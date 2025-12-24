export interface Env {
  DB: D1Database;
  APP_VERSION: string;
  FREE_LIMIT: string;
  PRO_LIMIT: string;
}

type Json = Record<string, any>;

function json(data: any, init: ResponseInit = {}) {
  return new Response(JSON.stringify(data), {
    ...init,
    headers: {
      "content-type": "application/json; charset=utf-8",
      ...(init.headers || {}),
    },
  });
}

function bad(msg: string, code = 400) {
  return json({ ok: false, error: msg }, { status: code });
}

function ok(data: any = {}) {
  return json({ ok: true, ...data });
}

function getUserId(req: Request): string | null {
  // MVP：前端必须传；后续可接 JWT / session
  const id = req.headers.get("X-User-Id");
  return id && id.trim() ? id.trim() : null;
}

function uuid(): string {
  return crypto.randomUUID();
}

async function readJson(req: Request): Promise<any> {
  try {
    return await req.json();
  } catch {
    return null;
  }
}

async function ensureUser(env: Env, userId: string) {
  const row = await env.DB.prepare(`SELECT id, plan_type FROM users WHERE id = ?`)
    .bind(userId)
    .first();
  if (row) return row as { id: string; plan_type: string };

  // 默认 free
  await env.DB.prepare(`INSERT INTO users (id, plan_type) VALUES (?, 'free')`)
    .bind(userId)
    .run();

  return { id: userId, plan_type: "free" };
}

function getLimit(planType: string, env: Env): number {
  if (planType === "ultra") return Number.MAX_SAFE_INTEGER;
  if (planType === "pro") return parseInt(env.PRO_LIMIT || "3", 10);
  return parseInt(env.FREE_LIMIT || "1", 10);
}

async function countWatchlist(env: Env, userId: string): Promise<number> {
  const r = await env.DB.prepare(`SELECT COUNT(*) as c FROM watchlist WHERE user_id = ?`)
    .bind(userId)
    .first();
  return Number((r as any)?.c || 0);
}

async function isSymbolInWatchlist(env: Env, userId: string, symbolId: string): Promise<boolean> {
  const r = await env.DB.prepare(`SELECT 1 as ok FROM watchlist WHERE user_id=? AND symbol_id=?`)
    .bind(userId, symbolId)
    .first();
  return !!r;
}

async function getPlan(env: Env, userId: string, planId: string) {
  const plan = await env.DB.prepare(
    `SELECT p.*, s.code as symbol_code, s.name as symbol_name, s.industry as symbol_industry
     FROM trade_plans p
     JOIN symbols s ON s.id = p.symbol_id
     WHERE p.id=? AND p.user_id=?`
  ).bind(planId, userId).first();
  return plan as any;
}

function nowEpoch(): number {
  return Math.floor(Date.now() / 1000);
}

// 系统判定（MVP 版本：只评“一致性”，不评涨跌对错）
function judge(plan: any, sellReason: string): { judgement: string; conclusion: string } {
  // sellReason：前端传 enum，如 "follow_plan" / "fear" / "panic" / "emotion" / "external" / "other"
  // 你也可以传 JSON，但先简单落地
  if (!plan) return { judgement: "no_plan", conclusion: "无计划，无法对照执行偏离。" };

  // 如果计划状态不是 armed/holding，说明流程不完整
  // 但仍可给结论：计划链条不完整
  if (plan.status === "draft") {
    return { judgement: "no_plan", conclusion: "计划未武装即结束，属于无计划交易。" };
  }

  // 简化：follow_plan = 按计划执行；否则情绪覆盖
  if (sellReason === "follow_plan") {
    return { judgement: "follow_plan", conclusion: "按计划执行，偏离为零。" };
  }

  // 其他原因一律归类为情绪覆盖（你后续可以细分 exec_error/judge_error）
  return { judgement: "emotion_override", conclusion: "卖出原因偏离计划，属于情绪覆盖计划。" };
}

async function route(req: Request, env: Env): Promise<Response> {
  const url = new URL(req.url);
  const path = url.pathname;
  const method = req.method.toUpperCase();

  // 健康检查
  if (path === "/health") return ok({ version: env.APP_VERSION });

  // 所有业务接口都需要 userId
  const userId = getUserId(req);
  if (!userId) return bad("Missing X-User-Id", 401);

  const user = await ensureUser(env, userId);

  // ---- symbols ----
  // GET /symbols?q=  用于用户搜索选择股票
  if (method === "GET" && path === "/symbols") {
    const q = (url.searchParams.get("q") || "").trim();
    // MVP：不做全文检索，简单 like
    const like = `%${q}%`;
    const rows = await env.DB.prepare(
      `SELECT id, code, name, industry
       FROM symbols
       WHERE (?='' OR code LIKE ? OR name LIKE ? OR industry LIKE ?)
       ORDER BY code
       LIMIT 50`
    ).bind(q, like, like, like).all();
    return ok({ items: rows.results || [] });
  }

  // POST /symbols/seed  （可选：你自己灌种子数据）
  if (method === "POST" && path === "/symbols/seed") {
    const body = await readJson(req);
    if (!body || !Array.isArray(body.items)) return bad("items[] required");
    const stmts: D1PreparedStatement[] = [];
    for (const it of body.items) {
      if (!it.code || !it.name) continue;
      stmts.push(
        env.DB.prepare(
          `INSERT OR IGNORE INTO symbols (id, code, name, industry) VALUES (?, ?, ?, ?)`
        ).bind(uuid(), String(it.code), String(it.name), it.industry ? String(it.industry) : null)
      );
    }
    if (stmts.length) await env.DB.batch(stmts);
    return ok({ inserted: stmts.length });
  }

  // ---- watchlist ----
  // GET /watchlist
  if (method === "GET" && path === "/watchlist") {
    const rows = await env.DB.prepare(
      `SELECT w.symbol_id, s.code, s.name, s.industry, w.created_at
       FROM watchlist w
       JOIN symbols s ON s.id = w.symbol_id
       WHERE w.user_id=?
       ORDER BY w.created_at DESC`
    ).bind(userId).all();
    return ok({ items: rows.results || [], plan_type: user.plan_type });
  }

  // POST /watchlist/add {symbol_id}
  if (method === "POST" && path === "/watchlist/add") {
    const body = await readJson(req);
    const symbolId = body?.symbol_id;
    if (!symbolId) return bad("symbol_id required");

    // 限制校验
    const limit = getLimit(user.plan_type, env);
    const current = await countWatchlist(env, userId);
    const already = await isSymbolInWatchlist(env, userId, symbolId);

    if (!already && current >= limit) {
      return bad(`watchlist limit reached for ${user.plan_type} (limit=${limit})`, 403);
    }

    await env.DB.prepare(`INSERT OR IGNORE INTO watchlist (user_id, symbol_id) VALUES (?, ?)`)
      .bind(userId, symbolId)
      .run();

    return ok();
  }

  // POST /watchlist/remove {symbol_id}
  if (method === "POST" && path === "/watchlist/remove") {
    const body = await readJson(req);
    const symbolId = body?.symbol_id;
    if (!symbolId) return bad("symbol_id required");
    await env.DB.prepare(`DELETE FROM watchlist WHERE user_id=? AND symbol_id=?`)
      .bind(userId, symbolId)
      .run();
    return ok();
  }

  // ---- plans ----
  // GET /plans?status=armed|holding|closed|draft
  if (method === "GET" && path === "/plans") {
    const status = (url.searchParams.get("status") || "").trim();
    const rows = await env.DB.prepare(
      `SELECT p.id, p.status, p.direction, p.buy_reason_text,
              p.target_low, p.target_high, p.created_at, p.updated_at,p.is_archived,
              s.code as symbol_code, s.name as symbol_name, s.industry as symbol_industry
       FROM trade_plans p
       JOIN symbols s ON s.id=p.symbol_id
       WHERE p.user_id=?
	AND p.is_archived=0
	AND (?='' OR p.status=?)

       ORDER BY p.updated_at DESC
       LIMIT 200`
    ).bind(userId, status, status).all();

    return ok({ items: rows.results || [] });
  }

// POST /plans/:id/archive
if (method === "POST" && path.startsWith("/plans/") && path.endsWith("/archive")) {
  const planId = path.split("/")[2];
  if (!planId) return bad("plan id required");

  const plan = await getPlan(env, userId, planId);
  if (!plan) return bad("not found", 404);

  const ts = nowEpoch();
  await env.DB.prepare(
    `UPDATE trade_plans SET is_archived=1, updated_at=? WHERE id=? AND user_id=?`
  ).bind(ts, planId, userId).run();

  return ok();
}

// POST /plans/:id/unarchive
if (method === "POST" && path.startsWith("/plans/") && path.endsWith("/unarchive")) {
  const planId = path.split("/")[2];
  if (!planId) return bad("plan id required");

  const plan = await getPlan(env, userId, planId);
  if (!plan) return bad("not found", 404);

  const ts = nowEpoch();
  await env.DB.prepare(
    `UPDATE trade_plans SET is_archived=0, updated_at=? WHERE id=? AND user_id=?`
  ).bind(ts, planId, userId).run();

  return ok();
}

// GET /plans/archived?status=
if (method === "GET" && path === "/plans/archived") {
  const status = (url.searchParams.get("status") || "").trim();
  const rows = await env.DB.prepare(
    `SELECT p.id, p.status, p.direction, p.buy_reason_text,
            p.target_low, p.target_high, p.created_at, p.updated_at,
            p.is_archived,
            s.code as symbol_code, s.name as symbol_name, s.industry as symbol_industry
     FROM trade_plans p
     JOIN symbols s ON s.id=p.symbol_id
     WHERE p.user_id=? AND p.is_archived=1 AND (?='' OR p.status=?)
     ORDER BY p.updated_at DESC
     LIMIT 200`
  ).bind(userId, status, status).all();

  return ok({ items: rows.results || [] });
}

  // POST /plans/create  （创建 draft）
  if (method === "POST" && path === "/plans/create") {
    const body = await readJson(req);
    if (!body) return bad("json body required");

    const {
      symbol_id,
      direction = "long",
      buy_reason_types,
      buy_reason_text,
      target_type,
      target_low,
      target_high,
      sell_conditions,
      time_take_profit_days,
      stop_type,
      stop_value,
      stop_time_days,
      entry_price,
    } = body;

    if (!symbol_id) return bad("symbol_id required");
    // 只允许对“已关注”的股票建计划：避免全量股票带来滥用和心智漂移
    const inWatchlist = await isSymbolInWatchlist(env, userId, symbol_id);
    if (!inWatchlist) return bad("symbol not in watchlist", 403);

    // 必填字段
    if (!Array.isArray(buy_reason_types) || buy_reason_types.length === 0) return bad("buy_reason_types[] required");
    if (!buy_reason_text || String(buy_reason_text).trim().length === 0) return bad("buy_reason_text required");
    if (!target_type) return bad("target_type required");
    if (target_low == null || target_high == null) return bad("target_low/target_high required");
    if (!Array.isArray(sell_conditions) || sell_conditions.length === 0) return bad("sell_conditions[] required");
    if (!stop_type) return bad("stop_type required");

    const id = uuid();
    const ts = nowEpoch();

    await env.DB.prepare(
      `INSERT INTO trade_plans (
        id, user_id, symbol_id, direction, status,
        buy_reason_types, buy_reason_text,
        target_type, target_low, target_high,
        sell_conditions, time_take_profit_days,
        stop_type, stop_value, stop_time_days,
        entry_price,
        created_at, updated_at
      ) VALUES (?, ?, ?, ?, 'draft', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
    )
      .bind(
        id, userId, symbol_id, String(direction),
        JSON.stringify(buy_reason_types), String(buy_reason_text),
        String(target_type), Number(target_low), Number(target_high),
        JSON.stringify(sell_conditions), time_take_profit_days == null ? null : Number(time_take_profit_days),
        String(stop_type), stop_value == null ? null : Number(stop_value),
        stop_time_days == null ? null : Number(stop_time_days),
        entry_price == null ? null : Number(entry_price),
        ts, ts
      )
      .run();

    return ok({ id });
  }

  // GET /plans/:id
  if (method === "GET" && path.startsWith("/plans/")) {
    const planId = path.split("/")[2];
    if (!planId) return bad("plan id required");
    const plan = await getPlan(env, userId, planId);
    if (!plan) return bad("not found", 404);

    const events = await env.DB.prepare(
      `SELECT id, event_type, summary, impact_target, triggered_exit, created_at
       FROM trade_events
       WHERE plan_id=? AND user_id=?
       ORDER BY created_at ASC`
    ).bind(planId, userId).all();

    const result = await env.DB.prepare(
      `SELECT plan_id, sell_price, sell_reason, system_judgement, conclusion_text, closed_at
       FROM trade_results
       WHERE plan_id=? AND user_id=?`
    ).bind(planId, userId).first();

    const edits = await env.DB.prepare(
      `SELECT id, field, old_value, new_value, edited_at
       FROM plan_edits
       WHERE plan_id=? AND user_id=?
       ORDER BY edited_at ASC`
    ).bind(planId, userId).all();

    return ok({
      plan,
      events: events.results || [],
      result: result || null,
      edits: edits.results || [],
    });
  }

  // POST /plans/:id/arm  （锁定进入 armed）
  if (method === "POST" && path.startsWith("/plans/") && path.endsWith("/arm")) {
    const parts = path.split("/");
    const planId = parts[2];
    const plan = await getPlan(env, userId, planId);
    if (!plan) return bad("not found", 404);
    if (plan.status !== "draft") return bad("only draft can be armed", 409);

    const ts = nowEpoch();
    await env.DB.prepare(
      `UPDATE trade_plans SET status='armed', updated_at=? WHERE id=? AND user_id=?`
    ).bind(ts, planId, userId).run();

    return ok();
  }

  // POST /plans/:id/update  （仅 draft 允许直接改；armed 后改走“修订记录”）
  if (method === "POST" && path.startsWith("/plans/") && path.endsWith("/update")) {
    const parts = path.split("/");
    const planId = parts[2];
    const plan = await getPlan(env, userId, planId);
    if (!plan) return bad("not found", 404);

    const body = await readJson(req);
    if (!body) return bad("json body required");

    const ts = nowEpoch();

    // 允许更新字段白名单
    const allowed = new Set([
      "direction",
      "buy_reason_types",
      "buy_reason_text",
      "target_type",
      "target_low",
      "target_high",
      "sell_conditions",
      "time_take_profit_days",
      "stop_type",
      "stop_value",
      "stop_time_days",
      "entry_price",
    ]);

    const updates: string[] = [];
    const binds: any[] = [];

    for (const [k, v] of Object.entries(body)) {
      if (!allowed.has(k)) continue;

      // armed/holding/closed 不允许改关键字段（尤其 buy_reason_text）
      if (plan.status !== "draft") {
        // 只允许补充 entry_price 这种执行类字段（你可扩）
        if (!["entry_price"].includes(k)) {
          // 写入修订记录，但不改原计划（避免事后改口）
          await env.DB.prepare(
            `INSERT INTO plan_edits (id, plan_id, user_id, field, old_value, new_value, edited_at)
             VALUES (?, ?, ?, ?, ?, ?, ?)`
          )
            .bind(
              uuid(), planId, userId, k,
              plan[k] == null ? null : String(plan[k]),
              v == null ? null : (typeof v === "string" ? v : JSON.stringify(v)),
              ts
            )
            .run();
          continue;
        }
      }

      // draft：直接更新
      updates.push(`${k}=?`);
      if (k === "buy_reason_types" || k === "sell_conditions") {
        binds.push(JSON.stringify(v));
      } else {
        binds.push(v);
      }
    }

    if (updates.length > 0) {
      binds.push(ts, planId, userId);
      await env.DB.prepare(
        `UPDATE trade_plans SET ${updates.join(", ")}, updated_at=? WHERE id=? AND user_id=?`
      ).bind(...binds).run();
    }

    return ok();
  }

  // POST /plans/:id/add-event
  if (method === "POST" && path.startsWith("/plans/") && path.endsWith("/add-event")) {
    const planId = path.split("/")[2];
    const plan = await getPlan(env, userId, planId);
    if (!plan) return bad("not found", 404);

    const body = await readJson(req);
    const { event_type, summary, impact_target, triggered_exit } = body || {};
    if (!event_type || !summary || !impact_target) return bad("event_type/summary/impact_target required");

    // 只允许 4 类
    const allowedTypes = new Set(["falsify", "forced", "verify", "structure"]);
    if (!allowedTypes.has(String(event_type))) return bad("invalid event_type");

    const id = uuid();
    await env.DB.prepare(
      `INSERT INTO trade_events (id, plan_id, user_id, event_type, summary, impact_target, triggered_exit)
       VALUES (?, ?, ?, ?, ?, ?, ?)`
    )
      .bind(
        id, planId, userId,
        String(event_type), String(summary).slice(0, 80),
        String(impact_target),
        triggered_exit ? 1 : 0
      )
      .run();

    return ok({ id });
  }

  // POST /plans/:id/close  {sell_price, sell_reason}
  if (method === "POST" && path.startsWith("/plans/") && path.endsWith("/close")) {
    const planId = path.split("/")[2];
    const plan = await getPlan(env, userId, planId);
    if (!plan) return bad("not found", 404);
    if (plan.status === "closed") return bad("already closed", 409);

    const body = await readJson(req);
    const sell_price = body?.sell_price;
    const sell_reason = body?.sell_reason; // e.g. "follow_plan" / "fear" / "panic" / "external" / "other"
    if (sell_price == null || !sell_reason) return bad("sell_price and sell_reason required");

    const { judgement, conclusion } = judge(plan, String(sell_reason));

    // 事务：写结果 + 更新计划状态
    const ts = nowEpoch();
    await env.DB.batch([
      env.DB.prepare(
        `INSERT OR REPLACE INTO trade_results
         (plan_id, user_id, sell_price, sell_reason, system_judgement, conclusion_text, closed_at)
         VALUES (?, ?, ?, ?, ?, ?, ?)`
      ).bind(planId, userId, Number(sell_price), String(sell_reason), judgement, conclusion, ts),
      env.DB.prepare(
        `UPDATE trade_plans SET status='closed', updated_at=? WHERE id=? AND user_id=?`
      ).bind(ts, planId, userId),
    ]);

    return ok({ system_judgement: judgement, conclusion_text: conclusion });
  }

  // ---- weekly report (MVP: PCS/TNR/LDC 的骨架先跑) ----
  // GET /report/weekly?days=7  （默认7天）
  if (method === "GET" && path === "/report/weekly") {
    const days = Number(url.searchParams.get("days") || "7");
    const since = nowEpoch() - Math.max(1, days) * 86400;

    // PCS：按计划执行占比（简化版：follow_plan / 总 closed）
    const totalClosedRow = await env.DB.prepare(
      `SELECT COUNT(*) as c FROM trade_results WHERE user_id=? AND closed_at>=?`
    ).bind(userId, since).first();
    const followRow = await env.DB.prepare(
      `SELECT COUNT(*) as c FROM trade_results WHERE user_id=? AND closed_at>=? AND system_judgement='follow_plan'`
    ).bind(userId, since).first();

    const total = Number((totalClosedRow as any)?.c || 0);
    const follow = Number((followRow as any)?.c || 0);
    const pcs = total === 0 ? 0 : Math.round((follow / total) * 100);

    // TNR/LDC：需要“触达目标区后未卖/该止损未止”依赖行情与实时触发记录
    // MVP 先返回 null，前端显示 “待启用（需要行情对照）”
    const tnr = null;
    const ldc = null;

    // 本周主要偏离类型
    const top = await env.DB.prepare(
      `SELECT system_judgement as k, COUNT(*) as c
       FROM trade_results
       WHERE user_id=? AND closed_at>=?
       GROUP BY system_judgement
       ORDER BY c DESC
       LIMIT 1`
    ).bind(userId, since).first();

    const mainDeviation = top ? (top as any).k : null;

    return ok({
      days,
      pcs,
      tnr,
      ldc,
      main_deviation: mainDeviation,
      note: "TNR/LDC 需要行情对照与触发记录，MVP 先占位。",
    });
  }

  return bad("not found", 404);
}

export default {
  fetch(req: Request, env: Env) {
    // CORS（简单粗暴，够用）
    if (req.method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: {
          "access-control-allow-origin": "*",
          "access-control-allow-methods": "GET,POST,OPTIONS",
          "access-control-allow-headers": "content-type, X-User-Id",
        },
      });
    }

    return route(req, env).then((res) => {
      const h = new Headers(res.headers);
      h.set("access-control-allow-origin", "*");
      return new Response(res.body, { status: res.status, headers: h });
    });
  },
};

export interface Env {
  DB: D1Database;
  APP_VERSION: string;
  FREE_LIMIT: string;
  PRO_LIMIT: string;
  JWT_ISSUER: string;
  JWT_AUDIENCE: string;
  JWT_SECRET: string;
}

type Json = Record<string, any>;

import { signJwtHS256, verifyJwtHS256, hashOtp } from "./auth_utils";

function nowEpoch() {
  return Math.floor(Date.now() / 1000);
}

class HttpError extends Error {
  status: number;
  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}

async function requireAuth(req: Request, env: Env): Promise<{ userId: string; sessionId: string }> {
  const auth = req.headers.get("Authorization");
  if (!auth || !auth.startsWith("Bearer ")) {
    throw new HttpError(401, "Missing or invalid Authorization header");
  }

  const token = auth.substring(7);
  const payload = await verifyJwtHS256(token, env.JWT_SECRET, env.JWT_ISSUER, env.JWT_AUDIENCE);

  if (!payload || !payload.sub || !payload.sid) {
    throw new HttpError(401, "Invalid or expired token");
  }

  const session = await env.DB.prepare(
    "SELECT id, revoked FROM user_sessions WHERE id = ? AND user_id = ?"
  ).bind(payload.sid, payload.sub).first();

  if (!session || (session as any).revoked) {
    throw new HttpError(401, "Session revoked or not found");
  }

  await env.DB.prepare(
    "UPDATE user_sessions SET last_seen_at = ? WHERE id = ?"
  ).bind(Math.floor(Date.now() / 1000), payload.sid).run();

  return { userId: payload.sub, sessionId: payload.sid };
}


//xinjia
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

// getUserId removed in favor of requireAuth


function uuid(): string {
  return crypto.randomUUID();
}
//新加鉴权


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

  // ---- Auth Routes ----
  if (method === "POST" && path === "/auth/request-otp") {
    const body = await readJson(req);
    const email = body?.email;
    if (!email || !email.includes("@")) return bad("Invalid email");

    const code = Math.floor(100000 + Math.random() * 900000).toString();
    console.log(`[OTP] ${email}: ${code}`); // In dev, we can see it in logs

    const hash = await hashOtp(code);
    const expiresAt = Math.floor(Date.now() / 1000) + 600; // 10 mins

    await env.DB.prepare(
      "INSERT INTO login_otps (id, email, code_hash, expires_at, attempts, created_at) VALUES (?, ?, ?, ?, ?, ?)"
    ).bind(uuid(), email, hash, expiresAt, 0, Math.floor(Date.now() / 1000)).run();

    return ok();
  }

  if (method === "POST" && path === "/auth/verify-otp") {
    const body = await readJson(req);
    const { email, code } = body || {};
    if (!email || !code) return bad("Email and code required");

    const otp = await env.DB.prepare(
      "SELECT * FROM login_otps WHERE email = ? AND expires_at > ? AND attempts < 5 ORDER BY created_at DESC LIMIT 1"
    ).bind(email, Math.floor(Date.now() / 1000)).first();

    if (!otp) return bad("Invalid or expired OTP", 401);

    const hash = await hashOtp(code);
    if ((otp as any).code_hash !== hash) {
      await env.DB.prepare("UPDATE login_otps SET attempts = attempts + 1 WHERE id = ?")
        .bind((otp as any).id).run();
      return bad("Invalid OTP", 401);
    }

    // Success! Find or create user
    let user = await env.DB.prepare("SELECT id, email FROM app_users WHERE email = ?")
      .bind(email).first();
    
    let userId: string;
    if (!user) {
      userId = uuid();
      await env.DB.prepare("INSERT INTO app_users (id, email, created_at) VALUES (?, ?, ?)")
        .bind(userId, email, Math.floor(Date.now() / 1000)).run();
    } else {
      userId = (user as any).id;
    }

    // Create session
    const sessionId = uuid();
    await env.DB.prepare(
      "INSERT INTO user_sessions (id, user_id, revoked, created_at, last_seen_at) VALUES (?, ?, 0, ?, ?)"
    ).bind(sessionId, userId, Math.floor(Date.now() / 1000), Math.floor(Date.now() / 1000)).run();

    // Update last login
    await env.DB.prepare("UPDATE app_users SET last_login_at = ? WHERE id = ?")
      .bind(Math.floor(Date.now() / 1000), userId).run();

    // Sign JWT
    const token = await signJwtHS256({
      sub: userId,
      sid: sessionId,
      iss: env.JWT_ISSUER,
      aud: env.JWT_AUDIENCE,
      iat: Math.floor(Date.now() / 1000),
      exp: Math.floor(Date.now() / 1000) + (30 * 24 * 60 * 60) // 30 days
    }, env.JWT_SECRET);

    return ok({
      token,
      user: { id: userId, email }
    });
  }

  // ---- Business Routes (Require Auth) ----
  let userId: string;
  try {
    const auth = await requireAuth(req, env);
    userId = auth.userId;
  } catch (e) {
    if (e instanceof HttpError) {
      return bad(e.message, e.status);
    }
    return bad("Authentication failed", 401);
  }

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
              p.target_low, p.target_high, p.created_at, p.updated_at, p.is_archived,
              s.code as symbol_code, s.name as symbol_name, s.industry as symbol_industry
       FROM trade_plans p
       JOIN symbols s ON s.id = p.symbol_id
       WHERE p.user_id = ?
       AND p.is_archived = 0
       AND (? = '' OR p.status = ?)
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
            p.target_low, p.target_high, p.created_at, p.updated_at, p.is_archived,
            s.code as symbol_code, s.name as symbol_name, s.industry as symbol_industry
     FROM trade_plans p
     JOIN symbols s ON s.id = p.symbol_id
     WHERE p.user_id = ? AND p.is_archived = 1 AND (? = '' OR p.status = ?)
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
    if (String(plan.status) === "closed") return bad("closed plan is read-only", 409);

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

  // ✅ 关键：closed 后端只读冻结
  if (String(plan.status) === "closed") return bad("closed plan is read-only", 409);

  const body = await readJson(req);
  const { event_type, summary, impact_target, triggered_exit } = body || {};

  // ✅ triggered_exit 必填（必须明确回答：是否触发退出条件）
  if (triggered_exit === undefined || triggered_exit === null) {
    return bad("triggered_exit required");
  }

  if (!event_type || !summary || !impact_target) return bad("event_type/summary/impact_target required");

  // 只允许 4 类
  const allowedTypes = new Set(["falsify", "forced", "verify", "structure"]);
  if (!allowedTypes.has(String(event_type))) return bad("invalid event_type");

  // impact_target 白名单（建议加上，防脏数据）
  const allowedTargets = new Set(["buy_logic", "sell_logic", "stop_loss"]);
  if (!allowedTargets.has(String(impact_target))) return bad("invalid impact_target");

  const id = uuid();
  const summaryText = String(summary).trim();
  if (!summaryText) return bad("summary required");

  await env.DB.prepare(
    `INSERT INTO trade_events (id, plan_id, user_id, event_type, summary, impact_target, triggered_exit)
     VALUES (?, ?, ?, ?, ?, ?, ?)`
  )
    .bind(
      id, planId, userId,
      String(event_type),
      summaryText.slice(0, 40), // ✅ 与前端统一：40
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

  // ---- self reviews (Step 7) ----
  // POST /reviews/self
  if (method === "POST" && path === "/reviews/self") {
    const body = await readJson(req);
    if (!body) return bad("json body required");

    const { plan_id } = body;
    if (!plan_id) return bad("plan_id required");

    // 1. Strict Validation: Ownership and Status
    const plan = await getPlan(env, userId, plan_id);
    if (!plan) return bad("plan not found", 404);
    if (plan.status !== "closed") {
      return bad("only closed plans can be self-reviewed", 403);
    }

    // 2. Uniqueness: Check if already reviewed
    const existing = await env.DB.prepare(
      "SELECT 1 FROM trade_self_reviews WHERE user_id = ? AND plan_id = ?"
    ).bind(userId, plan_id).first();
    if (existing) return bad("self-review already exists for this plan", 409);

    // 3. Data Validation: 13 dimensions (d1-d4, h1-h4, e1-e3, r1-r2)
    const dimensions = ["d1", "d2", "d3", "d4", "h1", "h2", "h3", "h4", "e1", "e2", "e3", "r1", "r2"];
    const scores: Record<string, number> = {};
    for (const d of dimensions) {
      const val = body[d];
      if (val === undefined || val === null) return bad(`${d} required`);
      const num = Number(val);
      if (num < 1 || num > 3) return bad(`${d} must be between 1 and 3`);
      scores[d] = num;
    }

    // 4. Persistence
    const id = uuid();
    const ts = nowEpoch();
    
    // Get result_id (which is plan_id in trade_results)
    const result = await env.DB.prepare(
      "SELECT plan_id FROM trade_results WHERE plan_id = ? AND user_id = ?"
    ).bind(plan_id, userId).first();
    if (!result) return bad("trade result not found", 404);

    await env.DB.prepare(
      `INSERT INTO trade_self_reviews (
        id, user_id, plan_id, result_id,
        d1, d2, d3, d4, h1, h2, h3, h4, e1, e2, e3, r1, r2,
        schema_version, created_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?)`
    ).bind(
      id, userId, plan_id, plan_id,
      scores.d1, scores.d2, scores.d3, scores.d4,
      scores.h1, scores.h2, scores.h3, scores.h4,
      scores.e1, scores.e2, scores.e3,
      scores.r1, scores.r2,
      ts
    ).run();

    return ok({ id });
  }

  // GET /reviews/self/:plan_id
  if (method === "GET" && path.startsWith("/reviews/self/")) {
    const planId = path.split("/")[3];
    if (!planId) return bad("plan_id required");

    const review = await env.DB.prepare(
      "SELECT * FROM trade_self_reviews WHERE plan_id = ? AND user_id = ?"
    ).bind(planId, userId).first();

    return ok({ review: review || null });
  }

  // ---- weekly report (MVP: PCS/TNR/LDC 的骨架先跑) ----
  // GET /report/weekly?days=7  （默认7天）
  if (method === "GET" && path === "/report/weekly") {
    const sql = `
      WITH params AS (
        SELECT
          CAST(strftime('%s', date('now','weekday 1','-7 days')) AS INTEGER) AS ws,
          CAST(strftime('%s','now') AS INTEGER) AS we
      ),
      weekly_closed AS (
        SELECT r.plan_id, r.user_id, r.sell_price, r.system_judgement, r.conclusion_text, r.closed_at
        FROM trade_results r, params p
        WHERE r.user_id = ?
          AND r.closed_at >= p.ws AND r.closed_at < p.we
      ),
      counts AS (
        SELECT
          COUNT(*) AS total_closed,
          SUM(CASE WHEN system_judgement='follow_plan' THEN 1 ELSE 0 END) AS cnt_follow,
          SUM(CASE WHEN system_judgement='no_plan' THEN 1 ELSE 0 END) AS cnt_no_plan,
          SUM(CASE WHEN system_judgement='emotion_override' THEN 1 ELSE 0 END) AS cnt_emotion
        FROM weekly_closed
      ),
      main_dev AS (
        SELECT
          CASE
            WHEN (SELECT total_closed FROM counts)=0 THEN 'no_trades'
            WHEN (SELECT cnt_no_plan FROM counts) > 0 THEN 'no_plan'
            WHEN (SELECT cnt_emotion FROM counts) > 0 THEN 'emotion_override'
            ELSE
              CASE
                WHEN EXISTS (
                  SELECT 1
                  FROM trade_events e, params p
                  WHERE e.user_id=?
                    AND e.event_type='forced'
                    AND e.created_at >= p.ws AND e.created_at < p.we
                ) THEN 'forced'
                ELSE 'none'
              END
          END AS main_deviation
      ),
      rep_conclusion AS (
        SELECT c.conclusion_text
        FROM weekly_closed c
        WHERE c.system_judgement <> 'follow_plan'
        ORDER BY c.closed_at DESC
        LIMIT 1
      ),
      rep_conclusion_fallback AS (
        SELECT c.conclusion_text
        FROM weekly_closed c
        ORDER BY c.closed_at DESC
        LIMIT 1
      ),
      tnr AS (
        SELECT
          CASE
            WHEN (SELECT total_closed FROM counts)=0 AND NOT EXISTS (
              SELECT 1 FROM trade_events e, params p
              WHERE e.user_id=?
                AND e.event_type='verify'
                AND e.impact_target='sell_logic'
                AND e.triggered_exit=0
                AND e.created_at >= p.ws AND e.created_at < p.we
            ) THEN '不适用'
            WHEN EXISTS (
              SELECT 1 FROM trade_events e, params p
              WHERE e.user_id=?
                AND e.event_type='verify'
                AND e.impact_target='sell_logic'
                AND e.triggered_exit=0
                AND e.created_at >= p.ws AND e.created_at < p.we
            ) THEN '发生'
            ELSE '未发生'
          END AS tnr_status
      ),
      ldc_calc AS (
        SELECT
          SUM(
            CASE
              WHEN p.stop_value IS NULL THEN 0
              WHEN p.direction='long'  AND wc.sell_price < p.stop_value THEN (p.stop_value - wc.sell_price)
              WHEN p.direction='short' AND wc.sell_price > p.stop_value THEN (wc.sell_price - p.stop_value)
              ELSE 0
            END
          ) AS ldc_value,
          SUM(
            CASE
              WHEN p.stop_value IS NULL THEN 0
              WHEN EXISTS (
                SELECT 1 FROM trade_events e
                WHERE e.plan_id = wc.plan_id
                  AND e.user_id=?
                  AND e.impact_target='stop_loss'
                  AND e.triggered_exit=0
              ) THEN 1
              ELSE 0
            END
          ) AS ldc_evidence_count
        FROM weekly_closed wc
        JOIN trade_plans p ON p.id = wc.plan_id AND p.user_id = ?
      ),
      ldc AS (
        SELECT
          CASE
            WHEN (SELECT total_closed FROM counts)=0 THEN '不适用'
            WHEN (SELECT ldc_evidence_count FROM ldc_calc) > 0 THEN '发生'
            ELSE '未发生'
          END AS ldc_status,
          CASE
            WHEN (SELECT ldc_evidence_count FROM ldc_calc) > 0 THEN (SELECT ldc_value FROM ldc_calc)
            ELSE NULL
          END AS ldc_value
      )
      SELECT
        (SELECT total_closed FROM counts) AS total_closed,
        CASE
          WHEN (SELECT total_closed FROM counts)=0 THEN NULL
          ELSE ROUND( (CAST((SELECT cnt_follow FROM counts) AS REAL) / (SELECT total_closed FROM counts)) * 100, 0)
        END AS pcs,
        (SELECT main_deviation FROM main_dev) AS main_deviation,
        COALESCE((SELECT conclusion_text FROM rep_conclusion),
                 (SELECT conclusion_text FROM rep_conclusion_fallback)) AS conclusion_text,
        (SELECT tnr_status FROM tnr) AS tnr_status,
        (SELECT ldc_status FROM ldc) AS ldc_status,
        (SELECT ldc_value FROM ldc) AS ldc_value
    `;

    const row = await env.DB.prepare(sql)
      .bind(userId, userId, userId, userId, userId, userId)
      .first();

    if (!row) return bad("Failed to calculate report");

    return ok({
      has_trades: Number((row as any).total_closed || 0) > 0,
      pcs: (row as any).pcs,
      main_deviation: (row as any).main_deviation,
      conclusion_text: (row as any).conclusion_text,
      tnr_status: (row as any).tnr_status,
      ldc_status: (row as any).ldc_status,
      ldc_value: (row as any).ldc_value
    });
  }

  return bad("not found", 404);
}

export default {
  async fetch(req: Request, env: Env) {
    // CORS（简单粗暴，够用）
    if (req.method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: {
          "access-control-allow-origin": "*",
          "access-control-allow-methods": "GET,POST,OPTIONS",
          "access-control-allow-headers": "content-type, Authorization",
        },
      });
    }

    try {
      const res = await route(req, env);
      const h = new Headers(res.headers);
      h.set("access-control-allow-origin", "*");
      return new Response(res.body, { status: res.status, headers: h });
    } catch (e: any) {
      console.error(e);
      return new Response(JSON.stringify({ ok: false, error: e.message || String(e) }), {
        status: 500,
        headers: {
          "content-type": "application/json; charset=utf-8",
          "access-control-allow-origin": "*",
        },
      });
    }
  },
};

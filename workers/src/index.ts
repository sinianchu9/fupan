export interface Env {
  DB: D1Database;
  APP_VERSION: string;
  FREE_LIMIT: string;
  PRO_LIMIT: string;
  JWT_ISSUER: string;
  JWT_AUDIENCE: string;
  JWT_SECRET: string;
  RESEND_API_KEY: string;
}

type Json = Record<string, any>;

interface Evidence {
  type: 'plan_field' | 'trade' | 'event';
  id: string;
  title: string;
  detail: string;
  ts: number;
}

interface WeeklyMetric {
  key: string;
  name: string;
  status: 'triggered' | 'not_triggered' | 'na' | 'insufficient_data';
  score: number | null;
  metrics: {
    deviation_pct?: number | null;
    cost_pct?: number | null;
    delay_level?: number | null;
  };
  thresholds: {
    deviation_threshold: number;
    hit_epsilon: number;
  };
  summary_line: string;
  evidence: Evidence[];
}

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
    
    // Rate Limiting: Check if an OTP was sent recently (e.g., last 60s)
    const recentOtp = await env.DB.prepare(
      "SELECT created_at FROM login_otps WHERE email = ? AND created_at > ? ORDER BY created_at DESC LIMIT 1"
    ).bind(email, nowEpoch() - 60).first();
    
    if (recentOtp) {
      return bad("Please wait 60 seconds before requesting a new code", 429);
    }

    // Send email via Resend
    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${env.RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: "复盘助手 <auth@mail.miamioh.edu.pl>",
        to: [email],
        subject: "【复盘助手】您的登录验证码",
        html: `<p>您的验证码是 <strong>${code}</strong>，有效期 10 分钟。请勿泄露给他人。</p>`,
      }),
    });

    if (!res.ok) {
      const error = await res.text();
      console.error("Resend API Error:", error);
      return bad("Failed to send verification code", 500);
    }

    // Use email as salt and JWT_SECRET as pepper
    const hash = await hashOtp(code, email, env.JWT_SECRET);
    const expiresAt = nowEpoch() + 600; // 10 mins

    await env.DB.prepare(
      "INSERT INTO login_otps (id, email, code_hash, expires_at, attempts, created_at) VALUES (?, ?, ?, ?, ?, ?)"
    ).bind(uuid(), email, hash, expiresAt, 0, nowEpoch()).run();

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

    const hash = await hashOtp(code, email, env.JWT_SECRET);
    if ((otp as any).code_hash !== hash) {
      await env.DB.prepare("UPDATE login_otps SET attempts = attempts + 1 WHERE id = ?")
        .bind((otp as any).id).run();
      return bad("Invalid OTP", 401);
    }

    // Success! Invalidate OTP immediately
    await env.DB.prepare("UPDATE login_otps SET expires_at = 0 WHERE id = ?")
      .bind((otp as any).id).run();

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
              p.planned_entry_price, p.actual_entry_price, p.entry_driver,
              COALESCE(p.actual_entry_price, p.planned_entry_price, p.entry_price) as entry_price,
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
            p.planned_entry_price, p.actual_entry_price, p.entry_driver,
            COALESCE(p.actual_entry_price, p.planned_entry_price, p.entry_price) as entry_price,
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
      planned_entry_price,
      entry_price, // 兼容字段
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
        planned_entry_price, entry_price,
        created_at, updated_at
      ) VALUES (?, ?, ?, ?, 'draft', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
    )
      .bind(
        id, userId, symbol_id, String(direction),
        JSON.stringify(buy_reason_types), String(buy_reason_text),
        String(target_type), Number(target_low), Number(target_high),
        JSON.stringify(sell_conditions), time_take_profit_days == null ? null : Number(time_take_profit_days),
        String(stop_type), stop_value == null ? null : Number(stop_value),
        stop_time_days == null ? null : Number(stop_time_days),
        planned_entry_price != null ? Number(planned_entry_price) : (entry_price != null ? Number(entry_price) : null),
        planned_entry_price != null ? Number(planned_entry_price) : (entry_price != null ? Number(entry_price) : null),
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
      `SELECT id, event_type, summary, impact_target, triggered_exit, event_stage, behavior_driver, price_at_event, created_at
       FROM trade_events
       WHERE plan_id=? AND user_id=?
       ORDER BY created_at ASC`
    ).bind(planId, userId).all();

    const result = await env.DB.prepare(
      `SELECT plan_id, sell_price, sell_reason, system_judgement, conclusion_text, post_exit_best_price, epc_opportunity_pct, closed_at
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
    
    const body = await readJson(req);
    const actual_entry_price = body?.actual_entry_price || body?.entry_price;
    const entry_driver = body?.entry_driver;
    if (actual_entry_price == null) return bad("actual_entry_price required", 400);

    const ts = nowEpoch();
    await env.DB.prepare(
      `UPDATE trade_plans SET status='armed', actual_entry_price=?, entry_price=?, entry_driver=?, updated_at=? WHERE id=? AND user_id=?`
    ).bind(Number(actual_entry_price), Number(actual_entry_price), entry_driver || null, ts, planId, userId).run();

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
      "planned_entry_price",
      "actual_entry_price",
      "entry_driver",
      "entry_price",
      "exit_plan_target_price",
    ]);

    const updates: string[] = [];
    const binds: any[] = [];

    for (const [k, v] of Object.entries(body)) {
      if (!allowed.has(k)) continue;

      // armed/holding/closed 不允许改关键字段（尤其 buy_reason_text）
      if (plan.status !== "draft") {
        // 只允许补充 actual_entry_price 这种执行类字段
        if (!["actual_entry_price", "entry_price"].includes(k)) {
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
      // 同步更新兼容字段
      if (k === "planned_entry_price" && plan.status === "draft") {
        updates.push(`entry_price=?`);
        binds.push(v);
      }
      if (k === "actual_entry_price" && plan.status !== "draft") {
        updates.push(`entry_price=?`);
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
  const { event_type, summary, impact_target, triggered_exit, event_stage, behavior_driver, price_at_event } = body || {};

  // ✅ triggered_exit 必填（必须明确回答：是否触发退出条件）
  if (triggered_exit === undefined || triggered_exit === null) {
    return bad("triggered_exit required");
  }

  if (!summary || !event_stage) return bad("summary and event_stage required");

  // 兼容旧版 event_type 和 impact_target
  const finalEventType = event_type || "external_change";
  const finalImpactTarget = impact_target || "buy_logic";

  const id = uuid();
  const summaryText = String(summary).trim();
  if (!summaryText) return bad("summary required");

  await env.DB.prepare(
    `INSERT INTO trade_events (id, plan_id, user_id, event_type, summary, impact_target, triggered_exit, event_stage, behavior_driver, price_at_event)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
  )
    .bind(
      id, planId, userId,
      String(finalEventType),
      summaryText.slice(0, 40),
      String(finalImpactTarget),
      triggered_exit ? 1 : 0,
      event_stage || null,
      behavior_driver || null,
      price_at_event != null ? Number(price_at_event) : null
    )
    .run();

  return ok({ id });
}


  // POST /plans/:id/close  {sell_price, sell_reason}
  if (method === "POST" && path.startsWith("/plans/") && path.endsWith("/close")) {
    const planId = path.split("/")[2];
    const plan = await getPlan(env, userId, planId);
    if (!plan) return bad("not found", 404);
    
    // ✅ State Machine Integrity: Only 'armed' plans can be closed
    if (plan.status !== "armed" && plan.status !== "holding") {
      return bad(`cannot close plan in '${plan.status}' status`, 403);
    }

    if (plan.actual_entry_price == null) {
      return bad("actual_entry_price required before closing", 400);
    }

    const body = await readJson(req);
    const { sell_price, sell_reason, post_exit_best_price, exit_plan_target_price } = body || {};
    if (sell_price == null || !sell_reason) return bad("sell_price and sell_reason required");

    const { judgement, conclusion } = judge(plan, String(sell_reason));

    // Calculate EPC
    let epc_opportunity_pct = null;
    const final_target_price = exit_plan_target_price || plan.exit_plan_target_price;
    
    if (final_target_price && Number(sell_price) < Number(final_target_price) && post_exit_best_price && Number(post_exit_best_price) > Number(sell_price)) {
      // Check for invalidation events
      const invalidation = await env.DB.prepare(
        "SELECT 1 FROM trade_events WHERE plan_id = ? AND triggered_exit = 1"
      ).bind(planId).first();
      
      if (!invalidation) {
        epc_opportunity_pct = (Number(post_exit_best_price) - Number(sell_price)) / Number(sell_price);
      }
    }

    // 事务：写结果 + 更新计划状态
    const ts = nowEpoch();
    const stmts = [
      env.DB.prepare(
        `INSERT INTO trade_results
         (plan_id, user_id, sell_price, sell_reason, system_judgement, conclusion_text, post_exit_best_price, epc_opportunity_pct, closed_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`
      ).bind(planId, userId, Number(sell_price), String(sell_reason), judgement, conclusion, 
             post_exit_best_price != null ? Number(post_exit_best_price) : null, 
             epc_opportunity_pct, ts),
      env.DB.prepare(
        `UPDATE trade_plans SET status='closed', updated_at=? WHERE id=? AND user_id=?`
      ).bind(ts, planId, userId),
    ];

    if (exit_plan_target_price != null) {
      stmts.push(
        env.DB.prepare(`UPDATE trade_plans SET exit_plan_target_price=? WHERE id=?`).bind(Number(exit_plan_target_price), planId)
      );
    }

    await env.DB.batch(stmts);

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

  // ---- weekly report (Audit Style) ----
  if (method === "GET" && path === "/report/weekly") {
    const DEVIATION_THRESHOLD = 0.01;
    const HIT_EPSILON = 0.005;

    // 1. Calculate week range (Monday to Sunday)
    const now = new Date();
    const day = now.getDay(); // 0 is Sunday, 1 is Monday...
    const diffToMonday = (day === 0 ? -6 : 1) - day;
    const monday = new Date(now);
    monday.setHours(0, 0, 0, 0);
    monday.setDate(now.getDate() + diffToMonday);
    
    const ws = Math.floor(monday.getTime() / 1000);
    const we = Math.floor(now.getTime() / 1000);

    // 2. Fetch Data
    // Results closed this week
    const results = (await env.DB.prepare(
      "SELECT * FROM trade_results WHERE user_id = ? AND closed_at >= ? AND closed_at < ?"
    ).bind(userId, ws, we).all()).results;

    // Events created this week
    const events = (await env.DB.prepare(
      "SELECT * FROM trade_events WHERE user_id = ? AND created_at >= ? AND created_at < ?"
    ).bind(userId, ws, we).all()).results;

    // Plans involved (either closed this week or had events this week)
    const planIds = new Set<string>();
    results.forEach((r: any) => planIds.add(r.plan_id));
    events.forEach((e: any) => planIds.add(e.plan_id));

    let plans: any[] = [];
    if (planIds.size > 0) {
      const placeholders = Array.from(planIds).map(() => "?").join(",");
      plans = (await env.DB.prepare(
        `SELECT * FROM trade_plans WHERE user_id = ? AND id IN (${placeholders})`
      ).bind(userId, ...Array.from(planIds)).all()).results;
    }

    const planMap = new Map(plans.map(p => [p.id, p]));

    // 3. Metric Calculations
    
    // --- 4.2 E-TNR (Buy) ---
    const calculateETNR = (): WeeklyMetric => {
      const evidence: Evidence[] = [];
      let maxScore = 0;
      let triggered = false;
      let hasData = false;
      let na = true;

      for (const p of plans) {
        if (p.planned_entry_price) {
          na = false;
          if (p.actual_entry_price) {
            hasData = true;
            if (p.actual_entry_price > p.planned_entry_price * (1 + DEVIATION_THRESHOLD)) {
              triggered = true;
              const dev = (p.actual_entry_price - p.planned_entry_price) / p.planned_entry_price;
              const score = Math.min(100, (dev / 0.10) * 100);
              if (score > maxScore) maxScore = score;
              
              evidence.push({
                type: 'plan_field',
                id: p.id,
                title: `${p.symbol_code} 预算价`,
                detail: `planned_entry_price=${p.planned_entry_price}`,
                ts: p.created_at
              });
              evidence.push({
                type: 'trade',
                id: p.id,
                title: `${p.symbol_code} 实际建仓价`,
                detail: `actual_entry_price=${p.actual_entry_price}`,
                ts: p.updated_at
              });
            }
          }
        }
      }

      return {
        key: 'E-TNR',
        name: '买入追高',
        status: na ? 'na' : (!hasData ? 'insufficient_data' : (triggered ? 'triggered' : 'not_triggered')),
        score: triggered ? Math.round(maxScore) : 0,
        metrics: { deviation_pct: triggered ? maxScore / 1000 : null }, // Placeholder logic
        thresholds: { deviation_threshold: DEVIATION_THRESHOLD, hit_epsilon: HIT_EPSILON },
        summary_line: triggered 
          ? `本周存在买入追高偏离，最大偏离幅度约 ${Math.round(maxScore/10)}%。`
          : "本周未发现明显的买入追高行为。",
        evidence: evidence.slice(0, 5)
      };
    };

    // --- 4.3 E-LDC (Buy) ---
    const calculateELDC = (): WeeklyMetric => {
      const evidence: Evidence[] = [];
      let triggered = false;
      let maxScore = 0;

      for (const e of events) {
        if (e.event_stage === 'entry_non_action') {
          triggered = true;
          let score = 30;
          if (e.price_at_event) score = 70;
          else if (e.summary) score = 50;
          
          if (score > maxScore) maxScore = score;
          evidence.push({
            type: 'event',
            id: e.id,
            title: '低位未执行事件',
            detail: e.summary || '未填写摘要',
            ts: e.created_at
          });
        }
      }

      return {
        key: 'E-LDC',
        name: '低位未买',
        status: triggered ? 'triggered' : 'not_triggered',
        score: maxScore,
        metrics: {},
        thresholds: { deviation_threshold: DEVIATION_THRESHOLD, hit_epsilon: HIT_EPSILON },
        summary_line: triggered 
          ? `本周记录了 ${evidence.length} 条低位未执行证据。`
          : "本周未记录低位未执行事件。",
        evidence
      };
    };

    // --- 4.4 TNR (Sell) ---
    const calculateTNR = (): WeeklyMetric => {
      const evidence: Evidence[] = [];
      let triggered = false;
      let hasTarget = false;
      let hasEvent = false;

      for (const p of plans) {
        if (p.target_high || p.exit_plan_target_price) {
          hasTarget = true;
          const planEvents = events.filter((e: any) => e.plan_id === p.id && e.event_type === 'verify');
          if (planEvents.length > 0) {
            hasEvent = true;
            // Check if sold after event
            const result = results.find((r: any) => r.plan_id === p.id);
            if (!result || result.closed_at < planEvents[0].created_at) {
              triggered = true;
              evidence.push({
                type: 'plan_field',
                id: p.id,
                title: `${p.symbol_code} 卖出目标`,
                detail: `target=${p.target_high || p.exit_plan_target_price}`,
                ts: p.created_at
              });
              evidence.push({
                type: 'event',
                id: planEvents[0].id,
                title: '验证/兑现事件',
                detail: planEvents[0].summary,
                ts: planEvents[0].created_at
              });
            }
          }
        }
      }

      return {
        key: 'TNR',
        name: '到位不卖',
        status: !hasTarget ? 'na' : (!hasEvent ? 'insufficient_data' : (triggered ? 'triggered' : 'not_triggered')),
        score: triggered ? 80 : 0,
        metrics: {},
        thresholds: { deviation_threshold: DEVIATION_THRESHOLD, hit_epsilon: HIT_EPSILON },
        summary_line: triggered 
          ? "本周存在目标到位后未及时卖出的情况。"
          : (hasEvent ? "本周目标到位后已执行卖出。" : "本周未记录目标验证事件。"),
        evidence
      };
    };

    // --- 4.5 LDC (Sell) ---
    const calculateLDC = (): WeeklyMetric => {
      const evidence: Evidence[] = [];
      let maxScore = 0;
      let triggered = false;
      let na = true;
      let hasData = false;

      for (const r of results) {
        const p = planMap.get(r.plan_id);
        if (p && p.stop_value) {
          na = false;
          hasData = true;
          if (r.sell_price < p.stop_value * (1 - DEVIATION_THRESHOLD)) {
            triggered = true;
            const cost = (p.stop_value - r.sell_price) / p.stop_value;
            const score = Math.min(100, (cost / 0.15) * 100);
            if (score > maxScore) maxScore = score;

            evidence.push({
              type: 'plan_field',
              id: p.id,
              title: `${p.symbol_code} 止损价`,
              detail: `stop_price=${p.stop_value}`,
              ts: p.created_at
            });
            evidence.push({
              type: 'trade',
              id: r.plan_id,
              title: `${p.symbol_code} 实际退出价`,
              detail: `sell_price=${r.sell_price}`,
              ts: r.closed_at
            });
          }
        }
      }

      return {
        key: 'LDC',
        name: '止损拖延',
        status: na ? 'na' : (!hasData ? 'insufficient_data' : (triggered ? 'triggered' : 'not_triggered')),
        score: Math.round(maxScore),
        metrics: { cost_pct: triggered ? maxScore / 1000 : null },
        thresholds: { deviation_threshold: DEVIATION_THRESHOLD, hit_epsilon: HIT_EPSILON },
        summary_line: triggered 
          ? `本周存在止损拖延，最大额外损失约 ${Math.round(maxScore/6.6)}%。`
          : "本周未发现明显的止损拖延行为。",
        evidence: evidence.slice(0, 5)
      };
    };

    // --- 4.6 EPC (Sell) ---
    const calculateEPC = (): WeeklyMetric => {
      const evidence: Evidence[] = [];
      let triggered = false;
      let maxScore = 0;
      let na = true;

      for (const r of results) {
        const p = planMap.get(r.plan_id);
        if (p && (p.target_high || p.exit_plan_target_price)) {
          na = false;
          const devEvent = events.find((e: any) => e.plan_id === r.plan_id && e.event_stage === 'exit_deviation');
          const failEvent = events.find((e: any) => e.plan_id === r.plan_id && e.triggered_exit);
          
          if (devEvent && !failEvent) {
            triggered = true;
            let score = 30;
            if (p.target_high) score = 70;
            if (score > maxScore) maxScore = score;

            evidence.push({
              type: 'event',
              id: devEvent.id,
              title: '卖出执行偏移',
              detail: devEvent.summary,
              ts: devEvent.created_at
            });
          }
        }
      }

      return {
        key: 'EPC',
        name: '提前卖出',
        status: na ? 'na' : (triggered ? 'triggered' : 'not_triggered'),
        score: maxScore,
        metrics: {},
        thresholds: { deviation_threshold: DEVIATION_THRESHOLD, hit_epsilon: HIT_EPSILON },
        summary_line: triggered 
          ? "本周存在非计划失效导致的提前卖出行为。"
          : "本周未发现明显的提前卖出偏离。",
        evidence
      };
    };

    const etnr = calculateETNR();
    const eldc = calculateELDC();
    const tnr = calculateTNR();
    const ldc = calculateLDC();
    const epc = calculateEPC();

    // --- 4.1 PCS (Plan Consistency Score) ---
    const calculatePCS = (): WeeklyMetric => {
      let score = 100;
      const deductions: Evidence[] = [];

      // 1. Field Integrity
      for (const p of plans) {
        if (!p.planned_entry_price) {
          score -= 2; // Simplified deduction
          deductions.push({ type: 'plan_field', id: p.id, title: '缺失预算价', detail: p.symbol_code, ts: p.created_at });
        }
        if (!p.target_high && !p.exit_plan_target_price) {
          score -= 2;
          deductions.push({ type: 'plan_field', id: p.id, title: '缺失卖出目标', detail: p.symbol_code, ts: p.created_at });
        }
        if (!p.stop_value) {
          score -= 2;
          deductions.push({ type: 'plan_field', id: p.id, title: '缺失止损价', detail: p.symbol_code, ts: p.created_at });
        }
      }

      // 2. Consistency Deductions
      if (etnr.status === 'triggered') score -= Math.min(20, (etnr.score || 0) * 0.2);
      if (ldc.status === 'triggered') score -= Math.min(30, (ldc.score || 0) * 0.3);
      if (tnr.status === 'triggered') score -= Math.min(20, (tnr.score || 0) * 0.2);
      if (epc.status === 'triggered') score -= Math.min(15, (epc.score || 0) * 0.15);

      // 3. Event Handling
      for (const e of events) {
        if (e.triggered_exit) {
          const result = results.find((r: any) => r.plan_id === e.plan_id);
          if (!result) {
            score -= 5;
            deductions.push({ type: 'event', id: e.id, title: '计划失效未卖出', detail: e.summary, ts: e.created_at });
          }
        }
      }

      score = Math.max(0, Math.round(score));

      return {
        key: 'PCS',
        name: '计划一致性',
        status: results.length > 0 ? 'triggered' : 'insufficient_data',
        score: score,
        metrics: {},
        thresholds: { deviation_threshold: DEVIATION_THRESHOLD, hit_epsilon: HIT_EPSILON },
        summary_line: `本周计划执行一致性评分为 ${score} 分。`,
        evidence: deductions.slice(0, 5)
      };
    };

    const pcs = calculatePCS();

    const metrics = [pcs, etnr, eldc, tnr, ldc, epc];
    
    // 5. Calm Conclusion
    const triggeredMetrics = metrics.filter(m => m.status === 'triggered' && m.key !== 'PCS');
    triggeredMetrics.sort((a, b) => (b.score || 0) - (a.score || 0));
    
    const dominant = triggeredMetrics.length > 0 ? triggeredMetrics[0] : null;
    let conclusion = "本周执行情况良好，未发现重大纪律偏离。";
    if (dominant) {
      conclusion = dominant.summary_line;
    }

    return ok({
      summary: {
        total_closed: results.length,
        dominant_label: dominant ? dominant.name : '无明显偏离',
        conclusion_text: conclusion,
      },
      metrics: metrics
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

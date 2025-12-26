PRAGMA foreign_keys = ON;

-- 用户（MVP：先用 X-User-Id 作为 user_id；可后续接鉴权）
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  plan_type TEXT NOT NULL DEFAULT 'free', -- free / pro / ultra
  created_at INTEGER NOT NULL DEFAULT (unixepoch())
);

-- 股票/行业基础表（MVP：先手动灌一点；或后续接第三方行情/券商数据）
CREATE TABLE IF NOT EXISTS symbols (
  id TEXT PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,    -- e.g. 000001.SZ / AAPL
  name TEXT NOT NULL,
  industry TEXT,                -- e.g. 储能/电网设备
  created_at INTEGER NOT NULL DEFAULT (unixepoch())
);

CREATE INDEX IF NOT EXISTS idx_symbols_code ON symbols(code);
CREATE INDEX IF NOT EXISTS idx_symbols_industry ON symbols(industry);

-- 关注列表（订阅限制：free=1, pro=3, ultra=无限）
CREATE TABLE IF NOT EXISTS watchlist (
  user_id TEXT NOT NULL,
  symbol_id TEXT NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (unixepoch()),
  PRIMARY KEY (user_id, symbol_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (symbol_id) REFERENCES symbols(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_watchlist_user ON watchlist(user_id);

-- users
CREATE TABLE IF NOT EXISTS app_users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  created_at INTEGER NOT NULL,
  last_login_at INTEGER
);

-- otp codes (短期有效)
CREATE TABLE IF NOT EXISTS login_otps (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL,
  code_hash TEXT NOT NULL,
  expires_at INTEGER NOT NULL,
  attempts INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_login_otps_email ON login_otps(email);

-- sessions (可用于拉黑、注销、设备管理)
CREATE TABLE IF NOT EXISTS user_sessions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  revoked INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL,
  last_seen_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_user_sessions_user ON user_sessions(user_id);

-- 交易计划（复盘核心）
-- 状态：draft(可编辑) / armed(锁定) / holding / closed
CREATE TABLE IF NOT EXISTS trade_plans (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  symbol_id TEXT NOT NULL,
  direction TEXT NOT NULL DEFAULT 'long', -- long/short（先保留）
  status TEXT NOT NULL DEFAULT 'draft',
  is_archived INTEGER NOT NULL DEFAULT 0,

  -- 买入理由
  buy_reason_types TEXT NOT NULL, -- JSON string: ["trend","policy",...]
  buy_reason_text TEXT NOT NULL,  -- 一句话理由（锁定后不可改）

  -- 目标
  target_type TEXT NOT NULL,      -- technical / previous_high / event / trend
  target_low REAL NOT NULL,
  target_high REAL NOT NULL,

  -- 卖出逻辑（触发条件）
  sell_conditions TEXT NOT NULL,  -- JSON string: ["reach_target","volume_exhaust",...]
  time_take_profit_days INTEGER,  -- 可空

  -- 止损
  stop_type TEXT NOT NULL,        -- technical / time / logic_fail / max_loss
  stop_value REAL,                -- 价格或百分比等（按你的前端定义）
  stop_time_days INTEGER,         -- 时间止损（可空）

  -- 执行辅助（MVP）
  entry_price REAL,               -- 兼容字段：旧数据或映射
  planned_entry_price REAL,       -- 计划买入价（草稿阶段）
  actual_entry_price REAL,        -- 实际成交均价（建仓后）
  entry_driver TEXT,              -- 建仓驱动因素（fomo, market_change等）
  exit_plan_target_price REAL,    -- 计划卖出目标价（EPC计算用）
  created_at INTEGER NOT NULL DEFAULT (unixepoch()),
  updated_at INTEGER NOT NULL DEFAULT (unixepoch())
);

CREATE INDEX IF NOT EXISTS idx_plans_user_status ON trade_plans(user_id, status);
CREATE INDEX IF NOT EXISTS idx_plans_symbol ON trade_plans(symbol_id);
CREATE INDEX IF NOT EXISTS idx_plans_user_archived_updated ON trade_plans(user_id, is_archived, updated_at);


-- 计划修订记录：armed 后任何变更都记录
CREATE TABLE IF NOT EXISTS plan_edits (
  id TEXT PRIMARY KEY,
  plan_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  field TEXT NOT NULL,
  old_value TEXT,
  new_value TEXT,
  edited_at INTEGER NOT NULL DEFAULT (unixepoch()),
  FOREIGN KEY (plan_id) REFERENCES trade_plans(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_edits_plan ON plan_edits(plan_id);

-- 复盘专用事件线（4类）
CREATE TABLE IF NOT EXISTS trade_events (
  id TEXT PRIMARY KEY,
  plan_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  event_type TEXT NOT NULL,       -- falsify / forced / verify / structure
  event_stage TEXT,               -- entry_deviation / entry_non_action / exit_non_action / exit_deviation / stoploss_deviation / external_change
  behavior_driver TEXT,           -- fomo, fear, wait_failed, etc.
  price_at_event REAL,            -- 发生时的价格
  summary TEXT NOT NULL,          -- ≤40字
  impact_target TEXT NOT NULL,    -- buy_logic / hold / sell_logic / stop_loss
  triggered_exit INTEGER NOT NULL DEFAULT 0, -- 0/1 (是否触发退出条件)
  created_at INTEGER NOT NULL DEFAULT (unixepoch()),
  FOREIGN KEY (plan_id) REFERENCES trade_plans(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_events_plan ON trade_events(plan_id);

-- 卖出与系统判定（结果表）
CREATE TABLE IF NOT EXISTS trade_results (
  plan_id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  sell_price REAL NOT NULL,
  sell_reason TEXT NOT NULL,        -- JSON string or enum
  system_judgement TEXT NOT NULL,   -- no_plan / follow_plan / exec_error / judge_error / emotion_override
  conclusion_text TEXT NOT NULL,
  post_exit_best_price REAL,      -- 卖出后观察期内最优价格
  epc_opportunity_pct REAL,       -- EPC 成本百分比
  closed_at INTEGER NOT NULL DEFAULT (unixepoch()),
  FOREIGN KEY (plan_id) REFERENCES trade_plans(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_results_user_closed ON trade_results(user_id, closed_at);

-- 交易多维度自我评估（Step 7）
CREATE TABLE IF NOT EXISTS trade_self_reviews (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  plan_id TEXT NOT NULL,
  result_id TEXT NOT NULL,

  -- 13 个维度 (1/2/3)
  d1 INTEGER NOT NULL, d2 INTEGER NOT NULL, d3 INTEGER NOT NULL, d4 INTEGER NOT NULL,
  h1 INTEGER NOT NULL, h2 INTEGER NOT NULL, h3 INTEGER NOT NULL, h4 INTEGER NOT NULL,
  e1 INTEGER NOT NULL, e2 INTEGER NOT NULL, e3 INTEGER NOT NULL,
  r1 INTEGER NOT NULL, r2 INTEGER NOT NULL,

  schema_version INTEGER NOT NULL DEFAULT 1,
  created_at INTEGER NOT NULL,

  UNIQUE(user_id, plan_id),
  FOREIGN KEY (plan_id) REFERENCES trade_plans(id) ON DELETE CASCADE,
  FOREIGN KEY (result_id) REFERENCES trade_results(plan_id) ON DELETE CASCADE
);


-- 异动提示表（不自动生成 trade_events，只做提示）
CREATE TABLE IF NOT EXISTS anomaly_hints (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  plan_id TEXT NOT NULL,
  symbol TEXT NOT NULL,
  hint_type TEXT NOT NULL,         -- 'price_trigger' | 'evidence_gap' | 'deviation_hint' | 'plan_prompt'
  trigger_tag TEXT,                -- 'EPC'|'LDC'|'TNR'|'E-TNR'|'E-LDC' (price_trigger 使用；其他可空)
  event_stage TEXT,                -- 建议预填：exit_non_action / stoploss_deviation 等（可空）
  ref_event_id TEXT,               -- 关联到某条 trade_event（可空）
  price REAL,                      -- 触发时价格（可空）
  payload_json TEXT,               -- 扩展信息：阈值、目标区间、缺失项等（可空）
  status TEXT NOT NULL DEFAULT 'open',  -- 'open' | 'consumed' | 'dismissed'
  created_at INTEGER NOT NULL,
  consumed_at INTEGER
);

CREATE INDEX IF NOT EXISTS idx_hints_user_status_created ON anomaly_hints(user_id, status, created_at DESC);

CREATE TABLE IF NOT EXISTS price_cache (
  symbol TEXT PRIMARY KEY,
  price REAL NOT NULL,
  updated_at INTEGER NOT NULL
);



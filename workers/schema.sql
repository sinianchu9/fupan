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

-- 交易计划（复盘核心）
-- 状态：draft(可编辑) / armed(锁定) / holding / closed
CREATE TABLE IF NOT EXISTS trade_plans (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  symbol_id TEXT NOT NULL,
  direction TEXT NOT NULL DEFAULT 'long', -- long/short（先保留）
  status TEXT NOT NULL DEFAULT 'draft',

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
  entry_price REAL,               -- 可空：买入均价
  created_at INTEGER NOT NULL DEFAULT (unixepoch()),
  updated_at INTEGER NOT NULL DEFAULT (unixepoch())
);

CREATE INDEX IF NOT EXISTS idx_plans_user_status ON trade_plans(user_id, status);
CREATE INDEX IF NOT EXISTS idx_plans_symbol ON trade_plans(symbol_id);

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
  summary TEXT NOT NULL,          -- ≤40字
  impact_target TEXT NOT NULL,    -- buy_logic / sell_logic / stop_loss
  triggered_exit INTEGER NOT NULL DEFAULT 0, -- 0/1
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
  closed_at INTEGER NOT NULL DEFAULT (unixepoch()),
  FOREIGN KEY (plan_id) REFERENCES trade_plans(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_results_user_closed ON trade_results(user_id, closed_at);

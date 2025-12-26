-- Anomaly Module Tables

CREATE TABLE IF NOT EXISTS anomaly_hints (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  plan_id TEXT NOT NULL,
  symbol TEXT NOT NULL,
  hint_type TEXT NOT NULL,
  trigger_tag TEXT,
  event_stage TEXT,
  ref_event_id TEXT,
  price REAL,
  payload_json TEXT,
  status TEXT NOT NULL DEFAULT 'open',
  created_at INTEGER NOT NULL,
  consumed_at INTEGER
);

CREATE INDEX IF NOT EXISTS idx_hints_user_status_created ON anomaly_hints(user_id, status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_hints_plan_status_created ON anomaly_hints(plan_id, status, created_at DESC);

CREATE TABLE IF NOT EXISTS price_cache (
  symbol TEXT PRIMARY KEY,
  price REAL NOT NULL,
  updated_at INTEGER NOT NULL
);

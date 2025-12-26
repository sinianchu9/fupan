-- Add new columns to trade_events
ALTER TABLE trade_events ADD COLUMN event_stage TEXT;
ALTER TABLE trade_events ADD COLUMN behavior_driver TEXT;
ALTER TABLE trade_events ADD COLUMN price_at_event REAL;

-- Migrate existing data (optional, but good practice)
-- Since event_type and event_stage are related, we can do some mapping if needed.
-- For now, we'll leave them as NULL or set a default.
UPDATE trade_events SET event_stage = 'external_change' WHERE event_stage IS NULL;

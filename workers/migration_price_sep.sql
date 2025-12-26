ALTER TABLE trade_plans ADD COLUMN planned_entry_price REAL;
ALTER TABLE trade_plans ADD COLUMN actual_entry_price REAL;

UPDATE trade_plans SET planned_entry_price = entry_price WHERE status = 'draft';
UPDATE trade_plans SET actual_entry_price = entry_price WHERE status != 'draft';

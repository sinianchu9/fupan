-- Migration: Add EPC related columns
ALTER TABLE trade_plans ADD COLUMN exit_plan_target_price REAL;
ALTER TABLE trade_results ADD COLUMN post_exit_best_price REAL;
ALTER TABLE trade_results ADD COLUMN epc_opportunity_pct REAL;

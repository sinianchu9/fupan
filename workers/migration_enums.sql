-- Harmonize event_type enums
UPDATE trade_events SET event_type = 'falsify' WHERE event_type = 'logic_broken';
UPDATE trade_events SET event_type = 'structure' WHERE event_type = 'structure_change';

-- Harmonize impact_target enums
UPDATE trade_events SET impact_target = 'buy_logic' WHERE impact_target = 'buy';
UPDATE trade_events SET impact_target = 'sell_logic' WHERE impact_target = 'sell';
UPDATE trade_events SET impact_target = 'stop_loss' WHERE impact_target = 'stop';

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title_journal => 'Trading Journal';

  @override
  String get title_plan_detail => 'Plan Detail';

  @override
  String get title_self_assessment => 'Self Assessment';

  @override
  String get title_weekly_report => 'Weekly Discipline Report';

  @override
  String get title_create_plan => 'New Trade Plan';

  @override
  String get title_archived_plans => 'Archived Plans';

  @override
  String get title_login => 'Login';

  @override
  String get status_draft => 'Draft';

  @override
  String get status_armed => 'Armed';

  @override
  String get status_holding => 'Holding';

  @override
  String get status_closed => 'Closed';

  @override
  String get status_archived => 'Archived';

  @override
  String get action_create_plan => 'New Plan';

  @override
  String get action_submit => 'Submit Assessment';

  @override
  String get action_arm => 'Arm Plan';

  @override
  String get action_close_trade => 'Close Trade';

  @override
  String get action_self_assessment => 'Self Assessment';

  @override
  String get action_archive => 'Archive';

  @override
  String get action_unarchive => 'Unarchive';

  @override
  String get action_refresh => 'Refresh';

  @override
  String get action_view_detail => 'View Details';

  @override
  String get action_hide_details => 'Hide Details';

  @override
  String get action_back => 'Back';

  @override
  String get action_confirm => 'Confirm';

  @override
  String get action_add => 'Add';

  @override
  String get action_switch_language => 'Switch Language';

  @override
  String get tip_required => 'Required';

  @override
  String get label_language_zh => '简体中文';

  @override
  String get label_language_en => 'English';

  @override
  String get label_discipline_score => 'Weekly Discipline Score';

  @override
  String get label_symbol => 'Symbol';

  @override
  String get label_industry => 'Industry';

  @override
  String get label_updated_at => 'Updated At';

  @override
  String get label_pcs_score => '1️⃣ Plan Consistency Score (PCS)';

  @override
  String get label_main_deviation => '2️⃣ Main Deviation Type';

  @override
  String get label_conclusion => '3️⃣ Calm Conclusion';

  @override
  String get label_tnr_ldc => '4️⃣ TNR / LDC';

  @override
  String label_completed_count(int count) {
    return 'Completed $count/13';
  }

  @override
  String get tip_no_plans => 'No trading plans yet';

  @override
  String get tip_no_plans_sub =>
      'Plan first, trade later to strengthen discipline';

  @override
  String get tip_no_trades => 'No trading records this week';

  @override
  String tip_fetch_failed(String error) {
    return 'Failed to fetch data: $error';
  }

  @override
  String get tip_submit_success => 'Assessment submitted successfully';

  @override
  String tip_submit_failed(String error) {
    return 'Submission failed: $error';
  }

  @override
  String get tip_complete_all => 'Please complete all dimensions';

  @override
  String get label_buy_reason => 'Buy Reason';

  @override
  String get label_reason_type => 'Reason Type';

  @override
  String get label_target_range => 'Target Range';

  @override
  String get label_sell_logic => 'Sell Logic';

  @override
  String get label_time_take_profit => 'Time Take Profit';

  @override
  String get label_stop_logic => 'Stop Logic';

  @override
  String get label_entry_price => 'Entry Price';

  @override
  String get label_edit_history => 'Edit History';

  @override
  String get label_close_price => 'Close Price';

  @override
  String get label_close_reason => 'Close Reason';

  @override
  String get hint_close_price => 'Enter close price';

  @override
  String get hint_close_reason => 'Briefly describe close logic';

  @override
  String get label_create => 'Create';

  @override
  String get label_update => 'Update';

  @override
  String get label_original_plan => 'Original Plan (Locked)';

  @override
  String get deviation_no_plan => 'No Plan Trade';

  @override
  String get deviation_emotion_override => 'Emotion Override';

  @override
  String get deviation_forced => 'Forced Disturbance';

  @override
  String get deviation_none => 'No Deviation';

  @override
  String get deviation_no_trades => 'No Trades';

  @override
  String get label_no_trades => 'No Trades';

  @override
  String get label_none => 'None';

  @override
  String get label_not_applicable => 'N/A';

  @override
  String get action_save_draft => 'Save Draft';

  @override
  String get label_symbol_selection => 'Symbol Selection';

  @override
  String get label_buy_reason_one_liner => 'One-liner Reason';

  @override
  String get hint_buy_reason_one_liner => 'In plain words (max 50 chars)';

  @override
  String get label_target_sell_price => 'Expected Sell Target';

  @override
  String get label_target_low => 'Target Low';

  @override
  String get label_target_high => 'Target High';

  @override
  String get label_sell_logic_expected => 'Expected Sell Logic';

  @override
  String get label_time_take_profit_days => 'Time Take Profit Days';

  @override
  String get label_stop_loss_logic => 'Stop Loss Logic';

  @override
  String get label_stop_price => 'Stop Price';

  @override
  String get label_stop_days => 'Stop Days';

  @override
  String get label_max_loss_percent => 'Max Loss (%)';

  @override
  String get hint_max_loss => 'e.g. 5 means 5%';

  @override
  String get label_advanced_options => 'Advanced Options';

  @override
  String get label_expected_entry_price => 'Expected Entry Price (Optional)';

  @override
  String get label_trade_direction => 'Trade Direction';

  @override
  String get label_long => 'Long';

  @override
  String get label_short => 'Short';

  @override
  String get tip_select_buy_reason =>
      'Please select at least one buy reason type';

  @override
  String get tip_select_sell_logic => 'Please select at least one sell logic';

  @override
  String get tip_watchlist_empty =>
      'Watchlist is empty, please add symbols first';

  @override
  String get tip_greater_than_low => 'Must be greater than low';

  @override
  String get tip_greater_than_zero => 'Must be >= 1';

  @override
  String get tip_invalid_loss_percent => 'Please enter 1~100';

  @override
  String get tip_invalid_price => 'Please enter a valid close price';

  @override
  String get reason_trend => 'Trend';

  @override
  String get reason_range => 'Range';

  @override
  String get reason_policy => 'Policy';

  @override
  String get reason_industry => 'Industry';

  @override
  String get reason_earnings => 'Earnings';

  @override
  String get reason_sentiment => 'Sentiment';

  @override
  String get reason_probe => 'Probe';

  @override
  String get reason_other => 'Other';

  @override
  String get target_technical => 'Technical';

  @override
  String get target_previous_high => 'Prev High';

  @override
  String get target_event => 'Event';

  @override
  String get target_trend => 'Trend';

  @override
  String get logic_reach_target => 'Reach Target';

  @override
  String get logic_volume_exhaust => 'Vol Exhaust';

  @override
  String get logic_trend_break => 'Trend Break';

  @override
  String get logic_thesis_invalidated => 'Thesis Invalid';

  @override
  String get logic_time_take_profit => 'Time TP';

  @override
  String get stop_technical => 'Technical';

  @override
  String get stop_time => 'Time';

  @override
  String get stop_logic_fail => 'Logic Fail';

  @override
  String get stop_max_loss => 'Max Loss';

  @override
  String get label_welcome_back => 'Welcome Back';

  @override
  String get tip_enter_email => 'Enter your email to get verification code';

  @override
  String get label_email => 'Email';

  @override
  String get hint_email => 'Enter your email address';

  @override
  String get action_send_otp => 'Send Code';

  @override
  String get tip_invalid_email => 'Please enter a valid email address';

  @override
  String get tip_send_otp_failed => 'Failed to send code, please try again';

  @override
  String get title_verify_otp => 'Verification';

  @override
  String tip_otp_sent_to(Object email) {
    return 'Verification code sent to $email';
  }

  @override
  String get label_otp => 'Verification Code';

  @override
  String get action_verify => 'Verify';

  @override
  String get tip_invalid_otp => 'Please enter 6-digit code';

  @override
  String get tip_verify_failed => 'Verification failed, please check the code';

  @override
  String get action_back_to_edit_email => 'Back to edit email';

  @override
  String get label_all_statuses => 'All Statuses';

  @override
  String get tip_no_archived_plans => 'No archived plans';

  @override
  String get tip_unarchived_success => 'Unarchived successfully';

  @override
  String label_target_range_with_values(Object high, Object low) {
    return 'Target: $low ~ $high';
  }

  @override
  String label_direction_with_value(Object direction) {
    return 'Direction: $direction';
  }

  @override
  String get title_manage_watchlist => 'Manage Watchlist';

  @override
  String get title_select_watchlist => 'Select Your Watchlist';

  @override
  String get tip_add_at_least_one =>
      'Please add at least 1 stock to get started';

  @override
  String get hint_search_symbol => 'Enter code/name/industry';

  @override
  String get label_all_industries => 'All Industries';

  @override
  String get tip_symbol_not_found => 'No matching stocks found';

  @override
  String get action_seed_data => 'Seed Test Data';

  @override
  String tip_added_symbol(Object name) {
    return 'Added $name';
  }

  @override
  String get label_added => 'Added';

  @override
  String get action_enter_app => 'Enter App';

  @override
  String get title_subscription_limit => 'Subscription Limit';

  @override
  String get tip_subscription_limit_msg =>
      'Free version can only add 1 stock. Please upgrade to unlock more slots.';

  @override
  String get action_learn_more_upgrade => 'Learn More & Upgrade';

  @override
  String get tip_seed_success =>
      'Test data seeded successfully, please search again';

  @override
  String tip_seed_failed(Object error) {
    return 'Seed failed: $error\nPlease ensure you have run npx wrangler d1 execute ... to initialize the database';
  }

  @override
  String get label_nav_journal => 'Journal';

  @override
  String get label_nav_alerts => 'Alerts';

  @override
  String get label_nav_stats => 'Stats';

  @override
  String get tip_alerts_placeholder => 'Alerts (Step 4 Implementation)';

  @override
  String get tip_plan_locked =>
      'Plan locked; subsequent adjustments will be saved as \'Revision Records\'.';

  @override
  String get action_revise_target => 'Revise Target Range';

  @override
  String get title_revise_target => 'Revise Target Range';

  @override
  String get label_event_timeline => 'Event Timeline';

  @override
  String get action_add_event => 'Add Event';

  @override
  String get label_comparison_status => 'Comparison Status';

  @override
  String get label_fact_only => 'Facts only, no advice provided';

  @override
  String get label_defined => 'Defined';

  @override
  String get label_undefined => 'Undefined';

  @override
  String get label_exit_trigger_event => 'Exit Trigger Event';

  @override
  String label_yes_with_count(int count) {
    return 'Yes ($count)';
  }

  @override
  String tip_exit_event_recorded(int count) {
    return '$count events recorded as \'Trigger Exit Condition\'. Please select a reason when selling and complete the comparison review.';
  }

  @override
  String label_time_take_profit_condition(int days) {
    return '• Time Take Profit: $days days (from plan creation)';
  }

  @override
  String get title_calm_conclusion => 'Calm Conclusion';

  @override
  String get label_entry_deviation => 'Entry Deviation';

  @override
  String get label_entry_driver => 'Entry Driver (Optional)';

  @override
  String get label_no_deviation =>
      'This entry strictly followed the original plan price.';

  @override
  String label_deviation_fact(Object direction, Object percent) {
    return 'In this trade, the actual entry price moved $direction by $percent% from the original budget.';
  }

  @override
  String label_driver_fact(Object driver) {
    return 'The main driver recorded at entry was: $driver';
  }

  @override
  String get label_plan_vs_actual => 'Original Plan vs Actual Execution';

  @override
  String get label_planned_range => 'Original Planned Range';

  @override
  String get label_actual_price => 'Actual Entry Price';

  @override
  String get label_deviation_direction => 'Deviation Direction';

  @override
  String get label_direction_up => 'Upward';

  @override
  String get label_direction_down => 'Downward';

  @override
  String get label_direction_none => 'No Deviation';

  @override
  String get label_result_correlation => 'Result Correlation';

  @override
  String get label_loss_with_deviation =>
      'This was a losing trade with entry deviation.';

  @override
  String get label_profit_with_deviation =>
      'This was a profitable trade but with entry deviation.';

  @override
  String get label_loss_no_deviation =>
      'This was a losing trade, execution consistent with plan.';

  @override
  String get label_profit_no_deviation =>
      'This was a profitable trade, execution consistent with plan.';

  @override
  String get label_calm_summary_deviation =>
      'In this trade, plan and execution deviated. It is recommended to monitor the recurrence frequency of such scenarios in subsequent reviews.';

  @override
  String get label_calm_summary_no_deviation =>
      'The execution process of this trade was consistent with the original plan.';

  @override
  String get driver_fomo => 'Fear Of Missing Out (FOMO)';

  @override
  String get driver_plan_weakened => 'Plan logic weakened';

  @override
  String get driver_market_change => 'Sudden market environment change';

  @override
  String get driver_wait_failed => 'Patience exhausted while waiting';

  @override
  String get driver_emotion => 'Emotional fluctuations';

  @override
  String get driver_other => 'Other';

  @override
  String get badge_deviation => 'Entry Deviation';

  @override
  String get badge_no_deviation => 'Followed Plan';

  @override
  String get label_event_stage => 'Event Stage';

  @override
  String get label_behavior_driver => 'Behavior Driver';

  @override
  String get label_price_at_event => 'Price at Event';

  @override
  String get stage_entry_deviation => 'Entry Execution Deviation';

  @override
  String get stage_entry_non_action => 'Low Entry Not Executed';

  @override
  String get stage_exit_deviation => 'Exit Execution Deviation';

  @override
  String get stage_exit_non_action => 'Target Reached Not Executed';

  @override
  String get stage_stoploss_deviation => 'Stop Loss Execution Deviation';

  @override
  String get stage_external_change => 'External Environment Change';

  @override
  String get label_epc => 'EPC';

  @override
  String label_epc_fact(String pct) {
    return 'After selling early, the price continued to move in the original target direction, forming an Early Profit Cut (EPC) opportunity cost of approximately $pct%.';
  }

  @override
  String get label_exit_triggered_by_event =>
      'This exit was triggered by a plan invalidation event and is not counted as an early sell cost.';

  @override
  String get label_epc_summary =>
      'In this trade, the exit behavior deviated from the original plan target. This type of scenario can be monitored for recurrence in future reviews.';

  @override
  String get driver_early_profit => 'Take profit early to reduce uncertainty';

  @override
  String get driver_fear_drawdown => 'Cannot tolerate drawdown';

  @override
  String get driver_emotion_fear => 'Emotional selling (fear/hesitation)';

  @override
  String get driver_lower_target => 'Temporarily lowered target';

  @override
  String get driver_fomo_short => 'Chasing high (FOMO)';

  @override
  String get driver_fear => 'Panic (Fear)';

  @override
  String get driver_wait_failed_short => 'Patience exhausted';

  @override
  String get driver_logic_broken => 'Logic broken';

  @override
  String get driver_market_crash => 'Market crash';

  @override
  String get driver_profit_protect => 'Profit protection';

  @override
  String get driver_revenge => 'Revenge trading';

  @override
  String get driver_other_short => 'Other';

  @override
  String get label_missed_price => 'Missed Price';

  @override
  String get label_deviation_price => 'Deviation Price';

  @override
  String get label_etnr => 'E-TNR (Chasing)';

  @override
  String get label_eldc => 'E-LDC (Low Entry Missed)';

  @override
  String get label_tnr => 'TNR (Target Not Sold)';

  @override
  String get label_ldc => 'LDC (Stop Loss Delay)';

  @override
  String get title_add_event => 'Add Event';

  @override
  String get label_event_summary => '事件摘要';

  @override
  String get label_triggered_exit => '触发退出条件';

  @override
  String get btn_submit_event => '提交事件';

  @override
  String get label_plan_consistency_desc => '计划一致性';

  @override
  String get label_etnr_desc => '买入追高';

  @override
  String get label_eldc_desc => '低位不执行';

  @override
  String get label_tnr_desc => '到位不卖';

  @override
  String get label_ldc_desc => '止损拖延';

  @override
  String get label_epc_desc => '提前卖出';

  @override
  String get tip_entry_deviation_hint => '检测到建仓价格偏离，请记录驱动因素';

  @override
  String get label_audit_metrics => '核心纪律指标';

  @override
  String get label_evidence_chain => '证据链 (Evidence Chain)';

  @override
  String get label_improvement_tips => '本周改进提示';

  @override
  String get label_quantitative_results => '量化结果';

  @override
  String get label_weekly_conclusion => '本周结论';

  @override
  String get label_deviation_score => 'Deviation Score';

  @override
  String get label_deviation_magnitude => 'Deviation Magnitude';

  @override
  String get label_trigger_threshold => 'Trigger Threshold';

  @override
  String get tip_score_explanation =>
      'Note: Score represents deviation intensity, not quality. Higher score means greater deviation from plan.';

  @override
  String get tip_no_evidence => 'No direct evidence yet';

  @override
  String get status_triggered => 'Triggered';

  @override
  String get status_not_triggered => 'Not Triggered';

  @override
  String get status_na => 'N/A';

  @override
  String get status_insufficient_data => 'Insufficient Data';

  @override
  String label_evidence_count(int count) {
    return '$count Evidence';
  }

  @override
  String get label_event_type => 'Event Type';

  @override
  String get label_impact_target => 'Impact Target';

  @override
  String get type_logic_broken => 'Logic Broken';

  @override
  String get type_forced => 'Forced Disturbance';

  @override
  String get type_verify => 'Verification';

  @override
  String get type_structure_change => 'Structure Change';

  @override
  String get target_buy => 'Entry';

  @override
  String get target_hold => 'Hold/Add';

  @override
  String get target_sell => 'Exit';

  @override
  String get target_stop => 'Stop Loss';

  @override
  String get hint_summary_fact_only =>
      'Facts only, no explanation (max 40 chars)';

  @override
  String get label_event_explain =>
      'Record factual evidence that affects whether the plan remains valid.';

  @override
  String get label_event_stage_prompt => 'This deviation occurred at:';

  @override
  String get label_adjust_explanation => 'Adjust Explanation (Optional)';

  @override
  String get label_system_understanding => 'System Understanding';

  @override
  String get label_triggered_exit_hint =>
      'Check means: This event has made the original plan no longer valid, and an exit needs to be executed.';

  @override
  String get hint_fact_summary =>
      'Write only what facts happened, not reasons or predictions (max 40 chars).';

  @override
  String get understanding_etnr =>
      'System Understanding: The actual entry price deviated from the planned price (corresponds to E-TNR).';

  @override
  String get understanding_eldc =>
      'System Understanding: A buying opportunity appeared, but the buy was not executed as planned (corresponds to E-LDC).';

  @override
  String get understanding_tnr =>
      'System Understanding: Plan conditions have been verified, but the sell was not executed (corresponds to TNR).';

  @override
  String get understanding_ldc =>
      'System Understanding: Stop loss conditions were reached, but the stop loss was not executed as planned (corresponds to LDC).';

  @override
  String get understanding_epc =>
      'System Understanding: The plan target was not reached, and the sell was executed early (corresponds to EPC).';

  @override
  String get driver_wait_confirm => 'Waiting for confirmation';

  @override
  String get driver_loosen_budget => 'Loosening budget range';

  @override
  String get driver_emotion_swing => 'Emotional swing';

  @override
  String get driver_fear_continue_drop => 'Fear of continued drop';

  @override
  String get driver_signal_insufficient => 'Insufficient signal';

  @override
  String get driver_full_position => 'Full position';

  @override
  String get driver_no_cash => 'No cash';

  @override
  String get driver_no_plan => 'No plan at the time';

  @override
  String get driver_hold_at_target => 'Still want to hold at target';

  @override
  String get driver_raise_target => 'Temporarily raised target';

  @override
  String get driver_greed_hesitation => 'Greed and hesitation';

  @override
  String get driver_resist_stop => 'Psychological resistance to stop';

  @override
  String get driver_hope_rebound => 'Hope for rebound';

  @override
  String get driver_lower_stop => 'Lowered stop loss';

  @override
  String get driver_emotion_ignore => 'Emotionally ignoring risk';

  @override
  String get type_logic_broken_hint => 'Original plan no longer holds';

  @override
  String get type_forced_hint => 'External reason interrupted plan';

  @override
  String get type_verify_hint => 'Plan conditions reached';

  @override
  String get type_structure_change_hint => 'Original premise changed';

  @override
  String get subtitle_fact_only => 'Facts only, no advice';

  @override
  String get judgement_follow_plan => 'Follow Plan';

  @override
  String get judgement_emotion_override => 'Emotion Override';

  @override
  String get action_expand => 'Expand';

  @override
  String label_associated_event(String stage, String price) {
    return 'Associated Event: $stage ($price)';
  }

  @override
  String get title_plan_integrity => 'Plan Integrity (Locked Content)';

  @override
  String get subtitle_plan_integrity =>
      'Indicates plan completeness, not execution status';

  @override
  String get label_locked => 'Locked';

  @override
  String get label_not_settled => 'Not settled, no judgment yet';
}

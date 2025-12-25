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
}

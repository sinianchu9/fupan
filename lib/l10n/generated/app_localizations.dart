import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @title_journal.
  ///
  /// In zh, this message translates to:
  /// **'交易复盘'**
  String get title_journal;

  /// No description provided for @title_plan_detail.
  ///
  /// In zh, this message translates to:
  /// **'计划详情'**
  String get title_plan_detail;

  /// No description provided for @title_self_assessment.
  ///
  /// In zh, this message translates to:
  /// **'自我评估'**
  String get title_self_assessment;

  /// No description provided for @title_weekly_report.
  ///
  /// In zh, this message translates to:
  /// **'本周纪律周报'**
  String get title_weekly_report;

  /// No description provided for @title_create_plan.
  ///
  /// In zh, this message translates to:
  /// **'新建交易计划'**
  String get title_create_plan;

  /// No description provided for @title_archived_plans.
  ///
  /// In zh, this message translates to:
  /// **'已归档计划'**
  String get title_archived_plans;

  /// No description provided for @title_login.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get title_login;

  /// No description provided for @status_draft.
  ///
  /// In zh, this message translates to:
  /// **'预建仓'**
  String get status_draft;

  /// No description provided for @status_armed.
  ///
  /// In zh, this message translates to:
  /// **'已建仓'**
  String get status_armed;

  /// No description provided for @status_holding.
  ///
  /// In zh, this message translates to:
  /// **'持仓'**
  String get status_holding;

  /// No description provided for @status_closed.
  ///
  /// In zh, this message translates to:
  /// **'平仓'**
  String get status_closed;

  /// No description provided for @status_archived.
  ///
  /// In zh, this message translates to:
  /// **'已归档'**
  String get status_archived;

  /// No description provided for @action_create_plan.
  ///
  /// In zh, this message translates to:
  /// **'新建计划'**
  String get action_create_plan;

  /// No description provided for @action_submit.
  ///
  /// In zh, this message translates to:
  /// **'提交评估'**
  String get action_submit;

  /// No description provided for @action_arm.
  ///
  /// In zh, this message translates to:
  /// **'建仓'**
  String get action_arm;

  /// No description provided for @action_close_trade.
  ///
  /// In zh, this message translates to:
  /// **'平仓结案'**
  String get action_close_trade;

  /// No description provided for @action_self_assessment.
  ///
  /// In zh, this message translates to:
  /// **'自我评估'**
  String get action_self_assessment;

  /// No description provided for @action_archive.
  ///
  /// In zh, this message translates to:
  /// **'归档'**
  String get action_archive;

  /// No description provided for @action_unarchive.
  ///
  /// In zh, this message translates to:
  /// **'取消归档'**
  String get action_unarchive;

  /// No description provided for @action_refresh.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get action_refresh;

  /// No description provided for @action_view_detail.
  ///
  /// In zh, this message translates to:
  /// **'查看详情'**
  String get action_view_detail;

  /// No description provided for @action_hide_details.
  ///
  /// In zh, this message translates to:
  /// **'收起细则'**
  String get action_hide_details;

  /// No description provided for @action_back.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get action_back;

  /// No description provided for @action_confirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get action_confirm;

  /// No description provided for @action_add.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get action_add;

  /// No description provided for @action_switch_language.
  ///
  /// In zh, this message translates to:
  /// **'切换语言'**
  String get action_switch_language;

  /// No description provided for @tip_required.
  ///
  /// In zh, this message translates to:
  /// **'必填'**
  String get tip_required;

  /// No description provided for @label_language_zh.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get label_language_zh;

  /// No description provided for @label_language_en.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get label_language_en;

  /// No description provided for @label_discipline_score.
  ///
  /// In zh, this message translates to:
  /// **'本周纪律得分'**
  String get label_discipline_score;

  /// No description provided for @label_symbol.
  ///
  /// In zh, this message translates to:
  /// **'标的'**
  String get label_symbol;

  /// No description provided for @label_industry.
  ///
  /// In zh, this message translates to:
  /// **'行业'**
  String get label_industry;

  /// No description provided for @label_updated_at.
  ///
  /// In zh, this message translates to:
  /// **'更新时间'**
  String get label_updated_at;

  /// No description provided for @label_pcs_score.
  ///
  /// In zh, this message translates to:
  /// **'1️⃣ 计划一致性得分 (PCS)'**
  String get label_pcs_score;

  /// No description provided for @label_main_deviation.
  ///
  /// In zh, this message translates to:
  /// **'2️⃣ 本周主要偏离类型'**
  String get label_main_deviation;

  /// No description provided for @label_conclusion.
  ///
  /// In zh, this message translates to:
  /// **'3️⃣ 冷静结论'**
  String get label_conclusion;

  /// No description provided for @label_tnr_ldc.
  ///
  /// In zh, this message translates to:
  /// **'4️⃣ TNR / LDC'**
  String get label_tnr_ldc;

  /// No description provided for @label_completed_count.
  ///
  /// In zh, this message translates to:
  /// **'已完成 {count}/13'**
  String label_completed_count(int count);

  /// No description provided for @tip_no_plans.
  ///
  /// In zh, this message translates to:
  /// **'还没有交易计划'**
  String get tip_no_plans;

  /// No description provided for @tip_no_plans_sub.
  ///
  /// In zh, this message translates to:
  /// **'先写计划再交易，强化交易纪律'**
  String get tip_no_plans_sub;

  /// No description provided for @tip_no_trades.
  ///
  /// In zh, this message translates to:
  /// **'本周无交易记录'**
  String get tip_no_trades;

  /// No description provided for @tip_fetch_failed.
  ///
  /// In zh, this message translates to:
  /// **'获取数据失败: {error}'**
  String tip_fetch_failed(String error);

  /// No description provided for @tip_submit_success.
  ///
  /// In zh, this message translates to:
  /// **'评估提交成功'**
  String get tip_submit_success;

  /// No description provided for @tip_submit_failed.
  ///
  /// In zh, this message translates to:
  /// **'提交失败: {error}'**
  String tip_submit_failed(String error);

  /// No description provided for @tip_complete_all.
  ///
  /// In zh, this message translates to:
  /// **'请完成所有维度的评估'**
  String get tip_complete_all;

  /// No description provided for @label_buy_reason.
  ///
  /// In zh, this message translates to:
  /// **'买入理由'**
  String get label_buy_reason;

  /// No description provided for @label_reason_type.
  ///
  /// In zh, this message translates to:
  /// **'理由类型'**
  String get label_reason_type;

  /// No description provided for @label_target_range.
  ///
  /// In zh, this message translates to:
  /// **'目标区间'**
  String get label_target_range;

  /// No description provided for @label_sell_logic.
  ///
  /// In zh, this message translates to:
  /// **'卖出逻辑'**
  String get label_sell_logic;

  /// No description provided for @label_time_take_profit.
  ///
  /// In zh, this message translates to:
  /// **'时间止盈'**
  String get label_time_take_profit;

  /// No description provided for @label_stop_logic.
  ///
  /// In zh, this message translates to:
  /// **'止损逻辑'**
  String get label_stop_logic;

  /// No description provided for @label_entry_price.
  ///
  /// In zh, this message translates to:
  /// **'预期买入价'**
  String get label_entry_price;

  /// No description provided for @label_edit_history.
  ///
  /// In zh, this message translates to:
  /// **'修订记录'**
  String get label_edit_history;

  /// No description provided for @label_close_price.
  ///
  /// In zh, this message translates to:
  /// **'成交均价'**
  String get label_close_price;

  /// No description provided for @label_close_reason.
  ///
  /// In zh, this message translates to:
  /// **'平仓理由'**
  String get label_close_reason;

  /// No description provided for @hint_close_price.
  ///
  /// In zh, this message translates to:
  /// **'输入平仓成交均价'**
  String get hint_close_price;

  /// No description provided for @hint_close_reason.
  ///
  /// In zh, this message translates to:
  /// **'简述平仓逻辑（如：触及止盈、逻辑走坏等）'**
  String get hint_close_reason;

  /// No description provided for @label_create.
  ///
  /// In zh, this message translates to:
  /// **'创建'**
  String get label_create;

  /// No description provided for @label_update.
  ///
  /// In zh, this message translates to:
  /// **'更新'**
  String get label_update;

  /// No description provided for @label_original_plan.
  ///
  /// In zh, this message translates to:
  /// **'原始计划 (锁定内容)'**
  String get label_original_plan;

  /// No description provided for @deviation_no_plan.
  ///
  /// In zh, this message translates to:
  /// **'无计划交易'**
  String get deviation_no_plan;

  /// No description provided for @deviation_emotion_override.
  ///
  /// In zh, this message translates to:
  /// **'情绪覆盖计划'**
  String get deviation_emotion_override;

  /// No description provided for @deviation_forced.
  ///
  /// In zh, this message translates to:
  /// **'强制扰动'**
  String get deviation_forced;

  /// No description provided for @deviation_none.
  ///
  /// In zh, this message translates to:
  /// **'无偏离'**
  String get deviation_none;

  /// No description provided for @deviation_no_trades.
  ///
  /// In zh, this message translates to:
  /// **'无交易'**
  String get deviation_no_trades;

  /// No description provided for @label_no_trades.
  ///
  /// In zh, this message translates to:
  /// **'无交易'**
  String get label_no_trades;

  /// No description provided for @label_none.
  ///
  /// In zh, this message translates to:
  /// **'无'**
  String get label_none;

  /// No description provided for @label_not_applicable.
  ///
  /// In zh, this message translates to:
  /// **'不适用'**
  String get label_not_applicable;

  /// No description provided for @action_save_draft.
  ///
  /// In zh, this message translates to:
  /// **'保存草稿'**
  String get action_save_draft;

  /// No description provided for @label_symbol_selection.
  ///
  /// In zh, this message translates to:
  /// **'股票选择'**
  String get label_symbol_selection;

  /// No description provided for @label_buy_reason_one_liner.
  ///
  /// In zh, this message translates to:
  /// **'一句话理由'**
  String get label_buy_reason_one_liner;

  /// No description provided for @hint_buy_reason_one_liner.
  ///
  /// In zh, this message translates to:
  /// **'用人话说一句 (50字以内)'**
  String get hint_buy_reason_one_liner;

  /// No description provided for @label_target_sell_price.
  ///
  /// In zh, this message translates to:
  /// **'预期卖出目标'**
  String get label_target_sell_price;

  /// No description provided for @label_target_low.
  ///
  /// In zh, this message translates to:
  /// **'目标低位'**
  String get label_target_low;

  /// No description provided for @label_target_high.
  ///
  /// In zh, this message translates to:
  /// **'目标高位'**
  String get label_target_high;

  /// No description provided for @label_sell_logic_expected.
  ///
  /// In zh, this message translates to:
  /// **'预期卖出逻辑'**
  String get label_sell_logic_expected;

  /// No description provided for @label_time_take_profit_days.
  ///
  /// In zh, this message translates to:
  /// **'时间止盈天数'**
  String get label_time_take_profit_days;

  /// No description provided for @label_stop_loss_logic.
  ///
  /// In zh, this message translates to:
  /// **'止损逻辑'**
  String get label_stop_loss_logic;

  /// No description provided for @label_stop_price.
  ///
  /// In zh, this message translates to:
  /// **'止损价'**
  String get label_stop_price;

  /// No description provided for @label_stop_days.
  ///
  /// In zh, this message translates to:
  /// **'止损天数'**
  String get label_stop_days;

  /// No description provided for @label_max_loss_percent.
  ///
  /// In zh, this message translates to:
  /// **'最大亏损 (%)'**
  String get label_max_loss_percent;

  /// No description provided for @hint_max_loss.
  ///
  /// In zh, this message translates to:
  /// **'例如 5 表示 5%'**
  String get hint_max_loss;

  /// No description provided for @label_advanced_options.
  ///
  /// In zh, this message translates to:
  /// **'高级选项'**
  String get label_advanced_options;

  /// No description provided for @label_expected_entry_price.
  ///
  /// In zh, this message translates to:
  /// **'预期买入价 (可选)'**
  String get label_expected_entry_price;

  /// No description provided for @label_trade_direction.
  ///
  /// In zh, this message translates to:
  /// **'交易方向'**
  String get label_trade_direction;

  /// No description provided for @label_long.
  ///
  /// In zh, this message translates to:
  /// **'做多 (Long)'**
  String get label_long;

  /// No description provided for @label_short.
  ///
  /// In zh, this message translates to:
  /// **'做空 (Short)'**
  String get label_short;

  /// No description provided for @tip_select_buy_reason.
  ///
  /// In zh, this message translates to:
  /// **'请至少选择一个买入理由类型'**
  String get tip_select_buy_reason;

  /// No description provided for @tip_select_sell_logic.
  ///
  /// In zh, this message translates to:
  /// **'请至少选择一个卖出逻辑'**
  String get tip_select_sell_logic;

  /// No description provided for @tip_watchlist_empty.
  ///
  /// In zh, this message translates to:
  /// **'自选股为空，请先添加股票'**
  String get tip_watchlist_empty;

  /// No description provided for @tip_greater_than_low.
  ///
  /// In zh, this message translates to:
  /// **'须大于低位'**
  String get tip_greater_than_low;

  /// No description provided for @tip_greater_than_zero.
  ///
  /// In zh, this message translates to:
  /// **'须 >= 1'**
  String get tip_greater_than_zero;

  /// No description provided for @tip_invalid_loss_percent.
  ///
  /// In zh, this message translates to:
  /// **'请输入 1~100'**
  String get tip_invalid_loss_percent;

  /// No description provided for @tip_invalid_price.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的成交均价'**
  String get tip_invalid_price;

  /// No description provided for @reason_trend.
  ///
  /// In zh, this message translates to:
  /// **'趋势'**
  String get reason_trend;

  /// No description provided for @reason_range.
  ///
  /// In zh, this message translates to:
  /// **'震荡'**
  String get reason_range;

  /// No description provided for @reason_policy.
  ///
  /// In zh, this message translates to:
  /// **'政策'**
  String get reason_policy;

  /// No description provided for @reason_industry.
  ///
  /// In zh, this message translates to:
  /// **'行业'**
  String get reason_industry;

  /// No description provided for @reason_earnings.
  ///
  /// In zh, this message translates to:
  /// **'财报'**
  String get reason_earnings;

  /// No description provided for @reason_sentiment.
  ///
  /// In zh, this message translates to:
  /// **'情绪'**
  String get reason_sentiment;

  /// No description provided for @reason_probe.
  ///
  /// In zh, this message translates to:
  /// **'试仓'**
  String get reason_probe;

  /// No description provided for @reason_other.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get reason_other;

  /// No description provided for @target_technical.
  ///
  /// In zh, this message translates to:
  /// **'技术位'**
  String get target_technical;

  /// No description provided for @target_previous_high.
  ///
  /// In zh, this message translates to:
  /// **'前高'**
  String get target_previous_high;

  /// No description provided for @target_event.
  ///
  /// In zh, this message translates to:
  /// **'事件兑现'**
  String get target_event;

  /// No description provided for @target_trend.
  ///
  /// In zh, this message translates to:
  /// **'趋势延续'**
  String get target_trend;

  /// No description provided for @logic_reach_target.
  ///
  /// In zh, this message translates to:
  /// **'到达目标区'**
  String get logic_reach_target;

  /// No description provided for @logic_volume_exhaust.
  ///
  /// In zh, this message translates to:
  /// **'量能衰竭'**
  String get logic_volume_exhaust;

  /// No description provided for @logic_trend_break.
  ///
  /// In zh, this message translates to:
  /// **'趋势破坏'**
  String get logic_trend_break;

  /// No description provided for @logic_thesis_invalidated.
  ///
  /// In zh, this message translates to:
  /// **'消息证伪'**
  String get logic_thesis_invalidated;

  /// No description provided for @logic_time_take_profit.
  ///
  /// In zh, this message translates to:
  /// **'时间止盈'**
  String get logic_time_take_profit;

  /// No description provided for @stop_technical.
  ///
  /// In zh, this message translates to:
  /// **'技术位'**
  String get stop_technical;

  /// No description provided for @stop_time.
  ///
  /// In zh, this message translates to:
  /// **'时间'**
  String get stop_time;

  /// No description provided for @stop_logic_fail.
  ///
  /// In zh, this message translates to:
  /// **'逻辑失效'**
  String get stop_logic_fail;

  /// No description provided for @stop_max_loss.
  ///
  /// In zh, this message translates to:
  /// **'最大亏损'**
  String get stop_max_loss;

  /// No description provided for @label_welcome_back.
  ///
  /// In zh, this message translates to:
  /// **'欢迎回来'**
  String get label_welcome_back;

  /// No description provided for @tip_enter_email.
  ///
  /// In zh, this message translates to:
  /// **'请输入邮箱以获取验证码'**
  String get tip_enter_email;

  /// No description provided for @label_email.
  ///
  /// In zh, this message translates to:
  /// **'邮箱'**
  String get label_email;

  /// No description provided for @hint_email.
  ///
  /// In zh, this message translates to:
  /// **'请输入您的邮箱地址'**
  String get hint_email;

  /// No description provided for @action_send_otp.
  ///
  /// In zh, this message translates to:
  /// **'发送验证码'**
  String get action_send_otp;

  /// No description provided for @tip_invalid_email.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的邮箱地址'**
  String get tip_invalid_email;

  /// No description provided for @tip_send_otp_failed.
  ///
  /// In zh, this message translates to:
  /// **'发送验证码失败，请重试'**
  String get tip_send_otp_failed;

  /// No description provided for @title_verify_otp.
  ///
  /// In zh, this message translates to:
  /// **'验证码'**
  String get title_verify_otp;

  /// No description provided for @tip_otp_sent_to.
  ///
  /// In zh, this message translates to:
  /// **'验证码已发送至 {email}'**
  String tip_otp_sent_to(Object email);

  /// No description provided for @label_otp.
  ///
  /// In zh, this message translates to:
  /// **'验证码'**
  String get label_otp;

  /// No description provided for @action_verify.
  ///
  /// In zh, this message translates to:
  /// **'验证'**
  String get action_verify;

  /// No description provided for @tip_invalid_otp.
  ///
  /// In zh, this message translates to:
  /// **'请输入6位验证码'**
  String get tip_invalid_otp;

  /// No description provided for @tip_verify_failed.
  ///
  /// In zh, this message translates to:
  /// **'验证失败，请检查验证码'**
  String get tip_verify_failed;

  /// No description provided for @action_back_to_edit_email.
  ///
  /// In zh, this message translates to:
  /// **'返回修改邮箱'**
  String get action_back_to_edit_email;

  /// No description provided for @label_all_statuses.
  ///
  /// In zh, this message translates to:
  /// **'全部状态'**
  String get label_all_statuses;

  /// No description provided for @tip_no_archived_plans.
  ///
  /// In zh, this message translates to:
  /// **'暂无归档计划'**
  String get tip_no_archived_plans;

  /// No description provided for @tip_unarchived_success.
  ///
  /// In zh, this message translates to:
  /// **'已取消归档'**
  String get tip_unarchived_success;

  /// No description provided for @label_target_range_with_values.
  ///
  /// In zh, this message translates to:
  /// **'目标: {low} ~ {high}'**
  String label_target_range_with_values(Object high, Object low);

  /// No description provided for @label_direction_with_value.
  ///
  /// In zh, this message translates to:
  /// **'方向: {direction}'**
  String label_direction_with_value(Object direction);

  /// No description provided for @title_manage_watchlist.
  ///
  /// In zh, this message translates to:
  /// **'管理关注股票'**
  String get title_manage_watchlist;

  /// No description provided for @title_select_watchlist.
  ///
  /// In zh, this message translates to:
  /// **'选择你关注的股票'**
  String get title_select_watchlist;

  /// No description provided for @tip_add_at_least_one.
  ///
  /// In zh, this message translates to:
  /// **'请至少添加 1 只股票以开始使用'**
  String get tip_add_at_least_one;

  /// No description provided for @hint_search_symbol.
  ///
  /// In zh, this message translates to:
  /// **'输入代码/名称/行业'**
  String get hint_search_symbol;

  /// No description provided for @label_all_industries.
  ///
  /// In zh, this message translates to:
  /// **'全部行业'**
  String get label_all_industries;

  /// No description provided for @tip_symbol_not_found.
  ///
  /// In zh, this message translates to:
  /// **'未找到相关股票'**
  String get tip_symbol_not_found;

  /// No description provided for @action_seed_data.
  ///
  /// In zh, this message translates to:
  /// **'灌入测试数据 (Seed)'**
  String get action_seed_data;

  /// No description provided for @tip_added_symbol.
  ///
  /// In zh, this message translates to:
  /// **'已添加 {name}'**
  String tip_added_symbol(Object name);

  /// No description provided for @label_added.
  ///
  /// In zh, this message translates to:
  /// **'已添加'**
  String get label_added;

  /// No description provided for @action_enter_app.
  ///
  /// In zh, this message translates to:
  /// **'进入应用'**
  String get action_enter_app;

  /// No description provided for @title_subscription_limit.
  ///
  /// In zh, this message translates to:
  /// **'订阅限制'**
  String get title_subscription_limit;

  /// No description provided for @tip_subscription_limit_msg.
  ///
  /// In zh, this message translates to:
  /// **'免费版仅可添加 1 只股票。请升级以解锁更多名额。'**
  String get tip_subscription_limit_msg;

  /// No description provided for @action_learn_more_upgrade.
  ///
  /// In zh, this message translates to:
  /// **'了解升级'**
  String get action_learn_more_upgrade;

  /// No description provided for @tip_seed_success.
  ///
  /// In zh, this message translates to:
  /// **'测试数据灌入成功，请重新搜索'**
  String get tip_seed_success;

  /// No description provided for @tip_seed_failed.
  ///
  /// In zh, this message translates to:
  /// **'灌入失败: {error}\n请确保已运行 npx wrangler d1 execute ... 初始化数据库'**
  String tip_seed_failed(Object error);

  /// No description provided for @label_nav_journal.
  ///
  /// In zh, this message translates to:
  /// **'复盘'**
  String get label_nav_journal;

  /// No description provided for @label_nav_alerts.
  ///
  /// In zh, this message translates to:
  /// **'异动'**
  String get label_nav_alerts;

  /// No description provided for @label_nav_stats.
  ///
  /// In zh, this message translates to:
  /// **'统计'**
  String get label_nav_stats;

  /// No description provided for @tip_alerts_placeholder.
  ///
  /// In zh, this message translates to:
  /// **'异动 (Step 4 实现)'**
  String get tip_alerts_placeholder;

  /// No description provided for @tip_plan_locked.
  ///
  /// In zh, this message translates to:
  /// **'计划已锁定；后续调整会以“修订记录”形式保存。'**
  String get tip_plan_locked;

  /// No description provided for @action_revise_target.
  ///
  /// In zh, this message translates to:
  /// **'修订目标区间'**
  String get action_revise_target;

  /// No description provided for @title_revise_target.
  ///
  /// In zh, this message translates to:
  /// **'修订目标区间'**
  String get title_revise_target;

  /// No description provided for @label_event_timeline.
  ///
  /// In zh, this message translates to:
  /// **'事件线'**
  String get label_event_timeline;

  /// No description provided for @action_add_event.
  ///
  /// In zh, this message translates to:
  /// **'新增事件'**
  String get action_add_event;

  /// No description provided for @label_comparison_status.
  ///
  /// In zh, this message translates to:
  /// **'对照状态'**
  String get label_comparison_status;

  /// No description provided for @label_fact_only.
  ///
  /// In zh, this message translates to:
  /// **'只显示事实，不提供建议'**
  String get label_fact_only;

  /// No description provided for @label_defined.
  ///
  /// In zh, this message translates to:
  /// **'已定义'**
  String get label_defined;

  /// No description provided for @label_undefined.
  ///
  /// In zh, this message translates to:
  /// **'未定义'**
  String get label_undefined;

  /// No description provided for @label_exit_trigger_event.
  ///
  /// In zh, this message translates to:
  /// **'退出触发事件'**
  String get label_exit_trigger_event;

  /// No description provided for @label_yes_with_count.
  ///
  /// In zh, this message translates to:
  /// **'有 ({count})'**
  String label_yes_with_count(int count);

  /// No description provided for @tip_exit_event_recorded.
  ///
  /// In zh, this message translates to:
  /// **'已记录 {count} 条事件标注为“触发退出条件”。请在卖出时选择原因并完成对照复盘。'**
  String tip_exit_event_recorded(int count);

  /// No description provided for @label_time_take_profit_condition.
  ///
  /// In zh, this message translates to:
  /// **'• 时间止盈条件：{days} 天（从建计划开始计）'**
  String label_time_take_profit_condition(int days);

  /// No description provided for @title_calm_conclusion.
  ///
  /// In zh, this message translates to:
  /// **'冷静结论'**
  String get title_calm_conclusion;

  /// No description provided for @label_entry_deviation.
  ///
  /// In zh, this message translates to:
  /// **'建仓偏离'**
  String get label_entry_deviation;

  /// No description provided for @label_entry_driver.
  ///
  /// In zh, this message translates to:
  /// **'建仓驱动 (可选)'**
  String get label_entry_driver;

  /// No description provided for @label_no_deviation.
  ///
  /// In zh, this message translates to:
  /// **'本次建仓严格按原计划价格执行'**
  String get label_no_deviation;

  /// No description provided for @label_deviation_fact.
  ///
  /// In zh, this message translates to:
  /// **'本次交易中，实际建仓价 {direction} 原预算价 {percent}%'**
  String label_deviation_fact(Object direction, Object percent);

  /// No description provided for @label_driver_fact.
  ///
  /// In zh, this message translates to:
  /// **'建仓时记录的主要驱动为：{driver}'**
  String label_driver_fact(Object driver);

  /// No description provided for @label_plan_vs_actual.
  ///
  /// In zh, this message translates to:
  /// **'原计划 vs 实际执行'**
  String get label_plan_vs_actual;

  /// No description provided for @label_planned_range.
  ///
  /// In zh, this message translates to:
  /// **'原计划建仓区间'**
  String get label_planned_range;

  /// No description provided for @label_actual_price.
  ///
  /// In zh, this message translates to:
  /// **'实际建仓价格'**
  String get label_actual_price;

  /// No description provided for @label_deviation_direction.
  ///
  /// In zh, this message translates to:
  /// **'偏离方向'**
  String get label_deviation_direction;

  /// No description provided for @label_direction_up.
  ///
  /// In zh, this message translates to:
  /// **'上移'**
  String get label_direction_up;

  /// No description provided for @label_direction_down.
  ///
  /// In zh, this message translates to:
  /// **'下移'**
  String get label_direction_down;

  /// No description provided for @label_direction_none.
  ///
  /// In zh, this message translates to:
  /// **'无偏离'**
  String get label_direction_none;

  /// No description provided for @label_result_correlation.
  ///
  /// In zh, this message translates to:
  /// **'结果关联'**
  String get label_result_correlation;

  /// No description provided for @label_loss_with_deviation.
  ///
  /// In zh, this message translates to:
  /// **'本次交易为亏损交易，且存在建仓偏离'**
  String get label_loss_with_deviation;

  /// No description provided for @label_profit_with_deviation.
  ///
  /// In zh, this message translates to:
  /// **'本次交易为盈利交易，但存在建仓偏离'**
  String get label_profit_with_deviation;

  /// No description provided for @label_loss_no_deviation.
  ///
  /// In zh, this message translates to:
  /// **'本次交易为亏损交易，执行与计划一致'**
  String get label_loss_no_deviation;

  /// No description provided for @label_profit_no_deviation.
  ///
  /// In zh, this message translates to:
  /// **'本次交易为盈利交易，执行与计划一致'**
  String get label_profit_no_deviation;

  /// No description provided for @label_calm_summary_deviation.
  ///
  /// In zh, this message translates to:
  /// **'本次交易中，计划与执行出现偏移，建议在后续复盘中关注该类情境的重复出现频率。'**
  String get label_calm_summary_deviation;

  /// No description provided for @label_calm_summary_no_deviation.
  ///
  /// In zh, this message translates to:
  /// **'本次交易执行过程与原计划一致。'**
  String get label_calm_summary_no_deviation;

  /// No description provided for @driver_fomo.
  ///
  /// In zh, this message translates to:
  /// **'担心错过行情 (FOMO)'**
  String get driver_fomo;

  /// No description provided for @driver_plan_weakened.
  ///
  /// In zh, this message translates to:
  /// **'计划逻辑弱化'**
  String get driver_plan_weakened;

  /// No description provided for @driver_market_change.
  ///
  /// In zh, this message translates to:
  /// **'市场环境突变'**
  String get driver_market_change;

  /// No description provided for @driver_wait_failed.
  ///
  /// In zh, this message translates to:
  /// **'等待耐心耗尽'**
  String get driver_wait_failed;

  /// No description provided for @driver_emotion.
  ///
  /// In zh, this message translates to:
  /// **'情绪波动'**
  String get driver_emotion;

  /// No description provided for @driver_other.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get driver_other;

  /// No description provided for @badge_deviation.
  ///
  /// In zh, this message translates to:
  /// **'有建仓偏离'**
  String get badge_deviation;

  /// No description provided for @badge_no_deviation.
  ///
  /// In zh, this message translates to:
  /// **'按计划执行'**
  String get badge_no_deviation;

  /// No description provided for @label_event_stage.
  ///
  /// In zh, this message translates to:
  /// **'事件阶段'**
  String get label_event_stage;

  /// No description provided for @label_behavior_driver.
  ///
  /// In zh, this message translates to:
  /// **'行为驱动'**
  String get label_behavior_driver;

  /// No description provided for @label_price_at_event.
  ///
  /// In zh, this message translates to:
  /// **'事件发生价'**
  String get label_price_at_event;

  /// No description provided for @stage_entry_deviation.
  ///
  /// In zh, this message translates to:
  /// **'建仓执行偏移'**
  String get stage_entry_deviation;

  /// No description provided for @stage_entry_non_action.
  ///
  /// In zh, this message translates to:
  /// **'低位未执行'**
  String get stage_entry_non_action;

  /// No description provided for @stage_exit_deviation.
  ///
  /// In zh, this message translates to:
  /// **'卖出执行偏移'**
  String get stage_exit_deviation;

  /// No description provided for @stage_stoploss_deviation.
  ///
  /// In zh, this message translates to:
  /// **'止损执行偏移'**
  String get stage_stoploss_deviation;

  /// No description provided for @stage_external_change.
  ///
  /// In zh, this message translates to:
  /// **'外部环境变化'**
  String get stage_external_change;

  /// No description provided for @label_epc.
  ///
  /// In zh, this message translates to:
  /// **'EPC'**
  String get label_epc;

  /// No description provided for @label_epc_fact.
  ///
  /// In zh, this message translates to:
  /// **'提前卖出后，价格继续向原目标方向发展，形成约 {pct}% 的提前卖出机会成本 (EPC)。'**
  String label_epc_fact(String pct);

  /// No description provided for @label_exit_triggered_by_event.
  ///
  /// In zh, this message translates to:
  /// **'本次卖出由计划失效事件触发，不计入提前卖出成本。'**
  String get label_exit_triggered_by_event;

  /// No description provided for @label_epc_summary.
  ///
  /// In zh, this message translates to:
  /// **'本次交易中，卖出行为与原计划目标存在偏离，该类情境可在后续复盘中关注其重复出现情况。'**
  String get label_epc_summary;

  /// No description provided for @driver_early_profit.
  ///
  /// In zh, this message translates to:
  /// **'提前兑现，降低不确定性'**
  String get driver_early_profit;

  /// No description provided for @driver_fear_drawdown.
  ///
  /// In zh, this message translates to:
  /// **'无法承受回撤'**
  String get driver_fear_drawdown;

  /// No description provided for @driver_emotion_fear.
  ///
  /// In zh, this message translates to:
  /// **'情绪性卖出（恐惧/犹豫）'**
  String get driver_emotion_fear;

  /// No description provided for @driver_lower_target.
  ///
  /// In zh, this message translates to:
  /// **'临时降低目标'**
  String get driver_lower_target;

  /// No description provided for @driver_fomo_short.
  ///
  /// In zh, this message translates to:
  /// **'追高 (FOMO)'**
  String get driver_fomo_short;

  /// No description provided for @driver_fear.
  ///
  /// In zh, this message translates to:
  /// **'恐慌 (Fear)'**
  String get driver_fear;

  /// No description provided for @driver_wait_failed_short.
  ///
  /// In zh, this message translates to:
  /// **'耐心耗尽'**
  String get driver_wait_failed_short;

  /// No description provided for @driver_logic_broken.
  ///
  /// In zh, this message translates to:
  /// **'逻辑破坏'**
  String get driver_logic_broken;

  /// No description provided for @driver_market_crash.
  ///
  /// In zh, this message translates to:
  /// **'市场崩盘'**
  String get driver_market_crash;

  /// No description provided for @driver_profit_protect.
  ///
  /// In zh, this message translates to:
  /// **'利润保护'**
  String get driver_profit_protect;

  /// No description provided for @driver_revenge.
  ///
  /// In zh, this message translates to:
  /// **'报复性交易'**
  String get driver_revenge;

  /// No description provided for @driver_other_short.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get driver_other_short;

  /// No description provided for @label_missed_price.
  ///
  /// In zh, this message translates to:
  /// **'错过价格'**
  String get label_missed_price;

  /// No description provided for @label_deviation_price.
  ///
  /// In zh, this message translates to:
  /// **'偏离价格'**
  String get label_deviation_price;

  /// No description provided for @label_etnr.
  ///
  /// In zh, this message translates to:
  /// **'E-TNR (追高成本)'**
  String get label_etnr;

  /// No description provided for @label_eldc.
  ///
  /// In zh, this message translates to:
  /// **'E-LDC (低位未买成本)'**
  String get label_eldc;

  /// No description provided for @label_tnr.
  ///
  /// In zh, this message translates to:
  /// **'TNR (到位未卖成本)'**
  String get label_tnr;

  /// No description provided for @label_ldc.
  ///
  /// In zh, this message translates to:
  /// **'LDC (止损延迟成本)'**
  String get label_ldc;

  /// No description provided for @title_add_event.
  ///
  /// In zh, this message translates to:
  /// **'新增事件'**
  String get title_add_event;

  /// No description provided for @label_event_summary.
  ///
  /// In zh, this message translates to:
  /// **'事件摘要'**
  String get label_event_summary;

  /// No description provided for @label_triggered_exit.
  ///
  /// In zh, this message translates to:
  /// **'触发退出条件'**
  String get label_triggered_exit;

  /// No description provided for @btn_submit_event.
  ///
  /// In zh, this message translates to:
  /// **'提交事件'**
  String get btn_submit_event;

  /// No description provided for @label_plan_consistency_desc.
  ///
  /// In zh, this message translates to:
  /// **'计划一致性'**
  String get label_plan_consistency_desc;

  /// No description provided for @label_etnr_desc.
  ///
  /// In zh, this message translates to:
  /// **'买入追高成本'**
  String get label_etnr_desc;

  /// No description provided for @label_eldc_desc.
  ///
  /// In zh, this message translates to:
  /// **'低位不执行成本'**
  String get label_eldc_desc;

  /// No description provided for @label_tnr_desc.
  ///
  /// In zh, this message translates to:
  /// **'到位不卖'**
  String get label_tnr_desc;

  /// No description provided for @label_ldc_desc.
  ///
  /// In zh, this message translates to:
  /// **'止损拖延'**
  String get label_ldc_desc;

  /// No description provided for @label_epc_desc.
  ///
  /// In zh, this message translates to:
  /// **'提前卖出成本'**
  String get label_epc_desc;

  /// No description provided for @tip_entry_deviation_hint.
  ///
  /// In zh, this message translates to:
  /// **'检测到建仓价格偏离，请记录驱动因素'**
  String get tip_entry_deviation_hint;

  /// No description provided for @label_audit_metrics.
  ///
  /// In zh, this message translates to:
  /// **'核心纪律指标'**
  String get label_audit_metrics;

  /// No description provided for @label_evidence_chain.
  ///
  /// In zh, this message translates to:
  /// **'证据链 (Evidence Chain)'**
  String get label_evidence_chain;

  /// No description provided for @label_improvement_tips.
  ///
  /// In zh, this message translates to:
  /// **'本周改进提示'**
  String get label_improvement_tips;

  /// No description provided for @label_quantitative_results.
  ///
  /// In zh, this message translates to:
  /// **'量化结果'**
  String get label_quantitative_results;

  /// No description provided for @label_weekly_conclusion.
  ///
  /// In zh, this message translates to:
  /// **'本周结论'**
  String get label_weekly_conclusion;

  /// No description provided for @label_deviation_score.
  ///
  /// In zh, this message translates to:
  /// **'偏离分数'**
  String get label_deviation_score;

  /// No description provided for @label_deviation_magnitude.
  ///
  /// In zh, this message translates to:
  /// **'偏离幅度'**
  String get label_deviation_magnitude;

  /// No description provided for @label_trigger_threshold.
  ///
  /// In zh, this message translates to:
  /// **'触发阈值'**
  String get label_trigger_threshold;

  /// No description provided for @tip_score_explanation.
  ///
  /// In zh, this message translates to:
  /// **'注：分数代表偏离强度，不代表好坏。分数越高表示偏离计划程度越大。'**
  String get tip_score_explanation;

  /// No description provided for @tip_no_evidence.
  ///
  /// In zh, this message translates to:
  /// **'暂无直接证据'**
  String get tip_no_evidence;

  /// No description provided for @status_triggered.
  ///
  /// In zh, this message translates to:
  /// **'发生'**
  String get status_triggered;

  /// No description provided for @status_not_triggered.
  ///
  /// In zh, this message translates to:
  /// **'未发生'**
  String get status_not_triggered;

  /// No description provided for @status_na.
  ///
  /// In zh, this message translates to:
  /// **'不适用'**
  String get status_na;

  /// No description provided for @status_insufficient_data.
  ///
  /// In zh, this message translates to:
  /// **'数据不足'**
  String get status_insufficient_data;

  /// No description provided for @label_evidence_count.
  ///
  /// In zh, this message translates to:
  /// **'证据 {count} 条'**
  String label_evidence_count(int count);

  /// No description provided for @label_event_type.
  ///
  /// In zh, this message translates to:
  /// **'事件类型'**
  String get label_event_type;

  /// No description provided for @label_impact_target.
  ///
  /// In zh, this message translates to:
  /// **'影响对象'**
  String get label_impact_target;

  /// No description provided for @type_logic_broken.
  ///
  /// In zh, this message translates to:
  /// **'逻辑证伪'**
  String get type_logic_broken;

  /// No description provided for @type_forced.
  ///
  /// In zh, this message translates to:
  /// **'强制扰动'**
  String get type_forced;

  /// No description provided for @type_verify.
  ///
  /// In zh, this message translates to:
  /// **'验证兑现'**
  String get type_verify;

  /// No description provided for @type_structure_change.
  ///
  /// In zh, this message translates to:
  /// **'结构变化'**
  String get type_structure_change;

  /// No description provided for @target_buy.
  ///
  /// In zh, this message translates to:
  /// **'建仓'**
  String get target_buy;

  /// No description provided for @target_hold.
  ///
  /// In zh, this message translates to:
  /// **'加仓持仓'**
  String get target_hold;

  /// No description provided for @target_sell.
  ///
  /// In zh, this message translates to:
  /// **'卖出'**
  String get target_sell;

  /// No description provided for @target_stop.
  ///
  /// In zh, this message translates to:
  /// **'止损'**
  String get target_stop;

  /// No description provided for @hint_summary_fact_only.
  ///
  /// In zh, this message translates to:
  /// **'只写事实，不写解释（最多40字）'**
  String get hint_summary_fact_only;

  /// No description provided for @label_event_explain.
  ///
  /// In zh, this message translates to:
  /// **'记录已发生且会影响计划是否继续成立的事实证据。'**
  String get label_event_explain;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get title_journal => '交易复盘';

  @override
  String get title_plan_detail => '计划详情';

  @override
  String get title_self_assessment => '自我评估';

  @override
  String get title_weekly_report => '本周纪律周报';

  @override
  String get title_create_plan => '新建交易计划';

  @override
  String get title_archived_plans => '已归档计划';

  @override
  String get title_login => '登录';

  @override
  String get status_draft => '草稿';

  @override
  String get status_armed => '武装';

  @override
  String get status_holding => '持仓';

  @override
  String get status_closed => '平仓';

  @override
  String get status_archived => '已归档';

  @override
  String get action_create_plan => '新建计划';

  @override
  String get action_submit => '提交评估';

  @override
  String get action_arm => '武装计划';

  @override
  String get action_close_trade => '平仓结案';

  @override
  String get action_self_assessment => '自我评估';

  @override
  String get action_archive => '归档';

  @override
  String get action_unarchive => '取消归档';

  @override
  String get action_refresh => '刷新';

  @override
  String get action_view_details => '查看细则';

  @override
  String get action_hide_details => '收起细则';

  @override
  String get label_discipline_score => '本周纪律得分';

  @override
  String get label_symbol => '标的';

  @override
  String get label_industry => '行业';

  @override
  String get label_updated_at => '更新时间';

  @override
  String get label_pcs_score => '1️⃣ 计划一致性得分 (PCS)';

  @override
  String get label_main_deviation => '2️⃣ 本周主要偏离类型';

  @override
  String get label_conclusion => '3️⃣ 冷静结论';

  @override
  String get label_tnr_ldc => '4️⃣ TNR / LDC';

  @override
  String label_completed_count(int count) {
    return '已完成 $count/13';
  }

  @override
  String get tip_no_plans => '还没有交易计划';

  @override
  String get tip_no_plans_sub => '先写计划再交易，强化交易纪律';

  @override
  String get tip_no_trades => '本周无交易记录';

  @override
  String tip_fetch_failed(String error) {
    return '获取数据失败: $error';
  }

  @override
  String get tip_submit_success => '评估提交成功';

  @override
  String tip_submit_failed(String error) {
    return '提交失败: $error';
  }

  @override
  String get tip_complete_all => '请完成所有维度的评估';

  @override
  String get label_buy_reason => '买入理由';

  @override
  String get label_reason_type => '理由类型';

  @override
  String label_target_range(Object high, Object low) {
    return '目标: $low ~ $high';
  }

  @override
  String get label_sell_logic => '卖出逻辑';

  @override
  String get label_time_take_profit => '时间止盈';

  @override
  String get label_stop_logic => '止损逻辑';

  @override
  String get label_entry_price => '预期买入价';

  @override
  String get label_edit_history => '修订记录';

  @override
  String get label_close_price => '成交均价';

  @override
  String get label_close_reason => '平仓理由';

  @override
  String get hint_close_price => '输入平仓成交均价';

  @override
  String get hint_close_reason => '简述平仓逻辑（如：触及止盈、逻辑走坏等）';

  @override
  String get label_create => '创建';

  @override
  String get label_update => '更新';

  @override
  String get label_original_plan => '原始计划 (锁定内容)';

  @override
  String get deviation_no_plan => '无计划交易';

  @override
  String get deviation_emotion_override => '情绪覆盖计划';

  @override
  String get deviation_forced => '强制扰动';

  @override
  String get deviation_none => '无偏离';

  @override
  String get deviation_no_trades => '无交易';

  @override
  String get label_no_trades => '无交易';

  @override
  String get label_none => '无';

  @override
  String get label_not_applicable => '不适用';

  @override
  String get action_save_draft => '保存草稿';

  @override
  String get label_symbol_selection => '股票选择';

  @override
  String get label_buy_reason_one_liner => '一句话理由';

  @override
  String get hint_buy_reason_one_liner => '用人话说一句 (50字以内)';

  @override
  String get label_target_sell_price => '预期卖出目标';

  @override
  String get label_target_low => '目标低位';

  @override
  String get label_target_high => '目标高位';

  @override
  String get label_sell_logic_expected => '预期卖出逻辑';

  @override
  String get label_time_take_profit_days => '时间止盈天数';

  @override
  String get label_stop_loss_logic => '止损逻辑';

  @override
  String get label_stop_price => '止损价';

  @override
  String get label_stop_days => '止损天数';

  @override
  String get label_max_loss_percent => '最大亏损 (%)';

  @override
  String get hint_max_loss => '例如 5 表示 5%';

  @override
  String get label_advanced_options => '高级选项';

  @override
  String get label_expected_entry_price => '预期买入价 (可选)';

  @override
  String get label_trade_direction => '交易方向';

  @override
  String get label_long => '做多 (Long)';

  @override
  String get label_short => '做空 (Short)';

  @override
  String get tip_select_buy_reason => '请至少选择一个买入理由类型';

  @override
  String get tip_select_sell_logic => '请至少选择一个卖出逻辑';

  @override
  String get tip_watchlist_empty => '自选股为空，请先添加股票';

  @override
  String get tip_greater_than_low => '须大于低位';

  @override
  String get tip_greater_than_zero => '须 >= 1';

  @override
  String get tip_invalid_loss_percent => '请输入 1~100';

  @override
  String get reason_trend => '趋势';

  @override
  String get reason_range => '震荡';

  @override
  String get reason_policy => '政策';

  @override
  String get reason_industry => '行业';

  @override
  String get reason_earnings => '财报';

  @override
  String get reason_sentiment => '情绪';

  @override
  String get reason_probe => '试仓';

  @override
  String get reason_other => '其他';

  @override
  String get target_technical => '技术位';

  @override
  String get target_previous_high => '前高';

  @override
  String get target_event => '事件兑现';

  @override
  String get target_trend => '趋势延续';

  @override
  String get logic_reach_target => '到达目标区';

  @override
  String get logic_volume_exhaust => '量能衰竭';

  @override
  String get logic_trend_break => '趋势破坏';

  @override
  String get logic_thesis_invalidated => '消息证伪';

  @override
  String get logic_time_take_profit => '时间止盈';

  @override
  String get stop_technical => '技术位';

  @override
  String get stop_time => '时间';

  @override
  String get stop_logic_fail => '逻辑失效';

  @override
  String get stop_max_loss => '最大亏损';

  @override
  String get label_welcome_back => '欢迎回来';

  @override
  String get tip_enter_email => '请输入邮箱以获取验证码';

  @override
  String get label_email => '邮箱';

  @override
  String get action_send_otp => '发送验证码';

  @override
  String get tip_invalid_email => '请输入有效的邮箱地址';

  @override
  String get tip_send_otp_failed => '发送验证码失败，请重试';

  @override
  String get title_verify_otp => '验证码';

  @override
  String tip_otp_sent_to(Object email) {
    return '验证码已发送至 $email';
  }

  @override
  String get label_otp => '验证码';

  @override
  String get action_verify => '验证';

  @override
  String get tip_invalid_otp => '请输入6位验证码';

  @override
  String get tip_verify_failed => '验证失败，请检查验证码';

  @override
  String get action_back_to_edit_email => '返回修改邮箱';

  @override
  String get label_all_statuses => '全部状态';

  @override
  String get tip_no_archived_plans => '暂无归档计划';

  @override
  String get tip_unarchived_success => '已取消归档';

  @override
  String label_direction_with_value(Object direction) {
    return '方向: $direction';
  }

  @override
  String get title_manage_watchlist => '管理关注股票';

  @override
  String get title_select_watchlist => '选择你关注的股票';

  @override
  String get tip_add_at_least_one => '请至少添加 1 只股票以开始使用';

  @override
  String get hint_search_symbol => '输入代码/名称/行业';

  @override
  String get label_all_industries => '全部行业';

  @override
  String get tip_symbol_not_found => '未找到相关股票';

  @override
  String get action_seed_data => '灌入测试数据 (Seed)';

  @override
  String tip_added_symbol(Object name) {
    return '已添加 $name';
  }

  @override
  String get label_added => '已添加';

  @override
  String get action_enter_app => '进入应用';

  @override
  String get title_subscription_limit => '订阅限制';

  @override
  String get tip_subscription_limit_msg => '免费版仅可添加 1 只股票。请升级以解锁更多名额。';

  @override
  String get action_learn_more_upgrade => '了解升级';

  @override
  String get tip_seed_success => '测试数据灌入成功，请重新搜索';

  @override
  String tip_seed_failed(Object error) {
    return '灌入失败: $error\n请确保已运行 npx wrangler d1 execute ... 初始化数据库';
  }

  @override
  String get label_nav_journal => '复盘';

  @override
  String get label_nav_alerts => '异动';

  @override
  String get label_nav_stats => '统计';

  @override
  String get tip_alerts_placeholder => '异动 (Step 4 实现)';
}

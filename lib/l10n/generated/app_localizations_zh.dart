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
  String get status_draft => '预建仓';

  @override
  String get status_armed => '已建仓';

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
  String get action_arm => '建仓';

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
  String get action_view_detail => '查看详情';

  @override
  String get action_hide_details => '收起细则';

  @override
  String get action_back => '返回';

  @override
  String get action_confirm => '确定';

  @override
  String get action_add => '添加';

  @override
  String get action_switch_language => '切换语言';

  @override
  String get tip_required => '必填';

  @override
  String get label_language_zh => '简体中文';

  @override
  String get label_language_en => 'English';

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
  String get label_target_range => '目标区间';

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
  String get tip_invalid_price => '请输入有效的成交均价';

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
  String get hint_email => '请输入您的邮箱地址';

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
  String label_target_range_with_values(Object high, Object low) {
    return '目标: $low ~ $high';
  }

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

  @override
  String get tip_plan_locked => '计划已锁定；后续调整会以“修订记录”形式保存。';

  @override
  String get action_revise_target => '修订目标区间';

  @override
  String get title_revise_target => '修订目标区间';

  @override
  String get label_event_timeline => '事件线';

  @override
  String get action_add_event => '新增事件';

  @override
  String get label_comparison_status => '对照状态';

  @override
  String get label_fact_only => '只显示事实，不提供建议';

  @override
  String get label_defined => '已定义';

  @override
  String get label_undefined => '未定义';

  @override
  String get label_exit_trigger_event => '退出触发事件';

  @override
  String label_yes_with_count(int count) {
    return '有 ($count)';
  }

  @override
  String tip_exit_event_recorded(int count) {
    return '已记录 $count 条事件标注为“触发退出条件”。请在卖出时选择原因并完成对照复盘。';
  }

  @override
  String label_time_take_profit_condition(int days) {
    return '• 时间止盈条件：$days 天（从建计划开始计）';
  }

  @override
  String get title_calm_conclusion => '冷静结论';

  @override
  String get label_entry_deviation => '建仓偏离';

  @override
  String get label_entry_driver => '建仓驱动 (可选)';

  @override
  String get label_no_deviation => '本次建仓严格按原计划价格执行';

  @override
  String label_deviation_fact(Object direction, Object percent) {
    return '本次交易中，实际建仓价 $direction 原预算价 $percent%';
  }

  @override
  String label_driver_fact(Object driver) {
    return '建仓时记录的主要驱动为：$driver';
  }

  @override
  String get label_plan_vs_actual => '原计划 vs 实际执行';

  @override
  String get label_planned_range => '原计划建仓区间';

  @override
  String get label_actual_price => '实际建仓价格';

  @override
  String get label_deviation_direction => '偏离方向';

  @override
  String get label_direction_up => '上移';

  @override
  String get label_direction_down => '下移';

  @override
  String get label_direction_none => '无偏离';

  @override
  String get label_result_correlation => '结果关联';

  @override
  String get label_loss_with_deviation => '本次交易为亏损交易，且存在建仓偏离';

  @override
  String get label_profit_with_deviation => '本次交易为盈利交易，但存在建仓偏离';

  @override
  String get label_loss_no_deviation => '本次交易为亏损交易，执行与计划一致';

  @override
  String get label_profit_no_deviation => '本次交易为盈利交易，执行与计划一致';

  @override
  String get label_calm_summary_deviation =>
      '本次交易中，计划与执行出现偏移，建议在后续复盘中关注该类情境的重复出现频率。';

  @override
  String get label_calm_summary_no_deviation => '本次交易执行过程与原计划一致。';

  @override
  String get driver_fomo => '担心错过行情 (FOMO)';

  @override
  String get driver_plan_weakened => '计划逻辑弱化';

  @override
  String get driver_market_change => '市场环境突变';

  @override
  String get driver_wait_failed => '等待耐心耗尽';

  @override
  String get driver_emotion => '情绪波动';

  @override
  String get driver_other => '其他';

  @override
  String get badge_deviation => '有建仓偏离';

  @override
  String get badge_no_deviation => '按计划执行';

  @override
  String get label_event_stage => '事件阶段';

  @override
  String get label_behavior_driver => '行为驱动';

  @override
  String get label_price_at_event => '事件发生价';

  @override
  String get stage_entry_deviation => '建仓执行偏移';

  @override
  String get stage_entry_non_action => '低位未执行';

  @override
  String get stage_exit_deviation => '卖出执行偏移';

  @override
  String get stage_stoploss_deviation => '止损执行偏移';

  @override
  String get stage_external_change => '外部环境变化';

  @override
  String get label_epc => 'EPC';

  @override
  String label_epc_fact(String pct) {
    return '提前卖出后，价格继续向原目标方向发展，形成约 $pct% 的提前卖出机会成本 (EPC)。';
  }

  @override
  String get label_exit_triggered_by_event => '本次卖出由计划失效事件触发，不计入提前卖出成本。';

  @override
  String get label_epc_summary => '本次交易中，卖出行为与原计划目标存在偏离，该类情境可在后续复盘中关注其重复出现情况。';

  @override
  String get driver_early_profit => '提前兑现，降低不确定性';

  @override
  String get driver_fear_drawdown => '无法承受回撤';

  @override
  String get driver_emotion_fear => '情绪性卖出（恐惧/犹豫）';

  @override
  String get driver_lower_target => '临时降低目标';

  @override
  String get driver_fomo_short => '追高 (FOMO)';

  @override
  String get driver_fear => '恐慌 (Fear)';

  @override
  String get driver_wait_failed_short => '耐心耗尽';

  @override
  String get driver_logic_broken => '逻辑破坏';

  @override
  String get driver_market_crash => '市场崩盘';

  @override
  String get driver_profit_protect => '利润保护';

  @override
  String get driver_revenge => '报复性交易';

  @override
  String get driver_other_short => '其他';

  @override
  String get label_missed_price => '错过价格';

  @override
  String get label_deviation_price => '偏离价格';

  @override
  String get label_etnr => 'E-TNR (追高成本)';

  @override
  String get label_eldc => 'E-LDC (低位未买成本)';

  @override
  String get label_tnr => 'TNR (到位未卖成本)';

  @override
  String get label_ldc => 'LDC (止损延迟成本)';

  @override
  String get title_add_event => '新增事件';

  @override
  String get label_event_summary => '事件摘要';

  @override
  String get label_triggered_exit => '触发退出条件';

  @override
  String get btn_submit_event => '提交事件';

  @override
  String get label_plan_consistency_desc => '计划一致性';

  @override
  String get label_etnr_desc => '买入追高成本';

  @override
  String get label_eldc_desc => '低位不执行成本';

  @override
  String get label_tnr_desc => '到位不卖';

  @override
  String get label_ldc_desc => '止损拖延';

  @override
  String get label_epc_desc => '提前卖出成本';

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
  String get label_deviation_score => '偏离分数';

  @override
  String get label_deviation_magnitude => '偏离幅度';

  @override
  String get label_trigger_threshold => '触发阈值';

  @override
  String get tip_score_explanation => '注：分数代表偏离强度，不代表好坏。分数越高表示偏离计划程度越大。';

  @override
  String get tip_no_evidence => '暂无直接证据';

  @override
  String get status_triggered => '发生';

  @override
  String get status_not_triggered => '未发生';

  @override
  String get status_na => '不适用';

  @override
  String get status_insufficient_data => '数据不足';

  @override
  String label_evidence_count(int count) {
    return '证据 $count 条';
  }

  @override
  String get label_event_type => '事件类型';

  @override
  String get label_impact_target => '影响对象';

  @override
  String get type_logic_broken => '逻辑证伪';

  @override
  String get type_forced => '强制扰动';

  @override
  String get type_verify => '验证兑现';

  @override
  String get type_structure_change => '结构变化';

  @override
  String get target_buy => '建仓';

  @override
  String get target_hold => '加仓持仓';

  @override
  String get target_sell => '卖出';

  @override
  String get target_stop => '止损';

  @override
  String get hint_summary_fact_only => '只写事实，不写解释（最多40字）';

  @override
  String get label_event_explain => '记录已发生且会影响计划是否继续成立的事实证据。';
}

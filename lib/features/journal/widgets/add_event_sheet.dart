import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fupan/l10n/generated/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/theme.dart';
import '../../../models/add_event_request.dart';

class AddEventSheet extends ConsumerStatefulWidget {
  final String planId;
  final String planStatus;
  final VoidCallback onSuccess;

  const AddEventSheet({
    super.key,
    required this.planId,
    required this.planStatus,
    required this.onSuccess,
    this.initialEventStage,
    this.initialPrice,
  });

  final String? initialEventStage;
  final double? initialPrice;

  @override
  ConsumerState<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends ConsumerState<AddEventSheet> {
  final _formKey = GlobalKey<FormState>();
  final _summaryController = TextEditingController();
  final _priceController = TextEditingController();

  String? _eventStage;
  String? _eventType;
  String? _impactTarget;
  String? _behaviorDriver;
  bool _triggeredExit = false;
  bool _isSubmitting = false;
  bool _showAdvanced = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEventStage != null) {
      _onStageSelected(widget.initialEventStage!);
    }
    if (widget.initialPrice != null) {
      _priceController.text = widget.initialPrice.toString();
    }
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  List<String> _getDriversForStage(String stage) {
    switch (stage) {
      case 'entry_deviation': // E-TNR
        return [
          'driver_fomo_short',
          'driver_wait_confirm',
          'driver_loosen_budget',
          'driver_emotion_swing',
        ];
      case 'entry_non_action': // E-LDC
        return [
          'driver_fear_continue_drop',
          'driver_signal_insufficient',
          'driver_full_position',
          'driver_no_cash',
          'driver_no_plan',
        ];
      case 'exit_non_action': // TNR
        return [
          'driver_hold_at_target',
          'driver_raise_target',
          'driver_wait_confirm',
          'driver_greed_hesitation',
        ];
      case 'stoploss_deviation': // LDC
        return [
          'driver_resist_stop',
          'driver_hope_rebound',
          'driver_lower_stop',
          'driver_emotion_ignore',
        ];
      case 'exit_deviation': // EPC
        return [
          'driver_early_profit',
          'driver_fear_drawdown',
          'driver_emotion_fear',
          'driver_lower_target',
        ];
      case 'external_change':
        return [
          'driver_market_change',
          'driver_policy_change',
          'driver_other_short',
        ];
      default:
        return [];
    }
  }

  String _getDriverLabel(BuildContext context, String driver) {
    final l10n = AppLocalizations.of(context)!;
    switch (driver) {
      case 'driver_early_profit':
        return l10n.driver_early_profit;
      case 'driver_fear_drawdown':
        return l10n.driver_fear_drawdown;
      case 'driver_emotion_fear':
        return l10n.driver_emotion_fear;
      case 'driver_lower_target':
        return l10n.driver_lower_target;
      case 'driver_fomo_short':
        return l10n.driver_fomo_short;
      case 'driver_wait_confirm':
        return l10n.driver_wait_confirm;
      case 'driver_loosen_budget':
        return l10n.driver_loosen_budget;
      case 'driver_emotion_swing':
        return l10n.driver_emotion_swing;
      case 'driver_fear_continue_drop':
        return l10n.driver_fear_continue_drop;
      case 'driver_signal_insufficient':
        return l10n.driver_signal_insufficient;
      case 'driver_full_position':
        return l10n.driver_full_position;
      case 'driver_no_cash':
        return l10n.driver_no_cash;
      case 'driver_no_plan':
        return l10n.driver_no_plan;
      case 'driver_hold_at_target':
        return l10n.driver_hold_at_target;
      case 'driver_raise_target':
        return l10n.driver_raise_target;
      case 'driver_greed_hesitation':
        return l10n.driver_greed_hesitation;
      case 'driver_resist_stop':
        return l10n.driver_resist_stop;
      case 'driver_hope_rebound':
        return l10n.driver_hope_rebound;
      case 'driver_lower_stop':
        return l10n.driver_lower_stop;
      case 'driver_emotion_ignore':
        return l10n.driver_emotion_ignore;
      case 'driver_other_short':
        return l10n.driver_other_short;
      default:
        return driver;
    }
  }

  String _getStageLabel(BuildContext context, String stage) {
    final l10n = AppLocalizations.of(context)!;
    switch (stage) {
      case 'entry_deviation':
        return l10n.label_etnr_desc;
      case 'entry_non_action':
        return l10n.label_eldc_desc;
      case 'exit_non_action':
        return l10n.label_tnr_desc;
      case 'stoploss_deviation':
        return l10n.label_ldc_desc;
      case 'exit_deviation':
        return l10n.label_epc_desc;
      case 'external_change':
        return '外部环境变化';
      default:
        return stage;
    }
  }

  String _getTypeLabel(AppLocalizations l10n, String type) {
    switch (type) {
      case 'falsify':
        return l10n.type_logic_broken;
      case 'forced':
        return l10n.type_forced;
      case 'verify':
        return l10n.type_verify;
      case 'structure':
        return l10n.type_structure_change;
      default:
        return type;
    }
  }

  String _getTypeHint(AppLocalizations l10n, String type) {
    switch (type) {
      case 'falsify':
        return l10n.type_logic_broken_hint;
      case 'forced':
        return l10n.type_forced_hint;
      case 'verify':
        return l10n.type_verify_hint;
      case 'structure':
        return l10n.type_structure_change_hint;
      default:
        return '';
    }
  }

  String _getTargetLabel(AppLocalizations l10n, String target) {
    switch (target) {
      case 'buy_logic':
        return l10n.target_buy;
      case 'hold':
        return l10n.target_hold;
      case 'sell_logic':
        return l10n.target_sell;
      case 'stop_loss':
        return l10n.target_stop;
      default:
        return target;
    }
  }

  String _getSystemUnderstanding(AppLocalizations l10n, String stage) {
    switch (stage) {
      case 'entry_deviation':
        return l10n.understanding_etnr;
      case 'entry_non_action':
        return l10n.understanding_eldc;
      case 'exit_non_action':
        return l10n.understanding_tnr;
      case 'stoploss_deviation':
        return l10n.understanding_ldc;
      case 'exit_deviation':
        return l10n.understanding_epc;
      case 'external_change':
        return '记录外部环境或基本面的重大变化，这些变化可能导致原计划逻辑不再成立。';
      default:
        return '';
    }
  }

  Future<void> _submit() async {
    if (_eventStage == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.addEvent(
        widget.planId,
        AddEventRequest(
          eventType: _eventType ?? 'verify', // Fallback to verify if not set
          summary: _summaryController.text.trim(),
          impactTarget: _impactTarget ?? 'hold',
          triggeredExit: _triggeredExit,
          eventStage: _eventStage,
          behaviorDriver: _behaviorDriver,
          // 确保 entry_deviation 时，entryDriver 被正确赋值
          entryDriver: _eventStage == 'entry_deviation'
              ? _behaviorDriver
              : null,
          priceAtEvent: double.tryParse(_priceController.text),
        ),
      );
      if (!mounted) return;
      widget.onSuccess();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('添加失败: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final drivers = _eventStage != null
        ? _getDriversForStage(_eventStage!)
        : <String>[];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.title_add_event,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textWeak),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Text(
                l10n.label_event_explain,
                style: const TextStyle(fontSize: 13, color: AppColors.textWeak),
              ),
              const SizedBox(height: 24),

              // Step 1: Event Stage
              Text(
                l10n.label_event_stage_prompt,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 12),
              _buildStageSelector(l10n),
              const SizedBox(height: 24),

              if (_eventStage != null) ...[
                // Step 2: System Understanding
                _buildSystemUnderstandingCard(l10n),
                const SizedBox(height: 16),

                // Advanced Options Toggle
                Center(
                  child: TextButton.icon(
                    onPressed: () =>
                        setState(() => _showAdvanced = !_showAdvanced),
                    icon: Icon(
                      _showAdvanced ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                    ),
                    label: Text(l10n.label_adjust_explanation),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.goldMain,
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),

                if (_showAdvanced) ...[
                  const SizedBox(height: 16),
                  // Step 3: Impact Target
                  _buildSectionTitle(l10n.label_impact_target),
                  _buildImpactTargetSelector(l10n),
                  const SizedBox(height: 20),

                  // Step 4: Event Type
                  _buildSectionTitle(l10n.label_event_type),
                  _buildEventTypeSelector(l10n),
                  const SizedBox(height: 20),

                  // Triggered Exit Switch
                  if (_eventType != null && _eventType != 'verify')
                    _buildTriggeredExitSwitch(l10n),
                ],

                const SizedBox(height: 24),

                // Step 5: Behavior Driver
                _buildSectionTitle(l10n.label_behavior_driver),
                _buildDriverSelector(l10n, drivers),
                const SizedBox(height: 24),

                // Step 6: Fact Summary
                _buildSectionTitle(l10n.label_event_summary),
                TextFormField(
                  controller: _summaryController,
                  decoration: InputDecoration(
                    hintText: l10n.hint_fact_summary,
                    counterText: '${_summaryController.text.length}/40',
                  ),
                  maxLength: 40,
                  onChanged: (v) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '请填写事实摘要';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Price (Optional/Required)
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: l10n.label_price_at_event,
                    hintText:
                        (_eventStage == 'entry_deviation' ||
                            _eventStage == 'exit_deviation')
                        ? '必填 (将自动更新计划状态)'
                        : '可选',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    if ((_eventStage == 'entry_deviation' ||
                            _eventStage == 'exit_deviation') &&
                        (v == null || v.isEmpty)) {
                      return '此阶段必须填写价格以更新计划状态';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(l10n.action_back),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkGrey,
                          foregroundColor: AppColors.goldMain,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.goldMain,
                                ),
                              )
                            : Text(
                                l10n.btn_submit_event,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
        ),
      ),
    );
  }

  Widget _buildStageSelector(AppLocalizations l10n) {
    final isEntryPhase =
        widget.planStatus == 'draft' || widget.planStatus == 'armed';
    final stages = isEntryPhase
        ? ['entry_deviation', 'entry_non_action', 'external_change']
        : [
            'exit_non_action',
            'stoploss_deviation',
            'exit_deviation',
            'external_change',
          ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: stages.map((s) {
        final isSelected = _eventStage == s;
        return InkWell(
          onTap: () => _onStageSelected(s),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.goldMain.withOpacity(0.1)
                  : AppColors.card,
              border: Border.all(
                color: isSelected ? AppColors.goldMain : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getStageLabel(context, s),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.goldMain : AppColors.textMain,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _onStageSelected(String stage) {
    setState(() {
      _eventStage = stage;
      _behaviorDriver = null;
      _showAdvanced = false;

      // Default Mappings (Canonical Enums)
      switch (stage) {
        case 'entry_deviation':
          _impactTarget = 'buy_logic';
          _eventType = null; // Will be auto-set if needed, or user selects
          break;
        case 'entry_non_action':
          _impactTarget = 'buy_logic';
          _eventType = null;
          break;
        case 'exit_non_action':
          _impactTarget = 'sell_logic';
          _eventType = 'verify';
          break;
        case 'stoploss_deviation':
          _impactTarget = 'stop_loss';
          _eventType = null;
          break;
        case 'exit_deviation': // EPC
          _impactTarget = 'sell_logic';
          _eventType = null;
          break;
        case 'external_change':
          _impactTarget = 'hold';
          _eventType = 'structure';
          break;
      }
      _triggeredExit = false;
    });
  }

  Widget _buildSystemUnderstandingCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.goldLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.goldMain.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.goldDeep, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getSystemUnderstanding(l10n, _eventStage!),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.goldDeep,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactTargetSelector(AppLocalizations l10n) {
    final targets = ['buy_logic', 'hold', 'sell_logic', 'stop_loss'];
    return Wrap(
      spacing: 8,
      children: targets.map((t) {
        final isSelected = _impactTarget == t;
        return ChoiceChip(
          label: Text(_getTargetLabel(l10n, t)),
          selected: isSelected,
          onSelected: (s) => setState(() => _impactTarget = t),
          selectedColor: AppColors.goldMain,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textMain,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEventTypeSelector(AppLocalizations l10n) {
    final types = ['falsify', 'forced', 'verify', 'structure'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: types.map((t) {
        final isSelected = _eventType == t;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => setState(() {
              _eventType = t;
              if (t == 'verify') _triggeredExit = false;
            }),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.goldMain.withOpacity(0.1)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.goldMain : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 18,
                    color: isSelected ? AppColors.goldMain : AppColors.textWeak,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTypeLabel(l10n, t),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: AppColors.textMain,
                        ),
                      ),
                      Text(
                        _getTypeHint(l10n, t),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textWeak,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTriggeredExitSwitch(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '触发退出条件',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              Switch(
                value: _triggeredExit,
                onChanged: (v) => setState(() => _triggeredExit = v),
                activeColor: Colors.orange,
              ),
            ],
          ),
          Text(
            l10n.label_triggered_exit_hint,
            style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverSelector(AppLocalizations l10n, List<String> drivers) {
    if (drivers.isEmpty)
      return const Text(
        '无可用驱动',
        style: TextStyle(fontSize: 12, color: AppColors.textWeak),
      );
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: drivers.map((d) {
        final isSelected = _behaviorDriver == d;
        return ChoiceChip(
          label: Text(_getDriverLabel(context, d)),
          selected: isSelected,
          onSelected: (s) => setState(() => _behaviorDriver = s ? d : null),
          selectedColor: AppColors.goldDeep,
          labelStyle: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : AppColors.textMain,
          ),
        );
      }).toList(),
    );
  }
}

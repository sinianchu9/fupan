import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/theme.dart';
import '../../../models/close_plan_request.dart';

class CloseTradeSheet extends ConsumerStatefulWidget {
  final String planId;
  final String status;
  final VoidCallback onSuccess;

  const CloseTradeSheet({
    super.key,
    required this.planId,
    required this.status,
    required this.onSuccess,
  });

  @override
  ConsumerState<CloseTradeSheet> createState() => _CloseTradeSheetState();
}

class _CloseTradeSheetState extends ConsumerState<CloseTradeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _postExitPriceController = TextEditingController();
  final _targetPriceController = TextEditingController();
  String _sellReason = 'follow_plan';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _priceController.dispose();
    _postExitPriceController.dispose();
    _targetPriceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.closePlan(
        widget.planId,
        ClosePlanRequest(
          sellPrice: double.parse(_priceController.text),
          sellReason: _sellReason,
          postExitBestPrice: double.tryParse(_postExitPriceController.text),
          exitPlanTargetPrice: double.tryParse(_targetPriceController.text),
        ),
      );
      if (!mounted) return;
      widget.onSuccess();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e.toString();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('提交失败: $errorMsg')));
      if (errorMsg.contains('already closed')) {
        widget.onSuccess();
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '结算交易',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '请录入实际成交数据，系统将自动审计执行偏差。',
                style: TextStyle(fontSize: 13, color: AppColors.textWeak),
              ),
              const SizedBox(height: 20),
              if (widget.status == 'draft')
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '计划尚未武装（未建仓），此时结算将被系统判定为“无计划交易”。',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              _buildSectionTitle('成交价格'),
              TextFormField(
                controller: _priceController,
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  labelText: '实际卖出价',
                  hintText: '0.00',
                  prefixIcon: Icon(
                    Icons.currency_yuan,
                    color: AppColors.goldMain,
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return '必填';
                  final val = double.tryParse(v);
                  if (val == null || val <= 0) return '请输入有效价格';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('卖出原因'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildReasonChip('follow_plan', '按计划执行'),
                  _buildReasonChip('stop_loss', '严格止损'),
                  _buildReasonChip('fear', '害怕/犹豫'),
                  _buildReasonChip('panic', '恐慌出逃'),
                  _buildReasonChip('external', '外力干扰'),
                  _buildReasonChip('other', '其他'),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('EPC 审计补全 (可选)'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBlock,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _postExitPriceController,
                      decoration: const InputDecoration(
                        labelText: '卖出后观察期最优价',
                        hintText: '用于计算 EPC 机会成本',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _targetPriceController,
                      decoration: const InputDecoration(
                        labelText: '原计划卖出目标价',
                        hintText: '若原计划未设定，可在此补填',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '确认结算并关闭计划',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
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
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.goldMain,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildReasonChip(String value, String label) {
    final isSelected = _sellReason == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (s) {
        if (s) setState(() => _sellReason = value);
      },
      selectedColor: AppColors.goldMain,
      backgroundColor: AppColors.secondaryBlock,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppColors.goldMain : AppColors.border,
        ),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}

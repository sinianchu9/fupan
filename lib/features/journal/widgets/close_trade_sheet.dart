import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '结束交易（卖出）',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (widget.status == 'draft')
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '计划未武装，系统可能判为无计划',
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: '实际卖出价',
                  border: OutlineInputBorder(),
                  prefixText: '¥ ',
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
              const SizedBox(height: 20),
              const Text(
                '卖出原因',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildReasonRadio('follow_plan', '按计划执行'),
              _buildReasonRadio('fear', '害怕/犹豫'),
              _buildReasonRadio('panic', '恐慌'),
              _buildReasonRadio('external', '外力干扰'),
              _buildReasonRadio('other', '其他'),
              const SizedBox(height: 20),
              const Text(
                'EPC 数据补全（可选）',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _postExitPriceController,
                decoration: const InputDecoration(
                  labelText: '卖出后观察期最优价',
                  hintText: '用于计算 EPC 成本',
                  border: OutlineInputBorder(),
                  prefixText: '¥ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _targetPriceController,
                decoration: const InputDecoration(
                  labelText: '原计划卖出目标价',
                  hintText: '若原计划未设定，可在此补填',
                  border: OutlineInputBorder(),
                  prefixText: '¥ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '确认结束交易',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReasonRadio(String value, String label) {
    return InkWell(
      onTap: () => setState(() => _sellReason = value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _sellReason,
              onChanged: (v) {
                if (v != null) {
                  setState(() => _sellReason = v);
                }
              },
              visualDensity: VisualDensity.compact,
            ),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

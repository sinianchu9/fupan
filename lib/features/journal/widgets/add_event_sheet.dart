import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../models/add_event_request.dart';

class AddEventSheet extends ConsumerStatefulWidget {
  final String planId;
  final VoidCallback onSuccess;

  const AddEventSheet({
    super.key,
    required this.planId,
    required this.onSuccess,
  });

  @override
  ConsumerState<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends ConsumerState<AddEventSheet> {
  final _formKey = GlobalKey<FormState>();
  final _summaryController = TextEditingController();

  String _eventType = 'falsify';
  String _impactTarget = 'buy_logic';
  bool _triggeredExit = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.addEvent(
        widget.planId,
        AddEventRequest(
          eventType: _eventType,
          summary: _summaryController.text.trim(),
          impactTarget: _impactTarget,
          triggeredExit: _triggeredExit,
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
                '新增事件',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              const Text(
                '事件类型',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildTypeChip('falsify', '逻辑证伪'),
                  _buildTypeChip('forced', '强制扰动'),
                  _buildTypeChip('verify', '验证/兑现'),
                  _buildTypeChip('structure', '市场结构变化'),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                '影响对象',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildImpactChip('buy_logic', '买入逻辑'),
                  _buildImpactChip('sell_logic', '卖出逻辑'),
                  _buildImpactChip('stop_loss', '止损'),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _summaryController,
                decoration: InputDecoration(
                  labelText: '事件摘要',
                  hintText: '描述发生了什么（最多40字）',
                  border: const OutlineInputBorder(),
                  counterText: '${_summaryController.text.length}/40',
                ),
                maxLength: 40,
                onChanged: (v) => setState(() {}),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '不能为空' : null,
              ),
              const SizedBox(height: 8),

              SwitchListTile(
                title: const Text('是否触发退出条件', style: TextStyle(fontSize: 14)),
                subtitle: const Text(
                  '此事件是否意味着你应该执行卖出/止损',
                  style: TextStyle(fontSize: 12),
                ),
                value: _triggeredExit,
                onChanged: (v) => setState(() => _triggeredExit = v),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.blue,
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
                          '提交事件',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String value, String label) {
    final isSelected = _eventType == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _eventType = value);
      },
      selectedColor: Colors.blue,
    );
  }

  Widget _buildImpactChip(String value, String label) {
    final isSelected = _impactTarget == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _impactTarget = value);
      },
      selectedColor: Colors.indigo,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fupan/l10n/generated/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../models/plan_detail.dart';

class ReviseTargetSheet extends ConsumerStatefulWidget {
  final PlanDetail plan;
  final VoidCallback onSuccess;

  const ReviseTargetSheet({
    super.key,
    required this.plan,
    required this.onSuccess,
  });

  @override
  ConsumerState<ReviseTargetSheet> createState() => _ReviseTargetSheetState();
}

class _ReviseTargetSheetState extends ConsumerState<ReviseTargetSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _lowController;
  late final TextEditingController _highController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _lowController = TextEditingController(
      text: widget.plan.targetLow.toString(),
    );
    _highController = TextEditingController(
      text: widget.plan.targetHigh.toString(),
    );
  }

  @override
  void dispose() {
    _lowController.dispose();
    _highController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      final low = double.parse(_lowController.text);
      final high = double.parse(_highController.text);

      await apiClient.updatePlan(widget.plan.id, {
        'target_low': low,
        'target_high': high,
      });

      if (!mounted) return;
      widget.onSuccess();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('修订失败: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              Text(
                l10n.title_revise_target,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lowController,
                      decoration: InputDecoration(
                        labelText: l10n.label_target_low,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? l10n.tip_required : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _highController,
                      decoration: InputDecoration(
                        labelText: l10n.label_target_high,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return l10n.tip_required;
                        final high = double.tryParse(v);
                        final low = double.tryParse(_lowController.text);
                        if (high != null && low != null && high <= low) {
                          return l10n.tip_greater_than_low;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.action_confirm),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

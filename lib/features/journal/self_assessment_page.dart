import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fupan/l10n/generated/app_localizations.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../models/self_review.dart';

class SelfAssessmentPage extends ConsumerStatefulWidget {
  final String planId;
  final bool isReadOnly;
  final Map<String, int>? initialScores;

  const SelfAssessmentPage({
    super.key,
    required this.planId,
    this.isReadOnly = false,
    this.initialScores,
  });

  @override
  ConsumerState<SelfAssessmentPage> createState() => _SelfAssessmentPageState();
}

class _SelfAssessmentPageState extends ConsumerState<SelfAssessmentPage> {
  final Map<String, int> _scores = {};
  String? _expandedId;
  bool _isSubmitting = false;
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialScores != null) {
      _scores.addAll(widget.initialScores!);
    }
  }

  int get _completedCount => _scores.length;
  bool get _isComplete => _completedCount == 13;

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_isComplete) {
      setState(() => _showErrors = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.tip_complete_all)));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.submitSelfReview(widget.planId, _scores);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.tip_submit_success)));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.tip_submit_failed(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dimensions = DimensionDef.all;
    final stages = dimensions.map((e) => e.stage).toSet().toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.title_self_assessment)),
      body: Column(
        children: [
          _buildProgressIndicator(context),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              itemCount: stages.length,
              itemBuilder: (context, index) {
                final stage = stages[index];
                final stageDimensions = dimensions
                    .where((e) => e.stage == stage)
                    .toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 4,
                        bottom: 12,
                        top: 8,
                      ),
                      child: Text(
                        stage,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    ...stageDimensions.map(
                      (d) => _buildDimensionCard(context, d),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
          if (!widget.isReadOnly) _buildSubmitButton(context),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _completedCount / 13,
                minHeight: 6,
                backgroundColor: AppColors.background,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.goldMain,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            l10n.label_completed_count(_completedCount),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionCard(BuildContext context, DimensionDef dim) {
    final l10n = AppLocalizations.of(context)!;
    final score = _scores[dim.key];
    final isError = _showErrors && score == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError ? Colors.red : AppColors.border,
          width: 1,
        ),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dim.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMain,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _expandedId = _expandedId == dim.key ? null : dim.key;
                        });
                      },
                      child: Text(
                        _expandedId == dim.key
                            ? l10n.action_hide_details
                            : l10n.action_view_detail,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [1, 2, 3].map((s) {
                    final isSelected = score == s;
                    return Expanded(
                      child: GestureDetector(
                        onTap: widget.isReadOnly
                            ? null
                            : () => setState(() => _scores[dim.key] = s),
                        child: Container(
                          margin: EdgeInsets.only(right: s < 3 ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.goldLight.withAlpha(50)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.goldMain
                                  : AppColors.border,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              s.toString(),
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.goldDeep
                                    : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (score != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBlock,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      dim.shortAnchors[score] ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_expandedId == dim.key)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.secondaryBlock,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [1, 2, 3].map((s) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$s: ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.textMain,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            dim.fullDetails[s] ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.card,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.goldMain,
                      ),
                    ),
                  )
                : Text(l10n.action_submit),
          ),
        ),
      ),
    );
  }
}

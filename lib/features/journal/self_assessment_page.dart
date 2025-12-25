import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
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
  final Set<String> _expandedKeys = {};
  bool _isSubmitting = false;

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
    if (!_isComplete || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.submitSelfReview(widget.planId, _scores);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('评估提交成功')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('提交失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = DimensionDef.all;
    final stages = dimensions.map((e) => e.stage).toSet().toList();

    return Scaffold(
      appBar: AppBar(title: const Text('自我评估')),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
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
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        stage,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                    ...stageDimensions.map((d) => _buildDimensionCard(d)),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
          if (!widget.isReadOnly) _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _completedCount / 13,
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '已完成 $_completedCount/13',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionCard(DimensionDef d) {
    final score = _scores[d.key];
    final isExpanded = _expandedKeys.contains(d.key);
    final hasError = !widget.isReadOnly && score == null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: hasError
            ? BorderSide(color: Colors.orange.withOpacity(0.5), width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${d.key.toUpperCase()} ${d.title}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _buildSegmentedControl(d),
              ],
            ),
            if (score != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  d.shortAnchors[score]!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedKeys.remove(d.key);
                    } else {
                      _expandedKeys.add(d.key);
                    }
                  });
                },
                icon: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                ),
                label: const Text('查看细则', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            if (isExpanded) ...[
              const Divider(),
              ...[1, 2, 3].map(
                (s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: score == s
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.outline.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$s',
                          style: TextStyle(
                            fontSize: 10,
                            color: score == s ? Colors.white : null,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          d.fullDetails[s]!,
                          style: TextStyle(
                            fontSize: 13,
                            color: score == s ? null : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl(DimensionDef d) {
    final score = _scores[d.key];

    return CupertinoSegmentedControl<int>(
      children: const {
        1: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('1'),
        ),
        2: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('2'),
        ),
        3: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('3'),
        ),
      },
      groupValue: score,
      onValueChanged: widget.isReadOnly
          ? (val) {} // Dummy callback for read-only
          : (int val) {
              setState(() => _scores[d.key] = val);
            },
      unselectedColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primary,
      borderColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isComplete && !_isSubmitting ? _submit : null,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const CupertinoActivityIndicator()
                : const Text(
                    '提交评估',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PlanDetailPlaceholderPage extends StatelessWidget {
  final String planId;
  const PlanDetailPlaceholderPage({super.key, required this.planId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('计划详情')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('计划 ID: $planId', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            const Text(
              '详情页逻辑将在 Step 3 实现',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}

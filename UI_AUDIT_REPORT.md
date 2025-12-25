I. 总览

- 审查页面数量: 10
- 组件数量(Widget 类): 18
- 高风险问题数量(P0): 3
- 中风险问题数量(P1): 13
- 低风险问题数量(P2/P3): 12

II. 问题清单（按严重度排序）

Severity: P0
页面/组件：LoginPage
文件路径 + 行号范围：lib/features/auth/login_page.dart:L51-L96
复现条件：小屏 320x568 + 键盘弹出 + 文本缩放 1.3x/1.6x
现象：键盘顶起后底部按钮被遮挡，无法点击发送；部分文本被挤出屏幕
根因分析：页面主体为 Column 且无滚动容器、无 SafeArea、未处理键盘内边距
修复建议：用 SafeArea + SingleChildScrollView 包裹内容，并添加 padding=MediaQuery.viewInsets；或改为 ListView
可直接粘贴的代码 patch：
```diff
--- a/lib/features/auth/login_page.dart
+++ b/lib/features/auth/login_page.dart
@@
-    return Scaffold(
-      appBar: AppBar(title: Text(l10n.title_login)),
-      body: Padding(
-        padding: const EdgeInsets.all(24.0),
-        child: Column(
+    return Scaffold(
+      appBar: AppBar(title: Text(l10n.title_login)),
+      body: SafeArea(
+        child: SingleChildScrollView(
+          padding: EdgeInsets.only(
+            left: 24,
+            right: 24,
+            top: 24,
+            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
+          ),
+          child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             crossAxisAlignment: CrossAxisAlignment.stretch,
             children: [
@@
-        ),
+          ],
+        ),
+      ),
     );
```

Severity: P0
页面/组件：VerifyOtpPage
文件路径 + 行号范围：lib/features/auth/verify_otp_page.dart:L59-L103
复现条件：小屏 320x568 + 键盘弹出 + 文本缩放 1.3x/1.6x
现象：验证码输入框/按钮被键盘遮挡，用户无法完成验证
根因分析：Column 直排、无滚动、无键盘内边距处理
修复建议：同 LoginPage，使用 SafeArea + SingleChildScrollView + viewInsets.bottom
可直接粘贴的代码 patch：
```diff
--- a/lib/features/auth/verify_otp_page.dart
+++ b/lib/features/auth/verify_otp_page.dart
@@
-    return Scaffold(
-      appBar: AppBar(title: Text(l10n.title_verify_otp)),
-      body: Padding(
-        padding: const EdgeInsets.all(24.0),
-        child: Column(
+    return Scaffold(
+      appBar: AppBar(title: Text(l10n.title_verify_otp)),
+      body: SafeArea(
+        child: SingleChildScrollView(
+          padding: EdgeInsets.only(
+            left: 24,
+            right: 24,
+            top: 24,
+            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
+          ),
+          child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             crossAxisAlignment: CrossAxisAlignment.stretch,
             children: [
@@
-        ),
+          ],
+        ),
+      ),
     );
```

Severity: P0
页面/组件：PlanDetailPage（自带 _CloseTradeSheet）
文件路径 + 行号范围：lib/features/journal/plan_detail_page.dart:L488-L535
复现条件：小屏 + 键盘弹出 + 文本缩放 1.3x/1.6x
现象：BottomSheet 内容被键盘遮挡，提交按钮不可见；可能出现“Bottom overflowed by ...”
根因分析：BottomSheet 仅 Column + padding，缺少滚动容器与 SafeArea
修复建议：用 SingleChildScrollView 包裹 + SafeArea + viewInsets 底部 padding
可直接粘贴的代码 patch：
```diff
--- a/lib/features/journal/plan_detail_page.dart
+++ b/lib/features/journal/plan_detail_page.dart
@@
-    return Padding(
-      padding: EdgeInsets.only(
-        bottom: MediaQuery.of(context).viewInsets.bottom,
-        left: 20,
-        right: 20,
-        top: 20,
-      ),
-      child: Column(
+    return SafeArea(
+      child: SingleChildScrollView(
+        padding: EdgeInsets.only(
+          left: 20,
+          right: 20,
+          top: 20,
+          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
+        ),
+        child: Column(
           mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
@@
-      ),
+        ],
+        ),
+      ),
     );
```

Severity: P1
页面/组件：OnboardingWatchlistPage（整页布局）
文件路径 + 行号范围：lib/features/onboarding/onboarding_watchlist_page.dart:L223-L457
复现条件：小屏 + 英文文案 + 1.3x/1.6x
现象：底部“进入应用”按钮可能被系统手势条/安全区遮挡；顶部说明与搜索框在小屏紧凑导致竖向溢出
根因分析：根布局为 Column，底部按钮未包 SafeArea；顶部内容无滚动
修复建议：底部按钮加 SafeArea，整体改为 CustomScrollView 或将 Column 改为 Expanded+ListView 结构
可直接粘贴的代码 patch：
```diff
--- a/lib/features/onboarding/onboarding_watchlist_page.dart
+++ b/lib/features/onboarding/onboarding_watchlist_page.dart
@@
-          if (!widget.isStandalone)
-            Padding(
-              padding: const EdgeInsets.all(16.0),
-              child: SizedBox(
-                width: double.infinity,
-                height: 50,
-                child: ElevatedButton(
+          if (!widget.isStandalone)
+            SafeArea(
+              top: false,
+              child: Padding(
+                padding: const EdgeInsets.all(16.0),
+                child: SizedBox(
+                  width: double.infinity,
+                  height: 50,
+                  child: ElevatedButton(
@@
-              ),
-            ),
+                ),
+              ),
+            ),
```

Severity: P1
页面/组件：OnboardingWatchlistPage（已添加列表区域的删除按钮）
文件路径 + 行号范围：lib/features/onboarding/onboarding_watchlist_page.dart:L375-L395
复现条件：小屏 + 1.6x + 手势操作
现象：删除按钮 Icon 点击区域不足 48x48，易误触/点不到
根因分析：GestureDetector + Icon 无最小尺寸约束
修复建议：用 IconButton 或 SizedBox+InkResponse，提供 48x48 的 hit area
可直接粘贴的代码 patch：
```diff
-                            GestureDetector(
-                              onTap: () => _removeFromWatchlist(item),
-                              child: const Icon(
-                                Icons.close,
-                                size: 16,
-                                color: Colors.grey,
-                              ),
-                            ),
+                            SizedBox(
+                              width: 48,
+                              height: 48,
+                              child: IconButton(
+                                icon: const Icon(
+                                  Icons.close,
+                                  size: 16,
+                                  color: Colors.grey,
+                                ),
+                                onPressed: () => _removeFromWatchlist(item),
+                                padding: EdgeInsets.zero,
+                              ),
+                            ),
```

Severity: P1
页面/组件：JournalListPage（顶部 Row）
文件路径 + 行号范围：lib/features/journal/journal_list_page.dart:L89-L131
复现条件：小屏 + 英文 + textScale 1.6x
现象：右侧“新建计划”按钮与左侧分数区域挤压，Row 溢出或按钮被压缩到不可点
根因分析：Row 子项无弹性布局限制，按钮宽度不受控
修复建议：为按钮加 ConstrainedBox + Flexible 并允许换行/缩放；或把按钮移到下一行
可直接粘贴的代码 patch：
```diff
-                  ElevatedButton.icon(
+                  Flexible(
+                    child: ConstrainedBox(
+                      constraints: const BoxConstraints(minHeight: 40),
+                      child: ElevatedButton.icon(
                         onPressed: () async {
@@
-                    label: Text(l10n.action_create_plan),
-                  ),
+                        label: Text(
+                          l10n.action_create_plan,
+                          overflow: TextOverflow.ellipsis,
+                        ),
+                      ),
+                    ),
+                  ),
```

Severity: P1
页面/组件：ArchivedPlansPage（卡片头部 Row）
文件路径 + 行号范围：lib/features/journal/archived_plans_page.dart:L125-L141
复现条件：小屏 + 英文 + textScale 1.3x+
现象：标题 + 状态徽章 + 菜单按钮 Row 可能溢出
根因分析：右侧两个固定组件占宽，标题未设置 maxLines/overflow
修复建议：标题 Text 加 maxLines/ellipsis；右侧菜单用 SizedBox 约束
可直接粘贴的代码 patch：
```diff
-                  Expanded(
-                    child: Text(
-                      '${plan.symbolCode} ${plan.symbolName}',
-                      style: const TextStyle(
-                        fontSize: 16,
-                        fontWeight: FontWeight.bold,
-                      ),
-                    ),
-                  ),
+                  Expanded(
+                    child: Text(
+                      '${plan.symbolCode} ${plan.symbolName}',
+                      maxLines: 1,
+                      overflow: TextOverflow.ellipsis,
+                      style: const TextStyle(
+                        fontSize: 16,
+                        fontWeight: FontWeight.bold,
+                      ),
+                    ),
+                  ),
```

Severity: P1
页面/组件：PlanDetailPage（summary card 顶部 Row）
文件路径 + 行号范围：lib/features/journal/plan_detail_page.dart:L150-L165
复现条件：小屏 + 英文 + textScale 1.3x+
现象：股票名 + 状态徽章一行溢出
根因分析：标题未限制行数，徽章占固定宽
修复建议：标题加 maxLines/ellipsis；徽章加 FittedBox 或约束最小宽
可直接粘贴的代码 patch：
```diff
-                Expanded(
-                  child: Text(
-                    '${plan.symbolCode} ${plan.symbolName}',
-                    style: const TextStyle(
-                      fontSize: 20,
-                      fontWeight: FontWeight.w600,
-                      color: AppColors.textMain,
-                    ),
-                  ),
-                ),
+                Expanded(
+                  child: Text(
+                    '${plan.symbolCode} ${plan.symbolName}',
+                    maxLines: 1,
+                    overflow: TextOverflow.ellipsis,
+                    style: const TextStyle(
+                      fontSize: 20,
+                      fontWeight: FontWeight.w600,
+                      color: AppColors.textMain,
+                    ),
+                  ),
+                ),
```

Severity: P1
页面/组件：PlanDetailPage（_buildTimeInfo Row）
文件路径 + 行号范围：lib/features/journal/plan_detail_page.dart:L178-L185
复现条件：小屏横屏 + 1.3x/1.6x
现象：左右时间列并排溢出/被挤压
根因分析：Row 内两个 Column 直接放置，未限制宽度
修复建议：改为 Wrap 或左右 Column 包 Expanded 并允许换行
可直接粘贴的代码 patch：
```diff
-            Row(
-              mainAxisAlignment: MainAxisAlignment.spaceBetween,
-              children: [
-                _buildTimeInfo(context, l10n.label_create, plan.createdAt),
-                _buildTimeInfo(context, l10n.label_update, plan.updatedAt),
-              ],
-            ),
+            Wrap(
+              spacing: 24,
+              runSpacing: 8,
+              children: [
+                _buildTimeInfo(context, l10n.label_create, plan.createdAt),
+                _buildTimeInfo(context, l10n.label_update, plan.updatedAt),
+              ],
+            ),
```

Severity: P1
页面/组件：PlanDetailPage（_buildDetailRow 标签列）
文件路径 + 行号范围：lib/features/journal/plan_detail_page.dart:L320-L342
复现条件：英文 + textScale 1.3x/1.6x
现象：左侧 label 固定宽度 80，英文较长时溢出/断行不合理
根因分析：硬编码宽度导致多语言不适配
修复建议：使用 IntrinsicWidth 或 Expanded + maxLines/ellipsis；或用 ConstrainedBox+Flexible
可直接粘贴的代码 patch：
```diff
-          SizedBox(
-            width: 80,
-            child: Text(
-              label,
-              style: const TextStyle(color: AppColors.textWeak, fontSize: 13),
-            ),
-          ),
+          ConstrainedBox(
+            constraints: const BoxConstraints(minWidth: 72, maxWidth: 120),
+            child: Text(
+              label,
+              maxLines: 2,
+              overflow: TextOverflow.ellipsis,
+              style: const TextStyle(color: AppColors.textWeak, fontSize: 13),
+            ),
+          ),
```

Severity: P1
页面/组件：PlanDetailPage（动作区按钮）
文件路径 + 行号范围：lib/features/journal/plan_detail_page.dart:L347-L392
复现条件：小屏 + 英文 + textScale 1.6x
现象：按钮 label 被截断或溢出
根因分析：固定高度 + icon+text 无换行策略
修复建议：对 label 加 maxLines/ellipsis，或用 Flexible 包裹 Text
可直接粘贴的代码 patch：
```diff
-                label: Text(l10n.action_close_trade),
+                label: Flexible(
+                  child: Text(
+                    l10n.action_close_trade,
+                    maxLines: 1,
+                    overflow: TextOverflow.ellipsis,
+                  ),
+                ),
```

Severity: P1
页面/组件：PlanCompareCard（标题 Row）
文件路径 + 行号范围：lib/features/journal/widgets/plan_compare_card.dart:L27-L39
复现条件：小屏 + 英文 + textScale 1.3x+
现象：标题+副标题同 Row，长文案溢出
根因分析：Row 内两个 Text，无 Expanded/Wrap
修复建议：改为 Column，或使用 Expanded 包裹副标题并设置 maxLines/ellipsis
可直接粘贴的代码 patch：
```diff
-            Row(
-              children: [
-                const Text(
-                  '对照状态',
-                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
-                ),
-                const SizedBox(width: 8),
-                Text(
-                  '只显示事实，不提供建议',
-                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
-                ),
-              ],
-            ),
+            Column(
+              crossAxisAlignment: CrossAxisAlignment.start,
+              children: [
+                const Text(
+                  '对照状态',
+                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
+                ),
+                const SizedBox(height: 4),
+                Text(
+                  '只显示事实，不提供建议',
+                  maxLines: 2,
+                  overflow: TextOverflow.ellipsis,
+                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
+                ),
+              ],
+            ),
```

Severity: P1
页面/组件：PlanCompareCard（状态行）
文件路径 + 行号范围：lib/features/journal/widgets/plan_compare_card.dart:L114-L142
复现条件：英文 + 1.3x/1.6x
现象：右侧 value 与左侧 label 挤压，文字重叠或溢出
根因分析：Row 中 label 无 Expanded，value 固定对齐
修复建议：用 Expanded 包 label，value 用 FittedBox 或 Flexible
可直接粘贴的代码 patch：
```diff
-          Text(label, style: const TextStyle(fontSize: 13)),
-          const Spacer(),
-          Text(
+          Expanded(
+            child: Text(label, style: const TextStyle(fontSize: 13)),
+          ),
+          Text(
             value,
             style: TextStyle(
               fontSize: 13,
               fontWeight: FontWeight.bold,
               color: color,
             ),
           ),
```

Severity: P1
页面/组件：EventsTimelineCard（标题 Row + 按钮）
文件路径 + 行号范围：lib/features/journal/widgets/events_timeline_card.dart:L29-L45
复现条件：小屏 + 英文 + textScale 1.3x+
现象：标题与“新增事件”按钮互相挤压，按钮不可点
根因分析：Row 内 TextButton 未限制宽度
修复建议：将标题 Expanded；按钮 label 限制 maxLines/ellipsis
可直接粘贴的代码 patch：
```diff
-                const Text(
-                  '事件线',
-                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
-                ),
+                const Expanded(
+                  child: Text(
+                    '事件线',
+                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
+                  ),
+                ),
@@
-                    label: const Text('新增事件'),
+                    label: const Text(
+                      '新增事件',
+                      maxLines: 1,
+                      overflow: TextOverflow.ellipsis,
+                    ),
```

Severity: P1
页面/组件：ResultCard（结果行）
文件路径 + 行号范围：lib/features/journal/widgets/result_card.dart:L97-L110
复现条件：小屏 + 英文 + 1.3x/1.6x
现象：label/value 同行溢出、value 被裁切
根因分析：Row 两端对齐，未限制文本长度
修复建议：用 Expanded 包 label，value 用 Flexible + maxLines/ellipsis
可直接粘贴的代码 patch：
```diff
-      child: Row(
-        mainAxisAlignment: MainAxisAlignment.spaceBetween,
-        children: [
-          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
-          Text(
-            value,
-            style: TextStyle(
-              fontSize: 13,
-              fontWeight: isJudgement ? FontWeight.bold : FontWeight.normal,
-              color: valueColor,
-            ),
-          ),
-        ],
-      ),
+      child: Row(
+        children: [
+          Expanded(
+            child: Text(
+              label,
+              style: const TextStyle(color: Colors.grey, fontSize: 13),
+            ),
+          ),
+          Flexible(
+            child: Text(
+              value,
+              maxLines: 1,
+              overflow: TextOverflow.ellipsis,
+              style: TextStyle(
+                fontSize: 13,
+                fontWeight: isJudgement ? FontWeight.bold : FontWeight.normal,
+                color: valueColor,
+              ),
+            ),
+          ),
+        ],
+      ),
```

Severity: P1
页面/组件：WeeklyReportPage（报告值文本）
文件路径 + 行号范围：lib/features/stats/weekly_report_page.dart:L141-L169
复现条件：小屏 + 英文 + 1.3x/1.6x
现象：PCS/偏离类型文本长度过长时溢出；结论文字可撑开导致布局过密
根因分析：Text 未设置 maxLines/overflow，字号固定
修复建议：为短值加 maxLines=1；长文本使用 maxLines 和 overflow; 可基于 textScaleFactor 下调字号
可直接粘贴的代码 patch：
```diff
-        Text(
-          value,
-          style: TextStyle(
+        Text(
+          value,
+          maxLines: isLongText ? 4 : 1,
+          overflow: TextOverflow.ellipsis,
+          style: TextStyle(
             fontSize: isLongText ? 15 : 32,
             fontWeight: isLongText ? FontWeight.normal : FontWeight.bold,
             color: isLongText
                 ? AppColors.textSecondary
                 : (isGold ? AppColors.goldMain : AppColors.textMain),
             height: isLongText ? 1.5 : 1.2,
           ),
         ),
```

Severity: P1
页面/组件：CreatePlanPage（表单 Row/Wrap 部分）
文件路径 + 行号范围：lib/features/journal/create_plan_page.dart:L256-L295、L405-L425
复现条件：小屏 + 英文 + textScale 1.3x+
现象：双列输入框 Row 溢出；长 label/Chip 超出屏幕
根因分析：Row 固定布局 + Wrap 未限制 chip 文本
修复建议：Row 改为 Column（小屏时）或用 LayoutBuilder 控制；Chip 文本用 maxLines/ellipsis
可直接粘贴的代码 patch：
```diff
-            Row(
-              children: [
-                Expanded(
-                  child: TextFormField(
+            LayoutBuilder(
+              builder: (context, constraints) {
+                final isNarrow = constraints.maxWidth < 360;
+                return isNarrow
+                    ? Column(
+                        children: [
+                          TextFormField(
                             controller: _targetLowController,
@@
-                ),
-                const SizedBox(width: 16),
-                Expanded(
-                  child: TextFormField(
+                          const SizedBox(height: 12),
+                          TextFormField(
                             controller: _targetHighController,
@@
-                ),
-              ],
-            ),
+                        ],
+                      )
+                    : Row(
+                        children: [
+                          Expanded(child: ...),
+                          const SizedBox(width: 16),
+                          Expanded(child: ...),
+                        ],
+                      );
+              },
+            ),
```

Severity: P1
页面/组件：AddEventSheet（SwitchListTile 标题）
文件路径 + 行号范围：lib/features/journal/widgets/add_event_sheet.dart:L133-L142
复现条件：小屏 + 英文 + textScale 1.3x+
现象：标题过长导致 SwitchListTile 高度爆增或溢出
根因分析：标题未设置 softWrap/maxLines
修复建议：将 title/subtitle 包成 Text 并设置 maxLines/overflow，或用 ListTile 且 dense
可直接粘贴的代码 patch：
```diff
-              SwitchListTile(
-                title: const Text('是否触发退出条件', style: TextStyle(fontSize: 14)),
-                subtitle: const Text(
+              SwitchListTile(
+                title: const Text(
+                  '是否触发退出条件',
+                  maxLines: 2,
+                  overflow: TextOverflow.ellipsis,
+                  style: TextStyle(fontSize: 14),
+                ),
+                subtitle: const Text(
                   '此事件是否意味着你应该执行卖出/止损',
-                  style: TextStyle(fontSize: 12),
+                  maxLines: 2,
+                  overflow: TextOverflow.ellipsis,
+                  style: TextStyle(fontSize: 12),
                 ),
```

Severity: P2
页面/组件：MainShell（NavigationBar）
文件路径 + 行号范围：lib/features/shell/main_shell.dart:L45-L65
复现条件：小屏 + 英文 + textScale 1.3x+
现象：底部导航文字可能被截断；按钮点击区略窄
根因分析：NavigationDestination label 长度未限制
修复建议：缩短英文文案或使用 responsive label；确保 nav bar 有足够高度
可直接粘贴的代码 patch：
```diff
-          NavigationDestination(
-            icon: const Icon(Icons.edit_note),
-            label: l10n.label_nav_journal,
-          ),
+          NavigationDestination(
+            icon: const Icon(Icons.edit_note),
+            label: l10n.label_nav_journal_short,
+          ),
```

Severity: P2
页面/组件：SelfAssessmentPage（评分按钮组）
文件路径 + 行号范围：lib/features/journal/self_assessment_page.dart:L217-L256
复现条件：小屏 + 1.6x
现象：三个评分块横排挤压，文字可能溢出
根因分析：Row 内 Expanded 固定横排；文本缩放后空间不足
修复建议：改为 Wrap 或使用 LayoutBuilder 在小屏下切换为两行
可直接粘贴的代码 patch：
```diff
-                Row(
-                  children: [1, 2, 3].map((s) {
+                Wrap(
+                  spacing: 8,
+                  runSpacing: 8,
+                  children: [1, 2, 3].map((s) {
                     final isSelected = score == s;
-                    return Expanded(
-                      child: GestureDetector(
+                    return SizedBox(
+                      width: 72,
+                      child: GestureDetector(
                         onTap: widget.isReadOnly
@@
-                    );
+                    );
                   }).toList(),
                 ),
```

Severity: P2
页面/组件：PlanDetailPlaceholderPage
文件路径 + 行号范围：lib/features/journal/plan_detail_placeholder_page.dart:L11-L28
复现条件：小屏 + 1.6x
现象：固定字号标题可能溢出；长 ID 换行不佳
根因分析：Text 未设置 maxLines/overflow
修复建议：ID Text 加 maxLines/ellipsis
可直接粘贴的代码 patch：
```diff
-            Text('计划 ID: $planId', style: const TextStyle(color: Colors.grey)),
+            Text(
+              '计划 ID: $planId',
+              maxLines: 1,
+              overflow: TextOverflow.ellipsis,
+              style: const TextStyle(color: Colors.grey),
+            ),
```

Severity: P2
页面/组件：OnboardingWatchlistPage（搜索结果 ListTile）
文件路径 + 行号范围：lib/features/onboarding/onboarding_watchlist_page.dart:L321-L333
复现条件：英文长 symbol/name + textScale 1.3x+
现象：ListTile 标题/副标题溢出
根因分析：Text 未限制 maxLines/overflow
修复建议：title/subtitle 加 maxLines/ellipsis
可直接粘贴的代码 patch：
```diff
-                        title: Text('${symbol.code} ${symbol.name}'),
-                        subtitle: Text(symbol.industry),
+                        title: Text(
+                          '${symbol.code} ${symbol.name}',
+                          maxLines: 1,
+                          overflow: TextOverflow.ellipsis,
+                        ),
+                        subtitle: Text(
+                          symbol.industry,
+                          maxLines: 1,
+                          overflow: TextOverflow.ellipsis,
+                        ),
```

Severity: P2
页面/组件：ResultCard（结论文本）
文件路径 + 行号范围：lib/features/journal/widgets/result_card.dart:L44-L59
复现条件：1.6x + 长文本
现象：结论文本高度过大导致页面滚动过长
根因分析：Text 无 maxLines 限制
修复建议：加 maxLines 与 "展开"（可选）；或在 card 内折叠
可直接粘贴的代码 patch：
```diff
-              child: Text(
-                result.conclusionText,
-                style: const TextStyle(
-                  fontSize: 15,
-                  fontWeight: FontWeight.w500,
-                  height: 1.4,
-                ),
-              ),
+              child: Text(
+                result.conclusionText,
+                maxLines: 4,
+                overflow: TextOverflow.ellipsis,
+                style: const TextStyle(
+                  fontSize: 15,
+                  fontWeight: FontWeight.w500,
+                  height: 1.4,
+                ),
+              ),
```

Severity: P3
页面/组件：Theme 对比度
文件路径 + 行号范围：lib/core/theme.dart:L52-L60
复现条件：暗色背景/设备高对比
现象：按钮前景色与背景对比不足（darkGrey + goldMain）
根因分析：统一颜色未考虑 WCAG 对比
修复建议：提高前景色对比或根据主题调整颜色
可直接粘贴的代码 patch：
```diff
-          foregroundColor: AppColors.goldMain,
+          foregroundColor: Colors.white,
```

Severity: P3
页面/组件：WeeklyReportPage（空态容器）
文件路径 + 行号范围：lib/features/stats/weekly_report_page.dart:L58-L76
复现条件：小屏 + 1.6x
现象：空态提示占用过多空间，挤压核心内容
根因分析：固定 margin/padding
修复建议：在小屏减少 padding 或用 SizedBox.shrink
可直接粘贴的代码 patch：
```diff
-                    Container(
-                      padding: const EdgeInsets.all(16),
-                      margin: const EdgeInsets.only(bottom: 24),
+                    Container(
+                      padding: const EdgeInsets.all(12),
+                      margin: const EdgeInsets.only(bottom: 12),
```

Severity: P3
页面/组件：CloseTradeSheet（Radio 列表）
文件路径 + 行号范围：lib/features/journal/widgets/close_trade_sheet.dart:L174-L195
复现条件：小屏 + textScale 1.6x
现象：单行 radio 文案拥挤
根因分析：Row + Text 无换行
修复建议：Text 增加 Flexible + maxLines
可直接粘贴的代码 patch：
```diff
-            Text(label, style: const TextStyle(fontSize: 14)),
+            Flexible(
+              child: Text(
+                label,
+                maxLines: 2,
+                overflow: TextOverflow.ellipsis,
+                style: const TextStyle(fontSize: 14),
+              ),
+            ),
```

Severity: P3
页面/组件：MainShell（AppBar 右侧 IconButton）
文件路径 + 行号范围：lib/features/shell/main_shell.dart:L27-L41
复现条件：小屏 + 高 textScale
现象：AppBar 图标可点击区未明确（默认 OK，但建议统一）
根因分析：依赖默认 IconButton 尺寸
修复建议：无需强制修改（无明显问题）
可直接粘贴的代码 patch：无（无明显问题）

III. 通用修复策略（可批量替换）

- overflow 通用模式：Row 内 Text 一律加 Expanded + maxLines + overflow；右侧 value 用 Flexible
- 点击区域统一封装：小图标使用 SizedBox(48) + IconButton 或 InkResponse，避免 GestureDetector 小点击
- 键盘遮挡统一处理：页面使用 SafeArea + SingleChildScrollView + padding(viewInsets.bottom)
- 多语言长度策略：所有标题/按钮/标签 Text 加 maxLines=1~2 + TextOverflow.ellipsis；长段落加 maxLines=4
- 暗色对比策略：主题中按钮前景色用白色或高对比；边框在暗色背景需更深或加阴影
- 列表嵌套：ListView inside Column 必须 shrinkWrap + NeverScrollableScrollPhysics 或改为 CustomScrollView

IV. 建议新增的自动化测试

示例 widget tests（至少 3 个）
1) 列表页：JournalListPage
- 断言：小屏+大字无 RenderFlex overflow
2) 表单页：CreatePlanPage
- 断言：键盘弹出时按钮可滚动可见
3) 弹窗页：CloseTradeSheet / AddEventSheet
- 断言：大字 + 小屏无 bottom overflow

示例目录结构：
- test/ui/journal_list_page_test.dart
- test/ui/create_plan_page_test.dart
- test/ui/close_trade_sheet_test.dart
- test/golden/
  - journal_list_page_golden_test.dart
  - weekly_report_page_golden_test.dart

建议命令：
- flutter test
- flutter test --update-goldens
- flutter test test/golden

# 复盘 (Fupan) - 工程交接与技术文档

## 1. 项目概述

“复盘”是一个基于 Flutter 开发的专业交易日志与计划管理应用。其核心理念是“先计划，再交易”，通过强制性的武装流程和客观的系统判定，帮助交易者强化纪律，减少情绪化交易。

## 2. 技术栈

- **前端框架**: Flutter (Latest Stable)
- **状态管理**: Riverpod (ConsumerStatefulWidget / Provider)
- **网络请求**: Dio (封装于 `ApiClient`)
- **本地存储**: `shared_preferences` (用于 `UserSession`)
- **日期处理**: `intl`
- **后端架构**: Cloudflare Workers + SQLite (D1)

## 3. 核心模块与功能

### 3.1 关注列表 (Watchlist & Onboarding)

- **路径**: `lib/features/onboarding/`
- **功能**: 用户首次进入时选择关注的股票/标的。支持种子数据注入。
- **关键组件**: `OnboardingWatchlistPage`

### 3.2 交易复盘 (Journal Module)

- **路径**: `lib/features/journal/`
- **流程**:
  1. **新建计划** (`CreatePlanPage`): 录入买入逻辑、目标区间、止损条件。
  2. **武装计划** (`PlanDetailPage` -> `armPlan`): 录入实际入场价，计划进入“持仓”状态，逻辑锁定。
  3. **过程记录** (`EventsTimelineCard`): 记录影响计划的外部事件（证伪、验证、结构变化）。
  4. **结束交易** (`CloseTradeSheet`): 录入卖出价和原因。
  5. **系统判定** (`ResultCard`): 系统根据计划执行情况给出“按计划执行”或“情绪干扰”的判定。

### 3.3 归档系统 (Archive)

- **功能**: 将已结束或不再关注的计划从主列表移出。
- **路径**: `lib/features/journal/archived_plans_page.dart`
- **逻辑**: 归档后的计划在详情页变为只读，隐藏所有编辑和事件添加功能。

## 4. 核心数据模型 (`lib/models/`)

- `PlanListItem`: 列表简略信息，包含 `isArchived` 状态。
- `PlanDetail`: 详情全量数据，包含买入/卖出逻辑数组。
- `TradeEvent`: 事件线记录，包含 `triggeredExit` 判定。
- `TradeResult`: 交易结束后的系统判定结果。
- **注意**: 所有模型均包含 `_parseBool` 静态助手，用于兼容后端返回的 `int` (0/1) 或 `String` 类型的布尔值。

## 5. API 契约 (`lib/core/api/api_client.dart`)

- 基础路径配置在 `ApiClient` 中。
- 自动注入 `X-User-Id` 请求头（从 `UserSession` 获取）。
- **主要接口**:
  - `getPlans()`: 获取未归档计划。
  - `getArchivedPlans()`: 获取已归档计划。
  - `armPlan(planId, entryPrice)`: 武装计划。
  - `closePlan(planId, req)`: 结束交易。
  - `archivePlan(planId)` / `unarchivePlan(planId)`: 归档操作。

## 6. UI/UX 规范

- **深色模式适配**: 全量支持深色模式。
- **对比度优化**:
  - 使用 `withValues(alpha: ...)` 替代已弃用的 `withAlpha`。
  - 关键操作（如“结束交易”）使用 `ElevatedButton` 以增强辨识度。
  - 卡片使用边框 (`BorderSide`) 增强层级感。
- **只读逻辑**: 计划结束后，详情页自动隐藏编辑入口。

## 7. 当前进度与后续计划

- [x] Step 1-5: 核心交易流（新建、武装、事件、结果判定）已完成。
- [x] 归档功能: 已完成。
- [x] UI 优化: 已完成深色模式高对比度适配。
- [ ] **Step 6 (Next)**: 周报统计模块。需要聚合一周内的交易判定，生成纪律得分。

## 8. 开发注意事项

1. **类型安全**: 后端 D1 数据库布尔值存储为 `int`，解析时必须使用 `_parseBool`。
2. **Context 安全**: 在异步操作（API 请求）后使用 `context` 前，务必检查 `if (!mounted) return;`。
3. **严肃性**: 计划一旦“武装”或“结束”，UI 应严格限制修改权限。

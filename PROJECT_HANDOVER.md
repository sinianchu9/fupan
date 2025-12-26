# 复盘 (Fupan) - 工程交接与技术文档

## 1. 项目概述

“复盘”是一个基于 Flutter 开发的专业交易日志与计划管理应用。其核心理念是“先计划，再交易”，通过强制性的建仓流程、客观的系统判定以及多维度的自我评估，帮助交易者强化纪律，减少情绪化交易。

## 2. 技术栈

- **前端框架**: Flutter (Latest Stable)
- **状态管理**: Riverpod (ConsumerStatefulWidget / Provider)
- **国际化 (i18n)**: Flutter Localizations (ARB based) + `localeProvider` (Riverpod)
- **网络请求**: Dio (封装于 `ApiClient`)
- **本地存储**: `shared_preferences` (用于 `UserSession` 和 `user_locale`)
- **日期处理**: `intl`
- **后端架构**: Cloudflare Workers + TypeScript
- **数据库**: Cloudflare D1 (SQLite)
- **邮件服务**: Resend API (用于发送验证码)

## 3. 核心模块与功能

### 3.1 身份验证与安全 (Auth & Security)

- **流程**: 邮箱 OTP (一次性密码) 登录。
- **安全特性**:
  - **Salt/Pepper**: 验证码哈希使用用户邮箱作为 Salt，服务器 `JWT_SECRET` 作为 Pepper。
  - **频率限制**: 同一邮箱 60 秒内只能请求一次 OTP。
  - **即时失效**: 验证码验证成功后立即失效。
  - **尝试限制**: 5 次验证失败后锁定。
  - **无日志**: 后端不记录任何验证码明文。

### 3.2 交易复盘流 (Journal Module)

1. **新建计划** (`CreatePlanPage`): 录入买入逻辑、目标区间、止损条件。
2. **建仓/武装** (`PlanDetailPage`): 录入实际入场价，计划进入“已建仓”状态，逻辑锁定。
3. **过程记录** (`EventsTimelineCard`): **[重构]** 记录结构化事件，包含阶段、驱动因素和价格。
4. **结束交易** (`_CloseTradeSheet`): **[增强]** 录入卖出价、原因，并可补全 EPC 计算所需的观察期最优价和原计划目标价。
5. **系统判定** (`ResultCard`): 系统根据计划执行情况给出判定，并计算 EPC 成本。
6. **自我评估** (`SelfAssessmentPage`): 结项后强制进行的 13 维度量化自评。

### 3.3 13 维自我评估系统

- **维度设计**: 涵盖买入前、持仓中、卖出执行、盘后总结四个阶段。
- **交互特性**:
  - **动态锚点**: 1/2/3 分数对应不同的短句描述。
  - **进度追踪**: 顶部显示进度条。
  - **折叠细则**: 默认收起评分标准。

### 3.4 国际化与语言切换 (i18n & Language Switch)

- **架构**: Flutter 官方 ARB 方案 + Riverpod。
- **支持语言**: 简体中文 (`zh`)、美式英语 (`en`)。
- **持久化**: 使用 `SharedPreferences` 存储用户偏好。

### 3.5 EPC (Early Profit Cut) 指标系统 [新增]

- **定义**: 衡量提前卖出带来的机会成本。
- **计算逻辑**:
  - `epc_opportunity_pct = (post_exit_best_price - exit_actual_price) / exit_actual_price`。
  - **失效条件**: 若卖出是由“计划失效”类事件（`triggered_exit = 1`）触发，则不计入 EPC。
- **UI 展示**: 在 `CalmConclusionCard` 中以“刺痛点”形式展示，并在周报中统计发生率和平均成本。
  PCS ｜计划一致性
  E-TNR ｜买入追高成本
  E-LDC ｜低位不执行成本
  TNR ｜到位不卖
  LDC ｜止损拖延
  EPC ｜提前卖出成本

### 3.6 结构化事件系统 [重构]

- **目的**: 将零散记录转变为可分析的行为数据。
- **核心字段**:
  - **事件阶段 (`event_stage`)**: 建仓偏移、建仓未执行、卖出执行偏移、止损执行偏移、外部环境变化。
  - **行为驱动 (`behavior_driver`)**: FOMO、无法承受回撤、情绪性恐惧、临时降低目标等。
  - **价格锚点**: 记录事件发生时的价格。

## 4. UI/UX 规范与审计修复

- **设计风格**: “暗金奢华”风格。
- **响应式优化**: 解决了键盘遮挡、文本溢出、点击区域过小等问题。

## 5. 核心数据模型 (`lib/models/`)

- `PlanListItem`: 包含 `isArchived` 状态。
- `PlanDetail`: 增加 `exitPlanTargetPrice`。
- `TradeResult`: 增加 `postExitBestPrice` 和 `epcOpportunityPct`。
- `TradeEvent`: 增加 `eventStage`, `behaviorDriver`, `priceAtEvent`, `triggeredExit`。

## 6. 后端 API 契约 (`workers/src/index.ts`)

- `POST /plans/:id/close`: 接收 `sell_price`, `sell_reason`, `post_exit_best_price`, `exit_plan_target_price`。
- `POST /plans/:id/add-event`: 接收结构化事件字段。
- `GET /report/weekly`: 返回包含 EPC 统计（发生率、平均值）的周报数据。

## 7. 数据库架构 (`workers/schema.sql`)

- `trade_plans`: 增加 `exit_plan_target_price`。
- `trade_events`: 增加 `event_stage`, `behavior_driver`, `price_at_event`。
- `trade_results`: 增加 `post_exit_best_price`, `epc_opportunity_pct`。

## 8. 开发注意事项

1. **严肃性原则**: 计划一旦锁定，限制修改。
2. **EPC 计算**: 后端负责核心计算，前端负责数据补全。
3. **i18n 同步**: 修改文案需同步更新中英文 ARB 并运行 `flutter gen-l10n`。

## 9. 当前进度

- [x] 核心交易流与系统判定。
- [x] 13 维自评系统。
- [x] 邮箱验证码登录。
- [x] 全量国际化 (i18n)。
- [x] **EPC 指标系统**: 完成后端计算、前端展示及数据补全。
- [x] **结构化事件系统**: 完成事件维度重构与 UI 集成。
- [x] **周报统计**: 集成 EPC 统计项。

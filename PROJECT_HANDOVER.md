# 复盘 (Fupan) - 工程交接与技术文档

## 1. 项目概述

“复盘”是一个基于 Flutter 开发的专业交易日志与计划管理应用。其核心理念是“先计划，再交易”，通过强制性的武装流程、客观的系统判定以及多维度的自我评估，帮助交易者强化纪律，减少情绪化交易。

## 2. 技术栈

- **前端框架**: Flutter (Latest Stable)
- **状态管理**: Riverpod (ConsumerStatefulWidget / Provider)
- **网络请求**: Dio (封装于 `ApiClient`)
- **本地存储**: `shared_preferences` (用于 `UserSession`)
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
2. **武装计划** (`PlanDetailPage`): 录入实际入场价，计划进入“持仓”状态，逻辑锁定。
3. **过程记录** (`EventsTimelineCard`): 记录影响计划的外部事件（证伪、验证、结构变化）。
4. **结束交易** (`CloseTradeSheet`): 录入卖出价和原因。
5. **系统判定** (`ResultCard`): 系统根据计划执行情况给出“按计划执行”或“情绪干扰”的判定。
6. **自我评估** (`SelfAssessmentPage`): **[核心增强]** 结项后强制进行的 13 维度量化自评。

### 3.3 13 维自我评估系统

- **维度设计**: 涵盖买入前、持仓中、卖出执行、盘后总结四个阶段。
- **交互特性**:
  - **动态锚点**: 1/2/3 分数对应不同的短句描述，实时切换。
  - **进度追踪**: 顶部显示“已完成 x/13”进度条。
  - **折叠细则**: 默认收起详细评分标准，保持界面整洁。
  - **只读模式**: 提交后不可修改，作为永久交易记录。

## 4. 核心数据模型 (`lib/models/`)

- `PlanListItem`: 列表简略信息，包含 `isArchived` 状态。
- `PlanDetail`: 详情全量数据。
- `SelfReview`: **[新]** 存储 13 个维度的评分数据。
- `DimensionDef`: **[新]** 静态定义 13 个维度的文案、阶段和评分标准。
- `TradeResult`: 交易结束后的系统判定结果。

## 5. 后端 API 契约 (`workers/src/index.ts`)

- **认证**: `Authorization: Bearer <JWT>`。
- **关键接口**:
  - `POST /auth/request-otp`: 请求验证码（集成 Resend）。
  - `POST /auth/verify-otp`: 验证并返回 JWT。
  - `POST /reviews/self`: 提交 13 维自评（带状态硬校验）。
  - `GET /reviews/self/:plan_id`: 获取已有的自评结果。

## 6. 数据库架构 (`workers/schema.sql`)

- `trade_plans`: 存储计划核心数据。
- `trade_results`: 存储交易结项后的系统判定。
- `trade_self_reviews`: **[新]** 存储 13 维自评数据，通过 `(user_id, plan_id)` 唯一约束确保复盘的严肃性。

## 7. 开发注意事项

1. **严肃性原则**: 计划一旦“武装”或“结束”，UI 和后端应严格限制修改权限。自评系统是结项后的必经环节。
2. **类型转换**: D1 数据库布尔值存储为 `int`，前端解析需使用 `_parseBool` 助手。
3. **安全合规**: 严禁在后端代码中添加任何打印敏感信息（如 OTP、Token）的 `console.log`。
4. **异步安全**: 在 Flutter 异步操作后使用 `context` 前，务必检查 `if (!mounted) return;`。

## 8. 当前进度

- [x] 核心交易流与系统判定。
- [x] 13 维自评系统（前端交互 + 后端校验）。
- [x] 邮箱验证码登录（Resend 集成 + 安全加固）。
- [ ] **Next**: 周报统计模块 (Weekly Report) 的深度数据聚合。

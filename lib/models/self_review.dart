class SelfReview {
  final String id;
  final String userId;
  final String planId;
  final String resultId;
  final Map<String, int> scores;
  final int schemaVersion;
  final DateTime createdAt;

  SelfReview({
    required this.id,
    required this.userId,
    required this.planId,
    required this.resultId,
    required this.scores,
    required this.schemaVersion,
    required this.createdAt,
  });

  factory SelfReview.fromJson(Map<String, dynamic> json) {
    final scores = <String, int>{};
    final dimensions = [
      'd1',
      'd2',
      'd3',
      'd4',
      'h1',
      'h2',
      'h3',
      'h4',
      'e1',
      'e2',
      'e3',
      'r1',
      'r2',
    ];
    for (var d in dimensions) {
      scores[d] = json[d] as int;
    }

    return SelfReview(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      planId: json['plan_id'] as String,
      resultId: json['result_id'] as String,
      scores: scores,
      schemaVersion: json['schema_version'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['created_at'] as int) * 1000,
      ),
    );
  }
}

class DimensionDef {
  final String key;
  final String title;
  final String stage;
  final Map<int, String> shortAnchors;
  final Map<int, String> fullDetails;

  DimensionDef({
    required this.key,
    required this.title,
    required this.stage,
    required this.shortAnchors,
    required this.fullDetails,
  });

  static List<DimensionDef> get all => [
    // 阶段一：买入前
    DimensionDef(
      key: 'd1',
      title: '买入逻辑清晰度',
      stage: '阶段一：买入前',
      shortAnchors: {1: '说不清，只剩感觉/价格', 2: '有原因，但逻辑松散', 3: '一句话可复述，条件明确'},
      fullDetails: {
        1: '只能复述“涨了/跌了/想抄底/感觉要起”，无条件描述',
        2: '有关键词（题材/指标/消息），但触发条件不明确',
        3: '能说出“在什么条件下买/为什么买/触发点是什么”',
      },
    ),
    DimensionDef(
      key: 'd2',
      title: '预期与失效边界',
      stage: '阶段一：买入前',
      shortAnchors: {1: '无目标，也无失效条件', 2: '只有目标或只有止损', 3: '目标与失效条件都清晰'},
      fullDetails: {
        1: '没有明确目标位或止损位（或写了但不可执行）',
        2: '二者缺其一，导致无法判定何时退出',
        3: '目标与止损/失效条件同时存在且可执行',
      },
    ),
    DimensionDef(
      key: 'd3',
      title: '环境一致性认知',
      stage: '阶段一：买入前',
      shortAnchors: {1: '没考虑大盘/行业/节奏', 2: '知道不一致，但仍介入', 3: '匹配环境，或清楚自知逆势'},
      fullDetails: {
        1: '完全未提及环境因素或风险背景',
        2: '承认逆风/逆势，但没有对应的仓位/退出安排',
        3: '说明环境匹配逻辑；若逆势，明确“我在赌什么 + 退路”',
      },
    ),
    DimensionDef(
      key: 'd4',
      title: '买入时情绪状态',
      stage: '阶段一：买入前',
      shortAnchors: {1: '焦虑/FOMO/报复性驱动', 2: '有波动，但仍可控', 3: '冷静，可延迟决策'},
      fullDetails: {
        1: '怕错过、怕踏空、想翻本、情绪推动下单',
        2: '紧张但能延迟下单或按流程检查',
        3: '不急于成交，能等待条件确认',
      },
    ),
    // 阶段二：持仓中
    DimensionDef(
      key: 'h1',
      title: '是否按原计划持有',
      stage: '阶段二：持仓中',
      shortAnchors: {1: '频繁改计划/临时加减仓', 2: '小幅调整，但不改核心逻辑', 3: '严格按原计划执行'},
      fullDetails: {
        1: '多次修改条件、随意加仓摊平、随意减仓止痒',
        2: '调整细节（如分批），但仍围绕原触发条件',
        3: '持仓动作与原计划一致，无临时改口',
      },
    ),
    DimensionDef(
      key: 'h2',
      title: '情绪波动强度',
      stage: '阶段二：持仓中',
      shortAnchors: {1: '高频盯盘/明显焦虑', 2: '偶尔波动', 3: '情绪稳定'},
      fullDetails: {
        1: '频繁刷新、坐立不安，决策受波动影响',
        2: '会紧张，但能恢复到计划框架',
        3: '能把波动当噪音，不改变动作',
      },
    ),
    DimensionDef(
      key: 'h3',
      title: '信息依赖与验证行为',
      stage: '阶段二：持仓中',
      shortAnchors: {1: '刷消息为自己辩护', 2: '被动接收信息', 3: '主动屏蔽噪音'},
      fullDetails: {1: '不断找利好/观点来证明自己对', 2: '看信息但不形成行动依据', 3: '只看与计划条件直接相关的信息'},
    ),
    DimensionDef(
      key: 'h4',
      title: '纪律破坏点',
      stage: '阶段二：持仓中',
      shortAnchors: {1: '破坏纪律且没记录原因', 2: '破坏纪律但能说明原因', 3: '无纪律破坏'},
      fullDetails: {
        1: '发生加仓/扛单/提前卖等行为，但无记录',
        2: '承认破坏点，并写清触发原因',
        3: '无破戒动作，或有冲动但未执行且有记录',
      },
    ),
    // 阶段三：卖出当下
    DimensionDef(
      key: 'e1',
      title: '卖出动机匹配度',
      stage: '阶段三：卖出当下',
      shortAnchors: {1: '恐慌/贪婪/外界刺激', 2: '部分符合原逻辑', 3: '完全按预设条件卖出'},
      fullDetails: {1: '因为情绪或他人观点触发卖出', 2: '有一部分条件吻合，但执行点偏离', 3: '卖出触发点与原计划一致'},
    ),
    DimensionDef(
      key: 'e2',
      title: '执行果断性',
      stage: '阶段三：卖出当下',
      shortAnchors: {1: '反复修改/犹豫拖延', 2: '短暂犹豫后执行', 3: '一次性执行'},
      fullDetails: {1: '改来改去、拖到错过条件', 2: '犹豫但没有改动核心决策', 3: '触发即执行，不反复试探'},
    ),
    DimensionDef(
      key: 'e3',
      title: '卖出后的即时心理反应',
      stage: '阶段三：卖出当下',
      shortAnchors: {1: '后悔/想立刻追回', 2: '波动但可接受', 3: '平静接受结果'},
      fullDetails: {
        1: '强烈不甘、立刻想再进场',
        2: '有情绪，但不会驱动下一笔冲动交易',
        3: '能接受结果，不急于证明自己',
      },
    ),
    // 阶段四：事后复盘
    DimensionDef(
      key: 'r1',
      title: '主要问题定位准确性',
      stage: '阶段四：事后复盘',
      shortAnchors: {1: '泛泛而谈/归因模糊', 2: '能定位阶段，但不具体', 3: '定位到阶段 + 具体行为'},
      fullDetails: {
        1: '只写“心态不好/不够理性/运气差”，无具体行为',
        2: '能说“买入/持仓/卖出有问题”，但说不出具体动作',
        3: '明确“哪个阶段 + 哪个动作/决策”导致偏离',
      },
    ),
    DimensionDef(
      key: 'r2',
      title: '可执行改进点',
      stage: '阶段四：事后复盘',
      shortAnchors: {1: '抽象口号，不可执行', 2: '方向对，但不够操作化', 3: '具体、可验证、可复用'},
      fullDetails: {
        1: '如“更谨慎/更理性/少冲动”',
        2: '如“少看盘”，但没给可验证规则',
        3: '给出明确规则（条件/频率/触发）且下次可直接照做',
      },
    ),
  ];
}

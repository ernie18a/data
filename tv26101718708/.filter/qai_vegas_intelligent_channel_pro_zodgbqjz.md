# QAI Vegas Intelligent Channel Pro

- url: https://www.tradingview.com/script/ZoDgBqJz/
- type: indicator
- pine_id: PUB;85f6c28979f04c3bbc4b0b1e8ea92d9d
- version: 13.0

## Description

Introduction & User Manual QAI Vegas Intelligent Channel Pro

Autumn AI · Vegas Intelligent Channel Pro
Type: Pure Technical Analysis Reference Indicator (NOT a Strategy)

1. Introduction

QAI Vegas Intelligent Channel Pro is a professional-grade, multi-timeframe, multi-layered technical analysis reference indicator developed by the Autumn AI team. Built around the classic Vegas Tunnel (144/169 EMA) as its core framework, it integrates short-term (21/55), medium-term (288/338), and long-term (576/676) EMA channels, an advanced VWAP system with deviation bands, Bollinger Bands breakout logic, and comprehensive divergence detection across four major oscillators: RSI, MACD, KDJ, and Stochastic (both regular and hidden divergence).

Important Disclaimer (Please Read Carefully):

This indicator is designed exclusively as a visual reference tool and decision-support indicator. It is NOT a trading strategy and does NOT generate any automated buy/sell signals. All bubble labels, info panel readings, divergence alerts, and overall recommendations are provided for informational and analytical purposes only. Traders must combine this tool with their own independent market analysis, strict risk management, and personal trading plan. Past performance is not indicative of future results. Trading carries substantial risk of loss.

2. Key Features

Multi-layered EMA channel system (Short / Mid / Long + Vegas Tunnel) with optional MTF for Vegas
Advanced VWAP system (Daily/Session reset + multi-SD bands + minimum distance filter)
Quad-oscillator divergence confluence (RSI + MACD + KDJ + Stochastic)
Bollinger Bands Squeeze & Expansion breakout assistance
Real-time Info Panel (original detailed 2-column 24-row layout)
5-minute auto-expiring bubble labels for breakouts, divergences, and strong signals
Full visibility controls (one-click show/hide for all channels)
Native TradingView dynamic alert system (trend change, strong signals, various divergences, etc.)

3、Recommended Default Settings

Source: close (recommended)
Visibility Controls: All on by default; when screen space is limited, keep only Vegas Tunnel + Filter Line + Info Panel
VWAP: Enable and keep useVWAPFilter = true
Bollinger Breakout: Enabled by default as auxiliary confirmation
Buy/Sell Arrows: Disabled by default (showArrows = false)

Core Reference Workflow (Practical Guide)

Start with Vegas Tunnel: Price above upper band + bullish tunnel alignment → bullish bias reference; below lower band + bearish alignment → bearish bias reference
Filter Line Confirmation: Price must be above/below EMA12 Filter for valid trend consideration
Channel Confluence: Short channel breakout + Vegas alignment + mid/long-term direction agreement = significantly stronger reference
Divergence Confluence: Multiple oscillators showing bullish/bearish divergence simultaneously = key reversal/continuation reference point
VWAP & Bollinger Assistance: Price far from VWAP + Bollinger expansion breakout = enhanced reference strength
Info Panel Quick Overview: Instant view of channel prices, distance %, indicator status, and overall recommendation
Bubble Labels: Real-time visual alerts that auto-delete after 5 minutes for clean charting

Info Panel Explanation
The panel uses the original detailed layout (2 columns, 24 rows) and displays:

Real-time prices and directional suggestions for all channels
Vegas distance percentage, VWAP/ATR, current price
Individual status for RSI, MACD, KDJ, Stochastic, Bollinger Bands, and Volume
Overall Recommendation and Trend at the bottom

4. Risk Disclaimer

Once again, this is strictly a reference indicator and NOT a trading strategy.
Autumn AI and the indicator developer assume no responsibility for any trading losses incurred from using this tool. Always practice proper position sizing, strict stop-loss discipline, and trade only within your personal risk tolerance.

## Source Code

````pine
//@version=6
indicator(title="秋AI-Vegas智能共振信息情报流 / QAI · Vegas Intelligent Confluence Market Intelligence Stream", 
     shorttitle="秋AI-Vegas智能共振信息情报流 / QAI · Vegas Intelligent Confluence Market Intelligence Stream", 
     overlay=true, 
     max_bars_back=5000, 
     max_labels_count=500, 
     max_boxes_count=500, 
     max_lines_count=500)

// ============================================================
// 【安全布尔函数】
// ============================================================
f_and(a, b) => bool(a) and bool(b)

// ============================================================
groupSrc = "数据源 / Data Source"
src = input.source(close, title="数据源 / Data Source", group=groupSrc, tooltip="【指标内容科普】\n数据源是所有技术指标计算的基础价格数据，所有通道、结构、Delta等情报均基于此计算。\n\n【新手提示】\n这是整个指标的‘心脏’。加密货币永续合约默认使用close即可获得最真实的市场情报。\n\n【实战建议】\n始终保持默认close，除非您有特定需求（如使用hlc3观察机构公平价值）。")

groupVis = "显示控制 / Visibility Controls"
showInfoPanel = input.bool(false, "显示悬浮信息面板 / Show Floating Info Panel", group=groupVis, tooltip="【指标内容科普】\n实时悬浮面板显示全部核心市场情报（共振分数、Delta压力、SMC结构、通道位置等）。\n\n【新手提示】\n面板是本指标‘大脑’，建议始终开启以一目了然掌握市场当前状态。\n\n【实战建议】\nTop Right位置几乎不遮挡K线，是最佳情报阅读位置。")

panelPosition = input.string("Top Right", "信息面板位置 / Info Panel Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=groupVis, tooltip="【指标内容科普】\n控制信息面板在图表上的显示位置，支持四角自由切换。\n\n【新手提示】\nTop Right是大多数专业交易者推荐的位置，不会干扰主图K线阅读。\n\n【实战建议】\n根据您的图表布局选择，避免遮挡关键价格区域。")

showDeltaPressureLine = input.bool(false, "显示Delta压力线 / Show Delta Pressure Line", group=groupVis, tooltip="【指标内容科普】\nDelta压力线是CVD的20期SMA，向上代表买方资金流入压力增强。\n\n【新手提示】\n默认关闭，仅在需要深度订单流情报时开启。\n\n【实战建议】\n专业订单流分析时开启，可直观看到资金真实买卖压力变化。")

showFilter = input.bool(true, "显示过滤线 / Show Filter", group=groupVis, tooltip="【指标内容科普】\nEMA12过滤线用于快速判断整体趋势方向。\n\n【新手提示】\n价格在过滤线上方=整体多头结构，下方=整体空头结构。\n\n【实战建议】\n强烈建议始终开启，作为多空基础结构过滤情报。")

showShort = input.bool(true, "显示短期通道 / Show Short Channel", group=groupVis, tooltip="【指标内容科普】\n短期通道（21/55）适合捕捉短期市场结构变化。\n\n【新手提示】\n短期通道更敏感，适合观察日内/短线结构转折。\n\n【实战建议】\n新手可开启观察短期趋势强度变化。")

showVegas = input.bool(true, "显示Vegas隧道 / Show Vegas Tunnel", group=groupVis, tooltip="【指标内容科普】\nVegas隧道（144/169）是本指标中期趋势核心情报区域。\n\n【新手提示】\nVegas隧道是判断中期市场结构的关键通道。\n\n【实战建议】\n强烈建议始终开启，作为中期趋势情报核心。")

showMid = input.bool(true, "显示中期通道 / Show Mid Channel", group=groupVis, tooltip="【指标内容科普】\n中期通道（288/338）用于判断中期趋势强度和结构稳健度。\n\n【新手提示】\n中期通道提供更稳健的市场结构确认情报。\n\n【实战建议】\n波段观察者强烈推荐开启。")

showLong = input.bool(true, "显示长期通道 / Show Long Channel", group=groupVis, tooltip="【指标内容科普】\n长期通道（576/676）代表大趋势方向和整体市场结构。\n\n【新手提示】\n长期通道作为最外层趋势过滤器，提供宏观结构情报。\n\n【实战建议】\n始终开启作为大方向市场结构判断。")

groupSMCLine = "SMC结构永久画线 / SMC Structure Permanent Lines"
showSMCLines = input.bool(false, "显示SMC结构线 / Show SMC Structure Lines", group=groupSMCLine, tooltip="【指标内容科普】\n为BOS、CHOCH、MSS、Breaker Block、Liquidity Sweep绘制永久水平线，便于观察结构变化。\n\n【新手提示】\n开启后关键结构会以虚线形式永久显示在图表上。\n\n【实战建议】\n强烈推荐开启，极大提升结构可视化效果。")

colBOSLine = input.color(color.new(#00FF9D, 0), "BOS结构线颜色 / BOS Line Color", group=groupSMCLine)
colCHOCHLine = input.color(color.new(#FFD700, 0), "CHOCH结构线颜色 / CHOCH Line Color", group=groupSMCLine)
colMSSLine = input.color(color.new(#FF6B6B, 0), "MSS结构线颜色 / MSS Line Color", group=groupSMCLine)
colBreakerLine = input.color(color.new(#9B59B6, 0), "Breaker Block线颜色 / Breaker Line Color", group=groupSMCLine)
colLiquidityLine = input.color(color.new(#E74C3C, 0), "Liquidity Sweep线颜色 / Liquidity Line Color", group=groupSMCLine)

groupBubble = "气泡优化 / Bubble Optimization"
showBubbles = input.bool(false, "显示实时智能气泡 / Show Real-time Smart Bubbles", group=groupBubble, tooltip="【指标内容科普】\n控制所有实时气泡提示的开关。\n\n【新手提示】\n关闭后将不再弹出任何气泡。\n\n【实战建议】\n默认关闭以保持图表清爽，需观察实时结构信号时手动开启。")
bubbleLifetimeBars = input.int(150, "气泡保留柱数 / Bubble Lifetime (bars)", minval=50, maxval=500, group=groupBubble, tooltip="气泡显示多久后自动清理（默认150根K线）")

groupMTF = "多时间框架 / Multi Timeframe"
useMTF = input.bool(false, "启用Vegas隧道MTF / Enable MTF for Vegas", group=groupMTF, tooltip="【指标内容科普】\nMTF可参考更高时间框架的Vegas隧道市场结构。\n\n【新手提示】\n开启后Vegas隧道将使用更高时间框架数据提供更稳健的情报。\n\n【实战建议】\n波段交易者强烈推荐开启，日内交易者建议关闭以提升速度。")

mtfTimeframe = input.timeframe("240", "Vegas MTF 时间框架 / MTF Timeframe", group=groupMTF, tooltip="【指标内容科普】\nMTF时间框架决定参考趋势的周期长度。\n\n【新手提示】\n选择更高时间框架作为Vegas参考结构情报。\n\n【实战建议】\n240分钟（4小时）是加密货币常用框架。")

groupBB = "布林带通道 / Bollinger Bands (Breakout Strategy)"
showBB = input.bool(false, "显示布林带通道 / Show Bollinger Bands", group=groupBB, tooltip="【指标内容科普】\n布林带用于判断波动率收缩与扩张，是市场结构突破的情报核心工具。\n\n【新手提示】\n是否显示布林带通道。\n\n【实战建议】\n适合判断波动率收缩与扩张，新手可开启观察。")

bbLength = input.int(20, "布林带周期 / BB Length", minval=1, group=groupBB, tooltip="【指标内容科普】\n20周期是布林带经典设置。\n\n【新手提示】\n设置布林带计算周期。\n\n【实战建议】\n20周期是经典设置。")

bbMult = input.float(2.0, "布林带倍数 / BB Multiplier", minval=0.1, group=groupBB, tooltip="【指标内容科普】\n2.0倍是标准倍数。\n\n【新手提示】\n设置布林带标准差倍数。\n\n【实战建议】\n2.0倍是标准设置。")

bbSqueezeThreshold = input.float(1.5, "Squeeze挤压阈值 / Squeeze Threshold", minval=0.5, group=groupBB, tooltip="【指标内容科普】\n挤压阈值判断低波动期。\n\n【新手提示】\n设置布林带挤压（低波动）的阈值。\n\n【实战建议】\n当带宽低于此值时，市场进入低波动期。")

bbExpansionThreshold = input.float(3.0, "Expansion扩张阈值 / Expansion Threshold", minval=1.0, group=groupBB, tooltip="【指标内容科普】\n扩张阈值判断高波动期。\n\n【新手提示】\n设置布林带扩张（高波动）的阈值。\n\n【实战建议】\n当带宽高于此值时，市场波动剧烈。")

colBBLine = input.color(color.orange, "布林带线条颜色 / BB Line Color", group=groupBB, tooltip="【指标内容科普】\n颜色选择影响视觉区分。\n\n【新手提示】\n自定义布林带线条颜色。\n\n【实战建议】\n建议使用橙色或黄色。")

colBBFill = input.color(color.orange, "布林带填充颜色 / BB Fill Color", group=groupBB, tooltip="【指标内容科普】\n填充颜色影响视觉层次。\n\n【新手提示】\n自定义布林带填充颜色。\n\n【实战建议】\n透明度建议设置在70-80%。")

groupFilter = "过滤线 / Filter Line"
emaFilter = input.int(12, "过滤线 EMA12 / Filter EMA12", minval=1, group=groupFilter, tooltip="【指标内容科普】\nEMA12是常用趋势结构过滤线。\n\n【新手提示】\n设置过滤线（EMA12）的周期。\n\n【实战建议】\n12周期EMA作为多空结构过滤情报。")

colFilter = input.color(color.black, "过滤线颜色 / Filter Color", group=groupFilter, tooltip="【指标内容科普】\n颜色选择影响视觉区分。\n\n【新手提示】\n自定义过滤线颜色。\n\n【实战建议】\n建议使用黑色或深色。")

lineWidthFilter = input.int(2, "过滤线粗细 / Filter Line Width", minval=1, maxval=5, group=groupFilter, tooltip="【指标内容科普】\n线条粗细影响视觉清晰度。\n\n【新手提示】\n设置过滤线线条粗细。\n\n【实战建议】\n2-3即可。")

lineStyleFilter = input.string("实线", "过滤线类型 / Filter Line Style", options=["实线","阶梯线"], group=groupFilter, tooltip="【指标内容科普】\n实线更平滑，阶梯线更突出转折。\n\n【新手提示】\n选择过滤线样式（实线或阶梯线）。\n\n【实战建议】\n实线更平滑。")

groupShort = "短期通道 / Short Channel"
emaShort1 = input.int(21, "短期通道 EMA-1 (21) / Short EMA-1 (21)", minval=1, group=groupShort, tooltip="【指标内容科普】\n21周期是经典短期均线，形成短期通道上轨。\n\n【新手提示】\n设置短期通道上轨EMA周期。\n\n【实战建议】\n21周期是经典短期均线，适合捕捉短期结构变化。")

emaShort2 = input.int(55, "短期通道 EMA-2 (55) / Short EMA-2 (55)", minval=1, group=groupShort, tooltip="【指标内容科普】\n55周期与21周期形成短期通道下轨。\n\n【新手提示】\n设置短期通道下轨EMA周期。\n\n【实战建议】\n55周期与21周期形成通道，提供短期结构情报。")

colShortLine = input.color(color.new(#1aa1fc, 0), "短期通道线条颜色 / Short Line Color", group=groupShort, tooltip="【指标内容科普】\n#1aa1fc为短期通道专用亮蓝色，代表短期趋势敏感区域。\n\n【新手提示】\n短期通道是捕捉短期结构变化的核心。\n\n【实战建议】\n亮蓝色醒目，建议保持此颜色以快速识别短期结构。")

colShortFill = input.color(color.new(#1aa1fc, 0), "短期通道填充颜色 / Short Fill Color", group=groupShort, tooltip="【指标内容科普】\n#1aa1fc填充色与线条统一，视觉层次更清晰。\n\n【新手提示】\n填充透明度建议70-80%。\n\n【实战建议】\n亮蓝色填充帮助快速识别短期通道区间。")

lineWidthShort = input.int(1, "短期通道线条粗细 / Short Line Width", minval=1, maxval=5, group=groupShort, tooltip="【指标内容科普】\n线条粗细影响视觉清晰度。\n\n【新手提示】\n设置短期通道线条粗细。\n\n【实战建议】\n1-2即可。")

lineStyleShort = input.string("实线", "短期通道线条类型 / Short Line Style", options=["实线","阶梯线"], group=groupShort, tooltip="【指标内容科普】\n实线更清晰，阶梯线突出转折。\n\n【新手提示】\n选择短期通道线条样式。\n\n【实战建议】\n实线更清晰。")

groupVegas = "Vegas隧道 / Vegas Tunnel"
emaVegas1 = input.int(144, "Vegas隧道 EMA-3 上轨 (144) / Vegas Upper (144)", minval=1, group=groupVegas, tooltip="【指标内容科普】\n144周期是Vegas隧道核心参数，形成上轨。\n\n【新手提示】\n设置Vegas隧道上轨EMA周期。\n\n【实战建议】\n144周期是Vegas隧道核心参数，适合中期结构判断。")

emaVegas2 = input.int(169, "Vegas隧道 EMA-4 下轨 (169) / Vegas Lower (169)", minval=1, group=groupVegas, tooltip="【指标内容科普】\n169周期与144周期形成经典Vegas隧道下轨。\n\n【新手提示】\n设置Vegas隧道下轨EMA周期。\n\n【实战建议】\n169周期与144周期形成经典Vegas隧道。")

colVegasLine = input.color(color.new(#f23645, 0), "Vegas隧道线条颜色 / Vegas Line Color", group=groupVegas, tooltip="【指标内容科普】\n#f23645为Vegas隧道专用红色，代表中期趋势核心区域。\n\n【新手提示】\nVegas隧道是本指标最核心的通道。\n\n【实战建议】\n红色醒目，建议保持此颜色以突出中期结构。")

colVegasFill = input.color(color.new(#f23645, 0), "Vegas隧道填充颜色 / Vegas Fill Color", group=groupVegas, tooltip="【指标内容科普】\n#f23645填充色与线条统一，视觉层次更清晰。\n\n【新手提示】\n填充透明度建议70-80%。\n\n【实战建议】\n红色填充帮助快速识别Vegas隧道区间。")

lineWidthVegas = input.int(1, "Vegas隧道线条粗细 / Vegas Line Width", minval=1, maxval=5, group=groupVegas, tooltip="【指标内容科普】\n线条粗细影响视觉清晰度。\n\n【新手提示】\n设置Vegas隧道线条粗细。\n\n【实战建议】\n1-2即可。")

lineStyleVegas = input.string("实线", "Vegas隧道线条类型 / Vegas Line Style", options=["实线","阶梯线"], group=groupVegas, tooltip="【指标内容科普】\n实线更平滑，阶梯线突出转折。\n\n【新手提示】\n选择Vegas隧道线条样式。\n\n【实战建议】\n实线更平滑。")

groupMid = "中期通道 / Mid Channel"
emaMid1 = input.int(288, "中期通道 EMA-5 (288) / Mid EMA-5 (288)", minval=1, group=groupMid, tooltip="【指标内容科普】\n288周期代表中期趋势强度，形成上轨。\n\n【新手提示】\n设置中期通道上轨EMA周期。\n\n【实战建议】\n288周期代表中期趋势强度。")

emaMid2 = input.int(338, "中期通道 EMA-6 (338) / Mid EMA-6 (338)", minval=1, group=groupMid, tooltip="【指标内容科普】\n338周期与288周期形成中期通道下轨。\n\n【新手提示】\n设置中期通道下轨EMA周期。\n\n【实战建议】\n338周期与288周期形成通道。")

colMidLine = input.color(color.gray, "中期通道线条颜色 / Mid Line Color", group=groupMid, tooltip="【指标内容科普】\n灰色作为背景参考。\n\n【新手提示】\n自定义中期通道线条颜色。\n\n【实战建议】\n建议使用灰色。")

colMidFill = input.color(color.gray, "中期通道填充颜色 / Mid Fill Color", group=groupMid, tooltip="【指标内容科普】\n填充颜色影响视觉层次。\n\n【新手提示】\n自定义中期通道填充颜色。\n\n【实战建议】\n透明度建议80%以上。")

lineWidthMid = input.int(1, "中期通道线条粗细 / Mid Line Width", minval=1, maxval=5, group=groupMid, tooltip="【指标内容科普】\n线条粗细影响视觉清晰度。\n\n【新手提示】\n设置中期通道线条粗细。\n\n【实战建议】\n1即可。")

lineStyleMid = input.string("实线", "中期通道线条类型 / Mid Line Style", options=["实线","阶梯线"], group=groupMid, tooltip="【指标内容科普】\n实线更清晰，阶梯线突出转折。\n\n【新手提示】\n选择中期通道线条样式。\n\n【实战建议】\n实线更清晰。")

groupLong = "长期通道 / Long Channel"
emaLong1 = input.int(576, "长期通道 EMA-7 (576) / Long EMA-7 (576)", minval=1, group=groupLong, tooltip="【指标内容科普】\n576周期代表大趋势方向，形成上轨。\n\n【新手提示】\n设置长期通道上轨EMA周期。\n\n【实战建议】\n576周期代表大趋势方向。")

emaLong2 = input.int(676, "长期通道 EMA-8 (676) / Long EMA-8 (676)", minval=1, group=groupLong, tooltip="【指标内容科普】\n676周期与576周期形成长期通道下轨。\n\n【新手提示】\n设置长期通道下轨EMA周期。\n\n【实战建议】\n676周期与576周期形成长期通道。")

colLongLine = input.color(color.new(#05b33b, 0), "长期通道线条颜色 / Long Line Color", group=groupLong, tooltip="【指标内容科普】\n#05b33b为长期通道专用绿色，代表大趋势方向。\n\n【新手提示】\n长期通道是最大级别的趋势过滤器。\n\n【实战建议】\n绿色醒目，建议保持此颜色以突出大趋势方向。")

colLongFill = input.color(color.new(#05b33b, 0), "长期通道填充颜色 / Long Fill Color", group=groupLong, tooltip="【指标内容科普】\n#05b33b填充色与线条统一，视觉层次更清晰。\n\n【新手提示】\n填充透明度建议85%以上。\n\n【实战建议】\n绿色填充帮助快速识别长期趋势区间。")

lineWidthLong = input.int(1, "长期通道线条粗细 / Long Line Width", minval=1, maxval=5, group=groupLong, tooltip="【指标内容科普】\n线条粗细影响视觉清晰度。\n\n【新手提示】\n设置长期通道线条粗细。\n\n【实战建议】\n1即可。")

lineStyleLong = input.string("实线", "长期通道线条类型 / Long Line Style", options=["实线","阶梯线"], group=groupLong, tooltip="【指标内容科普】\n实线更平滑，阶梯线突出转折。\n\n【新手提示】\n选择长期通道线条样式。\n\n【实战建议】\n实线更平滑。")

// ============================================================
// 新增：额外EMA均线组 (EMA100 / EMA200) - 默认开启，可自定义
// ============================================================
groupExtraEMA = "额外EMA均线 / Additional EMA Lines"
showEMA100 = input.bool(true, "显示EMA100 / Show EMA100", group=groupExtraEMA, tooltip="【指标内容科普】\nEMA100是重要中期均线，常用于判断中期趋势和支撑阻力。\n\n【新手提示】\n默认开启，适合观察价格与EMA100的关系。\n\n【实战建议】\nEMA100常与EMA200配合使用，价格在EMA100上方偏多头。")
emaLen100 = input.int(100, "EMA100周期 / EMA100 Length", minval=1, group=groupExtraEMA, tooltip="【指标内容科普】\n设置EMA100的计算周期，默认100。\n\n【新手提示】\n100周期是经典中期均线。\n\n【实战建议】\n保持默认100即可。")
colEMA100Line = input.color(color.new(#9B59B6, 0), "EMA100线条颜色 / EMA100 Line Color", group=groupExtraEMA, tooltip="【指标内容科普】\n紫色(#9B59B6)醒目区分。\n\n【新手提示】\n自定义EMA100颜色。\n\n【实战建议】\n建议使用紫色或品红色以区别其他通道。")
lineWidthEMA100 = input.int(3, "EMA100线条粗细 / EMA100 Line Width", minval=1, maxval=5, group=groupExtraEMA, tooltip="【指标内容科普】\n线条粗细影响视觉清晰度。\n\n【新手提示】\n设置EMA100线条粗细。\n\n【实战建议】\n2即可突出显示。")
lineStyleEMA100 = input.string("实线", "EMA100线条类型 / EMA100 Line Style", options=["实线","阶梯线"], group=groupExtraEMA, tooltip="【指标内容科普】\n实线更平滑，阶梯线突出转折。\n\n【新手提示】\n选择EMA100线条样式。\n\n【实战建议】\n实线更平滑。")

showEMA200 = input.bool(true, "显示EMA200 / Show EMA200", group=groupExtraEMA, tooltip="【指标内容科普】\nEMA200是经典长期均线，代表大趋势方向，常作为牛熊分界线。\n\n【新手提示】\n默认开启，强烈建议保持开启。\n\n【实战建议】\nEMA200是机构常用长期趋势过滤器，价格在EMA200上方为长期多头市场。")
emaLen200 = input.int(200, "EMA200周期 / EMA200 Length", minval=1, group=groupExtraEMA, tooltip="【指标内容科普】\n设置EMA200的计算周期，默认200。\n\n【新手提示】\n200周期是经典长期均线。\n\n【实战建议】\n保持默认200。")
colEMA200Line = input.color(color.new(#ff0000, 0), "EMA200线条颜色 / EMA200 Line Color", group=groupExtraEMA, tooltip="【指标内容科普】\n蓝色(#3498DB)专业醒目。\n\n【新手提示】\n自定义EMA200颜色。\n\n【实战建议】\n建议使用蓝色系以区别其他均线。")
lineWidthEMA200 = input.int(3, "EMA200线条粗细 / EMA200 Line Width", minval=1, maxval=5, group=groupExtraEMA, tooltip="【指标内容科普】\n线条粗细影响视觉清晰度。\n\n【新手提示】\n设置EMA200线条粗细。\n\n【实战建议】\n2即可突出显示。")
lineStyleEMA200 = input.string("实线", "EMA200线条类型 / EMA200 Line Style", options=["实线","阶梯线"], group=groupExtraEMA, tooltip="【指标内容科普】\n实线更平滑，阶梯线突出转折。\n\n【新手提示】\n选择EMA200线条样式。\n\n【实战建议】\n实线更平滑。")

groupFill = "通道填充样式 / Channel Fill Styles"
transShort = input.int(70, "短期通道填充透明度 / Short Fill Transparency", minval=0, maxval=100, group=groupFill, tooltip="【指标内容科普】\n透明度影响视觉层次。\n\n【新手提示】\n设置短期通道填充透明度。\n\n【实战建议】\n70-80%最佳。")

transVegas = input.int(70, "Vegas隧道填充透明度 / Vegas Fill Transparency", minval=0, maxval=100, group=groupFill, tooltip="【指标内容科普】\n透明度影响视觉层次。\n\n【新手提示】\n设置Vegas隧道填充透明度。\n\n【实战建议】\n70-80%最佳。")

transMid = input.int(70, "中期通道填充透明度 / Mid Fill Transparency", minval=0, maxval=100, group=groupFill, tooltip="【指标内容科普】\n透明度影响视觉层次。\n\n【新手提示】\n设置中期通道填充透明度。\n\n【实战建议】\n80%以上最佳。")

transLong = input.int(70, "长期通道填充透明度 / Long Fill Transparency", minval=0, maxval=100, group=groupFill, tooltip="【指标内容科普】\n透明度影响视觉层次。\n\n【新手提示】\n设置长期通道填充透明度。\n\n【实战建议】\n85%以上最佳。")

groupDiv = "背离检测参数 / Divergence Parameters"
leftBars = input.int(5, "背离左侧柱数 / Left Bars for Pivot", minval=1, group=groupDiv, tooltip="【指标内容科普】\n左侧柱数影响背离检测灵敏度。\n\n【新手提示】\n设置背离检测左侧柱数。\n\n【实战建议】\n5是经典值。")

rightBars = input.int(5, "背离右侧柱数 / Right Bars for Pivot", minval=1, group=groupDiv, tooltip="【指标内容科普】\n右侧柱数影响背离检测灵敏度。\n\n【新手提示】\n设置背离检测右侧柱数。\n\n【实战建议】\n5是经典值。")

useHiddenDivergence = input.bool(true, "启用隐藏背离 / Enable Hidden Divergence", group=groupDiv, tooltip="【指标内容科普】\n隐藏背离预示趋势延续。\n\n【新手提示】\n是否启用隐藏背离检测。\n\n【实战建议】\n隐藏背离往往预示趋势延续，建议开启。")

groupDivOpt = "背离优化与实战策略 / Divergence Optimization & Practical Strategy"
divConfirmationBars = input.int(1, "背离确认柱数 / Divergence Confirmation Bars", minval=0, maxval=3, group=groupDivOpt, tooltip="【指标内容科普】\n确认柱数可减少假信号。\n\n【新手提示】\n设置背离信号确认所需柱数。\n\n【实战建议】\n1-2柱确认可减少假信号。")

minDivergenceCount = input.int(4, "强信号所需最小背离数量 / Min Divergences for Strong Signal", minval=2, maxval=8, group=groupDivOpt, tooltip="【指标内容科普】\n背离数量越多结构情报越强。\n\n【新手提示】\n设置触发强结构情报所需的最小背离数量。\n\n【实战建议】\n4个以上背离共振时情报质量最高。")

useMTFDiv = input.bool(false, "启用多时间框架背离确认 / Enable MTF Divergence Confirmation", group=groupDivOpt, tooltip="【指标内容科普】\nMTF背离可大幅提升结构可靠性。\n\n【新手提示】\n是否启用更高时间框架背离确认。\n\n【实战建议】\n默认关闭，需手动开启。")

groupFib = "斐波那契回撤 / Fibonacci Retracement"
showFib = input.bool(false, "显示斐波那契回撤 / Show Fibonacci Retracement", group=groupFib, tooltip="【指标内容科普】\n斐波那契回撤是经典支撑阻力工具。\n\n【新手提示】\n是否显示斐波那契回撤水平线。\n\n【实战建议】\n默认关闭，开启后可作为动态支撑阻力参考。")

fibLookback = input.int(100, "斐波那契回溯周期 / Fibonacci Lookback", minval=10, maxval=200, group=groupFib, tooltip="【指标内容科普】\n回溯周期影响斐波那契高低点计算。\n\n【新手提示】\n设置斐波那契回撤的回溯周期。\n\n【实战建议】\n波段交易推荐100周期（4H图最佳），短线可调至50，长线可调至150-200。")

groupMatrixWeight = "矩阵权重调整 / Matrix Weight Adjustment"
matrixWeightVegas = input.int(30, "Vegas权重 / Vegas Weight", minval=10, maxval=50, group=groupMatrixWeight, tooltip="【指标内容科普】\nVegas隧道是中期趋势核心，权重越高对趋势判断越重要。\n\n【新手提示】\n调整Vegas在矩阵中的权重（默认30）。\n\n【实战建议】\n新手建议保持默认30。")

matrixWeightVWAP = input.int(15, "VWAP权重 / VWAP Weight", minval=5, maxval=30, group=groupMatrixWeight, tooltip="【指标内容科普】\nVWAP代表机构公平价，权重越高越重视机构行为。\n\n【新手提示】\n调整VWAP在矩阵中的权重（默认15）。\n\n【实战建议】\n日内交易者可提高至20。")

matrixWeightDiv = input.int(3, "背离权重系数 / Divergence Weight Multiplier", minval=1, maxval=5, group=groupMatrixWeight, tooltip="【指标内容科普】\n背离数量越多结构情报越强，此系数决定每个背离的贡献。\n\n【新手提示】\n调整背离在矩阵中的权重系数（默认3）。\n\n【实战建议】\n背离敏感度高时可调至4。")

matrixWeightBB = input.int(10, "BB权重 / BB Weight", minval=5, maxval=20, group=groupMatrixWeight, tooltip="【指标内容科普】\n布林带突破代表波动率扩张，权重越高越重视突破结构情报。\n\n【新手提示】\n调整布林带在矩阵中的权重（默认10）。\n\n【实战建议】\n高波动市场可提高至15。")

matrixWeightVol = input.int(15, "成交量权重 / Volume Weight", minval=5, maxval=25, group=groupMatrixWeight, tooltip="【指标内容科普】\n成交量代表资金真实参与度，权重越高越重视量能。\n\n【新手提示】\n调整成交量在矩阵中的权重（默认15）。\n\n【实战建议】\n放量确认结构情报时可提高至20。")

matrixWeightMTF = input.int(12, "MTF权重 / MTF Weight", minval=5, maxval=20, group=groupMatrixWeight, tooltip="【指标内容科普】\n多时间框架确认提升结构可靠性，权重越高越重视高周期一致性。\n\n【新手提示】\n调整MTF在矩阵中的权重（默认12）。\n\n【实战建议】\n波段交易者可提高至15。")

matrixWeightDelta = input.int(12, "Delta权重 / Delta Weight", minval=5, maxval=25, group=groupMatrixWeight, tooltip="【指标内容科普】\nDelta代表订单流真实买卖压力，权重越高越重视资金流向情报。\n\n【新手提示】\n调整Delta在矩阵中的权重（默认12）。\n\n【实战建议】\n订单流敏感交易者可提高至18。")

groupAdaptive = "黑科技自适应矩阵引擎 / Black-Tech Adaptive Matrix Engine"
enableAdaptive = input.bool(true, "启用自适应矩阵引擎 / Enable Adaptive Matrix Engine", group=groupAdaptive, tooltip="【指标内容科普】\n黑科技矩阵引擎实时计算7大因素独立分数并动态加权，是机构级共振判断核心。\n\n【新手提示】\n是否启用自适应矩阵引擎。\n\n【实战建议】\n强烈建议开启。")

regimeLookback = input.int(50, "矩阵检测周期 / Matrix Detection Lookback", minval=20, maxval=200, group=groupAdaptive, tooltip="【指标内容科普】\n检测周期影响矩阵分数计算准确性。\n\n【新手提示】\n设置矩阵引擎的回溯周期。\n\n【实战建议】\n50周期适合大多数加密货币市场。")

volatilityMultiplier = input.float(2.5, "波动率阈值乘数 / Volatility Threshold Multiplier", minval=1.5, maxval=5.0, step=0.1, group=groupAdaptive, tooltip="【指标内容科普】\n波动率阈值影响矩阵对市场状态的敏感度。\n\n【新手提示】\n设置波动率阈值乘数。\n\n【实战建议】\n2.5是平衡值。")

scoreThresholdStrong = input.float(75, "强结构矩阵阈值 / Strong Matrix Score Threshold", minval=60, maxval=90, step=1, group=groupAdaptive, tooltip="【指标内容科普】\n矩阵总分阈值决定强结构情报触发。\n\n【新手提示】\n设置触发强结构情报的矩阵总分阈值。\n\n【实战建议】\n75分以上结构情报质量最高。")

groupPhase3 = "Phase 3 极端共振设置 / Phase 3 Extreme Confluence Settings"
enableExtremeConfluence = input.bool(true, "启用极端共振情报 / Enable Extreme Confluence Intelligence", group=groupPhase3, tooltip="【指标内容科普】\n当矩阵总分 ≥ 85 且满足4重确认时触发极端共振情报。\n\n【新手提示】\n极端共振是Phase 4核心强共振结构情报。\n\n【实战建议】\n强烈建议开启，情报质量极高时才会触发。")

extremeScoreThreshold = input.float(85, "极端共振分数阈值 / Extreme Confluence Score Threshold", minval=75, maxval=95, step=1, group=groupPhase3, tooltip="【指标内容科普】\n矩阵总分达到此值才触发极端共振情报。\n\n【新手提示】\n85分是平衡值，过高会减少情报次数。\n\n【实战建议】\n保持85分，兼顾情报频率与质量。")

groupPerpetual = "加密永续模式 / Crypto Perpetual Mode"
cryptoPerpetualMode = input.bool(true, "启用加密永续模式 / Enable Crypto Perpetual Mode", group=groupPerpetual, tooltip="【指标内容科普】\n专为24/7永续合约优化。\n\n【新手提示】\n是否启用永续合约专用模式。\n\n【实战建议】\n加密货币永续交易者强烈建议开启。")

groupMoon = "月相周期 / Moon Phase Cycle"
showMoonPhase = input.bool(false, "显示月相周期 / Show Moon Phase Cycle", group=groupMoon, tooltip="【指标内容科普】\n月相周期基于29.53天朔望月计算当前月相阶段。\n\n【新手提示】\n是否显示月相周期。\n\n【实战建议】\n月相可辅助判断市场情绪周期，默认关闭。")

groupOBFVG = "机构订单块与FVG V3 / Order Blocks & FVG V3"
showOB = input.bool(false, "显示订单块 / Show Order Blocks", group=groupOBFVG, tooltip="【指标内容科普】\n订单块是机构大单积累的强支撑/阻力区域。\n\n【新手提示】\n是否显示机构订单块。\n\n【实战建议】\n默认关闭，可根据需要手动开启。")

showFVGBlocks = input.bool(false, "显示FVG块状区域 / Show FVG Block Areas", group=groupOBFVG, tooltip="【指标内容科普】\nFVG块状区域以半透明矩形向右延伸显示公平价值缺口。\n\n【新手提示】\n是否显示FVG的块状填充区域。\n\n【实战建议】\n默认关闭，开启后可清晰看到机构回补的缺口区域。")

// ============================================================

// 【全局变量声明区】
// ============================================================
var label fib236Label = na
var label fib382Label = na
var label fib500Label = na
var label fib618Label = na
var label fib786Label = na
var label fib0Label = na
var label fib100Label = na
var label fib1618Label = na
var label fib2618Label = na

// EMA文字标签 (为所有EMA均线在图上显示名称标注)
var label labelFilter = na
var label labelShort1 = na
var label labelShort2 = na
var label labelVegas1 = na
var label labelVegas2 = na
var label labelMid1 = na
var label labelMid2 = na
var label labelLong1 = na
var label labelLong2 = na
var label labelEMA100 = na
var label labelEMA200 = na

var bool fvgMitigatedUp = false
var bool fvgMitigatedDn = false

var label obBullLabel = na
var label obBearLabel = na
var label liquidityLabel = na

var float lastOBBull = na
var float lastOBBear = na
var float lastOBBullStrength = na
var float lastOBBearStrength = na
var bool obBullMitigated = false
var bool obBearMitigated = false

var float lastBOSBull = na
var float lastBOSBear = na
var float lastCHOCHBull = na
var float lastCHOCHBear = na
var float lastMSSBull = na
var float lastMSSBear = na
var float lastBreakerBull = na
var float lastBreakerBear = na
var bool bosBullMitigated = false
var bool bosBearMitigated = false
var bool chochBullMitigated = false
var bool chochBearMitigated = false
var bool mssBullMitigated = false
var bool mssBearMitigated = false
var bool breakerBullMitigated = false
var bool breakerBearMitigated = false

// === SMC永久结构线 ===
var line bosBullLine = na
var line bosBearLine = na
var line chochBullLine = na
var line chochBearLine = na
var line mssBullLine = na
var line mssBearLine = na
var line breakerBullLine = na
var line breakerBearLine = na
var line liquidityHighLine = na
var line liquidityLowLine = na

var float deltaMA = na
var float delta = na
var float cumDelta = na
var bool obBullStrong = false
var bool obBearStrong = false
var string orderFlowImbalance = "中性 / Neutral"

var string currentRegime = "Neutral"
var float confluenceScore = 0.0
var string deltaPractical = "中性 / Neutral"
var bool deltaBullishDivergence = false
var bool deltaBearishDivergence = false

var bool bullishStructure = false
var bool bearishStructure = false
var bool extremeConfluenceBull = false
var bool extremeConfluenceBear = false

var bool bosBull = false
var bool bosBear = false
var bool chochBull = false
var bool chochBear = false
var bool mssBull = false
var bool mssBear = false
var bool breakerBull = false
var bool breakerBear = false

// 气泡状态跟踪（rising edge使用）
var bool lastBullishStructure = false
var bool lastBearishStructure = false
var bool lastExtremeBull = false
var bool lastExtremeBear = false
var bool lastBosBull = false
var bool lastBosBear = false
var bool lastChochBull = false
var bool lastChochBear = false
var bool lastMssBull = false
var bool lastMssBear = false
var bool lastBreakerBullState = false
var bool lastBreakerBearState = false
var bool lastLiquidityHigh = false
var bool lastLiquidityLow = false
var bool lastFvgUp = false
var bool lastFvgDn = false
var bool lastDeltaBullDiv = false
var bool lastDeltaBearDiv = false
var bool lastImbalanceBull = false
var bool lastImbalanceBear = false
var bool lastShortBreakUp = false
var bool lastShortBreakDn = false
var bool lastVegasBreakUp = false
var bool lastVegasBreakDn = false
var bool lastMidBreakUp = false
var bool lastMidBreakDn = false
var bool lastLongBreakUp = false
var bool lastLongBreakDn = false
var bool lastBBLong = false
var bool lastBBShort = false
var bool lastRsiBullDiv = false
var bool lastRsiBearDiv = false
var bool lastMacdBullDiv = false
var bool lastMacdBearDiv = false
var bool lastStochBullDiv = false
var bool lastStochBearDiv = false
var bool lastSmaBull = false
var bool lastSmaBear = false


// ============================================================
// 【实时气泡标签管理系统 - 彻底优化版】
// ============================================================
var label[] timedLabels = array.new_label()
var int[] creationBarIndex = array.new_int()
var int[] creationTimes = array.new_int()

if barstate.isfirst
    array.clear(timedLabels)
    array.clear(creationBarIndex)
    array.clear(creationTimes)

f_getBubbleSize(_sizeStr) => 
    _sizeStr == "Tiny" ? size.tiny : _sizeStr == "Small" ? size.small : _sizeStr == "Normal" ? size.normal : size.large

f_createBubble(_textCN, _textEN, _price, _style, _bgColor, _textColor) =>
    if not showBubbles or not barstate.isrealtime or array.size(timedLabels) >= 30  // 增加到30个，配合输入开关
        na
    else
        textFull = _textCN + "\n" + _textEN
        tooltipFull = _textCN + "\n" + _textEN + "\n\n【实时市场情报提示】\n5分钟自动消失"
        lbl = label.new(bar_index, _price, textFull, style=_style, color=color.new(_bgColor, 0), textcolor=_textColor, size=size.small, tooltip=tooltipFull)  // bubble size input removed
        array.push(timedLabels, lbl)
        array.push(creationBarIndex, bar_index)
        array.push(creationTimes, timenow)
        lbl

// 增强版清理逻辑 - 仅在barstate.islast执行，更安全、更高效（修复原每根K线无条件执行的性能问题）
if barstate.islast
    int i = array.size(timedLabels) - 1
    while i >= 0
        if i >= array.size(timedLabels)
            break
        int ageBars = bar_index - array.get(creationBarIndex, i)
        int ageMs = timenow - array.get(creationTimes, i)
        if ageBars > bubbleLifetimeBars or ageMs > 300000  // 使用输入参数控制气泡寿命
            label.delete(array.get(timedLabels, i))
            array.remove(timedLabels, i)
            array.remove(creationBarIndex, i)
            array.remove(creationTimes, i)
        else
            i -= 1

// ============================================================
// 【输入参数区 - 全部完整展开，无任何省略】
// ============================================================
// 【背离检测函数】
// ============================================================
f_divergence(pricePivotLow, pricePivotHigh, oscLow, oscHigh, oscSeries, confirmationBars) =>
    barsSincePriceLow  = ta.barssince(not na(pricePivotLow))
    barsSinceOscLow    = ta.barssince(not na(oscLow))
    barsSincePriceHigh = ta.barssince(not na(pricePivotHigh))
    barsSinceOscHigh   = ta.barssince(not na(oscHigh))
    bool regularBull = not na(pricePivotLow) and not na(oscLow) and oscSeries[barsSincePriceLow] > oscSeries[barsSinceOscLow] and (confirmationBars == 0 or barsSincePriceLow >= confirmationBars)
    bool hiddenBull  = not na(pricePivotLow) and not na(oscLow) and oscSeries[barsSincePriceLow] < oscSeries[barsSinceOscLow] and (confirmationBars == 0 or barsSincePriceLow >= confirmationBars)
    bool regularBear = not na(pricePivotHigh) and not na(oscHigh) and oscSeries[barsSincePriceHigh] < oscSeries[barsSinceOscHigh] and (confirmationBars == 0 or barsSincePriceHigh >= confirmationBars)
    bool hiddenBear  = not na(pricePivotHigh) and not na(oscHigh) and oscSeries[barsSincePriceHigh] > oscSeries[barsSinceOscHigh] and (confirmationBars == 0 or barsSincePriceHigh >= confirmationBars)
    [regularBull or f_and(useHiddenDivergence, hiddenBull), regularBear or f_and(useHiddenDivergence, hiddenBear)]

// ============================================================
// 【全局计算区】
// ============================================================
f_ema(src, len, tf) => request.security(syminfo.tickerid, tf, ta.ema(src, len), lookahead=barmerge.lookahead_off)

pFilter = ta.ema(src, emaFilter)
pShort1 = ta.ema(src, emaShort1)
pShort2 = ta.ema(src, emaShort2)
pVegas1 = useMTF ? f_ema(src, emaVegas1, mtfTimeframe) : ta.ema(src, emaVegas1)
pVegas2 = useMTF ? f_ema(src, emaVegas2, mtfTimeframe) : ta.ema(src, emaVegas2)
pMid1   = ta.ema(src, emaMid1)
pMid2   = ta.ema(src, emaMid2)
pLong1  = ta.ema(src, emaLong1)
pLong2  = ta.ema(src, emaLong2)
pEMA100 = ta.ema(src, emaLen100)
pEMA200 = ta.ema(src, emaLen200)

shortBreakUp = ta.crossover(close, pShort1)
shortBreakDn = ta.crossunder(close, pShort2)
vegasBreakUp = ta.crossover(close, pVegas1)
vegasBreakDn = ta.crossunder(close, pVegas2)
midBreakUp   = ta.crossover(close, pMid1)
midBreakDn   = ta.crossunder(close, pMid2)
longBreakUp  = ta.crossover(close, pLong1)
longBreakDn  = ta.crossunder(close, pLong2)

isNewDay = ta.change(time("1D")) != 0
// VWAP calculations removed (module deleted)

bbBasis = ta.sma(src, bbLength)
bbDev = bbMult * ta.stdev(src, bbLength)
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev
bbBandwidth = (bbUpper - bbLower) / bbBasis * 100
bbSqueeze = bbBandwidth < bbSqueezeThreshold
bbExpansion = bbBandwidth > bbExpansionThreshold
bbBreakoutLong = ta.crossover(close, bbUpper) and bbExpansion and not bbSqueeze[1]
bbBreakoutShort = ta.crossunder(close, bbLower) and bbExpansion and not bbSqueeze[1]

atrVal = ta.atr(14)
volSma = ta.sma(volume, 20)
volRising = volume > volume[1]
volStrong = volume > volSma * 1.5 and volRising

bullishStructure := close > pVegas2 and pVegas1 > pVegas2 and close > pFilter
bearishStructure := close < pVegas1 and pVegas1 < pVegas2

priceLow  = ta.pivotlow(low,  leftBars, rightBars)
priceHigh = ta.pivothigh(high, leftBars, rightBars)

rsi = ta.rsi(src, 14)
rsiLow  = ta.pivotlow(rsi, leftBars, rightBars)
rsiHigh = ta.pivothigh(rsi, leftBars, rightBars)
[rsiBullishDivergence, rsiBearishDivergence] = f_divergence(priceLow, priceHigh, rsiLow, rsiHigh, rsi, divConfirmationBars)

[macdLine, signalLine, macdHist] = ta.macd(close, 12, 26, 9)
macdLow  = ta.pivotlow(macdHist, leftBars, rightBars)
macdHigh = ta.pivothigh(macdHist, leftBars, rightBars)
[macdBullishDivergence, macdBearishDivergence] = f_divergence(priceLow, priceHigh, macdLow, macdHigh, macdHist, divConfirmationBars)

stochKLine = ta.stoch(close, high, low, 14)
stochLow   = ta.pivotlow(stochKLine, leftBars, rightBars)
stochHigh  = ta.pivothigh(stochKLine, leftBars, rightBars)
[stochBullishDivergence, stochBearishDivergence] = f_divergence(priceLow, priceHigh, stochLow, stochHigh, stochKLine, divConfirmationBars)

emaVegas1Val = ta.ema(src, emaVegas1)
emaVegas2Val = ta.ema(src, emaVegas2)
var float higherTFVegas1 = na
var float higherTFVegas2 = na
if barstate.isnew or barstate.isfirst
    higherTFVegas1 := request.security(syminfo.tickerid, "240", emaVegas1Val, lookahead=barmerge.lookahead_off)
    higherTFVegas2 := request.security(syminfo.tickerid, "240", emaVegas2Val, lookahead=barmerge.lookahead_off)
mtfBiasLong = close > higherTFVegas2 and higherTFVegas1 > higherTFVegas2
mtfBiasShort = close < higherTFVegas1 and higherTFVegas1 < higherTFVegas2

activeDivergences = (rsiBullishDivergence ? 1 : 0) + (macdBullishDivergence ? 1 : 0) + (stochBullishDivergence ? 1 : 0)

obBull = ta.pivotlow(low,  leftBars*2, rightBars*2)
obBear = ta.pivothigh(high, leftBars*2, rightBars*2)

if not na(obBull)
    strength = volume > volSma * 1.8 and close > pVegas2 ? 2.0 : volume > volSma * 1.2 ? 1.0 : 0.5
    lastOBBull := obBull
    lastOBBullStrength := strength
    obBullMitigated := false
if not na(obBear)
    strength = volume > volSma * 1.8 and close < pVegas1 ? 2.0 : volume > volSma * 1.2 ? 1.0 : 0.5
    lastOBBear := obBear
    lastOBBearStrength := strength
    obBearMitigated := false

if not na(lastOBBull) and close < lastOBBull
    obBullMitigated := true
if not na(lastOBBear) and close > lastOBBear
    obBearMitigated := true

delta := close > open ? volume : close < open ? -volume : 0
cumDelta := cumDelta[1] + delta
deltaMA := ta.sma(delta, 20)
 
// 【关键修复】Delta压力线归一化处理（让它在价格主图上可见）
// 归一化到当前价格附近 ±3% 左右的范围，向上 = 买方压力增强，向下 = 卖方压力增强
deltaMA_norm = close + (deltaMA / math.max(ta.sma(volume, 20), 1)) * (close * 0.03)
deltaRising = cumDelta > cumDelta[1]
deltaFalling = cumDelta < cumDelta[1]

deltaLow  = ta.pivotlow(delta, leftBars, rightBars)
deltaHigh = ta.pivothigh(delta, leftBars, rightBars)
deltaBullishDivergence := not na(priceLow) and not na(deltaLow) and delta[ta.barssince(not na(priceLow))] > delta[ta.barssince(not na(deltaLow))]
deltaBearishDivergence := not na(priceHigh) and not na(deltaHigh) and delta[ta.barssince(not na(priceHigh))] < delta[ta.barssince(not na(deltaHigh))]
deltaPractical := deltaRising and deltaBullishDivergence ? "强看多结构情报 / Strong Bullish Structure Intelligence" : deltaFalling and deltaBearishDivergence ? "强看空结构情报 / Strong Bearish Structure Intelligence" : "中性 / Neutral"

deltaPressure = (delta / math.max(volume, 1)) * 100
orderFlowImbalance := deltaPressure > 15 ? "强买入压力 / Strong Buy Pressure" : deltaPressure < -15 ? "强卖出压力 / Strong Sell Pressure" : "中性 / Neutral"

imbalanceBull = deltaPressure > 25
imbalanceBear = deltaPressure < -25



bosBull := not na(ta.pivotlow(low, leftBars*3, rightBars*3)) and close > pVegas1 and volume > volSma * 1.3
bosBear := not na(ta.pivothigh(high, leftBars*3, rightBars*3)) and close < pVegas2 and volume > volSma * 1.3
chochBull := not na(ta.pivotlow(low, leftBars*3, rightBars*3)) and close < pVegas2
chochBear := not na(ta.pivothigh(high, leftBars*3, rightBars*3)) and close > pVegas1
mssBull := not na(ta.pivotlow(low, leftBars*4, rightBars*4)) and close > pVegas1
mssBear := not na(ta.pivothigh(high, leftBars*4, rightBars*4)) and close < pVegas2

breakerBull := not na(ta.pivotlow(low, leftBars*3, rightBars*3)) and close > pVegas1 and close[1] < pVegas1[1]
breakerBear := not na(ta.pivothigh(high, leftBars*3, rightBars*3)) and close < pVegas2 and close[1] > pVegas2[1]

if bosBull and barstate.isconfirmed
    lastBOSBull := low
    bosBullMitigated := false
if bosBear and barstate.isconfirmed
    lastBOSBear := high
    bosBearMitigated := false
if chochBull and barstate.isconfirmed
    lastCHOCHBull := low
    chochBullMitigated := false
if chochBear and barstate.isconfirmed
    lastCHOCHBear := high
    chochBearMitigated := false
if mssBull and barstate.isconfirmed
    lastMSSBull := low
    mssBullMitigated := false
if mssBear and barstate.isconfirmed
    lastMSSBear := high
    mssBearMitigated := false
if breakerBull and barstate.isconfirmed
    lastBreakerBull := low
    breakerBullMitigated := false
if breakerBear and barstate.isconfirmed
    lastBreakerBear := high
    breakerBearMitigated := false

if not na(lastBOSBull) and close < lastBOSBull
    bosBullMitigated := true
if not na(lastBOSBear) and close > lastBOSBear
    bosBearMitigated := true
if not na(lastCHOCHBull) and close < lastCHOCHBull
    chochBullMitigated := true
if not na(lastCHOCHBear) and close > lastCHOCHBear
    chochBearMitigated := true
if not na(lastMSSBull) and close < lastMSSBull
    mssBullMitigated := true
if not na(lastMSSBear) and close > lastMSSBear
    mssBearMitigated := true
if not na(lastBreakerBull) and close < lastBreakerBull
    breakerBullMitigated := true
if not na(lastBreakerBear) and close > lastBreakerBear
    breakerBearMitigated := true

liquidityHigh = ta.pivothigh(high, 5, 5)
liquidityLow  = ta.pivotlow(low, 5, 5)

// === SMC永久结构线绘制 ===
if showSMCLines
    // BOS
    if bosBull and barstate.isconfirmed
        if not na(bosBullLine) 
            line.delete(bosBullLine)
        bosBullLine := line.new(bar_index, lastBOSBull, bar_index + 80, lastBOSBull, color=colBOSLine, style=line.style_dashed, width=2, extend=extend.right)
    if bosBear and barstate.isconfirmed
        if not na(bosBearLine)
            line.delete(bosBearLine)
        bosBearLine := line.new(bar_index, lastBOSBear, bar_index + 80, lastBOSBear, color=colBOSLine, style=line.style_dashed, width=2, extend=extend.right)
    
    // CHOCH
    if chochBull and barstate.isconfirmed
        if not na(chochBullLine)
            line.delete(chochBullLine)
        chochBullLine := line.new(bar_index, lastCHOCHBull, bar_index + 80, lastCHOCHBull, color=colCHOCHLine, style=line.style_dotted, width=2, extend=extend.right)
    if chochBear and barstate.isconfirmed
        if not na(chochBearLine)
            line.delete(chochBearLine)
        chochBearLine := line.new(bar_index, lastCHOCHBear, bar_index + 80, lastCHOCHBear, color=colCHOCHLine, style=line.style_dotted, width=2, extend=extend.right)
    
    // MSS
    if mssBull and barstate.isconfirmed
        if not na(mssBullLine)
            line.delete(mssBullLine)
        mssBullLine := line.new(bar_index, lastMSSBull, bar_index + 80, lastMSSBull, color=colMSSLine, style=line.style_solid, width=2, extend=extend.right)
    if mssBear and barstate.isconfirmed
        if not na(mssBearLine)
            line.delete(mssBearLine)
        mssBearLine := line.new(bar_index, lastMSSBear, bar_index + 80, lastMSSBear, color=colMSSLine, style=line.style_solid, width=2, extend=extend.right)
    
    // Breaker Block
    if breakerBull and barstate.isconfirmed
        if not na(breakerBullLine)
            line.delete(breakerBullLine)
        breakerBullLine := line.new(bar_index, lastBreakerBull, bar_index + 80, lastBreakerBull, color=colBreakerLine, style=line.style_dashed, width=3, extend=extend.right)
    if breakerBear and barstate.isconfirmed
        if not na(breakerBearLine)
            line.delete(breakerBearLine)
        breakerBearLine := line.new(bar_index, lastBreakerBear, bar_index + 80, lastBreakerBear, color=colBreakerLine, style=line.style_dashed, width=3, extend=extend.right)
    
    // Liquidity Sweep
    if not na(liquidityHigh) and barstate.isconfirmed
        if not na(liquidityHighLine)
            line.delete(liquidityHighLine)
        liquidityHighLine := line.new(bar_index, liquidityHigh, bar_index + 60, liquidityHigh, color=colLiquidityLine, style=line.style_dotted, width=1, extend=extend.right)
    if not na(liquidityLow) and barstate.isconfirmed
        if not na(liquidityLowLine)
            line.delete(liquidityLowLine)
        liquidityLowLine := line.new(bar_index, liquidityLow, bar_index + 60, liquidityLow, color=colLiquidityLine, style=line.style_dotted, width=1, extend=extend.right)


fvgUp = low > high[2] ? (low + high[2])/2 : na
fvgDn = high < low[2] ? (high + low[2])/2 : na

var box fvgBoxUp = na
var box fvgBoxDn = na

if showFVGBlocks and not na(fvgUp) and barstate.isconfirmed
    if not na(fvgBoxUp)
        box.delete(fvgBoxUp)
    fvgBoxUp := box.new(bar_index, high[2], bar_index + 50, fvgUp, border_color=color.new(color.lime, 70), bgcolor=color.new(color.lime, 85), extend=extend.right)

if showFVGBlocks and not na(fvgDn) and barstate.isconfirmed
    if not na(fvgBoxDn)
        box.delete(fvgBoxDn)
    fvgBoxDn := box.new(bar_index, low[2], bar_index + 50, fvgDn, border_color=color.new(color.red, 70), bgcolor=color.new(color.red, 85), extend=extend.right)

// ============================================================
// ============================================================
fibHigh = ta.highest(high, fibLookback)
fibLow = ta.lowest(low, fibLookback)
fibRange = fibHigh - fibLow
fib0 = fibHigh
fib236 = fibHigh - fibRange * 0.236
fib382 = fibHigh - fibRange * 0.382
fib500 = fibHigh - fibRange * 0.5
fib618 = fibHigh - fibRange * 0.618
fib786 = fibHigh - fibRange * 0.786
fib100 = fibLow
fib1618 = fibHigh - fibRange * 1.618
fib2618 = fibHigh - fibRange * 2.618

if showFib and barstate.islast
    if na(fib0Label)
        fib0Label := label.new(bar_index, fib0, "0%\n" + str.tostring(fib0, "#.##"), style=label.style_label_left, color=color.new(color.red, 0), textcolor=color.white, size=size.tiny)
    else
        label.set_xy(fib0Label, bar_index, fib0)
        label.set_text(fib0Label, "0%\n" + str.tostring(fib0, "#.##"))
    if na(fib236Label)
        fib236Label := label.new(bar_index, fib236, "23.6%\n" + str.tostring(fib236, "#.##"), style=label.style_label_left, color=color.new(color.orange, 0), textcolor=color.white, size=size.tiny)
    else
        label.set_xy(fib236Label, bar_index, fib236)
        label.set_text(fib236Label, "23.6%\n" + str.tostring(fib236, "#.##"))
    if na(fib382Label)
        fib382Label := label.new(bar_index, fib382, "38.2%\n" + str.tostring(fib382, "#.##"), style=label.style_label_left, color=color.new(color.yellow, 0), textcolor=color.black, size=size.tiny)
    else
        label.set_xy(fib382Label, bar_index, fib382)
        label.set_text(fib382Label, "38.2%\n" + str.tostring(fib382, "#.##"))
    if na(fib500Label)
        fib500Label := label.new(bar_index, fib500, "50%\n" + str.tostring(fib500, "#.##"), style=label.style_label_left, color=color.new(#008B8B, 0), textcolor=color.white, size=size.tiny)
    else
        label.set_xy(fib500Label, bar_index, fib500)
        label.set_text(fib500Label, "50%\n" + str.tostring(fib500, "#.##"))
    if na(fib618Label)
        fib618Label := label.new(bar_index, fib618, "61.8%\n" + str.tostring(fib618, "#.##"), style=label.style_label_left, color=color.new(color.aqua, 0), textcolor=color.black, size=size.tiny)
    else
        label.set_xy(fib618Label, bar_index, fib618)
        label.set_text(fib618Label, "61.8%\n" + str.tostring(fib618, "#.##"))
    if na(fib786Label)
        fib786Label := label.new(bar_index, fib786, "78.6%\n" + str.tostring(fib786, "#.##"), style=label.style_label_left, color=color.new(color.purple, 0), textcolor=color.white, size=size.tiny)
    else
        label.set_xy(fib786Label, bar_index, fib786)
        label.set_text(fib786Label, "78.6%\n" + str.tostring(fib786, "#.##"))
    if na(fib100Label)
        fib100Label := label.new(bar_index, fib100, "100%\n" + str.tostring(fib100, "#.##"), style=label.style_label_left, color=color.new(color.green, 0), textcolor=color.white, size=size.tiny)
    else
        label.set_xy(fib100Label, bar_index, fib100)
        label.set_text(fib100Label, "100%\n" + str.tostring(fib100, "#.##"))
    if na(fib1618Label)
        fib1618Label := label.new(bar_index, fib1618, "161.8%\n" + str.tostring(fib1618, "#.##"), style=label.style_label_left, color=color.new(#FF69B4, 0), textcolor=color.white, size=size.tiny)
    else
        label.set_xy(fib1618Label, bar_index, fib1618)
        label.set_text(fib1618Label, "161.8%\n" + str.tostring(fib1618, "#.##"))
    if na(fib2618Label)
        fib2618Label := label.new(bar_index, fib2618, "261.8%\n" + str.tostring(fib2618, "#.##"), style=label.style_label_left, color=color.new(#DC143C, 0), textcolor=color.white, size=size.tiny)
    else
        label.set_xy(fib2618Label, bar_index, fib2618)
        label.set_text(fib2618Label, "261.8%\n" + str.tostring(fib2618, "#.##"))
else if not showFib
    if not na(fib0Label)
        label.delete(fib0Label)
        fib0Label := na
    if not na(fib236Label)
        label.delete(fib236Label)
        fib236Label := na
    if not na(fib382Label)
        label.delete(fib382Label)
        fib382Label := na
    if not na(fib500Label)
        label.delete(fib500Label)
        fib500Label := na
    if not na(fib618Label)
        label.delete(fib618Label)
        fib618Label := na
    if not na(fib786Label)
        label.delete(fib786Label)
        fib786Label := na
    if not na(fib100Label)
        label.delete(fib100Label)
        fib100Label := na
    if not na(fib1618Label)
        label.delete(fib1618Label)
        fib1618Label := na
    if not na(fib2618Label)
        label.delete(fib2618Label)
        fib2618Label := na

// ============================================================
// 【黑科技自适应矩阵引擎】
// ============================================================
volatility = ta.stdev(close, regimeLookback) / ta.sma(close, regimeLookback) * volatilityMultiplier
[_, _, adxVal] = ta.dmi(14, 14)
trendStrength = adxVal > 25 ? 1 : adxVal > 20 ? 0.5 : 0

if enableAdaptive
    if bullishStructure and trendStrength == 1 and volatility < 2.5
        currentRegime := "Strong Bull Structure"
    else if bearishStructure and trendStrength == 1 and volatility < 2.5
        currentRegime := "Strong Bear Structure"
    else if math.abs(close - pVegas1) / pVegas1 < 0.008 and volatility < 1.8
        currentRegime := "Low Volatility Range"
    else if volatility > 4.0
        currentRegime := "High Volatility Breakout"
    else if volatility < 1.5
        currentRegime := "Mean Reversion"
    else
        currentRegime := "Weak Trend"
else
    currentRegime := "Manual Mode"

dynamicVegasBoost = (currentRegime == "Strong Bull Structure" or currentRegime == "Strong Bear Structure") ? 1.25 : 1.0
dynamicDeltaBoost = (currentRegime == "Strong Bull Structure" or currentRegime == "Strong Bear Structure") ? 1.3 : 1.0

matrixVegas = (bullishStructure or bearishStructure) ? matrixWeightVegas * 1.2 * dynamicVegasBoost : matrixWeightVegas / 2
matrixDiv = activeDivergences * matrixWeightDiv * 1.1
matrixVol = volStrong ? matrixWeightVol * 1.3 : matrixWeightVol / 2
matrixMTF = ((useMTFDiv and mtfBiasLong and bullishStructure) or (useMTFDiv and mtfBiasShort and bearishStructure)) ? matrixWeightMTF * 1.2 : matrixWeightMTF / 2
matrixDelta = deltaBullishDivergence or deltaBearishDivergence ? matrixWeightDelta * 1.3 * dynamicDeltaBoost : matrixWeightDelta / 2

confluenceScore := math.round(matrixVegas + matrixDiv + matrixVol + matrixMTF + matrixDelta)
confluenceScore := math.min(math.max(confluenceScore, 0), 100)

sma50 = ta.sma(close, 50)
sma100 = ta.sma(close, 100)
sma200 = ta.sma(close, 200)
smaAdvancedBull = close > sma50 and sma50 > sma100 and sma100 > sma200
smaAdvancedBear = close < sma50 and sma50 < sma100 and sma100 < sma200
smaAdvancedStatus = smaAdvancedBull ? "强多头结构 / Strong Bullish Structure" : smaAdvancedBear ? "强空头结构 / Strong Bearish Structure" : "结构中性 / Neutral Structure"

lunarCycleDays = 29.530588853
moonAge = (time / 86400000.0) % lunarCycleDays
string moonPhaseText = moonAge < 1.84566 ? "新月 / New Moon" : moonAge < 5.53699 ? "蛾眉月 / Waxing Crescent" : moonAge < 9.22831 ? "上弦月 / First Quarter" : moonAge < 12.91963 ? "盈凸月 / Waxing Gibbous" : moonAge < 16.61096 ? "满月 / Full Moon" : moonAge < 20.30228 ? "亏凸月 / Waning Gibbous" : moonAge < 23.99361 ? "下弦月 / Last Quarter" : moonAge < 27.68493 ? "残月 / Waning Crescent" : "新月 / New Moon"
string moonSymbol = moonAge < 1.84566 ? "🌑" : moonAge < 5.53699 ? "🌒" : moonAge < 9.22831 ? "🌓" : moonAge < 12.91963 ? "🌔" : moonAge < 16.61096 ? "🌕" : moonAge < 20.30228 ? "🌖" : moonAge < 23.99361 ? "🌗" : moonAge < 27.68493 ? "🌘" : "🌑"

extremeConfluenceBull := enableExtremeConfluence and confluenceScore >= extremeScoreThreshold and bullishStructure and deltaBullishDivergence and volStrong and mtfBiasLong
extremeConfluenceBear := enableExtremeConfluence and confluenceScore >= extremeScoreThreshold and bearishStructure and deltaBearishDivergence and volStrong and mtfBiasShort

// ============================================================
// 【实时气泡提示 - 专业升级版】
// ============================================================




bool triggerExtremeBull = extremeConfluenceBull and not lastExtremeBull
if triggerExtremeBull and barstate.isrealtime
    bubbleTextCN = "极端共振多头情报\n矩阵聚合度: " + str.tostring(math.round(confluenceScore)) + "/100\n4重确认 + Delta背离 + 放量\n强共振结构情报"
    bubbleTextEN = "Extreme Bullish Confluence Intelligence\nMatrix Score: " + str.tostring(math.round(confluenceScore)) + "/100\n4x Confirmation + Delta Divergence + Volume Surge\nInstitutional High-Probability Setup"
    f_createBubble(bubbleTextCN, bubbleTextEN, close * 1.003, label.style_label_up, color.new(#FFD700, 0), color.black)
    lastExtremeBull := extremeConfluenceBull
if not extremeConfluenceBull
    lastExtremeBull := false

bool triggerExtremeBear = extremeConfluenceBear and not lastExtremeBear
if triggerExtremeBear and barstate.isrealtime
    bubbleTextCN = "极端共振空头情报\n矩阵聚合度: " + str.tostring(math.round(confluenceScore)) + "/100\n4重确认 + Delta背离 + 放量\n强共振结构情报"
    bubbleTextEN = "Extreme Bearish Confluence Intelligence\nMatrix Score: " + str.tostring(math.round(confluenceScore)) + "/100\n4x Confirmation + Delta Divergence + Volume Surge\nInstitutional High-Probability Setup"
    f_createBubble(bubbleTextCN, bubbleTextEN, close * 0.997, label.style_label_down, color.new(#FF4500, 0), color.white)
    lastExtremeBear := extremeConfluenceBear
if not extremeConfluenceBear
    lastExtremeBear := false

bool triggerBosBull = bosBull and not lastBosBull
if triggerBosBull and barstate.isrealtime
    bubbleTextCN = "BOS多头结构突破\n矩阵聚合度: " + str.tostring(math.round(confluenceScore)) + "/100\n市场结构向上突破 + 成交量确认\n趋势延续信号"
    bubbleTextEN = "BOS Bullish Structure Break\nMatrix Score: " + str.tostring(math.round(confluenceScore)) + "/100\nBreak of Structure Up + Volume Confirmation\nTrend Continuation Signal"
    f_createBubble(bubbleTextCN, bubbleTextEN, low * 0.998, label.style_label_up, color.new(#00FF9D, 20), color.black)
    lastBosBull := bosBull
if not bosBull
    lastBosBull := false

bool triggerBosBear = bosBear and not lastBosBear
if triggerBosBear and barstate.isrealtime
    bubbleTextCN = "BOS空头结构突破\n矩阵聚合度: " + str.tostring(math.round(confluenceScore)) + "/100\n市场结构向下突破 + 成交量确认\n趋势延续信号"
    bubbleTextEN = "BOS Bearish Structure Break\nMatrix Score: " + str.tostring(math.round(confluenceScore)) + "/100\nBreak of Structure Down + Volume Confirmation\nTrend Continuation Signal"
    f_createBubble(bubbleTextCN, bubbleTextEN, high * 1.002, label.style_label_down, color.new(#FF3B5C, 20), color.white)
    lastBosBear := bosBear
if not bosBear
    lastBosBear := false

bool triggerChochBull = chochBull and not lastChochBull
if triggerChochBull and barstate.isrealtime
    bubbleTextCN = "CHOCH多头结构转变\n矩阵聚合度: " + str.tostring(math.round(confluenceScore)) + "/100\n市场结构向上转变\n潜在趋势反转信号"
    bubbleTextEN = "CHOCH Bullish Structure Shift\nMatrix Score: " + str.tostring(math.round(confluenceScore)) + "/100\nChange of Character Up\nPotential Trend Reversal Signal"
    f_createBubble(bubbleTextCN, bubbleTextEN, low * 0.998, label.style_label_up, color.new(#00FF9D, 20), color.black)
    lastChochBull := chochBull
if not chochBull
    lastChochBull := false

bool triggerChochBear = chochBear and not lastChochBear
if triggerChochBear and barstate.isrealtime
    bubbleTextCN = "CHOCH空头结构转变\n矩阵聚合度: " + str.tostring(math.round(confluenceScore)) + "/100\n市场结构向下转变\n潜在趋势反转信号"
    bubbleTextEN = "CHOCH Bearish Structure Shift\nMatrix Score: " + str.tostring(math.round(confluenceScore)) + "/100\nChange of Character Down\nPotential Trend Reversal Signal"
    f_createBubble(bubbleTextCN, bubbleTextEN, high * 1.002, label.style_label_down, color.new(#FF3B5C, 20), color.white)
    lastChochBear := chochBear
if not chochBear
    lastChochBear := false

bool triggerMssBull = mssBull and not lastMssBull
if triggerMssBull and barstate.isrealtime
    bubbleTextCN = "MSS多头市场结构转变\n矩阵聚合度: " + str.tostring(math.round(confluenceScore)) + "/100\n高级市场结构转变\n反转确认信号"
    bubbleTextEN = "MSS Bullish Market Structure Shift\nMatrix Score: " + str.tostring(math.round(confluenceScore)) + "/100\nMarket Structure Shift Up\nReversal Confirmation Signal"
    f_createBubble(bubbleTextCN, bubbleTextEN, low * 0.998, label.style_label_up, color.new(#00FF9D, 20), color.black)
    lastMssBull := mssBull
if not mssBull
    lastMssBull := false

bool triggerMssBear = mssBear and not lastMssBear
if triggerMssBear and barstate.isrealtime
    bubbleTextCN = "MSS空头市场结构转变\n矩阵聚合度: " + str.tostring(math.round(confluenceScore)) + "/100\n高级市场结构转变\n反转确认信号"
    bubbleTextEN = "MSS Bearish Market Structure Shift\nMatrix Score: " + str.tostring(math.round(confluenceScore)) + "/100\nMarket Structure Shift Down\nReversal Confirmation Signal"
    f_createBubble(bubbleTextCN, bubbleTextEN, high * 1.002, label.style_label_down, color.new(#FF3B5C, 20), color.white)
    lastMssBear := mssBear
if not mssBear
    lastMssBear := false

bool triggerBreakerBull = breakerBull and not lastBreakerBullState
if triggerBreakerBull and barstate.isrealtime
    bubbleTextCN = "Breaker Block多头\n矩阵聚合度: " + str.tostring(math.round(confluenceScore)) + "/100\nBreaker Block强支撑反转区\n机构级支撑信号"
    bubbleTextEN = "Breaker Block Bullish\nMatrix Score: " + str.tostring(math.round(confluenceScore)) + "/100\nBreaker Block Strong Support Reversal Zone\nInstitutional Support Signal"
    f_createBubble(bubbleTextCN, bubbleTextEN, low * 0.998, label.style_label_up, color.new(#00FF9D, 20), color.black)
    lastBreakerBullState := breakerBull
if not breakerBull
    lastBreakerBullState := false

bool triggerBreakerBear = breakerBear and not lastBreakerBearState
if triggerBreakerBear and barstate.isrealtime
    bubbleTextCN = "Breaker Block空头\n矩阵聚合度: " + str.tostring(math.round(confluenceScore)) + "/100\nBreaker Block强阻力反转区\n机构级阻力信号"
    bubbleTextEN = "Breaker Block Bearish\nMatrix Score: " + str.tostring(math.round(confluenceScore)) + "/100\nBreaker Block Strong Resistance Reversal Zone\nInstitutional Resistance Signal"
    f_createBubble(bubbleTextCN, bubbleTextEN, high * 1.002, label.style_label_down, color.new(#FF3B5C, 20), color.white)
    lastBreakerBearState := breakerBear
if not breakerBear
    lastBreakerBearState := false

bool triggerLiquidityHigh = not na(liquidityHigh) and not lastLiquidityHigh
if triggerLiquidityHigh and barstate.isrealtime
    bubbleTextCN = "流动性扫荡↑\n矩阵聚合度: " + str.tostring(math.round(confluenceScore)) + "/100\n机构诱多收集流动性\n警惕假突破陷阱"
    bubbleTextEN = "Liquidity Sweep Up\nMatrix Score: " + str.tostring(math.round(confluenceScore)) + "/100\nInstitutional Liquidity Grab (Bull Trap)\nBeware Fake Breakout"
    f_createBubble(bubbleTextCN, bubbleTextEN, high * 1.002, label.style_label_down, color.new(color.fuchsia, 0), color.white)
    lastLiquidityHigh := true
else
    lastLiquidityHigh := not na(liquidityHigh)



bool triggerFvgUp = not na(fvgUp) and not lastFvgUp
if triggerFvgUp and barstate.isrealtime
    bubbleTextCN = "FVG向上缺口\n矩阵聚合度: " + str.tostring(math.round(confluenceScore)) + "/100\n公平价值缺口向上\n机构回补目标区"
    bubbleTextEN = "FVG Up Gap\nMatrix Score: " + str.tostring(math.round(confluenceScore)) + "/100\nFair Value Gap Up\nInstitutional Fill Target Zone"
    f_createBubble(bubbleTextCN, bubbleTextEN, fvgUp, label.style_label_up, color.new(color.lime, 30), color.black)
    lastFvgUp := true
else
    lastFvgUp := not na(fvgUp)

bool triggerFvgDn = not na(fvgDn) and not lastFvgDn
if triggerFvgDn and barstate.isrealtime
    bubbleTextCN = "FVG向下缺口\n矩阵聚合度: " + str.tostring(math.round(confluenceScore)) + "/100\n公平价值缺口向下\n机构回补目标区"
    bubbleTextEN = "FVG Down Gap\nMatrix Score: " + str.tostring(math.round(confluenceScore)) + "/100\nFair Value Gap Down\nInstitutional Fill Target Zone"
    f_createBubble(bubbleTextCN, bubbleTextEN, fvgDn, label.style_label_down, color.new(color.red, 30), color.white)
    lastFvgDn := true
else
    lastFvgDn := not na(fvgDn)

























bool triggerBBLong = bbBreakoutLong and not lastBBLong
if triggerBBLong and barstate.isrealtime
    bubbleTextCN = "布林带看多突破\n矩阵聚合度: " + str.tostring(math.round(confluenceScore)) + "/100\n布林带向上扩张突破\n波动率扩张多头信号"
    bubbleTextEN = "BB Bullish Breakout\nMatrix Score: " + str.tostring(math.round(confluenceScore)) + "/100\nBollinger Bands Up Expansion\nVolatility Expansion Bull Signal"
    f_createBubble(bubbleTextCN, bubbleTextEN, close * 1.002, label.style_label_up, color.new(color.orange, 20), color.black)
    lastBBLong := true
else
    lastBBLong := bbBreakoutLong

bool triggerBBShort = bbBreakoutShort and not lastBBShort
if triggerBBShort and barstate.isrealtime
    bubbleTextCN = "布林带看空突破\n矩阵聚合度: " + str.tostring(math.round(confluenceScore)) + "/100\n布林带向下扩张突破\n波动率扩张空头信号"
    bubbleTextEN = "BB Bearish Breakout\nMatrix Score: " + str.tostring(math.round(confluenceScore)) + "/100\nBollinger Bands Down Expansion\nVolatility Expansion Bear Signal"
    f_createBubble(bubbleTextCN, bubbleTextEN, close * 0.998, label.style_label_down, color.new(color.orange, 20), color.white)
    lastBBShort := true
else
    lastBBShort := bbBreakoutShort

bool triggerRsiBull = rsiBullishDivergence and not lastRsiBullDiv
if triggerRsiBull and barstate.isrealtime
    bubbleTextCN = "RSI看多背离\n矩阵聚合度: " + str.tostring(math.round(confluenceScore)) + "/100\nRSI看多背离\n价格新低而RSI更高"
    bubbleTextEN = "RSI Bullish Divergence\nMatrix Score: " + str.tostring(math.round(confluenceScore)) + "/100\nRSI Bullish Divergence\nPrice Lower Low, RSI Higher Low"
    f_createBubble(bubbleTextCN, bubbleTextEN, low * 0.998, label.style_label_up, color.new(#00FF9D, 30), color.black)
    lastRsiBullDiv := true
else
    lastRsiBullDiv := rsiBullishDivergence

bool triggerRsiBear = rsiBearishDivergence and not lastRsiBearDiv
if triggerRsiBear and barstate.isrealtime
    bubbleTextCN = "RSI看空背离\n矩阵聚合度: " + str.tostring(math.round(confluenceScore)) + "/100\nRSI看空背离\n价格新高而RSI更低"
    bubbleTextEN = "RSI Bearish Divergence\nMatrix Score: " + str.tostring(math.round(confluenceScore)) + "/100\nRSI Bearish Divergence\nPrice Higher High, RSI Lower High"
    f_createBubble(bubbleTextCN, bubbleTextEN, high * 1.002, label.style_label_down, color.new(#FF3B5C, 30), color.white)
    lastRsiBearDiv := true
else
    lastRsiBearDiv := rsiBearishDivergence

bool triggerMacdBull = macdBullishDivergence and not lastMacdBullDiv
if triggerMacdBull and barstate.isrealtime
    bubbleTextCN = "MACD看多背离\n矩阵聚合度: " + str.tostring(math.round(confluenceScore)) + "/100\nMACD看多背离\n价格新低而MACD更高"
    bubbleTextEN = "MACD Bullish Divergence\nMatrix Score: " + str.tostring(math.round(confluenceScore)) + "/100\nMACD Bullish Divergence\nPrice Lower Low, MACD Higher Low"
    f_createBubble(bubbleTextCN, bubbleTextEN, low * 0.998, label.style_label_up, color.new(#00FF9D, 30), color.black)
    lastMacdBullDiv := true
else
    lastMacdBullDiv := macdBullishDivergence

bool triggerMacdBear = macdBearishDivergence and not lastMacdBearDiv
if triggerMacdBear and barstate.isrealtime
    bubbleTextCN = "MACD看空背离\n矩阵聚合度: " + str.tostring(math.round(confluenceScore)) + "/100\nMACD看空背离\n价格新高而MACD更低"
    bubbleTextEN = "MACD Bearish Divergence\nMatrix Score: " + str.tostring(math.round(confluenceScore)) + "/100\nMACD Bearish Divergence\nPrice Higher High, MACD Lower High"
    f_createBubble(bubbleTextCN, bubbleTextEN, high * 1.002, label.style_label_down, color.new(#FF3B5C, 30), color.white)
    lastMacdBearDiv := true
else
    lastMacdBearDiv := macdBearishDivergence

bool triggerStochBull = stochBullishDivergence and not lastStochBullDiv
if triggerStochBull and barstate.isrealtime
    bubbleTextCN = "Stochastic看多背离\n矩阵聚合度: " + str.tostring(math.round(confluenceScore)) + "/100\nStochastic看多背离\n价格新低而Stoch更高"
    bubbleTextEN = "Stochastic Bullish Divergence\nMatrix Score: " + str.tostring(math.round(confluenceScore)) + "/100\nStochastic Bullish Divergence\nPrice Lower Low, Stochastic Higher Low"
    f_createBubble(bubbleTextCN, bubbleTextEN, low * 0.998, label.style_label_up, color.new(#00FF9D, 30), color.black)
    lastStochBullDiv := true
else
    lastStochBullDiv := stochBullishDivergence

bool triggerStochBear = stochBearishDivergence and not lastStochBearDiv
if triggerStochBear and barstate.isrealtime
    bubbleTextCN = "Stochastic看空背离\n矩阵聚合度: " + str.tostring(math.round(confluenceScore)) + "/100\nStochastic看空背离\n价格新高而Stoch更低"
    bubbleTextEN = "Stochastic Bearish Divergence\nMatrix Score: " + str.tostring(math.round(confluenceScore)) + "/100\nStochastic Bearish Divergence\nPrice Higher High, Stochastic Lower High"
    f_createBubble(bubbleTextCN, bubbleTextEN, high * 1.002, label.style_label_down, color.new(#FF3B5C, 30), color.white)
    lastStochBearDiv := true
else
    lastStochBearDiv := stochBearishDivergence

bool triggerSmaBull = smaAdvancedBull and not lastSmaBull
if triggerSmaBull and barstate.isrealtime
    bubbleTextCN = "SMA强多头结构\n矩阵聚合度: " + str.tostring(math.round(confluenceScore)) + "/100\n50/100/200 SMA金叉排列\n长期多头趋势确立"
    bubbleTextEN = "SMA Strong Bullish Structure\nMatrix Score: " + str.tostring(math.round(confluenceScore)) + "/100\n50/100/200 SMA Golden Cross\nLong-term Bullish Trend Confirmed"
    f_createBubble(bubbleTextCN, bubbleTextEN, low * 0.998, label.style_label_up, color.new(#00FF9D, 25), color.black)
    lastSmaBull := true
else
    lastSmaBull := smaAdvancedBull

bool triggerSmaBear = smaAdvancedBear and not lastSmaBear
if triggerSmaBear and barstate.isrealtime
    bubbleTextCN = "SMA强空头结构\n矩阵聚合度: " + str.tostring(math.round(confluenceScore)) + "/100\n50/100/200 SMA死叉排列\n长期空头趋势确立"
    bubbleTextEN = "SMA Strong Bearish Structure\nMatrix Score: " + str.tostring(math.round(confluenceScore)) + "/100\n50/100/200 SMA Death Cross\nLong-term Bearish Trend Confirmed"
    f_createBubble(bubbleTextCN, bubbleTextEN, high * 1.002, label.style_label_down, color.new(#FF3B5C, 25), color.white)
    lastSmaBear := true
else
    lastSmaBear := smaAdvancedBear

// ============================================================
// 【所有EMA均线图上文字标签】
// 在每根K线末尾（barstate.islast）为所有EMA绘制小标签，注明名称
// 位置在当前价格处，颜色与线条一致，size.tiny 避免遮挡
// ============================================================
if barstate.islast
    // 删除旧标签避免堆积
    if not na(labelFilter) 
        label.delete(labelFilter)
    if not na(labelShort1) 
        label.delete(labelShort1)
    if not na(labelShort2) 
        label.delete(labelShort2)
    if not na(labelVegas1) 
        label.delete(labelVegas1)
    if not na(labelVegas2) 
        label.delete(labelVegas2)
    if not na(labelMid1) 
        label.delete(labelMid1)
    if not na(labelMid2) 
        label.delete(labelMid2)
    if not na(labelLong1) 
        label.delete(labelLong1)
    if not na(labelLong2) 
        label.delete(labelLong2)
    if not na(labelEMA100) 
        label.delete(labelEMA100)
    if not na(labelEMA200) 
        label.delete(labelEMA200)

    // 重新创建标签 - 使用 label.style_label_left + 透明背景 + 线条颜色文字
    // 位置微调 x = bar_index + 1 让标签出现在K线右侧不遮挡
    if showFilter
        labelFilter  := label.new(bar_index + 1, pFilter,  "EMA12 / 过滤线",   style=label.style_label_left, color=na, textcolor=colFilter,     size=size.tiny)
    if showShort
        labelShort1  := label.new(bar_index + 1, pShort1,  "EMA21 / 短期上轨", style=label.style_label_left, color=na, textcolor=colShortLine,  size=size.tiny)
        labelShort2  := label.new(bar_index + 1, pShort2,  "EMA55 / 短期下轨", style=label.style_label_left, color=na, textcolor=colShortLine,  size=size.tiny)
    if showVegas
        labelVegas1  := label.new(bar_index + 1, pVegas1,  "EMA144 / Vegas上轨", style=label.style_label_left, color=na, textcolor=colVegasLine, size=size.tiny)
        labelVegas2  := label.new(bar_index + 1, pVegas2,  "EMA169 / Vegas下轨", style=label.style_label_left, color=na, textcolor=colVegasLine, size=size.tiny)
    if showMid
        labelMid1    := label.new(bar_index + 1, pMid1,    "EMA288 / 中期上轨", style=label.style_label_left, color=na, textcolor=colMidLine,   size=size.tiny)
        labelMid2    := label.new(bar_index + 1, pMid2,    "EMA338 / 中期下轨", style=label.style_label_left, color=na, textcolor=colMidLine,   size=size.tiny)
    if showLong
        labelLong1   := label.new(bar_index + 1, pLong1,   "EMA576 / 长期上轨", style=label.style_label_left, color=na, textcolor=colLongLine,  size=size.tiny)
        labelLong2   := label.new(bar_index + 1, pLong2,   "EMA676 / 长期下轨", style=label.style_label_left, color=na, textcolor=colLongLine,  size=size.tiny)
    if showEMA100
        labelEMA100  := label.new(bar_index + 1, pEMA100,  "EMA100",           style=label.style_label_left, color=na, textcolor=colEMA100Line, size=size.tiny)
    if showEMA200
        labelEMA200  := label.new(bar_index + 1, pEMA200,  "EMA200",           style=label.style_label_left, color=na, textcolor=colEMA200Line, size=size.tiny)

// ============================================================
// 【样式映射 + 绘图区】
// ============================================================
f_getStyle(s) => s == "实线" ? plot.style_line : plot.style_stepline

plot(showFilter ? pFilter : na, color=colFilter, linewidth=lineWidthFilter, style=f_getStyle(lineStyleFilter), title="过滤线 / Filter EMA12")
short1Plot = plot(showShort ? pShort1 : na, color=colShortLine, linewidth=lineWidthShort, style=f_getStyle(lineStyleShort), title="短期上轨 / Short Upper (21)")
short2Plot = plot(showShort ? pShort2 : na, color=colShortLine, linewidth=lineWidthShort, style=f_getStyle(lineStyleShort), title="短期下轨 / Short Lower (55)")
vegas1Plot = plot(showVegas ? pVegas1 : na, color=colVegasLine, linewidth=lineWidthVegas, style=f_getStyle(lineStyleVegas), title="Vegas上轨 / Vegas Upper (144)")
vegas2Plot = plot(showVegas ? pVegas2 : na, color=colVegasLine, linewidth=lineWidthVegas, style=f_getStyle(lineStyleVegas), title="Vegas下轨 / Vegas Lower (169)")
mid1Plot = plot(showMid ? pMid1 : na, color=colMidLine, linewidth=lineWidthMid, style=f_getStyle(lineStyleMid), title="中期上轨 / Mid Upper (288)")
mid2Plot = plot(showMid ? pMid2 : na, color=colMidLine, linewidth=lineWidthMid, style=f_getStyle(lineStyleMid), title="中期下轨 / Mid Lower (338)")
long1Plot = plot(showLong ? pLong1 : na, color=colLongLine, linewidth=lineWidthLong, style=f_getStyle(lineStyleLong), title="长期上轨 / Long Upper (576)")
long2Plot = plot(showLong ? pLong2 : na, color=colLongLine, linewidth=lineWidthLong, style=f_getStyle(lineStyleLong), title="长期下轨 / Long Lower (676)")

// 新增 EMA100 / EMA200 独立绘图 (默认开启)
ema100Plot = plot(showEMA100 ? pEMA100 : na, color=colEMA100Line, linewidth=lineWidthEMA100, style=f_getStyle(lineStyleEMA100), title="EMA100")
ema200Plot = plot(showEMA200 ? pEMA200 : na, color=colEMA200Line, linewidth=lineWidthEMA200, style=f_getStyle(lineStyleEMA200), title="EMA200")

fill(short1Plot, short2Plot, color=color.new(colShortFill, transShort))
fill(vegas1Plot, vegas2Plot, color=color.new(colVegasFill, transVegas))
fill(mid1Plot, mid2Plot, color=color.new(colMidFill, transMid))
fill(long1Plot, long2Plot, color=color.new(colLongFill, transLong))

// VWAP plots removed (module deleted)

bbPlotUpper = plot(showBB ? bbUpper : na, color=colBBLine, linewidth=1, title="布林带上轨 / BB Upper")
bbPlotLower = plot(showBB ? bbLower : na, color=colBBLine, linewidth=1, title="布林带下轨 / BB Lower")
fill(bbPlotUpper, bbPlotLower, color=color.new(colBBFill, 80))

plot(showOB ? lastOBBull : na, color=color.new(color.green, 0), linewidth=2, style=plot.style_circles, title="看多订单块 / Bullish OB")
plot(showOB ? lastOBBear : na, color=color.new(color.red, 0), linewidth=2, style=plot.style_circles, title="看空订单块 / Bearish OB")

plot(showDeltaPressureLine ? deltaMA_norm : na, color=color.new(color.fuchsia, 0), linewidth=2, title="Delta压力线 / Delta Pressure Line (已归一化)")

// CVD plot removed (module deleted)

// ============================================================
// 【超级信息面板 - 已优化】
// ============================================================
showPanelFinal = showInfoPanel
tablePos = panelPosition == "Top Left" ? position.top_left : panelPosition == "Top Right" ? position.top_right : panelPosition == "Bottom Left" ? position.bottom_left : position.bottom_right
var table priceTable = table.new(tablePos, 2, 30, bgcolor=color.new(#000000, 0), border_width=1, border_color=color.new(#B0B0B0, 50))  // 深黑纯黑底（#000000）+ 浅灰细边框

f(val) => str.tostring(val, "#.##")
distPercent = (close - (pVegas1 + pVegas2)/2) / ((pVegas1 + pVegas2)/2) * 100

filterSug = close > pFilter ? "多头结构 / Bullish Structure" : "空头结构 / Bearish Structure"
shortSug  = close > pShort1 ? "多头结构 / Bullish Structure" : "空头结构 / Bearish Structure"
vegasSug  = close > pVegas1 ? "多头结构 / Bullish Structure" : "空头结构 / Bearish Structure"
midSug    = close > pMid1 ? "多头结构 / Bullish Structure" : "空头结构 / Bearish Structure"
longSug   = close > pLong1 ? "多头结构 / Bullish Structure" : "空头结构 / Bearish Structure"

overallSug = extremeConfluenceBull ? "极端共振多头情报 / Extreme Bullish Intelligence" : extremeConfluenceBear ? "极端共振空头情报 / Extreme Bearish Intelligence" : bullishStructure ? "强多头结构 / Strong Bullish Structure" : bearishStructure ? "强空头结构 / Strong Bearish Structure" : "中性结构 / Neutral Structure"
overallColor = extremeConfluenceBull ? color.new(#FFD700, 0) : extremeConfluenceBear ? color.new(#FF4500, 0) : bullishStructure ? color.new(#00FF9D, 0) : bearishStructure ? color.new(#FF3B5C, 0) : color.new(#FFD700, 0)

if showPanelFinal and barstate.islast
    table.cell(priceTable, 0, 0, "秋AI-Vegas智能共振信息情报流\nQAI · Vegas Intelligent Confluence Market Intelligence Stream", text_color=color.new(#00FFEA, 0), text_size=size.small, text_halign=text.align_center, bgcolor=color.new(color.black, 0))
    table.merge_cells(priceTable, 0, 0, 1, 0)  // 纯黑底 + 霓虹青标题，极致醒目
    
    table.cell(priceTable, 0, 1, "长期通道 / Long Channel", text_color=colLongLine, text_size=size.tiny, text_halign=text.align_center)
    table.cell(priceTable, 1, 1, f(pLong1) + "/" + f(pLong2) + " " + longSug, text_color=colLongLine, text_size=size.tiny, text_halign=text.align_center)
    
    table.cell(priceTable, 0, 2, "中期通道 / Mid Channel", text_color=colMidLine, text_size=size.tiny, text_halign=text.align_center)
    table.cell(priceTable, 1, 2, f(pMid1) + "/" + f(pMid2) + " " + midSug, text_color=colMidLine, text_size=size.tiny, text_halign=text.align_center)
    
    table.cell(priceTable, 0, 3, "Vegas隧道 / Vegas Tunnel", text_color=colVegasLine, text_size=size.tiny, text_halign=text.align_center)
    table.cell(priceTable, 1, 3, f(pVegas1) + "/" + f(pVegas2) + " " + vegasSug, text_color=colVegasLine, text_size=size.tiny, text_halign=text.align_center)
    
    table.cell(priceTable, 0, 4, "短期通道 / Short Channel", text_color=colShortLine, text_size=size.tiny, text_halign=text.align_center)
    table.cell(priceTable, 1, 4, f(pShort1) + "/" + f(pShort2) + " " + shortSug, text_color=colShortLine, text_size=size.tiny, text_halign=text.align_center)
    
    table.cell(priceTable, 0, 5, "过滤线EMA12 / Filter EMA12", text_color=color.white, text_size=size.tiny, text_halign=text.align_center)
    table.cell(priceTable, 1, 5, f(pFilter) + " " + filterSug, text_color=color.white, text_size=size.tiny, bgcolor=close > pFilter ? color.new(#00FF9D, 85) : color.new(#FF3B5C, 85), text_halign=text.align_center)
    
    table.cell(priceTable, 0, 6, "Vegas距离% / Dist %", text_color=color.yellow, text_size=size.tiny, text_halign=text.align_center)
    table.cell(priceTable, 1, 6, f(distPercent) + "%", text_color=color.yellow, text_size=size.tiny, text_halign=text.align_center)
    
    table.cell(priceTable, 0, 7, "当前价格 / Price", text_color=color.yellow, text_size=size.tiny, text_halign=text.align_center)
    table.cell(priceTable, 1, 7, f(close), text_color=color.yellow, text_size=size.tiny, text_halign=text.align_center)
    
    table.cell(priceTable, 0, 8, "RSI背离 / RSI Div", text_color=color.white, text_size=size.tiny, text_halign=text.align_center)
    table.cell(priceTable, 1, 8, rsiBullishDivergence ? "看多 / Bullish" : rsiBearishDivergence ? "看空 / Bearish" : "中性 / Neutral", text_color=rsiBullishDivergence ? color.new(#00FF9D, 0) : rsiBearishDivergence ? color.new(#FF3B5C, 0) : color.gray, text_size=size.tiny, text_halign=text.align_center)
    
    table.cell(priceTable, 0, 9, "MACD背离 / MACD Div", text_color=color.white, text_size=size.tiny, text_halign=text.align_center)
    table.cell(priceTable, 1, 9, macdBullishDivergence ? "看多 / Bullish" : macdBearishDivergence ? "看空 / Bearish" : "中性 / Neutral", text_color=macdBullishDivergence ? color.new(#00FF9D, 0) : macdBearishDivergence ? color.new(#FF3B5C, 0) : color.gray, text_size=size.tiny, text_halign=text.align_center)
    
    table.cell(priceTable, 0, 10, "Stochastic背离 / Stochastic Div", text_color=color.white, text_size=size.tiny, text_halign=text.align_center)
    table.cell(priceTable, 1, 10, stochBullishDivergence ? "看多 / Bullish" : stochBearishDivergence ? "看空 / Bearish" : "中性 / Neutral", text_color=stochBullishDivergence ? color.new(#00FF9D, 0) : stochBearishDivergence ? color.new(#FF3B5C, 0) : color.gray, text_size=size.tiny, text_halign=text.align_center)
    
    table.cell(priceTable, 0, 11, "布林带 / BB", text_color=color.white, text_size=size.tiny, text_halign=text.align_center)
    table.cell(priceTable, 1, 11, bbBreakoutLong ? "看多 / Bullish" : bbBreakoutShort ? "看空 / Bearish" : "中性 / Neutral", text_color=bbBreakoutLong ? color.new(#00FF9D, 0) : bbBreakoutShort ? color.new(#FF3B5C, 0) : color.gray, text_size=size.tiny, text_halign=text.align_center)
    
    table.cell(priceTable, 0, 12, "成交量 / Volume", text_color=color.white, text_size=size.tiny, text_halign=text.align_center)
    table.cell(priceTable, 1, 12, volRising ? "放量多头结构 / Volume Bullish Structure" : "萎缩空头结构 / Volume Bearish Structure", text_color=volRising ? color.new(#00FF9D, 0) : color.new(#FF3B5C, 0), text_size=size.tiny, text_halign=text.align_center)
    
    table.cell(priceTable, 0, 13, "资金流Delta / Delta Flow", text_color=color.fuchsia, text_size=size.tiny, text_halign=text.align_center)
    table.cell(priceTable, 1, 13, delta > 0 ? "资金流入 / Capital Inflow" : "资金流出 / Capital Outflow", text_color=delta > 0 ? color.new(#00FF9D, 0) : color.new(#FF3B5C, 0), text_size=size.tiny, text_halign=text.align_center)
    
    table.cell(priceTable, 0, 14, "Delta结构情报 / Delta Structure Intelligence", text_color=color.fuchsia, text_size=size.tiny, text_halign=text.align_center)
    table.cell(priceTable, 1, 14, deltaPractical, text_color=deltaPractical == "强看多结构情报 / Strong Bullish Structure Intelligence" ? color.new(#00FF9D, 0) : deltaPractical == "强看空结构情报 / Strong Bearish Structure Intelligence" ? color.new(#FF3B5C, 0) : color.gray, text_size=size.tiny, text_halign=text.align_center)
    
    table.cell(priceTable, 0, 18, "综合市场结构 / Overall Market Structure", text_color=color.white, text_size=size.tiny, text_halign=text.align_center)
    table.cell(priceTable, 1, 18, overallSug, text_color=overallColor, text_size=size.tiny, bgcolor=color.new(overallColor, 60), text_halign=text.align_center)
    
    table.cell(priceTable, 0, 24, "SMA高级结构分析 / SMA Advanced Structure Analysis", text_color=color.white, text_size=size.tiny, text_halign=text.align_center)
    table.cell(priceTable, 1, 24, smaAdvancedStatus, text_color=smaAdvancedBull ? color.new(#00FF9D, 0) : smaAdvancedBear ? color.new(#FF3B5C, 0) : color.gray, text_size=size.tiny, text_halign=text.align_center)
    
    moonBg = moonAge < 14.765 ? color.new(#FFD700, 80) : color.new(#C0C0C0, 80)
    table.cell(priceTable, 0, 25, "月相周期 / Moon Phase", text_color=color.white, text_size=size.tiny, text_halign=text.align_center)
    table.cell(priceTable, 1, 25, showMoonPhase ? moonPhaseText + " " + moonSymbol : "已关闭 / Off", text_color=showMoonPhase ? color.new(#FFD700, 0) : color.gray, text_size=size.tiny, bgcolor=moonBg, text_halign=text.align_center)
    
    table.cell(priceTable, 0, 26, "趋势结构 / Trend Structure", text_color=color.white, text_size=size.tiny, text_halign=text.align_center)
    table.cell(priceTable, 1, 26, bullishStructure ? "多头 / Bullish" : bearishStructure ? "空头 / Bearish" : "震荡 / Sideways", text_color=bullishStructure ? color.new(#00FF9D, 0) : bearishStructure ? color.new(#FF3B5C, 0) : color.gray, text_size=size.tiny, text_halign=text.align_center)
    
    // Removed invalid panel rows (Advanced CVD Trend + Order Flow Imbalance)

// ============================================================
// 【背景高亮】
// ============================================================
// Imbalance background removed (module deleted)
bgcolor(extremeConfluenceBull ? color.new(#FFD700, 92) : extremeConfluenceBear ? color.new(#FF4500, 92) : na, title="Extreme Confluence Background")

// ============================================================
// 【版权声明】
// ============================================================
// © 2026 秋AI-Vegas智能共振信息情报流
// QAI · Vegas Intelligent Confluence Market Intelligence Stream
// All Rights Reserved.
````

# Market Compass - Dynamic Range Framework

- url: https://www.tradingview.com/script/fj357cmt/
- type: indicator
- pine_id: PUB;ca53d4c6d6b54643ba69da305b7034ab
- version: 3.0

## Description

[b]Hello English readers, the English version is provided below. Please scroll down to view it.[/b]

[quote]
[b]Market Compass - Dynamic Range Framework[/b]
[b]市场指南针 · 动态区间框架[/b]
[i]版本：1.0 | 类型：非预测性价格结构定位工具 | 作者：[william_wq][/i]
[/quote]

绝大多数交易亏损，根源并非方向判断错误，而是 [b]“位置感”的缺失[/b]。本指标旨在为您解决这一核心痛点——它不告诉您涨跌，但它告诉您 [b]“此时此刻，价格在地图上的精确坐标”[/b]。

---

[b][1. 是什么 (What) —— 一套主图叠加的“价格经纬度坐标系”][/b]

本指标并非传统的均线或动量振荡器，而是一个 [b]基于固定回溯周期的价格百分位区间定位系统[/b]。它以最近 N 根 K 线（默认 252 根，对应约 1 个交易年度）的最高价与最低价为天然边界，构建出一个覆盖 0% 至 100% 的[b]动态箱体网格[/b]。

该网格并非平均分割，而是采用 [b]非对称的黄金分割与极值锚定法[/b]，精确定制了 9 条关键水平轨道。这些轨道以彩色矩形色带和右侧实时浮动标签的形式，干净利落地叠加于主图 K 线之上：

[list=1]
[*][b]100% 顶部极值轨[/b]（红色）：回溯周期内的绝对天花板。
[*][b]89% 超买警戒轨[/b]（橙色）：情绪极度亢奋区，多头衰竭高发带。
[*][b]75% 强势分界轨[/b]（黄色）：牛熊分水岭，站上此线意味中期趋势转强。
[*][b]62.5% 强界枢轴轨[/b]（紫色）：多头趋势中的次级回踩支撑位。
[*][b]50% 多空中轴轨[/b]（白色）：价值均衡线，长线资金的成本密集区。
[*][b]37.5% 弱界枢轴轨[/b]（青色）：空头趋势中的次级反弹阻力位。
[*][b]25% 弱势分界轨[/b]（亮蓝）：跌破此线意味中期趋势正式转入空头。
[*][b]11% 超卖警戒轨[/b]（浅绿）：情绪极度恐慌区，空头衰竭高发带。
[*][b]0% 底部极值轨[/b]（深蓝）：回溯周期内的绝对地板。
[/list]

随着新 K 线的生成，整个框架会[b]滚动迭代[/b]，始终锚定最新的价格活动范围，确保参考坐标永不失效。

---

[b][2. 为什么 (Why) —— 解决传统 K 线分析的两大认知缺陷][/b]

传统价格图表存在严重的[b]视角局限性[/b]，导致交易者频繁陷入误判：

[list=1]
[*][b]“绝对值幻觉”与锚定效应[/b]：股价 100 元是高是低？脱离近期波动区间谈绝对价格毫无意义。本指标将价格转化为 [b]0~100 的相对百分位数[/b]，消除了价格基数的干扰，让您客观评判当前价格是“相对高位”还是“相对低位”。
[*][b]“区间失忆症”与近因偏好[/b]：人类大脑天然对最近 5~10 根 K 线赋予过高权重，极易遗忘前期关键的支撑与阻力结构。本指标通过固定窗口的滚动计算，强制将 [b]过去 N 根 K 线的价格极值[/b] 醒目地绘制在当前图表上，纠正了这种认知偏差。
[*][b]均值回归与极端磁吸理论[/b]：金融市场价格长期遵循 [b]“极端值向中轴（50% 均衡线）回归”[/b] 的统计规律。当价格进入 89% 以上或 11% 以下的极端尾部区域时，统计概率上必然面临向 50% 中轴的牵引力。本框架为这种“牵引力”提供了精确的量化刻度。
[/list]

---

[b][3. 怎么用 (How) —— 从“观察”到“决策”的完整作战手册][/b]

本指标是[b]趋势过滤、盈亏比评估与动态止盈止损[/b]的绝佳辅助工具。请勿将其视为独立入场信号，而应作为[b]“价格行为决策的量化底座”[/b]。

[b]3.1 基于市场环境的三种经典战法[/b]

[list=1]
[*][b]【趋势跟踪战法】—— 适用于强势单边行情[/b]
当价格经过充分调整后，以放量大阳线有效突破 [b]75% 强势分界轨[/b] 时，视为中期趋势由震荡转强的关键确认点。若后续价格回踩 75% 轨并获得支撑（收出长下影线），则为绝佳的[b]顺大势、逆小势[/b]加仓机会。此时可将止损设于 62.5% 强界枢轴轨下方。
[*][b]【均值回归战法】—— 适用于宽幅震荡行情[/b]
当价格快速冲高至 [b]89% 超买轨[/b] 上方，且 K 线出现明显滞涨形态（如射击之星、看跌吞没）时，可视为短线高空机会，第一目标位看向 75% 轨，第二目标位看向 50% 中轴。反之，价格急跌至 [b]11% 超卖轨[/b] 下方并出现止跌反转形态时，可视为短线低吸机会。
[*][b]【突破回踩确认战法】—— 适用于关键阻力支撑转换[/b]
任何一条百分比轨道都具备动态支撑/阻力的属性。当价格自下而上突破某一轨道（如 62.5% 轨）后，若随后缩量回踩该轨道且未跌破，则说明该轨道已由阻力转换为支撑，此处是风险收益比极高的 [b]“0 级入场点”[/b]（止损极小，空间极大）。
[/list]

[b]3.2 动态止盈与止损设置指南[/b]

[list]
[*][b]波段多头持仓[/b]：可将 [b]37.5% 弱界枢轴轨[/b] 设为最终的硬性离场线。只要价格在此轨之上，多头头寸便可安心持有，避免被早期震荡洗出。
[*][b]短线空头持仓[/b]：可将 [b]62.5% 强界枢轴轨[/b] 设为硬性止损线。一旦价格强势反抽并站上此轨，则空头逻辑被证伪，需果断离场。
[/list]

[b]3.3 参数动态调整建议（针对不同交易周期）[/b]

[list]
[*][b]日线级别（中长线 / 波段）[/b]：建议保持默认 [b]252[/b]（约 1 年交易日），用于捕捉年度大箱体的牛熊转换。
[*][b]周线级别（大趋势 / 仓位布局）[/b]：建议调整为 [b]52[/b]（约 1 年周线），用于识别超大周期的价格百分位极值。
[*][b]小时 / 分钟级别（日内短线 / 剥头皮）[/b]：建议调整为 [b]50 ~ 100[/b]，过长的周期在分钟图上会导致框架钝化，失去短线参考意义。
[/list]

---

[b][4. 用在哪里 (Where) —— 适用品种、场景与风控红线][/b]

[b]4.1 最佳适用场景[/b]

[list]
[*][b]流动性充裕的权益市场[/b]：沪深 300、中证 500、标普 500 等主流指数及成分股。
[*][b]高流动性大宗商品与外汇[/b]：黄金、原油、欧元/美元等主要交易对。
[*][b]高市值加密货币[/b]：比特币（BTC）、以太坊（ETH）等。
[/list]

[b]4.2 禁用与慎用场景（风控红线）[/b]

[list]
[*][b]严禁用于上市不足 N 根 K 线的新股/次新股[/b]：尽管代码内置了自适应缩窄逻辑，但新股价格极不稳定，高低点极易被操纵，百分位框架参考价值极低。
[*][b]慎用于连续无量涨跌停的极端行情[/b]：在极强的单边轧空或流动性枯竭的踩踏中，价格可能长期粘合在 100% 轨之上或 0% 轨之下，此时指标出现 [b]“钝化”[/b] 现象，需立即切换至趋势跟踪指标（如 SAR 抛物线或均线系统）进行二次印证。
[*][b]慎用于高度控盘的“庄股”或低成交量仙股[/b]：稀疏的成交导致价格跳跃性极大，计算出的区间极易失真。
[/list]

---

[b][5. 底层原理 (Underlying Mechanics) —— 数学引擎与渲染优化全解析][/b]

本指标严格遵循 TradingView 最佳实践，[b]完全不包含未来函数[/b]，所有信号均基于确定性的历史数据实时滚动计算。

[b]5.1 自适应周期核心算法[/b]
系统优先读取用户设定的 `lookbackLength`（默认 252）。然而，当图表加载的品种上市天数不足时，引擎会自动触发保护机制：
[pine]
effectiveLookback = math.min(i_lookbackLength, bar_index + 1)
[/pine]
该行代码确保指标在上市首日即能工作，且随着新 K 线增加，窗口期自然增长，直至达到用户设定的标准周期。

[b]5.2 九宫格线性映射（百分位分割数学）[/b]
首先确定箱体极值与范围：
[pine]
periodLow   = ta.lowest(low, effectiveLookback)   // 底部 0%
periodHigh  = ta.highest(high, effectiveLookback) // 顶部 100%
priceRange  = periodHigh - periodLow
[/pine]
随后基于 [b]斐波那契数列与统计学标准差启发式阈值[/b] 进行非均匀切割：
[pine]
priceL89  = periodLow + priceRange * 0.89  // 极值警戒
priceL75  = periodLow + priceRange * 0.75  // 强市分界
priceL625 = periodLow + priceRange * 0.625 // 黄金分割枢轴
priceL50  = periodLow + priceRange * 0.50  // 均衡中轴
// ... 下方对称切割同理
[/pine]
[i]注：62.5% 与 37.5% 的选取来源于对 0.618 黄金分割率的整数微调，旨在提供比传统 61.8% 更为清晰且易于记忆的刻度。[/i]

[b]5.3 图形渲染引擎优化（内存与性能管理）[/b]
为了避免在大量历史 K 线上重复绘制矩形和线条导致图表卡顿，引擎采用 [b]“惰性删除与单次实例化”[/b] 策略：
[pine]
if barstate.islast
    // 仅当加载完成且运行至图表最右侧时触发绘制
    box.delete(boxMain)   // 先销毁旧句柄
    line.delete(lineL100) // 清理旧线
    // ... 重新创建新对象
[/pine]
所有标签采用 [b]label.style_label_left[/b] 右对齐样式，确保在图表最右侧整齐排列，绝不遮挡最新的 K 线实体，同时提供精确至交易所最小报价单位（`format.mintick`）的实时读数。

---

[b][6. 总结：该指标的哲学定位][/b]

它不是占卜未来的水晶球，而是衡量当下的卡尺。
在充满不确定性的金融市场中，[b]“位置感”[/b]是纪律执行的基石。`Market Compass` 为您提供的不是圣杯，而是一张永远保持更新的[b]战场态势感知地图[/b]。请将它融入您现有的交易系统中，作为过滤低质量交易机会的第一道关卡。

---

[b][免责声明][/b]
[i]本指标及此说明文件仅供教育及技术分析参考之用，绝不构成任何形式的买入、卖出或持仓建议。金融衍生品及证券交易蕴含巨大风险，过往价格结构及百分位分布不构成对未来走势的绝对保证。您必须结合自身财务状况、风险承受能力及独立研判做出交易决策，盈亏自负。作者不承担任何因使用本指标而产生的直接或间接损失。[/i]

---

[b]如果您认可这套价格定位逻辑，欢迎点赞、收藏并关注！[/b]
期待您在评论区分享将该框架融入实战交易后的心得体会。


[quote]
[b]Market Compass - Dynamic Range Framework[/b]
[i]Version: 1.0 | Type: Non-Predictive Price Structure Positioning Tool | Author: [william_wq][/i]
[/quote]

The vast majority of trading losses stem not from incorrect directional judgment, but from a [b]lack of "positional awareness"[/b]. This indicator addresses this core pain point — it does not tell you whether price will go up or down, but it does tell you [b]"the precise coordinates of price on the map, at this very moment"[/b].

---

[b][1. What It Is — A "Price Latitude & Longitude Coordinate System" Overlaid on the Main Chart][/b]

This indicator is not a traditional moving average or momentum oscillator. Instead, it is a [b]price percentile range positioning system based on a fixed lookback period[/b]. It uses the highest high and lowest low over the most recent N bars (default 252, corresponding to approximately one trading year) as natural boundaries, constructing a [b]dynamic box grid[/b] spanning from 0% to 100%.

The grid is not evenly divided. It employs an [b]asymmetric golden ratio and extreme-value anchoring methodology[/b] to precisely define 9 key horizontal threshold levels. These levels are cleanly overlaid on the main price chart using colored rectangular bands and real-time right-aligned floating labels:

[list=1]
[*][b]100% Peak Threshold[/b] (Red): The absolute ceiling within the lookback period.
[*][b]89% Overbought Warning Zone[/b] (Orange): Extreme euphoria zone; high probability of bullish exhaustion.
[*][b]75% Bullish Boundary[/b] (Yellow): The bull-bear dividing line; breaking above signals medium-term strength.
[*][b]62.5% Bull Pivot Threshold[/b] (Purple): Secondary retracement support level within an uptrend.
[*][b]50% Equilibrium Axis[/b] (White): The value equilibrium line; a dense area of long-term capital cost.
[*][b]37.5% Bear Pivot Threshold[/b] (Cyan): Secondary retracement resistance level within a downtrend.
[*][b]25% Bearish Boundary[/b] (Light Blue): Breaking below signals a confirmed medium-term bearish trend.
[*][b]11% Oversold Warning Zone[/b] (Light Green): Extreme panic zone; high probability of bearish exhaustion.
[*][b]0% Floor Threshold[/b] (Dark Blue): The absolute floor within the lookback period.
[/list]

As new bars are generated, the entire framework [b]rolls forward iteratively[/b], always anchored to the most recent price activity range, ensuring the reference coordinates never become obsolete.

---

[b][2. Why It Matters — Addressing Two Critical Cognitive Biases in Traditional K-Line Analysis][/b]

Traditional price charts suffer from severe [b]perspective limitations[/b], leading traders into frequent misjudgments:

[list=1]
[*][b]"Absolute Value Illusion" and Anchoring Bias[/b]: Is a price of $100 high or low? Discussing absolute price without reference to the recent trading range is meaningless. This indicator converts price into a [b]relative percentile from 0 to 100[/b], eliminating the distortion of price magnitude and allowing you to objectively assess whether the current price is "relatively high" or "relatively low."
[*][b]"Range Amnesia" and Recency Bias[/b]: The human brain naturally assigns excessive weight to the most recent 5–10 bars, easily forgetting key prior support and resistance structures. Through rolling window calculations, this indicator forcibly and prominently plots the [b]price extremes of the past N bars[/b] on the current chart, correcting this cognitive bias.
[*][b]Mean Reversion and Extreme Magnetic Attraction Theory[/b]: Financial market prices have long exhibited a statistical tendency to [b]"revert from extreme values toward the center (50% equilibrium line)"[/b]. When price enters the extreme tail regions above 89% or below 11%, statistical probability dictates an inevitable gravitational pull toward the 50% axis. This framework provides precise quantitative刻度 for this "magnetic force."
[/list]

---

[b][3. How to Use It — A Complete Battle Manual from "Observation" to "Decision"][/b]

This indicator serves as an excellent auxiliary tool for [b]trend filtering, risk-reward assessment, and dynamic stop-loss/take-profit placement[/b]. Do not treat it as an independent entry signal; instead, regard it as a [b]"quantitative foundation for price-action decision-making."[/b]

[b]3.1 Three Classic Strategies Based on Market Context[/b]

[list=1]
[*][b]【Trend Following Strategy】— For Strong Directional Markets[/b]
When price, after sufficient consolidation, breaks decisively above the [b]75% Bullish Boundary[/b] with a high-volume bullish candle, this serves as a key confirmation that the medium-term trend is shifting from consolidation to strength. If price subsequently retests the 75% level and finds support (forming a long lower wick), it represents an excellent [b]"go with the macro trend, counter the micro pullback"[/b] add-on opportunity. In such cases, place your stop-loss below the 62.5% Bull Pivot Threshold.
[*][b]【Mean Reversion Strategy】— For Range-Bound Markets[/b]
When price spikes rapidly above the [b]89% Overbought Warning Zone[/b] and simultaneously exhibits clear exhaustion patterns (such as shooting stars or bearish engulfing), this can be viewed as a short-term selling opportunity. The first target is the 75% level, and the second target is the 50% Equilibrium Axis. Conversely, when price plummets below the [b]11% Oversold Warning Zone[/b] and shows reversal signals, a short-term buying opportunity emerges.
[*][b]【Breakout-Pullback Confirmation Strategy】— For Key Support/Resistance Transitions[/b]
Every percentage threshold possesses dynamic support/resistance properties. When price breaks upward through a given level (e.g., the 62.5% level) and subsequently retests that level on diminishing volume without breaking back below, this confirms that the level has successfully transitioned from resistance to support. This represents a highly favorable [b]"Grade-A Entry Point"[/b] (minimal stop-loss, substantial upside potential).
[/list]

[b]3.2 Dynamic Stop-Loss and Take-Profit Placement Guide[/b]

[list]
[*][b]Swing Long Positions[/b]: Use the [b]37.5% Bear Pivot Threshold[/b] as your ultimate hard exit line. As long as price remains above this level, you can confidently hold your long position, avoiding premature exits caused by early-stage volatility.
[*][b]Short-Term Short Positions[/b]: Use the [b]62.5% Bull Pivot Threshold[/b] as your hard stop-loss line. Should price stage a strong rally and close above this level, the bearish thesis is invalidated, and you must exit decisively.
[/list]

[b]3.3 Parameter Adjustment Recommendations (By Trading Timeframe)[/b]

[list]
[*][b]Daily Chart (Swing / Medium-to-Long Term)[/b]: Keep the default [b]252[/b] (approximately one trading year), ideal for capturing annual bull-bear transitions.
[*][b]Weekly Chart (Macro Trend / Position Sizing)[/b]: Consider adjusting to [b]52[/b] (approximately one year of weekly bars) for identifying extreme percentiles within broader cycles.
[*][b]Hourly / Minute Charts (Intraday / Scalping)[/b]: Consider adjusting to [b]50–100[/b]. Longer lookbacks on lower timeframes cause the framework to become overly rigid, diminishing its short-term relevance.
[/list]

---

[b][4. Where to Apply It — Suitable Instruments, Scenarios, and Risk Red Lines][/b]

[b]4.1 Optimal Use Cases[/b]

[list]
[*][b]Highly Liquid Equity Markets[/b]: CSI 300, S&P 500, major index constituents, and liquid individual stocks.
[*][b]High-Liquidity Commodities and FX[/b]: Gold, Crude Oil, EUR/USD, and other major pairs.
[*][b]Large-Cap Cryptocurrencies[/b]: Bitcoin (BTC), Ethereum (ETH), and similar assets.
[/list]

[b]4.2 Scenarios to Avoid or Use with Caution (Risk Red Lines)[/b]

[list]
[*][b]Strictly avoid newly listed stocks with fewer than N bars of history[/b]: Although the code includes a built-in adaptive shortening mechanism, new issues are extremely unstable, and their highs/lows are vulnerable to manipulation, rendering the percentile framework nearly worthless.
[*][b]Use with caution during continuous limit-up/limit-down extreme conditions[/b]: In powerful short squeezes or liquidity-driven crashes, price may remain persistently glued above the 100% level or below the 0% level. In such cases, the indicator becomes [b]"blunted"[/b], and you must immediately switch to trend-following tools (such as SAR or moving average systems) for secondary confirmation.
[*][b]Avoid low-float "pump-and-dump" penny stocks[/b]: Sparse trading volume leads to erratic price jumps, causing the computed range to become highly distorted.
[/list]

---

[b][5. Underlying Mechanics — A Comprehensive Breakdown of the Mathematical Engine and Rendering Optimization][/b]

This indicator strictly adheres to TradingView best practices and [b]contains absolutely no future functions[/b]. All signals are computed in real time based on deterministic historical data.

[b]5.1 Adaptive Lookback Core Algorithm[/b]
The system first reads the user-defined `lookbackLength` (default 252). However, when the loaded instrument has fewer total bars on the chart than the configured period, the engine automatically triggers a protective mechanism:
[pine]
effectiveLookback = math.min(i_lookbackLength, bar_index + 1)
[/pine]
This single line ensures the indicator functions from the very first trading day, and the window gradually expands as new bars are added until it reaches the user's desired standard period.

[b]5.2 Nine-Level Linear Mapping (Percentile Segmentation Mathematics)[/b]
The process begins by determining the box extremes and range:
[pine]
periodLow   = ta.lowest(low, effectiveLookback)   // Floor at 0%
periodHigh  = ta.highest(high, effectiveLookback) // Peak at 100%
priceRange  = periodHigh - periodLow
[/pine]
The range is then divided using a [b]heuristic blend of Fibonacci ratios and statistically inspired thresholds[/b]:
[pine]
priceL89  = periodLow + priceRange * 0.89  // Extreme warning
priceL75  = periodLow + priceRange * 0.75  // Bullish boundary
priceL625 = periodLow + priceRange * 0.625 // Golden ratio pivot
priceL50  = periodLow + priceRange * 0.50  // Equilibrium axis
// ... Symmetrical lower-level calculations follow the same logic
[/pine]
[i]Note: The selection of 62.5% and 37.5% is derived from a slight integer adjustment to the 0.618 golden ratio, intended to provide cleaner and more memorable reference刻度 than the traditional 61.8%. [/i]

[b]5.3 Rendering Engine Optimization (Memory & Performance Management)[/b]
To prevent chart lag caused by repeatedly drawing rectangles and lines across numerous historical bars, the engine employs a [b]"lazy deletion with single-instantiation"[/b] strategy:
[pine]
if barstate.islast
    // Only triggered when loaded and running at the rightmost edge of the chart
    box.delete(boxMain)   // Destroy old handles first
    line.delete(lineL100) // Clean up old lines
    // ... Then create new objects
[/pine]
All labels use the [b]label.style_label_left[/b] right-aligned format, ensuring they line up neatly on the far right of the chart without ever obscuring the most recent price bars. Prices are displayed with precision down to the exchange's minimum tick size (`format.mintick`).

---

[b][6. Conclusion — The Philosophical Positioning of This Indicator][/b]

It is not a crystal ball for predicting the future; it is a caliper for measuring the present.
In the inherently uncertain financial markets, [b]"positional awareness"[/b] is the cornerstone of disciplined execution. `Market Compass` does not offer you a holy grail; it offers you an ever-updating [b]situational awareness map of the battlefield[/b]. Integrate it into your existing trading system and use it as the first filter to eliminate low-probability trade setups.

---

[b][Disclaimer][/b]
[i]This indicator and its accompanying description are provided for educational and technical analysis purposes only. They do not constitute, and should not be construed as, any form of investment advice or recommendation to buy, sell, or hold any financial instrument. Trading securities and derivatives involves substantial risk of loss. Past price structures and percentile distributions do not guarantee future results. You are solely responsible for your own trading decisions, taking into account your financial situation, risk tolerance, and independent judgment. Neither the author nor the hosting platform accepts any liability for losses arising from the use of this indicator.[/i]

---

[b]If you find this price-positioning logic valuable, please like, bookmark, and follow![/b]
I look forward to hearing how you integrate this framework into your live trading. Feel free to share your experiences and feedback in the comments section below.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © william_wq (Enhanced with Anchor/Date Range Engine)
//@version=6
indicator("Market Compass - Dynamic Range Framework", shorttitle="Market Compass Region", overlay=true)

// ============================================================================
// 1. INPUT PARAMETERS & STYLING CONFIGURATION | 输入参数与样式设置
// ============================================================================
string GRP_CORE    = "Core & Anchor Settings | 核心与锚定设置"
string GRP_VISUAL  = "UI Display Controls | 显示界面控制"
string GRP_PALETTE = "Color Palette Customization | 配色方案定制"

// --- Mode Selection & Time Controls | 模式与时间锚定控制 ---
string MODE_FIXED  = "Fixed Lookback (固定 K 线根数)"
string MODE_ANCHOR = "Anchor Date to Present (自定义起点 -> 当前)"
string MODE_RANGE  = "Custom Date Range (自定义起止时间段)"

string i_calcMode    = input.string(MODE_FIXED, title="Calculation Mode | 计算模式", options=[MODE_FIXED, MODE_ANCHOR, MODE_RANGE], group=GRP_CORE, tooltip="选择按固定 K 线计算，还是自主选择时间锚定点/时间段。")
int i_lookbackLength = input.int(252, title="Lookback Window Period | 固定周期长度 (根数)", minval=1, group=GRP_CORE, tooltip="仅在选择'固定 K 线根数'模式时生效。")

// Default date anchors are set to typical bull/bear cycle examples. 
// Adjust them to match your own analysis timeline.
int i_startTime      = input.time(timestamp("2024-01-01T00:00:00"), title="Start Time | 锚定起始时间", group=GRP_CORE, tooltip="锚定计算的起始日期时间。")
int i_endTime        = input.time(timestamp("2025-01-01T00:00:00"), title="End Time | 锚定结束时间", group=GRP_CORE, tooltip="仅在选择'自定义起止时间段'模式时生效。")

// --- Visibility Toggles | 开关控制 ---
bool i_showRegionBox   = input.bool(true,  title="Show Bounding Box | 显示周期背景矩形框", group=GRP_VISUAL)
bool i_showExtremes    = input.bool(true,  title="Show Extreme Bands (89% / 11%) | 显示 89% / 11% 超买超卖轨", group=GRP_VISUAL)
bool i_showOuterLevels = input.bool(false, title="Show Strength Boundaries (75% / 25%) | 显示 75% / 25% 强弱分界线", group=GRP_VISUAL)
bool i_showInnerLevels = input.bool(true,  title="Show Pivot Thresholds (62.5% / 37.5%) | 显示 62.5% / 37.5% 枢轴线", group=GRP_VISUAL)
bool i_showPriceLabels = input.bool(true,  title="Show Price Labels | 显示右侧实时价格标签", group=GRP_VISUAL)

// --- Size Controls | 尺寸与字号设置 ---
int    i_lineWidthBoundary = input.int(2, title="Boundary Line Width | 边界线宽度 (0%/100%)", minval=1, maxval=10, group=GRP_VISUAL)
int    i_lineWidthInner    = input.int(1, title="Inner Line Width | 内部轨迹线宽度", minval=1, maxval=10, group=GRP_VISUAL)
string i_labelSize         = input.string(size.small, title="Label Text Size | 标签字号大小", options=[size.tiny, size.small, size.normal, size.large, size.huge], group=GRP_VISUAL)

// --- Color Palette Inputs | 色彩配置 ---
color colorL100 = input.color(#ff0055, "100% Peak Threshold | 100 轨 (顶部极值)", group=GRP_PALETTE)
color colorL89  = input.color(#ff5500, "89% Overbought Zone | 89 轨 (高位超买)", group=GRP_PALETTE)
color colorL75  = input.color(#ffaa00, "75% Bullish Boundary | 75 轨 (偏强区域)", group=GRP_PALETTE)
color colorL625 = input.color(#e040fb, "62.5% Bull Pivot Threshold | 62.5 轨 (强界临界)", group=GRP_PALETTE)
color colorL50  = input.color(#ffffff, "50% Equilibrium Axis | 50 轨 (多空中轴)", group=GRP_PALETTE)
color colorL375 = input.color(#1de9b6, "37.5% Bear Pivot Threshold | 37.5 轨 (弱界临界)", group=GRP_PALETTE)
color colorL25  = input.color(#00e5ff, "25% Bearish Boundary | 25 轨 (偏弱区域)", group=GRP_PALETTE)
color colorL11  = input.color(#00f5d4, "11% Oversold Zone | 11 轨 (低位超卖)", group=GRP_PALETTE)
color colorL0   = input.color(#00bbf9, "0% Floor Threshold | 0 轨 (底部极值)", group=GRP_PALETTE)
color colorBg   = input.color(color.new(#1e293b, 88), "Background Shading | 区域背景遮罩色", group=GRP_PALETTE)

// ============================================================================
// 2. CORE QUANTITATIVE CALCULATION ENGINE | 核心量化与时间锚定引擎
// ============================================================================

// Dynamic accumulation logic for custom date modes
var float dynamicHigh     = na
var float dynamicLow      = na
var int   dynamicStartBar = na
var int   dynamicEndBar   = na

bool isAfterStart = time >= i_startTime
bool isBeforeEnd  = (i_calcMode == MODE_RANGE) ? (time <= i_endTime) : true
bool inTimeWindow = isAfterStart and isBeforeEnd

// Track dynamic high/low across historical bars if custom mode is enabled
if i_calcMode != MODE_FIXED and inTimeWindow
    if na(dynamicStartBar)
        dynamicStartBar := bar_index
        dynamicHigh     := high
        dynamicLow      := low
    else
        dynamicHigh := math.max(dynamicHigh, high)
        dynamicLow  := math.min(dynamicLow, low)
    dynamicEndBar := bar_index

// Final price boundaries selection based on mode
float periodHigh    = na
float periodLow     = na
int   leftBarOffset = na
int   boxRightBar   = na

if i_calcMode == MODE_FIXED
    int effectiveLookback = math.min(i_lookbackLength, bar_index + 1)
    periodHigh    := ta.highest(high, effectiveLookback)
    periodLow     := ta.lowest(low, effectiveLookback)
    leftBarOffset := math.max(0, bar_index - effectiveLookback + 1)
    boxRightBar   := bar_index
else
    periodHigh    := dynamicHigh
    periodLow     := dynamicLow
    leftBarOffset := dynamicStartBar
    boxRightBar   := (i_calcMode == MODE_RANGE and not na(dynamicEndBar)) ? dynamicEndBar : bar_index

// Fallback safety (e.g. if requested date range is beyond current historical data)
if na(periodHigh) or na(periodLow) or na(leftBarOffset)
    periodHigh    := high
    periodLow     := low
    leftBarOffset := bar_index
    boxRightBar   := bar_index

float priceRange = periodHigh - periodLow

// Quantile / Ratio Level Price Calculations
float priceL100 = periodHigh
float priceL89  = periodLow + priceRange * 0.89
float priceL75  = periodLow + priceRange * 0.75
float priceL625 = periodLow + priceRange * 0.625
float priceL50  = periodLow + priceRange * 0.50
float priceL375 = periodLow + priceRange * 0.375
float priceL25  = periodLow + priceRange * 0.25
float priceL11  = periodLow + priceRange * 0.11
float priceL0   = periodLow

// ============================================================================
// 3. GRAPHICAL RENDERING ENGINE | 图形渲染引擎
// ============================================================================

// Persistent Graphic Handles
var box   boxMain       = na
var box   boxOverbought = na
var box   boxOversold   = na

var line  lineL100 = na, var line lineL89 = na, var line lineL75 = na, var line lineL625 = na, var line lineL50 = na, var line lineL375 = na, var line lineL25 = na, var line lineL11 = na, var line lineL0 = na
var label labelL100 = na, var label labelL89 = na, var label labelL75 = na, var label labelL625 = na, var label labelL50 = na, var label labelL375 = na, var label labelL25 = na, var label labelL11 = na, var label labelL0 = na

if barstate.islast
    // --- Step 1: Garbage Collection | 清理上一 K 线绘图句柄 ---
    box.delete(boxMain), box.delete(boxOverbought), box.delete(boxOversold)
    
    line.delete(lineL100), line.delete(lineL89), line.delete(lineL75), line.delete(lineL625), line.delete(lineL50), line.delete(lineL375), line.delete(lineL25), line.delete(lineL11), line.delete(lineL0)
    
    label.delete(labelL100), label.delete(labelL89), label.delete(labelL75), label.delete(labelL625), label.delete(labelL50), label.delete(labelL375), label.delete(labelL25), label.delete(labelL11), label.delete(labelL0)

    // Right Boundary for horizontal extension lines & labels
    int rightBarOffset = bar_index + 8

    // --- Step 2: Render Bounding Profile Boxes | 绘制背景矩形框 ---
    if i_showRegionBox
        boxMain := box.new(leftBarOffset, priceL100, boxRightBar, priceL0, border_color=color.new(color.gray, 50), border_width=1, border_style=line.style_dashed, bgcolor=colorBg)
        
        if i_showExtremes
            boxOverbought := box.new(leftBarOffset, priceL100, boxRightBar, priceL89, border_color=color.new(colorL100, 90), bgcolor=color.new(colorL100, 92))
            boxOversold   := box.new(leftBarOffset, priceL11, boxRightBar, priceL0, border_color=color.new(colorL11, 90), bgcolor=color.new(colorL11, 92))

    // --- Step 3: Render Level Trendlines | 绘制各分界横线 ---
    lineL100 := line.new(leftBarOffset, priceL100, rightBarOffset, priceL100, color=colorL100, width=i_lineWidthBoundary, style=line.style_solid)
    
    if i_showExtremes
        lineL89  := line.new(leftBarOffset, priceL89, rightBarOffset, priceL89, color=colorL89, width=i_lineWidthInner, style=line.style_dashed)
        
    if i_showOuterLevels
        lineL75  := line.new(leftBarOffset, priceL75, rightBarOffset, priceL75, color=colorL75, width=i_lineWidthInner, style=line.style_dotted)

    if i_showInnerLevels
        lineL625 := line.new(leftBarOffset, priceL625, rightBarOffset, priceL625, color=colorL625, width=i_lineWidthInner, style=line.style_dotted)

    lineL50  := line.new(leftBarOffset, priceL50, rightBarOffset, priceL50, color=colorL50, width=i_lineWidthInner, style=line.style_dotted)

    if i_showInnerLevels
        lineL375 := line.new(leftBarOffset, priceL375, rightBarOffset, priceL375, color=colorL375, width=i_lineWidthInner, style=line.style_dotted)

    if i_showOuterLevels
        lineL25  := line.new(leftBarOffset, priceL25, rightBarOffset, priceL25, color=colorL25, width=i_lineWidthInner, style=line.style_dotted)

    if i_showExtremes
        lineL11  := line.new(leftBarOffset, priceL11, rightBarOffset, priceL11, color=colorL11, width=i_lineWidthInner, style=line.style_dashed)
        
    lineL0   := line.new(leftBarOffset, priceL0, rightBarOffset, priceL0, color=colorL0, width=i_lineWidthBoundary, style=line.style_solid)

    // --- Step 4: Render Right-aligned Data Labels | 绘制右侧数值与属性标签 ---
    if i_showPriceLabels
        labelL100 := label.new(rightBarOffset, priceL100, "100.0% Peak (最高): " + str.tostring(priceL100, format.mintick), color=color.new(colorL100, 100), textcolor=colorL100, style=label.style_label_left, size=i_labelSize)
        
        if i_showExtremes
            labelL89  := label.new(rightBarOffset, priceL89, "89.0% High (高位): " + str.tostring(priceL89, format.mintick), color=color.new(colorL89, 100), textcolor=colorL89, style=label.style_label_left, size=i_labelSize)
            
        if i_showOuterLevels
            labelL75  := label.new(rightBarOffset, priceL75, "75.0% Strong (偏强): " + str.tostring(priceL75, format.mintick), color=color.new(colorL75, 100), textcolor=colorL75, style=label.style_label_left, size=i_labelSize)

        if i_showInnerLevels
            labelL625 := label.new(rightBarOffset, priceL625, "62.5% Bull Pivot (强界): " + str.tostring(priceL625, format.mintick), color=color.new(colorL625, 100), textcolor=colorL625, style=label.style_label_left, size=i_labelSize)

        labelL50  := label.new(rightBarOffset, priceL50, "50.0% Equilibrium (中轴): " + str.tostring(priceL50, format.mintick), color=color.new(colorL50, 100), textcolor=colorL50, style=label.style_label_left, size=i_labelSize)
        
        if i_showInnerLevels
            labelL375 := label.new(rightBarOffset, priceL375, "37.5% Bear Pivot (弱界): " + str.tostring(priceL375, format.mintick), color=color.new(colorL375, 100), textcolor=colorL375, style=label.style_label_left, size=i_labelSize)

        if i_showOuterLevels
            labelL25  := label.new(rightBarOffset, priceL25, "25.0% Weak (偏弱): " + str.tostring(priceL25, format.mintick), color=color.new(colorL25, 100), textcolor=colorL25, style=label.style_label_left, size=i_labelSize)

        if i_showExtremes
            labelL11  := label.new(rightBarOffset, priceL11, "11.0% Low (低位): " + str.tostring(priceL11, format.mintick), color=color.new(colorL11, 100), textcolor=colorL11, style=label.style_label_left, size=i_labelSize)
            
        labelL0   := label.new(rightBarOffset, priceL0, "0.0% Floor (最低): " + str.tostring(priceL0, format.mintick), color=color.new(colorL0, 100), textcolor=colorL0, style=label.style_label_left, size=i_labelSize)
````

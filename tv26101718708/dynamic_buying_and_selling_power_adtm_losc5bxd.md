# Dynamic Buying and Selling Power (ADTM)

- url: https://www.tradingview.com/script/LOSC5Bxd/
- type: indicator
- pine_id: PUB;a60a159d18eb4c7db1e1baa244b3fc67
- version: 1.0

## Description

[b] 什么是 ADTM？[/b]

ADTM（Dynamic Buying and Selling Power Indicator，动态买卖气指标）是一种经典的动量与反转量化指标。它通过对比开盘价的跃升与下挫，精确量化开盘后多空双方的推进力度（即爆发力），并将这种力量对比归一化在[b] [-1, 1][/b]的固定区间内。

与传统单纯依赖收盘价（Close）的振荡指标不同，ADTM 更加关注[b]开盘价（Open）相对于前一交易日的位置以及当日极值（High/Low）的延伸空间[/b]，从而能够更敏锐地捕捉到市场资金的日内异动。

---

[b]为什么使用它？[/b]

在波诡云谲的市场中，单纯的均线或 lagging 指标容易产生钝化。ADTM 的优势在于：
[list]
[*]无量纲化区间：其输出被严格限制在[b] [-1, 1][/b]之间，避免了绝对数值对趋势研判的干扰。
[*]日内真实动能：通过计算买方动态能量（DTM）和卖方动态能量（DBM），能够更早地在左侧识别出多空力量的衰竭点。
[*]极佳的反转提示：特别适合配合超买超卖边界进行逆势（反转）波段的卡点操作。
[/list]

---

[b] 怎么用？[/b]

本指标的使用逻辑非常直观，默认参数为经典配置：[b]N = 23（求和周期），M = 8（信号均线周期）。[/b]

[list]
[*][b]左侧买点（超卖区）：[/b]
当蓝色 ADTM 曲线跌破 [b]-0.5[/b]时，意味着市场短期内空头宣泄极快，进入超卖状态。这通常是极佳的左侧分批布局或观察止跌反转的买点。
[*][b]左侧风险（超买区）：[/b]
当蓝色 ADTM 曲线突破[b] +0.5[/b]时，意味着多头短期冲锋过急，进入超买状态。此时应防范多头力竭回撤，注意锁定利润或降低仓位。
[*][b]中轴信号：[/b]
0轴为多空分界线。当 ADTM 在 0 轴上方运行时，多头占优；反之，空头占优。
[*][b]均线交叉：[/b]
蓝色主线（ADTM）与橙色信号线（MA_ADTM）的黄金交叉与死亡交叉，可作为右侧动能确认的辅助信号。
[/list]
---

[b] 在哪里用？
[/b]
本指标采用纯粹的价格几何结构算法，具有极强的普适性：

[list]
[*]适用市场：广泛适用于 A 股、美股、加密货币、商品期货以及外汇等主流交易市场。
[*]适用周期：在日线（Daily）及以上大周期中表现尤为稳定，能够有效过滤盘整期的日内噪音；在小周期（如 1H/4H）中，配合趋势背景亦可用于日内波段捕捉。
[/list]

---

[b] 原创与致谢声明[/b]

[b]指标原创作者：[/b]本指标的核心算法源自经典量化分析领域的经典设计。
[b]脚本重构与发布：[/b]由本人进行 Pine Script v6 的标准化重构、算法优化与开源发布。

[b]风险提示：[/b]任何技术指标都无法百分之百预测市场。建议将 ADTM 融入自身的交易系统中，结合量价结构、关键支撑阻力位以及严谨的资金管理共同使用。

---

[b]What is ADTM?[/b]

ADTM (Dynamic Buying and Selling Power Indicator) is a classic momentum and reversal quantification tool. It precisely quantifies the offensive strength (i.e., explosive power) of both bulls and bears after the market opens by comparing the upward jumps and downward drops of the opening price, and normalizes this power comparison within a fixed range of [b][-1, 1][/b].

Unlike traditional oscillators that rely solely on the closing price (Close), ADTM places greater emphasis on the [b]opening price (Open) relative to the previous trading day's position, as well as the extension space of the day's extremes (High/Low)[/b], enabling it to more keenly capture intraday anomalies in market capital flow.

---

[b]Why Use It?[/b]

In volatile and unpredictable markets, simple moving averages or lagging indicators are prone to desensitization (flattening). The advantages of ADTM are:
[list]
[*]Dimensionless interval: Its output is strictly confined within [-1, 1], eliminating the interference of absolute price levels on trend assessment.
[*]Intraday true momentum: By calculating Dynamic Buying Momentum (DTM) and Dynamic Selling Momentum (DBM), it can identify exhaustion points of bullish/bearish power earlier on the left side.
[*]Excellent reversal signals: Particularly well-suited for contrarian (reversal) swing trading by utilizing overbought/oversold boundaries.
[/list]

---

[b]How to Use It?[/b]

The usage logic of this indicator is highly intuitive, with default parameters set to the classic configuration: [b]N = 23 (Summation Period), M = 8 (Signal MA Period).[/b]

[list]
[*][b]Left-side Buy Signal (Oversold Zone):[/b]
When the blue ADTM line drops below -0.5, it indicates that bearish forces have been excessively unleashed in the short term, entering an oversold state. This is typically an excellent opportunity for left-side accumulation or observing for a bullish reversal.
[*][b]Left-side Risk Signal (Overbought Zone):[/b]
When the blue ADTM line rises above +0.5, it indicates that bullish forces have pushed too aggressively in the short term, entering an overbought state. At this point, one should be cautious of bullish exhaustion and pullbacks, and consider locking in profits or reducing positions.
[*][b]Zero-Line Signal:[/b]
The 0.0 axis serves as the bull-bear dividing line. When ADTM is above 0, bulls are in control; when below 0, bears are in control.
[*][b]Moving Average Crossover:[/b]
The golden cross and death cross between the blue main line (ADTM) and the orange signal line (MA_ADTM) can serve as auxiliary signals for right-side momentum confirmation.
[/list]

---

[b]Where to Use It?[/b]

This indicator employs a pure geometric price-structure algorithm, offering strong universality:

[list]
[*]Applicable Markets: Widely applicable to A-shares, U.S. stocks, cryptocurrencies, commodity futures, forex, and other major trading markets.
[*]Applicable Timeframes: Performs particularly well on Daily and higher timeframes, effectively filtering out intraday noise during consolidation periods. On lower timeframes (e.g., 1H/4H), it can also be used for intraday swing trading when combined with the broader trend context.
[/list]

---

[b]Acknowledgments & Originality Statement[/b]

[b]Original Author:[/b] The core algorithm of this indicator originates from classic designs in the field of quantitative analysis.
[b]Script Re-engineering & Release:[/b] This script has been fully refactored, optimized, and released as open-source by myself.

[b]Risk Disclaimer:[/b] No technical indicator can predict the market with 100% accuracy. It is strongly recommended to integrate ADTM into your own trading system, combining it with volume-price structure, key support/resistance levels, and strict risk management practices.

## Source Code

````pine
//@version=6
indicator("Dynamic Buying and Selling Power (ADTM)", shorttitle="ADTM", overlay=false)

// ==========================================
// 1. Inputs & Parameters
// ==========================================
int n = input.int(23, minval=2, title="Summation Period (N)")
int m = input.int(8, minval=2, title="Smoothing Period (M)")

// ==========================================
// 2. Core Calculations
// ==========================================
// Dynamic Buying Momentum (DTM)
float dtm = 0.0
if open > open[1]
    dtm := math.max(high - open, open - open[1])
else
    dtm := 0.0

// Dynamic Selling Momentum (DBM)
float dbm = 0.0
if open < open[1]
    dbm := math.max(open - low, open[1] - open)
else
    dbm := 0.0

// Sum of Buying/Selling Momentum over N periods
float sumDtm = ta.sma(dtm, n) * n
float sumDbm = ta.sma(dbm, n) * n

// Normalization logic to restrict values within [-1, 1]
float adtm = 0.0
if sumDtm > sumDbm
    adtm := (sumDtm - sumDbm) / sumDtm
else if sumDtm < sumDbm
    adtm := (sumDtm - sumDbm) / sumDbm
else
    adtm := 0.0

// M-period Simple Moving Average of ADTM
float maAdtm = ta.sma(adtm, m)

// ==========================================
// 3. Plotting & Visualization
// ==========================================
// Baseline and Thresholds
hline(0.5, "Overbought Threshold (+0.5)", color=color.new(color.red, 30), linestyle=hline.style_dashed)
hline(-0.5, "Oversold Threshold (-0.5)", color=color.new(color.green, 30), linestyle=hline.style_dashed)
hline(0.0, "Median (0.0)", color=color.new(color.gray, 50))

// Indicator Curves
plot(adtm, title="ADTM Line", color=color.blue, linewidth=2)
plot(maAdtm, title="Signal Line (MA)", color=color.orange, linewidth=1)
````

# Shadows & Engulfing Patterns

- url: https://www.tradingview.com/script/nlmYbrsB/
- type: indicator
- pine_id: PUB;e6966fa929174e8b845d9da3e4664cac
- version: 1.0

## Description

This is a minimalist, combined price action indicator designed to identify key market reversal points by detecting Long Shadows and Engulfing Patterns. Built for traders who prefer clean charts, it completely removes bulky labels and background colors in favor of micro-triangle icons.

🌟 Key Features
Dual Pattern Detection: Combines two of the most reliable candlestick reversal patterns into a single, lightweight script.
Smart Trend Filtering: Engulfing patterns utilize a built-in SMA (50/200) trend filter to ensure signals only trigger at the end of established trends, significantly reducing false breakouts.
Ultra-Clean Visuals: Uses tiny text-based triangles (▴ and ▾) instead of standard shapes to keep your candlesticks fully visible and clutter-free.

📊 Visual Guide
Long Lower Shadow (Bullish): Marked by a White ▴ (Up). Indicates rejection of lower prices and potential support.
Long Upper Shadow (Bearish): Marked by a White ▾ (Down). Indicates rejection of higher prices and potential resistance.
Bullish Engulfing: Marked by a Green ▴ (Up). Shows strong buying momentum completely overtaking sellers.
Bearish Engulfing: Marked by a Red ▾ (Down). Shows strong selling momentum completely overtaking buyers.

这是一个极简风格的裸K反转指标，专门用于捕捉图表上的关键价格行为：长影线（Long Shadows）与吞噬形态（Engulfing Patterns）。该指标专为追求图表整洁的交易者打造，彻底摒弃了笨重的文本标签和背景色，全部采用微型三角图标进行提示。

🌟 核心亮点
双重形态捕捉：将两种最经典的K线反转形态合并在一个轻量级脚本中，为您节省宝贵的指标栏位。
智能趋势过滤：吞噬形态内置了 SMA（50/200）趋势过滤逻辑，确保信号只在明确的趋势末端触发，大幅过滤震荡市中的无效信号。
极致清爽体验：采用微型字符三角（▴ 和 ▾）替代系统默认图形，即使在大幅缩放图表时也绝不会遮挡K线实体。
📊 视觉图例
下长影线 (看涨)： 提示为 白色 ▴ (正三角)。代表价格拒绝下跌，正在测试潜在支撑位。
上长影线 (看跌)： 提示为 白色 ▾ (倒三角)。代表价格拒绝上涨，正在测试潜在阻力位。
看涨吞噬： 提示为 绿色 ▴ (正三角)。代表买盘强劲，多头动能完全反包空头。
看跌吞噬： 提示为 红色 ▾ (倒三角)。代表卖盘强劲，空头动能完全反包多头。

## Source Code

````pine
//@version=6
indicator("Shadows & Engulfing Patterns", shorttitle="Shadows & Engulfing", overlay=true)

// =========================================================================
// 🎨 1. 输入设置 (Inputs)
// =========================================================================
// 长影线设置
C_LongShadowPercent = input.float(75.0, "长影线占比阈值 (%)", group="长影线设置 (Long Shadows)", minval=0, maxval=100)

// 吞噬形态趋势设置
var trendRule1 = "SMA50"
var trendRule2 = "SMA50, SMA200"
trendRule = input.string(trendRule1, "吞噬形态趋势判定依据", options=[trendRule1, trendRule2, "No detection"], group="吞噬形态设置 (Engulfing)")

// =========================================================================
// 🧮 2. 核心计算 (Core Calculations)
// =========================================================================
// 基础 K 线数据
C_BodyHi = math.max(close, open)
C_BodyLo = math.min(close, open)
C_Body = C_BodyHi - C_BodyLo
C_Range = high - low
C_UpShadow = high - C_BodyHi
C_DnShadow = C_BodyLo - low

// 吞噬形态专用的实体大小计算 (使用 14 周期 EMA 计算平均实体)
C_Len = 14 
C_BodyAvg = ta.ema(C_Body, C_Len)
C_SmallBody = C_Body < C_BodyAvg
C_LongBody = C_Body > C_BodyAvg
C_WhiteBody = open < close
C_BlackBody = open > close

// 吞噬形态专用的趋势判定
C_DownTrend = true
C_UpTrend = true

if trendRule == trendRule1
    priceAvg = ta.sma(close, 50)
    C_DownTrend := close < priceAvg
    C_UpTrend := close > priceAvg

if trendRule == trendRule2
    sma200 = ta.sma(close, 200)
    sma50 = ta.sma(close, 50)
    C_DownTrend := close < sma50 and sma50 < sma200
    C_UpTrend := close > sma50 and sma50 > sma200

// =========================================================================
// 🔍 3. 信号逻辑 (Signal Logic)
// =========================================================================
// --- 长影线逻辑 ---
C_LongUpperShadowBearish = C_UpShadow > (C_Range / 100 * C_LongShadowPercent)
C_LongLowerShadowBullish = C_DnShadow > (C_Range / 100 * C_LongShadowPercent)

// --- 吞噬形态逻辑 ---
// 看涨吞噬：处于下降趋势 + 前一根是小阴线 + 当前是大阳线且完全包覆前一根实体
C_EngulfingBullish = C_DownTrend and C_WhiteBody and C_LongBody and C_BlackBody[1] and C_SmallBody[1] and close >= open[1] and open <= close[1] and (close > open[1] or open < close[1])

// 看跌吞噬：处于上升趋势 + 前一根是小阳线 + 当前是大阴线且完全包覆前一根实体
C_EngulfingBearish = C_UpTrend and C_BlackBody and C_LongBody and C_WhiteBody[1] and C_SmallBody[1] and close <= open[1] and open >= close[1] and (close < open[1] or open > close[1])

// =========================================================================
// 🔔 4. 警报与图形绘制 (Alerts & Plotting)
// =========================================================================
// 警报
alertcondition(C_LongUpperShadowBearish, title="Bearish Long Upper Shadow", message="New Long Upper Shadow pattern detected")
alertcondition(C_LongLowerShadowBullish, title="Bullish Long Lower Shadow", message="New Long Lower Shadow pattern detected")
alertcondition(C_EngulfingBullish, title="Bullish Engulfing", message="New Engulfing - Bullish pattern detected")
alertcondition(C_EngulfingBearish, title="Bearish Engulfing", message="New Engulfing - Bearish pattern detected")

// --- 图表标记 (使用微型字符突破尺寸限制) ---

// 1. 长影线 (纯白)
plotchar(C_LongUpperShadowBearish, title="Bearish LUS", char="▾", location=location.abovebar, color=color.white, size=size.tiny)
plotchar(C_LongLowerShadowBullish, title="Bullish LLS", char="▴", location=location.belowbar, color=color.white, size=size.tiny)

// 2. 吞噬形态 (红/绿)
plotchar(C_EngulfingBearish, title="Bearish Engulfing", char="▾", location=location.abovebar, color=color.red, size=size.tiny)
plotchar(C_EngulfingBullish, title="Bullish Engulfing", char="▴", location=location.belowbar, color=color.green, size=size.tiny)
````

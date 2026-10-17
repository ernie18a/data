# Market Regime RSI Matrix

- url: https://www.tradingview.com/script/wD5eMPfW/
- type: indicator
- pine_id: PUB;b7e24070f5bf4458b65ca34bd6f7a9c8
- version: 1.0

## Description

Market Regime RSI Matrix (MRM)

Market Regime RSI Matrix (MRM) is a multi-timeframe momentum and market context framework designed to transform traditional RSI analysis into a broader market regime model.

Rather than relying on a single RSI reading from the active chart timeframe, this indicator combines RSI measurements from multiple independent timeframes into a weighted composite engine called the Master RSI. It then evaluates the degree of agreement between those timeframes, estimates the persistence of the current market condition, classifies the prevailing market regime, and visualizes these relationships through adaptive momentum zones and dashboard components.

The objective of this script is not to generate isolated buy or sell signals, but to provide a structured view of how momentum is distributed throughout the market across multiple horizons.

📊 How It Works

The indicator is built around a hierarchical momentum framework composed of several interconnected modules.

Multi-Timeframe Master RSI Engine

At the core of the indicator is the Master RSI, a composite momentum value constructed from up to ten independent RSI calculations.

Each timeframe can be individually selected and assigned its own weight.

The composite value is calculated as:

Master RSI =
Σ(RSI × Weight) / Σ(Weight)

This allows shorter-term traders to emphasize lower timeframes, while swing traders can prioritize higher timeframe momentum.

Unlike traditional RSI implementations, the resulting Master RSI represents the collective behavior of multiple market participants operating on different time horizons.

🤝 Consensus Engine

Momentum strength alone does not necessarily imply broad market participation.

To address this, the script measures how many monitored timeframes agree on directional bias.

Each timeframe contributes to a bullish or bearish count according to whether its RSI is above or below the equilibrium level:

Bullish TF:
RSI ≥ 50

Bearish TF:
RSI < 50

Consensus is then calculated as:

Consensus Score =
|Bull TF − Bear TF| / Total TF × 100

Higher values indicate stronger alignment among market participants.

For example:

Consensus = 90%

9 timeframes bullish
1 timeframe bearish

suggests broad agreement across the monitored horizons.

Lower values indicate disagreement and fragmented market participation.

📈 Trend Strength Module

The indicator estimates momentum persistence by smoothing the Master RSI through two exponential moving averages:

Fast Trend EMA = EMA(Master RSI, 5)

Slow Trend EMA = EMA(Master RSI, 13)

The distance between these two curves provides an estimate of directional intensity.

Trend conditions are classified into:

• Weak

• Moderate

• Strong

• Very Strong

This framework helps distinguish between stable trends and environments where momentum lacks conviction.

🎯 Probability Engine

The Probability Engine combines several independent components into a unified score designed to estimate the persistence of the current market condition.

Inputs include:

• Consensus alignment

• Trend strength

• Master RSI positioning

• Dynamic Fibonacci context

The model aggregates these components using weighted contributions:

Probability Score =
Consensus × 40%
+ Trend Strength × 30%
+ Fibonacci Context × 20%
+ RSI Position × 10%

The resulting value is expressed as a percentage.

Higher scores indicate that the current market condition exhibits stronger internal agreement within the framework.

The Probability Score is intended as contextual information and should not be interpreted as a prediction of future price movement.

📐 Adaptive Fibonacci Momentum Zones

Instead of relying on fixed RSI thresholds such as 30 and 70, the script constructs dynamic Fibonacci zones using the observed Master RSI range.

The calculation window automatically adapts to the chart timeframe through the Adaptive Lookback Engine.

Typical lookback behavior:

Lower timeframes:
Longer observation windows

Higher timeframes:
Shorter observation windows

Standard Fibonacci ratios are then projected throughout the observed Master RSI range:

0.000
0.236
0.382
0.500
0.618
0.786
1.000

These zones serve as contextual momentum regions rather than predictive targets.

The indicator additionally estimates the corresponding price levels associated with each momentum zone, allowing users to compare momentum structure with actual price location.

🌡️ Multi-Timeframe RSI Heatmap

To improve readability, the script provides a visual heatmap displaying RSI values from every monitored timeframe.

Each row represents one timeframe and its current RSI value.

Color intensity reflects the relative position of the RSI within its momentum range, allowing users to quickly identify:

• Broad directional alignment

• Divergence between short-term and long-term momentum

• Emerging transitions in participation

The heatmap is intended to complement the Consensus Engine by providing a more granular view of internal market structure.

🧭 Market State Engine

One of the defining components of the framework is the Market State Engine.

Rather than describing conditions simply as bullish or bearish, the indicator classifies the market into five distinct regimes:

Bull Trend

Occurs when:

• Consensus is elevated

• Trend strength is positive

• Probability is high

• Master RSI maintains strong momentum

This environment suggests broad participation and directional persistence.

Bear Trend

Occurs when:

• Consensus is elevated

• Trend strength is negative

• Probability is high

• Master RSI reflects persistent downside momentum

This environment suggests coordinated selling pressure across timeframes.

Accumulation

Occurs when:

• Consensus is limited

• Probability remains subdued

• Master RSI operates below equilibrium

This condition may represent balance-building phases where directional conviction has not yet emerged.

Distribution

Occurs when:

• Consensus remains weak

• Probability remains subdued

• Master RSI operates above equilibrium

This condition may indicate loss of participation following sustained advances.

Transition

Any market environment not satisfying the criteria above is classified as Transition.

These phases often occur during regime changes, trend exhaustion, or evolving participation dynamics.

⚙️ Customization Options

Users can configure:

• Up to ten independent RSI timeframes

• Individual timeframe weights

• RSI calculation length

• Signal smoothing length

• Adaptive or manual Fibonacci lookback

• Fibonacci visualization settings

• Heatmap visibility

• Dashboard display preferences

This flexibility allows the framework to adapt to different asset classes, trading styles, and analytical objectives.

📖 How To Use

Possible applications include:

Use Consensus as a directional filter.

Higher Consensus values suggest broader market agreement.

Monitor Probability before acting on directional setups.

Increasing Probability may indicate strengthening market conditions.

Use Market State to identify the dominant regime.

Trend environments and transitional environments often require different decision-making approaches.

Observe the Heatmap for internal divergence.

Conflicting lower and higher timeframe momentum may signal weakening participation.

Use Fibonacci Momentum Zones as contextual reference areas.

These regions are intended to frame momentum behavior rather than provide precise price targets.

The indicator is designed to complement existing analytical processes and may be combined with price action, market structure, volume analysis, or individual risk management techniques.

💡 Originality

This script represents an original framework that integrates weighted multi-timeframe momentum aggregation, participation consensus measurement, adaptive momentum zoning, probability modeling, and market regime classification into a unified analytical dashboard.

Its primary innovation lies in treating RSI not as an isolated oscillator, but as a distributed representation of market participation across multiple horizons.

The combination of:

• Weighted Master RSI construction,

• Consensus-based participation analysis,

• Adaptive Fibonacci momentum zones,

• Composite probability estimation,

• Multi-timeframe heatmap visualization,

• and Market State classification,

forms a cohesive framework designed to improve contextual awareness rather than generate deterministic trading signals.

This complete implementation was developed as an integrated analytical model and is not derived from any previously published TradingView script.

⚠️ Disclaimer

This script is provided for educational and informational purposes only.

It does not constitute financial advice, investment advice, trading advice, or a recommendation to buy or sell any financial instrument.

All calculations are derived from historical market data and mathematical transformations of price behavior. Technical analysis is inherently uncertain, and past performance does not guarantee future results.

Users should conduct their own research and apply appropriate risk management before making trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Onuriano

//@version=6
indicator('Market Regime RSI Matrix', shorttitle = 'MRM Dashboard', overlay = false)

// ==========================================
// 1. INPUTS AND PERIOD SETTINGS
// ==========================================
var string G_RSI = 'General RSI Settings'
rsiLen = input.int(14, title = 'RSI Period', group = G_RSI)
src = input.source(close, title = 'Price Source', group = G_RSI)
signalLen = input.int(9, title = 'Signal Line EMA Length', group = G_RSI, minval = 1)

var string G_FIB = 'Dynamic Fibonacci Settings'
//fibLookback       = input.int(100, title="Fib Calculation Bar Count", group=G_FIB)
useAdaptiveFib = input.bool(true, title = 'Use Adaptive Fib Lookback', group = G_FIB)

manualFibLookback = input.int(100, title = 'Manual Fib Bar Count', group = G_FIB, minval = 20)

adaptiveFibLookback = timeframe.isseconds ? 300 : timeframe.isminutes ? timeframe.multiplier <= 5 ? 250 : timeframe.multiplier <= 15 ? 200 : timeframe.multiplier <= 60 ? 150 : 120 : timeframe.isdaily ? 100 : timeframe.isweekly ? 52 : timeframe.ismonthly ? 24 : manualFibLookback

fibLookback = useAdaptiveFib ? adaptiveFibLookback : manualFibLookback
var string G_TF = '10 Different Timeframe Selection'
tf1 = input.timeframe('5', title = 'Timeframe 1', group = G_TF)
tf2 = input.timeframe('15', title = 'Timeframe 2', group = G_TF)
tf3 = input.timeframe('30', title = 'Timeframe 3', group = G_TF)
tf4 = input.timeframe('60', title = 'Timeframe 4', group = G_TF)
tf5 = input.timeframe('120', title = 'Timeframe 5', group = G_TF)
tf6 = input.timeframe('240', title = 'Timeframe 6', group = G_TF)
tf7 = input.timeframe('480', title = 'Timeframe 7', group = G_TF)
tf8 = input.timeframe('D', title = 'Timeframe 8', group = G_TF)
tf9 = input.timeframe('2D', title = 'Timeframe 9', group = G_TF)
tf10 = input.timeframe('W', title = 'Timeframe 10', group = G_TF)
showHeatmap = input.bool(true, title = 'Show MTF RSI Heatmap', group = 'Heatmap')
// ==========================================
// TIMEFRAME WEIGHTS
// ==========================================
var string G_W = 'Timeframe Weights'
w1 = input.float(1.0, title = 'TF 1 Weight  (5m)', group = G_W, minval = 0.0, maxval = 10.0, step = 0.5)
w2 = input.float(1.0, title = 'TF 2 Weight  (15m)', group = G_W, minval = 0.0, maxval = 10.0, step = 0.5)
w3 = input.float(1.5, title = 'TF 3 Weight  (30m)', group = G_W, minval = 0.0, maxval = 10.0, step = 0.5)
w4 = input.float(1.5, title = 'TF 4 Weight  (1h)', group = G_W, minval = 0.0, maxval = 10.0, step = 0.5)
w5 = input.float(2.0, title = 'TF 5 Weight  (2h)', group = G_W, minval = 0.0, maxval = 10.0, step = 0.5)
w6 = input.float(2.0, title = 'TF 6 Weight  (4h)', group = G_W, minval = 0.0, maxval = 10.0, step = 0.5)
w7 = input.float(2.5, title = 'TF 7 Weight  (8h)', group = G_W, minval = 0.0, maxval = 10.0, step = 0.5)
w8 = input.float(3.0, title = 'TF 8 Weight  (D)', group = G_W, minval = 0.0, maxval = 10.0, step = 0.5)
w9 = input.float(3.5, title = 'TF 9 Weight  (2D)', group = G_W, minval = 0.0, maxval = 10.0, step = 0.5)
w10 = input.float(4.0, title = 'TF 10 Weight (W)', group = G_W, minval = 0.0, maxval = 10.0, step = 0.5)

// ==========================================
// 2. MULTI TIMEFRAME DATA COLLECTION
// ==========================================
calcRsi(source, length) =>
    ta.rsi(source, length)

r1 = request.security(syminfo.tickerid, tf1, calcRsi(src, rsiLen), barmerge.gaps_off, barmerge.lookahead_off)
r2 = request.security(syminfo.tickerid, tf2, calcRsi(src, rsiLen), barmerge.gaps_off, barmerge.lookahead_off)
r3 = request.security(syminfo.tickerid, tf3, calcRsi(src, rsiLen), barmerge.gaps_off, barmerge.lookahead_off)
r4 = request.security(syminfo.tickerid, tf4, calcRsi(src, rsiLen), barmerge.gaps_off, barmerge.lookahead_off)
r5 = request.security(syminfo.tickerid, tf5, calcRsi(src, rsiLen), barmerge.gaps_off, barmerge.lookahead_off)
r6 = request.security(syminfo.tickerid, tf6, calcRsi(src, rsiLen), barmerge.gaps_off, barmerge.lookahead_off)
r7 = request.security(syminfo.tickerid, tf7, calcRsi(src, rsiLen), barmerge.gaps_off, barmerge.lookahead_off)
r8 = request.security(syminfo.tickerid, tf8, calcRsi(src, rsiLen), barmerge.gaps_off, barmerge.lookahead_off)
r9 = request.security(syminfo.tickerid, tf9, calcRsi(src, rsiLen), barmerge.gaps_off, barmerge.lookahead_off)
r10 = request.security(syminfo.tickerid, tf10, calcRsi(src, rsiLen), barmerge.gaps_off, barmerge.lookahead_off)

// ==========================================
// 3. WEIGHTED MASTER RSI
// ==========================================
totalWeight = w1 + w2 + w3 + w4 + w5 + w6 + w7 + w8 + w9 + w10
master_rsi = totalWeight > 0 ? (r1 * w1 + r2 * w2 + r3 * w3 + r4 * w4 + r5 * w5 + r6 * w6 + r7 * w7 + r8 * w8 + r9 * w9 + r10 * w10) / totalWeight : 50.0

// ==========================================
// MTF CONSENSUS SCORE
// ==========================================
bullTF = (r1 >= 50 ? 1 : 0) + (r2 >= 50 ? 1 : 0) + (r3 >= 50 ? 1 : 0) + (r4 >= 50 ? 1 : 0) + (r5 >= 50 ? 1 : 0) + (r6 >= 50 ? 1 : 0) + (r7 >= 50 ? 1 : 0) + (r8 >= 50 ? 1 : 0) + (r9 >= 50 ? 1 : 0) + (r10 >= 50 ? 1 : 0)

bearTF = 10 - bullTF

consensusScore = math.abs(bullTF - bearTF) / 10.0 * 100.0

consensusState = consensusScore >= 80 ? 'VERY STRONG' : consensusScore >= 60 ? 'STRONG' : consensusScore >= 40 ? 'MODERATE' : 'WEAK'

consensusBias = bullTF > bearTF ? 'BULLISH' : bearTF > bullTF ? 'BEARISH' : 'NEUTRAL'
// ==========================================
// 4. DYNAMIC FIBONACCI CALCULATIONS (FOR RSI)
// ==========================================
fib_high = ta.highest(master_rsi, fibLookback)
fib_low = ta.lowest(master_rsi, fibLookback)
fib_range = fib_high - fib_low

fib_100 = fib_high
fib_786 = fib_low + fib_range * 0.786
fib_618 = fib_low + fib_range * 0.618
fib_500 = fib_low + fib_range * 0.500
fib_382 = fib_low + fib_range * 0.382
fib_236 = fib_low + fib_range * 0.236
fib_000 = fib_low

// ==========================================
// 5. REAL PRICE CALCULATION MATH FOR LABELS
// ==========================================
price_high = ta.highest(high, fibLookback)
price_low = ta.lowest(low, fibLookback)
price_range = price_high - price_low

price_f100 = price_high
price_f786 = price_low + price_range * 0.786
price_f618 = price_low + price_range * 0.618
price_f500 = price_low + price_range * 0.500
price_f382 = price_low + price_range * 0.382
price_f236 = price_low + price_range * 0.236
price_f000 = price_low

// ==========================================
// 6. MANUAL RGB GRADIENT LOGIC
// ==========================================
var color color_dynamic = color.gray

if master_rsi >= 50
    weight = math.min((master_rsi - 50) / 30, 1.0)
    int r_val = int(255 - 255 * weight)
    int g_val = int(235 + 5 * weight)
    color_dynamic := color.rgb(r_val, g_val, 59)
    color_dynamic
else
    weight = math.min((50 - master_rsi) / 30, 1.0)
    int r_val = int(255)
    int g_val = int(235 - 212 * weight)
    color_dynamic := color.rgb(r_val, g_val, 59)
    color_dynamic

// ==========================================
// 7. VISUALIZATION AND LINES
// ==========================================
h50 = hline(50, 'Balance Level', color = color.new(color.white, 60), linestyle = hline.style_dashed, linewidth = 1)

p_100 = plot(fib_100, title = 'Fib 1.000', color = color.new(#ff1744, 30), linewidth = 1)
p_786 = plot(fib_786, title = 'Fib 0.786', color = color.new(#ff5252, 30), linewidth = 1)
p_618 = plot(fib_618, title = 'Fib 0.618', color = color.new(#ffb74d, 30), linewidth = 2, style = plot.style_circles)
p_500 = plot(fib_500, title = 'Fib 0.500', color = color.new(#fff59d, 30), linewidth = 1)
p_382 = plot(fib_382, title = 'Fib 0.382', color = color.new(#81c784, 30), linewidth = 1)
p_236 = plot(fib_236, title = 'Fib 0.236', color = color.new(#69f0ae, 30), linewidth = 1)
p_000 = plot(fib_000, title = 'Fib 0.000', color = color.new(#00e676, 30), linewidth = 1)

fill(p_618, p_382, color = color.new(color.blue, 96), title = 'Fib Golden Zone')

plot(master_rsi, title = 'Gradient Master RSI', color = color_dynamic, linewidth = 3, style = plot.style_line)
barcolor(color = color_dynamic)
master_signal = ta.ema(master_rsi, signalLen)
plot(master_signal, title = 'Signal Line (EMA)', color = color.rgb(72, 105, 250), linewidth = 2)

// ==========================================
// MASTER RSI TREND STRENGTH
// ==========================================
trendFast = ta.ema(master_rsi, 5)
trendSlow = ta.ema(master_rsi, 13)

trendDistance = math.abs(trendFast - trendSlow)

trendDirection = trendFast > trendSlow ? 'UPTREND' : trendFast < trendSlow ? 'DOWNTREND' : 'SIDEWAYS'

trendStrength = trendDistance >= 8 ? 'VERY STRONG' : trendDistance >= 5 ? 'STRONG' : trendDistance >= 2 ? 'MODERATE' : 'WEAK'

trendStrengthValue = math.min(trendDistance * 10, 100)

// ==========================================
// PROBABILITY SCORE
// ==========================================

// RSI merkezden uzaklaştıkça yönsel güç artar
rsiScore = math.abs(master_rsi - 50) * 2

// Consensus zaten 0–100 arası
consensusProb = consensusScore

// Trend gücü zaten 0–100 arası
trendProb = trendStrengthValue

// Fib pozisyon skoru
fibProb = master_rsi >= fib_618 ? 100 : master_rsi >= fib_500 ? 75 : master_rsi >= fib_382 ? 50 : master_rsi >= fib_236 ? 25 : 0

// Nihai olasılık
probabilityScore = consensusProb * 0.40 + trendProb * 0.30 + fibProb * 0.20 + rsiScore * 0.10
probabilityState = probabilityScore >= 80 ? 'VERY HIGH' : probabilityScore >= 65 ? 'HIGH' : probabilityScore >= 50 ? 'MODERATE' : probabilityScore >= 35 ? 'LOW' : 'VERY LOW'

probabilityBias = master_rsi >= 50 ? 'BULLISH' : 'BEARISH'
// ==========================================
// MASTER MARKET STATE
// ==========================================

marketState = consensusScore >= 70 and trendFast > trendSlow and probabilityScore >= 70 and master_rsi >= 60 ? 'BULL TREND' : consensusScore >= 70 and trendFast < trendSlow and probabilityScore >= 70 and master_rsi <= 40 ? 'BEAR TREND' : consensusScore < 50 and master_rsi < 50 and probabilityScore < 50 ? 'ACCUMULATION' : consensusScore < 50 and master_rsi > 50 and probabilityScore < 50 ? 'DISTRIBUTION' : 'TRANSITION'




marketColor = marketState == 'BULL TREND' ? color.new(color.green, 0) : marketState == 'BEAR TREND' ? color.new(color.red, 0) : marketState == 'ACCUMULATION' ? color.new(color.blue, 0) : marketState == 'DISTRIBUTION' ? color.new(color.orange, 0) : color.new(color.gray, 0)





plot(trendFast, title = 'Trend EMA 5', color = color.new(color.green, 0), linewidth = 1)

plot(trendSlow, title = 'Trend EMA 13', color = color.new(color.red, 0), linewidth = 1)
// ==========================================
// 8. LABELS — FIB LEVEL ONLY (each has own var)
// ==========================================
var label lbl_100 = na
var label lbl_786 = na
var label lbl_618 = na
var label lbl_500 = na
var label lbl_382 = na
var label lbl_236 = na
var label lbl_000 = na

if barstate.islast
    int label_offset = bar_index + 2
    string p_format = syminfo.mintick > 0.1 ? '#.##' : '#.#####'

    label.delete(lbl_100)
    label.delete(lbl_786)
    label.delete(lbl_618)
    label.delete(lbl_500)
    label.delete(lbl_382)
    label.delete(lbl_236)
    label.delete(lbl_000)

    lbl_100 := label.new(label_offset, fib_100, '1.000', color = color.new(#ff1744, 20), textcolor = color.white, style = label.style_label_left, size = size.small)
    lbl_786 := label.new(label_offset, fib_786, '0.786', color = color.new(#ff5252, 40), textcolor = color.white, style = label.style_label_left, size = size.small)
    lbl_618 := label.new(label_offset, fib_618, '0.618', color = color.new(#ffb74d, 20), textcolor = color.black, style = label.style_label_left, size = size.small)
    lbl_500 := label.new(label_offset, fib_500, '0.500', color = color.new(#fff59d, 30), textcolor = color.black, style = label.style_label_left, size = size.small)
    lbl_382 := label.new(label_offset, fib_382, '0.382', color = color.new(#81c784, 20), textcolor = color.white, style = label.style_label_left, size = size.small)
    lbl_236 := label.new(label_offset, fib_236, '0.236', color = color.new(#69f0ae, 40), textcolor = color.white, style = label.style_label_left, size = size.small)
    lbl_000 := label.new(label_offset, fib_000, '0.000', color = color.new(#00e676, 20), textcolor = color.white, style = label.style_label_left, size = size.small)
    lbl_000

// ==========================================
// 9. TABLE — RSI AND PRICE VALUES (RIGHT SIDE)
// ==========================================
var table fib_table = table.new(position.middle_right, 3, 23, border_width = 1, border_color = color.new(color.gray, 60), force_overlay = true)

if barstate.islast
    string p_format = syminfo.mintick > 0.1 ? '#.##' : '#.#####'

    table.cell(fib_table, 0, 0, 'Level', text_color = color.white, text_size = size.small, bgcolor = color.new(color.gray, 40))
    table.cell(fib_table, 1, 0, 'RSI', text_color = color.white, text_size = size.small, bgcolor = color.new(color.gray, 40))
    table.cell(fib_table, 2, 0, 'Price', text_color = color.white, text_size = size.small, bgcolor = color.new(color.gray, 40))

    table.cell(fib_table, 0, 1, '1.000', text_color = color.white, text_size = size.small, bgcolor = color.new(#ff1744, 20))
    table.cell(fib_table, 1, 1, str.tostring(fib_100, '#.##'), text_color = color.white, text_size = size.small, bgcolor = color.new(#ff1744, 20))
    table.cell(fib_table, 2, 1, str.tostring(price_f100, p_format), text_color = color.white, text_size = size.small, bgcolor = color.new(#ff1744, 20))

    table.cell(fib_table, 0, 2, '0.786', text_color = color.white, text_size = size.small, bgcolor = color.new(#ff5252, 40))
    table.cell(fib_table, 1, 2, str.tostring(fib_786, '#.##'), text_color = color.white, text_size = size.small, bgcolor = color.new(#ff5252, 40))
    table.cell(fib_table, 2, 2, str.tostring(price_f786, p_format), text_color = color.white, text_size = size.small, bgcolor = color.new(#ff5252, 40))

    table.cell(fib_table, 0, 3, '0.618', text_color = color.black, text_size = size.small, bgcolor = color.new(#ffb74d, 20))
    table.cell(fib_table, 1, 3, str.tostring(fib_618, '#.##'), text_color = color.black, text_size = size.small, bgcolor = color.new(#ffb74d, 20))
    table.cell(fib_table, 2, 3, str.tostring(price_f618, p_format), text_color = color.black, text_size = size.small, bgcolor = color.new(#ffb74d, 20))

    table.cell(fib_table, 0, 4, '0.500', text_color = color.black, text_size = size.small, bgcolor = color.new(#fff59d, 30))
    table.cell(fib_table, 1, 4, str.tostring(fib_500, '#.##'), text_color = color.black, text_size = size.small, bgcolor = color.new(#fff59d, 30))
    table.cell(fib_table, 2, 4, str.tostring(price_f500, p_format), text_color = color.black, text_size = size.small, bgcolor = color.new(#fff59d, 30))

    table.cell(fib_table, 0, 5, '0.382', text_color = color.white, text_size = size.small, bgcolor = color.new(#81c784, 20))
    table.cell(fib_table, 1, 5, str.tostring(fib_382, '#.##'), text_color = color.white, text_size = size.small, bgcolor = color.new(#81c784, 20))
    table.cell(fib_table, 2, 5, str.tostring(price_f382, p_format), text_color = color.white, text_size = size.small, bgcolor = color.new(#81c784, 20))

    table.cell(fib_table, 0, 6, '0.236', text_color = color.white, text_size = size.small, bgcolor = color.new(#69f0ae, 40))
    table.cell(fib_table, 1, 6, str.tostring(fib_236, '#.##'), text_color = color.white, text_size = size.small, bgcolor = color.new(#69f0ae, 40))
    table.cell(fib_table, 2, 6, str.tostring(price_f236, p_format), text_color = color.white, text_size = size.small, bgcolor = color.new(#69f0ae, 40))

    table.cell(fib_table, 0, 7, '0.000', text_color = color.white, text_size = size.small, bgcolor = color.new(#00e676, 20))
    table.cell(fib_table, 1, 7, str.tostring(fib_000, '#.##'), text_color = color.white, text_size = size.small, bgcolor = color.new(#00e676, 20))
    table.cell(fib_table, 2, 7, str.tostring(price_f000, p_format), text_color = color.white, text_size = size.small, bgcolor = color.new(#00e676, 20))

// Consensus Header
table.cell(fib_table, 0, 8, 'Consensus', text_color = color.white, text_size = size.small, bgcolor = color.new(color.blue, 40))

table.cell(fib_table, 1, 8, str.tostring(math.round(consensusScore)) + '%', text_color = color.white, text_size = size.small, bgcolor = color.new(color.blue, 40))

table.cell(fib_table, 2, 8, consensusState, text_color = color.white, text_size = size.small, bgcolor = color.new(color.blue, 40))

// Bull Timeframes
table.cell(fib_table, 0, 9, 'Bull TF', text_color = color.white, text_size = size.small, bgcolor = color.new(color.green, 70))

table.cell(fib_table, 1, 9, str.tostring(bullTF), text_color = color.white, text_size = size.small, bgcolor = color.new(color.green, 70))

table.cell(fib_table, 2, 9, consensusBias, text_color = color.white, text_size = size.small, bgcolor = color.new(color.green, 70))

// Bear Timeframes
table.cell(fib_table, 0, 10, 'Bear TF', text_color = color.white, text_size = size.small, bgcolor = color.new(color.red, 70))

table.cell(fib_table, 1, 10, str.tostring(bearTF), text_color = color.white, text_size = size.small, bgcolor = color.new(color.red, 70))

table.cell(fib_table, 2, 10, '', text_color = color.white, text_size = size.small, bgcolor = color.new(color.red, 70))

// Trend Direction
table.cell(fib_table, 0, 11, 'Trend', text_color = color.white, text_size = size.small, bgcolor = color.new(color.purple, 60))

table.cell(fib_table, 1, 11, trendDirection, text_color = color.white, text_size = size.small, bgcolor = color.new(color.purple, 60))

table.cell(fib_table, 2, 11, trendStrength, text_color = color.white, text_size = size.small, bgcolor = color.new(color.purple, 60))

// Trend Power
table.cell(fib_table, 0, 12, 'Trend %', text_color = color.white, text_size = size.small, bgcolor = color.new(color.purple, 75))

table.cell(fib_table, 1, 12, str.tostring(math.round(trendStrengthValue)) + '%', text_color = color.white, text_size = size.small, bgcolor = color.new(color.purple, 75))

table.cell(fib_table, 2, 12, '', text_color = color.white, text_size = size.small, bgcolor = color.new(color.purple, 75))

// Probability Score
table.cell(fib_table, 0, 13, 'Probability', text_color = color.white, text_size = size.small, bgcolor = color.new(color.orange, 40))

table.cell(fib_table, 1, 13, str.tostring(math.round(probabilityScore)) + '%', text_color = color.white, text_size = size.small, bgcolor = color.new(color.orange, 40))

table.cell(fib_table, 2, 13, probabilityState, text_color = color.white, text_size = size.small, bgcolor = color.new(color.orange, 40))

// Probability Bias
table.cell(fib_table, 0, 14, 'Bias', text_color = color.white, text_size = size.small, bgcolor = color.new(color.orange, 60))

table.cell(fib_table, 1, 14, probabilityBias, text_color = color.white, text_size = size.small, bgcolor = color.new(color.orange, 60))

table.cell(fib_table, 2, 14, '', text_color = color.white, text_size = size.small, bgcolor = color.new(color.orange, 60))

table.cell(fib_table, 0, 15, 'Fib Window', text_color = color.white, text_size = size.small, bgcolor = color.new(color.teal, 50))

table.cell(fib_table, 1, 15, str.tostring(fibLookback), text_color = color.white, text_size = size.small, bgcolor = color.new(color.teal, 50))

table.cell(fib_table, 2, 15, useAdaptiveFib ? 'AUTO' : 'MANUAL', text_color = color.white, text_size = size.small, bgcolor = color.new(color.teal, 50))
// ==========================================
// MARKET STATE
// ==========================================

table.cell(fib_table, 0, 16, 'Market', text_color = color.white, text_size = size.small, bgcolor = marketColor)

table.cell(fib_table, 1, 16, marketState, text_color = color.white, text_size = size.small, bgcolor = marketColor)

table.cell(fib_table, 2, 16, '', text_color = color.white, text_size = size.small, bgcolor = marketColor)
// ==========================================
// HEATMAP COLOR FUNCTION
// ==========================================
getHeatmapColor(rsi) =>
    rsi >= 70 ? color.new(#fa0404, 0) : rsi >= 60 ? color.new(#fa9601, 0) : rsi >= 50 ? color.new(#f4dc02, 0) : rsi >= 40 ? color.new(#288121, 0) : color.new(#15ed06, 0)

// ==========================================
// MTF RSI HEATMAP TABLE
// ==========================================
var table heatmapTable = table.new(position.bottom_left, 2, 11, border_width = 1, border_color = color.new(color.gray, 60), force_overlay = true)

if barstate.islast and showHeatmap

    table.cell(heatmapTable, 0, 0, 'TF', text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.tiny)

    table.cell(heatmapTable, 1, 0, 'RSI', text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.tiny)

    // TF1
    table.cell(heatmapTable, 0, 1, tf1, text_color = color.white, text_size = size.tiny)

    table.cell(heatmapTable, 1, 1, str.tostring(r1, '#.##'), text_color = color.black, bgcolor = getHeatmapColor(r1), text_size = size.tiny)

    // TF2
    table.cell(heatmapTable, 0, 2, tf2, text_color = color.white, text_size = size.tiny)

    table.cell(heatmapTable, 1, 2, str.tostring(r2, '#.##'), text_color = color.black, bgcolor = getHeatmapColor(r2), text_size = size.tiny)

    // TF3
    table.cell(heatmapTable, 0, 3, tf3, text_color = color.white, text_size = size.tiny)

    table.cell(heatmapTable, 1, 3, str.tostring(r3, '#.##'), text_color = color.black, bgcolor = getHeatmapColor(r3), text_size = size.tiny)

    // TF4
    table.cell(heatmapTable, 0, 4, tf4, text_color = color.white, text_size = size.tiny)

    table.cell(heatmapTable, 1, 4, str.tostring(r4, '#.##'), text_color = color.black, bgcolor = getHeatmapColor(r4), text_size = size.tiny)

    // TF5
    table.cell(heatmapTable, 0, 5, tf5, text_color = color.white, text_size = size.tiny)

    table.cell(heatmapTable, 1, 5, str.tostring(r5, '#.##'), text_color = color.black, bgcolor = getHeatmapColor(r5), text_size = size.tiny)

    // TF6
    table.cell(heatmapTable, 0, 6, tf6, text_color = color.white, text_size = size.tiny)

    table.cell(heatmapTable, 1, 6, str.tostring(r6, '#.##'), text_color = color.black, bgcolor = getHeatmapColor(r6), text_size = size.tiny)

    // TF7
    table.cell(heatmapTable, 0, 7, tf7, text_color = color.white, text_size = size.tiny)

    table.cell(heatmapTable, 1, 7, str.tostring(r7, '#.##'), text_color = color.black, bgcolor = getHeatmapColor(r7), text_size = size.tiny)

    // TF8
    table.cell(heatmapTable, 0, 8, tf8, text_color = color.white, text_size = size.tiny)

    table.cell(heatmapTable, 1, 8, str.tostring(r8, '#.##'), text_color = color.black, bgcolor = getHeatmapColor(r8), text_size = size.tiny)

    // TF9
    table.cell(heatmapTable, 0, 9, tf9, text_color = color.white, text_size = size.tiny)

    table.cell(heatmapTable, 1, 9, str.tostring(r9, '#.##'), text_color = color.black, bgcolor = getHeatmapColor(r9), text_size = size.tiny)

    // TF10
    table.cell(heatmapTable, 0, 10, tf10, text_color = color.white, text_size = size.tiny)

    table.cell(heatmapTable, 1, 10, str.tostring(r10, '#.##'), text_color = color.black, bgcolor = getHeatmapColor(r10), text_size = size.tiny)
````

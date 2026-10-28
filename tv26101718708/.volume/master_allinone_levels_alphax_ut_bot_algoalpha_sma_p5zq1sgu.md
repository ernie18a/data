# Master All-In-One: Levels + AlphaX + UT Bot + AlgoAlpha + SMA

- url: https://www.tradingview.com/script/p5zQ1sGu-Master-All-In-One-Levels-AlphaX-UT-Bot-AlgoAlpha-SMA/
- type: indicator
- pine_id: PUB;7c38146e37e24563a01564d8bf106afb
- version: 1.0

## Description

# Master Signal Indicator

**Master Signal Indicator** is an advanced multi-factor trading system designed to identify high-probability market opportunities by combining trend, momentum, volume, volatility, and price action into a single actionable signal.

Unlike traditional indicators that rely on a single metric, Master Signal analyzes multiple market conditions simultaneously to reduce noise and filter out low-quality setups. The indicator is built to help traders quickly identify potential entries, exits, trend continuations, and reversal opportunities across stocks, ETFs, futures, forex, and cryptocurrencies.

### Key Features

* Multi-factor signal generation using trend, momentum, and volume confirmation.
* High-probability Buy and Sell signals with built-in filtering logic.
* Multi-timeframe trend alignment for stronger trade validation.
* Dynamic support and resistance identification.
* Early trend detection before major market moves develop.
* Volatility-aware filtering to avoid choppy market conditions.
* Visual signal markers for quick decision-making.
* Suitable for scalping, day trading, swing trading, and position trading.

### How It Works

Master Signal continuously evaluates market structure, trend strength, momentum shifts, and volume participation. Signals are generated only when multiple conditions align, helping traders focus on quality setups rather than reacting to every price movement.

The indicator is designed to:

* Capture emerging trends early.
* Confirm trend continuation opportunities.
* Identify potential reversals at key levels.
* Filter out weak or low-conviction setups.
* Improve risk-to-reward decision making.

### Best Use Cases

* Trend-following strategies.
* Breakout trading.
* Pullback entries in strong trends.
* Momentum-based trading systems.
* Multi-timeframe confirmation trading.

### Risk Disclaimer

No indicator guarantees profits. Master Signal should be used as part of a complete trading plan that includes proper risk management, position sizing, and market analysis.

## Source Code

````pine
//@version=6
indicator("Master All-In-One: Levels + AlphaX + UT Bot + AlgoAlpha + SMA", shorttitle="MegaSignal", overlay=true, max_labels_count=500, max_lines_count=500, max_bars_back=500)

// ============================================================================
// SCRIPT 1: ALL-IN-ONE LEVELS (CLEAN)
// ============================================================================

// ==========================================
// 1. SETTINGS & INPUTS
// ==========================================
show_pd   = input.bool(true,  "Show Prev Day Levels", group="Levels - Toggles")
show_pm   = input.bool(true,  "Show Premarket High/Low", group="Levels - Toggles")
show_orb5 = input.bool(true,  "Show 5-min ORB", group="Levels - Toggles")
show_orb15= input.bool(true,  "Show 15-min ORB", group="Levels - Toggles")

c_pdh   = input.color(color.new(color.green, 40), "PDH Color", group="Levels - Appearance")
c_pdl   = input.color(color.new(color.red, 40),   "PDL Color", group="Levels - Appearance")
c_pdc   = input.color(color.new(color.gray, 40),  "PDC Color", group="Levels - Appearance")
c_pm    = input.color(color.new(color.yellow, 30),"Pre-Market Color", group="Levels - Appearance")
c_orb5  = input.color(color.new(color.blue, 30),  "ORB 5m Color", group="Levels - Appearance")
c_orb15 = input.color(color.new(color.purple, 30),"ORB 15m Color", group="Levels - Appearance")

t_sess_start = input.session("0930-1600", "Regular Session (NY)", group="Levels - Time Settings")
t_pm_start   = input.session("0400-0930", "Premarket Session (NY)", group="Levels - Time Settings")

dHigh  = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
dLow   = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
dClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)

var float pm_h = na
var float pm_l = na
var float orb5_h = na
var float orb5_l = na
var float orb15_h = na
var float orb15_l = na

bool is_new_day = ta.change(time("D")) != 0
bool in_premarket = not na(time(timeframe.period, t_pm_start, "America/New_York"))
bool in_orb5 = not na(time(timeframe.period, "0930-0935", "America/New_York"))
bool in_orb15 = not na(time(timeframe.period, "0930-0945", "America/New_York"))

if is_new_day
    pm_h := na
    pm_l := na
    orb5_h := na
    orb5_l := na
    orb15_h := na
    orb15_l := na

if in_premarket
    pm_h := na(pm_h) ? high : math.max(pm_h, high)
    pm_l := na(pm_l) ? low  : math.min(pm_l, low)

if in_orb5
    orb5_h := na(orb5_h) ? high : math.max(orb5_h, high)
    orb5_l := na(orb5_l) ? low  : math.min(orb5_l, low)

if in_orb15
    orb15_h := na(orb15_h) ? high : math.max(orb15_h, high)
    orb15_l := na(orb15_l) ? low  : math.min(orb15_l, low)

var int start_idx = na
if is_new_day
    start_idx := bar_index

var line l_pdh = na
var label lb_pdh = na
var line l_pdl = na
var label lb_pdl = na
var line l_pdc = na
var label lb_pdc = na
var line l_pmh = na
var label lb_pmh = na
var line l_pml = na
var label lb_pml = na
var line l_orb5h = na
var label lb_orb5h = na
var line l_orb5l = na
var label lb_orb5l = na
var line l_orb15h = na
var label lb_orb15h = na
var line l_orb15l = na
var label lb_orb15l = na

draw_level(price, txt, col, style, show) =>
    line ln = na
    label lb = na
    if show and not na(price) and not na(start_idx)
        ln := line.new(start_idx, price, bar_index + 10, price, color=col, width=1, style=style)
        lb := label.new(bar_index + 10, price, txt, style=label.style_none, textcolor=col, size=size.normal)
    [ln, lb]

if barstate.islast
    line.delete(l_pdh), label.delete(lb_pdh)
    line.delete(l_pdl), label.delete(lb_pdl)
    line.delete(l_pdc), label.delete(lb_pdc)
    line.delete(l_pmh), label.delete(lb_pmh)
    line.delete(l_pml), label.delete(lb_pml)
    line.delete(l_orb5h), label.delete(lb_orb5h)
    line.delete(l_orb5l), label.delete(lb_orb5l)
    line.delete(l_orb15h), label.delete(lb_orb15h)
    line.delete(l_orb15l), label.delete(lb_orb15l)

    [t_pdh, tb_pdh] = draw_level(dHigh,  "PDH", c_pdh, line.style_solid,  show_pd)
    l_pdh := t_pdh, lb_pdh := tb_pdh
    [t_pdl, tb_pdl] = draw_level(dLow,   "PDL", c_pdl, line.style_solid,  show_pd)
    l_pdl := t_pdl, lb_pdl := tb_pdl
    [t_pdc, tb_pdc] = draw_level(dClose, "PDC", c_pdc, line.style_dashed, show_pd)
    l_pdc := t_pdc, lb_pdc := tb_pdc
    [t_pmh, tb_pmh] = draw_level(pm_h, "PM High", c_pm, line.style_dotted, show_pm)
    l_pmh := t_pmh, lb_pmh := tb_pmh
    [t_pml, tb_pml] = draw_level(pm_l, "PM Low",  c_pm, line.style_dotted, show_pm)
    l_pml := t_pml, lb_pml := tb_pml
    [t_o5h, tb_o5h] = draw_level(orb5_h, "ORB 5H", c_orb5, line.style_solid, show_orb5)
    l_orb5h := t_o5h, lb_orb5h := tb_o5h
    [t_o5l, tb_o5l] = draw_level(orb5_l, "ORB 5L", c_orb5, line.style_solid, show_orb5)
    l_orb5l := t_o5l, lb_orb5l := tb_o5l
    [t_o15h, tb_o15h] = draw_level(orb15_h, "ORB 15H", c_orb15, line.style_dashed, show_orb15)
    l_orb15h := t_o15h, lb_orb15h := tb_o15h
    [t_o15l, tb_o15l] = draw_level(orb15_l, "ORB 15L", c_orb15, line.style_dashed, show_orb15)
    l_orb15l := t_o15l, lb_orb15l := tb_o15l

// ============================================================================
// SCRIPT 2: ALPHAX VISION
// ============================================================================

fusionLength  = input.int(122, "Fusion MA Length", minval=7, maxval=200, group="AlphaX - Fusion System")
sens1         = input.int(12, "Fusion Slow Sensitivity", minval=3, maxval=20, group="AlphaX - Fusion System")
sens2         = input.int(5, "Fusion Fast Sensitivity", minval=2, maxval=15, group="AlphaX - Fusion System")
showCloud     = input.bool(true,"Show Trend Cloud", group="AlphaX - Fusion System")

showEmaFast     = input.bool(true, "Show Fast EMA", group="AlphaX - EMA Settings")
showEmaMedium   = input.bool(true, "Show Medium EMA", group="AlphaX - EMA Settings")
showEmaSlow     = input.bool(true, "Show Slow EMA", group="AlphaX - EMA Settings")
emaFastLength   = input.int(21, "Fast EMA Length", minval=1, maxval=500, group="AlphaX - EMA Settings")
emaMediumLength = input.int(55, "Medium EMA Length", minval=1, maxval=500, group="AlphaX - EMA Settings")
emaSlowLength   = input.int(120, "Slow EMA Length", minval=1, maxval=500, group="AlphaX - EMA Settings")

fastWPR_period   = input.int(21, "Fast WPR Period", minval=3, maxval=24, group="AlphaX - Pro Settings")
slowWPR_period   = input.int(55, "Slow WPR Period", minval=15, maxval=60, group="AlphaX - Pro Settings")
turtleWPR_period = input.int(120, "Turtle WPR Period", minval=100, maxval=500, group="AlphaX - Pro Settings")
oversold_level   = input.int(-90, "Oversold Level", minval=-99, maxval=-70, group="AlphaX - Pro Settings")
overbought_level = input.int(-10, "Overbought Level", minval=-30, maxval=-1, group="AlphaX - Pro Settings")
proTrendLookback = input.int(20, "Trend Detection Period", minval=10, maxval=50, group="AlphaX - Pro Settings")
minProConfidence = input.float(14,"Min Pro Confidence %", minval=0, maxval=100, step=5, group="AlphaX - Pro Settings")
enableProTrendGate      = input.bool(true, "Enable Trend Alignment Gate", group="AlphaX - Pro Settings")
proTrendGateStrict      = input.bool(true, "Strict Mode (Stronger Filter)", group="AlphaX - Pro Settings")
proUptrendTurtleLevel   = input.float(-35, "Uptrend: Turtle WPR Above", minval=-50, maxval=-10, step=1, group="AlphaX - Pro Settings")
proUptrendSlowLevel     = input.float(-40, "Uptrend: Slow WPR Above", minval=-60, maxval=-20, step=1, group="AlphaX - Pro Settings")
proDowntrendTurtleLevel = input.float(-65, "Downtrend: Turtle WPR Below", minval=-90, maxval=-50, step=1, group="AlphaX - Pro Settings")
proDowntrendSlowLevel   = input.float(-60, "Downtrend: Slow WPR Below", minval=-80, maxval=-40, step=1, group="AlphaX - Pro Settings")
enableProRecoveryReq    = input.bool(true, "Require WPR Recovery (Counter-Trend)", group="AlphaX - Pro Settings")
proRecoveryBars         = input.int(3, "Recovery Lookback (bars)", minval=2, maxval=10, group="AlphaX - Pro Settings")
proRecoveryMinMove      = input.float(6, "Minimum Recovery Move", minval=2, maxval=20, step=1, group="AlphaX - Pro Settings")

trendCooldown      = input.int(25, "Trend Label Cooldown (bars)", minval=1, maxval=50, group="AlphaX - Trend Filters")
signalAtrOffset    = input.float(2.4, "Signal ATR Offset", minval=0.0, maxval=10.0, step=0.1, group="AlphaX - Trend Filters")
signalLabelSizeStr = input.string("small", "Signal Label Size", options=["tiny","small","normal"], group="AlphaX - Trend Filters")

enableDateFilter = input.bool(false, "Enable Date Filter", group="AlphaX - Date Filter")
startDate        = input.time(timestamp("2026-03-20 00:00 +0000"), "Start Date", group="AlphaX - Date Filter")
endDate          = input.time(timestamp("2026-03-21 23:59 +0000"), "End Date", group="AlphaX - Date Filter")
inDateRange = not enableDateFilter or (time >= startDate and time <= endDate)

color BULL_PRIMARY    = input.color(#c8e624, "Bull Primary Color", group="AlphaX - Theme")
color BULL_BRIGHT     = input.color(#d4f03a, "Bull Bright Color", group="AlphaX - Theme")
color BULL_DIM        = input.color(#9ab81c, "Bull Dim Color", group="AlphaX - Theme")
color BEAR_PRIMARY    = input.color(#ff1744, "Bear Primary Color", group="AlphaX - Theme")
color BEAR_BRIGHT     = input.color(#ff5252, "Bear Bright Color", group="AlphaX - Theme")
color BEAR_DIM        = input.color(#d50032, "Bear Dim Color", group="AlphaX - Theme")
color NEUTRAL_COLOR   = input.color(#555555, "Neutral / Inactive", group="AlphaX - Theme")
color EMA_FAST_CLR    = input.color(#c8e624, "Fast EMA Color", group="AlphaX - Theme")
color EMA_MED_CLR     = input.color(#888888, "Medium EMA Color", group="AlphaX - Theme")
color EMA_SLOW_CLR    = input.color(#555555, "Slow EMA Color", group="AlphaX - Theme")

emaFast   = ta.ema(close, emaFastLength)
emaMedium = ta.ema(close, emaMediumLength)
emaSlow   = ta.ema(close, emaSlowLength)

plot(showEmaFast ? emaFast : na, "Fast EMA", color=EMA_FAST_CLR, linewidth=1, style=plot.style_cross)
plot(showEmaMedium ? emaMedium : na, "Medium EMA", color=EMA_MED_CLR, linewidth=1, style=plot.style_line)
plot(showEmaSlow ? emaSlow : na, "Slow EMA", color=EMA_SLOW_CLR, linewidth=2, style=plot.style_line)

emaVal   = ta.ema(close, fusionLength)
smaVal   = ta.sma(close, fusionLength)
wmaVal   = ta.wma(close, fusionLength)
almaVal  = ta.alma(close, fusionLength, 0.85, 6.0)
vwapVal  = ta.vwap(hlc3)

rawFusion  = (emaVal + smaVal + wmaVal + almaVal + vwapVal) / 5
fusionSlow = ta.ema(rawFusion, sens1)
fusionFast = ta.ema(rawFusion, sens2)

slopeUp       = fusionSlow > fusionSlow[1]
slopeDown     = fusionSlow < fusionSlow[1]
slopeFastUp   = fusionFast > fusionFast[1]
slopeFastDown = fusionFast < fusionFast[1]

bullishCondition = close > fusionSlow and slopeUp
bearishCondition = close < fusionSlow and slopeDown
neutralCondition = not bullishCondition and not bearishCondition

fusionAlignedBull = fusionFast > fusionSlow
fusionAlignedBear = fusionFast < fusionSlow

fusionLineColor = bullishCondition ? BULL_PRIMARY : bearishCondition ? BEAR_PRIMARY : NEUTRAL_COLOR
cloudBaseColor  = fusionFast > fusionSlow ? BULL_PRIMARY : fusionFast < fusionSlow ? BEAR_PRIMARY : NEUTRAL_COLOR

fusionSlowPlot = plot(fusionSlow, "Fusion Slow", color=fusionLineColor, linewidth=2)
fusionFastPlot = plot(fusionFast, "Fusion Fast", color=fusionLineColor, linewidth=1)

distance   = close - fusionSlow
gradLevel1 = fusionSlow + distance * 0.20
gradLevel2 = fusionSlow + distance * 0.40
gradLevel3 = fusionSlow + distance * 0.60
gradLevel4 = fusionSlow + distance * 0.80

pricePlot = plot(close, "Price", display=display.none)
grad1Plot = plot(gradLevel1, "Gradient 1", display=display.none)
grad2Plot = plot(gradLevel2, "Gradient 2", display=display.none)
grad3Plot = plot(gradLevel3, "Gradient 3", display=display.none)
grad4Plot = plot(gradLevel4, "Gradient 4", display=display.none)

cBull = bullishCondition
cBear = bearishCondition

fill(fusionSlowPlot, fusionFastPlot, color=showCloud ? color.new(cloudBaseColor, 65) : na, title="Main Cloud")
fill(fusionSlowPlot, grad1Plot, color=showCloud ? (cBull ? color.new(BULL_PRIMARY, 72) : cBear ? color.new(BEAR_PRIMARY, 72) : na) : na, title="Cloud Layer 1")
fill(grad1Plot, grad2Plot, color=showCloud ? (cBull ? color.new(BULL_PRIMARY, 80) : cBear ? color.new(BEAR_PRIMARY, 80) : na) : na, title="Cloud Layer 2")
fill(grad2Plot, grad3Plot, color=showCloud ? (cBull ? color.new(BULL_DIM, 86) : cBear ? color.new(BEAR_DIM, 86) : na) : na, title="Cloud Layer 3")
fill(grad3Plot, grad4Plot, color=showCloud ? (cBull ? color.new(BULL_DIM, 91) : cBear ? color.new(BEAR_DIM, 91) : na) : na, title="Cloud Layer 4")
fill(grad4Plot, pricePlot, color=showCloud ? (cBull ? color.new(BULL_DIM, 95) : cBear ? color.new(BEAR_DIM, 95) : na) : na, title="Cloud Layer 5")

rsiVal       = ta.rsi(close, 14)
rsiEma       = ta.ema(rsiVal, 7)
rsiSlopeUp   = rsiEma > rsiEma[1] and rsiEma > rsiEma[2]
rsiSlopeDown = rsiEma < rsiEma[1] and rsiEma < rsiEma[2]

[macdLine, signalLine, histLine] = ta.macd(close, 12, 26, 9)
macdBullish      = macdLine > signalLine
macdBearish      = macdLine < signalLine
macdMomentumUp   = histLine > histLine[1]
macdMomentumDown = histLine < histLine[1]

stochK       = ta.stoch(close, high, low, 14)
stochD       = ta.sma(stochK, 3)
stochBullish = stochK > stochD
stochBearish = stochK < stochD

higherHigh = high > high[1] and high[1] > high[2]
lowerLow   = low  < low[1]  and low[1]  < low[2]
higherLow  = low  > low[1]
lowerHigh  = high < high[1]

strongBullClose = close > (high + low) / 2 and close > open
strongBearClose = close < (high + low) / 2 and close < open

emaMediumSlopeUp   = emaMedium > emaMedium[1]
emaMediumSlopeDown = emaMedium < emaMedium[1]
emasAlignedBull    = emaMedium > emaSlow
emasAlignedBear    = emaMedium < emaSlow

bullF1 = close > fusionSlow and close > fusionFast ? 1 : 0
bullF2 = fusionAlignedBull ? 1 : 0
bullF3 = slopeUp and slopeFastUp ? 1 : 0
bullF4 = close > emaMedium and emaMediumSlopeUp ? 1 : 0
bullF5 = close > emaSlow or emasAlignedBull ? 1 : 0
bullF6 = macdBullish and macdMomentumUp ? 1 : 0
bullF7 = rsiEma > 45 and rsiEma < 75 and rsiSlopeUp ? 1 : 0
bullF8 = stochBullish and stochK > 30 ? 1 : 0
bullF9 = strongBullClose and (higherLow or higherHigh) ? 1 : 0
bullFusionScore = bullF1 + bullF2 + bullF3 + bullF4 + bullF5 + bullF6 + bullF7 + bullF8 + bullF9

bearF1 = close < fusionSlow and close < fusionFast ? 1 : 0
bearF2 = fusionAlignedBear ? 1 : 0
bearF3 = slopeDown and slopeFastDown ? 1 : 0
bearF4 = close < emaMedium and emaMediumSlopeDown ? 1 : 0
bearF5 = close < emaSlow or emasAlignedBear ? 1 : 0
bearF6 = macdBearish and macdMomentumDown ? 1 : 0
bearF7 = rsiEma < 55 and rsiEma > 25 and rsiSlopeDown ? 1 : 0
bearF8 = stochBearish and stochK < 70 ? 1 : 0
bearF9 = strongBearClose and (lowerHigh or lowerLow) ? 1 : 0
bearFusionScore = bearF1 + bearF2 + bearF3 + bearF4 + bearF5 + bearF6 + bearF7 + bearF8 + bearF9

wasBullish = bullishCondition[1]
wasBearish = bearishCondition[1]
wasNeutral = neutralCondition[1]

colorChangedToGreen  = bullishCondition and (wasBearish or wasNeutral)
colorChangedToPurple = bearishCondition and (wasBullish or wasNeutral)

var int lastTrendLabelBar  = 0
var int lastTrendDirection = 0

bullCooldownOK = (lastTrendDirection != 1) or ((bar_index - lastTrendLabelBar) >= trendCooldown)
bearCooldownOK = (lastTrendDirection != -1) or ((bar_index - lastTrendLabelBar) >= trendCooldown)

fusionBullSignal = colorChangedToGreen and bullCooldownOK
fusionBearSignal = colorChangedToPurple and bearCooldownOK

if fusionBullSignal
    lastTrendLabelBar  := bar_index
    lastTrendDirection := 1

if fusionBearSignal
    lastTrendLabelBar  := bar_index
    lastTrendDirection := -1

fastWPR   = ta.wpr(fastWPR_period)
slowWPR   = ta.wpr(slowWPR_period)
turtleWPR = ta.wpr(turtleWPR_period)

proEma200        = ta.ema(close, 200)
proEma50         = ta.ema(close, 50)
proPriceAboveEma = close > proEma200
proPriceBelowEma = close < proEma200
proEmaBullish    = proEma50 > proEma200
proEmaBearish    = proEma50 < proEma200

proRsi = ta.rsi(close, 14)

avgVolume          = ta.sma(volume, 20)
proVolumeStrength  = volume / avgVolume
proLowVolume       = proVolumeStrength < 0.7

proCurrentHour      = hour(time, "UTC")
proIsAsianSession   = proCurrentHour >= 0  and proCurrentHour < 8
proIsLondonSession  = proCurrentHour >= 8  and proCurrentHour < 13
proIsOverlapSession = proCurrentHour >= 13 and proCurrentHour < 17
proIsNyAfternoon    = proCurrentHour >= 17 and proCurrentHour < 21
proIsNyClose        = proCurrentHour >= 21 and proCurrentHour < 24
proSessionQuality   = proIsOverlapSession ? 100 : proIsLondonSession ? 85 : proIsNyAfternoon ? 60 : proIsAsianSession ? 30 : 40

proSlowSlope   = (slowWPR - slowWPR[proTrendLookback]) / proTrendLookback
proTurtleSlope = (turtleWPR - turtleWPR[proTrendLookback]) / proTrendLookback

proSlowTrendingUp     = proSlowSlope > 0.3
proSlowTrendingDown   = proSlowSlope < -0.3
proTurtleTrendingUp   = proTurtleSlope > 0.15
proTurtleTrendingDown = proTurtleSlope < -0.15

proVeryStrongUptrend   = turtleWPR > -30 and slowWPR > -40
proStrongUptrend       = turtleWPR > -40 and slowWPR > -50
proModerateUptrend     = turtleWPR > -55 and slowWPR > -60
proVeryStrongDowntrend = turtleWPR < -70 and slowWPR < -60
proStrongDowntrend     = turtleWPR < -60 and slowWPR < -50
proModerateDowntrend   = turtleWPR < -45 and slowWPR < -40

proFastVelocity = fastWPR - fastWPR[1]
proVelocityBase = proIsOverlapSession ? 1.0 : proIsLondonSession ? 0.9 : proIsNyAfternoon ? 0.8 : proIsAsianSession ? 0.5 : 0.6
proVelocityWeakThreshold    = 3  * proVelocityBase
proVelocityIdealMin         = 5  * proVelocityBase
proVelocityIdealMax         = 30 * proVelocityBase
proVelocityStrongThreshold  = 35 * proVelocityBase
proVelocityExtremeThreshold = 45 * proVelocityBase

absVel = math.abs(proFastVelocity)
proVelocityQuality = absVel >= proVelocityIdealMin and absVel <= proVelocityIdealMax ? "IDEAL" : absVel > proVelocityIdealMax and absVel <= proVelocityStrongThreshold ? "STRONG" : absVel > proVelocityStrongThreshold ? "EXTREME" : "WEAK"

proFastCrossesUp   = ta.crossover(fastWPR, oversold_level)
proFastCrossesDown = ta.crossunder(fastWPR, overbought_level)

proPivotLookback  = 5
proPivotLowPrice  = ta.pivotlow(low, proPivotLookback, proPivotLookback)
proPivotHighPrice = ta.pivothigh(high, proPivotLookback, proPivotLookback)

var float proPrevPivotLowPrice  = na
var float proPrevPivotLowWpr    = na
var int   proPrevPivotLowBar    = na
var float proPrevPivotHighPrice = na
var float proPrevPivotHighWpr   = na
var int   proPrevPivotHighBar   = na
var float proCurrPivotLowPrice  = na
var float proCurrPivotLowWpr    = na
var int   proCurrPivotLowBar    = na
var float proCurrPivotHighPrice = na
var float proCurrPivotHighWpr   = na
var int   proCurrPivotHighBar   = na

if not na(proPivotLowPrice)
    proPrevPivotLowPrice := proCurrPivotLowPrice
    proPrevPivotLowWpr   := proCurrPivotLowWpr
    proPrevPivotLowBar   := proCurrPivotLowBar
    proCurrPivotLowPrice := proPivotLowPrice
    proCurrPivotLowWpr   := fastWPR[proPivotLookback]
    proCurrPivotLowBar   := bar_index - proPivotLookback

if not na(proPivotHighPrice)
    proPrevPivotHighPrice := proCurrPivotHighPrice
    proPrevPivotHighWpr   := proCurrPivotHighWpr
    proPrevPivotHighBar   := proCurrPivotHighBar
    proCurrPivotHighPrice := proPivotHighPrice
    proCurrPivotHighWpr   := fastWPR[proPivotLookback]
    proCurrPivotHighBar   := bar_index - proPivotLookback

proBullishDivergence = not na(proPrevPivotLowPrice) and not na(proCurrPivotLowPrice) and not na(proPrevPivotLowWpr) and not na(proCurrPivotLowWpr) and proCurrPivotLowPrice < proPrevPivotLowPrice and proCurrPivotLowWpr > proPrevPivotLowWpr and bar_index - proCurrPivotLowBar <= 3 and proCurrPivotLowBar - proPrevPivotLowBar <= 50 and proCurrPivotLowBar - proPrevPivotLowBar >= 5
proBearishDivergence = not na(proPrevPivotHighPrice) and not na(proCurrPivotHighPrice) and not na(proPrevPivotHighWpr) and not na(proCurrPivotHighWpr) and proCurrPivotHighPrice > proPrevPivotHighPrice and proCurrPivotHighWpr < proPrevPivotHighWpr and bar_index - proCurrPivotHighBar <= 3 and proCurrPivotHighBar - proPrevPivotHighBar <= 50 and proCurrPivotHighBar - proPrevPivotHighBar >= 5

proDivergenceBuyTrigger = proBullishDivergence and proFastVelocity > proVelocityWeakThreshold
proDivergenceSellTrigger = proBearishDivergence and proFastVelocity < -proVelocityWeakThreshold

proExtremeSnapBuy = fastWPR[1] < -88 and proFastVelocity > proVelocityWeakThreshold and (turtleWPR > -65 or slowWPR > -65) and proFastCrossesUp
proExtremeSnapSell = fastWPR[1] > -12 and proFastVelocity < -proVelocityWeakThreshold and (turtleWPR < -35 or slowWPR < -35) and proFastCrossesDown

proExhaustionBuy = fastWPR[1] < -78 and (turtleWPR > -75 or slowWPR > -70) and proFastVelocity > proVelocityWeakThreshold and proFastCrossesUp
proExhaustionSell = fastWPR[1] > -22 and (turtleWPR < -25 or slowWPR < -30) and proFastVelocity < -proVelocityWeakThreshold and proFastCrossesDown

proBuyContinuation = proFastCrossesUp and (proVeryStrongUptrend or proStrongUptrend) and (proSlowTrendingUp or proTurtleTrendingUp)
proSellContinuation = proFastCrossesDown and (proVeryStrongDowntrend or proStrongDowntrend) and (proSlowTrendingDown or proTurtleTrendingDown)

proBuyPullback = proFastCrossesUp and (proModerateUptrend or slowWPR > -60) and proFastVelocity > proVelocityWeakThreshold
proSellPullback = proFastCrossesDown and (proModerateDowntrend or slowWPR < -40) and proFastVelocity < -proVelocityWeakThreshold

proAllOversold   = fastWPR < -78 and slowWPR < -68 and turtleWPR < -60
proAllOverbought = fastWPR > -22 and slowWPR > -32 and turtleWPR > -40

proTripleBuy = proAllOversold and proFastVelocity > proVelocityWeakThreshold and proFastCrossesUp
proTripleSell = proAllOverbought and proFastVelocity < -proVelocityWeakThreshold and proFastCrossesDown

proBuySignalCount = (proDivergenceBuyTrigger ? 1 : 0) + (proExtremeSnapBuy ? 1 : 0) + (proExhaustionBuy ? 1 : 0) + (proBuyContinuation ? 1 : 0) + (proBuyPullback ? 1 : 0) + (proTripleBuy ? 1 : 0)
proSellSignalCount = (proDivergenceSellTrigger ? 1 : 0) + (proExtremeSnapSell ? 1 : 0) + (proExhaustionSell ? 1 : 0) + (proSellContinuation ? 1 : 0) + (proSellPullback ? 1 : 0) + (proTripleSell ? 1 : 0)

proStackingBonusBuy = proBuySignalCount >= 3 ? 15 : proBuySignalCount >= 2 ? 8 : 0
proStackingBonusSell = proSellSignalCount >= 3 ? 15 : proSellSignalCount >= 2 ? 8 : 0

calcProBuyConfidence() =>
    float c = 0.0
    c += turtleWPR > -35 ? 25.0 : turtleWPR > -45 ? 20.0 : turtleWPR > -55 ? 12.0 : turtleWPR > -65 ? 5.0 : 0.0
    c += fastWPR < -94 ? 20.0 : fastWPR < -90 ? 16.0 : fastWPR < -85 ? 12.0 : fastWPR < -80 ? 6.0 : 0.0
    c += proTripleBuy ? 20.0 : proBuyContinuation ? 18.0 : proDivergenceBuyTrigger ? 17.0 : proExtremeSnapBuy ? 14.0 : proExhaustionBuy ? 11.0 : proBuyPullback ? 8.0 : 0.0
    c += proVelocityQuality == "IDEAL" ? 15.0 : proVelocityQuality == "STRONG" ? 10.0 : proVelocityQuality == "EXTREME" ? 3.0 : 6.0
    c += proSessionQuality / 10.0
    c += proPriceAboveEma and proEmaBullish ? 5.0 : proPriceAboveEma ? 2.0 : 0.0
    c += proStackingBonusBuy
    c -= absVel > proVelocityExtremeThreshold ? 10.0 : absVel > proVelocityStrongThreshold ? 5.0 : 0.0
    c -= proRsi > 72 ? 8.0 : proRsi > 65 ? 3.0 : 0.0
    c -= proIsAsianSession ? 10.0 : proIsNyClose ? 5.0 : 0.0
    c -= proLowVolume ? 5.0 : 0.0
    math.max(0.0, math.min(100.0, c))

calcProSellConfidence() =>
    float c = 0.0
    c += turtleWPR < -65 ? 25.0 : turtleWPR < -55 ? 20.0 : turtleWPR < -45 ? 12.0 : turtleWPR < -35 ? 5.0 : 0.0
    c += fastWPR > -6 ? 20.0 : fastWPR > -10 ? 16.0 : fastWPR > -15 ? 12.0 : fastWPR > -20 ? 6.0 : 0.0
    c += proTripleSell ? 20.0 : proSellContinuation ? 18.0 : proDivergenceSellTrigger ? 17.0 : proExtremeSnapSell ? 14.0 : proExhaustionSell ? 11.0 : proSellPullback ? 8.0 : 0.0
    c += proVelocityQuality == "IDEAL" ? 15.0 : proVelocityQuality == "STRONG" ? 10.0 : proVelocityQuality == "EXTREME" ? 3.0 : 6.0
    c += proSessionQuality / 10.0
    c += proPriceBelowEma and proEmaBearish ? 5.0 : proPriceBelowEma ? 2.0 : 0.0
    c += proStackingBonusSell
    c -= absVel > proVelocityExtremeThreshold ? 10.0 : absVel > proVelocityStrongThreshold ? 5.0 : 0.0
    c -= proRsi < 28 ? 8.0 : proRsi < 35 ? 3.0 : 0.0
    c -= proIsAsianSession ? 10.0 : proIsNyClose ? 5.0 : 0.0
    c -= proLowVolume ? 5.0 : 0.0
    math.max(0.0, math.min(100.0, c))

proBuyConfidence  = calcProBuyConfidence()
proSellConfidence = calcProSellConfidence()

proAnyBuySignal = proDivergenceBuyTrigger or proExtremeSnapBuy or proExhaustionBuy or proBuyContinuation or proBuyPullback or proTripleBuy
proAnySellSignal = proDivergenceSellTrigger or proExtremeSnapSell or proExhaustionSell or proSellContinuation or proSellPullback or proTripleSell

proValidBuySignal  = proAnyBuySignal and proBuyConfidence >= minProConfidence
proValidSellSignal = proAnySellSignal and proSellConfidence >= minProConfidence

float adjUptrendTurtle = proTrendGateStrict ? proUptrendTurtleLevel + 5 : proUptrendTurtleLevel
float adjUptrendSlow = proTrendGateStrict ? proUptrendSlowLevel + 5 : proUptrendSlowLevel
float adjDowntrendTurtle = proTrendGateStrict ? proDowntrendTurtleLevel - 5 : proDowntrendTurtleLevel
float adjDowntrendSlow = proTrendGateStrict ? proDowntrendSlowLevel - 5 : proDowntrendSlowLevel

bool proStrongUptrendDetected = turtleWPR > adjUptrendTurtle and slowWPR > adjUptrendSlow
bool proStrongDowntrendDetected = turtleWPR < adjDowntrendTurtle and slowWPR < adjDowntrendSlow

float fastWprLowest  = ta.lowest(fastWPR, proRecoveryBars + 1)
float fastWprHighest = ta.highest(fastWPR, proRecoveryBars + 1)

bool bullRecoveryDetected = fastWPR > fastWprLowest + proRecoveryMinMove and fastWprLowest < -80
bool bearRecoveryDetected = fastWPR < fastWprHighest - proRecoveryMinMove and fastWprHighest > -20

bool proTrendGateBullPass = true
bool proTrendGateBearPass = true

if enableProTrendGate
    if proStrongDowntrendDetected
        proTrendGateBullPass := enableProRecoveryReq ? bullRecoveryDetected : false
    if proStrongUptrendDetected
        proTrendGateBearPass := enableProRecoveryReq ? bearRecoveryDetected : false

bool proGatedBuySignal  = proValidBuySignal and proTrendGateBullPass
bool proGatedSellSignal = proValidSellSignal and proTrendGateBearPass

var int  currentTrend   = 0
var bool hasEntrySignal = false

if fusionBullSignal
    currentTrend   := 1
    hasEntrySignal := false

if fusionBearSignal
    currentTrend   := -1
    hasEntrySignal := false

bool doBullEntry = currentTrend == 1 and proGatedBuySignal and inDateRange
bool doBearEntry = currentTrend == -1 and proGatedSellSignal and inDateRange
bool doBullExit  = currentTrend == 1 and proGatedSellSignal and hasEntrySignal and inDateRange
bool doBearExit  = currentTrend == -1 and proGatedBuySignal and hasEntrySignal and inDateRange

if doBullEntry or doBearEntry
    hasEntrySignal := true

atrVal       = ta.atr(14)
atrOffset    = atrVal * signalAtrOffset
signalSize   = signalLabelSizeStr == "normal" ? size.huge : signalLabelSizeStr == "small" ? size.large : size.normal

if fusionBullSignal
    label.new(bar_index, low, text=" B U L L ", yloc=yloc.belowbar, color=color.new(BULL_PRIMARY, 15), textcolor=#1a1a1a, size=size.tiny, style=label.style_label_up)

if fusionBearSignal
    label.new(bar_index, high, text=" B E A R ", yloc=yloc.abovebar, color=color.new(BEAR_PRIMARY, 15), textcolor=#ffffff, size=size.tiny, style=label.style_label_down)

if doBullEntry
    float triY = low - atrOffset
    label.new(bar_index, triY, text="▲", color=color.new(BULL_BRIGHT, 0), textcolor=BULL_BRIGHT, style=label.style_none, size=signalSize)
    line.new(bar_index, low, bar_index, triY + atrOffset * 0.15, color=color.new(BULL_BRIGHT, 50), width=1, style=line.style_dotted)

if doBearEntry
    float triY = high + atrOffset
    label.new(bar_index, triY, text="▼", color=color.new(BEAR_BRIGHT, 0), textcolor=BEAR_BRIGHT, style=label.style_none, size=signalSize)
    line.new(bar_index, high, bar_index, triY - atrOffset * 0.15, color=color.new(BEAR_BRIGHT, 50), width=1, style=line.style_dotted)

if doBullExit
    float exitY = high + atrOffset
    label.new(bar_index, exitY, text="✕", color=color.new(NEUTRAL_COLOR, 0), textcolor=NEUTRAL_COLOR, style=label.style_none, size=signalSize)
    line.new(bar_index, high, bar_index, exitY - atrOffset * 0.15, color=color.new(NEUTRAL_COLOR, 60), width=1, style=line.style_dotted)

if doBearExit
    float exitY = low - atrOffset
    label.new(bar_index, exitY, text="✕", color=color.new(NEUTRAL_COLOR, 0), textcolor=NEUTRAL_COLOR, style=label.style_none, size=signalSize)
    line.new(bar_index, low, bar_index, exitY + atrOffset * 0.15, color=color.new(NEUTRAL_COLOR, 60), width=1, style=line.style_dotted)

// ============================================================================
// SCRIPT 3: UT BOT ALERTS
// ============================================================================

ut_a = input.float(1, title="Key Value. 'This changes the sensitivity'", group="UT Bot")
ut_c = input.int(10, title="ATR Period", group="UT Bot")
ut_h = input.bool(false, title="Signals from Heikin Ashi Candles", group="UT Bot")

ut_xATR  = ta.atr(ut_c)
ut_nLoss = ut_a * ut_xATR

ut_haTicker = ticker.heikinashi(syminfo.tickerid)
ut_src = ut_h ? request.security(ut_haTicker, timeframe.period, close, lookahead=barmerge.lookahead_off) : close

var float ut_xATRTrailingStop = 0.0
ut_xATRTrailingStop := ut_src > nz(ut_xATRTrailingStop[1], 0) and ut_src[1] > nz(ut_xATRTrailingStop[1], 0) ? math.max(nz(ut_xATRTrailingStop[1]), ut_src - ut_nLoss) :
     ut_src < nz(ut_xATRTrailingStop[1], 0) and ut_src[1] < nz(ut_xATRTrailingStop[1], 0) ? math.min(nz(ut_xATRTrailingStop[1]), ut_src + ut_nLoss) :
     ut_src > nz(ut_xATRTrailingStop[1], 0) ? ut_src - ut_nLoss : ut_src + ut_nLoss

var int ut_pos = 0
ut_pos := ut_src[1] < nz(ut_xATRTrailingStop[1], 0) and ut_src > nz(ut_xATRTrailingStop[1], 0) ? 1 :
     ut_src[1] > nz(ut_xATRTrailingStop[1], 0) and ut_src < nz(ut_xATRTrailingStop[1], 0) ? -1 : nz(ut_pos[1], 0)

ut_ema   = ta.ema(ut_src, 1)
ut_above = ta.crossover(ut_ema, ut_xATRTrailingStop)
ut_below = ta.crossover(ut_xATRTrailingStop, ut_ema)

ut_buy  = ut_src > ut_xATRTrailingStop and ut_above
ut_sell = ut_src < ut_xATRTrailingStop and ut_below

ut_barbuy  = ut_src > ut_xATRTrailingStop
ut_barsell = ut_src < ut_xATRTrailingStop

plotshape(ut_buy, title="UT Buy", text='Buy', style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.tiny)
plotshape(ut_sell, title="UT Sell", text='Sell', style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.tiny)

barcolor(ut_barbuy ? color.green : na)
barcolor(ut_barsell ? color.red : na)

// ============================================================================
// SCRIPT 4: ZERO LAG TREND SIGNALS (MTF) [ALGOALPHA]
// ============================================================================

algo_length = input.int(70, "Length", tooltip="The Look-Back window for the Zero-Lag EMA calculations", group="AlgoAlpha - Main Calculations")
algo_mult = input.float(1.2, "Band Multiplier", tooltip="This value controls the thickness of the bands, a larger value makes the indicator less noisy", group="AlgoAlpha - Main Calculations")
algo_t1 = input.timeframe("5", "Time frame 1", group="AlgoAlpha - Extra Timeframes")
algo_t2 = input.timeframe("15", "Time frame 2", group="AlgoAlpha - Extra Timeframes")
algo_t3 = input.timeframe("60", "Time frame 3", group="AlgoAlpha - Extra Timeframes")
algo_t4 = input.timeframe("240", "Time frame 4", group="AlgoAlpha - Extra Timeframes")
algo_t5 = input.timeframe("1D", "Time frame 5", group="AlgoAlpha - Extra Timeframes")
algo_green = input.color(#00ffbb, "Bullish Color", group="AlgoAlpha - Appearance")
algo_red = input.color(#ff1100, "Bearish Color", group="AlgoAlpha - Appearance")

algo_src = close
algo_lag = math.floor((algo_length - 1) / 2)
algo_zlema = ta.ema(algo_src + (algo_src - algo_src[algo_lag]), algo_length)
algo_volatility = ta.highest(ta.atr(algo_length), algo_length * 3) * algo_mult

var int algo_trend = 0
if ta.crossover(close, algo_zlema + algo_volatility)
    algo_trend := 1
if ta.crossunder(close, algo_zlema - algo_volatility)
    algo_trend := -1

algo_zlemaColor = algo_trend == 1 ? color.new(algo_green, 70) : color.new(algo_red, 70)
algo_m = plot(algo_zlema, title="Zero Lag Basis", linewidth=2, color=algo_zlemaColor)
algo_upper = plot(algo_trend == -1 ? algo_zlema + algo_volatility : na, style=plot.style_linebr, color=color.new(algo_red, 90), title="Upper Deviation Band")
algo_lower = plot(algo_trend == 1 ? algo_zlema - algo_volatility : na, style=plot.style_linebr, color=color.new(algo_green, 90), title="Lower Deviation Band")

fill(algo_m, algo_upper, (open + close) / 2, algo_zlema + algo_volatility, color.new(algo_red, 90), color.new(algo_red, 70))
fill(algo_m, algo_lower, (open + close) / 2, algo_zlema - algo_volatility, color.new(algo_green, 90), color.new(algo_green, 70))

plotshape(ta.crossunder(algo_trend, 0) ? algo_zlema + algo_volatility : na, "Bearish Trend", shape.labeldown, location.absolute, algo_red, text="▼", textcolor=chart.fg_color, size=size.small)
plotshape(ta.crossover(algo_trend, 0) ? algo_zlema - algo_volatility : na, "Bullish Trend", shape.labelup, location.absolute, algo_green, text="▲", textcolor=chart.fg_color, size=size.small)

plotchar(ta.crossover(close, algo_zlema) and algo_trend == 1 and algo_trend[1] == 1 ? algo_zlema - algo_volatility * 1.5 : na, "Bullish Entry", "▲", location.absolute, algo_green, size=size.tiny)
plotchar(ta.crossunder(close, algo_zlema) and algo_trend == -1 and algo_trend[1] == -1 ? algo_zlema + algo_volatility * 1.5 : na, "Bearish Entry", "▼", location.absolute, algo_red, size=size.tiny)

algo_zlemaTrendFunction() =>
    _src = close
    _lag = math.floor((algo_length - 1) / 2)
    _zlema = ta.ema(_src + (_src - _src[_lag]), algo_length)
    _volatility = ta.highest(ta.atr(algo_length), algo_length * 3) * algo_mult
    var int _trend = 0
    if ta.crossover(close, _zlema + _volatility)
        _trend := 1
    if ta.crossunder(close, _zlema - _volatility)
        _trend := -1
    _trend

algo_s1 = request.security(syminfo.tickerid, algo_t1, algo_zlemaTrendFunction())
algo_s2 = request.security(syminfo.tickerid, algo_t2, algo_zlemaTrendFunction())
algo_s3 = request.security(syminfo.tickerid, algo_t3, algo_zlemaTrendFunction())
algo_s4 = request.security(syminfo.tickerid, algo_t4, algo_zlemaTrendFunction())
algo_s5 = request.security(syminfo.tickerid, algo_t5, algo_zlemaTrendFunction())

algo_s1a = algo_s1 == 1 ? "Bullish" : "Bearish"
algo_s2a = algo_s2 == 1 ? "Bullish" : "Bearish"
algo_s3a = algo_s3 == 1 ? "Bullish" : "Bearish"
algo_s4a = algo_s4 == 1 ? "Bullish" : "Bearish"
algo_s5a = algo_s5 == 1 ? "Bullish" : "Bearish"

if barstate.islast
    var data_table = table.new(position=position.top_right, columns=2, rows=6, bgcolor=chart.bg_color, border_width=1, border_color=chart.fg_color, frame_color=chart.fg_color, frame_width=1)
    table.cell(data_table, text_halign=text.align_center, column=0, row=0, text="Time Frame", text_color=chart.fg_color)
    table.cell(data_table, text_halign=text.align_center, column=1, row=0, text="Signal", text_color=chart.fg_color)
    table.cell(data_table, text_halign=text.align_center, column=0, row=1, text=algo_t1, text_color=chart.fg_color)
    table.cell(data_table, text_halign=text.align_center, column=1, row=1, text=algo_s1a, text_color=chart.fg_color, bgcolor=algo_s1a == "Bullish" ? color.new(algo_green, 70) : color.new(algo_red, 70))
    table.cell(data_table, text_halign=text.align_center, column=0, row=2, text=algo_t2, text_color=chart.fg_color)
    table.cell(data_table, text_halign=text.align_center, column=1, row=2, text=algo_s2a, text_color=chart.fg_color, bgcolor=algo_s2a == "Bullish" ? color.new(algo_green, 70) : color.new(algo_red, 70))
    table.cell(data_table, text_halign=text.align_center, column=0, row=3, text=algo_t3, text_color=chart.fg_color)
    table.cell(data_table, text_halign=text.align_center, column=1, row=3, text=algo_s3a, text_color=chart.fg_color, bgcolor=algo_s3a == "Bullish" ? color.new(algo_green, 70) : color.new(algo_red, 70))
    table.cell(data_table, text_halign=text.align_center, column=0, row=4, text=algo_t4, text_color=chart.fg_color)
    table.cell(data_table, text_halign=text.align_center, column=1, row=4, text=algo_s4a, text_color=chart.fg_color, bgcolor=algo_s4a == "Bullish" ? color.new(algo_green, 70) : color.new(algo_red, 70))
    table.cell(data_table, text_halign=text.align_center, column=0, row=5, text=algo_t5, text_color=chart.fg_color)
    table.cell(data_table, text_halign=text.align_center, column=1, row=5, text=algo_s5a, text_color=chart.fg_color, bgcolor=algo_s5a == "Bullish" ? color.new(algo_green, 70) : color.new(algo_red, 70))

algoBullishEntrySignal = ta.crossover(close, algo_zlema) and algo_trend == 1 and algo_trend[1] == 1
algoBearishEntrySignal = ta.crossunder(close, algo_zlema) and algo_trend == -1 and algo_trend[1] == -1

// ============================================================================
// SCRIPT 5: SIMPLE MOVING AVERAGE
// ============================================================================

sma_len = input.int(200, minval=1, title="Length", group="SMA")
sma_src = input(close, title="Source", group="SMA")
sma_offset = input.int(title="Offset", defval=0, minval=-500, maxval=500, display=display.none, group="SMA")
sma_out = ta.sma(sma_src, sma_len)
plot(sma_out, color=color.blue, title="MA", offset=sma_offset)

GRP = "SMA - Smoothing"
TT_BB = "Only applies when 'SMA + Bollinger Bands' is selected. Determines the distance between the SMA and the bands."
sma_maTypeInput = input.string("None", "Type", options=["None", "SMA", "SMA + Bollinger Bands", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group=GRP, display=display.none)
sma_isBB = sma_maTypeInput == "SMA + Bollinger Bands"
sma_maLengthInput = input.int(14, "Length", group=GRP, display=display.none, active=sma_maTypeInput != "None")
sma_bbMultInput = input.float(2.0, "BB StdDev", minval=0.001, maxval=50, step=0.5, tooltip=TT_BB, group=GRP, display=display.none, active=sma_isBB)
sma_enableMA = sma_maTypeInput != "None"

sma_ma(source, length, MAtype) =>
    switch MAtype
        "SMA" => ta.sma(source, length)
        "SMA + Bollinger Bands" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA" => ta.wma(source, length)
        "VWMA" => ta.vwma(source, length)
        => na

sma_smoothingMA = sma_enableMA ? sma_ma(sma_out, sma_maLengthInput, sma_maTypeInput) : na
sma_smoothingStDev = sma_isBB ? ta.stdev(sma_out, sma_maLengthInput) * sma_bbMultInput : na
plot(sma_smoothingMA, "SMA-based MA", color=color.yellow, display=sma_enableMA ? display.all : display.none, editable=sma_enableMA)
sma_bbUpperBand = plot(sma_smoothingMA + sma_smoothingStDev, title="Upper Bollinger Band", color=color.green, display=sma_isBB ? display.all : display.none, editable=sma_isBB)
sma_bbLowerBand = plot(sma_smoothingMA - sma_smoothingStDev, title="Lower Bollinger Band", color=color.green, display=sma_isBB ? display.all : display.none, editable=sma_isBB)
fill(sma_bbUpperBand, sma_bbLowerBand, color=sma_isBB ? color.new(color.green, 90) : na, title="Bollinger Bands Background Fill", display=sma_isBB ? display.all : display.none, editable=sma_isBB)

// ============================================================================
// ALERT CONDITIONS - REDUCED TO AVOID TRADINGVIEW 64 PLOT LIMIT
// ============================================================================
// TradingView counts alertcondition() calls toward the plot limit.
// So we keep only the most useful alerts here.

masterBullishAll = doBullEntry and ut_buy and algoBullishEntrySignal
masterBearishAll = doBearEntry and ut_sell and algoBearishEntrySignal

alertcondition(masterBullishAll, title="MASTER BUY: AlphaX + UT + AlgoAlpha", message="MASTER BUY: AlphaX Re-entry Long + UT Long + AlgoAlpha Bullish Entry on {{ticker}} {{interval}}")
alertcondition(masterBearishAll, title="MASTER SELL: AlphaX + UT + AlgoAlpha", message="MASTER SELL: AlphaX Re-entry Short + UT Short + AlgoAlpha Bearish Entry on {{ticker}} {{interval}}")

// Optional broad alerts. Keep these only if needed.
alertcondition(doBullEntry, title="AlphaX Re-Entry Long", message="AlphaX Vision: Re-entry LONG ({{ticker}} {{interval}})")
alertcondition(doBearEntry, title="AlphaX Re-Entry Short", message="AlphaX Vision: Re-entry SHORT ({{ticker}} {{interval}})")
alertcondition(ut_buy, title="UT Long", message="UT Long")
alertcondition(ut_sell, title="UT Short", message="UT Short")
alertcondition(algoBullishEntrySignal, title="AlgoAlpha Bullish Entry Signal", message="AlgoAlpha Bullish Entry Signal on {{ticker}} {{interval}}")
alertcondition(algoBearishEntrySignal, title="AlgoAlpha Bearish Entry Signal", message="AlgoAlpha Bearish Entry Signal on {{ticker}} {{interval}}")
````

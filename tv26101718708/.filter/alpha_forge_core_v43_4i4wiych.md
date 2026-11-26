# Alpha Forge Core v4.3

- url: https://www.tradingview.com/script/4i4WiycH-Alpha-Forge-Core-v4-3/
- type: indicator
- pine_id: PUB;b31f9adc8ed148079fede061dd678c35
- version: 1.0

## Description

Alpha Forge Core v4.3 is an open-source chart-analysis indicator built to combine trend, structure, momentum, and higher-timeframe context into one visual framework.

The script is designed to help users study market conditions directly on the chart. It does not attempt to predict future price movement, and its signals should be interpreted as rule-based chart events rather than trade recommendations.

Core Idea

Core v4.3 uses several layers of analysis:

Trend direction
Market structure
Momentum state
Higher-timeframe alignment
Continuation and reversal conditions
Watch / no-trade states

Instead of relying on one trigger, the script checks multiple chart conditions before displaying a signal or state.

Main Components

Trend Context

The indicator evaluates whether the market is showing bullish, bearish, or neutral behavior based on its internal trend logic. This helps users see whether price action is aligned with the broader direction or moving against it.

Structure Logic

The script includes structure-based conditions such as Break of Structure and Change of Character. These are used to identify possible continuation or transition areas on the chart.

Momentum Confirmation

Momentum is used as an additional filter to help separate stronger directional movement from weaker or flatter price action.

Higher-Timeframe Alignment

The script can compare the current chart with a higher timeframe. This is useful for users who want to see whether lower-timeframe conditions are aligned with broader market context.

Signal Types

Core v4.3 separates signals into different categories so users can understand the type of condition being shown.

Buy Continuation

A bullish continuation condition appears when the script detects that bullish trend and momentum conditions remain active.

Sell Continuation

A bearish continuation condition appears when the script detects that bearish trend and momentum conditions remain active.

Buy Reversal

A bullish reversal condition appears when the script detects a possible transition from bearish or weak conditions into a stronger bullish state.

Sell Reversal

A bearish reversal condition appears when the script detects a possible transition from bullish or strong conditions into a weaker bearish state.

Watch / No Trade

The watch or no-trade state appears when the script’s conditions are not fully aligned. This is intended to provide chart context when the market does not meet the script’s defined continuation or reversal rules.

Adaptive Modes

Core v4.3 includes multiple operating modes:

Scalp
Day
Swing

Scalp mode is more responsive.

Day mode is balanced.

Swing mode is slower and more selective.

These modes adjust the behavior of the same underlying framework rather than acting as separate indicators.

Oscillator Companion

Core v4.3 can be used with its companion oscillator.

The oscillator is designed to provide additional momentum context. It can help users compare price signals with internal momentum conditions, such as whether momentum is expanding, fading, or moving against the signal direction.

For bullish conditions, users may look for oscillator strength above its center area or signal line.

For bearish conditions, users may look for oscillator weakness below its center area or signal line.

The oscillator is optional and should be used as supporting context, not as a standalone prediction tool.

Markets and Timeframes

The indicator can be applied to multiple markets, including:

Stocks
Crypto
Forex

Users can test different timeframes depending on their charting style. Lower timeframes may produce more frequent signals, while higher timeframes may produce fewer signals with broader context.

How to Use

1. Select the mode that fits your charting style.

Use Scalp for faster conditions, Day for balanced conditions, or Swing for slower conditions.

2. Read the current signal type.

Continuation signals describe conditions aligned with the current trend logic.

Reversal signals describe possible transition conditions.

Watch / no-trade states mean the script’s conditions are not fully aligned.

3. Compare the signal with momentum.

The companion oscillator can be used to check whether momentum supports or conflicts with the chart signal.

4. Use market context.

Signals should be reviewed alongside support and resistance, volatility, trend direction, and risk management.

Important Notes

This script is open source and provided for educational chart analysis.

It does not provide financial advice.

It does not guarantee future results.

It does not guarantee signal accuracy.

It should not be used as the only basis for trading decisions.

All signals, labels, alerts, and visual states are based on the script’s programmed conditions and should be interpreted as informational chart events.

## Source Code

````pine
//@version=6
indicator("Alpha Forge Core v4.3", shorttitle="AF4.3", overlay=true, max_labels_count=500, max_lines_count=500)

//============================
// INPUTS
//============================
groupMode    = "Mode"
groupHTF     = "Higher Timeframe"
groupVisual  = "Visuals"
groupDash    = "Dashboard"
groupAlerts  = "Alerts"
groupStruct  = "Structure"
groupTP      = "Targets"
groupSignals = "Signal Filter"

mode = input.string("Day", "Mode", options=["Scalp", "Day", "Swing"], group=groupMode)

useHTF = input.bool(true, "Use HTF Alignment", group=groupHTF)
htfTf  = input.timeframe("240", "HTF Timeframe", group=groupHTF)

showBasis      = input.bool(true, "Show Basis", group=groupVisual)
showBands      = input.bool(true, "Show Bands", group=groupVisual)
showSignals    = input.bool(true, "Show Buy/Sell Signals", group=groupVisual)
showStructure  = input.bool(true, "Show BOS / CHOCH", group=groupVisual)
showGradient   = input.bool(true, "Show Gradient Background", group=groupVisual)
tintBars       = input.bool(false, "Tint Bars", group=groupVisual)

showDashboard = input.bool(true, "Show Dashboard", group=groupDash)
dashboardPos  = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupDash)
dashboardSize = input.string("Small", "Dashboard Size", options=["Small", "Medium", "Large"], group=groupDash)

minBarsBetweenStruct = input.int(6, "Min Bars Between BOS/CHOCH", minval=1, group=groupStruct)

showTP1       = input.bool(true, "Show TP1", group=groupTP)
showTP2       = input.bool(true, "Show TP2", group=groupTP)
showTP3       = input.bool(false, "Show TP3", group=groupTP)
showTPLabels  = input.bool(true, "Show TP Labels", group=groupTP)
tpBarsForward = input.int(20, "TP Line Length (bars)", minval=3, maxval=200, group=groupTP)

signalFilter = input.string("All (A, B, C)", "Allowed Grades", options=["A Only", "A + B", "All (A, B, C)"], group=groupSignals)

stockMode = input.bool(true, "Stock Mode (Stricter Filters)")
confirmEntry = input.bool(true, "Require Confirmation Candle")
enableBuySellAlerts   = input.bool(true, "Enable Buy/Sell Alerts", group=groupAlerts)
enableStructureAlerts = input.bool(false, "Enable BOS / CHOCH Alerts", group=groupAlerts)

//============================
// MODE PRESETS
//============================
int trendLen = switch mode
    "Scalp" => 21
    "Day"   => 34
    => 55

float bandMult = switch mode
    "Scalp" => 1.00
    "Day"   => 1.25
    => 1.50

int oscSmooth = switch mode
    "Scalp" => 3
    "Day"   => 5
    => 8

int sigSmooth = switch mode
    "Scalp" => 2
    "Day"   => 4
    => 6

int pivotLen = switch mode
    "Scalp" => 2
    "Day"   => 3
    => 5

float minMom = switch mode
    "Scalp" => 0.03
    "Day"   => 0.08
    => 0.12

float structBreakAtr = switch mode
    "Scalp" => 0.05
    "Day"   => 0.10
    => 0.15

float maxStretchForEntry = switch mode
    "Scalp" => 1.10
    "Day"   => 0.95
    => 0.80

float reversalExtreme = switch mode
    "Scalp" => 1.00
    "Day"   => 1.15
    => 1.30

//============================
// COLORS
//============================
bull    = color.rgb(0, 255, 187)
bear    = color.rgb(255, 70, 70)
neutral = color.rgb(135, 135, 150)

bullBg  = color.new(bull, 93)
bearBg  = color.new(bear, 93)

//============================
// HELPERS
//============================
f_dash_pos(_p) =>
    _p == "Top Left" ? position.top_left :
     _p == "Bottom Right" ? position.bottom_right :
     _p == "Bottom Left" ? position.bottom_left :
     position.top_right

f_bias(_len, _mult) =>
    _lag = math.floor((_len - 1) / 2)
    _basis = ta.ema(close + (close - close[_lag]), _len)
    _atr = ta.atr(_len)
    _vol = ta.highest(_atr, _len * 3) * _mult
    close > _basis and _basis > _basis[1] ? 1 :
     close < _basis and _basis < _basis[1] ? -1 : 0

dashTextSize = dashboardSize == "Small" ? size.tiny : dashboardSize == "Medium" ? size.small : size.normal

//============================
// CORE TREND ENGINE
//============================
lag   = math.floor((trendLen - 1) / 2)
basis = ta.ema(close + (close - close[lag]), trendLen)

atrVal = ta.atr(trendLen)
vol    = ta.highest(atrVal, trendLen * 3) * bandMult

upper = basis + vol
lower = basis - vol

var int trend = 0
if ta.crossover(close, upper)
    trend := 1
if ta.crossunder(close, lower)
    trend := -1

trendSlopeUp   = basis > basis[1]
trendSlopeDown = basis < basis[1]

trendStrongBear = basis < basis[1] and close < basis and close < lower
trendStrongBull = basis > basis[1] and close > basis and close > upper

//============================
// OSCILLATOR-MATCHED MOMENTUM
//============================
rawOsc = vol != 0 ? (close - basis) / vol : 0.0
osc    = ta.ema(rawOsc, oscSmooth)
sig    = ta.ema(osc, sigSmooth)
hist   = osc - sig

oscBullBias    = osc > 0
oscBearBias    = osc < 0
oscBullConfirm = osc > sig and hist > hist[1]
oscBearConfirm = osc < sig and hist < hist[1]

momBull = osc > minMom and oscBullConfirm
momBear = osc < -minMom and oscBearConfirm
momText = momBull ? "Bullish" : momBear ? "Bearish" : "Neutral"

//============================
// HTF
//============================
htfBias = request.security(syminfo.tickerid, htfTf, f_bias(trendLen, bandMult), barmerge.gaps_off, barmerge.lookahead_off)
htfBull = htfBias == 1
htfBear = htfBias == -1
htfOkBull = not useHTF or htfBull or htfBias == 0
htfOkBear = not useHTF or htfBear or htfBias == 0

// soft HTF reversal filter
htfNotStrongBear = not useHTF or htfBias != -1
htfNotStrongBull = not useHTF or htfBias != 1

//============================
// STRUCTURE ENGINE
//============================
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastSwingHigh = na
var float lastSwingLow  = na
var int structureTrend = 0
var int lastStructBar = na

if not na(ph)
    lastSwingHigh := ph

if not na(pl)
    lastSwingLow := pl

barsOk = na(lastStructBar) or (bar_index - lastStructBar >= minBarsBetweenStruct)

bullBreakRaw = not na(lastSwingHigh) and close > lastSwingHigh and close[1] <= lastSwingHigh
bearBreakRaw = not na(lastSwingLow) and close < lastSwingLow and close[1] >= lastSwingLow

bullBreakStrong = bullBreakRaw and (close - lastSwingHigh) > atrVal * structBreakAtr
bearBreakStrong = bearBreakRaw and (lastSwingLow - close) > atrVal * structBreakAtr

bullBreak = bullBreakStrong and barsOk
bearBreak = bearBreakStrong and barsOk

bullBOS   = bullBreak and structureTrend >= 0
bearBOS   = bearBreak and structureTrend <= 0
bullCHOCH = bullBreak and structureTrend == -1
bearCHOCH = bearBreak and structureTrend == 1

if bullBreak
    structureTrend := 1
    lastStructBar := bar_index

if bearBreak
    structureTrend := -1
    lastStructBar := bar_index

structBull = structureTrend == 1
structBear = structureTrend == -1

//============================
// ENTRY QUALITY FILTERS
//============================
notTooStretchedLong  = rawOsc < maxStretchForEntry
notTooStretchedShort = rawOsc > -maxStretchForEntry

bullTrendOk = trend == 1 and trendSlopeUp and momBull and htfOkBull and not structBear
bearTrendOk = trend == -1 and trendSlopeDown and momBear and htfOkBear and not structBull

bullPullback = ta.crossover(close, basis) and trend == 1
bearPullback = ta.crossunder(close, basis) and trend == -1

//============================
// REVERSAL RECLAIM LOGIC
//============================
bullExtremeRecover = osc[1] < -reversalExtreme and osc > sig and hist > hist[1]
bearExtremeRecover = osc[1] > reversalExtreme and osc < sig and hist < hist[1]

bullBasisReclaim = close > basis and close[1] <= basis
bearBasisReject  = close < basis and close[1] >= basis

bullBandReclaim = close > lower and close[1] <= lower
bearBandReject  = close < upper and close[1] >= upper

watchRevLong = bullExtremeRecover and (bullBasisReclaim or bullBandReclaim) and not htfBear
watchRevShort = bearExtremeRecover and (bearBandReject or bearBasisReject) and not htfBull

//============================
// STRONG REVERSAL FILTER
//============================
bullCandleStrong = close > open and (close - open) > (high - low) * 0.4
bearCandleStrong = close < open and (open - close) > (high - low) * 0.3

bullMomentumStrong = osc > sig and hist > hist[1] and osc > osc[1]
bearMomentumStrong = osc < sig and hist < hist[1] and osc < osc[1]

//============================
// SIGNALS
//============================
buyCont  = bullTrendOk and structBull and bullPullback and oscBullBias and notTooStretchedLong
sellCont = bearTrendOk and structBear and bearPullback and oscBearBias and notTooStretchedShort

buyRev =
     stockMode
     ? (bullExtremeRecover
        and bullBasisReclaim
        and bullMomentumStrong
        and bullCandleStrong
        and htfNotStrongBear
        and not trendStrongBear
        and bullCHOCH)
     : (bullExtremeRecover
        and bullBasisReclaim
        and bullMomentumStrong
        and bullCandleStrong
        and htfNotStrongBear
        and not trendStrongBear)

sellRev =
     stockMode
     ? (bearExtremeRecover
        and bearBasisReject
        and bearMomentumStrong
        and bearCandleStrong
        and htfNotStrongBull
        and not trendStrongBull
        and bearCHOCH)
     : (bearExtremeRecover
        and bearBasisReject
        and bearMomentumStrong
        and bearCandleStrong
        and htfNotStrongBull
        and not trendStrongBull)

noTrade = trend == 0 or htfBias == 0 or momText == "Neutral"

buySignal_raw = buyCont or buyRev
sellSignal_raw = sellCont or sellRev

// CONTINUATION ADD
pullback = close < basis and close > lower
reclaim  = close > basis and close[1] < basis

contEntry = trend == 1 and structBull and reclaim and oscBullConfirm

buySignal = stockMode ? ((buySignal_raw and not noTrade and trend == 1 and structBull) or contEntry) : buySignal_raw
sellSignal = stockMode ? (sellSignal_raw and not noTrade and trend == -1 and structBear) : sellSignal_raw

finalBuy_base = confirmEntry ? (buySignal and close > close[1]) : buySignal
finalSell_base = confirmEntry ? (sellSignal and close < close[1]) : sellSignal

buyScore = 0
buyScore += trend == 1 ? 1 : 0
buyScore += htfBull ? 1 : 0
buyScore += structBull ? 1 : 0
buyScore += momBull ? 1 : 0
buyScore += oscBullConfirm ? 1 : 0

sellScore = 0
sellScore += trend == -1 ? 1 : 0
sellScore += htfBear ? 1 : 0
sellScore += structBear ? 1 : 0
sellScore += momBear ? 1 : 0
sellScore += oscBearConfirm ? 1 : 0

buyGrade = buyScore == 5 ? "A" : buyScore == 4 ? "B" : "C"
sellGrade = sellScore == 5 ? "A" : sellScore == 4 ? "B" : "C"

allowA = signalFilter == "A Only" or signalFilter == "A + B" or signalFilter == "All (A, B, C)"
allowB = signalFilter == "A + B" or signalFilter == "All (A, B, C)"
allowC = signalFilter == "All (A, B, C)"

buyAllowed = (buyGrade == "A" and allowA) or (buyGrade == "B" and allowB) or (buyGrade == "C" and allowC)
sellAllowed = (sellGrade == "A" and allowA) or (sellGrade == "B" and allowB) or (sellGrade == "C" and allowC)

//============================
// LOCK ALL SAME-DIRECTION SIGNALS
//============================
var bool buyLock = false
var bool sellLock = false

finalBuy_raw = finalBuy_base and buyAllowed
finalSell_raw = finalSell_base and sellAllowed

finalBuy = finalBuy_raw and not buyLock
finalSell = finalSell_raw and not sellLock

if finalBuy
    buyLock := true
    sellLock := false

if finalSell
    sellLock := true
    buyLock := false

if trend != 1 or not structBull
    buyLock := false

if trend != -1 or not structBear
    sellLock := false

watchRevLong := watchRevLong and not finalBuy and not finalSell
watchRevShort := watchRevShort and not finalBuy and not finalSell

watchLong  = not finalBuy and trend == 1 and structBull and oscBullConfirm and notTooStretchedLong and not htfBear
watchShort = not finalSell and trend == -1 and structBear and oscBearConfirm and notTooStretchedShort and not htfBull

decisionText =
     finalBuy ? (buyRev ? "BUY REV" : "BUY CONT") :
     finalSell ? (sellRev ? "SELL REV" : "SELL CONT") :
     watchRevLong ? "WATCH REV LONG" :
     watchRevShort ? "WATCH REV SHORT" :
     watchLong ? "WATCH LONG" :
     watchShort ? "WATCH SHORT" :
     trend == 1 and htfBear and useHTF ? "WAIT" :
     trend == -1 and htfBull and useHTF ? "WAIT" :
     "NO TRADE"

//============================
// TARGETS
//============================
tp1Long  = close + vol * 0.5
tp2Long  = close + vol * 1.0
tp3Long  = close + vol * 1.5

tp1Short = close - vol * 0.5
tp2Short = close - vol * 1.0
tp3Short = close - vol * 1.5

//============================
// VISUALS
//============================
basisColor = trend == 1 ? bull : trend == -1 ? bear : neutral

plot(showBasis ? basis : na, "Basis", color=basisColor, linewidth=2)
plot(showBands and trend == -1 ? upper : na, "Upper Band", color=color.new(bear, 25), linewidth=1)
plot(showBands and trend == 1 ? lower : na, "Lower Band", color=color.new(bull, 25), linewidth=1)

bgcolor(showGradient ? (trend == 1 ? bullBg : trend == -1 ? bearBg : na) : na)
barcolor(tintBars ? (trend == 1 ? color.new(bull, 75) : trend == -1 ? color.new(bear, 75) : na) : na)

// Signals
buyColor = buyGrade == "A" ? color.lime : buyGrade == "B" ? bull : color.new(bull, 60)
sellColor = sellGrade == "A" ? color.red : sellGrade == "B" ? bear : color.new(bear, 60)

if showSignals and finalBuy and not buyRev
    label.new(
        bar_index,
        low,
        "BUY " + buyGrade,
        style=label.style_label_up,
        color=buyColor,
        textcolor=color.black,
        size=size.small
    )

if showSignals and finalSell and not sellRev
    label.new(
        bar_index,
        high,
        "SELL " + sellGrade,
        style=label.style_label_down,
        color=sellColor,
        textcolor=color.white,
        size=size.small
    )

plotshape(showSignals and finalBuy and buyRev ? low : na, title="Buy Reversal", style=shape.triangleup, location=location.belowbar, color=color.new(bull, 0), text="REV", textcolor=color.black, size=size.small)
plotshape(showSignals and finalSell and sellRev ? high : na, title="Sell Reversal", style=shape.triangledown, location=location.abovebar, color=color.new(bear, 0), text="REV", textcolor=color.white, size=size.small)

plotshape(showSignals and watchLong ? low : na, title="Watch Long", style=shape.circle, location=location.belowbar, color=color.new(bull, 15), size=size.tiny)
plotshape(showSignals and watchShort ? high : na, title="Watch Short", style=shape.circle, location=location.abovebar, color=color.new(bear, 15), size=size.tiny)

plotshape(showSignals and watchRevLong ? low : na, title="Watch Rev Long", style=shape.diamond, location=location.belowbar, color=color.new(bull, 0), size=size.tiny)
plotshape(showSignals and watchRevShort ? high : na, title="Watch Rev Short", style=shape.diamond, location=location.abovebar, color=color.new(bear, 0), size=size.tiny)

// Structure
plotshape(showStructure and bullBOS ? high : na, title="Bull BOS", style=shape.circle, location=location.abovebar, color=color.new(bull, 5), size=size.tiny)
plotshape(showStructure and bearBOS ? low : na, title="Bear BOS", style=shape.circle, location=location.belowbar, color=color.new(bear, 5), size=size.tiny)

plotshape(showStructure and bullCHOCH ? high : na, title="Bull CHOCH", style=shape.diamond, location=location.abovebar, color=color.new(bull, 0), size=size.tiny)
plotshape(showStructure and bearCHOCH ? low : na, title="Bear CHOCH", style=shape.diamond, location=location.belowbar, color=color.new(bear, 0), size=size.tiny)

//============================
// ON-CHART TP LINES (FORWARD FIX)
//============================
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var label tp1Lab = na
var label tp2Lab = na
var label tp3Lab = na

var float activeTP1 = na
var float activeTP2 = na
var float activeTP3 = na
var bool activeLong = false
var int activeSignalBar = na

if finalBuy
    activeLong := true
    activeSignalBar := bar_index
    activeTP1 := tp1Long
    activeTP2 := tp2Long
    activeTP3 := tp3Long

if finalSell
    activeLong := false
    activeSignalBar := bar_index
    activeTP1 := tp1Short
    activeTP2 := tp2Short
    activeTP3 := tp3Short

if finalBuy or finalSell
    if not na(tp1Line)
        line.delete(tp1Line)
        tp1Line := na
    if not na(tp2Line)
        line.delete(tp2Line)
        tp2Line := na
    if not na(tp3Line)
        line.delete(tp3Line)
        tp3Line := na

    if not na(tp1Lab)
        label.delete(tp1Lab)
        tp1Lab := na
    if not na(tp2Lab)
        label.delete(tp2Lab)
        tp2Lab := na
    if not na(tp3Lab)
        label.delete(tp3Lab)
        tp3Lab := na

if finalBuy or finalSell
    tpColor1 = activeLong ? color.new(bull, 55) : color.new(bear, 55)
    tpColor2 = activeLong ? color.new(bull, 72) : color.new(bear, 72)
    tpColor3 = activeLong ? color.new(bull, 82) : color.new(bear, 82)

    tpTextColor = activeLong ? color.black : color.white
    tpLabel1Bg = activeLong ? color.new(bull, 15) : color.new(bear, 15)
    tpLabel2Bg = activeLong ? color.new(bull, 25) : color.new(bear, 25)
    tpLabel3Bg = activeLong ? color.new(bull, 35) : color.new(bear, 35)

    if showTP1
        tp1Line := line.new(activeSignalBar, activeTP1, bar_index + tpBarsForward, activeTP1, xloc=xloc.bar_index, extend=extend.none, color=tpColor1, width=1, style=line.style_dashed)
        if showTPLabels
            tp1Lab := label.new(bar_index + tpBarsForward, activeTP1, "TP1", xloc=xloc.bar_index, style=label.style_label_left, textcolor=tpTextColor, color=tpLabel1Bg, size=size.tiny)

    if showTP2
        tp2Line := line.new(activeSignalBar, activeTP2, bar_index + tpBarsForward, activeTP2, xloc=xloc.bar_index, extend=extend.none, color=tpColor2, width=1, style=line.style_dashed)
        if showTPLabels
            tp2Lab := label.new(bar_index + tpBarsForward, activeTP2, "TP2", xloc=xloc.bar_index, style=label.style_label_left, textcolor=tpTextColor, color=tpLabel2Bg, size=size.tiny)

    if showTP3
        tp3Line := line.new(activeSignalBar, activeTP3, bar_index + tpBarsForward, activeTP3, xloc=xloc.bar_index, extend=extend.none, color=tpColor3, width=1, style=line.style_dashed)
        if showTPLabels
            tp3Lab := label.new(bar_index + tpBarsForward, activeTP3, "TP3", xloc=xloc.bar_index, style=label.style_label_left, textcolor=tpTextColor, color=tpLabel3Bg, size=size.tiny)

if not na(activeSignalBar)
    if showTP1 and not na(tp1Line)
        line.set_xy1(tp1Line, activeSignalBar, activeTP1)
        line.set_xy2(tp1Line, bar_index + tpBarsForward, activeTP1)
        if showTPLabels and not na(tp1Lab)
            label.set_x(tp1Lab, bar_index + tpBarsForward)
            label.set_y(tp1Lab, activeTP1)

    if showTP2 and not na(tp2Line)
        line.set_xy1(tp2Line, activeSignalBar, activeTP2)
        line.set_xy2(tp2Line, bar_index + tpBarsForward, activeTP2)
        if showTPLabels and not na(tp2Lab)
            label.set_x(tp2Lab, bar_index + tpBarsForward)
            label.set_y(tp2Lab, activeTP2)

    if showTP3 and not na(tp3Line)
        line.set_xy1(tp3Line, activeSignalBar, activeTP3)
        line.set_xy2(tp3Line, bar_index + tpBarsForward, activeTP3)
        if showTPLabels and not na(tp3Lab)
            label.set_x(tp3Lab, bar_index + tpBarsForward)
            label.set_y(tp3Lab, activeTP3)

//============================
// DASHBOARD
//============================
if showDashboard
    var table dash = table.new(f_dash_pos(dashboardPos), 2, 8, bgcolor=color.new(chart.bg_color, 10), border_width=1, border_color=color.new(chart.fg_color, 80), frame_color=color.new(chart.fg_color, 80), frame_width=1)
    if barstate.islast
        table.cell(dash, 0, 0, "Metric", text_color=chart.fg_color, text_halign=text.align_center, bgcolor=color.new(neutral, 88), text_size=dashTextSize)
        table.cell(dash, 1, 0, "State", text_color=chart.fg_color, text_halign=text.align_center, bgcolor=color.new(neutral, 88), text_size=dashTextSize)

        table.cell(dash, 0, 1, "Mode", text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)
        table.cell(dash, 1, 1, mode, text_color=chart.fg_color, text_halign=text.align_center, bgcolor=color.new(neutral, 90), text_size=dashTextSize)

        table.cell(dash, 0, 2, "Grades", text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)
        table.cell(dash, 1, 2, signalFilter, text_color=chart.fg_color, text_halign=text.align_center, bgcolor=color.new(neutral, 90), text_size=dashTextSize)

        trendText = trend == 1 ? "Bullish" : trend == -1 ? "Bearish" : "Neutral"
        trendBg = trend == 1 ? color.new(bull, 76) : trend == -1 ? color.new(bear, 76) : color.new(neutral, 88)
        table.cell(dash, 0, 3, "Trend", text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)
        table.cell(dash, 1, 3, trendText, text_color=chart.fg_color, text_halign=text.align_center, bgcolor=trendBg, text_size=dashTextSize)

        momBg = momBull ? color.new(bull, 76) : momBear ? color.new(bear, 76) : color.new(neutral, 88)
        table.cell(dash, 0, 4, "Momentum", text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)
        table.cell(dash, 1, 4, momText, text_color=chart.fg_color, text_halign=text.align_center, bgcolor=momBg, text_size=dashTextSize)

        htfText = htfBull ? "Bullish" : htfBear ? "Bearish" : "Neutral"
        htfBg = htfBull ? color.new(bull, 76) : htfBear ? color.new(bear, 76) : color.new(neutral, 88)
        table.cell(dash, 0, 5, "HTF", text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)
        table.cell(dash, 1, 5, htfText, text_color=chart.fg_color, text_halign=text.align_center, bgcolor=htfBg, text_size=dashTextSize)

        structText = bullCHOCH ? "Bull CHOCH" : bearCHOCH ? "Bear CHOCH" : bullBOS ? "Bull BOS" : bearBOS ? "Bear BOS" : structBull ? "Bull Struct" : structBear ? "Bear Struct" : "Neutral"
        structBg = structBull ? color.new(bull, 76) : structBear ? color.new(bear, 76) : color.new(neutral, 88)
        table.cell(dash, 0, 6, "Structure", text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)
        table.cell(dash, 1, 6, structText, text_color=chart.fg_color, text_halign=text.align_center, bgcolor=structBg, text_size=dashTextSize)

        decisionBg =
             finalBuy ? color.new(bull, 62) :
             finalSell ? color.new(bear, 62) :
             watchRevLong ? color.new(bull, 78) :
             watchRevShort ? color.new(bear, 78) :
             watchLong ? color.new(bull, 84) :
             watchShort ? color.new(bear, 84) :
             color.new(neutral, 90)
        table.cell(dash, 0, 7, "Decision", text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)
        table.cell(dash, 1, 7, decisionText, text_color=chart.fg_color, text_halign=text.align_center, bgcolor=decisionBg, text_size=dashTextSize)

//============================
// ALERTS
//============================
alertcondition(enableBuySellAlerts and finalBuy, "Alpha Forge Buy", "Alpha Forge BUY on {{ticker}} {{interval}}")
alertcondition(enableBuySellAlerts and finalSell, "Alpha Forge Sell", "Alpha Forge SELL on {{ticker}} {{interval}}")

alertcondition(enableStructureAlerts and bullBOS, "Alpha Forge Bullish BOS", "Alpha Forge Bullish BOS on {{ticker}} {{interval}}")
alertcondition(enableStructureAlerts and bearBOS, "Alpha Forge Bearish BOS", "Alpha Forge Bearish BOS on {{ticker}} {{interval}}")
alertcondition(enableStructureAlerts and bullCHOCH, "Alpha Forge Bullish CHOCH", "Alpha Forge Bullish CHOCH on {{ticker}} {{interval}}")
alertcondition(enableStructureAlerts and bearCHOCH, "Alpha Forge Bearish CHOCH", "Alpha Forge Bearish CHOCH on {{ticker}} {{interval}}")
````

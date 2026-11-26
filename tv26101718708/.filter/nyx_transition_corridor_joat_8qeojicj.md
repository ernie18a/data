# Nyx Transition Corridor [JOAT]

- url: https://www.tradingview.com/script/8qeoJIcJ-Nyx-Transition-Corridor-JOAT/
- type: indicator
- pine_id: PUB;ee2af97768264bb480d6a44b78ee98bb
- version: 1.0

## Description

[b]Nyx Transition Corridor [JOAT][/b]

[b]Introduction[/b]

Nyx Transition Corridor is an open-source probabilistic regime corridor. It estimates whether the current bullish, bearish, or neutral state has recently tended to persist, then draws adaptive volatility corridors around price. The indicator is built for context, probability, and controlled visualization rather than aggressive signal clutter.

[image]https://www.tradingview.com/x/aHRb93Q8/[/image]

[b]Core Concepts[/b]

[b]1. Regime State[/b]

The script classifies each bar as bullish, bearish, or neutral using EMA alignment, adaptive basis location, and return behavior.

[b]2. Rolling Transition Model[/b]

Recent state transitions are counted to estimate continuation probability for the current state.

[pine]
pBullBull = math.sum(fromBull * toBull, transitionLen) / math.sum(fromBull, transitionLen)
[/pine]

[b]3. Adaptive Basis[/b]

The basis reacts faster when price movement is efficient and slower when the market is choppy.

[b]4. Probability Corridor[/b]

ATR, volatility rank, and continuation probability determine the corridor width. Outer rails identify stretched conditions.

[b]5. Compact Execution Rails[/b]

Optional small rails mark educational entry, stop, and targets when a probability reclaim or continuation event occurs.

[b]Features[/b]

[list]
[*][b]Three-state regime model:[/b] Bull, bear, and neutral states
[*][b]Transition probability:[/b] Rolling persistence estimate for current state
[*][b]Adaptive basis:[/b] Efficiency-weighted smoothing
[*][b]Volatility-ranked corridor:[/b] Bands expand and contract with market stress
[*][b]Confirmed HTF filter:[/b] Optional higher-timeframe EMA uses confirmed previous HTF data
[*][b]Compact trade rails:[/b] Smaller educational rails to reduce chart obstruction
[*][b]Dashboard:[/b] Shows probabilities, spread, efficiency, volatility rank, and HTF state
[/list]

[b]Input Parameters[/b]

[list]
[*]Adaptive basis length controls centerline memory
[*]Transition memory controls probability stability
[*]Continuation threshold controls signal selectivity
[*]Rail settings control optional educational projections
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the regime[/b]

The dashboard shows whether the model is bullish, bearish, or neutral.

[b]Step 2: Compare probabilities[/b]

Large spreads between bull and bear odds indicate clearer directional context.

[b]Step 3: Use the corridor[/b]

The corridor shows where price is trading relative to the adaptive probability field.

[b]Indicator Limitations[/b]

[list]
[*]Transition probabilities are historical estimates, not forecasts
[*]Neutral markets can persist even when price briefly crosses the basis
[*]The optional rails are visual projections and not trading advice
[/list]

[b]Originality Statement[/b]

Nyx Transition Corridor combines a state-transition model, efficiency-adjusted basis, volatility-ranked width, confirmed HTF filtering, and compact execution visuals. Its purpose is to map probabilistic state context, not to duplicate a standard moving-average band.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Probability estimates are based on historical state transitions and do not predict future behavior.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Nyx Transition Corridor [JOAT]", shorttitle="NTC [JOAT]", overlay=true, max_lines_count=260, max_labels_count=220, max_boxes_count=120, max_bars_back=2000)

// Nyx Transition Corridor [JOAT]
// A close-confirmed probabilistic regime corridor. It estimates state transition
// persistence from recent bullish, bearish, and neutral regimes, then projects a
// continuation/reversion corridor around an adaptive volatility basis.

//==============================================================================
// Inputs
//==============================================================================
groupCore = "Core Engine"
basisLen = input.int(34, "Adaptive basis length", minval=5, maxval=200, group=groupCore)
fastLen = input.int(21, "Fast trend length", minval=2, maxval=100, group=groupCore)
slowLen = input.int(55, "Slow trend length", minval=5, maxval=240, group=groupCore)
atrLen = input.int(21, "Volatility length", minval=2, maxval=100, group=groupCore)
rankLen = input.int(120, "Volatility rank window", minval=20, maxval=500, group=groupCore)
transitionLen = input.int(80, "Transition memory", minval=20, maxval=300, group=groupCore)
erLen = input.int(20, "Efficiency window", minval=5, maxval=100, group=groupCore)

groupSignal = "Signal Logic"
probThreshold = input.float(62.0, "Continuation probability threshold", minval=50.0, maxval=90.0, step=0.5, group=groupSignal)
minSpread = input.float(9.0, "Minimum probability spread", minval=0.0, maxval=40.0, step=0.5, group=groupSignal)
confirmSignals = input.bool(true, "Confirm signals on bar close", group=groupSignal)
useHtfFilter = input.bool(true, "Use confirmed HTF filter", group=groupSignal)
htfFrame = input.timeframe("240", "Confirmed HTF", group=groupSignal)
htfLen = input.int(55, "HTF EMA length", minval=5, maxval=200, group=groupSignal)

groupRisk = "Execution Rails"
showRails = input.bool(true, "Show execution rails", group=groupRisk)
riskAtr = input.float(0.85, "Stop ATR multiplier", minval=0.2, maxval=8.0, step=0.1, group=groupRisk)
rr1 = input.float(0.8, "TP1 R", minval=0.2, maxval=10.0, step=0.1, group=groupRisk)
rr2 = input.float(1.35, "TP2 R", minval=0.2, maxval=12.0, step=0.1, group=groupRisk)
rr3 = input.float(2.05, "TP3 R", minval=0.2, maxval=20.0, step=0.1, group=groupRisk)
railBars = input.int(18, "Rail projection bars", minval=5, maxval=300, group=groupRisk)

groupVisual = "Visual System"
showCloud = input.bool(true, "Show probability corridor", group=groupVisual)
showStateBoxes = input.bool(true, "Show state transition boxes", group=groupVisual)
showDashboard = input.bool(true, "Show dashboard", group=groupVisual)
paintCandles = input.bool(true, "Color candles by state", group=groupVisual)

//==============================================================================
// Palette
//==============================================================================
color joatCyan = color.rgb(8, 239, 251)
color joatMagenta = color.rgb(217, 2, 255)
color joatGold = color.rgb(255, 200, 0)
color joatTeal = color.rgb(38, 166, 154)
color joatCoral = color.rgb(239, 83, 80)
color joatViolet = color.rgb(125, 92, 255)
color joatInk = color.rgb(8, 10, 18)
color joatPanel = color.rgb(15, 18, 28)
color joatGrid = color.rgb(42, 48, 68)
color joatText = color.rgb(226, 232, 240)
color joatMute = color.rgb(130, 140, 160)

//==============================================================================
// Utility
//==============================================================================
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_safeDiv(float num, float den, float fallback) =>
    math.abs(den) > 0.0000001 ? num / den : fallback

f_probabilityColor(float value) =>
    color.from_gradient(value, 0.0, 100.0, joatCoral, joatCyan)

f_stateText(int state) =>
    state == 1 ? "BULL" : state == -1 ? "BEAR" : "NEUTRAL"

f_confirmedHtfEma(string tf, int len) =>
    request.security(syminfo.tickerid, tf, ta.ema(close, len)[1], lookahead=barmerge.lookahead_on)

//==============================================================================
// Core State Engine
//==============================================================================
atr = ta.atr(atrLen)
fast = ta.ema(close, fastLen)
slow = ta.ema(close, slowLen)
basisRaw = ta.ema(close, basisLen)
returnNow = close[1] != 0.0 ? math.log(close / close[1]) : 0.0
returnMean = ta.sma(returnNow, basisLen)
returnDev = ta.stdev(returnNow, basisLen)
zReturn = f_safeDiv(returnNow - returnMean, returnDev, 0.0)

absChange = math.abs(ta.change(close))
travel = ta.sma(absChange, erLen) * erLen
direction = math.abs(close - close[erLen])
efficiency = f_clamp(f_safeDiv(direction, travel, 0.0), 0.0, 1.0)

atrPct = close != 0.0 ? atr / close * 100.0 : 0.0
volRank = ta.percentrank(atrPct, rankLen)
volRankSafe = na(volRank) ? 50.0 : volRank

trendSpread = f_safeDiv(fast - slow, atr, 0.0)
bullStateRaw = fast > slow and close > basisRaw and zReturn > -0.25
bearStateRaw = fast < slow and close < basisRaw and zReturn < 0.25
state = bullStateRaw ? 1 : bearStateRaw ? -1 : 0
prevState = nz(state[1], 0)

// Rolling transition matrix. Counts are smoothed with SMA so probabilities stay stable.
fromBull = prevState == 1 ? 1.0 : 0.0
fromBear = prevState == -1 ? 1.0 : 0.0
fromNeutral = prevState == 0 ? 1.0 : 0.0
toBull = state == 1 ? 1.0 : 0.0
toBear = state == -1 ? 1.0 : 0.0
toNeutral = state == 0 ? 1.0 : 0.0

pBullBull = f_safeDiv(ta.sma(fromBull * toBull, transitionLen), ta.sma(fromBull, transitionLen), 0.50)
pBullBear = f_safeDiv(ta.sma(fromBull * toBear, transitionLen), ta.sma(fromBull, transitionLen), 0.25)
pBullNeutral = f_safeDiv(ta.sma(fromBull * toNeutral, transitionLen), ta.sma(fromBull, transitionLen), 0.25)
pBearBear = f_safeDiv(ta.sma(fromBear * toBear, transitionLen), ta.sma(fromBear, transitionLen), 0.50)
pBearBull = f_safeDiv(ta.sma(fromBear * toBull, transitionLen), ta.sma(fromBear, transitionLen), 0.25)
pBearNeutral = f_safeDiv(ta.sma(fromBear * toNeutral, transitionLen), ta.sma(fromBear, transitionLen), 0.25)
pNeutralBull = f_safeDiv(ta.sma(fromNeutral * toBull, transitionLen), ta.sma(fromNeutral, transitionLen), 0.34)
pNeutralBear = f_safeDiv(ta.sma(fromNeutral * toBear, transitionLen), ta.sma(fromNeutral, transitionLen), 0.33)
pNeutralNeutral = f_safeDiv(ta.sma(fromNeutral * toNeutral, transitionLen), ta.sma(fromNeutral, transitionLen), 0.33)

bullProbability = state == 1 ? pBullBull : state == -1 ? pBearBull : pNeutralBull
bearProbability = state == -1 ? pBearBear : state == 1 ? pBullBear : pNeutralBear
neutralProbability = state == 1 ? pBullNeutral : state == -1 ? pBearNeutral : pNeutralNeutral
continuationProbability = state == 1 ? bullProbability : state == -1 ? bearProbability : neutralProbability
bullPct = f_clamp(bullProbability * 100.0, 0.0, 100.0)
bearPct = f_clamp(bearProbability * 100.0, 0.0, 100.0)
neutralPct = f_clamp(neutralProbability * 100.0, 0.0, 100.0)
contPct = f_clamp(continuationProbability * 100.0, 0.0, 100.0)
probSpread = math.abs(bullPct - bearPct)

// Adaptive basis leans toward price when the market is efficient and slows in chop.
adaptiveAlpha = f_clamp(0.08 + efficiency * 0.32, 0.05, 0.45)
var float adaptiveBasis = na
adaptiveBasis := na(adaptiveBasis[1]) ? basisRaw : adaptiveBasis[1] + adaptiveAlpha * (close - adaptiveBasis[1])

widthBase = atr * (1.05 + volRankSafe / 100.0)
stateBoost = state == 0 ? 1.28 : 0.92
probBoost = 1.0 + math.abs(contPct - 50.0) / 140.0
corridorWidth = widthBase * stateBoost * probBoost
upperOne = adaptiveBasis + corridorWidth
lowerOne = adaptiveBasis - corridorWidth
upperTwo = adaptiveBasis + corridorWidth * 1.75
lowerTwo = adaptiveBasis - corridorWidth * 1.75

htfBasis = f_confirmedHtfEma(htfFrame, htfLen)
htfBull = close > htfBasis
htfBear = close < htfBasis
htfPassLong = not useHtfFilter or htfBull
htfPassShort = not useHtfFilter or htfBear

canConfirm = not confirmSignals or barstate.isconfirmed
longContext = state == 1 and bullPct >= probThreshold and probSpread >= minSpread and htfPassLong
shortContext = state == -1 and bearPct >= probThreshold and probSpread >= minSpread and htfPassShort
longSignal = canConfirm and longContext and ta.crossover(close, adaptiveBasis)
shortSignal = canConfirm and shortContext and ta.crossunder(close, adaptiveBasis)
longContinuation = canConfirm and longContext and close > upperOne and close[1] <= upperOne[1]
shortContinuation = canConfirm and shortContext and close < lowerOne and close[1] >= lowerOne[1]
exitLong = canConfirm and (state != 1 or close < lowerOne or bearPct > bullPct + minSpread)
exitShort = canConfirm and (state != -1 or close > upperOne or bullPct > bearPct + minSpread)

//==============================================================================
// Visual Corridor
//==============================================================================
stateColor = state == 1 ? f_probabilityColor(bullPct) : state == -1 ? color.from_gradient(bearPct, 0.0, 100.0, joatTeal, joatMagenta) : joatGold
cloudColor = color.new(stateColor, state == 0 ? 88 : 82)
outerColor = color.new(stateColor, 93)

pBasis = plot(adaptiveBasis, "NTC adaptive basis", color=color.new(stateColor, 0), linewidth=2)
pUpperOne = plot(showCloud ? upperOne : na, "NTC upper probability rail", color=color.new(stateColor, 25), linewidth=1)
pLowerOne = plot(showCloud ? lowerOne : na, "NTC lower probability rail", color=color.new(stateColor, 25), linewidth=1)
pUpperTwo = plot(showCloud ? upperTwo : na, "NTC upper exhaustion rail", color=color.new(stateColor, 65), linewidth=1)
pLowerTwo = plot(showCloud ? lowerTwo : na, "NTC lower exhaustion rail", color=color.new(stateColor, 65), linewidth=1)
fill(pUpperOne, pLowerOne, color=cloudColor, title="NTC probability body")
fill(pUpperTwo, pUpperOne, color=outerColor, title="NTC upper exhaustion field")
fill(pLowerOne, pLowerTwo, color=outerColor, title="NTC lower exhaustion field")

plot(htfBasis, "NTC confirmed HTF basis", color=color.new(joatViolet, useHtfFilter ? 25 : 100), linewidth=1)
barcolor(paintCandles ? color.new(stateColor, state == 0 ? 35 : 12) : na)

//==============================================================================
// State Transition Boxes
//==============================================================================
var box stateBox = na
stateShift = state != prevState and barstate.isconfirmed
if showStateBoxes and stateShift
    if not na(stateBox)
        box.delete(stateBox)
    boxColor = state == 1 ? color.new(joatCyan, 84) : state == -1 ? color.new(joatMagenta, 84) : color.new(joatGold, 88)
    stateBox := box.new(bar_index, high + atr * 0.35, bar_index + 12, low - atr * 0.35, bgcolor=boxColor, border_color=color.new(stateColor, 38), text=f_stateText(state), text_color=joatText, text_size=size.tiny)
if not na(stateBox)
    box.set_right(stateBox, math.min(bar_index + 12, box.get_left(stateBox) + 36))

//==============================================================================
// Execution Rails
//==============================================================================
var line entryLine = na
var line stopLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var linefill riskFill = na
var linefill rewardFill = na
var label entryLabel = na
var label stopLabel = na
var label tp1Label = na
var label tp2Label = na
var label tp3Label = na

newPlan = showRails and (longSignal or shortSignal or longContinuation or shortContinuation)
if newPlan
    if not na(entryLine)
        line.delete(entryLine)
    if not na(stopLine)
        line.delete(stopLine)
    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)
    if not na(tp3Line)
        line.delete(tp3Line)
    if not na(riskFill)
        linefill.delete(riskFill)
    if not na(rewardFill)
        linefill.delete(rewardFill)
    if not na(entryLabel)
        label.delete(entryLabel)
    if not na(stopLabel)
        label.delete(stopLabel)
    if not na(tp1Label)
        label.delete(tp1Label)
    if not na(tp2Label)
        label.delete(tp2Label)
    if not na(tp3Label)
        label.delete(tp3Label)

    planDir = (longSignal or longContinuation) ? 1 : -1
    entry = close
    stop = planDir == 1 ? close - atr * riskAtr : close + atr * riskAtr
    risk = math.abs(entry - stop)
    tp1 = planDir == 1 ? entry + risk * rr1 : entry - risk * rr1
    tp2 = planDir == 1 ? entry + risk * rr2 : entry - risk * rr2
    tp3 = planDir == 1 ? entry + risk * rr3 : entry - risk * rr3
    x2 = bar_index + railBars
    railColor = planDir == 1 ? joatCyan : joatMagenta
    entryLine := line.new(bar_index, entry, x2, entry, color=color.new(joatText, 8), width=1)
    stopLine := line.new(bar_index, stop, x2, stop, color=color.new(joatCoral, 5), width=1)
    tp1Line := line.new(bar_index, tp1, x2, tp1, color=color.new(joatGold, 6), width=1)
    tp2Line := line.new(bar_index, tp2, x2, tp2, color=color.new(railColor, 8), width=1)
    tp3Line := line.new(bar_index, tp3, x2, tp3, color=color.new(railColor, 18), width=1)
    riskFill := linefill.new(entryLine, stopLine, color.new(joatCoral, 92))
    rewardFill := linefill.new(entryLine, tp3Line, color.new(railColor, 94))
    entryLabel := label.new(x2, entry, "E", style=label.style_label_left, textcolor=joatText, color=color.new(joatPanel, 12), size=size.tiny)
    stopLabel := label.new(x2, stop, "S", style=label.style_label_left, textcolor=joatText, color=color.new(joatCoral, 20), size=size.tiny)
    tp1Label := label.new(x2, tp1, "1", style=label.style_label_left, textcolor=joatInk, color=color.new(joatGold, 8), size=size.tiny)
    tp2Label := label.new(x2, tp2, "2", style=label.style_label_left, textcolor=joatInk, color=color.new(railColor, 12), size=size.tiny)
    tp3Label := label.new(x2, tp3, "3", style=label.style_label_left, textcolor=joatInk, color=color.new(railColor, 18), size=size.tiny)

if showRails and not na(entryLine)
    nextX = bar_index + railBars
    line.set_x2(entryLine, nextX)
    line.set_x2(stopLine, nextX)
    line.set_x2(tp1Line, nextX)
    line.set_x2(tp2Line, nextX)
    line.set_x2(tp3Line, nextX)
    label.set_x(entryLabel, nextX)
    label.set_x(stopLabel, nextX)
    label.set_x(tp1Label, nextX)
    label.set_x(tp2Label, nextX)
    label.set_x(tp3Label, nextX)

plotshape(longSignal, title="NTC confirmed long state", style=shape.square, location=location.belowbar, color=color.new(joatCyan, 0), size=size.tiny, text="NTC", textcolor=joatInk)
plotshape(shortSignal, title="NTC confirmed short state", style=shape.square, location=location.abovebar, color=color.new(joatMagenta, 0), size=size.tiny, text="NTC", textcolor=joatText)

//==============================================================================
// Dashboard
//==============================================================================
var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(joatPanel, 4), border_color=color.new(joatGrid, 35), border_width=1)
if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "NTC [JOAT]", text_color=joatText, bgcolor=color.new(stateColor, 72), text_size=size.small)
    table.cell(dash, 1, 0, f_stateText(state), text_color=joatText, bgcolor=color.new(stateColor, 72), text_size=size.small)
    table.cell(dash, 0, 1, "Bull odds", text_color=joatMute, text_size=size.tiny)
    table.cell(dash, 1, 1, str.tostring(bullPct, "#.0") + "%", text_color=f_probabilityColor(bullPct), text_size=size.tiny)
    table.cell(dash, 0, 2, "Bear odds", text_color=joatMute, text_size=size.tiny)
    table.cell(dash, 1, 2, str.tostring(bearPct, "#.0") + "%", text_color=color.from_gradient(bearPct, 0.0, 100.0, joatTeal, joatMagenta), text_size=size.tiny)
    table.cell(dash, 0, 3, "Neutral", text_color=joatMute, text_size=size.tiny)
    table.cell(dash, 1, 3, str.tostring(neutralPct, "#.0") + "%", text_color=joatGold, text_size=size.tiny)
    table.cell(dash, 0, 4, "Spread", text_color=joatMute, text_size=size.tiny)
    table.cell(dash, 1, 4, str.tostring(probSpread, "#.0"), text_color=probSpread >= minSpread ? joatCyan : joatGold, text_size=size.tiny)
    table.cell(dash, 0, 5, "Efficiency", text_color=joatMute, text_size=size.tiny)
    table.cell(dash, 1, 5, str.tostring(efficiency * 100.0, "#.0") + "%", text_color=color.from_gradient(efficiency * 100.0, 0.0, 100.0, joatCoral, joatCyan), text_size=size.tiny)
    table.cell(dash, 0, 6, "Vol rank", text_color=joatMute, text_size=size.tiny)
    table.cell(dash, 1, 6, str.tostring(volRankSafe, "#.0") + "%", text_color=color.from_gradient(volRankSafe, 0.0, 100.0, joatTeal, joatMagenta), text_size=size.tiny)
    table.cell(dash, 0, 7, "HTF", text_color=joatMute, text_size=size.tiny)
    table.cell(dash, 1, 7, htfBull ? "BULL" : htfBear ? "BEAR" : "FLAT", text_color=htfBull ? joatCyan : htfBear ? joatMagenta : joatGold, text_size=size.tiny)

//==============================================================================
// Alerts
//==============================================================================
alertcondition(longSignal, "NTC Long Corridor Reclaim [JOAT]", "Nyx Transition Corridor [JOAT]: close-confirmed bullish probability reclaim.")
alertcondition(shortSignal, "NTC Short Corridor Reject [JOAT]", "Nyx Transition Corridor [JOAT]: close-confirmed bearish probability rejection.")
alertcondition(longContinuation, "NTC Bull Continuation [JOAT]", "Nyx Transition Corridor [JOAT]: bullish continuation probability expanded.")
alertcondition(shortContinuation, "NTC Bear Continuation [JOAT]", "Nyx Transition Corridor [JOAT]: bearish continuation probability expanded.")
alertcondition(exitLong, "NTC Long Risk-Off [JOAT]", "Nyx Transition Corridor [JOAT]: bullish regime risk-off.")
alertcondition(exitShort, "NTC Short Risk-Off [JOAT]", "Nyx Transition Corridor [JOAT]: bearish regime risk-off.")
````

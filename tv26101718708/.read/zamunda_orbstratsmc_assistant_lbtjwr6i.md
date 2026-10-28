# Zamunda ORB/Strat/SMC Assistant

- url: https://www.tradingview.com/script/LbtJwR6i-Zamunda-ORB-Strat-SMC-Assistant/
- type: indicator
- pine_id: PUB;acb7a389caba4eb8b43c31f221e5bb72
- version: 1.0

## Description

EMA's, Vwap, Gaps, fractal market structure and smart money concepts

## Source Code

````pine
//@version=6
indicator("Charlie ORB/Strat/SMC Assistant", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ───── Inputs
showEMAs      = input.bool(true, "Show 9/21 EMA")
showVWAP      = input.bool(true, "Show VWAP")
showStrat     = input.bool(true, "Show Strat 1 and 3 Candles")
showGaps      = input.bool(true, "Show Regular Gaps")
showFVG       = input.bool(true, "Show Fair Value Gaps")
showFractals  = input.bool(true, "Show Fractal Market Structure")
showSMC       = input.bool(true, "Show SMC BOS/CHOCH")
showOB        = input.bool(true, "Show Order Blocks")

pivotLen      = input.int(3, "Fractal Pivot Length", minval=1)
boxLookback   = input.int(50, "Order Block Search Lookback", minval=5)

// ───── EMAs + VWAP
ema9  = ta.ema(close, 9)
ema21 = ta.ema(close, 21)
vwap  = ta.vwap(hlc3)

plot(showEMAs ? ema9 : na, "9 EMA", color=color.yellow, linewidth=2)
plot(showEMAs ? ema21 : na, "21 EMA", color=color.orange, linewidth=2)
plot(showVWAP ? vwap : na, "VWAP", color=color.white, linewidth=2)

// ───── Strat Candles: 1 = inside, 3 = outside
insideBar  = high < high[1] and low > low[1]
outsideBar = high > high[1] and low < low[1]

if showStrat and insideBar
    label.new(bar_index, high, "1", style=label.style_label_down, color=color.gray, textcolor=color.white, size=size.small)

if showStrat and outsideBar
    label.new(bar_index, high, "3", style=label.style_label_down, color=color.purple, textcolor=color.white, size=size.small)

// ───── Regular Gaps
gapUp   = low > high[1]
gapDown = high < low[1]

if showGaps and gapUp
    box.new(bar_index - 1, low, bar_index, high[1], bgcolor=color.new(color.green, 82), border_color=color.new(color.green, 35), extend=extend.right)

if showGaps and gapDown
    box.new(bar_index - 1, low[1], bar_index, high, bgcolor=color.new(color.red, 82), border_color=color.new(color.red, 35), extend=extend.right)

// ───── Fair Value Gaps
bullFVG = low > high[2]
bearFVG = high < low[2]

if showFVG and bullFVG
    box.new(bar_index - 2, low, bar_index, high[2], bgcolor=color.new(color.teal, 84), border_color=color.new(color.teal, 30), extend=extend.right)

if showFVG and bearFVG
    box.new(bar_index - 2, low[2], bar_index, high, bgcolor=color.new(color.maroon, 84), border_color=color.new(color.maroon, 30), extend=extend.right)

// ───── Fractal Market Structure
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastSwingHigh = na
var float lastSwingLow  = na
var string trend = "Neutral"

newPH = not na(ph)
newPL = not na(pl)

if showFractals and newPH
    swingHighBar = bar_index - pivotLen
    swingLabel = na(lastSwingHigh) ? "H" : ph > lastSwingHigh ? "HH" : "LH"
    label.new(swingHighBar, ph, swingLabel, style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white, size=size.tiny)
    lastSwingHigh := ph

if showFractals and newPL
    swingLowBar = bar_index - pivotLen
    swingLabel = na(lastSwingLow) ? "L" : pl > lastSwingLow ? "HL" : "LL"
    label.new(swingLowBar, pl, swingLabel, style=label.style_label_up, color=color.new(color.green, 0), textcolor=color.white, size=size.tiny)
    lastSwingLow := pl

// ───── SMC BOS / CHOCH
bullBreak = showSMC and not na(lastSwingHigh) and close > lastSwingHigh
bearBreak = showSMC and not na(lastSwingLow) and close < lastSwingLow

if bullBreak
    smcText = trend == "Bearish" ? "Bull CHOCH" : "Bull BOS"
    label.new(bar_index, high, smcText, style=label.style_label_down, color=color.green, textcolor=color.white, size=size.small)
    line.new(bar_index - 1, lastSwingHigh, bar_index, lastSwingHigh, color=color.green, width=2)
    trend := "Bullish"

if bearBreak
    smcText = trend == "Bullish" ? "Bear CHOCH" : "Bear BOS"
    label.new(bar_index, low, smcText, style=label.style_label_up, color=color.red, textcolor=color.white, size=size.small)
    line.new(bar_index - 1, lastSwingLow, bar_index, lastSwingLow, color=color.red, width=2)
    trend := "Bearish"

// ───── Simple Order Blocks
findBullOB() =>
    float obHigh = na
    float obLow = na
    int obBar = na
    for i = 1 to boxLookback
        if close[i] < open[i]
            obHigh := high[i]
            obLow := low[i]
            obBar := bar_index - i
            break
    [obHigh, obLow, obBar]

findBearOB() =>
    float obHigh = na
    float obLow = na
    int obBar = na
    for i = 1 to boxLookback
        if close[i] > open[i]
            obHigh := high[i]
            obLow := low[i]
            obBar := bar_index - i
            break
    [obHigh, obLow, obBar]

if showOB and bullBreak
    [obH, obL, obB] = findBullOB()
    if not na(obH)
        box.new(obB, obH, bar_index, obL, bgcolor=color.new(color.green, 88), border_color=color.new(color.green, 35), extend=extend.right)

if showOB and bearBreak
    [obH, obL, obB] = findBearOB()
    if not na(obH)
        box.new(obB, obH, bar_index, obL, bgcolor=color.new(color.red, 88), border_color=color.new(color.red, 35), extend=extend.right)

// ───── Alerts
alertcondition(insideBar, "Strat 1 Inside Bar", "Strat 1 Inside Bar")
alertcondition(outsideBar, "Strat 3 Outside Bar", "Strat 3 Outside Bar")
alertcondition(bullBreak, "Bullish BOS/CHOCH", "Bullish BOS/CHOCH")
alertcondition(bearBreak, "Bearish BOS/CHOCH", "Bearish BOS/CHOCH")
alertcondition(bullFVG, "Bullish FVG", "Bullish Fair Value Gap")
alertcondition(bearFVG, "Bearish FVG", "Bearish Fair Value Gap")
````

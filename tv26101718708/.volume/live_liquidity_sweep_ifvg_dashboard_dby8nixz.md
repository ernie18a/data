# Live Liquidity Sweep IFVG Dashboard 

- url: https://www.tradingview.com/script/DBY8nIxZ-Live-Liquidity-Sweep-IFVG-Dashboard/
- type: indicator
- pine_id: PUB;30cf247345af4fd4b9ec065e6d2dd278
- version: 1.0

## Description

Simply sees where and when the liquidity is being taking out, finds the fair value gap and then gives you a percent chance of the best trade to be taken...

## Source Code

````pine
//@version=5
indicator("Live Liquidity Sweep IFVG Dashboard", overlay=true, max_labels_count=20, max_lines_count=20)

// ==========================
// Inputs
// ==========================
swingLen      = input.int(6, "Swing Length", minval=2)
signalWindow = input.int(10, "Bars After Sweep To Confirm", minval=1)
minScore     = input.int(70, "Minimum Signal Score", minval=40, maxval=100)
cooldownBars = input.int(10, "Cooldown Between Signals", minval=1)

emaLen = input.int(50, "Trend EMA Length", minval=5)
rsiLen = input.int(14, "RSI Length", minval=5)
volLen = input.int(20, "Volume Average Length", minval=5)

showLatestSignal = input.bool(true, "Show Latest Signal Label")
showTarget       = input.bool(true, "Show Active Target Line")
showEMA          = input.bool(false, "Show Trend EMA")

bullColor = input.color(color.lime, "Bullish Color")
bearColor = input.color(color.red, "Bearish Color")
waitColor = input.color(color.orange, "Waiting Color")
neutralColor = input.color(color.gray, "Neutral Color")

// ==========================
// Core Calculations
// ==========================
ema = ta.ema(close, emaLen)
rsi = ta.rsi(close, rsiLen)
avgVol = ta.sma(volume, volLen)

// Swing highs/lows
swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow  = ta.pivotlow(low, swingLen, swingLen)

var float lastSwingHigh = na
var float lastSwingLow  = na

if not na(swingHigh)
    lastSwingHigh := swingHigh

if not na(swingLow)
    lastSwingLow := swingLow

// ==========================
// Liquidity Sweep Logic
// ==========================
// Bullish idea: price takes prior swing low, then closes back above it
bullSweep = not na(lastSwingLow) and low < lastSwingLow and close > lastSwingLow

// Bearish idea: price takes prior swing high, then closes back below it
bearSweep = not na(lastSwingHigh) and high > lastSwingHigh and close < lastSwingHigh

// Store active sweep state
var int bullSweepBar = na
var int bearSweepBar = na

if bullSweep
    bullSweepBar := bar_index
    bearSweepBar := na

if bearSweep
    bearSweepBar := bar_index
    bullSweepBar := na

bullValidWindow = not na(bullSweepBar) and bar_index - bullSweepBar <= signalWindow
bearValidWindow = not na(bearSweepBar) and bar_index - bearSweepBar <= signalWindow

// Expire old sweep states
if not na(bullSweepBar) and bar_index - bullSweepBar > signalWindow
    bullSweepBar := na

if not na(bearSweepBar) and bar_index - bearSweepBar > signalWindow
    bearSweepBar := na

// ==========================
// IFVG / Displacement Logic
// ==========================
// Simple 3-candle FVG confirmation
bullFVG = low > high[2]
bearFVG = high < low[2]

// Displacement confirmation
bullDisplacement = close > open and close > close[1]
bearDisplacement = close < open and close < close[1]

// Trend filter
bullTrend = close > ema
bearTrend = close < ema

// RSI filter
bullRSI = rsi > 40 and rsi < 72
bearRSI = rsi < 60 and rsi > 25

// Volume filter
volumeConfirm = volume > avgVol

// ==========================
// Score Logic
// ==========================
bullScore = 0
bullScore += bullValidWindow ? 35 : 0
bullScore += bullFVG ? 20 : 0
bullScore += bullDisplacement ? 15 : 0
bullScore += bullTrend ? 15 : 0
bullScore += bullRSI ? 10 : 0
bullScore += volumeConfirm ? 5 : 0

bearScore = 0
bearScore += bearValidWindow ? 35 : 0
bearScore += bearFVG ? 20 : 0
bearScore += bearDisplacement ? 15 : 0
bearScore += bearTrend ? 15 : 0
bearScore += bearRSI ? 10 : 0
bearScore += volumeConfirm ? 5 : 0

// ==========================
// Signal Control
// ==========================
var int lastSignalBar = na
canSignal = na(lastSignalBar) or bar_index - lastSignalBar > cooldownBars

longSignal  = canSignal and bullScore >= minScore
shortSignal = canSignal and bearScore >= minScore

if longSignal or shortSignal
    lastSignalBar := bar_index

if longSignal
    bullSweepBar := na

if shortSignal
    bearSweepBar := na

// ==========================
// Current Live State
// ==========================
string biasText = "NO TRADE"
string sweepText = "None"
string ifvgText = "Waiting"
string actionText = "Wait"
int activeScore = 0
color stateColor = neutralColor

if bullValidWindow and not longSignal
    biasText := "LONG WATCH"
    sweepText := "Low Taken"
    ifvgText := bullFVG ? "Confirmed" : "Waiting"
    activeScore := bullScore
    actionText := bullScore >= minScore ? "Long Ready" : "Wait"
    stateColor := waitColor

if bearValidWindow and not shortSignal
    biasText := "SHORT WATCH"
    sweepText := "High Taken"
    ifvgText := bearFVG ? "Confirmed" : "Waiting"
    activeScore := bearScore
    actionText := bearScore >= minScore ? "Short Ready" : "Wait"
    stateColor := waitColor

if longSignal
    biasText := "LONG SETUP"
    sweepText := "Low Taken"
    ifvgText := "Confirmed"
    activeScore := bullScore
    actionText := "Long"
    stateColor := bullColor

if shortSignal
    biasText := "SHORT SETUP"
    sweepText := "High Taken"
    ifvgText := "Confirmed"
    activeScore := bearScore
    actionText := "Short"
    stateColor := bearColor

// ==========================
// Clean Latest Signal Label
// ==========================
var label latestLabel = na
var line targetLine = na
var label targetLabel = na

if longSignal or shortSignal
    if not na(latestLabel)
        label.delete(latestLabel)
    if not na(targetLine)
        line.delete(targetLine)
    if not na(targetLabel)
        label.delete(targetLabel)

if showLatestSignal and longSignal
    latestLabel := label.new(
         bar_index,
         low,
         "LONG\n" + str.tostring(bullScore) + "%",
         style=label.style_label_up,
         color=color.new(bullColor, 0),
         textcolor=color.white,
         size=size.large
     )

if showLatestSignal and shortSignal
    latestLabel := label.new(
         bar_index,
         high,
         "SHORT\n" + str.tostring(bearScore) + "%",
         style=label.style_label_down,
         color=color.new(bearColor, 0),
         textcolor=color.white,
         size=size.large
     )

// ==========================
// Active Target Line
// Long targets prior swing high
// Short targets prior swing low
// ==========================
if showTarget and longSignal and not na(lastSwingHigh)
    targetLine := line.new(
         bar_index,
         lastSwingHigh,
         bar_index + 40,
         lastSwingHigh,
         color=color.new(bullColor, 0),
         style=line.style_dashed,
         width=2
     )
    targetLabel := label.new(
         bar_index + 40,
         lastSwingHigh,
         "Target High",
         style=label.style_label_left,
         color=color.new(bullColor, 0),
         textcolor=color.white
     )

if showTarget and shortSignal and not na(lastSwingLow)
    targetLine := line.new(
         bar_index,
         lastSwingLow,
         bar_index + 40,
         lastSwingLow,
         color=color.new(bearColor, 0),
         style=line.style_dashed,
         width=2
     )
    targetLabel := label.new(
         bar_index + 40,
         lastSwingLow,
         "Target Low",
         style=label.style_label_left,
         color=color.new(bearColor, 0),
         textcolor=color.white
     )

// ==========================
// Dashboard Table
// ==========================
var table dash = table.new(position.top_right, 2, 6, border_width=1)

if barstate.islast
    table.cell(dash, 0, 0, "LIQUIDITY SETUP", text_color=color.white, bgcolor=color.new(stateColor, 0))
    table.cell(dash, 1, 0, biasText, text_color=color.white, bgcolor=color.new(stateColor, 0))

    table.cell(dash, 0, 1, "Sweep", text_color=color.white, bgcolor=color.new(color.black, 10))
    table.cell(dash, 1, 1, sweepText, text_color=color.white, bgcolor=color.new(color.black, 10))

    table.cell(dash, 0, 2, "IFVG", text_color=color.white, bgcolor=color.new(color.black, 10))
    table.cell(dash, 1, 2, ifvgText, text_color=color.white, bgcolor=color.new(color.black, 10))

    table.cell(dash, 0, 3, "Score", text_color=color.white, bgcolor=color.new(color.black, 10))
    table.cell(dash, 1, 3, str.tostring(activeScore) + "%", text_color=color.white, bgcolor=color.new(color.black, 10))

    table.cell(dash, 0, 4, "Action", text_color=color.white, bgcolor=color.new(color.black, 10))
    table.cell(dash, 1, 4, actionText, text_color=color.white, bgcolor=color.new(color.black, 10))

    table.cell(dash, 0, 5, "Mode", text_color=color.white, bgcolor=color.new(color.black, 10))
    table.cell(dash, 1, 5, "Sweep + IFVG", text_color=color.white, bgcolor=color.new(color.black, 10))

// ==========================
// Optional EMA
// ==========================
plot(showEMA ? ema : na, "Trend EMA", color=color.new(color.gray, 50))

// ==========================
// Alerts
// ==========================
alertcondition(longSignal, title="LONG Setup", message="LONG setup confirmed: liquidity sweep low + IFVG confirmation.")
alertcondition(shortSignal, title="SHORT Setup", message="SHORT setup confirmed: liquidity sweep high + IFVG confirmation.")
````

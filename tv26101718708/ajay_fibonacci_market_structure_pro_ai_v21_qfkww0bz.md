# Ajay Fibonacci Market Structure Pro AI V2.1

- url: https://www.tradingview.com/script/qFkWw0Bz-Ajay-Fibonacci-Market-Structure-Pro-AI-V2-1/
- type: indicator
- pine_id: PUB;9d9688405eb54c0aa1a8d3b9f185d67d
- version: 1.0

## Description

# Ajay Fibonacci Market Structure Pro AI V2.1

Ajay Fibonacci Market Structure Pro AI V2.1 is an advanced Fibonacci-based market structure indicator designed specifically for Gold (XAUUSD), Bitcoin (BTC), NAS100, and other trending markets.

The indicator combines automatic Fibonacci retracement analysis, market structure, support and resistance, ZigZag swing detection, AI confidence scoring, and trade management into a single clean trading tool.

## Key Features

### Automatic Fibonacci Retracement

* Auto-detects Swing Highs and Swing Lows
* Automatically updates Fibonacci levels as market structure changes
* No manual drawing required

### Fibonacci Levels

* 0.236 | 23.6% Continuation
* 0.382 | 38.2% Pullback
* 0.500 | 50.0% Mid Zone
* 0.618 | 61.8% Golden Zone
* 0.786 | 78.6% Last Chance
* 1.000 | 100% Swing Target

### Market Structure Analysis

* Automatic Swing High and Swing Low labels
* ZigZag market structure visualization
* Uptrend Fib and Downtrend Fib detection
* Dynamic structure updates

### Support & Resistance

* Automatic support levels from Swing Lows
* Automatic resistance levels from Swing Highs
* Clean right-side price labels
* Market structure confluence detection

### AI Confidence System

The built-in AI scoring engine evaluates:

* Market structure quality
* Fibonacci confluence
* Support and resistance alignment
* Rejection candle confirmation
* Trend strength

Signals are filtered through an AI confidence score to reduce low-quality setups.

### Trading Dashboard

The professional dashboard displays:

* Current Trend
* AI Score
* Current Fibonacci Zone
* Price vs 0.618 Golden Zone
* Golden Zone Status
* Signal Status
* TP Plan
* Market Focus

### Trade Management

* TP1: Swing Target
* TP2: Fibonacci 1.272 Extension
* TP3: Fibonacci 1.618 Extension
* Dynamic Stop Loss (0.786 Last Chance Zone)

### TradingView Auto Fib Module

Optional advanced module featuring:

* Automatic ZigZag Anchoring
* Extension Levels
* Reverse Fib Mode
* Dynamic Auto Updates
* 1.272 Extension
* 1.618 Extension
* 2.618 Extension
* 3.618 Extension
* 4.236 Extension

## Recommended Markets

* Gold (XAUUSD)
* Bitcoin (BTCUSD)
* NAS100
* US30
* Major Forex Pairs

## Recommended Timeframes

* 5 Minute (Primary Scalping)
* 15 Minute
* 30 Minute
* 1 Hour

## Best Use

The indicator is designed to help traders identify high-probability retracement opportunities while understanding market structure through Fibonacci theory. The 0.618 Golden Zone remains the primary focus area, while AI confidence scoring helps filter weaker setups.

Developed as part of the Ajay Trading Project series, this indicator combines Fibonacci retracement, market structure analysis, support/resistance, and AI-assisted trade evaluation into a single professional trading tool.

## Source Code

````pine
//@version=6
indicator("Ajay Fibonacci Market Structure Pro AI V2.1", overlay=true, max_lines_count=500, max_labels_count=500)

//====================================================
// IMPORT TRADINGVIEW ZIGZAG
//====================================================
import TradingView/ZigZag/7 as zigzag

//====================================================
// AJAY AI FIB INPUTS
//====================================================
showAjayAI = input.bool(true, "Show Ajay AI Fib System")
swingLen = input.int(10, "Ajay Swing Strength", minval=2)
extendBars = input.int(80, "Ajay Extend Right", minval=20)

show236 = input.bool(true, "Show 0.236")
showSignals = input.bool(true, "Show AI Buy/Sell")
showSwingLabels = input.bool(true, "Show Swing High/Low")
showZigZag = input.bool(true, "Show Ajay ZigZag")
showSR = input.bool(true, "Show Support/Resistance")
showTPSL = input.bool(true, "Show TP1/TP2/TP3/SL")
showDashboard = input.bool(true, "Show AI Dashboard")
minScore = input.int(70, "Minimum AI Score", minval=0, maxval=100)

//====================================================
// COLORS
//====================================================
col236 = color.rgb(255, 220, 80)
col382 = color.rgb(255, 140, 0)
col500 = color.rgb(0, 120, 255)
col618 = color.rgb(0, 220, 120)
col786 = color.rgb(160, 60, 255)
colTarget = color.rgb(255, 40, 80)

//====================================================
// AJAY SWINGS
//====================================================
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float swingHigh = na
var float swingLow = na
var int swingHighBar = na
var int swingLowBar = na

if not na(ph)
    swingHigh := ph
    swingHighBar := bar_index - swingLen

if not na(pl)
    swingLow := pl
    swingLowBar := bar_index - swingLen

valid = not na(swingHigh) and not na(swingLow)
uptrend = valid and swingLowBar < swingHighBar
downtrend = valid and swingHighBar < swingLowBar

fibRange = math.abs(swingHigh - swingLow)

fibTarget = uptrend ? swingHigh : swingLow
fibBase = uptrend ? swingLow : swingHigh

fib236 = uptrend ? swingHigh - fibRange * 0.236 : swingLow + fibRange * 0.236
fib382 = uptrend ? swingHigh - fibRange * 0.382 : swingLow + fibRange * 0.382
fib500 = uptrend ? swingHigh - fibRange * 0.500 : swingLow + fibRange * 0.500
fib618 = uptrend ? swingHigh - fibRange * 0.618 : swingLow + fibRange * 0.618
fib786 = uptrend ? swingHigh - fibRange * 0.786 : swingLow + fibRange * 0.786

tp1 = fibTarget
tp2 = uptrend ? swingHigh + fibRange * 0.272 : swingLow - fibRange * 0.272
tp3 = uptrend ? swingHigh + fibRange * 0.618 : swingLow - fibRange * 0.618
sl = fib786

//====================================================
// AJAY FIB DRAWING
//====================================================
var line[] fibLines = array.new_line()
var label[] fibLabels = array.new_label()

clearFib() =>
    for l in fibLines
        line.delete(l)
    for lb in fibLabels
        label.delete(lb)
    array.clear(fibLines)
    array.clear(fibLabels)

drawFib(price, txt, col, width) =>
    l = line.new(bar_index - swingLen, price, bar_index + extendBars, price, color=col, width=width)
    lb = label.new(bar_index + extendBars, price, txt + "  " + str.tostring(price, format.mintick), style=label.style_label_left, color=col, textcolor=color.white, size=size.small)
    array.push(fibLines, l)
    array.push(fibLabels, lb)

if barstate.islast and valid and showAjayAI
    clearFib()

    drawFib(fibTarget, "1.000 | 100% Swing Target", colTarget, 2)

    if show236
        drawFib(fib236, "0.236 | 23.6% Continuation", col236, 1)

    drawFib(fib382, "0.382 | 38.2% Pullback", col382, 1)
    drawFib(fib500, "0.500 | 50.0% Mid Zone", col500, 2)
    drawFib(fib618, "0.618 | 61.8% Golden Zone", col618, 2)
    drawFib(fib786, "0.786 | 78.6% Last Chance", col786, 1)
    drawFib(fibBase, "0.000 | Swing Base", color.gray, 1)

//====================================================
// SWING LABELS + ZIGZAG
//====================================================
var label shLab = na
var label slLab2 = na
var label trendLab = na
var line zzLine = na

if barstate.islast and valid and showAjayAI
    label.delete(shLab)
    label.delete(slLab2)
    label.delete(trendLab)
    line.delete(zzLine)

    if showSwingLabels
        shLab := label.new(swingHighBar, swingHigh, "SWING HIGH", style=label.style_label_down, color=color.red, textcolor=color.white)
        slLab2 := label.new(swingLowBar, swingLow, "SWING LOW", style=label.style_label_up, color=color.green, textcolor=color.white)

    if showZigZag
        zzLine := line.new(swingLowBar, swingLow, swingHighBar, swingHigh, color=color.orange, width=2)

    trendLab := label.new(bar_index, fibTarget, uptrend ? "UPTREND FIB" : "DOWNTREND FIB", style=label.style_label_down, color=uptrend ? color.green : color.red, textcolor=color.white)

//====================================================
// SUPPORT / RESISTANCE
//====================================================
var line[] srLines = array.new_line()
var label[] srLabels = array.new_label()

addSR(price, txt, col) =>
    l = line.new(bar_index - swingLen, price, bar_index + extendBars, price, color=col, width=1)
    lb = label.new(bar_index + extendBars, price, txt + " " + str.tostring(price, format.mintick), style=label.style_label_left, color=col, textcolor=color.white, size=size.small)
    array.push(srLines, l)
    array.push(srLabels, lb)

    if array.size(srLines) > 6
        line.delete(array.shift(srLines))
        label.delete(array.shift(srLabels))

if showAjayAI and showSR
    if not na(ph)
        addSR(ph, "Resistance", color.red)
    if not na(pl)
        addSR(pl, "Support", color.green)

if array.size(srLines) > 0
    for i = 0 to array.size(srLines) - 1
        line.set_x2(array.get(srLines, i), bar_index + extendBars)
        label.set_x(array.get(srLabels, i), bar_index + extendBars)

//====================================================
// REACTION LOGIC
//====================================================
bullReject(level) =>
    low <= level and close > level and close > open

bearReject(level) =>
    high >= level and close < level and close < open

near236 = low <= fib236 and high >= fib236
near382 = low <= fib382 and high >= fib382
near500 = low <= fib500 and high >= fib500
near618 = low <= fib618 and high >= fib618
near786 = low <= fib786 and high >= fib786

buySignal = showAjayAI and showSignals and uptrend and (bullReject(fib382) or bullReject(fib500) or bullReject(fib618) or bullReject(fib786))
sellSignal = showAjayAI and showSignals and downtrend and (bearReject(fib382) or bearReject(fib500) or bearReject(fib618) or bearReject(fib786))

score = 0
score += uptrend or downtrend ? 25 : 0
score += near618 ? 30 : near500 ? 20 : near786 ? 15 : near382 ? 12 : near236 ? 8 : 0
score += buySignal or sellSignal ? 25 : 0
score += showSR ? 10 : 0
score += showZigZag ? 10 : 0

strongBuy = buySignal and score >= minScore
strongSell = sellSignal and score >= minScore

currentZone = near618 ? "0.618 Golden" : near500 ? "0.500 Mid" : near786 ? "0.786 Last" : near382 ? "0.382 Pullback" : near236 ? "0.236 Continuation" : "Between Levels"
priceVs618 = close > fib618 ? "Above 0.618" : close < fib618 ? "Below 0.618" : "At 0.618"
goldenStatus = near618 ? "ACTIVE" : "Not Reached"
signalText = strongBuy ? "STRONG BUY" : strongSell ? "STRONG SELL" : buySignal ? "Buy Setup" : sellSignal ? "Sell Setup" : "WAIT"

//====================================================
// SIGNAL LABELS
//====================================================
if strongBuy
    label.new(bar_index, low, "AI STRONG BUY\nScore: " + str.tostring(score), style=label.style_label_up, color=color.lime, textcolor=color.black)

if strongSell
    label.new(bar_index, high, "AI STRONG SELL\nScore: " + str.tostring(score), style=label.style_label_down, color=color.red, textcolor=color.white)

plotshape(strongBuy, title="AI Buy Dot", style=shape.circle, location=location.belowbar, color=color.lime, size=size.small)
plotshape(strongSell, title="AI Sell Dot", style=shape.circle, location=location.abovebar, color=color.red, size=size.small)

//====================================================
// TP / SL
//====================================================
var label entryLab = na
var label tp1Lab = na
var label tp2Lab = na
var label tp3Lab = na
var label stopLab = na

if showTPSL and strongBuy
    label.delete(entryLab)
    label.delete(tp1Lab)
    label.delete(tp2Lab)
    label.delete(tp3Lab)
    label.delete(stopLab)

    entryLab := label.new(bar_index, close, "BUY ENTRY", style=label.style_label_up, color=color.lime, textcolor=color.black)
    tp1Lab := label.new(bar_index + 5, tp1, "TP1 Swing Target: " + str.tostring(tp1, format.mintick), style=label.style_label_left, color=color.green, textcolor=color.white)
    tp2Lab := label.new(bar_index + 5, tp2, "TP2 1.272: " + str.tostring(tp2, format.mintick), style=label.style_label_left, color=color.green, textcolor=color.white)
    tp3Lab := label.new(bar_index + 5, tp3, "TP3 1.618: " + str.tostring(tp3, format.mintick), style=label.style_label_left, color=color.green, textcolor=color.white)
    stopLab := label.new(bar_index + 5, sl, "SL 0.786: " + str.tostring(sl, format.mintick), style=label.style_label_left, color=color.red, textcolor=color.white)

if showTPSL and strongSell
    label.delete(entryLab)
    label.delete(tp1Lab)
    label.delete(tp2Lab)
    label.delete(tp3Lab)
    label.delete(stopLab)

    entryLab := label.new(bar_index, close, "SELL ENTRY", style=label.style_label_down, color=color.red, textcolor=color.white)
    tp1Lab := label.new(bar_index + 5, tp1, "TP1 Swing Target: " + str.tostring(tp1, format.mintick), style=label.style_label_left, color=color.green, textcolor=color.white)
    tp2Lab := label.new(bar_index + 5, tp2, "TP2 1.272: " + str.tostring(tp2, format.mintick), style=label.style_label_left, color=color.green, textcolor=color.white)
    tp3Lab := label.new(bar_index + 5, tp3, "TP3 1.618: " + str.tostring(tp3, format.mintick), style=label.style_label_left, color=color.green, textcolor=color.white)
    stopLab := label.new(bar_index + 5, sl, "SL 0.786: " + str.tostring(sl, format.mintick), style=label.style_label_left, color=color.red, textcolor=color.white)

//====================================================
// UPDATED AI DASHBOARD
//====================================================
var table dash = table.new(position.top_right, 2, 9, border_width=1)

dashBg = color.rgb(20, 24, 32)
headerBg = color.rgb(45, 50, 60)

if barstate.islast and showDashboard and showAjayAI
    table.cell(dash, 0, 0, "Ajay Fib AI", text_color=color.white, bgcolor=headerBg)
    table.cell(dash, 1, 0, "V2.1", text_color=color.white, bgcolor=headerBg)

    table.cell(dash, 0, 1, "Trend", text_color=color.white, bgcolor=dashBg)
    table.cell(dash, 1, 1, uptrend ? "UPTREND" : downtrend ? "DOWNTREND" : "WAIT", text_color=color.white, bgcolor=uptrend ? color.green : downtrend ? color.red : color.gray)

    table.cell(dash, 0, 2, "AI Score", text_color=color.white, bgcolor=dashBg)
    table.cell(dash, 1, 2, str.tostring(score) + "/100", text_color=color.white, bgcolor=score >= 70 ? color.green : score >= 50 ? color.orange : color.red)

    table.cell(dash, 0, 3, "Current Zone", text_color=color.white, bgcolor=dashBg)
    table.cell(dash, 1, 3, currentZone, text_color=color.white, bgcolor=dashBg)

    table.cell(dash, 0, 4, "Price vs 0.618", text_color=color.white, bgcolor=dashBg)
    table.cell(dash, 1, 4, priceVs618, text_color=color.white, bgcolor=dashBg)

    table.cell(dash, 0, 5, "Golden Zone", text_color=color.white, bgcolor=dashBg)
    table.cell(dash, 1, 5, goldenStatus, text_color=color.white, bgcolor=near618 ? color.green : dashBg)

    table.cell(dash, 0, 6, "Signal", text_color=color.white, bgcolor=dashBg)
    table.cell(dash, 1, 6, signalText, text_color=color.white, bgcolor=strongBuy ? color.green : strongSell ? color.red : dashBg)

    table.cell(dash, 0, 7, "TP Plan", text_color=color.white, bgcolor=dashBg)
    table.cell(dash, 1, 7, "TP1 / TP2 / TP3", text_color=color.white, bgcolor=dashBg)

    table.cell(dash, 0, 8, "Focus", text_color=color.white, bgcolor=dashBg)
    table.cell(dash, 1, 8, near618 ? "Watch reaction" : "Wait for 0.618", text_color=color.white, bgcolor=dashBg)

//====================================================
// TRADINGVIEW AUTO FIB MODULE
//====================================================
showTVAutoFib = input.bool(false, "Show TradingView Auto Fib Module")

devTooltip = "Deviation controls how much price must move to form a new ZigZag pivot."
depthTooltip = "Depth is the minimum number of bars used to calculate pivots."

threshold_multiplier = input.float(title="TV Fib Deviation", defval=3, minval=0, tooltip=devTooltip)
depth = input.int(title="TV Fib Depth", defval=10, minval=2, tooltip=depthTooltip)
reverse = input.bool(false, "TV Fib Reverse")
tvExtendLeft = input.bool(false, "TV Fib Extend Left")
tvExtendRight = input.bool(true, "TV Fib Extend Right")

var tvExtending = extend.none
if tvExtendLeft and tvExtendRight
    tvExtending := extend.both
if tvExtendLeft and not tvExtendRight
    tvExtending := extend.left
if not tvExtendLeft and tvExtendRight
    tvExtending := extend.right

tvPrices = input.bool(true, "TV Fib Show Prices")
tvLevels = input.bool(true, "TV Fib Show Levels")
tvLevelsFormat = input.string("Values", "TV Fib Label Format", options=["Values", "Percent"])
tvLabelsPosition = input.string("Right", "TV Fib Labels Position", options=["Left", "Right"])
tvBgTrans = input.int(85, "TV Fib Background Transparency", minval=0, maxval=100)

tvUpdate() =>
    var settings = zigzag.Settings.new(threshold_multiplier, depth, color(na), false, false, false, false, "Absolute", true)
    var zigzag.ZigZag tvZZ = zigzag.newInstance(settings)
    var zigzag.Pivot lastP = na
    var float startPrice = na
    var float height = na

    settings.devThreshold := ta.atr(10) / close * 100 * threshold_multiplier

    if tvZZ.update()
        lastP := tvZZ.lastPivot()
        if not na(lastP)
            startPrice := reverse ? lastP.start.price : lastP.end.price
            endPrice = reverse ? lastP.end.price : lastP.start.price
            height := (startPrice > endPrice ? -1 : 1) * math.abs(startPrice - endPrice)

    [lastP, startPrice, height]

[tvLastP, tvStartPrice, tvHeight] = tvUpdate()

tvDrawLine(price, col) =>
    var id = line.new(time, price, time, price, xloc=xloc.bar_time, color=col, width=1, extend=tvExtending)
    if not na(tvLastP)
        line.set_xy1(id, tvLastP.start.time, price)
        line.set_xy2(id, tvLastP.end.time, price)
    id

tvDrawLabel(price, txt, txtColor) =>
    x = tvLabelsPosition == "Left" and not na(tvLastP) ? tvLastP.start.time : time
    labelStyle = tvLabelsPosition == "Left" ? label.style_label_right : label.style_label_left
    align = tvLabelsPosition == "Left" ? text.align_right : text.align_left
    var id = label.new(x=x, y=price, xloc=xloc.bar_time, text=txt, textcolor=txtColor, style=labelStyle, textalign=align, color=#00000000)
    label.set_xy(id, x, price)
    label.set_text(id, txt)
    label.set_textcolor(id, txtColor)

tvWrap(txt) =>
    "(" + str.tostring(txt, format.mintick) + ")"

tvLabelTxt(level, price) =>
    l = tvLevelsFormat == "Values" ? str.tostring(level) : str.tostring(level * 100) + "%"
    (tvLevels ? l : "") + (tvPrices ? " " + tvWrap(price) : "")

tvCrossingLevel(series float sr, series float r) =>
    (r > sr and r < sr[1]) or (r < sr and r > sr[1])

tvProcessLevel(bool show, float value, color colorL, line lineIdOther) =>
    float m = value
    r = tvStartPrice + tvHeight * m
    crossed = tvCrossingLevel(close, r)

    if showTVAutoFib and show and not na(tvLastP) and not na(tvStartPrice) and not na(tvHeight)
        lineId = tvDrawLine(r, colorL)
        tvDrawLabel(r, tvLabelTxt(m, r), colorL)

        if crossed
            alert("TV AutoFib: " + syminfo.ticker + " crossing level " + str.tostring(value))

        if not na(lineIdOther)
            linefill.new(lineId, lineIdOther, color=color.new(colorL, tvBgTrans))

        lineId
    else
        lineIdOther

show_0 = input.bool(true, "TV 0")
show_236 = input.bool(true, "TV 0.236")
show_382 = input.bool(true, "TV 0.382")
show_500 = input.bool(true, "TV 0.500")
show_618 = input.bool(true, "TV 0.618")
show_786 = input.bool(true, "TV 0.786")
show_1 = input.bool(true, "TV 1.000")
show_1272 = input.bool(true, "TV 1.272")
show_1618 = input.bool(true, "TV 1.618")
show_2618 = input.bool(false, "TV 2.618")
show_3618 = input.bool(false, "TV 3.618")
show_4236 = input.bool(false, "TV 4.236")

lineId0 = tvProcessLevel(show_0, 0.0, color.gray, line(na))
lineId1 = tvProcessLevel(show_236, 0.236, color.yellow, lineId0)
lineId2 = tvProcessLevel(show_382, 0.382, color.orange, lineId1)
lineId3 = tvProcessLevel(show_500, 0.5, color.blue, lineId2)
lineId4 = tvProcessLevel(show_618, 0.618, color.green, lineId3)
lineId5 = tvProcessLevel(show_786, 0.786, color.purple, lineId4)
lineId6 = tvProcessLevel(show_1, 1.0, color.red, lineId5)
lineId7 = tvProcessLevel(show_1272, 1.272, color.green, lineId6)
lineId8 = tvProcessLevel(show_1618, 1.618, color.blue, lineId7)
lineId9 = tvProcessLevel(show_2618, 2.618, color.red, lineId8)
lineId10 = tvProcessLevel(show_3618, 3.618, color.purple, lineId9)
lineId11 = tvProcessLevel(show_4236, 4.236, color.fuchsia, lineId10)

//====================================================
// ALERTS
//====================================================
alertcondition(strongBuy, "Ajay Fib AI Strong Buy", "AI Strong Buy confirmed")
alertcondition(strongSell, "Ajay Fib AI Strong Sell", "AI Strong Sell confirmed")
````

# PSP AI Auto Gap Finder (Bullish + Bearish)

- url: https://www.tradingview.com/script/yyOI6voJ-PSP-AI-Auto-Gap-Finder-Bullish-Bearish/
- type: indicator
- pine_id: PUB;9017f65aabc5482680a54a6f6f91972d
- version: 1.0

## Description

"PSP AI Auto Gap Finder (Bullish + Bearish)" detects significant bullish and bearish price gaps automatically and visualizes them as dynamic zones on the chart. It combines historical gap behavior with live momentum analysis to estimate whether pending gaps may get filled soon.

Key Features:

* Auto-detects Bullish & Bearish Gaps
* Filter gaps by minimum % or minimum points
* Marks zones as **Filled** or **Pending for Filling**
* Shows gap size in points
* Displays bars taken to fill past gaps
* AI-style ETA for pending gap fills
* Probability score based on trend + RSI + momentum
* Separate controls for Filled / Pending zones
* Custom colors for bullish and bearish zones

Best Use Cases:

* Nifty / BankNifty gap trading
* Support & resistance via unfilled gaps
* Swing trading targets
* Mean reversion setups
* Historical gap behavior study

Example Box Output:

1. Bullish Gap
2. Pending for Filling
3. Gap: 674 pts
4. Open Since: 11 bars
5. ETA: 8 bars
6. Prob: 78%
=====

Designed for traders who want to track large gaps and estimate likely fill opportunities visually.

## Source Code

````pine
//@version=5
indicator("PSP AI Auto Gap Finder (Bullish + Bearish)", overlay=true, max_boxes_count=500, max_labels_count=500)

//================ INPUTS ================
minGapPerc   = input.float(0.15, "Minimum Gap %", step=0.05)
minGapPoints = input.float(400, "Show Only Gap >= X Points", step=1)
extendBars   = input.int(100, "Extend Gap Zone Bars", minval=10)

showBullBox  = input.bool(true, "Show Bullish Boxes")
showBearBox  = input.bool(true, "Show Bearish Boxes")
showFilled   = input.bool(true, "Show Filled Boxes")
showPending  = input.bool(true, "Show Pending Boxes")

bullColor    = input.color(color.new(color.green, 82), "Bullish Gap Color")
bearColor    = input.color(color.new(color.red, 82), "Bearish Gap Color")
bullFilled   = input.color(color.new(color.green, 90), "Bull Filled Color")
bearFilled   = input.color(color.new(color.red, 90), "Bear Filled Color")
bullBorder   = input.color(color.green, "Bull Border")
bearBorder   = input.color(color.red, "Bear Border")

//================ ARRAYS ================
var box[] boxes      = array.new_box()
var bool[] bullArr   = array.new_bool()
var float[] topArr   = array.new_float()
var float[] botArr   = array.new_float()
var bool[] doneArr   = array.new_bool()
var int[] startArr   = array.new_int()
var int[] fillArr    = array.new_int()

//================ INDICATORS ================
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
rsi14 = ta.rsi(close, 14)

//================ FUNCTION ================
f_text(_bull, _done, _pts, _bars, _eta, _prob) =>
    dir = _bull ? "Bullish Gap" : "Bearish Gap"
    txt = ""
    
    if _done
        txt := dir + "\nFilled" +
         "\nGap: " + str.tostring(_pts, format.mintick) + " pts" +
         "\nFilled in: " + str.tostring(_bars) + " bars"
    else
        txt := dir + "\nPending for Filling" +
         "\nGap: " + str.tostring(_pts, format.mintick) + " pts" +
         "\nOpen Since: " + str.tostring(_bars) + " bars" +
         "\nETA: " + str.tostring(_eta) + " bars" +
         "\nProb: " + str.tostring(_prob) + "%"
    
    txt

//================ GAP CONDITIONS ================
bullGap = low > high[1]
bearGap = high < low[1]

bullPts = low - high[1]
bearPts = low[1] - high

bullPerc = ((low - high[1]) / high[1]) * 100
bearPerc = ((low[1] - high) / low[1]) * 100

//================ CREATE BULLISH ================
if bullGap and bullPts >= minGapPoints and bullPerc >= minGapPerc and showBullBox
    bx = box.new(
     left=bar_index,
     top=low,
     right=bar_index + extendBars,
     bottom=high[1],
     bgcolor=bullColor,
     border_color=bullBorder,
     text_color=color.white,
     text_size=size.small)

    array.push(boxes, bx)
    array.push(bullArr, true)
    array.push(topArr, low)
    array.push(botArr, high[1])
    array.push(doneArr, false)
    array.push(startArr, bar_index)
    array.push(fillArr, na)

//================ CREATE BEARISH ================
if bearGap and bearPts >= minGapPoints and bearPerc >= minGapPerc and showBearBox
    bx = box.new(
     left=bar_index,
     top=low[1],
     right=bar_index + extendBars,
     bottom=high,
     bgcolor=bearColor,
     border_color=bearBorder,
     text_color=color.white,
     text_size=size.small)

    array.push(boxes, bx)
    array.push(bullArr, false)
    array.push(topArr, low[1])
    array.push(botArr, high)
    array.push(doneArr, false)
    array.push(startArr, bar_index)
    array.push(fillArr, na)

//================ PROCESS BOXES ================
count = array.size(boxes)

if count > 0
    for i = 0 to count - 1

        bx    = array.get(boxes, i)
        bull  = array.get(bullArr, i)
        topV  = array.get(topArr, i)
        botV  = array.get(botArr, i)
        done  = array.get(doneArr, i)
        start = array.get(startArr, i)

        pts = topV - botV
        age = bar_index - start

        // Fill Logic
        if not done
            if bull and low <= botV
                done := true
                array.set(doneArr, i, true)
                array.set(fillArr, i, age)

            if not bull and high >= topV
                done := true
                array.set(doneArr, i, true)
                array.set(fillArr, i, age)

        // AI Probability
        prob = 60

        if bull
            if ema20 > ema50
                prob += 10
            if rsi14 < 40
                prob += 10
        else
            if ema20 < ema50
                prob += 10
            if rsi14 > 60
                prob += 10

        prob := math.min(prob, 95)

        eta = math.max(5, 25 - age)

        // Display
        if done
            fillBars = array.get(fillArr, i)

            box.set_bgcolor(bx, showFilled ? (bull ? bullFilled : bearFilled) : na)
            box.set_border_color(bx, bull ? bullBorder : bearBorder)
            box.set_text(bx, showFilled ? f_text(bull, true, pts, fillBars, eta, prob) : "")
        else
            box.set_bgcolor(bx, showPending ? (bull ? bullColor : bearColor) : na)
            box.set_border_color(bx, bull ? bullBorder : bearBorder)
            box.set_text(bx, showPending ? f_text(bull, false, pts, age, eta, prob) : "")
````

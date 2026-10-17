# 15-Minute Candle Box + Countdown 

- url: https://www.tradingview.com/script/UzZcPTfh-15-Minute-Candle-Box-Countdown/
- type: indicator
- pine_id: PUB;e6120b65608345c4b7d2b938cf432313
- version: 1.0

## Description

I couldn't find one any where......I Hope Its enjoyed!

## Source Code

````pine
//@version=6
indicator("15-Minute Candle Box + Countdown", overlay=true, max_boxes_count=5)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tf = input.timeframe("15", "Timeframe")

showBox = input.bool(true, "Show Box")
showTimer = input.bool(true, "Show Countdown")

useBullBear = input.bool(true, "Bull/Bear Coloring")

bullBorder = input.color(color.lime, "Bull Border")
bearBorder = input.color(color.red, "Bear Border")
neutralBorder = input.color(color.yellow, "Neutral Border")

bullFill = input.color(color.new(color.lime, 85), "Bull Fill")
bearFill = input.color(color.new(color.red, 85), "Bear Fill")
neutralFill = input.color(color.new(color.yellow, 85), "Neutral Fill")

timerBG = input.color(color.new(color.black, 15), "Timer Background")
timerText = input.color(color.white, "Timer Text")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Detect New 15-Minute Candle
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
newTFBar = ta.change(time(tf)) != 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Current Candle Range
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float boxHigh = na
var float boxLow = na
var float boxOpen = na

if newTFBar
    boxHigh := high
    boxLow := low
    boxOpen := open
else
    boxHigh := math.max(boxHigh, high)
    boxLow := math.min(boxLow, low)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Colors
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool bullish = close >= boxOpen

border =
     useBullBear
     ? (bullish ? bullBorder : bearBorder)
     : neutralBorder

fill =
     useBullBear
     ? (bullish ? bullFill : bearFill)
     : neutralFill

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Box
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box currentBox = na
var int leftBar = na

if newTFBar
    leftBar := bar_index

    if not na(currentBox)
        box.delete(currentBox)

    if showBox
        currentBox := box.new(
             left = leftBar,
             right = bar_index,
             top = boxHigh,
             bottom = boxLow,
             bgcolor = fill,
             border_color = border,
             border_width = 2)

if showBox and not na(currentBox)
    box.set_right(currentBox, bar_index)
    box.set_top(currentBox, boxHigh)
    box.set_bottom(currentBox, boxLow)
    box.set_bgcolor(currentBox, fill)
    box.set_border_color(currentBox, border)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Countdown Timer
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table timerTable = table.new(position.bottom_right, 1, 1)

if barstate.islast
    if showTimer

        closeTime = time_close(tf)
        secondsLeft = math.max(0, int(math.floor((closeTime - timenow) / 1000)))

        mins = secondsLeft / 60
        secs = secondsLeft % 60

        timer =
             str.tostring(mins, "00") +
             ":" +
             str.tostring(secs, "00")

        table.cell(
             timerTable,
             0,
             0,
             "Next " + tf + " Bar\n" + timer,
             bgcolor = timerBG,
             text_color = timerText,
             text_size = size.large)

    else
        table.clear(timerTable, 0, 0, 0, 0)
````

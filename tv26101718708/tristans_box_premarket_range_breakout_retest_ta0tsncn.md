# Tristan's Box: Pre-Market Range Breakout + Retest

- url: https://www.tradingview.com/script/tA0tSNcn-Tristan-s-Box-Pre-Market-Range-Breakout-Retest/
- type: strategy
- pine_id: PUB;839e843390ad4d4388a56f4e598fdd3c
- version: 1.0

## Description

[b]Market Context:[/b]
This is designed for U.S. stocks, focusing on pre-market price action (4:00–9:30 AM ET) to identify key support/resistance levels before the regular session opens.

Built for 1 min and 5 min timelines, and is intended for day trading / scalping.

[b]Core Idea:[/b]
[list]
[*]Pre-market range (high/low) often acts as a magnet for price during regular hours.
[*]The first breakout outside this range signals potential strong momentum in that direction.
[*]Retest of the breakout level confirms whether the breakout is valid, avoiding false moves.
[/list]

[b]Step-by-Step Logic:[/b]
[list=1]
[*]Pre-Market Range Identification:
[*]Track high and low from 4:00–9:30 AM ET.
[*]Draw a box spanning this range for visual reference and calculation.
[/list]

[b]Breakout Detection:[/b]
[list]
[*]When the first candle closes above the pre-market high → long breakout.
[*]When the first candle closes below the pre-market low → short breakout.
[*]The first breakout candle is highlighted with a “YOLO” label for visual confirmation.
[/list]

[b]Retest Confirmation:[/b]
[list]
[*]Identify the first candle whose wick touches the pre-market box (high touches top for short, low touches bottom for long).
[*]Wait for the next candle: if it closes outside the box, it confirms the breakout.
[/list]

[b]Entry Execution:[/b]
[list]
[*]Long entry: on the confirming candle after a wick-touch above the pre-market high.
[*]Short entry: on the confirming candle after a wick-touch below the pre-market low.
[*]Only the first valid entry per direction per day is taken.
[/list]

[b]Visuals & Alerts:[/b]
[list]
[*]Box represents pre-market high/low.
[*]Top/bottom box border lines show the pre-market high / low levels cleanly.
[*]BUY/SELL markers are pinned to the confirming candle.
[*]Added a "YOLO" marker on breakout candle.
[*]Alert conditions trigger when a breakout is confirmed by the retest.
[/list]

[b]Strategy Type:[/b]
[list]
[*]Momentum breakout strategy with confirmation retest.
[*]Combines pre-market structure and risk-managed entries.
[*]Designed to filter false breakouts by requiring confirmation on the candle after the wick-touch.
[/list]

In short, it’s a pre-market breakout momentum strategy: it uses the pre-market high/low as reference, waits for a breakout, and then enters only after a confirmation retest, reducing the chance of entering on a false spike.

Always use good risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © OhRayOhRay
// @version=6
strategy("Tristan's Box: Pre-Market Range Breakout + Retest", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=2)

// ----- INPUTS -----
allowLong = input.bool(true, "Allow Longs")
allowShort = input.bool(true, "Allow Shorts")
useStop = input.bool(false, "Use stop loss / take profit")
stopPerc = input.float(1.5, "Stop loss (%)", step=0.1)
tpPerc = input.float(3.0, "Take profit (%)", step=0.1)

boxColor = input.color(color.new(color.blue,85), "Pre-market box color")
borderColor = input.color(color.blue, "Pre-market box border color")
lineColor  = input.color(color.blue, "Pre-market outline line color")

// ----- COMPUTE ET TIMES -----
y = year(time)
mo = month(time)
d = dayofmonth(time)
preStartET = timestamp("America/New_York", y, mo, d, 4, 0)
preEndET   = timestamp("America/New_York", y, mo, d, 9, 30)
marketStartET = preEndET
marketEndET   = timestamp("America/New_York", y, mo, d, 16, 0)

inPre = (time >= preStartET) and (time < preEndET)
inMarket = (time >= marketStartET) and (time < marketEndET)

// detect new day
dayETStart = timestamp("America/New_York", y, mo, d, 0, 0)
isNewDayET = ta.change(dayETStart) != 0

// ----- COLLECT PRE-MARKET HIGH / LOW -----
var float preHigh = na
var float preLow = na
var bool preCaptured = false

if isNewDayET
    preHigh := na
    preLow := na
    preCaptured := false

if inPre
    preHigh := na(preHigh) ? high : math.max(preHigh, high)
    preLow  := na(preLow)  ? low  : math.min(preLow, low)

// track transitions
var bool wasInPre = false
justLeftPre = wasInPre and not inPre
wasInPre := inPre

var bool wasInMarket = false
justLeftMarket = wasInMarket and not inMarket
wasInMarket := inMarket

// ----- DRAW PRE-MARKET BOX WITH EXTENDED EDGES -----
var box preBox = na
var int preBoxStartBar = na

if justLeftPre and not preCaptured and not na(preHigh) and not na(preLow)
    if not na(preBox)
        box.delete(preBox)

    preBoxStartBar := math.max(bar_index - 1, 0)
    preBox := box.new(left=preBoxStartBar, right=bar_index, top=preHigh, bottom=preLow, border_color=borderColor, bgcolor=boxColor)
    preCaptured := true

// Extend box to end of session + 1 bar to right
if justLeftMarket and preCaptured and not na(preBox)
    box.set_right(preBox, bar_index)

// ----- DRAW VISUAL OUTLINE LINES (TOP/BOTTOM) -----
var line topLine = na
var line bottomLine = na

if justLeftPre and not na(preHigh) and not na(preLow)
    if not na(topLine)
        line.delete(topLine)
    if not na(bottomLine)
        line.delete(bottomLine)
    
    topLine := line.new(x1=preBoxStartBar, y1=preHigh, x2=bar_index, y2=preHigh, xloc=xloc.bar_index, extend=extend.none, color=lineColor, width=1)
    bottomLine := line.new(x1=preBoxStartBar, y1=preLow, x2=bar_index, y2=preLow, xloc=xloc.bar_index, extend=extend.none, color=lineColor, width=1)

if justLeftMarket and not na(topLine) and not na(bottomLine)
    line.set_x2(topLine, bar_index)
    line.set_x2(bottomLine, bar_index)

// ----- BREAKOUT LOGIC -----
var bool breakoutUp = false
var int breakoutUpBar = na
var bool breakoutDown = false
var int breakoutDownBar = na
var bool enteredLongToday = false
var int longEntryBar = na
var bool enteredShortToday = false
var int shortEntryBar = na

if isNewDayET
    breakoutUp := false
    breakoutDown := false
    breakoutUpBar := na
    breakoutDownBar := na
    enteredLongToday := false
    longEntryBar := na
    enteredShortToday := false
    shortEntryBar := na

if inMarket and preCaptured
    if allowLong and not breakoutUp and close > preHigh
        breakoutUp := true
        breakoutUpBar := bar_index
    if allowShort and not breakoutDown and close < preLow
        breakoutDown := true
        breakoutDownBar := bar_index

// ----- RETEST LOGIC: wick-touch then next candle closes outside box -----
var int wickTouchUpBar = na
var int wickTouchDownBar = na

if breakoutUp and not enteredLongToday and low <= preHigh and high >= preHigh and (bar_index > nz(breakoutUpBar,0))
    wickTouchUpBar := bar_index

if breakoutDown and not enteredShortToday and high >= preLow and low <= preLow and (bar_index > nz(breakoutDownBar,0))
    wickTouchDownBar := bar_index

// next candle after wick-touch
retestUpCandle = not na(wickTouchUpBar) and bar_index == wickTouchUpBar + 1
retestDownCandle = not na(wickTouchDownBar) and bar_index == wickTouchDownBar + 1

enterLongNow = retestUpCandle and close > preHigh
enterShortNow = retestDownCandle and close < preLow

// ----- ENTRY -----
if enterLongNow and allowLong and not enteredLongToday
    strategy.entry("Long entry", strategy.long)
    enteredLongToday := true
    longEntryBar := bar_index
    if useStop
        strategy.exit("XL", "Long_PM_Retest", stop=close*(1-stopPerc/100), limit=close*(1+tpPerc/100))

if enterShortNow and allowShort and not enteredShortToday
    strategy.entry("Short entry", strategy.short)
    enteredShortToday := true
    shortEntryBar := bar_index
    if useStop
        strategy.exit("XS", "Short_PM_Retest", stop=close*(1+stopPerc/100), limit=close*(1-tpPerc/100))

// ----- VISUALS: plot first BUY/SELL markers pinned to confirming candle -----
plotshape(series=(longEntryBar==bar_index ? low : na), title="LongEntryMarker", style=shape.labelup, text="📈 BUY", location=location.belowbar, color=color.new(color.green,0), textcolor=color.white, size=size.normal)
plotshape(series=(shortEntryBar==bar_index ? high : na), title="ShortEntryMarker", style=shape.labeldown, text="📉 SELL", location=location.abovebar, color=color.new(color.red,0), textcolor=color.white, size=size.normal)

// breakout markers on breakout bar
plotshape(series=(breakoutUpBar==bar_index ? preHigh : na), title="BreakoutUpMarker", style=shape.triangleup, location=location.absolute, color=color.green, size=size.small)
plotshape(series=(breakoutDownBar==bar_index ? preLow : na), title="BreakoutDownMarker", style=shape.triangledown, location=location.absolute, color=color.red, size=size.small)

// ----- ALERTS -----
alertcondition(condition=enterLongNow, title="PreHigh Retest BUY", message="Pre-market high retested — BUY signal")
alertcondition(condition=enterShortNow, title="PreLow Retest SELL", message="Pre-market low retested — SELL signal")

// ----- YOLO MARKER ON FIRST BREAKOUT -----
var bool yoloPlottedUp = false
var bool yoloPlottedDown = false

// Long breakout
if breakoutUp and not yoloPlottedUp and close > preHigh
    label.new(bar_index, high, "🎲 YOLO", style=label.style_label_down, color=color.new(color.rgb(136, 219, 139),0), textcolor=color.black, size=size.tiny)
    yoloPlottedUp := true

// Short breakout
if breakoutDown and not yoloPlottedDown and close < preLow
    label.new(bar_index, low, "🎲 YOLO", style=label.style_label_up, color=color.new(color.rgb(240, 127, 136),0), textcolor=color.black, size=size.tiny)
    yoloPlottedDown := true

// Reset at new day
if isNewDayET
    yoloPlottedUp := false
    yoloPlottedDown := false
````

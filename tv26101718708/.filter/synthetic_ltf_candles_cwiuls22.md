# Synthetic LTF Candles

- url: https://www.tradingview.com/script/cWIULS22-Synthetic-LTF-Candles/
- type: indicator
- pine_id: PUB;17ec7a77604d4957b61732c1b925b41b
- version: 2.0

## Description

[i]Inspired by and adapted from [url=https://www.tradingview.com/script/HsO1bxqX-LTF-Candle-Insights-Zeiierman/]LTF Candle Insights by Zeiierman[/url], which introduced the concept of overlaying lower timeframe candles onto a higher timeframe chart. This script extends that idea by solving a specific limitation: TradingView only supports a fixed set of second-based timeframes (1S, 5S, 10S, 15S, 30S, 45S), meaning many second-based intervals do not exist natively. This indicator builds them anyway.

The 200S default is directly inspired by [url=https://x.com/OkalaNQT]Okala's[/url] 80/20 framework for trading NQ futures on the 10-minute timeframe. In that methodology the 10-minute candle is divided into three equal sections of approximately 200 seconds each (600 seconds / 3), giving a cleaner read of how each candle is constructed in thirds before it closes.[/i]

[b]How It Works[/b]
The script uses 10S as its base unit, the finest second-based resolution available on higher chart timeframes, and aggregates those bars into rolling buckets of your chosen length. When a bucket is full a completed synthetic candle is emitted and the bucket resets. The bucket persists across chart bars so candle boundaries are counted in real seconds rather than aligning to chart bar boundaries.

Because 10S is the base unit, the synthetic candle length should be set to a multiple of 10 (e.g. 200, 90, 300) to ensure clean and consistent candle boundaries.

The live forming candle merges the current partial bucket with the real-time tick, so it updates on every price tick rather than waiting for each 10S bar to close.

Key differences from Zeiierman's original:
[list]
[*]Any second interval can be specified and the script builds those candles by aggregating 10S base bars, working around TradingView's native TF restrictions
[*]The forming candle updates in real time on every price tick, not only when a lower-TF bar closes
[/list]

[b]Settings[/b]
[list]
[*][b]Seconds per synthetic candle[/b] - candle length in seconds, should be a multiple of 10. Default 200
[*][b]Amount of candles[/b] - how many completed candles to display. A live forming candle is always shown to the right
[*][b]Dn / Up colours[/b] - separate body and wick colours for bearish and bullish candles
[*][b]Location offset[/b] - how far to the right of the last chart bar the panel is drawn
[/list]

[b]Limitations[/b]
[list]
[*]10S intrabar data requires a chart timeframe of 1 minute or higher and will not function on sub-minute charts
[*]TradingView caps the number of intrabar bars returned per chart bar. On a 10-minute chart this is not a concern but on very high timeframes fewer candles may appear
[*]Candle boundaries may not align perfectly to session opens
[/list]

## Source Code

````pine
//@version=6
// Inspired by and adapted from:
//   "LTF Candle Insights" by Zeiierman
//   https://www.tradingview.com/script/HsO1bxqX-LTF-Candle-Insights-Zeiierman/
//
// Key differences from Zeiierman's original:
//   - Builds SYNTHETIC second-based candles (e.g. 200S) that TradingView does
//     not natively support, by aggregating confirmed 10S intrabar data into
//     custom-length buckets.
//   - Adds a LIVE (in-progress) candle that updates tick-by-tick using the
//     current bar's open/high/low/close merged with the partial bucket state,
//     rather than only drawing candles once a lower-TF bar has fully closed.
// =============================================================================


//@version=6
indicator("Synthetic LTF Candles", "LTF", overlay = true, max_bars_back = 500, max_boxes_count = 500, max_lines_count = 500)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
secondsPerCandle = input.int(200, "Seconds per synthetic candle", minval = 10, step = 10, group = "Synthetic LTF")
numb             = input.int(10, "Amount of Candles", minval = 1, maxval = 100, group = "Synthetic LTF")

dn_col  = input.color(color.new(color.red,  10), title = "Dn",   inline = "Candles", group = "Synthetic LTF")
dn_wick = input.color(color.new(color.red,   0), title = "Wick", inline = "Candles", group = "Synthetic LTF")
up_col  = input.color(color.new(color.lime, 10), title = "Up",   inline = "Candles", group = "Synthetic LTF")
up_wick = input.color(color.new(color.lime,  0), title = "Wick", inline = "Candles", group = "Synthetic LTF")

loc = input.int(3, "Location offset (bars)", group = "Location Settings")

//------------------------------------------------------------------------------
// Settings
//------------------------------------------------------------------------------
BASE_TF  = "10S"
bucketMs = secondsPerCandle * 1000

//------------------------------------------------------------------------------
// Lower timeframe arrays for current parent candle
//------------------------------------------------------------------------------
ltfT = request.security_lower_tf(syminfo.tickerid, BASE_TF, time)
ltfO = request.security_lower_tf(syminfo.tickerid, BASE_TF, open)
ltfH = request.security_lower_tf(syminfo.tickerid, BASE_TF, high)
ltfL = request.security_lower_tf(syminfo.tickerid, BASE_TF, low)
ltfC = request.security_lower_tf(syminfo.tickerid, BASE_TF, close)

//------------------------------------------------------------------------------
// Confirmed synthetic candle history
//------------------------------------------------------------------------------
var array<float> histO = array.new<float>()
var array<float> histH = array.new<float>()
var array<float> histL = array.new<float>()
var array<float> histC = array.new<float>()

var int lastCommittedParentTime = na

//------------------------------------------------------------------------------
// Drawing storage
//------------------------------------------------------------------------------
var array<box>  drawnBodies = array.new<box>()
var array<line> drawnWickH  = array.new<line>()
var array<line> drawnWickL  = array.new<line>()

//------------------------------------------------------------------------------
// Current parent synthetic buckets
//------------------------------------------------------------------------------
array<float> curO = array.new<float>()
array<float> curH = array.new<float>()
array<float> curL = array.new<float>()
array<float> curC = array.new<float>()

int   activeKey = na
float activeO   = na
float activeH   = na
float activeL   = na
float activeC   = na

if ltfO.size() > 0
    for i = 0 to ltfO.size() - 1
        t10 = ltfT.get(i)
        o10 = ltfO.get(i)
        h10 = ltfH.get(i)
        l10 = ltfL.get(i)
        c10 = ltfC.get(i)

        offsetMs = math.max(t10 - time, 0)
        thisKey  = int(math.floor(offsetMs / bucketMs))

        if na(activeKey)
            activeKey := thisKey
            activeO   := o10
            activeH   := h10
            activeL   := l10
            activeC   := c10

        else if thisKey != activeKey
            curO.push(activeO)
            curH.push(activeH)
            curL.push(activeL)
            curC.push(activeC)

            activeKey := thisKey
            activeO   := o10
            activeH   := h10
            activeL   := l10
            activeC   := c10

        else
            activeH := math.max(activeH, h10)
            activeL := math.min(activeL, l10)
            activeC := c10

    if not na(activeO)
        curO.push(activeO)
        curH.push(activeH)
        curL.push(activeL)
        curC.push(activeC)
else
    curO.push(open)
    curH.push(high)
    curL.push(low)
    curC.push(close)

//------------------------------------------------------------------------------
// Commit confirmed parent candle buckets to history once only
//------------------------------------------------------------------------------
shouldCommit = barstate.isconfirmed and (na(lastCommittedParentTime) or time != lastCommittedParentTime)

if shouldCommit
    for i = 0 to curO.size() - 1
        histO.push(curO.get(i))
        histH.push(curH.get(i))
        histL.push(curL.get(i))
        histC.push(curC.get(i))

    // Keep more than displayed amount so live buckets can be appended then trimmed
    histLimit = numb + 20

    while histO.size() > histLimit
        histO.shift()
        histH.shift()
        histL.shift()
        histC.shift()

    lastCommittedParentTime := time

//------------------------------------------------------------------------------
// Build display arrays
//------------------------------------------------------------------------------
array<float> drawO = array.new<float>()
array<float> drawH = array.new<float>()
array<float> drawL = array.new<float>()
array<float> drawC = array.new<float>()

if histO.size() > 0
    for i = 0 to histO.size() - 1
        drawO.push(histO.get(i))
        drawH.push(histH.get(i))
        drawL.push(histL.get(i))
        drawC.push(histC.get(i))

// Only append current parent buckets while the parent candle is live.
// If confirmed, they are already committed into history.
if not barstate.isconfirmed
    for i = 0 to curO.size() - 1
        drawO.push(curO.get(i))
        drawH.push(curH.get(i))
        drawL.push(curL.get(i))
        drawC.push(curC.get(i))

while drawO.size() > numb
    drawO.shift()
    drawH.shift()
    drawL.shift()
    drawC.shift()

//------------------------------------------------------------------------------
// Clear previous drawings
//------------------------------------------------------------------------------
while drawnBodies.size() > 0
    drawnBodies.shift().delete()

while drawnWickH.size() > 0
    drawnWickH.shift().delete()

while drawnWickL.size() > 0
    drawnWickL.shift().delete()

//------------------------------------------------------------------------------
// Draw synthetic candles
//------------------------------------------------------------------------------
b = bar_index
d = loc

if drawO.size() > 0
    for i = 0 to drawO.size() - 1
        o = drawO.get(i)
        h = drawH.get(i)
        l = drawL.get(i)
        c = drawC.get(i)

        isBear     = o > c
        bodyTop    = math.max(o, c)
        bodyBottom = math.min(o, c)
        bodyCol    = isBear ? dn_col  : up_col
        wickCol    = isBear ? dn_wick : up_wick

        x1 = b + d * 2 + loc
        xm = b + d * 2 + 1 + loc
        x2 = b + d * 2 + 2 + loc

        drawnBodies.push(box.new(x1, bodyTop, x2, bodyBottom, border_color = color(na), bgcolor = bodyCol))
        drawnWickH.push(line.new(xm, bodyTop,    xm, h, color = wickCol))
        drawnWickL.push(line.new(xm, bodyBottom, xm, l, color = wickCol))

        d += 2
````

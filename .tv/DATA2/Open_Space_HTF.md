<!-- tradingview-pine-id: PUB;4299f0477eba4a91a57c2011744b4f7a -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Open Space (HTF)

Source: https://www.tradingview.com/script/TqY3ixLA-Open-Space-PAID-HTF/

## Description

this indicator marks out two things at once: open space boxes on your selected timeframe, and fair value gaps one timeframe below it.

the idea is simple. higher timeframe open space shows you where price has room to move. the lower timeframe fair value gaps show you the imbalances inside that space. you get the bigger picture and the finer detail on the same chart without having to flip back and forth.

how the timeframe pairing works

you pick one timeframe. the indicator handles the rest.

1 month open space → 1 week fair value gaps
1 week → 1 day
1 day → 4 hour
4 hour → 2 hour
2 hour → 1 hour
1 hour → 15 min

so if you select 4 hour, you get 4 hour open space and 2 hour fair value gaps together. there's an override in settings if you want to break the pairing, but it runs on auto by default.

no overlapping boxes

overlapping boxes on the same layer get merged into one. if a fair value gap sits fully inside an open space box, it gets dropped since it doesn't add anything there. partial overlaps get trimmed so you only see the part that matters. the chart stays clean.

price anchored

every box is locked to actual price values and actual bar times. zoom in, zoom out, drag the chart around, the levels stay where they belong.

settings

separate color, opacity, and border controls for each layer so you can tell open space from fair value gaps at a glance. timeframe selector with auto pairing or manual override.

how i use it

levels first, entries second. these boxes are where i mark my zones, not where i take blind entries. i want price to react at the level and confirm before i do anything. open space tells me where there's room. the fair value gaps tell me where the imbalance sits inside it. confirmation still comes from structure and the actual reaction at the level.

this is not a signal indicator. it doesn't tell you to buy or sell. it marks levels so you can build your own plan around them.

---

## Source Code

````pine
//@version=6
indicator("Open Space (HTF)", shorttitle="Open Space", overlay=true, max_boxes_count=500, max_lines_count=500)

htf      = input.timeframe("W", "Higher Timeframe", group="Settings")
minRun   = input.int(2, "Minimum consecutive candles", minval=2, group="Settings")
maxBoxes = input.int(150, "Max boxes kept on chart", minval=5, maxval=490, group="Settings")

boxColor    = input.color(color.new(color.gray, 80), "Box Fill", group="Style")
showMid     = input.bool(true, "Show Midline", group="Style")
midColor    = input.color(color.red, "Midline Color", group="Style")
midWidth    = input.int(2, "Midline Width", minval=1, maxval=4, group="Style")

[hO, hH, hL, hC, hT] = request.security(syminfo.tickerid, htf, [open, high, low, close, time])

// The [1] offset at the instant the HTF rolls over is the just-closed HTF
// candle, so detection only ever acts on confirmed bars and never repaints.
newHtf = hT != hT[1]
htfO = hO[1]
htfH = hH[1]
htfL = hL[1]
htfC = hC[1]
htfT = hT[1]
col  = htfC > htfO ? 1 : htfC < htfO ? -1 : 0

var int   runColor     = 0
var int   runLen       = 0
var float runBeforeHi  = na
var float runBeforeLo  = na
var int   runStartTime = na
var float prevHigh     = na
var float prevLow      = na

var box[]   boxIds  = array.new<box>()
var line[]  lineIds = array.new<line>()
var float[] boxTops = array.new<float>()
var float[] boxBots = array.new<float>()

overlapsExisting(topCandidate, botCandidate) =>
    bool found = false
    if array.size(boxTops) > 0
        for i = 0 to array.size(boxTops) - 1
            t2 = array.get(boxTops, i)
            b2 = array.get(boxBots, i)
            if topCandidate > b2 and t2 > botCandidate
                found := true
                break
    found

bool boxCreated = false

if newHtf and not na(htfT)
    if col != 0 and col == runColor
        runLen += 1
    else
        if runLen >= minRun and col != 0 and col == -runColor and not na(runBeforeHi)
            float top = na
            float bot = na
            if runColor == -1
                top := runBeforeLo
                bot := htfH
            else
                top := htfL
                bot := runBeforeHi
            if not na(top) and not na(bot) and top > bot and not overlapsExisting(top, bot)
                if array.size(boxTops) >= maxBoxes
                    box.delete(array.shift(boxIds))
                    line.delete(array.shift(lineIds))
                    array.shift(boxTops)
                    array.shift(boxBots)
                bx = box.new(left=runStartTime, top=top, right=time, bottom=bot, xloc=xloc.bar_time, bgcolor=boxColor, border_color=na, extend=extend.right)
                array.push(boxIds, bx)
                array.push(boxTops, top)
                array.push(boxBots, bot)
                mid = (top + bot) / 2
                midLineColor = showMid ? midColor : color.new(color.white, 100)
                ln = line.new(x1=runStartTime, y1=mid, x2=time, y2=mid, xloc=xloc.bar_time, color=midLineColor, width=midWidth, style=line.style_solid, extend=extend.right)
                array.push(lineIds, ln)
                boxCreated := true
        if col != 0
            runColor := col
            runLen := 1
            runBeforeHi := prevHigh
            runBeforeLo := prevLow
            runStartTime := htfT
        else
            runColor := 0
            runLen := 0
    prevHigh := htfH
    prevLow  := htfL

alertcondition(boxCreated, title="New Open Space", message="New Open Space level formed")
````

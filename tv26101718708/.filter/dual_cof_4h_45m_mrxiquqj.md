# Dual COF (4H + 45m)

- url: https://www.tradingview.com/script/Mrxiquqj-Dual-COF-4H-45m/
- type: indicator
- pine_id: PUB;d2129f7e1b7240399d3e260e6f857b15
- version: 1.0

## Description

This indicator identifies and displays the active Candle of Focus (COF) levels from two timeframes: a higher timeframe, set by default to 4H, and a lower timeframe, set by default to 45 minutes. Instead of drawing rectangular boxes, the indicator draws horizontal rays from the high, low, and optional midpoint of the current active COF candle.
•	The 4H COF rays are thicker by default so they stand out as higher-timeframe context.
•	The 45m COF rays are thinner by default so they can be used as execution or entry-context levels.
•	Only the current active COF for each selected timeframe is displayed. When price closes beyond the active COF high or low, the old rays are deleted and new rays are created from the next COF candle.

## Source Code

````pine
//@version=6
indicator("Dual COF (4H + 45m)", overlay=true, max_lines_count=50)

// INPUTS
tfHTF = input.timeframe("240", "Higher TF COF (4H)")
tfLTF = input.timeframe("45", "Lower TF COF (45m)")

showHTF = input.bool(true, "Show 4H COF Rays")
showLTF = input.bool(true, "Show 45m COF Rays")

showHighLow = input.bool(true, "Show COF High/Low Rays")
showMid = input.bool(true, "Show COF 50% Ray")

htfRayWidth = input.int(3, "4H Ray Width", minval=1, maxval=5)
ltfRayWidth = input.int(1, "45m Ray Width", minval=1, maxval=5)
midRayWidth = input.int(1, "Midline Width", minval=1, maxval=5)

// TIME
barMS = timeframe.in_seconds() * 1000

// ================= TIMEFRAME CHECK =================
isLTFChart = timeframe.period == tfLTF
isHTFChart = timeframe.period == tfHTF

// ================= HTF DATA =================
htfOpen  = isHTFChart ? open[1]  : request.security(syminfo.tickerid, tfHTF, open[1])
htfHigh  = isHTFChart ? high[1]  : request.security(syminfo.tickerid, tfHTF, high[1])
htfLow   = isHTFChart ? low[1]   : request.security(syminfo.tickerid, tfHTF, low[1])
htfClose = isHTFChart ? close[1] : request.security(syminfo.tickerid, tfHTF, close[1])
htfTime  = isHTFChart ? time[1]  : request.security(syminfo.tickerid, tfHTF, time[1])

// ================= LTF DATA =================
ltfOpen  = isLTFChart ? open[1]  : request.security(syminfo.tickerid, tfLTF, open[1])
ltfHigh  = isLTFChart ? high[1]  : request.security(syminfo.tickerid, tfLTF, high[1])
ltfLow   = isLTFChart ? low[1]   : request.security(syminfo.tickerid, tfLTF, low[1])
ltfClose = isLTFChart ? close[1] : request.security(syminfo.tickerid, tfLTF, close[1])
ltfTime  = isLTFChart ? time[1]  : request.security(syminfo.tickerid, tfLTF, time[1])

// ================= NEW BAR =================
htfNew = ta.change(htfTime) != 0
ltfNew = ta.change(ltfTime) != 0

// COLORS
htfColor = htfClose >= htfOpen ? color.rgb(4, 161, 6) : color.rgb(218, 4, 4)
ltfColor = ltfClose >= ltfOpen ? color.rgb(4, 168, 10) : color.rgb(249, 155, 155)

// MIDPOINTS
htfMid = (htfHigh + htfLow) / 2
ltfMid = (ltfHigh + ltfLow) / 2

// STORAGE
var line htfHighRay = na
var line htfLowRay  = na
var line htfMidRay  = na

var line ltfHighRay = na
var line ltfLowRay  = na
var line ltfMidRay  = na

var float htfCofHigh = na
var float htfCofLow  = na

var float ltfCofHigh = na
var float ltfCofLow  = na

// ================= HTF INIT =================
if na(htfCofHigh)
    htfCofHigh := htfHigh
    htfCofLow  := htfLow

    if showHTF and showHighLow
        htfHighRay := line.new(
             htfTime, htfCofHigh,
             htfTime + barMS, htfCofHigh,
             xloc=xloc.bar_time,
             extend=extend.right,
             color=htfColor,
             width=htfRayWidth
        )

        htfLowRay := line.new(
             htfTime, htfCofLow,
             htfTime + barMS, htfCofLow,
             xloc=xloc.bar_time,
             extend=extend.right,
             color=htfColor,
             width=htfRayWidth
        )

    if showHTF and showMid
        htfMidRay := line.new(
             htfTime, htfMid,
             htfTime + barMS, htfMid,
             xloc=xloc.bar_time,
             extend=extend.right,
             color=htfColor,
             style=line.style_dashed,
             width=midRayWidth
        )

// ================= HTF BREAK =================
if htfNew and not na(htfCofHigh)
    if htfClose > htfCofHigh or htfClose < htfCofLow

        if not na(htfHighRay)
            line.delete(htfHighRay)

        if not na(htfLowRay)
            line.delete(htfLowRay)

        if not na(htfMidRay)
            line.delete(htfMidRay)

        htfCofHigh := htfHigh
        htfCofLow  := htfLow

        if showHTF and showHighLow
            htfHighRay := line.new(
                 htfTime, htfCofHigh,
                 htfTime + barMS, htfCofHigh,
                 xloc=xloc.bar_time,
                 extend=extend.right,
                 color=htfColor,
                 width=htfRayWidth
            )

            htfLowRay := line.new(
                 htfTime, htfCofLow,
                 htfTime + barMS, htfCofLow,
                 xloc=xloc.bar_time,
                 extend=extend.right,
                 color=htfColor,
                 width=htfRayWidth
            )

        if showHTF and showMid
            htfMidRay := line.new(
                 htfTime, htfMid,
                 htfTime + barMS, htfMid,
                 xloc=xloc.bar_time,
                 extend=extend.right,
                 color=htfColor,
                 style=line.style_dashed,
                 width=midRayWidth
            )

// ================= LTF INIT =================
if na(ltfCofHigh)
    ltfCofHigh := ltfHigh
    ltfCofLow  := ltfLow

    if showLTF and showHighLow
        ltfHighRay := line.new(
             ltfTime, ltfCofHigh,
             ltfTime + barMS, ltfCofHigh,
             xloc=xloc.bar_time,
             extend=extend.right,
             color=ltfColor,
             width=ltfRayWidth
        )

        ltfLowRay := line.new(
             ltfTime, ltfCofLow,
             ltfTime + barMS, ltfCofLow,
             xloc=xloc.bar_time,
             extend=extend.right,
             color=ltfColor,
             width=ltfRayWidth
        )

    if showLTF and showMid
        ltfMidRay := line.new(
             ltfTime, ltfMid,
             ltfTime + barMS, ltfMid,
             xloc=xloc.bar_time,
             extend=extend.right,
             color=ltfColor,
             style=line.style_dashed,
             width=midRayWidth
        )

// ================= LTF BREAK =================
if ltfNew and not na(ltfCofHigh)
    if ltfClose > ltfCofHigh or ltfClose < ltfCofLow

        if not na(ltfHighRay)
            line.delete(ltfHighRay)

        if not na(ltfLowRay)
            line.delete(ltfLowRay)

        if not na(ltfMidRay)
            line.delete(ltfMidRay)

        ltfCofHigh := ltfHigh
        ltfCofLow  := ltfLow

        if showLTF and showHighLow
            ltfHighRay := line.new(
                 ltfTime, ltfCofHigh,
                 ltfTime + barMS, ltfCofHigh,
                 xloc=xloc.bar_time,
                 extend=extend.right,
                 color=ltfColor,
                 width=ltfRayWidth
            )

            ltfLowRay := line.new(
                 ltfTime, ltfCofLow,
                 ltfTime + barMS, ltfCofLow,
                 xloc=xloc.bar_time,
                 extend=extend.right,
                 color=ltfColor,
                 width=ltfRayWidth
            )

        if showLTF and showMid
            ltfMidRay := line.new(
                 ltfTime, ltfMid,
                 ltfTime + barMS, ltfMid,
                 xloc=xloc.bar_time,
                 extend=extend.right,
                 color=ltfColor,
                 style=line.style_dashed,
                 width=midRayWidth
            )
````

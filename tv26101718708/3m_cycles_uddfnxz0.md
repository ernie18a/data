# 3m Cycles

- url: https://www.tradingview.com/script/uddFNxZ0-3m-Cycles/
- type: indicator
- pine_id: PUB;dfd5e52b0a4949b7bfb8ec69095bb5a6
- version: 1.0

## Description

3m Cycles is a TradingView indicator that draws vertical lines on your chart at fixed clock-based time intervals — every 20 seconds, every 1 minute, and every 3 minutes — to help you visually track recurring market cycles.
Each cycle is fully independent and configurable: you can set the line color, width, and style (solid, dashed, or dotted), control how far back and ahead the lines project, and choose which chart timeframes each cycle appears on. The 3-minute cycle acts as the master clock — all three cycles' visible windows shift forward together every time a new 3-minute boundary is crossed, keeping everything in sync. Lines are pre-drawn into the future so they're already on the chart before the candle forms, and they automatically disappear once they fall outside your configured lookback window.

## Source Code

````pine
//@version=6
indicator("3m Cycles", overlay=true, max_lines_count=500)

// === 20s Cycle Inputs ===
enable20s     = input.bool(true, "Enable 20s Cycle", group="20s Cycle")
color20s      = input.color(color.black, "Line Color", group="20s Cycle")
width20s      = input.int(1, "Line Width", minval=1, maxval=5, group="20s Cycle")
style20sStr   = input.string("Dotted", "Line Style", options=["Solid", "Dashed", "Dotted"], group="20s Cycle")
ahead20s      = input.int(2, "Minutes Ahead", minval=1, maxval=60, group="20s Cycle")
lookback20s   = input.int(4, "Minutes Lookback", minval=1, maxval=60, group="20s Cycle")
minTf20s      = input.timeframe("1S", "Show From (min timeframe)", group="20s Cycle")
maxTf20s      = input.timeframe("1S", "Show Until (max timeframe)", group="20s Cycle")

// === 1m Cycle Inputs ===
enable1min    = input.bool(true, "Enable 1m Cycle", group="1m Cycle")
color1min     = input.color(color.black, "Line Color", group="1m Cycle")
width1min     = input.int(1, "Line Width", minval=1, maxval=5, group="1m Cycle")
style1minStr  = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group="1m Cycle")
ahead1min     = input.int(2, "Minutes Ahead", minval=1, maxval=120, group="1m Cycle")
lookback1min  = input.int(4, "Minutes Lookback", minval=1, maxval=120, group="1m Cycle")
minTf1min     = input.timeframe("1S", "Show From (min timeframe)", group="1m Cycle")
maxTf1min     = input.timeframe("15S", "Show Until (max timeframe)", group="1m Cycle")

// === 3m Cycle Inputs ===
enable3min    = input.bool(true, "Enable 3m Cycle", group="3m Cycle")
color3min     = input.color(color.black, "Line Color", group="3m Cycle")
width3min     = input.int(2, "Line Width", minval=1, maxval=5, group="3m Cycle")
style3minStr  = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group="3m Cycle")
ahead3min     = input.int(3, "Minutes Ahead", minval=1, maxval=120, group="3m Cycle")
lookback3min  = input.int(6, "Minutes Lookback", minval=1, maxval=120, group="3m Cycle")
minTf3min     = input.timeframe("1S", "Show From (min timeframe)", group="3m Cycle")
maxTf3min     = input.timeframe("1", "Show Until (max timeframe)", group="3m Cycle")

// Convert string dropdown choices into Pine's line.style_* constants
style20s  = style20sStr  == "Dashed" ? line.style_dashed : style20sStr  == "Dotted" ? line.style_dotted : line.style_solid
style1min = style1minStr == "Dashed" ? line.style_dashed : style1minStr == "Dotted" ? line.style_dotted : line.style_solid
style3min = style3minStr == "Dashed" ? line.style_dashed : style3minStr == "Dotted" ? line.style_dotted : line.style_solid

// === Each cycle is only shown when the chart's timeframe falls within its configured min/max range ===
chartTfSeconds = timeframe.in_seconds()
isInRange20s   = chartTfSeconds >= timeframe.in_seconds(minTf20s) and chartTfSeconds <= timeframe.in_seconds(maxTf20s)
isInRange1min  = chartTfSeconds >= timeframe.in_seconds(minTf1min) and chartTfSeconds <= timeframe.in_seconds(maxTf1min)
isInRange3min  = chartTfSeconds >= timeframe.in_seconds(minTf3min) and chartTfSeconds <= timeframe.in_seconds(maxTf3min)

// === Persistent state per cycle: a drawing array of lines currently shown ===
var array<line> lines20s    = array.new<line>()
var array<line> lines1min   = array.new<line>()
var array<line> lines3min   = array.new<line>()

// === Track the chart's visible bar range; referencing these triggers recalculation on scroll/zoom ===
visibleLeftMs  = chart.left_visible_bar_time
visibleRightMs = chart.right_visible_bar_time
bool isBarVisible = time >= visibleLeftMs and time <= visibleRightMs

// Running highest/lowest across the visible range. Reset right when we reach the leftmost visible bar
// (which happens exactly once per visible-range scan), then accumulate forward from there.
var float visibleHi = na
var float visibleLo = na

if time == visibleLeftMs
    visibleHi := high
    visibleLo := low
else if isBarVisible
    visibleHi := math.max(visibleHi, high)
    visibleLo := math.min(visibleLo, low)

if barstate.islast
    int msPerSecond = 1000
    int msPerMinute = 60 * msPerSecond
    int msPer3min   = 3 * msPerMinute
    int msPer20s    = 20 * msPerSecond

    int nowMs = time
    var int anchorMs = na
    int currentAnchorCandidate = nowMs - (nowMs % msPer3min)
    bool anchorChanged = na(anchorMs) or currentAnchorCandidate != anchorMs
    if anchorChanged
        anchorMs := currentAnchorCandidate

    if anchorChanged
        while lines20s.size() > 0
            lines20s.shift().delete()
        while lines1min.size() > 0
            lines1min.shift().delete()
        while lines3min.size() > 0
            lines3min.shift().delete()

    float visibleRange = visibleHi - visibleLo
    float hi = visibleHi + visibleRange * 2
    float lo = visibleLo - visibleRange * 2

    if anchorChanged
        if enable20s and isInRange20s
            int mostRecent20s = anchorMs - (anchorMs % msPer20s)
            int startMark20s  = mostRecent20s - lookback20s * msPerMinute
            int horizon20s    = anchorMs + ahead20s * msPerMinute
            int mark20s       = startMark20s
            while mark20s <= horizon20s
                bool landsOnMinuteMark = (mark20s % msPerMinute) == 0
                if not landsOnMinuteMark
                    ln20 = line.new(mark20s, hi, mark20s, lo, xloc=xloc.bar_time, color=color20s, width=width20s, style=style20s, extend=extend.none)
                    lines20s.push(ln20)
                mark20s += msPer20s

        if enable1min and isInRange1min
            int mostRecent1min = anchorMs - (anchorMs % msPerMinute)
            int startMark1min  = mostRecent1min - lookback1min * msPerMinute
            int horizon1min    = anchorMs + ahead1min * msPerMinute
            int mark1min       = startMark1min
            while mark1min <= horizon1min
                bool landsOn3min = (mark1min % msPer3min) == 0
                if not landsOn3min
                    ln1 = line.new(mark1min, hi, mark1min, lo, xloc=xloc.bar_time, color=color1min, width=width1min, style=style1min, extend=extend.none)
                    lines1min.push(ln1)
                mark1min += msPerMinute

        if enable3min and isInRange3min
            int mostRecent3min = anchorMs - (anchorMs % msPer3min)
            int startMark3min  = mostRecent3min - lookback3min * msPerMinute
            int horizon3min    = anchorMs + ahead3min * msPerMinute
            int mark3min       = startMark3min
            while mark3min <= horizon3min
                ln3 = line.new(mark3min, hi, mark3min, lo, xloc=xloc.bar_time, color=color3min, width=width3min, style=style3min, extend=extend.none)
                lines3min.push(ln3)
                mark3min += msPer3min
````

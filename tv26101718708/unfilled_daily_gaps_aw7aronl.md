# Unfilled Daily Gaps

- url: https://www.tradingview.com/script/aw7AronL-Unfilled-Daily-Gaps/
- type: indicator
- pine_id: PUB;f1f39509e25e41088ea156e98513e344
- version: 4.0

## Description

[b]Unfilled Daily Gaps[/b]

Automatically detects and marks unfilled gap-up and gap-down levels between trading sessions. When the market opens above or below the previous session's close, the gap zone is drawn on your chart until price comes back to fill it.

[b]What it draws[/b]
[list]
[]Two horizontal lines marking the exact boundaries of the gap (previous session close and current session open)
[]A dashed midpoint line at the 50% level of the gap
[]A shaded fill between the boundaries for easy visual identification
[]Bullish gaps (gap up) in teal, bearish gaps (gap down) in red
[/list]

[b]How gaps are managed[/b]
[list]
[]Lines are drawn from the exact first traded price of the session — no drift from pre-market auction pricing
[]Each gap is restricted to its own session. Once the next session begins, the lines freeze in place
[*]When price fully fills the gap (returns to the previous session's close level), the gap is automatically removed from the chart
[/list]

[b]Settings[/b]
[list]
[]Bullish / Bearish colors and line width
[]Fill opacity
[]Minimum gap % filter — ignore gaps smaller than a threshold
[]Lookback days — control how far back gaps are shown
[/list]

[b]Works on any instrument and timeframe[/b] — NIFTY, NASDAQ, Forex, Crypto. No timezone configuration needed. Session boundaries are detected automatically from the instrument's exchange session. Best used on intraday (5m, 15m, 30m, 1h, 2h) and daily charts.

## Source Code

````pine
//@version=6
indicator("Unfilled Daily Gaps", overlay=true, max_boxes_count=500, max_lines_count=500)

// === Inputs ===
bullColor    = input.color(color.new(color.teal, 0), "Bullish Gap Color")
bearColor    = input.color(color.new(color.red,  0), "Bearish Gap Color")
fillOpacity  = input.int(85, "Fill Opacity", minval=0, maxval=100)
lineWidth    = input.int(2, "Line Width", minval=1, maxval=4)
showMid      = input.bool(true, "Show 50% Midpoint Line")
showLabels   = input.bool(true, "Show Gap Labels")
minGapPct    = input.float(0.0, "Min Gap % (0 = all gaps)", minval=0.0, step=0.01, tooltip="Filter out gaps smaller than this percentage of the previous close")
lookbackDays = input.int(30, "Lookback (days)", minval=1, tooltip="Only show gaps from the last N calendar days")

// === Session start detection ===
isNewDay = session.isfirstbar_regular

// === Gap tracking arrays ===
var box[]   gapBoxes  = array.new<box>()
var line[]  topLines  = array.new<line>()
var line[]  botLines  = array.new<line>()
var line[]  midLines  = array.new<line>()
var float[] topLevels = array.new<float>()
var float[] botLevels = array.new<float>()
var bool[]  bullFlags = array.new<bool>()
var bool[]  extending = array.new<bool>()  // true while the gap is still in its "next session"
var float   regClose  = na                 // last confirmed regular-session close (not pre-market)

// === Track last regular-session close (extended-hours fix) ===
// session.ismarket is false on pre-market/after-hours bars, so close[1] on
// session.isfirstbar_regular would be a pre-market price when extended hours
// are enabled. Storing it here avoids that false-gap detection.
if session.ismarket and not session.isfirstbar_regular
    regClose := close

// === Update extending gaps to follow the current bar ===
if array.size(extending) > 0
    for i = 0 to array.size(extending) - 1
        if array.get(extending, i)
            box.set_right(array.get(gapBoxes, i), bar_index)
            line.set_x2(array.get(topLines, i), bar_index)
            line.set_x2(array.get(botLines, i), bar_index)
            line.set_x2(array.get(midLines, i), bar_index)

// === Freeze boxes when their next session ends ===
if isNewDay and array.size(extending) > 0
    for i = 0 to array.size(extending) - 1
        if array.get(extending, i)
            array.set(extending, i, false)
            lastBar = bar_index - 1
            box.set_right(array.get(gapBoxes, i), lastBar)
            line.set_x2(array.get(topLines, i), lastBar)
            line.set_x2(array.get(botLines, i), lastBar)
            line.set_x2(array.get(midLines, i), lastBar)

// === Mitigation: remove gaps that price has filled ===
if array.size(gapBoxes) > 0
    for i = array.size(gapBoxes) - 1 to 0
        t    = array.get(topLevels, i)
        b    = array.get(botLevels, i)
        bull = array.get(bullFlags, i)
        if (bull and low <= b) or (not bull and high >= t)
            box.delete(array.get(gapBoxes, i))
            line.delete(array.get(topLines, i))
            line.delete(array.get(botLines, i))
            line.delete(array.get(midLines, i))
            array.remove(gapBoxes,  i)
            array.remove(topLines,  i)
            array.remove(botLines,  i)
            array.remove(midLines,  i)
            array.remove(topLevels, i)
            array.remove(botLevels, i)
            array.remove(bullFlags, i)
            array.remove(extending, i)

// === Detect and draw daily gaps ===
// A genuine gap requires that the first session candle stays entirely on one side
// of the previous close — if the candle's low (bull) or high (bear) crosses the
// previous close, there is no visually empty price region between the sessions.
cutoffTime = timenow - lookbackDays * 24 * 60 * 60 * 1000
if isNewDay and not na(regClose) and time >= cutoffTime
    bull    = open > regClose
    bear    = open < regClose
    genuine = (bull and low > regClose) or (bear and high < regClose)
    if genuine
        gapPct = math.abs(open - regClose) / regClose * 100
        if minGapPct == 0.0 or gapPct >= minGapPct
            topLvl  = bull ? open     : regClose
            botLvl  = bull ? regClose : open
            midLvl  = math.avg(topLvl, botLvl)
            clr     = bull ? bullColor : bearColor
            fillClr = color.new(clr, fillOpacity)
            midClr  = showMid ? color.new(clr, 40) : color.new(clr, 100)
            lblText = showLabels ? (bull ? "Daily Gap+" : "Daily Gap-") : ""
            txtClr  = bull ? color.new(color.teal, 20) : color.new(color.red, 20)
            b  = box.new(bar_index, topLvl, bar_index + 1, botLvl,
                  border_color=color(na), bgcolor=fillClr,
                  text=lblText, text_color=txtClr, text_size=size.small,
                  text_halign=text.align_right, text_valign=text.align_center)
            tl = line.new(bar_index, topLvl, bar_index + 1, topLvl, color=clr, width=lineWidth)
            bl = line.new(bar_index, botLvl, bar_index + 1, botLvl, color=clr, width=lineWidth)
            ml = line.new(bar_index, midLvl, bar_index + 1, midLvl,
                  color=midClr, width=1, style=line.style_dashed)
            array.push(gapBoxes,  b)
            array.push(topLines,  tl)
            array.push(botLines,  bl)
            array.push(midLines,  ml)
            array.push(topLevels, topLvl)
            array.push(botLevels, botLvl)
            array.push(bullFlags, bull)
            array.push(extending, true)
````

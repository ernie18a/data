# Simple PDH/PDL

- url: https://www.tradingview.com/script/jFIoettw/
- type: indicator
- pine_id: PUB;d7b736e2df9a4e2eba86b0685f94b181
- version: 1.0

## Description

Previous Day High/Low (PDH/PDL)
This indicator plots the previous day's high and low on your chart and keeps them live throughout the current session, so you always have yesterday's key levels in front of you while you trade.
How it works: Each level is drawn starting from the exact candle where that high or low actually formed on the prior day. The line then carries forward into the current day and tracks the live price — extending a little ahead of the current candle as it advances — and stops automatically at the end of the day rather than bleeding into the next session.
Key features:

Live tracking with lead: The active level follows the current candle with an adjustable forward projection, hard-capped at end of day.
True origin point: Lines begin at the precise bar where the prior high/low was made, not at an arbitrary session boundary.
Adjustable history: Choose how many past days to display, from just yesterday (1) up to 250 days back.
Fully customizable lines: Set color, width, and style (solid, dashed, or dotted) independently for PDH and PDL, just like standard trend lines.
Configurable labels: Toggle labels on or off, edit the label text (defaults: "PDH" / "PDL"), and control text color and size.
Timeframe-anchored: Levels are positioned by time, so they line up correctly across intraday timeframes (1m up to 4h).

PDH and PDL are among the most widely watched liquidity reference points. Price frequently reacts at these prior-day extremes — sweeping them to grab resting liquidity before reversing, or breaking and retesting them as support/resistance. This tool keeps those levels cleanly mapped and current so you can build your bias and spot reactions at a glance.
Note: Use this on intraday timeframes (1m–4h). It is not designed for daily or higher charts, where intraday high/low tracking isn't possible.

This indicator is a charting tool for technical analysis and does not constitute financial advice.

## Source Code

````pine
//@version=6
indicator("Previous Day High/Low (PDH/PDL)", overlay=true, max_lines_count=500, max_labels_count=500)

// ─── Inputs ───────────────────────────────────────────────
int   daysBack   = input.int(1, "Number of past days to show", minval=1, maxval=250, group="General")
float leadFrac   = input.float(0.05, "Lead ahead of price (fraction of day)", minval=0.0, maxval=0.5, step=0.01, group="General", tooltip="How far the active line projects ahead of the current candle, as a fraction of one day. Capped at end of day.")

// PDH style
grpH = "PDH Line"
colH    = input.color(color.red,   "Color", group=grpH, inline="h1")
widthH  = input.int(1, "Width", minval=1, maxval=5, group=grpH, inline="h1")
styleHi = input.string("Solid", "Style", group=grpH, options=["Solid","Dashed","Dotted"], inline="h2")
showLblH= input.bool(true, "Show label", group=grpH, inline="h3")
txtH    = input.string("PDH", "Label text", group=grpH, inline="h3")

// PDL style
grpL = "PDL Line"
colL    = input.color(color.green, "Color", group=grpL, inline="l1")
widthL  = input.int(1, "Width", minval=1, maxval=5, group=grpL, inline="l1")
styleLo = input.string("Solid", "Style", group=grpL, options=["Solid","Dashed","Dotted"], inline="l2")
showLblL= input.bool(true, "Show label", group=grpL, inline="l3")
txtL    = input.string("PDL", "Label text", group=grpL, inline="l3")

// Label appearance
grpLbl = "Label appearance"
lblCol  = input.color(color.white, "Text color", group=grpLbl, inline="t1")
lblSize = input.string("Normal", "Size", options=["Tiny","Small","Normal","Large","Huge"], group=grpLbl, inline="t1")

// ─── Helpers ──────────────────────────────────────────────
f_style(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

f_size(s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : s == "Huge" ? size.huge : size.normal

// ─── Track current day's high/low + exact times (chart timeframe) ───
var float curHigh  = na
var float curLow   = na
var int   curHighT = na
var int   curLowT  = na
var int   dayOpenT = na

bool newDay = ta.change(time("D")) != 0
int  dayMs  = 86400000

var line[]  hLines = array.new_line()
var line[]  lLines = array.new_line()
var label[] hLbls  = array.new_label()
var label[] lLbls  = array.new_label()

if newDay
    // The day that just finished becomes the "previous day" -> draw it for the new (current) day
    if not na(curHigh)
        lh = line.new(curHighT, curHigh, time, curHigh, xloc=xloc.bar_time, color=colH, width=widthH, style=f_style(styleHi))
        ll = line.new(curLowT,  curLow,  time, curLow,  xloc=xloc.bar_time, color=colL, width=widthL, style=f_style(styleLo))
        array.push(hLines, lh)
        array.push(lLines, ll)

        if showLblH
            lbH = label.new(time, curHigh, txtH, xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=lblCol, size=f_size(lblSize))
            array.push(hLbls, lbH)
        if showLblL
            lbL = label.new(time, curLow, txtL, xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=lblCol, size=f_size(lblSize))
            array.push(lLbls, lbL)

        while array.size(hLines) > daysBack
            line.delete(array.shift(hLines))
            line.delete(array.shift(lLines))
        while array.size(hLbls) > daysBack and showLblH
            label.delete(array.shift(hLbls))
        while array.size(lLbls) > daysBack and showLblL
            label.delete(array.shift(lLbls))

    // Reset trackers for the new day
    curHigh  := high
    curLow   := low
    curHighT := time
    curLowT  := time
    dayOpenT := time
else
    if na(curHigh) or high > curHigh
        curHigh  := high
        curHighT := time
    if na(curLow) or low < curLow
        curLow  := low
        curLowT := time

// ─── On every bar: stretch the active (most recent) line to current price + lead, capped at end of day ───
if array.size(hLines) > 0 and not na(dayOpenT)
    int endOfDay = dayOpenT + dayMs                          // start of next day = hard cap
    int rightT   = math.min(time + int(dayMs * leadFrac), endOfDay)

    line curH = array.get(hLines, array.size(hLines) - 1)
    line curL = array.get(lLines, array.size(lLines) - 1)
    line.set_x2(curH, rightT)
    line.set_x2(curL, rightT)

    if showLblH and array.size(hLbls) > 0
        label.set_x(array.get(hLbls, array.size(hLbls) - 1), rightT)
    if showLblL and array.size(lLbls) > 0
        label.set_x(array.get(lLbls, array.size(lLbls) - 1), rightT)
````

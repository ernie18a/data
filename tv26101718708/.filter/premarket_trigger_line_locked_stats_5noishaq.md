# Premarket Trigger Line (Locked Stats)

- url: https://www.tradingview.com/script/5NoIShAQ-Premarket-Trigger-Line-Locked-Stats/
- type: indicator
- pine_id: PUB;a85e85c33da34d64802ec81e5f2fd857
- version: 1.0

## Description

Premarket Call/Put Trigger Line with Locked Stats

Tracks time and number of closes above/below a custom trigger level during premarket. Stats lock in after 9:30 and remain visible even when Extended Hours are turned off. A customizable horizontal trigger line at any price level you choose that measures how price behaved relative to that level during the premarket session (04:00–09:30 New York time).

Displays:
Call/Put Trigger (price)  ▲ time above (closes above)   ▼ time below (closes below)

## Source Code

````pine
//@version=6
indicator("Premarket Trigger Line (Locked Stats)", overlay=true, max_labels_count=500, max_lines_count=50)

// ─── Inputs ────────────────────────────────────────────────
level           = input.float(185.65, "Call/Put Trigger Level", step=0.01)
sessionInput    = input.session("0400-0930", "Premarket Session")
timezone        = input.string("America/New_York", "Timezone")
lineColor       = input.color(color.blue, "Trigger Line Color")
lineWidth       = input.int(1, "Line Width", minval=1, maxval=4)
lineStyleInput  = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"])
labelSize       = input.string("normal", "Label Size", options=["tiny", "small", "normal", "large", "huge"])

// Convert style
lineStyle = switch lineStyleInput
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_solid

// ─── Force Extended Hours data for calculations ────────────
// This is the key that lets stats survive when you turn ETH off
extTicker = ticker.new(syminfo.prefix, syminfo.ticker, session=session.extended)

// ─── Calculation (always sees premarket) ───────────────────
calcTimes() =>
    inPM = not na(time(timeframe.period, sessionInput, timezone))
    isNewPM = inPM and not inPM[1]
    barSec = timeframe.in_seconds()

    var float secsAbove = 0.0
    var float secsBelow = 0.0
    var int   closesAbove = 0
    var int   closesBelow = 0

    if isNewPM
        secsAbove   := 0.0
        secsBelow   := 0.0
        closesAbove := 0
        closesBelow := 0

    if inPM
        if close > level
            secsAbove   += barSec
            closesAbove += 1
        else if close < level
            secsBelow   += barSec
            closesBelow += 1

    [secsAbove, secsBelow, closesAbove, closesBelow]

[secsAbove, secsBelow, closesAbove, closesBelow] = request.security(extTicker, timeframe.period, calcTimes(), barmerge.gaps_off, barmerge.lookahead_off)

// ─── Format helper ─────────────────────────────────────────
formatTime(sec) =>
    h = int(math.floor(sec / 3600))
    m = int(math.floor((sec % 3600) / 60))
    str.tostring(h) + "h " + str.tostring(m) + "m"

// ─── Persistent line (stays after open & when ETH is off) ──
var line triggerLine = na

// Detect first bar of the day that has the locked values
isNewDay = ta.change(time("D")) != 0

if isNewDay or na(triggerLine)
    if not na(triggerLine)
        line.delete(triggerLine)
    triggerLine := line.new(bar_index, level, bar_index + 1, level,
         color=lineColor, width=lineWidth, style=lineStyle, extend=extend.right)

if not na(triggerLine)
    line.set_color(triggerLine, lineColor)
    line.set_width(triggerLine, lineWidth)
    line.set_style(triggerLine, lineStyle)
    line.set_y1(triggerLine, level)
    line.set_y2(triggerLine, level)

// ─── Locked label (always visible) ─────────────────────────
var label timeLabel = na

labelText = "Call/Put Trigger (" + str.tostring(level) + ")  ▲ " +             formatTime(secsAbove) + " (" + str.tostring(closesAbove) + ")   ▼ " +             formatTime(secsBelow) + " (" + str.tostring(closesBelow) + ")"

if barstate.islast
    if na(timeLabel)
        timeLabel := label.new(bar_index + 3, level, labelText,
             xloc=xloc.bar_index, yloc=yloc.price,
             style=label.style_label_left,
             color=lineColor,
             textcolor=color.white,
             size=labelSize,
             textalign=text.align_left)
    else
        label.set_xy(timeLabel, bar_index + 3, level)
        label.set_text(timeLabel, labelText)
        label.set_color(timeLabel, lineColor)
        label.set_textcolor(timeLabel, color.white)
        label.set_size(timeLabel, labelSize)
````

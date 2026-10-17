# TimeBox

- url: https://www.tradingview.com/script/uvqtUZCs-TimeBox/
- type: indicator
- pine_id: PUB;6924db312456427fac9a54e3cfecb757
- version: 1.0

## Description

timed based candle ranges use for time thirds of completion

## Source Code

````pine
//@version=6
indicator("TimeBox", overlay = true, max_boxes_count = 500, max_labels_count = 200, max_lines_count = 500)

// ─────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────
groupTime = "TimeBox"
displayMode      = input.string("Range", "Display mode", options = ["Range", "Candle"], group = groupTime)

// Interval in MM:SS
intervalMM       = input.int(60, "Interval", minval = 0, maxval = 100000, inline = "INT", group = groupTime)
intervalSS       = input.int(0,  ":",        minval = 0, maxval = 59,     inline = "INT", group = groupTime)

anchorHour       = input.int(23, "Anchor hour (HH)", minval = 0, maxval = 23, inline = "A", group = groupTime)
anchorMinute     = input.int(0,  "Anchor minute (MM)", minval = 0, maxval = 59, inline = "A", group = groupTime)

// Timezone + UTC offset
useExchangeTz    = input.bool(true, "Use exchange timezone", group = groupTime)
userTzInput      = input.string("Etc/UTC", "Anchor timezone (IANA, e.g. Europe/London)", group = groupTime)
anchorTzBase     = useExchangeTz ? syminfo.timezone : userTzInput
utcOffset        = input.int(0, "UTC Offset Hours (-5 to +5)", minval = -5, maxval = 5, group = groupTime)

keepFinished     = input.int(150, "Keep last N finished intervals", minval = 1, maxval = 500, group = groupTime)
projectToEnd     = input.bool(true, "Project developing shapes to interval end", group = groupTime)

// Status style toggles (mix & match)
groupStatus = "Status Style"
showDotStatus     = input.bool(false, "Dot mode (status dot)", group = groupStatus)
showOutlineStatus = input.bool(true,  "Outline mode (status outline colors)", group = groupStatus)

// Range mode colors
groupRange = "Colors (Range Mode)"
finishedBorder = input.color(color.blue, "Finished outline", group = groupRange)
finishedFill   = input.color(color.new(color.blue, 80), "Finished fill", group = groupRange)

devBorder      = input.color(color.gray, "Developing outline (< 1/3)", group = groupRange)
devClearFill   = input.color(color.new(color.gray, 100), "Developing clear fill (< 1/3)", group = groupRange)

warn1Fill      = input.color(color.orange, "After 1/3 fill", group = groupRange)
warn2Fill      = input.color(color.red, "After 2/3 fill", group = groupRange)
warnFillTransp = input.int(75, "Warning fill transparency (0..100)", minval = 0, maxval = 100, group = groupRange)

// Candle mode colors
groupCandle = "Colors (Candle Mode)"
cUpColor     = input.color(color.lime, "Candle up (close ≥ open)", group = groupCandle)
cDownColor   = input.color(color.red,  "Candle down (close < open)", group = groupCandle)
cBodyTransp  = input.int(70, "Candle body transparency (0..100)", minval = 0, maxval = 100, group = groupCandle)
cWickWidth   = input.int(2, "Wick width", minval = 1, maxval = 4, group = groupCandle)

// Dot settings (used when Dot mode is enabled)
groupDot = "Status Dot"
dotSizeOpt = input.string("Small", "Dot size", options = ["Tiny", "Small", "Normal", "Large"], group = groupDot)
dotBase     = input.color(color.gray, "Dot color (< 1/3)", group = groupDot)
dotWarn1    = input.color(color.orange, "Dot color (≥ 1/3)", group = groupDot)
dotWarn2    = input.color(color.red, "Dot color (≥ 2/3)", group = groupDot)
dotDone     = input.color(color.blue, "Dot color (finished)", group = groupDot)

// Countdown
groupTimer = "Countdown"
showTimer  = input.bool(true, "Show countdown", group = groupTimer)
timerPosIn = input.string("Top Right", "Timer position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group = groupTimer)

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────
f_pos(string s) =>
    switch s
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        => position.bottom_right

f_pad2(int x) =>
    x < 10 ? "0" + str.tostring(x) : str.tostring(x)

f_formatMMSS(int ms) =>
    int msClamped = math.max(ms, 0)
    int totalSec  = int(msClamped / 1000)
    int totalMin  = int(totalSec / 60)
    int ss        = int(totalSec % 60)
    str.tostring(totalMin) + ":" + f_pad2(ss)

f_hmsAt(int tMs, string tz) =>
    f_pad2(hour(tMs, tz)) + ":" + f_pad2(minute(tMs, tz)) + ":" + f_pad2(second(tMs, tz))

f_dotStyle(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        => size.large

// ─────────────────────────────────────────────────────────────
// Interval math
// ─────────────────────────────────────────────────────────────
const int MS_PER_SEC  = 1000
const int MS_PER_MIN  = 60000
const int MS_PER_HOUR = 3600000

int intervalTotalSec = math.max(intervalMM * 60 + intervalSS, 1)
int intervalMs       = intervalTotalSec * MS_PER_SEC

// Anchor calendar parts in base timezone
int y  = year(time, anchorTzBase)
int mo = month(time, anchorTzBase)
int d  = dayofmonth(time, anchorTzBase)

// Build anchor in timezone, then shift by utcOffset hours (ms)
int anchorToday = timestamp(anchorTzBase, y, mo, d, anchorHour, anchorMinute, 0) + utcOffset * MS_PER_HOUR
int anchorPrev  = timestamp(anchorTzBase, y, mo, d - 1, anchorHour, anchorMinute, 0) + utcOffset * MS_PER_HOUR
int baseAnchor  = time >= anchorToday ? anchorToday : anchorPrev

int idx           = int((time - baseAnchor) / intervalMs)
int intervalStart = baseAnchor + idx * intervalMs
int intervalEnd   = intervalStart + intervalMs
int midTime       = intervalStart + int(intervalMs / 2)

// Realtime "now"
int nowMs = (barstate.islast and barstate.isrealtime) ? timenow : time_close
bool intervalTimeOver = nowMs >= intervalEnd

// Progress thresholds (based on nowMs)
float progress = float(nowMs - intervalStart) / float(intervalMs)
bool passed1 = progress >= (1.0 / 3.0)
bool passed2 = progress >= (2.0 / 3.0)

// Right edge for developing objects
int rightEdge = (projectToEnd or intervalTimeOver) ? intervalEnd : nowMs

bool isRangeMode  = displayMode == "Range"
bool isCandleMode = displayMode == "Candle"

// Status colors
color statusBorderColor =
     intervalTimeOver ? finishedBorder :
     passed2 ? warn2Fill :
     passed1 ? warn1Fill :
               devBorder

color statusFillColor =
     intervalTimeOver ? finishedFill :
     passed2 ? color.new(warn2Fill, warnFillTransp) :
     passed1 ? color.new(warn1Fill, warnFillTransp) :
               devClearFill

color dotColor =
     intervalTimeOver ? dotDone :
     passed2 ? dotWarn2 :
     passed1 ? dotWarn1 :
               dotBase

// ─────────────────────────────────────────────────────────────
// Per-interval OHLC tracking
// ─────────────────────────────────────────────────────────────
var int   curStart = na
var float curOpen  = na
var float curHigh  = na
var float curLow   = na
var float curClose = na

bool newInterval = na(curStart) or intervalStart != curStart

// ─────────────────────────────────────────────────────────────
// Objects (developing)
// ─────────────────────────────────────────────────────────────
var box   curRangeBox = na

var box   curBody = na
var line  curWick = na

// Extra status outline box (used mainly for Candle mode, optional)
var box curStatusOutlineBox = na

// Status dot label (optional)
var label curDot = na

// Finished object storage (for deletion control)
var box[]  finishedRanges   = array.new_box()
var box[]  finishedBodies   = array.new_box()
var line[] finishedWicks    = array.new_line()
var box[]  finishedOutlines = array.new_box()

// ─────────────────────────────────────────────────────────────
// Finalizers (called on newInterval)
// prevEnd is the end timestamp (ms) of the interval that just finished.
// On the first bar of the next interval, prevEnd == intervalStart.
// ─────────────────────────────────────────────────────────────
f_finalizeRange(box b) =>
    if not na(b)
        box.set_right(b, intervalStart)
        box.set_bgcolor(b, finishedFill)
        box.set_border_color(b, finishedBorder)
        array.push(finishedRanges, b)
        if array.size(finishedRanges) > keepFinished
            box.delete(array.shift(finishedRanges))

f_finalizeBodyWick(box body, line wick) =>
    if not na(body)
        box.set_right(body, intervalStart)
        array.push(finishedBodies, body)
        if array.size(finishedBodies) > keepFinished
            box.delete(array.shift(finishedBodies))
    if not na(wick)
        line.set_x1(wick, intervalStart - int(intervalMs / 2))
        line.set_x2(wick, intervalStart - int(intervalMs / 2))
        array.push(finishedWicks, wick)
        if array.size(finishedWicks) > keepFinished
            line.delete(array.shift(finishedWicks))

f_finalizeOutline(box b) =>
    if not na(b)
        box.set_right(b, intervalStart)
        box.set_bgcolor(b, color.new(color.gray, 100))
        box.set_border_color(b, finishedBorder)
        array.push(finishedOutlines, b)
        if array.size(finishedOutlines) > keepFinished
            box.delete(array.shift(finishedOutlines))

// ─────────────────────────────────────────────────────────────
// Interval transitions
// ─────────────────────────────────────────────────────────────
if newInterval
    // Finalize whichever developing objects exist from the previous interval
    f_finalizeRange(curRangeBox)
    curRangeBox := na

    f_finalizeBodyWick(curBody, curWick)
    curBody := na
    curWick := na

    f_finalizeOutline(curStatusOutlineBox)
    curStatusOutlineBox := na

    if not na(curDot)
        label.delete(curDot)
        curDot := na

    // Reset OHLC for new interval
    curStart := intervalStart
    curOpen  := open
    curHigh  := high
    curLow   := low
    curClose := close
else
    // Update running OHLC inside interval
    curHigh  := na(curHigh) ? high : math.max(curHigh, high)
    curLow   := na(curLow)  ? low  : math.min(curLow, low)
    curClose := close

// ─────────────────────────────────────────────────────────────
// Ensure correct developing objects exist (handles mid-interval toggles)
// ─────────────────────────────────────────────────────────────

// If in Range mode: ensure range box exists; delete candle objects (developing only)
if isRangeMode
    if not na(curBody)
        box.delete(curBody), curBody := na
    if not na(curWick)
        line.delete(curWick), curWick := na
    if not na(curStatusOutlineBox)
        box.delete(curStatusOutlineBox), curStatusOutlineBox := na

    if na(curRangeBox) and not na(curStart)
        curRangeBox := box.new(
            left = intervalStart,
            top = curHigh,
            right = rightEdge,
            bottom = curLow,
            xloc = xloc.bar_time,
            border_color = devBorder,
            bgcolor = devClearFill
        )

// If in Candle mode: ensure candle exists; delete range box (developing only)
if isCandleMode
    if not na(curRangeBox)
        box.delete(curRangeBox), curRangeBox := na

    if na(curBody) and not na(curStart)
        curBody := box.new(
            left = intervalStart,
            top = math.max(curOpen, curClose),
            right = rightEdge,
            bottom = math.min(curOpen, curClose),
            xloc = xloc.bar_time,
            border_color = color.gray,
            bgcolor = color.new(color.gray, 100)
        )
    if na(curWick) and not na(curStart)
        curWick := line.new(
            x1 = midTime, y1 = curHigh,
            x2 = midTime, y2 = curLow,
            xloc = xloc.bar_time,
            color = color.gray,
            width = cWickWidth
        )

    // Optional status outline box around the interval high/low (Candle mode)
    if showOutlineStatus
        if na(curStatusOutlineBox) and not na(curStart)
            curStatusOutlineBox := box.new(
                left = intervalStart,
                top = curHigh,
                right = rightEdge,
                bottom = curLow,
                xloc = xloc.bar_time,
                border_color = statusBorderColor,
                bgcolor = color.new(color.gray, 100) // always clear
            )
    else
        if not na(curStatusOutlineBox)
            box.delete(curStatusOutlineBox), curStatusOutlineBox := na

// Status dot (optional; can be used in Range or Candle mode)
if showDotStatus
    if na(curDot) and not na(curStart)
        curDot := label.new(
            x = midTime,
            y = curHigh,
            xloc = xloc.bar_time,
            yloc = yloc.price,
            style = label.style_circle,
            size = f_dotStyle(dotSizeOpt),
            text = "",
            color = dotColor,
            textcolor = color.new(color.white, 100)
        )
else
    if not na(curDot)
        label.delete(curDot)
        curDot := na

// ─────────────────────────────────────────────────────────────
// Update visuals each bar
// ─────────────────────────────────────────────────────────────

// Range mode box updates
if isRangeMode and not na(curRangeBox)
    box.set_left(curRangeBox, intervalStart)
    box.set_right(curRangeBox, rightEdge)
    box.set_top(curRangeBox, curHigh)
    box.set_bottom(curRangeBox, curLow)

    // Fill always uses clear → orange → red → finished blue
    box.set_bgcolor(curRangeBox, statusFillColor)

    // Outline depends on Outline mode toggle:
    // - ON : grey → orange → red → blue
    // - OFF: constant developing border, finished blue
    color borderCol = showOutlineStatus ? statusBorderColor : (intervalTimeOver ? finishedBorder : devBorder)
    box.set_border_color(curRangeBox, borderCol)

// Candle mode updates (directional candle colors)
if isCandleMode and not na(curBody) and not na(curWick)
    bool up = curClose >= curOpen
    color c = up ? cUpColor : cDownColor

    float bodyTop = math.max(curOpen, curClose)
    float bodyBot = math.min(curOpen, curClose)

    box.set_left(curBody, intervalStart)
    box.set_right(curBody, rightEdge)
    box.set_top(curBody, bodyTop)
    box.set_bottom(curBody, bodyBot)
    box.set_border_color(curBody, c)
    box.set_bgcolor(curBody, color.new(c, cBodyTransp))

    line.set_x1(curWick, midTime)
    line.set_x2(curWick, midTime)
    line.set_y1(curWick, curHigh)
    line.set_y2(curWick, curLow)
    line.set_color(curWick, c)
    line.set_width(curWick, cWickWidth)

// Candle-mode status outline box updates (if enabled)
if isCandleMode and showOutlineStatus and not na(curStatusOutlineBox)
    box.set_left(curStatusOutlineBox, intervalStart)
    box.set_right(curStatusOutlineBox, rightEdge)
    box.set_top(curStatusOutlineBox, curHigh)
    box.set_bottom(curStatusOutlineBox, curLow)
    box.set_border_color(curStatusOutlineBox, statusBorderColor)

// Dot updates (if enabled)
if showDotStatus and not na(curDot)
    label.set_x(curDot, midTime)
    label.set_y(curDot, curHigh)
    label.set_color(curDot, dotColor)

// ─────────────────────────────────────────────────────────────
// Countdown timer to next interval (MM:SS)
// ─────────────────────────────────────────────────────────────
var table t = na
if barstate.isfirst and showTimer
    t := table.new(f_pos(timerPosIn), 1, 1)

if showTimer and not na(t) and barstate.islast
    int msLeft = intervalEnd - nowMs
    string intervalStr = str.tostring(intervalMM) + ":" + f_pad2(intervalSS)
    table.cell(
        t, 0, 0,
        "Interval: " + intervalStr +
        "\nNext TimeBox in: " + f_formatMMSS(msLeft) +
        "\nEnds at: " + f_hmsAt(intervalEnd, anchorTzBase),
        text_halign = text.align_right
    )
````

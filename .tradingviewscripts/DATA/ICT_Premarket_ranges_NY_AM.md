<!-- tradingview-pine-id: PUB;109d4971f1cf44588fb3673ccecf5ce8 -->
<!-- tradingviewscripts-format: 1 -->
# ICT Pre-market ranges (NY AM)

Source: https://www.tradingview.com/script/umVN36NX-ICT-Pre-market-ranges-NY-AM/

## Description

This indicator plots the New York pre-market range — the high-to-low of price action between 07:00 and 09:00 NY time — as a box, with optional internal quarter, eighth, and range-boundary level lines, plus projected fib target lines and shaded target areas.

The two hours before the 09:30 cash open often establish the day's early liquidity and balance. Within ICT (Inner Circle Trader) methodology, the boundaries of this pre-market range and its internal subdivisions act as reference points once the NY AM session begins: price frequently reacts at the range extremes, the 0.5 equilibrium, and the intermediate quarter and eighth levels. Drawing these levels ahead of the open gives a ready-made framework for the session.

What It Plots

Once the 07:00–09:00 NY window closes, the indicator measures the highest high and lowest low of that window (from wicks by default, or candle bodies if you prefer) and draws a box between them. Level lines subdivide the range, and fib target lines project beyond it, so equilibrium, retracement, and extension levels are visible at a glance.

Visual Elements

[*]Peach range box spanning the 07:00–09:00 NY pre-market window
[*]Optional centered box title ("Pre-Market range" plus the weekday and date), with selectable position and font size
[*]Range boundary lines at 0 and 1 (low and high)
[*]Quarter lines at 0.25, 0.5, and 0.75
[*]Eighth lines at 0.125, 0.375, 0.625, and 0.875
[*]Optional extension of level lines toward the trading day end (00:00), tracking the current time
[*]Fib target lines outside the range at ±0.5, ±1.0, ±1.5, ±2.0, and a custom multiple
[*]Optional filled target-area bands per fixed target step — bullish (above the high) and bearish (below the low), each successive band a bit darker
[*]Optional fib labels (0 … 1 and ±targets) beside each line, on the left or right side

How To Use It

[*]Add the indicator to an intraday chart (15m–1H shows the pre-market range and the NY AM session together well).
[*]Watch for reactions at the range high/low, the 0.5 equilibrium, and the quarter/eighth levels during the NY AM session.
[*]Use the ± fib targets and shaded target areas to frame where an expansion out of the range may be heading.
[*]Enable "Extend Levels to Day End" to carry the levels across the whole trading day as reference.
[*]Use "Days to Show" to compare the current pre-market range against previous days.

Settings Overview

[*]General: show/hide box, box title with its position and font size, days to show (1–10), pre-market window time, wicks vs bodies
[*]Level Lines: range lines (0/1), quarter lines (0.25/0.5/0.75), eighth lines, extend to day end, line labels on/off, label side (left/right), label horizontal offset
[*]Fib Target Lines: ±0.5, ±1.0, ±1.5, ±2.0, and a custom multiple; "Fill Target Areas" on/off; bullish and bearish target-band colors
[*]Colors: box fill color, line color, line weight, line style (solid/dashed/dotted), and an optional box border (uses the line color)

Technical Notes

Range detection uses 1-minute intrabar data via request.security_lower_tf(), so the pre-market high and low are captured accurately on any chart timeframe. Boxes and level lines are time-anchored (xloc.bar_time) so past days line up with their real timestamps. The box is fixed to the 07:00–09:00 window; when the day-end extension is enabled, the level lines extend to the current time and are capped at the trading day end (00:00), so they never project past the latest bar. Only weekdays (Monday–Friday) are processed.

---

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════════
//
// ICT Pre-market ranges (NY AM)
// Version: 06/08/2026
//
// ──────────────────────────────────────────────────────────────────────────────
//
// DESCRIPTION:
// Plots the New York pre-market range — the high-low of price action between
// 07:00 and 09:00 NY time — as a box, with optional quarter, eighth, and range
// boundary level lines. Based on ICT (Inner Circle Trader) concepts, the
// pre-market range and its internal quarter/eighth levels act as reference
// points for the NY AM session that follows the 09:30 cash open.
//
// FEATURES:
//   • Live developing range: during the current day's window the box grows from
//     07:00 and expands until 09:00, then stays fixed (stale) afterwards
//   • Peach range box spanning the 07:00–09:00 NY pre-market window
//   • Optional two-line box title (name + weekday and date), position selectable
//   • Range boundary lines (0% / 100%) — toggle
//   • Quarter lines (25% / 50% / 75%) — toggle
//   • Eighth lines (12.5% / 37.5% / 62.5% / 87.5%) — toggle
//   • Fib target lines outside the range (± 0.5 / 1.0 / 1.5 / 2.0 / custom)
//   • Optional filled target-area bands per fixed target step — bullish (above)
//     and bearish (below), each successive band a bit darker
//   • Optional extension of level lines to the current time, capped at the
//     trading day end (00:00)
//   • Optional fib labels (0 … 1) beside each level line — left or right side,
//     with a configurable horizontal offset
//   • Configurable fill color, line color, line weight, line style, and an
//     optional box border
//   • Wicks (high/low) or bodies (open/close) for range measurement
//   • Configurable number of days to display (default 1 = today only)
//   • Weekdays only (Monday–Friday)
//
// TECHNICAL NOTES:
//   • All price data uses 1-minute bars via request.security_lower_tf() for
//     accurate high/low detection across any chart timeframe, and to bind the
//     indicator to the chart's price scale.
//   • Boxes and lines are time-anchored (xloc.bar_time) so past days align to
//     their real timestamps and the day-end extension resolves to a real time.
//   • The finalized box is created once and never modified. Level lines and
//     labels are created once, then only their right edge is extended (on the
//     last bar) to track the current time up to the trading day end.
//   • While the window is still open, a separate "developing" range is drawn on
//     the last bar and delete/recreated each update, so it grows live from 07:00
//     to 09:00. It is removed the moment the finalized range is created.
//
// ──────────────────────────────────────────────────────────────────────────────
//
// AUTHOR: Timo Haapsaari (@hqtimppa)
//
// ══════════════════════════════════════════════════════════════════════════════

indicator("ICT Pre-market ranges (NY AM)", overlay=true, max_boxes_count=500, max_lines_count=500)

// ══════════════════════════════════════════════════════════════════════════════
// CONSTANTS
// ══════════════════════════════════════════════════════════════════════════════

string TZ = "America/New_York"  // All session times reference NY timezone

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS - General Settings
// ══════════════════════════════════════════════════════════════════════════════

grpGeneral = "General Settings"

showBox = input.bool(true, "Show Range Box",
     group=grpGeneral,
     tooltip="Display the filled box spanning the pre-market high-low range. Level lines can still be shown with the box hidden.")

showBoxTitle = input.bool(true, "Show Box Title",
     group=grpGeneral,
     tooltip="Show a centered title inside the box: 'Pre-Market range' on the first line and the weekday and date (e.g. 'Mon 04.08.2026') on the second. Requires the box to be shown.")

boxTitlePos = input.string("Middle", "Box Title Position",
     options=["Above", "Middle", "Below"],
     group=grpGeneral,
     tooltip="Vertical position of the box title inside the box: Above (top), Middle (center), or Below (bottom).")

boxTitleSizeStr = input.string("Medium", "Box Title Size",
     options=["Small", "Medium", "Large"],
     group=grpGeneral,
     tooltip="Font size of the box title. Large matches the previous fixed size.")

daysToShow = input.int(1, "Days to Show",
     minval=1, maxval=10,
     group=grpGeneral,
     tooltip="Number of pre-market ranges to keep on the chart. 1 = today only, 2 = today and yesterday, etc. Weekends are skipped.")

sessionInput = input.session("0700-0900", "Pre-market Window (NY time)",
     group=grpGeneral,
     tooltip="Pre-market range window in HHMM-HHMM format (NY timezone). Default 0700-0900.")

useWicks = input.bool(true, "Use Wicks (uncheck for Bodies)",
     group=grpGeneral,
     tooltip="When enabled, the range is measured from candle wicks (high/low). When disabled, candle bodies (max/min of open/close) are used instead.")

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS - Level Lines
// ══════════════════════════════════════════════════════════════════════════════

grpLevels = "Level Lines"

showRangeLines = input.bool(true, "Show Range Lines (0%, 100%)",
     group=grpLevels,
     tooltip="Display dashed lines at the 0% (low) and 100% (high) range boundaries.")

showQuartiles = input.bool(true, "Show Quarter Lines (25%, 50%, 75%)",
     group=grpLevels,
     tooltip="Display dashed lines at the 25%, 50%, and 75% levels of the range.")

showEighths = input.bool(true, "Show Eighth Lines (12.5%, 37.5%, 62.5%, 87.5%)",
     group=grpLevels,
     tooltip="Display dashed lines at the 12.5%, 37.5%, 62.5%, and 87.5% levels of the range.")

extendToDayEnd = input.bool(false, "Extend Levels to Day End (00:00)",
     group=grpLevels,
     tooltip="When enabled, level lines extend to the right up to the current time, capped at the end of the trading day (the following 00:00 NY) — they never project past the current bar. When disabled, they stop at the end of the pre-market window (09:00).")

showLineLabels = input.bool(false, "Show Line Labels",
     group=grpLevels,
     tooltip="Display a fib label (0, 0.25, 0.5, …, 1) next to each level line, matching the ± target notation.")

labelSide = input.string("Right", "Label Side",
     options=["Left", "Right"],
     group=grpLevels,
     tooltip="Place the level and target labels on the left side (start of the lines) or the right side (end of the lines).")

labelOffset = input.int(2, "Label Horizontal Offset (bars)",
     minval=0, maxval=50,
     group=grpLevels,
     tooltip="Horizontal gap between a line's end and its label, measured in bars.")

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS - Fib Target Lines
// Range-projection targets plotted outside the range (symmetric above the high
// and below the low). Each value is a multiple of the range size.
// ══════════════════════════════════════════════════════════════════════════════

grpFib = "Fib Target Lines"

showFib05 = input.bool(true, "Show ± 0.5",
     group=grpFib,
     tooltip="Plot target lines 0.5× the range above the high and below the low.")

showFib10 = input.bool(false, "Show ± 1.0",
     group=grpFib,
     tooltip="Plot target lines 1.0× the range above the high and below the low.")

showFib15 = input.bool(false, "Show ± 1.5",
     group=grpFib,
     tooltip="Plot target lines 1.5× the range above the high and below the low.")

showFib20 = input.bool(false, "Show ± 2.0",
     group=grpFib,
     tooltip="Plot target lines 2.0× the range above the high and below the low.")

showFibCustom = input.bool(false, "Show ± Custom",
     group=grpFib,
     tooltip="Plot target lines at a custom multiple of the range above the high and below the low. The custom target is drawn as a line only — it does not form a filled band.")

fibCustomValue = input.float(2.5, "Custom Value",
     minval=0.0, step=0.1,
     group=grpFib,
     tooltip="Custom range multiple for the ± Custom target lines.")

showTargetAreas = input.bool(true, "Fill Target Areas",
     group=grpFib,
     tooltip="Shade a filled band for each enabled target step (high→+0.5, +0.5→+1.0, …), above the high and below the low.")

bullTargetColor = input.color(color.new(#A5D6A7, 82), "Bullish Target Color (above)",
     group=grpFib,
     tooltip="Base fill color for the bullish target bands above the range high. Each successive band is drawn a bit darker.")

bearTargetColor = input.color(color.new(#EF9A9A, 82), "Bearish Target Color (below)",
     group=grpFib,
     tooltip="Base fill color for the bearish target bands below the range low. Each successive band is drawn a bit darker.")

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS - Colors
// ══════════════════════════════════════════════════════════════════════════════

grpColors = "Colors"

fillColor = input.color(color.new(#FFCC99, 85), "Fill Color",
     group=grpColors,
     tooltip="Background fill color for the pre-market range box.")

lineColor = input.color(color.new(#000000, 40), "Line Color",
     group=grpColors,
     tooltip="Color for all level lines and, when enabled, the box border.")

lineWidth = input.int(1, "Line Weight",
     minval=1, maxval=4,
     group=grpColors,
     tooltip="Width of all level lines and the box border.")

lineStyleStr = input.string("Solid", "Line Style",
     options=["Solid", "Dashed", "Dotted"],
     group=grpColors,
     tooltip="Style for all level lines.")

showBorder = input.bool(false, "Show Box Border",
     group=grpColors,
     tooltip="Draw a border around the range box using the line color. Off by default.")

// ══════════════════════════════════════════════════════════════════════════════
// TIME INPUT PARSING
// Parse "HHMM-HHMM" session string into hour and minute integers
// ══════════════════════════════════════════════════════════════════════════════

int startHour   = int(str.tonumber(str.substring(sessionInput, 0, 2)))
int startMinute = int(str.tonumber(str.substring(sessionInput, 2, 4)))
int endHour     = int(str.tonumber(str.substring(sessionInput, 5, 7)))
int endMinute   = int(str.tonumber(str.substring(sessionInput, 7, 9)))

// ══════════════════════════════════════════════════════════════════════════════
// LINE STYLE CONVERSION
// ══════════════════════════════════════════════════════════════════════════════

lineStyleValue = switch lineStyleStr
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_solid

boxTitleValign = switch boxTitlePos
    "Above"  => text.align_top
    "Middle" => text.align_center
    "Below"  => text.align_bottom
    => text.align_center

boxTitleSize = switch boxTitleSizeStr
    "Small"  => size.tiny
    "Medium" => size.small
    "Large"  => size.normal
    => size.small

// ══════════════════════════════════════════════════════════════════════════════
// CUSTOM TYPE - Pre-market Range Record
// All drawing objects are time-anchored (xloc.bar_time). Each record is created
// once after the window closes and never modified.
// ══════════════════════════════════════════════════════════════════════════════

type PMRecord
    box          pmBox        // Main range box (07:00–09:00), fixed after creation
    array<line>  lines        // Level lines actually drawn (0/12.5/…/100%)
    array<box>   labels       // Percentage label boxes, parallel to labelYs
    array<float> labelYs      // Price of each label, for repositioning
    array<box>   areas        // Filled target-area bands (extend with the lines)
    int          dayNum       // YYYYMMDD identifier for duplicate prevention
    int          winStartTime // Left edge of the lines (window open, 07:00)
    int          winEndTime   // Right edge when not extending (window close, 09:00)
    int          dayEndTime   // Cap for the extended right edge (following 00:00)

// ══════════════════════════════════════════════════════════════════════════════
// DISPLAY CONSTANTS
// ══════════════════════════════════════════════════════════════════════════════

float quartilePriceOffset = syminfo.mintick * 20                    // Vertical padding for label boxes
int   barMs               = math.max(1, nz(timeframe.in_seconds(), 60)) * 1000  // Approx chart bar duration (ms)
int   labelBoxWidthMs     = barMs * 3                               // Width of the invisible label boxes (ms)

// ══════════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ══════════════════════════════════════════════════════════════════════════════

// Timestamp for a specific hour:minute on the current bar's date (NY timezone)
today_ts(h, m) =>
    timestamp(TZ, year(time, TZ), month(time, TZ), dayofmonth(time, TZ), h, m, 0)

// Unique day identifier (YYYYMMDD) for duplicate detection
getDayNum() =>
    year(time, TZ) * 10000 + month(time, TZ) * 100 + dayofmonth(time, TZ)

// Abbreviated weekday name for a day-of-week constant
getWeekdayName(int d) =>
    switch d
        dayofweek.monday    => "Mon"
        dayofweek.tuesday   => "Tue"
        dayofweek.wednesday => "Wed"
        dayofweek.thursday  => "Thu"
        dayofweek.friday    => "Fri"
        dayofweek.saturday  => "Sat"
        dayofweek.sunday    => "Sun"
        => ""

// Creates a time-anchored level line at a given price, using the selected style
mkLine(int x1, float y, int x2) =>
    line.new(x1=x1, y1=y, x2=x2, y2=y, xloc=xloc.bar_time,
         color=lineColor, style=lineStyleValue, width=lineWidth)

// Appends a level (price + label text) to the parallel build arrays.
// Arrays are passed by reference, so the pushes persist in the caller.
addLevel(array<float> ys, array<string> ts, float y, string t) =>
    array.push(ys, y)
    array.push(ts, t)

// Creates an invisible, time-anchored label box holding percentage/fib text next
// to a level line, on the left (line start) or right (line end) side per labelSide.
mkLabel(int lineLeft, int lineRight, float y, string txt) =>
    bool ll      = labelSide == "Left"
    int  boxLeft = ll ? lineLeft - labelOffset * barMs - labelBoxWidthMs : lineRight + labelOffset * barMs
    box.new(left=boxLeft, top=y + quartilePriceOffset, right=boxLeft + labelBoxWidthMs, bottom=y - quartilePriceOffset,
         xloc=xloc.bar_time, bgcolor=color.new(color.white, 100), border_color=color.new(color.white, 100),
         text=txt, text_color=lineColor, text_halign=(ll ? text.align_right : text.align_left), text_valign=text.align_center, text_size=size.small)

// ══════════════════════════════════════════════════════════════════════════════
// STATE VARIABLES
// ══════════════════════════════════════════════════════════════════════════════

var array<PMRecord> pmRecords = array.new<PMRecord>()  // All finalized ranges

var bool  pm_started = false  // True once the window has produced at least one bar today
var bool  pm_found   = false  // True once today's range has been finalized
var float pm_high    = na     // Running pre-market high
var float pm_low     = na     // Running pre-market low

// ══════════════════════════════════════════════════════════════════════════════
// CALCULATED COLORS
// Border uses the line color; hidden borders are fully transparent
// ══════════════════════════════════════════════════════════════════════════════

color borderColorFinal = showBorder ? lineColor : color.new(lineColor, 100)

// ══════════════════════════════════════════════════════════════════════════════
// SESSION TIME DEFINITIONS
// ══════════════════════════════════════════════════════════════════════════════

int period_start = today_ts(startHour, startMinute)  // 07:00 window open
int period_end   = today_ts(endHour, endMinute)      // 09:00 window close

// ══════════════════════════════════════════════════════════════════════════════
// BUILD ONE PRE-MARKET RANGE (box + levels + fib targets + areas + labels)
// Returns a PMRecord. Used both for the finalized range (fixed box, right=winEnd)
// and the live developing range (box + lines grow to the current time). boxRight
// is the box's right edge; lineRight is the lines'/areas' right edge.
// ══════════════════════════════════════════════════════════════════════════════

buildPMRange(float ph, float pl, int winStart, int boxRight, int lineRight, int winEnd, int dayEnd, int dayNumV) =>
    float rng  = ph - pl
    int   dowV = dayofweek(time, TZ)

    // Box title (two lines): name, then weekday and date (dd.mm.yyyy)
    string boxTitle = ""
    if showBoxTitle
        string dateStr = str.tostring(dayofmonth(time, TZ), "00") + "." + str.tostring(month(time, TZ), "00") + "." + str.tostring(year(time, TZ))
        boxTitle := "Pre-Market range\n" + getWeekdayName(dowV) + " " + dateStr

    box newBox = na
    if showBox
        newBox := box.new(left=winStart, top=ph, right=boxRight, bottom=pl,
             xloc=xloc.bar_time, bgcolor=fillColor, border_color=borderColorFinal,
             text=boxTitle, text_color=color.new(lineColor, 0),
             text_halign=text.align_center, text_valign=boxTitleValign, text_size=boxTitleSize)

    // Build the levels to draw as parallel price + label arrays
    array<float>  levelYs  = array.new<float>()
    array<string> levelTxt = array.new<string>()
    if showRangeLines
        addLevel(levelYs, levelTxt, pl, "0")
        addLevel(levelYs, levelTxt, ph, "1")
    if showQuartiles
        addLevel(levelYs, levelTxt, pl + rng * 0.25, "0.25")
        addLevel(levelYs, levelTxt, pl + rng * 0.50, "0.5")
        addLevel(levelYs, levelTxt, pl + rng * 0.75, "0.75")
    if showEighths
        addLevel(levelYs, levelTxt, pl + rng * 0.125, "0.125")
        addLevel(levelYs, levelTxt, pl + rng * 0.375, "0.375")
        addLevel(levelYs, levelTxt, pl + rng * 0.625, "0.625")
        addLevel(levelYs, levelTxt, pl + rng * 0.875, "0.875")

    // External fib target levels (multiples of the range, symmetric)
    array<float> fibVals = array.new<float>()
    if showFib05
        array.push(fibVals, 0.5)
    if showFib10
        array.push(fibVals, 1.0)
    if showFib15
        array.push(fibVals, 1.5)
    if showFib20
        array.push(fibVals, 2.0)
    if showFibCustom and fibCustomValue > 0
        array.push(fibVals, fibCustomValue)
    for v in fibVals
        addLevel(levelYs, levelTxt, ph + rng * v, "+" + str.tostring(v))
        addLevel(levelYs, levelTxt, pl - rng * v, "-" + str.tostring(v))

    // Target area bands (fixed steps only; each successive band a bit darker)
    array<float> bandVals = array.new<float>()
    if showFib05
        array.push(bandVals, 0.5)
    if showFib10
        array.push(bandVals, 1.0)
    if showFib15
        array.push(bandVals, 1.5)
    if showFib20
        array.push(bandVals, 2.0)

    array<box> recAreas = array.new<box>()
    if showTargetAreas and array.size(bandVals) > 0
        float bullTransp = color.t(bullTargetColor)
        float bearTransp = color.t(bearTargetColor)
        float prevV      = 0.0
        for k = 0 to array.size(bandVals) - 1
            float v       = array.get(bandVals, k)
            color upColor = color.new(bullTargetColor, math.max(10, bullTransp - k * 8))
            color dnColor = color.new(bearTargetColor, math.max(10, bearTransp - k * 8))
            array.push(recAreas, box.new(left=winStart, top=ph + rng * v, right=lineRight, bottom=ph + rng * prevV,
                 xloc=xloc.bar_time, bgcolor=upColor, border_color=color.new(color.white, 100)))
            array.push(recAreas, box.new(left=winStart, top=pl - rng * prevV, right=lineRight, bottom=pl - rng * v,
                 xloc=xloc.bar_time, bgcolor=dnColor, border_color=color.new(color.white, 100)))
            prevV := v

    // Create each level line and, when enabled, its label
    array<line>  recLines  = array.new<line>()
    array<box>   recLabels = array.new<box>()
    array<float> recLabelY = array.new<float>()
    for li = 0 to array.size(levelYs) - 1
        float y = array.get(levelYs, li)
        array.push(recLines, mkLine(winStart, y, lineRight))
        if showLineLabels
            array.push(recLabels, mkLabel(winStart, lineRight, y, array.get(levelTxt, li)))
            array.push(recLabelY, y)

    PMRecord.new(newBox, recLines, recLabels, recLabelY, recAreas, dayNumV, winStart, winEnd, dayEnd)

// ══════════════════════════════════════════════════════════════════════════════
// DAY CHANGE DETECTION & STATE RESET
// ══════════════════════════════════════════════════════════════════════════════

bool new_day       = ta.change(dayofmonth(time, TZ)) != 0
int  currentDayNum = getDayNum()
int  dow           = dayofweek(time, TZ)
bool isTradingDay  = dow != dayofweek.sunday and dow != dayofweek.saturday

if new_day
    pm_started := false
    pm_found   := false
    pm_high    := na
    pm_low     := na

// ══════════════════════════════════════════════════════════════════════════════
// FETCH 1-MINUTE DATA
// CRITICAL: request.security_lower_tf() at global scope binds the indicator to
// the chart's price scale and provides accurate intrabar high/low detection.
// ══════════════════════════════════════════════════════════════════════════════

high_arr  = request.security_lower_tf(syminfo.tickerid, "1", high)   // Wicks high + price-scale binding
low_arr   = request.security_lower_tf(syminfo.tickerid, "1", low)    // Wicks low
open_arr  = request.security_lower_tf(syminfo.tickerid, "1", open)   // Bodies (open)
close_arr = request.security_lower_tf(syminfo.tickerid, "1", close)  // Bodies (close)
time_arr  = request.security_lower_tf(syminfo.tickerid, "1", time)   // Window matching

int arr_size = array.size(high_arr)

// ══════════════════════════════════════════════════════════════════════════════
// ACCUMULATE PRE-MARKET RANGE (07:00–09:00)
// Track running high/low of all 1-minute bars within the window (weekdays only).
// ══════════════════════════════════════════════════════════════════════════════

if not pm_found and isTradingDay and arr_size > 0
    for i = 0 to arr_size - 1
        int bar_time = array.get(time_arr, i)
        if bar_time >= period_start and bar_time < period_end
            float hi = useWicks ? array.get(high_arr, i) : math.max(array.get(open_arr, i), array.get(close_arr, i))
            float lo = useWicks ? array.get(low_arr, i)  : math.min(array.get(open_arr, i), array.get(close_arr, i))
            if na(pm_high)
                pm_high    := hi
                pm_low     := lo
                pm_started := true
            else
                pm_high := math.max(pm_high, hi)
                pm_low  := math.min(pm_low, lo)

// ══════════════════════════════════════════════════════════════════════════════
// FINALIZE & CREATE VISUALIZATION
// Once the window has closed, create the box and level lines for the day.
// ══════════════════════════════════════════════════════════════════════════════

if not pm_found and pm_started and not na(pm_high)
    // Determine whether the window has closed
    bool session_ended = false
    if arr_size > 0 and array.get(time_arr, arr_size - 1) >= period_end
        session_ended := true
    if time >= period_end
        session_ended := true

    if session_ended
        pm_found := true

        // Duplicate prevention
        bool already_exists = false
        for rec in pmRecords
            if rec.dayNum == currentDayNum
                already_exists := true
                break

        if not already_exists and pm_high != pm_low
            // Time anchors for horizontal placement.
            // Day end = the following 00:00 NY. Computed by stepping ~36h from
            // today's midnight (safely into the next calendar day regardless of
            // DST) and re-flooring to that day's midnight — avoids relying on
            // timestamp() day-overflow normalization and is DST-safe.
            int winStart      = period_start
            int winEnd        = period_end
            int todayMidnight = timestamp(TZ, year(time, TZ), month(time, TZ), dayofmonth(time, TZ), 0, 0, 0)
            int nextDayInside = todayMidnight + 129600000  // + 36 hours → noon of the next day
            int dayEndTime    = timestamp(TZ, year(nextDayInside, TZ), month(nextDayInside, TZ), dayofmonth(nextDayInside, TZ), 0, 0, 0)
            // Lines extend to the current time, capped at day end; window close otherwise.
            // The barstate.islast update loop grows this for the current day.
            int lineRight     = extendToDayEnd ? (timenow < dayEndTime ? timenow : dayEndTime) : winEnd

            // Finalized range: box fixed to the 07:00–09:00 window (right=winEnd),
            // lines/areas to lineRight. Immutable from here on.
            array.push(pmRecords, buildPMRange(pm_high, pm_low, winStart, winEnd, lineRight, winEnd, dayEndTime, currentDayNum))

// ══════════════════════════════════════════════════════════════════════════════
// DEVELOPING RANGE (live, last bar only)
// While today's window is still open (started, not yet finalized), draw a range
// that grows from 07:00 to the current time and expands with the running
// high/low. Delete/recreated each update, and removed once the range finalizes.
// ══════════════════════════════════════════════════════════════════════════════

var PMRecord devRec = na

if barstate.islast
    // Clear the previous developing drawing
    if not na(devRec)
        box.delete(devRec.pmBox)
        for ln in devRec.lines
            line.delete(ln)
        for lb in devRec.labels
            box.delete(lb)
        for ar in devRec.areas
            box.delete(ar)
        devRec := na
    // Redraw while the window is in progress today
    bool inWindow = isTradingDay and pm_started and not pm_found and not na(pm_high) and pm_high != pm_low
    if inWindow
        int devRight = timenow < period_end ? timenow : period_end
        devRec := buildPMRange(pm_high, pm_low, period_start, devRight, devRight, period_end, period_end, currentDayNum)

// ══════════════════════════════════════════════════════════════════════════════
// UPDATE RIGHT EDGE (last bar only)
// Level lines extend to the current time, capped at the trading day end, when
// the day-end extension is on (so the current day's lines grow through the day
// and never project past "now"). Labels follow the line ends. The box is fixed.
// ══════════════════════════════════════════════════════════════════════════════

if barstate.islast and array.size(pmRecords) > 0
    for rec in pmRecords
        int rightEdge = extendToDayEnd ? (timenow < rec.dayEndTime ? timenow : rec.dayEndTime) : rec.winEndTime
        for ln in rec.lines
            line.set_x2(ln, rightEdge)
        for ar in rec.areas
            box.set_right(ar, rightEdge)
        if array.size(rec.labels) > 0
            // Labels sit on the left (line start, fixed) or right (line end, grows)
            int boxLeft = labelSide == "Left" ? rec.winStartTime - labelOffset * barMs - labelBoxWidthMs : rightEdge + labelOffset * barMs
            for li = 0 to array.size(rec.labels) - 1
                box   lb = array.get(rec.labels, li)
                float ly = array.get(rec.labelYs, li)
                box.set_left(lb, boxLeft)
                box.set_right(lb, boxLeft + labelBoxWidthMs)
                box.set_top(lb, ly + quartilePriceOffset)
                box.set_bottom(lb, ly - quartilePriceOffset)

// ══════════════════════════════════════════════════════════════════════════════
// CLEANUP
// Keep only the most recent daysToShow ranges. Delete ALL drawing objects
// before removing a record from the array.
// ══════════════════════════════════════════════════════════════════════════════

if barstate.islast
    while array.size(pmRecords) > daysToShow
        PMRecord old = array.get(pmRecords, 0)
        box.delete(old.pmBox)
        for ln in old.lines
            line.delete(ln)
        for lb in old.labels
            box.delete(lb)
        for ar in old.areas
            box.delete(ar)
        array.remove(pmRecords, 0)

// ══════════════════════════════════════════════════════════════════════════════
// END OF SCRIPT
// ══════════════════════════════════════════════════════════════════════════════
````

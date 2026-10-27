# ICT Pre-market ranges (NY AM)

- url: https://www.tradingview.com/script/umVN36NX-ICT-Pre-market-ranges-NY-AM/
- type: indicator
- pine_id: PUB;109d4971f1cf44588fb3673ccecf5ce8
- version: 3.0

## Description

This indicator plots the New York pre-market range — the high-to-low of price action between 07:00 and 09:00 NY time — as a box, with optional internal quarter, eighth, and range-boundary level lines, plus projected fib target lines and shaded target areas.

The two hours before the 09:30 cash open often establish the day's early liquidity and balance. Within ICT (Inner Circle Trader) methodology, the boundaries of this pre-market range and its internal subdivisions act as reference points once the NY AM session begins: price frequently reacts at the range extremes, the 0.5 equilibrium, and the intermediate quarter and eighth levels. Drawing these levels ahead of the open gives a ready-made framework for the session.

[b]What It Plots[/b]

Once the 07:00–09:00 NY window closes, the indicator measures the highest high and lowest low of that window (from wicks by default, or candle bodies if you prefer) and draws a box between them. Level lines subdivide the range, and fib target lines project beyond it, so equilibrium, retracement, and extension levels are visible at a glance.

[b]Visual Elements[/b]
[list]
[*]Peach range box spanning the 07:00–09:00 NY pre-market window
[*]Optional centered box title ("Pre-Market range" plus the weekday and date), with selectable position and font size
[*]Range boundary lines at 0 and 1 (low and high)
[*]Quarter lines at 0.25, 0.5, and 0.75
[*]Eighth lines at 0.125, 0.375, 0.625, and 0.875
[*]Optional extension of level lines toward the trading day end (00:00), tracking the current time
[*]Fib target lines outside the range at ±0.5, ±1.0, ±1.5, ±2.0, and a custom multiple
[*]Optional filled target-area bands per fixed target step — bullish (above the high) and bearish (below the low), each successive band a bit darker
[*]Optional fib labels (0 … 1 and ±targets) beside each line, on the left or right side
[/list]

[b]How To Use It[/b]
[list]
[*]Add the indicator to an intraday chart (15m–1H shows the pre-market range and the NY AM session together well).
[*]Watch for reactions at the range high/low, the 0.5 equilibrium, and the quarter/eighth levels during the NY AM session.
[*]Use the ± fib targets and shaded target areas to frame where an expansion out of the range may be heading.
[*]Enable "Extend Levels to Day End" to carry the levels across the whole trading day as reference.
[*]Use "Days to Show" to compare the current pre-market range against previous days.
[/list]

[b]Settings Overview[/b]
[list]
[*]General: show/hide box, box title with its position and font size, days to show (1–10), pre-market window time, wicks vs bodies
[*]Level Lines: range lines (0/1), quarter lines (0.25/0.5/0.75), eighth lines, extend to day end, line labels on/off, label side (left/right), label horizontal offset
[*]Fib Target Lines: ±0.5, ±1.0, ±1.5, ±2.0, and a custom multiple; "Fill Target Areas" on/off; bullish and bearish target-band colors
[*]Colors: box fill color, line color, line weight, line style (solid/dashed/dotted), and an optional box border (uses the line color)
[/list]

[b]Technical Notes[/b]

Range detection uses 1-minute intrabar data via request.security_lower_tf(), so the pre-market high and low are captured accurately on any chart timeframe. Boxes and level lines are time-anchored (xloc.bar_time) so past days line up with their real timestamps. The box is fixed to the 07:00–09:00 window; when the day-end extension is enabled, the level lines extend to the current time and are capped at the trading day end (00:00), so they never project past the latest bar. Only weekdays (Monday–Friday) are processed.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════════
//
// ICT Pre-market ranges
// Version: 21/08/2026
//
// ──────────────────────────────────────────────────────────────────────────────
//
// DESCRIPTION:
// Plots the New York pre-market range — the high-low of price action between
// 07:00 and 09:00 NY time — as a box, with optional quarter, eighth, and range
// boundary level lines. Based on ICT (Inner Circle Trader) concepts, the
// pre-market range and its internal quarter/eighth levels act as reference
// points for the NY AM session that follows the 09:30 cash open. A second,
// independently configurable window (default 02:00–05:00, e.g. the London
// session) can be plotted alongside using the same levels and targets.
//
// FEATURES:
//   • Live developing range: during the current day's window the box grows from
//     the open and expands until the close, then stays fixed afterwards
//   • Peach range box spanning the pre-market window, with an independent
//     fill toggle (keep the border/title/lines without the fill)
//   • Optional second range window (toggle), independently timed
//   • Optional two-line box title (name + weekday and date), position selectable
//   • Range boundary lines (0% / 100%) — toggle
//   • Quarter lines (25% / 50% / 75%) — toggle
//   • Eighth lines (12.5% / 37.5% / 62.5% / 87.5%) — toggle
//   • Fib target lines outside the range (± 0.5 / 1.0 / 1.5 / 2.0 / custom)
//   • Optional filled target-area bands per fixed target step — bullish (above)
//     and bearish (below), each successive band a bit darker
//   • Optional extension of level lines to the current time, capped at the
//     trading day end (00:00), with an option to extend only the target lines
//   • Optional projection of previous cycles' target lines (and their filled
//     bands) forward to the current time
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

indicator("ICT Pre-market ranges", overlay=true, max_boxes_count=500, max_lines_count=500)

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

rangesToShow = input.int(2, "Ranges to Show",
     minval=1, maxval=20,
     group=grpGeneral,
     tooltip="Total number of range boxes to keep on the chart, counting both windows together. With the second window on, today's two ranges use 2 of this count; with it off, the same count reaches further back in days. Weekends are skipped.")

sessionInput = input.session("0700-0900", "Pre-market Window (NY time)",
     group=grpGeneral,
     tooltip="Pre-market range window in HHMM-HHMM format (NY timezone). Default 0700-0900.")

showWindow2 = input.bool(true, "Show Second Window",
     group=grpGeneral,
     tooltip="Plot a second range for another window (e.g. the London session). Uses the same levels, targets, colors, and settings as the first window.")

session2Input = input.session("0200-0500", "Second Window (NY time)",
     group=grpGeneral,
     tooltip="Second range window in HHMM-HHMM format (NY timezone). Default 0200-0500.")

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

extendOnlyTargets = input.bool(false, "  ↳ Extend Only Target Lines",
     group=grpLevels,
     tooltip="Requires 'Extend Levels to Day End'. When on, only the fib target lines (and their filled bands) extend to day end; the internal range / quarter / eighth lines still stop at the window close.")

extendPrevTargets = input.bool(false, "Extend Previous Cycle Targets to Current Time",
     group=grpLevels,
     tooltip="Extend the fib target lines from previous cycles (earlier days) forward to the current time, so past targets can be compared against current price. Their filled bands extend too when 'Fill Target Areas' is on. Internal range / quarter / eighth lines are unaffected. Works independently of the day-end extension above.")

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

fillRange = input.bool(true, "Fill Range Area",
     group=grpColors,
     tooltip="Fill the range box with the fill color. Turn off to keep just the box border/title (and the level lines) with no fill, the same way 'Fill Target Areas' works for the targets. Requires 'Show Range Box'.")

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

int start2Hour   = int(str.tonumber(str.substring(session2Input, 0, 2)))
int start2Minute = int(str.tonumber(str.substring(session2Input, 2, 4)))
int end2Hour     = int(str.tonumber(str.substring(session2Input, 5, 7)))
int end2Minute   = int(str.tonumber(str.substring(session2Input, 7, 9)))

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
    array<bool>  lineIsTarget // Parallel to lines/labels: true = external fib target
    array<box>   labels       // Percentage label boxes, parallel to labelYs
    array<float> labelYs      // Price of each label, for repositioning
    array<box>   areas        // Filled target-area bands (extend with the lines)
    int          dayNum       // YYYYMMDD identifier for duplicate prevention
    int          windowId     // 0 = first window, 1 = second window
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

// Appends a level (price + label text + target flag) to the parallel build arrays.
// Arrays are passed by reference, so the pushes persist in the caller.
addLevel(array<float> ys, array<string> ts, array<bool> tg, float y, string t, bool isTgt) =>
    array.push(ys, y)
    array.push(ts, t)
    array.push(tg, isTgt)

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

// Second window state (mirrors the first)
var bool  w2_started = false
var bool  w2_found   = false
var float w2_high    = na
var float w2_low     = na

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

int period2_start = today_ts(start2Hour, start2Minute)  // second window open
int period2_end   = today_ts(end2Hour, end2Minute)      // second window close

// ══════════════════════════════════════════════════════════════════════════════
// BUILD ONE PRE-MARKET RANGE (box + levels + fib targets + areas + labels)
// Returns a PMRecord. Used both for the finalized range (fixed box, right=winEnd)
// and the live developing range (box + lines grow to the current time). boxRight
// is the box's right edge; lineRight is the lines'/areas' right edge.
// ══════════════════════════════════════════════════════════════════════════════

buildPMRange(float ph, float pl, int winStart, int boxRight, int lineRight, int winEnd, int dayEnd, int dayNumV, int windowIdV, string titleName) =>
    float rng  = ph - pl
    int   dowV = dayofweek(time, TZ)

    // Box title (two lines): name, then weekday and date (dd.mm.yyyy)
    string boxTitle = ""
    if showBoxTitle
        string dateStr = str.tostring(dayofmonth(time, TZ), "00") + "." + str.tostring(month(time, TZ), "00") + "." + str.tostring(year(time, TZ))
        boxTitle := titleName + "\n" + getWeekdayName(dowV) + " " + dateStr

    box newBox = na
    if showBox and (fillRange or showBorder or showBoxTitle)
        color rangeBg = fillRange ? fillColor : color.new(fillColor, 100)
        newBox := box.new(left=winStart, top=ph, right=boxRight, bottom=pl,
             xloc=xloc.bar_time, bgcolor=rangeBg, border_color=borderColorFinal,
             text=boxTitle, text_color=color.new(lineColor, 0),
             text_halign=text.align_center, text_valign=boxTitleValign, text_size=boxTitleSize)

    // Build the levels to draw as parallel price + label + target-flag arrays
    array<float>  levelYs  = array.new<float>()
    array<string> levelTxt = array.new<string>()
    array<bool>   levelTgt = array.new<bool>()
    if showRangeLines
        addLevel(levelYs, levelTxt, levelTgt, pl, "0", false)
        addLevel(levelYs, levelTxt, levelTgt, ph, "1", false)
    if showQuartiles
        addLevel(levelYs, levelTxt, levelTgt, pl + rng * 0.25, "0.25", false)
        addLevel(levelYs, levelTxt, levelTgt, pl + rng * 0.50, "0.5", false)
        addLevel(levelYs, levelTxt, levelTgt, pl + rng * 0.75, "0.75", false)
    if showEighths
        addLevel(levelYs, levelTxt, levelTgt, pl + rng * 0.125, "0.125", false)
        addLevel(levelYs, levelTxt, levelTgt, pl + rng * 0.375, "0.375", false)
        addLevel(levelYs, levelTxt, levelTgt, pl + rng * 0.625, "0.625", false)
        addLevel(levelYs, levelTxt, levelTgt, pl + rng * 0.875, "0.875", false)

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
        addLevel(levelYs, levelTxt, levelTgt, ph + rng * v, "+" + str.tostring(v), true)
        addLevel(levelYs, levelTxt, levelTgt, pl - rng * v, "-" + str.tostring(v), true)

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
    array<bool>  recIsTgt  = array.new<bool>()
    array<box>   recLabels = array.new<box>()
    array<float> recLabelY = array.new<float>()
    for li = 0 to array.size(levelYs) - 1
        float y   = array.get(levelYs, li)
        bool  tgt = array.get(levelTgt, li)
        array.push(recLines, mkLine(winStart, y, lineRight))
        array.push(recIsTgt, tgt)
        if showLineLabels
            array.push(recLabels, mkLabel(winStart, lineRight, y, array.get(levelTxt, li)))
            array.push(recLabelY, y)

    PMRecord.new(newBox, recLines, recIsTgt, recLabels, recLabelY, recAreas, dayNumV, windowIdV, winStart, winEnd, dayEnd)

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
    w2_started := false
    w2_found   := false
    w2_high    := na
    w2_low     := na

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
// PER-WINDOW PROCESSING HELPERS
// The two windows share all appearance/level/target settings; only the time
// window, id, and title differ. State scalars are returned (Pine can't mutate a
// caller's scalar), so each caller assigns the results back to its own vars.
// ══════════════════════════════════════════════════════════════════════════════

// Accumulate running high/low over the 1-minute bars inside [pStart, pEnd)
accumulateWindow(int pStart, int pEnd, bool started0, float hi0, float lo0) =>
    bool  st = started0
    float hi = hi0
    float lo = lo0
    if arr_size > 0
        for i = 0 to arr_size - 1
            int bt = array.get(time_arr, i)
            if bt >= pStart and bt < pEnd
                float h = useWicks ? array.get(high_arr, i) : math.max(array.get(open_arr, i), array.get(close_arr, i))
                float l = useWicks ? array.get(low_arr, i)  : math.min(array.get(open_arr, i), array.get(close_arr, i))
                if na(hi)
                    hi := h
                    lo := l
                    st := true
                else
                    hi := math.max(hi, h)
                    lo := math.min(lo, l)
    [st, hi, lo]

// Finalize once the window has closed: create the immutable record, push it, and
// return the new "found" state. Duplicate-guarded per (day, window).
finalizeWindow(bool found0, bool started0, float hi, float lo, int pStart, int pEnd, int wid, string titleName) =>
    bool found = found0
    if not found0 and started0 and not na(hi)
        bool session_ended = (arr_size > 0 and array.get(time_arr, arr_size - 1) >= pEnd) or time >= pEnd
        if session_ended
            found := true
            bool already = false
            for rec in pmRecords
                if rec.dayNum == currentDayNum and rec.windowId == wid
                    already := true
                    break
            if not already and hi != lo
                // Day end = the following 00:00 NY (step ~36h from today's
                // midnight, DST-safe, then re-floor to that day's midnight).
                int todayMidnight = timestamp(TZ, year(time, TZ), month(time, TZ), dayofmonth(time, TZ), 0, 0, 0)
                int nextDayInside = todayMidnight + 129600000
                int dayEndTime    = timestamp(TZ, year(nextDayInside, TZ), month(nextDayInside, TZ), dayofmonth(nextDayInside, TZ), 0, 0, 0)
                int lineRight     = extendToDayEnd ? (timenow < dayEndTime ? timenow : dayEndTime) : pEnd
                array.push(pmRecords, buildPMRange(hi, lo, pStart, pEnd, lineRight, pEnd, dayEndTime, currentDayNum, wid, titleName))
    found

// Build the live developing range while the window is still open (returns na
// otherwise). Redrawn each update on the last bar.
buildDev(bool started0, bool found0, float hi, float lo, int pStart, int pEnd, int wid, string titleName) =>
    PMRecord d = na
    bool inWindow = isTradingDay and started0 and not found0 and not na(hi) and hi != lo
    if inWindow
        int devRight = timenow < pEnd ? timenow : pEnd
        d := buildPMRange(hi, lo, pStart, devRight, devRight, pEnd, pEnd, currentDayNum, wid, titleName)
    d

// Delete every drawing object of a developing record
clearDev(PMRecord d) =>
    if not na(d)
        box.delete(d.pmBox)
        for ln in d.lines
            line.delete(ln)
        for lb in d.labels
            box.delete(lb)
        for ar in d.areas
            box.delete(ar)

// ══════════════════════════════════════════════════════════════════════════════
// ACCUMULATE & FINALIZE (both windows)
// Track running high/low within each window (weekdays only), then finalize once
// the window closes.
// ══════════════════════════════════════════════════════════════════════════════

if not pm_found and isTradingDay
    [st1, hi1, lo1] = accumulateWindow(period_start, period_end, pm_started, pm_high, pm_low)
    pm_started := st1
    pm_high    := hi1
    pm_low     := lo1
pm_found := finalizeWindow(pm_found, pm_started, pm_high, pm_low, period_start, period_end, 0, "Pre-Market range")

if showWindow2 and not w2_found and isTradingDay
    [st2, hi2, lo2] = accumulateWindow(period2_start, period2_end, w2_started, w2_high, w2_low)
    w2_started := st2
    w2_high    := hi2
    w2_low     := lo2
if showWindow2
    w2_found := finalizeWindow(w2_found, w2_started, w2_high, w2_low, period2_start, period2_end, 1, "Pre-Market range 2")

// ══════════════════════════════════════════════════════════════════════════════
// DEVELOPING RANGES (live, last bar only)
// While a window is still open (started, not finalized), draw a range that grows
// to the current time and expands with the running high/low. Delete/recreated
// each update, removed once the range finalizes.
// ══════════════════════════════════════════════════════════════════════════════

var PMRecord devRec  = na
var PMRecord devRec2 = na

if barstate.islast
    clearDev(devRec)
    devRec := buildDev(pm_started, pm_found, pm_high, pm_low, period_start, period_end, 0, "Pre-Market range")

    clearDev(devRec2)
    devRec2 := na
    if showWindow2
        devRec2 := buildDev(w2_started, w2_found, w2_high, w2_low, period2_start, period2_end, 1, "Pre-Market range 2")

// ══════════════════════════════════════════════════════════════════════════════
// UPDATE RIGHT EDGE (last bar only)
// Level lines extend to the current time, capped at the trading day end, when
// the day-end extension is on (so the current day's lines grow through the day
// and never project past "now"). Labels follow the line ends. The box is fixed.
// ══════════════════════════════════════════════════════════════════════════════

if barstate.islast and array.size(pmRecords) > 0
    for rec in pmRecords
        int  fullRight = extendToDayEnd ? (timenow < rec.dayEndTime ? timenow : rec.dayEndTime) : rec.winEndTime
        bool onlyTgt   = extendToDayEnd and extendOnlyTargets  // internal lines stop at winEnd
        bool prevCycle = rec.dayEndTime <= timenow             // an earlier, fully-ended cycle
        // Level lines: targets go to fullRight; internals stop at winEnd when onlyTgt.
        // A previous cycle's targets can be projected forward to the current time.
        for li = 0 to array.size(rec.lines) - 1
            bool tgt = array.get(rec.lineIsTarget, li)
            int  lr  = (onlyTgt and not tgt) ? rec.winEndTime : fullRight
            if extendPrevTargets and tgt and prevCycle
                lr := timenow
            line.set_x2(array.get(rec.lines, li), lr)
        // Target bands follow the targets, and are projected forward with them
        // when a previous cycle's targets extend to the current time.
        int areaRight = (extendPrevTargets and prevCycle) ? timenow : fullRight
        for ar in rec.areas
            box.set_right(ar, areaRight)
        if array.size(rec.labels) > 0
            for li = 0 to array.size(rec.labels) - 1
                box   lb  = array.get(rec.labels, li)
                float ly  = array.get(rec.labelYs, li)
                bool  tgt = array.get(rec.lineIsTarget, li)
                int   lr  = (onlyTgt and not tgt) ? rec.winEndTime : fullRight
                if extendPrevTargets and tgt and prevCycle
                    lr := timenow
                // Labels sit on the left (line start, fixed) or right (line end, grows)
                int boxLeft = labelSide == "Left" ? rec.winStartTime - labelOffset * barMs - labelBoxWidthMs : lr + labelOffset * barMs
                box.set_left(lb, boxLeft)
                box.set_right(lb, boxLeft + labelBoxWidthMs)
                box.set_top(lb, ly + quartilePriceOffset)
                box.set_bottom(lb, ly - quartilePriceOffset)

// ══════════════════════════════════════════════════════════════════════════════
// CLEANUP
// Keep only the most recent ranges TOTAL, counting both windows together and
// including any range currently forming (records are ordered oldest→newest by
// finalization). A live developing range counts toward the total, so the cap on
// finalized records is reduced by the number of ranges currently forming.
// Delete ALL drawing objects before removing a record from the array.
// ══════════════════════════════════════════════════════════════════════════════

if barstate.islast
    int activeDev = (na(devRec) ? 0 : 1) + (na(devRec2) ? 0 : 1)
    int keepFinal = math.max(0, rangesToShow - activeDev)
    while array.size(pmRecords) > keepFinal
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

# Daily Time Markers

- url: https://www.tradingview.com/script/0VbaNzD6-Daily-Time-Markers/
- type: indicator
- pine_id: PUB;f6a7a09db29a47208a0594a8c897bd65
- version: 1.0

## Description

/ WHAT THIS DOES
// ----------------------------------------------------------------------------
// Up to 8 independently configurable "time of day" markers (e.g. 09:30).
// Each marker is drawn as a vertical line on EVERY calendar day, but only
// for days within a rolling window of N days counting back from the most
// recent bar currently on the chart. That "most recent bar" is automatically
// the replay cursor's position while in Bar Replay mode, and the live last
// bar otherwise -- so the window follows you forward as you replay.
// TODAY'S line is projected ahead immediately at the start of the day, even
// before its target time arrives, so you can see it coming and prepare.
// Works on any chart timeframe: on coarser timeframes (e.g. 1H, 1D) the line
// is placed at the exact target time even if that falls inside a bar.
// Timezone defaults to following the loaded symbol's own exchange timezone
// (syminfo.timezone) automatically -- Pine cannot read the chart's display
// timezone dropdown, so this is the closest automatic equivalent. A manual
// override is available if you want a fixed timezone regardless of symbol.
// Labels are anchored to the top/bottom of the chart's VISIBLE price range,
// so they stay clear of candles and don't look cluttered, no matter how
// you zoom or scroll.

## Source Code

````pine
//@version=6
indicator("Daily Time Markers (8 lines, rolling 14-day)", overlay = true, max_lines_count = 500, max_labels_count = 500)

// Library for chart-visible-range high/low, used to anchor labels to the
// top/bottom of the currently visible price range (so they sit clear of
// price action regardless of zoom/scroll) rather than at a fixed price.
import PineCoders/VisibleChart/5 as PCvc

// ============================================================================
// WHAT THIS DOES
// ----------------------------------------------------------------------------
// Up to 8 independently configurable "time of day" markers (e.g. 09:30).
// Each marker is drawn as a vertical line on EVERY calendar day, but only
// for days within a rolling window of N days counting back from the most
// recent bar currently on the chart. That "most recent bar" is automatically
// the replay cursor's position while in Bar Replay mode, and the live last
// bar otherwise -- so the window follows you forward as you replay.
// TODAY'S line is projected ahead immediately at the start of the day, even
// before its target time arrives, so you can see it coming and prepare.
// Works on any chart timeframe: on coarser timeframes (e.g. 1H, 1D) the line
// is placed at the exact target time even if that falls inside a bar.
// Timezone defaults to following the loaded symbol's own exchange timezone
// (syminfo.timezone) automatically -- Pine cannot read the chart's display
// timezone dropdown, so this is the closest automatic equivalent. A manual
// override is available if you want a fixed timezone regardless of symbol.
// Labels are anchored to the top/bottom of the chart's VISIBLE price range,
// so they stay clear of candles and don't look cluttered, no matter how
// you zoom or scroll.
// ============================================================================

// ============================================================================
// GLOBAL SETTINGS
// ============================================================================
var string GRP_GLOBAL = "Global Settings"

// NOTE on timezones: Pine scripts cannot read the chart's display timezone
// (the dropdown at the bottom-right of the chart) -- TradingView does not
// expose that setting to scripts. What scripts CAN read is syminfo.timezone,
// the timezone the instrument itself trades in (e.g. "America/New_York" for
// AAPL, "Asia/Singapore" for an SGX symbol). "Follow Chart Symbol" uses that,
// so the line times are always correct for whatever symbol is loaded, with
// no manual selection needed. A manual override list is kept for cases where
// you want a fixed timezone regardless of symbol (e.g. always NY session
// times even while charting a Singapore-listed instrument).
tzInput = input.string("Follow Chart Symbol", "Timezone", options = [
    "Follow Chart Symbol", "UTC", "America/New_York", "America/Chicago", "America/Los_Angeles",
    "Europe/London", "Europe/Berlin", "Asia/Singapore", "Asia/Tokyo", "Asia/Hong_Kong",
    "Asia/Kolkata", "Asia/Dubai", "Australia/Sydney"
], group = GRP_GLOBAL, tooltip = "'Follow Chart Symbol' auto-uses the timezone the loaded symbol trades in (syminfo.timezone). Pine cannot read the chart's display-timezone dropdown setting directly, so this is the closest automatic equivalent. Pick a fixed zone instead only if you want line times anchored to one specific timezone regardless of symbol.")

lookbackDaysInput = input.int(14, "Rolling window (days back from current bar)", minval = 1, maxval = 365, group = GRP_GLOBAL)
labelSizeInput    = input.string("normal", "Label Size", options = ["tiny", "small", "normal", "large", "huge"], group = GRP_GLOBAL)
skipWeekendsInput = input.bool(false, "Skip Sat/Sun (in selected timezone)", group = GRP_GLOBAL)

// Where labels sit, expressed as a % padding outside the visible price
// range, so they clear the candles instead of overlapping them.
labelPaddingPctInput = input.float(3.0, "Label clearance from chart edge (%)", minval = 0.0, maxval = 20.0, step = 0.5, group = GRP_GLOBAL)

f_tzString(string choice) =>
    string result = choice == "Follow Chart Symbol" ? syminfo.timezone : choice
    result

string tzString = f_tzString(tzInput)

f_labelSize(string s) =>
    string out = s == "tiny" ? size.tiny : s == "small" ? size.small : s == "large" ? size.large : s == "huge" ? size.huge : size.normal
    out

string lblSize = f_labelSize(labelSizeInput)

// Visible-range high/low, recalculated every bar (required by the library
// for correct dynamic behavior on zoom/scroll). Padded outward slightly so
// labels sit just outside the visible candles rather than touching them.
float visHigh = PCvc.high()
float visLow  = PCvc.low()
float visSpan = visHigh - visLow
float labelTopY = visHigh + visSpan * (labelPaddingPctInput / 100)
float labelBotY = visLow  - visSpan * (labelPaddingPctInput / 100)


// ============================================================================
// PER-LINE INPUT BLOCK (repeated x8)
// Each line: enable, hour, minute, color, width, style, label text, label position
// Time-of-day is entered as separate Hour/Minute integers (not a date picker),
// since this now repeats daily rather than firing once on a fixed date.
// ============================================================================

// ---- Line 1 ----
var string G1 = "Line 1"
l1_on    = input.bool(true, "Enable", group = G1)
l1_hour  = input.int(9,  "Hour (0-23)",   minval = 0, maxval = 23, inline = "l1t", group = G1)
l1_min   = input.int(30, "Minute (0-59)", minval = 0, maxval = 59, inline = "l1t", group = G1)
l1_color = input.color(color.new(color.blue, 0), "Color", group = G1)
l1_width = input.int(1, "Width", minval = 1, maxval = 5, group = G1)
l1_style = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], group = G1)
l1_label = input.string("", "Label Text (blank = none)", group = G1)
l1_lpos  = input.string("Top", "Label Position", options = ["Top", "Bottom"], group = G1)

// ---- Line 2 ----
var string G2 = "Line 2"
l2_on    = input.bool(false, "Enable", group = G2)
l2_hour  = input.int(10, "Hour (0-23)",   minval = 0, maxval = 23, inline = "l2t", group = G2)
l2_min   = input.int(0,  "Minute (0-59)", minval = 0, maxval = 59, inline = "l2t", group = G2)
l2_color = input.color(color.new(color.red, 0), "Color", group = G2)
l2_width = input.int(1, "Width", minval = 1, maxval = 5, group = G2)
l2_style = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], group = G2)
l2_label = input.string("", "Label Text (blank = none)", group = G2)
l2_lpos  = input.string("Top", "Label Position", options = ["Top", "Bottom"], group = G2)

// ---- Line 3 ----
var string G3 = "Line 3"
l3_on    = input.bool(false, "Enable", group = G3)
l3_hour  = input.int(11, "Hour (0-23)",   minval = 0, maxval = 23, inline = "l3t", group = G3)
l3_min   = input.int(0,  "Minute (0-59)", minval = 0, maxval = 59, inline = "l3t", group = G3)
l3_color = input.color(color.new(color.green, 0), "Color", group = G3)
l3_width = input.int(1, "Width", minval = 1, maxval = 5, group = G3)
l3_style = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], group = G3)
l3_label = input.string("", "Label Text (blank = none)", group = G3)
l3_lpos  = input.string("Top", "Label Position", options = ["Top", "Bottom"], group = G3)

// ---- Line 4 ----
var string G4 = "Line 4"
l4_on    = input.bool(false, "Enable", group = G4)
l4_hour  = input.int(12, "Hour (0-23)",   minval = 0, maxval = 23, inline = "l4t", group = G4)
l4_min   = input.int(0,  "Minute (0-59)", minval = 0, maxval = 59, inline = "l4t", group = G4)
l4_color = input.color(color.new(color.orange, 0), "Color", group = G4)
l4_width = input.int(1, "Width", minval = 1, maxval = 5, group = G4)
l4_style = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], group = G4)
l4_label = input.string("", "Label Text (blank = none)", group = G4)
l4_lpos  = input.string("Top", "Label Position", options = ["Top", "Bottom"], group = G4)

// ---- Line 5 ----
var string G5 = "Line 5"
l5_on    = input.bool(false, "Enable", group = G5)
l5_hour  = input.int(13, "Hour (0-23)",   minval = 0, maxval = 23, inline = "l5t", group = G5)
l5_min   = input.int(0,  "Minute (0-59)", minval = 0, maxval = 59, inline = "l5t", group = G5)
l5_color = input.color(color.new(color.purple, 0), "Color", group = G5)
l5_width = input.int(1, "Width", minval = 1, maxval = 5, group = G5)
l5_style = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], group = G5)
l5_label = input.string("", "Label Text (blank = none)", group = G5)
l5_lpos  = input.string("Top", "Label Position", options = ["Top", "Bottom"], group = G5)

// ---- Line 6 ----
var string G6 = "Line 6"
l6_on    = input.bool(false, "Enable", group = G6)
l6_hour  = input.int(14, "Hour (0-23)",   minval = 0, maxval = 23, inline = "l6t", group = G6)
l6_min   = input.int(0,  "Minute (0-59)", minval = 0, maxval = 59, inline = "l6t", group = G6)
l6_color = input.color(color.new(color.teal, 0), "Color", group = G6)
l6_width = input.int(1, "Width", minval = 1, maxval = 5, group = G6)
l6_style = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], group = G6)
l6_label = input.string("", "Label Text (blank = none)", group = G6)
l6_lpos  = input.string("Top", "Label Position", options = ["Top", "Bottom"], group = G6)

// ---- Line 7 ----
var string G7 = "Line 7"
l7_on    = input.bool(false, "Enable", group = G7)
l7_hour  = input.int(15, "Hour (0-23)",   minval = 0, maxval = 23, inline = "l7t", group = G7)
l7_min   = input.int(0,  "Minute (0-59)", minval = 0, maxval = 59, inline = "l7t", group = G7)
l7_color = input.color(color.new(color.maroon, 0), "Color", group = G7)
l7_width = input.int(1, "Width", minval = 1, maxval = 5, group = G7)
l7_style = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], group = G7)
l7_label = input.string("", "Label Text (blank = none)", group = G7)
l7_lpos  = input.string("Top", "Label Position", options = ["Top", "Bottom"], group = G7)

// ---- Line 8 ----
var string G8 = "Line 8"
l8_on    = input.bool(false, "Enable", group = G8)
l8_hour  = input.int(16, "Hour (0-23)",   minval = 0, maxval = 23, inline = "l8t", group = G8)
l8_min   = input.int(0,  "Minute (0-59)", minval = 0, maxval = 59, inline = "l8t", group = G8)
l8_color = input.color(color.new(color.fuchsia, 0), "Color", group = G8)
l8_width = input.int(1, "Width", minval = 1, maxval = 5, group = G8)
l8_style = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], group = G8)
l8_label = input.string("", "Label Text (blank = none)", group = G8)
l8_lpos  = input.string("Top", "Label Position", options = ["Top", "Bottom"], group = G8)

// ============================================================================
// HELPERS
// ============================================================================

f_lineStyle(string s) =>
    string out = s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid
    out

// Today's calendar date (in tzString) combined with a given hour/minute,
// rebuilt as a fresh timestamp anchored in tzString. Recomputed every bar.
f_todaysTarget(string tz, int h, int mi) =>
    int y  = year(time, tz)
    int mo = month(time, tz)
    int d  = dayofmonth(time, tz)
    int out = timestamp(tz, y, mo, d, h, mi, 0)
    out

// Calendar-exact day key as YYYYMMDD (e.g. 20260629), immune to DST-offset
// arithmetic issues that a raw epoch-ms/86400000 division could hit on the
// few days per year a timezone's UTC offset changes.
f_dayKey(string tz) =>
    int y  = year(time, tz)
    int mo = month(time, tz)
    int d  = dayofmonth(time, tz)
    int out = y * 10000 + mo * 100 + d
    out

// Day-of-week in tzString as of this bar's time, 1=Sunday..7=Saturday (Pine's dayofweek convention)
f_dow(string tz) =>
    int out = dayofweek(time, tz)
    out

// ============================================================================
// CORE DRAWING ENGINE (called once per configured line)
// ----------------------------------------------------------------------------
// Maintains its own persistent arrays of line/label IDs + the calendar-day
// key each one belongs to, so it can:
//   1) Detect "a new calendar day has started" and immediately project that
//      day's line at its target time -- even if the target time hasn't
//      happened yet today, so you can see it coming in advance.
//   2) Avoid duplicate draws for the same day.
//   3) Prune lines/labels that have rolled out of the lookback window,
//      where the window is measured from the CURRENT (last/replay) bar.
// Lines/labels use xloc.bar_time so they can be placed at a future point in
// time (today's target, if it hasn't happened yet) without needing a bar to
// already exist there.
// ============================================================================
f_drawDailyLine(bool enabled, int hh, int mm, color col, int width, string styleStr,
     string labelTxt, string labelPos, string sizeStr,
     string tz, int lookbackDays, bool skipWeekends, float labelTopY, float labelBotY) =>

    var array<line>  lineIds   = array.new<line>()
    var array<label> labelIds  = array.new<label>()
    var array<int>   dayKeys   = array.new<int>()   // calendar-day key (in tz) each drawing belongs to
    var array<bool>  labelTops = array.new<bool>()  // true if that label is a "Top" label, false if "Bottom"

    // Calendar-exact day key for "today" (in tz) at this bar.
    int todayKey = f_dayKey(tz)
    int todayMidnightUTC = f_todaysTarget(tz, 0, 0)

    // Track the most recent (furthest-forward) calendar day seen so far,
    // both as a comparable key and as its midnight epoch (needed to do
    // real date arithmetic for the rolling-window cutoff below).
    // On the live last bar (or the current replay-cursor bar), this equals
    // today's key -- which is exactly the anchor point the rolling window
    // measures back from.
    var int latestKey          = na
    var int latestMidnightUTC  = na
    if na(latestKey) or todayKey > latestKey
        latestKey         := todayKey
        latestMidnightUTC := todayMidnightUTC

    int targetTime = f_todaysTarget(tz, hh, mm)
    bool isWeekend = f_dow(tz) == dayofweek.sunday or f_dow(tz) == dayofweek.saturday
    bool dayOk = not (skipWeekends and isWeekend)

    // Has this calendar day already been drawn?
    bool alreadyDrawn = false
    if array.size(dayKeys) > 0
        if array.indexof(dayKeys, todayKey) >= 0
            alreadyDrawn := true

    // Draw as soon as we recognize "today" for the first time -- this
    // projects the line at its target time immediately, whether that time
    // is still ahead (most of the day) or has already passed (later in the
    // day), rather than waiting for the bar that actually crosses it.
    if enabled and dayOk and not alreadyDrawn
        line newLine = line.new(targetTime, low, targetTime, high, xloc = xloc.bar_time, extend = extend.both, color = col, style = f_lineStyle(styleStr), width = width)
        array.push(lineIds, newLine)
        array.push(dayKeys, todayKey)

        label newLabel = na
        if labelTxt != ""
            string st = labelPos == "Bottom" ? label.style_label_up : label.style_label_down
            float ly = labelPos == "Bottom" ? labelBotY : labelTopY
            newLabel := label.new(targetTime, ly, labelTxt, xloc = xloc.bar_time, yloc = yloc.price, style = st, color = color.new(col, 85), textcolor = col, size = sizeStr)
        array.push(labelIds, newLabel)
        array.push(labelTops, labelPos != "Bottom")

    // Keep existing labels pinned to the (possibly moving, as the user
    // zooms/scrolls) visible-range top/bottom rather than a fixed price.
    if array.size(labelIds) > 0
        for i = 0 to array.size(labelIds) - 1
            label lbl = array.get(labelIds, i)
            if not na(lbl)
                bool isTop = array.get(labelTops, i)
                label.set_y(lbl, isTop ? labelTopY : labelBotY)

    // Prune anything older than the rolling window. The cutoff date is
    // computed via real epoch-ms arithmetic (subtracting N days worth of
    // milliseconds from the latest known midnight), then converted to the
    // same YYYYMMDD key format used for comparison against stored days.
    int cutoffEpoch = latestMidnightUTC - lookbackDays * 86400000
    int cutoffKey   = year(cutoffEpoch, tz) * 10000 + month(cutoffEpoch, tz) * 100 + dayofmonth(cutoffEpoch, tz)
    if array.size(dayKeys) > 0
        for i = array.size(dayKeys) - 1 to 0
            if array.get(dayKeys, i) < cutoffKey
                line.delete(array.get(lineIds, i))
                label oldLbl = array.get(labelIds, i)
                if not na(oldLbl)
                    label.delete(oldLbl)
                array.remove(lineIds, i)
                array.remove(labelIds, i)
                array.remove(labelTops, i)
                array.remove(dayKeys, i)

// ============================================================================
// EXECUTION
// ============================================================================

f_drawDailyLine(l1_on, l1_hour, l1_min, l1_color, l1_width, l1_style, l1_label, l1_lpos, lblSize, tzString, lookbackDaysInput, skipWeekendsInput, labelTopY, labelBotY)
f_drawDailyLine(l2_on, l2_hour, l2_min, l2_color, l2_width, l2_style, l2_label, l2_lpos, lblSize, tzString, lookbackDaysInput, skipWeekendsInput, labelTopY, labelBotY)
f_drawDailyLine(l3_on, l3_hour, l3_min, l3_color, l3_width, l3_style, l3_label, l3_lpos, lblSize, tzString, lookbackDaysInput, skipWeekendsInput, labelTopY, labelBotY)
f_drawDailyLine(l4_on, l4_hour, l4_min, l4_color, l4_width, l4_style, l4_label, l4_lpos, lblSize, tzString, lookbackDaysInput, skipWeekendsInput, labelTopY, labelBotY)
f_drawDailyLine(l5_on, l5_hour, l5_min, l5_color, l5_width, l5_style, l5_label, l5_lpos, lblSize, tzString, lookbackDaysInput, skipWeekendsInput, labelTopY, labelBotY)
f_drawDailyLine(l6_on, l6_hour, l6_min, l6_color, l6_width, l6_style, l6_label, l6_lpos, lblSize, tzString, lookbackDaysInput, skipWeekendsInput, labelTopY, labelBotY)
f_drawDailyLine(l7_on, l7_hour, l7_min, l7_color, l7_width, l7_style, l7_label, l7_lpos, lblSize, tzString, lookbackDaysInput, skipWeekendsInput, labelTopY, labelBotY)
f_drawDailyLine(l8_on, l8_hour, l8_min, l8_color, l8_width, l8_style, l8_label, l8_lpos, lblSize, tzString, lookbackDaysInput, skipWeekendsInput, labelTopY, labelBotY)
````

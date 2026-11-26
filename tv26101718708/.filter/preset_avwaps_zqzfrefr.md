# Preset AVWAPs

- url: https://www.tradingview.com/script/zQZfREfr-Preset-AVWAPs/
- type: indicator
- pine_id: PUB;077b2a6c349d4840bde111f2060075cf
- version: 1.0

## Description

This very simple script will display various anchored VWAPs on your chart.  You can choose from YTD, MTD, WTD, 2D and 1D.  You can also define 3 custom dates as well.

Very simple and straight forward.  I did find one or two other scripts that do this to some degree, but they appear to be a little more complicated.

Enjoy!

## Source Code

````pine
//@version=6
indicator("Preset AVWAPs", overlay=true, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════
// Preset AVWAPs
// by DarkStarOptions
//
// Displays Anchored VWAPs for common swing and day trading periods:
//   Swing Trading : Year-To-Date, Month-To-Date, Week-To-Date
//   Day Trading   : 1-Day, 2-Day
//   Custom        : Up to 3 user-defined anchor dates
//
// Custom AVWAPs allow you to anchor to any meaningful price event
// such as an election, market low, or earnings date.
// Enter dates in M/D/YYYY or MM/DD/YYYY format.
// ═══════════════════════════════════════════════════════════════════

// ── Inputs ─────────────────────────────────────────────────────────
show_ytd     = input.bool(true,  "Year-To-Date (YTD) AVWAP",   group="Swing Trading")
show_mtd     = input.bool(true,  "Month-To-Date (MTD) AVWAP",  group="Swing Trading")
show_wtd     = input.bool(true,  "Week-To-Date (WTD) AVWAP",   group="Swing Trading")

show_1d      = input.bool(false, "1-Day (1D) AVWAP",           group="Day Trading")
show_2d      = input.bool(false, "2-Day (2D) AVWAP",           group="Day Trading")

show_c1      = input.bool(false,        "Custom AVWAP #1",      group="Custom AVWAPs")
c1_date      = input.string("1/1/2025", "  Date (MM/DD/YYYY)",  group="Custom AVWAPs")
c1_label_str = input.string("Custom 1", "  Label",              group="Custom AVWAPs")
show_c2      = input.bool(false,        "Custom AVWAP #2",      group="Custom AVWAPs")
c2_date      = input.string("1/1/2025", "  Date (MM/DD/YYYY)",  group="Custom AVWAPs")
c2_label_str = input.string("Custom 2", "  Label",              group="Custom AVWAPs")
show_c3      = input.bool(false,        "Custom AVWAP #3",      group="Custom AVWAPs")
c3_date      = input.string("1/1/2025", "  Date (MM/DD/YYYY)",  group="Custom AVWAPs")
c3_label_str = input.string("Custom 3", "  Label",              group="Custom AVWAPs")

src          = input.source(hlc3, "Source",      group="Display")
show_labels  = input.bool(true,   "Show Labels", group="Display")

// ── Custom date parser ─────────────────────────────────────────────
// Accepts M/D/YYYY or MM/DD/YYYY format
// Returns na if the string is malformed
parseMonth(d) =>
    parts = str.split(d, "/")
    array.size(parts) == 3 ? int(str.tonumber(array.get(parts, 0))) : na

parseDay(d) =>
    parts = str.split(d, "/")
    array.size(parts) == 3 ? int(str.tonumber(array.get(parts, 1))) : na

parseYear(d) =>
    parts = str.split(d, "/")
    array.size(parts) == 3 ? int(str.tonumber(array.get(parts, 2))) : na

c1_month = parseMonth(c1_date)
c1_day   = parseDay(c1_date)
c1_year  = parseYear(c1_date)

c2_month = parseMonth(c2_date)
c2_day   = parseDay(c2_date)
c2_year  = parseYear(c2_date)

c3_month = parseMonth(c3_date)
c3_day   = parseDay(c3_date)
c3_year  = parseYear(c3_date)

// ── Swing Trading: current period anchors from wall clock ──────────
// Uses timenow so the correct period is always shown, even on weekends
current_year  = year(timenow)
current_month = month(timenow)
current_week  = weekofyear(timenow)

// ── Day Trading: roll timenow back to last trading session ─────────
// Handles Saturday, Sunday, and pre-market (before 9:30 AM ET)
// so the correct day's AVWAP is shown outside of market hours
ms_per_day   = 86400000
dow          = dayofweek(timenow)
current_hhmm = hour(timenow, "America/New_York") * 100 + minute(timenow, "America/New_York")

// Step 1: roll back if weekend
adjusted = dow == dayofweek.saturday ? timenow - ms_per_day : dow == dayofweek.sunday ? timenow - 2 * ms_per_day : timenow

// Step 2: roll back if pre-market
adjusted := current_hhmm < 930 ? adjusted - ms_per_day : adjusted

// Step 3: handle edge case where step 2 rollback lands on a weekend
dow2      = dayofweek(adjusted)
adjusted := dow2 == dayofweek.saturday ? adjusted - ms_per_day : dow2 == dayofweek.sunday ? adjusted - 2 * ms_per_day : adjusted

current_day       = dayofmonth(adjusted)
current_day_month = month(adjusted)
current_day_year  = year(adjusted)

// ── Previous trading day (used for 2D AVWAP) ───────────────────────
prev_adjusted  = adjusted - ms_per_day
dow3           = dayofweek(prev_adjusted)
prev_adjusted := dow3 == dayofweek.saturday ? prev_adjusted - ms_per_day : dow3 == dayofweek.sunday ? prev_adjusted - 2 * ms_per_day : prev_adjusted

prev_day   = dayofmonth(prev_adjusted)
prev_month = month(prev_adjusted)
prev_year  = year(prev_adjusted)

// ── Period boundary detection ──────────────────────────────────────
new_year  = ta.change(year)       != 0
new_month = ta.change(month)      != 0
new_week  = ta.change(weekofyear) != 0
new_day   = ta.change(dayofmonth) != 0

// ── Price * Volume accumulators ────────────────────────────────────
// Each accumulator resets at the start of its period and builds
// a running sum of (price * volume) and volume for AVWAP calculation
var float ytd_pv = 0.0
var float ytd_v  = 0.0
var float mtd_pv = 0.0
var float mtd_v  = 0.0
var float wtd_pv = 0.0
var float wtd_v  = 0.0
var float d1_pv  = 0.0
var float d1_v   = 0.0
var float d2_pv  = 0.0
var float d2_v   = 0.0
var float c1_pv  = 0.0
var float c1_v   = 0.0
var float c2_pv  = 0.0
var float c2_v   = 0.0
var float c3_pv  = 0.0
var float c3_v   = 0.0

// YTD: resets on first bar of each new year
if new_year
    ytd_pv := src * volume
    ytd_v  := volume
else
    ytd_pv += src * volume
    ytd_v  += volume

// MTD: resets on first bar of each new month
if new_month
    mtd_pv := src * volume
    mtd_v  := volume
else
    mtd_pv += src * volume
    mtd_v  += volume

// WTD: resets on first bar of each new week
if new_week
    wtd_pv := src * volume
    wtd_v  := volume
else
    wtd_pv += src * volume
    wtd_v  += volume

// 1D: resets on first bar of each new trading day
if new_day
    d1_pv := src * volume
    d1_v  := volume
else
    d1_pv += src * volume
    d1_v  += volume

// 2D: resets at the open of the previous trading day and accumulates
// continuously through today, giving a true 2-day AVWAP
if new_day and dayofmonth == prev_day and month == prev_month and year == prev_year
    d2_pv := src * volume
    d2_v  := volume
else if (dayofmonth == prev_day and month == prev_month and year == prev_year) or (dayofmonth == current_day and month == current_day_month and year == current_day_year)
    d2_pv += src * volume
    d2_v  += volume

// Custom 1: resets on the anchor date and accumulates forward indefinitely
if dayofmonth == c1_day and month == c1_month and year == c1_year and new_day
    c1_pv := src * volume
    c1_v  := volume
else if (dayofmonth == c1_day and month == c1_month and year == c1_year) or (year > c1_year) or (year == c1_year and month > c1_month) or (year == c1_year and month == c1_month and dayofmonth > c1_day)
    c1_pv += src * volume
    c1_v  += volume

// Custom 2
if dayofmonth == c2_day and month == c2_month and year == c2_year and new_day
    c2_pv := src * volume
    c2_v  := volume
else if (dayofmonth == c2_day and month == c2_month and year == c2_year) or (year > c2_year) or (year == c2_year and month > c2_month) or (year == c2_year and month == c2_month and dayofmonth > c2_day)
    c2_pv += src * volume
    c2_v  += volume

// Custom 3
if dayofmonth == c3_day and month == c3_month and year == c3_year and new_day
    c3_pv := src * volume
    c3_v  := volume
else if (dayofmonth == c3_day and month == c3_month and year == c3_year) or (year > c3_year) or (year == c3_year and month > c3_month) or (year == c3_year and month == c3_month and dayofmonth > c3_day)
    c3_pv += src * volume
    c3_v  += volume

// ── AVWAP calculations ─────────────────────────────────────────────
ytd_avwap = ytd_pv / ytd_v
mtd_avwap = mtd_pv / mtd_v
wtd_avwap = wtd_pv / wtd_v
d1_avwap  = d1_pv  / d1_v
d2_avwap  = d2_pv  / d2_v
c1_avwap  = c1_v   > 0 ? c1_pv / c1_v : na
c2_avwap  = c2_v   > 0 ? c2_pv / c2_v : na
c3_avwap  = c3_v   > 0 ? c3_pv / c3_v : na

// ── Display filters ────────────────────────────────────────────────
// Each filter ensures only the bars belonging to the current period
// are plotted, hiding all historical periods
in_current_year  = year       == current_year
in_current_month = year       == current_year  and month      == current_month
in_current_week  = weekofyear == current_week  and year       == current_year
in_1d            = dayofmonth == current_day   and month      == current_day_month and year == current_day_year
in_2d            = (dayofmonth == current_day and month == current_day_month and year == current_day_year) or (dayofmonth == prev_day and month == prev_month and year == prev_year)
in_c1            = not na(c1_day) and ((year == c1_year and month == c1_month and dayofmonth >= c1_day) or (year == c1_year and month > c1_month) or year > c1_year)
in_c2            = not na(c2_day) and ((year == c2_year and month == c2_month and dayofmonth >= c2_day) or (year == c2_year and month > c2_month) or year > c2_year)
in_c3            = not na(c3_day) and ((year == c3_year and month == c3_month and dayofmonth >= c3_day) or (year == c3_year and month > c3_month) or year > c3_year)

// ── Plots ──────────────────────────────────────────────────────────
plot(show_ytd and in_current_year  ? ytd_avwap : na, "YTD AVWAP",      color=color.white, display=display.pane)
plot(show_mtd and in_current_month ? mtd_avwap : na, "MTD AVWAP",      color=color.yellow, display=display.pane)
plot(show_wtd and in_current_week  ? wtd_avwap : na, "WTD AVWAP",      color=color.aqua, display=display.pane)
plot(show_1d  and in_1d            ? d1_avwap  : na, "1D AVWAP",       color=color.orange, display=display.pane)
plot(show_2d  and in_2d            ? d2_avwap  : na, "2D AVWAP",       color=color.fuchsia, display=display.pane)
plot(show_c1  and in_c1            ? c1_avwap  : na, "Custom 1 AVWAP", color=color.lime, display=display.pane)
plot(show_c2  and in_c2            ? c2_avwap  : na, "Custom 2 AVWAP", color=color.red, display=display.pane)
plot(show_c3  and in_c3            ? c3_avwap  : na, "Custom 3 AVWAP", color=color.purple, display=display.pane)

// ── Label helper function ──────────────────────────────────────────
// Places a label to the right of the last bar at the AVWAP price.
// labelCount staggers labels horizontally so they don't overlap.
createAvwapLabel(labelVar, avwapValue, labelText, labelColor, labelCount) =>
    baseOffset = 2
    increment  = 3
    label.delete(labelVar)
    label.new(
        x         = bar_index + baseOffset + labelCount * increment,
        y         = avwapValue,
        text      = labelText,
        xloc      = xloc.bar_index,
        style     = label.style_label_left,
        color     = labelColor,
        textcolor = color.black,
        size      = size.normal
    )

// ── Label variables ────────────────────────────────────────────────
var label ytd_label = na
var label mtd_label = na
var label wtd_label = na
var label d1_label  = na
var label d2_label  = na
var label c1_label  = na
var label c2_label  = na
var label c3_label  = na

// ── Draw labels on the last bar only ──────────────────────────────
// Labels are staggered right-to-left by period length so shorter
// periods appear closest to the price action
if barstate.islast and show_labels
    labelCount = 0

    if show_1d and in_1d
        d1_label  := createAvwapLabel(d1_label,  d1_avwap,  "1D",          color.orange,  labelCount)
        labelCount += 1

    if show_2d and in_2d
        d2_label  := createAvwapLabel(d2_label,  d2_avwap,  "2D",          color.fuchsia, labelCount)
        labelCount += 1

    if show_wtd and in_current_week
        wtd_label := createAvwapLabel(wtd_label, wtd_avwap, "WTD",         color.aqua,    labelCount)
        labelCount += 1

    if show_mtd and in_current_month
        mtd_label := createAvwapLabel(mtd_label, mtd_avwap, "MTD",         color.yellow,  labelCount)
        labelCount += 1

    if show_ytd and in_current_year
        ytd_label := createAvwapLabel(ytd_label, ytd_avwap, "YTD",         color.white,   labelCount)
        labelCount += 1

    if show_c1 and in_c1 and not na(c1_avwap)
        c1_label  := createAvwapLabel(c1_label,  c1_avwap,  c1_label_str,  color.lime,    labelCount)
        labelCount += 1

    if show_c2 and in_c2 and not na(c2_avwap)
        c2_label  := createAvwapLabel(c2_label,  c2_avwap,  c2_label_str,  color.red,     labelCount)
        labelCount += 1

    if show_c3 and in_c3 and not na(c3_avwap)
        c3_label  := createAvwapLabel(c3_label,  c3_avwap,  c3_label_str,  color.purple,  labelCount)
        labelCount += 1
````

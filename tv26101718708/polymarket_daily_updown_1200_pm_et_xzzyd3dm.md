# Polymarket Daily UP/Down (12:00 PM ET)

- url: https://www.tradingview.com/script/XzZyd3DM-Polymarket-Daily-UP-Down-12-00-PM-ET/
- type: indicator
- pine_id: PUB;2c353d03bd9e4644b3736176566f05a0
- version: 2.0

## Description

This script help you to draw a line at Daily Close. Support for BTC, ETH, SOL & XRP.

## Source Code

````pine
//@version=6
indicator("Daily Close (12:00 PM ET)", overlay = true)

// ─────────────────────────────────────────────
// DST Detection (EDT vs EST)
// ─────────────────────────────────────────────
is_edt(t) =>
    m = month(t, "UTC")
    if m > 3 and m < 11
        true
    else if m == 3
        d             = dayofweek(timestamp("UTC", year(t, "UTC"), 3, 1, 0, 0), "UTC")
        second_sunday = (d == 1 ? 8 : d == 2 ? 14 : d == 3 ? 13 : d == 4 ? 12 : d == 5 ? 11 : d == 6 ? 10 : 9)
        dayofmonth(t, "UTC") >= second_sunday
    else if m == 11
        d             = dayofweek(timestamp("UTC", year(t, "UTC"), 11, 1, 0, 0), "UTC")
        first_sunday  = (d == 1 ? 1 : d == 2 ? 7 : d == 3 ? 6 : d == 4 ? 5 : d == 5 ? 4 : d == 6 ? 3 : 2)
        dayofmonth(t, "UTC") < first_sunday
    else
        false

// ─────────────────────────────────────────────
// Target Time Calculation
// ─────────────────────────────────────────────
target_hour = is_edt(timenow) ? 16 : 17          // 12:00 PM ET in UTC

// Today's 12:00 PM ET timestamp
today_year   = year(timenow,       "UTC")
today_month  = month(timenow,      "UTC")
today_day    = dayofmonth(timenow, "UTC")
today_target = timestamp("UTC", today_year, today_month, today_day, target_hour, 0)

// If today's 12:00 PM ET has already passed → use today, else → use yesterday
target_time  = timenow >= today_target ? today_target : today_target - 86400000

// ─────────────────────────────────────────────
// Fetch 1-Min Data (works on any timeframe)
// ─────────────────────────────────────────────
[m1_close, m1_time] = request.security(
     syminfo.tickerid, "1",
     [close, time],
     lookahead = barmerge.lookahead_on
     )

// ─────────────────────────────────────────────
// Find & Store the Target Bar Close
// ─────────────────────────────────────────────
var float level        = na
var float stored_level = na

if m1_time == target_time
    level := m1_close

if not na(level)
    stored_level := level

// ─────────────────────────────────────────────
// Draw Line & Label (on last bar only)
// ─────────────────────────────────────────────
var line  daily_close_line  = na
var label daily_close_label = na

if not na(stored_level) and barstate.islast

    // Line
    line.delete(daily_close_line)
    daily_close_line := line.new(
         x1     = bar_index - 1,
         y1     = stored_level,
         x2     = bar_index,
         y2     = stored_level,
         color  = color.new(color.orange, 0),
         width  = 2,
         extend = extend.both
         )

    // Label
    label.delete(daily_close_label)
    daily_close_label := label.new(
         x         = bar_index,
         y         = stored_level,
         text      = "DC: " + str.tostring(stored_level, "#.00"),
         color     = color.orange,
         textcolor = color.white,
         style     = label.style_label_left,
         size      = size.small
         )
````

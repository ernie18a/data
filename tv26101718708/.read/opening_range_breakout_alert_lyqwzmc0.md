# Opening Range Breakout Alert

- url: https://www.tradingview.com/script/lYQwZMc0-Opening-Range-Breakout-Alert/
- type: indicator
- pine_id: PUB;a58e2b672ee440dcab51544ee06dbf1e
- version: 1.0

## Description

breakout alert for any stock

// Fires an alert when ALL four conditions are true on a confirmed bar:
//   1. Close breaks above the 9:30–10:00 ET opening-range high
//   2. Current bar volume >= 1.5 × the average volume of the OR window
//   3. Price (close) is above the session VWAP
//   4. Bar time is before 11:30 AM ET (first two hours of RTH)
//
// Visual elements:
//   • Horizontal orange line at the opening-range high (after OR closes)
//   • Green up-triangle ABOVE every bar where all conditions are met
//   • Light-green background tint on every qualifying bar
//   • Blue VWAP line for context
//
// Designed for intraday timeframes (recommended: 1m, 2m, 5m, 15m).
// All times are evaluated in the America/New_York timezone, so it
// works correctly regardless of the chart's display timezone.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NHPrime83

//@version=5
indicator("Opening Range Breakout Alert", shorttitle="ORB Alert",
     overlay=true, max_lines_count=500)


// -----------------------------------------------------------------------------
// INPUTS
// -----------------------------------------------------------------------------
group_or    = "Opening Range"
or_start_h  = input.int(9,  "OR Start Hour (ET)",   minval=0, maxval=23, group=group_or)
or_start_m  = input.int(30, "OR Start Minute",      minval=0, maxval=59, group=group_or)
or_end_h    = input.int(10, "OR End Hour (ET)",     minval=0, maxval=23, group=group_or)
or_end_m    = input.int(0,  "OR End Minute",        minval=0, maxval=59, group=group_or)

group_filt  = "Filters"
cutoff_h    = input.int(11, "Alert Cutoff Hour (ET)", minval=0, maxval=23, group=group_filt)
cutoff_m    = input.int(30, "Alert Cutoff Minute",    minval=0, maxval=59, group=group_filt)
vol_mult    = input.float(1.5, "Volume Multiplier vs OR Avg",
     minval=0.1, step=0.1, group=group_filt,
     tooltip="Current bar volume must be >= this × the OR window's average volume.")

group_viz   = "Visuals"
show_vwap   = input.bool(true,  "Show VWAP line",                group=group_viz)
show_or_box = input.bool(true,  "Highlight OR window background", group=group_viz)


// -----------------------------------------------------------------------------
// TIME / SESSION HELPERS — always evaluated in Eastern Time
// -----------------------------------------------------------------------------
TZ = "America/New_York"

// Current bar's minute-of-day in ET (e.g., 9:30 -> 570, 11:30 -> 690).
bar_min_of_day  = hour(time, TZ) * 60 + minute(time, TZ)
prev_min_of_day = hour(time[1], TZ) * 60 + minute(time[1], TZ)

or_start_mod    = or_start_h * 60 + or_start_m   // 570 at default 9:30 ET
or_end_mod      = or_end_h   * 60 + or_end_m     // 600 at default 10:00 ET
cutoff_mod      = cutoff_h   * 60 + cutoff_m     // 690 at default 11:30 ET

// Window flags
in_or_window    = bar_min_of_day >= or_start_mod and bar_min_of_day <  or_end_mod
post_or_window  = bar_min_of_day >= or_end_mod   and bar_min_of_day <  cutoff_mod

// Detect "first bar of a new OR window" — used to reset accumulators each day.
prev_in_or      = prev_min_of_day >= or_start_mod and prev_min_of_day < or_end_mod
first_or_bar    = in_or_window and not prev_in_or

// Detect the bar immediately AFTER the OR window closes — used to finalize stats.
just_closed_or  = not in_or_window and prev_in_or


// -----------------------------------------------------------------------------
// OPENING RANGE STATE — persists across bars within a session
// -----------------------------------------------------------------------------
var float or_high      = na    // highest high observed during 9:30–10:00 ET
var float or_vol_sum   = 0.0   // total volume during the OR window
var int   or_bar_count = 0     // number of bars inside the OR window
var float or_avg_vol   = na    // average per-bar volume during the OR window

if first_or_bar
    // Reset for a fresh session
    or_high      := high
    or_vol_sum   := volume
    or_bar_count := 1
    or_avg_vol   := na
else if in_or_window
    // Accumulate while inside the OR window
    or_high      := math.max(or_high, high)
    or_vol_sum   := or_vol_sum + volume
    or_bar_count := or_bar_count + 1

// Lock in the OR's average volume the instant the window closes.
if just_closed_or and or_bar_count > 0
    or_avg_vol := or_vol_sum / or_bar_count


// -----------------------------------------------------------------------------
// INDICATORS — VWAP for the price-vs-VWAP condition
// -----------------------------------------------------------------------------
vwap_val = ta.vwap


// -----------------------------------------------------------------------------
// CONDITIONS
// -----------------------------------------------------------------------------
cond_breakout = post_or_window and not na(or_high) and close > or_high
cond_volume   = not na(or_avg_vol) and volume >= or_avg_vol * vol_mult
cond_vwap     = close > vwap_val
cond_time     = bar_min_of_day < cutoff_mod

all_conditions = cond_breakout and cond_volume and cond_vwap and cond_time
     and barstate.isconfirmed   // only fire on closed bars


// -----------------------------------------------------------------------------
// VISUALS
// -----------------------------------------------------------------------------
// 1. Horizontal orange line at the opening-range high (only drawn after OR closes).
plot(post_or_window ? or_high : na, "OR High",
     color=color.new(color.orange, 0), linewidth=2, style=plot.style_linebr)

// 2. Faint orange line tracking the developing OR high while the window is open.
plot(in_or_window ? or_high : na, "OR High (developing)",
     color=color.new(color.orange, 60), linewidth=1, style=plot.style_linebr)

// 3. Green up-triangle ABOVE every bar where all conditions are met.
plotshape(all_conditions, title="Breakout",
     style=shape.triangleup, location=location.abovebar,
     color=color.new(color.green, 0), size=size.small)

// 4. Light-green background tint on every qualifying bar.
bgcolor(all_conditions ? color.new(color.green, 85) : na,
     title="Breakout Background")

// 5. Subtle background tint during the OR window itself (optional).
bgcolor(show_or_box and in_or_window ? color.new(color.gray, 92) : na,
     title="OR Window Background")

// 6. VWAP reference line (optional).
plot(show_vwap ? vwap_val : na, "VWAP",
     color=color.new(color.blue, 0), linewidth=1)


// -----------------------------------------------------------------------------
// ALERT
// -----------------------------------------------------------------------------
// Fires once per bar (on close) when all four conditions are simultaneously true.
// The message uses TradingView's built-in placeholders so the symbol, price, and
// timestamp are filled in automatically when the alert delivers.
alertcondition(all_conditions,
     title="ORB All Conditions Met",
     message="ORB BREAKOUT — Symbol: {{ticker}}  Price: {{close}}  Time: {{time}}")
````

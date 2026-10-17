# RSL after Levy +Pinescreener

- url: https://www.tradingview.com/script/zRYxUlEv-RSL-after-Levy-Pinescreener/
- type: indicator
- pine_id: PUB;decf64e2577a4d4c8b6f2e4bf79cdeb1
- version: 2.0

## Description

This Indicator calculates the Relative Strength after Levy for 130 Days (=26 Weeks).

On top of that you can set Entry and Exit Parameters (visualized as Green/Red Dashed Line).
An "open Long Position" is visualized with yellow background.

Also I added PineScreener Functionality (shows stuff like Date and Percentage of the last fictional Trade)


Just for educational purposes. Trade at your own risk!

## Source Code

````pine
//@version=6
indicator("RSL after Levy +Pinescreener", overlay = false)

// ── Inputs ───────────────────────────────────────────────────────────────────
length       = input.int(130,  "Calculation Period in Days (Default: 130D)", minval = 1)
entry_level  = input.float(1.25, "Long Entry Level", minval = 0.0, step = 0.01)
exit_level   = input.float(1.0, "Long Exit Level",  minval = 0.0, step = 0.01)
show_bg_main = input.bool(false, "Show In-Position Background on Main Chart")

// ── Daily-Data ────────────────────────────────────────────
[daily_close, daily_sma, daily_time] = request.security(
     syminfo.tickerid, "D", [close, ta.sma(close, length), time])

// ── RSL ──────────────────────────────────────────────────────────────────────
rsl          = daily_sma != 0 ? daily_close / daily_sma : na
entry_signal = rsl >= entry_level
exit_signal  = rsl <  exit_level

// ── State-Variables ──────────────────────────────────────────────────────────
var bool  in_long          = false
var float last_entry_price = na
var int   last_entry_time  = na
var float last_exit_price  = na
var int   last_exit_time   = na
var float max_rsl          = na

if not na(rsl)
    bool new_in_long = in_long ? not exit_signal : entry_signal

    if new_in_long and not in_long      // Transition: Entry
        last_entry_price := daily_close
        last_entry_time  := daily_time
        max_rsl          := rsl         // Set max_rsl at Entry
    else if new_in_long and in_long     // Ongoing Position
        max_rsl          := math.max(nz(max_rsl), rsl) // Update max_rsl
    else if not new_in_long             // No Position
        max_rsl          := na          // Reset

    if not new_in_long and in_long      // Transition: Exit
        last_exit_price  := daily_close
        last_exit_time   := daily_time

    in_long := new_in_long

// ── Date-Encoding for PineScreener: YY * 1 000 000 + MM * 1 000 + DD ────────────────────────
date_encode(t) =>
    na(t) ? na : float((year(t) % 100) * 1000000 + month(t) * 1000 + dayofmonth(t))

entry_date = date_encode(last_entry_time)
exit_date  = date_encode(last_exit_time)

// ── % since last Entry / Exit ──────────────────────────────────────────────
pct_entry = not na(last_entry_price) ? (daily_close / last_entry_price - 1) * 100 : na
pct_exit  = not na(last_exit_price)  ? (daily_close / last_exit_price  - 1) * 100 : na

// ── PineScreener Logic ───────────────────────────────────────────
screener_entry_date = entry_date
screener_pct_entry  = pct_entry

screener_exit_date  = in_long ? na : exit_date
screener_pct_exit   = in_long ? na : pct_exit

screener_sort_date  = in_long ? screener_entry_date : screener_exit_date

screener_highest_rsl = (in_long and rsl < max_rsl) ? max_rsl : na
since_highest_rsl = rsl - screener_highest_rsl

// ── Chart-Plots ──────────────────────────────────────────────────────────────
plot(rsl,         "RSL",         color = rsl >= 1 ? color.green : color.red, linewidth = 2, precision = 2)
plot(entry_level, "Long Entry Level", color = color.new(color.green, 30), display = display.pane, linestyle = plot.linestyle_dashed)
plot(exit_level,  "Long Exit Level",  color = color.new(color.red,   30), display = display.pane, linestyle = plot.linestyle_dashed)
bgcolor(in_long ? color.new(color.yellow, 85) : na, title = "Show Lpen Long Position")
bgcolor(show_bg_main and in_long ? color.new(color.yellow, 80) : na, force_overlay = true)

// ── PineScreener-Plots ────────────────────────
plot(screener_highest_rsl, "Highest RSL since last Entry", display = display.pine_screener, precision = 2)
plot(since_highest_rsl,    "Since highest RSL", color = math.abs(since_highest_rsl) > 0.4 ? color.red : na, display = display.pine_screener, precision = 2)
plot(screener_entry_date,  "RSL Last Entry (YY,oMM,oDD.oo)", display = display.pine_screener, precision = 2)
plot(screener_pct_entry,   "RSL Price-Diff Entry %",         display = display.pine_screener, precision = 1)
plot(screener_exit_date,   "RSL Last Exit  (YY,oMM,oDD.oo)", display = display.pine_screener, precision = 2)
plot(screener_pct_exit,    "RSL Price-Diff Exit %",          display = display.pine_screener, precision = 1)
plot(screener_sort_date,   "RSL Date SORT  (YY,oMM,oDD.oo)", display = display.pine_screener, precision = 2)
````

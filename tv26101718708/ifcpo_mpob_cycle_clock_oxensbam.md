# iFCPO MPOB Cycle Clock

- url: https://www.tradingview.com/script/OXenSbAm-iFCPO-MPOB-Cycle-Clock/
- type: indicator
- pine_id: PUB;67eaf45f97f44c7ebc2914c63ddcb18d
- version: 2.0

## Description

MPOB Cycle Clock — countdown to next Malaysian Palm Oil Board stockpiles release with post-release ATR multiplier context.

iFCPO Free-Tier CONTEXT layer. Use as size/SL adjustment cue, not as entry trigger.

MPOB releases monthly stockpiles ~10th of each month. Post-release window (10th-12th) historically shows 1.4-1.8x the 20-day baseline ATR. The status table shows: days to next release, current phase (NOW / close / soon / far), live ATR vs 40-bar baseline, and a trade-adjustment cue (Widen SL 15->25 inside MPOB window).

Pair with: iFCPO MPOB Spike (event flag), iFCPO Wick Hunter (entry trigger), iFCPO Session Law (PM window).

iFCPO Free Hero Stack designed for Bursa Malaysia FCPO traders.

## Source Code

````pine
//@version=6
// iFCPO MPOB Cycle Clock — countdown to next MPOB stockpiles release + measured post-release ATR multiplier
// Tier: FREE | Category: Statistics / Calendar | Free-Tier CONTEXT layer (silent)
// MPOB rhythm: Malaysian Palm Oil Board releases monthly stockpiles ~10th of each month (shifted off weekends).
//   Heuristic baseline: post-release (10th-12th) ATR typically expands vs 20-day baseline.
//   This script measures it live — `ATR mult (live)` row shows current; `ATR mult (60 post-window bars)` is the rolling avg.
// Differentiation vs mpob-volume-spike: this is the PLANNING/seasonality view (what to expect, history, ATR drift).
// Spike is the LIVE event detector (3× volume firing on the day). Use both: Clock for planning, Spike for triggering.
// Pair with: mpob-volume-spike (event flag), wick-hunter-lite (entry), session-law-enforcer (window), regime-meter
// Use as a SIZE / SL adjustment cue — NOT an entry signal.
indicator("iFCPO MPOB Cycle Clock", "iFCPO MPOC", overlay = true)

// ── Inputs ──
mpob_day      = input.int(10, "MPOB release day", minval = 1, maxval = 28, group = "Calendar")
post_window   = input.int(2,  "Post-release ATR window (days)", minval = 1, maxval = 5, group = "Calendar")
atr_period    = input.int(20, "ATR baseline period", minval = 5, group = "Detection")
show_table    = input.bool(true, "Show countdown + stats table", group = "Display")
show_clock    = input.bool(true, "Show clock arc on chart edge", group = "Display")
table_pos     = input.string("top_right", "Table position", options = ["top_right","top_left","bottom_right","bottom_left"], group = "Display")

// ── Calendar ──
TZ = "Asia/Kuala_Lumpur"
dom = dayofmonth(time, TZ)
mo  = month(time, TZ)
yr  = year(time, TZ)

// Proper days-in-current-month (handles leap years + 30/31 day months)
is_leap = (yr % 4 == 0 and yr % 100 != 0) or yr % 400 == 0
days_in_mo = mo == 2 ? (is_leap ? 29 : 28) : (mo == 4 or mo == 6 or mo == 9 or mo == 11) ? 30 : 31

// Effective release day — if MPOB day falls Sat/Sun, shift to next Monday
target_ts  = timestamp(TZ, yr, mo, mpob_day, 0, 0)
target_dow = dayofweek(target_ts, TZ)
effective_mpob_day = target_dow == dayofweek.saturday ? mpob_day + 2 : target_dow == dayofweek.sunday ? mpob_day + 1 : mpob_day

days_to_next = dom <= effective_mpob_day ? effective_mpob_day - dom : (days_in_mo - dom) + effective_mpob_day

in_window      = math.abs(dom - effective_mpob_day) <= post_window
in_post_window = dom >= effective_mpob_day and dom <= effective_mpob_day + post_window
imminent       = days_to_next <= 1 and days_to_next > 0

// ── ATR comparison (live + measured rolling post-window average) ──
atr_now      = ta.atr(atr_period)
atr_baseline = ta.sma(atr_now, atr_period * 2)
atr_mult     = atr_baseline > 0 ? atr_now / atr_baseline : 1.0

// Real rolling-average ATR multiplier across the LAST 60 confirmed post-MPOB bars (replaces the prior decorative claim)
var float[] post_mults_hist = array.new<float>()
if in_post_window and barstate.isconfirmed and not na(atr_mult)
    array.push(post_mults_hist, atr_mult)
    if array.size(post_mults_hist) > 60
        array.shift(post_mults_hist)
atr_post_avg_real = array.size(post_mults_hist) > 0 ? array.avg(post_mults_hist) : na

// ── Visualization ──
bgcolor(in_window ? color.new(#E0B544, 92) : na, title = "MPOB window")
bgcolor(imminent ? color.new(#3B82F6, 92) : na, title = "MPOB imminent")

// Clock arc — small visual indicator of countdown progress (text-based for simplicity)
clock_phase = days_to_next <= 1 ? "🟢 NOW" : days_to_next <= 3 ? "🟡 close" : days_to_next <= 7 ? "🟠 soon" : "⚪ far"

// ── Status table ──
tbl_pos = table_pos == "top_right" ? position.top_right : table_pos == "top_left" ? position.top_left : table_pos == "bottom_right" ? position.bottom_right : position.bottom_left
var table tbl = table.new(tbl_pos, 2, 7, bgcolor = color.new(color.black, 15), border_width = 1, border_color = color.new(color.gray, 60))
if show_table and barstate.islast
    table.cell(tbl, 0, 0, "iFCPO • MPOB Clock", bgcolor = color.new(#E0B544, 30), text_color = color.white, text_size = size.small)
    table.merge_cells(tbl, 0, 0, 1, 0)
    days_col = days_to_next <= 1 ? #E0B544 : days_to_next <= 3 ? color.new(#E0B544, 30) : days_to_next <= 7 ? color.new(#E0B544, 50) : color.new(color.white, 60)
    days_lbl = in_window ? "WINDOW (now)" : days_to_next > 0 ? str.tostring(days_to_next) + " days" : "today"
    table.cell(tbl, 0, 1, "Next release", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 1, days_lbl, text_color = days_col, text_size = size.small)
    table.cell(tbl, 0, 2, "Phase", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 2, clock_phase, text_color = color.white, text_size = size.tiny)
    atr_col = atr_mult >= 1.4 ? #E0B544 : atr_mult >= 1.2 ? color.new(#E0B544, 40) : color.new(color.white, 60)
    table.cell(tbl, 0, 3, "ATR vs avg", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 3, str.tostring(atr_mult, "#.##") + "× baseline", text_color = atr_col, text_size = size.tiny)
    post_avg_lbl = na(atr_post_avg_real) ? "— (collecting)" : str.tostring(atr_post_avg_real, "#.##") + "× (rolling 60-bar)"
    post_avg_col = na(atr_post_avg_real) ? color.new(color.white, 60) : atr_post_avg_real >= 1.4 ? #E0B544 : color.new(color.white, 80)
    table.cell(tbl, 0, 4, "Post-MPOB ATR avg", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 4, post_avg_lbl, text_color = post_avg_col, text_size = size.tiny)
    table.cell(tbl, 0, 5, "Trade adj", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 5, in_window ? "Widen SL 15→25 pts" : "Standard sizing", text_color = in_window ? #E0B544 : color.new(color.white, 60), text_size = size.tiny)
    table.cell(tbl, 0, 6, "Pair with", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 6, "mpob-spike, wick, regime", text_color = color.new(#3B82F6, 0), text_size = size.tiny)

// ── Chainable boolean outputs ──
plot(days_to_next,        "days_to_mpob",     display = display.data_window)
plot(in_window ? 1 : 0,   "in_mpob_window",   display = display.data_window)
plot(in_post_window ? 1 : 0, "in_post_window", display = display.data_window)
plot(atr_mult,            "atr_mult",         display = display.data_window)
plot(atr_post_avg_real,   "atr_post_avg",     display = display.data_window)
````

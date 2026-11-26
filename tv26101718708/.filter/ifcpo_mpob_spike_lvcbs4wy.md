# iFCPO MPOB Spike

- url: https://www.tradingview.com/script/LvcBs4Wy-iFCPO-MPOB-Spike/
- type: indicator
- pine_id: PUB;eaa3d0e2ea0343b5960f3a3a57650ab1
- version: 3.0

## Description

iFCPO MPOB Volume Spike — flags 3x average volume on/near MPOB release day (10th of month).

MPOB releases monthly palm oil supply/demand data on/around the 10th of each month. Volume spikes around release windows often mark institutional positioning.

Detection: volume > 3x SMA(20) AND within +/-2 days of the 10th. Gold flag above bar + bg highlight. Outputs mpob_spike + near_mpob booleans.

FREE indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO MPOB Volume Spike — flags 3x average volume on/near MPOB release day (10th of month, weekend-shifted)
// Tier: FREE | Category: Volume | Free-Tier GATE layer
// Research anchor: MPOB monthly stockpiles release ≈ 10th of month → systematic post-release range expansion
// Pair with: regime-meter (gate), wick-hunter-lite (entry), session-law-enforcer (window), mpob-cycle-clock (planning)
indicator("iFCPO MPOB Spike", "iFCPO MPOB", overlay = true, max_labels_count = 100)

// ── Inputs ──
vol_avg_period = input.int(20, "Vol average lookback", minval = 5, group = "Detection")
spike_mult     = input.float(3.0, "Spike multiplier", minval = 1.5, maxval = 10.0, step = 0.5, group = "Detection")
mpob_window    = input.int(2, "± Days from 10th", minval = 0, maxval = 5, group = "Window")
show_table     = input.bool(true, "Show research stats table", group = "Display")
show_spike_lbl = input.bool(true, "Label spikes with vol ratio", group = "Display")
show_window_bg = input.bool(true, "Tint MPOB window days", group = "Display")
table_pos      = input.string("top_right", "Table position", options = ["top_right","top_left","bottom_right","bottom_left"], group = "Display")

// ── Calendar ──
TZ = "Asia/Kuala_Lumpur"
dom = dayofmonth(time, TZ)
mo  = month(time, TZ)
yr  = year(time, TZ)

// Proper days-in-current-month (handles leap years + 30/31 day months)
is_leap = (yr % 4 == 0 and yr % 100 != 0) or yr % 400 == 0
days_in_mo = mo == 2 ? (is_leap ? 29 : 28) : (mo == 4 or mo == 6 or mo == 9 or mo == 11) ? 30 : 31

// Effective release day — if 10th is Sat/Sun, MPOB shifts to next Monday
target_ts  = timestamp(TZ, yr, mo, 10, 0, 0)
target_dow = dayofweek(target_ts, TZ)
effective_mpob_day = target_dow == dayofweek.saturday ? 12 : target_dow == dayofweek.sunday ? 11 : 10

near_mpob = math.abs(dom - effective_mpob_day) <= mpob_window

// Days to next MPOB release (using effective day + proper month length)
days_to_next = dom <= effective_mpob_day ? effective_mpob_day - dom : (days_in_mo - dom) + effective_mpob_day

// ── Volume detection ──
vol_avg = ta.sma(volume, vol_avg_period)
vol_ratio = vol_avg > 0 ? volume / vol_avg : 0
is_spike = volume > vol_avg * spike_mult
mpob_spike = near_mpob and is_spike

// ── Last spike tracking ──
var int last_spike_bar = na
var float last_spike_ratio = na
if mpob_spike
    last_spike_bar := bar_index
    last_spike_ratio := vol_ratio

bars_since_spike = na(last_spike_bar) ? na : bar_index - last_spike_bar

// ── Visualization ──
bgcolor(show_window_bg and near_mpob ? color.new(#E0B544, 90) : na, title = "MPOB window")
bgcolor(mpob_spike ? color.new(#E0B544, 70) : na, title = "MPOB spike")
plotshape(mpob_spike, "MPOB Spike", style = shape.flag, location = location.abovebar, color = color.new(#E0B544, 0), size = size.small, text = "MPOB!")

if show_spike_lbl and mpob_spike
    label.new(bar_index, high, str.tostring(vol_ratio, "#.#") + "× vol",
       color = color.new(#E0B544, 30), textcolor = color.white,
       style = label.style_label_down, size = size.small)

// ── Status table ──
tbl_pos = table_pos == "top_right" ? position.top_right : table_pos == "top_left" ? position.top_left : table_pos == "bottom_right" ? position.bottom_right : position.bottom_left
var table tbl = table.new(tbl_pos, 2, 8, bgcolor = color.new(color.black, 15), border_width = 1, border_color = color.new(color.gray, 60))
if show_table and barstate.islast
    table.cell(tbl, 0, 0, "iFCPO • MPOB Spike", bgcolor = color.new(#E0B544, 30), text_color = color.white, text_size = size.small)
    table.merge_cells(tbl, 0, 0, 1, 0)
    // Days to next MPOB
    days_col = days_to_next <= 2 ? #E0B544 : near_mpob ? #1FC77E : color.new(color.white, 60)
    days_lbl = near_mpob ? "MPOB WINDOW (now)" : days_to_next > 0 ? str.tostring(days_to_next) + " days" : "today"
    table.cell(tbl, 0, 1, "Next MPOB", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 1, days_lbl, text_color = days_col, text_size = size.tiny)
    // Current vol vs avg
    vol_col = vol_ratio > 2 ? #E0B544 : vol_ratio > 1.5 ? color.new(#E0B544, 40) : color.new(color.white, 50)
    table.cell(tbl, 0, 2, "Vol ratio", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 2, str.tostring(vol_ratio, "#.##") + "× avg", text_color = vol_col, text_size = size.tiny)
    // Spike threshold
    table.cell(tbl, 0, 3, "Spike at", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 3, str.tostring(spike_mult, "#.#") + "× avg", text_color = color.new(color.white, 60), text_size = size.tiny)
    // Last spike
    last_spike_lbl = na(last_spike_bar) ? "—" : str.tostring(bars_since_spike) + " bars ago (" + str.tostring(last_spike_ratio, "#.#") + "×)"
    table.cell(tbl, 0, 4, "Last spike", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 4, last_spike_lbl, text_color = color.new(color.white, 80), text_size = size.tiny)
    // State
    state_lbl = mpob_spike ? "★ MPOB SPIKE NOW" : near_mpob ? "Window armed" : "Off-window"
    state_col = mpob_spike ? #E0B544 : near_mpob ? #1FC77E : color.new(color.white, 50)
    table.cell(tbl, 0, 5, "State", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 5, state_lbl, text_color = state_col, text_size = size.small)
    // Trade rule
    table.cell(tbl, 0, 6, "Trade adj", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 6, near_mpob ? "Widen SL 15→25" : "Standard", text_color = near_mpob ? #E0B544 : color.new(color.white, 60), text_size = size.tiny)
    // Pair-with
    table.cell(tbl, 0, 7, "Pair with", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 7, "regime, wick, mpob-cycle", text_color = color.new(#3B82F6, 0), text_size = size.tiny)

// ── Alerts ──
alertcondition(mpob_spike, title = "iFCPO MPOB Spike", message = "iFCPO MPOB Volume Spike — within 10th-of-month window with 3×+ vol vs 20-bar avg.")
alertcondition(near_mpob and not near_mpob[1], title = "MPOB Window OPEN", message = "iFCPO MPOB release window opened — expect range expansion.")

// ── Chainable boolean outputs ──
plot(mpob_spike ? 1 : 0,  "mpob_spike",  display = display.data_window)
plot(near_mpob ? 1 : 0,   "near_mpob",   display = display.data_window)
plot(volume,              "volume",      display = display.data_window)
plot(vol_avg,             "vol_avg",     display = display.data_window)
plot(vol_ratio,           "vol_ratio",   display = display.data_window)
plot(days_to_next,        "days_to_mpob",display = display.data_window)
````

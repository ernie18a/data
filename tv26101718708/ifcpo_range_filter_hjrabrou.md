# iFCPO Range Filter

- url: https://www.tradingview.com/script/HJRAbROU-iFCPO-Range-Filter/
- type: indicator
- pine_id: PUB;8b374f615df34614a338fe4b0340ea83
- version: 2.0

## Description

iFCPO Range Filter — flags range-bound vs trending regime.

Detects ranging conditions: when (highest-lowest) over N bars is less than threshold-x-ATR-x-N. Range = engines should be off (avoid trend systems). Trend = engines on.

Gold tint = RANGE. Faint green = TREND. Status table top-right with current state. Outputs is_range + range_size for chaining.

MEMBER tier indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO Range Filter — flags range-bound vs trending regime (FCPO-tuned)
// Tier: MEMBER | Category: Trend
indicator("iFCPO Range Filter", "iFCPO Rng", overlay = true)

period = input.int(20, "Lookback period", minval = 5, group = "Detection")
range_thresh = input.float(2.5, "Range/ATR threshold (lower = stricter range def)", minval = 0.5, maxval = 10.0, step = 0.5, group = "Detection",
   tooltip = "If range over N bars / ATR(N) <= threshold, market is compressed. Default 2.5 = palm-tuned.")
gate_pm = input.bool(true, "Only assess in PM 14:30-18:00 (W18 Edge Zone)", group = "Filters")

TZ = "Asia/Kuala_Lumpur"
in_pm = not na(time(timeframe.period, "1430-1800:23456", TZ))
pm_ok = not gate_pm or in_pm

atr_v = ta.atr(period)
hh = ta.highest(high, period)
ll = ta.lowest(low, period)
range_size = hh - ll

range_ratio = atr_v > 0 ? range_size / atr_v : na
is_range = pm_ok and not na(range_ratio) and range_ratio <= range_thresh
is_trend = pm_ok and not na(range_ratio) and range_ratio > range_thresh

bgcolor(is_range ? color.new(#E0B544, 92) : is_trend ? color.new(#1FC77E, 96) : na, title = "Regime")

if barstate.islast
    var table tbl = table.new(position.top_right, 2, 4, bgcolor = color.new(color.black, 25), border_width = 1, border_color = color.new(color.gray, 70))
    table.cell(tbl, 0, 0, "iFCPO Range Filter", bgcolor = color.new(#3B82F6, 30), text_color = color.white, text_size = size.small)
    table.merge_cells(tbl, 0, 0, 1, 0)
    table.cell(tbl, 0, 1, "Range/ATR", text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 1, na(range_ratio) ? "n/a" : str.tostring(range_ratio, "#.##"), text_color = color.new(#3B82F6, 0), text_size = size.tiny)
    state_lbl = is_range ? "RANGE - gate engines off" : is_trend ? "TREND - engines on" : "Outside W18 window"
    state_col = is_range ? #E0B544 : is_trend ? #1FC77E : color.gray
    table.cell(tbl, 0, 2, "State", text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 2, state_lbl, text_color = state_col, text_size = size.tiny)
    table.cell(tbl, 0, 3, "Threshold", text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 3, "<=" + str.tostring(range_thresh, "#.#"), text_color = color.new(color.white, 40), text_size = size.tiny)

plot(is_range ? 1 : 0, "is_range", display = display.data_window)
plot(is_trend ? 1 : 0, "is_trend", display = display.data_window)
plot(range_ratio, "range_ratio", display = display.data_window)
plot(in_pm ? 1 : 0, "in_pm", display = display.data_window)
````

# iFCPO DoW Heatmap

- url: https://www.tradingview.com/script/o72GSxO2-iFCPO-DoW-Heatmap/
- type: indicator
- pine_id: PUB;fc8f7d1944464ea4ae750b62b29b97a6
- version: 1.0

## Description

iFCPO DoW Edge Heatmap — Day-of-week edge classifier for FCPO PM session.

Research-anchored from W40 + W250 backtests:
- Mon/Fri: BULL (Trade) — green tint
- Tue: DEAD (Skip) — red tint
- Wed/Thu: Mid (Light) — yellow tint

Reference table in bottom-right shows the law. Outputs mon_or_fri / tuesday booleans for chaining.

FREE indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO DoW Edge Heatmap — Mon/Fri green, Tue red, Wed/Thu yellow (W40 + W250)
// Tier: FREE | Category: Statistics
indicator("iFCPO DoW Heatmap", "iFCPO DoW", overlay = true)

show_bg     = input.bool(true,  "Color bars by DoW edge", group = "Display")
show_table  = input.bool(true,  "Show DoW reference table", group = "Display")

TZ = "Asia/Kuala_Lumpur"
dow = dayofweek(time, TZ)

edge_color = dow == dayofweek.monday or dow == dayofweek.friday ? color.new(#1FC77E, 88)
           : dow == dayofweek.tuesday ? color.new(#FF3B5C, 88)
           : dow == dayofweek.wednesday or dow == dayofweek.thursday ? color.new(#E0B544, 90)
           : na

bgcolor(show_bg ? edge_color : na, title = "DoW edge")

if show_table and barstate.islast
    var table tbl = table.new(position.bottom_right, 3, 6, bgcolor = color.new(color.black, 25), border_width = 1, border_color = color.new(color.gray, 70))
    table.cell(tbl, 0, 0, "iFCPO DoW Edge",   bgcolor = color.new(#3B82F6, 30), text_color = color.white, text_size = size.small)
    table.merge_cells(tbl, 0, 0, 2, 0)
    table.cell(tbl, 0, 1, "Day",   text_color = color.new(color.white, 40), text_size = size.tiny)
    table.cell(tbl, 1, 1, "Edge",  text_color = color.new(color.white, 40), text_size = size.tiny)
    table.cell(tbl, 2, 1, "Action",text_color = color.new(color.white, 40), text_size = size.tiny)
    table.cell(tbl, 0, 2, "Mon",   text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 2, "BULL",  text_color = #1FC77E, text_size = size.tiny)
    table.cell(tbl, 2, 2, "Trade", text_color = #1FC77E, text_size = size.tiny)
    table.cell(tbl, 0, 3, "Tue",   text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 3, "DEAD",  text_color = #FF3B5C, text_size = size.tiny)
    table.cell(tbl, 2, 3, "Skip",  text_color = #FF3B5C, text_size = size.tiny)
    table.cell(tbl, 0, 4, "Wed/Thu", text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 4, "Mid",   text_color = #E0B544, text_size = size.tiny)
    table.cell(tbl, 2, 4, "Light", text_color = #E0B544, text_size = size.tiny)
    table.cell(tbl, 0, 5, "Fri",   text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 5, "BULL",  text_color = #1FC77E, text_size = size.tiny)
    table.cell(tbl, 2, 5, "Trade", text_color = #1FC77E, text_size = size.tiny)

is_mon_or_fri = dow == dayofweek.monday or dow == dayofweek.friday
is_tuesday    = dow == dayofweek.tuesday
plot(is_mon_or_fri ? 1 : 0, "mon_or_fri", display = display.data_window)
plot(is_tuesday    ? 1 : 0, "tuesday",    display = display.data_window)
````

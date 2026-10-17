# Performance Box (1M / 3M / 6M)

- url: https://www.tradingview.com/script/qpv0eyU8-Performance-Box-1M-3M-6M/
- type: indicator
- pine_id: PUB;7f4ad809156d484ba27238750ce33161
- version: 1.0

## Description

This Box shows current stock performance for 1 month, 3 month and 6 month.
Use for detect current performance in market.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ZulSyirah

//@version=5
indicator("Performance Box (1M / 3M / 6M)", overlay=true)

// --- Helper: get daily close regardless of chart timeframe
dClose = request.security(syminfo.tickerid, "D", close)

// --- Lookback periods (approx trading days)
oneMonthBars  = 21
threeMonthBars = 63
sixMonthBars   = 126

// --- Calculate returns (%)
perf_1m = (dClose - dClose[oneMonthBars]) / dClose[oneMonthBars] * 100
perf_3m = (dClose - dClose[threeMonthBars]) / dClose[threeMonthBars] * 100
perf_6m = (dClose - dClose[sixMonthBars]) / dClose[sixMonthBars] * 100

// --- Create table
var table perfTable = table.new(position.top_right, 2, 4, border_width=1)

// --- Function for color
getColor(val) =>
    val >= 0 ? color.new(color.green, 0) : color.new(color.red, 0)

// --- Update table
if barstate.islast
    table.cell(perfTable, 0, 0, "Period", text_color=color.white, bgcolor=color.gray)
    table.cell(perfTable, 1, 0, "Return %", text_color=color.white, bgcolor=color.gray)

    table.cell(perfTable, 0, 1, "1 Month")
    table.cell(perfTable, 1, 1, str.tostring(perf_1m, "#.##") + "%", text_color=getColor(perf_1m))

    table.cell(perfTable, 0, 2, "3 Months")
    table.cell(perfTable, 1, 2, str.tostring(perf_3m, "#.##") + "%", text_color=getColor(perf_3m))

    table.cell(perfTable, 0, 3, "6 Months")
    table.cell(perfTable, 1, 3, str.tostring(perf_6m, "#.##") + "%", text_color=getColor(perf_6m))
````

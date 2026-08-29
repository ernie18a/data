<!-- tradingview-pine-id: PUB;e54e46d3f88640009c74bac1d20b5337 -->
<!-- tradingviewscripts-format: 1 -->
# Daily MA (SMA/EMA)

Source: https://www.tradingview.com/script/8J7144DV-SMA-EMA-7-30-90-182-365-days/

## Description

No matter what time interval do you use, this tool always shows moving averages for 7, 30, 90, 182, 365 days.
You can chose simple or exponential MA in settings.
Helpful in searching the optimal moment to enter a long-term investment.

---

## Source Code

````pine
//@version=6
indicator("Daily MA (SMA/EMA)", overlay=true)

// --- Settings ---
maType = input.string("SMA", title="MA Type", options=["SMA", "EMA"], tooltip="Select the calculation method. SMA (Simple) or EMA (Exponential).")

len1 = input.int(7, title="Period 1 (Days)", minval=1)
len2 = input.int(30, title="Period 2 (Days)", minval=1)
len3 = input.int(90, title="Period 3 (Days)", minval=1)
len4 = input.int(182, title="Period 4 (Days)", minval=1)
len5 = input.int(365, title="Period 5 (Days)", minval=1)

// --- Calculation Function ---
calc_ma(source, length, type) =>
    switch type
        "EMA" => ta.ema(source, length)
        "SMA" => ta.sma(source, length)
        => ta.sma(source, length)

// --- Requesting Daily (1D) Data ---
// Obliczenia wykonywane są w kontekście interwału "1D", a nie interwału bieżącego wykresu
out1 = request.security(syminfo.tickerid, "1D", calc_ma(close, len1, maType))
out2 = request.security(syminfo.tickerid, "1D", calc_ma(close, len2, maType))
out3 = request.security(syminfo.tickerid, "1D", calc_ma(close, len3, maType))
out4 = request.security(syminfo.tickerid, "1D", calc_ma(close, len4, maType))
out5 = request.security(syminfo.tickerid, "1D", calc_ma(close, len5, maType))

// --- Plotting ---
plot(out1, color=color.new(color.yellow, 0), title="MA 7D", linewidth=1)
plot(out2, color=color.new(color.lime, 0), title="MA 30D", linewidth=1)
plot(out3, color=color.new(color.aqua, 0), title="MA 90D", linewidth=2)
plot(out4, color=color.new(color.orange, 0), title="MA 183D", linewidth=2)
plot(out5, color=color.new(color.red, 0), title="MA 365D", linewidth=3)
````

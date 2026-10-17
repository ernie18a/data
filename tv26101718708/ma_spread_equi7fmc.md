# MA Spread

- url: https://www.tradingview.com/script/EQUi7fmC-MA-Spread/
- type: indicator
- pine_id: PUB;9306ff03d2634fddb0602d52c1193c5f
- version: 1.0

## Description

A simple indicator that measures the market distance from moving averages.

## Source Code

````pine
//@version=6
indicator(title="MA Spread", shorttitle="MASpread")

// Inputs for Fast MA
fast_ma_type = input.string("EMA", "Fast MA Type", options=["EMA", "SMA"], group="Fast MA Settings")
len1 = input.int(50, "Fast MA Length", minval=1, group="Fast MA Settings")
src1 = input.source(close, "Fast MA Source", group="Fast MA Settings")

// Inputs for Slow MA
slow_ma_type = input.string("EMA", "Slow MA Type", options=["EMA", "SMA"], group="Slow MA Settings")
len2 = input.int(200, "Slow MA Length", minval=1, group="Slow MA Settings")
src2 = input.source(close, "Slow MA Source", group="Slow MA Settings")

// Calculate Fast MA based on user selection
fast_ma = fast_ma_type == "SMA" ? ta.sma(src1, len1) : ta.ema(src1, len1)

// Calculate Slow MA based on user selection
slow_ma = slow_ma_type == "SMA" ? ta.sma(src2, len2) : ta.ema(src2, len2)

// Calculate spreads
spread_50d = ((close / fast_ma) - 1) * 100
spread_200d = ((close / slow_ma) - 1) * 100

// Plot horizontal line at 0
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dashed)

// Plot spreads
plot(spread_50d, "Fast MA Spread", color=color.black)
plot(spread_200d, "Slow MA Spread", color=color.gray)
````

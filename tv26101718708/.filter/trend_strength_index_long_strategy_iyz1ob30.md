# Trend Strength Index Long Strategy

- url: https://www.tradingview.com/script/iyz1oB30-Trend-Strength-Index-Long-Strategy/
- type: strategy
- pine_id: PUB;9c5e3dc5278845698a944b2ed38f13c0
- version: 1.0

## Description

[b]📈 Trend Strength Index Long Strategy[/b]

This strategy combines the Trend Strength Index (TSI) with a Volume-Weighted Moving Average (VWMA) to identify high-probability long entries based on trend momentum and price confirmation.

[list]
[*]📊 [b]TSI Calculation[/b]: Measures correlation between price and time (bar index) over a user-defined period. Strong TSI values indicate trend momentum.
[*]📏 [b]VWMA Filter[/b]: Confirms bullish bias when price is above the VWMA.
[*]🚀 [b]Entry Condition[/b]: Long position is triggered when TSI crosses above -0.65 and price is above VWMA.
[*]🔒 [b]Exit Condition[/b]: Position is closed when TSI crosses above 0.65.
[*]🎨 [b]Visuals[/b]: Gradient fills highlight bullish and bearish zones. VWMA is plotted for trend context.
[/list]
[list]
[*]🧮 TSI Length: Adjustable (default 14)
[*]📐 VWMA Length: Adjustable (default 55)
[*]💸 Commission: 0.1% per trade
[*]📊 Position Size: 75% of equity
[*]⚙️ Slippage: 10 ticks
[/list]

✅ Best used in trending markets with steady momentum.
⚠️ Avoid in choppy or range-bound conditions.

## Source Code

````pine
//@version=6
strategy('Trend Strength Index Long Strategy', commission_type = strategy.commission.percent, commission_value = 0.1, default_qty_type = strategy.percent_of_equity, default_qty_value = 75, slippage = 10)

period = input.int(14, 'TSI Length', minval = 2)
vwmaLength = input.int(55, 'VWMA Length', minval = 2)
tsi = ta.correlation(close, bar_index, period)

bullishColorInput = input.color(color.new(#089981, 90), 'Bullish Color')
bearishColorInput = input.color(color.new(#F23645, 90), 'Bearish Color')

tsiPlot = plot(tsi, 'Trend Strength Index',  color = #7E57C2)
hline(0, 'TSI Middle Band', color.new(#787B86, 50))
hline(0.65, 'TSI Bullish Band', color.new(bullishColorInput, 0))
hline(-0.65, 'TSI Bearish Band', color.new(bearishColorInput, 0))

midLinePlot = plot(0, color = na, editable = false, display = display.none)
fill(tsiPlot, midLinePlot, 1,  0, top_color = bullishColorInput,  bottom_color = color.new(bullishColorInput, 100), title = 'Bullish Gradient Fill')
fill(tsiPlot, midLinePlot, 0, -1, top_color = color.new(bearishColorInput, 100), bottom_color = bearishColorInput,  title = 'Bearish Gradient Fill')

vwma = ta.vwma(close, vwmaLength)

bullish = close > vwma
if ta.crossover(tsi, -0.65) and bullish
    strategy.entry('long', strategy.long)
if ta.crossover(tsi, 0.65)
    strategy.close('long')

plot(vwma, 'VWMA', #ce93d8, force_overlay = true)
````

# Dynamic 5 & 25 MA

- url: https://www.tradingview.com/script/LJ7yciNQ-Dynamic-5-25-MA/
- type: indicator
- pine_id: PUB;47dd9b2ef387484283bac4279b69cb98
- version: 1.0

## Description

This indicator displays the 5 and 25 moving averages to help traders follow trend direction and market momentum. It gives a clear visual view of price movement on TradingView.

## Source Code

````pine
//@version=5
indicator("Dynamic 5 & 25 MA", overlay=true, max_labels_count=500)

// Inputs
src = input.source(close, "Source")
fastLen = input.int(5, "Fast MA Length", minval=1)
slowLen = input.int(25, "Slow MA Length", minval=1)
maType = input.string("SMA", "MA Type", options=["SMA", "EMA", "WMA", "RMA"])
showSignals = input.bool(true, "Show Crossover Signals")
showFill = input.bool(true, "Fill Between MAs")

// Moving average function
maFunction(_src, _len) =>
    switch maType
        "EMA" => ta.ema(_src, _len)
        "WMA" => ta.wma(_src, _len)
        "RMA" => ta.rma(_src, _len)
        => ta.sma(_src, _len)

// Calculations
fastMA = maFunction(src, fastLen)
slowMA = maFunction(src, slowLen)

// Plots
pFast = plot(fastMA, title="Fast MA", color=color.new(color.aqua, 0), linewidth=2)
pSlow = plot(slowMA, title="Slow MA", color=color.new(color.orange, 0), linewidth=2)

fill(pFast, pSlow, color=showFill ? color.new(color.gray, 85) : na)

// Signals
buySignal = ta.crossover(fastMA, slowMA)
sellSignal = ta.crossunder(fastMA, slowMA)

plotshape(showSignals and buySignal, title="Buy", style=shape.labelup, location=location.belowbar, color=color.green, text="BUY", textcolor=color.white, size=size.tiny)
plotshape(showSignals and sellSignal, title="Sell", style=shape.labeldown, location=location.abovebar, color=color.red, text="SELL", textcolor=color.white, size=size.tiny)

// Alerts
alertcondition(buySignal, title="MA Buy Signal", message="Fast MA crossed above Slow MA")
alertcondition(sellSignal, title="MA Sell Signal", message="Fast MA crossed below Slow MA")
````

# Call Put Vega Candles_Prem

- url: https://www.tradingview.com/script/x1c31YXs-Call-Put-Vega-Candles-Prem/
- type: indicator
- pine_id: PUB;7c25dc7c6c7f475fa24aa9d337d4b21f
- version: 1.0

## Description

Call and Put options respond to Vega in the same way. Vega measures how much an option's premium changes for every 1% shift in Implied Volatility (IV). Both long calls and long puts have positive Vega, meaning their prices rise when volatility increases and fall when it drops.

## Source Code

````pine
//@version=6
indicator("Call Put Candles_Prem", overlay=false)

// Example Vega values (replace with your actual Vega calculations)
callVega = close - ta.sma(close, 20)
putVega  = ta.sma(close, 20) - close

// Call Vega Candle
callOpen  = callVega[1]
callClose = callVega
callHigh  = math.max(callOpen, callClose)
callLow   = math.min(callOpen, callClose)

// Put Vega Candle
putOpen  = putVega[1]
putClose = putVega
putHigh  = math.max(putOpen, putClose)
putLow   = math.min(putOpen, putClose)

// Plot Call Vega Candles
plotcandle(
     callOpen,
     callHigh,
     callLow,
     callClose,
     color = callClose >= callOpen ? color.green : color.red,
     title = "Call Vega Candle")

// Plot Put Vega Candles
plotcandle(
     putOpen,
     putHigh,
     putLow,
     putClose,
     color = putClose >= putOpen ? color.lime : color.orange,
     title = "Put Vega Candle")

// Zero Line (Center Meeting Point)
hline(
     0,
     title="Zero Line",
     color=color.white,
     linestyle=hline.style_dashed,
     linewidth=2)

callCrossUp   = ta.crossover(callVega, 0)
callCrossDown = ta.crossunder(callVega, 0)

plotshape(callCrossUp,
     title="Call Above Zero",
     style=shape.triangleup,
     location=location.bottom,
     color=color.lime,
     size=size.small)

plotshape(callCrossDown,
     title="Call Below Zero",
     style=shape.triangledown,
     location=location.top,
     color=color.red,
     size=size.small)
````

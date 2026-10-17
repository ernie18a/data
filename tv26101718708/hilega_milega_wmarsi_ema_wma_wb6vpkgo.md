# Hilega Milega - WMA(RSI), EMA, WMA

- url: https://www.tradingview.com/script/WB6vPkGo-Hilega-Milega-WMA-RSI-EMA-WMA/
- type: indicator
- pine_id: PUB;6aff42048a7246cf9615f3a3a1a98e7c
- version: 1.0

## Description

Designed to work with USD companion trades. confluent concept of EMA, RSI and  WMA to extend the trade returns. Can turn off RSI signal if too much noise. Added scale for some predictability. For grins let me know what your favorite time frame is, mine is 90 minutes.

## Source Code

````pine
//@version=5
indicator("Hilega Milega - WMA(RSI), EMA, WMA", overlay=false)

// Define lengths for the indicators
emaLength = input.int(3, title="EMA Length", minval=1)
wmaLength = input.int(20, title="WMA Length", minval=1)
rsiLength = input.int(9, title="RSI Length", minval=1)
wmaRsiLength = input.int(10, title="WMA on RSI Length", minval=1)

// --- Calculate the main indicators ---
ema = ta.ema(close, emaLength)
wma = ta.wma(close, wmaLength)
rsi = ta.rsi(close, rsiLength)

// --- Calculate the WMA of the RSI ---
wmaRsi = ta.wma(rsi, wmaRsiLength)

// Function to determine color based on direction
getColor(ma) =>
    ma > ma[1] ? color.new(color.green, 0) : color.new(color.red, 0)

// --- Plot the Moving Averages ---
// WMA will be the first plotted line
plot(wma, title="WMA", color=getColor(wma), linewidth=2)
// EMA will be the second plotted line
plot(ema, title="EMA", color=getColor(ema), linewidth=2)

// Add horizontal lines for the moving averages pane
hline(50, "50 Level", color=color.white, linestyle=hline.style_solid, linewidth=1)
hline(60, "60 Upper Level", color=color.new(color.gray, 50), linestyle=hline.style_solid, linewidth=1)
hline(80, "80 Upper Level", color=color.new(color.gray, 50), linestyle=hline.style_solid, linewidth=1)
hline(20, "20 Lower Level", color=color.new(color.gray, 50), linestyle=hline.style_solid, linewidth=1)
hline(40, "40 Lower Level", color=color.new(color.gray, 50), linestyle=hline.style_solid, linewidth=1)


// --- Plot the RSI and its WMA in a separate pane ---
// Plot the raw RSI line
plot(rsi, title="RSI", color=color.purple, linewidth=1)
// Plot the WMA of the RSI with dynamic color
plot(wmaRsi, title="WMA(RSI)", color=getColor(wmaRsi), linewidth=2)

// Add horizontal lines for the RSI pane
hline(70, "RSI Overbought", color=color.red, linestyle=hline.style_dashed, linewidth=1)
hline(30, "RSI Oversold", color=color.green, linestyle=hline.style_dashed, linewidth=1)

// USE confluent colors for trades, WMA to max trade return. RSI signal is optional turn off to reduce noise.
````

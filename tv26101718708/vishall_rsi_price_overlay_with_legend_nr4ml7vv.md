# Vishall - RSI Price Overlay with Legend

- url: https://www.tradingview.com/script/Nr4mL7Vv-Vishall-RSI-Price-Overlay-with-Legend/
- type: indicator
- pine_id: PUB;b289f24f6993465bb4a8e24bc3cbbdc5
- version: 1.0

## Description

Vishall - RSI Price Overlay with Legend
Vishall - RSI Price Overlay with Legend
Vishall - RSI Price Overlay with Legend
Vishall - RSI Price Overlay with Legend

## Source Code

````pine
//@version=6
indicator("RSI Price Overlay with Legend", overlay=true)

// --- RSI Calculation ---
rsiLen = input.int(14, "RSI Length")
rsiVal = ta.rsi(close, rsiLen)

// --- Color Logic ---
rsiColor = rsiVal > 70 ? color.red : 
           rsiVal > 50 ? color.lime : 
           rsiVal > 30 ? color.orange : 
           color.aqua

// Plot price with RSI-based coloring
plotcandle(open, high, low, close, color=rsiColor, wickcolor=rsiColor, bordercolor=rsiColor, title="RSI Colored Candles")

// --- Legend Table ---
var table legend = table.new(position.top_right, 2, 4, border_width=1)

if barstate.islast
    // Overbought
    table.cell(legend, 0, 0, "RSI > 70", bgcolor=color.red, text_color=color.white)
    table.cell(legend, 1, 0, "OVERBOUGHT", bgcolor=color.red, text_color=color.white)
    
    // Bullish
    table.cell(legend, 0, 1, "RSI 50-70", bgcolor=color.lime, text_color=color.black)
    table.cell(legend, 1, 1, "BULLISH", bgcolor=color.lime, text_color=color.black)
    
    // Bearish
    table.cell(legend, 0, 2, "RSI 30-50", bgcolor=color.orange, text_color=color.black)
    table.cell(legend, 1, 2, "BEARISH", bgcolor=color.orange, text_color=color.black)
    
    // Oversold
    table.cell(legend, 0, 3, "RSI < 30", bgcolor=color.aqua, text_color=color.black)
    table.cell(legend, 1, 3, "OVERSOLD", bgcolor=color.aqua, text_color=color.black)
````

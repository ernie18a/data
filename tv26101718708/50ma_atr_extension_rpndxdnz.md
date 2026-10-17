# 50MA ATR Extension

- url: https://www.tradingview.com/script/rpndxdnZ-50MA-ATR-Extension/
- type: indicator
- pine_id: PUB;0cc93ed3488a4583bdc56deeff9e46d6
- version: 1.0

## Description

This indicator measures how many 14-day ATRs price is trading away from its 50-day moving average. It's designed to identify when a trend has become unusually stretched relative to recent volatility.

## Source Code

````pine
//@version=6
indicator("50MA ATR Extension", shorttitle="50MA EXT", overlay=false)

// Inputs
maLength   = input.int(50, title="MA Length")
atrLength  = input.int(14, title="ATR Length")
smoothLen  = input.int(5, title="Smoothing Length")
maxLevel   = input.int(20, minval=2, title="Maximum Level")

// Core calculations
maValue  = ta.sma(close, maLength)
atrValue = ta.atr(atrLength)

// ATR-adjusted extension
extensionRaw = (close - maValue) / atrValue

// Optional smoothing
extension = ta.ema(extensionRaw, smoothLen)

// Plot extension
plot(extension, title="Extension", linewidth=2)

// Zero line
hline(0, "Mean", linestyle=hline.style_dotted, color=color.gray)

// Draw levels once
if barstate.isfirst
    for level = 2 to maxLevel by 2

        // Positive levels
        line.new(
             x1 = bar_index,
             y1 = level,
             x2 = bar_index + 1,
             y2 = level,
             extend = extend.both,
             style = line.style_dotted,
             color = color.gray
         )

        // Negative levels
        line.new(
             x1 = bar_index,
             y1 = -level,
             x2 = bar_index + 1,
             y2 = -level,
             extend = extend.both,
             style = line.style_dotted,
             color = color.gray
         )
````

<!-- tradingview-pine-id: PUB;e8a61b06d12942c8a4d324ab322f9310 -->
<!-- tradingviewscripts-format: 1 -->
# RV Stocks

Source: https://www.tradingview.com/script/Q8ZDCD2G-RV-Stocks/

## Description

use 5 min chart 
Entry: Buy just above the 5-minute high (for a long trade) or sell below the 5-minute low (for a short trade).Stop-Loss: Place the stop-loss right at the opposite end of the 5-minute range (the low of the candle for a buy order) to limit risk.Target: Aim for a 1:1.5 or 1:2 risk-to-reward ratio, as these intraday moves usually play out quickly within the first 15 to 30 minutes.

---

## Source Code

````pine
//@version=6
indicator("RV Stocks", overlay=true)

volLen = input.int(75, "Volume Lookback")

highCond =
     high > high[1] and
     high > high[2] and
     high > high[3] and
     high > high[4] and
     high > high[5]

lowCond =
     low < low[1] and
     low < low[2] and
     low < low[3] and
     low < low[4] and
     low < low[5]

volCond = volume > ta.highest(volume, volLen)[1]

signal = highCond and lowCond and volCond

plotshape(signal,
     title="Scanner Signal",
     location=location.belowbar,
     style=shape.triangleup,
     color=color.lime,
     size=size.large,
     text="BUY")

bgcolor(signal ? color.new(color.green,85) : na)

alertcondition(signal,
 title="Scanner Alert",
 message="High-Low Breakout with Highest Volume")
````

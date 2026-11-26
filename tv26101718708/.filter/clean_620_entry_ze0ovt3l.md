# Clean 620 Entry

- url: https://www.tradingview.com/script/ZE0OVt3l-Clean-620-Entry/
- type: indicator
- pine_id: PUB;7b6cf4584bdb4ceba50b616c998bf8a8
- version: 1.0

## Description

A clean implementation of Gil Morales' well-known 620 intraday timing method. Designed to help traders identify potential entry and exit points using a combination of short-term trend shifts and momentum changes on a 5-minute chart.

Core Components

6-period EMA
20-period EMA
MACD (6,20,9)
Optional VWAP confirmation

Bullish Signals

6 EMA crosses above 20 EMA
MACD turns positive
Momentum begins to improve
Can be used to confirm long entries near key support levels

Bearish Signals

6 EMA crosses below 20 EMA
MACD turns negative
Momentum begins to weaken
Can be used to confirm exits or short-sale entries near resistance

Best Use
The 620 is intended as a timing tool rather than a standalone trading system. It works best when combined with higher-timeframe analysis, support and resistance levels, volume analysis, and overall market context.

Disclaimer
This indicator is provided for educational and informational purposes only and should not be considered financial advice. Always perform your own due diligence and risk management before making trading

## Source Code

````pine
//@version=6
indicator("Clean 620 Entry", overlay=true)

// Inputs
fastLen = input.int(6, "Fast EMA")
slowLen = input.int(20, "Slow EMA")
macdSignal = input.int(9, "MACD Signal")
showVWAP = input.bool(true, "Show VWAP")

// 620 EMAs
ema6 = ta.ema(close, fastLen)
ema20 = ta.ema(close, slowLen)

// MACD using 6/20/9
macdLine = ema6 - ema20
signalLine = ta.ema(macdLine, macdSignal)

// VWAP
vwapLine = ta.vwap(close)

// Long / Short Conditions
longEntry = ta.crossover(ema6, ema20) and macdLine > signalLine
shortEntry = ta.crossunder(ema6, ema20) and macdLine < signalLine

// Plot EMAs
plot(ema6, "6 EMA", color=color.green, linewidth=2)
plot(ema20, "20 EMA", color=color.red, linewidth=2)
plot(showVWAP ? vwapLine : na, "VWAP", color=color.blue, linewidth=2)

// Entry Labels
plotshape(
     longEntry,
     title="Long",
     text="LONG",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     textcolor=color.white,
     size=size.small
)

plotshape(
     shortEntry,
     title="Short",
     text="SHORT",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     textcolor=color.white,
     size=size.small
)

// Alerts
alertcondition(
     longEntry,
     title="620 Long Alert",
     message="620 LONG: 6 EMA crossed above 20 EMA with MACD confirmation"
)

alertcondition(
     shortEntry,
     title="620 Short Alert",
     message="620 SHORT: 6 EMA crossed below 20 EMA with MACD confirmation"
)
````

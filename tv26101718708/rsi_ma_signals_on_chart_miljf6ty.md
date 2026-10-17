# RSI MA Signals on Chart

- url: https://www.tradingview.com/script/MiljF6tY/
- type: indicator
- pine_id: PUB;3795a3c5bccc445eb997cde696c531a2
- version: 1.0

## Description

RSI MA Signals

This indicator is a momentum analysis tool that displays buy and sell signals on the main price chart based on crossovers between the RSI and its moving average.

Both the RSI period and the RSI moving average period are set to 14 by default.

 Features

■ RSI and RSI Moving Average Crossovers

A buy signal is generated when the RSI crosses above its moving average.

A sell signal is generated when the RSI crosses below its moving average.

■ Signals Displayed on the Main Chart

Trading signals are displayed directly on the price chart.

* Buy signals are shown below the candles.
* Sell signals are shown above the candles.

This allows traders to identify potential entry and exit points while viewing price action.

■ Confirmed Candle Signals

Signals are generated only after the candle has closed.

As a result, confirmed historical signals do not change after they are displayed.

 Notes

This indicator generates trading signals based on crossovers between the RSI and its moving average using confirmed candles.

Because signals are evaluated only after candle close, previously confirmed signals are not modified afterward.

For improved analysis, consider using this indicator alongside other methods such as trend analysis, support and resistance levels, and volume analysis.

## Source Code

````pine
//@version=6
indicator("RSI MA Signals on Chart", shorttitle="RSI MA Signals", overlay=true)

// === Inputs
rsiLen = input.int(14, title="RSI Length", minval=1)
maLen  = input.int(14, title="RSI MA Length", minval=1)

// === RSI and RSI MA
rsiValue = ta.rsi(close, rsiLen)
rsiMA    = ta.sma(rsiValue, maLen)

// === Confirmed-bar signals
buySignal  = ta.crossover(rsiValue, rsiMA) and barstate.isconfirmed
sellSignal = ta.crossunder(rsiValue, rsiMA) and barstate.isconfirmed

// === Plot signals on main chart
plotshape(
     buySignal,
     title="Buy Signal",
     text="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.lime,
     textcolor=color.white,
     size=size.small
)

plotshape(
     sellSignal,
     title="Sell Signal",
     text="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     textcolor=color.white,
     size=size.small
)

// === Alerts
alertcondition(buySignal, title="Buy Alert", message="RSI crossed above RSI MA after candle close.")
alertcondition(sellSignal, title="Sell Alert", message="RSI crossed below RSI MA after candle close.")
````

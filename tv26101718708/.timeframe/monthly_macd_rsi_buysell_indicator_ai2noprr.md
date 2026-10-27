# Monthly MACD + RSI Buy/Sell Indicator

- url: https://www.tradingview.com/script/ai2NOprR-Monthly-MACD-RSI-Buy-Sell-Indicator/
- type: indicator
- pine_id: PUB;c2ec1e5234d34a39956ffb60ab12f4fc
- version: 1.0

## Description

Indicator is based on monthly MACD crossing signal line above and RSI above 55 to indicate a BUY signal and Monthly MACD crossing below signal line to indicate SELL.  May be good strategy for some type of stocks like metals

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © vkdmeena2707
//@version=6
indicator("Monthly MACD + RSI Buy/Sell Indicator", overlay = true)

// Inputs
fastLen   = input.int(12, "MACD Fast Length", minval = 1)
slowLen   = input.int(26, "MACD Slow Length", minval = 1)
signalLen = input.int(9,  "MACD Signal Length", minval = 1)
rsiLen    = input.int(14, "RSI Length", minval = 1)
rsiLevel  = input.float(55.0, "Monthly RSI Buy Level")

// Confirmed monthly MACD line from previous closed monthly candle
monthlyMacdLine = request.security(
    syminfo.tickerid,
    "M",
    (ta.ema(close, fastLen) - ta.ema(close, slowLen))[1],
    lookahead = barmerge.lookahead_on
)

// Confirmed monthly Signal line from previous closed monthly candle
monthlySignalLine = request.security(
    syminfo.tickerid,
    "M",
    ta.ema(ta.ema(close, fastLen) - ta.ema(close, slowLen), signalLen)[1],
    lookahead = barmerge.lookahead_on
)

// Confirmed monthly RSI from previous closed monthly candle
monthlyRsi = request.security(
    syminfo.tickerid,
    "M",
    ta.rsi(close, rsiLen)[1],
    lookahead = barmerge.lookahead_on
)

// Detect first bar of a new month on current chart timeframe
newMonth = ta.change(time("M")) != 0

// Signal logic based on confirmed monthly values only
buySignal  = newMonth and ta.crossover(monthlyMacdLine, monthlySignalLine) and monthlyRsi > rsiLevel
sellSignal = newMonth and ta.crossunder(monthlyMacdLine, monthlySignalLine)

// Plot buy/sell labels
plotshape(
    buySignal,
    title = "BUY",
    text = "BUY",
    style = shape.labelup,
    location = location.belowbar,
    color = color.green,
    textcolor = color.white,
    size = size.small
)

plotshape(
    sellSignal,
    title = "SELL",
    text = "SELL",
    style = shape.labeldown,
    location = location.abovebar,
    color = color.red,
    textcolor = color.white,
    size = size.small
)

// Optional alert conditions
alertcondition(
    buySignal,
    title = "Monthly BUY Alert",
    message = "BUY: Monthly MACD crossed above Signal and Monthly RSI is above 55."
)

alertcondition(
    sellSignal,
    title = "Monthly SELL Alert",
    message = "SELL: Monthly MACD crossed below Signal."
)
````

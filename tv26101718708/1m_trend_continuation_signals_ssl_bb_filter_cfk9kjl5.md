# 1m Trend Continuation Signals - SSL + BB Filter

- url: https://www.tradingview.com/script/CfK9KjL5-1m-Trend-Continuation-Signals-SSL-BB-Filter/
- type: indicator
- pine_id: PUB;21ede04b565d4f25903bb7fd218bfd1d
- version: 1.0

## Description

This can be used exclusively for index trading for shorter duration. one can catch intra day short term trend

## Source Code

````pine
//@version=6
indicator("1m Trend Continuation Signals - SSL + BB Filter", overlay=true)

//====================================================
// INPUTS
//====================================================
emaLength = input.int(200, "Trend EMA Length")

// SSL Settings
sslLength = input.int(10, "SSL Channel Length", group="SSL Settings")

// Bollinger Band Settings
bbLength = input.int(150, "BB Length", minval=1, group="Bollinger Band Filter")
bbStdDev = input.float(2.0, "BB Std Dev", step=0.1, group="Bollinger Band Filter")

//====================================================
// TREND EMA
//====================================================
trendEma = ta.ema(close, emaLength)

//====================================================
// SSL CHANNEL
//====================================================
smaHigh = ta.sma(high, sslLength)
smaLow  = ta.sma(low, sslLength)

var int hlv = 0
hlv := close > smaHigh ? 1 :
       close < smaLow  ? -1 :
       hlv[1]

sslUp   = hlv < 0 ? smaLow  : smaHigh
sslDown = hlv < 0 ? smaHigh : smaLow

//====================================================
// BOLLINGER BANDS
//====================================================
bbBasis = ta.sma(close, bbLength)
bbDev   = ta.stdev(close, bbLength) * bbStdDev

bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev

//====================================================
// TREND CONDITIONS
//====================================================
uptrend   = close > trendEma
downtrend = close < trendEma

sslBullish = ta.crossover(sslUp, sslDown)
sslBearish = ta.crossunder(sslUp, sslDown)

//====================================================
// BOLLINGER FILTER
//====================================================
closeAboveUpperBB = close > bbUpper
closeBelowLowerBB = close < bbLower

buySignal  = uptrend and sslBullish and closeAboveUpperBB
sellSignal = downtrend and sslBearish and closeBelowLowerBB

//====================================================
// PLOTS
//====================================================

// Trend EMA
plot(trendEma,
     color=color.new(#5b9cf6, 0),
     linewidth=2,
     title="Trend EMA")

// SSL
p_up = plot(sslUp,
     title="SSL Up",
     color=color.new(#089981, 0),
     linewidth=1)

p_down = plot(sslDown,
     title="SSL Down",
     color=color.new(#f23645, 0),
     linewidth=1)

fill(p_up,
     p_down,
     color=hlv == 1 ?
     color.new(#089981, 85) :
     color.new(#f23645, 85),
     title="SSL Fill")

// Bollinger Bands
plot(bbBasis,
     title="BB Basis",
     color=color.orange,
     linewidth=2)

upperPlot = plot(bbUpper,
     title="BB Upper",
     color=color.green)

lowerPlot = plot(bbLower,
     title="BB Lower",
     color=color.red)

fill(upperPlot,
     lowerPlot,
     color=color.new(color.gray, 92),
     title="BB Fill")

//====================================================
// SIGNALS
//====================================================
plotshape(
     buySignal,
     title="Buy Signal",
     location=location.belowbar,
     style=shape.labelup,
     text="BUY",
     color=#089981,
     textcolor=color.white,
     size=size.small)

plotshape(
     sellSignal,
     title="Sell Signal",
     location=location.abovebar,
     style=shape.labeldown,
     text="SELL",
     color=#f23645,
     textcolor=color.white,
     size=size.small)

//====================================================
// ALERTS
//====================================================
alertcondition(
     buySignal,
     title="Buy Signal",
     message="SSL Bullish Signal + Close Above Upper Bollinger Band")

alertcondition(
     sellSignal,
     title="Sell Signal",
     message="SSL Bearish Signal + Close Below Lower Bollinger Band")
````

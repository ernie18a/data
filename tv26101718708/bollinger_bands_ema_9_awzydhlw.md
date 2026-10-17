# Bollinger Bands + EMA 9

- url: https://www.tradingview.com/script/aWzYdHLW-Bollinger-Bands-EMA-9/
- type: indicator
- pine_id: PUB;c9539355698f46788116a872524ebefc
- version: 1.0

## Description

Save indicator space by adding these two in one indicator

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © zulkepledin
//@version=6
indicator("Bollinger Bands + EMA 9", shorttitle="BB + EMA9", overlay=true)

//====================================================
// INPUTS
//====================================================

bbGroup = "Bollinger Bands"

bbLength = input.int(20, "BB Length", minval=1, group=bbGroup)
bbSource = input.source(close, "Source", group=bbGroup)
bbMult   = input.float(2.0, "Standard Deviation", minval=0.1, step=0.1, group=bbGroup)


emaGroup = "EMA"

emaLength = input.int(9, "EMA Length", minval=1, group=emaGroup)


//====================================================
// CALCULATIONS
//====================================================

// Bollinger Bands
basis = ta.sma(bbSource, bbLength)
dev = bbMult * ta.stdev(bbSource, bbLength)

upperBand = basis + dev
lowerBand = basis - dev


// EMA 9
ema9 = ta.ema(close, emaLength)


//====================================================
// CONDITIONS
//====================================================

// Price breakout above upper band + EMA confirmation
bullBreakout =
     close > upperBand and
     close > ema9


// Price breakdown below lower band + EMA confirmation
bearBreakout =
     close < lowerBand and
     close < ema9


// Mean reversion signals
buySignal =
     ta.crossover(close, lowerBand) and
     close > ema9


sellSignal =
     ta.crossunder(close, upperBand) and
     close < ema9



//====================================================
// PLOTS
//====================================================

plot(
     basis,
     title="BB Middle",
     color=color.gray
)

upperPlot = plot(
     upperBand,
     title="Upper Band",
     color=color.blue
)

lowerPlot = plot(
     lowerBand,
     title="Lower Band",
     color=color.blue
)


fill(
     upperPlot,
     lowerPlot,
     color=color.new(color.blue, 90)
)


// EMA 9

plot(
     ema9,
     title="EMA 9",
     color=color.orange,
     linewidth=2
)



//====================================================
// SIGNALS
//====================================================

plotshape(
     bullBreakout,
     title="Bullish Breakout",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.small,
     text="BB↑"
)


plotshape(
     bearBreakout,
     title="Bearish Breakdown",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small,
     text="BB↓"
)


plotshape(
     buySignal,
     title="Buy",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="BUY",
     textcolor=color.white
)


plotshape(
     sellSignal,
     title="Sell",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SELL",
     textcolor=color.white
)



//====================================================
// ALERTS
//====================================================

alertcondition(
     bullBreakout,
     title="BB Bullish Breakout",
     message="Price broke above Bollinger Band with EMA9 confirmation"
)


alertcondition(
     bearBreakout,
     title="BB Bearish Breakdown",
     message="Price broke below Bollinger Band with EMA9 confirmation"
)


alertcondition(
     buySignal,
     title="BB EMA9 Buy",
     message="Bollinger Band + EMA9 BUY signal"
)


alertcondition(
     sellSignal,
     title="BB EMA9 Sell",
     message="Bollinger Band + EMA9 SELL signal"
)
plot(close)
````

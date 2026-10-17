# MACD Crossover Signal

- url: https://www.tradingview.com/script/vrX7pYNR/
- type: indicator
- pine_id: PUB;cebb0200d5904bd3be6b81a8762a4f8d
- version: 1.0

## Description

How to Use

This indicator displays BUY and SELL signals on the price chart based on MACD crossovers.

 BUY Signal

A green BUY label appears when:

* The MACD line crosses above the signal line.
* Bullish momentum may be increasing.

Possible uses:

* Entering during an uptrend
* Buying near support levels
* Confirming entries with other indicators

 SELL Signal

A red SELL label appears when:

* The MACD line crosses below the signal line.
* Bearish momentum may be increasing.

Possible uses:

* Taking profits
* Managing risk and stop-losses
* Confirming potential trend reversals

 Recommended Usage

This indicator works best when combined with other tools, such as:

* Volume Profile (support and resistance)
* Moving Averages (trend direction)
* Volume analysis
* RSI
* c-c/MA and VolumeMA

A typical workflow might be:

1. Identify key price levels using Volume Profile.
2. Confirm trend strength with c-c/MA and VolumeMA.
3. Use MACD crossovers to time entries and exits.

 Notes

MACD is a trend-following indicator.

Therefore:

* It may generate false signals in ranging markets.
* It tends to perform better during strong trends.
* Signals can lag during sharp market moves.

In cryptocurrency markets, MACD is often most effective when used as a timing tool within a broader market analysis framework.

## Source Code

````pine
//@version=6
indicator("MACD Crossover Signal", overlay=true)

// MACD settings
fastLength = 12
slowLength = 26
signalSmoothing = 9

// MACD calculation
[macdLine, signalLine, histLine] = ta.macd(close, fastLength, slowLength, signalSmoothing)

// Signal conditions
bullishCross = ta.crossover(macdLine, signalLine)
bearishCross = ta.crossunder(macdLine, signalLine)

// Show signals on main chart
plotshape(
     bullishCross,
     title="Buy Signal",
     location=location.belowbar,
     color=color.green,
     style=shape.labelup,
     size=size.small,
     text="BUY"
)

plotshape(
     bearishCross,
     title="Sell Signal",
     location=location.abovebar,
     color=color.red,
     style=shape.labeldown,
     size=size.small,
     text="SELL"
)
````

# SMA Strategy

- url: https://www.tradingview.com/script/86RaWbno/
- type: strategy
- pine_id: PUB;b33344f34cce40b6b9330737ea50f170
- version: 1.0

## Description

SMA Strategy is a minimalist trend-following trading system built around the interaction of short-term Simple Moving Averages.
The strategy uses the crossover between the SMA 5 and SMA 9 as the primary market trigger, while the SMA 20, SMA 50, and SMA 200 provide additional visual context for short-, medium-, and long-term trend structure.

Core Logic:
A LONG position is opened when the SMA 5 crosses above SMA 9.
A SHORT position is opened when the SMA 5 crosses below SMA 9.

Risk Management
Each trade automatically calculates:
a Stop Loss based on the most recent market structure,
and a Take Profit using a fixed 2:1 risk-to-reward ratio.

For long positions:
Stop Loss = lowest low of the last 5 candles.
Take Profit = entry price + 2× risk.

For short positions:
Stop Loss = highest high of the last 5 candles.
Take Profit = entry price − 2× risk.
This dynamic approach allows the strategy to adapt naturally to changing volatility and price structure.
Visual Features
The script includes multiple visual layers for quick chart interpretation:

SMA 9 displayed as a stepline trigger line.
SMA 20, SMA 50, and SMA 200 plotted as soft circular overlays.
Buy and sell signals plotted directly on the chart.
Candle colors change according to the direction of the SMA 9 trend:
Green candles indicate bullish momentum.
Red candles indicate bearish momentum.

Purpose
The strategy is designed for:
trend continuation trading, short-term momentum detection and clean visual market structure analysis.

Its lightweight construction makes it suitable for discretionary traders, automated backtesting, and further system development.

## Source Code

````pine
//@version=6
strategy("SMA Strategy", overlay=true, pyramiding=0)

//────────────────────
sma5  = ta.sma(close, 5)
sma9  = ta.sma(close, 9)
sma20 = ta.sma(close, 20)
sma50 = ta.sma(close, 50)
sma200 = ta.sma(close, 200)

//────────────────────
longSignal  = ta.crossover(sma5, sma9)
shortSignal = ta.crossunder(sma5, sma9)

//────────────────────
if longSignal

    sl = ta.lowest(low, 5)

    risk = close - sl

    if risk > syminfo.mintick

        tp = close + risk * 2

        strategy.entry("LONG", strategy.long)

        strategy.exit(
             "LONG EXIT",
             from_entry = "LONG",
             stop = sl,
             limit = tp)

//────────────────────
if shortSignal

    sl = ta.highest(high, 5)

    risk = sl - close

    if risk > syminfo.mintick

        tp = close - risk * 2

        strategy.entry("SHORT", strategy.short)

        strategy.exit(
             "SHORT EXIT",
             from_entry = "SHORT",
             stop = sl,
             limit = tp)

//────────────────────
plot(sma9, style = plot.style_stepline, color=color.rgb(120, 123, 134, 49))
plot(sma20, style = plot.style_circles, color=color.rgb(255, 153, 0, 60))
plot(sma50, style = plot.style_circles ,color=color.rgb(172, 0, 0, 54))
plot(sma200, style = plot.style_circles ,color=color.rgb(0, 110, 255, 47))

//────────────────────
// SIGNALS
//────────────────────
plotshape(
     longSignal,
     title="BUY",
     location=location.belowbar,
     color=color.rgb(76, 157, 175, 46),
     style=shape.labelup,
     size=size.tiny)

plotshape(
     shortSignal,
     title="SELL",
     location=location.abovebar,
     color=color.rgb(218, 229, 0, 58),
     style=shape.labeldown,
     size=size.tiny)

// SMA9 trend direction
bull = sma9 > sma9[1]
bear = sma9 < sma9[1]

barcolor(
     bull ? color.rgb(27, 230, 0) :
     bear ? color.rgb(198, 0, 0) :
     color.gray)
````

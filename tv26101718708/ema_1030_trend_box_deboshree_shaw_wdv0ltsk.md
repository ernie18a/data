# EMA 10/30 Trend Box Deboshree Shaw

- url: https://www.tradingview.com/script/WDV0LtsK-EMA-10-30-Trend-Box-Deboshree-Shaw/
- type: indicator
- pine_id: PUB;f98d801aa65e4139ba1b1b08222bd1c7
- version: 1.0

## Description

EMA 10/30 Trend Box with Buy/Sell Signals
Overview

The EMA 10/30 Trend Box is a simple yet powerful trend-following indicator designed to help traders quickly identify market direction and potential entry opportunities.

By combining the speed of the 10-period EMA with the reliability of the 30-period EMA, this indicator highlights bullish and bearish trend shifts using visual signals and an easy-to-read trend dashboard.

Key Features

✅ EMA 10 & EMA 30 crossover detection

✅ Instant BUY signal when EMA 10 crosses above EMA 30

✅ Instant SELL signal when EMA 10 crosses below EMA 30

✅ Dynamic Trend Box

Green = Bullish Trend (EMA 10 > EMA 30)
Red = Bearish Trend (EMA 10 < EMA 30)

✅ Fully customizable colors from indicator settings

✅ Built-in TradingView alert conditions

✅ Clean and lightweight design suitable for all markets

How It Works
Bullish Setup

When EMA 10 crosses above EMA 30:

A BUY signal is generated
Trend Box turns Green
Indicates potential upward momentum
Bearish Setup

When EMA 10 crosses below EMA 30:

A SELL signal is generated
Trend Box turns Red
Indicates potential downward momentum
Best Used For
Intraday Trading
Swing Trading
Index Trading (Nifty, Bank Nifty)
Stocks
Forex
Crypto
Recommended Timeframes
5 Minute
15 Minute
1 Hour
4 Hour
Daily
Risk Disclaimer

This indicator is designed to assist in trend identification and trade planning. Always use proper risk management and combine signals with price action, support/resistance, volume, or other confirmation tools before taking any trade.

Trade with discipline. Follow the trend. Manage your risk.

## Source Code

````pine
//@version=6
indicator("EMA 10/30 Trend Box", overlay=true)

// ======================
// Inputs
// ======================
fastLength = input.int(10, "Fast EMA")
slowLength = input.int(30, "Slow EMA")

bullColor = input.color(color.green, "Bullish Color")
bearColor = input.color(color.red, "Bearish Color")
textColor = input.color(color.white, "Text Color")

// ======================
// EMA Calculation
// ======================
ema10 = ta.ema(close, fastLength)
ema30 = ta.ema(close, slowLength)

// ======================
// Plot EMAs
// ======================
plot(ema10, color=color.green, linewidth=2, title="EMA 10")
plot(ema30, color=color.red, linewidth=2, title="EMA 30")

// ======================
// Cross Conditions
// ======================
bullCross = ta.crossover(ema10, ema30)
bearCross = ta.crossunder(ema10, ema30)

// ======================
// Buy / Sell Labels
// ======================
plotshape(
     bullCross,
     title="BUY",
     location=location.belowbar,
     style=shape.labelup,
     color=bullColor,
     text="BUY")

plotshape(
     bearCross,
     title="SELL",
     location=location.abovebar,
     style=shape.labeldown,
     color=bearColor,
     text="SELL")

// ======================
// Trend Box
// ======================
var table trendTable = table.new(position.top_right, 1, 1)

if barstate.islast
    if ema10 > ema30
        table.cell(
             trendTable,
             0,
             0,
             "EMA 10 > EMA 30\nBULLISH",
             bgcolor=bullColor,
             text_color=textColor)
    else
        table.cell(
             trendTable,
             0,
             0,
             "EMA 10 < EMA 30\nBEARISH",
             bgcolor=bearColor,
             text_color=textColor)

// ======================
// Alerts
// ======================
alertcondition(
     bullCross,
     title="Bullish Crossover",
     message="EMA 10 crossed ABOVE EMA 30")

alertcondition(
     bearCross,
     title="Bearish Crossover",
     message="EMA 10 crossed BELOW EMA 30")
````

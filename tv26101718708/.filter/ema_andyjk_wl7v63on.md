# ema - andyjk

- url: https://www.tradingview.com/script/wL7V63On-ema-andyjk/
- type: indicator
- pine_id: PUB;b7f2dd11f17e438ca7c35bcd0a2650fc
- version: 1.0

## Description

XAUUSD Traffic Lights + VWAP + 60 Pip Levels

A simple, all-in-one trend indicator designed for trading Gold (XAUUSD).

This indicator combines three Exponential Moving Averages (EMAs), VWAP and two live price levels to help traders identify market direction and potential trading opportunities.

Traffic Light EMA System

The indicator uses three coloured moving averages to make identifying the overall trend easier:

* 🟢 50 EMA (Green) – Short-term trend
* 🟠 100 EMA (Orange) – Medium-term trend
* 🔴 200 EMA (Red) – Longer-term trend

When the 50 EMA is above the 100 EMA and the 100 EMA is above the 200 EMA, the market is considered bullish.

When the 50 EMA is below the 100 EMA and the 100 EMA is below the 200 EMA, the market is considered bearish.

VWAP – Purple Line

The purple VWAP (Volume Weighted Average Price) helps traders see whether gold is trading above or below its volume-weighted average price.

Live 60-Pip Price Levels

Two horizontal lines automatically follow the live gold price, remaining 60 pips above and below it.

Using the default setting of 1 pip = $0.10, the lines are positioned $6.00 above and $6.00 below the current price.

The colours automatically change depending on the EMA trend:

* Bullish trend: Green line above price, red line below.
* Bearish trend: Red line above price, green line below.
* Neutral trend: Both lines turn grey when the EMAs are not fully aligned.

Both horizontal lines move as the market price changes and extend only to the right of the current candle.

Customisable Settings

Traders can adjust the pip distance and pip value to suit their preferred trading approach.

Suitable Timeframes

Designed primarily for XAUUSD scalping on the 1-minute and 5-minute charts, but can also be used on higher timeframes.

Purpose

The aim of this indicator is to provide a clean, easy-to-understand chart that combines trend direction, VWAP and dynamic price levels without needing several separate indicators.

Disclaimer: This indicator is intended for technical analysis and educational purposes only. It does not provide automatic buy or sell signals or guarantee profitable trades.

## Source Code

````pine
//@version=6 
indicator("XAUUSD Traffic Lights + VWAP + 60 Pips", overlay=true, max_lines_count=2)

// SETTINGS 
pips = input.int(60, "Distance in Pips", minval=1) 
pipSize = input.float(0.10, "Value of 1 Pip", minval=0.01, step=0.01)

// LIVE PRICE 
livePrice = close 
distance = pips * pipSize 
upperPrice = livePrice + distance 
lowerPrice = livePrice - distance

// EMA CALCULATIONS 
ema50 = ta.ema(close, 50) 
ema100 = ta.ema(close, 100) 
ema200 = ta.ema(close, 200)

// VWAP CALCULATION 
vwapValue = ta.vwap(hlc3)

// DISPLAY EMA TRAFFIC LIGHTS 
plot(ema50, title="50 EMA - Green", color=color.lime, linewidth=2) 
plot(ema100, title="100 EMA - Orange", color=color.orange, linewidth=2) 
plot(ema200, title="200 EMA - Red", color=color.red, linewidth=2)

// DISPLAY PURPLE VWAP 
plot(vwapValue, title="VWAP - Purple", color=color.purple, linewidth=2)

// EMA TREND CONDITIONS 
bullish = ema50 > ema100 and ema100 > ema200 
bearish = ema50 < ema100 and ema100 < ema200

// DYNAMIC COLOURS 
topColor = bullish ? color.lime : bearish ? color.red : color.gray 
bottomColor = bearish ? color.lime : bullish ? color.red : color.gray

// CREATE LIVE HORIZONTAL LINES 
var line topLine = line.new(bar_index, close, bar_index + 1, close, extend=extend.right, color=color.gray, width=3) 
var line bottomLine = line.new(bar_index, close, bar_index + 1, close, extend=extend.right, color=color.gray, width=3)

// UPDATE TOP LINE WITH LIVE PRICE 
line.set_xy1(topLine, bar_index, upperPrice) 
line.set_xy2(topLine, bar_index + 1, upperPrice) 
line.set_color(topLine, topColor)

// UPDATE BOTTOM LINE WITH LIVE PRICE 
line.set_xy1(bottomLine, bar_index, lowerPrice) 
line.set_xy2(bottomLine, bar_index + 1, lowerPrice) 
line.set_color(bottomLine, bottomColor)
````

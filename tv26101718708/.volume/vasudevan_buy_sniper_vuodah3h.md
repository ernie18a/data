# Vasudevan Buy sniper

- url: https://www.tradingview.com/script/vUOdah3h-Vasudevan-Buy-sniper/
- type: indicator
- pine_id: PUB;1fab956c8fef4283a3203780a642da98
- version: 1.0

## Description

## VWAP Retest + RSI BUY ONLY

This TradingView Pine Script indicator is designed to identify high-probability BUY opportunities using a combination of:

* VWAP support retest
* RSI bullish crossover
* Bullish candle confirmation
* Automatic Stoploss & Target levels

### BUY CONDITIONS

A BUY signal is generated when:

1. Price is above VWAP
2. Candle retests VWAP from upside
3. Bullish confirmation candle closes above open
4. RSI crosses above selected RSI level

### FEATURES

* Real-time BUY signal labels
* Automatic Stoploss line
* Automatic Target line
* Risk : Reward based target calculation
* Customizable RSI settings
* Adjustable Stoploss buffer
* Alert support for TradingView notifications

### STOPLOSS

Stoploss is automatically placed slightly below the signal candle low using customizable buffer percentage.

### TARGET

Target is calculated automatically using selected Risk : Reward ratio.

### BEST USED FOR

* Intraday trading
* Scalping
* VWAP bounce setups
* Trend continuation trades
* Index & stock futures

### RECOMMENDED TIMEFRAMES

* 3 Minute
* 5 Minute
* 15 Minute

### IDEAL MARKET CONDITIONS

Works best in:

* Trending markets
* High volume sessions
* Strong bullish momentum above VWAP

### ALERTS

TradingView alerts can be created using:

* “BUY ALERT”
* For webhook or mobile notifications

## Source Code

````pine
//@version=5
indicator("VWAP Retest + RSI Crossover + SL Target", overlay=true)

// ===== INPUTS =====
rr = input.float(2.0, "Risk Reward Ratio", step=0.5)
slBuffer = input.float(0.3, "SL Buffer %", step=0.1)

// RSI SETTINGS
rsiLength = input.int(14, "RSI Length")
rsiLevel  = input.int(50, "RSI Crossover Level")

// ===== VWAP =====
vwapValue = ta.vwap(close)
plot(vwapValue, color=color.orange, linewidth=2, title="VWAP")

// ===== RSI =====
rsiValue = ta.rsi(close, rsiLength)

// RSI CROSSOVER
rsiCross = ta.crossover(rsiValue, rsiLevel)

// ===== BUY CONDITIONS =====
aboveVWAP = close > vwapValue
retest    = low <= vwapValue and close > vwapValue
bullish   = close > open

// FINAL BUY SIGNAL
buySignal = aboveVWAP and retest and bullish and rsiCross

// ===== ENTRY / SL / TARGET =====
entryPrice = close

// Stoploss below candle low
stopLoss = low * (1 - slBuffer / 100)

// Risk Calculation
risk = entryPrice - stopLoss

// Target Calculation
targetPrice = entryPrice + (risk * rr)

// ===== BUY SIGNAL =====
plotshape(
     buySignal,
     title="BUY",
     location=location.belowbar,
     style=shape.labelup,
     color=color.green,
     text="BUY")

// ===== SL & TARGET LINES =====
if buySignal

    // STOPLOSS LINE
    line.new(
         bar_index, stopLoss,
         bar_index + 20, stopLoss,
         color=color.red,
         width=2)

    // TARGET LINE
    line.new(
         bar_index, targetPrice,
         bar_index + 20, targetPrice,
         color=color.green,
         width=2)

    // SL LABEL
    label.new(
         bar_index + 20,
         stopLoss,
         text="SL : " + str.tostring(stopLoss, format.mintick),
         style=label.style_label_left,
         color=color.red,
         textcolor=color.white)

    // TARGET LABEL
    label.new(
         bar_index + 20,
         targetPrice,
         text="TARGET : " + str.tostring(targetPrice, format.mintick),
         style=label.style_label_left,
         color=color.green,
         textcolor=color.white)

// ===== ALERT =====
alertcondition(
     buySignal,
     title="BUY ALERT",
     message="VWAP Retest + RSI Crossover BUY Signal")
````

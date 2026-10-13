<!-- tradingview-pine-id: PUB;65c9e49f8dc8443486a1f53691dbab88 -->
<!-- tradingviewscripts-format: 1 -->
# Buy Volume Momentum Alert

Source: https://www.tradingview.com/script/oU8QTHSR-Buy-Volume-Momentum-Alert-FINAL/

## Description

buy or sell? let the indicator give you a clue. I use this daily along side my growing volume strategy to maintain my 95% win rate and you can too

---

## Source Code

````pine
//@version=6
indicator("Buy Volume Momentum Alert", overlay=true)

// Approximate buy volume by candle direction
buyVol = close >= open ? volume : 0
sellVol = close < open ? volume : 0

// Entry condition (buy)
greenCandle = close > open
twoGreenCandles = greenCandle and greenCandle[1]
buyVolRising = buyVol > buyVol[1]

entry = twoGreenCandles and buyVolRising

// Exit condition (sell)
redCandle = close < open
twoRedCandles = redCandle and redCandle[1]
sellVolRising = sellVol > sellVol[1]

sellEntry = twoRedCandles and sellVolRising

// BUY label on the chart
if entry
    label.new(bar_index, low, "BUY", 
      style=label.style_label_up, 
      color=color.green, 
      textcolor=color.white, 
      size=size.normal)

// SELL label on the chart
if sellEntry
    label.new(bar_index, high, "SELL", 
      style=label.style_label_down, 
      color=color.red, 
      textcolor=color.white, 
      size=size.normal)

// Keep the background flash too
bgcolor(entry ? color.new(color.green, 85) : sellEntry ? color.new(color.red, 85) : na)

alertcondition(entry, title="Buy Vol Entry", message="Two green candles, buy vol rising!")
alertcondition(sellEntry, title="Sell Vol Entry", message="Two red candles, sell vol rising!")
````

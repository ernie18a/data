# Latest Body Over Wick by KEROL

- url: https://www.tradingview.com/script/HYW3UPnE-Latest-Body-Over-Wick-by-KEROL/
- type: indicator
- pine_id: PUB;86d8acc2181c45c69dafeab5e3c6a85f
- version: 1.0

## Description

Latest Body Over Wick by KEROL is a momentum-based price action indicator designed to identify strong breakout candles where the candle body closes beyond the previous candle wick.

The indicator focuses on detecting aggressive bullish and bearish momentum candles that signal potential continuation or reversal opportunities.

## Source Code

````pine
//@version=6
indicator("Latest Body Over Wick", overlay=true)

// Previous candle
prevHigh = high[1]
prevLow = low[1]

// Current candle body
bodyHigh = math.max(open, close)
bodyLow = math.min(open, close)

// Signals
bullSignal = close > open and bodyHigh > prevHigh

bearSignal = close < open and bodyLow < prevLow

// ======================================================
// SHOW ONLY LATEST SIGNAL
// ======================================================

var label latestLabel = na

if bullSignal
    label.delete(latestLabel)

    latestLabel := label.new(
         bar_index,
         low,
         "BULL",
         style=label.style_label_up,
         color=color.lime,
         textcolor=color.white,
         size=size.small
     )

if bearSignal
    label.delete(latestLabel)

    latestLabel := label.new(
         bar_index,
         high,
         "BEAR",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.small
     )

// ======================================================
// ALERTS
// ======================================================

alertcondition(bullSignal, title="Bullish", message="Bullish body over wick")

alertcondition(bearSignal, title="Bearish", message="Bearish body over wick")
````

# Auto Candlestick Patterns Targets Setup

- url: https://www.tradingview.com/script/nnwknaj8-Auto-Candlestick-Patterns-Targets-Setup/
- type: indicator
- pine_id: PUB;02997c4727134042ac07baee2af66816
- version: 2.0

## Description

🔷 [b]OVERVIEW[/b]

[b]Auto Candlestick Pattern Targets[/b] automatically identifies supported candlestick reversal patterns and displays a complete trade setup directly on the chart. When a qualifying pattern is detected, the indicator plots an Entry level, Stop Loss, and up to three Take Profit levels based on its internal calculation logic.

The objective is to reduce the amount of manual chart work by presenting trade levels in a consistent visual format.

🔷 [b]HOW IT WORKS[/b]

The indicator continuously evaluates completed candles for supported bullish and bearish candlestick formations.

When the pattern conditions are satisfied, it:

• Displays a Buy or Sell label

• Calculates an Entry level

• Places a Stop Loss based on the detected pattern

• Projects three Take Profit targets

Each setup remains visible on the chart, allowing users to review historical signals and monitor active trades.

🔷 [b]VISUAL FEATURES[/b]

• Automatic Buy and Sell labels

• Entry level

• Stop Loss level

• Three Take Profit targets

• Risk and reward visualization

• Historical signal display

• Configurable colors and styles

🔷 [b]INPUTS[/b]

The indicator includes options to customize:

• Signal sensitivity

• Display of Entry, Stop Loss, and Targets

• Label visibility

• Colors

• Historical setup display

🔷 [b]USAGE[/b]

A common workflow is:

Wait for a Buy or Sell signal.
Allow the signal candle to close.
Review the plotted Entry, Stop Loss, and Take Profit levels.
Combine the setup with your own market analysis before making trading decisions.

🔷 [b]MARKETS[/b]

The indicator can be applied to:

• Forex

• Stocks

• Cryptocurrency

• Indices

• Commodities

It is compatible with multiple timeframes, depending on the user's trading approach.

🔷 [b]NOTES[/b]

This indicator is intended as a chart analysis tool and does not predict future price movements. Trade setups are generated according to the indicator's programmed rules and should be evaluated alongside other forms of technical analysis and appropriate risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("Auto Candlestick Patterns Targets", overlay=true)

// Risk Reward
rr1 = input.float(1.0, "TP1 RR")
rr2 = input.float(2.0, "TP2 RR")
rr3 = input.float(3.0, "TP3 RR")

// Bullish Engulfing
bullEngulf =
     close > open and
     close[1] < open[1] and
     close > open[1] and
     open < close[1]

// Bearish Engulfing
bearEngulf =
     close < open and
     close[1] > open[1] and
     close < open[1] and
     open > close[1]

// Buy Setup
if bullEngulf
    sl = low
    risk = close - sl

    line.new(bar_index, close, bar_index + 20, close, color=color.green)
    line.new(bar_index, sl, bar_index + 20, sl, color=color.red)

    line.new(bar_index, close + risk * rr1, bar_index + 20, close + risk * rr1, color=color.blue)
    line.new(bar_index, close + risk * rr2, bar_index + 20, close + risk * rr2, color=color.blue)
    line.new(bar_index, close + risk * rr3, bar_index + 20, close + risk * rr3, color=color.blue)

    label.new(bar_index, low, "BUY", color=color.green)

// Sell Setup
if bearEngulf
    sl = high
    risk = sl - close

    line.new(bar_index, close, bar_index + 20, close, color=color.red)
    line.new(bar_index, sl, bar_index + 20, sl, color=color.green)

    line.new(bar_index, close - risk * rr1, bar_index + 20, close - risk * rr1, color=color.orange)
    line.new(bar_index, close - risk * rr2, bar_index + 20, close - risk * rr2, color=color.orange)
    line.new(bar_index, close - risk * rr3, bar_index + 20, close - risk * rr3, color=color.orange)

    label.new(bar_index, high, "SELL", color=color.red)

alertcondition(bullEngulf, "Bullish Pattern", "Bullish Pattern Detected")
alertcondition(bearEngulf, "Bearish Pattern", "Bearish Pattern Detected")
````

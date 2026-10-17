# Buy and Sell Type Splish 2

- url: https://www.tradingview.com/script/lZhwMoMt-Buy-and-Sell-Type-Splish-2/
- type: indicator
- pine_id: PUB;3ba7fe86822d4fc18f0147407fb22be2
- version: 1.0

## Description

This setup is specifically optimized for HOOD, though I’ve also applied it effectively to SOFI.

Play around with the timeframes—5-minute candles provide the most reliable signals, but fewer entry opportunities. For quicker trades, I switch to the 1-minute timeframe for fast in-and-out scalping.

My typical approach:
If HOOD is trading at $104.45 and a Buy signal fires, I’ll usually purchase $105 calls.

Early in the week (using 5-minute candles): I go for calls expiring that Friday.

Later in the week: I roll into the following Friday’s expiration to give it room.

For 1-minute scalps: I use the nearest expiration possible to maximize leverage and responsiveness.

Note: The Sell indicator still needs refining—it tends to trigger too frequently and a bit prematurely. Improvements are in progress.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © 
//@version=5
indicator("Buy and Sell Type Splish", overlay=true)

// ── Inputs ─────────────────────────────────────────────────────────────────────
rsiLen        = input.int(14, title="RSI Length")
rsiLowLevel   = input.int(35, title="RSI Oversold Level")
rsiHighLevel  = input.int(65, title="RSI Overbought Level")

macdFast      = input.int(12, title="MACD Fast Length")
macdSlow      = input.int(26, title="MACD Slow Length")
macdSignal    = input.int(9,  title="MACD Signal Length")

crossMode     = input.bool(false, title="Use MACD Crossover Mode")

// ── Calculations ────────────────────────────────────────────────────────────────
// RSI
rsiVal      = ta.rsi(close, rsiLen)
rsiBuyCond  = (rsiVal < rsiLowLevel) or (rsiVal[1] < rsiLowLevel)
rsiSellCond = (rsiVal > rsiHighLevel) or (rsiVal[1] > rsiHighLevel)

// MACD
[macdLine, signalLine, hist] = ta.macd(close, macdFast, macdSlow, macdSignal)

// Histogram “lightening”
histRise    = hist < 0 and hist > hist[1]
histFall    = hist > 0 and hist < hist[1]

// MACD‐line crossover
macdCrossUp   = ta.crossover(macdLine, signalLine)
macdCrossDown = ta.crossunder(macdLine, signalLine)

// Choose which MACD condition to use
macdBuyCond  = crossMode ? macdCrossUp   : histRise
macdSellCond = crossMode ? macdCrossDown : histFall

// ── Build Buy & Sell ────────────────────────────────────────────────────────────
buySignal  = rsiBuyCond  and macdBuyCond
sellSignal = rsiSellCond and macdSellCond

// ── Plot & Alerts ──────────────────────────────────────────────────────────────
plotshape(buySignal,
     title="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="BUY")

plotshape(sellSignal,
     title="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SELL")

alertcondition(buySignal,  title="Buy Alert",  message="BUY on {{ticker}} at {{time}}")
alertcondition(sellSignal, title="Sell Alert", message="SELL on {{ticker}} at {{time}}")
````

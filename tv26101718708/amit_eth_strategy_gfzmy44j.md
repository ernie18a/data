# Amit Eth Strategy

- url: https://www.tradingview.com/script/gFzmy44j-Amit-Eth-Strategy/
- type: strategy
- pine_id: PUB;bcbe5c42bdd3490d825d35aa436a8ecc
- version: 1.0

## Description

# MACD + EMA18 Signal Strategy

This strategy combines momentum and trend-following concepts using MACD, EMA, and SMA for clean directional trading signals.

## Strategy Logic

### BUY Setup

A BUY signal is generated when:

* MACD Line crosses above the Signal Line
* Price closes above the 18 EMA

### SELL Setup

A SELL signal is generated when:

* MACD Line crosses below the Signal Line
* Price closes below the 18 EMA

## Exit Rules

### For BUY Trades

Position exits when:

* Price closes below SMA 10 Low
  OR
* MACD gives bearish crossover

### For SELL Trades

Position exits when:

* Price closes above SMA 10 High
  OR
* MACD gives bullish crossover

## Features

* Trend confirmation using EMA 18
* Momentum confirmation using MACD crossover
* Dynamic stop-loss using SMA 10
* One trade at a time logic
* Clean BUY & SELL signals only
* Works well in trending markets

## Best Timeframes

* 5 Min
* 15 Min
* 30 Min
* 1 Hour

## Best Suitable For

* Intraday Trading
* Swing Trading
* Index Trading
* Stocks
* Futures & Options Directional Trading

## Risk Management

Always use proper position sizing and avoid overleveraging. This strategy performs best in trending markets and may produce false signals during sideways conditions.

Backtest before using in live markets.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BurnerView

//@version=6
//@version=5
strategy("MACD + EMA18 Signal Strategy", overlay=true, pyramiding=0)

// =====================================================
// INDICATORS
// =====================================================

// EMA 18
ema18 = ta.ema(close, 18)

// SMA 10 High & Low
smaHigh = ta.sma(high, 10)
smaLow  = ta.sma(low, 10)

// MACD
[macdLine, signalLine, _] = ta.macd(close, 12, 26, 9)

// =====================================================
// ENTRY CONDITIONS
// =====================================================

// Buy Condition
buyCondition =
     ta.crossover(macdLine, signalLine) and
     close > ema18

// Sell Condition
sellCondition =
     ta.crossunder(macdLine, signalLine) and
     close < ema18

// =====================================================
// ONE TRADE AT A TIME
// =====================================================

noPosition = strategy.position_size == 0

// =====================================================
// ENTRIES
// =====================================================

if (buyCondition and noPosition)
    strategy.entry("BUY", strategy.long)

if (sellCondition and noPosition)
    strategy.entry("SELL", strategy.short)

// =====================================================
// EXITS
// =====================================================

// Buy Exit
if (strategy.position_size > 0 and (close < smaLow or ta.crossunder(macdLine, signalLine)))
    strategy.close("BUY")

// Sell Exit
if (strategy.position_size < 0 and (close > smaHigh or ta.crossover(macdLine, signalLine)))
    strategy.close("SELL")

// =====================================================
// SIGNALS ONLY
// =====================================================

// Buy Signal
plotshape(
     buyCondition and noPosition,
     title="BUY",
     location=location.belowbar,
     style=shape.labelup,
     color=color.green,
     text="BUY",
     textcolor=color.white,
     size=size.small
     )

// Sell Signal
plotshape(
     sellCondition and noPosition,
     title="SELL",
     location=location.abovebar,
     style=shape.labeldown,
     color=color.red,
     text="SELL",
     textcolor=color.white,
     size=size.small
     )
````

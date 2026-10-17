# The Bear Crossover

- url: https://www.tradingview.com/script/cCdBvD3o-The-Bear-Crossover/
- type: indicator
- pine_id: PUB;d0ddfc314d1841e19dcf0fc88b363f32
- version: 1.0

## Description

# The Bear Crossover

**The Bear Crossover** is a clean, no-nonsense EMA crossover indicator designed to help traders identify potential trend reversals with minimal chart clutter.

The indicator uses:

* **11 EMA** (Fast)
* **51 EMA** (Slow)

A **BUY** signal is generated only when:

* The 11 EMA crosses above the 51 EMA.
* The crossover candle closes bullish (close > open).

A **SELL** signal is generated only when:

* The 11 EMA crosses below the 51 EMA.
* The crossover candle closes bearish (close < open).

By requiring candle confirmation, the indicator filters out some weak crossover signals that occur on indecisive candles.

### Features

* 11 EMA & 51 EMA trend visualization
* Bullish and bearish crossover detection
* Confirmation with candle direction
* Clean BUY/SELL labels
* Built-in TradingView alerts
* Lightweight and easy to use

### Best Used On

* Forex
* Gold (XAU/USD)
* Indices
* Crypto
* Stocks

### Recommended Timeframes

Works on all timeframes, with many traders preferring **5m, 15m, 1H, and 4H** depending on their trading style.

**Disclaimer:** This indicator is an analysis tool and should not be used as a standalone trading system. Always combine it with proper risk management, market structure, support/resistance, and additional confirmation before entering a trade.

## Source Code

````pine
//@version=6
indicator("The Bear Crossover", overlay=true)

fastEMA = ta.ema(close, 11)
slowEMA = ta.ema(close, 51)

plot(fastEMA, color=color.aqua, linewidth=2, title="11 EMA")
plot(slowEMA, color=color.orange, linewidth=2, title="51 EMA")

// EMA Crossovers
bullCross = ta.crossover(fastEMA, slowEMA)
bearCross = ta.crossunder(fastEMA, slowEMA)

// Signals only on the crossover candle
buySignal  = bullCross and close > open
sellSignal = bearCross and close < open

plotshape(
     buySignal,
     title="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.lime,
     text="BUY",
     textcolor=color.white)

plotshape(
     sellSignal,
     title="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SELL",
     textcolor=color.white)

alertcondition(buySignal, title="BUY", message="BUY Signal")
alertcondition(sellSignal, title="SELL", message="SELL Signal")
````

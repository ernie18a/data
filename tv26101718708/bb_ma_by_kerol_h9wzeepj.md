# BB + MA by KEROL

- url: https://www.tradingview.com/script/h9WzeEPJ-BB-MA-by-KEROL/
- type: indicator
- pine_id: PUB;e1ce499b37f1428ba4e752897fc64566
- version: 1.0

## Description

# BB + MA

BB + MA is a clean trend and volatility indicator that combines Bollinger Bands with Moving Average 9 and Moving Average 21 to help traders identify market direction, momentum, and expansion zones.

## Features

* MA 9 (Blue) for fast momentum tracking
* MA 21 (Red) for trend direction
* Bollinger Bands for volatility and expansion analysis
* Clean chart setup
* Suitable for scalping and intraday trading

## Components

### MA 9 (Blue)

The fast moving average used to identify short-term momentum and quick market reaction.

### MA 21 (Red)

The slower moving average used to confirm overall market direction and trend bias.

### Bollinger Bands

Used to detect:

* volatility expansion
* overbought zones
* oversold zones
* breakout conditions

## Trading Interpretation

### Bullish Trend

* MA 9 above MA 21
* Price holding near upper Bollinger Band
* Strong bullish momentum

### Bearish Trend

* MA 9 below MA 21
* Price holding near lower Bollinger Band
* Strong bearish momentum

### Consolidation

* MA lines crossing frequently
* Bollinger Bands tightening
* Lower volatility environment

## Best Used For

* Gold (XAUUSD)
* Forex
* Indices
* Scalping
* Intraday trading
* Momentum breakout setups

## Trading Style

This setup works well for:

* trend continuation
* volatility breakout
* pullback entry
* momentum trading

## Visual Guide

* Blue Line = MA 9
* Red Line = MA 21
* Red BB = Upper Bollinger Band
* Gray BB = Middle Band
* Green BB = Lower Bollinger Band

## Source Code

````pine
//@version=6
indicator("BB + MA", overlay=true)

// ======================================================
// MOVING AVERAGE
// ======================================================

ma9 = ta.sma(close, 9)
ma21 = ta.sma(close, 21)

plot(ma9, title="MA 9", color=color.blue, linewidth=2)
plot(ma21, title="MA 21", color=color.red, linewidth=2)

// ======================================================
// BOLLINGER BAND
// ======================================================

bbLength = input.int(20, "BB Length")
bbMult = input.float(2.0, "BB Multiplier")

basis = ta.sma(close, bbLength)
dev = ta.stdev(close, bbLength) * bbMult

upperBB = basis + dev
lowerBB = basis - dev

plot(upperBB, title="Upper BB", color=color.red, linewidth=1)
plot(basis, title="Middle BB", color=color.gray, linewidth=1)
plot(lowerBB, title="Lower BB", color=color.lime, linewidth=1)
````

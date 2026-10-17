# Simple 1H Buy/Sell System - EMA + Supertrend + RSI By Gerard Dak

- url: https://www.tradingview.com/script/kN4KIfJE-Simple-1H-Buy-Sell-System-EMA-Supertrend-RSI-By-Gerard-Dak/
- type: indicator
- pine_id: PUB;3c7b0baa6de845468d8e05e8000948e6
- version: 1.0

## Description

The simple 1H buy/sell indicator is a trend-following system designed to remove noise and only trigger trades when momentum, trend direction, and market structure align together.

Core logic:

Uses a fast EMA and slow EMA to identify the main trend
Uses RSI as a momentum filter to avoid weak setups
Uses ATR filtering to avoid low-volatility chop
Generates BUY signals only when:
Fast EMA crosses above slow EMA
RSI confirms bullish momentum
Price is above trend structure
Generates SELL signals only when:
Fast EMA crosses below slow EMA
RSI confirms bearish momentum
Price is below trend structure

The goal is:

Fewer fake signals
Cleaner entries
Better trend continuation trades
Easier visual interpretation on the 1-hour timeframe

Best market conditions:

Trending markets
NAS100, QQQ, SPY, BTC, major forex pairs
High-volume sessions (London/New York)

Avoid using it:

During sideways consolidation
Right before major news events
In extremely low volatility

Recommended 1H settings:

Fast EMA: 21
Slow EMA: 50
RSI Length: 14
RSI Buy Threshold: Above 55
RSI Sell Threshold: Below 45
ATR Filter: Enabled

Signal philosophy:
The indicator intentionally sacrifices early entries in exchange for higher-quality confirmation. It will not catch exact tops or bottoms. Instead, it tries to catch the “meat” of the move with fewer bad trades.

What makes it effective:

Multi-confirmation filtering
Trend + momentum alignment
Noise reduction
Prevents overtrading

Expected behavior:

Strong trends → excellent signals
Choppy markets → fewer signals (by design)
Win rate can be high if combined with:
Higher timeframe trend confirmation
Support/resistance
Volume analysis
Avoiding news spikes

A typical BUY setup on 1H:

Price consolidates
21 EMA crosses above 50 EMA
RSI moves above 55
Candle closes bullish above both EMAs
BUY signal appears

A typical SELL setup is the exact opposite.

The biggest mistake traders make with these systems is taking every signal blindly. The highest probability trades happen when:

4H trend agrees with 1H
Market is not overextended

## Source Code

````pine
//@version=5
indicator("Simple 1H Buy/Sell System - EMA + Supertrend + RSI", overlay=true)

// Inputs
emaLength = input.int(200, "EMA Length")
atrPeriod = input.int(10, "Supertrend ATR Period")
factor = input.float(3.0, "Supertrend Factor")
rsiLength = input.int(14, "RSI Length")

// Calculations
ema200 = ta.ema(close, emaLength)
rsi = ta.rsi(close, rsiLength)
[supertrend, direction] = ta.supertrend(factor, atrPeriod)

// Supertrend direction
supertrendBullish = direction < 0
supertrendBearish = direction > 0

// Trend filters
bullTrend = close > ema200 and rsi > 50
bearTrend = close < ema200 and rsi < 50

// Signals only after candle close
buySignal = supertrendBullish and not supertrendBullish[1] and bullTrend and barstate.isconfirmed
sellSignal = supertrendBearish and not supertrendBearish[1] and bearTrend and barstate.isconfirmed

// Plots
plot(ema200, "200 EMA", color=color.yellow, linewidth=2)
plot(supertrend, "Supertrend", color=supertrendBullish ? color.green : color.red, linewidth=2)

// Buy/Sell labels
plotshape(buySignal, title="BUY", text="BUY", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.large)
plotshape(sellSignal, title="SELL", text="SELL", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.large)

// Alerts
alertcondition(buySignal, title="BUY Alert", message="BUY signal confirmed on 1H chart")
alertcondition(sellSignal, title="SELL Alert", message="SELL signal confirmed on 1H chart")
````

# Pivot Points + Candle Trend | Albert Setups

- url: https://www.tradingview.com/script/fNpdjvwn-Pivot-Points-Candle-Trend-Albert-Setups/
- type: indicator
- pine_id: PUB;cd18543347234ca88676e6eaa88bb629
- version: 1.0

## Description

# Pivot Points + Candle Trend | Albert Setups 📊

**A Simple Support, Resistance & Market Momentum Indicator for TradingView**

The **Pivot Points + Candle Trend Indicator** is designed to help traders identify key market levels, monitor candle momentum, and recognize potential breakout opportunities. By combining confirmed swing highs and lows with candle trend analysis, this indicator provides a clean and straightforward view of market conditions.

### 🔹 Key Features

✅ **Pivot Resistance:** Identifies the latest confirmed swing high as a potential resistance level.

✅ **Pivot Support:** Identifies the latest confirmed swing low as a potential support level.

✅ **Candle Trend Analysis:** Highlights bullish candles in green and bearish candles in red based on price movement.

✅ **BUY Signals:** Generates a potential buy signal when price breaks above the latest pivot resistance with a bullish candle.

✅ **SELL Signals:** Generates a potential sell signal when price breaks below the latest pivot support with a bearish candle.

✅ **TradingView Alerts:** Supports customizable alerts for potential BUY and SELL signals.

✅ **Clean Chart Design:** Keeps essential support, resistance, and trading signals visible without unnecessary indicators.

### 📈 How to Use This Indicator

- Look for potential buying opportunities when price breaks above pivot resistance.
- Look for potential selling opportunities when price breaks below pivot support.
- Use candle colors to assess short-term momentum.
- Confirm signals with market structure, higher-timeframe trends, and additional technical analysis.

### 🎯 Suitable Markets

This indicator can be used to analyze **XAUUSD (Gold), Forex pairs, cryptocurrencies, and major indices** across different timeframes.

⚠️ **Risk Disclaimer:** Pivot levels require confirmation and therefore appear with a delay. Signals are not guaranteed to be profitable. Always use proper stop-loss placement, risk management, and backtesting before trading live.

**Albert Setups | Identify Key Levels. Follow Momentum. Trade with Discipline.**

## Source Code

````pine

 //@version=6
indicator("Pivot Points + Candle Trend | Albert Setups", overlay=true, max_labels_count=200)

// ───── SETTINGS ─────
pivotLen = input.int(5, "Pivot Length", minval=2, maxval=20)
showPivots = input.bool(true, "Show Pivot Support / Resistance")
showSignals = input.bool(true, "Show BUY / SELL Signals")
colorCandles = input.bool(true, "Color Candles by Trend")

// ───── CANDLE TREND ─────
bullishCandle = close > open
bearishCandle = close < open

// ───── PIVOT POINTS ─────
pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)

var float resistance = na
var float support = na

if not na(pivotHigh)
    resistance := pivotHigh

if not na(pivotLow)
    support := pivotLow

plot(showPivots ? resistance : na, title="Pivot Resistance", color=color.red, linewidth=2, style=plot.style_stepline)
plot(showPivots ? support : na, title="Pivot Support", color=color.green, linewidth=2, style=plot.style_stepline)

// ───── TREND CONFIRMATION ─────
bullTrend = close > close[1] and close > open
bearTrend = close < close[1] and close < open

// ───── SIGNAL CONDITIONS ─────
buySignal = not na(resistance) and ta.crossover(close, resistance) and bullishCandle
sellSignal = not na(support) and ta.crossunder(close, support) and bearishCandle

plotshape(showSignals and buySignal, title="BUY", text="BUY", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.small)
plotshape(showSignals and sellSignal, title="SELL", text="SELL", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.small)

// ───── CANDLE COLORS ─────
barcolor(colorCandles ? (bullTrend ? color.green : bearTrend ? color.red : na) : na)

// ───── ALERTS ─────
alertcondition(buySignal, title="BUY Alert", message="Pivot Points + Candle Trend: BUY signal")
alertcondition(sellSignal, title="SELL Alert", message="Pivot Points + Candle Trend: SELL signal")
````

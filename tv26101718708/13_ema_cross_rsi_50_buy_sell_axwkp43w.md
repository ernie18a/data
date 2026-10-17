# 13 EMA Cross + RSI 50 = Buy / Sell

- url: https://www.tradingview.com/script/aXwkp43w-13-EMA-Cross-RSI-50-Buy-Sell/
- type: indicator
- pine_id: PUB;4cda7b9e0d91437898f487b28c9b78c0
- version: 1.0

## Description

[b]13 EMA Cross + RSI 50 Description:[/b]

A simple yet effective signal indicator combining price action, a dynamic EMA level, and RSI momentum confirmation.
How it works:
🟢 Buy Signal = A bullish candle opens below the 13 EMA and closes above it, confirming a momentum shift to the upside. The signal is only valid when RSI has crossed above the 50 level within the last 1–2 candles, confirming that momentum is turning bullish.
🔴 Sell Signal = A bearish candle opens above the 13 EMA and closes below it. The signal is only valid when RSI has crossed below the 50 level within the last 1–2 candles, confirming bearish momentum.

Why this combination works:
The 13 EMA candle cross filters out noise by requiring price to actually close on the opposite side - not just touch the EMA. The RSI 50 cross filter ensures you are not catching signals in exhausted moves, but rather at the early stage of a momentum shift.
Best used on: 1H timeframe | Crude Oil (MCX) | Natural Gas (MCX) | Nifty 50
Settings:

EMA Length - default 13
RSI Length - default 14
RSI Lookback - how many previous candles RSI must have been on the opposite side of 50 (default 2)

This indicator is for educational purposes. Always use proper risk management and position sizing.

## Source Code

````pine
// ============================================================
// Strategy : 13 EMA Cross + RSI 50 Filter
//
// BUY  : Bullish candle opens below 13 EMA, closes above 13 EMA
//        + RSI is above 50 now, was below 50 in previous 1-2 candles
//
// SELL : Bearish candle opens above 13 EMA, closes below 13 EMA
//        + RSI is below 50 now, was above 50 in previous 1-2 candles
// ============================================================

//@version=5
indicator("13 EMA Cross + RSI 50 Filter", overlay=true)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
emaLen      = input.int(13, "EMA Length",    minval=1)
rsiLen      = input.int(14, "RSI Length",    minval=1)
rsiLookback = input.int(2,  "RSI Lookback (bars previously on opposite side of 50)", minval=1, maxval=5)

// ─────────────────────────────────────────────
// INDICATORS
// ─────────────────────────────────────────────
ema13 = ta.ema(close, emaLen)
rsi   = ta.rsi(close, rsiLen)

plot(ema13, title="13 EMA", color=color.orange, linewidth=2)

// ─────────────────────────────────────────────
// EMA CANDLE CROSS
// ─────────────────────────────────────────────
bullEMACross = open < ema13 and close > ema13 and close > open
bearEMACross = open > ema13 and close < ema13 and close < open

// ─────────────────────────────────────────────
// RSI 50 FILTER
// RSI must be on one side NOW and have been on
// the opposite side within the last rsiLookback candles
// ─────────────────────────────────────────────
rsiAbove50 = rsi > 50
rsiBelow50 = rsi < 50

bullRSI = false
bearRSI = false

for i = 1 to rsiLookback
    if rsi[i] < 50
        bullRSI := true
    if rsi[i] > 50
        bearRSI := true

bullRSI := bullRSI and rsiAbove50
bearRSI := bearRSI and rsiBelow50

// ─────────────────────────────────────────────
// FINAL SIGNALS
// ─────────────────────────────────────────────
buySignal  = bullEMACross and bullRSI
sellSignal = bearEMACross and bearRSI

// ─────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────
plotshape(buySignal,
     title    = "BUY",
     style    = shape.labelup,
     location = location.belowbar,
     color    = color.new(color.lime, 0),
     textcolor= color.black,
     text     = "BUY",
     size     = size.normal)

plotshape(sellSignal,
     title    = "SELL",
     style    = shape.labeldown,
     location = location.abovebar,
     color    = color.new(color.red, 0),
     textcolor= color.white,
     text     = "SELL",
     size     = size.normal)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(buySignal,
     title   = "BUY — 13 EMA Cross + RSI Above 50",
     message = "BUY | {{ticker}} | {{interval}} | Close: {{close}}")

alertcondition(sellSignal,
     title   = "SELL — 13 EMA Cross + RSI Below 50",
     message = "SELL | {{ticker}} | {{interval}} | Close: {{close}}")
````

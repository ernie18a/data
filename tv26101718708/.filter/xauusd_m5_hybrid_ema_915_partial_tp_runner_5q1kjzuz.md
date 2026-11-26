# XAUUSD M5 Hybrid EMA 9/15 (Partial TP + Runner)

- url: https://www.tradingview.com/script/5Q1KJZuZ-XAUUSD-M5-Hybrid-EMA-9-15-Partial-TP-Runner/
- type: strategy
- pine_id: PUB;d6aa451038ea4d0ab1dcee5f0d3cf0a3
- version: 1.0

## Description

This strategy is designed specifically for Gold (XAUUSD) on the 5-minute timeframe, combining trend-following EMAs with rejection-based entries and a dual take-profit system to balance consistency and high-reward opportunities.

⚙️ Strategy Logic

The system uses a 9 EMA and 15 EMA crossover to define short-term trend direction, combined with 15-minute higher timeframe confirmation to filter out low-probability trades.

Buy Conditions:
9 EMA above 15 EMA (M5)
9 EMA above 15 EMA (M15 confirmation)
Strong bullish rejection candle (long lower wick + bullish close)
Sell Conditions:
15 EMA above 9 EMA (M5)
15 EMA above 9 EMA (M15 confirmation)
Strong bearish rejection candle (long upper wick + bearish close)
💰 Trade Management (Key Edge)

Each trade is split into two parts:

TP1 (Partial Close – 50%)
Fixed at ~10 pips (1.0 gold point)
Locks in consistent profits
TP2 (Runner – 50%)
Targets ~50 pips (5.0 gold points)
Includes trailing stop to capture extended moves
Stop Loss
Based on EMA structure with buffer
Dynamic and adaptive to market conditions
🎯 Strategy Objective

This hybrid model is designed to:

Generate frequent small wins
Capture larger trend moves when they occur
Reduce drawdown through partial profit-taking
📊 Best Use Case
Instrument: XAUUSD (Gold)
Timeframe: 5 Minutes
Sessions: London & New York
Market Type: Trending / Volatile conditions
⚠️ Important Notes
This is not a guaranteed high win-rate system
Performance depends heavily on:
Market volatility
Session timing
Spread and execution quality

Backtesting and forward testing are strongly recommended before live use.

🚀 Summary

This strategy combines:

Trend alignment
Price action confirmation
Smart trade management

To create a balanced system between consistency and high-reward trades, making it suitable for disciplined intraday traders.

## Source Code

````pine
//@version=5
strategy("XAUUSD M5 Hybrid EMA 9/15 (Partial TP + Runner)", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=10)

// === INPUTS === //
emaFastLen = input.int(9, "EMA 9")
emaSlowLen = input.int(15, "EMA 15")

tp1 = input.float(1.0, "Partial TP (≈10 pips)")
tp2 = input.float(5.0, "Runner TP (≈50 pips)")

slBuffer = input.float(0.3, "SL Buffer")

// === INDICATORS (M5) === //
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

// === HIGHER TIMEFRAME (M15) === //
emaFastHTF = request.security(syminfo.tickerid, "15", ta.ema(close, emaFastLen))
emaSlowHTF = request.security(syminfo.tickerid, "15", ta.ema(close, emaSlowLen))

// === TREND CONDITIONS === //
bullTrend = emaFast > emaSlow and emaFastHTF > emaSlowHTF
bearTrend = emaFast < emaSlow and emaFastHTF < emaSlowHTF

// === STRONG REJECTION CANDLE === //
body = math.abs(close - open)
upperWick = high - math.max(close, open)
lowerWick = math.min(close, open) - low

bullishRejection = lowerWick > body * 1.5 and close > open
bearishRejection = upperWick > body * 1.5 and close < open

// === ENTRY CONDITIONS === //
buyCondition = bullTrend and bullishRejection
sellCondition = bearTrend and bearishRejection

// === STOP LOSS === //
longSL = emaSlow - slBuffer
shortSL = emaFast + slBuffer

// === EXECUTION === //
if (buyCondition)
    strategy.entry("BUY", strategy.long)

    // Partial TP
    strategy.exit("TP1 BUY", from_entry="BUY", limit=close + tp1, qty_percent=50)

    // Runner TP + trailing
    strategy.exit("TP2 BUY", from_entry="BUY", limit=close + tp2, stop=longSL, trail_points=1.5, trail_offset=1)

if (sellCondition)
    strategy.entry("SELL", strategy.short)

    // Partial TP
    strategy.exit("TP1 SELL", from_entry="SELL", limit=close - tp1, qty_percent=50)

    // Runner TP + trailing
    strategy.exit("TP2 SELL", from_entry="SELL", limit=close - tp2, stop=shortSL, trail_points=1.5, trail_offset=1)

// === PLOTS === //
plot(emaFast, color=color.green, title="EMA 9")
plot(emaSlow, color=color.red, title="EMA 15")

plotshape(buyCondition, location=location.belowbar, color=color.green, style=shape.triangleup, size=size.small)
plotshape(sellCondition, location=location.abovebar, color=color.red, style=shape.triangledown, size=size.small)
````

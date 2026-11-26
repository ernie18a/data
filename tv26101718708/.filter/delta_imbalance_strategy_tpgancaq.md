# Delta Imbalance Strategy

- url: https://www.tradingview.com/script/tpgANCaq-Delta-Imbalance-Strategy/
- type: strategy
- pine_id: PUB;885b1cdc17ce4044990143b563330730
- version: 1.0

## Description

Delta Imbalance Strategy

This strategy is built around a core idea:
Every candle creates an imbalance that must eventually be resolved.

⏱️ IMPORTANT - TIMEFRAME RESTRICTION

This strategy is specifically designed for:
Low timeframe scalping (1m – 5m charts)

It performs best where:
Order flow is fragmented
Micro-imbalances are visible
Price frequently overshoots and rebalances

Do NOT use on timeframes above 5m.

## Source Code

````pine
//@version=5
strategy("Delta Imbalance Strategy", overlay=true, pyramiding=2, initial_capital=10000)

// ==========================
// 🔧 SETTINGS
// ==========================
decay = input.float(0.95, "Imbalance Decay", step=0.001)
threshold = input.float(1.5, "Imbalance Threshold Multiplier", step=0.1)

// ==========================
// 📊 DELTA (ORDER FLOW PROXY)
// ==========================
delta = (close - open) * volume

// ==========================
// 🧠 IMBALANCE LEDGER
// ==========================
var float bull_imbalance = 0.0
var float bear_imbalance = 0.0

// Accumulate imbalance
if delta > 0
    bull_imbalance += delta
else
    bear_imbalance += -delta

// Resolve imbalance (counter candles)
if delta < 0
    bull_imbalance -= math.abs(delta)

if delta > 0
    bear_imbalance -= math.abs(delta)

// Prevent negative pools
bull_imbalance := math.max(bull_imbalance, 0)
bear_imbalance := math.max(bear_imbalance, 0)

// Apply decay (prevents infinite buildup)
bull_imbalance *= decay
bear_imbalance *= decay

// ==========================
// 📈 NORMALIZATION
// ==========================
avg_delta = ta.sma(math.abs(delta), 50)

bull_strength = bull_imbalance / avg_delta
bear_strength = bear_imbalance / avg_delta

// ==========================
// 🚨 SIGNAL LOGIC
// ==========================
// When imbalance is extreme and starts resolving

bull_peak = bull_strength > threshold
bear_peak = bear_strength > threshold

// Resolution trigger (opposite delta appears)
resolve_short = bull_peak and delta < 0
resolve_long  = bear_peak and delta > 0

// ==========================
// 📈 TRADES
// ==========================
if resolve_short
    strategy.entry("SHORT", strategy.short)

if resolve_long
    strategy.entry("LONG", strategy.long)

// ==========================
// 🛑 RISK MANAGEMENT
// ==========================
atr = ta.atr(14)

strategy.exit("XL", from_entry="LONG", stop=close - atr*2, limit=close + atr*3)
strategy.exit("XS", from_entry="SHORT", stop=close + atr*2, limit=close - atr*3)

// ==========================
// 📊 VISUALS
// ==========================
plot(bull_strength, color=color.green, title="Bull Imbalance")
plot(bear_strength, color=color.red, title="Bear Imbalance")
hline(threshold, "Threshold", color=color.gray)
````

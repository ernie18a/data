# VWAP Mean Reversion Strategy   Range Bound Forex  RSI Volume

- url: https://www.tradingview.com/script/9SEB7IHb-VWAP-Mean-Reversion-Strategy-Range-Bound-Forex-RSI-Volume/
- type: strategy
- pine_id: PUB;142cc1a12ca24caa986d790df3d065f6
- version: 1.0

## Description

### 🔷 Overview

VWAP Mean Reversion Strategy v6 is a systematic intraday trading model designed specifically for **range-bound forex markets**, where price oscillates around a fair value rather than trending.

The strategy leverages a **custom rolling VWAP (volume-weighted mean)** combined with deviation bands to identify statistically stretched price conditions and execute mean-reversion trades.

---

### ⚙️ Core Logic

This strategy operates on three key principles:

**1. VWAP-Based Mean Reversion**

* Uses a rolling VWAP (not session VWAP) as dynamic equilibrium
* Constructs deviation bands using volume-weighted absolute deviation
* Trades occur when price deviates significantly from fair value

**2. RSI Confirmation Filter**

* Long trades: RSI below oversold threshold
* Short trades: RSI above overbought threshold
* Helps avoid premature entries

**3. Volume Exhaustion Filter**

* Avoids trades during abnormal volume spikes
* Filters out potential breakout conditions (non-mean-reverting environments)

---

### 📊 Entry Conditions

**🔽 Long Setup**

* Price crosses below Lower Band (2σ deviation)
* RSI confirms oversold condition
* No extreme volume spike

**🔼 Short Setup**

* Price crosses above Upper Band (2σ deviation)
* RSI confirms overbought condition
* No extreme volume spike

---

### 🎯 Exit Logic

* **Take Profit:** Return to VWAP (mean reversion target)
* **Stop Loss:** Fixed % risk from entry price
* Designed for **high-probability, small-edge trades**

---

### 💱 Best Use Case (Forex Focus)

This strategy performs best in:

* **Range-bound currency pairs** (e.g., EUR/USD, GBP/USD, USD/JPY)
* **Low to moderate volatility sessions**
* **Non-trending market phases**

Avoid during:

* High-impact news events
* Strong directional trends
* Breakout environments

---

### ⚠️ Strategy Profile

* Type: Mean Reversion
* Market Condition: Sideways / Consolidation
* Frequency: Moderate to High
* Risk: Tight stops, frequent trades

---

### 🧠 Notes

* VWAP length controls sensitivity (shorter = faster signals)
* RSI thresholds can be tightened for higher precision
* Volume filter is critical to avoid false reversals

---

### 📌 Disclaimer

This strategy is for educational and research purposes only.
Not financial advice. Always validate with forward testing and proper risk management.

---

### 🔖 Credits

Concept based on VWAP mean reversion principles and statistical deviation modeling.

Customized into a systematic trading framework for forex markets.

## Source Code

````pine
// © VWAP Mean Reversion Strategy v6
//@version=6
strategy("VWAP Mean Reversion Strategy v6", 
     overlay = true,
     initial_capital = 10000,
     default_qty_type = strategy.percent_of_equity,
     default_qty_value = 10)

// =====================================================
// === INPUTS
// =====================================================

// --- Indicator Settings
group_ind = "Indicator Settings"
vwapLength     = input.int(60,  "VWAP Length", group = group_ind, minval = 1)
rsiLength      = input.int(14,  "RSI Length", group = group_ind, minval = 1)
rsiOverbought  = input.int(65,  "RSI Overbought", group = group_ind)
rsiOversold    = input.int(25,  "RSI Oversold", group = group_ind)
src            = input.source(close, "Source Price", group = group_ind)

// --- Risk Management
group_risk = "Risk Management"
stopLossPct = input.float(0.5, "Stop Loss %", step = 0.1, group = group_risk) / 100

// --- Volume Filter
group_filter = "Volume Filter"
enableVolFilter = input.bool(true, "Enable Volume Filter?", group = group_filter)
volLookback     = input.int(20, "Volume MA Length", group = group_filter, minval = 1)
volMultiplier   = input.float(3.0, "Volume Multiplier", step = 0.5, group = group_filter)

// =====================================================
// === CUSTOM FUNCTIONS
// =====================================================

vwMean(x, len) =>
    float weightedSum = 0.0
    float volumeSum   = 0.0
    for i = 0 to len - 1
        weightedSum += volume[i] * x[i]
        volumeSum   += volume[i]
    weightedSum / volumeSum

vwAbsDev(x, len, mean) =>
    float weightedDev = 0.0
    float volumeSum   = 0.0
    for i = 0 to len - 1
        weightedDev += volume[i] * math.abs(x[i] - mean)
        volumeSum   += volume[i]
    weightedDev / volumeSum

// =====================================================
// === CALCULATIONS
// =====================================================

basis = vwMean(src, vwapLength)
dev   = vwAbsDev(src, vwapLength, basis)

upper2 = basis + dev * 2.0
upper3 = basis + dev * 3.0
lower2 = basis - dev * 2.0
lower3 = basis - dev * 3.0

rsiValue = ta.rsi(src, rsiLength)

// =====================================================
// === VOLUME FILTER
// =====================================================

avgVol      = ta.sma(volume, volLookback)
extremeVol  = volume > avgVol * volMultiplier
volCondition = not enableVolFilter or not extremeVol

// =====================================================
// === ENTRY CONDITIONS
// =====================================================

longCondition  = ta.crossunder(src, lower2) and rsiValue < rsiOversold and volCondition
shortCondition = ta.crossover(src, upper2)  and rsiValue > rsiOverbought and volCondition

// =====================================================
// === EXECUTION
// =====================================================

if longCondition
    strategy.entry("Long", strategy.long)

if shortCondition
    strategy.entry("Short", strategy.short)

// --- Exit Logic

if strategy.position_size > 0
    strategy.exit("Long Exit",
         from_entry = "Long",
         stop  = close * (1.0 - stopLossPct),
         limit = basis)

if strategy.position_size < 0
    strategy.exit("Short Exit",
         from_entry = "Short",
         stop  = close * (1.0 + stopLossPct),
         limit = basis)

// =====================================================
// === PLOTS
// =====================================================

plot(basis,  color = color.gray, title = "VWAP Basis")

u2 = plot(upper2, color = color.red, title = "Upper Band 2")
u3 = plot(upper3, color = color.new(color.red, 60), title = "Upper Band 3")

l2 = plot(lower2, color = color.green, title = "Lower Band 2")
l3 = plot(lower3, color = color.new(color.green, 60), title = "Lower Band 3")

fill(u2, u3, color = color.new(color.red, 85))
fill(l3, l2, color = color.new(color.green, 85))
````

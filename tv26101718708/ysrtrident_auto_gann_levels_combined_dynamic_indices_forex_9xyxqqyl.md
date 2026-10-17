# YSRTRIDENT- AUTO GANN Levels Combined Dynamic (Indices + Forex)

- url: https://www.tradingview.com/script/9xyXQQYL-YSRTRIDENT-AUTO-GANN-Levels-Combined-Dynamic-Indices-Forex/
- type: indicator
- pine_id: PUB;dc4b89f44182475e969a71c0d049c2f9
- version: 1.0

## Description

# 🔱 YSR TRIDENT FX - AUTO GANN Levels Combined Dynamic (Indices + Forex)

## 📌 Overview

YSR TRIDENT FX AUTO GANN Levels Combined Dynamic is a powerful multi-market Gann-based support and resistance indicator specially designed for:

✔️ Indices
✔️ Forex Markets
✔️ Intraday Trading
✔️ Scalping
✔️ Swing Trading
✔️ Smart Money Concepts
✔️ Price Action Trading

This indicator automatically plots mathematically important Gann levels using dynamic market ranges.

---

# ⚡ Main Features

## ✅ Automatic Gann Level Generation

The script automatically plots important Gann vibration levels without manual calculations.

### 🔢 Included Gann Offsets

### 📈 Indices Levels

✔️ 90
✔️ 160
✔️ 250
✔️ 360
✔️ 490
✔️ 640
✔️ 810
✔️ 900

### 💱 Forex Levels

✔️ 9
✔️ 16
✔️ 25
✔️ 36
✔️ 49
✔️ 64
✔️ 81
✔️ 90

These levels are derived from Gann mathematical square relationships and market vibration principles.

---

# 🌍 Multi-Market Support

## 📊 Supported Indices

✔️ NIFTY
✔️ BANKNIFTY
✔️ NASDAQ
✔️ US30
✔️ DAX
✔️ S&P500
✔️ Other Major Indices

## 💹 Supported Forex Pairs

✔️ EURUSD
✔️ GBPUSD
✔️ USDJPY
✔️ XAUUSD
✔️ Major Forex Pairs

---

# 🎨 Dynamic Real-Time Colors

The levels automatically change color according to live market price.

🟢 GREEN → Price Above Level
🔴 RED → Price Below Level

This helps traders instantly identify:

✔️ Bullish Zones
✔️ Bearish Zones
✔️ Support Areas
✔️ Resistance Areas
✔️ Market Strength
✔️ Market Weakness

---

# ⚙️ Fully Customizable

Users can customize:

✔️ Start Range
✔️ End Range
✔️ Show/Hide Level Groups
✔️ Line Width

Suitable for:

⚡ Scalping
⚡ Intraday Trading
⚡ Swing Trading
⚡ Positional Trading

---

# 📘 How To Use

## 📈 1000 Levels (Major Zones)

Used for:
✔️ Institutional Levels
✔️ Major Reversals
✔️ Positional Targets
✔️ Strong Support & Resistance

### Example:

🔹 25090
🔹 25160
🔹 25250
🔹 25360

---

## 📉 100 Levels (Intraday Zones)

Used for:
✔️ Scalping Entries
✔️ Intraday Reactions
✔️ Short-Term Reversals
✔️ Price Action Confirmation

### Example:

🔹 3009
🔹 3016
🔹 3025
🔹 3036

---

# 💱 Forex Levels

Forex levels are generated using decimal precision suitable for 5-digit forex pairs.

### Example:

🔹 1.15009
🔹 1.15016
🔹 1.15025

Useful for:
✔️ Liquidity Sweeps
✔️ Precision Entries
✔️ Reversal Trading
✔️ Intraday Forex Trading

---

# 🧠 Trading Applications

This indicator works effectively with:

✔️ Price Action
✔️ Smart Money Concepts (SMC)
✔️ Order Blocks
✔️ Fair Value Gaps (FVG)
✔️ Market Structure
✔️ Breakout Trading
✔️ Liquidity Trading
✔️ Gann Analysis

---

# 📍 Suggested Trading Logic

## 🟢 Bullish Market

When price trades above multiple Gann levels:

✔️ Market strength increases
✔️ Look for buying opportunities
✔️ Levels act as support

---

## 🔴 Bearish Market

When price trades below multiple Gann levels:

✔️ Market weakness increases
✔️ Look for selling opportunities
✔️ Levels act as resistance

---

# ⏰ Recommended Timeframes

## ⚡ Scalping

✔️ 1 Minute
✔️ 3 Minute
✔️ 5 Minute

## 📊 Intraday

✔️ 15 Minute
✔️ 30 Minute

## 📈 Swing Trading

✔️ 1 Hour
✔️ 4 Hour
✔️ Daily

---

# 🛡️ Important Notes

⚠️ This indicator is designed as a support/resistance and market structure tool.

⚠️ Always use:
✔️ Proper Risk Management
✔️ Stop Loss
✔️ Trade Confirmation
✔️ Trend Analysis

Best results come when combined with:
✔️ Volume Analysis
✔️ Market Structure
✔️ Confirmation Candles
✔️ Institutional Concepts

---

# 👨‍💻 Developed By

🔱 YSR TRIDENT FX

Focused On:
✔️ Gann Analysis
✔️ Institutional Trading
✔️ Smart Money Concepts
✔️ Market Geometry
✔️ Price Action Techniques

---

# ⚠️ Disclaimer

This indicator is created for educational and analytical purposes only.

Trading financial markets involves significant risk.
Always backtest and validate before live trading.

## Source Code

````pine
//@version=5
indicator("GANN Levels Combined Dynamic (Indices + Forex)", overlay=true, max_lines_count=500)

// === INPUTS ===
// --- Indices 1000 Zone ---
show1000   = input.bool(true, "Show 1000 Levels")
start1000  = input.int(25000, "1000 Start", step=1000)
end1000    = input.int(26000, "1000 End", step=1000)

// --- Indices 100 Zone ---
show100    = input.bool(true, "Show 100 Levels")
start100   = input.int(3000, "100 Start", step=100)
end100     = input.int(3500, "100 End", step=100)

// --- Forex Zone ---
showForex  = input.bool(true, "Show Forex Levels")
baseStart  = input.float(1.15000, "Forex Base Start")
baseEnd    = input.float(1.16000, "Forex Base End")

// --- Styles ---
lineWidth  = input.int(1, "Line Width", minval=1)

// === OFFSETS ===
offsets1000 = array.from(90,160,250,360,490,640,810,900)
offsets100  = array.from(9,16,25,36,49,64,81,90)
offsetsForex = array.from(9,16,25,36,49,64,81,90)

// === FACTOR FOR FOREX ===
factor = 100000  // for 5-decimal pairs like EURUSD

// === ARRAYS TO STORE LINES ===
var line[] lines1000 = array.new_line()
var line[] lines100  = array.new_line()
var line[] linesForex = array.new_line()

// === DRAW LINES ONCE ===
if barstate.isfirst
    // --- 1000 Levels ---
    if show1000
        for base = start1000 to end1000 by 1000
            for offset in offsets1000
                level = base + offset
                l = line.new(bar_index-1, level, bar_index, level,
                             color=color.green, width=lineWidth, extend=extend.both)
                array.push(lines1000, l)

    // --- 100 Levels ---
    if show100
        for base = start100 to end100 by 100
            for offset in offsets100
                level = base + offset
                l = line.new(bar_index-1, level, bar_index, level,
                             color=color.green, width=lineWidth, extend=extend.both)
                array.push(lines100, l)

    // --- Forex Levels ---
    if showForex
        for base = int(baseStart*factor) to int(baseEnd*factor) by int(0.001*factor)
            for offset in offsetsForex
                level = (base + offset) / factor
                l = line.new(bar_index-1, level, bar_index, level,
                             color=color.green, width=lineWidth, extend=extend.both)
                array.push(linesForex, l)

// === UPDATE LINE COLORS IN REAL-TIME ===
for l in lines1000
    line.set_color(l, close > line.get_price(l, 0) ? color.green : color.red)

for l in lines100
    line.set_color(l, close > line.get_price(l, 0) ? color.green : color.red)

for l in linesForex
    line.set_color(l, close > line.get_price(l, 0) ? color.green : color.red)
````

# Reliable SuperTrend + VWAP + BOS + MTF | Intraday Pro Indicator

- url: https://www.tradingview.com/script/ZvI98mWW-Reliable-SuperTrend-VWAP-BOS-MTF-Intraday-Pro-Indicator/
- type: indicator
- pine_id: PUB;00c7f9fb6bbc4f73a4ae2bb0860b096d
- version: 2.0

## Description

# 🚀Reliable SuperTrend + VWAP + BOS + MTF | Intraday Pro Indicator

## 🔍 Overview

This indicator is a **professional-grade intraday trading system** built to align with **market structure, volatility, and institutional flow**.

By combining **Pivot-based SuperTrend**, **VWAP positioning**, and **Break of Structure (BOS)** logic, it filters out low-quality trades and highlights only high-probability opportunities.

---

## 🧠 What Makes It Different?

Unlike traditional indicators that rely on lagging signals, this system focuses on:

* ✔ Real market structure (pivot-based trend logic)
* ✔ Institutional bias (VWAP positioning)
* ✔ Smart entries (pullbacks instead of chasing)
* ✔ Early exits (structure-based, not reactive)

👉 Result: **Cleaner signals, better timing, and improved consistency**

---

## ⚙️ Core Features

### 📈 Pivot-Based SuperTrend

* Uses adaptive pivot levels instead of fixed ATR bands
* Tracks real support/resistance zones
* Provides dynamic trailing stop

---

### ⚖️ VWAP Smart Filter

* Trades only when price is decisively above/below VWAP
* Includes ATR-based buffer to avoid noise
* Helps align with institutional trading zones

---

### 🎯 Clean Trend Signals

* One signal per trend → avoids overtrading
* Filters out choppy market conditions
* Focuses on high-quality setups

---

### 🔁 Pullback Entry Engine

* Identifies retracements near VWAP
* Confirms entries using strong momentum candles
* Improves risk-to-reward ratio significantly

---

### 💥 Break of Structure (BOS)

* Tracks recent swing highs/lows
* Detects true structure breaks
* Automatically resets levels to prevent repainting

---

### 🚨 Early Exit System

* Exits trades when structure breaks against position
* Helps protect profits before reversals
* Reduces dependency on stop-loss

---

### 🔍 Advanced Filters

* Volume Filter → avoids weak participation
* Volatility Filter → avoids sideways markets
* Higher Timeframe (HTF) Filter → trade with dominant trend

---

## 📊 Signal Types

* 🟢 **BUY** → Strong bullish trend with VWAP confirmation
* 🔴 **SELL** → Strong bearish trend with VWAP confirmation
* 🔵 **Pullback Buy** → Retracement + bullish momentum
* 🟠 **Pullback Sell** → Rally + bearish rejection
* ❌ **EXIT** → Structure break → exit early

---

## 🎯 How to Use (Simple Workflow)

1. Identify overall trend (optional HTF filter)
2. Wait for main BUY/SELL signals in trending markets
3. Use pullback signals for refined entries
4. Exit early on structure break signals

---

## ⚡ Best Use Cases

* Intraday trading (3m / 5m / 15m)
* Index trading (Nifty / BankNifty)
* Futures and liquid stocks

---

## 💡 Pro Tip

> Trade in the direction of the higher timeframe,
> enter on pullbacks near VWAP,
> and exit on structure break.
> Remove Pullback Buy/Sell for clear chart

---

## ⚠️ Disclaimer

This indicator is for educational purposes only and does not guarantee profits. Always use proper risk management.

---

## 👨‍💻 Author Note

This system is designed for traders who want **clarity over clutter** — fewer signals, better quality, and structured decision-making.

---

## Source Code

````pine
//@version=6
indicator("Reliable Pivot SuperTrend + MTF Dash [Final V6]", overlay = true, max_labels_count = 500, max_lines_count = 500)

// --- 1. Inputs ---
grpMain  = "Main Settings"
prd      = input.int(2, "Pivot Period", minval=1, group=grpMain)
factor   = input.float(3.0, "ATR Factor", step=0.1, group=grpMain)
pd       = input.int(10, "ATR Lookback", group=grpMain)
bufferPc = input.float(0.2, "VWAP Buffer % of ATR", step=0.05, group=grpMain)

grpSignals = "Signal Display Settings"
showPullbacks = input.bool(false, "Show Pullback Signals (Triangles)", group=grpSignals)

grpDash  = "MTF Dashboard Settings"
showDash = input.bool(true, "Show Dashboard", group=grpDash)
dashTF1  = input.timeframe("15", "Dashboard TF 1", group=grpDash)
dashTF2  = input.timeframe("30", "Dashboard TF 2", group=grpDash)
dashTF3  = input.timeframe("60", "Dashboard TF 3", group=grpDash)
dashTF4  = input.timeframe("D",  "Dashboard TF 4", group=grpDash)

// --- 2. Calculations (Volatility & Pivots) ---
atrValue = ta.rma(ta.tr(true), pd)
ph = ta.pivothigh(prd, prd)
pl = ta.pivotlow(prd, prd)

var float center = na
lastpp = not na(ph) ? ph : (not na(pl) ? pl : na)
if not na(lastpp)
    center := na(center) ? lastpp : (center * 2 + lastpp) / 3

// --- 3. SuperTrend Engine (Current Timeframe) ---
Up = center - (factor * atrValue)
Dn = center + (factor * atrValue)
var float TUp = 0.0
var float TDown = 0.0
var int trend = 0

TUp   := close[1] > TUp[1] ? math.max(Up, TUp[1]) : Up
TDown := close[1] < TDown[1] ? math.min(Dn, TDown[1]) : Dn
trend := close > TDown[1] ? 1 : (close < TUp[1] ? -1 : nz(trend[1], 1))
trailStop = trend == 1 ? TUp : TDown

// --- 4. HIGHER TIMEFRAME DATA GATHERING (Dashboard Only) ---
trendTF1 = request.security(syminfo.tickerid, dashTF1, trend[1], barmerge.gaps_off, barmerge.lookahead_on)
trendTF2 = request.security(syminfo.tickerid, dashTF2, trend[1], barmerge.gaps_off, barmerge.lookahead_on)
trendTF3 = request.security(syminfo.tickerid, dashTF3, trend[1], barmerge.gaps_off, barmerge.lookahead_on)
trendTF4 = request.security(syminfo.tickerid, dashTF4, trend[1], barmerge.gaps_off, barmerge.lookahead_on)

// --- 5. VWAP Filter ---
vwapVal = ta.vwap(hlc3)
dynamicBuffer = ta.atr(14) * bufferPc
isBullishZone = close > (vwapVal + dynamicBuffer)
isBearishZone = close < (vwapVal - dynamicBuffer)

// --- 6a. Main Signals (UNFILTERED by HTF) ---
var bool buyTriggered = false
var bool sellTriggered = false

if trend != trend[1]
    buyTriggered  := false
    sellTriggered := false

buyCondition  = (trend == 1) and isBullishZone and not buyTriggered
sellCondition = (trend == -1) and isBearishZone and not sellTriggered

if buyCondition
    buyTriggered := true
if sellCondition
    sellTriggered := true

// --- 6b. Pullback Signals (UNFILTERED by HTF) ---
nearVwapBull = low <= (vwapVal + (dynamicBuffer * 3))
nearVwapBear = high >= (vwapVal - (dynamicBuffer * 3))
bullishBounce = (close > open) and (close > close[1])
bearishBounce = (close < open) and (close < close[1])

pbBuyCondition  = (trend == 1) and nearVwapBull and bullishBounce and not buyCondition
pbSellCondition = (trend == -1) and nearVwapBear and bearishBounce and not sellCondition

// --- 6c. BOS ENGINE ---
var float activePH = na
var float activePL = na
var int activePHBar = na
var int activePLBar = na

if not na(ph)
    activePH := ph
    activePHBar := bar_index - prd 
if not na(pl)
    activePL := pl
    activePLBar := bar_index - prd

bullBOS = false
bearBOS = false

if not na(activePH) and close > activePH
    bullBOS := true
    line.new(activePHBar, activePH, bar_index, activePH, color=color.new(color.lime, 40), style=line.style_dashed, width=2)
    activePH := na 

if not na(activePL) and close < activePL
    bearBOS := true
    line.new(activePLBar, activePL, bar_index, activePL, color=color.new(color.red, 40), style=line.style_dashed, width=2)
    activePL := na 

// --- 6d. EARLY EXIT LOGIC ---
earlyExitLong = (trend == 1) and bearBOS
earlyExitShort = (trend == -1) and bullBOS

// --- 7. Plotting Indicators ---
lineColor = trend == 1 ? color.lime : color.red
plot(trailStop, "Trailing Stop", color=lineColor, linewidth=2)
plot(vwapVal, "VWAP", color=color.new(color.gray, 50))

plotshape(buyCondition, "Main Buy", shape.labelup, location.belowbar, color.lime, text="BUY", textcolor=color.black, size=size.tiny)
plotshape(sellCondition, "Main Sell", shape.labeldown, location.abovebar, color.red, text="SELL", textcolor=color.white, size=size.tiny)

plotshape(showPullbacks and pbBuyCondition, "Pullback Buy", shape.triangleup, location.belowbar, color.new(color.blue, 0), size=size.small)
plotshape(showPullbacks and pbSellCondition, "Pullback Sell", shape.triangledown, location.abovebar, color.new(color.orange, 0), size=size.small)

plotshape(earlyExitLong, "Exit Long", shape.xcross, location.abovebar, color.orange, text="EXIT", textcolor=color.orange, size=size.small)
plotshape(earlyExitShort, "Exit Short", shape.xcross, location.belowbar, color.orange, text="EXIT", textcolor=color.orange, size=size.small)

// --- 8. MULTI-TIMEFRAME DASHBOARD ---
if showDash
    var dash = table.new(position.top_right, 2, 5, bgcolor = color.new(color.black, 60), border_width = 1, border_color=color.gray)
    if barstate.islast
        // Headers
        table.cell(dash, 0, 0, "Timeframe", text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 80))
        table.cell(dash, 1, 0, "Trend Bias", text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 80))
        
        // TF 1
        tf1Color = trendTF1 == 1 ? color.lime : color.red
        table.cell(dash, 0, 1, dashTF1 + " Min", text_color=color.white, text_size=size.small)
        table.cell(dash, 1, 1, trendTF1 == 1 ? "BULLISH" : "BEARISH", text_color=color.black, bgcolor=tf1Color, text_size=size.small)
        
        // TF 2
        tf2Color = trendTF2 == 1 ? color.lime : color.red
        table.cell(dash, 0, 2, dashTF2 + " Min", text_color=color.white, text_size=size.small)
        table.cell(dash, 1, 2, trendTF2 == 1 ? "BULLISH" : "BEARISH", text_color=color.black, bgcolor=tf2Color, text_size=size.small)
        
        // TF 3
        tf3Color = trendTF3 == 1 ? color.lime : color.red
        table.cell(dash, 0, 3, dashTF3 + " Min", text_color=color.white, text_size=size.small)
        table.cell(dash, 1, 3, trendTF3 == 1 ? "BULLISH" : "BEARISH", text_color=color.black, bgcolor=tf3Color, text_size=size.small)
        
        // TF 4
        tf4Color = trendTF4 == 1 ? color.lime : color.red
        table.cell(dash, 0, 4, dashTF4 == "D" ? "Daily" : dashTF4, text_color=color.white, text_size=size.small)
        table.cell(dash, 1, 4, trendTF4 == 1 ? "BULLISH" : "BEARISH", text_color=color.black, bgcolor=tf4Color, text_size=size.small)

// --- 9. Alerts ---
if buyCondition
    alert("Main Buy: Local Trend + VWAP confirmed", alert.freq_once_per_bar_close)
if sellCondition
    alert("Main Sell: Local Trend + VWAP confirmed", alert.freq_once_per_bar_close)

if showPullbacks and pbBuyCondition
    alert("Pullback Buy: Dip and Bounce", alert.freq_once_per_bar_close)
if showPullbacks and pbSellCondition
    alert("Pullback Sell: Rally and Rejection", alert.freq_once_per_bar_close)

if earlyExitLong
    alert("EARLY EXIT: Uptrend structure broken!", alert.freq_once_per_bar_close)
if earlyExitShort
    alert("EARLY EXIT: Downtrend structure broken!", alert.freq_once_per_bar_close)
````

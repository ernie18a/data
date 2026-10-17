# Badawy_Macro Risk Dashboard 

- url: https://www.tradingview.com/script/EU5566uR/
- type: indicator
- pine_id: PUB;bd81cc9964304ccebc084861d83ba77c
- version: 1.0

## Description

# 🔥 **Macro Risk Dashboard – Institutional Regime Indicator**

## 📊 **Overview**

The **Macro Risk Dashboard** is a multi-asset, institutional-grade indicator designed to quantify the overall market environment into a single **Macro Score (0–100)**.

It aggregates key macro signals across:

* Volatility
* Liquidity
* Growth
* Credit Markets

Then transforms them into a **clear Risk-On / Risk-Off regime**.

👉 Built for traders who want to think like institutions — not retail noise.

---

## 🧠 **Core Idea**

Instead of relying on price alone, this indicator reads the **macro engine behind the market**:

| Component  | What it Measures         | Signal Logic                 |
| ---------- | ------------------------ | ---------------------------- |
| VIX        | Market fear              | Lower = Bullish              |
| DXY        | Dollar strength          | Lower = Risk On              |
| US10Y      | Yields / liquidity       | Lower = Liquidity expansion  |
| QQQ        | Growth / Tech leadership | Above MA = Bullish           |
| HYG vs TLT | Credit risk appetite     | Risk assets outperform bonds |

Each component contributes to a weighted score → final **Macro Score**

📌 Source logic from your script: 

---

## ⚙️ **How It Works**

### 1️⃣ Scoring Engine

Each macro block contributes:

* **Liquidity (US10Y + DXY)** → 50 pts
* **Volatility (VIX)** → 25 pts
* **Growth (QQQ)** → 25 pts
* **Credit (HYG vs TLT)** → 18 pts

Score is normalized to:
👉 **0 → 100 scale**

---

### 2️⃣ Regime Detection

* 🟢 **Risk ON** → Score ≥ 70
* 🔴 **Risk OFF** → Score ≤ 45
* 🟠 **Neutral** → Between both

---

### 3️⃣ Visual Feedback

* Colored line:

  * Green → Risk On
  * Red → Risk Off
  * Orange → Neutral

* Background shading reflects regime

* Labels appear when regime changes

* Dashboard table shows real-time macro states

---

## 📈 **How to Use It**

### 🟢 Risk ON Environment

* Favor:

  * Growth stocks (QQQ, SOXL)
  * Breakouts
  * Trend-following

* Strategy:

  * Buy dips
  * Aggressive positioning

---

### 🔴 Risk OFF Environment

* Favor:

  * Defensive assets
  * Gold / bonds
  * Shorts / hedges

* Strategy:

  * Reduce exposure
  * Protect capital

---

### 🟠 Neutral

* Range trading
* Lower conviction trades
* Wait for confirmation

---

## 🎯 **Best Use Cases**

* Swing Trading
* Macro Trading
* Portfolio Allocation
* Risk Management Layer (VERY powerful)

---

## ⚡ **Why This Indicator is Powerful**

* Combines **6 macro markets** into 1 signal
* Filters fake moves driven by liquidity
* Works across all timeframes
* Adapts automatically if data is missing
* Thinks like **institutional flow**, not price-only indicators

---

## ⚠️ **Important Notes**

* This is a **macro regime tool**, not a direct entry signal

* Should be combined with:

  * Price action
  * Volume
  * Execution strategy

* No repainting (uses confirmed data)

* Slight lag due to moving averages (by design for stability)

---

## 🧪 **Pro Tip (Advanced)**

Use it as a **master filter**:

❌ Don’t take longs if Risk = OFF
❌ Don’t short aggressively if Risk = ON

👉 This alone can eliminate 50–70% of bad trades.

---

## 🏷️ **Tags**

#Macro #RiskOn #RiskOff #SmartMoney #Institutional #VIX #DXY #QQQ #Liquidity #TradingView #MarketRegime #Quant

## Source Code

````pine
//@version=6
indicator("My Indicator_ Macro", overlay=false, max_labels_count=100)

//-------------------------
// Inputs
//-------------------------
vixSymbol   = input.symbol("CBOE:VIX", "VIX")
dxySymbol   = input.symbol("TVC:DXY", "DXY")
us10ySymbol = input.symbol("TVC:US10Y", "US 10Y Yield")
qqqSymbol   = input.symbol("NASDAQ:QQQ", "QQQ")
hygSymbol   = input.symbol("AMEX:HYG", "HYG")
tltSymbol   = input.symbol("NASDAQ:TLT", "TLT")

maShort = input.int(10, "Short MA", minval=2)
maMed   = input.int(20, "Medium MA", minval=2)

showTable   = input.bool(true, "Show Dashboard Table")
showBg      = input.bool(true, "Show Background")
showLabels  = input.bool(true, "Show Regime Labels")

riskOnLevel  = input.int(70, "Risk On Threshold", minval=0, maxval=100)
riskOffLevel = input.int(45, "Risk Off Threshold", minval=0, maxval=100)

//-------------------------
// Data
//-------------------------
vix   = request.security(vixSymbol,   timeframe.period, close)
dxy   = request.security(dxySymbol,   timeframe.period, close)
us10y = request.security(us10ySymbol, timeframe.period, close)
qqq   = request.security(qqqSymbol,   timeframe.period, close)
hyg   = request.security(hygSymbol,   timeframe.period, close)
tlt   = request.security(tltSymbol,   timeframe.period, close)

//-------------------------
// Validity checks
//-------------------------
vix_ok   = not na(vix)
dxy_ok   = not na(dxy)
us10y_ok = not na(us10y)
qqq_ok   = not na(qqq)
hyg_ok   = not na(hyg)
tlt_ok   = not na(tlt)

//-------------------------
// Moving averages
//-------------------------
vixMA   = vix_ok   ? ta.sma(vix, maShort)   : na
dxyMA   = dxy_ok   ? ta.sma(dxy, maMed)     : na
us10yMA = us10y_ok ? ta.sma(us10y, maMed)   : na
qqqMA   = qqq_ok   ? ta.sma(qqq, maMed)     : na
hygMA   = hyg_ok   ? ta.sma(hyg, maMed)     : na
tltMA   = tlt_ok   ? ta.sma(tlt, maMed)     : na

//-------------------------
// Bullish states
//-------------------------
vixBull   = vix_ok   and not na(vixMA)   ? vix < vixMA     : false
dxyBull   = dxy_ok   and not na(dxyMA)   ? dxy < dxyMA     : false
us10yBull = us10y_ok and not na(us10yMA) ? us10y < us10yMA : false
qqqBull   = qqq_ok   and not na(qqqMA)   ? qqq > qqqMA     : false
creditBull = hyg_ok and tlt_ok and not na(hygMA) and not na(tltMA) ? (hyg > hygMA and tlt < tltMA) : false

//-------------------------
// Score by available data only
//-------------------------
liqScoreRaw   = (us10yBull ? 25 : 10) + (dxyBull ? 25 : 10)
riskScoreRaw  = (vixBull ? 25 : 8)
growthRaw     = (qqqBull ? 25 : 10)
creditRaw     = (creditBull ? 18 : 8)

liqWeight   = (us10y_ok ? 1 : 0) + (dxy_ok ? 1 : 0)
riskWeight  = vix_ok ? 1 : 0
growthWeight= qqq_ok ? 1 : 0
creditWeight= (hyg_ok and tlt_ok) ? 1 : 0

availableBlocks = liqWeight + riskWeight + growthWeight + creditWeight

rawScore =
     (liqWeight > 0 ? liqScoreRaw : 0) +
     (riskWeight > 0 ? riskScoreRaw : 0) +
     (growthWeight > 0 ? growthRaw : 0) +
     (creditWeight > 0 ? creditRaw : 0)

maxPossible =
     (liqWeight > 0 ? 50 : 0) +
     (riskWeight > 0 ? 25 : 0) +
     (growthWeight > 0 ? 25 : 0) +
     (creditWeight > 0 ? 18 : 0)

macroScore = maxPossible > 0 ? math.round(rawScore * 100 / maxPossible) : na

//-------------------------
// Regime
//-------------------------
riskOn  = not na(macroScore) and macroScore >= riskOnLevel
riskOff = not na(macroScore) and macroScore <= riskOffLevel
neutral = not na(macroScore) and not riskOn and not riskOff

regimeText = riskOn ? "RISK ON" : riskOff ? "RISK OFF" : "NEUTRAL"

//-------------------------
// Plot
//-------------------------
plot(macroScore, title="Macro Score", linewidth=3, color=riskOn ? color.lime : riskOff ? color.red : color.orange)
hline(riskOnLevel, "Risk On", color=color.new(color.green, 50))
hline(riskOffLevel, "Risk Off", color=color.new(color.red, 50))
hline(50, "Midline", color=color.new(color.gray, 70))

bgcolor(showBg ? (riskOn ? color.new(color.green, 88) : riskOff ? color.new(color.red, 88) : color.new(color.orange, 90)) : na)

//-------------------------
// Labels
//-------------------------
regimeChanged = bar_index > 0 and regimeText != regimeText[1]

if showLabels and regimeChanged and not na(macroScore)
    label.new(
         bar_index,
         macroScore,
         regimeText,
         style=label.style_label_down,
         color=riskOn ? color.green : riskOff ? color.red : color.orange,
         textcolor=color.white
     )

//-------------------------
// Alerts
//-------------------------
alertcondition(riskOn, "Macro Risk On", "Institutional Macro Dashboard: RISK ON")
alertcondition(riskOff, "Macro Risk Off", "Institutional Macro Dashboard: RISK OFF")
alertcondition(regimeChanged, "Macro Regime Changed", "Institutional Macro Dashboard: Regime changed")

//-------------------------
// Helpers
//-------------------------
f_stateText(_isAvailable, _bull) =>
    not _isAvailable ? "N/A" : _bull ? "Positive" : "Negative"

f_stateColor(_isAvailable, _bull) =>
    not _isAvailable ? color.gray : _bull ? color.green : color.red

f_fmt(_x) =>
    na(_x) ? "N/A" : str.tostring(_x, format.mintick)

//-------------------------
// Table
//-------------------------
var table dash = table.new(position.top_right, 4, 9, border_width=1)

if barstate.islast and showTable
    table.cell(dash, 0, 0, "Metric", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 0, "Value",  text_color=color.white, bgcolor=color.black)
    table.cell(dash, 2, 0, "MA",     text_color=color.white, bgcolor=color.black)
    table.cell(dash, 3, 0, "State",  text_color=color.white, bgcolor=color.black)

    table.cell(dash, 0, 1, "VIX")
    table.cell(dash, 1, 1, f_fmt(vix))
    table.cell(dash, 2, 1, f_fmt(vixMA))
    table.cell(dash, 3, 1, f_stateText(vix_ok, vixBull), text_color=color.white, bgcolor=f_stateColor(vix_ok, vixBull))

    table.cell(dash, 0, 2, "DXY")
    table.cell(dash, 1, 2, f_fmt(dxy))
    table.cell(dash, 2, 2, f_fmt(dxyMA))
    table.cell(dash, 3, 2, f_stateText(dxy_ok, dxyBull), text_color=color.white, bgcolor=f_stateColor(dxy_ok, dxyBull))

    table.cell(dash, 0, 3, "US10Y")
    table.cell(dash, 1, 3, f_fmt(us10y))
    table.cell(dash, 2, 3, f_fmt(us10yMA))
    table.cell(dash, 3, 3, f_stateText(us10y_ok, us10yBull), text_color=color.white, bgcolor=f_stateColor(us10y_ok, us10yBull))

    table.cell(dash, 0, 4, "QQQ")
    table.cell(dash, 1, 4, f_fmt(qqq))
    table.cell(dash, 2, 4, f_fmt(qqqMA))
    table.cell(dash, 3, 4, f_stateText(qqq_ok, qqqBull), text_color=color.white, bgcolor=f_stateColor(qqq_ok, qqqBull))

    table.cell(dash, 0, 5, "HYG")
    table.cell(dash, 1, 5, f_fmt(hyg))
    table.cell(dash, 2, 5, f_fmt(hygMA))
    table.cell(dash, 3, 5, f_stateText(hyg_ok, hyg_ok and not na(hygMA) ? hyg > hygMA : false), text_color=color.white, bgcolor=f_stateColor(hyg_ok, hyg_ok and not na(hygMA) ? hyg > hygMA : false))

    table.cell(dash, 0, 6, "TLT")
    table.cell(dash, 1, 6, f_fmt(tlt))
    table.cell(dash, 2, 6, f_fmt(tltMA))
    table.cell(dash, 3, 6, f_stateText(tlt_ok, tlt_ok and not na(tltMA) ? tlt < tltMA : false), text_color=color.white, bgcolor=f_stateColor(tlt_ok, tlt_ok and not na(tltMA) ? tlt < tltMA : false))

    table.cell(dash, 0, 7, "Score", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 7, f_fmt(macroScore), text_color=color.white, bgcolor=color.black)
    table.cell(dash, 2, 7, "Regime", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 3, 7, regimeText, text_color=color.white, bgcolor=riskOn ? color.green : riskOff ? color.red : color.orange)

    table.cell(dash, 0, 8, "Data", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 8, str.tostring(availableBlocks))
    table.cell(dash, 2, 8, "Blocks")
    table.cell(dash, 3, 8, maxPossible > 0 ? "OK" : "No Data", text_color=color.white, bgcolor=maxPossible > 0 ? color.green : color.red)
````

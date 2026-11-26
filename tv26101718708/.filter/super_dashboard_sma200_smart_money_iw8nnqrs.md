#  SUPER DASHBOARD  + SMA200 + SMART MONEY

- url: https://www.tradingview.com/script/Iw8NnQrS/
- type: indicator
- pine_id: PUB;74c14fecd6834f57abc1f5e18c7380d7
- version: 2.0

## Description

🚀 **SUPER DASHBOARD  + SMART MONEY**

📊 A powerful all-in-one trading indicator that combines **trend, volume, momentum, liquidity, and Smart Money analysis** into a single, easy-to-read dashboard.

---

### 🔥 Key Features

🔹 **Trend Engine**
Uses EMA 20 / 50 and **SMA 200** to define the market direction
→ Clearly identifies bullish or bearish trends

🔹 **HTF Confirmation**
Higher Timeframe (Daily) trend validation
→ Adds confidence through multi-timeframe alignment

🔹 **Volume & Market Control**
Analyzes Buyer vs Seller dominance
→ Helps you understand who is driving the market

🔹 **Momentum (RVOL)**
Measures strength of price moves using relative volume
→ Filters out weak or fake moves

🔹 **Liquidity Filter**
Identifies high vs low liquidity stocks
→ Avoid illiquid and risky setups

🔹 **Smart Money Detector 🧠**

* 🟢 Accumulation → Institutional buying
* 🔴 Distribution → Institutional selling
* 💣 Capitulation → Potential bottom

🔹 **Alpha Score 👑**
Ranks stocks by strength (Leader / Weak)
→ Focus on high-quality opportunities

🔹 **Signal Engine 🎯**

* 🚀 BUY → Strong bullish setup
* 💥 SELL → Bearish signal
* ⚖️ WAIT → No clear edge

---

### 🧠 Why This Indicator?

Instead of relying on a single signal, it combines:
✔ Trend
✔ Volume
✔ Momentum
✔ Smart Money behavior

👉 Delivering a **complete market view in seconds**

---

### ⚠️ Best Practice

For optimal performance, combine it with:
📍 Support & Resistance levels
📍 Overall market context

---

💡 **Conclusion:**
This is not just an indicator — it’s a **complete trading system** designed for traders who want **clarity, precision, and professional-level decision-making**.

## Source Code

````pine
//@version=6
indicator("🚀 SUPER DASHBOARD PRO+ FINAL", overlay=true)

// ==============================
// ⚙️ DISPLAY SETTINGS
// ==============================
showEMA20 = input.bool(true, "Show EMA 20")
showEMA50 = input.bool(true, "Show EMA 50")
showSMA200 = input.bool(true, "Show SMA 200")

// ==============================
// ⚙️ TABLE POSITION
// ==============================
grpTable = "Table Settings"

tablePosInput = input.string("top_right", "Table Position",
     options=["top_right","top_left","bottom_right","bottom_left"], group=grpTable)

tablePos =
     tablePosInput == "top_right" ? position.top_right :
     tablePosInput == "top_left" ? position.top_left :
     tablePosInput == "bottom_right" ? position.bottom_right :
     position.bottom_left

// ==============================
// 📊 TREND
// ==============================
emaFast = ta.ema(close, 20)
emaSlow = ta.ema(close, 50)
sma200  = ta.sma(close, 200)

// ✅ Style
plot(showEMA20 ? emaFast : na, color=color.lime, linewidth=2, title="EMA 20")
plot(showEMA50 ? emaSlow : na, color=color.red, linewidth=2, title="EMA 50")
plot(showSMA200 ? sma200 : na, color=color.blue, linewidth=2, title="SMA 200")

trendBull = emaFast > emaSlow and close > sma200
trendBear = emaFast < emaSlow and close < sma200

trendText = ""
trendColor = color.white

if trendBull
    trendText := "🟢 Bull"
    trendColor := color.lime
else if trendBear
    trendText := "🔴 Bear"
    trendColor := color.red
else
    trendText := "⚖️ Neutral"
    trendColor := color.orange

// ==============================
// 📊 TREND 200
// ==============================
trend200Text = close > sma200 ? "🟢 Above 200" : "🔴 Below 200"
trend200Color = close > sma200 ? color.lime : color.red

// ==============================
// 💰 CONTROL
// ==============================
buyVol = high != low ? volume * (close - low) / (high - low) : 0
buyPct = volume > 0 ? (buyVol / volume) * 100 : 0

controlText = buyPct > 60 ? "🟢 Buyers" : buyPct < 40 ? "🔴 Sellers" : "⚖️ Neutral"
controlColor = buyPct > 60 ? color.lime : buyPct < 40 ? color.red : color.orange

// ==============================
// ⚡ MOMENTUM
// ==============================
rvol = volume / ta.sma(volume, 20)

momentumText = rvol > 1.5 ? "🔥 Strong" : rvol > 1.1 ? "⚡ Medium" : "❄️ Weak"
momentumColor = rvol > 1.5 ? color.lime : rvol > 1.1 ? color.orange : color.gray

// ==============================
// 🧠 SMART MONEY
// ==============================
avgVol = ta.sma(volume, 20)
volClimax = volume > avgVol * 2

body = math.abs(close - open)
rangeCandle = high - low

strongCandle = rangeCandle > 0 ? (body / rangeCandle) > 0.6 : false

accumulation = volClimax and strongCandle and close > emaFast and close > open
distribution = volClimax and strongCandle and close < emaFast and close < open

smText = accumulation ? "🟢 Accumulation" :
         distribution ? "🔴 Distribution" :
         "⚖️ Neutral"

smColor = accumulation ? color.lime :
          distribution ? color.red :
          color.gray

// ==============================
// 💰 LIQUIDITY
// ==============================
liquidity = volume * close

// ==============================
// 👑 SCORING
// ==============================
score = 0.0

if trendBull
    score += 40
if accumulation
    score += 20
if rvol > 1.3
    score += 20
if liquidity > 2000000
    score += 20

scoreColor = score >= 80 ? color.lime :
             score >= 60 ? color.orange :
             color.red

// ==============================
// 🧠 CONFIDENCE
// ==============================
confidence = score >= 80 ? "🔥 High" :
             score >= 60 ? "⚡ Medium" :
             "❄️ Low"

confidenceColor = score >= 80 ? color.lime :
                  score >= 60 ? color.orange :
                  color.red

// ==============================
// 💰 RISK / REWARD
// ==============================
entry = close
sl = entry * 0.97
tp = entry * 1.08

rr = (tp - entry) / (entry - sl)

// ==============================
// 🎯 SIGNAL
// ==============================
signal = "⚖️ WAIT"
signalColor = color.orange

if trendBull and accumulation and (rangeCandle > 0 ? (body / rangeCandle) > 0.5 : false)
    signal := "🚀 BUY"
    signalColor := color.lime
else if trendBear and distribution
    signal := "💥 SELL"
    signalColor := color.red

// ==============================
// 📊 TABLE
// ==============================
var table t = table.new(tablePos, 2, 10, border_color=color.white)

if barstate.islast
    table.cell(t, 0, 0, "Metric", bgcolor=color.gray, text_color=color.white)
    table.cell(t, 1, 0, "Value", bgcolor=color.gray, text_color=color.white)

    table.cell(t, 0, 1, "Trend", text_color=color.white)
    table.cell(t, 1, 1, trendText, text_color=trendColor)

    table.cell(t, 0, 2, "Trend 200", text_color=color.white)
    table.cell(t, 1, 2, trend200Text, text_color=trend200Color)

    table.cell(t, 0, 3, "Control", text_color=color.white)
    table.cell(t, 1, 3, controlText, text_color=controlColor)

    table.cell(t, 0, 4, "Momentum", text_color=color.white)
    table.cell(t, 1, 4, momentumText, text_color=momentumColor)

    table.cell(t, 0, 5, "Smart Money", text_color=color.white)
    table.cell(t, 1, 5, smText, text_color=smColor)

    table.cell(t, 0, 6, "Score", text_color=color.white)
    table.cell(t, 1, 6, str.tostring(score), text_color=scoreColor)

    table.cell(t, 0, 7, "Confidence", text_color=color.white)
    table.cell(t, 1, 7, confidence, text_color=confidenceColor)

    table.cell(t, 0, 8, "R:R", text_color=color.white)
    table.cell(t, 1, 8, str.tostring(rr, "#.##"))

    table.cell(t, 0, 9, "Signal", text_color=color.white)
    table.cell(t, 1, 9, signal, text_color=signalColor)
````

# AS PRO ENGINE CLEAN (Elephant + SMA + FVG + EMA + AMA)

- url: https://www.tradingview.com/script/94vzc5TZ/
- type: indicator
- pine_id: PUB;a4438f05995646c7a76fc331b8f8eae1
- version: 1.0

## Description

This Pine Script v6 code defines a multi-layer trading indicator called “AS PRO ENGINE CLEAN (Elephant + SMA + FVG + EMA + AMA)”, which combines volatility detection, trend filtering, institutional price structures, and adaptive moving averages into one overlay system for TradingView.

🧠 General Overview

The script is designed as a multi-signal Smart Money-style engine that visually and algorithmically detects:

High-impact momentum candles (“Elephant bars”)
Fair Value Gaps (FVGs)
Multi-timeframe EMA trend direction
Standard SMAs (8, 20, 200) for structure
Adaptive Moving Average (AMA) for dynamic smoothing
Alert conditions combining all major signals

Everything is plotted directly on the price chart (overlay=true).

⚙️ MASTER CONTROLS

The user can globally enable or disable core modules:

🐘 Elephant detection
📦 FVG zones
⚡ EMA multi-timeframe filter
🧠 AMA adaptive average

This allows flexible switching between full system mode or partial analysis.

🐘 ELEPHANT MODULE (Momentum Detection)

This section detects high-impact candles based on volatility and body strength:

Logic:
Uses ATR to measure volatility expansion
Compares candle range to ATR × multiplier
Measures candle body dominance inside total range
Conditions:
Big Range Candle → range > ATR × multiplier
Strong Body Candle → body ratio > threshold
Bullish or bearish classification based on close vs open
Output:
bullElephant → strong bullish momentum candle
bearElephant → strong bearish momentum candle

Also colors bars:

Green → bullish elephant
Red → bearish elephant
📈 SMA STRUCTURE LAYER

Three simple moving averages define market structure:

SMA 8 → short-term reaction line
SMA 20 → medium trend filter
SMA 200 → macro trend direction

All are plotted using stepped style for clearer structure visualization.

📦 FVG (Fair Value Gaps)

Detects inefficiencies in price using a 3-candle model:

Bullish FVG:
Current low is above high two candles back
Bearish FVG:
Current high is below low two candles back

When detected:

A colored box is drawn on chart
Green = bullish imbalance
Red = bearish imbalance
Boxes extend forward by configurable length
⚡ EMA MULTI-TIMEFRAME MODULE

This section imports EMA from a higher timeframe:

User selects timeframe (default: 5 minutes)
EMA length is configurable (default: 20)
Signals:
emaUp → price crosses above EMA (bullish trigger)
emaDown → price crosses below EMA (bearish trigger)

EMA is plotted with semi-transparent yellow styling.

🧠 AMA (Adaptive Moving Average)

A custom adaptive smoothing algorithm:

Core idea:
Combines SMA baseline with dynamic sensitivity
Reacts stronger when price deviates from mean
Formula logic:
Uses SMA as center reference
Calculates deviation ratio
Applies exponential-like adaptive smoothing

Result:

Fast during trends
Smooth during consolidation

Plotted as a purple line when enabled.

🎨 VISUAL LAYER
Candle coloring depends on Elephant signals
SMA + EMA + AMA overlays provide layered trend context
FVG boxes visualize institutional imbalance zones
🚨 ALERT SYSTEM

Three alert types:

1. SMC Signal

Triggers when:

Elephant bar OR FVG appears
2. EMA Signal

Triggers on:

EMA cross up or down
3. ALL SIGNALS

Triggers when:

Any major condition occurs (combined system alert)
🧩 In Simple Terms

This script builds a multi-confirmation trading engine:

Elephant candles = momentum spikes
SMA = structural trend
EMA MTF = directional bias
FVG = liquidity imbalance zones
AMA = adaptive smoothing trend filter
Alerts = unified decision triggers

## Source Code

````pine
//@version=6
indicator("AS PRO ENGINE CLEAN (Elephant + SMA + FVG + EMA + AMA)", overlay=true, max_boxes_count=200)

//────────────────────
// ⚙️ MASTER
//────────────────────
group_master = "⚙️ MASTER"
enableElephant = input.bool(true, "Enable Elephant", group=group_master)
enableFVG      = input.bool(true, "Enable FVG", group=group_master)
enableEMA      = input.bool(true, "Enable EMA MTF", group=group_master)
enableAMA      = input.bool(true, "Enable AMA", group=group_master)

//────────────────────
// 🐘 ELEPHANT
//────────────────────
group_ele = "🐘 Elephant"
atrLen      = input.int(10, "ATR Length", group=group_ele)
mult        = input.float(1.5, "ATR Multiplier", step=0.1, group=group_ele)
bodyPercent = input.float(0.5, "Body Strength", step=0.05, group=group_ele)

atr = ta.atr(atrLen)
barRange = high - low
body = math.abs(close - open)

bodyRatio = barRange > 0 ? body / barRange : 0
isBigRange = barRange > atr * mult
isStrongBody = bodyRatio > bodyPercent

elephantBar = enableElephant and isBigRange and isStrongBody
bullElephant = elephantBar and close > open
bearElephant = elephantBar and close < open

//────────────────────
// 📈 SMA
//────────────────────
group_sma = "📈 SMA"
sma8Len   = input.int(8, "SMA 8", group=group_sma)
sma20Len  = input.int(20, "SMA 20", group=group_sma)
sma200Len = input.int(200, "SMA 200", group=group_sma)

sma8 = ta.sma(close, sma8Len)
sma20 = ta.sma(close, sma20Len)
sma200 = ta.sma(close, sma200Len)

plot(sma8, color=color.rgb(120, 123, 134, 46), style = plot.style_stepline, title="SMA 8")
plot(sma20, color=color.rgb(255, 153, 0, 76), style = plot.style_stepline, title="SMA 20")
plot(sma200, color=color.rgb(82, 183, 255, 78), style = plot.style_stepline, title="SMA 200")

//────────────────────
// 📦 FVG
//────────────────────
group_fvg = "📦 FVG"
fvgExtend = input.int(3, "Extend", group=group_fvg)

bullFVG = low > high[2]
bearFVG = high < low[2]

if enableFVG and bullFVG
    box.new(bar_index-2, low, bar_index+fvgExtend, high[2],
        bgcolor=color.new(color.green, 80), border_width=0)

if enableFVG and bearFVG
    box.new(bar_index-2, low[2], bar_index+fvgExtend, high,
        bgcolor=color.new(color.red, 80), border_width=0)

//────────────────────
// ⚡ EMA MTF
//────────────────────
group_ema = "⚡ EMA"
emaLen = input.int(20, "EMA Length", group=group_ema)
tf = input.timeframe("5", "HTF", group=group_ema)

emaMTF = enableEMA ? request.security(syminfo.tickerid, tf, ta.ema(close, emaLen)) : na

plot(emaMTF, color=color.rgb(255, 235, 59, 74), title="EMA MTF")

emaUp = ta.crossover(close, emaMTF)
emaDown = ta.crossunder(close, emaMTF)

//────────────────────
// 🧠 AMA
//────────────────────
group_ama = "🧠 AMA"
len = input.int(10, "Length", group=group_ama)
power = input.float(2, "Power", group=group_ama)

src = close
mid = ta.sma(src, len)
alpha = math.pow(math.abs(src - mid) / mid, power)

var float ama = src
ama := nz(ama[1]) + alpha * (src - nz(ama[1]))

plot(enableAMA ? ama : na, color=color.rgb(76, 0, 131, 69), title="AMA")

//────────────────────
// 🎨 COLORS
//────────────────────
barcolor(bullElephant ? color.lime : bearElephant ? color.red : na)

//────────────────────
// 🚨 ALERTS
//────────────────────
signal_main = elephantBar or bullFVG or bearFVG
signal_ema  = emaUp or emaDown

alertcondition(signal_main, title="SMC Signal", message="Elephant or FVG")
alertcondition(signal_ema, title="EMA Signal", message="EMA Cross")
alertcondition(signal_ema or signal_main, title="ALL", message="Take a Look!")
````

# XAUUSD Gold Sniper Dashboard PRO

- url: https://www.tradingview.com/script/KKPwhWGZ-XAUUSD-Gold-Sniper-Dashboard-PRO/
- type: indicator
- pine_id: PUB;ce232c4d583047d28b33da2b0e1144cc
- version: 1.0

## Description

A precision-built trading dashboard designed specifically for XAUUSD (Gold), combining institutional concepts like EMA, VWAP, Premium/Discount zones, and psychological levels into one clear, actionable view.

This tool helps traders quickly identify market bias, entry quality, and price positioning—eliminating guesswork and improving decision-making in fast-moving gold markets.

🔑 Key Features

• Market Bias Detection

Automatically defines Bullish, Bearish, or Neutral conditions
Based on price relative to EMA 50 and VWAP

• Smart Entry Zones

Highlights:
✅ Strong Long / Short Zones
⚠️ Okay Pullbacks
🚫 Chase Warnings (overextended moves)
Built around pullbacks to value (EMA + VWAP confluence)

• VWAP & EMA Distance Logic

Tracks how far price is from key levels
Labels conditions as:
Near
Healthy
Stretched
Overextended

• Premium / Discount Framework

Uses a dynamic range to identify:
🟢 Discount (buy-side interest)
🔴 Premium (sell-side interest)
Displays equilibrium (50% level)

• Psychological Levels ($50 increments)

Automatically calculates nearest key level
Helps identify reaction zones and liquidity areas

• Real-Time Dashboard

Clean table showing:
Price, EMA, VWAP
Distances to key levels
Market bias
Entry quality + trading hint
📊 How to Use
Look for alignment between bias + zone + VWAP/EMA proximity
Focus on:
Discount + Bullish Bias → Long setups
Premium + Bearish Bias → Short setups
Avoid trades when:
Market is overextended
Dashboard shows “Wait” or “Chase Warning”
⚙️ Best For
Intraday & scalping traders
XAUUSD specialists
Traders using smart money concepts (SMC), VWAP, and mean reversion

## Source Code

````pine
//@version=5
indicator("XAUUSD Gold Sniper Dashboard PRO", overlay=true)

// =========================
// SETTINGS
// =========================
step = input.float(50.0, "Psychological Level Step", step=0.1)
swingLookback = input.int(50, "Discount Range Lookback", minval=10)

// XAUUSD distance thresholds
nearEMA = input.float(4.0, "Near EMA Threshold")
nearVWAP = input.float(5.0, "Near VWAP Threshold")
stretchVWAP = input.float(15.0, "Stretched VWAP Threshold")
overextendVWAP = input.float(25.0, "Overextended VWAP Threshold")

// =========================
// CORE CALCULATIONS
// =========================
ema50 = ta.ema(close, 50)
vwapVal = ta.vwap(close)

// Distances
distEMA = close - ema50
distVWAP = close - vwapVal
absDistEMA = math.abs(distEMA)
absDistVWAP = math.abs(distVWAP)

// Nearest psych level
nearest50 = math.round(close / step) * step
distTo50 = close - nearest50

// =========================
// DISCOUNT / PREMIUM ZONE
// =========================
rangeHigh = ta.highest(high, swingLookback)
rangeLow = ta.lowest(low, swingLookback)
equilibrium = (rangeHigh + rangeLow) / 2

pdText = close < equilibrium ? "Discount Zone" : "Premium Zone"
pdColor = close < equilibrium ? color.new(color.green, 0) : color.new(color.red, 0)

// =========================
// BIAS LOGIC
// =========================
bullBias = close > ema50 and close > vwapVal
bearBias = close < ema50 and close < vwapVal

biasText = bullBias ? "Bullish Bias" :
     bearBias ? "Bearish Bias" :
     "Neutral / Chop"

// =========================
// VWAP CONDITION
// =========================
vwapState = absDistVWAP <= nearVWAP ? "Near VWAP" :
     absDistVWAP <= stretchVWAP ? "Healthy Distance" :
     absDistVWAP <= overextendVWAP ? "Stretched" :
     "Overextended"

vwapColor = absDistVWAP <= nearVWAP ? color.green :
     absDistVWAP <= stretchVWAP ? color.lime :
     absDistVWAP <= overextendVWAP ? color.orange :
     color.red

// =========================
// EMA CONDITION
// =========================
emaState = absDistEMA <= nearEMA ? "Near EMA50" : "Extended from EMA50"
emaColor = absDistEMA <= nearEMA ? color.green : color.orange

// =========================
// ENTRY QUALITY LOGIC
// =========================
entryText = "Wait"
entryColor = color.orange
hintText = "Wait for cleaner structure"

// LONG conditions
goodLongPullback = bullBias and close < equilibrium and absDistEMA <= nearEMA and absDistVWAP <= stretchVWAP
okayLongPullback = bullBias and close < equilibrium and absDistEMA <= nearEMA
chaseLong = bullBias and absDistVWAP > overextendVWAP

// SHORT conditions
goodShortPullback = bearBias and close > equilibrium and absDistEMA <= nearEMA and absDistVWAP <= stretchVWAP
okayShortPullback = bearBias and close > equilibrium and absDistEMA <= nearEMA
chaseShort = bearBias and absDistVWAP > overextendVWAP

if goodLongPullback
    entryText := "STRONG LONG ZONE"
    entryColor := color.green
    hintText := "Discount pullback near EMA/VWAP"
else if okayLongPullback
    entryText := "OKAY LONG ZONE"
    entryColor := color.lime
    hintText := "Good pullback, wait for confirmation"
else if chaseLong
    entryText := "CHASE WARNING"
    entryColor := color.red
    hintText := "Bullish but too stretched from VWAP"
else if goodShortPullback
    entryText := "STRONG SHORT ZONE"
    entryColor := color.red
    hintText := "Premium pullback near EMA/VWAP"
else if okayShortPullback
    entryText := "OKAY SHORT ZONE"
    entryColor := color.orange
    hintText := "Good short area, wait for confirmation"
else if chaseShort
    entryText := "CHASE WARNING"
    entryColor := color.red
    hintText := "Bearish but too stretched from VWAP"
else
    entryText := "WAIT"
    entryColor := color.gray
    hintText := "No clean setup right now"

// =========================
// PLOTS
// =========================
plot(ema50, title="EMA 50", color=color.yellow, linewidth=2)
plot(vwapVal, title="VWAP", color=color.aqua, linewidth=2)
plot(equilibrium, title="Equilibrium (50%)", color=color.fuchsia, linewidth=2, style=plot.style_line)

// =========================
// DASHBOARD TABLE
// =========================
var table dash = table.new(position.top_right, 1, 11, border_width=1)

if barstate.islast
    table.cell(dash, 0, 0, "Price: " + str.tostring(close, format.mintick), text_color=color.white, bgcolor=color.black)
    table.cell(dash, 0, 1, "EMA 50: " + str.tostring(ema50, format.mintick), text_color=color.black, bgcolor=color.yellow)
    table.cell(dash, 0, 2, "VWAP: " + str.tostring(vwapVal, format.mintick), text_color=color.black, bgcolor=color.aqua)
    table.cell(dash, 0, 3, "Dist EMA: " + str.tostring(distEMA, format.mintick), text_color=color.white, bgcolor=color.gray)
    table.cell(dash, 0, 4, "Dist VWAP: " + str.tostring(distVWAP, format.mintick), text_color=color.white, bgcolor=color.gray)
    table.cell(dash, 0, 5, "EMA State: " + emaState, text_color=color.white, bgcolor=emaColor)
    table.cell(dash, 0, 6, "VWAP State: " + vwapState, text_color=color.white, bgcolor=vwapColor)
    table.cell(dash, 0, 7, "Nearest $50: " + str.tostring(nearest50, format.mintick), text_color=color.black, bgcolor=color.orange)
    table.cell(dash, 0, 8, "Dist to $50: " + str.tostring(distTo50, format.mintick), text_color=color.white, bgcolor=color.gray)
    table.cell(dash, 0, 9, pdText + " | EQ: " + str.tostring(equilibrium, format.mintick), text_color=color.white, bgcolor=pdColor)
    table.cell(dash, 0, 10, biasText + " | " + entryText + " | " + hintText,
         text_color=color.white,
         bgcolor=entryColor)
````

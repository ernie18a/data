# IDM + IFVG Sniper Entry Final Fixed VASWANI

- url: https://www.tradingview.com/script/8vxgsQ9J-IDM-IFVG-Sniper-Entry-Final-Fixed-VASWANI/
- type: indicator
- pine_id: PUB;9e1e8d1a73cc47ba85769db7e46d9b3f
- version: 1.0

## Description

IDM + IFVG Sniper Entry Final Fixed VASWANI


This indicator is designed to identify high-probability “sniper” trade entries based on Smart Money Concepts (SMC), combining Inducement (IDM), Inverse Fair Value Gaps (IFVG), and trend confirmation.

It helps traders avoid noise and focus only on structured setups where liquidity has been taken and price is reacting from key imbalance zones.

---

## ⚙️ How It Works

The indicator combines multiple layers of confirmation:

• Trend filtering using EMA (50 / 200)
• Liquidity sweeps (IDM) to detect trapped traders
• Fair Value Gap (FVG) and Inverse FVG (IFVG) zones
• Rejection candles for entry timing
• Cooldown logic to avoid repeated signals

Signals are only printed when all conditions align, resulting in fewer but higher-quality setups.

---

## 🔻 SELL Setup Logic

A SELL signal is generated when:

• Market is in a bearish trend
• Price retraces into a bearish IFVG zone
• Liquidity above highs is swept (IDM) or rejection occurs
• Weak close confirms selling pressure

---

## 🔺 BUY Setup Logic

A BUY signal is generated when:

• Market is in a bullish trend
• Price retraces into a bullish IFVG zone
• Liquidity below lows is swept (IDM) or rejection occurs
• Strong close confirms buying pressure

---

## 🎯 Best Usage

• Works best on 15-minute timeframe
• Can be refined using 5-minute for entries
• Ideal for BTC, indices, and liquid markets
• Designed for trend-following setups

---

## ⚠️ Important Notes

This is a rule-based indicator, not a guarantee of profits.
Always combine with proper risk management and market context.

Avoid trading against the trend, and do not chase signals away from zones.

---

## 💡 Pro Tip

Use this indicator as a confirmation tool:

• Identify direction on higher timeframe
• Wait for price to return to IFVG zone
• Enter only when signal appears with rejection

---

## 🚀 Summary

This tool simplifies Smart Money Concepts into actionable signals, helping traders focus on:

• Liquidity traps (IDM)
• Institutional zones (IFVG)
• Clean, structured entries

Fewer signals. Better precision.

## Source Code

````pine
//@version=5
indicator("IDM + IFVG Sniper Entry Final Fixed", overlay=true, max_boxes_count=50, max_labels_count=50)

// Inputs
mode = input.string("SELL Only", "Signal Mode", options=["SELL Only", "BUY Only", "BUY and SELL"])
emaFastLen = input.int(50, "Fast EMA")
emaSlowLen = input.int(200, "Slow EMA")
swingLen = input.int(10, "Liquidity Swing Length")
cooldown = input.int(15, "Minimum Candles Between Signals")
showZones = input.bool(true, "Show IFVG Zones")

// EMA trend
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

plot(emaFast, color=color.blue, title="Fast EMA")
plot(emaSlow, color=color.black, title="Slow EMA")

bearTrend = close < emaFast and emaFast < emaSlow and emaFast < emaFast[1]
bullTrend = close > emaFast and emaFast > emaSlow and emaFast > emaFast[1]

// IDM liquidity sweep
recentHigh = ta.highest(high[1], swingLen)
recentLow = ta.lowest(low[1], swingLen)

idmSell = high > recentHigh and close < recentHigh
idmBuy = low < recentLow and close > recentLow

// FVG detection
bullFVG = low > high[2]
bearFVG = high < low[2]

// Store latest zones
var float bullTop = na
var float bullBottom = na
var float bearTop = na
var float bearBottom = na

var bool bullZoneUsed = false
var bool bearZoneUsed = false

if bullFVG
    bullTop := low
    bullBottom := high[2]
    bullZoneUsed := false

if bearFVG
    bearTop := low[2]
    bearBottom := high
    bearZoneUsed := false

// Zone touch
sellZoneTouch = not na(bearTop) and high >= bearBottom and low <= bearTop
buyZoneTouch = not na(bullTop) and low <= bullTop and high >= bullBottom

// Rejection candle
body = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

bearReject = close < open and upperWick > body * 0.7
bullReject = close > open and lowerWick > body * 0.7

// Confirmation
sellCloseWeak = not na(bearBottom) and (close < bearBottom or close < emaFast)
buyCloseStrong = not na(bullTop) and (close > bullTop or close > emaFast)

// Cooldown
var int lastSellBar = na
var int lastBuyBar = na

sellCooldownOK = na(lastSellBar) or bar_index - lastSellBar > cooldown
buyCooldownOK = na(lastBuyBar) or bar_index - lastBuyBar > cooldown

// Mode
allowSell = mode == "SELL Only" or mode == "BUY and SELL"
allowBuy = mode == "BUY Only" or mode == "BUY and SELL"

// Final signals
sellSignal = allowSell and bearTrend and sellZoneTouch and not bearZoneUsed and sellCooldownOK and sellCloseWeak and (idmSell or bearReject)
buySignal = allowBuy and bullTrend and buyZoneTouch and not bullZoneUsed and buyCooldownOK and buyCloseStrong and (idmBuy or bullReject)

if sellSignal
    lastSellBar := bar_index
    bearZoneUsed := true

if buySignal
    lastBuyBar := bar_index
    bullZoneUsed := true

// Plot signals
plotshape(sellSignal, title="SNIPER SELL", style=shape.labeldown, location=location.abovebar, color=color.red, text="SELL", textcolor=color.white, size=size.small)
plotshape(buySignal, title="SNIPER BUY", style=shape.labelup, location=location.belowbar, color=color.green, text="BUY", textcolor=color.white, size=size.small)

// Alerts
alertcondition(sellSignal, title="Sniper Sell Alert", message="High probability SELL setup detected")
alertcondition(buySignal, title="Sniper Buy Alert", message="High probability BUY setup detected")

// Draw zones
if showZones and bearFVG
    box.new(bar_index[2], bearTop, bar_index + 30, bearBottom, bgcolor=color.new(color.red, 88), border_color=color.new(color.red, 55))

if showZones and bullFVG
    box.new(bar_index[2], bullTop, bar_index + 30, bullBottom, bgcolor=color.new(color.green, 88), border_color=color.new(color.green, 55))
````

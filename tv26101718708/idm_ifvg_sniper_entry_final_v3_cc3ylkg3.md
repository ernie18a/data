# IDM + IFVG Sniper Entry Final V3

- url: https://www.tradingview.com/script/cC3ylkG3-IDM-IFVG-Sniper-Entry-Final-V3/
- type: indicator
- pine_id: PUB;492fb455454e42e0aa12b7bcf3b0ca54
- version: 1.0

## Description

Description

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
indicator("IDM + IFVG Sniper Entry Final V3", overlay=true, max_boxes_count=50, max_labels_count=50)

// === INPUTS ===
mode = input.string("SELL Only", "Signal Mode", options=["SELL Only", "BUY Only", "BUY and SELL"])
emaFastLen = input.int(50, "Fast EMA")
emaSlowLen = input.int(200, "Slow EMA")
swingLen = input.int(8, "Liquidity Swing Length")
cooldown = input.int(15, "Minimum Candles Between Signals")
zoneLookback = input.int(3, "Max Candles After IFVG Touch")
showZones = input.bool(true, "Show IFVG Zones")

// === EMA TREND ===
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

plot(emaFast, color=color.blue, title="Fast EMA")
plot(emaSlow, color=color.black, title="Slow EMA")

bearTrend = close < emaSlow or emaFast < emaSlow
bullTrend = close > emaSlow or emaFast > emaSlow

// === IDM / LIQUIDITY SWEEP ===
recentHigh = ta.highest(high[1], swingLen)
recentLow = ta.lowest(low[1], swingLen)

idmSell = high > recentHigh and close < recentHigh
idmBuy = low < recentLow and close > recentLow

// === FVG DETECTION ===
bullFVG = low > high[2]
bearFVG = high < low[2]

// === STORE LATEST IFVG ZONES ===
var float bullTop = na
var float bullBottom = na
var float bearTop = na
var float bearBottom = na

var int lastBearFvgBar = na
var int lastBullFvgBar = na

var bool bullZoneUsed = false
var bool bearZoneUsed = false

if bullFVG
    bullTop := low
    bullBottom := high[2]
    lastBullFvgBar := bar_index
    bullZoneUsed := false

if bearFVG
    bearTop := low[2]
    bearBottom := high
    lastBearFvgBar := bar_index
    bearZoneUsed := false

// === IFVG TOUCH ===
sellZoneTouch = not na(bearTop) and high >= bearBottom and low <= bearTop
buyZoneTouch = not na(bullTop) and low <= bullTop and high >= bullBottom

// Save the candle where price touched IFVG
var int lastSellTouchBar = na
var int lastBuyTouchBar = na

if sellZoneTouch
    lastSellTouchBar := bar_index

if buyZoneTouch
    lastBuyTouchBar := bar_index

nearSellZone = not na(lastSellTouchBar) and bar_index - lastSellTouchBar <= zoneLookback
nearBuyZone = not na(lastBuyTouchBar) and bar_index - lastBuyTouchBar <= zoneLookback

// === REJECTION CANDLE ===
body = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

bearReject = close < open or upperWick > body * 0.5
bullReject = close > open or lowerWick > body * 0.5

// === CLOSE CONFIRMATION ===
sellCloseWeak = close < open or close < emaFast
buyCloseStrong = close > open or close > emaFast

// === COOLDOWN ===
var int lastSellBar = na
var int lastBuyBar = na

sellCooldownOK = na(lastSellBar) or bar_index - lastSellBar > cooldown
buyCooldownOK = na(lastBuyBar) or bar_index - lastBuyBar > cooldown

// === MODE FILTER ===
allowSell = mode == "SELL Only" or mode == "BUY and SELL"
allowBuy = mode == "BUY Only" or mode == "BUY and SELL"

// === FINAL SIGNALS ===
// More precise: signal must happen on IFVG touch candle or within few candles after touch
sellSignal = allowSell and bearTrend and nearSellZone and not bearZoneUsed and sellCooldownOK and sellCloseWeak and (idmSell or bearReject)
buySignal = allowBuy and bullTrend and nearBuyZone and not bullZoneUsed and buyCooldownOK and buyCloseStrong and (idmBuy or bullReject)

if sellSignal
    lastSellBar := bar_index
    bearZoneUsed := true

if buySignal
    lastBuyBar := bar_index
    bullZoneUsed := true

// === ATR LABEL OFFSET ===
atr = ta.atr(14)
sellY = high + atr * 0.25
buyY = low - atr * 0.25

// === CANDLE-ATTACHED LABELS ===
if sellSignal
    label.new(x=bar_index, y=sellY, text="SELL", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)

if buySignal
    label.new(x=bar_index, y=buyY, text="BUY", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)

// === ALERTS ===
alertcondition(sellSignal, title="Sniper Sell Alert", message="IDM + IFVG SELL setup near zone")
alertcondition(buySignal, title="Sniper Buy Alert", message="IDM + IFVG BUY setup near zone")

// === DRAW IFVG ZONES ===
if showZones and bearFVG
    box.new(left=bar_index[2], top=bearTop, right=bar_index + 30, bottom=bearBottom, xloc=xloc.bar_index, bgcolor=color.new(color.red, 88), border_color=color.new(color.red, 55))

if showZones and bullFVG
    box.new(left=bar_index[2], top=bullTop, right=bar_index + 30, bottom=bullBottom, xloc=xloc.bar_index, bgcolor=color.new(color.green, 88), border_color=color.new(color.green, 55))
````

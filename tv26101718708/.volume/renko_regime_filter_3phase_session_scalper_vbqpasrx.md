# Renko Regime Filter - 3Phase Session Scalper

- url: https://www.tradingview.com/script/vbqPaSrX-Renko-Regime-Filter-3Phase-Session-Scalper/
- type: indicator
- pine_id: PUB;e1f080eac07047abb1b88a686fbc744c
- version: 1.0

## Description

Description:
A precision Renko trading system designed for futures and index instruments (MES, NQ, ES). Built around 3 session phases with adaptive signal filtering and broker-ready webhook alert payloads.

How It Works
Signals are generated only when all of the following align:

Brick direction matches the trade — LONG requires a green brick, SHORT requires a red brick
2 consecutive bricks in the same direction confirm momentum
EMA regime is confirmed — the most recent EMA cross must agree with the trade direction
EMA separation exceeds the minimum gap threshold — filters entries in the whipsaw zone right after a cross
VWAP position — price must be above VWAP for LONG, below for SHORT
Session filter — trades only fire during defined high-probability windows


3-Phase Session Engine (US Eastern Time)
PhaseWindowFilterPre-Market8:30 – 9:30 AMHigh volatility required (ATR ratio)Regular9:30 – 11:00 AMFull signal, no extra filterAfternoon2:00 – 4:00 PMHigh volatility required (ATR ratio)
Outside these windows, no signals fire.

Volatility Gate
ATR is compared against its own moving average. The ratio ATR / ATR_SMA must exceed the configurable threshold for pre-market and afternoon sessions. This keeps the system out of low-energy, choppy conditions.

Webhook Payload
Designed for direct broker integration (Tradovate, Alpaca, etc.):
Regular session payload (includes trailing stop):
json{
  "ticker": "MESH2025",
  "risk": "renko",
  "action": "BUY",
  "entry-price": "5120.25",
  "sl-ticks": "64",
  "tp-price": "5152.25",
  "mintick": "0.25",
  "renko-style": "trailing-stop"
}
Pre-market / afternoon payload (fixed stop):
json{
  "ticker": "MESH2025",
  "risk": "renko",
  "action": "SELL",
  "entry-price": "5120.25",
  "sl-price": "5136.25",
  "tp-price": "5088.25",
  "mintick": "0.25"
}
sl-ticks is calculated as (slBricks × brickSize) / mintick — a whole number ready for direct order submission.

Inputs
InputDefaultDescriptionFast EMA9Fast trend EMASlow EMA21Slow trend EMAMin EMA Gap0.5Minimum separation between EMAs to allow a signalRenko Brick Size8.0Size of each Renko brick in pointsSL Bricks2.0Stop loss distance in bricksTP Bricks4.0Take profit distance in bricksATR Length14ATR calculation periodATR Threshold1.0Minimum ATR ratio for volatility gate

Visual Guide

🟩 LONG label — below bar, green — all conditions met for a long entry
🟥 SHORT label — above bar, red — all conditions met for a short entry
🟡 Yellow background — pre-market session active
🟢 Green background — regular session active
🔵 Blue background — afternoon session active
Green line — Fast EMA
Red line — Slow EMA
Blue line — VWAP


Important Notes

This indicator is designed for Renko charts only. On standard candlestick charts the brick direction logic (close > open) will behave differently.
The Min EMA Gap input should be tuned per instrument. Use the Data Window (View → Data Window) to observe live EMA Gap values and set the threshold just above the gap size at weak signals you want to filter.
Webhook alerts use alert.freq_once_per_bar_close — alerts fire on bar close, not intra-bar.
This is not financial advice. Always validate signals in a paper trading environment before live deployment.

## Source Code

````pine
//@version=5
indicator("Renko 3-Phase ATR Webhook System", overlay=true)

// ==========================
// INPUTS
// ==========================

fastEMA      = input.int(9,    "Fast EMA")
slowEMA      = input.int(21,   "Slow EMA")
brickSize    = input.float(8.0,"Renko Brick Size")
slBricks     = input.float(2.0,"SL Bricks")
tpBricks     = input.float(4.0,"TP Bricks")
atrLen       = input.int(14,   "ATR Length")
atrThreshold = input.float(1.0,"ATR Threshold")
minEmaGap    = input.float(0.5,"Min EMA Gap (Points)", tooltip="Increase to filter weak crossover signals")

// ==========================
// INDICATORS
// ==========================

emaFast   = ta.ema(close, fastEMA)
emaSlow   = ta.ema(close, slowEMA)
vwapValue = ta.vwap(close)

atr      = ta.atr(atrLen)
atrAvg   = ta.sma(atr, atrLen)
volRatio = atr / atrAvg
highVol  = volRatio > atrThreshold

// ==========================
// RENKO BRICK DIRECTION
// ==========================

greenBrick  = close > open
redBrick    = close < open
greenStreak = greenBrick and greenBrick[1]
redStreak   = redBrick   and redBrick[1]

// ==========================
// EMA REGIME + SEPARATION GUARD  ← NEW
// ==========================

emaCrossedBullish = ta.crossover(emaFast, emaSlow)
emaCrossedBearish = ta.crossunder(emaFast, emaSlow)

barsSinceBull = ta.barssince(emaCrossedBullish)
barsSinceBear = ta.barssince(emaCrossedBearish)

inBullRegime = barsSinceBull < barsSinceBear
inBearRegime = barsSinceBear < barsSinceBull

emaGap       = math.abs(emaFast - emaSlow)
emasSeparated = emaGap > minEmaGap   // ← filters the weak crossover zone

// ==========================
// SESSION ENGINE (ET)
// ==========================

isPre = not na(time(timeframe.period, "0830-0930", "America/New_York"))
isReg = not na(time(timeframe.period, "0930-1100", "America/New_York"))
isAft = not na(time(timeframe.period, "1400-1600", "America/New_York"))

// ==========================
// TREND LOGIC
// ==========================

trendLong  = greenStreak and inBullRegime and emasSeparated and close > emaFast and emaFast > emaSlow and close > vwapValue
trendShort = redStreak   and inBearRegime and emasSeparated and close < emaFast and emaFast < emaSlow and close < vwapValue

// ==========================
// 3-PHASE FILTERS
// ==========================

preLong  = isPre and highVol and trendLong
preShort = isPre and highVol and trendShort
regLong  = isReg and trendLong
regShort = isReg and trendShort
aftLong  = isAft and highVol and trendLong
aftShort = isAft and highVol and trendShort

// ==========================
// FINAL SIGNALS
// ==========================

longActive  = preLong  or regLong  or aftLong
shortActive = preShort or regShort or aftShort

buySignal  = longActive  and not longActive[1]
sellSignal = shortActive and not shortActive[1]

// ==========================
// RISK MODEL
// ==========================

slPoints = brickSize * slBricks
tpPoints = brickSize * tpBricks

longSL  = close - slPoints
longTP  = close + tpPoints
shortSL = close + slPoints
shortTP = close - tpPoints

// ==========================
// VISUALS
// ==========================

plot(emaFast,   color=color.green)
plot(emaSlow,   color=color.red)
plot(vwapValue, color=color.blue)

// EMA gap strength bar — shows separation visually
plot(emaGap, title="EMA Gap", display=display.data_window)

plotshape(buySignal,  style=shape.labelup,   location=location.belowbar, text="LONG",  color=color.green)
plotshape(sellSignal, style=shape.labeldown, location=location.abovebar, text="SHORT", color=color.red)

bgcolor(isPre ? color.new(color.yellow, 90) :         isReg ? color.new(color.green,  90) :         isAft ? color.new(color.blue,   90) : na)
// ==========================
// WEBHOOK ALERTS
// ==========================

slTicks = int(slPoints / syminfo.mintick)

if buySignal
    if isReg
        alert('{"ticker":"' + syminfo.ticker + '","risk":"renko","action":"BUY","entry-price":"' + str.tostring(close) + '","sl-ticks":"' + str.tostring(slTicks) + '","tp-price":"' + str.tostring(longTP) + '","mintick":"' + str.tostring(syminfo.mintick) + '","renko-style":"trailing-stop"}', alert.freq_once_per_bar_close)
    else
        alert('{"ticker":"' + syminfo.ticker + '","risk":"renko","action":"BUY","entry-price":"' + str.tostring(close) + '","sl-price":"' + str.tostring(longSL) + '","tp-price":"' + str.tostring(longTP) + '","mintick":"' + str.tostring(syminfo.mintick) + '"}', alert.freq_once_per_bar_close)

if sellSignal
    if isReg
        alert('{"ticker":"' + syminfo.ticker + '","risk":"renko","action":"SELL","entry-price":"' + str.tostring(close) + '","sl-ticks":"' + str.tostring(slTicks) + '","tp-price":"' + str.tostring(shortTP) + '","mintick":"' + str.tostring(syminfo.mintick) + '","renko-style":"trailing-stop"}', alert.freq_once_per_bar_close)
    else
        alert('{"ticker":"' + syminfo.ticker + '","risk":"renko","action":"SELL","entry-price":"' + str.tostring(close) + '","sl-price":"' + str.tostring(shortSL) + '","tp-price":"' + str.tostring(shortTP) + '","mintick":"' + str.tostring(syminfo.mintick) + '"}', alert.freq_once_per_bar_close)
````

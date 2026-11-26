# Sriram FINAL BOSS - Institutional Engine (Stable)

- url: https://www.tradingview.com/script/Ded8MtFh-Sriram-FINAL-BOSS-Institutional-Engine-Stable/
- type: indicator
- pine_id: PUB;a1cde32a6ad44801aac91ca59bee3382
- version: 1.0

## Description

perfect indicator for trading and taking postonal calls.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © koushikvarshaa

//@version=6
indicator("Sriram FINAL BOSS - Institutional Engine (Stable)", overlay=true, max_labels_count=500)

//========================
// INPUTS
//========================
isBankNifty = input.bool(true, "BankNifty? (else Nifty)")
strongTrendThreshold = input.float(0.15, "Trend Strength Threshold")

//========================
// CORE CALCULATION
//========================
strikeStep = isBankNifty ? 100 : 50

atm  = math.round(close / strikeStep) * strikeStep
s1   = atm + strikeStep
s2   = atm + strikeStep * 2
s_1  = atm - strikeStep
s_2  = atm - strikeStep * 2

//========================
// TREND ENGINE
//========================
vwap = ta.vwap(close)
ema9 = ta.ema(close, 9)
ema21 = ta.ema(close, 21)

spread = math.abs(ema9 - ema21)

trendUp = close > vwap and ema9 > ema21 and spread > 5
trendDn = close < vwap and ema9 < ema21 and spread > 5

strongTrend = spread > ta.sma(spread, 10) * strongTrendThreshold

//========================
// VOLUME + MOMENTUM (OI REPLACEMENT)
//========================
volAvg = ta.sma(volume, 20)
volSpike = volume > volAvg * 1.5

delta = close - close[1]

buyCluster = volSpike and delta > 0
sellCluster = volSpike and delta < 0

//========================
// PRICE ACTION
//========================
bullCandle = close > open
bearCandle = close < open

breakUp = close > high[1] and bullCandle
breakDn = close < low[1] and bearCandle

//========================
// SIGNALS (CLEAN)
//========================
buy = trendUp and strongTrend and volSpike and breakUp and buyCluster

sell = trendDn and strongTrend and volSpike and breakDn and sellCluster

//========================
// STATE ENGINE
//========================
var float entry = na
var int direction = 0

if buy and direction <= 0
    entry := close
    direction := 1

if sell and direction >= 0
    entry := close
    direction := -1

//========================
// TARGETS
//========================
t1 = entry + direction * 50
t2 = entry + direction * 100
t3 = entry + direction * 200

//========================
// EXIT LOGIC
//========================
exit = (direction == 1 and (close < ema9 or close < vwap)) or (direction == -1 and (close > ema9 or close > vwap))

if exit
    direction := 0
    entry := na

//========================
// VISUALS
//========================
bgcolor(direction == 1 ? color.new(color.green, 88) : na)
bgcolor(direction == -1 ? color.new(color.red, 88) : na)

plot(vwap, color=color.yellow, linewidth=2)
plot(ema9, color=color.green)
plot(ema21, color=color.red)

plot(direction != 0 ? t1 : na, color=color.blue)
plot(direction != 0 ? t2 : na, color=color.blue)
plot(direction != 0 ? t3 : na, color=color.blue)

//========================
// SIGNALS
//========================
plotshape(buy, location=location.belowbar, style=shape.labelup, text="BUY", color=color.green)
plotshape(sell, location=location.abovebar, style=shape.labeldown, text="SELL", color=color.red)
plotshape(exit, location=location.abovebar, style=shape.circle, text="EXIT", color=color.orange)

//========================
// ALERTS
//========================
alertcondition(buy, title="BUY", message="BUY SIGNAL")
alertcondition(sell, title="SELL", message="SELL SIGNAL")
alertcondition(exit, title="EXIT", message="EXIT SIGNAL")
````

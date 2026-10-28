# Pressure Signals

- url: https://www.tradingview.com/script/4vhmeVIO-Pressure-Signals/
- type: indicator
- pine_id: PUB;773974595fe0448d9a3bba8d602b252b
- version: 1.0

## Description

How it works — it combines 4 pressure sources into a 0–100 buy score:

Volume delta (40%) — buy vs sell volume
Order book imbalance (30%) — bid depth vs ask depth
Price momentum (15%) — recent % change
RSI (15%) — overbought/oversold context

Signal rules:

BUY when buy score ≥ 65, RSI < 70, and volume delta positive
SELL when sell score ≥ 65, RSI > 30, and volume delta negative
HOLD otherwise

It also outputs suggested stop loss (2%) and take profit (4%) levels, plus reasoning for each signal.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © humbertopng
//@version=6
indicator("Pressure Signals", shorttitle="PRESSURE", overlay=true)
plot(close)

rsiLen          = input.int(14, "RSI Length", minval=2)
rsiOB           = input.int(70, "RSI Overbought")
rsiOS           = input.int(30, "RSI Oversold")
emaFastLen      = input.int(9, "EMA Fast")
emaSlowLen      = input.int(21, "EMA Slow")
pressureEnabled = input.bool(true, "Enable Pressure Filter")
buyThreshold    = input.float(60.0, "Buy Threshold", minval=0, maxval=100)
sellThreshold   = input.float(60.0, "Sell Threshold", minval=0, maxval=100)
volLookback     = input.int(10, "Volume Lookback", minval=2)

rsiVal  = ta.rsi(close, rsiLen)
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

isGreen    = close >= open
buyVol     = isGreen ? volume : 0.0
sellVol    = isGreen ? 0.0 : volume
sumBuyVol  = math.sum(buyVol, volLookback)
sumSellVol = math.sum(sellVol, volLookback)
totalVol   = sumBuyVol + sumSellVol
volRatio   = totalVol > 0 ? (sumBuyVol / totalVol) * 100 : 50.0

range1         = high - low
lowerWick      = math.min(close, open) - low
lowerWickRatio = range1 > 0 ? (lowerWick / range1) * 100 : 50.0
wickBuyScore   = ta.sma(lowerWickRatio, volLookback)

momentumPct   = (close - close[volLookback]) / close[volLookback] * 100
momentumScore = math.max(0.0, math.min(100.0, (momentumPct + 5.0) * 10.0))
rsiBuyComp    = 100.0 - rsiVal

buyScore  = volRatio * 0.40 + wickBuyScore * 0.20 + momentumScore * 0.20 + rsiBuyComp * 0.20
sellScore = 100.0 - buyScore

confirmLong  = buyScore  >= buyThreshold
confirmShort = sellScore >= sellThreshold

bullishCross = ta.crossover(emaFast, emaSlow)
bearishCross = ta.crossunder(emaFast, emaSlow)
rawBuy       = bullishCross and rsiVal < rsiOB
rawSell      = bearishCross and rsiVal > rsiOS
buySignal    = rawBuy  and (not pressureEnabled or confirmLong)
sellSignal   = rawSell and (not pressureEnabled or confirmShort)

plot(emaFast, "EMA Fast", color=color.aqua)
plot(emaSlow, "EMA Slow", color=color.orange)

plotshape(buySignal,  title="BUY",  location=location.belowbar, style=shape.labelup,   color=color.green, textcolor=color.white, text="BUY")
plotshape(sellSignal, title="SELL", location=location.abovebar, style=shape.labeldown, color=color.red,   textcolor=color.white, text="SELL")

bgcolor(buyScore  >= buyThreshold  ? color.new(color.green, 92) : na)
bgcolor(sellScore >= sellThreshold ? color.new(color.red, 92)   : na)

var table dash = table.new(position.top_right, 2, 5, bgcolor=color.new(color.black, 20))
if barstate.islast
    table.cell(dash, 0, 0, "Buy Score",  text_color=color.silver)
    table.cell(dash, 1, 0, str.tostring(buyScore, "#.0"),  text_color=color.lime)
    table.cell(dash, 0, 1, "Sell Score", text_color=color.silver)
    table.cell(dash, 1, 1, str.tostring(sellScore, "#.0"), text_color=color.red)
    table.cell(dash, 0, 2, "RSI",        text_color=color.silver)
    table.cell(dash, 1, 2, str.tostring(rsiVal, "#.0"),    text_color=color.white)
    table.cell(dash, 0, 3, "Trend",      text_color=color.silver)
    table.cell(dash, 1, 3, emaFast > emaSlow ? "UP" : "DOWN", text_color=emaFast > emaSlow ? color.lime : color.red)
    table.cell(dash, 0, 4, "Filter",     text_color=color.silver)
    table.cell(dash, 1, 4, pressureEnabled ? "ON" : "OFF", text_color=color.aqua)

alertcondition(buySignal,  title="BUY Signal",  message="BUY signal confirmed")
alertcondition(sellSignal, title="SELL Signal", message="SELL signal confirmed")
````

# Market Wave PRO ELITE + TRADE PANEL

- url: https://www.tradingview.com/script/SpCYkiPe/
- type: indicator
- pine_id: PUB;17314c378c224ad9b79827fe58449098
- version: 1.0

## Description

Scalping 1-5M. Very carfully. TREND SHORT TREND LONG. LONG - Trading. SHORT - Scalping
UPGRADE with TRADE PANEL

## Source Code

````pine
//@version=6
indicator("Market Wave PRO ELITE + TRADE PANEL", overlay=true)

// === INPUTS ===
hmaLen = input.int(55)
emaLen = input.int(200)
htf = input.timeframe("5")

wtChLen = input.int(10)
wtAvgLen = input.int(14)

bbLen = input.int(20)
bbMult = input.float(2.0)

// === TREND ===
hma = ta.hma(close, hmaLen)
ema = ta.ema(close, emaLen)
htfEMA = request.security(syminfo.tickerid, htf, ta.ema(close, emaLen))

trendUp = close > ema and close > htfEMA
trendDown = close < ema

plot(hma, color=color.yellow, linewidth=2)
plot(ema, color=color.blue, linewidth=2)

// === WAVETREND ===
ap = hlc3
esa = ta.ema(ap, wtChLen)
d = ta.ema(math.abs(ap - esa), wtChLen)
ci = (ap - esa) / (0.015 * d)
wt1 = ta.ema(ci, wtAvgLen)
wt2 = ta.sma(wt1, 4)

bull = wt1 > wt2
bear = wt1 < wt2

// === RSI + ADX ===
rsi = ta.rsi(close, 14)
[diplus, diminus, adx] = ta.dmi(14, 14)

// === BOLLINGER ===
basis = ta.sma(close, bbLen)
dev = bbMult * ta.stdev(close, bbLen)
upper = basis + dev
lower = basis - dev

plot(upper, color=color.new(color.gray, 70))
plot(lower, color=color.new(color.gray, 70))

// === VOLATILITY ===
volatility = upper - lower
highVol = volatility > ta.sma(volatility, 30)

// === SCORE ===
score = 0
score += trendUp ? 1 : trendDown ? -1 : 0
score += bull ? 1 : -1
score += rsi > 50 ? 1 : -1
score += adx > 20 ? 1 : 0

// === SYGNAŁY ===
longSignal = ta.crossover(wt1, wt2) and trendUp and rsi > 50 and highVol
shortSignal = ta.crossunder(wt1, wt2) and trendDown and rsi < 50 and highVol

longA = longSignal and score >= 2
shortA = shortSignal and score <= -2

plotshape(longA, location=location.belowbar, color=color.lime, style=shape.labelup, text="A+ LONG")
plotshape(shortA, location=location.abovebar, color=color.red, style=shape.labeldown, text="A+ SHORT")

// === BAR COLORS ===
barcolor(bull ? color.lime : bear ? color.red : na)

// === BACKGROUND ===
bgcolor(trendUp ? color.new(color.green, 92) : trendDown ? color.new(color.red, 92) : na)

// =======================
// 📊 DASHBOARD + TRADE PANEL
// =======================
var table dash = table.new(position.top_right, 1, 8)

tradeStatus = "WAIT"
tradeColor = color.orange

if adx < 15
    tradeStatus := "NO TRADE ❌"
    tradeColor := color.red
else if trendUp and rsi > 50
    tradeStatus := "LONG 🟢"
    tradeColor := color.green
else if trendDown and rsi < 50
    tradeStatus := "SHORT 🔴"
    tradeColor := color.red

if barstate.islast
    table.cell(dash, 0, 0, "📊 MARKET CORE", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 0, 1, "Trend: " + (trendUp ? "UP" : trendDown ? "DOWN" : "SIDE"))
    table.cell(dash, 0, 2, "Momentum: " + (bull ? "BULL" : "BEAR"))
    table.cell(dash, 0, 3, "RSI: " + str.tostring(rsi, "#.0"))
    table.cell(dash, 0, 4, "ADX: " + str.tostring(adx, "#.0"))
    table.cell(dash, 0, 5, "Score: " + str.tostring(score))
    table.cell(dash, 0, 6, "-------------")
    table.cell(dash, 0, 7, tradeStatus, text_color=color.white, bgcolor=tradeColor)
````

# Keith Sniper ELITE

- url: https://www.tradingview.com/script/uF1DpgLa-Keith-Sniper-ELITE/
- type: indicator
- pine_id: PUB;3c212c45eb044ed9b940572dc9874500
- version: 1.0

## Description

Thank me later, This is a sniper elite indicator add it to your chart and watch it all of a sudden click in your brain.

## Source Code

````pine
//@version=5
indicator("Keith Sniper ELITE", overlay=true)

// =========================
// INPUTS
// =========================
useVWAP = input.bool(true, "Use VWAP Filter")
useVIX  = input.bool(true, "Use VIX Filter")
useMTF  = input.bool(true, "Use MTF Confirmation")

// =========================
// EMA LOGIC
// =========================
emaFast = ta.ema(close, 3)
emaSlow = ta.ema(close, 9)
emaTrend = ta.ema(close, 21)

bullCross = ta.crossover(emaFast, emaSlow)
bearCross = ta.crossunder(emaFast, emaSlow)

bullTrend = close > emaTrend
bearTrend = close < emaTrend

// =========================
// RMI (Momentum)
// =========================
rmi = ta.rsi(close, 14)
oversold = rmi < 30
overbought = rmi > 70

// =========================
// VWAP FILTER
// =========================
vwap = ta.vwap(close)
nearVWAP = math.abs(close - vwap) < 0.5

// =========================
// VIX FILTER
// =========================
vix = request.security("CBOE:VIX", timeframe.period, close)
vixUp = vix > ta.sma(vix, 10)
vixDown = vix < ta.sma(vix, 10)

// =========================
// MTF CONFIRMATION (15m)
// =========================
mtfBull = request.security(syminfo.tickerid, "15", ta.crossover(ta.ema(close,3), ta.ema(close,9)))
mtfBear = request.security(syminfo.tickerid, "15", ta.crossunder(ta.ema(close,3), ta.ema(close,9)))

// =========================
// TREND STRENGTH FILTER
// =========================
trendStrength = ta.atr(14) / close
isTrending = trendStrength > 0.01

// =========================
// TRAP DETECTION
// =========================
fakeShort = bearCross and bullTrend
fakeLong  = bullCross and bearTrend

// =========================
// FINAL CONDITIONS (CLEAN SINGLE LINE)
// =========================
longCond  = bullCross and oversold and bullTrend and (not useVWAP or nearVWAP) and (not useVIX or vixDown) and (not useMTF or mtfBull) and not fakeLong and isTrending
shortCond = bearCross and overbought and bearTrend and (not useVWAP or nearVWAP) and (not useVIX or vixUp) and (not useMTF or mtfBear) and not fakeShort and isTrending

// =========================
// SIGNALS
// =========================
plotshape(longCond,  title="LONG",  location=location.belowbar, color=color.green, style=shape.labelup, text="LONG")
plotshape(shortCond, title="SHORT", location=location.abovebar, color=color.red,   style=shape.labeldown, text="SHORT")

// =========================
// VISUALS
// =========================
plot(emaFast, color=color.green, title="EMA 3")
plot(emaSlow, color=color.orange, title="EMA 9")
plot(emaTrend, color=color.white, title="EMA 21")
plot(vwap, color=color.blue, title="VWAP")

bgcolor(longCond ? color.new(color.green, 90) : na)
bgcolor(shortCond ? color.new(color.red, 90) : na)
````

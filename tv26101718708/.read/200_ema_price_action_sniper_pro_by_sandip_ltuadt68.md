# 200 EMA Price Action Sniper PRO by sandip

- url: https://www.tradingview.com/script/LtuAdT68-200-EMA-Price-Action-Sniper-PRO-by-sandip/
- type: indicator
- pine_id: PUB;a3196a4d459f443bb70cfefaead982ed
- version: 1.0

## Description

200 EMA = trend direction
Fast EMA cross = entry trigger
Price Action = confirmation
Chop filter = avoid fake signals
VWAP = institutional bias

## Source Code

````pine
//@version=6
indicator("200 EMA Price Action Sniper PRO", overlay=true, max_labels_count=500)

// ======================================================
// INPUTS
// ======================================================

fastEMA     = input.int(20, "Fast EMA")
slowEMA     = input.int(50, "Slow EMA")
trendEMA    = input.int(200, "200 EMA")

useVWAP        = input.bool(true, "Use VWAP Filter")
useATRFilter   = input.bool(true, "Use ATR Filter")
useADXFilter   = input.bool(true, "Use ADX Filter")
useChopFilter  = input.bool(true, "Use Chop Filter")

adxLen = input.int(14, "ADX Length")
adxMin = input.int(20, "Minimum ADX")

atrLen = input.int(14, "ATR Length")

// ======================================================
// EMA
// ======================================================

emaFast = ta.ema(close, fastEMA)
emaSlow = ta.ema(close, slowEMA)
ema200  = ta.ema(close, trendEMA)

vwapValue = ta.vwap(close)

// ======================================================
// ATR
// ======================================================

atr = ta.atr(atrLen)
atrMA = ta.sma(atr, atrLen)

atrFilter = atr > atrMA

// ======================================================
// ADX
// ======================================================

upMove = high - high[1]
downMove = low[1] - low

plusDM = (upMove > downMove and upMove > 0) ? upMove : 0
minusDM = (downMove > upMove and downMove > 0) ? downMove : 0

trur = ta.rma(ta.tr(true), adxLen)

plusDI = 100 * ta.rma(plusDM, adxLen) / trur
minusDI = 100 * ta.rma(minusDM, adxLen) / trur

dx = 100 * math.abs(plusDI - minusDI) / (plusDI + minusDI)
adx = ta.rma(dx, adxLen)

adxFilter = adx > adxMin

// ======================================================
// CHOP FILTER
// ======================================================

emaDistance = math.abs(emaFast - emaSlow)
isChoppy = emaDistance < atr * 0.25

// ======================================================
// TREND
// ======================================================

bullTrend = close > ema200 and ema200 > ema200[1]
bearTrend = close < ema200 and ema200 < ema200[1]

// ======================================================
// PRICE ACTION
// ======================================================

bullEngulf =
 close > open and
 close[1] < open[1] and
 close > open[1] and
 open < close[1]

bearEngulf =
 close < open and
 close[1] > open[1] and
 close < open[1] and
 open > close[1]

// ======================================================
// CROSS
// ======================================================

bullCross = ta.crossover(emaFast, emaSlow)
bearCross = ta.crossunder(emaFast, emaSlow)

// ======================================================
// VWAP
// ======================================================

vwapBull = close > vwapValue
vwapBear = close < vwapValue

// ======================================================
// BUY & SELL
// ======================================================

buyCondition =
 bullTrend and
 bullCross and
 bullEngulf and
 (not useVWAP or vwapBull) and
 (not useATRFilter or atrFilter) and
 (not useADXFilter or adxFilter) and
 (not useChopFilter or not isChoppy)

sellCondition =
 bearTrend and
 bearCross and
 bearEngulf and
 (not useVWAP or vwapBear) and
 (not useATRFilter or atrFilter) and
 (not useADXFilter or adxFilter) and
 (not useChopFilter or not isChoppy)

// ======================================================
// PLOTS
// ======================================================

plot(emaFast, color=color.lime, linewidth=2, title="Fast EMA")
plot(emaSlow, color=color.red, linewidth=2, title="Slow EMA")
plot(ema200, color=color.white, linewidth=3, title="200 EMA")

plot(vwapValue, color=color.orange, linewidth=2, title="VWAP")

// ======================================================
// BACKGROUND
// ======================================================

bgcolor(
 bullTrend ? color.new(color.green, 92) :
 bearTrend ? color.new(color.red, 92) :
 na
)

// ======================================================
// SIGNALS
// ======================================================

plotshape(
 buyCondition,
 title="BUY",
 location=location.belowbar,
 color=color.lime,
 style=shape.labelup,
 text="BUY",
 size=size.small
)

plotshape(
 sellCondition,
 title="SELL",
 location=location.abovebar,
 color=color.red,
 style=shape.labeldown,
 text="SELL",
 size=size.small
)

// ======================================================
// CHOP ZONE
// ======================================================

bgcolor(
 isChoppy ? color.new(color.yellow, 88) : na
)

// ======================================================
// ALERTS
// ======================================================

alertcondition(buyCondition, title="BUY ALERT", message="BUY SIGNAL")

alertcondition(sellCondition, title="SELL ALERT", message="SELL SIGNAL")

// ======================================================
// DASHBOARD
// ======================================================

var table dash = table.new(position.top_right, 2, 6)

if barstate.islast

    table.cell(dash, 0, 0, "Trend")
    table.cell(dash, 1, 0, bullTrend ? "BULL" : bearTrend ? "BEAR" : "SIDEWAYS")

    table.cell(dash, 0, 1, "ADX")
    table.cell(dash, 1, 1, str.tostring(adx, "#.0"))

    table.cell(dash, 0, 2, "ATR")
    table.cell(dash, 1, 2, atrFilter ? "ACTIVE" : "LOW")

    table.cell(dash, 0, 3, "VWAP")
    table.cell(dash, 1, 3, close > vwapValue ? "ABOVE" : "BELOW")

    table.cell(dash, 0, 4, "CHOP")
    table.cell(dash, 1, 4, isChoppy ? "YES" : "NO")

    table.cell(dash, 0, 5, "SIGNAL")
    table.cell(
         dash,
         1,
         5,
         buyCondition ? "BUY" :
         sellCondition ? "SELL" :
         "WAIT"
     )
````

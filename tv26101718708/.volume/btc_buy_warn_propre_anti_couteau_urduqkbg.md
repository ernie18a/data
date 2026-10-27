# BTC BUY WARN propre anti couteau

- url: https://www.tradingview.com/script/urDuqKbG/
- type: indicator
- pine_id: PUB;b95a4a6f1756437597539da556c0c11e
- version: 1.0

## Description

Quand le BTC sort d'une zone de faiblesse (RSI bas), que les acheteurs reprennent la main (CVD haussier), que le prix est proche d'une zone de volume importante (POC) et que la tendance courte repart à la hausse (EMA20 > EMA50).

BUY+ = même chose + gros volume d'acheteurs (Smart Money).

WARN = gros vendeurs détectés, ou tendance qui se retourne (EMA20 < EMA50 + CVD baissier).

WAIT = tous les autres cas.

L'objectif est de capter les rebonds de 2 à 5 jours, pas les grands cycles du BTC.

## Source Code

````pine
//@version=6
indicator("BTC 1H — BUY/WARN propre anti-couteau", overlay=true, max_lines_count=20, max_labels_count=80)

// =====================
// PARAMÈTRES
// =====================
rsiLen      = input.int(14, "RSI longueur")
rsiLow      = input.float(35, "RSI zone basse")
rsiEntry    = input.float(58, "RSI max BUY")

emaFastLen  = input.int(20, "EMA rapide")
emaSlowLen  = input.int(50, "EMA lente")

volLen      = input.int(50, "Volume moyenne")
volMult     = input.float(1.4, "Smart Money volume x", step=0.1)

profileLen  = input.int(150, "POC lookback")
bins        = input.int(24, "POC zones", minval=10, maxval=50)
pocMaxDist  = input.float(2.8, "Distance max POC %", step=0.1)

cvdLen      = input.int(50, "CVD moyenne")
cooldown    = input.int(10, "Cooldown signaux", minval=1)

showTable   = input.bool(true, "Afficher tableau")

// =====================
// EMA / STRUCTURE
// =====================
ema20 = ta.ema(close, emaFastLen)
ema50 = ta.ema(close, emaSlowLen)

prevHigh = high[1]
crossEMA20 = ta.crossover(close, ema20)

trendOK = close > ema20 and ema20 > ema50
structureOK = close > prevHigh or crossEMA20

// =====================
// RSI
// =====================
rsi = ta.rsi(close, rsiLen)
rsiMA = ta.sma(rsi, 14)

rsiWasLow = ta.lowest(rsi, 18) < rsiLow
rsiRecover = rsi > rsi[1] and rsi > rsiMA
rsiEntryOK = rsi < rsiEntry and rsiWasLow and rsiRecover

// =====================
// SMART MONEY
// =====================
volMA = ta.sma(volume, volLen)
volRatio = volMA != 0 ? volume / volMA : 0
smartVol = volume > volMA * volMult

body = math.abs(close - open)
rangeBar = high - low
lowerWick = math.min(open, close) - low

bullCandle = close > open
bearCandle = close < open

smartBuy = smartVol and bullCandle and lowerWick >= body * 0.5
smartSell = smartVol and bearCandle and close < low + rangeBar * 0.55

// =====================
// CVD APPROXIMATIF
// =====================
delta = bullCandle ? volume : bearCandle ? -volume : 0
cvd = ta.cum(delta)
cvdMA = ta.sma(cvd, cvdLen)

cvdBull = cvd > cvdMA
cvdBear = cvd < cvdMA

priceLL = low < ta.lowest(low[1], 10)
cvdHL = cvd > ta.lowest(cvd[1], 10)
cvdDiv = priceLL and cvdHL and rsi < 50

// =====================
// POC SIMPLIFIÉ
// =====================
highestPrice = ta.highest(high, profileLen)
lowestPrice = ta.lowest(low, profileLen)
step = (highestPrice - lowestPrice) / bins

var float[] volBins = array.new_float(bins, 0.0)
array.clear(volBins)

for i = 0 to bins - 1
    array.push(volBins, 0.0)

for j = 0 to profileLen - 1
    price = close[j]
    idx = step != 0 ? math.floor((price - lowestPrice) / step) : 0
    idx := math.max(0, math.min(bins - 1, idx))
    array.set(volBins, idx, array.get(volBins, idx) + volume[j])

maxVol = array.max(volBins)
pocIdx = array.indexof(volBins, maxVol)
pocPrice = lowestPrice + step * pocIdx

distPOC = math.abs(close - pocPrice) / close * 100
nearPOC = distPOC <= pocMaxDist

pocFalling = pocPrice < pocPrice[5]
pocOK = not pocFalling or close > pocPrice

// =====================
// SIGNAUX
// =====================
rawBuy =
     nearPOC and
     pocOK and
     trendOK and
     structureOK and
     cvdBull and
     (
         rsiEntryOK or
         smartBuy or
         cvdDiv
     )

rawBuyPlus =
     rawBuy and
     smartBuy and
     rsi < 50

rawWarn =
     smartSell or
     (rsi > 65 and cvdBear) or
     (close < ema20 and ema20 < ema50 and cvdBear)

var int lastBuyBar = na
var int lastWarnBar = na

buyAllowed = na(lastBuyBar) or bar_index - lastBuyBar > cooldown
warnAllowed = na(lastWarnBar) or bar_index - lastWarnBar > cooldown

buy = rawBuy and buyAllowed
buyPlus = rawBuyPlus and buyAllowed
warn = rawWarn and warnAllowed

if buy
    lastBuyBar := bar_index

if warn
    lastWarnBar := bar_index

// =====================
// VISUEL
// =====================
plot(ema20, "EMA 20", color=color.orange)
plot(ema50, "EMA 50", color=color.red)
plot(pocPrice, "POC", color=color.yellow, linewidth=2)

plotshape(buyPlus, title="BUY+", style=shape.labelup, location=location.belowbar,
     color=color.green, text="BUY+", textcolor=color.white, size=size.small)

plotshape(buy and not buyPlus, title="BUY", style=shape.labelup, location=location.belowbar,
     color=color.lime, text="BUY", textcolor=color.black, size=size.tiny)

plotshape(warn, title="WARN", style=shape.labeldown, location=location.abovebar,
     color=color.red, text="WARN", textcolor=color.white, size=size.tiny)

// =====================
// TABLEAU
// =====================
var table dash = table.new(position.top_right, 2, 6, border_width=1)

if barstate.islast and showTable
    table.cell(dash, 0, 0, "RSI")
    table.cell(dash, 1, 0, str.tostring(rsi, "#.0"))

    table.cell(dash, 0, 1, "Trend")
    table.cell(dash, 1, 1, trendOK ? "OK" : "NON")

    table.cell(dash, 0, 2, "CVD")
    table.cell(dash, 1, 2, cvdBull ? "HAUSSIER" : "BAISSIER")

    table.cell(dash, 0, 3, "Dist. POC")
    table.cell(dash, 1, 3, str.tostring(distPOC, "#.00") + "%")

    table.cell(dash, 0, 4, "POC")
    table.cell(dash, 1, 4, pocFalling ? "BAISSE" : "OK")

    table.cell(dash, 0, 5, "Signal")
    table.cell(dash, 1, 5, buyPlus ? "BUY+" : buy ? "BUY" : warn ? "WARN" : "WAIT")

// =====================
// ALERTE WARN UNIQUEMENT
// =====================
alertcondition(warn,
     title="BTC WARN 1H",
     message="BTC 1H : WARN - pression vendeuse ou tendance 1H dégradée.")
````

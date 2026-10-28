# Swing Canal Haussier + VCP - Indicateur Nicolas

- url: https://www.tradingview.com/script/3BChV7y9/
- type: indicator
- pine_id: PUB;75d3b3a35b804896a2b9ee38a8fe3b37
- version: 1.0

## Description

- Marché global haussier
- Canal haussier valide (Pentes parallèles , écart entre les pentes < 10% ou 15%, prix proche du bas du canal si distance < 1% ou < 0,5 ATR)
- Prix proche bande basse
- RSI > 40 - Volume décroissant et faible pendant correction
- ATR diminue - Volume - 4h et daily

## Source Code

````pine
//@version=6
indicator("Swing Canal Haussier + VCP - Indicateur Nicolas", overlay=true, max_lines_count=100, max_labels_count=100, max_boxes_count=20)

// ==========================
// PARAMÈTRES
// ==========================

// Canal
pivotLen        = input.int(5, "Sensibilité pivots canal", minval=2, maxval=20)
slopeTolerance  = input.float(15.0, "Tolérance pentes parallèles (%)", minval=1, maxval=50)
distancePct     = input.float(1.0, "Distance max bande basse (%)", minval=0.1, maxval=5)
distanceAtrMult = input.float(0.5, "Distance max bande basse en ATR", minval=0.1, maxval=3)

// RSI
rsiLen = input.int(14, "RSI longueur")
rsiMin = input.float(40, "RSI minimum")
rsiMax = input.float(60, "RSI maximum")

// Volume
volShortLen = input.int(5, "Volume court terme")
volLongLen  = input.int(20, "Volume long terme")

// ATR
atrLen       = input.int(14, "ATR longueur")
atrSmoothLen = input.int(20, "ATR moyenne")

// Compression ranges
rangeLen = input.int(5, "Contraction range court terme")

// Marché / force relative
rsSymbol     = input.symbol("SPY", "Indice force relative")
marketSymbol = input.symbol("SPY", "Indice marché global")
marketMaLen  = input.int(200, "MM marché global")

// Score
scoreMin = input.int(75, "Score minimum signal", minval=0, maxval=100)

// Filtre earnings manuel
useEarningsFilter = input.bool(false, "Activer filtre earnings manuel")
nextEarningsDate  = input.time(timestamp("2026-12-31T00:00:00"), "Prochaine date earnings")
earningsDaysMin   = input.int(5, "Éviter si earnings dans moins de X jours")

// Affichage
showChannel = input.bool(true, "Afficher canal")
showBuyZone = input.bool(true, "Afficher zone achat")
showTable   = input.bool(true, "Afficher score")

// ==========================
// MARCHÉ GLOBAL HAUSSIER
// ==========================

marketClose = request.security(marketSymbol, timeframe.period, close)
marketMA    = request.security(marketSymbol, timeframe.period, ta.sma(close, marketMaLen))
marketBull  = marketClose > marketMA

// ==========================
// CANAL PAR PIVOTS
// ==========================

pivotLow  = ta.pivotlow(low, pivotLen, pivotLen)
pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)

var float low1 = na
var float low2 = na
var int lowBar1 = na
var int lowBar2 = na

var float high1 = na
var float high2 = na
var int highBar1 = na
var int highBar2 = na

if not na(pivotLow)
    low1 := low2
    lowBar1 := lowBar2
    low2 := pivotLow
    lowBar2 := bar_index - pivotLen

if not na(pivotHigh)
    high1 := high2
    highBar1 := highBar2
    high2 := pivotHigh
    highBar2 := bar_index - pivotLen

hasLowLine  = not na(low1) and not na(low2) and lowBar2 != lowBar1
hasHighLine = not na(high1) and not na(high2) and highBar2 != highBar1

slopeLow  = hasLowLine ? (low2 - low1) / (lowBar2 - lowBar1) : na
slopeHigh = hasHighLine ? (high2 - high1) / (highBar2 - highBar1) : na

parallelOk = hasLowLine and hasHighLine and slopeLow > 0 and slopeHigh > 0 and math.abs(slopeLow - slopeHigh) / math.abs(slopeLow) <= slopeTolerance / 100

lowerChannel = hasLowLine ? low2 + slopeLow * (bar_index - lowBar2) : na
upperChannel = hasHighLine ? high2 + slopeHigh * (bar_index - highBar2) : na

channelValid = parallelOk and lowerChannel < upperChannel

// ==========================
// PROXIMITÉ BAS DE CANAL
// ==========================

atr = ta.atr(atrLen)

distanceToLower = channelValid ? math.abs(close - lowerChannel) : na
nearLowerPct = channelValid ? distanceToLower / close * 100 <= distancePct : false
nearLowerAtr = channelValid ? distanceToLower <= atr * distanceAtrMult : false

nearLowerBand = nearLowerPct or nearLowerAtr

// ==========================
// RSI
// ==========================

rsi = ta.rsi(close, rsiLen)
rsiOk = rsi > rsiMin and rsi < rsiMax

// ==========================
// VOLUME
// ==========================

volShort = ta.sma(volume, volShortLen)
volLong  = ta.sma(volume, volLongLen)

volumeWeak = volShort < volLong
volumeDecreasing = volume < volume[1] or volShort < volShort[1]
volumeOk = volumeWeak and volumeDecreasing

// ==========================
// ATR DIMINUE
// ==========================

atrMA = ta.sma(atr, atrSmoothLen)
atrDecreasing = atr < atrMA and atr < atr[1]

// ==========================
// RANGES SE CONTRACTENT
// ==========================

barRange = high - low
rangeShort = ta.sma(barRange, rangeLen)
rangeLong  = ta.sma(barRange, rangeLen * 3)

rangeContracting = rangeShort < rangeLong and barRange < barRange[1]

// ==========================
// FORCE RELATIVE
// ==========================

rsClose = request.security(rsSymbol, timeframe.period, close)
relativeStrength = close / rsClose
rsMA = ta.sma(relativeStrength, 20)

rsStrong = relativeStrength > rsMA and rsMA > rsMA[5]

// ==========================
// BOUGIE DE REBOND
// ==========================

bullishRebound = close > open and close > high[1]

// ==========================
// FILTRE EARNINGS MANUEL
// ==========================

daysToEarnings = (nextEarningsDate - time) / 86400000
earningsOk = not useEarningsFilter or daysToEarnings > earningsDaysMin or daysToEarnings < 0

// ==========================
// SCORE QUALITÉ
// ==========================

score = 0
score += marketBull       ? 15 : 0
score += channelValid     ? 20 : 0
score += nearLowerBand    ? 15 : 0
score += rsiOk            ? 10 : 0
score += volumeWeak       ? 10 : 0
score += volumeDecreasing ? 5  : 0
score += atrDecreasing    ? 10 : 0
score += rangeContracting ? 10 : 0
score += rsStrong         ? 15 : 0

scoreFinal = math.min(score, 100)

// ==========================
// SIGNAL FINAL
// ==========================

buySignal = scoreFinal >= scoreMin and marketBull and channelValid and nearLowerBand and rsiOk and volumeOk and atrDecreasing and rsStrong and bullishRebound and earningsOk

// ==========================
// AFFICHAGE
// ==========================

plot(showChannel and channelValid ? lowerChannel : na, "Bas canal", color=color.green, linewidth=2)
plot(showChannel and channelValid ? upperChannel : na, "Haut canal", color=color.green, linewidth=2)

buyZoneLow  = showBuyZone and channelValid ? lowerChannel : na
buyZoneHigh = showBuyZone and channelValid ? lowerChannel + atr * distanceAtrMult : na

p1 = plot(buyZoneLow, "Zone achat basse", color=color.new(color.green, 80))
p2 = plot(buyZoneHigh, "Zone achat haute", color=color.new(color.green, 80))
fill(p1, p2, color=color.new(color.green, 88))

plotshape(buySignal, title="Signal achat", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.large, text="BUY")

// ==========================
// TABLEAU SCORE
// ==========================

var table scoreTable = table.new(position.top_right, 1, 9)

if barstate.islast and showTable
    table.cell(scoreTable, 0, 0, "Score : " + str.tostring(scoreFinal) + "/100")
    table.cell(scoreTable, 0, 1, "Marché haussier : " + str.tostring(marketBull))
    table.cell(scoreTable, 0, 2, "Canal valide : " + str.tostring(channelValid))
    table.cell(scoreTable, 0, 3, "Proche bas canal : " + str.tostring(nearLowerBand))
    table.cell(scoreTable, 0, 4, "RSI OK : " + str.tostring(rsiOk))
    table.cell(scoreTable, 0, 5, "Volume OK : " + str.tostring(volumeOk))
    table.cell(scoreTable, 0, 6, "ATR diminue : " + str.tostring(atrDecreasing))
    table.cell(scoreTable, 0, 7, "Force relative : " + str.tostring(rsStrong))
    table.cell(scoreTable, 0, 8, "Earnings OK : " + str.tostring(earningsOk))

// ==========================
// ALERTE
// ==========================

alertcondition(buySignal, title="Signal achat - Canal haussier VCP", message="Signal achat détecté sur {{ticker}} | Timeframe: {{interval}} | Setup canal haussier + compression + force relative")
````

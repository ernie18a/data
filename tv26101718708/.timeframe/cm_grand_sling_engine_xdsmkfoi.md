# CM Grand Sling Engine

- url: https://www.tradingview.com/script/xdSMKFOI/
- type: indicator
- pine_id: PUB;91d5b3732e054726b1af4f6f38823389
- version: 1.0

## Description

**CM Grand Sling Engine**

CM Grand Sling Engine is a clean trend-following overlay designed to keep the chart readable while focusing on the dominant market direction.

The system uses a dual expanding rail structure based on two different lookback lengths: a fast rail and a slow rail. These rails are not standard moving averages. They are adaptive trend rails built from the indicator’s own calculation engine, combining price structure, volatility, multi-timeframe strength, momentum, flow behavior, PI energy logic, and internal market pressure.

When the fast rail stays above the slow rail, the system identifies a bullish trend environment. When the fast rail moves below the slow rail, the system identifies a bearish trend environment. The colored area between the rails helps traders visually understand the current trend regime without adding unnecessary chart noise.

The candle coloring is designed to separate normal trend movement from possible pullback and re-entry zones:

Yellow candles highlight aggressive pullback areas inside the active trend.
Aqua candles highlight conservative re-entry confirmation after price returns back in the trend direction.
Green rail structure represents bullish trend control.
Red rail structure represents bearish trend control.

CM Grand Sling Engine is built more for trend direction, pullback reading, and market structure clarity than for crowded buy/sell signals. The goal is to provide a cleaner view of trend continuation, weakness, and possible re-entry zones directly on the chart.

It can be useful on liquid markets and higher-volume instruments where trend behavior is clearer. As with any technical tool, it should be used together with risk management and broader market context.

## Source Code

````pine
//@version=6
indicator("OMEGA BIG PICTURE • SLING RAIL 38/62 FIX", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=100, max_bars_back=500)

//━━━━━━━━━━━━━━━━ LANGUAGE
lang = input.string("EN", "Language", options=["EN","TR","DE","ES","FR","RU","AR"])

txt(en, tr, de, es, fr, ru, ar) =>
    string out = en
    if lang == "TR"
        out := tr
    else if lang == "DE"
        out := de
    else if lang == "ES"
        out := es
    else if lang == "FR"
        out := fr
    else if lang == "RU"
        out := ru
    else if lang == "AR"
        out := ar
    out

//━━━━━━━━━━━━━━━━ INPUTS
tf1 = input.timeframe("15", "Fast TF")
tf2 = input.timeframe("60", "Mid TF")
tf3 = input.timeframe("240", "Macro TF")

trendLen  = input.int(55, "Organ Trend EMA")
momLen    = input.int(10, "Organ Momentum")
zLen      = input.int(34, "Z Lookback")
smoothLen = input.int(8, "Organ Smooth")

matcPct    = input.float(2.0, "MATC Band %", step=0.1)
matcSmooth = input.int(5, "MATC Smooth")
matcMirror = input.float(1.3, "MATC Mirror", step=0.1)

atrLen  = input.int(14, "ATR Length")
atrMult = input.float(2.4, "Trend Line Power", step=0.1)

fastLen = input.int(38, "Fast Sling Rail Length", minval=1)
slowLen = input.int(62, "Slow Sling Rail Length", minval=1)

coreLen        = input.int(21, "Core Length")
bullQualityPct = input.float(72.0, "Bull Quality %")
bearQualityPct = input.float(28.0, "Bear Quality %")
persistLen     = input.int(200, "Persistence Lookback")

piObvLen   = input.int(14, "PI OBV ROC Length")
piScaleLen = input.int(100, "PI Normalize Length")
piSmooth   = input.int(9, "PI Smooth")
piTrendLen = input.int(200, "PI Energy EMA")

mergeLen   = input.int(5, "Flow Merge Candles")
flowLen    = input.int(20, "Flow Trend Length")
flowSmooth = input.int(10, "Flow Smooth")
flowSrLen  = input.int(25, "Flow S/R Length")

pivotLen = input.int(5, "XABCD Pivot Length")
fibTol   = input.float(0.25, "Soft Fib Tolerance", step=0.01)

useVertex = input.bool(true, "Use Vertex Engine")
vertexLen = input.int(14, "Vertex Length")
rows      = input.int(12, "Tetris Rows", minval=5, maxval=20)

useO5D       = input.bool(true, "Use 5D Box Motor 30%")
o5dBlockTf   = input.timeframe("5D", "5D Block TF")
o5dSmoothLen = input.int(14, "5D Flow Smooth")
o5dSignalLen = input.int(9, "5D Signal Smooth")
o5dAtrLen    = input.int(14, "5D Sqrt ATR Length")
o5dNormLen   = input.int(100, "5D Normalize Length")
o5dMomLen    = input.int(5, "5D Momentum Length")
o5dVolLen    = input.int(20, "5D Relative Volume Length")

o5dVolWeight   = input.float(40.0, "5D Relative Volume Weight")
o5dDeltaWeight = input.float(25.0, "5D Sqrt Delta Weight")
o5dMomWeight   = input.float(15.0, "5D Momentum Weight")
o5dTopZone     = input.float(75.0, "5D Top Fade Zone")
o5dBuyMaxZone  = input.float(65.0, "5D Buy Max Zone")
o5dClusterBars = input.int(7, "5D Box Window Bars", minval=2)

showAggressive   = input.bool(true, "Show Aggressive Pullback Candle")
showConservative = input.bool(true, "Show Conservative Entry Candle")
showTrendMarks   = input.bool(false, "Show Trend Top/Bottom Triangles")
showEntryLabels  = input.bool(true, "Show Clean B/S Labels")
showAura         = input.bool(true, "Premium Aura")
showBars         = input.bool(true, "Candle Color")
showPanel        = input.bool(true, "Main Panel")
showGrid         = input.bool(true, "Tetris Grid")
showSlowRail     = input.bool(true, "Show Slow 62 Rail")

bullC  = input.color(color.lime, "Bull Color")
bearC  = input.color(color.red, "Bear Color")
midC   = input.color(color.gray, "Neutral Color")
goldC  = input.color(color.yellow, "Pullback Color")
entryC = input.color(color.aqua, "Entry Candle Color")

//━━━━━━━━━━━━━━━━ HELPERS
clamp(x, lo, hi) =>
    math.max(math.min(x, hi), lo)

z(src, l) =>
    m = ta.sma(src, l)
    d = ta.stdev(src, l)
    d != 0 ? (src - m) / d : 0.0

norm01(src, l) =>
    hi = ta.highest(src, l)
    lo = ta.lowest(src, l)
    hi != lo ? (src - lo) / (hi - lo) : 0.5

toPct(score) =>
    clamp(score * 5.0 + 50.0, 0.0, 100.0)

safe(v) =>
    math.abs(v) < 0.0000001 ? 0.0000001 : v

near(v, target, tol) =>
    math.abs(v - target) <= tol

inZone(v, lo, hi, tol) =>
    v >= lo - tol and v <= hi + tol

//━━━━━━━━━━━━━━━━ MTF LIGHT SCORE
f_light_score() =>
    a = ta.atr(atrLen)
    e = ta.ema(close, trendLen)
    tr = e - e[1]
    mo = ta.roc(close, momLen)
    ob = ta.cum(close > close[1] ? volume : close < close[1] ? -volume : 0)
    obRaw = ob - ob[1]
    prDir = close > ta.ema(close, 20) ? 1.0 : -1.0
    atrRaw = (a - a[1]) * prDir
    organRawF = z(tr, zLen) * 2.0 + z(mo, zLen) * 1.5 + z(obRaw, zLen) + z(atrRaw, zLen) * 0.5
    organPctF = clamp(ta.ema(organRawF, smoothLen) / 6.0 * 50.0 + 50.0, 0.0, 100.0)
    src = hl2
    up = src * (1.0 + matcPct / 100.0)
    lo = src * (1.0 - matcPct / 100.0)
    md = (up + lo) / 2.0
    ds = (up - lo) / 2.0
    res = ta.ema(md + ds * matcMirror, matcSmooth)
    sup = ta.ema(md - ds * matcMirror, matcSmooth)
    matcPctNow = clamp((close - (res + sup) / 2.0) / math.max(res - sup, syminfo.mintick) * 50.0 + 50.0, 0.0, 100.0)
    ribbon = ta.ema(close, 21) > ta.ema(close, 55) ? 65.0 : ta.ema(close, 21) < ta.ema(close, 55) ? 35.0 : 50.0
    rsiP = ta.rsi(close, 14)
    obvRocF = ta.roc(ob, piObvLen)
    obvRootF = obvRocF >= 0 ? math.sqrt(math.abs(obvRocF)) : -math.sqrt(math.abs(obvRocF))
    piRawF = math.pi * math.pow(a, 2) * obvRootF
    piEnergyF = ta.ema(norm01(piRawF, piScaleLen) * 100.0, piSmooth)
    piTrendF = ta.ema(piEnergyF, piTrendLen)
    piPctF = piEnergyF > piTrendF ? 65.0 + clamp(piEnergyF - piTrendF, 0, 25) : 35.0 - clamp(piTrendF - piEnergyF, 0, 25)
    organPctF * 0.25 + matcPctNow * 0.20 + ribbon * 0.15 + rsiP * 0.10 + clamp(piPctF, 0, 100) * 0.30

//━━━━━━━━━━━━━━━━ MAIN CORE
atr = ta.atr(atrLen)

emaTrend = ta.ema(close, trendLen)
trendRaw = emaTrend - emaTrend[1]
momRaw = ta.roc(close, momLen)

obvLocal = ta.cum(close > close[1] ? volume : close < close[1] ? -volume : 0)
obvRaw = obvLocal - obvLocal[1]

priceDir = close > ta.ema(close, 20) ? 1.0 : -1.0
atrRaw = (atr - atr[1]) * priceDir

organRaw = z(trendRaw, zLen) * 2.0 + z(momRaw, zLen) * 1.5 + z(obvRaw, zLen) + z(atrRaw, zLen) * 0.5
organScore = clamp(ta.ema(organRaw, smoothLen) / 6.0 * 10.0, -10.0, 10.0)

srcMatc = hl2
upperMatc = srcMatc * (1.0 + matcPct / 100.0)
lowerMatc = srcMatc * (1.0 - matcPct / 100.0)
midMatc = (upperMatc + lowerMatc) / 2.0
distMatc = (upperMatc - lowerMatc) / 2.0
resistMatc = ta.ema(midMatc + distMatc * matcMirror, matcSmooth)
supportMatc = ta.ema(midMatc - distMatc * matcMirror, matcSmooth)
matcMid = (resistMatc + supportMatc) / 2.0
matcRange = math.max(resistMatc - supportMatc, syminfo.mintick)
matcScore = clamp(((close - matcMid) / matcRange) * 10.0, -10.0, 10.0)

emaFastBase = ta.ema(close, 21)
emaSlowBase = ta.ema(close, 55)
ribbonScore = emaFastBase > emaSlowBase ? 4.0 : emaFastBase < emaSlowBase ? -4.0 : 0.0

rsiVal = ta.rsi(close, 14)
rsiScore = clamp((rsiVal - 50.0) / 5.0, -10.0, 10.0)

//━━━━━━━━━━━━━━━━ PI ENERGY
obvRoc = ta.roc(obvLocal, piObvLen)
obvRoot = obvRoc >= 0 ? math.sqrt(math.abs(obvRoc)) : -math.sqrt(math.abs(obvRoc))
rawEnergy = math.pi * math.pow(atr, 2) * obvRoot
piEnergy = ta.ema(norm01(rawEnergy, piScaleLen) * 100.0, piSmooth)
piTrend = ta.ema(piEnergy, piTrendLen)
piScore = clamp((piEnergy - piTrend) / 5.0, -10.0, 10.0)

//━━━━━━━━━━━━━━━━ FLOW
mOpen = open[mergeLen - 1]
mClose = close

float mVol = 0.0
for i = 0 to mergeLen - 1
    mVol += volume[i]

flowDelta = mClose > mOpen ? mVol : mClose < mOpen ? -mVol : 0.0
deltaEma = ta.ema(flowDelta, flowSmooth)
cvd = ta.cum(flowDelta)
cvdTrend = ta.ema(cvd, flowLen)

obvStep = mClose > mClose[1] ? mVol : mClose < mClose[1] ? -mVol : 0.0
obvFusion = ta.cum(obvStep)
obvTrend = ta.ema(obvFusion, flowLen)

fusion = (norm01(deltaEma, 100) + norm01(cvdTrend, 100) + norm01(obvTrend, 100)) / 3.0
fusionEma = ta.ema(fusion, flowSmooth)
fusionRes = ta.highest(fusion, flowSrLen)
fusionSup = ta.lowest(fusion, flowSrLen)

flowBreakBull = ta.crossover(fusion, fusionRes[1])
flowBreakBear = ta.crossunder(fusion, fusionSup[1])

flowScore = clamp((fusion - 0.5) * 20.0 + (fusion > fusionEma ? 2.0 : -2.0) + (flowBreakBull ? 2.0 : flowBreakBear ? -2.0 : 0.0), -10.0, 10.0)

//━━━━━━━━━━━━━━━━ POWER ZONE
swingHi = ta.highest(high, 50)
swingLo = ta.lowest(low, 50)
swingRange = math.max(swingHi - swingLo, syminfo.mintick)

fibZoneLo = swingLo + swingRange * 0.382
fibZoneHi = swingLo + swingRange * 0.618
inPowerFib = close >= fibZoneLo and close <= fibZoneHi

cBody = math.abs(close - open)
cUpperWick = high - math.max(close, open)
cLowerWick = math.min(close, open) - low

bullCandle = cLowerWick > cBody * 2.0 and close > open ? 3.0 : close > open and cBody > math.abs(close[1] - open[1]) ? 2.0 : 0.0
bearCandle = cUpperWick > cBody * 2.0 and close < open ? 3.0 : close < open and cBody > math.abs(close[1] - open[1]) ? 2.0 : 0.0

volPower = volume / math.max(ta.sma(volume, 20), 1)
pwrScore = inPowerFib and bullCandle > bearCandle ? clamp(bullCandle + math.min(volPower, 5), 0, 10) : inPowerFib and bearCandle > bullCandle ? -clamp(bearCandle + math.min(volPower, 5), 0, 10) : 0.0

//━━━━━━━━━━━━━━━━ XABCD / FIBO
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float xP = na
var float aP = na
var float bP = na
var float cP = na
var float dP = na

var int xT = na
var int aT = na
var int bT = na
var int cT = na
var int dT = na

newFibPivot = not na(ph) or not na(pl)
pivPrice = not na(ph) ? ph : pl
pivType = not na(ph) ? 1 : -1

if newFibPivot
    xP := aP
    aP := bP
    bP := cP
    cP := dP
    dP := pivPrice
    xT := aT
    aT := bT
    bT := cT
    cT := dT
    dT := pivType

hasXABCD = not na(xP) and not na(aP) and not na(bP) and not na(cP) and not na(dP)

xa = hasXABCD ? math.abs(aP - xP) : na
ab = hasXABCD ? math.abs(bP - aP) : na
bc = hasXABCD ? math.abs(cP - bP) : na
cd = hasXABCD ? math.abs(dP - cP) : na
xd = hasXABCD ? math.abs(dP - xP) : na

ab_xa = hasXABCD ? ab / safe(xa) : na
bc_ab = hasXABCD ? bc / safe(ab) : na
cd_bc = hasXABCD ? cd / safe(bc) : na
xd_xa = hasXABCD ? xd / safe(xa) : na

fibAB = hasXABCD and (near(ab_xa, 0.382, fibTol) or near(ab_xa, 0.500, fibTol) or near(ab_xa, 0.618, fibTol) or near(ab_xa, 0.786, fibTol))
fibBC = hasXABCD and inZone(bc_ab, 0.382, 0.886, fibTol)
fibCD = hasXABCD and inZone(cd_bc, 0.886, 2.618, fibTol)
fibXD = hasXABCD and inZone(xd_xa, 0.618, 1.618, fibTol)

int softFibScore = 0
softFibScore += fibAB ? 1 : 0
softFibScore += fibBC ? 1 : 0
softFibScore += fibCD ? 1 : 0
softFibScore += fibXD ? 1 : 0

bullHarmonic = hasXABCD and softFibScore >= 2 and dT == -1
bearHarmonic = hasXABCD and softFibScore >= 2 and dT == 1

fibScore = bullHarmonic ? softFibScore * 2.0 : bearHarmonic ? -softFibScore * 2.0 : 0.0
fibScore := clamp(fibScore, -10.0, 10.0)

//━━━━━━━━━━━━━━━━ FORCE / HAP
groupHigh = ta.highest(high, 5)
groupLow = ta.lowest(low, 5)
groupRange = math.max(groupHigh - groupLow, syminfo.mintick)
netForce = ((close - groupLow) / groupRange) - ((groupHigh - close) / groupRange)
forceScore = clamp(netForce * 10.0, -10.0, 10.0)

hapRsi = ta.rsi(close, 14)
hapMid = ta.sma(hapRsi, 50)
hapDev = ta.stdev(hapRsi, 50)
hapUp = hapMid + hapDev
hapLow = hapMid - hapDev
hapScore = hapRsi > hapUp ? 6.0 : hapRsi < hapLow ? -6.0 : clamp((hapRsi - 50.0) / 8.0, -10.0, 10.0)

//━━━━━━━━━━━━━━━━ QUALITY CORE
qAtr = ta.atr(14)
qRsi = ta.rsi(close, 14)
qEma9 = ta.ema(close, 9)
qEma21 = ta.ema(close, 21)
qEma55 = ta.ema(close, 55)
[qMacdL, qMacdS, qMacdH] = ta.macd(close, 12, 26, 9)

wickPower = ((math.min(open, close) - low) - (high - math.max(open, close))) / math.max(high - low, syminfo.mintick)
qMom = close - close[coreLen]
qVolAvg = ta.sma(volume, coreLen)

qRaw = (close > qEma55 ? 10 : close < qEma55 ? -10 : 0) + (qEma9 > qEma21 ? 8 : qEma9 < qEma21 ? -8 : 0) + ((qRsi - 50) / 5) + (qMacdH > 0 ? 7 : qMacdH < 0 ? -7 : 0) + (qAtr != 0 ? qMom / qAtr : 0) + wickPower * 8 + (close > open and volume > qVolAvg ? 5 : close < open and volume > qVolAvg ? -5 : 0)

qRaw := clamp(qRaw, -50, 50)
qPct = clamp(qRaw + 50, 0, 100)

qTf1 = request.security(syminfo.tickerid, tf1, qPct[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
qTf2 = request.security(syminfo.tickerid, tf2, qPct[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
qTf3 = request.security(syminfo.tickerid, tf3, qPct[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

qCascadeBull = qTf1 > 55 and qTf2 > 55 and qTf3 > 55
qCascadeBear = qTf1 < 45 and qTf2 < 45 and qTf3 < 45

bullPersist = ta.sma(qPct > 55 ? 1.0 : 0.0, persistLen) * 100.0
bearPersist = ta.sma(qPct < 45 ? 1.0 : 0.0, persistLen) * 100.0

qMtfScore = qCascadeBull ? 80 + bullPersist * 0.20 : qCascadeBear ? 20 - bearPersist * 0.20 : 50 + (bullPersist - bearPersist) * 0.25
rangePower = clamp(qPct * 0.40 + qMtfScore * 0.60, 0, 100)

rangeBull = rangePower > bullQualityPct and qCascadeBull
rangeBear = rangePower < bearQualityPct and qCascadeBear

//━━━━━━━━━━━━━━━━ VERTEX
vAtr = ta.atr(vertexLen)
vDelta = close - close[1]
vMom = ta.roc(close, vertexLen)
vTrend = ta.ema(close, 9) - ta.ema(close, 21)

var float vObv = 0.0
vObv := nz(vObv[1]) + (close > close[1] ? volume : close < close[1] ? -volume : 0)

normV(x) =>
    b = ta.sma(math.abs(x), vertexLen)
    b == 0 ? 0 : x / b

matrixScore = normV(vAtr - vAtr[vertexLen]) + normV(vDelta) + normV(vObv - ta.ema(vObv, vertexLen)) + normV(vMom) + normV(vTrend)
vertexNorm = clamp(matrixScore, -10.0, 10.0)
vertexPct = toPct(vertexNorm)

//━━━━━━━━━━━━━━━━ 5D BOX ENGINE — HIDDEN POWER ONLY
o5dVol   = request.security(syminfo.tickerid, o5dBlockTf, volume)
o5dOpen  = request.security(syminfo.tickerid, o5dBlockTf, open)
o5dClose = request.security(syminfo.tickerid, o5dBlockTf, close)
o5dHigh  = request.security(syminfo.tickerid, o5dBlockTf, high)
o5dLow   = request.security(syminfo.tickerid, o5dBlockTf, low)

o5dSOpen  = math.sqrt(math.max(o5dOpen, syminfo.mintick))
o5dSClose = math.sqrt(math.max(o5dClose, syminfo.mintick))
o5dSHigh  = math.sqrt(math.max(o5dHigh, syminfo.mintick))
o5dSLow   = math.sqrt(math.max(o5dLow, syminfo.mintick))

o5dTR = math.max(o5dSHigh - o5dSLow, math.max(math.abs(o5dSHigh - o5dSClose[1]), math.abs(o5dSLow - o5dSClose[1])))
o5dSATR = ta.ema(o5dTR, o5dAtrLen)

o5dVolAvg = ta.sma(o5dVol, o5dVolLen)
o5dRelVol = o5dVolAvg != 0 ? o5dVol / o5dVolAvg : 1.0
o5dSqrtDelta = o5dSOpen != 0 ? ((o5dSClose - o5dSOpen) / o5dSOpen) * 100.0 : 0.0
o5dFastMom = ta.roc(close, o5dMomLen)

o5dRaw = o5dRelVol * o5dVolWeight + o5dSqrtDelta * o5dDeltaWeight + o5dFastMom * o5dMomWeight
o5dEnergyBase = o5dSATR != 0 ? o5dRaw / o5dSATR : o5dRaw

o5dFlowRaw = ta.ema(o5dEnergyBase, o5dSmoothLen)
o5dFlow = norm01(o5dFlowRaw, o5dNormLen) * 100.0
o5dSignal = ta.ema(o5dFlow, o5dSignalLen)

o5dBuyRaw = ta.crossover(o5dFlow, o5dSignal)
o5dBuy = o5dBuyRaw and o5dFlow < o5dBuyMaxZone

o5dTopFade = o5dFlow > o5dTopZone and o5dFlow < o5dFlow[1] and o5dFlow[1] >= o5dFlow[2]
o5dRedDot = o5dTopFade

var int o5dRedCount = 0
var int o5dFirstRedBar = na

if o5dBuy
    o5dRedCount := 0
    o5dFirstRedBar := na

if o5dRedDot
    if o5dRedCount == 0
        o5dFirstRedBar := bar_index
    o5dRedCount += 1

o5dBarsFromFirst = not na(o5dFirstRedBar) ? bar_index - o5dFirstRedBar : na
o5dInWindow = not na(o5dBarsFromFirst) and o5dBarsFromFirst <= o5dClusterBars - 1

if not o5dInWindow and not na(o5dFirstRedBar)
    o5dRedCount := o5dRedDot ? 1 : 0
    o5dFirstRedBar := o5dRedDot ? bar_index : na

o5dBoxActive = o5dRedCount >= 2 and o5dInWindow

var int o5dBoxDirection = 0
if o5dBuy
    o5dBoxDirection := 1
if o5dRedDot
    o5dBoxDirection := -1

boxBonus = o5dBoxDirection == 1 ? 30.0 : o5dBoxDirection == -1 ? -30.0 : 0.0

//━━━━━━━━━━━━━━━━ UNIFIED POWER
tf1Pct = request.security(syminfo.tickerid, tf1, f_light_score()[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
tf2Pct = request.security(syminfo.tickerid, tf2, f_light_score()[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
tf3Pct = request.security(syminfo.tickerid, tf3, f_light_score()[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

mtfPct = tf1Pct * 0.30 + tf2Pct * 0.35 + tf3Pct * 0.35
 
weighted = organScore * 1.2 + matcScore * 1.2 + rsiScore * 0.6 + ribbonScore * 0.7 + piScore * 1.5 + flowScore * 1.3 + pwrScore * 1.8 + fibScore * 1.0 + forceScore * 1.2 + hapScore * 0.9
weightSum = 1.2 + 1.2 + 0.6 + 0.7 + 1.5 + 1.3 + 1.8 + 1.0 + 1.2 + 0.9
corePower = toPct(weighted / weightSum)

mainPower = corePower * 0.45 + mtfPct * 0.25 + rangePower * 0.15 + (useVertex ? vertexPct : 50.0) * 0.10 + toPct(fibScore) * 0.05
mainPower := clamp(mainPower, 0.0, 100.0)

power = useO5D ? clamp(mainPower * 0.70 + 50.0 * 0.30 + boxBonus, 0.0, 100.0) : mainPower

//━━━━━━━━━━━━━━━━ SLINGSHOT EXPANDING RAILS 38 / 62
finalDirPower = power >= 50 ? power : 100.0 - power

hotImpulse = finalDirPower >= 78 or o5dBoxDirection == 1 or o5dBoxDirection == -1 or rangeBull or rangeBear
dynamicAtrMult = hotImpulse ? atrMult * 1.08 : finalDirPower < 55 ? atrMult * 0.92 : atrMult

fastCore = ta.linreg(hl2, fastLen, 0)
slowCore = ta.linreg(hl2, slowLen, 0)

fastBullBase = fastCore - atr * dynamicAtrMult
fastBearBase = fastCore + atr * dynamicAtrMult
slowBullBase = slowCore - atr * dynamicAtrMult
slowBearBase = slowCore + atr * dynamicAtrMult

var int fastDir = na
var float fastRail = na

if na(fastDir)
    fastDir := close >= fastCore ? 1 : -1
    fastRail := fastDir == 1 ? fastBullBase : fastBearBase

fastBuyFlip = barstate.isconfirmed and close > nz(fastRail[1], fastRail) and fastDir == -1
fastSellFlip = barstate.isconfirmed and close < nz(fastRail[1], fastRail) and fastDir == 1

if fastBuyFlip
    fastDir := 1
    fastRail := fastBullBase
else if fastSellFlip
    fastDir := -1
    fastRail := fastBearBase
else
    if fastDir == 1
        fastRail := math.max(nz(fastRail[1], fastBullBase), fastBullBase)
    else
        fastRail := math.min(nz(fastRail[1], fastBearBase), fastBearBase)

var int slowDir = na
var float slowRail = na

if na(slowDir)
    slowDir := close >= slowCore ? 1 : -1
    slowRail := slowDir == 1 ? slowBullBase : slowBearBase

slowBuyFlip = barstate.isconfirmed and close > nz(slowRail[1], slowRail) and slowDir == -1
slowSellFlip = barstate.isconfirmed and close < nz(slowRail[1], slowRail) and slowDir == 1

if slowBuyFlip
    slowDir := 1
    slowRail := slowBullBase
else if slowSellFlip
    slowDir := -1
    slowRail := slowBearBase
else
    if slowDir == 1
        slowRail := math.max(nz(slowRail[1], slowBullBase), slowBullBase)
    else
        slowRail := math.min(nz(slowRail[1], slowBearBase), slowBearBase)

//━━━━━━━━━━━━━━━━ SLINGSHOT LOGIC
upTrend = fastRail >= slowRail
downTrend = fastRail < slowRail

pullbackUpT = upTrend and close < fastRail
pullbackDnT = downTrend and close > fastRail

entryUpT = upTrend and close[1] < fastRail[1] and close > fastRail
entryDnT = downTrend and close[1] > fastRail[1] and close < fastRail

cleanBuy = showConservative and entryUpT and barstate.isconfirmed
cleanSell = showConservative and entryDnT and barstate.isconfirmed

lineCol = upTrend ? bullC : downTrend ? bearC : midC
slowCol = upTrend ? color.new(bullC, 30) : downTrend ? color.new(bearC, 30) : color.new(midC, 60)
fillCol = upTrend ? color.new(bullC, 82) : downTrend ? color.new(bearC, 82) : color.new(midC, 90)

pFast = plot(fastRail, "Fast Expanding Sling Rail 38", color=lineCol, linewidth=5, style=plot.style_linebr)
pSlow = plot(showSlowRail ? slowRail : na, "Slow Expanding Sling Rail 62", color=slowCol, linewidth=3, style=plot.style_linebr)

fill(pFast, pSlow, color=fillCol, title="Sling Rail Cloud")

pPrice = plot(close, "Price Base", color=color.new(color.white, 100))
auraTransp = finalDirPower >= 80 ? 72 : finalDirPower >= 60 ? 86 : 96

fill(pPrice, pFast, color=showAura and upTrend ? color.new(bullC, auraTransp) : na)
fill(pPrice, pFast, color=showAura and downTrend ? color.new(bearC, auraTransp) : na)

plotshape(showTrendMarks and upTrend, title="Trend Bull", style=shape.triangleup, location=location.bottom, color=bullC, size=size.tiny)
plotshape(showTrendMarks and downTrend, title="Trend Bear", style=shape.triangledown, location=location.top, color=bearC, size=size.tiny)

plotshape(showEntryLabels and cleanBuy, title="BUY", style=shape.labelup, location=location.belowbar, color=bullC, textcolor=color.black, text="B", size=size.small)
plotshape(showEntryLabels and cleanSell, title="SELL", style=shape.labeldown, location=location.abovebar, color=bearC, textcolor=color.white, text="S", size=size.small)

//━━━━━━━━━━━━━━━━ BAR COLOR
barTransp = finalDirPower >= 80 ? 38 : finalDirPower >= 60 ? 55 : 68

barCol = showConservative and cleanBuy ? entryC :
     showConservative and cleanSell ? entryC :
     showAggressive and pullbackUpT ? goldC :
     showAggressive and pullbackDnT ? goldC :
     upTrend ? color.new(bullC, barTransp) :
     downTrend ? color.new(bearC, barTransp) :
     na

barcolor(showBars ? barCol : na)

//━━━━━━━━━━━━━━━━ TETRIS
getBlocks(x) =>
    ax = math.abs(x)
    b = ax >= 9 ? 12 : ax >= 7 ? 10 : ax >= 5 ? 8 : ax >= 3 ? 6 : ax >= 2 ? 4 : ax >= 1 ? 3 : ax > 0 ? 2 : 1
    math.min(b, rows)

getColor(x) =>
    x >= 7 ? bullC :
     x >= 3 ? color.new(bullC, 30) :
     x >= 1 ? goldC :
     x <= -7 ? bearC :
     x <= -3 ? color.new(bearC, 30) :
     x <= -1 ? goldC :
     midC

var table grid = table.new(position.middle_right, 1, rows, border_width=1)

if showGrid and barstate.islast
    blocks = getBlocks(vertexNorm)
    vCol = getColor(vertexNorm)
    for r = 0 to rows - 1
        table.cell(grid, 0, r, "", bgcolor=color.rgb(10, 10, 10))
    for r = 0 to blocks - 1
        table.cell(grid, 0, rows - 1 - r, "🧩", bgcolor=vCol)

//━━━━━━━━━━━━━━━━ PANEL
var table pan = table.new(position.top_right, 2, 7, border_width=1)

if showPanel and barstate.islast
    trendTxt = upTrend ? txt("BULL","BOĞA","BULLE","ALCISTA","HAUSSIER","БЫК","صاعد") : downTrend ? txt("BEAR","AYI","BÄR","BAJISTA","BAISSIER","МЕДВЕДЬ","هابط") : txt("NEUTRAL","NÖTR","NEUTRAL","NEUTRAL","NEUTRE","НЕЙТРАЛЬНО","محايد")
    trendCol = upTrend ? bullC : downTrend ? bearC : midC
    pullTxt = pullbackUpT or pullbackDnT ? txt("PULLBACK","GERİ ÇEKİLME","RÜCKLAUF","RETROCESO","REPLI","ОТКАТ","تصحيح") : cleanBuy or cleanSell ? txt("ENTRY","GİRİŞ","EINSTIEG","ENTRADA","ENTRÉE","ВХОД","دخول") : txt("NORMAL","NORMAL","NORMAL","NORMAL","NORMAL","НОРМАЛЬНО","طبيعي")
    lineTxt = finalDirPower >= 80 ? txt("STRONG","GÜÇLÜ","STARK","FUERTE","FORT","СИЛЬНЫЙ","قوي") : finalDirPower >= 60 ? txt("MEDIUM","ORTA","MITTEL","MEDIO","MOYEN","СРЕДНИЙ","متوسط") : txt("WEAK","ZAYIF","SCHWACH","DÉBIL","FAIBLE","СЛАБЫЙ","ضعيف")

    table.cell(pan, 0, 0, txt("SYSTEM","SİSTEM","SYSTEM","SISTEMA","SYSTÈME","СИСТЕМА","النظام"), text_color=color.white, bgcolor=color.black)
    table.cell(pan, 1, 0, "OMEGA SLING 38/62", text_color=trendCol, bgcolor=color.black)
    table.cell(pan, 0, 1, txt("Trend","Trend","Trend","Tendencia","Tendance","Тренд","الاتجاه"), text_color=color.white)
    table.cell(pan, 1, 1, trendTxt, text_color=trendCol)
    table.cell(pan, 0, 2, txt("Power","Güç","Kraft","Potencia","Puissance","Сила","القوة"), text_color=color.white)
    table.cell(pan, 1, 2, str.tostring(power, "#.0") + "%", text_color=finalDirPower >= 80 ? goldC : trendCol)
    table.cell(pan, 0, 3, "Fast", text_color=color.white)
    table.cell(pan, 1, 3, str.tostring(fastLen), text_color=lineCol)
    table.cell(pan, 0, 4, "Slow", text_color=color.white)
    table.cell(pan, 1, 4, str.tostring(slowLen), text_color=slowCol)
    table.cell(pan, 0, 5, txt("State","Durum","Status","Estado","État","Состояние","الحالة"), text_color=color.white)
    table.cell(pan, 1, 5, pullTxt, text_color=(cleanBuy or cleanSell) ? entryC : (pullbackUpT or pullbackDnT) ? goldC : trendCol)
    table.cell(pan, 0, 6, txt("Line","Çizgi","Linie","Línea","Ligne","Линия","الخط"), text_color=color.white)
    table.cell(pan, 1, 6, lineTxt, text_color=finalDirPower >= 80 ? goldC : trendCol)

//━━━━━━━━━━━━━━━━ ALERTS
alertcondition(cleanBuy, "SLING BUY", "OMEGA SLING 38/62 BUY")
alertcondition(cleanSell, "SLING SELL", "OMEGA SLING 38/62 SELL")
alertcondition(pullbackUpT, "Bull Pullback", "OMEGA SLING Bull Pullback")
alertcondition(pullbackDnT, "Bear Pullback", "OMEGA SLING Bear Pullback")
````

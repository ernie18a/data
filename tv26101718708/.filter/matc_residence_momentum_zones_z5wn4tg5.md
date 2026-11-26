# MATC Residence Momentum Zones 

- url: https://www.tradingview.com/script/z5Wn4TG5/
- type: indicator
- pine_id: PUB;6a0d298a4aba4967b3b511006d115c43
- version: 3.0

## Description

)
Description

MATC Residence Momentum Zones is a trend-regime visualization system designed to map market structure using dynamic support and resistance zones, combined with forward projection.

The indicator defines an upper resistance level and a lower support level, which form the main structural boundaries of price movement. A midline is used as a neutral reference area between these two zones.

In addition to the current structure, the system projects these levels forward in time. This forward projection creates a “future zone view”, allowing the user to observe how current market structure may extend into upcoming price action.

When price breaks above the resistance structure, the system transitions into a bullish regime. When price breaks below the support structure, it transitions into a bearish regime. These regime changes are used to generate BUY and SELL signals.

The visualization includes a color-filled area between the current structure and its forward projection. These filled zones represent a forecasted continuation area, not a guaranteed outcome. They are derived directly from the underlying price-based structure and serve as a visual representation of potential directional expansion.

Key elements:

Upper zone represents resistance-based structure
Lower zone represents support-based structure
Midline represents equilibrium
Forward projection shows extended structural expectation
Colored zones between current and projected levels represent probabilistic directional bias based on price action

This tool is intended for structural interpretation of trend direction and forward market context rather than precise prediction.

🇹🇷 MATC Residence Momentum Zones (Signals dahil)
Açıklama

MATC Residence Momentum Zones, piyasa yapısını dinamik destek ve direnç bölgeleri üzerinden görselleştiren ve buna ek olarak ileriye projeksiyon yapan bir trend rejim sistemidir.

İndikatör, fiyat hareketini üst direnç ve alt destek seviyeleri ile sınırlandırır. Bu iki seviye, piyasanın ana yapısal bölgelerini oluşturur. Orta çizgi ise bu iki bölge arasında denge referansı olarak kullanılır.

Sistemde ayrıca bu seviyeler ileriye doğru projekte edilir. Bu projeksiyon sayesinde kullanıcı, mevcut piyasa yapısının gelecekte nasıl devam edebileceğine dair görsel bir alan görür.

Fiyat üst direnç seviyesini kırdığında sistem boğa (bullish) rejimine geçer, alt destek seviyesini kırdığında ise ayı (bearish) rejimine geçer. Bu rejim değişimleri BUY ve SELL sinyallerini oluşturur.

Görselleştirmede, mevcut yapı ile ileri projeksiyon arasındaki alan renklendirilir. Bu renkli bölgeler, kesin bir tahmin değil, fiyat yapısından türetilmiş olasılıksal devam bölgesini temsil eder.

Bu renkli alanlar:

Üst bölgede yeşil olarak yükseliş baskısını
Alt bölgede kırmızı olarak düşüş baskısını
Gelecekteki olası fiyat genişleme alanını

görsel olarak ifade eder.

Bu sistem, kesin tahmin üretmekten ziyade piyasa yapısını ve trend yönünü daha net okumayı amaçlar.

## Source Code

````pine
//@version=6
indicator("OMEGA ULTIMATE PRO V5 V4 • NET FORCE ATR", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

//━━━━━━━━━━━━━━━━━━━
// BÖLÜM 1/4
// ÇEKİRDEK MOTORLAR
// Trend + GAE + PVM + VETI + Ichimoku
//━━━━━━━━━━━━━━━━━━━

//━━━━━━━━ INPUTS
tf1 = input.timeframe("15", "TF 1", group="MTF")
tf2 = input.timeframe("60", "TF 2", group="MTF")
tf3 = input.timeframe("240", "TF 3", group="MTF")
tf4 = input.timeframe("D", "TF 4", group="MTF")

showPanel   = input.bool(true, "Panel", group="Display")
showSignals = input.bool(true, "Signals", group="Display")
showBars    = input.bool(true, "Candle Color", group="Display")

// Ağırlıklar
wTrend = input.float(1.30, "Trend Weight", step=0.1, group="Weights")
wGAE   = input.float(1.60, "GAE MTF Weight", step=0.1, group="Weights")
wPVM   = input.float(1.25, "PVM Weight", step=0.1, group="Weights")
wVETI  = input.float(1.35, "VETI Weight", step=0.1, group="Weights")
wIchi  = input.float(1.20, "Ichimoku Weight", step=0.1, group="Weights")

// Ana eşikler
bullTh   = input.float(62.0, "Bull Threshold", step=1, group="Thresholds")
bearTh   = input.float(38.0, "Bear Threshold", step=1, group="Thresholds")
strongTh = input.float(75.0, "Strong Threshold", step=1, group="Thresholds")

// Renkler
bullC = color.lime
bearC = color.red
midC  = color.gray
goldC = color.yellow
aquaC = color.aqua
pwrC  = color.fuchsia

//━━━━━━━━ HELPERS
clamp(x, lo, hi) =>
    math.max(math.min(x, hi), lo)

normalize(src, len) =>
    lo = ta.lowest(src, len)
    hi = ta.highest(src, len)
    hi != lo ? 100.0 * (src - lo) / (hi - lo) : 50.0

scoreToPct(score) =>
    clamp(score * 5.0 + 50.0, 0.0, 100.0)

safeDiv(a, b) =>
    b != 0 ? a / b : 0.0

//━━━━━━━━━━━━━━━━━━━
// MOTOR 1 — TREND ENGINE
//━━━━━━━━━━━━━━━━━━━
ema21  = ta.ema(close, 21)
ema55  = ta.ema(close, 55)
ema100 = ta.ema(close, 100)
ema200 = ta.ema(close, 200)

trendScore =
     close > ema200 and ema21 > ema55 and ema55 > ema100 ? 10.0 :
     close < ema200 and ema21 < ema55 and ema55 < ema100 ? -10.0 :
     close > ema100 and ema21 > ema55 ? 6.0 :
     close < ema100 and ema21 < ema55 ? -6.0 :
     ema21 > ema55 ? 3.0 :
     ema21 < ema55 ? -3.0 : 0.0

trendPct = scoreToPct(trendScore)

//━━━━━━━━━━━━━━━━━━━
// MOTOR 2 — GAE MTF ALIGNMENT
//━━━━━━━━━━━━━━━━━━━
f_gae_state() =>
    _atr = ta.atr(14)
    _core = ta.linreg(hl2, 38, 0)

    _bullBase = _core - _atr * 2.4
    _bearBase = _core + _atr * 2.4

    var int _dir = na
    var float _rail = na

    if na(_dir)
        _dir := close >= _core ? 1 : -1
        _rail := _dir == 1 ? _bullBase : _bearBase

    _buyFlip  = barstate.isconfirmed and close > nz(_rail[1], _rail) and _dir == -1
    _sellFlip = barstate.isconfirmed and close < nz(_rail[1], _rail) and _dir == 1

    if _buyFlip
        _dir := 1
        _rail := _bullBase
    else if _sellFlip
        _dir := -1
        _rail := _bearBase
    else
        _rail := _dir == 1 ? math.max(nz(_rail[1], _bullBase), _bullBase) : math.min(nz(_rail[1], _bearBase), _bearBase)

    _dir

gae1 = request.security(syminfo.tickerid, tf1, f_gae_state(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
gae2 = request.security(syminfo.tickerid, tf2, f_gae_state(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
gae3 = request.security(syminfo.tickerid, tf3, f_gae_state(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
gae4 = request.security(syminfo.tickerid, tf4, f_gae_state(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
 
gaeBullVotes = (gae1 == 1 ? 1 : 0) + (gae2 == 1 ? 1 : 0) + (gae3 == 1 ? 1 : 0) + (gae4 == 1 ? 1 : 0)
gaeBearVotes = 4 - gaeBullVotes

gaePct = gaeBullVotes / 4.0 * 100.0

gaeFullBull = gaeBullVotes == 4
gaeFullBear = gaeBearVotes == 4
gaeStrongBull = gaeBullVotes >= 3
gaeStrongBear = gaeBearVotes >= 3

//━━━━━━━━━━━━━━━━━━━
// MOTOR 3 — PVM
// Price Volume Memory / Momentum
//━━━━━━━━━━━━━━━━━━━
priceChange = ta.change(close)
volumeChange = ta.change(volume)

pvmCorrRaw = nz(ta.correlation(priceChange, volumeChange, 55), 0.0)
pvmTrendEngine = ta.ema((pvmCorrRaw + 1.0) * 50.0, 9)

pvmRelVolBase = ta.ema(volume, 34)
pvmRelVol = volume / math.max(pvmRelVolBase, 1.0)

pvmAtrNow = ta.atr(14)
pvmAtrBase = ta.ema(pvmAtrNow, 34)
pvmAtrExpansion = pvmAtrNow / math.max(pvmAtrBase, syminfo.mintick)

pvmImpulseRaw = pvmAtrExpansion * pvmRelVol
pvmImpulseEngine = ta.ema(normalize(pvmImpulseRaw, 100), 9)

pvmDirectionRaw = ta.roc(close, 14)
pvmDirectionEngine = ta.ema(normalize(pvmDirectionRaw, 100), 9)

pvmPct =
     pvmTrendEngine * 0.40 +
     pvmImpulseEngine * 0.35 +
     pvmDirectionEngine * 0.25

pvmBull = pvmPct >= 55
pvmBear = pvmPct <= 45

//━━━━━━━━━━━━━━━━━━━
// MOTOR 4 — VETI
// Volume Efficiency Trend Index
//━━━━━━━━━━━━━━━━━━━
green = close > open
red   = close < open

upMove = math.max(close - close[1], 0.0)
dnMove = math.max(close[1] - close, 0.0)

greenVol = green ? volume : 0.0
redVol   = red ? volume : 0.0

bullEffRaw = upMove / math.max(greenVol, 1.0)
bearEffRaw = dnMove / math.max(redVol, 1.0)

bullEff = ta.ema(ta.percentrank(bullEffRaw, 34) * 100.0, 5)
bearEff = ta.ema(ta.percentrank(bearEffRaw, 34) * 100.0, 5)

greenVolAvg = ta.ema(greenVol, 20)
redVolAvg   = ta.ema(redVol, 20)

vetiBullLogic =
     bullEff > bearEff and
     greenVolAvg <= greenVolAvg[1] and
     redVolAvg >= redVolAvg[1]

vetiBearLogic =
     bearEff > bullEff and
     redVolAvg <= redVolAvg[1] and
     greenVolAvg >= greenVolAvg[1]

vetiPct =
     vetiBullLogic ? 75.0 :
     vetiBearLogic ? 25.0 :
     clamp(50.0 + (bullEff - bearEff) * 0.35, 0.0, 100.0)

vetiBull = vetiPct >= 55
vetiBear = vetiPct <= 45

//━━━━━━━━━━━━━━━━━━━
// MOTOR 5 — ICHIMOKU POWER
//━━━━━━━━━━━━━━━━━━━
tenkanLen = input.int(9, "Tenkan", group="Ichimoku")
kijunLen  = input.int(26, "Kijun", group="Ichimoku")
senkouLen = input.int(52, "Senkou", group="Ichimoku")

tenkan = (ta.highest(high, tenkanLen) + ta.lowest(low, tenkanLen)) / 2.0
kijun  = (ta.highest(high, kijunLen) + ta.lowest(low, kijunLen)) / 2.0
senkouA = (tenkan + kijun) / 2.0
senkouB = (ta.highest(high, senkouLen) + ta.lowest(low, senkouLen)) / 2.0

kumoTop = math.max(senkouA, senkouB)
kumoBot = math.min(senkouA, senkouB)

ichiPriceBull = close > kumoTop
ichiPriceBear = close < kumoBot
ichiCloudBull = senkouA > senkouB
ichiCloudBear = senkouA < senkouB
ichiTkBull = tenkan > kijun
ichiTkBear = tenkan < kijun
ichiChikouBull = close > close[26]
ichiChikouBear = close < close[26]

ichiScore =
     (ichiPriceBull ? 3.5 : ichiPriceBear ? -3.5 : 0.0) +
     (ichiCloudBull ? 2.0 : ichiCloudBear ? -2.0 : 0.0) +
     (ichiTkBull ? 2.0 : ichiTkBear ? -2.0 : 0.0) +
     (ichiChikouBull ? 1.5 : ichiChikouBear ? -1.5 : 0.0)

ichiScore := clamp(ichiScore, -10.0, 10.0)
ichiPct = scoreToPct(ichiScore)

ichiBull = ichiPct >= 60
ichiBear = ichiPct <= 40

//━━━━━━━━━━━━━━━━━━━
// BÖLÜM 1 GEÇİCİ SKOR
// Diğer bölümler eklenince Final Matrix Bölüm 4'te hesaplanacak.
//━━━━━━━━━━━━━━━━━━━
coreWeightSum = wTrend + wGAE + wPVM + wVETI + wIchi

corePct =
     (trendPct * wTrend +
      gaePct   * wGAE +
      pvmPct   * wPVM +
      vetiPct  * wVETI +
      ichiPct  * wIchi) / coreWeightSum

corePct := clamp(corePct, 0.0, 100.0)
//━━━━━━━━━━━━━━━━━━━
// BÖLÜM 2/4
// OTE + STRUCTURE + RSI STRUCTURE + HAP + REGRESSION FLOW
//━━━━━━━━━━━━━━━━━━━

//━━━━━━━━━━━━━━━━━━━
// MOTOR 6 — RSI STRUCTURE + ACCELERATION
//━━━━━━━━━━━━━━━━━━━
rsiLenStruct   = input.int(14, "RSI Length", group="RSI Structure")
rsiPivotLen    = input.int(5, "RSI Pivot Length", group="RSI Structure")
rsiAccSmooth   = input.int(5, "RSI Acc Smooth", group="RSI Structure")

rsiStruct = ta.rsi(close, rsiLenStruct)

rsiVel = rsiStruct - rsiStruct[1]
rsiAcc = rsiVel - rsiVel[1]
rsiAccSm = ta.ema(rsiAcc, rsiAccSmooth)

rsiHighPivot = ta.pivothigh(rsiStruct, rsiPivotLen, rsiPivotLen)
rsiLowPivot  = ta.pivotlow(rsiStruct, rsiPivotLen, rsiPivotLen)

var float rsiRes = na
var float rsiSup = na

if not na(rsiHighPivot)
    rsiRes := rsiHighPivot

if not na(rsiLowPivot)
    rsiSup := rsiLowPivot

rsiBullBreak = not na(rsiRes) and rsiStruct > rsiRes and rsiAccSm > 0
rsiBearBreak = not na(rsiSup) and rsiStruct < rsiSup and rsiAccSm < 0

rsiStructScore =
     rsiBullBreak ? 8.0 :
     rsiBearBreak ? -8.0 :
     (rsiStruct - 50.0) / 5.0 + rsiAccSm * 2.0

rsiStructScore := clamp(rsiStructScore, -10.0, 10.0)
rsiStructPct = scoreToPct(rsiStructScore)

rsiStructBull = rsiStructPct >= 60
rsiStructBear = rsiStructPct <= 40

//━━━━━━━━━━━━━━━━━━━
// MOTOR 7 — HAP RSI PRICE BAND + SQUEEZE
//━━━━━━━━━━━━━━━━━━━
hapRsiLen   = input.int(14, "HAP RSI Length", group="HAP")
hapBandLen  = input.int(50, "HAP Band Length", group="HAP")
hapPriceLen = input.int(100, "HAP Price Scale Length", group="HAP")

hapRsi = ta.rsi(close, hapRsiLen)

hapMidRsi = ta.sma(hapRsi, hapBandLen)
hapDevRsi = ta.stdev(hapRsi, hapBandLen)
hapUpRsi  = hapMidRsi + hapDevRsi
hapLowRsi = hapMidRsi - hapDevRsi

hapPriceMid = ta.sma(close, hapPriceLen)
hapPriceDev = ta.stdev(close, hapPriceLen)
hapScale = hapPriceDev / 50.0

hapUpper = hapPriceMid + (hapUpRsi - 50.0) * hapScale
hapLower = hapPriceMid + (hapLowRsi - 50.0) * hapScale

hapBandW = hapUpRsi - hapLowRsi
hapBwAvg = ta.sma(hapBandW, hapBandLen)

hapSqueeze = hapBandW < hapBwAvg
hapRelease = hapSqueeze[1] and not hapSqueeze

hapAbove = close > hapUpper
hapBelow = close < hapLower
hapMid = not hapAbove and not hapBelow

hapPct =
     hapRelease and hapAbove ? 78.0 :
     hapRelease and hapBelow ? 22.0 :
     hapAbove ? 65.0 :
     hapBelow ? 35.0 :
     hapSqueeze ? 50.0 : 52.0

hapBull = hapPct >= 60
hapBear = hapPct <= 40

//━━━━━━━━━━━━━━━━━━━
// MOTOR 8 — REGRESSION FLOW CORE
//━━━━━━━━━━━━━━━━━━━
regLenFlow     = input.int(120, "Regression Length", minval=20, maxval=300, group="Regression Flow")
regSmoothFlow  = input.int(5, "Regression Smooth", minval=1, group="Regression Flow")
flowAtrLen     = input.int(14, "Flow ATR Length", group="Regression Flow")
flowPowerLen   = input.int(34, "Flow Power Length", group="Regression Flow")
flowAvgLen     = input.int(55, "Flow AVG Length", group="Regression Flow")

regSrc = hl2

reg0 = ta.linreg(regSrc, regLenFlow, 0)
reg1 = ta.linreg(regSrc, regLenFlow, 1)
reg2 = ta.linreg(regSrc, regLenFlow, 2)

regSlope = reg0 - reg1
regCurve = (reg0 - reg1) - (reg1 - reg2)

regCoreRaw = reg0 + regSlope * 2.0 + regCurve * regLenFlow * 0.25
regCore = ta.ema(regCoreRaw, regSmoothFlow)

regBull = regCore > regCore[1]
regBear = regCore < regCore[1]

flowAtr = ta.atr(flowAtrLen)
flowDev = ta.ema(math.abs(close - regCore), regLenFlow)
flowWidthBase = math.max(flowDev, flowAtr)

flowSlopePower = normalize(math.abs(regSlope), flowPowerLen)
flowCurvePower = normalize(math.abs(regCurve), flowPowerLen)
flowDistRaw = math.abs(close - regCore) / math.max(flowWidthBase, syminfo.mintick)
flowDistPower = clamp(flowDistRaw * 50.0, 0.0, 100.0)
flowAtrPower = normalize(flowAtr, flowPowerLen)

flowPower =
     flowSlopePower * 0.40 +
     flowCurvePower * 0.20 +
     flowDistPower  * 0.25 +
     flowAtrPower   * 0.15

flowPower := ta.ema(flowPower, 5)
flowAvgPower = ta.ema(flowPower, flowAvgLen)
flowEdge = flowPower - flowAvgPower

flowPct =
     regBull ? clamp(50.0 + flowPower * 0.50, 0.0, 100.0) :
     regBear ? clamp(50.0 - flowPower * 0.50, 0.0, 100.0) :
     50.0

flowBull = flowPct >= 60
flowBear = flowPct <= 40

// Flowing OTE / Target bands
oteMultFlow = input.float(2.4, "Flow OTE Band Width", step=0.1, group="Regression Flow")
tpMultFlow  = input.float(1.4, "Flow Target Band Width", step=0.1, group="Regression Flow")

flowOteWidth = flowWidthBase * oteMultFlow
flowTpWidth  = flowWidthBase * tpMultFlow

flowBullOTE = regCore - flowOteWidth * 0.886
flowBullTP  = regCore + flowTpWidth  * 0.618

flowBearOTE = regCore + flowOteWidth * 0.886
flowBearTP  = regCore - flowTpWidth  * 0.618

flowOTE = regBull ? flowBullOTE : regBear ? flowBearOTE : na
flowTP  = regBull ? flowBullTP  : regBear ? flowBearTP  : na

//━━━━━━━━━━━━━━━━━━━
// MOTOR 9 — MARKET STRUCTURE + OTE STRUCTURE
//━━━━━━━━━━━━━━━━━━━
swingPivotLen = input.int(5, "Structure Pivot Length", group="Structure / OTE")
maxSwingMem   = input.int(40, "Swing Memory", minval=10, maxval=100, group="Structure / OTE")

phStruct = ta.pivothigh(high, swingPivotLen, swingPivotLen)
plStruct = ta.pivotlow(low, swingPivotLen, swingPivotLen)

phStructBar = bar_index - swingPivotLen
plStructBar = bar_index - swingPivotLen

var float[] stPrice = array.new_float()
var int[] stBar = array.new_int()
var int[] stType = array.new_int()

addStructurePivot(_price, _bar, _type) =>
    _sz = array.size(stType)

    if _sz == 0
        array.push(stPrice, _price)
        array.push(stBar, _bar)
        array.push(stType, _type)
    else
        _lastType = array.get(stType, _sz - 1)
        _lastPrice = array.get(stPrice, _sz - 1)

        if _lastType == _type
            _replaceHigh = _type == 1 and _price > _lastPrice
            _replaceLow  = _type == -1 and _price < _lastPrice

            if _replaceHigh or _replaceLow
                array.set(stPrice, _sz - 1, _price)
                array.set(stBar, _sz - 1, _bar)
        else
            array.push(stPrice, _price)
            array.push(stBar, _bar)
            array.push(stType, _type)

    while array.size(stType) > maxSwingMem
        array.shift(stPrice)
        array.shift(stBar)
        array.shift(stType)

if not na(phStruct)
    addStructurePivot(phStruct, phStructBar, 1)

if not na(plStruct)
    addStructurePivot(plStruct, plStructBar, -1)

stSz = array.size(stType)

float lastHighPrice = na
float lastLowPrice = na
float prevHighPrice = na
float prevLowPrice = na
 
if stSz >= 2
    for i = stSz - 1 to 0
        _t = array.get(stType, i)
        _p = array.get(stPrice, i)

        if _t == 1 and na(lastHighPrice)
            lastHighPrice := _p
        else if _t == 1 and na(prevHighPrice)
            prevHighPrice := _p

        if _t == -1 and na(lastLowPrice)
            lastLowPrice := _p
        else if _t == -1 and na(prevLowPrice)
            prevLowPrice := _p

structureHH = not na(lastHighPrice) and not na(prevHighPrice) and lastHighPrice > prevHighPrice
structureLH = not na(lastHighPrice) and not na(prevHighPrice) and lastHighPrice <= prevHighPrice
structureHL = not na(lastLowPrice) and not na(prevLowPrice) and lastLowPrice > prevLowPrice
structureLL = not na(lastLowPrice) and not na(prevLowPrice) and lastLowPrice <= prevLowPrice

bosBull = not na(lastHighPrice) and close > lastHighPrice
bosBear = not na(lastLowPrice) and close < lastLowPrice

structureScore =
     (structureHH ? 2.0 : structureLH ? -2.0 : 0.0) +
     (structureHL ? 2.0 : structureLL ? -2.0 : 0.0) +
     (bosBull ? 4.0 : bosBear ? -4.0 : 0.0)

structureScore := clamp(structureScore, -10.0, 10.0)
structurePct = scoreToPct(structureScore)

structureBull = structurePct >= 60
structureBear = structurePct <= 40

// OTE impulse score from last four pivots
oteStructPct = 50.0
float activeOTE = na
float activeTP = na

if stSz >= 4
    i1 = stSz - 4
    i2 = stSz - 3
    i3 = stSz - 2
    i4 = stSz - 1

    t1 = array.get(stType, i1)
    t2 = array.get(stType, i2)
    t3 = array.get(stType, i3)
    t4 = array.get(stType, i4)

    p1 = array.get(stPrice, i1)
    p2 = array.get(stPrice, i2)
    p3 = array.get(stPrice, i3)
    p4 = array.get(stPrice, i4)

    bullImpulse = t3 == -1 and t4 == 1 and p4 > p2 and p3 > p1
    bearImpulse = t3 == 1 and t4 == -1 and p4 < p2 and p3 < p1

    if bullImpulse
        activeOTE := p4 - (p4 - p3) * 0.886
        activeTP  := p4 - (p4 - p3) * 0.618
        oteStructPct := 68.0

    if bearImpulse
        activeOTE := p4 + (p3 - p4) * 0.886
        activeTP  := p4 + (p3 - p4) * 0.618
        oteStructPct := 32.0

oteBull = oteStructPct >= 60
oteBear = oteStructPct <= 40

//━━━━━━━━━━━━━━━━━━━
// BÖLÜM 2 GEÇİCİ SKOR
//━━━━━━━━━━━━━━━━━━━
wRSI  = input.float(0.90, "RSI Structure Weight", step=0.1, group="Weights")
wHAP  = input.float(0.75, "HAP Weight", step=0.1, group="Weights")
wFlow = input.float(1.15, "Regression Flow Weight", step=0.1, group="Weights")
wST   = input.float(1.10, "Market Structure Weight", step=0.1, group="Weights")
wOTE  = input.float(0.90, "OTE Structure Weight", step=0.1, group="Weights")

part2WeightSum = wRSI + wHAP + wFlow + wST + wOTE

part2Pct =
     (rsiStructPct * wRSI +
      hapPct       * wHAP +
      flowPct      * wFlow +
      structurePct * wST +
      oteStructPct * wOTE) / part2WeightSum

part2Pct := clamp(part2Pct, 0.0, 100.0)
//━━━━━━━━━━━━━━━━━━━
// BÖLÜM 3/4
// POWER ZONE + LIQUIDITY + VOLUME DELTA + HARMONIC + VOLATILITY
//━━━━━━━━━━━━━━━━━━━

//━━━━━━━━━━━━━━━━━━━
// MOTOR 10 — POWER ZONE PRO
//━━━━━━━━━━━━━━━━━━━
pzPivotLen = input.int(10, "Power Zone Pivot Lookback", group="Power Zone")
pzVolMult  = input.float(1.8, "Power Zone Volume Mult", step=0.1, group="Power Zone")
pzCooldown = input.int(20, "Power Signal Cooldown", minval=1, group="Power Zone")

pzHigh = ta.pivothigh(high, pzPivotLen, pzPivotLen)
pzLow  = ta.pivotlow(low, pzPivotLen, pzPivotLen)

var float pzLastRes = na
var int   pzLastResBar = na
var float pzLastSup = na
var int   pzLastSupBar = na

if not na(pzHigh)
    pzLastRes := pzHigh
    pzLastResBar := bar_index - pzPivotLen

if not na(pzLow)
    pzLastSup := pzLow
    pzLastSupBar := bar_index - pzPivotLen

var int pzResTests = 0
var int pzSupTests = 0

if not na(pzLastRes) and high >= pzLastRes * 0.998 and high <= pzLastRes * 1.002 and bar_index != pzLastResBar
    pzResTests += 1

if not na(pzLastSup) and low <= pzLastSup * 1.002 and low >= pzLastSup * 0.998 and bar_index != pzLastSupBar
    pzSupTests += 1

pzStrongRes = not na(pzLastRes) and pzResTests >= 2
pzStrongSup = not na(pzLastSup) and pzSupTests >= 2

pzSwingHi = ta.highest(high, 50)
pzSwingLo = ta.lowest(low, 50)
pzSwingRange = math.max(pzSwingHi - pzSwingLo, syminfo.mintick)

pzFibLo = pzSwingLo + pzSwingRange * 0.382
pzFibHi = pzSwingLo + pzSwingRange * 0.618
pzInFib = close >= pzFibLo and close <= pzFibHi

pzBody = math.abs(close - open)
pzUpperWick = high - math.max(close, open)
pzLowerWick = math.min(close, open) - low
pzRange = math.max(high - low, syminfo.mintick)

pzBullPin = pzLowerWick > pzBody * 2.0 and pzUpperWick < pzBody * 0.7 and close > open and pzRange > ta.atr(14) * 0.5
pzBearPin = pzUpperWick > pzBody * 2.0 and pzLowerWick < pzBody * 0.7 and close < open and pzRange > ta.atr(14) * 0.5

pzPrevBody = math.abs(close[1] - open[1])

pzBullEngulf = close[1] < open[1] and close > open and close > open[1] and open < close[1] and pzBody > pzPrevBody * 1.2
pzBearEngulf = close[1] > open[1] and close < open and close < open[1] and open > close[1] and pzBody > pzPrevBody * 1.2

pzCandleBull = pzBullPin ? 3.0 : pzBullEngulf ? 2.5 : 0.0
pzCandleBear = pzBearPin ? 3.0 : pzBearEngulf ? 2.5 : 0.0

pzVolSma = ta.sma(volume, 20)
pzVolPower = volume / math.max(pzVolSma, 1.0)

pzVolBull = pzVolPower > pzVolMult and close > open
pzVolBear = pzVolPower > pzVolMult and close < open

pzPivotFibBull = not na(pzLastSup) and pzInFib and close > pzLastSup
pzPivotFibBear = not na(pzLastRes) and pzInFib and close < pzLastRes

pzBullScore =
     (pzPivotFibBull ? 3.0 : 0.0) +
     pzCandleBull +
     (pzVolBull ? math.min(pzVolPower, 5.0) : 0.0) +
     (pzStrongSup ? 2.0 : 0.0)

pzBearScore =
     (pzPivotFibBear ? 3.0 : 0.0) +
     pzCandleBear +
     (pzVolBear ? math.min(pzVolPower, 5.0) : 0.0) +
     (pzStrongRes ? 2.0 : 0.0)

pzScore =
     pzBullScore > pzBearScore ? math.min(pzBullScore, 10.0) :
     pzBearScore > pzBullScore ? -math.min(pzBearScore, 10.0) :
     0.0

powerZonePct = scoreToPct(pzScore)

powerZoneBull = powerZonePct >= 60
powerZoneBear = powerZonePct <= 40

pzRawLong = pzBullScore >= 5.0
pzRawShort = pzBearScore >= 5.0

var int pzLastLongBar = na
var int pzLastShortBar = na

powerZoneLongEvent = pzRawLong and not pzRawLong[1] and (na(pzLastLongBar) or bar_index - pzLastLongBar > pzCooldown)
powerZoneShortEvent = pzRawShort and not pzRawShort[1] and (na(pzLastShortBar) or bar_index - pzLastShortBar > pzCooldown)

if powerZoneLongEvent
    pzLastLongBar := bar_index

if powerZoneShortEvent
    pzLastShortBar := bar_index

//━━━━━━━━━━━━━━━━━━━
// MOTOR 11 — LIQUIDITY / BOS QUALITY
//━━━━━━━━━━━━━━━━━━━
liqLen = input.int(20, "Liquidity Lookback", group="Liquidity")
liqAtrMult = input.float(0.25, "Sweep ATR Sensitivity", step=0.05, group="Liquidity")

liqAtr = ta.atr(14)

prevHighLiq = ta.highest(high[1], liqLen)
prevLowLiq  = ta.lowest(low[1], liqLen)

sweepHigh = high > prevHighLiq and close < prevHighLiq
sweepLow  = low < prevLowLiq and close > prevLowLiq

bosUpLiq = close > prevHighLiq
bosDnLiq = close < prevLowLiq

liqRejectBull = sweepLow and (close - low) > liqAtr * liqAtrMult
liqRejectBear = sweepHigh and (high - close) > liqAtr * liqAtrMult

liqScore =
     liqRejectBull ? 7.0 :
     liqRejectBear ? -7.0 :
     bosUpLiq ? 4.0 :
     bosDnLiq ? -4.0 :
     0.0

liqPct = scoreToPct(clamp(liqScore, -10.0, 10.0))

liqBull = liqPct >= 60
liqBear = liqPct <= 40

//━━━━━━━━━━━━━━━━━━━
// MOTOR 12 — VOLUME DELTA / CVD FUSION
//━━━━━━━━━━━━━━━━━━━
cvdMergeLen = input.int(5, "CVD Candle Merge", group="CVD / Delta")
cvdSmooth   = input.int(10, "CVD Smooth", group="CVD / Delta")
cvdTrendLen = input.int(20, "CVD Trend Length", group="CVD / Delta")

mOpenCvd = open[cvdMergeLen - 1]
mCloseCvd = close

float mVolCvd = 0.0
for iCvd = 0 to cvdMergeLen - 1
    mVolCvd += volume[iCvd]

volDeltaCvd = mCloseCvd > mOpenCvd ? mVolCvd : mCloseCvd < mOpenCvd ? -mVolCvd : 0.0
deltaEmaCvd = ta.ema(volDeltaCvd, cvdSmooth)

cvdRaw = ta.cum(volDeltaCvd)
cvdTrend = ta.ema(cvdRaw, cvdTrendLen)

obvStepCvd = mCloseCvd > nz(mCloseCvd[1]) ? mVolCvd : mCloseCvd < nz(mCloseCvd[1]) ? -mVolCvd : 0.0
obvCvd = ta.cum(obvStepCvd)
obvTrendCvd = ta.ema(obvCvd, cvdTrendLen)

normCvd(srcC, lenC) =>
    hhC = ta.highest(srcC, lenC)
    llC = ta.lowest(srcC, lenC)
    hhC == llC ? 0.5 : (srcC - llC) / (hhC - llC)

dCvd = normCvd(deltaEmaCvd, 100)
cCvd = normCvd(cvdTrend, 100)
oCvd = normCvd(obvTrendCvd, 100)

fusionCvd = (dCvd + cCvd + oCvd) / 3.0
fusionCvdEma = ta.ema(fusionCvd, cvdSmooth)

cvdScore = clamp((fusionCvd - 0.5) * 20.0, -10.0, 10.0)
cvdPct = scoreToPct(cvdScore)

cvdBull = cvdPct >= 60
cvdBear = cvdPct <= 40

//━━━━━━━━━━━━━━━━━━━
// MOTOR 13 — HARMONIC / ABCD FAMILY BASIC
//━━━━━━━━━━━━━━━━━━━
harmTol = input.float(0.12, "Harmonic Ratio Tolerance", step=0.01, group="Harmonic")

harmPct = 50.0
harmName = "-"

if stSz >= 5
    h0 = stSz - 5
    h1 = stSz - 4
    h2 = stSz - 3
    h3 = stSz - 2
    h4 = stSz - 1

    hp0 = array.get(stPrice, h0)
    hp1 = array.get(stPrice, h1)
    hp2 = array.get(stPrice, h2)
    hp3 = array.get(stPrice, h3)
    hp4 = array.get(stPrice, h4)

    ht0 = array.get(stType, h0)
    ht1 = array.get(stType, h1)
    ht2 = array.get(stType, h2)
    ht3 = array.get(stType, h3)
    ht4 = array.get(stType, h4)

    xa = math.abs(hp1 - hp0)
    ab = math.abs(hp2 - hp1)
    bc = math.abs(hp3 - hp2)
    cd = math.abs(hp4 - hp3)

    abRatio = xa > 0 ? ab / xa : na
    bcRatio = ab > 0 ? bc / ab : na
    cdRatio = bc > 0 ? cd / bc : na

    isBullABCD = ht1 == -1 and ht2 == 1 and ht3 == -1 and ht4 == 1 and cdRatio >= 0.88 and cdRatio <= 1.272 + harmTol
    isBearABCD = ht1 == 1 and ht2 == -1 and ht3 == 1 and ht4 == -1 and cdRatio >= 0.88 and cdRatio <= 1.272 + harmTol

    isGartleyLike = not na(abRatio) and abRatio >= 0.55 and abRatio <= 0.70 and not na(bcRatio) and bcRatio >= 0.382 and bcRatio <= 0.886
    isBatLike = not na(abRatio) and abRatio >= 0.382 and abRatio <= 0.55 and not na(bcRatio) and bcRatio >= 0.382 and bcRatio <= 0.886
    isButterflyLike = not na(abRatio) and abRatio >= 0.70 and abRatio <= 0.886 and not na(cdRatio) and cdRatio >= 1.272

    if isBullABCD or isBearABCD
        harmPct := isBullABCD ? 64.0 : 36.0
        harmName := "ABCD"

    if isGartleyLike
        harmPct := harmPct > 50 ? 66.0 : harmPct < 50 ? 34.0 : harmPct
        harmName := "GARTLEY?"

    if isBatLike
        harmPct := harmPct > 50 ? 65.0 : harmPct < 50 ? 35.0 : harmPct
        harmName := "BAT?"

    if isButterflyLike
        harmPct := harmPct > 50 ? 67.0 : harmPct < 50 ? 33.0 : harmPct
        harmName := "BUTTERFLY?"

harmBull = harmPct >= 60
harmBear = harmPct <= 40

//━━━━━━━━━━━━━━━━━━━
// MOTOR 14 — VOLATILITY / ATR REGIME
//━━━━━━━━━━━━━━━━━━━
volRegLen = input.int(34, "Volatility Regime Length", group="Volatility")
atrReg = ta.atr(14)
atrRegAvg = ta.ema(atrReg, volRegLen)
atrRegRatio = atrReg / math.max(atrRegAvg, syminfo.mintick)

volExpand = atrRegRatio > 1.10
volContract = atrRegRatio < 0.90

volTrendDir = close > ema55 ? 1.0 : close < ema55 ? -1.0 : 0.0

volScore =
     volExpand and volTrendDir > 0 ? 5.0 :
     volExpand and volTrendDir < 0 ? -5.0 :
     volContract ? 0.0 :
     volTrendDir * 2.0

volPct = scoreToPct(clamp(volScore, -10.0, 10.0))

volBull = volPct >= 60
volBear = volPct <= 40

//━━━━━━━━━━━━━━━━━━━
// BÖLÜM 3 GEÇİCİ SKOR
//━━━━━━━━━━━━━━━━━━━
wPZ   = input.float(1.20, "Power Zone Weight", step=0.1, group="Weights")
wLIQ  = input.float(1.10, "Liquidity Weight", step=0.1, group="Weights")
wCVD  = input.float(1.10, "CVD Delta Weight", step=0.1, group="Weights")
wHARM = input.float(0.75, "Harmonic Weight", step=0.1, group="Weights")
wVOL  = input.float(0.80, "Volatility Weight", step=0.1, group="Weights")

part3WeightSum = wPZ + wLIQ + wCVD + wHARM + wVOL

part3Pct =
     (powerZonePct * wPZ +
      liqPct       * wLIQ +
      cvdPct       * wCVD +
      harmPct      * wHARM +
      volPct       * wVOL) / part3WeightSum

part3Pct := clamp(part3Pct, 0.0, 100.0)

//━━━━━━━━━━━━━━━━━━━
// MOTOR 15 — FIBONACCI PULLBACK QUALITY
// Sağlıklı düzeltme yapan sinyale ekstra kalite verir.
// Motor mantığını bozmaz; sadece Final Matrix içine ayrı ağırlıkla katılır.
//━━━━━━━━━━━━━━━━━━━
useFibPB      = input.bool(true, "Use Fibonacci Pullback Quality", group="Fibonacci Pullback")
fibShowZone   = input.bool(true, "Show Active Fib Pullback Zone", group="Fibonacci Pullback")
fibMinRetr    = input.float(0.382, "Min Healthy Retracement", step=0.001, group="Fibonacci Pullback")
fibMaxRetr    = input.float(0.886, "Max Healthy Retracement", step=0.001, group="Fibonacci Pullback")
fibBonusNeed  = input.float(5.0, "Fib Agreement Bonus Need", step=0.5, group="Fibonacci Pullback")
wFIBPB        = input.float(0.95, "Fibonacci Pullback Weight", step=0.1, group="Weights")

float fibImpLow = na
float fibImpHigh = na
int fibImpDir = 0
float fibRetr = na
float fibPbScore = 0.0
string fibPbZoneTxt = "-"

if stSz >= 2
    _lastIdx = stSz - 1
    _prevIdx = stSz - 2
    _lastT = array.get(stType, _lastIdx)
    _prevT = array.get(stType, _prevIdx)
    _lastP = array.get(stPrice, _lastIdx)
    _prevP = array.get(stPrice, _prevIdx)

    // Son onaylı hareket dipten tepeye ise: bullish impuls, geri çekilme aranır.
    if _prevT == -1 and _lastT == 1 and _lastP > _prevP
        fibImpDir := 1
        fibImpLow := _prevP
        fibImpHigh := _lastP
        _rng = math.max(fibImpHigh - fibImpLow, syminfo.mintick)
        fibRetr := (fibImpHigh - close) / _rng

    // Son onaylı hareket tepeden dibe ise: bearish impuls, yukarı düzeltme aranır.
    if _prevT == 1 and _lastT == -1 and _prevP > _lastP
        fibImpDir := -1
        fibImpHigh := _prevP
        fibImpLow := _lastP
        _rng = math.max(fibImpHigh - fibImpLow, syminfo.mintick)
        fibRetr := (close - fibImpLow) / _rng

fibInHealthyZone = useFibPB and fibImpDir != 0 and not na(fibRetr) and fibRetr >= fibMinRetr and fibRetr <= fibMaxRetr
fibDeepInvalid   = useFibPB and fibImpDir != 0 and not na(fibRetr) and fibRetr > fibMaxRetr

if fibInHealthyZone
    if fibRetr >= 0.786
        fibPbScore := 10.0
        fibPbZoneTxt := "0.786-0.886"
    else if fibRetr >= 0.618
        fibPbScore := 8.0
        fibPbZoneTxt := "0.618-0.786"
    else if fibRetr >= 0.500
        fibPbScore := 5.0
        fibPbZoneTxt := "0.500-0.618"
    else
        fibPbScore := 3.0
        fibPbZoneTxt := "0.382-0.500"
else if fibDeepInvalid
    fibPbScore := -3.0
    fibPbZoneTxt := "DEEP"

// Tepki teyidi: düzeltme bölgesinde yönlü mum / küçük momentum dönüşü.
fibBullReaction = fibImpDir == 1 and fibInHealthyZone and (close > open or close > close[1] or rsiAccSm > 0)
fibBearReaction = fibImpDir == -1 and fibInHealthyZone and (close < open or close < close[1] or rsiAccSm < 0)

fibPbDirectionalScore =
     fibBullReaction ? fibPbScore :
     fibBearReaction ? -fibPbScore :
     fibDeepInvalid and fibImpDir == 1 ? -3.0 :
     fibDeepInvalid and fibImpDir == -1 ? 3.0 :
     0.0

fibPbPct = useFibPB ? scoreToPct(clamp(fibPbDirectionalScore, -10.0, 10.0)) : 50.0
fibPbBull = fibPbPct >= 60
fibPbBear = fibPbPct <= 40
fibPbBonusBull = fibBullReaction and fibPbScore >= fibBonusNeed
fibPbBonusBear = fibBearReaction and fibPbScore >= fibBonusNeed

fib382 = fibImpDir == 1 ? fibImpHigh - (fibImpHigh - fibImpLow) * 0.382 : fibImpDir == -1 ? fibImpLow + (fibImpHigh - fibImpLow) * 0.382 : na
fib500 = fibImpDir == 1 ? fibImpHigh - (fibImpHigh - fibImpLow) * 0.500 : fibImpDir == -1 ? fibImpLow + (fibImpHigh - fibImpLow) * 0.500 : na
fib618 = fibImpDir == 1 ? fibImpHigh - (fibImpHigh - fibImpLow) * 0.618 : fibImpDir == -1 ? fibImpLow + (fibImpHigh - fibImpLow) * 0.618 : na
fib786 = fibImpDir == 1 ? fibImpHigh - (fibImpHigh - fibImpLow) * 0.786 : fibImpDir == -1 ? fibImpLow + (fibImpHigh - fibImpLow) * 0.786 : na
fib886 = fibImpDir == 1 ? fibImpHigh - (fibImpHigh - fibImpLow) * 0.886 : fibImpDir == -1 ? fibImpLow + (fibImpHigh - fibImpLow) * 0.886 : na

//━━━━━━━━━━━━━━━━━━━
// BÖLÜM 4/4
// FINAL MATRIX + GÖRSELLER + PANEL + SİNYALLER
//━━━━━━━━━━━━━━━━━━━

//━━━━━━━━━━━━━━━━━━━
// FINAL WEIGHTS
//━━━━━━━━━━━━━━━━━━━
totalWeight =
     coreWeightSum +
     part2WeightSum +
     part3WeightSum +
     (useFibPB ? wFIBPB : 0.0)

finalPct =
     (corePct  * coreWeightSum +
      part2Pct * part2WeightSum +
      part3Pct * part3WeightSum +
      (useFibPB ? fibPbPct * wFIBPB : 0.0)) / totalWeight

finalPct := clamp(finalPct, 0.0, 100.0)

finalAvgLen = input.int(55, "Final AVG Length", minval=5, group="Final Matrix")
finalAvg = ta.ema(finalPct, finalAvgLen)
finalEdge = finalPct - finalAvg

finalBull = finalPct >= bullTh
finalBear = finalPct <= bearTh
finalStrongBull = finalPct >= strongTh
finalStrongBear = finalPct <= 100.0 - strongTh

//━━━━━━━━━━━━━━━━━━━
// MOTOR 16 — NET FORCE ATR ENGINE
// GERÇEK FARK BURADA:
// Tüm motor yüzdeleri 50 merkezinden çıkarılır.
// Örnek: +10 +40 -5 = +45
// Sonra işaret korunarak sqrt(abs(toplam)) alınır.
// Son olarak ATR ile çarpılıp AL/SAT bulutu ve eşik üretilir.
//━━━━━━━━━━━━━━━━━━━
useNetForceATR  = input.bool(true, "Use Net Force ATR Gate", group="Net Force ATR")
forceAtrLen     = input.int(14, "Force ATR Length", minval=1, group="Net Force ATR")
forceBasisLen   = input.int(34, "Force Basis EMA", minval=1, group="Net Force ATR")
forceAtrMult    = input.float(0.35, "Force ATR Mult", step=0.05, group="Net Force ATR")
forceCloudMult  = input.float(1.25, "Force Cloud Width", step=0.05, group="Net Force ATR")
forceSignalNeed = input.float(6.00, "Buy/Sell Root Threshold", step=0.25, group="Net Force ATR")

netForceSum =
     (trendPct      - 50.0) +
     (gaePct        - 50.0) +
     (pvmPct        - 50.0) +
     (vetiPct       - 50.0) +
     (ichiPct       - 50.0) +
     (rsiStructPct  - 50.0) +
     (hapPct        - 50.0) +
     (flowPct       - 50.0) +
     (structurePct  - 50.0) +
     (oteStructPct  - 50.0) +
     (powerZonePct  - 50.0) +
     (liqPct        - 50.0) +
     (cvdPct        - 50.0) +
     (harmPct       - 50.0) +
     (volPct        - 50.0) +
     (fibPbPct      - 50.0)

netForceRoot =
     netForceSum > 0 ? math.sqrt(math.abs(netForceSum)) :
     netForceSum < 0 ? -math.sqrt(math.abs(netForceSum)) :
     0.0

forceAtr      = ta.atr(forceAtrLen)
forceBasis    = ta.ema(close, forceBasisLen)
forceDistance = math.abs(netForceRoot) * forceAtr * forceAtrMult

forceBullLine = forceBasis - forceDistance * forceCloudMult
forceBearLine = forceBasis + forceDistance * forceCloudMult
forceMidLine  = forceBasis
forceCloudLine =
     netForceRoot >= forceSignalNeed ? forceBullLine :
     netForceRoot <= -forceSignalNeed ? forceBearLine :
     forceMidLine

forceBullOK = netForceRoot >= forceSignalNeed and close > forceCloudLine
forceBearOK = netForceRoot <= -forceSignalNeed and close < forceCloudLine

forcePctView = clamp(50.0 + netForceRoot * 5.0, 0.0, 100.0)

//━━━━━━━━━━━━━━━━━━━
// AGREEMENT MATRIX
//━━━━━━━━━━━━━━━━━━━
agreeBull =
     (trendPct >= 60 ? 1 : 0) +
     (gaeStrongBull ? 1 : 0) +
     (pvmBull ? 1 : 0) +
     (vetiBull ? 1 : 0) +
     (ichiBull ? 1 : 0) +
     (rsiStructBull ? 1 : 0) +
     (hapBull ? 1 : 0) +
     (flowBull ? 1 : 0) +
     (structureBull ? 1 : 0) +
     (oteBull ? 1 : 0) +
     (powerZoneBull ? 1 : 0) +
     (liqBull ? 1 : 0) +
     (cvdBull ? 1 : 0) +
     (harmBull ? 1 : 0) +
     (volBull ? 1 : 0) +
     (fibPbBonusBull ? 1 : 0)

agreeBear =
     (trendPct <= 40 ? 1 : 0) +
     (gaeStrongBear ? 1 : 0) +
     (pvmBear ? 1 : 0) +
     (vetiBear ? 1 : 0) +
     (ichiBear ? 1 : 0) +
     (rsiStructBear ? 1 : 0) +
     (hapBear ? 1 : 0) +
     (flowBear ? 1 : 0) +
     (structureBear ? 1 : 0) +
     (oteBear ? 1 : 0) +
     (powerZoneBear ? 1 : 0) +
     (liqBear ? 1 : 0) +
     (cvdBear ? 1 : 0) +
     (harmBear ? 1 : 0) +
     (volBear ? 1 : 0) +
     (fibPbBonusBear ? 1 : 0)

agreeDiff = agreeBull - agreeBear

//━━━━━━━━━━━━━━━━━━━
// SIGNAL RANK SYSTEM
//━━━━━━━━━━━━━━━━━━━
primeAgreeNeed = input.int(8, "Prime Agreement Need", minval=4, maxval=16, group="Signal Rank")
powerAgreeNeed = input.int(11, "Power Agreement Need", minval=6, maxval=16, group="Signal Rank")
eliteAgreeNeed = input.int(13, "Elite Agreement Need", minval=8, maxval=16, group="Signal Rank")

signalCooldown = input.int(12, "Signal Cooldown Bars", minval=1, group="Signal Rank")
useEdgeFilter = input.bool(true, "Use Edge Filter", group="Signal Rank")
minEdgePower  = input.float(0.0, "Min Edge Power", step=0.5, group="Signal Rank")

edgeBullOK = finalEdge > minEdgePower
edgeBearOK = finalEdge < -minEdgePower

var int lastLongSignalBar = na
var int lastShortSignalBar = na
var int signalState = 0

longCooldownOK = na(lastLongSignalBar) or bar_index - lastLongSignalBar > signalCooldown
shortCooldownOK = na(lastShortSignalBar) or bar_index - lastShortSignalBar > signalCooldown

rawLongSignal =
     barstate.isconfirmed and
     finalBull and
     agreeBull >= primeAgreeNeed and
     agreeBull > agreeBear and
     (not useEdgeFilter or edgeBullOK) and
     (not useNetForceATR or forceBullOK) and
     longCooldownOK and
     signalState != 1

rawShortSignal =
     barstate.isconfirmed and
     finalBear and
     agreeBear >= primeAgreeNeed and
     agreeBear > agreeBull and
     (not useEdgeFilter or edgeBearOK) and
     (not useNetForceATR or forceBearOK) and
     shortCooldownOK and
     signalState != -1

longRank =
     rawLongSignal and agreeBull >= eliteAgreeNeed and finalPct >= strongTh ? 3 :
     rawLongSignal and agreeBull >= powerAgreeNeed ? 2 :
     rawLongSignal ? 1 : 0

shortRank =
     rawShortSignal and agreeBear >= eliteAgreeNeed and finalPct <= 100.0 - strongTh ? 3 :
     rawShortSignal and agreeBear >= powerAgreeNeed ? 2 :
     rawShortSignal ? 1 : 0

primeLong  = longRank == 1
powerLong  = longRank == 2
eliteLong  = longRank == 3

primeShort = shortRank == 1
powerShort = shortRank == 2
eliteShort = shortRank == 3

if rawLongSignal
    signalState := 1
    lastLongSignalBar := bar_index

if rawShortSignal
    signalState := -1
    lastShortSignalBar := bar_index

exitLong = signalState == 1 and finalPct < 50
exitShort = signalState == -1 and finalPct > 50

if exitLong or exitShort
    signalState := 0


//━━━━━━━━━━━━━━━━━━━
// PROFESSIONAL CLEAN VISUAL LAYER
// Motor aynı kaldı. Sadece çizim/görsel katman sadeleştirildi.
//━━━━━━━━━━━━━━━━━━━

//━━━━━━━━ CLEAN VISUAL INPUTS
visMode = input.string("Clean", "Visual Mode", options=["Clean", "Full", "Minimal"], group="PRO Visual")
showRailPro     = input.bool(true, "Master Rail", group="PRO Visual")
showCloudPro    = input.bool(true, "Edge Cloud", group="PRO Visual")
showFlowPro     = input.bool(false, "Flow Core / OTE / TP", group="PRO Visual")
showStructPro   = input.bool(false, "Structure OTE / TP", group="PRO Visual")
showSignalsPro  = input.bool(true, "Main Signals", group="PRO Visual")
showMinorPro    = input.bool(false, "Minor Events: PZ / SQZ / Exit", group="PRO Visual")
showBadgePro    = input.bool(true, "Right Badge", group="PRO Visual")
showMiniPanel   = input.bool(true, "Compact Panel", group="PRO Visual")
showBarsPro     = input.bool(true, "Professional Candle Tint", group="PRO Visual")

proTranspCloud  = input.int(88, "Cloud Transparency", minval=70, maxval=98, group="PRO Visual")
proLineWidth    = input.int(3, "Rail Width", minval=1, maxval=6, group="PRO Visual")

isFull    = visMode == "Full"
isMinimal = visMode == "Minimal"
isClean   = visMode == "Clean"

//━━━━━━━━ MASTER RAIL
railAtrLen = input.int(14, "Rail ATR Length", group="Visual Rail")
railBasisLen = input.int(34, "Rail Basis EMA", group="Visual Rail")
railMultBase = input.float(2.4, "Rail Base Mult", step=0.1, group="Visual Rail")

railAtr = ta.atr(railAtrLen)
railBasis = ta.ema(close, railBasisLen)

directionalPower =
     signalState == 1 ? finalPct :
     signalState == -1 ? 100.0 - finalPct :
     finalPct >= 50 ? finalPct : 100.0 - finalPct

dynamicRailMult =
     directionalPower >= 80 ? railMultBase * 1.12 :
     directionalPower >= 65 ? railMultBase :
     railMultBase * 0.90

var int railDir = 0
var float masterRail = na

if rawLongSignal
    railDir := 1
    masterRail := railBasis - railAtr * dynamicRailMult

if rawShortSignal
    railDir := -1
    masterRail := railBasis + railAtr * dynamicRailMult

if railDir == 1
    masterRail := math.max(nz(masterRail[1], railBasis - railAtr * dynamicRailMult), railBasis - railAtr * dynamicRailMult)

if railDir == -1
    masterRail := math.min(nz(masterRail[1], railBasis + railAtr * dynamicRailMult), railBasis + railAtr * dynamicRailMult)

railColor =
     railDir == 1 ? color.new(bullC, 0) :
     railDir == -1 ? color.new(bearC, 0) :
     color.new(midC, 25)

railStrong = finalStrongBull or finalStrongBear or powerLong or powerShort or eliteLong or eliteShort

plot(showRailPro and not railStrong ? masterRail : na, "OMEGA Master Rail", color=railColor, linewidth=3, style=plot.style_linebr)
plot(showRailPro and railStrong ? masterRail : na, "OMEGA Strong Rail", color=railColor, linewidth=5, style=plot.style_linebr)

//━━━━━━━━ NET FORCE ATR CLOUD
cloudBase = forceMidLine
cloudLine = forceCloudLine
cloudColor = netForceRoot >= forceSignalNeed ? color.new(bullC, proTranspCloud) : netForceRoot <= -forceSignalNeed ? color.new(bearC, proTranspCloud) : color.new(midC, 92)

pCloudBase = plot(showCloudPro and not isMinimal ? cloudBase : na, "OMEGA Net Force Base", color=color.new(midC, 100))
pCloudLine = plot(showCloudPro and not isMinimal ? cloudLine : na, "OMEGA Net Force ATR Cloud", color=color.new(midC, 100))
fill(pCloudBase, pCloudLine, color=showCloudPro and not isMinimal ? cloudColor : na, title="OMEGA Net Force ATR Cloud")
plot(showCloudPro and isFull ? forceBullLine : na, "Force Bull Threshold", color=color.new(bullC, 70), linewidth=1, style=plot.style_linebr)
plot(showCloudPro and isFull ? forceBearLine : na, "Force Bear Threshold", color=color.new(bearC, 70), linewidth=1, style=plot.style_linebr)

//━━━━━━━━ OPTIONAL FLOW / OTE
flowCol =
     regBull ? bullC :
     regBear ? bearC :
     midC

pRegCore = plot((showFlowPro or isFull) and not isMinimal ? regCore : na, "Flow Core", color=color.new(flowCol, 15), linewidth=2)
pFlowOTE = plot((showFlowPro or isFull) and not isMinimal ? flowOTE : na, "Flow OTE", color=color.new(goldC, 30), linewidth=1, style=plot.style_linebr)
pFlowTP  = plot((showFlowPro or isFull) and not isMinimal ? flowTP : na, "Flow TP", color=color.new(aquaC, 35), linewidth=1, style=plot.style_linebr)
fill(pFlowOTE, pRegCore, color=(showFlowPro or isFull) and not isMinimal ? color.new(flowCol, 92) : na, title="Flow Zone")

plot((showStructPro or isFull) and not isMinimal ? activeOTE : na, "Structure OTE 0.886", color=color.new(goldC, 15), linewidth=2, style=plot.style_linebr)
plot((showStructPro or isFull) and not isMinimal ? activeTP : na, "Structure Target 0.618", color=color.new(aquaC, 25), linewidth=2, style=plot.style_linebr)

//━━━━━━━━ PROFESSIONAL CANDLE TINT
barColorFinal =
     finalPct >= 75 ? color.new(bullC, 35) :
     finalPct >= 62 ? color.new(bullC, 68) :
     finalPct <= 25 ? color.new(bearC, 35) :
     finalPct <= 38 ? color.new(bearC, 68) :
     hapSqueeze and isFull ? color.new(goldC, 72) :
     na

barcolor(showBarsPro ? barColorFinal : na)

//━━━━━━━━ CLEAN SIGNALS
// Pine plotshape text sabit olmak zorunda. Bu yüzden sinyaller ayrı ayrı çizilir.
plotshape(showSignalsPro and primeLong,  title="OMEGA Prime Long",  style=shape.triangleup,   location=location.belowbar, color=bullC, text="L",  textcolor=color.white, size=size.tiny)
plotshape(showSignalsPro and powerLong,  title="OMEGA Power Long",  style=shape.triangleup,   location=location.belowbar, color=pwrC,  text="P",  textcolor=color.white, size=size.small)
plotshape(showSignalsPro and eliteLong,  title="OMEGA Elite Long",  style=shape.triangleup,   location=location.belowbar, color=goldC, text="E",  textcolor=color.black, size=size.normal)

plotshape(showSignalsPro and primeShort, title="OMEGA Prime Short", style=shape.triangledown, location=location.abovebar, color=bearC, text="S",  textcolor=color.white, size=size.tiny)
plotshape(showSignalsPro and powerShort, title="OMEGA Power Short", style=shape.triangledown, location=location.abovebar, color=pwrC,  text="P",  textcolor=color.white, size=size.small)
plotshape(showSignalsPro and eliteShort, title="OMEGA Elite Short", style=shape.triangledown, location=location.abovebar, color=goldC, text="E",  textcolor=color.black, size=size.normal)

plotshape(showMinorPro and powerZoneLongEvent and not rawLongSignal, title="PZ Long", style=shape.circle, location=location.belowbar, color=color.new(pwrC, 15), text="PZ", textcolor=color.white, size=size.tiny)
plotshape(showMinorPro and powerZoneShortEvent and not rawShortSignal, title="PZ Short", style=shape.circle, location=location.abovebar, color=color.new(pwrC, 15), text="PZ", textcolor=color.white, size=size.tiny)
plotshape(showMinorPro and hapRelease, title="SQZ Release", style=shape.diamond, location=location.bottom, color=color.new(goldC, 0), text="SQZ", textcolor=color.black, size=size.tiny)
plotshape(showMinorPro and exitLong, title="Exit Long", style=shape.xcross, location=location.abovebar, color=color.orange, size=size.tiny)
plotshape(showMinorPro and exitShort, title="Exit Short", style=shape.xcross, location=location.belowbar, color=color.orange, size=size.tiny)

//━━━━━━━━ RIGHT BADGE
var label badge = na

if showBadgePro and barstate.islast
    label.delete(badge)

    badgeState =
         eliteLong ? "ELITE LONG" :
         eliteShort ? "ELITE SHORT" :
         powerLong ? "POWER LONG" :
         powerShort ? "POWER SHORT" :
         finalStrongBull ? "STRONG BULL" :
         finalStrongBear ? "STRONG BEAR" :
         finalBull ? "BULL" :
         finalBear ? "BEAR" :
         "NEUTRAL"

    badgeCol =
         eliteLong or eliteShort ? goldC :
         powerLong or powerShort ? pwrC :
         finalBull or finalStrongBull ? bullC :
         finalBear or finalStrongBear ? bearC :
         midC

    edgeTxt = finalEdge >= 0 ? "+" + str.tostring(finalEdge, "#.0") : str.tostring(finalEdge, "#.0")

    badgeTxt =
         "Ω " + badgeState + "\n" +
         "Score " + str.tostring(finalPct, "#.0") + "%  Edge " + edgeTxt + "\n" +
         "Agree " + str.tostring(agreeBull) + " / " + str.tostring(agreeBear)

    badgeY =
         railDir == 1 ? low - ta.atr(14) * 0.8 :
         railDir == -1 ? high + ta.atr(14) * 0.8 :
         close

    badge := label.new(
         bar_index + 4,
         badgeY,
         badgeTxt,
         xloc=xloc.bar_index,
         style=label.style_label_left,
         color=color.new(badgeCol, 8),
         textcolor=color.black,
         size=size.small)

//━━━━━━━━ COMPACT PANEL
rowColorBull(v) =>
    v >= 60 ? bullC : v <= 40 ? bearC : midC

var table pan = table.new(position.top_right, 3, 11, border_width=1)

if showMiniPanel and barstate.islast
    stateTxt =
         eliteLong ? "ELITE LONG" :
         eliteShort ? "ELITE SHORT" :
         powerLong ? "POWER LONG" :
         powerShort ? "POWER SHORT" :
         finalStrongBull ? "STRONG BULL" :
         finalStrongBear ? "STRONG BEAR" :
         finalBull ? "BULL" :
         finalBear ? "BEAR" :
         "NEUTRAL"

    stateCol =
         eliteLong or eliteShort ? goldC :
         powerLong or powerShort ? pwrC :
         finalBull ? bullC :
         finalBear ? bearC :
         midC

    table.cell(pan, 0, 0, "Ω OMEGA", text_color=color.white, bgcolor=color.black)
    table.cell(pan, 1, 0, str.tostring(finalPct, "#.0") + "%", text_color=stateCol, bgcolor=color.black)
    table.cell(pan, 2, 0, stateTxt, text_color=stateCol, bgcolor=color.black)

    table.cell(pan, 0, 1, "AVG / EDGE", text_color=color.white)
    table.cell(pan, 1, 1, str.tostring(finalAvg, "#.0"), text_color=rowColorBull(finalAvg))
    table.cell(pan, 2, 1, (finalEdge >= 0 ? "+" : "") + str.tostring(finalEdge, "#.0"), text_color=finalEdge >= 0 ? bullC : bearC)

    table.cell(pan, 0, 2, "Core", text_color=color.white)
    table.cell(pan, 1, 2, str.tostring(corePct, "#.0"), text_color=rowColorBull(corePct))
    table.cell(pan, 2, 2, "Trend/GAE", text_color=midC)

    table.cell(pan, 0, 3, "Structure", text_color=color.white)
    table.cell(pan, 1, 3, str.tostring(part2Pct, "#.0"), text_color=rowColorBull(part2Pct))
    table.cell(pan, 2, 3, bosBull ? "BOS+" : bosBear ? "BOS-" : "-", text_color=bosBull ? bullC : bosBear ? bearC : midC)

    table.cell(pan, 0, 4, "Power", text_color=color.white)
    table.cell(pan, 1, 4, str.tostring(part3Pct, "#.0"), text_color=rowColorBull(part3Pct))
    table.cell(pan, 2, 4, powerZoneLongEvent ? "PZ+" : powerZoneShortEvent ? "PZ-" : harmName, text_color=powerZoneLongEvent ? bullC : powerZoneShortEvent ? bearC : midC)

    table.cell(pan, 0, 5, "GAE", text_color=color.white)
    table.cell(pan, 1, 5, str.tostring(gaeBullVotes) + "/4", text_color=gaeBullVotes >= 3 ? bullC : gaeBearVotes >= 3 ? bearC : midC)
    table.cell(pan, 2, 5, gaeStrongBull ? "BULL" : gaeStrongBear ? "BEAR" : "MIX", text_color=gaeStrongBull ? bullC : gaeStrongBear ? bearC : midC)

    table.cell(pan, 0, 6, "Flow", text_color=color.white)
    table.cell(pan, 1, 6, str.tostring(flowPct, "#.0"), text_color=rowColorBull(flowPct))
    table.cell(pan, 2, 6, regBull ? "UP" : regBear ? "DOWN" : "FLAT", text_color=regBull ? bullC : regBear ? bearC : midC)

    table.cell(pan, 0, 7, "Liquidity", text_color=color.white)
    table.cell(pan, 1, 7, str.tostring(liqPct, "#.0"), text_color=rowColorBull(liqPct))
    table.cell(pan, 2, 7, sweepLow ? "SWEEP L" : sweepHigh ? "SWEEP H" : "-", text_color=sweepLow ? bullC : sweepHigh ? bearC : midC)

    table.cell(pan, 0, 8, "Fib PB", text_color=color.white)
    table.cell(pan, 1, 8, str.tostring(fibPbPct, "#.0"), text_color=rowColorBull(fibPbPct))
    table.cell(pan, 2, 8, fibPbZoneTxt, text_color=fibPbBonusBull ? bullC : fibPbBonusBear ? bearC : midC)

    table.cell(pan, 0, 9, "Net Force", text_color=color.white)
    table.cell(pan, 1, 9, str.tostring(netForceRoot, "#.00"), text_color=netForceRoot >= 0 ? bullC : bearC)
    table.cell(pan, 2, 9, forceBullOK ? "BUY OK" : forceBearOK ? "SELL OK" : "WAIT", text_color=forceBullOK ? bullC : forceBearOK ? bearC : midC)

    table.cell(pan, 0, 10, "Agree B/S", text_color=color.white)
    table.cell(pan, 1, 10, str.tostring(agreeBull), text_color=bullC)
    table.cell(pan, 2, 10, str.tostring(agreeBear), text_color=bearC)

//━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━
alertcondition(primeLong, "OMEGA PRIME LONG", "OMEGA PRIME LONG")
alertcondition(primeShort, "OMEGA PRIME SHORT", "OMEGA PRIME SHORT")
alertcondition(powerLong, "OMEGA POWER LONG", "OMEGA POWER LONG")
alertcondition(powerShort, "OMEGA POWER SHORT", "OMEGA POWER SHORT")
alertcondition(eliteLong, "OMEGA ELITE LONG", "OMEGA ELITE LONG")
alertcondition(eliteShort, "OMEGA ELITE SHORT", "OMEGA ELITE SHORT")
alertcondition(hapRelease, "OMEGA HAP SQUEEZE RELEASE", "HAP SQUEEZE RELEASE")
alertcondition(powerZoneLongEvent, "OMEGA POWER ZONE LONG EVENT", "POWER ZONE LONG EVENT")
alertcondition(powerZoneShortEvent, "OMEGA POWER ZONE SHORT EVENT", "POWER ZONE SHORT EVENT")
alertcondition(forceBullOK and barstate.isconfirmed, "OMEGA NET FORCE BUY OK", "NET FORCE ATR BUY THRESHOLD OK")
alertcondition(forceBearOK and barstate.isconfirmed, "OMEGA NET FORCE SELL OK", "NET FORCE ATR SELL THRESHOLD OK")
````

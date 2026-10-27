# CLEAN Combo Signal Edition

- url: https://www.tradingview.com/script/g6XYPa5y/
- type: indicator
- pine_id: PUB;09b29857a2ef496d9c700ef3b1705aa9
- version: 1.0

## Description

Hauptfunktionen

Der Indikator erkennt mögliche Einstiege durch:

BUY-Signale

Bounce aus einer Demand-Zone
Reclaim über EMA 21
EMA 5 / EMA 21 Bull-Cross
Breakout über eine Supply-Zone
Bestätigung durch SMA 9 Momentum

SELL-Signale

Ablehnung an einer Supply-Zone
Bruch einer Demand-Zone
EMA 5 / EMA 21 Bear-Cross
Bestätigung durch SMA 9 Momentum
Enthaltene Filter

Der Indikator nutzt mehrere Filter, um schlechte Signale zu reduzieren:

SMA 9 Momentum-Filter
Volumenfilter
ADX-Trendstärke
Seitwärtsphasen-Blocker
EMA 200 Trendfilter
HTF-Bestätigung
BUY nahe Supply blockieren
SELL nahe Demand optional blockieren
BUY/SELL Cooldown, um doppelte Signale im gleichen Impuls zu vermeiden
Zonen-Logik

Demand- und Supply-Zonen werden automatisch anhand von Pivot-Strukturen und erhöhtem Volumen erkannt.

Grüne Zonen zeigen mögliche Käuferbereiche.
Rote Zonen zeigen mögliche Verkäuferbereiche.

BUY-Signale werden bevorzugt in oder nahe Demand-Zonen gesucht.
SELL-Signale werden bevorzugt in oder nahe Supply-Zonen oder nach Bruch einer Demand-Zone gesucht.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Ford_Noxx

//@version=6
indicator("CLEAN Combo — Signal Edition", overlay=true, max_boxes_count=100, max_labels_count=100)


// ============================================================================
// === INPUTS =================================================================
// ============================================================================

grpEMA = "EMAs"
emaFastLen  = input.int(5,   "EMA Fast (5)",   minval=1, group=grpEMA)
emaMidLen   = input.int(21,  "EMA Mid (21)",   minval=1, group=grpEMA)
emaSlowLen  = input.int(200, "EMA Slow (200)", minval=1, group=grpEMA)
smaLen      = input.int(9,   "SMA (9)",        minval=1, group=grpEMA)
showEMAs    = input.bool(true, "EMAs anzeigen", group=grpEMA)

grpRSI = "RSI"
rsiLen    = input.int(14, "RSI Länge",      minval=2, group=grpRSI)
rsiSigLen = input.int(7,  "RSI Signal EMA", minval=1, group=grpRSI)

grpZone = "Demand / Supply Zonen"
useZones    = input.bool(true,  "Zonen aktiv",          group=grpZone)
showZones   = input.bool(true,  "Zonen anzeigen",        group=grpZone)
pivotLen    = input.int(5,      "Pivot Länge",           minval=2, maxval=20,  group=grpZone)
zoneAtrMult = input.float(0.6,  "Zonenbreite (ATR ×)",   minval=0.1, step=0.05, group=grpZone)
zoneDistAtr = input.float(1.5,  "Max. Abstand zur Zone", minval=0.5, step=0.1,  group=grpZone)
zoneVolMult = input.float(1.2,  "Min. Volumen (× SMA)",  minval=0.5, step=0.1,  group=grpZone)
maxZones    = input.int(5,      "Max. Zonen pro Seite",  minval=1, maxval=15,   group=grpZone)

grpPOC = "POC — Point of Control"
usePOC      = input.bool(true,  "POC Filter aktiv",          group=grpPOC,
     tooltip="POC = Preisniveau mit dem meisten gehandelten Volumen. Wirkt als Magnet, Support oder Widerstand.")
showPOC     = input.bool(true,  "POC Linie anzeigen",        group=grpPOC)
pocLen      = input.int(50,     "POC Lookback (Kerzen)",     minval=10, maxval=500, group=grpPOC,
     tooltip="Wie viele Kerzen für die POC-Berechnung. 50 = kurzfristiger POC, 200 = langfristiger POC.")
pocBands    = input.float(0.3,  "POC Widerstand/Support Abstand (ATR ×)", minval=0.1, step=0.05, group=grpPOC,
     tooltip="Wie nah muss Preis am POC sein damit er als Widerstand/Support gilt.")
pocColor    = input.color(color.new(#FFA000, 0), "POC Linienfarbe", group=grpPOC)

grpHTF = "HTF Filter"
useHTF = input.bool(true,      "HTF Filter aktiv", group=grpHTF)
htfTF  = input.timeframe("60", "HTF Timeframe",    group=grpHTF)

grpSig = "Signal Einstellungen"
rrRatio   = input.float(2.0, "Risk:Reward Ratio",     minval=1.0, maxval=5.0, step=0.1, group=grpSig)
cooldown  = input.int(8,     "Cooldown Kerzen",        minval=1, maxval=50,    group=grpSig)
showTP_SL = input.bool(true, "TP/SL Linien anzeigen", group=grpSig)
showReason = input.bool(true, "Signal-Grund anzeigen", group=grpSig)

grpHMM = "Regime Filter (Hurst)"
useRegime  = input.bool(true, "Chop-Filter aktiv",  group=grpHMM,
     tooltip="Blockiert Signale wenn Markt seitwärts läuft (Hurst < 0.48 + ADX < 18)")
hurstLen   = input.int(14,    "Hurst Lookback",     minval=5, group=grpHMM)
// showRegime entfernt — kein Hintergrund mehr

grpDisplay = "Farben & Anzeige"
buyColor    = input.color(#00E676, "BUY Farbe",    group=grpDisplay)
sellColor   = input.color(#FF1744, "SELL Farbe",   group=grpDisplay)
demandColor = input.color(#00897B, "Demand Zone",  group=grpDisplay)
supplyColor = input.color(#C62828, "Supply Zone",  group=grpDisplay)
showTable   = input.bool(true, "Info-Box anzeigen", group=grpDisplay)
tablePos    = input.string("Oben Rechts", "Info-Box Position",
     options=["Oben Rechts","Unten Rechts","Oben Links","Unten Links","Mitte Rechts"],
     group=grpDisplay)


// ============================================================================
// === BASISINDIKATOREN =======================================================
// ============================================================================
emaFast = ta.ema(close, emaFastLen)
emaMid  = ta.ema(close, emaMidLen)
emaSlow = ta.ema(close, emaSlowLen)
sma9    = ta.sma(close, smaLen)
rsi     = ta.rsi(close, rsiLen)
rsiSig  = ta.ema(rsi, rsiSigLen)
atr     = ta.atr(14)
volSma  = ta.sma(volume, 20)
[plusDI, minusDI, adxVal] = ta.dmi(14, 14)

emaFastUp = emaFast > emaFast[1]
emaFastDn = emaFast < emaFast[1]
bullStack = emaFast > emaMid and emaMid > emaSlow
bearStack = emaFast < emaMid and emaMid < emaSlow


// ============================================================================
// === POC — POINT OF CONTROL (Volumen-Profil Näherung) =======================
// Echter Ansatz: Teilt den Preisbereich in Buckets auf und summiert das
// Volumen pro Bucket. Der Bucket mit dem meisten Volumen = POC.
// Jede Kerze verteilt ihr Volumen anteilig auf die Buckets die sie berührt.
// Das ist die bestmögliche POC-Näherung ohne Tick-Daten in Pine Script.
// ============================================================================
int   POC_BUCKETS = 20  // Preisbereich in 20 Levels aufteilen

// Preisbereich des Lookback-Fensters
pocHighest = ta.highest(high, pocLen)
pocLowest  = ta.lowest(low,   pocLen)
pocRange   = math.max(pocHighest - pocLowest, syminfo.mintick)
bucketSize = pocRange / POC_BUCKETS

// Volumen-Array für jeden Bucket akkumulieren
var float[] volBuckets = array.new<float>(POC_BUCKETS, 0.0)

// Jeden Bar: Reset und neu berechnen über den gesamten Lookback
if barstate.isconfirmed
    // Array leeren
    for b = 0 to POC_BUCKETS - 1
        array.set(volBuckets, b, 0.0)

    // Für jede Kerze im Fenster: Volumen auf Buckets verteilen
    for i = 0 to pocLen - 1
        candleHigh = high[i]
        candleLow  = low[i]
        candleVol  = volume[i]
        candleRange = math.max(candleHigh - candleLow, syminfo.mintick)

        // Welche Buckets berührt diese Kerze?
        for b = 0 to POC_BUCKETS - 1
            bucketLow  = pocLowest + b * bucketSize
            bucketHigh = bucketLow + bucketSize

            // Überlappung zwischen Kerze und Bucket
            overlapLow  = math.max(candleLow,  bucketLow)
            overlapHigh = math.min(candleHigh, bucketHigh)

            if overlapHigh > overlapLow
                // Anteil des Volumens proportional zur Überlappung
                overlap = overlapHigh - overlapLow
                volShare = candleVol * (overlap / candleRange)
                array.set(volBuckets, b, array.get(volBuckets, b) + volShare)

// Bucket mit höchstem Volumen finden = POC
pocBucketIdx = 0
pocBucketVol = 0.0
for b = 0 to POC_BUCKETS - 1
    bVol = array.get(volBuckets, b)
    if bVol > pocBucketVol
        pocBucketVol := bVol
        pocBucketIdx := b

// POC-Level = Mitte des stärksten Buckets
pocLevel = pocLowest + (pocBucketIdx + 0.5) * bucketSize

// VAH / VAL (Value Area High/Low): 70% des gesamten Volumens
// Alles innerhalb dieser Zone = "faire Bewertung"
totalVol = 0.0
for b = 0 to POC_BUCKETS - 1
    totalVol += array.get(volBuckets, b)

valueAreaVol = totalVol * 0.70
vaVol        = pocBucketVol
vahIdx       = pocBucketIdx
valIdx       = pocBucketIdx

// VAH: nach oben expandieren bis 70%
while vahIdx < POC_BUCKETS - 1 and vaVol < valueAreaVol
    vahIdx += 1
    vaVol  += array.get(volBuckets, vahIdx)

// VAL: nach unten expandieren falls noch nicht 70%
while valIdx > 0 and vaVol < valueAreaVol
    valIdx -= 1
    vaVol  += array.get(volBuckets, valIdx)

vahLevel = pocLowest + (vahIdx + 1) * bucketSize  // Value Area High
valLevel = pocLowest + valIdx * bucketSize          // Value Area Low

// POC Status: ist Preis nahe am POC?
pocDist     = math.abs(close - pocLevel)
nearPOC     = pocDist < atr * pocBands
pocAbove    = close > pocLevel   // Preis über POC → POC = Support
pocBelow    = close < pocLevel   // Preis unter POC → POC = Widerstand

// POC + VAH/VAL: nur die letzten ~10 Kerzen rechts anzeigen
// Kein extend.right, kein langer horizontaler Strich durch den Chart
// → sieht aus wie ein "schwebendes" Level, nicht wie eine Trennlinie
var line poc_line = na
var line vah_line = na
var line val_line = na
var label poc_label = na

if showPOC and barstate.islast
    line.delete(poc_line)
    line.delete(vah_line)
    line.delete(val_line)
    label.delete(poc_label)

    // POC: kurze gestrichelte Linie, nur rechts vom aktuellen Bar
    poc_line := line.new(bar_index - 3, pocLevel, bar_index + 8, pocLevel,
         color=color.new(pocColor, 20), width=1, style=line.style_dashed)

    // VAH/VAL: noch dezenter, kein Label
    vah_line := line.new(bar_index - 3, vahLevel, bar_index + 8, vahLevel,
         color=color.new(pocColor, 55), width=1, style=line.style_dotted)
    val_line := line.new(bar_index - 3, valLevel, bar_index + 8, valLevel,
         color=color.new(pocColor, 55), width=1, style=line.style_dotted)

    // POC Label: winzig, rechts neben der Linie
    poc_label := label.new(bar_index + 9, pocLevel,
         "POC",
         style=label.style_none,
         textcolor=color.new(pocColor, 30),
         size=size.tiny)


// ============================================================================
// === REGIME FILTER (Hurst) ==================================================
// ============================================================================
sumTR  = math.sum(ta.tr, hurstLen)
hHigh  = ta.highest(high, hurstLen)
hLow   = ta.lowest(low,   hurstLen)
chop   = 100.0 * math.log10(sumTR / math.max(hHigh - hLow, syminfo.mintick)) / math.log10(hurstLen)
hurst  = 1.0 - (chop / 100.0)

isTrending = hurst > 0.50 and adxVal >= 18
isChopping = hurst < 0.48 and adxVal < 18
regimeOk   = not useRegime or not isChopping

// Kein bgcolor — Chop-Status nur im Dashboard sichtbar, kein Chart-Overlay


// ============================================================================
// === HTF FILTER =============================================================
// ============================================================================
htfBull    = request.security(syminfo.tickerid, htfTF,
     ta.ema(close, emaFastLen) > ta.ema(close, emaMidLen) and ta.rsi(close, rsiLen) > 50,
     barmerge.gaps_off, barmerge.lookahead_off)
htfBear    = request.security(syminfo.tickerid, htfTF,
     ta.ema(close, emaFastLen) < ta.ema(close, emaMidLen) and ta.rsi(close, rsiLen) < 50,
     barmerge.gaps_off, barmerge.lookahead_off)
htfLongOk  = not useHTF or htfBull
htfShortOk = not useHTF or htfBear


// ============================================================================
// === DEMAND / SUPPLY ZONEN ==================================================
// ============================================================================
var box[]   demandBoxes = array.new<box>()
var float[] demandTops  = array.new<float>()
var float[] demandBots  = array.new<float>()
var box[]   supplyBoxes = array.new<box>()
var float[] supplyTops  = array.new<float>()
var float[] supplyBots  = array.new<float>()

pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow  = ta.pivotlow(low,   pivotLen, pivotLen)
pvtAtr    = atr[pivotLen]
pvtVol    = volume[pivotLen]
bigVol    = pvtVol > volSma[pivotLen] * zoneVolMult

if useZones and not na(pivotLow) and bigVol
    dTop = pivotLow + pvtAtr * zoneAtrMult
    dBot = pivotLow - pvtAtr * zoneAtrMult * 0.5
    b = box.new(bar_index - pivotLen, dTop, bar_index, dBot,
         bgcolor=color.new(demandColor, showZones ? 95 : 100),
         border_color=color.new(demandColor, showZones ? 60 : 100),
         extend=extend.right)
    array.push(demandBoxes, b)
    array.push(demandTops,  dTop)
    array.push(demandBots,  dBot)
    if array.size(demandBoxes) > maxZones
        box.delete(array.shift(demandBoxes))
        array.shift(demandTops)
        array.shift(demandBots)

if useZones and not na(pivotHigh) and bigVol
    sTop = pivotHigh + pvtAtr * zoneAtrMult * 0.5
    sBot = pivotHigh - pvtAtr * zoneAtrMult
    b = box.new(bar_index - pivotLen, sTop, bar_index, sBot,
         bgcolor=color.new(supplyColor, showZones ? 95 : 100),
         border_color=color.new(supplyColor, showZones ? 60 : 100),
         extend=extend.right)
    array.push(supplyBoxes, b)
    array.push(supplyTops,  sTop)
    array.push(supplyBots,  sBot)
    if array.size(supplyBoxes) > maxZones
        box.delete(array.shift(supplyBoxes))
        array.shift(supplyTops)
        array.shift(supplyBots)

// Zonen invalidieren
if array.size(demandBoxes) > 0
    i = array.size(demandBoxes) - 1
    while i >= 0
        if close < array.get(demandBots, i) - atr * 0.5
            box.delete(array.get(demandBoxes, i))
            array.remove(demandBoxes, i)
            array.remove(demandTops,  i)
            array.remove(demandBots,  i)
        i -= 1

if array.size(supplyBoxes) > 0
    i = array.size(supplyBoxes) - 1
    while i >= 0
        if close > array.get(supplyTops, i) + atr * 0.5
            box.delete(array.get(supplyBoxes, i))
            array.remove(supplyBoxes, i)
            array.remove(supplyTops,  i)
            array.remove(supplyBots,  i)
        i -= 1

// Zonen-Status
nearDemand = false
nearSupply = false
float slDemand = na
float slSupply = na

if array.size(demandBots) > 0
    for i = 0 to array.size(demandBots) - 1
        top = array.get(demandTops, i)
        bot = array.get(demandBots, i)
        if close >= bot - atr * zoneDistAtr and close <= top + atr * zoneDistAtr
            nearDemand := true
            slDemand   := bot - atr * 0.3

if array.size(supplyBots) > 0
    for i = 0 to array.size(supplyBots) - 1
        top = array.get(supplyTops, i)
        bot = array.get(supplyBots, i)
        if close >= bot - atr * zoneDistAtr and close <= top + atr * zoneDistAtr
            nearSupply := true
            slSupply   := top + atr * 0.3

// Supply direkt über Preis (Block für BUY)
supplyAbove = false
if array.size(supplyBots) > 0
    for i = 0 to array.size(supplyBots) - 1
        sBot = array.get(supplyBots, i)
        if sBot > close and sBot - close < atr * 1.5
            supplyAbove := true


// ============================================================================
// === SL / TP LEVEL ==========================================================
// ============================================================================
swingLow  = ta.lowest(low,   pivotLen * 2)
swingHigh = ta.highest(high, pivotLen * 2)
slLong    = not na(slDemand) ? slDemand  : swingLow  - atr * 0.3
slShort   = not na(slSupply) ? slSupply  : swingHigh + atr * 0.3


// ============================================================================
// === SIGNAL SETUPS ==========================================================
// ============================================================================

// A) Zone Bounce
setupA = nearDemand
     and close > open
     and emaFastUp
     and rsi > rsi[1]
     and rsi > 35 and rsi < 78
     and volume > volSma * 1.05
     and (htfLongOk or (adxVal > 15 and close > close[2]))
     // POC: BUY nur wenn POC als Support wirkt (Preis über POC ODER POC weit genug weg)
     and (not usePOC or pocAbove or pocDist > atr * 1.5)

// B) EMA Cross Long
setupB = ta.crossover(emaFast, emaMid)
     and close > emaSlow
     and rsi > 50 and rsi < 70
     and sma9 > sma9[1]
     and volume > volSma * 1.15
     and htfLongOk
     and adxVal > 18
     // POC: kein BUY wenn Preis direkt in POC-Widerstand läuft
     // Auch blockiert wenn Preis direkt unter VAH (Value Area High = Widerstand)
     and (not usePOC or not (pocBelow and nearPOC))
     and (not usePOC or not (math.abs(close - vahLevel) < atr * 0.5 and close < vahLevel))

// C) EMA200 Retest
ema200Rising = emaSlow > emaSlow[5]
wickLong     = close > open and (open - low) > (close - open) * 1.5
setupC = ema200Rising
     and math.abs(low - emaSlow) < atr * 0.5
     and close > emaSlow
     and (wickLong or close > open)
     and rsi > 45
     and htfLongOk
     and volume > volSma
     and (not usePOC or pocAbove or pocDist > atr * 1.0)

// F) Support Bounce (auch unter EMA200)
wickBody     = math.abs(close - open)
wickLower    = open > close ? close - low : open - low
isWickBounce = wickLower > wickBody * 1.2

setupF_raw = nearDemand
     and (close > open or isWickBounce)
     and rsi > rsi[2]
     and rsi > 30 and rsi < 70
     and volume > volSma
     and not nearSupply
     and (close > close[1] or low[1] < low[2])
     and adxVal < 35

// POC als Filter für setupF:
// Wenn POC als Widerstand direkt über Preis → kein Setup F
pocResistAbove = usePOC and pocBelow and pocLevel > close and pocLevel - close < atr * 1.0
setupF_clean   = setupF_raw and not supplyAbove and not pocResistAbove

// H) Momentum Shift Long (Früh)
emaFastSlopeUp = emaFast - emaFast[3] > 0 and (emaFast - emaFast[3]) > (emaFast[1] - emaFast[4])
priceAboveFast = close > emaFast and close > close[2]

setupH = emaFastSlopeUp
     and priceAboveFast
     and close > open
     and rsi > 50 and rsi > rsi[2]
     and volume > volSma * 1.15
     and not nearSupply
     and adxVal > 15
     and (nearDemand or close > emaSlow)
     // POC: BUY nur wenn POC Support gibt oder weit weg
     and (not usePOC or pocAbove or pocDist > atr * 1.5)

// D) Zone Reject Short
setupD = nearSupply
     and close < open
     and emaFastDn
     and ta.crossunder(rsi, rsiSig)
     and rsi < 60 and rsi > 25
     and volume > volSma * 1.1
     and htfShortOk
     and close < emaSlow
     // POC: SELL stärker wenn Preis unter POC oder nahe VAH (Widerstand)
     and (not usePOC or pocBelow or nearPOC or math.abs(close - vahLevel) < atr * 0.5)

// E) EMA Cross Short
setupE = ta.crossunder(emaFast, emaMid)
     and close < emaSlow
     and rsi < 50 and rsi > 30
     and sma9 < sma9[1]
     and volume > volSma * 1.15
     and htfShortOk
     and adxVal > 18
     and (not usePOC or not (pocAbove and nearPOC))

// G) Momentum Shift Short (Früh)
emaFastSlope  = emaFast - emaFast[3]
emaMidSlope   = emaMid  - emaMid[3]
momentumShift = emaFastSlope < 0 and emaFastSlope < emaMidSlope
priceUnder    = close < emaFast and close < emaMid

setupG = momentumShift
     and priceUnder
     and close < open
     and rsi < 50 and rsi < rsi[2]
     and volume > volSma * 1.2
     and not nearDemand
     and adxVal > 15
     and (nearSupply or close < emaSlow)
     // POC als Widerstandsbestätigung: SELL stärker wenn unter POC
     and (not usePOC or pocBelow or nearPOC)


// ============================================================================
// === R:R VALIDIERUNG ========================================================
// ============================================================================
riskLong  = close - slLong
riskShort = slShort - close
tpLong    = close + riskLong  * rrRatio
tpShort   = close - riskShort * rrRatio

rrValidLong  = riskLong  > atr * 0.3 and riskLong  < atr * 4.0
rrValidShort = riskShort > atr * 0.3 and riskShort < atr * 4.0

// POC als TP-Blocker:
// Wenn POC zwischen Entry und TP liegt → R:R wird faktisch schlechter → blockieren
// TP-Blocker: POC oder VAH liegt zwischen Entry und TP
// → reales R:R schlechter als eingestellt → Signal blockieren
pocBlocksLong  = usePOC and ((pocBelow and pocLevel > close and pocLevel < tpLong  and pocDist < riskLong * 0.8) or (vahLevel > close and vahLevel < tpLong  and math.abs(close - vahLevel) < riskLong * 0.8))
pocBlocksShort = usePOC and ((pocAbove and pocLevel < close and pocLevel > tpShort and pocDist < riskShort * 0.8) or (valLevel < close and valLevel > tpShort and math.abs(close - valLevel) < riskShort * 0.8))


// ============================================================================
// === COOLDOWN & FINAL SIGNAL ================================================
// ============================================================================
var int lastLongBar  = na
var int lastShortBar = na
coolLong  = na(lastLongBar)  or bar_index - lastLongBar  > cooldown
coolShort = na(lastShortBar) or bar_index - lastShortBar > cooldown

rawLong  = (setupA or setupB or setupC or setupF_clean or setupH)
     and regimeOk and rrValidLong  and coolLong
     and (not usePOC or not pocBlocksLong)

rawShort = (setupD or setupE or setupG)
     and regimeOk and rrValidShort and coolShort
     and (not usePOC or not pocBlocksShort)

longSignal  = rawLong  and not rawLong[1]
shortSignal = rawShort and not rawShort[1]

if longSignal
    lastLongBar  := bar_index
if shortSignal
    lastShortBar := bar_index

// POC-Kontext für Signal-Grund
// POC + Value Area Kontext für Label
inValueArea = close >= valLevel and close <= vahLevel
pocContext   = nearPOC ? (pocAbove ? " +POC Sup" : " ⚠POC Res") : inValueArea ? " VA" : ""

string longReason  = setupA ? "Zone Bounce" : setupB ? "EMA Cross" : setupC ? "EMA200 Retest" : setupF_clean ? "Support Bounce" : setupH ? "Momentum ↑" : ""
string shortReason = setupD ? "Zone Reject"  : setupE ? "EMA Cross ↓" : setupG ? "Momentum ↓" : ""


// ============================================================================
// === PLOTS ==================================================================
// ============================================================================
plot(showEMAs ? emaFast : na, "EMA 5",   color=color.new(color.lime,   0), linewidth=1)
plot(showEMAs ? emaMid  : na, "EMA 21",  color=color.new(color.orange, 0), linewidth=2)
plot(showEMAs ? emaSlow : na, "EMA 200", color=color.new(color.purple, 0), linewidth=2)
// SMA9 aus Chart entfernt — nur noch intern für Signalberechnung genutzt

p1 = plot(showEMAs ? emaFast : na, "EMA5 fill", display=display.none)
p2 = plot(showEMAs ? emaMid  : na, display=display.none)
fill(p1, p2, color=emaFast > emaMid ? color.new(color.lime, 97) : color.new(color.red, 97), title="EMA Ribbon")

// VAH/VAL als plot für fill (dezente Fläche im Hintergrund)
p_vah = plot(showPOC ? vahLevel : na, "VAH", color=color.new(pocColor, 85), linewidth=1, display=display.none)
p_val = plot(showPOC ? valLevel : na, "VAL", color=color.new(pocColor, 85), linewidth=1, display=display.none)
fill(p_vah, p_val, color=color.new(pocColor, 98), title="Value Area")

// Signal Labels — minimalistisch: kleiner Pfeil + dezenter Grund-Text darunter
// Kein farbiger Kasten — nur ein kleines Shape + Text in Kerzenfarbe
plotshape(longSignal,  title="BUY",  style=shape.triangleup,
     location=location.belowbar, color=color.new(buyColor, 20),
     size=size.tiny)

plotshape(shortSignal, title="SELL", style=shape.triangledown,
     location=location.abovebar, color=color.new(sellColor, 20),
     size=size.tiny)

// Grund-Text: klein, transparent, kein Kasten
if longSignal and showReason and barstate.isconfirmed
    label.new(bar_index, low - atr * 1.4,
         longReason + pocContext,
         style=label.style_none,
         textcolor=color.new(buyColor, 30),
         size=size.tiny)

if shortSignal and showReason and barstate.isconfirmed
    label.new(bar_index, high + atr * 1.4,
         shortReason + pocContext,
         style=label.style_none,
         textcolor=color.new(sellColor, 30),
         size=size.tiny)

// TP / SL Linien
var line sl_line = na
var line tp_line = na

if longSignal and showTP_SL and barstate.isconfirmed
    line.delete(sl_line)
    line.delete(tp_line)
    sl_line := line.new(bar_index, slLong,  bar_index + 30, slLong,
         color=color.new(sellColor, 30), width=1, style=line.style_dashed)
    tp_line := line.new(bar_index, tpLong,  bar_index + 30, tpLong,
         color=color.new(buyColor,  30), width=1, style=line.style_dashed)

if shortSignal and showTP_SL and barstate.isconfirmed
    line.delete(sl_line)
    line.delete(tp_line)
    sl_line := line.new(bar_index, slShort, bar_index + 30, slShort,
         color=color.new(sellColor, 30), width=1, style=line.style_dashed)
    tp_line := line.new(bar_index, tpShort, bar_index + 30, tpShort,
         color=color.new(buyColor,  30), width=1, style=line.style_dashed)


// ============================================================================
// === DASHBOARD ==============================================================
// ============================================================================
tblPos = tablePos == "Oben Rechts"  ? position.top_right   : tablePos == "Unten Rechts" ? position.bottom_right : tablePos == "Oben Links" ? position.top_left : tablePos == "Unten Links" ? position.bottom_left : position.middle_right
var table dash = table.new(tblPos, 2, 10, border_width=1, bgcolor=color.new(color.black, 10))

f_cell(c, r, txt, bg, tc) =>
    table.cell(dash, c, r, txt, text_color=tc, bgcolor=bg, text_size=size.small)

if showTable and barstate.islast
    f_cell(0, 0, "CLEAN Combo", color.new(#1A237E, 0), color.white)
    f_cell(1, 0, isChopping ? "⛔ CHOP" : isTrending ? "✓ TREND" : "— OK", isChopping ? color.orange : color.new(#1B5E20, 0), color.white)

    f_cell(0, 1, "Trend (EMA200)", color.black, color.white)
    f_cell(1, 1, close > emaSlow ? "▲ Bullisch" : "▼ Bärisch", close > emaSlow ? color.new(#00897B,0) : color.new(#C62828,0), color.white)

    f_cell(0, 2, "EMA Stack", color.black, color.white)
    f_cell(1, 2, bullStack ? "5>21>200 ▲" : bearStack ? "5<21<200 ▼" : "Gemischt", bullStack ? color.green : bearStack ? color.red : color.gray, color.white)

    f_cell(0, 3, "HTF (" + htfTF + ")", color.black, color.white)
    f_cell(1, 3, htfBull ? "▲ Bull" : htfBear ? "▼ Bear" : "Neutral", htfBull ? color.green : htfBear ? color.red : color.gray, color.white)

    rsiCol = rsi > 70 ? color.new(#FF1744,0) : rsi < 30 ? color.new(#00E676,0) : rsi > 50 ? color.green : color.red
    f_cell(0, 4, "RSI", color.black, color.white)
    f_cell(1, 4, str.tostring(math.round(rsi, 1)) + (rsi > 70 ? " OB⚠" : rsi < 30 ? " OS⚠" : ""), rsiCol, color.white)

    f_cell(0, 5, "ADX / Trend", color.black, color.white)
    f_cell(1, 5, str.tostring(math.round(adxVal, 0)) + (adxVal > 25 ? " Stark" : adxVal > 18 ? " OK" : " Schwach"), adxVal > 18 ? color.green : color.orange, color.white)

    zoneLabel = nearDemand ? "▲ Demand" : nearSupply ? "▼ Supply" : "Keine"
    zoneCol   = nearDemand ? color.green : nearSupply ? color.red : color.gray
    f_cell(0, 6, "Zone", color.black, color.white)
    f_cell(1, 6, zoneLabel, zoneCol, color.white)

    // POC + Value Area im Dashboard
    inVA     = close >= valLevel and close <= vahLevel
    pocLabel = not usePOC ? "Deaktiviert" : nearPOC ? (pocAbove ? "POC Support ✓" : "POC Resist ⚠") : inVA ? "In Value Area" : pocAbove ? "Über POC" : "Unter POC"
    pocCol   = not usePOC ? color.gray : nearPOC ? (pocAbove ? color.green : color.red) : inVA ? color.new(#FFA000,0) : color.gray
    f_cell(0, 7, "POC / VA", color.black, color.white)
    f_cell(1, 7, pocLabel + " | VAH:" + str.tostring(vahLevel, "#.##"), pocCol, color.white)

    lastSig    = not na(lastLongBar) and (na(lastShortBar) or lastLongBar > lastShortBar) ? "BUY — " + longReason : not na(lastShortBar) ? "SELL — " + shortReason : "Kein Signal"
    lastSigCol = not na(lastLongBar) and (na(lastShortBar) or lastLongBar > lastShortBar) ? color.new(#00E676,0) : not na(lastShortBar) ? color.new(#FF1744,0) : color.gray
    f_cell(0, 8, "Letztes Signal", color.black, color.white)
    f_cell(1, 8, lastSig, lastSigCol, color.white)

    hurstCol = hurst > 0.52 ? color.green : hurst < 0.48 ? color.red : color.orange
    f_cell(0, 9, "Hurst", color.black, color.white)
    f_cell(1, 9, str.tostring(hurst, "#.##") + (hurst > 0.50 ? " Trend" : " Chop"), hurstCol, color.white)


// ============================================================================
// === ALERTS =================================================================
// ============================================================================
alertcondition(longSignal,          title="BUY Signal",           message="BUY — {{ticker}} | {{interval}}")
alertcondition(shortSignal,         title="SELL Signal",          message="SELL — {{ticker}} | {{interval}}")
alertcondition(setupA and regimeOk, title="BUY: Zone Bounce",     message="BUY Zone Bounce — {{ticker}}")
alertcondition(setupB and regimeOk, title="BUY: EMA Cross",       message="BUY EMA Cross — {{ticker}}")
alertcondition(setupC and regimeOk, title="BUY: EMA200 Retest",   message="BUY EMA200 Retest — {{ticker}}")
alertcondition(setupD and regimeOk, title="SELL: Zone Reject",    message="SELL Zone Reject — {{ticker}}")
alertcondition(setupE and regimeOk, title="SELL: EMA Cross",      message="SELL EMA Cross — {{ticker}}")
alertcondition(setupF_raw and regimeOk, title="BUY: Support Bounce", message="BUY Support Bounce — {{ticker}}")
alertcondition(setupG and regimeOk, title="SELL: Momentum ↓",    message="SELL Momentum Shift — {{ticker}}")
alertcondition(setupH and regimeOk, title="BUY: Momentum ↑",     message="BUY Momentum Shift — {{ticker}}")
alertcondition(isChopping,          title="Markt choppt",         message="CHOP — Keine Trades — {{ticker}}")
alertcondition(nearPOC and pocBelow, title="POC Widerstand",      message="Preis nahe POC (Widerstand) — {{ticker}}")
alertcondition(nearPOC and pocAbove,  title="POC Support",     message="Preis nahe POC (Support) — {{ticker}}")
alertcondition(not inValueArea[1] and inValueArea, title="Value Area Eintritt", message="Preis betritt Value Area — {{ticker}}")
alertcondition(inValueArea[1] and not inValueArea and close > vahLevel, title="VAH Breakout", message="Breakout über Value Area High — {{ticker}}")
alertcondition(inValueArea[1] and not inValueArea and close < valLevel, title="VAL Breakdown", message="Breakdown unter Value Area Low — {{ticker}}")
````

# Contrarian Level Strength PRO 

- url: https://www.tradingview.com/script/5SKbiYxY/
- type: indicator
- pine_id: PUB;be5faec51d16419288a5318eb838cab7
- version: 1.0

## Description

Contrarian Level Strength PRO is a discretionary trading assistant designed to analyze how price approaches manually defined support and resistance levels.

The indicator focuses on the structure, strength and context of price movement before the level is reached, helping traders evaluate whether a contrarian reaction is statistically more favorable or whether momentum is strong enough to avoid fading the move.

The script does not generate automatic buy/sell signals.
Instead, it provides contextual information intended to support discretionary execution.

Core concepts used internally:

* ATR-based volatility normalization
* Relative arrival speed calculation
* Volume expansion and contraction analysis
* Compression and overextension filters
* Liquidity sweep detection
* False breakout recognition
* Multi-timeframe EMA directional context
* Supertrend filtering
* Historical level quality analysis
* Contrarian probability scoring

Main features:

* Multi-symbol manual level profiles
* Weighted support/resistance levels
* Arrival strength score from 1 to 100
* Long vs Short probability estimation
* Liquidity sweep detection
* Fake breakout analysis
* ATR-based target and stop projections
* Technical trade management assistance
* Level invalidation logic
* Temporary contextual labels
* Dashboard with statistical tracking
* Supertrend directional filter
* Multi-timeframe directional bias

Typical interpretation:

* Low arrival strength + rejection/sweep = possible contrarian opportunity
* Strong breakout momentum = avoid fading the move
* Fresh levels generally provide higher reaction probability than heavily tested levels

The indicator is designed for traders using discretionary price action and liquidity-based execution models rather than fully automated systems.

Why manual levels?
The script intentionally uses trader-defined levels because many institutional liquidity reactions occur around discretionary market structure areas that are difficult to standardize algorithmically.

English translation of interface labels:

* “Forza arrivo” = Arrival strength
* “Livello attivo” = Active level
* “Probabilità” = Probability
* “Qualità livello” = Level quality
* “Pre-avviso” = Pre-alert
* “Stato trade” = Trade status
* “Proteggi trade” = Protect trade
* “Livello invalidato” = Level invalidated

Recommended usage:

* Define important support/resistance zones manually
* Wait for price approach
* Evaluate arrival strength and reaction quality
* Avoid fading extremely strong momentum
* Use confirmation logic before execution

This script is intended as a decision-support tool and should not be considered financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © marinobortoluzzi

//@version=5
indicator("Forza Arrivo Livello CONTRARIAN v17 PRO ITA", overlay=true, max_labels_count=500)

// === DASHBOARD ===
dashboardMode = input.string("Solo segnale", "Modalità Dashboard", options=["Sempre visibile", "Solo segnale", "Nascosta"])
dashboardSize = input.string("Estesa", "Tipo Dashboard", options=["Compatta", "Estesa"])
dashPosInput = input.string("Alto Destra", "Posizione Dashboard", options=["Alto Destra", "Alto Sinistra", "Basso Destra", "Basso Sinistra", "Centro Destra", "Centro Sinistra"])

dashPos =
     dashPosInput == "Alto Destra" ? position.top_right :
     dashPosInput == "Alto Sinistra" ? position.top_left :
     dashPosInput == "Basso Destra" ? position.bottom_right :
     dashPosInput == "Basso Sinistra" ? position.bottom_left :
     dashPosInput == "Centro Destra" ? position.middle_right :
     position.middle_left

// === PROFILI CUSTOM ===
useAutoSymbol = input.bool(true, "Usa profili automatici simbolo")
sym1 = input.string("", "Simbolo Profilo 1")
sym2 = input.string("", "Simbolo Profilo 2")
sym3 = input.string("", "Simbolo Profilo 3")
sym4 = input.string("", "Simbolo Profilo 4")

// === PROFILO 1 ===
p1_l1 = input.float(0.0, "P1 Livello 1")
p1_w1 = input.float(1.0, "P1 Peso 1", minval=0.1, step=0.1)
p1_l2 = input.float(0.0, "P1 Livello 2")
p1_w2 = input.float(1.0, "P1 Peso 2", minval=0.1, step=0.1)
p1_l3 = input.float(0.0, "P1 Livello 3")
p1_w3 = input.float(1.0, "P1 Peso 3", minval=0.1, step=0.1)
p1_l4 = input.float(0.0, "P1 Livello 4")
p1_w4 = input.float(1.0, "P1 Peso 4", minval=0.1, step=0.1)
p1_l5 = input.float(0.0, "P1 Livello 5")
p1_w5 = input.float(1.0, "P1 Peso 5", minval=0.1, step=0.1)
p1_l6 = input.float(0.0, "P1 Livello 6")
p1_w6 = input.float(1.0, "P1 Peso 6", minval=0.1, step=0.1)

// === PROFILO 2 ===
p2_l1 = input.float(0.0, "P2 Livello 1")
p2_w1 = input.float(1.0, "P2 Peso 1", minval=0.1, step=0.1)
p2_l2 = input.float(0.0, "P2 Livello 2")
p2_w2 = input.float(1.0, "P2 Peso 2", minval=0.1, step=0.1)
p2_l3 = input.float(0.0, "P2 Livello 3")
p2_w3 = input.float(1.0, "P2 Peso 3", minval=0.1, step=0.1)
p2_l4 = input.float(0.0, "P2 Livello 4")
p2_w4 = input.float(1.0, "P2 Peso 4", minval=0.1, step=0.1)
p2_l5 = input.float(0.0, "P2 Livello 5")
p2_w5 = input.float(1.0, "P2 Peso 5", minval=0.1, step=0.1)
p2_l6 = input.float(0.0, "P2 Livello 6")
p2_w6 = input.float(1.0, "P2 Peso 6", minval=0.1, step=0.1)

// === PROFILO 3 ===
p3_l1 = input.float(0.0, "P3 Livello 1")
p3_w1 = input.float(1.0, "P3 Peso 1", minval=0.1, step=0.1)
p3_l2 = input.float(0.0, "P3 Livello 2")
p3_w2 = input.float(1.0, "P3 Peso 2", minval=0.1, step=0.1)
p3_l3 = input.float(0.0, "P3 Livello 3")
p3_w3 = input.float(1.0, "P3 Peso 3", minval=0.1, step=0.1)
p3_l4 = input.float(0.0, "P3 Livello 4")
p3_w4 = input.float(1.0, "P3 Peso 4", minval=0.1, step=0.1)
p3_l5 = input.float(0.0, "P3 Livello 5")
p3_w5 = input.float(1.0, "P3 Peso 5", minval=0.1, step=0.1)
p3_l6 = input.float(0.0, "P3 Livello 6")
p3_w6 = input.float(1.0, "P3 Peso 6", minval=0.1, step=0.1)

// === PROFILO 4 ===
p4_l1 = input.float(0.0, "P4 Livello 1")
p4_w1 = input.float(1.0, "P4 Peso 1", minval=0.1, step=0.1)
p4_l2 = input.float(0.0, "P4 Livello 2")
p4_w2 = input.float(1.0, "P4 Peso 2", minval=0.1, step=0.1)
p4_l3 = input.float(0.0, "P4 Livello 3")
p4_w3 = input.float(1.0, "P4 Peso 3", minval=0.1, step=0.1)
p4_l4 = input.float(0.0, "P4 Livello 4")
p4_w4 = input.float(1.0, "P4 Peso 4", minval=0.1, step=0.1)
p4_l5 = input.float(0.0, "P4 Livello 5")
p4_w5 = input.float(1.0, "P4 Peso 5", minval=0.1, step=0.1)
p4_l6 = input.float(0.0, "P4 Livello 6")
p4_w6 = input.float(1.0, "P4 Peso 6", minval=0.1, step=0.1)

// === PARAMETRI BASE ===
lookback = input.int(10, "Candele analisi arrivo", minval=3)
atrLen = input.int(14, "ATR Length")
volLen = input.int(20, "Volume medio")
entryMax = input.int(45, "Forza max per ingresso contrarian")
skipMin = input.int(70, "Forza min per evitare il livello")

touchATR = input.float(0.15, "Zona touch in ATR", step=0.05)
preAlertATR = input.float(0.50, "Pre-alert distanza in ATR", step=0.05)
enablePre = input.bool(true, "Abilita pre-alert")

// === ETICHETTE INTELLIGENTI ===
showLabels = input.bool(true, "Mostra etichette")
labelMode = input.string("Temporanee", "Modalità etichette", options=["Nascoste", "Solo segnale", "Temporanee", "Compatta", "Completa"])
labelTTL = input.int(5, "Durata etichetta in barre", minval=1, maxval=50)
labelOffset = input.int(12, "Spostamento etichetta a sinistra", minval=1)
labelTransp = input.int(35, "Trasparenza etichette", minval=0, maxval=90)
labelSizeInput = input.string("Piccola", "Dimensione etichette", options=["Tiny", "Piccola", "Normale"])
showLabelPre = input.bool(true, "Etichetta pre-avviso")
showLabelEntry = input.bool(true, "Etichetta ingresso")
showLabelProtect = input.bool(true, "Etichetta protezione")
showLabelInvalid = input.bool(true, "Etichetta invalidazione")

labelSize =
     labelSizeInput == "Tiny" ? size.tiny :
     labelSizeInput == "Piccola" ? size.small :
     size.normal

var label lastLabel = na
var int lastLabelBar = na

// === QUALITÀ LIVELLO ===
touchLookback = input.int(50, "Lookback test livello", minval=10)
maxTouches = input.int(3, "Max test prima di livello debole", minval=1)

// === FILTRI ===
useCompression = input.bool(true, "Usa filtro compressione")
useExtension = input.bool(true, "Usa filtro estensione")
emaLen = input.int(50, "EMA per estensione")
maxExtension = input.float(2.0, "Max estensione da EMA in ATR", step=0.25)

useSweep = input.bool(true, "Usa filtro liquidity sweep")
sweepATR = input.float(0.05, "Minimo sweep oltre livello in ATR", step=0.01)

// === SUPER TREND ===
useSupertrend = input.bool(true, "Usa filtro Supertrend")
blockAgainstST = input.bool(false, "Blocca segnali contro Supertrend")
showSupertrendLine = input.bool(true, "Mostra linea Supertrend")
stAtrLen = input.int(10, "Supertrend ATR Length")
stFactor = input.float(3.0, "Supertrend Fattore", step=0.1)

// === MTF ===
htf = input.timeframe("15", "Timeframe superiore")
htfFastLen = input.int(9, "EMA veloce HTF")
htfSlowLen = input.int(21, "EMA lenta HTF")

showTradePlan = input.bool(true, "Mostra piano trade")
exitEmaLen = input.int(21, "EMA target uscita")
stopATR = input.float(0.35, "Stop oltre livello in ATR", step=0.05)
targetATR = input.float(1.00, "Target minimo in ATR", step=0.10)

// === GESTIONE TRADE AVANZATA ===
oneTradePerLevel = input.bool(true, "Una sola entrata per livello")
tpATR = input.float(0.50, "ATR profitto minimo per proteggere", step=0.10)
invalidateATR = input.float(0.30, "Invalidazione oltre livello in ATR", step=0.05)
showBE = input.bool(true, "Mostra alert Break Even")

// === STATISTICHE ===
showStats = input.bool(true, "Mostra statistiche in dashboard")
resetStatsOnAutoReset = input.bool(false, "Reset statistiche su cambio simbolo/profilo/livelli")

// === DATI BASE ===
atr = ta.atr(atrLen)
volAvg = ta.sma(volume, volLen)
relVol = volAvg > 0 ? volume / volAvg : 1.0
exitEma = ta.ema(close, exitEmaLen)

// === SUPER TREND DATA ===
[stLine, stDirRaw] = ta.supertrend(stFactor, stAtrLen)
stBull = stDirRaw < 0
stBear = stDirRaw > 0

stText =
     stBull ? "RIALZISTA" :
     stBear ? "RIBASSISTA" :
     "NEUTRO"

// === PROFILO ATTIVO ===
ticker = syminfo.ticker

match1 = useAutoSymbol and sym1 != "" and str.contains(ticker, sym1)
match2 = useAutoSymbol and sym2 != "" and str.contains(ticker, sym2)
match3 = useAutoSymbol and sym3 != "" and str.contains(ticker, sym3)
match4 = useAutoSymbol and sym4 != "" and str.contains(ticker, sym4)

profile =
     match1 ? "P1" :
     match2 ? "P2" :
     match3 ? "P3" :
     match4 ? "P4" :
     "NESSUN PROFILO"

l1 = profile == "P1" ? p1_l1 : profile == "P2" ? p2_l1 : profile == "P3" ? p3_l1 : profile == "P4" ? p4_l1 : na
l2 = profile == "P1" ? p1_l2 : profile == "P2" ? p2_l2 : profile == "P3" ? p3_l2 : profile == "P4" ? p4_l2 : na
l3 = profile == "P1" ? p1_l3 : profile == "P2" ? p2_l3 : profile == "P3" ? p3_l3 : profile == "P4" ? p4_l3 : na
l4 = profile == "P1" ? p1_l4 : profile == "P2" ? p2_l4 : profile == "P3" ? p3_l4 : profile == "P4" ? p4_l4 : na
l5 = profile == "P1" ? p1_l5 : profile == "P2" ? p2_l5 : profile == "P3" ? p3_l5 : profile == "P4" ? p4_l5 : na
l6 = profile == "P1" ? p1_l6 : profile == "P2" ? p2_l6 : profile == "P3" ? p3_l6 : profile == "P4" ? p4_l6 : na

w1 = profile == "P1" ? p1_w1 : profile == "P2" ? p2_w1 : profile == "P3" ? p3_w1 : profile == "P4" ? p4_w1 : na
w2 = profile == "P1" ? p1_w2 : profile == "P2" ? p2_w2 : profile == "P3" ? p3_w2 : profile == "P4" ? p4_w2 : na
w3 = profile == "P1" ? p1_w3 : profile == "P2" ? p2_w3 : profile == "P3" ? p3_w3 : profile == "P4" ? p4_w3 : na
w4 = profile == "P1" ? p1_w4 : profile == "P2" ? p2_w4 : profile == "P3" ? p3_w4 : profile == "P4" ? p4_w4 : na
w5 = profile == "P1" ? p1_w5 : profile == "P2" ? p2_w5 : profile == "P3" ? p3_w5 : profile == "P4" ? p4_w5 : na
w6 = profile == "P1" ? p1_w6 : profile == "P2" ? p2_w6 : profile == "P3" ? p3_w6 : profile == "P4" ? p4_w6 : na

// === LIVELLO PIÙ VICINO ===
float nearest = na
float activeWeight = na
float minDist = 10e10

if not na(l1) and l1 != 0 and math.abs(close - l1) < minDist
    minDist := math.abs(close - l1)
    nearest := l1
    activeWeight := w1
if not na(l2) and l2 != 0 and math.abs(close - l2) < minDist
    minDist := math.abs(close - l2)
    nearest := l2
    activeWeight := w2
if not na(l3) and l3 != 0 and math.abs(close - l3) < minDist
    minDist := math.abs(close - l3)
    nearest := l3
    activeWeight := w3
if not na(l4) and l4 != 0 and math.abs(close - l4) < minDist
    minDist := math.abs(close - l4)
    nearest := l4
    activeWeight := w4
if not na(l5) and l5 != 0 and math.abs(close - l5) < minDist
    minDist := math.abs(close - l5)
    nearest := l5
    activeWeight := w5
if not na(l6) and l6 != 0 and math.abs(close - l6) < minDist
    minDist := math.abs(close - l6)
    nearest := l6
    activeWeight := w6

hasLevel = not na(nearest)
nearestSafe = hasLevel ? nearest : close
activeWeightSafe = hasLevel and not na(activeWeight) ? activeWeight : 1.0

distNow = math.abs(close - nearestSafe)
touch = hasLevel and distNow <= atr * touchATR

arrivingUp = close > close[lookback]
arrivingDown = close < close[lookback]

arrivalText =
     arrivingUp ? "DAL BASSO" :
     arrivingDown ? "DALL'ALTO" :
     "NEUTRO"

approaching = hasLevel and ((arrivingUp and close < nearestSafe) or (arrivingDown and close > nearestSafe))
preTouch = enablePre and hasLevel and distNow <= atr * preAlertATR and not touch and approaching

// === FORZA ===
move = math.abs(close - close[lookback])
speedScore = math.min((move / atr) * 25, 100)
rangeScore = math.min(ta.sma(high - low, lookback) / atr * 100, 100)
volumeScore = math.min(relVol * 50, 100)

strength = math.round(math.min(speedScore * 0.40 + rangeScore * 0.30 + volumeScore * 0.30, 100))
strength := math.max(strength, 1)

// === FILTRI ===
rangeNow = ta.sma(high - low, 3)
rangePrev = ta.sma(high - low, lookback)
compression = rangeNow < rangePrev
compressionOk = not useCompression or compression

emaBase = ta.ema(close, emaLen)
extension = math.abs(close - emaBase) / atr
overextended = extension > maxExtension
extensionOk = not useExtension or not overextended

// === QUALITÀ LIVELLO ===
touchCount = 0
for i = 0 to touchLookback - 1
    if hasLevel and math.abs(close[i] - nearestSafe) <= atr * touchATR
        touchCount += 1

levelQuality =
     not hasLevel ? "NESSUN LIVELLO" :
     touchCount <= 1 ? "FRESCO" :
     touchCount <= maxTouches ? "USATO" :
     "DEBOLE"

levelOk = levelQuality != "DEBOLE" and hasLevel

// === REAZIONE ===
breakUp = hasLevel and close > nearestSafe and close[1] <= nearestSafe
breakDown = hasLevel and close < nearestSafe and close[1] >= nearestSafe

rejectUp = hasLevel and high > nearestSafe and close < nearestSafe
rejectDown = hasLevel and low < nearestSafe and close > nearestSafe

fakeUp = breakUp[1] and close < nearestSafe
fakeDown = breakDown[1] and close > nearestSafe

sweepShort = useSweep and hasLevel and high > nearestSafe + atr * sweepATR and close < nearestSafe
sweepLong = useSweep and hasLevel and low < nearestSafe - atr * sweepATR and close > nearestSafe

sweepText =
     sweepShort ? "SWEEP SHORT" :
     sweepLong ? "SWEEP LONG" :
     "NO"

reaction =
     sweepShort or sweepLong ? "LIQUIDITY SWEEP" :
     fakeUp or fakeDown ? "FALSA ROTTURA" :
     breakUp or breakDown ? "ROTTURA" :
     rejectUp or rejectDown ? "RIFIUTO" :
     touch ? "TEST" :
     preTouch ? "PRE-AVVISO" :
     "NESSUNA"

// === MTF ===
htfFast = request.security(syminfo.tickerid, htf, ta.ema(close, htfFastLen))
htfSlow = request.security(syminfo.tickerid, htf, ta.ema(close, htfSlowLen))

htfDir =
     htfFast > htfSlow ? "RIALZISTA" :
     htfFast < htfSlow ? "RIBASSISTA" :
     "NEUTRO"

// === BIAS ===
bias =
     arrivingUp ? "MEGLIO SHORT" :
     arrivingDown ? "MEGLIO LONG" :
     "NESSUN BIAS"

// === STATO TRADE / LIVELLO ===
var float managedLevel = na
var bool levelUsed = false
var bool levelInvalid = false
var int activeTradeDir = 0
var float tradeEntryPrice = na
var bool protectedDone = false

// === STATISTICHE ===
var int statSignals = 0
var int statWins = 0
var int statLosses = 0
var int statShort = 0
var int statLong = 0
var int statSweep = 0
var int statSweepWin = 0
var bool statActive = false
var int statDir = 0
var float statEntry = na
var float statTarget = na
var bool statIsSweep = false

// === AUTO RESET INTELLIGENTE ===
stateKey =
     ticker + "|" +
     timeframe.period + "|" +
     profile + "|" +
     str.tostring(l1) + "|" +
     str.tostring(l2) + "|" +
     str.tostring(l3) + "|" +
     str.tostring(l4) + "|" +
     str.tostring(l5) + "|" +
     str.tostring(l6)

var string lastStateKey = ""

autoResetEvent = lastStateKey != "" and stateKey != lastStateKey

if autoResetEvent
    managedLevel := na
    levelUsed := false
    levelInvalid := false
    activeTradeDir := 0
    tradeEntryPrice := na
    protectedDone := false
    statActive := false
    statDir := 0
    statEntry := na
    statTarget := na
    statIsSweep := false
    if not na(lastLabel)
        label.delete(lastLabel)
        lastLabel := na
        lastLabelBar := na
    if resetStatsOnAutoReset
        statSignals := 0
        statWins := 0
        statLosses := 0
        statShort := 0
        statLong := 0
        statSweep := 0
        statSweepWin := 0

lastStateKey := stateKey

levelChanged = hasLevel and (na(managedLevel) or nearestSafe != managedLevel)

if levelChanged
    managedLevel := nearestSafe
    levelUsed := false
    levelInvalid := false
    activeTradeDir := 0
    tradeEntryPrice := na
    protectedDone := false
    statActive := false
    statDir := 0
    statEntry := na
    statTarget := na
    statIsSweep := false

breakStrongUp = hasLevel and close > nearestSafe and (close - nearestSafe) > atr * invalidateATR
breakStrongDown = hasLevel and close < nearestSafe and (nearestSafe - close) > atr * invalidateATR

if breakStrongUp or breakStrongDown
    levelInvalid := true

// === DECISIONE RAW ===
rawDecision = "ATTENDI"

if not hasLevel
    rawDecision := "NESSUN LIVELLO"
else if preTouch
    rawDecision := "PREPARATI"
else if sweepShort
    rawDecision := "SWEEP SHORT"
else if sweepLong
    rawDecision := "SWEEP LONG"
else if reaction == "RIFIUTO" and strength <= entryMax and compressionOk and extensionOk and levelOk
    rawDecision := arrivingUp ? "CERCA SHORT" : "CERCA LONG"
else if reaction == "FALSA ROTTURA"
    rawDecision := arrivingUp ? "FALSO BREAK SHORT" : "FALSO BREAK LONG"
else if reaction == "ROTTURA" and strength >= skipMin
    rawDecision := "EVITA / LIVELLO SUCCESSIVO"
else if touch and strength >= skipMin
    rawDecision := "TROPPA FORZA / SALTA"
else if touch and not levelOk
    rawDecision := "LIVELLO DEBOLE"
else if touch
    rawDecision := "ATTENDI CONFERMA"

rawShort = rawDecision == "CERCA SHORT" or rawDecision == "FALSO BREAK SHORT" or rawDecision == "SWEEP SHORT"
rawLong = rawDecision == "CERCA LONG" or rawDecision == "FALSO BREAK LONG" or rawDecision == "SWEEP LONG"

// === SUPER TREND FILTER ===
stAgainstShort = useSupertrend and stBull
stAgainstLong = useSupertrend and stBear

stAgainstSetup =
     rawShort and stAgainstShort or
     rawLong and stAgainstLong

stWithSetup =
     rawShort and stBear or
     rawLong and stBull

stFilterText =
     not useSupertrend ? "DISATTIVATO" :
     stAgainstSetup ? "CONTRO SETUP" :
     stWithSetup ? "A FAVORE SETUP" :
     "NEUTRO"

canTradeBase = not oneTradePerLevel or (oneTradePerLevel and not levelUsed and not levelInvalid)
canTrade = blockAgainstST ? canTradeBase and not stAgainstSetup : canTradeBase

newTradeSignal = (rawShort or rawLong) and canTrade and not (rawShort[1] or rawLong[1])

if newTradeSignal
    levelUsed := true
    activeTradeDir := rawShort ? -1 : 1
    tradeEntryPrice := close
    protectedDone := false

    statSignals += 1
    statShort += rawShort ? 1 : 0
    statLong += rawLong ? 1 : 0
    statSweep += (rawDecision == "SWEEP SHORT" or rawDecision == "SWEEP LONG") ? 1 : 0

    statActive := true
    statDir := rawShort ? -1 : 1
    statEntry := close
    statTarget := rawShort ? close - atr * targetATR : close + atr * targetATR
    statIsSweep := rawDecision == "SWEEP SHORT" or rawDecision == "SWEEP LONG"

profitMove =
     activeTradeDir == -1 and not na(tradeEntryPrice) ? tradeEntryPrice - close :
     activeTradeDir == 1 and not na(tradeEntryPrice) ? close - tradeEntryPrice :
     0.0

tpReachedNow = activeTradeDir != 0 and not protectedDone and profitMove >= atr * tpATR

if tpReachedNow
    protectedDone := true

beSignal = showBE and tpReachedNow

// === STATISTICA OPZIONE A ===
statWinNow =
     statActive and (
         statDir == -1 and low <= statTarget or
         statDir == 1 and high >= statTarget
     )

statLossNow = statActive and not statWinNow and levelInvalid

if statWinNow
    statWins += 1
    statSweepWin += statIsSweep ? 1 : 0
    statActive := false
    statDir := 0
    statEntry := na
    statTarget := na
    statIsSweep := false

if statLossNow
    statLosses += 1
    statActive := false
    statDir := 0
    statEntry := na
    statTarget := na
    statIsSweep := false

decision = rawDecision

if levelInvalid
    decision := "LIVELLO INVALIDATO"
else if (rawShort or rawLong) and blockAgainstST and stAgainstSetup
    decision := "BLOCCATO DA SUPERTREND"
else if (rawShort or rawLong) and not canTradeBase
    decision := "TRADE GIÀ ESEGUITO"
else
    decision := rawDecision

// === PROBABILITÀ ===
strengthQuality = strength <= entryMax ? 25 : strength >= skipMin ? -25 : 5
levelQualityScore = levelQuality == "FRESCO" ? 20 : levelQuality == "USATO" ? 8 : levelQuality == "DEBOLE" ? -20 : 0
compressionScore = compression ? 12 : -5
extensionScore = overextended ? -15 : 10
sweepScore = sweepShort or sweepLong ? 25 : 0
reactionScore = reaction == "RIFIUTO" ? 15 : reaction == "FALSA ROTTURA" ? 18 : reaction == "ROTTURA" ? -20 : 0
weightScore = math.min((activeWeightSafe - 1.0) * 10, 15)
supertrendScore = not useSupertrend ? 0 : stWithSetup ? 8 : stAgainstSetup ? -12 : 0

probability = math.round(math.max(math.min(50 + strengthQuality + levelQualityScore + compressionScore + extensionScore + sweepScore + reactionScore + weightScore + supertrendScore, 100), 0))

probText =
     probability >= 75 ? "ALTA" :
     probability >= 55 ? "MEDIA" :
     probability >= 35 ? "BASSA" :
     "MOLTO BASSA"

// === PROBABILITÀ LONG / SHORT + TARGET TRADE ===
longRaw = 50.0
shortRaw = 50.0

longRaw += bias == "MEGLIO LONG" ? 20 : bias == "MEGLIO SHORT" ? -20 : 0
shortRaw += bias == "MEGLIO SHORT" ? 20 : bias == "MEGLIO LONG" ? -20 : 0

longRaw += sweepLong ? 20 : sweepShort ? -20 : 0
shortRaw += sweepShort ? 20 : sweepLong ? -20 : 0

longRaw += decision == "FALSO BREAK LONG" ? 15 : decision == "FALSO BREAK SHORT" ? -15 : 0
shortRaw += decision == "FALSO BREAK SHORT" ? 15 : decision == "FALSO BREAK LONG" ? -15 : 0

longRaw += reaction == "RIFIUTO" and arrivingDown ? 10 : 0
shortRaw += reaction == "RIFIUTO" and arrivingUp ? 10 : 0

longRaw += useSupertrend and stBull ? 8 : useSupertrend and stBear ? -8 : 0
shortRaw += useSupertrend and stBear ? 8 : useSupertrend and stBull ? -8 : 0

longRaw += levelQuality == "FRESCO" and bias == "MEGLIO LONG" ? 8 : 0
shortRaw += levelQuality == "FRESCO" and bias == "MEGLIO SHORT" ? 8 : 0

longRaw -= strength >= skipMin ? 12 : 0
shortRaw -= strength >= skipMin ? 12 : 0

longRaw := math.max(longRaw, 1)
shortRaw := math.max(shortRaw, 1)

longPct = math.round(longRaw / (longRaw + shortRaw) * 100)
shortPct = 100 - longPct

targetBiasLong = longPct > shortPct
targetBiasShort = shortPct > longPct

targetTradeATR = targetBiasLong ? close + atr * targetATR : close - atr * targetATR
targetTradeEMA = exitEma
stopTecnico = targetBiasLong ? nearestSafe - atr * stopATR : nearestSafe + atr * stopATR
targetDistanceATR = math.abs(targetTradeATR - close) / atr

targetDirectionText =
     targetBiasLong ? "LONG" :
     targetBiasShort ? "SHORT" :
     "NEUTRO"

targetReachedEvent =
     activeTradeDir == 1 and not na(tradeEntryPrice) and high >= tradeEntryPrice + atr * targetATR or
     activeTradeDir == -1 and not na(tradeEntryPrice) and low <= tradeEntryPrice - atr * targetATR

// === PIANO TRADE ===
shortStop = nearestSafe + atr * stopATR
longStop = nearestSafe - atr * stopATR
shortTargetATR = close - atr * targetATR
longTargetATR = close + atr * targetATR

isShortSetup = decision == "CERCA SHORT" or decision == "FALSO BREAK SHORT" or decision == "SWEEP SHORT"
isLongSetup = decision == "CERCA LONG" or decision == "FALSO BREAK LONG" or decision == "SWEEP LONG"

tradeState =
     activeTradeDir == -1 and protectedDone ? "SHORT PROTETTO / BE" :
     activeTradeDir == 1 and protectedDone ? "LONG PROTETTO / BE" :
     activeTradeDir == -1 ? "SHORT ATTIVO" :
     activeTradeDir == 1 ? "LONG ATTIVO" :
     levelInvalid ? "LIVELLO INVALIDATO" :
     levelUsed ? "LIVELLO GIÀ USATO" :
     "NESSUN TRADE"

tradeExit =
     not showTradePlan ? "Nascosto" :
     isShortSetup ? "SHORT | EMA: " + str.tostring(exitEma, format.mintick) + " | Target ATR: " + str.tostring(shortTargetATR, format.mintick) + " | Stop: " + str.tostring(shortStop, format.mintick) :
     isLongSetup ? "LONG | EMA: " + str.tostring(exitEma, format.mintick) + " | Target ATR: " + str.tostring(longTargetATR, format.mintick) + " | Stop: " + str.tostring(longStop, format.mintick) :
     activeTradeDir == -1 ? "SHORT attivo | Protezione a: " + str.tostring(tpATR, "#.00") + " ATR" :
     activeTradeDir == 1 ? "LONG attivo | Protezione a: " + str.tostring(tpATR, "#.00") + " ATR" :
     "Nessun piano attivo"

shortExitSignal = activeTradeDir == -1 and (close <= shortTargetATR or close <= exitEma)
longExitSignal = activeTradeDir == 1 and (close >= longTargetATR or close >= exitEma)

// === STATISTICHE TESTO ===
statClosed = statWins + statLosses
statWinrate = statClosed > 0 ? statWins / statClosed * 100 : na
statText = statClosed > 0 ? str.tostring(statWinrate, "#.0") + "%" : "N/D"

// === COLORI ===
decisionColor =
     decision == "CERCA SHORT" or decision == "SWEEP SHORT" ? color.red :
     decision == "CERCA LONG" or decision == "SWEEP LONG" ? color.green :
     decision == "FALSO BREAK SHORT" or decision == "FALSO BREAK LONG" ? color.orange :
     decision == "TROPPA FORZA / SALTA" ? color.red :
     decision == "LIVELLO DEBOLE" ? color.maroon :
     decision == "LIVELLO INVALIDATO" ? color.maroon :
     decision == "TRADE GIÀ ESEGUITO" ? color.gray :
     decision == "BLOCCATO DA SUPERTREND" ? color.gray :
     decision == "PREPARATI" ? color.yellow :
     color.gray

riskText =
     decision == "CERCA SHORT" or decision == "CERCA LONG" or decision == "SWEEP SHORT" or decision == "SWEEP LONG" ? "SETUP" :
     decision == "FALSO BREAK SHORT" or decision == "FALSO BREAK LONG" ? "FAKE / ALTA ATTENZIONE" :
     decision == "PREPARATI" ? "PREPARAZIONE" :
     decision == "ATTENDI CONFERMA" ? "CONFERMA NECESSARIA" :
     decision == "TROPPA FORZA / SALTA" or decision == "EVITA / LIVELLO SUCCESSIVO" or decision == "LIVELLO DEBOLE" or decision == "LIVELLO INVALIDATO" ? "RISCHIO ALTO" :
     decision == "TRADE GIÀ ESEGUITO" or decision == "BLOCCATO DA SUPERTREND" ? "BLOCCATO" :
     "NEUTRO"

riskColor =
     riskText == "SETUP" ? color.green :
     riskText == "FAKE / ALTA ATTENZIONE" ? color.orange :
     riskText == "PREPARAZIONE" ? color.yellow :
     riskText == "CONFERMA NECESSARIA" ? color.orange :
     riskText == "RISCHIO ALTO" ? color.red :
     riskText == "BLOCCATO" ? color.gray :
     color.gray

qualityColor = levelQuality == "FRESCO" ? color.green : levelQuality == "USATO" ? color.orange : levelQuality == "DEBOLE" ? color.red : color.gray
probColor = probability >= 75 ? color.green : probability >= 55 ? color.orange : probability >= 35 ? color.red : color.maroon
biasColor = bias == "MEGLIO SHORT" ? color.red : bias == "MEGLIO LONG" ? color.green : color.gray
compressionColor = compression ? color.green : color.orange
extensionColor = overextended ? color.red : color.green
tradeStateColor = protectedDone ? color.green : activeTradeDir != 0 ? color.orange : levelInvalid ? color.red : color.gray
stColor = stBull ? color.green : stBear ? color.red : color.gray
stFilterColor = stWithSetup ? color.green : stAgainstSetup ? color.red : color.gray
longColor = longPct >= shortPct ? color.green : color.gray
shortColor = shortPct > longPct ? color.red : color.gray

// === PLOT ===
plot(hasLevel ? nearestSafe : na, "Livello attivo", color=color.white, linewidth=3)
plot(not na(l1) and l1 != 0 ? l1 : na, "Livello 1", color=color.yellow)
plot(not na(l2) and l2 != 0 ? l2 : na, "Livello 2", color=color.orange)
plot(not na(l3) and l3 != 0 ? l3 : na, "Livello 3", color=color.red)
plot(not na(l4) and l4 != 0 ? l4 : na, "Livello 4", color=color.blue)
plot(not na(l5) and l5 != 0 ? l5 : na, "Livello 5", color=color.purple)
plot(not na(l6) and l6 != 0 ? l6 : na, "Livello 6", color=color.gray)

plot(showTradePlan and isShortSetup ? shortStop : na, "Stop Short", color=color.red, style=plot.style_linebr)
plot(showTradePlan and isLongSetup ? longStop : na, "Stop Long", color=color.green, style=plot.style_linebr)
plot(showTradePlan and isShortSetup ? shortTargetATR : na, "Target Short ATR", color=color.orange, style=plot.style_linebr)
plot(showTradePlan and isLongSetup ? longTargetATR : na, "Target Long ATR", color=color.orange, style=plot.style_linebr)
plot(showTradePlan ? exitEma : na, "EMA Uscita", color=color.blue)
plot(showSupertrendLine and useSupertrend ? stLine : na, "Supertrend", color=stBull ? color.green : color.red)

// === EVENTI ALERT STABILI ===
preTouchEvent = preTouch and not preTouch[1]
shortEvent = decision == "CERCA SHORT" and decision[1] != "CERCA SHORT"
longEvent = decision == "CERCA LONG" and decision[1] != "CERCA LONG"
sweepShortEvent = decision == "SWEEP SHORT" and decision[1] != "SWEEP SHORT"
sweepLongEvent = decision == "SWEEP LONG" and decision[1] != "SWEEP LONG"
fakeShortEvent = decision == "FALSO BREAK SHORT" and decision[1] != "FALSO BREAK SHORT"
fakeLongEvent = decision == "FALSO BREAK LONG" and decision[1] != "FALSO BREAK LONG"
avoidEvent = decision == "EVITA / LIVELLO SUCCESSIVO" and decision[1] != "EVITA / LIVELLO SUCCESSIVO"
tooStrongEvent = decision == "TROPPA FORZA / SALTA" and decision[1] != "TROPPA FORZA / SALTA"
alreadyDoneEvent = decision == "TRADE GIÀ ESEGUITO" and decision[1] != "TRADE GIÀ ESEGUITO"
invalidEvent = levelInvalid and not levelInvalid[1]
stBlockedEvent = decision == "BLOCCATO DA SUPERTREND" and decision[1] != "BLOCCATO DA SUPERTREND"
protectEvent = tpReachedNow
beEvent = beSignal
shortExitEvent = shortExitSignal and not shortExitSignal[1]
longExitEvent = longExitSignal and not longExitSignal[1]
statWinEvent = statWinNow
statLossEvent = statLossNow

// === ETICHETTE TEMPORANEE / PULITE ===
entryLabelEvent = showLabelEntry and (shortEvent or longEvent or sweepShortEvent or sweepLongEvent or fakeShortEvent or fakeLongEvent or stBlockedEvent or alreadyDoneEvent)
preLabelEvent = showLabelPre and preTouchEvent
protectLabelEvent = showLabelProtect and protectEvent
invalidLabelEvent = showLabelInvalid and invalidEvent

labelEvent =
     showLabels and
     labelMode != "Nascoste" and
     (preLabelEvent or entryLabelEvent or protectLabelEvent or invalidLabelEvent)

if not na(lastLabel) and labelMode == "Temporanee" and not na(lastLabelBar) and bar_index - lastLabelBar >= labelTTL
    label.delete(lastLabel)
    lastLabel := na
    lastLabelBar := na

if labelEvent
    if not na(lastLabel)
        label.delete(lastLabel)

    mainAction =
         protectEvent ? "PROTEGGI / BE" :
         invalidEvent ? "INVALIDATO" :
         preTouchEvent ? "PRE-AVVISO" :
         decision

    labelText =
         labelMode == "Solo segnale" ?
             mainAction
         :
         labelMode == "Temporanee" or labelMode == "Compatta" ?
             mainAction + "\nL:" + str.tostring(longPct) + "% S:" + str.tostring(shortPct) + "%"
         :
             mainAction +
             "\nProbabilità: " + str.tostring(probability) + "/100 " + probText +
             "\nLONG: " + str.tostring(longPct) + "% | SHORT: " + str.tostring(shortPct) + "%" +
             "\nTarget: " + targetDirectionText + " " + str.tostring(targetTradeATR, format.mintick) +
             "\nForza: " + str.tostring(strength) + "/100" +
             "\nBias: " + bias +
             "\nSupertrend: " + stText +
             "\nFiltro ST: " + stFilterText +
             "\nReazione: " + reaction +
             "\nSweep: " + sweepText +
             "\nQualità: " + levelQuality +
             "\nStato: " + tradeState

    labelX = math.max(bar_index - labelOffset, 0)

    lastLabel := label.new(
         labelX,
         close,
         labelText,
         color=color.new(protectEvent ? color.green : invalidEvent ? color.maroon : preTouchEvent ? color.yellow : decisionColor, labelTransp),
         textcolor=preTouchEvent ? color.black : color.white,
         style=label.style_label_right,
         size=labelSize
     )

    lastLabelBar := bar_index

if (not showLabels or labelMode == "Nascoste") and not na(lastLabel)
    label.delete(lastLabel)
    lastLabel := na
    lastLabelBar := na

// === DASHBOARD ===
var table dash = table.new(dashPos, 2, 32, border_width=1)

signalNow =
     preTouchEvent or
     touch or
     isShortSetup or
     isLongSetup or
     protectEvent or
     invalidEvent or
     stBlockedEvent or
     statWinEvent or
     statLossEvent or
     targetReachedEvent

showDash =
     dashboardMode == "Sempre visibile" ? true :
     dashboardMode == "Solo segnale" ? signalNow :
     false

if barstate.islast
    table.clear(dash, 0, 0, 1, 31)

    if showDash
        table.cell(dash, 0, 0, "Parametro", bgcolor=color.black, text_color=color.white)
        table.cell(dash, 1, 0, "Valore", bgcolor=color.black, text_color=color.white)

        table.cell(dash, 0, 1, "Profilo")
        table.cell(dash, 1, 1, profile)

        table.cell(dash, 0, 2, "Livello attivo")
        table.cell(dash, 1, 2, hasLevel ? str.tostring(nearestSafe, format.mintick) : "NON IMPOSTATO")

        table.cell(dash, 0, 3, "Bias livello")
        table.cell(dash, 1, 3, bias, bgcolor=biasColor, text_color=color.white)

        table.cell(dash, 0, 4, "Probabilità")
        table.cell(dash, 1, 4, str.tostring(probability) + "/100 " + probText, bgcolor=probColor, text_color=color.white)

        table.cell(dash, 0, 5, "Forza arrivo")
        table.cell(dash, 1, 5, str.tostring(strength) + "/100", bgcolor=decisionColor, text_color=color.white)

        table.cell(dash, 0, 6, "Decisione")
        table.cell(dash, 1, 6, decision, bgcolor=decisionColor, text_color=decision == "PREPARATI" ? color.black : color.white)

        table.cell(dash, 0, 7, "Supertrend")
        table.cell(dash, 1, 7, stText, bgcolor=stColor, text_color=color.white)

        table.cell(dash, 0, 8, "Filtro ST")
        table.cell(dash, 1, 8, stFilterText, bgcolor=stFilterColor, text_color=color.white)

        table.cell(dash, 0, 9, "Stato trade")
        table.cell(dash, 1, 9, tradeState, bgcolor=tradeStateColor, text_color=color.white)

        table.cell(dash, 0, 10, "Rischio")
        table.cell(dash, 1, 10, riskText, bgcolor=riskColor, text_color=riskText == "PREPARAZIONE" ? color.black : color.white)

        if dashboardSize == "Estesa"
            table.cell(dash, 0, 11, "Arrivo")
            table.cell(dash, 1, 11, arrivalText)

            table.cell(dash, 0, 12, "Pre-avviso")
            table.cell(dash, 1, 12, preTouch ? "ATTIVO" : "NO", bgcolor=preTouch ? color.yellow : color.gray, text_color=preTouch ? color.black : color.white)

            table.cell(dash, 0, 13, "Touch")
            table.cell(dash, 1, 13, touch ? "SI" : "NO")

            table.cell(dash, 0, 14, "Reazione")
            table.cell(dash, 1, 14, reaction)

            table.cell(dash, 0, 15, "Liquidity sweep")
            table.cell(dash, 1, 15, sweepText, bgcolor=(sweepShort or sweepLong) ? color.orange : color.gray, text_color=color.white)

            table.cell(dash, 0, 16, "Qualità livello")
            table.cell(dash, 1, 16, levelQuality, bgcolor=qualityColor, text_color=color.white)

            table.cell(dash, 0, 17, "Compressione")
            table.cell(dash, 1, 17, compression ? "SI" : "NO", bgcolor=compressionColor, text_color=color.white)

            table.cell(dash, 0, 18, "Estensione")
            table.cell(dash, 1, 18, overextended ? "ECCESSIVA" : "OK", bgcolor=extensionColor, text_color=color.white)

            table.cell(dash, 0, 19, "Trend HTF")
            table.cell(dash, 1, 19, htfDir)

            table.cell(dash, 0, 20, "Piano uscita")
            table.cell(dash, 1, 20, tradeExit)

            table.cell(dash, 0, 21, "Prob. LONG")
            table.cell(dash, 1, 21, str.tostring(longPct) + "%", bgcolor=longColor, text_color=color.white)

            table.cell(dash, 0, 22, "Prob. SHORT")
            table.cell(dash, 1, 22, str.tostring(shortPct) + "%", bgcolor=shortColor, text_color=color.white)

            table.cell(dash, 0, 23, "Target trade")
            table.cell(dash, 1, 23, targetDirectionText + " | " + str.tostring(targetTradeATR, format.mintick))

            table.cell(dash, 0, 24, "Target EMA")
            table.cell(dash, 1, 24, str.tostring(targetTradeEMA, format.mintick))

            table.cell(dash, 0, 25, "Stop tecnico")
            table.cell(dash, 1, 25, str.tostring(stopTecnico, format.mintick))

            table.cell(dash, 0, 26, "Distanza target")
            table.cell(dash, 1, 26, str.tostring(targetDistanceATR, "#.00") + " ATR")

            if showStats
                table.cell(dash, 0, 27, "Segnali totali")
                table.cell(dash, 1, 27, str.tostring(statSignals))

                table.cell(dash, 0, 28, "Win / Loss")
                table.cell(dash, 1, 28, str.tostring(statWins) + " / " + str.tostring(statLosses))

                table.cell(dash, 0, 29, "Winrate")
                table.cell(dash, 1, 29, statText, bgcolor=statClosed > 0 and statWinrate >= 50 ? color.green : color.gray, text_color=color.white)

                table.cell(dash, 0, 30, "Short / Long")
                table.cell(dash, 1, 30, str.tostring(statShort) + " / " + str.tostring(statLong))

                table.cell(dash, 0, 31, "Sweep win")
                table.cell(dash, 1, 31, str.tostring(statSweepWin) + " / " + str.tostring(statSweep))

// === ALERT ===
alertcondition(preTouchEvent, "PRE-AVVISO LIVELLO", "Il prezzo si sta avvicinando al livello attivo")
alertcondition(shortEvent, "CERCA SHORT", "Setup contrarian short sul livello")
alertcondition(longEvent, "CERCA LONG", "Setup contrarian long sul livello")
alertcondition(sweepShortEvent, "SWEEP SHORT", "Liquidity sweep rialzista: possibile short contrarian")
alertcondition(sweepLongEvent, "SWEEP LONG", "Liquidity sweep ribassista: possibile long contrarian")
alertcondition(fakeShortEvent, "FALSO BREAK SHORT", "Falsa rottura rialzista: possibile short contrarian")
alertcondition(fakeLongEvent, "FALSO BREAK LONG", "Falsa rottura ribassista: possibile long contrarian")
alertcondition(avoidEvent, "EVITA LIVELLO", "Arrivo o rottura troppo forte: valutare livello successivo")
alertcondition(tooStrongEvent, "TROPPA FORZA", "Arrivo troppo forte sul livello: evitare ingresso contrarian")
alertcondition(alreadyDoneEvent, "TRADE GIÀ ESEGUITO", "Secondo ingresso bloccato sullo stesso livello")
alertcondition(invalidEvent, "LIVELLO INVALIDATO", "Il livello è stato rotto con forza: evitare nuovi ingressi")
alertcondition(stBlockedEvent, "BLOCCATO DA SUPERTREND", "Segnale bloccato dal filtro Supertrend")
alertcondition(protectEvent, "PROTEGGI TRADE", "Profitto minimo raggiunto: proteggi, chiudi parziale o porta stop a BE")
alertcondition(beEvent, "BREAK EVEN", "Porta lo stop a break even")
alertcondition(shortExitEvent, "USCITA SHORT", "Possibile uscita short: raggiunto target o EMA")
alertcondition(longExitEvent, "USCITA LONG", "Possibile uscita long: raggiunto target o EMA")
alertcondition(statWinEvent, "STATISTICA WIN", "Il setup simulato ha raggiunto il target ATR")
alertcondition(statLossEvent, "STATISTICA LOSS", "Il setup simulato è stato invalidato")
alertcondition(targetReachedEvent, "TARGET TRADE RAGGIUNTO", "Il target ATR del trade è stato raggiunto")
````

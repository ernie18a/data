# HTF FVG Scanner - Filtered

- url: https://www.tradingview.com/script/jeXXB4hK/
- type: indicator
- pine_id: PUB;13ceb7146dae44499ce61d91969de6d4
- version: 3.0

## Description

This script automatically identifies Fair Value Gaps (FVGs) — price inefficiencies — using a 3-candle pattern logic.

⚙️ How it works
Scans sequences of 3 consecutive candles to detect gaps between the first and the third candle
Highlights:
Bullish FVG when price leaves an imbalance to the upside
Bearish FVG when price leaves an imbalance to the downside
Draws FVGs as boxes extended forward until mitigation
📊 Multi-Timeframe
Supports FVG detection on multiple timeframes (e.g., H1, H4, Daily)
Displays higher timeframe FVGs on the current chart
Helps identify key liquidity zones
🎯 Filters & Customization
Minimum FVG size (to filter out weak signals)
Lookback range
Mitigation logic (partial or full)
Visual settings (colors, labels, box style)
🧠 Usage

FVGs represent areas where price moved too quickly, leaving an imbalance.
Price often revisits these zones to rebalance.

Not all FVGs are tradable — the most reliable ones align with market structure and liquidity.

## Source Code

````pine
//@version=6
indicator("HTF FVG Decision Tool Professional v3.1.1 FSM", overlay=true, max_boxes_count=240, max_labels_count=200, max_lines_count=180)

// v3.1.1
// Correzione anti-repaint:
// Lo stato 4 (MICRO FVG READY) viene raggiunto solo alla chiusura
// della candela M5 (barstate.isconfirmed), evitando passaggi
// temporanei 3→4→3 durante la formazione della barra.

// VERSIONE 3.1 FSM
// - la FSM segue la vita del setup, non la distanza istantanea del prezzo
// - eliminato il reset TOO FAR dopo l'armamento
// - il primo contatto con la Primary arma il setup in modo persistente
// - reset solo per invalidazione HTF, perdita della Primary o timeout
// - stato 1 rinominato SETUP ARMED
// - mantenuti BOS congelato, finestra micro-FVG e retest successivo
// - filtro ibrido assoluto + Gap/ATR
// - stato storico ACTIVE / MITIGATED / BROKEN
// - score normalizzato su ATR
// - Primary Lock
// - BOS su candela chiusa
// - trigger strutturale su TF piccolo: zona > sweep > BOS > micro FVG > retest

// INPUT
tfH1 = input.timeframe("60", "H1")
tfH4 = input.timeframe("240", "H4")
tfD  = input.timeframe("D", "Daily")

lb = input.int(80, "Lookback HTF", minval=10, maxval=200)

minGap = input.float(1.0, "Gap minimo assoluto $", step=0.1)
minFloorH1 = input.float(1.0, "Hard floor H1 $", step=0.5)
minFloorH4 = input.float(2.0, "Hard floor H4 $", step=0.5)
minFloorD  = input.float(4.0, "Hard floor Daily $", step=0.5)
atrLen = input.int(14, "ATR periodo filtro FVG", minval=5, maxval=100)
minAtrRatioH1 = input.float(0.12, "Min Gap/ATR H1", step=0.01)
minAtrRatioH4 = input.float(0.15, "Min Gap/ATR H4", step=0.01)
minAtrRatioD  = input.float(0.18, "Min Gap/ATR Daily", step=0.01)
maxAtrRatioH1 = input.float(2.50, "Max Gap/ATR H1", step=0.10)
maxAtrRatioH4 = input.float(2.20, "Max Gap/ATR H4", step=0.10)
maxAtrRatioD  = input.float(2.00, "Max Gap/ATR Daily", step=0.10)
usePrimaryLock = input.bool(true, "Blocca Primary quando entra nella FVG")
lockOnEqTouch = input.bool(true, "Blocca Primary al raggiungimento EQ")
primaryLockTimeout = input.int(120, "Timeout Primary Lock - barre chart", minval=10, maxval=2000)

maxAgeH1 = input.int(72, "Età max FVG H1 - barre", minval=5, maxval=300)
maxAgeH4 = input.int(60, "Età max FVG H4 - barre", minval=5, maxval=300)
maxAgeD  = input.int(30, "Età max FVG Daily - barre", minval=5, maxval=120)

emaFastLen = input.int(50, "EMA Fast")
emaSlowLen = input.int(200, "EMA Slow")

showBoxes = input.bool(true, "Mostra box")
showPrimaryOnly = input.bool(false, "Mostra solo Primary/Cluster")
showTable = input.bool(true, "Mostra tabella")
showSignals = input.bool(true, "Mostra segnali EXECUTE")
showInvalidation = input.bool(true, "Mostra invalidazione Primary")
showTargets = input.bool(true, "Mostra TP1/TP2/TP3")
showCap = input.bool(true, "Mostra CAP FVG contraria")
showCluster = input.bool(true, "Mostra cluster H1/H4")
showEquilibrium = input.bool(true, "Mostra EQ 50% Primary")

useHalfFVGFilter = input.bool(true, "Segnali solo nella metà migliore FVG")

sweepLookback = input.int(10, "Sweep/BOS lookback", minval=3, maxval=50)
useSweepBos = input.bool(false, "Usa filtro Sweep/BOS")

bosConfirmTf = input.timeframe("15", "TF conferma BOS")
useBosConfirmation = input.bool(true, "Usa conferma BOS per EXECUTE")
bosLookback = input.int(8, "BOS conferma lookback", minval=3, maxval=50)

approachDistance = input.float(10.0, "Distanza APPROACHING $", step=1)

minScoreToShow = input.float(60, "Score minimo visualizzazione", step=5)
minScorePrimary = input.float(80, "Score minimo Primary", step=5)

cooldownBars = input.int(8, "Cooldown segnali", minval=1, maxval=50)

wickRatio = input.float(1.2, "Reaction wick ratio", step=0.1)
useMomentum = input.bool(true, "Usa momentum candle")
useRejection = input.bool(true, "Usa rejection wick")

tp1Lookback = input.int(20, "TP1 swing locale lookback", minval=5, maxval=100)
tp2Tf = input.timeframe("240", "TP2 timeframe")
tp2Lookback = input.int(50, "TP2 swing HTF lookback", minval=10, maxval=200)
tp3Tf = input.timeframe("D", "TP3 timeframe")
tp3Lookback = input.int(60, "TP3 liquidity HTF lookback", minval=10, maxval=300)

// TRIGGER LOWER TIMEFRAME
triggerTf = input.timeframe("5", "TF trigger operativo")
triggerSweepLookback = input.int(8, "Trigger sweep lookback", minval=3, maxval=30)
triggerBosLookback = input.int(5, "Trigger BOS lookback", minval=2, maxval=20)
triggerTimeoutBars = input.int(30, "Scadenza trigger - barre TF trigger", minval=5, maxval=200)
triggerAtrLen = input.int(14, "ATR trigger", minval=5, maxval=50)
triggerMinGapAtr = input.float(0.05, "Micro FVG min Gap/ATR", step=0.01, minval=0.0)
triggerSlBufferAtr = input.float(0.10, "Buffer SL in ATR", step=0.05, minval=0.0)
triggerMaxDistanceAtr = input.float(1.00, "Distanza max dalla Primary in ATR trigger", step=0.10, minval=0.10)
triggerMicroMaxBars = input.int(5, "Micro FVG entro N barre dal BOS", minval=1, maxval=20)
showTriggerLevels = input.bool(true, "Mostra livelli Entry/SL trigger")


// EMA VISIVE
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

plot(emaFast, "EMA Fast chart", color=color.orange, linewidth=2)
plot(emaSlow, "EMA Slow chart", color=color.red, linewidth=2)

// TREND HTF
f_tfTrend() =>
    float eFast = ta.ema(close, emaFastLen)
    float eSlow = ta.ema(close, emaSlowLen)
    bool bTrend = close > eFast and eFast > eSlow
    bool sTrend = close < eFast and eFast < eSlow
    [bTrend, sTrend]

[h1BullTrend, h1BearTrend] = request.security(syminfo.tickerid, tfH1, f_tfTrend(), lookahead=barmerge.lookahead_off)
[h4BullTrend, h4BearTrend] = request.security(syminfo.tickerid, tfH4, f_tfTrend(), lookahead=barmerge.lookahead_off)
[dBullTrend, dBearTrend] = request.security(syminfo.tickerid, tfD, f_tfTrend(), lookahead=barmerge.lookahead_off)

h1Atr = request.security(syminfo.tickerid, tfH1, ta.atr(atrLen), lookahead=barmerge.lookahead_off)
h4Atr = request.security(syminfo.tickerid, tfH4, ta.atr(atrLen), lookahead=barmerge.lookahead_off)
dAtr  = request.security(syminfo.tickerid, tfD, ta.atr(atrLen), lookahead=barmerge.lookahead_off)

// TROVA FVG LONG + SHORT - STATO STORICO + FILTRO ATR
f_findRecentBoth(maxAgeBars, minFloor, minAtrRatio, maxAtrRatio) =>
    float bullTop = na
    float bullBot = na
    float bullGap = na
    float bullDist = na
    int bullBorn = na
    int bullState = 0
    bool bullFound = false

    float bearTop = na
    float bearBot = na
    float bearGap = na
    float bearDist = na
    int bearBorn = na
    int bearState = 0
    bool bearFound = false

    float atrValue = ta.atr(atrLen)
    float safeAtr = math.max(atrValue, syminfo.mintick)

    for i = 1 to lb - 3
        if i <= maxAgeBars
            bool bullFvg = low[i] > high[i + 2]
            bool bearFvg = high[i] < low[i + 2]

            if bullFvg and not bullFound
                float tBull = low[i]
                float bBull = high[i + 2]
                float gBull = math.abs(tBull - bBull)
                float ratioBull = gBull / safeAtr
                bool historicallyBrokenBull = false
                bool historicallyTouchedBull = false
                for j = 0 to i + 1
                    historicallyBrokenBull := historicallyBrokenBull or close[j] < bBull
                    historicallyTouchedBull := historicallyTouchedBull or (high[j] >= bBull and low[j] <= tBull)
                bool validBullSize = gBull >= minGap and gBull >= minFloor and ratioBull >= minAtrRatio and ratioBull <= maxAtrRatio
                if validBullSize and not historicallyBrokenBull
                    bullTop := tBull
                    bullBot := bBull
                    bullGap := gBull
                    bullDist := math.abs(close - ((tBull + bBull) / 2))
                    bullBorn := time[i + 2]
                    bullState := historicallyTouchedBull ? 2 : 1
                    bullFound := true

            if bearFvg and not bearFound
                float tBear = low[i + 2]
                float bBear = high[i]
                float gBear = math.abs(tBear - bBear)
                float ratioBear = gBear / safeAtr
                bool historicallyBrokenBear = false
                bool historicallyTouchedBear = false
                for j = 0 to i + 1
                    historicallyBrokenBear := historicallyBrokenBear or close[j] > tBear
                    historicallyTouchedBear := historicallyTouchedBear or (high[j] >= bBear and low[j] <= tBear)
                bool validBearSize = gBear >= minGap and gBear >= minFloor and ratioBear >= minAtrRatio and ratioBear <= maxAtrRatio
                if validBearSize and not historicallyBrokenBear
                    bearTop := tBear
                    bearBot := bBear
                    bearGap := gBear
                    bearDist := math.abs(close - ((tBear + bBear) / 2))
                    bearBorn := time[i + 2]
                    bearState := historicallyTouchedBear ? 2 : 1
                    bearFound := true

    [bullTop, bullBot, bullGap, bullDist, bullBorn, bullState, bearTop, bearBot, bearGap, bearDist, bearBorn, bearState]

// REQUEST SECURITY FVG
[h1LTop, h1LBot, h1LGap, h1LDist, h1LBorn, h1LStateCode, h1STop, h1SBot, h1SGap, h1SDist, h1SBorn, h1SStateCode] = request.security(syminfo.tickerid, tfH1, f_findRecentBoth(maxAgeH1, minFloorH1, minAtrRatioH1, maxAtrRatioH1), lookahead=barmerge.lookahead_off)
[h4LTop, h4LBot, h4LGap, h4LDist, h4LBorn, h4LStateCode, h4STop, h4SBot, h4SGap, h4SDist, h4SBorn, h4SStateCode] = request.security(syminfo.tickerid, tfH4, f_findRecentBoth(maxAgeH4, minFloorH4, minAtrRatioH4, maxAtrRatioH4), lookahead=barmerge.lookahead_off)
[dLTop, dLBot, dLGap, dLDist, dLBorn, dLStateCode, dSTop, dSBot, dSGap, dSDist, dSBorn, dSStateCode] = request.security(syminfo.tickerid, tfD, f_findRecentBoth(maxAgeD, minFloorD, minAtrRatioD, maxAtrRatioD), lookahead=barmerge.lookahead_off)

// STATE
f_stateText(code) =>
    string result = "-"
    if code == 1
        result := "ACTIVE"
    else if code == 2
        result := "MITIGATED"
    result

h1LState = f_stateText(h1LStateCode)
h1SState = f_stateText(h1SStateCode)
h4LState = f_stateText(h4LStateCode)
h4SState = f_stateText(h4SStateCode)
dLState = f_stateText(dLStateCode)
dSState = f_stateText(dSStateCode)

// SCORE - NORMALIZZATO SU ATR
f_score(tfName, top, bot, dist, bull, st, gap, tfAtr, tfBullTrend, tfBearTrend) =>
    float score = 0.0
    if not na(top) and not na(bot)
        float safeTfAtr = math.max(tfAtr, syminfo.mintick)
        float distAtr = dist / safeTfAtr
        float gapAtr = gap / safeTfAtr
        score += tfName == "D" ? 30 : tfName == "H4" ? 22 : 15
        score += st == "ACTIVE" ? 25 : st == "MITIGATED" ? 10 : 0
        score += bull and tfBullTrend ? 25 : not bull and tfBearTrend ? 25 : 0
        score += distAtr <= 0.25 ? 25 : distAtr <= 0.60 ? 18 : distAtr <= 1.20 ? 10 : distAtr <= 2.00 ? 4 : 0
        score += gapAtr >= 0.50 ? 10 : gapAtr >= 0.25 ? 7 : gapAtr >= 0.12 ? 4 : 0
    score

f_scoreClass(score) =>
    string result = "-"
    if score >= 140
        result := "A+"
    else if score >= 110
        result := "A"
    else if score >= 80
        result := "B"
    else if score > 0
        result := "C"
    result

h1LScore = f_score("H1", h1LTop, h1LBot, h1LDist, true, h1LState, h1LGap, h1Atr, h1BullTrend, h1BearTrend)
h1SScore = f_score("H1", h1STop, h1SBot, h1SDist, false, h1SState, h1SGap, h1Atr, h1BullTrend, h1BearTrend)
h4LScore = f_score("H4", h4LTop, h4LBot, h4LDist, true, h4LState, h4LGap, h4Atr, h4BullTrend, h4BearTrend)
h4SScore = f_score("H4", h4STop, h4SBot, h4SDist, false, h4SState, h4SGap, h4Atr, h4BullTrend, h4BearTrend)
dLScore = f_score("D", dLTop, dLBot, dLDist, true, dLState, dLGap, dAtr, dBullTrend, dBearTrend)
dSScore = f_score("D", dSTop, dSBot, dSDist, false, dSState, dSGap, dAtr, dBullTrend, dBearTrend)

// HELPER
f_inside(top, bot) =>
    not na(top) and not na(bot) and close <= top and close >= bot

h1LInside = f_inside(h1LTop, h1LBot)
h1SInside = f_inside(h1STop, h1SBot)
h4LInside = f_inside(h4LTop, h4LBot)
h4SInside = f_inside(h4STop, h4SBot)
dLInside = f_inside(dLTop, dLBot)
dSInside = f_inside(dSTop, dSBot)

// CONTINUATION
h1LCont = h1LState != "-" and h1BullTrend
h1SCont = h1SState != "-" and h1BearTrend
h4LCont = h4LState != "-" and h4BullTrend
h4SCont = h4SState != "-" and h4BearTrend
dLCont = dLState != "-" and dBullTrend
dSCont = dSState != "-" and dBearTrend

// PRIMARY SCORE
f_primaryScore(score, dist, cont, st) =>
    float ps = score
    ps += cont ? 40 : 0
    ps += not na(dist) and dist <= 10 ? 35 : not na(dist) and dist <= 25 ? 20 : not na(dist) and dist <= 50 ? 5 : -25
    ps += st == "MITIGATED" ? 10 : 0
    ps

h1LPrimaryScore = f_primaryScore(h1LScore, h1LDist, h1LCont, h1LState)
h1SPrimaryScore = f_primaryScore(h1SScore, h1SDist, h1SCont, h1SState)
h4LPrimaryScore = f_primaryScore(h4LScore, h4LDist, h4LCont, h4LState)
h4SPrimaryScore = f_primaryScore(h4SScore, h4SDist, h4SCont, h4SState)
dLPrimaryScore = f_primaryScore(dLScore, dLDist, dLCont, dLState)
dSPrimaryScore = f_primaryScore(dSScore, dSDist, dSCont, dSState)

// CLUSTERS
clusterLongHasData = not na(h1LTop) and not na(h1LBot) and not na(h4LTop) and not na(h4LBot)
clusterLongTop = clusterLongHasData ? math.min(h1LTop, h4LTop) : na
clusterLongBot = clusterLongHasData ? math.max(h1LBot, h4LBot) : na
clusterLongExists = showCluster and clusterLongHasData and clusterLongBot <= clusterLongTop
clusterLongBorn = clusterLongExists ? math.min(h1LBorn, h4LBorn) : na
clusterLongDist = clusterLongExists ? math.abs(close - ((clusterLongTop + clusterLongBot) / 2)) : na
clusterLongGap = clusterLongExists ? math.abs(clusterLongTop - clusterLongBot) : na
clusterLongState = clusterLongExists ? "ACTIVE" : "-"
clusterLongCont = clusterLongExists and h4BullTrend
clusterLongScore = clusterLongExists ? f_score("H4", clusterLongTop, clusterLongBot, clusterLongDist, true, clusterLongState, clusterLongGap, h4Atr, h4BullTrend, h4BearTrend) + 25 : 0.0
clusterLongPrimaryScore = clusterLongExists ? f_primaryScore(clusterLongScore, clusterLongDist, clusterLongCont, clusterLongState) + 20 : 0.0

clusterShortHasData = not na(h1STop) and not na(h1SBot) and not na(h4STop) and not na(h4SBot)
clusterShortTop = clusterShortHasData ? math.min(h1STop, h4STop) : na
clusterShortBot = clusterShortHasData ? math.max(h1SBot, h4SBot) : na
clusterShortExists = showCluster and clusterShortHasData and clusterShortBot <= clusterShortTop
clusterShortBorn = clusterShortExists ? math.min(h1SBorn, h4SBorn) : na
clusterShortDist = clusterShortExists ? math.abs(close - ((clusterShortTop + clusterShortBot) / 2)) : na
clusterShortGap = clusterShortExists ? math.abs(clusterShortTop - clusterShortBot) : na
clusterShortState = clusterShortExists ? "ACTIVE" : "-"
clusterShortCont = clusterShortExists and h4BearTrend
clusterShortScore = clusterShortExists ? f_score("H4", clusterShortTop, clusterShortBot, clusterShortDist, false, clusterShortState, clusterShortGap, h4Atr, h4BullTrend, h4BearTrend) + 25 : 0.0
clusterShortPrimaryScore = clusterShortExists ? f_primaryScore(clusterShortScore, clusterShortDist, clusterShortCont, clusterShortState) + 20 : 0.0

// PRIMARY SELECTION
string candidateTf = "-"
float candidateScore = 0.0
bool candidateBull = true
float candidateTop = na
float candidateBot = na
int candidateBorn = na
bool candidateBullTrend = false
bool candidateBearTrend = false

if h1LPrimaryScore >= minScorePrimary and h1LPrimaryScore > candidateScore
    candidateTf := "H1 LONG"
    candidateScore := h1LPrimaryScore
    candidateBull := true
    candidateTop := h1LTop
    candidateBot := h1LBot
    candidateBorn := h1LBorn
    candidateBullTrend := h1BullTrend
    candidateBearTrend := h1BearTrend

if h1SPrimaryScore >= minScorePrimary and h1SPrimaryScore > candidateScore
    candidateTf := "H1 SHORT"
    candidateScore := h1SPrimaryScore
    candidateBull := false
    candidateTop := h1STop
    candidateBot := h1SBot
    candidateBorn := h1SBorn
    candidateBullTrend := h1BullTrend
    candidateBearTrend := h1BearTrend

if h4LPrimaryScore >= minScorePrimary and h4LPrimaryScore > candidateScore
    candidateTf := "H4 LONG"
    candidateScore := h4LPrimaryScore
    candidateBull := true
    candidateTop := h4LTop
    candidateBot := h4LBot
    candidateBorn := h4LBorn
    candidateBullTrend := h4BullTrend
    candidateBearTrend := h4BearTrend

if h4SPrimaryScore >= minScorePrimary and h4SPrimaryScore > candidateScore
    candidateTf := "H4 SHORT"
    candidateScore := h4SPrimaryScore
    candidateBull := false
    candidateTop := h4STop
    candidateBot := h4SBot
    candidateBorn := h4SBorn
    candidateBullTrend := h4BullTrend
    candidateBearTrend := h4BearTrend

if dLPrimaryScore >= minScorePrimary and dLPrimaryScore > candidateScore
    candidateTf := "D LONG"
    candidateScore := dLPrimaryScore
    candidateBull := true
    candidateTop := dLTop
    candidateBot := dLBot
    candidateBorn := dLBorn
    candidateBullTrend := dBullTrend
    candidateBearTrend := dBearTrend

if dSPrimaryScore >= minScorePrimary and dSPrimaryScore > candidateScore
    candidateTf := "D SHORT"
    candidateScore := dSPrimaryScore
    candidateBull := false
    candidateTop := dSTop
    candidateBot := dSBot
    candidateBorn := dSBorn
    candidateBullTrend := dBullTrend
    candidateBearTrend := dBearTrend

if clusterLongPrimaryScore >= minScorePrimary and clusterLongPrimaryScore > candidateScore
    candidateTf := "CL LONG"
    candidateScore := clusterLongPrimaryScore
    candidateBull := true
    candidateTop := clusterLongTop
    candidateBot := clusterLongBot
    candidateBorn := clusterLongBorn
    candidateBullTrend := h4BullTrend
    candidateBearTrend := h4BearTrend

if clusterShortPrimaryScore >= minScorePrimary and clusterShortPrimaryScore > candidateScore
    candidateTf := "CL SHORT"
    candidateScore := clusterShortPrimaryScore
    candidateBull := false
    candidateTop := clusterShortTop
    candidateBot := clusterShortBot
    candidateBorn := clusterShortBorn
    candidateBullTrend := h4BullTrend
    candidateBearTrend := h4BearTrend

candidateHasPrimary = candidateTf != "-"
candidateInside = candidateHasPrimary and close <= candidateTop and close >= candidateBot
candidateEq = candidateHasPrimary ? (candidateTop + candidateBot) / 2 : na
candidateEqTouched = candidateHasPrimary and (candidateBull ? low <= candidateEq : high >= candidateEq)

var bool primaryLocked = false
var int primaryLockBar = na
var string lockedTf = "-"
var float lockedScore = 0.0
var bool lockedBull = true
var float lockedTop = na
var float lockedBot = na
var int lockedBorn = na
var bool lockedBullTrend = false
var bool lockedBearTrend = false

lockTrigger = usePrimaryLock and candidateHasPrimary and (candidateInside or (lockOnEqTouch and candidateEqTouched))

if not primaryLocked and lockTrigger
    primaryLocked := true
    primaryLockBar := bar_index
    lockedTf := candidateTf
    lockedScore := candidateScore
    lockedBull := candidateBull
    lockedTop := candidateTop
    lockedBot := candidateBot
    lockedBorn := candidateBorn
    lockedBullTrend := candidateBullTrend
    lockedBearTrend := candidateBearTrend

lockedInvalidatedNow = primaryLocked and (lockedBull ? close < lockedBot : close > lockedTop)
lockedTimedOut = primaryLocked and not na(primaryLockBar) and bar_index - primaryLockBar >= primaryLockTimeout

if primaryLocked and (lockedInvalidatedNow or lockedTimedOut)
    primaryLocked := false
    primaryLockBar := na
    lockedTf := "-"
    lockedScore := 0.0
    lockedTop := na
    lockedBot := na
    lockedBorn := na
    lockedBullTrend := false
    lockedBearTrend := false

string primaryTf = primaryLocked ? lockedTf : candidateTf
float primaryScore = primaryLocked ? lockedScore : candidateScore
bool primaryBull = primaryLocked ? lockedBull : candidateBull
float primaryTop = primaryLocked ? lockedTop : candidateTop
float primaryBot = primaryLocked ? lockedBot : candidateBot
int primaryBorn = primaryLocked ? lockedBorn : candidateBorn
bool primaryBullTrend = primaryLocked ? lockedBullTrend : candidateBullTrend
bool primaryBearTrend = primaryLocked ? lockedBearTrend : candidateBearTrend

hasPrimary = primaryTf != "-"
primaryClass = f_scoreClass(primaryScore)

// PRIMARY OPERATIVA
primaryInside = f_inside(primaryTop, primaryBot)
primaryContLong = hasPrimary and primaryBull and primaryInside and primaryBullTrend
primaryContShort = hasPrimary and not primaryBull and primaryInside and primaryBearTrend

primaryInvalidation = hasPrimary ? (primaryBull ? primaryBot : primaryTop) : na
primaryInvalidated = hasPrimary and (primaryBull ? close < primaryBot : close > primaryTop)

primaryEq = hasPrimary ? (primaryTop + primaryBot) / 2 : na
primaryInBestHalfLong = hasPrimary and primaryBull and close >= primaryBot and close <= primaryEq
primaryInBestHalfShort = hasPrimary and not primaryBull and close <= primaryTop and close >= primaryEq
primaryBestHalf = hasPrimary and (primaryBull ? primaryInBestHalfLong : primaryInBestHalfShort)

// CAP FVG CONTRARIA
float capLevel = na
string capName = "-"
bool hasCap = false

if hasPrimary and not primaryBull
    if not na(h1LTop) and h1LTop < close
        capLevel := na(capLevel) ? h1LTop : math.max(capLevel, h1LTop)
        capName := capLevel == h1LTop ? "H1 LONG" : capName
    if not na(h4LTop) and h4LTop < close
        capLevel := na(capLevel) ? h4LTop : math.max(capLevel, h4LTop)
        capName := capLevel == h4LTop ? "H4 LONG" : capName
    if not na(dLTop) and dLTop < close
        capLevel := na(capLevel) ? dLTop : math.max(capLevel, dLTop)
        capName := capLevel == dLTop ? "D LONG" : capName

if hasPrimary and primaryBull
    if not na(h1SBot) and h1SBot > close
        capLevel := na(capLevel) ? h1SBot : math.min(capLevel, h1SBot)
        capName := capLevel == h1SBot ? "H1 SHORT" : capName
    if not na(h4SBot) and h4SBot > close
        capLevel := na(capLevel) ? h4SBot : math.min(capLevel, h4SBot)
        capName := capLevel == h4SBot ? "H4 SHORT" : capName
    if not na(dSBot) and dSBot > close
        capLevel := na(capLevel) ? dSBot : math.min(capLevel, dSBot)
        capName := capLevel == dSBot ? "D SHORT" : capName

hasCap := not na(capLevel)

// SWEEP/BOS
prevHigh = ta.highest(high[1], sweepLookback)
prevLow = ta.lowest(low[1], sweepLookback)

bearSweep = high > prevHigh and close < prevHigh
bullSweep = low < prevLow and close > prevLow
bearBos = close < prevLow
bullBos = close > prevHigh

bearSweepBosOk = bearSweep or bearBos
bullSweepBosOk = bullSweep or bullBos

f_confirmBos(_lookback) =>
    float pHigh = ta.highest(high[2], _lookback)
    float pLow = ta.lowest(low[2], _lookback)
    bool bullConfirm = close[1] > pHigh
    bool bearConfirm = close[1] < pLow
    [bullConfirm, bearConfirm, pHigh, pLow]

[bullBosConfirm, bearBosConfirm, bosHighLevel, bosLowLevel] = request.security(syminfo.tickerid, bosConfirmTf, f_confirmBos(bosLookback), lookahead=barmerge.lookahead_off)

// REACTION
body = math.abs(close - open)
safeBody = body == 0 ? syminfo.mintick : body

upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

bearMomentum = close < open and close < low[1]
bullMomentum = close > open and close > high[1]

bearRejection = primaryInside and upperWick >= safeBody * wickRatio and close < open
bullRejection = primaryInside and lowerWick >= safeBody * wickRatio and close > open

longReaction = (useMomentum and bullMomentum) or (useRejection and bullRejection)
shortReaction = (useMomentum and bearMomentum) or (useRejection and bearRejection)

halfFilterOkLong = not useHalfFVGFilter or primaryInBestHalfLong
halfFilterOkShort = not useHalfFVGFilter or primaryInBestHalfShort

longSetup = primaryContLong and longReaction and halfFilterOkLong and (not useSweepBos or bullSweepBosOk) and not primaryInvalidated
shortSetup = primaryContShort and shortReaction and halfFilterOkShort and (not useSweepBos or bearSweepBosOk) and not primaryInvalidated

longBosOk = not useBosConfirmation or bullBosConfirm
shortBosOk = not useBosConfirmation or bearBosConfirm

rawLongSignal = longSetup and longBosOk
rawShortSignal = shortSetup and shortBosOk

var int lastLongSignalBar = na
var int lastShortSignalBar = na

longSignal = rawLongSignal and (na(lastLongSignalBar) or bar_index - lastLongSignalBar > cooldownBars)
shortSignal = rawShortSignal and (na(lastShortSignalBar) or bar_index - lastShortSignalBar > cooldownBars)

if longSignal
    lastLongSignalBar := bar_index

if shortSignal
    lastShortSignalBar := bar_index

// TRIGGER STRUTTURALE LOWER TIMEFRAME - FINITE STATE MACHINE
// La macchina segue il ciclo di vita del setup, non la posizione istantanea del prezzo.
//
// 0 WAIT PRIMARY
// 1 SETUP ARMED
// 2 SWEEP LOCKED
// 3 BOS CONFIRMED
// 4 MICRO FVG READY
// 5 TRIGGERED

int FSM_WAIT_PRIMARY = 0
int FSM_SETUP_ARMED = 1
int FSM_SWEEP_LOCKED = 2
int FSM_BOS_CONFIRMED = 3
int FSM_MICRO_READY = 4
int FSM_TRIGGERED = 5

int RESET_NONE = 0
int RESET_INVALIDATED = 1
int RESET_TIMEOUT = 2
int RESET_MICRO_WINDOW = 3

f_ltfTriggerFsm(_hasPrimary, _primaryBull, _primaryTop, _primaryBot) =>
    var int state = FSM_WAIT_PRIMARY
    var int stateBornBar = na
    var int setupArmedBar = na
    var int resetReason = RESET_NONE

    var float frozenSweepExtreme = na
    var float frozenBosReference = na
    var int frozenBosBar = na

    var float frozenMicroTop = na
    var float frozenMicroBot = na
    var float frozenEntry = na
    var float frozenStop = na
    var int frozenMicroBornBar = na

    float atrTrigger = ta.atr(triggerAtrLen)
    float safeAtrTrigger = math.max(atrTrigger, syminfo.mintick)

    // Calcoli eseguiti a ogni barra per coerenza Pine.
    float sweepHighSeries = ta.highest(high[1], triggerSweepLookback)
    float sweepLowSeries = ta.lowest(low[1], triggerSweepLookback)
    float bosHighSeries = ta.highest(high[1], triggerBosLookback)
    float bosLowSeries = ta.lowest(low[1], triggerBosLookback)

    bool zoneTouchedNow = _hasPrimary and high >= _primaryBot and low <= _primaryTop
    bool invalidNow = _hasPrimary and (_primaryBull ? close < _primaryBot : close > _primaryTop)

    // Il timeout decorre dall'armamento del setup, non dal singolo stato.
    bool setupTimedOut = state > FSM_WAIT_PRIMARY and state < FSM_TRIGGERED and not na(setupArmedBar) and bar_index - setupArmedBar > triggerTimeoutBars
    bool microWindowExpired = state == FSM_BOS_CONFIRMED and not na(frozenBosBar) and bar_index - frozenBosBar > triggerMicroMaxBars

    // RESET CENTRALIZZATO
    if not _hasPrimary
        state := FSM_WAIT_PRIMARY
        resetReason := RESET_NONE
        stateBornBar := na
        setupArmedBar := na
        frozenSweepExtreme := na
        frozenBosReference := na
        frozenBosBar := na
        frozenMicroTop := na
        frozenMicroBot := na
        frozenEntry := na
        frozenStop := na
        frozenMicroBornBar := na
    else if invalidNow
        state := FSM_WAIT_PRIMARY
        resetReason := RESET_INVALIDATED
        stateBornBar := na
        setupArmedBar := na
        frozenSweepExtreme := na
        frozenBosReference := na
        frozenBosBar := na
        frozenMicroTop := na
        frozenMicroBot := na
        frozenEntry := na
        frozenStop := na
        frozenMicroBornBar := na
    else if setupTimedOut
        state := FSM_WAIT_PRIMARY
        resetReason := RESET_TIMEOUT
        stateBornBar := na
        setupArmedBar := na
        frozenSweepExtreme := na
        frozenBosReference := na
        frozenBosBar := na
        frozenMicroTop := na
        frozenMicroBot := na
        frozenEntry := na
        frozenStop := na
        frozenMicroBornBar := na
    else if microWindowExpired
        // La micro-FVG è arrivata troppo tardi.
        // Conserviamo il setup armato, ma richiediamo una nuova sequenza sweep -> BOS.
        state := FSM_SETUP_ARMED
        resetReason := RESET_MICRO_WINDOW
        stateBornBar := bar_index
        frozenSweepExtreme := na
        frozenBosReference := na
        frozenBosBar := na
        frozenMicroTop := na
        frozenMicroBot := na
        frozenEntry := na
        frozenStop := na
        frozenMicroBornBar := na

    // TRANSIZIONE 0 -> 1
    // Il primo contatto con la Primary arma il setup in modo persistente.
    if state == FSM_WAIT_PRIMARY and zoneTouchedNow
        state := FSM_SETUP_ARMED
        resetReason := RESET_NONE
        stateBornBar := bar_index
        setupArmedBar := bar_index

    bool bullSweep = state == FSM_SETUP_ARMED and _primaryBull and low < sweepLowSeries and close > sweepLowSeries and barstate.isconfirmed
    bool bearSweep = state == FSM_SETUP_ARMED and not _primaryBull and high > sweepHighSeries and close < sweepHighSeries and barstate.isconfirmed

    // TRANSIZIONE 1 -> 2
    if bullSweep or bearSweep
        state := FSM_SWEEP_LOCKED
        frozenSweepExtreme := _primaryBull ? low : high
        frozenBosReference := _primaryBull ? bosHighSeries : bosLowSeries
        frozenStop := _primaryBull ? low - safeAtrTrigger * triggerSlBufferAtr : high + safeAtrTrigger * triggerSlBufferAtr
        stateBornBar := bar_index
        resetReason := RESET_NONE

    bool bullBos = state == FSM_SWEEP_LOCKED and _primaryBull and not na(frozenBosReference) and close > frozenBosReference and barstate.isconfirmed
    bool bearBos = state == FSM_SWEEP_LOCKED and not _primaryBull and not na(frozenBosReference) and close < frozenBosReference and barstate.isconfirmed

    // TRANSIZIONE 2 -> 3
    if bullBos or bearBos
        state := FSM_BOS_CONFIRMED
        frozenBosBar := bar_index
        stateBornBar := bar_index
        resetReason := RESET_NONE

    bool bullMicroFvg = low > high[2]
    bool bearMicroFvg = high < low[2]
    float bullMicroGap = bullMicroFvg ? low - high[2] : na
    float bearMicroGap = bearMicroFvg ? low[2] - high : na

    bool withinMicroWindow = state == FSM_BOS_CONFIRMED and not na(frozenBosBar) and bar_index > frozenBosBar and bar_index - frozenBosBar <= triggerMicroMaxBars
    bool bullMicroValid = withinMicroWindow and _primaryBull and bullMicroFvg and bullMicroGap / safeAtrTrigger >= triggerMinGapAtr and barstate.isconfirmed
    bool bearMicroValid = withinMicroWindow and not _primaryBull and bearMicroFvg and bearMicroGap / safeAtrTrigger >= triggerMinGapAtr and barstate.isconfirmed

    // TRANSIZIONE 3 -> 4
    if bullMicroValid
        frozenMicroTop := low
        frozenMicroBot := high[2]
        frozenEntry := (frozenMicroTop + frozenMicroBot) / 2
        frozenMicroBornBar := bar_index
        state := FSM_MICRO_READY
        stateBornBar := bar_index

    if bearMicroValid
        frozenMicroTop := low[2]
        frozenMicroBot := high
        frozenEntry := (frozenMicroTop + frozenMicroBot) / 2
        frozenMicroBornBar := bar_index
        state := FSM_MICRO_READY
        stateBornBar := bar_index

    bool retestNow = state == FSM_MICRO_READY and not na(frozenEntry) and not na(frozenMicroBornBar) and bar_index > frozenMicroBornBar and low <= frozenEntry and high >= frozenEntry and barstate.isconfirmed

    // TRANSIZIONE 4 -> 5
    if retestNow
        state := FSM_TRIGGERED
        stateBornBar := bar_index

    [state, resetReason, frozenSweepExtreme, frozenBosReference, frozenMicroTop, frozenMicroBot, frozenEntry, frozenStop, zoneTouchedNow, bullSweep, bearSweep, bullBos, bearBos, retestNow]

[triggerStage, triggerResetReason, triggerSweepExtreme, triggerFrozenBosRef, triggerMicroTop, triggerMicroBot, triggerEntry, triggerStop, triggerZoneTouchedNow, triggerBullSweep, triggerBearSweep, triggerBullBos, triggerBearBos, triggerRetest] = request.security(syminfo.tickerid, triggerTf, f_ltfTriggerFsm(hasPrimary, primaryBull, primaryTop, primaryBot), lookahead=barmerge.lookahead_off)

f_triggerStageText(state, resetReason, zoneTouchedNow) =>
    string result = "0/5 | WAIT PRIMARY"
    if state == FSM_WAIT_PRIMARY
        result := resetReason == RESET_INVALIDATED ? "0/5 | INVALIDATED" : resetReason == RESET_TIMEOUT ? "0/5 | TIMEOUT RESET" : "0/5 | WAIT PRIMARY"
    else if state == FSM_SETUP_ARMED
        result := resetReason == RESET_MICRO_WINDOW ? "1/5 | RE-ARMED" : zoneTouchedNow ? "1/5 | ARMED IN ZONE" : "1/5 | SETUP ARMED"
    else if state == FSM_SWEEP_LOCKED
        result := "2/5 | SWEEP LOCKED"
    else if state == FSM_BOS_CONFIRMED
        result := "3/5 | BOS CONFIRMED"
    else if state == FSM_MICRO_READY
        result := "4/5 | MICRO FVG READY"
    else if state == FSM_TRIGGERED
        result := "5/5 | TRIGGERED"
    result

f_triggerAction(state, resetReason, bull) =>
    string result = "WAIT"
    if not hasPrimary
        result := "NO PRIMARY"
    else if primaryInvalidated or resetReason == RESET_INVALIDATED
        result := "NO TRADE"
    else if resetReason == RESET_TIMEOUT
        result := "SETUP EXPIRED"
    else if state == FSM_WAIT_PRIMARY
        result := "WAIT ZONE TOUCH"
    else if state == FSM_SETUP_ARMED
        result := bull ? "WAIT LONG SWEEP" : "WAIT SHORT SWEEP"
    else if state == FSM_SWEEP_LOCKED
        result := "WAIT BOS LTF"
    else if state == FSM_BOS_CONFIRMED
        result := "WAIT MICRO FVG"
    else if state == FSM_MICRO_READY
        result := bull ? "BUY EQ RETEST" : "SELL EQ RETEST"
    else if state == FSM_TRIGGERED
        result := bull ? "LONG TRIGGERED" : "SHORT TRIGGERED"
    result

triggerText = f_triggerStageText(triggerStage, triggerResetReason, triggerZoneTouchedNow)
triggerAction = f_triggerAction(triggerStage, triggerResetReason, primaryBull)
triggerReady = triggerStage == FSM_MICRO_READY
triggerExecuted = triggerStage == FSM_TRIGGERED

// STATUS
f_status() =>
    string result = "-"
    bool nearPrimary = hasPrimary and not primaryInside and not na(primaryTop) and not na(primaryBot) and math.abs(close - ((primaryTop + primaryBot) / 2)) <= approachDistance
    bool confirming = longSetup or shortSetup
    bool bosConfirmed = (longSetup and bullBosConfirm) or (shortSetup and bearBosConfirm)

    if not hasPrimary
        result := "-"
    else if primaryInvalidated
        result := "INVALIDATED"
    else if longSignal
        result := "EXECUTE LONG"
    else if shortSignal
        result := "EXECUTE SHORT"
    else if bosConfirmed
        result := "BOS CONFIRMED"
    else if confirming
        result := "CONFIRMING"
    else if primaryInside and primaryBestHalf
        result := "READY"
    else if primaryInside
        result := "INSIDE"
    else if triggerStage > 0
        result := "ZONE TOUCHED"
    else if nearPrimary
        result := "APPROACHING"
    else
        result := "WATCH"
    result

mainStatus = f_status()

f_statusColor(st) =>
    color result = color.yellow
    if st == "INVALIDATED"
        result := color.red
    else if st == "EXECUTE LONG" or st == "EXECUTE SHORT"
        result := color.lime
    else if st == "BOS CONFIRMED"
        result := color.new(color.green, 0)
    else if st == "CONFIRMING"
        result := color.new(color.green, 15)
    else if st == "READY"
        result := color.new(color.green, 30)
    else if st == "INSIDE"
        result := color.orange
    else if st == "APPROACHING" or st == "ZONE TOUCHED"
        result := color.yellow
    else if st == "WATCH"
        result := color.new(color.yellow, 20)
    else
        result := color.gray
    result

mainStatusColor = f_statusColor(mainStatus)

// TP
tp1Long = ta.highest(high, tp1Lookback)
tp1Short = ta.lowest(low, tp1Lookback)

tp2Long = request.security(syminfo.tickerid, tp2Tf, ta.highest(high, tp2Lookback), lookahead=barmerge.lookahead_off)
tp2Short = request.security(syminfo.tickerid, tp2Tf, ta.lowest(low, tp2Lookback), lookahead=barmerge.lookahead_off)

tp3Long = request.security(syminfo.tickerid, tp3Tf, ta.highest(high, tp3Lookback), lookahead=barmerge.lookahead_off)
tp3Short = request.security(syminfo.tickerid, tp3Tf, ta.lowest(low, tp3Lookback), lookahead=barmerge.lookahead_off)

tp1 = hasPrimary ? (primaryBull ? tp1Long : tp1Short) : na

// I target successivi sono validi solo se realmente più lontani nella direzione del trade.
tp2Raw = hasPrimary ? (primaryBull ? tp2Long : tp2Short) : na
tp3Raw = hasPrimary ? (primaryBull ? tp3Long : tp3Short) : na

tp2 = hasPrimary and not na(tp1) and not na(tp2Raw) and (primaryBull ? tp2Raw > tp1 : tp2Raw < tp1) ? tp2Raw : na
float tp3Reference = not na(tp2) ? tp2 : tp1
tp3 = hasPrimary and not na(tp3Reference) and not na(tp3Raw) and (primaryBull ? tp3Raw > tp3Reference : tp3Raw < tp3Reference) ? tp3Raw : na

tpBlocked(level) =>
    bool blocked = false
    if hasPrimary and hasCap and not na(level)
        blocked := primaryBull ? level > capLevel : level < capLevel
    blocked

tp1Blocked = tpBlocked(tp1)
tp2Blocked = tpBlocked(tp2)
tp3Blocked = tpBlocked(tp3)

tpStatus(level, blocked) =>
    na(level) ? "NO DISTINCT TARGET" : blocked ? "BLOCK CAP" : ""

// OBJECTS
var box h1LBox = na
var box h1SBox = na
var box h4LBox = na
var box h4SBox = na
var box dLBox = na
var box dSBox = na
var box clLBox = na
var box clSBox = na
var box primaryBox = na

var label primaryLabel = na
var label clLLabel = na
var label clSLabel = na
var label invalidationLabel = na
var label tp1Label = na
var label tp2Label = na
var label tp3Label = na
var label eqLabel = na
var label capLabel = na

var line invalidationLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var line eqLine = na
var line capLine = na

f_deleteBox(b) =>
    if not na(b)
        box.delete(b)

f_deleteLabel(l) =>
    if not na(l)
        label.delete(l)

f_deleteLine(ln) =>
    if not na(ln)
        line.delete(ln)

f_shouldShow(score, name) =>
    bool result = false
    result := score >= minScoreToShow and (not showPrimaryOnly or name == primaryTf or name == "CL LONG" or name == "CL SHORT")
    result

f_drawBox(top, bot, bull, name, tfName, score, born) =>
    box b = na
    if showBoxes and not na(top) and not na(bot) and not na(born) and f_shouldShow(score, name)
        color col = bull ? color.green : color.red
        int transp = tfName == "D" ? 88 : tfName == "H4" ? 86 : 84
        int borderTransp = tfName == "D" ? 20 : tfName == "H4" ? 35 : 55
        b := box.new(left=born, top=top, right=time, bottom=bot, xloc=xloc.bar_time, extend=extend.right, bgcolor=color.new(col, transp), border_color=color.new(col, borderTransp))
    b

f_drawCluster(top, bot, bull, score, born, txt) =>
    box b = na
    label l = na
    if showBoxes and showCluster and not na(top) and not na(bot) and not na(born)
        color baseCol = bull ? color.green : color.red
        b := box.new(left=born, top=top, right=time, bottom=bot, xloc=xloc.bar_time, extend=extend.right, bgcolor=color.new(baseCol, 90), border_color=color.aqua, border_width=2)
        l := label.new(x=bar_index, y=(top + bot) / 2, text=txt + " | " + f_scoreClass(score), style=label.style_label_right, size=size.small, color=color.aqua, textcolor=color.black)
    [b, l]

f_drawPrimary(top, bot, bull, tfName, score, born) =>
    box b = na
    label l = na
    if showBoxes and hasPrimary and not na(top) and not na(bot) and not na(born)
        color baseCol = bull ? color.green : color.red
        b := box.new(left=born, top=top, right=time, bottom=bot, xloc=xloc.bar_time, extend=extend.right, bgcolor=color.new(baseCol, 94), border_color=color.yellow, border_width=2)
        l := label.new(x=bar_index, y=(top + bot) / 2, text=(primaryLocked ? "LOCKED | " : "PRIMARY | ") + tfName + " | " + primaryClass, style=label.style_label_right, size=size.small, color=color.yellow, textcolor=color.black)
    [b, l]

f_drawInvalidation(level) =>
    line ln = na
    label tmpLabel = na
    if showInvalidation and hasPrimary and not na(level)
        color invColor = primaryInvalidated ? color.red : color.yellow
        string invText = primaryInvalidated ? "INVALIDATED" : "INVALIDATION"
        ln := line.new(x1=bar_index, y1=level, x2=bar_index + 1, y2=level, extend=extend.right, color=invColor, style=line.style_dashed, width=2)
        tmpLabel := label.new(x=bar_index, y=level, text=invText + " " + str.tostring(level, format.mintick), style=label.style_label_right, size=size.tiny, color=invColor, textcolor=color.black)
    [ln, tmpLabel]

f_drawTP(level, txt, blocked, col) =>
    line ln = na
    label tmpLabel = na
    if showTargets and hasPrimary and not na(level)
        color finalCol = blocked ? color.orange : col
        string labelText = txt + " " + str.tostring(level, format.mintick) + (blocked ? " | BLOCK CAP" : "")
        ln := line.new(x1=bar_index, y1=level, x2=bar_index + 1, y2=level, extend=extend.right, color=finalCol, style=line.style_dotted, width=2)
        tmpLabel := label.new(x=bar_index, y=level, text=labelText, style=label.style_label_right, size=size.tiny, color=finalCol, textcolor=color.black)
    [ln, tmpLabel]

f_drawEQ(level) =>
    line ln = na
    label tmpLabel = na
    if showEquilibrium and hasPrimary and not na(level)
        ln := line.new(x1=bar_index, y1=level, x2=bar_index + 1, y2=level, extend=extend.right, color=color.white, style=line.style_dotted, width=1)
        tmpLabel := label.new(x=bar_index, y=level, text="EQ " + str.tostring(level, format.mintick), style=label.style_label_right, size=size.tiny, color=color.white, textcolor=color.black)
    [ln, tmpLabel]

f_drawCap(level, name) =>
    line ln = na
    label tmpLabel = na
    if showCap and hasPrimary and hasCap and not na(level)
        ln := line.new(x1=bar_index, y1=level, x2=bar_index + 1, y2=level, extend=extend.right, color=color.orange, style=line.style_solid, width=2)
        tmpLabel := label.new(x=bar_index, y=level, text="CAP " + name + " " + str.tostring(level, format.mintick), style=label.style_label_right, size=size.tiny, color=color.orange, textcolor=color.black)
    [ln, tmpLabel]

// DRAW
if barstate.islast
    f_deleteBox(h1LBox)
    f_deleteBox(h1SBox)
    f_deleteBox(h4LBox)
    f_deleteBox(h4SBox)
    f_deleteBox(dLBox)
    f_deleteBox(dSBox)
    f_deleteBox(clLBox)
    f_deleteBox(clSBox)
    f_deleteBox(primaryBox)

    f_deleteLabel(primaryLabel)
    f_deleteLabel(clLLabel)
    f_deleteLabel(clSLabel)
    f_deleteLabel(invalidationLabel)
    f_deleteLabel(tp1Label)
    f_deleteLabel(tp2Label)
    f_deleteLabel(tp3Label)
    f_deleteLabel(eqLabel)
    f_deleteLabel(capLabel)

    f_deleteLine(invalidationLine)
    f_deleteLine(tp1Line)
    f_deleteLine(tp2Line)
    f_deleteLine(tp3Line)
    f_deleteLine(eqLine)
    f_deleteLine(capLine)

    h1LBox := f_drawBox(h1LTop, h1LBot, true, "H1 LONG", "H1", h1LScore, h1LBorn)
    h1SBox := f_drawBox(h1STop, h1SBot, false, "H1 SHORT", "H1", h1SScore, h1SBorn)
    h4LBox := f_drawBox(h4LTop, h4LBot, true, "H4 LONG", "H4", h4LScore, h4LBorn)
    h4SBox := f_drawBox(h4STop, h4SBot, false, "H4 SHORT", "H4", h4SScore, h4SBorn)
    dLBox := f_drawBox(dLTop, dLBot, true, "D LONG", "D", dLScore, dLBorn)
    dSBox := f_drawBox(dSTop, dSBot, false, "D SHORT", "D", dSScore, dSBorn)

    if clusterLongExists
        [tmpClLBox, tmpClLLabel] = f_drawCluster(clusterLongTop, clusterLongBot, true, clusterLongPrimaryScore, clusterLongBorn, "CLUSTER LONG")
        clLBox := tmpClLBox
        clLLabel := tmpClLLabel

    if clusterShortExists
        [tmpClSBox, tmpClSLabel] = f_drawCluster(clusterShortTop, clusterShortBot, false, clusterShortPrimaryScore, clusterShortBorn, "CLUSTER SHORT")
        clSBox := tmpClSBox
        clSLabel := tmpClSLabel

    [tmpPrimaryBox, tmpPrimaryLabel] = f_drawPrimary(primaryTop, primaryBot, primaryBull, primaryTf, primaryScore, primaryBorn)
    primaryBox := tmpPrimaryBox
    primaryLabel := tmpPrimaryLabel

    [tmpInvalidationLine, tmpInvalidationLabel] = f_drawInvalidation(primaryInvalidation)
    invalidationLine := tmpInvalidationLine
    invalidationLabel := tmpInvalidationLabel

    [tmpTp1Line, tmpTp1Label] = f_drawTP(tp1, "TP1", tp1Blocked, color.aqua)
    tp1Line := tmpTp1Line
    tp1Label := tmpTp1Label

    [tmpTp2Line, tmpTp2Label] = f_drawTP(tp2, "TP2", tp2Blocked, color.new(color.aqua, 20))
    tp2Line := tmpTp2Line
    tp2Label := tmpTp2Label

    [tmpTp3Line, tmpTp3Label] = f_drawTP(tp3, "TP3", tp3Blocked, color.new(color.blue, 10))
    tp3Line := tmpTp3Line
    tp3Label := tmpTp3Label

    [tmpEqLine, tmpEqLabel] = f_drawEQ(primaryEq)
    eqLine := tmpEqLine
    eqLabel := tmpEqLabel

    [tmpCapLine, tmpCapLabel] = f_drawCap(capLevel, capName)
    capLine := tmpCapLine
    capLabel := tmpCapLabel

// SIGNALS
plotshape(showSignals and longSignal, title="Execute Long", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, text="EXEC LONG")
plotshape(showSignals and shortSignal, title="Execute Short", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="EXEC SHORT")
plotshape(useSweepBos and bullSweep, title="Bull Sweep", style=shape.circle, location=location.belowbar, color=color.aqua, size=size.tiny)
plotshape(useSweepBos and bearSweep, title="Bear Sweep", style=shape.circle, location=location.abovebar, color=color.orange, size=size.tiny)

plot(showTriggerLevels and triggerStage >= 4 ? triggerEntry : na, title="Trigger Entry", color=color.lime, linewidth=2, style=plot.style_linebr)
plot(showTriggerLevels and triggerStage >= 2 ? triggerStop : na, title="Trigger SL", color=color.red, linewidth=2, style=plot.style_linebr)
plotshape(showSignals and triggerExecuted and primaryBull, title="LTF Long Trigger", style=shape.labelup, location=location.belowbar, color=color.lime, text="LTF LONG", textcolor=color.black, size=size.tiny)
plotshape(showSignals and triggerExecuted and not primaryBull, title="LTF Short Trigger", style=shape.labeldown, location=location.abovebar, color=color.red, text="LTF SHORT", textcolor=color.white, size=size.tiny)

// TABLE HELPERS
f_ageText(born) =>
    string result = "-"
    if not na(born)
        float ageMinutes = math.max(0.0, (time - born) / 60000.0)
        result := ageMinutes >= 1440 ? str.tostring(ageMinutes / 1440.0, "#.0") + "d" : ageMinutes >= 60 ? str.tostring(ageMinutes / 60.0, "#.0") + "h" : str.tostring(ageMinutes, "#.0") + "m"
    result

fmt(top, bot, dist, bull, st, score, born) =>
    string result = "-"
    if not na(top) and not na(bot)
        result := (bull ? "BULL " : "BEAR ") + str.tostring(bot, format.mintick) + " - " + str.tostring(top, format.mintick) + " | d " + str.tostring(dist, "#.0") + " | " + st + " " + f_ageText(born) + " | " + f_scoreClass(score)
    result

f_bias(name, cont) =>
    string result = "-"
    if name == primaryTf
        result := "PRIMARY"
    if name == primaryTf and cont
        result := primaryBull ? "P CONT LONG" : "P CONT SHORT"
    result

reactionText = mainStatus
reactionMode = (bullRejection or bearRejection) ? "WICK" : (bullMomentum or bearMomentum) ? "MOM" : "-"
bosText = bullBosConfirm ? "CONFIRMED LONG" : bearBosConfirm ? "CONFIRMED SHORT" : "WAIT"
capText = hasCap ? capName + " " + str.tostring(capLevel, format.mintick) : "NO CAP"
eqText = hasPrimary ? str.tostring(primaryEq, format.mintick) : "-"

// TABLE DINAMICA
var table tbl = table.new(position.top_right, 3, 24, border_width=1)

if barstate.islast and showTable
    table.clear(tbl, 0, 0, 2, 23)

    table.cell(tbl, 0, 0, "ITEM", bgcolor=color.black, text_color=color.white)
    table.cell(tbl, 1, 0, "VALUE", bgcolor=color.black, text_color=color.white)
    table.cell(tbl, 2, 0, "STATUS", bgcolor=color.black, text_color=color.white)

    int row = 1

    primaryText = hasPrimary ? (primaryLocked ? "LOCKED | " : "") + primaryTf + " | SETUP " + primaryClass : "-"
    invalidationText = hasPrimary ? str.tostring(primaryInvalidation, format.mintick) : "-"

    table.cell(tbl, 0, row, "MAIN", bgcolor=color.yellow, text_color=color.black)
    table.cell(tbl, 1, row, primaryText, bgcolor=color.yellow, text_color=color.black)
    table.cell(tbl, 2, row, "", bgcolor=color.yellow, text_color=color.black)
    row += 1

    table.cell(tbl, 0, row, "REACT", bgcolor=color.black, text_color=color.white)
    table.cell(tbl, 1, row, reactionText, bgcolor=mainStatusColor, text_color=color.black)
    table.cell(tbl, 2, row, reactionMode, bgcolor=mainStatusColor, text_color=color.black)
    row += 1

    table.cell(tbl, 0, row, "INV", bgcolor=color.black, text_color=color.white)
    table.cell(tbl, 1, row, invalidationText, bgcolor=primaryInvalidated ? color.red : color.yellow, text_color=color.black)
    table.cell(tbl, 2, row, primaryInvalidated ? "BROKEN" : "VALID", bgcolor=primaryInvalidated ? color.red : color.yellow, text_color=color.black)
    row += 1

    table.cell(tbl, 0, row, "CAP", bgcolor=color.orange, text_color=color.black)
    table.cell(tbl, 1, row, capText, bgcolor=color.orange, text_color=color.black)
    table.cell(tbl, 2, row, hasCap ? "FVG CONTRARIA" : "ASSENTE", bgcolor=color.orange, text_color=color.black)
    row += 1

    table.cell(tbl, 0, row, "EQ", bgcolor=color.black, text_color=color.white)
    table.cell(tbl, 1, row, eqText, bgcolor=color.new(color.white, 20), text_color=color.black)
    table.cell(tbl, 2, row, "", bgcolor=color.new(color.white, 20), text_color=color.black)
    row += 1

    table.cell(tbl, 0, row, "BOS " + bosConfirmTf, bgcolor=color.black, text_color=color.white)
    table.cell(tbl, 1, row, bosText, bgcolor=color.new(color.green, 20), text_color=color.white)
    table.cell(tbl, 2, row, useBosConfirmation ? "MID TF" : "OFF", bgcolor=color.new(color.green, 20), text_color=color.white)
    row += 1

    color triggerColor = triggerStage == 5 ? color.lime : triggerStage == 4 ? color.new(color.green, 0) : triggerStage >= 2 ? color.orange : color.yellow
    table.cell(tbl, 0, row, "STATE", bgcolor=color.black, text_color=color.white)
    table.cell(tbl, 1, row, triggerText, bgcolor=triggerColor, text_color=color.black)
    table.cell(tbl, 2, row, "LTF " + triggerTf, bgcolor=triggerColor, text_color=color.black)
    row += 1

    table.cell(tbl, 0, row, "ACTION", bgcolor=color.black, text_color=color.white)
    table.cell(tbl, 1, row, triggerAction, bgcolor=triggerColor, text_color=color.black)
    table.cell(tbl, 2, row, triggerReady ? "RETEST EQ" : triggerExecuted ? "EXECUTED" : "WAIT", bgcolor=triggerColor, text_color=color.black)
    row += 1

    table.cell(tbl, 0, row, "ENTRY", bgcolor=color.black, text_color=color.white)
    table.cell(tbl, 1, row, not na(triggerEntry) ? str.tostring(triggerEntry, format.mintick) : "-", bgcolor=color.new(color.lime, 20), text_color=color.black)
    table.cell(tbl, 2, row, triggerStage >= 4 ? "RETEST BAR > BIRTH" : "-", bgcolor=color.new(color.lime, 20), text_color=color.black)
    row += 1

    table.cell(tbl, 0, row, "SL LTF", bgcolor=color.black, text_color=color.white)
    table.cell(tbl, 1, row, not na(triggerStop) ? str.tostring(triggerStop, format.mintick) : "-", bgcolor=color.new(color.red, 10), text_color=color.white)
    table.cell(tbl, 2, row, triggerStage >= 2 ? "FROZEN SWEEP" : "-", bgcolor=color.new(color.red, 10), text_color=color.white)
    row += 1

    table.cell(tbl, 0, row, "TP1", bgcolor=color.black, text_color=color.white)
    table.cell(tbl, 1, row, hasPrimary and not na(tp1) ? str.tostring(tp1, format.mintick) : "-", bgcolor=tp1Blocked ? color.orange : color.new(color.aqua, 20), text_color=color.white)
    table.cell(tbl, 2, row, tpStatus(tp1, tp1Blocked), bgcolor=tp1Blocked ? color.orange : color.new(color.aqua, 20), text_color=color.white)
    row += 1

    table.cell(tbl, 0, row, "TP2", bgcolor=color.black, text_color=color.white)
    table.cell(tbl, 1, row, hasPrimary and not na(tp2) ? str.tostring(tp2, format.mintick) : "-", bgcolor=tp2Blocked ? color.orange : color.new(color.aqua, 30), text_color=color.white)
    table.cell(tbl, 2, row, tpStatus(tp2, tp2Blocked), bgcolor=tp2Blocked ? color.orange : color.new(color.aqua, 30), text_color=color.white)
    row += 1

    table.cell(tbl, 0, row, "TP3", bgcolor=color.black, text_color=color.white)
    table.cell(tbl, 1, row, hasPrimary and not na(tp3) ? str.tostring(tp3, format.mintick) : "-", bgcolor=tp3Blocked ? color.orange : color.new(color.blue, 20), text_color=color.white)
    table.cell(tbl, 2, row, tpStatus(tp3, tp3Blocked), bgcolor=tp3Blocked ? color.orange : color.new(color.blue, 20), text_color=color.white)
    row += 1

    table.cell(tbl, 0, row, "FVG", bgcolor=color.black, text_color=color.white)
    table.cell(tbl, 1, row, "DETAIL", bgcolor=color.black, text_color=color.white)
    table.cell(tbl, 2, row, "BIAS", bgcolor=color.black, text_color=color.white)
    row += 1

    if not na(h1LTop) and not na(h1LBot)
        table.cell(tbl, 0, row, "H1 L", bgcolor=color.black, text_color=color.white)
        table.cell(tbl, 1, row, fmt(h1LTop, h1LBot, h1LDist, true, h1LState, h1LScore, h1LBorn), bgcolor=color.new(color.green, 28), text_color=color.white)
        table.cell(tbl, 2, row, f_bias("H1 LONG", h1LCont), bgcolor=color.new(color.green, 28), text_color=color.white)
        row += 1

    if not na(h1STop) and not na(h1SBot)
        table.cell(tbl, 0, row, "H1 S", bgcolor=color.black, text_color=color.white)
        table.cell(tbl, 1, row, fmt(h1STop, h1SBot, h1SDist, false, h1SState, h1SScore, h1SBorn), bgcolor=color.new(color.red, 28), text_color=color.white)
        table.cell(tbl, 2, row, f_bias("H1 SHORT", h1SCont), bgcolor=color.new(color.red, 28), text_color=color.white)
        row += 1

    if not na(h4LTop) and not na(h4LBot)
        table.cell(tbl, 0, row, "H4 L", bgcolor=color.black, text_color=color.white)
        table.cell(tbl, 1, row, fmt(h4LTop, h4LBot, h4LDist, true, h4LState, h4LScore, h4LBorn), bgcolor=color.new(color.green, 28), text_color=color.white)
        table.cell(tbl, 2, row, f_bias("H4 LONG", h4LCont), bgcolor=color.new(color.green, 28), text_color=color.white)
        row += 1

    if not na(h4STop) and not na(h4SBot)
        table.cell(tbl, 0, row, "H4 S", bgcolor=color.black, text_color=color.white)
        table.cell(tbl, 1, row, fmt(h4STop, h4SBot, h4SDist, false, h4SState, h4SScore, h4SBorn), bgcolor=color.new(color.red, 28), text_color=color.white)
        table.cell(tbl, 2, row, f_bias("H4 SHORT", h4SCont), bgcolor=color.new(color.red, 28), text_color=color.white)
        row += 1

    if not na(dLTop) and not na(dLBot)
        table.cell(tbl, 0, row, "D L", bgcolor=color.black, text_color=color.white)
        table.cell(tbl, 1, row, fmt(dLTop, dLBot, dLDist, true, dLState, dLScore, dLBorn), bgcolor=color.new(color.green, 28), text_color=color.white)
        table.cell(tbl, 2, row, f_bias("D LONG", dLCont), bgcolor=color.new(color.green, 28), text_color=color.white)
        row += 1

    if not na(dSTop) and not na(dSBot)
        table.cell(tbl, 0, row, "D S", bgcolor=color.black, text_color=color.white)
        table.cell(tbl, 1, row, fmt(dSTop, dSBot, dSDist, false, dSState, dSScore, dSBorn), bgcolor=color.new(color.red, 28), text_color=color.white)
        table.cell(tbl, 2, row, f_bias("D SHORT", dSCont), bgcolor=color.new(color.red, 28), text_color=color.white)
        row += 1

    if clusterLongExists and row <= 23
        table.cell(tbl, 0, row, "CL L", bgcolor=color.aqua, text_color=color.black)
        table.cell(tbl, 1, row, fmt(clusterLongTop, clusterLongBot, clusterLongDist, true, clusterLongState, clusterLongPrimaryScore, clusterLongBorn), bgcolor=color.new(color.green, 10), text_color=color.white)
        table.cell(tbl, 2, row, f_bias("CL LONG", clusterLongCont), bgcolor=color.new(color.green, 10), text_color=color.white)
        row += 1

    if clusterShortExists and row <= 23
        table.cell(tbl, 0, row, "CL S", bgcolor=color.aqua, text_color=color.black)
        table.cell(tbl, 1, row, fmt(clusterShortTop, clusterShortBot, clusterShortDist, false, clusterShortState, clusterShortPrimaryScore, clusterShortBorn), bgcolor=color.new(color.red, 10), text_color=color.white)
        table.cell(tbl, 2, row, f_bias("CL SHORT", clusterShortCont), bgcolor=color.new(color.red, 10), text_color=color.white)
        row += 1

// ALERTS
alertcondition(longSignal, title="Execute Long", message="EXECUTE LONG: BOS confermato sulla Primary FVG")
alertcondition(shortSignal, title="Execute Short", message="EXECUTE SHORT: BOS confermato sulla Primary FVG")
alertcondition(primaryInvalidated, title="Primary FVG Invalidated", message="Primary FVG invalidata")
alertcondition(clusterLongExists, title="H1/H4 Long FVG Cluster", message="Cluster LONG H1/H4 rilevato")
alertcondition(clusterShortExists, title="H1/H4 Short FVG Cluster", message="Cluster SHORT H1/H4 rilevato")
alertcondition(hasPrimary, title="PRIMARY FVG ACTIVE", message="Primary FVG attiva sopra soglia score")
alertcondition(primaryLocked and not primaryLocked[1], title="PRIMARY LOCKED", message="Primary FVG bloccata")
alertcondition(not primaryLocked and primaryLocked[1], title="PRIMARY UNLOCKED", message="Primary FVG sbloccata")

alertcondition(triggerReady, title="FSM MICRO FVG READY", message="Trigger LTF pronto: attendere retest EQ micro FVG")
alertcondition(triggerExecuted and primaryBull, title="LTF LONG TRIGGERED", message="Trigger LONG LTF eseguito sul retest della micro FVG")
alertcondition(triggerExecuted and not primaryBull, title="LTF SHORT TRIGGERED", message="Trigger SHORT LTF eseguito sul retest della micro FVG")

alertcondition(triggerResetReason == RESET_TIMEOUT and triggerResetReason[1] != RESET_TIMEOUT, title="LTF TRIGGER EXPIRED", message="Trigger LTF scaduto")
````

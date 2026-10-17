# Scalper Trend Day Filter v4 

- url: https://www.tradingview.com/script/fj35PTpi-Scalper-Trend-Day-Filter-v4/
- type: indicator
- pine_id: PUB;7c6b794f615e485789fcbeeddb01c006
- version: 3.0

## Description

What it does:
This indicator identifies high-probability intraday trade signals on NAS100 (and other CFD/futures instruments) using a dual-layer institutional scoring system built around the Opening Range Breakout (ORB).
How it works:
Every signal requires two independent scores to align:
ORB Score (0–5 pts): measures the quality of the ORB breakout — acceptance candles beyond the range, volume at the first level test, RVOL, daily ATR headroom, and directional context.
Breakout Quality Score (0–5 pts): measures real-time confirmation at the moment of the signal — candle direction, MACD 1m zero-line, RSI momentum (near 70/30 = strength, not obstacle), volume vs 2-sigma threshold, and price position relative to previous session VWAP and POC.
Three signal types:

A+ (large arrow): full alignment — ORB score 5/5 + BQ score ≥ 3 + confirmed directional context
RET (medium arrow): retest of the ORB level with confirmed volume + dynamic context
INV / CNT (small arrow): balance zone breakout after consolidation post-ORB

Context logic — static + dynamic:
Static context uses previous day High/Low. Dynamic context reads live session levels: if price breaks below VWAP, current POC, and previous session POC simultaneously, the indicator recognizes a real-time bearish bias even in a technically "neutral" day — and enables RET SHORT signals accordingly.
Levels plotted:

ORB High / Low (building + confirmed)
Previous Day High / Low
Previous session POC (orange) — yesterday's institutional volume node
Current session VWAP (blue) — live fair value
Current session POC (green) — where today's volume is concentrating

Recommended settings:

Timeframe: 1m or 5m
Instrument: NAS100, US100, equity futures, liquid CFDs
Session: set NY open/close to your chart timezone

## Source Code

````pine
//@version=6
indicator("Scalper Trend Day Filter v4 [CFD/NASDAQ]", overlay=true, max_bars_back=500)

// =====================================================================
//  SCALPER TREND DAY FILTER v4.2 - RISCRITTURA COMPLETA
//
//  SISTEMA IN DUE LIVELLI:
//
//  LIVELLO 1 - ORB SCORE (0-5pt):
//    1pt accettazione N candele fuori ORB
//    0-2pt volume prima rottura (0=debole, 1=moderato, 2=forte >2sigma)
//    1pt RVOL corrente >= minimo
//    1pt ATR daily non esaurito
//    1pt contesto (BULLISH per long, BEARISH per short)
//
//  LIVELLO 2 - BREAKOUT QUALITY SCORE (0-5pt, Mod.567 + Mod.533):
//    1pt candle direction (verde per long, rossa per short)
//    1pt MACD 5m sopra zero (long) o sotto zero (short)
//    1pt RSI 5m non ipercomprato (long <70) o non ipervenduto (short >30)
//    1pt RVOL alla rottura >= soglia forte
//    1pt posizione vs VWAP sessione precedente (proxy POC)
//
//  SEGNALE A+ : ORB score=5 E BQ score>=3
//  SEGNALE RET: ORB score>=4 E BQ score>=2 E retest su livello
//  SEGNALE INV: inversione da balance zone (MODO C)
//
//  CONTESTO NEUTRO = nessun segnale diretto
//  CONTESTO OPPOSTO = blocco totale
// =====================================================================

// -------------------------------------------------------
// INPUTS
// -------------------------------------------------------

g0 = "SESSIONE NY"
i_openHour  = input.int(15, "Ora Apertura NY",    minval=0, maxval=23, group=g0)
i_openMin   = input.int(30, "Minuto Apertura NY", minval=0, maxval=59, group=g0)
i_closeHour = input.int(22, "Ora Chiusura NY",    minval=0, maxval=23, group=g0)
i_closeMin  = input.int(0,  "Minuto Chiusura NY", minval=0, maxval=59, group=g0)

g1 = "ORB"
i_orbMin     = input.int(15, "Finestra ORB (minuti)",   minval=5,  maxval=60,  group=g1)
i_acceptance = input.int(4,  "Candele Accettazione",    minval=1,  maxval=10,  group=g1)

g2 = "VOLUME"
i_sessMin    = input.int  (390,  "Durata Sessione (minuti)", minval=30, maxval=1440, group=g2,
     tooltip="NAS100/Stocks 6.5h=390 | DAX 8.5h=510 | Crypto/Forex 24h=1440. Su 5m dividi per 5.")
i_rvolLen    = i_sessMin
i_rvolMin    = input.float(1.2,  "RVOL Minimo",           minval=0.3,maxval=6.0, step=0.1, group=g2,
     tooltip="NAS100: 1.2 ok. Strumenti meno liquidi o forex: prova 1.1 o 1.0.")
i_volStdMult = input.float(2.0,  "Dev Std soglia forte",  minval=1.0,maxval=4.0, step=0.5, group=g2)

g3 = "ATR"
i_atrLen    = input.int  (14,   "ATR Periodo Daily",  minval=5,  maxval=50,  group=g3)
i_atrMaxPct = input.float(70.0, "ATR Daily Pct Max",  minval=20, maxval=100, step=5,   group=g3)

g4 = "QUALITA BREAKOUT (1m)"
i_rsiLen    = input.int(14, "RSI Periodo (1m)",    minval=5, maxval=30,  group=g4)
i_rsiOB     = input.int(70, "RSI Ipercomprato",    minval=60,maxval=85,  group=g4)
i_rsiOS     = input.int(30, "RSI Ipervenduto",     minval=15,maxval=40,  group=g4)
i_macdFast  = input.int(12, "MACD Fast (1m)",      minval=3, maxval=20,  group=g4)
i_macdSlow  = input.int(26, "MACD Slow (1m)",      minval=10,maxval=50,  group=g4)
i_tapeOn    = input.bool(true, "Abilita Tape Analysis", group=g4, tooltip="Calcola bull/bear volume ratio intra-barra. Su 5m usa dati 1m interni. Su 1m usa ultime 3 barre.")
i_tapeRatio = input.float(1.5, "Tape Ratio minimo",  minval=1.0, maxval=5.0, step=0.1, group=g4, tooltip="Ratio bull/bear minimo per punto BQ. 1.5 = compratori 50% piu aggressivi dei venditori.")
i_absorbPct = input.float(30.0,"Absorbed Max % (retest)", minval=5.0, maxval=80.0, step=5.0, group=g4, tooltip="Se volume assorbito supera questa % del totale al retest, il livello e difeso = segnale piu affidabile.")

g5 = "RETEST e BALANCE"
i_retestPct = input.float(0.05, "Zona Retest ORB Pct",  minval=0.01,maxval=0.5, step=0.01, group=g5)
i_balLookbk = input.int  (10,   "Balance Lookback",     minval=3,   maxval=30,            group=g5)
i_balMaxPct = input.float(0.20, "Balance Max Ampiezza", minval=0.05,maxval=1.0, step=0.05, group=g5)

g6 = "DISPLAY"
i_showTable = input.bool(true, "Mostra Tabella", group=g6)
i_showPDHL  = input.bool(true, "Prev Day H/L",  group=g6)


// -------------------------------------------------------
// SESSIONE
// -------------------------------------------------------

barTimeInt        = hour(time) * 100 + minute(time)
inSession         = barTimeInt >= (i_openHour*100 + i_openMin) and barTimeInt < (i_closeHour*100 + i_closeMin)
sessionJustOpened = inSession and not inSession[1]


// -------------------------------------------------------
// ORB
// -------------------------------------------------------

var float _oH    = float(na)
var float _oL    = float(na)
var bool  _oDone = false
var int   _oStart= int(na)

if sessionJustOpened
    _oH    := float(na)
    _oL    := float(na)
    _oDone := false
    _oStart:= time

orbMs    = i_orbMin * 60 * 1000
inWindow = inSession and not na(_oStart) and (time - _oStart) < orbMs

if inWindow
    _oH := na(_oH) ? high : math.max(_oH, high)
    _oL := na(_oL) ? low  : math.min(_oL, low)

if inSession and not na(_oStart) and (time - _oStart) >= orbMs and not _oDone
    _oDone := true


// -------------------------------------------------------
// VOLUME
// -------------------------------------------------------

volAvg      = ta.sma  (volume, i_rvolLen)
volStdRaw   = ta.stdev(volume, i_rvolLen)
volStd      = nz(volStdRaw, 0.0)
rvol        = volAvg > 0 ? volume / volAvg : 0.0
volThreshM  = volAvg * 1.2
volThreshS  = volAvg + i_volStdMult * volStd
rvolOk      = rvol >= i_rvolMin
volStrongNow= volume >= volThreshS


// -------------------------------------------------------
// ATR DAILY
// -------------------------------------------------------

dailyATR = request.security(syminfo.tickerid, "D", ta.atr(i_atrLen), lookahead=barmerge.lookahead_off)

var float _sessOpen = float(na)
if sessionJustOpened
    _sessOpen := open

dayMove    = not na(_sessOpen) and inSession ? math.abs(close - _sessOpen) : 0.0
atrSafe    = nz(dailyATR, 1.0)
atrUsedPct = atrSafe > 0 ? (dayMove / atrSafe) * 100 : 0.0
atrOk      = not na(dailyATR) and atrUsedPct < i_atrMaxPct


// -------------------------------------------------------
// CONTESTO (Prev Day H/L)
// -------------------------------------------------------

pdH = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
pdL = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_off)

bullCtx = not na(pdH) and close > pdH
bearCtx = not na(pdL) and close < pdL
neutCtx = not bullCtx and not bearCtx


// -------------------------------------------------------
// ACCETTAZIONE ORB (CW10002 fix: calcola prima del confronto)
// -------------------------------------------------------

lowestC  = ta.lowest (close, i_acceptance)
highestC = ta.highest(close, i_acceptance)
longAcc  = _oDone and lowestC  > _oH
shortAcc = _oDone and highestC < _oL


// -------------------------------------------------------
// INVALIDAZIONE TESI
// -------------------------------------------------------

var bool _longInval  = false
var bool _shortInval = false

if sessionJustOpened
    _longInval  := false
    _shortInval := false

if longAcc  and not na(_oL) and close < _oL
    _longInval  := true
if shortAcc and not na(_oH) and close > _oH
    _shortInval := true


// -------------------------------------------------------
// VOLUME PRIMO TEST DEL LIVELLO ORB (aggiornato ad ogni touch)
// -------------------------------------------------------

touchZone = i_retestPct / 100.0

var float _bvL = float(na)
var float _bvS = float(na)

if sessionJustOpened
    _bvL := float(na)
    _bvS := float(na)

if _oDone and not na(_oH) and math.abs(close - _oH) / _oH <= touchZone
    _bvL := volume
if _oDone and not na(_oL) and math.abs(close - _oL) / _oL <= touchZone
    _bvS := volume

bvL = nz(_bvL, 0.0)
bvS = nz(_bvS, 0.0)
brkScoreL = bvL >= volThreshS ? 2 : bvL >= volThreshM ? 1 : 0
brkScoreS = bvS >= volThreshS ? 2 : bvS >= volThreshM ? 1 : 0


// -------------------------------------------------------
// LIVELLO 1 - ORB SCORE (max 5pt)
// -------------------------------------------------------

sc_L_a = longAcc  ? 1 : 0
sc_L_v = brkScoreL
sc_L_r = rvolOk   ? 1 : 0
sc_L_t = atrOk    ? 1 : 0
sc_L_c = bullCtx  ? 1 : 0
orbScoreL = sc_L_a + sc_L_v + sc_L_r + sc_L_t + sc_L_c

sc_S_a = shortAcc ? 1 : 0
sc_S_v = brkScoreS
sc_S_r = rvolOk   ? 1 : 0
sc_S_t = atrOk    ? 1 : 0
sc_S_c = bearCtx  ? 1 : 0
orbScoreS = sc_S_a + sc_S_v + sc_S_r + sc_S_t + sc_S_c

blockedL = bearCtx
blockedS = bullCtx


// -------------------------------------------------------
// LIVELLO 2 - BREAKOUT QUALITY SCORE (max 5pt, Mod.567)
// Calcola su 5m: RSI, MACD, VWAP sessione precedente
// -------------------------------------------------------

// RSI su 1m - stesso timeframe del grafico operativo (Mod.375)
rsi5m  = request.security(syminfo.tickerid, "1", ta.rsi(close, i_rsiLen), lookahead=barmerge.lookahead_off)
// MACD su 1m - decisioni sul breakout avvengono in secondi (Mod.567, Mod.113)
ema12_5m = request.security(syminfo.tickerid, "1", ta.ema(close, i_macdFast), lookahead=barmerge.lookahead_off)
ema26_5m = request.security(syminfo.tickerid, "1", ta.ema(close, i_macdSlow), lookahead=barmerge.lookahead_off)
macd5m = nz(ema12_5m, close) - nz(ema26_5m, close)

// -------------------------------------------------------
// TAPE ANALYSIS - Bull/Bear Volume Ratio (Mod.137, Mod.282)
// -------------------------------------------------------
var float tapeBullVol  = 0.0
var float tapeBearVol  = 0.0
var float tapeAbsoVol  = 0.0
var float tapeTotalVol = 0.0
var float tapeRatioVal = 0.0

if i_tapeOn
    ltfClose = request.security_lower_tf(syminfo.tickerid, "1", close)
    ltfVol   = request.security_lower_tf(syminfo.tickerid, "1", volume)
    tbull = 0.0
    tbear = 0.0
    tabso = 0.0
    ltfSize = array.size(ltfClose)
    if ltfSize > 1
        for i = 0 to ltfSize - 2
            c1 = array.get(ltfClose, i)
            c2 = array.get(ltfClose, i + 1)
            v  = array.get(ltfVol, i)
            if c1 > c2
                tbull += v
            else if c1 < c2
                tbear += v
            else
                tabso += v
    else
        tbull := close > open ? volume : 0.0
        tbear := close < open ? volume : 0.0
        tabso := close == open ? volume : 0.0
    tapeBullVol  := tbull
    tapeBearVol  := tbear
    tapeAbsoVol  := tabso
    tapeTotalVol := tbull + tbear + tabso
    if tapeBullVol > tapeBearVol
        tapeRatioVal := tapeBullVol / math.max(tapeBearVol + tapeAbsoVol, 1.0)
    else if tapeBearVol > tapeBullVol
        tapeRatioVal := -(tapeBearVol / math.max(tapeBullVol + tapeAbsoVol, 1.0))
    else
        tapeRatioVal := 0.0
else
    tapeRatioVal := close > open ? 1.5 : close < open ? -1.5 : 0.0

tapeAbsoPct  = tapeTotalVol > 0 ? (tapeAbsoVol / tapeTotalVol) * 100 : 0.0
tapeLongOk   = tapeRatioVal >= i_tapeRatio
tapeShortOk  = tapeRatioVal <= -i_tapeRatio
tapeDefended = tapeAbsoPct >= i_absorbPct

// -------------------------------------------------------
// VWAP SESSIONE NY (manuale - solo ore NY, esclude overnight)
// -------------------------------------------------------
var float _cumPV       = 0.0
var float _cumV        = 0.0
var float prevSessVWAP = float(na)

if sessionJustOpened
    if _cumV > 0
        prevSessVWAP := _cumPV / _cumV
    _cumPV := 0.0
    _cumV  := 0.0

if inSession
    _cumPV += ((high + low + close) / 3.0) * volume
    _cumV  += volume

sessVWAP = _cumV > 0 ? _cumPV / _cumV : float(na)
prevVWAP = prevSessVWAP

// -------------------------------------------------------
// POC SESSIONE NY - calcolo CORRETTO con bucket fissi
//
// PROBLEMA del vecchio codice: bucket size ricalcolata ogni barra
// mentre il range si espande -> volume assegnato a prezzi sbagliati
//
// SOLUZIONE: bucket size FISSA all apetura, basata sul range del
// giorno precedente. I bucket non cambiano mai durante la sessione.
// Volume fuori range va ai bucket estremi (edge clipping).
// -------------------------------------------------------

int   N_POC   = 50
float POC_MUL = 1.5

var array<float> _pocArr = array.new_float(N_POC, 0.0)
var float _pocBase       = float(na)
var float _pocBSize      = float(na)
var float prevPOC        = float(na)
var float _pocHi         = float(na)
var float _pocLo         = float(na)

// All apertura: fissa il grid usando range del giorno precedente
if sessionJustOpened
    // Salva POC sessione precedente prima del reset
    if not na(_pocBase) and not na(_pocBSize)
        maxV3  = 0.0
        maxB3  = 0
        for i = 0 to N_POC - 1
            v3 = array.get(_pocArr, i)
            if v3 > maxV3
                maxV3 := v3
                maxB3 := i
        prevPOC := _pocBase + (maxB3 + 0.5) * _pocBSize

    // Reset array
    array.fill(_pocArr, 0.0)
    _pocHi := float(na)
    _pocLo := float(na)

    // Fissa grid con range ieri (prevHi/prevLo gia calcolati)
    // Se non disponibili usa ATR come fallback
    refRange = not na(pdH) and not na(pdL) and pdH > pdL ? (pdH - pdL) * POC_MUL : nz(dailyATR, 200.0) * POC_MUL
    refLo    = not na(pdL) ? pdL - refRange * 0.1 : close - refRange * 0.5
    _pocBase  := refLo
    _pocBSize := refRange / N_POC

// Accumula volume durante la sessione NY con bucket FISSI
if inSession and not na(_pocBase) and not na(_pocBSize) and _pocBSize > 0
    _pocHi := na(_pocHi) ? high : math.max(_pocHi, high)
    _pocLo := na(_pocLo) ? low  : math.min(_pocLo, low)
    typ    = (high + low + close) / 3.0
    bIdx   = int(math.floor((typ - _pocBase) / _pocBSize))
    bIdx  := math.max(0, math.min(N_POC - 1, bIdx))
    array.set(_pocArr, bIdx, array.get(_pocArr, bIdx) + volume)

// POC corrente: prezzo con massimo volume accumulato nella sessione
curPOC = float(na)
if not na(_pocBase) and not na(_pocBSize)
    maxV4 = 0.0
    maxB4 = 0
    for i = 0 to N_POC - 1
        v4 = array.get(_pocArr, i)
        if v4 > maxV4
            maxV4 := v4
            maxB4 := i
    curPOC := _pocBase + (maxB4 + 0.5) * _pocBSize

rsiSafe = nz(rsi5m, 50.0)
macdSafe= macd5m

// TAPE come peso variabile (Mod.137, Mod.282, Mod.293):
// ratio >= 3.0 = aggressione forte istituzionale = 2pt
// ratio 1.5-3.0 = partecipazione buona = 1pt
// ratio < 1.5 = no aggressione = 0pt + blocca A+
bq_L_tape   = tapeRatioVal >= 3.0 ? 2 : tapeRatioVal >= i_tapeRatio ? 1 : 0
bq_L_candle = bq_L_tape
bq_L_macd   = macdSafe > 0 ? 1 : 0
bq_L_rsi    = rsiSafe >= i_rsiOB ? 1 : 0
bq_L_rvol   = bvL >= volThreshS ? 1 : 0
// POC/VWAP logic (Mod.255, Mod.277):
// Prezzo sopra ENTRAMBI prevPOC e prevVWAP = bullish istituzionale confermato
// Prezzo sotto ENTRAMBI = bearish confermato
// Tra i due = zona grigia, no punto

// Long: sopra entrambi i riferimenti (massima confluence bullish)
aboveBothL  = (na(prevPOC) or close > prevPOC) and (na(prevVWAP) or close > prevVWAP)
bq_L_poc    = aboveBothL ? 1 : 0

// Resistenza vicina: prevPOC sopra il prezzo entro 0.3% = magnet, riduce qualita long
pocResNear  = not na(prevPOC) and prevPOC > close and (prevPOC - close) / close < 0.003

bqScoreL    = bq_L_candle + bq_L_macd + bq_L_rsi + bq_L_rvol + bq_L_poc

bq_S_tape   = tapeRatioVal <= -3.0 ? 2 : tapeRatioVal <= -i_tapeRatio ? 1 : 0
bq_S_candle = bq_S_tape
bq_S_macd   = macdSafe < 0 ? 1 : 0
bq_S_rsi    = rsiSafe <= i_rsiOS ? 1 : 0
bq_S_rvol   = bvS >= volThreshS ? 1 : 0

// Short: sotto entrambi i riferimenti
belowBothS  = (na(prevPOC) or close < prevPOC) and (na(prevVWAP) or close < prevVWAP)
bq_S_poc    = belowBothS ? 1 : 0

// Supporto vicino: prevPOC sotto il prezzo entro 0.3% = magnet, riduce qualita short
pocSupNear  = not na(prevPOC) and prevPOC < close and (close - prevPOC) / close < 0.003

bqScoreS    = bq_S_candle + bq_S_macd + bq_S_rsi + bq_S_rvol + bq_S_poc


// -------------------------------------------------------
// CONTESTO DINAMICO (Mod.255, Mod.361, Mod.283)
// Il contesto "statico" usa ieri H/L -> lento, si aggiorna una volta al giorno
// Il contesto "dinamico" usa i livelli ATTUALI della sessione:
//   se prezzo < sessVWAP E < curPOC E < prevPOC = DINAMICAMENTE BEARISH
//   se prezzo > sessVWAP E > curPOC E > prevPOC = DINAMICAMENTE BULLISH
// Rottura multipla di livelli istituzionali = bias direzionale reale (Mod.255)
// -------------------------------------------------------

vwapOk    = not na(sessVWAP)
pocCurOk  = not na(curPOC)
pocPrevOk = not na(prevPOC)

// Dinamicamente bearish: sotto TUTTI i livelli disponibili
dynBear = (not vwapOk or close < sessVWAP) and (not pocCurOk or close < curPOC) and (not pocPrevOk or close < prevPOC)
dynBull = (not vwapOk or close > sessVWAP) and (not pocCurOk or close > curPOC) and (not pocPrevOk or close > prevPOC)

// Contesto EFFETTIVO = statico (ieri H/L) OR dinamico (livelli sessione)
// Il dinamico pesa di piu sul retest perche e' in tempo reale
effBull = bullCtx or (neutCtx and dynBull)
effBear = bearCtx or (neutCtx and dynBear)

// -------------------------------------------------------
// BALANCE ZONE DETECTION (Mod.305)
// ta.highest/lowest globali (CW10002 fix)
// -------------------------------------------------------

balH = ta.highest(high, i_balLookbk)[1]
balL = ta.lowest (low,  i_balLookbk)[1]
balRange    = nz(balH, close) - nz(balL, close)
balMaxRange = close * (i_balMaxPct / 100.0)
isTightBal  = not na(balH) and not na(balL) and balRange > 0 and balRange <= balMaxRange


// -------------------------------------------------------
// SEGNALE A+ DIRETTO
// ORB score=5 + BQ score>=3 + no blocco
// -------------------------------------------------------

// A+ richiede:
// 1. Contesto coerente (no NEUTRO) - Mod.190
// 2. Tape presente (bq_L_tape > 0) - senza aggressione no segnale - Mod.137
// 3. POC non come resistenza/supporto immediata
modeA_L = not blockedL and bullCtx and orbScoreL == 5 and bqScoreL >= 3 and bq_L_tape > 0 and not pocResNear and inSession
modeA_S = not blockedS and bearCtx and orbScoreS == 5 and bqScoreS >= 3 and bq_S_tape > 0 and not pocSupNear and inSession

// LOCK: un solo segnale per accettazione (evita frecce multiple)
var bool _lockA_L = false
var bool _lockA_S = false
if sessionJustOpened
    _lockA_L := false
    _lockA_S := false
if not longAcc
    _lockA_L := false
if not shortAcc
    _lockA_S := false

sigA_L = modeA_L and not _lockA_L
sigA_S = modeA_S and not _lockA_S
if sigA_L
    _lockA_L := true
if sigA_S
    _lockA_S := true


// -------------------------------------------------------
// SEGNALE RET (retest su livello ORB)
// ORB score>=4 + BQ score>=2 + prezzo torna al livello + vol forte
// -------------------------------------------------------

retZ = i_retestPct / 100.0

// RET usa contesto EFFETTIVO + tape defense (livello difeso da assorbimento = qualita retest)
// In NEUTRO con rottura multipla livelli (dynBear/dynBull) il retest e' valido
retLCond = longAcc and not _longInval and not na(_oH) and close >= _oH and (close - _oH) / _oH <= retZ and (volStrongNow or tapeDefended) and rvolOk and atrOk and not blockedL and inSession and bqScoreL >= 2 and (orbScoreL - sc_L_c) >= 3 and effBull and (bq_L_tape > 0 or tapeDefended)
retSCond = shortAcc and not _shortInval and not na(_oL) and close <= _oL and (_oL - close) / _oL <= retZ and (volStrongNow or tapeDefended) and rvolOk and atrOk and not blockedS and inSession and bqScoreS >= 2 and (orbScoreS - sc_S_c) >= 3 and effBear and (bq_S_tape > 0 or tapeDefended)

modeB_L = retLCond
modeB_S = retSCond
sigB_L  = modeB_L and not modeB_L[1]
sigB_S  = modeB_S and not modeB_S[1]


// -------------------------------------------------------
// SEGNALE INV / CNT (balance zone break, Modo C)
// -------------------------------------------------------

modeC_invL = shortAcc and not _shortInval and isTightBal and close > balH and volStrongNow and rvolOk and atrOk and not blockedL and inSession and bqScoreL >= 2 and effBull
modeC_invS = longAcc  and not _longInval  and isTightBal and close < balL and volStrongNow and rvolOk and atrOk and not blockedS and inSession and bqScoreS >= 2 and effBear
modeC_cntL = longAcc  and not _longInval  and isTightBal and close > balH and volStrongNow and rvolOk and atrOk and not blockedL and inSession and bqScoreL >= 2 and effBull
modeC_cntS = shortAcc and not _shortInval and isTightBal and close < balL and volStrongNow and rvolOk and atrOk and not blockedS and inSession and bqScoreS >= 2 and effBear

sigC_invL = modeC_invL and not modeC_invL[1]
sigC_invS = modeC_invS and not modeC_invS[1]
sigC_cntL = modeC_cntL and not modeC_cntL[1]
sigC_cntS = modeC_cntS and not modeC_cntS[1]


// -------------------------------------------------------
// PLOTS
// -------------------------------------------------------

plot(inWindow ? _oH : na, "ORB H bld", color.new(color.lime, 55), 1, plot.style_linebr)
plot(inWindow ? _oL : na, "ORB L bld", color.new(color.red,  55), 1, plot.style_linebr)
pOH = plot(_oDone ? _oH : na, "ORB H", color.new(color.lime, 0), 2, plot.style_linebr)
pOL = plot(_oDone ? _oL : na, "ORB L", color.new(color.red,  0), 2, plot.style_linebr)
fill(pOH, pOL, color.new(color.gray, 87))

plot(i_showPDHL ? pdH : na, "PD High", color.new(color.aqua,   40), 1, plot.style_linebr)
plot(i_showPDHL ? pdL : na, "PD Low",  color.new(color.orange, 40), 1, plot.style_linebr)
// Prev VWAP: usato solo internamente per calcoli (non plottato)
// POC ieri = linea arancio tratteggiata (livello istituzionale chiave)
// POC oggi = linea verde chiaro (si aggiorna, mostra dove si sta costruendo volume)
// VWAP oggi = linea azzurra (fair value corrente di sessione)
plot(not na(prevPOC)  ? prevPOC  : na, "POC Ieri (arancio)",         color.new(color.orange, 20), 2, plot.style_linebr)
plot(not na(sessVWAP) ? sessVWAP : na, "VWAP NY oggi (azzurro)",     color.new(color.aqua,   40), 1, plot.style_linebr)
plot(not na(curPOC)   ? curPOC   : na, "POC NY oggi (verde)",        color.new(color.lime,   40), 1, plot.style_linebr)

plotshape(sigA_L, title="A+ LONG",  style=shape.triangleup,   location=location.belowbar, color=color.new(color.lime,   0),  size=size.large,  text="A+ L",  textcolor=color.white)
plotshape(sigA_S, title="A+ SHORT", style=shape.triangledown, location=location.abovebar, color=color.new(color.red,    0),  size=size.large,  text="A+ S",  textcolor=color.white)
plotshape(sigB_L, title="RET LONG", style=shape.triangleup,   location=location.belowbar, color=color.new(color.lime,  40),  size=size.normal, text="RET L", textcolor=color.white)
plotshape(sigB_S, title="RET SHORT",style=shape.triangledown, location=location.abovebar, color=color.new(color.red,   40),  size=size.normal, text="RET S", textcolor=color.white)
plotshape(sigC_invL, title="INV L", style=shape.triangleup,   location=location.belowbar, color=color.new(color.yellow, 0),  size=size.normal, text="INV L", textcolor=color.black)
plotshape(sigC_invS, title="INV S", style=shape.triangledown, location=location.abovebar, color=color.new(color.yellow, 0),  size=size.normal, text="INV S", textcolor=color.black)
plotshape(sigC_cntL, title="CNT L", style=shape.triangleup,   location=location.belowbar, color=color.new(color.purple,20),  size=size.normal, text="CNT L", textcolor=color.white)
plotshape(sigC_cntS, title="CNT S", style=shape.triangledown, location=location.abovebar, color=color.new(color.purple,20),  size=size.normal, text="CNT S", textcolor=color.white)

bgcolor(inSession ? color.new(color.blue, 97) : na)
bgcolor(inSession and not atrOk ? color.new(color.red, 91) : na, title="ATR esaurito")


// -------------------------------------------------------
// ALERTS
// -------------------------------------------------------

alertcondition(sigA_L,   "A+ LONG",   "A+ LONG {{ticker}} @ {{close}}")
alertcondition(sigA_S,   "A+ SHORT",  "A+ SHORT {{ticker}} @ {{close}}")
alertcondition(sigB_L,   "RET LONG",  "RETEST LONG {{ticker}} @ {{close}}")
alertcondition(sigB_S,   "RET SHORT", "RETEST SHORT {{ticker}} @ {{close}}")
alertcondition(sigC_invL,"INV LONG",  "INVERSIONE LONG {{ticker}} @ {{close}}")
alertcondition(sigC_invS,"INV SHORT", "INVERSIONE SHORT {{ticker}} @ {{close}}")
alertcondition(sigC_cntL,"CNT LONG",  "CONTINUAZIONE LONG {{ticker}} @ {{close}}")
alertcondition(sigC_cntS,"CNT SHORT", "CONTINUAZIONE SHORT {{ticker}} @ {{close}}")
alertcondition(sigA_L or sigA_S or sigB_L or sigB_S or sigC_invL or sigC_invS or sigC_cntL or sigC_cntS, "Segnale v4", "Segnale {{ticker}} @ {{close}}")


// -------------------------------------------------------
// TABELLA (20 righe)
// -------------------------------------------------------

var table tbl = table.new(position.top_right, 2, 7, bgcolor=color.new(color.black, 45), border_color=color.new(color.gray, 50), border_width=1, frame_color=color.new(color.gray, 50), frame_width=1)

if i_showTable
    // HEADER
    table.cell(tbl, 0, 0, "SCALPER v4.2",  text_color=color.white,  bgcolor=color.new(color.navy,20), text_size=size.small)
    table.cell(tbl, 1, 0, syminfo.ticker,   text_color=color.yellow, bgcolor=color.new(color.navy,20), text_size=size.small)

    // ORB
    clrOrb = _oDone?color.lime:inWindow?color.yellow:color.gray
    strOrb = _oDone?"ORB " + str.tostring(i_orbMin)+"min OK":inWindow?"BUILDING...":"attendi 15:30"
    table.cell(tbl, 0, 1, "ORB",           text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 1, strOrb,          text_color=clrOrb, text_size=size.small)

    // CONTESTO
    ctxStr2 = bullCtx?"BULLISH sopra PD H":bearCtx?"BEARISH sotto PD L":dynBull?"DYN BULLISH":dynBear?"DYN BEARISH":"NEUTRO"
    ctxClr2 = (bullCtx or dynBull)?color.lime:(bearCtx or dynBear)?color.red:color.yellow
    table.cell(tbl, 0, 2, "Contesto",      text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 2, ctxStr2,         text_color=ctxClr2, text_size=size.small)

    // TAPE RATIO
    // Mostra: ratio numerico + direzione + absorbed %
    tapeNum  = str.tostring(math.abs(tapeRatioVal),"#.##")
    tapeDir  = tapeRatioVal >= 3.0?"BULL FORTE":tapeRatioVal >= i_tapeRatio?"BULL":tapeRatioVal <= -3.0?"BEAR FORTE":tapeRatioVal <= -i_tapeRatio?"BEAR":"NEUTRO"
    tapeAbsS = " | abs " + str.tostring(tapeAbsoPct,"#.0") + "%"
    tapeClr2 = (tapeRatioVal >= 3.0)?color.lime:(tapeRatioVal >= i_tapeRatio)?color.new(color.lime,40):(tapeRatioVal <= -3.0)?color.red:(tapeRatioVal <= -i_tapeRatio)?color.new(color.red,40):color.gray
    table.cell(tbl, 0, 3, "TAPE",          text_color=color.silver, text_size=size.small, bgcolor=color.new(color.navy,50))
    table.cell(tbl, 1, 3, tapeNum + " " + tapeDir + tapeAbsS, text_color=tapeClr2, text_size=size.small, bgcolor=color.new(color.navy,50))

    // RVOL
    rvolStr2 = str.tostring(rvol,"#.##") + "x"
    rvolClr2 = rvol >= 2.0?color.lime:rvol >= i_rvolMin?color.new(color.lime,40):color.red
    rvolLbl  = rvol >= 2.0?" FORTE":rvol >= i_rvolMin?" OK":" BASSO"
    table.cell(tbl, 0, 4, "RVOL",          text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 4, rvolStr2 + rvolLbl, text_color=rvolClr2, text_size=size.small)

    // VOL AL LIVELLO
    vbLstr = na(_bvL)?"no test":str.tostring(math.round(bvL))+(brkScoreL==2?" FORTE":brkScoreL==1?" MOD":" DEB")
    vbSstr = na(_bvS)?"no test":str.tostring(math.round(bvS))+(brkScoreS==2?" FORTE":brkScoreS==1?" MOD":" DEB")
    volLvlStr = "L:" + vbLstr + "  S:" + vbSstr
    volLvlClr = (brkScoreL==2 or brkScoreS==2)?color.lime:(brkScoreL==1 or brkScoreS==1)?color.yellow:color.gray
    table.cell(tbl, 0, 5, "Vol Livello",   text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 5, volLvlStr,       text_color=volLvlClr, text_size=size.small)

    // SEGNALE
    finS2 = modeA_L?"A+ LONG":modeA_S?"A+ SHORT":modeB_L?"RET LONG":modeB_S?"RET SHORT":modeC_invL?"INV LONG":modeC_invS?"INV SHORT":modeC_cntL?"CNT LONG":modeC_cntS?"CNT SHORT":"ATTENDI"
    finC2 = (modeA_L or modeB_L or modeC_invL or modeC_cntL)?color.lime:(modeA_S or modeB_S or modeC_invS or modeC_cntS)?color.red:color.gray
    finBG  = (modeA_L or modeA_S)?color.new(color.navy,0):(modeB_L or modeB_S or modeC_invL or modeC_invS or modeC_cntL or modeC_cntS)?color.new(color.navy,40):color.new(color.black,45)
    table.cell(tbl, 0, 6, "SEGNALE",       text_color=color.silver, text_size=size.small, bgcolor=finBG)
    table.cell(tbl, 1, 6, finS2,           text_color=finC2, text_size=size.small, bgcolor=finBG)

// =====================================================================
//  FINE v4.2
// =====================================================================
````

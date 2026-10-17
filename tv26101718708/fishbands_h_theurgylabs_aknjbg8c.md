# FishBands H TheurgyLabs

- url: https://www.tradingview.com/script/akNjbG8c-FishBands-H-TheurgyLabs/
- type: indicator
- pine_id: PUB;412e782fc5c8413ba360d258f0142866
- version: 1.0

## Description

FishBands H is the companion oscillator for the FishBands overlay. It renders the Fisher Transform mechanism in a separate pane — the histogram, the Fisher and Trigger lines, the learned adaptive thresholds, and the turn dots that show exactly where each signal decision happens. The signal chain is byte-identical to the overlay: same inputs, same logic, same fires.

Pair with the FishBands overlay to see both the price-level view (ribbon, bands, triangles) and the oscillator-level view (Fisher extremes, threshold crossings, momentum state) simultaneously.

## What It Shows

The Fisher histogram (Fisher minus Trigger) uses 4-state momentum coloring. Bright green means the histogram is positive and accelerating. Dim green means positive but decelerating. Bright red means negative and accelerating. Dim red means negative but decelerating. This shows the direction and intensity of Fisher momentum at a glance.

The Fisher line (blue) is the Ehlers Fisher Transform computed on ATR-normalized spread from the overlay's SMMA ribbon. The Trigger line (gold) is the prior bar's Fisher value — turns are detected when the Fisher changes direction relative to the Trigger.

The upper threshold (magenta) is the rolling mean of Fisher peak levels over a 124-bar lookback window. The lower threshold (cyan) is the mean of valley levels. A buy fires when the Fisher turns up and the crossover level (midpoint of Fisher and Trigger) is below the lower threshold. A sell fires when the Fisher turns down and the crossover level is above the upper threshold.

## Turn Dots

Every Fisher turn is logged as a dim gray dot at the crossLevel. Turns that pass all gates and fire as actual signals are plotted as bright dots — cyan for buys, magenta for sells. This makes it easy to see which turns were deep enough to qualify and which were filtered out. Most turns are dim (logged only); the bright ones are the signals the overlay fires.

## Divergence Marks

RSI divergence confirmations appear as green circles (bull, price lower-low with RSI higher-low) and red circles (bear, price higher-high with RSI lower-high). ADX divergence confirmations appear as gold crosses (bull, price lower-low with fading trend strength) and silver crosses (bear, price higher-high with fading trend strength). These are the same marks shown on the overlay — they appear at the Fisher line level in the oscillator pane for easy correlation with the Fisher state at the time of confirmation.

## SpreadZ Line

The SpreadZ line (regime-colored, scaled 10x for visibility) shows the z-scored ATR-normalized ribbon spread — the same computation used by the SpreadZ Override in the signal chain. Zero-cross diamonds mark when spreadZ crosses its zero line (cyan = cross up, magenta = cross down). Both the line and diamonds default OFF and can be toggled in the SpreadZ input group.

## Band Filter

The companion replicates the overlay's full Donchian penetration-learning band computation. Donchian Length, Penetration Learning, Pen Learn Bars, Band Smoothing, and ATR Mult inputs match the overlay's ATR/Bands group. The Band Filter toggle and Band Offset (ATR) match the overlay's Band Filter group. When enabled, the filter requires price near the learned bands for a signal to fire — identical to the overlay's behavior.

## Gate Stack

Every gate from the overlay is replicated with matching defaults. Regime Gate (ON), Band Filter (ON), LL/HH Filter (OFF), Tail-Risk Breaker (OFF), Regime Maturity Gate (OFF), SpreadZ Override Buy/Sell (OFF). The breaker uses a minimal flat-dollar position replay to compute drawdown — it does not carry a full performance table.

## Status Table

The table (default Top Right) shows the current Fisher value, upper and lower thresholds, zone (ABV UP / UP MID / LOW MID / BLW LOW), last signal (BUY/SELL), regime (BULL/BEAR/NEUT), RSI divergence state, ADX divergence state, and breaker status.

## Settings Sync

For the overlay and companion to show identical signals, keep Ribbon, ATR, Fisher, Regime Gate, LL/HH, Band Filter, Risk, Maturity Gate, Z-Override, and Divergence inputs matched between the two indicators. The companion does not replicate conviction sizing or the performance table — these are overlay-only and do not affect signal timing.

TheurgyLabs — Conjured with AI.

## Source Code

````pine
// ============================================================
// FishBands H — Companion Oscillator for Fisher Bands
// TheurgyLabs | Build 2.00 | 2026-06-29
// ============================================================
// v2.00 : Full L2 sync with Fisher Bands overlay Build 2.00.
//   Signal chain byte-identical to overlay: Fisher turn + crossLevel
//   threshold + regime gate + LL/HH + breaker + maturity + z-override.
//   SellCapOK removed (%-of-remaining self-limits). Flat-$ position
//   replay feeds breaker only (no perf table). RSI + ADX divergence
//   diagnostic (no gate/conviction in companion). SpreadZ line + zero-
//   cross diamonds ported from MACD Bands H. Display modeled on
//   MACD Bands H: Fisher histogram, Fisher/Trigger lines, learned
//   upper/lower thresholds, turn dots at crossLevel.
// v1.00 : Initial companion — Fisher + trigger lines, thresholds,
//   basic turn dots, status table. No gates, no SpreadZ.
// ------------------------------------------------------------
// Shows the mechanism behind the overlay:
//   - Fisher histogram (Fisher - Trigger), 4-state momentum colors
//   - Fisher line (cyan) + Trigger line (gold)
//   - Zero line (dotted)
//   - Upper threshold (magenta) = mean/median of Fisher peak levels
//   - Lower threshold (cyan)    = mean/median of Fisher valley levels
//   - Turn dots at crossLevel: dim = logged only,
//     bright cyan = BUY trigger, bright magenta = SELL trigger
// Core logic is byte-identical to Fisher Bands Build 2.00.
// ============================================================
//@version=6
indicator("FishBands H TheurgyLabs", "FshBnds H", overlay=false)

// ── INPUTS ─────────────────────────────────────────────────
// Ribbon (must match overlay: 8/16/24/32 on HL2)
ribSrc = input.source(hl2, "Ribbon Source", group="Ribbon")
ribP1  = input.int(8,  "Fast SMMA",   minval=1, group="Ribbon")
ribP2  = input.int(16, "Mid SMMA",    minval=1, group="Ribbon")
ribP3  = input.int(24, "Slow SMMA",   minval=1, group="Ribbon")
ribP4  = input.int(32, "Anchor SMMA", minval=1, group="Ribbon")
neutZone = input.float(0.34, "Neutral Zone %", minval=0.0, step=0.01, group="Ribbon")

// ATR
atrLen = input.int(14, "ATR Length", minval=1, group="ATR")
donLen   = input.int(100,   "Donchian Length",       minval=10, group="ATR")
penLrn   = input.bool(true, "Penetration Learning",             group="ATR")
penLen   = input.int(50,    "Pen Learn Bars",        minval=5,  group="ATR")
bandSmth = input.int(5,     "Band Smoothing",        minval=1,  group="ATR")
atrMult  = input.float(3.5, "ATR Mult (fallback)",   step=0.1,  group="ATR")

// Fisher Transform
fishLen  = input.int(24,  "Fisher Length",      minval=2,  group="Fisher")
fishLook = input.int(124, "Threshold Lookback", minval=10, group="Fisher",
     tooltip="Window over which past Fisher turn levels are averaged into the upper/lower thresholds.")
fishMinX = input.int(2,   "Min Turns in Zone",  minval=1,  group="Fisher",
     tooltip="Minimum prior turns required in a zone before that threshold is trusted for a signal.")
fishStat = input.string("Mean", "Threshold Stat", options=["Mean","Median"], group="Fisher",
     tooltip="Mean = array.avg. Median = array.median (robust to outlier turns). Default Mean reproduces overlay cells.")

// Regime Gate (matches overlay: buys blocked in bull, sells blocked in bear)
regGateOn = input.bool(true, "Regime Gate", group="Regime Gate",
     tooltip="OFF: no regime filter. ON: block buys in bull and sells in bear (fleet standard). Matches overlay.")

// LL/HH filter (XDEV-style simple bool, matching overlay Build 2.00)
llOn = input.bool(false, "LL Filter (Buy)",  group="LL/HH Filter",
     tooltip="Each buy must print a lower low than the last buy. Ref resets after a sell.")
hhOn = input.bool(false, "HH Filter (Sell)", group="LL/HH Filter",
     tooltip="Each sell must print a higher high than the last sell. Ref resets after a buy.")

// Band Proximity Filter
bandGateOn  = input.bool(true,    "Band Filter",       group="Band Filter",
     tooltip="Require price near the learned Donchian bands. Matches overlay default ON.")
bandOffset  = input.float(0.0,    "Band Offset (ATR)", group="Band Filter", step=0.1,
     tooltip="Positive = widen bands (deeper penetration). Negative = slack (looser). 0 = touch band.")

// Risk: Tail-Risk Breaker (flat-$ replay feeds the DD)
brkOn     = input.bool(false,  "Tail-Risk Breaker", group="Risk",
     tooltip="Halt new buys when the held position's open drawdown exceeds Halt %, resume at Resume %. Companion carries a minimal flat-$ replay to feed this.")
brkHalt   = input.float(20.0, "Breaker Halt DD %",   minval=5, maxval=50, step=1, group="Risk")
brkResume = input.float(12.0, "Breaker Resume DD %", minval=0, maxval=40, step=1, group="Risk")

// Regime Maturity Gate
matGateOn  = input.bool(false, "Regime Maturity Gate", group="Maturity Gate",
     tooltip="Block signals until regime ages Min Bars OR spread depth reaches Min ATR. Z-override bypasses. Matches overlay default OFF.")
matMinBars = input.int(12,     "Min Regime Bars",     minval=1, maxval=40, group="Maturity Gate")
matMinATR  = input.float(1.5,  "Min Regime Depth (ATR)", minval=0.1, maxval=5.0, step=0.1, group="Maturity Gate")

// SpreadZ Override
zOvrBuyOn  = input.bool(false,  "SpreadZ Override (Buy)", group="Z-Override",
     tooltip="Capitulation safety net. Fire buy on extreme negative spreadZ. Breaker still applies. Matches overlay default OFF.")
zBuyThr    = input.float(-3.5,  "Buy Z Threshold",  minval=-6.0, maxval=-1.0, step=0.25, group="Z-Override")
zOvrSellOn = input.bool(false,  "SpreadZ Override (Sell)", group="Z-Override",
     tooltip="Euphoria safety net. Default OFF.")
zSellThr   = input.float(3.5,   "Sell Z Threshold", minval=1.0, maxval=6.0, step=0.25, group="Z-Override")

// Divergence (RSI + ADX, diagnostic only — companion has no conviction replay)
divLbL  = input.int(5,  "Pivot Left bars",   minval=1, group="Divergence")
divLbR  = input.int(3,  "Pivot Right bars",  minval=1, group="Divergence")
divMin  = input.int(5,  "Min bars between pivots", minval=1, group="Divergence")
divMax  = input.int(24, "Max bars between pivots", minval=1, group="Divergence")
divVal  = input.int(15, "Divergence valid for (bars)", minval=1, group="Divergence",
     tooltip="Diagnostic only in companion — does not gate or size.")
rsiLen  = input.int(14, "RSI Length", minval=2, group="Divergence")
adxDiLen  = input.int(14, "ADX DI Length", minval=2, group="Divergence")
adxSmooth = input.int(14, "ADX Smoothing", minval=1, group="Divergence")
showDivMarks = input.bool(true, "Show RSI/ADX Divergence Markers", group="Divergence",
     tooltip="RSI: green/red circles. ADX: gold/silver crosses.")

// Display
showDots = input.bool(true, "Show Turn Dots",   group="Display")
showTbl  = input.bool(true, "Show Status Table", group="Display")
tblPosIn = input.string("Top Right", "Table Position",
     options=["Top Left","Top Right","Middle Right","Bottom Left","Bottom Right"], group="Display")

// ── PLOT STYLE: per-plot on/off toggles + colors ─────────
grpP = "Plots"
showHist   = input.bool(true,     "Histogram",       inline="ph1",  group=grpP)
histUpCol  = input.color(#00FF88, "up",              inline="ph1",  group=grpP)
histDnCol  = input.color(#FF4444, "dn",              inline="ph1",  group=grpP)
showFish   = input.bool(true,     "Fisher Line",     inline="ph2",  group=grpP)
fishCol    = input.color(#1E90FF, "",                inline="ph2",  group=grpP)
showTrig   = input.bool(true,     "Trigger Line",    inline="ph3",  group=grpP)
trigCol    = input.color(#FFD700, "",                inline="ph3",  group=grpP)
showZero   = input.bool(true,     "Zero Line",       inline="ph4",  group=grpP)
zeroCol    = input.color(#d0d0d0, "",                inline="ph4",  group=grpP)
showUpper  = input.bool(true,     "Upper Threshold", inline="ph5",  group=grpP)
upperCol   = input.color(#FF44FF, "",                inline="ph5",  group=grpP)
showLower  = input.bool(true,     "Lower Threshold", inline="ph6",  group=grpP)
lowerCol   = input.color(#00FFFF, "",                inline="ph6",  group=grpP)
showBuyX   = input.bool(true,     "Buy Dot",         inline="ph7",  group=grpP)
buyXCol    = input.color(#00FFFF, "",                inline="ph7",  group=grpP)
showSellX  = input.bool(true,     "Sell Dot",        inline="ph8",  group=grpP)
sellXCol   = input.color(#FF00FF, "",                inline="ph8",  group=grpP)
dotsCol    = input.color(#d0d0d0, "Turn Dots (toggle in Display)", inline="ph9", group=grpP)
showSigBg  = input.bool(true,     "Signal BG",       inline="ph10", group=grpP)

// SpreadZ display
szSrc     = input.source(close, "SpreadZ Source",          group="SpreadZ")
szRib1    = input.int(8,   "SpreadZ Ribbon Fast", minval=1, group="SpreadZ")
szRib4    = input.int(32,  "SpreadZ Ribbon Slow", minval=1, group="SpreadZ")
szAtrLen  = input.int(14,  "SpreadZ ATR Length",  minval=1, group="SpreadZ")
szWin     = input.int(124, "SpreadZ Z Window",    minval=2, group="SpreadZ")
showSprdZ = input.bool(false, "Show SpreadZ Line (x10)",           group="SpreadZ")
szWidth   = input.int(2, "SpreadZ Line Width", minval=1, maxval=5, group="SpreadZ")
szBullCol = input.color(#FFD700, "SpreadZ Bull",    inline="szc", group="SpreadZ")
szBearCol = input.color(#00BFFF, "SpreadZ Bear",    inline="szc", group="SpreadZ")
szNeutCol = input.color(#C0C0C8, "SpreadZ Neutral", inline="szc", group="SpreadZ")
showDia   = input.bool(false, "Show SpreadZ Zero-Cross Diamonds",  group="SpreadZ")
diaBull   = input.color(#00FFFF, "Diamond Bull (cross up)",   inline="dia", group="SpreadZ")
diaBear   = input.color(#FF00FF, "Diamond Bear (cross down)", inline="dia", group="SpreadZ")

// ── CORE: SMMA helper ────────────────────────────────────
f_smma(_src, _len) =>
    float s = 0.0
    float sma = ta.sma(_src, _len)
    s := na(s[1]) ? sma : (s[1] * (_len - 1) + _src) / _len
    s

// ── RIBBON + REGIME (byte-identical to overlay) ──────────
float r1 = f_smma(ribSrc, ribP1)
float r2 = f_smma(ribSrc, ribP2)
float r3 = f_smma(ribSrc, ribP3)
float r4 = f_smma(ribSrc, ribP4)
float rMid = (r1 + r4) / 2.0

float ribSpread = r1 > 0 ? (r1 - r4) / r1 * 100.0 : 0.0
bool isBull = ribSpread > neutZone
bool isBear = ribSpread < -neutZone

// ── ATR + ATR-NORMALIZED SPREAD ──────────────────────────
float atr     = ta.atr(atrLen)
float spread  = close - rMid
float atrNorm = atr > 0 ? spread / atr : 0.0

// ── FISHER TRANSFORM (byte-identical to overlay) ─────────
float fishHi  = ta.highest(atrNorm, fishLen)
float fishLo  = ta.lowest(atrNorm,  fishLen)
float fishRng = fishHi - fishLo
float fishNrm = fishRng != 0 ? 2.0 * ((atrNorm - fishLo) / fishRng) - 1.0 : 0.0
fishNrm := math.max(-0.999, math.min(0.999, fishNrm * 0.99))

var float fisher  = 0.0
var float fisher1 = 0.0
var float fisher2 = 0.0
fisher2 := fisher1
fisher1 := fisher
fisher  := 0.5 * math.log((1.0 + fishNrm) / (1.0 - fishNrm)) + 0.5 * nz(fisher1)

bool turnUp = fisher > fisher1 and fisher1 <= fisher2 and bar_index > 2
bool turnDn = fisher < fisher1 and fisher1 >= fisher2 and bar_index > 2
bool isTurn = turnUp or turnDn
float histLine = fisher - fisher1

// ── ADAPTIVE THRESHOLDS (byte-identical to overlay) ──────
var array<float> valVals  = array.new<float>()
var array<int>   valBars  = array.new<int>()
var array<float> peakVals = array.new<float>()
var array<int>   peakBars = array.new<int>()

while array.size(valBars) > 0 and (bar_index - array.get(valBars, 0)) > fishLook
    array.shift(valBars)
    array.shift(valVals)
while array.size(peakBars) > 0 and (bar_index - array.get(peakBars, 0)) > fishLook
    array.shift(peakBars)
    array.shift(peakVals)

int numVals  = array.size(valVals)
int numPeaks = array.size(peakVals)

float loRaw = numVals  > 0 ? (fishStat == "Median" ? array.median(valVals)  : array.avg(valVals))  : na
float hiRaw = numPeaks > 0 ? (fishStat == "Median" ? array.median(peakVals) : array.avg(peakVals)) : na
var float lowerThr = na
var float upperThr = na
lowerThr := na(loRaw) ? lowerThr : loRaw
upperThr := na(hiRaw) ? upperThr : hiRaw

if turnUp
    array.push(valVals, fisher1)
    array.push(valBars, bar_index)
if turnDn
    array.push(peakVals, fisher1)
    array.push(peakBars, bar_index)

float crossLevel = (fisher + fisher1) / 2.0

// ── RSI DIVERGENCE (diagnostic only) ─────────────────────
float rsiVal = ta.rsi(close, rsiLen)
float rpl = ta.pivotlow(rsiVal, divLbL, divLbR)
float rph = ta.pivothigh(rsiVal, divLbL, divLbR)
bool rplF = not na(rpl)
bool rphF = not na(rph)
int  rGL = ta.barssince(rplF[1])
int  rGH = ta.barssince(rphF[1])
bool rRL = not na(rGL) and rGL >= divMin and rGL <= divMax
bool rRH = not na(rGH) and rGH >= divMin and rGH <= divMax
bool bullRsiCond = low[divLbR] < ta.valuewhen(rplF, low[divLbR], 1) and rsiVal[divLbR] > ta.valuewhen(rplF, rsiVal[divLbR], 1) and rRL and rplF
bool bearRsiCond = high[divLbR] > ta.valuewhen(rphF, high[divLbR], 1) and rsiVal[divLbR] < ta.valuewhen(rphF, rsiVal[divLbR], 1) and rRH and rphF
int  bsRB = ta.barssince(bullRsiCond)
int  bsRBr = ta.barssince(bearRsiCond)
bool bullRsiActive = not na(bsRB) and bsRB <= divVal
bool bearRsiActive = not na(bsRBr) and bsRBr <= divVal

// ── ADX DIVERGENCE (diagnostic only) ─────────────────────
[adxP, adxM, adxVal] = ta.dmi(adxDiLen, adxSmooth)
float apl = ta.pivotlow(low, divLbL, divLbR)
float aph = ta.pivothigh(high, divLbL, divLbR)
bool aplF = not na(apl)
bool aphF = not na(aph)
int  aGL = ta.barssince(aplF[1])
int  aGH = ta.barssince(aphF[1])
bool aRL = not na(aGL) and aGL >= divMin and aGL <= divMax
bool aRH = not na(aGH) and aGH >= divMin and aGH <= divMax
bool bullAdxCond = low[divLbR] < ta.valuewhen(aplF, low[divLbR], 1) and adxVal[divLbR] < ta.valuewhen(aplF, adxVal[divLbR], 1) and aRL and aplF
bool bearAdxCond = high[divLbR] > ta.valuewhen(aphF, high[divLbR], 1) and adxVal[divLbR] < ta.valuewhen(aphF, adxVal[divLbR], 1) and aRH and aphF
int  bsAB = ta.barssince(bullAdxCond)
int  bsABr = ta.barssince(bearAdxCond)
bool bullAdxActive = not na(bsAB) and bsAB <= divVal
bool bearAdxActive = not na(bsABr) and bsABr <= divVal

// ── SPREADZ (identical to overlay's block) ───────────────
float szR1v = f_smma(szSrc, szRib1)
float szR4v = f_smma(szSrc, szRib4)
float szAtr = ta.atr(szAtrLen)
float szRaw = szAtr > 0 ? (szR1v - szR4v) / szAtr * 100.0 : 0.0
float szMu  = ta.sma(szRaw, szWin)
float szSig = ta.stdev(szRaw, szWin)
float spreadZ = szSig > 0 ? (szRaw - szMu) / szSig : 0.0
bool szCrossUp = ta.crossover(spreadZ, 0.0)
bool szCrossDn = ta.crossunder(spreadZ, 0.0)

// ── REGIME MATURITY GATE ─────────────────────────────────
var int bearAge = 0
var int bullAge = 0
bearAge := isBear ? bearAge + 1 : 0
bullAge := isBull ? bullAge + 1 : 0
float depthATR = atr > 0 ? math.abs(close - rMid) / atr : 0.0
bool buyMatureOK  = not matGateOn or bearAge >= matMinBars or depthATR >= matMinATR
bool sellMatureOK = not matGateOn or bullAge >= matMinBars or depthATR >= matMinATR

// ── SPREADZ EXTREME OVERRIDE ─────────────────────────────
bool zBuyOvr  = zOvrBuyOn  and spreadZ <= zBuyThr
bool zSellOvr = zOvrSellOn and spreadZ >= zSellThr

// ── LL/HH FILTER (simple bool, matching overlay) ─────────
var float lastBuyLow   = na
var float lastSellHigh = na
bool llOK = not llOn or na(lastBuyLow) or low < lastBuyLow
bool hhOK = not hhOn or na(lastSellHigh) or high > lastSellHigh

// ── TAIL-RISK BREAKER (flat-$ replay feeds DD only) ──────
var float totalQty   = 0.0
var float totalCost  = 0.0
var float avgEntry   = 0.0
var bool  brkActive  = false
var float cycSoldQty = 0.0
float ddPct = totalQty > 0 and avgEntry > 0 ? (avgEntry - close) / avgEntry * 100.0 : 0.0
if brkOn and ddPct >= brkHalt
    brkActive := true
if brkOn and ddPct <= brkResume
    brkActive := false
bool breakerOK = not brkOn or not brkActive

// ── BAND FILTER (matching overlay: Donchian + penetration learning) ──
float donHi  = ta.highest(high, donLen)
float donLo  = ta.lowest(low, donLen)
float donMid = (donHi + donLo) / 2.0
var float lrnBuyM  = atrMult
var float lrnSellM = atrMult
if penLrn and bar_index > penLen
    float mxB = 0.0
    float mxS = 0.0
    for i = 1 to penLen
        if atr[i] > 0
            mxB := math.max(mxB, (donMid[i] - low[i])  / atr[i])
            mxS := math.max(mxS, (high[i] - donMid[i]) / atr[i])
    lrnBuyM  := math.max(1.0, mxB * 0.85)
    lrnSellM := math.max(1.0, mxS * 0.85)
float bandLo = ta.sma(donMid - lrnBuyM  * atr, bandSmth)
float bandHi = ta.sma(donMid + lrnSellM * atr, bandSmth)
bool bandBuyOK  = not bandGateOn or close <= bandLo - bandOffset * atr
bool bandSellOK = not bandGateOn or close >= bandHi + bandOffset * atr

// ── SIGNALS (byte-identical to overlay Build 2.00) ───────
bool regBuyOK  = not regGateOn or not isBull
bool regSellOK = not regGateOn or not isBear

bool normalBuy  = turnUp and numVals >= fishMinX and not na(lowerThr) and crossLevel < lowerThr and regBuyOK and buyMatureOK and llOK and bandBuyOK
bool normalSell = turnDn and numPeaks >= fishMinX and not na(upperThr) and crossLevel > upperThr and regSellOK and sellMatureOK and hhOK and bandSellOK
buySignal  = (normalBuy or zBuyOvr) and breakerOK
sellSignal = normalSell or zSellOvr

// LL/HH ladder refs + flat-$ position replay (drives breaker)
if buySignal
    lastBuyLow   := low
    lastSellHigh := na
if sellSignal
    lastSellHigh := high
    lastBuyLow   := na
if buySignal and cycSoldQty > 0 and totalQty > 0
    brkActive  := false
    cycSoldQty := 0.0
if buySignal
    totalQty  += 1.0 / close
    totalCost += 1.0
    avgEntry  := totalQty > 0 ? totalCost / totalQty : close
if sellSignal and totalQty > 0
    float sq    = totalQty * 0.25
    cycSoldQty += sq
    totalQty   -= sq
    totalCost  := totalQty * avgEntry

var string lastSig = "\u2014"
if buySignal
    lastSig := "BUY"
if sellSignal
    lastSig := "SELL"

// ── PLOTS: oscillator pane ───────────────────────────────
// Histogram: Fisher - Trigger, 4-state momentum coloring
histColor = histLine >= 0 ?
     (histLine >= nz(histLine[1]) ? histUpCol : color.new(histUpCol, 55)) :
     (histLine <= nz(histLine[1]) ? histDnCol : color.new(histDnCol, 55))
plot(showHist ? histLine : na, "Histogram", color=histColor, style=plot.style_columns)

plot(showFish ? fisher  : na, "Fisher",  color=fishCol, linewidth=2)
plot(showTrig ? fisher1 : na, "Trigger", color=trigCol, linewidth=1)
hline(0, "Zero", color=showZero ? color.new(zeroCol, 40) : na, linestyle=hline.style_dotted)

plot(showUpper ? upperThr : na, "Upper Threshold", color=color.new(upperCol, 15), linewidth=1)
plot(showLower ? lowerThr : na, "Lower Threshold", color=color.new(lowerCol, 15), linewidth=1)

// Turn dots at crossLevel
neutralX = showDots and isTurn and not buySignal and not sellSignal ? crossLevel : na
buyX     = buySignal  ? crossLevel : na
sellX    = sellSignal ? crossLevel : na
plot(neutralX, "Turns", color=color.new(dotsCol, 35), style=plot.style_circles, linewidth=2)
plot(showBuyX ? buyX : na,     "Buy Dot",  color=buyXCol, style=plot.style_circles, linewidth=4)
plot(showSellX ? sellX : na,   "Sell Dot", color=sellXCol, style=plot.style_circles, linewidth=4)

// SpreadZ line (regime-colored, x10 scale) + zero-cross diamonds
color szClr = isBull ? szBullCol : isBear ? szBearCol : szNeutCol
plot(showSprdZ ? spreadZ * 10 : na, "SpreadZ x10", color=szClr, linewidth=szWidth)
plotshape(showDia and szCrossUp ? 0.0 : na, "SpreadZ Cross Up",   shape.diamond, location.absolute, color=diaBull, size=size.tiny)
plotshape(showDia and szCrossDn ? 0.0 : na, "SpreadZ Cross Down", shape.diamond, location.absolute, color=diaBear, size=size.tiny)
plot(spreadZ,  "SpreadZ",      color=color.new(#FFD700, 100), display=display.data_window)
plot(szRaw,    "SpreadZ Raw%", color=color.new(#FFD700, 100), display=display.data_window)

bgcolor(showSigBg ? (buySignal ? color.new(buyXCol, 85) : sellSignal ? color.new(sellXCol, 85) : na) : na, title="Signal BG")

// RSI + ADX divergence confirmation marks (matching overlay)
plotshape(showDivMarks and bullRsiCond ? fisher : na, "RSI Bull Div", shape.circle, location.absolute, color=#00FF88, size=size.tiny)
plotshape(showDivMarks and bearRsiCond ? fisher : na, "RSI Bear Div", shape.circle, location.absolute, color=#FF4444, size=size.tiny)
plotshape(showDivMarks and bullAdxCond ? fisher : na, "ADX Bull Div", shape.cross,  location.absolute, color=#FFD700, size=size.tiny)
plotshape(showDivMarks and bearAdxCond ? fisher : na, "ADX Bear Div", shape.cross,  location.absolute, color=#C0C0C0, size=size.tiny)

// Divergence state — data window only (diagnostic)
plot(bullRsiActive ? 1 : 0, "Div RSI Bull", color=color.new(#00FF88, 100), display=display.data_window)
plot(bearRsiActive ? 1 : 0, "Div RSI Bear", color=color.new(#FF4444, 100), display=display.data_window)
plot(bullAdxActive ? 1 : 0, "Div ADX Bull", color=color.new(#FFD700, 100), display=display.data_window)
plot(bearAdxActive ? 1 : 0, "Div ADX Bear", color=color.new(#C0C0C0, 100), display=display.data_window)
plot(isBull ? 1 : isBear ? -1 : 0, "Regime",      color=color.new(#FFD700, 100), display=display.data_window)
plot(ribSpread,                     "Rib Spread%", color=color.new(#FFD700, 100), display=display.data_window)

// ── STATUS TABLE ─────────────────────────────────────────
f_num(float v) => na(v) ? "\u2014" : str.tostring(v, "#.###")

tPos = switch tblPosIn
    "Top Left"     => position.top_left
    "Top Right"    => position.top_right
    "Middle Right" => position.middle_right
    "Bottom Left"  => position.bottom_left
    => position.bottom_right

var table ht = table.new(tPos, 2, 10, border_width=1, border_color=#333355, frame_color=#333355, frame_width=1)

if showTbl and barstate.islast
    zoneTxt = na(upperThr) or na(lowerThr) ? "\u2014" :
             fisher > upperThr ? "ABV UP" :
             fisher < lowerThr ? "BLW LOW" :
             fisher >= 0 ? "UP MID" : "LOW MID"
    sigCol = lastSig == "BUY" ? #00FFFF : lastSig == "SELL" ? #FF00FF : #d0d0d0
    regTxt = isBull ? "BULL" : isBear ? "BEAR" : "NEUT"
    regClr = isBull ? #FFD700 : isBear ? #00BFFF : (regGateOn ? #FF4444 : #C0C0C0)
    rsiTxt = (bullRsiActive or bearRsiActive) ? (bullRsiActive and bearRsiActive ? "B+B" : bullRsiActive ? "BULL" : "BEAR") : "\u2014"
    rsiClr = bullRsiActive ? #00FF88 : bearRsiActive ? #FF4444 : #d0d0d0
    adxTxt = (bullAdxActive or bearAdxActive) ? (bullAdxActive and bearAdxActive ? "B+B" : bullAdxActive ? "BULL" : "BEAR") : "\u2014"
    adxClr = bullAdxActive ? #FFD700 : bearAdxActive ? #C0C0C0 : #d0d0d0
    brkTxt = brkOn ? (brkActive ? "ON" : "off") : "OFF"
    brkClr = brkActive ? #FF4444 : #d0d0d0

    table.cell(ht, 0, 0, "FishBands H", text_color=#FFD700, bgcolor=#1a1a2e, text_size=size.small, text_halign=text.align_left)
    table.cell(ht, 1, 0, "B2",          text_color=#FFD700, bgcolor=#1a1a2e, text_size=size.small, text_halign=text.align_right)

    table.cell(ht, 0, 1, "Upper", text_color=#d0d0d0, bgcolor=#0d0d1a, text_size=size.small, text_halign=text.align_left)
    table.cell(ht, 1, 1, f_num(upperThr), text_color=#FF44FF, bgcolor=#0d0d1a, text_size=size.small, text_halign=text.align_right)
    table.cell(ht, 0, 2, "Fisher", text_color=#d0d0d0, bgcolor=#0d0d1a, text_size=size.small, text_halign=text.align_left)
    table.cell(ht, 1, 2, f_num(fisher), text_color=(fisher >= 0 ? #00FF88 : #FF4444), bgcolor=#0d0d1a, text_size=size.small, text_halign=text.align_right)
    table.cell(ht, 0, 3, "Lower", text_color=#d0d0d0, bgcolor=#0d0d1a, text_size=size.small, text_halign=text.align_left)
    table.cell(ht, 1, 3, f_num(lowerThr), text_color=#00FFFF, bgcolor=#0d0d1a, text_size=size.small, text_halign=text.align_right)
    table.cell(ht, 0, 4, "Zone",  text_color=#d0d0d0, bgcolor=#0d0d1a, text_size=size.small, text_halign=text.align_left)
    table.cell(ht, 1, 4, zoneTxt, text_color=#FFFFFF, bgcolor=#0d0d1a, text_size=size.small, text_halign=text.align_right)
    table.cell(ht, 0, 5, "Last",  text_color=#d0d0d0, bgcolor=#0d0d1a, text_size=size.small, text_halign=text.align_left)
    table.cell(ht, 1, 5, lastSig, text_color=sigCol, bgcolor=#0d0d1a, text_size=size.small, text_halign=text.align_right)
    table.cell(ht, 0, 6, "Regime", text_color=#d0d0d0, bgcolor=#0d0d1a, text_size=size.small, text_halign=text.align_left)
    table.cell(ht, 1, 6, regTxt,   text_color=regClr,  bgcolor=#0d0d1a, text_size=size.small, text_halign=text.align_right)
    table.cell(ht, 0, 7, "RSI Div", text_color=#d0d0d0, bgcolor=#0d0d1a, text_size=size.small, text_halign=text.align_left)
    table.cell(ht, 1, 7, rsiTxt,   text_color=rsiClr,  bgcolor=#0d0d1a, text_size=size.small, text_halign=text.align_right)
    table.cell(ht, 0, 8, "ADX Div", text_color=#d0d0d0, bgcolor=#0d0d1a, text_size=size.small, text_halign=text.align_left)
    table.cell(ht, 1, 8, adxTxt,   text_color=adxClr,  bgcolor=#0d0d1a, text_size=size.small, text_halign=text.align_right)
    table.cell(ht, 0, 9, "Breaker", text_color=#d0d0d0, bgcolor=#0d0d1a, text_size=size.small, text_halign=text.align_left)
    table.cell(ht, 1, 9, brkTxt,    text_color=brkClr,  bgcolor=#0d0d1a, text_size=size.small, text_halign=text.align_right)
````

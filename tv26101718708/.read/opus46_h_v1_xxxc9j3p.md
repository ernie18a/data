# Opus46 H v1

- url: https://www.tradingview.com/script/xxXc9j3p-Opus46-H-v1/
- type: indicator
- pine_id: PUB;3236201874934026ad167da5b8949592
- version: 5.0

## Description

Opus46 H is the companion oscillator for Opus46. It visualizes the internal state of the signal engine — spread dynamics, money flow wave, regime phase, pressure conditions, and divergence events — so you can see exactly why signals fire and what conditions are building before they do.

SPREAD HISTOGRAM

The primary plot is the ATR-normalized spread between the fast SMMA (8) and slow SMMA (32), displayed as a regime-colored histogram. Gold bars indicate bullish regime, blue bars indicate bearish regime. Bar transparency distinguishes expansion from contraction — solid bars mean the spread is expanding (strengthening move), faded bars mean it is contracting (weakening move).

MONEY FLOW WAVE

A filled wave plot overlays the histogram showing smoothed Money Flow Index centered at zero. The wave scales adaptively to match the histogram's range using the 100-bar peak spread, keeping the two visually proportional regardless of asset or timeframe. Green fill (50% opacity) indicates bullish money flow (MFI above 50), red fill indicates bearish flow (MFI below 50). This gives an immediate read on whether institutional flow confirms or contradicts the price regime — green wave during a blue (bearish) histogram signals building buy conviction.

DMFI AREA

The DMFI (Double-Pass Money Flow Index) is displayed as a filled area scaled to fit the spread range. Green-tinted area indicates negative DMFI (seller exhaustion / buy conviction), red-tinted area indicates positive DMFI (buyer euphoria / sell conviction), and grey indicates neutral flow. This lets you see the conviction multiplier state at a glance — deeply green DMFI means the overlay is scaling buys toward 2.0x.

REGIME BACKGROUND

A subtle background tint shows the current regime state — blue for bearish (buy zone), gold for bullish (sell zone). With the 2-line ribbon, regime transitions are clean and binary with no grey neutral periods.

RSI BACKGROUND

Green background shading appears when RSI(14) drops below 30, indicating oversold conditions. Red background shading appears when RSI(14) rises above 70, indicating overbought conditions. These layers combine with the regime background to show multi-factor confluence — a blue regime with green RSI shading represents a high-conviction buy zone.

DIVERGENCE MARKERS

Pivot-based divergence detection (5 left bars, 3 right bars) plots at the bottom and top of the pane. Bullish spread divergence appears as lime circles, bullish RSI divergence as teal diamonds. Bearish spread divergence appears as orange circles, bearish RSI divergence as magenta diamonds. These match the overlay's divergence boost window — when these markers appear, the overlay is priming a 1.5x buy or sell size multiplier.

Z-OVERRIDE MARKERS

Diamond markers appear when the spread z-score crosses into extreme territory (default below -3.5 sigma for buy zone, above 3.5 sigma for sell zone). These highlight bars where the overlay would fire z-override signals that bypass regime and maturity gates.

PAIN GATE MARKERS

When the pain gate is enabled, cyan up-triangles appear at the bottom of the pane when recent capitulation is first detected (pressZ dropping below the capitulation threshold within the lookback window). Magenta down-triangles appear at the top when recent euphoria is detected. These show exactly when the pain gate opens for buy or sell signals on the overlay.

STATUS TABLE

An optional status table (default OFF) displays the current state of all signal components in one view. The SETUP row shows the current verdict — Z-BUY, Z-SELL, BUY ZONE, SELL ZONE, or WAIT (chop). Additional rows show spread z-score, regime state with age, maturity gate status with ATR depth, pain gate status with pressure z, DMFI value with current multiplier, gate direction, phase buy and sell boost values, raw spread, and active divergence type.

USAGE

Place Opus46 H in a pane below the Opus46 overlay. The companion shares the same SMMA ribbon, regime detection, and DMFI parameters — keep the settings synchronized between the two indicators. The oscillator pane gives you forward visibility into what the overlay is computing internally, letting you anticipate signals before they fire and understand signal quality after they fire.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════
// OPUS46 H v2.0 | 2026-07-12 | FULL REBUILD from overlay 616.9 (single source of truth).
//   Fleet H standard: the overlay's ENTIRE logic core is ported verbatim -- ribbon,
//   spread/Z, pain gate, DMFI, percentile conviction, phase tracking, divergence,
//   pen-learned bands (chart + HTF), structural filters, wick boost, signal chain,
//   position state + breaker, sell throttle, cascade exhaustion, and the FULL
//   dollar-accounting shadow mirror INCLUDING the Basis Guard (ON, sliver 1.0 --
//   the committed 616.9 config). Marker parity with the overlay is by construction:
//   same code, same inputs, same defaults. Stripped: price-pane plots, perf table,
//   pipeline SQS exports, webhook (overlay owns those). Added: pane display layer
//   (spread histogram, MFI wave, DMFI area, pressure/Z/divergence markers), buy/sell
//   markers, L0 vetoed layer (default OFF), key table, status table, Signal export.
//   BUILD export = overlay sync stamp (616.9). Replaces Opus46 H v1 (616.5-era).
//   Buy/sell triangles ride the spread trace (location.absolute, na-guarded series
//   per the fleet plotshape rule -- bare bools at absolute pull pane scale to zero).
// ══════════════════════════════════════════════════════════════════════
indicator("Opus46 H", shorttitle="Opus46 H", overlay=false)

// ─── FUNCTIONS ──────────────────────────────────────────────────────

smma(float src, int len) =>
    var float val = na
    val := na(val) ? ta.sma(src, len) : (val * (len - 1) + src) / len
    val

// ─── INPUTS ─────────────────────────────────────────────────────────

grpRib      = "═══ SMMA RIBBON ═══"
i_src       = input.source(hl2, "Source", group=grpRib)
i_fastLen   = input.int(8,  "Fast SMMA", minval=2, maxval=50, group=grpRib)
i_slowLen   = input.int(32, "Slow SMMA", minval=5, maxval=80, group=grpRib)

grpBand     = "═══ PENETRATION BANDS ═══"
i_donchLen      = input.int(14,    "Donchian Length",       group=grpBand, minval=5, maxval=100)
i_adaptLookback = input.int(100,   "Penetration Samples",  group=grpBand, minval=20, maxval=500, tooltip="Rolling window of wick penetration depths to learn from.")
i_minSamples    = input.int(22,    "Min Samples Required", group=grpBand, minval=5, maxval=100)
i_defaultMult   = input.float(0.5, "Default ATR Mult",     group=grpBand, minval=0.1, maxval=2.0, step=0.1, tooltip="Used before enough samples are collected.")
i_sensitivity   = input.float(0.8, "Sensitivity Factor",   group=grpBand, minval=0.1, maxval=1.5, step=0.1, tooltip="Scales learned multiplier. Lower = more signals.")
i_minMult       = input.float(0.1, "Min Multiplier",       group=grpBand, minval=0.0, maxval=1.0, step=0.1)
i_maxMult       = input.float(1.5, "Max Multiplier",       group=grpBand, minval=0.5, maxval=3.0, step=0.1)

grpHtf      = "=== HTF PEN BAND (A/B) ==="
i_buyHtfMode  = input.string("Off",  "Buy HTF Band Mode",  options=["Off","Chart","HTF","Either","Both"], group=grpHtf, tooltip="Homogeneous HTF Donchian-extreme gate on buys. Off = 616.5 baseline (byte-identical).")
i_sellHtfMode = input.string("Off",  "Sell HTF Band Mode", options=["Off","Chart","HTF","Either","Both"], group=grpHtf, tooltip="HTF structural sell gate (Opus48MAX sell-patience pattern). Off = baseline.")
i_htfMode     = input.string("Auto", "HTF Timeframe Mode", options=["Auto","Manual"], group=grpHtf)
i_htfMult     = input.int(4,   "HTF Auto Multiplier", minval=2, maxval=12, group=grpHtf)
i_htfMan      = input.int(480, "HTF Manual (min)",    minval=60, maxval=1440, step=60, group=grpHtf)

grpZOver    = "═══ Z-SCORE OVERRIDE ═══"
i_zOverride   = input.bool(true,   "Z-Score Override",     group=grpZOver, tooltip="Bypass ALL gates when spread z-score hits extreme σ. Captures capitulation/euphoria regardless of regime.")
i_zBuyThresh  = input.float(-3.0,  "Buy Override ≤ σ",     group=grpZOver, minval=-6.0, maxval=-2.0, step=0.25)
i_zSellThresh = input.float(3.75,  "Sell Override ≥ σ",    group=grpZOver, minval=2.0, maxval=6.0, step=0.25)

grpPain     = "═══ PAIN GATE (crypto) ═══"
i_usePainGate  = input.bool(true,   "Enable Pain Gate",          group=grpPain, tooltip="Require recent capitulation/euphoria before band-touch fires. Universally accretive with reward-only conviction multipliers.")
i_vwapLen      = input.int(24,      "Cost Basis Lookback",       group=grpPain, minval=5, maxval=200)
i_shortVwap    = input.int(8,       "Recent Buyers Lookback",    group=grpPain, minval=3, maxval=50)
i_normLen      = input.int(100,     "Normalization Window",      group=grpPain, minval=20, maxval=500)
i_capThresh    = input.float(1.5,   "Capitulation σ",            group=grpPain, minval=0.5, maxval=5.0, step=0.25)
i_euphThresh   = input.float(1.5,   "Euphoria σ",                group=grpPain, minval=0.5, maxval=5.0, step=0.25)
i_painWindow   = input.int(4,       "Pain Lookback (bars)",      group=grpPain, minval=1, maxval=12, tooltip="Capitulation/euphoria within this many bars opens the gate.")

grpPhase    = "═══ PHASE BOOST ═══"
i_phaseOn       = input.bool(true,  "Enable Phase Sell Boost", group=grpPhase, tooltip="Boosts sell % as gold regimes mature. Conservative early, aggressive late.")
i_phaseScale    = input.float(0.5,  "Sell Boost Scale",        group=grpPhase, minval=0.5, maxval=5.0, step=0.1)
i_phaseMax      = input.float(2.5,  "Sell Boost Max",          group=grpPhase, minval=1.1, maxval=5.0, step=0.1)
i_phaseBuyOn    = input.bool(true,  "Enable Phase Buy Boost",  group=grpPhase, tooltip="Boosts buy $ as blue regimes mature. Conservative early, aggressive late.")
i_phaseBuyScale = input.float(1.0,  "Buy Boost Scale",         group=grpPhase, minval=0.5, maxval=5.0, step=0.1)
i_phaseBuyMax   = input.float(2.5,  "Buy Boost Max",           group=grpPhase, minval=1.1, maxval=5.0, step=0.1)

grpDiv      = "═══ DIVERGENCE ═══"
i_showDiv        = input.bool(true,  "Show Spread Divergence",   group=grpDiv)
i_showRSIDiv     = input.bool(true,  "Show RSI Divergence",      group=grpDiv)
i_divPivL        = input.int(5,      "Pivot Left Bars",           group=grpDiv, minval=2, maxval=20)
i_divPivR        = input.int(3,      "Pivot Right Bars",          group=grpDiv, minval=1, maxval=10)
i_divBoostOn     = input.bool(true,  "Divergence Buy Boost",     group=grpDiv, tooltip="Boost buy size when bullish divergence fired recently (spread OR RSI).")
i_divSellBoostOn = input.bool(false, "Divergence Sell Boost",    group=grpDiv, tooltip="Boost sell % when bearish divergence fired recently. Default OFF — A/B test per asset.")
i_divBoostMult   = input.float(1.5,  "Div Boost Multiplier",     group=grpDiv, minval=1.0, maxval=2.0, step=0.05)
i_divWindow      = input.int(5,      "Div Boost Window (bars)",  group=grpDiv, minval=1, maxval=20)

grpRisk     = "═══ RISK MANAGEMENT ═══"
i_breakerOn     = input.bool(false,  "Tail-Risk Breaker",       group=grpRisk, tooltip="Halt new buys when position DD exceeds threshold. Resumes at recovery level. Default OFF.")
i_breakerHalt   = input.float(20,    "Breaker Halt DD %",       group=grpRisk, minval=5, maxval=50, step=1, tooltip="DD % below avg entry that halts new buys.")
i_breakerResume = input.float(12,    "Breaker Resume DD %",     group=grpRisk, minval=0, maxval=40, step=1, tooltip="DD % recovery level that resumes buying. Hysteresis prevents oscillation.")

grpDMFI     = "═══ DMFI CONVICTION ═══"
i_useDmfi      = input.bool(true,   "Enable DMFI Buy Sizing",  group=grpDMFI, tooltip="Scale buy amounts by money flow exhaustion. Deep negative DMFI = high conviction = bigger position. Seven for seven across all fleet architectures.")
i_useDmfiSell  = input.bool(false,  "Enable DMFI Sell Sizing", group=grpDMFI, tooltip="Scale sell % by money flow euphoria. High positive DMFI = euphoric flow = sell more aggressively. Default OFF — over-sells on trending equities.")
i_mfiLen       = input.int(14,      "MFI Length",              group=grpDMFI)
i_mfiSmooth    = input.int(3,       "MFI Smooth",              group=grpDMFI)
i_dmfiLen      = input.int(14,      "DMFI Length",             group=grpDMFI)
i_dmfiSmooth   = input.int(5,       "DMFI Smooth",             group=grpDMFI)
i_dmfiCeil     = input.float(30,    "Ceiling",                 group=grpDMFI, minval=10, maxval=50, step=1)
i_dmfiMin      = input.float(1.0,   "Min Multiplier",          group=grpDMFI, minval=0.1, maxval=1.0, step=0.1)
i_dmfiMax      = input.float(2.0,   "Max Multiplier",          group=grpDMFI, minval=1.0, maxval=3.0, step=0.1)

grpPctConv  = "═══ PERCENTILE CONVICTION ═══"
i_usePctConv   = input.bool(true,   "Enable Pctile Buy Sizing",  group=grpPctConv, tooltip="Scale buy amounts by how statistically extreme the spread is. Lower percentile = deeper oversold = bigger buy. Complements DMFI (flow) with distribution context.")
i_usePctSell   = input.bool(false,  "Enable Pctile Sell Sizing", group=grpPctConv, tooltip="Scale sell % by how statistically extreme the spread is. Default OFF — can over-sell on trending assets.")
i_pctLookback  = input.int(124,     "Percentile Lookback",       group=grpPctConv, minval=20, maxval=500)
i_pctMin       = input.float(1.0,   "Min Multiplier",            group=grpPctConv, minval=0.1, maxval=1.0, step=0.1)
i_pctMax       = input.float(1.5,   "Max Multiplier",            group=grpPctConv, minval=1.0, maxval=3.0, step=0.1)

// ─── 4-SMMA RIBBON ─────────────────────────────────────────────────

float v1 = smma(i_src, i_fastLen)
float v2 = smma(i_src, i_slowLen)

// ─── REGIME DETECTION (2-line, no neutral zone) ────────────────────

bool  bearish   = v1 < v2
bool  bullish   = not bearish
color ribbonClr = bullish ? #FFD700 : #1E90FF

int regime = bullish ? 1 : bearish ? -1 : 0

// ─── ATR-NORM SPREAD & Z-SCORE ──────────────────────────────────────

float atrNorm       = ta.atr(14)
float atrNormSpread = atrNorm > 0 ? (v1 - v2) / atrNorm * 100 : 0.0
float spreadMean    = ta.sma(atrNormSpread, 124)
float spreadStdev   = ta.stdev(atrNormSpread, 124)
float spreadZ       = spreadStdev > 0 ? (atrNormSpread - spreadMean) / spreadStdev : 0.0

bool  zBuyOverride  = i_zOverride and spreadZ <= i_zBuyThresh and barstate.isconfirmed
bool  zSellOverride = i_zOverride and spreadZ >= i_zSellThresh and barstate.isconfirmed

// ─── PAIN GATE — RealPnL Pressure (Pulse lookback-window) ──────────

var float cumPV = 0.0
var float cumV  = 0.0
cumPV += hlc3 * volume
cumV  += volume

f_rollingVwap(int length) =>
    float windowPV = cumPV - nz(cumPV[length])
    float windowV  = cumV  - nz(cumV[length])
    windowV > 0 ? windowPV / windowV : hlc3

float costBasis   = f_rollingVwap(i_vwapLen) * 0.4 + f_rollingVwap(i_shortVwap) * 0.6
float plMargin    = costBasis != 0 ? (close - costBasis) / costBasis * 100.0 : 0.0
float volSma      = ta.sma(volume, 20)
float rawPressure = plMargin * (volSma > 0 ? volume / volSma : 1.0)
float pressMean   = ta.sma(rawPressure, i_normLen)
float pressStd    = ta.stdev(rawPressure, i_normLen)
float pressZ      = pressStd > 0 ? (rawPressure - pressMean) / pressStd : 0.0

bool capRecent  = ta.lowest(pressZ,  i_painWindow) <= -i_capThresh
bool euphRecent = ta.highest(pressZ, i_painWindow) >=  i_euphThresh

bool painBuyOK  = not i_usePainGate or capRecent
bool painSellOK = not i_usePainGate or euphRecent

// ─── DMFI — Double-Pass Money Flow Conviction ──────────────────────

float rawMFI    = nz(ta.mfi(hlc3, i_mfiLen), 50.0)
float smoothMFI = ta.sma(rawMFI, i_mfiSmooth)
float dmfiRaw   = 2.0 * smoothMFI - nz(ta.rsi(smoothMFI, i_dmfiLen), 50.0)
float dmfi      = nz(ta.sma(dmfiRaw, i_dmfiSmooth), 0.0)
float dmfiClamp = math.max(-i_dmfiCeil, math.min(i_dmfiCeil, dmfi))
float dmfiMult     = i_useDmfi ? nz(i_dmfiMax - (dmfiClamp + i_dmfiCeil) / (2.0 * i_dmfiCeil) * (i_dmfiMax - i_dmfiMin), 1.0) : 1.0
float dmfiSellMult = i_useDmfiSell ? nz(i_dmfiMin + (dmfiClamp + i_dmfiCeil) / (2.0 * i_dmfiCeil) * (i_dmfiMax - i_dmfiMin), 1.0) : 1.0

// ─── PERCENTILE CONVICTION — Statistical Extremity Sizing ──────────

float pctRank    = nz(ta.percentrank(atrNormSpread, i_pctLookback), 50.0)
float pctBuyConv  = math.max(0.0, (50.0 - pctRank) / 50.0)
float pctSellConv = math.max(0.0, (pctRank - 50.0) / 50.0)
float pctBuyMult  = i_usePctConv ? nz(i_pctMin + pctBuyConv * (i_pctMax - i_pctMin), 1.0) : 1.0
float pctSellMult = i_usePctSell ? nz(i_pctMin + pctSellConv * (i_pctMax - i_pctMin), 1.0) : 1.0

// ─── REGIME PHASE TRACKING (XDEV5) ─────────────────────────────────

// Gold regime → sell boost (sell more as bull matures)
var int   goldAge = 0
var float goldPeakSpread = 0.0
var int   goldCount = 0
var float sumGoldPeaks = 0.0
var float sumGoldAges = 0.0

if bullish
    goldAge += 1
    goldPeakSpread := math.max(goldPeakSpread, math.abs(atrNormSpread))
else
    if bullish[1] and goldAge > 0
        goldCount    += 1
        sumGoldPeaks += goldPeakSpread
        sumGoldAges  += goldAge
    goldAge := 0
    goldPeakSpread := 0.0

float avgGoldPeak     = goldCount > 0 ? sumGoldPeaks / goldCount : goldPeakSpread > 0 ? goldPeakSpread : 1.0
float avgGoldAge      = goldCount > 0 ? sumGoldAges / goldCount : 50.0
float spreadPeakRatio = goldPeakSpread > 0 ? math.abs(atrNormSpread) / goldPeakSpread : 0.0
float regimeAgeNorm   = math.min(1.0, goldAge / math.max(1.0, avgGoldAge))
float phaseBoost      = i_phaseOn ? math.min(i_phaseMax, 1.0 + spreadPeakRatio * regimeAgeNorm * i_phaseScale) : 1.0

// Blue regime → buy boost (buy more as bear matures)
var int   blueAge = 0
var float bluePeakSpread = 0.0
var int   blueCount = 0
var float sumBluePeaks = 0.0
var float sumBlueAges = 0.0

if bearish
    blueAge += 1
    bluePeakSpread := math.max(bluePeakSpread, math.abs(atrNormSpread))
else
    if bearish[1] and blueAge > 0
        blueCount    += 1
        sumBluePeaks += bluePeakSpread
        sumBlueAges  += blueAge
    blueAge := 0
    bluePeakSpread := 0.0

float avgBluePeak       = blueCount > 0 ? sumBluePeaks / blueCount : bluePeakSpread > 0 ? bluePeakSpread : 1.0
float avgBlueAge        = blueCount > 0 ? sumBlueAges / blueCount : 50.0
float spreadTroughRatio = bluePeakSpread > 0 ? math.abs(atrNormSpread) / bluePeakSpread : 0.0
float blueAgeNorm       = math.min(1.0, blueAge / math.max(1.0, avgBlueAge))
float phaseBuyBoost     = i_phaseBuyOn ? math.min(i_phaseBuyMax, 1.0 + spreadTroughRatio * blueAgeNorm * i_phaseBuyScale) : 1.0

// ─── SPREAD DIVERGENCE ──────────────────────────────────────────────

// ─── PIVOT-BASED DIVERGENCE (5L/3R fleet standard) ──────────────────

float rsiVal = ta.rsi(close, 14)
float pivHi  = ta.pivothigh(high, i_divPivL, i_divPivR)
float pivLo  = ta.pivotlow(low, i_divPivL, i_divPivR)

// Track previous pivot values
var float prevPivHiPrice  = na
var float prevPivHiSpread = na
var float prevPivHiRSI    = na
var float prevPivLoPrice  = na
var float prevPivLoSpread = na
var float prevPivLoRSI    = na

float spreadAtPiv = nz(atrNormSpread[i_divPivR])
float rsiAtPiv    = nz(rsiVal[i_divPivR])

// Bearish: price higher high, indicator lower high
bool bearDivSpread = false
bool bearDivRSI    = false
if not na(pivHi)
    if not na(prevPivHiPrice)
        if pivHi > prevPivHiPrice and spreadAtPiv < prevPivHiSpread
            bearDivSpread := true
        if pivHi > prevPivHiPrice and rsiAtPiv < prevPivHiRSI
            bearDivRSI := true
    prevPivHiPrice  := pivHi
    prevPivHiSpread := spreadAtPiv
    prevPivHiRSI    := rsiAtPiv

// Bullish: price lower low, indicator higher low
bool bullDivSpread = false
bool bullDivRSI    = false
if not na(pivLo)
    if not na(prevPivLoPrice)
        if pivLo < prevPivLoPrice and spreadAtPiv > prevPivLoSpread
            bullDivSpread := true
        if pivLo < prevPivLoPrice and rsiAtPiv > prevPivLoRSI
            bullDivRSI := true
    prevPivLoPrice  := pivLo
    prevPivLoSpread := spreadAtPiv
    prevPivLoRSI    := rsiAtPiv

// Combined: either type triggers boost
bool bullDiv = bullDivSpread or bullDivRSI
bool bearDiv = bearDivSpread or bearDivRSI
int barsSinceBullDiv = ta.barssince(bullDiv)
bool recentBullDiv = not na(barsSinceBullDiv) and barsSinceBullDiv <= i_divWindow
float divBoost = i_divBoostOn and recentBullDiv ? i_divBoostMult : 1.0
int barsSinceBearDiv = ta.barssince(bearDiv)
bool recentBearDiv = not na(barsSinceBearDiv) and barsSinceBearDiv <= i_divWindow
float divSellBoost = i_divSellBoostOn and recentBearDiv ? i_divBoostMult : 1.0

// --- HTF PEN BAND (homogeneous: identical Donchian-extreme + learned-mult construction, for A/B) ---
f_bandLevels() =>
    float _atr = ta.atr(14)
    float _dHi = ta.highest(high, i_donchLen)[1]
    float _dLo = ta.lowest(low, i_donchLen)[1]
    var array<float> _bPen = array.new_float()
    var array<float> _sPen = array.new_float()
    if low <= _dLo and _atr > 0
        float _p = (_dLo - low) / _atr
        if _p > 0
            array.push(_bPen, _p)
            if array.size(_bPen) > i_adaptLookback
                array.shift(_bPen)
    if high >= _dHi and _atr > 0
        float _p = (high - _dHi) / _atr
        if _p > 0
            array.push(_sPen, _p)
            if array.size(_sPen) > i_adaptLookback
                array.shift(_sPen)
    var float _bMult = i_defaultMult
    var float _sMult = i_defaultMult
    if array.size(_bPen) >= i_minSamples
        _bMult := math.max(i_minMult, math.min(i_maxMult, array.avg(_bPen) * i_sensitivity))
    if array.size(_sPen) >= i_minSamples
        _sMult := math.max(i_minMult, math.min(i_maxMult, array.avg(_sPen) * i_sensitivity))
    [_dLo - _atr * _bMult, _dHi + _atr * _sMult]

f_bandLevelsOff() =>
    [_b, _s] = f_bandLevels()
    [_b[1], _s[1]]

// ─── PENETRATION-LEARNING BANDS (XDEV5) ─────────────────────────────

float atr = ta.atr(14)

float donchHi = ta.highest(high, i_donchLen)[1]
float donchLo = ta.lowest(low, i_donchLen)[1]

var array<float> buyPenetrations  = array.new_float()
var array<float> sellPenetrations = array.new_float()

bool touchedLower = low <= donchLo
bool touchedUpper = high >= donchHi

if touchedLower and atr > 0
    float pen = (donchLo - low) / atr
    if pen > 0
        array.push(buyPenetrations, pen)
        if array.size(buyPenetrations) > i_adaptLookback
            array.shift(buyPenetrations)

if touchedUpper and atr > 0
    float pen = (high - donchHi) / atr
    if pen > 0
        array.push(sellPenetrations, pen)
        if array.size(sellPenetrations) > i_adaptLookback
            array.shift(sellPenetrations)

var float buyMult  = i_defaultMult
var float sellMult = i_defaultMult

if array.size(buyPenetrations) >= i_minSamples
    float avgPen = array.avg(buyPenetrations) * i_sensitivity
    buyMult := math.max(i_minMult, math.min(i_maxMult, avgPen))

if array.size(sellPenetrations) >= i_minSamples
    float avgPen = array.avg(sellPenetrations) * i_sensitivity
    sellMult := math.max(i_minMult, math.min(i_maxMult, avgPen))

float buyBandLevel  = donchLo - (atr * buyMult)
float sellBandLevel = donchHi + (atr * sellMult)

// HTF pen band (homogeneous [1]-offset, no repaint)
int    _chartTfMin = int(timeframe.in_seconds() / 60)
int    _htfMin     = i_htfMode == "Auto" ? _chartTfMin * i_htfMult : i_htfMan
string _htfStr     = _htfMin >= 1440 ? str.tostring(math.max(1, int(_htfMin / 1440))) + "D" : str.tostring(_htfMin)
[htfBuyBand, htfSellBand] = request.security(syminfo.tickerid, _htfStr, f_bandLevelsOff(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ─── INPUTS: SIZING & SIGNALS ───────────────────────────────────────

grpSize     = "═══ POSITION SIZING ═══"
i_buyBase   = input.float(100, "Buy Base $",       minval=1, group=grpSize)
i_geoFactor = input.float(1.5, "Geo Factor",       step=0.1, group=grpSize)
i_geoSteps  = input.int(5, "Geo Steps",            minval=1, maxval=10, group=grpSize)
i_maxBuys   = input.int(24, "Max Buys",            minval=1, group=grpSize)
i_cascadeBase = input.float(1.0, "Cascade Decay",       group=grpSize, minval=0.5, maxval=1.0, step=0.05, tooltip="Each subsequent buy gets this × previous tier. 1.0 (default) = no decay. WARNING: cascade decay combined with geometric sizing is a proven destructive pairing fleet-wide (eliminated majority of realized PnL in testing) — only lower below 1.0 if geo factor is also set to 1.0.")

grpFilt     = "═══ STRUCTURAL FILTERS ═══"
i_llOn           = input.bool(false,  "LL Filter (Buy Side)",     group=grpFilt, tooltip="Require new lower low since last buy before next buy can fire.")
i_hhOn           = input.bool(true,   "HH Filter (Sell Side)",    group=grpFilt, tooltip="Require new higher high since last sell before next sell can fire.")
i_atrSepOn       = input.bool(true,   "ATR Buy Separation",       group=grpFilt, tooltip="Minimum ATR distance between consecutive buys.")
i_atrSepMult     = input.float(0.50,  "ATR Sep Buy Multiplier",   group=grpFilt, minval=0.1, maxval=3.0, step=0.05)
i_sellAtrSepOn   = input.bool(true,   "ATR Sell Separation",      group=grpFilt, tooltip="Minimum ATR distance between consecutive sells.")
i_sellAtrSepMult = input.float(2.0,   "ATR Sep Sell Multiplier",  group=grpFilt, minval=0.1, maxval=3.0, step=0.05)
i_wickBoostOn    = input.bool(true,   "Wick Rejection Boost",     group=grpFilt, tooltip="Boost buy size when band-touch bar shows strong lower wick rejection.")
i_wickBoostMult  = input.float(1.2,   "Wick Boost Multiplier",    group=grpFilt, minval=1.0, maxval=2.0, step=0.05)
i_wickThresh     = input.float(0.6,   "Wick Threshold",           group=grpFilt, minval=0.3, maxval=0.9, step=0.05, tooltip="Close must be in upper X% of bar range. 0.6 = close in upper 40%.")
i_regMatureOn    = input.bool(true,   "Regime Maturity Gate",      group=grpFilt, tooltip="Block signals until regime has matured — enough bars passed OR spread reached sufficient depth. Prevents premature signals in fresh regime flips.")
i_regMinBars     = input.int(8,       "Min Regime Bars",           group=grpFilt, minval=1, maxval=40, tooltip="Minimum bars in current regime before signals allowed.")
i_regMinSpread   = input.float(1.5,   "Min Regime Depth (ATR)",    group=grpFilt, minval=0.1, maxval=3.0, step=0.1, tooltip="Minimum spread depth in ATR units before signals allowed. Either bars OR depth qualifies.")
i_sellCooldown   = input.int(0,       "Sell Cooldown (bars)",      group=grpFilt, minval=0, maxval=10, tooltip="Minimum bars between consecutive sells.")
i_buyCooldown    = input.int(1,       "Buy Cooldown (bars)",       group=grpFilt, minval=0, maxval=10, tooltip="Minimum bars between consecutive buys.")

grpSell     = "═══ SELL ENGINE ═══"
i_sellBase  = input.float(20, "Sell Base %",        minval=1, maxval=100, group=grpSell)
i_sellMax   = input.float(50, "Sell Max %",         minval=1, maxval=100, group=grpSell)
i_maxSells  = input.int(50, "Max Sells",            minval=1, group=grpSell)
i_basisGuard = input.bool(true,  "Basis Guard (below-basis slivers)", group=grpSell, tooltip="Fleet kit, ninth chassis: any sell fired while price is below the pre-sell average entry takes only the Guard Sliver % of position instead of the computed sell percent (phase/div/DMFI scaling included). Keeps loss realizations tiny; the held inventory sells higher later. Changes sell SIZE only, never sell timing -- signals are untouched either way. Default ON at sliver 1.0 -- the committed 616.9 board (fleet #4). Turn OFF to reproduce the old 616.7 board.")
i_guardPct   = input.float(1.0,  "Guard Sliver % (Basis Guard)", group=grpSell, minval=0.25, maxval=50.0, step=0.25, tooltip="Sell %-of-position used below basis when the Guard is ON. 12.5 is the canonical launch value; each chassis probes its own knee (Core 10, XDEV 5, CycleTune 2.5, CCIBands 1.0 floor, CRUCIBLE 2.5 plateau, Simplex 1.0 committed, Opus46 1.0 committed). Floor 0.25 so the ladder cannot run out of road.")


grpVolSpike = "═══ VOLUME SPIKE ═══"
i_volSpikeOn   = input.bool(true,           "Show Volume Spike BG",  group=grpVolSpike, tooltip="Shade background when volume exceeds the SMA by the specified multiplier.")
i_volSpikeMult = input.float(2.0,           "Volume Multiplier",     group=grpVolSpike, minval=1.1, maxval=10.0, step=0.1, tooltip="Volume must exceed SMA × this value to trigger shading.")
i_volSpikeLen  = input.int(20,              "Volume SMA Length",     group=grpVolSpike, minval=5, maxval=200)
i_volSpikeClr  = input.color(#9B30FF,       "Spike Color",           group=grpVolSpike)
i_volSpikeFade = input.int(75,              "Transparency",          group=grpVolSpike, minval=50, maxval=97, step=1)

grpCascade  = "═══ CASCADE EXHAUSTION (CRUCIBLE port) ═══"
i_cascExhOn      = input.bool(true, "Cascade Exhaustion Boost", group=grpCascade, tooltip="CRUCIBLE port — ON by default (616.4, EARNED 3/3: MSTR 4H +$875/+0.8%, BTC 2H +$798/+5.7%, HYPE 2H +$240/+2.0% — all positive, identical signal structure, sizes up the right bars). Reward-only conviction multiplier that sizes up buys when multiple exhaustion signals agree — volume climax, price deceleration, ATR contraction, wick rejection. Each component asks a different question about whether the selling is genuinely running out of gas. Boost only (min 1.0), never blocks a signal. Buy-side only — sell-side conviction is proven harmful on accumulation-class systems.")
i_cascMinScore   = input.int(2, "Min Components (0-4)", minval=1, maxval=4, group=grpCascade, tooltip="How many of the 4 exhaustion signals must agree before the boost applies. 2 = any two is enough. 4 = all four must line up (very rare).")
i_cascBoostMult  = input.float(1.5, "Boost Multiplier", minval=1.0, maxval=3.0, step=0.25, group=grpCascade, tooltip="Buy size multiplied by this when cascade score meets the minimum. Reward-only: 1.0 when score is below minimum (no penalty).")
i_volClimaxMult  = input.float(3.0, "Vol Climax (× SMA20)", minval=1.5, maxval=10.0, step=0.5, group=grpCascade, tooltip="Volume must exceed its 20-bar SMA by this factor to count as a climax bar.")
i_cascWickRatio  = input.float(2.0, "Wick Rejection Ratio", minval=1.0, maxval=5.0, step=0.5, group=grpCascade, tooltip="Lower wick must be this many times the body size to count as rejection. Separate from Opus46's existing wick boost (which uses close position in range).")

grpThrot    = "═══ SELL THROTTLE (KEEL port) ═══"
i_sellThrotOn    = input.bool(true, "Adaptive Sell Throttle", group=grpThrot, tooltip="Waits longer between sells while the market is running hot, so each sell happens at a better price. ON by default (616.2, EARNED): Opus46 pairs — MSTR 4H +22%, HYPE 2H +13%, MRVL 8H +10%, BTC 2H flat (no rallies to exploit). KEEL pairs 4/4 (+23% to +52%). Only does work on charts with real uptrends; harmless elsewhere. First sell of each cycle always fires instantly. Replaces the fixed Sell Cooldown (now default 0) — do not run both.")
i_sellThrotBase  = input.int(4, "Throttle Base (bars)", minval=1, maxval=20, group=grpThrot)
i_sellThrotScale = input.float(1.0, "Throttle Scale (per σ)", minval=0.25, maxval=4.0, step=0.25, group=grpThrot, tooltip="Cooldown multiplier grows by this much per +1σ of bull spreadZ. mult = 1 + min(cap-1, max(0,spreadZ) × scale).")
i_sellThrotMax   = input.float(10.0, "Throttle Max Mult", minval=2.0, maxval=30.0, step=1.0, group=grpThrot)


// ─── H DISPLAY INPUTS ───────────────────────────────────────────────
grpDispH   = "═══ H DISPLAY ═══"
i_histFade  = input.int(50,    "Hist Fade (contracting)", minval=0, maxval=100, group=grpDispH)
i_showMfi   = input.bool(true, "Show Money Flow Wave",  group=grpDispH, tooltip="Green/red filled wave showing smoothed MFI direction.")
i_showDmfi  = input.bool(false,"Show DMFI Area",        group=grpDispH, tooltip="Overlay DMFI conviction area (cyan/magenta) on histogram. OFF by default to reduce visual complexity.")
i_showL0    = input.bool(false,"Show Vetoed Signals (L0)", group=grpDispH, tooltip="Dim triangles where the raw band/Z trigger fired but a gate (capacity, breaker, cooldown, LL, ATR sep, throttle, inventory) vetoed it. Shows what the gate stack is doing.")
i_showTable = input.bool(false,"Show Status Table",     group=grpDispH)
i_tblPos    = input.string("Bottom Right", "Table Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=grpDispH)
i_showKey   = input.bool(true, "Show Key",              group=grpDispH)
i_keyPos    = input.string("Bottom Left", "Key Position", options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=grpDispH)

// ─── STRUCTURAL FILTERS (XDEV5/ATHANOR) ────────────────────────────

var float lastBuyPrice = na, var float lastBuyLow = na, var float lastSellHigh = na
var float lastSellPrice = na
var int   lastSellBar = 0
var int   lastBuyBar  = 0

bool llOK         = not i_llOn or na(lastBuyLow) or low < lastBuyLow
bool hhOK         = not i_hhOn or na(lastSellHigh) or high > lastSellHigh
bool atrSepOK     = not i_atrSepOn or na(lastBuyPrice) or math.abs(close - lastBuyPrice) >= i_atrSepMult * atr
bool sellAtrSepOK = not i_sellAtrSepOn or na(lastSellPrice) or (close - lastSellPrice) >= atr * i_sellAtrSepMult

// ─── WICK REJECTION BOOST ────────────────────────────────────────────

float wickScore = (high - low) > 0 ? (close - low) / (high - low) : 0.5
float wickBoost = i_wickBoostOn and wickScore >= i_wickThresh ? i_wickBoostMult : 1.0

// ─── BAND-TOUCH SIGNALS + Z-OVERRIDE + REGIME GATE + FILTERS ───────

// Regime maturity: block signals until regime is established (bars OR depth)
bool regimeBuyMature  = not i_regMatureOn or blueAge >= i_regMinBars or (bluePeakSpread / 100.0) >= i_regMinSpread
bool regimeSellMature = not i_regMatureOn or goldAge >= i_regMinBars or (goldPeakSpread / 100.0) >= i_regMinSpread

// Sell cooldown
bool sellCoolOK = i_sellCooldown == 0 or lastSellBar == 0 or (bar_index - lastSellBar) >= i_sellCooldown

// Buy cooldown
bool buyCoolOK = i_buyCooldown == 0 or lastBuyBar == 0 or (bar_index - lastBuyBar) >= i_buyCooldown

// Band touch: BUY in BEAR + LL + ATR sep, SELL in BULL + HH + ATR sep
bool bandBuyTouch  = low <= buyBandLevel and bearish and regimeBuyMature and painBuyOK and barstate.isconfirmed
bool bandSellTouch = high >= sellBandLevel and bullish and hhOK and sellAtrSepOK and regimeSellMature and sellCoolOK and painSellOK and barstate.isconfirmed

// Combined triggers: band touch OR z-score override (z bypasses regime/maturity/pain; LL + ATR sep + cooldown still apply)
// HTF structural touches (homogeneous with chart bands)
bool chartBuyStruct  = low  <= buyBandLevel
bool htfBuyStruct    = low  <= htfBuyBand
bool chartSellStruct = high >= sellBandLevel
bool htfSellStruct   = high >= htfSellBand
bool buyHtfGate  = i_buyHtfMode  == "Off" ? true : i_buyHtfMode  == "Chart" ? chartBuyStruct  : i_buyHtfMode  == "HTF" ? htfBuyStruct  : i_buyHtfMode  == "Either" ? (chartBuyStruct  or htfBuyStruct)  : (chartBuyStruct  and htfBuyStruct)
bool sellHtfGate = i_sellHtfMode == "Off" ? true : i_sellHtfMode == "Chart" ? chartSellStruct : i_sellHtfMode == "HTF" ? htfSellStruct : i_sellHtfMode == "Either" ? (chartSellStruct or htfSellStruct) : (chartSellStruct and htfSellStruct)

bool sigBuy  = (bandBuyTouch or zBuyOverride) and buyHtfGate
bool sigSell = (bandSellTouch or zSellOverride) and sellHtfGate

// ─── POSITION STATE ─────────────────────────────────────────────────

var int   cycBuyLots  = 0
var int   cycSellLots = 0
var float totalQty    = 0.0
var float totalCost   = 0.0
var float avgEntry    = 0.0

// Tail-risk breaker: halt buys when DD exceeds threshold
var bool breakerActive = false
float ddPct = totalQty > 0 and avgEntry > 0 ? (avgEntry - close) / avgEntry * 100 : 0.0
if i_breakerOn and ddPct >= i_breakerHalt
    breakerActive := true
if i_breakerOn and ddPct <= i_breakerResume
    breakerActive := false
bool breakerOK = not i_breakerOn or not breakerActive

// Final signals with capacity + breaker
// 616.0: if this raw trigger will close the cycle (sells occurred), the lot cap
// must be judged against the fresh cycle (0 lots), not the dying one — otherwise
// the cycle-closing buy is wrongly cap-blocked at the boundary (AZOTH-family ordering bug).
bool cycleWillClose = sigBuy and cycSellLots > 0 and totalQty > 0
int  effBuyLots     = cycleWillClose ? 0 : cycBuyLots
bool buySignal  = sigBuy and effBuyLots < i_maxBuys and breakerOK and buyCoolOK and llOK and atrSepOK
// Adaptive sell throttle (616.1): cooldown stretches with bull extension strength
float sellThrotMult = 1.0 + math.min(i_sellThrotMax - 1.0, math.max(0.0, bullish ? spreadZ : 0.0) * i_sellThrotScale)
int   sellThrotCD   = math.round(i_sellThrotBase * sellThrotMult)
bool  sellThrotOK   = not i_sellThrotOn or cycSellLots == 0 or lastSellBar == 0 or (bar_index - lastSellBar) >= sellThrotCD

bool sellSignal = sigSell and cycSellLots < i_maxSells and totalQty > 0 and sellThrotOK

// ─── CASCADE EXHAUSTION (CRUCIBLE port) ──────────────────────────────
// Four independent questions about whether selling energy is spent:
// 1. Volume climax — is volume spiking? (capitulation/panic signature)
// 2. Price deceleration — price still falling but slowing down (2nd derivative)
// 3. ATR contraction — volatility was elevated but is now declining (storm passing)
// 4. Wick rejection — long lower wick with bullish close (buyers stepping in)
float cascVolSma    = ta.sma(volume, 20)
bool  cascVolClimax = volume > cascVolSma * i_volClimaxMult

float cascPriceVel  = close - close[1]
float cascPriceAcc  = cascPriceVel - cascPriceVel[1]
bool  cascPriceBot  = cascPriceVel < 0 and cascPriceAcc > 0

float cascAtrSma    = ta.sma(atr, 20)
float cascAtrDelta  = atr - atr[1]
bool  cascAtrContr  = atr > cascAtrSma * 1.5 and cascAtrDelta < 0

float cascWickLo    = math.min(close, open) - low
float cascBodyAbs   = math.max(math.abs(close - open), syminfo.mintick)
bool  cascWickRej   = cascWickLo > cascBodyAbs * i_cascWickRatio and close > open

int   cascBuyScore  = (cascVolClimax ? 1 : 0) + (cascPriceBot ? 1 : 0) + (cascAtrContr ? 1 : 0) + (cascWickRej ? 1 : 0)
float cascBuyBoost  = i_cascExhOn and cascBuyScore >= i_cascMinScore ? i_cascBoostMult : 1.0

// Geometric sizing × phase buy boost
int  geoStep   = math.min(i_geoSteps, cycBuyLots)
float geoMult  = math.pow(i_geoFactor, geoStep)
float cascadeDecay = math.pow(i_cascadeBase, cycBuyLots)
float buySize  = i_buyBase * geoMult * cascadeDecay * phaseBuyBoost * divBoost * wickBoost * dmfiMult * pctBuyMult * cascBuyBoost

// Sell sizing: %-of-remaining × phase sell boost
float sellPctCalc = math.min(i_sellMax, i_sellBase * phaseBoost * divSellBoost * dmfiSellMult * pctSellMult)
// BASIS GUARD: below the pre-sell average entry the sell takes only the sliver %.
float sellPctEff = i_basisGuard and totalQty > 0 and close < avgEntry ? i_guardPct : sellPctCalc
float sellQty = totalQty > 0 ? totalQty * (sellPctEff / 100) : 0.0

// ─── CYCLE ACCOUNTING (fleet standard: per-cycle PnL) ───────────────

var float realized      = 0.0
var int   wins          = 0
var int   losses        = 0
var int   totalBuySigs  = 0
var int   totalSellSigs = 0
var int   cycleCount    = 0
var float totalDeployed = 0.0
var float maxCost       = 0.0
var float peakPnl       = 0.0
var float maxDD         = 0.0
var float sumWins       = 0.0
var float sumLosses     = 0.0
var float cycleSellRev  = 0.0
var float cycleSellQty  = 0.0
var float cycPeakPnL    = 0.0
var float cycMaxDD      = 0.0
var float sumCycDD      = 0.0

// Cycle close: raw buy trigger after sells (XDEV5 pattern)
bool rawBuyTrigger = sigBuy
bool bookCycle = false
float bookPnL = 0.0

if rawBuyTrigger and cycSellLots > 0 and totalQty > 0
    float soldCost = cycleSellQty * avgEntry
    bookPnL  := cycleSellRev - soldCost
    bookCycle := true
    cycleSellRev := 0.0
    cycleSellQty := 0.0
    cycSellLots  := 0
    cycBuyLots   := 0
    lastBuyPrice  := na
    lastBuyLow    := na
    lastSellHigh  := na
    lastSellPrice := na
    breakerActive := false

// Position-zero close: if sells reduced position to zero
if totalQty <= 0 and cycSellLots > 0
    float soldCost = cycleSellQty * avgEntry
    bookPnL  := cycleSellRev - soldCost
    bookCycle := true
    cycleSellRev := 0.0
    cycleSellQty := 0.0
    cycSellLots  := 0
    cycBuyLots   := 0
    totalQty     := 0.0
    totalCost    := 0.0
    lastBuyPrice := na
    lastBuyLow   := na
    lastSellHigh := na
    lastSellPrice := na

if bookCycle
    cycleCount += 1
    sumCycDD   += cycMaxDD
    cycPeakPnL := realized + bookPnL
    cycMaxDD   := 0.0
    if bookPnL >= 0
        wins     += 1
        sumWins  += bookPnL
    else
        losses   += 1
        sumLosses += math.abs(bookPnL)
    realized += bookPnL

// Process buy
if buySignal
    float buyQty = buySize / close
    totalQty    += buyQty
    totalCost   += buySize
    avgEntry    := totalQty > 0 ? totalCost / totalQty : close
    cycBuyLots  += 1
    totalBuySigs += 1
    totalDeployed += buySize
    lastBuyPrice := close
    lastBuyLow   := low
    lastBuyBar   := bar_index
    lastSellHigh := na
    lastSellPrice := na
    if totalCost > maxCost
        maxCost := totalCost

// Process sell (accumulate within cycle, book on cycle close)
if sellSignal
    float sellVal = sellQty * close
    cycleSellRev += sellVal
    cycleSellQty += sellQty
    totalQty     -= sellQty
    totalCost    := totalQty * avgEntry
    cycSellLots  += 1
    totalSellSigs += 1
    lastSellHigh := high
    lastBuyLow   := na
    lastSellPrice := close
    lastSellBar  := bar_index

// Drawdown tracking (includes unbooked cycle PnL in unrealized)
float posVal     = totalQty * close
float unrealized = cycleSellRev + posVal - totalCost - (cycleSellQty * avgEntry)
float totalPnl   = realized + unrealized
peakPnl    := math.max(peakPnl, totalPnl)
maxDD      := math.min(maxDD, totalPnl - peakPnl)
cycPeakPnL := math.max(cycPeakPnL, totalPnl)
cycMaxDD   := math.max(cycMaxDD, cycPeakPnL - totalPnl)

// ─── PERFORMANCE METRICS ────────────────────────────────────────────

int   totalTrades = wins + losses
float winRate     = totalTrades > 0 ? float(wins) / float(totalTrades) * 100 : 0.0
float avgWinCalc  = wins > 0 ? sumWins / float(wins) : 0.0
float avgLossCalc = losses > 0 ? -sumLosses / float(losses) : 0.0
float expectancy  = totalTrades > 0 ? realized / float(totalTrades) : 0.0
float pf          = sumLosses > 0 ? sumWins / sumLosses : (sumWins > 0 ? 999.0 : 0.0)
float avgDDVal    = cycleCount > 0 ? -sumCycDD / float(cycleCount) : 0.0
float roiVal      = maxCost > 0 ? realized / maxCost * 100 : 0.0
float dwpVal      = totalDeployed > 0 ? realized / totalDeployed * 100 : 0.0

// ═══════════════════════════════════════════════════════════════════
//  H PANE DISPLAY LAYER (v2.0)
// ═══════════════════════════════════════════════════════════════════

// Display-only helpers (engine quantities untouched)
bool  zBuyZone  = spreadZ <= i_zBuyThresh
bool  zSellZone = spreadZ >= i_zSellThresh
float rawSpread = v2 != 0 ? (v1 - v2) / v2 * 100 : 0.0
float dmfiThresh = i_dmfiCeil / 2.0

// Expansion/contraction
bool expanding = math.abs(atrNormSpread) > math.abs(nz(atrNormSpread[1]))

// Histogram: regime-colored, faded when contracting
color histColor = bullish ?
     (expanding ? color.new(#FFD700, 0) : color.new(#FFD700, i_histFade)) :
     (expanding ? color.new(#1E90FF, 0) : color.new(#1E90FF, i_histFade))

plot(atrNormSpread, "Spread Histogram", color=histColor, style=plot.style_histogram, linewidth=2)

// Money Flow wave (smoothed MFI centered at 50, scaled to match spread range)
float mfNorm    = (smoothMFI - 50.0) / 50.0
float spreadPeakH = ta.highest(math.abs(atrNormSpread), 100)
float mfWave    = i_showMfi ? mfNorm * spreadPeakH * 0.8 : na
color mfWaveClr = mfNorm >= 0 ? color.new(#00FF88, 50) : color.new(#FF4444, 50)
plot(mfWave, "Money Flow", color=mfWaveClr, style=plot.style_area, linewidth=1)

// Spread line (regime-colored, solid)
color spreadLineClr = bullish ? color.new(#FFD700, 0) : color.new(#1E90FF, 0)
plot(atrNormSpread, "Spread", color=spreadLineClr, linewidth=2)

// DMFI area (optional, default OFF) — color threshold = half ceiling, synced with table
float dmfiScaled = i_showDmfi and i_useDmfi ? (dmfiClamp / i_dmfiCeil) * spreadPeakH * 0.25 : na
color dmfiAreaClr = dmfi < -dmfiThresh ? color.new(#00FFFF, 65) : dmfi > dmfiThresh ? color.new(#FF00FF, 65) : color.new(#808080, 80)
plot(dmfiScaled, "DMFI", color=dmfiAreaClr, style=plot.style_area, linewidth=1)

// Zero line
hline(0, "Zero", color=color.new(#808080, 50), linestyle=hline.style_dotted)

// Regime background
bgcolor(bearish ? color.new(#1E90FF, 93) : color.new(#FFD700, 93), title="Regime BG")

// RSI extremes background
bgcolor(rsiVal < 30 ? color.new(#00FF88, 85) : na, title="RSI Oversold BG")
bgcolor(rsiVal > 70 ? color.new(#FF4444, 85) : na, title="RSI Overbought BG")

// Volume spike background (overlay parity)
float volSpikeSma = ta.sma(volume, i_volSpikeLen)
bool  volSpike = i_volSpikeOn and volume >= volSpikeSma * i_volSpikeMult
bgcolor(volSpike ? color.new(i_volSpikeClr, i_volSpikeFade) : na, title="Volume Spike BG")

// ─── SIGNAL MARKERS (shadow mirror parity, by construction) ─────────
// Buy: conviction-colored triangles (green tiers, light -> deep with position depth;
// H-specific palette -- greens for contrast against the blue regime/histogram zones)
color buyCol = cycBuyLots <= 1 ? color.new(#76FF03, 0) : cycBuyLots <= 3 ? color.new(#00FF88, 0) : cycBuyLots <= 5 ? color.new(#00E676, 0) : color.new(#00C853, 0)
plotshape(buySignal ? atrNormSpread : na, "Buy", shape.triangleup, location.absolute, buyCol, size=size.small)
plotshape(sellSignal ? atrNormSpread : na, "Sell", shape.triangledown, location.absolute, color.new(#FF00FF, 0), size=size.small)

// L0 vetoed-detect layer (default OFF): raw trigger fired, gate stack said no
plotshape(i_showL0 and sigBuy and not buySignal, "Vetoed Buy (L0)", shape.triangleup, location.bottom, color.new(#00FFFF, 70), size=size.tiny)
plotshape(i_showL0 and sigSell and not sellSignal, "Vetoed Sell (L0)", shape.triangledown, location.top, color.new(#FF00FF, 70), size=size.tiny)

// Z-override entry diamonds
plotshape(zBuyZone and not zBuyZone[1], "Z-Buy", shape.diamond, location.bottom, color.new(#00FF88, 0), size=size.tiny)
plotshape(zSellZone and not zSellZone[1], "Z-Sell", shape.diamond, location.top, color.new(#FF00FF, 0), size=size.tiny)

// Pain gate: capitulation/euphoria markers
plotshape(i_usePainGate and capRecent and not capRecent[1], "Cap Recent", shape.triangleup, location.bottom, color.new(#00FFFF, 0), size=size.tiny)
plotshape(i_usePainGate and euphRecent and not euphRecent[1], "Euph Recent", shape.triangledown, location.top, color.new(#FF00FF, 0), size=size.tiny)

// Divergence dots (fleet standard, pane-located)
plotshape(i_showDiv and bullDivSpread, "Bull Div Spread", shape.circle, location.bottom, color.new(#00FF00, 0), size=size.tiny, offset=-i_divPivR)
plotshape(i_showDiv and bearDivSpread, "Bear Div Spread", shape.circle, location.top, color.new(#FF6B35, 0), size=size.tiny, offset=-i_divPivR)
plotshape(i_showRSIDiv and bullDivRSI, "Bull Div RSI", shape.diamond, location.bottom, color.new(#00FFAA, 0), size=size.tiny, offset=-i_divPivR)
plotshape(i_showRSIDiv and bearDivRSI, "Bear Div RSI", shape.diamond, location.top, color.new(#FF00FF, 0), size=size.tiny, offset=-i_divPivR)

// ─── STATUS TABLE ───────────────────────────────────────────────────

var tPos = switch i_tblPos
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    => position.bottom_right

var table tbl = table.new(tPos, 2, 14, border_color=#333355, border_width=1, frame_color=#333355, frame_width=1)
hBg = #1a1a2e
rBg = #0d0d1a

if barstate.islast and i_showTable
    int row = 0

    // SETUP — gate-aware: shows blocker when zone is not actionable
    bool   setupMature  = bearish ? regimeBuyMature : regimeSellMature
    bool   setupPainOK  = bearish ? painBuyOK : painSellOK
    string setupZone    = bearish ? "BUY" : "SELL"
    string setupStr = zBuyZone ? "Z-BUY" : zSellZone ? "Z-SELL" :
         not setupMature ? setupZone + " WAIT" :
         not setupPainOK ? setupZone + " GATED" :
         setupZone + " ZONE"
    color  setupCol = zBuyZone ? #00FF88 : zSellZone ? #FF00FF :
         not setupMature or not setupPainOK ? #FF4444 :
         bearish ? #1E90FF : #FFD700
    table.cell(tbl, 0, row, "SETUP", text_color=#FFFFFF, bgcolor=hBg, text_size=size.small)
    table.cell(tbl, 1, row, setupStr, text_color=setupCol, bgcolor=hBg, text_size=size.normal)
    row += 1

    color zClr = spreadZ <= i_zBuyThresh ? #00FF88 : spreadZ >= i_zSellThresh ? #FF00FF : #FFFFFF
    table.cell(tbl, 0, row, "Spread Z", text_color=#FFFFFF, bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 1, row, str.tostring(spreadZ, "#.##") + "σ", text_color=zClr, bgcolor=rBg, text_size=size.small)
    row += 1

    string regStr = bullish ? "GOLD" : "BLUE"
    color  regClr = bullish ? #FFD700 : #1E90FF
    int    regAge = bullish ? goldAge : blueAge
    table.cell(tbl, 0, row, "Regime", text_color=#FFFFFF, bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 1, row, regStr + " " + str.tostring(regAge), text_color=regClr, bgcolor=rBg, text_size=size.small)
    row += 1

    bool curMature = bearish ? regimeBuyMature : regimeSellMature
    float curDepth = bearish ? bluePeakSpread / 100.0 : goldPeakSpread / 100.0
    string matStr = not i_regMatureOn ? "OFF" : curMature ? "READY" : "WAIT"
    color  matClr = not i_regMatureOn ? #FFFFFF : curMature ? #00FF88 : #FF4444
    string matDetail = i_regMatureOn ? " " + str.tostring(curDepth, "#.#") + "ATR" : ""
    table.cell(tbl, 0, row, "Maturity", text_color=#FFFFFF, bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 1, row, matStr + matDetail, text_color=matClr, bgcolor=rBg, text_size=size.small)
    row += 1

    string painStr = "—"
    color  painClr = #FFFFFF
    if not i_usePainGate
        painStr := "OFF"
    else if bearish
        painStr := painBuyOK ? "CAP OK" : "NO CAP"
        painClr := painBuyOK ? #00FF88 : #FF4444
    else if bullish
        painStr := painSellOK ? "EUPH OK" : "NO EUPH"
        painClr := painSellOK ? #00FF88 : #FF4444
    table.cell(tbl, 0, row, "Pain Gate", text_color=#FFFFFF, bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 1, row, painStr + " " + str.tostring(pressZ, "#.#"), text_color=painClr, bgcolor=rBg, text_size=size.small)
    row += 1

    color dmfiClr = dmfi <= -dmfiThresh ? #00FFFF : dmfi >= dmfiThresh ? #FF00FF : #FFFFFF
    string dmfiVal = str.tostring(dmfi, "#.#") + " " + str.tostring(dmfiMult, "#.##") + "x"
    table.cell(tbl, 0, row, "DMFI", text_color=#FFFFFF, bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 1, row, dmfiVal, text_color=dmfiClr, bgcolor=rBg, text_size=size.small)
    row += 1

    string gateStr = bearish ? "BUY OK" : bullish ? "SELL OK" : "BLOCKED"
    color  gateCol = bearish ? #1E90FF : bullish ? #FFD700 : #FF4444
    table.cell(tbl, 0, row, "Gate", text_color=#FFFFFF, bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 1, row, gateStr, text_color=gateCol, bgcolor=rBg, text_size=size.small)
    row += 1

    // Book (shadow mirror state: lots, qty, basis, Guard)
    string bookStr = str.tostring(cycBuyLots) + "B/" + str.tostring(cycSellLots) + "S q" + str.tostring(totalQty, "#.##")
    table.cell(tbl, 0, row, "Book", text_color=#FFFFFF, bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 1, row, bookStr, text_color=#00E5FF, bgcolor=rBg, text_size=size.small)
    row += 1

    string guardStr = i_basisGuard ? (totalQty > 0 and close < avgEntry ? "SLIVER " + str.tostring(i_guardPct, "#.#") + "%" : "ARMED " + str.tostring(i_guardPct, "#.#") + "%") : "OFF"
    color  guardClr = i_basisGuard ? (totalQty > 0 and close < avgEntry ? #FF4444 : #00FF88) : #FFFFFF
    table.cell(tbl, 0, row, "Guard", text_color=#FFFFFF, bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 1, row, guardStr, text_color=guardClr, bgcolor=rBg, text_size=size.small)
    row += 1

    color buyBClr = phaseBuyBoost >= 2.0 ? #00FFFF : phaseBuyBoost >= 1.3 ? #FFD700 : phaseBuyBoost > 1.05 ? #00FF88 : #FFFFFF
    table.cell(tbl, 0, row, "Buy Boost", text_color=#FFFFFF, bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 1, row, str.tostring(phaseBuyBoost, "#.##") + "×", text_color=buyBClr, bgcolor=rBg, text_size=size.small)
    row += 1

    color sellBClr = phaseBoost >= 2.0 ? #FF4444 : phaseBoost >= 1.3 ? #FFD700 : phaseBoost > 1.05 ? #00FF88 : #FFFFFF
    table.cell(tbl, 0, row, "Sell Boost", text_color=#FFFFFF, bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 1, row, str.tostring(phaseBoost, "#.##") + "×", text_color=sellBClr, bgcolor=rBg, text_size=size.small)
    row += 1

    table.cell(tbl, 0, row, "Spread", text_color=#FFFFFF, bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 1, row, str.tostring(atrNormSpread, "#.##"), text_color=atrNormSpread > 0 ? #FFD700 : #1E90FF, bgcolor=rBg, text_size=size.small)
    row += 1

    string divStr = bullDivSpread ? "BULL S" : bullDivRSI ? "BULL R" : bearDivSpread ? "BEAR S" : bearDivRSI ? "BEAR R" : "—"
    color  divCol = (bullDivSpread or bullDivRSI) ? #00FF00 : (bearDivSpread or bearDivRSI) ? #FF6B35 : #FFFFFF
    table.cell(tbl, 0, row, "Diverg", text_color=#FFFFFF, bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 1, row, divStr, text_color=divCol, bgcolor=rBg, text_size=size.small)
    row += 1

    table.cell(tbl, 0, row, "Raw %", text_color=#FFFFFF, bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 1, row, str.tostring(rawSpread, "#.##") + "%", text_color=rawSpread > 0 ? #FFD700 : #1E90FF, bgcolor=rBg, text_size=size.small)

// ─── KEY TABLE ──────────────────────────────────────────────────────

var kPos = switch i_keyPos
    "Top Left"     => position.top_left
    "Top Right"    => position.top_right
    "Bottom Right" => position.bottom_right
    => position.bottom_left

var table keyTbl = table.new(kPos, 2, 9, border_color=#333355, border_width=1, frame_color=#333355, frame_width=1)

if barstate.islast and i_showKey
    table.cell(keyTbl, 0, 0, "KEY", text_color=#FFD700, bgcolor=#1a1a2e, text_size=size.small)
    table.cell(keyTbl, 1, 0, "Opus46 H · 616.9", text_color=#d0d0d0, bgcolor=#1a1a2e, text_size=size.small)
    table.cell(keyTbl, 0, 1, "▲ green", text_color=#00FF88, bgcolor=#0d0d1a, text_size=size.small)
    table.cell(keyTbl, 1, 1, "Buy (tier-colored)", text_color=#d0d0d0, bgcolor=#0d0d1a, text_size=size.small)
    table.cell(keyTbl, 0, 2, "▼ magenta", text_color=#FF00FF, bgcolor=#0d0d1a, text_size=size.small)
    table.cell(keyTbl, 1, 2, "Sell", text_color=#d0d0d0, bgcolor=#0d0d1a, text_size=size.small)
    table.cell(keyTbl, 0, 3, "▲▼ dim", text_color=#4DA6FF, bgcolor=#0d0d1a, text_size=size.small)
    table.cell(keyTbl, 1, 3, "Vetoed (L0, toggle)", text_color=#d0d0d0, bgcolor=#0d0d1a, text_size=size.small)
    table.cell(keyTbl, 0, 4, "● lime/orange", text_color=#00FF00, bgcolor=#0d0d1a, text_size=size.small)
    table.cell(keyTbl, 1, 4, "Spread divergence", text_color=#d0d0d0, bgcolor=#0d0d1a, text_size=size.small)
    table.cell(keyTbl, 0, 5, "◆ teal/magenta", text_color=#00FFAA, bgcolor=#0d0d1a, text_size=size.small)
    table.cell(keyTbl, 1, 5, "RSI div / Z zone", text_color=#d0d0d0, bgcolor=#0d0d1a, text_size=size.small)
    table.cell(keyTbl, 0, 6, "▲▼ tiny cyan/mag", text_color=#00FFFF, bgcolor=#0d0d1a, text_size=size.small)
    table.cell(keyTbl, 1, 6, "Capitulation / Euphoria", text_color=#d0d0d0, bgcolor=#0d0d1a, text_size=size.small)
    table.cell(keyTbl, 0, 7, "▌columns", text_color=#FFD700, bgcolor=#0d0d1a, text_size=size.small)
    table.cell(keyTbl, 1, 7, "ATR-norm spread (gold bull / blue bear)", text_color=#d0d0d0, bgcolor=#0d0d1a, text_size=size.small)
    table.cell(keyTbl, 0, 8, "≈ wave", text_color=#00FF88, bgcolor=#0d0d1a, text_size=size.small)
    table.cell(keyTbl, 1, 8, "Money flow (MFI)", text_color=#d0d0d0, bgcolor=#0d0d1a, text_size=size.small)

// ─── EXPORTS + ALERTS ────────────────────────────────────────────────

plot(buySignal ? 1 : sellSignal ? -1 : 0, "Signal", color=color.new(color.blue, 100), display=display.data_window)
plot(cascBuyScore, "Cascade Score", display=display.data_window, color=na)
plot(cascBuyBoost, "Cascade Boost", display=display.data_window, color=na)
plot(sellThrotMult, "Sell Throttle Mult", display=display.data_window, color=na)
plot(sellThrotCD,   "Sell Throttle CD",   display=display.data_window, color=na)
plot(616.9, "BUILD", display=display.data_window, color=na)

alertcondition(zBuyZone and not zBuyZone[1],   "Z-Buy Zone Entered",  "Opus46 H: Spread Z crossed below buy override threshold")
alertcondition(zSellZone and not zSellZone[1], "Z-Sell Zone Entered", "Opus46 H: Spread Z crossed above sell override threshold")
alertcondition(bullDivSpread or bullDivRSI,  "Bullish Divergence", "Opus46 H: Bullish divergence detected (spread or RSI)")
alertcondition(bearDivSpread or bearDivRSI,  "Bearish Divergence", "Opus46 H: Bearish divergence detected (spread or RSI)")
alertcondition(capRecent and not capRecent[1],   "Capitulation", "Opus46 H: Pressure Z capitulation extreme reached")
alertcondition(euphRecent and not euphRecent[1], "Euphoria",     "Opus46 H: Pressure Z euphoria extreme reached")
````

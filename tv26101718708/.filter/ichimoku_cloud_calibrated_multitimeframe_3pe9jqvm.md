# Ichimoku Cloud  Calibrated & Multi-Timeframe

- url: https://www.tradingview.com/script/3pe9jQVM-Ichimoku-Cloud-Calibrated-Multi-Timeframe/
- type: indicator
- pine_id: PUB;3095d45080e84285a9628535d399cc1c
- version: 1.0

## Description

# Ichimoku Cloud — Strength-Graded, Calibrated & Multi-Timeframe (ICHI ARC)

## What it is

The classic Ichimoku Kinko Hyo five-line system — Tenkan, Kijun, the Senkou A/B cloud (Kumo) and the Chikou span — drawn faithfully, but with the *reading* of it done by a modern engine instead of the eye.

A plain Ichimoku throws six signals at once with no synthesis, uses fixed periods designed for one market in the 1930s, and tells you nothing about whether its signals actually work.

ICHI ARC keeps the cloud exactly as the core, then fuses the whole signal cluster into **one 0–100 strength score per signal**, confirms it with market structure and volume, and **calibrates the score to what actually happened on this symbol**.

It runs on **any symbol, asset class, timeframe and market**. The raw data source and every optional feed are user-selectable; nothing is hard-coded to a market.

---

## Why these components are combined (mashup rationale)

A raw Ichimoku has four well-known weaknesses, and each added layer fixes exactly one of them and feeds the next — none is decorative:

### 1. Adaptive periods (fixes the "one-market settings" problem)

Optionally derive Tenkan/Kijun/Span-B from the measured **dominant cycle** so the cloud fits the instrument and timeframe instead of fixed 9/26/52. Classic mode is the default.

### 2. One strength score (fixes "six signals, no synthesis")

Price-vs-cloud (the master bias), Tenkan/Kijun, Chikou clearance, current cloud colour, the forward Kumo twist, Kijun slope and cloud thickness are weighted into a single 0–100 grade so you read one number, not six lines.

### 3. Market-structure confirmation, BOS / CHoCH (fixes false breakouts)

Swing-pivot structure independently checks whether a cloud breakout is a real structural shift: a same-direction Break of Structure strengthens the signal; a signal against the last Change of Character is vetoed.

This is price geometry, so it is orthogonal to the cloud and to volume.

### 4. Relative-volume confirmation (fixes dead-volume fakeouts)

Real breakouts carry volume; RVOL (volume vs its own average) boosts strong-volume signals and can veto dead-volume ones — a third, independent angle on the same failure mode.

### 5. Regime + multi-timeframe context (keeps it out of chop)

An efficiency-ratio / trend-strength / volatility-cluster classifier and three higher-timeframe clouds gate the signals, since Ichimoku breakouts fail in range-bound tape.

### 6. Conviction, vetoes and Kelly sizing

Everything resolves to one LONG / SHORT / FLAT verdict with hard vetoes, and the calibrated win-rate is turned into a fractional-Kelly position-size suggestion.

Remove any one layer and a specific Ichimoku failure returns (wrong fit, signal overload, false breakout, dead-volume breakout, chop). That is the justification for combining them.

---

## How it is original

ICHI ARC keeps a **self-calibrating quality engine**.

Every cloud-bias signal is checked a fixed window later for whether price actually ran a **favourable target (in ATR)** in the signal's direction — i.e. whether the trade *worked*, not merely whether the cloud held.

From that it reports, live, the **realised win-rate of past signals at each strength tier on this symbol** plus the average favourable move (in ATR), can **auto-learn the strength cutoff** worth acting on, and converts the win-rate into a **Kelly-based sizing suggestion**.

A stock Ichimoku tells you nothing about the quality of its own signals; this one is accountable to its own track record.

---

## What it plots

• The full classic Ichimoku: Tenkan, Kijun, the displaced Senkou A/B **cloud** (with opacity scaled by cloud thickness), the Chikou span, and marked forward **Kumo twists**.

• Strength-graded signal triangles with a score label (`72 S` / `55 M` / `31 w`), and small diamonds marking **Change-of-Character** structure flips.

• A compact **dashboard** featuring:

* Verdict
* Regime
* Price-vs-cloud
* Structure state
* Signal strength and realised win-rate
* Tenkan/Kijun status
* Chikou status
* MTF agreement
* Relative volume
* Calibration statistics
* Kelly / expectancy sizing reference
* Active veto status

---

## How to use it

### 1. Trade with the cloud

Long bias above the Kumo, short bias below, no-trade inside.

### 2. Focus on strength-graded signals

A high-strength signal that also has:

• Same-direction Break of Structure
• Higher-timeframe agreement
• Real volume confirmation

is the A+ setup.

Weak signals during chop regimes are generally the ones to skip.

### 3. Read the VERDICT / VETO rows

WEAK or VETO means stand aside (for example, a signal against structure, in chop, or on dead volume).

### 4. Use the RELIABILITY and KELLY rows

The **RELIABILITY** row shows how this symbol's signals at each strength tier have historically behaved.

The **KELLY** row suggests a risk percentage for journaling and trade review purposes.

The displayed size is a reference only and not an order recommendation.

### 5. Alerts

Alerts cover:

• Bullish cloud signals
• Bearish cloud signals
• Conviction verdict changes
• Kumo twists

---

## Settings (use on any asset / market)

### Raw data source

`close`, `hl2`, `hlc3`, `ohlc4`, or another indicator's plot.

The cloud's highs/lows always use chart high/low.

Works on any instrument.

### Periods

Classic (9/26/52/26) or Adaptive (dominant-cycle).

Displacement remains fixed.

### Structure

Swing pivot length and structure veto controls.

### Volume

RVOL length and minimum thresholds.

Optional low-volume veto.

### Calibration

Judging window and favourable ATR target defining a "good" signal.

Auto-learn cutoff and target win-rate settings.

### Advanced Controls

Regime, MTF, conviction weights, risk controls, Kelly fraction and maximum risk.

### Optional feeds (blank = off)

• Volatility-index symbol (spike veto)
• Cross-asset symbol (confluence)

Both are disabled by default, allowing fully self-contained operation on any market.

---

## Notes

• This is a **study / indicator**, not a strategy, and it places no orders.

• Signals are evaluated on bar close to avoid intrabar repainting.

• Structure uses confirmed pivots and higher-timeframe reads use confirmed values.

• The cloud and Chikou are displaced exactly as in classic Ichimoku.

• Relative-volume features require a symbol that reports volume (such as futures). On volume-less symbols they gracefully revert to neutral behaviour.

---

## Disclaimer

This script is provided for educational and informational purposes only. It is a technical-analysis study, not financial, investment, or trading advice, and not a recommendation or solicitation to buy or sell any instrument.

No indicator can predict markets; past behaviour and any historical statistics shown (including the signal win-rates and any Kelly-based sizing suggestion) do not guarantee future results.

Trading involves substantial risk of loss.

You are solely responsible for your own decisions — do your own research and consider consulting a licensed financial professional before trading.

The author accepts no liability for any loss arising from use of this script.

## Source Code

````pine
// =============================================================================
// Ichimoku Cloud — Strength-Graded, Calibrated & Multi-Timeframe   (ICHI ARC)
// -----------------------------------------------------------------------------
// The classic Ichimoku Kinko Hyo five-line system (Tenkan, Kijun, Senkou A/B
// cloud, Chikou) drawn faithfully — but every confirmation, the signal-strength
// score and the context come from a modern engine instead of the eye:
//   * ADAPTIVE PERIODS  — optionally derive 9/26/52 from the measured dominant
//     cycle so the cloud fits the instrument and timeframe, not 1930s daily rice.
//   * ONE STRENGTH SCORE — price-vs-cloud, Tenkan/Kijun, Chikou clearance, cloud
//     colour, the forward Kumo twist, Kijun slope, cloud thickness and higher-
//     timeframe agreement are fused into a single 0-100 grade per signal.
//   * CALIBRATION — every cloud-bias flip is checked a window later for whether
//     price actually ran a favourable target (in ATR); the script reports the
//     realised win-rate of past signals at each strength tier on THIS symbol and
//     can auto-learn the strength cutoff worth acting on.
//   * REGIME + MTF — a trend/range/volatile classifier and three higher-timeframe
//     clouds gate the signals, because Ichimoku breakouts fail in chop.
//   * CONVICTION + VETOES resolve everything to one LONG / SHORT / FLAT verdict.
//
// WHY THESE PIECES ARE COMBINED (mashup rationale): a raw Ichimoku throws six
// simultaneous signals with no synthesis and fixed periods that suit one market.
// Each layer here removes one of those weaknesses and feeds the next — adaptive
// periods fix the fit, the strength score fuses the six signals, calibration
// makes the score accountable, and regime/MTF keep it out of chop. None is
// decorative.
//
// Works on ANY symbol / timeframe / market. Raw data source and all optional
// feeds are user-selectable. Study/indicator only — not a strategy, not advice.
// =============================================================================

//@version=6
indicator("Ichimoku Cloud — Strength-Graded, Calibrated & Multi-Timeframe", shorttitle="ICHI ARC", overlay=true,
     max_lines_count=200, max_labels_count=200, precision=2)

// =============================================================================
// HELPERS  (UDFs use only their args + built-ins, never globals)
// =============================================================================
f_clamp(x, lo, hi) => math.max(lo, math.min(hi, x))
sgn(x)  => x >= 0 ? "+" : ""
f_pos(s) => s=="top_left"?position.top_left : s=="bottom_right"?position.bottom_right : s=="bottom_left"?position.bottom_left : position.top_right
f_fetch(sym) => request.security(sym, timeframe.period, close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

// Rolling highest/lowest over a SERIES length (for adaptive periods)
f_rollhl(hsrc, lsrc, len) =>
    int n = int(math.max(1, math.min(260, len)))
    float hh = hsrc
    float ll = lsrc
    for i = 1 to 259
        if i < n
            hh := math.max(hh, hsrc[i])
            ll := math.min(ll, lsrc[i])
    [hh, ll]

// Timeframe string that is a multiple of the chart timeframe
f_tfstr(simple int mult) =>
    secs = timeframe.in_seconds() * mult
    out = secs < 60    ? str.tostring(int(secs)) + "S"
       : secs < 86400  ? str.tostring(int(secs / 60))
       : secs < 604800 ? str.tostring(int(secs / 86400)) + "D"
       :                 str.tostring(int(secs / 604800)) + "W"
    out

// Higher-timeframe Ichimoku cloud bias: +1 above cloud / -1 below / 0 inside
f_ichibias(simple int tl, simple int kl, simple int bl, simple int dp) =>
    th = (ta.highest(high, tl) + ta.lowest(low, tl)) / 2.0
    kj = (ta.highest(high, kl) + ta.lowest(low, kl)) / 2.0
    sa = (th + kj) / 2.0
    sb = (ta.highest(high, bl) + ta.lowest(low, bl)) / 2.0
    ct = math.max(sa[dp], sb[dp])
    cb = math.min(sa[dp], sb[dp])
    close > ct ? 1 : close < cb ? -1 : 0

// =============================================================================
// INPUTS
// =============================================================================
gCore   = "Core · Ichimoku"
src_in  = input.source(close, "Raw data source", group=gCore, tooltip="Series used for price-vs-cloud, breakout and Chikou comparisons. close / hl2 / hlc3 / ohlc4 or another indicator's plot. The cloud's highs/lows always use chart high/low. Works on any symbol or market.")
perMode = input.string("Classic", "Periods", options=["Classic","Adaptive"], group=gCore, tooltip="Classic = fixed Tenkan/Kijun/Span-B below. Adaptive = derive them from the measured dominant cycle so the cloud fits this instrument/timeframe.")
tenLen0 = input.int(9,   "Tenkan (conversion) length", minval=1, maxval=200, group=gCore)
kijLen0 = input.int(26,  "Kijun (base) length", minval=1, maxval=400, group=gCore)
spbLen0 = input.int(52,  "Senkou Span B length", minval=1, maxval=520, group=gCore)
dispUse = input.int(26,  "Displacement (cloud / Chikou shift)", minval=1, maxval=200, group=gCore, tooltip="Forward shift of the cloud and backward shift of the Chikou span. Stays fixed even in Adaptive mode (plot offsets must be constant).")
adCycMl = input.float(1.0, "  Adaptive: Kijun = cycle ×", minval=0.4, maxval=2.0, step=0.05, group=gCore)

gReg    = "Regime"
adxLen  = input.int   (14,   "ADX / DMI length", minval=2, maxval=60, group=gReg)
adxTrd  = input.float (20.0, "ADX trend threshold", minval=5, maxval=50, group=gReg)
erLen   = input.int   (14,   "Efficiency-ratio length", minval=2, maxval=60, group=gReg)
erTrd   = input.float (0.35, "ER trend threshold", minval=0.05, maxval=0.95, step=0.01, group=gReg)
normLen = input.int   (100,  "Vol-cluster normalize length", minval=20, maxval=500, group=gReg)
clustDecay=input.float(0.20, "Vol-cluster decay", minval=0.02, maxval=0.9, step=0.01, group=gReg)
clustThr= input.float (1.5,  "Vol-cluster z threshold", minval=0.5, maxval=4.0, step=0.1, group=gReg)
useChopVeto=input.bool(true, "Veto fresh signals in Range/Volatile", group=gReg)

gMtf    = "Multi-timeframe cloud agreement"
useMtf  = input.bool  (true, "Enable MTF cloud agreement", group=gMtf)
htfM1   = input.int   (3,    "HTF multiple 1", minval=2, maxval=60, group=gMtf)
htfM2   = input.int   (6,    "HTF multiple 2", minval=2, maxval=120, group=gMtf)
htfM3   = input.int   (12,   "HTF multiple 3", minval=2, maxval=240, group=gMtf)
useHtfGate=input.bool (true, "Veto signals all HTFs oppose", group=gMtf)

gCal    = "Calibration · signal reliability"
evalK   = input.int   (24,   "Bars to judge a signal", minval=2, maxval=300, group=gCal, tooltip="Window after a cloud-bias flip over which it is judged. A signal is 'good' if price ran the favourable target (below) in its direction within this window.")
favATR  = input.float (1.0,  "Favourable move to count a signal good (ATR)", minval=0.1, maxval=5.0, step=0.1, group=gCal)
atrLen  = input.int   (14,   "ATR length (calibration / size / thickness)", minval=1, maxval=100, group=gCal)

gData   = "Optional feeds (blank = off)"
vixSym  = input.symbol("",   "Volatility-index symbol", group=gData, tooltip="Optional. Your market's volatility index for a spike veto. Blank or invalid = ignored.")
vixLen  = input.int   (20,   "  Vol-index z length", minval=5, maxval=200, group=gData)
vixSpk  = input.float (1.5,  "  Vol-index spike z", minval=0.5, maxval=4.0, step=0.1, group=gData)
xaSym   = input.string("",   "Cross-asset symbol", group=gData)
xaSign  = input.int   (1,    "  Cross-asset sign (+1 / -1)", minval=-1, maxval=1, group=gData)
xaLen   = input.int   (10,   "  Cross-asset momentum length", minval=2, maxval=100, group=gData)

gStruct = "Structure (BOS / CHoCH)"
useStruct = input.bool(true, "Use market-structure confirmation", group=gStruct, tooltip="Confirms cloud signals against swing structure: a same-direction Break of Structure is high quality; a signal against the last Change of Character is downgraded or vetoed. Pure price geometry — fully non-repainting on confirmed pivots.")
pvLen     = input.int (8,    "Swing pivot length", minval=2, maxval=50, group=gStruct)
useStructVeto = input.bool(true, "Veto signals against structure", group=gStruct)
showStruct= input.bool(true, "Mark CHoCH (structure flips)", group=gStruct)

gVol    = "Volume confirmation"
useRvol = input.bool(true, "Use relative-volume confirmation", group=gVol, tooltip="Real breakouts carry volume. RVOL = volume / its own average; boosts strength when high, can veto dead-volume breakouts. Needs a symbol with volume (e.g. futures).")
rvolLen = input.int(20,   "RVOL average length", minval=2, maxval=200, group=gVol)
rvolMin = input.float(0.8,"Min RVOL for a clean breakout", minval=0.1, maxval=5.0, step=0.1, group=gVol)
useRvolVeto = input.bool(false, "Veto low-RVOL breakouts", group=gVol)

gCon    = "Conviction & vetoes"
wTK     = input.float (18,   "Weight: Tenkan/Kijun", group=gCon)
wCh     = input.float (18,   "Weight: Chikou clearance", group=gCon)
wCol    = input.float (14,   "Weight: cloud colour (now)", group=gCon)
wFut    = input.float (14,   "Weight: future cloud / twist", group=gCon)
wKj     = input.float (12,   "Weight: Kijun slope", group=gCon)
wMtfW   = input.float (14,   "Weight: MTF agreement", group=gCon)
wThk    = input.float (10,   "Weight: cloud thickness", group=gCon)
wStruc  = input.float (16,   "Weight: market structure", group=gCon)
wRvl    = input.float (10,   "Weight: relative volume", group=gCon)
minConv = input.int   (45,   "Min conviction to act", minval=0, maxval=100, group=gCon)
minStr  = input.int   (0,    "Min signal strength to act", minval=0, maxval=100, group=gCon)
useAutoStr=input.bool (false,"Auto-learn strength cutoff", group=gCon, tooltip="Use the lowest strength whose past signals met the target win-rate as the gate.")
autoTarget=input.float(60,   "  Target win-rate %", minval=40, maxval=95, group=gCon)
autoMinN  =input.int  (20,   "  Min signals before trusting cutoff", minval=5, maxval=300, group=gCon)

gRisk   = "Risk context (dashboard only)"
equity  = input.float (100000, "Account equity", minval=0, group=gRisk)
riskPct = input.float (1.0,  "Risk per trade %", minval=0.0, maxval=100, step=0.1, group=gRisk)
ptValue = input.float (1.0,  "Point value / unit", minval=0.0, group=gRisk)
stopMode= input.string("Kijun", "Stop reference", options=["Kijun","Cloud","ATR"], group=gRisk)
kellyFr = input.float (0.5,  "Kelly fraction (safety)", minval=0.1, maxval=1.0, step=0.05, group=gRisk, tooltip="Fraction of full Kelly to suggest (0.5 = half-Kelly). Suggested risk is capped below.")
maxRisk = input.float (3.0,  "Max suggested risk %", minval=0.1, maxval=10.0, step=0.1, group=gRisk)

gVis    = "VIS · Display"
showLines=input.bool  (true, "Tenkan / Kijun lines", group=gVis)
showChik= input.bool  (true, "Chikou span", group=gVis)
showCloud=input.bool  (true, "Kumo cloud", group=gVis)
thickFade=input.bool  (true, "Cloud opacity by thickness", group=gVis)
showTwist=input.bool  (true, "Mark Kumo twists", group=gVis)
showSig = input.bool  (true, "Signal markers", group=gVis)
showStr = input.bool  (true, "Strength labels on signals", group=gVis)
showReg = input.bool  (false,"Faint regime background", group=gVis)
showTbl = input.bool  (true, "Dashboard", group=gVis)
compactTbl=input.bool (true, "  Compact dashboard", group=gVis)
tblTheme= input.string("Auto","Dashboard theme", options=["Auto","Dark","Light"], group=gVis)
tblPos  = input.string("top_right","Dashboard position", options=["top_right","top_left","bottom_right","bottom_left"], group=gVis)
showId  = input.bool  (true, "Identity label", group=gVis)
confirmClose=input.bool(true,"Evaluate signals on bar close (non-repaint)", group=gVis)
ltfRes  = input.timeframe("1","Volume-delta lower timeframe", group=gVis)

// =============================================================================
// DOMINANT CYCLE (homodyne discriminator)
// =============================================================================
hl2src = (high + low) / 2.0
var float Period = 20.0
Smooth = (4*hl2src + 3*hl2src[1] + 2*hl2src[2] + hl2src[3]) / 10.0
adjc = (0.075*Period + 0.54)
Detr = (0.0962*Smooth + 0.5769*nz(Smooth[2]) - 0.5769*nz(Smooth[4]) - 0.0962*nz(Smooth[6])) * adjc
Q1   = (0.0962*Detr + 0.5769*nz(Detr[2]) - 0.5769*nz(Detr[4]) - 0.0962*nz(Detr[6])) * adjc
I1   = nz(Detr[3])
jI   = (0.0962*I1 + 0.5769*nz(I1[2]) - 0.5769*nz(I1[4]) - 0.0962*nz(I1[6])) * adjc
jQ   = (0.0962*Q1 + 0.5769*nz(Q1[2]) - 0.5769*nz(Q1[4]) - 0.0962*nz(Q1[6])) * adjc
var float I2 = 0.0
var float Q2 = 0.0
I2 := 0.2*(I1 - jQ) + 0.8*nz(I2[1])
Q2 := 0.2*(Q1 + jI) + 0.8*nz(Q2[1])
var float Re = 0.0
var float Im = 0.0
Re := 0.2*(I2*nz(I2[1]) + Q2*nz(Q2[1])) + 0.8*nz(Re[1])
Im := 0.2*(I2*nz(Q2[1]) - Q2*nz(I2[1])) + 0.8*nz(Im[1])
float pNew = Period
if Im != 0 and Re != 0
    pNew := 2.0 * math.pi / math.abs(math.atan(Im / Re))
pNew := f_clamp(pNew, 0.67*Period, 1.5*Period)
pNew := f_clamp(pNew, 8.0, 60.0)
Period := 0.2*pNew + 0.8*Period
domCycle = Period
cycRising = Detr >= nz(Detr[1], Detr)

// =============================================================================
// REGIME (efficiency ratio + ADX + volatility cluster)
// =============================================================================
[diP, diM, adx] = ta.dmi(adxLen, adxLen)
logRet = math.abs(nz(ta.change(math.log(close))))
var float clustI = 0.0
clustI := clustI * math.exp(-clustDecay) + logRet
hMeanH = ta.sma(clustI, normLen)
hStdH  = ta.stdev(clustI, normLen)
clustZ = hStdH == 0 ? 0.0 : (clustI - hMeanH) / hStdH
volCluster = clustZ > clustThr
erChg = math.abs(src_in - src_in[erLen])
erVol = math.sum(math.abs(src_in - src_in[1]), erLen)
er = erVol == 0 ? 0.0 : erChg / erVol
trending = adx > adxTrd and er > erTrd
regimePct = math.round(f_clamp((adx/40.0)*50 + er*50, 0, 100))
string regime = volCluster and not trending ? "Volatile" : trending ? "Trend" : "Range"
isRange = regime == "Range"
isVol   = regime == "Volatile"
isTrend = trending

// =============================================================================
// FEEDS — volume delta + optional volatility index + cross-asset
// =============================================================================
atr0 = ta.atr(atrLen)
volNz = nz(volume, 0.0)
volLive = ta.cum(volNz) > 0
ltfArr = request.security_lower_tf(syminfo.tickerid, ltfRes, (close >= open ? 1.0 : -1.0) * volNz)
barDelta = array.size(ltfArr) > 0 ? array.sum(ltfArr) : (close >= open ? 1.0 : -1.0) * volNz
cvd = ta.cum(barDelta)
cvdSign = math.sign(cvd - nz(cvd[5], cvd))

vix = f_fetch(vixSym)
vixLive = not na(vix)
vixMean = ta.sma(vix, vixLen)
vixSD   = ta.stdev(vix, vixLen)
vixZ = (vixLive and vixSD > 0) ? (vix - vixMean) / vixSD : 0.0
vixSpike = vixLive and vixZ >= vixSpk
xaSymUse = str.length(xaSym) > 0 ? xaSym : syminfo.tickerid
xaRaw = request.security(xaSymUse, timeframe.period, close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
xa = str.length(xaSym) > 0 ? xaRaw : na
xaLive = not na(xa)
xaMom = xaLive ? math.sign(xa - nz(xa[xaLen], xa)) * xaSign : 0

// =============================================================================
// ICHIMOKU CORE (Classic or Adaptive periods)
// =============================================================================
kijA = int(f_clamp(math.round(domCycle * adCycMl), 5, 130))
tenA = int(f_clamp(math.round(kijA / 3.0), 2, 60))
spbA = int(f_clamp(math.round(kijA * 2.0), 10, 260))
adaptive = perMode == "Adaptive"
lenTen = adaptive ? tenA : tenLen0
lenKij = adaptive ? kijA : kijLen0
lenSpb = adaptive ? spbA : spbLen0

[hhT, llT] = f_rollhl(high, low, lenTen)
[hhK, llK] = f_rollhl(high, low, lenKij)
[hhB, llB] = f_rollhl(high, low, lenSpb)
tenkan = (hhT + llT) / 2.0
kijun  = (hhK + llK) / 2.0
spanA  = (tenkan + kijun) / 2.0
spanB  = (hhB + llB) / 2.0

// current (displaced) cloud at this bar = spans from dispUse bars ago
cloudTop = math.max(spanA[dispUse], spanB[dispUse])
cloudBot = math.min(spanA[dispUse], spanB[dispUse])
priceC   = src_in
aboveCloud = priceC > cloudTop
belowCloud = priceC < cloudBot
inCloud    = not aboveCloud and not belowCloud
biasDir = aboveCloud ? 1 : belowCloud ? -1 : 0

tkBull   = tenkan > kijun
chikBull = priceC > nz(priceC[dispUse], priceC)
cloudGreenNow = spanA[dispUse] >= spanB[dispUse]
futGreen = spanA >= spanB
kijunSlope = kijun > kijun[1] ? 1 : kijun < kijun[1] ? -1 : 0
thick = math.abs(spanA[dispUse] - spanB[dispUse]) / (atr0 == 0 ? 1 : atr0)
twistUp = ta.crossover(spanA, spanB)
twistDn = ta.crossunder(spanA, spanB)

// =============================================================================
// STRUCTURE — swing pivots, BOS / CHoCH  (confirmation layer, not a new core)
// =============================================================================
ph = ta.pivothigh(pvLen, pvLen)
pl = ta.pivotlow(pvLen, pvLen)
var float lastPH = na
var float lastPL = na
var bool  phTaken = false
var bool  plTaken = false
if not na(ph)
    lastPH := ph
    phTaken := false
if not na(pl)
    lastPL := pl
    plTaken := false
var int mstruct = 0
bool bosUp = false
bool chochUp = false
bool bosDn = false
bool chochDn = false
if not na(lastPH) and not phTaken and close > lastPH
    phTaken := true
    if mstruct < 0
        chochUp := true
    else
        bosUp := true
    mstruct := 1
if not na(lastPL) and not plTaken and close < lastPL
    plTaken := true
    if mstruct > 0
        chochDn := true
    else
        bosDn := true
    mstruct := -1
var string lastStructTxt = "—"
if chochUp
    lastStructTxt := "CHoCH up"
else if bosUp
    lastStructTxt := "BOS up"
else if chochDn
    lastStructTxt := "CHoCH dn"
else if bosDn
    lastStructTxt := "BOS dn"

// RELATIVE VOLUME
rvolAvg = ta.sma(volNz, rvolLen)
rvol = (volLive and rvolAvg > 0) ? volNz / rvolAvg : na

// =============================================================================
// MTF — higher-timeframe cloud agreement (non-repaint via [1])
// =============================================================================
hd1 = useMtf ? nz(request.security(syminfo.tickerid, f_tfstr(htfM1), f_ichibias(tenLen0,kijLen0,spbLen0,dispUse)[1], lookahead=barmerge.lookahead_off), 0) : 0
hd2 = useMtf ? nz(request.security(syminfo.tickerid, f_tfstr(htfM2), f_ichibias(tenLen0,kijLen0,spbLen0,dispUse)[1], lookahead=barmerge.lookahead_off), 0) : 0
hd3 = useMtf ? nz(request.security(syminfo.tickerid, f_tfstr(htfM3), f_ichibias(tenLen0,kijLen0,spbLen0,dispUse)[1], lookahead=barmerge.lookahead_off), 0) : 0
mtfBull = (hd1>0?1:0)+(hd2>0?1:0)+(hd3>0?1:0)
mtfBear = (hd1<0?1:0)+(hd2<0?1:0)+(hd3<0?1:0)
mtfAllOppose = biasDir>0 ? (mtfBear==3) : biasDir<0 ? (mtfBull==3) : false

// =============================================================================
// STRENGTH — how many confirmations align with the cloud bias (0-100)
// =============================================================================
aTK  = (tkBull?1:-1) == biasDir ? 1.0 : 0.0
aCh  = (chikBull?1:-1) == biasDir ? 1.0 : 0.0
aCol = (cloudGreenNow?1:-1) == biasDir ? 1.0 : 0.0
aFut = (futGreen?1:-1) == biasDir ? 1.0 : 0.0
aKj  = kijunSlope == biasDir ? 1.0 : 0.0
aMtf = biasDir==0 or not useMtf ? 0.5 : (biasDir>0 ? mtfBull/3.0 : mtfBear/3.0)
aThk = f_clamp(thick/2.0, 0, 1)
aStr = not useStruct or biasDir==0 ? 0.5 : (mstruct==biasDir ? 1.0 : 0.0)
aRvl = not useRvol or na(rvol) ? 0.5 : f_clamp((rvol - rvolMin) / 1.5, 0, 1)
wSum = wTK+wCh+wCol+wFut+wKj+wMtfW+wThk + wStruc + wRvl
rawStr = wTK*aTK + wCh*aCh + wCol*aCol + wFut*aFut + wKj*aKj + wMtfW*aMtf + wThk*aThk + wStruc*aStr + wRvl*aRvl
strengthNow = biasDir==0 ? 0 : math.round(f_clamp(wSum>0 ? rawStr/wSum*100.0 : 0, 0, 100))

barOk = confirmClose ? barstate.isconfirmed : true
longSig  = biasDir==1  and biasDir[1]<=0 and barOk
shortSig = biasDir==-1 and biasDir[1]>=0 and barOk
freshSig = longSig or shortSig
sigStr = (longSig or shortSig) ? strengthNow : na
var float lastSigStr = na
if longSig or shortSig
    lastSigStr := strengthNow

// =============================================================================
// CALIBRATION — judge each signal by favourable follow-through (MFE >= target)
// =============================================================================
hh_e = ta.highest(high, evalK)
ll_e = ta.lowest(low,  evalK)
sigAgo  = (longSig[evalK] or shortSig[evalK])
dThen   = biasDir[evalK]
atrF    = nz(atr0[evalK], 0.0)
mfeAgo  = dThen > 0 ? hh_e - close[evalK] : close[evalK] - ll_e
goodAgo = atrF > 0 and mfeAgo >= favATR * atrF
var int   sigEval = 0
var int   sigWon  = 0
var float favSum  = 0.0
var int[] bkEval  = array.new_int(3, 0)
var int[] bkWon   = array.new_int(3, 0)
var int[] binEval = array.new_int(20, 0)
var int[] binWon  = array.new_int(20, 0)
if barstate.isconfirmed and bar_index > evalK + 5 and sigAgo
    sigEval += 1
    if goodAgo
        sigWon += 1
    favSum += atrF > 0 ? mfeAgo / atrF : 0.0
    sv = nz(sigStr[evalK], 50.0)
    bk = sv>=70 ? 2 : sv>=40 ? 1 : 0
    array.set(bkEval, bk, array.get(bkEval, bk) + 1)
    if goodAgo
        array.set(bkWon, bk, array.get(bkWon, bk) + 1)
    bn = int(f_clamp(math.floor(sv / 5.0), 0, 19))
    array.set(binEval, bn, array.get(binEval, bn) + 1)
    if goodAgo
        array.set(binWon, bn, array.get(binWon, bn) + 1)
winRate = sigEval > 0 ? sigWon / sigEval * 100.0 : na
avgFav  = sigEval > 0 ? favSum / sigEval : na
lastBk     = na(lastSigStr) ? 1 : (lastSigStr>=70 ? 2 : lastSigStr>=40 ? 1 : 0)
lastBkEval = array.get(bkEval, lastBk)
lastBkRate = lastBkEval > 0 ? array.get(bkWon, lastBk) / lastBkEval * 100.0 : na

// auto-learn cutoff: lowest threshold whose signals >= it won >= target
int totSig = 0
for j = 0 to 19
    totSig += array.get(binEval, j)
var float autoCut = na
if useAutoStr and totSig >= autoMinN
    int cumE = 0
    int cumW = 0
    float cut = na
    bool stop = false
    for j = 19 to 0
        if not stop
            cumE += array.get(binEval, j)
            cumW += array.get(binWon, j)
            rateC = cumE > 0 ? cumW / cumE * 100.0 : 0.0
            if cumE >= 5 and rateC >= autoTarget
                cut := j * 5.0
            else if cumE >= 5 and rateC < autoTarget and not na(cut)
                stop := true
    autoCut := cut
minStrUse = useAutoStr and not na(autoCut) ? autoCut : minStr

// =============================================================================
// CONVICTION + VETOES
// =============================================================================
sReg = isTrend ? 1.0 : isRange ? 0.45 : 0.3
sMtf = useMtf ? (biasDir>0 ? mtfBull/3.0 : biasDir<0 ? mtfBear/3.0 : 0.0) : 0.5
sCvd = cvdSign==biasDir and biasDir!=0 ? 1.0 : 0.4
sXa  = xaLive ? (xaMom==biasDir and biasDir!=0 ? 1.0 : 0.4) : 0.5
conv = biasDir==0 ? 0 : math.round(f_clamp((strengthNow*0.6 + (sReg*100)*0.18 + (sMtf*100)*0.14 + (sCvd*100)*0.05 + (sXa*100)*0.03), 0, 100))
tier = conv>=75?"S" : conv>=60?"A" : conv>=45?"B" : "-"

vVix  = vixSpike and freshSig
vMtf  = useHtfGate and freshSig and mtfAllOppose
vChop = useChopVeto and freshSig and (isRange or isVol)
vIn   = freshSig and biasDir==0
vXa   = xaLive and freshSig and xaMom!=0 and xaMom!=biasDir
vStr  = useStruct and useStructVeto and freshSig and mstruct!=0 and mstruct!=biasDir
vRvl2 = useRvol and useRvolVeto and freshSig and not na(rvol) and rvol < rvolMin
vetoes = vVix or vMtf or vChop or vIn or vXa or vStr or vRvl2
vetoTxt = vVix?"vol spike" : vMtf?"HTF oppose" : vChop?"chop regime" : vStr?"vs structure" : vRvl2?"low volume" : vXa?"cross-asset" : "none"

act = freshSig and conv>=minConv and strengthNow>=minStrUse and not vetoes
longTrig  = act and biasDir>0
shortTrig = act and biasDir<0
verdict = freshSig and vetoes ? "VETO" : freshSig and (conv<minConv or strengthNow<minStrUse) ? "WEAK" : longSig ? "LONG" : shortSig ? "SHORT" : biasDir>0 ? "HOLD L" : biasDir<0 ? "HOLD S" : "FLAT"

// =============================================================================
// RISK CONTEXT
// =============================================================================
stopPx = stopMode=="Kijun" ? kijun : stopMode=="Cloud" ? (biasDir>0 ? cloudBot : cloudTop) : (biasDir>0 ? close - 2*atr0 : close + 2*atr0)
stopDist = math.abs(close - stopPx)
riskCap = equity * riskPct / 100.0
perUnit = stopDist * ptValue
qty = perUnit > 0 ? math.floor(riskCap / perUnit) : 0
// Kelly / expectancy from the calibrated win-rate (turns the stat into sizing)
pWin = na(winRate) ? na : winRate/100.0
riskATR = atr0 > 0 ? stopDist/atr0 : 1.0
bOdds = riskATR > 0 ? favATR / riskATR : favATR
kellyF = na(pWin) ? na : f_clamp(pWin - (1.0-pWin)/(bOdds==0?1:bOdds), 0, 1)
kRiskPct = na(kellyF) ? na : f_clamp(kellyF * kellyFr * 100.0, 0, maxRisk)
expR = na(pWin) ? na : pWin*bOdds - (1.0-pWin)

// =============================================================================
// ALERTS
// =============================================================================
alertcondition(longSig,  "Bullish cloud signal", "ICHI ARC: bullish cloud-bias signal")
alertcondition(shortSig, "Bearish cloud signal", "ICHI ARC: bearish cloud-bias signal")
alertcondition(longTrig, "LONG (conviction)",    "ICHI ARC: LONG verdict")
alertcondition(shortTrig,"SHORT (conviction)",   "ICHI ARC: SHORT verdict")
alertcondition(twistUp,  "Kumo twist up",        "ICHI ARC: future cloud turned bullish")
alertcondition(twistDn,  "Kumo twist down",      "ICHI ARC: future cloud turned bearish")

// =============================================================================
// VIS — Ichimoku
// =============================================================================
cBullL = color.new(#2dd4bf, 0)
cBearL = color.new(#ff6b6b, 0)
plot(showLines ? tenkan : na, "Tenkan", color=color.new(#3aa0ff, 0), linewidth=1)
plot(showLines ? kijun  : na, "Kijun",  color=color.new(#ffb43a, 0), linewidth=2)
plot(showChik  ? priceC : na, "Chikou", color=color.new(#b07cff, 0), offset=-dispUse, linewidth=1)

cloudTransp = thickFade ? int(f_clamp(86 - f_clamp(thick,0,3)/3.0*46, 40, 86)) : 72
spAcol = futGreen ? color.new(#14b88a, 0) : color.new(#ff5252, 0)
pA = plot(showCloud ? spanA : na, "Senkou A", color=color.new(spAcol, 40), offset=dispUse, linewidth=1)
pB = plot(showCloud ? spanB : na, "Senkou B", color=color.new(futGreen?#14b88a:#ff5252, 40), offset=dispUse, linewidth=1)
fill(pA, pB, color = showCloud ? color.new(futGreen?#14b88a:#ff5252, cloudTransp) : na)

plotshape(showTwist and twistUp ? spanA : na, "Twist up",   shape.circle, location.absolute, color.new(#14b88a,0), offset=dispUse, size=size.tiny)
plotshape(showTwist and twistDn ? spanA : na, "Twist down", shape.circle, location.absolute, color.new(#ff5252,0), offset=dispUse, size=size.tiny)
plotshape(showStruct and chochUp ? low  : na, "CHoCH up", shape.diamond, location.belowbar, color.new(#3aa0ff,0), size=size.tiny)
plotshape(showStruct and chochDn ? high : na, "CHoCH dn", shape.diamond, location.abovebar, color.new(#b07cff,0), size=size.tiny)

mkUp = strengthNow>=70 ? cBullL : strengthNow>=40 ? color.new(#2dd4bf,25) : color.new(#2dd4bf,55)
mkDn = strengthNow>=70 ? cBearL : strengthNow>=40 ? color.new(#ff6b6b,25) : color.new(#ff6b6b,55)
plotshape(showSig and longSig  ? low  : na, "Long signal",  shape.triangleup,   location.belowbar, mkUp, size=size.small)
plotshape(showSig and shortSig ? high : na, "Short signal", shape.triangledown, location.abovebar, mkDn, size=size.small)
strG = strengthNow>=70 ? " S" : strengthNow>=40 ? " M" : " w"
if showStr and longSig
    label.new(bar_index, low,  str.tostring(strengthNow)+strG, yloc=yloc.belowbar, style=label.style_label_up,   color=color.new(mkUp,12), textcolor=color.white, size=size.small)
if showStr and shortSig
    label.new(bar_index, high, str.tostring(strengthNow)+strG, yloc=yloc.abovebar, style=label.style_label_down, color=color.new(mkDn,12), textcolor=color.white, size=size.small)

bgcolor(showReg and isTrend ? (biasDir>0?color.new(#14b88a,94):color.new(#ff5252,94)) : showReg and isVol ? color.new(color.orange,94) : na)

// =============================================================================
// VIS — DASHBOARD
// =============================================================================
var table dash = table.new(f_pos(tblPos), 2, 24, frame_width=1, border_width=1)
setrow(tbl, r, lbl, val, vc, lc, bg) =>
    table.cell(tbl, 0, r, lbl, text_color=lc, text_size=size.tiny,  text_halign=text.align_left,  bgcolor=bg)
    table.cell(tbl, 1, r, val, text_color=vc, text_size=size.small, text_halign=text.align_right, bgcolor=bg)

if showTbl and barstate.islast
    tIsDark = tblTheme=="Dark" ? true : tblTheme=="Light" ? false : color.r(chart.bg_color) < 128
    tBg   = tIsDark ? color.new(#0b0f17, 6) : color.new(#ffffff, 4)
    tBord = tIsDark ? color.new(#3a4250, 0) : color.new(#c2c8d0, 0)
    tLbl  = tIsDark ? #9aa3b2 : #515a67
    tVal  = tIsDark ? #f2f4f8 : #10151d
    cBull = tIsDark ? #2dd4bf : #0e9e76
    cBear = tIsDark ? #ff6b6b : #d32f2f
    cWarn = tIsDark ? #ffa94d : #b56a00
    cMute = tIsDark ? #6b7480 : #98a0ab
    table.set_frame_color(dash, tBord)
    table.set_border_color(dash, tBord)
    biasCol = biasDir>0?cBull : biasDir<0?cBear : cMute
    verdCol = verdict=="LONG"?cBull : verdict=="SHORT"?cBear : verdict=="VETO" or verdict=="WEAK"?cWarn : biasDir>0?cBull:biasDir<0?cBear:cMute
    regCol  = regime=="Trend"?(biasDir>0?cBull:cBear) : regime=="Volatile"?cWarn : cMute
    actCol  = longTrig?color.new(cBull,0) : shortTrig?color.new(cBear,0) : freshSig and vetoes?color.new(cWarn,0) : color.new(#5b6472,0)
    actShort= longTrig?"BUY" : shortTrig?"SELL" : freshSig and vetoes?"WAIT" : biasDir>0?"LONG":biasDir<0?"SHORT":"FLAT"
    posTxt  = aboveCloud?"above cloud" : belowCloud?"below cloud" : "in cloud"
    perTxt  = (adaptive?"adapt ":"")+str.tostring(lenTen)+"/"+str.tostring(lenKij)+"/"+str.tostring(lenSpb)
    strGrade= na(lastSigStr) ? "" : (lastSigStr>=70?"strong":lastSigStr>=40?"med":"weak")
    relTxt  = na(winRate)?"learning…":(str.tostring(sigWon)+"/"+str.tostring(sigEval)+" won "+str.tostring(math.round(winRate))+"% · "+str.tostring(avgFav,"0.0")+"R")
    mtfTxt  = useMtf?(str.tostring(mtfBull)+" up / "+str.tostring(mtfBear)+" dn of 3"):"off"
    chikTxt = chikBull?"above px":"below px"
    twTxt   = futGreen?"bull ahead":"bear ahead"
    sigTxt  = na(lastSigStr) ? (biasDir>0?"long bias":biasDir<0?"short bias":"none") : ("str "+str.tostring(int(lastSigStr))+" "+strGrade+(na(lastBkRate)?"":(" "+str.tostring(math.round(lastBkRate))+"%")))
    cutTxt  = useAutoStr ? (na(autoCut)?"cut learning":("cut >="+str.tostring(int(autoCut)))) : "manual"
    structTxt = useStruct ? ((mstruct>0?"bull":mstruct<0?"bear":"flat")+" · "+lastStructTxt) : "off"
    structCol = mstruct>0?cBull : mstruct<0?cBear : cMute
    rvolTxt = na(rvol) ? "n/a" : (str.tostring(rvol,"0.0")+"x"+(rvol>=rvolMin?"":" low"))
    rvolCol = na(rvol)?cMute : (rvol>=rvolMin?cBull:cWarn)
    kellyTxt = na(kRiskPct) ? "learning…" : (str.tostring(kRiskPct,"0.0")+"% risk · exp "+sgn(expR)+str.tostring(expR,"0.0")+"R")
    kellyCol = na(expR)?cMute : (expR>0?cBull:cBear)
    table.cell(dash, 0, 0, " > "+actShort+" ", text_color=color.white, text_size=size.small, text_halign=text.align_left,  bgcolor=actCol)
    table.cell(dash, 1, 0, (freshSig?"signal":"hold")+" · conv "+str.tostring(conv)+" "+tier+" ", text_color=color.white, text_size=size.small, text_halign=text.align_right, bgcolor=actCol)
    rr = 0
    rr += 1
    setrow(dash, rr, "VERDICT",  verdict+" · "+str.tostring(conv)+" ("+tier+")", verdCol, tLbl, tBg)
    rr += 1
    setrow(dash, rr, "REGIME",   regime+" "+str.tostring(regimePct)+"%", regCol, tLbl, tBg)
    rr += 1
    setrow(dash, rr, "PRICE",    posTxt, biasCol, tLbl, tBg)
    rr += 1
    setrow(dash, rr, "STRUCTURE", structTxt, structCol, tLbl, tBg)
    rr += 1
    setrow(dash, rr, "SIGNAL",   sigTxt, na(lastSigStr)?biasCol:(lastSigStr>=70?cBull:lastSigStr>=40?cWarn:cMute), tLbl, tBg)
    rr += 1
    setrow(dash, rr, "TENKAN/KIJUN", tkBull?"bull":"bear", tkBull?cBull:cBear, tLbl, tBg)
    rr += 1
    setrow(dash, rr, "CHIKOU",   chikTxt, chikBull?cBull:cBear, tLbl, tBg)
    if not compactTbl
        rr += 1
        setrow(dash, rr, "PERIODS",  perTxt, tVal, tLbl, tBg)
        rr += 1
        setrow(dash, rr, "CLOUD", (cloudGreenNow?"green":"red")+" · "+str.tostring(thick,"0.0")+" ATR", cloudGreenNow?cBull:cBear, tLbl, tBg)
        rr += 1
        setrow(dash, rr, "TWIST", twTxt, futGreen?cBull:cBear, tLbl, tBg)
        rr += 1
        setrow(dash, rr, "RVOL", rvolTxt, rvolCol, tLbl, tBg)
    rr += 1
    setrow(dash, rr, "MTF", mtfTxt, ((biasDir>0 and mtfBull>=2) or (biasDir<0 and mtfBear>=2))?cBull:cMute, tLbl, tBg)
    rr += 1
    setrow(dash, rr, "RELIABILITY", relTxt, na(winRate)?cMute:(winRate>=55?cBull:cWarn), tLbl, tBg)
    rr += 1
    setrow(dash, rr, "KELLY", kellyTxt, kellyCol, tLbl, tBg)
    if not compactTbl
        rr += 1
        setrow(dash, rr, "CUTOFF", cutTxt, useAutoStr?(na(autoCut)?cMute:cBull):cMute, tLbl, tBg)
        rr += 1
        setrow(dash, rr, "CYCLE", "cyc "+str.tostring(math.round(domCycle))+(cycRising?" ^":" v"), tVal, tLbl, tBg)
    rr += 1
    setrow(dash, rr, "SIZE", str.tostring(qty)+" units ("+str.tostring(riskPct,"0.0")+"%)", tVal, tLbl, tBg)
    rr += 1
    setrow(dash, rr, "VETO", vetoTxt, vetoTxt=="none"?cMute:cWarn, tLbl, tBg)

// =============================================================================
// IDENTITY
// =============================================================================
var table idTbl = table.new(position.bottom_center, 1, 1)
if showId and barstate.islast
    table.cell(idTbl, 0, 0, "ICHI ARC · Ichimoku Cloud   ·   " + syminfo.ticker + "  " + timeframe.period, text_color=color.new(#8a929e, 20), text_size=size.small, text_halign=text.align_center, bgcolor=color.new(color.gray, 100))
````

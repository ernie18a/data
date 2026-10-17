# Cyclic RSI  Adaptive Length & Dynamic Bands

- url: https://www.tradingview.com/script/hXY0paTq-Cyclic-RSI-Adaptive-Length-Dynamic-Bands/
- type: indicator
- pine_id: PUB;2fedf2bae6b34765a42b7e2bc2a08dd1
- version: 2.0

## Description

Overview

A fixed RSI length of 14 is an arbitrary choice — it fits some markets and fights others. Cyclic RSI measures the market's dominant cycle directly from the data and sets the RSI length to half of it, so the read auto-tunes across symbols and timeframes. On top of that it does two more things a plain RSI can't: it draws overbought/oversold bands that adapt to the recent distribution instead of an assumed 70/30, and it applies a cycle-strength gate — because a cyclic oscillator's turns only mean something when a real cycle is actually present. When the spectrum is flat, the pane greys out and the reversal reads are suppressed. It is a momentum/timing tool, not a signal to trade alone.

Why these components are ONE tool (mashup justification)

Each stage exists to fix a specific weakness in the stage before it:


Dominant-cycle measurement. A roofing filter (a high-pass to strip trend plus a smoother to strip noise) isolates the cycle band, and an autocorrelation periodogram over a range of lags produces a power spectrum. Its centre of mass is the dominant cycle; how sharply it peaks is a confidence reading. This is the measurement most cycle work considers more robust than phase-based methods.
Adaptive length. The RSI length is set to half the measured cycle (clamped). This is the whole point — it removes the overfit of a fixed lookback. Because Pine's built-in RSI needs a constant length, the RSI here is summed by hand over the varying half-cycle.
Cyclic smoothing. An optional phasing filter reduces lag so turns are timelier, then a SuperSmoother cleans the line.
Adaptive bands. Overbought and oversold are percentiles of the oscillator's own recent distribution, so the thresholds fit the instrument and regime instead of an assumed 70/30.
Cycle gate + calibration harness. Turns fire only when cycle confidence clears the gate, and a forward harness measures whether those gated turns actually led a move versus the base rate. The cycle read is the picture; the gate says when to trust it; the harness is the proof. Remove any one and you're back to a fixed-length RSI firing overbought/oversold turns in a trend, where they fail most.


How it works

The roofing filter isolates the cycle band. Autocorrelation across lags, projected onto a small set of frequencies, yields a per-period power spectrum smoothed across bars; its centre of mass (over the significant peaks) is the dominant cycle, and its concentration — one sharp peak versus a flat spread — is the confidence. RSI length = half that cycle. The RSI is summed directly over that length, optionally phase-smoothed, then smoothed again. The overbought/oversold bands are recent percentiles of the smoothed oscillator, and a turn off a band is only flagged when confidence clears the gate.

How to use it

Read the oscillator against its adaptive bands, not fixed lines. A turn up off the lower band is a potential reversion long; a turn down off the upper band a potential short — but only trust them when the pane is not greyed (a cycle is present). When the gate is closed, the market is trending or has no clear cycle, and mean-reversion reads are unreliable — that's the tool telling you to stand down, which is exactly when a naive RSI would keep firing losing signals. Gated turns are marked in the pane and, optionally, mirrored on the price chart (up/down triangles) so you can read them without leaving the price. Watch the Edge row: it reports whether gated turns have actually led moves on this instrument. It is never a standalone trigger.

Universal & non-repainting

The source is an input, so it runs on any symbol and timeframe. The oscillator updates live like any RSI; the calibration harness logs and resolves only on closed (confirmed) bars, so its Edge never inflates intrabar. Edge figures are in-sample, close-to-close, with no costs — a study aid, not a backtest. The heaviest part is the periodogram (a bounded lag × frequency scan); if load is slow on very low timeframes, lower the max lag.

Originality

The parts are public: the RSI, roofing filters, autocorrelation-periodogram cycle estimation, half-cycle adaptive RSI length, cyclic smoothing, and distribution-based bands. What's assembled here that isn't sitting on a shelf is the combination: an adaptive-length cyclic RSI wrapped in a spectral-concentration confidence gate that greys the pane and suppresses turns when no cycle is present, plus a forward-calibration harness that scores those gated turns against their base rate. The gate and the harness are this script's own; the rest is credited below. This is an independent Pine v6 implementation — no third-party code is copied verbatim.

Concept credits


Relative Strength Index — J. Welles Wilder.
Roofing filter (high-pass + SuperSmoother), the autocorrelation-periodogram dominant-cycle estimate, and the half-cycle adaptive RSI — John Ehlers (Cycle Analytics for Traders, Rocket Science for Traders).
Cyclic phasing smoother and distribution-based dynamic bands — after Lars von Thienen's cyclic-smoothed RSI (cRSI), from Decoding the Hidden Market Rhythm (whentotrade). That work is licensed Creative Commons Attribution 4.0 International (CC BY 4.0) — https://creativecommons.org/licenses/by/4.0/ . This script is an independent implementation adapted from that method, with changes (v6 rewrite, spectral-concentration gate, percentile bands, calibration harness); attribution is given as the licence requires.


Disclaimer

Research and educational tool only. Not financial advice, no recommendation, no guarantee of results. Markets are only intermittently cyclic; the cycle estimate lags and gets noisy at regime shifts, which is exactly why the gate exists. Indicators describe past behaviour; they do not predict the future. Trading carries risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                   MPL-2.0
// CYCLIC RSI — ADAPTIVE LENGTH & DYNAMIC BANDS                                                v1.1
// ────────────────────────────────────────────────────────────────────────────────────────────
// OVERVIEW
//   A cycle-tuned RSI. A fixed RSI length (14) is an arbitrary choice that fits some markets and
//   fights others. This oscillator measures the market's DOMINANT CYCLE from the data and sets the
//   RSI length to HALF of it, so the read auto-tunes across symbols and timeframes. It adds two more
//   upgrades: overbought/oversold bands that ADAPT to the recent distribution instead of a fixed
//   70/30, and a CYCLE-STRENGTH GATE — because a cyclic oscillator's overbought/oversold turns only
//   mean something when a real cycle is actually present. Reversal reads are greyed out when the
//   spectrum is flat. It is a momentum/timing tool, not a signal to trade alone.
//
// WHAT MAKES IT DIFFERENT  (why these parts are ONE tool)
//   - DOMINANT CYCLE from an autocorrelation periodogram on a roofing-filtered series (high-pass to
//     strip trend + a smoother to strip noise), which also emits a cycle CONFIDENCE (how sharply the
//     spectrum peaks). This is the measurement most cycle work considers superior to phase methods.
//   - ADAPTIVE LENGTH: RSI length = half the measured cycle, clamped — the whole point, it removes
//     the overfit of a fixed lookback. Pine's built-in RSI needs a constant length, so the RSI here
//     is summed by hand over the varying half-cycle.
//   - CYCLIC SMOOTHING: an optional phasing filter reduces lag so turns are timelier, then a smoother
//     cleans the line.
//   - ADAPTIVE BANDS: overbought/oversold are percentiles of the recent oscillator distribution, so
//     the thresholds fit the instrument and regime instead of an assumed 70/30.
//   - CYCLE GATE + CALIBRATION: turns fire only when cycle confidence clears a threshold, and a
//     forward harness measures whether those gated turns actually led a move. The cycle read is the
//     picture; the gate says when to trust it; the harness is the honesty.
//
// HOW IT WORKS
//   A roofing filter isolates the cycle band. Autocorrelation across a range of lags, projected onto
//   a small set of frequencies, yields a power spectrum whose centre of mass is the dominant cycle
//   and whose peak strength is the confidence. RSI length = half that cycle. The RSI is summed
//   directly over that length, optionally phase-smoothed, then smoothed. Overbought/oversold bands
//   are recent percentiles. Turns off the bands fire only when confidence clears the gate.
//
// HOW TO USE
//   Read the oscillator against its ADAPTIVE bands, not fixed lines. A turn up off the lower band is a
//   potential reversion long; a turn down off the upper band a potential short — but ONLY trust them
//   when the pane is not greyed (cycle present). When the gate is closed the market is trending or
//   has no clear cycle, and mean-reversion reads are unreliable. Watch the EDGE row: it tells you
//   whether gated turns have actually led moves on this instrument. Never a standalone trigger.
//
//
// EDGE IS NOW BOUNDED, NOT ASSERTED  (v1.1)
//   The Edge figure is a POINT ESTIMATE, and on a modest sample a +4 pt reading
//   and pure noise look identical. Every Edge now carries a WILSON 95% LOWER
//   BOUND beside it:  Edge LB = wilsonLo(hit rate) - base rate.  The panel turns
//   green ONLY when that lower bound clears zero with an adequate sample - a
//   positive point estimate alone is no longer coloured as though it were
//   evidence. Expect the bound to sit below zero far more often than the point
//   estimate does; that is the honest picture of a modest sample, not a fault in
//   the measurement.
//   Edge figures remain IN-SAMPLE and without costs - a study aid, not a backtest.
// UNIVERSAL / NON-REPAINT
//   Source is an input; runs on any symbol and timeframe. The oscillator reads live like any RSI; the
//   calibration harness logs and resolves ONLY on closed (confirmed) bars, so its Edge never inflates
//   intrabar. Edge figures are in-sample, close-to-close, no costs — a study aid.
//   PERFORMANCE: the periodogram is the heaviest part (a bounded lag×frequency scan). If load is
//   slow on very low timeframes, lower the max lag. Raise the band-memory only within reason — the
//   history buffer (max_bars_back) is sized for the maximum band memory.
//
// EXPORTS  (Data Window — consume from other scripts via input.source())
//   EXP_CyclicRSI · EXP_DomCycle · EXP_CycleConf · EXP_Turn (+1 up / −1 down / 0) · EXP_Edge
//
// CONCEPT CREDIT
//   Relative Strength Index — J. Welles Wilder. Roofing filter (high-pass + SuperSmoother), the
//   autocorrelation-periodogram dominant-cycle estimate, and the adaptive-length (half-cycle) RSI —
//   John Ehlers. Cyclic phasing smoother and distribution-based dynamic bands — after Lars von
//   Thienen's cyclic-smoothed RSI (cRSI), which is licensed CC BY 4.0; this is an independent Pine
//   v6 implementation, adapted, with changes indicated. The cycle-strength gate, the coupling and the
//   forward-calibration harness are this script's own. No third-party code is copied verbatim;
//   adapted methods are credited here and, with the CC BY 4.0 licence link, in the published
//   description. Not affiliated with, nor endorsed by, any party.
//
// HONESTY / LIMITATIONS
//   Markets are only INTERMITTENTLY cyclic; the cycle estimate lags and gets noisy at regime shifts,
//   which is exactly why the gate exists (low confidence → do not trade the bands). Adaptive bands
//   need memory to settle. Nothing here predicts price.
//
// DISCLAIMER
//   Research and educational tool only. NOT financial advice, NO recommendation, NO guarantee of
//   results. Indicators describe past behaviour; they do not predict the future. Trading carries
//   risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Cyclic RSI — Adaptive Length & Dynamic Bands", "Cyclic RSI", overlay = false, max_bars_back = 500)

int MAXLAG = 60   // fixed allocation ceiling for the spectrum arrays

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════════
g0        = "01 · Source & roofing filter"
src       = input.source(close, "Source", group = g0)
hpLen     = input.int(48, "High-pass length (trend removal)", minval = 10, maxval = 200, group = g0)
ssLen     = input.int(10, "Smoother length (noise removal)", minval = 2, maxval = 50, group = g0)

g1        = "02 · Cycle engine"
minLag    = input.int(8,  "Min cycle (lag)", minval = 4, maxval = 30, group = g1)
maxLag    = input.int(48, "Max cycle (lag)", minval = 12, maxval = 60, group = g1, tooltip = "Upper bound of the period search. Lower it to speed up the periodogram.")
avgLen    = input.int(3,  "Autocorrelation averaging", minval = 1, maxval = 10, group = g1)

g2        = "03 · Adaptive RSI"
halfFac   = input.float(0.5, "Length = cycle ×", minval = 0.25, maxval = 1.0, step = 0.05, group = g2, tooltip = "RSI length as a fraction of the dominant cycle. 0.5 = half-cycle (the classic choice).")
minRsi    = input.int(4,  "Min RSI length", minval = 2, maxval = 30, group = g2)
maxRsi    = input.int(48, "Max RSI length", minval = 5, maxval = 100, group = g2)
rsiSrcOpt = input.string("Price", "RSI input", options = ["Price","Roofing-filtered"], group = g2, tooltip = "Standard practice runs the RSI on price and uses the cycle only for length. Roofing-filtered is cleaner but more derivative.")

g3        = "04 · Smoothing"
useCyclic = input.bool(true, "Cyclic phasing (reduce lag)", group = g3, tooltip = "A phasing filter that makes turns timelier.")
vibration = input.int(10, "Phasing amount", minval = 1, maxval = 40, group = g3)
finalSs   = input.int(10, "Final smoother length", minval = 2, maxval = 50, group = g3)

g4        = "05 · Adaptive bands"
useAdaBand= input.bool(true, "Distribution-adaptive bands", group = g4, tooltip = "Overbought/oversold as recent percentiles instead of fixed 70/30. Bands adapt to the instrument; the memory window is fixed below.")
bandMem   = input.int(60, "Band memory (bars)", minval = 20, maxval = 400, group = g4)
leveling  = input.float(30, "Band percentile", minval = 5, maxval = 45, step = 1, group = g4, tooltip = "Oversold = this percentile; Overbought = its mirror. 30 → OS=30th / OB=70th percentile.")
fixedOB   = input.float(70, "Fixed overbought", minval = 55, maxval = 95, group = g4)
fixedOS   = input.float(30, "Fixed oversold", minval = 5, maxval = 45, group = g4)

g5        = "06 · Cycle gate"
gateThr   = input.float(0.40, "Min cycle confidence to trust", minval = 0.0, maxval = 0.95, step = 0.05, group = g5, tooltip = "Below this, the spectrum is treated as too flat for reliable cyclic turns; the pane greys and turns are suppressed.")
gateMode  = input.string("Grey out & suppress", "Below confidence", options = ["Grey out & suppress","Grey out only"], group = g5)

g6        = "07 · Calibration harness"
horizon   = input.int(10, "Forward horizon (bars)", minval = 2, maxval = 100, group = g6)
kATR      = input.float(1.0, "Move threshold (× ATR)", minval = 0.1, maxval = 5.0, step = 0.1, group = g6)

g7        = "08 · Display & theme"
showBands = input.bool(true, "Draw bands & fill", group = g7)
showMarks = input.bool(true, "Mark gated turns (pane)", group = g7)
showOvl   = input.bool(true, "Also mark signals on price (overlay)", group = g7, tooltip = "Draw the gated turn-up / turn-down triangles on the price chart as well as in the pane.")
tintGate  = input.bool(true, "Tint pane when cycle weak", group = g7)
showDash  = input.bool(true, "Show dashboard", group = g7)
theme     = input.string("Auto", "Theme", options = ["Auto","Dark","Light"], group = g7)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                      PALETTE / THEME / DSP HELPERS
// ═════════════════════════════════════════════════════════════════════════════════════════
GRN = #2ebd85
RED = #f6465d
YEL = #ffd600
f_luma(color c) => na(c) ? 0.0 : 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
isLight  = theme == "Light" or (theme == "Auto" and f_luma(chart.bg_color) > 140)
txtCol   = isLight ? color.new(#0b0f14, 0) : color.new(#e8edf2, 0)
mutCol   = isLight ? color.new(#5b6673, 0) : color.new(#8b95a1, 0)
rowA     = isLight ? color.new(#f2f4f7, 0) : color.new(#11161c, 0)
rowB     = isLight ? color.new(#e7ebf0, 0) : color.new(#171d24, 0)
hdrCol   = isLight ? color.new(#d9dee5, 0) : color.new(#0c1116, 0)
frameCol = isLight ? color.new(#c8cfd8, 0) : color.new(#2a323c, 0)

f_ss(series float s, simple int len) =>
    a1 = math.exp(-1.414 * math.pi / len)
    b1 = 2.0 * a1 * math.cos(1.414 * math.pi / len)
    c2 = b1
    c3 = -a1 * a1
    c1 = 1.0 - c2 - c3
    var float o = na
    float p1 = nz(o[1], s)
    float p2 = nz(o[2], s)
    o := c1 * (s + nz(s[1], s)) / 2.0 + c2 * p1 + c3 * p2
    o
f_hp(series float s, simple int len) =>
    a = (math.cos(0.707 * 2.0 * math.pi / len) + math.sin(0.707 * 2.0 * math.pi / len) - 1.0) / math.cos(0.707 * 2.0 * math.pi / len)
    var float h = na
    float p1 = nz(h[1], 0.0)
    float p2 = nz(h[2], 0.0)
    h := math.pow(1.0 - a / 2.0, 2) * (s - 2.0 * nz(s[1], s) + nz(s[2], s)) + 2.0 * (1.0 - a) * p1 - math.pow(1.0 - a, 2) * p2
    h

// ═════════════════════════════════════════════════════════════════════════════════════════
//                          ROOFING FILTER → cycle-band series
// ═════════════════════════════════════════════════════════════════════════════════════════
float filt = f_ss(f_hp(src, hpLen), ssLen)

// ═════════════════════════════════════════════════════════════════════════════════════════
//              AUTOCORRELATION PERIODOGRAM → dominant cycle + confidence
// ═════════════════════════════════════════════════════════════════════════════════════════
int hiLag = int(math.min(maxLag, MAXLAG))
var array<float> corrArr = array.new<float>(MAXLAG + 1, 0.0)
for lag = minLag to hiLag
    float Sx = 0.0
    float Sy = 0.0
    float Sxx = 0.0
    float Syy = 0.0
    float Sxy = 0.0
    for cnt = 0 to avgLen - 1
        float X = nz(filt[cnt])
        float Y = nz(filt[lag + cnt])
        Sx += X
        Sy += Y
        Sxx += X * X
        Syy += Y * Y
        Sxy += X * Y
    float den = (avgLen * Sxx - Sx * Sx) * (avgLen * Syy - Sy * Sy)
    float corr = den > 0.0 ? (avgLen * Sxy - Sx * Sy) / math.sqrt(den) : 0.0
    array.set(corrArr, lag, corr)

// small DFT of the autocorrelation → per-period power (smoothed across bars)
var array<float> pwrArr = array.new<float>(MAXLAG + 1, 0.0)
float maxPwr = 1e-12
for period = minLag to hiLag
    float cosP = 0.0
    float sinP = 0.0
    for lag = minLag to hiLag
        float c = array.get(corrArr, lag)
        cosP += c * math.cos(2.0 * math.pi * lag / period)
        sinP += c * math.sin(2.0 * math.pi * lag / period)
    float sq = cosP * cosP + sinP * sinP
    float sm = 0.2 * sq + 0.8 * array.get(pwrArr, period)
    array.set(pwrArr, period, sm)
    maxPwr := math.max(maxPwr, sm)

// dominant cycle = centre of mass of the normalized power above 0.5;
// cycle confidence = spectral CONCENTRATION (1 − mean normalized power): a sharp single
// peak → high confidence, a flat/spread spectrum → low confidence (a discriminating gate,
// unlike raw autocorrelation which saturates on a band-passed series).
float Spx = 0.0
float Sp = 0.0
float sumR = 0.0
int   nP = 0
for period = minLag to hiLag
    float r = array.get(pwrArr, period) / maxPwr
    sumR += r
    nP += 1
    if r >= 0.5
        Spx += period * r
        Sp += r
var float domCyc = na
domCyc := Sp > 0.0 ? Spx / Sp : nz(domCyc[1], (minLag + hiLag) / 2.0)
float meanR = nP > 0 ? sumR / nP : 1.0
float cycleConf = math.max(0.0, math.min(1.0, 1.0 - meanR))   // spectral concentration → gate

// ═════════════════════════════════════════════════════════════════════════════════════════
//                          ADAPTIVE-LENGTH RSI (summed by hand)
// ═════════════════════════════════════════════════════════════════════════════════════════
int rsiLen = int(math.max(minRsi, math.min(maxRsi, math.round(domCyc * halfFac))))
float rsiSrc = rsiSrcOpt == "Roofing-filtered" ? filt : src
float cu = 0.0
float cd = 0.0
for i = 0 to rsiLen - 1
    float d = nz(rsiSrc[i]) - nz(rsiSrc[i + 1])
    cu += d > 0.0 ? d : 0.0
    cd += d < 0.0 ? -d : 0.0
float arsi = (cu + cd) != 0.0 ? 100.0 * cu / (cu + cd) : 50.0

// cyclic phasing (reduce lag), then final smoother
float torque = 2.0 / (vibration + 1.0)
int   phLag  = int(math.max(0, math.round((vibration - 1) / 2.0)))
var float crsi = na
crsi := useCyclic ? torque * (2.0 * arsi - nz(arsi[phLag], arsi)) + (1.0 - torque) * nz(crsi[1], arsi) : arsi
float crsiSm = f_ss(crsi, finalSs)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                          ADAPTIVE OVERBOUGHT / OVERSOLD BANDS
// ═════════════════════════════════════════════════════════════════════════════════════════
float obBand = useAdaBand ? ta.percentile_linear_interpolation(crsiSm, bandMem, 100.0 - leveling) : fixedOB
float osBand = useAdaBand ? ta.percentile_linear_interpolation(crsiSm, bandMem, leveling) : fixedOS

// ═════════════════════════════════════════════════════════════════════════════════════════
//                          CYCLE GATE → SIGNALS
// ═════════════════════════════════════════════════════════════════════════════════════════
bool gateOpen = cycleConf >= gateThr
bool osTurnUp = ta.crossover(crsiSm, osBand) and (gateMode == "Grey out only" or gateOpen)
bool obTurnDn = ta.crossunder(crsiSm, obBand) and (gateMode == "Grey out only" or gateOpen)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                          CALIBRATION HARNESS (two-sided, non-repaint)
//   Accumulates ONLY on barstate.isconfirmed so the live bar never double-counts across ticks.
// ═════════════════════════════════════════════════════════════════════════════════════════
float atr = ta.atr(14)
int sigDir = osTurnUp ? 1 : obTurnDn ? -1 : 0
var int hN = 0
var int hHit = 0
var int bT = 0
var int bU = 0
var int bD = 0
bool warm = bar_index > hiLag + bandMem + horizon + 20
if barstate.isconfirmed and warm and not na(close[horizon]) and not na(atr[horizon])
    float thr = kATR * atr[horizon]
    float mv  = close - close[horizon]
    bT += 1
    bU += mv >=  thr ? 1 : 0
    bD += -mv >= thr ? 1 : 0
    int sd = sigDir[horizon]
    if sd != 0
        hN += 1
        hHit += (sd > 0 and mv >= thr) or (sd < 0 and -mv >= thr) ? 1 : 0
float hitP  = hN > 0 ? hHit * 100.0 / hN : na
float baseP = bT > 0 ? (bU + bD) * 100.0 / (2.0 * bT) : na
float edge  = (not na(hitP) and not na(baseP)) ? hitP - baseP : na

// WILSON 95% LOWER BOUND on the hit rate. The Edge above is a POINT ESTIMATE:
// on a small sample a +4 pt reading and pure noise are indistinguishable. The
// lower bound answers the question that actually matters - what is the WORST
// the hit rate plausibly is, given this many observations? Edge LB = the lower
// bound minus the base rate. Only a POSITIVE lower bound is evidence; a
// positive point estimate on its own is not.
f_wilsonLo(int hits, int n) =>
    float outv = na
    if n > 0
        float ph  = hits / float(n)
        float z   = 1.96
        float ctr = ph + z * z / (2.0 * n)
        float hlf = z * math.sqrt((ph * (1.0 - ph) + z * z / (4.0 * n)) / n)
        outv := math.max(0.0, (ctr - hlf) / (1.0 + z * z / n)) * 100.0
    outv
float edgeLo   = f_wilsonLo(hHit, hN)
float edgeLB   = (not na(edgeLo) and not na(baseP)) ? edgeLo - baseP : na
bool  edgeProven = not na(edgeLB) and edgeLB > 0 and hN >= 20


// ═════════════════════════════════════════════════════════════════════════════════════════
//                                        PLOTS
// ═════════════════════════════════════════════════════════════════════════════════════════
color zoneCol = not gateOpen ? mutCol : crsiSm >= obBand ? RED : crsiSm <= osBand ? GRN : YEL
bgcolor(tintGate and not gateOpen ? color.new(mutCol, 90) : na, title = "Weak-cycle tint")
hline(50, "Midline", color.new(chart.fg_color, 60))
pOB = plot(showBands ? obBand : na, "Overbought", color.new(RED, 55), 1)
pOS = plot(showBands ? osBand : na, "Oversold",   color.new(GRN, 55), 1)
fill(pOB, pOS, color = color.new(YEL, 94), title = "Band fill")
plot(crsiSm, "Cyclic RSI glow", color.new(zoneCol, 78), 7)
plot(crsiSm, "Cyclic RSI", color.new(zoneCol, 0), 2)
plotshape(showMarks and osTurnUp, "Turn up",   shape.triangleup,   location.bottom, color.new(GRN, 0), size = size.tiny)
plotshape(showMarks and obTurnDn, "Turn down", shape.triangledown, location.top,    color.new(RED, 0), size = size.tiny)
// same gated turns mirrored onto the price chart
plotshape(showOvl and osTurnUp, "Turn up (price)",   shape.triangleup,   location.belowbar, color.new(GRN, 0), size = size.tiny, force_overlay = true)
plotshape(showOvl and obTurnDn, "Turn down (price)", shape.triangledown, location.abovebar, color.new(RED, 0), size = size.tiny, force_overlay = true)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                        DASHBOARD
// ═════════════════════════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 9, border_width = 1, border_color = frameCol, frame_color = frameCol, frame_width = 1)
f_row(int r, string k, string v, color vc) =>
    color bg = r % 2 == 0 ? rowA : rowB
    table.cell(dash, 0, r, k, text_size = size.small, text_color = mutCol, text_halign = text.align_left,  bgcolor = bg)
    table.cell(dash, 1, r, v, text_size = size.small, text_color = vc,     text_halign = text.align_right, bgcolor = bg)
if showDash and barstate.islast
    string edgeTxt = hN < 20 ? "warming…" : str.tostring(edge, "+0.0;-0.0") + " / LB " + str.tostring(edgeLB, "+0.0;-0.0") + " (n" + str.tostring(hN) + ")"
    color  edgeCol = na(edge) or hN < 20 ? mutCol : edgeProven ? GRN : edgeLB < -3 ? RED : mutCol
    string zoneTxt = not gateOpen ? "no clear cycle" : crsiSm >= obBand ? "overbought" : crsiSm <= osBand ? "oversold" : "neutral"
    table.cell(dash, 0, 0, "CYCLIC RSI", text_size = size.small, text_color = txtCol, text_halign = text.align_left,  bgcolor = hdrCol)
    table.cell(dash, 1, 0, syminfo.ticker,  text_size = size.small, text_color = txtCol, text_halign = text.align_right, bgcolor = hdrCol)
    f_row(1, "Cyclic RSI", str.tostring(crsiSm, "0.0"), zoneCol)
    f_row(2, "Zone", zoneTxt, zoneCol)
    f_row(3, "Dominant cycle", str.tostring(domCyc, "0.0") + " bars", txtCol)
    f_row(4, "Cycle confidence", str.tostring(cycleConf * 100.0, "0") + "%" + (gateOpen ? " ✓" : " · gated"), gateOpen ? GRN : mutCol)
    f_row(5, "Adaptive length", str.tostring(rsiLen), txtCol)
    f_row(6, "Bands OB / OS", str.tostring(obBand, "0") + " / " + str.tostring(osBand, "0"), txtCol)
    f_row(7, "Turn leads move?", edgeTxt, edgeCol)
    f_row(8, "Read", not gateOpen ? "trend / no cycle" : "trade the bands", gateOpen ? txtCol : mutCol)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                    EXPORTS  (Data Window — consume elsewhere via input.source())
// ═════════════════════════════════════════════════════════════════════════════════════════
plot(crsiSm,                            "EXP_CyclicRSI", color.new(color.gray, 100), display = display.data_window)
plot(domCyc,                            "EXP_DomCycle",  color.new(color.gray, 100), display = display.data_window)
plot(cycleConf,                         "EXP_CycleConf", color.new(color.gray, 100), display = display.data_window)
plot(osTurnUp ? 1 : obTurnDn ? -1 : 0,  "EXP_Turn",      color.new(color.gray, 100), display = display.data_window)
plot(edge,                              "EXP_Edge",      color.new(color.gray, 100), display = display.data_window)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                        ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════════
alertcondition(osTurnUp, "Cyclic RSI turn up",   "Cyclic RSI: gated turn up off the oversold band.")
alertcondition(obTurnDn, "Cyclic RSI turn down", "Cyclic RSI: gated turn down off the overbought band.")
alertcondition(ta.crossover(cycleConf, gateThr),  "Cycle appeared",   "Cyclic RSI: a dominant cycle has emerged (gate opened).")
alertcondition(ta.crossunder(cycleConf, gateThr), "Cycle faded",      "Cyclic RSI: dominant cycle faded (gate closed).")
````

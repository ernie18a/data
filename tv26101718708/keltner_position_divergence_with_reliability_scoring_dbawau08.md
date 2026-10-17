# Keltner Position Divergence with Reliability Scoring

- url: https://www.tradingview.com/script/DBAWaU08-Keltner-Position-Divergence-with-Reliability-Scoring/
- type: indicator
- pine_id: PUB;ef979d78e9e5417b92d8120e89ccb7ac
- version: 4.0

## Description

Overview

Keltner-Position Divergence with Reliability Scoring turns where price sits inside its Keltner channel into a bounded oscillator, reads it for divergence against price, and then scores — in real time — whether those divergences have actually been worth acting on for the symbol on your chart, and which direction is carrying the edge. It is a context / research read, not a standalone buy or sell signal.

The idea

A Keltner channel frames price with an ATR envelope around a moving average. Where price sits inside that envelope — pinned to the upper band, mid, or pinned to the lower band — is a bounded read of stretch. When price makes a new high but its Keltner position does not confirm (a lower band-position high), that non-confirmation can precede a turn. This script measures the divergence between price and its Keltner position, then keeps a self-updating track record of whether such divergences pay.

Why these parts are combined (mashup rationale)

Three components form one pipeline, not three separate signals:


A Keltner-position oscillator — price's location within the ATR envelope (0 centre, +1 upper band, −1 lower band), z-scored so the bands and zones mean the same on every asset.
Confirmed-pivot divergence — regular and hidden, between that position line and price, with an optional triple-pivot mode for rarer, stronger disagreements.
A reliability harness — a binomial-proportion confidence test that asks whether each class of divergence has preceded a favourable move (a k×ATR travel over a fixed horizon) more often than a same-zone baseline, reported per direction with a Wilson confidence bound.


Part 1 builds the bounded stretch read, part 2 fires only where price and position disagree, part 3 decides whether that disagreement has actually paid on this instrument. Remove any one and the tool can no longer answer "is this Keltner divergence worth trading here?"

How to use it

Read the verdict panel first. GREEN = these divergences have beaten a same-spot baseline here; RED = they've lost to it (skip, or change the band width / timeframe); AMBER = not statistically established yet; GREY = still gathering data. "Best signal" names the direction with the strongest measured edge; "Reward : risk" is the average best-vs-worst move after a signal, in ATR. A divergence is price making a higher high / lower low while the Keltner-position line does the opposite — marked in the pane and, optionally, on the price chart. It is context, never a standalone trigger.

Settings worth knowing

The regime filter ("Only count signals in regime") restricts the track record to signals that fired in a chosen regime — reverting markets suit divergence, strong trends punish it — so you can measure the edge where it's supposed to work. Costs subtracted (×ATR) raises the bar a signal must clear so the score is net of costs. Band width, MA length and the z-score window adapt the read to any instrument.

Universality & non-repainting

It reads only the chart's own price (configurable source), so it runs on any symbol, any timeframe, with no external data. Pivots confirm a fixed number of bars after the fact, and the track-record harness logs, updates and resolves only on confirmed (closed) bars, so its statistics never inflate or shift intrabar. The live oscillator updates each bar like any oscillator. All figures are in-sample and past-only.

Outputs for other scripts

Generic EXP_* plots — oscillator, signal, probability, edge, edge lower-bound, sample count, regime, band position — are published to the Data Window for use from other scripts via input.source().

Originality

Standard Keltner tools just plot the channel. This one turns band-position into a divergence oscillator and keeps a self-updating, confidence-scored, per-class track record against a same-zone baseline — so you see not just that a divergence printed, but whether and how it has paid on the current market. Clean-room implementation; no third-party Pine code reused.

Concept credits


Keltner channel — Chester Keltner; ATR-band refinement — Linda Raschke
Average True Range — J. Welles Wilder
Binomial score confidence interval — Edwin B. Wilson
Trend-efficiency regime measure — Perry Kaufman


Disclaimer

For research and education only. Not financial advice, not a recommendation, and not a guarantee of future results. All figures are in-sample and past-only. Markets carry risk; do your own research and manage your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ════════════════════════════════════════════════════════════════════════════════════════════
//  KELTNER-POSITION DIVERGENCE WITH RELIABILITY SCORING                                    v1.3
//  v1.3 (R1 · honest-stats standardization): the reliability scoring is now backed by the published
//    calibration libraries — robust-z via ml_robuststats/2 (byte-identical, so the oscillator/signals
//    are UNCHANGED), and Wilson lower-bound + Wilson half-width + hit-rate via ml_calib/2 — plus a NEW
//    optional time-of-day significance gate via ml_session/2 (group 05, default OFF). Imports are pinned
//    to the exact published v2 versions. Same calibration engine now shared across the divergence family.
//  v1.2 (Wave A): robust MAD z-score + Ehlers UltimateSmoother, both optional (default ON) and
//    one-click reversible via the "Z-score mode" and "Output smoother" selectors in the
//    Normalization group. Set them to "Classic (mean/stdev)" / "EMA" for the original v1.1 output.
//    No divergence or reliability-scoring logic changed.
//  © Market_Logic_India                                                                  MPL-2.0
// ----------------------------------------------------------------------------------------------
//  WHAT IT PLOTS
//    A normalised oscillator built from where price sits inside its Keltner channel (its position
//    between the volatility bands), with stretch bands and divergence markers, plus a plain-
//    language panel that scores — in real time — whether those divergences have actually been
//    worth acting on for the symbol on your chart, and which direction is carrying the edge.
//
//  THE IDEA
//    A Keltner channel frames price by an ATR envelope around a moving average. WHERE price sits
//    inside that envelope — pinned to the upper band, mid, or pinned to the lower band — is a
//    bounded read of stretch. When price makes a new high but its Keltner position does NOT confirm
//    (a lower band-position high), that non-confirmation can precede a turn. This script measures
//    divergence between price and its Keltner position, then scores whether such divergences pay.
//
//  WHY THESE PARTS ARE COMBINED (mashup rationale)
//    Three components form ONE pipeline, not three separate signals:
//      1. A Keltner-position oscillator (price location within an ATR envelope), z-scored.
//      2. Confirmed-pivot divergence between that position and price (regular + hidden).
//      3. A binomial-proportion confidence test → whether each class of divergence has preceded a
//         favourable move more often than a same-zone baseline.
//    Part 1 builds the bounded stretch read, part 2 fires only where price and position disagree,
//    part 3 decides whether that disagreement has paid on THIS instrument, per direction. Remove
//    any one and the script can no longer answer "is this Keltner divergence worth trading here?"
//
//  HOW TO USE
//    • Read the verdict panel first. GREEN = these divergences have beaten a same-spot baseline
//      here; RED = they've lost to it (skip / change band width or timeframe); AMBER = not
//      established yet; GREY = still gathering data.
//    • "Best signal" names the direction with the strongest measured edge. "Reward : risk" is the
//      average best vs worst move after a signal, in ATR.
//    • A divergence is price making a higher high / lower low while the Keltner-position line does
//      the opposite. Regular divergences are also mirrored on the price chart (optional).
//    • It is a context / research read, NOT a standalone buy or sell signal.
//
//  WHAT CHANGED IN v1.1  (two corrections to the scoring engine)
//
//    1. BASELINE STATE BUG - FIXED.
//       The zone-conditional baseline averaged its numerator inside the TRUE branch of a
//       ternary. Pine's stateful functions must run on EVERY bar; sitting in a conditional
//       branch, those averages were skipped on every bar where the denominator was zero, and
//       their rolling windows silently drifted over a broken history. Because the baseline is
//       the yardstick every divergence is measured against, the defect propagated straight
//       through the Edge, the lower bound, the verdict tier and the alerts. All four averages
//       are now computed unconditionally and combined afterwards. Verdicts on existing charts
//       may change - the previous ones were measured against a corrupted baseline.
//
//    2. LOWER BOUND WAS ANTI-CONSERVATIVE - FIXED.
//       The edge floor was computed as (hit rate - half-width). The Wilson interval, however,
//       is NOT symmetric about the observed rate: it is centred on (p + z^2/2n) / (1 + z^2/n),
//       a point pulled toward 0.5. Subtracting only the half-width therefore OVERSTATES the
//       floor, and overstates it most on small samples - precisely where a floor is supposed
//       to protect you. At a hit rate of 0.80 on 20 signals the old formula reported a floor
//       near 63% where the correct Wilson bound is roughly 58%. The proper bound is now used,
//       and since EDGE CONFIRMED and the alerts are both gated on it, some setups that
//       previously read confirmed will now read unproven. That is the correction working.
//
//    The panel also now shows the interval WIDTH beside the Edge, so the size of the
//    uncertainty is visible rather than only its floor.
//
//  ORIGINALITY
//    Standard Keltner tools just plot the channel. This one turns band-position into a divergence
//    oscillator and keeps a self-updating, confidence-scored, per-class track record against a
//    same-zone baseline — so you see not just that a divergence printed, but whether and how it has
//    paid on the current market.
//
//  DATA / UNIVERSALITY
//    Reads only the chart's own price (configurable source), so it runs on ANY symbol, ANY
//    timeframe, in ANY market with no external data. Defaults target NIFTY futures; change the
//    source, MA length or band width for other instruments.
//
//  NON-REPAINT
//    Pivots confirm a fixed number of bars after the fact. The track-record harness logs, updates
//    and resolves ONLY on confirmed (closed) bars, so its statistics never inflate or shift
//    intrabar. The live oscillator updates each bar, like any oscillator.
//
//  OUTPUTS FOR OTHER SCRIPTS
//    Generic EXP_* plots (oscillator, signal, probability, edge, edge lower-bound, sample count,
//    regime, band position) are published to the Data Window for use via input.source().
//
//  CONCEPT CREDITS
//    Keltner channel — Chester Keltner; ATR-band refinement — Linda Raschke. Average true range —
//    J. W. Wilder. Binomial score confidence interval — E. B. Wilson. Trend-efficiency regime
//    measure — P. Kaufman. (Named for attribution; the UI uses generic terms only.)
//
//  DISCLAIMER
//    For research and education only. NOT financial advice, NOT a recommendation, and NOT a
//    guarantee of future results. All figures are in-sample and past-only. Markets carry risk;
//    do your own research and manage your own risk.
// ════════════════════════════════════════════════════════════════════════════════════════════
indicator("Keltner-Position Divergence with Reliability Scoring", "KeltnerDv", overlay = false, max_labels_count = 500, max_lines_count = 300)

// R1 · honest-stats standardization — reliability scoring backed by the published calibration libraries
// (one engine across the divergence family). Robust-z is byte-identical to the prior local f_robZ, so the
// oscillator/signals are unchanged; only the stats plumbing + an optional time-of-day gate are new. Pinned
// to the exact published v2 versions so a later library update can't silently change this script.
import Market_Logic_India/ml_calib/2        as calib
import Market_Logic_India/ml_robuststats/2  as rstat
import Market_Logic_India/ml_session/2      as sess

// ════ 01 · DATA SOURCE ═════════════════════════════════════════════════════════
g1 = "01 · Data Source"
srcPrice = input.source(close, "Price source", group = g1, display = display.none, tooltip = "The chart price that Keltner position is diverged against. Defaults to close; runs on any symbol or timeframe.")

// ════ 02 · KELTNER ENGINE ══════════════════════════════════════════════════════
g2 = "02 · Keltner Engine"
kMaLen  = input.int(20, "Channel MA length", minval = 2, group = g2, display = display.none, tooltip = "Length of the moving-average centreline the channel is built around.")
kAtrLen = input.int(20, "Channel ATR length", minval = 2, group = g2, display = display.none)
kMult   = input.float(2.0, "Band width (×ATR)", minval = 0.5, maxval = 6.0, step = 0.1, group = g2, display = display.none, tooltip = "How many ATRs the bands sit from the centreline. Wider = position pins to the rails less often.")

// ════ 03 · DIVERGENCE ENGINE ═══════════════════════════════════════════════════
g3 = "03 · Divergence Engine"
divLb     = input.int(5, "Pivot length", minval = 2, group = g3, display = display.none)
maxGap    = input.int(60, "Max bars between pivots", minval = 5, group = g3, display = display.none)
magThr    = input.float(0.3, "Min position gap (×σ)", minval = 0.0, step = 0.05, group = g3, display = display.none)
showHidden= input.bool(true, "Include hidden divergence", group = g3, display = display.none)
pivotsReq = input.int(2, "Pivots required (2 = standard, 3 = triple)", minval = 2, maxval = 3, group = g3, display = display.none, tooltip = "3 = triple divergence: rarer, stronger — the disagreement must hold across three pivots.")
recentBars= input.int(5, "Treat a signal as 'live' for N bars", minval = 1, group = g3, display = display.none)

// ════ 04 · ZONES & NORMALIZATION ═══════════════════════════════════════════════
g4 = "04 · Zones & Normalization"
normLen   = input.int(100, "Z-Score window", minval = 20, group = g4, display = display.none, tooltip = "Standardises Keltner position so bands and zones mean the same on every asset.")
smoothLen = input.int(2, "Output smoothing", minval = 1, group = g4, display = display.none)
zMode     = input.string("Robust (MAD)", "Z-score mode", options = ["Robust (MAD)","Classic (mean/stdev)"], group = g4, display = display.none, tooltip = "Robust (MAD) standardizes with median / median-absolute-deviation (×1.4826), so outlier bars don't distort the σ bands. Classic reproduces the original.")
zWinMode = input.string("Single window", "Extreme normalization (Wave D · U8)", options = ["Single window","3-window consensus"], group = g4, tooltip = "Single window = the one Normalization window above (original). 3-window consensus = z is the MEDIAN of the z at half, one and double that window, so a reading is extreme only when short, medium and long agree. Default Single so nothing changes unless you opt in.")
smootherType = input.string("UltimateSmoother (Wave A)", "Output smoother", options = ["UltimateSmoother (Wave A)","EMA"], group = g4, display = display.none, tooltip = "Applies when smoothing > 1. UltimateSmoother (Ehlers) is lag-minimal; EMA reproduces the original.")
obSigma   = input.float(1.5, "Stretch band (σ)", minval = 0.5, step = 0.1, group = g4, display = display.none)
extSigma  = input.float(2.5, "Extreme band (σ)", minval = 0.5, step = 0.1, group = g4, display = display.none)

// ════ 05 · RELIABILITY SCORING & REGIME ════════════════════════════════════════
g5 = "05 · Reliability Scoring & Regime"
calcCal  = input.bool(true, "Measure track record", group = g5, display = display.none)
calH     = input.int(10, "Look-ahead (bars)", minval = 1, group = g5, display = display.none, tooltip = "How long after a signal we check whether the favourable move happened.")
calK     = input.float(1.0, "Favourable move (×ATR)", minval = 0.1, step = 0.1, group = g5, display = display.none)
costK    = input.float(0.0, "Costs subtracted (×ATR)", minval = 0.0, step = 0.05, group = g5, display = display.none, tooltip = "Raises the bar a signal must clear, so the score is NET of costs / slippage.")
calWin   = input.int(500, "Baseline window", minval = 50, group = g5, display = display.none)
minN     = input.int(20, "Minimum samples before judging", minval = 1, group = g5, display = display.none)
wfTrainN = input.int(30, "In-sample signals before out-of-sample (walk-forward)", minval = 5, group = g5, display = display.none, tooltip = "Wave E honesty: the first N resolved signals TRAIN (in-sample); every signal after is scored OUT-OF-SAMPLE. The OOS edge is the trustworthy one — an in-sample edge can flatter because the settings were chosen on that same data.")
regimeMode = input.string("Off", "Only count signals in regime", options = ["Off", "Favor reverting", "Favor trending"], group = g5, display = display.none, tooltip = "Optional filter — only signals in the chosen regime enter the track record. Reverting markets suit divergence; strong trends punish it.")
erLen    = input.int(20, "Regime window", minval = 3, group = g5, display = display.none)
erThr    = input.float(0.35, "Regime threshold", minval = 0.05, maxval = 0.95, step = 0.05, group = g5, display = display.none)
todOn    = input.bool(false, "Time-of-day significance gate (R1)", group = g5, display = display.none, tooltip = "When ON, a divergence only counts / marks if its intraday time-slot is statistically significant (ml_session.slotSignificant, |slot-z| ≥ threshold) — filters the dead hours. Off by default so nothing changes unless you opt in.")
todSlotM = input.int(30, "ToD slot size (min)", minval = 5, maxval = 120, group = g5, display = display.none)
todZ     = input.float(1.0, "ToD significance |z|", minval = 0.0, maxval = 4.0, step = 0.1, group = g5, display = display.none)

// ════ 06 · VISUALS & TABLES ════════════════════════════════════════════════════
g6 = "06 · Visuals & Tables"
themeOpt   = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = g6, display = display.none, tooltip = "Auto reads the chart background and adapts table colours for contrast.")
showVerdict= input.bool(true, "Show verdict panel", group = g6, display = display.none)
showKey    = input.bool(false, "Show key-info table", group = g6, display = display.none)
showGrid   = input.bool(false, "Show per-class table", group = g6, display = display.none)
showLines  = input.bool(true, "Draw connecting pivot lines", group = g6, display = display.none)
lineWidth  = input.int(2, "Divergence line width", minval = 1, maxval = 5, group = g6, display = display.none, tooltip = "Thickness of the pivot-to-pivot divergence lines.")
showTint   = input.bool(true, "Tint extreme zones", group = g6, display = display.none)
showOvl    = input.bool(true, "Mark signals on price (overlay)", group = g6, display = display.none, tooltip = "Draw the regular-divergence triangles on the price chart as well as in the pane.")
showId     = input.bool(true, "Show name tag", group = g6, display = display.none)
showEXP    = input.bool(true, "Publish EXP_* outputs", group = g6, display = display.none)
bullCol    = input.color(#2ebd85, "Bullish", group = g6, display = display.none)
bearCol    = input.color(#f6465d, "Bearish", group = g6, display = display.none)
midColr    = input.color(#f7c948, "Caution", group = g6, display = display.none)

// ─── HELPERS (pure: arguments + built-ins only) ───────────────────────────────
f_z(float v, float m, float s) => s > 0 ? (v - m) / s : 0.0
// robust z is now rstat.robZ (byte-identical formula: median / MAD ×1.4826) — see the R1 imports above.
// Ehlers UltimateSmoother (Wave A) — lag-minimal; no ta.* inside, safe under a selector.
ml_ultimateSmoother(series float src, simple int period) =>
    float q  = math.exp(-1.414 * math.pi / period)
    float c1 = 2.0 * q * math.cos(1.414 * math.pi / period)
    float c2 = q * q
    float a0 = (1.0 + c1 + c2) / 4.0
    float us = src
    if bar_index >= 4
        us := (1.0 - a0) * src + (2.0 * a0 - c1) * nz(src[1]) + (c2 - a0) * nz(src[2]) + c1 * nz(us[1]) - c2 * nz(us[2])
    us
// f_ci → calib.wilsonHalf, f_wilsonLo → calib.wilsonLo, f_hit → calib.hitRate — all byte-identical to the
// prior local formulas (see the R1 imports above). calib.wilsonHalf / calib.wilsonLo already return PERCENT
// (and wilsonLo already applies max(0,·)), so the ×100 is dropped at the call sites.
f_luma(color c) => 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)

// ─── ENGINE  (Keltner band-position as the divergence base) ───────────────────
atr = ta.atr(14)
// Keltner channel: MA centreline ± kMult·ATR. Position = where price sits in the
// envelope, 0 at centre, +1 at the upper band, -1 at the lower band (can exceed when
// price pierces a band). This bounded location read is what price is diverged against.
float kMid = ta.ema(srcPrice, kMaLen)
float kAtr = ta.atr(kAtrLen)
float kHalf = kMult * kAtr
float kPos = kHalf > 0 ? (srcPrice - kMid) / kHalf : 0.0
float cmpRaw = kPos
// Wave A: compute both z-scores + both smoothers unconditionally (Pine v6: ta.* must not sit in a branch), then select
// U8 (Wave D): z at three windows (unconditional), select by mode, optional median consensus.
int   _wS = math.max(5, int(normLen / 2))
int   _wL = int(normLen * 2)
float _zcS = f_z(cmpRaw, ta.sma(cmpRaw, _wS), ta.stdev(cmpRaw, _wS)), _zcM = f_z(cmpRaw, ta.sma(cmpRaw, normLen), ta.stdev(cmpRaw, normLen)), _zcL = f_z(cmpRaw, ta.sma(cmpRaw, _wL), ta.stdev(cmpRaw, _wL))
float _zrS = rstat.robZ(cmpRaw, _wS), _zrM = rstat.robZ(cmpRaw, normLen), _zrL = rstat.robZ(cmpRaw, _wL)
bool  _uCl = zMode == "Classic (mean/stdev)"
float _zS = _uCl ? _zcS : _zrS
float _zM = _uCl ? _zcM : _zrM
float _zL = _uCl ? _zcL : _zrL
float _zMed = _zS + _zM + _zL - math.min(_zS, math.min(_zM, _zL)) - math.max(_zS, math.max(_zM, _zL))
float cmpZ = zWinMode == "Single window" ? _zM : _zMed
float cmpEma   = ta.ema(cmpZ, smoothLen)
float cmpUlt   = ml_ultimateSmoother(cmpZ, math.max(smoothLen, 2))
float cmp = smoothLen > 1 ? (smootherType == "EMA" ? cmpEma : cmpUlt) : cmpZ
float cmpStd = ta.stdev(cmp, normLen)

// internal regime (trend-efficiency ratio)
float erNum = math.abs(srcPrice - srcPrice[erLen])
float erDen = math.sum(math.abs(srcPrice - srcPrice[1]), erLen)
float erVal = erDen > 0 ? erNum / erDen : na
bool  trending = not na(erVal) and erVal >= erThr
bool  regimeOK = regimeMode == "Off" ? true : regimeMode == "Favor reverting" ? (na(erVal) ? true : erVal < erThr) : (na(erVal) ? true : erVal >= erThr)
int   regimeCode = na(erVal) ? 0 : trending ? 1 : -1
// R1 time-of-day significance gate — a divergence counts / marks only in a statistically live slot.
int   todSlot = sess.slotOf(todSlotM)
int   todNs   = sess.slotCount(todSlotM)
bool  todOK   = (not todOn) or sess.slotSignificant(srcPrice - nz(srcPrice[1], srcPrice), todSlot, todNs, 0.10, todZ)

// ─── DIVERGENCE DETECTION (confirmed pivots, regular + hidden, 2- or 3-pivot) ──
ph = ta.pivothigh(cmp, divLb, divLb)
pl = ta.pivotlow(cmp, divLb, divLb)
var float pOscH = na
var float pOscL = na
var float pPrcH = na
var float pPrcL = na
var float pOscH2 = na
var float pOscL2 = na
var float pPrcH2 = na
var float pPrcL2 = na
var int   pBarH = na
var int   pBarL = na
bool bullDiv = false
bool bearDiv = false
bool hBull = false
bool hBear = false
if not na(pl)
    float pr = srcPrice[divLb]
    int curBar = bar_index - divLb
    bool gap2 = not na(pOscL) and (curBar - pBarL) <= maxGap and math.abs(pl - pOscL) >= magThr * nz(cmpStd)
    bool reg2 = gap2 and pl > pOscL and pr < pPrcL
    bool hid2 = gap2 and showHidden and pl < pOscL and pr > pPrcL
    bullDiv := pivotsReq == 3 ? (reg2 and not na(pOscL2) and pOscL > pOscL2 and pPrcL < pPrcL2) : reg2
    hBull   := pivotsReq == 3 ? (hid2 and not na(pOscL2) and pOscL < pOscL2 and pPrcL > pPrcL2) : hid2
    if showLines and (bullDiv or hBull)
        line.new(pBarL, pOscL, curBar, pl, xloc = xloc.bar_index, color = bullDiv ? color.new(bullCol, 0) : color.new(bullCol, 40), style = hBull ? line.style_dashed : line.style_solid, width = lineWidth)
    pOscL2 := pOscL
    pPrcL2 := pPrcL
    pOscL := pl
    pPrcL := pr
    pBarL := curBar
if not na(ph)
    float pr = srcPrice[divLb]
    int curBar = bar_index - divLb
    bool gap2 = not na(pOscH) and (curBar - pBarH) <= maxGap and math.abs(ph - pOscH) >= magThr * nz(cmpStd)
    bool reg2 = gap2 and ph < pOscH and pr > pPrcH
    bool hid2 = gap2 and showHidden and ph > pOscH and pr < pPrcH
    bearDiv := pivotsReq == 3 ? (reg2 and not na(pOscH2) and pOscH < pOscH2 and pPrcH > pPrcH2) : reg2
    hBear   := pivotsReq == 3 ? (hid2 and not na(pOscH2) and pOscH > pOscH2 and pPrcH < pPrcH2) : hid2
    if showLines and (bearDiv or hBear)
        line.new(pBarH, pOscH, curBar, ph, xloc = xloc.bar_index, color = bearDiv ? color.new(bearCol, 0) : color.new(bearCol, 40), style = hBear ? line.style_dashed : line.style_solid, width = lineWidth)
    pOscH2 := pOscH
    pPrcH2 := pPrcH
    pOscH := ph
    pPrcH := pr
    pBarH := curBar
// R1 time-of-day gate applied to every divergence class (default off → no-op).
bullDiv := bullDiv and todOK
bearDiv := bearDiv and todOK
hBull := hBull and todOK
hBear := hBear and todOK
bool longSig  = bullDiv or hBull
bool shortSig = bearDiv or hBear

// recency of last signal (any class)
var int lastDir = 0
var int lastBarSig = na
if bullDiv or hBull
    lastDir := 1
    lastBarSig := bar_index
if bearDiv or hBear
    lastDir := -1
    lastBarSig := bar_index
int barsSince = na(lastBarSig) ? na : bar_index - lastBarSig
bool live = not na(barsSince) and barsSince <= recentBars

// ─── ZONE-CONDITIONAL BASELINE ────────────────────────────────────────────────
bool upEvt  = srcPrice >= srcPrice[calH] + (calK + costK) * atr[calH]
bool dnEvt  = srcPrice <= srcPrice[calH] - (calK + costK) * atr[calH]
bool wasOS  = cmp[calH] <= -obSigma
bool wasOB  = cmp[calH] >=  obSigma
float upHit = wasOS and upEvt ? 1.0 : 0.0
float upTot = wasOS ? 1.0 : 0.0
float dnHit = wasOB and dnEvt ? 1.0 : 0.0
float dnTot = wasOB ? 1.0 : 0.0
// ta.sma is STATEFUL: it must be evaluated on EVERY bar or its rolling window is
// computed over a broken history. Previously the numerator averages sat inside
// the TRUE branch of a ternary, so on every bar where the denominator was zero
// they were skipped and their internal state silently drifted. Because these two
// values ARE the baseline that every divergence is scored against, the defect
// propagated into the Edge, the lower bound, the verdict tier and the alerts.
// All four averages are now computed unconditionally and combined afterwards.
float smaUpTot = ta.sma(upTot, calWin)
float smaUpHit = ta.sma(upHit, calWin)
float smaDnTot = ta.sma(dnTot, calWin)
float smaDnHit = ta.sma(dnHit, calWin)
float baseUp = smaUpTot > 0 ? smaUpHit / smaUpTot * 100.0 : na
float baseDn = smaDnTot > 0 ? smaDnHit / smaDnTot * 100.0 : na

// ─── TRACK-RECORD HARNESS (1 Bull · 2 Bear · 3 Hidden-Bull · 4 Hidden-Bear) ───
// Logs / updates / resolves ONLY on confirmed bars, so the live bar never double-counts
// across ticks. The regime filter gates what enters the record (only in-regime signals).
var int[]   cBar = array.new_int()
var int[]   cCls = array.new_int()
var int[]   cDir = array.new_int()
var float[] cEnt = array.new_float()
var float[] cAtr = array.new_float()
var float[] cBase= array.new_float()
var float[] cMfe = array.new_float()
var float[] cMae = array.new_float()
var float[] kW  = array.new_float(5, 0.0)
var float[] kN  = array.new_float(5, 0.0)
var float[] kBs = array.new_float(5, 0.0)
var float[] kBn = array.new_float(5, 0.0)
var float[] kFe = array.new_float(5, 0.0)
var float[] kAe = array.new_float(5, 0.0)
// Wave E — walk-forward out-of-sample split (trustworthy reliability, additive)
var int   wfResolved = 0
var float wfIsW = 0.0, var float wfIsN = 0.0
var float wfOosW = 0.0, var float wfOosN = 0.0
f_log(int cls, int dir, float basel) =>
    cBar.push(bar_index)
    cCls.push(cls)
    cDir.push(dir)
    cEnt.push(srcPrice)
    cAtr.push(atr)
    cBase.push(basel)
    cMfe.push(0.0)
    cMae.push(0.0)
if calcCal and barstate.isconfirmed and regimeOK
    if bullDiv
        f_log(1, 1, baseUp)
    if bearDiv
        f_log(2, -1, baseDn)
    if hBull
        f_log(3, 1, baseUp)
    if hBear
        f_log(4, -1, baseDn)
if barstate.isconfirmed and cBar.size() > 0
    for i = cBar.size() - 1 to 0
        int dir = cDir.get(i)
        float cur = dir == 1 ? srcPrice - cEnt.get(i) : cEnt.get(i) - srcPrice
        if cur > cMfe.get(i)
            cMfe.set(i, cur)
        if cur < cMae.get(i)
            cMae.set(i, cur)
        if bar_index - cBar.get(i) >= calH
            int cls = cCls.get(i)
            float a = cAtr.get(i)
            bool win = cur >= (calK + costK) * a
            kN.set(cls, kN.get(cls) + 1.0)
            if win
                kW.set(cls, kW.get(cls) + 1.0)
            // walk-forward: first wfTrainN resolved → in-sample, rest → out-of-sample
            wfResolved += 1
            if wfResolved <= wfTrainN
                wfIsN += 1.0
                wfIsW := wfIsW + (win ? 1.0 : 0.0)
            else
                wfOosN += 1.0
                wfOosW := wfOosW + (win ? 1.0 : 0.0)
            float b = cBase.get(i)
            if not na(b)
                kBs.set(cls, kBs.get(cls) + b)
                kBn.set(cls, kBn.get(cls) + 1.0)
            if a > 0
                kFe.set(cls, kFe.get(cls) + cMfe.get(i) / a)
                kAe.set(cls, kAe.get(cls) + cMae.get(i) / a)
            cBar.remove(i)
            cCls.remove(i)
            cDir.remove(i)
            cEnt.remove(i)
            cAtr.remove(i)
            cBase.remove(i)
            cMfe.remove(i)
            cMae.remove(i)

float totW = kW.get(1) + kW.get(2) + kW.get(3) + kW.get(4)
float totN = kN.get(1) + kN.get(2) + kN.get(3) + kN.get(4)
float totBs= kBs.get(1) + kBs.get(2) + kBs.get(3) + kBs.get(4)
float totBn= kBn.get(1) + kBn.get(2) + kBn.get(3) + kBn.get(4)
float totFe= kFe.get(1) + kFe.get(2) + kFe.get(3) + kFe.get(4)
float totAe= kAe.get(1) + kAe.get(2) + kAe.get(3) + kAe.get(4)
float hitPct  = calib.hitRate(totW, totN)
float basePct = totBn > 0 ? totBs / totBn : na
float edge    = not na(hitPct) and not na(basePct) ? hitPct - basePct : na
float ciPct   = calib.wilsonHalf(totW, totN, 1.96)
bool  enoughN = totN >= minN
float hitLoPct = calib.wilsonLo(totW, totN, 1.96)
float edgeLB  = not na(hitLoPct) and not na(basePct) ? hitLoPct - basePct : na
bool  sigStar = enoughN and not na(edgeLB) and edgeLB > 0
float mfeAll  = totN > 0 ? totFe / totN : na
float maeAll  = totN > 0 ? totAe / totN : na
float rr      = (not na(mfeAll) and not na(maeAll) and maeAll < 0) ? mfeAll / (-maeAll) : na
// Wave E — out-of-sample (walk-forward) reliability: the trustworthy read
float wfOosHit   = wfOosN > 0 ? wfOosW / wfOosN * 100.0 : na
float wfOosLo    = calib.wilsonLo(wfOosW, wfOosN, 1.96)
float wfOosEdge  = (not na(wfOosHit) and not na(basePct)) ? wfOosHit - basePct : na
float wfOosEdgeLB= (not na(wfOosLo) and not na(basePct)) ? wfOosLo - basePct : na
bool  wfOosProven= wfOosN >= minN and not na(wfOosEdgeLB) and wfOosEdgeLB > 0
float wfIsHit    = wfIsN > 0 ? wfIsW / wfIsN * 100.0 : na

// best-performing class (which direction carries the edge)
float bestE = na
int bestC = 0
for c = 1 to 4
    float n = kN.get(c)
    float h = calib.hitRate(kW.get(c), n)
    float bb = kBn.get(c) > 0 ? kBs.get(c) / kBn.get(c) : na
    float e = not na(h) and not na(bb) ? h - bb : na
    if n >= minN and not na(e) and (na(bestE) or e > bestE)
        bestE := e
        bestC := c
string bestName = bestC == 1 ? "Bullish" : bestC == 2 ? "Bearish" : bestC == 3 ? "Bullish (hidden)" : bestC == 4 ? "Bearish (hidden)" : "—"

// ─── VERDICT (plain language) ─────────────────────────────────────────────────
// tier: 0 learning · 1 no edge · 2 unproven · 3 confirmed
int tier = not enoughN ? 0 : (not na(edgeLB) and edgeLB > 0) ? 3 : (not na(edge) and edge < 0) ? 1 : 2
string verdict  = tier == 3 ? "✓ EDGE CONFIRMED" : tier == 1 ? "✗ NO EDGE HERE" : tier == 2 ? "• UNPROVEN" : "… LEARNING"
string actShort = tier == 3 ? "Signals have edge" : tier == 1 ? "Skip — no edge" : tier == 2 ? "Low confidence" : "Gathering data"
string actLong  = tier == 3 ? "Keltner-position divergences have beaten a same-spot baseline here. Favour the direction in 'Best signal' — as context, not a standalone trigger." : tier == 1 ? "These Keltner divergences have not beaten a coin-flip here. Skip them, widen the band, or change the timeframe." : tier == 2 ? "Edge isn't statistically established yet. Treat signals as low-confidence until the sample grows." : "Still collecting completed signals. The verdict appears once there are enough to judge (need " + str.tostring(minN) + ", have " + str.tostring(totN, "0") + ")."
string nowTxt = live ? (lastDir == 1 ? "Bullish" : "Bearish") + " signal" + (barsSince == 0 ? " — now" : " — " + str.tostring(barsSince) + " bars ago") : "No live signal"
string zone = cmp >= extSigma ? "Stretched high" : cmp >= obSigma ? "High" : cmp <= -extSigma ? "Stretched low" : cmp <= -obSigma ? "Low" : "Neutral"

// ─── THEME (adaptive to chart background) ─────────────────────────────────────
bool dark = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_luma(chart.bg_color) < 140
color panelBg = dark ? color.rgb(17, 22, 28)  : color.rgb(244, 246, 248)
color rowAlt  = dark ? color.rgb(25, 31, 39)  : color.rgb(232, 236, 240)
color pTxt    = dark ? color.rgb(154,166,178) : color.rgb(74, 82, 91)
color pStr    = dark ? color.white            : color.rgb(16, 20, 24)
color frameC  = dark ? color.rgb(58, 70, 84)  : color.rgb(196,204,212)
color tierCol = tier == 3 ? bullCol : tier == 1 ? bearCol : tier == 2 ? midColr : color.gray
color tierTxt = f_luma(tierCol) > 150 ? color.black : color.white
color zc      = cmp >= obSigma ? bullCol : cmp <= -obSigma ? bearCol : color.new(chart.fg_color, 25)
color zcTxt   = f_luma(zc) > 150 ? color.black : color.white

// ─── PLOTS (kept out of status line / price scale for a clean chart) ──────────
bgcolor(showTint ? (cmp >= extSigma ? color.new(bullCol, 92) : cmp <= -extSigma ? color.new(bearCol, 92) : na) : na, title = "Extreme tint")
hline(0, "Zero", color.new(chart.fg_color, 70))
pU  = plot(obSigma,   "+Band", color.new(bullCol, 65), 1, display = display.pane, editable = false)
pUe = plot(extSigma,  "+Ext",  color.new(bullCol, 80), 1, display = display.pane, editable = false)
pL  = plot(-obSigma,  "-Band", color.new(bearCol, 65), 1, display = display.pane, editable = false)
pLe = plot(-extSigma, "-Ext",  color.new(bearCol, 80), 1, display = display.pane, editable = false)
fill(pUe, pU,  extSigma,  obSigma,  color.new(bullCol, 82), color.new(bullCol, 95), title = "Upper band")
fill(pL, pLe, -obSigma, -extSigma, color.new(bearCol, 95), color.new(bearCol, 82), title = "Lower band")
color cmpCol = cmp >= 0 ? bullCol : bearCol
plot(cmp, "Keltner pos glow", color.new(cmpCol, 80), 5, display = display.pane)
plot(cmp, "Keltner pos", cmpCol, 2, display = display.pane)
int strT = sigStar ? 0 : 45
plotshape(bullDiv ? cmp : na, "Bullish signal", shape.diamond, location.absolute, color.new(bullCol, strT), 0, size = size.tiny, display = display.pane)
plotshape(bearDiv ? cmp : na, "Bearish signal", shape.diamond, location.absolute, color.new(bearCol, strT), 0, size = size.tiny, display = display.pane)
plotshape(showHidden and hBull ? cmp : na, "Hidden bullish", shape.diamond, location.absolute, color.new(bullCol, 45), 0, size = size.tiny, display = display.pane)
plotshape(showHidden and hBear ? cmp : na, "Hidden bearish", shape.diamond, location.absolute, color.new(bearCol, 45), 0, size = size.tiny, display = display.pane)
// regular divergences mirrored onto the price chart
plotshape(showOvl and bullDiv, "Bull (price)", shape.triangleup,   location.belowbar, color.new(bullCol, 0), size = size.tiny, force_overlay = true)
plotshape(showOvl and bearDiv, "Bear (price)", shape.triangledown, location.abovebar, color.new(bearCol, 0), size = size.tiny, force_overlay = true)

// ─── VERDICT PANEL (top-right) ────────────────────────────────────────────────
var table pan = table.new(position.top_right, 2, 9, frame_width = 1, border_width = 1)
f_pan(int r, string k, string v, color vc, string tip) =>
    color bg = r % 2 == 0 ? panelBg : rowAlt
    table.cell(pan, 0, r, k, text_color = pTxt, bgcolor = bg, text_size = size.tiny, text_halign = text.align_left, tooltip = tip)
    table.cell(pan, 1, r, v, text_color = vc, bgcolor = bg, text_size = size.tiny, text_halign = text.align_right, tooltip = tip)
if barstate.islast and showVerdict
    table.set_frame_color(pan, frameC)
    table.set_border_color(pan, frameC)
    table.cell(pan, 0, 0, "KELTNER DIV", text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny, text_halign = text.align_left)
    table.cell(pan, 1, 0, verdict, text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny, text_halign = text.align_right)
    f_pan(1, "Do this", actShort, tierCol, actLong)
    f_pan(2, "Right now", nowTxt, live ? (lastDir == 1 ? bullCol : bearCol) : pTxt, "Whether a fresh signal has printed in the last few bars.")
    f_pan(3, "Best signal", bestC == 0 ? "—" : bestName + "  " + (bestE >= 0 ? "+" : "") + str.tostring(bestE, "#.#") + "%", bestC == 0 ? pTxt : bestC == 1 or bestC == 3 ? bullCol : bearCol, "The divergence direction with the strongest measured edge over the baseline. Favour this side.")
    f_pan(4, "Band position", str.tostring(kPos, "0.00"), math.abs(kPos) >= 1.0 ? (kPos > 0 ? bullCol : bearCol) : pStr, "Where price sits in the Keltner envelope: 0 centre, +1 upper band, -1 lower band.")
    f_pan(5, "Track record", na(hitPct) ? "warming up" : "won " + str.tostring(hitPct, "#.#") + "% vs " + str.tostring(basePct, "#.#") + "% base", pStr, "How often the favourable move followed, vs a same-spot baseline, over " + str.tostring(totN, "0") + " completed signals.")
    f_pan(6, "Reward : risk", na(rr) ? "—" : str.tostring(rr, "0.0") + " : 1" + (rr >= 1.2 ? "  good" : rr < 0.8 ? "  poor" : ""), na(rr) ? pTxt : rr >= 1.2 ? bullCol : rr < 0.8 ? bearCol : pStr, "Average best move vs average worst move after a signal, in ATR. Below 1:1 means signals hurt more than they help.")
    f_pan(7, "Market regime", regimeCode == 1 ? "Trending" : regimeCode == -1 ? "Reverting" : "—", regimeCode == 1 ? bullCol : regimeCode == -1 ? midColr : pTxt, "Reverting markets suit divergence; strong trends punish it.")
    string wfTxt = wfOosN < minN ? "warming (" + str.tostring(wfOosN, "0") + "/" + str.tostring(minN) + ")" : (wfOosEdge >= 0 ? "+" : "") + str.tostring(wfOosEdge, "#.#") + "pp (LB " + (wfOosEdgeLB >= 0 ? "+" : "") + str.tostring(wfOosEdgeLB, "#.#") + ")" + (wfOosProven ? " ✓" : "")
    f_pan(8, "OOS edge (walk-fwd)", wfTxt, wfOosN < minN ? pTxt : wfOosProven ? bullCol : midColr, "Out-of-sample walk-forward: the edge measured ONLY on the signals AFTER the first " + str.tostring(wfTrainN) + " (in-sample). This is the trustworthy read — the in-sample track record above can flatter because the settings were tuned on that same data; the OOS edge cannot.")

// ─── KEY-INFO TABLE (top-left) ────────────────────────────────────────────────
var table keyT = table.new(position.top_left, 2, 6, frame_width = 1, border_width = 1)
f_key(int r, string k, string v, color vc) =>
    color bg = r % 2 == 0 ? panelBg : rowAlt
    table.cell(keyT, 0, r, k, text_color = pTxt, bgcolor = bg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(keyT, 1, r, v, text_color = vc, bgcolor = bg, text_size = size.tiny, text_halign = text.align_right)
if barstate.islast and showKey
    table.set_frame_color(keyT, frameC)
    table.set_border_color(keyT, frameC)
    table.cell(keyT, 0, 0, "KEY INFO", text_color = zcTxt, bgcolor = zc, text_size = size.tiny, text_halign = text.align_left)
    table.cell(keyT, 1, 0, zone, text_color = zcTxt, bgcolor = zc, text_size = size.tiny, text_halign = text.align_right)
    f_key(1, "Instrument", syminfo.ticker + " · " + timeframe.period, pStr)
    f_key(2, "Channel", "EMA " + str.tostring(kMaLen) + " ± " + str.tostring(kMult, "0.0") + "×ATR", pStr)
    f_key(3, "Band position", str.tostring(kPos, "0.00"), math.abs(kPos) >= 1.0 ? (kPos > 0 ? bullCol : bearCol) : pStr)
    f_key(4, "Samples", str.tostring(totN, "0") + (enoughN ? " (ready)" : " (warming)"), enoughN ? pStr : midColr)
    f_key(5, "Value (σ)", str.tostring(cmp, "#.##"), zc)

// ─── PER-CLASS TABLE (bottom-right) ───────────────────────────────────────────
var table grid = table.new(position.bottom_right, 7, 7, frame_width = 1, border_width = 1)
f_grid(int r, int cls, string nm, color nc) =>
    color bg = r % 2 == 0 ? panelBg : rowAlt
    float w = kW.get(cls)
    float n = kN.get(cls)
    float h = calib.hitRate(w, n)
    float bb = kBn.get(cls) > 0 ? kBs.get(cls) / kBn.get(cls) : na
    float e = not na(h) and not na(bb) ? h - bb : na
    float fe = n > 0 ? kFe.get(cls) / n : na
    float ae = n > 0 ? kAe.get(cls) / n : na
    float r2r = not na(fe) and not na(ae) and ae < 0 ? fe / (-ae) : na
    table.cell(grid, 0, r, nm, text_color = nc, bgcolor = bg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(grid, 1, r, str.tostring(n, "0"), text_color = pTxt, bgcolor = bg, text_size = size.tiny)
    table.cell(grid, 2, r, na(h) ? "—" : str.tostring(h, "#.#"), text_color = pStr, bgcolor = bg, text_size = size.tiny)
    table.cell(grid, 3, r, na(bb) ? "—" : str.tostring(bb, "#.#"), text_color = pTxt, bgcolor = bg, text_size = size.tiny)
    table.cell(grid, 4, r, na(e) ? "—" : (e >= 0 ? "+" : "") + str.tostring(e, "#.#"), text_color = na(e) ? pTxt : e > 0 ? bullCol : bearCol, bgcolor = bg, text_size = size.tiny)
    table.cell(grid, 5, r, na(r2r) ? "—" : str.tostring(r2r, "0.0"), text_color = pTxt, bgcolor = bg, text_size = size.tiny)
    table.cell(grid, 6, r, na(ae) ? "—" : str.tostring(ae, "#.#"), text_color = pTxt, bgcolor = bg, text_size = size.tiny)
if barstate.islast and showGrid
    table.set_frame_color(grid, frameC)
    table.set_border_color(grid, frameC)
    table.cell(grid, 0, 0, "Signal",  text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny, text_halign = text.align_left)
    table.cell(grid, 1, 0, "n",     text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny)
    table.cell(grid, 2, 0, "Win%",  text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny)
    table.cell(grid, 3, 0, "Base",  text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny)
    table.cell(grid, 4, 0, "Edge",  text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny)
    table.cell(grid, 5, 0, "R:R",   text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny)
    table.cell(grid, 6, 0, "MAE",   text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny)
    f_grid(1, 1, "Bullish",    bullCol)
    f_grid(2, 2, "Bearish",    bearCol)
    f_grid(3, 3, "Bull (hid)", color.new(bullCol, 35))
    f_grid(4, 4, "Bear (hid)", color.new(bearCol, 35))
    table.cell(grid, 0, 5, "All", text_color = pStr, bgcolor = panelBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(grid, 1, 5, str.tostring(totN, "0"), text_color = pTxt, bgcolor = panelBg, text_size = size.tiny)
    table.cell(grid, 2, 5, na(hitPct) ? "—" : str.tostring(hitPct, "#.#"), text_color = pStr, bgcolor = panelBg, text_size = size.tiny)
    table.cell(grid, 3, 5, na(basePct) ? "—" : str.tostring(basePct, "#.#"), text_color = pTxt, bgcolor = panelBg, text_size = size.tiny)
    table.cell(grid, 4, 5, na(edge) ? "—" : (sigStar ? "★" : "") + (edge >= 0 ? "+" : "") + str.tostring(edge, "#.#") + (na(ciPct) ? "" : " ±" + str.tostring(ciPct, "#.#")), text_color = na(edge) ? pTxt : edge > 0 ? bullCol : bearCol, bgcolor = panelBg, text_size = size.tiny)
    table.cell(grid, 5, 5, na(rr) ? "—" : str.tostring(rr, "0.0"), text_color = pTxt, bgcolor = panelBg, text_size = size.tiny)
    table.cell(grid, 6, 5, "", bgcolor = panelBg)
    table.cell(grid, 0, 6, "Edge floor", text_color = pTxt, bgcolor = rowAlt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(grid, 1, 6, "", bgcolor = rowAlt)
    table.cell(grid, 2, 6, "", bgcolor = rowAlt)
    table.cell(grid, 3, 6, "", bgcolor = rowAlt)
    table.cell(grid, 4, 6, na(edgeLB) ? "—" : (edgeLB >= 0 ? "+" : "") + str.tostring(edgeLB, "#.#"), text_color = na(edgeLB) ? pTxt : edgeLB > 0 ? bullCol : bearCol, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(grid, 5, 6, "", bgcolor = rowAlt)
    table.cell(grid, 6, 6, "", bgcolor = rowAlt)

// ─── NAME TAG (bottom-center) ─────────────────────────────────────────────────
var table idT = table.new(position.bottom_center, 1, 1)
if barstate.islast and showId
    table.cell(idT, 0, 0, "Keltner Div · " + syminfo.ticker + " · " + timeframe.period, text_size = size.tiny, text_color = dark ? color.white : color.black, bgcolor = color.new(dark ? color.black : color.white, 15))

// ─── EXP_* EXPORT BUS (generic names for cross-script access) ──────────────────
float expProb = na(hitPct) ? na : hitPct / 100.0
plot(showEXP ? cmp : na,        "EXP_Osc",    color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? (longSig ? 1 : shortSig ? -1 : 0) : na, "EXP_Signal", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? expProb : na,    "EXP_Prob",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? edge : na,       "EXP_Edge",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? edgeLB : na,     "EXP_EdgeLB", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? totN : na,       "EXP_N",      color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? regimeCode : na, "EXP_Regime", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? kPos : na,       "EXP_BandPos", color = color.new(color.gray, 100), display = display.data_window)
// Wave E — out-of-sample walk-forward exports
plot(showEXP ? wfOosEdge : na,  "EXP_OOSEdge", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? wfOosEdgeLB : na, "EXP_OOSEdgeLB", color = color.new(color.gray, 100), display = display.data_window)

// ─── ALERTS ───────────────────────────────────────────────────────────────────
alertcondition(bullDiv or hBull, "Bullish divergence", "Keltner Div: bullish Keltner-position divergence")
alertcondition(bearDiv or hBear, "Bearish divergence", "Keltner Div: bearish Keltner-position divergence")
alertcondition((bullDiv or hBull) and tier == 3, "Bullish (edge confirmed)", "Keltner Div: bullish divergence with confirmed edge")
alertcondition((bearDiv or hBear) and tier == 3, "Bearish (edge confirmed)", "Keltner Div: bearish divergence with confirmed edge")
````

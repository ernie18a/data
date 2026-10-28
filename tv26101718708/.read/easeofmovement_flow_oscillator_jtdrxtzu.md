# Ease-of-Movement Flow Oscillator

- url: https://www.tradingview.com/script/jtDrxtZu-Ease-of-Movement-Flow-Oscillator/
- type: indicator
- pine_id: PUB;8e19cc1998fa4cab98c82b138c525aef
- version: 5.0

## Description

Ease-of-Movement Flow Oscillator

A volume oscillator that measures how easily price moves — distance travelled relative to the volume required to travel it. Large travel on light volume = high ease (a frictionless drift); small travel on heavy volume = low ease (absorption — effort without result). Above zero, price advances with little resistance; below zero, it declines with little resistance. It adds an absorption warning and a plain-language forward-calibration layer, so you can tell at a glance whether a move is frictionless or being absorbed, and whether the signal has actually paid here.

Why these parts are combined (not a mashup for show). Ease of movement relates distance to the volume needed for it — a different question from "buying vs selling." A frictionless advance and an absorbed advance look identical on a price chart but behave differently next, so that's the core read. An effort-vs-result check (price making a new extreme while ease does not) flags absorption — heavy volume no longer moving price — which the raw line alone misses. Forward calibration removes blind faith: instead of assuming a cross "should" pay, it measures whether it actually has, with realistic profit/stop outcomes. Together they form one coherent volume-flow tool.

How it works. Distance moved = midpoint change; box ratio = (volume ÷ scale) ÷ range. Ease = distance ÷ box ratio, smoothed, standardized and soft-bounded to ±100 that auto-fits its own magnitude. A signal fires only when ease decisively clears a confirmation band beyond zero (filtering the constant zero-line chatter). Absorption divergence is detected from confirmed price pivots versus the ease line. Each signal is then labelled by a triple barrier — a profit target and equal stop in ATR units plus a time limit — split into in-sample and recent out-of-sample, with a confidence interval and a multiple-testing check.

How to use. Read the Verdict row (Long/Short, Absorption, or Wait) and the Conviction row, which reads "High" only when that signal type shows a positive edge that survives the test on this symbol. Green above zero = easy up, red below = easy down; shaded bands = strong ease; the faint band lines mark where signals fire. Best used with your own trend and risk plan, not alone.

What's original. The absorption (effort-vs-result) flag, auto volume scaling, a noise-filtering signal band, the forward triple-barrier calibration with an out-of-sample split, and a conviction read that openly admits when there's no proven edge.

Volume note. This needs real volume — use a futures contract such as NSE:NIFTY1!. On a cash index it reports "No volume" rather than printing noise.

Honesty & limitations. Edge figures are computed on this chart's own history with overlapping windows and no costs — context, not a guaranteed backtest; past behaviour doesn't predict the future. Volume quality varies by feed and instrument.

Disclaimer: for research and education only. Not financial advice. Trading carries risk of loss; manage your own positions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// EASE-OF-MOVEMENT FLOW OSCILLATOR — Effort-vs-Result, Forward-Calibrated                     v1.2
// ────────────────────────────────────────────────────────────────────────────────────────────
// v1.1 — Correctness + house-standard pass:
//        • Correctness: the signal crossovers called ta.crossover / ta.crossunder from behind a
//          short-circuiting `hasVol and …`, so on no-volume symbols (or before cumulative volume
//          turned positive) they were skipped and their series went inconsistent (CW10004). They
//          now run on every bar and the volume check is applied to the result.
//        • Added the MPL-2.0 licence header, an EXP_ Data-Window export bus, and a round-trip COST
//          model (Net R): conviction now requires a signal that also survives trading costs.
// ────────────────────────────────────────────────────────────────────────────────────────────
// WHAT IT IS
//   A volume oscillator that measures how EASILY price moves — distance travelled relative to the
//   volume required to travel it. Large price travel on light volume = high ease (a frictionless
//   drift); small travel on heavy volume = low ease (absorption / effort without result). Above
//   zero, price is advancing with little resistance; below zero, declining with little resistance.
//   It adds two things the textbook version lacks: an EFFORT-VS-RESULT absorption flag that warns
//   when heavy volume is failing to move price (a stall the raw line hides), and a forward-
//   calibration layer that scores its own zero-crosses on the chart you are viewing — in plain
//   language — so a non-technical reader can tell at a glance whether to act or wait.
//
// WHY THESE PARTS ARE COMBINED (read this if you think it is a mashup)
//   Each part answers what the previous one leaves open:
//     • Ease of movement relates DISTANCE to the VOLUME needed for it — a different question from
//       "buying vs selling". A frictionless advance and an absorbed advance look identical on a
//       price chart but behave differently next, so this is the core read.
//     • An effort-vs-result check (price making a new extreme while ease does NOT) flags absorption
//       — heavy volume that is no longer moving price — which the raw line alone misses.
//     • Forward calibration removes blind faith: instead of assuming a zero-cross "should" pay, it
//       measures whether it actually has, on this symbol, with realistic profit/stop outcomes.
//   Together they form one coherent volume-flow tool, not separate studies stacked for show.
//
// HOW IT WORKS
//   Distance moved = midpoint change; box ratio = (volume ÷ scale) ÷ range. Ease = distance ÷ box
//   ratio, smoothed, standardized and soft-bounded to ±100 (auto-fit to its own magnitude). Buy =
//   cross up through zero; Sell = cross down through zero. Absorption divergence is detected from
//   confirmed price pivots versus the ease line. Each signal is then labelled by a TRIPLE BARRIER
//   (profit target + equal stop in ATR units, plus a time limit), split into in-sample and recent
//   out-of-sample, with a confidence interval and a multiple-testing check.
//
// HOW TO USE (plain language)
//   • Read the VERDICT row: Long/Short = a fresh frictionless cross; Absorption = heavy volume
//     stalling price (a warning); Wait = mid-range.
//   • The CONVICTION row says whether that signal type has a positive, statistically-surviving edge
//     on THIS chart. Low conviction = treat as context only.
//   • Green above zero = easy up; red below = easy down; shaded bands = strong ease. Best used with
//     your own trend and risk plan, not alone.
//
// VOLUME  Needs real volume — use a futures contract (e.g. NSE:NIFTY1!). A cash index reports
//   "no volume" and the oscillator will say so rather than print noise.
//
// NON-REPAINT  Reads confirmed closes; pivots confirm late and never move. Calibration logs and
//   resolves only on barstate.isconfirmed.
//
// CONCEPT CREDIT (technical attributions)
//   This script combines established, public-domain techniques: an ease-of-movement (distance over
//   effort) volume oscillator from classical technical analysis; price-versus-oscillator
//   (effort-vs-result) divergence; triple-barrier outcome labelling from standard supervised-
//   labelling practice in quantitative finance; the Wilson score interval for the proportion bound;
//   and the Bonferroni adjustment for multiple testing. Credit is due to the originators of each
//   technique. This is an original implementation combining them into one forward-calibrated tool.
//
// CHANGELOG
//   v1.4 (Wave D) — Optional VSA event layer (U9 · group 8). Names the current bar's dominant
//     Wyckoff/VSA effort-vs-result event (Upthrust, Shakeout, Stopping Volume, Buying/Selling
//     Climax, No-Demand/Supply) on a new dashboard row using the shared ml_vsa vocabulary — the
//     specific event behind this tool's generic "absorption". Price markers are OFF by default.
//     Adds EXP_VSABias. The ease engine, signals and calibration are unchanged.
//   v1.3 (Wave C) — Optional shared REGIME GATE (group 6). A Kaufman efficiency-ratio filter can
//     restrict the Long/Short zero-cross signals (and their forward scoring) to a chosen regime:
//     "Favor trending" fires crosses only when the market is actually trending — a natural fit for a
//     momentum/ease cross — or "Favor reverting" for the opposite. Defaults to "Off" so behaviour is
//     identical to v1.2 unless you opt in. Absorption divergence, drawing and calibration math are
//     unchanged; only the final Long/Short signal passes through the gate. Dashboard group 6→7.
//   v1.2 (Wave A) — Two optional accuracy upgrades, both defaulting ON, both one-click reversible:
//     • ULTIMATESMOOTHER on the ease line. The raw box-ratio is spiky; the smoother can now use
//       Ehlers' lag-minimal UltimateSmoother instead of an SMA, so the ease wave tracks turns with
//       far less lag than a simple average. ("Smoother type".)
//     • ROBUST z-score. The ease line can be standardized with a MEDIAN / MAD z (median absolute
//       deviation × 1.4826) instead of mean / stdev — thin-volume / gap bars throw huge box-ratio
//       outliers, and MAD ignores them so the pane scale stays stable. ("Normalization".)
//     Set Smoother type = "SMA" and Normalization = "Classic (mean/stdev)" for the original v1.1
//     behaviour. No divergence or calibration logic changed.
//
// DISCLAIMER  For research and education only. Edge figures are computed on this chart's own
//   history with overlapping windows and no costs — context, not a guaranteed backtest, and past
//   behaviour does not predict the future. Nothing here is financial advice. Trading carries risk
//  of loss; size and manage your own positions.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Ease-of-Movement Flow Oscillator", "EOM Flow", overlay = false, max_lines_count = 200, max_labels_count = 300)

// ──────────────────────────────────────────────────────────────────────────────────────────────
// INPUTS  (defaults tuned for NSE:NIFTY1! intraday futures — needs real volume)
// ──────────────────────────────────────────────────────────────────────────────────────────────
gMain    = "1 · General"
useHL    = input.bool(true, "Use high/low midpoint", group = gMain, tooltip = "On: midpoint of high/low. Off: the close source below.")
srcClose = input.source(close, "Close source (if midpoint off)", group = gMain)
audience = input.string("Simple (plain language)", "Reading mode", options = ["Simple (plain language)", "Pro (full detail)"], group = gMain, tooltip = "Simple shows a verdict and conviction in words. Pro shows every number.")

gEng     = "2 · Ease engine"
emaLen   = input.int(14,  "Smoothing length", minval = 1, maxval = 100, group = gEng)
smootherType = input.string("UltimateSmoother (Wave A)", "Smoother type", options = ["UltimateSmoother (Wave A)","SMA"], group = gEng, tooltip = "How the ease line is smoothed. UltimateSmoother (Ehlers) is lag-minimal, so the wave turns sooner and cleaner than a simple average. SMA reproduces the original v1.1 behaviour.")
autoScale= input.bool(true, "Auto volume scale", group = gEng, tooltip = "Standardize automatically so the line fills the pane on any instrument. On by default — no manual tuning needed.")
volScale = input.float(1000000, "Manual volume scale (if auto off)", minval = 1, group = gEng, tooltip = "Divisor to keep the box ratio sane when auto scale is off; instrument-dependent.")
normLen  = input.int(100, "Normalization window", minval = 20, maxval = 500, group = gEng)
zMode    = input.string("Robust (MAD)", "Normalization", options = ["Robust (MAD)","Classic (mean/stdev)"], group = gEng, tooltip = "Robust (MAD) standardizes the ease line with median / median-absolute-deviation (×1.4826) — thin-volume and gap bars throw huge box-ratio outliers, and MAD ignores them so the pane scale stays stable. Classic reproduces the original.")

gDiv     = "3 · Absorption divergence"
showDiv  = input.bool(true, "Flag absorption", group = gDiv, tooltip = "Warn when price makes a new extreme but ease does not — heavy volume failing to move price.")
pivLen   = input.int(5,  "Pivot length", minval = 1, maxval = 50, group = gDiv)
divLook  = input.int(60, "Max bars between pivots", minval = 5, maxval = 300, group = gDiv)

gSig     = "4 · Zones"
strZone  = input.float(50, "Strong-ease zone", minval = 20, maxval = 90, group = gSig)
sigBand  = input.float(10, "Signal band (filter zero-noise)", minval = 0, maxval = 40, step = 1, group = gSig, tooltip = "A cross only signals when ease decisively passes this far beyond zero — filters the constant zero-line chatter that ease-of-movement produces. Raise for fewer, cleaner signals.")

gCal     = "5 · Forward calibration"
calOn    = input.bool(true, "Run forward calibration", group = gCal, tooltip = "Score signals forward on this chart. On by default — the core honesty feature.")
calHor   = input.int(10, "Time limit (bars)", minval = 2, maxval = 200, group = gCal)
barrierK = input.float(1.0, "Profit/stop size × ATR", minval = 0.1, maxval = 10.0, step = 0.1, group = gCal, tooltip = "A signal wins if price reaches the profit target (this many ATRs) before the equal-sized stop, within the time limit.")
atrLen   = input.int(14, "ATR length", minval = 2, maxval = 100, group = gCal)
oosBars  = input.int(1500, "Out-of-sample window (recent bars)", minval = 100, maxval = 20000, group = gCal, tooltip = "Signals inside the last N bars are scored separately as out-of-sample.")
uniqOn   = input.bool(true, "Non-overlapping sampling", group = gCal, tooltip = "Skip a signal if the previous same-side one was within one time-limit — reduces double-counting.")
calMinN  = input.int(20, "Min sample for rating", minval = 5, maxval = 500, group = gCal)
costR    = input.float(0.30, "Round-trip cost (R) — subtracted for NET", minval = 0.0, maxval = 3.0, step = 0.05, group = gCal, tooltip = "Round-trip cost (brokerage + STT + slippage + optimistic fill) as a fraction of the barrier risk (Profit/stop × ATR). The barrier is symmetric 1:1, so gross expectancy in R = 2·hit% − 1; Net R subtracts this cost, and CONVICTION now requires the edge to survive it. On 1m NIFTY futures costs eat a large share of R, so a gross edge that ignores them is not tradeable.")

gReg     = "6 · Regime gate (Wave C)"
regGate  = input.string("Off", "Regime gate", options = ["Off","Favor trending","Favor reverting"], group = gReg, tooltip = "Optional Kaufman efficiency-ratio filter on the Long/Short zero-cross signals (and their forward scoring). Off = unchanged. Favor trending = take frictionless crosses only when the market is actually trending (ER at/above threshold) — a natural fit for a momentum/ease cross. Favor reverting = the opposite. Default Off.")
regErLen = input.int(20, "Efficiency-ratio window", minval = 5, maxval = 200, group = gReg)
regErThr = input.float(0.40, "Trend threshold", minval = 0.05, maxval = 0.95, step = 0.05, group = gReg, tooltip = "ER at or above this = trending; below = ranging.")

gUI      = "7 · Dashboard & appearance"
showTbl  = input.bool(true, "Show dashboard", group = gUI)
tblPos   = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = gUI)
dashTheme= input.string("Auto (match chart)", "Color theme", options = ["Auto (match chart)","Dark","Light"], group = gUI, tooltip = "Auto reads the chart background brightness and adapts table, text and line colors for visibility on any theme.")
tintBg   = input.bool(true, "Tint pane in strong ease", group = gUI)
colUp    = input.color(#2ebd85, "Up color",   inline = "c", group = gUI)
colDn    = input.color(#f6465d, "Down color", inline = "c", group = gUI)

gVsa     = "8 · VSA bar events (Wave D)"
vsaRow   = input.bool(true,  "Name the VSA event on the dashboard", group = gVsa, tooltip = "Names the current bar's dominant Wyckoff/VSA effort-vs-result event (Upthrust, Shakeout, Stopping Volume, Buying/Selling Climax, No-Demand/Supply) using the shared ml_vsa vocabulary — the specific event behind a generic 'absorption'. Additive; the ease engine, signals and calibration are unchanged.")
vsaMarks = input.bool(false, "Also mark VSA events on price", group = gVsa, tooltip = "Off by default. On draws small VSA tags on the price chart alongside the ease signals.")
vsaLen   = input.int(50, "VSA history window", minval = 10, maxval = 300, group = gVsa)
vsaPiv   = input.int(5,  "New-extreme lookback", minval = 2, maxval = 50, group = gVsa)
vsaTod  = input.bool(false, "Time-of-day volume (Wave D · U11)", group = gVsa, tooltip = "OFF: high volume judged against a flat rolling window (original). ON: judge volume against the SAME time-of-day slot on prior sessions (ml_session per-slot baseline, inlined) — so a normal-for-the-open bar is not a false climax and a heavy-for-lunch bar is caught. Default off.")
vsaTodMin = input.int(5,  "  Slot size (minutes)", minval = 1, maxval = 60, group = gVsa, tooltip = "Time-of-day bucket size for the volume baseline.")
vsaTodSes = input.int(20, "  Session memory", minval = 3, maxval = 200, group = gVsa, tooltip = "Sessions of memory the per-slot volume baseline keeps.")

// ──────────────────────────────────────────────────────────────────────────────────────────────
// THEME  (single source of truth — every table, text and line color derives from here)
// ──────────────────────────────────────────────────────────────────────────────────────────────
bgc        = chart.bg_color
lumaV      = na(bgc) ? 0.0 : color.r(bgc)*0.299 + color.g(bgc)*0.587 + color.b(bgc)*0.114
darkUI     = dashTheme=="Dark" ? true : dashTheme=="Light" ? false : (na(bgc) or lumaV < 140)
panelBg    = darkUI ? color.rgb(17,22,28)    : color.rgb(244,246,248)
rowAlt     = darkUI ? color.rgb(25,31,39)    : color.rgb(232,236,240)
txtMain    = darkUI ? color.rgb(236,239,243) : color.rgb(16,20,24)
txtSub     = darkUI ? color.rgb(154,166,178) : color.rgb(74,82,91)
frameC     = darkUI ? color.rgb(58,70,84)    : color.rgb(196,204,212)
upC        = darkUI ? colUp : color.rgb(22,151,106)
dnC        = darkUI ? colDn : color.rgb(200,42,64)
flatC      = darkUI ? color.rgb(120,130,140) : color.rgb(122,130,139)
gridC      = darkUI ? color.new(color.gray, 55) : color.new(color.gray, 45)

// ── HELPERS ───────────────────────────────────────────────────────────────────────────────────
f_pos(string s) => s=="Top Left"?position.top_left : s=="Bottom Right"?position.bottom_right : s=="Bottom Left"?position.bottom_left : position.top_right
f_zscore(float s, int len) =>
    sd = ta.stdev(s, len)
    mn = ta.sma(s, len)
    sd == 0 ? 0.0 : (s - mn) / sd
// robust z: median / MAD (×1.4826). ta.median calls unconditional → compiles clean.
f_robZ(float s, int len) =>
    float med = ta.median(s, len)
    float mad = ta.median(math.abs(s - med), len)
    mad > 1e-10 ? (s - med) / (1.4826 * mad) : 0.0
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
f_tanh(float x) =>
    float xc = math.max(-10.0, math.min(10.0, x))
    float e = math.exp(2 * xc)
    (e - 1) / (e + 1)
f_squash(float x, float k) => 100.0 * f_tanh(x / math.max(k, 0.0001))
f_wilson(int w, int n, float z) =>
    if n <= 0
        na
    else
        p = w / n
        (p + z*z/(2*n) - z*math.sqrt(p*(1-p)/n + z*z/(4*n*n))) / (1 + z*z/n) * 100.0
f_stars(float wl, float base, int n) =>
    n < calMinN or na(wl) or na(base) ? "n/a" : wl > base+5 ? "★★★" : wl > base ? "★★" : wl > base-5 ? "★" : "—"
f_firstHit(float up, float lo, int hor) =>
    int fh = 0
    bool done = false
    for i = 0 to hor - 1
        off = hor - 1 - i
        if not done
            hi = high[off]
            ll = low[off]
            bu = hi >= up
            bd = ll <= lo
            if bu and bd
                fh := 2
                done := true
            else if bu
                fh := 1
                done := true
            else if bd
                fh := -1
                done := true
    fh

// ── ENGINE ──────────────────────────────────────────────────────────────────────────────────
hasVol = ta.cum(nz(volume)) > 0
mid    = useHL ? (high + low) / 2 : srcClose
dm     = mid - mid[1]
rng    = high - low
scaleUse = autoScale ? math.max(ta.sma(nz(volume), normLen), 1.0) : volScale
boxRatio = rng != 0 ? (volume / scaleUse) / rng : 0.0
emvRaw = boxRatio != 0 ? dm / boxRatio : 0.0
// compute both smoothers unconditionally, then select (emaLen 1 = passthrough, unchanged behaviour)
emvSma = ta.sma(emvRaw, emaLen)
emvUlt = ml_ultimateSmoother(emvRaw, math.max(emaLen, 2))
emv    = emaLen > 1 ? (smootherType == "SMA" ? emvSma : emvUlt) : emvRaw
// compute both z-scores unconditionally, then select
emvZc  = f_zscore(emv, normLen)
emvZr  = f_robZ(emv, normLen)
emvZ   = zMode == "Classic (mean/stdev)" ? emvZc : emvZr
// Adaptive display scale keeps the wave filling the pane on any instrument
absZ   = math.abs(emvZ * 33)
scaleRaw = ta.percentile_linear_interpolation(absZ, 200, 85)
dispScale = math.max(40.0, nz(scaleRaw, 100.0)) * 1.2
eom    = f_squash(emvZ * 33, dispScale)

// ta.crossover/crossunder are stateful — hoist them so the hasVol gate never short-circuits them
// (they must run every bar), then apply the volume check to the result.
bool xUp = ta.crossover(eom, sigBand)
bool xDn = ta.crossunder(eom, -sigBand)
// REGIME GATE (Wave C) — optional Kaufman efficiency-ratio filter, default Off.
float regErNet  = math.abs(close - close[regErLen])
float regErPath = math.sum(math.abs(close - close[1]), regErLen)
float regER     = regErPath > 0.0 ? regErNet / regErPath : 0.0
bool  regTrend  = regER >= regErThr
bool  regOK     = regGate == "Off" ? true : regGate == "Favor trending" ? regTrend : not regTrend
buySig  = hasVol and xUp and regOK
sellSig = hasVol and xDn and regOK

// ── VSA BAR EVENTS (Wave D · U9 — ml_vsa effort-vs-result taxonomy, inlined) ──
// Names the specific event behind a generic "absorption". All ta.* unconditional; volume-gated.
float vsaSp   = ta.percentrank(high - low, vsaLen)
// U11 (Wave D): optional time-of-day volume baseline (ml_session slotMean, inlined). "Heavy" is
// judged against the same wall-clock slot on prior sessions. State advances every bar (array EMA,
// no ta.*) so the baseline stays warm whether or not the switch is on.
int   vsaNSlots = math.max(1, int(math.ceil(1440.0 / math.max(vsaTodMin, 1))))
float vsaTodA   = 2.0 / (math.max(vsaTodSes, 1) + 1.0)
int   vsaSlot   = vsaTodMin > 0 ? int((hour * 60 + minute) / vsaTodMin) : 0
var array<float> vsaSlotVol = array.new<float>(vsaNSlots, na)
int   vsaSlotI  = (vsaSlot >= 0 and vsaSlot < vsaNSlots) ? vsaSlot : 0
float vsaSlotPv = array.get(vsaSlotVol, vsaSlotI)
float vsaSlotCv = na(volume) ? vsaSlotPv : na(vsaSlotPv) ? volume : vsaSlotPv + vsaTodA * (volume - vsaSlotPv)
array.set(vsaSlotVol, vsaSlotI, vsaSlotCv)
float vsaVolRatio = (not na(vsaSlotCv) and vsaSlotCv > 0.0) ? volume / vsaSlotCv : 1.0
float vsaVolUse   = vsaTod ? vsaVolRatio : volume
float vsaVp   = ta.percentrank(vsaVolUse,     vsaLen)
float vsaVpk  = ta.highest(vsaVolUse, vsaLen)
float vsaRngE = high - low
float vsaCp   = vsaRngE > 0.0 ? (close - low) / vsaRngE : 0.5
float vsaPHi  = ta.highest(high, vsaPiv)[1]
float vsaPLo  = ta.lowest(low,  vsaPiv)[1]
bool  vsaUpB  = close > close[1]
bool  vsaDnB  = close < close[1]
bool  vUpthrust = hasVol and (high >= vsaPHi) and vsaCp <= 0.35 and vsaVp >= 60.0
bool  vShakeout = hasVol and (low  <= vsaPLo) and vsaCp >= 0.65 and vsaVp >= 60.0
bool  vStopping = hasVol and vsaDnB and vsaSp >= 60.0 and vsaVp >= 80.0 and vsaCp >= 0.45
bool  vClimaxUp = hasVol and vsaUpB and vsaVolUse >= vsaVpk and vsaSp >= 70.0
bool  vClimaxDn = hasVol and vsaDnB and vsaVolUse >= vsaVpk and vsaSp >= 70.0
bool  vNoDemand = hasVol and vsaUpB and vsaSp <= 35.0 and vsaVp <= 35.0
bool  vNoSupply = hasVol and vsaDnB and vsaSp <= 35.0 and vsaVp <= 35.0
string vsaEvt = vClimaxUp ? "Buying climax" : vClimaxDn ? "Selling climax" : vUpthrust ? "Upthrust" : vShakeout ? "Shakeout" : vStopping ? "Stopping volume" : vNoDemand ? "No demand" : vNoSupply ? "No supply" : "—"
int    vsaBiasVal = (vClimaxDn or vShakeout or vStopping or vNoSupply) ? 1 : (vClimaxUp or vUpthrust or vNoDemand) ? -1 : 0
color  vsaEvtCol  = vsaBiasVal > 0 ? upC : vsaBiasVal < 0 ? dnC : flatC
strong  = math.abs(eom) > strZone
phaseTxt = not hasVol ? "No volume" : eom >= 0 ? (strong ? "Easy up" : "Up") : (strong ? "Easy down" : "Down")
wCol    = eom >= 0 ? upC : dnC

// ── ABSORPTION DIVERGENCE (price vs ease; detected on the standardized line) ─────────────────
detLine = emvZ
ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low, pivLen, pivLen)
phC = not na(ph)
plC = not na(pl)
curX = bar_index - pivLen
oH=detLine[pivLen], pHh=high[pivLen], oHy=eom[pivLen]
poH=ta.valuewhen(phC, detLine[pivLen],1), ppH=ta.valuewhen(phC, high[pivLen],1), pxH=ta.valuewhen(phC, bar_index-pivLen,1)
poHy=ta.valuewhen(phC, eom[pivLen],1)
bearDiv = showDiv and hasVol and phC and pHh>ppH and oH<poH and (curX-pxH<=divLook)
oL=detLine[pivLen], pLl=low[pivLen], oLy=eom[pivLen]
poL=ta.valuewhen(plC, detLine[pivLen],1), ppL=ta.valuewhen(plC, low[pivLen],1), pxL=ta.valuewhen(plC, bar_index-pivLen,1)
poLy=ta.valuewhen(plC, eom[pivLen],1)
bullDiv = showDiv and hasVol and plC and pLl<ppL and oL>poL and (curX-pxL<=divLook)

var line[] divLines = array.new_line()
if bearDiv
    ln = line.new(int(pxH), poHy, curX, oHy, color = color.new(dnC,25), width = 2)
    array.push(divLines, ln)
if bullDiv
    ln = line.new(int(pxL), poLy, curX, oLy, color = color.new(upC,25), width = 2)
    array.push(divLines, ln)
if array.size(divLines) > 14
    line.delete(array.shift(divLines))

// ── CALIBRATION (triple-barrier + OOS + uniqueness + Bonferroni) ─────────────────────────────
atrSeries = ta.atr(atrLen)
var int buyN = 0
var int buyW = 0
var int buyNo = 0
var int buyWo = 0
var int sellN = 0
var int sellW = 0
var int sellNo = 0
var int sellWo = 0
var int baseN = 0
var int baseW = 0
var int lastBuyBar = -1000000
var int lastSellBar = -1000000

canEval = calOn and barstate.isconfirmed and not na(close[calHor]) and not na(atrSeries[calHor])
if canEval
    entryB = close[calHor]
    aB = atrSeries[calHor]
    fhB = f_firstHit(entryB + barrierK*aB, entryB - barrierK*aB, calHor)
    baseN += 1
    baseW += (fhB == 1 or (fhB == 0 and close > entryB)) ? 1 : 0
    if buySig[calHor]
        sigBar = bar_index[calHor]
        okB = (not uniqOn) or (sigBar - lastBuyBar >= calHor)
        if okB
            win = fhB == 1 or (fhB == 0 and close > entryB)
            buyN += 1
            buyW += win ? 1 : 0
            if sigBar >= last_bar_index - oosBars
                buyNo += 1
                buyWo += win ? 1 : 0
            lastBuyBar := sigBar
    if sellSig[calHor]
        sigBarS = bar_index[calHor]
        okS = (not uniqOn) or (sigBarS - lastSellBar >= calHor)
        if okS
            winS = fhB == -1 or (fhB == 0 and close < entryB)
            sellN += 1
            sellW += winS ? 1 : 0
            if sigBarS >= last_bar_index - oosBars
                sellNo += 1
                sellWo += winS ? 1 : 0
            lastSellBar := sigBarS

baseUp  = baseN > 0 ? baseW / baseN * 100.0 : na
baseDn  = baseN > 0 ? 100.0 - baseUp : na
buyHit  = buyN  > 0 ? buyW  / buyN  * 100.0 : na
sellHit = sellN > 0 ? sellW / sellN * 100.0 : na
buyHitO = buyNo  > 0 ? buyWo  / buyNo  * 100.0 : na
sellHitO= sellNo > 0 ? sellWo / sellNo * 100.0 : na
buyEdge  = (not na(buyHit)  and not na(baseUp)) ? buyHit  - baseUp : na
sellEdge = (not na(sellHit) and not na(baseDn)) ? sellHit - baseDn : na
buyStars  = f_stars(f_wilson(buyW, buyN, 1.96),  baseUp, buyN)
sellStars = f_stars(f_wilson(sellW, sellN, 1.96), baseDn, sellN)
buySurv  = (buyN  >= calMinN and not na(baseUp)) and (f_wilson(buyW, buyN, 2.24)  > baseUp)
sellSurv = (sellN >= calMinN and not na(baseDn)) and (f_wilson(sellW, sellN, 2.24) > baseDn)

// COST MODEL (Net R on the symmetric 1:1 barrier)
float buyNetR  = na(buyHit)  ? na : (2.0 * buyHit  / 100.0 - 1.0) - costR
float sellNetR = na(sellHit) ? na : (2.0 * sellHit / 100.0 - 1.0) - costR

// ── PLAIN-LANGUAGE VERDICT + CONVICTION ──────────────────────────────────────────────────────
longConv  = buyN  >= calMinN and not na(buyEdge)  and buyEdge  > 0 and buySurv  and not na(buyNetR)  and buyNetR  > 0
shortConv = sellN >= calMinN and not na(sellEdge) and sellEdge > 0 and sellSurv and not na(sellNetR) and sellNetR > 0
verdict = not hasVol ? "NO VOLUME — use futures" : buySig ? "LONG — easy up" : sellSig ? "SHORT — easy down" : bullDiv ? "ABSORPTION — downside stalling" : bearDiv ? "ABSORPTION — upside stalling" : "WAIT"
vCol    = not hasVol ? flatC : buySig ? upC : sellSig ? dnC : bullDiv ? upC : bearDiv ? dnC : flatC
convTxt = (buySig and longConv) or (sellSig and shortConv) ? "High — edge survives test" : (buySig or sellSig) ? "Low — context only" : longConv or shortConv ? "Crosses have edge here" : "No proven edge here"
convCol = ((buySig and longConv) or (sellSig and shortConv)) ? upC : flatC

// ── PLOTS (theme-aware) ──────────────────────────────────────────────────────────────────────
pObIn  = plot(strZone,  "Easy up edge", color.new(upC, 45), 1)
pObOut = plot(100.0,    "Up cap",  color.new(upC, 100), display = display.none)
fill(pObIn, pObOut, 100.0, 50.0, color.new(upC, 30), color.new(upC, 95), title = "Easy-up zone")
pOsIn  = plot(-strZone, "Easy dn edge", color.new(dnC, 45), 1)
pOsOut = plot(-100.0,   "Dn cap",  color.new(dnC, 100), display = display.none)
fill(pOsIn, pOsOut, -50.0, -100.0, color.new(dnC, 95), color.new(dnC, 30), title = "Easy-down zone")
plot(0, "Zero", gridC, 1)
plot(sigBand > 0 ? sigBand : na, "Band+", color.new(flatC, 70), 1)
plot(sigBand > 0 ? -sigBand : na, "Band-", color.new(flatC, 70), 1)
bgcolor(tintBg ? (eom > strZone ? color.new(upC, 92) : eom < -strZone ? color.new(dnC, 92) : na) : na, title = "Strong-ease tint")

plot(eom, "Ease glow", color.new(wCol, 70), 8)
plot(eom, "Ease", color.new(wCol, 0), 2)

plotshape(buySig  ? eom : na, "Buy",  shape.triangleup,   location.absolute, color.new(upC,0), size = size.small)
plotshape(sellSig ? eom : na, "Sell", shape.triangledown, location.absolute, color.new(dnC,0), size = size.small)
plotshape(bullDiv ? oLy : na, "Bull absorption", shape.circle, location.absolute, color.new(upC,0), offset = -pivLen, size = size.tiny)
plotshape(bearDiv ? oHy : na, "Bear absorption", shape.circle, location.absolute, color.new(dnC,0), offset = -pivLen, size = size.tiny)
plotshape(buySig,  "Buy mark",  shape.triangleup,   location.belowbar, color.new(upC,0), size = size.tiny, force_overlay = true)
plotshape(sellSig, "Sell mark", shape.triangledown, location.abovebar, color.new(dnC,0), size = size.tiny, force_overlay = true)

// ── DASHBOARD ───────────────────────────────────────────────────────────────────────────────
simple = audience == "Simple (plain language)"
var table st = table.new(f_pos(tblPos), 2, 14, frame_width = 1, border_width = 1)
if showTbl and barstate.islast
    color hdr   = color.new(upC, 0)
    color phCol = eom>=0?upC:dnC
    table.set_bgcolor(st, panelBg)
    table.set_frame_color(st, frameC)
    table.set_border_color(st, frameC)
    int r = 0
    table.cell(st, 0, r, "Ease-of-Movement Flow", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(st, 1, r, str.upper(phaseTxt), text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Verdict", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, verdict, text_color = vCol, bgcolor = rowAlt, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Conviction", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, r, calOn ? convTxt : "calibration off", text_color = convCol, bgcolor = panelBg, text_size = size.tiny)
    r += 1
    if not simple
        table.cell(st, 0, r, "Ease", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, r, str.tostring(eom,"#"), text_color = phCol, bgcolor = rowAlt, text_size = size.tiny)
        r += 1
        table.cell(st, 0, r, "Scale", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, autoScale ? "auto" : "manual", text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)
        r += 1
    if calOn
        string baseTxt = (na(baseUp) or na(baseDn)) ? "warming up" : "up " + str.tostring(baseUp,"0") + "%  dn " + str.tostring(baseDn,"0") + "%"
        string buyTxt  = buyN  < calMinN ? "warming " + str.tostring(buyN)  : "win " + str.tostring(buyHit,"0")  + "%  edge " + (nz(buyEdge)>=0?"+":"")  + str.tostring(buyEdge,"0")  + "  (" + str.tostring(buyN) + ")"
        string sellTxt = sellN < calMinN ? "warming " + str.tostring(sellN) : "win " + str.tostring(sellHit,"0") + "%  edge " + (nz(sellEdge)>=0?"+":"") + str.tostring(sellEdge,"0") + "  (" + str.tostring(sellN) + ")"
        table.cell(st, 0, r, "Base " + str.tostring(calHor) + "b", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, r, baseTxt, text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
        r += 1
        table.cell(st, 0, r, "Long " + buyStars, text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, buyTxt, text_color = buyN<calMinN?flatC:upC, bgcolor = panelBg, text_size = size.tiny)
        r += 1
        table.cell(st, 0, r, "Short " + sellStars, text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, r, sellTxt, text_color = sellN<calMinN?flatC:dnC, bgcolor = rowAlt, text_size = size.tiny)
        r += 1
        string netTxt = (na(buyNetR) or na(sellNetR)) ? "warming" : "L " + (buyNetR>=0?"+":"") + str.tostring(buyNetR,"0.00") + " · S " + (sellNetR>=0?"+":"") + str.tostring(sellNetR,"0.00") + " R  (cost " + str.tostring(costR,"0.00") + ")"
        color netCol = (na(buyNetR) or na(sellNetR)) ? flatC : (buyNetR > 0 or sellNetR > 0) ? upC : dnC
        table.cell(st, 0, r, "Net R", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, netTxt, text_color = netCol, bgcolor = panelBg, text_size = size.tiny)
        r += 1
        if not simple
            string buyOTxt = buyNo  < calMinN ? "warming " + str.tostring(buyNo)  : "win " + str.tostring(buyHitO,"0")  + "%  (" + str.tostring(buyNo) + ")"
            string selOTxt = sellNo < calMinN ? "warming " + str.tostring(sellNo) : "win " + str.tostring(sellHitO,"0") + "%  (" + str.tostring(sellNo) + ")"
            table.cell(st, 0, r, "Out-of-sample", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
            table.cell(st, 1, r, "L " + buyOTxt + " · S " + selOTxt, text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)
            r += 1
            table.cell(st, 0, r, "Multi-test", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
            table.cell(st, 1, r, "long " + (buySurv?"survives":"no") + " · short " + (sellSurv?"survives":"no"), text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
            r += 1
    if vsaRow
        table.cell(st, 0, r, "VSA event", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, r, vsaEvt, text_color = vsaEvtCol, bgcolor = rowAlt, text_size = size.tiny)
        r += 1
    table.cell(st, 0, r, "Note", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, r, "context, not advice", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)

// ── GENERIC EXPORTS (for use from other scripts) ─────────────────────────────────────────────
plot(eom,       "EXP_Ease",        color.new(color.gray,100), display = display.data_window)
plot(emvZ,      "EXP_EaseZ",       color.new(color.gray,100), display = display.data_window)
plot(buySig?1:0,  "EXP_BuySignal",  color.new(color.gray,100), display = display.data_window)
plot(sellSig?1:0, "EXP_SellSignal", color.new(color.gray,100), display = display.data_window)
plot(buySig?1:sellSig?-1:0, "EXP_Signal", color.new(color.gray,100), display = display.data_window)
plot(bullDiv?1:bearDiv?-1:0, "EXP_Absorption", color.new(color.gray,100), display = display.data_window)
plot(buyEdge,   "EXP_LongEdge",    color.new(color.gray,100), display = display.data_window)
plot(sellEdge,  "EXP_ShortEdge",   color.new(color.gray,100), display = display.data_window)
plot(na(buyNetR)  ? na : buyNetR,  "EXP_LongNetR",  color.new(color.gray,100), display = display.data_window)
plot(na(sellNetR) ? na : sellNetR, "EXP_ShortNetR", color.new(color.gray,100), display = display.data_window)
plot(vsaBiasVal, "EXP_VSABias", color.new(color.gray,100), display = display.data_window)

// VSA event markers on price (Wave D) — off by default; one marker per bar by priority
plotshape(vsaMarks and vClimaxUp, "VSA Buying climax",  shape.triangledown, location.abovebar, color.new(#ff6d00,0), text = "BC", textcolor = color.new(#ff6d00,0), size = size.tiny, force_overlay = true)
plotshape(vsaMarks and vClimaxDn, "VSA Selling climax", shape.triangleup,   location.belowbar, color.new(#ff6d00,0), text = "SC", textcolor = color.new(#ff6d00,0), size = size.tiny, force_overlay = true)
plotshape(vsaMarks and vUpthrust and not (vClimaxUp or vClimaxDn), "VSA Upthrust", shape.triangledown, location.abovebar, color.new(dnC,0), text = "UT", textcolor = color.new(dnC,0), size = size.tiny, force_overlay = true)
plotshape(vsaMarks and vShakeout and not (vClimaxUp or vClimaxDn), "VSA Shakeout", shape.triangleup,   location.belowbar, color.new(upC,0), text = "SO", textcolor = color.new(upC,0), size = size.tiny, force_overlay = true)
plotshape(vsaMarks and vStopping and not (vClimaxUp or vClimaxDn or vShakeout), "VSA Stopping Vol", shape.square, location.belowbar, color.new(upC,0), text = "SV", textcolor = color.new(upC,0), size = size.tiny, force_overlay = true)

alertcondition(buySig,  "Long signal",  "Ease-of-Movement: crossed up through zero (easy up)")
alertcondition(sellSig, "Short signal", "Ease-of-Movement: crossed down through zero (easy down)")
alertcondition(bullDiv, "Bull absorption", "Ease-of-Movement: downside absorption (price low, ease higher)")
alertcondition(bearDiv, "Bear absorption", "Ease-of-Movement: upside absorption (price high, ease lower)")
alertcondition(ta.crossover(eom, strZone),   "Strong easy up",   "Ease-of-Movement: entered strong easy-up zone")
alertcondition(ta.crossunder(eom, -strZone), "Strong easy down", "Ease-of-Movement: entered strong easy-down zone")
````

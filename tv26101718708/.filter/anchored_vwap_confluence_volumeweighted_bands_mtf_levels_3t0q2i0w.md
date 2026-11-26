# Anchored VWAP Confluence  Volume-Weighted Bands & MTF Levels

- url: https://www.tradingview.com/script/3t0Q2I0W-Anchored-VWAP-Confluence-Volume-Weighted-Bands-MTF-Levels/
- type: indicator
- pine_id: PUB;49ed2f8f5bb54119abac0f1f57a10599
- version: 3.0

## Description

ANCHORED VWAP CONFLUENCE — Decayed Line, Volume-Weighted Bands & MTF Levels

OVERVIEW
This is an anchored-VWAP framework that turns a single VWAP line into a complete fair-value workspace. It plots an anchored VWAP, a faster "decayed" VWAP, a rolling VWAP, proper volume-weighted standard-deviation bands, higher-timeframe VWAP levels that act as support and resistance, and a regime read — and it calibrates its own signals against the symbol's own past so you can see how often they actually followed through. Everything is derived from one idea (volume-weighted price) so the components reinforce each other rather than competing for screen space.

WHY THESE COMPONENTS ARE COMBINED (and how they work together)
A plain VWAP tells you fair value but nothing about momentum, dispersion, higher-timeframe structure, or reliability. Each component here answers a different one of those questions, and they are meant to be read together as one picture:

- ANCHORED VWAP is the reference: fair value accumulated since a chosen event (the session, a swing pivot, or a manual click). Every other element is measured relative to this line, which is why it sits at the centre of the engine rather than being one more overlay.

- DECAYED FAST VWAP is the same VWAP with an exponential half-life applied to its volume weights, so it responds faster to recent flow. On its own a fast line is just noise; paired with the anchored line it becomes a momentum signal — when the fast line crosses the slow line, near-term flow has shifted relative to fair value. This is a fast/slow pair built from a single construct, not two unrelated indicators.

- VOLUME-WEIGHTED SIGMA BANDS measure dispersion around fair value. They are computed from the running second moment (sigma = square root of E[x^2] - (E[x])^2), volume-weighted and reset-aware, not a price-only standard deviation slapped onto the VWAP. Because the bands scale with volume-weighted dispersion, "stretched" means the same thing on any instrument and in any regime — which is what lets the cross and stretch signals be compared and calibrated across assets.

- ROLLING VWAP provides a second, independent cross of the anchored line, so a shift confirmed by both the decayed and the rolling line carries more weight than either alone.

- MULTI-TIMEFRAME VWAP LEVELS are the rolling VWAP computed at 3x, 5x and 15x the chart timeframe and drawn as horizontal levels. Higher-timeframe fair value is where larger participants transact, so these levels frequently act as support and resistance. They are coloured by role — green when a level sits below price (support), red when above (resistance) — and weighted by horizon, so the longer-timeframe level is visually the heaviest.

- REGIME + CALIBRATION are the quality layer. An efficiency-ratio and ADX read classifies the market as trending, mixed or choppy, and (optionally) filters the cross signals so they are not taken in chop. Separately, the script tracks, past-only, how often a cross was followed by a move and how often a stretch reverted toward fair value, reporting each as a percentage with a confidence interval. This is what separates a measured framework from a drawing tool: the signals are scored against the instrument's own history.

Read together: the anchored VWAP gives you fair value, the bands tell you how stretched price is, the decayed/rolling crosses tell you when flow shifts, the higher-timeframe levels tell you the structure price is moving inside, the regime tells you whether to trust a signal, and the calibration tells you how those signals have behaved here before.

HOW TO USE IT
1. Pick an anchor mode in settings — Session, Pivot High, Pivot Low, or Manual (click a bar). The anchored VWAP and its bands rebuild from that point.
2. Use the trend-coloured anchored VWAP as fair value. Price above it is in the upper half of value, below it the lower half.
3. Watch the decayed line crossing the anchored line (triangles) as a momentum-shift cue, and treat crosses that occur in a non-choppy regime as higher quality (the regime filter does this for you when enabled).
4. Treat the +/- sigma stretches (circles) as extension — price is far from fair value and historically prone to revert; the table shows how often that has happened on this symbol.
5. Use the 3x/5x/15x VWAP levels as support/resistance targets and invalidation references; alignment of price above or below all three is shown compactly in the table.
6. Read the table for direction, extension (as a z-score), regime, higher-timeframe alignment, and the past-only follow-through rates.

WHAT MAKES IT ORIGINAL
It is not a single-line VWAP or a generic band script. The combination is the point: a decayed fast/slow VWAP pair, a correct volume-weighted sigma from the running second moment, multi-timeframe VWAP support/resistance, regime-gated signals, and a per-symbol calibration of both the cross and the stretch. The calibration in particular — measuring the script's own signals against the symbol's own past rather than assuming they work — is not something a standard VWAP provides.

WORKS ON ANY ASSET (universal)
The price SOURCE is selectable in the settings, so the engine runs on any market — futures, indices, FX, crypto, or stocks. VWAP requires volume; on symbols that report none, you can borrow volume from a reference symbol so the script still functions. All thresholds are sigma- and ATR-relative, so nothing is tied to one instrument's price scale.

SETTINGS SUMMARY
- Data Source: price source (default HLC3) and an optional volume-borrow symbol for no-volume instruments.
- Anchor & Lines: anchor mode, pivot length, manual anchor time, decay half-life, rolling window, slope smoothing.
- Signals & Regime: stretch threshold (in sigma), and an option to show crosses only in a non-choppy regime.
- Higher-Timeframe VWAP: show the 3x/5x/15x bias, and draw them as support/resistance levels.
- Calibration: enable tracking, evaluation horizon, and minimum follow-through in ATR.
- Visuals: Auto/Dark/Light theme, bull/bear colours, gradient fill, line glow, table, and table position.

The script also prints its name, the symbol and the timeframe on the chart so it is always clear what is being viewed.

LIMITATIONS (please read)
- Pivot anchors confirm only after the pivot length in bars, so a new pivot anchor appears with that delay (it is always drawn at its true historical bar).
- The higher-timeframe levels are live VWAPs and firm up as their higher-timeframe bar closes.
- Calibration is descriptive of past behaviour only and is not a forecast.
- Everything here is probabilistic context, not a prediction or a guarantee.

DISCLAIMER
This is a study / indicator for chart analysis and education only. It is NOT a strategy, NOT a recommendation, and NOT financial advice. It places no orders and guarantees no outcome. Trading involves risk. Do your own research and manage your own risk.

## Source Code

````pine
// =============================================================================
//  ANCHORED VWAP CONFLUENCE — Adaptive Auto-Anchor, Volume-Weighted Bands & MTF
//  shorttitle: AVWAP-C                                           Pine Script v6
// -----------------------------------------------------------------------------
//  WHAT THIS IS
//    An anchored-VWAP framework that adds what a plain VWAP lacks: a time-DECAYED
//    fast VWAP that crosses the anchored line as a momentum signal, proper
//    VOLUME-WEIGHTED standard-deviation bands, higher-timeframe VWAP LEVELS that
//    act as support/resistance, and a past-only CALIBRATION of whether its own
//    signals actually followed through on the current symbol.
//
//  CHANGES IN THIS UPDATE
//    * Anchoring is now fully AUTOMATIC. The old click-to-place manual anchor and
//      its on-add setup prompt are removed. New modes: Dual (auto) — the default —
//      plus Swing Low, Swing High and Rolling. Dual re-anchors to the most recent
//      significant swing as structure forms. On existing charts no action is
//      needed; any manual anchor placed in an earlier version no longer applies
//      and the script self-anchors.
//    * Refreshed colour scheme: teal / magenta direction, orange decayed line,
//      blue rolling line, amber stretch markers, dark panel with a blue title.
//      Every colour remains editable in Settings.
//    * All analytics are unchanged — decayed cross, volume-weighted s bands,
//      multi-timeframe VWAP levels, regime filter and past-only calibration.
//
//  ANCHORING (adaptive, no manual setup)
//    The anchor is chosen automatically — there is no click-to-place step, so the
//    script loads instantly on any chart:
//      * Dual (auto)  — anchors to the more recent significant swing (low or high)
//                       and re-anchors as new structure forms. The default.
//      * Swing Low / Swing High — anchor to that pivot type only.
//      * Rolling      — a fixed-window volume VWAP, no pivot needed.
//    Both swing anchors accumulate FORWARD from the pivot (reseeded back to the
//    true pivot bar), never whole-chart cumulative, so long histories keep their
//    float precision. If no pivot has formed yet the channel falls back to the
//    rolling anchor so it never blanks out.
//
//  WHY THE COMPONENTS ARE COMBINED  (mashup rationale)
//    Each piece answers a different question and they are read together, so they
//    are fused into one object rather than stacked as separate studies:
//      * ANCHORED VWAP — fair value since the auto-selected swing. The reference
//        everything else is measured against.
//      * VOLUME-WEIGHTED s BANDS — dispersion around fair value from the running
//        second moment (s = sqrt(E[x^2] - E[x]^2)), so "stretched" means the same
//        thing across assets and regimes, unlike fixed-width bands.
//      * DECAYED FAST VWAP — the same VWAP with an exponential half-life on its
//        volume weights, so it reacts faster; its cross of the anchored line is a
//        momentum shift — a fast/slow pair built from one construct.
//      * ROLLING VWAP — a fixed-window VWAP as a second, independent cross.
//      * MULTI-TIMEFRAME VWAP LEVELS — the rolling VWAP at 3x, 5x and 15x the
//        chart timeframe, drawn as horizontal levels; higher-timeframe fair value
//        is where larger participants transact, so these act as support/resistance.
//      * REGIME + CALIBRATION — an efficiency/strength read filters crosses in
//        chop, and a forward hit-rate measures how often the signals worked.
//    Fair value, dispersion, momentum, higher-timeframe structure and proof —
//    one engine, because a trader needs all of them at once.
//
//  HOW TO READ IT
//    * The trend-coloured line is the anchored VWAP (fair value): teal = bullish
//      bias, magenta = bearish.
//    * The orange line is the decayed fast VWAP; the blue line is the rolling
//      VWAP. Triangles mark either crossing the anchored line (a momentum shift).
//    * The shaded bands are +/-1/2/3s; the gradient deepens toward the extremes.
//    * Amber circles mark +/-s stretches (extension, often mean-reversion-prone).
//    * The glowing horizontal levels are the 3x/5x/15x VWAPs — teal where they
//      sit below price (support), magenta where above (resistance); heavier = higher TF.
//    * The table reads direction, extension as a z-score, regime, the higher-TF
//      VWAP alignment, and the past-only follow-through rates of both signal types.
//    Context for your own decision — not a signal to act on. Manage your risk.
//
//  UNIVERSAL — WORKS ON ANY ASSET
//    The price SOURCE is selectable in settings, so the engine runs on any market
//    (futures, indices, FX, crypto, stocks). VWAP needs volume; where a symbol
//    reports none, volume is borrowed from a reference symbol. All thresholds are
//    s/ATR-relative, so nothing is hard-coded to one instrument's price scale.
//
//  ORIGINALITY
//    Not a single-line VWAP: an auto-selecting dual swing anchor, a decayed
//    fast/slow VWAP pair, a correct volume-weighted s from the running second
//    moment, multi-timeframe VWAP support/resistance, regime-gated signals, and a
//    per-symbol calibration of both the cross and the stretch — measured, not assumed.
//
//  LIMITATIONS (honest)
//    Swing anchors confirm only after the pivot length in bars, so a new anchor
//    appears with that delay (it is drawn at its true historical bar). In Dual
//    mode the anchor re-bases as new swings form, so the channel can step when a
//    fresh pivot confirms. Higher-timeframe levels firm up as their bar closes.
//    Calibration is past-only and descriptive. Everything here is probabilistic
//    context, not prediction.
//
//  DISCLAIMER
//    Study / indicator for analysis and education only. NOT a strategy, NOT a
//    recommendation, NOT financial advice. It places no orders and guarantees no
//    outcome. Markets carry risk. Do your own research and manage your own risk.
//    Update note: this version anchors automatically; manual-anchor settings from
//    earlier versions no longer apply and are no longer required.
// =============================================================================

//@version=6
indicator("Anchored VWAP Confluence — Adaptive Auto-Anchor, Volume-Weighted Bands & MTF Levels", "AVWAP-C", overlay = true, max_labels_count = 50, max_lines_count = 100, max_bars_back = 2000)

// ───────────────────────────── INPUTS ──────────────────────────────────────
gSrc = "Data Source (any asset)"
src          = input.source(hlc3, "Source", group = gSrc)
volBorrowSym = input.symbol("", "Borrow volume from symbol (no-volume fix)", group = gSrc, tooltip = "VWAP needs volume. If your symbol reports none, add one that does (e.g. a futures or proxy) and its volume is used.")

gAnc = "Anchor & Lines"
anchorMode = input.string("Dual (auto)", "Anchor mode", options = ["Rolling", "Swing Low", "Swing High", "Dual (auto)"], group = gAnc, tooltip = "Auto-anchors with no manual setup. Dual (auto) anchors to the more recent significant swing and re-anchors as new structure forms.")
pivotLen   = input.int(21, "Swing pivot length (bars)", options = [8, 13, 21, 34, 55, 89], group = gAnc, tooltip = "Pivot lookback used by the Swing/Dual anchors. Larger = more significant swings, slower to re-anchor.")
hl         = input.int(10, "Decay half-life (bars)", minval = 1, group = gAnc)
rollN      = input.int(21, "Rolling VWAP window (Fib)", options = [9, 21, 34, 55], group = gAnc)
showRoll   = input.bool(true, "Show rolling VWAP", group = gAnc)
sdSmooth   = input.int(5, "Slope-delta EMA smoothing", minval = 1, group = gAnc)

gSig = "Signals & Regime"
stretchZ  = input.float(2.0, "Stretch threshold (σ / z-score)", minval = 1.0, maxval = 4.0, step = 0.5, group = gSig)
useRegime = input.bool(true, "Only show crosses in a non-choppy regime", group = gSig, tooltip = "Filters decayed×anchored crosses using an efficiency-ratio + ADX regime read, removing most chop whipsaws.")

gHTF = "Higher-Timeframe VWAP (compact)"
useHTF = input.bool(true, "Show 3× / 5× / 15× timeframe VWAP bias", group = gHTF, tooltip = "Reads price vs a rolling VWAP at 3×, 5× and 15× your chart timeframe — compact higher-timeframe context without leaving the chart.")
showHtfLevels = input.bool(true, "Draw them as support / resistance levels", group = gHTF, tooltip = "Plots each higher-TF VWAP as a glowing horizontal level, green where it sits below price (support) and red above (resistance). Heavier line = longer horizon. Levels firm up as their higher-TF bar closes.")

gCal = "Calibration (past-only)"
calEnable  = input.bool(true, "Track signal follow-through", group = gCal)
calHorizon = input.int(20, "Evaluation horizon (bars)", minval = 3, maxval = 100, group = gCal)
calMoveATR = input.float(1.0, "Min follow-through (x ATR)", minval = 0.2, maxval = 4.0, step = 0.1, group = gCal)

gV = "Visuals"
themeMode    = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)", "Dark", "Light"], group = gV)
bullCol      = input.color(#21dfac, "Bullish", group = gV)
bearCol      = input.color(#df216d, "Bearish", group = gV)
showGradient = input.bool(true, "Gradient σ-band fill", group = gV)
showGlow     = input.bool(true, "Line glow", group = gV)
showTable    = input.bool(true, "Confluence table", group = gV)
dashPosStr   = input.string("Top Right", "Table position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gV)
showId       = input.bool(true, "Identity strip", group = gV)

// ───────────────────────────── PURE HELPERS ────────────────────────────────
f_luma(color c) => na(c) ? 0.0 : color.r(c) * 0.299 + color.g(c) * 0.587 + color.b(c) * 0.114
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))
f_pos(string s) =>
    switch s
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right
f_wilson(int hits, int total) =>
    float lo = na
    float hi = na
    if total >= 5
        float p = hits / float(total)
        float z = 1.96
        float den = 1.0 + z * z / total
        float c = (p + z * z / (2.0 * total)) / den
        float h = z * math.sqrt(p * (1.0 - p) / total + z * z / (4.0 * total * total)) / den
        lo := math.max(0.0, c - h)
        hi := math.min(1.0, c + h)
    [lo, hi]
f_mult(int m) =>
    float s = timeframe.in_seconds(timeframe.period) * m
    s < 60 ? str.tostring(math.round(s)) + "S" : s < 86400 ? str.tostring(math.round(s / 60.0)) : s < 604800 ? str.tostring(math.round(s / 86400.0)) + "D" : str.tostring(math.round(s / 604800.0)) + "W"
// higher-timeframe rolling VWAP value (pure: built-ins + inputs)
f_htfVwap() =>
    float pv = math.sum(src * volume, rollN)
    float vv = math.sum(volume, rollN)
    vv > 0 ? pv / vv : na

// ───────────────────────────── THEME ───────────────────────────────────────
_luma  = f_luma(chart.bg_color)
uiDark = themeMode == "Dark" ? true : themeMode == "Light" ? false : (na(chart.bg_color) or _luma < 140)
uiBull = bullCol
uiBear = bearCol
cPanel = uiDark ? color.rgb(10, 14, 22)    : color.rgb(244, 246, 248)
cSub   = uiDark ? color.rgb(22, 27, 34)    : color.rgb(233, 237, 242)
cAlt   = uiDark ? color.rgb(16, 20, 32)    : color.rgb(238, 241, 245)
cTxt   = uiDark ? color.rgb(226, 232, 240) : color.rgb(20, 26, 38)
cDim   = uiDark ? color.rgb(194, 203, 214) : color.rgb(96, 104, 116)
cFrame = uiDark ? color.rgb(43, 51, 64)    : color.rgb(196, 204, 212)
cBord  = uiDark ? color.rgb(43, 51, 64)    : color.rgb(210, 216, 224)
cHdr   = uiDark ? color.rgb(22, 29, 43)   : color.rgb(210, 224, 255)

// ───────────────────────────── VOLUME BORROW (unconditional) ───────────────
var bool nativeVolSeen = false
if volume > 0
    nativeVolSeen := true
useBorrow = str.length(volBorrowSym) > 0 and not nativeVolSeen
volBorrowResolved = str.length(volBorrowSym) > 0 ? volBorrowSym : syminfo.tickerid
volBorrowRaw = request.security(volBorrowResolved, timeframe.period, volume, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
volEff = useBorrow and not na(volBorrowRaw) ? volBorrowRaw : volume
bool noVol = na(volume) or volume <= 0

// per-bar weighted terms used by every anchor
srcVol  = src * volEff
srcVol2 = src * src * volEff

// ───────────────────────────── HTF BIAS (unconditional, gated) ─────────────
tf3 = f_mult(3)
tf5 = f_mult(5)
tf15 = f_mult(15)
float vw3  = request.security(syminfo.tickerid, tf3,  f_htfVwap(), lookahead = barmerge.lookahead_off)
float vw5  = request.security(syminfo.tickerid, tf5,  f_htfVwap(), lookahead = barmerge.lookahead_off)
float vw15 = request.security(syminfo.tickerid, tf15, f_htfVwap(), lookahead = barmerge.lookahead_off)
int bias3  = na(vw3)  ? 0 : close > vw3  ? 1 : close < vw3  ? -1 : 0
int bias5  = na(vw5)  ? 0 : close > vw5  ? 1 : close < vw5  ? -1 : 0
int bias15 = na(vw15) ? 0 : close > vw15 ? 1 : close < vw15 ? -1 : 0
int htfStack = (bias3 > 0 ? 1 : bias3 < 0 ? -1 : 0) + (bias5 > 0 ? 1 : bias5 < 0 ? -1 : 0) + (bias15 > 0 ? 1 : bias15 < 0 ? -1 : 0)

// ═════════════════════════════ ADAPTIVE ANCHOR ENGINE ══════════════════════
// Forward accumulation from each swing pivot (reset on a new pivot, seed the
// bars between the pivot and its confirmation). Maintains a LOW anchor and a
// HIGH anchor at once, plus a ROLLING anchor; the selected mode picks one.
pl = ta.pivotlow(low,  pivotLen, pivotLen)
ph = ta.pivothigh(high, pivotLen, pivotLen)

// LOW anchor (last swing low)
var float lPV = 0.0
var float lV  = 0.0
var float lP2V = 0.0
var int   lBar = na
if not na(pl)
    lPV  := 0.0
    lV   := 0.0
    lP2V := 0.0
    for k = 0 to pivotLen
        lPV  += srcVol[k]
        lV   += volEff[k]
        lP2V += srcVol2[k]
    lBar := bar_index - pivotLen
else if not na(lBar)
    lPV  += srcVol
    lV   += volEff
    lP2V += srcVol2
float lAV = (not na(lBar) and lV > 0) ? lPV / lV : na
float lSD = (not na(lBar) and lV > 0) ? math.sqrt(math.max(lP2V / lV - lAV * lAV, 0.0)) : na

// HIGH anchor (last swing high)
var float hPV = 0.0
var float hV  = 0.0
var float hP2V = 0.0
var int   hBar = na
if not na(ph)
    hPV  := 0.0
    hV   := 0.0
    hP2V := 0.0
    for k = 0 to pivotLen
        hPV  += srcVol[k]
        hV   += volEff[k]
        hP2V += srcVol2[k]
    hBar := bar_index - pivotLen
else if not na(hBar)
    hPV  += srcVol
    hV   += volEff
    hP2V += srcVol2
float hAV = (not na(hBar) and hV > 0) ? hPV / hV : na
float hSD = (not na(hBar) and hV > 0) ? math.sqrt(math.max(hP2V / hV - hAV * hAV, 0.0)) : na

// ROLLING anchor
float rW  = math.sum(volEff, rollN)
float rAV = rW > 0 ? math.sum(srcVol, rollN) / rW : na
float rSD = rW > 0 ? math.sqrt(math.max(math.sum(srcVol2, rollN) / rW - rAV * rAV, 0.0)) : na

// PRIMARY SELECTION (Dual picks the more recent pivot)
bool dualLowRecent = nz(lBar, -1) >= nz(hBar, -1)
float vwap = switch anchorMode
    "Rolling"    => rAV
    "Swing Low"  => lAV
    "Swing High" => hAV
    => dualLowRecent ? lAV : hAV
float sigma = switch anchorMode
    "Rolling"    => rSD
    "Swing Low"  => lSD
    "Swing High" => hSD
    => dualLowRecent ? lSD : hSD
int paBar = switch anchorMode
    "Rolling"    => bar_index - (rollN - 1)
    "Swing Low"  => lBar
    "Swing High" => hBar
    => dualLowRecent ? lBar : hBar

// Robustness: if the selected anchor hasn't formed yet, fall back to rolling
if na(vwap)
    vwap  := rAV
    sigma := rSD
    paBar := bar_index - (rollN - 1)

started = not na(vwap)
up1 = vwap + sigma
lo1 = vwap - sigma
up2 = vwap + 2 * sigma
lo2 = vwap - 2 * sigma
up3 = vwap + 3 * sigma
lo3 = vwap - 3 * sigma

// Reset signal for the decayed line: a new (selected) anchor point appeared.
bool resetNow = anchorMode == "Rolling" ? false : anchorMode == "Swing Low" ? not na(pl) : anchorMode == "Swing High" ? not na(ph) : (not na(pl) or not na(ph))

// ───────────────────────────── DECAYED FAST VWAP ───────────────────────────
lambda = math.pow(0.5, 1.0 / hl)
var float dNum = na
var float dDen = na
if resetNow or na(dNum)
    dNum := srcVol
    dDen := volEff
else
    dNum := lambda * dNum + srcVol
    dDen := lambda * dDen + volEff
decayed = na(dDen) ? na : dNum / dDen

// ───────────────────────────── ROLLING VWAP (secondary cross) ──────────────
rollRaw  = math.sum(srcVol, rollN) / math.sum(volEff, rollN)
rollVwap = started ? rollRaw : na

// ───────────────────────────── EXTENSION + SLOPE ───────────────────────────
spread     = (na(decayed) or na(vwap)) ? na : decayed - vwap
slopeDelta = ta.ema(ta.change(spread), sdSmooth)
float zScore = (started and sigma > 0) ? (src - vwap) / sigma : 0.0

// ───────────────────────────── REGIME (chart) ──────────────────────────────
float atr = ta.atr(14)
float atrSafe = atr > 0 ? atr : close * 0.001
float erNum = math.abs(close - close[20])
float erDen = math.sum(math.abs(close - close[1]), 20)
float er = erDen > 0 ? erNum / erDen : 0.0
[dpR, dmR, adxR] = ta.dmi(14, 14)
bool trending = er > 0.35 and adxR > 20
string regimeTxt = trending ? "Trending" : er < 0.2 ? "Choppy" : "Mixed"

// ───────────────────────────── SIGNALS (regime-gated) ──────────────────────
xUp = ta.crossover(decayed, vwap)
xDn = ta.crossunder(decayed, vwap)
rxUp = ta.crossover(rollVwap, vwap)
rxDn = ta.crossunder(rollVwap, vwap)
bool regimeOk = (not useRegime) or trending
crossUp     = started and xUp and regimeOk
crossDn     = started and xDn and regimeOk
rollCrossUp = started and rxUp
rollCrossDn = started and rxDn
stretchUp = started and zScore >= stretchZ
stretchDn = started and zScore <= -stretchZ

bull     = na(spread) ? false : spread >= 0
trendCol = bull ? uiBull : uiBear

// ───────────────────────────── CALIBRATION 1: CROSS CONTINUATION ───────────
var int ccTot = 0
var int ccHit = 0
var int[] ccBar = array.new_int(0)
var float[] ccRef = array.new_float(0)
var int[] ccDir = array.new_int(0)
if calEnable and barstate.isconfirmed and (crossUp or crossDn)
    array.push(ccBar, bar_index)
    array.push(ccRef, close)
    array.push(ccDir, crossUp ? 1 : -1)
if calEnable and array.size(ccBar) > 0
    int i = 0
    while i < array.size(ccBar)
        if bar_index - array.get(ccBar, i) >= calHorizon
            float p0 = array.get(ccRef, i)
            int dr = array.get(ccDir, i)
            float mv = close - p0
            bool hit = dr == 1 ? mv >= calMoveATR * atrSafe : mv <= -calMoveATR * atrSafe
            ccTot += 1
            ccHit += hit ? 1 : 0
            array.remove(ccBar, i)
            array.remove(ccRef, i)
            array.remove(ccDir, i)
        else
            i += 1
    while array.size(ccBar) > 300
        array.shift(ccBar)
        array.shift(ccRef)
        array.shift(ccDir)

// ───────────────────────────── CALIBRATION 2: STRETCH REVERSION ────────────
var int srTot = 0
var int srHit = 0
var int[] srBar = array.new_int(0)
var float[] srRef = array.new_float(0)
var int[] srDir = array.new_int(0)
bool newStretchUp = stretchUp and not stretchUp[1]
bool newStretchDn = stretchDn and not stretchDn[1]
if calEnable and barstate.isconfirmed and (newStretchUp or newStretchDn)
    array.push(srBar, bar_index)
    array.push(srRef, close)
    array.push(srDir, newStretchUp ? -1 : 1)
if calEnable and array.size(srBar) > 0
    int j = 0
    while j < array.size(srBar)
        if bar_index - array.get(srBar, j) >= calHorizon
            float p0 = array.get(srRef, j)
            int dr = array.get(srDir, j)
            float mv = close - p0
            bool hit = dr == 1 ? mv >= calMoveATR * atrSafe : mv <= -calMoveATR * atrSafe
            srTot += 1
            srHit += hit ? 1 : 0
            array.remove(srBar, j)
            array.remove(srRef, j)
            array.remove(srDir, j)
        else
            j += 1
    while array.size(srBar) > 300
        array.shift(srBar)
        array.shift(srRef)
        array.shift(srDir)

// ───────────────────────────── σ BANDS + GRADIENT FILL ─────────────────────
sBase = uiDark ? color.rgb(208, 216, 230) : color.rgb(54, 62, 78)
sCol1 = color.new(sBase, 58)
sCol2 = color.new(sBase, 42)
sCol3 = color.new(sBase, 26)
plot(started ? up1 : na, "+1σ", sCol1, 1)
plot(started ? lo1 : na, "-1σ", sCol1, 1)
plot(started ? up2 : na, "+2σ", sCol2, 1)
plot(started ? lo2 : na, "-2σ", sCol2, 1)
pU3   = plot(started ? up3  : na, "+3σ", sCol3, 1)
pL3   = plot(started ? lo3  : na, "-3σ", sCol3, 1)
pVref = plot(started ? vwap : na, "vwap ref", na, 1)
fill(pU3,   pVref, up3, vwap, showGradient ? color.new(uiBull, 50)  : na, showGradient ? color.new(uiBull, 100) : na)
fill(pVref, pL3,   vwap, lo3, showGradient ? color.new(uiBear, 100) : na, showGradient ? color.new(uiBear, 50)  : na)

// ───────────────────────────── GLOWING LINES ───────────────────────────────
rcore = showRoll and started ? rollVwap : na
plot(rcore, "Rolling glow", color.new(#79c0ff, showGlow ? 82 : 100), 5)
plot(rcore, "Rolling VWAP", color.new(#79c0ff, 0), 1)
dcore = started ? decayed : na
plot(dcore, "Decayed glow", color.new(#ffa600, showGlow ? 80 : 100), 6)
plot(dcore, "Decayed VWAP", color.new(#ffa600, 0), 2)
vcore = started ? vwap : na
plot(vcore, "VWAP glow outer", color.new(trendCol, showGlow ? 85 : 100), 9)
plot(vcore, "VWAP glow inner", color.new(trendCol, showGlow ? 60 : 100), 4)
plot(vcore, "Anchored VWAP",   trendCol, 2)

// ───────────────────────────── MARKERS ─────────────────────────────────────
plotshape(crossUp,     "Decayed↑VWAP", shape.triangleup,   location.belowbar, color.new(uiBull, 0), size = size.small)
plotshape(crossDn,     "Decayed↓VWAP", shape.triangledown, location.abovebar, color.new(uiBear, 0), size = size.small)
plotshape(rollCrossUp, "Roll↑VWAP",    shape.triangleup,   location.belowbar, color.new(uiBull, 0), size = size.tiny)
plotshape(rollCrossDn, "Roll↓VWAP",    shape.triangledown, location.abovebar, color.new(uiBear, 0), size = size.tiny)
plotshape(stretchUp,   ">+σ stretch",  shape.circle,       location.abovebar, color.new(#ffd166, 0), size = size.tiny)
plotshape(stretchDn,   ">-σ stretch",  shape.circle,       location.belowbar, color.new(#ffd166, 0), size = size.tiny)

// anchor marker at the true pivot bar (skip Rolling — it has no discrete anchor)
if resetNow and anchorMode != "Rolling"
    line.new(bar_index - pivotLen, low, bar_index - pivotLen, high, extend = extend.both, color = color.new(cDim, 40), style = line.style_dotted)

// ───────────────────────────── HTF VWAP SUPPORT/RESISTANCE LEVELS ──────────
var line[] hLines = array.new_line(0)
var label[] hLabels = array.new_label(0)
if showHtfLevels and useHTF and barstate.islast
    if array.size(hLines) > 0
        for k = 0 to array.size(hLines) - 1
            line.delete(array.get(hLines, k))
        array.clear(hLines)
    if array.size(hLabels) > 0
        for k = 0 to array.size(hLabels) - 1
            label.delete(array.get(hLabels, k))
        array.clear(hLabels)
    float[] lvls  = array.from(vw3, vw5, vw15)
    int[]   mults = array.from(3, 5, 15)
    for k = 0 to 2
        float lv = array.get(lvls, k)
        int ml = array.get(mults, k)
        if not na(lv)
            bool sup = close >= lv
            color rc = sup ? uiBull : uiBear
            int cw = ml == 15 ? 4 : ml == 5 ? 3 : 2
            line gO = line.new(bar_index, lv, bar_index + 1, lv, xloc = xloc.bar_index, extend = extend.right, color = color.new(rc, showGlow ? 80 : 100), width = cw + 5)
            line gI = line.new(bar_index, lv, bar_index + 1, lv, xloc = xloc.bar_index, extend = extend.right, color = color.new(rc, showGlow ? 55 : 100), width = cw + 2)
            line cR = line.new(bar_index, lv, bar_index + 1, lv, xloc = xloc.bar_index, extend = extend.right, color = color.new(rc, 0), width = cw)
            array.push(hLines, gO)
            array.push(hLines, gI)
            array.push(hLines, cR)
            label lb = label.new(bar_index + 8, lv, str.tostring(ml) + "× VWAP  " + str.tostring(math.round_to_mintick(lv)) + (sup ? "  · support" : "  · resistance"), xloc = xloc.bar_index, style = label.style_label_left, textcolor = color.white, color = color.new(rc, 8), size = size.small)
            array.push(hLabels, lb)

// ───────────────────────────── CONFLUENCE TABLE ────────────────────────────
[ccLo, ccHi] = f_wilson(ccHit, ccTot)
[srLo, srHi] = f_wilson(srHit, srTot)
var table t = table.new(f_pos(dashPosStr), 2, 9, border_width = 1, frame_width = 1)
if showTable and barstate.islast and started
    table.set_bgcolor(t, cPanel)
    table.set_frame_color(t, cFrame)
    table.set_border_color(t, cBord)
    string dir   = decayed > vwap ? "▲ bullish" : "▼ bearish"
    string accel = slopeDelta > 0 ? "accelerating" : "decelerating"
    string band  = zScore >= stretchZ ? "stretched up" : zScore <= -stretchZ ? "stretched down" : zScore > 0 ? "upper half" : "lower half"
    string ccTxt = ccTot < 5 ? "warming up" : str.tostring(math.round(ccHit * 100.0 / ccTot)) + "%  [" + (na(ccLo) ? "—" : str.tostring(math.round(ccLo * 100)) + "-" + str.tostring(math.round(ccHi * 100))) + "]"
    string srTxt = srTot < 5 ? "warming up" : str.tostring(math.round(srHit * 100.0 / srTot)) + "%  [" + (na(srLo) ? "—" : str.tostring(math.round(srLo * 100)) + "-" + str.tostring(math.round(srHi * 100))) + "]"
    table.cell(t, 0, 0, "AVWAP  •  " + anchorMode, text_color = #79c0ff, bgcolor = cHdr, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 0, regimeTxt, text_color = trending ? uiBull : cDim, bgcolor = cHdr, text_size = size.small, text_halign = text.align_right)
    table.cell(t, 0, 1, "Direction", text_color = cDim, text_size = size.small, bgcolor = cSub)
    table.cell(t, 1, 1, dir, text_color = bull ? uiBull : uiBear, text_size = size.small, bgcolor = cSub)
    table.cell(t, 0, 2, "Extension (z)", text_color = cDim, text_size = size.small, bgcolor = cAlt)
    table.cell(t, 1, 2, str.tostring(math.round(zScore * 100) / 100.0) + "σ · " + band, text_color = math.abs(zScore) >= stretchZ ? #ffd166 : cTxt, text_size = size.small, bgcolor = cAlt)
    table.cell(t, 0, 3, "Acceleration", text_color = cDim, text_size = size.small, bgcolor = cSub)
    table.cell(t, 1, 3, accel, text_color = cTxt, text_size = size.small, bgcolor = cSub)
    string h3 = bias3 > 0 ? "▲" : bias3 < 0 ? "▼" : "·"
    string h5 = bias5 > 0 ? "▲" : bias5 < 0 ? "▼" : "·"
    string h15 = bias15 > 0 ? "▲" : bias15 < 0 ? "▼" : "·"
    color hCol = htfStack > 0 ? uiBull : htfStack < 0 ? uiBear : cDim
    table.cell(t, 0, 4, "VWAP 3/5/15×", text_color = cDim, text_size = size.small, bgcolor = cAlt, tooltip = "Price vs a rolling VWAP at 3× (" + tf3 + "), 5× (" + tf5 + ") and 15× (" + tf15 + ") your chart timeframe. All up = aligned higher-TF support.")
    table.cell(t, 1, 4, not useHTF ? "off" : (h3 + " " + h5 + " " + h15), text_color = not useHTF ? cDim : hCol, text_size = size.small, bgcolor = cAlt)
    table.cell(t, 0, 5, "Cross follow-through", text_color = cDim, text_size = size.small, bgcolor = cSub, tooltip = "Past-only: how often a decayed×anchored cross was followed by a " + str.tostring(calMoveATR) + "x ATR move within " + str.tostring(calHorizon) + " bars. Wilson 95% CI.")
    table.cell(t, 1, 5, ccTxt, text_color = ccTot < 5 ? cDim : cTxt, text_size = size.small, bgcolor = cSub)
    table.cell(t, 0, 6, "Stretch reversion", text_color = cDim, text_size = size.small, bgcolor = cAlt, tooltip = "Past-only: how often a ±" + str.tostring(stretchZ) + "σ stretch reverted toward fair value within the horizon. Wilson 95% CI.")
    table.cell(t, 1, 6, srTxt, text_color = srTot < 5 ? cDim : cTxt, text_size = size.small, bgcolor = cAlt)
    table.cell(t, 0, 7, "Anchored VWAP", text_color = cDim, text_size = size.small, bgcolor = cSub)
    table.cell(t, 1, 7, str.tostring(vwap, format.mintick), text_color = cTxt, text_size = size.small, bgcolor = cSub)
    table.cell(t, 0, 8, "1σ", text_color = cDim, text_size = size.small, bgcolor = cAlt)
    table.cell(t, 1, 8, str.tostring(sigma, format.mintick), text_color = cTxt, text_size = size.small, bgcolor = cAlt)

// ───────────────────────────── IDENTITY STRIP ──────────────────────────────
var table idTbl = table.new(position.bottom_center, 1, 1)
if showId and barstate.islast
    table.cell(idTbl, 0, 0, "AVWAP-C  /  " + syminfo.ticker + "  " + timeframe.period + "  /  " + anchorMode, text_color = cDim, text_size = size.small, text_halign = text.align_center, bgcolor = color.new(cPanel, 20))

// ───────────────────────────── ALERTS ──────────────────────────────────────
alertcondition(crossUp, "AVWAP bullish cross", "Decayed VWAP crossed ABOVE anchored VWAP")
alertcondition(crossDn, "AVWAP bearish cross", "Decayed VWAP crossed BELOW anchored VWAP")
alertcondition(stretchUp, "Stretched above +σ", "Price stretched above the upper band")
alertcondition(stretchDn, "Stretched below -σ", "Price stretched below the lower band")

// ───────────────────────────── EXP_* EXPORTS ───────────────────────────────
float ccRate = ccTot > 0 ? ccHit / float(ccTot) : na
float srRate = srTot > 0 ? srHit / float(srTot) : na
int sigState = crossUp ? 1 : crossDn ? -1 : 0
int regCode = trending ? 2 : er < 0.2 ? 0 : 1
plot(vwap,                "EXP_AnchoredVWAP", color = color.new(color.gray, 100), display = display.data_window)
plot(sigma,               "EXP_Sigma",        color = color.new(color.gray, 100), display = display.data_window)
plot(zScore,              "EXP_ZScore",       color = color.new(color.gray, 100), display = display.data_window)
plot(spread,              "EXP_Spread",       color = color.new(color.gray, 100), display = display.data_window)
plot(slopeDelta,          "EXP_SlopeDelta",   color = color.new(color.gray, 100), display = display.data_window)
plot(sigState,            "EXP_SignalState",  color = color.new(color.gray, 100), display = display.data_window)
plot(regCode,             "EXP_Regime",       color = color.new(color.gray, 100), display = display.data_window)
plot(useHTF ? bias3 : na, "EXP_VWAP3x",   color = color.new(color.gray, 100), display = display.data_window)
plot(useHTF ? bias5 : na, "EXP_VWAP5x",   color = color.new(color.gray, 100), display = display.data_window)
plot(useHTF ? bias15 : na, "EXP_VWAP15x", color = color.new(color.gray, 100), display = display.data_window)
plot(nz(ccRate, -1),      "EXP_CrossRate",    color = color.new(color.gray, 100), display = display.data_window)
plot(nz(srRate, -1),      "EXP_ReversionRate",color = color.new(color.gray, 100), display = display.data_window)
````

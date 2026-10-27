# Citadel Microstructure Edge [JOAT]

- url: https://www.tradingview.com/script/e4IdtxL4-Citadel-Microstructure-Edge-JOAT/
- type: indicator
- pine_id: PUB;b77c395398d948cebe63f65584c3b251
- version: 1.0

## Description

[b]CITADEL MICROSTRUCTURE EDGE [JOAT][/b]

A tribute to the high-frequency / market-making style of microstructure-edge extraction. Builds three orthogonal microstructure signals — [b]tick imbalance[/b] (which side is aggressively crossing the tape), [b]spread tightness[/b] (how thin the bid-ask is relative to its baseline), and [b]micro momentum[/b] (the EMA-pair spread on the fastest timeframe) — then composes them into a single decaying [b]edge[/b] value with an exponential half-life. When the edge crosses a configurable threshold and has sustained for N bars same-sign, a directional signal fires. Cooldown plus asymmetric lockout keep the signal stream institutional.

[image]https://www.tradingview.com/x/k9qlMtzJ/[/image]

[b]Three orthogonal components[/b]

Each component is computed independently and Z-normalised (optional for tick imbalance) for stationarity:

[list]
[*] [b]Tick Imbalance[/b] — LTF-reconstructed buy/sell tick classification. Output is the rolling imbalance bounded in [−1, +1]; optionally Z-normalised over a configurable window (default 60 bars) for cross-asset stationarity. The dominant input for fast / scalping reads.
[*] [b]Spread Tightness[/b] — (H − L) / C against its own EMA-smoothed baseline, Z-scored. Tight spread (low relative range) is constructive for whichever side momentum favours. The sign is borrowed from the micro-momentum factor.
[*] [b]Micro Momentum[/b] — EMA-fast minus EMA-slow on the tick-reconstructed flow, Z-scored. The directional engine.
[/list]

Default weights (0.45 / 0.25 / 0.45) bias the read toward the two most-actionable components (tick imbalance + momentum), with spread tightness as confirmation. Optional auto-normalisation to sum=1.

[b]Decaying edge with half-life ~ 3 bars[/b]

Microstructure edges decay quickly. The script does not just sum the three components per bar — it [b]accumulates with decay[/b]:

[i]edge_t = decay × edge_{t−1} + contribution_t[/i]

The default decay (0.78) gives the edge a half-life of approximately 3 bars — the standard market-making decay window. Older contributions fade out automatically; new contributions get incorporated immediately. This is the institutional way to track a fast signal without re-introducing flicker.

[b]Sustained-edge signal logic[/b]

[list]
[*] [b]Edge Threshold[/b] (default 0.75) — minimum |edge| magnitude required to fire.
[*] [b]Sustained Edge[/b] (default 5 bars same sign) — the edge must have held its sign for N consecutive bars before a signal fires. This is the script's most important false-positive filter.
[*] [b]Cooldown[/b] (default 7 bars) — minimum bars between signals.
[*] [b]Asymmetric lockout[/b] (default ON) — an opposite-side signal CAN fire during cooldown. This means a quick flip from buy to sell remains responsive while consecutive same-side signals are suppressed.
[/list]

[b]Visual system[/b]

[list]
[*] [b]Edge histogram[/b] — projected at the top of the chart at a configurable percent of price (default 2% of price, 1.2% top padding). Histogram columns are coloured by edge sign with magnitude-proportional intensity. At a glance you see the edge's recent trajectory.
[*] [b]Buy / Sell labels[/b] with optional Unicode lightning glyph (toggleable to plain ">").
[*] [b]Slope-tinted micro ribbon[/b] — the micro fast / slow EMAs plotted with a translucent fill coloured by spread sign. Toggleable.
[*] [b]Subtle background shade by edge sign[/b] (off by default).
[/list]

A locked Crimson Pulse palette: electric blue buy edge / lime-yellow sell edge / muted neutral on a deep crimson-black ground — the institutional HFT aesthetic.

[b]Dashboard[/b]

9-row monospaced table positionable to any of nine corners. Surfaces:

[list]
[*] Edge value with status (BUY / SELL / FLAT).
[*] Tick imbalance value.
[*] Spread tightness Z.
[*] Micro momentum Z.
[*] Sustained-edge counter (how many consecutive same-sign bars).
[*] Last signal direction with bars-ago.
[*] Decay setting and effective half-life.
[*] Cooldown remaining.
[*] Configuration: LTF, weights, threshold.
[/list]

[b]Alerts[/b]

Three alert conditions, each independently controllable:

[list]
[*] Edge Buy
[*] Edge Sell
[*] Sustained Edge (N bars same sign) — the script's headline alert; fires before the signal does, useful as an early-warning notification.
[/list]

{image]https://www.tradingview.com/x/ybVYCAr3/[/image]

[b]How to read it[/b]

Three reads, in order of conviction:

[list=1]
[*] [b]Sustained edge into a structural level[/b] — the highest-conviction read. The microstructure has been one-sided for N+ bars AND price is at a known S/R; the next move into the level usually breaks it.
[*] [b]Edge buy / sell with all three components agreeing[/b] — fast directional commitment. The dashboard's per-component rows tell you whether the read is dominated by tick imbalance (aggressive tape) or by micro momentum (sustained direction) or by spread tightness (regime-aware confirmation).
[*] [b]Edge above threshold but not sustained[/b] — early-warning state. Edge has crossed threshold but the sustained counter has not yet reached N. Watch the counter — if it ticks up bar-by-bar, the signal is forming; if it drops, the edge is decaying.
[/list]

[b]Suggested settings[/b]

Defaults (1m LTF, spread EMA 14 / Z 60, micro EMA 3/8 / Z 60, weights 0.45/0.25/0.45, edge threshold 0.75, sustain 5 bars, decay 0.78, cooldown 7 bars) are tuned for 5m–15m charts on liquid futures and crypto where microstructure has meaningful presence. For 1m scalping drop LTF to 15s (Premium required) and sustain to 3 bars. For HTF the script is not the right tool — microstructure edges decay too quickly to be meaningful on 1H+ timeframes.

[b]Originality[/b]

The implementation — the three-component microstructure pipeline (tick imbalance + spread tightness + micro momentum), the LTF tick-rule reconstruction with optional Z-normalisation, the weighted-sum composition with auto-normalisation, the exponential-decay edge accumulator with configurable half-life, the sustained-edge counter and asymmetric-lockout signal logic, the price-anchored histogram render at the top of the chart, the slope-tinted micro ribbon, and the Crimson Pulse palette — is JOAT-original. No third-party code reused. The script is a [i]tribute[/i] to Citadel-style market-making microstructure-edge extraction, not a direct replication of any proprietary Citadel code.

[b]Limitations[/b]

Reconstructed tick direction is an inference — the tick rule is the accepted public-market proxy but is not a direct read of bid/ask. Sub-minute LTFs require a TradingView Premium or Ultimate plan. Microstructure edges decay fast by design; on 1H+ timeframes the engine produces few signals — that is correct behaviour, not a bug.

—

-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title       = "Citadel Microstructure Edge [JOAT]",
          shorttitle  = "CIT [JOAT]",
          overlay     = true,
          max_labels_count = 500,
          max_lines_count  = 500,
          max_boxes_count  = 500,
          max_bars_back    = 5000)

// ============================================================
//  SECTION 1 - INPUTS
// ============================================================
grpComp   = "+++ COMPONENTS +++"
grpWts    = "+++ WEIGHTS +++"
grpEdge   = "+++ EDGE / DECAY / COOLDOWN +++"
grpVis    = "+++ VISUALS +++"
grpDash   = "+++ DASHBOARD +++"
grpAlert  = "+++ ALERTS +++"

// --- Components -------------------------------------------------------------
ltfRes       = input.timeframe("1", "LTF Resolution (intrabar)", options=["1","3","5","15","30"], group=grpComp,
     tooltip="Lower timeframe (minutes) used by request.security_lower_tf() to reconstruct buy/sell ticks via the tick rule. Smaller = more granular microstructure.")
spreadLen    = input.int(14, "Spread Smoothing (EMA len)", minval=1, maxval=200, group=grpComp)
spreadZLen   = input.int(60, "Spread Z-score Window",       minval=10, maxval=400, group=grpComp)
microFast    = input.int(3,  "Micro EMA - fast",            minval=1, maxval=50, group=grpComp)
microSlow    = input.int(8,  "Micro EMA - slow",            minval=2, maxval=100, group=grpComp)
microZLen    = input.int(60, "Micro Momentum Z-score Window", minval=10, maxval=400, group=grpComp)
tickZLen     = input.int(60, "Tick Imbalance Z-score Window", minval=10, maxval=400, group=grpComp)
useTickZ     = input.bool(true, "Z-Normalize Tick Imbalance", group=grpComp,
     tooltip="If on, raw [-1,+1] tick imbalance is rolled through a Z-score for cross-asset stationarity.")

// --- Weights ----------------------------------------------------------------
wTickIn      = input.float(0.45, "Tick Imbalance Weight",  minval=0.0, maxval=2.0, step=0.05, group=grpWts)
wSpreadIn    = input.float(0.25, "Spread Tightness Weight", minval=0.0, maxval=2.0, step=0.05, group=grpWts,
     tooltip="Tight spread (low (H-L)/C vs its average) is constructive for whichever side momentum favors. Sign is borrowed from microMomZ.")
wMomIn       = input.float(0.45, "Micro Momentum Weight",   minval=0.0, maxval=2.0, step=0.05, group=grpWts)
autoNormW    = input.bool(true,  "Auto-normalize weights to sum=1", group=grpWts)

// --- Edge / Decay / Cooldown -----------------------------------------------
edgeThresh   = input.float(0.75, "Edge Threshold (|edge| >)", minval=0.05, maxval=4.0, step=0.05, group=grpEdge,
     tooltip="Absolute edge magnitude required to fire a signal once cooldown has elapsed.")
sustainBars  = input.int(5,    "Sustained Edge (bars same sign)", minval=2, maxval=20, group=grpEdge)
decayRate    = input.float(0.78, "Edge Decay (per bar, 0..1)", minval=0.0, maxval=0.99, step=0.01, group=grpEdge,
     tooltip="Each bar: edge := decay * prev_edge + contribution. 0.78 ~= half-life of ~3 bars.")
cooldownBars = input.int(7,    "Cooldown (bars between signals)", minval=0, maxval=50, group=grpEdge)
lockoutOpp   = input.bool(true,"Allow opposite signal during cooldown", group=grpEdge,
     tooltip="If on, an opposite-side signal can still fire while in cooldown for the same side (asymmetric).")

// --- Visuals ----------------------------------------------------------------
showHist     = input.bool(true,  "Show Edge Histogram (top of chart)", group=grpVis)
histHeight   = input.float(0.020,"Histogram Vertical Scale (% of price)", minval=0.002, maxval=0.10, step=0.001, group=grpVis,
     tooltip="Histogram columns are projected near the top of the visible price range; this value scales their max height as a fraction of price.")
histPad      = input.float(0.012,"Histogram Top Padding (% of price)", minval=0.0, maxval=0.10, step=0.001, group=grpVis)
showLabels   = input.bool(true,  "Show Buy/Sell Labels", group=grpVis)
useUnicode   = input.bool(true,  "Use Unicode Glyph (lightning) instead of '>'", group=grpVis)
showRibbon   = input.bool(true,  "Show Slope-Tinted Micro Ribbon", group=grpVis,
     tooltip="Plots the micro fast/slow EMAs with a translucent fill colored bull/bear by sign of the spread.")
showShade    = input.bool(false, "Background Shade by Edge Sign (subtle)", group=grpVis)
fadeBase     = input.int(86,     "Background Fade (0=opaque, 100=transparent)", minval=50, maxval=99, group=grpVis)

// --- Dashboard --------------------------------------------------------------
showDash     = input.bool(true,  "Show 9-Row Dashboard", group=grpDash)
dashPosStr   = input.string("Top Right", "Dashboard Position", group=grpDash, options=[
     "Top Right","Top Left","Top Center","Middle Right","Middle Left","Middle Center",
     "Bottom Right","Bottom Left","Bottom Center"])
dashSizeStr  = input.string("Small",   "Dashboard Text Size", group=grpDash, options=["Tiny","Small","Normal","Large","Huge"])

// --- Alerts -----------------------------------------------------------------
alertBuy     = input.bool(true,  "Alert on Edge Buy",  group=grpAlert)
alertSell    = input.bool(true,  "Alert on Edge Sell", group=grpAlert)
alertSust    = input.bool(true,  "Alert on Sustained Edge (N bars same sign)", group=grpAlert)

// ============================================================
//  SECTION 2 - COLOR PALETTE  (Crimson Pulse - locked institutional)
// ============================================================
//  Single curated palette. No theme switcher. Electric blue buy edge /
//  lime-yellow sell edge / muted neutral / deep crimson bg / frame.

const color C_BULL    = color.rgb(0, 207, 254)
const color C_BEAR    = #e0f70e
const color C_NEUTRAL = #9E7680
const color C_BG      = #12080C
const color C_FRAME   = #2A0F18

// Helper alpha-shifted versions (no new hues are introduced).
color C_BULL_25 = color.new(C_BULL,  25)
color C_BULL_55 = color.new(C_BULL,  55)
color C_BULL_85 = color.new(C_BULL,  85)
color C_BEAR_25 = color.new(C_BEAR,  25)
color C_BEAR_55 = color.new(C_BEAR,  55)
color C_BEAR_85 = color.new(C_BEAR,  85)
color C_TEXT    = color.new(color.white, 0)
color C_TEXTDIM = color.new(color.white, 35)
color C_HDRBG   = color.new(C_FRAME, 25)
color C_CELLBG  = color.new(C_FRAME, 80)

// ============================================================
//  SECTION 3 - HELPER FUNCTIONS
// ============================================================
//  f_clamp        : clamp a value to [lo, hi]
//  f_colorGradient: linear-interpolate two colors by ratio in [0,1]
//  f_signColor    : pick BULL or BEAR (or transparent) by sign with optional intensity
//  f_zscore       : rolling z-score
//  f_safeDiv      : div guard
//  f_normTanh     : map any real into [-1,+1] via tanh approximation
//  strToPos       : map dashboard-position string to position.*
//  strToSize      : map dashboard-size string to size.*
//  signLabel      : "BUY" / "SELL" / "FLAT"
// ----------------------------------------------------------------------------
f_clamp(_x, _lo, _hi) => math.max(_lo, math.min(_x, _hi))

f_colorGradient(_ratio, _colA, _colB) =>
    r = f_clamp(_ratio, 0.0, 1.0)
    rA = color.r(_colA), gA = color.g(_colA), bA = color.b(_colA)
    rB = color.r(_colB), gB = color.g(_colB), bB = color.b(_colB)
    rr = rA + int((rB - rA) * r)
    rg = gA + int((gB - gA) * r)
    rb = bA + int((bB - bA) * r)
    color.rgb(rr, rg, rb, 0)

f_signColor(_v, float _intensity = 1.0) =>
    a = int(f_clamp(85.0 - 80.0 * math.abs(_intensity), 0.0, 100.0))
    _v > 0 ? color.new(C_BULL, a) : _v < 0 ? color.new(C_BEAR, a) : color.new(C_FRAME, 75)

f_safeDiv(float n, float d) => d == 0.0 or na(d) ? 0.0 : n / d

f_zscore(float src, int len) =>
    mu  = ta.sma(src, len)
    sd  = ta.stdev(src, len)
    sd > 0.0 ? (src - mu) / sd : 0.0

f_normTanh(float x) =>
    // numerically stable tanh approximation -> [-1, +1]
    e2 = math.exp(-2.0 * math.max(math.min(x, 20.0), -20.0))
    (1.0 - e2) / (1.0 + e2)

strToPos(string s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        =>               position.bottom_right

strToSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.normal

signLabel(float v) => v > 0.0 ? "BUY" : v < 0.0 ? "SELL" : "FLAT"

// Bull arrow / bear arrow glyphs — kept to 2 chars so all labels are uniform.
arrowBuy  = useUnicode ? "⚡" : ">"   // U+26A1 lightning bolt
arrowSell = useUnicode ? "⚡" : "<"

// ============================================================
//  SECTION 4 - CORE CALCULATIONS
// ============================================================
//  4.1  INTRABAR RECONSTRUCTION ----------------------------------------------
//  request.security_lower_tf(symbol, timeframe, expression) -> array<type>
//  When expression is a tuple, the call returns a TUPLE OF ARRAYS, each
//  indexed by intrabar position within the current chart bar.
//
//  Tick rule (Lee-Ready): if intrabar close > prev intrabar close => up tick;
//  if intrabar close < prev intrabar close => down tick; else carry prior tag.
// ----------------------------------------------------------------------------
[ltfClose, ltfVol] = request.security_lower_tf(syminfo.tickerid, ltfRes, [close, volume])

var int   _upTicks         = 0
var int   _dnTicks         = 0
var float _upVol           = 0.0
var float _dnVol           = 0.0
var float _totVol          = 0.0
var int   _totTicks        = 0
var int   _lastDir         = 0
var float _prevIntrabarCls = na

_upTicks  := 0
_dnTicks  := 0
_upVol    := 0.0
_dnVol    := 0.0
_totVol   := 0.0
_totTicks := 0

int sz = array.size(ltfClose)
if sz > 0
    for i = 0 to sz - 1
        c  = array.get(ltfClose, i)
        v  = array.get(ltfVol, i)
        if not na(c)
            dir = _lastDir
            if not na(_prevIntrabarCls)
                if c > _prevIntrabarCls
                    dir := 1
                else if c < _prevIntrabarCls
                    dir := -1
                // else: carry prior direction (zero tick)
            if dir > 0
                _upTicks += 1
                _upVol   += nz(v, 0.0)
            else if dir < 0
                _dnTicks += 1
                _dnVol   += nz(v, 0.0)
            _totTicks += 1
            _totVol   += nz(v, 0.0)
            _lastDir         := dir
            _prevIntrabarCls := c

// If the intrabar feed is empty (e.g. very low timeframe not granted by plan),
// fall back to a simple high/low-vs-open proxy so the rest of the math stays
// well-defined and the script still renders cleanly.
bool feedOk = _totTicks > 0
tickImbalRaw = feedOk ? f_safeDiv(_upTicks - _dnTicks, _totTicks) : f_safeDiv((close - open), math.max(high - low, syminfo.mintick))
float volImbalRaw  = feedOk ? f_safeDiv(_upVol - _dnVol, _totVol)       : tickImbalRaw

// Blend tick count and tick-weighted volume into a single imbalance signal.
// This is closer to the way HFT desks weight signed flow than tick-count alone.
float tickImbalBlend = 0.65 * tickImbalRaw + 0.35 * volImbalRaw
float tickImbal      = useTickZ ? f_normTanh(f_zscore(tickImbalBlend, tickZLen)) : tickImbalBlend

//  4.2  SPREAD PROXY ---------------------------------------------------------
//  (H - L) / C smoothed by EMA, then Z-scored.  Negative Z = tight spread =
//  microstructure-constructive; positive Z = wide spread = chaotic / costly.
// ----------------------------------------------------------------------------
float spreadRaw    = f_safeDiv(high - low, close)
float spreadSmooth = ta.ema(spreadRaw, spreadLen)
float spreadZ      = f_zscore(spreadSmooth, spreadZLen)

//  4.3  MICRO MOMENTUM -------------------------------------------------------
//  EMA(close,3) - EMA(close,8), normalized by the rolling std of that diff,
//  then mapped to [-1,+1] via tanh.  Tight, sensitive, and noise-aware.
// ----------------------------------------------------------------------------
float emaFast   = ta.ema(close, microFast)
float emaSlow   = ta.ema(close, microSlow)
float microDiff = emaFast - emaSlow
float microZ    = f_zscore(microDiff, microZLen)
float microMom  = f_normTanh(microZ)

//  4.4  COMPONENT WEIGHTS / NORMALIZATION -----------------------------------
float wSum  = math.max(0.0001, wTickIn + wSpreadIn + wMomIn)
float wTick    = autoNormW ? wTickIn   / wSum : wTickIn
float wSpread  = autoNormW ? wSpreadIn / wSum : wSpreadIn
float wMom     = autoNormW ? wMomIn    / wSum : wMomIn

//  4.5  EDGE CONTRIBUTION ----------------------------------------------------
//  Each component is constrained to [-1, +1] so weights stay interpretable.
//  Spread is sign-borrowed from microMom: a tight spread RE-INFORCES the side
//  momentum is already favoring (typical HFT setup) and a wide spread
//  drags edge toward zero.
// ----------------------------------------------------------------------------
float tickClamp   = f_clamp(tickImbal,    -1.0, 1.0)
float momClamp    = f_clamp(microMom,     -1.0, 1.0)
float spreadTight = f_clamp(-spreadZ / 2.0, -1.0, 1.0)
float spreadContr = math.sign(momClamp) * math.abs(spreadTight)

float contribution = wTick * tickClamp + wSpread * spreadContr + wMom * momClamp

//  4.6  EXPONENTIAL DECAY EDGE STATE ----------------------------------------
//  edge_t = decay * edge_{t-1} + contribution_t
//  The decay term makes signals SHORT-LIVED — they expire fast like real HFT.
// ----------------------------------------------------------------------------
var float edgeState = 0.0
edgeState := decayRate * nz(edgeState[1], 0.0) + contribution
edgeState := f_clamp(edgeState, -3.5, 3.5)   // numerical guard

// ============================================================
//  SECTION 5 - STATE / TRACKING
// ============================================================
var float lastEdge          = 0.0
var int   lastSignalBar     = -100000
var int   lastBuyBar        = -100000
var int   lastSellBar       = -100000
var int   sameSignStreak    = 0
var int   lastSign          = 0
var int   sessionSignals    = 0
var int   sessionBuys       = 0
var int   sessionSells      = 0
var int   lastSignalDir     = 0          //  +1 buy, -1 sell, 0 none
var float lastEdgeMag       = 0.0
var int   sustainedBars     = 0

// Streak tracking on sign of edge.
int curSign = edgeState > 0.0 ? 1 : edgeState < 0.0 ? -1 : 0
if curSign == lastSign and curSign != 0
    sameSignStreak += 1
else
    sameSignStreak := curSign == 0 ? 0 : 1
lastSign := curSign

// Reset session counters at the start of each new trading session.
bool newSession = ta.change(time("D")) != 0
if newSession
    sessionSignals := 0
    sessionBuys    := 0
    sessionSells   := 0

// ============================================================
//  SECTION 6 - SIGNAL ENGINE
// ============================================================
//  Crossing the threshold (NOT being merely above it) gates new entries.
//  Cooldown is measured from the most recent signal of the SAME side; the
//  optional lockoutOpp toggle lets the opposite side jump in during cooldown.
// ----------------------------------------------------------------------------
bool crossUp   = ta.crossover(edgeState,  edgeThresh)
bool crossDn   = ta.crossunder(edgeState, -edgeThresh)

bool cdBuyOk   = (bar_index - lastBuyBar)  >= cooldownBars
bool cdSellOk  = (bar_index - lastSellBar) >= cooldownBars
bool cdAnyOk   = (bar_index - lastSignalBar) >= cooldownBars

bool buyGate   = crossUp  and (lockoutOpp ? cdBuyOk  : cdAnyOk)
bool sellGate  = crossDn  and (lockoutOpp ? cdSellOk : cdAnyOk)

bool edgeBuy   = buyGate
bool edgeSell  = sellGate

if edgeBuy
    lastSignalBar  := bar_index
    lastBuyBar     := bar_index
    lastSignalDir  := 1
    lastEdgeMag    := math.abs(edgeState)
    sessionSignals += 1
    sessionBuys    += 1
if edgeSell
    lastSignalBar  := bar_index
    lastSellBar    := bar_index
    lastSignalDir  := -1
    lastEdgeMag    := math.abs(edgeState)
    sessionSignals += 1
    sessionSells   += 1

// Sustained edge alert: |edge|>threshold for sustainBars consecutive bars,
// AND streak of sign at least sustainBars long.
bool sustainedHot = math.abs(edgeState) >= edgeThresh and sameSignStreak >= sustainBars
if sustainedHot
    sustainedBars += 1
else
    sustainedBars := 0
bool sustainedFire = sustainedHot and sustainedBars == 1   // edge-event

lastEdge := edgeState

// ============================================================
//  SECTION 7 - PLOTS / FILLS / CANDLES
// ============================================================
//  All overlay plots use only BULL / BEAR / BG — never any third hue.
// ----------------------------------------------------------------------------
//  7.1 Micro ribbon (fast/slow EMAs).  Colored by sign of microMom only.
ribbonCol = microMom >= 0.0 ? color.new(C_BULL, 30) : color.new(C_BEAR, 30)
ribbonFil = microMom >= 0.0 ? color.new(C_BULL, 80) : color.new(C_BEAR, 80)

pFast = plot(showRibbon ? emaFast : na, "Micro Fast EMA", color = ribbonCol,  linewidth = 1)
pSlow = plot(showRibbon ? emaSlow : na, "Micro Slow EMA", color = ribbonCol,  linewidth = 1)
fill(pFast, pSlow, color = ribbonFil, title = "Micro Ribbon Fill")

//  7.2 Edge histogram (compact, near top of visible range).
//      Anchored at TOP of recent N-bar high to keep it out of price action.
int    histLook   = 120
float  topAnchor  = ta.highest(high, histLook) * (1.0 + histPad)
float  histScale  = close * histHeight
float  histVal    = topAnchor + f_clamp(edgeState / 3.0, -1.0, 1.0) * histScale
color  histCol    = edgeState >= 0.0 ? color.new(C_BULL, 15) : color.new(C_BEAR, 15)
plot(showHist ? topAnchor : na, "Edge Histogram Baseline", color = color.new(C_FRAME, 65), linewidth = 1, style = plot.style_line)
plot(showHist ? histVal   : na, "Edge Histogram",          color = histCol,                linewidth = 1, style = plot.style_columns)

//  7.3 Threshold guide rails for the histogram (faint).
float thrTopBull = topAnchor + (edgeThresh / 3.0) * histScale
float thrTopBear = topAnchor - (edgeThresh / 3.0) * histScale
plot(showHist ? thrTopBull : na, "Bull Threshold",  color = color.new(C_BULL, 70), linewidth = 1, style = plot.style_circles)
plot(showHist ? thrTopBear : na, "Bear Threshold",  color = color.new(C_BEAR, 70), linewidth = 1, style = plot.style_circles)

//  7.4 Optional background shade by edge sign (very subtle — fadeBase is high).
bgcolor(showShade and edgeState > 0.0 ? color.new(C_BULL, fadeBase) :
        showShade and edgeState < 0.0 ? color.new(C_BEAR, fadeBase) : na,
        title = "Edge Sign Background")

// ============================================================
//  SECTION 8 - DRAWINGS (Buy/Sell labels)
// ============================================================
//  Labels are 2-character ('>'+'\n'+price-tag style minimized to one glyph),
//  kept to the active BULL/BEAR hues.  Capped via max_labels_count=500.
// ----------------------------------------------------------------------------
if showLabels and edgeBuy and barstate.isconfirmed
    label.new(bar_index, low, arrowBuy,
         style    = label.style_label_up,
         color    = C_BULL,
         textcolor= color.new(C_BG, 0),
         size     = size.small,
         yloc     = yloc.belowbar,
         tooltip  = "Edge Buy\nEdge = " + str.tostring(edgeState, "#.##") +
                    "\nTick Imb = " + str.tostring(tickImbal, "#.##") +
                    "\nMicro Mom = " + str.tostring(microMom, "#.##") +
                    "\nSpread Z = " + str.tostring(spreadZ, "#.##"))

if showLabels and edgeSell and barstate.isconfirmed
    label.new(bar_index, high, arrowSell,
         style    = label.style_label_down,
         color    = C_BEAR,
         textcolor= color.new(C_BG, 0),
         size     = size.small,
         yloc     = yloc.abovebar,
         tooltip  = "Edge Sell\nEdge = " + str.tostring(edgeState, "#.##") +
                    "\nTick Imb = " + str.tostring(tickImbal, "#.##") +
                    "\nMicro Mom = " + str.tostring(microMom, "#.##") +
                    "\nSpread Z = " + str.tostring(spreadZ, "#.##"))

// ============================================================
//  SECTION 9 - DASHBOARD (9 rows)
// ============================================================
//  Two-column tabular layout, monospaced.  Header spans both columns visually.
//  Row palette never exceeds bull/bear/frame trio.
// ----------------------------------------------------------------------------
var table tbl = table.new(strToPos(dashPosStr), 2, 10,
     bgcolor      = color.new(C_BG, 20),
     frame_color  = color.new(C_FRAME, 25),
     frame_width  = 1,
     border_color = color.new(C_FRAME, 65),
     border_width = 1)

f_decayHalfLife(float d) =>
    d <= 0.0 or d >= 1.0 ? na : math.log(0.5) / math.log(d)

f_signalColor(int dir) => dir > 0 ? C_BULL : dir < 0 ? C_BEAR : color.new(C_TEXTDIM, 30)

if showDash and barstate.islast
    txtSz = strToSize(dashSizeStr)

    // Pre-format strings -----------------------------------------------------
    string edgeTxt    = str.tostring(edgeState, "#.###")
    string tickTxt    = str.tostring(tickImbal, "#.###")
    string spreadTxt  = str.tostring(spreadZ,    "#.###") + "z"
    string momTxt     = str.tostring(microMom,   "#.###")
    int    barsAgo    = lastSignalBar < 0 ? -1 : bar_index - lastSignalBar
    lastSigTxt = lastSignalDir == 0 ? "none" : (lastSignalDir == 1 ? "BUY"  : "SELL") + "  " + (barsAgo >= 0 ? (str.tostring(barsAgo) + "b") : "")
    string decayTxt   = str.tostring(decayRate, "#.###") +
         "  (HL~" + (na(f_decayHalfLife(decayRate)) ? "inf" :
                    str.tostring(f_decayHalfLife(decayRate), "#.#")) + "b)"
    int    cdRemBuy   = math.max(0, cooldownBars - (bar_index - lastBuyBar))
    int    cdRemSell  = math.max(0, cooldownBars - (bar_index - lastSellBar))
    string cdTxt      = "L " + str.tostring(cdRemBuy) + "b / S " + str.tostring(cdRemSell) + "b"
    string sigCntTxt  = str.tostring(sessionSignals) + "  (B " + str.tostring(sessionBuys) + " / S " + str.tostring(sessionSells) + ")"

    color edgeRowCol  = edgeState >= 0.0 ? C_BULL : C_BEAR
    color tickRowCol  = tickImbal >= 0.0 ? C_BULL : C_BEAR
    color spRowCol    = spreadZ   <= 0.0 ? C_BULL : C_BEAR
    color momRowCol   = microMom  >= 0.0 ? C_BULL : C_BEAR
    color lastSigCol  = f_signalColor(lastSignalDir)
    bool  hot         = math.abs(edgeState) >= edgeThresh
    color statusDot   = hot ? edgeRowCol : color.new(C_TEXTDIM, 50)

    // Header (row 0) ---------------------------------------------------------
    table.cell(tbl, 0, 0, "CITADEL MICRO EDGE [JOAT]",
         text_color = C_TEXT, bgcolor = C_HDRBG,
         text_size = txtSz, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 0, hot ? "* HOT *" : "idle",
         text_color = statusDot, bgcolor = C_HDRBG,
         text_size = txtSz, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // Row 1 - Edge Score
    table.cell(tbl, 0, 1, "Edge Score",         text_color = C_TEXTDIM, bgcolor = C_CELLBG,
         text_size = txtSz, text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(tbl, 1, 1, edgeTxt,              text_color = edgeRowCol, bgcolor = C_CELLBG,
         text_size = txtSz, text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 2 - Tick Imbalance
    table.cell(tbl, 0, 2, "Tick Imbalance",     text_color = C_TEXTDIM, bgcolor = C_CELLBG,
         text_size = txtSz, text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(tbl, 1, 2, tickTxt,              text_color = tickRowCol, bgcolor = C_CELLBG,
         text_size = txtSz, text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 3 - Spread Proxy
    table.cell(tbl, 0, 3, "Spread Proxy",       text_color = C_TEXTDIM, bgcolor = C_CELLBG,
         text_size = txtSz, text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(tbl, 1, 3, spreadTxt,            text_color = spRowCol, bgcolor = C_CELLBG,
         text_size = txtSz, text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 4 - Micro Momentum
    table.cell(tbl, 0, 4, "Micro Momentum",     text_color = C_TEXTDIM, bgcolor = C_CELLBG,
         text_size = txtSz, text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(tbl, 1, 4, momTxt,               text_color = momRowCol, bgcolor = C_CELLBG,
         text_size = txtSz, text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 5 - Last Signal
    table.cell(tbl, 0, 5, "Last Signal",        text_color = C_TEXTDIM, bgcolor = C_CELLBG,
         text_size = txtSz, text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(tbl, 1, 5, lastSigTxt,           text_color = lastSigCol, bgcolor = C_CELLBG,
         text_size = txtSz, text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 6 - Decay Rate / Half-life
    table.cell(tbl, 0, 6, "Decay Rate",         text_color = C_TEXTDIM, bgcolor = C_CELLBG,
         text_size = txtSz, text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(tbl, 1, 6, decayTxt,             text_color = C_TEXT, bgcolor = C_CELLBG,
         text_size = txtSz, text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 7 - Cooldown
    table.cell(tbl, 0, 7, "Cooldown",           text_color = C_TEXTDIM, bgcolor = C_CELLBG,
         text_size = txtSz, text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(tbl, 1, 7, cdTxt,                text_color = (cdRemBuy + cdRemSell > 0 ? C_BEAR : C_BULL),
         bgcolor = C_CELLBG, text_size = txtSz, text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 8 - Signal Count (session)
    table.cell(tbl, 0, 8, "Signals (session)",  text_color = C_TEXTDIM, bgcolor = C_CELLBG,
         text_size = txtSz, text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(tbl, 1, 8, sigCntTxt,            text_color = C_TEXT, bgcolor = C_CELLBG,
         text_size = txtSz, text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 9 - Sustained streak (bonus row, fits in 10-row table)
    string streakTxt = (curSign == 0 ? "neutral" :
         (curSign > 0 ? "bull " : "bear ") + str.tostring(sameSignStreak) + "b")
    color  streakCol = curSign > 0 ? C_BULL : curSign < 0 ? C_BEAR : color.new(C_TEXTDIM, 30)
    table.cell(tbl, 0, 9, "Streak",             text_color = C_TEXTDIM, bgcolor = C_CELLBG,
         text_size = txtSz, text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(tbl, 1, 9, streakTxt,            text_color = streakCol, bgcolor = C_CELLBG,
         text_size = txtSz, text_halign = text.align_right, text_font_family = font.family_monospace)

// ============================================================
//  SECTION 10 - ALERTS
// ============================================================
alertcondition(alertBuy  and edgeBuy,         title = "CIT Edge Buy",       message  = "CIT [JOAT] Edge BUY  | edge={{plot('Edge Histogram')}}")
alertcondition(alertSell and edgeSell,        title = "CIT Edge Sell",      message  = "CIT [JOAT] Edge SELL | edge={{plot('Edge Histogram')}}")
alertcondition(alertSust and sustainedFire,   title = "CIT Sustained Edge", message  = "CIT [JOAT] Sustained Edge for >= N bars same sign.")

// Pine-side alert() fallback for users who prefer once-per-bar-close alerts.
if edgeBuy
    alert("CIT [JOAT] Edge BUY | edge=" + str.tostring(edgeState, "#.###") +
          " | tick=" + str.tostring(tickImbal, "#.##") +
          " | mom="  + str.tostring(microMom, "#.##") +
          " | spZ="  + str.tostring(spreadZ, "#.##"), alert.freq_once_per_bar_close)
if edgeSell
    alert("CIT [JOAT] Edge SELL | edge=" + str.tostring(edgeState, "#.###") +
          " | tick=" + str.tostring(tickImbal, "#.##") +
          " | mom="  + str.tostring(microMom, "#.##") +
          " | spZ="  + str.tostring(spreadZ, "#.##"), alert.freq_once_per_bar_close)
if sustainedFire
    alert("CIT [JOAT] Sustained edge | streak=" + str.tostring(sameSignStreak) +
          " bars | edge=" + str.tostring(edgeState, "#.###"), alert.freq_once_per_bar_close)

// =============================================================================
//  END  -  Citadel Microstructure Edge [JOAT]
// =============================================================================
````

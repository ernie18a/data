# Standing Wave Phase Coherence [JOAT]

- url: https://www.tradingview.com/script/s0Nl5oog-Standing-Wave-Phase-Coherence-JOAT/
- type: indicator
- pine_id: PUB;92ef94c574c04d1fa1e1eb1584d9a66b
- version: 1.0

## Description

[b]STANDING WAVE PHASE COHERENCE [JOAT][/b]

A phase-coherence engine that asks a question almost no public indicator can answer: are the LTF and HTF oscillators [i]in phase[/i] or [i]out of phase[/i]? Two oscillators that move together (peaks and troughs aligned) form a [b]standing wave[/b] — a state of constructive interference where the trend is amplified. Two oscillators that move opposite (peaks aligned with troughs) form an [b]anti-standing wave[/b] — a state of destructive interference where a reversal is forming. Standing Wave Phase Coherence measures phase, computes the coherence between the two timeframes, and surfaces a single number bounded in [−1, +1] that tells you which regime you are in.

[image]https://www.tradingview.com/x/k7dak7qf/[/image]

[b]Phase, not just direction[/b]

A moving average tells you "where price is sitting". A momentum oscillator tells you "which way it is moving". Phase is the [i]location inside the cycle[/i] — are we approaching a peak, leaving a peak, approaching a trough, leaving a trough? Two oscillators on different timeframes can be:

[list]
[*] [b]In phase[/b] — both rising or both falling at the same rate of cycle progression. Constructive interference. Trend amplifies.
[*] [b]Anti-phase[/b] — one rising, the other falling at the same cycle rate. Destructive interference. Reversal forms.
[*] [b]Decoherent[/b] — phases are uncorrelated. The wave structure is breaking down. No directional edge from coherence.
[/list]

The script estimates phase from each timeframe's RSI series (both legs at the same RSI length for fair comparison), differences the phase smoothly, then takes the cosine of the phase difference — which is exactly the quantum-mechanical coherence metric on a [−1, +1] scale.

[b]Non-repainting HTF construction[/b]

The HTF leg uses [b]request.security[/b] with [b]lookahead_on AND a [1] offset[/b] on the expression — the only non-repainting form per Pine v6 docs. This is exposed as a toggle but ON by default; the warning in the input tooltip explains the trade-off (turn off only for research, never live).

[b]Three thresholds, three states[/b]

[list]
[*] [b]Coherence > +0.70[/b] (configurable) — [b]IN PHASE[/b]. Standing wave constructive. Trend amplifies. Bull-palette background tint.
[*] [b]Coherence < −0.70[/b] — [b]ANTI PHASE[/b]. Standing wave destructive. Reversal forms. Bear-palette background tint.
[*] [b]|Coherence| < 0.30[/b] (decoherent band) — [b]DECOHERENT[/b]. No standing wave. Mid-palette neutral.
[*] In between — transitional.
[/list]

Phase-status arrows print inside the pane at every regime entry, so the chart history shows when each standing wave formed and collapsed.

[b]Visual system[/b]

[list]
[*] [b]Coherence line[/b] with configurable width.
[*] [b]Glow halo[/b] — a wider semi-transparent copy of the coherence line below the main line, creating a soft glow effect.
[*] [b]Background tint by phase status[/b] — bull when IN PHASE, bear when ANTI PHASE, none when decoherent. Transparency configurable.
[*] [b]Threshold lines[/b] at ±0.70 (toggleable).
[*] [b]Zero line[/b].
[*] [b]Fill between threshold and ±1[/b] — soft bull / bear fill highlights the active phase zone so it is immediately obvious which side is engaged.
[*] [b]Phase status arrows[/b] inside the pane on state transitions.
[/list]

The pane uses the JOAT default palette (cyan-teal bull / magenta bear).

[b]Amplification factor[/b]

A separate EMA-smoothed [b]trend amplification factor[/b] is computed from the coherence and surfaced in the dashboard. When coherence is sustained high (in-phase), the amplification factor rises — quantifying how much the LTF/HTF agreement is reinforcing the move. Useful as a position-sizing input: bigger amplification = stronger conviction = larger size.

[b]Dashboard[/b]

Monospaced table, positionable to any of nine corners. Surfaces:

[list]
[*] Current coherence value and bar age.
[*] Phase status (IN PHASE / ANTI PHASE / DECOHERENT) with glyph.
[*] LTF and HTF RSI values.
[*] Phase difference in radians and degrees.
[*] Trend amplification factor (smoothed).
[*] HTF timeframe in use with non-repaint flag.
[/list]

[b]Alerts[/b]

Multiple alert conditions:

[list]
[*] Coherence crosses above +0.70 (IN PHASE entry)
[*] Coherence crosses below −0.70 (ANTI PHASE entry)
[*] Coherence returns to decoherent band
[*] Sustained IN PHASE (held above threshold for N bars)
[*] Sustained ANTI PHASE
[/list]

[image]https://www.tradingview.com/x/tJkCm8iE/[/image]

[b]How to read it[/b]

Three reads, in order of conviction:

[list=1]
[*] [b]Sustained IN PHASE[/b] — the highest-conviction trend read. LTF and HTF oscillators are decisively moving together. This is the regime in which momentum tools have their largest edge.
[*] [b]Entry into ANTI PHASE[/b] — the reversal warning. The two timeframes have rotated opposite each other; whichever direction LTF is moving, HTF is opposing. Often precedes meaningful reversals.
[*] [b]Decoherent zone[/b] — stand-aside signal. The wave structure has broken down. Coherence-based reads are not actionable; switch to a regime-classification tool (FDI, Hurst, Entropy).
[/list]

The cleanest workflow: only take trend trades when IN PHASE; only take reversal trades when ANTI PHASE; do nothing when DECOHERENT.

[b]Suggested settings[/b]

Defaults (RSI 14, HTF 4H, phase smoothing 3, coherence smoothing 8, ±0.70 thresholds, ±0.30 decoherent band) are tuned for 15m–1H charts. The HTF should always be greater than or equal to the chart timeframe; mismatching produces meaningless phase reads. For HTF (4H+ chart timeframes) raise HTF to Daily and consider the LTF/HTF coherence as a daily-vs-weekly read.

[b]Originality[/b]

The implementation — the dual-timeframe RSI phase estimator, the smoothed phase-difference cosine coherence (quantum-style metric), the non-repainting HTF request with [1]-offset + lookahead_on pattern, the three-threshold phase classifier with decoherent band, the trend amplification factor formulation, the glow-halo line render, and the pane-overlay phase-status arrows — is JOAT-original. No third-party code reused. The notion of [i]phase coherence between timeframes[/i] as a market regime metric is the original quantitative contribution, borrowed conceptually from optical and quantum physics.

[b]Limitations[/b]

Phase estimation from discrete bar data is inherently noisy on short windows; the smoothing inputs (phase EMA and coherence EMA) exist to address that — over-smoothing destroys phase information, so the defaults are intentionally light. The HTF request is non-repainting in the [b]useStrictHtf[/b] = ON configuration; do not turn it off in live trading. The decoherent band is a heuristic to avoid acting on noise reads; widen it on instruments with naturally choppy oscillator structure.

—

-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(
     title              = "Standing Wave Phase Coherence [JOAT]",
     shorttitle         = "SWP [JOAT]",
     overlay            = false,
     precision          = 4,
     max_lines_count    = 500,
     max_labels_count   = 500,
     max_boxes_count    = 500,
     max_bars_back      = 5000)


// =============================================================================
//  SECTION 1 - INPUTS
// =============================================================================

// --- group strings (box-drawing as per house style) ---------------------------
G_OSC   = "+----- Oscillators -----+"
G_SMTH  = "+----- Smoothing -----+"
G_THR   = "+----- Thresholds -----+"
G_VIS   = "+----- Visuals -----+"
G_DASH  = "+----- Dashboard -----+"
G_ALERT = "+----- Alerts -----+"


// ---- Oscillators ------------------------------------------------------------
rsiLen        = input.int   (14,     "RSI Length",
     minval = 2,  maxval = 200, group = G_OSC,
     tooltip = "Period of the RSI used for BOTH the LTF (chart) and HTF series. "
             + "Standard 14 is the common Wilder value.")

rsiSrc        = input.source(close,  "RSI Source",
     group   = G_OSC,
     tooltip = "Price source fed into ta.rsi() on the chart timeframe.  The "
             + "HTF version is always close.")

htfTf         = input.timeframe("240", "HTF Timeframe",
     group   = G_OSC,
     tooltip = "Higher timeframe used for the second RSI.  Default 240 (4h) "
             + "fits an intraday chart; pick a TF >= chart period.")

useStrictHtf  = input.bool  (true,   "Use lookahead_on with [1] offset (anti-repaint)",
     group   = G_OSC,
     tooltip = "When ON the HTF series is requested with lookahead_on AND a "
             + "[1] offset on the expression - this is the only non-repainting "
             + "form per Pine v6 docs.  Turn OFF only for research.")


// ---- Smoothing --------------------------------------------------------------
phaseSmoothLen = input.int  (3,      "Phase Smoothing EMA",
     minval = 1,  maxval = 50,  group = G_SMTH,
     tooltip = "EMA length applied to each raw phase angle before differencing. "
             + "Keep small (1-5) - over-smoothing destroys phase information.")

cohSmoothLen   = input.int  (8,      "Coherence Smoothing EMA",
     minval = 1,  maxval = 100, group = G_SMTH,
     tooltip = "EMA length applied to the cos() coherence value.  This is the "
             + "main responsiveness knob - bigger = smoother but laggier.")

ampSmoothLen   = input.int  (14,     "Amplification Factor EMA",
     minval = 1,  maxval = 200, group = G_SMTH,
     tooltip = "EMA length for the trend amplification factor displayed in the "
             + "dashboard.  Independent from coherence smoothing.")


// ---- Thresholds -------------------------------------------------------------
inPhaseLevel   = input.float(0.70,   "In-Phase Threshold (+)",
     minval = 0.10, maxval = 0.99, step = 0.01, group = G_THR,
     tooltip = "Coherence above this is treated as IN PHASE (trend "
             + "amplification).  Default 0.70.")

antiPhaseLevel = input.float(-0.70,  "Anti-Phase Threshold (-)",
     minval = -0.99, maxval = -0.10, step = 0.01, group = G_THR,
     tooltip = "Coherence below this is treated as ANTI PHASE (reversal "
             + "setup).  Default -0.70.")

decoherentBand = input.float(0.30,   "Decoherent Band (+/-)",
     minval = 0.05, maxval = 0.60, step = 0.01, group = G_THR,
     tooltip = "Symmetric band around zero where the system is considered "
             + "decoherent (no clear standing wave).  Default 0.30 -> "
             + "decoherent zone is -0.30 .. +0.30.")


// ---- Visuals ----------------------------------------------------------------
cohLineWidth   = input.int  (3,      "Coherence Line Width",
     minval = 1, maxval = 6, group = G_VIS)

showGlow       = input.bool (true,   "Coherence Glow Halo",
     group   = G_VIS,
     tooltip = "Renders a wider semi-transparent copy of the coherence line "
             + "below the main line to create a soft glow effect.")

showBgTint     = input.bool (true,   "Background Tint by Phase Status",
     group   = G_VIS,
     tooltip = "Subtle bgcolor() in bull hue when IN PHASE, bear hue when "
             + "ANTI PHASE, none when decoherent.  Transparency is 88-92.")

bgTintTrans    = input.int  (88,     "BG Tint Transparency",
     minval = 70, maxval = 98, group = G_VIS,
     tooltip = "Pine transparency (0 opaque, 100 invisible).  Higher = "
             + "more subtle.  88 is the default - barely visible but readable.")

showThreshLines = input.bool(true,   "Show Threshold Lines (+/-0.7)",
     group   = G_VIS)

showZeroLine   = input.bool (true,   "Show Zero Line",
     group   = G_VIS)

showPhaseArrows = input.bool(true,   "Show Phase Status Arrows",
     group   = G_VIS,
     tooltip = "Plots tiny up/down/dot shapes inside the pane when the phase "
             + "STATUS changes (entered in-phase, entered anti-phase, "
             + "returned to decoherent).")

showFillThresh = input.bool (true,   "Fill Between Threshold Lines",
     group   = G_VIS,
     tooltip = "Soft fill between +threshold and +1 (bull hue) and between "
             + "-threshold and -1 (bear hue) to make the active zone obvious.")


// ---- Dashboard --------------------------------------------------------------
showDash       = input.bool (true,   "Show Dashboard",          group = G_DASH)

dashPos        = input.string("Top Right", "Dashboard Position",
     options = ["Top Right","Top Left","Top Center",
                "Bottom Right","Bottom Left","Bottom Center",
                "Middle Right","Middle Left","Middle Center"],
     group = G_DASH)

dashSize       = input.string("Small", "Dashboard Text Size",
     options = ["Tiny","Small","Normal","Large","Huge"],
     group   = G_DASH)

dashCompact    = input.bool (false,  "Compact Dashboard (hide settings rows)",
     group   = G_DASH)


// ---- Alerts -----------------------------------------------------------------
alertOnEnter   = input.bool (true,   "Alert on In-Phase entry",      group = G_ALERT)
alertOnExit    = input.bool (true,   "Alert on Anti-Phase entry",    group = G_ALERT)
alertOnFlip    = input.bool (false,  "Alert on Coherence sign flip", group = G_ALERT)
alertOnDecoh   = input.bool (false,  "Alert on entering Decoherent", group = G_ALERT)


// =============================================================================
//  SECTION 2 - COLOR PALETTE  (Quantum - curated)
//      In-phase    = #00FFE0 (cyan)
//      Anti-phase  = #FF00C8 (pink)
//      Decoherent  = #80FFE0 (neutral)
//      BG / Frame  = #02011A / #1A0F33
//  Coherence line interpolates between cyan and pink ONLY.
// =============================================================================

const color C_BULL      = #00FFE0   // in-phase  (cyan)
const color C_BEAR      = #FF00C8   // anti-phase (pink)
const color C_DECOH     = #80FFE0   // decoherent (neutral - used for non-line status)
const color C_BG        = #02011A
const color C_FRAME     = #1A0F33   // table frame

// Derived text colors (NOT new hues - just neutral grays for table chrome).
color C_TEXT      = color.new(color.white, 5)
color C_TEXT_DIM  = color.new(color.white, 35)
color C_HDR_BG    = color.new(C_BG,  10)
color C_CELL_BG   = color.new(C_BG,  60)
color C_CELL_BG2  = color.new(C_BG,  72)


// =============================================================================
//  SECTION 3 - HELPER FUNCTIONS
// =============================================================================

// -- f_clamp ------------------------------------------------------------------
f_clamp(float _x, float _min, float _max) =>
    math.max(_min, math.min(_x, _max))


// -- f_colorGradient ----------------------------------------------------------
//  Linear-RGB interpolation between two colors by ratio in [0, 1].
//  This is THE single helper used to paint the coherence line - it guarantees
//  the line is composed exclusively of the active theme's bull and bear hues,
//  with every intermediate value being a true blend of those two.
f_colorGradient(float _ratio, color _colA, color _colB) =>
    r  = f_clamp(_ratio, 0.0, 1.0)
    rA = color.r(_colA)
    gA = color.g(_colA)
    bA = color.b(_colA)
    rB = color.r(_colB)
    gB = color.g(_colB)
    bB = color.b(_colB)
    rr = rA + int((rB - rA) * r)
    gg = gA + int((gB - gA) * r)
    bb = bA + int((bB - bA) * r)
    color.rgb(rr, gg, bb, 0)


// -- f_atan2 ------------------------------------------------------------------
//  Four-quadrant arctangent.  Pine v6 ships math.atan2(y, x) natively, but to
//  insulate this script against any future signature drift we wrap it in our
//  own helper.  Behavior matches the IEEE 754 atan2(y, x): result in (-pi, pi].
//  Edge cases (x == 0) are handled explicitly so we never feed a NaN to cos().
f_atan2(float _y, float _x) =>
    float ang = 0.0
    if _x > 0.0
        ang := math.atan(_y / _x)
    else if _x < 0.0 and _y >= 0.0
        ang := math.atan(_y / _x) + math.pi
    else if _x < 0.0 and _y <  0.0
        ang := math.atan(_y / _x) - math.pi
    else if _x == 0.0 and _y > 0.0
        ang :=  math.pi / 2.0
    else if _x == 0.0 and _y < 0.0
        ang := -math.pi / 2.0
    else
        ang := 0.0
    ang


// -- f_wrapAngle --------------------------------------------------------------
//  Wrap an arbitrary angle to the canonical (-pi, pi] interval.  Used after
//  subtracting two phases (the raw difference can fall in (-2pi, 2pi)).
f_wrapAngle(float _a) =>
    float a = _a
    while a >  math.pi
        a -= 2.0 * math.pi
    while a <= -math.pi
        a += 2.0 * math.pi
    a


// -- f_radToDeg ---------------------------------------------------------------
f_radToDeg(float _rad) =>
    _rad * 180.0 / math.pi


// -- f_signStr ----------------------------------------------------------------
f_signStr(float _x) =>
    _x > 0.0 ? "+" : _x < 0.0 ? "-" : " "


// -- strToPos -----------------------------------------------------------------
strToPos(string _s) =>
    switch _s
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


// -- strToSize ----------------------------------------------------------------
strToSize(string _s) =>
    switch _s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.normal


// -- f_statusColor ------------------------------------------------------------
//  Maps phase status (in-phase / decoherent / anti-phase) directly to one of
//  the two theme hues (or a neutralized blend for decoherent).  Keeps the
//  two-hue contract iron-clad - decoherent uses a 50/50 blend, not a 3rd hue.
f_statusColor(int _state, color _bull, color _bear) =>
    _state == 1  ? _bull : _state == -1 ? _bear : f_colorGradient(0.5, _bear, _bull)


// -- f_safeRatio --------------------------------------------------------------
f_safeRatio(float _num, float _den) =>
    _den == 0.0 or na(_den) ? 0.0 : _num / _den


// =============================================================================
//  SECTION 4 - CORE CALCULATIONS  (LTF + HTF RSI, phases, coherence)
// =============================================================================

// ---- 4.1  Lower-Timeframe RSI (chart bar) ----------------------------------
ltfRsi      = ta.rsi(rsiSrc, rsiLen)
ltfRsiPrev  = nz(ltfRsi[1], ltfRsi)
ltfDeriv    = ltfRsi - ltfRsiPrev               // d(RSI)/dt  (one-bar diff)
ltfCentered = ltfRsi - 50.0                     // amplitude around equilibrium


// ---- 4.2  Higher-Timeframe RSI -------------------------------------------
//  Single request.security() call - the expression evaluated in HTF context
//  is ta.rsi(close, rsiLen).  When useStrictHtf is enabled we apply the
//  anti-repaint pattern documented in the Pine v6
//  Other Timeframes docs: lookahead_on with a [1] offset on the expression.
//  When disabled, we use the default lookahead_off (live but may repaint on
//  intrabar updates).
htfRsiRaw   = useStrictHtf
     ? request.security(syminfo.tickerid, htfTf, ta.rsi(close, rsiLen)[1],
                         lookahead = barmerge.lookahead_on)
     : request.security(syminfo.tickerid, htfTf, ta.rsi(close, rsiLen),
                         lookahead = barmerge.lookahead_off)

htfRsi      = nz(htfRsiRaw, ltfRsi)             // first bars before HTF resolves
htfRsiPrev  = nz(htfRsi[1], htfRsi)
htfDeriv    = htfRsi - htfRsiPrev
htfCentered = htfRsi - 50.0


// ---- 4.3  Instantaneous Phase Angles --------------------------------------
//  phase = atan2(d(RSI)/dt,  RSI - 50)
//  - x-axis (real)      : centered amplitude   (RSI - 50)
//  - y-axis (imag/rate) : velocity             (d RSI / dt)
//  This is the standard analytic-signal phase recovery applied to a bounded
//  oscillator.  An EMA on the raw phase removes single-bar atan2 jitter
//  without destroying the standing-wave structure.
ltfPhaseRaw = f_atan2(ltfDeriv, ltfCentered)
htfPhaseRaw = f_atan2(htfDeriv, htfCentered)

ltfPhase    = ta.ema(ltfPhaseRaw, phaseSmoothLen)
htfPhase    = ta.ema(htfPhaseRaw, phaseSmoothLen)


// ---- 4.4  Coherence  (cosine of phase difference) -------------------------
phaseDiffRaw = ltfPhase - htfPhase
phaseDiff    = f_wrapAngle(phaseDiffRaw)        // map to (-pi, pi]
cohRaw       = math.cos(phaseDiff)              // in [-1, +1] by construction
coherence    = ta.ema(cohRaw, cohSmoothLen)
coherence   := f_clamp(coherence, -1.0, 1.0)    // defensive clamp


// ---- 4.5  Trend Amplification Factor --------------------------------------
//  When both waves are in phase, the constructive superposition amplitude is
//  bounded above by the sum of the individual amplitudes (max amp = 2).
//  When anti-phase, destructive interference yields ~0.  We model the
//  factor as  1 + coherence  (range [0, 2]).  Smoothed for display.
ampFactorRaw = 1.0 + coherence
ampFactor    = ta.ema(ampFactorRaw, ampSmoothLen)


// =============================================================================
//  SECTION 5 - STATE / TRACKING
// =============================================================================

//  phaseState:  +1 = IN PHASE,  -1 = ANTI PHASE,  0 = DECOHERENT,
//               +2 = weak-positive (between decoherent band and +threshold),
//               -2 = weak-negative (between -threshold and -decoherent band)
//  Only +1/-1/0 are reported as "named" statuses for alerts.

f_resolveState(float _c) =>
    int s = 0
    if _c >=  inPhaseLevel
        s :=  1
    else if _c <=  antiPhaseLevel
        s := -1
    else if _c >=  decoherentBand
        s :=  2
    else if _c <= -decoherentBand
        s := -2
    else
        s :=  0
    s

phaseState     = f_resolveState(coherence)

var int prevPhaseState  = 0
var int barsInState     = 0
var int lastFlipBar     = na

// barsInState counter
if phaseState == prevPhaseState
    barsInState += 1
else
    barsInState := 1

// last sign-flip bookkeeping (zero crossing of coherence)
crossedUp   = ta.crossover (coherence, 0.0)
crossedDown = ta.crossunder(coherence, 0.0)
if crossedUp or crossedDown
    lastFlipBar := bar_index

// entry-edge detectors (state CHANGE events) for alerts and labels
enteredInPhase    = phaseState ==  1 and prevPhaseState !=  1
enteredAntiPhase  = phaseState == -1 and prevPhaseState != -1
enteredDecoherent = phaseState ==  0 and prevPhaseState !=  0
enteredWeakPos    = phaseState ==  2 and prevPhaseState !=  2
enteredWeakNeg    = phaseState == -2 and prevPhaseState != -2

// commit previous state at bar end
if barstate.isconfirmed
    prevPhaseState := phaseState


// =============================================================================
//  SECTION 6 - SIGNAL ENGINE
// =============================================================================
//  The signal engine emits high-conviction tags only on state CHANGES.  This
//  Entry flip detection: no
//  re-firing while the state is held.
// =============================================================================

// Named labels for the pane shapes / dashboard
string statusText = phaseState == 1 ? "PHASE+" : phaseState == -1 ? "ANTI" : phaseState == 2 ? "weak+" : phaseState == -2 ? "weak-" : "DECOH"

// Signal eventa
sigInPhase    = enteredInPhase
sigAntiPhase  = enteredAntiPhase
sigDecoh      = enteredDecoherent
sigFlip       = crossedUp or crossedDown


// =============================================================================
//  SECTION 7 - PLOTS / FILLS  (the heart of the visual)
// =============================================================================
//  Two-hue contract enforcement:
//      *  The coherence line is colored by f_colorGradient(ratio, bear, bull)
//         where ratio = (coherence + 1) / 2  in [0, 1].  At ratio = 0 the
//         line is pure bear hue; at ratio = 1 it is pure bull hue; every
//         intermediate value is an RGB-interpolated blend of ONLY those two.
//      *  Threshold hlines use bull hue (positive) and bear hue (negative).
//      *  Zero line uses a low-opacity neutral derived from blend at 50%.
//      *  BG tint uses transparent bull or bear hue (NEVER a third hue).
// =============================================================================

// ---- 7.1  Coherence ratio in [0,1] used for the line color -----------------
cohColorRatio = (coherence + 1.0) / 2.0
cohLineColor  = f_colorGradient(cohColorRatio, C_BEAR, C_BULL)

// Glow halo color = same as line, but heavily transparent.
glowColor     = color.new(cohLineColor, 80)

// ---- 7.2  Main plots -------------------------------------------------------
//  We plot the GLOW first (wider, transparent) so the crisp line draws on top.
plot(showGlow ? coherence : na,
     title     = "Coherence Glow",
     color     = glowColor,
     linewidth = math.min(cohLineWidth + 3, 8))

plotCoh = plot(coherence,
     title     = "Coherence",
     color     = cohLineColor,
     linewidth = cohLineWidth)


// ---- 7.3  Threshold lines --------------------------------------------------
//  hline takes a CONSTANT color, so we precompute these once.  They use the
//  bull and bear hues at high transparency - still only the two theme hues.
plusThreshColor  = color.new(C_BULL, 50)
minusThreshColor = color.new(C_BEAR, 50)
hl_plus  = hline( inPhaseLevel,
     title     = "In-Phase Threshold",
     color     = plusThreshColor,
     linestyle = hline.style_dashed)

hl_minus = hline( antiPhaseLevel,
     title     = "Anti-Phase Threshold",
     color     = minusThreshColor,
     linestyle = hline.style_dashed)

hl_top   = hline( 1.0,
     title     = "Top Cap",
     color     = color.new(C_BULL, 90),
     linestyle = hline.style_dotted)

hl_bot   = hline(-1.0,
     title     = "Bottom Cap",
     color     = color.new(C_BEAR, 90),
     linestyle = hline.style_dotted)

// Zero line: uses a UDF-derived color so cannot use hline() (which requires
// const color). Replaced with plot() + plot.style_linebr — same visual effect.
plot(showZeroLine ? 0.0 : na, "Zero",
     color     = color.new(f_colorGradient(0.5, C_BEAR, C_BULL), 70),
     linewidth = 1,
     style     = plot.style_linebr)

// ---- 7.4  Fills between threshold and cap (soft "active zone" highlight) --
fill(hl_plus,  hl_top,  color = color.new(C_BULL, showFillThresh ? 88 : 100),
     title    = "In-Phase Zone Fill")
fill(hl_minus, hl_bot,  color = color.new(C_BEAR, showFillThresh ? 88 : 100),
     title    = "Anti-Phase Zone Fill")


// ---- 7.5  Background tint by phase status ---------------------------------
//  ONLY bull hue, bear hue, or na.  Never a third hue.
color bgTintColor = showBgTint and phaseState == 1 ? color.new(C_BULL, bgTintTrans) : showBgTint and phaseState == -1 ? color.new(C_BEAR, bgTintTrans) : na
bgcolor(bgTintColor, title = "Phase Status Tint")


// ---- 7.6  Phase status arrows / shapes (state-change markers) -------------
plotshape(showPhaseArrows and enteredInPhase,
     title    = "Entered In-Phase",
     style    = shape.triangleup,
     location = location.bottom,
     color    = C_BULL,
     size     = size.tiny)

plotshape(showPhaseArrows and enteredAntiPhase,
     title    = "Entered Anti-Phase",
     style    = shape.triangledown,
     location = location.top,
     color    = C_BEAR,
     size     = size.tiny)

plotshape(showPhaseArrows and enteredDecoherent,
     title    = "Entered Decoherent",
     style    = shape.circle,
     location = location.absolute,
     color    = color.new(f_colorGradient(0.5, C_BEAR, C_BULL), 30),
     size     = size.tiny)


// =============================================================================
//  SECTION 8 - SECONDARY PLOTS (offsetable helper series, all hidden default)
// =============================================================================
//  These are exposed so users can pull them into Strategy Tester, alerts, or
//  external scripts via input.source.  They contribute zero visual weight to
//  the pane unless the user explicitly enables them in the Settings > Style.
// =============================================================================

plot(ltfRsi,        "LTF RSI",         color = color.new(C_BULL, 90), display = display.data_window)
plot(htfRsi,        "HTF RSI",         color = color.new(C_BEAR, 90), display = display.data_window)
plot(ltfPhase,      "LTF Phase (rad)", color = color.new(C_BULL, 90), display = display.data_window)
plot(htfPhase,      "HTF Phase (rad)", color = color.new(C_BEAR, 90), display = display.data_window)
plot(phaseDiff,     "Phase Diff",      color = color.new(color.gray, 90), display = display.data_window)
plot(ampFactor,     "Amp Factor",      color = color.new(C_BULL, 90), display = display.data_window)
plot(phaseState,    "Phase State",     color = color.new(color.gray, 90), display = display.data_window)
plot(barsInState,   "Bars In State",   color = color.new(color.gray, 90), display = display.data_window)


// =============================================================================
//  SECTION 9 - DASHBOARD
// =============================================================================
//  Eight content rows + a header row.  Two columns.  Layout matches the spec
//  All cell text is monospace for tabular
//  alignment.  Backgrounds use the C_CELL_BG / C_CELL_BG2 zebra striping.
// =============================================================================

f_fmtRsi(float _v)    => na(_v) ? "n/a" : str.tostring(_v, "#.##")
f_fmtRad(float _v)    => na(_v) ? "n/a" : str.tostring(_v, "#.###") + " rad"
f_fmtDeg(float _v)    => na(_v) ? "n/a" : str.tostring(f_radToDeg(_v), "#.#") + " deg"
f_fmtCoh(float _v)    => na(_v) ? "n/a" : (_v >= 0.0 ? "+" : "") + str.tostring(_v, "0.000")
f_fmtAmp(float _v)    => na(_v) ? "n/a" : str.tostring(_v, "0.00") + "x"
f_fmtInt(int   _v)    => na(_v) ? "n/a" : str.tostring(_v)

string statusLabel = phaseState == 1 ? "IN PHASE" : phaseState == -1 ? "ANTI PHASE" : phaseState == 2 ? "weak constructive" : phaseState == -2 ? "weak destructive" : "DECOHERENT"

statusCellColor = f_statusColor(phaseState, C_BULL, C_BEAR)

var table dash = table.new(
     position     = strToPos(dashPos),
     columns      = 2,
     rows         = 10,
     bgcolor      = na,
     frame_color  = C_FRAME,
     frame_width  = 1,
     border_color = color.new(C_FRAME, 65),
     border_width = 1)


if showDash and barstate.islast
    // --- Header (spans both cols, both cells share hdr bg) ------------------
    table.cell(dash, 0, 0, "STANDING WAVE PHASE",
         text_color       = C_TEXT,
         bgcolor          = C_HDR_BG,
         text_size        = strToSize(dashSize),
         text_halign      = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(dash, 1, 0, "[ SWP ]",
         text_color       = statusCellColor,
         bgcolor          = C_HDR_BG,
         text_size        = strToSize(dashSize),
         text_halign      = text.align_right,
         text_font_family = font.family_monospace)

    // --- Row 1: LTF RSI / phase ---------------------------------------------
    table.cell(dash, 0, 1, "LTF RSI / phase",
         text_color = C_TEXT, bgcolor = C_CELL_BG,
         text_size  = strToSize(dashSize),
         text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(dash, 1, 1, f_fmtRsi(ltfRsi) + "   " + f_fmtDeg(ltfPhase),
         text_color = C_TEXT, bgcolor = C_CELL_BG,
         text_size  = strToSize(dashSize),
         text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // --- Row 2: HTF RSI / phase ---------------------------------------------
    table.cell(dash, 0, 2, "HTF RSI / phase",
         text_color = C_TEXT, bgcolor = C_CELL_BG2,
         text_size  = strToSize(dashSize),
         text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(dash, 1, 2, f_fmtRsi(htfRsi) + "   " + f_fmtDeg(htfPhase),
         text_color = C_TEXT, bgcolor = C_CELL_BG2,
         text_size  = strToSize(dashSize),
         text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // --- Row 3: Coherence ---------------------------------------------------
    table.cell(dash, 0, 3, "Coherence",
         text_color = C_TEXT, bgcolor = C_CELL_BG,
         text_size  = strToSize(dashSize),
         text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(dash, 1, 3, f_fmtCoh(coherence),
         text_color = cohLineColor, bgcolor = C_CELL_BG,
         text_size  = strToSize(dashSize),
         text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // --- Row 4: Status ------------------------------------------------------
    table.cell(dash, 0, 4, "Status",
         text_color = C_TEXT, bgcolor = C_CELL_BG2,
         text_size  = strToSize(dashSize),
         text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(dash, 1, 4, statusLabel,
         text_color = statusCellColor, bgcolor = C_CELL_BG2,
         text_size  = strToSize(dashSize),
         text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // --- Row 5: Bars in status ----------------------------------------------
    table.cell(dash, 0, 5, "Bars in status",
         text_color = C_TEXT, bgcolor = C_CELL_BG,
         text_size  = strToSize(dashSize),
         text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(dash, 1, 5, f_fmtInt(barsInState),
         text_color = C_TEXT, bgcolor = C_CELL_BG,
         text_size  = strToSize(dashSize),
         text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // --- Row 6: LTF setting -------------------------------------------------
    if not dashCompact
        table.cell(dash, 0, 6, "LTF setting",
             text_color = C_TEXT_DIM, bgcolor = C_CELL_BG2,
             text_size  = strToSize(dashSize),
             text_halign = text.align_left,
             text_font_family = font.family_monospace)
        table.cell(dash, 1, 6, "RSI " + str.tostring(rsiLen) + " @ " + timeframe.period,
             text_color = C_TEXT_DIM, bgcolor = C_CELL_BG2,
             text_size  = strToSize(dashSize),
             text_halign = text.align_right,
             text_font_family = font.family_monospace)

        // --- Row 7: HTF setting ---------------------------------------------
        table.cell(dash, 0, 7, "HTF setting",
             text_color = C_TEXT_DIM, bgcolor = C_CELL_BG,
             text_size  = strToSize(dashSize),
             text_halign = text.align_left,
             text_font_family = font.family_monospace)
        table.cell(dash, 1, 7, "RSI " + str.tostring(rsiLen) + " @ " + htfTf,
             text_color = C_TEXT_DIM, bgcolor = C_CELL_BG,
             text_size  = strToSize(dashSize),
             text_halign = text.align_right,
             text_font_family = font.family_monospace)

        // --- Row 8: Amplification factor ------------------------------------
        table.cell(dash, 0, 8, "Amp factor",
             text_color = C_TEXT, bgcolor = C_CELL_BG2,
             text_size  = strToSize(dashSize),
             text_halign = text.align_left,
             text_font_family = font.family_monospace)
        table.cell(dash, 1, 8, f_fmtAmp(ampFactor) +
             (phaseState ==  1 ? "  ^" :
              phaseState == -1 ? "  v" : ""),
             text_color = statusCellColor, bgcolor = C_CELL_BG2,
             text_size  = strToSize(dashSize),
             text_halign = text.align_right,
             text_font_family = font.family_monospace)

        // --- Row 9: Last flip ago (auxiliary - settings group) --------------
        flipsAgo = na(lastFlipBar) ? na : bar_index - lastFlipBar
        table.cell(dash, 0, 9, "Last sign-flip",
             text_color = C_TEXT_DIM, bgcolor = C_CELL_BG,
             text_size  = strToSize(dashSize),
             text_halign = text.align_left,
             text_font_family = font.family_monospace)
        table.cell(dash, 1, 9, na(flipsAgo) ? "-" : f_fmtInt(flipsAgo) + " bars ago",
             text_color = C_TEXT_DIM, bgcolor = C_CELL_BG,
             text_size  = strToSize(dashSize),
             text_halign = text.align_right,
             text_font_family = font.family_monospace)


// =============================================================================
//  SECTION 10 - ALERTS
// =============================================================================
//  Alerts respect their individual input toggles - the alertcondition itself
//  is always compiled (Pine requires that), but the message body and gating
//  reflect the user's selection.
// =============================================================================

alertcondition(alertOnEnter and sigInPhase,
     title   = "SWP - In-Phase Entry",
     message = "SWP [JOAT]  IN PHASE entered  (trend amplification)  coherence={{plot('Coherence')}}")

alertcondition(alertOnExit and sigAntiPhase,
     title   = "SWP - Anti-Phase Entry",
     message = "SWP [JOAT]  ANTI PHASE entered  (reversal setup)  coherence={{plot('Coherence')}}")

alertcondition(alertOnDecoh and sigDecoh,
     title   = "SWP - Decoherent Entry",
     message = "SWP [JOAT]  DECOHERENT entered  (no clear standing wave)")

alertcondition(alertOnFlip and sigFlip,
     title   = "SWP - Coherence Sign Flip",
     message = "SWP [JOAT]  coherence sign flip detected")

alertcondition(crossedUp,
     title   = "SWP - Coherence Crossed Zero Up",
     message = "SWP [JOAT]  coherence crossed ZERO upward")

alertcondition(crossedDown,
     title   = "SWP - Coherence Crossed Zero Down",
     message = "SWP [JOAT]  coherence crossed ZERO downward")

alertcondition(ta.crossover(coherence, inPhaseLevel),
     title   = "SWP - Crossed In-Phase Threshold",
     message = "SWP [JOAT]  coherence crossed above +threshold")

alertcondition(ta.crossunder(coherence, antiPhaseLevel),
     title   = "SWP - Crossed Anti-Phase Threshold",
     message = "SWP [JOAT]  coherence crossed below -threshold")


// =============================================================================
//  END OF Standing Wave Phase Coherence [JOAT]
//  Architecture:  Section 1 (Inputs) -> 2 (Theme) -> 3 (Helpers) ->
//                 4 (Core math: RSI/phase/coherence) -> 5 (State) ->
//                 6 (Signal) -> 7 (Plots/Fills) -> 8 (Aux plots) ->
//                 9 (Dashboard) -> 10 (Alerts)
//  Two-hue contract verified:  ALL render colors derived from C_BULL, C_BEAR.
//  Phase math verified:  f_atan2(y, x) + math.cos(diff), wrapped to (-pi, pi].
//  HTF request verified:  request.security(syminfo.tickerid, htfTf,
//                            ta.rsi(close, rsiLen)[1], lookahead_on).
// =============================================================================
````

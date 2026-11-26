# Schrodinger Zone Probability [JOAT]

- url: https://www.tradingview.com/script/YjucWaZR-Schrodinger-Zone-Probability-JOAT/
- type: indicator
- pine_id: PUB;a1ad1b6db57c4f5896f8dd6407a06d1b
- version: 1.0

## Description

[b]SCHRÖDINGER ZONE PROBABILITY [JOAT][/b]

The most quantitatively ambitious indicator in the JOAT suite. Detects Fair Value Gaps and Order Blocks the way a serious SMC engine should — and then, before they are touched, treats each one as a [b]superposition zone[/b] with two simultaneous probabilities: [b]P_S[/b] (the probability it will act as Support when revisited) and [b]P_R[/b] (the probability it will act as Resistance). The two probabilities sum to one. The zone exists in a superposition of both states until price actually touches it; at that moment the [i]wavefunction collapses[/i] to a single classical state — S or R — driven by the bars-after-touch confirmation logic. Then the script tags the zone with the committed direction and archives the collapse.

[image]https://www.tradingview.com/x/PXBlOGZ7/[/image]

[b]Detection — FVGs and OBs done properly[/b]

Two independent zone types feed the superposition engine:

[list]
[*] [b]Fair Value Gaps[/b] — the standard 3-candle imbalance definition, ATR-filtered (minimum gap = configurable × ATR, default 0.30×) so only meaningful gaps qualify. Bull and bear FVGs both detected.
[*] [b]Order Blocks[/b] — three methods exposed:
  [list]
  [*] [b]Last Opposite[/b] — latest opposite-color candle before displacement.
  [*] [b]Extreme Opposite[/b] — most extreme (lowest low / highest high) candle in the walk-back window.
  [*] [b]Strict Volume[/b] — Last Opposite filtered by volume above MA.
  [/list]
[/list]

Displacement (the move that creates the zone) requires a body of [b]displacement ATR multiple × ATR[/b] (default 1.20×). A configurable walk-back window controls how far back to search for the OB origin. Configurable mitigation rule (Wick = any pierce, Close = bar must close beyond).

[b]The headline math — three-factor superposition probability[/b]

The collapse probabilities P_S / P_R are computed as a weighted blend of three orthogonal factors:

[list]
[*] [b]Distance factor[/b] — distance from current price to the zone, decayed exponentially with a configurable half-life in ATR units (default 2.0 ATR). Closer zones have higher commit probability.
[*] [b]Direction factor[/b] — which side of the zone current price is on. Above the zone leans the read toward Support collapse; below leans toward Resistance.
[*] [b]Flow factor[/b] — EMA-slope alignment over a configurable flow window (default 20 bars). Bullish flow biases toward Support; bearish flow biases toward Resistance.
[/list]

Each factor's weight is independently tunable. Defaults (0.45 distance / 0.30 direction / 0.25 flow) are the script's institutional calibration. The output is two probabilities that sum to 1.

A zone with [b]P_S ≈ P_R ≈ 0.5[/b] is in [i]pure superposition[/i] — the model is genuinely undecided. A zone with [b]P_S = 0.85 / P_R = 0.15[/b] is in a state nearly committed to Support; the wavefunction has already partly collapsed.

[b]Wavefunction collapse — the engine's headline event[/b]

When price enters the zone within a configurable touch tolerance (default 0.05 × ATR slack) and holds inside for the configurable [b]holdBars[/b] window (default 3 bars), the zone collapses to a single classical state:

[list]
[*] [b]Collapse to S[/b] — price bounced; the zone acted as Support. Marker prints "(+)→S" at the centroid.
[*] [b]Collapse to R[/b] — price was rejected from the other side; the zone acted as Resistance. Marker prints "(+)→R".
[/list]

A configurable connector line is drawn at the committed level. Collapsed zones are optionally archived (default ON) so the chart shows the full history of how superpositions resolved.

[b]Visual system — superposition rendering[/b]

[list]
[*] [b]Vertical gradient fill[/b] — each zone is rendered as a stack of N sub-boxes (configurable, default 8 slices) with progressive transparency, creating a vertical gradient that visually communicates "high probability of support at the bottom of the zone, high probability of resistance at the top". This is the script's signature visual.
[*] [b]Glow border[/b] — configurable glow intensity; becomes thicker when uncertainty is high (P_S ≈ P_R).
[*] [b]Animated superposition pulse[/b] — for zones in pure superposition (P ≈ 0.5), transparency oscillates with bar_index to indicate undecided state. Configurable period and amplitude.
[*] [b]Probability labels[/b] — P_S / P_R values printed on each active zone.
[*] [b]Zone type tags[/b] — FVG_BU, FVG_BE, OB_BU, OB_BE so origin is unambiguous.
[*] [b]Collapse markers[/b] — fancy glyphs (+)→S / (+)→R or plain S / R, configurable.
[*] [b]Show-only-superposition mode[/b] — hide collapsed and archived zones for a minimalist view.
[*] [b]Right extension[/b] — zones project a configurable number of bars to the right.
[/list]

A locked institutional palette (cyan-teal bull / magenta bear) gives the chart a distinctive quantum-finance identity.

[image]https://www.tradingview.com/x/9segj1Vw/[/image]

[b]Dashboard[/b]

Monospaced table positionable to any of nine corners. Surfaces:

[list]
[*] Active superposition zone count and archived count.
[*] Nearest zone with its P_S / P_R values and distance.
[*] Last collapse direction with bars-ago.
[*] Current flow direction.
[*] Detection thresholds and weights in use.
[*] Mitigation rule.
[/list]

[b]Alerts[/b]

Multiple alert conditions:

[list]
[*] New Superposition Zone Created (FVG or OB)
[*] Collapse to Support
[*] Collapse to Resistance
[*] Approaching Zone (within collapse-touch tolerance)
[*] High-Uncertainty Zone formed (P_S ≈ P_R ≈ 0.5)
[/list]

[b]How to read it[/b]

Three reads, in order of conviction:

[list=1]
[*] [b]Collapse alert with extreme one-sided probability[/b] — e.g. a zone with P_S = 0.85 collapses to S. The model was confidently pointing at one outcome, and the market confirmed it. The highest-conviction confluence read the script produces.
[*] [b]Approaching a zone with sharp probability bias[/b] — when P_S or P_R is dominant before touch, the model is committed to one direction. Position toward the dominant side; if the collapse confirms, you are in early.
[*] [b]High-uncertainty zone (P ≈ 0.5)[/b] — stand-aside signal. The model is genuinely undecided; trade only with strong external confluence (HTF structure, news flow) or skip the zone entirely.
[/list]

[b]Suggested settings[/b]

Defaults (FVG ATR 0.30×, displacement 1.20×, OB Last-Opposite, 15-bar walk-back, weights 0.45 / 0.30 / 0.25, half-life 2.0 ATR, 3-bar hold) are tuned for 15m–4H on liquid markets. For lower timeframes drop displacement to 1.0× and hold to 2. For HTF raise FVG ATR to 0.50× to keep only large gaps. The weights are calibrated together — change one and the others rebalance the probabilities; experimenting with the weights is a legitimate way to specialise the script to your instrument.

[b]Originality[/b]

The implementation — the dual-source zone detector (FVG + OB) with three OB methods, the three-factor probability blend (distance / direction / flow) with independent weights, the exponential ATR-halflife distance decay, the touch-with-hold collapse-confirmation state machine, the vertical-gradient zone render using N stacked sub-boxes, the uncertainty-modulated glow border, the animated superposition pulse for high-uncertainty zones, the archive-on-collapse logic, and the dashboard's probability-aware layout — is JOAT-original. No third-party code reused. The Schrödinger framing (superposition → collapse) is the original conceptual contribution; the math is purpose-built.

[b]Limitations[/b]

The "probability" output is a heuristic blend of three factors that historically correlate with which side a zone acts as — it is a ranked confidence, not a true Bayesian posterior. The factor weights are exposed precisely because no single weighting is universally correct. The collapse confirmation requires the holdBars window to elapse, so collapse markers lag the actual touch by that window (intentional — single-bar pierces should not commit a zone). The animated pulse for high-uncertainty zones is purely visual.



-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title="Schrodinger Zone Probability [JOAT]", shorttitle="SZP [JOAT]", overlay=true,
     max_boxes_count=500, max_labels_count=500, max_lines_count=500, max_bars_back=5000)

// =================================================================================================
//  SECTION 1 - INPUTS  (grouped with box-drawing headers)
// =================================================================================================

grpDet   = "+------------- Detection -------------+"
grpProb  = "+------------ Probability ------------+"
grpVis   = "+-------------- Visuals --------------+"
grpDisp  = "+-------------- Display --------------+"
grpDash  = "+------------- Dashboard -------------+"
grpAlt   = "+--------------- Alerts --------------+"

// ---- Detection ----
detectFvg     = input.bool(true, "Detect FVGs",
     tooltip="Enable detection of 3-candle Fair Value Gaps (price imbalances).",
     group=grpDet)
detectOb      = input.bool(true, "Detect Order Blocks",
     tooltip="Enable detection of Order Blocks (last opposite-color candle before displacement).",
     group=grpDet)
fvgMinAtr     = input.float(0.30, "FVG Min ATR Multiple", minval=0.05, maxval=3.0, step=0.05,
     tooltip="Minimum FVG gap size as a multiple of ATR. Larger = only significant gaps qualify.",
     group=grpDet)
obMethod      = input.string("Last Opposite", "OB Detection Method",
     options=["Last Opposite", "Extreme Opposite", "Strict Volume"],
     tooltip="Last Opposite = latest opposite-color candle before displacement. "
       + "Extreme Opposite = most extreme (lowest low / highest high) candle in window. "
       + "Strict Volume = Last Opposite filtered by volume above MA.",
     group=grpDet)
obWindow      = input.int(15, "OB Walk-Back Window", minval=3, maxval=60,
     tooltip="How many bars to walk back searching for the order block before displacement.",
     group=grpDet)
dispMult      = input.float(1.20, "Displacement ATR Multiple", minval=0.50, maxval=4.0, step=0.10,
     tooltip="Body size threshold (xATR) for a candle to qualify as a displacement / impulse.",
     group=grpDet)
atrLen        = input.int(14, "ATR Length", minval=1, maxval=200,
     tooltip="ATR period used by FVG and OB sizing logic.",
     group=grpDet)
maxZones      = input.int(20, "Max Active Zones", minval=3, maxval=80,
     tooltip="Cap on simultaneously tracked superposition zones. Oldest are pruned first.",
     group=grpDet)
mitigateRule  = input.string("Wick", "Mitigation Rule",
     options=["Wick", "Close"],
     tooltip="Wick = any price pierce mitigates the zone. Close = bar must close beyond zone.",
     group=grpDet)
keepArchived  = input.bool(true, "Archive Collapsed Zones",
     tooltip="Keep collapsed (mitigated) zones on chart with muted color for context.",
     group=grpDet)
archiveMax    = input.int(30, "Max Archived Zones", minval=5, maxval=120,
     tooltip="Cap on archived (collapsed) zones retained on the chart.",
     group=grpDet)

// ---- Probability ----
wDistance     = input.float(0.45, "Distance Weight", minval=0.0, maxval=1.0, step=0.05,
     tooltip="Weight applied to the distance-based collapse probability component.",
     group=grpProb)
wDirection    = input.float(0.30, "Direction Weight", minval=0.0, maxval=1.0, step=0.05,
     tooltip="Weight applied to price-side-of-zone bias. Above zone leans toward support collapse.",
     group=grpProb)
wFlow         = input.float(0.25, "Flow Weight", minval=0.0, maxval=1.0, step=0.05,
     tooltip="Weight applied to recent flow (EMA slope alignment). Bullish flow -> support side.",
     group=grpProb)
flowWindow    = input.int(20, "Flow Window (bars)", minval=3, maxval=200,
     tooltip="Lookback for flow / momentum computation feeding the flow probability factor.",
     group=grpProb)
distHalfLife  = input.float(2.0, "Distance Half-Life (xATR)", minval=0.25, maxval=10.0, step=0.25,
     tooltip="ATR multiple at which the distance factor decays by half (smaller = sharper falloff).",
     group=grpProb)
collapseTouch = input.float(0.05, "Collapse Touch Tolerance (xATR)", minval=0.0, maxval=1.0, step=0.05,
     tooltip="Allowed slack in ATR units when detecting price entry into zone for collapse.",
     group=grpProb)
holdBars      = input.int(3, "Hold Bars to Commit", minval=1, maxval=20,
     tooltip="Bars after first touch needed to confirm collapse direction (S or R).",
     group=grpProb)

// ---- Visuals ----
showGradient   = input.bool(true, "Show Vertical Gradient Fill", group=grpVis,
     tooltip="Render each zone as a vertical gradient (top=resistance P, bottom=support P).")
gradSlices     = input.int(8, "Gradient Slices per Zone", minval=2, maxval=18, group=grpVis,
     tooltip="Number of stacked sub-boxes per zone to fake a vertical gradient. Higher = smoother.")
showGlow       = input.bool(true, "Show Glow Border", group=grpVis)
glowIntensity  = input.int(70, "Glow Intensity", minval=0, maxval=100, group=grpVis,
     tooltip="0 = no glow alpha, 100 = max alpha. Glow becomes thicker when uncertainty is high.")
animatePulse   = input.bool(true, "Animate Superposition Pulse", group=grpVis,
     tooltip="Modulates zone transparency by bar_index for pure-superposition zones (P approx 0.5).")
pulsePeriod    = input.int(6, "Pulse Period (bars)", minval=2, maxval=24, group=grpVis)
pulseAmp       = input.int(22, "Pulse Amplitude (alpha)", minval=0, maxval=60, group=grpVis)
baseAlphaFill  = input.int(82, "Base Fill Transparency", minval=40, maxval=98, group=grpVis)
baseAlphaBorder= input.int(35, "Base Border Transparency", minval=0, maxval=90, group=grpVis)
extendZones    = input.bool(true, "Extend Zones to Right", group=grpVis)
extendBars     = input.int(40, "Right Extension (bars)", minval=1, maxval=400, group=grpVis,
     tooltip="If 'Extend Zones' is off, zones still project this many bars to the right.")

// ---- Display ----
showProbLabel  = input.bool(true, "Show Probability Labels", group=grpDisp,
     tooltip="Show P_S / P_R labels on each active superposition zone.")
showCollapse   = input.bool(true, "Show Collapse Markers", group=grpDisp,
     tooltip="Place an S or R marker at the centroid of collapsed zones.")
showZoneType   = input.bool(true, "Show Zone Type Tag", group=grpDisp,
     tooltip="Tag each zone with its origin (FVG_BU, FVG_BE, OB_BU, OB_BE).")
showOnlySuper  = input.bool(false, "Show Only Superposition Zones", group=grpDisp,
     tooltip="Hide collapsed/archived zones, show only live undecided zones.")
showCollapseLn = input.bool(true, "Draw Collapse Connector Line", group=grpDisp,
     tooltip="On collapse, draw a faint horizontal line at the committed level for context.")
labelSize      = input.string("Small", "Label Size",
     options=["Tiny", "Small", "Normal", "Large"], group=grpDisp)
markerSize     = input.string("Normal", "Collapse Marker Size",
     options=["Tiny", "Small", "Normal", "Large"], group=grpDisp)
useFancyGlyph  = input.bool(true, "Use Fancy Collapse Glyphs",
     tooltip="Render collapse markers as '(+)->S' / '(+)->R' instead of plain S / R.",
     group=grpDisp)

// ---- Dashboard ----
showDash       = input.bool(true, "Show Dashboard", group=grpDash)
dashPosStr     = input.string("Top Right", "Dashboard Position", group=grpDash,
     options=["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left",
              "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"])
dashSizeStr    = input.string("Small", "Dashboard Size", group=grpDash,
     options=["Tiny", "Small", "Normal", "Large", "Huge"])
dashGradient   = input.bool(true, "Dashboard Row Gradient", group=grpDash)

// ---- Alerts ----
enaNewZone     = input.bool(true, "Enable 'New Superposition Zone' alerts", group=grpAlt)
enaCollapseS   = input.bool(true, "Enable 'Collapse to Support' alerts", group=grpAlt)
enaCollapseR   = input.bool(true, "Enable 'Collapse to Resistance' alerts", group=grpAlt)
enaHighProb    = input.bool(true, "Enable 'High-Probability Zone' alerts", group=grpAlt)
highProbThr    = input.float(0.72, "High-Probability Threshold",
     minval=0.55, maxval=0.95, step=0.01, group=grpAlt)

// =================================================================================================
//  SECTION 2 - COLOR PALETTE  (Royal Purple - curated)
//      Support-collapse    = #c5aff5 (lavender)
//      Resistance-collapse = #D900FF (magenta)
//      Superposition mid   = #9C8FD9 (muted purple)
//      BG / Frame          = #0F0B1A / #241A3A
//  Each zone uses ONE hue with transparency-pulse - never blends hues.
// =================================================================================================

const color C_BULL   = #c5aff5            // support-collapse (lavender)
const color C_BEAR   = color.rgb(217, 0, 255)  // resistance-collapse (magenta = #D900FF)
const color C_MID    = #9C8FD9            // superposition (muted purple)
const color C_BG     = #0F0B1A
const color C_FRAME  = #241A3A
const color C_TEXT   = #E6E6E6
const color C_SUB    = #9C8FD9
color C_HDR_BG       = color.new(#241A3A, 25)
color C_ROW_A        = color.new(#0F0B1A, 55)
color C_ROW_B        = color.new(#241A3A, 65)
color C_GHOST        = color.rgb(140, 130, 170, 70)   // muted lavender-gray for archived zones

// =================================================================================================
//  SECTION 3 - HELPER FUNCTIONS
// =================================================================================================

// ---- Color gradient (RGB linear interpolation) ----
f_colorGradient(float ratio, color colA, color colB) =>
    float r = math.max(0.0, math.min(1.0, ratio))
    rA = color.r(colA), gA = color.g(colA), bA = color.b(colA)
    rB = color.r(colB), gB = color.g(colB), bB = color.b(colB)
    rr = rA + int((rB - rA) * r)
    rg = gA + int((gB - gA) * r)
    rb = bA + int((bB - bA) * r)
    color.rgb(rr, rg, rb, 0)

// ---- Multi-stop gradient ----
f_gradientMulti(float ratio, array<color> stops) =>
    n = array.size(stops) - 1
    color out = na
    if n < 1
        out := array.size(stops) > 0 ? array.get(stops, 0) : color.gray
    else
        posR = math.max(0.0, math.min(1.0, ratio)) * n
        idx = math.min(n - 1, math.max(0, int(posR)))
        local = posR - idx
        out := f_colorGradient(local, array.get(stops, idx), array.get(stops, idx + 1))
    out

// ---- Clamp ----
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))

// ---- Position resolver ----
f_strToPos(string s) =>
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

// ---- Size string resolver (table cells / labels) ----
f_strToSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.normal

// ---- Compact number formatter ----
f_fmt(float v, int dec) =>
    str.tostring(v, "#." + str.repeat("0", dec))

// ---- Subtle row gradient ----
f_rowGrad(color base, int row, int rows, int minT, int maxT) =>
    float t = rows <= 1 ? float(minT) : (minT + (maxT - minT) * (row / float(rows - 1)))
    color.new(base, int(t))

// ---- Safe start bar (bounded by max_bars_back) ----
f_safeStartBar(int b) =>
    int minSafe = bar_index - 4900
    b < minSafe ? minSafe : b

// ---- Sign helper ----
f_sign(float x) => x > 0.0 ? 1 : x < 0.0 ? -1 : 0

// ---- Map a value in [0,1] to alpha [aMin, aMax] (linear) ----
f_alphaFromConfidence(float conf, int aMin, int aMax) =>
    int a = int(aMin + (aMax - aMin) * (1.0 - f_clamp(conf, 0.0, 1.0)))
    f_clamp(float(a), 0.0, 100.0)

// ---- Pulse modulation (sinusoid by bar_index) ----
f_pulseAlpha(int barIdx, int period, int amp) =>
    float phase = (barIdx % math.max(period, 1)) / float(math.max(period, 1))
    int   pulse = int(math.round(amp * (0.5 + 0.5 * math.sin(2.0 * math.pi * phase))))
    pulse

// ---- Distance-based collapse pull (inverse exponential decay by ATR units) ----
f_distancePull(float priceNow, float zCenter, float atrVal, float halfLifeAtr) =>
    float d = math.abs(priceNow - zCenter)
    float u = atrVal > 0.0 ? d / atrVal : 0.0
    // exp(-ln(2) * u / halfLife) -> 1 at d=0, 0.5 at u=halfLife
    math.exp(-math.log(2.0) * (u / math.max(halfLifeAtr, 0.0001)))

// ---- Direction bias (price above zone => +1 lean to SUPPORT) ----
f_directionBias(float priceNow, float zTop, float zBot) =>
    float zMid = (zTop + zBot) * 0.5
    float zh   = math.max(zTop - zBot, 1e-10)
    float zRel = (priceNow - zMid) / zh
    // squash into [-1, +1]
    f_clamp(zRel / 4.0, -1.0, 1.0)

// ---- Flow bias from EMA slope and momentum ----
f_flowBias(int win) =>
    float ema  = ta.ema(close, math.max(2, win))
    float slope = ema - ema[1]
    float roc  = ta.roc(close, math.max(2, win / 2))
    float comb = nz(slope, 0.0) * 0.5 + nz(roc, 0.0) * 0.5
    float norm = ta.atr(math.max(14, win))
    float bias = norm > 0.0 ? comb / norm : 0.0
    f_clamp(bias / 1.5, -1.0, 1.0)

// ---- Weight normalizer ----
f_normWeights(float w1, float w2, float w3) =>
    float s = w1 + w2 + w3
    s > 0.0 ? s : 1.0

// =================================================================================================
//  SECTION 4 - USER-DEFINED TYPES (UDTs)
// =================================================================================================

// Each Schrodinger zone tracks both potential states until collapse.
type Zone
    int    id              // monotonic identifier
    int    leftBar         // bar_index of zone formation anchor
    float  top             // upper bound
    float  bot             // lower bound
    float  center          // midpoint
    int    kind            // 1 = bullish-origin FVG, -1 = bearish-origin FVG, 2 = bullish OB, -2 = bearish OB
    float  atrAt           // ATR at formation (sizing baseline)
    float  pSupport        // probability of collapse to SUPPORT (0..1)
    float  pResistance     // probability of collapse to RESISTANCE (0..1)
    float  confidence      // max(pS, pR) - 0.5  scaled to [0,1]
    int    touches         // count of price touches
    int    firstTouchBar   // bar of first interaction
    bool   collapsed       // true once committed
    int    collapsedTo     // +1 = Support, -1 = Resistance, 0 = pending
    int    collapseBar     // bar of commit
    bool   highProbAlerted // gate so we only alert once
    array<box>  slices     // gradient slice boxes
    box    glow            // outer glow border box
    label  probTag         // probability text label
    label  collapseLbl     // collapse marker
    line   collapseLine    // optional connector line

// Buffer for a candidate FVG to be confirmed
type CandFvg
    float  top
    float  bot
    int    bar
    int    dir   // +1 bull, -1 bear

// =================================================================================================
//  SECTION 5 - STATE / TRACKING
// =================================================================================================

var array<Zone>  zones        = array.new<Zone>()
var array<Zone>  archive      = array.new<Zone>()
var int          zoneIdSeq    = 0
var int          countActive  = 0
var int          countCollS   = 0
var int          countCollR   = 0
var int          lastCollBar  = -1
var int          lastCollDir  = 0
var float        flowEma      = na
var float        avgConf      = 0.0
var int          newZoneBar   = -1

float atrFast   = ta.atr(atrLen)
float atrSlow   = ta.atr(math.max(atrLen * 3, 30))
float volMa     = ta.sma(volume, 20)

// =================================================================================================
//  SECTION 6 - CORE CALCULATIONS  (FVG + OB detection, KB 3.10 / 3.11)
// =================================================================================================

// --------- FVG DETECTION (3-candle gap) ---------
// Bullish FVG: low > high[2] and middle candle confirms (close[1] > high[2])
// Bearish FVG: high < low[2] and middle candle confirms (close[1] < low[2])
bullFvgRaw = low > high[2] and close[1] > high[2]
bearFvgRaw = high < low[2] and close[1] < low[2]

float bullGap = low - high[2]
float bearGap = low[2] - high

bool bullFvgOk = bullFvgRaw and bullGap >= atrFast * fvgMinAtr
bool bearFvgOk = bearFvgRaw and bearGap >= atrFast * fvgMinAtr

// --------- DISPLACEMENT CANDLE FLAG (current bar) ---------
f_isDispBar(float o, float c, float h, float l, float impulse) =>
    float body = math.abs(c - o)
    float rng  = h - l
    float ratio = rng > 0 ? body / rng : 0.0
    (ratio >= 0.55) and (body >= impulse)

float impulseSize = atrFast * dispMult
bool isDispUp = f_isDispBar(open, close, high, low, impulseSize) and close > open
bool isDispDn = f_isDispBar(open, close, high, low, impulseSize) and close < open

// --------- ORDER BLOCK DETECTION (walk-back) ---------
// On a displacement up, walk back through 'obWindow' bars looking for the qualifying
// opposite-color (bearish) candle (Last Opposite / Extreme Opposite / Strict Volume).
f_findBullOb(int win) =>
    float bestTop = na
    float bestBot = na
    int   bestBar = na
    if isDispUp
        for j = 1 to math.min(win, bar_index)
            float oj = open[j], cj = close[j], hj = high[j], lj = low[j]
            float vj = nz(volume[j], 0.0)
            bool opposite  = cj < oj
            bool notWide   = (hj - lj) <= atrFast * 2.5
            float bodyRng  = (hj - lj) > 0 ? math.abs(cj - oj) / (hj - lj) : 0.0
            bool quality   = bodyRng >= 0.25
            bool volOk     = obMethod == "Strict Volume" ? (vj >= nz(volMa, 0.0)) : true
            if opposite and notWide and quality and volOk
                if obMethod == "Extreme Opposite"
                    // pick the LOWEST low across qualifying candles
                    if na(bestBot) or lj < bestBot
                        bestTop := hj
                        bestBot := lj
                        bestBar := bar_index - j
                else
                    // Last Opposite / Strict Volume - take the most recent (smallest j)
                    if na(bestBot)
                        bestTop := hj
                        bestBot := lj
                        bestBar := bar_index - j
    [bestTop, bestBot, bestBar]

f_findBearOb(int win) =>
    float bestTop = na
    float bestBot = na
    int   bestBar = na
    if isDispDn
        for j = 1 to math.min(win, bar_index)
            float oj = open[j], cj = close[j], hj = high[j], lj = low[j]
            float vj = nz(volume[j], 0.0)
            bool opposite  = cj > oj
            bool notWide   = (hj - lj) <= atrFast * 2.5
            float bodyRng  = (hj - lj) > 0 ? math.abs(cj - oj) / (hj - lj) : 0.0
            bool quality   = bodyRng >= 0.25
            bool volOk     = obMethod == "Strict Volume" ? (vj >= nz(volMa, 0.0)) : true
            if opposite and notWide and quality and volOk
                if obMethod == "Extreme Opposite"
                    if na(bestTop) or hj > bestTop
                        bestTop := hj
                        bestBot := lj
                        bestBar := bar_index - j
                else
                    if na(bestTop)
                        bestTop := hj
                        bestBot := lj
                        bestBar := bar_index - j
    [bestTop, bestBot, bestBar]

[_bullObTop, _bullObBot, _bullObBar] = f_findBullOb(obWindow)
[_bearObTop, _bearObBot, _bearObBar] = f_findBearOb(obWindow)
float obBuTop = detectOb ? _bullObTop : na
float obBuBot = detectOb ? _bullObBot : na
int   obBuBar = detectOb ? _bullObBar : na
float obBeTop = detectOb ? _bearObTop : na
float obBeBot = detectOb ? _bearObBot : na
int   obBeBar = detectOb ? _bearObBar : na

// --------- FLOW BIAS (used by probability and dashboard) ---------
float flowBias = f_flowBias(flowWindow)
flowEma := na(flowEma) ? flowBias : ta.ema(flowBias, math.max(5, flowWindow / 4))

// =================================================================================================
//  SECTION 7 - ZONE CONSTRUCTION + PRUNING
// =================================================================================================

// Helper: register a brand new superposition zone
f_newZone(int kind, float top, float bot, int leftBar) =>
    float center = (top + bot) * 0.5
    Zone z = Zone.new(
         id              = zoneIdSeq,
         leftBar         = leftBar,
         top             = top,
         bot             = bot,
         center          = center,
         kind            = kind,
         atrAt           = nz(atrFast, 0.0001),
         pSupport        = 0.5,
         pResistance     = 0.5,
         confidence      = 0.0,
         touches         = 0,
         firstTouchBar   = na,
         collapsed       = false,
         collapsedTo     = 0,
         collapseBar     = na,
         highProbAlerted = false,
         slices          = array.new<box>(),
         glow            = na,
         probTag         = na,
         collapseLbl     = na,
         collapseLine    = na
       )
    z

// Emit new zones on confirmed bars only (avoid repaint flicker)
if barstate.isconfirmed
    if detectFvg and bullFvgOk
        Zone z = f_newZone(1, low, high[2], bar_index - 1)
        array.push(zones, z)
        zoneIdSeq += 1
        newZoneBar := bar_index
    if detectFvg and bearFvgOk
        Zone z = f_newZone(-1, low[2], high, bar_index - 1)
        array.push(zones, z)
        zoneIdSeq += 1
        newZoneBar := bar_index
    if detectOb and not na(obBuTop) and not na(obBuBot)
        Zone z = f_newZone(2, obBuTop, obBuBot, nz(obBuBar, bar_index))
        array.push(zones, z)
        zoneIdSeq += 1
        newZoneBar := bar_index
    if detectOb and not na(obBeTop) and not na(obBeBot)
        Zone z = f_newZone(-2, obBeTop, obBeBot, nz(obBeBar, bar_index))
        array.push(zones, z)
        zoneIdSeq += 1
        newZoneBar := bar_index

// Memory cap (KB 8.6 - shift-on-overflow). Move oldest to archive if enabled.
while array.size(zones) > maxZones
    Zone old = array.shift(zones)
    if not na(old.glow)
        box.delete(old.glow)
    if array.size(old.slices) > 0
        for bx in old.slices
            box.delete(bx)
        array.clear(old.slices)
    if not na(old.probTag)
        label.delete(old.probTag)
    if not na(old.collapseLbl)
        label.delete(old.collapseLbl)
    if not na(old.collapseLine)
        line.delete(old.collapseLine)
    if keepArchived and old.collapsed
        array.push(archive, old)

// Archive trim
while array.size(archive) > archiveMax
    Zone old = array.shift(archive)
    if not na(old.glow)
        box.delete(old.glow)
    if array.size(old.slices) > 0
        for bx in old.slices
            box.delete(bx)
        array.clear(old.slices)
    if not na(old.probTag)
        label.delete(old.probTag)
    if not na(old.collapseLbl)
        label.delete(old.collapseLbl)
    if not na(old.collapseLine)
        line.delete(old.collapseLine)

// =================================================================================================
//  SECTION 8 - PROBABILITY ENGINE  (per-bar, per-zone update)
// =================================================================================================
//   Each live zone has two amplitudes pS (support) and pR (resistance).
//   We model:
//       distancePull  - magnitude only (closer => bigger weight)
//       directionLean - signed:  +1 favors support  (price above zone)
//                                -1 favors resistance (price below zone)
//       flowLean      - signed:  +1 favors support  (rising flow)
//                                -1 favors resistance (falling flow)
//
//   We combine into a single "side score" in [-1, +1]:
//       side = wDir*directionLean + wFlow*flowLean
//   Modulated by distance (so distant zones drift toward 0.5/0.5):
//       sideEff = side * distancePull
//   Then pS = 0.5 + 0.5 * sideEff,  pR = 1 - pS  (Born-rule analog).
// =================================================================================================

float wSum = f_normWeights(wDistance, wDirection, wFlow)

f_updateProb(Zone z) =>
    float pull       = f_distancePull(close, z.center, math.max(atrFast, z.atrAt * 0.5), distHalfLife)
    float dirLean    = f_directionBias(close, z.top, z.bot)
    float flowLean   = nz(flowEma, 0.0)
    float distWeight = wDistance / wSum
    float dirWeight  = wDirection / wSum
    float flwWeight  = wFlow / wSum
    // distWeight reshapes the magnitude of the side push
    float sideRaw  = dirWeight * dirLean + flwWeight * flowLean
    float sideEff  = sideRaw * (0.4 + 0.6 * (distWeight * pull + (1 - distWeight) * 0.5))
    sideEff := f_clamp(sideEff, -1.0, 1.0)
    float pS = f_clamp(0.5 + 0.5 * sideEff, 0.01, 0.99)
    float pR = 1.0 - pS
    z.pSupport    := pS
    z.pResistance := pR
    z.confidence  := math.abs(pS - 0.5) * 2.0

// =================================================================================================
//  SECTION 9 - COLLAPSE DETECTION + COMMITMENT
// =================================================================================================

// First-touch tolerance (in price units)
float touchSlack = collapseTouch * nz(atrFast, 0.0)

// Returns true if price has entered (touched) the zone now
f_priceInZone(Zone z) =>
    bool inZone = false
    if mitigateRule == "Wick"
        inZone := (high >= z.bot - touchSlack) and (low <= z.top + touchSlack)
    else
        inZone := (close >= z.bot - touchSlack) and (close <= z.top + touchSlack)
    inZone

// Returns true if a confirmed bar after touch held above (->S) or below (->R)
f_evaluateCollapse(Zone z, int barsSinceTouch) =>
    int dir = 0   // +1 S, -1 R, 0 still indeterminate
    if barsSinceTouch >= holdBars
        // measure last 'holdBars' bars' average position vs zone midpoint
        float avgClose = 0.0
        for k = 0 to holdBars - 1
            avgClose += nz(close[k], close)
        avgClose /= holdBars
        if avgClose > z.top
            dir := 1
        else if avgClose < z.bot
            dir := -1
        else
            // pick whichever side dominates by current price vs midpoint
            if close >= z.center
                dir := 1
            else
                dir := -1
    dir

// =================================================================================================
//  SECTION 10 - RENDERING  (single-hue zones with transparency-only gradient + glow + pulse)
// =================================================================================================
//
//  VISUAL DISCIPLINE (user-enforced):
//    1. Each zone uses ONE color family at a time.
//         - If z.pSupport    >= z.pResistance => zone is bull-leaning   -> use C_BULL
//         - If z.pResistance >  z.pSupport    => zone is bear-leaning   -> use C_BEAR
//         - Collapsed (committed) zone takes the committed-side hue permanently.
//         - Archived zones use the muted ghost color (still one family).
//    2. Vertical gradient inside the zone is achieved via TRANSPARENCY VARIATION of that
//       single hue (denser at the dominant edge, fading toward the opposite edge).
//    3. Animated pulse on pure-superposition zones modulates alpha of the SAME dominant hue.
//       (No third color is ever introduced.)
//    4. The chart therefore renders with at most 2 visible hues (bull family + bear family)
//       plus the background. No rainbow blends.
//
//  Intensity rule:  visual punch  = max(P_support, P_resistance)  -> drives base alpha
//                   higher P => more opaque (denser) overall fill.
// =================================================================================================

// Returns the right-edge bar for a zone (extends right if enabled)
f_zoneRight(Zone z) =>
    extendZones ? bar_index + extendBars : math.max(z.leftBar + extendBars, bar_index)

// Clears the slice boxes / annotations for a zone
f_clearZoneArt(Zone z) =>
    if array.size(z.slices) > 0
        for bx in z.slices
            box.delete(bx)
        array.clear(z.slices)
    if not na(z.glow)
        box.delete(z.glow)
        z.glow := na
    if not na(z.probTag)
        label.delete(z.probTag)
        z.probTag := na

// Pick the dominant single hue for a zone (one color family - never blended)
// Bull-leaning  -> C_BULL   (lavender on default theme)
// Bear-leaning  -> C_BEAR   (magenta on default theme)
// Archived      -> C_GHOST  (muted)
f_zoneHue(Zone z, bool isArchived) =>
    color hue = C_BULL
    if isArchived
        hue := C_GHOST
    else if z.collapsed
        hue := z.collapsedTo == 1 ? C_BULL : C_BEAR
    else
        hue := z.pSupport >= z.pResistance ? C_BULL : C_BEAR
    hue

// Renders a single zone (called on barstate.islast)
//   - Single-hue (from f_zoneHue) for all slices, glow, border, label.
//   - Gradient achieved via transparency only:
//       dominant side  = densest (lowest alpha)
//       opposite side  = faintest (highest alpha)
//     For a bull-leaning zone, the bottom (support edge) is densest; top fades.
//     For a bear-leaning zone, the top (resistance edge) is densest; bottom fades.
//   - Pulse: when confidence < 0.30 (P near 0.5), modulate alpha of the SAME hue.
f_renderZone(Zone z, bool isArchived) =>
    f_clearZoneArt(z)

    color hue    = f_zoneHue(z, isArchived)
    int rightBar = f_zoneRight(z)
    int safeLeft = f_safeStartBar(z.leftBar)
    float h      = math.max(z.top - z.bot, syminfo.mintick)
    int   N      = math.max(2, gradSlices)

    // Determine direction the dense edge sits:
    //   bullDense = true  -> bottom is dense, top fades  (support-leaning zone)
    //   bullDense = false -> top is dense,    bottom fades (resistance-leaning zone)
    bool bullDense = false
    if isArchived
        bullDense := z.collapsedTo == 1
    else if z.collapsed
        bullDense := z.collapsedTo == 1
    else
        bullDense := z.pSupport >= z.pResistance

    // Intensity = max(P_support, P_resistance) -> drives base alpha
    float intensity = isArchived ? 0.25 : math.max(z.pSupport, z.pResistance)

    // Pulse only when uncertain (P near 0.5) and not collapsed
    int pulse = 0
    if animatePulse and (not isArchived) and (not z.collapsed) and z.confidence < 0.30
        pulse := f_pulseAlpha(bar_index, pulsePeriod, pulseAmp)

    // Map intensity (0..1) onto a base alpha range. Higher intensity => denser (lower alpha).
    int aLo = baseAlphaFill - 22         // densest end (dominant edge)
    int aHi = baseAlphaFill + 12         // faintest end (opposite edge)
    aLo := int(f_clamp(float(aLo), 30.0, 96.0))
    aHi := int(f_clamp(float(aHi), 40.0, 98.0))
    // Apply intensity bias: high P => shift both edges denser by up to 14 alpha
    int intBias = int(math.round((1.0 - intensity) * 14.0))
    aLo += intBias
    aHi += intBias
    aLo := int(f_clamp(float(aLo + pulse), 0.0, 98.0))
    aHi := int(f_clamp(float(aHi + pulse), 0.0, 98.0))

    if showGradient and not isArchived
        // Stacked slices, each with the SAME hue, only transparency varies.
        for i = 0 to N - 1
            float sliceTop = z.top - (h * i) / N
            float sliceBot = z.top - (h * (i + 1)) / N
            // ratio = position from top (0) to bottom (1)
            float ratio    = i / float(math.max(N - 1, 1))
            // If bullDense (support-leaning), bottom dense -> alpha decreases with ratio
            // If bearDense (resistance-leaning), top dense -> alpha increases with ratio
            float alphaT   = bullDense ? (aHi - (aHi - aLo) * ratio) : (aLo + (aHi - aLo) * ratio)
            int   sliceAlpha = int(f_clamp(alphaT, 0.0, 98.0))
            color cellCol    = color.new(hue, sliceAlpha)
            box bx = box.new(left=safeLeft, top=sliceTop, right=rightBar, bottom=sliceBot,
                 border_color=color.new(hue, 99), border_width=0, bgcolor=cellCol,
                 xloc=xloc.bar_index)
            array.push(z.slices, bx)
    else
        // Flat single box fallback (single-hue, mid alpha)
        int flatAlpha = isArchived ? 88 : int(f_clamp(float((aLo + aHi) / 2), 0.0, 98.0))
        box bx = box.new(left=safeLeft, top=z.top, right=rightBar, bottom=z.bot,
             border_color=color.new(hue, 92), border_width=0,
             bgcolor=color.new(hue, flatAlpha), xloc=xloc.bar_index)
        array.push(z.slices, bx)

    // GLOW BORDER : same hue, thickness scales inversely with confidence
    // (uncertain zones get the brighter halo so the user spots them).
    if showGlow and not isArchived
        int glowW     = int(math.round(1.0 + (1.0 - z.confidence) * 3.0))
        int glowAlpha = int(f_clamp(
             float(baseAlphaBorder - int(glowIntensity * 0.25) + (pulse / 2)),
             0.0, 92.0))
        z.glow := box.new(left=safeLeft, top=z.top, right=rightBar, bottom=z.bot,
             border_color=color.new(hue, glowAlpha), border_width=glowW,
             bgcolor=na, xloc=xloc.bar_index)

    // PROBABILITY LABEL : text is dominant hue, background is dark frame for contrast
    if showProbLabel and not isArchived and not z.collapsed
        kindTag = z.kind ==  1 ? "FVG_BU" : z.kind == -1 ? "FVG_BE" : z.kind ==  2 ? "OB_BU" : z.kind == -2 ? "OB_BE" : "?"
        string typeLine = showZoneType ? "[" + kindTag + "]  " : ""
        // Show the dominant probability prominently with side tag
        bool bullSide = z.pSupport >= z.pResistance
        float dominantP = bullSide ? z.pSupport : z.pResistance
        string sideTag = bullSide ? "S" : "R"
        string txt = typeLine + sideTag + " " + f_fmt(dominantP * 100.0, 0) + "%"
        z.probTag := label.new(x=rightBar, y=z.center, text=txt,
             style=label.style_label_left, color=color.new(C_FRAME, 35),
             textcolor=hue, size=f_strToSize(labelSize), xloc=xloc.bar_index,
             yloc=yloc.price)

// Render collapse marker
f_renderCollapseMarker(Zone z) =>
    if showCollapse and z.collapsed
        bool toSupport = z.collapsedTo == 1
        txt = useFancyGlyph ? (toSupport ? "(+)->S" : "(+)->R") : (toSupport ? "S" : "R")
        color mcol = toSupport ? C_BULL : C_BEAR
        if not na(z.collapseLbl)
            label.delete(z.collapseLbl)
        z.collapseLbl := label.new(x=z.collapseBar, y=z.center, text=txt,
             style=toSupport ? label.style_label_up : label.style_label_down,
             color=color.new(mcol, 25), textcolor=color.white,
             size=f_strToSize(markerSize), xloc=xloc.bar_index, yloc=yloc.price)
        if showCollapseLn
            if not na(z.collapseLine)
                line.delete(z.collapseLine)
            int rb = f_zoneRight(z)
            z.collapseLine := line.new(x1=z.collapseBar, y1=z.center, x2=rb, y2=z.center,
                 color=color.new(mcol, 50), width=1, style=line.style_dashed,
                 xloc=xloc.bar_index)

// =================================================================================================
//  SECTION 11 - PER-BAR ZONE PROCESSING LOOP
// =================================================================================================

// Phase A: update probabilities, detect touches, and run collapse logic
if array.size(zones) > 0
    for z in zones
        if not z.collapsed
            f_updateProb(z)
            // High-probability gate (one-shot alert)
            if (not z.highProbAlerted) and math.max(z.pSupport, z.pResistance) >= highProbThr
                z.highProbAlerted := true
                if enaHighProb
                    alert("SZP: High-Probability Zone (p="
                         + f_fmt(math.max(z.pSupport, z.pResistance) * 100.0, 0) + "%)",
                         alert.freq_once_per_bar)
            // Touch detection (use confirmed bar to avoid mid-bar flicker)
            if barstate.isconfirmed and f_priceInZone(z)
                if na(z.firstTouchBar)
                    z.firstTouchBar := bar_index
                z.touches += 1
            // Collapse evaluation
            if not na(z.firstTouchBar)
                int barsSince = bar_index - z.firstTouchBar
                int dir = f_evaluateCollapse(z, barsSince)
                if dir != 0
                    z.collapsed    := true
                    z.collapsedTo  := dir
                    z.collapseBar  := bar_index
                    lastCollBar    := bar_index
                    lastCollDir    := dir
                    if dir == 1
                        countCollS += 1
                        if enaCollapseS
                            alert("SZP: Collapse to Support @ " + f_fmt(z.center, 4),
                                 alert.freq_once_per_bar)
                    else
                        countCollR += 1
                        if enaCollapseR
                            alert("SZP: Collapse to Resistance @ " + f_fmt(z.center, 4),
                                 alert.freq_once_per_bar)

// Phase B: count active + compute avg confidence (for dashboard)
if barstate.islast
    int liveCount = 0
    float confSum = 0.0
    for z in zones
        if not z.collapsed
            liveCount += 1
            confSum += z.confidence
    countActive := liveCount
    avgConf     := liveCount > 0 ? confSum / liveCount : 0.0

// Phase C: render zones (only on islast to stay within draw limits)
if barstate.islast
    for z in zones
        if showOnlySuper and z.collapsed
            // skip rendering collapsed zones if filter requested
            f_clearZoneArt(z)
            if not na(z.collapseLbl)
                label.delete(z.collapseLbl)
                z.collapseLbl := na
            if not na(z.collapseLine)
                line.delete(z.collapseLine)
                z.collapseLine := na
        else
            f_renderZone(z, false)
            if z.collapsed
                f_renderCollapseMarker(z)

    if keepArchived and not showOnlySuper
        for z in archive
            f_renderZone(z, true)
            f_renderCollapseMarker(z)

// =================================================================================================
//  SECTION 12 - NEW ZONE ALERT
// =================================================================================================

if barstate.isconfirmed and newZoneBar == bar_index and enaNewZone
    alert("SZP: New Superposition Zone formed (price=" + f_fmt(close, 4) + ")",
         alert.freq_once_per_bar)

// =================================================================================================
//  SECTION 13 - DASHBOARD (9 rows: header + 8 metrics)
// =================================================================================================

dashHeaderTxt = "SCHRODINGER ZONES"
dashRowCount  = 9
dashColCount  = 2

var table dash = table.new(f_strToPos(dashPosStr), dashColCount, dashRowCount,
     bgcolor      = na,
     frame_color  = C_FRAME,
     frame_width  = 1,
     border_color = color.new(C_FRAME, 65),
     border_width = 1)

// Pick highest-prob zone (one-shot scan)
f_highestProbZone() =>
    Zone best = na
    float bestP = -1.0
    if array.size(zones) > 0
        for z in zones
            if not z.collapsed
                float p = math.max(z.pSupport, z.pResistance)
                if p > bestP
                    bestP := p
                    best  := z
    [best, bestP]

f_nearestZoneDist() =>
    float bestDist = na
    int   bestKind = 0
    if array.size(zones) > 0
        for z in zones
            if not z.collapsed
                float d = math.abs(close - z.center)
                if na(bestDist) or d < bestDist
                    bestDist := d
                    bestKind := z.kind
    [bestDist, bestKind]

if showDash and barstate.islast
    [bestZone, bestP] = f_highestProbZone()
    [nearDist, nearKind] = f_nearestZoneDist()
    bool   haveBest   = not na(bestZone)
    string bestSide   = haveBest ? (bestZone.pSupport >= bestZone.pResistance ? "SUPPORT" : "RESISTANCE") : "-"
    color  bestCol    = haveBest ? (bestZone.pSupport >= bestZone.pResistance ? C_BULL : C_BEAR) : C_SUB
    string bestPrice  = haveBest ? f_fmt(bestZone.center, 4) : "-"
    string bestProb   = haveBest ? (f_fmt(bestP * 100.0, 1) + "%") : "-"

    nearStr  = na(nearDist) ? "-" : (f_fmt(nearDist, 4) + "  (" + f_fmt(atrFast > 0 ? (nearDist / atrFast) : 0.0, 2) + " ATR)")
    nearTag  = nearKind ==  1 ? "FVG_BU" : nearKind == -1 ? "FVG_BE" : nearKind ==  2 ? "OB_BU" : nearKind == -2 ? "OB_BE" : "-"

    lastCollStr = lastCollBar < 0 ? "none" : (str.tostring(bar_index - lastCollBar) + " bars ago (" + (lastCollDir == 1 ? "->S" : "->R") + ")")

    string flowTxt = na(flowEma) ? "-" : f_fmt(nz(flowEma, 0.0), 3)
    flowSta = na(flowEma) ? "FLAT" : flowEma >  0.10 ? "BULLISH" : flowEma < -0.10 ? "BEARISH" : "NEUTRAL"
    flowCol = flowEma >  0.10 ? C_BULL : flowEma < -0.10 ? C_BEAR : C_SUB

    color rowABg = dashGradient ? f_rowGrad(C_FRAME, 1, dashRowCount, 78, 90) : color.new(C_FRAME, 84)
    color rowBBg = dashGradient ? f_rowGrad(C_FRAME, 2, dashRowCount, 78, 90) : color.new(C_FRAME, 86)

    // Header (row 0)
    table.cell(dash, 0, 0, dashHeaderTxt, text_color=C_TEXT, bgcolor=C_HDR_BG,
         text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(dash, 1, 0, "v1.0 (+) ", text_color=C_MID, bgcolor=C_HDR_BG,
         text_font_family=font.family_monospace, text_halign=text.align_right)

    // Row 1 - active superposition zones
    table.cell(dash, 0, 1, "Active Superposition", text_color=C_TEXT,
         bgcolor=rowABg, text_font_family=font.family_monospace)
    table.cell(dash, 1, 1, str.tostring(countActive), text_color=C_MID,
         bgcolor=rowABg, text_font_family=font.family_monospace,
         text_halign=text.align_right)

    // Row 2 - collapses to support
    table.cell(dash, 0, 2, "Collapsed -> Support", text_color=C_TEXT,
         bgcolor=rowBBg, text_font_family=font.family_monospace)
    table.cell(dash, 1, 2, str.tostring(countCollS), text_color=C_BULL,
         bgcolor=rowBBg, text_font_family=font.family_monospace,
         text_halign=text.align_right)

    // Row 3 - collapses to resistance
    table.cell(dash, 0, 3, "Collapsed -> Resistance", text_color=C_TEXT,
         bgcolor=rowABg, text_font_family=font.family_monospace)
    table.cell(dash, 1, 3, str.tostring(countCollR), text_color=C_BEAR,
         bgcolor=rowABg, text_font_family=font.family_monospace,
         text_halign=text.align_right)

    // Row 4 - highest-probability zone
    table.cell(dash, 0, 4, "Highest-Prob Zone", text_color=C_TEXT,
         bgcolor=rowBBg, text_font_family=font.family_monospace)
    table.cell(dash, 1, 4, haveBest ? (bestPrice + " " + bestSide + " " + bestProb) : "-",
         text_color=bestCol, bgcolor=rowBBg, text_font_family=font.family_monospace,
         text_halign=text.align_right)

    // Row 5 - nearest zone distance
    table.cell(dash, 0, 5, "Nearest Zone (" + nearTag + ")", text_color=C_TEXT,
         bgcolor=rowABg, text_font_family=font.family_monospace)
    table.cell(dash, 1, 5, nearStr, text_color=C_MID,
         bgcolor=rowABg, text_font_family=font.family_monospace,
         text_halign=text.align_right)

    // Row 6 - recent collapse
    table.cell(dash, 0, 6, "Recent Collapse", text_color=C_TEXT,
         bgcolor=rowBBg, text_font_family=font.family_monospace)
    color recentCol = lastCollDir == 1 ? C_BULL : lastCollDir == -1 ? C_BEAR : C_SUB
    table.cell(dash, 1, 6, lastCollStr, text_color=recentCol, bgcolor=rowBBg,
         text_font_family=font.family_monospace, text_halign=text.align_right)

    // Row 7 - flow bias
    table.cell(dash, 0, 7, "Flow Bias", text_color=C_TEXT,
         bgcolor=rowABg, text_font_family=font.family_monospace)
    table.cell(dash, 1, 7, flowSta + " (" + flowTxt + ")",
         text_color=flowCol, bgcolor=rowABg,
         text_font_family=font.family_monospace, text_halign=text.align_right)

    // Row 8 - avg zone confidence
    table.cell(dash, 0, 8, "Avg Zone Confidence", text_color=C_TEXT,
         bgcolor=rowBBg, text_font_family=font.family_monospace)
    color confCol = avgConf >= 0.60 ? C_BULL : avgConf >= 0.30 ? C_MID : C_SUB
    table.cell(dash, 1, 8, f_fmt(avgConf * 100.0, 1) + "%",
         text_color=confCol, bgcolor=rowBBg,
         text_font_family=font.family_monospace, text_halign=text.align_right)

// =================================================================================================
//  SECTION 14 - ALERTCONDITIONS  (declared once so they appear in the Alerts panel)
// =================================================================================================

newZoneCondition       = barstate.isconfirmed and (newZoneBar == bar_index)
collapseSupCondition   = barstate.isconfirmed and (lastCollBar == bar_index) and (lastCollDir ==  1)
collapseResCondition   = barstate.isconfirmed and (lastCollBar == bar_index) and (lastCollDir == -1)
highProbCondition      = false
if array.size(zones) > 0
    for z in zones
        if (not z.collapsed) and math.max(z.pSupport, z.pResistance) >= highProbThr
            highProbCondition := true
            break

alertcondition(newZoneCondition,     title="New Superposition Zone",
     message="SZP: New superposition zone formed at {{close}}")
alertcondition(collapseSupCondition, title="Collapse to Support",
     message="SZP: Zone collapse committed to SUPPORT at {{close}}")
alertcondition(collapseResCondition, title="Collapse to Resistance",
     message="SZP: Zone collapse committed to RESISTANCE at {{close}}")
alertcondition(highProbCondition,    title="High-Probability Zone",
     message="SZP: A superposition zone exceeded the high-probability threshold")

// =================================================================================================
//  SECTION 15 - HIDDEN ANCHORS  (for chart auto-scale + legend ordering)
// =================================================================================================
// Plotting hidden series so the indicator behaves nicely on overlay-add and Strategy Tester scaling.
plot(na, title="_anchor_top",    color=na, display=display.none)
plot(na, title="_anchor_bot",    color=na, display=display.none)
plot(countActive, title="Active Zones", color=color.new(C_MID, 100), display=display.none)
plot(countCollS,  title="Support Collapses", color=color.new(C_BULL, 100), display=display.none)
plot(countCollR,  title="Resistance Collapses", color=color.new(C_BEAR, 100), display=display.none)
plot(avgConf,     title="Avg Confidence", color=color.new(C_MID, 100), display=display.none)

// =================================================================================================
//  END OF FILE - SCHRODINGER ZONE PROBABILITY [JOAT]
// =================================================================================================
````

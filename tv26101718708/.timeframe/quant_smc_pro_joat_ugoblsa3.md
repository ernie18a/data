# Quant SMC Pro [JOAT]

- url: https://www.tradingview.com/script/ugOBLSa3-Quant-SMC-Pro-JOAT/
- type: indicator
- pine_id: PUB;b3beb033534e4a1daac8d5ebba7c3373
- version: 1.0

## Description

[b]QUANT SMC PRO [JOAT][/b]

A complete Smart Money Concepts engine rebuilt from first principles — pivots, structure, order blocks, fair value gaps, liquidity, premium/discount, HTF context, and a 0–100 confluence score per zone — wired together so every element actually [i]talks[/i] to every other element. This is the SMC toolkit you build when you have read enough versions of "BOS / CHoCH / OB" to know that the difference between a coin-flip and a real signal is the [b]quality[/b] of the underlying pivots, the [b]filter[/b] on the order-block detection, and the [b]scoring[/b] of how much confluence each zone actually carries.

[image]https://www.tradingview.com/x/VuOS1xJF/[/image]

[b]Pivot engine — adaptive, not arbitrary[/b]

A clean structure read is impossible if the pivots themselves are noisy. Quant SMC Pro ships two pivot engines and lets you pick:

[list]
[*] [b]Adaptive ZigZag[/b] (default) — a pivot is confirmed only after price retraces by an ATR-multiple from the candidate extreme. The threshold is volatility-aware, so the engine produces clean swing structure across very different instruments without retuning.
[*] [b]Fixed Window[/b] — the classic [i]N-bar look-left, N-bar look-right[/i] confirmation. Use it on instruments where you want strict symmetry rather than ATR-relative confirmation.
[/list]

A separate, lighter minor-pivot window drives the minor structure layer so you can see internal liquidity grabs without polluting the major read.

[b]Market structure[/b]

Both major and minor structure are tracked. BOS (break of structure) and CHoCH (change of character) are labelled in the palette colour at the breaking bar. MSS (market structure shift) is only printed when the [i]requireDisp[/i] gate is satisfied: the breaking candle must be a real impulse — strong body, range above an ATR multiple. This single filter eliminates the bulk of the "CHoCH on a doji" false positives that plague off-the-shelf SMC scripts.

[pine]
// Displacement requirement for MSS confirmation (illustrative)
float bodyAbs   = math.abs(close - open)
float rangeBar  = high - low
bool  isImpulse = bodyAbs >= rangeBar * 0.6 and rangeBar >= ta.atr(14) * dispMult
bool  isMSS     = isCHoCH and isImpulse
[/pine]

[b]Order Blocks — two detection methods[/b]

OBs are detected at the structural origin of the move that broke structure, not blindly at the last opposite candle. Two methods are exposed:

[list]
[*] [b]Structural Extreme[/b] (default, stricter) — scans backward inside the walk-back window and selects the most-extreme qualifying opposite-color candle. This is the cleaner output and the one you want on a working chart.
[*] [b]Last Opposite Candle[/b] — the simpler heuristic. Useful for comparison and for replicating the look of older SMC scripts.
[/list]

Optional above-average-volume filtering, configurable mitigation rule (wick-touch vs close-through), per-side count cap (1–10), and a structural walk-back window let the OBs stay relevant instead of cluttering up old territory.

[b]Fair Value Gaps — ATR-filtered[/b]

FVGs use the standard three-candle imbalance definition, but only register when the gap exceeds a configurable ATR multiple. This is the difference between a clean chart and a wallpaper of 1-tick gaps. Hard caps on count per side, optional extension bars, and an optional "keep mitigated FVGs faded" toggle (off by default to prevent accumulation) round out the controls.

[b]JOAT enhancements (new vs every other SMC script)[/b]

Three concepts most public SMC scripts skip — implemented here as proper, gated layers:

[list]
[*] [b]Inversion FVGs (iFVG)[/b] — when an FVG is mitigated and the polarity flips within a configurable bar window, the gap is re-rendered with a multi-stop gradient so you can see the [i]flipped[/i] zone. Off by default because it adds visual density; turn it on when you specifically want to read polarity flips.
[*] [b]Breaker Blocks[/b] — an OB that gets mitigated and then [i]holds[/i] on the opposite side for a configurable bar count is re-tagged as a Breaker Block in its own palette color. This is one of the strongest re-entry concepts in SMC and almost never implemented correctly in public scripts.
[*] [b]Mitigation Block tag[/b] — the first OB created after a BOS is tagged "MB" so you can read which block carries the most structural significance.
[/list]

[b]Liquidity — equal highs / lows and real sweeps[/b]

Equal highs / lows are detected with an ATR-relative tolerance over a configurable scan depth. Liquidity sweeps are detected against [b]actual structural pivots[/b] (the minor-pivot output, not a rolling [b]ta.highest[/b]) — so a sweep is registered when a wick punctures a recent pivot extreme and the bar closes back inside, which is what the term actually means in the textbook. A cooldown prevents double-prints of the same sweep.

[b]Premium / Discount array[/b]

Two equilibrium methods:

[list]
[*] [b]AVWAP Equilibrium[/b] (default) — equilibrium is anchored to the most recent major structure event, so the PD array [i]drifts with trend[/i] rather than re-anchoring on every minor pivot. This is the institutional read.
[*] [b]Range Midpoint[/b] — the classic 50% of the most recent major leg.
[/list]

A toggleable [b]multi-stop gradient render[/b] paints premium and discount as shaded regions instead of just lines. Configurable stop count keeps it tunable.

[b]HTF context[/b]

Optional previous-day, previous-week, and previous-month H / L overlays in their own per-timeframe colours. Optional midpoint lines. When enabled, the HTF read also contributes to the confluence score — because no zone is really meaningful without HTF agreement.

[image]https://www.tradingview.com/x/6QpM53JA/[/image]

[b]Confluence Score (0–100)[/b]

Every order block carries an aggregate confluence score derived from:

[list]
[*] Zone size relative to ATR
[*] Displacement quality of the move that produced it
[*] Volume on the originating bar relative to the rolling average
[*] Overlap with active FVGs
[*] (Optional) HTF level proximity
[/list]

A "Hide zones below score" input lets you mute lower-quality blocks. A separate alert threshold fires when a zone above your minimum score is created. The score is also rendered into the confluence heatmap dashboard.

[b]Dashboard (confluence heatmap)[/b]

A compact, monospaced table positionable to any of nine corners with a per-row vertical alpha gradient. Reads the current bias, nearest premium / discount zone, count of active OBs, count of active FVGs, and the highest confluence score on the chart. Background transparency is user-controlled so it never visually competes with structure.

[b]How to read it[/b]

The intended workflow is structure-first, confluence-second. Wait for a BOS or MSS in the direction you want to trade. Look at the OB or breaker block at the origin of the move — its confluence score is your edge proxy. If the zone has an iFVG or active FVG overlap, the score will reflect it. HTF agreement (previous-day midpoint, previous-week high, etc.) is the final filter. Liquidity sweeps before the structural break are a particularly clean confluence — they indicate the move broke [i]because[/i] liquidity was taken first.

[b]Originality / what's reused[/b]

The SMC vocabulary (BOS, CHoCH, MSS, OB, FVG, premium/discount) is, of course, public-domain market-structure language. The implementations here — the adaptive ATR-confirmed pivot engine, the structural-extreme OB scan, the iFVG gradient render, the breaker block detection, the mitigation block tagging, the AVWAP-anchored PD array, the confluence-score aggregation, and the heatmap dashboard — are written from scratch and tuned together. No third-party code is reused.

[b]Open source[/b]

Published open-source under the default Mozilla Public License 2.0. The source is fully readable: every helper function is documented inline, every input has a tooltip, and the file is sectioned with banner headers so you can navigate it like a textbook chapter. If you want to fork it, please keep the credit and please make it materially better — that is what open-source SMC actually needs.

[b]Limitations[/b]

SMC is a [i]structural[/i] read, not a signal generator — Quant SMC Pro does not print buy/sell labels. It prints zones and structure; you decide the entry. Equal H/L detection and structural sweeps rely on minor-pivot output, so on very illiquid instruments those layers may be sparse. Confluence scoring is heuristic by definition — it ranks zones by features that historically correlated with significance; it does not predict reactions.

—

-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title="Quant SMC Pro [JOAT]", shorttitle="SMC [JOAT]",
     overlay           = true,
     max_lines_count   = 500,
     max_labels_count  = 500,
     max_boxes_count   = 500,
     max_bars_back     = 500)

// =============================================================================
//  SECTION 1 - INPUTS
// =============================================================================
//  All inputs grouped with box-drawing headers so the settings panel is easy
//  to navigate. Each block maps to one functional subsystem.
// -----------------------------------------------------------------------------

// --- General -----------------------------------------------------------------
g_general   = "General"
displayMode = input.string("Live", "Display Mode",
     options = ["Live", "All History"], group = g_general,
     tooltip = "Live keeps only the most recent structure elements on screen and trims old drawings to stay under the 500-object cap.")
paintBars   = input.bool(false, "Paint Candles by Minor Bias", group = g_general)
useCustomBg = input.bool(false, "Use Background Tint", group = g_general,
     tooltip = "Apply a subtle bgcolor tint matched to the palette.")

// --- Pivot engine -----------------------------------------------------------
g_pivot     = "Pivot Engine"
pivEngine   = input.string("Adaptive ZigZag", "Major Pivot Engine",
     options = ["Adaptive ZigZag", "Fixed Window"], group = g_pivot,
     tooltip = "Adaptive confirms a pivot only after price retraces by ATR x multiplier (preferred). Fixed uses a static bar window (classic).")
pivWindow   = input.int(25, "Fixed Window Length", minval = 5, group = g_pivot)
pivAtrMult  = input.float(1.8, "Adaptive ATR Threshold",
     minval = 0.2, step = 0.1, group = g_pivot)
microWin    = input.int(4, "Minor Pivot Window",
     minval = 2, maxval = 20, group = g_pivot)
showSwings  = input.bool(false, "Label Swings (HH / HL / LH / LL)", group = g_pivot)

// --- Market structure -------------------------------------------------------
g_struct    = "Market Structure"
showMajor   = input.bool(true, "Show Major Structure", group = g_struct)
showMinor   = input.bool(true, "Show Minor Structure", group = g_struct)
requireDisp = input.bool(true, "MSS requires displacement candle", group = g_struct,
     tooltip = "When enabled, a CHoCH is labelled MSS only if the breaking candle is an impulse (strong body, large range).")
dispMult    = input.float(1.2, "Displacement ATR Multiplier",
     minval = 0.3, step = 0.1, group = g_struct)
bullColIn   = input.color(#00CED1, "Bull Color", group = g_struct)
bearColIn   = input.color(#9400D3, "Bear Color", group = g_struct)

// --- Order Blocks -----------------------------------------------------------
g_ob        = "Order Blocks"
showOB      = input.bool(true, "Show Order Blocks", group = g_ob)
obMethod    = input.string("Structural Extreme", "Detection Method",
     options = ["Structural Extreme", "Last Opposite Candle"], group = g_ob,
     tooltip = "Structural Extreme scans the structural window and picks the most-extreme qualifying opposite-color candle (stricter, cleaner zones). Last Opposite is a simpler heuristic.")
obMax       = input.int(3, "Max OBs per side", minval = 1, maxval = 10, group = g_ob,
     tooltip = "Hard cap on number of bull and bear OBs kept on screen. Keep this small (2-4) for a clean chart.")
obVolReq    = input.bool(true, "Require above-average volume", group = g_ob)
obVolMult   = input.float(1.25, "Volume Multiplier",
     minval = 1.0, step = 0.05, group = g_ob)
obMitig     = input.string("Wick", "Mitigation Rule",
     options = ["Wick", "Close"], group = g_ob)
obWalkBars  = input.int(30, "Walk-Back Window (bars)",
     minval = 5, maxval = 100, group = g_ob,
     tooltip = "How many bars back to scan for the structural-origin candle.")

// --- FVG --------------------------------------------------------------------
g_fvg       = "Fair Value Gaps"
showFvg     = input.bool(true, "Show FVGs", group = g_fvg)
fvgMax      = input.int(4, "Max FVGs per side", minval = 1, maxval = 15, group = g_fvg,
     tooltip = "Hard cap. Small values (3-5) keep the chart readable.")
fvgMinAtr   = input.float(0.40, "Min FVG Size (ATR multiples)",
     minval = 0.0, step = 0.05, group = g_fvg,
     tooltip = "Filter out small FVGs. Raise this if too many tiny gaps clutter the chart.")
fvgFade     = input.bool(false, "Keep mitigated FVGs faded", group = g_fvg,
     tooltip = "Off by default - prevents historical FVGs from accumulating as background clutter.")
fvgExtend   = input.int(10, "Extend Bars", minval = 0, group = g_fvg)

// --- iFVG (NEW JOAT enhancement) --------------------------------------------
g_ifvg      = "Inversion FVGs (iFVG) [NEW]"
showIFvg    = input.bool(false, "Show iFVG flips", group = g_ifvg,
     tooltip = "Off by default - turn on only when you specifically want to see polarity flips. When ON, this adds significant visual density.")
ifvgFlipBars = input.int(40, "Max bars after mitigation to flip",
     minval = 5, maxval = 200, group = g_ifvg)
ifvgGradStops = input.int(4, "Gradient Stops",
     minval = 2, maxval = 12, group = g_ifvg,
     tooltip = "Sub-bands per iFVG. Keep low (3-5) to avoid heavy density.")

// --- Breaker Block (NEW JOAT enhancement) -----------------------------------
g_brk       = "Breaker Blocks [NEW]"
showBrk     = input.bool(false, "Show Breaker Blocks", group = g_brk,
     tooltip = "Off by default - turn on only when you want to track mitigated OBs that flipped role. Adds visual density.")
brkHoldBars = input.int(15, "Bars to confirm 'hold'",
     minval = 3, maxval = 60, group = g_brk)
brkColIn    = input.color(#4DFFB5, "Breaker Block Color", group = g_brk,
     tooltip = "Default cyberpunk mint - within the palette.")

// --- Mitigation Block (NEW JOAT enhancement) --------------------------------
g_mb        = "Mitigation Blocks [NEW]"
showMb      = input.bool(false, "Tag first OB after BOS", group = g_mb,
     tooltip = "Off by default. When ON, the first OB after a BOS is tagged 'MB'.")
mbColIn     = input.color(#E6F4FF, "MB Tag Color", group = g_mb,
     tooltip = "Default near-white for a clean tag color in the palette.")

// --- Liquidity --------------------------------------------------------------
g_liq       = "Liquidity"
showEq      = input.bool(true, "Show Equal Highs / Lows", group = g_liq)
eqLookback  = input.int(100, "EQ Scan Depth (bars)", minval = 5, group = g_liq)
eqTol       = input.float(0.18, "EQ Tolerance (ATR)",
     minval = 0.0, step = 0.02, group = g_liq)
showSweep   = input.bool(true, "Show Liquidity Sweeps", group = g_liq,
     tooltip = "Detects wicks that poke through a recent minor pivot and close back inside. Reference levels are actual structural highs/lows, not rolling max/min.")
sweepCool   = input.int(8, "Sweep Cooldown (bars)",
     minval = 1, maxval = 50, group = g_liq)

// --- Premium / Discount -----------------------------------------------------
g_pd        = "Premium / Discount"
showPD      = input.bool(true, "Show PD Array", group = g_pd)
pdMethod    = input.string("AVWAP Equilibrium", "Equilibrium Method",
     options = ["AVWAP Equilibrium", "Range Midpoint"], group = g_pd,
     tooltip = "AVWAP is anchored to the most recent major structure event - equilibrium drifts with trend. Range Midpoint is the classic 50% rule.")
showPDgrad  = input.bool(true, "Render PD Zones as Gradient",
     group = g_pd,
     tooltip = "JOAT enhancement: render premium and discount as gradient-shaded regions instead of just lines.")
pdGradStops = input.int(6, "PD Gradient Stops",
     minval = 2, maxval = 12, group = g_pd)

// --- HTF levels -------------------------------------------------------------
g_htf       = "HTF Levels"
showPDH     = input.bool(false, "Previous Day H/L",   group = g_htf)
pdCol       = input.color(#6c5ce7, "Day Color",       group = g_htf)
showPWH     = input.bool(false, "Previous Week H/L",  group = g_htf)
pwCol       = input.color(#0984e3, "Week Color",      group = g_htf)
showPMH     = input.bool(false, "Previous Month H/L", group = g_htf)
pmCol       = input.color(#d63031, "Month Color",     group = g_htf)
showMid     = input.bool(false, "Show Midpoints (50%)", group = g_htf)
htfBiasCalc = input.bool(true, "Use HTF for Confluence Alignment",
     group = g_htf,
     tooltip = "When enabled, HTF closes vs HTF midpoints contribute to the confluence score.")

// --- Confluence -------------------------------------------------------------
g_score     = "Confluence Score"
showScore   = input.bool(false, "Show Zone Scores (0-100)", group = g_score,
     tooltip = "Each OB is scored by size, displacement quality, volume and overlap with FVGs.")
minScore    = input.int(0, "Hide zones below score",
     minval = 0, maxval = 100, group = g_score)
confThresh  = input.int(70, "Confluence Score Alert Threshold",
     minval = 0, maxval = 100, group = g_score)

// --- Dashboard --------------------------------------------------------------
g_dash      = "Dashboard"
showDash    = input.bool(true, "Show Confluence Heatmap", group = g_dash)
dashPos     = input.string("Top Right", "Dashboard Position",
     options = ["Top Right","Top Left","Top Center",
                "Middle Right","Middle Left","Middle Center",
                "Bottom Right","Bottom Left","Bottom Center"],
     group = g_dash)
dashSize    = input.string("Small", "Text Size",
     options = ["Tiny","Small","Normal","Large","Huge"],
     group = g_dash)
dashTrans   = input.int(15, "Background Transparency",
     minval = 0, maxval = 100, group = g_dash)

// =============================================================================
//  SECTION 2 - COLOR PALETTE  (Mystic - locked)
// =============================================================================
const color C_BULL    = #00CED1
const color C_BEAR    = #9400D3
const color C_NEUTRAL_BASE = #F0F8FF
const color C_BG      = #191970
const color C_FRAME_BASE = #241A3A

color C_BREAK  = brkColIn
color C_MB     = mbColIn
color C_FRAME  = color.new(C_FRAME_BASE, 60)
color C_HDR_BG = color.new(C_BG,  dashTrans)
color C_TXT    = color.new(#FFFFFF, 0)
color C_TXT_M  = color.new(#A8B0BD, 10)
color C_NEUTRAL = color.new(C_NEUTRAL_BASE, 30)

// =============================================================================
//  SECTION 3 - HELPER FUNCTIONS
// =============================================================================

// 3.1 RGB linear-interpolation gradient -------------------------------------
//     Interpolates between two colors by a 0..1 ratio.
f_colorGradient(float r, color a, color b) =>
    rA = color.r(a), gA = color.g(a), bA = color.b(a)
    rB = color.r(b), gB = color.g(b), bB = color.b(b)
    rr = rA + int((rB - rA) * r)
    rg = gA + int((gB - gA) * r)
    rb = bA + int((bB - bA) * r)
    color.rgb(rr, rg, rb, 0)

// 3.2 Multi-stop gradient over an array of color stops ---------------------
f_gradientMulti(float r, array<color> stops) =>
    n   = array.size(stops) - 1
    pos = r * n
    idx = math.min(n - 1, math.max(0, int(pos)))
    loc = pos - idx
    f_colorGradient(loc, array.get(stops, idx), array.get(stops, idx + 1))

// 3.3 Clamp helper ---------------------------------------------------------
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(x, hi))

// 3.4 Position string resolver ---------------------------------------------
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

// 3.5 Size string resolver -------------------------------------------------
strToSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.normal

// 3.6 Dashboard row gradient -----------------------------------------------
//     Transparency fades subtly down each row to give a premium feel.
f_grad(color base, int row, int rows, int minT, int maxT) =>
    float t = rows <= 1 ? float(minT) : float(minT) + float(maxT - minT) * (float(row) / float(rows - 1))
    color.new(base, int(t))

// 3.7 Format price for dashboard cells -------------------------------------
f_fmtPrice(float p) =>
    p > 1000 ? str.tostring(p, "#.##") : p > 1 ? str.tostring(p, "#.####") : str.tostring(p, "#.######")

// 3.8 Distance percent helper ----------------------------------------------
f_distPct(float a, float b) => b == 0 ? 0.0 : math.abs(a - b) / b * 100.0

// 3.9 Format percent --------------------------------------------------------
f_fmtPct(float v) => str.tostring(v, "#.##") + "%"

// =============================================================================
//  SECTION 4 - CORE CALCULATIONS
// =============================================================================

float atrFast = ta.atr(14)
float atrSlow = ta.atr(50)
float volAvg  = ta.sma(volume, 20)

// Price candle classification used in several places
bool  isBullCandle = close >= open
bool  isBearCandle = close <  open
float bodySize     = math.abs(close - open)
float candleRng    = high - low
float bodyRatio    = candleRng > 0 ? bodySize / candleRng : 0.0
float topWickFast  = high - math.max(open, close)
float botWickFast  = math.min(open, close) - low

// =============================================================================
//  SECTION 5 - STATE - UDTs and var arrays
// =============================================================================

// 5.1 Pivot ----------------------------------------------------------------
type Pivot
    int    bar
    float  price
    int    kind         // +1 high, -1 low

// 5.2 Zone (extended with JOAT fields: flipped, brokenAndHeld, isMb) -------
type Zone
    int    leftBar
    float  top
    float  bottom
    int    direction       // +1 bull demand, -1 bear supply
    int    createdAt
    int    touches
    float  score
    bool   mitigated
    int    mitigatedAt     // bar index of mitigation
    bool   flipped         // iFVG flip flag (NEW)
    bool   brokenAndHeld   // Breaker Block flag (NEW)
    bool   isMb            // Mitigation Block tag (NEW)
    box    bx
    label  tag
    array<box> subBoxes    // for gradient sub-band rendering

// 5.3 Bias state -----------------------------------------------------------
type Bias
    int    state           // +1 bull, -1 bear, 0 neutral
    int    anchorBar
    float  anchorVwapNum
    float  anchorVwapDen

// 5.4 Persistent arrays ----------------------------------------------------
var array<Pivot> majorPivots = array.new<Pivot>()
var array<Pivot> minorPivots = array.new<Pivot>()
var array<Zone>  bullOBs     = array.new<Zone>()
var array<Zone>  bearOBs     = array.new<Zone>()
var array<Zone>  bullFVGs    = array.new<Zone>()
var array<Zone>  bearFVGs    = array.new<Zone>()
var array<Zone>  iFVGs       = array.new<Zone>()
var array<Zone>  breakers    = array.new<Zone>()
var array<line>  strLines    = array.new<line>()
var array<label> strLabels   = array.new<label>()
var array<label> swingLabels = array.new<label>()
var array<line>  eqLines     = array.new<line>()
var array<label> eqLabels    = array.new<label>()
var array<box>   pdBoxes     = array.new<box>()

// 5.5 Bias instances -------------------------------------------------------
var Bias major = Bias.new(0, bar_index, 0.0, 0.0)
var Bias minor = Bias.new(0, bar_index, 0.0, 0.0)

// 5.6 Adaptive ZigZag running candidates -----------------------------------
var float rcHigh    = high
var int   rcHighBar = bar_index
var float rcLow     = low
var int   rcLowBar  = bar_index
var int   lastConf  = 0    // direction of last confirmed pivot

// 5.7 Sweep cooldown tracking ----------------------------------------------
var int   lastBearSweep = 0
var int   lastBullSweep = 0
var int   lastBullSweepDir = 0  // dir of most recent sweep regardless of side
var int   lastBearSweepDir = 0

// 5.8 Pending break references ---------------------------------------------
var float pendH     = na
var int   pendHBar  = na
var float pendL     = na
var int   pendLBar  = na
var float pendHm    = na
var int   pendHmBar = na
var float pendLm    = na
var int   pendLmBar = na

// 5.9 First-OB-after-BOS state for Mitigation Block tagging -----------------
var bool needMbBull = false
var bool needMbBear = false

// 5.10 Confluence score running value --------------------------------------
var float confluenceScore = 0.0
var float prevConfluence  = 0.0

// 5.11 PD line / label refs (so we can update on each render) --------------
var line   premL = na
var line   eqL   = na
var line   discL = na
var label  premB = na
var label  eqB   = na
var label  discB = na

// 5.12 HTF refs ------------------------------------------------------------
var line   pdH_L = na
var line   pdL_L = na
var line   pdM_L = na
var label  pdH_B = na
var label  pdL_B = na
var label  pdM_B = na
var line   pwH_L = na
var line   pwL_L = na
var line   pwM_L = na
var label  pwH_B = na
var label  pwL_B = na
var label  pwM_B = na
var line   pmH_L = na
var line   pmL_L = na
var line   pmM_L = na
var label  pmH_B = na
var label  pmL_B = na
var label  pmM_B = na

// =============================================================================
//  SECTION 6 - DETECTION LOGIC
// =============================================================================

// 6.1 Live trim helper -----------------------------------------------------
trimLiveArt() =>
    if displayMode == "Live"
        while array.size(strLines) > 6
            line.delete(array.shift(strLines))
        while array.size(strLabels) > 6
            label.delete(array.shift(strLabels))

// 6.2 Displacement candle classifier ----------------------------------------
isDispBar(float o, float c, float h, float l, float impulse) =>
    body = math.abs(c - o)
    rng  = h - l
    ratio = rng > 0 ? body / rng : 0.0
    ratio >= 0.55 and body >= impulse

// 6.3 Last pivot of given kind ---------------------------------------------
lastPivotKind(array<Pivot> arr, int k) =>
    Pivot found = na
    sz = array.size(arr)
    if sz > 0
        for i = sz - 1 to 0
            p = array.get(arr, i)
            if p.kind == k
                found := p
                break
    found

// 6.4 Generic structure-line drawer -----------------------------------------
//      Major = solid line + filled label tag at the break point.
//      Internal = dashed line + smaller filled tag.
//      Label is placed AT the break point (x2) with an arrow tip pointing to
//      the broken level - this matches the Premium/Discount label convention
//      and keeps tags out of the candle body.
drawStruct(int x1, float y1, int x2, string txt, int dir, bool isInternal) =>
    col    = dir == 1 ? C_BULL : C_BEAR
    styl   = isInternal ? line.style_dashed : line.style_solid
    lwidth = isInternal ? 1 : 2
    ln  = line.new(x1, y1, x2, y1, color = col, style = styl, width = lwidth)
    // Filled label - solid colored background, white text for contrast.
    // Major structure = label_left (sits to the right of break); internal = label_right
    // so iBOS/iCHoCH don't overlap with major tags fired on the same bar.
    bgAlpha   = isInternal ? 35 : 15
    lblStyle  = isInternal ? label.style_label_right : label.style_label_left
    lblSize   = isInternal ? size.tiny : size.small
    lbl = label.new(x2, y1, txt,
         color     = color.new(col, bgAlpha),
         textcolor = color.white,
         style     = lblStyle,
         size      = lblSize)
    array.push(strLines, ln)
    array.push(strLabels, lbl)
    trimLiveArt()

// 6.5 Adaptive ZigZag pivot confirmation -----------------------------------
//     Better than ta.pivothigh/low because confirmation is by ATR retracement.
Pivot newMajor = na
if pivEngine == "Adaptive ZigZag"
    threshold = atrFast * pivAtrMult
    if high >= rcHigh
        rcHigh    := high
        rcHighBar := bar_index
    if low <= rcLow
        rcLow    := low
        rcLowBar := bar_index
    if lastConf != 1 and (rcHigh - low) >= threshold
        newMajor := Pivot.new(rcHighBar, rcHigh, 1)
        array.push(majorPivots, newMajor)
        lastConf := 1
        rcLow    := low
        rcLowBar := bar_index
    else if lastConf != -1 and (high - rcLow) >= threshold
        newMajor := Pivot.new(rcLowBar, rcLow, -1)
        array.push(majorPivots, newMajor)
        lastConf  := -1
        rcHigh    := high
        rcHighBar := bar_index
else
    ph = ta.pivothigh(pivWindow, pivWindow)
    pl = ta.pivotlow(pivWindow, pivWindow)
    if not na(ph)
        newMajor := Pivot.new(bar_index - pivWindow, ph, 1)
        array.push(majorPivots, newMajor)
    if not na(pl)
        newMajor := Pivot.new(bar_index - pivWindow, pl, -1)
        array.push(majorPivots, newMajor)

// 6.6 Minor pivots ---------------------------------------------------------
Pivot newMinor = na
microPh = ta.pivothigh(microWin, microWin)
microPl = ta.pivotlow(microWin, microWin)
if not na(microPh)
    newMinor := Pivot.new(bar_index - microWin, microPh, 1)
    array.push(minorPivots, newMinor)
if not na(microPl)
    newMinor := Pivot.new(bar_index - microWin, microPl, -1)
    array.push(minorPivots, newMinor)

// 6.7 Memory caps ----------------------------------------------------------
while array.size(majorPivots) > 40
    array.shift(majorPivots)
while array.size(minorPivots) > 80
    array.shift(minorPivots)

// 6.8 Swing labels (HH / HL / LH / LL) -------------------------------------
if showSwings and not na(newMajor)
    Pivot prevP = na
    sz = array.size(majorPivots)
    if sz >= 2
        for i = sz - 2 to math.max(sz - 15, 0)
            p = array.get(majorPivots, i)
            if p.kind == newMajor.kind
                prevP := p
                break
    string tag = ""
    if newMajor.kind == 1
        tag := na(prevP) ? "H" : (newMajor.price > prevP.price ? "HH" : "LH")
    else
        tag := na(prevP) ? "L" : (newMajor.price < prevP.price ? "LL" : "HL")
    lbl = label.new(newMajor.bar, newMajor.price, tag,
         color     = color.new(color.gray, 100),
         textcolor = newMajor.kind == 1 ? C_BEAR : C_BULL,
         style     = newMajor.kind == 1 ? label.style_label_down : label.style_label_up,
         size      = size.tiny)
    array.push(swingLabels, lbl)
    if displayMode == "Live" and array.size(swingLabels) > 10
        label.delete(array.shift(swingLabels))

// 6.9 Pending-break maintenance -------------------------------------------
if not na(newMajor)
    if newMajor.kind == 1
        pendH    := newMajor.price
        pendHBar := newMajor.bar
    else
        pendL    := newMajor.price
        pendLBar := newMajor.bar

bool bullMajorBreak = showMajor and not na(pendH) and close > pendH and close[1] <= pendH
bool bearMajorBreak = showMajor and not na(pendL) and close < pendL and close[1] >= pendL

// 6.10 Major BOS / CHoCH / MSS -------------------------------------------
string lastMajorKind = ""
if bullMajorBreak
    shift  = major.state == -1
    dispOk = isDispBar(open, close, high, low, atrFast * dispMult)
    string kind = "BOS"
    if shift
        kind := requireDisp ? (dispOk ? "MSS" : "CHoCH") : "CHoCH"
    drawStruct(pendHBar, pendH, bar_index, kind, 1, false)
    major.state := 1
    if shift
        major.anchorBar     := bar_index
        major.anchorVwapNum := 0.0
        major.anchorVwapDen := 0.0
    pendH := na
    needMbBull := true   // first OB after this BOS gets the MB tag
    lastMajorKind := kind

if bearMajorBreak
    shift  = major.state == 1
    dispOk = isDispBar(open, close, high, low, atrFast * dispMult)
    string kind = "BOS"
    if shift
        kind := requireDisp ? (dispOk ? "MSS" : "CHoCH") : "CHoCH"
    drawStruct(pendLBar, pendL, bar_index, kind, -1, false)
    major.state := -1
    if shift
        major.anchorBar     := bar_index
        major.anchorVwapNum := 0.0
        major.anchorVwapDen := 0.0
    pendL := na
    needMbBear := true
    lastMajorKind := kind

// 6.11 Minor structure ----------------------------------------------------
if not na(newMinor)
    if newMinor.kind == 1
        pendHm    := newMinor.price
        pendHmBar := newMinor.bar
    else
        pendLm    := newMinor.price
        pendLmBar := newMinor.bar

bool bullMinorBreak = showMinor and not na(pendHm) and close > pendHm and close[1] <= pendHm
bool bearMinorBreak = showMinor and not na(pendLm) and close < pendLm and close[1] >= pendLm

if bullMinorBreak
    shift = minor.state == -1
    drawStruct(pendHmBar, pendHm, bar_index, shift ? "iCHoCH" : "iBOS", 1, true)
    minor.state := 1
    pendHm := na

if bearMinorBreak
    shift = minor.state == 1
    drawStruct(pendLmBar, pendLm, bar_index, shift ? "iCHoCH" : "iBOS", -1, true)
    minor.state := -1
    pendLm := na

// 6.12 Order Block walk-back search ---------------------------------------
//      Scan a configurable window backward from the break.
//      Pick the most-extreme candle that passes four quality filters:
//        (1) opposite-color candle
//        (2) not abnormally wide (range < ATR * 2.5)
//        (3) decent body-to-range ratio (>= 0.25)
//        (4) above-average volume (optional)
findOrigin(int dir) =>
    int    oBar = -1
    float  oTop = na
    float  oBtm = na
    int    scanBars = math.min(obWalkBars, 100)
    for i = 1 to scanBars
        o_  = open[i]
        c_  = close[i]
        h_  = high[i]
        l_  = low[i]
        v_  = volume[i]
        va_ = volAvg[i]
        rng = h_ - l_
        body = math.abs(c_ - o_)
        bodyR = rng > 0 ? body / rng : 0.0
        volOk       = obVolReq ? (nz(v_) >= nz(va_) * obVolMult) : true
        notVolatile = rng < atrFast * 2.5
        qualityOk   = bodyR >= 0.25
        opposite    = dir == 1 ? c_ < o_ : c_ > o_
        if opposite and notVolatile and volOk and qualityOk
            if obMethod == "Last Opposite Candle"
                if oBar < 0
                    oBar := bar_index - i
                    oTop := h_
                    oBtm := l_
            else
                if dir == 1
                    if na(oBtm) or l_ < oBtm
                        oBar := bar_index - i
                        oTop := h_
                        oBtm := l_
                else
                    if na(oTop) or h_ > oTop
                        oBar := bar_index - i
                        oTop := h_
                        oBtm := l_
    [oBar, oTop, oBtm]

// 6.13 OB scoring 0-100 ---------------------------------------------------
//      sizeScore + dispScore + volScore + confScore
computeObScore(float top, float bottom, int dir) =>
    sz       = (top - bottom) / math.max(atrFast, 0.0001)
    sizeScr  = math.min(sz / 2.0, 1.0) * 30.0
    dispBody = math.abs(close - open)
    dispScr  = math.min(dispBody / math.max(atrFast * 1.5, 0.0001), 1.0) * 30.0
    volScr   = volume > volAvg ? 20.0 : 10.0
    float confScr = 0.0
    fvgs = dir == 1 ? bullFVGs : bearFVGs
    for f in fvgs
        if f.top >= bottom and f.bottom <= top
            confScr := 20.0
            break
    sizeScr + dispScr + volScr + confScr

// 6.14 Push OB ------------------------------------------------------------
pushOB(int dir) =>
    bool _mbConsumed = false
    [oBar, oTop, oBtm] = findOrigin(dir)
    if oBar > 0 and not na(oTop) and not na(oBtm)
        score = computeObScore(oTop, oBtm, dir)
        if score >= minScore
            col   = dir == 1 ? color.new(C_BULL, 80) : color.new(C_BEAR, 80)
            isMb  = false
            if showMb and dir == 1 and needMbBull
                isMb := true
                _mbConsumed := true
            if showMb and dir == -1 and needMbBear
                isMb := true
                _mbConsumed := true
            bx = box.new(oBar, oTop, bar_index + 5, oBtm,
                 bgcolor      = col,
                 border_color = color.new(col, 40),
                 extend       = extend.right)
            label tag = na
            // Filled tag attached to the RIGHT edge of the OB. Solid colored
            // background, white text. MB tag uses palette accent color so it
            // is visually distinct from the OB body without breaking the theme.
            if showScore
                tagBg = isMb ? color.new(C_MB, 15) : color.new(col, 25)
                tag := label.new(bar_index + 5, (oTop + oBtm) / 2,
                     str.tostring(math.round(score)) + (isMb ? "  MB" : ""),
                     color     = tagBg,
                     textcolor = color.white,
                     style     = label.style_label_left,
                     size      = size.small)
            else if isMb
                tag := label.new(bar_index + 5, (oTop + oBtm) / 2, "MB",
                     color     = color.new(C_MB, 15),
                     textcolor = color.white,
                     style     = label.style_label_left,
                     size      = size.small)
            z = Zone.new(oBar, oTop, oBtm, dir, bar_index, 0, score,
                 false, na, false, false, isMb, bx, tag, array.new<box>())
            arr = dir == 1 ? bullOBs : bearOBs
            array.push(arr, z)
            while array.size(arr) > obMax
                old = array.shift(arr)
                box.delete(old.bx)
                if not na(old.tag)
                    label.delete(old.tag)
    _mbConsumed

if showOB and bullMajorBreak
    _bull_mb = pushOB(1)
    if _bull_mb
        needMbBull := false
if showOB and bearMajorBreak
    _bear_mb = pushOB(-1)
    if _bear_mb
        needMbBear := false

// 6.15 OB mitigation + breaker promotion ----------------------------------
//      When an OB is mitigated, we keep its data so we can promote it to a
//      Breaker Block if price returns and holds from the opposite side.
mitigateOBs(array<Zone> arr, int dir) =>
    sz = array.size(arr)
    if sz > 0
        for i = sz - 1 to 0
            z = array.get(arr, i)
            bool dead = false
            if dir == 1
                dead := obMitig == "Wick" ? low < z.bottom : close < z.bottom
            else
                dead := obMitig == "Wick" ? high > z.top    : close > z.top
            if dead
                // Promote to Breaker Block tracking before deletion
                if showBrk
                    brk = Zone.new(z.leftBar, z.top, z.bottom, dir == 1 ? -1 : 1,
                         bar_index, 0, z.score, true, bar_index, false, false,
                         false, na, na, array.new<box>())
                    array.push(breakers, brk)
                    while array.size(breakers) > obMax * 2
                        array.shift(breakers)
                box.delete(z.bx)
                if not na(z.tag)
                    label.delete(z.tag)
                array.remove(arr, i)
            if not dead
                box.set_right(z.bx, bar_index + 5)
                if not na(z.tag)
                    label.set_x(z.tag, bar_index + 5)
                    label.set_y(z.tag, (z.top + z.bottom) / 2)
    0

mitigateOBs(bullOBs, 1)
mitigateOBs(bearOBs, -1)

// 6.16 Breaker Block confirmation -----------------------------------------
//      A breaker = previous OB that was mitigated, then price returned and
//      held from the OPPOSITE side. We promote on first re-test.
bool brkBullConfirmed = false
bool brkBearConfirmed = false

if showBrk
    szB = array.size(breakers)
    if szB > 0
        for i = szB - 1 to 0
            b = array.get(breakers, i)
            ageMit = bar_index - b.mitigatedAt
            if ageMit > brkHoldBars * 4
                array.remove(breakers, i)
                continue
            if b.brokenAndHeld
                continue
            // dir == +1 means it has flipped to bullish role (was bear OB)
            // dir == -1 means it has flipped to bearish role (was bull OB)
            touched = false
            if b.direction == 1
                touched := low <= b.top and low >= b.bottom and close > b.bottom
            else
                touched := high >= b.bottom and high <= b.top and close < b.top
            if touched
                b.brokenAndHeld := true
                col = b.direction == 1 ? color.new(C_BREAK, 70) : color.new(C_BREAK, 70)
                bx = box.new(b.leftBar, b.top, bar_index + 10, b.bottom,
                     bgcolor      = col,
                     border_color = color.new(C_BREAK, 30),
                     extend       = extend.right)
                tag = label.new(bar_index + 10, (b.top + b.bottom) / 2, "BRK",
                     color     = color.new(C_BREAK, 15),
                     textcolor = color.white,
                     style     = label.style_label_left,
                     size      = size.small)
                b.bx  := bx
                b.tag := tag
                if b.direction == 1
                    brkBullConfirmed := true
                else
                    brkBearConfirmed := true

// 6.17 FVG detection ------------------------------------------------------
bool bullFvgFormed = false
bool bearFvgFormed = false

if showFvg
    bullFvgRaw = low > high[2] and close[1] > high[2]
    bearFvgRaw = high < low[2] and close[1] < low[2]
    bullGap    = low - high[2]
    bearGap    = low[2] - high
    bullOk     = bullFvgRaw and bullGap >= atrFast * fvgMinAtr
    bearOk     = bearFvgRaw and bearGap >= atrFast * fvgMinAtr
    if bullOk
        bullFvgCol = color.new(C_BULL, 85)
        bx = box.new(bar_index - 2, low, bar_index + fvgExtend, high[2],
             bgcolor      = bullFvgCol,
             border_color = color.new(bullFvgCol, 50))
        z = Zone.new(bar_index - 2, low, high[2], 1, bar_index, 0, 0.0,
             false, na, false, false, false, bx, na, array.new<box>())
        array.push(bullFVGs, z)
        bullFvgFormed := true
    if bearOk
        bearFvgCol = color.new(C_BEAR, 85)
        bx = box.new(bar_index - 2, low[2], bar_index + fvgExtend, high,
             bgcolor      = bearFvgCol,
             border_color = color.new(bearFvgCol, 50))
        z = Zone.new(bar_index - 2, low[2], high, -1, bar_index, 0, 0.0,
             false, na, false, false, false, bx, na, array.new<box>())
        array.push(bearFVGs, z)
        bearFvgFormed := true
    // Bull FVG mitigation
    szB = array.size(bullFVGs)
    if szB > 0
        for i = szB - 1 to 0
            z = array.get(bullFVGs, i)
            if low < z.bottom and not z.mitigated
                if fvgFade
                    box.set_bgcolor(z.bx, color.new(C_BULL, 92))
                    box.set_border_color(z.bx, color.new(C_BULL, 90))
                    z.mitigated := true
                    z.mitigatedAt := bar_index
                else
                    box.delete(z.bx)
                    array.remove(bullFVGs, i)
            else if not z.mitigated
                box.set_right(z.bx, bar_index + fvgExtend)
    // Bear FVG mitigation
    szS = array.size(bearFVGs)
    if szS > 0
        for i = szS - 1 to 0
            z = array.get(bearFVGs, i)
            if high > z.top and not z.mitigated
                if fvgFade
                    box.set_bgcolor(z.bx, color.new(C_BEAR, 92))
                    box.set_border_color(z.bx, color.new(C_BEAR, 90))
                    z.mitigated := true
                    z.mitigatedAt := bar_index
                else
                    box.delete(z.bx)
                    array.remove(bearFVGs, i)
            else if not z.mitigated
                box.set_right(z.bx, bar_index + fvgExtend)
    // Cap memory
    while array.size(bullFVGs) > fvgMax
        old = array.shift(bullFVGs)
        box.delete(old.bx)
    while array.size(bearFVGs) > fvgMax
        old = array.shift(bearFVGs)
        box.delete(old.bx)

// 6.18 iFVG (Inversion FVG) flip detection (NEW) --------------------------
//      When a previously-mitigated bull FVG is re-traversed downward
//      (close < bottom) within ifvgFlipBars, flip it and tag as bearish
//      iFVG. Symmetric for bear FVGs. Render with gradient fill.
bool ifvgBullFlip = false
bool ifvgBearFlip = false

if showIFvg
    // Bull -> Bear flip
    szB = array.size(bullFVGs)
    if szB > 0
        for i = szB - 1 to 0
            z = array.get(bullFVGs, i)
            if z.mitigated and not z.flipped
                age = bar_index - z.mitigatedAt
                if age <= ifvgFlipBars and close < z.bottom and close[1] >= z.bottom
                    z.flipped := true
                    z.direction := -1
                    // Build gradient sub-bands as a polyline-style stack
                    nStops = ifvgGradStops
                    band   = (z.top - z.bottom) / float(nStops)
                    stops  = array.from(C_BEAR, color.new(C_BEAR, 50), color.new(C_BULL, 90))
                    for k = 0 to nStops - 1
                        ratio = float(k) / float(math.max(nStops - 1, 1))
                        cellCol = f_gradientMulti(ratio, stops)
                        bandCol = color.new(cellCol, 70)
                        bk = box.new(z.leftBar, z.bottom + band * float(k + 1),
                             bar_index + fvgExtend,
                             z.bottom + band * float(k),
                             bgcolor      = bandCol,
                             border_color = color.new(bandCol, 100),
                             extend       = extend.right)
                        array.push(z.subBoxes, bk)
                    iflbl = label.new(bar_index + fvgExtend,
                         (z.top + z.bottom) / 2, "iFVG",
                         color     = color.new(C_BEAR, 15),
                         textcolor = color.white,
                         style     = label.style_label_left,
                         size      = size.small)
                    z.tag := iflbl
                    array.push(iFVGs, z)
                    ifvgBearFlip := true
    // Bear -> Bull flip
    szS = array.size(bearFVGs)
    if szS > 0
        for i = szS - 1 to 0
            z = array.get(bearFVGs, i)
            if z.mitigated and not z.flipped
                age = bar_index - z.mitigatedAt
                if age <= ifvgFlipBars and close > z.top and close[1] <= z.top
                    z.flipped := true
                    z.direction := 1
                    nStops = ifvgGradStops
                    band   = (z.top - z.bottom) / float(nStops)
                    stops  = array.from(C_BULL, color.new(C_BULL, 50), color.new(C_BEAR, 90))
                    for k = 0 to nStops - 1
                        ratio = float(k) / float(math.max(nStops - 1, 1))
                        cellCol = f_gradientMulti(ratio, stops)
                        bandCol = color.new(cellCol, 70)
                        bk = box.new(z.leftBar, z.bottom + band * float(k + 1),
                             bar_index + fvgExtend,
                             z.bottom + band * float(k),
                             bgcolor      = bandCol,
                             border_color = color.new(bandCol, 100),
                             extend       = extend.right)
                        array.push(z.subBoxes, bk)
                    iflbl = label.new(bar_index + fvgExtend,
                         (z.top + z.bottom) / 2, "iFVG",
                         color     = color.new(C_BULL, 15),
                         textcolor = color.white,
                         style     = label.style_label_left,
                         size      = size.small)
                    z.tag := iflbl
                    array.push(iFVGs, z)
                    ifvgBullFlip := true
    // Cap memory of iFVG list
    while array.size(iFVGs) > fvgMax
        old = array.shift(iFVGs)
        for bx in old.subBoxes
            box.delete(bx)
        if not na(old.tag)
            label.delete(old.tag)

// 6.19 Equal Highs / Lows -------------------------------------------------
if showEq and not na(newMajor)
    tol = atrFast * eqTol
    sz  = array.size(majorPivots)
    if sz >= 2
        if newMajor.kind == 1
            for i = sz - 2 to math.max(sz - 12, 0)
                p = array.get(majorPivots, i)
                if p.kind == 1 and bar_index - p.bar <= eqLookback and math.abs(p.price - newMajor.price) <= tol
                    ln = line.new(p.bar, p.price, newMajor.bar, newMajor.price,
                         color = C_BEAR, style = line.style_dotted, width = 1)
                    lbl = label.new(int(math.avg(p.bar, newMajor.bar)),
                         newMajor.price, "EQH",
                         color     = color.new(C_BEAR, 100),
                         textcolor = C_BEAR,
                         style     = label.style_label_down,
                         size      = size.tiny)
                    array.push(eqLines,  ln)
                    array.push(eqLabels, lbl)
                    break
        else
            for i = sz - 2 to math.max(sz - 12, 0)
                p = array.get(majorPivots, i)
                if p.kind == -1 and bar_index - p.bar <= eqLookback and math.abs(p.price - newMajor.price) <= tol
                    ln = line.new(p.bar, p.price, newMajor.bar, newMajor.price,
                         color = C_BULL, style = line.style_dotted, width = 1)
                    lbl = label.new(int(math.avg(p.bar, newMajor.bar)),
                         newMajor.price, "EQL",
                         color     = color.new(C_BULL, 100),
                         textcolor = C_BULL,
                         style     = label.style_label_up,
                         size      = size.tiny)
                    array.push(eqLines,  ln)
                    array.push(eqLabels, lbl)
                    break
    while array.size(eqLines) > 20
        line.delete(array.shift(eqLines))
        label.delete(array.shift(eqLabels))

// 6.20 Liquidity sweeps (strict 5-condition) -----------------------------
//      ALL of:
//        (1) wick pokes through a recent MINOR pivot
//        (2) close returns back inside the range
//        (3) wick length >= 0.8 * ATR
//        (4) wick >= 35% of the candle's range
//        (5) cooldown bars since same-direction sweep
bool bullSweepSig = false
bool bearSweepSig = false

if showSweep
    topWick = high - math.max(open, close)
    botWick = math.min(open, close) - low
    rng_    = high - low
    float refHi = na
    float refLo = na
    sz = array.size(minorPivots)
    if sz > 0
        maxScan = math.max(sz - 12, 0)
        for i = sz - 1 to maxScan
            p = array.get(minorPivots, i)
            if na(refHi) and p.kind == 1 and bar_index - p.bar > 2
                refHi := p.price
            if na(refLo) and p.kind == -1 and bar_index - p.bar > 2
                refLo := p.price
            if not na(refHi) and not na(refLo)
                break
    bearSweepSig := not na(refHi)
         and high > refHi
         and close < refHi
         and topWick >= atrFast * 0.8
         and topWick / math.max(rng_, 0.0001) >= 0.35
         and bar_index - lastBearSweep > sweepCool
    bullSweepSig := not na(refLo)
         and low < refLo
         and close > refLo
         and botWick >= atrFast * 0.8
         and botWick / math.max(rng_, 0.0001) >= 0.35
         and bar_index - lastBullSweep > sweepCool
    if bearSweepSig
        lastBearSweep    := bar_index
        lastBearSweepDir := bar_index
        label.new(bar_index, high + atrFast * 0.2, "X",
             color     = color.new(C_BEAR, 0),
             textcolor = color.white,
             style     = label.style_label_down,
             size      = size.small)
    if bullSweepSig
        lastBullSweep    := bar_index
        lastBullSweepDir := bar_index
        label.new(bar_index, low - atrFast * 0.2, "X",
             color     = color.new(C_BULL, 0),
             textcolor = color.white,
             style     = label.style_label_up,
             size      = size.small)

// 6.21 AVWAP equilibrium (drifts with trend) ------------------------------
if bar_index >= major.anchorBar
    safeVol = nz(volume, 1)
    hlc3v   = (high + low + close) / 3.0 * safeVol
    major.anchorVwapNum := major.anchorVwapNum + hlc3v
    major.anchorVwapDen := major.anchorVwapDen + safeVol

float avwap = major.anchorVwapDen > 0 ? major.anchorVwapNum / major.anchorVwapDen : close

// 6.22 HTF requests --------------------------------------------------------
[pdH, pdL] = request.security(syminfo.tickerid, "D", [high[1], low[1]],
     lookahead = barmerge.lookahead_on)
[pwH, pwL] = request.security(syminfo.tickerid, "W", [high[1], low[1]],
     lookahead = barmerge.lookahead_on)
[pmH, pmL] = request.security(syminfo.tickerid, "M", [high[1], low[1]],
     lookahead = barmerge.lookahead_on)

// =============================================================================
//  SECTION 7 - PLOTS
// =============================================================================

// 7.1 Bar coloring by minor bias -----------------------------------------
color barTint = na
if paintBars
    barTint := minor.state == 1 ? C_BULL : minor.state == -1 ? C_BEAR : na
plotcandle(open, high, low, close,
     color       = barTint,
     wickcolor   = barTint,
     bordercolor = barTint,
     editable    = false)

// 7.2 Optional theme bg tint ---------------------------------------------
bgcolor(useCustomBg ? color.new(C_BG, 92) : na, editable = false)

// 7.3 Hidden plots so we can reference values in dashboards if needed ---
plot(major.state, title = "Major Bias", display = display.none, editable = false)
plot(minor.state, title = "Minor Bias", display = display.none, editable = false)
plot(avwap,       title = "AVWAP EQ",   display = display.none, editable = false)
plot(atrFast,     title = "ATR(14)",    display = display.none, editable = false)
plot(volAvg,      title = "Vol SMA(20)", display = display.none, editable = false)

// =============================================================================
//  SECTION 8 - DRAWINGS
// =============================================================================
// Almost all drawings are managed inside the detection logic above for
// performance. The Premium / Discount and HTF panels are rendered ONLY on
// the last bar to limit drawing churn.
// -----------------------------------------------------------------------------

// 8.1 Premium / Discount panel with optional gradient zones ---------------
if barstate.islast and showPD
    lookBack = math.min(bar_index - major.anchorBar, 500)
    hh = high
    ll = low
    if lookBack > 0
        for i = 0 to lookBack
            hh := math.max(hh, high[i])
            ll := math.min(ll, low[i])
    equilibrium = pdMethod == "AVWAP Equilibrium" ? avwap : math.avg(hh, ll)

    // delete previous
    line.delete(premL)
    line.delete(eqL)
    line.delete(discL)
    label.delete(premB)
    label.delete(eqB)
    label.delete(discB)
    while array.size(pdBoxes) > 0
        box.delete(array.shift(pdBoxes))

    // gradient sub-bands for premium and discount regions
    if showPDgrad
        nStops = pdGradStops
        // Premium: equilibrium -> hh, fade from neutral to bear
        bandUp = (hh - equilibrium) / float(nStops)
        for k = 0 to nStops - 1
            ratio = float(k) / float(math.max(nStops - 1, 1))
            // top of band has stronger bear tint
            cellCol = color.new(C_BEAR, int(85 - 30 * ratio))
            bx = box.new(major.anchorBar,
                 equilibrium + bandUp * float(k + 1),
                 bar_index + 20,
                 equilibrium + bandUp * float(k),
                 bgcolor      = cellCol,
                 border_color = color.new(cellCol, 100))
            array.push(pdBoxes, bx)
        // Discount: ll -> equilibrium, fade from neutral to bull
        bandDn = (equilibrium - ll) / float(nStops)
        for k = 0 to nStops - 1
            ratio = float(k) / float(math.max(nStops - 1, 1))
            cellCol = color.new(C_BULL, int(85 - 30 * ratio))
            bx = box.new(major.anchorBar,
                 equilibrium - bandDn * float(k),
                 bar_index + 20,
                 equilibrium - bandDn * float(k + 1),
                 bgcolor      = cellCol,
                 border_color = color.new(cellCol, 100))
            array.push(pdBoxes, bx)

    // structure lines
    premL := line.new(major.anchorBar, hh, bar_index + 20, hh,
         color = C_BEAR, width = 1)
    eqL   := line.new(major.anchorBar, equilibrium, bar_index + 20, equilibrium,
         color = color.new(color.gray, 30), style = line.style_dashed)
    discL := line.new(major.anchorBar, ll, bar_index + 20, ll,
         color = C_BULL, width = 1)
    premB := label.new(bar_index + 20, hh, "Premium",
         color     = color.new(C_BEAR, 100),
         textcolor = C_BEAR,
         style     = label.style_label_left,
         size      = size.small)
    eqB := label.new(bar_index + 20, equilibrium,
         pdMethod == "AVWAP Equilibrium" ? "AVWAP EQ" : "EQ 50%",
         color     = color.new(color.gray, 100),
         textcolor = color.gray,
         style     = label.style_label_left,
         size      = size.tiny)
    discB := label.new(bar_index + 20, ll, "Discount",
         color     = color.new(C_BULL, 100),
         textcolor = C_BULL,
         style     = label.style_label_left,
         size      = size.small)

// 8.2 HTF level rendering -------------------------------------------------
if showPDH and barstate.islast
    line.delete(pdH_L)
    line.delete(pdL_L)
    line.delete(pdM_L)
    label.delete(pdH_B)
    label.delete(pdL_B)
    label.delete(pdM_B)
    pdH_L := line.new(bar_index - 30, pdH, bar_index + 10, pdH,
         color = pdCol, style = line.style_dotted)
    pdL_L := line.new(bar_index - 30, pdL, bar_index + 10, pdL,
         color = pdCol, style = line.style_dotted)
    pdH_B := label.new(bar_index + 10, pdH, "PDH",
         color = color.new(pdCol, 100), textcolor = pdCol,
         style = label.style_label_left, size = size.tiny)
    pdL_B := label.new(bar_index + 10, pdL, "PDL",
         color = color.new(pdCol, 100), textcolor = pdCol,
         style = label.style_label_left, size = size.tiny)
    if showMid
        pdM = math.avg(pdH, pdL)
        pdM_L := line.new(bar_index - 30, pdM, bar_index + 10, pdM,
             color = color.new(pdCol, 40), style = line.style_dashed)
        pdM_B := label.new(bar_index + 10, pdM, "PD 50%",
             color = color.new(pdCol, 100),
             textcolor = color.new(pdCol, 40),
             style = label.style_label_left, size = size.tiny)

if showPWH and barstate.islast
    line.delete(pwH_L)
    line.delete(pwL_L)
    line.delete(pwM_L)
    label.delete(pwH_B)
    label.delete(pwL_B)
    label.delete(pwM_B)
    pwH_L := line.new(bar_index - 30, pwH, bar_index + 10, pwH,
         color = pwCol, style = line.style_dotted)
    pwL_L := line.new(bar_index - 30, pwL, bar_index + 10, pwL,
         color = pwCol, style = line.style_dotted)
    pwH_B := label.new(bar_index + 10, pwH, "PWH",
         color = color.new(pwCol, 100), textcolor = pwCol,
         style = label.style_label_left, size = size.tiny)
    pwL_B := label.new(bar_index + 10, pwL, "PWL",
         color = color.new(pwCol, 100), textcolor = pwCol,
         style = label.style_label_left, size = size.tiny)
    if showMid
        pwM = math.avg(pwH, pwL)
        pwM_L := line.new(bar_index - 30, pwM, bar_index + 10, pwM,
             color = color.new(pwCol, 40), style = line.style_dashed)
        pwM_B := label.new(bar_index + 10, pwM, "PW 50%",
             color = color.new(pwCol, 100),
             textcolor = color.new(pwCol, 40),
             style = label.style_label_left, size = size.tiny)

if showPMH and barstate.islast
    line.delete(pmH_L)
    line.delete(pmL_L)
    line.delete(pmM_L)
    label.delete(pmH_B)
    label.delete(pmL_B)
    label.delete(pmM_B)
    pmH_L := line.new(bar_index - 30, pmH, bar_index + 10, pmH,
         color = pmCol, style = line.style_dotted)
    pmL_L := line.new(bar_index - 30, pmL, bar_index + 10, pmL,
         color = pmCol, style = line.style_dotted)
    pmH_B := label.new(bar_index + 10, pmH, "PMH",
         color = color.new(pmCol, 100), textcolor = pmCol,
         style = label.style_label_left, size = size.tiny)
    pmL_B := label.new(bar_index + 10, pmL, "PML",
         color = color.new(pmCol, 100), textcolor = pmCol,
         style = label.style_label_left, size = size.tiny)
    if showMid
        pmM = math.avg(pmH, pmL)
        pmM_L := line.new(bar_index - 30, pmM, bar_index + 10, pmM,
             color = color.new(pmCol, 40), style = line.style_dashed)
        pmM_B := label.new(bar_index + 10, pmM, "PM 50%",
             color = color.new(pmCol, 100),
             textcolor = color.new(pmCol, 40),
             style = label.style_label_left, size = size.tiny)

// =============================================================================
//  SECTION 9 - CONFLUENCE HEATMAP DASHBOARD (NEW)
// =============================================================================
//  9-row positionable table that summarises every SMC factor right now.
// -----------------------------------------------------------------------------

// 9.1 Helpers used by the dashboard --------------------------------------

// Resolve the equilibrium consistently with what the PD panel renders
calcEquilibrium() =>
    lookBack = math.min(bar_index - major.anchorBar, 500)
    hh = high
    ll = low
    if lookBack > 0
        for i = 0 to lookBack
            hh := math.max(hh, high[i])
            ll := math.min(ll, low[i])
    eq = pdMethod == "AVWAP Equilibrium" ? avwap : math.avg(hh, ll)
    [hh, ll, eq]

// Determine which price zone we are in
priceZoneText(float eq, float hh, float ll) =>
    span = math.max(hh - ll, 1e-10)
    pos  = (close - ll) / span
    pos > 0.65 ? "Premium" : pos < 0.35 ? "Discount" : "Equilibrium"

// Find the nearest OB and report distance%
nearestOB() =>
    string name = "None"
    float  bestDist = 1e10
    for z in bullOBs
        d = f_distPct(close, math.avg(z.top, z.bottom))
        if d < bestDist
            bestDist := d
            name := "Bull OB " + f_fmtPct(d)
    for z in bearOBs
        d = f_distPct(close, math.avg(z.top, z.bottom))
        if d < bestDist
            bestDist := d
            name := "Bear OB " + f_fmtPct(d)
    [name, bestDist]

// Are we currently inside an FVG?
inFvgState() =>
    string s = "None"
    for z in bullFVGs
        if not z.mitigated and close <= z.top and close >= z.bottom
            s := "Bull FVG"
            break
    if s == "None"
        for z in bearFVGs
            if not z.mitigated and close <= z.top and close >= z.bottom
                s := "Bear FVG"
                break
    if s == "None"
        for z in iFVGs
            if close <= z.top and close >= z.bottom
                s := z.direction == 1 ? "iFVG Bull" : "iFVG Bear"
                break
    s

// Recent sweep status
sweepRecentText() =>
    bullAge = bar_index - lastBullSweep
    bearAge = bar_index - lastBearSweep
    if lastBullSweep == 0 and lastBearSweep == 0
        "None"
    else if bullAge < bearAge and bullAge < 30
        "Bull Sweep " + str.tostring(bullAge) + "b ago"
    else if bearAge < 30
        "Bear Sweep " + str.tostring(bearAge) + "b ago"
    else
        "None"

// HTF alignment
htfAlignText() =>
    string parts = ""
    if showPDH and not na(pdH) and not na(pdL)
        mid = math.avg(pdH, pdL)
        parts := close > mid ? parts + "D+ " : parts + "D- "
    if showPWH and not na(pwH) and not na(pwL)
        mid = math.avg(pwH, pwL)
        parts := close > mid ? parts + "W+ " : parts + "W- "
    if showPMH and not na(pmH) and not na(pmL)
        mid = math.avg(pmH, pmL)
        parts := close > mid ? parts + "M+ " : parts + "M- "
    parts == "" ? "off" : parts

biasText(int s) =>
    s == 1 ? "Bull A" : s == -1 ? "Bear V" : "Flat ="

biasColor(int s) =>
    s == 1 ? color.new(C_BULL, 50) : s == -1 ? color.new(C_BEAR, 50) : color.new(color.gray, 70)

// 9.2 Confluence score calculation ---------------------------------------
//     Composite of all aligned factors. 100 = perfect alignment.
calcConfluence() =>
    [hh, ll, eqv] = calcEquilibrium()
    zoneTxt = priceZoneText(eqv, hh, ll)
    [obName, obDist] = nearestOB()
    fvgState = inFvgState()
    score = 0.0
    // Major bias presence: 20 pts when defined
    if major.state != 0
        score += 20.0
    // Major bias same as minor bias: another 15 pts
    if major.state != 0 and major.state == minor.state
        score += 15.0
    // Inside an FVG aligned with bias: 15 pts
    if (fvgState == "Bull FVG" and major.state == 1) or (fvgState == "Bear FVG" and major.state == -1)
        score += 15.0
    // Inside an iFVG aligned with bias: 10 pts (treat as confluence too)
    if (fvgState == "iFVG Bull" and major.state == 1) or (fvgState == "iFVG Bear" and major.state == -1)
        score += 10.0
    // Premium when bear bias / Discount when bull bias: 15 pts
    if (zoneTxt == "Premium" and major.state == -1) or (zoneTxt == "Discount" and major.state == 1)
        score += 15.0
    // Near an OB (<0.5% away): 10 pts
    if obDist < 0.5
        score += 10.0
    // Recent sweep aligned with bias: 10 pts
    bullAge = bar_index - lastBullSweep
    bearAge = bar_index - lastBearSweep
    if (bullAge < 5 and major.state == 1) or (bearAge < 5 and major.state == -1)
        score += 10.0
    // HTF alignment: each TF in line gives 5 pts
    if htfBiasCalc
        if showPDH and not na(pdH) and not na(pdL)
            mid = math.avg(pdH, pdL)
            if (close > mid and major.state == 1) or (close < mid and major.state == -1)
                score += 5.0
        if showPWH and not na(pwH) and not na(pwL)
            mid = math.avg(pwH, pwL)
            if (close > mid and major.state == 1) or (close < mid and major.state == -1)
                score += 5.0
        if showPMH and not na(pmH) and not na(pmL)
            mid = math.avg(pmH, pmL)
            if (close > mid and major.state == 1) or (close < mid and major.state == -1)
                score += 5.0
    f_clamp(score, 0.0, 100.0)

prevConfluence    := confluenceScore
confluenceScore   := calcConfluence()

// 9.3 Confluence heatmap colour gradient ---------------------------------
// Color discipline: ramp uses ONLY the active theme's bear -> neutral -> bull palette
// so the dashboard stays on-brand regardless of theme.
confluenceColor(float s) =>
    color base = color.new(C_BEAR, 0)
    if s < 50.0
        base := f_colorGradient(s / 50.0, color.new(C_BEAR, 0), color.new(C_NEUTRAL, 0))
    else
        base := f_colorGradient((s - 50.0) / 50.0, color.new(C_NEUTRAL, 0), color.new(C_BULL, 0))
    base

// 9.4 Build the dashboard table ------------------------------------------
var table dash = na
if showDash
    if na(dash)
        dash := table.new(strToPos(dashPos), 2, 9,
             bgcolor      = color.new(C_BG, 100),
             frame_color  = C_FRAME,
             frame_width  = 1,
             border_color = color.new(C_FRAME, 65),
             border_width = 1)

if showDash and barstate.islast
    [hh, ll, eqv] = calcEquilibrium()
    zoneTxt        = priceZoneText(eqv, hh, ll)
    [obName, obDist] = nearestOB()
    fvgState       = inFvgState()
    sweepTxt       = sweepRecentText()
    htfTxt         = htfAlignText()
    rows = 9
    sz   = strToSize(dashSize)
    // Header
    table.cell(dash, 0, 0, "SMC CONFLUENCE",
         text_color = C_TXT, bgcolor = f_grad(C_BG, 0, rows, dashTrans, dashTrans + 5),
         text_font_family = font.family_monospace, text_size = sz)
    table.cell(dash, 1, 0, "STATE",
         text_color = C_TXT, bgcolor = f_grad(C_BG, 0, rows, dashTrans, dashTrans + 5),
         text_halign = text.align_right,
         text_font_family = font.family_monospace, text_size = sz)
    // Major bias
    table.cell(dash, 0, 1, "Major Bias",
         text_color = C_TXT_M, bgcolor = f_grad(C_BG, 1, rows, dashTrans, dashTrans + 25),
         text_size = sz)
    table.cell(dash, 1, 1, biasText(major.state),
         text_color = biasColor(major.state),
         bgcolor    = f_grad(C_BG, 1, rows, dashTrans, dashTrans + 25),
         text_halign = text.align_right, text_size = sz)
    // Minor bias
    table.cell(dash, 0, 2, "Minor Bias",
         text_color = C_TXT_M, bgcolor = f_grad(C_BG, 2, rows, dashTrans, dashTrans + 25),
         text_size = sz)
    table.cell(dash, 1, 2, biasText(minor.state),
         text_color = biasColor(minor.state),
         bgcolor    = f_grad(C_BG, 2, rows, dashTrans, dashTrans + 25),
         text_halign = text.align_right, text_size = sz)
    // Price zone
    zoneCol = zoneTxt == "Premium" ? C_BEAR : zoneTxt == "Discount" ? C_BULL : C_NEUTRAL
    table.cell(dash, 0, 3, "Price Zone",
         text_color = C_TXT_M, bgcolor = f_grad(C_BG, 3, rows, dashTrans, dashTrans + 25),
         text_size = sz)
    table.cell(dash, 1, 3, zoneTxt,
         text_color = color.new(zoneCol, 0),
         bgcolor    = f_grad(C_BG, 3, rows, dashTrans, dashTrans + 25),
         text_halign = text.align_right, text_size = sz)
    // Near OB
    table.cell(dash, 0, 4, "Near OB",
         text_color = C_TXT_M, bgcolor = f_grad(C_BG, 4, rows, dashTrans, dashTrans + 25),
         text_size = sz)
    table.cell(dash, 1, 4, obName,
         text_color = obDist < 0.5 ? C_TXT : C_TXT_M,
         bgcolor    = f_grad(C_BG, 4, rows, dashTrans, dashTrans + 25),
         text_halign = text.align_right, text_size = sz)
    // In FVG
    fvgCol = str.contains(fvgState, "Bull") ? C_BULL : str.contains(fvgState, "Bear") ? C_BEAR : C_NEUTRAL
    table.cell(dash, 0, 5, "In FVG",
         text_color = C_TXT_M, bgcolor = f_grad(C_BG, 5, rows, dashTrans, dashTrans + 25),
         text_size = sz)
    table.cell(dash, 1, 5, fvgState,
         text_color = fvgCol,
         bgcolor    = f_grad(C_BG, 5, rows, dashTrans, dashTrans + 25),
         text_halign = text.align_right, text_size = sz)
    // Sweep recent
    sweepCol = str.contains(sweepTxt, "Bull") ? C_BULL : str.contains(sweepTxt, "Bear") ? C_BEAR : C_NEUTRAL
    table.cell(dash, 0, 6, "Sweep Recent",
         text_color = C_TXT_M, bgcolor = f_grad(C_BG, 6, rows, dashTrans, dashTrans + 25),
         text_size = sz)
    table.cell(dash, 1, 6, sweepTxt,
         text_color = sweepCol,
         bgcolor    = f_grad(C_BG, 6, rows, dashTrans, dashTrans + 25),
         text_halign = text.align_right, text_size = sz)
    // HTF aligned
    table.cell(dash, 0, 7, "HTF Aligned",
         text_color = C_TXT_M, bgcolor = f_grad(C_BG, 7, rows, dashTrans, dashTrans + 25),
         text_size = sz)
    table.cell(dash, 1, 7, htfTxt,
         text_color = C_TXT,
         bgcolor    = f_grad(C_BG, 7, rows, dashTrans, dashTrans + 25),
         text_halign = text.align_right, text_size = sz)
    // Confluence score (gradient bg)
    confCol = confluenceColor(confluenceScore)
    table.cell(dash, 0, 8, "Confluence",
         text_color = C_TXT, bgcolor = color.new(confCol, 60), text_size = sz,
         text_font_family = font.family_monospace)
    table.cell(dash, 1, 8, str.tostring(math.round(confluenceScore)) + " / 100",
         text_color = C_TXT, bgcolor = color.new(confCol, 30),
         text_halign = text.align_right, text_size = sz,
         text_font_family = font.family_monospace)

// =============================================================================
//  SECTION 10 - ALERTS
// =============================================================================
//  All alerts use alertcondition() so the user can wire each one into the
//  TradingView alert dialog independently.
// -----------------------------------------------------------------------------

bool bullFvgAlert = showFvg and bullFvgFormed
bool bearFvgAlert = showFvg and bearFvgFormed
bool ifvgBullAlert = showIFvg and ifvgBullFlip
bool ifvgBearAlert = showIFvg and ifvgBearFlip
bool brkBullAlert  = showBrk and brkBullConfirmed
bool brkBearAlert  = showBrk and brkBearConfirmed
bool confCrossUp   = confluenceScore >= confThresh and prevConfluence < confThresh
bool confCrossDn   = confluenceScore < confThresh and prevConfluence >= confThresh

alertcondition(bullMajorBreak,
     "Bullish Major Break",
     "Major bullish structure break - BOS / CHoCH / MSS")
alertcondition(bearMajorBreak,
     "Bearish Major Break",
     "Major bearish structure break - BOS / CHoCH / MSS")
alertcondition(bullMinorBreak,
     "Bullish Minor Break",
     "Minor bullish structure break - iBOS / iCHoCH")
alertcondition(bearMinorBreak,
     "Bearish Minor Break",
     "Minor bearish structure break - iBOS / iCHoCH")
alertcondition(bullSweepSig,
     "Bull Liquidity Sweep",
     "Wick rejection below recent minor pivot low")
alertcondition(bearSweepSig,
     "Bear Liquidity Sweep",
     "Wick rejection above recent minor pivot high")
alertcondition(bullFvgAlert,
     "Bullish FVG",
     "Bullish fair value gap formed")
alertcondition(bearFvgAlert,
     "Bearish FVG",
     "Bearish fair value gap formed")
alertcondition(ifvgBullAlert,
     "Bullish iFVG Flip",
     "Bearish FVG was inverted into a bullish iFVG")
alertcondition(ifvgBearAlert,
     "Bearish iFVG Flip",
     "Bullish FVG was inverted into a bearish iFVG")
alertcondition(brkBullAlert,
     "Bullish Breaker Confirmed",
     "Mitigated bear OB now holding as bullish breaker")
alertcondition(brkBearAlert,
     "Bearish Breaker Confirmed",
     "Mitigated bull OB now holding as bearish breaker")
alertcondition(confCrossUp,
     "Confluence Score Crossed Up Threshold",
     "Composite SMC confluence score crossed above threshold")
alertcondition(confCrossDn,
     "Confluence Score Crossed Down Threshold",
     "Composite SMC confluence score crossed below threshold")

// =============================================================================
//  END OF FILE
// =============================================================================
````

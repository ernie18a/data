<!-- tradingview-pine-id: PUB;8c03c06e84a74869ab18d9d5a6bf6c35 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Breaker Block Identifier [algotim]

Source: https://www.tradingview.com/script/w7X1InRe-Breaker-Block-Identifier-algotim/

## Description

Breaker Block Identifier is a market structure indicator that converts failed order block retests into scored, non-repainting breaker zones. Rather than flagging every order block that gets invalidated, the script requires a complete sequence of confirmed price events — order block formation, an opposing structure break, a retracement into the invalidated zone, and a failed retest of that zone — before a breaker is created, and then ranks the result with a transparent quality score.

Problem Statement
Order blocks are frequently invalidated by a structure break and later retested, but a retest failing to continue in the original direction is not automatically a tradable breaker block. Many public scripts draw a zone as soon as an order block is broken, without verifying that the subsequent retest actually failed, how deep that retest penetrated, or how convincingly price rejected the zone. This produces a high volume of low-quality zones that require manual filtering by the trader.

This indicator addresses that gap by treating breaker formation as a multi-stage state machine rather than a single condition, and by scoring every candidate that completes the sequence so weak retests can be filtered out programmatically instead of visually.

Methodology
Swing highs and lows are identified with ta.pivothigh/ta.pivotlow using a user-defined bar count on each side, so every structural level referenced by the script is a confirmed pivot, never a forming one.

An order block source candle is located as the last opposite-colored candle at or immediately before each confirmed swing pivot, within a fixed lookback. The candle must exceed a minimum size expressed as a multiple of ATR, and can optionally be required to close on above-average volume. Zone boundaries can be set to the candle body (open/close) or the full wick range (high/low).

Every order block candidate then moves through three internal states. In the Pending state the script waits for an opposing structure break (a close beyond the relevant swing high or low, optionally required to clear the level by a minimum ATR multiple). Once that break occurs the candidate becomes Flipped, and the script waits for price to retrace back into the now-invalidated zone. On entry into the zone the candidate becomes Retesting, and the script tracks the deepest penetration price reaches inside the zone on a bar-by-bar basis.

A Retesting candidate resolves in one of two ways. If price closes back through the zone in its original direction by the confirmation displacement threshold, the retest is judged to have held and the candidate is discarded with no breaker created. If price instead closes through the opposite edge of the zone by the same displacement threshold, and the tracked penetration depth met a minimum percentage of the zone's height (the Retest Qualification Filter), the retest is judged to have failed and the order block is converted into a breaker in the opposite direction of its original bias.

Each confirmed breaker is then scored from 0 to 100 using six independent, user-weighted factors: the displacement strength of the invalidating structure break, the ATR-relative size of the original order block candle, how closely the retest penetration matched a user-defined ideal depth (scored on a curve, so both shallow touches and near-total breaches score lower than a clean mid-zone tag), the wick-rejection ratio of the confirming candle, how quickly the retest resolved relative to the retest window, and the ATR-normalized distance price traveled before returning to retest. The six sub-scores are combined using auto-normalized weights, so a breaker only appears on the chart, gets drawn, and triggers alerts if it clears the configured minimum quality threshold.

Confirmed breakers remain in an Active/Touched state until price closes through the far edge of the zone by the invalidation displacement threshold, at which point the zone is marked invalidated, visually dimmed, and removed after a configurable linger period. A hard maximum-age limit and a per-direction cap on active zone count prevent unbounded object growth.

Signal Workflow
Step 1 — a confirmed swing pivot forms and an order block candidate is registered from the qualifying source candle behind it.
Step 2 — the candidate waits in a Pending state until an opposing structure break (BOS/CHoCH) closes beyond the originating swing level.
Step 3 — once flipped, the candidate waits for price to re-enter the invalidated zone, entering the Retesting state and tracking maximum penetration depth.
Step 4 — the retest resolves: a displacement close back through the zone in the original direction discards the candidate, while a displacement close through the opposite edge with sufficient penetration confirms a breaker.
Step 5 — the confirmed breaker is scored across six weighted factors and only drawn, labeled, and alerted on if it meets the minimum quality threshold.
Step 6 — the active breaker zone extends forward until price closes through its far edge by the invalidation displacement threshold, at which point it dims and is scheduled for removal.

Why This Indicator Is Different
Most public order block or breaker scripts draw a zone the moment an order block is invalidated by a structure break, without separately validating whether the ensuing retest actually failed.
This script models breaker formation as an explicit four-state pipeline (source candle, pending, flipped, retesting) and only creates a zone after the retest resolves against its original direction with a minimum measured penetration depth.
The Breaker Quality Score converts six independently disclosed factors, including retest penetration depth scored on a curve around a configurable ideal value rather than a simple threshold, into a single adjustable ranking rather than a cosmetic label.
Quality-score weighting is fully exposed, allowing the ranking to be tuned toward structure strength, retest precision, wick rejection, confirmation speed, or impulse distance depending on the trader's approach.
Zone fill transparency scales with the quality score, so higher-ranked breakers render more opaque and lower-ranked ones fade into the background without adding separate visual elements.
An optional formation preview renders the retest phase of a candidate before it resolves, giving visibility into why a breaker did or did not form without permanently cluttering the chart.

Inputs
Structure Settings
Swing Pivot Length
Displacement Filter on Structure Break
Structure Break Displacement (x ATR)
ATR Length

Order Block Detection
Use Candle Body for Zone Boundaries
Min Order Block Size (x ATR)
Candidate Expiry (bars)
Volume Confirmation Filter
Volume MA Length
Volume Multiplier Threshold

Breaker Conversion Rules
Retest Window (bars)
Confirmation Displacement (x ATR)
Min Retest Penetration (%)

Quality Score
Filter Breakers by Quality Score
Minimum Quality Score
Ideal Retest Penetration Ratio
Advanced weight sliders for structure break strength, impulse size, retest precision, wick rejection, confirmation speed, and distance traveled

Visual Settings
Bullish/Bearish Breaker Colors
Min/Max Fill Transparency
Show Zone Midline
Show Quality Label
Label Size
Formation Preview toggle and color

Lifecycle & Cleanup
Max Active Breakers (per side)
Invalidation Displacement (x ATR)
Invalidated Linger (bars)
Max Breaker Age (bars)

Info Panel
Show Info Panel
Panel Position

Alerts
Alerts are available for:
Bullish Breaker Block formed
Bearish Breaker Block formed
Structure confirmation on breaker conversion
Price entering an active breaker zone
Breaker invalidated

Practical Usage
Use the info panel's structure bias reading as directional context before evaluating individual breaker zones.
Treat a fresh, high-quality breaker aligned with the prevailing structure bias as a potential continuation zone rather than a standalone entry signal.
Raise the minimum quality threshold on lower timeframes or noisy instruments to reduce the number of marginal zones drawn.
Use the retest penetration and displacement settings together to control how strict the failed-retest qualification is for your instrument and timeframe.
Combine the alert feed with a broader trade plan, since each alert marks a structural event, not an execution signal.

Limitations
Swing pivots require bars to form on both sides before they confirm, so structure breaks and order block placement are inherently delayed by the swing pivot length.
The order block source candle is located within a fixed lookback behind each pivot; if no qualifying candle exists in that window, no candidate is created for that pivot.
Quality scoring is a relative ranking based on disclosed, adjustable factors and does not predict the outcome of any individual breaker zone.
Volume-based filtering depends on the data provider's reported volume and may behave inconsistently on instruments with limited or unreliable volume data.
As with any structure-based tool, results will vary across instruments, timeframes, and market regimes.

Notes
This indicator is a market structure analysis tool intended to organize and rank breaker block formation through a disclosed, multi-stage validation process.
All structure breaks, state transitions, breaker confirmations, and invalidations are evaluated on confirmed bar closes only, so no element of the script repaints once drawn.
The output is intended to support structural analysis and is not a standalone buy or sell recommendation.

---

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════
// Breaker Block Identifier [algotim]
// Author : algotim
// Version: 1.0.0
//
// ── WHAT THIS SCRIPT DOES ─────────────────────────────────────────
// Detects true institutional Breaker Blocks: an order block that is
// invalidated by an opposing structure break, retested, and FAILS
// that retest — converting the original order block into a breaker
// zone in the opposite direction. This is not a simple "failed order
// block" tool. A breaker is only ever drawn after the full sequence
// below has occurred, bar-by-bar, on confirmed data:
//
//   Bullish Breaker
//     1. Bearish order block forms at a confirmed swing high.
//     2. Price breaks market structure UP (BOS/CHoCH).
//     3. Price retraces back into the bearish order block.
//     4. The retest FAILS to push price lower — the zone holds as
//        support instead of behaving as resistance.
//     5. A displacement close back above the zone confirms the failure.
//     6. The bearish order block converts into a Bullish Breaker.
//
//   Bearish Breaker mirrors this sequence from a bullish order block
//   after a downside structure break and a failed upside retest.
//
// ── CORE INNOVATION: BREAKER QUALITY SCORE ────────────────────────
// Every confirmed breaker receives a transparent 0-100 quality score
// built from six disclosed, independently-weighted factors:
//   • Structure break strength — displacement of the invalidating
//     BOS/CHoCH beyond the broken swing level.
//   • Original impulse size — displacement of the source order
//     block's candle relative to ATR.
//   • Retest precision — how cleanly price penetrated the zone,
//     scored on a curve around an ideal depth (a shallow touch and a
//     near full breach both score lower than a clean mid-zone tag).
//   • Wick rejection strength — how decisively the confirmation
//     candle rejected the zone on a closing basis.
//   • Confirmation speed — fewer bars from retest entry to
//     confirmation score higher, a proxy for reversal aggression.
//   • Distance traveled — size of the impulse leg before price
//     returned to retest the zone.
// Weights are user-adjustable and auto-normalized, so traders can tune
// the score toward the factors that matter most to their approach.
// Only breakers scoring at or above a configurable threshold are ever
// created and drawn — this is a real filtering mechanism, not a
// cosmetic label, and is what separates this script from public
// "failed order block" scripts that draw every failed retest.
//
// ── NON-REPAINTING DESIGN ──────────────────────────────────────────
// All structure breaks, candidate-state transitions, breaker
// confirmations and invalidations are evaluated strictly on confirmed
// bar closes (barstate.isconfirmed). Swing pivots use ta.pivothigh /
// ta.pivotlow, which by definition only confirm once enough bars exist
// on both sides. No stage of this script looks ahead of the current
// confirmed bar.
// ══════════════════════════════════════════════════════════════════

indicator(
     title            = "Breaker Block Identifier [algotim]",
     shorttitle       = "Breaker Blocks [algotim]",
     overlay          = true,
     max_bars_back    = 500,
     max_boxes_count  = 300,
     max_labels_count = 300,
     max_lines_count  = 300)

// ──────────────────────────────────────────────────────────────────
// SECTION 1 — INPUTS
// ──────────────────────────────────────────────────────────────────
GRP_STRUCT = "Structure Settings"
GRP_OB     = "Order Block Detection"
GRP_BRK    = "Breaker Conversion Rules"
GRP_QS     = "Quality Score"
GRP_QSW    = "Advanced: Quality Score Weights"
GRP_VIS    = "Visual Settings"
GRP_LIFE   = "Lifecycle & Cleanup"

GRP_PANEL  = "Info Panel"
GRP_ALRT   = "Alerts"

// ── Structure Settings ──────────────────────────────────────────────
i_swingLen = input.int(8, "Swing Pivot Length", minval = 3, maxval = 50,
     group   = GRP_STRUCT,
     tooltip = "Bars required on each side to confirm a swing high/low. Drives both order block placement and BOS/CHoCH structure breaks.")

i_structDispFilter = input.bool(true, "Displacement Filter on Structure Break",
     group   = GRP_STRUCT,
     tooltip = "Requires the breaking candle to close beyond the swing level by a minimum ATR multiple before a BOS/CHoCH is confirmed. Reduces marginal, low-conviction breaks.")

i_structDispMult = input.float(0.1, "Structure Break Displacement (× ATR)", minval = 0.0, maxval = 2.0, step = 0.05,
     group   = GRP_STRUCT,
     tooltip = "ATR multiple the close must exceed the swing level by when the displacement filter is enabled.")

i_atrLen = input.int(14, "ATR Length", minval = 5, maxval = 50,
     group   = GRP_STRUCT,
     tooltip = "ATR period used throughout the script for all displacement-based filters and the quality score.")

// ── Order Block Detection ───────────────────────────────────────────
i_useBody = input.bool(true, "Use Candle Body for Zone Boundaries",
     group   = GRP_OB,
     tooltip = "ON: zone boundaries are open/close (body). OFF: zone boundaries are high/low (full wick range).")

i_obMinSizeAtr = input.float(0.25, "Min Order Block Size (× ATR)", minval = 0.0, step = 0.05,
     group   = GRP_OB,
     tooltip = "The source candle's range must exceed this ATR multiple to be registered as an order block candidate. Filters thin, insignificant candles.")

i_pendingTimeout = input.int(200, "Candidate Expiry (bars)", minval = 20, maxval = 1000,
     group   = GRP_OB,
     tooltip = "An order block candidate that never sees an opposing structure break within this many bars is discarded — it never had a chance to become a breaker.")

i_useVolFilter = input.bool(false, "Volume Confirmation Filter",
     group   = GRP_OB,
     tooltip = "When enabled, only accepts order block candidates whose source candle volume exceeded the rolling average by the multiplier below.")

i_volMaLen = input.int(20, "Volume MA Length", minval = 5, maxval = 100,
     group   = GRP_OB,
     tooltip = "Lookback for the volume moving average used by the volume confirmation filter.")

i_volMult = input.float(1.0, "Volume Multiplier Threshold", minval = 0.5, maxval = 5.0, step = 0.1,
     group   = GRP_OB,
     tooltip = "Source candle volume must be at least this multiple of the volume MA to pass the filter.")

// ── Breaker Conversion Rules ────────────────────────────────────────
i_retestTimeout = input.int(60, "Retest Window (bars)", minval = 5, maxval = 300,
     group   = GRP_BRK,
     tooltip = "Maximum bars allowed between price entering the zone and either a confirmation or a failed-retest discard. Prevents stale, drawn-out setups from lingering.")

i_confirmDispMult = input.float(0.15, "Confirmation Displacement (× ATR)", minval = 0.0, maxval = 2.0, step = 0.05,
     group   = GRP_BRK,
     tooltip = "ATR multiple the close must clear beyond the zone edge to confirm a breaker (or to confirm the retest held and no breaker forms).")

i_minPenetrationPct = input.float(0.15, "Min Retest Penetration (%)", minval = 0.0, maxval = 0.9, step = 0.05,
     group   = GRP_BRK,
     tooltip = "The Retest Qualification Filter. Price must travel at least this fraction of the zone's height into the zone before a confirmation is accepted as valid. Rejects shallow touch-and-go retests that would otherwise inflate breaker count.")

// ── Quality Score ────────────────────────────────────────────────────
i_useQualityFilter = input.bool(true, "Filter Breakers by Quality Score",
     group   = GRP_QS,
     tooltip = "When enabled, only breakers scoring at or above the threshold are created and drawn.")

i_qualityThreshold = input.int(60, "Minimum Quality Score", minval = 0, maxval = 100,
     group   = GRP_QS,
     tooltip = "Breakers scoring below this value are discarded silently — no box, no label, no alert.")

i_idealPenetration = input.float(0.5, "Ideal Retest Penetration Ratio", minval = 0.1, maxval = 0.9, step = 0.05,
     group   = GRP_QS,
     tooltip = "The retest-precision factor scores penetration depth on a curve centered on this ratio of zone height. 0.5 = a clean tag near the middle of the zone scores highest.")

// ── Advanced: Quality Score Weights ─────────────────────────────────
i_wBos = input.float(1.0, "Weight: Structure Break Strength", minval = 0.0, maxval = 3.0, step = 0.1, group = GRP_QSW)
i_wDisp = input.float(1.0, "Weight: Original Impulse Size", minval = 0.0, maxval = 3.0, step = 0.1, group = GRP_QSW)
i_wRetest = input.float(1.5, "Weight: Retest Precision", minval = 0.0, maxval = 3.0, step = 0.1, group = GRP_QSW)
i_wWick = input.float(1.0, "Weight: Wick Rejection Strength", minval = 0.0, maxval = 3.0, step = 0.1, group = GRP_QSW)
i_wTiming = input.float(0.75, "Weight: Confirmation Speed", minval = 0.0, maxval = 3.0, step = 0.1, group = GRP_QSW)
i_wDistance = input.float(0.75, "Weight: Distance Traveled", minval = 0.0, maxval = 3.0, step = 0.1, group = GRP_QSW)

// ── Visual Settings ──────────────────────────────────────────────────
i_colBullBrk = input.color(#26C6DA, "Bullish Breaker Color", group = GRP_VIS)
i_colBearBrk = input.color(#FF7043, "Bearish Breaker Color", group = GRP_VIS)

i_maxTransp = input.int(85, "Max Fill Transparency (Low Quality)", minval = 50, maxval = 95,
     group   = GRP_VIS,
     tooltip = "Fill transparency applied to breakers scoring near the quality threshold. Higher = more transparent.")

i_minTransp = input.int(55, "Min Fill Transparency (High Quality)", minval = 20, maxval = 90,
     group   = GRP_VIS,
     tooltip = "Fill transparency applied to breakers scoring near 100. Lower = more opaque, drawing the eye to the strongest setups.")

i_showMid = input.bool(true, "Show Zone Midline", group = GRP_VIS)

i_showLabel = input.bool(true, "Show Quality Label", group = GRP_VIS)

i_labelSize = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal"], group = GRP_VIS)

i_showPreview = input.bool(false, "Show Formation Preview (Experimental)",
     group   = GRP_VIS,
     tooltip = "Draws a thin dotted outline around candidates currently in the retest phase, before they qualify as a confirmed breaker. Off by default to keep the chart focused on confirmed zones only.")

i_previewCol = input.color(color.new(color.gray, 40), "Formation Preview Color", group = GRP_VIS)

// ── Lifecycle & Cleanup ──────────────────────────────────────────────
i_maxBreakers = input.int(12, "Max Active Breakers (per side)", minval = 2, maxval = 50,
     group   = GRP_LIFE,
     tooltip = "Oldest active breakers are removed first once this limit is reached, per direction.")

i_invalidateDispMult = input.float(0.15, "Invalidation Displacement (× ATR)", minval = 0.0, maxval = 2.0, step = 0.05,
     group   = GRP_LIFE,
     tooltip = "ATR multiple the close must clear beyond the opposite edge of an active breaker zone to mark it invalidated.")

i_lingerBars = input.int(20, "Invalidated Linger (bars)", minval = 0, maxval = 200,
     group   = GRP_LIFE,
     tooltip = "How long an invalidated breaker remains visible, dimmed, before being removed from the chart.")

i_maxAgeBars = input.int(400, "Max Breaker Age (bars)", minval = 20, maxval = 2000,
     group   = GRP_LIFE,
     tooltip = "Active or touched breakers older than this are automatically removed even if never invalidated.")

// ── Info Panel ────────────────────────────────────────────────────────
i_showPanel = input.bool(true, "Show Info Panel", group = GRP_PANEL)

i_panelPos = input.string("Top Right", "Panel Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group   = GRP_PANEL)

// ── Alerts ────────────────────────────────────────────────────────────
i_alrtFormed  = input.bool(true, "Alert: Breaker Formed",       group = GRP_ALRT)
i_alrtConfirm = input.bool(true, "Alert: Structure Confirmation", group = GRP_ALRT)
i_alrtTouch   = input.bool(true, "Alert: Price Entered Breaker", group = GRP_ALRT)
i_alrtInvalid = input.bool(true, "Alert: Breaker Invalidated",  group = GRP_ALRT)

// ──────────────────────────────────────────────────────────────────
// SECTION 2 — TYPES
// ──────────────────────────────────────────────────────────────────

// An unconfirmed order block being tracked through the breaker
// conversion pipeline. Never drawn on the chart directly (only its
// optional dotted "formation preview" is, once it reaches Retesting).
type OBCandidate
    bool  isBull            // true = bullish OB (born at swing low); its eventual breaker, if any, is BEARISH
    float top               // zone upper boundary
    float bot               // zone lower boundary
    float mid               // zone midpoint (cached)
    int   birthBar          // bar index of the source candle
    int   state             // 0 = Pending, 1 = Flipped, 2 = Retesting
    int   flipBar           // bar index the opposing structure break occurred
    float flipDisplacement  // ATR multiples the flip break exceeded the swing level by
    float obDisplacement    // ATR multiples of the source candle's own range
    float distanceAtr       // distance from source zone to the flip break level, in ATR
    int   retestStartBar    // bar index price first entered the zone
    float retestExtreme     // deepest penetration price reached while retesting
    int   confirmBar        // bar index of confirmation (valid only once converted)
    float wickRatio         // closing rejection ratio of the confirmation candle
    box   previewBox        // optional formation-preview drawing (na unless shown)

// A confirmed breaker block, drawn and tracked until mitigation.
type Breaker
    bool   isBull        // true = bullish breaker, false = bearish breaker
    float  top
    float  bot
    float  mid
    int    birthBar
    int    stateBar      // bar index of the last state transition
    int    state         // 0 = Active, 1 = Touched, 2 = Invalidated
    int    quality       // 0-100 quality score, fixed at creation
    box    zoneBox
    line   midLine
    label  lbl

// ──────────────────────────────────────────────────────────────────
// SECTION 3 — GLOBAL STATE
// ──────────────────────────────────────────────────────────────────

// Internal safety cap on candidate array growth (not user-exposed —
// candidates are already bounded by i_pendingTimeout / i_retestTimeout,
// this is a hard backstop against pathological data).
var int MAX_CANDIDATES = 150

// Order block candidates working their way through the breaker pipeline.
var OBCandidate[] bullCandidates = array.new<OBCandidate>()   // support zones, may become bearish breakers
var OBCandidate[] bearCandidates = array.new<OBCandidate>()   // resistance zones, may become bullish breakers

// Confirmed breaker zones.
var Breaker[] bullBreakers = array.new<Breaker>()
var Breaker[] bearBreakers = array.new<Breaker>()

// Structure engine registers.
var float lastSwingHigh  = na
var float lastSwingLow   = na
var int   lastSHBar      = na
var int   lastSLBar      = na
var bool  lastHighBroken = false
var bool  lastLowBroken  = false
var int   structBias     = 0     // 1 = bullish, -1 = bearish, 0 = undefined (display only)

// Per-bar event flags, reset every bar, used to drive alert() calls
// exactly once per qualifying event. Stored as single-element arrays
// (not plain globals) because Pine Script v6 forbids user-defined
// functions from reassigning outer-scope variables directly — arrays
// are reference types, so array.set() from inside a function is legal.
var bool[] evt_bullBreakerFormed = array.new<bool>(1, false)
var bool[] evt_bearBreakerFormed = array.new<bool>(1, false)
var bool[] evt_bullStructConfirm = array.new<bool>(1, false)
var bool[] evt_bearStructConfirm = array.new<bool>(1, false)
var bool[] evt_bullBreakerTouch  = array.new<bool>(1, false)
var bool[] evt_bearBreakerTouch  = array.new<bool>(1, false)
var bool[] evt_bullBreakerInval  = array.new<bool>(1, false)
var bool[] evt_bearBreakerInval  = array.new<bool>(1, false)

// Latest confirmed breaker details, used to build alert() messages.
// Also array-backed for the same reason as the event flags above.
var float[] lastEvtTop     = array.new<float>(1, na)
var float[] lastEvtBot     = array.new<float>(1, na)
var int[]   lastEvtQuality = array.new<int>(1, na)


// ──────────────────────────────────────────────────────────────────
// SECTION 4 — UTILITY FUNCTIONS
// ──────────────────────────────────────────────────────────────────

atr   = ta.atr(i_atrLen)
volMa = ta.sma(volume, i_volMaLen)

f_lblSize(string s) => s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : size.small


// Zone boundary helpers — body or wick, per user choice.
f_zoneTop(int idx) => i_useBody ? math.max(open[idx], close[idx]) : high[idx]
f_zoneBot(int idx) => i_useBody ? math.min(open[idx], close[idx]) : low[idx]

// Candle range filter for OB source candles.
f_sizeOk(int idx) => atr[idx] > 0 and (high[idx] - low[idx]) >= i_obMinSizeAtr * atr[idx]

// Volume confirmation filter for OB source candles.
f_volOk(int idx) => not i_useVolFilter or (volMa[idx] > 0 and volume[idx] / volMa[idx] >= i_volMult)

// Clip a value into [0, 100].
f_clip100(float v) => math.max(0.0, math.min(100.0, v))

// ── Quality Score sub-factors (each returns 0-100) ──────────────────

// Structure break strength: displacement of the invalidating BOS/CHoCH
// beyond the swing level, in ATR multiples, capped at 2.0 ATR = 100.
f_scoreBos(float dispAtr) => f_clip100((dispAtr / 2.0) * 100.0)

// Original impulse size: source candle range in ATR multiples, capped
// at 3.0 ATR = 100.
f_scoreDisp(float dispAtr) => f_clip100((dispAtr / 3.0) * 100.0)

// Retest precision: scores highest when penetration ratio sits at the
// user-defined ideal depth, decaying linearly toward either extreme.
f_scoreRetest(float ratio) =>
    float dist    = math.abs(ratio - i_idealPenetration)
    float maxDist = math.max(i_idealPenetration, 1.0 - i_idealPenetration)
    f_clip100(100.0 * (1.0 - dist / maxDist))

// Wick rejection strength: fraction of the confirmation candle's range
// made up of the rejecting wick.
f_scoreWick(float ratio) => f_clip100(ratio * 100.0)

// Confirmation speed: fewer bars between retest entry and confirmation
// scores higher, relative to the retest window.
f_scoreTiming(int barsUsed) =>
    float ratio = i_retestTimeout > 0 ? float(barsUsed) / float(i_retestTimeout) : 1.0
    f_clip100(100.0 * (1.0 - math.min(ratio, 1.0)))

// Distance traveled before the retest, in ATR multiples, capped at 5.0
// ATR = 100. A larger impulse leg implies a more meaningful flip.
f_scoreDistance(float distAtr) => f_clip100((distAtr / 5.0) * 100.0)

// Weighted composite quality score, auto-normalized against whatever
// weights the user has set (so weights never need to sum to 1).
f_qualityScore(
     float bosDisp, float obDisp, float retestRatio,
     float wickRatio, int barsUsed, float distAtr) =>

    float sBos      = f_scoreBos(bosDisp)
    float sDisp     = f_scoreDisp(obDisp)
    float sRetest   = f_scoreRetest(retestRatio)
    float sWick     = f_scoreWick(wickRatio)
    float sTiming   = f_scoreTiming(barsUsed)
    float sDistance = f_scoreDistance(distAtr)

    float totalW = i_wBos + i_wDisp + i_wRetest + i_wWick + i_wTiming + i_wDistance
    float score  = totalW > 0 ?
         (sBos * i_wBos + sDisp * i_wDisp + sRetest * i_wRetest +
          sWick * i_wWick + sTiming * i_wTiming + sDistance * i_wDistance) / totalW :
         (sBos + sDisp + sRetest + sWick + sTiming + sDistance) / 6.0

    int(math.round(score))

// Quality-adaptive fill transparency: higher score = lower transparency
// (more opaque), scaled between the min/max quality this filter allows.
f_qualityTransp(int quality) =>
    int lo = i_useQualityFilter ? i_qualityThreshold : 0
    float span = math.max(1.0, 100.0 - lo)
    float t = f_clip100(100.0 * (float(quality) - lo) / span) / 100.0
    int(math.round(i_maxTransp - t * (i_maxTransp - i_minTransp)))

// ──────────────────────────────────────────────────────────────────
// SECTION 5 — STRUCTURE ENGINE (BOS / CHoCH break events)
// ──────────────────────────────────────────────────────────────────
// Confirmed pivots only (ta.pivothigh/low inherently lag i_swingLen
// bars). A structure break fires exactly once per swing level — the
// "broken" flag resets only when a fresh pivot replaces the level,
// which prevents the same break from re-firing every bar that price
// simply remains beyond it.

float pivHigh = ta.pivothigh(high, i_swingLen, i_swingLen)
float pivLow  = ta.pivotlow(low,  i_swingLen, i_swingLen)

if not na(pivHigh)
    lastSwingHigh  := pivHigh
    lastSHBar      := bar_index - i_swingLen
    lastHighBroken := false

if not na(pivLow)
    lastSwingLow   := pivLow
    lastSLBar      := bar_index - i_swingLen
    lastLowBroken  := false

float structDispBuf = i_structDispFilter ? atr * i_structDispMult : 0.0

bool structBrokeUp   = not na(lastSwingHigh) and not lastHighBroken and close > lastSwingHigh + structDispBuf
bool structBrokeDown = not na(lastSwingLow)  and not lastLowBroken  and close < lastSwingLow  - structDispBuf

if structBrokeUp
    lastHighBroken := true
    structBias     := 1

if structBrokeDown
    lastLowBroken := true
    structBias    := -1

// Displacement of the current break event, in ATR multiples, cached
// once per bar so every candidate flipping on this bar shares the
// same measured break strength.
float curBosDownDisp = structBrokeDown and atr > 0 ? math.abs(close - lastSwingLow)  / atr : 0.0
float curBosUpDisp   = structBrokeUp   and atr > 0 ? math.abs(close - lastSwingHigh) / atr : 0.0

// ──────────────────────────────────────────────────────────────────
// SECTION 6 — ORDER BLOCK CANDIDATE CREATION
// ──────────────────────────────────────────────────────────────────
// The order block "source candle" is the last opposite-colored candle
// at or immediately before the confirmed swing pivot (fixed 5-bar
// lookback). If no qualifying candle is found, no candidate is
// created for that pivot — the script never forces a zone onto data
// that doesn't support one.

var int SOURCE_LOOKBACK = 5

// Bar offset (bars back) of the last bearish candle at/before pivotOffset.
f_findBearSource(int pivotOffset) =>
    int found = na
    for i = pivotOffset to pivotOffset + SOURCE_LOOKBACK
        if na(found) and close[i] < open[i]
            found := i
    found

// Bar offset of the last bullish candle at/before pivotOffset.
f_findBullSource(int pivotOffset) =>
    int found = na
    for i = pivotOffset to pivotOffset + SOURCE_LOOKBACK
        if na(found) and close[i] > open[i]
            found := i
    found

// New Bullish OB candidate at a confirmed swing low (support zone;
// may later convert into a BEARISH breaker).
if not na(pivLow) and array.size(bullCandidates) < MAX_CANDIDATES
    int srcOffset = f_findBearSource(i_swingLen)
    if not na(srcOffset) and f_sizeOk(srcOffset) and f_volOk(srcOffset)
        float zt = f_zoneTop(srcOffset)
        float zb = f_zoneBot(srcOffset)
        OBCandidate c = OBCandidate.new(
             isBull         = true,
             top            = zt,
             bot            = zb,
             mid            = (zt + zb) / 2.0,
             birthBar       = bar_index - srcOffset,
             state          = 0,
             obDisplacement = atr[srcOffset] > 0 ? (high[srcOffset] - low[srcOffset]) / atr[srcOffset] : 0.0)
        array.push(bullCandidates, c)

// New Bearish OB candidate at a confirmed swing high (resistance zone;
// may later convert into a BULLISH breaker).
if not na(pivHigh) and array.size(bearCandidates) < MAX_CANDIDATES
    int srcOffset = f_findBullSource(i_swingLen)
    if not na(srcOffset) and f_sizeOk(srcOffset) and f_volOk(srcOffset)
        float zt = f_zoneTop(srcOffset)
        float zb = f_zoneBot(srcOffset)
        OBCandidate c = OBCandidate.new(
             isBull         = false,
             top            = zt,
             bot            = zb,
             mid            = (zt + zb) / 2.0,
             birthBar       = bar_index - srcOffset,
             state          = 0,
             obDisplacement = atr[srcOffset] > 0 ? (high[srcOffset] - low[srcOffset]) / atr[srcOffset] : 0.0)
        array.push(bearCandidates, c)

// ──────────────────────────────────────────────────────────────────
// SECTION 7 — BREAKER CREATION HELPER
// ──────────────────────────────────────────────────────────────────
// Instantiates a confirmed breaker: draws its zone box, optional
// midline and quality label, enforces the per-direction breaker cap
// (oldest active breaker is dropped first), and raises the "formed"
// and "structure confirmation" event flags consumed by the alert
// block in Section 11.
f_createBreaker(bool isBull, float top, float bot, int quality) =>
    color baseCol = isBull ? i_colBullBrk : i_colBearBrk
    int   transp  = f_qualityTransp(quality)
    float mid     = (top + bot) / 2.0

    box zoneBox = box.new(
         left        = bar_index, right = bar_index,
         top         = top, bottom = bot,
         border_color = color.new(baseCol, 25),
         border_width = 1,
         bgcolor      = color.new(baseCol, transp),
         extend       = extend.none)

    line midLine = i_showMid ? line.new(
         bar_index, mid, bar_index, mid,
         color = color.new(baseCol, 40), style = line.style_dotted, width = 1) : na

    label lbl = i_showLabel ? label.new(
         bar_index, isBull ? bot : top,
         text      = (isBull ? "▲ Bullish Breaker  Q" : "▼ Bearish Breaker  Q") + str.tostring(quality),
         style     = isBull ? label.style_label_up : label.style_label_down,
         color     = color.new(baseCol, 10),
         textcolor = color.white,
         size      = f_lblSize(i_labelSize)) : na

    Breaker b = Breaker.new(
         isBull   = isBull, top = top, bot = bot, mid = mid,
         birthBar = bar_index, stateBar = bar_index, state = 0,
         quality  = quality, zoneBox = zoneBox, midLine = midLine, lbl = lbl)

    Breaker[] targetArr = isBull ? bullBreakers : bearBreakers
    array.push(targetArr, b)

    if array.size(targetArr) > i_maxBreakers
        Breaker oldest = array.shift(targetArr)
        box.delete(oldest.zoneBox)
        line.delete(oldest.midLine)
        label.delete(oldest.lbl)

    array.set(lastEvtTop, 0, top)
    array.set(lastEvtBot, 0, bot)
    array.set(lastEvtQuality, 0, quality)
    if isBull
        array.set(evt_bullBreakerFormed, 0, true)
        array.set(evt_bullStructConfirm, 0, true)
    else
        array.set(evt_bearBreakerFormed, 0, true)
        array.set(evt_bearStructConfirm, 0, true)


// ──────────────────────────────────────────────────────────────────
// SECTION 8 — BULLISH-OB CANDIDATE PIPELINE (→ BEARISH BREAKER)
// ──────────────────────────────────────────────────────────────────
// Pending (0): waiting for a bearish BOS/CHoCH to invalidate the zone.
// Flipped (1): structure has broken down; waiting for price to
//              retrace UP into the zone (retest from below).
// Retesting (2): price is inside the zone; confirms as a bearish
//              breaker only if price rejects downward through the
//              zone floor with sufficient penetration and displacement.
if array.size(bullCandidates) > 0
    for i = array.size(bullCandidates) - 1 to 0
        OBCandidate c = array.get(bullCandidates, i)
        bool remove = false

        if c.state == 0
            if bar_index - c.birthBar > i_pendingTimeout
                remove := true
            else if structBrokeDown
                c.state            := 1
                c.flipBar          := bar_index
                c.flipDisplacement := curBosDownDisp
                c.distanceAtr      := atr > 0 ? math.abs(close - c.mid) / atr : 0.0

        if not remove and c.state == 1
            if bar_index - c.flipBar > i_retestTimeout
                remove := true
            else if high >= c.bot
                c.state          := 2
                c.retestStartBar := bar_index
                c.retestExtreme  := high
                if i_showPreview
                    c.previewBox := box.new(bar_index, c.top, bar_index, c.bot,
                         border_color = i_previewCol, border_width = 1, border_style = line.style_dotted,
                         bgcolor = na, extend = extend.none)

        if not remove and c.state == 2
            c.retestExtreme := math.max(c.retestExtreme, high)
            float confBuf     = atr * i_confirmDispMult
            float penetration = c.top > c.bot ? (c.retestExtreme - c.bot) / (c.top - c.bot) : 1.0

            if not na(c.previewBox)
                box.set_right(c.previewBox, bar_index)

            if bar_index - c.retestStartBar > i_retestTimeout
                remove := true
            else if close > c.top + confBuf
                remove := true   // retest succeeded upward — no breaker, zone behaved normally
            else if close < c.bot - confBuf and penetration >= i_minPenetrationPct
                float rng = high - low
                c.confirmBar := bar_index
                c.wickRatio  := rng > 0 ? (high - math.max(open, close)) / rng : 0.0
                int barsUsed = bar_index - c.retestStartBar
                int quality  = f_qualityScore(c.flipDisplacement, c.obDisplacement, penetration, c.wickRatio, barsUsed, c.distanceAtr)
                if not i_useQualityFilter or quality >= i_qualityThreshold
                    f_createBreaker(false, c.top, c.bot, quality)
                remove := true

        if remove
            if not na(c.previewBox)
                box.delete(c.previewBox)
            array.remove(bullCandidates, i)


// ──────────────────────────────────────────────────────────────────
// SECTION 9 — BEARISH-OB CANDIDATE PIPELINE (→ BULLISH BREAKER)
// ──────────────────────────────────────────────────────────────────
// Mirror image of Section 8. Pending → Flipped (bullish BOS/CHoCH
// invalidates the resistance zone) → Retesting (price retraces DOWN
// into the zone) → confirms as a bullish breaker if price rejects
// upward through the zone ceiling with sufficient penetration and
// displacement.
if array.size(bearCandidates) > 0
    for i = array.size(bearCandidates) - 1 to 0
        OBCandidate c = array.get(bearCandidates, i)
        bool remove = false

        if c.state == 0
            if bar_index - c.birthBar > i_pendingTimeout
                remove := true
            else if structBrokeUp
                c.state            := 1
                c.flipBar          := bar_index
                c.flipDisplacement := curBosUpDisp
                c.distanceAtr      := atr > 0 ? math.abs(close - c.mid) / atr : 0.0

        if not remove and c.state == 1
            if bar_index - c.flipBar > i_retestTimeout
                remove := true
            else if low <= c.top
                c.state          := 2
                c.retestStartBar := bar_index
                c.retestExtreme  := low
                if i_showPreview
                    c.previewBox := box.new(bar_index, c.top, bar_index, c.bot,
                         border_color = i_previewCol, border_width = 1, border_style = line.style_dotted,
                         bgcolor = na, extend = extend.none)

        if not remove and c.state == 2
            c.retestExtreme := math.min(c.retestExtreme, low)
            float confBuf     = atr * i_confirmDispMult
            float penetration = c.top > c.bot ? (c.top - c.retestExtreme) / (c.top - c.bot) : 1.0

            if not na(c.previewBox)
                box.set_right(c.previewBox, bar_index)

            if bar_index - c.retestStartBar > i_retestTimeout
                remove := true
            else if close < c.bot - confBuf
                remove := true   // retest succeeded downward — no breaker, zone behaved normally
            else if close > c.top + confBuf and penetration >= i_minPenetrationPct
                float rng = high - low
                c.confirmBar := bar_index
                c.wickRatio  := rng > 0 ? (math.min(open, close) - low) / rng : 0.0
                int barsUsed = bar_index - c.retestStartBar
                int quality  = f_qualityScore(c.flipDisplacement, c.obDisplacement, penetration, c.wickRatio, barsUsed, c.distanceAtr)
                if not i_useQualityFilter or quality >= i_qualityThreshold
                    f_createBreaker(true, c.top, c.bot, quality)
                remove := true

        if remove
            if not na(c.previewBox)
                box.delete(c.previewBox)
            array.remove(bearCandidates, i)


// ──────────────────────────────────────────────────────────────────
// SECTION 10 — BREAKER LIFECYCLE (touch / invalidate / cleanup)
// ──────────────────────────────────────────────────────────────────
// A bullish breaker is invalidated once price closes decisively BELOW
// its zone floor (the support it was expected to hold has failed
// outright). A bearish breaker is invalidated once price closes
// decisively ABOVE its zone ceiling. "Touched" simply marks that
// price has returned into an active zone at least once — informative
// for the alert system, not itself a removal condition.
f_updateBreakerSide(Breaker[] arr, bool isBull) =>
    if array.size(arr) > 0
        for i = array.size(arr) - 1 to 0
            Breaker b = array.get(arr, i)
            bool dropNow = false

            // Extend the zone box's right edge to the current bar while active/touched.
            if b.state != 2
                box.set_right(b.zoneBox, bar_index)
                if not na(b.midLine)
                    line.set_x2(b.midLine, bar_index)

            float invBuf = atr * i_invalidateDispMult

            if b.state == 0 or b.state == 1
                bool priceInZone = low <= b.top and high >= b.bot
                if b.state == 0 and priceInZone
                    b.state    := 1
                    b.stateBar := bar_index
                    if b.isBull
                        array.set(evt_bullBreakerTouch, 0, true)
                    else
                        array.set(evt_bearBreakerTouch, 0, true)
                    array.set(lastEvtTop, 0, b.top)
                    array.set(lastEvtBot, 0, b.bot)
                    array.set(lastEvtQuality, 0, b.quality)

                bool invalidated = b.isBull ? close < b.bot - invBuf : close > b.top + invBuf
                if invalidated
                    b.state    := 2
                    b.stateBar := bar_index
                    box.set_bgcolor(b.zoneBox, color.new(color.gray, 88))
                    box.set_border_color(b.zoneBox, color.new(color.gray, 60))
                    if not na(b.midLine)
                        line.set_color(b.midLine, color.new(color.gray, 70))
                    if b.isBull
                        array.set(evt_bullBreakerInval, 0, true)
                    else
                        array.set(evt_bearBreakerInval, 0, true)
                    array.set(lastEvtTop, 0, b.top)
                    array.set(lastEvtBot, 0, b.bot)
                    array.set(lastEvtQuality, 0, b.quality)


            // Cleanup: invalidated zones linger briefly then are removed;
            // any zone (any state) exceeding max age is removed outright.
            if b.state == 2 and bar_index - b.stateBar > i_lingerBars
                dropNow := true
            if bar_index - b.birthBar > i_maxAgeBars
                dropNow := true

            if dropNow
                box.delete(b.zoneBox)
                line.delete(b.midLine)
                label.delete(b.lbl)
                array.remove(arr, i)

f_updateBreakerSide(bullBreakers, true)
f_updateBreakerSide(bearBreakers, false)

// ──────────────────────────────────────────────────────────────────
// SECTION 11 — INFO PANEL
// ──────────────────────────────────────────────────────────────────
// A compact, single-purpose panel: active breaker counts per
// direction and the current structural bias. This is not a scanner
// dashboard — it exists only to answer "how many valid breaker zones
// are currently on the chart and which way is structure leaning",
// which the boxes alone don't make quickly scannable at a glance.
var table infoPanel = na

f_panelPos(string s) => s == "Top Right" ? position.top_right : s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : position.bottom_left


if barstate.islast and i_showPanel
    if na(infoPanel)
        infoPanel := table.new(f_panelPos(i_panelPos), 2, 4,
             bgcolor = color.new(color.black, 15), border_color = color.new(color.gray, 60), border_width = 1)

    int bullActive = array.size(bullBreakers)
    int bearActive = array.size(bearBreakers)
    string biasTxt = structBias == 1 ? "Bullish" : structBias == -1 ? "Bearish" : "Undefined"
    color  biasCol = structBias == 1 ? i_colBullBrk : structBias == -1 ? i_colBearBrk : color.gray

    table.cell(infoPanel, 0, 0, "Breaker Block Identifier", text_color = color.white, text_halign = text.align_left, bgcolor = color.new(color.gray, 40), text_size = size.small)
    table.cell(infoPanel, 1, 0, "", text_color = color.new(color.white, 30), text_halign = text.align_right, bgcolor = color.new(color.gray, 40), text_size = size.small)

    table.cell(infoPanel, 0, 1, "Bullish Breakers", text_color = color.gray, text_halign = text.align_left, text_size = size.small)
    table.cell(infoPanel, 1, 1, str.tostring(bullActive), text_color = i_colBullBrk, text_halign = text.align_right, text_size = size.small)

    table.cell(infoPanel, 0, 2, "Bearish Breakers", text_color = color.gray, text_halign = text.align_left, text_size = size.small)
    table.cell(infoPanel, 1, 2, str.tostring(bearActive), text_color = i_colBearBrk, text_halign = text.align_right, text_size = size.small)

    table.cell(infoPanel, 0, 3, "Structure Bias", text_color = color.gray, text_halign = text.align_left, text_size = size.small)
    table.cell(infoPanel, 1, 3, biasTxt, text_color = biasCol, text_halign = text.align_right, text_size = size.small)

// ──────────────────────────────────────────────────────────────────
// SECTION 12 — ALERTS
// ──────────────────────────────────────────────────────────────────
// Every alert fires from confirmed-bar state only (all upstream logic
// already runs on barstate.isconfirmed-safe structures — pivots and
// closes never repaint once printed). Each condition is gated by its
// own toggle so users can subscribe to exactly the events they need.

if i_alrtFormed and array.get(evt_bullBreakerFormed, 0)
    alert("Bullish Breaker Block formed on " + syminfo.ticker + " (" + timeframe.period + "). Zone: " +
         str.tostring(array.get(lastEvtBot, 0), format.mintick) + " - " + str.tostring(array.get(lastEvtTop, 0), format.mintick) +
         " | Quality: " + str.tostring(array.get(lastEvtQuality, 0)), alert.freq_once_per_bar_close)

if i_alrtFormed and array.get(evt_bearBreakerFormed, 0)
    alert("Bearish Breaker Block formed on " + syminfo.ticker + " (" + timeframe.period + "). Zone: " +
         str.tostring(array.get(lastEvtBot, 0), format.mintick) + " - " + str.tostring(array.get(lastEvtTop, 0), format.mintick) +
         " | Quality: " + str.tostring(array.get(lastEvtQuality, 0)), alert.freq_once_per_bar_close)

if i_alrtConfirm and array.get(evt_bullStructConfirm, 0)
    alert("Bullish structure confirmation: failed retest converted bearish OB into a breaker on " +
         syminfo.ticker + " (" + timeframe.period + ").", alert.freq_once_per_bar_close)

if i_alrtConfirm and array.get(evt_bearStructConfirm, 0)
    alert("Bearish structure confirmation: failed retest converted bullish OB into a breaker on " +
         syminfo.ticker + " (" + timeframe.period + ").", alert.freq_once_per_bar_close)

if i_alrtTouch and array.get(evt_bullBreakerTouch, 0)
    alert("Price entered a Bullish Breaker zone on " + syminfo.ticker + " (" + timeframe.period + "). Zone: " +
         str.tostring(array.get(lastEvtBot, 0), format.mintick) + " - " + str.tostring(array.get(lastEvtTop, 0), format.mintick), alert.freq_once_per_bar_close)

if i_alrtTouch and array.get(evt_bearBreakerTouch, 0)
    alert("Price entered a Bearish Breaker zone on " + syminfo.ticker + " (" + timeframe.period + "). Zone: " +
         str.tostring(array.get(lastEvtBot, 0), format.mintick) + " - " + str.tostring(array.get(lastEvtTop, 0), format.mintick), alert.freq_once_per_bar_close)

if i_alrtInvalid and array.get(evt_bullBreakerInval, 0)
    alert("Bullish Breaker invalidated on " + syminfo.ticker + " (" + timeframe.period + "). Zone: " +
         str.tostring(array.get(lastEvtBot, 0), format.mintick) + " - " + str.tostring(array.get(lastEvtTop, 0), format.mintick), alert.freq_once_per_bar_close)

if i_alrtInvalid and array.get(evt_bearBreakerInval, 0)
    alert("Bearish Breaker invalidated on " + syminfo.ticker + " (" + timeframe.period + "). Zone: " +
         str.tostring(array.get(lastEvtBot, 0), format.mintick) + " - " + str.tostring(array.get(lastEvtTop, 0), format.mintick), alert.freq_once_per_bar_close)

// Reset per-bar event flags so each alert fires exactly once per
// qualifying bar close, never carrying state into the next bar.
array.set(evt_bullBreakerFormed, 0, false)
array.set(evt_bearBreakerFormed, 0, false)
array.set(evt_bullStructConfirm, 0, false)
array.set(evt_bearStructConfirm, 0, false)
array.set(evt_bullBreakerTouch, 0, false)
array.set(evt_bearBreakerTouch, 0, false)
array.set(evt_bullBreakerInval, 0, false)
array.set(evt_bearBreakerInval, 0, false)
````

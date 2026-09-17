<!-- tradingview-pine-id: PUB;8f72280622f34390ac44109b5362dfdd -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Judas Swing Detector [algotim]

Source: https://www.tradingview.com/script/xCj8zFVS-Judas-Swing-Detector-algotim/

## Description

Judas Swing Detector is a session-based reversal indicator that models the institutional Judas Swing as a complete, sequential price event rather than a single false-breakout candle. Instead of flagging every session-open wick that reverses, the script requires a full chain of confirmed conditions — a locked Initial Range, a liquidity sweep beyond it, a rejection close back inside, an optional market structure shift, institutional-grade displacement, and higher-timeframe trend agreement — before a signal is ever scored, drawn, or alerted.

Problem Statement
A Judas Swing is commonly described as "price sweeps one side of the session open and reverses," but that description alone matches an enormous number of ordinary, low-quality wicks. Scripts that flag every such wick generate far more noise than usable signal, because a sweep and a close-back-inside is only the first half of the institutional sequence — it says nothing about whether the reversal has real structural or momentum support, or whether it agrees with the underlying daily trend.

This indicator addresses that gap by treating the Judas Swing as a seven-stage sequence and only surfacing a signal once every enabled stage has been satisfied on confirmed price data, with the overall setup then ranked by a disclosed, weighted confidence score.

Methodology
A session window (London Open, New York Open, or a fully custom session and timezone) drives an Initial Range engine that locks the session's high and low once a configurable opening window (5, 10, 15 or 30 minutes) elapses. The Initial Range is drawn as a transparent box and extends for the remainder of the session.

Once the Initial Range is locked, the script watches for a liquidity sweep: a wick that pierces beyond the Initial Range high or low by at least a minimum ATR-based distance, with the same candle closing back inside the range. This closing-back-inside requirement is what separates a genuine sweep-and-reject from an ordinary breakout continuation.

A confirmed sweep becomes a pending candidate. If Market Structure Confirmation is enabled, the candidate must be followed by a genuine structure shift measured against minor swing pivots that form strictly after the sweep bar: a higher high following a low-side sweep, or a lower low following a high-side sweep. Candidates that do not produce this structure shift within a configurable bar timeout are discarded with no signal created.

A qualifying candidate is then subjected to a Displacement Filter, requiring the confirming candle's body to reach a minimum ATR multiple, and an optional Higher Timeframe Bias check, requiring a fast/slow EMA relationship on a user-selected higher timeframe (e.g. 1H, 4H, Daily) to agree with the reversal direction. Only after every enabled stage passes does the script compute the Judas Confidence Filter score.

The Judas Confidence Filter combines five independently disclosed, user-weighted factors into a single 0-100 score: sweep depth (how far price pierced beyond the Initial Range in ATR units), displacement (the confirming candle's body size in ATR units), HTF agreement (the normalized separation between the fast and slow higher-timeframe EMA, reflecting how decisively the higher-timeframe trend supports the direction), rejection quality (where the sweep candle closed within its own range), and reversal aggression (how few bars elapsed between the sweep and structure confirmation). Weights are user-adjustable and auto-normalized. A signal is only plotted and only triggers alerts if its score meets the Minimum Confidence Score threshold — this is a genuine filtering mechanism that changes what is drawn, not a cosmetic label applied afterward.

Confirmed signals optionally draw an Entry Zone between the 50% and 62% retracement of the confirming displacement candle, reflecting where institutional-style retracement entries are commonly sought after a confirmed reversal, along with a stop-reference line at the sweep extreme. Both extend forward and are visually dimmed once price closes back through the sweep extreme, marking the setup invalidated.

Signal Workflow
Step 1 — the selected session opens and the Initial Range begins building from the session's first 5-30 minutes of price action.
Step 2 — the Initial Range locks; the script now watches for a liquidity sweep beyond either side of that locked range.
Step 3 — a wick pierces beyond the range by a minimum ATR distance and the same candle closes back inside, registering a pending sweep candidate.
Step 4 — if enabled, the candidate must be followed by a market structure shift measured against post-sweep swing pivots, within a bounded bar timeout.
Step 5 — the confirming candle must clear the ATR-based displacement threshold, and if enabled, the higher-timeframe EMA bias must agree with the reversal direction.
Step 6 — the completed sequence is scored by the Judas Confidence Filter across five weighted factors; only scores at or above the minimum threshold are plotted and alerted.
Step 7 — an optional 50%-62% entry zone and stop-reference line are drawn from the confirming candle and remain active until price closes back through the original sweep extreme.

Why This Indicator Is Different
Most public "Judas Swing" or session-sweep scripts fire on the sweep-and-close-back-inside event alone, with no structural or momentum confirmation and no higher-timeframe context.
This script models the full institutional sequence explicitly — session, Initial Range, sweep, rejection, structure shift, displacement, HTF agreement — and only creates a signal after every enabled stage resolves in order on confirmed bar closes.
The Judas Confidence Filter converts five independently disclosed factors, including reversal aggression measured in bars-to-confirmation and rejection quality measured from close position within the sweep candle's own range, into a single adjustable score rather than a binary flag.
Confidence weighting is fully exposed, letting the ranking be tuned toward sweep depth, displacement strength, higher-timeframe agreement, rejection quality, or reversal speed depending on the trader's approach.
The optional 50%-62% Entry Zone models a specific, disclosed institutional retracement convention rather than simply marking the signal bar.

Inputs
Session Engine
Session (London Open / New York Open / Custom)
Custom Session Window
Session Timezone

Initial Range
Initial Range Duration (5/10/15/30 minutes)
Show Initial Range Box

Liquidity Sweep Detection
Minimum Sweep Pierce (x ATR)

Market Structure Confirmation
Require MSS Confirmation
MSS Pivot Length
MSS Timeout (bars)

Displacement Filter
Displacement Threshold (x ATR)
ATR Length

Higher Timeframe Bias
Require HTF Bias Agreement
HTF Timeframe
HTF Fast/Slow EMA Length

Judas Confidence Filter
Minimum Confidence Score
High-Confidence Threshold
Advanced weight sliders for sweep depth, displacement, HTF agreement, rejection quality, and reversal aggression

Entry Zone
Show Entry Zone (50%-62% Retracement)
Entry Zone Extension (bars)

Visual Settings
Show Sweep Markers / Confirmation Arrows / Stop Marker
Label Size
Bullish/Bearish/Initial Range/Elite Score Colors

Status Panel
Show Status Panel
Panel Position

Alerts
Alerts are available for:
Session Started
Liquidity Sweep detected
Bullish Judas Swing confirmed
Bearish Judas Swing confirmed
High-Confidence Judas Swing (Elite grade)
Higher-Timeframe Bias Change
Entry Zone Reached

Practical Usage
Use the status panel's HTF Bias reading as directional context before evaluating an individual Judas signal.
Treat a High-Confidence (Elite) signal as a materially stronger setup than one that merely clears the minimum threshold, since it reflects agreement across all five scored factors rather than a narrow pass.
Raise the Minimum Confidence Score on lower timeframes or noisy instruments to reduce the number of marginal signals generated.
Disable Require MSS Confirmation only if you specifically want to evaluate the sweep-and-rejection event on its own, understanding this removes one of the seven confirming stages.
Combine the alert feed with a broader trade plan, since each alert marks a structural event, not an execution signal.

Limitations
The Initial Range and session logic depend on the chart's intrabar data matching the selected session window; behavior on markets with irregular or 24-hour sessions may differ from traditional FX/futures sessions.
Market structure confirmation depends on minor swing pivots, which require bars to form on both sides before they confirm, introducing an inherent, bounded delay.
Confidence scoring is a relative, disclosed ranking and does not predict the outcome of any individual signal.
The higher-timeframe bias is read via a standard non-repainting security call and reflects EMA relationship only; it is not an independent trend-strength model.
As with any structure-based tool, results will vary across instruments, timeframes, and market regimes.

Notes
This indicator is a session and structure analysis tool intended to organize and score the Judas Swing sequence through a disclosed, multi-stage validation process.
All session state, sweep detection, structure confirmation, displacement, and scoring are evaluated on confirmed bar closes only, so no element of the script repaints once drawn.
The output is intended to support structural analysis and is not a standalone buy or sell recommendation.

---

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════
// Judas Swing Detector [algotim]
// Author : algotim
// Version: 1.0.0
//
// ── WHAT THIS SCRIPT DOES ─────────────────────────────────────────
// Models the institutional "Judas Swing" as a full sequence, not a
// single candlestick event. A Judas Swing is the false, liquidity-
// driven move away from the true daily direction that occurs around
// a session open, engineered to trigger stops and induce retail
// entries before price reverses into the real trend. Most public
// scripts flag every session-open false breakout. This script instead
// requires the entire institutional sequence to complete, in order,
// on confirmed data, before a signal is ever drawn:
//
//   1. A session opens (London Open, New York Open, or a custom
//      user-defined window).
//   2. An Initial Range (IR) is built from the session's first 5,
//      10, 15 or 30 minutes.
//   3. Price sweeps beyond the IR high or low — the false move.
//   4. Price closes back inside the IR — the rejection.
//   5. (Optional) A genuine market structure shift confirms the
//      reversal: a higher high after a low sweep, or a lower low
//      after a high sweep, measured against swings that form AFTER
//      the sweep itself.
//   6. The confirming candle shows real institutional displacement
//      (body size relative to ATR), not a marginal wiggle.
//   7. The reversal direction agrees with a higher-timeframe EMA
//      trend bias — a Judas Swing against the daily trend is a much
//      lower-quality signal than one that resolves back into it.
//
// Only setups that clear every enabled stage are scored. Only scores
// at or above the confidence threshold are ever plotted or alerted.
//
// ── CORE INNOVATION: JUDAS CONFIDENCE FILTER™ ─────────────────────
// Every completed sequence receives a transparent 0-100 confidence
// score built from five disclosed, user-weighted factors:
//   • Sweep Depth       — how far the wick pierced beyond the IR,
//                          in ATR units.
//   • Displacement       — the confirming candle's body size in ATR
//                          units.
//   • HTF Agreement      — normalized separation between the fast and
//                          slow higher-timeframe EMA, i.e. how
//                          decisively the HTF trend supports this
//                          direction rather than merely allowing it.
//   • Rejection Quality   — where the sweep candle closed within its
//                          own range (a close near the opposite
//                          extreme signals a stronger rejection than
//                          a marginal close-back-inside).
//   • Reversal Aggression — how few bars elapsed between the sweep
//                          and structure confirmation; a fast
//                          reversal is a stronger institutional
//                          signature than a slow, grinding one.
// Weights are user-adjustable and auto-normalized. Signals scoring
// below the Minimum Confidence Score are suppressed entirely — this
// is a real filtering mechanism that changes what gets drawn, not a
// cosmetic label added after the fact.
//
// ── NON-REPAINTING DESIGN ──────────────────────────────────────────
// Session state, the Initial Range, sweep detection, structure
// confirmation, displacement, scoring and invalidation are all
// evaluated strictly on confirmed bar closes (barstate.isconfirmed).
// Minor swing pivots use ta.pivothigh/ta.pivotlow, which by definition
// only confirm once enough bars exist on both sides. The higher
// timeframe bias is read via request.security with
// barmerge.lookahead_off, the standard non-repainting configuration.
// ══════════════════════════════════════════════════════════════════

indicator(
     title            = "Judas Swing Detector [algotim]",
     shorttitle       = "Judas Swing [algotim]",
     overlay          = true,
     max_bars_back    = 500,
     max_boxes_count  = 300,
     max_labels_count = 300,
     max_lines_count  = 300)

// ──────────────────────────────────────────────────────────────────
// SECTION 1 — INPUTS
// ──────────────────────────────────────────────────────────────────
GRP_SESSION = "Session Engine"
GRP_IR      = "Initial Range"
GRP_SWEEP   = "Liquidity Sweep Detection"
GRP_MSS     = "Market Structure Confirmation"
GRP_DISP    = "Displacement Filter"
GRP_HTF     = "Higher Timeframe Bias"
GRP_CONF    = "Judas Confidence Filter\u2122"
GRP_ENTRY   = "Entry Zone"
GRP_VIS     = "Visual Settings"
GRP_PANEL   = "Status Panel"
GRP_ALERT   = "Alerts"

// ── Session Engine ──────────────────────────────────────────────────
i_sessionChoice = input.string("New York Open", "Session",
     options = ["London Open", "New York Open", "Custom"],
     group   = GRP_SESSION,
     tooltip = "Selects the session-open window the Initial Range is built from. Choose Custom to define your own window below.")

i_customSession = input.session("0930-1130", "Custom Session Window",
     group   = GRP_SESSION,
     tooltip = "Used only when Session above is set to Custom.")

i_sessionTZ = input.string("America/New_York", "Session Timezone",
     options = ["America/New_York", "Europe/London", "Asia/Tokyo", "UTC"],
     group   = GRP_SESSION,
     tooltip = "Timezone the session window is evaluated in.")

// ── Initial Range ────────────────────────────────────────────────────
i_irMinutesStr = input.string("15", "Initial Range Duration (minutes)",
     options = ["5", "10", "15", "30"],
     group   = GRP_IR,
     tooltip = "Length of the opening window used to build the Initial Range high/low. The IR locks once this window elapses.")

i_showIRBox = input.bool(true, "Show Initial Range Box", group = GRP_IR)

// ── Liquidity Sweep Detection ────────────────────────────────────────
i_minPierceAtr = input.float(0.05, "Minimum Sweep Pierce (\u00d7 ATR)",
     minval  = 0.0,
     step    = 0.01,
     group   = GRP_SWEEP,
     tooltip = "Minimum distance a wick must pierce beyond the Initial Range before it is registered as a liquidity sweep. Filters out insignificant touches.")

// ── Market Structure Confirmation ────────────────────────────────────
i_requireMSS = input.bool(true, "Require MSS Confirmation",
     group   = GRP_MSS,
     tooltip = "When enabled, a Judas Swing is only confirmed after a genuine market structure shift forms following the sweep: a higher high after a low sweep, or a lower low after a high sweep. When disabled, the sweep's own rejection close is treated as sufficient confirmation.")

i_mssPivotLen = input.int(3, "MSS Pivot Length",
     minval  = 2,
     maxval  = 20,
     group   = GRP_MSS,
     tooltip = "Bars required on each side to confirm the minor swing pivots used for structure-shift detection.")

i_mssTimeout = input.int(30, "MSS Timeout (bars)",
     minval  = 5,
     maxval  = 200,
     group   = GRP_MSS,
     tooltip = "A pending sweep that has not produced a confirmed structure shift within this many bars is discarded.")

// ── Displacement Filter ──────────────────────────────────────────────
i_dispMult = input.float(0.5, "Displacement Threshold (\u00d7 ATR)",
     minval  = 0.0,
     maxval  = 3.0,
     step    = 0.05,
     group   = GRP_DISP,
     tooltip = "The confirming candle's body must reach this ATR multiple before a Judas Swing is confirmed. Removes weak, low-conviction reversals.")

i_atrLen = input.int(14, "ATR Length",
     minval  = 5,
     maxval  = 100,
     group   = GRP_DISP,
     tooltip = "ATR period used throughout the script for the sweep, displacement and confidence-score calculations.")

// ── Higher Timeframe Bias ────────────────────────────────────────────
i_requireHTF = input.bool(true, "Require HTF Bias Agreement",
     group   = GRP_HTF,
     tooltip = "When enabled, a Judas Swing is only confirmed if its reversal direction agrees with the higher-timeframe EMA bias below.")

i_htf = input.timeframe("240", "HTF Timeframe", group = GRP_HTF)

i_htfFastLen = input.int(20, "HTF Fast EMA Length", minval = 2, maxval = 200, group = GRP_HTF)
i_htfSlowLen = input.int(50, "HTF Slow EMA Length", minval = 2, maxval = 400, group = GRP_HTF)

// ── Judas Confidence Filter\u2122 ─────────────────────────────────────────
i_minScore = input.int(60, "Minimum Confidence Score",
     minval  = 0,
     maxval  = 100,
     group   = GRP_CONF,
     tooltip = "Judas signals scoring below this threshold are suppressed entirely — they are never plotted and never alerted.")

i_highScore = input.int(80, "High-Confidence Threshold",
     minval  = 0,
     maxval  = 100,
     group   = GRP_CONF,
     tooltip = "Signals at or above this score trigger the separate High-Confidence Judas alert and display an elite marker on the chart.")

i_wSweep  = input.int(20, "Weight: Sweep Depth",        minval = 0, maxval = 100, group = GRP_CONF)
i_wDisp   = input.int(25, "Weight: Displacement",       minval = 0, maxval = 100, group = GRP_CONF)
i_wHtf    = input.int(20, "Weight: HTF Agreement",       minval = 0, maxval = 100, group = GRP_CONF)
i_wReject = input.int(20, "Weight: Rejection Quality",   minval = 0, maxval = 100, group = GRP_CONF)
i_wSpeed  = input.int(15, "Weight: Reversal Aggression", minval = 0, maxval = 100, group = GRP_CONF)

// ── Entry Zone ────────────────────────────────────────────────────────
i_showEntryZone = input.bool(true, "Show Entry Zone (50%-62% Retracement)",
     group   = GRP_ENTRY,
     tooltip = "Draws a retracement zone between 50% and 62% of the confirming displacement candle, the area institutional traders favor for entry after a Judas confirmation.")

i_entryExtend = input.int(20, "Entry Zone Extension (bars)",
     minval  = 5,
     maxval  = 100,
     group   = GRP_ENTRY,
     tooltip = "How many bars forward the entry zone and its projection line extend while still active.")

// ── Visual Settings ───────────────────────────────────────────────────
i_showSweepMarkers = input.bool(true, "Show Sweep Markers", group = GRP_VIS)
i_showArrows        = input.bool(true, "Show Confirmation Arrows", group = GRP_VIS)
i_showStop          = input.bool(true, "Show Stop Marker", group = GRP_VIS)

i_labelSize = input.string("Small", "Label Size",
     options = ["Tiny", "Small", "Normal"],
     group   = GRP_VIS)

i_colBull = input.color(color.new(#00e676, 0), "Bullish Colour", group = GRP_VIS)
i_colBear = input.color(color.new(#ef5350, 0), "Bearish Colour", group = GRP_VIS)
i_colIR   = input.color(color.new(#787b86, 0), "Initial Range Colour", group = GRP_VIS)
i_colElite = input.color(color.new(#ffd700, 0), "Elite Score Colour", group = GRP_VIS)

// ── Status Panel ──────────────────────────────────────────────────────
i_showPanel = input.bool(true, "Show Status Panel", group = GRP_PANEL)
i_panelPos  = input.string("Top Right", "Panel Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group   = GRP_PANEL)

// ── Alerts ────────────────────────────────────────────────────────────
i_alertSession   = input.bool(true, "Alert: Session Started",       group = GRP_ALERT)
i_alertSweep     = input.bool(true, "Alert: Liquidity Sweep",       group = GRP_ALERT)
i_alertBullJudas = input.bool(true, "Alert: Bullish Judas Swing",   group = GRP_ALERT)
i_alertBearJudas = input.bool(true, "Alert: Bearish Judas Swing",   group = GRP_ALERT)
i_alertHighConf  = input.bool(true, "Alert: High-Confidence Judas", group = GRP_ALERT)
i_alertHtfChange = input.bool(true, "Alert: HTF Bias Change",       group = GRP_ALERT)
i_alertEntryZone = input.bool(true, "Alert: Entry Zone Reached",    group = GRP_ALERT)

// ──────────────────────────────────────────────────────────────────
// SECTION 2 — STATE VARIABLES
// ──────────────────────────────────────────────────────────────────

// Session / IR engine
var float sessionStartTime = na
var int   sessionStartBar  = na
var bool  irBuilding       = false
var bool  irLocked         = false
var float irHigh           = na
var float irLow             = na
var box   irBox              = na

// Minor pivot register (continuous, session-independent — drives MSS)
var float minorPivHigh    = na
var float minorPivLow     = na
var int   minorPivHighBar = na
var int   minorPivLowBar  = na

// Sweep candidates
var bool  sweptLow          = false
var bool  sweptHigh         = false
var float sweepLowExtreme   = na
var float sweepHighExtreme  = na
var int   sweepLowBar       = na
var int   sweepHighBar      = na
var float postSweepPivHighForBull = na
var float postSweepPivLowForBear  = na

// Per-session confirmation guards (one high-quality signal per direction per session)
var bool bullConfirmedSession = false
var bool bearConfirmedSession = false

// Confirmed setup lifecycle (for entry-zone tracking / invalidation)
var bool  bullActive   = false
var bool  bearActive   = false
var float bullEntryTop = na
var float bullEntryBot = na
var float bearEntryTop = na
var float bearEntryBot = na
var box   bullZoneBox  = na
var box   bearZoneBox  = na
var line  bullEntryLine = na
var line  bearEntryLine = na
var line  bullStopLine  = na
var line  bearStopLine  = na

// HTF bias tracking
var int htfBiasPrev = 0

// Status panel memory
var string lastSignalDir   = "\u2014"
var int    lastSignalScore = na
var int    totalSignals    = 0
var table  statusTbl       = na

// Drawing object pools (pruned to avoid runaway object counts)
var array<box>   g_boxArr = array.new<box>()
var array<line>  g_lineArr = array.new<line>()
var array<label> g_lblArr  = array.new<label>()

// ──────────────────────────────────────────────────────────────────
// SECTION 3 — UTILITY FUNCTIONS  (must be declared at global scope)
// ──────────────────────────────────────────────────────────────────

f_lblSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : size.small

f_pruneBoxes() =>
    if array.size(g_boxArr) > 60
        box.delete(array.shift(g_boxArr))

f_pruneLines() =>
    if array.size(g_lineArr) > 60
        line.delete(array.shift(g_lineArr))

f_pruneLabels() =>
    if array.size(g_lblArr) > 120
        label.delete(array.shift(g_lblArr))

f_trackBox(box b) =>
    array.push(g_boxArr, b)
    f_pruneBoxes()
    b

f_trackLine(line l) =>
    array.push(g_lineArr, l)
    f_pruneLines()
    l

f_trackLabel(label lb) =>
    array.push(g_lblArr, lb)
    f_pruneLabels()
    lb

// Confidence grade word from score
f_scoreWord(int score) =>
    score >= i_highScore ? "Elite" : score >= i_minScore ? "Confirmed" : "Weak"

// Status panel row writer
f_row(table tbl, int r, string lbl, string val, color vc) =>
    table.cell(tbl, 0, r, lbl,
         text_color  = color.new(color.gray, 20),
         text_size   = size.small,
         bgcolor     = color.new(#1a1a2e, 15),
         text_halign = text.align_left)
    table.cell(tbl, 1, r, val,
         text_color  = vc,
         text_size   = size.small,
         bgcolor     = color.new(#1a1a2e, 15),
         text_halign = text.align_right)

// ──────────────────────────────────────────────────────────────────
// SECTION 4 — CORE CALCULATIONS
// ──────────────────────────────────────────────────────────────────

float atrVal = ta.atr(i_atrLen)

// Session window string — a ternary of input-qualified literals still
// resolves to an "input string", satisfying time()'s simple-string requirement.
string sessStr = i_sessionChoice == "London Open"   ? "0700-0900" :
                 i_sessionChoice == "New York Open" ? "0930-1130" :
                 i_customSession

bool inSession = not na(time(timeframe.period, sessStr, i_sessionTZ))
bool sessionStartedNow = inSession and not inSession[1]
bool sessionEndedNow   = inSession[1] and not inSession

int irMinutes   = int(str.tonumber(i_irMinutesStr))
int irDurationMs = irMinutes * 60 * 1000

// Minor swing pivots — continuous register used for structure-shift detection
float pivH = ta.pivothigh(high, i_mssPivotLen, i_mssPivotLen)
float pivL = ta.pivotlow(low,  i_mssPivotLen, i_mssPivotLen)

// ── Higher timeframe bias (non-repainting: lookahead_off) ───────────
[htfFast, htfSlow] = request.security(
     syminfo.tickerid, i_htf,
     [ta.ema(close, i_htfFastLen), ta.ema(close, i_htfSlowLen)],
     lookahead = barmerge.lookahead_off)

int htfBias = htfFast > htfSlow ? 1 : htfFast < htfSlow ? -1 : 0
float htfSepAtr = atrVal > 0 ? math.abs(htfFast - htfSlow) / atrVal : 0.0

// ──────────────────────────────────────────────────────────────────
// SECTION 5 — EVENT FLAGS (reset every bar; drive alerts at the bottom)
// ──────────────────────────────────────────────────────────────────
bool sessionStartEvent = false
bool sweepEventBull    = false
bool sweepEventBear    = false
bool bullJudasEvent    = false
bool bearJudasEvent    = false
bool highConfEvent     = false
bool htfChangeEvent    = false
bool entryZoneBullEvt  = false
bool entryZoneBearEvt  = false

string alertSweepDir  = ""
float  alertSweepPx   = na
string alertHtfDir    = ""
int    alertScore     = na
string alertScoreDir  = ""

// ──────────────────────────────────────────────────────────────────
// SECTION 6 — SESSION LIFECYCLE  (confirmed-bar only, non-repainting)
// ──────────────────────────────────────────────────────────────────
if barstate.isconfirmed

    // ── Update minor pivot register ──────────────────────────────
    if not na(pivH)
        minorPivHigh    := pivH
        minorPivHighBar := bar_index[i_mssPivotLen]
    if not na(pivL)
        minorPivLow    := pivL
        minorPivLowBar := bar_index[i_mssPivotLen]

    // ── New session begins: reset the working state ─────────────
    if sessionStartedNow
        sessionStartTime := time
        sessionStartBar  := bar_index
        irBuilding       := true
        irLocked         := false
        irHigh           := high
        irLow            := low
        sweptLow             := false
        sweptHigh            := false
        sweepLowExtreme       := na
        sweepHighExtreme      := na
        sweepLowBar           := na
        sweepHighBar          := na
        postSweepPivHighForBull := na
        postSweepPivLowForBear  := na
        bullConfirmedSession  := false
        bearConfirmedSession  := false
        sessionStartEvent     := true

    // ── Building the Initial Range ───────────────────────────────
    if irBuilding and inSession
        irHigh := math.max(irHigh, high)
        irLow  := math.min(irLow, low)
        if (time - sessionStartTime) >= irDurationMs
            irBuilding := false
            irLocked   := true
            if i_showIRBox
                irBox := f_trackBox(box.new(
                     left        = sessionStartBar,
                     top         = irHigh,
                     right       = bar_index + 1,
                     bottom      = irLow,
                     border_color = color.new(i_colIR, 40),
                     border_width = 1,
                     bgcolor      = color.new(i_colIR, 90)))

    // ── Extend the IR box forward while the session remains open ─
    if irLocked and inSession and i_showIRBox and not na(irBox)
        box.set_right(irBox, bar_index + 1)

    // ── Liquidity sweep detection (rejection close required) ─────
    if irLocked and inSession
        float pierceLow  = irLow  - low
        float pierceHigh = high - irHigh

        // Bullish candidate: wick pierces below IR low, close back inside
        if not sweptLow and not bullConfirmedSession and low < irLow and close >= irLow and pierceLow >= atrVal * i_minPierceAtr
            sweptLow             := true
            sweepLowExtreme      := low
            sweepLowBar          := bar_index
            postSweepPivHighForBull := na
            sweepEventBull       := true
            alertSweepDir        := "Bullish"
            alertSweepPx         := low

            if i_showSweepMarkers
                f_trackLabel(label.new(
                     x         = bar_index,
                     y         = low,
                     text      = "\u00d7",
                     style     = label.style_label_up,
                     color     = color.new(color.gray, 40),
                     textcolor = color.new(i_colBull, 10),
                     size      = size.tiny))

        // Bearish candidate: wick pierces above IR high, close back inside
        if not sweptHigh and not bearConfirmedSession and high > irHigh and close <= irHigh and pierceHigh >= atrVal * i_minPierceAtr
            sweptHigh            := true
            sweepHighExtreme     := high
            sweepHighBar         := bar_index
            postSweepPivLowForBear := na
            sweepEventBear       := true
            alertSweepDir        := "Bearish"
            alertSweepPx         := high

            if i_showSweepMarkers
                f_trackLabel(label.new(
                     x         = bar_index,
                     y         = high,
                     text      = "\u00d7",
                     style     = label.style_label_down,
                     color     = color.new(color.gray, 40),
                     textcolor = color.new(i_colBear, 10),
                     size      = size.tiny))

    // ── Track post-sweep pivots used for MSS confirmation ────────
    if sweptLow and not na(minorPivHighBar) and minorPivHighBar > sweepLowBar
        postSweepPivHighForBull := minorPivHigh

    if sweptHigh and not na(minorPivLowBar) and minorPivLowBar > sweepHighBar
        postSweepPivLowForBear := minorPivLow

    // ── MSS timeout: discard stale candidates ────────────────────
    if sweptLow and not bullConfirmedSession and (bar_index - sweepLowBar) > i_mssTimeout
        sweptLow := false
    if sweptHigh and not bearConfirmedSession and (bar_index - sweepHighBar) > i_mssTimeout
        sweptHigh := false

// ──────────────────────────────────────────────────────────────────
// SECTION 7 — STRUCTURE, DISPLACEMENT & HTF CONFIRMATION
// ──────────────────────────────────────────────────────────────────
if barstate.isconfirmed

    float rangeVal = high - low
    float bodyAtr  = atrVal > 0 ? math.abs(close - open) / atrVal : 0.0

    // ── Bullish confirmation path ─────────────────────────────────
    if sweptLow and not bullConfirmedSession
        bool mssOk = not i_requireMSS or (not na(postSweepPivHighForBull) and close > postSweepPivHighForBull)
        bool dispOk = bodyAtr >= i_dispMult
        bool htfOk  = not i_requireHTF or htfBias == 1

        if mssOk and dispOk and htfOk
            // ── Judas Confidence Filter\u2122 — five disclosed factors ──
            float sweepDepthAtr = atrVal > 0 ? (irLow - sweepLowExtreme) / atrVal : 0.0
            float fSweep  = math.min(sweepDepthAtr / 1.0, 1.0) * 100.0
            float fDisp   = math.min(bodyAtr / 1.5, 1.0) * 100.0
            float fHtf    = math.min(htfSepAtr / 0.5, 1.0) * 100.0
            float fReject = 50.0
            if sweepLowBar == bar_index
                fReject := rangeVal > 0 ? (close - low) / rangeVal * 100.0 : 50.0
            else
                fReject := 70.0
            int barsToConfirm = bar_index - sweepLowBar
            float fSpeed = math.max(0.0, 100.0 - (barsToConfirm - 1) * 20.0)

            float wSum = i_wSweep + i_wDisp + i_wHtf + i_wReject + i_wSpeed
            int score = wSum > 0 ? int(math.round((fSweep * i_wSweep + fDisp * i_wDisp + fHtf * i_wHtf + fReject * i_wReject + fSpeed * i_wSpeed) / wSum)) : 0

            if score >= i_minScore
                bullConfirmedSession := true
                sweptLow             := false
                bullActive           := true
                bullJudasEvent       := true
                totalSignals        += 1
                lastSignalDir        := "\u25b2 Bullish"
                lastSignalScore      := score
                alertScore           := score
                alertScoreDir        := "Bullish"

                bool elite = score >= i_highScore
                if elite
                    highConfEvent := true

                if i_showArrows
                    f_trackLabel(label.new(
                         x         = bar_index,
                         y         = low - atrVal * 0.5,
                         text      = "Judas \u25b2\n" + str.tostring(score) + (elite ? " \u2605" : ""),
                         style     = label.style_label_up,
                         color     = color.new(elite ? i_colElite : i_colBull, 10),
                         textcolor = color.white,
                         size      = f_lblSize(i_labelSize)))

                if i_showStop
                    bullStopLine := f_trackLine(line.new(
                         x1    = sweepLowBar,
                         y1    = sweepLowExtreme,
                         x2    = bar_index + i_entryExtend,
                         y2    = sweepLowExtreme,
                         color = color.new(i_colBear, 30),
                         style = line.style_dotted,
                         width = 1))

                if i_showEntryZone
                    float dTop = math.max(open, close)
                    float dBot = math.min(open, close)
                    float dRange = high - low
                    bullEntryTop := high - dRange * 0.5
                    bullEntryBot := high - dRange * 0.618
                    bullZoneBox := f_trackBox(box.new(
                         left         = bar_index,
                         top          = bullEntryTop,
                         right        = bar_index + i_entryExtend,
                         bottom       = bullEntryBot,
                         border_color = color.new(i_colBull, 40),
                         border_width = 1,
                         bgcolor      = color.new(i_colBull, 85)))
                    bullEntryLine := f_trackLine(line.new(
                         x1    = bar_index,
                         y1    = (bullEntryTop + bullEntryBot) / 2,
                         x2    = bar_index + i_entryExtend,
                         y2    = (bullEntryTop + bullEntryBot) / 2,
                         color = color.new(i_colBull, 20),
                         style = line.style_dashed,
                         width = 1))

    // ── Bearish confirmation path ─────────────────────────────────
    if sweptHigh and not bearConfirmedSession
        bool mssOk = not i_requireMSS or (not na(postSweepPivLowForBear) and close < postSweepPivLowForBear)
        bool dispOk = bodyAtr >= i_dispMult
        bool htfOk  = not i_requireHTF or htfBias == -1

        if mssOk and dispOk and htfOk
            float sweepDepthAtr = atrVal > 0 ? (sweepHighExtreme - irHigh) / atrVal : 0.0
            float fSweep  = math.min(sweepDepthAtr / 1.0, 1.0) * 100.0
            float fDisp   = math.min(bodyAtr / 1.5, 1.0) * 100.0
            float fHtf    = math.min(htfSepAtr / 0.5, 1.0) * 100.0
            float fReject = 50.0
            if sweepHighBar == bar_index
                fReject := rangeVal > 0 ? (high - close) / rangeVal * 100.0 : 50.0
            else
                fReject := 70.0
            int barsToConfirm = bar_index - sweepHighBar
            float fSpeed = math.max(0.0, 100.0 - (barsToConfirm - 1) * 20.0)

            float wSum = i_wSweep + i_wDisp + i_wHtf + i_wReject + i_wSpeed
            int score = wSum > 0 ? int(math.round((fSweep * i_wSweep + fDisp * i_wDisp + fHtf * i_wHtf + fReject * i_wReject + fSpeed * i_wSpeed) / wSum)) : 0

            if score >= i_minScore
                bearConfirmedSession := true
                sweptHigh            := false
                bearActive           := true
                bearJudasEvent       := true
                totalSignals        += 1
                lastSignalDir        := "\u25bc Bearish"
                lastSignalScore      := score
                alertScore           := score
                alertScoreDir        := "Bearish"

                bool elite = score >= i_highScore
                if elite
                    highConfEvent := true

                if i_showArrows
                    f_trackLabel(label.new(
                         x         = bar_index,
                         y         = high + atrVal * 0.5,
                         text      = "Judas \u25bc\n" + str.tostring(score) + (elite ? " \u2605" : ""),
                         style     = label.style_label_down,
                         color     = color.new(elite ? i_colElite : i_colBear, 10),
                         textcolor = color.white,
                         size      = f_lblSize(i_labelSize)))

                if i_showStop
                    bearStopLine := f_trackLine(line.new(
                         x1    = sweepHighBar,
                         y1    = sweepHighExtreme,
                         x2    = bar_index + i_entryExtend,
                         y2    = sweepHighExtreme,
                         color = color.new(i_colBull, 30),
                         style = line.style_dotted,
                         width = 1))

                if i_showEntryZone
                    float dRange = high - low
                    bearEntryTop := low + dRange * 0.618
                    bearEntryBot := low + dRange * 0.5
                    bearZoneBox := f_trackBox(box.new(
                         left         = bar_index,
                         top          = bearEntryTop,
                         right        = bar_index + i_entryExtend,
                         bottom       = bearEntryBot,
                         border_color = color.new(i_colBear, 40),
                         border_width = 1,
                         bgcolor      = color.new(i_colBear, 85)))
                    bearEntryLine := f_trackLine(line.new(
                         x1    = bar_index,
                         y1    = (bearEntryTop + bearEntryBot) / 2,
                         x2    = bar_index + i_entryExtend,
                         y2    = (bearEntryTop + bearEntryBot) / 2,
                         color = color.new(i_colBear, 20),
                         style = line.style_dashed,
                         width = 1))

// ──────────────────────────────────────────────────────────────────
// SECTION 8 — ENTRY ZONE TRACKING & INVALIDATION
// ──────────────────────────────────────────────────────────────────
if barstate.isconfirmed

    // ── Bullish zone: extend, detect touch, invalidate ───────────
    if bullActive
        if not na(bullZoneBox)
            box.set_right(bullZoneBox, bar_index + i_entryExtend)
        if not na(bullEntryLine)
            line.set_x2(bullEntryLine, bar_index + i_entryExtend)
        if not na(bullStopLine)
            line.set_x2(bullStopLine, bar_index + i_entryExtend)

        if i_showEntryZone and not na(bullEntryTop) and low <= bullEntryTop and high >= bullEntryBot
            entryZoneBullEvt := true

        if not na(sweepLowExtreme) and close < sweepLowExtreme
            bullActive := false
            if not na(bullZoneBox)
                box.set_border_color(bullZoneBox, color.new(color.gray, 70))
                box.set_bgcolor(bullZoneBox, color.new(color.gray, 92))
            if not na(bullStopLine)
                line.set_color(bullStopLine, color.new(color.gray, 70))

    // ── Bearish zone: extend, detect touch, invalidate ────────────
    if bearActive
        if not na(bearZoneBox)
            box.set_right(bearZoneBox, bar_index + i_entryExtend)
        if not na(bearEntryLine)
            line.set_x2(bearEntryLine, bar_index + i_entryExtend)
        if not na(bearStopLine)
            line.set_x2(bearStopLine, bar_index + i_entryExtend)

        if i_showEntryZone and not na(bearEntryTop) and low <= bearEntryTop and high >= bearEntryBot
            entryZoneBearEvt := true

        if not na(sweepHighExtreme) and close > sweepHighExtreme
            bearActive := false
            if not na(bearZoneBox)
                box.set_border_color(bearZoneBox, color.new(color.gray, 70))
                box.set_bgcolor(bearZoneBox, color.new(color.gray, 92))
            if not na(bearStopLine)
                line.set_color(bearStopLine, color.new(color.gray, 70))

    // ── HTF bias change tracking ──────────────────────────────────
    if htfBiasPrev != 0 and htfBias != htfBiasPrev and htfBias != 0
        htfChangeEvent := true
        alertHtfDir    := htfBias == 1 ? "Bullish" : "Bearish"
    if htfBias != 0
        htfBiasPrev := htfBias

// ──────────────────────────────────────────────────────────────────
// SECTION 9 — STATUS PANEL
// ──────────────────────────────────────────────────────────────────
panelPos = i_panelPos == "Top Right"    ? position.top_right    :
     i_panelPos == "Top Left"     ? position.top_left     :
     i_panelPos == "Bottom Right" ? position.bottom_right :
     position.bottom_left

if i_showPanel and barstate.islast
    if na(statusTbl)
        statusTbl := table.new(panelPos, 2, 6,
             bgcolor      = color.new(#1a1a2e, 15),
             border_color = color.new(color.gray, 65),
             border_width = 1,
             frame_color  = color.new(color.gray, 50),
             frame_width  = 1)

    table.cell(statusTbl, 0, 0, "Judas Swing",
         text_color  = color.new(#29b6f6, 0),
         text_size   = size.small,
         bgcolor     = color.new(#0d0d1a, 0),
         text_halign = text.align_left)
    table.cell(statusTbl, 1, 0, syminfo.ticker + " \u00b7 " + timeframe.period,
         text_color  = color.new(color.gray, 30),
         text_size   = size.small,
         bgcolor     = color.new(#0d0d1a, 0),
         text_halign = text.align_right)

    string sessStat = inSession ? (irBuilding ? "Building IR" : "Monitoring") : "Closed"
    f_row(statusTbl, 1, "Session", sessStat, color.new(color.gray, 10))

    string htfStr = htfBias == 1 ? "\u25b2 Bullish" : htfBias == -1 ? "\u25bc Bearish" : "\u2014"
    color  htfCol = htfBias == 1 ? color.new(i_colBull, 0) : htfBias == -1 ? color.new(i_colBear, 0) : color.new(color.gray, 30)
    f_row(statusTbl, 2, "HTF Bias", htfStr, htfCol)

    color lastCol = lastSignalDir == "\u25b2 Bullish" ? color.new(i_colBull, 0) : lastSignalDir == "\u25bc Bearish" ? color.new(i_colBear, 0) : color.new(color.gray, 30)
    string lastTxt = na(lastSignalScore) ? "\u2014" : lastSignalDir + " (" + str.tostring(lastSignalScore) + ")"
    f_row(statusTbl, 3, "Last Signal", lastTxt, lastCol)

    f_row(statusTbl, 4, "Total Signals", str.tostring(totalSignals), color.new(color.gray, 20))

    string irStr = na(irHigh) or na(irLow) ? "\u2014" : str.tostring(math.round(irLow, 5)) + " - " + str.tostring(math.round(irHigh, 5))
    f_row(statusTbl, 5, "IR Range", irStr, color.new(color.gray, 20))

// ──────────────────────────────────────────────────────────────────
// SECTION 10 — ALERTS
// alert() delivers dynamic, score-aware messages; alertcondition()
// keeps every event individually selectable in the Add Alert dialog.
// ──────────────────────────────────────────────────────────────────

if sessionStartEvent and i_alertSession
    alert("Judas Swing \u2014 " + syminfo.ticker + " " + timeframe.period +
         ": " + i_sessionChoice + " session started. Initial Range is now building.",
         alert.freq_once_per_bar_close)

if (sweepEventBull or sweepEventBear) and i_alertSweep
    alert("Judas Swing \u2014 " + syminfo.ticker + " " + timeframe.period +
         ": " + alertSweepDir + " liquidity sweep detected at " + str.tostring(alertSweepPx, format.mintick) +
         ". Price closed back inside the Initial Range — watching for structure confirmation.",
         alert.freq_once_per_bar_close)

if bullJudasEvent and i_alertBullJudas
    alert("Judas Swing \u2014 " + syminfo.ticker + " " + timeframe.period +
         ": Bullish Judas Swing confirmed. Confidence score " + str.tostring(alertScore) + "/100. " +
         "Sweep, rejection, structure shift, displacement and HTF bias all aligned bullish.",
         alert.freq_once_per_bar_close)

if bearJudasEvent and i_alertBearJudas
    alert("Judas Swing \u2014 " + syminfo.ticker + " " + timeframe.period +
         ": Bearish Judas Swing confirmed. Confidence score " + str.tostring(alertScore) + "/100. " +
         "Sweep, rejection, structure shift, displacement and HTF bias all aligned bearish.",
         alert.freq_once_per_bar_close)

if highConfEvent and i_alertHighConf
    alert("Judas Swing \u2014 " + syminfo.ticker + " " + timeframe.period +
         ": High-Confidence " + alertScoreDir + " Judas Swing. Score " + str.tostring(alertScore) +
         "/100 — an elite-grade setup by the Judas Confidence Filter\u2122.",
         alert.freq_once_per_bar_close)

if htfChangeEvent and i_alertHtfChange
    alert("Judas Swing  \u2014 " + syminfo.ticker + " " + timeframe.period +
         ": Higher-timeframe (" + i_htf + ") bias flipped " + alertHtfDir + ".",
         alert.freq_once_per_bar_close)

if (entryZoneBullEvt or entryZoneBearEvt) and i_alertEntryZone
    alert("Judas Swing \u2014 " + syminfo.ticker + " " + timeframe.period +
         ": Price has reached the " + (entryZoneBullEvt ? "bullish" : "bearish") +
         " Judas Swing entry zone (50%-62% retracement).",
         alert.freq_once_per_bar_close)

alertcondition(sessionStartEvent, title = "Session Started",
     message = "Judas Swing  \u2014 {{ticker}} {{interval}}: Session started, Initial Range building.")

alertcondition(sweepEventBull or sweepEventBear, title = "Liquidity Sweep",
     message = "Judas Swing  \u2014 {{ticker}} {{interval}}: Liquidity sweep of the Initial Range detected.")

alertcondition(bullJudasEvent, title = "Bullish Judas Swing",
     message = "Judas Swing  \u2014 {{ticker}} {{interval}}: Bullish Judas Swing confirmed.")

alertcondition(bearJudasEvent, title = "Bearish Judas Swing",
     message = "Judas Swing \u2014 {{ticker}} {{interval}}: Bearish Judas Swing confirmed.")

alertcondition(highConfEvent, title = "High-Confidence Judas Swing",
     message = "Judas Swing  \u2014 {{ticker}} {{interval}}: High-Confidence Judas Swing (Elite grade).")

alertcondition(htfChangeEvent, title = "HTF Bias Change",
     message = "Judas Swing \u2014 {{ticker}} {{interval}}: Higher-timeframe bias has changed.")

alertcondition(entryZoneBullEvt or entryZoneBearEvt, title = "Entry Zone Reached",
     message = "Judas Swing \u2014 {{ticker}} {{interval}}: Price has reached the Judas Swing entry zone.")

// ── End of Script ─────────────────────────────────────────────────
````

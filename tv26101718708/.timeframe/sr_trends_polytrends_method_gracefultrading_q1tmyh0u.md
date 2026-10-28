# S&R + Trends | Polytrends Method (gracefultrading)

- url: https://www.tradingview.com/script/Q1TMYH0U-S-R-Trends-Polytrends-Method-gracefultrading/
- type: indicator
- pine_id: PUB;75cd937ea0674b9bb9bd160fff5b78e3
- version: 6.0

## Description

[b]SUPPORT & RESISTANCE + TRENDS | POLYTRENDS METHOD
[/b]

Maps market structure automatically: every trend is detected, classified, and turned into support/resistance levels that know their own state. Built around the polytrends method of reading structure through trends and progression. This is my own independent, open-source interpretation of the framework, coded from scratch based on publicly available material. For educational purposes only — not financial advice.

[b]TRENDS AND CONTAINMENT[/b]

Every pivot is compared against the previous pivot in the same direction. A swing that pushes past the prior trend is a valid continuation and draws in the trend colour. A swing that fails to exceed it — a lower high on the way up and or a lower low on the way down — is a containment trend, drawn in its own colour and style.

The current in-progress leg draws dashed, so you always see the swing being built. Pivot detection reacts to wick pullbacks, close-breaks of the prior candle, structural breaks, and same-bar reversals — not fixed-length lookbacks.

[b]LEVELS WITH STATE[/b]

Each trend leaves a level at the candle body, committed only after the next opposite pivot confirms it. Every label shows the level's current state at a glance:

G — gained
SG — support gained
L — lost
RL — resistance lost

State updates bar by bar as price closes through or reclaims a level. An optional break/test offset (in ticks or percent) means a level only counts as gained, lost, or tested once price clears it by your buffer.

[b]PAIRED STRUCTURE[/b]

Levels come from trends and draws in colour-matched pairs from a 12-colour set, each pair originating from the same piece of structure. 

Tested levels draw in a different line style from untested ones and can be hidden entirely; when hidden, you choose whether each pair still shows its tested partner so pairs stay intact. At high relevance settings, clustered tested levels within a tick distance thin down to the strongest one.

[b]POLYBOUNDS[/b]

Experimental.

A corner readout that reduces the chart to the two prices that matter:

▲ hold above — the key gained level below price. Bulls are in control while price holds above it.
▼ hold below — the key lost level above price. Bears are in control while price holds below it.
Each line is coloured to match its pair on the chart, and the box only quotes levels that are actually drawn. A Trend Day row (1H and below) reads whether the session is shaping up bullish, bearish, or rangebound based on where price sits against the bounds.

[b]SETTINGS[/b]

Levels above/below counts. A relevance dial controlling how deep into history levels are pulled from (50 bars to full history). Independent colours, styles, and widths for trends, containment trends, and levels. Configurable label background and twelve pair colours. A right-offset so all level rays align cleanly ahead of price.

[b]HOW TO READ IT
[/b]

The market is always in progression — always attempting either a new high or a new low. Every swing this indicator draws is one attempt in that sequence, and every level is the footprint it leaves behind.

Progression rule: in an uptrend, price should not lose the previous swing low if it intends to go higher — losing it shifts probability toward the opposite objective. Mirror logic in a downtrend. Watch the level states: a support flipping from SG to L is that shift happening in real time.
Containment is the early warning. A containment trend (lower high in an uptrend, higher low in a downtrend) means the progression is failing before any level has broken. Trend weakness is the warning; level failure is the confirmation.

Levels mark accepted value. They're built from candle bodies, not wicks — the goal is to see where the market accepted or rejected value, which is why the break/test offset exists to filter wick noise.

Untested levels react first. Fresh levels are the highest-priority reaction zones; tested levels remain valid structure and become targets when price is nearer to them. The pair colours show you which structure each level came from.

Timeframes nest. Higher-timeframe levels are destinations; lower-timeframe levels are the navigation between them. Significant trends typically start from higher-timeframe pivots — the biggest swings on your chart usually trace back to them. RTH-formed levels tend to carry the most weight.

Works on any symbol and timeframe; the Trend Day readout is built for intraday. This is a tool for reading structure, not a signal service — nothing replaces risk management.

## Source Code

````pine
//@version=6
indicator("Graceful Trading Polytrends", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_polylines_count=50)

// ═════════════════════════════════════════════════════════════════════════════
//  CHANGELOG
// ═════════════════════════════════════════════════════════════════════════════
//  0. HISTORICAL-BUFFER RUNTIME ERROR FIXED — drawings anchored to old
//     pivots (bands/rays/markers) need the `time` series history to place
//     their x-coordinates; Pine's automatic buffer (~400 bars) was too
//     small, throwing "requested historical offset beyond the buffer's
//     limit" in replay. The buffer is now reserved explicitly (5,000 bars)
//     and every drawing anchor is capped at 4,500 bars back.
//  1. ZIGZAG NEVER SKIPS A LEG (from v19) — every appended leg draws,
//     including same-candle legs on a genuine new extreme; leg handle can
//     never go stale (no low-to-low corruption).
// ─────────────────────────────────────────────────────────────────────────────
//  1. CONTAINMENT OFF: LEVELS FOLLOW THE ZIGZAG NODES (major) — the
//     containment-free view now derives levels, pairs, bands, AND tested
//     selection from the exact node map of the drawn zigzag. A swing that
//     was absorbed (containment, or a valid extreme replaced by a bigger
//     one) has no level, no pair, no band — so a level can never appear
//     without a connector swing touching it, and one leg can never carry
//     two highlight bands. Absorbed TESTED levels can still be surfaced
//     via "Show Containment Tested Levels".
//  2. CONTAINMENT-OFF TREND WICK-TO-WICK (from v16) — the zigzag anchors
//     to true swing extremes; levels stay body-based; bands body-to-body.
// ─────────────────────────────────────────────────────────────────────────────
//  1. PAIRING MODEL REDEFINED (major) — a pair is now ONE swing high level
//     + the swing low level that FOLLOWS it (the leg down from that high).
//     Every level belongs to exactly ONE pair: highs look forward to their
//     next low, lows look back to their high. This removes the previous
//     overlap where each level sat in two neighboring pairs ("2 pairs per
//     trend"). Pair color is keyed by the high member so both members and
//     the band always share one color. Bands follow the pair's own leg in
//     either time direction.
//  2. TESTED LEVELS AS COMPLETE PAIRS (from v14) — tested levels plot in
//     pair color, dotted, with partner + band; selection unchanged.
//  3. PAIRS ALWAYS COMPLETE (from v13) — de-dup per LEVEL, never per pair.
//  NOTE: trend drawing is untouched since v12.
// ─────────────────────────────────────────────────────────────────────────────
//  1. CONTAINMENT-OFF TREND IS BODY-TO-BODY — with containment trends off,
//     the bridged zigzag (and its in-progress preview) now anchors to the
//     pivot candles' BODY levels instead of wick extremes, so the trend
//     line, the pair levels, and the highlight bands all sit on the same
//     prices. Containment ON keeps the original wick-to-wick structure.
//  2. SIMPLER TESTED-LEVEL MODEL (one rule, any mode):
//       • "Show Tested Levels"            — master on/off for standalone
//         tested levels (counts + spacing below).
//       • "Show Containment Tested Levels" — whether tested levels born
//         from CONTAINMENT swings join that selection. Works the same
//         whether containment trends are shown or not.
//       • "Show Tested Pair Levels"       — PAIRS ONLY: show/hide the
//         tested companion of a displayed pair. Independent of the two
//         above.
//  3. (from v10) Pairs with containment off use the nearest preceding
//     valid level of the OPPOSITE type — bands never run high-to-high.
//     In-progress leg hidden until a real new extreme is made.
//  2. TESTED × CONTAINMENT RULE — with containment off and tested levels
//     on, only tested levels from non-containment swings show. A new
//     "Show Containment Tested Levels" toggle overrides this and lets
//     containment tested levels into the tested selection anyway.
//  3. (from v8) BRIGHTER HIGHLIGHTS — bands and markers at 60% opacity,
//     one shared constant so they always match.
//  4. (from v8) MARKER SIZE IS AUTOMATIC — width/height inputs removed;
//     fixed small pill (1 bar wide, ~3% of ATR tall).
//  From v7: containment-free zigzag — with containment off, a valid higher
//  high RELOCATES the previous high node (absorbing the containment swing),
//  so the trend always alternates swing high → swing low through the true
//  extremes. No high-to-high lines.
//  NOTE: each pair band's color comes straight from that pair's color input
//  in the Pair Colors section — adjust "Pair N Color" and the band follows.
//  Carried forward: tested levels alongside pairs with spacing, wick source
//  marked not recommended, relevance 1–3, HTF lookahead fix, alerts.
// ═════════════════════════════════════════════════════════════════════════════
//  DEFINITION: CONTAINMENT TREND
// ═════════════════════════════════════════════════════════════════════════════
//  • Swing HIGH: VALID runHigh > prevHigh · CONTAINMENT runHigh <= prevHigh
//  • Swing LOW:  VALID runLow < prevLow   · CONTAINMENT runLow >= prevLow
//
// Containment is direction-relative: a containment HIGH (lower high) is
// bearish structure; a containment LOW (higher low) is bullish structure.
//
// prevHigh / prevLow update on EVERY pivot. All levels (valid + containment)
// live in one unified pool; the containment toggle only affects trend lines.
// ═════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────
//  INPUTS — TARGET TIMEFRAME
// ─────────────────────────────────────────────
targetTF = input.string("Chart", "Target Timeframe", options=["Chart", "1m", "5m", "15m", "30m", "1hr", "4hr", "Daily", "Weekly", "Monthly"], group="Target Timeframe",
             tooltip="Select a higher timeframe to plot its swing levels/trends on the current chart. Only works when the chart timeframe is lower than the target. Use 'Chart' to analyze the current timeframe directly.")

// ─────────────────────────────────────────────
//  INPUTS — TRENDS
// ─────────────────────────────────────────────
showTrend  = input.bool(true, "Display Trend", group="Trends")
trendCol   = input.color(color.new(#2979FF, 20), "Trend Color", group="Trends")
trendStyle = input.string("Solid", "Trend Style", options=["Solid","Dashed","Dotted"], group="Trends")
trendWidth = input.int(1, "Trend Width", minval=1, maxval=4, group="Trends")

// ─────────────────────────────────────────────
//  INPUTS — CONTAINMENT TRENDS
// ─────────────────────────────────────────────
showContainment = input.bool(true, "Enable Containment Trends", group="Containment Trends",
                tooltip="ON: full structure view — every pivot drawn, containment legs in their own style. OFF: containment swings are absorbed into a clean alternating zigzag — a higher high relocates the previous high node instead of drawing extra legs.")
containmentCol   = input.color(color.new(#FF8F00, 0), "Containment Trend Color", group="Containment Trends")
containmentStyle = input.string("Dotted", "Containment Trend Style", options=["Solid","Dashed","Dotted"], group="Containment Trends")
containmentWidth = input.int(1, "Containment Trend Width", minval=1, maxval=4, group="Containment Trends")

// ─────────────────────────────────────────────
//  INPUTS — LEVELS
// ─────────────────────────────────────────────
enableLevels = input.bool(true,  "Enable Levels",      group="Levels")
levelSrc     = input.string("Body", "Level Source", options=["Body", "Wick (not recommended)"], group="Levels",
                tooltip="Body = levels at the pivot candle's body edge — the intended design. Wick = identical engine and states, but levels sit at the wick extremes instead. NOT RECOMMENDED: wick extremes are noisier and produce weaker, less respected levels; provided for comparison only.")
showLabels   = input.bool(true,  "Show Labels",        group="Levels")
showLvlMarks = input.bool(true,  "Level Origin Markers", group="Levels",
                tooltip="Draw a small rectangle on the level at the pivot that created it, matching the level's color and the pair-band transparency. Sized automatically.")
showLvlHl    = input.bool(true,  "Highlight Levels", group="Levels",
                tooltip="Overlay a thin translucent band along each displayed level ray, in the level's color. Same transparency as the pair trend bands so everything reads in harmony. The normal level line still draws underneath.")
showTested   = input.bool(false, "Show Tested Levels", group="Levels",
                tooltip="Draw standalone tested levels ALONGSIDE the pair levels (never replacing them, never as pairs). Counts and spacing below.")
testedAbove  = input.int(2, "Tested Levels Above", minval=0, maxval=5, group="Levels")
testedBelow  = input.int(2, "Tested Levels Below", minval=0, maxval=5, group="Levels")
testedMinTicks = input.int(20, "Tested Level Separation (ticks)", minval=1, maxval=500, group="Levels",
                tooltip="Minimum spacing between displayed tested levels. When several tested levels cluster inside this distance, only the one created by the largest connector swing is shown.")
showConTested = input.bool(false, "Show Containment Tested Levels", group="Levels",
                tooltip="Include tested levels that came from CONTAINMENT swings in the tested-level selection. One rule, any mode: works the same whether containment trends are shown or not. Off = only tested levels from regular (valid) trends are selected.")
showTestedPairs = input.bool(true, "Show Tested Pair Levels", group="Levels",
                tooltip="PAIRS ONLY: show or hide the tested companion of each displayed pair level. Independent of the standalone tested-level selection controlled by 'Show Tested Levels' / 'Show Containment Tested Levels'.")
levelsAbove  = input.int(4,  "Levels Above", minval=1, maxval=10, group="Levels")
levelsBelow  = input.int(4,  "Levels Below", minval=1, maxval=10, group="Levels")
relevance    = input.int(2,  "Relevance",    minval=1, maxval=3,  group="Levels",
                tooltip="Chart history used for connector-swing levels. 1 = Near (last 50 bars); 2 = Middle (last 600 bars); 3 = Distant (full history). Levels Above/Below controls the displayed count.")
levelWidth   = input.int(1,  "Level Width",  minval=1, maxval=4,   group="Levels")
untestedSty  = input.string("Solid",  "Untested Style", options=["Solid","Dashed","Dotted"], group="Levels")
testedSty    = input.string("Dotted", "Tested Style",   options=["Solid","Dashed","Dotted"], group="Levels")
useTestOffset = input.bool(true, "Use Break/Test Offset", group="Levels",
                tooltip="Require price to clear a level by the selected buffer before it can become gained, lost, or tested.")
testOffsetMode = input.string("Ticks", "Break/Test Offset Type", options=["Ticks", "Percent"], group="Levels")
testOffsetTicks = input.int(1, "Break/Test Offset (ticks)", minval=0, maxval=1000, group="Levels")
testOffsetPercent = input.float(0.01, "Break/Test Offset (%)", minval=0.0, maxval=10.0, step=0.01, group="Levels")
labelBgCol = input.color(color.new(#1a1a1a, 0), "Label Background", group="Levels")

// ─────────────────────────────────────────────
//  INPUTS — PAIR COLORS
// ─────────────────────────────────────────────
showPairBands = input.bool(true, "Highlight Pair Trends", group="Pair Colors",
                tooltip="Draw a translucent band along each displayed pair's connector swing, body level to body level, in the pair's color (60% opacity — same as the origin markers). Adjust any 'Pair N Color' below and its band follows.")
pairCol0  = input.color(color.new(#E91E63, 0), "Pair 0 Color",  group="Pair Colors")
pairCol1  = input.color(color.new(#FF8F00, 0), "Pair 1 Color",  group="Pair Colors")
pairCol2  = input.color(color.new(#8E24AA, 0), "Pair 2 Color",  group="Pair Colors")
pairCol3  = input.color(color.new(#0288D1, 0), "Pair 3 Color",  group="Pair Colors")
pairCol4  = input.color(color.new(#E64A19, 0), "Pair 4 Color",  group="Pair Colors")
pairCol5  = input.color(color.new(#388E3C, 0), "Pair 5 Color",  group="Pair Colors")
pairCol6  = input.color(color.new(#5E35B1, 0), "Pair 6 Color",  group="Pair Colors")
pairCol7  = input.color(color.new(#C2185B, 0), "Pair 7 Color",  group="Pair Colors")
pairCol8  = input.color(color.new(#00796B, 0), "Pair 8 Color",  group="Pair Colors")
pairCol9  = input.color(color.new(#F57F17, 0), "Pair 9 Color",  group="Pair Colors")
pairCol10 = input.color(color.new(#3949AB, 0), "Pair 10 Color", group="Pair Colors")
pairCol11 = input.color(color.new(#6D4C41, 0), "Pair 11 Color", group="Pair Colors")

// Shared transparency for pair bands AND origin markers (60% opacity).
// One constant so the two can never drift apart visually.
int HL_TRANSP = 40

// ─────────────────────────────────────────────
//  INPUTS — POLYBOUNDS
// ─────────────────────────────────────────────
enablePolyBounds = input.bool(true, "Enable PolyBounds", group="PolyBounds")

// ─────────────────────────────────────────────
//  TIMEFRAME RESOLUTION
// ─────────────────────────────────────────────
f_tfString(string tfName) =>
    switch tfName
        "1m"      => "1"
        "5m"      => "5"
        "15m"     => "15"
        "30m"     => "30"
        "1hr"     => "60"
        "4hr"     => "240"
        "Daily"      => "1D"
        "Weekly"   => "1W"
        "Monthly"  => "1M"
        => timeframe.period

string resolvedTF = f_tfString(targetTF)
bool useHTF = targetTF != "Chart"
float chartTFSeconds = timeframe.in_seconds()
float targetTFSeconds = timeframe.in_seconds(resolvedTF)
bool tfValid = not useHTF or chartTFSeconds < targetTFSeconds

// ─────────────────────────────────────────────
//  HTF DATA REQUEST
// ─────────────────────────────────────────────
[reqO, reqH, reqL, reqC] = request.security(syminfo.tickerid, resolvedTF, [open, high, low, close], lookahead=barmerge.lookahead_on)

bool htfActive = useHTF and tfValid
bool newHTFBar = htfActive ? (timeframe.change(resolvedTF) or barstate.isfirst) : true

// CONFIRMED ANALYSIS CANDLE: in HTF mode the engine consumes the just-CLOSED
// HTF candle ([1] of the lookahead series), never the still-forming one.
float swO = htfActive ? reqO[1] : open
float swH = htfActive ? reqH[1] : high
float swL = htfActive ? reqL[1] : low
float swC = htfActive ? reqC[1] : close

// Developing candle — DISPLAY ONLY (PolyBounds "Pot. Reversing" live tier).
float liveH = htfActive ? reqH : high
float liveL = htfActive ? reqL : low

bool useWickLevels = levelSrc != "Body"

// Chart ATR — used only to size the rectangular level markers.
float mkAtr = ta.atr(14)

// Reserve a deep history buffer for the `time` series: drawings anchored by
// bar index (bands, rays, markers) convert index → time internally, and the
// automatic buffer (~400 bars) is too small for old pivots. All drawing
// anchors are additionally capped at 4,500 bars back.
max_bars_back(time, 5000)

// ─────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────
getStyle(string s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_levelLookback(int r) =>
    switch r
        1 => 50
        2 => 600
        => 999999

f_rayHistoryBars(int r) =>
    switch r
        1 => 100
        2 => 1000
        => 9999

f_testOffset(float p) =>
    if not useTestOffset
        0.0
    else if testOffsetMode == "Percent"
        p * testOffsetPercent / 100.0
    else
        testOffsetTicks * syminfo.mintick

getStateCol(string st) =>
    switch st
        "G"  => color.new(#26C6DA, 0)
        "SG" => color.new(#00FF00, 0)
        "L"  => color.new(#FF0000, 0)
        "RL" => color.new(#EF5350, 0)
        => color.new(#888888, 0)

f_pairColor(int pairId) =>
    switch pairId % 12
        0  => pairCol0
        1  => pairCol1
        2  => pairCol2
        3  => pairCol3
        4  => pairCol4
        5  => pairCol5
        6  => pairCol6
        7  => pairCol7
        8  => pairCol8
        9  => pairCol9
        10 => pairCol10
        => pairCol11

f_levelState(bool isH, bool ca, float p, float c) =>
    st = "R"
    if isH
        st := ca ? (c > p ? "G" : "RL") : "R"
    else
        st := ca ? (c < p ? "L" : "G") : "SG"
    st

rayGap = input.int(10, "Level Right Offset (bars)", minval=0, maxval=100, group="Levels",
          tooltip="All level rays align to this many bars right of the current bar")

drawRay(int b, float p, color c, string sty, string st) =>
    historyStart = bar_index - math.min(f_rayHistoryBars(relevance), 4500)
    safeB  = math.max(b, historyStart)
    rightB = bar_index + rayGap
    ln = line.new(safeB, p, rightB, p, xloc=xloc.bar_index, color=c, style=getStyle(sty), width=levelWidth)
    label lbl = na
    if showLabels
        txt = str.tostring(p, format.mintick) + " " + st
        lbl := label.new(rightB, p, text=txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=labelBgCol, textcolor=c, size=size.small)
    // rectangular origin marker — same transparency as the pair bands
    box mk = na
    if showLvlMarks and not na(mkAtr)
        mh = mkAtr * 0.015   // fixed small pill: ~3% of ATR tall, 1 bar wide
        mkCol = color.new(c, HL_TRANSP)
        mk := box.new(safeB, p + mh, safeB + 1, p - mh, xloc=xloc.bar_index, border_color=mkCol, border_width=1, bgcolor=mkCol)
    // level highlight — thin translucent band over the whole ray, same
    // color and transparency; the level line itself still draws underneath
    box hb = na
    if showLvlHl and not na(mkAtr)
        hh = mkAtr * 0.005   // thin: ~1% of ATR total height
        hb := box.new(safeB, p + hh, rightB, p - hh, xloc=xloc.bar_index, border_color=color.new(c, 100), border_width=1, bgcolor=color.new(c, HL_TRANSP))
    [ln, lbl, mk, hb]

// ─────────────────────────────────────────────
//  STATE
// ─────────────────────────────────────────────
var int   dir               = 0
var float runHigh           = na
var int   runHBar           = na
var float runHO             = na
var float runHC             = na
var float runLow            = na
var int   runLBar           = na
var float runLO             = na
var float runLC             = na
var float prevWick          = na
var int   prevBar           = na

var float prevHigh          = na
var float prevLow           = na

var int   lastHighType      = 0
var int   lastLowType       = 0

var int   regime            = 0
var bool  regimeConfirmed   = false

var line  ipLine            = na

// CONTAINMENT-FREE ZIGZAG (containment OFF display):
//   zzType: 1 = last node is a swing high, -1 = swing low, 0 = none yet
//   A valid pivot of the OPPOSITE type appends a new node (draws a leg).
//   A valid pivot of the SAME type that is MORE EXTREME relocates the last
//   node (moves the last leg's endpoint) — absorbing the containment swing
//   between them. Containment pivots never create or move nodes.
var int   zzType            = 0
var int   zzBar             = na
var float zzPrice           = na
var line  zzLine            = na

// Previous PROCESSED analysis candle (replaces swH[1]/swL[1], which break
// in HTF mode where adjacent chart bars repeat the same HTF candle)
var float swHPrev           = na
var float swLPrev           = na
var bool  engineInit        = false

// PENDING LEVEL: only committed when next opposite pivot confirms it
var float pendingP    = na
var int   pendingB    = na
var bool  pendingIsH  = false
var bool  pendingHas  = false
var float pendingStr  = na
var bool  pendingIsCon = false
var float pendingWickP = na   // pivot wick extreme — drives the node map

// UNIFIED LEVELS
var float[] lvlP              = array.new<float>()
var int[]   lvlB              = array.new<int>()
var bool[]  lvlT              = array.new<bool>()
var bool[]  lvlIsH            = array.new<bool>()
var bool[]  lvlClosedAbove    = array.new<bool>()
var float[] lvlStrength       = array.new<float>()
var bool[]  lvlTouched        = array.new<bool>()    // internal — powers the SG First Touch alert
var bool[]  lvlIsCon          = array.new<bool>()    // level came from a containment swing
var float[] lvlWickP          = array.new<float>()   // pivot wick extreme (node-map comparisons)
var int     lvlScanStart      = 0
var line[]  dLines            = array.new<line>()
var label[] dLabels           = array.new<label>()
var box[]   dBoxes            = array.new<box>()
var polyline[] dPolys         = array.new<polyline>()

// PolyBounds state
var table polyBoundsTable     = na
var float[] pbPrices = array.new<float>()
var string[] pbStates = array.new<string>()
var color[] pbColors = array.new<color>()
var bool[] pbIsAbove = array.new<bool>()

// per-bar alert flags
bool levelCommitted = false
bool sgFirstTouch   = false
bool supportLost    = false

// ─────────────────────────────────────────────
//  PAIR RESOLUTION
//  A pair = ONE swing high level + the swing low level that FOLLOWS it.
//  Highs look FORWARD to the next low; lows look BACK to their high.
//  Every level belongs to exactly one pair. When useNodes is true
//  (containment trends off), only NODE levels of the containment-free
//  zigzag qualify as partners — pairs mirror the drawn trend exactly.
// ─────────────────────────────────────────────
f_pairPartner(int idx, array<bool> nodes, bool useNodes) =>
    int result = -1
    int total = array.size(lvlP)
    if idx >= 0 and idx < total
        if array.get(lvlIsH, idx)
            int j = idx + 1
            while j < total
                bool okJ = not useNodes or array.get(nodes, j)
                if okJ and not array.get(lvlIsH, j)
                    result := j
                    break
                j += 1
        else
            int j = idx - 1
            while j >= 0
                bool okJ = not useNodes or array.get(nodes, j)
                if okJ and array.get(lvlIsH, j)
                    result := j
                    break
                j -= 1
    result

// ─────────────────────────────────────────────
//  INIT — first bar with usable analysis data
// ─────────────────────────────────────────────
bool initBar = false
if not engineInit and not na(swO) and not na(swH) and not na(swL) and not na(swC)
    engineInit := true
    initBar := true
    dir     := swC > swO ? 1 : -1
    runHigh := swH
    runHBar := bar_index
    runHO   := swO
    runHC   := swC
    runLow  := swL
    runLBar := bar_index
    runLO   := swO
    runLC   := swC

// ─────────────────────────────────────────────
//  HARD-CLOSE BREAK DETECTION
// ─────────────────────────────────────────────
if tfValid and engineInit
    bool barJustClosed = useHTF ? (newHTFBar and not initBar) : barstate.isconfirmed
    float confClose    = swC
    if barJustClosed
        if not na(prevHigh) and confClose > prevHigh
            if regime != 1
                regime          := 1
                regimeConfirmed := lastHighType == 1 and lastLowType == 1
        else if not na(prevLow) and confClose < prevLow
            if regime != -1
                regime          := -1
                regimeConfirmed := lastHighType == -1 and lastLowType == -1

// ─────────────────────────────────────────────
//  SWING DETECTION — levels committed only after next opposite pivot
// ─────────────────────────────────────────────
if tfValid and (not useHTF or newHTFBar) and engineInit
    if not initBar
        if dir == 1
            if swH > runHigh
                runHigh := swH
                runHBar := bar_index
                runHO   := swO
                runHC   := swC

            if swL < runLow
                runLow  := swL
                runLBar := bar_index
                runLO   := swO
                runLC   := swC

            bodyTop = math.max(runHO, runHC)
            wickPullback = swH < swHPrev
            closeBreakDown = swC < swLPrev
            structuralBreak = swL < prevLow and not na(prevLow)
            sameBarReversal = swC < swO and swH == runHigh and bar_index == runHBar and swC < bodyTop

            if (wickPullback or closeBreakDown or structuralBreak or sameBarReversal) and bar_index >= runHBar
                isContainment = not na(prevHigh) and runHigh <= prevHigh
                swingStrength = na(prevWick) ? 0.0 : math.abs(runHigh - prevWick)

                // TREND DRAWING
                if showContainment
                    if not na(prevBar) and prevBar < bar_index and showTrend
                        if isContainment
                            line.new(prevBar, prevWick, runHBar, runHigh, xloc=xloc.bar_index, color=containmentCol, style=getStyle(containmentStyle), width=containmentWidth)
                        else
                            line.new(prevBar, prevWick, runHBar, runHigh, xloc=xloc.bar_index, color=trendCol, style=getStyle(trendStyle), width=trendWidth)
                else if not isContainment
                    // containment-free zigzag — WICK to WICK (true swing
                    // extremes). Levels stay body-based independently.
                    if zzType == 1
                        if runHigh > zzPrice
                            if not na(zzLine)
                                line.set_xy2(zzLine, runHBar, runHigh)
                            zzBar   := runHBar
                            zzPrice := runHigh
                    else
                        if zzType == -1 and showTrend and zzBar <= runHBar
                            // same-candle legs allowed: the pivot made a real
                            // new extreme, so the leg draws even within one bar
                            zzLine := line.new(zzBar, zzPrice, runHBar, runHigh, xloc=xloc.bar_index, color=trendCol, style=getStyle(trendStyle), width=trendWidth)
                        else
                            // only the chart's first node has nothing to draw;
                            // clearing the handle keeps relocations honest
                            zzLine := na
                        zzType  := 1
                        zzBar   := runHBar
                        zzPrice := runHigh

                if pendingHas
                    array.push(lvlP,           pendingP)
                    array.push(lvlB,           pendingB)
                    array.push(lvlT,           false)
                    array.push(lvlIsH,         pendingIsH)
                    array.push(lvlClosedAbove, false)
                    array.push(lvlStrength,    pendingStr)
                    array.push(lvlTouched,     false)
                    array.push(lvlIsCon,       pendingIsCon)
                    array.push(lvlWickP,       pendingWickP)
                    levelCommitted := true
                    pendingP   := na
                    pendingB   := na
                    pendingIsH := false
                    pendingHas := false
                    pendingStr := na
                    pendingIsCon := false
                    pendingWickP := na

                pendingP   := useWickLevels ? runHigh : bodyTop
                pendingB   := runHBar
                pendingIsH := true
                pendingHas := true
                pendingStr := swingStrength
                pendingIsCon := isContainment
                pendingWickP := runHigh

                lastHighType := isContainment ? -1 : 1
                prevHigh     := runHigh
                prevWick     := runHigh
                prevBar      := runHBar
                dir          := -1
                runLow       := swL
                runLBar      := bar_index
                runLO       := swO
                runLC       := swC
        else
            if swL < runLow
                runLow  := swL
                runLBar := bar_index
                runLO   := swO
                runLC   := swC

            if swH > runHigh
                runHigh := swH
                runHBar := bar_index
                runHO   := swO
                runHC   := swC

            bodyBot = math.min(runLO, runLC)
            wickBounce = swL > swLPrev
            closeBreakUp = swC > swHPrev
            structuralBreakUp = swH > prevHigh and not na(prevHigh)
            sameBarReversalUp = swC > swO and swL == runLow and bar_index == runLBar and swC > bodyBot

            if (wickBounce or closeBreakUp or structuralBreakUp or sameBarReversalUp) and bar_index >= runLBar
                isContainment = not na(prevLow) and runLow >= prevLow
                swingStrength = na(prevWick) ? 0.0 : math.abs(prevWick - runLow)

                // TREND DRAWING
                if showContainment
                    if not na(prevBar) and prevBar < bar_index and showTrend
                        if isContainment
                            line.new(prevBar, prevWick, runLBar, runLow, xloc=xloc.bar_index, color=containmentCol, style=getStyle(containmentStyle), width=containmentWidth)
                        else
                            line.new(prevBar, prevWick, runLBar, runLow, xloc=xloc.bar_index, color=trendCol, style=getStyle(trendStyle), width=trendWidth)
                else if not isContainment
                    // containment-free zigzag — WICK to WICK (true swing
                    // extremes). Levels stay body-based independently.
                    if zzType == -1
                        if runLow < zzPrice
                            if not na(zzLine)
                                line.set_xy2(zzLine, runLBar, runLow)
                            zzBar   := runLBar
                            zzPrice := runLow
                    else
                        if zzType == 1 and showTrend and zzBar <= runLBar
                            // same-candle legs allowed: the pivot made a real
                            // new extreme, so the leg draws even within one bar
                            zzLine := line.new(zzBar, zzPrice, runLBar, runLow, xloc=xloc.bar_index, color=trendCol, style=getStyle(trendStyle), width=trendWidth)
                        else
                            // only the chart's first node has nothing to draw;
                            // clearing the handle keeps relocations honest
                            zzLine := na
                        zzType  := -1
                        zzBar   := runLBar
                        zzPrice := runLow

                if pendingHas
                    array.push(lvlP,           pendingP)
                    array.push(lvlB,           pendingB)
                    array.push(lvlT,           false)
                    array.push(lvlIsH,         pendingIsH)
                    array.push(lvlClosedAbove, false)
                    array.push(lvlStrength,    pendingStr)
                    array.push(lvlTouched,     false)
                    array.push(lvlIsCon,       pendingIsCon)
                    array.push(lvlWickP,       pendingWickP)
                    levelCommitted := true
                    pendingP   := na
                    pendingB   := na
                    pendingIsH := false
                    pendingHas := false
                    pendingStr := na
                    pendingIsCon := false
                    pendingWickP := na

                pendingP   := useWickLevels ? runLow : bodyBot
                pendingB   := runLBar
                pendingIsH := false
                pendingHas := true
                pendingStr := swingStrength
                pendingIsCon := isContainment
                pendingWickP := runLow

                lastLowType  := isContainment ? 1 : -1
                prevLow      := runLow
                prevWick     := runLow
                prevBar      := runLBar
                dir          := 1
                runHigh      := swH
                runHBar      := bar_index
                runHO        := swO
                runHC        := swC
    swHPrev := swH
    swLPrev := swL

if regime == 1 and lastHighType == 1 and lastLowType == 1
    regimeConfirmed := true
else if regime == -1 and lastHighType == -1 and lastLowType == -1
    regimeConfirmed := true

// ─────────────────────────────────────────────
//  IN-PROGRESS LEG — anchors to the last pivot (containment ON) or the
//  last zigzag node (containment OFF)
// ─────────────────────────────────────────────
int   ipBar   = showContainment ? prevBar : zzBar
float ipPrice = showContainment ? prevWick : zzPrice
// Containment OFF: only preview the in-progress leg once the developing
// move has actually made a NEW swing extreme — a lower low after a high
// node, or a higher high after a low node. A containment-sized move shows
// nothing, because it may never join the containment-free zigzag.
bool ipValidOff = zzType == 1 ? (not na(prevLow) and runLow < prevLow) : zzType == -1 ? (not na(prevHigh) and runHigh > prevHigh) : false
bool wantIp = tfValid and not na(ipBar) and not na(ipPrice) and ipBar < bar_index and showTrend and (showContainment or ipValidOff)
if wantIp
    tip = showContainment ? (dir == 1 ? runHigh : runLow) : (zzType == 1 ? runLow : runHigh)
    if na(ipLine)
        ipLine := line.new(ipBar, ipPrice, bar_index, tip, xloc=xloc.bar_index, color=trendCol, style=line.style_dashed, width=trendWidth)
    else
        line.set_xy1(ipLine, ipBar, ipPrice)
        line.set_xy2(ipLine, bar_index, tip)
else if not na(ipLine)
    line.delete(ipLine)
    ipLine := na

// ─────────────────────────────────────────────
//  TESTED + CLOSED-ABOVE TRACKING — UNIFIED LEVELS
// ─────────────────────────────────────────────
n = array.size(lvlP)
if n > 0 and (not useHTF or newHTFBar)
    cTop = math.max(swO, swC)
    cBot = math.min(swO, swC)
    for i = 0 to n - 1
        td  = array.get(lvlT, i)
        if td
            continue
        lb  = array.get(lvlB, i)
        if bar_index <= lb
            continue
        p   = array.get(lvlP,           i)
        isH = array.get(lvlIsH,         i)
        ca  = array.get(lvlClosedAbove, i)
        offset = f_testOffset(p)
        bool brokeAbove = isH and cTop > p + offset
        bool brokeBelow = not isH and cBot < p - offset
        if not ca
            if brokeAbove
                array.set(lvlClosedAbove, i, true)
            else if brokeBelow
                array.set(lvlClosedAbove, i, true)
                supportLost := true
        // SG first-touch alert (internal flag only — nothing is drawn)
        if not ca and not brokeAbove and not brokeBelow
            if not isH and not array.get(lvlTouched, i) and swL <= p
                array.set(lvlTouched, i, true)
                sgFirstTouch := true
        if not td
            if isH and ca and cBot < p - offset
                array.set(lvlT, i, true)
            else if not isH and ca and cTop > p + offset
                array.set(lvlT, i, true)

// ─────────────────────────────────────────────
//  POT. REVERSING FLAGS (global — feed PolyBounds AND alerts)
// ─────────────────────────────────────────────
bool potRevUp   = tfValid and not na(prevHigh) and liveH > prevHigh and regime != 1
bool potRevDown = tfValid and not na(prevLow)  and liveL < prevLow  and regime != -1
bool regimeFlip = not na(regime[1]) and regime != 0 and regime != regime[1]

// ─────────────────────────────────────────────
//  DRAW LEVELS — on barstate.islast
// ─────────────────────────────────────────────
if barstate.islast and enableLevels and tfValid
    for ln in dLines
        line.delete(ln)
    for lb in dLabels
        label.delete(lb)
    for bx in dBoxes
        box.delete(bx)
    for py in dPolys
        polyline.delete(py)
    array.clear(dLines)
    array.clear(dLabels)
    array.clear(dBoxes)
    array.clear(dPolys)
    array.clear(pbPrices)
    array.clear(pbStates)
    array.clear(pbColors)
    array.clear(pbIsAbove)

    cutoff = bar_index - f_levelLookback(relevance)
    curClose = close

    // ── COLLECT: untested pair candidates + tested candidates (separate) ──
    aP = array.new<float>()
    aB = array.new<int>()
    aH = array.new<bool>()
    aCA = array.new<bool>()
    aI = array.new<int>()
    bP = array.new<float>()
    bB = array.new<int>()
    bH = array.new<bool>()
    bCA = array.new<bool>()
    bI = array.new<int>()
    taP = array.new<float>()
    taB = array.new<int>()
    taH = array.new<bool>()
    taCA = array.new<bool>()
    taS = array.new<float>()
    taI = array.new<int>()
    tbP = array.new<float>()
    tbB = array.new<int>()
    tbH = array.new<bool>()
    tbCA = array.new<bool>()
    tbS = array.new<float>()
    tbI = array.new<int>()
    total = array.size(lvlP)
    while lvlScanStart < total and array.get(lvlB, lvlScanStart) < cutoff
        lvlScanStart += 1

    // ── CONTAINMENT-FREE NODE MAP (containment OFF) ──
    // Recreates the drawn zigzag over the level pool: valid pivots become
    // nodes; a same-type more-extreme pivot RELOCATES the node and demotes
    // the old one. Levels/pairs/bands/tested then follow NODES only, so a
    // level always sits on a drawn connector swing.
    nodeArr = array.new<bool>(total, false)
    if not showContainment and total > lvlScanStart
        int ndType = 0
        int ndIdx  = -1
        float ndExt = na
        for i = lvlScanStart to total - 1
            if array.get(lvlIsCon, i)
                continue
            bool ndH = array.get(lvlIsH, i)
            float ndW = array.get(lvlWickP, i)
            if ndType == 0 or (ndH ? ndType == -1 : ndType == 1)
                array.set(nodeArr, i, true)
                ndType := ndH ? 1 : -1
                ndIdx  := i
                ndExt  := ndW
            else if (ndH and ndW > ndExt) or (not ndH and ndW < ndExt)
                if ndIdx >= 0
                    array.set(nodeArr, ndIdx, false)
                array.set(nodeArr, i, true)
                ndIdx := i
                ndExt := ndW

    if total > lvlScanStart
        for i = lvlScanStart to total - 1
            // Visibility rules:
            //  • Containment ON — containment TESTED levels follow the
            //    "Show Containment Tested Levels" toggle; all else shows.
            //  • Containment OFF — only NODE levels of the containment-free
            //    zigzag show (containment swings and absorbed valid swings
            //    are both hidden), so levels always sit on a drawn trend.
            //    Absorbed TESTED levels re-enabled via the same toggle.
            if showContainment
                if array.get(lvlIsCon, i) and array.get(lvlT, i) and not showConTested
                    continue
            else
                if not array.get(nodeArr, i)
                    if not (showConTested and array.get(lvlT, i))
                        continue
            lb  = array.get(lvlB,           i)
            p   = array.get(lvlP,           i)
            td  = array.get(lvlT,           i)
            isH = array.get(lvlIsH,         i)
            ca  = array.get(lvlClosedAbove, i)
            strength = array.get(lvlStrength, i)
            goAbove = false
            if isH
                goAbove := p >= curClose
            else
                goAbove := ca and p >= curClose
            if td
                if goAbove
                    array.push(taP, p)
                    array.push(taB, lb)
                    array.push(taH, isH)
                    array.push(taCA, ca)
                    array.push(taS, strength)
                    array.push(taI, i)
                else
                    array.push(tbP, p)
                    array.push(tbB, lb)
                    array.push(tbH, isH)
                    array.push(tbCA, ca)
                    array.push(tbS, strength)
                    array.push(tbI, i)
            else
                if goAbove
                    array.push(aP, p)
                    array.push(aB, lb)
                    array.push(aH, isH)
                    array.push(aCA, ca)
                    array.push(aI, i)
                else
                    array.push(bP, p)
                    array.push(bB, lb)
                    array.push(bH, isH)
                    array.push(bCA, ca)
                    array.push(bI, i)

    // ── PAIR LEVELS (always drawn — tested never competes for these slots) ──
    nA = array.size(aP)
    drawnPairSources = array.new<int>()
    dA = 0
    for i = 0 to levelsAbove - 1
        if dA >= levelsAbove or nA == 0
            break
        minV = float(na)
        minI = -1
        for j = 0 to nA - 1
            pj = array.get(aP, j)
            if not na(pj) and (na(minV) or pj < minV)
                minV := pj
                minI := j
        if minI < 0
            break
        dp = array.get(aP, minI)
        db = array.get(aB, minI)
        dhH = array.get(aH, minI)
        dhCA = array.get(aCA, minI)
        sourceI = array.get(aI, minI)
        stA = f_levelState(dhH, dhCA, dp, curClose)
        array.set(aP, minI, na)

        companionI = f_pairPartner(sourceI, nodeArr, not showContainment)
        showCompanion = false
        if companionI >= 0
            companionIsTested = array.get(lvlT, companionI)
            showCompanion := showTestedPairs or not companionIsTested
        // v13: de-dup per LEVEL, never per pair — both members of a
        // displayed pair always plot; a shared level isn't drawn twice
        // but never suppresses its partner or the band.
        int pairKey = dhH ? sourceI : (companionI >= 0 ? companionI : sourceI)
        pairCol = f_pairColor(pairKey)
        if not array.includes(drawnPairSources, sourceI)
            [lnA, lbA, mkA, hbA] = drawRay(db, dp, pairCol, untestedSty, stA)
            array.push(dLines, lnA)
            if not na(lbA)
                array.push(dLabels, lbA)
            if not na(mkA)
                array.push(dBoxes, mkA)
            if not na(hbA)
                array.push(dBoxes, hbA)
            array.push(drawnPairSources, sourceI)
            array.push(pbPrices, dp)
            array.push(pbStates, stA)
            array.push(pbColors, pairCol)
            array.push(pbIsAbove, true)

        // PAIR TREND BAND — body to body along the pair's own leg
        if showPairBands and companionI >= 0
            float bandP = array.get(lvlP, companionI)
            int   bandB = array.get(lvlB, companionI)
            if not na(bandP) and bandB != db and bar_index - math.min(bandB, db) < 4500
                int   pbB1 = math.min(bandB, db)
                int   pbB2 = math.max(bandB, db)
                float pbP1 = bandB < db ? bandP : dp
                float pbP2 = bandB < db ? dp : bandP
                float dHalf = math.max(math.abs(dp - bandP) * 0.04, syminfo.mintick)
                bandCol = color.new(pairCol, HL_TRANSP)
                pts = array.from(chart.point.from_index(pbB1, pbP1 + dHalf), chart.point.from_index(pbB2, pbP2 + dHalf), chart.point.from_index(pbB2, pbP2 - dHalf), chart.point.from_index(pbB1, pbP1 - dHalf))
                array.push(dPolys, polyline.new(pts, closed=true, xloc=xloc.bar_index, line_color=bandCol, fill_color=bandCol, line_width=1))

        if showCompanion and not array.includes(drawnPairSources, companionI)
            companionP = array.get(lvlP, companionI)
            companionB = array.get(lvlB, companionI)
            companionH = array.get(lvlIsH, companionI)
            companionCA = array.get(lvlClosedAbove, companionI)
            companionSty = array.get(lvlT, companionI) ? testedSty : untestedSty
            companionSt = f_levelState(companionH, companionCA, companionP, curClose)
            [lnCompanion, lbCompanion, mkCompanion, hbCompanion] = drawRay(companionB, companionP, pairCol, companionSty, companionSt)
            array.push(dLines, lnCompanion)
            if not na(lbCompanion)
                array.push(dLabels, lbCompanion)
            if not na(mkCompanion)
                array.push(dBoxes, mkCompanion)
            if not na(hbCompanion)
                array.push(dBoxes, hbCompanion)
            array.push(drawnPairSources, companionI)
            array.push(pbPrices, companionP)
            array.push(pbStates, companionSt)
            array.push(pbColors, pairCol)
            array.push(pbIsAbove, companionP >= curClose)
        dA += 1

    nB = array.size(bP)
    dB = 0
    for i = 0 to levelsBelow - 1
        if dB >= levelsBelow or nB == 0
            break
        maxV = float(na)
        maxI = -1
        for j = 0 to nB - 1
            pj = array.get(bP, j)
            if not na(pj) and (na(maxV) or pj > maxV)
                maxV := pj
                maxI := j
        if maxI < 0
            break
        dp = array.get(bP, maxI)
        db = array.get(bB, maxI)
        dhH = array.get(bH, maxI)
        dhCA = array.get(bCA, maxI)
        sourceI = array.get(bI, maxI)
        stB = f_levelState(dhH, dhCA, dp, curClose)
        array.set(bP, maxI, na)

        companionI = f_pairPartner(sourceI, nodeArr, not showContainment)
        showCompanion = false
        if companionI >= 0
            companionIsTested = array.get(lvlT, companionI)
            showCompanion := showTestedPairs or not companionIsTested
        // v13: de-dup per LEVEL, never per pair — both members of a
        // displayed pair always plot; a shared level isn't drawn twice
        // but never suppresses its partner or the band.
        int pairKey = dhH ? sourceI : (companionI >= 0 ? companionI : sourceI)
        pairCol = f_pairColor(pairKey)
        if not array.includes(drawnPairSources, sourceI)
            [lnB, lbB, mkB, hbB] = drawRay(db, dp, pairCol, untestedSty, stB)
            array.push(dLines, lnB)
            if not na(lbB)
                array.push(dLabels, lbB)
            if not na(mkB)
                array.push(dBoxes, mkB)
            if not na(hbB)
                array.push(dBoxes, hbB)
            array.push(drawnPairSources, sourceI)
            array.push(pbPrices, dp)
            array.push(pbStates, stB)
            array.push(pbColors, pairCol)
            array.push(pbIsAbove, false)

        // PAIR TREND BAND — body to body along the pair's own leg
        if showPairBands and companionI >= 0
            float bandP = array.get(lvlP, companionI)
            int   bandB = array.get(lvlB, companionI)
            if not na(bandP) and bandB != db and bar_index - math.min(bandB, db) < 4500
                int   pbB1 = math.min(bandB, db)
                int   pbB2 = math.max(bandB, db)
                float pbP1 = bandB < db ? bandP : dp
                float pbP2 = bandB < db ? dp : bandP
                float dHalf = math.max(math.abs(dp - bandP) * 0.04, syminfo.mintick)
                bandCol = color.new(pairCol, HL_TRANSP)
                pts = array.from(chart.point.from_index(pbB1, pbP1 + dHalf), chart.point.from_index(pbB2, pbP2 + dHalf), chart.point.from_index(pbB2, pbP2 - dHalf), chart.point.from_index(pbB1, pbP1 - dHalf))
                array.push(dPolys, polyline.new(pts, closed=true, xloc=xloc.bar_index, line_color=bandCol, fill_color=bandCol, line_width=1))

        if showCompanion and not array.includes(drawnPairSources, companionI)
            companionP = array.get(lvlP, companionI)
            companionB = array.get(lvlB, companionI)
            companionH = array.get(lvlIsH, companionI)
            companionCA = array.get(lvlClosedAbove, companionI)
            companionSty = array.get(lvlT, companionI) ? testedSty : untestedSty
            companionSt = f_levelState(companionH, companionCA, companionP, curClose)
            [lnCompanion, lbCompanion, mkCompanion, hbCompanion] = drawRay(companionB, companionP, pairCol, companionSty, companionSt)
            array.push(dLines, lnCompanion)
            if not na(lbCompanion)
                array.push(dLabels, lbCompanion)
            if not na(mkCompanion)
                array.push(dBoxes, mkCompanion)
            if not na(hbCompanion)
                array.push(dBoxes, hbCompanion)
            array.push(drawnPairSources, companionI)
            array.push(pbPrices, companionP)
            array.push(pbStates, companionSt)
            array.push(pbColors, pairCol)
            array.push(pbIsAbove, companionP >= curClose)
        dB += 1

    // ── TESTED LEVELS — standalone, ALONGSIDE the pairs ──
    if showTested
        sep = testedMinTicks * syminfo.mintick

        nTA = array.size(taP)
        if nTA > 0 and testedAbove > 0
            usedA = array.new<bool>(nTA, false)
            dTA = 0
            while dTA < testedAbove
                minV = float(na)
                minI = -1
                for j = 0 to nTA - 1
                    if not array.get(usedA, j)
                        pj = array.get(taP, j)
                        if na(minV) or pj < minV
                            minV := pj
                            minI := j
                if minI < 0
                    break
                bestJ = minI
                bestS = array.get(taS, minI)
                for j = 0 to nTA - 1
                    if not array.get(usedA, j) and math.abs(array.get(taP, j) - minV) <= sep and array.get(taS, j) > bestS
                        bestJ := j
                        bestS := array.get(taS, j)
                chP  = array.get(taP,  bestJ)
                chB  = array.get(taB,  bestJ)
                chH  = array.get(taH,  bestJ)
                chCA = array.get(taCA, bestJ)
                int tSrc = array.get(taI, bestJ)
                // v14: tested levels draw as COMPLETE PAIRS — pair color,
                // tested style, partner + band alongside
                int tComp = f_pairPartner(tSrc, nodeArr, not showContainment)
                int tKey = chH ? tSrc : (tComp >= 0 ? tComp : tSrc)
                color tCol = f_pairColor(tKey)
                stT = f_levelState(chH, chCA, chP, curClose)
                if not array.includes(drawnPairSources, tSrc)
                    [lnT, lbT, mkT, hbT] = drawRay(chB, chP, tCol, testedSty, stT)
                    array.push(dLines, lnT)
                    if not na(lbT)
                        array.push(dLabels, lbT)
                    if not na(mkT)
                        array.push(dBoxes, mkT)
                    if not na(hbT)
                        array.push(dBoxes, hbT)
                    array.push(drawnPairSources, tSrc)
                    array.push(pbPrices, chP)
                    array.push(pbStates, stT)
                    array.push(pbColors, tCol)
                    array.push(pbIsAbove, true)
                if showPairBands and tComp >= 0
                    float tbandP = array.get(lvlP, tComp)
                    int   tbandB = array.get(lvlB, tComp)
                    if not na(tbandP) and tbandB != chB and bar_index - math.min(tbandB, chB) < 4500
                        int   tbB1 = math.min(tbandB, chB)
                        int   tbB2 = math.max(tbandB, chB)
                        float tbP1 = tbandB < chB ? tbandP : chP
                        float tbP2 = tbandB < chB ? chP : tbandP
                        float tHalf = math.max(math.abs(chP - tbandP) * 0.04, syminfo.mintick)
                        tbandCol = color.new(tCol, HL_TRANSP)
                        tpts = array.from(chart.point.from_index(tbB1, tbP1 + tHalf), chart.point.from_index(tbB2, tbP2 + tHalf), chart.point.from_index(tbB2, tbP2 - tHalf), chart.point.from_index(tbB1, tbP1 - tHalf))
                        array.push(dPolys, polyline.new(tpts, closed=true, xloc=xloc.bar_index, line_color=tbandCol, fill_color=tbandCol, line_width=1))
                if tComp >= 0 and not array.includes(drawnPairSources, tComp)
                    float tcP  = array.get(lvlP, tComp)
                    int   tcB  = array.get(lvlB, tComp)
                    bool  tcH  = array.get(lvlIsH, tComp)
                    bool  tcCA = array.get(lvlClosedAbove, tComp)
                    tcSty = array.get(lvlT, tComp) ? testedSty : untestedSty
                    tcSt  = f_levelState(tcH, tcCA, tcP, curClose)
                    [lnTC, lbTC, mkTC, hbTC] = drawRay(tcB, tcP, tCol, tcSty, tcSt)
                    array.push(dLines, lnTC)
                    if not na(lbTC)
                        array.push(dLabels, lbTC)
                    if not na(mkTC)
                        array.push(dBoxes, mkTC)
                    if not na(hbTC)
                        array.push(dBoxes, hbTC)
                    array.push(drawnPairSources, tComp)
                    array.push(pbPrices, tcP)
                    array.push(pbStates, tcSt)
                    array.push(pbColors, tCol)
                    array.push(pbIsAbove, tcP >= curClose)
                for j = 0 to nTA - 1
                    if math.abs(array.get(taP, j) - chP) <= sep
                        array.set(usedA, j, true)
                array.set(usedA, minI, true)
                dTA += 1

        nTB = array.size(tbP)
        if nTB > 0 and testedBelow > 0
            usedB = array.new<bool>(nTB, false)
            dTB = 0
            while dTB < testedBelow
                maxV = float(na)
                maxI = -1
                for j = 0 to nTB - 1
                    if not array.get(usedB, j)
                        pj = array.get(tbP, j)
                        if na(maxV) or pj > maxV
                            maxV := pj
                            maxI := j
                if maxI < 0
                    break
                bestJ = maxI
                bestS = array.get(tbS, maxI)
                for j = 0 to nTB - 1
                    if not array.get(usedB, j) and math.abs(array.get(tbP, j) - maxV) <= sep and array.get(tbS, j) > bestS
                        bestJ := j
                        bestS := array.get(tbS, j)
                chP  = array.get(tbP,  bestJ)
                chB  = array.get(tbB,  bestJ)
                chH  = array.get(tbH,  bestJ)
                chCA = array.get(tbCA, bestJ)
                int tSrc = array.get(tbI, bestJ)
                // v14: tested levels draw as COMPLETE PAIRS — pair color,
                // tested style, partner + band alongside
                int tComp = f_pairPartner(tSrc, nodeArr, not showContainment)
                int tKey = chH ? tSrc : (tComp >= 0 ? tComp : tSrc)
                color tCol = f_pairColor(tKey)
                stT = f_levelState(chH, chCA, chP, curClose)
                if not array.includes(drawnPairSources, tSrc)
                    [lnT, lbT, mkT, hbT] = drawRay(chB, chP, tCol, testedSty, stT)
                    array.push(dLines, lnT)
                    if not na(lbT)
                        array.push(dLabels, lbT)
                    if not na(mkT)
                        array.push(dBoxes, mkT)
                    if not na(hbT)
                        array.push(dBoxes, hbT)
                    array.push(drawnPairSources, tSrc)
                    array.push(pbPrices, chP)
                    array.push(pbStates, stT)
                    array.push(pbColors, tCol)
                    array.push(pbIsAbove, false)
                if showPairBands and tComp >= 0
                    float tbandP = array.get(lvlP, tComp)
                    int   tbandB = array.get(lvlB, tComp)
                    if not na(tbandP) and tbandB != chB and bar_index - math.min(tbandB, chB) < 4500
                        int   tbB1 = math.min(tbandB, chB)
                        int   tbB2 = math.max(tbandB, chB)
                        float tbP1 = tbandB < chB ? tbandP : chP
                        float tbP2 = tbandB < chB ? chP : tbandP
                        float tHalf = math.max(math.abs(chP - tbandP) * 0.04, syminfo.mintick)
                        tbandCol = color.new(tCol, HL_TRANSP)
                        tpts = array.from(chart.point.from_index(tbB1, tbP1 + tHalf), chart.point.from_index(tbB2, tbP2 + tHalf), chart.point.from_index(tbB2, tbP2 - tHalf), chart.point.from_index(tbB1, tbP1 - tHalf))
                        array.push(dPolys, polyline.new(tpts, closed=true, xloc=xloc.bar_index, line_color=tbandCol, fill_color=tbandCol, line_width=1))
                if tComp >= 0 and not array.includes(drawnPairSources, tComp)
                    float tcP  = array.get(lvlP, tComp)
                    int   tcB  = array.get(lvlB, tComp)
                    bool  tcH  = array.get(lvlIsH, tComp)
                    bool  tcCA = array.get(lvlClosedAbove, tComp)
                    tcSty = array.get(lvlT, tComp) ? testedSty : untestedSty
                    tcSt  = f_levelState(tcH, tcCA, tcP, curClose)
                    [lnTC, lbTC, mkTC, hbTC] = drawRay(tcB, tcP, tCol, tcSty, tcSt)
                    array.push(dLines, lnTC)
                    if not na(lbTC)
                        array.push(dLabels, lbTC)
                    if not na(mkTC)
                        array.push(dBoxes, mkTC)
                    if not na(hbTC)
                        array.push(dBoxes, hbTC)
                    array.push(drawnPairSources, tComp)
                    array.push(pbPrices, tcP)
                    array.push(pbStates, tcSt)
                    array.push(pbColors, tCol)
                    array.push(pbIsAbove, tcP >= curClose)
                for j = 0 to nTB - 1
                    if math.abs(array.get(tbP, j) - chP) <= sep
                        array.set(usedB, j, true)
                array.set(usedB, maxI, true)
                dTB += 1

    // ─────────────────────────────────────────────
    //  POLYBOUNDS TABLE
    // ─────────────────────────────────────────────
    if enablePolyBounds
        if not na(polyBoundsTable)
            table.delete(polyBoundsTable)

        float polyHoldAbove = na
        float polyHoldBelow = na
        color polyAboveColor = color.gray
        color polyBelowColor = color.gray
        string polyAboveState = ""
        string polyBelowState = ""

        nTracked = array.size(pbPrices)
        if nTracked > 0
            for i = 0 to nTracked - 1
                p = array.get(pbPrices, i)
                st = array.get(pbStates, i)
                col = array.get(pbColors, i)
                isAbove = array.get(pbIsAbove, i)

                if isAbove and st == "RL"
                    if na(polyHoldBelow) or p < polyHoldBelow
                        polyHoldBelow := p
                        polyBelowColor := col
                        polyBelowState := st

                if not isAbove and (st == "SG" or st == "G")
                    if na(polyHoldAbove) or p > polyHoldAbove
                        polyHoldAbove := p
                        polyAboveColor := col
                        polyAboveState := st

        isHourlyOrBelow = timeframe.isintraday and timeframe.multiplier <= 60
        string trendDayText = ""
        color trendDayColor = color.gray

        if not isHourlyOrBelow
            trendDayText := "use 1hr or below"
            trendDayColor := color.new(#8B949E, 0)
        else
            if potRevUp
                trendDayText := "Pot. Reversing ▲"
                trendDayColor := color.new(#FFD600, 0)
            else if potRevDown
                trendDayText := "Pot. Reversing ▼"
                trendDayColor := color.new(#FFD600, 0)
            else if regime == 1
                trendDayText := regimeConfirmed ? "Likely ▲" : "Reversal ▲"
                trendDayColor := color.new(#00FF00, 0)
            else if regime == -1
                trendDayText := regimeConfirmed ? "Likely ▼" : "Reversal ▼"
                trendDayColor := color.new(#FF0000, 0)
            else
                trendDayText := "—"
                trendDayColor := color.new(#8B949E, 0)

        polyBoundsTable := table.new(position.bottom_right, 2, 3,
            bgcolor=color.new(#101318, 10),
            frame_color=color.new(#555555, 60),
            frame_width=1)

        belowDisplay = not na(polyHoldBelow) ? polyBelowState + " " + str.tostring(polyHoldBelow, format.mintick) : "—"
        table.cell(polyBoundsTable, 0, 0, "▼ hold below:", text_color=color.new(#FF5252, 0), text_size=size.small)
        table.cell(polyBoundsTable, 1, 0, belowDisplay, text_color=polyBelowColor, text_size=size.small)

        aboveDisplay = not na(polyHoldAbove) ? polyAboveState + " " + str.tostring(polyHoldAbove, format.mintick) : "—"
        table.cell(polyBoundsTable, 0, 1, "▲ hold above:", text_color=color.new(#00E676, 0), text_size=size.small)
        table.cell(polyBoundsTable, 1, 1, aboveDisplay, text_color=polyAboveColor, text_size=size.small)

        table.cell(polyBoundsTable, 0, 2, "Trend Day:", text_color=color.new(#8B949E, 0), text_size=size.small)
        table.cell(polyBoundsTable, 1, 2, trendDayText, text_color=trendDayColor, text_size=size.small)
    else
        if not na(polyBoundsTable)
            table.delete(polyBoundsTable)
            polyBoundsTable := na

// ─────────────────────────────────────────────
//  ALERTS — enable individually in TV's alert dialog
// ─────────────────────────────────────────────
alertcondition(levelCommitted,          "New Level Committed",   "Polytrends: a new swing level was committed to the pool")
alertcondition(sgFirstTouch,            "SG First Touch",        "Polytrends: first touch of an untouched SG level")
alertcondition(supportLost,             "Support Lost (SG → L)", "Polytrends: a support level hard-closed below")
alertcondition(regimeFlip,              "Regime Flip",           "Polytrends: trend regime flipped on a hard close")
alertcondition(potRevUp or potRevDown,  "Pot. Reversing",        "Polytrends: wick beyond the trend invalidation point")
````

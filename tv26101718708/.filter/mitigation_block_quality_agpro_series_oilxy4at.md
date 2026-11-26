# Mitigation Block Quality [AGPro Series]

- url: https://www.tradingview.com/script/oilXY4at-Mitigation-Block-Quality-AGPro-Series/
- type: indicator
- pine_id: PUB;80a08bfd971f4affb243a909e6b0aaa5
- version: 4.0

## Description

OVERVIEW

Mitigation Block Quality grades every order-block retest as A, B, or C based on
the strength, speed, and follow-through of the bounce after price returns to
the block. Instead of just drawing order blocks and leaving you to guess
which ones matter, the script measures each mitigation objectively and keeps
a live scoreboard of how those reactions have been performing.

The result is an order block tool that tells you two things at once: where
the zones are, and how well price has historically respected them on the
symbol and timeframe you are looking at.


UNIQUE EDGE

Most order-block indicators end at detection. This one begins there. Each
time a block is mitigated, the script measures the reaction over a fixed
window and grades the bounce by its ATR-normalized magnitude. That grade
is then reflected everywhere: on the block border, in the on-chart label,
in the dashboard, and in the historical success-rate statistics.

You also get multi-timeframe context, confluence detection, streak tracking,
and a dynamic setup banner that describes the current price-block
relationship in plain English.


METHODOLOGY

1. Detection. Swing pivots are identified using a configurable pivot length.
   The last opposite-colored candle before the pivot forms the order block.
2. Mitigation. A block is mitigated when price re-enters the zone.
3. Grading. After a fixed reaction window, the script measures the peak of
   the bounce and normalizes it to ATR. Grade A is a strong bounce, B is
   solid, C is weak.
4. Invalidation. A body close beyond the block marks it as invalidated.
   Invalidated blocks can be hidden or shown as a dotted reference.
5. Retirement. Blocks retire by age, by distance from price, or when the
   per-side cap is exceeded.


FEATURES

- A, B, or C grade assigned to every mitigation (ATR-normalized reaction)
- Reaction trail line on Grade A mitigations showing the bounce extent
- Entry marker (diamond) at the exact mitigation bar of Grade A bounces
- Confluence glow when two or more blocks overlap within 0.5 ATR
- Time-based opacity decay so older blocks recede and fresh ones pop
- Optional pulse animation on A/B blocks while price is inside them
- Price-scale labels tagging each active block's grade and side
- Higher-timeframe alignment check against a configurable HTF structural bias
- Dashboard panel with: active count, tested count, success (current),
  nearest-block state (Inside / Touching / distance in ATR), all-time
  success rate with stacked distribution bar, last-20 success, health
  progress bar, current Win/Loss streak, HTF alignment, and a dynamic
  setup banner


SIGNALS & ALERTS

Three alert conditions are provided:
- Grade A Mitigation  — a premium-quality bounce has been detected
- Grade B Mitigation  — a solid bounce has been detected
- Block Invalidation  — an active block has been broken

These are alertconditions and can be configured from the TradingView
Create Alert dialog in the usual way.


KEY INPUTS

- Pivot Length and Lookback: control how blocks are detected and how long
  they stay on the chart
- Reaction Window and Grade Thresholds (A, B in ATR units): define what
  counts as a premium, solid, or weak bounce
- Invalidation Mode: choose between body close or wick pierce
- Retire Block Beyond (xATR): automatic cleanup when price moves far away
- Max Active Blocks per Side and Max Visible Labels: keep the chart premium
- Premium Visuals toggles: Reaction Trail, Entry Marker, Confluence Glow,
  Quality Heatmap row, Setup Banner, Pulse, Time Decay, Price Scale Labels,
  HTF Alignment, Streak row
- HTF for Alignment: the higher timeframe used for multi-timeframe confluence
- Panel location and theme


HOW TO USE

1. Add the script to any chart and timeframe.
2. Read the panel top-down:
   - Last 20 breakdown tells you the recent quality regime
   - Nearest Block tells you how close the closest active zone is
   - All-time and Last 20 success tell you how reliable those zones have been
   - Streak gives you momentum context
   - HTF Alignment tells you if the bigger picture agrees
   - Setup banner describes what is happening right now
3. Look at the chart:
   - A/B/C labels on mitigated blocks tell you how those tests resolved
   - Reaction trails and diamonds highlight the premium Grade A mitigations
   - Confluence glows mark zones where multiple blocks agree
4. Use alerts to get notified when a fresh Grade A or Grade B mitigation
   occurs, or when an active block is invalidated.

The tool is designed to help with discretionary analysis. It is not a
trading system and does not generate buy or sell signals on its own.


LIMITATIONS & TRANSPARENCY

- Pivots are confirmed after the swing length completes, so block detection
  has a small structural lag. This is inherent to any pivot-based method.
- Grades are assigned after the reaction window closes. A very fresh
  mitigation will briefly show "Active" before its grade appears.
- HTF Alignment uses a 50-period simple moving average on the chosen higher
  timeframe as a structural bias proxy. It is a context filter, not a
  predictive signal.
- All metrics are computed from the visible historical data on the current
  chart. Loading more bars will change the all-time statistics.
- The script uses Pine Script v6 drawing objects. Extremely long histories
  on very low timeframes may hit TradingView object limits; the built-in
  per-side cap and distance-based retire keep this under control in normal
  use.


RISK DISCLOSURE

This script is an analysis aid, not financial advice. It does not predict
future price movement and does not generate trade recommendations. Any
decision to enter or exit a position is the responsibility of the user.
Historical grade distributions are descriptive, not predictive. Past
mitigation behavior on a symbol does not guarantee future behavior.
Trade with risk capital you can afford to lose and use appropriate
position sizing and stop placement.


LICENSE

Released under the Mozilla Public License 2.0. The full source is available
on TradingView via the Open-Source badge. You are free to study and modify
the code subject to the terms of the license.

## Source Code

````pine
// =============================================================================
// Mitigation Block Quality [AGPro Series]
// -----------------------------------------------------------------------------
// Author  : AGProLabs | AGPro Series
// Version : 3.1
// =============================================================================
// Maps mitigation blocks, measures the reaction after each test, and converts
// depth, follow-through, freshness, width, and repeated hits into a normalized
// 0-100 quality score. A compact lifecycle panel and labeled defense zones keep
// demand and supply reactions readable without turning the chart into a generic
// order-block map or a predictive trading system.
// =============================================================================
//@version=6
indicator("Mitigation Block Quality [AGPro Series]",
     shorttitle       = "AG Pro MBQ",
     overlay          = true,
     max_boxes_count  = 500,
     max_lines_count  = 500,
     max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────────────
// AGPro Color Palette
// ─────────────────────────────────────────────────────────────────────────────
headerBg      = color.rgb(37, 99, 235)     // #2563EB
headerText    = color.rgb(245, 247, 250)   // #F5F7FA
panelBg       = color.rgb(15, 23, 42)      // #0F172A
panelBorder   = color.rgb(51, 65, 85)      // #334155
panelLabelCol = color.rgb(148, 163, 184)   // #94A3B8
panelValueCol = color.rgb(226, 232, 240)   // #E2E8F0
bullColor     = color.rgb(34, 197, 166)    // #22C5A6
bearColor     = color.rgb(244, 114, 182)   // #F472B6
neutralColor  = color.rgb(245, 189, 92)    // #F5BD5C
accentColor   = color.rgb(129, 140, 248)   // #818CF8
greyFar       = color.rgb(120, 130, 145)
whiteLabel    = color.rgb(255, 255, 255)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — Detection
// ─────────────────────────────────────────────────────────────────────────────
grpDet = "Detection"
sensitivity   = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = grpDet,
     tooltip = "Controls how selective the mitigation planner is. Conservative favors fewer, cleaner lifecycle states; Aggressive accepts earlier mitigation review states.")
confirmMode   = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = grpDet,
     tooltip = "Close Confirmed waits for the bar to close before lifecycle alerts are printed. Live Updating allows intrabar state updates for more responsive review.")
swingLen     = input.int(5,   "Swing Length",               minval = 2,  maxval = 20, group = grpDet,
     tooltip = "Pivot lookback used to locate the origin candle of each order block. Lower values produce more blocks; higher values produce fewer but more significant ones.")
obLookback   = input.int(200, "Block Lifetime (bars)",      minval = 50, maxval = 500, group = grpDet,
     tooltip = "Maximum age of an order block in bars before it is retired. Prevents stale blocks from cluttering the chart.")
maxActive    = input.int(6,   "Max Active Blocks / Side",   minval = 3,  maxval = 20, group = grpDet,
     tooltip = "Upper cap on simultaneously tracked blocks per side. When exceeded, the oldest block is retired first. Lower = cleaner chart.")
maxDistATR   = input.float(15.0, "Retire Block Beyond (xATR)", minval = 3.0, maxval = 50.0, step = 0.5, group = grpDet,
     tooltip = "Blocks are automatically retired when price moves this many ATRs away from them. Keeps the chart focused on relevant levels only. Lower = more aggressive cleanup.")
maxVisibleObjects = input.int(6, "Max Visible Objects", minval = 3, maxval = 30, group = grpDet,
     tooltip = "Caps visible mitigation structures per side before older objects are retired. This protects performance and keeps the chart publication-clean.")
activeCap = math.min(maxActive, maxVisibleObjects)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — Quality Scoring
// ─────────────────────────────────────────────────────────────────────────────
grpQ = "Quality Scoring"
reactionBars = input.int(5,    "Reaction Window (bars)",    minval = 2,  maxval = 20, group = grpQ,
     tooltip = "Number of bars measured after a mitigation event to evaluate the reaction magnitude and grade it A / B / C.")
atrLen       = input.int(14,   "ATR Length",                minval = 5,  maxval = 50, group = grpQ,
     tooltip = "ATR length used to normalize reaction strength across different volatility regimes.")
minQualityScore = input.int(68, "Minimum Quality Score", minval = 35, maxval = 95, group = grpQ,
     tooltip = "Minimum 0-100 block quality score required before the planner treats a mitigation as a high-quality defended state.")
gradeAThresh = input.float(1.5, "Grade A Threshold (xATR)", minval = 0.5, step = 0.1, group = grpQ,
     tooltip = "Minimum ATR-normalized reaction required for a Grade A (premium) mitigation. Higher = more selective.")
gradeBThresh = input.float(0.8, "Grade B Threshold (xATR)", minval = 0.2, step = 0.1, group = grpQ,
     tooltip = "Minimum ATR-normalized reaction required for a Grade B (solid) mitigation. Reactions below this fall to Grade C.")
sensMult = sensitivity == "Conservative" ? 1.15 : sensitivity == "Aggressive" ? 0.90 : 1.00
gradeAActive = gradeAThresh * sensMult
gradeBActive = gradeBThresh * sensMult

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — Invalidation
// ─────────────────────────────────────────────────────────────────────────────
grpInv = "Invalidation"
invalidateMode  = input.string("Body Close", "Invalidation Mode", options = ["Body Close", "Wick Break"], group = grpInv,
     tooltip = "Body Close: the block is invalidated only when a candle body closes beyond it (stricter). Wick Break: any wick beyond the block invalidates (more reactive).")
showInvalidated = input.bool(false, "Show Invalidated Blocks (dotted)", group = grpInv,
     tooltip = "Keeps invalidated blocks visible as dotted grey references instead of removing them, so you can see where structure was broken.")

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — Visual
// ─────────────────────────────────────────────────────────────────────────────
grpVis = "Visual"
showBullBlocks = input.bool(true, "Show Bullish Blocks", group = grpVis)
showBearBlocks = input.bool(true, "Show Bearish Blocks", group = grpVis)
extendBlocks   = input.bool(true, "Extend Blocks to Right", group = grpVis,
     tooltip = "Keeps the box extending right so the block remains visible as a live reference until mitigated or invalidated.")
showDottedExt  = input.bool(true, "Dotted Mid-Level Extension", group = grpVis,
     tooltip = "Draws a dotted horizontal line from the block mid-point as a far-reference level.")
dottedActiveOnly = input.bool(true, "Dotted Lines on Active Blocks Only", group = grpVis,
     tooltip = "When ON, the dotted mid-level line is drawn only for active (un-mitigated) blocks. Mitigated blocks keep only the box, which dramatically reduces visual clutter.")
showDefenseRail = input.bool(true, "Show Defense Rail", group = grpVis,
     tooltip = "Draws the active invalidation edge of each mitigation block as a clean defense rail. The rail marks where the block lifecycle would lose structural validity.")
showZoneText = input.bool(true, "Show Centered Block Text", group = grpVis,
     tooltip = "Places a centered lifecycle label inside each visible mitigation block so the zone communicates its state without requiring extra chart clutter.")
compressNestedBlocks = input.bool(true, "Compress Nested Blocks", group = grpVis,
     tooltip = "Keeps only the strongest visual representative when same-side blocks materially overlap in both price and time. All blocks remain in the analytical model; only redundant boxes and labels are suppressed.")
showLabels     = input.bool(true, "Show Mitigation Labels", group = grpVis,
     tooltip = "Displays the A/B/C label with age and hit count when mitigation occurs.")
maxLabels      = input.int(6, "Max Visible Labels", minval = 2, maxval = 20, group = grpVis,
     tooltip = "Caps the number of on-chart mitigation labels to the most recent N. Keeps the chart premium and uncluttered.")
minLabelScore  = input.int(72, "Minimum Historical Label Score", minval = 0, maxval = 100, group = grpVis,
     tooltip = "Shows detailed right-edge labels only when the completed quality score meets this threshold. Lower-quality visible zones retain a concise centered lifecycle badge.")
onlyALabels    = input.bool(false, "Show Only Grade A Labels", group = grpVis,
     tooltip = "When ON, only Grade A (premium) mitigation labels are drawn. Grades B and C are suppressed for a cleaner chart.")
boxAlpha       = input.int(85, "Box Transparency",  minval = 50, maxval = 95, group = grpVis,
     tooltip = "Transparency of the block fill. Higher = more pastel / less distracting.")
lineWidthDom   = input.int(3, "Mitigated Border Width", minval = 1, maxval = 5, group = grpVis,
     tooltip = "Border width for mitigated (graded) blocks — these are the most important blocks on the chart.")
lineWidthAct   = input.int(2, "Active Border Width",    minval = 1, maxval = 5, group = grpVis,
     tooltip = "Border width for active un-tested blocks.")
lineWidthPass  = input.int(1, "Invalidated Border Width", minval = 1, maxval = 5, group = grpVis,
     tooltip = "Border width for invalidated blocks (dotted style).")

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — Premium Visuals (WOW features)
// ─────────────────────────────────────────────────────────────────────────────
grpWow = "Premium Visuals"
showReactionTrail = input.bool(true, "Show Reaction Trail (Grade A)", group = grpWow,
     tooltip = "Draws a gradient line from the mitigation point to the peak of the reaction — visualizes the bounce strength that earned a Grade A. Makes premium mitigations unmistakable at a glance.")
showEntryMarker   = input.bool(true, "Show Touch Marker (Grade A)", group = grpWow,
     tooltip = "Places a diamond marker at the bar where a Grade A mitigation occurred. It marks the exact touch point of a high-quality reaction.")
showConfluence    = input.bool(false, "Show Confluence Glow", group = grpWow,
     tooltip = "When 2+ blocks overlap within 0.5 ATR, draws a subtle outer glow around the cluster — highlights high-confluence Points of Interest (POIs) loved by Smart Money traders.")
showHeatmapBar    = input.bool(true, "Show Quality Heatmap in Panel", group = grpWow,
     tooltip = "Adds a row in the panel showing the last 20 mitigations as a color heatmap (green=A, amber=B, grey=C). One glance tells you how quality is trending.")
showSetupBanner   = input.bool(true, "Show Current Setup Banner", group = grpWow,
     tooltip = "Adds a dynamic banner at the bottom of the panel describing the current price-block relationship (e.g. 'Inside Grade A Demand', 'Approaching Supply').")
showPulse         = input.bool(true, "Pulse Active Hot Zones", group = grpWow,
     tooltip = "Makes the border of a Grade A/B block gently pulse (alternating width per bar) when price is currently inside it. Draws the eye to the most urgent zone on the chart.")
showTimeDecay     = input.bool(true, "Time-based Opacity Decay", group = grpWow,
     tooltip = "Fades older blocks progressively (higher transparency as they age) so fresh levels command attention and stale ones recede visually.")
showPriceLabels   = input.bool(false, "Price Scale Labels", group = grpWow,
     tooltip = "Optional. Adds a small text tag out on the right price scale for each active block, marking its grade and side. Off by default to keep the chart clean, since grade and side are already shown by the right-edge label and the block colour. Enable if you want a price-scale marker when scrolled away from the block origin.")
showHtfConfluence = input.bool(true, "Higher Timeframe Alignment", group = grpWow,
     tooltip = "Compares the nearest mitigation block on the current timeframe against the same on a higher timeframe. When both agree on side (bullish/bearish), a high-emphasis alignment banner appears. Signals true multi-timeframe confluence.")
htfTimeframe      = input.timeframe("240", "HTF for Alignment", group = grpWow,
     tooltip = "The higher timeframe used to compute multi-timeframe alignment. Common choices: 240 (4H) on a 1H chart, D on a 4H chart, W on a 1D chart.")
showStreak        = input.bool(true, "Show Win/Loss Streak", group = grpWow,
     tooltip = "Adds a panel row showing the current consecutive streak of grade outcomes — e.g. '3 Wins (A,B,A)' when the last three mitigations were A or B, or '4 Losses (C,C,C,C)' when they were weak.")

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — Panel
// ─────────────────────────────────────────────────────────────────────────────
grpPanel = "Panel"
showPanel     = input.bool(true, "Show Dashboard Panel", group = grpPanel)
panelLocation = input.string("Top Right", "Panel Location",
     options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = grpPanel,
     tooltip = "Where the dashboard panel is anchored on the chart.")
panelTheme    = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = grpPanel,
     tooltip = "Dark: slate background for dark charts. Light: soft white background for light charts.")
panelTextSize = input.string("Normal", "Panel Font Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = grpPanel,
     tooltip = "Font size used throughout the dashboard panel.")
labelTextSize = input.string("Normal", "Label Font Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = grpPanel,
     tooltip = "Font size used for on-chart mitigation labels (A / B / C).")

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — Alerts
// ─────────────────────────────────────────────────────────────────────────────
grpAlert = "Alerts"
eventCooldownBars = input.int(8, "Event Cooldown Bars", minval = 1, maxval = 80, group = grpAlert,
     tooltip = "Minimum bars between lifecycle attention events. Higher values reduce repeated alerts and labels during active mitigation sequences.")
alertOnReady = input.bool(true, "Alert on READY State", group = grpAlert)
alertOnShift = input.bool(true, "Alert on Confirmed State Shift", group = grpAlert)
alertOnFollow = input.bool(true, "Alert on Major Follow-Through", group = grpAlert)
alertOnA    = input.bool(true,  "Alert on Grade A Mitigation",  group = grpAlert)
alertOnB    = input.bool(false, "Alert on Grade B Mitigation",  group = grpAlert)
alertOnInv  = input.bool(true,  "Alert on Block Invalidation",  group = grpAlert)

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
f_toSize(string p) =>
    switch p
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        =>          size.normal

f_panelPos(string p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left"  => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        =>                position.top_right

f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_text_on(color bg) =>
    lum = (0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)) / 255.0
    lum > 0.6 ? color.rgb(15, 23, 42) : color.rgb(245, 247, 250)

// Theme-dependent panel colors (evaluate once per bar)
themeDark = panelTheme == "Dark"
pBg       = themeDark ? panelBg        : color.rgb(248, 250, 252)
pBorder   = themeDark ? panelBorder    : color.rgb(203, 213, 225)
pLabel    = themeDark ? panelLabelCol  : color.rgb(71,  85,  105)
pValue    = themeDark ? panelValueCol  : color.rgb(15,  23,  42)

pTextSize = f_toSize(panelTextSize)
lTextSize = f_toSize(labelTextSize)

// ATR
atrVal    = ta.atr(atrLen)
atrSafe   = na(atrVal) or atrVal == 0 ? syminfo.mintick : atrVal
confirmedNow = confirmMode == "Live Updating" or barstate.isconfirmed

// ─────────────────────────────────────────────────────────────────────────────
// Higher Timeframe Bias — gauges whether HTF structure is bullish or bearish
// by comparing price to a longer-period moving average on the HTF. Returns
// +1 (bullish HTF), -1 (bearish HTF), or 0 (neutral / insufficient data).
// The comparison uses a 50-period SMA relative to the most recent HTF close,
// offering a robust, lag-controlled structural read.
// ─────────────────────────────────────────────────────────────────────────────
[htfClose, htfMa] = request.security(syminfo.tickerid, htfTimeframe,
     [close, ta.sma(close, 50)], lookahead = barmerge.lookahead_off)

int htfBias = 0
if not na(htfClose) and not na(htfMa)
    if htfClose > htfMa
        htfBias := 1
    else if htfClose < htfMa
        htfBias := -1

// ─────────────────────────────────────────────────────────────────────────────
// User-Defined Type
// ─────────────────────────────────────────────────────────────────────────────
type OB
    float  top
    float  bot
    int    startBar
    bool   isBull
    bool   mitigated
    bool   invalidated
    bool   graded          = false
    int    hitCount
    int    mitigationBar
    float  reactionPeak    = na
    float  mitigationDepth  = na
    float  qualityScore     = na
    string lifeState        = "Fresh"
    string grade           = ""
    box    bx              = na
    line   ln              = na
    line   defenseRail      = na
    label  lb              = na
    label  zoneLabel       = na
    line   trail           = na
    label  entryMark       = na
    box    glow            = na
    label  priceLabel      = na

// ─────────────────────────────────────────────────────────────────────────────
// State Arrays
// ─────────────────────────────────────────────────────────────────────────────
var array<OB>  bullBlocks    = array.new<OB>()
var array<OB>  bearBlocks    = array.new<OB>()
var array<int> last20Grades  = array.new<int>()    // 3=A, 2=B, 1=C

var int totalA       = 0
var int totalB       = 0
var int totalC       = 0

// Per-bar alert triggers (reset every bar)
var int gradeAEvent = 0
var int gradeBEvent = 0
var int invEvent    = 0
var int readyEvent  = 0
var int shiftEvent  = 0
var int followEvent = 0
var int lastReadyEventBar = na
var int lastShiftEventBar = na
var int lastFollowEventBar = na
gradeAEvent := 0
gradeBEvent := 0
invEvent    := 0
readyEvent  := 0
shiftEvent  := 0
followEvent := 0

// ─────────────────────────────────────────────────────────────────────────────
// Block Detection
// Bullish OB: the last bearish candle immediately preceding a confirmed
// pivot low forms a demand block (top = high, bottom = low of that candle).
// Bearish OB: mirror logic — the last bullish candle preceding a pivot high.
// Pivots confirm `swingLen` bars after the pivot bar, so we scan backward
// from the pivot to find the source candle.
// ─────────────────────────────────────────────────────────────────────────────
pivotHigh = ta.pivothigh(high, swingLen, swingLen)
pivotLow  = ta.pivotlow (low,  swingLen, swingLen)

if not na(pivotLow) and showBullBlocks
    int srcBar = na
    for i = 0 to swingLen * 2
        idx = swingLen + i
        if close[idx] < open[idx]
            srcBar := idx
            break
    if not na(srcBar)
        array.push(bullBlocks, OB.new(
             top           = high[srcBar],
             bot           = low[srcBar],
             startBar      = bar_index - srcBar,
             isBull        = true,
             mitigated     = false,
             invalidated   = false,
             hitCount      = 0,
             mitigationBar = 0))

if not na(pivotHigh) and showBearBlocks
    int srcBar = na
    for i = 0 to swingLen * 2
        idx = swingLen + i
        if close[idx] > open[idx]
            srcBar := idx
            break
    if not na(srcBar)
        array.push(bearBlocks, OB.new(
             top           = high[srcBar],
             bot           = low[srcBar],
             startBar      = bar_index - srcBar,
             isBull        = false,
             mitigated     = false,
             invalidated   = false,
             hitCount      = 0,
             mitigationBar = 0))

// ─────────────────────────────────────────────────────────────────────────────
// Cleanup helper — deletes every drawing object tied to an OB
// ─────────────────────────────────────────────────────────────────────────────
f_cleanupOB(OB ob) =>
    if not na(ob.bx)
        box.delete(ob.bx)
    if not na(ob.ln)
        line.delete(ob.ln)
    if not na(ob.defenseRail)
        line.delete(ob.defenseRail)
    if not na(ob.lb)
        label.delete(ob.lb)
    if not na(ob.zoneLabel)
        label.delete(ob.zoneLabel)
    if not na(ob.trail)
        line.delete(ob.trail)
    if not na(ob.entryMark)
        label.delete(ob.entryMark)
    if not na(ob.glow)
        box.delete(ob.glow)
    if not na(ob.priceLabel)
        label.delete(ob.priceLabel)
    int _ = 0

// Visual-only cleanup for a redundant nested block. Analytical state remains
// untouched, while every drawing handle is cleared so a later dominant block
// can be rendered safely without interacting with deleted objects.
f_hideOB(OB ob) =>
    if not na(ob.bx)
        box.delete(ob.bx)
        ob.bx := na
    if not na(ob.ln)
        line.delete(ob.ln)
        ob.ln := na
    if not na(ob.defenseRail)
        line.delete(ob.defenseRail)
        ob.defenseRail := na
    if not na(ob.lb)
        label.delete(ob.lb)
        ob.lb := na
    if not na(ob.zoneLabel)
        label.delete(ob.zoneLabel)
        ob.zoneLabel := na
    if not na(ob.trail)
        line.delete(ob.trail)
        ob.trail := na
    if not na(ob.entryMark)
        label.delete(ob.entryMark)
        ob.entryMark := na
    if not na(ob.glow)
        box.delete(ob.glow)
        ob.glow := na
    if not na(ob.priceLabel)
        label.delete(ob.priceLabel)
        ob.priceLabel := na
    int _ = 0

// Rank blocks inside one nested visual cluster. Price currently inside a block
// has first priority, followed by completed graded evidence, fresh planning
// zones, and pending mitigations. Quality and recency resolve close decisions.
f_visualRank(OB ob) =>
    inside = close >= ob.bot and close <= ob.top
    score  = na(ob.qualityScore) ? 0.0 : ob.qualityScore
    base   = inside ? 1000.0 : ob.graded ? 600.0 : not ob.mitigated ? 500.0 : 400.0
    base + score

// A same-side block is visually dominant unless a materially overlapping peer
// has a stronger lifecycle rank. This compresses nested structures without
// changing detection, scoring, proof statistics, or alert behavior.
f_isDominant(OB ob, array<OB> peers) =>
    bool dominant = true
    if not ob.invalidated
        endA    = ob.mitigated and ob.mitigationBar > 0 ? ob.mitigationBar + reactionBars : bar_index + 10
        heightA = math.max(syminfo.mintick, ob.top - ob.bot)
        rankA   = f_visualRank(ob)
        for peer in peers
            sameBlock = peer.startBar == ob.startBar and peer.top == ob.top and peer.bot == ob.bot
            if not sameBlock and not peer.invalidated
                endB        = peer.mitigated and peer.mitigationBar > 0 ? peer.mitigationBar + reactionBars : bar_index + 10
                timeOverlap = math.min(endA, endB) >= math.max(ob.startBar, peer.startBar)
                overlap     = math.min(ob.top, peer.top) - math.max(ob.bot, peer.bot)
                heightB     = math.max(syminfo.mintick, peer.top - peer.bot)
                overlapPct  = overlap > 0 ? overlap / math.min(heightA, heightB) : 0.0
                materiallyNested = timeOverlap and overlapPct >= 0.50
                if materiallyNested
                    rankB = f_visualRank(peer)
                    peerWins = rankB > rankA or (rankB == rankA and peer.startBar > ob.startBar)
                    if peerWins
                        dominant := false
    dominant

// ─────────────────────────────────────────────────────────────────────────────
// Cap active blocks per side (retire oldest first)
// ─────────────────────────────────────────────────────────────────────────────
while array.size(bullBlocks) > activeCap
    OB old = array.shift(bullBlocks)
    f_cleanupOB(old)

while array.size(bearBlocks) > activeCap
    OB old = array.shift(bearBlocks)
    f_cleanupOB(old)

// ─────────────────────────────────────────────────────────────────────────────
// Process each active block: mitigation touch + invalidation + aging.
// Logic is inlined here (rather than in a helper returning a tuple) because
// tuple destructuring inside a while loop creates redeclared locals.
// ─────────────────────────────────────────────────────────────────────────────
int newInvsTotal = 0

// Bullish blocks
int iB = 0
while iB < array.size(bullBlocks)
    OB ob = array.get(bullBlocks, iB)
    age = bar_index - ob.startBar
    bool removeBlock = false
    // Age-based retire
    if age > obLookback
        removeBlock := true
    // Distance-based retire (price has moved far away)
    else
        distAtr = math.min(math.abs(close - ob.top), math.abs(close - ob.bot)) / atrSafe
        if distAtr > maxDistATR
            removeBlock := true
        else
            invBody = invalidateMode == "Body Close" ? close < ob.bot : low < ob.bot
            if confirmedNow and not ob.invalidated and invBody
                ob.invalidated := true
                ob.lifeState   := "Invalidated"
                newInvsTotal  += 1
                canFireInvBull = na(lastShiftEventBar) or bar_index - lastShiftEventBar >= eventCooldownBars
                if canFireInvBull
                    shiftEvent := 1
                    lastShiftEventBar := bar_index
            touched = confirmedNow and not ob.invalidated and low <= ob.top and high >= ob.bot
            if touched
                ob.hitCount += 1
                if not ob.mitigated
                    blockRange = math.max(syminfo.mintick, ob.top - ob.bot)
                    depth = f_clamp((ob.top - low) / blockRange, 0.0, 1.0)
                    ob.mitigationDepth := depth
                    ob.lifeState := depth >= 0.75 ? "Full Test" : "Partial Test"
                    ob.mitigated     := true
                    ob.mitigationBar := bar_index
                    canFireReadyBull = na(lastReadyEventBar) or bar_index - lastReadyEventBar >= eventCooldownBars
                    if canFireReadyBull
                        readyEvent := 1
                        lastReadyEventBar := bar_index
    if removeBlock
        f_cleanupOB(ob)
        array.remove(bullBlocks, iB)
    else
        iB += 1

// Bearish blocks
int iBr = 0
while iBr < array.size(bearBlocks)
    OB ob = array.get(bearBlocks, iBr)
    age = bar_index - ob.startBar
    bool removeBlock = false
    if age > obLookback
        removeBlock := true
    else
        distAtr = math.min(math.abs(close - ob.top), math.abs(close - ob.bot)) / atrSafe
        if distAtr > maxDistATR
            removeBlock := true
        else
            invBody = invalidateMode == "Body Close" ? close > ob.top : high > ob.top
            if confirmedNow and not ob.invalidated and invBody
                ob.invalidated := true
                ob.lifeState   := "Invalidated"
                newInvsTotal  += 1
                canFireInvBear = na(lastShiftEventBar) or bar_index - lastShiftEventBar >= eventCooldownBars
                if canFireInvBear
                    shiftEvent := 1
                    lastShiftEventBar := bar_index
            touched = confirmedNow and not ob.invalidated and high >= ob.bot and low <= ob.top
            if touched
                ob.hitCount += 1
                if not ob.mitigated
                    blockRange = math.max(syminfo.mintick, ob.top - ob.bot)
                    depth = f_clamp((high - ob.bot) / blockRange, 0.0, 1.0)
                    ob.mitigationDepth := depth
                    ob.lifeState := depth >= 0.75 ? "Full Test" : "Partial Test"
                    ob.mitigated     := true
                    ob.mitigationBar := bar_index
                    canFireReadyBear = na(lastReadyEventBar) or bar_index - lastReadyEventBar >= eventCooldownBars
                    if canFireReadyBear
                        readyEvent := 1
                        lastReadyEventBar := bar_index
    if removeBlock
        f_cleanupOB(ob)
        array.remove(bearBlocks, iBr)
    else
        iBr += 1

if newInvsTotal > 0
    invEvent := 1

f_qualityScore(float reactAtr, float depth, float widthAtr, int age, int hits) =>
    d = na(depth) ? 0.50 : depth
    reactionPts = f_clamp(35.0 * reactAtr / math.max(0.10, gradeAActive), 0.0, 35.0)
    depthPts = f_clamp(25.0 - math.abs(d - 0.45) * 45.0, 5.0, 25.0)
    originPts = widthAtr <= 0.80 ? 20.0 : widthAtr <= 1.40 ? 16.0 : widthAtr <= 2.20 ? 11.0 : 7.0
    timePts = f_clamp(20.0 - 20.0 * age / math.max(1.0, obLookback * 1.0), 0.0, 20.0)
    hitPenalty = hits > 2 ? 10.0 : hits > 1 ? 5.0 : 0.0
    f_clamp(reactionPts + depthPts + originPts + timePts - hitPenalty, 0.0, 100.0)

f_lifecycleState(string grade, float score, float depth, bool invalidated) =>
    d = na(depth) ? 0.50 : depth
    if invalidated
        "Invalidated"
    else if grade == ""
        d >= 0.75 ? "Full Test" : "Partial Test"
    else if grade == "A" and score >= minQualityScore
        "Clean Mitigation"
    else if (grade == "A" or grade == "B") and score >= minQualityScore
        "Defended"
    else if grade == "B"
        "Partial Defense"
    else
        "Weak Reaction"

// ─────────────────────────────────────────────────────────────────────────────
// Grading: evaluate reaction N bars after mitigationBar.
// bar_index is mitigationBar + reactionBars when the trigger fires, so the
// reaction window is offsets 1..reactionBars (most recent N bars).
// Logic is INLINED in the main scope because UDT field mutation via a helper
// function was not persisting reliably (graded flag kept resetting).
// ─────────────────────────────────────────────────────────────────────────────
for ob in bullBlocks
    if confirmedNow and ob.mitigated and not ob.graded and (bar_index - ob.mitigationBar) >= reactionBars
        float mx = ob.top
        for k = 1 to reactionBars
            h = high[k]
            if h > mx
                mx := h
        react = (mx - ob.top) / atrSafe
        g = react >= gradeAActive ? "A" : react >= gradeBActive ? "B" : "C"
        widthAtr = (ob.top - ob.bot) / atrSafe
        age = bar_index - ob.startBar
        score = f_qualityScore(react, ob.mitigationDepth, widthAtr, age, ob.hitCount)
        ob.grade        := g
        ob.graded       := true
        ob.reactionPeak := mx
        ob.qualityScore := score
        ob.lifeState    := f_lifecycleState(g, score, ob.mitigationDepth, ob.invalidated)
        canFireShiftBull = na(lastShiftEventBar) or bar_index - lastShiftEventBar >= eventCooldownBars
        if canFireShiftBull
            shiftEvent := 1
            lastShiftEventBar := bar_index
        canFireFollowBull = score >= minQualityScore and (g == "A" or g == "B") and (na(lastFollowEventBar) or bar_index - lastFollowEventBar >= eventCooldownBars)
        if canFireFollowBull
            followEvent := 1
            lastFollowEventBar := bar_index
        if g == "A"
            totalA += 1
            gradeAEvent := 1
            array.push(last20Grades, 3)
        else if g == "B"
            totalB += 1
            gradeBEvent := 1
            array.push(last20Grades, 2)
        else
            totalC += 1
            array.push(last20Grades, 1)
        if array.size(last20Grades) > 20
            array.shift(last20Grades)

for ob in bearBlocks
    if confirmedNow and ob.mitigated and not ob.graded and (bar_index - ob.mitigationBar) >= reactionBars
        float mn = ob.bot
        for k = 1 to reactionBars
            l = low[k]
            if l < mn
                mn := l
        react = (ob.bot - mn) / atrSafe
        g = react >= gradeAActive ? "A" : react >= gradeBActive ? "B" : "C"
        widthAtr = (ob.top - ob.bot) / atrSafe
        age = bar_index - ob.startBar
        score = f_qualityScore(react, ob.mitigationDepth, widthAtr, age, ob.hitCount)
        ob.grade        := g
        ob.graded       := true
        ob.reactionPeak := mn
        ob.qualityScore := score
        ob.lifeState    := f_lifecycleState(g, score, ob.mitigationDepth, ob.invalidated)
        canFireShiftBear = na(lastShiftEventBar) or bar_index - lastShiftEventBar >= eventCooldownBars
        if canFireShiftBear
            shiftEvent := 1
            lastShiftEventBar := bar_index
        canFireFollowBear = score >= minQualityScore and (g == "A" or g == "B") and (na(lastFollowEventBar) or bar_index - lastFollowEventBar >= eventCooldownBars)
        if canFireFollowBear
            followEvent := 1
            lastFollowEventBar := bar_index
        if g == "A"
            totalA += 1
            gradeAEvent := 1
            array.push(last20Grades, 3)
        else if g == "B"
            totalB += 1
            gradeBEvent := 1
            array.push(last20Grades, 2)
        else
            totalC += 1
            array.push(last20Grades, 1)
        if array.size(last20Grades) > 20
            array.shift(last20Grades)

// ─────────────────────────────────────────────────────────────────────────────
// Rendering
// ─────────────────────────────────────────────────────────────────────────────
f_stateColor(OB ob) =>
    ob.invalidated ? greyFar : ob.isBull ? bullColor : bearColor

f_shortState(string state) =>
    switch state
        "Clean Mitigation" => "Clean"
        "Partial Defense"  => "Part"
        "Weak Reaction"    => "Weak"
        "Full Test"        => "Full"
        "Partial Test"     => "Part"
        "Invalidated"      => "Invalid"
        "Defended"         => "Defended"
        =>                    "Active"

f_gradeText(string g, int age, int hits, float score, string state) =>
    base = " (" + str.tostring(age) + "b/" + str.tostring(hits) + "x)"
    scoreTxt = na(score) ? "" : " " + str.tostring(score, "#")
    gradeTxt = g == "" ? "Ready" : g
    f_shortState(state) + " " + gradeTxt + scoreTxt + base

f_zoneText(OB ob) =>
    sideTxt = ob.isBull ? "DEMAND" : "SUPPLY"
    stateTxt = str.upper(f_shortState(ob.lifeState))
    scoreTxt = na(ob.qualityScore) ? "" : " | Q" + str.tostring(ob.qualityScore, "#")
    sideTxt + " | " + stateTxt + scoreTxt

f_render(OB ob, bool allowLabel) =>
    rCol   = f_stateColor(ob)

    // Time-based decay: older blocks fade progressively. Scale up transparency
    // linearly from the user-chosen boxAlpha baseline up toward ~95 as age
    // approaches obLookback. Invalidated blocks are not decayed further.
    age        = bar_index - ob.startBar
    decayBonus = 0
    if showTimeDecay and not ob.invalidated
        ratio      = math.min(1.0, math.max(0.0, age / math.max(1.0, obLookback * 1.0)))
        maxDecay   = 12
        decayBonus := int(math.round(ratio * maxDecay))
    effAlpha  = math.min(95, boxAlpha + decayBonus)
    fill      = color.new(rCol, effAlpha)

    // Pulse: when price is currently inside a Grade A or B block, alternate
    // the border width between two values on successive bars to create a
    // breathing effect that draws the eye to the most urgent zone.
    insideNow = close >= ob.bot and close <= ob.top
    pulseActive = showPulse and ob.graded and (ob.grade == "A" or ob.grade == "B") and insideNow and not ob.invalidated
    baseLw = ob.mitigated ? lineWidthDom : ob.invalidated ? lineWidthPass : lineWidthAct
    pulseLw = bar_index % 2 == 0 ? baseLw + 1 : baseLw
    lw     = pulseActive ? pulseLw : baseLw

    resolvedEndBar = ob.mitigated and not na(ob.mitigationBar) ? ob.mitigationBar + reactionBars : bar_index + 10
    endBar = extendBlocks ? resolvedEndBar : ob.startBar + 40
    ls     = ob.invalidated ? line.style_dotted : line.style_solid

    // Hide if invalidated and user doesn't want them shown
    if ob.invalidated and not showInvalidated
        if not na(ob.bx)
            box.delete(ob.bx)
            ob.bx := na
        if not na(ob.ln)
            line.delete(ob.ln)
            ob.ln := na
        if not na(ob.defenseRail)
            line.delete(ob.defenseRail)
            ob.defenseRail := na
        if not na(ob.lb)
            label.delete(ob.lb)
            ob.lb := na
        if not na(ob.zoneLabel)
            label.delete(ob.zoneLabel)
            ob.zoneLabel := na
        if not na(ob.priceLabel)
            label.delete(ob.priceLabel)
            ob.priceLabel := na
        int _ = 0
    else
        // Box
        if na(ob.bx)
            ob.bx := box.new(ob.startBar, ob.top, endBar, ob.bot,
                 border_color = rCol, bgcolor = fill,
                 border_width = lw, border_style = ls)
            int _ = 0
        else
            box.set_right(ob.bx, endBar)
            box.set_bgcolor(ob.bx, fill)
            box.set_border_color(ob.bx, rCol)
            box.set_border_width(ob.bx, lw)
            box.set_border_style(ob.bx, ls)
            int _ = 0

        // Defense rail marks the invalidation edge without turning the script
        // into a generic order-block or breaker-block map.
        drawDefense = showDefenseRail and not ob.invalidated
        defensePrice = ob.isBull ? ob.bot : ob.top
        if drawDefense
            railCol = color.new(rCol, 10)
            if na(ob.defenseRail)
                ob.defenseRail := line.new(ob.startBar, defensePrice, endBar, defensePrice,
                     color = railCol, style = line.style_solid, width = 2)
                int _ = 0
            else
                line.set_xy1(ob.defenseRail, ob.startBar, defensePrice)
                line.set_xy2(ob.defenseRail, endBar, defensePrice)
                line.set_color(ob.defenseRail, railCol)
                int _ = 0
        else if not na(ob.defenseRail)
            line.delete(ob.defenseRail)
            ob.defenseRail := na
            int _ = 0

        // Whether the richer right-edge mitigation label will be drawn for this
        // block. Computed here so the centered badge can defer to it: a zone is
        // never labelled both in-zone AND at the right edge.
        scoreQualified = not na(ob.qualityScore) and ob.qualityScore >= minLabelScore
        showThisLabel = showLabels and ob.mitigated and allowLabel and scoreQualified and (not onlyALabels or ob.grade == "A")

        // Every visible block keeps one meaningful label. Detailed high-quality
        // outcomes use a right-edge label; all other zones retain a centered
        // lifecycle badge so no visible planning zone is left unexplained.
        drawZoneText = showZoneText and not ob.invalidated and not showThisLabel
        if drawZoneText
            zTxt = f_zoneText(ob)
            zTip = "Centered mitigation lifecycle label. State, score, and defense context are calculated from mitigation depth, reaction strength, block width, hit count, and time decay."
            midPrice = (ob.top + ob.bot) / 2
            midBar = int(math.round((ob.startBar + endBar) / 2.0))
            badgeBg  = color.new(rCol, 28)
            badgeTxt = f_text_on(rCol)
            if na(ob.zoneLabel)
                ob.zoneLabel := label.new(midBar, midPrice, zTxt,
                     style = label.style_label_center,
                     color = badgeBg,
                     textcolor = badgeTxt,
                     size = lTextSize,
                     textalign = text.align_center,
                     tooltip = zTip)
                int _ = 0
            else
                label.set_xy(ob.zoneLabel, midBar, midPrice)
                label.set_text(ob.zoneLabel, zTxt)
                label.set_style(ob.zoneLabel, label.style_label_center)
                label.set_color(ob.zoneLabel, badgeBg)
                label.set_textcolor(ob.zoneLabel, badgeTxt)
                label.set_size(ob.zoneLabel, lTextSize)
                label.set_tooltip(ob.zoneLabel, zTip)
                int _ = 0
        else if not na(ob.zoneLabel)
            label.delete(ob.zoneLabel)
            ob.zoneLabel := na
            int _ = 0

        // Dotted mid-level extension — active blocks only if requested
        drawDotted = showDottedExt and (not dottedActiveOnly or not ob.mitigated)
        if drawDotted
            mid = (ob.top + ob.bot) / 2
            lnCol = color.new(rCol, 40)
            if na(ob.ln)
                ob.ln := line.new(ob.startBar, mid, bar_index + 20, mid,
                     color = lnCol, style = line.style_dotted, width = 1)
                int _ = 0
            else
                line.set_xy1(ob.ln, ob.startBar, mid)
                line.set_xy2(ob.ln, bar_index + 20, mid)
                line.set_color(ob.ln, lnCol)
                int _ = 0
        else if not na(ob.ln)
            line.delete(ob.ln)
            ob.ln := na
            int _ = 0

        // Label on mitigation — respect Grade-A-only filter and cap.
        // showThisLabel was computed above (shared with the centered-badge gate).
        if showThisLabel
            txt    = f_gradeText(ob.grade, age, ob.hitCount, ob.qualityScore, ob.lifeState)
            // Full info on hover for premium UX
            ttype  = ob.isBull ? "Bullish" : "Bearish"
            tip    = ttype + " mitigation block" +
                     "\nState: " + ob.lifeState +
                     "\nQuality Score: " + (na(ob.qualityScore) ? "Pending" : str.tostring(ob.qualityScore, "#") + "/100") +
                     "\nGrade: " + (ob.grade == "" ? "Pending" : ob.grade) +
                     "\nInvalidation edge: " + str.tostring(ob.isBull ? ob.bot : ob.top, format.mintick) +
                     "\nAge: " + str.tostring(age) + " bars" +
                     "\nHits: " + str.tostring(ob.hitCount) + "x"
            // Completed outcomes stay beside their own reaction window instead
            // of accumulating at the live right edge. Demand labels sit below
            // the zone and supply labels sit above it, keeping candles readable.
            ypos   = ob.isBull ? ob.bot - 0.35 * atrSafe : ob.top + 0.35 * atrSafe
            lstyle = ob.isBull ? label.style_label_up : label.style_label_down
            lxpos  = ob.mitigationBar + reactionBars + 1
            if na(ob.lb)
                ob.lb := label.new(lxpos, ypos, txt,
                     style     = lstyle,
                     color     = rCol,
                     textcolor = whiteLabel,
                     size      = lTextSize,
                     tooltip   = tip)
                int _ = 0
            else
                label.set_xy(ob.lb, lxpos, ypos)
                label.set_text(ob.lb, txt)
                label.set_color(ob.lb, rCol)
                label.set_style(ob.lb, lstyle)
                label.set_tooltip(ob.lb, tip)
                int _ = 0
        else if not na(ob.lb)
            label.delete(ob.lb)
            ob.lb := na
            int _ = 0

// Price Scale Label — sticky label anchored at the rightmost visible area,
// using label.style_none so only text shows, yloc.price so it stays anchored
// to the block mid-price regardless of chart scroll. Rendered only for
// active (non-invalidated) blocks that are NOT part of a confluence cluster
// (the glow already signals those zones; duplicate text is noise).
f_renderPriceLabel(OB ob) =>
    // Compact form: "A Dem" / "B Sup" / "Act Dem" / "Act Sup"
    // Skip if this block's glow is drawn (it's part of a confluence cluster)
    inCluster  = not na(ob.glow)
    shouldDraw = showPriceLabels and not ob.invalidated and not inCluster and not na(ob.bx)
    if shouldDraw
        midPrice = (ob.top + ob.bot) / 2
        side     = ob.isBull ? "Dem" : "Sup"
        gtxt     = ob.grade == "" ? "Act" : ob.grade
        txt      = gtxt + " " + side
        tCol     = f_stateColor(ob)
        xAnchor  = bar_index + 40
        if na(ob.priceLabel)
            ob.priceLabel := label.new(xAnchor, midPrice, txt,
                 style     = label.style_none,
                 textcolor = tCol,
                 size      = lTextSize)
            int _ = 0
        else
            label.set_xy(ob.priceLabel, xAnchor, midPrice)
            label.set_text(ob.priceLabel, txt)
            label.set_textcolor(ob.priceLabel, tCol)
            label.set_size(ob.priceLabel, lTextSize)
            int _ = 0
    else if not na(ob.priceLabel)
        label.delete(ob.priceLabel)
        ob.priceLabel := na
        int _ = 0

// ─────────────────────────────────────────────────────────────────────────────
// WOW features — Reaction Trail, Touch Marker, Confluence Glow
// ─────────────────────────────────────────────────────────────────────────────

// Reaction Trail — gradient line from mitigation bar/price to reaction peak.
// Only for Grade A mitigations (the most premium signals on the chart).
f_renderTrail(OB ob) =>
    shouldDraw = showReactionTrail and ob.graded and ob.grade == "A" and not ob.invalidated and not na(ob.reactionPeak)
    if shouldDraw
        startPrice = ob.isBull ? ob.top : ob.bot
        endBar     = ob.mitigationBar + reactionBars
        trailCol   = ob.isBull ? bullColor : bearColor
        if na(ob.trail)
            ob.trail := line.new(ob.mitigationBar, startPrice, endBar, ob.reactionPeak,
                 color = color.new(trailCol, 20),
                 style = line.style_solid,
                 width = 3)
            int _ = 0
        else
            line.set_xy1(ob.trail, ob.mitigationBar, startPrice)
            line.set_xy2(ob.trail, endBar, ob.reactionPeak)
            line.set_color(ob.trail, color.new(trailCol, 20))
            int _ = 0
    else if not na(ob.trail)
        line.delete(ob.trail)
        ob.trail := na
        int _ = 0

// Touch Marker: diamond at the mitigation bar, mid-price, for Grade A only.
// Marks the exact touch point of a premium-quality reaction.
f_renderEntryMark(OB ob) =>
    shouldDraw = showEntryMarker and ob.graded and ob.grade == "A" and not ob.invalidated
    if shouldDraw
        midPrice = (ob.top + ob.bot) / 2
        markCol  = ob.isBull ? bullColor : bearColor
        if na(ob.entryMark)
            ob.entryMark := label.new(ob.mitigationBar, midPrice, "",
                 style     = label.style_diamond,
                 color     = markCol,
                 textcolor = whiteLabel,
                 size      = size.tiny,
                 tooltip   = "Grade A mitigation touch - premium reaction")
            int _ = 0
        else
            label.set_xy(ob.entryMark, ob.mitigationBar, midPrice)
            label.set_color(ob.entryMark, markCol)
            int _ = 0
    else if not na(ob.entryMark)
        label.delete(ob.entryMark)
        ob.entryMark := na
        int _ = 0

// Confluence Glow — halo box around clusters of 2+ blocks within 0.5 ATR.
// Detects when multiple blocks agree on a price zone (high-conviction POI).
f_renderConfluence() =>
    if not showConfluence
        int _ = 0
    else
        // For each non-invalidated block, count how many other blocks share
        // its mid-price within 0.5 ATR. If count >= 2, draw a glow box.
        thresholdAtr = 0.5
        // First pass: delete stale glows
        for ob in bullBlocks
            if not na(ob.glow)
                box.delete(ob.glow)
                ob.glow := na
        for ob in bearBlocks
            if not na(ob.glow)
                box.delete(ob.glow)
                ob.glow := na
        // Second pass: detect and draw
        for ob in bullBlocks
            if not ob.invalidated and not na(ob.bx)
                mid  = (ob.top + ob.bot) / 2
                int cnt = 0
                float lo = ob.bot
                float hi = ob.top
                for other in bullBlocks
                    if not other.invalidated and not na(other.bx)
                        oMid = (other.top + other.bot) / 2
                        if math.abs(mid - oMid) <= thresholdAtr * atrSafe
                            cnt += 1
                            lo := math.min(lo, other.bot)
                            hi := math.max(hi, other.top)
                for other in bearBlocks
                    if not other.invalidated and not na(other.bx)
                        oMid = (other.top + other.bot) / 2
                        if math.abs(mid - oMid) <= thresholdAtr * atrSafe
                            cnt += 1
                            lo := math.min(lo, other.bot)
                            hi := math.max(hi, other.top)
                if cnt >= 2
                    padAtr = 0.25 * atrSafe
                    gCol   = accentColor
                    ob.glow := box.new(ob.startBar - 2, hi + padAtr,
                                       bar_index + 14, lo - padAtr,
                                       border_color = color.new(gCol, 60),
                                       bgcolor      = color.new(gCol, 92),
                                       border_width = 1,
                                       border_style = line.style_dotted)
                    int _ = 0
        int _ = 0

f_labelThreshold() =>
    array<int> mBars = array.new<int>()
    for ob in bullBlocks
        if ob.mitigated and not na(ob.qualityScore) and ob.qualityScore >= minLabelScore and (not onlyALabels or ob.grade == "A")
            array.push(mBars, ob.mitigationBar)
    for ob in bearBlocks
        if ob.mitigated and not na(ob.qualityScore) and ob.qualityScore >= minLabelScore and (not onlyALabels or ob.grade == "A")
            array.push(mBars, ob.mitigationBar)
    int thresh = 0
    if array.size(mBars) > maxLabels
        array.sort(mBars, order.descending)
        thresh := array.get(mBars, maxLabels - 1)
    thresh

// Label Y-collision avoidance helper — nudges labels apart when they share
// the same X column and sit too close in price. Used for both mitigation
// labels (bar_index + 12) and price scale labels (bar_index + 40).
f_nudgeCollisions(array<label> lbs, int baseX) =>
    n = array.size(lbs)
    if n > 1
        float minSep = 0.5 * atrSafe
        array<float> ys    = array.new<float>()
        array<int>   order = array.new<int>()
        for k = 0 to n - 1
            array.push(ys, label.get_y(array.get(lbs, k)))
            array.push(order, k)
        // Selection sort 'order' by ascending Y (lowest price first)
        for a = 0 to n - 2
            minPos = a
            for c = a + 1 to n - 1
                if array.get(ys, array.get(order, c)) < array.get(ys, array.get(order, minPos))
                    minPos := c
            if minPos != a
                tmp = array.get(order, a)
                array.set(order, a, array.get(order, minPos))
                array.set(order, minPos, tmp)
        // Greedy bottom-up stack. These labels share one X column, so each only
        // needs to clear the one directly below it in price. One pass, no
        // residual overlap regardless of how many stack up.
        for a = 1 to n - 1
            idx   = array.get(order, a)
            prev  = array.get(order, a - 1)
            yPrev = array.get(ys, prev)
            yi    = array.get(ys, idx)
            if yi - yPrev < minSep
                yi := yPrev + minSep
                array.set(ys, idx, yi)
                label.set_y(array.get(lbs, idx), yi)
        // Three horizontal lanes prevent wide badges from forming one opaque
        // wall when several nearby mitigations resolve at similar prices.
        for a = 0 to n - 1
            idx = array.get(order, a)
            label.set_x(array.get(lbs, idx), baseX + (a % 3) * 14)
    int _ = 0

// Centered zone badge de-collision — sort-and-stack. These badges sit at
// different X positions (each block's mid-bar), so a simple price-only nudge
// would move badges that merely share a level but sit far apart in time, and a
// pairwise push leaves residual overlap in dense (4+) clusters. Instead, badges
// are sorted by price and walked bottom-up: each is lifted to sit at least one
// minimum gap above the highest already-placed badge that is X-close (within
// xGap bars). One pass, no residual overlap, regardless of cluster depth.
// Badges that are far apart in time are never moved.
f_nudgeCentered(array<label> lbs) =>
    n = array.size(lbs)
    if n > 1
        float minSep = 0.6 * atrSafe
        int   xGap   = 40
        array<float> ys    = array.new<float>()
        array<int>   xs    = array.new<int>()
        array<int>   order = array.new<int>()
        for k = 0 to n - 1
            array.push(ys, label.get_y(array.get(lbs, k)))
            array.push(xs, label.get_x(array.get(lbs, k)))
            array.push(order, k)
        // Selection sort 'order' by ascending Y (lowest price first)
        for a = 0 to n - 2
            minPos = a
            for c = a + 1 to n - 1
                if array.get(ys, array.get(order, c)) < array.get(ys, array.get(order, minPos))
                    minPos := c
            if minPos != a
                tmp = array.get(order, a)
                array.set(order, a, array.get(order, minPos))
                array.set(order, minPos, tmp)
        // Greedy bottom-up stack within each X-cluster
        for a = 0 to n - 1
            idx = array.get(order, a)
            yi  = array.get(ys, idx)
            xi  = array.get(xs, idx)
            float floorY = na
            for c = 0 to a - 1
                jdx = array.get(order, c)
                if math.abs(xi - array.get(xs, jdx)) <= xGap
                    yj = array.get(ys, jdx)
                    if na(floorY) or yj > floorY
                        floorY := yj
            if not na(floorY) and yi - floorY < minSep
                yi := floorY + minSep
                array.set(ys, idx, yi)
                label.set_y(array.get(lbs, idx), yi)
    int _ = 0

if barstate.islast
    int lblThresh = f_labelThreshold()
    for ob in bullBlocks
        dominant = not compressNestedBlocks or f_isDominant(ob, bullBlocks)
        if dominant
            allow = ob.mitigationBar >= lblThresh
            f_render(ob, allow)
            f_renderTrail(ob)
            f_renderEntryMark(ob)
        else
            f_hideOB(ob)
    for ob in bearBlocks
        dominant = not compressNestedBlocks or f_isDominant(ob, bearBlocks)
        if dominant
            allow = ob.mitigationBar >= lblThresh
            f_render(ob, allow)
            f_renderTrail(ob)
            f_renderEntryMark(ob)
        else
            f_hideOB(ob)
    // Confluence glow runs BEFORE priceLabel so priceLabel can skip clustered blocks
    f_renderConfluence()
    // Price scale labels — only for blocks NOT in a confluence cluster
    for ob in bullBlocks
        f_renderPriceLabel(ob)
    for ob in bearBlocks
        f_renderPriceLabel(ob)

    // ─────────────────────────────────────────────────────────────────────────
    // Label Y-collision avoidance: includes BOTH mitigation labels (right edge)
    // AND price scale labels (far right). Labels sharing the same X column get
    // sorted by price and nudged apart so their text doesn't overlap.
    // ─────────────────────────────────────────────────────────────────────────

    // Collect price scale labels (bar_index + 40) and run anti-collision
    array<label> priceLabels = array.new<label>()
    for ob in bullBlocks
        if not na(ob.priceLabel)
            array.push(priceLabels, ob.priceLabel)
    for ob in bearBlocks
        if not na(ob.priceLabel)
            array.push(priceLabels, ob.priceLabel)
    f_nudgeCollisions(priceLabels, bar_index + 40)

    // Historical outcome labels keep their event-window X anchor, but nearby
    // labels are vertically separated so dense reaction clusters stay legible.
    array<label> mitigationLabels = array.new<label>()
    for ob in bullBlocks
        if not na(ob.lb)
            array.push(mitigationLabels, ob.lb)
    for ob in bearBlocks
        if not na(ob.lb)
            array.push(mitigationLabels, ob.lb)
    f_nudgeCentered(mitigationLabels)

    // Centered zone badges remain at the exact horizontal and vertical center
    // of the dominant box they explain. Redundant nested boxes are not drawn.

// ─────────────────────────────────────────────────────────────────────────────
// Panel Stats
// ─────────────────────────────────────────────────────────────────────────────
f_computeStats() =>
    int    active        = 0
    int    tested        = 0
    int    success       = 0
    float  nearestDist   = na
    float  nearestScore  = na
    float  nearestInvDist = na
    bool   nearestInside = false
    bool   nearestIsBull = false
    string nearestGrade  = ""
    string nearestState  = "No Active Block"
    float  px            = close

    for ob in bullBlocks
        if not ob.invalidated
            active += 1
            if ob.mitigated
                tested += 1
                if ob.grade == "A" or ob.grade == "B"
                    success += 1
            inside = px >= ob.bot and px <= ob.top
            d = inside ? 0.0 : math.min(math.abs(px - ob.top), math.abs(px - ob.bot))
            if na(nearestDist) or d < nearestDist
                nearestDist   := d
                nearestInside := inside
                nearestIsBull := true
                nearestGrade  := ob.grade
                age           = bar_index - ob.startBar
                agePct        = math.min(100.0, 100.0 * age / obLookback)
                overhit       = ob.hitCount > 2 ? 20.0 : ob.hitCount > 1 ? 10.0 : 0.0
                health        = math.max(0.0, 100.0 - agePct - overhit)
                nearestScore  := na(ob.qualityScore) ? health : ob.qualityScore
                nearestInvDist := math.abs(px - ob.bot)
                nearestState  := ob.lifeState

    for ob in bearBlocks
        if not ob.invalidated
            active += 1
            if ob.mitigated
                tested += 1
                if ob.grade == "A" or ob.grade == "B"
                    success += 1
            inside = px >= ob.bot and px <= ob.top
            d = inside ? 0.0 : math.min(math.abs(px - ob.top), math.abs(px - ob.bot))
            if na(nearestDist) or d < nearestDist
                nearestDist   := d
                nearestInside := inside
                nearestIsBull := false
                nearestGrade  := ob.grade
                age           = bar_index - ob.startBar
                agePct        = math.min(100.0, 100.0 * age / obLookback)
                overhit       = ob.hitCount > 2 ? 20.0 : ob.hitCount > 1 ? 10.0 : 0.0
                health        = math.max(0.0, 100.0 - agePct - overhit)
                nearestScore  := na(ob.qualityScore) ? health : ob.qualityScore
                nearestInvDist := math.abs(px - ob.top)
                nearestState  := ob.lifeState

    [active, tested, success, nearestDist, nearestScore, nearestInside, nearestIsBull, nearestGrade, nearestState, nearestInvDist]

f_last20SuccessRate() =>
    int n = array.size(last20Grades)
    float result = na
    if n > 0
        int good = 0
        for v in last20Grades
            if v >= 2
                good += 1
        result := 100.0 * good / n
    result

// Win/Loss streak — scan last20Grades from the newest backward and count the
// consecutive run of the same outcome class ("Win" = A|B, "Loss" = C).
// Returns [runLength, isWin, sequence string e.g. "A,B,A"]
f_streak() =>
    int   n = array.size(last20Grades)
    int   runLen = 0
    bool  isWin  = true
    string seq   = ""
    if n > 0
        // Determine class of the newest
        latest = array.get(last20Grades, n - 1)
        firstIsWin = latest >= 2
        isWin := firstIsWin
        // Count the consecutive run matching this class, newest-first
        for k = n - 1 to 0
            v      = array.get(last20Grades, k)
            thisIsWin = v >= 2
            if thisIsWin == firstIsWin
                runLen += 1
                letter = v == 3 ? "A" : v == 2 ? "B" : "C"
                seq := seq == "" ? letter : letter + "," + seq
            else
                break
    [runLen, isWin, seq]

// ─────────────────────────────────────────────────────────────────────────────
// Panel helpers
// ─────────────────────────────────────────────────────────────────────────────

// Last 20 breakdown — returns "A:6 B:7 C:7" style summary
f_last20Breakdown() =>
    int a = 0
    int b = 0
    int c = 0
    for v in last20Grades
        if v == 3
            a += 1
        else if v == 2
            b += 1
        else if v == 1
            c += 1
    int tot = a + b + c
    tot == 0 ? "no data yet" : "A:" + str.tostring(a) + " B:" + str.tostring(b) + " C:" + str.tostring(c)

// Last 20 breakdown color — semantic based on grade mix
f_last20BreakdownColor() =>
    int a = 0
    int b = 0
    int c = 0
    for v in last20Grades
        if v == 3
            a += 1
        else if v == 2
            b += 1
        else if v == 1
            c += 1
    int tot = a + b + c
    color result = pLabel
    if tot == 0
        result := pLabel
    else if a >= b + c           // Grade A dominant = best regime
        result := bullColor
    else if a + b >= c           // A+B combined majority = neutral-positive
        result := neutralColor
    else                         // Grade C heavy = weak regime
        result := bearColor
    result

// Setup banner string — describes current price-block relationship
f_setupBanner(bool inside, float dAtr, bool isBull, string grade) =>
    if na(dAtr)
        "No active blocks"
    else
        side  = isBull ? "Demand" : "Supply"
        gtxt  = grade == "" ? "Active" : "Grade " + grade
        if inside
            "Inside " + gtxt + " " + side
        else if dAtr < 0.2
            "Touching " + gtxt + " " + side
        else if dAtr < 1.0
            "Approaching " + gtxt + " " + side
        else
            "Clear of " + gtxt + " " + side

f_setupBannerColor(bool inside, float dAtr, bool isBull, string grade) =>
    // Grade A = vivid, others muted. Inside/touching is hotter.
    base = isBull ? bullColor : bearColor
    if na(dAtr)
        pLabel
    else if inside or dAtr < 0.2
        grade == "A" ? base : neutralColor
    else if dAtr < 1.0
        color.new(base, 30)
    else
        pLabel

// ─────────────────────────────────────────────────────────────────────────────
// Panel Render
// ─────────────────────────────────────────────────────────────────────────────
var table panel = na

if barstate.islast and showPanel
    // Panel dimensions: 2 cols, 12 rows max
    //   0 header (merged)
    //   1 mitigation state / 2 block quality / 3 defense / 4 invalidation
    //   5 action / 6 recent quality / 7 active+tested / 8 A/B ratio
    //   9 streak / 10 HTF alignment / 11 setup banner (merged)
    if na(panel)
        panel := table.new(f_panelPos(panelLocation), 2, 12,
             bgcolor      = pBg,
             border_color = pBorder,
             border_width = 1,
             frame_color  = pBorder,
             frame_width  = 1)

    [active, tested, success, nearestDist, nearestScore, nearestInside, nearestIsBull, nearestGrade, nearestState, nearestInvDist] = f_computeStats()
    float sr20 = f_last20SuccessRate()
    int   totalMits = totalA + totalB + totalC
    float srAll = totalMits == 0 ? na : 100.0 * (totalA + totalB) / totalMits
    float distAtrN  = na(nearestDist) ? na : nearestDist / atrSafe
    float invAtrN = na(nearestInvDist) ? na : nearestInvDist / atrSafe
    [streakRun, streakIsWin, streakSeq] = f_streak()
    stateIsStrong = nearestState == "Clean Mitigation" or nearestState == "Defended"
    stateIsWeak = nearestState == "Weak Reaction" or nearestState == "Invalidated"
    stateCol = nearestState == "No Active Block" ? pLabel : stateIsStrong ? bullColor : stateIsWeak ? bearColor : neutralColor
    scoreCol = na(nearestScore) ? pValue : nearestScore >= minQualityScore ? bullColor : nearestScore >= 50 ? neutralColor : bearColor
    sideTxt = na(nearestDist) ? "" : nearestIsBull ? "Demand" : "Supply"
    stateTxt = nearestState == "No Active Block" ? "No Active Block" : sideTxt + " / " + nearestState
    defenseTxt = na(nearestDist) ? "No active rail" : nearestInside ? "Testing Defense" : distAtrN < 0.35 ? "Near Defense" : "Outside Zone"
    defenseCol = na(nearestDist) ? pLabel : nearestInside ? neutralColor : distAtrN < 0.35 ? accentColor : pValue
    invTxt = na(invAtrN) ? "-" : str.tostring(invAtrN, "#.##") + " ATR"
    invCol = na(invAtrN) ? pValue : invAtrN < 0.35 ? bearColor : invAtrN < 1.00 ? neutralColor : accentColor
    actionTxt = na(nearestDist) ? "Wait for block" :
         stateIsStrong and nearestScore >= minQualityScore ? "Manage defense" :
         nearestInside ? "Review reaction" :
         distAtrN < 0.75 ? "Prepare review" :
         nearestState == "Weak Reaction" ? "Wait for reset" : "Observe"

    // Row 0 — merged blue header
    table.cell(panel, 0, 0, "AG Pro Mitigation Block Quality",
         text_color  = headerText,
         bgcolor     = headerBg,
         text_size   = pTextSize,
         text_halign = text.align_center)
    table.cell(panel, 1, 0, "",
         text_color  = headerText,
         bgcolor     = headerBg,
         text_size   = pTextSize)
    table.merge_cells(panel, 0, 0, 1, 0)

    // Row 1 - mitigation lifecycle state
    table.cell(panel, 0, 1, "Mitigation State",
         text_color = pLabel, bgcolor = pBg, text_size = pTextSize, text_halign = text.align_left,
         tooltip = "Lifecycle state of the nearest active mitigation block: partial, full, clean, defended, weak, or invalidated.")
    table.cell(panel, 1, 1, stateTxt,
         text_color = stateCol, bgcolor = pBg, text_size = pTextSize, text_halign = text.align_right)

    // Row 2 - 0-100 block quality
    scoreTxt = na(nearestScore) ? "-" : str.tostring(nearestScore, "#") + "/100"
    table.cell(panel, 0, 2, "Block Quality",
         text_color = pLabel, bgcolor = pBg, text_size = pTextSize, text_halign = text.align_left,
         tooltip = "Planner score from mitigation depth, reaction strength, block width, hit count, and time decay. Higher values mean cleaner mitigation quality.")
    table.cell(panel, 1, 2, scoreTxt,
         text_color = scoreCol, bgcolor = pBg, text_size = pTextSize, text_halign = text.align_right)

    // Row 3 - defense rail status
    table.cell(panel, 0, 3, "Defense",
         text_color = pLabel, bgcolor = pBg, text_size = pTextSize, text_halign = text.align_left,
         tooltip = "Shows whether price is inside, near, or away from the active defense rail of the nearest mitigation block.")
    table.cell(panel, 1, 3, defenseTxt,
         text_color = defenseCol, bgcolor = pBg, text_size = pTextSize, text_halign = text.align_right)

    // Row 4 - invalidation distance
    table.cell(panel, 0, 4, "Invalidation",
         text_color = pLabel, bgcolor = pBg, text_size = pTextSize, text_halign = text.align_left,
         tooltip = "ATR-normalized distance from price to the active invalidation edge. It is a planning reference, not a trading instruction.")
    table.cell(panel, 1, 4, invTxt,
         text_color = invCol, bgcolor = pBg, text_size = pTextSize, text_halign = text.align_right)

    // Row 5 - next action state
    table.cell(panel, 0, 5, "Action",
         text_color = pLabel, bgcolor = pBg, text_size = pTextSize, text_halign = text.align_left,
         tooltip = "Next review state derived from the mitigation lifecycle. Alerts are attention markers, not trade instructions.")
    table.cell(panel, 1, 5, actionTxt,
         text_color = scoreCol, bgcolor = pBg, text_size = pTextSize, text_halign = text.align_right)

    // Row 6 - recent mitigation mix
    bdStr = showHeatmapBar ? f_last20Breakdown() : "Hidden"
    bdCol = showHeatmapBar ? f_last20BreakdownColor() : pLabel
    table.cell(panel, 0, 6, "Recent Quality",
         text_color = pLabel, bgcolor = pBg, text_size = pTextSize, text_halign = text.align_left)
    table.cell(panel, 1, 6, bdStr,
         text_color = bdCol, bgcolor = pBg, text_size = pTextSize, text_halign = text.align_right)

    // Row 7 - active / tested count
    table.cell(panel, 0, 7, "Active / Tested",
         text_color = pLabel, bgcolor = pBg, text_size = pTextSize, text_halign = text.align_left)
    table.cell(panel, 1, 7, str.tostring(active) + " / " + str.tostring(tested),
         text_color = pValue, bgcolor = pBg, text_size = pTextSize, text_halign = text.align_right)

    // Row 8 - current success ratio
    srAllStr = na(srAll) ? "-" : str.tostring(srAll, "#") + "%"
    srAllCol = na(srAll) ? pValue : srAll >= 60 ? bullColor : srAll >= 40 ? neutralColor : bearColor
    table.cell(panel, 0, 8, "A/B Ratio",
         text_color = pLabel, bgcolor = pBg, text_size = pTextSize, text_halign = text.align_left,
         tooltip = "Share of graded mitigations that resolved as Grade A or Grade B in the current session memory.")
    table.cell(panel, 1, 8, srAllStr,
         text_color = srAllCol, bgcolor = pBg, text_size = pTextSize, text_halign = text.align_right)

    // Row 9 — current streak of grade outcomes (Wins or Losses)
    if showStreak
        stkLabel = streakRun == 0 ? "Streak" :
                     (streakIsWin ? "Streak Wins (" : "Streak Losses (") + streakSeq + ")"
        stkVal   = streakRun == 0 ? "—" : str.tostring(streakRun)
        stkCol   = streakRun == 0 ? pValue :
                     streakIsWin ? (streakRun >= 3 ? bullColor : neutralColor) :
                                   (streakRun >= 3 ? bearColor : neutralColor)
        table.cell(panel, 0, 9, stkLabel,
             text_color = pLabel, bgcolor = pBg, text_size = pTextSize, text_halign = text.align_left,
             tooltip    = "Consecutive run of mitigation outcomes starting from the most recent. Wins = Grade A/B, Losses = Grade C. A long win streak indicates strong structure respect; a long loss streak indicates deteriorating setups.")
        table.cell(panel, 1, 9, stkVal,
             text_color = stkCol, bgcolor = pBg, text_size = pTextSize, text_halign = text.align_right)
    else
        table.cell(panel, 0, 9, "", bgcolor = pBg, text_size = pTextSize)
        table.cell(panel, 1, 9, "", bgcolor = pBg, text_size = pTextSize)

    // Row 10 — HTF alignment (merged)
    if showHtfConfluence
        // current TF nearest side: +1 bull, -1 bear, 0 none
        int curSide = na(nearestDist) ? 0 : (nearestIsBull ? 1 : -1)
        aligned  = curSide != 0 and htfBias != 0 and curSide == htfBias
        string htfTxt = ""
        color  htfCol = pLabel
        color  htfBg  = pBg
        if curSide == 0 or htfBias == 0
            htfTxt := "HTF Align: —"
            htfCol := pLabel
        else if aligned
            dir    = curSide == 1 ? "Bullish" : "Bearish"
            htfTxt := "HTF Aligned: " + dir
            htfCol := curSide == 1 ? bullColor : bearColor
            htfBg  := color.new(htfCol, 82)
        else
            ctf = curSide == 1 ? "Bullish" : "Bearish"
            htf = htfBias == 1 ? "Bullish" : "Bearish"
            htfTxt := "HTF Conflict: " + ctf + " vs " + htf
            htfCol := neutralColor
        table.cell(panel, 0, 10, "HTF Context",
             text_color  = pLabel,
             bgcolor     = pBg,
             text_size   = pTextSize,
             text_halign = text.align_left,
             tooltip     = "Compares the nearest block's side on the current chart with the structural bias of the higher timeframe (" + htfTimeframe + ").")
        table.cell(panel, 1, 10, htfTxt,
             text_color  = htfCol,
             bgcolor     = htfBg,
             text_size   = pTextSize,
             text_halign = text.align_right)
    else
        table.cell(panel, 0, 10, "", bgcolor = pBg, text_size = pTextSize)
        table.cell(panel, 1, 10, "", bgcolor = pBg, text_size = pTextSize)

    // Row 11 — current setup banner (merged)
    if showSetupBanner
        banTxt = f_setupBanner(nearestInside, distAtrN, nearestIsBull, nearestGrade)
        banCol = f_setupBannerColor(nearestInside, distAtrN, nearestIsBull, nearestGrade)
        banBg  = nearestInside or (not na(distAtrN) and distAtrN < 0.2) ?
                     color.new(banCol, 85) : color.new(pBorder, 50)
        table.cell(panel, 0, 11, "Setup",
             text_color  = pLabel,
             bgcolor     = pBg,
             text_size   = pTextSize,
             text_halign = text.align_left,
             tooltip     = "Dynamic description of the current price-block relationship.")
        table.cell(panel, 1, 11, banTxt,
             text_color  = banCol,
             bgcolor     = banBg,
             text_size   = pTextSize,
             text_halign = text.align_right)
    else
        table.cell(panel, 0, 11, "", bgcolor = pBg, text_size = pTextSize)
        table.cell(panel, 1, 11, "", bgcolor = pBg, text_size = pTextSize)

if barstate.islast and not showPanel and not na(panel)
    table.delete(panel)
    panel := na

// ─────────────────────────────────────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(confirmedNow and readyEvent == 1 and alertOnReady, "Mitigation READY",
     "Mitigation Block Quality marked a READY mitigation review state on {{ticker}} {{interval}}")
alertcondition(confirmedNow and shiftEvent == 1 and alertOnShift, "Mitigation State Shift",
     "Mitigation Block Quality confirmed a lifecycle state shift on {{ticker}} {{interval}}")
alertcondition(confirmedNow and followEvent == 1 and alertOnFollow, "Major Mitigation Follow-Through",
     "Mitigation Block Quality confirmed high-quality mitigation follow-through on {{ticker}} {{interval}}")
alertcondition(confirmedNow and gradeAEvent == 1 and alertOnA,  "Grade A Mitigation",
     "Premium (Grade A) mitigation detected on {{ticker}} {{interval}}")
alertcondition(confirmedNow and gradeBEvent == 1 and alertOnB,  "Grade B Mitigation",
     "Solid (Grade B) mitigation detected on {{ticker}} {{interval}}")
alertcondition(confirmedNow and invEvent == 1 and alertOnInv,   "Block Invalidation",
     "Mitigation block invalidated on {{ticker}} {{interval}}")
````

# Volume Expansion Breakout Planner [AGPro Series]

- url: https://www.tradingview.com/script/md5hsTEP-Volume-Expansion-Breakout-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;a9fc701d5e3d4c90bd4f135ed8cd3c75
- version: 4.0

## Description

Volume Expansion Breakout Planner [AGPro Series]

🧠 Core Idea

After a breakout, is volume expanding in a constructive path, or is the move losing participation and acceptance?


📌 Overview / What it does

Volume Expansion Breakout Planner [AGPro Series] is a chart-first breakout planning tool built around post-breakout participation quality.

Instead of judging only the breakout candle, the script maps the broken reference level, draws an acceptance band, monitors relative volume after the break, tracks whether price holds the path, and converts the full sequence into a 0-100 quality score.

The output includes compact breakout path labels, volume expansion labels, hold labels, failed-volume labels, an invalidation rail, a room or review guide, and a clean AGPro decision panel. It does not predict price, automate entries, or issue trade commands.


🎯 Purpose & Design Philosophy

This script was built to fill the gap between simple breakout markers and full trade-management tools.

Many breakouts look strong on the first candle but quickly lose participation. Others start quietly and become stronger as post-break volume expands. This tool is designed for traders who want to evaluate that path with structure, not emotion.

The mindset is planning-first: identify the breakout reference, evaluate volume expansion, check acceptance, respect invalidation, and decide whether the path deserves continued attention.


⚡ Why This Script Is Different

Most breakout tools focus on the first break beyond a level.

This script does NOT try to clone a standard breakout volume confirmation tool, a Darvas breakout system, a triangle breakout scanner, or a generic support/resistance map.

Instead, it focuses on the post-break volume expansion path: what happens after the level breaks, whether volume remains constructive, whether price accepts the broken area, and whether the path becomes suspicious or failed.


⚙️ Methodology

1. Context Detection
The script builds a prior price structure from a configurable lookback and identifies the upper and lower breakout references.

2. Reference Mapping
When price closes beyond the reference by an ATR-normalized buffer, the script starts a breakout path and draws the broken level, acceptance band, invalidation rail, and a room or review guide.

3. Reaction Evaluation
The model evaluates relative volume, candle efficiency, close location, breakout distance, trend alignment, range quality, post-break participation, progress, acceptance, and failure behavior.

4. Visual Output
The chart displays compact path labels, volume expansion labels, accepted-path labels, failed-volume labels, and a premium AGPro panel summarizing the current decision state.


🗺️ How to Read the Chart

Zones = the acceptance band around the broken level. Its text changes by state, such as BULL PATH REVIEW, ACCEPTED BULL PATH, or FAILED BEAR PATH.

Labels = compact path state markers such as UP, DN, VOL+, HOLD, FAIL, WATCH UP, and WATCH DN. Label scores can be enabled from settings if the user wants more detail.

Colors = teal for constructive bullish paths, pink for constructive bearish paths, yellow for watch or caution states, indigo for room or review guide emphasis, and muted gray for expired paths.

Panel = the current breakout side, volume expansion state, acceptance state, quality score, and next action.


🚦 Signals & States

• UP → a bullish breakout path has started.

• DN → a bearish breakout path has started.

• VOL+ → post-break volume is expanding with directional follow-through.

• HOLD → the path held beyond the acceptance band with constructive volume.

• FAIL → the path returned into weak-volume or invalidation conditions.

• WATCH UP / WATCH DN → optional approach labels when price is near a breakout reference while relative volume is building.


🔔 Alerts Logic

Alerts trigger when a high-quality bullish or bearish volume expansion path starts, when post-break volume expands, when the path becomes accepted, or when failed-volume conditions appear.

These alerts are attention markers for chart review. They are not trade instructions.


🧩 Confluence Logic

The strongest readings usually occur when the breakout closes cleanly beyond the reference, relative volume expands above baseline, candle structure is efficient, trend alignment supports the side, and price later accepts the broken area.

When these conditions align, the quality score improves and the next-action state becomes more constructive.


📊 When to Use

• Breakout continuation review

• Range exits where volume quality matters

• Post-break acceptance monitoring

• Breakouts that need a clear invalidation reference

• Multi-symbol review where traders need fast path-quality comparison


⚠️ When NOT to Use

• Low-liquidity symbols with unreliable volume

• Markets with irregular session volume or distorted feeds

• Extremely choppy periods where every break returns inside the prior structure

• Events driven by abnormal news volatility where technical volume baselines become less stable


🎛️ Key Inputs

• Breakout Lookback → controls the prior structure used for breakout references.

• Break Buffer ATR → defines how far price must close beyond the level.

• Volume Baseline Length → controls the relative volume baseline.

• Expansion RVOL Threshold → defines the required volume expansion for strong pulses.

• Minimum Planner Score → controls how selective the main path states are.

• Acceptance Band ATR → controls the decision zone around the broken level.

• Invalidation Rail ATR → controls the structural failure reference.

• Panel / Label Settings → control location, theme, font size, label scores, optional watch labels, and label density.


🖥️ Interface & Visual Design

The interface is built for fast chart reading.

The acceptance band is the main visual anchor. The breakout line, invalidation rail, and room or review guide create a compact planning map without filling the chart with generic zones. Labels are short, shifted slightly away from the candle, and capped by user settings.

The AGPro panel follows the publication standard with a single merged blue header row containing only the script name.


🧪 Practical Usage Workflow

1. Read the panel to see whether a breakout path is active.

2. Check the acceptance band and broken level.

3. Evaluate whether volume is expanding or fading.

4. Watch for ACCEPTED or FAILED VOL states.

5. Use the invalidation rail and room or review guide as planning references within broader market context.


🔍 Interpretation Guidelines

Read the score as a structured quality model, not as certainty.

A higher score means the path has cleaner participation, stronger candle structure, better close quality, better trend alignment, and stronger acceptance behavior according to the script's rules.

A lower score means the path is weaker, less accepted, or more vulnerable to failed-volume behavior.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not auto trading

• Not guaranteed signals

• Not a complete trading system

• Not a generic buy/sell indicator


⚠️ Limitations & Transparency

Volume quality depends on the reliability of the TradingView volume feed for the selected symbol.

Different timeframes can produce different breakout references and acceptance behavior.

High-volatility news periods, low-liquidity markets, and irregular session activity can reduce the usefulness of relative volume baselines.

The script is rule-based and should be interpreted alongside broader context.


🧠 Market Context Notes

Volume expansion is most useful when it is connected to structure.

The broken level matters because it gives the move a reference. The acceptance band matters because it shows whether the market is holding that reference. The invalidation rail matters because it defines when the path has lost structural quality.


🧾 Use Case Examples

When price breaks above a prior range with strong RVOL and later holds the acceptance band, the path may remain constructive.

When price breaks below a range but volume fades and price returns above the broken reference, the path may become suspicious or failed.

When price approaches a reference with building volume but no confirmed break, VOL WATCH keeps the trader aware without turning the tool into a signal board.


🧱 System Philosophy

The script is part of the AGPro planner-style workflow: show the reference, score the context, define invalidation, monitor acceptance, and guide the next review step.


🔐 Non-Promise Statement

No script can guarantee continuation, reversal, or outcome certainty.

This tool organizes breakout-volume context so users can evaluate the chart more clearly.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions, risk management, and market interpretation.

This script is provided for educational and analytical use only and does not provide financial advice.


📚 Educational Note

Use the script to study how post-breakout volume behaves after price leaves a prior structure. The most useful insights often come from comparing accepted paths against failed-volume paths over many examples.

## Source Code

````pine
// -------------------------------------------------
// Volume Expansion Breakout Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Volume Expansion Breakout Planner is a chart-first breakout planning tool
// focused on post-breakout participation quality. It maps breakout reference
// levels, volume expansion, acceptance behavior, invalidation risk, a structured
// 0-100 path quality score and a persistent hold-rate proof layer so traders can
// judge whether a breakout is expanding constructively or becoming suspicious
// after the first release.
// -------------------------------------------------

//@version=6
indicator("Volume Expansion Breakout Planner [AGPro Series]",
     shorttitle = "AG Pro VEB",
     overlay = true,
     max_labels_count = 500,
     max_lines_count = 100,
     max_boxes_count = 50)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
color headerBg      = color.rgb(37, 99, 235)
color headerText    = color.rgb(245, 247, 250)
color panelBg       = color.rgb(15, 23, 42)
color panelBorder   = color.rgb(51, 65, 85)
color panelLabelCol = color.rgb(148, 163, 184)
color panelValueCol = color.rgb(226, 232, 240)
color bullColor     = color.rgb(34, 197, 166)
color bearColor     = color.rgb(244, 114, 182)
color neutralColor  = color.rgb(245, 189, 92)
color accentColor   = color.rgb(129, 140, 248)
color darkText      = color.rgb(17, 24, 39)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupStructure = "1. Breakout Structure"
int lookbackInput = input.int(34, "Breakout Lookback", minval = 10, maxval = 200, group = groupStructure, tooltip = "Defines the prior structure window used to locate the upper and lower breakout references. The current candle is excluded from this range.")
int atrLengthInput = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupStructure, tooltip = "Controls volatility normalization for breakout buffers, acceptance bands, invalidation rails, and label offsets.")
float breakBufferAtrInput = input.float(0.18, "Break Buffer ATR", minval = 0.02, maxval = 1.50, step = 0.01, group = groupStructure, tooltip = "Requires the close to finish beyond the breakout reference by this ATR fraction before a path can start.")
float minRangeAtrInput = input.float(0.70, "Minimum Range Height ATR", minval = 0.10, maxval = 5.00, step = 0.05, group = groupStructure, tooltip = "Filters out structures that are too flat to provide a meaningful post-breakout path.")
float maxRangeAtrInput = input.float(6.00, "Maximum Range Height ATR", minval = 1.00, maxval = 20.00, step = 0.25, group = groupStructure, tooltip = "Filters out overly wide structures where breakout planning quality becomes less precise.")

string groupVolume = "2. Volume Expansion Path"
int volumeLengthInput = input.int(30, "Volume Baseline Length", minval = 5, maxval = 200, group = groupVolume, tooltip = "Defines the moving average baseline used for relative volume expansion.")
float expansionRvolInput = input.float(1.45, "Expansion RVOL Threshold", minval = 0.80, maxval = 5.00, step = 0.05, group = groupVolume, tooltip = "Relative volume required for a strong expansion pulse after the breakout path starts.")
float sustainRvolInput = input.float(1.15, "Sustained RVOL Threshold", minval = 0.70, maxval = 4.00, step = 0.05, group = groupVolume, tooltip = "Smoothed relative volume threshold used to judge whether participation remains constructive after the breakout.")
float weakRvolInput = input.float(0.85, "Weak RVOL Warning", minval = 0.20, maxval = 2.00, step = 0.05, group = groupVolume, tooltip = "When post-breakout participation falls below this level and price returns toward the breakout reference, the path can be marked as suspicious or failed.")
float fullRvolInput = input.float(2.20, "Full RVOL Score Ratio", minval = 1.00, maxval = 6.00, step = 0.10, group = groupVolume, tooltip = "Relative volume ratio that receives the full volume component in the 0-100 quality model.")
int postBreakBarsInput = input.int(18, "Post-Break Path Bars", minval = 5, maxval = 80, group = groupVolume, tooltip = "How many bars the script monitors after a breakout to evaluate expansion, acceptance, suspicion, or failed-volume behavior.")
int acceptanceBarsInput = input.int(3, "Minimum Acceptance Bars", minval = 1, maxval = 20, group = groupVolume, tooltip = "Minimum number of bars after the breakout before the path can be classified as accepted.")

string groupQuality = "3. Planner Quality"
string confirmationModeInput = input.string("Balanced", "Confirmation Mode", options = ["Early", "Balanced", "Strict"], group = groupQuality, tooltip = "Early lowers the score threshold for more path labels. Strict raises the threshold and requires cleaner structure.")
int minimumScoreInput = input.int(64, "Minimum Planner Score", minval = 1, maxval = 100, group = groupQuality, tooltip = "Minimum score for high-quality breakout path states and primary alerts.")
int weakFloorInput = input.int(44, "Weak Path Floor", minval = 1, maxval = 100, group = groupQuality, tooltip = "Lowest breakout score allowed to create a weak or suspicious path label. This keeps the chart active without labeling every minor poke.")
float acceptanceBandAtrInput = input.float(0.36, "Acceptance Band ATR", minval = 0.05, maxval = 2.00, step = 0.01, group = groupQuality, tooltip = "Width of the acceptance band around the broken level. The band is the main post-breakout decision zone.")
float invalidationAtrInput = input.float(0.72, "Invalidation Rail ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupQuality, tooltip = "Distance from the broken level to the invalidation rail. A close through this rail marks the path as structurally failed.")
float pathGuideAtrInput = input.float(1.80, "Expansion Path Guide ATR", minval = 0.50, maxval = 8.00, step = 0.10, group = groupQuality, tooltip = "ATR distance used for the forward path guide. It is a planning reference, not a guaranteed target.")
int trendFastLengthInput = input.int(21, "Fast Trend EMA", minval = 5, maxval = 100, group = groupQuality, tooltip = "Fast EMA used to judge trend alignment in the quality model.")
int trendSlowLengthInput = input.int(55, "Slow Trend EMA", minval = 10, maxval = 200, group = groupQuality, tooltip = "Slow EMA used to judge broader trend alignment in the quality model.")

string groupProof = "4. Confirm-Rate Proof"
int proofWindowInput = input.int(10, "Proof Hold Window Bars", minval = 3, maxval = 120, group = groupProof, tooltip = "Bars a fresh breakout path must hold without closing through its invalidation rail to be counted as a held breakout in the Hold Rate proof statistic.")

string groupVisual = "5. Visual Controls"
bool showAcceptanceBandInput = input.bool(true, "Show Acceptance Band", group = groupVisual, tooltip = "Displays the post-breakout acceptance band as a clean projected zone.")
bool showCenteredBadgeInput = input.bool(true, "Show Centered Zone Badge", group = groupVisual, tooltip = "Shows a separate centered badge inside the acceptance band. This keeps text readable on dark and light chart themes.")
float zoneBadgeAnchorInput = input.float(0.58, "Zone Badge Anchor", minval = 0.20, maxval = 0.80, step = 0.02, group = groupVisual, tooltip = "Controls the horizontal anchor of the centered zone badge between the path start and projected right edge.")
bool showPathGuidesInput = input.bool(true, "Show Breakout / Risk / Path Guides", group = groupVisual, tooltip = "Displays the broken level, invalidation rail, and forward expansion path guide.")
bool showEventLabelsInput = input.bool(true, "Show Event Labels", group = groupVisual, tooltip = "Shows breakout, expansion, acceptance, and failed-volume labels.")
bool showLabelScoresInput = input.bool(false, "Show Label Scores", group = groupVisual, tooltip = "Adds score values to chart labels. The default is off to keep the publication view cleaner.")
bool showWatchLabelsInput = input.bool(false, "Show Volume Watch Labels", group = groupVisual, tooltip = "Shows controlled approach labels when price is near a breakout reference and relative volume is building. The default is off to keep the first view cleaner.")
bool tintCandlesInput = input.bool(true, "Tint Active Path Candles", group = groupVisual, tooltip = "Applies a subtle candle tint while a breakout path is active.")
int labelCooldownInput = input.int(16, "Label Cooldown Bars", minval = 1, maxval = 80, group = groupVisual, tooltip = "Minimum spacing between chart event labels to keep the visual layout readable.")
int maxLabelsInput = input.int(10, "Maximum Visible Labels", minval = 4, maxval = 80, group = groupVisual, tooltip = "Caps retained event labels so the chart stays premium and fast.")
float labelOffsetAtrInput = input.float(0.90, "Label Offset ATR", minval = 0.10, maxval = 5.00, step = 0.05, group = groupVisual, tooltip = "Moves labels away from candle bodies by this ATR fraction.")
float labelLaneSpacingAtrInput = input.float(0.55, "Label Lane Spacing ATR", minval = 0.15, maxval = 2.00, step = 0.05, group = groupVisual, tooltip = "Adds vertical separation between nearby labels printed on the same side of price. This prevents rapid opposite breakout paths from stacking labels over the same candle cluster.")
string labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisual, tooltip = "Controls the size of all chart labels and zone badges. Normal is the publication default.")

string groupPanel = "6. Panel"
bool showPanelInput = input.bool(true, "Show Panel", group = groupPanel, tooltip = "Shows or hides the AGPro decision panel. The default is enabled for publication-ready chart context.")
string panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = "Moves the AGPro decision panel to the preferred chart location.")
string panelThemeInput = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = groupPanel, tooltip = "Switches between premium dark, slate, and clean light panel themes while preserving the merged blue header row.")
string panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel, tooltip = "Controls the font size of the panel text. Normal is the publication default.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_text_on(color bg) =>
    float bright = (color.r(bg) * 299 + color.g(bg) * 587 + color.b(bg) * 114) / 1000
    bright >= 145 ? darkText : headerText

f_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_panel_position(string location) =>
    switch location
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_panel_bg(string theme) =>
    theme == "Clean Light" ? color.rgb(248, 250, 252) : theme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_row_bg(string theme, int row) =>
    color bg = na
    if theme == "Clean Light"
        bg := row % 2 == 0 ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)
    else if theme == "Slate"
        bg := row % 2 == 0 ? color.rgb(30, 41, 59) : color.rgb(24, 34, 56)
    else
        bg := row % 2 == 0 ? color.new(panelBg, 0) : color.rgb(21, 31, 51)
    bg

f_panel_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_grade(float score) =>
    string grade = "E"
    if score >= 85
        grade := "A"
    else if score >= 72
        grade := "B"
    else if score >= 58
        grade := "C"
    else if score >= 44
        grade := "D"
    grade

f_state_color(string state) =>
    switch state
        "Accepted" => bullColor
        "Expanding" => accentColor
        "Fresh Path" => neutralColor
        "Suspicious" => neutralColor
        "Failed Volume" => bearColor
        "Expired" => color.rgb(100, 116, 139)
        => panelLabelCol

f_action_from_state(string state, float score, float threshold) =>
    string actionText = "No active path"
    if state == "Accepted" and score >= threshold
        actionText := "Review continuation"
    else if state == "Expanding"
        actionText := "Watch expansion"
    else if state == "Fresh Path"
        actionText := "Wait for acceptance"
    else if state == "Suspicious"
        actionText := "Check failed volume"
    else if state == "Failed Volume"
        actionText := "Invalidation review"
    else if state == "Expired"
        actionText := "Path expired"
    actionText

f_zone_title(int side, string state) =>
    string sideText = side == 1 ? "Bull" : "Bear"
    string title = sideText + " Path Review"
    if state == "Accepted"
        title := "Accepted " + sideText + " Path"
    else if state == "Failed Volume"
        title := "Failed " + sideText + " Path"
    else if state == "Expanding"
        title := "Expanding " + sideText + " Path"
    else if state == "Expired"
        title := "Expired " + sideText + " Path"
    title

f_guide_text(string state) =>
    state == "Failed Volume" or state == "Suspicious" or state == "Expired" ? "Review Guide" : "Room Guide"

f_event_text(string baseText, float score, bool showScore) =>
    showScore ? baseText + "\n" + str.tostring(score, "#") : baseText

f_score(int side, float level, float atrValue, float rangeHeight, float rvolValue, bool trendAligned, bool trendSoft, float fullRvol, float breakBufferAtr, float minRangeAtr, float maxRangeAtr) =>
    float candleRange = math.max(high - low, syminfo.mintick)
    float bodyEfficiency = math.abs(close - open) / candleRange
    float closeLocation = side == 1 ? (close - low) / candleRange : (high - close) / candleRange
    float breakDistanceAtr = side == 1 ? (close - level) / atrValue : (level - close) / atrValue
    float rangeAtr = rangeHeight / atrValue
    float volScore = f_clamp((rvolValue - 0.85) / math.max(0.10, fullRvol - 0.85) * 25.0, 0.0, 25.0)
    float bodyScore = f_clamp(bodyEfficiency * 18.0, 0.0, 18.0)
    float closeScore = f_clamp(closeLocation * 17.0, 0.0, 17.0)
    float distanceScore = f_clamp(breakDistanceAtr / math.max(0.10, breakBufferAtr * 4.0) * 15.0, 0.0, 15.0)
    float trendScore = trendAligned ? 15.0 : trendSoft ? 8.0 : 2.0
    float rangeFitScore = 10.0
    if rangeAtr < minRangeAtr
        rangeFitScore := f_clamp(rangeAtr / minRangeAtr * 10.0, 0.0, 10.0)
    else if rangeAtr > maxRangeAtr
        rangeFitScore := f_clamp(maxRangeAtr / rangeAtr * 10.0, 0.0, 10.0)
    math.round(f_clamp(volScore + bodyScore + closeScore + distanceScore + trendScore + rangeFitScore, 0.0, 100.0))

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_panel_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_size(fontSize))
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_size(fontSize), text_halign = text.align_right)

f_push_label(label[] labels, label newLabel, int maxCount) =>
    array.push(labels, newLabel)
    if array.size(labels) > maxCount
        label.delete(array.shift(labels))

// -------------------------------------------------
// Core Calculations
// -------------------------------------------------
float atr = ta.atr(atrLengthInput)
float safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
float volBase = ta.sma(nz(volume), volumeLengthInput)
float rvol = volBase > 0 ? nz(volume) / volBase : 1.0
float rvolSmooth = ta.sma(rvol, 3)
float emaFast = ta.ema(close, trendFastLengthInput)
float emaSlow = ta.ema(close, trendSlowLengthInput)

float rangeHigh = ta.highest(high[1], lookbackInput)
float rangeLow = ta.lowest(low[1], lookbackInput)
float rangeHeight = rangeHigh - rangeLow
bool rangeReady = not na(rangeHigh) and not na(rangeLow) and rangeHeight > syminfo.mintick
float breakBuffer = safeAtr * breakBufferAtrInput

bool bullTrendAligned = emaFast > emaSlow and close > emaFast
bool bearTrendAligned = emaFast < emaSlow and close < emaFast
bool bullTrendSoft = emaFast >= emaSlow or close > emaFast
bool bearTrendSoft = emaFast <= emaSlow or close < emaFast

bool bullBreak = rangeReady and close > rangeHigh + breakBuffer and close[1] <= rangeHigh + breakBuffer
bool bearBreak = rangeReady and close < rangeLow - breakBuffer and close[1] >= rangeLow - breakBuffer

float bullScore = bullBreak ? f_score(1, rangeHigh, safeAtr, rangeHeight, rvol, bullTrendAligned, bullTrendSoft, fullRvolInput, breakBufferAtrInput, minRangeAtrInput, maxRangeAtrInput) : na
float bearScore = bearBreak ? f_score(-1, rangeLow, safeAtr, rangeHeight, rvol, bearTrendAligned, bearTrendSoft, fullRvolInput, breakBufferAtrInput, minRangeAtrInput, maxRangeAtrInput) : na
float modeAdjustment = confirmationModeInput == "Early" ? -8.0 : confirmationModeInput == "Strict" ? 8.0 : 0.0
float activeThreshold = f_clamp(minimumScoreInput + modeAdjustment, 1.0, 100.0)

// -------------------------------------------------
// Active Path State
// -------------------------------------------------
var int activeSide = 0
var int activeStartBar = na
var float activeLevel = na
var float activeAtr = na
var float activeBaseScore = na
var float activeInvalidation = na
var float activePathGuide = na
var bool activeAccepted = false
var bool activeFailed = false
var string activeState = "No Active Path"

var box acceptanceBox = na
var line breakoutLine = na
var line invalidationLine = na
var line pathGuideLine = na
var label zoneBadge = na
var label guideLabel = na
var label[] eventLabels = array.new_label()
var int lastEventLabelBar = na
var int lastWatchLabelBar = na
var int[] recentPlacementBars = array.new_int()
var int[] recentPlacementSides = array.new_int()
var int[] recentPlacementLanes = array.new_int()

f_next_label_lane(int currentBar, int placementSide) =>
    int nextLane = 0
    int collisionWindow = math.max(4, int(math.round(labelCooldownInput * 0.65)))
    if array.size(recentPlacementBars) > 0
        for i = 0 to array.size(recentPlacementBars) - 1
            int priorBar = array.get(recentPlacementBars, i)
            int priorSide = array.get(recentPlacementSides, i)
            int priorLane = array.get(recentPlacementLanes, i)
            if placementSide == priorSide and currentBar - priorBar <= collisionWindow
                nextLane := math.max(nextLane, priorLane + 1)
    nextLane := math.min(nextLane, 3)
    array.push(recentPlacementBars, currentBar)
    array.push(recentPlacementSides, placementSide)
    array.push(recentPlacementLanes, nextLane)
    while array.size(recentPlacementBars) > 24
        array.shift(recentPlacementBars)
        array.shift(recentPlacementSides)
        array.shift(recentPlacementLanes)
    nextLane

// Hold-rate proof state
var bool proofPending = false
var int proofDir = 0
var float proofInvalid = na
var int proofStartBar = na
var int proofTotal = 0
var int proofWin = 0

bool highQualityBullBreak = bullBreak and bullScore >= activeThreshold
bool highQualityBearBreak = bearBreak and bearScore >= activeThreshold
bool trackBullBreak = bullBreak and bullScore >= weakFloorInput
bool trackBearBreak = bearBreak and bearScore >= weakFloorInput
int candidateSide = trackBullBreak ? 1 : trackBearBreak ? -1 : 0
int sameSideCooldownBars = math.max(acceptanceBarsInput + 2, int(math.round(postBreakBarsInput * 0.65)))
bool newPathAllowed = candidateSide != 0 and (activeSide == 0 or activeSide != candidateSide or na(activeStartBar) or bar_index - activeStartBar > sameSideCooldownBars)
bool newPath = candidateSide != 0 and newPathAllowed

if newPath
    activeSide := candidateSide
    activeStartBar := bar_index
    activeLevel := activeSide == 1 ? rangeHigh : rangeLow
    activeAtr := safeAtr
    activeBaseScore := activeSide == 1 ? bullScore : bearScore
    activeInvalidation := activeLevel - activeSide * activeAtr * invalidationAtrInput
    activePathGuide := activeLevel + activeSide * activeAtr * pathGuideAtrInput
    activeAccepted := false
    activeFailed := false
    activeState := activeBaseScore < activeThreshold ? "Suspicious" : "Fresh Path"

    if not na(acceptanceBox)
        box.delete(acceptanceBox)
    if not na(breakoutLine)
        line.delete(breakoutLine)
    if not na(invalidationLine)
        line.delete(invalidationLine)
    if not na(pathGuideLine)
        line.delete(pathGuideLine)
    if not na(zoneBadge)
        label.delete(zoneBadge)
    if not na(guideLabel)
        label.delete(guideLabel)

    int rightEdge = bar_index + postBreakBarsInput
    float bandTop = activeLevel + activeAtr * acceptanceBandAtrInput
    float bandBottom = activeLevel - activeAtr * acceptanceBandAtrInput
    float bandMid = math.avg(bandTop, bandBottom)
    int badgeX = int(math.round(bar_index + (rightEdge - bar_index) * zoneBadgeAnchorInput))
    color pathColor = activeSide == 1 ? bullColor : bearColor
    string zoneText = f_zone_title(activeSide, activeState) + "\n" + str.tostring(activeBaseScore, "#") + " / 100 " + f_grade(activeBaseScore)

    if showAcceptanceBandInput
        acceptanceBox := box.new(left = bar_index, top = bandTop, right = rightEdge, bottom = bandBottom, xloc = xloc.bar_index, bgcolor = color.new(pathColor, 88), border_color = color.new(pathColor, 28), border_width = 1)
    if showCenteredBadgeInput and showAcceptanceBandInput
        zoneBadge := label.new(x = badgeX, y = bandMid, text = zoneText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(pathColor, 6), textcolor = f_text_on(pathColor), size = f_size(labelSizeInput), textalign = text.align_center)
    if showPathGuidesInput
        breakoutLine := line.new(x1 = bar_index, y1 = activeLevel, x2 = rightEdge, y2 = activeLevel, xloc = xloc.bar_index, extend = extend.none, color = color.new(pathColor, 0), width = 2)
        invalidationLine := line.new(x1 = bar_index, y1 = activeInvalidation, x2 = rightEdge, y2 = activeInvalidation, xloc = xloc.bar_index, extend = extend.none, color = color.new(bearColor, 10), width = 1, style = line.style_dotted)
        pathGuideLine := line.new(x1 = bar_index, y1 = activePathGuide, x2 = rightEdge, y2 = activePathGuide, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 12), width = 1, style = line.style_dashed)
        guideLabel := label.new(x = rightEdge, y = activePathGuide, text = f_guide_text(activeState), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 10), textcolor = f_text_on(accentColor), size = f_size(labelSizeInput))

    if showEventLabelsInput
        int labelX = bar_index + 1
        int placementSide = activeSide
        int labelLane = f_next_label_lane(bar_index, placementSide)
        float laneOffset = labelOffsetAtrInput + labelLane * labelLaneSpacingAtrInput
        float labelY = placementSide == 1 ? low - safeAtr * laneOffset : high + safeAtr * laneOffset
        string labelPrefix = activeSide == 1 ? "Breakout Up" : "Breakout Down"
        if activeBaseScore < activeThreshold
            labelPrefix := activeSide == 1 ? "Weak Up" : "Weak Down"
        string labelText = f_event_text(labelPrefix, activeBaseScore, showLabelScoresInput)
        color labelColor = activeBaseScore >= activeThreshold ? pathColor : neutralColor
        label eventLabel = label.new(x = labelX, y = labelY, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = activeSide == 1 ? label.style_label_up : label.style_label_down, color = color.new(labelColor, 8), textcolor = f_text_on(labelColor), size = f_size(labelSizeInput), textalign = text.align_center)
        f_push_label(eventLabels, eventLabel, maxLabelsInput)
        lastEventLabelBar := bar_index

// Arm the hold proof when a fresh breakout path is confirmed
if newPath and barstate.isconfirmed
    proofPending := true
    proofDir := activeSide
    proofInvalid := activeInvalidation
    proofStartBar := bar_index

// Resolve the hold proof: closing through the invalidation rail within the window
// is a non-hold; holding the rail through the window counts as a held breakout.
if proofPending and barstate.isconfirmed and bar_index > proofStartBar
    bool pInval = proofDir == 1 ? close < proofInvalid : close > proofInvalid
    bool pHeld = bar_index - proofStartBar >= proofWindowInput
    if pInval
        proofTotal += 1
        proofPending := false
    else if pHeld
        proofTotal += 1
        proofWin += 1
        proofPending := false

float holdRate = proofTotal > 0 ? 100.0 * proofWin / proofTotal : na

bool pathActive = activeSide != 0 and not na(activeLevel) and not na(activeAtr)
int barsActive = pathActive ? bar_index - activeStartBar : na
float activeBandTop = pathActive ? activeLevel + activeAtr * acceptanceBandAtrInput : na
float activeBandBottom = pathActive ? activeLevel - activeAtr * acceptanceBandAtrInput : na
bool closeRightSide = pathActive and (activeSide == 1 ? close > activeBandTop : close < activeBandBottom)
bool returnedInside = pathActive and (activeSide == 1 ? close < activeLevel : close > activeLevel)
bool invalidatedPath = pathActive and (activeSide == 1 ? close < activeInvalidation : close > activeInvalidation)
bool directionalBar = pathActive and (activeSide == 1 ? close > open and close >= close[1] : close < open and close <= close[1])
bool volumeSustained = pathActive and rvolSmooth >= sustainRvolInput
bool expansionPulse = pathActive and barsActive > 0 and barsActive <= postBreakBarsInput and rvol >= expansionRvolInput and directionalBar and closeRightSide and not activeFailed
bool acceptedNow = pathActive and not activeAccepted and not activeFailed and barsActive >= acceptanceBarsInput and closeRightSide and volumeSustained
bool failedNow = pathActive and not activeFailed and barsActive > 0 and (invalidatedPath or (returnedInside and rvolSmooth <= weakRvolInput) or (barsActive >= acceptanceBarsInput and not closeRightSide and rvolSmooth < sustainRvolInput and rvol <= weakRvolInput))
bool expiredPath = pathActive and not activeFailed and not activeAccepted and barsActive > postBreakBarsInput

float progressAtr = pathActive ? activeSide * (close - activeLevel) / activeAtr : 0.0
float volumePathAdj = pathActive ? f_clamp((rvolSmooth - 0.85) / math.max(0.10, sustainRvolInput - 0.85) * 10.0, -8.0, 12.0) : 0.0
float progressAdj = pathActive ? f_clamp(progressAtr / math.max(0.50, pathGuideAtrInput) * 12.0, -12.0, 12.0) : 0.0
float acceptanceAdj = activeAccepted ? 10.0 : closeRightSide ? 5.0 : returnedInside ? -12.0 : 0.0
float failureAdj = activeFailed or invalidatedPath ? -32.0 : 0.0
float pathScore = pathActive ? math.round(f_clamp(activeBaseScore + volumePathAdj + progressAdj + acceptanceAdj + failureAdj, 0.0, 100.0)) : na

if acceptedNow
    activeAccepted := true
    activeState := "Accepted"
else if failedNow
    activeFailed := true
    activeState := "Failed Volume"
else if expiredPath
    activeState := "Expired"
else if pathActive
    if activeFailed
        activeState := "Failed Volume"
    else if activeAccepted
        activeState := "Accepted"
    else if expansionPulse or (volumeSustained and progressAtr > 0.35)
        activeState := "Expanding"
    else if returnedInside or (rvolSmooth <= weakRvolInput and progressAtr < 0.25 and barsActive > 1)
        activeState := "Suspicious"
    else
        activeState := "Fresh Path"

if pathActive
    int currentRightEdge = math.max(activeStartBar + postBreakBarsInput, bar_index + 1)
    color currentColor = f_state_color(activeState)
    string currentZoneText = f_zone_title(activeSide, activeState) + "\n" + (na(pathScore) ? "--" : str.tostring(pathScore, "#") + " / 100 " + f_grade(pathScore))
    float currentBandMid = math.avg(activeBandTop, activeBandBottom)
    int currentBadgeX = int(math.round(activeStartBar + (currentRightEdge - activeStartBar) * zoneBadgeAnchorInput))
    if not na(acceptanceBox)
        box.set_right(acceptanceBox, currentRightEdge)
        box.set_bgcolor(acceptanceBox, color.new(currentColor, activeState == "Failed Volume" ? 84 : 88))
        box.set_border_color(acceptanceBox, color.new(currentColor, 28))
    if not na(zoneBadge)
        label.set_x(zoneBadge, currentBadgeX)
        label.set_y(zoneBadge, currentBandMid)
        label.set_text(zoneBadge, currentZoneText)
        label.set_color(zoneBadge, color.new(currentColor, 6))
        label.set_textcolor(zoneBadge, f_text_on(currentColor))
        label.set_size(zoneBadge, f_size(labelSizeInput))
    if not na(breakoutLine)
        line.set_x2(breakoutLine, currentRightEdge)
        line.set_color(breakoutLine, color.new(currentColor, 0))
    if not na(invalidationLine)
        line.set_x2(invalidationLine, currentRightEdge)
    if not na(pathGuideLine)
        line.set_x2(pathGuideLine, currentRightEdge)
    if not na(guideLabel)
        label.set_x(guideLabel, currentRightEdge)
        label.set_y(guideLabel, activePathGuide)
        label.set_text(guideLabel, f_guide_text(activeState))
        label.set_size(guideLabel, f_size(labelSizeInput))

int stateCooldownBars = math.max(4, int(math.round(labelCooldownInput * 0.55)))
bool canPrintEvent = showEventLabelsInput and (na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownInput)
bool canPrintState = showEventLabelsInput and (na(lastEventLabelBar) or bar_index - lastEventLabelBar >= stateCooldownBars)

if expansionPulse and canPrintEvent
    int labelX = bar_index + 1
    int placementSide = activeSide
    int labelLane = f_next_label_lane(bar_index, placementSide)
    float laneOffset = labelOffsetAtrInput + labelLane * labelLaneSpacingAtrInput
    float labelY = placementSide == 1 ? low - safeAtr * laneOffset : high + safeAtr * laneOffset
    label expansionLabel = label.new(x = labelX, y = labelY, text = f_event_text("Volume Expansion", pathScore, showLabelScoresInput), xloc = xloc.bar_index, yloc = yloc.price, style = activeSide == 1 ? label.style_label_up : label.style_label_down, color = color.new(accentColor, 8), textcolor = f_text_on(accentColor), size = f_size(labelSizeInput), textalign = text.align_center)
    f_push_label(eventLabels, expansionLabel, maxLabelsInput)
    lastEventLabelBar := bar_index

if acceptedNow and canPrintState
    int labelX = bar_index + 1
    int placementSide = activeSide
    int labelLane = f_next_label_lane(bar_index, placementSide)
    float laneOffset = labelOffsetAtrInput + 0.30 + labelLane * labelLaneSpacingAtrInput
    float labelY = placementSide == 1 ? low - safeAtr * laneOffset : high + safeAtr * laneOffset
    label acceptLabel = label.new(x = labelX, y = labelY, text = f_event_text("Accepted", pathScore, showLabelScoresInput), xloc = xloc.bar_index, yloc = yloc.price, style = activeSide == 1 ? label.style_label_up : label.style_label_down, color = color.new(bullColor, 8), textcolor = f_text_on(bullColor), size = f_size(labelSizeInput), textalign = text.align_center)
    f_push_label(eventLabels, acceptLabel, maxLabelsInput)
    lastEventLabelBar := bar_index

if failedNow and canPrintState
    int labelX = bar_index + 1
    int placementSide = -activeSide
    int labelLane = f_next_label_lane(bar_index, placementSide)
    float laneOffset = labelOffsetAtrInput + labelLane * labelLaneSpacingAtrInput
    float labelY = placementSide == 1 ? low - safeAtr * laneOffset : high + safeAtr * laneOffset
    label failLabel = label.new(x = labelX, y = labelY, text = f_event_text("Failed Volume", pathScore, showLabelScoresInput), xloc = xloc.bar_index, yloc = yloc.price, style = activeSide == 1 ? label.style_label_down : label.style_label_up, color = color.new(bearColor, 8), textcolor = f_text_on(bearColor), size = f_size(labelSizeInput), textalign = text.align_center)
    f_push_label(eventLabels, failLabel, maxLabelsInput)
    lastEventLabelBar := bar_index

bool canPrintWatch = showWatchLabelsInput and rangeReady and (na(lastWatchLabelBar) or bar_index - lastWatchLabelBar >= labelCooldownInput)
bool bullWatch = canPrintWatch and close < rangeHigh and math.abs(rangeHigh - close) / safeAtr <= 0.65 and rvol >= sustainRvolInput and close > open and close > emaFast
bool bearWatch = canPrintWatch and close > rangeLow and math.abs(close - rangeLow) / safeAtr <= 0.65 and rvol >= sustainRvolInput and close < open and close < emaFast

if bullWatch or bearWatch
    int watchSide = bullWatch ? 1 : -1
    int labelX = bar_index + 1
    int labelLane = f_next_label_lane(bar_index, watchSide)
    float laneOffset = labelOffsetAtrInput + labelLane * labelLaneSpacingAtrInput
    float labelY = watchSide == 1 ? low - safeAtr * laneOffset : high + safeAtr * laneOffset
    label watchLabel = label.new(x = labelX, y = labelY, text = watchSide == 1 ? "Volume Watch Up" : "Volume Watch Down", xloc = xloc.bar_index, yloc = yloc.price, style = watchSide == 1 ? label.style_label_up : label.style_label_down, color = color.new(neutralColor, 10), textcolor = f_text_on(neutralColor), size = f_size(labelSizeInput), textalign = text.align_center)
    f_push_label(eventLabels, watchLabel, maxLabelsInput)
    lastWatchLabelBar := bar_index

color candleTint = na
if tintCandlesInput and pathActive and barsActive <= postBreakBarsInput
    int tintStrength = activeState == "Failed Volume" ? 82 : 88
    candleTint := activeSide == 1 ? color.new(bullColor, tintStrength) : color.new(bearColor, tintStrength)
barcolor(candleTint)

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table panel = table.new(f_panel_position(panelLocationInput), 2, 7, border_width = 1, border_color = panelBorder)

string panelSide = pathActive ? activeSide == 1 ? "Bull Path" : "Bear Path" : "None"
string panelVolume = pathActive ? str.tostring(rvolSmooth, "#.##") + "x RVOL" : "--"
string panelAcceptance = pathActive ? activeState : "No Active Path"
string panelScore = pathActive and not na(pathScore) ? str.tostring(pathScore, "#") + " / 100 " + f_grade(pathScore) : "--"
string panelAction = pathActive ? f_action_from_state(activeState, nz(pathScore, 0), activeThreshold) : "Wait for path"
string panelHoldRate = na(holdRate) ? "Building" : str.tostring(math.round(holdRate)) + "% (" + str.tostring(proofTotal) + ")"
color panelStateColor = pathActive ? f_state_color(activeState) : f_panel_value(panelThemeInput)
color panelVolumeColor = volumeSustained ? bullColor : neutralColor
color panelScoreColor = neutralColor
if pathActive and pathScore >= activeThreshold
    panelScoreColor := bullColor
else if pathActive and pathScore < weakFloorInput
    panelScoreColor := bearColor
color panelHoldColor = na(holdRate) ? f_panel_value(panelThemeInput) : holdRate >= 55.0 ? bullColor : holdRate >= 40.0 ? neutralColor : bearColor

if barstate.islast
    table.set_position(panel, f_panel_position(panelLocationInput))
    if showPanelInput
        table.clear(panel, 0, 0, 1, 6)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Volume Expansion Breakout Planner", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelSizeInput), text_halign = text.align_center)
        f_panel_row(panel, 1, "Breakout Side", panelSide, panelStateColor, panelThemeInput, panelSizeInput)
        f_panel_row(panel, 2, "Volume Expansion", panelVolume, panelVolumeColor, panelThemeInput, panelSizeInput)
        f_panel_row(panel, 3, "Acceptance", panelAcceptance, panelStateColor, panelThemeInput, panelSizeInput)
        f_panel_row(panel, 4, "Quality Score", panelScore, panelScoreColor, panelThemeInput, panelSizeInput)
        f_panel_row(panel, 5, "Action", panelAction, panelStateColor, panelThemeInput, panelSizeInput)
        f_panel_row(panel, 6, "Hold Rate", panelHoldRate, panelHoldColor, panelThemeInput, panelSizeInput)
    else
        table.clear(panel, 0, 0, 1, 6)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(highQualityBullBreak, "High-quality bullish volume expansion path", "Volume Expansion Breakout Planner: a bullish breakout path started with high-quality volume expansion conditions.")
alertcondition(highQualityBearBreak, "High-quality bearish volume expansion path", "Volume Expansion Breakout Planner: a bearish breakout path started with high-quality volume expansion conditions.")
alertcondition(expansionPulse, "Post-break volume expansion pulse", "Volume Expansion Breakout Planner: post-breakout volume is expanding constructively inside the active path.")
alertcondition(acceptedNow, "Volume expansion path accepted", "Volume Expansion Breakout Planner: the active breakout path reached an accepted state.")
alertcondition(failedNow, "Failed volume expansion path", "Volume Expansion Breakout Planner: the active breakout path returned into failed-volume or invalidation conditions.")
````

# Trend Pullback Risk Planner [AGPro Series]

- url: https://www.tradingview.com/script/5h7bL82R-Trend-Pullback-Risk-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;9d936939e47e470a96176355e0fd988f
- version: 6.0

## Description

Trend Pullback Risk Planner [AGPro Series]

🧠 Core Idea

Is the current pullback normal trend digestion, or is it becoming a risk shift that deserves review?


📌 Overview / What it does

Trend Pullback Risk Planner [AGPro Series] is a chart-first trend risk planner built to evaluate active pullbacks inside an established trend.

The script maps a Pullback Risk Pocket, trend defense line, invalidation reference, target-room guide, compact state labels, alert conditions, and a clean AGPro panel. It converts trend slope, pullback depth, volume dry-up, defense response, and target obstruction into a 0-100 Continuation Score.

It does not predict price movement, automate execution, or print buy/sell commands. Its purpose is to help traders judge whether a pullback is still controlled enough to review, or whether the trend context is starting to lose quality.


🎯 Purpose & Design Philosophy

This script was built for traders who already see a trend but need a cleaner way to evaluate pullback risk.

Many pullback tools focus on marking every retracement as a possible continuation setup. This planner focuses on the decision question behind the setup: is the pullback still being defended, is it getting too deep, does target room remain clean, and what should be reviewed next?

The design supports a risk-first mindset. It helps users read pullback behavior without turning the chart into a crowded signal board or a generic support/resistance map.


⚡ Why This Script Is Different

Most tools focus on identifying pullbacks or continuation signals.

This script does NOT try to clone a low-volume pullback zone, a generic trend continuation score, a Supertrend pullback model, or a broad support/resistance system.

Instead, it treats the pullback as a live risk review. The unique output is the Pullback Risk Pocket: a controlled planning area where depth, defense, volume behavior, target room, and invalidation context are evaluated together before the panel prints the next action state.


⚙️ Methodology

1. Context Detection
The planner identifies trend side using EMA stack structure and normalized trend slope. Users can keep the side automatic or restrict the tool to bullish-only or bearish-only review.

2. Reference Mapping
The script builds a Pullback Risk Pocket between the base trend reference and the defense line. It also maps an invalidation reference and a target-room guide.

3. Reaction Evaluation
The model evaluates pullback depth versus ATR, trend slope, volume dry-up, wick/close response inside the pocket, and distance to the nearest target-side obstruction.

4. Visual Output
The result is shown through a centered risk pocket label, defense/risk/target guide lines, compact event labels, alerts, and an AGPro decision panel.


🗺️ How to Read the Chart

Zones = the Pullback Risk Pocket where an active pullback is reviewed for normal digestion versus risk shift.

Labels = continuation-ready, risk-watch, weak-pullback, risk-shift, follow-through, and sparse pocket-context markers.

Colors = bullish trend context uses AGPro teal, bearish trend context uses AGPro pink, warning states use yellow, and invalidation/risk-shift states use red.

Panel = the panel summarizes Trend Side, Pullback Depth, Risk Pocket status, Continuation Score, target-room context, and Action.


🚦 Signals & States

• TREND ACTIVE → trend context exists, but price has not reached the pullback risk pocket.

• POCKET NEAR → price is approaching the pullback risk pocket and deserves attention.

• HEALTHY PULLBACK → pullback is being reviewed with constructive but not yet high-grade conditions.

• RISK WATCH → pullback depth or response quality is becoming less clean.

• CONTINUATION READY → pullback risk pocket is defending with sufficient score and target-room context for review.

• FOLLOW-THROUGH → price is responding after a defended pullback pocket.

• WEAK PULLBACK → pullback touched the pocket, but score quality is weak.

• RISK SHIFT → price crossed the invalidation reference and the context should be rebuilt.

• NO TREND → trend structure is not aligned enough for the planner.


🔔 Alerts Logic

Alerts trigger when the planner detects a Continuation Ready state, a Risk Watch state, a Risk Shift event, or Follow-Through after a defended pocket.

These alerts are attention markers. They are not trade instructions, not execution commands, and not guaranteed outcomes.


🧩 Confluence Logic

The strongest context appears when trend slope, controlled pullback depth, quiet retracement volume, a constructive defense response, and clean target room align at the same time.

When one or more of these elements weakens, the planner shifts toward POCKET NEAR, RISK WATCH, WEAK PULLBACK, or RISK SHIFT instead of forcing a continuation interpretation.


📊 When to Use

• Trending markets with visible pullback structure

• Continuation review after a clean directional leg

• Situations where pullback depth and defense quality matter

• Trade-planning workflows that need risk, invalidation, and target-room context


⚠️ When NOT to Use

• Flat, low-directional range conditions

• Low-liquidity charts with unreliable wick and volume behavior

• Extreme news volatility where pullbacks can invalidate quickly

• Situations where the user expects an automatic buy/sell system


🎛️ Key Inputs

• Planner Side → controls Auto, Bullish Only, or Bearish Only evaluation.

• Sensitivity → changes how strict the risk pocket and scoring model behave.

• EMA Lengths → define fast trend pressure, base pullback reference, and defense line.

• Pullback Depth Lookback → controls how the script measures retracement depth from the latest trend-side extreme.

• Risk Pocket Width ATR → controls the thickness of the pullback review area.

• Invalidation Buffer ATR → controls the distance of the invalidation reference beyond the defense line.

• Clean Target Room ATR → defines preferred room before target-side obstruction.

• Visual settings → control pocket visibility, guide lines, labels, panel location, theme, and font sizes.


🖥️ Interface & Visual Design

The interface is built around one main object: the Pullback Risk Pocket.

The centered pocket label keeps the active state visible without forcing users to read many separate markers. The guide lines show defense, invalidation, and target-room context. The AGPro panel keeps the decision state compact and readable.

Labels use controlled spacing, cooldown, and maximum-count settings so the chart remains active without becoming crowded.


🧪 Practical Usage Workflow

1. Read the panel Action state.

2. Check Trend Side and Pullback Depth.

3. Review whether price is near, inside, defending, or breaching the Pullback Risk Pocket.

4. Compare the Continuation Score with target-room context.

5. Treat alerts as attention markers and confirm broader market context independently.


🔍 Interpretation Guidelines

A higher Continuation Score means the active pullback is showing stronger alignment between trend slope, controlled depth, volume dry-up, defense response, and remaining target room.

CONTINUATION READY does not mean a trade should be opened. It means the pullback remains structurally constructive under the script's rule set.

RISK WATCH and RISK SHIFT are caution states. They help users slow down when pullback depth, defense response, or invalidation context becomes weaker.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not provide guaranteed signals.

It is not a generic support/resistance zone map.

It is not a clone of Low Volume Pullback Zones, Trend Continuation Quality, or Supertrend Pullback Quality.


⚠️ Limitations & Transparency

Timeframe differences can change trend slope, pullback depth, and target-room readings.

Volume behavior can vary across markets and data feeds.

Fast volatility expansion can move price through the pocket before a clean review state appears.

The script is rule-based and should be interpreted as an analytical planning layer, not as certainty.


🧠 Market Context Notes

Pullbacks are not automatically healthy because they occur inside a trend. A clean trend pullback usually needs controlled depth, reduced against-trend pressure, visible defense response, and enough room before the next obstruction.

This planner is designed to keep that review process structured.


🧾 Use Case Examples

When price pulls into the risk pocket with controlled depth, softer relative volume, and a strong close back toward the trend side, the planner may classify the state as CONTINUATION READY.

When price enters the pocket but response quality is weak or depth becomes excessive, the planner may show RISK WATCH.

When price crosses the invalidation reference beyond the defense line, the planner may show RISK SHIFT.


🧱 System Philosophy

Trend Pullback Risk Planner follows the AGPro Series decision-engine approach:

Trend first.

Pullback risk second.

Defense and target room before action.

Attention markers instead of promises.


🔐 Non-Promise Statement

No script can guarantee that a pullback will continue.

No state should be interpreted as certainty.

All outputs should be reviewed within broader market context.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions, risk management, and trade execution.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

The script is designed to help users think in structured pullback-risk terms: trend, depth, defense, target room, invalidation, and review.

## Source Code

````pine
// ─────────────────────────────────────────────────
// Trend Pullback Risk Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.1
//
// Trend Pullback Risk Planner is a chart-first trend pullback risk
// dashboard for reviewing whether an active pullback is normal digestion
// or a risk shift. It maps a pullback risk pocket, defense line,
// invalidation reference, target-room guide, continuation review score,
// and next-action workflow with cleaner label density, owned guide tags,
// closer candle-aware event badges, selective secondary label controls,
// and box-text-free premium visuals. V2.1 freezes each historical
// follow-through episode to its confirmation-time target and invalidation,
// resolves same-bar ambiguity conservatively, gates small samples, ages old
// chart badges, and aligns pocket, guide, panel, and alert semantics without
// becoming a prediction engine or a generic pullback signal printer.
// ─────────────────────────────────────────────────

//@version=6
indicator("Trend Pullback Risk Planner [AGPro Series]",
     shorttitle = "AG Pro TPR",
     overlay = true,
     max_boxes_count = 10,
     max_labels_count = 120,
     max_lines_count = 20)

// ─────────────────────────────────────────────────
// AGPro Color Palette
// ─────────────────────────────────────────────────
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
color dangerColor   = color.rgb(239, 68, 68)
color darkText      = color.rgb(15, 23, 42)

// ─────────────────────────────────────────────────
// Tooltips
// ─────────────────────────────────────────────────
const string TT_SIDE = "Selects the trend side evaluated by the planner. Auto follows the active EMA stack, while directional modes restrict the planner to bullish or bearish trend-pullback risk only."
const string TT_SENS = "Controls how strict the risk pocket model is. Responsive accepts more pullback reviews, Balanced is the publication default, and Strict requires cleaner trend slope and defense response."
const string TT_CONFIRM = "Close Confirmed prints labels and alerts only after a closed bar. Live Updating lets the planner update during the active bar."
const string TT_FAST = "Fast EMA used to detect short-term trend pressure and recovery behavior. It is not a standalone signal line."
const string TT_BASE = "Base EMA used as the near edge of the pullback risk pocket."
const string TT_SLOW = "Slow EMA used as the trend defense reference and invalidation context."
const string TT_SLOPE = "Number of bars used to measure normalized trend slope. Higher values make the trend-side score slower and smoother."
const string TT_PULLBACK = "Lookback used to measure pullback depth from the latest trend-side extreme."
const string TT_ATR = "ATR normalizes pocket width, depth, defense rails, target room, and label offsets across symbols."
const string TT_VOL = "Volume baseline used to judge whether pullback activity is drying up instead of expanding aggressively against trend."
const string TT_TARGET = "Lookback used to locate the prior directional extreme used as the target-room reference. If that reference no longer leaves usable room, the planner substitutes an ATR-based open-room benchmark."
const string TT_POCKET = "ATR width around the base-to-defense area used to draw the pullback risk pocket."
const string TT_IDEAL = "Preferred ATR-normalized pullback depth. Very shallow pullbacks and overly deep pullbacks score lower."
const string TT_DEEP = "ATR-normalized pullback depth where the planner begins treating the pullback as elevated risk."
const string TT_RISK = "ATR buffer beyond the trend defense line used to draw the invalidation reference. It is a planning guide, not a stop recommendation."
const string TT_ROOM = "Preferred ATR-normalized room to the prior directional reference, or to the explicit open-room benchmark when no usable prior reference remains ahead."
const string TT_READY = "Minimum 0-100 continuation review score required before the planner marks review-continuation context. If set below Review Score, the engine safely uses one point above Review Score."
const string TT_WATCH = "Minimum 0-100 score used for healthy pullback or watch-risk review states. The continuation threshold is always normalized above this value."
const string TT_CONT_WINDOW = "Number of confirmed bars allowed for one non-overlapping historical follow-through episode to resolve. Unresolved episodes count as non-follow-through; this descriptive rate is not a forecast."
const string TT_CONT_MOVE = "ATR distance frozen at qualification as the favorable follow-through level. The matching invalidation reference is frozen at the same time, later ATR or guide movement cannot rewrite the episode, and qualification requires enough target room to cover this distance."
const string TT_CONT_MIN = "Minimum number of resolved historical episodes required before the panel displays a rate. Smaller samples remain in Building status."
const string TT_EMA = "Shows optional EMA anchors used by the planner. Hidden by default to keep the public chart cleaner."
const string TT_POCKET_SHOW = "Shows the active Pullback Risk Pocket with a compact centered badge. This is the primary chart-first visual object."
const string TT_GUIDES = "Shows the trend defense, invalidation, and target-room reference guides. Every visible guide remains paired with a filled right-side owner badge."
const string TT_GUIDE_TAGS = "Shows the complete owned guide set with compact right-side tags for Defense, Invalidation, and Target or Room Reference. Disabling tags also hides the guide lines so no rail is left without an owner."
const string TT_GUIDE_TAG_OFFSET = "Bars between the current bar and the shared guide-tag lane. A wider offset separates guide tags from the centered pocket badge."
const string TT_ZONE_OPACITY = "Transparency of the pullback risk pocket. Higher values make the pocket lighter."
const string TT_PROJECTION = "Number of bars projected to the right for the pullback risk pocket. Owned guide length is controlled separately by the shared guide-tag lane."
const string TT_LABELS = "Shows compact Review, Watch, Shift, Follow, and Weak review labels."
const string TT_CONTEXT = "Adds sparse context labels while price is approaching or reviewing the risk pocket so the chart stays informative without clutter."
const string TT_FOLLOW_LABELS = "Shows Follow event labels after a defended pullback. Disabled by default because follow-through labels can drift visually after price expands."
const string TT_WATCH_LABELS = "Shows Watch labels for lower-priority risk-review states. Disabled by default for a cleaner publication preset."
const string TT_WEAK_LABELS = "Shows Weak labels for low-score pullback reviews. Disabled by default because these secondary labels can feel detached on volatile symbols."
const string TT_SCORE_LABEL = "Adds the 0-100 review score to chart labels."
const string TT_COOLDOWN = "Minimum bars between full event labels. Higher values reduce repeated labels during active pullbacks."
const string TT_CONTEXT_SPACING = "Minimum bars between sparse context labels during ongoing pullback review."
const string TT_MAX_LABELS = "Maximum number of chart labels retained. Older labels are deleted first for performance."
const string TT_LABEL_HISTORY = "Maximum age of historical event labels in bars. This works with the count limit to remove stale or edge-clipped badges while retaining recent review context."
const string TT_OFFSET = "ATR-based vertical offset that keeps labels near their source candles without burying them inside candle bodies."
const string TT_LABEL_SIZE = "Controls every chart label and centered pocket badge. Normal is the recommended publication default."
const string TT_BADGE_LANES = "Offsets nearby event labels into small ATR-based lanes so REVIEW, WATCH, SHIFT, and FOLLOW badges stay readable in clustered pullback reactions."
const string TT_LANE_SPACING = "Controls the vertical distance between smart badge lanes. Lower values keep labels visually attached to their source candles."
const string TT_PANEL = "Shows or hides the AG Pro planning panel. The default is visible for public-release readability."
const string TT_PANEL_LOCATION = "Moves the AG Pro planning panel to the preferred chart location."
const string TT_PANEL_THEME = "Switches the panel between the premium AGPro dark theme and a clean light theme."
const string TT_PANEL_SIZE = "Controls panel text size. Normal is the recommended publication default."
const string TT_ALERT = "Minimum continuation review score required before review and follow-through alerts can trigger."

// ─────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────
string groupEngine = "Trend Pullback Engine"
string sideMode = input.string("Auto", "Planner Side", options = ["Auto", "Bullish Only", "Bearish Only"], group = groupEngine, tooltip = TT_SIDE)
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Responsive", "Balanced", "Strict"], group = groupEngine, tooltip = TT_SENS)
string confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = TT_CONFIRM)
int fastEmaLength = input.int(21, "Fast EMA Length", minval = 2, maxval = 160, group = groupEngine, tooltip = TT_FAST)
int baseEmaLength = input.int(34, "Base EMA Length", minval = 5, maxval = 240, group = groupEngine, tooltip = TT_BASE)
int slowEmaLength = input.int(89, "Defense EMA Length", minval = 10, maxval = 400, group = groupEngine, tooltip = TT_SLOW)
int slopeLookback = input.int(8, "Trend Slope Lookback", minval = 2, maxval = 80, group = groupEngine, tooltip = TT_SLOPE)
int pullbackLookback = input.int(34, "Pullback Depth Lookback", minval = 8, maxval = 220, group = groupEngine, tooltip = TT_PULLBACK)
int atrLength = input.int(14, "ATR Length", minval = 3, maxval = 120, group = groupEngine, tooltip = TT_ATR)
int volumeLength = input.int(30, "Volume Baseline Length", minval = 5, maxval = 220, group = groupEngine, tooltip = TT_VOL)
int targetLookback = input.int(72, "Target Reference Lookback", minval = 12, maxval = 300, group = groupEngine, tooltip = TT_TARGET)

string groupPlanner = "Risk Planner Model"
float pocketWidthAtr = input.float(0.42, "Risk Pocket Width ATR", minval = 0.08, maxval = 2.50, step = 0.02, group = groupPlanner, tooltip = TT_POCKET)
float idealPullbackAtr = input.float(1.10, "Ideal Pullback Depth ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupPlanner, tooltip = TT_IDEAL)
float deepPullbackAtr = input.float(2.70, "Deep Pullback Risk ATR", minval = 0.40, maxval = 8.00, step = 0.05, group = groupPlanner, tooltip = TT_DEEP)
float riskBufferAtr = input.float(0.34, "Invalidation Buffer ATR", minval = 0.00, maxval = 2.50, step = 0.01, group = groupPlanner, tooltip = TT_RISK)
float cleanRoomAtr = input.float(2.10, "Clean Target Room ATR", minval = 0.30, maxval = 8.00, step = 0.05, group = groupPlanner, tooltip = TT_ROOM)
int readyScore = input.int(70, "Review Continuation Score", minval = 45, maxval = 95, group = groupPlanner, tooltip = TT_READY)
int watchScore = input.int(54, "Review Score", minval = 25, maxval = 90, group = groupPlanner, tooltip = TT_WATCH)
int continuationWindow = input.int(40, "Continuation Proof Window (bars)", minval = 5, maxval = 240, group = groupPlanner, tooltip = TT_CONT_WINDOW)
float continuationMoveAtr = input.float(0.75, "Follow-Through Move ATR", minval = 0.10, maxval = 5.00, step = 0.05, group = groupPlanner, tooltip = TT_CONT_MOVE)
int minimumProofSamples = input.int(30, "Minimum Proof Samples", minval = 5, maxval = 500, group = groupPlanner, tooltip = TT_CONT_MIN)

string groupVisual = "Chart Visuals"
bool showEmaAnchors = input.bool(false, "Show EMA Anchors", group = groupVisual, tooltip = TT_EMA)
bool showRiskPocket = input.bool(true, "Show Pullback Risk Pocket", group = groupVisual, tooltip = TT_POCKET_SHOW)
bool showGuideLines = input.bool(true, "Show Owned Planning Guides", group = groupVisual, tooltip = TT_GUIDES)
bool showGuideTags = input.bool(true, "Show Guide Tags", group = groupVisual, tooltip = TT_GUIDE_TAGS)
int guideTagOffsetBars = input.int(10, "Guide Tag Offset Bars", minval = 1, maxval = 30, group = groupVisual, tooltip = TT_GUIDE_TAG_OFFSET)
int pocketTransparency = input.int(86, "Pocket Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = TT_ZONE_OPACITY)
int projectionBars = input.int(42, "Pocket Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = TT_PROJECTION)

string groupLabels = "Labels"
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = TT_LABELS)
bool showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = TT_CONTEXT)
bool showFollowLabels = input.bool(false, "Show Follow Labels", group = groupLabels, tooltip = TT_FOLLOW_LABELS)
bool showWatchLabels = input.bool(false, "Show Watch Labels", group = groupLabels, tooltip = TT_WATCH_LABELS)
bool showWeakLabels = input.bool(false, "Show Weak Labels", group = groupLabels, tooltip = TT_WEAK_LABELS)
bool showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = TT_SCORE_LABEL)
int labelCooldownBars = input.int(34, "Event Label Cooldown", minval = 1, maxval = 120, group = groupLabels, tooltip = TT_COOLDOWN)
int contextSpacingBars = input.int(72, "Context Label Spacing", minval = 6, maxval = 180, group = groupLabels, tooltip = TT_CONTEXT_SPACING)
int maxVisibleLabels = input.int(5, "Max Visible Labels", minval = 4, maxval = 100, group = groupLabels, tooltip = TT_MAX_LABELS)
int labelHistoryBars = input.int(180, "Label History Bars", minval = 40, maxval = 2000, group = groupLabels, tooltip = TT_LABEL_HISTORY)
float labelOffsetAtr = input.float(0.48, "Label Offset ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupLabels, tooltip = TT_OFFSET)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = TT_LABEL_SIZE)
bool useSmartBadgeLanes = input.bool(true, "Use Smart Badge Lanes", group = groupLabels, tooltip = TT_BADGE_LANES)
float badgeLaneAtr = input.float(0.16, "Badge Lane Spacing ATR", minval = 0.06, maxval = 1.50, step = 0.02, group = groupLabels, tooltip = TT_LANE_SPACING)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = TT_PANEL)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = TT_PANEL_LOCATION)
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = TT_PANEL_THEME)
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = TT_PANEL_SIZE)

string groupAlerts = "Alerts"
int alertScore = input.int(70, "Minimum Alert Score", minval = 45, maxval = 95, group = groupAlerts, tooltip = TT_ALERT)

// ─────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_norm_high_good(float value, float weak, float strong) =>
    float span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float good, float bad) =>
    float span = bad - good
    span == 0.0 ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    float result = 0.0
    if value <= idealValue
        result := f_norm_high_good(value, lowValue, idealValue)
    else
        result := f_norm_low_good(value, idealValue, highValue)
    result

f_text_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_position(string posText) =>
    switch posText
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_panel_bg(string theme) =>
    theme == "Clean Light" ? color.rgb(241, 245, 249) : panelBg

f_panel_border(string theme) =>
    theme == "Clean Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string theme, int row) =>
    bool evenRow = row % 2 == 0
    if theme == "Clean Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)
    else
        evenRow ? color.rgb(20, 31, 52) : panelBg

f_panel_semantic(color valueColor, string theme) =>
    color result = valueColor
    if theme == "Clean Light"
        result := valueColor == bullColor ? color.rgb(4, 120, 87) : valueColor == bearColor ? color.rgb(190, 24, 93) : valueColor == neutralColor ? color.rgb(180, 83, 9) : valueColor == accentColor ? color.rgb(79, 70, 229) : valueColor == dangerColor ? color.rgb(185, 28, 28) : valueColor
    result

f_badge_text_color(color badgeColor) =>
    badgeColor == dangerColor ? headerText : darkText

f_fmt(float value) =>
    na(value) ? "-" : str.tostring(value, "#.##")

f_fmt_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_grade(float score) =>
    string result = "D"
    if score >= 88
        result := "A+"
    else if score >= 78
        result := "A"
    else if score >= 66
        result := "B"
    else if score >= 54
        result := "C"
    result

f_score_color(float score, int dir) =>
    color result = dangerColor
    if score >= 78
        result := dir == 1 ? bullColor : bearColor
    else if score >= math.max(readyScore, watchScore + 1)
        result := accentColor
    else if score >= watchScore
        result := neutralColor
    result

f_review_badge_color(float score, int dir) =>
    score >= 78.0 ? (dir == 1 ? bullColor : bearColor) : score >= 74.0 ? accentColor : neutralColor

f_state_color(string stateText, int dir, float score) =>
    color result = f_panel_value(panelTheme)
    if stateText == "NO TREND"
        result := neutralColor
    else if stateText == "TREND ACTIVE" or stateText == "REVIEW CONTINUATION" or stateText == "TRACK FOLLOW-THROUGH"
        result := dir == 1 ? bullColor : bearColor
    else if stateText == "PULLBACK HEALTHY"
        result := accentColor
    else if stateText == "WATCH RISK" or stateText == "NEAR POCKET"
        result := neutralColor
    else if stateText == "RISK SHIFT" or stateText == "WEAK PULLBACK"
        result := dangerColor
    else
        result := f_score_color(score, dir)
    result

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = f_panel_semantic(rightColor, theme), bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_right)

f_delete_label(label id) =>
    if not na(id)
        label.delete(id)
    true

f_trim_labels(array<label> labels, int maxCount, int maxAge, int currentBar) =>
    while array.size(labels) > maxCount
        label oldLabel = array.shift(labels)
        f_delete_label(oldLabel)
    bool checkingAge = true
    while checkingAge and array.size(labels) > 0
        label oldestLabel = array.get(labels, 0)
        bool tooOld = na(oldestLabel)
        if not tooOld
            tooOld := currentBar - label.get_x(oldestLabel) > maxAge
        if tooOld
            label expiredLabel = array.shift(labels)
            f_delete_label(expiredLabel)
        else
            checkingAge := false
    true

f_badge_set(label id, int xValue, float yValue, string textValue, color bgColor, string sizeText) =>
    label result = id
    if na(result)
        result := label.new(x = xValue, y = yValue, text = textValue, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(bgColor, 0), textcolor = f_badge_text_color(bgColor), size = f_text_size(sizeText), textalign = text.align_center)
    else
        label.set_x(result, xValue)
        label.set_y(result, yValue)
        label.set_text(result, textValue)
        label.set_color(result, color.new(bgColor, 0))
        label.set_textcolor(result, f_badge_text_color(bgColor))
        label.set_size(result, f_text_size(sizeText))
    result

f_add_label(array<label> labels, int x, float y, string labelText, color bgColor, color textColor, bool isBull, string sizeText, int maxCount, int maxAge, int currentBar) =>
    label newLabel = label.new(x = x, y = y, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = isBull ? label.style_label_up : label.style_label_down, color = bgColor, textcolor = textColor, size = f_text_size(sizeText))
    array.push(labels, newLabel)
    f_trim_labels(labels, maxCount, maxAge, currentBar)

f_badge_step(float atrInput) =>
    math.max(math.max(atrInput, syminfo.mintick) * badgeLaneAtr, syminfo.mintick * 20.0)

f_guide_badge_gap(float atrInput, string sizeText) =>
    float fontFactor = sizeText == "Tiny" ? 2.40 : sizeText == "Small" ? 2.80 : sizeText == "Large" ? 4.00 : 3.40
    math.max(math.max(atrInput, syminfo.mintick) * fontFactor, syminfo.mintick * 30.0)

f_bull_badge_y(float basePrice, int lane, float atrInput) =>
    useSmartBadgeLanes ? basePrice - f_badge_step(atrInput) * math.max(lane - 1, 0) : basePrice

f_bear_badge_y(float basePrice, int lane, float atrInput) =>
    useSmartBadgeLanes ? basePrice + f_badge_step(atrInput) * math.max(lane - 1, 0) : basePrice

// ─────────────────────────────────────────────────
// Core Calculations
// ─────────────────────────────────────────────────
bool confirmReady = confirmationMode == "Live Updating" or barstate.isconfirmed
float safeAtr = math.max(ta.atr(atrLength), syminfo.mintick)
float fastEma = ta.ema(close, fastEmaLength)
float baseEma = ta.ema(close, baseEmaLength)
float slowEma = ta.ema(close, slowEmaLength)
float volumeMa = ta.sma(volume, volumeLength)
float rvol = nz(volumeMa > 0.0 ? volume / volumeMa : 1.0, 1.0)
bool dataReady = not na(baseEma[slopeLookback]) and not na(slowEma) and not na(safeAtr)

bool bullStack = fastEma > baseEma and baseEma > slowEma
bool bearStack = fastEma < baseEma and baseEma < slowEma
bool bullTrend = dataReady and bullStack
bool bearTrend = dataReady and bearStack
int autoDir = bullTrend ? 1 : bearTrend ? -1 : 0
int evalDir = sideMode == "Bullish Only" ? (bullTrend ? 1 : 0) : sideMode == "Bearish Only" ? (bearTrend ? -1 : 0) : autoDir
bool activeSide = evalDir != 0
bool useBull = evalDir == 1
float dirMult = useBull ? 1.0 : evalDir == -1 ? -1.0 : 0.0

float sensitivityMult = sensitivity == "Responsive" ? 1.12 : sensitivity == "Strict" ? 0.88 : 1.0
float strictBonus = sensitivity == "Strict" ? 8.0 : sensitivity == "Responsive" ? -4.0 : 0.0
float idealDepth = idealPullbackAtr * sensitivityMult
float deepDepth = math.max(deepPullbackAtr * sensitivityMult, idealDepth + 0.10)
float minUsefulDepth = math.max(0.22, idealDepth * 0.28)
int effectiveReadyScore = math.max(readyScore, watchScore + 1)

float recentTrendHigh = ta.highest(high, pullbackLookback)
float recentTrendLow = ta.lowest(low, pullbackLookback)
float pullbackDepthAtr = activeSide ? (useBull ? (recentTrendHigh - low) / safeAtr : (high - recentTrendLow) / safeAtr) : na

float slopeRaw = activeSide ? (baseEma - baseEma[slopeLookback]) / safeAtr * dirMult : na
float slopeScore = activeSide ? f_norm_high_good(slopeRaw, 0.04, sensitivity == "Strict" ? 0.42 : 0.32) : 0.0
float stackScore = useBull ? (bullStack ? 100.0 : fastEma > baseEma ? 55.0 : 20.0) : evalDir == -1 ? (bearStack ? 100.0 : fastEma < baseEma ? 55.0 : 20.0) : 0.0
float trendScore = activeSide ? f_clamp(stackScore * 0.62 + slopeScore * 0.38 - strictBonus, 0.0, 100.0) : 0.0
float depthScore = activeSide ? f_peak_score(pullbackDepthAtr, minUsefulDepth, idealDepth, deepDepth) : 0.0

float rawTop = na
float rawBottom = na
float defenseLine = activeSide ? slowEma : na
if activeSide
    if useBull
        rawTop := baseEma + safeAtr * pocketWidthAtr
        rawBottom := defenseLine - safeAtr * pocketWidthAtr
    else
        rawTop := defenseLine + safeAtr * pocketWidthAtr
        rawBottom := baseEma - safeAtr * pocketWidthAtr
float pocketTop = activeSide ? math.max(rawTop, rawBottom) : na
float pocketBottom = activeSide ? math.min(rawTop, rawBottom) : na
float riskEdge = activeSide ? defenseLine - dirMult * safeAtr * riskBufferAtr : na

float priorHighRef = ta.highest(high, targetLookback)[1]
float priorLowRef = ta.lowest(low, targetLookback)[1]
float priorExtremeRef = activeSide ? (useBull ? priorHighRef : priorLowRef) : na
float targetGuide = na
bool targetIsBenchmark = false
if activeSide
    targetGuide := priorExtremeRef
    float rawRoom = useBull ? (targetGuide - close) / safeAtr : (close - targetGuide) / safeAtr
    if na(targetGuide) or rawRoom < 0.30
        targetGuide := close + dirMult * safeAtr * cleanRoomAtr
        targetIsBenchmark := true
float targetRoomAtr = activeSide ? math.max(useBull ? (targetGuide - close) / safeAtr : (close - targetGuide) / safeAtr, 0.0) : na
float targetScore = activeSide ? f_norm_high_good(targetRoomAtr, 0.35, cleanRoomAtr) : 0.0

bool touchesPocket = activeSide and high >= pocketBottom and low <= pocketTop
bool insidePocket = activeSide and close <= pocketTop and close >= pocketBottom
bool nearPocket = activeSide and (useBull ? low <= pocketTop + safeAtr * 0.35 : high >= pocketBottom - safeAtr * 0.35)
bool pullbackActive = activeSide and pullbackDepthAtr >= minUsefulDepth and nearPocket
var bool invalidationLatched = false
var int invalidationDir = 0
var float latchedInvalidationLevel = na
bool currentInvalidationBreach = confirmReady and activeSide and (useBull ? close < riskEdge : close > riskEdge)
bool priorContextExists = nz(evalDir[1], 0) != 0 and not na(riskEdge[1])
bool priorContextBreach = confirmReady and priorContextExists and (evalDir[1] == 1 ? close < riskEdge[1] : close > riskEdge[1])
bool usePriorBreach = priorContextBreach and (not currentInvalidationBreach or not activeSide or evalDir != evalDir[1])
bool invalidationBreach = priorContextBreach or currentInvalidationBreach
int breachDir = usePriorBreach ? evalDir[1] : evalDir
float breachLevel = usePriorBreach ? riskEdge[1] : riskEdge
bool invalidationStart = false
if invalidationBreach
    if not invalidationLatched or invalidationDir != breachDir
        invalidationStart := true
        invalidationLatched := true
        invalidationDir := breachDir
        latchedInvalidationLevel := breachLevel
else if invalidationLatched
    bool sameLatchedContext = activeSide and evalDir == invalidationDir
    bool rebuiltBeyondPocket = sameLatchedContext and (invalidationDir == 1 ? close > pocketTop : close < pocketBottom)
    if confirmReady and (rebuiltBeyondPocket or not sameLatchedContext)
        invalidationLatched := false
        invalidationDir := 0
        latchedInvalidationLevel := na
bool invalidated = invalidationLatched
float displayedRiskEdge = invalidated and not na(latchedInvalidationLevel) ? latchedInvalidationLevel : riskEdge

float barRange = math.max(high - low, syminfo.mintick)
float closeLocation = useBull ? (close - low) / barRange : evalDir == -1 ? (high - close) / barRange : 0.0
float wickResponse = useBull ? (math.min(open, close) - low) / barRange : evalDir == -1 ? (high - math.max(open, close)) / barRange : 0.0
bool closeBackToTrend = activeSide and (useBull ? close > baseEma : close < baseEma)
float locationScore = f_norm_high_good(closeLocation, 0.42, 0.76)
float wickScore = f_norm_high_good(wickResponse, 0.08, 0.34)
float closeBackScore = closeBackToTrend ? 100.0 : insidePocket ? 62.0 : 34.0
float defenseResponseScore = activeSide ? (touchesPocket or nearPocket ? locationScore * 0.38 + wickScore * 0.30 + closeBackScore * 0.32 : 48.0) : 0.0

bool againstTrendCandle = activeSide and (useBull ? close < open or close < fastEma : close > open or close > fastEma)
float volumeDryUpScore = f_norm_low_good(rvol, 0.62, 1.35)
float volumeScore = activeSide ? (pullbackActive or againstTrendCandle ? volumeDryUpScore : 58.0) : 0.0

float continuationScore = activeSide ? f_clamp(trendScore * 0.24 + depthScore * 0.22 + volumeScore * 0.16 + defenseResponseScore * 0.22 + targetScore * 0.16, 0.0, 100.0) : 0.0
string sideText = activeSide ? (useBull ? "Bull Trend" : "Bear Trend") : "No Trend"
string depthText = activeSide ? f_fmt(pullbackDepthAtr) + " ATR" : "-"
string pocketText = invalidated ? "Breached" : activeSide ? touchesPocket ? "In Review" : nearPocket ? "Near" : "Clear" : "-"
string roomText = activeSide ? f_fmt(targetRoomAtr) + " ATR" : "-"
string invalidationText = activeSide or invalidated ? f_fmt_price(displayedRiskEdge) : "-"
float riskDistanceAtr = invalidated ? math.max(invalidationDir == 1 ? (close - displayedRiskEdge) / safeAtr : (displayedRiskEdge - close) / safeAtr, 0.0) : activeSide ? math.max(useBull ? (close - riskEdge) / safeAtr : (riskEdge - close) / safeAtr, 0.0) : na

float minimumDefenseResponse = sensitivity == "Strict" ? 64.0 : sensitivity == "Responsive" ? 52.0 : 58.0
bool riskWatchRaw = activeSide and confirmReady and nearPocket and not invalidated and continuationScore >= watchScore and (pullbackDepthAtr > deepDepth * 0.72 or defenseResponseScore < 50.0)
bool readyRaw = activeSide and confirmReady and touchesPocket and not invalidated and not riskWatchRaw and continuationScore >= effectiveReadyScore and defenseResponseScore >= minimumDefenseResponse and targetRoomAtr >= math.max(cleanRoomAtr * 0.45, continuationMoveAtr)
bool healthyRaw = activeSide and confirmReady and touchesPocket and not invalidated and not riskWatchRaw and continuationScore >= watchScore and continuationScore < effectiveReadyScore and pullbackDepthAtr <= deepDepth * 0.82
bool weakRaw = activeSide and confirmReady and touchesPocket and not invalidated and continuationScore < watchScore
bool readyStart = readyRaw and (not readyRaw[1] or evalDir != evalDir[1])
bool watchStart = riskWatchRaw and (not riskWatchRaw[1] or evalDir != evalDir[1])
bool weakStart = weakRaw and (not weakRaw[1] or evalDir != evalDir[1])
bool visibleWatchRaw = riskWatchRaw and not touchesPocket
bool visibleWatchStart = visibleWatchRaw and (not visibleWatchRaw[1] or evalDir != evalDir[1])

// ─────────────────────────────────────────────────
// Historical follow-through proof
// One non-overlapping episode is tracked at a time. Qualification-time
// direction, target, and invalidation levels remain frozen until resolution.
// If both frozen levels trade on the same bar, invalidation wins.
// ─────────────────────────────────────────────────
var int   contTotal        = 0
var int   contWon          = 0
var bool  contPend         = false
var int   contDir          = 0
var float contTarget       = na
var float contInvalidation = na
var float contQualificationScore = na
var int   contLeft         = 0
bool contFollowEvent = false
int resolvedFollowDir = 0
float resolvedFollowScore = na

if barstate.isconfirmed
    if contPend and not na(contTarget) and not na(contInvalidation)
        bool adverseHit = contDir == 1 ? low <= contInvalidation : high >= contInvalidation
        bool favorableHit = contDir == 1 ? high >= contTarget : low <= contTarget
        if adverseHit
            contTotal += 1
            contPend := false
            contTarget := na
            contInvalidation := na
        else if favorableHit
            contTotal += 1
            contWon += 1
            contFollowEvent := true
            resolvedFollowDir := contDir
            resolvedFollowScore := contQualificationScore
            contPend := false
            contTarget := na
            contInvalidation := na
        else
            contLeft -= 1
            if contLeft <= 0
                contTotal += 1
                contPend := false
                contTarget := na
                contInvalidation := na
    if readyStart and evalDir != 0 and not contPend
        contPend := true
        contDir := evalDir
        contTarget := close + evalDir * safeAtr * continuationMoveAtr
        contInvalidation := riskEdge
        contQualificationScore := continuationScore
        contLeft := continuationWindow

float contRate = contTotal > 0 ? contWon / contTotal * 100.0 : na
bool proofReady = contTotal >= minimumProofSamples
bool followThroughRaw = contFollowEvent
bool followStateRaw = followThroughRaw and activeSide and evalDir == resolvedFollowDir

string stateText = "WAIT"
if invalidated
    stateText := "RISK SHIFT"
else if not activeSide
    stateText := "NO TREND"
else if followStateRaw
    stateText := "TRACK FOLLOW-THROUGH"
else if readyRaw
    stateText := "REVIEW CONTINUATION"
else if riskWatchRaw
    stateText := "WATCH RISK"
else if healthyRaw
    stateText := "PULLBACK HEALTHY"
else if weakRaw
    stateText := "WEAK PULLBACK"
else if nearPocket
    stateText := "NEAR POCKET"
else
    stateText := "TREND ACTIVE"

string actionText = "Wait"
if stateText == "NO TREND"
    actionText := "Stand aside"
else if stateText == "TREND ACTIVE"
    actionText := "Wait pullback"
else if stateText == "NEAR POCKET"
    actionText := "Prepare review"
else if stateText == "PULLBACK HEALTHY"
    actionText := "Monitor defense"
else if stateText == "WATCH RISK"
    actionText := "Wait response"
else if stateText == "REVIEW CONTINUATION"
    actionText := "Review defense / room"
else if stateText == "TRACK FOLLOW-THROUGH"
    actionText := "Review target room"
else if stateText == "WEAK PULLBACK"
    actionText := "Avoid chase"
else if stateText == "RISK SHIFT"
    actionText := "Rebuild plan"

color stateColor = f_state_color(stateText, evalDir, continuationScore)
color sideColor = useBull ? bullColor : evalDir == -1 ? bearColor : neutralColor
color stateTextColor = f_badge_text_color(stateColor)
string labelSuffix = showLabelScore and activeSide ? " " + str.tostring(math.round(continuationScore)) : ""
string compactStateText = stateText == "REVIEW CONTINUATION" ? "REVIEW" : stateText == "TRACK FOLLOW-THROUGH" ? "FOLLOW" : stateText == "PULLBACK HEALTHY" ? "HEALTHY" : stateText == "WATCH RISK" ? "WATCH" : stateText == "WEAK PULLBACK" ? "WEAK" : stateText == "RISK SHIFT" ? "SHIFT" : stateText == "NEAR POCKET" ? "NEAR" : stateText == "TREND ACTIVE" ? "WAIT" : stateText

// ─────────────────────────────────────────────────
// Chart Visuals
// ─────────────────────────────────────────────────
plot(showEmaAnchors ? fastEma : na, "Fast EMA", color = color.new(accentColor, 15), linewidth = 1)
plot(showEmaAnchors ? baseEma : na, "Base EMA", color = color.new(neutralColor, 10), linewidth = 1)
plot(showEmaAnchors ? slowEma : na, "Defense EMA", color = color.new(sideColor, 10), linewidth = 2)

var label fastEmaTag = na
var label baseEmaTag = na
var label slowEmaTag = na
var box riskPocketBox = na
var label riskPocketLabel = na
var line defenseGuideLine = na
var line riskGuideLine = na
var line targetGuideLine = na
var line defenseGuideConnector = na
var line riskGuideConnector = na
var label defenseGuideTag = na
var label riskGuideTag = na
var label targetGuideTag = na

int leftEdge = math.max(0, bar_index - math.min(pullbackLookback, 90))
int rightEdge = bar_index + projectionBars
int guideTagX = bar_index + guideTagOffsetBars
int defenseRiskTagX = guideTagX + 9
bool showOwnedGuides = showGuideLines and showGuideTags
float guideBadgeMinGap = f_guide_badge_gap(safeAtr, labelFontSize)
bool guideBadgesNeedSeparation = useSmartBadgeLanes and math.abs(defenseLine - displayedRiskEdge) < guideBadgeMinGap
float guideBadgeMidPrice = (defenseLine + displayedRiskEdge) / 2.0
bool defenseAboveRisk = defenseLine >= displayedRiskEdge
float defenseTagY = guideBadgesNeedSeparation ? guideBadgeMidPrice + (defenseAboveRisk ? guideBadgeMinGap / 2.0 : -guideBadgeMinGap / 2.0) : defenseLine
float riskTagY = guideBadgesNeedSeparation ? guideBadgeMidPrice + (defenseAboveRisk ? -guideBadgeMinGap / 2.0 : guideBadgeMinGap / 2.0) : displayedRiskEdge
string zoneText = activeSide ? "POCKET | " + compactStateText + (showLabelScore ? " | " + str.tostring(math.round(continuationScore)) : "") : ""

if showEmaAnchors and barstate.islast
    fastEmaTag := f_badge_set(fastEmaTag, bar_index + 1, fastEma, "Fast EMA " + str.tostring(fastEmaLength), accentColor, labelFontSize)
    label.set_style(fastEmaTag, label.style_label_left)
    baseEmaTag := f_badge_set(baseEmaTag, bar_index + 1, baseEma, "Base EMA " + str.tostring(baseEmaLength), neutralColor, labelFontSize)
    label.set_style(baseEmaTag, label.style_label_left)
    slowEmaTag := f_badge_set(slowEmaTag, bar_index + 1, slowEma, "Defense EMA " + str.tostring(slowEmaLength), sideColor, labelFontSize)
    label.set_style(slowEmaTag, label.style_label_left)
else if not showEmaAnchors
    if not na(fastEmaTag)
        label.delete(fastEmaTag)
        fastEmaTag := na
    if not na(baseEmaTag)
        label.delete(baseEmaTag)
        baseEmaTag := na
    if not na(slowEmaTag)
        label.delete(slowEmaTag)
        slowEmaTag := na

if showRiskPocket and activeSide
    if na(riskPocketBox)
        riskPocketBox := box.new(left = leftEdge, top = pocketTop, right = rightEdge, bottom = pocketBottom, xloc = xloc.bar_index, border_color = color.new(stateColor, 0), bgcolor = color.new(sideColor, pocketTransparency))
    else
        box.set_lefttop(riskPocketBox, leftEdge, pocketTop)
        box.set_rightbottom(riskPocketBox, rightEdge, pocketBottom)
        box.set_border_color(riskPocketBox, color.new(stateColor, 0))
        box.set_bgcolor(riskPocketBox, color.new(sideColor, pocketTransparency))
    int pocketMidBar = int(math.round((leftEdge + rightEdge) / 2.0))
    float pocketMidPrice = (pocketTop + pocketBottom) / 2.0
    if na(riskPocketLabel)
        riskPocketLabel := label.new(x = pocketMidBar, y = pocketMidPrice, text = zoneText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(stateColor, 0), textcolor = stateTextColor, size = f_text_size(labelFontSize))
    else
        label.set_x(riskPocketLabel, pocketMidBar)
        label.set_y(riskPocketLabel, pocketMidPrice)
        label.set_text(riskPocketLabel, zoneText)
        label.set_color(riskPocketLabel, color.new(stateColor, 0))
        label.set_textcolor(riskPocketLabel, stateTextColor)
        label.set_size(riskPocketLabel, f_text_size(labelFontSize))
else
    if not na(riskPocketBox)
        box.delete(riskPocketBox)
        riskPocketBox := na
    if not na(riskPocketLabel)
        label.delete(riskPocketLabel)
        riskPocketLabel := na

if showOwnedGuides and activeSide and not invalidated
    if na(defenseGuideLine)
        defenseGuideLine := line.new(x1 = leftEdge, y1 = defenseLine, x2 = guideTagX, y2 = defenseLine, xloc = xloc.bar_index, extend = extend.none, color = sideColor, style = line.style_solid, width = 2)
    else
        line.set_xy1(defenseGuideLine, leftEdge, defenseLine)
        line.set_xy2(defenseGuideLine, guideTagX, defenseLine)
        line.set_color(defenseGuideLine, sideColor)
        line.set_style(defenseGuideLine, line.style_solid)
        line.set_width(defenseGuideLine, 2)
    if na(riskGuideLine)
        riskGuideLine := line.new(x1 = leftEdge, y1 = displayedRiskEdge, x2 = guideTagX, y2 = displayedRiskEdge, xloc = xloc.bar_index, extend = extend.none, color = invalidated ? dangerColor : neutralColor, style = line.style_dashed, width = 2)
    else
        line.set_xy1(riskGuideLine, leftEdge, displayedRiskEdge)
        line.set_xy2(riskGuideLine, guideTagX, displayedRiskEdge)
        line.set_color(riskGuideLine, invalidated ? dangerColor : neutralColor)
        line.set_style(riskGuideLine, line.style_dashed)
        line.set_width(riskGuideLine, 2)
    if na(defenseGuideConnector)
        defenseGuideConnector := line.new(x1 = guideTagX, y1 = defenseLine, x2 = defenseRiskTagX, y2 = defenseTagY, xloc = xloc.bar_index, extend = extend.none, color = sideColor, style = line.style_solid, width = 2)
    else
        line.set_xy1(defenseGuideConnector, guideTagX, defenseLine)
        line.set_xy2(defenseGuideConnector, defenseRiskTagX, defenseTagY)
        line.set_color(defenseGuideConnector, sideColor)
    if na(riskGuideConnector)
        riskGuideConnector := line.new(x1 = guideTagX, y1 = displayedRiskEdge, x2 = defenseRiskTagX, y2 = riskTagY, xloc = xloc.bar_index, extend = extend.none, color = invalidated ? dangerColor : neutralColor, style = line.style_dashed, width = 2)
    else
        line.set_xy1(riskGuideConnector, guideTagX, displayedRiskEdge)
        line.set_xy2(riskGuideConnector, defenseRiskTagX, riskTagY)
        line.set_color(riskGuideConnector, invalidated ? dangerColor : neutralColor)
    if na(targetGuideLine)
        targetGuideLine := line.new(x1 = leftEdge, y1 = targetGuide, x2 = guideTagX, y2 = targetGuide, xloc = xloc.bar_index, extend = extend.none, color = accentColor, style = line.style_dotted, width = 1)
    else
        line.set_xy1(targetGuideLine, leftEdge, targetGuide)
        line.set_xy2(targetGuideLine, guideTagX, targetGuide)
        line.set_color(targetGuideLine, accentColor)
        line.set_style(targetGuideLine, line.style_dotted)
        line.set_width(targetGuideLine, 1)
    defenseGuideTag := f_badge_set(defenseGuideTag, defenseRiskTagX, defenseTagY, "Defense " + f_fmt_price(defenseLine), sideColor, labelFontSize)
    label.set_style(defenseGuideTag, label.style_label_left)
    riskGuideTag := f_badge_set(riskGuideTag, defenseRiskTagX, riskTagY, "Invalid. " + f_fmt_price(displayedRiskEdge), invalidated ? dangerColor : neutralColor, labelFontSize)
    label.set_style(riskGuideTag, label.style_label_left)
    string targetTagText = targetIsBenchmark ? "Room Ref " : "Target Ref "
    targetGuideTag := f_badge_set(targetGuideTag, guideTagX, targetGuide, targetTagText + f_fmt_price(targetGuide), accentColor, labelFontSize)
    label.set_style(targetGuideTag, label.style_label_left)
else
    if not na(defenseGuideLine)
        line.delete(defenseGuideLine)
        defenseGuideLine := na
    if not na(riskGuideLine)
        line.delete(riskGuideLine)
        riskGuideLine := na
    if not na(targetGuideLine)
        line.delete(targetGuideLine)
        targetGuideLine := na
    if not na(defenseGuideConnector)
        line.delete(defenseGuideConnector)
        defenseGuideConnector := na
    if not na(riskGuideConnector)
        line.delete(riskGuideConnector)
        riskGuideConnector := na
    if not na(defenseGuideTag)
        label.delete(defenseGuideTag)
        defenseGuideTag := na
    if not na(riskGuideTag)
        label.delete(riskGuideTag)
        riskGuideTag := na
    if not na(targetGuideTag)
        label.delete(targetGuideTag)
        targetGuideTag := na

// ─────────────────────────────────────────────────
// Labels
// ─────────────────────────────────────────────────
var array<label> chartLabels = array.new<label>()
var int lastEventLabelBar = na
var int lastContextLabelBar = na
f_trim_labels(chartLabels, maxVisibleLabels, labelHistoryBars, bar_index)

bool eventSpacingReady = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
bool readyEvent = showEventLabels and eventSpacingReady and readyStart
bool riskWatchEvent = showEventLabels and showWatchLabels and eventSpacingReady and visibleWatchStart
bool weakEvent = showEventLabels and showWeakLabels and eventSpacingReady and weakStart
bool shiftEvent = showEventLabels and invalidationStart
bool followThroughEvent = showEventLabels and showFollowLabels and followThroughRaw

if shiftEvent
    bool shiftBull = invalidationDir == 1
    float baseY = shiftBull ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
    float y = shiftBull ? f_bear_badge_y(baseY, 1, safeAtr) : f_bull_badge_y(baseY, 1, safeAtr)
    f_add_label(chartLabels, bar_index, y, "Shift " + f_fmt_price(latchedInvalidationLevel), color.new(dangerColor, 2), headerText, not shiftBull, labelFontSize, maxVisibleLabels, labelHistoryBars, bar_index)
    lastEventLabelBar := bar_index
else if readyEvent
    float baseY = useBull ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    float y = useBull ? f_bull_badge_y(baseY, 1, safeAtr) : f_bear_badge_y(baseY, 1, safeAtr)
    color reviewBadgeColor = f_review_badge_color(continuationScore, evalDir)
    f_add_label(chartLabels, bar_index, y, "Review" + labelSuffix, color.new(reviewBadgeColor, 4), f_badge_text_color(reviewBadgeColor), useBull, labelFontSize, maxVisibleLabels, labelHistoryBars, bar_index)
    lastEventLabelBar := bar_index
else if riskWatchEvent
    float baseY = useBull ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    float y = useBull ? f_bull_badge_y(baseY, 2, safeAtr) : f_bear_badge_y(baseY, 2, safeAtr)
    f_add_label(chartLabels, bar_index, y, "Watch" + labelSuffix, color.new(neutralColor, 4), darkText, useBull, labelFontSize, maxVisibleLabels, labelHistoryBars, bar_index)
    lastEventLabelBar := bar_index
else if weakEvent
    float baseY = useBull ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
    float y = useBull ? f_bear_badge_y(baseY, 2, safeAtr) : f_bull_badge_y(baseY, 2, safeAtr)
    f_add_label(chartLabels, bar_index, y, "Weak" + labelSuffix, color.new(dangerColor, 5), headerText, not useBull, labelFontSize, maxVisibleLabels, labelHistoryBars, bar_index)
    lastEventLabelBar := bar_index

if followThroughEvent
    bool followBull = resolvedFollowDir == 1
    string followSuffix = showLabelScore and not na(resolvedFollowScore) ? " " + str.tostring(math.round(resolvedFollowScore)) : ""
    float baseY = followBull ? low - safeAtr * (labelOffsetAtr + 0.12) : high + safeAtr * (labelOffsetAtr + 0.12)
    float y = followBull ? f_bull_badge_y(baseY, 2, safeAtr) : f_bear_badge_y(baseY, 2, safeAtr)
    f_add_label(chartLabels, bar_index, y, "Follow" + followSuffix, color.new(accentColor, 3), darkText, followBull, labelFontSize, maxVisibleLabels, labelHistoryBars, bar_index)
    lastEventLabelBar := bar_index

bool contextEventGapReady = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= math.max(labelCooldownBars, contextSpacingBars)
bool contextReady = showContextLabels and confirmReady and activeSide and nearPocket and not touchesPocket and not invalidated and contextEventGapReady and (na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars)
if contextReady
    float baseY = useBull ? low - safeAtr * (labelOffsetAtr + 0.18) : high + safeAtr * (labelOffsetAtr + 0.18)
    float y = useBull ? f_bull_badge_y(baseY, 3, safeAtr) : f_bear_badge_y(baseY, 3, safeAtr)
    f_add_label(chartLabels, bar_index, y, "Pocket", color.new(stateColor, 6), stateTextColor, useBull, labelFontSize, maxVisibleLabels, labelHistoryBars, bar_index)
    lastContextLabelBar := bar_index

// ─────────────────────────────────────────────────
// Panel
// ─────────────────────────────────────────────────
string scorePanelText = activeSide ? str.tostring(math.round(continuationScore)) + "/100 " + f_grade(continuationScore) : "-"
string riskPanelText = invalidated ? "Breached / " + invalidationText : activeSide ? f_fmt(riskDistanceAtr) + " ATR / " + invalidationText : "-"
string targetPanelText = activeSide ? roomText + (targetIsBenchmark ? " / Benchmark" : " / Prior Ref") : "-"
color targetPanelColor = targetIsBenchmark ? accentColor : targetScore >= 55.0 ? bullColor : neutralColor
string contRateText = proofReady ? str.tostring(math.round(contRate)) + "% | " + str.tostring(contWon) + "/" + str.tostring(contTotal) : "Building " + str.tostring(contTotal) + "/" + str.tostring(minimumProofSamples)
color contRateColor = proofReady ? (contRate >= 60.0 ? bullColor : contRate >= 45.0 ? neutralColor : dangerColor) : f_panel_value(panelTheme)

var table panel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""
var string lastPanelFont = ""

if barstate.islast
    if showPanel
        if na(panel) or panelLocation != lastPanelLocation or panelTheme != lastPanelTheme or panelFontSize != lastPanelFont
            if not na(panel)
                table.delete(panel)
            panel := table.new(f_panel_position(panelLocation), 2, 9, bgcolor = f_panel_bg(panelTheme), frame_color = f_panel_border(panelTheme), frame_width = 1, border_color = f_panel_border(panelTheme), border_width = 1)
            table.cell(panel, 0, 0, "", bgcolor = headerBg)
            table.cell(panel, 1, 0, "", bgcolor = headerBg)
            table.merge_cells(panel, 0, 0, 1, 0)
            lastPanelLocation := panelLocation
            lastPanelTheme := panelTheme
            lastPanelFont := panelFontSize
        table.clear(panel, 0, 1, 1, 8)
        table.cell(panel, 0, 0, "AG Pro Trend Pullback Risk Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        f_panel_row(panel, 1, "Workflow", actionText, stateColor, panelTheme, panelFontSize)
        f_panel_row(panel, 2, "Trend Context", sideText, sideColor, panelTheme, panelFontSize)
        f_panel_row(panel, 3, "Pullback Risk", depthText + " / " + pocketText, stateColor, panelTheme, panelFontSize)
        f_panel_row(panel, 4, "Invalidation", riskPanelText, invalidated ? dangerColor : neutralColor, panelTheme, panelFontSize)
        f_panel_row(panel, 5, "Target Room", targetPanelText, targetPanelColor, panelTheme, panelFontSize)
        f_panel_row(panel, 6, "Review Score", scorePanelText, activeSide ? f_score_color(continuationScore, evalDir) : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_panel_row(panel, 7, "Historical FT", contRateText, contRateColor, panelTheme, panelFontSize)
        f_panel_row(panel, 8, "State", stateText, stateColor, panelTheme, panelFontSize)
    else if not na(panel)
        table.delete(panel)
        panel := na
        lastPanelLocation := ""
        lastPanelTheme := ""
        lastPanelFont := ""

// ─────────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────────
bool readyAlertRaw = readyRaw and continuationScore >= alertScore
bool readyAlertStart = readyAlertRaw and (not readyAlertRaw[1] or evalDir != evalDir[1])
bool riskWatchAlertStart = watchStart
bool followAlertRaw = followThroughRaw and not na(resolvedFollowScore) and resolvedFollowScore >= alertScore
alertcondition(readyAlertStart, title = "Trend Pullback Review Continuation", message = "Trend Pullback Risk Planner: pullback risk pocket entered a qualified continuation review state.")
alertcondition(riskWatchAlertStart, title = "Trend Pullback Watch Risk", message = "Trend Pullback Risk Planner: pullback entered a watch-risk state near the active pocket.")
alertcondition(invalidationStart, title = "Trend Pullback Risk Shift", message = "Trend Pullback Risk Planner: price crossed the frozen invalidation reference and the pullback context should be rebuilt.")
alertcondition(followAlertRaw, title = "Trend Pullback Follow-Through Review", message = "Trend Pullback Risk Planner: a qualified historical episode reached its frozen follow-through level before its frozen invalidation. This is a review marker, not a trade instruction.")

// Hidden reference plot
plot(proofReady ? contRate : na, "Historical Follow-Through Rate", display = display.none)
````

# Session Reclaim Planner [AGPro Series]

- url: https://www.tradingview.com/script/MnrrwWgy-Session-Reclaim-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;2ce173792a8047629d39647b2dc7c636
- version: 4.0

## Description

Session Reclaim Planner [AGPro Series]

🧠 Core Idea

Did price reclaim a key session high or low with enough acceptance to create a valid planning context?


📌 Overview / What it does

Session Reclaim Planner [AGPro Series] is an intraday decision-support tool built around session high and session low reclaim behavior. It builds a configurable reference session, maps the session high/low rails, then monitors whether price temporarily loses one of those rails and reclaims it with measurable acceptance.

The script produces a 0-100 Reclaim Score, session level rails, a reclaim pocket, a risk edge, a target corridor, event labels, alerts, and a compact AG Pro planning panel. It is designed to help traders organize session reclaim context instead of reacting to every touch of a session level.

It does not predict price direction, automate trades, or mark every session high/low as important. The script focuses on a specific sequence: session rail built -> rail temporarily lost -> rail reclaimed by close -> acceptance quality reviewed.


🎯 Purpose & Design Philosophy

This script was built to fill the gap between simple session level markers and broad session reaction tools.

Many session indicators show highs, lows, opens, boxes, or kill zones. Those references can be useful, but they often leave the trader with the harder question: did the level actually get reclaimed with enough structure to matter?

Session Reclaim Planner supports a planning-first mindset. It asks whether the setup is valid, how strong it is, where the risk edge sits, where the target corridor is, and what the next action state should be.


⚡ Why This Script Is Different

Most session tools focus on time windows, session opens, or static high/low levels.

This script does NOT clone Session Reaction Map, Kill Zone Session Engine, Session VWAP Reaction Engine, Session Range Expansion Planner, Previous Day Sweep & Reclaim, or a generic support/resistance map.

Instead, it focuses only on session rail reclaim behavior after a completed reference session. The reclaim must come from a clear rail loss and a close back through the level, then the script evaluates acceptance, participation, room, and risk structure.


⚙️ Methodology

1. Context Detection
The script builds a configurable session range and stores the session high and low as active reclaim rails.

2. Reference Mapping
The high and low rails are projected forward. The user can evaluate both rails or focus only on the high or low.

3. Reaction Evaluation
The planner waits for a temporary rail loss, then checks whether price closes back through the rail with enough reclaim distance.

4. Visual Output
Accepted events create a reclaim pocket, risk edge, target corridor, chart labels, panel state, and alert conditions.


🗺️ How to Read the Chart

Zones = the reclaim pocket and target corridor.

Labels = rail loss, reclaim watch, plan review, failed reclaim, and target review events.

Colors = bullish low reclaim uses AGPro teal, bearish high reclaim uses AGPro pink, neutral review states use gold, and target context uses indigo.

Panel = current session level, Reclaim Score, acceptance status, risk edge, and action state.


🚦 Signals & States

• Reclaim Watch → price has temporarily lost a selected session rail and the planner is waiting for a reclaim close.

• Acceptance Watch → a reclaim close exists, but the plan still needs enough quality or acceptance.

• Plan Review → score and acceptance are strong enough to review risk and target context.

• Risk Edge Test → price is testing the active risk boundary.

• Failed Reclaim → price closes through the risk edge and the reclaim plan is no longer valid.

• Target Review → price reaches the target corridor and the reaction should be reviewed.


🔔 Alerts Logic

Bullish Session Reclaim triggers when the session low is lost, reclaimed, and the score reaches the alert threshold.

Bearish Session Reclaim triggers when the session high is lost, reclaimed, and the score reaches the alert threshold.

Plan Review triggers when the active reclaim reaches the required score and acceptance conditions.

Failed Reclaim triggers when price closes through the active risk edge.

Target Review triggers when price reaches the active target corridor.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The score combines multiple conditions:

• Reclaim close strength
• Acceptance closes
• Volume support
• Risk-to-target room
• Session range fit

When those elements align, the reclaim context becomes stronger. When one or more elements are weak, the panel keeps the user in watch or no-review states.


📊 When to Use

• 1H publication charts and lower intraday execution-review charts

• Intraday markets with clear session behavior
• Session high/low reclaim workflows
• London or New York continuation/reversal review
• Markets where traders actively monitor session rails
• Clean reclaim sequences after temporary level loss


⚠️ When NOT to Use

• Very low liquidity markets
• Extremely noisy micro timeframes
• Symbols where session windows are not meaningful
• Conditions with erratic gaps or unreliable volume
• Markets where the reference session is not relevant to your workflow


🎛️ Key Inputs

• Visual Timeframe Preset → default chart objects are optimized for 1H and lower publication charts, while 4H or all intraday visuals can be enabled manually.

• Session Timezone → defines how session windows are interpreted.

• Level Build Session → builds the reference high and low rails.

• Monitor Session → defines when reclaim behavior is evaluated.

• Reclaim Rail Mode → selects high, low, or both rails.

• Minimum Rail Loss ATR → controls how much level loss is required before a reclaim watch starts.

• Acceptance Closes → controls how many closes must hold the reclaimed side.

• Target Corridor Model → selects rail-based, R-based, or hybrid target logic.

• Panel and Label Settings → control readability, location, theme, and font sizes.


🖥️ Interface & Visual Design

The interface is built around a clean AG Pro planning panel and chart-first visual structure.

The session rails define the level context. The reclaim pocket defines the recovered area. The risk edge shows where the active plan weakens. The target corridor frames the next review area.

Labels are intentionally compact and offset away from candles so the chart remains readable without looking empty.


🧪 Practical Usage Workflow

1. Read the AG Pro panel.

2. Check whether the session rails are built.

3. Wait for a rail loss and reclaim close.

4. Review the Reclaim Score and acceptance count.

5. Compare the risk edge and target corridor with broader market context.


🔍 Interpretation Guidelines

Treat the script as a structured session reclaim map.

A higher score means the reclaim has cleaner acceptance, better participation, and better room relative to risk. A lower score means the reclaim may still exist, but the plan quality is weaker or incomplete.

The target corridor is a review area, not a guaranteed objective.


🚫 What This Script Is NOT

• Not a prediction engine
• Not financial advice
• Not auto trading
• Not guaranteed signals
• Not a generic support/resistance map
• Not a session open reaction scanner
• Not a VWAP reclaim tool


⚠️ Limitations & Transparency

Session behavior depends heavily on symbol, liquidity, timezone, and timeframe.

A reclaim that looks clean on one timeframe may look incomplete or noisy on another.

Volume support can be less reliable on markets where reported volume is limited or synthetic.

No rule-based script can account for every news event, spread condition, execution constraint, or market regime shift.


🧠 Market Context Notes

Session reclaim behavior often matters because traders watch session highs and lows as liquidity and structure references.

The key distinction is not the level itself. The key distinction is whether price lost the level, reclaimed it, and then held acceptance strongly enough to deserve review.


🧾 Use Case Examples

When price sweeps below the built session low, closes back above it, holds acceptance, and has room toward the opposite rail, the panel may move into Plan Review.

When price reclaims a rail but immediately closes through the risk edge, the state shifts to Failed Reclaim.

When price reaches the target corridor, the script marks Target Review so the user can evaluate the reaction instead of assuming continuation.


🧱 System Philosophy

Session Reclaim Planner follows the AGPro decision-engine model:

Validate the setup.
Score the quality.
Map the risk.
Frame the target.
Show the next action state.


🔐 Non-Promise Statement

The script does not provide certainty.

It organizes session reclaim context with rule-based logic and visual planning references.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions, risk management, and execution.

This script is for educational and analytical use only and does not provide financial advice.


📚 Educational Note

Use the tool to study how session high and session low reclaim behavior changes across symbols, sessions, and timeframes.

## Source Code

````pine
// -------------------------------------------------
// Session Reclaim Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.7
//
// Session Reclaim Planner is an intraday session-level decision engine that
// maps whether price lost and reclaimed a key session high or low with enough
// acceptance. It builds session rails, scores reclaim quality from 0 to 100,
// frames the risk edge and target corridor, and converts the context into a
// clear next-action state without cloning session open reaction tools, VWAP
// reclaim tools, kill-zone engines, or generic support/resistance maps.
// The default visual preset supports charts through 4H while retaining the
// denser 1H publication layout as the primary visual reference.
// -------------------------------------------------

//@version=6
indicator("Session Reclaim Planner [AGPro Series]",
     shorttitle = "AG Pro SRP",
     overlay = true,
     max_boxes_count = 80,
     max_labels_count = 220,
     max_lines_count = 140)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
color headerBg      = color.rgb(37, 99, 235)      // #2563EB
color headerText    = color.rgb(245, 247, 250)    // #F5F7FA
color panelBg       = color.rgb(15, 23, 42)       // #0F172A
color panelBorder   = color.rgb(51, 65, 85)       // #334155
color panelLabelCol = color.rgb(148, 163, 184)    // #94A3B8
color panelValueCol = color.rgb(226, 232, 240)    // #E2E8F0
color bullColor     = color.rgb(34, 197, 166)     // #22C5A6
color bearColor     = color.rgb(244, 114, 182)    // #F472B6
color neutralColor  = color.rgb(245, 189, 92)     // #F5BD5C
color accentColor   = color.rgb(129, 140, 248)    // #818CF8
color dangerColor   = color.rgb(239, 68, 68)
color darkInk       = color.rgb(17, 24, 39)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
const string TT_TZ = "Timezone used to build and monitor session levels. Match this with the market session you want to evaluate."
const string TT_BUILD_SESSION = "Session window used to build the reference high and low rails. The planner evaluates reclaim behavior after this window is formed."
const string TT_MONITOR_SESSION = "Session window where reclaim behavior is monitored after the reference rails are available."
const string TT_LEVEL_MODE = "Selects which session rail can trigger reclaim planning. High & Low evaluates both rails; focused modes reduce chart objects."
const string TT_CONFIRM = "When enabled, reclaim states and alerts are confirmed only after bar close for stable public chart behavior."
const string TT_ATR = "ATR normalizes sweep depth, reclaim distance, pocket height, risk edge spacing, target corridor width, and label offsets."
const string TT_VOLUME = "Volume baseline used to judge participation behind the reclaim. If volume is unavailable, the model treats participation as neutral."
const string TT_SWEEP = "Minimum temporary move beyond a session rail, measured in ATR, required before a reclaim watch can arm."
const string TT_RECLAIM = "Minimum close back beyond the reclaimed rail, measured in ATR, required to activate a reclaim plan."
const string TT_ACCEPT = "Number of closes on the reclaimed side required before the planner can move from acceptance watch to plan review."
const string TT_WINDOW = "Maximum number of bars allowed between the rail loss and reclaim close before the watch expires."
const string TT_POCKET = "ATR-based height of the reclaim pocket around the recovered session rail."
const string TT_RISK = "ATR buffer placed beyond the sweep extreme to define the risk edge. This is a planning reference, not a trade instruction."
const string TT_TARGET = "Target-corridor model. Hybrid uses the cleaner of opposite session rail context and R-multiple room."
const string TT_TARGET_R = "Risk multiple used when the target corridor is projected from the reclaimed rail and risk edge."
const string TT_TARGET_WIDTH = "ATR-based width of the target corridor around the selected target reference."
const string TT_READY = "Minimum 0-100 reclaim score required for PLAN REVIEW state after acceptance closes are present."
const string TT_WATCH = "Minimum 0-100 reclaim score required for ACCEPTANCE WATCH state."
const string TT_EXPIRY = "Number of bars the active reclaim plan remains in review before it expires. Also bounds the proof-rate measurement window."
const string TT_VISUAL_TF = "Controls which intraday timeframes display chart objects. The default keeps 15m, 1H, and 4H session maps visible; All intraday extends the same structure to higher intraday charts."
const string TT_RAILS = "Shows the active session high and low rails used by the reclaim planner."
const string TT_RANGE = "Shows the completed build-session range box with a centered label."
const string TT_POCKET_SHOW = "Shows the reclaim pocket around the recovered session rail with a centered label."
const string TT_TARGET_SHOW = "Shows the session target corridor with a centered label."
const string TT_LABELS = "Shows compact event labels for reclaim activation, plan review, target review, and failed reclaim."
const string TT_SCORE_LABEL = "Adds the active 0-100 score to event labels."
const string TT_LABEL_SIZE = "Controls all chart label sizes, including centered zone labels. Normal is the recommended publication default."
const string TT_LABEL_OFFSET = "ATR-based vertical offset that keeps event labels above or below candles."
const string TT_COOLDOWN = "Minimum number of bars between repeated event labels. Higher values reduce label clustering."
const string TT_BADGE_LANES = "Separates pocket, target, session, and event badges into ATR-based visual lanes so meaningful labels remain visible without stacking on the same price band."
const string TT_BADGE_SPACING = "Controls the vertical distance between smart badge lanes. Higher values create more breathing room on dense charts."
const string TT_PROJECTION = "Number of bars projected to the right for reclaim pocket, target corridor, and active rails."
const string TT_MAX_OBJECTS = "Maximum stored boxes and lines retained by the script. Older objects are deleted first for performance."
const string TT_MAX_LABELS = "Maximum visible labels retained by the script. Older labels are deleted first for performance."
const string TT_PANEL_SHOW = "Shows or hides the AG Pro planning panel. It is shown by default for public-release readability."
const string TT_PANEL_LOCATION = "Moves the AG Pro panel to the preferred chart location."
const string TT_PANEL_THEME = "Switches the panel between the premium AGPro dark theme and a clean light theme."
const string TT_PANEL_SIZE = "Controls the font size used inside the AG Pro panel. Normal is the recommended publication default."
const string TT_ALERT = "Minimum reclaim score required before alert conditions can trigger. Alerts are attention markers, not trade instructions."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupSession = "Session Engine"
string sessionTz = input.string("America/New_York", "Session Timezone", group = groupSession, tooltip = TT_TZ)
string buildSession = input.session("0000-0800", "Level Build Session", group = groupSession, tooltip = TT_BUILD_SESSION)
string monitorSession = input.session("0800-2359", "Monitor Session", group = groupSession, tooltip = TT_MONITOR_SESSION)
string levelMode = input.string("High & Low", "Reclaim Rail Mode", options = ["High & Low", "Low Only", "High Only"], group = groupSession, tooltip = TT_LEVEL_MODE)
bool confirmOnClose = input.bool(true, "Confirm On Bar Close", group = groupSession, tooltip = TT_CONFIRM)
int atrLength = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupSession, tooltip = TT_ATR)
int volumeLength = input.int(34, "Volume Baseline Length", minval = 5, maxval = 200, group = groupSession, tooltip = TT_VOLUME)

string groupPlanner = "Planner Model"
float minimumSweepAtr = input.float(0.14, "Minimum Rail Loss ATR", minval = 0.01, maxval = 2.00, step = 0.01, group = groupPlanner, tooltip = TT_SWEEP)
float minimumReclaimAtr = input.float(0.05, "Minimum Reclaim Close ATR", minval = 0.00, maxval = 1.00, step = 0.01, group = groupPlanner, tooltip = TT_RECLAIM)
int acceptanceBars = input.int(2, "Acceptance Closes", minval = 1, maxval = 8, group = groupPlanner, tooltip = TT_ACCEPT)
int reclaimWindowBars = input.int(36, "Reclaim Window Bars", minval = 3, maxval = 180, group = groupPlanner, tooltip = TT_WINDOW)
float reclaimPocketAtr = input.float(0.35, "Reclaim Pocket ATR", minval = 0.05, maxval = 2.50, step = 0.01, group = groupPlanner, tooltip = TT_POCKET)
float riskBufferAtr = input.float(0.16, "Risk Edge Buffer ATR", minval = 0.00, maxval = 2.00, step = 0.01, group = groupPlanner, tooltip = TT_RISK)
string targetModel = input.string("Hybrid Rail / R", "Target Corridor Model", options = ["Hybrid Rail / R", "Opposite Session Rail", "R Multiple"], group = groupPlanner, tooltip = TT_TARGET)
float targetRMultiple = input.float(1.60, "Target R Multiple", minval = 0.25, maxval = 5.00, step = 0.05, group = groupPlanner, tooltip = TT_TARGET_R)
float targetCorridorAtr = input.float(0.28, "Target Corridor Width ATR", minval = 0.05, maxval = 2.00, step = 0.01, group = groupPlanner, tooltip = TT_TARGET_WIDTH)
int planReviewThreshold = input.int(72, "PLAN REVIEW Threshold", minval = 45, maxval = 95, group = groupPlanner, tooltip = TT_READY)
int watchThreshold = input.int(56, "ACCEPTANCE WATCH Threshold", minval = 25, maxval = 90, group = groupPlanner, tooltip = TT_WATCH)
int planExpiryBars = input.int(72, "Active Plan Expiry Bars", minval = 8, maxval = 260, group = groupPlanner, tooltip = TT_EXPIRY)

string groupVisual = "Chart Visuals"
string visualTfPreset = input.string("4H and lower", "Visual Timeframe Preset", options = ["1H and lower", "4H and lower", "All intraday"], group = groupVisual, tooltip = TT_VISUAL_TF)
bool showSessionRails = input.bool(true, "Show Session Level Rails", group = groupVisual, tooltip = TT_RAILS)
bool showSessionRangeBox = input.bool(true, "Show Session Range Box", group = groupVisual, tooltip = TT_RANGE)
bool showReclaimPocket = input.bool(true, "Show Reclaim Pocket", group = groupVisual, tooltip = TT_POCKET_SHOW)
bool showTargetCorridor = input.bool(true, "Show Target Corridor", group = groupVisual, tooltip = TT_TARGET_SHOW)
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupVisual, tooltip = TT_LABELS)
bool showLabelScore = input.bool(true, "Show Label Score", group = groupVisual, tooltip = TT_SCORE_LABEL)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisual, tooltip = TT_LABEL_SIZE)
float labelOffsetAtr = input.float(0.95, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupVisual, tooltip = TT_LABEL_OFFSET)
int labelCooldownBars = input.int(14, "Event Label Cooldown", minval = 1, maxval = 120, group = groupVisual, tooltip = TT_COOLDOWN)
bool useSmartBadgeLanes = input.bool(true, "Use Smart Badge Lanes", group = groupVisual, tooltip = TT_BADGE_LANES)
float badgeLaneAtr = input.float(0.34, "Badge Lane Spacing ATR", minval = 0.10, maxval = 1.25, step = 0.05, group = groupVisual, tooltip = TT_BADGE_SPACING)
int projectionBars = input.int(42, "Forward Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = TT_PROJECTION)
int maxVisibleLabels = input.int(8, "Max Visible Event Labels", minval = 4, maxval = 60, group = groupVisual, tooltip = TT_MAX_LABELS)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = TT_PANEL_SHOW)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = TT_PANEL_LOCATION)
string panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = TT_PANEL_THEME)
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel, tooltip = TT_PANEL_SIZE)

string groupAlerts = "Alerts"
int alertScoreThreshold = input.int(72, "Minimum Alert Score", minval = 40, maxval = 95, group = groupAlerts, tooltip = TT_ALERT)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_norm_high_good(float value, float weakValue, float strongValue) =>
    float span = math.max(strongValue - weakValue, 0.000001)
    f_clamp((value - weakValue) / span * 100.0, 0.0, 100.0)

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    float result = 0.0
    if value <= idealValue
        result := f_norm_high_good(value, lowValue, idealValue)
    else
        float span = math.max(highValue - idealValue, 0.000001)
        result := f_clamp((highValue - value) / span * 100.0, 0.0, 100.0)
    result

// Luminance-145 contrast: bright badge fills get dark ink, dark fills get header text.
f_text_on(color bg) =>
    float lum = math.round(0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg))
    lum >= 145 ? darkInk : headerText

f_text_size(string value) =>
    switch value
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_panel_pos(string value) =>
    switch value
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_fmt_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_fmt_score(float value) =>
    na(value) ? "-" : str.tostring(value, "#")

f_fmt_atr(float value) =>
    na(value) ? "-" : (value >= 0.0 ? "+" : "") + str.tostring(value, "0.0") + " ATR"

f_score_grade(float value) =>
    string grade = "-"
    if not na(value)
        if value >= 86
            grade := "A+"
        else if value >= 78
            grade := "A"
        else if value >= 68
            grade := "B"
        else if value >= 56
            grade := "C"
        else
            grade := "D"
    grade

f_side_text(int side) =>
    side == 1 ? "Low Reclaim" : side == -1 ? "High Reclaim" : "-"

f_side_badge_text(int side) =>
    side == 1 ? "LOW RECLAIM" : side == -1 ? "HIGH RECLAIM" : "RECLAIM"

f_side_color(int side) =>
    side == 1 ? bullColor : side == -1 ? bearColor : neutralColor

f_score_color(float value) =>
    color result = panelValueCol
    if not na(value)
        result := value >= planReviewThreshold ? bullColor : value >= watchThreshold ? neutralColor : dangerColor
    result

f_panel_bg() =>
    panelTheme == "Light" ? color.rgb(248, 250, 252) : panelBg

f_panel_border() =>
    panelTheme == "Light" ? color.rgb(203, 213, 225) : panelBorder

f_panel_label_color() =>
    panelTheme == "Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value_color() =>
    panelTheme == "Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(int row) =>
    bool evenRow = row % 2 == 0
    if panelTheme == "Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)
    else
        evenRow ? color.rgb(20, 31, 52) : panelBg

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, string fontInput) =>
    color rowBg = f_row_bg(row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label_color(), bgcolor = rowBg, text_size = f_text_size(fontInput), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(fontInput), text_halign = text.align_right)

f_target_price(int side, float level, float riskEdge, float sessionHigh, float sessionLow) =>
    float riskDistance = math.max(math.abs(level - riskEdge), syminfo.mintick)
    float rangeDistance = math.max(math.abs(sessionHigh - sessionLow), syminfo.mintick)
    float railTarget = side == 1 ? sessionHigh : sessionLow
    float rTarget = level + side * riskDistance * targetRMultiple
    float halfRangeTarget = level + side * rangeDistance * 0.50
    float result = railTarget
    if targetModel == "R Multiple"
        result := rTarget
    else if targetModel == "Hybrid Rail / R"
        result := side == 1 ? math.min(math.max(railTarget, halfRangeTarget), rTarget) : math.max(math.min(railTarget, halfRangeTarget), rTarget)
    result

f_reclaim_score(int side, float level, float riskEdge, float targetPrice, float sessionHigh, float sessionLow, int acceptedCloses, int acceptedNeeded, float volumeRatio, float atrValue, float closeValue) =>
    float safeAtr = math.max(atrValue, syminfo.mintick)
    float closeDistanceAtr = (side == 1 ? closeValue - level : level - closeValue) / safeAtr
    float closeScore = f_norm_high_good(closeDistanceAtr, 0.00, 0.50)
    float acceptanceScore = f_clamp(float(acceptedCloses) / math.max(float(acceptedNeeded), 1.0) * 100.0, 0.0, 100.0)
    float participationScore = na(volumeRatio) ? 55.0 : f_norm_high_good(volumeRatio, 0.70, 1.55)
    float riskDistance = math.max(math.abs(level - riskEdge), syminfo.mintick)
    float roomDistance = math.abs(targetPrice - closeValue)
    float roomR = roomDistance / riskDistance
    float roomScore = f_norm_high_good(roomR, 0.35, 1.65)
    float sessionRangeAtr = math.abs(sessionHigh - sessionLow) / safeAtr
    float rangeFitScore = f_peak_score(sessionRangeAtr, 0.45, 2.20, 6.00)
    f_clamp(closeScore * 0.25 + acceptanceScore * 0.25 + participationScore * 0.18 + roomScore * 0.22 + rangeFitScore * 0.10, 0.0, 100.0)

f_mid_bar(int leftBar, int rightBar) =>
    int safeLeft = math.max(leftBar, bar_index - 9999)
    int(math.round((safeLeft + rightBar) / 2.0))

f_badge_step(float atrValue) =>
    math.max(math.max(atrValue, syminfo.mintick) * badgeLaneAtr, syminfo.mintick * 20.0)

f_level_badge_y(float basePrice, int side, int lane, float atrValue) =>
    float dir = side == 1 ? -1.0 : side == -1 ? 1.0 : 1.0
    useSmartBadgeLanes ? basePrice + dir * f_badge_step(atrValue) * lane : basePrice

f_target_badge_y(float basePrice, int side, int lane, float atrValue) =>
    float dir = side == 1 ? 1.0 : side == -1 ? -1.0 : 1.0
    useSmartBadgeLanes ? basePrice + dir * f_badge_step(atrValue) * lane : basePrice

f_state_color(string stateText, int side, float scoreValue) =>
    color result = neutralColor
    if stateText == "Plan Review"
        result := f_side_color(side)
    else if stateText == "Acceptance Watch"
        result := accentColor
    else if stateText == "Failed Reclaim" or stateText == "Risk Edge Test"
        result := dangerColor
    else if stateText == "Target Review"
        result := bullColor
    else if stateText == "Needs More Proof"
        result := f_score_color(scoreValue)
    result

// -------------------------------------------------
// Object storage
// -------------------------------------------------
// Active session and plan objects are managed as single handles (delete-then-create)
// so only the current session range and the active reclaim plan are ever shown.
// Only historical event labels use a rolling store.
var label[] labelStore = array.new_label()

f_event_label_limit() =>
    int result = maxVisibleLabels
    if timeframe.isminutes and timeframe.multiplier >= 240
        result := math.min(result, 4)
    else if timeframe.isminutes and timeframe.multiplier >= 60
        result := math.min(result, 6)
    result

f_keep_label(label item) =>
    if not na(item)
        array.push(labelStore, item)
        while array.size(labelStore) > f_event_label_limit()
            label.delete(array.shift(labelStore))

f_center_label(int x, float y, string textValue, color bgColor) =>
    label.new(x, y, textValue, style = label.style_label_center, color = bgColor, textcolor = f_text_on(bgColor), size = f_text_size(labelFontSize))

f_event_label(int x, float y, string textValue, int side, color bgColor) =>
    label item = label.new(x, y, textValue, style = side == 1 ? label.style_label_up : label.style_label_down, color = bgColor, textcolor = f_text_on(bgColor), size = f_text_size(labelFontSize))
    f_keep_label(item)
    item

// Pushes a new event label away from the previous one when they would stack at a similar price.
f_safe_event_y(float desiredY, float lastY, int lastBar, float atrValue) =>
    float adj = desiredY
    if not na(lastY) and not na(lastBar) and (bar_index - lastBar) <= labelCooldownBars * 3
        float gap = f_badge_step(atrValue) * 1.25
        if math.abs(adj - lastY) < gap
            float candidate = lastY + (adj >= lastY ? gap : -gap)
            float maxShift = math.max(atrValue, syminfo.mintick) * 0.65
            adj := math.max(desiredY - maxShift, math.min(desiredY + maxShift, candidate))
    adj

// -------------------------------------------------
// Core session engine
// -------------------------------------------------
float atrRaw = ta.atr(atrLength)
float atrUse = math.max(nz(atrRaw), ta.tr(true), syminfo.mintick)
float volumeBase = ta.sma(volume, volumeLength)
float volumeRatio = na(volumeBase) or volumeBase <= 0.0 ? 1.0 : volume / volumeBase

bool isIntraday = timeframe.isintraday
int visualTfLimit = visualTfPreset == "4H and lower" ? 240 : 60
bool minuteVisualOk = timeframe.isminutes and timeframe.multiplier <= visualTfLimit
bool visualTimeframeOk = isIntraday and (visualTfPreset == "All intraday" or minuteVisualOk)
bool inBuildSession = isIntraday and not na(time(timeframe.period, buildSession, sessionTz))
bool inMonitorSession = isIntraday and not na(time(timeframe.period, monitorSession, sessionTz))
bool prevInBuildSession = inBuildSession[1] == true
bool newBuildSession = inBuildSession and not prevInBuildSession
bool buildSessionEnded = not inBuildSession and prevInBuildSession
bool allowLowRail = levelMode != "High Only"
bool allowHighRail = levelMode != "Low Only"
bool validClose = confirmOnClose ? barstate.isconfirmed : true

var float sessionHigh = na
var float sessionLow = na
var int buildStartBar = na
var int buildEndBar = na
var bool levelsReady = false
var box activeSessionBox = na
var label activeSessionLabel = na
var line activeHighRail = na
var line activeLowRail = na

var int watchSide = 0
var float watchLevel = na
var float watchExtreme = na
var int watchStartBar = na

var bool hasActivePlan = false
var int activeSide = 0
var float activeLevel = na
var float activeExtreme = na
var float activeRiskEdge = na
var float activeTarget = na
var float activeScore = na
var int activeStartBar = na
var int activeAcceptCount = 0
var bool activeFailed = false
var bool activeRiskTouched = false
var bool activeTargetReached = false
var bool planReviewPrinted = false
var bool failedPrinted = false
var bool targetPrinted = false

var box activePocketBox = na
var label activePocketLabel = na
var box activeTargetBox = na
var label activeTargetLabel = na
var line activeLevelLine = na
var line activeRiskLine = na
var line activeTargetLine = na
var int lastEventLabelBar = na
var float lastEventLabelY = na

// Stop-aware proof engine state (reclaim plans that reached target before risk edge)
var bool proofPending = false
var int proofSide = 0
var float proofRiskEdge = na
var float proofTarget = na
var int proofStartBar = na
var int proofWins = 0
var int proofCount = 0
var int lastReclaimResult = 0   // 1 = win, -1 = loss, 0 = none yet

bool newBullReclaim = false
bool newBearReclaim = false
bool newPlanReview = false
bool newFailedReclaim = false
bool newTargetReview = false

if newBuildSession
    label.delete(activeSessionLabel)
    label.delete(activePocketLabel)
    label.delete(activeTargetLabel)
    box.delete(activeSessionBox)
    box.delete(activePocketBox)
    box.delete(activeTargetBox)
    line.delete(activeHighRail)
    line.delete(activeLowRail)
    line.delete(activeLevelLine)
    line.delete(activeRiskLine)
    line.delete(activeTargetLine)
    sessionHigh := high
    sessionLow := low
    buildStartBar := bar_index
    buildEndBar := bar_index
    levelsReady := false
    watchSide := 0
    watchLevel := na
    watchExtreme := na
    watchStartBar := na
    hasActivePlan := false
    activeSide := 0
    activeLevel := na
    activeExtreme := na
    activeRiskEdge := na
    activeTarget := na
    activeScore := na
    activeStartBar := na
    activeAcceptCount := 0
    activeFailed := false
    activeRiskTouched := false
    activeTargetReached := false
    planReviewPrinted := false
    failedPrinted := false
    targetPrinted := false
    activePocketBox := na
    activePocketLabel := na
    activeTargetBox := na
    activeTargetLabel := na
    activeLevelLine := na
    activeRiskLine := na
    activeTargetLine := na
    if showSessionRangeBox and visualTimeframeOk
        activeSessionBox := box.new(bar_index, sessionHigh, bar_index, sessionLow, bgcolor = color.new(accentColor, 93), border_color = color.new(accentColor, 38), border_width = 1)
        activeSessionLabel := f_center_label(bar_index, math.avg(sessionHigh, sessionLow), "SESSION RAILS", color.new(accentColor, 8))
    if showSessionRails and visualTimeframeOk
        activeHighRail := line.new(bar_index, sessionHigh, bar_index + 1, sessionHigh, color = color.new(bearColor, 12), width = 1, style = line.style_dashed)
        activeLowRail := line.new(bar_index, sessionLow, bar_index + 1, sessionLow, color = color.new(bullColor, 12), width = 1, style = line.style_dashed)

if inBuildSession
    sessionHigh := math.max(nz(sessionHigh, high), high)
    sessionLow := math.min(nz(sessionLow, low), low)
    buildEndBar := bar_index
    if showSessionRangeBox and not na(activeSessionBox)
        box.set_right(activeSessionBox, bar_index)
        box.set_top(activeSessionBox, sessionHigh)
        box.set_bottom(activeSessionBox, sessionLow)
    if showSessionRangeBox and not na(activeSessionLabel)
        label.set_x(activeSessionLabel, f_mid_bar(nz(buildStartBar, bar_index), bar_index))
        label.set_y(activeSessionLabel, math.avg(sessionHigh, sessionLow))
        label.set_size(activeSessionLabel, f_text_size(labelFontSize))
    if showSessionRails and not na(activeHighRail)
        line.set_x2(activeHighRail, bar_index + projectionBars)
        line.set_y1(activeHighRail, sessionHigh)
        line.set_y2(activeHighRail, sessionHigh)
    if showSessionRails and not na(activeLowRail)
        line.set_x2(activeLowRail, bar_index + projectionBars)
        line.set_y1(activeLowRail, sessionLow)
        line.set_y2(activeLowRail, sessionLow)

if buildSessionEnded and not na(sessionHigh) and not na(sessionLow) and sessionHigh > sessionLow
    levelsReady := true

if levelsReady and showSessionRails
    if not na(activeHighRail)
        line.set_x2(activeHighRail, bar_index + projectionBars)
        line.set_y1(activeHighRail, sessionHigh)
        line.set_y2(activeHighRail, sessionHigh)
    if not na(activeLowRail)
        line.set_x2(activeLowRail, bar_index + projectionBars)
        line.set_y1(activeLowRail, sessionLow)
        line.set_y2(activeLowRail, sessionLow)

bool canEvaluate = isIntraday and levelsReady and inMonitorSession and not inBuildSession and not na(sessionHigh) and not na(sessionLow)
bool canPrintEvent = visualTimeframeOk and (na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars)

if canEvaluate and validClose and not hasActivePlan and watchSide == 0
    float lowSweepDepth = allowLowRail ? (sessionLow - low) / atrUse : 0.0
    float highSweepDepth = allowHighRail ? (high - sessionHigh) / atrUse : 0.0
    bool hasLowSweep = lowSweepDepth >= minimumSweepAtr
    bool hasHighSweep = highSweepDepth >= minimumSweepAtr
    if hasLowSweep or hasHighSweep
        if hasLowSweep and (not hasHighSweep or lowSweepDepth >= highSweepDepth)
            watchSide := 1
            watchLevel := sessionLow
            watchExtreme := low
            watchStartBar := bar_index
        else
            watchSide := -1
            watchLevel := sessionHigh
            watchExtreme := high
            watchStartBar := bar_index

if canEvaluate and validClose and not hasActivePlan and watchSide != 0
    watchExtreme := watchSide == 1 ? math.min(nz(watchExtreme, low), low) : math.max(nz(watchExtreme, high), high)
    bool watchExpired = bar_index - nz(watchStartBar, bar_index) > reclaimWindowBars
    bool reclaimedRail = watchSide == 1 ? close >= watchLevel + minimumReclaimAtr * atrUse : close <= watchLevel - minimumReclaimAtr * atrUse
    if watchExpired
        watchSide := 0
        watchLevel := na
        watchExtreme := na
        watchStartBar := na
    else if reclaimedRail
        if not na(activePocketLabel)
            label.delete(activePocketLabel)
            activePocketLabel := na
        if not na(activeTargetLabel)
            label.delete(activeTargetLabel)
            activeTargetLabel := na
        hasActivePlan := true
        activeSide := watchSide
        activeLevel := watchLevel
        activeExtreme := watchExtreme
        activeStartBar := bar_index
        activeAcceptCount := 1
        activeFailed := false
        activeRiskTouched := false
        activeTargetReached := false
        planReviewPrinted := false
        failedPrinted := false
        targetPrinted := false
        // The completed session range has served its purpose once a reclaim
        // plan is active. Rails remain, while the overlapping range box and
        // badge are retired so the pocket and target own the decision map.
        if not na(activeSessionLabel)
            label.delete(activeSessionLabel)
            activeSessionLabel := na
        if not na(activeSessionBox)
            box.delete(activeSessionBox)
            activeSessionBox := na
        float pocketSize = reclaimPocketAtr * atrUse
        activeRiskEdge := activeSide == 1 ? math.min(activeExtreme, activeLevel - pocketSize) - riskBufferAtr * atrUse : math.max(activeExtreme, activeLevel + pocketSize) + riskBufferAtr * atrUse
        activeTarget := f_target_price(activeSide, activeLevel, activeRiskEdge, sessionHigh, sessionLow)
        activeScore := f_reclaim_score(activeSide, activeLevel, activeRiskEdge, activeTarget, sessionHigh, sessionLow, activeAcceptCount, acceptanceBars, volumeRatio, atrUse, close)
        newBullReclaim := activeSide == 1 and activeScore >= alertScoreThreshold
        newBearReclaim := activeSide == -1 and activeScore >= alertScoreThreshold
        // Open a fresh stop-aware proof sample for this reclaim plan
        proofPending := true
        proofSide := activeSide
        proofRiskEdge := activeRiskEdge
        proofTarget := activeTarget
        proofStartBar := bar_index
        watchSide := 0
        watchLevel := na
        watchExtreme := na
        watchStartBar := na
        int visualRight = bar_index + projectionBars
        float pocketTop = activeLevel + pocketSize
        float pocketBottom = activeLevel - pocketSize
        float targetBand = targetCorridorAtr * atrUse
        float targetTop = activeTarget + targetBand
        float targetBottom = activeTarget - targetBand
        color planColor = f_side_color(activeSide)
        box.delete(activePocketBox)
        box.delete(activeTargetBox)
        line.delete(activeLevelLine)
        line.delete(activeRiskLine)
        line.delete(activeTargetLine)
        if showReclaimPocket and visualTimeframeOk
            activePocketBox := box.new(bar_index, pocketTop, visualRight, pocketBottom, bgcolor = color.new(planColor, 86), border_color = color.new(planColor, 20), border_width = 1)
            activePocketLabel := f_center_label(f_mid_bar(bar_index, visualRight), activeLevel, f_side_badge_text(activeSide), color.new(planColor, 4))
        if showTargetCorridor and visualTimeframeOk
            activeTargetBox := box.new(bar_index, targetTop, visualRight, targetBottom, bgcolor = color.new(accentColor, 88), border_color = color.new(accentColor, 26), border_width = 1)
            activeTargetLabel := f_center_label(f_mid_bar(bar_index, visualRight), activeTarget, "TARGET CORRIDOR", color.new(accentColor, 6))
        if showSessionRails and visualTimeframeOk
            activeLevelLine := line.new(bar_index, activeLevel, visualRight, activeLevel, color = color.new(planColor, 0), width = 2)
            activeRiskLine := line.new(bar_index, activeRiskEdge, visualRight, activeRiskEdge, color = color.new(dangerColor, 0), width = 1, style = line.style_dashed)
            activeTargetLine := line.new(bar_index, activeTarget, visualRight, activeTarget, color = color.new(accentColor, 0), width = 1, style = line.style_dotted)
        if showEventLabels and canPrintEvent
            string scorePart = showLabelScore ? " · " + f_fmt_score(activeScore) : ""
            string eventText = f_side_badge_text(activeSide) + scorePart
            float activationBaseY = activeSide == 1 ? low - labelOffsetAtr * atrUse : high + labelOffsetAtr * atrUse
            float eventY = f_safe_event_y(activationBaseY, lastEventLabelY, lastEventLabelBar, atrUse)
            f_event_label(bar_index, eventY, eventText, activeSide, color.new(planColor, 4))
            lastEventLabelBar := bar_index
            lastEventLabelY := eventY

if hasActivePlan
    if validClose and bar_index > nz(activeStartBar, bar_index)
        bool closeAccepted = activeSide == 1 ? close >= activeLevel : close <= activeLevel
        activeAcceptCount := closeAccepted ? math.min(activeAcceptCount + 1, acceptanceBars) : 0
    if validClose
        activeTarget := f_target_price(activeSide, activeLevel, activeRiskEdge, sessionHigh, sessionLow)
        activeScore := f_reclaim_score(activeSide, activeLevel, activeRiskEdge, activeTarget, sessionHigh, sessionLow, activeAcceptCount, acceptanceBars, volumeRatio, atrUse, close)
    bool riskTouchedNow = activeSide == 1 ? low <= activeRiskEdge : high >= activeRiskEdge
    bool riskClosedNow = activeSide == 1 ? close <= activeRiskEdge : close >= activeRiskEdge
    bool targetTouchedNow = activeSide == 1 ? high >= activeTarget : low <= activeTarget
    if validClose
        activeRiskTouched := activeRiskTouched or riskTouchedNow
    if validClose and riskClosedNow and not activeFailed
        activeFailed := true
        newFailedReclaim := activeScore >= watchThreshold
        if not na(activePocketBox)
            box.set_bgcolor(activePocketBox, color.new(dangerColor, 88))
            box.set_border_color(activePocketBox, color.new(dangerColor, 12))
        if not na(activePocketLabel)
            label.set_text(activePocketLabel, "FAILED RECLAIM")
            label.set_color(activePocketLabel, color.new(dangerColor, 2))
            label.set_textcolor(activePocketLabel, f_text_on(dangerColor))
        if not na(activeTargetLabel)
            label.delete(activeTargetLabel)
            activeTargetLabel := na
        if not na(activeTargetBox)
            box.delete(activeTargetBox)
            activeTargetBox := na
        if not na(activeTargetLine)
            line.delete(activeTargetLine)
            activeTargetLine := na
    if validClose and targetTouchedNow and not activeTargetReached and not activeFailed
        activeTargetReached := true
        newTargetReview := activeScore >= alertScoreThreshold
        if not na(activeTargetLabel)
            label.set_text(activeTargetLabel, "TARGET HIT")
            label.set_color(activeTargetLabel, color.new(bullColor, 4))
            label.set_textcolor(activeTargetLabel, f_text_on(bullColor))
    bool planReadyNow = validClose and not activeFailed and not activeTargetReached and activeScore >= planReviewThreshold and activeAcceptCount >= acceptanceBars
    if planReadyNow and not planReviewPrinted
        newPlanReview := true
        planReviewPrinted := true
        if showEventLabels and visualTimeframeOk
            string scorePart = showLabelScore ? " · " + f_fmt_score(activeScore) : ""
            float eventY = f_safe_event_y(activeSide == 1 ? low - labelOffsetAtr * atrUse : high + labelOffsetAtr * atrUse, lastEventLabelY, lastEventLabelBar, atrUse)
            f_event_label(bar_index, eventY, "PLAN REVIEW" + scorePart, activeSide, color.new(f_side_color(activeSide), 2))
            lastEventLabelBar := bar_index
            lastEventLabelY := eventY
    if activeFailed and not failedPrinted
        failedPrinted := true
        if showEventLabels and visualTimeframeOk
            float eventY = f_safe_event_y(activeSide == 1 ? high + labelOffsetAtr * atrUse : low - labelOffsetAtr * atrUse, lastEventLabelY, lastEventLabelBar, atrUse)
            f_event_label(bar_index, eventY, "FAILED RECLAIM", -activeSide, color.new(dangerColor, 2))
            lastEventLabelBar := bar_index
            lastEventLabelY := eventY
    if activeTargetReached and not targetPrinted
        targetPrinted := true
        if showEventLabels and visualTimeframeOk
            float eventY = f_safe_event_y(activeSide == 1 ? high + labelOffsetAtr * atrUse : low - labelOffsetAtr * atrUse, lastEventLabelY, lastEventLabelBar, atrUse)
            f_event_label(bar_index, eventY, "TARGET HIT", -activeSide, color.new(bullColor, 4))
            lastEventLabelBar := bar_index
            lastEventLabelY := eventY
    int activeRight = bar_index + projectionBars
    float activePocket = reclaimPocketAtr * atrUse
    float targetBandLive = targetCorridorAtr * atrUse
    string pocketStateText = activeFailed ? "FAILED RECLAIM" : activeTargetReached ? "TARGET REVIEW" : planReviewPrinted ? "PLAN REVIEW\n" + f_side_badge_text(activeSide) : activeScore >= watchThreshold ? "ACCEPTANCE WATCH\n" + f_side_badge_text(activeSide) : f_side_badge_text(activeSide)
    color pocketStateColor = activeFailed ? dangerColor : activeTargetReached ? bullColor : planReviewPrinted ? f_side_color(activeSide) : activeScore >= watchThreshold ? accentColor : f_side_color(activeSide)
    if showReclaimPocket and not na(activePocketBox)
        box.set_right(activePocketBox, activeRight)
        box.set_top(activePocketBox, activeLevel + activePocket)
        box.set_bottom(activePocketBox, activeLevel - activePocket)
        box.set_bgcolor(activePocketBox, color.new(pocketStateColor, 86))
        box.set_border_color(activePocketBox, color.new(pocketStateColor, 18))
    if showReclaimPocket and not na(activePocketLabel)
        label.set_x(activePocketLabel, f_mid_bar(nz(activeStartBar, bar_index), activeRight))
        label.set_y(activePocketLabel, activeLevel)
        label.set_text(activePocketLabel, pocketStateText)
        label.set_color(activePocketLabel, color.new(pocketStateColor, 4))
        label.set_textcolor(activePocketLabel, f_text_on(pocketStateColor))
        label.set_size(activePocketLabel, f_text_size(labelFontSize))
    if showTargetCorridor and not na(activeTargetBox)
        box.set_right(activeTargetBox, activeRight)
        box.set_top(activeTargetBox, activeTarget + targetBandLive)
        box.set_bottom(activeTargetBox, activeTarget - targetBandLive)
    if showTargetCorridor and not na(activeTargetLabel)
        label.set_x(activeTargetLabel, f_mid_bar(nz(activeStartBar, bar_index), activeRight))
        label.set_y(activeTargetLabel, activeTarget)
        label.set_size(activeTargetLabel, f_text_size(labelFontSize))
    if showSessionRangeBox and not na(activeSessionLabel)
        label.set_x(activeSessionLabel, f_mid_bar(nz(buildStartBar, bar_index), nz(buildEndBar, bar_index)))
        label.set_y(activeSessionLabel, math.avg(sessionHigh, sessionLow))
        label.set_size(activeSessionLabel, f_text_size(labelFontSize))
    if showSessionRails and not na(activeLevelLine)
        line.set_x2(activeLevelLine, activeRight)
        line.set_y1(activeLevelLine, activeLevel)
        line.set_y2(activeLevelLine, activeLevel)
    if showSessionRails and not na(activeRiskLine)
        line.set_x2(activeRiskLine, activeRight)
        line.set_y1(activeRiskLine, activeRiskEdge)
        line.set_y2(activeRiskLine, activeRiskEdge)
    if showSessionRails and not na(activeTargetLine)
        line.set_x2(activeTargetLine, activeRight)
        line.set_y1(activeTargetLine, activeTarget)
        line.set_y2(activeTargetLine, activeTarget)
    if validClose and bar_index - nz(activeStartBar, bar_index) > planExpiryBars
        hasActivePlan := false

// -------------------------------------------------
// Stop-aware proof resolution (target before risk edge)
// -------------------------------------------------
if barstate.isconfirmed and proofPending and not na(proofRiskEdge) and not na(proofTarget)
    bool proofLoss = proofSide == 1 ? low <= proofRiskEdge : high >= proofRiskEdge
    bool proofWin = proofSide == 1 ? high >= proofTarget : low <= proofTarget
    if proofLoss
        proofCount += 1
        proofPending := false
        lastReclaimResult := -1
    else if proofWin
        proofWins += 1
        proofCount += 1
        proofPending := false
        lastReclaimResult := 1
    else if not na(proofStartBar) and bar_index - proofStartBar >= planExpiryBars
        proofPending := false

float proofRate = proofCount > 0 ? proofWins / proofCount * 100.0 : na
bool proofReady = proofCount >= 6
color proofTierCol = not proofReady ? panelLabelCol : proofRate >= 55.0 ? bullColor : proofRate >= 45.0 ? neutralColor : bearColor
string proofValue = not proofReady ? "Building (" + str.tostring(proofCount) + ")" : str.tostring(math.round(proofRate), "0") + "% (" + str.tostring(proofCount) + ")"

// -------------------------------------------------
// Panel text (always populated, never blank)
// -------------------------------------------------
bool activeRiskTesting = hasActivePlan and not activeFailed and not activeTargetReached and activeRiskTouched
string stateText = "Monitor Rails"
if not isIntraday
    stateText := "Intraday Only"
else if not levelsReady
    stateText := "Build Session Rails"
else if watchSide != 0
    stateText := "Reclaim Watch"
else if hasActivePlan
    if activeFailed
        stateText := "Failed Reclaim"
    else if activeTargetReached
        stateText := "Target Review"
    else if activeRiskTesting
        stateText := "Risk Edge Test"
    else if activeScore >= planReviewThreshold and activeAcceptCount >= acceptanceBars
        stateText := "Plan Review"
    else if activeScore >= watchThreshold
        stateText := "Acceptance Watch"
    else
        stateText := "Needs More Proof"

string actionText = "Monitor session rails"
if not isIntraday
    actionText := "Use intraday chart"
else if not levelsReady
    actionText := "Let session build"
else if watchSide != 0
    actionText := "Wait for reclaim close"
else if hasActivePlan
    if activeFailed
        actionText := "Stop reviewing plan"
    else if activeTargetReached
        actionText := "Review target reaction"
    else if activeScore >= planReviewThreshold and activeAcceptCount >= acceptanceBars
        actionText := "Review risk and target"
    else if activeScore >= watchThreshold
        actionText := "Wait for acceptance"
    else
        actionText := "Need more proof"
else
    actionText := "Monitor session rails"

// Session rails row never blank
string railsText = not isIntraday ? "Intraday chart only" : not levelsReady ? "Building rails..." : "H " + f_fmt_price(sessionHigh) + "  L " + f_fmt_price(sessionLow)

// Score row never blank
string scoreText = "—"
if hasActivePlan
    scoreText := f_fmt_score(activeScore) + "/100 " + f_score_grade(activeScore) + " · " + str.tostring(activeAcceptCount) + "/" + str.tostring(acceptanceBars)
else if watchSide != 0
    scoreText := "Watching reclaim"
else if levelsReady
    scoreText := "Idle · no active plan"
else if isIntraday
    scoreText := "Building rails..."

// Risk / Target row never blank: live context even when idle
string riskTargetText = "Let session build"
if hasActivePlan
    riskTargetText := "R " + f_fmt_price(activeRiskEdge) + "  T " + f_fmt_price(activeTarget)
else if watchSide != 0
    riskTargetText := "Watch " + f_side_text(watchSide)
else if levelsReady
    float distHigh = (sessionHigh - close) / atrUse
    float distLow = (close - sessionLow) / atrUse
    riskTargetText := math.abs(distHigh) <= math.abs(distLow) ? "High rail " + f_fmt_atr(distHigh) : "Low rail " + f_fmt_atr(distLow)
else if not isIntraday
    riskTargetText := "Use intraday chart"

color stateTone = f_state_color(stateText, hasActivePlan ? activeSide : watchSide, activeScore)
color scoreTone = hasActivePlan ? f_score_color(activeScore) : f_panel_label_color()
color railsTone = levelsReady ? f_panel_value_color() : f_panel_label_color()

// -------------------------------------------------
// Premium panel (7 rows, proof always alive)
// -------------------------------------------------
var table infoPanel = na
var string lastPanelLocation = na
var string lastPanelTheme = na

if showPanel and barstate.islast
    color panelBgActive = f_panel_bg()
    color panelBorderActive = f_panel_border()
    if na(infoPanel) or lastPanelLocation != panelLocation or lastPanelTheme != panelTheme
        if not na(infoPanel)
            table.delete(infoPanel)
        infoPanel := table.new(f_panel_pos(panelLocation), 2, 7, bgcolor = panelBgActive, frame_color = panelBorderActive, frame_width = 1, border_color = panelBorderActive, border_width = 1)
        table.merge_cells(infoPanel, 0, 0, 1, 0)
        lastPanelLocation := panelLocation
        lastPanelTheme := panelTheme
    table.cell(infoPanel, 0, 0, "AG Pro Session Reclaim Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
    f_panel_row(infoPanel, 1, "State", stateText, stateTone, panelFontSize)
    f_panel_row(infoPanel, 2, "Session Rails", railsText, railsTone, panelFontSize)
    f_panel_row(infoPanel, 3, "Reclaim Score", scoreText, scoreTone, panelFontSize)
    color proofRowBg = proofReady ? color.new(proofTierCol, 12) : f_row_bg(4)
    color proofInk = proofReady ? f_text_on(proofTierCol) : f_panel_label_color()
    table.cell(infoPanel, 0, 4, "Reclaim Proof", text_color = f_panel_label_color(), bgcolor = f_row_bg(4), text_size = f_text_size(panelFontSize), text_halign = text.align_left)
    table.cell(infoPanel, 1, 4, proofValue, text_color = proofInk, bgcolor = proofRowBg, text_size = f_text_size(panelFontSize), text_halign = text.align_right)
    f_panel_row(infoPanel, 5, "Risk / Target", riskTargetText, hasActivePlan ? dangerColor : f_panel_value_color(), panelFontSize)
    f_panel_row(infoPanel, 6, "Action", actionText, stateTone, panelFontSize)

if not showPanel and not na(infoPanel)
    table.delete(infoPanel)
    infoPanel := na
    lastPanelLocation := na
    lastPanelTheme := na

// -------------------------------------------------
// Data window
// -------------------------------------------------
plot(hasActivePlan ? activeScore : na, "Reclaim Score", color = scoreTone, display = display.data_window)
plot(proofReady ? proofRate : na, "Reclaim Proof Rate", color = proofTierCol, display = display.data_window)
plot(levelsReady ? sessionHigh : na, "Session High Rail", color = bearColor, display = display.data_window)
plot(levelsReady ? sessionLow : na, "Session Low Rail", color = bullColor, display = display.data_window)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(newBullReclaim, "Bullish Session Reclaim", "Session Reclaim Planner detected a bullish session-low reclaim with sufficient score. Review acceptance, risk edge, target corridor, and broader context.")
alertcondition(newBearReclaim, "Bearish Session Reclaim", "Session Reclaim Planner detected a bearish session-high reclaim with sufficient score. Review acceptance, risk edge, target corridor, and broader context.")
alertcondition(newPlanReview and activeScore >= alertScoreThreshold, "Session Reclaim Plan Review", "Session Reclaim Planner moved an active reclaim into Plan Review. Alerts are attention markers, not trade instructions.")
alertcondition(newFailedReclaim, "Session Reclaim Failed", "Session Reclaim Planner detected a failed reclaim at the risk edge. Review context before making any decision.")
alertcondition(newTargetReview, "Session Reclaim Target Review", "Session Reclaim Planner detected that the active target corridor was reached. Review reaction and broader market context.")
````

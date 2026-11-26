# Failed Pullback Reversal Planner [AGPro Series]

- url: https://www.tradingview.com/script/gc2VR8OV-Failed-Pullback-Reversal-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;84b7795dc203475a82e88170505cb950
- version: 5.0

## Description

Failed Pullback Reversal Planner [AGPro Series]

🧠 Core Idea

Did the pullback fail to recover, and is it now creating a reversal-warning context?


📌 Overview / What it does

Failed Pullback Reversal Planner [AGPro Series] is a chart-first reversal risk planner built for one specific situation: a pullback inside an existing trend stops behaving like a healthy retracement and begins losing control.

The script maps a failed pullback pocket, control-loss rail, invalidation reference, target-room guide, compact state labels, alerts, and a clean AG Pro panel. It converts pullback depth, failed recovery, close behavior, volume response, and follow-through into a 0-100 Failure Score.

It does not predict future price movement, automate entries, or issue guaranteed buy/sell signals. Its role is to organize failed-pullback context into a clearer decision framework.


🎯 Purpose & Design Philosophy

This script was built because many pullback tools only focus on continuation quality. They often ask whether the pullback is healthy enough to resume the original trend.

Failed Pullback Reversal Planner focuses on the opposite decision layer. It asks whether the pullback failed to recover, lost the control reference, and now deserves reversal-risk review.

The design supports traders who want cleaner structure, risk location, target-room context, and next-action guidance without turning every candle into a signal.


⚡ Why This Script Is Different

Most tools focus on pullback continuation, moving-average bounces, or generic reversal markers.

This script does NOT clone Pullback Acceptance Planner, Low Volume Pullback Zones, Trend Continuation Quality, or a generic reversal signal indicator.

Instead, it treats failed pullbacks as a planning problem. Price must first enter a pullback context, then fail recovery around a control rail, then show enough close quality, volume response, and follow-through to raise reversal-risk state.


⚙️ Methodology

1. Context Detection
The script identifies former bullish or bearish trend context using fast, base, and slow EMA alignment.

2. Reference Mapping
It builds a failed pullback pocket, control-loss rail, invalidation reference, and target-room guide using ATR-normalized logic.

3. Reaction Evaluation
It scores pullback depth, failed recovery, close against the former trend, volume response, and nearby follow-through.

4. Visual Output
It displays concept-native zones, centered zone labels, compact event labels, guide rails, alerts, and a premium AG Pro planning panel.


🗺️ How to Read the Chart

Zones = the failed pullback pocket and reversal-risk zone.

Labels = pullback test, control-loss, reversal-risk, or reset markers.

Colors = teal shows bullish reversal-risk context, pink shows bearish reversal-risk context, amber shows watch context, red shows control-loss or risk context, and indigo shows reset/recovery context.

Panel = a compact decision dashboard showing Pullback State, Failure Score, Reversal Risk, Invalidation, and Action.


🚦 Signals & States

• PB TEST → a recent pullback is being monitored for failed-recovery behavior.

• CTRL LOST → price has lost the control reference but has not fully qualified the warning state.

• REV RISK → failed pullback context has enough score to deserve reversal-risk review.

• RESET → optional marker showing that price reclaimed the invalidation reference and the failed-pullback plan should be reset.

• NO SETUP → no active failed-pullback context is present.


🔔 Alerts Logic

Alerts trigger when the planner detects a monitored failed-pullback setup, a reversal-risk warning, invalidation/reset behavior, or meaningful follow-through after control loss.

Alerts are attention markers only. They are not trade instructions.


🧩 Confluence Logic

The strongest failed-pullback context appears when pullback depth is meaningful, price loses the control rail, the candle closes against the former trend, volume supports the shift, and follow-through begins beyond nearby structure.

When these components align, the Failure Score rises and the panel moves from watch context toward reversal-risk review.


📊 When to Use

• Trend pullbacks that start losing recovery quality

• Potential reversal transitions after a failed retracement

• Markets where a prior trend is weakening around a control reference

• Situations where invalidation and target-room context matter


⚠️ When NOT to Use

• Very low liquidity markets

• Extremely noisy sideways conditions

• News-driven volatility spikes

• Markets with no clean prior trend context

• Symbols where volume behavior is unreliable


🎛️ Key Inputs

• Sensitivity → controls how strict the failed-pullback model is.

• Former Trend Side → restricts evaluation to bullish-trend or bearish-trend failures when needed.

• Failure Window Bars → defines how long after a pullback touch control-loss behavior can qualify.

• Control-Loss Buffer ATR → adjusts the rail used to mark failed recovery.

• Invalidation Buffer ATR → controls the reset reference beyond the fast trend anchor.

• Label and Panel Settings → control panel location, theme, font size, label size, label spacing, and visible label count.


🖥️ Interface & Visual Design

The interface is built around a clean AG Pro decision panel and chart-first planning visuals.

The first panel row uses the AG Pro merged blue header standard with only the script name. The remaining rows focus on the active decision: pullback state, failure score, reversal risk, invalidation, and action.

The chart uses a focused failed pullback pocket, a reversal-risk zone, guide rails, and compact labels. The goal is a premium planning view without crowded generic signals.


🧪 Practical Usage Workflow

1. Read the panel state.

2. Check whether a pullback test is active.

3. Watch whether price loses the control rail.

4. Review the Failure Score and reversal-risk label.

5. Compare the invalidation reference and target-room guide before interpreting the context.


🔍 Interpretation Guidelines

Think in terms of failed recovery quality, not prediction.

A higher Failure Score means the current pullback has stronger failed-recovery characteristics across depth, control loss, close behavior, volume, and follow-through.

A control-loss state means the setup is weakening but may still need more confirmation.

A reset state means the failed-pullback idea has been reclaimed and should be reassessed.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not auto trading

• Not guaranteed signals

• Not a generic pullback continuation indicator


⚠️ Limitations & Transparency

• Timeframe differences can change how pullback depth and failure windows appear.

• High volatility can distort ATR-normalized rails.

• Low-volume instruments may reduce the reliability of the volume component.

• Sideways markets can create repeated failed-pullback noise.

• Outputs should be interpreted with broader market structure.


🧠 Market Context Notes

Failed pullbacks often matter when a market was expected to recover in the direction of the prior trend but instead loses the control reference.

The script does not assume that every failed recovery becomes a full reversal. It simply marks when the context is strong enough to deserve review.


🧾 Use Case Examples

When a bullish trend pulls back toward the fast/base EMA area, fails to recover, and closes below the control rail with stronger participation, the planner may raise bearish reversal-risk context.

When a bearish trend pulls back upward, fails to reject lower, and closes above the control rail with follow-through, the planner may raise bullish reversal-risk context.


🧱 System Philosophy

The script is built around decision quality. It does not try to add another signal layer. It asks whether a specific market behavior is valid, how strong it is, where it is invalidated, and what should be reviewed next.


🔐 Non-Promise Statement

No guarantees.

No certainty.

The script organizes observable market behavior into a structured analytical view.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own analysis, risk management, and decisions.

This script does not provide financial advice or guaranteed trading outcomes.


📚 Educational Note

Use the planner as an educational framework for studying failed pullbacks, recovery quality, control loss, and reversal-risk context.

## Source Code

````pine
// -------------------------------------------------
// Failed Pullback Reversal Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.7
//
// Failed Pullback Reversal Planner is a chart-first reversal risk planner.
// It studies when a pullback inside an established trend fails to recover,
// loses control, and starts to create reversal-warning context. The script
// maps a failed pullback pocket, reversal-risk zone, target-room context,
// control rails, compact labels, and a 0-100 failure score without becoming
// an automated signal system. V1.7 strengthens close-confirmation integrity,
// identifies every active guide, and prevents merged planning zones from
// appearing without a clear shared label.
// -------------------------------------------------

//@version=6
indicator("Failed Pullback Reversal Planner [AGPro Series]",
     shorttitle       = "AG Pro FPR",
     overlay          = true,
     max_boxes_count  = 60,
     max_labels_count = 160,
     max_lines_count  = 90)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBg       = color.rgb(15, 23, 42)
panelBorder   = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)
darkText      = color.rgb(15, 23, 42)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
const string TT_SIDE = "Selects which former trend side can be evaluated. Auto allows both bullish-trend failures and bearish-trend failures."
const string TT_SENS = "Controls how strict the failed-pullback model is. Responsive reacts earlier, Balanced is the public-release default, and Strict requires cleaner control loss."
const string TT_FAST = "Fast EMA used to define the first pullback response area. It is part of the planner model, not a standalone signal."
const string TT_BASE = "Base EMA used as the control reference. A failed recovery is measured around this line."
const string TT_SLOW = "Slow EMA used to confirm the prior trend context before a failed pullback can be evaluated."
const string TT_ATR = "ATR normalizes pocket width, control-loss rails, invalidation distance, target room, and label offsets across symbols."
const string TT_VOL = "Volume baseline used to judge whether the failed recovery has participation behind it."
const string TT_LOOKBACK = "Lookback used to locate the nearest prior high or low as target-room context after a failed pullback."
const string TT_REACH = "ATR reach around the fast EMA that allows a pullback to enter the planner's monitoring state."
const string TT_IDEAL = "Preferred pullback depth before failure is evaluated. Very shallow pullbacks receive weaker context."
const string TT_EXCESS = "Depth beyond this ATR distance is treated as disorderly and receives weaker structure quality."
const string TT_WINDOW = "Number of bars after a pullback touch where control-loss behavior can still qualify."
const string TT_CONTROL = "ATR buffer beyond the base EMA used to define the control-loss rail."
const string TT_INVALID = "ATR buffer beyond the fast EMA used as the invalidation reference for the reversal-risk plan."
const string TT_TARGET = "ATR fallback used when the nearest prior high or low does not provide enough target-room context."
const string TT_CONFIRM = "Defines whether reversal-risk confirmation requires close behavior only, close plus volume, or strict close, volume, follow-through, and room alignment."
const string TT_CLOSE = "When enabled, labels and alerts wait for bar close. This keeps public chart behavior more stable."
const string TT_MIN = "Minimum 0-100 failure score required before the planner can mark a confirmed reversal-warning state."
const string TT_WATCH = "Minimum 0-100 score required before lighter pullback-test labels can appear."
const string TT_REVWINDOW = "Number of bars a reversal warning has to follow through within, for the Reversal Rate proof. It only measures historical follow-through and is not a forecast."
const string TT_ANCHORS = "Shows or hides the EMA anchors used by the failed-pullback model."
const string TT_POCKET = "Shows the failed pullback pocket. The pocket is concept-native context, not a generic support or resistance zone."
const string TT_RISK = "Shows the reversal-risk zone between the control-loss rail and invalidation reference."
const string TT_TARGET_ROOM = "Shows the target-room context from current price toward the nearest structure or fallback guide."
const string TT_TARGET_STYLE = "Full Path is the recommended publication default because it preserves the original strong zone geometry. Compact Rail remains available for users who prefer a smaller target guide."
const string TT_RAILS = "Shows control-loss, invalidation, and target-room guide rails for the active failed-pullback plan."
const string TT_LABELS = "Shows compact pullback-test, control-loss, reversal-warning, and reset labels with controlled spacing."
const string TT_SCORE_LABEL = "Adds the 0-100 failure score to chart labels."
const string TT_RESET_LABELS = "Shows reset labels when price reclaims the invalidation reference. Disabled by default to keep public screenshots focused on active failed-pullback decisions."
const string TT_LABEL_MODE = "Compact keeps screenshots cleaner. Detailed adds state and action context directly on chart labels."
const string TT_COOLDOWN = "Minimum bars between major event labels. Higher values reduce clustering."
const string TT_CONTEXT = "Minimum bars between lighter pullback-test labels. This keeps the chart active without crowding candles."
const string TT_MAX_LABELS = "Maximum number of visible chart labels retained by the script. Older labels are deleted first for performance."
const string TT_PROJECTION = "Number of bars projected to the right for the pocket, risk zone, target corridor, and guide rails."
const string TT_OFFSET = "ATR-based vertical offset that keeps labels away from candles."
const string TT_ZONE = "Transparency used for the failed pullback pocket, risk zone, and target-room context."
const string TT_LABEL_SIZE = "Controls all chart labels and centered zone text. Normal is the recommended public-release default."
const string TT_PANEL_SHOW = "Shows or hides the AG Pro planning panel. It is shown by default for public-release readability."
const string TT_PANEL_LOCATION = "Moves the AG Pro panel to the preferred chart location."
const string TT_PANEL_THEME = "Switches the panel between the premium AGPro dark theme and a clean light theme."
const string TT_PANEL_SIZE = "Controls the font size used inside the AG Pro panel. Normal is the recommended publication default."
const string TT_ALERT = "Minimum failure score required before alert conditions can trigger."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Failed Pullback Engine"
string sideMode = input.string("Auto", "Former Trend Side", options = ["Auto", "Bull Trend Only", "Bear Trend Only"], group = groupEngine, tooltip = TT_SIDE)
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Responsive", "Balanced", "Strict"], group = groupEngine, tooltip = TT_SENS)
int fastEmaLength = input.int(13, "Fast EMA Length", minval = 2, maxval = 100, group = groupEngine, tooltip = TT_FAST)
int baseEmaLength = input.int(34, "Base EMA Length", minval = 5, maxval = 220, group = groupEngine, tooltip = TT_BASE)
int slowEmaLength = input.int(89, "Slow EMA Length", minval = 10, maxval = 400, group = groupEngine, tooltip = TT_SLOW)
int atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine, tooltip = TT_ATR)
int volumeLength = input.int(34, "Volume Baseline Length", minval = 5, maxval = 200, group = groupEngine, tooltip = TT_VOL)
int structureLookback = input.int(72, "Target Structure Lookback", minval = 12, maxval = 300, group = groupEngine, tooltip = TT_LOOKBACK)

string groupPlanner = "Planner Model"
float pullbackReachAtr = input.float(0.48, "Pullback Reach ATR", minval = 0.05, maxval = 2.00, step = 0.01, group = groupPlanner, tooltip = TT_REACH)
float idealPullbackAtr = input.float(1.05, "Ideal Pullback Depth ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupPlanner, tooltip = TT_IDEAL)
float excessivePullbackAtr = input.float(3.10, "Disorderly Pullback ATR", minval = 0.50, maxval = 8.00, step = 0.05, group = groupPlanner, tooltip = TT_EXCESS)
int failureWindowBars = input.int(12, "Failure Window Bars", minval = 2, maxval = 60, group = groupPlanner, tooltip = TT_WINDOW)
float controlBufferAtr = input.float(0.18, "Control-Loss Buffer ATR", minval = 0.00, maxval = 1.50, step = 0.01, group = groupPlanner, tooltip = TT_CONTROL)
float invalidationBufferAtr = input.float(0.38, "Invalidation Buffer ATR", minval = 0.05, maxval = 2.50, step = 0.01, group = groupPlanner, tooltip = TT_INVALID)
float targetFallbackAtr = input.float(2.00, "Target-Room Fallback ATR", minval = 0.40, maxval = 8.00, step = 0.05, group = groupPlanner, tooltip = TT_TARGET)
string confirmationMode = input.string("Close + Volume", "Confirmation Mode", options = ["Close Only", "Close + Volume", "Strict"], group = groupPlanner, tooltip = TT_CONFIRM)
bool confirmOnClose = input.bool(true, "Confirm On Bar Close", group = groupPlanner, tooltip = TT_CLOSE)
int minFailureScore = input.int(62, "Minimum Failure Score", minval = 40, maxval = 95, group = groupPlanner, tooltip = TT_MIN)
int watchScore = input.int(44, "Pullback Watch Score", minval = 20, maxval = 90, group = groupPlanner, tooltip = TT_WATCH)
int reversalWindow = input.int(20, "Reversal Proof Window (bars)", minval = 4, maxval = 200, group = groupPlanner, tooltip = TT_REVWINDOW)

string groupVisual = "Chart Visuals"
bool showTrendAnchors = input.bool(false, "Show Trend Anchors", group = groupVisual, tooltip = TT_ANCHORS)
bool showFailedPocket = input.bool(true, "Show Failed Pullback Pocket", group = groupVisual, tooltip = TT_POCKET)
bool showRiskZone = input.bool(true, "Show Reversal Risk Zone", group = groupVisual, tooltip = TT_RISK)
bool showTargetRoom = input.bool(true, "Show Target-Room Corridor", group = groupVisual, tooltip = TT_TARGET_ROOM)
string targetRoomStyle = input.string("Full Path", "Target-Room Style", options = ["Full Path", "Compact Rail"], group = groupVisual, tooltip = TT_TARGET_STYLE)
bool showGuideRails = input.bool(true, "Show Control / Target Rails", group = groupVisual, tooltip = TT_RAILS)
int projectionBars = input.int(42, "Forward Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = TT_PROJECTION)
int zoneTransparency = input.int(88, "Zone Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = TT_ZONE)

string groupLabels = "Labels"
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = TT_LABELS)
bool showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = TT_SCORE_LABEL)
bool showResetLabels = input.bool(false, "Show Reset Labels", group = groupLabels, tooltip = TT_RESET_LABELS)
string labelTextMode = input.string("Compact", "Label Text Mode", options = ["Compact", "Detailed"], group = groupLabels, tooltip = TT_LABEL_MODE)
int labelCooldownBars = input.int(38, "Event Label Cooldown", minval = 1, maxval = 120, group = groupLabels, tooltip = TT_COOLDOWN)
int watchSpacingBars = input.int(64, "Watch Label Spacing", minval = 4, maxval = 180, group = groupLabels, tooltip = TT_CONTEXT)
int maxVisibleLabels = input.int(6, "Max Visible Labels", minval = 4, maxval = 80, group = groupLabels, tooltip = TT_MAX_LABELS)
float labelOffsetAtr = input.float(1.18, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = TT_OFFSET)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = TT_LABEL_SIZE)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = TT_PANEL_SHOW)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = TT_PANEL_LOCATION)
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = TT_PANEL_THEME)
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = TT_PANEL_SIZE)

string groupAlerts = "Alerts"
int alertScoreThreshold = input.int(62, "Minimum Alert Score", minval = 40, maxval = 95, group = groupAlerts, tooltip = TT_ALERT)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_norm_high(float value, float weak, float strong) =>
    float span = math.max(strong - weak, 0.000001)
    f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low(float value, float strong, float weak) =>
    float span = math.max(weak - strong, 0.000001)
    f_clamp((weak - value) / span * 100.0, 0.0, 100.0)

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    value <= idealValue ? f_norm_high(value, lowValue, idealValue) : f_norm_low(value, idealValue, highValue)

f_text_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_text_on(color bgColor) =>
    float yiq = (color.r(bgColor) * 299.0 + color.g(bgColor) * 587.0 + color.b(bgColor) * 114.0) / 1000.0
    yiq >= 150.0 ? darkText : headerText

f_panel_pos(string locationInput) =>
    switch locationInput
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

f_score_text(float value) =>
    na(value) ? "-" : str.tostring(math.round(f_clamp(value, 0.0, 100.0)), "#")

f_atr_text(float value) =>
    na(value) ? "-" : str.tostring(value, "#.00") + " ATR"

f_grade(float score) =>
    score >= 86.0 ? "A+" : score >= 76.0 ? "A" : score >= 64.0 ? "B" : score >= 52.0 ? "C" : "D"

f_score_color(float score) =>
    score >= minFailureScore ? bullColor : score >= watchScore ? neutralColor : score >= 30.0 ? accentColor : panelValueCol

f_side_color(int dir) =>
    dir == 1 ? bullColor : dir == -1 ? bearColor : panelValueCol

f_side_text_color(int dir) =>
    dir == 0 ? panelValueCol : headerText

f_panel_bg(string theme) =>
    theme == "Clean Light" ? color.rgb(245, 247, 250) : panelBg

f_panel_border(string theme) =>
    theme == "Clean Light" ? color.rgb(203, 213, 225) : panelBorder

f_panel_label_color(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value_color(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string theme, int row) =>
    bool evenRow = row % 2 == 0
    theme == "Clean Light" ? (evenRow ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)) : (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontInput) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label_color(theme), bgcolor = rowBg, text_size = f_text_size(fontInput), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(fontInput), text_halign = text.align_right)

f_trim_labels(array<label> ids, int limit) =>
    while array.size(ids) > limit
        label oldLabel = array.shift(ids)
        if not na(oldLabel)
            label.delete(oldLabel)

f_active_text(int dir) =>
    dir == -1 ? "Bull PB Failing" : dir == 1 ? "Bear PB Failing" : "No Active PB"

f_active_long(int dir) =>
    dir == -1 ? "Bull Pullback Failing" : dir == 1 ? "Bear Pullback Failing" : "No Active Pullback"

f_state_short(string stateText) =>
    stateText == "REVERSAL WARN" ? "REV RISK" : stateText == "CONTROL LOST" ? "CTRL LOST" : stateText == "PULLBACK TEST" ? "PB TEST" : stateText == "RECOVERY BACK" ? "RESET" : stateText

f_box_set(box id, int leftValue, float topValue, int rightValue, float bottomValue, color bgValue, color borderValue, string textValue, color textValueColor, string sizeValue) =>
    box.set_left(id, leftValue)
    box.set_right(id, rightValue)
    box.set_top(id, topValue)
    box.set_bottom(id, bottomValue)
    box.set_bgcolor(id, bgValue)
    box.set_border_color(id, borderValue)
    box.set_text(id, textValue)
    box.set_text_color(id, textValueColor)
    box.set_text_size(id, f_text_size(sizeValue))
    box.set_text_halign(id, text.align_center)
    box.set_text_valign(id, text.align_center)

// -------------------------------------------------
// Core Calculations
// -------------------------------------------------
float fastEma = ta.ema(close, fastEmaLength)
float baseEma = ta.ema(close, baseEmaLength)
float slowEma = ta.ema(close, slowEmaLength)
float atrRaw = ta.atr(atrLength)
float atr = math.max(nz(atrRaw, high - low), syminfo.mintick)
float rawVolume = nz(volume, 0.0)
float volumeAverage = ta.sma(rawVolume, volumeLength)
float volumeRatio = not na(volumeAverage) and volumeAverage > 0.0 ? rawVolume / volumeAverage : 1.0

float slopeLookback = nz(baseEma[5], baseEma)
float baseSlopeAtr = (baseEma - slopeLookback) / atr
float minSlopeAtr = sensitivity == "Strict" ? 0.060 : sensitivity == "Responsive" ? -0.005 : 0.020
float closeLocationNeed = sensitivity == "Strict" ? 0.66 : sensitivity == "Responsive" ? 0.54 : 0.60
float volumeNeed = sensitivity == "Strict" ? 1.10 : sensitivity == "Responsive" ? 0.88 : 0.96
float controlBreakNeedAtr = sensitivity == "Strict" ? 0.34 : sensitivity == "Responsive" ? 0.14 : 0.22
float followThroughNeedAtr = sensitivity == "Strict" ? 0.42 : sensitivity == "Responsive" ? 0.16 : 0.25
float reachAtr = sensitivity == "Strict" ? pullbackReachAtr * 0.85 : sensitivity == "Responsive" ? pullbackReachAtr * 1.20 : pullbackReachAtr

bool allowBullTrend = sideMode != "Bear Trend Only"
bool allowBearTrend = sideMode != "Bull Trend Only"
bool bullTrend = allowBullTrend and fastEma > baseEma and baseEma > slowEma and baseSlopeAtr >= minSlopeAtr
bool bearTrend = allowBearTrend and fastEma < baseEma and baseEma < slowEma and baseSlopeAtr <= -minSlopeAtr

bool bullPullbackTouch = bullTrend and low <= fastEma + atr * reachAtr and close < fastEma + atr * 0.30
bool bearPullbackTouch = bearTrend and high >= fastEma - atr * reachAtr and close > fastEma - atr * 0.30
int barsSinceBullTouch = ta.barssince(bullPullbackTouch)
int barsSinceBearTouch = ta.barssince(bearPullbackTouch)
bool recentBullPullback = not na(barsSinceBullTouch) and barsSinceBullTouch <= failureWindowBars
bool recentBearPullback = not na(barsSinceBearTouch) and barsSinceBearTouch <= failureWindowBars

int reversalDir = 0
if recentBullPullback and (not recentBearPullback or barsSinceBullTouch <= barsSinceBearTouch)
    reversalDir := -1
else if recentBearPullback
    reversalDir := 1

float windowLow = ta.lowest(low, failureWindowBars)
float windowHigh = ta.highest(high, failureWindowBars)
float pullbackDepthAtr = reversalDir == -1 ? math.max(fastEma - windowLow, 0.0) / atr : reversalDir == 1 ? math.max(windowHigh - fastEma, 0.0) / atr : na
float depthScore = reversalDir != 0 ? f_peak_score(pullbackDepthAtr, 0.10, idealPullbackAtr, excessivePullbackAtr) : 0.0

float controlRail = reversalDir == -1 ? baseEma - atr * controlBufferAtr : reversalDir == 1 ? baseEma + atr * controlBufferAtr : na
float invalidationRail = reversalDir == -1 ? fastEma + atr * invalidationBufferAtr : reversalDir == 1 ? fastEma - atr * invalidationBufferAtr : na
float structureLow = ta.lowest(low, structureLookback)[1]
float structureHigh = ta.highest(high, structureLookback)[1]
float rawTargetRail = reversalDir == -1 ? structureLow : reversalDir == 1 ? structureHigh : na
float rawTargetRoomAtr = reversalDir == -1 ? (close - rawTargetRail) / atr : reversalDir == 1 ? (rawTargetRail - close) / atr : na
bool targetNeedsFallback = reversalDir != 0 and (na(rawTargetRail) or na(rawTargetRoomAtr) or rawTargetRoomAtr < 0.35)
float targetRail = reversalDir == -1 ? (targetNeedsFallback ? close - atr * targetFallbackAtr : rawTargetRail) : reversalDir == 1 ? (targetNeedsFallback ? close + atr * targetFallbackAtr : rawTargetRail) : na
float targetRoomAtr = reversalDir == -1 ? math.max(close - targetRail, 0.0) / atr : reversalDir == 1 ? math.max(targetRail - close, 0.0) / atr : na

float controlBreakAtr = reversalDir == -1 ? (controlRail - close) / atr : reversalDir == 1 ? (close - controlRail) / atr : 0.0
bool controlLost = reversalDir != 0 and controlBreakAtr > 0.0
float failedRecoveryScore = reversalDir != 0 ? f_norm_high(controlBreakAtr, 0.0, controlBreakNeedAtr) : 0.0

float candleRange = math.max(high - low, syminfo.mintick)
float closeLocation = (close - low) / candleRange
float closeAgainstTrendMetric = reversalDir == -1 ? 1.0 - closeLocation : reversalDir == 1 ? closeLocation : 0.0
bool candleAgainstTrend = reversalDir == -1 ? close < open : reversalDir == 1 ? close > open : false
float closeAgainstScoreRaw = f_clamp(closeAgainstTrendMetric / closeLocationNeed * 100.0, 0.0, 100.0)
float closeAgainstScore = candleAgainstTrend ? closeAgainstScoreRaw : closeAgainstScoreRaw * 0.55

float volumeScore = f_clamp(volumeRatio / volumeNeed * 100.0, 0.0, 100.0)
float priorThreeLow = ta.lowest(low, 3)[1]
float priorThreeHigh = ta.highest(high, 3)[1]
float followThroughAtr = reversalDir == -1 ? (priorThreeLow - close) / atr : reversalDir == 1 ? (close - priorThreeHigh) / atr : 0.0
bool followThrough = reversalDir != 0 and followThroughAtr > 0.0
float followThroughScore = reversalDir != 0 ? f_norm_high(followThroughAtr, 0.0, followThroughNeedAtr) : 0.0

float failureScoreRaw = reversalDir != 0 ? depthScore * 0.23 + failedRecoveryScore * 0.27 + closeAgainstScore * 0.20 + volumeScore * 0.15 + followThroughScore * 0.15 : 0.0
float failureScore = math.round(f_clamp(failureScoreRaw, 0.0, 100.0))

bool confirmedBar = confirmOnClose ? barstate.isconfirmed : true
bool volumeReady = confirmationMode == "Close Only" ? true : volumeRatio >= volumeNeed
bool strictReady = confirmationMode == "Strict" ? followThroughScore >= 45.0 and targetRoomAtr >= 0.60 and depthScore >= 45.0 : true
bool invalidatedRaw = reversalDir == -1 ? close > invalidationRail : reversalDir == 1 ? close < invalidationRail : false
bool invalidated = confirmedBar and invalidatedRaw
bool reversalWarning = confirmedBar and controlLost and candleAgainstTrend and volumeReady and strictReady and not invalidated and failureScore >= minFailureScore
bool controlLossReview = confirmedBar and controlLost and not reversalWarning and not invalidated and failureScore >= watchScore
bool pullbackWatch = confirmedBar and reversalDir != 0 and not controlLost and not invalidated and failureScore >= watchScore

string pullbackState = "NO SETUP"
if reversalDir != 0
    if invalidated
        pullbackState := "RECOVERY BACK"
    else if reversalWarning
        pullbackState := "REVERSAL WARN"
    else if controlLossReview
        pullbackState := "CONTROL LOST"
    else if pullbackWatch
        pullbackState := "PULLBACK TEST"
    else
        pullbackState := "WAIT"

string reversalRisk = "None"
if reversalDir != 0
    if invalidated
        reversalRisk := "Reset"
    else if reversalWarning
        reversalRisk := reversalDir == 1 ? "Bullish Elevated" : "Bearish Elevated"
    else if controlLossReview
        reversalRisk := "Rising"
    else if pullbackWatch
        reversalRisk := "Watching"
    else
        reversalRisk := "Low"

string actionText = "Wait for setup"
if pullbackState == "PULLBACK TEST"
    actionText := "Monitor recovery"
else if pullbackState == "CONTROL LOST"
    actionText := "Review failure"
else if pullbackState == "REVERSAL WARN"
    actionText := "Review reversal"
else if pullbackState == "RECOVERY BACK"
    actionText := "Reset plan"
else if pullbackState == "WAIT"
    actionText := "Wait control loss"

color sideColor = f_side_color(reversalDir)
color stateColor = pullbackState == "REVERSAL WARN" ? sideColor : pullbackState == "CONTROL LOST" ? bearColor : pullbackState == "PULLBACK TEST" ? neutralColor : pullbackState == "RECOVERY BACK" ? accentColor : f_score_color(failureScore)
color scoreColor = reversalDir != 0 and failureScore >= minFailureScore ? sideColor : f_score_color(failureScore)

plot(showTrendAnchors ? fastEma : na, "Fast EMA", color = color.new(sideColor, 18), linewidth = 1)
plot(showTrendAnchors ? baseEma : na, "Control EMA", color = color.new(accentColor, 0), linewidth = 2)
plot(showTrendAnchors ? slowEma : na, "Slow EMA", color = color.new(neutralColor, 18), linewidth = 2)

// -------------------------------------------------
// Reversal follow-through proof (Confirm Rate)
// -------------------------------------------------
// When a reversal warning fires, does price follow through 0.75 ATR in the
// expected reversal direction before reclaiming the invalidation reference (a
// reset / failed reversal)? Counted once per warning. A reclaim first, or a
// window expiry with no follow-through, is treated as not-followed.
float rvMargin = math.max(nz(atr), syminfo.mintick) * 0.75
var int   rvTotal = 0
var int   rvWon    = 0
var bool  rvPend    = false
var int   rvDir      = 0
var float rvAnchor    = na
var float rvInval      = na
var int   rvLeft        = 0
bool warnFire = reversalWarning and not reversalWarning[1]

if barstate.isconfirmed
    if rvPend and not na(rvAnchor) and not na(rvInval)
        bool rvFailed = rvDir > 0 ? close < rvInval : close > rvInval
        bool rvFollowed = rvDir > 0 ? close >= rvAnchor + rvMargin : close <= rvAnchor - rvMargin
        if rvFailed
            rvTotal += 1
            rvPend := false
        else if rvFollowed
            rvTotal += 1
            rvWon += 1
            rvPend := false
        else
            rvLeft -= 1
            if rvLeft <= 0
                rvTotal += 1
                rvPend := false
    if warnFire and reversalDir != 0 and not na(invalidationRail) and not rvPend
        rvDir := reversalDir
        rvAnchor := close
        rvInval := invalidationRail
        rvLeft := reversalWindow
        rvPend := true

float rvRate = rvTotal > 0 ? rvWon / rvTotal * 100.0 : na
string reversalRateRead = rvTotal > 0 ? str.tostring(math.round(rvRate)) + "% (" + str.tostring(rvTotal) + ")" : "Building"

// -------------------------------------------------
// Live Planner Visuals
// -------------------------------------------------
var box activePocketBox = na
var box activeRiskBox = na
var box activeTargetBox = na
var label activePocketBadge = na
var label activeRiskBadge = na
var label activeTargetBadge = na
var line activeControlLine = na
var line activeInvalidLine = na
var line activeTargetLine = na
var label activeControlTag = na
var label activeInvalidTag = na
var label activeTargetTag = na
var array<label> eventLabels = array.new_label()
var int lastEventLabelBar = na
var int lastWatchLabelBar = na

int visualLeft = math.max(bar_index - failureWindowBars, 0)
int visualRight = bar_index + projectionBars
float pocketPad = atr * math.max(reachAtr * 0.55, 0.12)
float pocketTopRaw = reversalDir == -1 ? fastEma + pocketPad : reversalDir == 1 ? baseEma + pocketPad : na
float pocketBottomRaw = reversalDir == -1 ? baseEma - pocketPad : reversalDir == 1 ? fastEma - pocketPad : na
float pocketTop = reversalDir != 0 ? math.max(pocketTopRaw, pocketBottomRaw) : na
float pocketBottom = reversalDir != 0 ? math.min(pocketTopRaw, pocketBottomRaw) : na
float riskTopRaw = reversalDir != 0 ? math.max(controlRail, invalidationRail) : na
float riskBottomRaw = reversalDir != 0 ? math.min(controlRail, invalidationRail) : na
float riskMid = (riskTopRaw + riskBottomRaw) / 2.0
float minRiskHeight = atr * 0.12
float riskTop = reversalDir != 0 and riskTopRaw - riskBottomRaw < minRiskHeight ? riskMid + minRiskHeight * 0.50 : riskTopRaw
float riskBottom = reversalDir != 0 and riskTopRaw - riskBottomRaw < minRiskHeight ? riskMid - minRiskHeight * 0.50 : riskBottomRaw
float fullCorridorTopRaw = reversalDir != 0 ? math.max(close, targetRail) : na
float fullCorridorBottomRaw = reversalDir != 0 ? math.min(close, targetRail) : na
float targetRailHalf = atr * math.max(0.10, math.min(targetRoomAtr * 0.045, 0.35))
float compactTopRaw = reversalDir != 0 ? targetRail + targetRailHalf : na
float compactBottomRaw = reversalDir != 0 ? targetRail - targetRailHalf : na
float corridorTopRaw = targetRoomStyle == "Full Path" ? fullCorridorTopRaw : compactTopRaw
float corridorBottomRaw = targetRoomStyle == "Full Path" ? fullCorridorBottomRaw : compactBottomRaw
float minCorridorHeight = atr * 0.14
float corridorMid = (corridorTopRaw + corridorBottomRaw) / 2.0
float corridorTop = reversalDir != 0 and corridorTopRaw - corridorBottomRaw < minCorridorHeight ? corridorMid + minCorridorHeight * 0.50 : corridorTopRaw
float corridorBottom = reversalDir != 0 and corridorTopRaw - corridorBottomRaw < minCorridorHeight ? corridorMid - minCorridorHeight * 0.50 : corridorBottomRaw
float pocketMid = (pocketTop + pocketBottom) / 2.0
bool zonesOverlap = reversalDir != 0 and pocketTop >= riskBottom and riskTop >= pocketBottom
bool zonesVeryClose = reversalDir != 0 and math.abs(pocketMid - riskMid) <= atr * 0.42
bool mergeCloseZoneText = showFailedPocket and showRiskZone and (zonesOverlap or zonesVeryClose)
float pocketVisualTop = mergeCloseZoneText ? math.max(pocketTop, riskTop) : pocketTop
float pocketVisualBottom = mergeCloseZoneText ? math.min(pocketBottom, riskBottom) : pocketBottom
float pocketVisualMid = (pocketVisualTop + pocketVisualBottom) / 2.0
bool renderVisuals = reversalDir != 0 and barstate.islast

if showFailedPocket and renderVisuals
    color pocketFill = color.new(stateColor, zoneTransparency)
    color pocketBorder = color.new(stateColor, pullbackState == "REVERSAL WARN" ? 18 : 38)
    color pocketBadgeBg = color.new(stateColor, 4)
    string pocketText = mergeCloseZoneText ? "PULLBACK / RISK\n" + f_score_text(failureScore) : pullbackState == "REVERSAL WARN" ? "FAILED PULLBACK\nWARNING" : pullbackState == "CONTROL LOST" ? "CONTROL LOSS\nPOCKET" : "FAILED PULLBACK\nPOCKET"
    int pocketBadgeX = int(math.round((visualLeft + visualRight) / 2.0))
    if na(activePocketBox)
        activePocketBox := box.new(left = visualLeft, top = pocketVisualTop, right = visualRight, bottom = pocketVisualBottom, xloc = xloc.bar_index, bgcolor = pocketFill, border_color = pocketBorder, border_width = 1, text = "")
    else
        f_box_set(activePocketBox, visualLeft, pocketVisualTop, visualRight, pocketVisualBottom, pocketFill, pocketBorder, "", headerText, labelFontSize)
    if na(activePocketBadge)
        activePocketBadge := label.new(pocketBadgeX, pocketVisualMid, pocketText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = pocketBadgeBg, textcolor = f_text_on(stateColor), size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_xy(activePocketBadge, pocketBadgeX, pocketVisualMid)
        label.set_text(activePocketBadge, pocketText)
        label.set_color(activePocketBadge, pocketBadgeBg)
        label.set_textcolor(activePocketBadge, f_text_on(stateColor))
        label.set_size(activePocketBadge, f_text_size(labelFontSize))
else if (not showFailedPocket or reversalDir == 0) and not na(activePocketBox)
    box.delete(activePocketBox)
    activePocketBox := na
    if not na(activePocketBadge)
        label.delete(activePocketBadge)
        activePocketBadge := na

if showRiskZone and renderVisuals and not mergeCloseZoneText
    color riskColor = reversalWarning ? sideColor : bearColor
    color riskFill = color.new(riskColor, math.min(zoneTransparency + 3, 96))
    color riskBorder = color.new(riskColor, 34)
    color riskBadgeBg = color.new(riskColor, 4)
    string riskText = mergeCloseZoneText ? "" : reversalWarning ? "REVERSAL RISK\nZONE" : invalidated ? "RESET\nZONE" : "INVALIDATION\nZONE"
    int riskBadgeX = int(math.round((visualLeft + visualRight) / 2.0))
    if na(activeRiskBox)
        activeRiskBox := box.new(left = visualLeft, top = riskTop, right = visualRight, bottom = riskBottom, xloc = xloc.bar_index, bgcolor = riskFill, border_color = riskBorder, border_width = 1, text = "")
    else
        f_box_set(activeRiskBox, visualLeft, riskTop, visualRight, riskBottom, riskFill, riskBorder, "", headerText, labelFontSize)
    if riskText != ""
        if na(activeRiskBadge)
            activeRiskBadge := label.new(riskBadgeX, riskMid, riskText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = riskBadgeBg, textcolor = f_text_on(riskColor), size = f_text_size(labelFontSize), textalign = text.align_center)
        else
            label.set_xy(activeRiskBadge, riskBadgeX, riskMid)
            label.set_text(activeRiskBadge, riskText)
            label.set_color(activeRiskBadge, riskBadgeBg)
            label.set_textcolor(activeRiskBadge, f_text_on(riskColor))
            label.set_size(activeRiskBadge, f_text_size(labelFontSize))
    else if not na(activeRiskBadge)
        label.delete(activeRiskBadge)
        activeRiskBadge := na
else if (not showRiskZone or reversalDir == 0 or mergeCloseZoneText) and not na(activeRiskBox)
    box.delete(activeRiskBox)
    activeRiskBox := na
    if not na(activeRiskBadge)
        label.delete(activeRiskBadge)
        activeRiskBadge := na

if showTargetRoom and renderVisuals
    color targetColor = targetRoomAtr >= targetFallbackAtr ? accentColor : neutralColor
    color targetFill = color.new(targetColor, targetRoomStyle == "Full Path" ? 93 : 88)
    color targetBorder = color.new(targetColor, 42)
    color targetBadgeBg = color.new(targetColor, 4)
    int targetLeft = targetRoomStyle == "Full Path" ? bar_index : math.max(bar_index + int(math.round(projectionBars * 0.38)), bar_index + 3)
    string targetText = targetRoomStyle == "Full Path" ? "TARGET ROOM\n" + f_atr_text(targetRoomAtr) : "TARGET\n" + f_atr_text(targetRoomAtr)
    int targetBadgeX = int(math.round((targetLeft + visualRight) / 2.0))
    if na(activeTargetBox)
        activeTargetBox := box.new(left = targetLeft, top = corridorTop, right = visualRight, bottom = corridorBottom, xloc = xloc.bar_index, bgcolor = targetFill, border_color = targetBorder, border_width = 1, text = "")
    else
        f_box_set(activeTargetBox, targetLeft, corridorTop, visualRight, corridorBottom, targetFill, targetBorder, "", headerText, labelFontSize)
    if na(activeTargetBadge)
        activeTargetBadge := label.new(targetBadgeX, corridorMid, targetText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = targetBadgeBg, textcolor = f_text_on(targetColor), size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_xy(activeTargetBadge, targetBadgeX, corridorMid)
        label.set_text(activeTargetBadge, targetText)
        label.set_color(activeTargetBadge, targetBadgeBg)
        label.set_textcolor(activeTargetBadge, f_text_on(targetColor))
        label.set_size(activeTargetBadge, f_text_size(labelFontSize))
else if (not showTargetRoom or reversalDir == 0) and not na(activeTargetBox)
    box.delete(activeTargetBox)
    activeTargetBox := na
    if not na(activeTargetBadge)
        label.delete(activeTargetBadge)
        activeTargetBadge := na

if showGuideRails and renderVisuals
    int railLeft = bar_index + math.max(int(math.round(projectionBars * 0.10)), 2)
    int railSpan = math.max(visualRight - railLeft, 3)
    int controlTagX = railLeft + int(math.round(railSpan * 0.60))
    int invalidTagX = railLeft + int(math.round(railSpan * 0.80))
    int targetTagX = railLeft + int(math.round(railSpan * 0.95))
    if na(activeControlLine)
        activeControlLine := line.new(railLeft, controlRail, visualRight, controlRail, xloc = xloc.bar_index, extend = extend.none, color = color.new(neutralColor, 0), style = line.style_dashed, width = 2)
    else
        line.set_xy1(activeControlLine, railLeft, controlRail)
        line.set_xy2(activeControlLine, visualRight, controlRail)
        line.set_color(activeControlLine, color.new(neutralColor, 0))
    if na(activeInvalidLine)
        activeInvalidLine := line.new(railLeft, invalidationRail, visualRight, invalidationRail, xloc = xloc.bar_index, extend = extend.none, color = color.new(bearColor, 0), style = line.style_dashed, width = 2)
    else
        line.set_xy1(activeInvalidLine, railLeft, invalidationRail)
        line.set_xy2(activeInvalidLine, visualRight, invalidationRail)
        line.set_color(activeInvalidLine, color.new(bearColor, 0))
    if na(activeTargetLine)
        activeTargetLine := line.new(railLeft, targetRail, visualRight, targetRail, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 0), style = line.style_dotted, width = 2)
    else
        line.set_xy1(activeTargetLine, railLeft, targetRail)
        line.set_xy2(activeTargetLine, visualRight, targetRail)
        line.set_color(activeTargetLine, color.new(accentColor, 0))
    if na(activeControlTag)
        activeControlTag := label.new(controlTagX, controlRail, "CONTROL", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(neutralColor, 4), textcolor = f_text_on(neutralColor), size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_xy(activeControlTag, controlTagX, controlRail)
        label.set_text(activeControlTag, "CONTROL")
        label.set_color(activeControlTag, color.new(neutralColor, 4))
        label.set_textcolor(activeControlTag, f_text_on(neutralColor))
        label.set_size(activeControlTag, f_text_size(labelFontSize))
    if na(activeInvalidTag)
        activeInvalidTag := label.new(invalidTagX, invalidationRail, "INVALID", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(bearColor, 4), textcolor = f_text_on(bearColor), size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_xy(activeInvalidTag, invalidTagX, invalidationRail)
        label.set_text(activeInvalidTag, "INVALID")
        label.set_color(activeInvalidTag, color.new(bearColor, 4))
        label.set_textcolor(activeInvalidTag, f_text_on(bearColor))
        label.set_size(activeInvalidTag, f_text_size(labelFontSize))
    if na(activeTargetTag)
        activeTargetTag := label.new(targetTagX, targetRail, "TARGET", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(accentColor, 4), textcolor = f_text_on(accentColor), size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_xy(activeTargetTag, targetTagX, targetRail)
        label.set_text(activeTargetTag, "TARGET")
        label.set_color(activeTargetTag, color.new(accentColor, 4))
        label.set_textcolor(activeTargetTag, f_text_on(accentColor))
        label.set_size(activeTargetTag, f_text_size(labelFontSize))
else
    if not na(activeControlLine)
        line.delete(activeControlLine)
        activeControlLine := na
    if not na(activeInvalidLine)
        line.delete(activeInvalidLine)
        activeInvalidLine := na
    if not na(activeTargetLine)
        line.delete(activeTargetLine)
        activeTargetLine := na
    if not na(activeControlTag)
        label.delete(activeControlTag)
        activeControlTag := na
    if not na(activeInvalidTag)
        label.delete(activeInvalidTag)
        activeInvalidTag := na
    if not na(activeTargetTag)
        label.delete(activeTargetTag)
        activeTargetTag := na

// -------------------------------------------------
// Event Labels
// -------------------------------------------------
bool eventCooldownReady = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
bool watchCooldownReady = na(lastWatchLabelBar) or bar_index - lastWatchLabelBar >= watchSpacingBars
bool warningEvent = showEventLabels and reversalWarning and eventCooldownReady
bool controlEvent = showEventLabels and controlLossReview and eventCooldownReady
bool resetEvent = showEventLabels and showResetLabels and invalidated and reversalDir != 0 and eventCooldownReady
bool watchEvent = showEventLabels and pullbackWatch and watchCooldownReady and not warningEvent and not controlEvent and not resetEvent

if warningEvent or controlEvent or resetEvent or watchEvent
    string eventName = warningEvent ? "REV RISK" : controlEvent ? "CTRL LOST" : resetEvent ? "RESET" : "PB TEST"
    string scoreSuffix = showLabelScore ? "\n" + f_score_text(failureScore) : ""
    string labelText = eventName + scoreSuffix
    if labelTextMode == "Detailed"
        string directionText = reversalDir == 1 ? "Bullish" : reversalDir == -1 ? "Bearish" : "Neutral"
        labelText := eventName + "\n" + directionText + "\n" + f_score_text(failureScore)
    color labelColor = warningEvent ? sideColor : controlEvent ? bearColor : resetEvent ? accentColor : neutralColor
    bool labelBelow = reversalDir == 1
    float labelY = labelBelow ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr
    label newLabel = label.new(bar_index, labelY, labelText, xloc = xloc.bar_index, yloc = yloc.price, style = labelBelow ? label.style_label_up : label.style_label_down, color = color.new(labelColor, 2), textcolor = f_text_on(labelColor), size = f_text_size(labelFontSize), textalign = text.align_center)
    array.push(eventLabels, newLabel)
    f_trim_labels(eventLabels, maxVisibleLabels)
    if watchEvent
        lastWatchLabelBar := bar_index
    else
        lastEventLabelBar := bar_index

// -------------------------------------------------
// Data Window
// -------------------------------------------------
plot(failureScore, title = "Failed Pullback Score", color = scoreColor, display = display.data_window)
plot(depthScore, title = "Pullback Depth Quality", color = neutralColor, display = display.data_window)
plot(failedRecoveryScore, title = "Control Loss Quality", color = bearColor, display = display.data_window)
plot(volumeScore, title = "Participation Quality", color = accentColor, display = display.data_window)
plot(targetRoomAtr, title = "Target Room ATR", color = accentColor, display = display.data_window)
plot(rvRate, title = "Reversal Follow Rate", color = bullColor, display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table infoPanel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""

if showPanel and barstate.islast
    color panelBgActive = f_panel_bg(panelTheme)
    color panelBorderActive = f_panel_border(panelTheme)
    color reversalRateCol = na(rvRate) ? f_panel_value_color(panelTheme) : rvRate >= 60.0 ? bullColor : rvRate >= 45.0 ? neutralColor : bearColor
    if na(infoPanel) or lastPanelLocation != panelLocation or lastPanelTheme != panelTheme
        if not na(infoPanel)
            table.delete(infoPanel)
        infoPanel := table.new(f_panel_pos(panelLocation), 2, 7, bgcolor = panelBgActive, frame_color = panelBorderActive, frame_width = 1, border_color = panelBorderActive, border_width = 1)
        table.merge_cells(infoPanel, 0, 0, 1, 0)
        lastPanelLocation := panelLocation
        lastPanelTheme := panelTheme
    table.cell(infoPanel, 0, 0, "AG Pro Failed Pullback Reversal Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
    string scorePanelText = reversalDir == 0 ? "-" : f_score_text(failureScore) + " / " + f_grade(failureScore)
    string statePanelText = reversalDir == 0 ? pullbackState : f_active_text(reversalDir) + " / " + f_state_short(pullbackState)
    string roomText = reversalDir == 0 ? "-" : f_atr_text(targetRoomAtr)
    f_panel_row(infoPanel, 1, "Pullback State", statePanelText, stateColor, panelTheme, panelFontSize)
    f_panel_row(infoPanel, 2, "Failure Score", scorePanelText, reversalDir == 0 ? f_panel_value_color(panelTheme) : scoreColor, panelTheme, panelFontSize)
    f_panel_row(infoPanel, 3, "Reversal Risk", reversalRisk, stateColor, panelTheme, panelFontSize)
    f_panel_row(infoPanel, 4, "Reversal Rate", reversalRateRead, reversalRateCol, panelTheme, panelFontSize)
    f_panel_row(infoPanel, 5, "Target Room", roomText, reversalDir == 0 ? f_panel_value_color(panelTheme) : accentColor, panelTheme, panelFontSize)
    f_panel_row(infoPanel, 6, "Action", actionText, stateColor, panelTheme, panelFontSize)

if not showPanel and not na(infoPanel)
    table.delete(infoPanel)
    infoPanel := na
    lastPanelLocation := ""
    lastPanelTheme := ""

// -------------------------------------------------
// Alerts
// -------------------------------------------------
bool alertReady = pullbackWatch and failureScore >= alertScoreThreshold
bool alertWarning = reversalWarning and failureScore >= alertScoreThreshold
bool alertInvalidated = invalidated and reversalDir != 0
bool alertFollowThrough = confirmedBar and followThrough and controlLost and failureScore >= alertScoreThreshold

alertcondition(alertReady and reversalDir == -1, "Bearish Failed Pullback Ready", "Failed Pullback Reversal Planner: bullish-trend pullback is being monitored for bearish failure context. This is an attention marker, not a trade instruction.")
alertcondition(alertReady and reversalDir == 1, "Bullish Failed Pullback Ready", "Failed Pullback Reversal Planner: bearish-trend pullback is being monitored for bullish failure context. This is an attention marker, not a trade instruction.")
alertcondition(alertWarning and reversalDir == -1, "Bearish Reversal Risk Warning", "Failed Pullback Reversal Planner: failed pullback control loss created bearish reversal-risk context. This is an attention marker, not a trade instruction.")
alertcondition(alertWarning and reversalDir == 1, "Bullish Reversal Risk Warning", "Failed Pullback Reversal Planner: failed pullback control loss created bullish reversal-risk context. This is an attention marker, not a trade instruction.")
alertcondition(alertInvalidated, "Failed Pullback Plan Invalidated", "Failed Pullback Reversal Planner: price reclaimed the invalidation reference and the failed-pullback plan should be reset. This is an attention marker, not a trade instruction.")
alertcondition(alertFollowThrough, "Failed Pullback Follow-Through", "Failed Pullback Reversal Planner: failed-pullback context is showing follow-through beyond nearby structure. This is an attention marker, not a trade instruction.")
````

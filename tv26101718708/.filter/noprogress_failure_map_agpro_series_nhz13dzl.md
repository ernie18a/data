# No-Progress Failure Map [AGPro Series]

- url: https://www.tradingview.com/script/nHZ13dzL-No-Progress-Failure-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;5c5fea58addf4ddca543f5e33b571c8c
- version: 9.0

## Description

No-Progress Failure Map [AGPro Series]

🧠 Core Idea

Did price trigger a setup but fail to travel far enough afterward?


📌 Overview / What it does

No-Progress Failure Map is a post-trigger execution failure planner designed to evaluate whether an active setup is actually moving after it triggers, or simply stalling around the trigger area.

The script builds a progress window, maps a risk shelf, projects a minimum progress rail, tracks elapsed bars, measures distance travelled in ATR, evaluates candle efficiency, reads volume participation, and converts the result into a 0-100 Progress Score with a clear action state.

It does not predict price direction, automate trading, or print guaranteed entry or exit commands. Its purpose is to organize the question of progress versus failure after a trigger appears.


🎯 Purpose & Design Philosophy

This script was built for traders who do not want to judge a setup only at the moment it triggers.

Many setups look valid at first, but the real weakness appears later: price does not travel far enough, time passes, participation fades, or the trigger side is lost. This tool turns that hidden execution problem into a visible decision layer.

It supports a planning mindset: trigger, observe progress, evaluate time cost, check failure risk, and decide what deserves attention next.


⚡ Why This Script Is Different

Most tools focus on finding the trigger itself.

This script does NOT behave like a generic signal indicator, opening range failure tool, RSI failure swing detector, order-block map, support/resistance scanner, or broad regime dashboard.

Instead, it asks a narrower execution question: after a setup starts, is price travelling enough to keep the idea alive, or is the setup becoming a no-progress failure?


⚙️ Methodology

1. Context Detection
The script selects the evaluation side using Auto, Long Context, or Short Context. Auto mode follows trend and slope context.

2. Trigger Mapping
The planner starts a tracking window from a selected trigger model: Range Break, Impulse Close, or Trend Reclaim.

3. Progress Evaluation
It measures favorable travel, elapsed bars, close efficiency, relative volume, time decay, reclaim behavior, and risk shelf pressure.

4. Visual Output
It displays a stalled-move box, minimum progress rail, risk shelf, trigger line, event labels, alerts, and a compact AGPro panel.


🗺️ How to Read the Chart

Zones = the stalled-move box between the risk shelf and the minimum progress rail.

Labels = compact event markers for Trigger, No Progress, Reclaim, Travel OK, and Failed states.

Colors = teal marks accepted progress, pink/red marks failure or invalidation, amber marks stalled progress, and indigo marks active watch or recovery context.

Panel = summarizes Progress Score, Elapsed Bars, Distance Travelled, Failure Risk, and Action.


🚦 Signals & States

• Trigger → a new post-trigger progress window is active.

• Watch Progress → the setup is active but has not yet proven enough travel.

• Stalled → price has lost the trigger side or is not progressing cleanly.

• No Progress → the evaluation window matured without enough favorable travel.

• Reclaim → price recovered the trigger side after temporary loss.

• Travel OK → the setup reached the accepted progress threshold.

• Failed → the tracked setup crossed its risk shelf.


🔔 Alerts Logic

Alerts trigger when a new progress window starts, when no-progress failure risk appears, when travel is accepted, when a reclaim appears, or when the risk shelf is crossed.

Alerts are attention markers. They are not trade instructions, automated strategy commands, or certainty signals.


🧩 Confluence Logic

The strongest progress context appears when favorable travel, close efficiency, volume participation, time efficiency, and trigger-side control align.

When travel is weak and elapsed bars increase, the failure-risk reading rises. When the trigger side is lost and reclaimed, the script marks recovery context but does not treat it as certainty.


📊 When to Use

• After a breakout-style trigger appears.

• During continuation attempts that should show progress quickly.

• Around trend reclaim setups where follow-through matters.

• When a setup looks active but price remains trapped near the trigger.

• On liquid markets where ATR and relative volume are meaningful.


⚠️ When NOT to Use

• Extremely low-liquidity markets with unreliable candles or volume.

• Very noisy micro-timeframes where trigger-side loss is frequent.

• News-driven volatility spikes where ATR expands suddenly.

• Symbols where volume data is missing or not useful.

• As a standalone reason to enter, exit, or size a trade.


🎛️ Key Inputs

• Evaluation Side → controls Auto, Long Context, or Short Context.

• Trigger Model → selects Range Break, Impulse Close, or Trend Reclaim activation.

• Evaluation Window Bars → defines how long the setup has to show minimum progress.

• Minimum Progress ATR → defines the expected favorable travel threshold.

• Progress Accepted ATR → defines stronger follow-through.

• Risk Shelf Buffer ATR → controls invalidation distance around the initial shelf.

• Visual Settings → control boxes, rails, prior boxes, labels, panel location, theme, and font sizes.


🖥️ Interface & Visual Design

The interface is chart-first.

The stalled-move box is the primary visual object and contains a centered progress meter. Rails show trigger, risk, and progress references without turning the chart into a crowded level map.

The panel follows the AGPro publication layout with a single merged blue title row, adjustable location, adjustable theme, and adjustable font size.


🧪 Practical Usage Workflow

1. Read the panel state and Progress Score.

2. Check whether price is travelling beyond the minimum progress rail.

3. Review elapsed bars versus the evaluation window.

4. Watch for No Progress, Reclaim, Travel OK, or Failed labels.

5. Interpret the output inside broader market structure and risk context.


🔍 Interpretation Guidelines

A high Progress Score means the setup is moving efficiently relative to this rule set. It does not mean price must continue.

A No Progress label means the setup has not travelled enough after the selected trigger. It does not guarantee failure, but it highlights weakening execution quality.

A Failed state means the mapped risk shelf was crossed. It should be read as rule-based invalidation context, not as financial advice.


🚫 What This Script Is NOT

• Not a prediction engine.

• Not financial advice.

• Not auto trading.

• Not guaranteed signals.

• Not a buy/sell signal service.

• Not an opening range failure tool.

• Not an RSI failure swing detector.

• Not a generic support/resistance or order-block map.


⚠️ Limitations & Transparency

Progress quality depends on the selected trigger model, lookback, ATR length, timeframe, and market conditions.

Different symbols may produce different volume behavior. High volatility can expand the tracking box quickly, while low volatility can make progress thresholds harder to interpret.

The script is rule-based and should be used as an analytical planning layer, not as a complete trading system.


🧠 Market Context Notes

No-progress behavior is often a time and efficiency problem, not just a price-level problem.

A setup can trigger, remain technically alive, and still become unattractive if it fails to move far enough while time passes. This script makes that condition visible.


🧾 Use Case Examples

When price breaks a recent range but remains near the trigger after the evaluation window, the map can mark No Progress and increase failure risk.

When price loses the trigger side and then reclaims it, the script can mark Reclaim so the user can review whether recovery is meaningful.

When price travels beyond the accepted progress threshold with efficient closes, the panel can move toward Travel OK context.


🧱 System Philosophy

No-Progress Failure Map follows the AGPro decision-engine approach: the script should help users evaluate context, quality, risk, progress, and next action without promising an outcome.

The goal is not to add another signal. The goal is to make post-trigger progress easier to judge.


🔐 Non-Promise Statement

No script can guarantee direction, continuation, reversal, or outcome.

This tool provides structured chart context only.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own analysis, risk controls, position sizing, and trading decisions.

This script does not provide financial advice, investment advice, or guaranteed trading outcomes.


📚 Educational Note

Use the script to study how triggered setups behave after activation. The most useful reading comes from comparing progress, elapsed bars, risk shelf behavior, and broader market context.

## Source Code

````pine
// -------------------------------------------------
// No-Progress Failure Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.8
//
// No-Progress Failure Map is a chart-first post-trigger progress review tool.
// It tracks whether a triggered setup is actually moving after activation, or
// whether it is stalling, reclaiming, losing time, or failing through lack of
// meaningful progress. The script maps trigger price, minimum progress rail,
// risk shelf, elapsed bars, travel quality, reclaim behavior, and failure
// pressure into a premium workflow-style progress map, and adds a confirmation-
// anchored proof layer (Follow, Hold, React, Flip rates) that shows how past
// trigger windows on this symbol resolved - without acting as a signal printer,
// prediction engine, or automated trade system.
// -------------------------------------------------

//@version=6
indicator("No-Progress Failure Map [AGPro Series]",
     shorttitle       = "AG Pro NPF",
     overlay          = true,
     max_labels_count = 140,
     max_boxes_count  = 30,
     max_lines_count  = 70)

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
color dangerColor   = color.rgb(239, 68, 68)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
string ttPreset = "Selects the operating profile. Balanced Map is the publication default. Cleaner Swing reduces label density. Active Intraday keeps the map more responsive. Custom uses the raw input values."
string ttSide = "Selects the setup direction used by the planner. Auto follows trend and slope context, while manual modes force long-side or short-side progress evaluation."
string ttTrigger = "Selects the trigger model that starts a progress-tracking window. The output remains an attention marker, not a trade entry command."
string ttLookback = "Lookback used to define the recent trigger boundary and initial risk shelf. Higher values make triggers slower and more selective."
string ttAtr = "ATR length used to normalize distance travelled, risk shelf distance, label offset, and progress targets."
string ttTrend = "EMA length used for auto side selection and trend-support context. It is not used as a standalone signal."
string ttVolume = "Volume baseline used to estimate whether post-trigger movement has participation. Symbols with limited volume data fall back to a neutral reading."
string ttConfirm = "Close Confirmed waits for closed bars before new labels, alerts, and proof evaluation. Live Updating can react before the candle is closed."
string ttEval = "Number of bars allowed for the setup to show minimum progress after a trigger. If progress is weak after this window, failure review becomes more important."
string ttTrack = "Maximum number of bars to keep tracking the active trigger before the map expires the progress window."
string ttTriggerCooldown = "Minimum bars to wait after a tracked window closes before a new trigger can start. Higher values reduce repeated trigger clusters."
string ttMinTravel = "Minimum favorable ATR travel expected before the evaluation window matures. Weak travel after this point can mark no-progress failure risk."
string ttRecovery = "ATR travel level that confirms enough follow-through to move from stalled or review state into progress-accepted context."
string ttImpulse = "Minimum candle body size, measured in ATR, required by the Impulse Close trigger model."
string ttRiskBuffer = "ATR buffer added beyond the initial risk shelf. Crossing this shelf marks the tracked setup as failed inside this map."
string ttMinVolume = "Participation reference for the volume component. Higher values require stronger relative volume before the progress score improves."
string ttFailure = "Minimum progress score needed to avoid failure-review state after the evaluation window matures."
string ttRecoveryScore = "Minimum progress score used for accepted-progress context."
string ttShowBox = "Shows the post-trigger progress map between the risk shelf and the minimum progress rail. A single solid status badge centered inside the active map is the primary chart-first progress meter."
string ttShowRails = "Shows the active trigger price, minimum progress rail, and risk shelf as projected guide lines."
string ttRailLabels = "Shows compact right-side labels for trigger, progress, and risk rails. Labels are connected to their rail endpoints for clarity."
string ttMemory = "Keeps a small number of prior progress windows as soft memory boxes when a new trigger appears. Prior windows are shown as faded zones; their outcome is marked by event labels."
string ttForward = "Number of bars the active box and rails project to the right for readability."
string ttSmartWidth = "Automatically keeps the active progress map tighter on weekly and monthly charts so the zone does not dominate publication screenshots."
string ttZoneOpacity = "Transparency of active and archived progress-map zones. Higher values make the map lighter."
string ttLabels = "Shows compact workflow labels for trigger, review, no-progress, reclaim, progress accepted, and failed events."
string ttContext = "Adds sparse progress labels while a setup is being tracked. Disabled by default to avoid chart crowding."
string ttLabelMode = "Compact keeps labels short for publication screenshots. Detailed adds state and distance context."
string ttCooldown = "Minimum bars between event labels. Higher values reduce label density."
string ttContextSpacing = "Minimum spacing between sparse progress labels during an active tracking window."
string ttMaxLabels = "Maximum number of labels retained on the chart. Older labels are removed first for performance."
string ttOffset = "ATR-based label offset used to keep labels above or below candles instead of buried inside price bars."
string ttScore = "Adds the 0-100 progress score to chart labels."
string ttLabelSize = "Font size for all chart labels, rail tags, and the progress-map status badge. Normal is the recommended publication default."
string ttPanel = "Shows or hides the AG Pro planning panel. The panel is visible by default for public-release readability."
string ttProof = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across all resolved trigger windows on the current symbol and timeframe. These are historical outcome rates, not predictions."
string ttReactBars = "Number of bars after a trigger used to detect an immediate favorable reaction. Lower values require a faster initial push to count as a React."
string ttReactProg = "Minimum favorable progress toward the accepted-progress distance, within the reaction window, required to count a window as an early React."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Failure Map Engine"
string enginePreset = input.string("Balanced Map", "Engine Preset", options = ["Balanced Map", "Cleaner Swing", "Active Intraday", "Custom"], group = groupEngine, tooltip = ttPreset)
string sideMode = input.string("Auto", "Evaluation Side", options = ["Auto", "Long Context", "Short Context"], group = groupEngine, tooltip = ttSide)
string triggerModel = input.string("Range Break", "Trigger Model", options = ["Range Break", "Impulse Close", "Trend Reclaim"], group = groupEngine, tooltip = ttTrigger)
int triggerLookback = input.int(34, "Trigger Lookback", minval = 8, maxval = 180, group = groupEngine, tooltip = ttLookback)
int atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = ttAtr)
int trendLen = input.int(55, "Trend Context EMA", minval = 5, maxval = 240, group = groupEngine, tooltip = ttTrend)
int volumeLen = input.int(20, "Volume Baseline", minval = 5, maxval = 120, group = groupEngine, tooltip = ttVolume)
string confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = ttConfirm)

string groupScoring = "Progress Scoring"
int evaluationBars = input.int(14, "Evaluation Window Bars", minval = 4, maxval = 80, group = groupScoring, tooltip = ttEval)
int maxTrackBars = input.int(42, "Maximum Tracking Bars", minval = 10, maxval = 160, group = groupScoring, tooltip = ttTrack)
int triggerCooldownBars = input.int(14, "Trigger Cooldown Bars", minval = 0, maxval = 120, group = groupScoring, tooltip = ttTriggerCooldown)
float minimumTravelAtr = input.float(0.85, "Minimum Progress ATR", minval = 0.10, maxval = 6.00, step = 0.05, group = groupScoring, tooltip = ttMinTravel)
float recoveryTravelAtr = input.float(1.35, "Progress Accepted ATR", minval = 0.20, maxval = 8.00, step = 0.05, group = groupScoring, tooltip = ttRecovery)
float impulseBodyAtr = input.float(0.45, "Impulse Body ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupScoring, tooltip = ttImpulse)
float riskBufferAtr = input.float(0.20, "Risk Shelf Buffer ATR", minval = 0.00, maxval = 2.00, step = 0.05, group = groupScoring, tooltip = ttRiskBuffer)
float minimumVolumeRatio = input.float(0.90, "Minimum Volume Ratio", minval = 0.20, maxval = 3.00, step = 0.05, group = groupScoring, tooltip = ttMinVolume)
int failureRiskScore = input.int(46, "Failure Review Score", minval = 15, maxval = 80, group = groupScoring, tooltip = ttFailure)
int recoveryScore = input.int(64, "Progress Accepted Score", minval = 35, maxval = 90, group = groupScoring, tooltip = ttRecoveryScore)

string groupVisual = "Chart Visuals"
bool showProgressMap = input.bool(true, "Show Progress Map Zone", group = groupVisual, tooltip = ttShowBox)
bool showRails = input.bool(true, "Show Trigger / Progress / Risk Rails", group = groupVisual, tooltip = ttShowRails)
bool showRailLabels = input.bool(true, "Show Rail Labels", group = groupVisual, tooltip = ttRailLabels)
bool showMemoryBoxes = input.bool(true, "Show Prior Progress Zones", group = groupVisual, tooltip = ttMemory)
int memoryBoxCount = input.int(1, "Max Prior Zones", minval = 0, maxval = 10, group = groupVisual, tooltip = ttMemory)
int forwardBars = input.int(24, "Forward Render Bars", minval = 6, maxval = 120, group = groupVisual, tooltip = ttForward)
bool smartMapWidth = input.bool(true, "Smart Higher-Timeframe Width", group = groupVisual, tooltip = ttSmartWidth)
int zoneTransparency = input.int(91, "Zone Transparency", minval = 78, maxval = 96, group = groupVisual, tooltip = ttZoneOpacity)

string groupLabels = "Labels"
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
bool showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContext)
string labelTextMode = input.string("Compact", "Label Text Mode", options = ["Compact", "Detailed"], group = groupLabels, tooltip = ttLabelMode)
int labelCooldownBars = input.int(18, "Label Cooldown Bars", minval = 1, maxval = 80, group = groupLabels, tooltip = ttCooldown)
int contextSpacingBars = input.int(42, "Context Label Spacing", minval = 10, maxval = 160, group = groupLabels, tooltip = ttContextSpacing)
int maxVisibleLabels = input.int(8, "Max Visible Labels", minval = 3, maxval = 40, group = groupLabels, tooltip = ttMaxLabels)
float labelOffsetAtr = input.float(1.05, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttOffset)
bool showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttScore)
string labelFontSize = input.string("Large", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttPanel)
string panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = "Moves the panel to the preferred chart location.")
string panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = "Switches the panel between the AG Pro dark theme and a clean light theme.")
string panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = "Font size for the planning panel. Normal is the recommended publication default.")

string groupProof = "Proof"
bool showProof = input.bool(true, "Show Proof Layer", group = groupProof, tooltip = ttProof)
int reactBars = input.int(3, "Reaction Window Bars", minval = 1, maxval = 30, group = groupProof, tooltip = ttReactBars)
float reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = groupProof, tooltip = ttReactProg)

string groupAlerts = "Alerts"
bool alertTriggers = input.bool(true, "Alert on Trigger Window", group = groupAlerts, tooltip = "Enables alerts when a new post-trigger progress window starts.")
bool alertFailureStates = input.bool(true, "Alert on Failure / Progress States", group = groupAlerts, tooltip = "Enables alerts for no-progress review, progress accepted, reclaim, failed, and expired states.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_titlecase(string s) =>
    switch s
        "WAITING" => "Waiting"
        "FAILED" => "Failed"
        "PROGRESS OK" => "Progress OK"
        "EXPIRED" => "Expired"
        "NO PROGRESS" => "No Progress"
        "STALLED" => "Stalled"
        "RECOVERY" => "Recovery"
        "ON TRACK" => "On Track"
        "REVIEW" => "Review"
        => s

f_norm_high_good(float value, float weak, float strong) =>
    float span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float good, float bad) =>
    float span = bad - good
    span == 0.0 ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

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
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_panel_bg(bool isLight, bool alt) =>
    isLight ? (alt ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)) : (alt ? color.rgb(20, 31, 52) : panelBg)

f_panel_border(bool isLight) =>
    isLight ? color.rgb(203, 213, 225) : panelBorder

f_panel_label(bool isLight) =>
    isLight ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(bool isLight) =>
    isLight ? color.rgb(15, 23, 42) : panelValueCol

f_state_color(string stateText) =>
    switch stateText
        "PROGRESS OK" => bullColor
        "ON TRACK" => bullColor
        "RECOVERY" => accentColor
        "REVIEW" => accentColor
        "STALLED" => neutralColor
        "NO PROGRESS" => bearColor
        "FAILED" => dangerColor
        "EXPIRED" => panelLabelCol
        => panelLabelCol

f_score_color(int scoreValue, int recoveryLevel, int failureLevel) =>
    scoreValue >= recoveryLevel ? bullColor : scoreValue >= failureLevel ? neutralColor : bearColor

f_pressure_color(int pressureValue) =>
    pressureValue >= 72 ? bearColor : pressureValue >= 45 ? neutralColor : bullColor

f_rate_color(float value) =>
    value >= 55 ? bullColor : value >= 40 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30 ? bullColor : value <= 55 ? neutralColor : bearColor

f_best_view_text() =>
    timeframe.isintraday ? "1H / 4H / 1D" : timeframe.isdaily ? "Daily chart" : "4H / 1D"

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        label oldLabel = array.shift(labels)
        label.delete(oldLabel)

f_trim_boxes(array<box> boxes, int maxCount) =>
    while array.size(boxes) > maxCount
        box oldBox = array.shift(boxes)
        box.delete(oldBox)

f_delete_label(label labelId) =>
    if not na(labelId)
        label.delete(labelId)

f_label_text(string codeText, string detailText, int scoreValue) =>
    string scoreText = showLabelScore ? str.tostring(scoreValue) : ""
    labelTextMode == "Compact" ? (showLabelScore ? codeText + " " + scoreText : codeText) : (showLabelScore ? codeText + "\n" + detailText + "\nScore " + scoreText : codeText + "\n" + detailText)

f_add_label(array<label> labels, string textValue, float labelY, bool labelAbovePrice, color labelColor, string tipText, int limit) =>
    label newLabel = label.new(x = bar_index, y = labelY, text = textValue, xloc = xloc.bar_index, yloc = yloc.price, style = labelAbovePrice ? label.style_label_down : label.style_label_up, textcolor = headerText, color = color.new(labelColor, 0), size = f_text_size(labelFontSize), tooltip = tipText, textalign = text.align_center)
    array.push(labels, newLabel)
    f_trim_labels(labels, limit)

f_set_row(table target, int row, string leftText, string rightText, color rightColor, bool isLight, bool altRow, string fontSize) =>
    color rowBg = f_panel_bg(isLight, altRow)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(isLight), bgcolor = rowBg, text_size = f_text_size(fontSize))
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_right)

// -------------------------------------------------
// Presets
// -------------------------------------------------
bool cleanerPreset = enginePreset == "Cleaner Swing"
bool activePreset = enginePreset == "Active Intraday"
int usedLabelCooldown = cleanerPreset ? math.max(labelCooldownBars, 26) : activePreset ? math.min(labelCooldownBars, 10) : labelCooldownBars
int usedContextSpacing = cleanerPreset ? math.max(contextSpacingBars, 64) : activePreset ? math.min(contextSpacingBars, 28) : contextSpacingBars
int usedMaxLabels = cleanerPreset ? math.min(maxVisibleLabels, 5) : activePreset ? math.min(maxVisibleLabels, 10) : math.min(maxVisibleLabels, 8)
int usedMemoryCount = cleanerPreset ? math.min(memoryBoxCount, 1) : memoryBoxCount
int usedTriggerCooldown = cleanerPreset ? math.max(triggerCooldownBars, 22) : activePreset ? math.min(triggerCooldownBars, 8) : triggerCooldownBars
int usedEvaluationBars = cleanerPreset ? math.max(evaluationBars, 18) : activePreset ? math.max(evaluationBars - 2, 4) : evaluationBars
int usedForwardBars = smartMapWidth and (timeframe.isweekly or timeframe.ismonthly) ? math.min(forwardBars, 18) : forwardBars

float effectiveMinimumTravelAtr = math.min(minimumTravelAtr, recoveryTravelAtr)
float effectiveRecoveryTravelAtr = math.max(recoveryTravelAtr, effectiveMinimumTravelAtr + 0.05)
int effectiveFailureRiskScore = math.min(failureRiskScore, recoveryScore - 1)
int effectiveRecoveryScore = math.max(recoveryScore, effectiveFailureRiskScore + 1)
int usedReactBars = math.min(reactBars, math.max(usedEvaluationBars, 1))

// -------------------------------------------------
// Core measurements
// -------------------------------------------------
bool confirmedBar = confirmationMode == "Close Confirmed" ? barstate.isconfirmed : true
int trackLimitBars = math.max(maxTrackBars, usedEvaluationBars + 1)
float atr = ta.atr(atrLen)
float safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
float trendBasis = ta.ema(close, trendLen)
float trendSlope = trendBasis - nz(trendBasis[5], trendBasis)
float volumeAverage = ta.sma(nz(volume, 0.0), volumeLen)
float volumeRatio = volumeAverage > 0.0 ? nz(volume, 0.0) / volumeAverage : 1.0
float volumeReady = na(volume) or volumeAverage <= 0.0 ? 1.0 : volumeRatio

float priorHigh = nz(ta.highest(high[1], triggerLookback), high)
float priorLow = nz(ta.lowest(low[1], triggerLookback), low)
float bodyAtr = math.abs(close - open) / safeAtr

bool autoLong = close >= trendBasis and trendSlope >= 0.0
bool longContext = sideMode == "Long Context" ? true : sideMode == "Short Context" ? false : autoLong

bool longRangeTrigger = close > priorHigh and nz(close[1], close) <= priorHigh
bool shortRangeTrigger = close < priorLow and nz(close[1], close) >= priorLow
bool longImpulseTrigger = close > open and close > nz(high[1], high) and bodyAtr >= impulseBodyAtr and close >= trendBasis
bool shortImpulseTrigger = close < open and close < nz(low[1], low) and bodyAtr >= impulseBodyAtr and close <= trendBasis
bool longReclaimTrigger = close > trendBasis and nz(close[1], close) <= nz(trendBasis[1], trendBasis)
bool shortReclaimTrigger = close < trendBasis and nz(close[1], close) >= nz(trendBasis[1], trendBasis)

bool rawLongTrigger = triggerModel == "Range Break" ? longRangeTrigger : triggerModel == "Impulse Close" ? longImpulseTrigger : longReclaimTrigger
bool rawShortTrigger = triggerModel == "Range Break" ? shortRangeTrigger : triggerModel == "Impulse Close" ? shortImpulseTrigger : shortReclaimTrigger

// -------------------------------------------------
// Persistent state
// -------------------------------------------------
var bool hasSetup = false
var bool activeLong = true
var bool lockedFailed = false
var bool lostTrigger = false
var bool reclaimedTrigger = false
var bool failureWarned = false
var bool progressMarked = false
var bool expiredMarked = false
var int triggerBar = na
var int terminalBar = na
var int lastClosedWindowBar = na
var float triggerPrice = na
var float triggerAtr = na
var float riskShelf = na
var float progressRail = na
var float activeBest = na

var box activeBox = na
var label activeZoneBadge = na
var line triggerLine = na
var line riskLine = na
var line progressLine = na
var label triggerRailTag = na
var label riskRailTag = na
var label progressRailTag = na
var array<box> progressBoxes = array.new_box()
var array<label> eventLabels = array.new_label()
var int lastEventLabelBar = na
var int lastContextLabelBar = na

// Confirmation-anchored proof state
var int proofTotal = 0
var int proofFollow = 0
var int proofHold = 0
var int proofReact = 0
var int proofFlip = 0
var int proofAmbiguous = 0
var bool proofCounted = false
var bool earlyReact = false

if not showMemoryBoxes and array.size(progressBoxes) > 1
    while array.size(progressBoxes) > 1
        box oldMemoryBox = array.shift(progressBoxes)
        box.delete(oldMemoryBox)

bool cooldownReadyForTrigger = na(lastClosedWindowBar) or bar_index - lastClosedWindowBar >= usedTriggerCooldown
bool newTrigger = confirmedBar and not hasSetup and cooldownReadyForTrigger and (longContext ? rawLongTrigger : rawShortTrigger)

bool triggerEvent = false
bool failureEvent = false
bool progressEvent = false
bool reclaimEvent = false
bool failedEvent = false
bool expiredEvent = false

if newTrigger
    if not na(triggerLine)
        line.delete(triggerLine)
        triggerLine := na
    if not na(riskLine)
        line.delete(riskLine)
        riskLine := na
    if not na(progressLine)
        line.delete(progressLine)
        progressLine := na
    f_delete_label(triggerRailTag)
    f_delete_label(progressRailTag)
    f_delete_label(riskRailTag)
    f_delete_label(activeZoneBadge)
    triggerRailTag := na
    progressRailTag := na
    riskRailTag := na
    activeZoneBadge := na

    hasSetup := true
    activeLong := longContext
    lockedFailed := false
    lostTrigger := false
    reclaimedTrigger := false
    failureWarned := false
    progressMarked := false
    expiredMarked := false
    proofCounted := false
    earlyReact := false
    triggerBar := bar_index
    terminalBar := na
    triggerPrice := close
    triggerAtr := safeAtr
    float shelfBase = activeLong ? priorLow : priorHigh
    riskShelf := activeLong ? shelfBase - safeAtr * riskBufferAtr : shelfBase + safeAtr * riskBufferAtr
    progressRail := activeLong ? triggerPrice + safeAtr * effectiveMinimumTravelAtr : triggerPrice - safeAtr * effectiveMinimumTravelAtr
    activeBest := activeLong ? high : low
    activeBox := na
    triggerEvent := true

if hasSetup
    activeBest := activeLong ? math.max(nz(activeBest, high), high) : math.min(nz(activeBest, low), low)
    bool lostNow = activeLong ? close < triggerPrice : close > triggerPrice
    lostTrigger := lostTrigger or lostNow
    bool regainedNow = activeLong ? close >= triggerPrice : close <= triggerPrice
    reclaimEvent := confirmedBar and lostTrigger and regainedNow and not reclaimedTrigger and not lockedFailed and not progressMarked
    reclaimedTrigger := reclaimedTrigger or reclaimEvent

int elapsedBars = hasSetup ? math.max(bar_index - triggerBar, 0) : 0
float favorableDistance = hasSetup ? (activeLong ? math.max(activeBest - triggerPrice, 0.0) : math.max(triggerPrice - activeBest, 0.0)) : 0.0
float closeProgressDistance = hasSetup ? (activeLong ? math.max(close - triggerPrice, 0.0) : math.max(triggerPrice - close, 0.0)) : 0.0
float progressAtr = hasSetup and triggerAtr > 0.0 ? favorableDistance / triggerAtr : 0.0
float closeProgressAtr = hasSetup and triggerAtr > 0.0 ? closeProgressDistance / triggerAtr : 0.0

// Early reaction detection for the proof layer
if hasSetup and confirmedBar and not earlyReact and elapsedBars >= 1 and elapsedBars <= usedReactBars and progressAtr >= effectiveRecoveryTravelAtr * reactProgressPct / 100.0
    earlyReact := true

float travelComponent = hasSetup ? f_norm_high_good(progressAtr, 0.0, effectiveRecoveryTravelAtr) : 0.0
float efficiencyComponent = hasSetup and progressAtr > 0.0 ? f_clamp(closeProgressAtr / progressAtr * 100.0, 0.0, 100.0) : 0.0
float volumeComponent = hasSetup ? f_norm_high_good(volumeReady, minimumVolumeRatio * 0.70, minimumVolumeRatio * 1.35) : 0.0
float decayComponent = hasSetup ? f_norm_low_good(float(elapsedBars), float(usedEvaluationBars), float(trackLimitBars)) : 0.0
float reclaimComponent = hasSetup ? (lostTrigger ? (reclaimedTrigger ? 84.0 : 24.0) : 76.0) : 0.0

float scoreRaw = travelComponent * 0.38 + efficiencyComponent * 0.20 + volumeComponent * 0.16 + decayComponent * 0.16 + reclaimComponent * 0.10

bool riskTouchedNow = hasSetup and not lockedFailed and (activeLong ? low <= riskShelf : high >= riskShelf)
bool progressCandidateNow = hasSetup and not lockedFailed and not progressMarked and progressAtr >= effectiveRecoveryTravelAtr and scoreRaw >= effectiveRecoveryScore
bool ambiguousOutcomeNow = confirmedBar and riskTouchedNow and progressCandidateNow

bool invalidatedNow = confirmedBar and riskTouchedNow
if invalidatedNow
    lockedFailed := true
    terminalBar := bar_index
failedEvent := invalidatedNow

bool progressNow = confirmedBar and progressCandidateNow and not invalidatedNow
if progressNow
    progressMarked := true
    terminalBar := bar_index
progressEvent := progressNow

bool failureNow = hasSetup and confirmedBar and not failureWarned and not lockedFailed and not progressMarked and elapsedBars >= usedEvaluationBars and progressAtr < effectiveMinimumTravelAtr and scoreRaw < effectiveFailureRiskScore
if failureNow
    failureWarned := true
failureEvent := failureNow

bool expiredNow = hasSetup and confirmedBar and not lockedFailed and not progressMarked and elapsedBars > trackLimitBars
if expiredNow and not expiredMarked
    expiredMarked := true
    terminalBar := bar_index
expiredEvent := expiredNow and expiredMarked and terminalBar == bar_index

// Proof tally: resolve each trigger window once. Bars touching both the progress
// threshold and risk shelf are sequence-ambiguous and excluded from rate statistics.
if hasSetup and not proofCounted and (failedEvent or progressEvent or expiredEvent)
    proofCounted := true
    if ambiguousOutcomeNow
        proofAmbiguous := proofAmbiguous + 1
    else
        proofTotal := proofTotal + 1
        if progressEvent
            proofFollow := proofFollow + 1
        if not failedEvent
            proofHold := proofHold + 1
        if earlyReact
            proofReact := proofReact + 1
        if failedEvent
            proofFlip := proofFlip + 1

float scoreAdjusted = lockedFailed ? math.min(scoreRaw, 18.0) : expiredMarked ? math.min(scoreRaw, 42.0) : scoreRaw
int progressScore = int(math.round(f_clamp(scoreAdjusted, 0.0, 100.0)))
float timePressure = hasSetup ? f_norm_high_good(float(elapsedBars), float(math.max(1, usedEvaluationBars / 2)), float(usedEvaluationBars)) : 0.0
float failureRiskRaw = hasSetup ? 100.0 - progressScore + timePressure * 0.25 + (lostTrigger and not reclaimedTrigger ? 12.0 : 0.0) : 0.0
int failureRisk = int(math.round(f_clamp(lockedFailed ? 100.0 : failureRiskRaw, 0.0, 100.0)))

string stateText = not hasSetup ? "WAITING" : lockedFailed ? "FAILED" : progressMarked ? "PROGRESS OK" : expiredMarked ? "EXPIRED" : failureWarned ? "NO PROGRESS" : lostTrigger and not reclaimedTrigger ? "STALLED" : reclaimedTrigger ? "RECOVERY" : progressAtr >= effectiveMinimumTravelAtr ? "ON TRACK" : "REVIEW"
string actionText = switch stateText
    "PROGRESS OK" => "Progress Accepted"
    "ON TRACK" => "Track Progress"
    "RECOVERY" => "Monitor Reclaim"
    "STALLED" => "Watch Reclaim"
    "NO PROGRESS" => "Review Failure"
    "FAILED" => "Reset Context"
    "EXPIRED" => "Wait New Trigger"
    => hasSetup ? "Review Progress" : "Wait For Trigger"

color stateColor = f_state_color(stateText)

// -------------------------------------------------
// Chart visuals
// -------------------------------------------------
int renderRight = hasSetup ? math.min(bar_index + usedForwardBars, triggerBar + trackLimitBars + usedForwardBars) : bar_index + usedForwardBars
int railRight = renderRight + 1
float boxTop = hasSetup ? math.max(riskShelf, progressRail) : high
float boxBottom = hasSetup ? math.min(riskShelf, progressRail) : low
float boxHeight = math.max(boxTop - boxBottom, syminfo.mintick)
int badgeX = hasSetup ? triggerBar + int(math.round((renderRight - triggerBar) * 0.5)) : bar_index
float badgeY = hasSetup ? (boxTop + boxBottom) * 0.5 : close
string headlineText = f_titlecase(stateText)
string badgeText = headlineText + " | Q" + str.tostring(progressScore) + "\nTravel " + str.tostring(progressAtr, "#.##") + " ATR | Pressure " + str.tostring(failureRisk)
int windowLimit = showMemoryBoxes ? usedMemoryCount + 1 : 1

if showProgressMap and hasSetup and (barstate.islast or triggerEvent or failedEvent or progressEvent or expiredEvent)
    if na(activeBox)
        activeBox := box.new(left = triggerBar, top = boxTop, right = renderRight, bottom = boxBottom, xloc = xloc.bar_index, bgcolor = color.new(stateColor, zoneTransparency), border_color = color.new(stateColor, 30), border_width = progressMarked or lockedFailed ? 2 : 1)
        array.push(progressBoxes, activeBox)
        f_trim_boxes(progressBoxes, windowLimit)
    else
        box.set_left(activeBox, triggerBar)
        box.set_right(activeBox, renderRight)
        box.set_top(activeBox, boxTop)
        box.set_bottom(activeBox, boxBottom)
        box.set_bgcolor(activeBox, color.new(stateColor, zoneTransparency))
        box.set_border_color(activeBox, color.new(stateColor, 30))
        box.set_border_width(activeBox, progressMarked or lockedFailed ? 2 : 1)

    labelStyleAnchor = label.style_label_center
    if na(activeZoneBadge)
        activeZoneBadge := label.new(badgeX, badgeY, badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = labelStyleAnchor, color = color.new(stateColor, 0), textcolor = headerText, size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_xy(activeZoneBadge, badgeX, badgeY)
        label.set_text(activeZoneBadge, badgeText)
        label.set_style(activeZoneBadge, labelStyleAnchor)
        label.set_color(activeZoneBadge, color.new(stateColor, 0))
        label.set_textcolor(activeZoneBadge, headerText)
        label.set_size(activeZoneBadge, f_text_size(labelFontSize))
        label.set_textalign(activeZoneBadge, text.align_center)
else if not showProgressMap and not na(activeBox)
    box.delete(activeBox)
    activeBox := na
    f_delete_label(activeZoneBadge)
    activeZoneBadge := na

if showRails and hasSetup and (barstate.islast or triggerEvent or failedEvent or progressEvent or expiredEvent)
    if na(triggerLine)
        triggerLine := line.new(x1 = triggerBar, y1 = triggerPrice, x2 = railRight, y2 = triggerPrice, xloc = xloc.bar_index, color = color.new(accentColor, 12), width = 2, style = line.style_dotted)
    else
        line.set_xy1(triggerLine, triggerBar, triggerPrice)
        line.set_xy2(triggerLine, railRight, triggerPrice)
        line.set_color(triggerLine, color.new(accentColor, 12))
        line.set_width(triggerLine, 2)

    if na(progressLine)
        progressLine := line.new(x1 = triggerBar, y1 = progressRail, x2 = railRight, y2 = progressRail, xloc = xloc.bar_index, color = color.new(bullColor, 8), width = 2, style = line.style_dashed)
    else
        line.set_xy1(progressLine, triggerBar, progressRail)
        line.set_xy2(progressLine, railRight, progressRail)
        line.set_color(progressLine, color.new(bullColor, 8))
        line.set_width(progressLine, 2)

    if na(riskLine)
        riskLine := line.new(x1 = triggerBar, y1 = riskShelf, x2 = railRight, y2 = riskShelf, xloc = xloc.bar_index, color = color.new(dangerColor, 8), width = 2, style = line.style_dashed)
    else
        line.set_xy1(riskLine, triggerBar, riskShelf)
        line.set_xy2(riskLine, railRight, riskShelf)
        line.set_color(riskLine, color.new(dangerColor, 8))
        line.set_width(riskLine, 2)

    if showRailLabels
        string triggerTagText = "Trigger\n" + str.tostring(triggerPrice, format.mintick)
        string progressTagText = "Progress\n" + str.tostring(progressRail, format.mintick)
        string riskTagText = "Risk Shelf\n" + str.tostring(riskShelf, format.mintick)
        int triggerTagX = railRight
        int progressTagX = railRight + 2
        int riskTagX = railRight + 4
        if na(triggerRailTag)
            triggerRailTag := label.new(triggerTagX, triggerPrice, triggerTagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 0), textcolor = headerText, size = f_text_size(labelFontSize), textalign = text.align_center)
            progressRailTag := label.new(progressTagX, progressRail, progressTagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bullColor, 0), textcolor = headerText, size = f_text_size(labelFontSize), textalign = text.align_center)
            riskRailTag := label.new(riskTagX, riskShelf, riskTagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(dangerColor, 0), textcolor = headerText, size = f_text_size(labelFontSize), textalign = text.align_center)
        else
            label.set_xy(triggerRailTag, triggerTagX, triggerPrice)
            label.set_text(triggerRailTag, triggerTagText)
            label.set_size(triggerRailTag, f_text_size(labelFontSize))
            label.set_color(triggerRailTag, color.new(accentColor, 0))
            label.set_xy(progressRailTag, progressTagX, progressRail)
            label.set_text(progressRailTag, progressTagText)
            label.set_size(progressRailTag, f_text_size(labelFontSize))
            label.set_color(progressRailTag, color.new(bullColor, 0))
            label.set_xy(riskRailTag, riskTagX, riskShelf)
            label.set_text(riskRailTag, riskTagText)
            label.set_size(riskRailTag, f_text_size(labelFontSize))
            label.set_color(riskRailTag, color.new(dangerColor, 0))
    else
        f_delete_label(triggerRailTag)
        f_delete_label(progressRailTag)
        f_delete_label(riskRailTag)
        triggerRailTag := na
        progressRailTag := na
        riskRailTag := na
else
    if not na(triggerLine)
        line.delete(triggerLine)
        triggerLine := na
    if not na(riskLine)
        line.delete(riskLine)
        riskLine := na
    if not na(progressLine)
        line.delete(progressLine)
        progressLine := na
    f_delete_label(triggerRailTag)
    f_delete_label(progressRailTag)
    f_delete_label(riskRailTag)
    triggerRailTag := na
    progressRailTag := na
    riskRailTag := na

// -------------------------------------------------
// Labels
// -------------------------------------------------
bool eventLabelAbove = hasSetup ? activeLong : true
float eventY = eventLabelAbove ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
bool canEventLabel = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= usedLabelCooldown

if showEventLabels and triggerEvent
    string textValue = f_label_text("Trigger", activeLong ? "Long-side progress window" : "Short-side progress window", progressScore)
    f_add_label(eventLabels, textValue, eventY, eventLabelAbove, accentColor, "A new setup trigger started a post-trigger progress window. This is an attention marker, not a trade instruction.", usedMaxLabels)
    lastEventLabelBar := bar_index

if showEventLabels and failedEvent and canEventLabel
    string textValue = f_label_text("Failed", "Risk shelf crossed", progressScore)
    f_add_label(eventLabels, textValue, eventY, eventLabelAbove, dangerColor, "The tracked setup crossed its risk shelf. The map marks the setup as failed inside this rule set.", usedMaxLabels)
    lastEventLabelBar := bar_index

if showEventLabels and failureEvent and canEventLabel
    string textValue = f_label_text("No Progress", "Evaluation window matured without enough travel", progressScore)
    f_add_label(eventLabels, textValue, eventY, eventLabelAbove, bearColor, "The setup did not travel far enough after the trigger. This label marks failure review context, not a trade command.", usedMaxLabels)
    lastEventLabelBar := bar_index

if showEventLabels and progressEvent and canEventLabel
    string textValue = f_label_text("Progress OK", "Minimum follow-through accepted", progressScore)
    f_add_label(eventLabels, textValue, eventY, eventLabelAbove, bullColor, "The active setup reached the accepted progress threshold with enough score support.", usedMaxLabels)
    lastEventLabelBar := bar_index

if showEventLabels and reclaimEvent and canEventLabel
    string textValue = f_label_text("Reclaim", "Trigger recovered after loss", progressScore)
    f_add_label(eventLabels, textValue, eventY, eventLabelAbove, neutralColor, "Price reclaimed the trigger side after losing it. This marks recovery context, not certainty.", usedMaxLabels)
    lastEventLabelBar := bar_index

if showEventLabels and expiredEvent and canEventLabel
    string textValue = f_label_text("Expired", "Progress window closed", progressScore)
    f_add_label(eventLabels, textValue, eventY, eventLabelAbove, panelLabelCol, "The tracked progress window expired before a stronger progress state appeared.", usedMaxLabels)
    lastEventLabelBar := bar_index

if showContextLabels and hasSetup and confirmedBar and not triggerEvent and not failedEvent and not failureEvent and not progressEvent and not reclaimEvent and not expiredEvent and (na(lastContextLabelBar) or bar_index - lastContextLabelBar >= usedContextSpacing)
    string contextCode = f_titlecase(stateText)
    string textValue = f_label_text(contextCode, str.tostring(progressAtr, "#.##") + " ATR travelled", progressScore)
    f_add_label(eventLabels, textValue, eventY, eventLabelAbove, stateColor, "Sparse progress context label. It summarizes the current tracked setup state and distance travelled.", usedMaxLabels)
    lastContextLabelBar := bar_index

// -------------------------------------------------
// Panel
// -------------------------------------------------
bool panelIsLight = panelThemeInput == "Light"
color panelFrame = f_panel_border(panelIsLight)
string panelSize = panelFontSizeInput
string scoreText = hasSetup ? str.tostring(progressScore) + " / 100" : "Waiting"
string elapsedText = hasSetup ? str.tostring(elapsedBars) + " / " + str.tostring(usedEvaluationBars) : "Waiting"
string distanceText = hasSetup ? str.tostring(progressAtr, "#.##") + " ATR" : "n/a"
string pressureText = hasSetup ? str.tostring(failureRisk) + " / 100" : "Neutral"
string reclaimText = hasSetup ? lostTrigger ? reclaimedTrigger ? "Recovered" : "Lost trigger" : "Held trigger" : "n/a"
string stateRead = hasSetup ? f_titlecase(stateText) + " | " + (activeLong ? "Long" : "Short") : "Waiting"
string bestViewText = f_best_view_text()

// Proof rates (confirmation-anchored, cumulative over resolved trigger windows)
float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0
string followText = proofTotal > 0 ? f_pct(followRate) : "-"
string holdText = proofTotal > 0 ? f_pct(holdRate) : "-"
string reactText = proofTotal > 0 ? f_pct(reactRate) : "-"
string flipText = proofTotal > 0 ? f_pct(flipRate) : "-"
color followCol = proofTotal > 0 ? f_rate_color(followRate) : panelLabelCol
color holdCol = proofTotal > 0 ? f_rate_color(holdRate) : panelLabelCol
color reactCol = proofTotal > 0 ? f_rate_color(reactRate) : panelLabelCol
color flipCol = proofTotal > 0 ? f_flip_color(flipRate) : panelLabelCol
string sampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) + (proofAmbiguous > 0 ? " | x = " + str.tostring(proofAmbiguous) : "") : proofAmbiguous > 0 ? "x = " + str.tostring(proofAmbiguous) : "building"

int panelRowCount = showProof ? 13 : 8
var table panel = table.new(position.top_right, 2, panelRowCount, bgcolor = panelBg, frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)

if barstate.islast
    table.set_position(panel, f_panel_position(panelLocationInput))
    table.set_frame_color(panel, panelFrame)
    table.set_border_color(panel, panelFrame)
    table.clear(panel, 0, 0, 1, panelRowCount - 1)
    if showPanel
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro No-Progress Failure Map", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelSize), text_halign = text.align_center)
        f_set_row(panel, 1, "Workflow State", stateRead, stateColor, panelIsLight, false, panelSize)
        f_set_row(panel, 2, "Progress Score", scoreText, f_score_color(progressScore, effectiveRecoveryScore, effectiveFailureRiskScore), panelIsLight, true, panelSize)
        f_set_row(panel, 3, "Elapsed Bars", elapsedText, hasSetup and elapsedBars > usedEvaluationBars ? neutralColor : f_panel_value(panelIsLight), panelIsLight, false, panelSize)
        f_set_row(panel, 4, "Progress Travel", distanceText, progressAtr >= effectiveMinimumTravelAtr ? bullColor : neutralColor, panelIsLight, true, panelSize)
        f_set_row(panel, 5, "Failure Pressure", pressureText, f_pressure_color(failureRisk), panelIsLight, false, panelSize)
        f_set_row(panel, 6, "Reclaim Status", reclaimText, reclaimedTrigger ? bullColor : lostTrigger ? neutralColor : accentColor, panelIsLight, true, panelSize)
        f_set_row(panel, 7, "Next Action", actionText + " | " + bestViewText, stateColor, panelIsLight, false, panelSize)
        if showProof
            color subBg = f_panel_bg(panelIsLight, true)
            table.cell(panel, 0, 8, "Proof @ Confirm", text_color = accentColor, bgcolor = subBg, text_size = f_text_size(panelSize))
            table.cell(panel, 1, 8, sampleText, text_color = f_panel_label(panelIsLight), bgcolor = subBg, text_size = f_text_size(panelSize), text_halign = text.align_right)
            f_set_row(panel, 9, "Follow Rate", followText, followCol, panelIsLight, false, panelSize)
            f_set_row(panel, 10, "Hold Rate", holdText, holdCol, panelIsLight, true, panelSize)
            f_set_row(panel, 11, "React Rate", reactText, reactCol, panelIsLight, false, panelSize)
            f_set_row(panel, 12, "Flip Rate", flipText, flipCol, panelIsLight, true, panelSize)

// -------------------------------------------------
// Closeout
// -------------------------------------------------
int terminalHoldBars = math.max(usedTriggerCooldown, 8)
bool terminalActive = hasSetup and not na(terminalBar)
if terminalActive and bar_index - terminalBar >= terminalHoldBars
    lastClosedWindowBar := terminalBar
    hasSetup := false
    triggerBar := na
    terminalBar := na
    triggerPrice := na
    triggerAtr := na
    riskShelf := na
    progressRail := na
    activeBest := na
    lockedFailed := false
    lostTrigger := false
    reclaimedTrigger := false
    failureWarned := false
    progressMarked := false
    expiredMarked := false

// -------------------------------------------------
// Alerts And Hidden Exports
// -------------------------------------------------
alertcondition(alertTriggers and triggerEvent, title = "No-Progress Trigger Window", message = "No-Progress Failure Map: a new post-trigger progress window is active.")
alertcondition(alertFailureStates and failureEvent, title = "No-Progress Failure Review", message = "No-Progress Failure Map: the setup has not travelled far enough after the evaluation window.")
alertcondition(alertFailureStates and progressEvent, title = "No-Progress Progress Accepted", message = "No-Progress Failure Map: the active setup has reached the accepted progress threshold.")
alertcondition(alertFailureStates and reclaimEvent, title = "No-Progress Reclaim", message = "No-Progress Failure Map: price reclaimed the trigger side after temporary loss.")
alertcondition(alertFailureStates and failedEvent, title = "No-Progress Failed", message = "No-Progress Failure Map: the tracked setup crossed its risk shelf.")
alertcondition(alertFailureStates and expiredEvent, title = "No-Progress Window Expired", message = "No-Progress Failure Map: the tracked progress window expired.")

plot(progressScore, "NPF Progress Score", display = display.none)
plot(failureRisk, "NPF Failure Pressure", display = display.none)
plot(progressAtr, "NPF Progress ATR", display = display.none)
plot(followRate, "NPF Follow Rate", display = display.none)
plot(holdRate, "NPF Hold Rate", display = display.none)
plot(reactRate, "NPF React Rate", display = display.none)
plot(flipRate, "NPF Flip Rate", display = display.none)
plot(proofAmbiguous, "NPF Ambiguous Proof Count", display = display.none)
````

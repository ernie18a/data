# Setup Lifecycle Tracker [AGPro Series]

- url: https://www.tradingview.com/script/qE6465pl-Setup-Lifecycle-Tracker-AGPro-Series/
- type: indicator
- pine_id: PUB;7b166f0aba08416bbebfcfb0c2f3ed89
- version: 6.0

## Description

Setup Lifecycle Tracker [AGPro Series]

🧠 Core Idea

What stage is this setup in right now: forming, armed, triggered, invalidated, or expired?


📌 Overview / What it does

Setup Lifecycle Tracker [AGPro Series] is a chart-first setup planning tool that follows a developing market structure through a defined lifecycle window.

Instead of showing another isolated signal, it maps the setup stage, trigger rail, invalidation rail, expiry marker, time risk, and a 0-100 lifecycle quality score directly on the chart.

The script does not predict price, automate execution, or tell users what to trade. It organizes setup context so the trader can evaluate whether the setup is still valid, still early, close to activation, already invalidated, or simply too old.


🎯 Purpose & Design Philosophy

This script was built for traders who want a cleaner way to manage setup timing.

Many setups look interesting when they first appear, but they often decay, trigger too late, or lose their invalidation logic before the trader reacts. Setup Lifecycle Tracker fills that gap by turning setup timing into a visible planning structure.

The design philosophy is simple: a setup should have a stage, a deadline, a risk reference, and a clear next-action state. Without those elements, the chart can become another collection of loose signals.


⚡ Why This Script Is Different

Most tools focus on entry markers, setup scores, or generic support and resistance levels.

This script does NOT try to clone a setup scorecard, create a buy/sell system, or build a broad support/resistance map.

Instead, it tracks the lifecycle of one active setup window. It shows whether the setup is forming, armed near the trigger rail, already triggered, invalidated by its risk rail, or expired because too much time has passed.


⚙️ Methodology

1. Context Detection
The script reads trend context, recent range structure, volatility, candle behavior, and volume support to decide whether a clean setup window can be tracked.

2. Reference Mapping
When a setup forms, the script creates a trigger rail, an invalidation rail, and a lifecycle window between them.

3. Reaction Evaluation
The model evaluates setup maturity, trigger proximity, confirmation strength, time decay, and invalidation distance to produce a 0-100 lifecycle score.

4. Visual Output
The active lifecycle window, stage labels, trigger rail, invalidation rail, expiry marker, candle tint, and panel summarize the current state.


🗺️ How to Read the Chart

Zones = the lifecycle window between trigger and invalidation.

Labels = current lifecycle stage and optional score.

Colors = stage context:
• Blue / indigo = forming
• Yellow = armed
• Green = triggered
• Red / pink = invalidated or expired

Panel = the compact AG Pro summary showing Stage, Quality Score, Time Risk, Invalidation, and Action.


🚦 Signals & States

• FORMING → a setup window has been detected but is not yet close enough to the trigger rail.

• ARMED → price is close enough to the trigger rail and the lifecycle score is strong enough to deserve attention.

• TRIGGERED → the tracked setup moved beyond its configured trigger condition.

• INVALIDATED → price crossed the invalidation rail and the setup context is no longer valid.

• EXPIRED → the setup stayed active too long without a useful lifecycle resolution.


🔔 Alerts Logic

The script includes alerts for:

• New lifecycle window forming
• Setup armed near the trigger rail
• Setup triggered
• Setup invalidated
• Setup expired
• High-quality lifecycle threshold reached

Alerts are attention markers only. They are not trade instructions, automated entries, or guaranteed outcome signals.


🧩 Confluence Logic

The lifecycle score becomes stronger when setup maturity, trigger proximity, confirmation strength, time health, and invalidation fit align.

For example, a setup that is mature, close to the trigger rail, supported by directional candle behavior, and not too close to invalidation will generally score better than an old setup with weak confirmation and high time risk.


📊 When to Use

• Breakout preparation
• Pullback continuation planning
• Range compression before expansion
• Setups that need a time limit
• Charts where invalidation needs to stay visible
• Traders who want to separate early setups from late setups


⚠️ When NOT to Use

• Extremely low-liquidity markets
• Charts with unreliable volume and erratic candles
• Very noisy micro timeframes
• Extreme volatility spikes where ATR-based references expand too quickly
• Situations where the user wants a direct buy/sell signal instead of a planning map


🎛️ Key Inputs

• Setup Side → selects automatic, long-side, or short-side lifecycle tracking.

• Trigger Model → controls how the setup moves into TRIGGERED state.

• Setup Lookback → defines the forming range used for trigger and invalidation mapping.

• Sensitivity → changes how strict the lifecycle detection and confirmation logic feels.

• Expiry Bars → controls how long an untriggered setup can stay active.

• Minimum Quality Score → defines the threshold for stronger lifecycle contexts.

• Panel / Label Settings → control panel position, theme, font size, label size, and label density.


🖥️ Interface & Visual Design

The interface is built around a single chart-first lifecycle window.

The panel is intentionally compact. It does not replace the chart; it summarizes the active state so the user can quickly read the setup stage, score, time risk, invalidation, and next context action.

Labels are kept moderate and offset away from candles to preserve readability.


🧪 Practical Usage Workflow

1. Read the panel stage.
2. Check the lifecycle window between trigger and invalidation.
3. Watch whether the setup moves from FORMING to ARMED.
4. Review the trigger rail and invalidation rail.
5. Use the expiry marker to avoid stale setup interpretation.
6. Confirm the broader market context before making any decision.


🔍 Interpretation Guidelines

A high lifecycle score means the current setup context is cleaner according to the script's rule set.

An ARMED state means the setup is close to the trigger area, not that a trade must be taken.

An EXPIRED state means time quality has degraded.

An INVALIDATED state means the tracked setup lost its mapped risk reference.


🚫 What This Script Is NOT

• Not a prediction engine
• Not financial advice
• Not an auto-trading tool
• Not a guaranteed signal system
• Not a generic support/resistance mapper
• Not a clone of Setup Quality Scorecard


⚠️ Limitations & Transparency

Lifecycle windows depend on lookback, ATR behavior, and recent structure.

Different timeframes can produce different setup stages.

High-volatility conditions may expand rails and change score behavior.

Low-liquidity symbols can create unstable ranges and misleading candle structure.


🧠 Market Context Notes

Setup lifecycle quality is strongest when structure, volatility, and timing align.

A setup can be technically visible but still weak if it is too old, too far from the trigger rail, too close to invalidation, or unsupported by confirmation behavior.


🧾 Use Case Examples

When price compresses below a range edge and the lifecycle window turns ARMED, the trader can observe whether the trigger rail is reached before the expiry marker.

When a setup remains FORMING for too long, the time risk row helps identify whether the context is becoming stale.

When price crosses the invalidation rail, the script marks the lifecycle as INVALIDATED so the previous setup is no longer treated as active.


🧱 System Philosophy

AGPro tools are designed to help traders read market context with structure and restraint.

Setup Lifecycle Tracker follows that philosophy by converting setup timing into a visible planning workflow instead of adding another isolated signal marker.


🔐 Non-Promise Statement

No script can provide certainty.

No score, state, label, or alert guarantees future price behavior.


📉 Risk Disclosure

Trading involves risk.

This script is for educational and analytical use only.

It does not provide financial advice, investment advice, or guaranteed trading outcomes.

Users remain responsible for their own decisions, risk management, and position sizing.


📚 Educational Note

The main educational purpose of this script is to help users think in lifecycle stages: setup formation, activation risk, invalidation, time decay, and context review.

## Source Code

````pine
// -------------------------------------------------
// Setup Lifecycle Tracker [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Setup Lifecycle Tracker is a chart-first workflow planner that follows a
// setup through forming, armed, active, review, invalidated, and expired stages.
// It maps a lifecycle window, trigger rail, invalidation rail, expiry marker,
// time risk, setup quality, next-action context, and a confirmation-anchored
// proof layer (Follow, Hold, React, Flip rates) so traders can evaluate whether
// a setup still deserves attention without turning the script into a signal
// printer, scorecard clone, or generic support/resistance map.
// -------------------------------------------------

//@version=6
indicator("Setup Lifecycle Tracker [AGPro Series]",
     shorttitle       = "AG Pro SLT",
     overlay          = true,
     max_labels_count = 130,
     max_boxes_count  = 30,
     max_lines_count  = 50)

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
dangerColor   = color.rgb(239, 68, 68)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
ttPreset = "Selects the operating profile. Balanced Lifecycle is the publication default. Cleaner Swing reduces lifecycle and label density. Active Intraday reacts faster. Custom uses the raw inputs below."
ttSide = "Selects the setup direction used by the lifecycle tracker. Auto reads trend context, while manual modes force long-side or short-side setup tracking."
ttTriggerModel = "Selects how a tracked setup moves from ARMED to ACTIVE. Structure Break uses the trigger rail, Trend Reclaim uses the trend EMA plus the trigger area, and Impulse Release requires a stronger directional candle."
ttLookback = "Lookback used to define the forming setup range, trigger rail, and invalidation rail. Higher values create slower but broader lifecycle windows."
ttAtr = "ATR length used to normalize setup width, trigger distance, invalidation distance, label offset, expiry window size, and score components."
ttFast = "Fast EMA used for automatic setup side and confirmation strength. It does not create standalone buy or sell signals."
ttSlow = "Slow EMA used as the trend backbone for setup direction, confirmation strength, and context scoring."
ttVolume = "Volume baseline used to estimate confirmation support. Symbols without reliable volume data fall back to a neutral reading."
ttConfirm = "Close Confirmed waits for the bar to close before state changes, labels, and alerts are printed. Live Updating can react before the candle is closed."
ttSensitivity = "Controls how strict the lifecycle model is. Early accepts wider forming ranges and quicker arming. Strict requires cleaner compression and confirmation."
ttExpiry = "Maximum number of bars a setup can remain untriggered before it becomes EXPIRED. This keeps old setups from staying visually active forever."
ttPostTrigger = "Number of bars to keep tracking an active setup before the lifecycle enters review or expires if invalidation has not occurred."
ttMaturity = "Bar age where the setup maturity component is considered most balanced. Too early is immature, while too late increases time risk."
ttTriggerBuffer = "ATR buffer added beyond the forming range to create the trigger rail. This reduces noise around the range edge."
ttInvalidBuffer = "ATR buffer added beyond the opposite side of the forming range to create the invalidation rail."
ttRangeWidth = "Maximum ATR-normalized forming range width accepted by the tracker. Wider ranges are ignored because the setup is not clean enough for lifecycle planning."
ttArmedDistance = "ATR-normalized distance to the trigger rail required before a forming setup can become ARMED."
ttMinScore = "Minimum 0-100 score used to classify a setup as high-quality and to allow ARMED state under the default model."
ttRestart = "Minimum bars between a terminal lifecycle state and the next newly tracked setup. This prevents rapid object churn."
ttWindow = "Shows the main lifecycle window between trigger and invalidation. Its centered badge is the primary chart-first workflow visual."
ttGuides = "Shows trigger and invalidation rails for the active lifecycle window."
ttGuideTags = "Shows compact right-side trigger and invalidation tags using solid label boxes for readability."
ttTagOffset = "Horizontal offset for right-side rail tags. Increase it if the tags sit too close to the projected lifecycle window."
ttExpiryMarker = "Shows a vertical expiry marker at the lifecycle deadline."
ttMemory = "Keeps a limited number of previous lifecycle windows as soft chart memory after a new setup starts."
ttForward = "Number of bars the active lifecycle window and guide rails project to the right for readability."
ttTint = "Applies a subtle stage color tint to active lifecycle candles. Disabled by default for cleaner publication screenshots."
ttLabels = "Shows compact FORMING, ARMED, ACTIVE, REVIEW, INVALIDATED, and EXPIRED labels. Labels are offset away from candles."
ttExpiredLabels = "Shows EXPIRED labels when lifecycle windows time out. Disabled by default because expiry can be frequent on lower timeframes and should not dominate the chart."
ttContextLabels = "Adds sparse state labels during an active lifecycle. Disabled by default to avoid label crowding."
ttLabelMode = "Compact keeps chart labels short for publication screenshots. Detailed adds age, trigger, and invalidation context."
ttCooldown = "Minimum bars between event labels. Critical state changes can still appear immediately."
ttContextSpacing = "Minimum bars between sparse context labels during an active lifecycle."
ttMaxLabels = "Maximum number of labels retained on chart. Older labels are removed first to preserve performance."
ttOffset = "ATR-based vertical label offset used to keep labels above or below candles."
ttLabelScore = "Adds the 0-100 lifecycle score to chart labels."
ttLabelSize = "Font size for all chart labels and lifecycle window labels. Normal is the recommended publication default."
ttPanel = "Shows or hides the AG Pro lifecycle panel. The panel is visible by default for public-release readability."
ttShowProof = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across past triggered setups on the current symbol and timeframe. These are historical outcome rates, not predictions."
ttProofHorizon = "Number of bars each triggered setup is tracked forward to measure whether it followed through in the setup direction before the invalidation rail was breached."
ttProofFollow = "Favorable distance, in ATR from the trigger close, that counts as a follow-through (Follow)."
ttReactBars = "Number of bars after a trigger used to detect an immediate favorable reaction."
ttReactProgress = "Minimum favorable progress toward the follow-through distance, within the reaction window, required to count as an early React."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Lifecycle Engine"
enginePreset = input.string("Balanced Lifecycle", "Engine Preset", options = ["Balanced Lifecycle", "Cleaner Swing", "Active Intraday", "Custom"], group = groupEngine, tooltip = ttPreset)
sideMode = input.string("Auto", "Setup Side", options = ["Auto", "Long Setup", "Short Setup"], group = groupEngine, tooltip = ttSide)
triggerModel = input.string("Structure Break", "Trigger Model", options = ["Structure Break", "Trend Reclaim", "Impulse Release"], group = groupEngine, tooltip = ttTriggerModel)
setupLookback = input.int(34, "Setup Lookback", minval = 8, maxval = 220, group = groupEngine, tooltip = ttLookback)
atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = ttAtr)
fastEmaLen = input.int(21, "Fast Context EMA", minval = 2, maxval = 200, group = groupEngine, tooltip = ttFast)
slowEmaLen = input.int(55, "Slow Context EMA", minval = 5, maxval = 300, group = groupEngine, tooltip = ttSlow)
volumeLen = input.int(20, "Volume Baseline", minval = 5, maxval = 160, group = groupEngine, tooltip = ttVolume)
confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = ttConfirm)

groupScoring = "Lifecycle Scoring"
sensitivityInput = input.string("Balanced", "Sensitivity", options = ["Early", "Balanced", "Strict"], group = groupScoring, tooltip = ttSensitivity)
expiryBars = input.int(56, "Untriggered Expiry Bars", minval = 8, maxval = 180, group = groupScoring, tooltip = ttExpiry)
postTriggerBars = input.int(42, "Post-Trigger Tracking Bars", minval = 8, maxval = 180, group = groupScoring, tooltip = ttPostTrigger)
idealMaturityBars = input.int(18, "Ideal Maturity Bars", minval = 3, maxval = 120, group = groupScoring, tooltip = ttMaturity)
triggerBufferAtr = input.float(0.16, "Trigger Buffer ATR", minval = 0.00, maxval = 2.00, step = 0.01, group = groupScoring, tooltip = ttTriggerBuffer)
invalidationBufferAtr = input.float(0.28, "Invalidation Buffer ATR", minval = 0.00, maxval = 3.00, step = 0.01, group = groupScoring, tooltip = ttInvalidBuffer)
maxFormationWidthAtr = input.float(5.80, "Max Formation Width ATR", minval = 0.50, maxval = 12.00, step = 0.10, group = groupScoring, tooltip = ttRangeWidth)
armedDistanceAtr = input.float(1.05, "Armed Distance ATR", minval = 0.05, maxval = 4.00, step = 0.01, group = groupScoring, tooltip = ttArmedDistance)
minimumQualityScore = input.int(56, "Minimum Quality Score", minval = 20, maxval = 95, group = groupScoring, tooltip = ttMinScore)
restartCooldownBars = input.int(18, "Restart Cooldown Bars", minval = 0, maxval = 100, group = groupScoring, tooltip = ttRestart)

groupVisual = "Chart Visuals"
showLifecycleWindow = input.bool(true, "Show Lifecycle Window", group = groupVisual, tooltip = ttWindow)
showGuideLines = input.bool(true, "Show Trigger / Invalidation Rails", group = groupVisual, tooltip = ttGuides)
showGuideTags = input.bool(true, "Show Guide Tags", group = groupVisual, tooltip = ttGuideTags)
rightTagOffsetBars = input.int(6, "Right Tag Offset Bars", minval = 1, maxval = 40, group = groupVisual, tooltip = ttTagOffset)
showExpiryMarker = input.bool(true, "Show Expiry Marker", group = groupVisual, tooltip = ttExpiryMarker)
showMemoryWindows = input.bool(true, "Show Prior Lifecycle Windows", group = groupVisual, tooltip = ttMemory)
maxMemoryWindows = input.int(2, "Max Prior Windows", minval = 0, maxval = 12, group = groupVisual, tooltip = ttMemory)
forwardBars = input.int(28, "Forward Render Bars", minval = 4, maxval = 160, group = groupVisual, tooltip = ttForward)
showStageTint = input.bool(false, "Tint Active Stage Bars", group = groupVisual, tooltip = ttTint)

groupLabels = "Labels"
showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
showExpiredLabels = input.bool(false, "Show Expired Labels", group = groupLabels, tooltip = ttExpiredLabels)
showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContextLabels)
labelTextMode = input.string("Compact", "Label Text Mode", options = ["Compact", "Detailed"], group = groupLabels, tooltip = ttLabelMode)
labelCooldownBars = input.int(24, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
contextSpacingBars = input.int(72, "Context Label Spacing", minval = 8, maxval = 220, group = groupLabels, tooltip = ttContextSpacing)
maxVisibleLabels = input.int(6, "Max Visible Labels", minval = 3, maxval = 80, group = groupLabels, tooltip = ttMaxLabels)
labelOffsetAtr = input.float(0.95, "Label Offset ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupLabels, tooltip = ttOffset)
showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttLabelScore)
labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttPanel)
panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = "Moves the panel to the preferred chart location.")
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = "Switches the panel between AG Pro dark and clean light themes.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = "Font size for the AG Pro panel. Normal is the recommended publication default.")

groupProof = "Proof"
showProof = input.bool(true, "Show Proof Layer", group = groupProof, tooltip = ttShowProof)
proofHorizonBars = input.int(30, "Proof Horizon Bars", minval = 5, maxval = 240, group = groupProof, tooltip = ttProofHorizon)
proofFollowAtr = input.float(1.50, "Proof Follow-Through ATR", minval = 0.30, maxval = 10.00, step = 0.05, group = groupProof, tooltip = ttProofFollow)
reactBars = input.int(4, "Reaction Window Bars", minval = 1, maxval = 60, group = groupProof, tooltip = ttReactBars)
reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = groupProof, tooltip = ttReactProgress)

groupAlerts = "Alerts"
alertLifecycleStates = input.bool(true, "Alert on Lifecycle States", group = groupAlerts,
     tooltip = "Enables alerts for forming, armed, active, review, invalidated, expired, and high-quality lifecycle states.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_norm_high_good(float value, float weak, float strong) =>
    span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float good, float bad) =>
    span = bad - good
    span == 0.0 ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    value <= idealValue ? f_norm_high_good(value, lowValue, idealValue) : f_norm_low_good(value, idealValue, highValue)

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

f_panel_bg(bool isLight, bool alt) =>
    isLight ? (alt ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)) : (alt ? color.rgb(19, 29, 48) : panelBg)

f_panel_border(bool isLight) =>
    isLight ? color.rgb(203, 213, 225) : panelBorder

f_panel_label(bool isLight) =>
    isLight ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(bool isLight) =>
    isLight ? color.rgb(15, 23, 42) : panelValueCol

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(float value) =>
    value >= 55 ? bullColor : value >= 40 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30 ? bullColor : value <= 55 ? neutralColor : bearColor

f_stage_color(string stageText) =>
    switch stageText
        "FORMING" => accentColor
        "ARMED" => neutralColor
        "ACTIVE" => bullColor
        "REVIEW" => accentColor
        "INVALIDATED" => dangerColor
        "EXPIRED" => bearColor
        => panelLabelCol

f_score_color(int scoreValue, int threshold) =>
    scoreValue >= 78 ? bullColor : scoreValue >= threshold ? accentColor : scoreValue >= 45 ? neutralColor : bearColor

f_time_color(int riskValue) =>
    riskValue >= 74 ? bearColor : riskValue >= 48 ? neutralColor : bullColor

f_grade(int scoreValue) =>
    scoreValue >= 86 ? "A+" : scoreValue >= 76 ? "A" : scoreValue >= 64 ? "B" : scoreValue >= 48 ? "C" : "D"

f_price(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_stage_short(string stageText) =>
    switch stageText
        "FORMING" => "FORM"
        "ARMED" => "ARMED"
        "ACTIVE" => "ACTIVE"
        "REVIEW" => "REVIEW"
        "INVALIDATED" => "INVALID"
        "EXPIRED" => "EXPIRED"
        => "SCAN"

f_action(string stageText, int scoreValue, int threshold, int timeRiskValue) =>
    result = "Wait For Setup"
    if stageText == "FORMING"
        result := scoreValue >= threshold ? "Watch Maturity" : "Wait Cleaner Setup"
    else if stageText == "ARMED"
        result := timeRiskValue >= 70 ? "Review Time Risk" : "Monitor Trigger Rail"
    else if stageText == "ACTIVE"
        result := "Track Lifecycle"
    else if stageText == "REVIEW"
        result := "Review Time / Risk"
    else if stageText == "INVALIDATED"
        result := "Reset Setup"
    else if stageText == "EXPIRED"
        result := "Wait New Lifecycle"
    result

f_best_view_text() =>
    timeframe.isintraday ? "15m / 1H / 4H" : "4H / 1D / 1W"

f_set_row(table target, int row, string leftText, string rightText, color rightColor, bool isLight, bool altRow, string fontSize) =>
    rowBg = f_panel_bg(isLight, altRow)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(isLight), bgcolor = rowBg, text_size = f_text_size(fontSize))
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_right)

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        oldLabel = array.shift(labels)
        label.delete(oldLabel)

f_trim_boxes(array<box> boxes, int maxCount) =>
    while array.size(boxes) > maxCount
        oldBox = array.shift(boxes)
        box.delete(oldBox)

f_clear_boxes(array<box> boxes) =>
    while array.size(boxes) > 0
        oldBox = array.shift(boxes)
        box.delete(oldBox)

f_delete_label(label item) =>
    if not na(item)
        label.delete(item)

f_label_text(string codeText, string detailText, int scoreValue) =>
    scoreText = showLabelScore ? str.tostring(scoreValue) : ""
    labelTextMode == "Compact" ? (showLabelScore ? codeText + " " + scoreText : codeText) : (showLabelScore ? codeText + "\n" + detailText + "\nScore " + scoreText : codeText + "\n" + detailText)

f_add_label(array<label> labels, string textValue, float labelY, int dirValue, color labelColor, string tipText, int limit) =>
    newLabel = label.new(x = bar_index,
         y = labelY,
         text = textValue,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = dirValue == 1 ? label.style_label_up : label.style_label_down,
         textcolor = headerText,
         color = color.new(labelColor, 0),
         size = f_text_size(labelFontSize),
         tooltip = tipText,
         textalign = text.align_center)
    array.push(labels, newLabel)
    f_trim_labels(labels, limit)

// -------------------------------------------------
// Presets
// -------------------------------------------------
cleanerPreset = enginePreset == "Cleaner Swing"
activePreset = enginePreset == "Active Intraday"
customPreset = enginePreset == "Custom"

usedMaxLabels = customPreset ? maxVisibleLabels : cleanerPreset ? math.min(maxVisibleLabels, 5) : activePreset ? math.min(maxVisibleLabels, 8) : math.min(maxVisibleLabels, 6)
usedMemoryWindows = customPreset ? maxMemoryWindows : cleanerPreset ? math.min(maxMemoryWindows, 1) : activePreset ? math.min(maxMemoryWindows, 3) : maxMemoryWindows

usedLabelCooldown = customPreset ? labelCooldownBars : cleanerPreset ? math.max(labelCooldownBars, 32) : activePreset ? math.min(labelCooldownBars, 12) : labelCooldownBars
usedContextSpacing = customPreset ? contextSpacingBars : cleanerPreset ? math.max(contextSpacingBars, 96) : activePreset ? math.min(contextSpacingBars, 42) : contextSpacingBars
usedRestartCooldown = customPreset ? restartCooldownBars : cleanerPreset ? math.max(restartCooldownBars, 26) : activePreset ? math.min(restartCooldownBars, 8) : restartCooldownBars
usedMinimumQuality = customPreset ? minimumQualityScore : cleanerPreset ? math.max(minimumQualityScore, 62) : activePreset ? math.max(minimumQualityScore - 4, 20) : minimumQualityScore

usedExpiryBars = customPreset ? expiryBars : cleanerPreset ? math.max(expiryBars, 64) : activePreset ? math.min(expiryBars, 40) : expiryBars
usedPostTriggerBars = customPreset ? postTriggerBars : cleanerPreset ? math.max(postTriggerBars, 48) : activePreset ? math.min(postTriggerBars, 28) : postTriggerBars
usedForwardBars = customPreset ? forwardBars : cleanerPreset ? math.max(forwardBars, 32) : activePreset ? math.min(forwardBars, 22) : forwardBars

effectiveIdealMaturityBars = math.max(1, math.min(idealMaturityBars, usedExpiryBars - 1))
effectiveReactBars = math.min(reactBars, math.max(proofHorizonBars - 1, 1))

// -------------------------------------------------
// Core measurements
// -------------------------------------------------
confirmedBar = confirmationMode == "Close Confirmed" ? barstate.isconfirmed : true
proofConfirmedBar = barstate.isconfirmed
engineWarmup = math.max(math.max(setupLookback, slowEmaLen), math.max(volumeLen, atrLen)) + atrLen + 5
engineReady = bar_index > engineWarmup

sensitivityFactor = sensitivityInput == "Early" ? 0.86 : sensitivityInput == "Strict" ? 1.18 : 1.0
rangeWidthFactor = sensitivityInput == "Early" ? 1.18 : sensitivityInput == "Strict" ? 0.84 : 1.0
bodyRequirementAtr = sensitivityInput == "Early" ? 0.18 : sensitivityInput == "Strict" ? 0.42 : 0.28

atr = ta.atr(atrLen)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
fastEma = ta.ema(close, fastEmaLen)
slowEma = ta.ema(close, slowEmaLen)
slowSlope = slowEma - nz(slowEma[5], slowEma)
volumeAverage = ta.sma(nz(volume, 0.0), volumeLen)
volumeRatio = volumeAverage > 0.0 ? nz(volume, 0.0) / volumeAverage : 1.0
volumeScoreSource = na(volume) or volumeAverage <= 0.0 ? 1.0 : volumeRatio

barRange = math.max(high - low, syminfo.mintick)
bodySize = math.abs(close - open)
bodyAtr = bodySize / safeAtr
bullCloseLocation = (close - low) / barRange
bearCloseLocation = (high - close) / barRange

priorHigh = ta.highest(high, setupLookback)[1]
priorLow = ta.lowest(low, setupLookback)[1]
rangeDefined = not na(priorHigh) and not na(priorLow) and priorHigh > priorLow
rangeWidthAtr = rangeDefined ? (priorHigh - priorLow) / safeAtr : na
contextDir = sideMode == "Long Setup" ? 1 : sideMode == "Short Setup" ? -1 : fastEma >= slowEma and close >= slowEma ? 1 : -1

trendReady = contextDir == 1 ? close >= slowEma or fastEma > slowEma : close <= slowEma or fastEma < slowEma
insideRange = rangeDefined and close <= priorHigh + safeAtr * triggerBufferAtr and close >= priorLow - safeAtr * triggerBufferAtr
compressionReady = rangeDefined and rangeWidthAtr <= maxFormationWidthAtr * rangeWidthFactor
formationRaw = compressionReady and insideRange and trendReady

// -------------------------------------------------
// Persistent lifecycle state
// -------------------------------------------------
var bool hasSetup = false
var int setupDir = 0
var int setupStartBar = na
var int setupTriggerBar = na
var int terminalBar = na
var float setupTrigger = na
var float setupInvalidation = na
var float setupTop = na
var float setupBottom = na
var string lifecycleStage = "SCAN"

var box lifecycleBox = na
var label lifecycleBoxLabel = na
var line triggerLine = na
var line invalidationLine = na
var line expiryLine = na
var label triggerTag = na
var label invalidationTag = na
var array<box> memoryBoxes = array.new_box()
var array<label> eventLabels = array.new_label()
var int lastEventLabelBar = na
var int lastContextLabelBar = na
var int previousLifecycleScore = na

// -------------------------------------------------
// New lifecycle detection
// -------------------------------------------------
stageBefore = lifecycleStage
terminalStage = lifecycleStage == "INVALIDATED" or lifecycleStage == "EXPIRED"
readyForNewSetup = not hasSetup or (terminalStage and not na(terminalBar) and bar_index - terminalBar >= usedRestartCooldown)
newSetupEvent = false

if readyForNewSetup and formationRaw and confirmedBar and engineReady
    if not na(lifecycleBox)
        box.set_bgcolor(lifecycleBox, color.new(f_stage_color(lifecycleStage), 94))
        box.set_border_color(lifecycleBox, color.new(f_stage_color(lifecycleStage), 72))
        if showMemoryWindows and usedMemoryWindows > 0
            array.push(memoryBoxes, lifecycleBox)
            f_trim_boxes(memoryBoxes, usedMemoryWindows)
        else
            box.delete(lifecycleBox)
        lifecycleBox := na
    f_delete_label(lifecycleBoxLabel)
    lifecycleBoxLabel := na
    if not na(triggerLine)
        line.delete(triggerLine)
        triggerLine := na
    if not na(invalidationLine)
        line.delete(invalidationLine)
        invalidationLine := na
    if not na(expiryLine)
        line.delete(expiryLine)
        expiryLine := na
    f_delete_label(triggerTag)
    f_delete_label(invalidationTag)
    triggerTag := na
    invalidationTag := na

    setupDir := contextDir
    setupStartBar := bar_index
    setupTriggerBar := na
    terminalBar := na
    setupTrigger := setupDir == 1 ? priorHigh + safeAtr * triggerBufferAtr : priorLow - safeAtr * triggerBufferAtr
    setupInvalidation := setupDir == 1 ? priorLow - safeAtr * invalidationBufferAtr : priorHigh + safeAtr * invalidationBufferAtr
    setupTop := math.max(setupTrigger, setupInvalidation)
    setupBottom := math.min(setupTrigger, setupInvalidation)
    lifecycleStage := "FORMING"
    hasSetup := true
    newSetupEvent := true

if not showMemoryWindows
    f_clear_boxes(memoryBoxes)
else
    f_trim_boxes(memoryBoxes, usedMemoryWindows)

// -------------------------------------------------
// Lifecycle scoring
// -------------------------------------------------
ageBars = hasSetup and not na(setupStartBar) ? bar_index - setupStartBar : 0
barsAfterTrigger = hasSetup and not na(setupTriggerBar) ? bar_index - setupTriggerBar : 0
activeDeadline = hasSetup and not na(setupTriggerBar) ? usedPostTriggerBars : usedExpiryBars
timeRisk = hasSetup ? int(math.round(f_clamp(float(not na(setupTriggerBar) ? barsAfterTrigger : ageBars) / math.max(float(activeDeadline), 1.0) * 100.0, 0.0, 100.0))) : 0

triggerDistanceAtr = 0.0
if hasSetup
    triggerDistanceAtr := setupDir == 1 ? math.max((setupTrigger - close) / safeAtr, 0.0) : math.max((close - setupTrigger) / safeAtr, 0.0)

invalidationDistanceAtr = 0.0
if hasSetup
    invalidationDistanceAtr := setupDir == 1 ? math.max((close - setupInvalidation) / safeAtr, 0.0) : math.max((setupInvalidation - close) / safeAtr, 0.0)

maturityScore = hasSetup ? f_peak_score(float(ageBars), 0.0, float(effectiveIdealMaturityBars), float(usedExpiryBars)) : 0.0
triggerProximityScore = hasSetup ? f_norm_low_good(triggerDistanceAtr, 0.0, math.max(armedDistanceAtr * 2.2, 0.10)) : 0.0
timeDecayScore = hasSetup ? f_norm_low_good(float(not na(setupTriggerBar) ? barsAfterTrigger : ageBars), 0.0, float(activeDeadline)) : 0.0
invalidationFitScore = hasSetup ? f_peak_score(invalidationDistanceAtr, 0.35 * sensitivityFactor, 1.70 * sensitivityFactor, 4.80 * sensitivityFactor) : 0.0

directionalCloseScore = hasSetup ? setupDir == 1 ? f_norm_high_good(bullCloseLocation, 0.45, 0.82) : f_norm_high_good(bearCloseLocation, 0.45, 0.82) : 0.0
bodyScore = f_norm_high_good(bodyAtr, 0.05, bodyRequirementAtr)
trendScore = hasSetup ? setupDir == 1 ? (fastEma >= slowEma ? 78.0 : 45.0) + f_clamp(slowSlope / safeAtr * 65.0, -22.0, 22.0) : (fastEma <= slowEma ? 78.0 : 45.0) + f_clamp(-slowSlope / safeAtr * 65.0, -22.0, 22.0) : 0.0
volumeScore = f_norm_high_good(volumeScoreSource, 0.65, 1.30)
confirmationScore = f_clamp(directionalCloseScore * 0.34 + bodyScore * 0.24 + trendScore * 0.27 + volumeScore * 0.15, 0.0, 100.0)

rawLifecycleScore = maturityScore * 0.20 + triggerProximityScore * 0.20 + confirmationScore * 0.25 + timeDecayScore * 0.15 + invalidationFitScore * 0.20
lifecycleScore = int(math.round(f_clamp(rawLifecycleScore, 0.0, 100.0)))

// -------------------------------------------------
// Stage transitions
// -------------------------------------------------
structureBreak = hasSetup and (setupDir == 1 ? close > setupTrigger : close < setupTrigger)
trendReclaim = hasSetup and (setupDir == 1 ? close > fastEma and close > setupTrigger - safeAtr * 0.20 and close[1] <= fastEma[1] : close < fastEma and close < setupTrigger + safeAtr * 0.20 and close[1] >= fastEma[1])
impulseRelease = hasSetup and structureBreak and bodyAtr >= bodyRequirementAtr and (setupDir == 1 ? close > open and bullCloseLocation >= 0.62 : close < open and bearCloseLocation >= 0.62)
triggerRaw = triggerModel == "Trend Reclaim" ? trendReclaim : triggerModel == "Impulse Release" ? impulseRelease : structureBreak
triggerEvent = hasSetup and confirmedBar and na(setupTriggerBar) and triggerRaw
invalidationEvent = hasSetup and confirmedBar and lifecycleStage != "INVALIDATED" and lifecycleStage != "EXPIRED" and (setupDir == 1 ? close < setupInvalidation : close > setupInvalidation)
hardLifecycleExpiry = hasSetup and ageBars >= usedExpiryBars + usedPostTriggerBars + 5
expiryEvent = hasSetup and confirmedBar and lifecycleStage != "INVALIDATED" and lifecycleStage != "EXPIRED" and ((na(setupTriggerBar) and ageBars >= usedExpiryBars) or (not na(setupTriggerBar) and barsAfterTrigger >= usedPostTriggerBars) or hardLifecycleExpiry)
reviewEvent = hasSetup and confirmedBar and not na(setupTriggerBar) and timeRisk >= 68 and lifecycleStage != "REVIEW"

if hasSetup
    if invalidationEvent
        lifecycleStage := "INVALIDATED"
        terminalBar := bar_index
        lifecycleScore := math.min(lifecycleScore, 28)
    else if triggerEvent
        setupTriggerBar := bar_index
        lifecycleStage := "ACTIVE"
    else if expiryEvent
        lifecycleStage := "EXPIRED"
        terminalBar := bar_index
        lifecycleScore := math.min(lifecycleScore, 42)
    else if not na(setupTriggerBar) and timeRisk >= 68
        lifecycleStage := "REVIEW"
    else if not na(setupTriggerBar)
        lifecycleStage := "ACTIVE"
    else if triggerDistanceAtr <= armedDistanceAtr and lifecycleScore >= usedMinimumQuality
        lifecycleStage := "ARMED"
    else
        lifecycleStage := "FORMING"

stageChanged = lifecycleStage != stageBefore
armedEvent = stageChanged and lifecycleStage == "ARMED"
activeEvent = stageChanged and lifecycleStage == "ACTIVE"
highQualityEvent = confirmedBar and hasSetup and (lifecycleStage == "ARMED" or lifecycleStage == "ACTIVE") and lifecycleScore >= usedMinimumQuality and nz(previousLifecycleScore, 0) < usedMinimumQuality

if hasSetup and lifecycleStage != "INVALIDATED" and lifecycleStage != "EXPIRED"
    overdueTriggered = not na(setupTriggerBar) and barsAfterTrigger > usedPostTriggerBars
    overdueUntriggered = na(setupTriggerBar) and ageBars > usedExpiryBars
    if overdueTriggered or overdueUntriggered or hardLifecycleExpiry
        lifecycleStage := "EXPIRED"
        terminalBar := bar_index
        lifecycleScore := math.min(lifecycleScore, 42)

terminalHoldBars = math.max(usedRestartCooldown, 12)
staleTerminal = hasSetup and (lifecycleStage == "INVALIDATED" or lifecycleStage == "EXPIRED") and not na(terminalBar) and bar_index - terminalBar > terminalHoldBars
staleAncientSetup = hasSetup and ageBars > usedExpiryBars + usedPostTriggerBars + terminalHoldBars
if staleTerminal or staleAncientSetup
    hasSetup := false
    setupDir := 0
    setupStartBar := na
    setupTriggerBar := na
    terminalBar := na
    setupTrigger := na
    setupInvalidation := na
    setupTop := na
    setupBottom := na
    lifecycleStage := "SCAN"

// -------------------------------------------------
// Confirmation-anchored proof (trigger follow-through)
// -------------------------------------------------
var int proofTotal = 0
var int proofFollow = 0
var int proofHold = 0
var int proofReact = 0
var int proofFlip = 0
var int proofAmbiguous = 0
var bool pEvalActive = false
var int pEvalDir = 0
var int pEvalStart = na
var float pEvalEntry = na
var float pEvalStop = na
var float pEvalTarget = na
var bool pReacted = false
var bool pFollowed = false

if proofConfirmedBar and engineReady
    if pEvalActive
        int heldBars = bar_index - pEvalStart
        float followDist = math.max(math.abs(pEvalTarget - pEvalEntry), syminfo.mintick)
        float favorableExcursion = pEvalDir == 1 ? high - pEvalEntry : pEvalEntry - low
        bool targetTouched = heldBars >= 1 and favorableExcursion >= followDist
        bool stopTouched = pEvalDir == 1 ? low <= pEvalStop : high >= pEvalStop
        bool ambiguousNow = targetTouched and stopTouched

        if heldBars >= 1 and heldBars <= effectiveReactBars and favorableExcursion >= followDist * reactProgressPct / 100.0
            pReacted := true
        if targetTouched and not stopTouched
            pFollowed := true

        bool horizonDone = heldBars >= proofHorizonBars
        bool lifecycleExpired = expiryEvent
        bool resolveNow = ambiguousNow or targetTouched or stopTouched or horizonDone or lifecycleExpired

        if resolveNow
            if ambiguousNow
                proofAmbiguous := proofAmbiguous + 1
            else
                proofTotal := proofTotal + 1
                if pFollowed
                    proofFollow := proofFollow + 1
                if not stopTouched
                    proofHold := proofHold + 1
                if pReacted
                    proofReact := proofReact + 1
                if stopTouched
                    proofFlip := proofFlip + 1
            pEvalActive := false

    // Each confirmed trigger opens exactly one Proof evaluation.
    if triggerEvent and not pEvalActive
        pEvalActive := true
        pEvalDir := setupDir
        pEvalEntry := close
        pEvalStop := setupInvalidation
        pEvalTarget := close + setupDir * safeAtr * proofFollowAtr
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

// -------------------------------------------------
// Visual rendering
// -------------------------------------------------
stageColor = f_stage_color(lifecycleStage)
rightEdge = bar_index + usedForwardBars
triggerTagX = rightEdge + rightTagOffsetBars
invalidationTagX = triggerTagX + 3
minObjectLeftBar = bar_index - 9000
renderStartBar = hasSetup ? math.max(setupStartBar, minObjectLeftBar) : na
deadlineBar = hasSetup ? setupStartBar + (not na(setupTriggerBar) ? usedPostTriggerBars + math.max(setupTriggerBar - setupStartBar, 0) : usedExpiryBars) : na
renderDeadlineBar = hasSetup and not na(deadlineBar) ? math.max(deadlineBar, minObjectLeftBar) : na
boxMid = hasSetup ? (setupTop + setupBottom) * 0.50 : na
minBoxHeight = safeAtr * 0.80
boxTop = hasSetup ? math.max(setupTop, boxMid + minBoxHeight * 0.50) : na
boxBottom = hasSetup ? math.min(setupBottom, boxMid - minBoxHeight * 0.50) : na
dirText = setupDir == 1 ? "LONG" : "SHORT"
scoreText = str.tostring(lifecycleScore) + "/100"
boxText = lifecycleStage + "\nQ " + str.tostring(lifecycleScore)
boxLabelX = bar_index + int(math.round(usedForwardBars * 0.50))

if showLifecycleWindow and hasSetup
    if na(lifecycleBox)
        lifecycleBox := box.new(left = renderStartBar, top = boxTop, right = rightEdge, bottom = boxBottom, xloc = xloc.bar_index, bgcolor = color.new(stageColor, 90), border_color = color.new(stageColor, 30), border_width = lifecycleStage == "ACTIVE" or lifecycleStage == "REVIEW" ? 2 : 1)
    else
        box.set_left(lifecycleBox, renderStartBar)
        box.set_right(lifecycleBox, rightEdge)
        box.set_top(lifecycleBox, boxTop)
        box.set_bottom(lifecycleBox, boxBottom)
        box.set_bgcolor(lifecycleBox, color.new(stageColor, 90))
        box.set_border_color(lifecycleBox, color.new(stageColor, 30))
        box.set_border_width(lifecycleBox, lifecycleStage == "ACTIVE" or lifecycleStage == "REVIEW" ? 2 : 1)
    if na(lifecycleBoxLabel)
        lifecycleBoxLabel := label.new(boxLabelX, boxMid, boxText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(stageColor, 0), textcolor = headerText, size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_x(lifecycleBoxLabel, boxLabelX)
        label.set_y(lifecycleBoxLabel, boxMid)
        label.set_text(lifecycleBoxLabel, boxText)
        label.set_color(lifecycleBoxLabel, color.new(stageColor, 0))
        label.set_textcolor(lifecycleBoxLabel, headerText)
        label.set_size(lifecycleBoxLabel, f_text_size(labelFontSize))
        label.set_textalign(lifecycleBoxLabel, text.align_center)
else
    if not na(lifecycleBox)
        box.delete(lifecycleBox)
        lifecycleBox := na
    f_delete_label(lifecycleBoxLabel)
    lifecycleBoxLabel := na

if showGuideLines and hasSetup
    if na(triggerLine)
        triggerLine := line.new(x1 = renderStartBar, y1 = setupTrigger, x2 = triggerTagX, y2 = setupTrigger, xloc = xloc.bar_index, color = color.new(accentColor, 10), width = 1, style = line.style_dashed)
    else
        line.set_xy1(triggerLine, renderStartBar, setupTrigger)
        line.set_xy2(triggerLine, triggerTagX, setupTrigger)
        line.set_color(triggerLine, color.new(accentColor, 10))

    if na(invalidationLine)
        invalidationLine := line.new(x1 = renderStartBar, y1 = setupInvalidation, x2 = invalidationTagX, y2 = setupInvalidation, xloc = xloc.bar_index, color = color.new(dangerColor, 8), width = 1, style = line.style_solid)
    else
        line.set_xy1(invalidationLine, renderStartBar, setupInvalidation)
        line.set_xy2(invalidationLine, invalidationTagX, setupInvalidation)
        line.set_color(invalidationLine, color.new(dangerColor, 8))
    if showGuideTags
        triggerText = "Trigger\n" + f_price(setupTrigger)
        invalidText = "Invalidation\n" + f_price(setupInvalidation)
        if na(triggerTag)
            triggerTag := label.new(triggerTagX, setupTrigger, triggerText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 0), textcolor = headerText, size = f_text_size(labelFontSize), textalign = text.align_center)
        else
            label.set_xy(triggerTag, triggerTagX, setupTrigger)
            label.set_text(triggerTag, triggerText)
            label.set_color(triggerTag, color.new(accentColor, 0))
            label.set_textcolor(triggerTag, headerText)
            label.set_size(triggerTag, f_text_size(labelFontSize))
        if na(invalidationTag)
            invalidationTag := label.new(invalidationTagX, setupInvalidation, invalidText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(dangerColor, 0), textcolor = headerText, size = f_text_size(labelFontSize), textalign = text.align_center)
        else
            label.set_xy(invalidationTag, invalidationTagX, setupInvalidation)
            label.set_text(invalidationTag, invalidText)
            label.set_color(invalidationTag, color.new(dangerColor, 0))
            label.set_textcolor(invalidationTag, headerText)
            label.set_size(invalidationTag, f_text_size(labelFontSize))
    else
        f_delete_label(triggerTag)
        f_delete_label(invalidationTag)
        triggerTag := na
        invalidationTag := na
else
    if not na(triggerLine)
        line.delete(triggerLine)
        triggerLine := na
    if not na(invalidationLine)
        line.delete(invalidationLine)
        invalidationLine := na
    f_delete_label(triggerTag)
    f_delete_label(invalidationTag)
    triggerTag := na
    invalidationTag := na

if showExpiryMarker and hasSetup and not na(renderDeadlineBar)
    if na(expiryLine)
        expiryLine := line.new(x1 = renderDeadlineBar, y1 = boxTop, x2 = renderDeadlineBar, y2 = boxBottom, xloc = xloc.bar_index, color = color.new(neutralColor, 18), width = 1, style = line.style_dotted)
    else
        line.set_xy1(expiryLine, renderDeadlineBar, boxTop)
        line.set_xy2(expiryLine, renderDeadlineBar, boxBottom)
        line.set_color(expiryLine, color.new(neutralColor, 18))
else if not na(expiryLine)
    line.delete(expiryLine)
    expiryLine := na

barcolor(showStageTint and hasSetup ? color.new(stageColor, 68) : na)

// -------------------------------------------------
// Labels
// -------------------------------------------------
eventLabelDue = showEventLabels and hasSetup and confirmedBar and (newSetupEvent or stageChanged)
terminalLabelEvent = invalidationEvent or expiryEvent
criticalLabelEvent = newSetupEvent or triggerEvent or invalidationEvent or expiryEvent
requiredEventSpacing = math.max(1, int(math.round(usedLabelCooldown * 0.50)))
expiredLabelBlocked = lifecycleStage == "EXPIRED" and not showExpiredLabels
eventLabelAllowed = eventLabelDue and not expiredLabelBlocked and (criticalLabelEvent or na(lastEventLabelBar) or bar_index - lastEventLabelBar >= requiredEventSpacing)

if eventLabelAllowed
    labelY = setupDir == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    detailText = dirText + " | Age " + str.tostring(ageBars) + "/" + str.tostring(activeDeadline) + " | Invalid " + f_price(setupInvalidation)
    labelText = f_label_text(f_stage_short(lifecycleStage), detailText, lifecycleScore)
    labelTip = "Setup Lifecycle Tracker stage: " + lifecycleStage + ". Score " + scoreText + ". Alerts are attention markers, not trade instructions."
    f_add_label(eventLabels, labelText, labelY, setupDir, stageColor, labelTip, usedMaxLabels)
    lastEventLabelBar := bar_index

contextDue = showContextLabels and hasSetup and confirmedBar and not stageChanged and lifecycleStage != "INVALIDATED" and lifecycleStage != "EXPIRED" and (na(lastContextLabelBar) or bar_index - lastContextLabelBar >= usedContextSpacing)
if contextDue
    labelY = setupDir == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    contextDetail = dirText + " | Time risk " + str.tostring(timeRisk) + "% | Trigger " + f_price(setupTrigger)
    contextText = f_label_text(f_stage_short(lifecycleStage), contextDetail, lifecycleScore)
    contextTip = "Sparse lifecycle context label. It summarizes the active setup stage without issuing a trade instruction."
    f_add_label(eventLabels, contextText, labelY, setupDir, stageColor, contextTip, usedMaxLabels)
    lastContextLabelBar := bar_index

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelIsLight = panelThemeInput == "Light"
panelFrame = f_panel_border(panelIsLight)
panelFont = panelFontSizeInput
stageRead = hasSetup ? lifecycleStage + " | " + dirText : "SCANNING"
qualityRead = hasSetup ? scoreText + " | " + f_grade(lifecycleScore) : "n/a"
timeRiskRead = hasSetup ? str.tostring(timeRisk) + "% | " + (timeRisk >= 74 ? "HIGH" : timeRisk >= 48 ? "MEDIUM" : "LOW") : "n/a"
triggerRead = hasSetup ? f_price(setupTrigger) : "n/a"
invalidationRead = hasSetup ? f_price(setupInvalidation) : "n/a"
ageRead = hasSetup ? str.tostring(ageBars) + " / " + str.tostring(activeDeadline) + " bars" : "n/a"
actionRead = hasSetup ? f_action(lifecycleStage, lifecycleScore, usedMinimumQuality, timeRisk) : "Wait For Setup"
bestViewText = f_best_view_text()

proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) + (proofAmbiguous > 0 ? " | x = " + str.tostring(proofAmbiguous) : "") : proofAmbiguous > 0 ? "x = " + str.tostring(proofAmbiguous) : "building"
followText = proofTotal > 0 ? f_pct(followRate) : "-"
holdText = proofTotal > 0 ? f_pct(holdRate) : "-"
reactText = proofTotal > 0 ? f_pct(reactRate) : "-"
flipText = proofTotal > 0 ? f_pct(flipRate) : "-"
followCol = proofTotal > 0 ? f_rate_color(followRate) : f_panel_value(panelIsLight)
holdCol = proofTotal > 0 ? f_rate_color(holdRate) : f_panel_value(panelIsLight)
reactCol = proofTotal > 0 ? f_rate_color(reactRate) : f_panel_value(panelIsLight)
flipCol = proofTotal > 0 ? f_flip_color(flipRate) : f_panel_value(panelIsLight)

int panelRowCount = showProof ? 14 : 9

var table panel = table.new(position.top_right, 2, panelRowCount, bgcolor = panelBg, frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)

if barstate.islast
    table.set_position(panel, f_panel_position(panelLocationInput))
    table.set_frame_color(panel, panelFrame)
    table.set_border_color(panel, panelFrame)
    if showPanel
        table.clear(panel, 0, 0, 1, panelRowCount - 1)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Setup Lifecycle Tracker", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFont), text_halign = text.align_center)
        f_set_row(panel, 1, "Workflow Stage", stageRead, f_stage_color(lifecycleStage), panelIsLight, false, panelFont)
        f_set_row(panel, 2, "Setup Quality", qualityRead, f_score_color(lifecycleScore, usedMinimumQuality), panelIsLight, true, panelFont)
        f_set_row(panel, 3, "Time Risk", timeRiskRead, f_time_color(timeRisk), panelIsLight, false, panelFont)
        f_set_row(panel, 4, "Trigger Rail", triggerRead, accentColor, panelIsLight, true, panelFont)
        f_set_row(panel, 5, "Invalidation", invalidationRead, lifecycleStage == "INVALIDATED" ? dangerColor : neutralColor, panelIsLight, false, panelFont)
        f_set_row(panel, 6, "Lifecycle Age", ageRead, panelValueCol, panelIsLight, true, panelFont)
        f_set_row(panel, 7, "Next Action", actionRead, f_stage_color(lifecycleStage), panelIsLight, false, panelFont)
        f_set_row(panel, 8, "Best View", bestViewText, accentColor, panelIsLight, true, panelFont)
        if showProof
            color proofHeadBg = f_panel_bg(panelIsLight, false)
            table.cell(panel, 0, 9, "Proof @ Confirm", text_color = accentColor, bgcolor = proofHeadBg, text_size = f_text_size(panelFont), text_halign = text.align_left)
            table.cell(panel, 1, 9, proofSampleText, text_color = f_panel_label(panelIsLight), bgcolor = proofHeadBg, text_size = f_text_size(panelFont), text_halign = text.align_right)
            f_set_row(panel, 10, "Follow Rate", followText, followCol, panelIsLight, true, panelFont)
            f_set_row(panel, 11, "Hold Rate", holdText, holdCol, panelIsLight, false, panelFont)
            f_set_row(panel, 12, "React Rate", reactText, reactCol, panelIsLight, true, panelFont)
            f_set_row(panel, 13, "Flip Rate", flipText, flipCol, panelIsLight, false, panelFont)
    else
        table.clear(panel, 0, 0, 1, panelRowCount - 1)

// -------------------------------------------------
// Alerts And Hidden Exports
// -------------------------------------------------
alertcondition(alertLifecycleStates and newSetupEvent, title = "Setup Lifecycle Forming", message = "Setup Lifecycle Tracker: a new lifecycle window is forming. This is an attention marker, not a trade instruction.")
alertcondition(alertLifecycleStates and armedEvent, title = "Setup Lifecycle Armed", message = "Setup Lifecycle Tracker: the tracked setup is armed near the trigger rail. This is an attention marker, not a trade instruction.")
alertcondition(alertLifecycleStates and activeEvent, title = "Setup Lifecycle Active", message = "Setup Lifecycle Tracker: the tracked setup moved into ACTIVE state. Review the lifecycle context.")
alertcondition(alertLifecycleStates and reviewEvent, title = "Setup Lifecycle Review", message = "Setup Lifecycle Tracker: the active lifecycle moved into REVIEW state because time risk is elevated.")
alertcondition(alertLifecycleStates and invalidationEvent, title = "Setup Lifecycle Invalidated", message = "Setup Lifecycle Tracker: the tracked setup crossed its invalidation rail.")
alertcondition(alertLifecycleStates and expiryEvent, title = "Setup Lifecycle Expired", message = "Setup Lifecycle Tracker: the tracked setup reached its lifecycle expiry window.")
alertcondition(alertLifecycleStates and highQualityEvent, title = "High-Quality Lifecycle Context", message = "Setup Lifecycle Tracker: lifecycle score crossed the configured quality threshold.")

plot(lifecycleScore, title = "SLT Lifecycle Score", display = display.none)
plot(timeRisk, title = "SLT Time Risk", display = display.none)
plot(triggerDistanceAtr, title = "SLT Trigger Distance ATR", display = display.none)
plot(followRate, title = "SLT Follow Rate", display = display.none)
plot(holdRate, title = "SLT Hold Rate", display = display.none)
plot(reactRate, title = "SLT React Rate", display = display.none)
plot(flipRate, title = "SLT Flip Rate", display = display.none)
plot(proofAmbiguous, title = "SLT Ambiguous Proof Count", display = display.none)
plot(invalidationDistanceAtr, title = "SLT Invalidation Distance ATR", display = display.none)
plot(setupDir, title = "SLT Setup Direction", display = display.none)
plot(hasSetup ? ageBars : na, title = "SLT Lifecycle Age", display = display.none)
plot(hasSetup ? barsAfterTrigger : na, title = "SLT Bars After Trigger", display = display.none)

if confirmedBar
    previousLifecycleScore := lifecycleScore
````

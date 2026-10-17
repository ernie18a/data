# Trailing Stop Quality [AGPro Series]

- url: https://www.tradingview.com/script/LdT7mCkG-Trailing-Stop-Quality-AGPro-Series/
- type: indicator
- pine_id: PUB;320fb151ade849eaae7373027f8923a8
- version: 7.0

## Description

Trailing Stop Quality [AGPro Series]

🧠 Core Idea

Is the current trailing reference defending the move cleanly, or is it creating noise that deserves a risk review?


📌 Overview / What it does

Trailing Stop Quality [AGPro Series] is a trade-management planner built for traders who want more context around active trailing stops, defense rails, and risk-shift conditions.

The script compares a swing defense rail with a volatility defense rail, evaluates trend-defense quality, measures pullback depth, checks volatility expansion, and converts the result into a 0-100 trailing stop quality score.

It produces trail rails, a centered risk-shift zone, a target-room guide, compact state labels, alerts, and a clean AGPro panel. It does not predict price direction, automate trading, or tell users what to buy or sell.


🎯 Purpose & Design Philosophy

Many trailing stop tools show a stop line, but they do not explain whether the current trail is structurally clean, too close to noise, too loose, or in conflict with another management reference.

This script was built to fill that gap.

It helps traders who already have a move in progress and want to evaluate whether the active trail is still defending the move with enough quality to keep monitoring.

The design philosophy is simple: manage context before reacting to the line.


⚡ Why This Script Is Different

Most tools focus on plotting a trailing stop line, flipping side, or marking stop transitions.

This script does NOT clone a Chandelier Exit flip-zone tool, does not act as a stop-loss optimizer, and does not print direct trade commands.

Instead, it scores the quality of the current trail using swing defense, volatility defense, trend slope, pullback depth, volatility expansion, and rail conflict. The result is a management-readiness layer, not another raw stop signal.


⚙️ Methodology

1. Context Detection
The script reads the active management side automatically or lets the user force long-side or short-side evaluation.

2. Reference Mapping
It maps two trail references: a swing defense rail and a volatility defense rail. The tighter reference becomes the active defense rail.

3. Reaction Evaluation
It scores whether the active trail is balanced, too near, too loose, conflicted, or already broken.

4. Visual Output
It displays the active defense rail, swing rail, volatility rail, risk-shift zone, target guide, compact labels, alerts, and AGPro panel state.


🗺️ How to Read the Chart

Zones = the risk-shift zone shows the gap between the swing defense rail and volatility defense rail. Its centered label summarizes the active conflict or quiet state.

Labels = labels mark TRAIL HOLDS, RISK SHIFT, MONITOR, NOISE, ROOM LIMITED, or DEFENSE LOST contexts.

Colors = green highlights clean defense, pink highlights lost defense, amber highlights risk review, and indigo highlights monitor context.

Panel = the panel summarizes Trail Quality, Stop Distance, Trend Defense, Risk Shift, and Action.


🚦 Signals & States

• TRAIL HOLDS → the active trail is defending cleanly with enough score and no major risk-shift conflict.

• RISK SHIFT → price is close to the active rail or swing and volatility rails disagree enough to deserve review.

• MONITOR → trail quality is acceptable but not strong enough for a clean defense state.

• NOISE → the current trail reference is low quality or too unstable.

• ROOM LIMITED → forward room is limited relative to the active trail risk.

• DEFENSE LOST → price crossed the active defense rail and the current trail context should be reviewed.


🔔 Alerts Logic

Alerts trigger when the script detects a clean trail-hold state, risk-shift state, monitor state, noisy trail state, defense-loss event, or limited target-room condition.

Alerts are attention markers only.

They are not trade instructions and should be interpreted within broader market context.


🧩 Confluence Logic

The strongest context appears when swing defense and volatility defense are aligned, the active trail distance is balanced, trend slope supports the management side, pullback depth is controlled, and volatility is expanding without becoming chaotic.

When those conditions align, the 0-100 trail quality score improves.


📊 When to Use

• During active trend-following management

• After a move has already started and trailing references matter

• When comparing swing-based trail behavior with volatility-based defense

• During pullbacks where the trail may be too close to price

• When evaluating whether a move still has reasonable room before the next structure edge


⚠️ When NOT to Use

• Very low-liquidity symbols with erratic wick behavior

• Extremely noisy chop where no stable management side exists

• Event-driven spikes where volatility changes too quickly

• Charts where the user wants entry signals instead of trail-quality context


🎛️ Key Inputs

• Management Side → controls Auto, Long Management, or Short Management mode.

• Swing Trail Lookback → controls the structural defense rail.

• Volatility Rail Multiple → controls the ATR-based volatility defense rail.

• Sensitivity → adjusts how strict the trail-quality scoring model is.

• Minimum Clean Score → defines when the trail can qualify as a clean defense state.

• Target Guide R Multiple → sets the forward planning reference used for target-room context.

• Visual settings → control rails, risk-shift zone, target guide, labels, panel location, panel theme, and font sizes.


🖥️ Interface & Visual Design

The interface is intentionally chart-first.

The rails show the actual management references, the zone shows swing-versus-volatility conflict, and the panel gives a fast decision read without turning the script into a crowded dashboard.

The AGPro panel uses a single merged blue header row and keeps the key state visible at a glance.


🧪 Practical Usage Workflow

1. Read the panel Trail Quality state.

2. Check whether the active defense rail is still below price in long management or above price in short management.

3. Review the risk-shift zone to see whether swing and volatility references agree.

4. Check whether the target guide still has reasonable forward room.

5. Use the label state as an attention marker, then confirm with broader structure and market context.


🔍 Interpretation Guidelines

Think of the output as trail-quality context, not a trade signal.

A high score means the active trail is better aligned with structure, volatility, trend defense, and pullback depth.

A low score means the current trailing reference may be too noisy, too close, too loose, or already losing defensive value.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not auto trading

• Not guaranteed signals

• Not a Chandelier Exit clone

• Not a stop-loss optimizer

• Not a buy or sell signal tool


⚠️ Limitations & Transparency

Trailing stop quality can change quickly when volatility expands, contracts, or when price moves into noisy pullback conditions.

Different timeframes may produce different trail rails and score behavior.

Fast markets, low liquidity, and abnormal wick behavior can reduce the usefulness of any rule-based trail-quality model.


🧠 Market Context Notes

Trail quality is not only about distance from price.

It also depends on whether structure is still defending the move, whether volatility is stable enough to support the rail, and whether the next target area leaves enough room relative to current trail risk.


🧾 Use Case Examples

When price trends higher and both swing defense and volatility defense remain below price with a strong score, the script may mark TRAIL HOLDS.

When price compresses toward the active trail or swing and volatility rails separate too much, the script may mark RISK SHIFT.

When price crosses the active defense rail, the script may mark DEFENSE LOST so the user can review the management context.


🧱 System Philosophy

Trailing Stop Quality belongs to the AGPro planner-style family: tools designed to help traders evaluate context before decisions, rather than simply adding another signal to the chart.


🔐 Non-Promise Statement

No output from this script guarantees a result.

No score represents certainty.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions, position sizing, and risk management.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

The goal is to make trailing stop context easier to inspect by separating clean defense, risk shift, noisy trails, limited room, and lost defense states.

## Source Code

````pine
// -------------------------------------------------
// Trailing Stop Quality [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.0.2
//
// Trailing Stop Quality is a trade-management planner that evaluates whether
// the current trailing reference is defending the move cleanly or creating
// noise. It compares swing defense, volatility defense, trail distance,
// pullback depth, risk-shift pressure, invalidation, and target-room context
// through a chart-first overlay and compact AG Pro review dashboard, and adds a
// confirmation-anchored proof layer (Follow, Hold, React, Flip rates) that shows
// how past defended trail contexts resolved on the current symbol.
// -------------------------------------------------

//@version=6
indicator("Trailing Stop Quality [AGPro Series]",
     shorttitle       = "AG Pro TSQ",
     overlay          = true,
     max_labels_count = 120,
     max_boxes_count  = 20,
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

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
ttPreset = "Selects the operating profile. Balanced Trail is the publication default. Cleaner Swing reduces label density. Active Intraday reacts faster. Custom uses the raw input values."
ttSide = "Selects the management side. Auto reads trend context and keeps the active side focused on the current move. Manual modes force long-side or short-side trail management."
ttConfirm = "When enabled, labels, alerts, and state transitions are confirmed only after the bar closes. This keeps public chart behavior stable."
ttSwing = "Lookback used to build the swing defense rail. The rail tracks recent higher lows in long context and recent lower highs in short context."
ttAtrLen = "ATR length used to normalize trail distance, volatility expansion, label offsets, defense zones, and target guides."
ttAtrBase = "Longer ATR baseline used to classify whether volatility is compressed, normal, expanding, or too hot."
ttVolMult = "Distance multiplier used for the volatility defense rail. It is built from the trend backbone and ATR, not from a Chandelier high/low anchor."
ttTrend = "EMA backbone used to determine management side, trend defense, slope quality, and the volatility rail."
ttFast = "Fast EMA used only for automatic context reading. It does not create entry signals."
ttSlope = "Number of bars used to evaluate whether the trend backbone is defending the current side."
ttPullback = "Lookback used to measure how deep the current pullback is from the recent move extreme."
ttTargetLookback = "Lookback used to detect whether the nearest recent structure edge leaves enough room beyond the current trail risk."
ttSensitivity = "Controls how strict the trail-quality model is. Conservative requires cleaner distance and trend defense. Aggressive accepts earlier management context."
ttMinScore = "Minimum 0-100 score required before the script can classify the trail as a clean defense state."
ttWatchScore = "Minimum 0-100 score required for MONITOR state. Below this level, the trailing reference is treated as noisy."
ttMinTrail = "Minimum acceptable ATR-normalized distance from the active trail. Below this value, normal noise can pressure the trail."
ttIdealTrail = "Preferred ATR-normalized trail distance. Scores are strongest around this balanced defense area."
ttMaxTrail = "Maximum acceptable ATR-normalized distance from the active trail. Above this value, the active trail can be too loose."
ttConflict = "Swing and volatility rail separation that marks a risk-shift conflict. Higher values make the conflict marker less sensitive."
ttNear = "ATR-normalized distance where price is considered close enough to the active rail to deserve risk review."
ttTarget = "R multiple used for the forward target guide. It is a planning reference only and not a price prediction."
ttRail = "Shows the active defense rail selected from the tighter of the swing rail and volatility rail."
ttSwingRail = "Shows the swing defense rail used by the quality model."
ttVolRail = "Shows the volatility defense rail used by the quality model."
ttZone = "Shows the risk-shift zone between swing defense and volatility defense. The label is centered inside the zone."
ttTargetGuide = "Shows a forward target-room guide based on the current active trail risk. It is a planning reference, not an outcome forecast."
ttLiveTags = "Shows a single compact right-side workflow review tag connected to the active defense rail. Quality, distance, and target-room readings stay in the panel."
ttProjection = "Number of bars projected to the right for the risk-shift zone and target guide."
ttLabels = "Shows compact TRAIL HOLDS, RISK SHIFT, MONITOR, NOISE, and DEFENSE LOST labels. Labels are offset away from candles."
ttContext = "Adds sparse context labels even when the state does not change. Disabled by default for cleaner public screenshots."
ttRoomLabels = "Shows optional target-room labels when forward room is limited relative to the current active trail risk. Disabled by default for a cleaner public view."
ttMarkers = "Shows small state markers on event bars. Disabled by default because compact labels already carry the main visual story."
ttCooldown = "Minimum bars between chart labels. Higher values reduce label density."
ttContextSpacing = "Minimum bars between sparse context labels during ongoing trail management."
ttMaxLabels = "Maximum number of chart labels retained. Older labels are removed first to preserve performance."
ttLabelOffset = "ATR-based vertical offset that keeps labels above or below candles."
ttLabelScore = "Adds the 0-100 trail-quality score to chart labels."
ttLabelSize = "Font size for all chart labels and zone text. Normal is the recommended publication default."
ttShowPanel = "Shows or hides the AG Pro management panel. It is shown by default for public-release readability."
ttShowProof = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across sequential, non-overlapping evaluation windows in the active management direction while the trail remains defended. These are historical outcome rates, not predictions."
ttProofHorizon = "Number of bars each constructive trail state is tracked forward to measure whether the move continued before the defended rail was breached."
ttProofFollow = "Favorable distance, in ATR from the call's close, that counts as a follow-through (Follow)."
ttReactBars = "Number of bars after a constructive trail state used to detect an immediate favorable reaction."
ttReactProgress = "Minimum favorable progress toward the follow-through distance, within the reaction window, required to count as an early React."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Trail Quality Engine"
enginePreset = input.string("Balanced Trail", "Engine Preset", options = ["Balanced Trail", "Cleaner Swing", "Active Intraday", "Custom"], group = groupEngine, tooltip = ttPreset)
sideMode = input.string("Auto", "Management Side", options = ["Auto", "Long Management", "Short Management"], group = groupEngine, tooltip = ttSide)
confirmOnClose = input.bool(true, "Confirm On Bar Close", group = groupEngine, tooltip = ttConfirm)
swingLookback = input.int(21, "Swing Trail Lookback", minval = 5, maxval = 160, group = groupEngine, tooltip = ttSwing)
atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = ttAtrLen)
atrBaseLen = input.int(55, "ATR Context Baseline", minval = 10, maxval = 300, group = groupEngine, tooltip = ttAtrBase)
volatilityRailMult = input.float(2.10, "Volatility Rail Multiple", minval = 0.50, maxval = 8.00, step = 0.05, group = groupEngine, tooltip = ttVolMult)
fastEmaLen = input.int(21, "Fast Context EMA", minval = 1, maxval = 200, group = groupEngine, tooltip = ttFast)
trendEmaLen = input.int(55, "Trend Backbone EMA", minval = 2, maxval = 300, group = groupEngine, tooltip = ttTrend)
slopeBars = input.int(5, "Trend Slope Bars", minval = 1, maxval = 30, group = groupEngine, tooltip = ttSlope)
pullbackLookback = input.int(34, "Pullback Depth Lookback", minval = 8, maxval = 220, group = groupEngine, tooltip = ttPullback)
targetLookback = input.int(72, "Target Room Lookback", minval = 12, maxval = 300, group = groupEngine, tooltip = ttTargetLookback)

groupScoring = "Trail Quality Scoring"
sensitivityInput = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = groupScoring, tooltip = ttSensitivity)
minimumQualityScore = input.int(68, "Minimum Clean Score", minval = 35, maxval = 95, group = groupScoring, tooltip = ttMinScore)
watchQualityScore = input.int(52, "Monitor Score", minval = 20, maxval = 90, group = groupScoring, tooltip = ttWatchScore)
minTrailAtr = input.float(0.42, "Minimum Trail Distance ATR", minval = 0.05, maxval = 4.00, step = 0.01, group = groupScoring, tooltip = ttMinTrail)
idealTrailAtr = input.float(1.20, "Ideal Trail Distance ATR", minval = 0.10, maxval = 8.00, step = 0.05, group = groupScoring, tooltip = ttIdealTrail)
maxTrailAtr = input.float(2.80, "Maximum Trail Distance ATR", minval = 0.30, maxval = 12.00, step = 0.05, group = groupScoring, tooltip = ttMaxTrail)
conflictAtr = input.float(0.82, "Rail Conflict ATR", minval = 0.10, maxval = 5.00, step = 0.01, group = groupScoring, tooltip = ttConflict)
nearRailAtr = input.float(0.58, "Risk Shift Distance ATR", minval = 0.05, maxval = 4.00, step = 0.01, group = groupScoring, tooltip = ttNear)
targetMultiple = input.float(2.00, "Target Guide R Multiple", minval = 0.50, maxval = 6.00, step = 0.25, group = groupScoring, tooltip = ttTarget)

groupVisual = "Chart Visuals"
showActiveRail = input.bool(true, "Show Active Defense Rail", group = groupVisual, tooltip = ttRail)
showSwingRail = input.bool(true, "Show Swing Rail", group = groupVisual, tooltip = ttSwingRail)
showVolatilityRail = input.bool(true, "Show Volatility Rail", group = groupVisual, tooltip = ttVolRail)
showRiskShiftZone = input.bool(true, "Show Risk Shift Zone", group = groupVisual, tooltip = ttZone)
riskZoneTransparency = input.int(91, "Risk Zone Transparency", minval = 76, maxval = 96, group = groupVisual, tooltip = "Transparency used by the risk-shift zone. Higher values make wide conflict zones lighter while preserving the rail context.")
showTargetGuide = input.bool(true, "Show Target Guide", group = groupVisual, tooltip = ttTargetGuide)
showLiveReviewTags = input.bool(true, "Show Live Review Tags", group = groupVisual, tooltip = ttLiveTags)
liveTagOffsetBars = input.int(18, "Live Tag Offset Bars", minval = 4, maxval = 60, group = groupVisual, tooltip = "Horizontal offset for the live review tags. Increase it if tags overlap the price scale or risk-shift zone.")
projectionBars = input.int(42, "Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = ttProjection)

groupLabels = "Labels"
showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContext)
showRoomLabels = input.bool(false, "Show Room Labels", group = groupLabels, tooltip = ttRoomLabels)
showStateMarkers = input.bool(false, "Show State Markers", group = groupLabels, tooltip = ttMarkers)
labelCooldownBars = input.int(22, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
contextSpacingBars = input.int(72, "Context Label Spacing", minval = 10, maxval = 240, group = groupLabels, tooltip = ttContextSpacing)
maxVisibleLabels = input.int(5, "Max Visible Labels", minval = 3, maxval = 80, group = groupLabels, tooltip = ttMaxLabels)
labelOffsetAtr = input.float(1.08, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttLabelScore)
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = "Moves the panel to the preferred chart location.")
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = "Switches the panel between AG Pro dark and clean light themes.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = "Font size for the AG Pro panel. Normal is the recommended publication default.")

groupProof = "Proof"
showProof = input.bool(true, "Show Proof Layer", group = groupProof, tooltip = ttShowProof)
proofHorizonBars = input.int(24, "Proof Horizon Bars", minval = 5, maxval = 240, group = groupProof, tooltip = ttProofHorizon)
proofFollowAtr = input.float(1.50, "Proof Follow-Through ATR", minval = 0.30, maxval = 10.00, step = 0.05, group = groupProof, tooltip = ttProofFollow)
reactBars = input.int(4, "Reaction Window Bars", minval = 1, maxval = 60, group = groupProof, tooltip = ttReactBars)
reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = groupProof, tooltip = ttReactProgress)

groupAlerts = "Alerts"
alertTrailStates = input.bool(true, "Alert on Trail States", group = groupAlerts,
     tooltip = "Enables alerts for trail holds, risk shift, monitor, noise, and defense lost states.")
alertRoomWarnings = input.bool(true, "Alert on Target Room Limited", group = groupAlerts,
     tooltip = "Enables alerts when forward room is limited relative to current active trail risk.")

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

f_trail_fit(float distanceAtr, float minAtr, float idealAtr, float maxAtr) =>
    result = 0.0
    if distanceAtr <= 0.0
        result := 0.0
    else if distanceAtr < minAtr
        result := f_clamp(distanceAtr / math.max(minAtr, 0.01) * 58.0, 0.0, 58.0)
    else if distanceAtr <= idealAtr
        result := 58.0 + f_clamp((distanceAtr - minAtr) / math.max(idealAtr - minAtr, 0.01) * 42.0, 0.0, 42.0)
    else if distanceAtr <= maxAtr
        result := 100.0 - f_clamp((distanceAtr - idealAtr) / math.max(maxAtr - idealAtr, 0.01) * 44.0, 0.0, 44.0)
    else
        result := f_clamp(56.0 - (distanceAtr - maxAtr) / math.max(maxAtr, 0.01) * 56.0, 0.0, 56.0)
    result

f_label_size(string sizeText) =>
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

f_score_color(int score) =>
    score >= 78 ? bullColor : score >= 62 ? accentColor : score >= 48 ? neutralColor : bearColor

f_state_color(string stateText) =>
    switch stateText
        "TRAIL HOLDS" => bullColor
        "RISK SHIFT" => neutralColor
        "MONITOR" => accentColor
        "NOISE" => neutralColor
        "DEFENSE LOST" => bearColor
        => panelLabelCol

f_workflow_text(string stateText) =>
    switch stateText
        "TRAIL HOLDS" => "Review Hold"
        "RISK SHIFT" => "Check Shift"
        "MONITOR" => "Track Trail"
        "DEFENSE LOST" => "Reset Trail"
        "NOISE" => "Wait Cleaner"
        => "Wait Cleaner"

f_zone_state(string stateText) =>
    switch stateText
        "TRAIL HOLDS" => "Hold"
        "RISK SHIFT" => "Shift"
        "MONITOR" => "Track"
        "DEFENSE LOST" => "Lost"
        "NOISE" => "Noise"
        => "Wait"

f_titlecase(string stateText) =>
    switch stateText
        "TRAIL HOLDS" => "Trail Holds"
        "RISK SHIFT" => "Risk Shift"
        "MONITOR" => "Monitor"
        "NOISE" => "Noise"
        "DEFENSE LOST" => "Defense Lost"
        => stateText

f_text_on(color bgColor) =>
    bright = (color.r(bgColor) * 299 + color.g(bgColor) * 587 + color.b(bgColor) * 114) / 1000
    bright >= 145 ? color.rgb(15, 23, 42) : color.rgb(248, 250, 252)

f_best_view_text() =>
    timeframe.isintraday ? "1H / 4H / 1D" : timeframe.isdaily ? "Daily Chart" : "4H / 1D"

f_set_row(table target, int row, string leftText, string rightText, color rightColor, bool isLight, bool altRow, string fontSize) =>
    rowBg = f_panel_bg(isLight, altRow)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(isLight), bgcolor = rowBg, text_size = f_label_size(fontSize))
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_label_size(fontSize), text_halign = text.align_right)

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        oldLabel = array.shift(labels)
        label.delete(oldLabel)

// -------------------------------------------------
// Presets
// -------------------------------------------------
cleanerPreset = enginePreset == "Cleaner Swing"
activePreset = enginePreset == "Active Intraday"
usedLabelCooldown = cleanerPreset ? math.max(labelCooldownBars, 30) : activePreset ? math.min(labelCooldownBars, 12) : labelCooldownBars
usedContextSpacing = cleanerPreset ? math.max(contextSpacingBars, 96) : activePreset ? math.min(contextSpacingBars, 42) : contextSpacingBars
usedMaxLabels = cleanerPreset ? math.min(maxVisibleLabels, 5) : activePreset ? math.min(maxVisibleLabels, 9) : math.min(maxVisibleLabels, 7)
usedMinimumQualityRaw = cleanerPreset ? math.max(minimumQualityScore, 72) : activePreset ? math.max(minimumQualityScore - 4, 35) : minimumQualityScore
usedWatchQualityRaw = cleanerPreset ? math.max(watchQualityScore, 56) : activePreset ? math.max(watchQualityScore - 4, 20) : watchQualityScore
usedMinimumQuality = math.max(usedMinimumQualityRaw, usedWatchQualityRaw + 1)
usedWatchQuality = math.min(usedWatchQualityRaw, usedMinimumQuality - 1)

effectiveMinTrailAtr = math.min(minTrailAtr, maxTrailAtr)
effectiveMaxTrailAtr = math.max(minTrailAtr, maxTrailAtr)
effectiveIdealTrailAtr = f_clamp(idealTrailAtr, effectiveMinTrailAtr, effectiveMaxTrailAtr)
effectiveConflictAtr = math.max(conflictAtr, 0.01)
effectiveNearRailAtr = math.max(nearRailAtr, 0.01)
effectiveReactBars = math.min(reactBars, math.max(proofHorizonBars - 1, 1))

// -------------------------------------------------
// Core measurements
// -------------------------------------------------
atr = ta.atr(atrLen)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
atrBase = ta.sma(atr, atrBaseLen)
atrRatio = not na(atrBase) and atrBase > 0.0 ? atr / atrBase : 1.0
sensitivityFactor = sensitivityInput == "Conservative" ? 1.12 : sensitivityInput == "Aggressive" ? 0.88 : 1.0

fastEma = ta.ema(close, fastEmaLen)
trendEma = ta.ema(close, trendEmaLen)
trendSlope = trendEma - nz(trendEma[slopeBars], trendEma)
slopeAtr = math.abs(trendSlope) / safeAtr

bullContext = close >= trendEma and fastEma >= trendEma
bearContext = close < trendEma and fastEma < trendEma
var int managementDir = 1
autoDir = bullContext ? 1 : bearContext ? -1 : nz(managementDir[1], close >= trendEma ? 1 : -1)
managementDir := sideMode == "Long Management" ? 1 : sideMode == "Short Management" ? -1 : autoDir

dirText = managementDir == 1 ? "Long" : "Short"
dirColor = managementDir == 1 ? bullColor : bearColor

swingRailLong = nz(ta.highest(low, swingLookback), low)
swingRailShort = nz(ta.lowest(high, swingLookback), high)
swingRail = managementDir == 1 ? swingRailLong : swingRailShort
volatilityRail = managementDir == 1 ? trendEma - safeAtr * volatilityRailMult : trendEma + safeAtr * volatilityRailMult
activeRail = managementDir == 1 ? math.max(swingRail, volatilityRail) : math.min(swingRail, volatilityRail)

swingDistanceAtr = managementDir == 1 ? (close - swingRail) / safeAtr : (swingRail - close) / safeAtr
volatilityDistanceAtr = managementDir == 1 ? (close - volatilityRail) / safeAtr : (volatilityRail - close) / safeAtr
activeDistanceRaw = managementDir == 1 ? close - activeRail : activeRail - close
activeDistanceAtr = math.max(activeDistanceRaw / safeAtr, 0.0)
railSpreadAtr = math.abs(swingRail - volatilityRail) / safeAtr

recentExtreme = managementDir == 1 ? nz(ta.highest(high, pullbackLookback), high) : nz(ta.lowest(low, pullbackLookback), low)
pullbackDepthAtr = managementDir == 1 ? math.max(recentExtreme - close, 0.0) / safeAtr : math.max(close - recentExtreme, 0.0) / safeAtr

rangeHigh = nz(ta.highest(high, targetLookback), high)
rangeLow = nz(ta.lowest(low, targetLookback), low)
roomToEdge = managementDir == 1 ? math.max(rangeHigh - close, 0.0) : math.max(close - rangeLow, 0.0)
trailRisk = math.max(math.abs(activeDistanceRaw), safeAtr * 0.10)
targetGuide = close + managementDir * trailRisk * targetMultiple
targetRoomOpen = roomToEdge >= trailRisk * targetMultiple

defenseLost = activeDistanceRaw <= 0.0
railConflict = railSpreadAtr >= effectiveConflictAtr
nearRail = not defenseLost and activeDistanceAtr <= effectiveNearRailAtr
riskShift = not defenseLost and (railConflict or nearRail)
trendAligned = managementDir == 1 ? close >= trendEma and trendSlope >= 0.0 : close <= trendEma and trendSlope <= 0.0

// -------------------------------------------------
// Quality model
// -------------------------------------------------
minTrailAdj = effectiveMinTrailAtr * sensitivityFactor
idealTrailAdj = effectiveIdealTrailAtr * sensitivityFactor
maxTrailAdj = effectiveMaxTrailAtr * sensitivityFactor
swingScore = f_trail_fit(swingDistanceAtr, minTrailAdj, idealTrailAdj, maxTrailAdj)
volatilityRailScore = f_trail_fit(volatilityDistanceAtr, minTrailAdj, idealTrailAdj, maxTrailAdj)
trendBaseScore = trendAligned ? 68.0 : (managementDir == 1 ? close >= trendEma : close <= trendEma) ? 42.0 : 10.0
trendSlopeScore = f_clamp(trendBaseScore + f_norm_high_good(slopeAtr, 0.02, 0.36) * 0.32, 0.0, 100.0)
pullbackScore = f_norm_low_good(pullbackDepthAtr, 0.20, maxTrailAdj * 1.18)
volatilityExpansionScore = f_peak_score(atrRatio, 0.68, 1.22, 2.10)
conflictScore = f_norm_low_good(railSpreadAtr, 0.08, effectiveConflictAtr * 1.85)

rawQuality = swingScore * 0.24 + volatilityRailScore * 0.22 + trendSlopeScore * 0.20 + pullbackScore * 0.14 + volatilityExpansionScore * 0.10 + conflictScore * 0.10
qualityScore = int(math.round(f_clamp(defenseLost ? math.min(rawQuality, 34.0) : rawQuality, 0.0, 100.0)))

distanceState = defenseLost ? "Broken" : activeDistanceAtr < minTrailAdj ? "Too Near" : activeDistanceAtr > maxTrailAdj ? "Too Loose" : "Balanced"
trendDefense = trendAligned ? "Defending" : managementDir == 1 ? close >= trendEma ? "Soft" : "Against" : close <= trendEma ? "Soft" : "Against"
riskShiftText = defenseLost ? "Lost" : riskShift ? railConflict ? "Conflict" : "Near Rail" : "Quiet"
targetText = targetRoomOpen ? "Room Open" : "Room Limited"

trailState = ""
if defenseLost
    trailState := "DEFENSE LOST"
else if qualityScore >= usedMinimumQuality and not riskShift
    trailState := "TRAIL HOLDS"
else if riskShift and qualityScore >= usedWatchQuality
    trailState := "RISK SHIFT"
else if qualityScore >= usedWatchQuality
    trailState := "MONITOR"
else
    trailState := "NOISE"

actionState = f_workflow_text(trailState)
stateColor = f_state_color(trailState)
confirmedBar = not confirmOnClose or barstate.isconfirmed

// -------------------------------------------------
// Visual rails
// -------------------------------------------------
plot(showSwingRail ? swingRail : na, "Swing Defense Rail", color = color.new(dirColor, 55), linewidth = 1, style = plot.style_linebr)
plot(showVolatilityRail ? volatilityRail : na, "Volatility Defense Rail", color = color.new(accentColor, 38), linewidth = 1, style = plot.style_linebr)
plot(showActiveRail ? activeRail : na, "Active Defense Rail", color = stateColor, linewidth = 2, style = plot.style_linebr)
plot(trendEma, "Trend Backbone", color = color.new(panelLabelCol, 82), linewidth = 1)

// -------------------------------------------------
// Risk shift zone and target guide
// -------------------------------------------------
rightEdge = bar_index + projectionBars
zoneLeft = bar_index - math.min(swingLookback, 30)
zoneTop = math.max(swingRail, volatilityRail)
zoneBottom = math.min(swingRail, volatilityRail)
zoneText = "Trail " + f_zone_state(trailState) + "\nScore " + str.tostring(qualityScore)
zoneColor = defenseLost ? bearColor : riskShift ? neutralColor : dirColor
zoneTextColor = f_text_on(zoneColor)
wideConflictZone = railSpreadAtr >= effectiveConflictAtr * 2.0
zoneFillAlpha = wideConflictZone ? math.max(riskZoneTransparency, 93) : trailState == "TRAIL HOLDS" ? math.min(riskZoneTransparency, 88) : riskZoneTransparency
zoneBorderAlpha = wideConflictZone ? 48 : 28
zoneMidY = (zoneTop + zoneBottom) * 0.5
zoneHeight = math.max(zoneTop - zoneBottom, syminfo.mintick)
zoneLabelHalfHeight = math.max(syminfo.mintick * 30.0, math.min(zoneHeight * 0.46, safeAtr * 0.82))
zoneLabelMidX = int(math.round((zoneLeft + rightEdge) * 0.5))
zoneLabelHalfBars = int(math.max(8.0, math.round((rightEdge - zoneLeft) * 0.20)))
zoneLabelLeft = zoneLabelMidX - zoneLabelHalfBars
zoneLabelRight = zoneLabelMidX + zoneLabelHalfBars

var box riskZone = na
var label riskZoneLabel = na
if barstate.islast and showRiskShiftZone
    if na(riskZone)
        riskZone := box.new(left = zoneLeft, top = zoneTop, right = rightEdge, bottom = zoneBottom, xloc = xloc.bar_index, bgcolor = color.new(zoneColor, zoneFillAlpha), border_color = color.new(zoneColor, zoneBorderAlpha), border_width = trailState == "TRAIL HOLDS" ? 2 : 1)
    else
        box.set_left(riskZone, zoneLeft)
        box.set_right(riskZone, rightEdge)
        box.set_top(riskZone, zoneTop)
        box.set_bottom(riskZone, zoneBottom)
        box.set_bgcolor(riskZone, color.new(zoneColor, zoneFillAlpha))
        box.set_border_color(riskZone, color.new(zoneColor, zoneBorderAlpha))
        box.set_border_width(riskZone, trailState == "TRAIL HOLDS" ? 2 : 1)
    if na(riskZoneLabel)
        riskZoneLabel := label.new(zoneLabelMidX, zoneMidY, zoneText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(zoneColor, 0), textcolor = zoneTextColor, size = f_label_size(labelSizeInput), textalign = text.align_center)
    else
        label.set_xy(riskZoneLabel, zoneLabelMidX, zoneMidY)
        label.set_text(riskZoneLabel, zoneText)
        label.set_color(riskZoneLabel, color.new(zoneColor, 0))
        label.set_textcolor(riskZoneLabel, zoneTextColor)
        label.set_size(riskZoneLabel, f_label_size(labelSizeInput))
        label.set_textalign(riskZoneLabel, text.align_center)
else
    if not na(riskZone)
        box.delete(riskZone)
        riskZone := na
    if not na(riskZoneLabel)
        label.delete(riskZoneLabel)
        riskZoneLabel := na

var line targetLine = na
var label targetLabel = na
if barstate.islast and showTargetGuide and not defenseLost
    targetColor = targetRoomOpen ? color.new(bullColor, 8) : color.new(neutralColor, 8)
    targetLabelText = str.tostring(targetMultiple, "#.##") + "R"
    if na(targetLine)
        targetLine := line.new(bar_index, targetGuide, rightEdge, targetGuide, xloc = xloc.bar_index, extend = extend.none, color = targetColor, width = 1, style = line.style_dashed)
    else
        line.set_xy1(targetLine, bar_index, targetGuide)
        line.set_xy2(targetLine, rightEdge, targetGuide)
        line.set_color(targetLine, targetColor)
    if showRoomLabels
        if na(targetLabel)
            targetLabel := label.new(rightEdge, targetGuide, targetLabelText + "\n" + targetText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(targetRoomOpen ? bullColor : neutralColor, 8), textcolor = headerText, size = f_label_size(labelSizeInput))
        else
            label.set_xy(targetLabel, rightEdge, targetGuide)
            label.set_text(targetLabel, targetLabelText + "\n" + targetText)
            label.set_color(targetLabel, color.new(targetRoomOpen ? bullColor : neutralColor, 8))
            label.set_size(targetLabel, f_label_size(labelSizeInput))
    else
        if not na(targetLabel)
            label.delete(targetLabel)
            targetLabel := na
else
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na
    if not na(targetLabel)
        label.delete(targetLabel)
        targetLabel := na

// -------------------------------------------------
// Confirmation-anchored proof (defended trail follow-through)
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
var int pLastResolveBar = na
var float pEvalEntry = na
var float pEvalStop = na
var float pEvalTarget = na
var bool pReacted = false
var bool pFollowed = false

int proofWarmup = math.max(trendEmaLen, swingLookback) + atrLen + 5
bool proofEligible = not defenseLost and trailState != "NOISE"

if confirmedBar and bar_index > proofWarmup
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
        bool directionReplaced = managementDir != pEvalDir
        bool defenseReplaced = trailState == "DEFENSE LOST"
        bool resolveNow = ambiguousNow or stopTouched or targetTouched or horizonDone or directionReplaced or defenseReplaced

        if resolveNow
            if ambiguousNow
                proofAmbiguous := proofAmbiguous + 1
            else
                proofTotal := proofTotal + 1
                if pFollowed
                    proofFollow := proofFollow + 1
                if not stopTouched and not directionReplaced and not defenseReplaced
                    proofHold := proofHold + 1
                if pReacted
                    proofReact := proofReact + 1
                if stopTouched or directionReplaced or defenseReplaced
                    proofFlip := proofFlip + 1

            pEvalActive := false
            pLastResolveBar := bar_index

    // Start sequential, non-overlapping proof windows whenever a defended
    // trail context is available. A new sample never begins on the same bar
    // that resolved the previous sample.
    bool proofRestartReady = na(pLastResolveBar) or bar_index > pLastResolveBar
    if proofEligible and not pEvalActive and proofRestartReady
        pEvalActive := true
        pEvalDir := managementDir
        pEvalEntry := close
        pEvalStop := activeRail
        pEvalTarget := close + managementDir * safeAtr * proofFollowAtr
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

// -------------------------------------------------
// Live review tags
// -------------------------------------------------
var label liveWorkflowTag = na
var line liveConnector = na

if barstate.islast
    if showLiveReviewTags
        liveTagX = bar_index + math.min(projectionBars, liveTagOffsetBars)
        tagGap = safeAtr * 0.74
        workflowY = managementDir == 1 ? math.max(zoneTop, close) + tagGap * 0.45 : math.min(zoneBottom, close) - tagGap * 0.45
        workflowText = "Workflow\n" + actionState + " | " + dirText

        if na(liveWorkflowTag)
            liveWorkflowTag := label.new(liveTagX, workflowY, workflowText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(stateColor, 0), textcolor = f_text_on(stateColor), size = f_label_size(labelSizeInput), textalign = text.align_center)
        else
            label.set_xy(liveWorkflowTag, liveTagX, workflowY)
            label.set_text(liveWorkflowTag, workflowText)
            label.set_style(liveWorkflowTag, label.style_label_center)
            label.set_color(liveWorkflowTag, color.new(stateColor, 0))
            label.set_textcolor(liveWorkflowTag, f_text_on(stateColor))
            label.set_size(liveWorkflowTag, f_label_size(labelSizeInput))
            label.set_textalign(liveWorkflowTag, text.align_center)

        if na(liveConnector)
            liveConnector := line.new(bar_index, activeRail, liveTagX, workflowY, xloc = xloc.bar_index, color = color.new(stateColor, 45), width = 1, style = line.style_dotted)
        else
            line.set_xy1(liveConnector, bar_index, activeRail)
            line.set_xy2(liveConnector, liveTagX, workflowY)
            line.set_color(liveConnector, color.new(stateColor, 45))
            line.set_style(liveConnector, line.style_dotted)
    else
        if not na(liveWorkflowTag)
            label.delete(liveWorkflowTag)
            liveWorkflowTag := na
        if not na(liveConnector)
            line.delete(liveConnector)
            liveConnector := na

// -------------------------------------------------
// Labels and markers
// -------------------------------------------------
var int lastLabelBar = na
var string labelLastTrailState = ""
var array<label> eventLabels = array.new_label()

holdsEvent = confirmedBar and trailState == "TRAIL HOLDS" and labelLastTrailState != "TRAIL HOLDS"
shiftEvent = confirmedBar and trailState == "RISK SHIFT" and labelLastTrailState != "RISK SHIFT"
monitorEvent = confirmedBar and trailState == "MONITOR" and labelLastTrailState != "MONITOR"
noiseEvent = confirmedBar and trailState == "NOISE" and labelLastTrailState != "NOISE"
lostEvent = confirmedBar and trailState == "DEFENSE LOST" and labelLastTrailState != "DEFENSE LOST"
previousTargetRoomOpen = bar_index == 0 ? true : targetRoomOpen[1]
roomLimitedEvent = confirmedBar and not targetRoomOpen and previousTargetRoomOpen
labelCooldownReady = na(lastLabelBar) or bar_index - lastLabelBar >= usedLabelCooldown
contextReady = na(lastLabelBar) or bar_index - lastLabelBar >= usedContextSpacing
drawContext = showContextLabels and contextReady and (trailState == "TRAIL HOLDS" or trailState == "RISK SHIFT" or trailState == "MONITOR")
roomLabelEvent = showRoomLabels and roomLimitedEvent
drawEventLabel = showEventLabels and labelCooldownReady and (holdsEvent or shiftEvent or monitorEvent or noiseEvent or lostEvent or roomLabelEvent or drawContext)

if drawEventLabel
    compactState = lostEvent ? "Reset Trail" : roomLabelEvent ? "Check Room" : trailState == "TRAIL HOLDS" ? "Review Hold" : trailState == "RISK SHIFT" ? "Check Shift" : trailState == "MONITOR" ? "Track Trail" : "Wait Cleaner"
    labelText = compactState
    if showLabelScore and not lostEvent
        labelText += " " + str.tostring(qualityScore)
    labelDistanceAtr = defenseLost ? math.abs(close - activeRail) / safeAtr : activeDistanceAtr
    labelText += "\n" + str.tostring(labelDistanceAtr, "#.00") + " ATR"
    labelY = managementDir == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    eventLabel = label.new(x = bar_index, y = labelY, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = managementDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(lostEvent ? bearColor : roomLabelEvent ? neutralColor : stateColor, 8), textcolor = headerText, size = f_label_size(labelSizeInput), textalign = text.align_center)
    array.push(eventLabels, eventLabel)
    f_trim_labels(eventLabels, usedMaxLabels)
    lastLabelBar := bar_index

plotshape(showStateMarkers and holdsEvent and managementDir == 1, title = "Long Trail Holds Marker", style = shape.diamond, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showStateMarkers and holdsEvent and managementDir == -1, title = "Short Trail Holds Marker", style = shape.diamond, location = location.abovebar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showStateMarkers and (shiftEvent or roomLimitedEvent), title = "Risk Shift Marker", style = shape.diamond, location = location.abovebar, color = color.new(neutralColor, 0), size = size.tiny)
plotshape(showStateMarkers and lostEvent, title = "Defense Lost Marker", style = shape.diamond, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelIsLight = panelThemeInput == "Light"
panelFrame = f_panel_border(panelIsLight)
panelSize = panelFontSizeInput
qualityRead = str.tostring(qualityScore) + " / " + f_titlecase(trailState)
distanceRead = str.tostring(activeDistanceAtr, "#.00") + " ATR / " + distanceState
defenseRead = str.tostring(activeRail, format.mintick)
shiftRead = riskShiftText + " / " + str.tostring(railSpreadAtr, "#.00") + " ATR"
targetRead = str.tostring(targetMultiple, "#.##") + "R / " + targetText
workflowRead = actionState + " | " + dirText
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

int panelRowCount = showProof ? 13 : 8

var table panel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""
var string lastPanelSize = ""
var bool lastProofMode = false

panelNeedsReset = showPanel and (na(panel) or panelLocationInput != lastPanelLocation or panelThemeInput != lastPanelTheme or panelFontSizeInput != lastPanelSize or showProof != lastProofMode)
if panelNeedsReset
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_position(panelLocationInput), 2, panelRowCount, bgcolor = f_panel_bg(panelIsLight, false), frame_color = panelFrame, frame_width = 1, border_color = panelFrame, border_width = 1)
    table.cell(panel, 0, 0, "AG Pro Trailing Stop Quality", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelSize), text_halign = text.align_center)
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelSize))
    table.merge_cells(panel, 0, 0, 1, 0)
    lastPanelLocation := panelLocationInput
    lastPanelTheme := panelThemeInput
    lastPanelSize := panelFontSizeInput
    lastProofMode := showProof

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    lastPanelLocation := ""
    lastPanelTheme := ""
    lastPanelSize := ""

if showPanel and not na(panel) and barstate.islast
    table.clear(panel, 0, 0, 1, panelRowCount - 1)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.cell(panel, 0, 0, "AG Pro Trailing Stop Quality", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelSize), text_halign = text.align_center)
    f_set_row(panel, 1, "Workflow", workflowRead, stateColor, panelIsLight, false, panelSize)
    f_set_row(panel, 2, "Quality", qualityRead, f_score_color(qualityScore), panelIsLight, true, panelSize)
    f_set_row(panel, 3, "Trail Distance", distanceRead, activeDistanceAtr >= minTrailAdj and activeDistanceAtr <= maxTrailAdj and not defenseLost ? bullColor : neutralColor, panelIsLight, false, panelSize)
    f_set_row(panel, 4, "Defense Rail", defenseRead, trendAligned ? bullColor : neutralColor, panelIsLight, true, panelSize)
    f_set_row(panel, 5, "Risk Shift", shiftRead, riskShift ? neutralColor : bullColor, panelIsLight, false, panelSize)
    f_set_row(panel, 6, "Target Room", targetRead, targetRoomOpen ? bullColor : neutralColor, panelIsLight, true, panelSize)
    f_set_row(panel, 7, "Review View", bestViewText, accentColor, panelIsLight, false, panelSize)
    if showProof
        color proofHeadBg = f_panel_bg(panelIsLight, false)
        table.cell(panel, 0, 8, "Proof @ Confirm", text_color = accentColor, bgcolor = proofHeadBg, text_size = f_label_size(panelSize), text_halign = text.align_left)
        table.cell(panel, 1, 8, proofSampleText, text_color = f_panel_label(panelIsLight), bgcolor = proofHeadBg, text_size = f_label_size(panelSize), text_halign = text.align_right)
        f_set_row(panel, 9, "Follow Rate", followText, followCol, panelIsLight, true, panelSize)
        f_set_row(panel, 10, "Hold Rate", holdText, holdCol, panelIsLight, false, panelSize)
        f_set_row(panel, 11, "React Rate", reactText, reactCol, panelIsLight, true, panelSize)
        f_set_row(panel, 12, "Flip Rate", flipText, flipCol, panelIsLight, false, panelSize)

// -------------------------------------------------
// Alerts And Hidden Exports
// -------------------------------------------------
alertcondition(alertTrailStates and holdsEvent, title = "TSQ | Review Hold", message = "Trailing Stop Quality: REVIEW HOLD attention marker. Trail distance and defense context remain clean.")
alertcondition(alertTrailStates and shiftEvent, title = "TSQ | Check Shift", message = "Trailing Stop Quality: CHECK SHIFT attention marker. Swing and volatility trail context moved into a risk-shift state.")
alertcondition(alertTrailStates and monitorEvent, title = "TSQ | Track Trail", message = "Trailing Stop Quality: TRACK TRAIL attention marker. The trail context requires broader review.")
alertcondition(alertTrailStates and noiseEvent, title = "TSQ | Wait Cleaner", message = "Trailing Stop Quality: WAIT CLEANER attention marker. The current trailing reference is noisy or low quality.")
alertcondition(alertTrailStates and lostEvent, title = "TSQ | Reset Trail", message = "Trailing Stop Quality: RESET TRAIL attention marker. Price crossed the active defense rail.")
alertcondition(alertRoomWarnings and roomLimitedEvent, title = "TSQ | Check Room", message = "Trailing Stop Quality: CHECK ROOM attention marker. Forward room is limited relative to current active trail risk.")

plot(qualityScore, title = "TSQ Quality Score", display = display.none)
plot(activeDistanceAtr, title = "TSQ Active Distance ATR", display = display.none)
plot(railSpreadAtr, title = "TSQ Rail Spread ATR", display = display.none)
plot(followRate, title = "TSQ Follow Rate", display = display.none)
plot(holdRate, title = "TSQ Hold Rate", display = display.none)
plot(reactRate, title = "TSQ React Rate", display = display.none)
plot(flipRate, title = "TSQ Flip Rate", display = display.none)
plot(proofAmbiguous, title = "TSQ Ambiguous Proof Count", display = display.none)
plot(managementDir, title = "TSQ Management Direction", display = display.none)

if confirmedBar
    labelLastTrailState := trailState
````

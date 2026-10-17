# Invalidation Quality Planner [AGPro Series]

- url: https://www.tradingview.com/script/4NG02kK9-Invalidation-Quality-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;a1a6290eabf84b76b31b4771a221e61b
- version: 7.0

## Description

Invalidation Quality Planner [AGPro Series]

🧠 Core Idea

Is the active invalidation shelf meaningful enough to build a plan around, or is it fragile, distant, weak, or already violated?


📌 Overview / What it does

Invalidation Quality Planner [AGPro Series] is a chart-first risk planning tool designed to evaluate the quality of the level that would invalidate a setup idea.

Instead of drawing generic support/resistance zones or printing buy/sell signals, the script studies one active invalidation shelf and converts its structure into a 0-100 quality score. It measures swing clarity, defended reactions, prior violations, wick pressure, volatility buffer, forward room, and violation risk.

The output is a focused planning workflow: an invalidation shelf zone, shelf and violation guides, forward-room reference, compact event labels, alerts, and a clean AGPro decision panel. It does not predict future price movement, automate decisions, or guarantee that any shelf will hold.


🎯 Purpose & Design Philosophy

This script was built for traders who want to judge whether their risk reference is structurally meaningful before relying on it.

Many tools show entries, targets, support/resistance zones, or stop distances. This tool focuses on the deeper planning question: is the invalidation level itself strong enough to deserve trust?

The design supports a disciplined setup-review mindset. It helps users separate a clean invalidation shelf from a weak, noisy, overextended, or already violated one.


⚡ Why This Script Is Different

Most tools focus on signals, stop-loss placement, support/resistance mapping, or risk/reward drawings.

This script does NOT become a generic S/R zone map, a stop-loss optimizer, a position-size calculator, a target ladder, or an entry signal tool.

Instead, it evaluates the quality of the invalidation reference. The core output is not a trade command. It is a planning state that helps users decide whether the current shelf is VALID, on WATCH, FRAGILE, DISTANT, DEFENDED, WEAK, or VIOLATED.


⚙️ Methodology

1. Context Detection
The script detects the active planning side using trend context and range location, or allows the user to force long-context or short-context evaluation.

2. Reference Mapping
It maps the active invalidation shelf from confirmed swing pivots, with a fallback structure reference when no fresh pivot is available.

3. Reaction Evaluation
The model scores swing clarity, defended shelf reactions, clean history, wick pressure, ATR-normalized shelf distance, volatility context, violation risk, and forward room.

4. Visual Output
The output is shown through an invalidation shelf zone, violation guide, forward-room guide, compact labels, deterministic alerts, and a premium AGPro panel.


🗺️ How to Read the Chart

Zones = the active invalidation shelf used by the planner. It is a risk reference, not a generic support/resistance zone.

Labels = compact state markers showing VALID, WATCH, DEFENDED, FRAGILE, DISTANT, WEAK, or VIOLATED context.

Colors = teal marks cleaner planning context, pink marks violation or weak context, amber marks caution, and indigo marks watch/transition context.

Panel = the panel summarizes Invalidation Quality, Distance, Structure Support, Violation Risk, and Action.


🚦 Signals & States

• VALID → the active invalidation shelf has enough structure and quality to deserve review.

• WATCH → the shelf is improving but not clean enough for VALID state.

• DEFENDED → price tested the shelf and closed back in favor of the active planning side.

• FRAGILE → price is too close to the shelf, making normal noise more important.

• DISTANT → the shelf is too far from price for clean planning context.

• WEAK → the shelf lacks enough structure, reaction memory, or clean history.

• VIOLATED → price crossed the active violation guide and the context should be rebuilt.


🔔 Alerts Logic

Alerts trigger when the planner enters VALID state, enters WATCH state, detects a defended shelf reaction, marks a weak/fragile/distant shelf, or detects a shelf violation.

These alerts are attention markers. They are not trade instructions, entry signals, exit commands, or automated strategy actions.


🧩 Confluence Logic

The strongest invalidation context appears when swing clarity, defended reactions, clean violation history, controlled wick pressure, balanced ATR distance, and sufficient forward room align.

When those factors align, the quality score rises and the panel can move from WATCH to VALID. If the shelf becomes too close, too distant, noisy, or violated, the state downgrades.


📊 When to Use

• Before evaluating a discretionary setup

• During pullbacks where a structural invalidation shelf is forming

• Around continuation setups where risk needs a clean reference

• Before breakout or reclaim attempts where the failure point matters

• When comparing whether one setup has a cleaner invalidation reference than another


⚠️ When NOT to Use

• Extremely low-liquidity symbols

• Very noisy micro-timeframes with unstable wicks

• News-driven volatility spikes

• Markets where recent structure is distorted and no useful invalidation shelf exists

• Situations where the user expects a signal-only entry tool


🎛️ Key Inputs

• Planning Side → controls Auto, Long Context, or Short Context evaluation.

• Shelf Pivot Left / Right → controls how strict the confirmed swing shelf detection is.

• Shelf Fallback Lookback → defines the backup structure reference when no fresh pivot exists.

• Reaction Memory Lookback → controls how far back defended reactions and violations are counted.

• Shelf Zone Buffer ATR → controls the width of the invalidation shelf zone.

• Violation Buffer ATR → controls when price is treated as crossing beyond the shelf.

• VALID / WATCH Thresholds → adjust how selective the planner is.

• Visual settings → control shelf zones, guide lines, memory zones, labels, panel location, theme, and font sizes.


🖥️ Interface & Visual Design

The interface is built around one primary chart object: the invalidation shelf zone.

The panel follows the AGPro public-release standard with one merged blue header row containing only the script name. The layout keeps the key planning information readable without turning the script into a dashboard-heavy overlay.

Labels are compact, offset away from candles, and controlled with cooldown and maximum-visible settings.


🧪 Practical Usage Workflow

1. Read the panel Invalidation Quality and Action state.

2. Check whether price is respecting, approaching, or violating the shelf zone.

3. Review the Distance row to see whether the shelf is balanced, fragile, or distant.

4. Compare Structure Support with Violation Risk.

5. Treat alerts as review prompts and confirm the broader market context before making any decision.


🔍 Interpretation Guidelines

A higher score means the planner sees stronger alignment between shelf structure, reaction memory, clean history, distance quality, violation risk, and forward room.

VALID does not mean a trade must be taken. It means the invalidation shelf is meaningful enough to deserve attention.

WATCH means the shelf may be developing but still needs stronger evidence.

FRAGILE, DISTANT, WEAK, and VIOLATED are caution states that help users avoid building a plan around a poor invalidation reference.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not auto trading

• Not guaranteed signals

• Not a generic support/resistance mapper

• Not a stop-loss optimizer

• Not a position sizing calculator

• Not a take-profit planner


⚠️ Limitations & Transparency

Pivot-based shelves are confirmed after the selected pivot strength completes, so the script is intentionally reactive rather than predictive.

Different timeframes can create different shelf references, reaction counts, and violation-risk readings.

Volatility changes can alter ATR-normalized distance, shelf width, and forward-room conditions.

The script is rule-based and should be interpreted as an analytical planning layer, not as certainty.


🧠 Market Context Notes

Invalidation quality is not only about distance. A shelf can be close but meaningful, distant but inefficient, or visually obvious but already weakened by violations.

The planner is most useful when it helps the user ask better questions before trusting a setup idea.


🧾 Use Case Examples

When price pulls back toward a clean swing shelf, defends it, and still has enough forward room, the planner may show DEFENDED or VALID context.

When price is sitting directly on the shelf with heavy wick pressure, the planner may mark FRAGILE even if the level looks visually interesting.

When price crosses beyond the violation guide, the planner marks VIOLATED so the old risk reference is not treated as still clean.


🧱 System Philosophy

Invalidation Quality Planner follows the AGPro Series decision-engine approach:

Context first.
Risk reference before target.
Structure before signal.
Attention markers instead of promises.


🔐 Non-Promise Statement

No indicator can remove uncertainty.

No state, score, label, alert, or visual zone should be interpreted as guaranteed market direction.


📉 Risk Disclosure

Trading involves risk.

All decisions remain the responsibility of the user.

This script is for educational and analytical chart review only and does not provide financial advice.


📚 Educational Note

Use the tool to study how invalidation references form, defend, weaken, or fail across different market conditions.

## Source Code

````pine
// -------------------------------------------------
// Invalidation Quality Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.7
//
// Invalidation Quality Planner is a chart-first risk planning tool that
// evaluates whether an active invalidation shelf is meaningful enough to plan
// around. It scores shelf clarity, defended reactions, wick pressure, distance
// buffer, violation risk, volatility context, and forward room without becoming
// generic support/resistance, a stop-loss optimizer, or a signal tool.
// Version 1.4 adds a confirmation-anchored proof layer (Follow, Hold, React,
// Flip rates) showing how often plannable shelves held toward forward room
// before the violation guide was crossed.
// -------------------------------------------------

//@version=6
indicator("Invalidation Quality Planner [AGPro Series]",
     shorttitle       = "AG Pro Inv",
     overlay          = true,
     max_labels_count = 160,
     max_boxes_count  = 60,
     max_lines_count  = 70)

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
ttPreset = "Applies a complete preset for shelf strictness, memory, label density, and visual behavior. Custom keeps the manual settings below."
ttSide = "Selects the planning side. Auto reads trend and range location to choose the active long or short invalidation context. Manual modes force one side only."
ttConfirm = "Close Confirmed waits for the bar to close before state changes, labels, and alerts are printed. Live Updating can react intrabar."
ttAtrLen = "ATR length used to normalize shelf distance, wick pressure, target room, visual offsets, and violation buffers."
ttBaseline = "Longer ATR baseline used to classify whether current volatility is compressed, normal, or hot."
ttPivot = "Pivot strength used to find meaningful swing shelves. Higher values require more structure before a shelf is accepted."
ttShelfLookback = "Fallback lookback used when no fresh confirmed pivot shelf is available. The script evaluates one active invalidation shelf, not a generic level map."
ttReactionLookback = "Lookback used to count defended reactions and prior shelf violations. This is a shelf memory score, not support/resistance inventory."
ttTargetLookback = "Lookback used to estimate forward room before the next range edge in the planned direction."
ttFast = "Fast EMA used only for automatic side selection and trend context. It does not generate entry signals."
ttSlow = "Slow EMA used only for automatic side selection and trend context."
ttShelfBuffer = "ATR padding around the active invalidation shelf. This defines the visual shelf zone and reaction-test area."
ttViolationBuffer = "ATR padding beyond the shelf that must be crossed before a violation is counted."
ttMinBuffer = "Minimum acceptable ATR-normalized distance from price to invalidation. Below this value, normal noise can make the shelf fragile."
ttIdealBuffer = "Preferred ATR-normalized distance from price to invalidation. The distance score is strongest near this value."
ttMaxBuffer = "Maximum acceptable ATR-normalized distance from price to invalidation. Above this value, the shelf can become too distant to plan around cleanly."
ttDefenseTarget = "Defended reaction count that maps to a strong reaction-memory score. Higher values require more shelf history."
ttMaxViolations = "Violation count that starts to damage shelf trust. Lower values make the model stricter when the shelf has already failed."
ttMinRoom = "Minimum ATR-normalized forward room required before invalidation quality can be treated as clean."
ttStrongRoom = "Forward-room value that maps to a strong room score. Higher values require more open space in the planned direction."
ttValid = "Minimum 0-100 score required for VALID state. VALID means the shelf is meaningful enough for review, not that a trade should be taken."
ttWatch = "Minimum 0-100 score required for WATCH state. WATCH means the shelf is improving but still not clean enough for VALID."
ttZone = "Shows the active invalidation shelf zone with centered badge text. The zone is a planning reference, not a generic support/resistance area."
ttLines = "Shows the shelf line and violation guide. These guides explain the current plan context without creating buy or sell signals."
ttTarget = "Shows the forward target-edge guide used only to measure room. It is not a take-profit command."
ttMemory = "Keeps a small number of prior defended shelf zones as soft context, with readable centered labels. Disable if the chart becomes too busy."
ttProjection = "Number of bars the active shelf and guide lines project to the right."
ttZoneOpacity = "Transparency for the active shelf zone. Higher values make the zone lighter."
ttZoneTextMode = "Controls how much text is displayed inside the active invalidation shelf zone. Compact is best for publication screenshots."
ttRiskBand = "Shows a subtle band between the shelf and the violation guide. This improves invalidation-risk visibility without changing the model."
ttZoneBorder = "Controls the active shelf zone border width. Higher values make the planning shelf easier to see on light backgrounds."
ttRightTags = "Shows compact right-side tags for shelf, violation, and room references. Useful for screenshots and quick reading."
ttTagOffset = "Horizontal offset for right-side tags. Increase it if tags overlap with the current price scale or nearby labels."
ttMemoryText = "Controls how defended shelf memory zones are labeled. Compact keeps screenshots clean; Detailed adds score context."
ttMarkers = "Shows small chart markers in addition to labels. Disabled by default because labels and shelf zones already carry the primary visual story."
ttLabels = "Shows compact VALID, WATCH, WEAK, DEFENDED, and VIOLATED labels. Labels are offset away from candles."
ttContext = "Adds sparse context labels while the planner remains active. Disabled by default for a cleaner public-release chart."
ttCooldown = "Minimum bars between event labels. Higher values reduce label density."
ttContextSpacing = "Minimum bars between sparse context labels during ongoing evaluation."
ttMaxLabels = "Maximum number of chart labels retained. Older labels are removed first to preserve performance."
ttLabelOffset = "ATR-based vertical offset that keeps labels above or below candles."
ttLabelScore = "Adds the 0-100 invalidation-quality score to chart labels."
ttLabelDetails = "Adds a second label line with violation-risk and ATR-distance details. Disabled by default to keep publication screenshots cleaner."
ttLabelSize = "Font size for chart labels and centered shelf text. Normal is the recommended publication default."
ttShowPanel = "Shows or hides the AG Pro planning panel. It is shown by default for public-release readability."
ttPanelLocation = "Moves the panel to the preferred chart location."
ttPanelTheme = "Switches the panel between AGPro dark and clean light themes."
ttPanelFont = "Font size for the AG Pro panel. Normal is the recommended publication default."
ttAlerts = "Enables alert conditions for valid, watch, defended, weak, and violated shelf states."
ttProof = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across plannable (VALID or DEFENDED) shelves on the current symbol and timeframe. Follow means a plannable shelf held one risk unit (1R) toward forward room before the violation guide was crossed. These are historical outcome rates, not predictions."
ttProofHorizon = "Maximum number of bars each plannable shelf is tracked for the proof measurement before it resolves at its current outcome."
ttReactBars = "Number of bars after a shelf becomes plannable used to detect an immediate favorable reaction toward forward room."
ttReactProgress = "Minimum favorable progress toward the 1R room target, within the reaction window, required to count as an early React."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Invalidation Engine"
enginePreset = input.string("Balanced Shelf", "Engine Preset", options = ["Balanced Shelf", "Cleaner Swing", "Active Intraday", "Custom"], group = groupEngine, tooltip = ttPreset)
sideMode = input.string("Auto", "Planning Side", options = ["Auto", "Long Context", "Short Context"], group = groupEngine, tooltip = ttSide)
confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = ttConfirm)
atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = ttAtrLen)
baselineLen = input.int(55, "ATR Context Baseline", minval = 10, maxval = 300, group = groupEngine, tooltip = ttBaseline)
pivotLeft = input.int(3, "Shelf Pivot Left", minval = 1, maxval = 20, group = groupEngine, tooltip = ttPivot)
pivotRight = input.int(3, "Shelf Pivot Right", minval = 1, maxval = 20, group = groupEngine, tooltip = ttPivot)
shelfLookback = input.int(48, "Shelf Fallback Lookback", minval = 10, maxval = 260, group = groupEngine, tooltip = ttShelfLookback)
reactionLookback = input.int(72, "Reaction Memory Lookback", minval = 12, maxval = 300, group = groupEngine, tooltip = ttReactionLookback)
targetLookback = input.int(84, "Forward Room Lookback", minval = 12, maxval = 320, group = groupEngine, tooltip = ttTargetLookback)
fastEmaLen = input.int(21, "Fast Context EMA", minval = 1, maxval = 200, group = groupEngine, tooltip = ttFast)
slowEmaLen = input.int(55, "Slow Context EMA", minval = 2, maxval = 300, group = groupEngine, tooltip = ttSlow)
shelfBufferAtr = input.float(0.30, "Shelf Zone Buffer ATR", minval = 0.05, maxval = 2.00, step = 0.01, group = groupEngine, tooltip = ttShelfBuffer)
violationBufferAtr = input.float(0.22, "Violation Buffer ATR", minval = 0.03, maxval = 1.50, step = 0.01, group = groupEngine, tooltip = ttViolationBuffer)

groupScoring = "Quality Scoring"
minBufferAtr = input.float(0.55, "Minimum Shelf Distance ATR", minval = 0.05, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = ttMinBuffer)
idealBufferAtr = input.float(1.35, "Ideal Shelf Distance ATR", minval = 0.10, maxval = 8.00, step = 0.05, group = groupScoring, tooltip = ttIdealBuffer)
maxBufferAtr = input.float(3.00, "Maximum Shelf Distance ATR", minval = 0.20, maxval = 12.00, step = 0.05, group = groupScoring, tooltip = ttMaxBuffer)
defenseTarget = input.float(3.0, "Strong Defense Count", minval = 1.0, maxval = 10.0, step = 0.5, group = groupScoring, tooltip = ttDefenseTarget)
maxViolationCount = input.float(2.0, "Weak Shelf Violation Count", minval = 1.0, maxval = 8.0, step = 0.5, group = groupScoring, tooltip = ttMaxViolations)
minRoomAtr = input.float(1.20, "Minimum Forward Room ATR", minval = 0.10, maxval = 10.00, step = 0.05, group = groupScoring, tooltip = ttMinRoom)
strongRoomAtr = input.float(3.20, "Strong Forward Room ATR", minval = 0.30, maxval = 20.00, step = 0.10, group = groupScoring, tooltip = ttStrongRoom)
validThreshold = input.float(74.0, "VALID Threshold", minval = 40.0, maxval = 95.0, step = 1.0, group = groupScoring, tooltip = ttValid)
watchThreshold = input.float(58.0, "WATCH Threshold", minval = 25.0, maxval = 90.0, step = 1.0, group = groupScoring, tooltip = ttWatch)

groupVisual = "Chart Visuals"
showShelfZone = input.bool(true, "Show Invalidation Shelf Zone", group = groupVisual, tooltip = ttZone)
showGuideLines = input.bool(true, "Show Shelf / Violation Guides", group = groupVisual, tooltip = ttLines)
showTargetGuide = input.bool(true, "Show Forward Room Guide", group = groupVisual, tooltip = ttTarget)
showMemoryZones = input.bool(true, "Show Defended Shelf Memory", group = groupVisual, tooltip = ttMemory)
memoryZoneCount = input.int(1, "Max Memory Zones", minval = 0, maxval = 10, group = groupVisual, tooltip = ttMemory)
memoryTextMode = input.string("Compact", "Memory Zone Text", options = ["Off", "Compact", "Detailed"], group = groupVisual, tooltip = ttMemoryText)
projectionBars = input.int(40, "Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = ttProjection)
zoneTransparency = input.int(87, "Shelf Zone Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = ttZoneOpacity)
zoneTextMode = input.string("Compact", "Shelf Zone Text", options = ["Off", "Compact", "Detailed"], group = groupVisual, tooltip = ttZoneTextMode)
showRiskBand = input.bool(true, "Show Violation Risk Band", group = groupVisual, tooltip = ttRiskBand)
riskBandTransparency = input.int(92, "Risk Band Transparency", minval = 80, maxval = 97, group = groupVisual, tooltip = ttZoneOpacity)
zoneBorderWidthInput = input.int(2, "Shelf Zone Border Width", minval = 1, maxval = 4, group = groupVisual, tooltip = ttZoneBorder)
showRightSideTags = input.bool(true, "Show Right-Side Tags", group = groupVisual, tooltip = ttRightTags)
rightTagOffsetBars = input.int(7, "Right Tag Offset Bars", minval = 1, maxval = 40, group = groupVisual, tooltip = ttTagOffset)
showEventMarkers = input.bool(false, "Show Event Markers", group = groupVisual, tooltip = ttMarkers)

groupLabels = "Labels"
showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContext)
labelCooldownBars = input.int(28, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
contextSpacingBars = input.int(96, "Context Label Spacing", minval = 12, maxval = 240, group = groupLabels, tooltip = ttContextSpacing)
maxVisibleLabels = input.int(7, "Max Visible Labels", minval = 4, maxval = 80, group = groupLabels, tooltip = ttMaxLabels)
labelOffsetAtr = input.float(1.05, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttLabelScore)
showLabelDetails = input.bool(false, "Show Label Details", group = groupLabels, tooltip = ttLabelDetails)
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = ttPanelTheme)
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

groupProof = "Proof"
showProof = input.bool(true, "Show Proof Layer", group = groupProof, tooltip = ttProof)
proofHorizonBars = input.int(36, "Proof Horizon Bars", minval = 5, maxval = 300, group = groupProof, tooltip = ttProofHorizon)
reactBars = input.int(4, "Reaction Window Bars", minval = 1, maxval = 60, group = groupProof, tooltip = ttReactBars)
reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = groupProof, tooltip = ttReactProgress)

groupAlerts = "Alerts"
alertShelfStates = input.bool(true, "Alert on Shelf States", group = groupAlerts, tooltip = ttAlerts)

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

f_buffer_score(float distanceAtr, float minAtr, float idealAtr, float maxAtr) =>
    result = 0.0
    if distanceAtr < minAtr
        result := f_clamp(distanceAtr / math.max(minAtr, 0.01) * 68.0, 0.0, 68.0)
    else if distanceAtr <= idealAtr
        result := 68.0 + f_clamp((distanceAtr - minAtr) / math.max(idealAtr - minAtr, 0.01) * 32.0, 0.0, 32.0)
    else if distanceAtr <= maxAtr
        result := 100.0 - f_clamp((distanceAtr - idealAtr) / math.max(maxAtr - idealAtr, 0.01) * 34.0, 0.0, 34.0)
    else
        result := f_clamp(66.0 - (distanceAtr - maxAtr) / math.max(maxAtr, 0.01) * 66.0, 0.0, 66.0)
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

f_state_color(string stateText) =>
    switch stateText
        "VALID" => bullColor
        "DEFENDED" => bullColor
        "WATCH" => accentColor
        "FRAGILE" => neutralColor
        "DISTANT" => neutralColor
        "VIOLATED" => dangerColor
        "WEAK" => bearColor
        => panelLabelCol

f_zone_label_color(string stateText) =>
    switch stateText
        "VALID" => color.rgb(13, 148, 136)
        "DEFENDED" => color.rgb(13, 148, 136)
        "WATCH" => color.rgb(79, 70, 229)
        "FRAGILE" => color.rgb(180, 83, 9)
        "DISTANT" => color.rgb(180, 83, 9)
        "VIOLATED" => color.rgb(220, 38, 38)
        "WEAK" => color.rgb(190, 24, 93)
        => panelBorder

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

f_delete_label(label item) =>
    if not na(item)
        label.delete(item)

// -------------------------------------------------
// Core measurements
// -------------------------------------------------
cleanerPreset = enginePreset == "Cleaner Swing"
activePreset = enginePreset == "Active Intraday"
customPreset = enginePreset == "Custom"
usedValidThreshold = customPreset ? validThreshold : cleanerPreset ? math.max(validThreshold, 78.0) : activePreset ? math.max(validThreshold - 5.0, 50.0) : validThreshold
usedWatchThreshold = customPreset ? watchThreshold : cleanerPreset ? math.max(watchThreshold, 62.0) : activePreset ? math.max(watchThreshold - 5.0, 35.0) : watchThreshold
usedMaxLabels = customPreset ? maxVisibleLabels : cleanerPreset ? math.min(maxVisibleLabels, 5) : activePreset ? math.min(maxVisibleLabels, 9) : math.min(maxVisibleLabels, 7)
usedLabelCooldown = customPreset ? labelCooldownBars : cleanerPreset ? math.max(labelCooldownBars, 36) : activePreset ? math.max(labelCooldownBars, 18) : labelCooldownBars
usedContextSpacing = customPreset ? contextSpacingBars : cleanerPreset ? math.max(contextSpacingBars, 120) : activePreset ? math.max(contextSpacingBars, 60) : contextSpacingBars
usedMemoryZones = customPreset ? memoryZoneCount : cleanerPreset ? math.min(memoryZoneCount, 1) : activePreset ? math.min(memoryZoneCount, 3) : math.min(memoryZoneCount, 2)

confirmedBar = confirmationMode == "Close Confirmed" ? barstate.isconfirmed : true
atr = ta.atr(atrLen)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
atrBase = ta.sma(atr, baselineLen)
atrRatio = not na(atrBase) and atrBase > 0.0 ? atr / atrBase : 1.0

fastEma = ta.ema(close, fastEmaLen)
slowEma = ta.ema(close, slowEmaLen)
rangeHigh = nz(ta.highest(high, targetLookback), high)
rangeLow = nz(ta.lowest(low, targetLookback), low)
rangeWidth = math.max(rangeHigh - rangeLow, syminfo.mintick)
rangePosition = f_clamp((close - rangeLow) / rangeWidth, 0.0, 1.0)

bullContext = close >= slowEma and fastEma >= slowEma
bearContext = close < slowEma and fastEma < slowEma
planDir = sideMode == "Long Context" ? 1 : sideMode == "Short Context" ? -1 : bullContext ? 1 : bearContext ? -1 : rangePosition <= 0.50 ? 1 : -1
dirText = planDir == 1 ? "Long" : "Short"

pivotLow = ta.pivotlow(low, pivotLeft, pivotRight)
pivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)
var float lastPivotLow = na
var float lastPivotHigh = na
var int lastPivotLowBar = na
var int lastPivotHighBar = na

if not na(pivotLow)
    lastPivotLow := pivotLow
    lastPivotLowBar := bar_index - pivotRight

if not na(pivotHigh)
    lastPivotHigh := pivotHigh
    lastPivotHighBar := bar_index - pivotRight

longPivotFresh = not na(lastPivotLowBar) and bar_index - lastPivotLowBar <= shelfLookback
shortPivotFresh = not na(lastPivotHighBar) and bar_index - lastPivotHighBar <= shelfLookback
fallbackLow = nz(ta.lowest(low, shelfLookback), low)
fallbackHigh = nz(ta.highest(high, shelfLookback), high)
fallbackLowOffset = math.max(0, nz(ta.lowestbars(low, shelfLookback), 0))
fallbackHighOffset = math.max(0, nz(ta.highestbars(high, shelfLookback), 0))

activeShelf = planDir == 1 ? longPivotFresh ? lastPivotLow : fallbackLow : shortPivotFresh ? lastPivotHigh : fallbackHigh
shelfBar = planDir == 1 ? longPivotFresh ? lastPivotLowBar : bar_index - fallbackLowOffset : shortPivotFresh ? lastPivotHighBar : bar_index - fallbackHighOffset
pivotShelf = planDir == 1 ? longPivotFresh : shortPivotFresh

shelfTop = activeShelf + safeAtr * shelfBufferAtr
shelfBottom = activeShelf - safeAtr * shelfBufferAtr
violationGuide = activeShelf - planDir * safeAtr * violationBufferAtr
shelfDistance = math.max(planDir == 1 ? close - activeShelf : activeShelf - close, syminfo.mintick)
shelfDistanceAtr = shelfDistance / safeAtr
targetEdge = planDir == 1 ? rangeHigh : rangeLow
forwardRoom = math.max(planDir == 1 ? targetEdge - close : close - targetEdge, 0.0)
forwardRoomAtr = forwardRoom / safeAtr

shelfDeparture = planDir == 1 ? nz(ta.highest(high, shelfLookback), high) - activeShelf : activeShelf - nz(ta.lowest(low, shelfLookback), low)
shelfDepartureAtr = math.max(shelfDeparture, 0.0) / safeAtr
shelfAge = math.max(0, bar_index - shelfBar)
activeWick = planDir == 1 ? math.min(open, close) - low : high - math.max(open, close)
wickPressureAtr = nz(ta.sma(activeWick / safeAtr, reactionLookback), activeWick / safeAtr)

defenseCount = 0.0
testCount = 0.0
violationCount = 0.0

for idx = 0 to reactionLookback - 1
    testLow = low[idx]
    testHigh = high[idx]
    testClose = close[idx]
    testOpen = open[idx]
    if planDir == 1 and not na(testLow)
        tested = testLow <= shelfTop and testHigh >= shelfBottom
        defended = tested and testClose > activeShelf and testClose >= testOpen
        violated = testClose < activeShelf - safeAtr * violationBufferAtr
        testCount += tested ? 1.0 : 0.0
        defenseCount += defended ? 1.0 : 0.0
        violationCount += violated ? 1.0 : 0.0
    if planDir == -1 and not na(testHigh)
        tested = testHigh >= shelfBottom and testLow <= shelfTop
        defended = tested and testClose < activeShelf and testClose <= testOpen
        violated = testClose > activeShelf + safeAtr * violationBufferAtr
        testCount += tested ? 1.0 : 0.0
        defenseCount += defended ? 1.0 : 0.0
        violationCount += violated ? 1.0 : 0.0

clarityScore = f_norm_high_good(shelfDepartureAtr, 0.70, 2.80)
ageScore = shelfAge <= pivotRight ? 70.0 : shelfAge <= shelfLookback * 0.72 ? 100.0 : 72.0
pivotScore = pivotShelf ? 100.0 : 62.0
structureSupportScore = clarityScore * 0.48 + ageScore * 0.28 + pivotScore * 0.24
defenseScore = f_clamp(defenseCount / math.max(defenseTarget, 1.0) * 100.0, 0.0, 100.0)
cleanHistoryScore = f_norm_low_good(violationCount, 0.0, maxViolationCount)
reactionMemoryScore = defenseScore * 0.68 + cleanHistoryScore * 0.32
bufferScore = f_buffer_score(shelfDistanceAtr, minBufferAtr, idealBufferAtr, maxBufferAtr)
wickScore = f_norm_low_good(wickPressureAtr, 0.08, 0.72)
roomScore = f_norm_high_good(forwardRoomAtr, minRoomAtr * 0.45, strongRoomAtr)
volatilityScore = f_peak_score(atrRatio, 0.58, 1.00, 1.90)
violationRisk = f_clamp((100.0 - cleanHistoryScore) * 0.36 + (100.0 - wickScore) * 0.28 + (100.0 - bufferScore) * 0.24 + (100.0 - volatilityScore) * 0.12, 0.0, 100.0)
violationScore = 100.0 - violationRisk
qualityRaw = structureSupportScore * 0.28 + reactionMemoryScore * 0.24 + bufferScore * 0.20 + violationScore * 0.16 + roomScore * 0.12
qualityScore = int(math.round(f_clamp(qualityRaw, 0.0, 100.0)))

testedNow = planDir == 1 ? low <= shelfTop : high >= shelfBottom
defendedNow = confirmedBar and testedNow and (planDir == 1 ? close > activeShelf and close >= open : close < activeShelf and close <= open)
violatedNow = confirmedBar and (planDir == 1 ? close < violationGuide : close > violationGuide)
tooClose = shelfDistanceAtr < minBufferAtr
tooDistant = shelfDistanceAtr > maxBufferAtr
noRoom = forwardRoomAtr < minRoomAtr

distanceState = tooClose ? "FRAGILE" : tooDistant ? "DISTANT" : bufferScore >= 78.0 ? "BALANCED" : "ACCEPTABLE"
structureState = structureSupportScore >= 72.0 ? "SUPPORTED" : structureSupportScore >= 54.0 ? "MIXED" : "WEAK"
violationRiskState = violationRisk <= 28.0 ? "LOW" : violationRisk <= 55.0 ? "MODERATE" : "HIGH"
roomState = noRoom ? "LIMITED" : roomScore >= 72.0 ? "OPEN" : "FAIR"
qualityState = violatedNow ? "VIOLATED" : defendedNow and qualityScore >= usedWatchThreshold ? "DEFENDED" : tooClose ? "FRAGILE" : tooDistant ? "DISTANT" : qualityScore >= usedValidThreshold ? "VALID" : qualityScore >= usedWatchThreshold ? "WATCH" : "WEAK"
actionState = qualityState == "VALID" ? "Plan Around" : qualityState == "DEFENDED" ? "Review Defense" : qualityState == "WATCH" ? "Monitor Shelf" : qualityState == "FRAGILE" ? "Wait Buffer" : qualityState == "DISTANT" ? "Wait Closer" : qualityState == "VIOLATED" ? "Rebuild Plan" : "Wait"
stateColor = f_state_color(qualityState)

// -------------------------------------------------
// Invalidation shelf visuals
// -------------------------------------------------
rightEdge = bar_index + projectionBars
var box shelfBox = na
var box riskBandBox = na
var line shelfLine = na
var line violationLine = na
var line targetLine = na
var label shelfTag = na
var label violationTag = na
var label roomTag = na
var label shelfZoneLabel = na
var label riskBandLabel = na
var array<box> memoryBoxes = array.new_box()
var array<label> memoryZoneLabels = array.new_label()

if showShelfZone
    zoneLabelText = zoneTextMode == "Off" ? "" : zoneTextMode == "Detailed" ? "SHELF\n" + qualityState + " " + str.tostring(qualityScore) + "\nRisk " + violationRiskState : qualityState + "\nQ " + str.tostring(qualityScore)
    zoneBorderWidth = math.max(zoneBorderWidthInput, qualityState == "VALID" or qualityState == "DEFENDED" ? 2 : 1)
    if na(shelfBox)
        shelfBox := box.new(left = shelfBar, top = shelfTop, right = rightEdge, bottom = shelfBottom, xloc = xloc.bar_index, bgcolor = color.new(stateColor, zoneTransparency), border_color = color.new(stateColor, 18), border_width = zoneBorderWidth)
    else
        box.set_left(shelfBox, shelfBar)
        box.set_right(shelfBox, rightEdge)
        box.set_top(shelfBox, shelfTop)
        box.set_bottom(shelfBox, shelfBottom)
        box.set_bgcolor(shelfBox, color.new(stateColor, zoneTransparency))
        box.set_border_color(shelfBox, color.new(stateColor, 18))
        box.set_border_width(shelfBox, zoneBorderWidth)
    zoneLabelX = int(math.round((shelfBar + rightEdge) * 0.5))
    zoneLabelY = (shelfTop + shelfBottom) * 0.5
    if zoneTextMode != "Off"
        if na(shelfZoneLabel)
            shelfZoneLabel := label.new(x = zoneLabelX, y = zoneLabelY, text = zoneLabelText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(f_zone_label_color(qualityState), 0), textcolor = headerText, size = f_text_size(labelSizeInput), textalign = text.align_center)
        else
            label.set_xy(shelfZoneLabel, zoneLabelX, zoneLabelY)
            label.set_text(shelfZoneLabel, zoneLabelText)
            label.set_color(shelfZoneLabel, color.new(f_zone_label_color(qualityState), 0))
            label.set_textcolor(shelfZoneLabel, headerText)
            label.set_size(shelfZoneLabel, f_text_size(labelSizeInput))
            label.set_textalign(shelfZoneLabel, text.align_center)
    else
        f_delete_label(shelfZoneLabel)
        shelfZoneLabel := na
else
    if not na(shelfBox)
        box.delete(shelfBox)
        shelfBox := na
    f_delete_label(shelfZoneLabel)
    shelfZoneLabel := na

riskBandShelfEdge = planDir == 1 ? shelfBottom : shelfTop
riskBandTop = math.max(riskBandShelfEdge, violationGuide)
riskBandBottom = math.min(riskBandShelfEdge, violationGuide)
riskLabelInside = math.abs(riskBandTop - riskBandBottom) >= safeAtr * 0.85
if showRiskBand and showShelfZone
    riskBandText = zoneTextMode == "Off" or not riskLabelInside ? "" : zoneTextMode == "Detailed" ? "RISK\n" + violationRiskState + "\n" + str.tostring(violationGuide, format.mintick) : "RISK\n" + violationRiskState
    if na(riskBandBox)
        riskBandBox := box.new(left = shelfBar, top = riskBandTop, right = rightEdge, bottom = riskBandBottom, xloc = xloc.bar_index, bgcolor = color.new(dangerColor, riskBandTransparency), border_color = color.new(dangerColor, 45), border_width = 1)
    else
        box.set_left(riskBandBox, shelfBar)
        box.set_right(riskBandBox, rightEdge)
        box.set_top(riskBandBox, riskBandTop)
        box.set_bottom(riskBandBox, riskBandBottom)
        box.set_bgcolor(riskBandBox, color.new(dangerColor, riskBandTransparency))
        box.set_border_color(riskBandBox, color.new(dangerColor, 45))
    riskLabelX = int(math.round((shelfBar + rightEdge) * 0.5))
    riskLabelY = (riskBandTop + riskBandBottom) * 0.5
    if riskBandText != ""
        if na(riskBandLabel)
            riskBandLabel := label.new(x = riskLabelX, y = riskLabelY, text = riskBandText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(color.rgb(185, 28, 28), 0), textcolor = headerText, size = f_text_size(labelSizeInput), textalign = text.align_center)
        else
            label.set_xy(riskBandLabel, riskLabelX, riskLabelY)
            label.set_text(riskBandLabel, riskBandText)
            label.set_color(riskBandLabel, color.new(color.rgb(185, 28, 28), 0))
            label.set_textcolor(riskBandLabel, headerText)
            label.set_size(riskBandLabel, f_text_size(labelSizeInput))
            label.set_textalign(riskBandLabel, text.align_center)
    else
        f_delete_label(riskBandLabel)
        riskBandLabel := na
else
    if not na(riskBandBox)
        box.delete(riskBandBox)
        riskBandBox := na
    f_delete_label(riskBandLabel)
    riskBandLabel := na

if showGuideLines
    if na(shelfLine)
        shelfLine := line.new(shelfBar, activeShelf, rightEdge, activeShelf, xloc = xloc.bar_index, extend = extend.none, color = color.new(stateColor, 0), width = 2)
    else
        line.set_xy1(shelfLine, shelfBar, activeShelf)
        line.set_xy2(shelfLine, rightEdge, activeShelf)
        line.set_color(shelfLine, color.new(stateColor, 0))
    if na(violationLine)
        violationLine := line.new(shelfBar, violationGuide, rightEdge, violationGuide, xloc = xloc.bar_index, extend = extend.none, color = color.new(dangerColor, 5), width = 1, style = line.style_dotted)
    else
        line.set_xy1(violationLine, shelfBar, violationGuide)
        line.set_xy2(violationLine, rightEdge, violationGuide)
        line.set_color(violationLine, color.new(dangerColor, 5))
else
    if not na(shelfLine)
        line.delete(shelfLine)
        shelfLine := na
    if not na(violationLine)
        line.delete(violationLine)
        violationLine := na

if showTargetGuide
    if na(targetLine)
        targetLine := line.new(bar_index - 2, targetEdge, rightEdge, targetEdge, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 20), width = 1)
    else
        line.set_xy1(targetLine, bar_index - 2, targetEdge)
        line.set_xy2(targetLine, rightEdge, targetEdge)
        line.set_color(targetLine, color.new(accentColor, 20))
else
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na

if barstate.islast and showRightSideTags
    tagX = rightEdge + rightTagOffsetBars
    tagGap = math.max(safeAtr * 0.38, syminfo.mintick * 20.0)
    shelfTagY = activeShelf
    violationTagY = planDir == 1 ? violationGuide - tagGap : violationGuide + tagGap
    roomTagY = targetEdge
    shelfTagText = "Shelf " + str.tostring(activeShelf, format.mintick) + "\n" + qualityState + " " + str.tostring(qualityScore)
    violationTagText = "Violation " + str.tostring(violationGuide, format.mintick) + "\nRisk " + violationRiskState
    roomTagText = "Room " + str.tostring(forwardRoomAtr, "#.00") + " ATR\n" + roomState
    f_delete_label(shelfTag)
    f_delete_label(violationTag)
    f_delete_label(roomTag)
    shelfTag := label.new(x = tagX, y = shelfTagY, text = shelfTagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(stateColor, 4), textcolor = headerText, size = f_text_size(labelSizeInput), textalign = text.align_center)
    violationTag := label.new(x = tagX, y = violationTagY, text = violationTagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(dangerColor, 8), textcolor = headerText, size = f_text_size(labelSizeInput), textalign = text.align_center)
    roomTag := label.new(x = tagX, y = roomTagY, text = roomTagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 10), textcolor = headerText, size = f_text_size(labelSizeInput), textalign = text.align_center)
else if barstate.islast
    f_delete_label(shelfTag)
    f_delete_label(violationTag)
    f_delete_label(roomTag)
    shelfTag := na
    violationTag := na
    roomTag := na

// -------------------------------------------------
// Labels and memory zones
// -------------------------------------------------
var int lastLabelBar = na
var string lastQualityState = ""
var array<label> eventLabels = array.new_label()

validEvent = confirmedBar and qualityState == "VALID" and lastQualityState != "VALID"
watchEvent = confirmedBar and qualityState == "WATCH" and lastQualityState != "WATCH"
weakEvent = confirmedBar and (qualityState == "WEAK" or qualityState == "FRAGILE" or qualityState == "DISTANT") and lastQualityState != qualityState
defendedEvent = confirmedBar and qualityState == "DEFENDED" and lastQualityState != "DEFENDED"
violationEvent = confirmedBar and qualityState == "VIOLATED" and lastQualityState != "VIOLATED"
labelCooldownReady = na(lastLabelBar) or bar_index - lastLabelBar >= usedLabelCooldown
contextReady = na(lastLabelBar) or bar_index - lastLabelBar >= usedContextSpacing
drawContext = showContextLabels and contextReady and (qualityState == "VALID" or qualityState == "WATCH" or qualityState == "FRAGILE" or qualityState == "DISTANT" or qualityState == "WEAK")
drawEventLabel = showEventLabels and labelCooldownReady and (validEvent or watchEvent or weakEvent or defendedEvent or violationEvent or drawContext)

if showMemoryZones and usedMemoryZones > 0 and defendedEvent
    memoryText = memoryTextMode == "Off" ? "" : memoryTextMode == "Detailed" ? "DEFENDED SHELF\nScore " + str.tostring(qualityScore) : "DEFENDED\nSHELF"
    memoryLeft = math.max(0, bar_index - 4)
    memoryRight = bar_index + math.max(10, int(math.round(projectionBars * 0.55)))
    memoryBox = box.new(left = memoryLeft, top = shelfTop, right = memoryRight, bottom = shelfBottom, xloc = xloc.bar_index, bgcolor = color.new(bullColor, 88), border_color = color.new(bullColor, 28), border_width = 2)
    array.push(memoryBoxes, memoryBox)
    f_trim_boxes(memoryBoxes, usedMemoryZones)
    if memoryTextMode != "Off"
        memoryLabel = label.new(x = int(math.round((memoryLeft + memoryRight) * 0.5)), y = (shelfTop + shelfBottom) * 0.5, text = memoryText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(color.rgb(13, 148, 136), 0), textcolor = headerText, size = f_text_size(labelSizeInput), textalign = text.align_center)
        array.push(memoryZoneLabels, memoryLabel)
        f_trim_labels(memoryZoneLabels, usedMemoryZones)

if drawEventLabel
    sideShort = planDir == 1 ? "L" : "S"
    stateShort = qualityState == "DEFENDED" ? "DEF" : qualityState == "VIOLATED" ? "VOID" : qualityState == "FRAGILE" ? "FRAG" : qualityState == "DISTANT" ? "DIST" : qualityState
    labelText = sideShort + " " + stateShort
    if showLabelScore and qualityState != "VIOLATED"
        labelText += " " + str.tostring(qualityScore)
    if showLabelDetails
        labelText += "\n" + violationRiskState + " | " + str.tostring(shelfDistanceAtr, "#.00") + " ATR"
    labelY = planDir == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    eventLabel = label.new(x = bar_index, y = labelY, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = planDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(stateColor, 8), textcolor = headerText, size = f_text_size(labelSizeInput))
    array.push(eventLabels, eventLabel)
    f_trim_labels(eventLabels, usedMaxLabels)
    lastLabelBar := bar_index

plotshape(showEventMarkers and validEvent and planDir == 1, title = "Long VALID Marker", style = shape.diamond, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showEventMarkers and validEvent and planDir == -1, title = "Short VALID Marker", style = shape.diamond, location = location.abovebar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showEventMarkers and defendedEvent and planDir == 1, title = "Long Defended Shelf Marker", style = shape.circle, location = location.belowbar, color = color.new(accentColor, 0), size = size.tiny)
plotshape(showEventMarkers and defendedEvent and planDir == -1, title = "Short Defended Shelf Marker", style = shape.circle, location = location.abovebar, color = color.new(accentColor, 0), size = size.tiny)
plotshape(showEventMarkers and violationEvent and planDir == 1, title = "Long Violation Marker", style = shape.xcross, location = location.belowbar, color = color.new(dangerColor, 0), size = size.tiny)
plotshape(showEventMarkers and violationEvent and planDir == -1, title = "Short Violation Marker", style = shape.xcross, location = location.abovebar, color = color.new(dangerColor, 0), size = size.tiny)

// -------------------------------------------------
// Confirmation-anchored proof (plannable shelves, Follow = held 1R toward forward room before violation)
// -------------------------------------------------
var int proofTotal = 0
var int proofFollow = 0
var int proofHold = 0
var int proofReact = 0
var int proofFlip = 0
var bool pEvalActive = false
var int pEvalDir = 0
var int pEvalStart = na
var float pEvalEntry = na
var float pEvalStop = na
var float pEvalTarget = na
var bool pReacted = false
var bool pFollowed = false
var bool pFlipped = false

bool anchorEvent = validEvent or defendedEvent
int proofWarmup = math.max(baselineLen, math.max(reactionLookback, targetLookback)) + 5
if barstate.isconfirmed and bar_index > proofWarmup
    if pEvalActive
        int heldBars = bar_index - pEvalStart
        float followDist = math.max(math.abs(pEvalTarget - pEvalEntry), syminfo.mintick)
        float favExc = pEvalDir * (close - pEvalEntry)
        if heldBars >= 1 and heldBars <= reactBars and favExc >= followDist * reactProgressPct / 100.0
            pReacted := true
        bool stopBreached = pEvalDir == 1 ? close < pEvalStop : close > pEvalStop
        bool hitTarget = heldBars >= 1 and favExc >= followDist
        if stopBreached
            pFlipped := true
        bool followNow = hitTarget and not pFlipped
        if followNow
            pFollowed := true
        bool naturalResolve = pFlipped or followNow or heldBars >= proofHorizonBars
        if naturalResolve or anchorEvent
            proofTotal := proofTotal + 1
            if pFollowed
                proofFollow := proofFollow + 1
            if not pFlipped
                proofHold := proofHold + 1
            if pReacted
                proofReact := proofReact + 1
            if pFlipped
                proofFlip := proofFlip + 1
            pEvalActive := false
    if anchorEvent and not pEvalActive
        pEvalActive := true
        pEvalDir := planDir
        pEvalEntry := close
        pEvalStop := violationGuide
        float pStopDist = math.max(math.abs(close - violationGuide), syminfo.mintick)
        float pRoomDist = math.max(forwardRoom, syminfo.mintick)
        float pFollowDist = math.max(math.min(pStopDist, pRoomDist), syminfo.mintick)
        pEvalTarget := close + planDir * pFollowDist
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false
        pFlipped := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelIsLight = panelThemeInput == "Light"
panelFrame = f_panel_border(panelIsLight)
panelSize = panelFontSizeInput
qualityRead = str.tostring(qualityScore) + " / " + qualityState
distanceRead = str.tostring(shelfDistanceAtr, "#.00") + " ATR / " + distanceState
structureRead = str.tostring(int(math.round(structureSupportScore))) + " / " + structureState
riskRead = violationRiskState + " / " + str.tostring(int(math.round(violationRisk)))
actionRead = actionState + " | " + dirText + " | " + roomState
shelfMapRead = str.tostring(activeShelf, format.mintick) + " / " + str.tostring(violationGuide, format.mintick)

string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) : "building"
string followTextPanel = proofTotal > 0 ? f_pct(followRate) : "--"
string holdTextPanel = proofTotal > 0 ? f_pct(holdRate) : "--"
string reactTextPanel = proofTotal > 0 ? f_pct(reactRate) : "--"
string flipTextPanel = proofTotal > 0 ? f_pct(flipRate) : "--"
color proofDefaultCol = f_panel_value(panelIsLight)
color followCol = proofTotal > 0 ? f_rate_color(followRate) : proofDefaultCol
color holdCol = proofTotal > 0 ? f_rate_color(holdRate) : proofDefaultCol
color reactCol = proofTotal > 0 ? f_rate_color(reactRate) : proofDefaultCol
color flipCol = proofTotal > 0 ? f_flip_color(flipRate) : proofDefaultCol

int panelRowCount = showProof ? 12 : 7
var table panel = na
var int prevPanelRows = -1
if showPanel and (na(panel) or prevPanelRows != panelRowCount)
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_position(panelLocationInput), 2, panelRowCount, bgcolor = panelBg, frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)
    prevPanelRows := panelRowCount
if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    prevPanelRows := -1

if showPanel and not na(panel) and barstate.islast
    table.set_position(panel, f_panel_position(panelLocationInput))
    table.set_frame_color(panel, panelFrame)
    table.set_border_color(panel, panelFrame)
    table.clear(panel, 0, 0, 1, panelRowCount - 1)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.cell(panel, 0, 0, "AG Pro Invalidation Quality Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelSize), text_halign = text.align_center)
    f_set_row(panel, 1, "Invalidation Quality", qualityRead, stateColor, panelIsLight, false, panelSize)
    f_set_row(panel, 2, "Distance", distanceRead, bufferScore >= 62.0 ? bullColor : neutralColor, panelIsLight, true, panelSize)
    f_set_row(panel, 3, "Structure Support", structureRead, structureSupportScore >= 60.0 ? bullColor : neutralColor, panelIsLight, false, panelSize)
    f_set_row(panel, 4, "Violation Risk", riskRead, violationRisk <= 28.0 ? bullColor : violationRisk <= 55.0 ? neutralColor : dangerColor, panelIsLight, true, panelSize)
    f_set_row(panel, 5, "Shelf / Violation", shelfMapRead, accentColor, panelIsLight, false, panelSize)
    f_set_row(panel, 6, "Action", actionRead, stateColor, panelIsLight, true, panelSize)
    if showProof
        rowBgProof = f_panel_bg(panelIsLight, false)
        table.cell(panel, 0, 7, "Proof @ Confirm", text_color = accentColor, bgcolor = rowBgProof, text_size = f_text_size(panelSize))
        table.cell(panel, 1, 7, proofSampleText, text_color = f_panel_label(panelIsLight), bgcolor = rowBgProof, text_size = f_text_size(panelSize), text_halign = text.align_right)
        f_set_row(panel, 8, "Follow Rate", followTextPanel, followCol, panelIsLight, true, panelSize)
        f_set_row(panel, 9, "Hold Rate", holdTextPanel, holdCol, panelIsLight, false, panelSize)
        f_set_row(panel, 10, "React Rate", reactTextPanel, reactCol, panelIsLight, true, panelSize)
        f_set_row(panel, 11, "Flip Rate", flipTextPanel, flipCol, panelIsLight, false, panelSize)

// -------------------------------------------------
// Alerts And Hidden Exports
// -------------------------------------------------
alertcondition(alertShelfStates and validEvent, title = "Invalidation Quality VALID", message = "Invalidation Quality Planner: VALID shelf context is active. This is an attention marker, not a trade instruction.")
alertcondition(alertShelfStates and watchEvent, title = "Invalidation Quality WATCH", message = "Invalidation Quality Planner: WATCH state is active. The invalidation shelf is improving but not yet fully clean.")
alertcondition(alertShelfStates and defendedEvent, title = "Invalidation Shelf Defended", message = "Invalidation Quality Planner: price tested and defended the active invalidation shelf. Review broader context.")
alertcondition(alertShelfStates and weakEvent, title = "Invalidation Shelf Weak", message = "Invalidation Quality Planner: the active invalidation shelf is weak, fragile, or too distant for clean planning context.")
alertcondition(alertShelfStates and violationEvent, title = "Invalidation Shelf Violated", message = "Invalidation Quality Planner: price crossed the active violation guide. Rebuild the planning context.")

plot(qualityScore, title = "IQP Quality Score", display = display.none)
plot(structureSupportScore, title = "IQP Structure Support Score", display = display.none)
plot(reactionMemoryScore, title = "IQP Reaction Memory Score", display = display.none)
plot(bufferScore, title = "IQP Shelf Distance Score", display = display.none)
plot(violationRisk, title = "IQP Violation Risk", display = display.none)
plot(roomScore, title = "IQP Forward Room Score", display = display.none)
plot(followRate, title = "IQP Follow Rate", display = display.none)
plot(holdRate, title = "IQP Hold Rate", display = display.none)
plot(reactRate, title = "IQP React Rate", display = display.none)
plot(flipRate, title = "IQP Flip Rate", display = display.none)

if confirmedBar
    lastQualityState := qualityState
````

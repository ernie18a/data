# Gap Fill Reaction Planner [AGPro Series]

- url: https://www.tradingview.com/script/gac9k3X6-Gap-Fill-Reaction-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;64186cf42919412382fcf7952320c5ee
- version: 5.0

## Description

Gap Fill Reaction Planner [AGPro Series]

🧠 Core Idea

Is this gap reaction actually ready for planning, or is it just another rectangle on the chart?


📌 Overview / What it does

Gap Fill Reaction Planner [AGPro Series] is a planner-style price action tool built around gap fill behavior, reaction quality, and execution readiness. Instead of simply drawing gap zones, it evaluates whether the active gap reaction has enough structure to become a measurable plan.

The script detects gap support and gap resistance zones, tracks fill progress, classifies reaction state, and converts the active setup into a 0-100 readiness score. It also maps a live entry reference, invalidation level, target projection, and estimated R multiple so the user can review the structure as a plan rather than as an isolated signal.

It does not automate trades, predict future price, or replace independent analysis. Its purpose is to organize gap reaction context into a cleaner decision framework.


🎯 Purpose & Design Philosophy

This script was built to move beyond passive gap marking. A normal gap indicator can show where a gap exists, but it does not answer the questions that matter before a trade idea is considered:

Is the reaction valid?
How strong is the setup?
Where is the invalidation?
Where is the target?
What should the trader watch next?

Gap Fill Reaction Planner was designed for traders who want a structured workflow around opening gaps, continuous-market reaction bands, partial fills, full fills, rejection behavior, and acceptance risk. The mindset is not "take every gap." The mindset is "measure the reaction first."


⚡ Why This Script Is Different

Most gap tools focus on detection. They draw every gap, imbalance, or separation zone and leave the decision process to the user.

This script does NOT act as a generic gap highlighter, generic support/resistance map, or broad imbalance catalog.

Instead, it treats each gap as a planning object. Every active zone is evaluated through fill depth, reaction state, volatility context, participation, age, and structural validity. The panel then translates that context into readiness, next action, invalidation, target, and risk/reward information.

That planner layer is the difference. The script helps the user decide whether a gap reaction deserves attention, not merely whether a gap exists.


⚙️ Methodology

1. Context Detection
The script first searches for gap reaction zones. It prioritizes classic open-to-previous-close gaps, then supports adaptive reaction bands for continuous markets where clean opening gaps may be rare.

2. Reference Mapping
Each detected zone receives a fixed-length rectangular band. The zone is not dragged forward forever; it remains anchored to its origin so old structures do not distort the current chart. Thin zones are displayed with a minimum visual height so the chart keeps a cleaner, more professional planning layer.

3. Reaction Evaluation
The engine tracks fill percentage, partial fill, full fill, rejection, and acceptance. Rejection behavior is treated differently from simple fill behavior because a filled gap and a rejected gap communicate different planning context.

4. Planner Scoring
The readiness score combines gap size, fill quality, reaction behavior, volatility participation, and recency. The score is normalized from 0 to 100.

5. Risk / Target Projection
For the active planner zone, the script calculates an invalidation reference beyond the far side of the gap and projects a target using the selected R multiple.

6. Visual Output
The chart shows gap zones, centered zone labels, optional fill progress, planner labels, and active plan levels. The panel summarizes the decision state.


🗺️ How to Read the Chart

Zones
Gap Support zones represent upward gap reactions that may act as support-style planning areas.
Gap Resistance zones represent downward gap reactions that may act as resistance-style planning areas.

Zone Labels
Focused zones can display a centered label showing the zone role, state, and readiness score. This keeps the chart readable without turning every historical zone into a text cluster.

Colors
Bullish planner context uses the AGPro green state color.
Bearish planner context uses the AGPro pink state color.
Neutral or unfinished context uses restrained secondary colors.

Panel
The panel shows readiness, next action, plan side, gap size, fill/state, invalidation, target/R, and bias.

Plan Levels
When an active planner zone exists, the script can display entry reference, invalidation, and target lines.


🚦 Signals & States

• Fresh → A new gap zone exists but has not reached meaningful fill depth.

• Partial Fill → Price has returned into the gap enough to begin reaction monitoring.

• Rejected → Price filled part of the gap and then closed back away from the zone.

• Full Fill → The gap has reached the full-fill threshold and becomes more neutral.

• Accepted → Price closed beyond the far boundary of the gap, meaning the zone has lost its original reaction role.

• Planner Ready → A rejection setup reached the configured readiness threshold.


🔔 Alerts Logic

New Gap Support Zone
Triggers when a bullish gap support planning zone is created.

New Gap Resistance Zone
Triggers when a bearish gap resistance planning zone is created.

Gap Partial Fill
Triggers when a tracked zone reaches the partial-fill threshold.

Gap Full Fill
Triggers when a tracked zone reaches the full-fill threshold.

Gap Planner Ready
Triggers when a rejection setup reaches the readiness score threshold.

Gap Acceptance
Triggers when price accepts beyond the far side of the gap.

Alerts are attention markers and workflow prompts. They are not trade instructions.


🧩 Confluence Logic

The planner score becomes stronger when multiple conditions align:

• The gap has enough ATR-normalized size
• Fill depth is meaningful but not exhausted
• Reaction behavior confirms away from the zone
• Current volatility and participation support the reaction
• The zone is recent enough to remain relevant

When these pieces align, the gap becomes a stronger planning candidate.


📊 When to Use

• After large opening gaps
• During pullbacks into gap support or gap resistance
• Around partial fill and rejection behavior
• In trending markets where gaps create reaction shelves
• In volatile markets where gap fill behavior matters
• On crypto and FX charts where adaptive reaction bands may help continuous-market analysis


⚠️ When NOT to Use

• Extremely low-liquidity symbols
• Very noisy micro timeframes
• Market conditions where spread, slippage, or data quality is poor
• When the chart is moving too fast for structured planning
• When a trader has not defined broader market context


🎛️ Key Inputs

Detection Mode
Controls whether the script uses only classic open gaps or adaptive reaction bands.

Minimum Gap Size
Filters out small gaps using ATR normalization.

Readiness Threshold
Defines the minimum score required for a planner-ready label.

Target Multiple (R)
Projects the target from the current reference price using the invalidation distance.

Invalidation Buffer
Adds ATR-based spacing beyond the far side of the gap zone.

Zone Right Extension
Controls how far each zone projects from its origin.

Panel / Label Settings
Control panel visibility, panel theme, panel location, and font sizes.


🖥️ Interface & Visual Design

The interface is built for quick decision review. The panel provides the planner summary, while the chart emphasizes the most important structural elements: premium-height zones, focused centered labels, action labels, and active plan levels.

The visual hierarchy is intentionally clean. Zones explain context, labels explain state, and the panel explains what to do next from an analytical standpoint.


🧪 Practical Usage Workflow

1. Read the panel readiness score.
2. Check whether the next action is monitor, wait, plan, or stand aside.
3. Review the active gap zone and its centered label.
4. Compare fill percentage with the reaction state.
5. Review invalidation and target levels.
6. Confirm the idea with broader market context before acting.


🔍 Interpretation Guidelines

A high score does not mean certainty. It means the gap reaction has stronger planning structure.

A partial fill means price has started interacting with the gap, but reaction quality still matters.

A rejection state is more meaningful when it occurs with strong score, clean invalidation, and acceptable target distance.

An accepted zone should usually be treated as a failed reaction context rather than an active planning area.


🚫 What This Script Is NOT

This script is not a prediction engine.
This script is not an automated trading system.
This script is not a financial advice tool.
This script does not provide guaranteed outcomes.
This script does not replace risk management, trade review, or independent confirmation.


⚠️ Limitations & Transparency

Gap behavior can change significantly across symbols and timeframes.

Continuous markets may produce fewer classic opening gaps, which is why the script includes adaptive detection modes.

Volatility expansion can make targets and invalidation levels wider.

Low-liquidity environments may reduce the reliability of reaction labels and score readings.

No rule-based tool can fully account for news events, sudden liquidity shifts, or execution quality.


🧠 Market Context Notes

Gap reactions are often more useful when they are read together with trend structure, volatility, session behavior, and liquidity context. A gap zone is not automatically important because it exists. It becomes more useful when price returns to it, reacts clearly, and produces a measurable planning structure.


🧾 Use Case Examples

When price returns into a Gap Support zone and rejects upward with a high readiness score, the panel can help review whether invalidation and target structure are measurable.

When price fills a Gap Resistance zone and accepts above it, the script marks the context as acceptance rather than treating the zone as a still-valid resistance area.

When the panel shows low readiness, the script is communicating that the structure may exist visually but is not yet a strong planner candidate.


🧱 System Philosophy

AGProLabs tools are built around structured interpretation. The goal is not to add more noise to the chart. The goal is to convert raw market behavior into a cleaner decision framework that traders can review with discipline.


🔐 Non-Promise Statement

No indicator can remove uncertainty.
No score can guarantee a result.
No planner can replace the trader's responsibility to manage risk.


📉 Risk Disclosure

Trading involves risk. This script is provided for educational and analytical use only. It does not provide financial advice, investment advice, or guaranteed trading outcomes. Users remain responsible for their own research, risk management, position sizing, and execution decisions.


📚 Educational Note

The best use of this script is not to chase every gap. The best use is to slow the decision process down, measure the reaction, and decide whether the setup is structured enough to deserve attention.

## Source Code

````pine
// -------------------------------------------------
// Gap Fill Reaction Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Gap Fill Reaction Planner converts gap fill behavior into a structured
// decision-support map for gap trading, opening gap reaction, gap rejection,
// acceptance, invalidation, target projection, and readiness scoring. It
// detects gap reaction zones, tracks fill progress, scores reaction quality,
// and summarizes the next action state without becoming a generic gap scanner.
// V1.5 completes the visual identity layer so every visible gap zone and every
// active Entry, Invalidation, and Target reference remains explicitly labeled.
// The confirmation-anchored proof model and core gap reaction logic are unchanged.
// -------------------------------------------------

//@version=6
indicator("Gap Fill Reaction Planner [AGPro Series]",
     shorttitle       = "AG Pro GFP",
     overlay          = true,
     max_boxes_count  = 220,
     max_labels_count = 180,
     max_lines_count  = 80)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
// Brand
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
// Panel
panelBg       = color.rgb(15, 23, 42)
panelBorder   = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
// States
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
const string TT_PRESET = "Selects the default operating profile. Daily Gap Plan is cleaner for publication charts. Intraday Active tracks more zones. Custom uses the raw inputs below."
const string TT_ATR_LEN = "ATR normalizes gap size, invalidation distance, target projection, and label offset across different symbols."
const string TT_DETECTION_MODE = "Adaptive Reaction Gaps uses classic opens first, then body, wick, and controlled close-displacement bands when needed. Balanced Reaction Gaps excludes the displacement fallback."
const string TT_MIN_GAP = "Minimum gap band height as a multiple of ATR. Higher values keep only larger reaction zones."
const string TT_CONFIRM_GAP = "Registers new gap zones only after the bar closes. This keeps the planner stable for publication-style chart reading."
const string TT_GAP_SPACING = "Minimum number of bars between newly created gap zones. Higher values reduce clusters."
const string TT_REJECT_FILL = "Minimum fill percentage required before a reaction can qualify as a rejection setup."
const string TT_FULL_FILL = "Fill percentage required to mark the zone as fully filled and no longer fresh."
const string TT_TARGET_R = "Target projection based on the current reference price and the invalidation distance. This creates a planner-style risk-to-target map."
const string TT_INVALIDATION = "ATR buffer placed beyond the far edge of the gap zone to calculate the invalidation reference."
const string TT_SCORE_READY = "Minimum readiness score required before a confirmed rejection is labeled as a planner-quality event."
const string TT_MAX_GAPS = "Maximum number of recent gap zones kept on the chart."
const string TT_EXTEND = "Number of bars each zone projects to the right from its origin. Zones are fixed-length and are not dragged forward forever."
const string TT_SHOW_RESOLVED = "When disabled, fully filled and accepted zones are hidden so active planner zones remain dominant."
const string TT_SHOW_ZONES = "Shows the rectangular gap reaction zones."
const string TT_SHOW_FILL = "Shows the filled portion inside active zones."
const string TT_ZONE_HEIGHT = "Adds a minimum display height to thin zones. The planner logic still uses the original gap boundaries, while the chart shows a more readable premium zone."
const string TT_SHOW_ZONE_LABELS = "Shows the full state, score, and fill details inside each visible zone. When disabled, every visible zone still keeps a compact identity label so no rectangle is left unexplained."
const string TT_ZONE_LABEL_MODE = "Controls the preferred zone-label behavior. Visible Zones is the publication default. When centered zone labels are enabled, every visible zone keeps its own badge so no displayed zone is left unexplained."
const string TT_SHOW_ACTION_LABELS = "Shows compact planner labels when a rejection setup reaches the required readiness score."
const string TT_ACTION_COOLDOWN = "Minimum number of bars between planner action labels."
const string TT_ACTION_CAP = "Maximum number of historical planner action labels kept on the chart."
const string TT_SHOW_PLAN = "Shows the active planner map. Every visible entry, invalidation, and target line is paired with a right-edge identity tag."
const string TT_PLAN_VALUES = "Adds the live price value to each mandatory Entry, Invalidation, and Target identity tag."
const string TT_LABEL_SIZE = "Controls all chart label sizes created by the script. Normal is the default publication setting."
const string TT_PANEL_SHOW = "Shows or hides the AG Pro summary panel."
const string TT_PANEL_LOCATION = "Selects where the panel appears on the chart."
const string TT_PANEL_THEME = "Controls the panel color theme."
const string TT_PANEL_SIZE = "Controls the font size used inside the panel. Normal is the default publication setting."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
const string GROUP_DETECTION = "Gap Detection"
const string GROUP_PLANNER = "Planner Logic"
const string GROUP_VISUAL = "Visuals"
const string GROUP_PANEL = "Panel"
const string GROUP_ALERTS = "Alerts"

enginePreset = input.string("Daily Gap Plan", "Engine Preset", options = ["Daily Gap Plan", "Intraday Active", "Custom"], group = GROUP_DETECTION, tooltip = TT_PRESET)
atrLength = input.int(14, "ATR Length", minval = 1, group = GROUP_DETECTION, tooltip = TT_ATR_LEN)
detectionModeInput = input.string("Adaptive Reaction Gaps", "Detection Mode", options = ["Adaptive Reaction Gaps", "Balanced Reaction Gaps", "Classic Open Gap", "Classic + Body Separation", "Aggressive Displacement"], group = GROUP_DETECTION, tooltip = TT_DETECTION_MODE)
minGapAtr = input.float(0.12, "Minimum Gap Size (x ATR)", minval = 0.01, maxval = 5.00, step = 0.01, group = GROUP_DETECTION, tooltip = TT_MIN_GAP)
confirmGapOnClose = input.bool(true, "Confirm Gap on Bar Close", group = GROUP_DETECTION, tooltip = TT_CONFIRM_GAP)
gapSpacingBars = input.int(10, "Gap Cooldown Bars", minval = 0, maxval = 100, group = GROUP_DETECTION, tooltip = TT_GAP_SPACING)

rejectionMinFill = input.float(25.0, "Rejection Min Fill (%)", minval = 1.0, maxval = 95.0, step = 1.0, group = GROUP_PLANNER, tooltip = TT_REJECT_FILL)
fullFillThreshold = input.float(99.0, "Full Fill Threshold (%)", minval = 50.0, maxval = 100.0, step = 0.5, group = GROUP_PLANNER, tooltip = TT_FULL_FILL)
targetMultiple = input.float(1.50, "Target Multiple (R)", minval = 0.25, maxval = 5.00, step = 0.25, group = GROUP_PLANNER, tooltip = TT_TARGET_R)
invalidationBufferAtr = input.float(0.15, "Invalidation Buffer (x ATR)", minval = 0.00, maxval = 2.00, step = 0.05, group = GROUP_PLANNER, tooltip = TT_INVALIDATION)
readinessThreshold = input.int(60, "Readiness Threshold", minval = 1, maxval = 100, group = GROUP_PLANNER, tooltip = TT_SCORE_READY)
maxTrackedGaps = input.int(5, "Max Tracked Zones", minval = 1, maxval = 20, group = GROUP_PLANNER, tooltip = TT_MAX_GAPS)
zoneRightBars = input.int(44, "Zone Right Extension", minval = 10, maxval = 300, group = GROUP_PLANNER, tooltip = TT_EXTEND)
showResolvedBands = input.bool(false, "Show Resolved Zones", group = GROUP_PLANNER, tooltip = TT_SHOW_RESOLVED)

showGapZones = input.bool(true, "Show Gap Zones", group = GROUP_VISUAL, tooltip = TT_SHOW_ZONES)
showFillProgress = input.bool(true, "Show Fill Progress", group = GROUP_VISUAL, tooltip = TT_SHOW_FILL)
minZoneHeightAtr = input.float(0.24, "Minimum Visual Zone Height (x ATR)", minval = 0.00, maxval = 2.00, step = 0.01, group = GROUP_VISUAL, tooltip = TT_ZONE_HEIGHT)
showZoneLabels = input.bool(true, "Show Detailed Zone Labels", group = GROUP_VISUAL, tooltip = TT_SHOW_ZONE_LABELS)
zoneLabelModeInput = input.string("Visible Zones", "Zone Label Mode", options = ["Visible Zones", "Focused Zones", "Latest Active", "Rejections Only"], group = GROUP_VISUAL, tooltip = TT_ZONE_LABEL_MODE)
showActionLabels = input.bool(true, "Show Planner Action Labels", group = GROUP_VISUAL, tooltip = TT_SHOW_ACTION_LABELS)
actionLabelCooldown = input.int(30, "Planner Label Cooldown", minval = 0, maxval = 300, group = GROUP_VISUAL, tooltip = TT_ACTION_COOLDOWN)
maxActionLabels = input.int(7, "Max Planner Labels", minval = 1, maxval = 40, group = GROUP_VISUAL, tooltip = TT_ACTION_CAP)
showPlanLevels = input.bool(true, "Show Active Plan Levels", group = GROUP_VISUAL, tooltip = TT_SHOW_PLAN)
showPlanLevelValues = input.bool(true, "Show Values in Plan Tags", group = GROUP_VISUAL, tooltip = TT_PLAN_VALUES)
labelFontInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = GROUP_VISUAL, tooltip = TT_LABEL_SIZE)
labelOffsetAtr = input.float(0.55, "Label Offset (x ATR)", minval = 0.05, maxval = 2.00, step = 0.05, group = GROUP_VISUAL, tooltip = "Moves action labels away from candles by an ATR-normalized distance.")

showPanel = input.bool(true, "Show Panel", group = GROUP_PANEL, tooltip = TT_PANEL_SHOW)
panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group = GROUP_PANEL, tooltip = TT_PANEL_LOCATION)
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = GROUP_PANEL, tooltip = TT_PANEL_THEME)
panelFontInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = GROUP_PANEL, tooltip = TT_PANEL_SIZE)

alertNewGaps = input.bool(true, "Alert on New Gap Zones", group = GROUP_ALERTS,
     tooltip = "Enables alerts when the planner creates a new support or resistance gap reaction zone.")
alertPlannerReady = input.bool(true, "Alert on Planner Ready", group = GROUP_ALERTS,
     tooltip = "Enables alerts when a gap reaction reaches the readiness threshold.")
alertGapResolution = input.bool(true, "Alert on Fill or Acceptance", group = GROUP_ALERTS,
     tooltip = "Enables alerts when a tracked gap reaches full fill or acceptance.")

const string GROUP_PROOF = "Proof"
showProof = input.bool(true, "Show Proof Layer", group = GROUP_PROOF, tooltip = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across planner-ready gap reactions on the current symbol and timeframe. Follow means a ready reaction reached its projected target before the invalidation level. These are historical outcome rates, not predictions.")
proofHorizonBars = input.int(30, "Proof Horizon Bars", minval = 4, maxval = 300, group = GROUP_PROOF, tooltip = "Maximum number of bars each ready reaction is tracked for the proof measurement before it resolves at its current outcome.")
reactBars = input.int(3, "Reaction Window Bars", minval = 1, maxval = 40, group = GROUP_PROOF, tooltip = "Number of bars after a ready reaction used to detect an immediate favorable follow-through reaction.")
reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = GROUP_PROOF, tooltip = "Minimum favorable progress toward the projected target, within the reaction window, required to count as an early React.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_position(string locationInput) =>
    switch locationInput
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Right" => position.middle_right
        "Middle Center" => position.middle_center
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Center" => position.bottom_center
        "Bottom Left" => position.bottom_left
        => position.top_right

f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_state_text(int state) =>
    switch state
        1 => "Partial Fill"
        2 => "Rejected"
        3 => "Full Fill"
        4 => "Accepted"
        => "Fresh"

f_action_text(int direction, int state, float scoreValue, int threshold) =>
    if state == 4
        "Stand Aside"
    else if state == 3
        "Filled / Neutral"
    else if state == 2 and scoreValue >= threshold
        direction == 1 ? "Review Bull Reaction" : "Review Bear Reaction"
    else if state == 2
        "Weak Reaction"
    else if state == 1
        "Wait for Reaction"
    else
        "Monitor Fill"

f_state_color(int state, int direction, float scoreValue, int threshold) =>
    if state == 2 and scoreValue >= threshold
        direction == 1 ? bullColor : bearColor
    else
        switch state
            1 => neutralColor
            2 => neutralColor
            3 => panelLabelCol
            4 => direction == 1 ? bearColor : bullColor
            => accentColor

f_zone_transparency(int state) =>
    switch state
        1 => 82
        2 => 76
        3 => 94
        4 => 94
        => 86

f_fill_percent(int direction, float gapTopValue, float gapBottomValue) =>
    gapHeightValue = math.max(gapTopValue - gapBottomValue, syminfo.mintick)
    rawFill = direction == 1 ? (gapTopValue - low) / gapHeightValue : (high - gapBottomValue) / gapHeightValue
    f_clamp(rawFill, 0.0, 1.0) * 100.0

f_readiness_score(int state, float fillPercent, float gapAtr, float ageRatio, float barRangeAtr, float volumeFactor, bool zoneTouched) =>
    sizeScore = f_clamp(gapAtr / 0.85, 0.0, 1.0) * 20.0
    fillShape = fillPercent >= rejectionMinFill ? 20.0 - math.abs(fillPercent - 58.0) * 0.25 : 5.0
    fillScore = f_clamp(fillShape, 0.0, 20.0)
    reactionScore = state == 2 ? 30.0 : zoneTouched ? 18.0 : state == 1 ? 14.0 : 6.0
    participationScore = f_clamp((f_clamp(barRangeAtr / 1.35, 0.0, 1.0) * 0.60) + (volumeFactor * 0.40), 0.0, 1.0) * 15.0
    recencyScore = f_clamp(1.0 - ageRatio, 0.0, 1.0) * 15.0
    math.round(f_clamp(sizeScore + fillScore + reactionScore + participationScore + recencyScore, 0.0, 100.0))

f_grade(float scoreValue) =>
    scoreValue >= 86 ? "A+" : scoreValue >= 76 ? "A" : scoreValue >= 66 ? "B" : scoreValue >= 54 ? "C" : "D"

f_zone_state_title(int state) =>
    switch state
        1 => "Fill Watch"
        2 => "Reaction"
        3 => "Filled"
        4 => "Accepted"
        => "Fresh"

f_zone_label_text(int direction, int state, float scoreValue, float fillPercent) =>
    zoneText = direction == 1 ? "Support Gap" : "Resistance Gap"
    stateText = f_zone_state_title(state)
    zoneText + "\n" + stateText + " " + str.tostring(math.round(scoreValue)) + " " + f_grade(scoreValue) + "\n" + str.tostring(fillPercent, "#") + "% filled"

f_bias_text(int direction, int state, float scoreValue, int threshold) =>
    if state == 4
        direction == 1 ? "Bearish acceptance" : "Bullish acceptance"
    else if state == 3
        "Filled / neutral"
    else if state == 2 and scoreValue >= threshold
        direction == 1 ? "Bullish planner edge" : "Bearish planner edge"
    else if state == 2
        "Reaction needs context"
    else
        direction == 1 ? "Support fill watch" : "Resistance fill watch"

f_panel_bg(bool isLight, bool alt) =>
    isLight ? (alt ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)) : (alt ? color.rgb(19, 29, 48) : panelBg)

f_panel_border(bool isLight) =>
    isLight ? color.rgb(203, 213, 225) : panelBorder

f_panel_label_color(bool isLight) =>
    isLight ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value_color(bool isLight) =>
    isLight ? color.rgb(15, 23, 42) : panelValueCol

f_rate_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(float value) =>
    value >= 55.0 ? bullColor : value >= 40.0 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30.0 ? bullColor : value <= 55.0 ? neutralColor : bearColor

f_delete_label(label item) =>
    if not na(item)
        label.delete(item)

// -------------------------------------------------
// Presets
// -------------------------------------------------
dailyPreset = enginePreset == "Daily Gap Plan"
activePreset = enginePreset == "Intraday Active"
usedMinGapAtr = dailyPreset ? math.max(minGapAtr, 0.14) : activePreset ? math.min(minGapAtr, 0.10) : minGapAtr
usedGapSpacingBars = dailyPreset ? math.max(gapSpacingBars, 12) : activePreset ? math.max(gapSpacingBars, 6) : gapSpacingBars
usedMaxTrackedGaps = dailyPreset ? math.min(maxTrackedGaps, 5) : activePreset ? math.min(maxTrackedGaps, 7) : maxTrackedGaps
usedActionCooldown = dailyPreset ? math.max(actionLabelCooldown, 30) : activePreset ? math.max(actionLabelCooldown, 18) : actionLabelCooldown
usedZoneRightBars = dailyPreset ? math.max(zoneRightBars, 44) : activePreset ? math.max(zoneRightBars, 34) : zoneRightBars

// -------------------------------------------------
// State Storage
// -------------------------------------------------
var array<box> gapBoxes = array.new_box()
var array<box> fillBoxes = array.new_box()
var array<label> zoneLabels = array.new_label()
var array<label> actionLabels = array.new_label()
var array<float> gapTops = array.new_float()
var array<float> gapBottoms = array.new_float()
var array<float> gapMaxFills = array.new_float()
var array<float> gapScores = array.new_float()
var array<int> gapDirections = array.new_int()
var array<int> gapStates = array.new_int()
var array<int> gapBirthBars = array.new_int()
var int lastCreatedGapBar = na
var int lastActionLabelBar = na

// -------------------------------------------------
// Gap Detection
// -------------------------------------------------
atrValue = ta.atr(atrLength)
atrSafe = math.max(atrValue, syminfo.mintick)
volumeAverage = ta.sma(volume, 20)
hasPrevBar = bar_index > 0 and not na(close[1]) and not na(atrValue)
gapDistance = hasPrevBar ? open - close[1] : 0.0
minGapDistance = atrSafe * usedMinGapAtr
controlledDisplacementDistance = atrSafe * math.max(usedMinGapAtr * 4.0, 0.55)
canCreateGap = not confirmGapOnClose or barstate.isconfirmed

useBodySeparation = detectionModeInput == "Adaptive Reaction Gaps" or detectionModeInput == "Balanced Reaction Gaps" or detectionModeInput == "Classic + Body Separation" or detectionModeInput == "Aggressive Displacement"
useWickSeparation = detectionModeInput == "Adaptive Reaction Gaps" or detectionModeInput == "Balanced Reaction Gaps" or detectionModeInput == "Aggressive Displacement"
useDisplacementGap = detectionModeInput == "Adaptive Reaction Gaps" or detectionModeInput == "Aggressive Displacement"

currentBodyHigh = math.max(open, close)
currentBodyLow = math.min(open, close)
previousBodyHigh = hasPrevBar ? math.max(open[1], close[1]) : 0.0
previousBodyLow = hasPrevBar ? math.min(open[1], close[1]) : 0.0

classicGapUp = hasPrevBar and gapDistance >= minGapDistance
classicGapDown = hasPrevBar and gapDistance <= -minGapDistance
wickGapUp = useWickSeparation and not classicGapUp and hasPrevBar and low - high[1] >= minGapDistance
wickGapDown = useWickSeparation and not classicGapDown and hasPrevBar and low[1] - high >= minGapDistance
bodyGapUp = useBodySeparation and not classicGapUp and not wickGapUp and hasPrevBar and currentBodyLow - previousBodyHigh >= minGapDistance
bodyGapDown = useBodySeparation and not classicGapDown and not wickGapDown and hasPrevBar and previousBodyLow - currentBodyHigh >= minGapDistance
displacementGapUp = useDisplacementGap and not classicGapUp and not wickGapUp and not bodyGapUp and hasPrevBar and close > high[1] and close - close[1] >= controlledDisplacementDistance
displacementGapDown = useDisplacementGap and not classicGapDown and not wickGapDown and not bodyGapDown and hasPrevBar and close < low[1] and close[1] - close >= controlledDisplacementDistance
gapSpacingOk = na(lastCreatedGapBar) or (bar_index != lastCreatedGapBar and bar_index - lastCreatedGapBar >= usedGapSpacingBars)

isNewGapUp = hasPrevBar and canCreateGap and (classicGapUp or wickGapUp or bodyGapUp or displacementGapUp)
isNewGapDown = hasPrevBar and canCreateGap and (classicGapDown or wickGapDown or bodyGapDown or displacementGapDown)
isNewGap = (isNewGapUp or isNewGapDown) and gapSpacingOk

newGapUpEvent = false
newGapDownEvent = false
partialFillEvent = false
fullFillEvent = false
plannerReadyEvent = false
acceptanceEvent = false

if isNewGap
    newDirection = isNewGapUp ? 1 : -1
    useClassicCoordinates = newDirection == 1 ? classicGapUp : classicGapDown
    useWickCoordinates = newDirection == 1 ? wickGapUp : wickGapDown
    useBodyCoordinates = newDirection == 1 ? bodyGapUp : bodyGapDown
    float newTop = na
    float newBottom = na
    if useClassicCoordinates
        newTop := math.max(open, close[1])
        newBottom := math.min(open, close[1])
    else if useWickCoordinates
        if newDirection == 1
            newTop := low
            newBottom := high[1]
        else
            newTop := low[1]
            newBottom := high
    else if useBodyCoordinates
        if newDirection == 1
            newTop := currentBodyLow
            newBottom := previousBodyHigh
        else
            newTop := previousBodyLow
            newBottom := currentBodyHigh
    else
        displacementHeight = math.max(minGapDistance, math.min(math.abs(close - close[1]) * 0.35, atrSafe * 0.65))
        if newDirection == 1
            newTop := close[1] + displacementHeight
            newBottom := close[1]
        else
            newTop := close[1]
            newBottom := close[1] - displacementHeight

    if not na(newTop) and not na(newBottom) and newTop > newBottom
        newBaseColor = newDirection == 1 ? bullColor : bearColor
        newGapBox = box.new(left = bar_index, top = newTop, right = bar_index + usedZoneRightBars, bottom = newBottom,
             xloc = xloc.bar_index,
             border_color = color.new(newBaseColor, 0),
             border_width = 1,
             bgcolor = showGapZones ? color.new(newBaseColor, 86) : color.new(newBaseColor, 100))
        newFillBox = box.new(left = bar_index, top = newTop, right = bar_index + usedZoneRightBars, bottom = newBottom,
             xloc = xloc.bar_index,
             border_color = color.new(accentColor, 100),
             border_width = 1,
             bgcolor = color.new(accentColor, 100))
        label emptyZoneLabel = na
        array.push(gapBoxes, newGapBox)
        array.push(fillBoxes, newFillBox)
        array.push(zoneLabels, emptyZoneLabel)
        array.push(gapTops, newTop)
        array.push(gapBottoms, newBottom)
        array.push(gapMaxFills, 0.0)
        array.push(gapScores, 0.0)
        array.push(gapDirections, newDirection)
        array.push(gapStates, 0)
        array.push(gapBirthBars, bar_index)
        lastCreatedGapBar := bar_index
        newGapUpEvent := newDirection == 1
        newGapDownEvent := newDirection == -1

while array.size(gapBoxes) > usedMaxTrackedGaps
    removedGapBox = array.shift(gapBoxes)
    removedFillBox = array.shift(fillBoxes)
    removedZoneLabel = array.shift(zoneLabels)
    box.delete(removedGapBox)
    box.delete(removedFillBox)
    f_delete_label(removedZoneLabel)
    array.shift(gapTops)
    array.shift(gapBottoms)
    array.shift(gapMaxFills)
    array.shift(gapScores)
    array.shift(gapDirections)
    array.shift(gapStates)
    array.shift(gapBirthBars)

// -------------------------------------------------
// Gap Lifecycle And Scoring
// -------------------------------------------------
labelSize = f_size(labelFontInput)
gapCount = array.size(gapBoxes)

bool proofArmRequested = false
int proofArmDir = 0
float proofArmEntry = na
float proofArmInvalid = na

if gapCount > 0
    for idx = 0 to gapCount - 1
        activeGapBox = array.get(gapBoxes, idx)
        activeFillBox = array.get(fillBoxes, idx)
        activeTop = array.get(gapTops, idx)
        activeBottom = array.get(gapBottoms, idx)
        activeHeight = math.max(activeTop - activeBottom, syminfo.mintick)
        storedFill = array.get(gapMaxFills, idx)
        activeDirection = array.get(gapDirections, idx)
        priorState = array.get(gapStates, idx)
        birthBar = array.get(gapBirthBars, idx)
        rightEdge = birthBar + usedZoneRightBars
        canEvaluateFill = bar_index > birthBar and bar_index <= rightEdge
        liveFill = canEvaluateFill ? f_fill_percent(activeDirection, activeTop, activeBottom) : storedFill
        displayFill = math.max(storedFill, liveFill)
        confirmedFill = barstate.isconfirmed and canEvaluateFill ? displayFill : storedFill
        nextState = priorState
        zoneTouched = high >= activeBottom and low <= activeTop

        if barstate.isconfirmed and canEvaluateFill
            hasPartialFill = confirmedFill >= rejectionMinFill
            isFullFill = confirmedFill >= fullFillThreshold
            isAccepted = activeDirection == 1 ? close <= activeBottom : close >= activeTop
            isRejected = not isAccepted and not isFullFill and hasPartialFill and (activeDirection == 1 ? close > activeTop : close < activeBottom)
            nextState := isAccepted ? 4 : isRejected ? 2 : isFullFill ? 3 : hasPartialFill ? 1 : 0
            if priorState == 2 and nextState == 1
                nextState := 2
            if priorState == 4
                nextState := 4
            array.set(gapMaxFills, idx, confirmedFill)
            array.set(gapStates, idx, nextState)

        ageRatio = f_clamp((bar_index - birthBar) / (usedZoneRightBars * 1.0), 0.0, 1.0)
        gapAtr = activeHeight / atrSafe
        barRangeAtr = (high - low) / atrSafe
        volumeFactor = not na(volumeAverage) and volumeAverage > 0 ? f_clamp(volume / volumeAverage, 0.0, 2.0) / 2.0 : 0.50
        scoreValue = f_readiness_score(nextState, displayFill, gapAtr, ageRatio, barRangeAtr, volumeFactor, zoneTouched)
        array.set(gapScores, idx, scoreValue)

        if barstate.isconfirmed and nextState != priorState
            partialFillEvent := partialFillEvent or nextState == 1
            fullFillEvent := fullFillEvent or nextState == 3
            acceptanceEvent := acceptanceEvent or nextState == 4
            plannerReadyEvent := plannerReadyEvent or (nextState == 2 and scoreValue >= readinessThreshold)

            if nextState == 2 and scoreValue >= readinessThreshold
                proofArmRequested := true
                proofArmDir := activeDirection
                proofArmEntry := close
                proofArmInvalid := activeDirection == 1 ? activeBottom - atrSafe * invalidationBufferAtr : activeTop + atrSafe * invalidationBufferAtr

            actionLabelAllowed = na(lastActionLabelBar) or bar_index - lastActionLabelBar >= usedActionCooldown
            if nextState == 2 and scoreValue >= readinessThreshold and showActionLabels and actionLabelAllowed
                bullPlan = activeDirection == 1
                markerY = bullPlan ? low - atrSafe * labelOffsetAtr : high + atrSafe * labelOffsetAtr
                markerText = bullPlan ? "Bull Reaction\nQ " : "Bear Reaction\nQ "
                markerLabel = label.new(bar_index, markerY, markerText + str.tostring(math.round(scoreValue)) + " " + f_grade(scoreValue),
                     xloc = xloc.bar_index,
                     yloc = yloc.price,
                     style = bullPlan ? label.style_label_up : label.style_label_down,
                     textcolor = headerText,
                     color = color.new(bullPlan ? bullColor : bearColor, 0),
                     size = labelSize,
                     textalign = text.align_center)
                array.push(actionLabels, markerLabel)
                lastActionLabelBar := bar_index

        isResolvedVisual = nextState == 3 or nextState == 4
        shouldHideZone = not showGapZones or (isResolvedVisual and not showResolvedBands)
        stateColor = f_state_color(nextState, activeDirection, scoreValue, readinessThreshold)
        directionColor = activeDirection == 1 ? bullColor : bearColor
        zoneTransparency = shouldHideZone ? 100 : f_zone_transparency(nextState)
        fillTransparency = shouldHideZone or isResolvedVisual or not showFillProgress ? 100 : 74
        progressFill = f_clamp(displayFill, 0.0, 100.0)
        zoneMid = (activeTop + activeBottom) / 2.0
        displayHeight = math.max(activeHeight, atrSafe * minZoneHeightAtr)
        displayTop = zoneMid + displayHeight / 2.0
        displayBottom = zoneMid - displayHeight / 2.0
        progressLevel = activeDirection == 1 ? displayTop - displayHeight * progressFill / 100.0 : displayBottom + displayHeight * progressFill / 100.0

        box.set_top(activeGapBox, displayTop)
        box.set_right(activeGapBox, rightEdge)
        box.set_bottom(activeGapBox, displayBottom)
        box.set_bgcolor(activeGapBox, color.new(directionColor, zoneTransparency))
        box.set_border_color(activeGapBox, shouldHideZone ? color.new(stateColor, 100) : color.new(stateColor, 0))
        box.set_border_width(activeGapBox, nextState == 2 and scoreValue >= readinessThreshold ? 2 : 1)

        box.set_top(activeFillBox, displayTop)
        box.set_right(activeFillBox, rightEdge)
        box.set_bottom(activeFillBox, displayBottom)
        if activeDirection == 1
            box.set_top(activeFillBox, displayTop)
            box.set_bottom(activeFillBox, math.max(progressLevel, displayBottom))
        else
            box.set_top(activeFillBox, math.min(progressLevel, displayTop))
            box.set_bottom(activeFillBox, displayBottom)
        box.set_bgcolor(activeFillBox, color.new(accentColor, fillTransparency))
        box.set_border_color(activeFillBox, color.new(accentColor, 100))

        activeZoneLabel = array.get(zoneLabels, idx)
        isLatestGap = idx == gapCount - 1
        isActiveLabelState = nextState == 0 or nextState == 1 or nextState == 2
        isFocusedZone = isLatestGap or scoreValue >= readinessThreshold
        zoneLabelAllowed = not shouldHideZone
        if zoneLabelAllowed
            labelX = int(math.round(birthBar + usedZoneRightBars * 0.5))
            labelY = zoneMid
            compactZoneText = (activeDirection == 1 ? "Support Gap" : "Resistance Gap") + "\n" + f_zone_state_title(nextState)
            zoneText = showZoneLabels ? f_zone_label_text(activeDirection, nextState, scoreValue, progressFill) : compactZoneText
            if showZoneLabels
                if zoneLabelModeInput == "Focused Zones" and not isFocusedZone
                    zoneText := compactZoneText
                else if zoneLabelModeInput == "Latest Active" and not (isLatestGap and isActiveLabelState)
                    zoneText := compactZoneText
                else if zoneLabelModeInput == "Rejections Only" and nextState != 2
                    zoneText := compactZoneText
            if na(activeZoneLabel)
                activeZoneLabel := label.new(labelX, labelY, zoneText,
                     xloc = xloc.bar_index,
                     yloc = yloc.price,
                     style = label.style_label_center,
                     textcolor = headerText,
                     color = color.new(stateColor, 8),
                     size = labelSize,
                     textalign = text.align_center)
                array.set(zoneLabels, idx, activeZoneLabel)
            else
                label.set_x(activeZoneLabel, labelX)
                label.set_y(activeZoneLabel, labelY)
                label.set_text(activeZoneLabel, zoneText)
                label.set_style(activeZoneLabel, label.style_label_center)
                label.set_color(activeZoneLabel, color.new(stateColor, 8))
                label.set_textcolor(activeZoneLabel, headerText)
                label.set_size(activeZoneLabel, labelSize)
                label.set_textalign(activeZoneLabel, text.align_center)
        else
            if not na(activeZoneLabel)
                label.delete(activeZoneLabel)
                label emptyLabel = na
                array.set(zoneLabels, idx, emptyLabel)

while array.size(actionLabels) > maxActionLabels
    oldActionLabel = array.shift(actionLabels)
    f_delete_label(oldActionLabel)

// -------------------------------------------------
// Confirmation-anchored proof (planner-ready reactions: Follow = reached projected target before invalidation)
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

int proofWarmup = math.max(atrLength, 20) + 5
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
        if naturalResolve or proofArmRequested
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
    if proofArmRequested and not pEvalActive and proofArmDir != 0 and not na(proofArmInvalid)
        float pRisk = math.max(math.abs(proofArmEntry - proofArmInvalid), syminfo.mintick)
        pEvalActive := true
        pEvalDir := proofArmDir
        pEvalEntry := proofArmEntry
        pEvalStop := proofArmInvalid
        pEvalTarget := proofArmEntry + proofArmDir * pRisk * targetMultiple
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false
        pFlipped := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

// -------------------------------------------------
// Active Planner Lines
// -------------------------------------------------
int plannerIdx = na
float bestPlannerScore = na
if gapCount > 0
    for searchIdx = 0 to gapCount - 1
        reverseIdx = gapCount - 1 - searchIdx
        candidateBirth = array.get(gapBirthBars, reverseIdx)
        candidateState = array.get(gapStates, reverseIdx)
        candidateScore = array.get(gapScores, reverseIdx)
        candidateInProjection = bar_index <= candidateBirth + usedZoneRightBars
        candidateActionable = candidateInProjection and candidateState < 3
        if candidateActionable and (na(bestPlannerScore) or candidateScore > bestPlannerScore)
            bestPlannerScore := candidateScore
            plannerIdx := reverseIdx

var line entryLine = na
var line invalidationLine = na
var line targetLine = na
var label entryTag = na
var label invalidationTag = na
var label targetTag = na

float activeEntry = na
float activeInvalidation = na
float activeTarget = na
float activeRisk = na
float activeReward = na
float activeRr = na
string activePlanSide = "No active plan"
string activeAction = "Waiting"
string activeBias = "Waiting"
string activeGapSizeText = "No active zone"
string activeFillText = "--"
string activeStateText = "Idle"
float activeScore = na
color activePlanColor = panelValueCol

if not na(plannerIdx)
    plannerTop = array.get(gapTops, plannerIdx)
    plannerBottom = array.get(gapBottoms, plannerIdx)
    plannerHeight = math.max(plannerTop - plannerBottom, syminfo.mintick)
    plannerFill = array.get(gapMaxFills, plannerIdx)
    plannerDirection = array.get(gapDirections, plannerIdx)
    plannerState = array.get(gapStates, plannerIdx)
    plannerScore = array.get(gapScores, plannerIdx)
    activeEntry := close
    activeInvalidation := plannerDirection == 1 ? plannerBottom - atrSafe * invalidationBufferAtr : plannerTop + atrSafe * invalidationBufferAtr
    activeRisk := math.max(math.abs(activeEntry - activeInvalidation), syminfo.mintick)
    activeTarget := plannerDirection == 1 ? activeEntry + activeRisk * targetMultiple : activeEntry - activeRisk * targetMultiple
    activeReward := math.abs(activeTarget - activeEntry)
    activeRr := activeReward / activeRisk
    activeScore := plannerScore
    activePlanSide := plannerDirection == 1 ? "Bull Reaction" : "Bear Reaction"
    activeAction := f_action_text(plannerDirection, plannerState, plannerScore, readinessThreshold)
    activeBias := f_bias_text(plannerDirection, plannerState, plannerScore, readinessThreshold)
    activeGapSizeText := str.tostring(plannerHeight / syminfo.mintick, "#") + " ticks / " + str.tostring(plannerHeight / atrSafe, "#.00") + " ATR"
    activeFillText := str.tostring(plannerFill, "#.0") + "%"
    activeStateText := f_state_text(plannerState)
    activePlanColor := f_state_color(plannerState, plannerDirection, plannerScore, readinessThreshold)

if showPlanLevels and not na(plannerIdx)
    planLeft = bar_index
    planRight = bar_index + math.min(usedZoneRightBars, 35)
    if na(entryLine)
        entryLine := line.new(planLeft, activeEntry, planRight, activeEntry, xloc = xloc.bar_index, color = color.new(panelValueCol, 0), width = 1)
        invalidationLine := line.new(planLeft, activeInvalidation, planRight, activeInvalidation, xloc = xloc.bar_index, color = color.new(bearColor, 0), width = 1, style = line.style_dashed)
        targetLine := line.new(planLeft, activeTarget, planRight, activeTarget, xloc = xloc.bar_index, color = color.new(bullColor, 0), width = 1, style = line.style_dotted)
    else
        line.set_xy1(entryLine, planLeft, activeEntry)
        line.set_xy2(entryLine, planRight, activeEntry)
        line.set_xy1(invalidationLine, planLeft, activeInvalidation)
        line.set_xy2(invalidationLine, planRight, activeInvalidation)
        line.set_xy1(targetLine, planLeft, activeTarget)
        line.set_xy2(targetLine, planRight, activeTarget)
    line.set_color(entryLine, color.new(panelValueCol, 0))
    line.set_color(invalidationLine, color.new(bearColor, 0))
    line.set_color(targetLine, color.new(bullColor, 0))
    line.set_style(entryLine, line.style_solid)
    line.set_style(invalidationLine, line.style_dashed)
    line.set_style(targetLine, line.style_dotted)

    entryTagText = "Entry" + (showPlanLevelValues ? " " + str.tostring(activeEntry, format.mintick) : "")
    invalidationTagText = "Invalidation" + (showPlanLevelValues ? " " + str.tostring(activeInvalidation, format.mintick) : "")
    targetTagText = "Target" + (showPlanLevelValues ? " " + str.tostring(activeTarget, format.mintick) : "")
    if na(entryTag)
        entryTag := label.new(planRight, activeEntry, entryTagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = headerText, color = color.new(panelBorder, 0), size = labelSize)
        invalidationTag := label.new(planRight, activeInvalidation, invalidationTagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = headerText, color = color.new(bearColor, 0), size = labelSize)
        targetTag := label.new(planRight, activeTarget, targetTagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = headerText, color = color.new(bullColor, 0), size = labelSize)
    else
        label.set_x(entryTag, planRight)
        label.set_y(entryTag, activeEntry)
        label.set_text(entryTag, entryTagText)
        label.set_size(entryTag, labelSize)
        label.set_x(invalidationTag, planRight)
        label.set_y(invalidationTag, activeInvalidation)
        label.set_text(invalidationTag, invalidationTagText)
        label.set_size(invalidationTag, labelSize)
        label.set_x(targetTag, planRight)
        label.set_y(targetTag, activeTarget)
        label.set_text(targetTag, targetTagText)
        label.set_size(targetTag, labelSize)
else
    if not na(entryLine)
        line.set_color(entryLine, color.new(panelValueCol, 100))
        line.set_color(invalidationLine, color.new(bearColor, 100))
        line.set_color(targetLine, color.new(bullColor, 100))
    f_delete_label(entryTag)
    f_delete_label(invalidationTag)
    f_delete_label(targetTag)
    entryTag := na
    invalidationTag := na
    targetTag := na

// -------------------------------------------------
// Panel
// -------------------------------------------------
isLightPanel = panelThemeInput == "Light"
panelTextSize = f_size(panelFontInput)
panelBgA = f_panel_bg(isLightPanel, false)
panelBgB = f_panel_bg(isLightPanel, true)
panelBorderA = f_panel_border(isLightPanel)
panelLabelA = f_panel_label_color(isLightPanel)
panelValueA = f_panel_value_color(isLightPanel)
scoreText = na(activeScore) ? "--" : str.tostring(math.round(activeScore)) + " / 100 " + f_grade(activeScore)
invalidationText = na(activeInvalidation) ? "--" : str.tostring(activeInvalidation, format.mintick)
targetText = na(activeTarget) ? "--" : str.tostring(activeTarget, format.mintick)
rrText = na(activeRr) ? "--" : str.tostring(activeRr, "#.00") + "R"
proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) : "building"

int panelRowCount = showProof ? 13 : 8
var table plannerPanel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""
var string lastPanelFont = ""
var bool lastPanelVisible = false
var bool lastProofMode = false

bool panelNeedsBuild = showPanel and (na(plannerPanel) or panelLocationInput != lastPanelLocation or panelThemeInput != lastPanelTheme or panelFontInput != lastPanelFont or not lastPanelVisible or showProof != lastProofMode)
if panelNeedsBuild
    if not na(plannerPanel)
        table.delete(plannerPanel)
    plannerPanel := table.new(f_panel_position(panelLocationInput), 2, panelRowCount, bgcolor = panelBgA, frame_color = panelBorderA, frame_width = 1, border_color = panelBorderA, border_width = 1)
    table.cell(plannerPanel, 0, 0, "AG Pro Gap Fill Reaction Planner", text_color = headerText, bgcolor = headerBg, text_size = panelTextSize, text_halign = text.align_center)
    table.cell(plannerPanel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelTextSize)
    table.merge_cells(plannerPanel, 0, 0, 1, 0)
    lastPanelLocation := panelLocationInput
    lastPanelTheme := panelThemeInput
    lastPanelFont := panelFontInput
    lastPanelVisible := true
    lastProofMode := showProof

if not showPanel and not na(plannerPanel)
    table.delete(plannerPanel)
    plannerPanel := na
    lastPanelVisible := false

if showPanel and not na(plannerPanel) and barstate.islast
    table.set_position(plannerPanel, f_panel_position(panelLocationInput))
    table.clear(plannerPanel, 0, 1, 1, panelRowCount - 1)
    table.cell(plannerPanel, 0, 0, "AG Pro Gap Fill Reaction Planner", text_color = headerText, bgcolor = headerBg, text_size = panelTextSize, text_halign = text.align_center)
    table.cell(plannerPanel, 0, 1, "Readiness", text_color = panelLabelA, bgcolor = panelBgA, text_size = panelTextSize)
    table.cell(plannerPanel, 1, 1, scoreText, text_color = activePlanColor, bgcolor = panelBgA, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(plannerPanel, 0, 2, "Next Action", text_color = panelLabelA, bgcolor = panelBgB, text_size = panelTextSize)
    table.cell(plannerPanel, 1, 2, activeAction, text_color = activePlanColor, bgcolor = panelBgB, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(plannerPanel, 0, 3, "Plan Side", text_color = panelLabelA, bgcolor = panelBgA, text_size = panelTextSize)
    table.cell(plannerPanel, 1, 3, activePlanSide, text_color = panelValueA, bgcolor = panelBgA, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(plannerPanel, 0, 4, "Gap Size", text_color = panelLabelA, bgcolor = panelBgB, text_size = panelTextSize)
    table.cell(plannerPanel, 1, 4, activeGapSizeText, text_color = panelValueA, bgcolor = panelBgB, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(plannerPanel, 0, 5, "Fill / State", text_color = panelLabelA, bgcolor = panelBgA, text_size = panelTextSize)
    table.cell(plannerPanel, 1, 5, activeFillText + " / " + activeStateText, text_color = panelValueA, bgcolor = panelBgA, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(plannerPanel, 0, 6, "Invalidation", text_color = panelLabelA, bgcolor = panelBgB, text_size = panelTextSize)
    table.cell(plannerPanel, 1, 6, invalidationText, text_color = bearColor, bgcolor = panelBgB, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(plannerPanel, 0, 7, "Target / R", text_color = panelLabelA, bgcolor = panelBgA, text_size = panelTextSize)
    table.cell(plannerPanel, 1, 7, targetText + " / " + rrText, text_color = bullColor, bgcolor = panelBgA, text_size = panelTextSize, text_halign = text.align_right)
    if showProof
        table.cell(plannerPanel, 0, 8, "Proof @ Confirm", text_color = accentColor, bgcolor = panelBgB, text_size = panelTextSize, text_halign = text.align_left)
        table.cell(plannerPanel, 1, 8, proofSampleText, text_color = panelLabelA, bgcolor = panelBgB, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(plannerPanel, 0, 9, "Follow Rate", text_color = panelLabelA, bgcolor = panelBgA, text_size = panelTextSize)
        table.cell(plannerPanel, 1, 9, proofTotal > 0 ? f_rate_pct(followRate) : "-", text_color = proofTotal > 0 ? f_rate_color(followRate) : panelValueA, bgcolor = panelBgA, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(plannerPanel, 0, 10, "Hold Rate", text_color = panelLabelA, bgcolor = panelBgB, text_size = panelTextSize)
        table.cell(plannerPanel, 1, 10, proofTotal > 0 ? f_rate_pct(holdRate) : "-", text_color = proofTotal > 0 ? f_rate_color(holdRate) : panelValueA, bgcolor = panelBgB, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(plannerPanel, 0, 11, "React Rate", text_color = panelLabelA, bgcolor = panelBgA, text_size = panelTextSize)
        table.cell(plannerPanel, 1, 11, proofTotal > 0 ? f_rate_pct(reactRate) : "-", text_color = proofTotal > 0 ? f_rate_color(reactRate) : panelValueA, bgcolor = panelBgA, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(plannerPanel, 0, 12, "Flip Rate", text_color = panelLabelA, bgcolor = panelBgB, text_size = panelTextSize)
        table.cell(plannerPanel, 1, 12, proofTotal > 0 ? f_rate_pct(flipRate) : "-", text_color = proofTotal > 0 ? f_flip_color(flipRate) : panelValueA, bgcolor = panelBgB, text_size = panelTextSize, text_halign = text.align_right)

// -------------------------------------------------
// Alerts And Hidden Exports
// -------------------------------------------------
alertcondition(alertNewGaps and newGapUpEvent, "New Gap Support Zone", "A new gap support reaction zone has been detected on {{ticker}} {{interval}}.")
alertcondition(alertNewGaps and newGapDownEvent, "New Gap Resistance Zone", "A new gap resistance reaction zone has been detected on {{ticker}} {{interval}}.")
alertcondition(partialFillEvent, "Gap Partial Fill", "A tracked gap planner zone has reached partial fill criteria on {{ticker}} {{interval}}.")
alertcondition(alertGapResolution and fullFillEvent, "Gap Full Fill", "A tracked gap planner zone has reached full fill criteria on {{ticker}} {{interval}}.")
alertcondition(alertPlannerReady and plannerReadyEvent, "Gap Planner Ready", "A gap reaction setup has reached the planner readiness threshold on {{ticker}} {{interval}}.")
alertcondition(alertGapResolution and acceptanceEvent, "Gap Acceptance", "A tracked gap planner zone has confirmed acceptance beyond the far boundary on {{ticker}} {{interval}}.")

plot(activeScore, "GFP Active Readiness Score", display = display.none)
plot(activeRr, "GFP Active Reward Risk", display = display.none)
plot(followRate, "GFP Follow Rate", display = display.none)
plot(holdRate, "GFP Hold Rate", display = display.none)
plot(reactRate, "GFP React Rate", display = display.none)
plot(flipRate, "GFP Flip Rate", display = display.none)
````

# Choppiness Setup Planner [AGPro Series]

- url: https://www.tradingview.com/script/vPx2XplH-Choppiness-Setup-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;11ea9c5389ca4727b41e53db4f769fef
- version: 5.0

## Description

Choppiness Setup Planner [AGPro Series]

🧠 Core Idea

Is this choppy market still a no-trade environment, or has it matured into a valid setup with defined risk, invalidation, and targets?

📌 Overview / What it does

Choppiness Setup Planner [AGPro Series] is a planner-style overlay built for one of the most common decision problems in technical analysis: what should a trader do when price is trapped inside a choppy range, but pressure starts building near the edge?

The script detects no-trade chop conditions, builds a decision range around the active structure, scores setup quality from 0 to 100, and turns a mature range release into a clear planning map with invalidation and target levels. Instead of only saying "the market is choppy," it answers whether the setup is still avoidable, preparing, weak, valid, active, or invalidated.

The cleanest visual use case is higher-timeframe planning. Weekly and daily charts allow the full range-to-plan lifecycle to breathe: no-trade structure, preparation, release, target, and invalidation can all be read without the chart feeling crowded.

It does not automate execution, predict future price, or replace personal trade selection. It is an analytical planner designed to organize context, risk, and next-action state directly on the chart.

🎯 Purpose & Design Philosophy

This script was built because many market-state tools show information without helping the user make a decision. A Choppiness Index value, ADX filter, or range box can be useful, but those outputs often stop before the practical question: what now?

Choppiness Setup Planner fills that gap by connecting chop detection with a structured planning workflow. It is intended for discretionary traders, breakout traders, and range-to-expansion traders who want to avoid low-quality noise while preparing for stronger releases from mature ranges.

The design philosophy is simple: first protect attention, then qualify the setup, then map risk only when the structure deserves it.

⚡ Why This Script Is Different

Most tools focus on detecting chop, drawing a box, or marking a breakout.

This script does NOT act like a generic signal indicator, generic support/resistance tool, or simple Choppiness Index panel.

Instead, it turns a choppy market into a decision sequence:

1. Detect the no-trade environment.
2. Track range age and pressure.
3. Grade setup validity with a 0-100 score.
4. Define the next action state.
5. Map invalidation and targets only after a valid release.

That makes the script closer to a decision engine than a visual marker. It is also intentionally separated from manual position planners: users do not enter their own position parameters. The script derives its planning levels from the detected chop range and the release quality model.

⚙️ Methodology

1. Context Detection
The engine blends Choppiness Index, directional weakness, path efficiency, range tightness, wick noise, and volatility behavior to determine whether the market is inefficient enough to qualify as a no-trade chop environment.

2. Reference Mapping
When chop persists long enough, the script builds a decision range around the active structure. This range is not a generic support/resistance zone; it is a planning container for the current no-trade condition.

3. Reaction Evaluation
The script evaluates whether pressure is improving through range age, chop release, ADX lift, path-efficiency improvement, ATR lift, edge pressure, candle body quality, close quality, and optional volume participation.

4. Visual Output
The chart displays the no-trade ribbon, decision range box, centered zone label, preparation markers, valid plan markers, weak-release markers, invalidation level, target levels, and a compact AGPro planner panel.

🗺️ How to Read the Chart

Zones represent the active no-trade decision range. A centered label inside the box shows whether the structure is still a no-trade zone or has moved into preparation mode.

Labels represent state changes. PREP marks a mature range with improving setup quality. PLAN UP and PLAN DN mark valid releases. SKIP marks a release that happened but failed the minimum plan-quality threshold. T1, T2, and INVALID track the active plan lifecycle.

Colors follow the AGPro state palette. Teal is used for stronger upside planning states, pink for downside or invalidation states, amber for caution and no-trade states, and indigo for preparation/readiness.

The panel shows Setup Quality, Next Action, Chop / Ready, Range Age, Invalidation, and Targets.

🚦 Signals & States

• Avoid: Chop → the market is inefficient and still belongs in no-trade mode.

• Prepare: Edge Watch → the range has matured and internal readiness is improving.

• Skip: Low Quality → price released from the range, but the quality score was not strong enough.

• Track Upside Plan → upside release met the minimum valid plan score.

• Track Downside Plan → downside release met the minimum valid plan score.

• Manage: T1 Reached → the active plan reached its first target level.

• Review: T2 Reached → the active plan reached its second target level.

• Reset: Invalidated → the active plan crossed its invalidation level.

🔔 Alerts Logic

Alerts are available for preparation state, valid upside plan, valid downside plan, weak release, Target 1 reached, Target 2 reached, and invalidation.

Each alert is an attention marker. Alerts are not trade instructions, not automation rules, and not execution commands.

🧩 Confluence Logic

The setup becomes stronger when a mature chop range aligns with improving readiness, edge pressure, candle body participation, release distance, and optional volume participation.

When these components align, the script can convert the release into a valid plan. When price releases without enough score, the script marks the event as SKIP instead of treating every breakout as useful.

📊 When to Use

• Choppy markets where the user needs a no-trade filter.
• Weekly, daily, and 4H planning where range structure matters more than micro-noise.
• Mature ranges that may be preparing for expansion.
• Breakout-preparation workflows.
• Range-to-trend transition monitoring.
• Symbols where invalidation and target structure should be visible before acting.

⚠️ When NOT to Use

• Extremely illiquid markets with unreliable candles.
• Symbols where volume data is misleading, unless volume participation is disabled.
• News-driven spikes where a single candle can distort range logic.
• Very low timeframes with excessive spread noise.
• Scalping workflows that require rapid-fire signals instead of structural planning.
• Markets where the user has no broader context for trend, liquidity, or session behavior.

🎛️ Key Inputs

• Choppiness Length → controls the chop-detection backbone.
• Decision Range Length → controls how the active no-trade range is framed.
• Minimum Range Age → controls how long chop must persist before planning begins.
• Preparation Threshold → controls when the range moves from avoid mode to preparation mode.
• Minimum Valid Plan Score → controls how selective valid plan labels should be.
• Release Buffer ATR → controls how far price must move beyond the range boundary.
• Invalidation Buffer ATR → controls the distance behind the released boundary used for invalidation.
• Target 1 / Target 2 R Multiples → control target projection from the plan risk.
• Panel Location / Theme / Font Size → control the AGPro panel interface.
• Label Font Size / Cooldown / Maximum Visible Labels → control chart readability.

🖥️ Interface & Visual Design

The interface is designed around fast decision reading. The chart carries the range box, no-trade ribbon, centered zone label, event labels, and active risk/target levels. The panel summarizes the same workflow without becoming a large dashboard.

The first panel row follows the AGPro standard: one merged blue header row containing only the script name.

Visual density is intentionally moderate. The chart should not look empty, but it should also avoid crowded signal spam.

🧪 Practical Usage Workflow

1. Read the panel.
Check Setup Quality and Next Action first.

2. Check the decision range.
If the box says NO-TRADE, the structure is still inefficient. If it says PREP, the range is maturing.

3. Evaluate the release.
A valid PLAN label means the release met the quality threshold. A SKIP label means the release was not strong enough.

4. Review invalidation and targets.
When a plan is active, use the plotted levels to understand structure, not as automatic orders.

5. Confirm broader context.
Combine the planner output with trend, liquidity, timeframe, session, and personal execution rules.

For publication screenshots, higher-timeframe examples are usually the cleanest because they show the complete planning sequence without compressing labels and boxes into a noisy layout.

🔍 Interpretation Guidelines

Think in states, not isolated signals.

NO-TRADE protects attention.
PREP means the market is becoming more interesting.
PLAN means the release has enough structure to track.
SKIP means the release happened but did not earn quality.
INVALID means the plan lost its structural premise.

🚫 What This Script Is NOT

This script is not a prediction engine.
It is not financial advice.
It is not auto trading.
It is not guaranteed signals.
It is not a strategy tester.
It is not a replacement for independent analysis.

⚠️ Limitations & Transparency

The script is rule-based and depends on selected inputs, timeframe, volatility, and available market data.

Different symbols and sessions can produce different behavior. Low liquidity, sudden volatility shocks, and abnormal gaps can reduce the usefulness of range-based planning.

Volume participation is optional because volume quality differs across markets and feeds.

🧠 Market Context Notes

Chop is not always weakness. Sometimes it is absorption, sometimes indecision, and sometimes simple noise. The script does not claim to know the cause. It organizes the observable structure so the user can decide whether the environment is worth attention.

🧾 Use Case Examples

When price spends several bars inside a tight inefficient range and the panel says Avoid: Chop, the script is acting as a no-trade filter.

When the range matures and the centered label changes to PREP, the script is showing that pressure has improved enough to monitor the edge.

When price releases and receives PLAN UP or PLAN DN, the script maps invalidation and targets from the structure.

When price releases but receives SKIP, the script is saying the event did not meet the model's quality threshold.

On weekly charts, a single valid plan can show the entire decision chain: range maturity, preparation, release, target reaction, and invalidation. This is the strongest showcase environment for the script.

🧱 System Philosophy

AGPro tools are built around structured decision support: define the condition, score the quality, map the relevant structure, and keep the chart readable.

Choppiness Setup Planner follows that philosophy by turning a noisy no-trade environment into a cleaner decision workflow.

🔐 Non-Promise Statement

No script can provide certainty.
No score guarantees follow-through.
No label guarantees an outcome.

📉 Risk Disclosure

Trading involves risk. Market conditions can change quickly, planned setups can fail, and losses can occur. This script is provided for educational and analytical use only. It does not provide financial advice or guaranteed trading outcomes. Users remain responsible for their own analysis, decisions, risk management, and execution.

📚 Educational Note

Use this script to study how choppy markets mature, how range releases differ in quality, and how invalidation and target logic can be organized visually before a decision is made.

## Source Code

````pine
// -------------------------------------------------
// Choppiness Setup Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Choppiness Setup Planner is a planner-style market decision engine for
// range-bound, choppy, low-efficiency, and pre-expansion conditions. It maps
// no-trade chop ranges, grades setup quality with a 0-100 score, displays
// preparation and release states, and projects invalidation plus target levels
// when a mature choppy range releases with enough quality.
// V1.5 clarifies the handoff from a completed chop range into an active plan.
// Closed ranges stop at their release boundary, plan levels follow the current
// lifecycle stage, and all state-changing events are confirmed on bar close.
// -------------------------------------------------

//@version=6
indicator("Choppiness Setup Planner [AGPro Series]",
     shorttitle       = "AG Pro CSP",
     overlay          = true,
     max_boxes_count  = 80,
     max_labels_count = 160,
     max_lines_count  = 40)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBgDark   = color.rgb(15, 23, 42)
panelBorderD  = color.rgb(51, 65, 85)
panelLabelD   = color.rgb(148, 163, 184)
panelValueD   = color.rgb(226, 232, 240)
panelBgLight  = color.rgb(248, 250, 252)
panelBorderL  = color.rgb(203, 213, 225)
panelLabelL   = color.rgb(71, 85, 105)
panelValueL   = color.rgb(15, 23, 42)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Engine"
enginePreset = input.string("Balanced Planner", "Engine Preset", options = ["Balanced Planner", "Cleaner Swing", "Active Intraday", "Custom"], group = groupEngine,
     tooltip = "Selects the default behavior profile. Balanced Planner is the publication default. Cleaner Swing reduces visual density. Active Intraday reacts faster. Custom uses the raw inputs below.")
ciLen = input.int(14, "Choppiness Length", minval = 5, maxval = 100, group = groupEngine,
     tooltip = "Lookback used for the Choppiness Index backbone. Higher values create slower, more structural chop detection.")
adxLen = input.int(14, "Directional Weakness Length", minval = 5, maxval = 100, group = groupEngine,
     tooltip = "Length used for DMI/ADX. Low directional strength increases the chop component of the model.")
effLen = input.int(12, "Path Efficiency Length", minval = 5, maxval = 100, group = groupEngine,
     tooltip = "Measures direct price progress versus total traveled movement. Low efficiency supports no-trade conditions.")
rangeLen = input.int(28, "Decision Range Length", minval = 8, maxval = 200, group = groupEngine,
     tooltip = "Lookback used to frame the active no-trade decision range and evaluate range tightness.")
noiseLen = input.int(10, "Wick Noise Length", minval = 3, maxval = 80, group = groupEngine,
     tooltip = "Smooths wick-heavy candle behavior. Higher wick dominance inside a range raises the no-trade score.")
smoothLen = input.int(4, "Score Smoothing", minval = 1, maxval = 20, group = groupEngine,
     tooltip = "EMA smoothing applied to the final chop, readiness, and setup quality scores.")
useVolume = input.bool(true, "Use Volume Participation", group = groupEngine,
     tooltip = "When enabled, breakout quality includes relative volume participation. Disable on symbols where volume is not informative.")
volumeLen = input.int(30, "Volume Baseline Length", minval = 5, maxval = 200, group = groupEngine,
     tooltip = "Moving average length used to normalize volume participation during a range release.")

groupPlanner = "Planner Logic"
chopGate = input.float(61.8, "No-Trade Chop Threshold", minval = 40.0, maxval = 90.0, step = 0.1, group = groupPlanner,
     tooltip = "Chop score required before the script marks a no-trade decision range.")
minRangeAge = input.int(8, "Minimum Range Age", minval = 2, maxval = 100, group = groupPlanner,
     tooltip = "Minimum number of consecutive chop bars required before a decision range can become actionable.")
readinessGate = input.float(64.0, "Preparation Threshold", minval = 40.0, maxval = 95.0, step = 0.1, group = groupPlanner,
     tooltip = "Setup quality required before a mature chop range is promoted from avoid mode to preparation mode.")
minPlanQuality = input.float(70.0, "Minimum Valid Plan Score", minval = 40.0, maxval = 98.0, step = 0.1, group = groupPlanner,
     tooltip = "Minimum 0-100 quality score required before a range release becomes a valid upside or downside plan.")
breakBufferAtr = input.float(0.15, "Release Buffer ATR", minval = 0.00, maxval = 2.00, step = 0.01, group = groupPlanner,
     tooltip = "ATR buffer beyond the decision range boundary required to qualify a release.")
riskBufferAtr = input.float(0.65, "Invalidation Buffer ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupPlanner,
     tooltip = "ATR distance used to place the invalidation level behind the released range boundary.")
targetR1 = input.float(1.0, "Target 1 R Multiple", minval = 0.25, maxval = 5.00, step = 0.25, group = groupPlanner,
     tooltip = "First target multiple based on the distance between plan entry and invalidation.")
targetR2 = input.float(2.0, "Target 2 R Multiple", minval = 0.50, maxval = 8.00, step = 0.25, group = groupPlanner,
     tooltip = "Second target multiple based on the distance between plan entry and invalidation.")
maxPlanBars = input.int(60, "Maximum Active Plan Bars", minval = 10, maxval = 300, group = groupPlanner,
     tooltip = "Maximum number of bars a plan can remain active before the script returns to scanning mode.")

groupVisual = "Visuals"
showDecisionRange = input.bool(true, "Show Decision Range Box", group = groupVisual,
     tooltip = "Displays the active no-trade range as a concept-native planning box on the chart.")
showRangeCenterLabel = input.bool(true, "Show Centered Range Label", group = groupVisual,
     tooltip = "Places a centered label inside the no-trade decision range. This is the main visual anchor for the planner.")
showNoTradeRibbon = input.bool(true, "Show No-Trade Ribbon", group = groupVisual,
     tooltip = "Displays the active chop structure as a subtle ribbon between range boundaries.")
showPlanLevels = input.bool(true, "Show Invalidation and Targets", group = groupVisual,
     tooltip = "Plots the active plan entry, invalidation, and target levels after a valid release.")
showPrepMarkers = input.bool(true, "Show Preparation Markers", group = groupVisual,
     tooltip = "Prints restrained preparation markers when a mature no-trade range develops enough setup quality.")
showPlanMarkers = input.bool(true, "Show Plan Markers", group = groupVisual,
     tooltip = "Prints valid, weak, target, and invalidation markers for the planner workflow.")
showWeakReleaseMarkers = input.bool(false, "Show Weak Release Markers", group = groupVisual,
     tooltip = "Shows low-quality release markers. Disabled by default for cleaner publication screenshots; weak releases still remain available through alerts and internal state.")
showPlanLevelTags = input.bool(true, "Show Plan Level Tags", group = groupVisual,
     tooltip = "Shows right-side tags for entry, invalidation, and targets. Enabled by default so active plan levels do not appear ownerless.")
planMapDensity = input.string("Focused", "Plan Map Density", options = ["Focused", "All"], group = groupVisual,
     tooltip = "Focused shows Entry, Invalidation, and T1 before the first target, then T1 Hit, Invalidation, and T2. All keeps every plan level visible throughout the active lifecycle.")
planTagOffsetBars = input.int(3, "Plan Tag Offset Bars", minval = 1, maxval = 30, group = groupVisual,
     tooltip = "Horizontal offset used to place active plan level tags to the right of the latest bar.")
showBackdrop = input.bool(false, "Show Subtle Chop Backdrop", group = groupVisual,
     tooltip = "Adds a light full-chart backdrop during no-trade chop conditions. Disabled by default for a cleaner publication view.")
showBarTint = input.bool(false, "Tint Candles by State", group = groupVisual,
     tooltip = "Optional candle tinting by no-trade, preparation, or active plan state. Disabled by default for cleaner screenshots.")
boxProjection = input.int(34, "Decision Box Projection", minval = 5, maxval = 200, group = groupVisual,
     tooltip = "Number of bars the active decision range projects forward from the current bar.")
maxStoredBoxes = input.int(1, "Maximum Historical Boxes", minval = 1, maxval = 20, group = groupVisual,
     tooltip = "Limits preserved historical decision boxes to keep the chart responsive and uncluttered.")
markerCooldown = input.int(24, "Marker Cooldown Bars", minval = 1, maxval = 100, group = groupVisual,
     tooltip = "Minimum spacing between preparation, plan, weak-release, target, and invalidation markers.")
maxEventLabels = input.int(6, "Maximum Visible Labels", minval = 6, maxval = 100, group = groupVisual,
     tooltip = "Maximum number of labels kept on the chart before older labels are removed.")
labelOffsetAtr = input.float(1.20, "Label Offset ATR", minval = 0.20, maxval = 5.00, step = 0.05, group = groupVisual,
     tooltip = "ATR-based vertical offset used to keep labels away from candle bodies and wicks.")
labelFontOpt = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual,
     tooltip = "Controls the size of all chart labels created by the script.")

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel,
     tooltip = "Displays the AG Pro planner panel with setup quality, next action, risk, targets, range state, and proof statistics.")
panelPositionOpt = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel,
     tooltip = "Selects where the information panel is anchored on the chart.")
panelThemeOpt = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel,
     tooltip = "Controls the panel color theme while preserving the AG Pro blue title row.")
panelFontOpt = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel,
     tooltip = "Controls the text size used inside the information panel.")

groupAlerts = "Alerts"
alertPrep = input.bool(true, "Alert on Preparation State", group = groupAlerts,
     tooltip = "Enables alerts when a mature no-trade range enters preparation state.")
alertPlans = input.bool(true, "Alert on Valid Plans", group = groupAlerts,
     tooltip = "Enables alerts when an upside or downside release reaches the minimum valid plan score.")
alertPlanEvents = input.bool(true, "Alert on Targets and Invalidation", group = groupAlerts,
     tooltip = "Enables alerts for target and invalidation events after a plan becomes active.")

groupProof = "Proof"
showProof = input.bool(true, "Show Proof Layer", group = groupProof,
     tooltip = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across chop-range releases on the current symbol and timeframe. Follow means a release reached its first target before its invalidation level. These are historical outcome rates, not predictions.")
proofHorizonBars = input.int(24, "Proof Horizon Bars", minval = 4, maxval = 200, group = groupProof,
     tooltip = "Maximum number of bars each release is tracked for the proof measurement before it resolves at its current outcome.")
reactBars = input.int(3, "Reaction Window Bars", minval = 1, maxval = 40, group = groupProof,
     tooltip = "Number of bars after a release used to detect an immediate favorable follow-through reaction.")
reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = groupProof,
     tooltip = "Minimum favorable progress toward the first target, within the reaction window, required to count as an early React.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_norm(float value, float minValue, float maxValue) =>
    maxValue == minValue ? 0.0 : f_clamp((value - minValue) / (maxValue - minValue) * 100.0, 0.0, 100.0)

f_sum_over(series float src, int len) =>
    float total = 0.0
    for i = 0 to len - 1
        total += nz(src[i])
    total

f_pos(string posText) =>
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

f_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_price(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(float value) =>
    value >= 55.0 ? bullColor : value >= 40.0 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30.0 ? bullColor : value <= 55.0 ? neutralColor : bearColor

f_panel_bg(bool isLight, bool alt) =>
    isLight ? (alt ? color.rgb(241, 245, 249) : panelBgLight) : (alt ? color.rgb(19, 29, 48) : panelBgDark)

var array<label> storedLabels = array.new<label>()
var array<box> storedBoxes = array.new<box>()

f_keep_label(label newLabel) =>
    array.push(storedLabels, newLabel)
    if array.size(storedLabels) > maxEventLabels
        oldLabel = array.shift(storedLabels)
        label.delete(oldLabel)

f_keep_box(box newBox) =>
    array.push(storedBoxes, newBox)
    if array.size(storedBoxes) > maxStoredBoxes
        oldBox = array.shift(storedBoxes)
        box.delete(oldBox)

f_delete_label(label item) =>
    if not na(item)
        label.delete(item)

f_delete_line(line item) =>
    if not na(item)
        line.delete(item)

// -------------------------------------------------
// Presets
// -------------------------------------------------
cleanerPreset = enginePreset == "Cleaner Swing"
activePreset = enginePreset == "Active Intraday"
usedChopGate = cleanerPreset ? math.max(chopGate, 64.0) : activePreset ? math.min(chopGate, 58.0) : chopGate
usedMinRangeAge = cleanerPreset ? math.max(minRangeAge, 10) : activePreset ? math.max(minRangeAge, 6) : minRangeAge
usedReadinessGate = cleanerPreset ? math.max(readinessGate, 66.0) : activePreset ? math.min(readinessGate, 60.0) : readinessGate
usedMinPlanQuality = cleanerPreset ? math.max(minPlanQuality, 72.0) : activePreset ? math.min(minPlanQuality, 66.0) : minPlanQuality
usedMarkerCooldown = cleanerPreset ? math.max(markerCooldown, 20) : activePreset ? math.max(markerCooldown, 10) : markerCooldown
usedBoxProjection = cleanerPreset ? math.max(boxProjection, 38) : activePreset ? math.max(boxProjection, 26) : boxProjection

// -------------------------------------------------
// Market-state engine
// -------------------------------------------------
trueRange = ta.tr(true)
sumTrueRange = f_sum_over(trueRange, ciLen)
ciHigh = ta.highest(high, ciLen)
ciLow = ta.lowest(low, ciLen)
ciSpan = ciHigh - ciLow
chopRaw = ciSpan > syminfo.mintick and ciLen > 1 ? 100.0 * math.log(sumTrueRange / ciSpan) / math.log(ciLen) : 50.0
chopIndex = f_clamp(chopRaw, 0.0, 100.0)

[diPlus, diMinus, adxValue] = ta.dmi(adxLen, adxLen)
directionalWeakness = 100.0 - f_norm(adxValue, 12.0, 34.0)

effDistance = bar_index >= effLen ? math.abs(close - close[effLen]) : 0.0
effTravel = f_sum_over(math.abs(ta.change(close)), effLen)
effRatio = effTravel > syminfo.mintick ? f_clamp(effDistance / effTravel, 0.0, 1.0) : 0.0
efficiencyChop = (1.0 - effRatio) * 100.0

localHigh = ta.highest(high, rangeLen)
localLow = ta.lowest(low, rangeLen)
localSpan = localHigh - localLow
rangeBaseLen = rangeLen * 3
rangeBaseline = ta.sma(localSpan, rangeBaseLen)
rangeRatio = rangeBaseline > syminfo.mintick ? localSpan / rangeBaseline : 1.0
rangeTightness = f_clamp((1.28 - rangeRatio) / 0.78 * 100.0, 0.0, 100.0)

barSpan = math.max(high - low, syminfo.mintick)
barBody = math.abs(close - open)
bodyPct = barBody / barSpan * 100.0
wickShare = (barSpan - barBody) / barSpan * 100.0
wickNoise = ta.sma(wickShare, noiseLen)

chopComposite = chopIndex * 0.35 + directionalWeakness * 0.20 + efficiencyChop * 0.22 + rangeTightness * 0.15 + wickNoise * 0.08
chopScore = ta.ema(chopComposite, smoothLen)
inChop = chopScore >= usedChopGate

atrLen = 14
atrBaseLen = 56
atrNow = ta.atr(atrLen)
safeAtr = math.max(atrNow, syminfo.mintick)
atrBase = ta.sma(atrNow, atrBaseLen)
atrRatio = atrBase > syminfo.mintick ? atrNow / atrBase : 1.0

volumeBase = ta.sma(volume, volumeLen)
volumeRatio = volumeBase > 0.0 ? volume / volumeBase : 1.0
volumeQuality = useVolume ? f_norm(volumeRatio, 0.80, 1.80) : 50.0

var int rangeAge = 0
rangeAge := inChop ? nz(rangeAge[1]) + 1 : 0

var float activeRangeHigh = na
var float activeRangeLow = na
var int activeRangeStart = na
var float lastRangeHigh = na
var float lastRangeLow = na
var int lastRangeAge = 0
var int lastRangeEnd = na

wasInChop = bar_index > 0 ? inChop[1] : false
newChop = inChop and not wasInChop
endChop = not inChop and wasInChop

if newChop
    activeRangeHigh := high
    activeRangeLow := low
    activeRangeStart := bar_index
else if inChop
    activeRangeHigh := math.max(nz(activeRangeHigh, high), high)
    activeRangeLow := math.min(nz(activeRangeLow, low), low)

if endChop
    lastRangeHigh := activeRangeHigh
    lastRangeLow := activeRangeLow
    lastRangeAge := nz(rangeAge[1])
    lastRangeEnd := bar_index - 1

decisionHigh = inChop ? activeRangeHigh : lastRangeHigh
decisionLow = inChop ? activeRangeLow : lastRangeLow
decisionAge = inChop ? rangeAge : lastRangeAge
decisionMid = not na(decisionHigh) and not na(decisionLow) ? (decisionHigh + decisionLow) * 0.5 : na
decisionSpan = not na(decisionHigh) and not na(decisionLow) ? decisionHigh - decisionLow : na
rangePosition = not na(decisionSpan) and decisionSpan > syminfo.mintick ? f_clamp((close - decisionLow) / decisionSpan, 0.0, 1.0) : 0.5
edgePressure = math.abs(rangePosition - 0.5) * 200.0

ageQuality = f_norm(decisionAge, usedMinRangeAge, usedMinRangeAge * 3)
chopRelease = nz(chopScore[3], chopScore) - chopScore
releaseQuality = f_norm(chopRelease, 0.0, 12.0)
adxLift = adxValue - nz(adxValue[3], adxValue)
adxLiftQuality = f_norm(adxLift, 0.0, 7.0)
effLift = effRatio - nz(effRatio[3], effRatio)
effLiftQuality = f_norm(effLift, 0.0, 0.18)
atrLiftQuality = f_norm(atrRatio, 0.95, 1.38)

readinessScore = ta.ema(ageQuality * 0.22 + releaseQuality * 0.22 + adxLiftQuality * 0.17 + effLiftQuality * 0.14 + atrLiftQuality * 0.13 + edgePressure * 0.12, smoothLen)
prePlanQuality = ta.ema(chopScore * 0.18 + readinessScore * 0.42 + ageQuality * 0.22 + edgePressure * 0.10 + volumeQuality * 0.08, smoothLen)
prepState = inChop and decisionAge >= usedMinRangeAge and prePlanQuality >= usedReadinessGate
wasPrepState = bar_index > 0 ? prepState[1] : false
prepEvent = barstate.isconfirmed and prepState and not wasPrepState

barsAfterRange = not na(lastRangeEnd) ? bar_index - lastRangeEnd : 100000
recentMatureRange = not inChop and lastRangeAge >= usedMinRangeAge and barsAfterRange <= usedBoxProjection
releaseUpBoundary = not na(lastRangeHigh) ? lastRangeHigh + safeAtr * breakBufferAtr : na
releaseDownBoundary = not na(lastRangeLow) ? lastRangeLow - safeAtr * breakBufferAtr : na
candidateUpRelease = barstate.isconfirmed and recentMatureRange and bar_index > 0 and not na(releaseUpBoundary) and close > releaseUpBoundary and close[1] <= releaseUpBoundary
candidateDownRelease = barstate.isconfirmed and recentMatureRange and bar_index > 0 and not na(releaseDownBoundary) and close < releaseDownBoundary and close[1] >= releaseDownBoundary

upCloseQuality = (close - low) / barSpan * 100.0
downCloseQuality = (high - close) / barSpan * 100.0
releaseDistance = candidateUpRelease ? math.abs(close - lastRangeHigh) / safeAtr : candidateDownRelease ? math.abs(close - lastRangeLow) / safeAtr : 0.0
releaseDistanceQuality = f_norm(releaseDistance, breakBufferAtr, 1.25)
bodyQuality = f_norm(bodyPct, 35.0, 85.0)
closeQuality = candidateUpRelease ? upCloseQuality : candidateDownRelease ? downCloseQuality : 50.0
breakQuality = candidateUpRelease or candidateDownRelease ? f_clamp(readinessScore * 0.28 + ageQuality * 0.18 + releaseDistanceQuality * 0.22 + bodyQuality * 0.14 + closeQuality * 0.10 + volumeQuality * 0.08, 0.0, 100.0) : prePlanQuality

validUpPlan = candidateUpRelease and breakQuality >= usedMinPlanQuality
validDownPlan = candidateDownRelease and breakQuality >= usedMinPlanQuality
weakRelease = (candidateUpRelease or candidateDownRelease) and breakQuality < usedMinPlanQuality

// -------------------------------------------------
// Confirmation-anchored proof (chop-range releases: Follow = reached first target before invalidation)
// -------------------------------------------------
int releaseDir = candidateUpRelease ? 1 : candidateDownRelease ? -1 : 0
bool releaseEvent = candidateUpRelease or candidateDownRelease

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

int proofWarmup = math.max(rangeBaseLen, math.max(atrBaseLen, volumeLen)) + 5
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
        if naturalResolve or releaseEvent
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
    if releaseEvent and not pEvalActive and releaseDir != 0
        float pBoundary = releaseDir == 1 ? lastRangeHigh : lastRangeLow
        if not na(pBoundary)
            float pRawInvalid = releaseDir == 1 ? pBoundary - safeAtr * riskBufferAtr : pBoundary + safeAtr * riskBufferAtr
            float pRisk = math.max(releaseDir == 1 ? close - pRawInvalid : pRawInvalid - close, safeAtr * 0.25)
            pEvalActive := true
            pEvalDir := releaseDir
            pEvalEntry := close
            pEvalStop := close - releaseDir * pRisk
            pEvalTarget := close + releaseDir * pRisk * targetR1
            pEvalStart := bar_index
            pReacted := false
            pFollowed := false
            pFlipped := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

// -------------------------------------------------
// Planner state
// -------------------------------------------------
var bool planActive = false
var int planSide = 0
var int planStartBar = na
var float planEntry = na
var float planInvalidation = na
var float planRisk = na
var float planTarget1 = na
var float planTarget2 = na
var float activePlanScore = na
var bool target1Reached = false
var bool target2Reached = false
var string planOutcome = "Scan"
var int planOutcomeBar = na

newPlan = validUpPlan or validDownPlan
if newPlan
    planActive := true
    planSide := validUpPlan ? 1 : -1
    planStartBar := bar_index
    planEntry := close
    if planSide == 1
        planInvalidation := lastRangeHigh - safeAtr * riskBufferAtr
        planRisk := math.max(planEntry - planInvalidation, safeAtr * 0.25)
        planInvalidation := planEntry - planRisk
        planTarget1 := planEntry + planRisk * targetR1
        planTarget2 := planEntry + planRisk * targetR2
    else
        planInvalidation := lastRangeLow + safeAtr * riskBufferAtr
        planRisk := math.max(planInvalidation - planEntry, safeAtr * 0.25)
        planInvalidation := planEntry + planRisk
        planTarget1 := planEntry - planRisk * targetR1
        planTarget2 := planEntry - planRisk * targetR2
    activePlanScore := breakQuality
    target1Reached := false
    target2Reached := false
    planOutcome := "Active"

planAge = planActive and not na(planStartBar) ? bar_index - planStartBar : 0
target1Event = barstate.isconfirmed and planActive and not target1Reached and ((planSide == 1 and high >= planTarget1) or (planSide == -1 and low <= planTarget1))
target2Event = barstate.isconfirmed and planActive and not target2Reached and ((planSide == 1 and high >= planTarget2) or (planSide == -1 and low <= planTarget2))
invalidationEvent = barstate.isconfirmed and planActive and planAge > 0 and ((planSide == 1 and close <= planInvalidation) or (planSide == -1 and close >= planInvalidation))
planExpired = barstate.isconfirmed and planActive and planAge > maxPlanBars

if target1Event
    target1Reached := true
    planOutcome := "T1 Reached"
    planOutcomeBar := bar_index
if target2Event
    target2Reached := true
    planOutcome := "T2 Reached"
    planOutcomeBar := bar_index
if invalidationEvent
    planOutcome := "Invalidated"
    planOutcomeBar := bar_index
if planExpired
    planOutcome := "Expired"
    planOutcomeBar := bar_index
if invalidationEvent or planExpired
    planActive := false

previewSide = rangePosition >= 0.5 ? 1 : -1
previewEntry = previewSide == 1 ? decisionHigh : decisionLow
previewRisk = safeAtr * riskBufferAtr
previewInvalidation = previewSide == 1 ? previewEntry - previewRisk : previewEntry + previewRisk
previewTarget1 = previewSide == 1 ? previewEntry + previewRisk * targetR1 : previewEntry - previewRisk * targetR1
previewTarget2 = previewSide == 1 ? previewEntry + previewRisk * targetR2 : previewEntry - previewRisk * targetR2

displayEntry = planActive ? planEntry : prepState ? previewEntry : na
displayInvalidation = planActive ? planInvalidation : prepState ? previewInvalidation : na
displayTarget1 = planActive ? planTarget1 : prepState ? previewTarget1 : na
displayTarget2 = planActive ? planTarget2 : prepState ? previewTarget2 : na
recentPlanOutcome = not na(planOutcomeBar) and bar_index - planOutcomeBar <= usedMarkerCooldown
displayQuality = (planActive or recentPlanOutcome) and not na(activePlanScore) ? activePlanScore : breakQuality

string nextAction = "Scan: No Range"
color actionColor = panelLabelD
if planActive
    if target2Reached
        nextAction := "Review: T2 Reached"
        actionColor := bullColor
    else if target1Reached
        nextAction := "Manage: T1 Reached"
        actionColor := bullColor
    else
        nextAction := planSide == 1 ? "Track Upside Plan" : "Track Downside Plan"
        actionColor := planSide == 1 ? bullColor : bearColor
else if planOutcome == "Invalidated" and recentPlanOutcome
    nextAction := "Reset: Invalidated"
    actionColor := bearColor
else if planOutcome == "Expired" and recentPlanOutcome
    nextAction := "Reset: Expired"
    actionColor := neutralColor
else if weakRelease
    nextAction := "Skip: Low Quality"
    actionColor := neutralColor
else if prepState
    nextAction := "Prepare: Edge Watch"
    actionColor := accentColor
else if inChop
    nextAction := "Avoid: Chop"
    actionColor := neutralColor
else if recentMatureRange
    nextAction := "Wait: Release"
    actionColor := accentColor

string stateText = "Scan"
if planActive
    stateText := "Plan Active"
else if prepState
    stateText := "Preparation"
else if inChop
    stateText := "No-Trade"
else if recentMatureRange
    stateText := "Release Watch"

// -------------------------------------------------
// Visual map
// -------------------------------------------------
labelSize = f_size(labelFontOpt)
var int lastPrepMarkerBar = -100000
var int lastEventMarkerBar = -100000
canPrintPrepMarker = bar_index - lastPrepMarkerBar >= usedMarkerCooldown
canPrintEventMarker = bar_index - lastEventMarkerBar >= usedMarkerCooldown

ribbonColor = prepState ? color.new(accentColor, 86) : color.new(neutralColor, 88)
ribbonBorder = prepState ? color.new(accentColor, 35) : color.new(neutralColor, 42)
plotTop = plot(showNoTradeRibbon and inChop ? activeRangeHigh : na, "No-Trade Ribbon High", color = ribbonBorder, linewidth = 1, style = plot.style_linebr)
plotBottom = plot(showNoTradeRibbon and inChop ? activeRangeLow : na, "No-Trade Ribbon Low", color = ribbonBorder, linewidth = 1, style = plot.style_linebr)
plotMid = plot(showNoTradeRibbon and inChop ? decisionMid : na, "No-Trade Ribbon Mid", color = color.new(headerBg, 62), linewidth = 1, style = plot.style_linebr)
fill(plotTop, plotBottom, color = showNoTradeRibbon and inChop ? ribbonColor : na, title = "No-Trade Ribbon Fill")

color barTintColor = na
if showBarTint
    if planActive
        barTintColor := color.new(planSide == 1 ? bullColor : bearColor, 15)
    else if prepState
        barTintColor := color.new(accentColor, 18)
    else if inChop
        barTintColor := color.new(neutralColor, 48)
barcolor(barTintColor)
bgcolor(showBackdrop and inChop ? color.new(neutralColor, 94) : na, title = "Chop Backdrop")

var box activeBox = na
var label activeBoxLabel = na
boxAllowed = showDecisionRange and inChop and decisionAge >= usedMinRangeAge and not na(activeRangeHigh) and not na(activeRangeLow)
boxBg = prepState ? color.new(accentColor, 87) : color.new(neutralColor, 93)
boxBorder = prepState ? color.new(accentColor, 24) : color.new(neutralColor, 48)
boxText = prepState ? "Prep\nQ " + str.tostring(math.round(prePlanQuality)) : "Chop\nQ " + str.tostring(math.round(chopScore))
boxRight = bar_index + usedBoxProjection
boxCenterX = not na(activeRangeStart) ? int(math.round((activeRangeStart + boxRight) / 2.0)) : bar_index
boxCenterY = not na(activeRangeHigh) and not na(activeRangeLow) ? (activeRangeHigh + activeRangeLow) * 0.5 : close

if boxAllowed
    if na(activeBox)
        activeBox := box.new(activeRangeStart, activeRangeHigh, boxRight, activeRangeLow,
             xloc = xloc.bar_index,
             bgcolor = boxBg,
             border_color = boxBorder,
             border_width = prepState ? 2 : 1)
        if showRangeCenterLabel
            activeBoxLabel := label.new(boxCenterX, boxCenterY, boxText,
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 style = label.style_label_center,
                 color = prepState ? color.new(accentColor, 6) : color.new(panelBgDark, 8),
                 textcolor = headerText,
                 size = labelSize,
                 textalign = text.align_center)
    else
        box.set_left(activeBox, activeRangeStart)
        box.set_right(activeBox, boxRight)
        box.set_top(activeBox, activeRangeHigh)
        box.set_bottom(activeBox, activeRangeLow)
        box.set_bgcolor(activeBox, boxBg)
        box.set_border_color(activeBox, boxBorder)
        box.set_border_width(activeBox, prepState ? 2 : 1)
        if showRangeCenterLabel
            if na(activeBoxLabel)
                activeBoxLabel := label.new(boxCenterX, boxCenterY, boxText,
                     xloc = xloc.bar_index,
                     yloc = yloc.price,
                     style = label.style_label_center,
                     color = prepState ? color.new(accentColor, 6) : color.new(panelBgDark, 8),
                     textcolor = headerText,
                     size = labelSize,
                     textalign = text.align_center)
            else
                label.set_x(activeBoxLabel, boxCenterX)
                label.set_y(activeBoxLabel, boxCenterY)
                label.set_text(activeBoxLabel, boxText)
                label.set_color(activeBoxLabel, prepState ? color.new(accentColor, 6) : color.new(panelBgDark, 8))
                label.set_size(activeBoxLabel, labelSize)
        else if not na(activeBoxLabel)
            label.delete(activeBoxLabel)
            activeBoxLabel := na
else if not na(activeBox) and not inChop
    closedBoxRight = math.max(activeRangeStart, nz(lastRangeEnd, bar_index))
    box.set_right(activeBox, closedBoxRight)
    if not na(activeBoxLabel)
        closedBoxCenterX = int(math.round((activeRangeStart + closedBoxRight) / 2.0))
        label.set_x(activeBoxLabel, closedBoxCenterX)
        label.set_y(activeBoxLabel, boxCenterY)
    f_keep_box(activeBox)
    if not na(activeBoxLabel)
        f_keep_label(activeBoxLabel)
    activeBox := na
    activeBoxLabel := na
else if not showDecisionRange and not na(activeBox)
    box.delete(activeBox)
    f_delete_label(activeBoxLabel)
    activeBox := na
    activeBoxLabel := na

planColor = planSide == 1 ? bullColor : planSide == -1 ? bearColor : accentColor
focusedPlanMap = planMapDensity == "Focused"
stageAnchor = focusedPlanMap and target1Reached ? planTarget1 : planEntry
stageAnchorText = focusedPlanMap and target1Reached ? "T1 HIT" : "Entry"
showT1Stage = not focusedPlanMap or not target1Reached
showT2Stage = not focusedPlanMap or target1Reached
planEntrySeries = showPlanLevels and planActive ? stageAnchor : na
planInvalidSeries = showPlanLevels and planActive ? planInvalidation : na
planTarget1Series = showPlanLevels and planActive and showT1Stage ? planTarget1 : na
planTarget2Series = showPlanLevels and planActive and showT2Stage ? planTarget2 : na
pEntry = plot(planEntrySeries, "Plan Stage Anchor", color = color.new(headerText, 20), linewidth = 1, style = plot.style_linebr)
pInvalid = plot(planInvalidSeries, "Plan Invalidation", color = color.new(bearColor, 0), linewidth = 2, style = plot.style_linebr)
pTarget1 = plot(planTarget1Series, "Plan Target 1", color = color.new(planColor, 0), linewidth = 2, style = plot.style_linebr)
pTarget2 = plot(planTarget2Series, "Plan Target 2", color = color.new(planColor, 35), linewidth = 1, style = plot.style_linebr)
fill(pEntry, pInvalid, color = showPlanLevels and planActive ? color.new(bearColor, 88) : na, title = "Plan Risk Area")
fill(pEntry, pTarget1, color = showPlanLevels and planActive ? color.new(planColor, 90) : na, title = "Plan Target Area")
fill(pEntry, pTarget2, color = showPlanLevels and planActive and focusedPlanMap and showT2Stage ? color.new(planColor, 90) : na, title = "Plan Stage Target Area")

var label entryTag = na
var label invalidTag = na
var label target1Tag = na
var label target2Tag = na
var line entryGuide = na
var line invalidGuide = na
var line target1Guide = na
var line target2Guide = na
if showPlanLevels and showPlanLevelTags and planActive
    tagX = bar_index + planTagOffsetBars
    if na(entryTag)
        entryTag := label.new(tagX, stageAnchor, stageAnchorText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(panelBorderD, 0), textcolor = headerText, size = labelSize)
        invalidTag := label.new(tagX, planInvalidation, "Invalid", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bearColor, 0), textcolor = headerText, size = labelSize)
        entryGuide := line.new(planStartBar, stageAnchor, tagX, stageAnchor, xloc = xloc.bar_index, extend = extend.none, color = color.new(headerText, 35), style = line.style_dotted, width = 1)
        invalidGuide := line.new(planStartBar, planInvalidation, tagX, planInvalidation, xloc = xloc.bar_index, extend = extend.none, color = color.new(bearColor, 0), style = line.style_solid, width = 1)
    else
        label.set_x(entryTag, tagX)
        label.set_y(entryTag, stageAnchor)
        label.set_text(entryTag, stageAnchorText)
        label.set_x(invalidTag, tagX)
        label.set_y(invalidTag, planInvalidation)
        line.set_xy1(entryGuide, planStartBar, stageAnchor)
        line.set_xy2(entryGuide, tagX, stageAnchor)
        line.set_xy1(invalidGuide, planStartBar, planInvalidation)
        line.set_xy2(invalidGuide, tagX, planInvalidation)
    if showT1Stage
        if na(target1Tag)
            target1Tag := label.new(tagX, planTarget1, "T1", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(planColor, 0), textcolor = headerText, size = labelSize)
            target1Guide := line.new(planStartBar, planTarget1, tagX, planTarget1, xloc = xloc.bar_index, extend = extend.none, color = color.new(planColor, 0), style = line.style_solid, width = 1)
        else
            label.set_x(target1Tag, tagX)
            label.set_y(target1Tag, planTarget1)
            line.set_xy1(target1Guide, planStartBar, planTarget1)
            line.set_xy2(target1Guide, tagX, planTarget1)
    else
        f_delete_label(target1Tag)
        f_delete_line(target1Guide)
        target1Tag := na
        target1Guide := na
    if showT2Stage
        target2Text = target2Reached ? "T2 HIT" : "T2"
        if na(target2Tag)
            target2Tag := label.new(tagX, planTarget2, target2Text, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(planColor, 15), textcolor = headerText, size = labelSize)
            target2Guide := line.new(planStartBar, planTarget2, tagX, planTarget2, xloc = xloc.bar_index, extend = extend.none, color = color.new(planColor, 25), style = line.style_dashed, width = 1)
        else
            label.set_x(target2Tag, tagX)
            label.set_y(target2Tag, planTarget2)
            label.set_text(target2Tag, target2Text)
            line.set_xy1(target2Guide, planStartBar, planTarget2)
            line.set_xy2(target2Guide, tagX, planTarget2)
    else
        f_delete_label(target2Tag)
        f_delete_line(target2Guide)
        target2Tag := na
        target2Guide := na
else
    f_delete_label(entryTag)
    f_delete_label(invalidTag)
    f_delete_label(target1Tag)
    f_delete_label(target2Tag)
    f_delete_line(entryGuide)
    f_delete_line(invalidGuide)
    f_delete_line(target1Guide)
    f_delete_line(target2Guide)
    entryTag := na
    invalidTag := na
    target1Tag := na
    target2Tag := na
    entryGuide := na
    invalidGuide := na
    target1Guide := na
    target2Guide := na

prepY = close >= nz(decisionMid, close) ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
prepStyle = close >= nz(decisionMid, close) ? label.style_label_down : label.style_label_up
if showPrepMarkers and prepEvent and canPrintPrepMarker
    prepLabel = label.new(bar_index, prepY, "Prep\nQ " + str.tostring(math.round(prePlanQuality)),
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = prepStyle,
         color = color.new(accentColor, 0),
         textcolor = headerText,
         size = labelSize)
    f_keep_label(prepLabel)
    lastPrepMarkerBar := bar_index

planY = validUpPlan ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
planStyle = validUpPlan ? label.style_label_down : label.style_label_up
planLabelText = validUpPlan ? "Plan Up\nQ " + str.tostring(math.round(breakQuality)) : "Plan Down\nQ " + str.tostring(math.round(breakQuality))
if showPlanMarkers and newPlan and canPrintEventMarker
    planLabel = label.new(bar_index, planY, planLabelText,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = planStyle,
         color = validUpPlan ? color.new(bullColor, 0) : color.new(bearColor, 0),
         textcolor = headerText,
         size = labelSize)
    f_keep_label(planLabel)
    lastEventMarkerBar := bar_index

weakY = candidateUpRelease ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
weakStyle = candidateUpRelease ? label.style_label_down : label.style_label_up
if showPlanMarkers and showWeakReleaseMarkers and weakRelease and canPrintEventMarker
    weakLabel = label.new(bar_index, weakY, "Weak\nQ " + str.tostring(math.round(breakQuality)),
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = weakStyle,
         color = color.new(neutralColor, 0),
         textcolor = panelBgDark,
         size = labelSize)
    f_keep_label(weakLabel)
    lastEventMarkerBar := bar_index

targetY = planSide == 1 ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
targetStyle = planSide == 1 ? label.style_label_down : label.style_label_up
if showPlanMarkers and target1Event and canPrintEventMarker
    targetLabel = label.new(bar_index, targetY, "T1\n" + str.tostring(targetR1) + "R",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = targetStyle,
         color = color.new(planColor, 0),
         textcolor = headerText,
         size = labelSize)
    f_keep_label(targetLabel)
    lastEventMarkerBar := bar_index

if showPlanMarkers and target2Event and canPrintEventMarker
    target2Label = label.new(bar_index, targetY, "T2\n" + str.tostring(targetR2) + "R",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = targetStyle,
         color = color.new(planColor, 0),
         textcolor = headerText,
         size = labelSize)
    f_keep_label(target2Label)
    lastEventMarkerBar := bar_index

invalidY = planSide == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
invalidStyle = planSide == 1 ? label.style_label_up : label.style_label_down
if showPlanMarkers and invalidationEvent and canPrintEventMarker
    invalidLabel = label.new(bar_index, invalidY, "Invalid",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = invalidStyle,
         color = color.new(bearColor, 0),
         textcolor = headerText,
         size = labelSize)
    f_keep_label(invalidLabel)
    lastEventMarkerBar := bar_index

// -------------------------------------------------
// Panel
// -------------------------------------------------
isLightPanel = panelThemeOpt == "Light"
panelBg = f_panel_bg(isLightPanel, false)
panelBgAlt = f_panel_bg(isLightPanel, true)
panelBorder = isLightPanel ? panelBorderL : panelBorderD
panelLabelCol = isLightPanel ? panelLabelL : panelLabelD
panelValueCol = isLightPanel ? panelValueL : panelValueD
panelSize = f_size(panelFontOpt)

qualityText = str.tostring(math.round(displayQuality)) + " / 100"
chopReadyText = "C " + str.tostring(math.round(chopScore)) + " | R " + str.tostring(math.round(readinessScore))
ageText = str.tostring(decisionAge) + " bars"
invalidationText = na(displayInvalidation) ? "Await setup" : f_price(displayInvalidation)
targetText = na(displayTarget1) or na(displayTarget2) ? "Await setup" : f_price(displayTarget1) + " / " + f_price(displayTarget2)
proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) : "building"

int panelRowCount = showProof ? 12 : 7
var table plannerPanel = na
var string lastPanelPos = ""
var string lastPanelTheme = ""
var string lastPanelFont = ""
var bool lastPanelVisible = false
var bool lastProofMode = false

bool panelNeedsBuild = showPanel and (na(plannerPanel) or panelPositionOpt != lastPanelPos or panelThemeOpt != lastPanelTheme or panelFontOpt != lastPanelFont or not lastPanelVisible or showProof != lastProofMode)
if panelNeedsBuild
    if not na(plannerPanel)
        table.delete(plannerPanel)
    plannerPanel := table.new(f_pos(panelPositionOpt), 2, panelRowCount, bgcolor = panelBg, frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)
    table.cell(plannerPanel, 0, 0, "AG Pro Choppiness Setup Planner", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    table.cell(plannerPanel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
    table.merge_cells(plannerPanel, 0, 0, 1, 0)
    lastPanelPos := panelPositionOpt
    lastPanelTheme := panelThemeOpt
    lastPanelFont := panelFontOpt
    lastPanelVisible := true
    lastProofMode := showProof

if not showPanel and not na(plannerPanel)
    table.delete(plannerPanel)
    plannerPanel := na
    lastPanelVisible := false

if showPanel and not na(plannerPanel) and barstate.islast
    table.set_position(plannerPanel, f_pos(panelPositionOpt))
    table.clear(plannerPanel, 0, 1, 1, panelRowCount - 1)
    table.cell(plannerPanel, 0, 0, "AG Pro Choppiness Setup Planner", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    table.cell(plannerPanel, 0, 1, "Setup Quality", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(plannerPanel, 1, 1, qualityText, text_color = panelValueCol, bgcolor = displayQuality >= usedMinPlanQuality ? color.new(bullColor, 68) : displayQuality >= usedReadinessGate ? color.new(accentColor, 72) : panelBg, text_size = panelSize, text_halign = text.align_right)
    table.cell(plannerPanel, 0, 2, "Next Action", text_color = panelLabelCol, bgcolor = panelBgAlt, text_size = panelSize, text_halign = text.align_left)
    table.cell(plannerPanel, 1, 2, nextAction, text_color = panelValueCol, bgcolor = color.new(actionColor, 70), text_size = panelSize, text_halign = text.align_right)
    table.cell(plannerPanel, 0, 3, "Chop / Ready", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(plannerPanel, 1, 3, chopReadyText, text_color = panelValueCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)
    table.cell(plannerPanel, 0, 4, "Range Age", text_color = panelLabelCol, bgcolor = panelBgAlt, text_size = panelSize, text_halign = text.align_left)
    table.cell(plannerPanel, 1, 4, ageText, text_color = panelValueCol, bgcolor = decisionAge >= usedMinRangeAge ? color.new(neutralColor, 76) : panelBgAlt, text_size = panelSize, text_halign = text.align_right)
    table.cell(plannerPanel, 0, 5, "Invalidation", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(plannerPanel, 1, 5, invalidationText, text_color = panelValueCol, bgcolor = not na(displayInvalidation) ? color.new(bearColor, 78) : panelBg, text_size = panelSize, text_halign = text.align_right)
    table.cell(plannerPanel, 0, 6, "Targets", text_color = panelLabelCol, bgcolor = panelBgAlt, text_size = panelSize, text_halign = text.align_left)
    table.cell(plannerPanel, 1, 6, targetText, text_color = panelValueCol, bgcolor = not na(displayTarget1) ? color.new(actionColor, 80) : panelBgAlt, text_size = panelSize, text_halign = text.align_right)
    if showProof
        table.cell(plannerPanel, 0, 7, "Proof @ Confirm", text_color = accentColor, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(plannerPanel, 1, 7, proofSampleText, text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)
        table.cell(plannerPanel, 0, 8, "Follow Rate", text_color = panelLabelCol, bgcolor = panelBgAlt, text_size = panelSize, text_halign = text.align_left)
        table.cell(plannerPanel, 1, 8, proofTotal > 0 ? f_pct(followRate) : "-", text_color = proofTotal > 0 ? f_rate_color(followRate) : panelValueCol, bgcolor = panelBgAlt, text_size = panelSize, text_halign = text.align_right)
        table.cell(plannerPanel, 0, 9, "Hold Rate", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(plannerPanel, 1, 9, proofTotal > 0 ? f_pct(holdRate) : "-", text_color = proofTotal > 0 ? f_rate_color(holdRate) : panelValueCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)
        table.cell(plannerPanel, 0, 10, "React Rate", text_color = panelLabelCol, bgcolor = panelBgAlt, text_size = panelSize, text_halign = text.align_left)
        table.cell(plannerPanel, 1, 10, proofTotal > 0 ? f_pct(reactRate) : "-", text_color = proofTotal > 0 ? f_rate_color(reactRate) : panelValueCol, bgcolor = panelBgAlt, text_size = panelSize, text_halign = text.align_right)
        table.cell(plannerPanel, 0, 11, "Flip Rate", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(plannerPanel, 1, 11, proofTotal > 0 ? f_pct(flipRate) : "-", text_color = proofTotal > 0 ? f_flip_color(flipRate) : panelValueCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

// -------------------------------------------------
// Alerts And Hidden Exports
// -------------------------------------------------
alertcondition(alertPrep and prepEvent, "CSP Preparation State", "Choppiness Setup Planner: a mature no-trade range has entered preparation state.")
alertcondition(alertPlans and validUpPlan, "CSP Valid Upside Plan", "Choppiness Setup Planner: upside release reached the minimum valid plan score.")
alertcondition(alertPlans and validDownPlan, "CSP Valid Downside Plan", "Choppiness Setup Planner: downside release reached the minimum valid plan score.")
alertcondition(weakRelease, "CSP Weak Release", "Choppiness Setup Planner: range release occurred but did not meet the minimum valid plan score.")
alertcondition(alertPlanEvents and target1Event, "CSP Target 1 Reached", "Choppiness Setup Planner: active plan reached Target 1.")
alertcondition(alertPlanEvents and target2Event, "CSP Target 2 Reached", "Choppiness Setup Planner: active plan reached Target 2.")
alertcondition(alertPlanEvents and invalidationEvent, "CSP Invalidation", "Choppiness Setup Planner: active plan crossed its invalidation level.")

plot(chopScore, "CSP Chop Score", display = display.none)
plot(readinessScore, "CSP Readiness Score", display = display.none)
plot(displayQuality, "CSP Setup Quality", display = display.none)
plot(followRate, "CSP Follow Rate", display = display.none)
plot(holdRate, "CSP Hold Rate", display = display.none)
plot(reactRate, "CSP React Rate", display = display.none)
plot(flipRate, "CSP Flip Rate", display = display.none)
````

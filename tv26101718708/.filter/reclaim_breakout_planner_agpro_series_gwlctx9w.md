# Reclaim Breakout Planner [AGPro Series]

- url: https://www.tradingview.com/script/GWlCTx9w-Reclaim-Breakout-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;fe79dda6e2f74820b8b40b332611f150
- version: 6.0

## Description

Reclaim Breakout Planner [AGPro Series]


🧠 Core Idea

Is a recently broken structural level being lost and reclaimed in a way that creates a valid breakout planning area?


📌 Overview / What it does

Reclaim Breakout Planner [AGPro Series] is a chart-first breakout planning tool built around structural pivot reclaim behavior. It detects when price breaks beyond a confirmed pivot level, temporarily moves back through that broken level, and then closes back on the breakout side with measurable acceptance quality.

The script produces a 0-100 Acceptance Score, an active Reclaim State, an Acceptance Pocket, a Risk Edge, a Target Corridor, controlled chart labels, and a compact AG Pro panel. The goal is to help traders organize reclaim context after a structural breakout attempt.

This script does not predict price direction, automate trades, or mark every pivot as important. It filters for a specific sequence: structural level break -> temporary level loss -> reclaim close -> planning state.


🎯 Purpose & Design Philosophy

Many breakout tools stop after price crosses a level. Many retest tools treat any return to the level as meaningful. This script was built for the narrower question that often matters after a breakout: did price briefly lose the broken level and then reclaim it with enough quality to deserve attention?

It is designed for traders who want a cleaner decision-support layer around breakout acceptance, not another crowded support/resistance map. The mindset is planning first: evaluate validity, score quality, locate risk, estimate target room, and decide whether the context deserves monitoring.


⚡ Why This Script Is Different

Most tools focus on the breakout candle or the retest touch.

This script does NOT clone VWAP Reclaim Quality, Previous Day Sweep & Reclaim, EMA reclaim maps, session VWAP reaction tools, or a simple breakout retest readiness model.

Instead, it focuses on structural pivot reclaim after a level is briefly lost. The reclaim must come from a confirmed pivot break, a temporary move back through the broken level, and a close back on the breakout side. That creates a distinct reclaim-planning workflow rather than a generic level scanner.


⚙️ Methodology

1. Context Detection
The script identifies confirmed pivot highs and pivot lows as structural levels. These levels are not VWAP, previous-day highs/lows, session anchors, order blocks, or fixed support/resistance zones.

2. Breakout Arming
When price closes beyond a pivot level by an ATR-normalized amount, the planner arms a reclaim watch. A bullish watch begins after a close above resistance. A bearish watch begins after a close below support.

3. Reclaim Evaluation
The script waits for price to temporarily lose the broken level and then close back through it. It scores the event using reclaim close distance, retest depth, volume support, trend alignment, and wick rejection.

4. Visual Output
Accepted reclaims create an Acceptance Pocket, Risk Edge, Target Corridor, event labels, sparse context labels, and panel state. The visuals are designed to stay readable without leaving the chart empty.


🗺️ How to Read the Chart

Acceptance Pocket = the reclaimed structural level area where the breakout side is being tested.

Risk Edge = the failed-side reference beyond the pocket. It is a planning boundary, not a trading instruction.

Target Corridor = a projected review area based on the reclaim risk distance and the selected R multiple.

Labels = compact event and context markers such as Bull Reclaim, Bear Reclaim, Retest Watch, and Failed Reclaim. Target Review labels are optional because the target corridor already marks the review area.

Colors = bullish reclaim context uses teal, bearish reclaim context uses pink, caution/watch states use gold or indigo, and risk/failure context uses red.

Panel = shows Reclaim State, Acceptance Score, Risk Edge, Target Room, and Action.


🚦 Signals & States

• Scan Structure → no active reclaim plan exists yet.

• Bull Retest Watch → price broke above a structural pivot and is waiting for a valid reclaim sequence.

• Bear Retest Watch → price broke below a structural pivot and is waiting for a valid reclaim sequence.

• Acceptance Watch → reclaim exists, but the score is not strong enough for the highest planning state.

• Plan Review → reclaim quality is strong enough to monitor as structured planning context.

• Risk Edge Test → price is testing the failed-side boundary.

• Failed Reclaim → the active reclaim plan closed beyond the risk edge.

• Target Review → price reached the projected target corridor area.


🔔 Alerts Logic

Bullish Reclaim Breakout Plan triggers when a bullish structural reclaim is accepted and the score is above the alert threshold.

Bearish Reclaim Breakout Plan triggers when a bearish structural reclaim is accepted and the score is above the alert threshold.

Reclaim Risk Edge Failed triggers when an active reclaim plan closes beyond the risk edge.

Reclaim Target Corridor Reached triggers when price reaches the projected target corridor.

Alerts are attention markers. They are not trade instructions.


🧩 Confluence Logic

The context becomes stronger when a confirmed pivot breakout, temporary level loss, reclaim close, supportive volume, trend alignment, and wick rejection appear together. The score compresses those components into one readable 0-100 Acceptance Score.


📊 When to Use

• After structural breakouts where price returns to the broken level

• During trending or transitioning markets where reclaim behavior matters

• When evaluating whether a breakout level is being accepted after a brief failure

• When a trader needs risk edge and target-room context around a reclaim sequence


⚠️ When NOT to Use

• Very low-liquidity symbols with unreliable volume and erratic candles

• Extremely noisy ranges where pivots form too frequently

• News-driven candles where ATR-normalized structure can be distorted

• Markets where price is far from any meaningful structural pivot


🎛️ Key Inputs

• Reclaim Side → selects Auto, Bullish Only, or Bearish Only.

• Pivot Strength → controls how selective structural levels are.

• Minimum Break Close ATR → defines how far beyond the pivot price must close before a reclaim watch is armed.

• Minimum Level Loss ATR → requires price to temporarily move back through the broken level before reclaim evaluation.

• Acceptance Pocket ATR → controls the visual and logical reclaim pocket size.

• Retest Window Bars → controls how long the reclaim watch remains valid.

• Risk Edge Buffer ATR → adjusts the failed-side planning boundary.

• Target Corridor R Multiple → controls the projected target review area.

• Label and Panel Settings → control chart label density, optional target review labels, font size, panel location, and panel theme.


🖥️ Interface & Visual Design

The interface is intentionally compact. The chart carries the main decision layer through acceptance pockets, risk edges, target corridors, and event labels. The panel acts as a quick readout for state, score, risk, target room, and next action.

The first panel row follows the AGPro style with a merged blue title row. Label density is controlled by cooldown and maximum visible label settings so the chart remains premium and readable.


🧪 Practical Usage Workflow

1. Read the panel state.

2. Check whether the planner is scanning, watching a retest, or showing an accepted reclaim.

3. Inspect the Acceptance Pocket and Risk Edge.

4. Compare the Acceptance Score with the active state.

5. Use the Target Corridor as a review area, not as a guaranteed objective.


🔍 Interpretation Guidelines

A high score means the reclaim sequence is cleaner under the script's rules. It does not mean the market must continue.

A weak score means the reclaim lacks enough acceptance quality, volume support, trend alignment, or wick rejection.

A failed reclaim means the planning structure has weakened and should be re-evaluated in broader market context.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not auto trading

• Not guaranteed signals

• Not a VWAP reclaim tool

• Not a previous-day sweep reclaim script

• Not a generic support/resistance map

• Not an order block or FVG scanner


⚠️ Limitations & Transparency

Timeframe selection affects pivot behavior. Lower timeframes may create more reclaim sequences, while higher timeframes may produce fewer but more important structural levels.

Volatility can widen pockets and risk edges. During extreme volatility, reclaim signals can appear later or fail faster.

Volume quality may be less reliable on markets where reported volume is synthetic, incomplete, or inconsistent.


🧠 Market Context Notes

Reclaim behavior often matters when a market tests whether a broken level is becoming accepted. A clean reclaim can show that a breakout area is still being defended. A failed reclaim can show that the attempted breakout lost structure.

The script treats that behavior as planning context, not certainty.


🧾 Use Case Examples

When price closes above a pivot high, dips back below the broken level, then closes back above it with rejection wick and supportive volume, the planner may create a bullish reclaim plan.

When price closes below a pivot low, trades back above the broken level, then closes back below it with rejection behavior, the planner may create a bearish reclaim plan.


🧱 System Philosophy

AGPro tools are designed to help traders organize context, not chase isolated signals. This script follows that principle by turning reclaim behavior into a structured planning workflow with score, state, risk edge, target room, and action text.


🔐 Non-Promise Statement

No script can guarantee continuation, reversal, or future price behavior. Reclaim structure can fail, especially in fast, illiquid, or news-driven markets.


📉 Risk Disclosure

Trading involves risk. This script is for educational and analytical use only. It does not provide financial advice, investment advice, or guaranteed trading outcomes. Users remain responsible for their own decisions.


📚 Educational Note

Use the script to study how reclaimed structural levels behave across symbols, timeframes, and volatility environments. The best use is disciplined observation, comparison, and context building.

## Source Code

````pine
// -------------------------------------------------
// Reclaim Breakout Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.10
//
// Reclaim Breakout Planner converts structural level reclaim behavior into a
// chart-first breakout planning overlay. It detects when a recently broken
// pivot level is briefly lost and then reclaimed by close, scores acceptance
// quality, maps a risk edge and target-room corridor, and summarizes the
// current review workflow without acting as a prediction engine.
// V1.10 separates centered zone badges and right-side price tags into dedicated
// horizontal lanes, preventing visual superposition while preserving the core
// structural breakout, temporary loss, and reclaim acceptance model.
// -------------------------------------------------

//@version=6
indicator("Reclaim Breakout Planner [AGPro Series]",
     shorttitle       = "AG RBP",
     overlay          = true,
     max_boxes_count  = 4,
     max_labels_count = 40,
     max_lines_count  = 12)

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
darkText      = color.rgb(17, 24, 39)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
const string TT_SIDE = "Selects which reclaim side the planner evaluates. Auto reads fresh structural pivot breakouts, while manual modes focus only on bullish or bearish reclaim planning."
const string TT_CONFIRM = "When enabled, breakout arming, reclaim labels, and alerts are confirmed only after bar close for stable public chart behavior."
const string TT_PIVOT = "Defines how many bars are required on each side of a structural pivot. Higher values produce fewer but stronger reclaim levels."
const string TT_ATR = "ATR normalizes reclaim distance, pocket height, risk edge spacing, target corridor width, and label offset across symbols."
const string TT_VOLUME = "Volume baseline used to judge whether reclaim acceptance has participation. On symbols without reliable volume, the volume component becomes neutral."
const string TT_FAST = "Fast EMA used only for trend alignment inside the score model. It does not generate standalone signals."
const string TT_SLOW = "Slow EMA used only for broader trend alignment inside the score model."
const string TT_BREAK = "Minimum close beyond a structural pivot, in ATR terms, required before the planner arms a reclaim watch."
const string TT_LOSS = "Minimum temporary move back through the broken level, in ATR terms, required before a retest can qualify as a reclaim sequence."
const string TT_RECLAIM = "Minimum close back beyond the reclaimed level, in ATR terms, required before the retest can qualify as accepted."
const string TT_POCKET = "ATR-based height of the acceptance pocket around the reclaimed structural level."
const string TT_RETEST = "Maximum number of bars after the breakout close where the retest and reclaim sequence can remain valid."
const string TT_RISK = "ATR buffer placed beyond the failed side of the reclaim pocket to define the planner risk edge."
const string TT_TARGET = "Risk multiple projected from the reclaimed level to draw the target corridor. This is a planning reference, not a forecast."
const string TT_READY = "Minimum 0-100 acceptance score required for REVIEW RECLAIM state. This is an attention state, not a trade instruction."
const string TT_WATCH = "Minimum 0-100 score required for WATCH HOLD state."
const string TT_EXPIRY = "Maximum number of bars an unresolved accepted reclaim remains active before the planner returns to fresh monitoring."
const string TT_RESOLVED = "Number of bars a confirmed failed or target-reached plan remains visible for review before the chart returns to fresh monitoring."
const string TT_LEVELS = "Shows the reclaimed structural level, risk edge, and target guide lines for the active plan."
const string TT_POCKET_SHOW = "Shows the acceptance pocket around the reclaimed pivot level with a centered premium badge."
const string TT_TARGET_SHOW = "Shows the projected target-room corridor with a centered premium badge."
const string TT_RIGHT_TAGS = "Shows staggered right-side price tags for the reclaim level, risk edge, and target guide. Enabled by default so every active planning line remains identifiable."
const string TT_GLOW = "Optionally applies a subtle state color to active reclaim bars. Disabled by default for clean public chart screenshots."
const string TT_EVENTS = "Shows compact event labels for reclaim acceptance, weak reclaim, failed reclaim, and target review states."
const string TT_TARGET_LABELS = "Shows target-corridor review labels after an active reclaim reaches its projection."
const string TT_CONTEXT = "Adds sparse context labels while a breakout is armed or an accepted reclaim remains active. These labels are intentionally compact to keep the chart readable."
const string TT_COOLDOWN = "Minimum number of bars between event labels. Higher values reduce label clustering."
const string TT_CONTEXT_SPACING = "Minimum number of bars between sparse context labels."
const string TT_MAX_LABELS = "Maximum number of visible chart labels retained by the script. Older labels are deleted first for performance."
const string TT_PROJECTION = "Number of bars projected to the right for acceptance pocket, risk edge, level, and target corridor visuals."
const string TT_LABEL_OFFSET = "ATR-based vertical offset that keeps labels above or below candles."
const string TT_SCORE_LABEL = "Adds the 0-100 acceptance score to chart labels."
const string TT_LABEL_SIZE = "Controls all chart label sizes, including centered zone badges and right-side tags. Normal is the recommended publication default."
const string TT_PANEL_SHOW = "Shows or hides the AG Pro planning panel. It is shown by default for public-release readability."
const string TT_PANEL_LOCATION = "Moves the AG Pro panel to the preferred chart location."
const string TT_PANEL_THEME = "Switches the panel between the premium AGPro dark theme and a clean light theme."
const string TT_PANEL_SIZE = "Controls the font size used inside the AG Pro panel. Normal is the recommended publication default."
const string TT_ALERT_TOGGLE = "Enables alert conditions for accepted reclaim, failed risk edge, and target corridor review states."
const string TT_ALERT = "Minimum acceptance score required before reclaim alert conditions can trigger."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Reclaim Engine"
sideMode = input.string("Auto", "Reclaim Side", options = ["Auto", "Bullish Only", "Bearish Only"], group = groupEngine, tooltip = TT_SIDE)
confirmOnClose = input.bool(true, "Confirm On Bar Close", group = groupEngine, tooltip = TT_CONFIRM)
pivotLeft = input.int(4, "Pivot Left Strength", minval = 2, maxval = 20, group = groupEngine, tooltip = TT_PIVOT)
pivotRight = input.int(4, "Pivot Right Strength", minval = 2, maxval = 20, group = groupEngine, tooltip = TT_PIVOT)
atrLength = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = TT_ATR)
volumeLength = input.int(34, "Volume Baseline Length", minval = 5, maxval = 200, group = groupEngine, tooltip = TT_VOLUME)
fastEmaLength = input.int(21, "Fast Context EMA", minval = 1, maxval = 200, group = groupEngine, tooltip = TT_FAST)
slowEmaLength = input.int(55, "Slow Context EMA", minval = 2, maxval = 300, group = groupEngine, tooltip = TT_SLOW)

groupPlanner = "Planner Model"
minimumBreakAtr = input.float(0.16, "Minimum Break Close ATR", minval = 0.01, maxval = 2.00, step = 0.01, group = groupPlanner, tooltip = TT_BREAK)
minimumLevelLossAtr = input.float(0.04, "Minimum Level Loss ATR", minval = 0.00, maxval = 1.00, step = 0.01, group = groupPlanner, tooltip = TT_LOSS)
minimumReclaimAtr = input.float(0.05, "Minimum Reclaim Close ATR", minval = 0.00, maxval = 1.00, step = 0.01, group = groupPlanner, tooltip = TT_RECLAIM)
acceptancePocketAtr = input.float(0.38, "Acceptance Pocket ATR", minval = 0.05, maxval = 2.50, step = 0.01, group = groupPlanner, tooltip = TT_POCKET)
retestWindowBars = input.int(28, "Retest Window Bars", minval = 3, maxval = 160, group = groupPlanner, tooltip = TT_RETEST)
riskBufferAtr = input.float(0.18, "Risk Edge Buffer ATR", minval = 0.00, maxval = 2.00, step = 0.01, group = groupPlanner, tooltip = TT_RISK)
targetRMultiple = input.float(1.60, "Target Corridor R Multiple", minval = 0.25, maxval = 5.00, step = 0.05, group = groupPlanner, tooltip = TT_TARGET)
planReviewThreshold = input.int(72, "REVIEW RECLAIM Threshold", minval = 45, maxval = 95, group = groupPlanner, tooltip = TT_READY)
watchThreshold = input.int(56, "WATCH HOLD Threshold", minval = 25, maxval = 90, group = groupPlanner, tooltip = TT_WATCH)
planExpiryBars = input.int(64, "Active Plan Expiry Bars", minval = 8, maxval = 240, group = groupPlanner, tooltip = TT_EXPIRY)
resolvedDisplayBars = input.int(12, "Resolved Plan Display Bars", minval = 2, maxval = 80, group = groupPlanner, tooltip = TT_RESOLVED)

groupVisual = "Chart Visuals"
showPlanLevels = input.bool(true, "Show Reclaim / Risk / Target Lines", group = groupVisual, tooltip = TT_LEVELS)
showAcceptancePocket = input.bool(true, "Show Acceptance Pocket", group = groupVisual, tooltip = TT_POCKET_SHOW)
showTargetCorridor = input.bool(true, "Show Target Corridor", group = groupVisual, tooltip = TT_TARGET_SHOW)
showRightSideTags = input.bool(true, "Show Right-Side Level Tags", group = groupVisual, tooltip = TT_RIGHT_TAGS)
showStateGlow = input.bool(false, "Color Bars By State", group = groupVisual, tooltip = TT_GLOW)
projectionBars = input.int(40, "Forward Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = TT_PROJECTION)

groupLabels = "Labels"
showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = TT_EVENTS)
showTargetReviewLabels = input.bool(true, "Show Target Review Labels", group = groupLabels, tooltip = TT_TARGET_LABELS)
showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = TT_CONTEXT)
labelCooldownBars = input.int(18, "Event Label Cooldown", minval = 1, maxval = 120, group = groupLabels, tooltip = TT_COOLDOWN)
contextSpacingBars = input.int(84, "Context Label Spacing", minval = 6, maxval = 180, group = groupLabels, tooltip = TT_CONTEXT_SPACING)
maxVisibleLabels = input.int(10, "Max Visible Labels", minval = 4, maxval = 60, group = groupLabels, tooltip = TT_MAX_LABELS)
labelOffsetAtr = input.float(1.05, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = TT_LABEL_OFFSET)
showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = TT_SCORE_LABEL)
labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = TT_LABEL_SIZE)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = TT_PANEL_SHOW)
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = TT_PANEL_LOCATION)
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = TT_PANEL_THEME)
panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = TT_PANEL_SIZE)

groupAlerts = "Alerts"
alertReclaimStates = input.bool(true, "Alert on Reclaim States", group = groupAlerts, tooltip = TT_ALERT_TOGGLE)
alertScoreThreshold = input.int(72, "Minimum Alert Score", minval = 40, maxval = 95, group = groupAlerts, tooltip = TT_ALERT)

groupProof = "Proof"
showProof = input.bool(true, "Show Proof Layer", group = groupProof, tooltip = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across accepted reclaims on the current symbol and timeframe. Follow means price reached the target corridor before the risk edge. These are historical outcome rates, not predictions.")
proofReactBars = input.int(3, "Reaction Window Bars", minval = 1, maxval = 40, group = groupProof, tooltip = "Number of bars after an accepted reclaim used to detect an immediate favorable reaction toward the target corridor.")
proofReactProgressPct = input.float(40.0, "Reaction Progress %", minval = 5.0, maxval = 90.0, step = 1.0, group = groupProof, tooltip = "Minimum favorable progress toward the target corridor, within the reaction window, required to count as an early React.")

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

f_text_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(string locationInput) =>
    switch locationInput
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_fmt_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_fmt(float value) =>
    na(value) ? "-" : str.tostring(value, "#.##")

f_rate_pct(value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(value) =>
    value >= 55.0 ? bullColor : value >= 40.0 ? neutralColor : bearColor

f_flip_color(value) =>
    value <= 30.0 ? bullColor : value <= 55.0 ? neutralColor : bearColor

f_score_grade(float scoreValue) =>
    string grade = "E"
    if scoreValue >= 86
        grade := "A+"
    else if scoreValue >= 78
        grade := "A"
    else if scoreValue >= 68
        grade := "B"
    else if scoreValue >= 56
        grade := "C"
    else if scoreValue >= 44
        grade := "D"
    grade

f_side_color(int direction) =>
    direction == 1 ? bullColor : direction == -1 ? bearColor : neutralColor

f_score_color(float scoreValue, int direction) =>
    scoreValue >= planReviewThreshold ? f_side_color(direction) : scoreValue >= watchThreshold ? neutralColor : dangerColor

f_panel_bg(string theme) =>
    theme == "Clean Light" ? color.rgb(248, 250, 252) : panelBg

f_panel_border(string theme) =>
    theme == "Clean Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string theme, int row) =>
    bool evenRow = row % 2 == 0
    if theme == "Clean Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(248, 250, 252)
    else
        evenRow ? color.rgb(20, 31, 52) : panelBg

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontInput) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_text_size(fontInput), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(fontInput), text_halign = text.align_right)

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        label oldLabel = array.shift(labels)
        label.delete(oldLabel)

f_delete_box(box id) =>
    if not na(id)
        box.delete(id)

f_delete_line(line id) =>
    if not na(id)
        line.delete(id)

f_delete_label(label id) =>
    if not na(id)
        label.delete(id)

f_state_color(string stateText, int direction) =>
    color result = neutralColor
    if stateText == "Review Reclaim"
        result := f_side_color(direction)
    else if stateText == "Watch Hold" or stateText == "Watch Bull Retest" or stateText == "Watch Bear Retest"
        result := accentColor
    else if stateText == "Test Risk" or stateText == "Plan Failed"
        result := dangerColor
    else if stateText == "Target Reached"
        result := bullColor
    result

f_tag_set(label id, int xValue, float yValue, string textValue, color bgValue, string sizeInput) =>
    label result = id
    if na(result)
        result := label.new(xValue, yValue, textValue, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = headerText, color = color.new(bgValue, 0), size = f_text_size(sizeInput))
    else
        label.set_xy(result, xValue, yValue)
        label.set_text(result, textValue)
        label.set_color(result, color.new(bgValue, 0))
        label.set_textcolor(result, headerText)
        label.set_size(result, f_text_size(sizeInput))
    result

// -------------------------------------------------
// Core Measurements
// -------------------------------------------------
chartLabelSize = f_text_size(labelFontSize)
confirmedBar = not confirmOnClose or barstate.isconfirmed
atrRaw = ta.atr(atrLength)
safeAtr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
fastEma = ta.ema(close, fastEmaLength)
slowEma = ta.ema(close, slowEmaLength)

rawVolume = na(volume) ? 1.0 : volume
volumeBase = ta.sma(rawVolume, volumeLength)
volumeRatio = not na(volumeBase) and volumeBase > 0.0 ? rawVolume / volumeBase : 1.0

pivotHighValue = ta.pivothigh(high, pivotLeft, pivotRight)
pivotLowValue = ta.pivotlow(low, pivotLeft, pivotRight)

var float lastResistance = na
var int lastResistanceBar = na
var float lastSupport = na
var int lastSupportBar = na

if not na(pivotHighValue)
    lastResistance := pivotHighValue
    lastResistanceBar := bar_index - pivotRight

if not na(pivotLowValue)
    lastSupport := pivotLowValue
    lastSupportBar := bar_index - pivotRight

allowBull = sideMode == "Auto" or sideMode == "Bullish Only"
allowBear = sideMode == "Auto" or sideMode == "Bearish Only"
canUseResistance = allowBull and not na(lastResistance) and not na(lastResistanceBar) and bar_index > lastResistanceBar + pivotRight
canUseSupport = allowBear and not na(lastSupport) and not na(lastSupportBar) and bar_index > lastSupportBar + pivotRight

bullBreakLevel = canUseResistance ? lastResistance + safeAtr * minimumBreakAtr : na
bearBreakLevel = canUseSupport ? lastSupport - safeAtr * minimumBreakAtr : na
bullBreakout = canUseResistance and confirmedBar and close > bullBreakLevel and nz(close[1], close) <= bullBreakLevel
bearBreakout = canUseSupport and confirmedBar and close < bearBreakLevel and nz(close[1], close) >= bearBreakLevel

// -------------------------------------------------
// Reclaim State
// -------------------------------------------------
var int armedDirection = 0
var float armedLevel = na
var int armedBar = na
var float armedBreakExtreme = na

if bullBreakout
    armedDirection := 1
    armedLevel := lastResistance
    armedBar := bar_index
    armedBreakExtreme := high
else if bearBreakout
    armedDirection := -1
    armedLevel := lastSupport
    armedBar := bar_index
    armedBreakExtreme := low

armedActive = armedDirection != 0 and not na(armedLevel) and not na(armedBar)
armedAge = armedActive ? bar_index - armedBar : 0
armedExpired = armedActive and armedAge > retestWindowBars
armedInvalid = armedActive and (armedDirection == 1 ? close < armedLevel - safeAtr * acceptancePocketAtr : close > armedLevel + safeAtr * acceptancePocketAtr)

if armedExpired or armedInvalid
    armedDirection := 0
    armedLevel := na
    armedBar := na
    armedBreakExtreme := na

armedActive := armedDirection != 0 and not na(armedLevel) and not na(armedBar)
armedAge := armedActive ? bar_index - armedBar : 0

pocketTouched = armedActive and armedAge > 0 and (armedDirection == 1 ? low <= armedLevel - safeAtr * minimumLevelLossAtr : high >= armedLevel + safeAtr * minimumLevelLossAtr)
reclaimCloseDistanceAtr = armedActive ? (armedDirection == 1 ? (close - armedLevel) / safeAtr : (armedLevel - close) / safeAtr) : 0.0
reclaimClose = armedActive and reclaimCloseDistanceAtr >= minimumReclaimAtr
reclaimCandidate = confirmedBar and pocketTouched and reclaimClose

barRange = math.max(high - low, syminfo.mintick)
closeLocation = armedDirection == 1 ? (close - low) / barRange : (high - close) / barRange
bodyShare = math.abs(close - open) / barRange
lowerWick = (math.min(open, close) - low) / barRange
upperWick = (high - math.max(open, close)) / barRange
reclaimWick = armedDirection == 1 ? lowerWick : upperWick
reclaimDepthAtr = armedActive ? math.max(armedDirection == 1 ? armedLevel - low : high - armedLevel, 0.0) / safeAtr : 0.0

bullTrendAligned = close >= slowEma and fastEma >= slowEma
bearTrendAligned = close <= slowEma and fastEma <= slowEma
trendScore = armedDirection == 1 ? (bullTrendAligned ? 100.0 : close >= slowEma ? 68.0 : 32.0) : armedDirection == -1 ? (bearTrendAligned ? 100.0 : close <= slowEma ? 68.0 : 32.0) : 50.0
reclaimCloseScore = f_norm_high_good(reclaimCloseDistanceAtr, 0.0, math.max(minimumBreakAtr, minimumReclaimAtr + 0.18))
retestHoldScore = pocketTouched ? f_peak_score(reclaimDepthAtr, 0.0, acceptancePocketAtr * 0.55, acceptancePocketAtr * 1.75) : 20.0
volumeScore = na(volume) ? 55.0 : f_norm_high_good(volumeRatio, 0.75, 1.55)
wickScore = f_clamp(reclaimWick * 180.0 + closeLocation * 36.0 + bodyShare * 20.0, 0.0, 100.0)
acceptanceScore = f_clamp(reclaimCloseScore * 0.28 + retestHoldScore * 0.24 + volumeScore * 0.18 + trendScore * 0.18 + wickScore * 0.12, 0.0, 100.0)

// -------------------------------------------------
// Active Plan Storage
// -------------------------------------------------
var int activeDirection = 0
var int activeStartBar = na
var float activeLevel = na
var float activeRiskEdge = na
var float activeTarget = na
var float activeScore = na
var float activeAtr = na
var string activeAction = "Wait breakout"
var bool activeFailed = false
var bool activeTargetReached = false
var int activeResolvedBar = na

var box acceptanceBox = na
var box targetBox = na
var line reclaimLine = na
var line riskLine = na
var line targetLine = na
var label acceptanceBadge = na
var label targetBadge = na
var label reclaimTag = na
var label riskTag = na
var label targetTag = na
var array<label> chartLabels = array.new_label()
var int lastEventLabelBar = na
var int lastContextLabelBar = na

newAcceptedReclaim = reclaimCandidate and acceptanceScore >= watchThreshold
lowQualityReclaim = reclaimCandidate and acceptanceScore < watchThreshold

if newAcceptedReclaim
    activeDirection := armedDirection
    activeStartBar := bar_index
    activeLevel := armedLevel
    activeScore := acceptanceScore
    activeAtr := safeAtr
    rawRisk = activeDirection == 1 ? math.min(low, activeLevel - safeAtr * riskBufferAtr) : math.max(high, activeLevel + safeAtr * riskBufferAtr)
    activeRiskEdge := rawRisk
    riskDistance = math.max(math.abs(activeLevel - activeRiskEdge), safeAtr * 0.20)
    activeTarget := activeLevel + activeDirection * riskDistance * targetRMultiple
    activeAction := activeScore >= planReviewThreshold ? "Review reclaim" : "Watch hold"
    activeFailed := false
    activeTargetReached := false
    activeResolvedBar := na
    armedDirection := 0
    armedLevel := na
    armedBar := na
    armedBreakExtreme := na

hasActivePlan = activeDirection != 0 and not na(activeStartBar) and not na(activeLevel) and not na(activeRiskEdge) and not na(activeTarget)
activeAge = hasActivePlan ? bar_index - activeStartBar : 0
rawFailedPlan = confirmedBar and hasActivePlan and activeAge <= planExpiryBars and not activeTargetReached and (activeDirection == 1 ? close < activeRiskEdge : close > activeRiskEdge)
rawTargetReached = confirmedBar and hasActivePlan and activeAge <= planExpiryBars and not activeFailed and (activeDirection == 1 ? close >= activeTarget : close <= activeTarget)
failedPlanSignal = rawFailedPlan and not activeFailed
targetReachedSignal = rawTargetReached and not activeTargetReached
if failedPlanSignal
    activeFailed := true
    activeResolvedBar := bar_index
else if targetReachedSignal
    activeTargetReached := true
    activeResolvedBar := bar_index
resolvedAge = not na(activeResolvedBar) ? bar_index - activeResolvedBar : 0
planExpired = hasActivePlan and (activeAge > planExpiryBars or ((activeFailed or activeTargetReached) and resolvedAge > resolvedDisplayBars))
failedPlan = hasActivePlan and activeFailed
targetReached = hasActivePlan and activeTargetReached
levelHeld = hasActivePlan and (activeDirection == 1 ? close >= activeLevel : close <= activeLevel)

planState = "Scan Breakout"
if hasActivePlan
    if failedPlan
        planState := "Plan Failed"
        activeAction := "Rebuild context"
    else if targetReached
        planState := "Target Reached"
        activeAction := "Target complete"
    else if not levelHeld
        planState := "Test Risk"
        activeAction := "Watch risk edge"
    else if activeScore >= planReviewThreshold
        planState := "Review Reclaim"
        activeAction := "Review acceptance"
    else
        planState := "Watch Hold"
        activeAction := "Wait stronger hold"
else if armedActive
    planState := armedDirection == 1 ? "Watch Bull Retest" : "Watch Bear Retest"
    activeAction := "Wait reclaim close"
else
    activeAction := "Wait breakout"

if planExpired
    activeDirection := 0
    activeStartBar := na
    activeLevel := na
    activeRiskEdge := na
    activeTarget := na
    activeScore := na
    activeAtr := na
    activeAction := "Wait breakout"
    activeFailed := false
    activeTargetReached := false
    activeResolvedBar := na

hasActivePlan := activeDirection != 0 and not na(activeStartBar) and not na(activeLevel) and not na(activeRiskEdge) and not na(activeTarget)
riskDistanceActive = hasActivePlan ? math.max(math.abs(activeLevel - activeRiskEdge), syminfo.mintick) : na
directionalTargetRoom = hasActivePlan ? (activeDirection == 1 ? activeTarget - close : close - activeTarget) : na
targetRoomR = hasActivePlan ? math.max(directionalTargetRoom, 0.0) / riskDistanceActive : na

// -------------------------------------------------
// Confirmation-anchored proof (accepted reclaims: Follow = target corridor reached before risk edge)
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

int proofWarmup = slowEmaLength + atrLength + 10
bool proofTargetAhead = activeDirection == 1 ? close < activeTarget : activeDirection == -1 ? close > activeTarget : false
bool reclaimAnchor = barstate.isconfirmed and newAcceptedReclaim and activeDirection != 0 and not na(activeRiskEdge) and not na(activeTarget) and proofTargetAhead
if barstate.isconfirmed and bar_index > proofWarmup
    if pEvalActive
        int heldBars = bar_index - pEvalStart
        float followDist = math.max(math.abs(pEvalTarget - pEvalEntry), syminfo.mintick)
        float favExc = pEvalDir * (close - pEvalEntry)
        if heldBars >= 1 and heldBars <= proofReactBars and favExc >= followDist * proofReactProgressPct / 100.0
            pReacted := true
        bool stopBreached = pEvalDir == 1 ? close < pEvalStop : close > pEvalStop
        bool hitTarget = heldBars >= 1 and favExc >= followDist
        if stopBreached
            pFlipped := true
        bool followNow = hitTarget and not pFlipped
        if followNow
            pFollowed := true
        bool naturalResolve = pFlipped or followNow or heldBars >= planExpiryBars
        if naturalResolve or reclaimAnchor
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
    if reclaimAnchor and not pEvalActive
        pEvalActive := true
        pEvalDir := activeDirection
        pEvalEntry := close
        pEvalStop := activeRiskEdge
        pEvalTarget := activeTarget
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false
        pFlipped := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float proofFlipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0
string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) : "building"

// -------------------------------------------------
// Labels
// -------------------------------------------------
eventCooldownOk = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
contextCooldownOk = na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars

if showEventLabels and newAcceptedReclaim and eventCooldownOk
    eventText = activeDirection == 1 ? "BULL RECLAIM" : "BEAR RECLAIM"
    eventText += showLabelScore ? " | Q" + str.tostring(activeScore, "#") : ""
    labelPrice = activeDirection == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    newLabel = label.new(bar_index, labelPrice, eventText, xloc = xloc.bar_index, yloc = yloc.price, style = activeDirection == 1 ? label.style_label_up : label.style_label_down, textcolor = headerText, color = color.new(f_side_color(activeDirection), 4), size = chartLabelSize)
    array.push(chartLabels, newLabel)
    f_trim_labels(chartLabels, maxVisibleLabels)
    lastEventLabelBar := bar_index

if showEventLabels and lowQualityReclaim and eventCooldownOk
    lowText = (armedDirection == 1 ? "BULL WEAK" : "BEAR WEAK") + (showLabelScore ? " | Q" + str.tostring(acceptanceScore, "#") : "")
    weakLabelPrice = armedDirection == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    weakLabel = label.new(bar_index, weakLabelPrice, lowText, xloc = xloc.bar_index, yloc = yloc.price, style = armedDirection == 1 ? label.style_label_up : label.style_label_down, textcolor = darkText, color = color.new(neutralColor, 4), size = chartLabelSize)
    array.push(chartLabels, weakLabel)
    f_trim_labels(chartLabels, maxVisibleLabels)
    lastEventLabelBar := bar_index

if showEventLabels and failedPlanSignal and eventCooldownOk
    failLabelPrice = activeDirection == 1 ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
    failText = (activeDirection == 1 ? "BULL FAIL" : "BEAR FAIL") + " | " + f_fmt_price(activeRiskEdge)
    failLabel = label.new(bar_index, failLabelPrice, failText, xloc = xloc.bar_index, yloc = yloc.price, style = activeDirection == 1 ? label.style_label_down : label.style_label_up, textcolor = headerText, color = color.new(dangerColor, 4), size = chartLabelSize)
    array.push(chartLabels, failLabel)
    f_trim_labels(chartLabels, maxVisibleLabels)
    lastEventLabelBar := bar_index

if showEventLabels and showTargetReviewLabels and targetReachedSignal and eventCooldownOk
    targetLabelPrice = activeDirection == 1 ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
    targetTextEvent = (activeDirection == 1 ? "BULL TARGET" : "BEAR TARGET") + " | " + f_fmt_price(activeTarget)
    reachLabel = label.new(bar_index, targetLabelPrice, targetTextEvent, xloc = xloc.bar_index, yloc = yloc.price, style = activeDirection == 1 ? label.style_label_down : label.style_label_up, textcolor = darkText, color = color.new(bullColor, 4), size = chartLabelSize)
    array.push(chartLabels, reachLabel)
    f_trim_labels(chartLabels, maxVisibleLabels)
    lastEventLabelBar := bar_index

if showContextLabels and contextCooldownOk
    contextCondition = armedActive or (hasActivePlan and levelHeld and not failedPlan and not targetReached)
    if contextCondition
        contextDir = armedActive ? armedDirection : activeDirection
        contextText = armedActive ? "Retest" : planState == "Review Reclaim" ? "Hold" : planState == "Watch Hold" ? "Watch" : planState == "Test Risk" ? "Risk" : "Plan"
        contextPrice = contextDir == 1 ? low - safeAtr * labelOffsetAtr * 0.68 : high + safeAtr * labelOffsetAtr * 0.68
        contextLabel = label.new(bar_index, contextPrice, contextText, xloc = xloc.bar_index, yloc = yloc.price, style = contextDir == 1 ? label.style_label_up : label.style_label_down, textcolor = headerText, color = color.new(accentColor, 4), size = chartLabelSize)
        array.push(chartLabels, contextLabel)
        f_trim_labels(chartLabels, maxVisibleLabels)
        lastContextLabelBar := bar_index

// -------------------------------------------------
// State Glow
// -------------------------------------------------
stateBarColor = showStateGlow and hasActivePlan ? planState == "Review Reclaim" ? color.new(f_side_color(activeDirection), 78) : planState == "Watch Hold" ? color.new(accentColor, 84) : (planState == "Test Risk" or planState == "Plan Failed") ? color.new(dangerColor, 84) : na : na
barcolor(stateBarColor)

// -------------------------------------------------
// Active Visuals
// -------------------------------------------------
renderActiveVisuals = hasActivePlan and not planExpired
if not renderActiveVisuals
    f_delete_box(acceptanceBox)
    f_delete_box(targetBox)
    f_delete_line(reclaimLine)
    f_delete_line(riskLine)
    f_delete_line(targetLine)
    f_delete_label(acceptanceBadge)
    f_delete_label(targetBadge)
    f_delete_label(reclaimTag)
    f_delete_label(riskTag)
    f_delete_label(targetTag)
    acceptanceBox := na
    targetBox := na
    reclaimLine := na
    riskLine := na
    targetLine := na
    acceptanceBadge := na
    targetBadge := na
    reclaimTag := na
    riskTag := na
    targetTag := na
else
    activeColor = f_side_color(activeDirection)
    rightX = bar_index + projectionBars
    riskTagX = rightX + 2
    reclaimTagX = rightX + 18
    targetTagX = rightX + 34
    lockedPocketHalfHeight = activeAtr * acceptancePocketAtr
    pocketTop = activeLevel + lockedPocketHalfHeight
    pocketBottom = activeLevel - lockedPocketHalfHeight
    targetHalfHeight = activeAtr * math.max(acceptancePocketAtr * 0.40, 0.08)
    targetTop = activeTarget + targetHalfHeight
    targetBottom = activeTarget - targetHalfHeight
    pocketMidX = activeStartBar + int(math.round((rightX - activeStartBar) * 0.22))
    targetMidX = activeStartBar + int(math.round((rightX - activeStartBar) * 0.78))
    directionText = activeDirection == 1 ? "BULL" : "BEAR"
    pocketBadgeText = planState == "Plan Failed" ? "PLAN FAILED" : planState == "Target Reached" ? "RECLAIM HELD | Q" + str.tostring(activeScore, "#") : directionText + " RECLAIM | Q" + str.tostring(activeScore, "#")
    targetBadgeText = planState == "Target Reached" ? "TARGET REACHED | " + f_fmt_price(activeTarget) : "TARGET " + f_fmt_price(activeTarget) + " | " + f_fmt(targetRoomR) + "R"

    if showAcceptancePocket
        if na(acceptanceBox)
            acceptanceBox := box.new(activeStartBar, pocketTop, rightX, pocketBottom, xloc = xloc.bar_index, border_color = color.new(activeColor, 18), bgcolor = color.new(activeColor, 89))
        else
            box.set_left(acceptanceBox, activeStartBar)
            box.set_right(acceptanceBox, rightX)
            box.set_top(acceptanceBox, pocketTop)
            box.set_bottom(acceptanceBox, pocketBottom)
            box.set_border_color(acceptanceBox, color.new(activeColor, 18))
            box.set_bgcolor(acceptanceBox, color.new(activeColor, 89))
        if na(acceptanceBadge)
            acceptanceBadge := label.new(pocketMidX, (pocketTop + pocketBottom) * 0.5, pocketBadgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = headerText, color = color.new(f_state_color(planState, activeDirection), 0), size = chartLabelSize)
        else
            label.set_xy(acceptanceBadge, pocketMidX, (pocketTop + pocketBottom) * 0.5)
            label.set_text(acceptanceBadge, pocketBadgeText)
            label.set_color(acceptanceBadge, color.new(f_state_color(planState, activeDirection), 0))
            label.set_textcolor(acceptanceBadge, headerText)
            label.set_size(acceptanceBadge, chartLabelSize)
    else
        f_delete_box(acceptanceBox)
        f_delete_label(acceptanceBadge)
        acceptanceBox := na
        acceptanceBadge := na

    if showTargetCorridor
        if na(targetBox)
            targetBox := box.new(activeStartBar, targetTop, rightX, targetBottom, xloc = xloc.bar_index, border_color = color.new(accentColor, 28), bgcolor = color.new(accentColor, 91))
        else
            box.set_left(targetBox, activeStartBar)
            box.set_right(targetBox, rightX)
            box.set_top(targetBox, targetTop)
            box.set_bottom(targetBox, targetBottom)
            box.set_border_color(targetBox, color.new(accentColor, 28))
            box.set_bgcolor(targetBox, color.new(accentColor, 91))
        if na(targetBadge)
            targetBadge := label.new(targetMidX, (targetTop + targetBottom) * 0.5, targetBadgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = headerText, color = color.new(accentColor, 0), size = chartLabelSize)
        else
            label.set_xy(targetBadge, targetMidX, (targetTop + targetBottom) * 0.5)
            label.set_text(targetBadge, targetBadgeText)
            label.set_color(targetBadge, color.new(accentColor, 0))
            label.set_textcolor(targetBadge, headerText)
            label.set_size(targetBadge, chartLabelSize)
    else
        f_delete_box(targetBox)
        f_delete_label(targetBadge)
        targetBox := na
        targetBadge := na

    if showPlanLevels
        if na(reclaimLine)
            reclaimLine := line.new(activeStartBar, activeLevel, rightX, activeLevel, xloc = xloc.bar_index, color = color.new(activeColor, 0), width = 2, style = line.style_solid)
            riskLine := line.new(activeStartBar, activeRiskEdge, rightX, activeRiskEdge, xloc = xloc.bar_index, color = color.new(dangerColor, 0), width = 2, style = line.style_dashed)
            targetLine := line.new(activeStartBar, activeTarget, rightX, activeTarget, xloc = xloc.bar_index, color = color.new(accentColor, 0), width = 2, style = line.style_dotted)
        else
            line.set_xy1(reclaimLine, activeStartBar, activeLevel)
            line.set_xy2(reclaimLine, rightX, activeLevel)
            line.set_color(reclaimLine, color.new(activeColor, 0))
            line.set_xy1(riskLine, activeStartBar, activeRiskEdge)
            line.set_xy2(riskLine, rightX, activeRiskEdge)
            line.set_color(riskLine, color.new(dangerColor, 0))
            line.set_xy1(targetLine, activeStartBar, activeTarget)
            line.set_xy2(targetLine, rightX, activeTarget)
            line.set_color(targetLine, color.new(accentColor, 0))
    else
        f_delete_line(reclaimLine)
        f_delete_line(riskLine)
        f_delete_line(targetLine)
        reclaimLine := na
        riskLine := na
        targetLine := na

    if showRightSideTags and barstate.islast
        reclaimTag := f_tag_set(reclaimTag, reclaimTagX, activeLevel, "RECLAIM " + f_fmt_price(activeLevel), activeColor, labelFontSize)
        riskTag := f_tag_set(riskTag, riskTagX, activeRiskEdge, "RISK " + f_fmt_price(activeRiskEdge), dangerColor, labelFontSize)
        targetTag := f_tag_set(targetTag, targetTagX, activeTarget, "TARGET " + f_fmt_price(activeTarget), accentColor, labelFontSize)
    else if not showRightSideTags
        f_delete_label(reclaimTag)
        f_delete_label(riskTag)
        f_delete_label(targetTag)
        reclaimTag := na
        riskTag := na
        targetTag := na

// -------------------------------------------------
// Data Window
// -------------------------------------------------
plot(hasActivePlan ? activeScore : acceptanceScore, title = "Reclaim Acceptance Score", color = hasActivePlan ? f_score_color(activeScore, activeDirection) : neutralColor, display = display.data_window)
plot(volumeRatio, title = "Volume Participation Ratio", color = accentColor, display = display.data_window)
plot(reclaimDepthAtr, title = "Reclaim Depth ATR", color = neutralColor, display = display.data_window)
plot(targetRoomR, title = "Target Room R", color = bullColor, display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table infoPanel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""
var bool lastProofMode = false
int panelRowCount = showProof ? 9 : 6

if barstate.islast
    if showPanel
        if na(infoPanel) or panelLocation != lastPanelLocation or panelTheme != lastPanelTheme or showProof != lastProofMode
            if not na(infoPanel)
                table.delete(infoPanel)
            infoPanel := table.new(f_panel_pos(panelLocation), 2, panelRowCount, bgcolor = f_panel_bg(panelTheme), frame_color = f_panel_border(panelTheme), frame_width = 1, border_color = f_panel_border(panelTheme), border_width = 1)
            lastPanelLocation := panelLocation
            lastPanelTheme := panelTheme
            lastProofMode := showProof
        table.clear(infoPanel, 0, 0, 1, panelRowCount - 1)
        table.merge_cells(infoPanel, 0, 0, 1, 0)
        table.cell(infoPanel, 0, 0, "AG Pro Reclaim Breakout Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)

        scoreText = hasActivePlan ? str.tostring(activeScore, "#") + " / 100 " + f_score_grade(activeScore) : armedActive ? str.tostring(acceptanceScore, "#") + " developing" : "-"
        panelDir = hasActivePlan ? activeDirection : armedActive ? armedDirection : 0
        scoreColor = hasActivePlan ? f_score_color(activeScore, activeDirection) : armedActive ? neutralColor : f_panel_value(panelTheme)
        riskText = hasActivePlan ? f_fmt_price(activeRiskEdge) : "-"
        levelText = hasActivePlan ? f_fmt_price(activeLevel) : armedActive ? f_fmt_price(armedLevel) : "-"
        targetText = hasActivePlan ? f_fmt_price(activeTarget) : "-"
        targetRoomText = hasActivePlan ? f_fmt(targetRoomR) + "R" : "-"
        ageText = hasActivePlan ? "A" + str.tostring(activeAge) : "-"
        volumeText = str.tostring(volumeRatio, "#.##") + "x"
        volStateText = volumeRatio >= 1.20 ? "Strong" : volumeRatio >= 0.85 ? "Normal" : "Light"
        volColor = volumeRatio >= 1.20 ? bullColor : volumeRatio >= 0.85 ? f_panel_value(panelTheme) : neutralColor
        sideText = panelDir == 1 ? "Bull reclaim" : panelDir == -1 ? "Bear reclaim" : "Scanning"

        f_panel_row(infoPanel, 1, "Workflow", activeAction, f_state_color(planState, panelDir), panelTheme, panelFontSize)
        f_panel_row(infoPanel, 2, "Context", sideText + " | " + planState, f_state_color(planState, panelDir), panelTheme, panelFontSize)
        f_panel_row(infoPanel, 3, "Quality / Volume", scoreText + " | " + volumeText + " " + volStateText, scoreColor, panelTheme, panelFontSize)
        f_panel_row(infoPanel, 4, "Level / Risk", levelText + " / " + riskText, hasActivePlan ? f_side_color(panelDir) : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_panel_row(infoPanel, 5, "Target / Room", targetText + " / " + targetRoomText + " | " + ageText, hasActivePlan ? accentColor : f_panel_value(panelTheme), panelTheme, panelFontSize)
        if showProof
            f_panel_row(infoPanel, 6, "Proof @ Confirm", proofSampleText, accentColor, panelTheme, panelFontSize)
            f_panel_row(infoPanel, 7, "Follow / Hold", (proofTotal > 0 ? f_rate_pct(followRate) : "-") + " / " + (proofTotal > 0 ? f_rate_pct(holdRate) : "-"), proofTotal > 0 ? f_rate_color(followRate) : f_panel_value(panelTheme), panelTheme, panelFontSize)
            f_panel_row(infoPanel, 8, "React / Flip", (proofTotal > 0 ? f_rate_pct(reactRate) : "-") + " / " + (proofTotal > 0 ? f_rate_pct(proofFlipRate) : "-"), proofTotal > 0 ? f_rate_color(reactRate) : f_panel_value(panelTheme), panelTheme, panelFontSize)
    else if not na(infoPanel)
        table.delete(infoPanel)
        infoPanel := na
        lastPanelLocation := ""
        lastPanelTheme := ""

// -------------------------------------------------
// Alerts
// -------------------------------------------------
bullReclaimAlert = alertReclaimStates and newAcceptedReclaim and activeDirection == 1 and activeScore >= alertScoreThreshold
bearReclaimAlert = alertReclaimStates and newAcceptedReclaim and activeDirection == -1 and activeScore >= alertScoreThreshold
failedReclaimAlert = alertReclaimStates and failedPlanSignal
targetReviewAlert = alertReclaimStates and targetReachedSignal

alertcondition(bullReclaimAlert, "Bullish Reclaim Breakout Plan", "Reclaim Breakout Planner: bullish structural reclaim accepted above the alert threshold. This is an attention marker, not a trade instruction.")
alertcondition(bearReclaimAlert, "Bearish Reclaim Breakout Plan", "Reclaim Breakout Planner: bearish structural reclaim accepted above the alert threshold. This is an attention marker, not a trade instruction.")
alertcondition(failedReclaimAlert, "Reclaim Risk Edge Failed", "Reclaim Breakout Planner: active reclaim plan closed beyond the risk edge. Rebuild context before interpretation.")
alertcondition(targetReviewAlert, "Reclaim Target Corridor Reached", "Reclaim Breakout Planner: active reclaim plan reached the projected target corridor review area.")

// -------------------------------------------------
// Hidden Proof Exports
// -------------------------------------------------
plot(followRate, title = "RBP Follow Rate", display = display.none)
plot(holdRate, title = "RBP Hold Rate", display = display.none)
plot(reactRate, title = "RBP React Rate", display = display.none)
plot(proofFlipRate, title = "RBP Flip Rate", display = display.none)
````

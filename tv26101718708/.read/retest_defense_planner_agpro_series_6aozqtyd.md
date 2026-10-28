# Retest Defense Planner [AGPro Series]

- url: https://www.tradingview.com/script/6aozQtYD-Retest-Defense-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;fa67a5c27e974554a45ecaee248387d2
- version: 4.0

## Description

Retest Defense Planner [AGPro Series]


🧠 Core Idea

Is a retested level still being defended strongly enough to keep the planning context alive?


📌 Overview / What it does

Retest Defense Planner [AGPro Series] is a chart-first decision tool built for traders who review how price behaves after returning to an active defense shelf.

Instead of treating every level touch as meaningful, the script evaluates whether the shelf is actually being protected. It measures retest depth, wick defense, close response, time at level, volume support, target room, and risk-edge distance, then converts that evidence into a 0-100 Retest Score and a clear next-action state.

The default view is tuned for clear 4H-style retest review, where shelf defense, reaction quality, and short-term follow-through are usually easier to read than on very compressed timeframes. The script still works across timeframes, but users should adjust shelf age, projection bars, and sensitivity when changing market rhythm.

The script produces a defense zone, active defense rail, risk edge, target-room guide, follow-through guide, compact chart labels, alerts, and a clean AGPro planning panel. It does not predict price movement, automate execution, or provide guaranteed outcomes.


🎯 Purpose & Design Philosophy

This script was built to fill the gap between simple level plotting and full structure scanners.

Many traders can identify that price has returned to a level, but the harder question is whether the level is still being defended cleanly enough to deserve attention. Retest Defense Planner focuses on that decision layer.

The design supports a planning mindset: read the defense state, check the score, locate the risk edge, compare target room, and decide what deserves review next.


⚡ Why This Script Is Different

Most retest tools focus on structure breaks, swing-leg pullbacks, support/resistance maps, or broad breakout retest signals.

This script does NOT clone Structure Retest Planner, Swing Retest Quality, Breakout Retest Readiness, Break-Retest Quality, Breaker Block Engine, or a generic S/R zone map.

Instead, it evaluates one active defense shelf and asks whether the shelf is surviving the retest. The main output is not a signal. It is a decision state: DEFENDED, WATCH, WEAK RETEST, APPROACH, DEFENSE LOST, WAIT, or SCAN.


⚙️ Methodology

1. Context Detection
The script identifies fresh support-side or resistance-side defense shelves using confirmed pivot behavior and optional automatic side selection.

2. Reference Mapping
It maps one active defense zone, a shelf rail, a risk edge, and a target-room guide. These are planning references, not trade instructions.

3. Reaction Evaluation
The 0-100 model scores retest depth, wick defense, close response, time at level, and volume support.

4. Visual Output
The chart shows the active defense zone with centered text, event labels, guide lines, and the AGPro decision panel.


🗺️ How to Read the Chart

Defense Zone = the active shelf area being evaluated after price returns to it.

Defense Rail = the exact reference shelf the model is monitoring.

Risk Edge = the planning line where the active defense context is considered lost.

Target-Room Guide = a forward context guide based on the current shelf-to-risk distance.

Labels = compact TEST, DEFENDED, WATCH, WEAK, LOST, and context labels.

Colors = teal marks bullish support-defense context, pink marks bearish resistance-defense context, amber marks caution/review, indigo marks watch/transition, and red marks lost defense.

Panel = the AGPro panel summarizes Defense State, Retest Score, Reaction Quality, Risk Edge, and Action.


🚦 Signals & States

• DEFENDED → the shelf has been retested and the defense score is strong enough for structured review.

• WATCH → the response is developing, but confirmation or room is still incomplete.

• WEAK RETEST → price touched the shelf, but response quality is not strong enough.

• APPROACH → price is near the active defense shelf and a retest review may be forming.

• DEFENSE LOST → price crossed the risk edge and the active shelf context should be rebuilt.

• WAIT → an active shelf exists, but price is not close enough for a useful review.

• SCAN → no fresh defense shelf is active yet.


🔔 Alerts Logic

Alerts trigger when price touches the active defense zone, when a defended retest appears, when watch context appears, when a weak retest is detected, and when the risk edge is crossed.

Alerts are attention markers only. They are not trade instructions, automated strategy commands, or outcome promises.


🧩 Confluence Logic

The strongest context appears when a controlled retest probe, visible wick defense, constructive close response, enough hold time, supportive relative volume, and usable target room align.

When those components conflict, the panel moves toward WATCH, WEAK RETEST, RISK REVIEW, or DEFENSE LOST.


📊 When to Use

• Pullbacks into a defended support shelf

• Retests of a resistance shelf after bearish pressure

• 4H retest reviews where shelf defense and reaction candles are visually readable

• Continuation planning where the level has already been identified by price action

• Risk planning where invalidation and target room matter

• Liquid markets where candles, pivots, and volume behavior are readable


⚠️ When NOT to Use

• Very low-liquidity symbols with irregular candles

• Extremely noisy micro-timeframes

• News-driven spikes where shelf behavior becomes distorted

• Markets where pivot structure is too compressed to form useful shelves

• Situations where the user expects a signal-only tool


🎛️ Key Inputs

• Defense Side → selects Auto, Bullish Defense, or Bearish Defense.

• Defense Pivot Length → controls how confirmed shelves are detected.

• Max Shelf Age → controls how long a shelf remains eligible.

• Sensitivity → adjusts activation distance and zone tolerance.

• Response Window Bars → controls how long the retest response remains active.

• Risk Edge ATR → controls the planning risk edge behind the shelf.

• DEFENDED Score → sets the score threshold for stronger review states.

• Label and Panel Font Size → controls chart-label and panel readability.

• Panel Location and Theme → adjusts the AGPro panel layout.


🖥️ Interface & Visual Design

The interface is designed to stay chart-first and decision-led.

The defense zone is the main visual object. The centered label keeps the zone readable without adding extra floating text. The risk edge and target guide explain where the planning context weakens and how much room remains.

The AGPro panel uses a merged blue title row and five compact rows so the user can read state, score, reaction quality, risk, and next action quickly.


🧪 Practical Usage Workflow

1. Read the panel state and Retest Score.

2. Check whether price is approaching or touching the defense zone.

3. Compare the shelf rail with the risk edge.

4. Review whether the label says TEST, DEFENDED, WATCH, WEAK, or LOST.

5. Confirm the broader market context before making any decision.


🔍 Interpretation Guidelines

Think in terms of defense quality, not prediction.

A higher score means multiple defense components align inside the script's rule set. A weaker score means the retest may be too shallow, too deep, too fast, too noisy, or missing a constructive close response.

The script helps organize the review process. It does not replace judgment.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not an auto-trading system

• Not a guaranteed signal tool

• Not a BOS / CHOCH scanner

• Not a breakout retest scanner

• Not a swing-leg retest tool

• Not an order block, FVG, or supply/demand map

• Not a generic support/resistance zone map


⚠️ Limitations & Transparency

• Pivot-based shelf references appear only after pivots are confirmed.

• Scores can vary across symbols, sessions, and timeframes.

• Volume scoring depends on exchange-provided volume data.

• Fast volatility can cross a shelf before a clean defense can be measured.

• In Live Updating mode, active-bar values can change before the bar closes.


🧠 Market Context Notes

Retest defense is easiest to interpret when liquidity, volatility, and trend context are readable.

A defended shelf is not enough by itself. The reaction, close location, hold time, risk edge, and target room all matter.


🧾 Use Case Examples

When price returns to a support shelf, probes the defense zone, forms a visible lower wick, and closes back above the shelf with enough target room, the planner may mark DEFENDED.

When price touches the shelf but closes weakly with poor reaction quality, the planner may show WEAK RETEST or WATCH.

When price crosses the risk edge, DEFENSE LOST indicates that the active context should be rebuilt.


🧱 System Philosophy

Retest Defense Planner follows the AGPro decision-engine approach: map the context, score the quality, show the risk reference, show the target room, and summarize the next action without issuing trade commands.


🔐 Non-Promise Statement

No indicator can provide certainty.

The script does not guarantee that a retest will hold, continue, reverse, or produce any specific outcome.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own analysis, risk management, and trading decisions.

This script is provided for educational and analytical purposes only and does not constitute financial advice.


📚 Educational Note

Use the script as a structured retest-defense review framework. The best results come from combining the panel, zones, labels, and alerts with broader chart context and disciplined risk evaluation.

## Source Code

````pine
// -------------------------------------------------
// Retest Defense Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Retest Defense Planner is a chart-first retest decision engine for judging
// whether a single active defense shelf is still being protected after price
// returns to it. It scores retest depth, wick defense, close response, time at
// level, and volume support into a 0-100 readiness model, then maps risk edge,
// target room, and next action without becoming a generic support/resistance,
// breakout retest, order block, swing-leg retest, or signal script. Version 1.3
// adds an owned defense-plan lane, proactive collision control, and auditable
// non-overlapping historical hold evidence.
// -------------------------------------------------

//@version=6
indicator("Retest Defense Planner [AGPro Series]",
     shorttitle = "AG RDP",
     overlay = true,
     max_labels_count = 120,
     max_boxes_count = 10,
     max_lines_count = 20)

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
darkText      = color.rgb(15, 23, 42)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
ttSide = "Selects the active defense direction. Auto chooses the nearest fresh defense shelf with basic trend context. Manual modes force bullish support defense or bearish resistance defense."
ttPivot = "Pivot length used to confirm a defense shelf. Lower values react faster, while higher values require cleaner structure before a shelf is used."
ttAge = "Maximum age of a confirmed defense shelf. Older shelves are ignored so the planner stays focused on the current chart context."
ttAtr = "ATR length used for shelf thickness, activation distance, risk edge, target guide, and label spacing."
ttVolume = "Volume baseline used to judge whether the retest response has participation. Disable volume scoring on symbols where volume is unreliable."
ttFast = "Fast EMA used only for automatic side selection and light context scoring. It does not create entry or exit signals."
ttSlow = "Slow EMA used only for automatic side selection and light context scoring."
ttSensitivity = "Controls activation distance and shelf tolerance. Conservative is tighter, Balanced is standard, and Aggressive allows broader retest behavior."
ttConfirm = "Close Confirmed waits for a closed bar before labels and alerts are printed. Live Updating lets the planner update during the active bar."
ttActivation = "ATR distance from the defense shelf where the planner starts treating price as approaching a retest."
ttZone = "ATR thickness around the active defense shelf. The centered badge stays horizontally and vertically centered inside this box."
ttIdeal = "Preferred ATR-normalized probe through the shelf. Very shallow retests and very deep violations score lower than a controlled defense probe."
ttMaxProbe = "ATR-normalized probe depth that becomes too deep for a clean defense read."
ttResponse = "Number of bars after a shelf touch where the script continues evaluating the response as active."
ttHold = "Preferred number of bars for a shelf to remain defended after touch. This helps separate instant noise from cleaner defense attempts."
ttClose = "Minimum ATR-normalized close back on the defended side of the shelf for a stronger close-response score."
ttInvalidation = "ATR distance beyond the shelf used to draw the risk edge. It is a planning reference, not a stop instruction."
ttTarget = "R multiple used to project a target-room guide from the shelf and risk edge. It is context only, not a forecast."
ttReady = "Minimum 0-100 score required for Defended state. This is an attention filter, not a trade instruction."
ttWatch = "Minimum 0-100 score required for Watch state before the defense is strong enough for Defended."
ttRoom = "Minimum ATR-normalized room preferred before a defended shelf can be treated as cleaner context."
ttUseVolume = "When enabled, relative volume contributes to the 0-100 score. When disabled, the volume component becomes neutral."
ttDefenseZone = "Shows the active defense zone with a separate filled centered badge. This is the main chart-first visual object."
ttRails = "Shows the defense shelf, risk edge, and target-room guide used by the planner."
ttRightTags = "Displays the owned shelf, risk, and target guide family. Disabling tags also retires the matching rails so no planning line remains ownerless."
ttProjection = "Controls how far the active zone and guide lines extend to the right."
ttTagOffset = "Moves the owned guide badges beyond the active zone. Connector segments preserve the exact price ownership of any dynamically separated badge."
ttSmartGuides = "Automatically separates nearby shelf, risk, and target badges using font-aware ATR spacing while connector segments keep each badge tied to its exact guide price."
ttOpacity = "Transparency for the defense zone. Higher values make the zone lighter."
ttLabels = "Shows compact Test, Defended, Watch, Weak Retest, Lost, and sparse context labels with controlled spacing."
ttContext = "Adds sparse active-context labels so the chart does not look empty while avoiding repeated signal clutter."
ttScoreLabel = "Adds the 0-100 score to chart labels."
ttCooldown = "Minimum bars between event labels. Higher values reduce repeated labels during active retests."
ttContextSpacing = "Minimum bars between sparse context labels during ongoing defense review."
ttMaxLabels = "Maximum number of chart labels retained. Older labels are removed first for performance."
ttOffset = "ATR-based label offset that keeps labels above or below candles."
ttLabelSize = "Controls all chart labels, centered badges, and right-side tags. Normal is the recommended publication default."
ttLabelHistory = "Maximum age in bars for historical event badges. Active plan objects and the panel are not affected."
ttProofWindow = "Maximum bars allowed for a frozen defense-touch episode to reach its target reference before risk contact or timeout."
ttProofSamples = "Minimum resolved historical episodes required before the panel displays a Hold Rate."
ttPanel = "Shows or hides the AG Pro planning panel. The default is visible for public-release readability."
ttPanelLocation = "Moves the AG Pro planning panel to the preferred chart location."
ttPanelTheme = "Switches the panel between dark and light chart-friendly themes."
ttPanelFont = "Controls panel text size. Normal is the recommended publication default."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Retest Defense Engine"
sideMode = input.string("Auto", "Defense Side", options = ["Auto", "Bullish Defense", "Bearish Defense"], group = groupEngine, tooltip = ttSide)
defensePivotLength = input.int(5, "Defense Pivot Length", minval = 2, maxval = 35, group = groupEngine, tooltip = ttPivot)
maxShelfAge = input.int(130, "Max Shelf Age", minval = 25, maxval = 600, group = groupEngine, tooltip = ttAge)
atrLength = input.int(14, "ATR Length", minval = 3, maxval = 100, group = groupEngine, tooltip = ttAtr)
volumeLength = input.int(30, "Volume Baseline Length", minval = 5, maxval = 200, group = groupEngine, tooltip = ttVolume)
fastEmaLength = input.int(21, "Fast Context EMA", minval = 2, maxval = 200, group = groupEngine, tooltip = ttFast)
slowEmaLength = input.int(55, "Slow Context EMA", minval = 3, maxval = 300, group = groupEngine, tooltip = ttSlow)
sensitivity = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = groupEngine, tooltip = ttSensitivity)
confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = ttConfirm)

groupScoring = "Defense Score Model"
activationDistanceAtr = input.float(1.10, "Activation Distance ATR", minval = 0.20, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = ttActivation)
defenseZoneAtr = input.float(0.30, "Defense Zone ATR", minval = 0.08, maxval = 2.00, step = 0.02, group = groupScoring, tooltip = ttZone)
idealProbeAtr = input.float(0.16, "Ideal Retest Probe ATR", minval = 0.00, maxval = 1.50, step = 0.01, group = groupScoring, tooltip = ttIdeal)
maxProbeAtr = input.float(0.76, "Deep Probe Risk ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupScoring, tooltip = ttMaxProbe)
responseWindowBars = input.int(7, "Response Window Bars", minval = 1, maxval = 40, group = groupScoring, tooltip = ttResponse)
idealHoldBars = input.int(3, "Preferred Hold Bars", minval = 1, maxval = 20, group = groupScoring, tooltip = ttHold)
closeResponseAtr = input.float(0.10, "Close Response ATR", minval = 0.00, maxval = 1.00, step = 0.01, group = groupScoring, tooltip = ttClose)
riskEdgeAtr = input.float(0.60, "Risk Edge ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupScoring, tooltip = ttInvalidation)
targetRMultiple = input.float(1.55, "Target Guide R Multiple", minval = 0.50, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = ttTarget)
defendedScore = input.int(72, "Defended Score", minval = 40, maxval = 95, group = groupScoring, tooltip = ttReady)
watchScore = input.int(55, "Watch Score", minval = 25, maxval = 90, group = groupScoring, tooltip = ttWatch)
minTargetRoomAtr = input.float(1.10, "Minimum Target Room ATR", minval = 0.10, maxval = 8.00, step = 0.05, group = groupScoring, tooltip = ttRoom)
useVolumeSupport = input.bool(true, "Use Volume Support", group = groupScoring, tooltip = ttUseVolume)
proofWindowBars = input.int(40, "Historical Hold Window", minval = 5, maxval = 250, group = groupScoring, tooltip = ttProofWindow)
minimumProofSamples = input.int(8, "Minimum Hold Samples", minval = 3, maxval = 100, group = groupScoring, tooltip = ttProofSamples)

groupVisual = "Chart Visuals"
showDefenseZone = input.bool(true, "Show Defense Zone", group = groupVisual, tooltip = ttDefenseZone)
showGuideLines = input.bool(true, "Show Defense / Risk / Target Guides", group = groupVisual, tooltip = ttRails)
showRightTags = input.bool(true, "Show Right-Side Tags", group = groupVisual, tooltip = ttRightTags)
projectionBars = input.int(34, "Forward Render Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = ttProjection)
guideTagOffsetBars = input.int(9, "Guide Badge Offset Bars", minval = 2, maxval = 40, group = groupVisual, tooltip = ttTagOffset)
useSmartGuideLanes = input.bool(true, "Use Smart Guide Lanes", group = groupVisual, tooltip = ttSmartGuides)
zoneTransparency = input.int(89, "Defense Zone Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = ttOpacity)

groupLabels = "Labels"
showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
showContextLabels = input.bool(true, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContext)
showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttScoreLabel)
labelCooldownBars = input.int(50, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
contextSpacingBars = input.int(72, "Context Label Spacing", minval = 8, maxval = 240, group = groupLabels, tooltip = ttContextSpacing)
maxVisibleLabels = input.int(6, "Max Visible Labels", minval = 5, maxval = 100, group = groupLabels, tooltip = ttMaxLabels)
labelHistoryBars = input.int(220, "Label History Bars", minval = 40, maxval = 2000, group = groupLabels, tooltip = ttLabelHistory)
labelOffsetAtr = input.float(1.00, "Label Offset ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupLabels, tooltip = ttOffset)
labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttPanel)
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = ttPanelTheme)
panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_norm_high(float value, float weak, float strong) =>
    span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low(float value, float good, float bad) =>
    span = bad - good
    span == 0.0 ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    result = 0.0
    if value <= idealValue
        result := f_norm_high(value, lowValue, idealValue)
    else
        result := f_norm_low(value, idealValue, highValue)
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
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_text_on(color bgColor) =>
    bright = (color.r(bgColor) * 299 + color.g(bgColor) * 587 + color.b(bgColor) * 114) / 1000
    bright >= 145 ? darkText : headerText

f_reg(float x, float y, float[] bars, float[] ys) =>
    array.push(bars, x)
    array.push(ys, y)
    if array.size(bars) > 16
        array.shift(bars)
        array.shift(ys)

f_resolve_y(float x, float yBase, float dir, float sep, float[] bars, float[] ys) =>
    float y = yBase
    bool clash = true
    int g = 0
    while clash and g < 14
        clash := false
        if array.size(bars) > 0
            for i = 0 to array.size(bars) - 1
                if math.abs(x - array.get(bars, i)) <= 34 and math.abs(y - array.get(ys, i)) < sep
                    y := y + dir * sep
                    clash := true
        g += 1
    f_reg(x, y, bars, ys)
    y

f_fmt(float value) =>
    na(value) ? "-" : str.tostring(value, "#.##")

f_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_grade(float score) =>
    result = "D"
    if score >= 88.0
        result := "A+"
    else if score >= 78.0
        result := "A"
    else if score >= 66.0
        result := "B"
    else if score >= 55.0
        result := "C"
    result

f_compact_state(string state) =>
    switch state
        "Defense Lost" => "LOST"
        "Weak Retest" => "WEAK"
        "Defended" => "DEFENDED"
        "Approach" => "NEAR"
        "Watch" => "WATCH"
        "Wait" => "WAIT"
        => "SCAN"

f_panel_bg(string theme) =>
    theme == "Light" ? color.rgb(241, 245, 249) : panelBg

f_panel_border(string theme) =>
    theme == "Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string theme) =>
    theme == "Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Light" ? color.rgb(15, 23, 42) : panelValueCol

f_panel_semantic(color semanticColor, string theme) =>
    color result = semanticColor
    if theme == "Light"
        if semanticColor == bullColor
            result := color.rgb(4, 120, 87)
        else if semanticColor == bearColor
            result := color.rgb(190, 24, 93)
        else if semanticColor == neutralColor
            result := color.rgb(180, 83, 9)
        else if semanticColor == accentColor
            result := color.rgb(79, 70, 229)
        else if semanticColor == dangerColor
            result := color.rgb(185, 28, 28)
    result

f_row_bg(string theme, int row) =>
    evenRow = row % 2 == 0
    theme == "Light" ? (evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)) : (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_set_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    rowBg = f_row_bg(theme, row)
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

f_add_label(array<label> labels, int x, float y, string labelText, color bgColor, bool upStyle) =>
    newLabel = label.new(x = x, y = y, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = upStyle ? label.style_label_up : label.style_label_down, color = color.new(bgColor, 8), textcolor = f_text_on(bgColor), size = f_text_size(labelFontSize), textalign = text.align_center)
    array.push(labels, newLabel)
    f_trim_labels(labels, maxVisibleLabels, labelHistoryBars, bar_index)

f_set_label(label tag, int x, float y, string txt, color bg, styleValue) =>
    label.set_xy(tag, x, y)
    label.set_text(tag, txt)
    label.set_color(tag, color.new(bg, 0))
    label.set_textcolor(tag, f_text_on(bg))
    label.set_style(tag, styleValue)
    label.set_size(tag, f_text_size(labelFontSize))
    label.set_textalign(tag, text.align_center)

f_guide_badge_gap(float atrInput, string sizeText) =>
    float fontFactor = sizeText == "Tiny" ? 2.40 : sizeText == "Small" ? 2.80 : sizeText == "Large" ? 4.00 : 3.40
    math.max(math.max(atrInput, syminfo.mintick) * fontFactor, syminfo.mintick * 30.0)

// -------------------------------------------------
// Core References
// -------------------------------------------------
confirmReady = confirmationMode == "Live Updating" or barstate.isconfirmed
atrValue = ta.atr(atrLength)
safeAtr = math.max(nz(atrValue, ta.tr(true)), syminfo.mintick)
fastEma = ta.ema(close, fastEmaLength)
slowEma = ta.ema(close, slowEmaLength)
volumeBase = ta.sma(volume, volumeLength)
relativeVolume = volumeBase > 0.0 ? volume / volumeBase : 1.0

pivotHigh = ta.pivothigh(high, defensePivotLength, defensePivotLength)
pivotLow = ta.pivotlow(low, defensePivotLength, defensePivotLength)

var float lastSupportShelf = na
var int lastSupportBar = na
var float lastResistanceShelf = na
var int lastResistanceBar = na

if not na(pivotLow)
    lastSupportShelf := pivotLow
    lastSupportBar := bar_index - defensePivotLength

if not na(pivotHigh)
    lastResistanceShelf := pivotHigh
    lastResistanceBar := bar_index - defensePivotLength

hasSupport = not na(lastSupportShelf) and not na(lastSupportBar) and bar_index - lastSupportBar <= maxShelfAge
hasResistance = not na(lastResistanceShelf) and not na(lastResistanceBar) and bar_index - lastResistanceBar <= maxShelfAge
supportDistance = hasSupport ? math.abs(close - lastSupportShelf) : na
resistanceDistance = hasResistance ? math.abs(close - lastResistanceShelf) : na

autoBull = false
if hasSupport and hasResistance
    trendPrefersSupport = close >= slowEma or fastEma >= slowEma
    autoBull := trendPrefersSupport ? supportDistance <= resistanceDistance * 1.35 : supportDistance < resistanceDistance * 0.80
else if hasSupport
    autoBull := true

useBullSide = sideMode == "Bullish Defense" ? true : sideMode == "Bearish Defense" ? false : autoBull
activePlan = (useBullSide and hasSupport) or (not useBullSide and hasResistance)
activeShelf = activePlan ? (useBullSide ? lastSupportShelf : lastResistanceShelf) : na
activeShelfBar = activePlan ? (useBullSide ? lastSupportBar : lastResistanceBar) : na

sensitivityMult = switch sensitivity
    "Conservative" => 0.82
    "Aggressive" => 1.18
    => 1.00

effectiveMaxProbeAtr = math.max(maxProbeAtr, idealProbeAtr + 0.01)
effectiveDefendedScore = math.max(defendedScore, watchScore + 1)
zonePad = safeAtr * defenseZoneAtr * sensitivityMult
activationDistance = safeAtr * activationDistanceAtr * sensitivityMult
riskEdge = activePlan ? (useBullSide ? activeShelf - safeAtr * riskEdgeAtr : activeShelf + safeAtr * riskEdgeAtr) : na
riskSpan = activePlan ? math.abs(activeShelf - riskEdge) : na
targetGuide = activePlan ? (useBullSide ? activeShelf + riskSpan * targetRMultiple : activeShelf - riskSpan * targetRMultiple) : na
zoneTop = activePlan ? activeShelf + zonePad : na
zoneBottom = activePlan ? activeShelf - zonePad : na
touchesZone = activePlan and high >= zoneBottom and low <= zoneTop
nearZone = activePlan and math.abs(close - activeShelf) <= activationDistance
riskBreached = activePlan and (useBullSide ? close < riskEdge : close > riskEdge)

var int activeShelfMemoryBar = na
var bool activeShelfMemoryBull = false
var int lastTouchBar = na
var bool invalidationLatched = false
var float latchedRiskEdge = na

activePlanChanged = activePlan and (na(activeShelfMemoryBar) or activeShelfBar != activeShelfMemoryBar or useBullSide != activeShelfMemoryBull)
if activePlanChanged
    lastTouchBar := na
    invalidationLatched := false
    latchedRiskEdge := na
    activeShelfMemoryBar := activeShelfBar
    activeShelfMemoryBull := useBullSide

invalidationStart = confirmReady and activePlan and riskBreached and not invalidationLatched
if invalidationStart
    invalidationLatched := true
    latchedRiskEdge := riskEdge
invalidated = invalidationLatched

enteredZone = touchesZone and (activePlanChanged or not (touchesZone[1] == true))
if confirmReady and enteredZone
    lastTouchBar := bar_index

touchAge = na(lastTouchBar) ? 100000 : bar_index - lastTouchBar
touchedRecently = activePlan and touchAge <= responseWindowBars

// -------------------------------------------------
// Score Model
// -------------------------------------------------
barRange = math.max(high - low, syminfo.mintick)
lowerWick = math.max(math.min(open, close) - low, 0.0)
upperWick = math.max(high - math.max(open, close), 0.0)
wickRatio = useBullSide ? lowerWick / barRange : upperWick / barRange
wickScore = activePlan ? f_norm_high(wickRatio, 0.10, 0.55) : 0.0

probeDepthAtr = activePlan ? (useBullSide ? math.max((activeShelf - low) / safeAtr, 0.0) : math.max((high - activeShelf) / safeAtr, 0.0)) : na
distanceToShelfAtr = activePlan ? math.abs(close - activeShelf) / safeAtr : na
retestDepthScore = activePlan ? (touchesZone or touchedRecently ? f_peak_score(probeDepthAtr, 0.0, idealProbeAtr, effectiveMaxProbeAtr) : f_norm_low(distanceToShelfAtr, 0.0, activationDistanceAtr * sensitivityMult)) : 0.0

defendedCloseAtr = activePlan ? (useBullSide ? (close - activeShelf) / safeAtr : (activeShelf - close) / safeAtr) : na
closeSideScore = activePlan ? f_norm_high(defendedCloseAtr, -defenseZoneAtr, closeResponseAtr) : 0.0
closeLocation = useBullSide ? (close - low) / barRange : (high - close) / barRange
closeLocationScore = f_norm_high(closeLocation, 0.45, 0.85)
closeResponseScore = activePlan ? closeSideScore * 0.58 + closeLocationScore * 0.42 : 0.0

rawTimeScore = 0.0
if touchedRecently
    if touchAge <= idealHoldBars
        rawTimeScore := f_norm_high(float(touchAge), 0.0, float(idealHoldBars))
    else
        rawTimeScore := f_norm_low(float(touchAge), float(idealHoldBars), float(responseWindowBars))
timeAtLevelScore = touchedRecently ? math.max(rawTimeScore, 55.0) : 0.0

volumeScore = useVolumeSupport ? f_norm_high(relativeVolume, 0.75, 1.60) : 70.0
reactionScore = activePlan ? wickScore * 0.34 + closeResponseScore * 0.46 + volumeScore * 0.20 : 0.0
qualityRaw = activePlan ? retestDepthScore * 0.24 + wickScore * 0.20 + closeResponseScore * 0.24 + timeAtLevelScore * 0.16 + volumeScore * 0.16 : 0.0
qualityScore = qualityRaw
if activePlan and not nearZone and not touchedRecently
    qualityScore := math.min(qualityRaw, 42.0)
if invalidated
    qualityScore := math.min(qualityScore, 30.0)

targetRoomAtr = activePlan ? (useBullSide ? (targetGuide - close) / safeAtr : (close - targetGuide) / safeAtr) : na
displayedRiskEdge = invalidated and not na(latchedRiskEdge) ? latchedRiskEdge : riskEdge
riskDistanceAtr = activePlan ? math.abs(close - displayedRiskEdge) / safeAtr : na
roomClean = activePlan and targetRoomAtr >= minTargetRoomAtr
defendedState = activePlan and touchedRecently and qualityScore >= effectiveDefendedScore and roomClean and not invalidated
watchState = activePlan and touchedRecently and qualityScore >= watchScore and not defendedState and not invalidated
weakRetestState = activePlan and touchedRecently and qualityScore < watchScore and not invalidated
approachState = activePlan and nearZone and not touchedRecently and not invalidated

stateText = "Scan"
if activePlan
    if invalidated
        stateText := "Defense Lost"
    else if defendedState
        stateText := "Defended"
    else if watchState
        stateText := "Watch"
    else if weakRetestState
        stateText := "Weak Retest"
    else if approachState
        stateText := "Approach"
    else
        stateText := "Wait"

actionText = switch stateText
    "Defended" => "Review hold"
    "Watch" => "Wait response"
    "Weak Retest" => "Risk review"
    "Approach" => "Prepare review"
    "Defense Lost" => "Rebuild context"
    "Wait" => "Scan next touch"
    => "Find shelf"

directionColor = activePlan ? (useBullSide ? bullColor : bearColor) : neutralColor
stateColor = switch stateText
    "Defended" => directionColor
    "Watch" => accentColor
    "Weak Retest" => neutralColor
    "Approach" => accentColor
    "Defense Lost" => dangerColor
    => neutralColor

reactionText = reactionScore >= 72.0 ? "Clean" : reactionScore >= 55.0 ? "Developing" : reactionScore >= 40.0 ? "Fragile" : "Weak"
riskText = activePlan ? f_price(displayedRiskEdge) + " / " + f_fmt(riskDistanceAtr) + " ATR" : "-"

// -------------------------------------------------
// Chart Objects
// -------------------------------------------------
var box defenseBox = na
var line shelfLine = na
var line riskLine = na
var line targetLine = na
var line shelfConnector = na
var line riskConnector = na
var line targetConnector = na
var label zoneBadge = na
var label shelfTag = na
var label riskTag = na
var label targetTag = na

leftEdge = activePlan ? math.max(activeShelfBar, bar_index - math.min(maxShelfAge, 96)) : bar_index
rightEdge = bar_index + projectionBars
guideTagX = rightEdge + guideTagOffsetBars
zoneText = activePlan ? "SHELF | " + f_compact_state(stateText) + (showLabelScore ? " | " + str.tostring(math.round(qualityScore)) : "") : ""
zoneCenterX = activePlan ? int(math.round((leftEdge + rightEdge) / 2.0)) : bar_index
zoneCenterY = activePlan ? (zoneTop + zoneBottom) * 0.5 : close
guideBadgeGap = f_guide_badge_gap(safeAtr, labelFontSize)
shelfTagY = activeShelf
targetTagY = not useSmartGuideLanes or not activePlan ? targetGuide : useBullSide ? math.max(targetGuide, activeShelf + guideBadgeGap) : math.min(targetGuide, activeShelf - guideBadgeGap)
riskTagY = not useSmartGuideLanes or not activePlan ? riskEdge : useBullSide ? math.min(riskEdge, activeShelf - guideBadgeGap) : math.max(riskEdge, activeShelf + guideBadgeGap)
showOwnedGuides = showGuideLines and showRightTags

if showDefenseZone and activePlan
    if na(defenseBox)
        defenseBox := box.new(left = leftEdge, top = zoneTop, right = rightEdge, bottom = zoneBottom, xloc = xloc.bar_index, border_color = color.new(stateColor, 18), bgcolor = color.new(directionColor, zoneTransparency), border_width = 1)
    else
        box.set_lefttop(defenseBox, leftEdge, zoneTop)
        box.set_rightbottom(defenseBox, rightEdge, zoneBottom)
        box.set_border_color(defenseBox, color.new(stateColor, 18))
        box.set_bgcolor(defenseBox, color.new(directionColor, zoneTransparency))
    if na(zoneBadge)
        zoneBadge := label.new(zoneCenterX, zoneCenterY, "", xloc = xloc.bar_index, style = label.style_label_center, color = stateColor, textcolor = f_text_on(stateColor), size = f_text_size(labelFontSize))
    f_set_label(zoneBadge, zoneCenterX, zoneCenterY, zoneText, stateColor, label.style_label_center)
else
    if not na(defenseBox)
        box.delete(defenseBox)
        defenseBox := na
    if not na(zoneBadge)
        label.delete(zoneBadge)
        zoneBadge := na

if showOwnedGuides and activePlan and not invalidated
    if na(shelfLine)
        shelfLine := line.new(x1 = leftEdge, y1 = activeShelf, x2 = rightEdge, y2 = activeShelf, xloc = xloc.bar_index, extend = extend.none, color = directionColor, style = line.style_solid, width = 2)
    else
        line.set_xy1(shelfLine, leftEdge, activeShelf)
        line.set_xy2(shelfLine, rightEdge, activeShelf)
        line.set_color(shelfLine, directionColor)
    if na(riskLine)
        riskLine := line.new(x1 = leftEdge, y1 = riskEdge, x2 = rightEdge, y2 = riskEdge, xloc = xloc.bar_index, extend = extend.none, color = invalidated ? dangerColor : neutralColor, style = line.style_dashed, width = 2)
    else
        line.set_xy1(riskLine, leftEdge, riskEdge)
        line.set_xy2(riskLine, rightEdge, riskEdge)
        line.set_color(riskLine, invalidated ? dangerColor : neutralColor)
    if na(targetLine)
        targetLine := line.new(x1 = leftEdge, y1 = targetGuide, x2 = rightEdge, y2 = targetGuide, xloc = xloc.bar_index, extend = extend.none, color = accentColor, style = line.style_dotted, width = 1)
    else
        line.set_xy1(targetLine, leftEdge, targetGuide)
        line.set_xy2(targetLine, rightEdge, targetGuide)
        line.set_color(targetLine, accentColor)
    if na(shelfConnector)
        shelfConnector := line.new(x1 = rightEdge, y1 = activeShelf, x2 = guideTagX, y2 = shelfTagY, xloc = xloc.bar_index, extend = extend.none, color = directionColor, style = line.style_solid, width = 2)
    else
        line.set_xy1(shelfConnector, rightEdge, activeShelf)
        line.set_xy2(shelfConnector, guideTagX, shelfTagY)
        line.set_color(shelfConnector, directionColor)
    if na(riskConnector)
        riskConnector := line.new(x1 = rightEdge, y1 = riskEdge, x2 = guideTagX, y2 = riskTagY, xloc = xloc.bar_index, extend = extend.none, color = invalidated ? dangerColor : neutralColor, style = line.style_dashed, width = 2)
    else
        line.set_xy1(riskConnector, rightEdge, riskEdge)
        line.set_xy2(riskConnector, guideTagX, riskTagY)
        line.set_color(riskConnector, invalidated ? dangerColor : neutralColor)
    if na(targetConnector)
        targetConnector := line.new(x1 = rightEdge, y1 = targetGuide, x2 = guideTagX, y2 = targetTagY, xloc = xloc.bar_index, extend = extend.none, color = accentColor, style = line.style_dotted, width = 1)
    else
        line.set_xy1(targetConnector, rightEdge, targetGuide)
        line.set_xy2(targetConnector, guideTagX, targetTagY)
        line.set_color(targetConnector, accentColor)
    if showRightTags
        if na(shelfTag)
            shelfTag := label.new(guideTagX, shelfTagY, "", xloc = xloc.bar_index, style = label.style_label_left, color = directionColor, textcolor = f_text_on(directionColor), size = f_text_size(labelFontSize))
        f_set_label(shelfTag, guideTagX, shelfTagY, "Shelf " + f_price(activeShelf), directionColor, label.style_label_left)
        if na(riskTag)
            riskTag := label.new(guideTagX, riskTagY, "", xloc = xloc.bar_index, style = label.style_label_left, color = neutralColor, textcolor = f_text_on(neutralColor), size = f_text_size(labelFontSize))
        f_set_label(riskTag, guideTagX, riskTagY, "Risk " + f_price(riskEdge), invalidated ? dangerColor : neutralColor, label.style_label_left)
        if na(targetTag)
            targetTag := label.new(guideTagX, targetTagY, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = f_text_on(accentColor), size = f_text_size(labelFontSize))
        f_set_label(targetTag, guideTagX, targetTagY, "Target " + f_price(targetGuide), accentColor, label.style_label_left)
    else
        if not na(shelfTag)
            label.delete(shelfTag)
            shelfTag := na
        if not na(riskTag)
            label.delete(riskTag)
            riskTag := na
        if not na(targetTag)
            label.delete(targetTag)
            targetTag := na
else
    if not na(shelfLine)
        line.delete(shelfLine)
        shelfLine := na
    if not na(riskLine)
        line.delete(riskLine)
        riskLine := na
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na
    if not na(shelfConnector)
        line.delete(shelfConnector)
        shelfConnector := na
    if not na(riskConnector)
        line.delete(riskConnector)
        riskConnector := na
    if not na(targetConnector)
        line.delete(targetConnector)
        targetConnector := na
    if not na(shelfTag)
        label.delete(shelfTag)
        shelfTag := na
    if not na(riskTag)
        label.delete(riskTag)
        riskTag := na
    if not na(targetTag)
        label.delete(targetTag)
        targetTag := na

// -------------------------------------------------
// Labels
// -------------------------------------------------
var array<label> chartLabels = array.new_label()
var float[] lblBars = array.new_float()
var float[] lblYs = array.new_float()
var int lastEventLabelBar = na
var int lastContextLabelBar = na

prevDefended = defendedState[1] == true
prevWatch = watchState[1] == true
prevWeak = weakRetestState[1] == true

touchEvent = confirmReady and enteredZone
defendedEvent = confirmReady and defendedState and not prevDefended
watchEvent = confirmReady and watchState and not prevWatch
weakEvent = confirmReady and weakRetestState and not prevWeak
lostEvent = invalidationStart

eventCooldownReady = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
scoreSuffix = showLabelScore ? " | " + str.tostring(math.round(qualityScore)) : ""

if showEventLabels and eventCooldownReady
    if lostEvent
        lostBaseY = useBullSide ? math.max(high, zoneTop) + safeAtr * labelOffsetAtr : math.min(low, zoneBottom) - safeAtr * labelOffsetAtr
        lostY = f_resolve_y(bar_index, lostBaseY, useBullSide ? 1.0 : -1.0, safeAtr * 2.4, lblBars, lblYs)
        f_add_label(chartLabels, bar_index, lostY, "Lost " + f_price(latchedRiskEdge) + scoreSuffix, dangerColor, not useBullSide)
        lastEventLabelBar := bar_index
    else if defendedEvent
        defendedBaseY = useBullSide ? math.min(low, zoneBottom) - safeAtr * labelOffsetAtr : math.max(high, zoneTop) + safeAtr * labelOffsetAtr
        defendedY = f_resolve_y(bar_index, defendedBaseY, useBullSide ? -1.0 : 1.0, safeAtr * 2.4, lblBars, lblYs)
        f_add_label(chartLabels, bar_index, defendedY, "Defended" + scoreSuffix, directionColor, useBullSide)
        lastEventLabelBar := bar_index
    else if watchEvent
        watchBaseY = useBullSide ? math.min(low, zoneBottom) - safeAtr * labelOffsetAtr : math.max(high, zoneTop) + safeAtr * labelOffsetAtr
        watchY = f_resolve_y(bar_index, watchBaseY, useBullSide ? -1.0 : 1.0, safeAtr * 2.4, lblBars, lblYs)
        f_add_label(chartLabels, bar_index, watchY, "Watch" + scoreSuffix, accentColor, useBullSide)
        lastEventLabelBar := bar_index
    else if weakEvent
        weakBaseY = useBullSide ? math.max(high, zoneTop) + safeAtr * labelOffsetAtr : math.min(low, zoneBottom) - safeAtr * labelOffsetAtr
        weakY = f_resolve_y(bar_index, weakBaseY, useBullSide ? 1.0 : -1.0, safeAtr * 2.4, lblBars, lblYs)
        f_add_label(chartLabels, bar_index, weakY, "Weak Retest" + scoreSuffix, neutralColor, not useBullSide)
        lastEventLabelBar := bar_index
    else if touchEvent
        touchBaseY = useBullSide ? math.min(low, zoneBottom) - safeAtr * labelOffsetAtr : math.max(high, zoneTop) + safeAtr * labelOffsetAtr
        touchY = f_resolve_y(bar_index, touchBaseY, useBullSide ? -1.0 : 1.0, safeAtr * 2.4, lblBars, lblYs)
        f_add_label(chartLabels, bar_index, touchY, "Test" + scoreSuffix, directionColor, useBullSide)
        lastEventLabelBar := bar_index

contextReady = showContextLabels and confirmReady and activePlan and (nearZone or touchedRecently) and not invalidated and (na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars)
if contextReady
    contextText = touchedRecently ? f_compact_state(stateText) : "Shelf Near"
    contextBaseY = useBullSide ? math.min(low, zoneBottom) - safeAtr * (labelOffsetAtr + 0.55) : math.max(high, zoneTop) + safeAtr * (labelOffsetAtr + 0.55)
    contextY = f_resolve_y(bar_index, contextBaseY, useBullSide ? -1.0 : 1.0, safeAtr * 2.4, lblBars, lblYs)
    f_add_label(chartLabels, bar_index, contextY, contextText + scoreSuffix, stateColor, useBullSide)
    lastContextLabelBar := bar_index

f_trim_labels(chartLabels, maxVisibleLabels, labelHistoryBars, bar_index)

// -------------------------------------------------
// Target-room follow-through proof (stop-aware)
// -------------------------------------------------
// After each defense touch, did price reach the target-room guide before the
// risk edge was crossed? Win = target room first, Loss = risk edge first,
// neither inside the window = resolved as a non-hold timeout.
var int   pfTotal  = 0
var int   pfWins   = 0
var bool  pfOpen   = false
var int   pfDir    = 0
var float pfTarget = na
var float pfStop   = na
var int   pfBar    = na

if confirmReady
    bool pfResolvedThisBar = false
    if pfOpen
        bool pfHitStop   = pfDir == 1 ? low <= pfStop : high >= pfStop
        bool pfHitTarget = pfDir == 1 ? high >= pfTarget : low <= pfTarget
        if pfHitStop
            pfTotal += 1
            pfOpen  := false
            pfResolvedThisBar := true
        else if pfHitTarget
            pfTotal += 1
            pfWins  += 1
            pfOpen  := false
            pfResolvedThisBar := true
        else if not na(pfBar) and bar_index - pfBar >= proofWindowBars
            pfTotal += 1
            pfOpen := false
            pfResolvedThisBar := true
    if touchEvent and not invalidated and not pfOpen and not pfResolvedThisBar and not na(targetGuide) and not na(riskEdge)
        pfOpen   := true
        pfDir    := useBullSide ? 1 : -1
        pfTarget := targetGuide
        pfStop   := riskEdge
        pfBar    := bar_index

float pfRate = pfTotal > 0 ? pfWins / pfTotal * 100.0 : na
holdRateText = pfTotal >= minimumProofSamples ? str.tostring(math.round(pfRate)) + "% | " + str.tostring(pfWins) + "/" + str.tostring(pfTotal) : "Building " + str.tostring(pfTotal) + "/" + str.tostring(minimumProofSamples)

// -------------------------------------------------
// Data Window
// -------------------------------------------------
plot(qualityScore, title = "Retest Defense Score", color = stateColor, display = display.data_window)
plot(reactionScore, title = "Reaction Quality Score", color = directionColor, display = display.data_window)
plot(retestDepthScore, title = "Retest Depth Score", color = accentColor, display = display.data_window)
plot(wickScore, title = "Wick Defense Score", color = neutralColor, display = display.data_window)
plot(closeResponseScore, title = "Close Response Score", color = bearColor, display = display.data_window)
plot(volumeScore, title = "Volume Support Score", color = panelLabelCol, display = display.data_window)
plot(pfTotal >= minimumProofSamples ? pfRate : na, title = "Historical Hold Rate", color = bullColor, display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
scoreRead = activePlan ? str.tostring(math.round(qualityScore)) + " / " + f_grade(qualityScore) : "-"
reactionRead = activePlan ? str.tostring(math.round(reactionScore)) + " / " + reactionText : "-"
stateRead = activePlan ? stateText : "-"
actionRead = actionText
panelFrame = f_panel_border(panelTheme)
holdRateCol = pfTotal >= minimumProofSamples ? (pfRate >= 55.0 ? bullColor : pfRate >= 45.0 ? neutralColor : bearColor) : f_panel_value(panelTheme)

var table panel = na
var string panelLocationCache = ""
var string panelThemeCache = ""

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    panelLocationCache := ""
    panelThemeCache := ""

if showPanel and (na(panel) or panelLocationCache != panelLocation or panelThemeCache != panelTheme)
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_position(panelLocation), 2, 7, bgcolor = f_panel_bg(panelTheme), frame_color = panelFrame, frame_width = 1, border_color = panelFrame, border_width = 1)
    table.cell(panel, 0, 0, "AG Pro Retest Defense Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize))
    table.merge_cells(panel, 0, 0, 1, 0)
    panelLocationCache := panelLocation
    panelThemeCache := panelTheme

if showPanel and barstate.islast and not na(panel)
    table.clear(panel, 0, 1, 1, 6)
    table.cell(panel, 0, 0, "AG Pro Retest Defense Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
    f_set_row(panel, 1, "Defense State", stateRead, stateColor, panelTheme, panelFontSize)
    f_set_row(panel, 2, "Retest Score", scoreRead, stateColor, panelTheme, panelFontSize)
    f_set_row(panel, 3, "Reaction Quality", reactionRead, reactionScore >= 72.0 ? directionColor : reactionScore >= 55.0 ? accentColor : neutralColor, panelTheme, panelFontSize)
    f_set_row(panel, 4, "Risk Edge", riskText, invalidated ? dangerColor : neutralColor, panelTheme, panelFontSize)
    f_set_row(panel, 5, "Historical Hold", holdRateText, holdRateCol, panelTheme, panelFontSize)
    f_set_row(panel, 6, "Action", actionRead, stateColor, panelTheme, panelFontSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(touchEvent, title = "Retest Defense Touch", message = "Retest Defense Planner: price has touched the active defense zone.")
alertcondition(defendedEvent, title = "Retest Defense Defended", message = "Retest Defense Planner: the active defense shelf is holding with sufficient quality for review.")
alertcondition(watchEvent, title = "Retest Defense Watch", message = "Retest Defense Planner: the defense response is improving but still requires confirmation.")
alertcondition(weakEvent, title = "Retest Defense Weak Retest", message = "Retest Defense Planner: price retested the defense shelf but response quality is weak.")
alertcondition(lostEvent, title = "Retest Defense Lost", message = "Retest Defense Planner: the active risk edge has been crossed and context should be rebuilt.")
````

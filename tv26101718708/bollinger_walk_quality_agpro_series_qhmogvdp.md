# Bollinger Walk Quality [AGPro Series]

- url: https://www.tradingview.com/script/qHMogVDP-Bollinger-Walk-Quality-AGPro-Series/
- type: indicator
- pine_id: PUB;11e126d8677f478f84fc26eedc8bac0a
- version: 4.0

## Description

📌 Bollinger Walk Quality [AGPro Series]

Bollinger Walk Quality [AGPro Series] is built for one specific question: when price starts walking the outer Bollinger Band, is that walk strong enough to support continuation, or is the structure beginning to fail?

Many Bollinger Band tools focus on band touches, volatility contraction, width percentiles, or squeeze-style expansion setups. This script takes a different approach. It studies the behavior that comes after expansion: persistent upper-band or lower-band walking, directional pressure around the outer lane, pullback quality inside the band structure, and the point where the walk begins to lose control.

The goal is to make Bollinger Band continuation easier to read directly on the chart. Instead of treating every band touch as meaningful, the script scores whether price is staying in the correct outer lane, whether the Bollinger basis supports the active direction, whether pressure is persisting across multiple bars, and whether a pullback is holding in a healthy continuation pocket.

🧭 What The Script Measures

1. Walk Side
The panel identifies whether the active environment is an Upper Walk, Lower Walk, Cooling Walk, or Neutral state.

Upper Walk means price is persistently operating near the upper Bollinger lane while the basis supports upward continuation pressure.

Lower Walk means price is persistently operating near the lower Bollinger lane while the basis supports downward continuation pressure.

Cooling states appear when a recent walk is no longer fully active, but the script is still monitoring pullback quality and failure risk for a limited memory window.

2. Band Pressure
Band Pressure is a quality score for the active or developing walk. It combines outer-lane position, persistence, band contact behavior, basis slope support, and candle direction. A higher score means the walk has stronger structural pressure. A lower score means price is no longer showing durable outer-band control.

This keeps the script focused on continuation quality instead of simple band interaction. The chart can show a band touch, but the panel helps separate a weak touch from a real band-walk environment.

3. Pullback Quality
Healthy band walks often reset toward the middle of the Bollinger structure before continuing. Bollinger Walk Quality tracks that reset through a concept-native pullback pocket.

The pullback pocket is not a generic support or resistance rectangle. It is projected from the current Bollinger structure and represents the area where a band walk can cool off while still keeping its continuation profile intact.

The panel can show states such as Awaiting Pullback, Testing Pocket, Clean Hold, or Weak Reset. This helps distinguish a controlled continuation reset from a walk that is losing quality.

4. Failure Risk
Failure Risk is designed to catch the moment when an active or recently active band walk starts to break down. It rises when price loses the outer lane, pressure falls, the basis slope weakens, or price begins to threaten the Bollinger basis.

The failure label is intentionally restrained. It appears only on fresh failure events, so the chart remains clean and readable instead of filling with repeated warnings.

🎯 Core Features

- Outer-band walk detection for upper and lower Bollinger continuation phases
- Band pressure scoring based on lane position, persistence, slope support, and band contact behavior
- Pullback-to-band quality state for continuation resets
- Projected pullback pockets that show where a healthy walk can reset without losing structure
- Failure warning labels when the active walk loses pressure or threatens the basis
- Clean AG Pro panel with walk side, band pressure, pullback quality, and failure risk
- Adjustable panel location, theme, font sizes, label spacing, label clearance, zone projection, and visual density

📊 Visual Design

The default view is designed for a clean public TradingView chart.

The script displays Bollinger Bands, highlights the active walk track, projects a limited number of pullback zones, and uses event labels with spacing controls. Labels are anchored outside the local candle envelope so they do not disappear inside candles or cover important price action.

The chart remains active enough to be visually informative, but the object count and label density are controlled by default. This keeps the indicator suitable for repeated use across different symbols and timeframes.

🧩 Panel

The AG Pro panel summarizes the current state in four compact rows:

- Walk Side
- Band Pressure
- Pullback Quality
- Failure Risk

Panel location, panel theme, panel font size, label font size, label spacing, label clearance, zone projection, zone opacity, and object limits are all adjustable from the settings menu.

🔎 How This Is Different

Bollinger Walk Quality is not a squeeze map and does not rely on compression logic. It does not use Keltner confirmation, volatility percentile ranking, or width contraction states.

Its lane is continuation after expansion:

- Is price walking the band?
- Which side controls the walk?
- Is the walk supported by pressure and basis slope?
- Is the pullback still healthy?
- Is the walk beginning to fail?

That makes it a separate Bollinger Band workflow from squeeze-focused tools. It is designed for traders who want to evaluate trend continuation rhythm, pullback behavior, and outer-band pressure in a more structured way.

✅ Best Use Cases

- Studying Bollinger Band walk continuation
- Reviewing trend pressure after expansion
- Identifying controlled pullbacks inside active band-walk environments
- Monitoring when a walk is cooling or losing quality
- Comparing upper-band and lower-band pressure across market phases
- Keeping Bollinger Band continuation analysis clean and visual

⚙️ Settings Overview

Engine settings control the Bollinger length, multiplier, source, basis slope lookback, and ATR normalization.

Band Walk Logic settings control the outer-lane depth, minimum walk persistence, minimum walk score, pullback memory, and failure warning threshold.

Visual settings control Bollinger Bands, walk highlight, pullback zones, event labels, label spacing, label count, label offset, label clearance, and label font size.

Pullback Zone settings control zone projection length, maximum visible zones, and opacity.

Panel settings control the information panel, location, theme, and font size.

🏁 Design Intent

Bollinger Walk Quality [AGPro Series] is designed to make Bollinger Band continuation more readable without turning the chart into a crowded signal dashboard.

The script focuses on structure, persistence, pullback quality, and failure behavior. It gives the chart a clear visual rhythm while keeping the panel concise and the labels controlled.

This makes the script useful as a premium public Bollinger continuation tool and keeps it clearly differentiated from Bollinger squeeze, compression, and volatility expansion maps.

## Source Code

````pine
// -------------------------------------------------
// Bollinger Walk Quality [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Bollinger Walk Quality is a continuation-focused Bollinger Bands overlay
// that studies persistent upper-band and lower-band walking behavior,
// pullback-to-band quality, band pressure, and early failure risk. It avoids
// squeeze, compression, Keltner, and percentile-width logic so the script
// remains clearly separated from Bollinger squeeze-map workflows. A live Walk
// Continuation Rate logs how often a new band walk reaches a balanced one-risk
// target before losing the basis, as honest, non-repainting proof of the walk.
// Version 1.5 adds exclusive pocket ownership and collision-safe event density.
// -------------------------------------------------
//@version=6
indicator("Bollinger Walk Quality [AGPro Series]",
     shorttitle = "AG Pro BWQ",
     overlay = true,
     max_boxes_count = 60,
     max_labels_count = 140)

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
color darkText      = color.rgb(17, 24, 39)
color pocketBadgeBg = color.rgb(59, 130, 246)
color pocketBadgeMutedBg = color.rgb(51, 65, 85)
color pocketBadgeMidBg = color.rgb(99, 102, 241)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
string ttSource = "Price source used for Bollinger Band calculations and walk pressure scoring."
string ttLength = "Lookback length used to calculate the Bollinger basis and standard deviation."
string ttMult = "Standard deviation multiplier used to set the upper and lower Bollinger Bands."
string ttSlope = "Bars used to evaluate whether the Bollinger basis is supporting the active walk direction."
string ttAtr = "ATR length used for label spacing, zone projection balance, and risk normalization."
string ttLane = "Controls how deep price can move inside the band and still count as outer-band walking behavior."
string ttBars = "Minimum persistence required before the planner classifies price as an active band walk."
string ttScore = "Minimum quality score required to promote an outer-band lane into an active walk state."
string ttMemory = "Bars after an active walk during which pullback quality and failure risk remain monitored."
string ttFailure = "Failure risk score required before the planner can print a band-walk failure warning label."
string ttProof = "Bars allowed for a new walk to reach its one-risk target or lose the basis before the sample is left unresolved (uncounted) in the Walk Continuation Rate."
string ttBands = "Displays the Bollinger basis, upper band, and lower band used by the engine."
string ttHighlight = "Highlights the active upper-band or lower-band walk lane directly on the chart."
string ttTrack = "Shows a refined directional walk rail only while a band walk is active. The rail uses line breaks so separate walks do not connect into long zigzags."
string ttZones = "Draws concept-native continuation pullback pockets while a band walk is active or recently active."
string ttBadges = "Places a centered premium badge inside the active pullback pocket. This keeps the zone readable without embedding text in the box."
string ttAdaptive = "Shortens forward projection on higher timeframes so pullback zones do not dominate the chart."
string ttBadgeAnchor = "Controls where the centered pocket badge sits horizontally inside the projected zone."
string ttLabels = "Displays restrained labels for confirmed band walks, clean pullback holds, and failure warnings."
string ttCooldown = "Minimum spacing between event labels to keep the chart readable."
string ttMaxLabels = "Maximum number of active event labels kept on the chart."
string ttOffset = "ATR-based vertical clearance that pushes event labels outside the local candle envelope."
string ttClear = "Number of recent bars used to anchor labels above or below the nearby candle cluster."
string ttLabelSize = "Controls the font size used by event labels and centered pocket badges."
string ttProjection = "How far active pullback pockets are projected to the right side of the chart."
string ttMaxZones = "Maximum number of historical pullback zones kept on the chart."
string ttOpacity = "Transparency level for pullback zones. Higher values create a lighter visual footprint."
string ttPanelShow = "Displays the AG Pro status panel with walk side, band pressure, pullback quality, failure risk, and next action."
string ttPanelLoc = "Sets the chart location of the information panel."
string ttPanelTheme = "Controls the panel color theme while preserving the AGPro blue merged header row."
string ttPanelFont = "Controls the font size used inside the AG Pro information panel."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string grpEngine = "Engine"
src = input.source(close, "Source", group = grpEngine, tooltip = ttSource)
bbLength = input.int(20, "Bollinger Length", minval = 5, maxval = 200, group = grpEngine, tooltip = ttLength)
bbMult = input.float(2.0, "Band Multiplier", minval = 0.5, maxval = 5.0, step = 0.1, group = grpEngine, tooltip = ttMult)
slopeLookback = input.int(5, "Basis Slope Lookback", minval = 1, maxval = 50, group = grpEngine, tooltip = ttSlope)
atrLength = input.int(14, "ATR Length", minval = 1, maxval = 100, group = grpEngine, tooltip = ttAtr)

string grpWalk = "Band Walk Logic"
laneDepth = input.float(0.35, "Outer Lane Depth", minval = 0.05, maxval = 0.90, step = 0.05, group = grpWalk, tooltip = ttLane)
minWalkBars = input.int(3, "Minimum Walk Bars", minval = 1, maxval = 20, group = grpWalk, tooltip = ttBars)
minWalkScore = input.float(55.0, "Minimum Walk Score", minval = 1.0, maxval = 100.0, step = 1.0, group = grpWalk, tooltip = ttScore)
pullbackMemory = input.int(8, "Pullback Memory Bars", minval = 1, maxval = 50, group = grpWalk, tooltip = ttMemory)
failureThreshold = input.float(72.0, "Failure Warning Threshold", minval = 40.0, maxval = 95.0, step = 1.0, group = grpWalk, tooltip = ttFailure)
proofWindowBars = input.int(30, "Walk Proof Window Bars", minval = 8, maxval = 200, group = grpWalk, tooltip = ttProof)

string grpVisual = "Visuals"
showBands = input.bool(true, "Show Bollinger Bands", group = grpVisual, tooltip = ttBands)
showWalkHighlight = input.bool(true, "Show Band Walk Highlight", group = grpVisual, tooltip = ttHighlight)
showWalkTrack = input.bool(true, "Show Walk Track", group = grpVisual, tooltip = ttTrack)
showPullbackZones = input.bool(true, "Show Pullback Zones", group = grpVisual, tooltip = ttZones)
showPocketBadges = input.bool(true, "Show Centered Pocket Badge", group = grpVisual, tooltip = ttBadges)
adaptiveProjection = input.bool(true, "Adaptive HTF Projection", group = grpVisual, tooltip = ttAdaptive)
zoneBadgeAnchor = input.float(0.56, "Zone Badge Anchor", minval = 0.25, maxval = 0.75, step = 0.05, group = grpVisual, tooltip = ttBadgeAnchor)
showEventLabels = input.bool(true, "Show Event Labels", group = grpVisual, tooltip = ttLabels)
labelCooldown = input.int(48, "Label Cooldown", minval = 1, maxval = 100, group = grpVisual, tooltip = ttCooldown)
maxVisibleLabels = input.int(6, "Max Visible Labels", minval = 4, maxval = 60, group = grpVisual, tooltip = ttMaxLabels)
labelOffsetAtr = input.float(1.15, "Label Offset ATR", minval = 0.1, maxval = 5.0, step = 0.05, group = grpVisual, tooltip = ttOffset)
labelClearBars = input.int(5, "Label Clearance Bars", minval = 1, maxval = 20, group = grpVisual, tooltip = ttClear)
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpVisual, tooltip = ttLabelSize)

string grpZones = "Pullback Zones"
zoneForwardBars = input.int(20, "Zone Projection Bars", minval = 5, maxval = 100, group = grpZones, tooltip = ttProjection)
maxVisibleZones = input.int(2, "Max Visible Zones", minval = 1, maxval = 20, group = grpZones, tooltip = ttMaxZones)
zoneOpacity = input.int(92, "Zone Opacity", minval = 70, maxval = 96, group = grpZones, tooltip = ttOpacity)

string grpPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = grpPanel, tooltip = ttPanelShow)
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grpPanel, tooltip = ttPanelLoc)
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light", "Auto"], group = grpPanel, tooltip = ttPanelTheme)
panelFontInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpPanel, tooltip = ttPanelFont)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_text_on(color bg) =>
    bright = (color.r(bg) * 299 + color.g(bg) * 587 + color.b(bg) * 114) / 1000
    bright >= 145 ? darkText : headerText

f_size(string value) =>
    switch value
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_badge_size(string value) =>
    switch value
        "Tiny" => size.tiny
        "Small" => size.tiny
        "Large" => size.normal
        "Huge" => size.normal
        => size.small

f_position(string value) =>
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

f_chart_is_light() =>
    float brightness = color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color)
    brightness > 382.0

f_theme_bg(string value) =>
    bool lightChart = f_chart_is_light()
    switch value
        "Clean Light" => color.rgb(245, 247, 250)
        "Slate" => color.rgb(30, 41, 59)
        "Auto" => lightChart ? color.rgb(245, 247, 250) : panelBg
        => panelBg

f_theme_border(string value) =>
    bool lightChart = f_chart_is_light()
    switch value
        "Clean Light" => color.rgb(148, 163, 184)
        "Slate" => color.rgb(71, 85, 105)
        "Auto" => lightChart ? color.rgb(148, 163, 184) : panelBorder
        => panelBorder

f_theme_label(string value) =>
    bool lightChart = f_chart_is_light()
    switch value
        "Clean Light" => color.rgb(71, 85, 105)
        "Auto" => lightChart ? color.rgb(71, 85, 105) : panelLabelCol
        => panelLabelCol

f_theme_value(string value) =>
    bool lightChart = f_chart_is_light()
    switch value
        "Clean Light" => color.rgb(15, 23, 42)
        "Auto" => lightChart ? color.rgb(15, 23, 42) : panelValueCol
        => panelValueCol

f_row_bg(string theme, int row) =>
    bool lightChart = f_chart_is_light()
    bool lightMode = theme == "Clean Light" or (theme == "Auto" and lightChart)
    bool slateMode = theme == "Slate"
    bool evenRow = row % 2 == 0
    lightMode ? (evenRow ? color.rgb(226, 232, 240) : color.rgb(245, 247, 250)) : slateMode ? (evenRow ? color.rgb(37, 49, 70) : color.rgb(30, 41, 59)) : (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_score_text(float score) =>
    score >= 75.0 ? "Strong" : score >= 55.0 ? "Developing" : score >= 35.0 ? "Soft" : "Low"

f_risk_text(float score) =>
    score >= failureThreshold ? "Failure Watch" : score >= 55.0 ? "Elevated" : score >= 35.0 ? "Moderate" : "Low"

f_risk_color(float score) =>
    score >= failureThreshold ? bearColor : score >= 55.0 ? neutralColor : score >= 35.0 ? accentColor : bullColor

f_grade(float score) =>
    score >= 85.0 ? "A" : score >= 70.0 ? "B" : score >= 55.0 ? "C" : "D"

f_pocket_badge_bg(float score, bool activeNow) =>
    score >= 70.0 ? (activeNow ? pocketBadgeBg : color.rgb(79, 70, 229)) : score >= 55.0 ? pocketBadgeMidBg : pocketBadgeMutedBg

f_walk_state_text(int side, bool recentlyActive, int rememberedSide, float score) =>
    side == 1 ? "Upper Walk" : side == -1 ? "Lower Walk" : recentlyActive ? (rememberedSide == 1 ? "Upper Reset Review" : "Lower Reset Review") : score >= 45.0 ? "Pressure Building" : "Scanning"

f_action_text(int side, bool recentlyActive, float pScore, float riskScore, float score) =>
    riskScore >= failureThreshold ? "Rebuild walk context" : pScore >= 80.0 ? "Review continuation" : pScore >= 55.0 ? "Track pocket response" : side != 0 ? "Wait pullback quality" : recentlyActive ? "Monitor reset quality" : score >= 45.0 ? "Watch pressure build" : "Wait band walk"

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        label oldLabel = array.shift(labels)
        label.delete(oldLabel)

f_trim_boxes(array<box> boxes, int maxCount) =>
    while array.size(boxes) > maxCount
        box oldBox = array.shift(boxes)
        box.delete(oldBox)

f_set_badge(label badge, int xValue, float yValue, string textValue, color badgeColor, string sizeValue) =>
    label.set_xy(badge, xValue, yValue)
    label.set_text(badge, textValue)
    label.set_color(badge, badgeColor)
    label.set_textcolor(badge, f_text_on(badgeColor))
    label.set_style(badge, label.style_label_center)
    label.set_size(badge, f_badge_size(sizeValue))

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_theme_label(theme), bgcolor = rowBg, text_size = f_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_size(fontSize), text_halign = text.align_right)

// -------------------------------------------------
// Bollinger Walk Engine
// -------------------------------------------------
basis = ta.sma(src, bbLength)
deviation = ta.stdev(src, bbLength) * bbMult
upperBand = basis + deviation
lowerBand = basis - deviation
bandWidth = math.max(upperBand - lowerBand, syminfo.mintick)
halfWidth = math.max(bandWidth * 0.5, syminfo.mintick)
atr = ta.atr(atrLength)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)

positionPct = f_clamp((src - lowerBand) / bandWidth * 100.0, 0.0, 100.0)
basisSlope = na(basis[slopeLookback]) ? 0.0 : basis - basis[slopeLookback]
slopeNorm = f_clamp(math.abs(basisSlope) / safeAtr * 100.0, 0.0, 30.0)

upperLaneLine = upperBand - halfWidth * laneDepth
lowerLaneLine = lowerBand + halfWidth * laneDepth
upperContact = high >= upperBand or close >= upperLaneLine
lowerContact = low <= lowerBand or close <= lowerLaneLine

bullLane = close > basis and close >= upperLaneLine and basisSlope > 0
bearLane = close < basis and close <= lowerLaneLine and basisSlope < 0

var int bullWalkBars = 0
var int bearWalkBars = 0
bullWalkBars := bullLane ? bullWalkBars + 1 : close < basis ? 0 : math.max(bullWalkBars - 1, 0)
bearWalkBars := bearLane ? bearWalkBars + 1 : close > basis ? 0 : math.max(bearWalkBars - 1, 0)

bullPressureRaw = f_clamp((positionPct - 50.0) * 2.0, 0.0, 100.0)
bearPressureRaw = f_clamp((50.0 - positionPct) * 2.0, 0.0, 100.0)

bullWalkScore = f_clamp(bullPressureRaw * 0.45 + math.min(bullWalkBars, 6) * 7.0 + slopeNorm * 0.70 + (upperContact ? 12.0 : 0.0) + (close > open ? 6.0 : 0.0), 0.0, 100.0)
bearWalkScore = f_clamp(bearPressureRaw * 0.45 + math.min(bearWalkBars, 6) * 7.0 + slopeNorm * 0.70 + (lowerContact ? 12.0 : 0.0) + (close < open ? 6.0 : 0.0), 0.0, 100.0)

bullWalk = bullWalkBars >= minWalkBars and bullWalkScore >= minWalkScore
bearWalk = bearWalkBars >= minWalkBars and bearWalkScore >= minWalkScore
walkSide = bullWalk and bullWalkScore >= bearWalkScore ? 1 : bearWalk ? -1 : 0
walkScore = walkSide == 1 ? bullWalkScore : walkSide == -1 ? bearWalkScore : math.max(bullWalkScore, bearWalkScore)
pressureText = str.tostring(math.round(walkScore)) + " / 100 - " + f_score_text(walkScore)

var int memorySide = 0
var int barsSinceWalk = 10000
if walkSide != 0
    memorySide := walkSide
    barsSinceWalk := 0
else
    barsSinceWalk += 1

walkRecently = memorySide != 0 and barsSinceWalk <= pullbackMemory
monitorSide = walkSide != 0 ? walkSide : walkRecently ? memorySide : 0
newBullWalk = walkSide == 1 and nz(walkSide[1]) != 1
newBearWalk = walkSide == -1 and nz(walkSide[1]) != -1

// -------------------------------------------------
// Pullback Quality
// -------------------------------------------------
bullPocketTop = basis + halfWidth * 0.72
bullPocketBottom = basis + halfWidth * 0.12
bearPocketTop = basis - halfWidth * 0.12
bearPocketBottom = basis - halfWidth * 0.72

bullPocketTest = monitorSide == 1 and low <= bullPocketTop and close >= bullPocketBottom and close > basis
bearPocketTest = monitorSide == -1 and high >= bearPocketBottom and close <= bearPocketTop and close < basis
bullPocketHold = bullPocketTest and close >= open and close >= close[1]
bearPocketHold = bearPocketTest and close <= open and close <= close[1]
bullPocketHoldEvent = bullPocketHold and bullPocketHold[1] != true
bearPocketHoldEvent = bearPocketHold and bearPocketHold[1] != true

pullbackScore = 0.0
if monitorSide == 1
    pullbackScore := (walkRecently ? 25.0 : 0.0) + (bullPocketTest ? 35.0 : 0.0) + (bullPocketHold ? 25.0 : 0.0) + (basisSlope > 0 ? 15.0 : 0.0)
else if monitorSide == -1
    pullbackScore := (walkRecently ? 25.0 : 0.0) + (bearPocketTest ? 35.0 : 0.0) + (bearPocketHold ? 25.0 : 0.0) + (basisSlope < 0 ? 15.0 : 0.0)
pullbackScore := f_clamp(pullbackScore, 0.0, 100.0)

pullbackText = "No Walk"
if monitorSide != 0
    if pullbackScore >= 80.0
        pullbackText := "Clean Hold"
    else if pullbackScore >= 55.0
        pullbackText := "Testing Pocket"
    else if walkSide != 0
        pullbackText := "Awaiting Pullback"
    else
        pullbackText := "Weak Reset"

// -------------------------------------------------
// Failure Risk
// -------------------------------------------------
bullLostOuterLane = monitorSide == 1 and close < upperLaneLine
bearLostOuterLane = monitorSide == -1 and close > lowerLaneLine
bullBasisThreat = monitorSide == 1 and close < basis
bearBasisThreat = monitorSide == -1 and close > basis
bullPressureFalling = monitorSide == 1 and bullWalkScore < nz(bullWalkScore[1], bullWalkScore)
bearPressureFalling = monitorSide == -1 and bearWalkScore < nz(bearWalkScore[1], bearWalkScore)

failureRisk = 0.0
if monitorSide == 1
    failureRisk := (bullBasisThreat ? 36.0 : 0.0) + (bullLostOuterLane ? 24.0 : 0.0) + (bullPressureFalling ? 18.0 : 0.0) + (basisSlope <= 0 ? 14.0 : 0.0) + (close < open ? 8.0 : 0.0)
else if monitorSide == -1
    failureRisk := (bearBasisThreat ? 36.0 : 0.0) + (bearLostOuterLane ? 24.0 : 0.0) + (bearPressureFalling ? 18.0 : 0.0) + (basisSlope >= 0 ? 14.0 : 0.0) + (close > open ? 8.0 : 0.0)
failureRisk := f_clamp(failureRisk, 0.0, 100.0)

walkText = f_walk_state_text(walkSide, walkRecently, memorySide, walkScore)
walkColor = walkSide == 1 ? bullColor : walkSide == -1 ? bearColor : walkRecently ? neutralColor : walkScore >= 45.0 ? accentColor : panelValueCol
actionText = f_action_text(walkSide, walkRecently, pullbackScore, failureRisk, walkScore)

// -------------------------------------------------
// Walk-Continuation-Rate Proof
// On a new band walk, a win is recorded when price reaches one risk-distance in
// the walk direction (a balanced one-risk target) before closing back across the
// basis it started from. Samples that resolve neither inside the proof window are
// left unresolved and uncounted. Updated only on confirmed bars so the statistic
// does not repaint.
// -------------------------------------------------
var int   proofWins    = 0
var int   proofTotal   = 0
var bool  proofPending = false
var int   proofDir     = 0
var float proofTarget  = na
var float proofStop    = na
var int   proofStartBar = na

bool proofArm = newBullWalk or newBearWalk
int  armDir   = newBullWalk ? 1 : -1

if barstate.isconfirmed
    if proofPending
        favHit  = proofDir == 1 ? high >= proofTarget : low <= proofTarget
        stopHit = proofDir == 1 ? close < proofStop : close > proofStop
        expiredProof = bar_index - proofStartBar >= proofWindowBars
        if favHit and stopHit
            proofTotal += 1
            proofPending := false
        else if favHit
            proofWins += 1
            proofTotal += 1
            proofPending := false
        else if stopHit
            proofTotal += 1
            proofPending := false
        else if expiredProof
            proofPending := false
    if proofArm and not proofPending
        riskDist = math.max(math.abs(close - basis), safeAtr * 0.10)
        proofDir := armDir
        proofTarget := close + armDir * riskDist
        proofStop := basis
        proofStartBar := bar_index
        proofPending := true

float proofRate = proofTotal > 0 ? proofWins / proofTotal * 100.0 : na

// -------------------------------------------------
// Visuals
// -------------------------------------------------
upperPlot = plot(showBands ? upperBand : na, "Upper Band", color = color.new(accentColor, 45), linewidth = 1)
basisPlot = plot(showBands ? basis : na, "Basis", color = color.new(panelLabelCol, 35), linewidth = 1)
lowerPlot = plot(showBands ? lowerBand : na, "Lower Band", color = color.new(accentColor, 45), linewidth = 1)

walkFillColor = showWalkHighlight and walkSide == 1 ? color.new(bullColor, 93) : showWalkHighlight and walkSide == -1 ? color.new(bearColor, 93) : na
fill(upperPlot, lowerPlot, color = walkFillColor, title = "Band Walk Highlight")
plot(showWalkTrack and walkSide == 1 ? upperBand : na, "Upper Walk Track", color = color.new(bullColor, 0), linewidth = 2, style = plot.style_linebr)
plot(showWalkTrack and walkSide == -1 ? lowerBand : na, "Lower Walk Track", color = color.new(bearColor, 0), linewidth = 2, style = plot.style_linebr)

// -------------------------------------------------
// Pullback Zones
// -------------------------------------------------
var array<box> pocketBoxes = array.new_box()
var array<label> pocketBadges = array.new_label()
var box activePocket = na
var label activePocketBadge = na
var int activePocketSide = 0
var int lastPocketBar = -10000

baseProjection = adaptiveProjection and timeframe.isintraday == false ? math.max(8, int(math.round(zoneForwardBars * 0.70))) : zoneForwardBars
projectionBars = math.max(5, baseProjection)
pocketReady = showPullbackZones and walkSide != 0
zoneCooldownBars = math.max(8, int(math.round(projectionBars * 0.50)))
newPocket = pocketReady and bar_index - lastPocketBar >= zoneCooldownBars and (na(activePocket) or activePocketSide != walkSide or newBullWalk or newBearWalk)

if newPocket
    float pocketTop = walkSide == 1 ? bullPocketTop : bearPocketTop
    float pocketBottom = walkSide == 1 ? bullPocketBottom : bearPocketBottom
    color pocketColor = walkSide == 1 ? bullColor : bearColor
    int pocketRight = bar_index + projectionBars
    int badgeX = bar_index + int(math.round(projectionBars * zoneBadgeAnchor))
    string badgeText = (walkSide == 1 ? "UPPER POCKET" : "LOWER POCKET") + " | Q" + str.tostring(math.round(pullbackScore)) + " " + f_grade(pullbackScore)
    if not na(activePocket)
        int priorLeft = box.get_left(activePocket)
        int priorRight = math.max(priorLeft + 1, bar_index - 1)
        box.set_right(activePocket, priorRight)
        box.set_bgcolor(activePocket, color.new(activePocketSide == 1 ? bullColor : bearColor, 96))
        box.set_border_color(activePocket, color.new(activePocketSide == 1 ? bullColor : bearColor, 72))
    if not na(activePocketBadge)
        int priorBadgeLeft = not na(activePocket) ? box.get_left(activePocket) : bar_index - 1
        int priorBadgeRight = not na(activePocket) ? box.get_right(activePocket) : bar_index
        label.set_x(activePocketBadge, int(math.round((priorBadgeLeft + priorBadgeRight) * 0.5)))
        label.set_color(activePocketBadge, color.new(pocketBadgeMutedBg, 18))
        label.set_textcolor(activePocketBadge, f_text_on(pocketBadgeMutedBg))
    activePocket := box.new(left = bar_index, top = pocketTop, right = pocketRight, bottom = pocketBottom, xloc = xloc.bar_index, border_color = color.new(pocketColor, 42), bgcolor = color.new(pocketColor, zoneOpacity), border_width = 1)
    activePocketSide := walkSide
    lastPocketBar := bar_index
    array.push(pocketBoxes, activePocket)
    f_trim_boxes(pocketBoxes, maxVisibleZones)
    if array.size(pocketBoxes) > 1
        for i = 0 to array.size(pocketBoxes) - 2
            box oldPocket = array.get(pocketBoxes, i)
            if not na(oldPocket)
                box.set_bgcolor(oldPocket, color.new(accentColor, 97))
                box.set_border_color(oldPocket, color.new(accentColor, 80))
    if array.size(pocketBadges) > 0
        for i = 0 to array.size(pocketBadges) - 1
            label oldBadge = array.get(pocketBadges, i)
            if not na(oldBadge)
                label.set_color(oldBadge, color.new(pocketBadgeMutedBg, 18))
                label.set_textcolor(oldBadge, f_text_on(pocketBadgeMutedBg))
    if showPocketBadges
        color badgeBg = f_pocket_badge_bg(pullbackScore, true)
        activePocketBadge := label.new(badgeX, (pocketTop + pocketBottom) * 0.5, badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(badgeBg, 8), textcolor = f_text_on(badgeBg), size = f_badge_size(labelSizeInput), textalign = text.align_center)
        array.push(pocketBadges, activePocketBadge)
        f_trim_labels(pocketBadges, maxVisibleZones)

if showPullbackZones and not na(activePocket) and activePocketSide == monitorSide and failureRisk < failureThreshold
    float liveTop = activePocketSide == 1 ? bullPocketTop : bearPocketTop
    float liveBottom = activePocketSide == 1 ? bullPocketBottom : bearPocketBottom
    int liveRight = bar_index + projectionBars
    int liveBadgeX = bar_index + int(math.round(projectionBars * zoneBadgeAnchor))
    string liveBadgeText = (activePocketSide == 1 ? "UPPER POCKET" : "LOWER POCKET") + " | Q" + str.tostring(math.round(pullbackScore)) + " " + f_grade(pullbackScore)
    box.set_right(activePocket, liveRight)
    box.set_top(activePocket, liveTop)
    box.set_bottom(activePocket, liveBottom)
    box.set_bgcolor(activePocket, color.new(activePocketSide == 1 ? bullColor : bearColor, zoneOpacity))
    box.set_border_color(activePocket, color.new(activePocketSide == 1 ? bullColor : bearColor, 42))
    if showPocketBadges and not na(activePocketBadge)
        f_set_badge(activePocketBadge, liveBadgeX, (liveTop + liveBottom) * 0.5, liveBadgeText, color.new(f_pocket_badge_bg(pullbackScore, true), 8), labelSizeInput)
else if failureRisk >= failureThreshold
    if not na(activePocket)
        int failedLeft = box.get_left(activePocket)
        int failedRight = math.max(failedLeft + 1, bar_index)
        box.set_right(activePocket, failedRight)
        box.set_bgcolor(activePocket, color.new(activePocketSide == 1 ? bullColor : bearColor, 96))
        box.set_border_color(activePocket, color.new(neutralColor, 58))
    if not na(activePocketBadge)
        int failedBadgeLeft = not na(activePocket) ? box.get_left(activePocket) : bar_index - 1
        int failedBadgeRight = not na(activePocket) ? box.get_right(activePocket) : bar_index
        label.set_x(activePocketBadge, int(math.round((failedBadgeLeft + failedBadgeRight) * 0.5)))
        label.set_color(activePocketBadge, color.new(neutralColor, 8))
        label.set_textcolor(activePocketBadge, f_text_on(neutralColor))
    activePocket := na
    activePocketBadge := na
    activePocketSide := 0

if not showPocketBadges and not na(activePocketBadge)
    label.set_text(activePocketBadge, "")

// -------------------------------------------------
// Labels
// -------------------------------------------------
var array<label> eventLabels = array.new_label()
var int lastEventLabelBar = -10000
labelSize = f_size(labelSizeInput)
failureCandidate = monitorSide != 0 and failureRisk >= failureThreshold
failureWarning = failureCandidate and failureCandidate[1] != true
canPrintLabel = showEventLabels and bar_index - lastEventLabelBar >= labelCooldown
labelHighY = ta.highest(high, labelClearBars) + safeAtr * labelOffsetAtr
labelLowY = ta.lowest(low, labelClearBars) - safeAtr * labelOffsetAtr

if canPrintLabel and failureWarning
    bool upperFailure = monitorSide == 1
    string failureText = upperFailure ? "Upper Fail" : "Lower Fail"
    float failureY = upperFailure ? labelHighY : labelLowY
    failureStyle = upperFailure ? label.style_label_down : label.style_label_up
    label failureLabel = label.new(bar_index, failureY, failureText, yloc = yloc.price, style = failureStyle, color = color.new(neutralColor, 0), textcolor = f_text_on(neutralColor), size = labelSize)
    array.push(eventLabels, failureLabel)
    lastEventLabelBar := bar_index
    f_trim_labels(eventLabels, maxVisibleLabels)
else if canPrintLabel and newBullWalk
    label bullWalkLabel = label.new(bar_index, labelLowY, "Upper Walk", yloc = yloc.price, style = label.style_label_up, color = color.new(bullColor, 0), textcolor = f_text_on(bullColor), size = labelSize)
    array.push(eventLabels, bullWalkLabel)
    lastEventLabelBar := bar_index
    f_trim_labels(eventLabels, maxVisibleLabels)
else if canPrintLabel and newBearWalk
    label bearWalkLabel = label.new(bar_index, labelHighY, "Lower Walk", yloc = yloc.price, style = label.style_label_down, color = color.new(bearColor, 0), textcolor = f_text_on(bearColor), size = labelSize)
    array.push(eventLabels, bearWalkLabel)
    lastEventLabelBar := bar_index
    f_trim_labels(eventLabels, maxVisibleLabels)
else if canPrintLabel and bullPocketHoldEvent and not newBullWalk and (not showPullbackZones or not showPocketBadges)
    label bullPullbackLabel = label.new(bar_index, labelLowY, "Pocket Hold", yloc = yloc.price, style = label.style_label_up, color = color.new(bullColor, 10), textcolor = f_text_on(bullColor), size = labelSize)
    array.push(eventLabels, bullPullbackLabel)
    lastEventLabelBar := bar_index
    f_trim_labels(eventLabels, maxVisibleLabels)
else if canPrintLabel and bearPocketHoldEvent and not newBearWalk and (not showPullbackZones or not showPocketBadges)
    label bearPullbackLabel = label.new(bar_index, labelHighY, "Pocket Hold", yloc = yloc.price, style = label.style_label_down, color = color.new(bearColor, 10), textcolor = f_text_on(bearColor), size = labelSize)
    array.push(eventLabels, bearPullbackLabel)
    lastEventLabelBar := bar_index
    f_trim_labels(eventLabels, maxVisibleLabels)

// -------------------------------------------------
// Panel
// -------------------------------------------------
color panelBodyBg = f_theme_bg(panelTheme)
color panelFrame = f_theme_border(panelTheme)
var table infoPanel = table.new(f_position(panelLocation), 2, 7, bgcolor = panelBodyBg, border_width = 1, frame_width = 1, border_color = panelFrame, frame_color = panelFrame)
panelTextSize = f_size(panelFontInput)
proofText = proofTotal > 0 ? str.tostring(math.round(nz(proofRate, 0.0))) + "% (" + str.tostring(proofTotal) + ")" : "Building"
proofCol = na(proofRate) ? f_theme_value(panelTheme) : proofRate >= 55 ? bullColor : proofRate >= 45 ? neutralColor : bearColor

if barstate.islast
    table.set_position(infoPanel, f_position(panelLocation))
    table.clear(infoPanel, 0, 0, 1, 6)
    if showPanel
        table.merge_cells(infoPanel, 0, 0, 1, 0)
        table.cell(infoPanel, 0, 0, "AG Pro Bollinger Walk Quality", text_color = headerText, bgcolor = headerBg, text_size = panelTextSize, text_halign = text.align_center)
        f_panel_row(infoPanel, 1, "Walk Side", walkText, walkColor, panelTheme, panelFontInput)
        f_panel_row(infoPanel, 2, "Band Pressure", pressureText, walkColor, panelTheme, panelFontInput)
        f_panel_row(infoPanel, 3, "Pullback Quality", pullbackText, pullbackScore >= 75.0 ? bullColor : pullbackScore >= 55.0 ? neutralColor : f_theme_value(panelTheme), panelTheme, panelFontInput)
        f_panel_row(infoPanel, 4, "Failure Risk", f_risk_text(failureRisk), f_risk_color(failureRisk), panelTheme, panelFontInput)
        f_panel_row(infoPanel, 5, "Walk Continuation Rate", proofText, proofCol, panelTheme, panelFontInput)
        f_panel_row(infoPanel, 6, "Action", actionText, failureRisk >= failureThreshold ? bearColor : walkColor, panelTheme, panelFontInput)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(newBullWalk, "Upper Band Walk", "Bollinger Walk Quality: upper-band walk pressure has become active.")
alertcondition(newBearWalk, "Lower Band Walk", "Bollinger Walk Quality: lower-band walk pressure has become active.")
alertcondition(bullPocketHold, "Bullish Pullback Hold", "Bollinger Walk Quality: upper-walk pullback pocket is holding.")
alertcondition(bearPocketHold, "Bearish Pullback Hold", "Bollinger Walk Quality: lower-walk pullback pocket is holding.")
alertcondition(failureWarning, "Band Walk Failure Warning", "Bollinger Walk Quality: active band walk is showing elevated failure risk.")
````

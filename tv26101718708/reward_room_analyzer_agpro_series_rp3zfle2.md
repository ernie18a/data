# Reward Room Analyzer [AGPro Series]

- url: https://www.tradingview.com/script/RP3zFle2-Reward-Room-Analyzer-AGPro-Series/
- type: indicator
- pine_id: PUB;88b327911d6045e8b7fca49c801a88a8
- version: 7.0

## Description

Reward Room Analyzer [AGPro Series]

🧠 Core Idea

Does the chart offer enough clean reward room before the next major obstacle?

📌 Overview / What it does

Reward Room Analyzer [AGPro Series] is a chart-overlay planning tool designed to evaluate whether the current price area has enough practical space before the next meaningful obstacle.
Instead of projecting a take-profit ladder or calculating position size, the script studies the distance from current price to the nearest target-side obstacle, the opposite invalidation reference, room-to-risk ratio, trend support, clean-air structure, and volatility fit. These inputs are converted into a 0-100 Reward Room Score with a clear state such as Open Room, Watch Room, Thin Room, Blocked Path, Risk Heavy, or No Room.
The script produces a forward reward room corridor, nearest obstacle rail, invalidation reference rail, compact chart labels, alert conditions, and a clean AGPro planning panel. It does not predict price movement, automate execution, or promise that any target will be reached.

🎯 Purpose & Design Philosophy

This script was built to solve a common planning problem: a setup can look attractive, but the path ahead may already be blocked by nearby structure, poor room-to-risk, or excessive invalidation distance.
Reward Room Analyzer helps traders review the quality of the space ahead before treating a setup as actionable. It supports a planner mindset: check the available room, identify the obstacle, compare room against risk, and then decide whether the chart deserves more attention.
It is designed for traders who care about trade planning, target path quality, risk awareness, and cleaner decision structure rather than another generic signal marker.

⚡ Why This Script Is Different

Most tools focus on drawing take-profit levels, R-multiple ladders, Fibonacci extensions, or basic risk/reward boxes.
This script does NOT build a TP ladder, position-size calculator, profit tracker, or entry signal system.
Instead, it asks a narrower decision question: is there enough clean reward room before the next obstacle, or is the path already too thin, blocked, or risk-heavy?

⚙️ Methodology

1. Context Detection
The script selects the active target side using Auto Side, Long Room, or Short Room. Auto Side weighs trend support and available room.
2. Reference Mapping
It maps confirmed obstacle pivots, the nearest target-side rail, the opposite invalidation reference, and ATR-normalized reward room.
3. Reaction Evaluation
It scores the room using distance to obstacle, room-to-risk ratio, clean-air structure, trend agreement, risk distance, and volatility fit.
4. Visual Output
It displays the active reward corridor, centered corridor label, obstacle/invalidation rails, compact labels, alerts, and an AGPro panel.

🗺️ How to Read the Chart

Reward Room Corridor = the forward space between current price and the nearest target-side obstacle.
Nearest Obstacle Rail = the first meaningful structural barrier in the selected target direction.
Invalidation Reference = the opposite-side reference used to estimate risk distance.
Labels = compact state markers showing the current reward-room condition and score.
Colors = teal and indigo suggest stronger room quality, amber suggests caution, and pink/red suggests weak or blocked room.
Panel = summarizes reward score, reward room, obstacle, room-to-risk, target side, and next action.

🚦 Signals & States

• Open Room → reward room is wide enough, room-to-risk is acceptable, and risk is not excessive.
• Watch Room → context is acceptable but not strong enough for the open-room state.
• Thin Room → the nearest obstacle is too close.
• Blocked Path → room-to-risk is weak relative to the invalidation reference.
• Risk Heavy → invalidation distance is too large compared with the available room.
• No Room → conditions are not strong enough for planning attention.

🔔 Alerts Logic

• Open Reward Room → triggers when the script enters the Open Room state.
• Watch Reward Room → triggers when watchable room appears without reaching Open Room.
• Blocked Reward Path → triggers when room-to-risk becomes structurally blocked.
• Thin Reward Room → triggers when the nearest obstacle is too close.
• Risk Heavy Room → triggers when invalidation distance is heavy relative to room.
Alerts are attention markers. They are not trade instructions.

🧩 Confluence Logic

Reward room quality improves when the target-side distance, room-to-risk ratio, clean-air structure, trend agreement, balanced risk distance, and stable volatility align.
The strongest read appears when the corridor is visibly open and the panel confirms sufficient room with a strong score.

## Source Code

````pine
// -------------------------------------------------
// Reward Room Analyzer [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.6
//
// Reward Room Analyzer is a chart-first reward-room planner built to evaluate
// whether price has enough clean space before the next meaningful obstacle. It
// maps the forward reward corridor, nearest obstacle rail, opposite invalidation
// reference, room-to-risk ratio, trend support, and volatility fit into a 0-100
// Reward Room Score with a clear next-action state, plus a confirmation-anchored
// proof layer (Follow, Hold, React, Flip rates) that shows how often mapped
// reward rooms were captured before invalidation on the current symbol.
// -------------------------------------------------

//@version=6
indicator("Reward Room Analyzer [AGPro Series]",
     shorttitle       = "AG Pro RRA",
     overlay          = true,
     max_labels_count = 120,
     max_lines_count  = 30,
     max_boxes_count  = 20)

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
ttPreset = "Selects the operating profile. Balanced Reward is the publication default. Cleaner Swing reduces visual density. Active Intraday keeps the planner more responsive. Custom uses the raw input values."
ttSide = "Selects the side used for reward-room analysis. Auto Side weighs trend support and available room; fixed modes keep the planner focused on one direction."
ttLookback = "Defines the recent market window used to locate confirmed obstacle rails, clean-air structure, and opposite invalidation context."
ttPivot = "Controls how strict the confirmed swing logic is when collecting obstacle rails. Higher values produce fewer but stronger obstacles."
ttTrend = "EMA length used to evaluate whether the chosen reward side agrees with broader directional support."
ttAtr = "ATR length used to normalize reward room, obstacle distance, invalidation distance, and volatility fit."
ttConfirm = "Close Confirmed waits for closed bars before printing new event labels and alerts. Live Updating can react intrabar."
ttOpen = "Minimum 0-100 score required for the Open Room state."
ttWatch = "Minimum 0-100 score required before the script treats the room as watchable instead of blocked."
ttMinRoom = "Minimum ATR-normalized distance required between current price and the nearest obstacle rail."
ttRr = "Minimum room-to-risk ratio required before reward room can be considered efficient."
ttMaxRisk = "If the opposite invalidation reference is farther than this ATR value, the score is capped because risk is too heavy for a clean room read."
ttFallback = "Fallback projection used when no confirmed obstacle rail exists beyond current price."
ttInvalid = "Small ATR buffer placed beyond the opposite reference to estimate invalidation context."
ttCorridor = "Displays the active reward room corridor as a forward box with a centered score and state badge."
ttRails = "Displays the target-side obstacle rail and opposite invalidation rail used by the planner."
ttRailLabels = "Shows compact right-side labels for the obstacle and invalidation rails. Disable this if the price scale becomes crowded."
ttTagOffset = "Horizontal offset for right-side rail tags. Increase it if tags sit too close to the projected corridor."
ttTrendBasis = "Shows the EMA trend basis used by the model."
ttLabels = "Displays compact state labels when reward-room context changes or remains important after the cooldown."
ttLabelMode = "Compact keeps the chart cleaner by using short state tags. Detailed prints the full state and score on labels."
ttCooldown = "Minimum bars between event labels. This keeps label density visible but controlled."
ttMaxLabels = "Limits how many recent reward-room labels remain visible on the chart."
ttForward = "Controls how far the active corridor and rails extend to the right."
ttFont = "Controls all chart label sizes produced by the script."
ttPanel = "Shows or hides the AG Pro information panel. The default is visible for publication-ready chart context."
ttZoneContrast = "Uses solid label boxes for corridor and rail labels so text remains readable on light chart backgrounds."
ttShowProof = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across rolling evaluation windows in the active reward direction on the current symbol and timeframe. Follow means the mapped obstacle was reached before invalidation. These are historical outcome rates, not predictions."
ttProofHorizon = "Number of bars each rolling reward-room window is tracked forward to measure whether the mapped obstacle was reached before the invalidation reference was breached."
ttReactBars = "Number of bars after a window opens used to detect an immediate favorable reaction toward the obstacle."
ttReactProgress = "Minimum favorable progress toward the obstacle, within the reaction window, required to count as an early React."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Reward Room Engine"
enginePreset = input.string("Balanced Reward", "Engine Preset", options = ["Balanced Reward", "Cleaner Swing", "Active Intraday", "Custom"], group = groupEngine, tooltip = ttPreset)
targetSideMode = input.string("Auto Side", "Target Side", options = ["Auto Side", "Long Room", "Short Room"], group = groupEngine, tooltip = ttSide)
roomLookback = input.int(120, "Reward Room Lookback", minval = 50, maxval = 400, group = groupEngine, tooltip = ttLookback)
obstaclePivotLength = input.int(6, "Obstacle Pivot Length", minval = 2, maxval = 24, group = groupEngine, tooltip = ttPivot)
trendLength = input.int(55, "Trend Support Length", minval = 10, maxval = 200, group = groupEngine, tooltip = ttTrend)
atrLength = input.int(14, "ATR Length", minval = 5, maxval = 50, group = groupEngine, tooltip = ttAtr)
confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = ttConfirm)

groupQuality = "Quality Model"
minOpenScore = input.int(70, "Minimum Open Room Score", minval = 45, maxval = 95, group = groupQuality, tooltip = ttOpen)
minWatchScore = input.int(55, "Minimum Watch Score", minval = 30, maxval = 90, group = groupQuality, tooltip = ttWatch)
minimumRoomAtr = input.float(1.40, "Minimum Clean Room ATR", minval = 0.4, maxval = 6.0, step = 0.05, group = groupQuality, tooltip = ttMinRoom)
minimumRoomToRisk = input.float(1.15, "Minimum Room-to-Risk", minval = 0.3, maxval = 5.0, step = 0.05, group = groupQuality, tooltip = ttRr)
maxRiskAtr = input.float(3.25, "Maximum Invalidation Distance ATR", minval = 0.8, maxval = 8.0, step = 0.05, group = groupQuality, tooltip = ttMaxRisk)
fallbackProjectionAtr = input.float(2.75, "Fallback Open Room ATR", minval = 0.8, maxval = 8.0, step = 0.05, group = groupQuality, tooltip = ttFallback)
invalidationBufferAtr = input.float(0.18, "Invalidation Buffer ATR", minval = 0.0, maxval = 1.2, step = 0.02, group = groupQuality, tooltip = ttInvalid)

groupVisual = "Visuals"
showRewardRoom = input.bool(true, "Show Reward Room Corridor", group = groupVisual, tooltip = ttCorridor)
showObstacleRails = input.bool(true, "Show Obstacle Rails", group = groupVisual, tooltip = ttRails)
showRailLabels = input.bool(true, "Show Rail Labels", group = groupVisual, tooltip = ttRailLabels)
rightTagOffsetBars = input.int(6, "Right Tag Offset Bars", minval = 1, maxval = 40, group = groupVisual, tooltip = ttTagOffset)
showTrendBasis = input.bool(false, "Show Trend Basis", group = groupVisual, tooltip = ttTrendBasis)
showLabels = input.bool(true, "Show Event Labels", group = groupVisual, tooltip = ttLabels)
labelTextMode = input.string("Compact", "Label Text Mode", options = ["Compact", "Detailed"], group = groupVisual, tooltip = ttLabelMode)
labelCooldown = input.int(20, "Label Cooldown Bars", minval = 3, maxval = 80, group = groupVisual, tooltip = ttCooldown)
maxVisibleLabels = input.int(7, "Max Visible Labels", minval = 2, maxval = 20, group = groupVisual, tooltip = ttMaxLabels)
renderForwardBars = input.int(34, "Forward Render Bars", minval = 10, maxval = 140, group = groupVisual, tooltip = ttForward)
labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual, tooltip = ttFont)
useSolidZoneLabels = input.bool(true, "Use Solid Zone Labels", group = groupVisual, tooltip = ttZoneContrast)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttPanel)
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = "Moves the panel to the preferred chart location.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = "Controls the panel color theme while preserving the AG Pro blue header standard.")
panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = "Controls panel text size.")

groupProof = "Proof"
showProof = input.bool(true, "Show Proof Layer", group = groupProof, tooltip = ttShowProof)
proofHorizonBars = input.int(30, "Proof Horizon Bars", minval = 5, maxval = 240, group = groupProof, tooltip = ttProofHorizon)
reactBars = input.int(4, "Reaction Window Bars", minval = 1, maxval = 60, group = groupProof, tooltip = ttReactBars)
reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = groupProof, tooltip = ttReactProgress)

groupAlerts = "Alerts"
alertOpenWatch = input.bool(true, "Alert on Open and Watch Room", group = groupAlerts,
     tooltip = "Enables alerts when the planner enters open or watchable reward-room context.")
alertRoomWarnings = input.bool(true, "Alert on Thin, Blocked, or Risk Heavy Room", group = groupAlerts,
     tooltip = "Enables alerts when reward room becomes thin, blocked by room-to-risk, or risk heavy.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_text_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(string posText) =>
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

f_score_color(int score, int openLevel, int watchLevel) =>
    score >= 82 ? bullColor : score >= openLevel ? accentColor : score >= watchLevel ? neutralColor : bearColor

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(float value) =>
    value >= 55 ? bullColor : value >= 40 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30 ? bullColor : value <= 55 ? neutralColor : bearColor

f_zone_label_color(string stateValue, color fallbackColor) =>
    switch stateValue
        "OPEN ROOM" => color.rgb(13, 148, 136)
        "WATCH ROOM" => color.rgb(79, 70, 229)
        "BLOCKED PATH" => color.rgb(190, 24, 93)
        "RISK HEAVY" => color.rgb(185, 28, 28)
        "THIN ROOM" => color.rgb(180, 83, 9)
        => fallbackColor

f_grade(int score) =>
    score >= 84 ? "A" : score >= 73 ? "B" : score >= 62 ? "C" : score >= 45 ? "D" : "E"

f_fmt_1(float value) =>
    na(value) ? "-" : str.tostring(value, "#.##")

f_fmt_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_state_code(string stateValue) =>
    switch stateValue
        "OPEN ROOM" => "Open"
        "WATCH ROOM" => "Watch"
        "BLOCKED PATH" => "Blocked"
        "RISK HEAVY" => "Risk"
        "THIN ROOM" => "Thin"
        => "No Room"

f_titlecase(string stateValue) =>
    switch stateValue
        "OPEN ROOM" => "Open Room"
        "WATCH ROOM" => "Watch Room"
        "BLOCKED PATH" => "Blocked Path"
        "RISK HEAVY" => "Risk Heavy"
        "THIN ROOM" => "Thin Room"
        "NO ROOM" => "No Room"
        => stateValue

f_panel_bg(bool isLight, bool alt) =>
    isLight ? (alt ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)) : (alt ? color.rgb(19, 29, 48) : panelBg)

f_panel_border(bool isLight) =>
    isLight ? color.rgb(203, 213, 225) : panelBorder

f_panel_label(bool isLight) =>
    isLight ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(bool isLight) =>
    isLight ? color.rgb(15, 23, 42) : panelValueCol

f_best_view_text() =>
    timeframe.isintraday ? "1H / 4H / 1D" : timeframe.isdaily ? "Daily Chart" : "4H / 1D"

f_delete_label(label item) =>
    if not na(item)
        label.delete(item)

// -------------------------------------------------
// Presets
// -------------------------------------------------
cleanerPreset = enginePreset == "Cleaner Swing"
activePreset = enginePreset == "Active Intraday"

usedOpenScoreRaw = cleanerPreset ? math.max(minOpenScore, 74) : activePreset ? math.max(minOpenScore - 4, 45) : minOpenScore
usedWatchScoreRaw = cleanerPreset ? math.max(minWatchScore, 58) : activePreset ? math.max(minWatchScore - 4, 30) : minWatchScore
usedOpenScore = math.max(usedOpenScoreRaw, usedWatchScoreRaw + 1)
usedWatchScore = math.min(usedWatchScoreRaw, usedOpenScore - 1)

usedLabelCooldown = cleanerPreset ? math.max(labelCooldown, 28) : activePreset ? math.min(labelCooldown, 14) : labelCooldown
usedMaxLabels = cleanerPreset ? math.min(maxVisibleLabels, 6) : activePreset ? math.min(maxVisibleLabels, 9) : maxVisibleLabels
usedForwardBars = cleanerPreset ? math.max(renderForwardBars, 38) : activePreset ? math.min(renderForwardBars, 26) : renderForwardBars
effectiveReactBars = math.min(reactBars, math.max(proofHorizonBars - 1, 1))

// -------------------------------------------------
// Core Reward Room Model
// -------------------------------------------------
confirmedBar = confirmationMode == "Close Confirmed" ? barstate.isconfirmed : true
atr = math.max(nz(ta.atr(atrLength), syminfo.mintick), syminfo.mintick)
trendBasis = ta.ema(close, trendLength)
trendSlope = trendBasis - nz(trendBasis[5], trendBasis)

ph = ta.pivothigh(high, obstaclePivotLength, obstaclePivotLength)
pl = ta.pivotlow(low, obstaclePivotLength, obstaclePivotLength)

var array<float> upperObstacles = array.new_float()
var array<int> upperObstacleBars = array.new_int()
var array<float> lowerObstacles = array.new_float()
var array<int> lowerObstacleBars = array.new_int()

if not na(ph)
    array.push(upperObstacles, ph)
    array.push(upperObstacleBars, bar_index - obstaclePivotLength)

if not na(pl)
    array.push(lowerObstacles, pl)
    array.push(lowerObstacleBars, bar_index - obstaclePivotLength)

// Keep pivot memory aligned with the selected market window and cap storage.
while array.size(upperObstacleBars) > 0 and bar_index - array.get(upperObstacleBars, 0) > roomLookback
    array.shift(upperObstacleBars)
    array.shift(upperObstacles)

while array.size(lowerObstacleBars) > 0 and bar_index - array.get(lowerObstacleBars, 0) > roomLookback
    array.shift(lowerObstacleBars)
    array.shift(lowerObstacles)

while array.size(upperObstacles) > 48
    array.shift(upperObstacles)
    array.shift(upperObstacleBars)

while array.size(lowerObstacles) > 48
    array.shift(lowerObstacles)
    array.shift(lowerObstacleBars)

pastHigh = nz(ta.highest(high[1], roomLookback), high)
pastLow = nz(ta.lowest(low[1], roomLookback), low)

float nearestAbove = pastHigh > close ? pastHigh : na
float nearestBelow = pastLow < close ? pastLow : na
int aboveObstacleCount = 0
int belowObstacleCount = 0

if array.size(upperObstacles) > 0
    for i = 0 to array.size(upperObstacles) - 1
        level = array.get(upperObstacles, i)
        if level > close
            aboveObstacleCount += 1
            if na(nearestAbove) or level < nearestAbove
                nearestAbove := level

if array.size(lowerObstacles) > 0
    for i = 0 to array.size(lowerObstacles) - 1
        level = array.get(lowerObstacles, i)
        if level < close
            belowObstacleCount += 1
            if na(nearestBelow) or level > nearestBelow
                nearestBelow := level

upperRail = na(nearestAbove) ? close + atr * fallbackProjectionAtr : nearestAbove
lowerRail = na(nearestBelow) ? close - atr * fallbackProjectionAtr : nearestBelow
upperRoomAtr = math.max((upperRail - close) / atr, 0.0)
lowerRoomAtr = math.max((close - lowerRail) / atr, 0.0)

trendLong = close >= trendBasis
roomPrefersLong = upperRoomAtr >= lowerRoomAtr * 0.88
roomPrefersShort = lowerRoomAtr > upperRoomAtr * 1.12
autoLongSide = roomPrefersShort and not trendLong ? false : roomPrefersLong and trendLong ? true : upperRoomAtr >= lowerRoomAtr
longSide = targetSideMode == "Long Room" ? true : targetSideMode == "Short Room" ? false : autoLongSide

targetRail = longSide ? upperRail : lowerRail
oppositeRail = longSide ? lowerRail : upperRail
targetRoomAtr = longSide ? upperRoomAtr : lowerRoomAtr
obstacleCount = longSide ? aboveObstacleCount : belowObstacleCount
invalidationLevel = longSide ? oppositeRail - atr * invalidationBufferAtr : oppositeRail + atr * invalidationBufferAtr
riskDistanceAtrRaw = longSide ? (close - invalidationLevel) / atr : (invalidationLevel - close) / atr
riskDistanceAtr = math.max(riskDistanceAtrRaw, 0.0)
roomToRisk = riskDistanceAtr > 0.0 ? targetRoomAtr / riskDistanceAtr : 0.0

trendAligned = longSide ? close >= trendBasis : close <= trendBasis
slopeAligned = longSide ? trendSlope >= 0 : trendSlope <= 0
trendComponent = trendAligned and slopeAligned ? 100.0 : trendAligned ? 76.0 : slopeAligned ? 60.0 : 28.0

distanceComponent = f_clamp(targetRoomAtr / minimumRoomAtr * 74.0, 0.0, 100.0)
distanceComponent := targetRoomAtr >= minimumRoomAtr * 1.75 ? math.min(100.0, distanceComponent + 18.0) : distanceComponent

ratioComponent = f_clamp(roomToRisk / minimumRoomToRisk * 76.0, 0.0, 100.0)
ratioComponent := roomToRisk >= minimumRoomToRisk * 1.60 ? math.min(100.0, ratioComponent + 16.0) : ratioComponent

cleanAirPenalty = math.min(obstacleCount * 4.0, 32.0)
cleanAirComponent = f_clamp(100.0 - cleanAirPenalty, 20.0, 100.0)
cleanAirComponent := targetRoomAtr < minimumRoomAtr ? math.min(cleanAirComponent, 48.0) : cleanAirComponent

riskComponent = f_clamp(100.0 - math.abs(riskDistanceAtr - 1.45) * 34.0, 0.0, 100.0)
riskComponent := riskDistanceAtr > maxRiskAtr ? math.min(riskComponent, 42.0) : riskComponent

atrBase = nz(ta.sma(atr, atrLength * 3), atr)
volRatio = atrBase == 0.0 ? 1.0 : atr / atrBase
volComponent = f_clamp(100.0 - math.abs(volRatio - 1.05) * 82.0, 0.0, 100.0)
volComponent := volRatio < 0.55 or volRatio > 2.00 ? math.min(volComponent, 44.0) : volComponent

thinRoom = targetRoomAtr < minimumRoomAtr
weakRatio = roomToRisk < minimumRoomToRisk
riskHeavy = riskDistanceAtr > maxRiskAtr

scoreRaw = distanceComponent * 0.30 + ratioComponent * 0.24 + cleanAirComponent * 0.18 + trendComponent * 0.16 + riskComponent * 0.07 + volComponent * 0.05
scoreCapped = thinRoom ? math.min(scoreRaw, usedWatchScore - 5.0) : weakRatio ? math.min(scoreRaw, usedOpenScore - 8.0) : riskHeavy ? math.min(scoreRaw, usedWatchScore - 2.0) : scoreRaw
rewardScore = int(math.round(f_clamp(scoreCapped, 0.0, 100.0)))
rewardGrade = f_grade(rewardScore)

openRoom = rewardScore >= usedOpenScore and not thinRoom and not weakRatio and not riskHeavy
watchRoom = rewardScore >= usedWatchScore and not thinRoom and not riskHeavy
stateText = openRoom ? "OPEN ROOM" : thinRoom ? "THIN ROOM" : riskHeavy ? "RISK HEAVY" : weakRatio ? "BLOCKED PATH" : watchRoom ? "WATCH ROOM" : "NO ROOM"
stateColor = f_score_color(rewardScore, usedOpenScore, usedWatchScore)
zoneLabelColor = f_zone_label_color(stateText, stateColor)
targetSideText = longSide ? "Long Room" : "Short Room"
actionText = openRoom ? "Evaluate Setup" : stateText == "WATCH ROOM" ? "Keep Watching" : stateText == "THIN ROOM" ? "Wait for Room" : stateText == "RISK HEAVY" ? "Risk Heavy" : stateText == "BLOCKED PATH" ? "Path Blocked" : "Stand Aside"
obstacleText = f_fmt_1(targetRoomAtr) + " ATR"
roomRiskText = f_fmt_1(roomToRisk) + " R/R"

// -------------------------------------------------
// Confirmation-anchored proof (reward-room capture)
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

int proofWarmup = trendLength + atrLength + obstaclePivotLength * 2 + 5
bool proofConfirmedBar = barstate.isconfirmed
int proofSideCode = longSide ? 1 : -1
bool proofEligible = (stateText == "OPEN ROOM" or stateText == "WATCH ROOM") and targetRoomAtr > 0.0 and riskDistanceAtr > 0.0

if proofConfirmedBar and bar_index > proofWarmup
    if pEvalActive
        int heldBars = bar_index - pEvalStart
        float targetDistance = math.max(math.abs(pEvalTarget - pEvalEntry), syminfo.mintick)
        float favorableExcursion = pEvalDir == 1 ? high - pEvalEntry : pEvalEntry - low
        bool targetTouched = heldBars >= 1 and favorableExcursion >= targetDistance
        bool stopTouched = pEvalDir == 1 ? low <= pEvalStop : high >= pEvalStop
        bool sideReplaced = proofSideCode != pEvalDir
        bool ambiguousNow = targetTouched and (stopTouched or sideReplaced)

        if heldBars >= 1 and heldBars <= effectiveReactBars and favorableExcursion >= targetDistance * reactProgressPct / 100.0
            pReacted := true
        if targetTouched and not stopTouched and not sideReplaced
            pFollowed := true

        bool horizonDone = heldBars >= proofHorizonBars
        bool resolveNow = ambiguousNow or targetTouched or stopTouched or sideReplaced or horizonDone

        if resolveNow
            if ambiguousNow
                proofAmbiguous := proofAmbiguous + 1
            else
                proofTotal := proofTotal + 1
                if pFollowed
                    proofFollow := proofFollow + 1
                if not stopTouched and not sideReplaced
                    proofHold := proofHold + 1
                if pReacted
                    proofReact := proofReact + 1
                if stopTouched or sideReplaced
                    proofFlip := proofFlip + 1

            pEvalActive := false
            pLastResolveBar := bar_index

    // Open sequential, non-overlapping samples only in qualified room states.
    bool proofRestartReady = na(pLastResolveBar) or bar_index > pLastResolveBar
    if proofEligible and not pEvalActive and proofRestartReady
        pEvalActive := true
        pEvalDir := proofSideCode
        pEvalEntry := close
        pEvalStop := invalidationLevel
        pEvalTarget := targetRail
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

// -------------------------------------------------
// Visual Rendering
// -------------------------------------------------
labelSz = f_text_size(labelFontSize)
panelSz = f_text_size(panelFontSize)
renderLeft = bar_index
renderRight = bar_index + usedForwardBars
targetTagX = renderRight + rightTagOffsetBars
invalidationTagX = targetTagX + 3
renderCenter = bar_index + int(math.round(usedForwardBars * 0.5))
roomTop = longSide ? targetRail : close
roomBottom = longSide ? close : targetRail
roomMid = (roomTop + roomBottom) * 0.5
roomBg = color.new(stateColor, openRoom ? 84 : watchRoom ? 88 : 91)
roomBorder = color.new(stateColor, openRoom ? 12 : 25)
roomLabelText = labelTextMode == "Detailed" ? "Reward Room\n" + str.tostring(rewardScore) + " " + rewardGrade + "\n" + f_state_code(stateText) : "RRA " + str.tostring(rewardScore) + " " + rewardGrade + "\n" + f_state_code(stateText)

var box rewardRoomBox = na
var label rewardRoomLabel = na
var line targetRailLine = na
var line invalidationRailLine = na
var label targetRailLabel = na
var label invalidationRailLabel = na

if barstate.islast
    if showRewardRoom
        if na(rewardRoomBox)
            rewardRoomBox := box.new(renderLeft, roomTop, renderRight, roomBottom, xloc = xloc.bar_index, bgcolor = roomBg, border_color = roomBorder, border_width = openRoom ? 2 : 1)
        else
            box.set_left(rewardRoomBox, renderLeft)
            box.set_right(rewardRoomBox, renderRight)
            box.set_top(rewardRoomBox, roomTop)
            box.set_bottom(rewardRoomBox, roomBottom)
            box.set_bgcolor(rewardRoomBox, roomBg)
            box.set_border_color(rewardRoomBox, roomBorder)
            box.set_border_width(rewardRoomBox, openRoom ? 2 : 1)

        if na(rewardRoomLabel)
            rewardRoomLabel := label.new(renderCenter, roomMid, roomLabelText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = headerText, color = color.new(useSolidZoneLabels ? zoneLabelColor : stateColor, useSolidZoneLabels ? 0 : 8), size = labelSz, textalign = text.align_center)
        else
            label.set_x(rewardRoomLabel, renderCenter)
            label.set_y(rewardRoomLabel, roomMid)
            label.set_text(rewardRoomLabel, roomLabelText)
            label.set_color(rewardRoomLabel, color.new(useSolidZoneLabels ? zoneLabelColor : stateColor, useSolidZoneLabels ? 0 : 8))
            label.set_textcolor(rewardRoomLabel, headerText)
            label.set_size(rewardRoomLabel, labelSz)
            label.set_textalign(rewardRoomLabel, text.align_center)
    else
        if not na(rewardRoomBox)
            box.delete(rewardRoomBox)
            rewardRoomBox := na
        f_delete_label(rewardRoomLabel)
        rewardRoomLabel := na

    if showObstacleRails
        targetRailColor = color.new(accentColor, 10)
        invalidationColor = color.new(dangerColor, 10)
        if na(targetRailLine)
            targetRailLine := line.new(renderLeft, targetRail, renderRight, targetRail, xloc = xloc.bar_index, color = targetRailColor, style = line.style_dotted, width = 1)
        else
            line.set_xy1(targetRailLine, renderLeft, targetRail)
            line.set_xy2(targetRailLine, renderRight, targetRail)
            line.set_color(targetRailLine, targetRailColor)

        if na(invalidationRailLine)
            invalidationRailLine := line.new(renderLeft, invalidationLevel, renderRight, invalidationLevel, xloc = xloc.bar_index, color = invalidationColor, style = line.style_dashed, width = 1)
        else
            line.set_xy1(invalidationRailLine, renderLeft, invalidationLevel)
            line.set_xy2(invalidationRailLine, renderRight, invalidationLevel)
            line.set_color(invalidationRailLine, invalidationColor)

        if showRailLabels
            targetText = "Obstacle\n" + f_fmt_price(targetRail)
            invalidationText = "Invalidation\n" + f_fmt_price(invalidationLevel)
            if na(targetRailLabel)
                targetRailLabel := label.new(targetTagX, targetRail, targetText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = headerText, color = color.new(accentColor, 0), size = labelSz)
            else
                label.set_x(targetRailLabel, targetTagX)
                label.set_y(targetRailLabel, targetRail)
                label.set_text(targetRailLabel, targetText)
                label.set_color(targetRailLabel, color.new(accentColor, 0))
                label.set_size(targetRailLabel, labelSz)
                label.set_textcolor(targetRailLabel, headerText)

            if na(invalidationRailLabel)
                invalidationRailLabel := label.new(invalidationTagX, invalidationLevel, invalidationText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = headerText, color = color.new(dangerColor, 0), size = labelSz)
            else
                label.set_x(invalidationRailLabel, invalidationTagX)
                label.set_y(invalidationRailLabel, invalidationLevel)
                label.set_text(invalidationRailLabel, invalidationText)
                label.set_color(invalidationRailLabel, color.new(dangerColor, 0))
                label.set_size(invalidationRailLabel, labelSz)
                label.set_textcolor(invalidationRailLabel, headerText)
        else
            f_delete_label(targetRailLabel)
            f_delete_label(invalidationRailLabel)
            targetRailLabel := na
            invalidationRailLabel := na
    else
        if not na(targetRailLine)
            line.delete(targetRailLine)
            targetRailLine := na
        if not na(invalidationRailLine)
            line.delete(invalidationRailLine)
            invalidationRailLine := na
        f_delete_label(targetRailLabel)
        f_delete_label(invalidationRailLabel)
        targetRailLabel := na
        invalidationRailLabel := na

plot(showTrendBasis ? trendBasis : na, "Trend Basis", color = color.new(accentColor, 15), linewidth = 2)

// -------------------------------------------------
// Event Labels
// -------------------------------------------------
var array<label> eventLabels = array.new_label()
var int lastLabelBar = na

barsFromLastLabel = na(lastLabelBar) ? 100000 : bar_index - lastLabelBar
stateChanged = bar_index > 0 and stateText != stateText[1]
scoreCrossedOpen = ta.crossover(rewardScore, usedOpenScore)
scoreLostOpen = ta.crossunder(rewardScore, usedOpenScore)
periodicImportant = rewardScore >= usedWatchScore and barsFromLastLabel >= usedLabelCooldown * 3
printEvent = showLabels and confirmedBar and barsFromLastLabel >= usedLabelCooldown and (stateChanged or scoreCrossedOpen or scoreLostOpen or periodicImportant)

if printEvent
    eventCode = f_state_code(stateText)
    eventText = labelTextMode == "Compact" ? eventCode + " " + str.tostring(rewardScore) : f_titlecase(stateText) + "\nScore " + str.tostring(rewardScore) + " " + rewardGrade
    labelY = longSide ? high + atr * 0.78 : low - atr * 0.78
    labelStyle = longSide ? label.style_label_down : label.style_label_up
    eventTip = f_titlecase(stateText) + "\nScore: " + str.tostring(rewardScore) + "\nTarget side: " + targetSideText + "\nObstacle: " + f_fmt_price(targetRail) + "\nReward room: " + obstacleText + "\nRoom-to-risk: " + roomRiskText + "\nAction: " + actionText
    eventLabel = label.new(bar_index, labelY, eventText, xloc = xloc.bar_index, yloc = yloc.price, style = labelStyle, textcolor = headerText, color = color.new(zoneLabelColor, 0), size = labelSz, tooltip = eventTip, textalign = text.align_center)
    array.push(eventLabels, eventLabel)
    while array.size(eventLabels) > usedMaxLabels
        oldLabel = array.shift(eventLabels)
        label.delete(oldLabel)
    lastLabelBar := bar_index

if barstate.islast and array.size(eventLabels) > 0
    if showLabels
        for i = 0 to array.size(eventLabels) - 1
            label.set_size(array.get(eventLabels, i), labelSz)
    else
        for i = 0 to array.size(eventLabels) - 1
            label.delete(array.get(eventLabels, i))
        array.clear(eventLabels)

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelIsLight = panelTheme == "Light"
panelShell = f_panel_bg(panelIsLight, false)
panelAlt = f_panel_bg(panelIsLight, true)
panelFrame = f_panel_border(panelIsLight)
panelKeyText = f_panel_label(panelIsLight)
panelValText = f_panel_value(panelIsLight)
bestViewText = f_best_view_text()
scoreBg = color.new(stateColor, panelIsLight ? 80 : 88)

proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) + (proofAmbiguous > 0 ? " | x = " + str.tostring(proofAmbiguous) : "") : proofAmbiguous > 0 ? "x = " + str.tostring(proofAmbiguous) : "building"
followText = proofTotal > 0 ? f_pct(followRate) : "-"
holdText = proofTotal > 0 ? f_pct(holdRate) : "-"
reactText = proofTotal > 0 ? f_pct(reactRate) : "-"
flipText = proofTotal > 0 ? f_pct(flipRate) : "-"
followCol = proofTotal > 0 ? f_rate_color(followRate) : panelValText
holdCol = proofTotal > 0 ? f_rate_color(holdRate) : panelValText
reactCol = proofTotal > 0 ? f_rate_color(reactRate) : panelValText
flipCol = proofTotal > 0 ? f_flip_color(flipRate) : panelValText

int panelRowCount = showProof ? 13 : 8

var table pnl = table.new(position.top_right, 2, panelRowCount, frame_color = panelBorder, frame_width = 1, border_width = 1, bgcolor = panelBg)

if barstate.islast
    table.set_position(pnl, f_panel_pos(panelLocation))
    table.set_frame_color(pnl, panelFrame)
    table.set_border_color(pnl, panelFrame)
    if showPanel
        table.clear(pnl, 0, 0, 1, panelRowCount - 1)
        table.merge_cells(pnl, 0, 0, 1, 0)
        table.cell(pnl, 0, 0, "AG Pro Reward Room Analyzer", text_color = headerText, bgcolor = headerBg, text_size = panelSz, text_halign = text.align_center)
        table.cell(pnl, 0, 1, "Reward Score", text_color = panelKeyText, bgcolor = panelShell, text_size = panelSz)
        table.cell(pnl, 1, 1, str.tostring(rewardScore) + " / 100  " + rewardGrade, text_color = stateColor, bgcolor = scoreBg, text_size = panelSz, text_halign = text.align_right)
        table.cell(pnl, 0, 2, "State", text_color = panelKeyText, bgcolor = panelAlt, text_size = panelSz)
        table.cell(pnl, 1, 2, f_titlecase(stateText), text_color = stateColor, bgcolor = panelAlt, text_size = panelSz, text_halign = text.align_right)
        table.cell(pnl, 0, 3, "Reward Room", text_color = panelKeyText, bgcolor = panelShell, text_size = panelSz)
        table.cell(pnl, 1, 3, obstacleText, text_color = targetRoomAtr >= minimumRoomAtr ? bullColor : neutralColor, bgcolor = panelShell, text_size = panelSz, text_halign = text.align_right)
        table.cell(pnl, 0, 4, "Room to Risk", text_color = panelKeyText, bgcolor = panelAlt, text_size = panelSz)
        table.cell(pnl, 1, 4, roomRiskText, text_color = roomToRisk >= minimumRoomToRisk ? bullColor : neutralColor, bgcolor = panelAlt, text_size = panelSz, text_halign = text.align_right)
        table.cell(pnl, 0, 5, "Target Side", text_color = panelKeyText, bgcolor = panelShell, text_size = panelSz)
        table.cell(pnl, 1, 5, targetSideText, text_color = panelValText, bgcolor = panelShell, text_size = panelSz, text_halign = text.align_right)
        table.cell(pnl, 0, 6, "Action", text_color = panelKeyText, bgcolor = panelAlt, text_size = panelSz)
        table.cell(pnl, 1, 6, actionText, text_color = panelValText, bgcolor = panelAlt, text_size = panelSz, text_halign = text.align_right)
        table.cell(pnl, 0, 7, "Best View", text_color = panelKeyText, bgcolor = panelShell, text_size = panelSz)
        table.cell(pnl, 1, 7, bestViewText, text_color = accentColor, bgcolor = panelShell, text_size = panelSz, text_halign = text.align_right)
        if showProof
            table.cell(pnl, 0, 8, "Proof @ Confirm", text_color = accentColor, bgcolor = panelAlt, text_size = panelSz, text_halign = text.align_left)
            table.cell(pnl, 1, 8, proofSampleText, text_color = panelKeyText, bgcolor = panelAlt, text_size = panelSz, text_halign = text.align_right)
            table.cell(pnl, 0, 9, "Follow Rate", text_color = panelKeyText, bgcolor = panelShell, text_size = panelSz)
            table.cell(pnl, 1, 9, followText, text_color = followCol, bgcolor = panelShell, text_size = panelSz, text_halign = text.align_right)
            table.cell(pnl, 0, 10, "Hold Rate", text_color = panelKeyText, bgcolor = panelAlt, text_size = panelSz)
            table.cell(pnl, 1, 10, holdText, text_color = holdCol, bgcolor = panelAlt, text_size = panelSz, text_halign = text.align_right)
            table.cell(pnl, 0, 11, "React Rate", text_color = panelKeyText, bgcolor = panelShell, text_size = panelSz)
            table.cell(pnl, 1, 11, reactText, text_color = reactCol, bgcolor = panelShell, text_size = panelSz, text_halign = text.align_right)
            table.cell(pnl, 0, 12, "Flip Rate", text_color = panelKeyText, bgcolor = panelAlt, text_size = panelSz)
            table.cell(pnl, 1, 12, flipText, text_color = flipCol, bgcolor = panelAlt, text_size = panelSz, text_halign = text.align_right)
    else
        table.clear(pnl, 0, 0, 1, panelRowCount - 1)

// -------------------------------------------------
// Alerts And Hidden Exports
// -------------------------------------------------
newOpenRoom = confirmedBar and openRoom and not openRoom[1]
newWatchRoom = confirmedBar and watchRoom and not openRoom and not watchRoom[1]
newBlockedPath = confirmedBar and stateText == "BLOCKED PATH" and stateText[1] != "BLOCKED PATH"
newThinRoom = confirmedBar and stateText == "THIN ROOM" and stateText[1] != "THIN ROOM"
newRiskHeavy = confirmedBar and stateText == "RISK HEAVY" and stateText[1] != "RISK HEAVY"

alertcondition(alertOpenWatch and newOpenRoom, "Open Reward Room", "Reward Room Analyzer: open reward room state is active.")
alertcondition(alertOpenWatch and newWatchRoom, "Watch Reward Room", "Reward Room Analyzer: watchable reward room context is active.")
alertcondition(alertRoomWarnings and newBlockedPath, "Blocked Reward Path", "Reward Room Analyzer: room-to-risk is blocked by nearby structure.")
alertcondition(alertRoomWarnings and newThinRoom, "Thin Reward Room", "Reward Room Analyzer: nearest obstacle is too close for clean reward room.")
alertcondition(alertRoomWarnings and newRiskHeavy, "Risk Heavy Room", "Reward Room Analyzer: invalidation distance is heavy relative to reward room.")

plot(rewardScore, "RRA Reward Room Score", display = display.none)
plot(targetRoomAtr, "RRA Target Room ATR", display = display.none)
plot(roomToRisk, "RRA Room To Risk", display = display.none)
plot(followRate, "RRA Follow Rate", display = display.none)
plot(holdRate, "RRA Hold Rate", display = display.none)
plot(reactRate, "RRA React Rate", display = display.none)
plot(flipRate, "RRA Flip Rate", display = display.none)
plot(proofAmbiguous, "RRA Ambiguous Proof Count", display = display.none)
plot(riskDistanceAtr, "RRA Risk Distance ATR", display = display.none)
plot(obstacleCount, "RRA Active Obstacle Count", display = display.none)
plot(longSide ? 1 : -1, "RRA Target Side Code", display = display.none)
````

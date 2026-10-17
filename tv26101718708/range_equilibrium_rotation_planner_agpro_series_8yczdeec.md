# Range Equilibrium Rotation Planner [AGPro Series]

- url: https://www.tradingview.com/script/8YczdeeC-Range-Equilibrium-Rotation-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;652b6b98e4604d0fbac282c461ef5cbc
- version: 4.0

## Description

Range Equilibrium Rotation Planner [AGPro Series]

🧠 Core Idea

Is price rotating cleanly away from range equilibrium toward an edge, or is the midpoint still controlling the auction?


📌 Overview / What it does

Range Equilibrium Rotation Planner [AGPro Series] maps mature range structure and focuses on the midpoint equilibrium area instead of treating every range as a breakout setup.

The script displays the active range box, equilibrium band, edge rails, rotation room rail, failure rail, event labels, right-side tags, optional bar coloring, and a compact AG Pro dashboard with a 0-100 Rotation Score.

It does not predict range breaks. It helps organize range balance, midpoint control, directional rotation, edge room, failure risk, and next-action state.


🎯 Purpose & Design Philosophy

Many range tools focus on support, resistance, or breakout alerts.

This script was built for a different question: what happens inside the range before price reaches the edge?

It helps traders review whether price is still trapped around equilibrium or beginning a clean rotation from the midpoint toward the upper or lower edge.


⚡ Why This Script Is Different

Most range indicators draw a box and wait for a breakout.

This script does NOT center the workflow on range escape.

Instead, it evaluates range maturity, midpoint control, rotation quality, edge room, and failure back through equilibrium. The goal is rotation planning, not breakout prediction.


⚙️ Methodology

1. Range Maturity Detection

The script builds a rolling range using recent high and low structure, then checks whether the height and edge interactions are meaningful.

2. Equilibrium Mapping

The midpoint band is calculated around the center of the range and becomes the key control zone.

3. Rotation Evaluation

Price must move away from equilibrium with enough buffer before directional rotation is considered active.

4. Risk / Room Structure

The active edge becomes the room reference, while the opposite side of equilibrium becomes the failure area.

5. Visual Output

The chart receives a range box, equilibrium band, edge rails, room rail, failure rail, labels, right-side tags, optional bar coloring, and dashboard panel.


🗺️ How to Read the Chart

The range box marks the current high-to-low structure.

The equilibrium band shows the midpoint area where rotation control is evaluated.

The upper and lower rails mark the active range edges.

The room rail marks the edge being targeted by the active rotation.

The failure rail marks where rotation has moved back through the wrong side of equilibrium.

Labels highlight mature ranges, rotations from midpoint, equilibrium holds, edge reviews, and failed rotations.

Colors represent context:

• Teal → bullish rotation

• Pink → bearish rotation or failure

• Gold → equilibrium, room, or edge review

• Indigo → range structure or waiting context

The panel summarizes:

• Range

• Rotation Score

• Balance

• Room

• Action


🚦 Signals & States

• Range Ready → a mature range structure is available

• Bull Rotation → price rotated upward from equilibrium

• Bear Rotation → price rotated downward from equilibrium

• Midpoint Hold → price remains controlled by the equilibrium band

• Edge Review → price reached the active range edge

• Failed → rotation moved back through the failure rail

• READY → rotation quality and room are strong enough to monitor

• MONITOR → rotation is active but not fully ready

• WAIT RANGE → no mature range exists

• WAIT ROTATION → range exists but no clean rotation has started


🔔 Alerts Logic

Alerts can trigger when a mature range appears, when bullish or bearish rotation begins, when READY state appears, when midpoint hold appears, when an edge is reached, or when the rotation fails.

Alerts are attention markers only. They are not trade instructions.


🧩 Confluence Logic

The context becomes stronger when range maturity, balanced edge interaction, midpoint departure, edge room, and failure distance align.

The script avoids treating midpoint noise as a clean rotation without confirmation.


📊 When to Use

• Sideways markets with visible range structure

• Crypto, forex, indices, and liquid stocks

• 1H, 4H, and 1D market structure review

• Mean-reversion planning inside a range

• Range edge preparation without waiting for breakout-only logic


⚠️ When NOT to Use

• Strong one-directional trends with no range structure

• Thin symbols with unreliable highs and lows

• News-driven candles that distort range boundaries

• Very small ranges where spread or tick noise dominates

• Markets with unstable data or irregular sessions


🎛️ Key Inputs

• Range Lookback → controls the structure used to build the range

• Minimum / Maximum Range Height ATR → filters ranges that are too small or too wide

• Edge Touch Tolerance → controls how edge interactions are counted

• Equilibrium Band ATR → controls midpoint band width

• Rotation Break Buffer → controls how far price must move beyond equilibrium

• Minimum Ready Score → controls READY strictness

• Projection Bars → controls how far boxes, rails, and tags extend

• Visual settings → control labels, tags, panel location, theme, and font size


🖥️ Interface & Visual Design

The panel is designed to show the range state, rotation quality, balance, room, and action without overloading the chart.

The first row uses a merged AG Pro header. The chart layer keeps the range and equilibrium structure visible while leaving room for price action.

Labels are controlled with cooldown and maximum count settings to preserve a premium screenshot style.


🧪 Practical Usage Workflow

1. Read the panel.

2. Confirm a mature range exists.

3. Check whether price is still at equilibrium or rotating away.

4. Review room to the active edge.

5. Watch the failure rail if rotation loses control.


🔍 Interpretation Guidelines

A high score means range maturity, midpoint departure, and edge room are aligned.

A midpoint hold means equilibrium is still controlling the auction.

An edge review means the rotation has reached the active range edge and should be interpreted as context, not as an automatic exit.

A failed state means the active rotation moved back through its failure boundary.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an automated trading system.

It does not place orders.

It does not guarantee edge reach, reversal, breakout, or profitability.


⚠️ Limitations & Transparency

Range boundaries can shift as new highs or lows appear.

Different timeframes may show different range structures.

Large volatility events can temporarily distort range height and edge touch quality.

Low liquidity may create unreliable equilibrium or edge behavior.

The script is rule-based and should be interpreted within broader market context.


🧠 Market Context Notes

Equilibrium is often where the market decides whether price will rotate toward an edge or remain balanced.

The strongest rotation contexts usually appear when price leaves midpoint with room, while failure remains clearly defined.

This script is designed to make that inside-range decision point easier to read.


🧾 Use Case Examples

When price holds near midpoint and then closes above the equilibrium band, the script can begin tracking bullish rotation toward the upper range edge.

When price rotates downward from equilibrium and reaches the lower edge, the context shifts into edge review rather than fresh entry signaling.

When price moves back through the failure rail, the active rotation context fails.


🧱 System Philosophy

AGPro Series tools are built as decision-support systems.

They aim to convert market structure into readable context: what is active, what improves the plan, what invalidates it, and what should be reviewed next.


🔐 Non-Promise Statement

No script can provide certainty.

No signal guarantees outcome.

This tool provides structured context only.


📉 Risk Disclosure

Trading involves risk.

Markets can move quickly and unexpectedly.

Users are responsible for their own analysis, risk management, and decisions.

This script does not provide financial advice.


📚 Educational Note

Use this tool to study how range equilibrium, midpoint control, rotation quality, and edge room interact across different symbols and timeframes.

## Source Code

````pine
// --------------------------------------------------
// Range Equilibrium Rotation Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.6
//
// Range Equilibrium Rotation Planner maps mature range structure, identifies
// the midpoint equilibrium band, evaluates whether price is rotating cleanly
// toward a range edge, and organizes room, failure risk, balance quality, and
// next-action state into a 0-100 score. It keeps active rotation structures
// alive through the review window and presents room, failure, and balance
// context with high-contrast badges and panel themes.
// --------------------------------------------------

//@version=6
indicator("Range Equilibrium Rotation Planner [AGPro Series]",
     shorttitle = "AG Pro RER",
     overlay = true,
     max_boxes_count = 60,
     max_lines_count = 150,
     max_labels_count = 220)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
G_RANGE = "Range Engine"
G_ROTATION = "Rotation Logic"
G_VISUAL = "Visuals"
G_PANEL = "Panel"
G_ALERTS = "Alerts"

atrLength = input.int(14, "ATR Length", minval = 1, maxval = 300, group = G_RANGE,
     tooltip = "ATR length used to normalize range height, equilibrium width, labels, failure rails, and edge-room calculations.")
rangeLookback = input.int(72, "Range Lookback", minval = 20, maxval = 500, group = G_RANGE,
     tooltip = "Lookback used to build the active range high, range low, and midpoint equilibrium reference.")
minRangeAtr = input.float(1.20, "Minimum Range Height ATR", minval = 0.20, maxval = 20.0, step = 0.05, group = G_RANGE,
     tooltip = "Minimum range height, measured in ATR, required before the structure can be treated as a meaningful rotation range.")
maxRangeAtr = input.float(9.00, "Maximum Range Height ATR", minval = 0.50, maxval = 50.0, step = 0.25, group = G_RANGE,
     tooltip = "Maximum range height, measured in ATR, allowed before the structure becomes too wide for clean equilibrium rotation planning.")
edgeTouchAtr = input.float(0.28, "Edge Touch Tolerance ATR", minval = 0.02, maxval = 2.0, step = 0.01, group = G_RANGE,
     tooltip = "ATR tolerance used to count recent upper and lower range-edge interactions.")
minEdgeTouches = input.int(2, "Minimum Edge Touches", minval = 1, maxval = 20, group = G_RANGE,
     tooltip = "Minimum combined upper and lower edge touches required for range maturity.")
equilibriumWidthAtr = input.float(0.28, "Equilibrium Band ATR", minval = 0.02, maxval = 2.0, step = 0.01, group = G_RANGE,
     tooltip = "Half-width of the equilibrium band around the range midpoint, measured in ATR.")

minReadyScore = input.int(65, "Minimum Ready Score", minval = 1, maxval = 100, group = G_ROTATION,
     tooltip = "Minimum 0-100 score required before the range rotation context becomes READY.")
rotationBufferAtr = input.float(0.06, "Rotation Break Buffer ATR", minval = 0.00, maxval = 1.0, step = 0.01, group = G_ROTATION,
     tooltip = "ATR buffer beyond the equilibrium band required before rotation direction is considered active.")
failureBufferAtr = input.float(0.18, "Equilibrium Failure Buffer ATR", minval = 0.00, maxval = 2.0, step = 0.01, group = G_ROTATION,
     tooltip = "ATR buffer beyond the opposite side of the equilibrium band where the active rotation idea fails.")
maxRotationAge = input.int(120, "Maximum Rotation Age", minval = 10, maxval = 800, group = G_ROTATION,
     tooltip = "Maximum bars an active equilibrium rotation can remain active before it expires.")
keepRotationStructure = input.bool(true, "Keep Active Rotation Structure", group = G_ROTATION,
     tooltip = "Keeps the locked range box, equilibrium band, edge room, and failure rail visible through the rotation review window even if the newest rolling range is no longer mature.")

showRangeBox = input.bool(true, "Show Range Box", group = G_VISUAL,
     tooltip = "Shows the active range high-to-low structure.")
showRangeText = input.bool(true, "Show Centered Range Badge", group = G_VISUAL,
     tooltip = "Shows a separate centered badge inside the range box.")
showEquilibriumBand = input.bool(true, "Show Equilibrium Band", group = G_VISUAL,
     tooltip = "Shows the midpoint equilibrium band that controls rotation direction.")
showEquilibriumText = input.bool(false, "Show Equilibrium Badge", group = G_VISUAL,
     tooltip = "Shows a separate centered badge inside the equilibrium band. Disabled by default so range and midpoint text do not crowd each other.")
showEdgeRails = input.bool(false, "Show Secondary Edge Rails", group = G_VISUAL,
     tooltip = "Shows both secondary range-edge rails in addition to the owned active room rail. Disabled by default because the range box already defines both boundaries.")
showFailureRail = input.bool(true, "Show Failure Rail", group = G_VISUAL,
     tooltip = "Shows where the active equilibrium rotation fails.")
showRoomRail = input.bool(true, "Show Rotation Room Rail", group = G_VISUAL,
     tooltip = "Shows the active edge-room target for the current rotation direction.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows range, midpoint, rotation, edge, and failed-rotation labels on the chart.")
showRangeLabels = input.bool(true, "Show Range Labels", group = G_VISUAL,
     tooltip = "Shows labels when a mature range becomes available.")
showRotationLabels = input.bool(true, "Show Rotation Labels", group = G_VISUAL,
     tooltip = "Shows labels when price rotates away from the equilibrium band.")
showMidpointLabels = input.bool(false, "Show Midpoint Pressure Labels", group = G_VISUAL,
     tooltip = "Shows labels when price is testing equilibrium without clean directional rotation. Disabled by default for cleaner screenshots.")
showEdgeLabels = input.bool(true, "Show Edge Labels", group = G_VISUAL,
     tooltip = "Shows labels when price reaches the active range edge.")
showInvalidLabels = input.bool(true, "Show Failed Labels", group = G_VISUAL,
     tooltip = "Shows labels when the active equilibrium rotation fails.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows compact right-side tags for equilibrium, edge room, and failure levels.")
rightTagMode = input.string("Compact", "Right Tag Detail Mode", options = ["Compact", "Full"], group = G_VISUAL,
     tooltip = "Compact shows decision-critical right-side tags. Full also shows the equilibrium tag during active rotations.")
showBarColors = input.bool(false, "Color Bars By State", group = G_VISUAL,
     tooltip = "Colors bars lightly according to the active range rotation state.")
projectionBars = input.int(64, "Projection Bars", minval = 10, maxval = 400, group = G_VISUAL,
     tooltip = "Number of bars used for projected boxes, rails, and right-side tags.")
zoneBadgeAnchor = input.float(0.60, "Zone Badge Anchor", minval = 0.35, maxval = 0.90, step = 0.05, group = G_VISUAL,
     tooltip = "Controls the horizontal position of centered range and equilibrium badges inside projected structures.")
labelCooldownBars = input.int(34, "Label Cooldown Bars", minval = 1, maxval = 100, group = G_VISUAL,
     tooltip = "Minimum spacing between repeated event labels.")
maxEventLabels = input.int(5, "Maximum Event Labels", minval = 4, maxval = 80, group = G_VISUAL,
     tooltip = "Maximum historical event labels retained on the chart.")
eventMemoryBars = input.int(180, "Event Label Memory Bars", minval = 20, maxval = 1000, group = G_VISUAL,
     tooltip = "Maximum age of historical event labels. Older labels are removed so stale range events do not dominate the current chart.")
labelOffsetAtr = input.float(0.90, "Label Offset ATR", minval = 0.05, maxval = 5.0, step = 0.05, group = G_VISUAL,
     tooltip = "ATR-based label offset so labels remain readable above or below candles.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Controls chart label, centered badge, and right-side tag font size.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro dashboard panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = G_PANEL,
     tooltip = "Controls dashboard location.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Slate", "Light"], group = G_PANEL,
     tooltip = "Controls dashboard theme.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Controls dashboard font size.")

alertRange = input.bool(true, "Alert: Mature Range", group = G_ALERTS,
     tooltip = "Enables alerts when a mature range structure becomes available.")
alertRotation = input.bool(true, "Alert: Rotation Active", group = G_ALERTS,
     tooltip = "Enables alerts when price rotates away from equilibrium.")
alertReady = input.bool(true, "Alert: Ready State", group = G_ALERTS,
     tooltip = "Enables alerts when the range rotation context reaches READY conditions.")
alertMidpoint = input.bool(false, "Alert: Midpoint Pressure", group = G_ALERTS,
     tooltip = "Enables alerts when price pressures the equilibrium band without clean rotation.")
alertEdge = input.bool(false, "Alert: Edge Review", group = G_ALERTS,
     tooltip = "Enables alerts when price reaches the active range edge.")
alertFailed = input.bool(true, "Alert: Rotation Failed", group = G_ALERTS,
     tooltip = "Enables alerts when the active equilibrium rotation fails.")

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBg = color.rgb(15, 23, 42)
panelBgSlate = color.rgb(30, 41, 59)
panelBgLight = color.rgb(248, 250, 252)
panelBorder = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
panelLabelLight = color.rgb(71, 85, 105)
panelValueLight = color.rgb(15, 23, 42)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, nz(value, minValue)))

// Luminance-aware contrast text (target luminance 145)
f_lum(color c)      => 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
f_text_on(color bg) => f_lum(bg) > 145 ? color.rgb(15, 23, 42) : color.rgb(245, 247, 250)

f_score(float value) =>
    int(math.round(f_clamp(value, 0.0, 100.0)))

f_grade(int score) =>
    score >= 85 ? "A+" : score >= 75 ? "A" : score >= 65 ? "B" : score >= 50 ? "C" : "D"

f_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_position(string posInput) =>
    switch posInput
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_panel_bg(string themeInput) =>
    themeInput == "Light" ? panelBgLight : themeInput == "Slate" ? panelBgSlate : panelBg

f_panel_label(string themeInput) =>
    themeInput == "Light" ? panelLabelLight : panelLabelCol

f_panel_value(string themeInput) =>
    themeInput == "Light" ? panelValueLight : panelValueCol

f_price(float value) =>
    str.tostring(value, format.mintick)

f_set_badge(label badge, int x, float y, string txt, color bg, color tx, string sizeInput) =>
    label.set_x(badge, x)
    label.set_y(badge, y)
    label.set_text(badge, txt)
    label.set_color(badge, bg)
    label.set_textcolor(badge, tx)
    label.set_size(badge, f_size(sizeInput))
    label.set_style(badge, label.style_label_center)

f_hide_badge(label badge) =>
    label.set_text(badge, "")
    label.set_color(badge, color.new(color.white, 100))
    label.set_textcolor(badge, color.new(color.white, 100))
    label.set_x(badge, bar_index)
    label.set_y(badge, close)

f_panel_cell(table panelRef, int col, int row, string txt, color txtColor, color bgColor, string sizeInput) =>
    table.cell(panelRef, col, row, txt, text_color = txtColor, bgcolor = bgColor, text_size = f_size(sizeInput))

// --------------------------------------------------
// Core calculations
// --------------------------------------------------
atr = ta.atr(atrLength)
atrSafe = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
rangeHigh = ta.highest(high, rangeLookback)
rangeLow = ta.lowest(low, rangeLookback)
rangeHeight = math.max(rangeHigh - rangeLow, syminfo.mintick)
rangeAtr = rangeHeight / atrSafe
midpoint = (rangeHigh + rangeLow) * 0.50
eqHalf = equilibriumWidthAtr * atrSafe
eqTop = midpoint + eqHalf
eqBottom = midpoint - eqHalf
rotationUpRail = eqTop + rotationBufferAtr * atrSafe
rotationDownRail = eqBottom - rotationBufferAtr * atrSafe
upperEdgeTouch = high >= rangeHigh - edgeTouchAtr * atrSafe
lowerEdgeTouch = low <= rangeLow + edgeTouchAtr * atrSafe
upperTouches = ta.sma(upperEdgeTouch ? 1.0 : 0.0, rangeLookback) * rangeLookback
lowerTouches = ta.sma(lowerEdgeTouch ? 1.0 : 0.0, rangeLookback) * rangeLookback
totalTouches = upperTouches + lowerTouches
rangeMature = rangeAtr >= minRangeAtr and rangeAtr <= maxRangeAtr and totalTouches >= minEdgeTouches and not na(rangeHigh[1])

inEquilibrium = close <= eqTop and close >= eqBottom
prevRangeMature = bar_index > 0 ? rangeMature[1] : false
bullRotationRaw = rangeMature and close > rotationUpRail and close[1] <= eqTop
bearRotationRaw = rangeMature and close < rotationDownRail and close[1] >= eqBottom
newRotation = bullRotationRaw or bearRotationRaw
newMatureRange = rangeMature and not prevRangeMature

// --------------------------------------------------
// Active rotation state
// --------------------------------------------------
var bool hasRotation = false
var int activeDir = 0
var int rotationBar = na
var float lockedRangeHigh = na
var float lockedRangeLow = na
var float lockedMid = na
var float lockedEqTop = na
var float lockedEqBottom = na
var float lockedRangeAtr = na
var float lockedTouches = na
var float roomRail = na
var float failureRail = na
var bool edgeReached = false
var bool failed = false
var int lastLabelBar = na

if newRotation
    hasRotation := true
    activeDir := bullRotationRaw ? 1 : -1
    rotationBar := bar_index
    lockedRangeHigh := rangeHigh
    lockedRangeLow := rangeLow
    lockedMid := midpoint
    lockedEqTop := eqTop
    lockedEqBottom := eqBottom
    lockedRangeAtr := rangeAtr
    lockedTouches := totalTouches
    roomRail := activeDir == 1 ? rangeHigh : rangeLow
    failureRail := activeDir == 1 ? eqBottom - failureBufferAtr * atrSafe : eqTop + failureBufferAtr * atrSafe
    edgeReached := false
    failed := false

rotationAge = hasRotation ? bar_index - rotationBar : na
expired = hasRotation and rotationAge > maxRotationAge

if hasRotation and not expired
    if activeDir == 1 and high >= roomRail
        edgeReached := true
    if activeDir == -1 and low <= roomRail
        edgeReached := true
    if activeDir == 1 and close < failureRail
        failed := true
    if activeDir == -1 and close > failureRail
        failed := true

activeRotation = hasRotation and not expired and not failed
activeRangeHigh = hasRotation ? lockedRangeHigh : rangeHigh
activeRangeLow = hasRotation ? lockedRangeLow : rangeLow
activeMid = hasRotation ? lockedMid : midpoint
activeEqTop = hasRotation ? lockedEqTop : eqTop
activeEqBottom = hasRotation ? lockedEqBottom : eqBottom
planningContext = rangeMature or keepRotationStructure and hasRotation and not expired and not na(activeRangeHigh) and not na(activeRangeLow)
planningRangeAtr = hasRotation and not na(lockedRangeAtr) ? lockedRangeAtr : rangeAtr
planningTouches = hasRotation and not na(lockedTouches) ? lockedTouches : totalTouches
rightEdge = bar_index + projectionBars
leftEdge = math.max(bar_index - rangeLookback, 0)

// --------------------------------------------------
// Score and states
// --------------------------------------------------
balanceScore = planningContext ? f_clamp((planningTouches / math.max(minEdgeTouches, 1)) * 22.0, 0.0, 24.0) : 0.0
widthScore = planningContext ? f_clamp((1.0 - math.abs(planningRangeAtr - ((minRangeAtr + maxRangeAtr) * 0.50)) / math.max((maxRangeAtr - minRangeAtr) * 0.50, 0.1)) * 18.0, 0.0, 18.0) : 0.0
eqControlScore = inEquilibrium ? 16.0 : hasRotation ? 10.0 : 4.0
rotationScorePart = hasRotation ? activeDir == 1 ? f_clamp((close - activeEqTop) / math.max(activeRangeHigh - activeEqTop, syminfo.mintick) * 24.0, 0.0, 24.0) : f_clamp((activeEqBottom - close) / math.max(activeEqBottom - activeRangeLow, syminfo.mintick) * 24.0, 0.0, 24.0) : 0.0
roomScore = hasRotation ? activeDir == 1 ? f_clamp((roomRail - close) / atrSafe * 4.0, 0.0, 18.0) : f_clamp((close - roomRail) / atrSafe * 4.0, 0.0, 18.0) : 0.0
agePenalty = hasRotation ? f_clamp(rotationAge / math.max(maxRotationAge, 1) * 8.0, 0.0, 8.0) : 0.0
rawScore = balanceScore + widthScore + eqControlScore + rotationScorePart + roomScore - agePenalty
rotationScore = planningContext ? f_score(rawScore) : 0
grade = f_grade(rotationScore)

readyState = activeRotation and not edgeReached and rotationScore >= minReadyScore
midpointPressure = rangeMature and not hasRotation and inEquilibrium

rangeState = expired ? "Expired" : failed ? "Failed" : hasRotation ? activeDir == 1 ? "Bull Rotation" : "Bear Rotation" : rangeMature ? "Equilibrium" : "No Range"
roomText = hasRotation and not expired and not na(roomRail) ? str.tostring(math.abs(roomRail - close) / atrSafe, "0.00") + " ATR" : rangeMature ? "Edge Pending" : "n/a"
balanceText = planningContext ? str.tostring(planningRangeAtr, "0.00") + " ATR | Touch " + str.tostring(planningTouches, "0") : "n/a"
scoreText = planningContext ? str.tostring(rotationScore) + "/100  " + grade : "n/a"

actionState = "Wait"
if expired
    actionState := "Expired"
else if failed
    actionState := "Failed"
else if edgeReached
    actionState := "Edge Review"
else if readyState
    actionState := "Ready"
else if hasRotation
    actionState := "Monitor"
else if midpointPressure
    actionState := "Midpoint Hold"
else if not rangeMature
    actionState := "Wait Range"
else
    actionState := "Wait Rotation"

stateColor = not planningContext or expired ? neutralColor : failed ? bearColor : readyState ? bullColor : hasRotation ? activeDir == 1 ? bullColor : bearColor : accentColor
actionColor = actionState == "Ready" ? bullColor : actionState == "Failed" ? bearColor : actionState == "Edge Review" or actionState == "Midpoint Hold" ? neutralColor : actionState == "Monitor" ? stateColor : accentColor
actionTextColor = f_text_on(actionColor)

rotationPrev = bar_index > 0 ? hasRotation[1] : false
edgePrev = bar_index > 0 ? edgeReached[1] : false
failedPrev = bar_index > 0 ? failed[1] : false
readyPrev = bar_index > 0 ? readyState[1] : false
midPrev = bar_index > 0 ? midpointPressure[1] : false

rotationEvent = hasRotation and not rotationPrev
edgeEvent = activeRotation and edgeReached and not edgePrev
failedEvent = hasRotation and failed and not failedPrev
readyEvent = readyState and not readyPrev
midpointEvent = midpointPressure and not midPrev

// --------------------------------------------------
// Drawings
// --------------------------------------------------
var box rangeBox = na
var box eqBox = na
var line upperLine = na
var line lowerLine = na
var line roomLine = na
var line failLine = na
var label rangeBadge = label.new(bar_index, close, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = accentColor, textcolor = f_text_on(accentColor), size = size.normal, textalign = text.align_center)
var label eqBadge = label.new(bar_index, close, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = neutralColor, textcolor = f_text_on(neutralColor), size = size.normal, textalign = text.align_center)

badgeX = int(math.round(leftEdge + (rightEdge - leftEdge) * zoneBadgeAnchor))

if planningContext and showRangeBox
    if na(rangeBox)
        rangeBox := box.new(leftEdge, activeRangeHigh, rightEdge, activeRangeLow, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 91), border_color = color.new(accentColor, 48), border_width = 1)
    else
        box.set_lefttop(rangeBox, leftEdge, activeRangeHigh)
        box.set_rightbottom(rangeBox, rightEdge, activeRangeLow)
    if showRangeText
        string rangeBadgeText = hasRotation ? (activeDir == 1 ? "BULL ROTATION RANGE" : "BEAR ROTATION RANGE") + " | Q" + str.tostring(rotationScore) : "EQUILIBRIUM RANGE | Q" + str.tostring(rotationScore)
        color rangeBadgeColor = hasRotation ? stateColor : accentColor
        f_set_badge(rangeBadge, badgeX, (activeRangeHigh + activeRangeLow) * 0.50, rangeBadgeText, color.new(rangeBadgeColor, 0), f_text_on(rangeBadgeColor), labelSizeInput)
    else
        f_hide_badge(rangeBadge)
else
    if not na(rangeBox)
        box.delete(rangeBox)
        rangeBox := na
    f_hide_badge(rangeBadge)

if planningContext and showEquilibriumBand
    if na(eqBox)
        eqBox := box.new(leftEdge, activeEqTop, rightEdge, activeEqBottom, xloc = xloc.bar_index, bgcolor = color.new(neutralColor, 82), border_color = color.new(neutralColor, 35), border_width = 1)
    else
        box.set_lefttop(eqBox, leftEdge, activeEqTop)
        box.set_rightbottom(eqBox, rightEdge, activeEqBottom)
    if showEquilibriumText
        f_set_badge(eqBadge, badgeX, activeMid, "Equilibrium", color.new(neutralColor, 0), f_text_on(neutralColor), labelSizeInput)
    else
        f_hide_badge(eqBadge)
else
    if not na(eqBox)
        box.delete(eqBox)
        eqBox := na
    f_hide_badge(eqBadge)

if planningContext and showEdgeRails
    if na(upperLine)
        upperLine := line.new(leftEdge, activeRangeHigh, rightEdge, activeRangeHigh, xloc = xloc.bar_index, extend = extend.none, color = bullColor, width = 1)
        lowerLine := line.new(leftEdge, activeRangeLow, rightEdge, activeRangeLow, xloc = xloc.bar_index, extend = extend.none, color = bearColor, width = 1)
    else
        line.set_xy1(upperLine, leftEdge, activeRangeHigh)
        line.set_xy2(upperLine, rightEdge, activeRangeHigh)
        line.set_xy1(lowerLine, leftEdge, activeRangeLow)
        line.set_xy2(lowerLine, rightEdge, activeRangeLow)
else
    if not na(upperLine)
        line.delete(upperLine)
        upperLine := na
    if not na(lowerLine)
        line.delete(lowerLine)
        lowerLine := na

if activeRotation and showRoomRail
    if na(roomLine)
        roomLine := line.new(rotationBar, roomRail, rightEdge, roomRail, xloc = xloc.bar_index, extend = extend.none, color = neutralColor, width = 2)
    else
        line.set_xy1(roomLine, rotationBar, roomRail)
        line.set_xy2(roomLine, rightEdge, roomRail)
else
    if not na(roomLine)
        line.delete(roomLine)
        roomLine := na

if activeRotation and showFailureRail
    if na(failLine)
        failLine := line.new(rotationBar, failureRail, rightEdge, failureRail, xloc = xloc.bar_index, extend = extend.none, color = bearColor, width = 1, style = line.style_dashed)
    else
        line.set_xy1(failLine, rotationBar, failureRail)
        line.set_xy2(failLine, rightEdge, failureRail)
else
    if not na(failLine)
        line.delete(failLine)
        failLine := na

// --------------------------------------------------
// Labels
// --------------------------------------------------
labelSize = f_size(labelSizeInput)
var array<label> eventLabels = array.new<label>()
var array<line> eventConnectors = array.new<line>()

f_push_event(label newLabel, line newConnector) =>
    array.push(eventLabels, newLabel)
    array.push(eventConnectors, newConnector)
    if array.size(eventLabels) > maxEventLabels
        label.delete(array.shift(eventLabels))
        line.delete(array.shift(eventConnectors))

if array.size(eventLabels) > 0
    cleanupIdx = array.size(eventLabels) - 1
    while cleanupIdx >= 0
        oldLabel = array.get(eventLabels, cleanupIdx)
        oldX = label.get_x(oldLabel)
        if bar_index - oldX > eventMemoryBars
            label.delete(oldLabel)
            line.delete(array.get(eventConnectors, cleanupIdx))
            array.remove(eventLabels, cleanupIdx)
            array.remove(eventConnectors, cleanupIdx)
        cleanupIdx -= 1

canLabel = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars
laneIndex = bar_index % 3
laneStep = labelSizeInput == "Tiny" ? 0.14 : labelSizeInput == "Small" ? 0.18 : labelSizeInput == "Large" ? 0.30 : 0.23
eventDistance = atrSafe * (labelOffsetAtr + laneIndex * laneStep)

if showEventLabels and showRangeLabels and newMatureRange and canLabel
    float eventY = high + eventDistance
    line newConnector = line.new(bar_index, high, bar_index, eventY, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 28), width = 1)
    label newLabel = label.new(bar_index, eventY, "RANGE READY | EQ MAPPED", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = accentColor, textcolor = f_text_on(accentColor), size = labelSize)
    f_push_event(newLabel, newConnector)
    lastLabelBar := bar_index

if showEventLabels and showRotationLabels and rotationEvent and canLabel
    bool bullEvent = activeDir == 1
    float anchorY = bullEvent ? low : high
    float eventY = bullEvent ? anchorY - eventDistance : anchorY + eventDistance
    color eventColor = bullEvent ? bullColor : bearColor
    line newConnector = line.new(bar_index, anchorY, bar_index, eventY, xloc = xloc.bar_index, extend = extend.none, color = color.new(eventColor, 28), width = 1)
    label newLabel = label.new(bar_index, eventY, bullEvent ? "BULL ROTATION | FROM EQ" : "BEAR ROTATION | FROM EQ", xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_up : label.style_label_down, color = eventColor, textcolor = f_text_on(eventColor), size = labelSize)
    f_push_event(newLabel, newConnector)
    lastLabelBar := bar_index

if showEventLabels and showMidpointLabels and midpointEvent and canLabel
    bool placeAbove = close >= midpoint
    float anchorY = placeAbove ? high : low
    float eventY = placeAbove ? anchorY + eventDistance : anchorY - eventDistance
    line newConnector = line.new(bar_index, anchorY, bar_index, eventY, xloc = xloc.bar_index, extend = extend.none, color = color.new(neutralColor, 28), width = 1)
    label newLabel = label.new(bar_index, eventY, "MIDPOINT HOLD | EQ CONTROL", xloc = xloc.bar_index, yloc = yloc.price, style = placeAbove ? label.style_label_down : label.style_label_up, color = neutralColor, textcolor = f_text_on(neutralColor), size = labelSize)
    f_push_event(newLabel, newConnector)
    lastLabelBar := bar_index

if showEventLabels and showEdgeLabels and edgeEvent and canLabel
    bool bullEvent = activeDir == 1
    float anchorY = bullEvent ? high : low
    float eventY = bullEvent ? anchorY + eventDistance : anchorY - eventDistance
    line newConnector = line.new(bar_index, anchorY, bar_index, eventY, xloc = xloc.bar_index, extend = extend.none, color = color.new(neutralColor, 28), width = 1)
    label newLabel = label.new(bar_index, eventY, bullEvent ? "EDGE REVIEW | UPPER REACHED" : "EDGE REVIEW | LOWER REACHED", xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_down : label.style_label_up, color = neutralColor, textcolor = f_text_on(neutralColor), size = labelSize)
    f_push_event(newLabel, newConnector)
    lastLabelBar := bar_index

if showEventLabels and showInvalidLabels and failedEvent and canLabel
    bool bullEvent = activeDir == 1
    float anchorY = bullEvent ? low : high
    float eventY = bullEvent ? anchorY - eventDistance : anchorY + eventDistance
    line newConnector = line.new(bar_index, anchorY, bar_index, eventY, xloc = xloc.bar_index, extend = extend.none, color = color.new(bearColor, 28), width = 1)
    label newLabel = label.new(bar_index, eventY, bullEvent ? "BULL FAILED | EQ LOST" : "BEAR FAILED | EQ LOST", xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_up : label.style_label_down, color = bearColor, textcolor = f_text_on(bearColor), size = labelSize)
    f_push_event(newLabel, newConnector)
    lastLabelBar := bar_index

// --------------------------------------------------
// Right-side tags
// --------------------------------------------------
var label eqTag = na
var label roomTag = na
var label failTag = na

f_update_tag(label tag, int x, float y, string txt, color bg, color txtCol) =>
    label result = tag
    if na(result)
        result := label.new(x, y, txt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = bg, textcolor = txtCol, size = labelSize)
    else
        label.set_x(result, x)
        label.set_y(result, y)
        label.set_text(result, txt)
        label.set_color(result, bg)
        label.set_textcolor(result, txtCol)
        label.set_size(result, labelSize)
    result

if showRightTags and planningContext
    if activeRotation
        roomTag := f_update_tag(roomTag, rightEdge, roomRail, "EDGE ROOM | " + f_price(roomRail), stateColor, f_text_on(stateColor))
        failTag := f_update_tag(failTag, rightEdge + 4, failureRail, "FAILURE | " + f_price(failureRail), bearColor, f_text_on(bearColor))
        if rightTagMode == "Full"
            eqTag := f_update_tag(eqTag, rightEdge + 8, activeMid, "EQUILIBRIUM | " + f_price(activeMid), neutralColor, f_text_on(neutralColor))
        else
            if not na(eqTag)
                label.delete(eqTag)
                eqTag := na
    else
        eqTag := f_update_tag(eqTag, rightEdge, activeMid, "EQUILIBRIUM | " + f_price(activeMid), neutralColor, f_text_on(neutralColor))
        if not na(roomTag)
            label.delete(roomTag)
            roomTag := na
        if not na(failTag)
            label.delete(failTag)
            failTag := na
else
    if not na(eqTag)
        label.delete(eqTag)
        eqTag := na
    if not na(roomTag)
        label.delete(roomTag)
        roomTag := na
    if not na(failTag)
        label.delete(failTag)
        failTag := na

// --------------------------------------------------
// Panel
// --------------------------------------------------
panelBodyBg = f_panel_bg(panelTheme)
panelLeftBg = panelTheme == "Light" ? color.rgb(226, 232, 240) : panelBorder
panelLabel = f_panel_label(panelTheme)
panelValue = f_panel_value(panelTheme)

var table panel = table.new(f_panel_position(panelPositionInput), 2, 6, border_width = 1, border_color = panelBorder, frame_color = panelBorder, frame_width = 1)

if barstate.islast
    table.set_position(panel, f_panel_position(panelPositionInput))
    if showPanel
        table.clear(panel, 0, 0, 1, 5)
        table.merge_cells(panel, 0, 0, 1, 0)
        f_panel_cell(panel, 0, 0, "AG Pro Range Equilibrium Rotation Planner", f_text_on(headerBg), headerBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 1, "Range", panelLabel, panelLeftBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 1, rangeState, panelValue, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 2, "Rotation Score", panelLabel, panelLeftBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 2, scoreText, f_text_on(stateColor), stateColor, panelFontSizeInput)
        f_panel_cell(panel, 0, 3, "Balance", panelLabel, panelLeftBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 3, balanceText, panelValue, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 4, "Room", panelLabel, panelLeftBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 4, roomText, panelValue, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 5, "Action", panelLabel, panelLeftBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 5, actionState, actionTextColor, actionColor, panelFontSizeInput)
    else
        table.clear(panel, 0, 0, 1, 5)

barStateColor = actionState == "Ready" ? color.new(stateColor, 72) : actionState == "Monitor" ? color.new(stateColor, 78) : actionState == "Failed" ? color.new(bearColor, 70) : actionState == "Midpoint Hold" ? color.new(neutralColor, 78) : na
barcolor(showBarColors ? barStateColor : na)

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(alertRange and newMatureRange, "Range Ready", "AG Pro RER: A mature range equilibrium structure has been detected on {{ticker}}.")
alertcondition(alertRotation and rotationEvent and activeDir == 1, "Bull Rotation", "AG Pro RER: Price is rotating upward from range equilibrium on {{ticker}}.")
alertcondition(alertRotation and rotationEvent and activeDir == -1, "Bear Rotation", "AG Pro RER: Price is rotating downward from range equilibrium on {{ticker}}.")
alertcondition(alertReady and readyEvent, "Ready", "AG Pro RER: The active range equilibrium rotation context is ready on {{ticker}}.")
alertcondition(alertMidpoint and midpointEvent, "Midpoint Hold", "AG Pro RER: Price is holding near range equilibrium on {{ticker}}.")
alertcondition(alertEdge and edgeEvent, "Edge Review", "AG Pro RER: Price reached the active range edge on {{ticker}}. Review context; this is not an exit instruction.")
alertcondition(alertFailed and failedEvent, "Failed", "AG Pro RER: The active range equilibrium rotation context has failed on {{ticker}}.")
````

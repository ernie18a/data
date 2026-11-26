# Wick Absorption Reversal Planner [AGPro Series]

- url: https://www.tradingview.com/script/5VoON2Ha-Wick-Absorption-Reversal-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;68badca820a84134931d28e14eacbd72
- version: 4.0

## Description

Wick Absorption Reversal Planner [AGPro Series]

🧠 Core Idea

Is an extended wick showing absorption, and did the candle body reclaim enough structure to treat the reversal context seriously?


📌 Overview / What it does

Wick Absorption Reversal Planner [AGPro Series] maps extended wick reactions as absorption pockets and evaluates whether price can reclaim the body rail after that reaction.

The script displays a wick absorption pocket, body reclaim rail, failure shelf, room reference, event labels, right-side tags, optional bar coloring, and a compact AG Pro dashboard with a 0-100 reversal score.

It does not predict reversals. It helps organize wick absorption, body reclaim quality, pressure, room, invalidation, and action state.


🎯 Purpose & Design Philosophy

Many candle tools label rejection candles, engulfing candles, or generic wick events.

This script was built for the next layer: whether the wick reaction is being absorbed and whether the candle body can reclaim the important zone afterward.

It helps traders separate random wick noise from a structured absorption pocket with a body reclaim rail and failure logic.


⚡ Why This Script Is Different

Most wick indicators focus on the wick itself.

This script does NOT treat every long wick as a reversal signal.

Instead, it maps the wick pocket, checks body reclaim, measures pressure and room, and gives a clear action state. The goal is interpretation, not prediction.


⚙️ Methodology

1. Wick Absorption Detection

The script checks upper and lower wick size relative to ATR and total candle range.

2. Context Mapping

The wick is compared with recent structure to avoid treating every isolated candle as meaningful.

3. Body Reclaim Evaluation

After a wick absorption pocket is detected, the body reclaim rail becomes the key threshold for reversal planning.

4. Visual Output

The chart receives the wick pocket, body reclaim rail, failure shelf, room rail, labels, right-side tags, optional bar coloring, and dashboard panel.


🗺️ How to Read the Chart

The wick absorption pocket marks the area created by the extended wick reaction.

The body reclaim rail shows the level price needs to recover for the reversal context to improve.

The failure shelf marks where the absorption context fails.

The room rail marks the nearest structure reference in the reversal direction.

Labels highlight wick absorption, body reclaim, pocket pressure, room tests, and absorption failure.

Colors represent context:

• Teal → bullish wick absorption

• Pink → bearish wick absorption or failure

• Gold → room reference or waiting context

• Indigo → pocket pressure or monitoring context

The panel summarizes:

• Pocket

• Reversal Score

• Pressure

• Room

• Action


🚦 Signals & States

• Bull Wick Absorption → lower wick absorption pocket detected

• Bear Wick Absorption → upper wick absorption pocket detected

• Body Reclaim → price reclaimed the body rail after absorption

• Pocket Pressure → price is testing the wick pocket without clean reclaim

• Room Test → price reached the active room reference

• Absorption Failed → price crossed the failure shelf

• READY → body reclaim and score quality are strong enough to monitor

• MONITOR → pocket or reclaim context is active but not fully ready

• WAIT → no strong active context exists

• INVALIDATED → the wick absorption context failed

• EXPIRED → the pocket is too old to remain active


🔔 Alerts Logic

Alerts can trigger when a bullish or bearish wick absorption pocket appears, when body reclaim appears, when READY state appears, when pocket pressure appears, when the room rail is reached, or when absorption fails.

Alerts are attention markers only. They are not trade instructions.


🧩 Confluence Logic

The context becomes stronger when wick size, wick-to-range ratio, structural location, participation, body reclaim, and room align.

For example, a lower wick into recent structure followed by body reclaim and available room is more useful than a random wick in the middle of noisy price action.


📊 When to Use

• Reversal watch areas after extended wicks

• Support/resistance reactions with visible rejection

• Pullbacks where wick absorption may matter

• Failed breakdown or failed breakout reactions

• Liquid symbols with readable candles and stable spreads

• 1h, 4h, and 1D charts where wick structure is visible


⚠️ When NOT to Use

• Very low-liquidity markets

• Symbols with unreliable candle structure

• Random spike candles from illiquid prints

• News candles with unstable spreads

• Extremely noisy ranges where every candle has exaggerated wicks


🎛️ Key Inputs

• ATR Length → controls normalization for wick size and visual spacing

• Wick Context Lookback → controls structural comparison

• Minimum Wick ATR → controls required wick size

• Minimum Wick / Range → controls required wick dominance inside the candle

• Minimum Relative Volume → filters very thin wick reactions

• Body Reclaim Buffer ATR → controls the reclaim rail threshold

• Failure Buffer ATR → controls where absorption fails

• Room Lookback → controls the room reference

• Visual settings → control pocket, rails, labels, tags, panel, and bar colors


🖥️ Interface & Visual Design

The visual hierarchy is designed around the wick pocket first, then the reclaim rail.

The pocket defines the reaction, the body reclaim rail defines improvement, the failure shelf defines risk, and the panel gives a quick state read.

The goal is a premium wick absorption map without turning the chart into a generic candle-label board.


🧪 Practical Usage Workflow

1. Check whether a wick absorption pocket is active

2. Read the reversal score and action state

3. Inspect the body reclaim rail

4. Compare pocket pressure with room

5. Watch the failure shelf

6. Confirm the context with broader structure and timeframe alignment


🔍 Interpretation Guidelines

A wick absorption pocket means the candle showed a meaningful wick reaction in context.

Body reclaim means price recovered the reclaim rail after the wick reaction.

READY means the rule-based context has enough quality to monitor.

Room is a reference for structure, not a promised target.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not a guaranteed reversal system.

It is not a generic candle pattern detector.

It is not a volume absorption zone engine.

It is not an automated trading tool.

It does not provide financial advice.

It does not guarantee reversal, continuation, profit, or a specific target.


⚠️ Limitations & Transparency

Wick behavior depends on market structure, liquidity, volatility, session conditions, and timeframe.

Some long wicks are random noise.

Some absorption pockets may fail quickly.

The score is a rule-based context score, not a certainty model.


🧠 Market Context Notes

Wicks can show rejection, absorption, stop activity, or simply noise.

The key question is whether price can reclaim the body rail after the wick event.

Use the pocket as context, not as confirmation by itself.


🧾 Use Case Examples

When price prints a long lower wick into recent structure, the script can map a bullish wick absorption pocket.

If price later reclaims the body rail, the script marks body reclaim and updates the panel state.

If price loses the failure shelf, the script marks absorption failure.


🧱 System Philosophy

This script follows the AGPro Series approach: turn a familiar chart behavior into a structured decision-support map.

The focus is not prediction. The focus is wick context, body reclaim, pressure, room, invalidation awareness, and visual clarity.


🔐 Non-Promise Statement

No script can remove uncertainty from markets.

This tool does not promise accuracy, profitability, or future price movement.

Its purpose is to organize wick absorption context so the user can interpret the chart more clearly.


📉 Risk Disclosure

Trading involves risk.

Market conditions can change quickly, and any analytical output can fail.

Users are responsible for their own decisions, risk management, and trade execution.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

Do not read a wick by itself.

The strongest reads usually come when wick absorption, body reclaim, structure, participation, and room align.

## Source Code

````pine
// --------------------------------------------------
// Wick Absorption Reversal Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Wick Absorption Reversal Planner maps extended wick reactions as absorption
// pockets, evaluates whether the candle body reclaims the reaction zone, and
// organizes reversal readiness, pressure, room, and invalidation into a 0-100
// score. It is designed for wick absorption, candle body reclaim, reversal
// planning, price action, support resistance, and risk-aware market structure.
// Version 1.3 adds owned, collision-safe rail badges and clearer quality-aware
// event history while preserving the original wick, reclaim, scoring, and
// stop-aware room-reach engine.
// --------------------------------------------------

//@version=6
indicator("Wick Absorption Reversal Planner [AGPro Series]",
     shorttitle = "AG Pro WAR",
     overlay = true,
     max_boxes_count = 50,
     max_lines_count = 140,
     max_labels_count = 220)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
G_WICK = "Wick Absorption"
G_REV = "Reversal Logic"
G_VISUAL = "Visuals"
G_PANEL = "Panel"
G_ALERTS = "Alerts"

atrLength = input.int(14, "ATR Length", minval = 1, maxval = 300, group = G_WICK,
     tooltip = "ATR length used to normalize wick size, absorption pockets, failure shelves, labels, and room calculations.")
wickLookback = input.int(34, "Wick Context Lookback", minval = 5, maxval = 300, group = G_WICK,
     tooltip = "Lookback used to compare current wick behavior against recent structure.")
minWickAtr = input.float(0.42, "Minimum Wick ATR", minval = 0.05, step = 0.01, group = G_WICK,
     tooltip = "Minimum wick size measured in ATR required before an absorption pocket can be detected.")
minWickToRange = input.float(0.38, "Minimum Wick / Range", minval = 0.05, maxval = 0.95, step = 0.01, group = G_WICK,
     tooltip = "Minimum wick-to-candle-range ratio required for a meaningful absorption event.")
volumeLength = input.int(24, "Relative Volume Length", minval = 5, maxval = 300, group = G_WICK,
     tooltip = "Lookback used to compare current volume against recent average volume.")
minRelativeVolume = input.float(0.72, "Minimum Relative Volume", minval = 0.10, step = 0.05, group = G_WICK,
     tooltip = "Minimum relative volume used to avoid over-scoring very thin wick reactions.")

minReadyScore = input.int(65, "Minimum Ready Score", minval = 1, maxval = 100, group = G_REV,
     tooltip = "Minimum 0-100 score required before the wick absorption reversal context becomes READY.")
reclaimBufferAtr = input.float(0.05, "Body Reclaim Buffer ATR", minval = 0.00, step = 0.01, group = G_REV,
     tooltip = "ATR buffer beyond the candle body reclaim rail required to confirm a reversal attempt.")
failureBufferAtr = input.float(0.16, "Failure Buffer ATR", minval = 0.00, step = 0.01, group = G_REV,
     tooltip = "ATR buffer beyond the far side of the wick pocket where absorption fails.")
roomLookback = input.int(64, "Room Lookback", minval = 10, maxval = 400, group = G_REV,
     tooltip = "Lookback used to estimate the nearest structure room after a reversal attempt.")
maxPocketAge = input.int(120, "Maximum Pocket Age", minval = 10, maxval = 700, group = G_REV,
     tooltip = "Maximum bars a wick absorption pocket can remain active before it expires.")

showWickPocket = input.bool(true, "Show Wick Pocket", group = G_VISUAL,
     tooltip = "Shows the wick absorption pocket that defines the reaction zone.")
showPocketText = input.bool(true, "Show Centered Pocket Text", group = G_VISUAL,
     tooltip = "Shows a contrast-safe centered badge inside the wick absorption pocket.")
showReclaimRail = input.bool(true, "Show Body Reclaim Rail", group = G_VISUAL,
     tooltip = "Shows the body reclaim rail that price must recover for a reversal attempt.")
showFailureShelf = input.bool(true, "Show Failure Shelf", group = G_VISUAL,
     tooltip = "Shows where the active wick absorption context fails.")
showRoomRail = input.bool(true, "Show Room Rail", group = G_VISUAL,
     tooltip = "Shows the nearest structure-room reference after a reversal attempt.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows absorption, reclaim, pressure, room, and invalidation labels on the chart.")
showAbsorptionLabels = input.bool(true, "Show Absorption Labels", group = G_VISUAL,
     tooltip = "Shows labels when a new wick absorption pocket is detected.")
showReclaimLabels = input.bool(true, "Show Reclaim Labels", group = G_VISUAL,
     tooltip = "Shows labels when price reclaims the candle body rail.")
showPressureLabels = input.bool(false, "Show Pressure Labels", group = G_VISUAL,
     tooltip = "Shows labels when price tests the wick pocket without a clean reclaim. Disabled by default to keep publication screenshots cleaner.")
showRoomLabels = input.bool(true, "Show Room Labels", group = G_VISUAL,
     tooltip = "Shows labels when price reaches the room reference.")
showInvalidLabels = input.bool(false, "Show Invalidation Labels", group = G_VISUAL,
     tooltip = "Shows labels when the active wick absorption context fails. Disabled by default to keep publication screenshots cleaner.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows compact right-side tags for reclaim, failure, and room levels.")
rightTagGapAtr = input.float(0.55, "Right Tag Minimum Gap ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = G_VISUAL,
     tooltip = "Minimum vertical separation between right-side rail badges. The gap scales with ATR and the selected label font size.")
rightTagConnectorBars = input.int(8, "Right Tag Connector Bars", minval = 3, maxval = 30, group = G_VISUAL,
     tooltip = "Length of the owned connector segment used when a right-side badge is moved away from its exact rail price.")
showBarColors = input.bool(false, "Color Bars By State", group = G_VISUAL,
     tooltip = "Colors bars lightly according to the active wick absorption state.")
projectionBars = input.int(72, "Projection Bars", minval = 10, maxval = 400, group = G_VISUAL,
     tooltip = "Number of bars used for projected boxes, rails, and right-side tags.")
labelCooldownBars = input.int(20, "Label Cooldown Bars", minval = 1, maxval = 80, group = G_VISUAL,
     tooltip = "Minimum spacing between repeated event labels.")
maxEventLabels = input.int(9, "Maximum Event Labels", minval = 4, maxval = 80, group = G_VISUAL,
     tooltip = "Maximum historical event labels retained on the chart.")
labelOffsetAtr = input.float(0.82, "Label Offset ATR", minval = 0.05, step = 0.05, group = G_VISUAL,
     tooltip = "ATR-based label offset so labels remain readable above or below candles.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VISUAL,
     tooltip = "Controls chart label and right-side tag font size.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro dashboard panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group = G_PANEL,
     tooltip = "Controls dashboard location.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_PANEL,
     tooltip = "Controls dashboard theme.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_PANEL,
     tooltip = "Controls dashboard font size.")

alertAbsorption = input.bool(true, "Alert: Absorption Pocket", group = G_ALERTS,
     tooltip = "Enables alerts when a new wick absorption pocket is detected.")
alertReclaim = input.bool(true, "Alert: Body Reclaim", group = G_ALERTS,
     tooltip = "Enables alerts when price reclaims the candle body rail.")
alertReady = input.bool(true, "Alert: Ready State", group = G_ALERTS,
     tooltip = "Enables alerts when the wick absorption reversal context reaches READY conditions.")
alertPressure = input.bool(false, "Alert: Pocket Pressure", group = G_ALERTS,
     tooltip = "Enables alerts when price pressures the wick pocket without a clean reclaim.")
alertRoom = input.bool(false, "Alert: Room Rail", group = G_ALERTS,
     tooltip = "Enables alerts when price reaches the structure-room reference.")
alertInvalidated = input.bool(true, "Alert: Absorption Failed", group = G_ALERTS,
     tooltip = "Enables alerts when the active wick absorption context is invalidated.")

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBg = color.rgb(15, 23, 42)
panelBorder = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_score(float value) =>
    int(math.round(f_clamp(value, 0.0, 100.0)))

f_grade(int score) =>
    score >= 85 ? "A+" : score >= 75 ? "A" : score >= 65 ? "B" : score >= 50 ? "C" : "D"

f_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_lane_mult(string sizeInput) =>
    switch sizeInput
        "Tiny" => 0.75
        "Small" => 0.90
        "Large" => 1.25
        "Huge" => 1.55
        => 1.00

f_panel_position(string posInput) =>
    switch posInput
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Right" => position.middle_right
        "Middle Center" => position.middle_center
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Center" => position.bottom_center
        "Bottom Left" => position.bottom_left
        => position.top_right

f_text_on(color bgColor) =>
    float bright = (color.r(bgColor) * 299 + color.g(bgColor) * 587 + color.b(bgColor) * 114) / 1000
    bright >= 145 ? color.rgb(17, 24, 39) : headerText

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
                if math.abs(x - array.get(bars, i)) <= 36 and math.abs(y - array.get(ys, i)) < sep
                    y := y + dir * sep
                    clash := true
        g += 1
    f_reg(x, y, bars, ys)
    y

f_price(float value) =>
    str.tostring(value, format.mintick)

// --------------------------------------------------
// Core calculations
// --------------------------------------------------
atrRaw = ta.atr(atrLength)
atr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
volAvg = ta.sma(volume, volumeLength)
rvol = volAvg > 0.0 ? volume / volAvg : 1.0
barRange = math.max(high - low, syminfo.mintick)
bodyTop = math.max(open, close)
bodyBottom = math.min(open, close)
upperWick = high - bodyTop
lowerWick = bodyBottom - low
upperWickRatio = upperWick / barRange
lowerWickRatio = lowerWick / barRange
upperWickAtr = upperWick / atr
lowerWickAtr = lowerWick / atr
contextHigh = ta.highest(high[1], wickLookback)
contextLow = ta.lowest(low[1], wickLookback)
roomHigh = ta.highest(high[1], roomLookback)
roomLow = ta.lowest(low[1], roomLookback)

bullAbsorptionRaw = lowerWickAtr >= minWickAtr and lowerWickRatio >= minWickToRange and low <= contextLow and close > bodyBottom and rvol >= minRelativeVolume
bearAbsorptionRaw = upperWickAtr >= minWickAtr and upperWickRatio >= minWickToRange and high >= contextHigh and close < bodyTop and rvol >= minRelativeVolume
newAbsorption = bullAbsorptionRaw or bearAbsorptionRaw

var bool hasPocket = false
var int activeDir = 0
var int pocketBar = na
var float pocketTop = na
var float pocketBottom = na
var float reclaimRail = na
var float failureRail = na
var float roomRail = na
var bool roomDone = false
var bool resetAfterRender = false

if newAbsorption
    hasPocket := true
    activeDir := bullAbsorptionRaw ? 1 : -1
    pocketBar := bar_index
    pocketTop := bullAbsorptionRaw ? bodyBottom : high
    pocketBottom := bullAbsorptionRaw ? low : bodyTop
    reclaimRail := bullAbsorptionRaw ? bodyTop + atr * reclaimBufferAtr : bodyBottom - atr * reclaimBufferAtr
    failureRail := bullAbsorptionRaw ? low - atr * failureBufferAtr : high + atr * failureBufferAtr
    roomRail := bullAbsorptionRaw ? roomHigh : roomLow
    roomDone := false

pocketAge = hasPocket and not na(pocketBar) ? bar_index - pocketBar : na
expired = hasPocket and pocketAge > maxPocketAge
insidePocket = hasPocket and high >= pocketBottom and low <= pocketTop
bullReclaim = hasPocket and activeDir == 1 and close > reclaimRail and bar_index > nz(pocketBar, bar_index)
bearReclaim = hasPocket and activeDir == -1 and close < reclaimRail and bar_index > nz(pocketBar, bar_index)
reclaimEvent = (bullReclaim or bearReclaim) and not (bullReclaim[1] or bearReclaim[1])
pressureEvent = hasPocket and insidePocket and not reclaimEvent and not expired
invalidated = hasPocket and activeDir == 1 and close < failureRail or hasPocket and activeDir == -1 and close > failureRail
roomReached = hasPocket and activeDir == 1 and high >= roomRail or hasPocket and activeDir == -1 and low <= roomRail
roomEvent = roomReached and not roomDone

if roomEvent
    roomDone := true

wickScore = activeDir == 1 ? f_clamp(lowerWickAtr * 18.0, 0.0, 24.0) : activeDir == -1 ? f_clamp(upperWickAtr * 18.0, 0.0, 24.0) : 0.0
ratioScore = activeDir == 1 ? f_clamp(lowerWickRatio * 44.0, 0.0, 18.0) : activeDir == -1 ? f_clamp(upperWickRatio * 44.0, 0.0, 18.0) : 0.0
reclaimScoreRaw = activeDir == 1 ? f_clamp((close - reclaimRail) / atr * 24.0, 0.0, 20.0) : activeDir == -1 ? f_clamp((reclaimRail - close) / atr * 24.0, 0.0, 20.0) : 0.0
volumeScore = f_clamp(rvol * 10.0, 0.0, 14.0)
roomAtr = hasPocket ? math.abs(roomRail - close) / atr : na
roomScore = hasPocket ? f_clamp(roomAtr * 5.0, 0.0, 12.0) : 0.0
pressureDistance = hasPocket ? activeDir == 1 ? (close - reclaimRail) / atr : (reclaimRail - close) / atr : na
reversalScore = f_score(18.0 + wickScore + ratioScore + reclaimScoreRaw + volumeScore + roomScore)

readyState = hasPocket and reversalScore >= minReadyScore and not invalidated and not expired and (bullReclaim or bearReclaim)
pocketState = not hasPocket ? "No Pocket" : expired ? "Expired" : activeDir == 1 ? "Bull Wick Absorption" : "Bear Wick Absorption"
pressureText = not hasPocket ? "n/a" : insidePocket ? "Testing Pocket" : pressureDistance >= 0 ? "Holding  " + str.tostring(math.abs(pressureDistance), "#.##") + " ATR" : "Pressured  " + str.tostring(math.abs(pressureDistance), "#.##") + " ATR"
roomText = hasPocket ? str.tostring(roomAtr, "#.##") + " ATR" : "n/a"
scoreText = hasPocket ? str.tostring(reversalScore) + "/100  " + f_grade(reversalScore) : "n/a"
actionState = not hasPocket ? "WAIT" : expired ? "EXPIRED" : invalidated ? "INVALIDATED" : readyState ? "READY" : insidePocket or bullReclaim or bearReclaim ? "MONITOR" : "WAIT"
stateColor = activeDir == 1 ? bullColor : activeDir == -1 ? bearColor : neutralColor
actionColor = actionState == "READY" ? stateColor : actionState == "MONITOR" ? accentColor : actionState == "INVALIDATED" ? bearColor : actionState == "EXPIRED" ? panelBorder : neutralColor
labelSize = f_size(labelSizeInput)
rightEdge = bar_index + projectionBars
tagConnectorSpan = math.min(rightTagConnectorBars, math.max(projectionBars - 2, 2))
tagKneeX = rightEdge - tagConnectorSpan
railRightEdge = showRightTags ? tagKneeX : rightEdge

// --------------------------------------------------
// Room-reach follow-through proof (stop-aware)
// --------------------------------------------------
// After each body reclaim, did price reach the room rail before the failure
// shelf was crossed? Win = room rail first, Loss = failure shelf first, neither
// inside the pocket window = uncounted.
var int   pfTotal  = 0
var int   pfWins   = 0
var bool  pfOpen   = false
var int   pfDir    = 0
var float pfTarget = na
var float pfStop   = na
var int   pfBar    = na

if barstate.isconfirmed
    if pfOpen
        bool pfHitStop   = pfDir == 1 ? close < pfStop : close > pfStop
        bool pfHitTarget = pfDir == 1 ? high >= pfTarget : low <= pfTarget
        if pfHitStop
            pfTotal += 1
            pfOpen  := false
        else if pfHitTarget
            pfTotal += 1
            pfWins  += 1
            pfOpen  := false
        else if not na(pfBar) and bar_index - pfBar > maxPocketAge
            pfOpen := false
    if reclaimEvent and not na(roomRail) and not na(failureRail)
        pfOpen   := true
        pfDir    := activeDir
        pfTarget := roomRail
        pfStop   := failureRail
        pfBar    := bar_index

float pfRate = pfTotal > 0 ? pfWins / pfTotal * 100.0 : na
roomRateText = pfTotal >= 6 ? str.tostring(math.round(pfRate)) + "%  (" + str.tostring(pfTotal) + ")" : "Building (" + str.tostring(pfTotal) + ")"
color roomRateCol = pfTotal >= 6 ? (pfRate >= 55.0 ? bullColor : pfRate >= 45.0 ? neutralColor : bearColor) : (panelTheme == "Dark" ? panelValueCol : color.rgb(15, 23, 42))

// --------------------------------------------------
// Visual objects
// --------------------------------------------------
var box wickBox = na
var line reclaimLine = na
var line failLine = na
var line roomLine = na
var label pocketBadge = na

if hasPocket and showWickPocket and not expired
    if na(wickBox)
        wickBox := box.new(pocketBar, pocketTop, rightEdge, pocketBottom, xloc = xloc.bar_index, bgcolor = color.new(stateColor, 90), border_color = color.new(stateColor, 32), border_width = 1)
    else
        box.set_lefttop(wickBox, pocketBar, pocketTop)
        box.set_rightbottom(wickBox, rightEdge, pocketBottom)
        box.set_bgcolor(wickBox, color.new(stateColor, 90))
        box.set_border_color(wickBox, color.new(stateColor, 32))
    box.set_text(wickBox, "")
    if showPocketText
        int pocketBadgeX = int(math.round((pocketBar + rightEdge) * 0.5))
        float pocketBadgeY = (pocketTop + pocketBottom) * 0.5
        string pocketBadgeText = (activeDir == 1 ? "BULL ABSORPTION" : "BEAR ABSORPTION") + " | " + actionState + (hasPocket ? " | Q " + str.tostring(reversalScore) : "")
        if na(pocketBadge)
            pocketBadge := label.new(pocketBadgeX, pocketBadgeY, pocketBadgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = stateColor, textcolor = f_text_on(stateColor), size = labelSize)
        else
            label.set_x(pocketBadge, pocketBadgeX)
            label.set_y(pocketBadge, pocketBadgeY)
            label.set_text(pocketBadge, pocketBadgeText)
            label.set_color(pocketBadge, stateColor)
            label.set_textcolor(pocketBadge, f_text_on(stateColor))
            label.set_size(pocketBadge, labelSize)
    else if not na(pocketBadge)
        label.delete(pocketBadge)
        pocketBadge := na
else
    if not na(wickBox)
        box.delete(wickBox)
        wickBox := na
    if not na(pocketBadge)
        label.delete(pocketBadge)
        pocketBadge := na

if hasPocket and showReclaimRail and not expired
    if na(reclaimLine)
        reclaimLine := line.new(pocketBar, reclaimRail, railRightEdge, reclaimRail, xloc = xloc.bar_index, extend = extend.none, color = stateColor, width = 2)
    else
        line.set_xy1(reclaimLine, pocketBar, reclaimRail)
        line.set_xy2(reclaimLine, railRightEdge, reclaimRail)
        line.set_color(reclaimLine, stateColor)
        line.set_width(reclaimLine, 2)
else
    if not na(reclaimLine)
        line.delete(reclaimLine)
        reclaimLine := na

if hasPocket and showFailureShelf and not expired
    if na(failLine)
        failLine := line.new(pocketBar, failureRail, railRightEdge, failureRail, xloc = xloc.bar_index, extend = extend.none, color = bearColor, width = 1, style = line.style_dashed)
    else
        line.set_xy1(failLine, pocketBar, failureRail)
        line.set_xy2(failLine, railRightEdge, failureRail)
        line.set_color(failLine, bearColor)
        line.set_style(failLine, line.style_dashed)
else
    if not na(failLine)
        line.delete(failLine)
        failLine := na

if hasPocket and showRoomRail and not expired
    if na(roomLine)
        roomLine := line.new(pocketBar, roomRail, railRightEdge, roomRail, xloc = xloc.bar_index, extend = extend.none, color = neutralColor, width = 1)
    else
        line.set_xy1(roomLine, pocketBar, roomRail)
        line.set_xy2(roomLine, railRightEdge, roomRail)
        line.set_color(roomLine, neutralColor)
else
    if not na(roomLine)
        line.delete(roomLine)
        roomLine := na

// --------------------------------------------------
// Labels
// --------------------------------------------------
labelOffset = atr * labelOffsetAtr
var int lastLabelBar = na
var array<label> eventLabels = array.new<label>()
var float[] lblBars = array.new_float()
var float[] lblYs = array.new_float()

f_push_label(label newLabel) =>
    array.push(eventLabels, newLabel)
    if array.size(eventLabels) > maxEventLabels
        label.delete(array.shift(eventLabels))

if showEventLabels and showAbsorptionLabels and newAbsorption and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
    bool bullEvent = activeDir == 1
    color absCol = bullEvent ? bullColor : bearColor
    float absY = f_resolve_y(bar_index, bullEvent ? low - labelOffset : high + labelOffset, bullEvent ? -1.0 : 1.0, atr * 1.75, lblBars, lblYs)
    label newLabel = label.new(bar_index, absY, (bullEvent ? "BULL ABSORPTION" : "BEAR ABSORPTION") + " | Q " + str.tostring(reversalScore), xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_up : label.style_label_down, color = absCol, textcolor = f_text_on(absCol), size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and showReclaimLabels and reclaimEvent and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
    bool bullEvent = activeDir == 1
    color recCol = bullEvent ? bullColor : bearColor
    float recY = f_resolve_y(bar_index, bullEvent ? low - labelOffset : high + labelOffset, bullEvent ? -1.0 : 1.0, atr * 1.75, lblBars, lblYs)
    label newLabel = label.new(bar_index, recY, (bullEvent ? "BULL RECLAIM" : "BEAR RECLAIM") + " | Q " + str.tostring(reversalScore), xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_up : label.style_label_down, color = recCol, textcolor = f_text_on(recCol), size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and showPressureLabels and pressureEvent and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
    bool bullEvent = activeDir == 1
    float prsY = f_resolve_y(bar_index, bullEvent ? low - labelOffset : high + labelOffset, bullEvent ? -1.0 : 1.0, atr * 1.75, lblBars, lblYs)
    label newLabel = label.new(bar_index, prsY, "POCKET TEST | Q " + str.tostring(reversalScore), xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_up : label.style_label_down, color = accentColor, textcolor = f_text_on(accentColor), size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and showRoomLabels and roomEvent and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
    bool bullEvent = activeDir == 1
    float roomY = f_resolve_y(bar_index, bullEvent ? high + labelOffset : low - labelOffset, bullEvent ? 1.0 : -1.0, atr * 1.75, lblBars, lblYs)
    label newLabel = label.new(bar_index, roomY, "ROOM REACHED | Q " + str.tostring(reversalScore), xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_down : label.style_label_up, color = neutralColor, textcolor = f_text_on(neutralColor), size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and showInvalidLabels and invalidated and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
    bool bullEvent = activeDir == 1
    float invY = f_resolve_y(bar_index, bullEvent ? high + labelOffset : low - labelOffset, bullEvent ? 1.0 : -1.0, atr * 1.75, lblBars, lblYs)
    label newLabel = label.new(bar_index, invY, "ABSORPTION FAILED | Q " + str.tostring(reversalScore), xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_down : label.style_label_up, color = bearColor, textcolor = f_text_on(bearColor), size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index
    resetAfterRender := true

// --------------------------------------------------
// Right-side tags
// --------------------------------------------------
var label reclaimTag = na
var label failTag = na
var label roomTag = na
var line reclaimTagConnector = na
var line failTagConnector = na
var line roomTagConnector = na

f_update_tag(label tag, float y, string txt, color bg) =>
    label result = tag
    if na(result)
        result := label.new(rightEdge, y, txt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = bg, textcolor = f_text_on(bg), size = labelSize)
    else
        label.set_x(result, rightEdge)
        label.set_y(result, y)
        label.set_text(result, txt)
        label.set_color(result, bg)
        label.set_textcolor(result, f_text_on(bg))
        label.set_size(result, labelSize)
    result

f_update_connector(line connector, float railY, float badgeY, color railColor, bool dashed) =>
    line result = connector
    if na(result)
        result := line.new(tagKneeX, railY, rightEdge, badgeY, xloc = xloc.bar_index, extend = extend.none, color = railColor, width = 1, style = dashed ? line.style_dashed : line.style_solid)
    else
        line.set_xy1(result, tagKneeX, railY)
        line.set_xy2(result, rightEdge, badgeY)
        line.set_color(result, railColor)
        line.set_style(result, dashed ? line.style_dashed : line.style_solid)
    result

if showRightTags and hasPocket and not expired
    float tagGap = atr * rightTagGapAtr * f_lane_mult(labelSizeInput)
    float reclaimTagY = reclaimRail
    float failTagY = failureRail
    if math.abs(failTagY - reclaimTagY) < tagGap
        failTagY := activeDir == 1 ? reclaimTagY - tagGap : reclaimTagY + tagGap
    float roomTagY = roomRail
    if showRoomRail
        if math.abs(roomTagY - reclaimTagY) < tagGap
            roomTagY := activeDir == 1 ? reclaimTagY + tagGap : reclaimTagY - tagGap
        if math.abs(roomTagY - failTagY) < tagGap
            roomTagY := activeDir == 1 ? math.max(reclaimTagY, failTagY) + tagGap : math.min(reclaimTagY, failTagY) - tagGap

    reclaimTag := f_update_tag(reclaimTag, reclaimTagY, "BODY RECLAIM | " + f_price(reclaimRail), stateColor)
    failTag := f_update_tag(failTag, failTagY, "FAILURE | " + f_price(failureRail), bearColor)
    reclaimTagConnector := f_update_connector(reclaimTagConnector, reclaimRail, reclaimTagY, stateColor, false)
    failTagConnector := f_update_connector(failTagConnector, failureRail, failTagY, bearColor, true)
    if showRoomRail
        roomTag := f_update_tag(roomTag, roomTagY, "ROOM | " + f_price(roomRail), neutralColor)
        roomTagConnector := f_update_connector(roomTagConnector, roomRail, roomTagY, neutralColor, false)
    else
        if not na(roomTag)
            label.delete(roomTag)
            roomTag := na
        if not na(roomTagConnector)
            line.delete(roomTagConnector)
            roomTagConnector := na
else
    if not na(reclaimTag)
        label.delete(reclaimTag)
        reclaimTag := na
    if not na(failTag)
        label.delete(failTag)
        failTag := na
    if not na(roomTag)
        label.delete(roomTag)
        roomTag := na
    if not na(reclaimTagConnector)
        line.delete(reclaimTagConnector)
        reclaimTagConnector := na
    if not na(failTagConnector)
        line.delete(failTagConnector)
        failTagConnector := na
    if not na(roomTagConnector)
        line.delete(roomTagConnector)
        roomTagConnector := na

// --------------------------------------------------
// Panel
// --------------------------------------------------
panelPos = f_panel_position(panelPositionInput)
panelSize = f_size(panelFontSizeInput)
panelLeftFinal = panelTheme == "Dark" ? color.rgb(51, 65, 85) : color.rgb(226, 232, 240)
panelBgFinal = panelTheme == "Dark" ? panelBg : color.rgb(248, 250, 252)
panelLabelFinal = panelTheme == "Dark" ? panelLabelCol : color.rgb(71, 85, 105)
panelValueFinal = panelTheme == "Dark" ? panelValueCol : color.rgb(15, 23, 42)

var table panel = table.new(panelPos, 2, 7, border_width = 1, border_color = panelBorder)

if barstate.islast
    if showPanel
        table.clear(panel, 0, 0, 1, 6)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Wick Absorption Reversal Planner", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
        table.cell(panel, 0, 1, "Pocket", text_color = panelLabelFinal, bgcolor = panelLeftFinal, text_size = panelSize)
        table.cell(panel, 1, 1, pocketState, text_color = panelValueFinal, bgcolor = panelBgFinal, text_size = panelSize)
        table.cell(panel, 0, 2, "Reversal Score", text_color = panelLabelFinal, bgcolor = panelLeftFinal, text_size = panelSize)
        table.cell(panel, 1, 2, scoreText, text_color = f_text_on(stateColor), bgcolor = stateColor, text_size = panelSize)
        table.cell(panel, 0, 3, "Pressure", text_color = panelLabelFinal, bgcolor = panelLeftFinal, text_size = panelSize)
        table.cell(panel, 1, 3, pressureText, text_color = panelValueFinal, bgcolor = panelBgFinal, text_size = panelSize)
        table.cell(panel, 0, 4, "Room", text_color = panelLabelFinal, bgcolor = panelLeftFinal, text_size = panelSize)
        table.cell(panel, 1, 4, roomText, text_color = panelValueFinal, bgcolor = panelBgFinal, text_size = panelSize)
        table.cell(panel, 0, 5, "Room Rate", text_color = panelLabelFinal, bgcolor = panelLeftFinal, text_size = panelSize)
        table.cell(panel, 1, 5, roomRateText, text_color = roomRateCol, bgcolor = panelBgFinal, text_size = panelSize)
        table.cell(panel, 0, 6, "Action", text_color = panelLabelFinal, bgcolor = panelLeftFinal, text_size = panelSize)
        table.cell(panel, 1, 6, actionState, text_color = f_text_on(actionColor), bgcolor = actionColor, text_size = panelSize)
    else
        table.clear(panel, 0, 0, 1, 6)

barStateColor = actionState == "READY" ? color.new(stateColor, 72) : actionState == "MONITOR" ? color.new(accentColor, 78) : actionState == "INVALIDATED" ? color.new(bearColor, 70) : na
barcolor(showBarColors ? barStateColor : na)

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(alertAbsorption and newAbsorption and activeDir == 1, "AG Pro WAR | BULL WICK ABSORPTION", "AG Pro WAR: A bullish wick absorption pocket has been detected.")
alertcondition(alertAbsorption and newAbsorption and activeDir == -1, "AG Pro WAR | BEAR WICK ABSORPTION", "AG Pro WAR: A bearish wick absorption pocket has been detected.")
alertcondition(alertReclaim and reclaimEvent and activeDir == 1, "AG Pro WAR | BULL BODY RECLAIM", "AG Pro WAR: Bullish body reclaim appeared after wick absorption.")
alertcondition(alertReclaim and reclaimEvent and activeDir == -1, "AG Pro WAR | BEAR BODY RECLAIM", "AG Pro WAR: Bearish body reclaim appeared after wick absorption.")
alertcondition(alertReady and readyState and activeDir == 1, "AG Pro WAR | BULL READY", "AG Pro WAR: Bullish wick absorption reversal context is READY.")
alertcondition(alertReady and readyState and activeDir == -1, "AG Pro WAR | BEAR READY", "AG Pro WAR: Bearish wick absorption reversal context is READY.")
alertcondition(alertPressure and pressureEvent, "AG Pro WAR | POCKET PRESSURE", "AG Pro WAR: Price is pressuring the active wick absorption pocket.")
alertcondition(alertRoom and roomEvent, "AG Pro WAR | ROOM RAIL", "AG Pro WAR: Price reached the active room reference.")
alertcondition(alertInvalidated and invalidated, "AG Pro WAR | ABSORPTION FAILED", "AG Pro WAR: The active wick absorption context has been invalidated.")

if invalidated and not resetAfterRender
    resetAfterRender := true

if resetAfterRender
    hasPocket := false
    activeDir := 0
    pocketBar := na
    pocketTop := na
    pocketBottom := na
    reclaimRail := na
    failureRail := na
    roomRail := na
    roomDone := false
    resetAfterRender := false
````

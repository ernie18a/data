# Trend Exhaustion Snapback Planner [AGPro Series]

- url: https://www.tradingview.com/script/91VBveta-Trend-Exhaustion-Snapback-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;c180cca38c474e0f80e284050ae9c509
- version: 3.0

## Description

Trend Exhaustion Snapback Planner [AGPro Series]

🧠 Core Idea

Is the current trend stretch becoming snapback-ready, or is momentum still supported enough to avoid calling exhaustion too early?


📌 Overview / What it does

Trend Exhaustion Snapback Planner [AGPro Series] is a rule-based trend exhaustion and mean-reversion planning tool. It measures how far price has stretched away from its trend mean, then evaluates whether that stretch is supported by pressure, efficiency loss, wick behavior, and room back toward value.

The script produces an exhaustion pocket, snapback rail, failure rail, room reference, event labels, right-side tags, optional bar coloring, and a compact AG Pro dashboard with a 0-100 Snapback Score.

It does not predict reversals. It helps organize trend stretch, exhaustion quality, snapback reclaim behavior, failure risk, and next-action state.


🎯 Purpose & Design Philosophy

Strong trends can stay stretched for longer than expected. At the same time, many reversals begin only after a trend becomes inefficient and price starts moving back toward value.

This script was built to help traders review that transition without relying on a simple overbought or oversold reading.

It supports a patient workflow: identify stretch, wait for reclaim behavior, evaluate room, then interpret the active state within broader market context.


⚡ Why This Script Is Different

Most exhaustion tools focus on RSI extremes, distance from a moving average, or isolated reversal candles.

This script does NOT treat every stretched move as a reversal.

Instead, it maps a live exhaustion pocket, scores stretch quality, tracks snapback reclaim behavior, defines where the idea fails, and shows whether there is room back toward the trend mean.


⚙️ Methodology

1. Trend Stretch Detection

The script measures price distance from a trend mean using ATR normalization.

2. Pressure Evaluation

RSI pressure, wick behavior, and trend-efficiency loss are reviewed to decide whether the extension is weakening.

3. Snapback Rail Mapping

Once a valid exhaustion pocket appears, the snapback rail becomes the first reclaim threshold.

4. Risk / Room Structure

The failure rail marks continuation risk, while the room rail shows the value or structure reference that price may test after reclaim.

5. Visual Output

The chart receives the exhaustion pocket, trend mean, snapback rail, failure rail, room rail, event labels, right-side tags, optional bar coloring, and dashboard panel.


🗺️ How to Read the Chart

The exhaustion pocket marks the stretch area created after price moves far away from its trend mean.

The snapback rail shows the reclaim level that improves the snapback context.

The failure rail marks where continuation risk invalidates the active snapback idea.

The room rail shows the next value or structure reference after the snapback begins.

Labels highlight stretch pockets, snapback reclaim, pocket pressure, room tests, and failed snapbacks.

Colors represent context:

• Teal → bullish snapback context

• Pink → bearish snapback context or failure

• Gold → room, waiting, or neutral review

• Indigo → pocket pressure or monitoring context

The panel summarizes:

• Pocket

• Snapback Score

• Stretch

• Room

• Action


🚦 Signals & States

• Bull Snapback Pocket → downside trend stretch with bullish snapback context

• Bear Snapback Pocket → upside trend stretch with bearish snapback context

• Snapback Reclaim → price reclaimed the active snapback rail

• Pocket Pressure → price is testing the exhaustion pocket without clean reclaim

• Room Test → price reached the active room reference

• Failed → price crossed the failure rail

• READY → reclaim and score quality are strong enough to monitor

• MONITOR → snapback context is active but not fully ready

• WAIT RECLAIM → pocket exists but reclaim has not confirmed

• EXPIRED → the pocket is too old to remain active


🔔 Alerts Logic

Alerts can trigger when a bullish or bearish snapback pocket appears, when price reclaims the snapback rail, when the READY state appears, when pocket pressure appears, when the room rail is reached, or when the context fails.

Alerts are attention markers only. They are not trade instructions.


🧩 Confluence Logic

The context becomes stronger when ATR stretch, RSI pressure, wick behavior, efficiency loss, snapback reclaim, and room back toward value align.

No single condition is treated as enough by itself.


📊 When to Use

• Mature directional moves

• Strong extensions away from trend mean

• Markets with visible impulse and reaction structure

• 1H, 4H, and 1D review where exhaustion context matters

• Crypto, indices, forex, and liquid stocks


⚠️ When NOT to Use

• Extremely illiquid symbols

• Very low-volume periods

• News shock candles with abnormal gaps

• Very tight ranges with no meaningful trend stretch

• Markets where spreads or wicks dominate the structure


🎛️ Key Inputs

• ATR Length → normalizes trend stretch and rail distances

• Trend Mean Length → controls the main value reference

• Minimum Stretch ATR → controls how stretched price must be before a pocket appears

• RSI Pressure → controls pressure thresholds for extended conditions

• Efficiency Length → controls how trend efficiency loss is measured

• Minimum Ready Score → controls how strict READY classification is

• Projection Bars → controls how far rails and zones extend

• Visual settings → control labels, tags, panel location, theme, and font size


🖥️ Interface & Visual Design

The panel is designed as a compact decision dashboard, not a large data table.

The first row uses a merged AG Pro header. The remaining rows show the pocket state, score, stretch context, room, and action.

The visual hierarchy is built so traders can read the active plan quickly without losing chart structure.


🧪 Practical Usage Workflow

1. Read the panel.

2. Check whether an exhaustion pocket is active.

3. Watch the snapback rail for reclaim behavior.

4. Review failure risk and room back toward value.

5. Interpret labels as context markers, not trade commands.


🔍 Interpretation Guidelines

A high score means the active stretch has multiple snapback conditions aligned.

A snapback reclaim improves the context, but it does not guarantee continuation toward the room rail.

A failed state means price crossed the continuation-risk boundary for that active pocket.

Use the script to organize the question, not to outsource the answer.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an automated trading system.

It does not place orders.

It does not guarantee reversal timing, target reach, or profitability.


⚠️ Limitations & Transparency

Trend exhaustion can remain extended for long periods.

Different timeframes may show different exhaustion and snapback contexts.

Volatility spikes can distort ATR-normalized distance.

Low liquidity can create false stretch pockets or unreliable wick behavior.

The script is rule-based and should be interpreted within broader market context.


🧠 Market Context Notes

Trend exhaustion is not the same as trend reversal.

The most useful snapback contexts often appear when price stretches away from value, momentum efficiency weakens, and reclaim behavior begins before the failure rail breaks.

The strongest readings usually come from alignment between structure, volatility, and reaction quality.


🧾 Use Case Examples

When price stretches far above the trend mean, RSI pressure rises, and the candle begins reclaiming back through the snapback rail, the bearish snapback context may become more meaningful.

When price stretches below the trend mean but cannot reclaim the snapback rail, the script may remain in WAIT RECLAIM or PRESSURE instead of READY.

When price reaches the room rail after reclaim, the context shifts into room review rather than fresh entry signaling.


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

Use this tool to study how trend stretch, momentum pressure, efficiency loss, and snapback behavior interact across different markets and timeframes.

## Source Code

````pine
// --------------------------------------------------
// Trend Exhaustion Snapback Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.2
//
// Maps stretched trend extensions, momentum efficiency loss, RSI pressure,
// distance from trend mean, snapback reclaim quality, failure continuation
// risk, and room back toward value. It scores each exhaustion pocket 0-100,
// reports a stop-aware Snapback Hit Rate (room reached before failure), and
// gives a clear action read for trend exhaustion, snapback planning, mean
// reversion, and volatility context, without acting as a prediction or strategy.
// --------------------------------------------------

//@version=6
indicator("Trend Exhaustion Snapback Planner [AGPro Series]",
     shorttitle = "AG Pro TES",
     overlay = true,
     max_boxes_count = 50,
     max_lines_count = 140,
     max_labels_count = 240)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
G_EXHAUST = "Exhaustion Engine"
G_SNAP = "Snapback Logic"
G_VISUAL = "Visuals"
G_PANEL = "Panel"
G_ALERTS = "Alerts"

atrLength = input.int(14, "ATR Length", minval = 1, maxval = 300, group = G_EXHAUST,
     tooltip = "ATR length used to normalize trend stretch, snapback rails, labels, failure distance, and room calculations.")
trendLength = input.int(55, "Trend Mean Length", minval = 5, maxval = 400, group = G_EXHAUST,
     tooltip = "EMA length used as the primary trend mean. Exhaustion is measured by distance from this mean.")
fastTrendLength = input.int(21, "Fast Trend Length", minval = 3, maxval = 200, group = G_EXHAUST,
     tooltip = "Fast EMA length used to evaluate whether the current stretch still has directional trend support.")
stretchLookback = input.int(34, "Stretch Lookback", minval = 10, maxval = 300, group = G_EXHAUST,
     tooltip = "Lookback used to compare current extension against recent stretched conditions.")
minStretchAtr = input.float(1.25, "Minimum Stretch ATR", minval = 0.20, maxval = 8.0, step = 0.05, group = G_EXHAUST,
     tooltip = "Minimum distance from the trend mean, measured in ATR, required before an exhaustion pocket can be considered.")
rsiLength = input.int(14, "RSI Length", minval = 2, maxval = 100, group = G_EXHAUST,
     tooltip = "RSI length used to detect pressure at extended trend conditions.")
upperRsiPressure = input.float(66.0, "Upper RSI Pressure", minval = 50.0, maxval = 95.0, step = 0.5, group = G_EXHAUST,
     tooltip = "RSI threshold that strengthens bearish snapback context after an upside trend stretch.")
lowerRsiPressure = input.float(34.0, "Lower RSI Pressure", minval = 5.0, maxval = 50.0, step = 0.5, group = G_EXHAUST,
     tooltip = "RSI threshold that strengthens bullish snapback context after a downside trend stretch.")
efficiencyLength = input.int(12, "Efficiency Length", minval = 3, maxval = 80, group = G_EXHAUST,
     tooltip = "Lookback used to compare net trend progress against total price travel. Falling efficiency can indicate exhaustion.")

minReadyScore = input.int(66, "Minimum Ready Score", minval = 1, maxval = 100, group = G_SNAP,
     tooltip = "Minimum 0-100 score required before the snapback context becomes READY.")
snapbackBufferAtr = input.float(0.06, "Snapback Reclaim Buffer ATR", minval = 0.00, maxval = 1.0, step = 0.01, group = G_SNAP,
     tooltip = "ATR buffer beyond the snapback rail required to confirm a reclaim attempt.")
failureBufferAtr = input.float(0.22, "Failure Buffer ATR", minval = 0.00, maxval = 2.0, step = 0.01, group = G_SNAP,
     tooltip = "ATR buffer beyond the far side of the exhaustion pocket where the snapback context fails. This is also the stop used by the Snapback Hit Rate.")
roomLookback = input.int(72, "Room Lookback", minval = 10, maxval = 500, group = G_SNAP,
     tooltip = "Lookback used to estimate room back toward value or nearby structure after a snapback attempt. This is also the target used by the Snapback Hit Rate.")
maxPocketAge = input.int(140, "Maximum Pocket Age", minval = 10, maxval = 800, group = G_SNAP,
     tooltip = "Maximum bars an exhaustion pocket can remain active before it expires. Pockets that neither reach room nor fail within this window are left uncounted by the Hit Rate.")

showPocket = input.bool(true, "Show Exhaustion Pocket", group = G_VISUAL,
     tooltip = "Shows the active stretch pocket created by trend exhaustion.")
showPocketText = input.bool(true, "Show Centered Pocket Badge", group = G_VISUAL,
     tooltip = "Shows a separate centered badge inside the exhaustion pocket.")
showMean = input.bool(true, "Show Trend Mean", group = G_VISUAL,
     tooltip = "Shows the trend mean used as the main value reference.")
showSnapRail = input.bool(true, "Show Snapback Rail", group = G_VISUAL,
     tooltip = "Shows the first reclaim rail that improves snapback context.")
showFailureRail = input.bool(true, "Show Failure Rail", group = G_VISUAL,
     tooltip = "Shows where the active snapback context fails and continuation risk increases.")
showRoomRail = input.bool(true, "Show Room Rail", group = G_VISUAL,
     tooltip = "Shows the nearest room reference after a snapback attempt.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows stretch, snapback, pressure, room, and failed snapback labels on the chart.")
showStretchLabels = input.bool(true, "Show Stretch Labels", group = G_VISUAL,
     tooltip = "Shows labels when a new trend exhaustion pocket is detected.")
showSnapLabels = input.bool(true, "Show Snapback Labels", group = G_VISUAL,
     tooltip = "Shows labels when price reclaims the snapback rail.")
showPressureLabels = input.bool(false, "Show Pressure Labels", group = G_VISUAL,
     tooltip = "Shows labels when price pressures the exhaustion pocket without a clean snapback. Disabled by default for cleaner publication screenshots.")
showRoomLabels = input.bool(true, "Show Room Labels", group = G_VISUAL,
     tooltip = "Shows labels when price reaches the active room reference.")
showInvalidLabels = input.bool(true, "Show Failed Labels", group = G_VISUAL,
     tooltip = "Shows labels when the active snapback context fails.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows compact right-side tags for snapback, failure, and room levels.")
showBarColors = input.bool(false, "Color Bars By State", group = G_VISUAL,
     tooltip = "Colors bars lightly according to the active snapback state.")
projectionBars = input.int(76, "Projection Bars", minval = 10, maxval = 400, group = G_VISUAL,
     tooltip = "Number of bars used for projected boxes, rails, and right-side tags.")
labelCooldownBars = input.int(28, "Label Cooldown Bars", minval = 1, maxval = 100, group = G_VISUAL,
     tooltip = "Minimum spacing between repeated event labels. Higher values reduce label density on lower timeframes.")
maxEventLabels = input.int(12, "Maximum Event Labels", minval = 4, maxval = 80, group = G_VISUAL,
     tooltip = "Maximum historical event labels retained on the chart.")
labelOffsetAtr = input.float(0.68, "Label Offset ATR", minval = 0.05, maxval = 5.0, step = 0.05, group = G_VISUAL,
     tooltip = "ATR-based label offset so labels remain readable above or below candles.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VISUAL,
     tooltip = "Controls chart label, centered badge, and right-side tag font size.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro dashboard panel.")
panelPositionInput = input.string("Top Right", "Panel Location",
     options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"],
     group = G_PANEL,
     tooltip = "Controls dashboard location.")
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = G_PANEL,
     tooltip = "Controls dashboard theme.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_PANEL,
     tooltip = "Controls dashboard font size.")

alertStretch = input.bool(true, "Alert: Exhaustion Pocket", group = G_ALERTS,
     tooltip = "Enables alerts when a new trend exhaustion pocket is detected.")
alertSnapback = input.bool(true, "Alert: Snapback Reclaim", group = G_ALERTS,
     tooltip = "Enables alerts when price reclaims the snapback rail.")
alertReady = input.bool(true, "Alert: Ready State", group = G_ALERTS,
     tooltip = "Enables alerts when the snapback context reaches READY conditions.")
alertPressure = input.bool(false, "Alert: Pocket Pressure", group = G_ALERTS,
     tooltip = "Enables alerts when price pressures the exhaustion pocket without a clean reclaim.")
alertRoom = input.bool(false, "Alert: Room Rail", group = G_ALERTS,
     tooltip = "Enables alerts when price reaches the active room reference.")
alertFailed = input.bool(true, "Alert: Failed Snapback", group = G_ALERTS,
     tooltip = "Enables alerts when the active snapback context is invalidated.")

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBorder = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)
inkDark = color.rgb(15, 23, 42)
inkLight = color.rgb(245, 247, 250)

// --------------------------------------------------
// Helpers
// --------------------------------------------------
// Luminance-aware text color: dark ink on light fills, light ink on dark fills.
f_text_on(color bg) =>
    float r = color.r(bg)
    float g = color.g(bg)
    float b = color.b(bg)
    float lum = 0.299 * r + 0.587 * g + 0.114 * b
    lum > 145 ? inkDark : inkLight

f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_score(float value) =>
    int(math.round(f_clamp(value, 0.0, 100.0)))

f_grade(int score) =>
    score >= 85 ? "A+" : score >= 75 ? "A" : score >= 65 ? "B" : score >= 50 ? "C" : "D"

f_size(string sizeInput) =>
    sizeInput == "Tiny" ? size.tiny :
     sizeInput == "Small" ? size.small :
     sizeInput == "Large" ? size.large :
     sizeInput == "Huge" ? size.huge : size.normal

f_panel_position(string posInput) =>
    posInput == "Top Left" ? position.top_left :
     posInput == "Top Center" ? position.top_center :
     posInput == "Middle Right" ? position.middle_right :
     posInput == "Middle Center" ? position.middle_center :
     posInput == "Middle Left" ? position.middle_left :
     posInput == "Bottom Right" ? position.bottom_right :
     posInput == "Bottom Center" ? position.bottom_center :
     posInput == "Bottom Left" ? position.bottom_left : position.top_right

f_panel_bg() =>
    panelTheme == "Clean Light" ? color.rgb(248, 250, 252) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : color.rgb(15, 23, 42)

f_panel_label_bg() =>
    panelTheme == "Clean Light" ? color.rgb(226, 232, 240) : panelTheme == "Slate" ? color.rgb(51, 65, 85) : color.rgb(51, 65, 85)

f_panel_text() =>
    panelTheme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_panel_label() =>
    panelTheme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_border() =>
    panelTheme == "Clean Light" ? color.rgb(203, 213, 225) : panelBorder

f_price(float value) =>
    str.tostring(value, format.mintick)

// --------------------------------------------------
// Core calculations
// --------------------------------------------------
atr = ta.atr(atrLength)
atrSafe = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
mean = ta.ema(close, trendLength)
fastMean = ta.ema(close, fastTrendLength)
rsi = ta.rsi(close, rsiLength)
stretchAtr = (close - mean) / atrSafe
absStretch = math.abs(stretchAtr)
stretchRank = ta.highest(absStretch[1], stretchLookback)

travel = ta.sma(math.abs(ta.change(close)), efficiencyLength) * efficiencyLength
netMove = math.abs(close - close[efficiencyLength])
efficiency = travel > 0.0 ? netMove / travel : 0.0
efficiencyLoss = 1.0 - efficiency

barRange = math.max(high - low, syminfo.mintick)
bodyTop = math.max(open, close)
bodyBottom = math.min(open, close)
upperWick = high - bodyTop
lowerWick = bodyBottom - low
upperWickRatio = upperWick / barRange
lowerWickRatio = lowerWick / barRange

trendUp = fastMean >= mean
trendDown = fastMean <= mean
pressureUp = rsi >= upperRsiPressure
pressureDown = rsi <= lowerRsiPressure
extensionStrong = absStretch >= minStretchAtr and (na(stretchRank) or absStretch >= stretchRank * 0.82)

bearStretchRaw = trendUp and stretchAtr >= minStretchAtr and extensionStrong and (pressureUp or upperWickRatio >= 0.30 or efficiencyLoss >= 0.35)
bullStretchRaw = trendDown and stretchAtr <= -minStretchAtr and extensionStrong and (pressureDown or lowerWickRatio >= 0.30 or efficiencyLoss >= 0.35)
newStretch = bearStretchRaw or bullStretchRaw

roomHigh = ta.highest(high[1], roomLookback)
roomLow = ta.lowest(low[1], roomLookback)

// --------------------------------------------------
// Active pocket state
// --------------------------------------------------
var bool hasPocket = false
var int activeDir = 0
var int pocketBar = na
var float pocketTop = na
var float pocketBottom = na
var float snapRail = na
var float failureRail = na
var float roomRail = na
var bool snapConfirmed = false
var bool failed = false
var bool roomReached = false
var int lastLabelBar = na

if newStretch
    hasPocket := true
    activeDir := bullStretchRaw ? 1 : -1
    pocketBar := bar_index
    pocketTop := high
    pocketBottom := low
    snapRail := activeDir == 1 ? bodyTop + snapbackBufferAtr * atrSafe : bodyBottom - snapbackBufferAtr * atrSafe
    failureRail := activeDir == 1 ? low - failureBufferAtr * atrSafe : high + failureBufferAtr * atrSafe
    roomRail := activeDir == 1 ? math.min(mean, roomHigh) : math.max(mean, roomLow)
    snapConfirmed := false
    failed := false
    roomReached := false

pocketAge = hasPocket ? bar_index - pocketBar : na
expired = hasPocket and pocketAge > maxPocketAge

if hasPocket and not expired
    if activeDir == 1 and close >= snapRail
        snapConfirmed := true
    if activeDir == -1 and close <= snapRail
        snapConfirmed := true
    if activeDir == 1 and low <= failureRail
        failed := true
    if activeDir == -1 and high >= failureRail
        failed := true
    if activeDir == 1 and high >= roomRail
        roomReached := true
    if activeDir == -1 and low <= roomRail
        roomReached := true

activePocket = hasPocket and not expired and not failed
rightEdge = bar_index + projectionBars

// --------------------------------------------------
// Snapback Hit Rate (stop-aware, confirmed-bar gated, resolve-then-open)
// Of past exhaustion pockets, how many reached the room reference (back toward
// value) before hitting the failure rail. Targets and stops are frozen at the
// pocket's detection bar. A new pocket supersedes an unresolved one (uncounted).
// --------------------------------------------------
var int snapWins = 0
var int snapTotal = 0
var bool snapPending = false
var int snapPendingDir = 0
var float snapRoomTarget = na
var float snapFailStop = na
var int snapPendingBar = na

if barstate.isconfirmed
    if snapPending
        bool hitRoom = snapPendingDir == 1 ? high >= snapRoomTarget : low <= snapRoomTarget
        bool hitFail = snapPendingDir == 1 ? low <= snapFailStop : high >= snapFailStop
        if hitRoom
            snapWins += 1
            snapTotal += 1
            snapPending := false
        else if hitFail
            snapTotal += 1
            snapPending := false
        else if not na(snapPendingBar) and bar_index - snapPendingBar >= maxPocketAge
            snapPending := false
    if newStretch
        if snapPending
            snapPending := false
        snapPendingDir := bullStretchRaw ? 1 : -1
        snapRoomTarget := roomRail
        snapFailStop := failureRail
        snapPendingBar := bar_index
        snapPending := not na(roomRail) and not na(failureRail)

int snapPct = snapTotal > 0 ? int(math.round(snapWins / snapTotal * 100.0)) : na
bool snapBuilding = snapTotal < 6
string hitRateText = snapBuilding ? "Building (" + str.tostring(snapTotal) + ")" : str.tostring(snapPct) + "% (" + str.tostring(snapTotal) + ")"
color hitRateColor = snapBuilding ? neutralColor : snapPct >= 55 ? bullColor : snapPct >= 40 ? neutralColor : bearColor

// --------------------------------------------------
// Score and states
// --------------------------------------------------
stretchScore = hasPocket ? f_clamp(absStretch / math.max(minStretchAtr, 0.01) * 28.0, 0.0, 28.0) : 0.0
pressureScore = hasPocket ? activeDir == 1 ? f_clamp((lowerRsiPressure - rsi) / math.max(lowerRsiPressure, 1.0) * 20.0 + lowerWickRatio * 10.0, 0.0, 25.0) : f_clamp((rsi - upperRsiPressure) / math.max(100.0 - upperRsiPressure, 1.0) * 20.0 + upperWickRatio * 10.0, 0.0, 25.0) : 0.0
efficiencyScore = hasPocket ? f_clamp(efficiencyLoss * 24.0, 0.0, 20.0) : 0.0
snapScore = hasPocket ? snapConfirmed ? 20.0 : activeDir == 1 ? f_clamp((close - pocketBottom) / math.max(snapRail - pocketBottom, syminfo.mintick) * 14.0, 0.0, 14.0) : f_clamp((pocketTop - close) / math.max(pocketTop - snapRail, syminfo.mintick) * 14.0, 0.0, 14.0) : 0.0
roomScore = hasPocket ? activeDir == 1 ? f_clamp((roomRail - close) / atrSafe * 4.0, 0.0, 7.0) : f_clamp((close - roomRail) / atrSafe * 4.0, 0.0, 7.0) : 0.0
agePenalty = hasPocket ? f_clamp(pocketAge / math.max(maxPocketAge, 1) * 8.0, 0.0, 8.0) : 0.0
rawScore = stretchScore + pressureScore + efficiencyScore + snapScore + roomScore - agePenalty
snapScoreFinal = hasPocket and not expired ? f_score(rawScore) : 0
grade = f_grade(snapScoreFinal)

pocketState = not hasPocket ? "No Pocket" : expired ? "Expired" : failed ? "Failed" : activeDir == 1 ? "Bull Snapback" : "Bear Snapback"
pressureText = not hasPocket ? "n/a" : str.tostring(absStretch, "0.00") + " ATR  Eff " + str.tostring(efficiency, "0.00")
roomText = not hasPocket or expired ? "n/a" : str.tostring(math.abs(roomRail - close) / atrSafe, "0.00") + " ATR"

readyState = activePocket and snapConfirmed and snapScoreFinal >= minReadyScore and not roomReached
pressureState = activePocket and not snapConfirmed and (activeDir == 1 ? low <= pocketBottom + (pocketTop - pocketBottom) * 0.40 : high >= pocketTop - (pocketTop - pocketBottom) * 0.40)

actionState = "WAIT"
if expired
    actionState := "EXPIRED"
else if failed
    actionState := "FAILED"
else if roomReached
    actionState := "ROOM TEST"
else if readyState
    actionState := "READY"
else if snapConfirmed
    actionState := "MONITOR"
else if pressureState
    actionState := "PRESSURE"
else if hasPocket
    actionState := "WAIT RECLAIM"

stateColor = not hasPocket or expired ? neutralColor : failed ? bearColor : readyState ? bullColor : snapConfirmed ? bullColor : pressureState ? accentColor : neutralColor
actionColor = actionState == "READY" ? bullColor : actionState == "FAILED" ? bearColor : actionState == "ROOM TEST" ? neutralColor : actionState == "PRESSURE" ? accentColor : neutralColor
scoreText = hasPocket and not expired ? str.tostring(snapScoreFinal) + "/100  " + grade : "n/a"

snapPrev = bar_index > 0 ? snapConfirmed[1] : false
failedPrev = bar_index > 0 ? failed[1] : false
roomPrev = bar_index > 0 ? roomReached[1] : false
readyPrev = bar_index > 0 ? readyState[1] : false
pressurePrev = bar_index > 0 ? pressureState[1] : false

snapEvent = activePocket and snapConfirmed and not snapPrev
failedEvent = hasPocket and failed and not failedPrev
roomEvent = activePocket and roomReached and not roomPrev
readyEvent = readyState and not readyPrev
pressureEvent = pressureState and not pressurePrev

// --------------------------------------------------
// Drawings
// --------------------------------------------------
plot(showMean ? mean : na, "Trend Mean", color = color.new(accentColor, 0), linewidth = 1)

var box pocketBox = na
var label pocketBadge = na
var line snapLine = na
var line failLine = na
var line roomLine = na

if activePocket and showPocket
    if na(pocketBox)
        pocketBox := box.new(pocketBar, pocketTop, rightEdge, pocketBottom, xloc = xloc.bar_index, bgcolor = color.new(stateColor, 84), border_color = color.new(stateColor, 30), border_width = 1)
    else
        box.set_lefttop(pocketBox, pocketBar, pocketTop)
        box.set_rightbottom(pocketBox, rightEdge, pocketBottom)
        box.set_bgcolor(pocketBox, color.new(stateColor, 84))
        box.set_border_color(pocketBox, color.new(stateColor, 30))
else
    if not na(pocketBox)
        box.delete(pocketBox)
        pocketBox := na

if activePocket and showPocket and showPocketText
    badgeX = pocketBar + int(math.round((rightEdge - pocketBar) * 0.50))
    badgeY = (pocketTop + pocketBottom) / 2.0
    badgeText = activeDir == 1 ? "BULL SNAPBACK\nPOCKET" : "BEAR SNAPBACK\nPOCKET"
    if na(pocketBadge)
        pocketBadge := label.new(badgeX, badgeY, badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(stateColor, 0), textcolor = f_text_on(stateColor), size = f_size(labelSizeInput))
    else
        label.set_x(pocketBadge, badgeX)
        label.set_y(pocketBadge, badgeY)
        label.set_text(pocketBadge, badgeText)
        label.set_color(pocketBadge, color.new(stateColor, 0))
        label.set_textcolor(pocketBadge, f_text_on(stateColor))
        label.set_size(pocketBadge, f_size(labelSizeInput))
else
    if not na(pocketBadge)
        label.delete(pocketBadge)
        pocketBadge := na

if activePocket and showSnapRail
    if na(snapLine)
        snapLine := line.new(pocketBar, snapRail, rightEdge, snapRail, xloc = xloc.bar_index, extend = extend.none, color = stateColor, width = 2)
    else
        line.set_xy1(snapLine, pocketBar, snapRail)
        line.set_xy2(snapLine, rightEdge, snapRail)
        line.set_color(snapLine, stateColor)
else
    if not na(snapLine)
        line.delete(snapLine)
        snapLine := na

if activePocket and showFailureRail
    if na(failLine)
        failLine := line.new(pocketBar, failureRail, rightEdge, failureRail, xloc = xloc.bar_index, extend = extend.none, color = bearColor, width = 1, style = line.style_dashed)
    else
        line.set_xy1(failLine, pocketBar, failureRail)
        line.set_xy2(failLine, rightEdge, failureRail)
else
    if not na(failLine)
        line.delete(failLine)
        failLine := na

if activePocket and showRoomRail
    if na(roomLine)
        roomLine := line.new(pocketBar, roomRail, rightEdge, roomRail, xloc = xloc.bar_index, extend = extend.none, color = neutralColor, width = 1)
    else
        line.set_xy1(roomLine, pocketBar, roomRail)
        line.set_xy2(roomLine, rightEdge, roomRail)
else
    if not na(roomLine)
        line.delete(roomLine)
        roomLine := na

// --------------------------------------------------
// Labels
// --------------------------------------------------
labelSize = f_size(labelSizeInput)
labelOffset = atrSafe * labelOffsetAtr
var array<label> eventLabels = array.new<label>()

f_push_label(label newLabel) =>
    array.push(eventLabels, newLabel)
    if array.size(eventLabels) > maxEventLabels
        label.delete(array.shift(eventLabels))

// Vertical anti-collision: nudge a new event label away from nearby existing ones
// (bar-based cooldown alone fails on compressed/HTF views).
f_collision_free_y(int x, float baseY, bool up) =>
    float adjY = baseY
    float step = atrSafe * 0.9
    int guard = 0
    bool moved = true
    while moved and guard < 16
        moved := false
        int n = array.size(eventLabels)
        if n > 0
            for i = 0 to n - 1
                label lb = array.get(eventLabels, i)
                if math.abs(label.get_x(lb) - x) <= 13 and math.abs(label.get_y(lb) - adjY) < step
                    adjY := up ? adjY + step : adjY - step
                    moved := true
        guard += 1
    adjY

if showEventLabels and showStretchLabels and newStretch and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
    bool bullEvent = bullStretchRaw
    color bg = bullEvent ? bullColor : bearColor
    float ly = f_collision_free_y(bar_index, bullEvent ? low - labelOffset : high + labelOffset, not bullEvent)
    label newLabel = label.new(bar_index, ly, bullEvent ? "BULL SNAPBACK\nTrend stretched" : "BEAR SNAPBACK\nTrend stretched", xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_up : label.style_label_down, color = bg, textcolor = f_text_on(bg), size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and showSnapLabels and snapEvent and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
    bool bullEvent = activeDir == 1
    color bg = bullEvent ? bullColor : bearColor
    float ly = f_collision_free_y(bar_index, bullEvent ? low - labelOffset : high + labelOffset, not bullEvent)
    label newLabel = label.new(bar_index, ly, "SNAPBACK RECLAIM\nBack toward mean", xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_up : label.style_label_down, color = bg, textcolor = f_text_on(bg), size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and showPressureLabels and pressureEvent and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
    bool bullEvent = activeDir == 1
    float ly = f_collision_free_y(bar_index, bullEvent ? low - labelOffset : high + labelOffset, not bullEvent)
    label newLabel = label.new(bar_index, ly, "POCKET PRESSURE\nTesting stretch", xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_up : label.style_label_down, color = accentColor, textcolor = f_text_on(accentColor), size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and showRoomLabels and roomEvent and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
    bool bullEvent = activeDir == 1
    float ly = f_collision_free_y(bar_index, bullEvent ? high + labelOffset : low - labelOffset, bullEvent)
    label newLabel = label.new(bar_index, ly, "ROOM TEST\nMean reached", xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_down : label.style_label_up, color = neutralColor, textcolor = f_text_on(neutralColor), size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and showInvalidLabels and failedEvent and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
    bool bullEvent = activeDir == 1
    float ly = f_collision_free_y(bar_index, bullEvent ? low - labelOffset : high + labelOffset, not bullEvent)
    label newLabel = label.new(bar_index, ly, "FAILED\nContinuation risk", xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_up : label.style_label_down, color = bearColor, textcolor = f_text_on(bearColor), size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

// --------------------------------------------------
// Right-side tags
// --------------------------------------------------
var label snapTag = na
var label failTag = na
var label roomTag = na

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

if showRightTags and activePocket
    snapTag := f_update_tag(snapTag, snapRail, "Snapback  " + f_price(snapRail), stateColor)
    failTag := f_update_tag(failTag, failureRail, "Failure  " + f_price(failureRail), bearColor)
    roomTag := f_update_tag(roomTag, roomRail, "Room  " + f_price(roomRail), neutralColor)
else
    if not na(snapTag)
        label.delete(snapTag)
        snapTag := na
    if not na(failTag)
        label.delete(failTag)
        failTag := na
    if not na(roomTag)
        label.delete(roomTag)
        roomTag := na

// Right-tag de-collision: snap/fail/room share the same x, so separate them vertically when too close.
if barstate.islast and showRightTags and activePocket
    array<label> tagArr = array.new_label()
    if not na(snapTag)
        array.push(tagArr, snapTag)
    if not na(failTag)
        array.push(tagArr, failTag)
    if not na(roomTag)
        array.push(tagArr, roomTag)
    int tc = array.size(tagArr)
    if tc > 1
        array<float> tys = array.new_float()
        for ti = 0 to tc - 1
            array.push(tys, label.get_y(array.get(tagArr, ti)))
        for a = 0 to tc - 2
            int mi = a
            for b = a + 1 to tc - 1
                if array.get(tys, b) < array.get(tys, mi)
                    mi := b
            if mi != a
                float ty = array.get(tys, a)
                array.set(tys, a, array.get(tys, mi))
                array.set(tys, mi, ty)
                label tl = array.get(tagArr, a)
                array.set(tagArr, a, array.get(tagArr, mi))
                array.set(tagArr, mi, tl)
        float gap = atrSafe * 0.7
        for a = 1 to tc - 1
            float py = array.get(tys, a - 1)
            float cy = array.get(tys, a)
            if cy - py < gap
                float ny = py + gap
                array.set(tys, a, ny)
                label.set_y(array.get(tagArr, a), ny)

// --------------------------------------------------
// Panel
// --------------------------------------------------
panelSize = f_size(panelFontSizeInput)

var table panel = na

if barstate.islast
    if showPanel
        if na(panel)
            panel := table.new(f_panel_position(panelPositionInput), 2, 7, border_width = 1, border_color = f_panel_border(), frame_color = f_panel_border(), frame_width = 1, bgcolor = f_panel_bg())
        table.set_position(panel, f_panel_position(panelPositionInput))
        table.set_border_color(panel, f_panel_border())
        table.set_frame_color(panel, f_panel_border())
        table.clear(panel, 0, 0, 1, 6)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Trend Exhaustion Snapback Planner", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
        table.cell(panel, 0, 1, "Pocket", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelSize)
        table.cell(panel, 1, 1, pocketState, text_color = f_panel_text(), bgcolor = f_panel_bg(), text_size = panelSize)
        table.cell(panel, 0, 2, "Snapback Score", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelSize)
        table.cell(panel, 1, 2, scoreText, text_color = f_text_on(stateColor), bgcolor = stateColor, text_size = panelSize)
        table.cell(panel, 0, 3, "Hit Rate", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelSize)
        table.cell(panel, 1, 3, hitRateText, text_color = hitRateColor, bgcolor = f_panel_bg(), text_size = panelSize)
        table.cell(panel, 0, 4, "Stretch", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelSize)
        table.cell(panel, 1, 4, pressureText, text_color = f_panel_text(), bgcolor = f_panel_bg(), text_size = panelSize)
        table.cell(panel, 0, 5, "Room", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelSize)
        table.cell(panel, 1, 5, roomText, text_color = f_panel_text(), bgcolor = f_panel_bg(), text_size = panelSize)
        table.cell(panel, 0, 6, "Action", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelSize)
        table.cell(panel, 1, 6, actionState, text_color = f_text_on(actionColor), bgcolor = actionColor, text_size = panelSize)
    else
        if not na(panel)
            table.delete(panel)
            panel := na

barStateColor = actionState == "READY" ? color.new(stateColor, 72) : actionState == "MONITOR" ? color.new(bullColor, 78) : actionState == "FAILED" ? color.new(bearColor, 70) : actionState == "PRESSURE" ? color.new(accentColor, 78) : na
barcolor(showBarColors ? barStateColor : na)

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(alertStretch and newStretch and bullStretchRaw, "AG Pro TES | BULL SNAPBACK POCKET", "AG Pro TES: A bullish trend exhaustion snapback pocket has been detected.")
alertcondition(alertStretch and newStretch and bearStretchRaw, "AG Pro TES | BEAR SNAPBACK POCKET", "AG Pro TES: A bearish trend exhaustion snapback pocket has been detected.")
alertcondition(alertSnapback and snapEvent, "AG Pro TES | SNAPBACK RECLAIM", "AG Pro TES: Price reclaimed the active snapback rail.")
alertcondition(alertReady and readyEvent, "AG Pro TES | READY", "AG Pro TES: The active trend exhaustion snapback context is READY.")
alertcondition(alertPressure and pressureEvent, "AG Pro TES | POCKET PRESSURE", "AG Pro TES: Price is pressuring the active exhaustion pocket.")
alertcondition(alertRoom and roomEvent, "AG Pro TES | ROOM TEST", "AG Pro TES: Price reached the active snapback room reference.")
alertcondition(alertFailed and failedEvent, "AG Pro TES | FAILED", "AG Pro TES: The active trend exhaustion snapback context has failed.")
````

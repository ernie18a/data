# Weekly Range Break Planner [AGPro Series]

- url: https://www.tradingview.com/script/dIbppOLU-Weekly-Range-Break-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;ea4076a7c44844bcac2f752074a0d074
- version: 4.0

## Description

# Weekly Range Break Planner [AGPro Series]

🧠 Core Idea

Is the weekly range break strong enough to monitor, or is price likely to fail back inside the range?

📌 Overview / What it does

Weekly Range Break Planner is a weekly range decision-support script built to evaluate whether price is breaking beyond the previous week's high or low with enough structural quality.

The script maps the previous weekly high, low, and midpoint, detects bullish or bearish breaks, builds a retest shelf around the broken boundary, scores the break from 0 to 100, and summarizes the current state inside a compact AG Pro panel.

It does not predict price direction, automate trades, or provide guaranteed signals. It is designed to organize weekly range context, break quality, retest behavior, target room, and invalidation risk into a clean visual workflow.

🎯 Purpose & Design Philosophy

Weekly highs and weekly lows are widely watched reference points, but not every break beyond them is meaningful.

This script was built for traders who want to separate a clean weekly range break from a weak expansion, failed breakout, or noisy return back into the prior range.

The design supports structured observation: range first, break quality second, retest behavior third, and action state last.

⚡ Why This Script Is Different

Most tools mark weekly highs and lows or show simple breakout signals.

This script does NOT stop at drawing weekly levels.

Instead, it evaluates what happens after price breaks the range: whether the break has enough close quality, whether the retest shelf is respected, whether target room remains, and whether the context is still valid.

⚙️ Methodology

1. Previous Weekly Range Mapping
2. Break Boundary Detection
3. Retest Shelf Construction
4. Break Quality Scoring
5. Target Room Evaluation
6. Invalidation And Expiration Handling
7. Panel And Alert Output

🗺️ How to Read the Chart

The weekly range box marks the previous week's high-low structure.

The high and low rails show the main break boundaries.

The midpoint line helps users understand where price is relative to the prior weekly balance.

The retest shelf appears around the broken boundary after a weekly range break.

READY BREAK labels appear when the break context meets the required score threshold.

Target rails show projected continuation references after a qualified break.

The panel summarizes Range State, Break Score, Retest, Room, and Action.

🚦 Signals & States

• READY → A qualified weekly range break has formed.

• MONITOR → Price has broken a weekly boundary and the script is evaluating quality.

• WAIT → The previous weekly range is valid, but no active break context is present.

• INVALIDATED → Price failed back inside the weekly range after a break.

• EXPIRED → The break window closed without a qualified context.

• BLOCKED → The previous weekly range is not suitable for evaluation.

🔔 Alerts Logic

Bullish Weekly Range Break Ready triggers when price breaks above the previous weekly high with enough quality.

Bearish Weekly Range Break Ready triggers when price breaks below the previous weekly low with enough quality.

Weekly Range Break Invalidated triggers when price fails back inside the prior weekly range after a break.

Weekly Range Break Expired triggers when the evaluation window closes without a qualified break state.

Alerts are attention markers, not trade instructions.

🧩 Confluence Logic

The break score combines weekly range fit, close distance beyond the boundary, retest shelf behavior, time quality, relative volume, and available target room.

When these elements align, the context becomes stronger.

When they do not align, the script remains in WAIT, MONITOR, INVALIDATED, EXPIRED, or BLOCKED state.

📊 When to Use

• Weekly high and weekly low break analysis

• Breakout-retest workflows

• Intraday monitoring around prior weekly extremes

• Swing context planning

• Trend continuation after a range expansion

⚠️ When NOT to Use

Avoid relying on this script in extremely low-liquidity markets, very noisy symbols, holiday sessions, or conditions where the previous weekly range is not meaningful.

It should not be used as a standalone decision tool without broader market context, risk planning, and independent confirmation.

🎛️ Key Inputs

• Minimum Weekly Range filters weak or compressed prior weekly ranges.

• Break Buffer ATR controls how far price must close beyond the weekly boundary.

• Retest Shelf ATR controls the depth of the shelf around the broken boundary.

• Invalidation Buffer ATR controls how far price must close back inside the range before invalidation.

• Minimum Ready Score controls how strong the score must be before READY appears.

• Target inputs define continuation reference rails from the broken boundary.

• Visual settings control boxes, rails, labels, right-side tags, panel location, and font size.

🖥️ Interface & Visual Design

The interface is designed to make the weekly range context readable at a glance.

The chart shows the prior weekly range, the active break boundary, the retest shelf, and target-room references without turning the screen into a generic breakout overlay.

The AG Pro panel gives compact decision context while preserving chart visibility.

🧪 Practical Usage Workflow

1. Check whether the previous weekly range is valid.

2. Watch for a close beyond the weekly high or low.

3. Observe the retest shelf around the broken boundary.

4. Read the break score, retest state, and room value.

5. Treat READY as an attention state and confirm with broader market context.

🔍 Interpretation Guidelines

A higher break score means the weekly range break is cleaner according to the script logic.

A clean retest shelf response can strengthen the context.

Low remaining room means the move may already be extended relative to the projected target.

READY means the context deserves attention, not that price must continue.

🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not provide guaranteed signals.

It does not replace risk management or independent analysis.

⚠️ Limitations & Transparency

Weekly range behavior changes across markets, timeframes, volatility regimes, and liquidity conditions.

The score is rule-based and depends on current chart timeframe, ATR normalization, volume behavior, and the previous weekly range.

Different symbols may require different sensitivity settings.

🧠 Market Context Notes

Weekly range breaks can be more meaningful when aligned with trend, liquidity response, volume participation, and clean retest behavior.

Breaks that quickly return inside the prior weekly range often need extra caution.

🔐 Non-Promise Statement

No script can guarantee future price behavior.

This tool provides structured visual context only.

📉 Risk Disclosure

Trading involves risk.

Users remain responsible for their own decisions.

This script is for educational and analytical purposes only and does not provide financial advice or guaranteed trading outcomes.

## Source Code

````pine
// -------------------------------------------------
// Weekly Range Break Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Weekly Range Break Planner is a multi-timeframe weekly breakout decision
// engine that grades whether price is breaking and accepting the prior weekly
// high or low. It maps the previous weekly range, builds a retest shelf on the
// broken boundary, scores break quality from 0-100, projects two continuation
// targets, and tracks a stop-aware Follow Rate showing how often past READY
// breaks reached the first target before failing back inside the range. Range
// state, retest quality, target room, follow-through proof, and the next action
// are organized into one clean AG Pro decision panel.
//
// Version 1.5: exact center-owned range, shelf, and target-room identities;
// boundary-owned right-side badges with short price connectors; font-aware ATR
// spacing; compact historical event badges; and atomic visual cleanup when a
// plan or visual layer is replaced.
// -------------------------------------------------

//@version=6
indicator("Weekly Range Break Planner [AGPro Series]",
     shorttitle = "AG Pro WRB",
     overlay = true,
     max_boxes_count = 80,
     max_labels_count = 120,
     max_lines_count = 100)

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

darkInk       = color.rgb(15, 23, 42)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(_v, _lo, _hi) =>
    math.max(_lo, math.min(_v, _hi))

// Luminance-aware text color: dark ink on light badges, light text on dark badges.
f_text_on(_bg) =>
    _lum = 0.299 * color.r(_bg) + 0.587 * color.g(_bg) + 0.114 * color.b(_bg)
    _lum > 145 ? darkInk : headerText

f_size(_s) =>
    _s == "Tiny" ? size.tiny :
     _s == "Small" ? size.small :
     _s == "Normal" ? size.normal :
     _s == "Large" ? size.large : size.huge

f_label_lane_mult(_s) =>
    _s == "Tiny" ? 0.75 :
     _s == "Small" ? 0.90 :
     _s == "Large" ? 1.25 :
     _s == "Huge" ? 1.55 : 1.00

f_table_size(_s) =>
    _s == "Tiny" ? size.tiny :
     _s == "Small" ? size.small :
     _s == "Normal" ? size.normal : size.large

f_panel_position(_p) =>
    _p == "Top Right" ? position.top_right :
     _p == "Top Left" ? position.top_left :
     _p == "Middle Right" ? position.middle_right :
     _p == "Middle Left" ? position.middle_left :
     _p == "Bottom Right" ? position.bottom_right : position.bottom_left

f_grade(_score) =>
    _score >= 85 ? "A+" :
     _score >= 75 ? "A" :
     _score >= 65 ? "B" :
     _score >= 55 ? "C" : "D"

f_score_text(_score) =>
    na(_score) ? "n/a" : str.tostring(math.round(_score)) + "/100  " + f_grade(_score)

f_action_base(_action) =>
    _action == "READY" ? bullColor :
     _action == "MONITOR" ? accentColor :
     _action == "WAIT" ? neutralColor :
     _action == "INVALIDATED" ? bearColor :
     _action == "EXPIRED" ? panelBorder :
     _action == "BLOCKED" ? panelBorder : panelBg

f_action_color(_action) =>
    _action == "READY" ? color.new(bullColor, 8) :
     _action == "MONITOR" ? color.new(accentColor, 10) :
     _action == "WAIT" ? color.new(neutralColor, 16) :
     _action == "INVALIDATED" ? color.new(bearColor, 8) :
     _action == "EXPIRED" ? color.new(panelBorder, 8) :
     _action == "BLOCKED" ? color.new(panelBorder, 0) : color.new(panelBg, 0)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
G_RANGE  = "Weekly Range"
G_ENGINE = "Break Engine"
G_VISUAL = "Visuals"
G_PANEL  = "Panel"
G_ALERTS = "Alerts"

rangeSource = input.string("Previous Week", "Range Source",
     options = ["Previous Week"],
     group = G_RANGE,
     tooltip = "Uses the fully closed previous weekly candle as the high/low range reference. This avoids using an unfinished weekly range.")
atrLength = input.int(14, "ATR Length", minval = 2, maxval = 100, group = G_RANGE,
     tooltip = "ATR normalizes break buffers, retest shelf depth, room calculations, and label spacing.")
minWeeklyRangeAtr = input.float(0.90, "Minimum Weekly Range (x ATR)", minval = 0.10, maxval = 10.00, step = 0.05, group = G_RANGE,
     tooltip = "Blocks analysis when the previous weekly range is too compressed relative to current ATR.")

confirmationMode = input.string("Balanced", "Confirmation Mode", options = ["Fast", "Balanced", "Strict"], group = G_ENGINE,
     tooltip = "Fast reacts earlier, Balanced requires cleaner break quality, and Strict demands stronger close and lower failure risk.")
breakBufferAtr = input.float(0.08, "Break Buffer ATR", minval = 0.00, maxval = 3.00, step = 0.01, group = G_ENGINE,
     tooltip = "ATR-based close distance beyond the weekly high or low required before a break context starts.")
retestShelfAtr = input.float(0.22, "Retest Shelf ATR", minval = 0.03, maxval = 3.00, step = 0.01, group = G_ENGINE,
     tooltip = "ATR-based shelf around the broken weekly boundary where retest quality is evaluated.")
invalidationBufferAtr = input.float(0.10, "Invalidation Buffer ATR", minval = 0.00, maxval = 3.00, step = 0.01, group = G_ENGINE,
     tooltip = "ATR-based close back inside the weekly range required to invalidate a break context. This level is also used as the stop reference for the Follow Rate proof.")
breakWindowBars = input.int(80, "Break Window Bars", minval = 5, maxval = 500, group = G_ENGINE,
     tooltip = "Maximum number of bars after a weekly break during which the script keeps evaluating retest and follow-through quality. Also the timeout for the Follow Rate proof.")
minReadyScore = input.int(64, "Minimum Ready Score", minval = 1, maxval = 100, group = G_ENGINE,
     tooltip = "Minimum 0-100 break score required before READY appears.")
useVolumeScore = input.bool(true, "Use Relative Volume In Score", group = G_ENGINE,
     tooltip = "Adds relative volume participation to the weekly break score.")
volumeLength = input.int(20, "Relative Volume Length", minval = 2, maxval = 200, group = G_ENGINE,
     tooltip = "Lookback used to compare current volume against recent average participation.")
targetOneRange = input.float(0.35, "Target 1 x Weekly Range", minval = 0.05, maxval = 3.00, step = 0.05, group = G_ENGINE,
     tooltip = "First projected target distance measured from the broken weekly boundary.")
targetTwoRange = input.float(0.65, "Target 2 x Weekly Range", minval = 0.05, maxval = 5.00, step = 0.05, group = G_ENGINE,
     tooltip = "Second projected target distance measured from the broken weekly boundary.")

showWeeklyRange = input.bool(true, "Show Weekly Range Box", group = G_VISUAL,
     tooltip = "Shows the previous weekly range as the main high/low reference.")
showRangeMidline = input.bool(true, "Show Weekly Midline", group = G_VISUAL,
     tooltip = "Shows the midpoint of the previous weekly range.")
showRangeCenterLabel = input.bool(true, "Show Centered Range Label", group = G_VISUAL,
     tooltip = "Shows a compact premium badge centered inside the weekly range box.")
showRetestShelf = input.bool(true, "Show Retest Shelf", group = G_VISUAL,
     tooltip = "Shows the focused shelf around the broken weekly boundary.")
showTargetRails = input.bool(true, "Show Target Rails", group = G_VISUAL,
     tooltip = "Shows projected continuation target rails after a qualified break.")
showRoomCorridor = input.bool(true, "Show Target-Room Corridor", group = G_VISUAL,
     tooltip = "Shows a soft corridor between the weekly boundary and first projected target after READY appears.")
rangeExtendBars = input.int(240, "Weekly Range Extension Bars", minval = 20, maxval = 450, group = G_VISUAL,
     tooltip = "How far the weekly range box and high/low rails extend to the right.")
shelfExtendBars = input.int(90, "Retest Shelf Extension Bars", minval = 10, maxval = 450, group = G_VISUAL,
     tooltip = "How far the retest shelf projects after a break.")
targetExtendBars = input.int(120, "Target Rail Extension Bars", minval = 10, maxval = 450, group = G_VISUAL,
     tooltip = "How far target rails and room corridor project after READY.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows READY, failed retest, invalidation, and expiration labels.")
showBreakWatchLabels = input.bool(false, "Show Break Watch Labels", group = G_VISUAL,
     tooltip = "Shows early break-watch labels. Disabled by default for cleaner publication screenshots.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows compact right-side tags for the weekly high, weekly low, and projected targets.")
rightTagOffsetBars = input.int(7, "Right Tag Offset", minval = 2, maxval = 40, group = G_VISUAL,
     tooltip = "Controls the short connector distance between each owned rail boundary and its right-side badge.")
rightTagMinGapAtr = input.float(0.55, "Right Tag Minimum Gap ATR", minval = 0.00, maxval = 4.00, step = 0.05, group = G_VISUAL,
     tooltip = "Minimum ATR-based vertical gap used to separate nearby right-side tags such as W Low, T1 and T2 so they never overlap.")
showBarColors = input.bool(false, "Color Bars By State", group = G_VISUAL,
     tooltip = "Colors bars lightly when a weekly break state is active.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VISUAL,
     tooltip = "Controls chart label and right-side tag size.")
labelOffsetAtr = input.float(0.55, "Label Offset ATR", minval = 0.05, maxval = 5.00, step = 0.05, group = G_VISUAL,
     tooltip = "ATR-based vertical spacing used to keep event labels clearly above or below the candles.")
maxEventLabels = input.int(6, "Max Event Labels", minval = 2, maxval = 60, group = G_VISUAL,
     tooltip = "Maximum number of event labels retained on chart.")
eventLabelCooldownBars = input.int(18, "Event Label Cooldown", minval = 0, maxval = 200, group = G_VISUAL,
     tooltip = "Minimum number of bars between retained historical event labels. Higher values reduce label clustering on 1D and 1W screenshots.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Displays the AG Pro decision panel. Enabled by default.")
panelPositionInput = input.string("Top Right", "Panel Position",
     options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"],
     group = G_PANEL,
     tooltip = "Controls where the panel appears on chart.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_PANEL,
     tooltip = "Controls whether the panel uses the AGPro dark theme or a light chart-friendly theme.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Controls text size inside the decision panel.")

alertReady = input.bool(true, "Alert: Weekly Break Ready", group = G_ALERTS,
     tooltip = "Creates an alert condition when a weekly range break becomes READY.")
alertInvalidated = input.bool(true, "Alert: Weekly Break Invalidated", group = G_ALERTS,
     tooltip = "Creates an alert condition when a break fails back inside the prior weekly range.")
alertExpired = input.bool(false, "Alert: Weekly Break Expired", group = G_ALERTS,
     tooltip = "Creates an alert condition when the weekly break context expires without a qualified state.")

// -------------------------------------------------
// Core calculations
// -------------------------------------------------
atr = ta.atr(atrLength)
labelSize = f_size(labelSizeInput)
labelLaneMult = f_label_lane_mult(labelSizeInput)
panelSize = f_table_size(panelFontSizeInput)
volAvg = ta.sma(volume, volumeLength)
rvol = volAvg > 0 ? volume / volAvg : 1.0
confirmBonus = confirmationMode == "Fast" ? 4.0 : confirmationMode == "Balanced" ? 0.0 : -7.0
requiredScore = f_clamp(minReadyScore - confirmBonus, 1, 100)

prevWeekHigh = request.security(syminfo.tickerid, "W", high[1], barmerge.gaps_off, barmerge.lookahead_off)
prevWeekLow = request.security(syminfo.tickerid, "W", low[1], barmerge.gaps_off, barmerge.lookahead_off)
prevWeekMid = (prevWeekHigh + prevWeekLow) / 2.0
weeklyRange = prevWeekHigh - prevWeekLow
rangeValid = not na(prevWeekHigh) and not na(prevWeekLow) and weeklyRange > 0 and atr > 0 and weeklyRange >= atr * minWeeklyRangeAtr
newWeek = ta.change(time("W")) != 0

var int breakDir = 0
var float brokenEdge = na
var int breakBar = na
var bool resolved = false
var string rangeState = "Waiting Range"
var string actionState = "WAIT"
var float lastScore = na
var float lastRoom = na
var string retestState = "n/a"

// Latched reference frame (keeps edge, range, targets and tags coherent across weeks)
var float refHigh = na
var float refLow = na
var float refMid = na
var float refRange = na

// Follow Rate proof state (stop-aware: did a READY break reach T1 before failing back inside?)
var int followWins = 0
var int followTotal = 0
var bool followPending = false
var int followDir = 0
var float followTarget = na
var float followStop = na
var int followStartBar = na

var box rangeBox = na
var box shelfBox = na
var box roomBox = na
var line highLine = na
var line lowLine = na
var line midLine = na
var line targetOneLine = na
var line targetTwoLine = na
var line tagHighConnector = na
var line tagLowConnector = na
var line tagT1Connector = na
var line tagT2Connector = na
var label tagHigh = na
var label tagLow = na
var label tagT1 = na
var label tagT2 = na
var label rangeCenterLabel = na
var label shelfCenterLabel = na
var label roomCenterLabel = na
var label[] eventLabels = array.new_label()
var int lastEventLabelBar = na

barsSinceBreak = breakDir != 0 and not na(breakBar) ? bar_index - breakBar : na
rangeRight = bar_index + rangeExtendBars
shelfRight = bar_index + shelfExtendBars
targetRight = bar_index + targetExtendBars

if newWeek
    breakDir := 0
    brokenEdge := na
    breakBar := na
    resolved := false
    rangeState := rangeValid ? "Range Ready" : "Range Blocked"
    actionState := rangeValid ? "WAIT" : "BLOCKED"
    lastScore := na
    lastRoom := na
    retestState := "n/a"
    if not na(shelfBox)
        box.delete(shelfBox)
        shelfBox := na
    if not na(roomBox)
        box.delete(roomBox)
        roomBox := na
    if not na(shelfCenterLabel)
        label.delete(shelfCenterLabel)
        shelfCenterLabel := na
    if not na(roomCenterLabel)
        label.delete(roomCenterLabel)
        roomCenterLabel := na
    if not na(targetOneLine)
        line.delete(targetOneLine)
        targetOneLine := na
    if not na(targetTwoLine)
        line.delete(targetTwoLine)
        targetTwoLine := na
    if not na(tagT1Connector)
        line.delete(tagT1Connector)
        tagT1Connector := na
    if not na(tagT2Connector)
        line.delete(tagT2Connector)
        tagT2Connector := na

// Refresh the reference frame to the live prior week while no break is active;
// it latches automatically on the break bar (breakDir is still 0 at this point).
if breakDir == 0
    refHigh := prevWeekHigh
    refLow := prevWeekLow
    refMid := prevWeekMid
    refRange := weeklyRange

refValid = not na(refHigh) and not na(refLow) and (refHigh - refLow) > 0 and atr > 0
showFrame = rangeValid or refValid

if showFrame and showWeeklyRange
    if na(rangeBox)
        rangeBox := box.new(bar_index, refHigh, rangeRight, refLow,
             bgcolor = color.new(accentColor, 92),
             border_color = color.new(accentColor, 35),
             border_width = 1)
    else
        box.set_lefttop(rangeBox, bar_index, refHigh)
        box.set_rightbottom(rangeBox, rangeRight, refLow)
else
    if not na(rangeBox)
        box.delete(rangeBox)
        rangeBox := na
    if not na(rangeCenterLabel)
        label.delete(rangeCenterLabel)
        rangeCenterLabel := na

if showFrame
    if na(highLine)
        highLine := line.new(bar_index, refHigh, rangeRight, refHigh,
             color = color.new(bullColor, 8),
             width = 1)
    else
        line.set_xy1(highLine, bar_index, refHigh)
        line.set_xy2(highLine, rangeRight, refHigh)
    if na(lowLine)
        lowLine := line.new(bar_index, refLow, rangeRight, refLow,
             color = color.new(bearColor, 8),
             width = 1)
    else
        line.set_xy1(lowLine, bar_index, refLow)
        line.set_xy2(lowLine, rangeRight, refLow)
    if showRangeMidline
        if na(midLine)
            midLine := line.new(bar_index, refMid, rangeRight, refMid,
                 color = color.new(neutralColor, 35),
                 width = 1,
                 style = line.style_dotted)
        else
            line.set_xy1(midLine, bar_index, refMid)
            line.set_xy2(midLine, rangeRight, refMid)
    else
        if not na(midLine)
            line.delete(midLine)
            midLine := na

breakBuffer = atr * breakBufferAtr
breakUp = rangeValid and breakDir == 0 and close > prevWeekHigh + breakBuffer
breakDown = rangeValid and breakDir == 0 and close < prevWeekLow - breakBuffer

eventLabelAllowed = showEventLabels and (na(lastEventLabelBar) or bar_index - lastEventLabelBar >= eventLabelCooldownBars)

if breakUp or breakDown
    breakDir := breakUp ? 1 : -1
    brokenEdge := breakDir == 1 ? prevWeekHigh : prevWeekLow
    refHigh := prevWeekHigh
    refLow := prevWeekLow
    refMid := prevWeekMid
    refRange := weeklyRange
    breakBar := bar_index
    resolved := false
    rangeState := breakDir == 1 ? "Bull Break Watch" : "Bear Break Watch"
    actionState := "MONITOR"
    retestState := "Waiting Retest"
    lastScore := na
    lastRoom := na
    if eventLabelAllowed and showBreakWatchLabels
        labelBg = color.new(breakDir == 1 ? bullColor : bearColor, 8)
        eventOffset = atr * labelOffsetAtr * labelLaneMult
        label breakLabel = label.new(bar_index, breakDir == 1 ? high + eventOffset : low - eventOffset,
             breakDir == 1 ? "WEEKLY HIGH BREAK | RETEST WATCH" : "WEEKLY LOW BREAK | RETEST WATCH",
             style = breakDir == 1 ? label.style_label_down : label.style_label_up,
             textcolor = f_text_on(breakDir == 1 ? bullColor : bearColor),
             color = labelBg,
             size = labelSize)
        array.push(eventLabels, breakLabel)
        lastEventLabelBar := bar_index
        if array.size(eventLabels) > maxEventLabels
            label.delete(array.shift(eventLabels))

hasBreak = breakDir != 0 and not na(brokenEdge)
shelfDepth = atr * retestShelfAtr
shelfTop = hasBreak ? brokenEdge + shelfDepth : na
shelfBottom = hasBreak ? brokenEdge - shelfDepth : na

if hasBreak and showRetestShelf
    shelfColor = breakDir == 1 ? bullColor : bearColor
    if na(shelfBox)
        shelfBox := box.new(breakBar, shelfTop, shelfRight, shelfBottom,
             bgcolor = color.new(shelfColor, 86),
             border_color = color.new(shelfColor, 22),
             border_width = 1)
    else
        box.set_lefttop(shelfBox, breakBar, shelfTop)
        box.set_rightbottom(shelfBox, shelfRight, shelfBottom)
else
    if not na(shelfBox)
        box.delete(shelfBox)
        shelfBox := na
    if not na(shelfCenterLabel)
        label.delete(shelfCenterLabel)
        shelfCenterLabel := na

touchedShelf = hasBreak and high >= shelfBottom and low <= shelfTop
heldRetest = hasBreak and breakDir == 1 ? touchedShelf and close >= brokenEdge :
     hasBreak and breakDir == -1 ? touchedShelf and close <= brokenEdge : false
failedRetest = hasBreak and breakDir == 1 ? close < brokenEdge - atr * invalidationBufferAtr :
     hasBreak and breakDir == -1 ? close > brokenEdge + atr * invalidationBufferAtr : false
expired = hasBreak and not resolved and not na(barsSinceBreak) and barsSinceBreak > breakWindowBars

targetOne = hasBreak and breakDir == 1 ? brokenEdge + refRange * targetOneRange :
     hasBreak and breakDir == -1 ? brokenEdge - refRange * targetOneRange : na
targetTwo = hasBreak and breakDir == 1 ? brokenEdge + refRange * targetTwoRange :
     hasBreak and breakDir == -1 ? brokenEdge - refRange * targetTwoRange : na

breakCloseDistance = hasBreak and atr > 0 ? math.abs(close - brokenEdge) / atr : 0.0
rangeFitScore = refValid ? f_clamp(refRange / (atr * 4.0), 0.0, 1.0) * 16.0 : 0.0
closeScore = f_clamp(breakCloseDistance / 1.4, 0.0, 1.0) * 24.0
retestScore = heldRetest ? 22.0 : touchedShelf ? 12.0 : 7.0
timeScore = hasBreak and not na(barsSinceBreak) ? f_clamp(16.0 * (1.0 - barsSinceBreak / math.max(breakWindowBars, 1)), 0.0, 16.0) : 0.0
rvolScore = useVolumeScore ? f_clamp(rvol / 1.6, 0.0, 1.0) * 12.0 : 9.0
roomAtr = hasBreak and breakDir == 1 and not na(targetOne) ? (targetOne - close) / atr :
     hasBreak and breakDir == -1 and not na(targetOne) ? (close - targetOne) / atr : 0.0
roomScore = f_clamp(roomAtr / 2.0, 0.0, 1.0) * 14.0
candidateScore = f_clamp(rangeFitScore + closeScore + retestScore + timeScore + rvolScore + roomScore, 0.0, 100.0)
roomPct = hasBreak and refRange > 0 and not na(targetOne) ? f_clamp(math.abs(targetOne - close) / refRange * 100.0, 0.0, 100.0) : na

readyEvent = hasBreak and not resolved and candidateScore >= requiredScore and (heldRetest or breakCloseDistance >= 0.45) and not failedRetest
invalidatedEvent = hasBreak and not resolved and failedRetest
expiredEvent = hasBreak and not resolved and expired

if hasBreak and not resolved
    lastScore := candidateScore
    lastRoom := roomPct
    retestState := heldRetest ? "Retest Held" : touchedShelf ? "Testing Shelf" : "Waiting Retest"
    actionState := "MONITOR"

if readyEvent
    resolved := true
    rangeState := breakDir == 1 ? "Bull Break Accepted" : "Bear Break Accepted"
    actionState := "READY"
    retestState := heldRetest ? "Retest Held" : "Break Accepted"
    lastScore := candidateScore
    lastRoom := roomPct
    if eventLabelAllowed
        eventOffset = atr * labelOffsetAtr * labelLaneMult
        label readyLabel = label.new(bar_index, breakDir == 1 ? low - eventOffset : high + eventOffset,
             "READY BREAK | Q " + str.tostring(math.round(candidateScore)),
             style = breakDir == 1 ? label.style_label_up : label.style_label_down,
             textcolor = f_text_on(breakDir == 1 ? bullColor : bearColor),
             color = color.new(breakDir == 1 ? bullColor : bearColor, 0),
             size = labelSize)
        array.push(eventLabels, readyLabel)
        lastEventLabelBar := bar_index
        if array.size(eventLabels) > maxEventLabels
            label.delete(array.shift(eventLabels))
    if showTargetRails and not na(targetOne) and not na(targetTwo)
        if not na(targetOneLine)
            line.delete(targetOneLine)
        if not na(targetTwoLine)
            line.delete(targetTwoLine)
        targetOneLine := line.new(bar_index, targetOne, targetRight, targetOne,
             color = color.new(neutralColor, 10),
             width = 1,
             style = line.style_dashed)
        targetTwoLine := line.new(bar_index, targetTwo, targetRight, targetTwo,
             color = color.new(accentColor, 10),
             width = 1,
             style = line.style_dashed)
    if showRoomCorridor and not na(targetOne)
        roomHigh = math.max(brokenEdge, targetOne)
        roomLow = math.min(brokenEdge, targetOne)
        if na(roomBox)
            roomBox := box.new(bar_index, roomHigh, targetRight, roomLow,
                 bgcolor = color.new(breakDir == 1 ? bullColor : bearColor, 91),
                 border_color = color.new(breakDir == 1 ? bullColor : bearColor, 30),
                 border_width = 1)
        else
            box.set_lefttop(roomBox, bar_index, roomHigh)
            box.set_rightbottom(roomBox, targetRight, roomLow)

if invalidatedEvent
    resolved := true
    rangeState := "Break Invalidated"
    actionState := "INVALIDATED"
    retestState := "Failed Back In"
    lastScore := candidateScore
    lastRoom := roomPct
    if eventLabelAllowed
        eventOffset = atr * labelOffsetAtr * labelLaneMult
        label failLabel = label.new(bar_index, breakDir == 1 ? low - eventOffset : high + eventOffset,
             "INVALIDATED | BACK INSIDE RANGE",
             style = breakDir == 1 ? label.style_label_up : label.style_label_down,
             textcolor = f_text_on(bearColor),
             color = color.new(bearColor, 0),
             size = labelSize)
        array.push(eventLabels, failLabel)
        lastEventLabelBar := bar_index
        if array.size(eventLabels) > maxEventLabels
            label.delete(array.shift(eventLabels))

if expiredEvent
    resolved := true
    rangeState := "Break Expired"
    actionState := "EXPIRED"
    retestState := "Window Closed"
    if eventLabelAllowed
        eventOffset = atr * labelOffsetAtr * labelLaneMult
        label expiredLabel = label.new(bar_index, breakDir == 1 ? low - eventOffset : high + eventOffset,
             "EXPIRED | NO CLEAN FOLLOW-THROUGH",
             style = breakDir == 1 ? label.style_label_up : label.style_label_down,
             textcolor = f_text_on(panelBorder),
             color = color.new(panelBorder, 0),
             size = labelSize)
        array.push(eventLabels, expiredLabel)
        lastEventLabelBar := bar_index
        if array.size(eventLabels) > maxEventLabels
            label.delete(array.shift(eventLabels))

if not rangeValid and not hasBreak
    rangeState := "Range Blocked"
    actionState := "BLOCKED"
    retestState := "n/a"

if rangeValid and breakDir == 0
    rangeState := "Range Ready"
    actionState := "WAIT"
    retestState := "n/a"
    lastScore := na
    lastRoom := na

// -------------------------------------------------
// Follow Rate proof (stop-aware, confirmed-bar gated, resolve-then-open)
// Counts a READY break as a win if price reached T1 before closing back inside
// the range past the invalidation buffer. Timeouts are left uncounted.
// -------------------------------------------------
if barstate.isconfirmed
    if followPending
        proofWin = followDir == 1 ? high >= followTarget : low <= followTarget
        proofLoss = followDir == 1 ? close < followStop : close > followStop
        proofTimeout = not na(followStartBar) and (bar_index - followStartBar) > breakWindowBars
        if proofWin
            followWins += 1
            followTotal += 1
            followPending := false
        else if proofLoss
            followTotal += 1
            followPending := false
        else if proofTimeout
            followPending := false
    if readyEvent and not followPending and not na(targetOne) and breakDir != 0
        followPending := true
        followDir := breakDir
        followTarget := targetOne
        followStop := breakDir == 1 ? brokenEdge - atr * invalidationBufferAtr : brokenEdge + atr * invalidationBufferAtr
        followStartBar := bar_index

followPct = followTotal > 0 ? followWins / followTotal * 100.0 : na
followBuilding = followTotal < 6
followBase = followBuilding ? panelBorder : followPct >= 60 ? bullColor : followPct >= 45 ? neutralColor : bearColor
followText = followBuilding ? "Building (" + str.tostring(followTotal) + ")" :
     str.tostring(math.round(followPct)) + "%  (" + str.tostring(followTotal) + ")"

// -------------------------------------------------
// Centered range label (rendered after the state machine so it always
// matches the panel's range state and action)
// -------------------------------------------------
if barstate.islast and showFrame and showWeeklyRange and showRangeCenterLabel
    rangeLabelX = int(math.round((bar_index + rangeRight) / 2.0))
    rangeLabelText = "Weekly Range  |  " + rangeState + "  |  " + actionState
    if na(rangeCenterLabel)
        rangeCenterLabel := label.new(rangeLabelX, refMid, rangeLabelText,
             xloc = xloc.bar_index,
             style = label.style_label_center,
             textcolor = f_text_on(accentColor),
             color = color.new(accentColor, 0),
             size = labelSize,
             textalign = text.align_center)
    else
        label.set_x(rangeCenterLabel, rangeLabelX)
        label.set_y(rangeCenterLabel, refMid)
        label.set_text(rangeCenterLabel, rangeLabelText)
        label.set_color(rangeCenterLabel, color.new(accentColor, 0))
        label.set_textcolor(rangeCenterLabel, f_text_on(accentColor))
        label.set_size(rangeCenterLabel, labelSize)
else if barstate.islast and not na(rangeCenterLabel)
    label.delete(rangeCenterLabel)
    rangeCenterLabel := na

// -------------------------------------------------
// Center-owned active zones
// -------------------------------------------------
if barstate.islast and not na(shelfBox) and showRetestShelf
    shelfLabelX = int(math.round((box.get_left(shelfBox) + box.get_right(shelfBox)) / 2.0))
    shelfLabelY = (box.get_top(shelfBox) + box.get_bottom(shelfBox)) / 2.0
    shelfLabelBg = breakDir == 1 ? bullColor : bearColor
    shelfLabelText = "RETEST SHELF | " + retestState
    if na(shelfCenterLabel)
        shelfCenterLabel := label.new(shelfLabelX, shelfLabelY, shelfLabelText,
             xloc = xloc.bar_index,
             style = label.style_label_center,
             textcolor = f_text_on(shelfLabelBg),
             color = color.new(shelfLabelBg, 0),
             size = labelSize,
             textalign = text.align_center)
    else
        label.set_x(shelfCenterLabel, shelfLabelX)
        label.set_y(shelfCenterLabel, shelfLabelY)
        label.set_text(shelfCenterLabel, shelfLabelText)
        label.set_color(shelfCenterLabel, color.new(shelfLabelBg, 0))
        label.set_textcolor(shelfCenterLabel, f_text_on(shelfLabelBg))
        label.set_size(shelfCenterLabel, labelSize)
else if barstate.islast and not na(shelfCenterLabel)
    label.delete(shelfCenterLabel)
    shelfCenterLabel := na

if barstate.islast and not na(roomBox) and showRoomCorridor
    roomLabelX = int(math.round((box.get_left(roomBox) + box.get_right(roomBox)) / 2.0))
    roomLabelY = (box.get_top(roomBox) + box.get_bottom(roomBox)) / 2.0
    roomLabelBg = breakDir == 1 ? bullColor : bearColor
    if na(roomCenterLabel)
        roomCenterLabel := label.new(roomLabelX, roomLabelY, "TARGET ROOM | T1",
             xloc = xloc.bar_index,
             style = label.style_label_center,
             textcolor = f_text_on(roomLabelBg),
             color = color.new(roomLabelBg, 0),
             size = labelSize,
             textalign = text.align_center)
    else
        label.set_x(roomCenterLabel, roomLabelX)
        label.set_y(roomCenterLabel, roomLabelY)
        label.set_text(roomCenterLabel, "TARGET ROOM | T1")
        label.set_color(roomCenterLabel, color.new(roomLabelBg, 0))
        label.set_textcolor(roomCenterLabel, f_text_on(roomLabelBg))
        label.set_size(roomCenterLabel, labelSize)
else if barstate.islast and not na(roomCenterLabel)
    label.delete(roomCenterLabel)
    roomCenterLabel := na

// -------------------------------------------------
// Boundary-owned right-side badges and price connectors
// -------------------------------------------------
if barstate.islast and showFrame and showRightTags
    rangeTagX = rangeRight + rightTagOffsetBars
    targetAnchorX = not na(targetOneLine) ? line.get_x2(targetOneLine) : targetRight
    targetTagX = targetAnchorX + rightTagOffsetBars
    gap = math.max(atr * rightTagMinGapAtr * labelLaneMult, syminfo.mintick * 20.0)
    isBullBreak = hasBreak and breakDir == 1
    isBearBreak = hasBreak and breakDir == -1
    showTgts = showTargetRails and actionState == "READY" and not na(targetOne) and not na(targetTwo)

    yHigh = refHigh
    yLow = refLow
    yT1 = targetOne
    yT2 = targetTwo

    // De-collide in the known vertical order for each case.
    if showTgts and isBullBreak
        // top -> bottom : T2, T1, W High (broken), W Low
        if yT1 - yHigh < gap
            yT1 := yHigh + gap
        if yT2 - yT1 < gap
            yT2 := yT1 + gap
        if yHigh - yLow < gap
            yLow := yHigh - gap
    else if showTgts and isBearBreak
        // top -> bottom : W High, W Low (broken), T1, T2
        if yHigh - yLow < gap
            yHigh := yLow + gap
        if yLow - yT1 < gap
            yT1 := yLow - gap
        if yT1 - yT2 < gap
            yT2 := yT1 - gap
    else
        // no targets shown : just keep W High / W Low apart
        if yHigh - yLow < gap
            mid = (yHigh + yLow) / 2.0
            yHigh := mid + gap / 2.0
            yLow := mid - gap / 2.0

    highTagText = "W HIGH | " + str.tostring(refHigh, format.mintick) + (isBullBreak ? " | BROKEN" : "")
    lowTagText = "W LOW | " + str.tostring(refLow, format.mintick) + (isBearBreak ? " | BROKEN" : "")
    highTagBg = isBullBreak ? color.new(bullColor, 0) : color.new(bullColor, 22)
    lowTagBg = isBearBreak ? color.new(bearColor, 0) : color.new(bearColor, 22)

    if not na(tagHigh)
        label.delete(tagHigh)
    if not na(tagLow)
        label.delete(tagLow)
    if not na(tagT1)
        label.delete(tagT1)
    if not na(tagT2)
        label.delete(tagT2)
    if not na(tagHighConnector)
        line.delete(tagHighConnector)
    if not na(tagLowConnector)
        line.delete(tagLowConnector)
    if not na(tagT1Connector)
        line.delete(tagT1Connector)
    if not na(tagT2Connector)
        line.delete(tagT2Connector)
    tagHigh := na
    tagLow := na
    tagT1 := na
    tagT2 := na
    tagHighConnector := na
    tagLowConnector := na
    tagT1Connector := na
    tagT2Connector := na

    tagHighConnector := line.new(rangeRight, refHigh, rangeTagX, yHigh,
         xloc = xloc.bar_index,
         color = color.new(bullColor, 18),
         width = 1)
    tagLowConnector := line.new(rangeRight, refLow, rangeTagX, yLow,
         xloc = xloc.bar_index,
         color = color.new(bearColor, 18),
         width = 1)
    tagHigh := label.new(rangeTagX, yHigh, highTagText,
         style = label.style_label_left,
         textcolor = f_text_on(highTagBg),
         color = highTagBg,
         size = labelSize)
    tagLow := label.new(rangeTagX, yLow, lowTagText,
         style = label.style_label_left,
         textcolor = f_text_on(lowTagBg),
         color = lowTagBg,
         size = labelSize)
    if showTgts
        tagT1Connector := line.new(targetAnchorX, targetOne, targetTagX, yT1,
             xloc = xloc.bar_index,
             color = color.new(neutralColor, 18),
             width = 1)
        tagT2Connector := line.new(targetAnchorX, targetTwo, targetTagX, yT2,
             xloc = xloc.bar_index,
             color = color.new(accentColor, 18),
             width = 1)
        tagT1 := label.new(targetTagX, yT1,
             "T1 | " + str.tostring(targetOne, format.mintick),
             style = label.style_label_left,
             textcolor = f_text_on(neutralColor),
             color = color.new(neutralColor, 8),
             size = labelSize)
        tagT2 := label.new(targetTagX, yT2,
             "T2 | " + str.tostring(targetTwo, format.mintick),
             style = label.style_label_left,
             textcolor = f_text_on(accentColor),
             color = color.new(accentColor, 8),
             size = labelSize)
else if barstate.islast
    if not na(tagHigh)
        label.delete(tagHigh)
        tagHigh := na
    if not na(tagLow)
        label.delete(tagLow)
        tagLow := na
    if not na(tagT1)
        label.delete(tagT1)
        tagT1 := na
    if not na(tagT2)
        label.delete(tagT2)
        tagT2 := na
    if not na(tagHighConnector)
        line.delete(tagHighConnector)
        tagHighConnector := na
    if not na(tagLowConnector)
        line.delete(tagLowConnector)
        tagLowConnector := na
    if not na(tagT1Connector)
        line.delete(tagT1Connector)
        tagT1Connector := na
    if not na(tagT2Connector)
        line.delete(tagT2Connector)
        tagT2Connector := na

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelBgFinal = panelTheme == "Dark" ? panelBg : color.rgb(248, 250, 252)
panelLeftFinal = panelTheme == "Dark" ? color.new(panelBorder, 0) : color.rgb(226, 232, 240)
panelTextFinal = panelTheme == "Dark" ? panelValueCol : color.rgb(15, 23, 42)
panelLabelFinal = panelTheme == "Dark" ? panelLabelCol : color.rgb(71, 85, 105)
scoreText = f_score_text(lastScore)
roomText = na(lastRoom) ? "n/a" : str.tostring(math.round(lastRoom)) + "%"
followCellBg = followBuilding ? panelBgFinal : color.new(followBase, 14)
followCellText = followBuilding ? panelLabelFinal : f_text_on(followBase)

var table panel = table.new(position.top_right, 2, 7, border_width = 1)

if showPanel and barstate.islast
    table.set_position(panel, f_panel_position(panelPositionInput))
    table.set_border_color(panel, panelBorder)
    table.set_frame_color(panel, panelBorder)
    table.clear(panel, 0, 0, 1, 6)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.cell(panel, 0, 0, "AG Pro Weekly Range Break Planner",
         text_color = headerText,
         bgcolor = headerBg,
         text_size = panelSize)
    table.cell(panel, 0, 1, "Range State",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 1, rangeState,
         text_color = panelTextFinal,
         bgcolor = panelBgFinal,
         text_size = panelSize)
    table.cell(panel, 0, 2, "Break Score",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 2, scoreText,
         text_color = panelTextFinal,
         bgcolor = panelBgFinal,
         text_size = panelSize)
    table.cell(panel, 0, 3, "Retest",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 3, retestState,
         text_color = panelTextFinal,
         bgcolor = panelBgFinal,
         text_size = panelSize)
    table.cell(panel, 0, 4, "Room",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 4, roomText,
         text_color = panelTextFinal,
         bgcolor = panelBgFinal,
         text_size = panelSize)
    table.cell(panel, 0, 5, "Follow Rate",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 5, followText,
         text_color = followCellText,
         bgcolor = followCellBg,
         text_size = panelSize)
    table.cell(panel, 0, 6, "Action",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 6, actionState,
         text_color = f_text_on(f_action_base(actionState)),
         bgcolor = f_action_color(actionState),
         text_size = panelSize)

if not showPanel and barstate.islast
    table.clear(panel, 0, 0, 1, 6)

// -------------------------------------------------
// Bar color and alerts
// -------------------------------------------------
barStateColor = actionState == "READY" ? color.new(breakDir == 1 ? bullColor : bearColor, 76) :
     actionState == "MONITOR" ? color.new(accentColor, 84) :
     actionState == "INVALIDATED" ? color.new(bearColor, 80) :
     actionState == "EXPIRED" ? color.new(panelBorder, 84) : na
barcolor(showBarColors ? barStateColor : na)

alertcondition(alertReady and readyEvent and breakDir == 1, "Bullish Weekly Range Break Ready",
     "AG Pro WRB | BULLISH WEEKLY RANGE BREAK READY | {{ticker}} | {{interval}}")
alertcondition(alertReady and readyEvent and breakDir == -1, "Bearish Weekly Range Break Ready",
     "AG Pro WRB | BEARISH WEEKLY RANGE BREAK READY | {{ticker}} | {{interval}}")
alertcondition(alertInvalidated and invalidatedEvent, "Weekly Range Break Invalidated",
     "AG Pro WRB | WEEKLY RANGE BREAK INVALIDATED | {{ticker}} | {{interval}}")
alertcondition(alertExpired and expiredEvent, "Weekly Range Break Expired",
     "AG Pro WRB | WEEKLY RANGE BREAK EXPIRED | {{ticker}} | {{interval}}")
````

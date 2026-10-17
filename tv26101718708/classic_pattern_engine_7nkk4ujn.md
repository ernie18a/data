# Classic Pattern Engine

- url: https://www.tradingview.com/script/7nkk4UjN-Classic-Pattern-Engine/
- type: indicator
- pine_id: PUB;3182b883f8a44a59b58f3d098f95a060
- version: 1.0

## Description

Is a chart-pattern detection tool built around confirmed swing pivots.

The script identifies selected classic chart-pattern structures and draws them directly on the chart. It is designed as a visual pattern-mapping tool, not as an automated trading system.

What the script detects

Reversal patterns:
- Double Top
- Double Bottom
- Triple Top
- Triple Bottom
- Head and Shoulders
- Inverted Head and Shoulders

Continuation / structure patterns:
- Rectangles
- Ascending Triangle
- Descending Triangle
- Symmetrical Triangle
- Rising Wedge
- Falling Wedge
- Bull Flag
- Bear Flag
- Bullish Pennant
- Bearish Pennant

How it works

The script uses confirmed pivot highs and pivot lows to build a swing structure. It then compares the most recent confirmed swings against geometric conditions such as:

- Similarity of highs or lows
- Pattern height relative to ATR
- Slope of upper and lower boundaries
- Convergence or parallel behavior
- Pattern duration
- Flag or pennant context when applicable

Each detected pattern receives a quality score. This score is based on the geometry of the pattern, such as symmetry, height, similarity of key swing points, slope behavior, and structure fit. The score is intended to help users filter weaker shapes from cleaner structures.

Entry, Stop, and Target levels

The script can display Entry, Stop, and Target reference levels for detected patterns.

These levels are geometric references derived from the detected pattern structure. They are not trade recommendations.

The script can also track the state of the detected setup:

- Pending: the pattern is detected but entry has not been triggered
- Active: entry level has been reached
- Target Hit: price reached the target reference level
- Stop Hit: price reached the stop reference level
- Expired: the setup remained unresolved beyond the selected time window

The Entry label can also show an estimated R:R value based on the distance between Entry, Stop, and Target.

Main settings

Detection:
- Pivot strength
- Equality tolerance in ATR
- Minimum pattern height
- Minimum pattern quality
- Maximum pattern length

Display:
- Show only latest pattern
- Show pattern lines
- Show entry / stop / target levels
- Show R:R in entry label
- Fade inactive levels after result
- Entry / stop / target projection length
- Pattern line width
- Entry / stop / target line width
- Entry / stop / target label size

Colors:
- Pattern colors
- Entry line color
- Stop line color
- Target line color
- Entry text color
- Stop text color
- Target text color
- Resolved / inactive level styling

How to use

Use the indicator as a visual assistant for identifying and reviewing chart-pattern structures.

A detected pattern means the required swing geometry has formed. It does not mean that the pattern will complete successfully or that price will reach the target.

Users can choose to display only the latest pattern for a clean chart, or keep more visual history by changing the display settings.

Repainting note

This script uses confirmed pivot highs and confirmed pivot lows. A pattern can only be detected after the required pivot confirmation bars have passed.

For this reason, pattern drawings may appear on earlier swing points after confirmation. This is a normal confirmation delay caused by pivot-based detection.

The script does not use lookahead. Entry, stop, target, and state labels update only as new bars develop after a pattern has been detected.

Limitations

Chart patterns are geometric interpretations of price structure. Different traders may classify the same structure differently.

The displayed Entry, Stop, Target, and R:R values are reference levels calculated from the pattern geometry. They should not be treated as financial advice, trading instructions, or guaranteed outcomes.

The indicator is intended for chart analysis, education, and visual pattern review.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) ADXAE

//@version=6
indicator("Classic Pattern Engine", "Pattern Engine", overlay=true, max_lines_count=500, max_labels_count=300, max_bars_back=500)

//==============================================================================
// Classic Pattern Engine
//==============================================================================
// Detects and draws classic chart patterns from confirmed swing pivots.
//
// Pattern families:
// - Reversal: Double Top/Bottom, Triple Top/Bottom, Head and Shoulders,
//   Inverted Head and Shoulders.
// - Channels: Rectangles, Triangles, Wedges.
// - Flag structures: Flags and Pennants.
//
// Design goals:
// - Cleaner default chart.
// - Quality scoring before drawing.
// - Entry / stop / target levels with state tracking and optional R:R.
// - Optional last-pattern-only mode, ON by default.
// - No performance claims and no forecast language.
//
// Notes:
// - Swing pivots are confirmed with ta.pivothigh/ta.pivotlow.
// - A pattern can only be drawn after the last required swing is confirmed.
// - Entry, stop, and target levels are geometric references, not trade recommendations.
//==============================================================================

//==============================================================================
// Inputs
//==============================================================================

grpDetection = "1) Detection"

piv = input.int(
     6,
     "Pivot strength",
     minval=2,
     maxval=25,
     group=grpDetection,
     tooltip="Higher values detect larger and cleaner structures. Patterns appear only after the confirming pivot is complete.")

tolAtr = input.float(
     0.60,
     "Equality tolerance in ATR",
     minval=0.10,
     maxval=2.00,
     step=0.10,
     group=grpDetection,
     tooltip="Tolerance used for similar tops/bottoms and shoulders.")

minHeightAtr = input.float(
     2.50,
     "Minimum pattern height in ATR",
     minval=0.50,
     maxval=10.00,
     step=0.50,
     group=grpDetection)

minQuality = input.float(
     65.0,
     "Minimum pattern quality",
     minval=0.0,
     maxval=100.0,
     step=5.0,
     group=grpDetection,
     tooltip="Higher values draw fewer but cleaner patterns.")

flatSlopeAtr = input.float(
     0.06,
     "Flat slope limit ATR/bar",
     minval=0.01,
     maxval=0.30,
     step=0.01,
     group=grpDetection)

maxPatternBars = input.int(
     140,
     "Maximum pattern length",
     minval=20,
     maxval=500,
     group=grpDetection)

minChannelBars = input.int(
     12,
     "Minimum channel length",
     minval=6,
     maxval=80,
     group=grpDetection)


grpFamilies = "2) Pattern Families"

showReversal = input.bool(true, "Reversal patterns", group=grpFamilies)
showChannels = input.bool(true, "Triangles / wedges / rectangles", group=grpFamilies)
showFlags = input.bool(true, "Flags / pennants", group=grpFamilies)

flagMaxBars = input.int(
     55,
     "Maximum flag / pennant length",
     minval=10,
     maxval=160,
     group=grpFamilies)

minPoleAtr = input.float(
     3.00,
     "Minimum flag pole in ATR",
     minval=1.00,
     maxval=12.00,
     step=0.50,
     group=grpFamilies)


grpDisplay = "3) Display"

showOnlyLastPattern = input.bool(
     true,
     "Show only latest pattern",
     group=grpDisplay,
     tooltip="ON by default for a clean chart. Turn OFF to keep older patterns, capped by the drawing limit.")

showMeasuredLevels = input.bool(
     true,
     "Show entry / stop / target levels",
     group=grpDisplay,
     tooltip="ON by default. These levels are geometric references from the detected pattern, not trade recommendations.")

showQualityInLabel = input.bool(
     true,
     "Show quality score in label",
     group=grpDisplay)

showPatternLines = input.bool(
     true,
     "Show pattern lines",
     group=grpDisplay)

labelSizeInput = input.string(
     "Small",
     "Pattern label size",
     options=["Tiny", "Small", "Normal"],
     group=grpDisplay)

patternLineWidth = input.int(
     2,
     "Pattern line width",
     minval=1,
     maxval=5,
     group=grpDisplay)

necklineLineWidth = input.int(
     2,
     "Neckline line width",
     minval=1,
     maxval=5,
     group=grpDisplay)

levelProjectionBars = input.int(
     36,
     "Entry / stop / target projection bars",
     minval=8,
     maxval=140,
     group=grpDisplay,
     active=showMeasuredLevels)

levelLineWidth = input.int(
     2,
     "Entry / stop / target line width",
     minval=1,
     maxval=5,
     group=grpDisplay,
     active=showMeasuredLevels)

levelLineStyleInput = input.string(
     "Solid",
     "Entry / stop / target line style",
     options=["Solid", "Dashed", "Dotted"],
     group=grpDisplay,
     active=showMeasuredLevels)

levelLabelSizeInput = input.string(
     "Small",
     "Entry / stop / target label size",
     options=["Tiny", "Small", "Normal"],
     group=grpDisplay,
     active=showMeasuredLevels)

levelLabelBgTransparency = input.int(
     12,
     "Entry / stop / target label transparency",
     minval=0,
     maxval=100,
     group=grpDisplay,
     active=showMeasuredLevels)

showPriceInLevelLabels = input.bool(
     true,
     "Show prices in level labels",
     group=grpDisplay,
     active=showMeasuredLevels)

showRiskReward = input.bool(
     true,
     "Show R:R in entry label",
     group=grpDisplay,
     active=showMeasuredLevels)

trackPatternState = input.bool(
     true,
     "Track pattern state",
     group=grpDisplay,
     tooltip="Shows Pending, Active, Target Hit, Stop Hit, or Expired for the latest pattern.",
     active=showMeasuredLevels)

keepLevelsExtended = input.bool(
     true,
     "Keep levels extended until resolved",
     group=grpDisplay,
     active=showMeasuredLevels)

showStateLabel = input.bool(
     true,
     "Show one state label",
     group=grpDisplay,
     tooltip="Shows only one state label: Pending, Active, Target Hit, Stop Hit, or Expired.",
     active=trackPatternState)

showStopTargetOnlyAfterEntry = input.bool(
     false,
     "Show stop / target only after entry",
     group=grpDisplay,
     active=trackPatternState)

fadeInactiveResolvedLevels = input.bool(
     true,
     "Fade inactive levels after result",
     group=grpDisplay,
     active=trackPatternState)

resolvedFadeTransparency = input.int(
     70,
     "Inactive resolved level transparency",
     minval=0,
     maxval=100,
     group=grpDisplay,
     active=fadeInactiveResolvedLevels)

expireAfterBars = input.int(
     80,
     "Expire pattern after bars",
     minval=10,
     maxval=500,
     group=grpDisplay,
     active=trackPatternState)

maxDrawingObjects = input.int(
     180,
     "Maximum stored drawing objects",
     minval=40,
     maxval=480,
     group=grpDisplay,
     tooltip="Used only when Show only latest pattern is OFF.")


grpColors = "4) Colors"

topColor = input.color(color.rgb(197, 127, 134), "Top / bearish reversal color", group=grpColors)
bottomColor = input.color(color.rgb(132, 187, 161), "Bottom / bullish reversal color", group=grpColors)
channelColor = input.color(color.rgb(120, 150, 190), "Channel pattern color", group=grpColors)
flagColor = input.color(color.rgb(212, 180, 131), "Flag / pennant color", group=grpColors)
neutralColor = input.color(color.rgb(164, 171, 183), "Neckline / neutral color", group=grpColors)
labelTextColor = input.color(color.rgb(16, 20, 26), "Pattern label text color", group=grpColors)

entryLineColor = input.color(color.rgb(120, 150, 190), "Entry line color", group=grpColors)
stopLineColor = input.color(color.rgb(216, 96, 92), "Stop line color", group=grpColors)
targetLineColor = input.color(color.rgb(38, 166, 154), "Target line color", group=grpColors)

entryTextColor = input.color(color.white, "Entry text color", group=grpColors)
stopTextColor = input.color(color.white, "Stop text color", group=grpColors)
targetTextColor = input.color(color.white, "Target text color", group=grpColors)

statePendingColor = input.color(color.rgb(164, 171, 183), "Pending state color", group=grpColors)
stateActiveColor = input.color(color.rgb(88, 166, 255), "Active state color", group=grpColors)
stateTargetColor = input.color(color.rgb(38, 166, 154), "Target hit state color", group=grpColors)
stateStopColor = input.color(color.rgb(216, 96, 92), "Stop hit state color", group=grpColors)
stateExpiredColor = input.color(color.rgb(120, 120, 120), "Expired / inactive color", group=grpColors)
stateTextColor = input.color(color.white, "State label text color", group=grpColors)


//==============================================================================
// Shared values
//==============================================================================

atr = ta.atr(14)
tol = tolAtr * atr
minHeight = minHeightAtr * atr

labelSize =
     labelSizeInput == "Tiny" ? size.tiny :
     labelSizeInput == "Normal" ? size.normal :
     size.small

levelLabelSize =
     levelLabelSizeInput == "Tiny" ? size.tiny :
     levelLabelSizeInput == "Normal" ? size.normal :
     size.small


//==============================================================================
// Drawing storage helpers
//==============================================================================

var line[] drawnLines = array.new_line()
var label[] drawnLabels = array.new_label()

var line[] activeLevelLines = array.new_line()
var label[] activeLevelLabels = array.new_label()
var label[] activeStateLabels = array.new_label()
var float[] activeLevelValues = array.new_float()
var int[] activeDirection = array.new_int()
var int[] activeCreatedBar = array.new_int()
var int[] activePatternState = array.new_int()
var string[] activePatternName = array.new_string()

f_clear_drawings() =>
    while array.size(drawnLines) > 0
        line.delete(array.shift(drawnLines))
    while array.size(drawnLabels) > 0
        label.delete(array.shift(drawnLabels))
    array.clear(activeLevelLines)
    array.clear(activeLevelLabels)
    array.clear(activeStateLabels)
    array.clear(activeLevelValues)
    array.clear(activeDirection)
    array.clear(activeCreatedBar)
    array.clear(activePatternState)
    array.clear(activePatternName)

f_trim_drawings() =>
    while array.size(drawnLines) > maxDrawingObjects
        line.delete(array.shift(drawnLines))
    while array.size(drawnLabels) > maxDrawingObjects
        label.delete(array.shift(drawnLabels))

f_draw_line(x1, y1, x2, y2, col, style, width) =>
    line ln = line.new(x1, y1, x2, y2, xloc=xloc.bar_index, color=col, style=style, width=width)
    array.push(drawnLines, ln)
    if not showOnlyLastPattern
        f_trim_drawings()
    ln

f_draw_label(x, y, txt, st, col, txtCol, sz) =>
    label lb = label.new(x, y, txt, xloc=xloc.bar_index, style=st, color=col, textcolor=txtCol, size=sz)
    array.push(drawnLabels, lb)
    if not showOnlyLastPattern
        f_trim_drawings()
    lb

f_prepare_new_drawing() =>
    if showOnlyLastPattern
        f_clear_drawings()


//==============================================================================
// Math helpers
//==============================================================================

f_clamp(value, minValue, maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_val(x1, y1, x2, y2, x) =>
    y1 + (y2 - y1) * (x - x1) / math.max(x2 - x1, 1)

f_similarity_score(a, b, tolerance) =>
    tolerance > 0.0 ? 100.0 * f_clamp(1.0 - math.abs(a - b) / tolerance, 0.0, 1.0) : 0.0

f_height_score(height, requiredHeight) =>
    requiredHeight > 0.0 ? 100.0 * f_clamp(height / (requiredHeight * 1.75), 0.0, 1.0) : 0.0

f_symmetry_score(leftBars, rightBars) =>
    span = math.max(leftBars + rightBars, 1)
    100.0 * f_clamp(1.0 - math.abs(leftBars - rightBars) / span, 0.0, 1.0)

f_quality_text(q) =>
    q >= 85.0 ? "Strong" :
     q >= 72.0 ? "Good" :
     "Valid"

f_label_text(name, q) =>
    showQualityInLabel ? name + "\nQ " + str.tostring(q, "#") + " - " + f_quality_text(q) : name

f_price_text(price) =>
    showPriceInLevelLabels ? "\n" + str.tostring(price, format.mintick) : ""

f_rr_text(entryLevel, stopLevel, targetLevel) =>
    float risk = math.abs(entryLevel - stopLevel)
    float reward = math.abs(targetLevel - entryLevel)
    showRiskReward and risk > syminfo.mintick ? "\nR:R " + str.tostring(reward / risk, "#.##") : ""

f_entry_label_text(entryLevel, stopLevel, targetLevel) =>
    "Entry" + f_price_text(entryLevel) + f_rr_text(entryLevel, stopLevel, targetLevel)

f_state_text(state) =>
    state == 1 ? "Active" :
     state == 2 ? "Target Hit" :
     state == 3 ? "Stop Hit" :
     state == 4 ? "Expired" :
     "Pending"

f_state_color(state) =>
    state == 1 ? stateActiveColor :
     state == 2 ? stateTargetColor :
     state == 3 ? stateStopColor :
     state == 4 ? stateExpiredColor :
     statePendingColor


//==============================================================================
// ZigZag from confirmed pivots
//==============================================================================

var int[] swingBars = array.new_int()
var float[] swingPrices = array.new_float()
var bool[] swingIsHigh = array.new_bool()

f_push_swing(b, p, isHigh) =>
    int n = array.size(swingBars)

    if n > 0 and array.get(swingIsHigh, n - 1) == isHigh
        float oldPrice = array.get(swingPrices, n - 1)

        if (isHigh and p > oldPrice) or (not isHigh and p < oldPrice)
            array.set(swingBars, n - 1, b)
            array.set(swingPrices, n - 1, p)
    else
        array.push(swingBars, b)
        array.push(swingPrices, p)
        array.push(swingIsHigh, isHigh)

        if array.size(swingBars) > 18
            array.shift(swingBars)
            array.shift(swingPrices)
            array.shift(swingIsHigh)

    true

f_n() =>
    array.size(swingBars)

f_price(k) =>
    array.get(swingPrices, array.size(swingPrices) - 1 - k)

f_bar(k) =>
    array.get(swingBars, array.size(swingBars) - 1 - k)

f_is_high(k) =>
    array.get(swingIsHigh, array.size(swingIsHigh) - 1 - k)


//==============================================================================
// Drawing helpers for patterns
//==============================================================================

f_draw_zigzag(kEnd, col) =>
    if showPatternLines
        for k = 0 to kEnd - 1
            f_draw_line(f_bar(k + 1), f_price(k + 1), f_bar(k), f_price(k), col, line.style_solid, patternLineWidth)

f_draw_measured_levels(x, entryLevel, stopLevel, targetLevel, direction, patternName) =>
    if showMeasuredLevels
        int x2 = x + levelProjectionBars
        levelStyle = levelLineStyleInput == "Dotted" ? line.style_dotted :
             levelLineStyleInput == "Dashed" ? line.style_dashed :
             line.style_solid

        bool hideStopTarget = trackPatternState and showStopTargetOnlyAfterEntry

        line entryLine = f_draw_line(x, entryLevel, x2, entryLevel, entryLineColor, levelStyle, levelLineWidth)
        line stopLine = f_draw_line(x, stopLevel, x2, stopLevel, hideStopTarget ? color.new(stopLineColor, 100) : stopLineColor, levelStyle, levelLineWidth)
        line targetLine = f_draw_line(x, targetLevel, x2, targetLevel, hideStopTarget ? color.new(targetLineColor, 100) : targetLineColor, levelStyle, levelLineWidth)

        label entryLabel = f_draw_label(x2, entryLevel, f_entry_label_text(entryLevel, stopLevel, targetLevel), label.style_label_left, color.new(entryLineColor, levelLabelBgTransparency), entryTextColor, levelLabelSize)
        label stopLabel = f_draw_label(x2, stopLevel, "Stop" + f_price_text(stopLevel), label.style_label_left, color.new(stopLineColor, hideStopTarget ? 100 : levelLabelBgTransparency), hideStopTarget ? color.new(stopTextColor, 100) : stopTextColor, levelLabelSize)
        label targetLabel = f_draw_label(x2, targetLevel, "Target" + f_price_text(targetLevel), label.style_label_left, color.new(targetLineColor, hideStopTarget ? 100 : levelLabelBgTransparency), hideStopTarget ? color.new(targetTextColor, 100) : targetTextColor, levelLabelSize)

        array.clear(activeLevelLines)
        array.push(activeLevelLines, entryLine)
        array.push(activeLevelLines, stopLine)
        array.push(activeLevelLines, targetLine)

        array.clear(activeLevelLabels)
        array.push(activeLevelLabels, entryLabel)
        array.push(activeLevelLabels, stopLabel)
        array.push(activeLevelLabels, targetLabel)

        array.clear(activeLevelValues)
        array.push(activeLevelValues, entryLevel)
        array.push(activeLevelValues, stopLevel)
        array.push(activeLevelValues, targetLevel)

        array.clear(activeDirection)
        array.push(activeDirection, direction)

        array.clear(activeCreatedBar)
        array.push(activeCreatedBar, bar_index)

        array.clear(activePatternState)
        array.push(activePatternState, 0)

        array.clear(activePatternName)
        array.push(activePatternName, patternName)

        array.clear(activeStateLabels)

f_draw_reversal(kEnd, name, isTop, nx1, ny1, nx2, ny2, extreme, extremeBar, q) =>
    f_prepare_new_drawing()

    color col = isTop ? topColor : bottomColor

    f_draw_zigzag(kEnd, col)

    int xEnd = f_bar(0) + levelProjectionBars
    float neckEnd = f_val(nx1, ny1, nx2, ny2, xEnd)

    if showPatternLines
        f_draw_line(nx1, ny1, xEnd, neckEnd, neutralColor, line.style_dashed, necklineLineWidth)

    int xMid = int((f_bar(kEnd) + f_bar(0)) / 2)
    float yLabel = isTop ? extreme + atr : extreme - atr

    f_draw_label(
         xMid,
         yLabel,
         f_label_text(name, q),
         isTop ? label.style_label_down : label.style_label_up,
         color.new(col, 18),
         labelTextColor,
         labelSize)

    float neckAtExtreme = f_val(nx1, ny1, nx2, ny2, extremeBar)
    float neckAtEnd = f_val(nx1, ny1, nx2, ny2, f_bar(0))
    float height = math.abs(extreme - neckAtExtreme)

    float invalidLevel = isTop ? extreme + 0.50 * atr : extreme - 0.50 * atr
    float measuredLevel = isTop ? neckAtEnd - height : neckAtEnd + height

    f_draw_measured_levels(f_bar(0) + 2, neckAtEnd, invalidLevel, measuredLevel, isTop ? -1 : 1, name)


f_pattern_bias(name) =>
    name == "Bullish Rectangle" ? 1 :
     name == "Ascending Triangle" ? 1 :
     name == "Falling Wedge" ? 1 :
     name == "Bull Flag" ? 1 :
     name == "Bullish Pennant" ? 1 :
     name == "Bearish Rectangle" ? -1 :
     name == "Descending Triangle" ? -1 :
     name == "Rising Wedge" ? -1 :
     name == "Bear Flag" ? -1 :
     name == "Bearish Pennant" ? -1 :
     0

f_draw_channel_levels(name, x, upperLevel, lowerLevel, patternHeight) =>
    int bias = f_pattern_bias(name)

    if showMeasuredLevels and bias != 0 and patternHeight > 0
        float entryLevel = bias == 1 ? upperLevel : lowerLevel
        float stopLevel = bias == 1 ? lowerLevel - 0.50 * atr : upperLevel + 0.50 * atr
        float targetLevel = bias == 1 ? entryLevel + patternHeight : entryLevel - patternHeight
        f_draw_measured_levels(x + 2, entryLevel, stopLevel, targetLevel, bias, name)


//==============================================================================
// Pivot stream
//==============================================================================

ph = ta.pivothigh(high, piv, piv)
pl = ta.pivotlow(low, piv, piv)

if not na(ph)
    f_push_swing(bar_index - piv, ph, true)

if not na(pl)
    f_push_swing(bar_index - piv, pl, false)

newPivot = not na(ph) or not na(pl)


//==============================================================================
// Reversal detection
//==============================================================================

var int lastTopPatternEnd = 0
var int lastBottomPatternEnd = 0

bool reversalEvent = false
string reversalName = ""

if newPivot and showReversal
    int n = f_n()

    // Top family: latest confirmed swing is a high.
    if n >= 3 and f_is_high(0)
        bool made = false

        if n >= 5
            float h3 = f_price(0)
            float l2 = f_price(1)
            float h2 = f_price(2)
            float l1 = f_price(3)
            float h1 = f_price(4)

            int b3 = f_bar(0)
            int b2 = f_bar(2)
            int b1 = f_bar(4)

            bool spanOk = f_bar(0) - f_bar(4) <= maxPatternBars and f_bar(4) > lastTopPatternEnd

            float necklineAtHead = f_val(f_bar(3), l1, f_bar(1), l2, b2)
            float hsHeight = h2 - necklineAtHead
            float shoulderScore = f_similarity_score(h1, h3, 2.0 * tol)
            float headScore = f_height_score(h2 - math.max(h1, h3), tol)
            float heightScore = f_height_score(hsHeight, minHeight)
            float symmetryScore = f_symmetry_score(b2 - b1, b3 - b2)
            float hsQuality = 0.30 * shoulderScore + 0.25 * headScore + 0.30 * heightScore + 0.15 * symmetryScore

            if spanOk and h2 > h1 and h2 > h3 and h2 - math.max(h1, h3) >= tol and math.abs(h1 - h3) <= 2.0 * tol and hsHeight >= minHeight and hsQuality >= minQuality
                f_draw_reversal(4, "Head and Shoulders", true, f_bar(3), l1, f_bar(1), l2, h2, b2, hsQuality)
                lastTopPatternEnd := f_bar(0)
                made := true
                reversalEvent := true
                reversalName := "Head and Shoulders"

            float topRange = math.max(h1, math.max(h2, h3)) - math.min(l1, l2)
            float eq12 = f_similarity_score(h1, h2, tol)
            float eq23 = f_similarity_score(h2, h3, tol)
            float eq13 = f_similarity_score(h1, h3, tol)
            float tripleEqScore = (eq12 + eq23 + eq13) / 3.0
            float tripleHeightScore = f_height_score(topRange, minHeight)
            float tripleQuality = 0.60 * tripleEqScore + 0.40 * tripleHeightScore

            if not made and spanOk and math.abs(h1 - h2) <= tol and math.abs(h2 - h3) <= tol and math.abs(h1 - h3) <= tol and topRange >= minHeight and tripleQuality >= minQuality
                float neckline = math.min(l1, l2)
                f_draw_reversal(4, "Triple Top", true, f_bar(3), neckline, f_bar(1), neckline, math.max(h1, math.max(h2, h3)), b2, tripleQuality)
                lastTopPatternEnd := f_bar(0)
                made := true
                reversalEvent := true
                reversalName := "Triple Top"

        // Double Top
        if not made and n >= 3
            float h2 = f_price(0)
            float l1 = f_price(1)
            float h1 = f_price(2)

            int b2 = f_bar(0)
            int b1 = f_bar(2)

            bool spanOk = f_bar(0) - f_bar(2) <= maxPatternBars and f_bar(2) > lastTopPatternEnd
            float height = math.min(h1, h2) - l1
            float eqScore = f_similarity_score(h1, h2, tol)
            float heightScore = f_height_score(height, minHeight)
            float symmetryScore = f_symmetry_score(f_bar(1) - b1, b2 - f_bar(1))
            float quality = 0.45 * eqScore + 0.40 * heightScore + 0.15 * symmetryScore

            if spanOk and math.abs(h1 - h2) <= tol and height >= minHeight and quality >= minQuality
                f_draw_reversal(2, "Double Top", true, f_bar(1), l1, f_bar(0), l1, math.max(h1, h2), f_bar(1), quality)
                lastTopPatternEnd := f_bar(0)
                reversalEvent := true
                reversalName := "Double Top"

    // Bottom family: latest confirmed swing is a low.
    if n >= 3 and not f_is_high(0)
        bool made = false

        if n >= 5
            float l3 = f_price(0)
            float h2 = f_price(1)
            float l2 = f_price(2)
            float h1 = f_price(3)
            float l1 = f_price(4)

            int b3 = f_bar(0)
            int b2 = f_bar(2)
            int b1 = f_bar(4)

            bool spanOk = f_bar(0) - f_bar(4) <= maxPatternBars and f_bar(4) > lastBottomPatternEnd

            float necklineAtHead = f_val(f_bar(3), h1, f_bar(1), h2, b2)
            float hsHeight = necklineAtHead - l2
            float shoulderScore = f_similarity_score(l1, l3, 2.0 * tol)
            float headScore = f_height_score(math.min(l1, l3) - l2, tol)
            float heightScore = f_height_score(hsHeight, minHeight)
            float symmetryScore = f_symmetry_score(b2 - b1, b3 - b2)
            float ihsQuality = 0.30 * shoulderScore + 0.25 * headScore + 0.30 * heightScore + 0.15 * symmetryScore

            if spanOk and l2 < l1 and l2 < l3 and math.min(l1, l3) - l2 >= tol and math.abs(l1 - l3) <= 2.0 * tol and hsHeight >= minHeight and ihsQuality >= minQuality
                f_draw_reversal(4, "Inverted Head and Shoulders", false, f_bar(3), h1, f_bar(1), h2, l2, b2, ihsQuality)
                lastBottomPatternEnd := f_bar(0)
                made := true
                reversalEvent := true
                reversalName := "Inverted Head and Shoulders"

            float bottomRange = math.max(h1, h2) - math.min(l1, math.min(l2, l3))
            float eq12 = f_similarity_score(l1, l2, tol)
            float eq23 = f_similarity_score(l2, l3, tol)
            float eq13 = f_similarity_score(l1, l3, tol)
            float tripleEqScore = (eq12 + eq23 + eq13) / 3.0
            float tripleHeightScore = f_height_score(bottomRange, minHeight)
            float tripleQuality = 0.60 * tripleEqScore + 0.40 * tripleHeightScore

            if not made and spanOk and math.abs(l1 - l2) <= tol and math.abs(l2 - l3) <= tol and math.abs(l1 - l3) <= tol and bottomRange >= minHeight and tripleQuality >= minQuality
                float neckline = math.max(h1, h2)
                f_draw_reversal(4, "Triple Bottom", false, f_bar(3), neckline, f_bar(1), neckline, math.min(l1, math.min(l2, l3)), b2, tripleQuality)
                lastBottomPatternEnd := f_bar(0)
                made := true
                reversalEvent := true
                reversalName := "Triple Bottom"

        // Double Bottom
        if not made and n >= 3
            float l2 = f_price(0)
            float h1 = f_price(1)
            float l1 = f_price(2)

            int b2 = f_bar(0)
            int b1 = f_bar(2)

            bool spanOk = f_bar(0) - f_bar(2) <= maxPatternBars and f_bar(2) > lastBottomPatternEnd
            float height = h1 - math.max(l1, l2)
            float eqScore = f_similarity_score(l1, l2, tol)
            float heightScore = f_height_score(height, minHeight)
            float symmetryScore = f_symmetry_score(f_bar(1) - b1, b2 - f_bar(1))
            float quality = 0.45 * eqScore + 0.40 * heightScore + 0.15 * symmetryScore

            if spanOk and math.abs(l1 - l2) <= tol and height >= minHeight and quality >= minQuality
                f_draw_reversal(2, "Double Bottom", false, f_bar(1), h1, f_bar(0), h1, math.min(l1, l2), f_bar(1), quality)
                lastBottomPatternEnd := f_bar(0)
                reversalEvent := true
                reversalName := "Double Bottom"


//==============================================================================
// Channel / triangle / wedge / flag detection
//==============================================================================

var string lastChannelKey = ""
var line channelUpperLine = na
var line channelLowerLine = na
var label channelLabel = na

bool channelEvent = false
string channelName = ""

if newPivot and (showChannels or showFlags) and f_n() >= 4
    int highB = f_is_high(0) ? 0 : 1
    int lowB = f_is_high(0) ? 1 : 0
    int highA = highB + 2
    int lowA = lowB + 2

    float high2 = f_price(highB)
    float high1 = f_price(highA)
    float low2 = f_price(lowB)
    float low1 = f_price(lowA)

    int barHigh2 = f_bar(highB)
    int barHigh1 = f_bar(highA)
    int barLow2 = f_bar(lowB)
    int barLow1 = f_bar(lowA)

    int startBar = math.min(barHigh1, barLow1)
    int span = bar_index - startBar

    if span >= minChannelBars and span <= maxPatternBars and atr > 0.0
        float highSlope = (high2 - high1) / math.max(barHigh2 - barHigh1, 1) / atr
        float lowSlope = (low2 - low1) / math.max(barLow2 - barLow1, 1) / atr

        float upperNow = f_val(barHigh1, high1, barHigh2, high2, bar_index)
        float lowerNow = f_val(barLow1, low1, barLow2, low2, bar_index)

        float upperStart = f_val(barHigh1, high1, barHigh2, high2, startBar)
        float lowerStart = f_val(barLow1, low1, barLow2, low2, startBar)

        float widthStart = upperStart - lowerStart
        float widthNow = upperNow - lowerNow

        bool validWidth = widthStart > 0.0 and widthNow > 0.0
        bool converging = validWidth and widthNow < 0.72 * widthStart
        bool parallel = math.abs(highSlope - lowSlope) <= flatSlopeAtr

        bool highFlat = math.abs(highSlope) <= flatSlopeAtr
        bool lowFlat = math.abs(lowSlope) <= flatSlopeAtr
        bool highUp = highSlope > flatSlopeAtr
        bool lowUp = lowSlope > flatSlopeAtr
        bool highDown = highSlope < -flatSlopeAtr
        bool lowDown = lowSlope < -flatSlopeAtr

        int offset = bar_index - startBar
        float poleReturnAtr = offset + 10 <= bar_index and atr > 0.0 ? (nz(close[offset], close) - nz(close[offset + 10], nz(close[offset], close))) / atr : 0.0
        bool poleUp = poleReturnAtr >= minPoleAtr
        bool poleDown = poleReturnAtr <= -minPoleAtr
        bool smallSpan = span <= flagMaxBars

        string name = ""
        color drawColor = channelColor

        if validWidth
            if highFlat and lowFlat
                name := poleReturnAtr >= 1.0 ? "Bullish Rectangle" : poleReturnAtr <= -1.0 ? "Bearish Rectangle" : "Rectangle"

            else if highDown and lowUp
                if smallSpan and (poleUp or poleDown) and showFlags
                    name := poleUp ? "Bullish Pennant" : "Bearish Pennant"
                    drawColor := flagColor
                else
                    name := "Symmetrical Triangle"

            else if highFlat and lowUp
                name := "Ascending Triangle"

            else if highDown and lowFlat
                name := "Descending Triangle"

            else if highUp and lowUp
                if converging
                    name := "Rising Wedge"
                else if parallel and poleDown and smallSpan and showFlags
                    name := "Bear Flag"
                    drawColor := flagColor

            else if highDown and lowDown
                if converging
                    name := "Falling Wedge"
                else if parallel and poleUp and smallSpan and showFlags
                    name := "Bull Flag"
                    drawColor := flagColor

        bool familyAllowed = name != "" and (drawColor == flagColor ? showFlags : showChannels)

        float slopeQuality = parallel ? 80.0 : converging ? 85.0 : 65.0
        float widthQuality = validWidth ? 100.0 * f_clamp(1.0 - widthNow / widthStart, 0.0, 1.0) : 0.0
        float lengthQuality = 100.0 * f_clamp(span / maxPatternBars, 0.0, 1.0)
        float poleQuality = drawColor == flagColor ? 100.0 * f_clamp(math.abs(poleReturnAtr) / minPoleAtr, 0.0, 1.0) : 70.0
        float channelQuality = 0.30 * slopeQuality + 0.30 * math.max(widthQuality, 45.0) + 0.20 * lengthQuality + 0.20 * poleQuality

        if familyAllowed and channelQuality >= minQuality
            string key = name + ":" + str.tostring(startBar)

            int midBar = int((startBar + bar_index) / 2)
            float labelY = f_val(barHigh1, high1, barHigh2, high2, midBar) + atr

            if key == lastChannelKey and not na(channelUpperLine) and not na(channelLowerLine) and not na(channelLabel)
                line.set_xy2(channelUpperLine, bar_index, upperNow)
                line.set_xy2(channelLowerLine, bar_index, lowerNow)
                label.set_xy(channelLabel, midBar, labelY)
                label.set_text(channelLabel, f_label_text(name, channelQuality))
            else
                f_prepare_new_drawing()

                if showPatternLines
                    channelUpperLine := f_draw_line(barHigh1, high1, bar_index, upperNow, drawColor, line.style_solid, patternLineWidth)
                    channelLowerLine := f_draw_line(barLow1, low1, bar_index, lowerNow, drawColor, line.style_solid, patternLineWidth)

                channelLabel := f_draw_label(
                     midBar,
                     labelY,
                     f_label_text(name, channelQuality),
                     label.style_label_down,
                     color.new(drawColor, 18),
                     labelTextColor,
                     labelSize)

                f_draw_channel_levels(name, bar_index, upperNow, lowerNow, math.max(widthStart, widthNow))

                lastChannelKey := key
                channelEvent := true
                channelName := name


//==============================================================================
// Active pattern state tracking
//==============================================================================

bool entryTriggeredEvent = false
bool targetHitEvent = false
bool stopHitEvent = false
bool patternExpiredEvent = false

if trackPatternState and array.size(activeLevelLines) == 3 and array.size(activeLevelLabels) == 3 and array.size(activeLevelValues) == 3 and array.size(activeDirection) == 1 and array.size(activePatternState) == 1 and array.size(activeCreatedBar) == 1
    line entryLine = array.get(activeLevelLines, 0)
    line stopLine = array.get(activeLevelLines, 1)
    line targetLine = array.get(activeLevelLines, 2)

    label entryLabel = array.get(activeLevelLabels, 0)
    label stopLabel = array.get(activeLevelLabels, 1)
    label targetLabel = array.get(activeLevelLabels, 2)

    float entryLevel = array.get(activeLevelValues, 0)
    float stopLevel = array.get(activeLevelValues, 1)
    float targetLevel = array.get(activeLevelValues, 2)

    int direction = array.get(activeDirection, 0)
    int state = array.get(activePatternState, 0)
    int created = array.get(activeCreatedBar, 0)
    int age = bar_index - created

    bool entryTriggered = direction == 1 ? high >= entryLevel : low <= entryLevel
    bool targetHit = direction == 1 ? high >= targetLevel : low <= targetLevel
    bool stopHit = direction == 1 ? low <= stopLevel : high >= stopLevel
    bool expired = age > expireAfterBars

    if state == 0
        if entryTriggered
            state := 1
            array.set(activePatternState, 0, state)
            entryTriggeredEvent := true
        else if stopHit
            state := 3
            array.set(activePatternState, 0, state)
            stopHitEvent := true
        else if expired
            state := 4
            array.set(activePatternState, 0, state)
            patternExpiredEvent := true

    if state == 1
        if targetHit
            state := 2
            array.set(activePatternState, 0, state)
            targetHitEvent := true
        else if stopHit
            state := 3
            array.set(activePatternState, 0, state)
            stopHitEvent := true
        else if expired
            state := 4
            array.set(activePatternState, 0, state)
            patternExpiredEvent := true

    bool resolved = state == 2 or state == 3 or state == 4
    bool showFullLevels = not showStopTargetOnlyAfterEntry or state >= 1
    color inactiveCol = fadeInactiveResolvedLevels ? color.new(stateExpiredColor, resolvedFadeTransparency) : stateExpiredColor

    color entryCol = resolved ? inactiveCol : entryLineColor
    color stopCol = state == 3 ? stateStopColor : resolved ? inactiveCol : showFullLevels ? stopLineColor : color.new(stopLineColor, 100)
    color targetCol = state == 2 ? stateTargetColor : resolved ? inactiveCol : showFullLevels ? targetLineColor : color.new(targetLineColor, 100)

    line.set_color(entryLine, entryCol)
    line.set_color(stopLine, stopCol)
    line.set_color(targetLine, targetCol)

    if keepLevelsExtended and not resolved
        int x2 = bar_index + levelProjectionBars
        line.set_x2(entryLine, x2)
        line.set_x2(stopLine, x2)
        line.set_x2(targetLine, x2)
        label.set_x(entryLabel, x2)
        label.set_x(stopLabel, x2)
        label.set_x(targetLabel, x2)

    label.set_text(entryLabel, f_entry_label_text(entryLevel, stopLevel, targetLevel))
    label.set_text(stopLabel, (state == 3 ? "Stop Hit" : "Stop") + f_price_text(stopLevel))
    label.set_text(targetLabel, (state == 2 ? "Target Hit" : "Target") + f_price_text(targetLevel))

    label.set_color(entryLabel, color.new(resolved ? stateExpiredColor : entryLineColor, resolved and fadeInactiveResolvedLevels ? resolvedFadeTransparency : levelLabelBgTransparency))
    label.set_textcolor(entryLabel, resolved and fadeInactiveResolvedLevels ? color.new(entryTextColor, 25) : entryTextColor)

    label.set_color(stopLabel, color.new(state == 3 ? stateStopColor : resolved ? stateExpiredColor : stopLineColor, not showFullLevels ? 100 : resolved and state != 3 and fadeInactiveResolvedLevels ? resolvedFadeTransparency : levelLabelBgTransparency))
    label.set_textcolor(stopLabel, not showFullLevels ? color.new(stopTextColor, 100) : resolved and state != 3 and fadeInactiveResolvedLevels ? color.new(stopTextColor, 35) : stopTextColor)

    label.set_color(targetLabel, color.new(state == 2 ? stateTargetColor : resolved ? stateExpiredColor : targetLineColor, not showFullLevels ? 100 : resolved and state != 2 and fadeInactiveResolvedLevels ? resolvedFadeTransparency : levelLabelBgTransparency))
    label.set_textcolor(targetLabel, not showFullLevels ? color.new(targetTextColor, 100) : resolved and state != 2 and fadeInactiveResolvedLevels ? color.new(targetTextColor, 35) : targetTextColor)

    if showStateLabel
        int stateX = bar_index + math.max(4, int(levelProjectionBars / 2))
        float stateY = entryLevel
        color stateColor = f_state_color(state)
        string stateText = f_state_text(state)

        if array.size(activeStateLabels) == 0
            label stateLabel = f_draw_label(stateX, stateY, stateText, label.style_label_left, color.new(stateColor, 0), stateTextColor, levelLabelSize)
            array.push(activeStateLabels, stateLabel)
        else
            label stateLabel = array.get(activeStateLabels, 0)
            label.set_x(stateLabel, stateX)
            label.set_y(stateLabel, stateY)
            label.set_text(stateLabel, stateText)
            label.set_color(stateLabel, color.new(stateColor, 0))
            label.set_textcolor(stateLabel, stateTextColor)



//==============================================================================
// Alerts
//==============================================================================

alertcondition(
     reversalEvent,
     title="Pattern Engine reversal pattern",
     message="Classic Pattern Engine detected a completed reversal pattern.")

alertcondition(
     channelEvent,
     title="Pattern Engine channel pattern",
     message="Classic Pattern Engine detected a channel, triangle, wedge, flag, or pennant structure.")

alertcondition(
     entryTriggeredEvent,
     title="Pattern Engine entry triggered",
     message="Classic Pattern Engine: latest pattern entry level was triggered.")

alertcondition(
     targetHitEvent,
     title="Pattern Engine target hit",
     message="Classic Pattern Engine: latest pattern target level was reached.")

alertcondition(
     stopHitEvent,
     title="Pattern Engine stop hit",
     message="Classic Pattern Engine: latest pattern stop level was reached.")

alertcondition(
     patternExpiredEvent,
     title="Pattern Engine pattern expired",
     message="Classic Pattern Engine: latest pattern expired before completion.")

//==============================================================================
// End of file
//==============================================================================
````

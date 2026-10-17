# Triangle Breakout Quality [AGPro Series]

- url: https://www.tradingview.com/script/EJEFXxVF-Triangle-Breakout-Quality-AGPro-Series/
- type: indicator
- pine_id: PUB;076a9b6720074a69a30b05506e89ac8f
- version: 3.0

## Description

Triangle Breakout Quality [AGPro Series]

🔺 OVERVIEW

Triangle Breakout Quality is built for one of the most searched and visually recognizable chart structures in technical analysis: the triangle breakout.

The script automatically detects triangle candidates from confirmed pivot highs and pivot lows, projects the upper and lower converging boundaries, measures how much the structure has compressed, locates the projected apex, and grades the quality of the eventual breakout. After the release, it monitors the first return toward the broken triangle boundary so the user can see whether price accepted the breakout or quickly lost structural quality.

The goal is not to mark every small consolidation or every trendline touch. The goal is to isolate the full triangle sequence:

Formation -> compression -> apex pressure -> boundary release -> first retest state.

That full lifecycle is what gives the tool its own identity. A triangle is not just a range, not just a single diagonal line, and not just a breakout candle. It is a narrowing structure where both sides of price are being compressed into a decision point. This script is designed around that idea from the ground up.

🔹 WHAT MAKES IT DIFFERENT

Most triangle tools stop at drawing two lines. Most breakout tools stop at the first candle outside a boundary. Triangle Breakout Quality does more by turning the structure into a scored, state-aware workflow.

Core differentiators:

• Dual-boundary validation
The script requires both an upper pivot boundary and a lower pivot boundary. The two lines must converge. This prevents the logic from acting like a generic trendline-break detector.

• Compression measurement
The engine compares the opening width of the triangle with the current width. A pattern must show meaningful narrowing before it can qualify.

• Apex pressure logic
The script projects where the upper and lower boundaries intersect and evaluates whether the current structure is close enough to that decision zone to matter.

• Breakout quality score
Every displayed breakout receives a 0-100 score based on compression, apex pressure, breakout distance, candle body participation, close quality, and optional volume expansion.

• Retest state
After a breakout, the script watches the first return toward the broken triangle boundary. A held retest and a failed retest are visually different states, not the same event.

• Premium visual restraint
The chart shows active triangle lines, controlled breakout labels, optional retest labels, subtle candle tint, and a compact AGPro panel. Label density is capped so the layout stays clean for live use and publication screenshots.

🧭 WHY THIS DOES NOT OVERLAP WITH OTHER AGPRO TOOLS

This script is intentionally separated from the existing AGPro breakout and structure family.

It is not Break-Retest Quality, because it does not begin with a horizontal pivot break and then grade the first retest of that static level. Triangle Breakout Quality first requires a valid converging triangle structure.

It is not Failed Break Quality, because it is not centered on false breaks and reclaim behavior. It tracks the primary breakout from a valid triangle and then monitors the first boundary retest.

It is not Consolidation Breakout Quality, because the reference structure is not a horizontal range. A triangle must have two projected pivot boundaries that move toward each other.

It is not Donchian Breakout Quality, because it is not based on period highs and lows or channel escape logic.

It is not ATR Envelope Breakout Quality, because it does not use a volatility envelope as the breakout shell.

It is not Auto Trendline Break Quality, because it does not score isolated trendline breaks. The event only matters when the upper and lower lines together form a valid triangle compression structure.

That distinction matters visually and analytically. On the chart, this script tells a triangle story: converging boundaries, apex pressure, breakout quality, and retest state. It belongs in the chart-pattern lane, not the generic breakout lane.

⚙️ METHODOLOGY

1. Pivot anchors
The script uses confirmed pivot highs and pivot lows to define the latest upper and lower triangle boundaries. This keeps the structure rules transparent and reproducible.

2. Convergence filter
The upper boundary and lower boundary must move toward each other. The current width of the pattern must be smaller than the starting width, and the compression percentage must meet the selected threshold.

3. Width and maturity filters
The pattern must be old enough to represent a real structure, but not so old that it becomes stale. The starting width and current width are also normalized by ATR so the same logic can adapt across symbols and timeframes.

4. Apex projection
The script calculates where the two projected boundaries intersect. This creates the apex pressure layer, which helps separate mature triangle compression from loose diagonal movement.

5. Breakout confirmation
A bullish breakout requires price to close beyond the projected upper boundary by an ATR-normalized buffer. A bearish breakout requires price to close beyond the projected lower boundary by the same type of buffer.

6. Quality score
The breakout score combines:

• Compression quality
• Apex pressure
• Breakout distance beyond the boundary
• Candle body participation
• Close position inside the breakout candle
• Optional volume participation

The result is displayed as a compact grade and score so the chart remains readable.

7. Retest state
After a breakout, the script projects the broken triangle boundary forward internally and evaluates an ATR-scaled retest tolerance around it. If price revisits that boundary area and holds the correct side, the retest is marked as held. If price loses the boundary, the retest state is marked as failed.

📊 PANEL

The AGPro panel summarizes the current structure and latest event:

• Pattern Age
• Compression
• Apex Pressure
• Breakout Side
• Retest Quality
• Current State

Panel location, theme, and font size are adjustable. The first row follows the AGPro publication standard: one merged blue header row containing only the panel title.

🎛️ KEY INPUTS

Triangle Structure
• Pivot Length
• Minimum Pattern Age
• Maximum Pattern Age
• Minimum Compression %
• Minimum Starting Width ATR
• Maximum Current Width ATR
• Maximum Forward Apex Bars

Breakout Quality
• ATR Length
• Volume Average Length
• Use Volume Participation
• Volume Full-Score Ratio
• Minimum Break Distance ATR
• High Quality Threshold
• Minimum Label Score
• Visual Cooldown Bars

Retest State
• Retest Minimum Bars
• Retest Window Bars
• Retest Tolerance ATR

Visual Controls
• Show Triangle Lines
• Show Breakout Labels
• Show Retest Labels
• Tint Breakout Candles
• Label Offset ATR
• Label Font Size
• Maximum Visible Events

Panel
• Show Panel
• Panel Position
• Panel Theme
• Panel Font Size

🔍 HOW TO READ IT

When a valid triangle is forming, the chart displays the converging upper and lower boundaries. The panel reports apex pressure and compression so the projected decision area is visible without adding extra rectangles to the chart. Compression shows how much the pattern has tightened relative to its opening width.

When price closes beyond a valid boundary, the script prints a compact breakout label with a quality grade and score. A higher score means the breakout candle carried stronger structural qualities according to the script's rules.

After the breakout, retest labels and the panel show whether the first return toward the broken triangle boundary held or failed. A held retest suggests cleaner acceptance of the breakout boundary. A failed retest suggests the release lost quality.

Use the tool as a structured chart-reading layer. It is designed to help users compare triangle breakouts by quality, not to replace broader context such as trend, liquidity, session behavior, or personal execution rules.

🧩 BEST USE CASES

• Symmetrical triangle compression
• Ascending triangle pressure
• Descending triangle pressure
• Breakout candle quality review
• First retest monitoring after triangle release
• Screenshot-friendly pattern study
• Multi-symbol scanning for cleaner chart-pattern candidates

🔹 LIMITATIONS AND TRANSPARENCY

Triangle detection is based on confirmed pivots, so the final anchor points appear only after the selected pivot length has elapsed. This is standard pivot behavior and keeps the structure rules visible.

The live triangle can change while new pivots form. Breakout and retest labels are event-based and are designed to remain stable after confirmation.

Volume participation is optional because volume quality varies across markets and feeds. On instruments where volume is less informative, the volume component can be disabled.

The score is a structured description of the triangle release according to the script's internal model. It should be read as context, not as an execution command.

## Source Code

````pine
// -------------------------------------------------
// Triangle Breakout Quality [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.2
//
// Triangle Breakout Quality is a pivot-based chart pattern engine for detecting
// converging triangle structures, measuring apex pressure, grading breakout
// quality, tracking the first retest state after release, and proving how often
// breakouts held their broken boundary. It focuses on symmetrical, ascending,
// and descending triangle compression without becoming a generic consolidation
// range or single-trendline breakout tool. This release adds a clear next-action
// stance, a persistent hold-rate proof layer, and contrast-safe label text.
// -------------------------------------------------

//@version=6
indicator("Triangle Breakout Quality [AGPro Series]",
     shorttitle = "AG Pro TBQ",
     overlay = true,
     max_lines_count = 80,
     max_labels_count = 80)

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
darkText      = color.rgb(17, 24, 39)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupPattern = "Triangle Structure"
pivotLen = input.int(5, "Pivot Length", minval = 2, maxval = 20, group = groupPattern,
     tooltip = "Number of bars used on each side of a pivot. Higher values create fewer, more structural triangle candidates.")
minPatternBars = input.int(24, "Minimum Pattern Age", minval = 10, maxval = 120, group = groupPattern,
     tooltip = "Minimum number of bars between the earliest triangle anchor and the current bar before a pattern can be considered mature.")
maxPatternBars = input.int(140, "Maximum Pattern Age", minval = 40, maxval = 300, group = groupPattern,
     tooltip = "Maximum age of a triangle candidate. Older structures are ignored so stale geometry does not dominate the chart.")
minCompressionPct = input.float(22.0, "Minimum Compression %", minval = 5.0, maxval = 80.0, step = 1.0, group = groupPattern,
     tooltip = "Minimum reduction between the starting triangle width and the current width. This is the core filter that separates true convergence from ordinary range movement.")
minStartWidthAtr = input.float(2.0, "Minimum Starting Width ATR", minval = 0.5, maxval = 10.0, step = 0.25, group = groupPattern,
     tooltip = "Minimum triangle opening width in ATR units. This prevents tiny, visually insignificant patterns from being promoted.")
maxCurrentWidthAtr = input.float(6.0, "Maximum Current Width ATR", minval = 1.0, maxval = 15.0, step = 0.25, group = groupPattern,
     tooltip = "Maximum current triangle width in ATR units. Lower values make the detector focus on tighter apex pressure.")
maxForwardApexBars = input.int(80, "Maximum Forward Apex Bars", minval = 10, maxval = 250, group = groupPattern,
     tooltip = "Maximum number of bars ahead where the projected line intersection may sit. Far-away apex points are treated as weak compression.")

groupBreak = "Breakout Quality"
atrLen = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupBreak,
     tooltip = "ATR length used for volatility-normalized scoring, label offsets, breakout buffers, and retest tolerance.")
volLen = input.int(20, "Volume Average Length", minval = 5, maxval = 100, group = groupBreak,
     tooltip = "Volume baseline used when volume participation is included in the breakout score.")
useVolume = input.bool(true, "Use Volume Participation", group = groupBreak,
     tooltip = "When enabled, breakout quality receives additional credit when volume expands above its recent average.")
volFullScoreRatio = input.float(1.6, "Volume Full-Score Ratio", minval = 1.0, maxval = 4.0, step = 0.1, group = groupBreak,
     tooltip = "Volume-to-average ratio that earns full participation credit in the breakout score.")
minBreakAtr = input.float(0.08, "Minimum Break Distance ATR", minval = 0.0, maxval = 1.0, step = 0.01, group = groupBreak,
     tooltip = "Minimum close distance beyond the triangle boundary, measured in ATR. This avoids classifying boundary kisses as breakouts.")
highQualityScore = input.int(72, "High Quality Threshold", minval = 50, maxval = 95, group = groupBreak,
     tooltip = "Breakouts with scores at or above this threshold receive the strongest visual treatment.")
minLabelScore = input.int(55, "Minimum Label Score", minval = 0, maxval = 95, group = groupBreak,
     tooltip = "Breakout labels are shown only when the quality score reaches this value. Lower it for more activity or raise it for cleaner charts.")
cooldownBars = input.int(12, "Visual Cooldown Bars", minval = 0, maxval = 100, group = groupBreak,
     tooltip = "Minimum number of bars between displayed triangle breakout events unless a completely new triangle structure forms.")

groupProof = "Confirm-Rate Proof"
proofWindow = input.int(10, "Proof Hold Window Bars", minval = 3, maxval = 120, group = groupProof,
     tooltip = "Bars a breakout must hold its broken triangle boundary, without closing back inside, to be counted as a held breakout in the Hold Rate proof statistic.")

groupRetest = "Retest State"
retestMinBars = input.int(2, "Retest Minimum Bars", minval = 1, maxval = 20, group = groupRetest,
     tooltip = "Earliest bar after breakout where a retest can be evaluated.")
retestMaxBars = input.int(24, "Retest Window Bars", minval = 4, maxval = 80, group = groupRetest,
     tooltip = "Maximum number of bars after breakout where the first return to the broken triangle boundary remains relevant.")
retestTolAtr = input.float(0.35, "Retest Tolerance ATR", minval = 0.05, maxval = 2.0, step = 0.05, group = groupRetest,
     tooltip = "ATR-based tolerance around the projected broken triangle boundary used for retest evaluation.")

groupVisual = "Visual Controls"
showTriangleLines = input.bool(true, "Show Triangle Lines", group = groupVisual,
     tooltip = "Displays the active converging upper and lower triangle boundaries built from confirmed pivots.")
showBreakLabels = input.bool(true, "Show Breakout Labels", group = groupVisual,
     tooltip = "Displays compact breakout quality labels outside the candle body using the selected ATR offset.")
showRetestLabels = input.bool(true, "Show Retest Labels", group = groupVisual,
     tooltip = "Displays held or failed retest-state labels after the first return into the broken triangle boundary.")
showCandleTint = input.bool(true, "Tint Breakout Candles", group = groupVisual,
     tooltip = "Applies a subtle candle tint on confirmed triangle breakout bars so the release candle is easy to locate without adding clutter.")
labelOffsetAtr = input.float(1.0, "Label Offset ATR", minval = 0.1, maxval = 4.0, step = 0.05, group = groupVisual,
     tooltip = "Vertical label padding from the signal candle, measured in ATR. Increase it when labels sit too close to candles.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual,
     tooltip = "Controls the size of event labels. Normal is the default AGPro public-release setting.")
maxVisibleEvents = input.int(6, "Maximum Visible Events", minval = 3, maxval = 25, group = groupVisual,
     tooltip = "Maximum number of historical triangle event packages kept on the chart. Lower values keep screenshots cleaner.")

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel,
     tooltip = "Shows the compact AGPro status panel with triangle age, compression, breakout side, retest quality, hold rate, and next action.")
panelPositionInput = input.string("Top Right", "Panel Position", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = groupPanel,
     tooltip = "Selects where the AGPro panel is displayed on the chart.")
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel,
     tooltip = "Controls the panel color theme. Dark follows the default AGPro premium palette; Light is provided for bright chart layouts.")
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel,
     tooltip = "Controls panel text size. Normal is the default AGPro public-release setting.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float lowValue, float highValue) =>
    math.max(lowValue, math.min(value, highValue))

f_text_on(color bg) =>
    float bright = (color.r(bg) * 299 + color.g(bg) * 587 + color.b(bg) * 114) / 1000
    bright >= 145 ? darkText : headerText

f_project(int x1, float y1, int x2, float y2, int targetX) =>
    x2 == x1 ? na : y1 + (y2 - y1) * (targetX - x1) / (x2 - x1)

f_label_size(string sizeName) =>
    switch sizeName
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(string posName) =>
    switch posName
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_grade(float score) =>
    score >= 85 ? "A+" : score >= 72 ? "A" : score >= 60 ? "B" : score >= 45 ? "C" : "D"

f_quality_text(float score) =>
    score >= 85 ? "Elite" : score >= 72 ? "High" : score >= 60 ? "Valid" : score >= 45 ? "Low" : "Weak"

f_side_text(int side) =>
    side == 1 ? "Bullish" : side == -1 ? "Bearish" : "Waiting"

f_trim_lines(array<line> itemArray, int maxItems) =>
    while array.size(itemArray) > maxItems
        line.delete(array.shift(itemArray))

f_trim_labels(array<label> itemArray, int maxItems) =>
    while array.size(itemArray) > maxItems
        label.delete(array.shift(itemArray))

labelSize = f_label_size(labelSizeInput)
panelSize = f_label_size(panelSizeInput)
panelPos = f_panel_pos(panelPositionInput)

isLightPanel = panelThemeInput == "Light"
panelBgFinal = isLightPanel ? color.rgb(248, 250, 252) : panelBg
panelBorderFinal = isLightPanel ? color.rgb(203, 213, 225) : panelBorder
panelLabelFinal = isLightPanel ? color.rgb(71, 85, 105) : panelLabelCol
panelValueFinal = isLightPanel ? color.rgb(15, 23, 42) : panelValueCol

// -------------------------------------------------
// Pivot Memory
// -------------------------------------------------
atr = math.max(nz(ta.atr(atrLen), ta.tr(true)), syminfo.mintick)
volAvg = ta.sma(volume, volLen)
volRatio = volAvg > 0 ? volume / volAvg : 1.0
barSpan = math.max(high - low, syminfo.mintick)
bodySpan = math.abs(close - open)
bodyRatio = bodySpan / barSpan

pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)

var int hiBarA = na
var int hiBarB = na
var float hiPriceA = na
var float hiPriceB = na
var int loBarA = na
var int loBarB = na
var float loPriceA = na
var float loPriceB = na

if not na(pivotHigh)
    hiBarA := hiBarB
    hiPriceA := hiPriceB
    hiBarB := bar_index - pivotLen
    hiPriceB := pivotHigh

if not na(pivotLow)
    loBarA := loBarB
    loPriceA := loPriceB
    loBarB := bar_index - pivotLen
    loPriceB := pivotLow

hasAnchors = not na(hiBarA) and not na(hiBarB) and not na(loBarA) and not na(loBarB) and hiBarB > hiBarA and loBarB > loBarA

upperNow = hasAnchors ? f_project(hiBarA, hiPriceA, hiBarB, hiPriceB, bar_index) : na
lowerNow = hasAnchors ? f_project(loBarA, loPriceA, loBarB, loPriceB, bar_index) : na
upperPrev = hasAnchors ? f_project(hiBarA, hiPriceA, hiBarB, hiPriceB, bar_index - 1) : na
lowerPrev = hasAnchors ? f_project(loBarA, loPriceA, loBarB, loPriceB, bar_index - 1) : na

startBarRaw = hasAnchors ? math.min(hiBarA, loBarA) : na
startBar = hasAnchors ? int(startBarRaw) : na
upperStart = hasAnchors ? f_project(hiBarA, hiPriceA, hiBarB, hiPriceB, startBar) : na
lowerStart = hasAnchors ? f_project(loBarA, loPriceA, loBarB, loPriceB, startBar) : na
widthStart = hasAnchors ? upperStart - lowerStart : na
widthNow = hasAnchors ? upperNow - lowerNow : na
patternAge = hasAnchors ? bar_index - startBar : na

upperSlope = hasAnchors ? (hiPriceB - hiPriceA) / math.max(hiBarB - hiBarA, 1) : na
lowerSlope = hasAnchors ? (loPriceB - loPriceA) / math.max(loBarB - loBarA, 1) : na
compressionPct = hasAnchors and widthStart > 0 ? (widthStart - widthNow) / widthStart * 100.0 : na
currentWidthAtr = hasAnchors and atr > 0 ? widthNow / atr : na
startWidthAtr = hasAnchors and atr > 0 ? widthStart / atr : na

slopeDiff = hasAnchors ? upperSlope - lowerSlope : na
apexRaw = hasAnchors and slopeDiff != 0 ? (loPriceA - lowerSlope * loBarA - (hiPriceA - upperSlope * hiBarA)) / slopeDiff : na
apexBarFloat = hasAnchors ? apexRaw : na
apexBar = hasAnchors and not na(apexBarFloat) ? int(math.round(apexBarFloat)) : na
apexPrice = hasAnchors and not na(apexBar) ? f_project(hiBarA, hiPriceA, hiBarB, hiPriceB, apexBar) : na
barsToApex = hasAnchors and not na(apexBar) ? apexBar - bar_index : na

validTriangle = hasAnchors and
     patternAge >= minPatternBars and
     patternAge <= maxPatternBars and
     widthStart > 0 and
     widthNow > 0 and
     startWidthAtr >= minStartWidthAtr and
     currentWidthAtr <= maxCurrentWidthAtr and
     compressionPct >= minCompressionPct and
     upperSlope < lowerSlope and
     upperNow > lowerNow and
     not na(apexBar) and
     barsToApex >= -5 and
     barsToApex <= maxForwardApexBars

structureKey = hasAnchors ? hiBarA + hiBarB + loBarA + loBarB : na
breakPad = atr * minBreakAtr
bullBreak = validTriangle and close > upperNow + breakPad and close[1] <= upperPrev
bearBreak = validTriangle and close < lowerNow - breakPad and close[1] >= lowerPrev
breakSide = bullBreak ? 1 : bearBreak ? -1 : 0

// -------------------------------------------------
// Scoring
// -------------------------------------------------
compressionScore = validTriangle ? f_clamp((compressionPct - minCompressionPct) / math.max(80.0 - minCompressionPct, 1.0), 0.0, 1.0) * 22.0 : 0.0
apexWindowScore = validTriangle ? f_clamp(1.0 - math.abs(barsToApex - 18.0) / math.max(maxForwardApexBars, 1), 0.0, 1.0) : 0.0
apexWidthScore = validTriangle ? f_clamp(1.0 - currentWidthAtr / math.max(maxCurrentWidthAtr, 0.1), 0.0, 1.0) : 0.0
apexScore = (apexWindowScore * 0.45 + apexWidthScore * 0.55) * 22.0

breakDistance = bullBreak ? close - upperNow : bearBreak ? lowerNow - close : 0.0
impulseScore = breakSide != 0 ? f_clamp(breakDistance / math.max(atr * 1.25, syminfo.mintick), 0.0, 1.0) * 22.0 : 0.0
bodyScore = breakSide != 0 ? f_clamp(bodyRatio, 0.0, 1.0) * 16.0 : 0.0
closePosition = breakSide == 1 ? (close - low) / barSpan : breakSide == -1 ? (high - close) / barSpan : 0.0
closeScore = breakSide != 0 ? f_clamp(closePosition, 0.0, 1.0) * 8.0 : 0.0
volumeScore = breakSide != 0 and useVolume ? f_clamp((volRatio - 1.0) / math.max(volFullScoreRatio - 1.0, 0.1), 0.0, 1.0) * 10.0 : breakSide != 0 ? 7.0 : 0.0
breakScore = compressionScore + apexScore + impulseScore + bodyScore + closeScore + volumeScore
breakScoreRounded = math.round(breakScore)

// -------------------------------------------------
// Drawing State
// -------------------------------------------------
var line liveUpperLine = na
var line liveLowerLine = na
var array<line> archivedLines = array.new_line()
var array<label> archivedLabels = array.new_label()

var int lastBreakBar = na
var int lastBreakKey = na
var int activeSide = 0
var int activeBreakBar = na
var int activeX1 = na
var int activeX2 = na
var float activeY1 = na
var float activeY2 = na
var float lastRetestScore = na
var string lastRetestState = "None"
var int lastBreakSide = 0
var float lastBreakScore = na
var bool retestHeldSignal = false
var bool retestFailedSignal = false

// Label anti-collision stagger (shared by breakout + retest tags)
var int lblLastBar = na
var int lblStack = 0

retestHeldSignal := false
retestFailedSignal := false

newStructure = na(lastBreakKey) or structureKey != lastBreakKey
cooldownReady = na(lastBreakBar) or bar_index - lastBreakBar > cooldownBars
showBreakEvent = breakSide != 0 and (newStructure or cooldownReady) and breakScoreRounded >= minLabelScore

if showTriangleLines and validTriangle
    if na(liveUpperLine)
        liveUpperLine := line.new(hiBarA, hiPriceA, bar_index, upperNow, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 0), width = 2)
    else
        line.set_xy1(liveUpperLine, hiBarA, hiPriceA)
        line.set_xy2(liveUpperLine, bar_index, upperNow)
        line.set_color(liveUpperLine, color.new(accentColor, 0))
        line.set_width(liveUpperLine, 2)
    if na(liveLowerLine)
        liveLowerLine := line.new(loBarA, loPriceA, bar_index, lowerNow, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 0), width = 2)
    else
        line.set_xy1(liveLowerLine, loBarA, loPriceA)
        line.set_xy2(liveLowerLine, bar_index, lowerNow)
        line.set_color(liveLowerLine, color.new(accentColor, 0))
        line.set_width(liveLowerLine, 2)
else
    if not na(liveUpperLine)
        line.set_color(liveUpperLine, color.new(accentColor, 100))
    if not na(liveLowerLine)
        line.set_color(liveLowerLine, color.new(accentColor, 100))

if showBreakEvent
    eventColor = breakSide == 1 ? bullColor : bearColor
    mutedColor = breakScoreRounded >= highQualityScore ? eventColor : neutralColor
    labelStyle = breakSide == 1 ? label.style_label_down : label.style_label_up
    sideTag = breakSide == 1 ? "BULL" : "BEAR"
    qualityTag = f_grade(breakScoreRounded) + " " + str.tostring(breakScoreRounded)
    labelText = "TRI " + sideTag + "\nQ " + qualityTag
    if showBreakLabels
        // stagger consecutive close labels so they do not overlap
        if not na(lblLastBar) and (bar_index - lblLastBar) <= 10
            lblStack := math.min(lblStack + 1, 3)
        else
            lblStack := 0
        lblLastBar := bar_index
        stackOff = atr * labelOffsetAtr * lblStack * 0.9
        labelY = breakSide == 1 ? high + atr * labelOffsetAtr + stackOff : low - atr * labelOffsetAtr - stackOff
        breakoutLabel = label.new(bar_index, labelY, labelText, xloc = xloc.bar_index, yloc = yloc.price, style = labelStyle, color = color.new(mutedColor, 0), textcolor = f_text_on(mutedColor), size = labelSize)
        array.push(archivedLabels, breakoutLabel)
    if showTriangleLines
        upperArchive = line.new(hiBarA, hiPriceA, bar_index, upperNow, xloc = xloc.bar_index, extend = extend.none, color = color.new(eventColor, 25), width = 2)
        lowerArchive = line.new(loBarA, loPriceA, bar_index, lowerNow, xloc = xloc.bar_index, extend = extend.none, color = color.new(eventColor, 25), width = 2)
        array.push(archivedLines, upperArchive)
        array.push(archivedLines, lowerArchive)
    activeSide := breakSide
    activeBreakBar := bar_index
    activeX1 := breakSide == 1 ? hiBarA : loBarA
    activeY1 := breakSide == 1 ? hiPriceA : loPriceA
    activeX2 := breakSide == 1 ? hiBarB : loBarB
    activeY2 := breakSide == 1 ? hiPriceB : loPriceB
    lastBreakBar := bar_index
    lastBreakKey := structureKey
    lastBreakSide := breakSide
    lastBreakScore := breakScoreRounded
    lastRetestScore := na
    lastRetestState := "Watching"

f_trim_lines(archivedLines, maxVisibleEvents * 2)
f_trim_labels(archivedLabels, maxVisibleEvents * 2)

// -------------------------------------------------
// Hold-Rate Proof
// On a breakout event, a win is recorded when the broken triangle boundary is
// held through the proof window; closing back inside the boundary within the
// window is a non-hold (fakeout).
// -------------------------------------------------
var bool proofPending = false
var int proofDir = 0
var float proofLevel = na
var int proofStartBar = na
var int proofTotal = 0
var int proofWin = 0

if showBreakEvent and barstate.isconfirmed
    proofPending := true
    proofDir := breakSide
    proofLevel := breakSide == 1 ? upperNow : lowerNow
    proofStartBar := bar_index

if proofPending and barstate.isconfirmed and bar_index > proofStartBar
    bool proofFailed = proofDir == 1 ? close < proofLevel : close > proofLevel
    bool proofHeld = bar_index - proofStartBar >= proofWindow
    if proofFailed
        proofTotal += 1
        proofPending := false
    else if proofHeld
        proofTotal += 1
        proofWin += 1
        proofPending := false

float holdRate = proofTotal > 0 ? 100.0 * proofWin / proofTotal : na
string holdRateText = na(holdRate) ? "Building" : str.tostring(math.round(holdRate)) + "% (" + str.tostring(proofTotal) + ")"
color holdRateColor = na(holdRate) ? panelValueFinal : holdRate >= 55.0 ? bullColor : holdRate >= 40.0 ? neutralColor : bearColor

// -------------------------------------------------
// Retest Tracking
// -------------------------------------------------
activeLevel = activeSide != 0 and not na(activeX1) and not na(activeX2) ? f_project(activeX1, activeY1, activeX2, activeY2, bar_index) : na
activeAge = activeSide != 0 and not na(activeBreakBar) ? bar_index - activeBreakBar : na
activeTol = atr * retestTolAtr

if activeSide != 0 and not na(activeLevel)
    inRetestWindow = activeAge >= retestMinBars and activeAge <= retestMaxBars
    touchRetestBand = high >= activeLevel - activeTol and low <= activeLevel + activeTol
    heldRetest = inRetestWindow and touchRetestBand and (activeSide == 1 ? close > activeLevel and low >= activeLevel - activeTol : close < activeLevel and high <= activeLevel + activeTol)
    failedRetest = activeAge > 0 and (activeSide == 1 ? close < activeLevel - activeTol : close > activeLevel + activeTol)
    expiredRetest = activeAge > retestMaxBars
    if heldRetest or failedRetest
        depthRaw = activeSide == 1 ? math.abs(low - activeLevel) : math.abs(high - activeLevel)
        depthScore = f_clamp(1.0 - depthRaw / math.max(activeTol, syminfo.mintick), 0.0, 1.0) * 30.0
        reclaimScore = heldRetest ? 35.0 : 8.0
        wickReject = activeSide == 1 ? (math.min(open, close) - low) / barSpan : (high - math.max(open, close)) / barSpan
        rejectionScore = f_clamp(wickReject, 0.0, 1.0) * 20.0
        speedScore = f_clamp(1.0 - (activeAge - retestMinBars) / math.max(retestMaxBars - retestMinBars, 1), 0.0, 1.0) * 15.0
        retestScore = math.round(depthScore + reclaimScore + rejectionScore + speedScore)
        lastRetestScore := retestScore
        lastRetestState := heldRetest ? "Held " + f_grade(retestScore) : "Failed"
        retestHeldSignal := heldRetest
        retestFailedSignal := failedRetest
        if showRetestLabels
            // stagger consecutive close labels so they do not overlap
            if not na(lblLastBar) and (bar_index - lblLastBar) <= 10
                lblStack := math.min(lblStack + 1, 3)
            else
                lblStack := 0
            lblLastBar := bar_index
            rStackOff = atr * labelOffsetAtr * lblStack * 0.9
            retestColor = heldRetest ? (activeSide == 1 ? bullColor : bearColor) : neutralColor
            retestY = activeSide == 1 ? activeLevel + atr * labelOffsetAtr * 1.6 + rStackOff : activeLevel - atr * labelOffsetAtr * 1.6 - rStackOff
            retestStyle = activeSide == 1 ? label.style_label_up : label.style_label_down
            retestText = heldRetest ? "RT HOLD\nQ " + str.tostring(retestScore) : "RT FAIL\nQ " + str.tostring(retestScore)
            retestLabel = label.new(bar_index, retestY, retestText, xloc = xloc.bar_index, yloc = yloc.price, style = retestStyle, color = color.new(retestColor, 0), textcolor = f_text_on(retestColor), size = labelSize)
            array.push(archivedLabels, retestLabel)
        activeSide := 0
    else if expiredRetest
        lastRetestState := "Expired"
        activeSide := 0

f_trim_labels(archivedLabels, maxVisibleEvents * 2)

// -------------------------------------------------
// Action Stance
// -------------------------------------------------
string actionText = "Scan Pattern"
color actionColor = panelLabelFinal
if breakSide != 0
    actionText := "Confirm Breakout"
    actionColor := breakSide == 1 ? bullColor : bearColor
else if activeSide != 0
    actionText := "Track Retest"
    actionColor := activeSide == 1 ? bullColor : bearColor
else if validTriangle
    actionText := "Watch Apex"
    actionColor := accentColor

// -------------------------------------------------
// Plot States
// -------------------------------------------------
barTint = showCandleTint and showBreakEvent ? color.new(breakSide == 1 ? bullColor : bearColor, 68) : na
barcolor(barTint)

alertcondition(showBreakEvent and breakSide == 1, "Bullish Triangle Breakout", "Triangle Breakout Quality detected a bullish triangle breakout.")
alertcondition(showBreakEvent and breakSide == -1, "Bearish Triangle Breakout", "Triangle Breakout Quality detected a bearish triangle breakout.")
alertcondition(showBreakEvent and breakScoreRounded >= highQualityScore, "High Quality Triangle Breakout", "Triangle Breakout Quality detected a high-quality triangle breakout.")
alertcondition(retestHeldSignal, "Triangle Retest Held", "Triangle Breakout Quality detected a held retest after triangle breakout.")
alertcondition(retestFailedSignal, "Triangle Retest Failed", "Triangle Breakout Quality detected a failed retest after triangle breakout.")

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table panel = table.new(panelPos, 2, 9, border_width = 1, border_color = panelBorderFinal)
var bool panelMerged = false

if not panelMerged
    table.merge_cells(panel, 0, 0, 1, 0)
    panelMerged := true

if barstate.islast and showPanel
    table.cell(panel, 0, 0, "AG Pro Triangle Breakout Quality", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
    table.cell(panel, 0, 1, "Pattern Age", text_color = panelLabelFinal, bgcolor = panelBgFinal, text_size = panelSize)
    table.cell(panel, 1, 1, validTriangle ? str.tostring(patternAge) + " bars" : "No valid triangle", text_color = panelValueFinal, bgcolor = panelBgFinal, text_size = panelSize)
    table.cell(panel, 0, 2, "Compression", text_color = panelLabelFinal, bgcolor = panelBgFinal, text_size = panelSize)
    table.cell(panel, 1, 2, validTriangle ? str.tostring(math.round(compressionPct)) + "%" : "-", text_color = validTriangle ? neutralColor : panelValueFinal, bgcolor = panelBgFinal, text_size = panelSize)
    table.cell(panel, 0, 3, "Apex Pressure", text_color = panelLabelFinal, bgcolor = panelBgFinal, text_size = panelSize)
    apexPanelText = validTriangle ? str.tostring(math.max(barsToApex, 0)) + " bars / " + str.tostring(math.round(currentWidthAtr * 10.0) / 10.0) + " ATR" : "-"
    table.cell(panel, 1, 3, apexPanelText, text_color = validTriangle ? accentColor : panelValueFinal, bgcolor = panelBgFinal, text_size = panelSize)
    table.cell(panel, 0, 4, "Breakout Side", text_color = panelLabelFinal, bgcolor = panelBgFinal, text_size = panelSize)
    sideColor = lastBreakSide == 1 ? bullColor : lastBreakSide == -1 ? bearColor : panelValueFinal
    scoreText = na(lastBreakScore) ? "-" : f_side_text(lastBreakSide) + " / " + f_grade(lastBreakScore) + " " + str.tostring(lastBreakScore)
    table.cell(panel, 1, 4, scoreText, text_color = sideColor, bgcolor = panelBgFinal, text_size = panelSize)
    table.cell(panel, 0, 5, "Retest Quality", text_color = panelLabelFinal, bgcolor = panelBgFinal, text_size = panelSize)
    retestText = na(lastRetestScore) ? lastRetestState : lastRetestState + " / " + str.tostring(lastRetestScore)
    table.cell(panel, 1, 5, retestText, text_color = lastRetestState == "Watching" ? neutralColor : panelValueFinal, bgcolor = panelBgFinal, text_size = panelSize)
    table.cell(panel, 0, 6, "Current State", text_color = panelLabelFinal, bgcolor = panelBgFinal, text_size = panelSize)
    stateScore = validTriangle ? (compressionScore + apexScore) / 44.0 * 100.0 : 0.0
    stateText = validTriangle ? f_quality_text(stateScore) + " Compression" : "Scanning"
    table.cell(panel, 1, 6, stateText, text_color = validTriangle ? accentColor : panelValueFinal, bgcolor = panelBgFinal, text_size = panelSize)
    table.cell(panel, 0, 7, "Hold Rate", text_color = panelLabelFinal, bgcolor = panelBgFinal, text_size = panelSize)
    table.cell(panel, 1, 7, holdRateText, text_color = holdRateColor, bgcolor = panelBgFinal, text_size = panelSize)
    table.cell(panel, 0, 8, "Action", text_color = panelLabelFinal, bgcolor = panelBgFinal, text_size = panelSize)
    table.cell(panel, 1, 8, actionText, text_color = actionColor, bgcolor = panelBgFinal, text_size = panelSize)
````

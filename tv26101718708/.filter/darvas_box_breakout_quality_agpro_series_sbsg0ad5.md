# Darvas Box Breakout Quality [AGPro Series]

- url: https://www.tradingview.com/script/SBsg0Ad5-Darvas-Box-Breakout-Quality-AGPro-Series/
- type: indicator
- pine_id: PUB;720a41e03b5f4890a0a3239917ffad83
- version: 5.0

## Description

Darvas Box Breakout Quality [AGPro Series]

🔹 OVERVIEW

Darvas Box Breakout Quality [AGPro Series] is built for one of the most recognizable and widely searched chart-pattern structures in technical analysis: the Darvas Box.

The script focuses on the full Darvas lifecycle:

Box formation → compression quality → breakout direction → volume support → failed-break behavior.

Instead of treating every horizontal range as support and resistance, this script waits for a Darvas-style structure to form, validates the box by age and volatility-adjusted height, then evaluates how price resolves from that box. The result is a clean chart-pattern workflow designed for traders who want to study rectangular compression and breakout quality without turning the chart into a crowded zone map.

The main visual element is the active Darvas box itself. By default, resolved boxes are removed after breakout so the chart stays focused on the current live structure instead of filling with old rectangles.

🔹 WHAT MAKES IT DIFFERENT

Most box or breakout tools stop at drawing a rectangle or marking the first break beyond a level. Darvas Box Breakout Quality adds structure, scoring, and failure awareness.

Core differentiators:

• Darvas-first structure logic
The rectangle is not a generic support/resistance zone. It comes from a Darvas box formation process built around a fresh seed high, containment, age, and volatility-adjusted box height.

• Compression quality
The script measures whether the box has enough maturity and controlled range behavior before treating it as a meaningful active structure.

• Breakout quality score
Every qualified breakout is evaluated with a 0-100 model that includes compression quality, relative volume, breakout distance, candle body participation, and directional close location.

• Volume confirmation
Breakout labels can require volume support, helping separate stronger participation events from weaker boundary pokes.

• Failed-break tracking
After breakout, the script watches whether price returns back inside the former box within the selected failure window. If it does, the event is marked as a failed break.

• Premium visual restraint
The default chart view uses one active box, compact labels, controlled label spacing, and a compact AGPro panel. The goal is to make the chart informative without making it noisy.

🧭 WHY THIS DOES NOT OVERLAP WITH OTHER AGPRO TOOLS

This script is intentionally separated from the existing AGPro breakout and chart-pattern family.

It is not Inside Bar Breakout Quality, because it does not require a mother bar or inside-bar compression sequence.

It is not Donchian Breakout Quality, because it is not based on rolling channel highs and lows.

It is not Opening Range Breakout logic, because it is not tied to a session-defined range.

It is not Triangle Breakout Quality, because it does not use converging pivot boundaries, apex pressure, or diagonal structure.

It is not Breakout Volume Quality, because volume is only one part of the confirmation model, not the entire concept.

It is not a supply/demand, order-block, or generic support/resistance zone script. The rectangle exists only when the Darvas box formation process supports it.

That distinction matters visually and analytically. On the chart, this script tells a Darvas story: rectangular compression, active box behavior, quality of release, and failed-break review.

⚙️ METHODOLOGY

1. Darvas seed detection
The script looks for a fresh high over the selected lookback period. This high becomes the initial reference for a potential Darvas box.

2. Box formation
After the seed appears, price must spend enough time contained beneath the upper boundary while the lower boundary develops. The box remains in formation until it meets the selected age and height requirements.

3. Volatility normalization
The box height is measured relative to ATR. This helps filter boxes that are too flat to matter or too wide to represent clean compression.

4. Active box state
When the box qualifies, the script displays the active Darvas box and optional midpoint. The box projects forward so the active breakout boundary remains visible while price approaches it.

5. Breakout confirmation
A bullish breakout requires price to resolve above the Darvas top. A bearish breakout requires price to resolve below the Darvas bottom. Users can require close-based confirmation for stricter filtering.

6. Quality score
The breakout score combines:

• Compression quality
• Relative volume support
• ATR-normalized breakout distance
• Candle body participation
• Directional close location

7. Failed-break monitoring
After breakout, the script watches a defined number of bars. If price returns back inside the former Darvas boundary, the failed-break marker is printed.

📊 PANEL

The AGPro panel summarizes the current Darvas environment:

• Box Age
• Compression
• Breakout Side
• Volume Support
• Latest Quality / State

The first panel row follows the AGPro publication standard: one merged blue header row containing only the panel title. Panel location, panel theme, and panel font size are adjustable from settings.

🎛️ KEY INPUTS

Darvas Box Detection
• New High Lookback
• Minimum Box Age
• Maximum Box Age
• ATR Length
• Minimum Box Height ATR
• Maximum Box Height ATR
• Require Close Beyond Box

Breakout Quality
• Volume MA Length
• Volume Support Threshold
• Require Volume Support
• Target Break Distance ATR
• Minimum Breakout Score
• Failed Break Window

Visual Controls
• Show Active Darvas Box
• Show Box Midline
• Show Breakout Labels
• Show Failed Break Markers
• Keep Resolved Box
• Box Projection Bars
• Label Cooldown Bars
• Maximum Visible Labels
• Label Offset ATR
• Label Stack Offset ATR
• Label Font Size

Panel
• Panel Location
• Panel Theme
• Panel Font Size

🔍 HOW TO READ IT

When a Darvas box becomes active, the chart displays the live rectangular structure. The panel shows how old the box is, how compressed it is, and whether the latest environment has breakout direction or volume support.

When price resolves outside the box with enough quality, the chart prints a compact breakout label such as UP 79 or DN 75. The number represents the breakout quality score.

When price fails to hold outside the box and returns back inside during the selected failure window, the script prints a compact failed-break marker such as FAIL UP or FAIL DN.

The best readings come when the box is visually clear, compression is meaningful, and the breakout candle has both directional close quality and volume support.

🧩 BEST USE CASES

• Classic Darvas box formations
• Rectangular range compression
• Box breakout quality review
• Volume-backed breakout confirmation
• Failed-break review after a box release
• Clean chart-pattern study
• Multi-timeframe Darvas structure observation
• Screenshot-friendly public chart analysis

🧠 VISUAL DESIGN PHILOSOPHY

Darvas Box Breakout Quality is designed to look premium through restraint.

The script avoids filling the chart with old boxes by default. It keeps the active Darvas box as the main visual layer, uses short event labels, adds cooldown and stack spacing to reduce overlap, and keeps the panel compact.

This makes the indicator easier to publish, easier to read, and easier to use across different symbols and timeframes.

🔔 ALERTS

The script includes alert conditions for:

• High-quality bullish Darvas breakout
• High-quality bearish Darvas breakout
• Failed bullish Darvas breakout
• Failed bearish Darvas breakout

These alerts follow the same structure-aware logic used by the chart labels.

🔹 LIMITATIONS AND TRANSPARENCY

Darvas box detection is structure-based and depends on the selected lookback, age, and ATR filters. Changing those settings can make the script more selective or more active.

Volume support depends on the quality of the symbol's volume feed. On instruments where volume is less informative, users may prefer to adjust the volume threshold or disable the volume requirement.

The score is a structured description of breakout quality according to the script's internal model. It is designed to help compare Darvas box releases by quality, not to replace the user's broader market context.

✅ IDEAL USER

This script is designed for traders who want a focused Darvas box tool with cleaner structure detection, breakout quality scoring, volume confirmation, failed-break awareness, and a premium chart layout.

It is best suited for users who want the Darvas box itself to remain the main story on the chart.

## Source Code

````pine
// -------------------------------------------------
// Darvas Box Breakout Quality [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Darvas Box Breakout Quality detects classic Darvas-style box formations,
// grades compression quality, evaluates breakout confirmation through volume,
// candle efficiency, and close location, tracks failed breaks back into the box,
// and measures a self-tested breakout follow-through rate. The script is built
// for clean chart reading around box formation, range compression, breakout
// quality, volume support, and failure behavior.
// -------------------------------------------------

//@version=6
indicator("Darvas Box Breakout Quality [AGPro Series]",
     shorttitle = "AG Pro DBQ",
     overlay = true,
     max_boxes_count = 20,
     max_labels_count = 120,
     max_lines_count = 30)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupDetection = "Darvas Box Detection"
seedLookback = input.int(20, "New High Lookback", minval = 5, maxval = 200, group = groupDetection, tooltip = "Defines how far back the script looks to confirm a fresh Darvas seed high. Higher values require a more meaningful new-high event before a box can begin forming.")
minBoxAge = input.int(5, "Minimum Box Age", minval = 2, maxval = 50, group = groupDetection, tooltip = "Minimum number of bars that must remain below the seed high before a Darvas box can become active.")
maxBoxAge = input.int(80, "Maximum Box Age", minval = 10, maxval = 300, group = groupDetection, tooltip = "Maximum number of bars a forming or active Darvas box may remain valid before it is considered stale.")
atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupDetection, tooltip = "ATR period used to normalize box height, breakout distance, label spacing, and quality scoring.")
minBoxHeightAtr = input.float(0.30, "Minimum Box Height ATR", minval = 0.05, maxval = 5.0, step = 0.05, group = groupDetection, tooltip = "Prevents very flat boxes from being treated as meaningful Darvas structures.")
maxBoxHeightAtr = input.float(3.00, "Maximum Box Height ATR", minval = 0.50, maxval = 10.0, step = 0.10, group = groupDetection, tooltip = "Filters boxes that are too wide relative to current volatility. Tighter boxes usually create cleaner breakout-quality reads.")
requireCloseBreak = input.bool(true, "Require Close Beyond Box", group = groupDetection, tooltip = "When enabled, a breakout requires the bar to close beyond the Darvas boundary. When disabled, an intrabar break is enough to resolve the box.")

groupScoring = "Breakout Quality"
volumeLength = input.int(20, "Volume MA Length", minval = 5, maxval = 200, group = groupScoring, tooltip = "Volume baseline used to measure whether the breakout has participation support.")
volumeThreshold = input.float(1.20, "Volume Support Threshold", minval = 0.50, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = "Relative volume level required for volume support. A value of 1.20 means current volume must be at least 120 percent of its baseline.")
requireVolumeSupport = input.bool(true, "Require Volume Support", group = groupScoring, tooltip = "When enabled, high-quality breakout labels require relative volume to meet the selected support threshold.")
targetBreakAtr = input.float(0.60, "Target Break Distance ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupScoring, tooltip = "ATR-normalized distance used to grade how decisively price closes beyond the Darvas boundary.")
minBreakoutScore = input.int(60, "Minimum Breakout Score", minval = 1, maxval = 100, group = groupScoring, tooltip = "Minimum 0-100 quality score required before a breakout label is printed on the chart.")
failureWindow = input.int(5, "Failed Break Window", minval = 1, maxval = 30, group = groupScoring, tooltip = "Number of bars after a breakout during which a return back inside the Darvas box is marked as a failed breakout.")
proofWindowBars = input.int(8, "Breakout Proof Window", minval = 2, maxval = 60, group = groupScoring, tooltip = "After a qualified breakout, the script waits this many bars and checks whether price is still beyond the broken Darvas boundary. Feeds the Breakout Hit Rate readout in the panel.")

groupVisual = "Visual Settings"
showActiveBox = input.bool(true, "Show Active Darvas Box", group = groupVisual, tooltip = "Displays the current Darvas box as a controlled rectangle. This is the primary structure layer of the script.")
showCenteredBoxBadge = input.bool(true, "Show Centered Box Badge", group = groupVisual, tooltip = "Adds a separate centered badge inside the active Darvas box so the structure reads clearly without using box text.")
showMidline = input.bool(true, "Show Box Midline", group = groupVisual, tooltip = "Displays the midpoint of the active Darvas box to make compression balance easier to read.")
showBreakoutLabels = input.bool(true, "Show Breakout Labels", group = groupVisual, tooltip = "Displays qualified breakout labels when the score and volume model confirm the Darvas box resolution.")
showFailedMarkers = input.bool(true, "Show Failed Break Markers", group = groupVisual, tooltip = "Displays a failed-break marker when price returns back inside the Darvas box within the selected failure window.")
keepResolvedBox = input.bool(false, "Keep Resolved Box", group = groupVisual, tooltip = "When disabled, the Darvas box is removed after breakout so only the live active structure remains on the chart.")
boxProjectionBars = input.int(20, "Box Projection Bars", minval = 1, maxval = 100, group = groupVisual, tooltip = "Extends the active Darvas box to the right so the breakout boundary remains visible while price approaches it.")
labelCooldownBars = input.int(18, "Label Cooldown Bars", minval = 0, maxval = 80, group = groupVisual, tooltip = "Minimum spacing between event labels. The publication default preserves selective breakout history without repeated labels crowding the active box.")
maxVisibleLabels = input.int(6, "Maximum Visible Labels", minval = 4, maxval = 30, group = groupVisual, tooltip = "Caps retained event history so the active Darvas structure remains the primary chart story.")
labelOffsetAtr = input.float(0.35, "Label Offset ATR", minval = 0.05, maxval = 3.00, step = 0.05, group = groupVisual, tooltip = "Offsets labels away from candles using ATR so they remain readable and do not get buried inside bars.")
labelStackAtr = input.float(0.75, "Label Stack Offset ATR", minval = 0.20, maxval = 3.00, step = 0.05, group = groupVisual, tooltip = "Adds extra vertical spacing when a new event label appears close to a recent label on the same side of price.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisual, tooltip = "Controls the size of breakout and failed-break labels. Normal is the default publication setting.")

groupPanel = "Panel Settings"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = "Shows or hides the AGPro summary panel.")
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Center", "Bottom Right", "Bottom Center", "Bottom Left"], group = groupPanel, tooltip = "Controls where the AGPro summary panel is displayed.")
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = groupPanel, tooltip = "Controls the visual theme of the AGPro summary panel.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel, tooltip = "Controls the font size used in the summary panel. Normal is the default publication setting.")

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
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
dangerColor = color.rgb(239, 68, 68)
darkText = color.rgb(17, 24, 39)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_text_on(color bgColor) =>
    float bright = (color.r(bgColor) * 299.0 + color.g(bgColor) * 587.0 + color.b(bgColor) * 114.0) / 1000.0
    bright >= 145.0 ? darkText : headerText

f_text_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_panel_position(string locationText) =>
    switch locationText
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Right" => position.middle_right
        "Middle Center" => position.middle_center
        "Bottom Right" => position.bottom_right
        "Bottom Center" => position.bottom_center
        "Bottom Left" => position.bottom_left
        => position.top_right

f_panel_bg() =>
    panelTheme == "Clean Light" ? color.rgb(248, 250, 252) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_label_bg() =>
    panelTheme == "Clean Light" ? color.rgb(226, 232, 240) : panelTheme == "Slate" ? color.rgb(51, 65, 85) : color.rgb(22, 32, 56)

f_panel_label() =>
    panelTheme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value() =>
    panelTheme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_panel_border() =>
    panelTheme == "Clean Light" ? color.rgb(203, 213, 225) : panelBorder

f_grade(float score) =>
    score >= 85 ? "A+" : score >= 75 ? "A" : score >= 65 ? "B" : score >= 50 ? "C" : "D"

f_side_text(int sideValue) =>
    sideValue == 1 ? "Bullish" : sideValue == -1 ? "Bearish" : "None"

f_set_center_badge(label targetLabel, int xValue, float yValue, string labelText, color bgColor) =>
    label result = targetLabel
    if na(result)
        result := label.new(xValue, yValue, labelText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(bgColor, 0), textcolor = f_text_on(bgColor), size = f_text_size(labelSizeInput))
    else
        label.set_x(result, xValue)
        label.set_y(result, yValue)
        label.set_text(result, labelText)
        label.set_color(result, color.new(bgColor, 0))
        label.set_textcolor(result, f_text_on(bgColor))
        label.set_size(result, f_text_size(labelSizeInput))
    result

var array<label> eventLabels = array.new_label()

f_track_label(label eventLabel) =>
    array.push(eventLabels, eventLabel)
    if array.size(eventLabels) > maxVisibleLabels
        label oldLabel = array.shift(eventLabels)
        label.delete(oldLabel)

// -------------------------------------------------
// State
// -------------------------------------------------
var bool candidateActive = false
var bool boxActive = false
var float candidateTop = na
var float candidateBottom = na
var int candidateLeft = na
var float activeTop = na
var float activeBottom = na
var int activeLeft = na
var int lastEventBar = na
var int latestBreakSide = 0
var float latestBreakScore = na
var string latestState = "Waiting"
var bool failureWatch = false
var int watchSide = 0
var float watchTop = na
var float watchBottom = na
var int watchBar = na
var box darvasBox = na
var line midLine = na
var label boxBadge = na
var int lastUpperLabelBar = na
var int lastLowerLabelBar = na
var float lastUpperLabelY = na
var float lastLowerLabelY = na

// Breakout follow-through proof
var int brkProofHits = 0
var int brkProofTotal = 0
var bool brkProofPending = false
var int brkProofStart = na
var float brkProofBoundary = na
var int brkProofDir = 0

// -------------------------------------------------
// Core calculations
// -------------------------------------------------
atrValue = ta.atr(atrLength)
atrSafe = math.max(nz(atrValue, ta.tr(true)), syminfo.mintick)
priorHigh = ta.highest(high[1], seedLookback)
newDarvasSeed = not na(priorHigh) and high > priorHigh
volMa = ta.sma(volume, volumeLength)
volumeReady = not na(volume) and not na(volMa) and volMa > 0
volumeRatio = volumeReady ? volume / volMa : na
volumeSupported = volumeReady and volumeRatio >= volumeThreshold
volumeScore = volumeReady ? f_clamp(volumeRatio / volumeThreshold * 100.0, 0.0, 100.0) : 50.0

if boxActive and not na(activeLeft)
    int activeAgeCheck = bar_index - activeLeft + 1
    if activeAgeCheck > maxBoxAge
        boxActive := false
        latestState := "Expired"
        if not na(darvasBox)
            box.delete(darvasBox)
            darvasBox := na
        if not na(midLine)
            line.delete(midLine)
            midLine := na
        if not na(boxBadge)
            label.delete(boxBadge)
            boxBadge := na

if not candidateActive and not boxActive and newDarvasSeed
    candidateActive := true
    candidateTop := high
    candidateBottom := low
    candidateLeft := bar_index
    latestState := "Forming"
    latestBreakSide := 0
    latestBreakScore := na

if candidateActive and not boxActive
    int candidateAge = bar_index - candidateLeft + 1
    if high > candidateTop
        candidateTop := high
        candidateBottom := low
        candidateLeft := bar_index
        candidateAge := 1
    else
        candidateBottom := math.min(candidateBottom, low)

    float candidateHeight = candidateTop - candidateBottom
    float candidateHeightAtr = candidateHeight / atrSafe
    bool candidateMature = candidateAge >= minBoxAge and candidateHeightAtr >= minBoxHeightAtr and candidateHeightAtr <= maxBoxHeightAtr
    bool candidateExpired = candidateAge > maxBoxAge

    if candidateMature
        boxActive := true
        candidateActive := false
        activeTop := candidateTop
        activeBottom := candidateBottom
        activeLeft := candidateLeft
        latestState := "Active Box"
        latestBreakSide := 0
        latestBreakScore := na
        if showActiveBox
            if not na(darvasBox)
                box.delete(darvasBox)
            darvasBox := box.new(activeLeft, activeTop, bar_index + boxProjectionBars, activeBottom, xloc = xloc.bar_index, border_color = color.new(accentColor, 0), bgcolor = color.new(accentColor, 88), border_width = 2)
        if showActiveBox and showMidline
            if not na(midLine)
                line.delete(midLine)
            float activeMid = (activeTop + activeBottom) * 0.5
            midLine := line.new(activeLeft, activeMid, bar_index + boxProjectionBars, activeMid, xloc = xloc.bar_index, extend = extend.none, color = color.new(panelValueCol, 35), style = line.style_dotted, width = 1)
    else if candidateExpired
        candidateActive := false
        latestState := "Waiting"

if boxActive and showActiveBox and not na(darvasBox)
    box.set_right(darvasBox, bar_index + boxProjectionBars)
    box.set_top(darvasBox, activeTop)
    box.set_bottom(darvasBox, activeBottom)

if boxActive and showActiveBox and showMidline and not na(midLine)
    float liveMid = (activeTop + activeBottom) * 0.5
    line.set_x2(midLine, bar_index + boxProjectionBars)
    line.set_y1(midLine, liveMid)
    line.set_y2(midLine, liveMid)

// -------------------------------------------------
// Quality model
// -------------------------------------------------
float contextTop = boxActive ? activeTop : candidateTop
float contextBottom = boxActive ? activeBottom : candidateBottom
int contextLeft = boxActive ? activeLeft : candidateLeft
bool hasContext = (boxActive or candidateActive) and not na(contextTop) and not na(contextBottom) and not na(contextLeft)
int contextAge = hasContext ? bar_index - contextLeft + 1 : 0
float contextHeight = hasContext ? contextTop - contextBottom : na
float contextHeightAtr = hasContext ? contextHeight / atrSafe : na
float idealAge = math.max(minBoxAge * 3.0, minBoxAge + 1.0)
float ageRatio = contextAge > 0 ? contextAge / idealAge : 0.0
float ageScore = ageRatio <= 1.0 ? ageRatio * 100.0 : f_clamp(100.0 - (ageRatio - 1.0) * 35.0, 30.0, 100.0)
float heightWindow = math.max(maxBoxHeightAtr - minBoxHeightAtr, 0.10)
float tightnessScore = not na(contextHeightAtr) ? f_clamp(100.0 - ((contextHeightAtr - minBoxHeightAtr) / heightWindow * 100.0), 0.0, 100.0) : 0.0
float compressionScore = hasContext ? f_clamp(tightnessScore * 0.70 + ageScore * 0.30, 0.0, 100.0) : 0.0

if barstate.islast
    if showCenteredBoxBadge and showActiveBox and boxActive and not na(activeTop) and not na(activeBottom) and not na(activeLeft)
        badgeX = int(math.round((activeLeft + bar_index + boxProjectionBars) * 0.50))
        badgeY = (activeTop + activeBottom) * 0.50
        string badgeText = "DARVAS BOX | Q" + str.tostring(math.round(compressionScore)) + " | " + str.tostring(contextAge) + "B"
        boxBadge := f_set_center_badge(boxBadge, badgeX, badgeY, badgeText, accentColor)
    else if not keepResolvedBox and not na(boxBadge)
        label.delete(boxBadge)
        boxBadge := na

bool breakUp = boxActive and barstate.isconfirmed and (requireCloseBreak ? close > activeTop : high > activeTop)
bool breakDown = boxActive and barstate.isconfirmed and (requireCloseBreak ? close < activeBottom : low < activeBottom)
int breakSide = breakUp ? 1 : breakDown ? -1 : 0
bool breakoutEvent = breakSide != 0

float barRange = math.max(high - low, syminfo.mintick)
float bodyRatio = math.abs(close - open) / barRange
float closeLocation = breakSide == 1 ? (close - low) / barRange : breakSide == -1 ? (high - close) / barRange : 0.50
float breakDistanceAtr = breakoutEvent ? (breakSide == 1 ? (close - activeTop) / atrSafe : (activeBottom - close) / atrSafe) : 0.0
float distanceScore = f_clamp(breakDistanceAtr / targetBreakAtr * 100.0, 0.0, 100.0)
float bodyScore = f_clamp(bodyRatio * 100.0, 0.0, 100.0)
float closeScore = f_clamp(closeLocation * 100.0, 0.0, 100.0)
float breakoutScore = f_clamp(compressionScore * 0.30 + volumeScore * 0.25 + distanceScore * 0.20 + closeScore * 0.15 + bodyScore * 0.10, 0.0, 100.0)
bool volumeGate = not requireVolumeSupport or volumeSupported
bool scoreGate = breakoutScore >= minBreakoutScore
bool cooldownReady = na(lastEventBar) or bar_index - lastEventBar >= labelCooldownBars
bool qualifiedBreakout = breakoutEvent and volumeGate and scoreGate

// -------------------------------------------------
// Failed-break tracking
// -------------------------------------------------
bool failedUp = false
bool failedDown = false

if failureWatch
    int barsAfterBreak = bar_index - watchBar
    failedUp := watchSide == 1 and barsAfterBreak > 0 and barsAfterBreak <= failureWindow and close < watchTop
    failedDown := watchSide == -1 and barsAfterBreak > 0 and barsAfterBreak <= failureWindow and close > watchBottom
    bool watchExpired = barsAfterBreak > failureWindow
    if failedUp or failedDown or watchExpired
        failureWatch := false
        if failedUp
            latestState := "Failed Up"
            latestBreakSide := 1
        if failedDown
            latestState := "Failed Down"
            latestBreakSide := -1

if showFailedMarkers and (failedUp or failedDown) and cooldownReady
    string failText = failedUp ? "BULL BREAK FAILED" : "BEAR BREAK FAILED"
    float failY = failedUp ? high + atrSafe * labelOffsetAtr : low - atrSafe * labelOffsetAtr
    bool upperCrowdedFail = failedUp and not na(lastUpperLabelBar) and bar_index - lastUpperLabelBar <= labelCooldownBars * 2
    bool lowerCrowdedFail = failedDown and not na(lastLowerLabelBar) and bar_index - lastLowerLabelBar <= labelCooldownBars * 2
    failY := upperCrowdedFail ? math.max(failY, lastUpperLabelY + atrSafe * labelStackAtr) : failY
    failY := lowerCrowdedFail ? math.min(failY, lastLowerLabelY - atrSafe * labelStackAtr) : failY
    failStyle = failedUp ? label.style_label_down : label.style_label_up
    color failColor = dangerColor
    label failLabel = label.new(bar_index, failY, failText, xloc = xloc.bar_index, style = failStyle, color = color.new(failColor, 0), textcolor = f_text_on(failColor), size = f_text_size(labelSizeInput))
    f_track_label(failLabel)
    if failedUp
        lastUpperLabelBar := bar_index
        lastUpperLabelY := failY
    if failedDown
        lastLowerLabelBar := bar_index
        lastLowerLabelY := failY
    lastEventBar := bar_index

// -------------------------------------------------
// Breakout handling
// -------------------------------------------------
if breakoutEvent
    latestBreakSide := breakSide
    latestBreakScore := breakoutScore
    latestState := qualifiedBreakout ? "Confirmed" : "Weak Break"
    failureWatch := true
    watchSide := breakSide
    watchTop := activeTop
    watchBottom := activeBottom
    watchBar := bar_index

    // Arm follow-through proof on qualified breakouts (boundary captured before reset)
    if qualifiedBreakout and not brkProofPending
        brkProofPending := true
        brkProofStart := bar_index
        brkProofBoundary := breakSide == 1 ? activeTop : activeBottom
        brkProofDir := breakSide

    if keepResolvedBox
        if not na(darvasBox)
            color resolvedBorder = breakSide == 1 ? bullColor : bearColor
            color resolvedFill = breakSide == 1 ? color.new(bullColor, 88) : color.new(bearColor, 88)
            box.set_right(darvasBox, bar_index + boxProjectionBars)
            box.set_border_color(darvasBox, resolvedBorder)
            box.set_bgcolor(darvasBox, resolvedFill)
        if not na(midLine)
            line.set_x2(midLine, bar_index + boxProjectionBars)
        if showCenteredBoxBadge and showActiveBox
            int resolvedBadgeX = int(math.round((activeLeft + bar_index + boxProjectionBars) * 0.50))
            float resolvedBadgeY = (activeTop + activeBottom) * 0.50
            string resolvedBadgeText = (breakSide == 1 ? "BULL BREAK" : "BEAR BREAK") + " | Q" + str.tostring(math.round(breakoutScore))
            boxBadge := f_set_center_badge(boxBadge, resolvedBadgeX, resolvedBadgeY, resolvedBadgeText, breakSide == 1 ? bullColor : bearColor)
    else
        if not na(darvasBox)
            box.delete(darvasBox)
            darvasBox := na
        if not na(midLine)
            line.delete(midLine)
            midLine := na
        if not na(boxBadge)
            label.delete(boxBadge)
            boxBadge := na

    if showBreakoutLabels and qualifiedBreakout and cooldownReady
        string breakText = (breakSide == 1 ? "UP " : "DN ") + str.tostring(math.round(breakoutScore)) + " " + f_grade(breakoutScore)
        float breakY = breakSide == 1 ? high + atrSafe * labelOffsetAtr : low - atrSafe * labelOffsetAtr
        bool upperCrowdedBreak = breakSide == 1 and not na(lastUpperLabelBar) and bar_index - lastUpperLabelBar <= labelCooldownBars * 2
        bool lowerCrowdedBreak = breakSide == -1 and not na(lastLowerLabelBar) and bar_index - lastLowerLabelBar <= labelCooldownBars * 2
        breakY := upperCrowdedBreak ? math.max(breakY, lastUpperLabelY + atrSafe * labelStackAtr) : breakY
        breakY := lowerCrowdedBreak ? math.min(breakY, lastLowerLabelY - atrSafe * labelStackAtr) : breakY
        breakStyle = breakSide == 1 ? label.style_label_down : label.style_label_up
        color breakColor = breakSide == 1 ? bullColor : bearColor
        label breakLabel = label.new(bar_index, breakY, breakText, xloc = xloc.bar_index, style = breakStyle, color = color.new(breakColor, 0), textcolor = f_text_on(breakColor), size = f_text_size(labelSizeInput))
        f_track_label(breakLabel)
        if breakSide == 1
            lastUpperLabelBar := bar_index
            lastUpperLabelY := breakY
        if breakSide == -1
            lastLowerLabelBar := bar_index
            lastLowerLabelY := breakY
        lastEventBar := bar_index

    boxActive := false
    candidateActive := false

// -------------------------------------------------
// Breakout Hit Rate (Proof Pass resolution)
// -------------------------------------------------
// After proofWindowBars, check whether price is still beyond the broken Darvas
// boundary in the breakout direction. Builds an honest follow-through rate.
if barstate.isconfirmed and brkProofPending and not na(brkProofStart) and bar_index - brkProofStart >= proofWindowBars
    bool brkHit = brkProofDir > 0 ? close > brkProofBoundary : close < brkProofBoundary
    brkProofTotal += 1
    if brkHit
        brkProofHits += 1
    brkProofPending := false

float brkProofRate = brkProofTotal > 0 ? brkProofHits / brkProofTotal * 100.0 : na
string brkRateText = brkProofTotal > 0 ? str.tostring(int(math.round(brkProofRate))) + "% (" + str.tostring(brkProofHits) + "/" + str.tostring(brkProofTotal) + ")" : "Building"
color brkRateColor = brkProofTotal == 0 ? neutralColor : brkProofRate >= 60.0 ? bullColor : brkProofRate >= 45.0 ? neutralColor : bearColor

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelTextSize = f_text_size(panelFontSizeInput)
boxAgeText = boxActive ? str.tostring(contextAge) + " bars" : candidateActive ? "Forming " + str.tostring(contextAge) : "Waiting"
compressionText = hasContext ? str.tostring(math.round(compressionScore)) + "/100" : "n/a"
sideText = boxActive ? "Inside Box" : latestBreakSide == 0 ? "None" : f_side_text(latestBreakSide)
volumeText = volumeReady ? (volumeSupported ? "Supported " : "Low ") + str.tostring(volumeRatio, "#.##") + "x" : "n/a"
qualityText = boxActive ? str.tostring(math.round(compressionScore)) + "/100 " + f_grade(compressionScore) : not na(latestBreakScore) ? str.tostring(math.round(latestBreakScore)) + "/100 " + f_grade(latestBreakScore) : "n/a"
isFailedState = latestState == "Failed Up" or latestState == "Failed Down"
stateColor = latestState == "Confirmed" ? (latestBreakSide == 1 ? bullColor : bearColor) : latestState == "Weak Break" ? neutralColor : isFailedState ? bearColor : f_panel_value()

var table infoPanel = na

if barstate.islast
    if showPanel
        if na(infoPanel)
            infoPanel := table.new(f_panel_position(panelLocation), 2, 7, bgcolor = f_panel_bg(), border_color = f_panel_border(), border_width = 1, frame_color = f_panel_border(), frame_width = 1)
        table.set_position(infoPanel, f_panel_position(panelLocation))
        table.set_border_color(infoPanel, f_panel_border())
        table.set_frame_color(infoPanel, f_panel_border())
        table.clear(infoPanel, 0, 0, 1, 6)
        table.cell(infoPanel, 0, 0, "AG Pro Darvas Box Breakout Quality", text_color = headerText, bgcolor = headerBg, text_size = panelTextSize, text_halign = text.align_center)
        table.cell(infoPanel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelTextSize)
        table.merge_cells(infoPanel, 0, 0, 1, 0)
        table.cell(infoPanel, 0, 1, "Box Age", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelTextSize)
        table.cell(infoPanel, 1, 1, boxAgeText, text_color = f_panel_value(), bgcolor = f_panel_bg(), text_size = panelTextSize)
        table.cell(infoPanel, 0, 2, "Compression", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelTextSize)
        table.cell(infoPanel, 1, 2, compressionText, text_color = compressionScore >= 65 ? bullColor : compressionScore >= 40 ? neutralColor : bearColor, bgcolor = f_panel_bg(), text_size = panelTextSize)
        table.cell(infoPanel, 0, 3, "Breakout Side", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelTextSize)
        table.cell(infoPanel, 1, 3, sideText, text_color = boxActive ? accentColor : latestBreakSide == 1 ? bullColor : latestBreakSide == -1 ? bearColor : f_panel_value(), bgcolor = f_panel_bg(), text_size = panelTextSize)
        table.cell(infoPanel, 0, 4, "Volume Support", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelTextSize)
        table.cell(infoPanel, 1, 4, volumeText, text_color = volumeSupported ? bullColor : neutralColor, bgcolor = f_panel_bg(), text_size = panelTextSize)
        table.cell(infoPanel, 0, 5, "Breakout Hit Rate", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelTextSize)
        table.cell(infoPanel, 1, 5, brkRateText, text_color = brkRateColor, bgcolor = f_panel_bg(), text_size = panelTextSize)
        table.cell(infoPanel, 0, 6, latestState, text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelTextSize)
        table.cell(infoPanel, 1, 6, qualityText, text_color = stateColor, bgcolor = f_panel_bg(), text_size = panelTextSize)
    else
        if not na(infoPanel)
            table.delete(infoPanel)
            infoPanel := na

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(qualifiedBreakout and breakSide == 1, "High-Quality Bullish Darvas Breakout", "Darvas Box Breakout Quality: high-quality bullish breakout confirmed.")
alertcondition(qualifiedBreakout and breakSide == -1, "High-Quality Bearish Darvas Breakout", "Darvas Box Breakout Quality: high-quality bearish breakout confirmed.")
alertcondition(failedUp, "Failed Bullish Darvas Breakout", "Darvas Box Breakout Quality: bullish Darvas breakout failed back inside the box.")
alertcondition(failedDown, "Failed Bearish Darvas Breakout", "Darvas Box Breakout Quality: bearish Darvas breakout failed back inside the box.")
````

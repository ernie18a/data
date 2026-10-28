# Quasimodo Reversal Zones [AGPro Series]

- url: https://www.tradingview.com/script/zqlDPLfS-Quasimodo-Reversal-Zones-AGPro-Series/
- type: indicator
- pine_id: PUB;c20a47a5d51f444fb2b955bd7ee5af1a
- version: 4.0

## Description

Quasimodo Reversal Zones [AGPro Series]

🔹 OVERVIEW

Quasimodo Reversal Zones [AGPro Series] is a focused Smart Money Concepts tool built around one specific idea: the Quasimodo reversal pattern.

Instead of turning the chart into a crowded market-structure dashboard, this script identifies confirmed QM swing sequences, marks the original shoulder-derived QM level, projects a clean reaction zone, and tracks the invalidation threshold from the head.

The goal is simple: help traders see where a valid Quasimodo structure formed, where price may revisit the QM level, whether the reaction zone is active, and when the structure has failed.

It is designed as a premium public-free AGPro tool for traders who want a clean, visual, and selective Quasimodo framework without generic signal clutter.

🔹 WHAT MAKES IT DIFFERENT

Most reversal tools try to detect too many patterns at the same time. They often combine double tops, double bottoms, head and shoulders, order blocks, BOS, CHOCH, liquidity sweeps, and support/resistance zones into one heavy overlay.

Quasimodo Reversal Zones [AGPro Series] stays intentionally narrow.

Its only job is to map Quasimodo reversal structures with quality scoring, reaction-zone tracking, and invalidation logic. This makes the script easier to read, easier to trust visually, and more useful as a dedicated QM layer inside a larger trading workflow.

The script also avoids marking every small pivot as a pattern. A valid QM structure must pass multiple filters:

- confirmed swing sequence,
- meaningful head extension,
- displacement beyond the pullback swing,
- minimum spacing between pivots,
- swing amplitude quality,
- time-balance evaluation,
- optional relative-volume participation.

This gives the tool a more selective and professional feel than simple pivot-label scripts.

🧭 WHY THIS DOES NOT OVERLAP WITH OTHER AGPRO TOOLS

This script was designed to stay in a very specific lane inside the AGPro Series catalog.

It is not a broad reversal-pattern scanner.
It is not a BOS or CHOCH dashboard.
It is not an order block tool.
It is not a generic support/resistance zone engine.
It is not a liquidity sweep module.

Its focus is the Quasimodo pattern only.

The visual logic is built around four QM-specific components:

- the shoulder,
- the head,
- the QM level,
- the reaction zone with invalidation.

That narrow structure keeps the tool differentiated from broader AGPro pattern, breakout, structure, and zone-based scripts while still giving traders a strong SMC-style visual experience.

⚙️ METHODOLOGY

The script uses confirmed swing pivots to build a four-step Quasimodo sequence.

For a bullish QM structure, the script looks for:

- an initial swing low,
- a swing high,
- a lower low that forms the head,
- a higher high that confirms the sequence break.

For a bearish QM structure, the script looks for:

- an initial swing high,
- a swing low,
- a higher high that forms the head,
- a lower low that confirms the sequence break.

After the sequence is confirmed, the original shoulder becomes the QM level. A compact ATR-based reaction box is projected around that level. The head becomes the invalidation reference, with optional ATR padding.

The quality score is built from:

- head extension strength,
- sequence-break displacement,
- spacing between pivots,
- average swing size,
- internal time balance,
- optional relative-volume confirmation.

Only structures that meet the selected score threshold are drawn on the chart.

📊 PANEL

The AGPro panel summarizes the latest valid QM structure in a compact format.

Panel fields:

- Pattern Side
- Structure Quality
- Zone Status
- Score

The first panel row follows the AGPro standard: one merged blue header row containing only the script name.

Panel location, panel theme, and panel font size are adjustable from settings. The default panel size is Normal for a clean publication-ready layout.

🎛️ KEY INPUTS

Swing Pivot Length
Controls how strict the confirmed swing structure should be. Higher values create fewer but cleaner patterns.

ATR Normalization Length
Used to normalize zone width, head extension, sequence displacement, label offset, and invalidation padding.

Minimum Head Extension
Defines how far the head must extend beyond the original shoulder before the sequence can qualify.

Minimum Sequence Break
Defines how strongly the final swing must break beyond the pullback level.

Minimum Pattern Score
Filters out weaker QM sequences before they are drawn.

Signal Cooldown Bars
Controls label density and prevents the chart from becoming overloaded on noisy markets.

Reaction Zone Width
Controls the ATR-based thickness of the projected QM reaction box.

Reaction Zone Length
Controls how far the reaction zone projects into the future.

Invalidation Buffer
Adds optional ATR padding beyond the head-based invalidation level.

Maximum Visible QM Zones
Limits how many recent QM zones remain visible on the chart.

Label Font Size and Panel Font Size
Both are adjustable, with Normal as the default setting.

🔍 HOW TO READ IT

Start with the panel.

Pattern Side shows whether the latest valid structure is bullish or bearish.
Structure Quality gives a quick qualitative view of the setup.
Zone Status shows whether the reaction zone is waiting, active, confirmed, or invalidated.
Score shows the numerical strength of the latest accepted QM pattern.

On the chart:

- Shoulder marks the original level that later becomes the QM reference.
- Head marks the extension that creates the imbalance.
- QM Level marks the precise shoulder-derived reaction level.
- Reaction Zone shows the area where the QM retest is being tracked.
- Invalidation Line shows where the structure is no longer valid.
- Status Label shows the live state of the latest zone.

The cleanest reads usually come when price returns to the reaction zone after a strong sequence break and then shows a visible response away from the QM level.

🧩 BEST USE CASES

This script is best used for:

- SMC-style Quasimodo analysis,
- swing-based reversal mapping,
- reaction-zone planning,
- invalidation-based structure review,
- higher-timeframe QM context,
- clean chart screenshots for public analysis,
- traders who want one dedicated QM layer instead of a large all-in-one structure scanner.

It can be useful on many markets and timeframes, but the best visual quality usually appears on charts where swings are clear and price action is not excessively compressed.

🧠 VISUAL DESIGN PHILOSOPHY

The visual design is built around clarity, not clutter.

The script uses the AGPro color palette with a restrained premium look:

- blue merged panel header,
- teal bullish structures,
- pink bearish structures,
- gold invalidation or inactive-state emphasis,
- compact labels placed away from candles where possible,
- projected boxes that stay readable without covering the chart.

The chart should not feel empty, but it should also not feel noisy. Labels, zones, and status elements are intentionally controlled with cooldowns, maximum visible zones, adjustable offsets, and configurable font sizes.

The goal is to make the QM story easy to understand at first glance.

🔔 ALERTS

The script includes alerts for important QM events:

- Bullish Quasimodo Sequence
- Bearish Quasimodo Sequence
- QM Reaction Zone Touched
- QM Reaction Confirmed
- QM Pattern Invalidated

These alerts are designed around structure events rather than generic entry messages.

🔹 LIMITATIONS AND TRANSPARENCY

This script uses confirmed pivots, so patterns are confirmed only after enough bars have passed to validate the swing structure.

It is intentionally selective. Some early or aggressive QM ideas may not appear if they fail the pivot, spacing, displacement, or score requirements.

The script is not designed to predict every reversal. It is designed to identify cleaner Quasimodo structures, display the relevant reaction zone, and provide a clear invalidation reference.

It also does not attempt to replace broader market analysis. Trend context, volatility, liquidity conditions, and higher-timeframe structure can still matter.

✅ IDEAL USER

This script is ideal for traders who:

- understand basic SMC and price-action concepts,
- want a clean Quasimodo-specific tool,
- prefer visual structure over signal spam,
- care about invalidation and reaction-zone logic,
- want a focused public-free AGPro tool that does not overlap with broader reversal scanners,
- value a premium chart presentation with adjustable labels, zones, and panel controls.

Quasimodo Reversal Zones [AGPro Series] is built for traders who want the QM pattern to be visible, structured, and easy to evaluate without adding unnecessary market-structure clutter.

## Source Code

````pine
// -------------------------------------------------
// Quasimodo Reversal Zones [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.1
//
// Quasimodo Reversal Zones detects confirmed QM swing sequences, maps the
// shoulder-derived reversal level, projects a clean reaction zone with a single
// consolidated badge showing side, status, and score, tracks
// retest/reaction/invalidated states, and scores pattern quality using swing
// geometry, displacement, spacing, swing range balance, and optional relative
// volume context. A Reaction Rate reports how often past accepted QM zones
// confirmed a reaction before being invalidated. The educational swing path is
// available as an optional layer.
//
// Version 2.1: luminance-aware text contrast on every badge and label, and a
// Reaction Rate proof layer in the panel.
// -------------------------------------------------

//@version=6
indicator("Quasimodo Reversal Zones [AGPro Series]",
     shorttitle = "AG Pro QMZ",
     overlay = true,
     max_boxes_count = 100,
     max_lines_count = 220,
     max_labels_count = 320)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
basePanelBg   = color.rgb(15, 23, 42)
basePanelBorder = color.rgb(51, 65, 85)
basePanelLabel  = color.rgb(148, 163, 184)
basePanelValue  = color.rgb(226, 232, 240)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)
darkInk       = color.rgb(15, 23, 42)

// Luminance-aware text color: dark ink on light badges, light text on dark badges.
f_text_on(color _bg) =>
    float _lum = 0.299 * color.r(_bg) + 0.587 * color.g(_bg) + 0.114 * color.b(_bg)
    _lum > 145 ? darkInk : headerText

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "QM Sequence Engine"
pivotLen = input.int(4, "Swing Pivot Length", minval = 2, maxval = 12, group = groupEngine, tooltip = "Bars required on each side of a confirmed swing point. Higher values create fewer but cleaner Quasimodo structures.")
atrLen = input.int(14, "ATR Normalization Length", minval = 5, maxval = 100, group = groupEngine, tooltip = "ATR normalizes head extension, sequence break quality, reaction-zone width, label offsets, and invalidation padding.")
minHeadAtr = input.float(0.60, "Minimum Head Extension ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupEngine, tooltip = "Minimum distance between the original shoulder level and the later head, measured in ATR.")
minBreakAtr = input.float(0.35, "Minimum Sequence Break ATR", minval = 0.10, maxval = 2.00, step = 0.05, group = groupEngine, tooltip = "Minimum displacement beyond the pullback swing after the head forms. This confirms the Quasimodo sequence.")
minSwingSpacing = input.int(4, "Minimum Swing Spacing", minval = 1, maxval = 50, group = groupEngine, tooltip = "Minimum bar distance between the four confirmed swing points.")
minPatternScore = input.int(55, "Minimum Pattern Score", minval = 1, maxval = 100, group = groupEngine, tooltip = "Only patterns with a quality score at or above this value will draw zones and labels.")
signalCooldown = input.int(20, "Signal Cooldown Bars", minval = 0, maxval = 250, group = groupEngine, tooltip = "Minimum bars between newly accepted QM structures.")
useVolumeScore = input.bool(true, "Use Relative Volume in Score", group = groupEngine, tooltip = "When enabled, relative volume contributes to the final structure score.")

groupZones = "Reaction Zone"
zoneWidthAtr = input.float(0.18, "Reaction Zone Width ATR", minval = 0.05, maxval = 1.00, step = 0.01, group = groupZones, tooltip = "Reaction-zone half-width around the QM level, expressed as an ATR multiple.")
zoneForwardBars = input.int(60, "Reaction Zone Length", minval = 40, maxval = 500, group = groupZones, tooltip = "Number of bars the active reaction box projects to the right. Also the window used by the Reaction Rate proof.")
invalidBufferAtr = input.float(0.10, "Invalidation Buffer ATR", minval = 0.00, maxval = 1.00, step = 0.01, group = groupZones, tooltip = "Additional ATR padding beyond the head used to place the invalidation line.")
reactionConfirmAtr = input.float(0.35, "Reaction Confirmation Distance ATR", minval = 0.05, maxval = 2.00, step = 0.05, group = groupZones, tooltip = "Distance away from the zone required after a touch before the status changes to Reaction Confirmed.")
maxVisibleZones = input.int(2, "Maximum Visible QM Zones", minval = 1, maxval = 12, group = groupZones, tooltip = "Maximum recent QM structures kept visible. Older structures are removed first.")
showReactionBoxes = input.bool(true, "Show Reaction Boxes", group = groupZones, tooltip = "Draws the QM reaction box around the shoulder-derived level.")
showQmLevel = input.bool(true, "Show QM Level", group = groupZones, tooltip = "Shows the exact shoulder-derived QM level inside the reaction box.")
showInvalidation = input.bool(true, "Show Invalidation Line", group = groupZones, tooltip = "Shows the head-based invalidation threshold for the latest accepted QM pattern.")
showZoneBadges = input.bool(true, "Show Centered Zone Badges", group = groupZones, tooltip = "Adds a separate centered badge inside the active reaction zone.")

groupVisual = "Visual Style"
showStructurePath = input.bool(false, "Show Educational QM Path", group = groupVisual, tooltip = "Optional. Draws the four-point Quasimodo swing path so users can see the sequence structure. Off by default for a cleaner chart.")
structureLineWidth = input.int(3, "QM Path Width", minval = 1, maxval = 5, group = groupVisual, tooltip = "Controls the thickness of the educational QM swing path.")
showSwingLabels = input.bool(false, "Show Structure Point Labels", group = groupVisual, tooltip = "Optional. Shows LS, PB, Head, and BOS labels at the confirmed QM swing points. Off by default for a cleaner chart.")
showStatusLabels = input.bool(false, "Show Separate Status Label", group = groupVisual, tooltip = "Optional. Adds an extra right-side status label. Off by default because the centered zone badge already shows side, status, and score.")
keepStructureHistory = input.bool(true, "Keep Structure History", group = groupVisual, tooltip = "Keeps educational QM paths and point labels on historical detected structures.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisual, tooltip = "Controls swing, QM level, and status label size.")
labelOffsetAtr = input.float(0.75, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupVisual, tooltip = "ATR-based vertical offset used to keep swing labels away from candles.")
labelRightOffset = input.int(8, "Right Label Offset", minval = 1, maxval = 40, group = groupVisual, tooltip = "Bars to the right used for QM level and status labels.")

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = "Shows the AGPro status panel with side, structure quality, zone status, reaction rate, and score.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group = groupPanel, tooltip = "Moves the AGPro status panel.")
panelThemeInput = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = groupPanel, tooltip = "Controls the panel color theme.")
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel, tooltip = "Controls the dashboard font size.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(value, maxValue))

f_norm(float value, float target) =>
    target <= 0.0 ? 0.0 : f_clamp(value / target, 0.0, 1.0)

f_size(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : s == "Huge" ? size.huge : size.normal

f_panel_pos(string p) =>
    p == "Top Left" ? position.top_left :
     p == "Top Center" ? position.top_center :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Center" ? position.middle_center :
     p == "Middle Left" ? position.middle_left :
     p == "Bottom Right" ? position.bottom_right :
     p == "Bottom Center" ? position.bottom_center :
     p == "Bottom Left" ? position.bottom_left : position.top_right

f_panel_bg() =>
    panelThemeInput == "Clean Light" ? color.rgb(248, 250, 252) : panelThemeInput == "Slate" ? color.rgb(30, 41, 59) : basePanelBg

f_panel_label_bg() =>
    panelThemeInput == "Clean Light" ? color.rgb(226, 232, 240) : panelThemeInput == "Slate" ? color.rgb(51, 65, 85) : color.rgb(22, 32, 56)

f_panel_label() =>
    panelThemeInput == "Clean Light" ? color.rgb(71, 85, 105) : basePanelLabel

f_panel_value() =>
    panelThemeInput == "Clean Light" ? color.rgb(15, 23, 42) : basePanelValue

f_panel_border() =>
    panelThemeInput == "Clean Light" ? color.rgb(203, 213, 225) : basePanelBorder

f_quality_text(float scoreValue) =>
    na(scoreValue) ? "No Pattern" : scoreValue >= 78.0 ? "Prime" : scoreValue >= 65.0 ? "Clean" : scoreValue >= 50.0 ? "Developing" : "Weak"

f_score_color(float scoreValue) =>
    na(scoreValue) ? f_panel_value() : scoreValue >= 65.0 ? bullColor : scoreValue >= 50.0 ? neutralColor : bearColor

f_side_text(int sideValue) =>
    sideValue == 1 ? "Bullish QM" : sideValue == -1 ? "Bearish QM" : "No Pattern"

f_record_pivot(int pivotType, float pivotPrice, int pivotBar, array<int> types, array<float> prices, array<int> bars) =>
    accepted = false
    pivotCount = array.size(types)
    if pivotCount == 0
        array.push(types, pivotType)
        array.push(prices, pivotPrice)
        array.push(bars, pivotBar)
        accepted := true
    else
        lastIndex = pivotCount - 1
        lastType = array.get(types, lastIndex)
        lastPrice = array.get(prices, lastIndex)
        if pivotType == lastType
            replacePivot = (pivotType == 1 and pivotPrice > lastPrice) or (pivotType == -1 and pivotPrice < lastPrice)
            if replacePivot
                array.set(prices, lastIndex, pivotPrice)
                array.set(bars, lastIndex, pivotBar)
                accepted := true
        else
            array.push(types, pivotType)
            array.push(prices, pivotPrice)
            array.push(bars, pivotBar)
            accepted := true
    while array.size(types) > 12
        array.shift(types)
        array.shift(prices)
        array.shift(bars)
    accepted

f_trim_boxes(array<box> boxes, int maxCount) =>
    while array.size(boxes) > maxCount
        oldBox = array.shift(boxes)
        box.delete(oldBox)

f_trim_lines(array<line> lines, int maxCount) =>
    while array.size(lines) > maxCount
        oldLine = array.shift(lines)
        line.delete(oldLine)

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        oldLabel = array.shift(labels)
        label.delete(oldLabel)

labelSize = f_size(labelSizeInput)
panelTextSize = f_size(panelSizeInput)

// -------------------------------------------------
// Core Data
// -------------------------------------------------
atrRaw = ta.atr(atrLen)
barVolatility = math.max(high - low, syminfo.mintick)
atrValue = na(atrRaw) ? barVolatility : math.max(atrRaw, syminfo.mintick)
volumeBase = ta.sma(nz(volume), 20)
relativeVolume = volumeBase > 0.0 ? nz(volume) / volumeBase : 1.0

var array<int> pivotTypes = array.new_int()
var array<float> pivotPrices = array.new_float()
var array<int> pivotBars = array.new_int()

var array<box> qmBoxes = array.new<box>()
var array<line> qmLines = array.new<line>()
var array<label> qmLabels = array.new<label>()
var array<label> qmZoneBadges = array.new<label>()

var int activeSide = 0
var float activeLevel = na
var float activeZoneTop = na
var float activeZoneBottom = na
var float activeInvalidation = na
var float activeScore = na
var bool activeTouched = false
var bool activeReaction = false
var bool activeInvalidated = false
var string activeStatus = "No Pattern"
var box activeBox = na
var label activeZoneBadge = na
var line activeQmLine = na
var line activeInvalidLine = na
var label activeStatusLabel = na
var int lastDetectedPivotBar = na
var int lastSignalBar = na

// Reaction Rate proof state (share of accepted QM zones that confirmed a reaction before invalidation)
var int   qmWins = 0
var int   qmTotal = 0
var bool  qmPending = false
var int   qmPendingSide = 0
var float qmPendingTarget = na
var float qmPendingStop = na
var int   qmPendingStartBar = na

newBullishPattern = false
newBearishPattern = false
reactionTouchEvent = false
reactionConfirmEvent = false
invalidationEvent = false

// -------------------------------------------------
// Pivot Capture
// -------------------------------------------------
pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)
newPivot = false

if not na(pivotHigh)
    newPivot := f_record_pivot(1, pivotHigh, bar_index - pivotLen, pivotTypes, pivotPrices, pivotBars) or newPivot

if not na(pivotLow)
    newPivot := f_record_pivot(-1, pivotLow, bar_index - pivotLen, pivotTypes, pivotPrices, pivotBars) or newPivot

// -------------------------------------------------
// QM Sequence Detection
// -------------------------------------------------
bool detectedPattern = false
int detectedSide = 0
float detectedScore = na
float detectedLevel = na
float detectedZoneTop = na
float detectedZoneBottom = na
float detectedInvalidation = na
float detectedP1 = na
float detectedP2 = na
float detectedP3 = na
float detectedP4 = na
int detectedP1Bar = na
int detectedP2Bar = na
int detectedP3Bar = na
int detectedP4Bar = na

if newPivot and array.size(pivotTypes) >= 4
    pivotCount = array.size(pivotTypes)
    t1 = array.get(pivotTypes, pivotCount - 4)
    t2 = array.get(pivotTypes, pivotCount - 3)
    t3 = array.get(pivotTypes, pivotCount - 2)
    t4 = array.get(pivotTypes, pivotCount - 1)
    p1 = array.get(pivotPrices, pivotCount - 4)
    p2 = array.get(pivotPrices, pivotCount - 3)
    p3 = array.get(pivotPrices, pivotCount - 2)
    p4 = array.get(pivotPrices, pivotCount - 1)
    p1Bar = array.get(pivotBars, pivotCount - 4)
    p2Bar = array.get(pivotBars, pivotCount - 3)
    p3Bar = array.get(pivotBars, pivotCount - 2)
    p4Bar = array.get(pivotBars, pivotCount - 1)

    bullShape = t1 == -1 and t2 == 1 and t3 == -1 and t4 == 1 and p3 < p1 and p4 > p2
    bearShape = t1 == 1 and t2 == -1 and t3 == 1 and t4 == -1 and p3 > p1 and p4 < p2

    if bullShape or bearShape
        candidateSide = bullShape ? 1 : -1
        headMove = candidateSide == 1 ? p1 - p3 : p3 - p1
        breakMove = candidateSide == 1 ? p4 - p2 : p2 - p4
        gapA = p2Bar - p1Bar
        gapB = p3Bar - p2Bar
        gapC = p4Bar - p3Bar
        spacingOk = gapA >= minSwingSpacing and gapB >= minSwingSpacing and gapC >= minSwingSpacing
        geometryOk = headMove >= atrValue * minHeadAtr and breakMove >= atrValue * minBreakAtr
        cooldownOk = na(lastSignalBar) or bar_index - lastSignalBar >= signalCooldown
        duplicateOk = na(lastDetectedPivotBar) or p4Bar != lastDetectedPivotBar

        headScore = f_norm(headMove, atrValue * minHeadAtr * 2.0) * 25.0
        breakScore = f_norm(breakMove, atrValue * minBreakAtr * 2.0) * 25.0
        smallestGap = math.min(gapA, math.min(gapB, gapC))
        spacingScore = f_norm(float(smallestGap), float(minSwingSpacing) * 2.0) * 15.0
        averageSwingSize = (math.abs(p2 - p1) + math.abs(p3 - p2) + math.abs(p4 - p3)) / 3.0
        rangeScore = f_norm(averageSwingSize, atrValue * 1.25) * 15.0
        averageGap = math.max(1.0, float(gapA + gapB + gapC) / 3.0)
        balanceDrift = math.abs(float(gapA - gapB)) / averageGap
        balanceScore = (1.0 - f_clamp(balanceDrift, 0.0, 1.0)) * 10.0
        volumeScore = useVolumeScore ? f_norm(relativeVolume, 1.35) * 10.0 : 10.0
        candidateScore = f_clamp(math.round(headScore + breakScore + spacingScore + rangeScore + balanceScore + volumeScore), 0.0, 100.0)

        if spacingOk and geometryOk and cooldownOk and duplicateOk and candidateScore >= float(minPatternScore)
            detectedPattern := true
            detectedSide := candidateSide
            detectedScore := candidateScore
            detectedLevel := p1
            zoneHalfWidth = math.max(atrValue * zoneWidthAtr, syminfo.mintick * 2.0)
            detectedZoneTop := detectedLevel + zoneHalfWidth
            detectedZoneBottom := detectedLevel - zoneHalfWidth
            detectedInvalidation := detectedSide == 1 ? p3 - atrValue * invalidBufferAtr : p3 + atrValue * invalidBufferAtr
            detectedP1 := p1
            detectedP2 := p2
            detectedP3 := p3
            detectedP4 := p4
            detectedP1Bar := p1Bar
            detectedP2Bar := p2Bar
            detectedP3Bar := p3Bar
            detectedP4Bar := p4Bar

// -------------------------------------------------
// Drawing and Active State
// -------------------------------------------------
if detectedPattern
    lastDetectedPivotBar := detectedP4Bar
    lastSignalBar := bar_index
    activeSide := detectedSide
    activeLevel := detectedLevel
    activeZoneTop := detectedZoneTop
    activeZoneBottom := detectedZoneBottom
    activeInvalidation := detectedInvalidation
    activeScore := detectedScore
    activeTouched := false
    activeReaction := false
    activeInvalidated := false
    activeStatus := "Awaiting Retest"
    activeBox := na
    activeZoneBadge := na
    activeQmLine := na
    activeInvalidLine := na
    activeStatusLabel := na

    patternColor = detectedSide == 1 ? bullColor : bearColor
    patternFill = color.new(patternColor, 84)
    patternBorder = color.new(patternColor, 10)
    rightEdge = bar_index + zoneForwardBars

    if showStructurePath
        l1 = line.new(detectedP1Bar, detectedP1, detectedP2Bar, detectedP2, xloc = xloc.bar_index, color = color.new(patternColor, 0), style = line.style_solid, width = structureLineWidth)
        l2 = line.new(detectedP2Bar, detectedP2, detectedP3Bar, detectedP3, xloc = xloc.bar_index, color = color.new(patternColor, 0), style = line.style_solid, width = structureLineWidth)
        l3 = line.new(detectedP3Bar, detectedP3, detectedP4Bar, detectedP4, xloc = xloc.bar_index, color = color.new(patternColor, 0), style = line.style_solid, width = structureLineWidth)
        array.push(qmLines, l1)
        array.push(qmLines, l2)
        array.push(qmLines, l3)

    if showReactionBoxes
        activeBox := box.new(left = detectedP4Bar, top = detectedZoneTop, right = rightEdge, bottom = detectedZoneBottom, xloc = xloc.bar_index, bgcolor = patternFill, border_color = patternBorder, border_width = 2)
        array.push(qmBoxes, activeBox)
        if showZoneBadges
            badgeText = (detectedSide == 1 ? "BULLISH QM" : "BEARISH QM") + " | AWAITING | " + str.tostring(math.round(detectedScore))
            activeZoneBadge := label.new(x = int(math.round((detectedP4Bar + rightEdge) * 0.5)), y = detectedLevel, text = badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = f_text_on(patternColor), color = color.new(patternColor, 0), size = labelSize)
            array.push(qmZoneBadges, activeZoneBadge)

    if showQmLevel
        activeQmLine := line.new(x1 = detectedP1Bar, y1 = detectedLevel, x2 = rightEdge, y2 = detectedLevel, xloc = xloc.bar_index, extend = extend.none, color = patternColor, style = line.style_solid, width = 2)
        array.push(qmLines, activeQmLine)

    if showInvalidation
        activeInvalidLine := line.new(x1 = detectedP3Bar, y1 = detectedInvalidation, x2 = rightEdge, y2 = detectedInvalidation, xloc = xloc.bar_index, extend = extend.none, color = color.new(patternColor, 35), style = line.style_dotted, width = 1)
        array.push(qmLines, activeInvalidLine)

    if showSwingLabels
        isBull = detectedSide == 1
        p1Y = isBull ? detectedP1 - atrValue * labelOffsetAtr : detectedP1 + atrValue * labelOffsetAtr
        p2Y = isBull ? detectedP2 + atrValue * labelOffsetAtr : detectedP2 - atrValue * labelOffsetAtr
        p3Y = isBull ? detectedP3 - atrValue * labelOffsetAtr : detectedP3 + atrValue * labelOffsetAtr
        p4Y = isBull ? detectedP4 + atrValue * labelOffsetAtr : detectedP4 - atrValue * labelOffsetAtr
        lowStyle = label.style_label_up
        highStyle = label.style_label_down
        p1Label = label.new(x = detectedP1Bar, y = p1Y, text = "LS", xloc = xloc.bar_index, style = isBull ? lowStyle : highStyle, textcolor = f_text_on(patternColor), color = color.new(patternColor, 0), size = labelSize)
        p2Label = label.new(x = detectedP2Bar, y = p2Y, text = "PB", xloc = xloc.bar_index, style = isBull ? highStyle : lowStyle, textcolor = f_text_on(accentColor), color = color.new(accentColor, 0), size = labelSize)
        p3Label = label.new(x = detectedP3Bar, y = p3Y, text = "HEAD", xloc = xloc.bar_index, style = isBull ? lowStyle : highStyle, textcolor = f_text_on(patternColor), color = color.new(patternColor, 0), size = labelSize)
        p4Label = label.new(x = detectedP4Bar, y = p4Y, text = "BOS", xloc = xloc.bar_index, style = isBull ? highStyle : lowStyle, textcolor = f_text_on(neutralColor), color = color.new(neutralColor, 0), size = labelSize)
        array.push(qmLabels, p1Label)
        array.push(qmLabels, p2Label)
        array.push(qmLabels, p3Label)
        array.push(qmLabels, p4Label)

    if showStatusLabels
        statusY = detectedSide == 1 ? detectedZoneTop + atrValue * 0.45 : detectedZoneBottom - atrValue * 0.45
        activeStatusLabel := label.new(x = bar_index + labelRightOffset, y = statusY, text = "AWAITING | " + str.tostring(math.round(detectedScore)), xloc = xloc.bar_index, style = label.style_label_left, textcolor = f_text_on(patternColor), color = color.new(patternColor, 0), size = labelSize)
        array.push(qmLabels, activeStatusLabel)

    f_trim_boxes(qmBoxes, maxVisibleZones)
    f_trim_lines(qmLines, maxVisibleZones * 6)
    f_trim_labels(qmLabels, maxVisibleZones * 8)
    f_trim_labels(qmZoneBadges, maxVisibleZones * 2)

    if not keepStructureHistory and array.size(qmLabels) > 8
        f_trim_labels(qmLabels, 8)
        f_trim_lines(qmLines, 6)

    newBullishPattern := detectedSide == 1
    newBearishPattern := detectedSide == -1

if activeSide != 0
    wasTouched = activeTouched
    wasReaction = activeReaction
    wasInvalidated = activeInvalidated
    zoneTouched = high >= activeZoneBottom and low <= activeZoneTop
    invalidNow = activeSide == 1 ? low <= activeInvalidation : high >= activeInvalidation
    reactionNow = activeSide == 1 ? close > activeZoneTop + atrValue * reactionConfirmAtr : close < activeZoneBottom - atrValue * reactionConfirmAtr

    activeTouched := activeTouched or zoneTouched
    activeReaction := activeReaction or (activeTouched and reactionNow)
    activeInvalidated := activeInvalidated or invalidNow

    reactionTouchEvent := zoneTouched and not wasTouched
    reactionConfirmEvent := activeReaction and not wasReaction
    invalidationEvent := activeInvalidated and not wasInvalidated

    if activeInvalidated
        activeStatus := "Invalidated"
    else if activeReaction
        activeStatus := "Reaction Confirmed"
    else if activeTouched
        activeStatus := "Reaction Active"
    else
        activeStatus := "Awaiting Retest"

    activePatternColor = activeSide == 1 ? bullColor : bearColor
    activeStatusColor = activeInvalidated ? neutralColor : activeReaction ? activePatternColor : activeTouched ? accentColor : activePatternColor
    activeFillColor = activeInvalidated ? color.new(neutralColor, 88) : activeReaction ? color.new(activePatternColor, 80) : activeTouched ? color.new(accentColor, 83) : color.new(activePatternColor, 84)
    activeRightEdge = bar_index + zoneForwardBars
    sideShort = activeSide == 1 ? "BULLISH QM" : "BEARISH QM"
    statusShort = activeInvalidated ? "INVALID" : activeReaction ? "REACTION" : activeTouched ? "ACTIVE" : "AWAITING"
    scoreShort = str.tostring(math.round(activeScore))
    liveBadge = sideShort + " | " + statusShort + " | " + scoreShort

    if not na(activeBox)
        box.set_right(activeBox, activeRightEdge)
        box.set_bgcolor(activeBox, activeFillColor)
        box.set_border_color(id = activeBox, color = activeStatusColor)

    if not na(activeZoneBadge)
        label.set_x(activeZoneBadge, int(math.round((bar_index + activeRightEdge) * 0.5)))
        label.set_y(activeZoneBadge, activeLevel)
        label.set_text(activeZoneBadge, liveBadge)
        label.set_color(activeZoneBadge, color.new(activeStatusColor, 0))
        label.set_textcolor(activeZoneBadge, f_text_on(activeStatusColor))

    if not na(activeQmLine)
        line.set_x2(activeQmLine, activeRightEdge)
        line.set_color(id = activeQmLine, color = activeStatusColor)

    if not na(activeInvalidLine)
        line.set_x2(activeInvalidLine, activeRightEdge)

    if not na(activeStatusLabel)
        statusLabelY = activeSide == 1 ? activeZoneTop + atrValue * 0.45 : activeZoneBottom - atrValue * 0.45
        label.set_x(activeStatusLabel, bar_index + labelRightOffset)
        label.set_y(activeStatusLabel, statusLabelY)
        label.set_text(activeStatusLabel, statusShort + " | " + scoreShort)
        label.set_color(activeStatusLabel, color.new(activeStatusColor, 0))
        label.set_textcolor(activeStatusLabel, f_text_on(activeStatusColor))

// -------------------------------------------------
// Zone-badge de-collision (last bar): when two zone badges sit close in both
// x and y, push the lower one down so the centered badges never overlap.
// -------------------------------------------------
if barstate.islast and array.size(qmZoneBadges) > 1 and not na(atrValue)
    int bn = array.size(qmZoneBadges)
    array<label> bl = array.new_label()
    array<int>   bx = array.new_int()
    array<float> bys = array.new_float()
    for bi = 0 to bn - 1
        lb = array.get(qmZoneBadges, bi)
        array.push(bl, lb)
        array.push(bx, label.get_x(lb))
        array.push(bys, label.get_y(lb))
    // sort the copy by y ascending (parallel bx + bl); original array order is preserved for trimming
    for a = 0 to bn - 2
        int minI = a
        for b = a + 1 to bn - 1
            if array.get(bys, b) < array.get(bys, minI)
                minI := b
        if minI != a
            float tY = array.get(bys, a)
            array.set(bys, a, array.get(bys, minI))
            array.set(bys, minI, tY)
            int tX = array.get(bx, a)
            array.set(bx, a, array.get(bx, minI))
            array.set(bx, minI, tX)
            label tL = array.get(bl, a)
            array.set(bl, a, array.get(bl, minI))
            array.set(bl, minI, tL)
    // push apart only badges that are close in both x and y
    float gapY = math.max(atrValue * 0.9, syminfo.mintick * 20.0)
    int xThresh = int(zoneForwardBars * 0.7)
    for a = 1 to bn - 1
        float prevY = array.get(bys, a - 1)
        float curY = array.get(bys, a)
        int prevX = array.get(bx, a - 1)
        int curX = array.get(bx, a)
        if math.abs(curX - prevX) <= xThresh and curY - prevY < gapY
            float newY = prevY + gapY
            array.set(bys, a, newY)
            label.set_y(array.get(bl, a), newY)

// -------------------------------------------------
// Reaction Rate proof (stop-aware, confirmed-bar gated, resolve-then-open)
// Of past accepted QM zones, how many confirmed a reaction away from the zone
// before price reached the head-based invalidation level?
// -------------------------------------------------
if barstate.isconfirmed
    if qmPending
        bool proofWin = qmPendingSide == 1 ? close > qmPendingTarget : close < qmPendingTarget
        bool proofLoss = qmPendingSide == 1 ? low <= qmPendingStop : high >= qmPendingStop
        bool proofTimeout = not na(qmPendingStartBar) and (bar_index - qmPendingStartBar) > zoneForwardBars
        if proofWin
            qmWins += 1
            qmTotal += 1
            qmPending := false
        else if proofLoss
            qmTotal += 1
            qmPending := false
        else if proofTimeout
            qmPending := false
    if detectedPattern
        qmPending := true
        qmPendingSide := detectedSide
        qmPendingTarget := detectedSide == 1 ? detectedZoneTop + atrValue * reactionConfirmAtr : detectedZoneBottom - atrValue * reactionConfirmAtr
        qmPendingStop := detectedInvalidation
        qmPendingStartBar := bar_index

float qmRate = qmTotal > 0 ? qmWins / qmTotal * 100.0 : na
int   qmRateR = na(qmRate) ? 0 : int(math.round(qmRate))
bool  qmBuilding = qmTotal < 6
color qmRateColor = qmBuilding ? f_panel_value() : qmRateR >= 55 ? bullColor : qmRateR >= 40 ? neutralColor : bearColor
string qmRateText = qmBuilding ? "Building (" + str.tostring(qmTotal) + ")" : str.tostring(qmRateR) + "%  (" + str.tostring(qmTotal) + ")"

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table qmPanel = na

if not showPanel and not na(qmPanel)
    table.delete(qmPanel)
    qmPanel := na

if showPanel and barstate.islast
    if na(qmPanel)
        qmPanel := table.new(f_panel_pos(panelPositionInput), 2, 6, bgcolor = f_panel_bg(), border_color = f_panel_border(), border_width = 1, frame_color = f_panel_border(), frame_width = 1)
    table.set_position(qmPanel, f_panel_pos(panelPositionInput))
    table.clear(qmPanel, 0, 0, 1, 5)
    table.merge_cells(qmPanel, 0, 0, 1, 0)

    sideText = f_side_text(activeSide)
    qualityText = f_quality_text(activeScore)
    scoreText = activeSide == 0 or na(activeScore) ? "--" : str.tostring(math.round(activeScore)) + " / 100"
    sideColor = activeSide == 1 ? bullColor : activeSide == -1 ? bearColor : f_panel_value()
    scoreColor = f_score_color(activeScore)
    statusColor = activeInvalidated ? neutralColor : activeReaction ? sideColor : activeTouched ? accentColor : f_panel_value()

    table.cell(qmPanel, 0, 0, "AG Pro Quasimodo Reversal Zones", text_color = headerText, bgcolor = headerBg, text_size = panelTextSize, text_halign = text.align_center)
    table.cell(qmPanel, 0, 1, "Pattern Side", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelTextSize, text_halign = text.align_left)
    table.cell(qmPanel, 1, 1, sideText, text_color = sideColor, bgcolor = f_panel_bg(), text_size = panelTextSize, text_halign = text.align_right)
    table.cell(qmPanel, 0, 2, "Structure Quality", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelTextSize, text_halign = text.align_left)
    table.cell(qmPanel, 1, 2, qualityText, text_color = scoreColor, bgcolor = f_panel_bg(), text_size = panelTextSize, text_halign = text.align_right)
    table.cell(qmPanel, 0, 3, "Zone Status", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelTextSize, text_halign = text.align_left)
    table.cell(qmPanel, 1, 3, activeStatus, text_color = statusColor, bgcolor = f_panel_bg(), text_size = panelTextSize, text_halign = text.align_right)
    table.cell(qmPanel, 0, 4, "Reaction Rate", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelTextSize, text_halign = text.align_left)
    table.cell(qmPanel, 1, 4, qmRateText, text_color = qmRateColor, bgcolor = f_panel_bg(), text_size = panelTextSize, text_halign = text.align_right)
    table.cell(qmPanel, 0, 5, "Score", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelTextSize, text_halign = text.align_left)
    table.cell(qmPanel, 1, 5, scoreText, text_color = scoreColor, bgcolor = f_panel_bg(), text_size = panelTextSize, text_halign = text.align_right)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(newBullishPattern, "Bullish Quasimodo Sequence", "A bullish Quasimodo sequence was confirmed on {{ticker}}.")
alertcondition(newBearishPattern, "Bearish Quasimodo Sequence", "A bearish Quasimodo sequence was confirmed on {{ticker}}.")
alertcondition(reactionTouchEvent, "QM Reaction Zone Touched", "Price has reached the latest Quasimodo reaction zone on {{ticker}}.")
alertcondition(reactionConfirmEvent, "QM Reaction Confirmed", "The latest Quasimodo reaction zone has confirmed directional response on {{ticker}}.")
alertcondition(invalidationEvent, "QM Pattern Invalidated", "The latest Quasimodo pattern has reached its invalidation threshold on {{ticker}}.")
````

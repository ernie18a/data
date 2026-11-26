# Break-Retest Quality [AGPro Series]

- url: https://www.tradingview.com/script/fdUvmBI6-Break-Retest-Quality-AGPro-Series/
- type: indicator
- pine_id: PUB;89da5120410c486490a2054622594148
- version: 4.0

## Description

Break-Retest Quality [AGPro Series]

🎯 OVERVIEW

Break-Retest Quality is a precision-focused structure toolkit that detects pivot-based breaks of structure (BOS) and grades the first retest of the broken level using a transparent, multi-factor quality score. Instead of only drawing a break line and leaving you to guess whether the retest "looked clean", the script quantifies the retest with a 0-100 score and an A / B / C / F letter grade so you can quickly separate high-conviction pullbacks from low-quality ones. It is a discretionary context tool built for price action traders, SMC / ICT practitioners and anyone who builds setups around break-and-retest logic.

The system is fully automated, non-repainting after confirmation, and works on any symbol and timeframe that TradingView supports.


📐 UNIQUE EDGE — WHAT MAKES IT DIFFERENT

Most break-of-structure indicators stop at drawing a line and an arrow. Break-Retest Quality goes further:

🔹 Every retest is scored on six independent factors and translated into an A / B / C / F grade
🔹 The acceptance zone is an ATR-scaled rectangle that changes color and state as the setup evolves (live WATCH → graded RETEST)
🔹 A "Min Grade To Display" filter keeps weak retests off the chart, so the visual footprint stays clean
🔹 A right-edge WATCH tag pins the currently active level so you never lose track of the live setup
🔹 A compact two-line retest marker shows grade, score and a short outcome tag in a minimal footprint
🔹 Built-in cooldown and single-retest-per-break logic prevent label clutter on choppy price action

This is not a repackaged BOS indicator — it is a quality filter on top of BOS / retest logic.


🧪 METHODOLOGY

1. STRUCTURE DETECTION
Pivot highs and lows are detected with a user-defined Pivot Length. A break is registered when price clears the most recent pivot by at least Min Break ATR Filter × ATR, either on a close (default) or on a wick.

2. RETEST TRACKING
After a confirmed break, the script opens an acceptance zone of ± Retest Tolerance ATR × ATR around the broken level and watches for the first price revisit within Max Bars For Retest.

3. QUALITY SCORING (0-100)
The first retest is graded on six weighted factors:

🔸 Reclaim (25 pts) — how decisively the close reclaims the correct side of the level
🔸 Rejection (20 pts) — wick / body composition on the retest bar
🔸 Depth (20 pts) — how close the extreme of the retest bar lands to the level (no excessive overshoot)
🔸 Speed (15 pts) — how quickly the retest prints after the break
🔸 Volatility (10 pts) — bar range discipline relative to ATR
🔸 Volume (10 pts, optional) — relative volume vs 20-bar SMA

Final score → Grade: A ≥ 80, B ≥ 65, C ≥ 50, F < 50.

4. CONFIRMATION LOGIC
A retest is marked "confirmed" only if the score meets the Min Grade For Confirmation threshold AND the close lands on the correct side of the broken level.


🔔 SIGNALS & ALERTS

Three TradingView alert conditions are exposed:

🔹 Structure Break Detected — fires the moment a valid break is registered
🔹 First Retest Detected — fires on the first qualifying revisit inside the acceptance zone
🔹 High-Quality Retest Confirmed — fires only when the graded retest meets the confirmation threshold


⚙️ KEY INPUTS

STRUCTURE
• Pivot Length, Use Close Confirmation, Min Break ATR Filter, ATR Length

RETEST
• Max Bars For Retest, Retest Tolerance ATR, Cooldown Bars After Completed Setup, Resolved Zone Extension

SCORING
• Show Numeric Score / Grade, Use Volume Confirmation, Min Grade For Confirmation, Min Grade To Display

VISUALS
• Show Break Line / Labels / Retest Marker / Retest Zone / Watch Zone Text / Resolved Zone Text / Active Level Glow / Right-Edge Watch Tag / Invalidation Line / Outcome Text, Use Grade Colors, Zone Forward Extension, Label Size

PANEL
• Show Panel, Panel Position, Panel Font Size, Show Last Result Row

RUNTIME
• Keep Last Setups (controls how many historical setups stay on the chart)


🧭 HOW TO USE

1. Add Break-Retest Quality to any chart and timeframe. Adjust Pivot Length to match the structure you care about (lower on intraday, higher on swing).
2. Wait for a BRK▲ or BRK▼ label to print — this confirms a structure break.
3. Observe the live acceptance zone and the right-edge WATCH tag. These mark the level and the remaining retest window.
4. When price returns to the zone, read the two-line retest marker: grade + score on the top line, short outcome tag (Strong / Valid / Weak / Failed) on the bottom line.
5. Use the panel to monitor live state, active level, remaining window and the last completed result with its full outcome description.
6. Combine with your own confluences — higher-timeframe bias, liquidity levels, session context, volume profile — before acting on any signal.


⚠️ LIMITATIONS & TRANSPARENCY

🔹 This is an analytical and educational tool, not a strategy. It does not generate buy / sell orders and does not measure historical performance.
🔹 Grades describe the geometric and relative-volume quality of the retest bar at the moment it prints. They are not predictions of future price movement.
🔹 Scores calculated at bar close are final; intra-bar readings can shift until the bar closes.
🔹 The volume factor depends on exchange-supplied volume data. Turn it off on instruments where volume is unreliable or missing.
🔹 Pivot-based structure is sensitive to the Pivot Length setting. Choose it deliberately for the timeframe and symbol you are analyzing.


📢 RISK DISCLOSURE

Trading involves substantial risk and is not suitable for every investor. Past price behavior is not indicative of future results. This indicator is provided for educational and analytical purposes only and does not constitute financial advice, investment advice, or a solicitation to trade any instrument. Always perform your own research and risk management before acting on any signal.

## Source Code

````pine
// -------------------------------------------------
// Break-Retest Quality [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.13
//
// Pivot-based break of structure and first-retest quality planner for
// TradingView. The script maps broken pivot levels, watches the first retest,
// grades the reaction with a transparent multi-factor score, and presents the
// result with clean zones, labels, right-edge tags, and an AG Pro panel.
// -------------------------------------------------

//@version=6
indicator("Break-Retest Quality [AGPro Series]",
     shorttitle = "AG Pro BRQ",
     overlay = true,
     max_labels_count = 120,
     max_lines_count = 80,
     max_boxes_count = 30)

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
groupStructure = "Structure"
pivotLength = input.int(5, "Pivot Length", minval = 2, maxval = 20, group = groupStructure, tooltip = "Number of bars used on each side of a pivot. Higher values create stronger but slower structure levels.")
useCloseConfirmation = input.bool(true, "Use Close Confirmation", group = groupStructure, tooltip = "When enabled, structure breaks must close beyond the pivot level. When disabled, wick breaks can qualify.")
minBreakAtrFilter = input.float(0.10, "Minimum Break ATR Filter", minval = 0.0, maxval = 2.0, step = 0.05, group = groupStructure, tooltip = "Minimum break distance beyond the pivot, expressed as an ATR multiple.")
atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupStructure, tooltip = "ATR length used for break filters, retest zones, scoring, and label offsets.")

groupRetest = "Retest"
maxBarsForRetest = input.int(10, "Max Bars For Retest", minval = 1, maxval = 60, group = groupRetest, tooltip = "Maximum bars allowed after a break for the first retest to appear.")
retestToleranceAtr = input.float(0.20, "Retest Tolerance ATR", minval = 0.05, maxval = 2.0, step = 0.05, group = groupRetest, tooltip = "Half-height of the retest acceptance zone around the broken level.")
retestCooldownBars = input.int(15, "Cooldown Bars After Setup", minval = 0, maxval = 300, group = groupRetest, tooltip = "Bars to wait after a resolved or expired setup before looking for a new break.")
zoneForwardBars = input.int(6, "Zone Forward Extension", minval = 1, maxval = 80, group = groupRetest, tooltip = "Forward extension of active and resolved retest zones.")

groupScoring = "Scoring"
showNumericScore = input.bool(true, "Show Numeric Score", group = groupScoring, tooltip = "Shows the 0-100 retest quality score on retest labels.")
showGrade = input.bool(true, "Show Grade", group = groupScoring, tooltip = "Shows the A / B / C / F grade on retest labels.")
showOutcomeText = input.bool(true, "Show Outcome Text", group = groupScoring, tooltip = "Adds a short quality outcome line to retest labels.")
useVolumeConfirmation = input.bool(false, "Use Volume Confirmation", group = groupScoring, tooltip = "Includes relative volume as a scoring factor. Disabled by default for symbols with unreliable volume data.")
minGradeForConfirm = input.string("B", "Minimum Grade For Confirmation", options = ["A", "B", "C", "F"], group = groupScoring, tooltip = "Minimum grade required for a retest to be treated as confirmed.")
minGradeForDisplay = input.string("B", "Minimum Grade To Display", options = ["A", "B", "C", "F"], group = groupScoring, tooltip = "Retests below this grade are not annotated to keep the chart clean.")
holdProofWindow = input.int(10, "Hold Proof Window", minval = 3, maxval = 60, group = groupScoring, tooltip = "After a confirmed retest, the script waits this many bars (or until the broken level is reclaimed) and checks whether price followed through in the break direction. Feeds the self-measured Hold Rate.")
holdStopBufferAtr = input.float(0.50, "Hold Invalidation Buffer (ATR)", minval = 0.1, maxval = 2.0, step = 0.05, group = groupScoring, tooltip = "ATR distance beyond the broken level that counts as a reclaim. A close past this level means the break-retest failed; otherwise the proof checks for follow-through. Looser values avoid counting normal retest noise as a failure.")

groupVisuals = "Visuals"
showBreakLine = input.bool(true, "Show Break Line", group = groupVisuals, tooltip = "Draws a horizontal line at the broken pivot level.")
showBreakLabels = input.bool(false, "Show Break Labels", group = groupVisuals, tooltip = "Shows compact BRK labels at the structure break bar. Disabled by default so retest-quality labels remain the primary visual focus.")
showRetestMarker = input.bool(true, "Show Retest Marker", group = groupVisuals, tooltip = "Shows a compact retest label with grade and score.")
showRetestZone = input.bool(true, "Show Retest Zone", group = groupVisuals, tooltip = "Draws the first-retest acceptance zone around the broken level.")
showZoneBadges = input.bool(true, "Show Centered Zone Badges", group = groupVisuals, tooltip = "Shows one filled direction-and-state badge centered horizontally and vertically inside every active retest zone.")
showResolvedZoneBadges = input.bool(false, "Keep Resolved Zone Badges", group = groupVisuals, tooltip = "Keeps a result badge inside the zone after a retest resolves. Disabled by default to prevent duplicate retest labels.")
showRightEdgeWatchTag = input.bool(true, "Show Right-Edge Watch Tag", group = groupVisuals, tooltip = "Pins a WATCH tag near the right edge while waiting for the first retest.")
watchTagGapBars = input.int(6, "Watch Tag Gap Bars", minval = 3, maxval = 20, group = groupVisuals, tooltip = "Adds this many clear bars beyond the active zone before placing the live WATCH badge. The gap remains independent of the zone extension setting.")
showInvalidationLine = input.bool(false, "Show Invalidation Line", group = groupVisuals, tooltip = "Draws a dashed reference line at the retest-bar extreme.")
showActiveLevelGlow = input.bool(true, "Show Active Level Glow", group = groupVisuals, tooltip = "Adds a soft glow around the active break level while a retest is pending.")
keepLastSetups = input.int(3, "Keep Last Setups", minval = 2, maxval = 20, group = groupVisuals, tooltip = "Maximum number of historical result badges retained. Three results plus the active zone and WATCH badge target a balanced five-badge chart story.")
labelOffsetAtr = input.float(0.62, "Label Offset ATR", minval = 0.05, maxval = 3.0, step = 0.05, group = groupVisuals, tooltip = "ATR-based offset used to keep labels away from candle bodies.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisuals, tooltip = "Font size for chart labels, watch tags, and centered zone badges.")

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = "Shows or hides the AG Pro information panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = "Controls where the panel appears on the chart.")
panelThemeInput = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = groupPanel, tooltip = "Controls the panel theme while preserving the AGPro blue header.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel, tooltip = "Font size inside the information panel.")
showPanelLastResult = input.bool(true, "Show Last Result Row", group = groupPanel, tooltip = "Shows the most recent closed retest result as a dedicated panel row.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_text_on(color bg) =>
    float bright = (color.r(bg) * 299.0 + color.g(bg) * 587.0 + color.b(bg) * 114.0) / 1000.0
    bright >= 145.0 ? darkText : headerText

f_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_panel_position(string posText) =>
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

f_panel_bg() =>
    panelThemeInput == "Clean Light" ? color.rgb(248, 250, 252) : panelThemeInput == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_border() =>
    panelThemeInput == "Clean Light" ? color.rgb(203, 213, 225) : panelBorder

f_panel_label() =>
    panelThemeInput == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value() =>
    panelThemeInput == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(int row) =>
    if panelThemeInput == "Clean Light"
        row % 2 == 0 ? color.rgb(241, 245, 249) : color.rgb(226, 232, 240)
    else
        row % 2 == 0 ? color.rgb(20, 31, 52) : f_panel_bg()

f_panel_cell(table panelRef, int col, int row, string txt, color txtColor, color bgColor, string alignInput) =>
    table.cell(panelRef, col, row, txt, text_color = txtColor, bgcolor = bgColor, text_size = f_size(panelFontSizeInput), text_halign = alignInput == "left" ? text.align_left : alignInput == "right" ? text.align_right : text.align_center)

f_grade_threshold(string gradeText) =>
    gradeText == "A" ? 80 : gradeText == "B" ? 65 : gradeText == "C" ? 50 : 0

f_grade_from_score(int score) =>
    score >= 80 ? "A" : score >= 65 ? "B" : score >= 50 ? "C" : "F"

f_outcome_tag(int score) =>
    score >= 80 ? "Strong" : score >= 65 ? "Valid" : score >= 50 ? "Weak" : "Failed"

f_quality_color(string gradeText) =>
    gradeText == "A" ? bullColor : gradeText == "B" ? color.rgb(74, 213, 180) : gradeText == "C" ? neutralColor : bearColor

f_side_text(int dir) =>
    dir == 1 ? "Bullish" : dir == -1 ? "Bearish" : "Neutral"

f_state_text(int dir) =>
    dir == 1 ? "Watch Bull Retest" : dir == -1 ? "Watch Bear Retest" : "Scanning"

f_price(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_compact_label_text(string grade, int score) =>
    string line1 = showGrade and showNumericScore ? grade + " " + str.tostring(score) : showGrade ? grade : showNumericScore ? str.tostring(score) : "RT"
    line1 + (showOutcomeText ? " | " + f_outcome_tag(score) : "")

f_badge_x(int leftX, int rightX) =>
    int(math.round(leftX + math.max(rightX - leftX, 1) * 0.50))

f_trim_lines(array<line> lines, int maxKeep) =>
    while array.size(lines) > maxKeep
        line oldLine = array.shift(lines)
        if not na(oldLine)
            line.delete(oldLine)

f_trim_labels(array<label> labels, int maxKeep) =>
    while array.size(labels) > maxKeep
        label oldLabel = array.shift(labels)
        if not na(oldLabel)
            label.delete(oldLabel)

f_trim_boxes(array<box> boxes, int maxKeep) =>
    while array.size(boxes) > maxKeep
        box oldBox = array.shift(boxes)
        if not na(oldBox)
            box.delete(oldBox)

f_reclaim_score(int dir, float closePrice, float level, float atrRef) =>
    atrSafe = math.max(atrRef, syminfo.mintick)
    raw = dir == 1 ? (closePrice - level) / (atrSafe * 0.60) : (level - closePrice) / (atrSafe * 0.60)
    int(math.round(f_clamp(raw, 0.0, 1.0) * 25.0))

f_rejection_score(int dir, float openPrice, float highPrice, float lowPrice, float closePrice) =>
    candleRange = math.max(highPrice - lowPrice, syminfo.mintick)
    lowerWick = math.max(math.min(openPrice, closePrice) - lowPrice, 0.0)
    upperWick = math.max(highPrice - math.max(openPrice, closePrice), 0.0)
    body = math.abs(closePrice - openPrice)
    wickPart = dir == 1 ? lowerWick / candleRange : upperWick / candleRange
    bodyBonus = dir == 1 ? (closePrice > openPrice ? 0.20 : 0.0) : (closePrice < openPrice ? 0.20 : 0.0)
    raw = wickPart + bodyBonus + body / candleRange * 0.20
    int(math.round(f_clamp(raw / 1.20, 0.0, 1.0) * 20.0))

f_depth_score(int dir, float level, float extremePrice, float atrRef) =>
    atrSafe = math.max(atrRef, syminfo.mintick)
    overshoot = dir == 1 ? math.max(level - extremePrice, 0.0) : math.max(extremePrice - level, 0.0)
    raw = 1.0 - overshoot / (atrSafe * 0.80)
    int(math.round(f_clamp(raw, 0.0, 1.0) * 20.0))

f_speed_score(int barsSinceBreak, int maxBars) =>
    maxBarsSafe = math.max(maxBars, 1)
    raw = 1.0 - (barsSinceBreak - 1.0) / math.max(maxBarsSafe - 1.0, 1.0)
    int(math.round(f_clamp(raw, 0.0, 1.0) * 15.0))

f_volatility_score(float highPrice, float lowPrice, float atrRef) =>
    atrSafe = math.max(atrRef, syminfo.mintick)
    barRange = highPrice - lowPrice
    raw = 1.0 - math.max(barRange - atrSafe, 0.0) / (atrSafe * 2.0)
    int(math.round(f_clamp(raw, 0.0, 1.0) * 10.0))

f_volume_score(bool useVolumeFactor) =>
    if not useVolumeFactor
        10
    else
        volBase = math.max(ta.sma(volume, 20), 1.0)
        raw = volume / volBase
        int(math.round(f_clamp(raw / 1.50, 0.0, 1.0) * 10.0))

f_total_score(int dir, float level, float atrRef, int barsSinceBreak) =>
    reclaimPart = f_reclaim_score(dir, close, level, atrRef)
    rejectionPart = f_rejection_score(dir, open, high, low, close)
    depthPart = f_depth_score(dir, level, dir == 1 ? low : high, atrRef)
    speedPart = f_speed_score(barsSinceBreak, maxBarsForRetest)
    volatilityPart = f_volatility_score(high, low, atrRef)
    volumePart = f_volume_score(useVolumeConfirmation)
    reclaimPart + rejectionPart + depthPart + speedPart + volatilityPart + volumePart

// -------------------------------------------------
// Core Series
// -------------------------------------------------
atrValue = ta.atr(atrLength)
atrSafe = math.max(nz(atrValue, ta.tr(true)), syminfo.mintick)
minBreakDistance = atrSafe * minBreakAtrFilter
labelSize = f_size(labelSizeInput)
confirmThreshold = f_grade_threshold(minGradeForConfirm)
displayThreshold = f_grade_threshold(minGradeForDisplay)
fontClearance = labelSizeInput == "Huge" ? 0.70 : labelSizeInput == "Large" ? 0.52 : labelSizeInput == "Normal" ? 0.38 : labelSizeInput == "Small" ? 0.28 : 0.22
breakLabelOffset = math.max(atrSafe * (labelOffsetAtr + fontClearance), syminfo.mintick * 20)
retestLabelOffset = math.max(atrSafe * (labelOffsetAtr + fontClearance + 0.10), syminfo.mintick * 24)
watchLaneGap = atrSafe * (labelSizeInput == "Huge" ? 1.10 : labelSizeInput == "Large" ? 0.90 : labelSizeInput == "Normal" ? 0.72 : labelSizeInput == "Small" ? 0.58 : 0.48)

pivotHigh = ta.pivothigh(high, pivotLength, pivotLength)
pivotLow = ta.pivotlow(low, pivotLength, pivotLength)

var float lastPivotHigh = na
var float lastPivotLow = na
var int lastPivotHighBar = na
var int lastPivotLowBar = na

if not na(pivotHigh)
    lastPivotHigh := pivotHigh
    lastPivotHighBar := bar_index - pivotLength

if not na(pivotLow)
    lastPivotLow := pivotLow
    lastPivotLowBar := bar_index - pivotLength

// -------------------------------------------------
// Storage
// -------------------------------------------------
var array<line> invalidationLines = array.new_line()
var array<label> signalLabels = array.new_label()
var array<label> zoneBadges = array.new_label()
var array<box> zoneBoxes = array.new_box()

var int activeDirection = 0
var float activeLevel = na
var float activeAtrAtBreak = na
var int activeBreakBar = na
var int activePivotBar = na
var bool activeRetestSeen = false
var float activeInvalidation = na
var box activeZoneBox = na
var label activeZoneBadge = na
var line activeGlowOuter = na
var line activeGlowInner = na
var line activeBreakLine = na
var label activeWatchLabel = na
var line activeWatchGuide = na

var int lastUsedBullPivotBar = na
var int lastUsedBearPivotBar = na
var int nextEligibleBreakBar = 0

var string lastResultGrade = "-"
var int lastResultScore = na
var string lastResultOutcome = "No closed retest"
var string lastResultSide = "-"

// Hold Rate proof state (stop-aware directional follow-through)
var int hrHits = 0
var int hrTotal = 0
var bool hrPending = false
var int hrStart = na
var int hrDir = 0
var float hrEntry = na
var float hrInval = na

breakAlert = false
retestAlert = false
confirmAlert = false

// -------------------------------------------------
// Break Detection
// -------------------------------------------------
canLookForNewBreak = activeDirection == 0 and bar_index >= nextEligibleBreakBar
bullBreakNow = canLookForNewBreak and not na(lastPivotHigh) and not na(lastPivotHighBar) and (na(lastUsedBullPivotBar) or lastPivotHighBar != lastUsedBullPivotBar) and bar_index > lastPivotHighBar and ((useCloseConfirmation and close > lastPivotHigh + minBreakDistance) or (not useCloseConfirmation and high > lastPivotHigh + minBreakDistance))
bearBreakNow = canLookForNewBreak and not na(lastPivotLow) and not na(lastPivotLowBar) and (na(lastUsedBearPivotBar) or lastPivotLowBar != lastUsedBearPivotBar) and bar_index > lastPivotLowBar and ((useCloseConfirmation and close < lastPivotLow - minBreakDistance) or (not useCloseConfirmation and low < lastPivotLow - minBreakDistance))

if bullBreakNow or bearBreakNow
    activeDirection := bullBreakNow ? 1 : -1
    activeLevel := bullBreakNow ? lastPivotHigh : lastPivotLow
    activeAtrAtBreak := atrSafe
    activeBreakBar := bar_index
    activePivotBar := bullBreakNow ? lastPivotHighBar : lastPivotLowBar
    activeRetestSeen := false
    activeInvalidation := activeDirection == 1 ? activeLevel - activeAtrAtBreak * retestToleranceAtr : activeLevel + activeAtrAtBreak * retestToleranceAtr
    if activeDirection == 1
        lastUsedBullPivotBar := lastPivotHighBar
    else
        lastUsedBearPivotBar := lastPivotLowBar
    breakAlert := true

    color sideColor = activeDirection == 1 ? bullColor : bearColor
    if showBreakLine
        if not na(activeBreakLine)
            line.delete(activeBreakLine)
        activeBreakLine := line.new(activePivotBar, activeLevel, bar_index + zoneForwardBars, activeLevel, xloc = xloc.bar_index, extend = extend.none, color = color.new(sideColor, 8), width = 2)

    if showBreakLabels
        string breakText = activeDirection == 1 ? "BRK\nUP" : "BRK\nDOWN"
        float breakY = activeDirection == 1 ? high + breakLabelOffset : low - breakLabelOffset
        label newBreakLabel = label.new(bar_index, breakY, breakText, xloc = xloc.bar_index, yloc = yloc.price, style = activeDirection == 1 ? label.style_label_down : label.style_label_up, textcolor = f_text_on(sideColor), color = color.new(sideColor, 0), size = labelSize, textalign = text.align_center)
        array.push(signalLabels, newBreakLabel)
        f_trim_labels(signalLabels, keepLastSetups)

    if showRetestZone
        float zoneHalfHeight = activeAtrAtBreak * retestToleranceAtr
        activeZoneBox := box.new(left = bar_index, top = activeLevel + zoneHalfHeight, right = bar_index + zoneForwardBars, bottom = activeLevel - zoneHalfHeight, xloc = xloc.bar_index, border_color = color.new(sideColor, 30), bgcolor = color.new(sideColor, 88), border_width = 1)
        array.push(zoneBoxes, activeZoneBox)
        f_trim_boxes(zoneBoxes, keepLastSetups)
        if showZoneBadges
            activeZoneBadge := label.new(f_badge_x(bar_index, bar_index + zoneForwardBars), activeLevel, activeDirection == 1 ? "BULL RT | WATCH" : "BEAR RT | WATCH", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = f_text_on(sideColor), color = color.new(sideColor, 0), size = labelSize, textalign = text.align_center)
            array.push(zoneBadges, activeZoneBadge)
            f_trim_labels(zoneBadges, keepLastSetups)

    if showActiveLevelGlow
        activeGlowOuter := line.new(activePivotBar, activeLevel, bar_index + zoneForwardBars, activeLevel, xloc = xloc.bar_index, extend = extend.none, color = color.new(sideColor, 90), width = 6)
        activeGlowInner := line.new(activePivotBar, activeLevel, bar_index + zoneForwardBars, activeLevel, xloc = xloc.bar_index, extend = extend.none, color = color.new(sideColor, 74), width = 3)

// -------------------------------------------------
// Active Watch Tag
// -------------------------------------------------
if showRightEdgeWatchTag and activeDirection != 0 and not na(activeLevel)
    color watchColor = activeDirection == 1 ? bullColor : bearColor
    float watchY = activeDirection == 1 ? activeLevel + watchLaneGap : activeLevel - watchLaneGap
    string watchText = activeDirection == 1 ? "WATCH BULL RT" : "WATCH BEAR RT"
    int guideStartX = bar_index + zoneForwardBars
    int watchX = guideStartX + watchTagGapBars
    if na(activeWatchLabel)
        activeWatchLabel := label.new(watchX, watchY, watchText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = f_text_on(watchColor), color = color.new(watchColor, 0), size = labelSize)
    else
        label.set_x(activeWatchLabel, watchX)
        label.set_y(activeWatchLabel, watchY)
        label.set_text(activeWatchLabel, watchText)
        label.set_color(activeWatchLabel, color.new(watchColor, 0))
        label.set_textcolor(activeWatchLabel, f_text_on(watchColor))
        label.set_size(activeWatchLabel, labelSize)
    if na(activeWatchGuide)
        activeWatchGuide := line.new(guideStartX, activeLevel, watchX, watchY, xloc = xloc.bar_index, extend = extend.none, color = color.new(watchColor, 10), width = 2)
    else
        line.set_xy1(activeWatchGuide, guideStartX, activeLevel)
        line.set_xy2(activeWatchGuide, watchX, watchY)
        line.set_color(activeWatchGuide, color.new(watchColor, 10))
else
    if not na(activeWatchLabel)
        label.delete(activeWatchLabel)
        activeWatchLabel := na
    if not na(activeWatchGuide)
        line.delete(activeWatchGuide)
        activeWatchGuide := na

// -------------------------------------------------
// Retest Detection
// -------------------------------------------------
if activeDirection != 0
    int barsSinceBreak = bar_index - activeBreakBar
    float retestBand = math.max(activeAtrAtBreak * retestToleranceAtr, syminfo.mintick)

    if not na(activeBreakLine)
        line.set_xy2(activeBreakLine, bar_index + zoneForwardBars, activeLevel)
    if not na(activeGlowOuter)
        line.set_xy2(activeGlowOuter, bar_index + zoneForwardBars, activeLevel)
    if not na(activeGlowInner)
        line.set_xy2(activeGlowInner, bar_index + zoneForwardBars, activeLevel)

    if showRetestZone and not na(activeZoneBox)
        box.set_right(activeZoneBox, bar_index + zoneForwardBars)
        if showZoneBadges and not na(activeZoneBadge)
            label.set_x(activeZoneBadge, f_badge_x(activeBreakBar, bar_index + zoneForwardBars))
            label.set_y(activeZoneBadge, activeLevel)

    bool bullRetestNow = activeDirection == 1 and barsSinceBreak > 0 and barsSinceBreak <= maxBarsForRetest and low <= activeLevel + retestBand and high >= activeLevel - retestBand
    bool bearRetestNow = activeDirection == -1 and barsSinceBreak > 0 and barsSinceBreak <= maxBarsForRetest and high >= activeLevel - retestBand and low <= activeLevel + retestBand
    bool retestNow = not activeRetestSeen and (bullRetestNow or bearRetestNow)

    if retestNow
        activeRetestSeen := true
        retestAlert := true
        int score = f_total_score(activeDirection, activeLevel, activeAtrAtBreak, barsSinceBreak)
        string grade = f_grade_from_score(score)
        bool accepted = score >= confirmThreshold and ((activeDirection == 1 and close >= activeLevel) or (activeDirection == -1 and close <= activeLevel))
        bool shouldDisplay = score >= displayThreshold
        confirmAlert := accepted

        lastResultGrade := grade
        lastResultScore := score
        lastResultOutcome := f_outcome_tag(score)
        lastResultSide := f_side_text(activeDirection)
        activeInvalidation := activeDirection == 1 ? low : high

        color gradeColor = f_quality_color(grade)
        color finalColor = accepted ? gradeColor : panelLabelCol

        if showInvalidationLine and shouldDisplay
            line newInvalidationLine = line.new(bar_index, activeInvalidation, bar_index + zoneForwardBars, activeInvalidation, xloc = xloc.bar_index, extend = extend.none, color = color.new(neutralColor, 8), style = line.style_dashed, width = 1)
            array.push(invalidationLines, newInvalidationLine)
            f_trim_lines(invalidationLines, keepLastSetups)
            label invalidationBadge = label.new(bar_index + zoneForwardBars, activeInvalidation, "INVALID " + f_price(activeInvalidation), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = f_text_on(bearColor), color = color.new(bearColor, 0), size = labelSize)
            array.push(signalLabels, invalidationBadge)
            f_trim_labels(signalLabels, keepLastSetups)

        if showRetestZone and not na(activeZoneBox)
            box.set_border_color(activeZoneBox, color.new(finalColor, 30))
            box.set_bgcolor(activeZoneBox, color.new(finalColor, 86))
            box.set_right(activeZoneBox, bar_index + zoneForwardBars)

        if showZoneBadges and not na(activeZoneBadge)
            if showResolvedZoneBadges
                string zoneText = (accepted ? grade + " RETEST" : "RT " + grade) + " | " + f_outcome_tag(score)
                label.set_x(activeZoneBadge, f_badge_x(activeBreakBar, bar_index + zoneForwardBars))
                label.set_y(activeZoneBadge, activeLevel)
                label.set_text(activeZoneBadge, zoneText)
                label.set_color(activeZoneBadge, color.new(finalColor, 0))
                label.set_textcolor(activeZoneBadge, f_text_on(finalColor))
                label.set_size(activeZoneBadge, labelSize)
            else
                label.delete(activeZoneBadge)
                activeZoneBadge := na

        if showRetestZone and not na(activeZoneBox) and not (showZoneBadges and showResolvedZoneBadges)
            box.delete(activeZoneBox)
            activeZoneBox := na

        if showRetestMarker and shouldDisplay
            string labelText = f_compact_label_text(grade, score)
            float retestY = activeDirection == 1 ? low - retestLabelOffset : high + retestLabelOffset
            label newRetestLabel = label.new(bar_index, retestY, labelText, xloc = xloc.bar_index, yloc = yloc.price, style = activeDirection == 1 ? label.style_label_up : label.style_label_down, textcolor = f_text_on(finalColor), color = color.new(finalColor, 4), size = labelSize, textalign = text.align_center)
            array.push(signalLabels, newRetestLabel)
            f_trim_labels(signalLabels, keepLastSetups)

        if not na(activeGlowOuter)
            line.delete(activeGlowOuter)
            activeGlowOuter := na
        if not na(activeGlowInner)
            line.delete(activeGlowInner)
            activeGlowInner := na
        if not na(activeWatchLabel)
            label.delete(activeWatchLabel)
            activeWatchLabel := na
        if not na(activeWatchGuide)
            line.delete(activeWatchGuide)
            activeWatchGuide := na
        if not na(activeBreakLine)
            line.delete(activeBreakLine)
            activeBreakLine := na

        if accepted and barstate.isconfirmed and not hrPending
            hrPending := true
            hrStart := bar_index
            hrDir := activeDirection
            hrEntry := close
            hrInval := activeDirection == 1 ? activeLevel - activeAtrAtBreak * holdStopBufferAtr : activeLevel + activeAtrAtBreak * holdStopBufferAtr

        nextEligibleBreakBar := bar_index + retestCooldownBars
        activeDirection := 0
        activeLevel := na
        activeAtrAtBreak := na
        activeBreakBar := na
        activePivotBar := na
        activeRetestSeen := false
        activeInvalidation := na
        activeZoneBox := na
        activeZoneBadge := na

    if barsSinceBreak > maxBarsForRetest and not activeRetestSeen
        bool keepExpiredZone = showZoneBadges and showResolvedZoneBadges
        if showRetestZone and not na(activeZoneBox) and keepExpiredZone
            box.set_border_color(activeZoneBox, color.new(panelBorder, 60))
            box.set_bgcolor(activeZoneBox, color.new(panelBorder, 90))
            box.set_right(activeZoneBox, bar_index)
        if showZoneBadges and not na(activeZoneBadge) and keepExpiredZone
            label.set_text(activeZoneBadge, "RT | EXPIRED")
            label.set_color(activeZoneBadge, color.new(panelBorder, 0))
        if not keepExpiredZone
            if not na(activeZoneBadge)
                label.delete(activeZoneBadge)
                activeZoneBadge := na
            if not na(activeZoneBox)
                box.delete(activeZoneBox)
                activeZoneBox := na

        if not na(activeGlowOuter)
            line.delete(activeGlowOuter)
            activeGlowOuter := na
        if not na(activeGlowInner)
            line.delete(activeGlowInner)
            activeGlowInner := na
        if not na(activeWatchLabel)
            label.delete(activeWatchLabel)
            activeWatchLabel := na
        if not na(activeWatchGuide)
            line.delete(activeWatchGuide)
            activeWatchGuide := na
        if not na(activeBreakLine)
            line.delete(activeBreakLine)
            activeBreakLine := na

        nextEligibleBreakBar := bar_index + retestCooldownBars
        activeDirection := 0
        activeLevel := na
        activeAtrAtBreak := na
        activeBreakBar := na
        activePivotBar := na
        activeRetestSeen := false
        activeInvalidation := na
        activeZoneBox := na
        activeZoneBadge := na

// -------------------------------------------------
// Hold Rate Resolution (Proof Pass)
// -------------------------------------------------
// A confirmed retest is armed with the break direction and a reclaim level set
// one buffer beyond the broken pivot. It resolves as a miss if price closes back
// through that reclaim level first, otherwise as a hit when price has followed
// through in the break direction after the proof window. Timeouts are not losses.
if barstate.isconfirmed and hrPending and not na(hrStart) and bar_index > hrStart
    bool hrStop = hrDir == 1 ? close < hrInval : close > hrInval
    if hrStop
        hrTotal += 1
        hrPending := false
    else if bar_index - hrStart >= holdProofWindow
        bool hrFollowed = hrDir == 1 ? close > hrEntry : close < hrEntry
        hrTotal += 1
        if hrFollowed
            hrHits += 1
        hrPending := false

float hrRate = hrTotal > 0 ? hrHits / hrTotal * 100.0 : na
string holdRateText = hrTotal > 0 ? str.tostring(int(math.round(hrRate))) + "% (" + str.tostring(hrHits) + "/" + str.tostring(hrTotal) + ")" : "Building"
color holdRateColor = hrTotal == 0 ? neutralColor : hrRate >= 60.0 ? bullColor : hrRate >= 45.0 ? neutralColor : bearColor

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table infoPanel = table.new(f_panel_position(panelPositionInput), 2, 8, bgcolor = f_panel_bg(), frame_color = f_panel_border(), frame_width = 1, border_color = f_panel_border(), border_width = 1)

if barstate.islast
    table.set_position(infoPanel, f_panel_position(panelPositionInput))
    table.clear(infoPanel, 0, 0, 1, 7)
    if showPanel
        string currentLevelText = activeDirection != 0 and not na(activeLevel) ? f_price(activeLevel) : "-"
        string currentWindowText = activeDirection != 0 and not na(activeBreakBar) ? str.tostring(math.max(maxBarsForRetest - (bar_index - activeBreakBar), 0)) + " bars" : "Ready"
        string watchLevelsText = na(lastPivotHigh) and na(lastPivotLow) ? "Forming" : (na(lastPivotHigh) ? "Lo " + f_price(lastPivotLow) : na(lastPivotLow) ? "Hi " + f_price(lastPivotHigh) : "Hi " + f_price(lastPivotHigh) + " | Lo " + f_price(lastPivotLow))
        string lastResultText = lastResultGrade == "-" or na(lastResultScore) ? lastResultOutcome : lastResultSide + " | " + lastResultGrade + " " + str.tostring(lastResultScore) + " | " + lastResultOutcome
        string filterText = (useCloseConfirmation ? "Close" : "Wick") + " | Vol " + (useVolumeConfirmation ? "On" : "Off")
        color stateColor = activeDirection == 1 ? bullColor : activeDirection == -1 ? bearColor : accentColor

        table.merge_cells(infoPanel, 0, 0, 1, 0)
        f_panel_cell(infoPanel, 0, 0, "AG Pro Break-Retest Quality", headerText, headerBg, "center")
        f_panel_cell(infoPanel, 0, 1, "State", f_panel_label(), f_row_bg(1), "left")
        f_panel_cell(infoPanel, 1, 1, f_state_text(activeDirection), stateColor, f_row_bg(1), "right")
        f_panel_cell(infoPanel, 0, 2, "Active Level", f_panel_label(), f_row_bg(2), "left")
        f_panel_cell(infoPanel, 1, 2, currentLevelText, f_panel_value(), f_row_bg(2), "right")
        f_panel_cell(infoPanel, 0, 3, "Watch Levels", f_panel_label(), f_row_bg(3), "left")
        f_panel_cell(infoPanel, 1, 3, watchLevelsText, f_panel_value(), f_row_bg(3), "right")
        f_panel_cell(infoPanel, 0, 4, "Retest Window", f_panel_label(), f_row_bg(4), "left")
        f_panel_cell(infoPanel, 1, 4, currentWindowText, f_panel_value(), f_row_bg(4), "right")
        f_panel_cell(infoPanel, 0, 5, "Filters", f_panel_label(), f_row_bg(5), "left")
        f_panel_cell(infoPanel, 1, 5, filterText, f_panel_value(), f_row_bg(5), "right")
        f_panel_cell(infoPanel, 0, 6, "Hold Rate", f_panel_label(), f_row_bg(6), "left")
        f_panel_cell(infoPanel, 1, 6, holdRateText, holdRateColor, f_row_bg(6), "right")
        if showPanelLastResult
            f_panel_cell(infoPanel, 0, 7, "Last Result", f_panel_label(), f_row_bg(7), "left")
            f_panel_cell(infoPanel, 1, 7, lastResultText, f_panel_value(), f_row_bg(7), "right")

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(breakAlert, "Structure Break Detected", "Break-Retest Quality: structure break detected.")
alertcondition(retestAlert, "First Retest Detected", "Break-Retest Quality: first retest detected.")
alertcondition(confirmAlert, "High-Quality Retest Confirmed", "Break-Retest Quality: high-quality retest confirmed.")
````

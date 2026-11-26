# Cup and Handle Quality [AGPro Series]

- url: https://www.tradingview.com/script/Kg8nENSG-Cup-and-Handle-Quality-AGPro-Series/
- type: indicator
- pine_id: PUB;bc1d12fcc67740b7b5eeff09fafdbabf
- version: 2.0

## Description

Cup and Handle Quality [AGPro Series]

🧩 OVERVIEW

Cup and Handle Quality [AGPro Series] is a visual pattern-quality overlay for one of the most recognized continuation structures in technical analysis: the cup and handle.

The script is designed to map the full pattern lifecycle instead of only marking a breakout candle. It studies the left cup rim, the cup base, the right rim recovery, the controlled handle pullback, the breakout behavior, and the measured projection context. The goal is to make cup and handle structures easier to recognize, compare, and explain directly on the chart.

The final visual output is intentionally clear. The detected cup and handle candle ranges are framed with subtle boxes, while thick curved outlines make the formation readable at a glance. The rim line, target line, DEPTH arrow, and MOVE arrow help users understand how the structure is measured, not just where the label appears.

✅ WHAT MAKES IT DIFFERENT

Most public cup and handle tools focus on one of two things: either they draw a simple breakout marker, or they scan aggressively and leave the chart crowded with low-context shapes. Cup and Handle Quality [AGPro Series] takes a narrower approach.

It combines three layers:

- Structure recognition: left rim, cup base, right rim, and handle low
- Quality scoring: cup symmetry, handle depth, and breakout quality
- Visual education: cup box, handle box, thick pattern outline, rim line, target line, and measurement arrows

This makes the script more than a pattern detector. It is also a visual explanation tool. The chart shows where the cup was detected, where the handle formed, how deep the cup is, and where the measured projection line comes from.

🧭 WHY THIS DOES NOT OVERLAP WITH OTHER AGPRO TOOLS

This script has its own lane inside the AGPro Series.

It is not a flag scanner, wedge detector, triangle breakout module, inside-bar breakout tool, Donchian breakout validator, double-top detector, head-and-shoulders detector, generic support-resistance map, or supply-demand zone script.

Its lane is specifically:

Cup rim recovery -> controlled handle depth -> breakout participation -> measured projection line.

The script focuses on the complete cup and handle lifecycle. It does not try to replace broader breakout engines, market-structure tools, support-resistance tools, liquidity tools, or trend dashboards. The defining feature is the combination of a recognizable cup-and-handle drawing with a quality panel that grades the actual pattern components.

⚙️ METHODOLOGY

The engine builds the pattern from pivot structure. A qualified setup begins with a left rim, moves into a cup low, recovers into a right rim, and then forms a handle pullback after the right rim.

The quality model evaluates:

1. Cup Symmetry
The script compares the two rim areas and measures how balanced the cup is over time. A cleaner return from the cup base into the right rim area produces a stronger symmetry reading.

2. Handle Depth
The handle is measured as a percentage of cup depth. A useful handle should create structure without pulling so deeply that the cup profile loses strength. The input range allows the user to control how strict or flexible the handle requirement should be.

3. Breakout Quality
Breakout quality is calculated from candle behavior and participation context. The script checks distance beyond the rim, candle body efficiency, close location, and relative volume against a configurable baseline.

4. Final Score
The final score combines the structure score and breakout behavior into a compact quality reading. Developing setups can be shown before breakout confirmation, while confirmed breakouts require the breakout quality gate.

📊 PANEL

The AGPro panel displays the main quality dimensions in a compact format:

- Cup Symmetry
- Handle Depth
- Breakout Quality
- Score

The first row follows the AGPro standard with a merged blue title row. Panel location, panel theme, panel font size, and label font size are adjustable from settings.

🎛️ KEY INPUTS

- Pivot Span controls structural sensitivity.
- Minimum Cup Bars defines the shortest accepted cup duration.
- Maximum Cup Bars defines the longest accepted cup duration.
- Maximum Rim Variance % controls how closely the left and right rims must align.
- Minimum Cup Depth ATR filters shallow structures.
- Minimum Handle Depth % filters handles that are too shallow.
- Maximum Handle Depth % filters handles that are too deep.
- Breakout Volume Baseline controls the relative volume comparison.
- Minimum Setup Score controls developing setup visibility.
- Minimum Breakout Quality controls confirmed breakout strictness.
- Minimum Pattern Score controls the final quality gate.
- Show Developing Setup controls pre-breakout visualization.
- Show Cup Path controls the curved cup drawing and cup candle box.
- Show Handle Box controls the detected handle range.
- Show Target Line controls the measured projection line.
- Show Measurement Arrows controls the DEPTH and MOVE explanation arrows.
- Pattern Stroke Width controls the thickness of the cup and handle outlines.
- Target Projection Bars controls how far the measured target line extends.

🔍 HOW TO READ IT

Start with the rim line. This is the reference level the structure must recover into and eventually move beyond.

Then read the cup. The subtle cup box marks the detected candle range, while the thick curved outline helps the formation read visually as a cup instead of a simple V-shaped swing.

Next read the handle. The handle box marks the controlled pullback area after the right rim. The curved handle outline makes the handle easier to recognize without turning it into a generic rectangle pattern.

The DEPTH arrow shows the measured cup depth. The MOVE arrow transfers that depth upward from the rim area. The TARGET line shows the forward measured projection level.

The panel summarizes the same structure numerically. Stronger Cup Symmetry, disciplined Handle Depth, and stronger Breakout Quality combine into the final Score.

🧩 BEST USE CASES

Cup and Handle Quality is best used on liquid symbols and timeframes where swing structure has enough room to develop. It is especially useful for users who want a clean visual map of a classic continuation pattern without filling the chart with unrelated pattern families.

The default settings are tuned for active discovery. Users who want fewer patterns can raise pivot sensitivity or score thresholds. Users who want a more reactive view can lower the score thresholds, while still using the chart visuals to review pattern quality.

🧠 VISUAL DESIGN PHILOSOPHY

The design philosophy is simple: make the pattern understandable without making the chart noisy.

The cup and handle are drawn with thick curved lines because this pattern is visual by nature. Newer users should be able to see the shape immediately. At the same time, the candle boxes keep the drawing grounded in the actual detected structure.

The target is shown as a line rather than a large zone, keeping the projection clean. The DEPTH and MOVE arrows explain the measurement logic without turning the indicator into a crowded education panel. Labels are compact, and the panel is restrained so the chart remains the main focus.

🔔 ALERTS

The script includes an alert condition for confirmed cup and handle breakouts.

Alert name:
Cup and Handle Quality Breakout

Alert message:
Cup and Handle Quality [AGPro Series]: high-quality cup and handle breakout confirmed on {{ticker}} at {{close}}.

Alerts are tied to confirmed breakout logic, which means the structure, breakout quality, and pattern score must pass the configured gates.

🔹 LIMITATIONS AND TRANSPARENCY

Cup and handle structures are pattern-based and depend on pivot interpretation. Different sensitivity settings can produce different structures on the same chart.

Very noisy markets, illiquid symbols, extreme gaps, and unusually compressed price action can reduce pattern readability. Lower thresholds may produce more setups, but visual review remains important when using any chart-pattern tool.

The thick cup and handle lines are designed as visual guides. The subtle candle boxes identify the detected structure ranges, while the curved outlines make the pattern easier to understand on the chart.

✅ IDEAL USER

This script is built for traders and analysts who want a clean, visual, and structured way to study cup and handle formations.

It is especially useful for:

- Users who want classic chart patterns with a modern quality layer
- Price-action traders who care about structure, handle depth, and breakout behavior
- Chart reviewers who want a clear visual explanation of the setup
- Newer users who benefit from seeing the cup, handle, depth, move, and target drawn directly on the chart
- AGPro users who want a focused cup-and-handle tool that does not overlap with broader breakout or market-structure scripts

## Source Code

````pine
// -------------------------------------------------
// Cup and Handle Quality [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.0
//
// Cup and Handle Quality detects high-quality cup and handle continuation
// patterns by grading cup rim symmetry, handle depth, breakout quality,
// and measured projection context. The script focuses on clean cup rim
// recovery, controlled handle retracement, breakout participation, and a
// premium chart overlay with restrained labels and forward target lines.
// A cumulative Target Proof engine measures, on this chart and timeframe,
// how often the drawn measured-move target was actually reached before the
// handle low gave way, and a clear next-action line turns the pattern map
// into a decision tool.
// -------------------------------------------------

//@version=6
indicator("Cup and Handle Quality [AGPro Series]",
     shorttitle = "AG Pro CHQ",
     overlay = true,
     max_lines_count = 70,
     max_boxes_count = 30,
     max_labels_count = 40)

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
cupArrowColor  = color.rgb(167, 139, 250)
moveArrowColor = color.rgb(45, 212, 191)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
const string GROUP_DETECTION = "Detection"
const string GROUP_QUALITY   = "Quality Gates"
const string GROUP_VISUAL    = "Visuals"
const string GROUP_PANEL     = "Panel"

const string TT_PIVOT = "Pivot sensitivity used to build the four-point cup and handle structure. Higher values produce fewer but cleaner patterns."
const string TT_MIN_CUP = "Minimum number of bars between the left rim and right rim. This prevents tiny structures from being treated as full cup formations."
const string TT_MAX_CUP = "Maximum number of bars between the left rim and right rim. This keeps the engine focused on recent, readable structures."
const string TT_MIN_HANDLE = "Minimum number of bars from the right rim to the handle low. This avoids one-bar pullbacks being treated as handles."
const string TT_MAX_RIM = "Maximum allowed difference between the two rim highs as a percentage of cup depth. Lower values require cleaner rim alignment."
const string TT_MIN_DEPTH = "Minimum cup depth measured in ATR units. This filters shallow price noise before any visual object is drawn."
const string TT_HANDLE_MIN = "Minimum handle retracement as a percentage of cup depth. A handle that is too shallow often lacks structure."
const string TT_HANDLE_MAX = "Maximum handle retracement as a percentage of cup depth. A handle that is too deep weakens the cup and handle profile."
const string TT_VOL_LEN = "Lookback used to compare breakout volume against recent participation."
const string TT_MIN_SETUP = "Minimum cup-and-handle setup score required to show the developing rim, handle, and projection visuals before breakout confirmation."
const string TT_MIN_BREAK = "Minimum breakout quality score required before the pattern can print on the chart."
const string TT_MIN_SCORE = "Minimum final quality score required before the pattern can print on the chart."
const string TT_TARGET_WINDOW = "Maximum number of bars a Target Proof episode may stay open after a confirmed breakout. If neither the measured target nor the handle-low invalidation is reached inside this window, the episode counts as a miss."
const string TT_SHOW_SETUP = "Show the latest qualified developing cup-and-handle setup before breakout confirmation. This prevents the chart from looking empty while still requiring a quality gate."
const string TT_SHOW_CUP = "Show the cup outline and cup candle box so the structure reads visually as a full cup instead of a simple V-shaped swing."
const string TT_SHOW_RIM = "Show the cup rim line for qualified developing setups and confirmed breakouts."
const string TT_SHOW_HANDLE = "Show the handle box for qualified developing setups and confirmed breakouts."
const string TT_SHOW_TARGET = "Show the forward measured projection target line for qualified developing setups and confirmed breakouts."
const string TT_SHOW_LABEL = "Show a compact setup or breakout label when a qualified pattern is available."
const string TT_SHOW_TAGS = "Show compact CUP and HANDLE tags directly on the pattern. The tags are designed to clarify the structure without adding signal noise."
const string TT_SHOW_MEASURE = "Show educational vertical arrows for cup depth and measured projection. This helps newer users understand how the target line is derived."
const string TT_STROKE = "Controls the thickness of the hand-drawn cup and handle outline. Higher values make the pattern read more like a visual drawing on the chart."
const string TT_PROJECTION = "Number of bars used to project the measured target line forward from the breakout candle."
const string TT_TARGET_WIDTH = "Line thickness used for the measured projection target."
const string TT_LABEL_OFFSET = "ATR-based vertical offset used to keep breakout labels clear of candle bodies."
const string TT_PANEL = "Show or hide the compact quality panel."
const string TT_PANEL_LOCATION = "Location of the AGPro quality panel."
const string TT_PANEL_THEME = "Panel color theme. The dark theme uses the AGPro publication palette; the light theme improves readability on bright charts."
const string TT_PANEL_SIZE = "Font size used in the AGPro quality panel. Default is Normal for publication readability."
const string TT_LABEL_SIZE = "Font size used by breakout labels. Default is Normal for clean TradingView thumbnails."

pivotLen          = input.int(3, "Pivot Span", minval = 2, maxval = 20, group = GROUP_DETECTION, tooltip = TT_PIVOT)
minCupBars        = input.int(8, "Minimum Cup Bars", minval = 6, maxval = 300, group = GROUP_DETECTION, tooltip = TT_MIN_CUP)
maxCupBars        = input.int(280, "Maximum Cup Bars", minval = 40, maxval = 700, group = GROUP_DETECTION, tooltip = TT_MAX_CUP)
minHandleBars     = input.int(2, "Minimum Handle Bars", minval = 1, maxval = 40, group = GROUP_DETECTION, tooltip = TT_MIN_HANDLE)
maxRimVariancePct = input.float(78.0, "Maximum Rim Variance %", minval = 5.0, maxval = 140.0, step = 0.5, group = GROUP_QUALITY, tooltip = TT_MAX_RIM)
minCupDepthAtr    = input.float(0.25, "Minimum Cup Depth ATR", minval = 0.1, maxval = 8.0, step = 0.05, group = GROUP_QUALITY, tooltip = TT_MIN_DEPTH)
handleMinPct      = input.float(1.5, "Minimum Handle Depth %", minval = 0.5, maxval = 40.0, step = 0.5, group = GROUP_QUALITY, tooltip = TT_HANDLE_MIN)
handleMaxPct      = input.float(98.0, "Maximum Handle Depth %", minval = 15.0, maxval = 100.0, step = 0.5, group = GROUP_QUALITY, tooltip = TT_HANDLE_MAX)
volumeLen         = input.int(50, "Breakout Volume Baseline", minval = 10, maxval = 200, group = GROUP_QUALITY, tooltip = TT_VOL_LEN)
minSetupScore     = input.float(28.0, "Minimum Setup Score", minval = 1.0, maxval = 100.0, step = 1.0, group = GROUP_QUALITY, tooltip = TT_MIN_SETUP)
minBreakoutScore  = input.float(16.0, "Minimum Breakout Quality", minval = 1.0, maxval = 100.0, step = 1.0, group = GROUP_QUALITY, tooltip = TT_MIN_BREAK)
minPatternScore   = input.float(36.0, "Minimum Pattern Score", minval = 1.0, maxval = 100.0, step = 1.0, group = GROUP_QUALITY, tooltip = TT_MIN_SCORE)
targetWindow      = input.int(100, "Target Resolution Window", minval = 10, maxval = 500, group = GROUP_QUALITY, tooltip = TT_TARGET_WINDOW)

showDevelopingSetup = input.bool(true, "Show Developing Setup", group = GROUP_VISUAL, tooltip = TT_SHOW_SETUP)
showCupPath      = input.bool(true, "Show Cup Path", group = GROUP_VISUAL, tooltip = TT_SHOW_CUP)
showRimLine       = input.bool(true, "Show Rim Line", group = GROUP_VISUAL, tooltip = TT_SHOW_RIM)
showHandleBox     = input.bool(true, "Show Handle Box", group = GROUP_VISUAL, tooltip = TT_SHOW_HANDLE)
showTargetZone    = input.bool(true, "Show Target Line", group = GROUP_VISUAL, tooltip = TT_SHOW_TARGET)
showBreakoutLabel = input.bool(true, "Show Breakout Label", group = GROUP_VISUAL, tooltip = TT_SHOW_LABEL)
showStructureTags = input.bool(true, "Show Cup/Handle Tags", group = GROUP_VISUAL, tooltip = TT_SHOW_TAGS)
showMeasureArrows = input.bool(true, "Show Measurement Arrows", group = GROUP_VISUAL, tooltip = TT_SHOW_MEASURE)
patternStrokeWidth = input.int(5, "Pattern Stroke Width", minval = 2, maxval = 6, group = GROUP_VISUAL, tooltip = TT_STROKE)
projectionBars    = input.int(64, "Target Projection Bars", minval = 10, maxval = 160, group = GROUP_VISUAL, tooltip = TT_PROJECTION)
targetLineWidth   = input.int(5, "Target Line Width", minval = 2, maxval = 6, group = GROUP_VISUAL, tooltip = TT_TARGET_WIDTH)
labelOffsetAtr    = input.float(0.65, "Label Offset ATR", minval = 0.05, maxval = 2.0, step = 0.05, group = GROUP_VISUAL, tooltip = TT_LABEL_OFFSET)

showPanel         = input.bool(true, "Show Panel", group = GROUP_PANEL, tooltip = TT_PANEL)
panelLocation     = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GROUP_PANEL, tooltip = TT_PANEL_LOCATION)
panelTheme        = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = GROUP_PANEL, tooltip = TT_PANEL_THEME)
panelFontInput    = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = GROUP_PANEL, tooltip = TT_PANEL_SIZE)
labelFontInput    = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = GROUP_PANEL, tooltip = TT_LABEL_SIZE)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_position(string locationInput) =>
    switch locationInput
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_score_color(float score) =>
    color result = panelValueCol
    if na(score)
        result := panelLabelCol
    else if score >= 80.0
        result := bullColor
    else if score >= 65.0
        result := neutralColor
    else
        result := bearColor
    result

f_fmt_score(float score) =>
    string result = "Waiting"
    if not na(score)
        result := str.tostring(math.round(score))
    result

f_fmt_pct(float value) =>
    string result = "Waiting"
    if not na(value)
        result := str.tostring(value, "#.0") + "%"
    result

// Target Proof display helpers. Color follows the same rounded rate
// shown in the panel text, and is applied only once the sample is
// sufficient (n >= 5, cup and handle patterns are rare events); below
// that the value stays neutral so a small sample never implies
// confidence.
f_thText(int _w, int _n) =>
    _n > 0 ? str.tostring(math.round(100.0 * _w / _n)) + "%  (n=" + str.tostring(_n) + ")" : "-  (n=0)"

f_thColor(int _w, int _n, color _fb) =>
    _r = _n > 0 ? math.round(100.0 * _w / _n) : 0
    _n >= 5 ? (_r >= 55 ? bullColor : _r >= 40 ? neutralColor : bearColor) : _fb

// -------------------------------------------------
// Pivot Stream
// -------------------------------------------------
var array<int> pivotBars = array.new_int()
var array<float> pivotPrices = array.new_float()
var array<string> pivotKinds = array.new_string()

f_store_pivot(string pivotKind, float pivotPrice, int pivotBar) =>
    int pivotCount = array.size(pivotKinds)
    if pivotCount > 0 and array.get(pivotKinds, pivotCount - 1) == pivotKind
        float lastPivotPrice = array.get(pivotPrices, pivotCount - 1)
        bool shouldReplace = pivotKind == "H" ? pivotPrice >= lastPivotPrice : pivotPrice <= lastPivotPrice
        if shouldReplace
            array.set(pivotBars, pivotCount - 1, pivotBar)
            array.set(pivotPrices, pivotCount - 1, pivotPrice)
    else
        array.push(pivotKinds, pivotKind)
        array.push(pivotBars, pivotBar)
        array.push(pivotPrices, pivotPrice)
        if array.size(pivotKinds) > 50
            array.shift(pivotKinds)
            array.shift(pivotBars)
            array.shift(pivotPrices)
    true

pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)

if not na(pivotHigh)
    f_store_pivot("H", pivotHigh, bar_index - pivotLen)

if not na(pivotLow)
    f_store_pivot("L", pivotLow, bar_index - pivotLen)

// -------------------------------------------------
// Quality Engine
// -------------------------------------------------
atr = ta.atr(14)
volumeAverage = ta.sma(volume, volumeLen)
barRange = math.max(high - low, syminfo.mintick)
bodyEfficiency = math.abs(close - open) / barRange
closeLocation = (close - low) / barRange
volumeRatio = volumeAverage > 0 ? nz(volume, volumeAverage) / volumeAverage : 1.0

float cupSymmetryScore = na
float setupScore = na
float handleDepthPct = na
float handleQualityScore = na
float breakoutQualityScore = na
float patternScore = na
float candidateBreakoutLevel = na
float candidateCupDepth = na
float candidateHandleLow = na
int candidateRightRimBar = na
int candidateHandleLowBar = na
int candidateStartIndex = na
string candidateKey = ""
bool candidateValid = false
bool confirmedBreakout = false

int pivotCount = array.size(pivotKinds)
if pivotCount >= 3
    for scan = 0 to 47
        if not candidateValid
            int patternStart = na
            bool useDevelopingHandle = false
            int confirmedIndex = pivotCount - 4 - scan
            if confirmedIndex >= 0
                bool isCupHandleSequence = array.get(pivotKinds, confirmedIndex) == "H" and array.get(pivotKinds, confirmedIndex + 1) == "L" and array.get(pivotKinds, confirmedIndex + 2) == "H" and array.get(pivotKinds, confirmedIndex + 3) == "L"
                if isCupHandleSequence
                    patternStart := confirmedIndex

            if na(patternStart)
                int developingIndex = pivotCount - 3 - scan
                if developingIndex >= 0
                    bool isDevelopingSequence = array.get(pivotKinds, developingIndex) == "H" and array.get(pivotKinds, developingIndex + 1) == "L" and array.get(pivotKinds, developingIndex + 2) == "H"
                    if isDevelopingSequence
                        patternStart := developingIndex
                        useDevelopingHandle := true

            if not na(patternStart)
                int leftRimBar = array.get(pivotBars, patternStart)
                int cupBottomBar = array.get(pivotBars, patternStart + 1)
                int rightRimBar = array.get(pivotBars, patternStart + 2)
                float leftRimPrice = array.get(pivotPrices, patternStart)
                float cupBottomPrice = array.get(pivotPrices, patternStart + 1)
                float rightRimPrice = array.get(pivotPrices, patternStart + 2)
                int handleLowBar = na
                float handleLowPrice = na

                if useDevelopingHandle
                    handleLowBar := bar_index
                    handleLowPrice := low
                    int handleLookback = math.min(math.max(bar_index - rightRimBar, 0), 180)
                    for handleScan = 0 to 180
                        if handleScan <= handleLookback and not na(low[handleScan]) and low[handleScan] <= handleLowPrice
                            handleLowPrice := low[handleScan]
                            handleLowBar := bar_index - handleScan
                else
                    handleLowBar := array.get(pivotBars, patternStart + 3)
                    handleLowPrice := array.get(pivotPrices, patternStart + 3)

                float rimAverage = (leftRimPrice + rightRimPrice) * 0.5
                float breakoutLevel = math.max(leftRimPrice, rightRimPrice)
                float cupDepth = rimAverage - cupBottomPrice
                int cupBars = rightRimBar - leftRimBar
                int leftCupBars = cupBottomBar - leftRimBar
                int rightCupBars = rightRimBar - cupBottomBar
                int handleBars = handleLowBar - rightRimBar
                float rimVarianceRatio = cupDepth > 0 ? math.abs(leftRimPrice - rightRimPrice) / cupDepth : na
                float handleDepthRatio = cupDepth > 0 ? (breakoutLevel - handleLowPrice) / cupDepth : na

                bool orderedStructure = leftRimBar < cupBottomBar and cupBottomBar < rightRimBar and rightRimBar < handleLowBar
                bool cupSizeOk = cupBars >= minCupBars and cupBars <= maxCupBars
                bool depthOk = cupDepth > atr * minCupDepthAtr
                bool rimOk = not na(rimVarianceRatio) and rimVarianceRatio <= maxRimVariancePct * 0.01
                bool handleBarsOk = handleBars >= minHandleBars and handleBars <= math.max(minHandleBars, int(math.round(cupBars * 1.65)))
                bool handleDepthOk = not na(handleDepthRatio) and handleDepthRatio >= handleMinPct * 0.01 and handleDepthRatio <= handleMaxPct * 0.01
                bool handleAboveBottom = handleLowPrice > cupBottomPrice + cupDepth * 0.01

                if orderedStructure and cupSizeOk and depthOk and rimOk and handleBarsOk and handleDepthOk and handleAboveBottom
                    float rimScore = 100.0 * (1.0 - f_clamp(rimVarianceRatio / (maxRimVariancePct * 0.01), 0.0, 1.0))
                    float timeBalanceRatio = math.min(leftCupBars, rightCupBars) / math.max(leftCupBars, rightCupBars)
                    float timeScore = 100.0 * f_clamp(timeBalanceRatio, 0.0, 1.0)
                    float handleDepthCenter = (handleMinPct + handleMaxPct) * 0.005
                    float handleDepthWidth = math.max((handleMaxPct - handleMinPct) * 0.005, 0.01)
                    float handleDepthScore = 100.0 * (1.0 - f_clamp(math.abs(handleDepthRatio - handleDepthCenter) / handleDepthWidth, 0.0, 1.0))
                    float handleTimeScore = 100.0 * (1.0 - f_clamp(handleBars / math.max(cupBars * 1.65, 1.0), 0.0, 1.0))
                    float breakoutDistanceScore = 100.0 * f_clamp((close - breakoutLevel) / math.max(atr, syminfo.mintick), 0.0, 1.0)
                    float volumeScore = 100.0 * f_clamp((volumeRatio - 0.80) / 0.90, 0.0, 1.0)
                    float bodyScore = 100.0 * f_clamp(bodyEfficiency * 1.25, 0.0, 1.0)
                    float closeScore = 100.0 * f_clamp(closeLocation, 0.0, 1.0)

                    cupSymmetryScore := rimScore * 0.50 + timeScore * 0.50
                    handleDepthPct := handleDepthRatio * 100.0
                    handleQualityScore := handleDepthScore * 0.66 + handleTimeScore * 0.34
                    setupScore := cupSymmetryScore * 0.55 + handleQualityScore * 0.45
                    breakoutQualityScore := breakoutDistanceScore * 0.35 + volumeScore * 0.25 + bodyScore * 0.20 + closeScore * 0.20
                    patternScore := cupSymmetryScore * 0.33 + handleQualityScore * 0.27 + breakoutQualityScore * 0.40
                    candidateBreakoutLevel := breakoutLevel
                    candidateCupDepth := cupDepth
                    candidateHandleLow := handleLowPrice
                    candidateRightRimBar := rightRimBar
                    candidateHandleLowBar := handleLowBar
                    candidateStartIndex := patternStart
                    candidateKey := str.tostring(leftRimBar) + "-" + str.tostring(cupBottomBar) + "-" + str.tostring(rightRimBar) + "-" + str.tostring(handleLowBar)
                    candidateValid := true

// -------------------------------------------------
// Confirmed Pattern Drawing
// -------------------------------------------------
var string lastPatternKey = ""
var line rimLine = na
var array<line> cupPathLines = array.new_line()
var array<line> handlePathLines = array.new_line()
var box cupBox = na
var box handleBox = na
var line targetLine = na
var line cupDepthArrow = na
var line projectionArrow = na
var label breakoutLabel = na
var label cupTagLabel = na
var label handleTagLabel = na
var label targetTagLabel = na
var label depthTagLabel = na
var label moveTagLabel = na
var float displayCupSymmetryScore = na
var float displayHandleDepthPct = na
var float displayBreakoutQualityScore = na
var float displayPanelScore = na

int breakoutLagLimit = math.max(pivotLen * 6, minHandleBars + pivotLen + 12)
bool breakoutFresh = candidateValid and not na(candidateHandleLowBar) and bar_index - candidateHandleLowBar <= breakoutLagLimit
bool breakoutCross = candidateValid and close > candidateBreakoutLevel and breakoutFresh
confirmedBreakout := breakoutCross and breakoutQualityScore >= minBreakoutScore and patternScore >= minPatternScore and candidateKey != lastPatternKey
bool setupQualified = candidateValid and setupScore >= minSetupScore
bool drawDevelopingSetup = showDevelopingSetup and barstate.islast and setupQualified
bool drawPattern = (confirmedBreakout or drawDevelopingSetup) and not na(candidateStartIndex)

if drawPattern
    bool isBreakoutDraw = confirmedBreakout
    int leftRimBarDraw = array.get(pivotBars, candidateStartIndex)
    int rightRimBarDraw = array.get(pivotBars, candidateStartIndex + 2)
    float leftRimPriceDraw = array.get(pivotPrices, candidateStartIndex)
    float detectedCupBottom = array.get(pivotPrices, candidateStartIndex + 1)
    float rightRimPriceDraw = array.get(pivotPrices, candidateStartIndex + 2)
    float labelY = math.max(high, candidateBreakoutLevel) + atr * labelOffsetAtr
    color activeRimColor = isBreakoutDraw ? color.new(accentColor, 0) : color.new(accentColor, 10)
    color activeGuideColor = isBreakoutDraw ? color.new(accentColor, 0) : color.new(accentColor, 12)
    color activeCupBorder = isBreakoutDraw ? color.new(accentColor, 34) : color.new(accentColor, 46)
    color activeCupBg = isBreakoutDraw ? color.new(accentColor, 94) : color.new(accentColor, 96)
    color activeHandleLineColor = isBreakoutDraw ? color.new(neutralColor, 0) : color.new(neutralColor, 10)
    color activeHandleBorder = isBreakoutDraw ? color.new(neutralColor, 18) : color.new(neutralColor, 30)
    color activeHandleBg = isBreakoutDraw ? color.new(neutralColor, 91) : color.new(neutralColor, 94)
    color activeTargetLineColor = isBreakoutDraw ? color.new(bullColor, 8) : color.new(bullColor, 18)
    color activeLabelColor = isBreakoutDraw ? color.new(bullColor, 6) : color.new(accentColor, 6)
    string activeLabelText = isBreakoutDraw ? "C&H BREAK\n" + str.tostring(math.round(patternScore)) : "C&H SETUP\n" + str.tostring(math.round(setupScore))
    int activeLineWidth = patternStrokeWidth
    float handleDepthDraw = math.max(candidateBreakoutLevel - candidateHandleLow, syminfo.mintick)
    int rawCupBarWidth = math.max(rightRimBarDraw - leftRimBarDraw, 1)
    int visualCupBarWidth = math.max(rawCupBarWidth, 24)
    int cupLeftBarDraw = rightRimBarDraw - visualCupBarWidth
    int cupRightBarDraw = rightRimBarDraw
    int cupCenterBarDraw = int(math.round((cupLeftBarDraw + cupRightBarDraw) * 0.5))
    float cupRimDraw = candidateBreakoutLevel
    float cupBottomDraw = cupRimDraw - math.max(candidateCupDepth, atr * 1.25)
    float cupBoxTopDraw = math.max(leftRimPriceDraw, rightRimPriceDraw)
    float cupBoxBottomDraw = detectedCupBottom
    float targetPrice = cupRimDraw + candidateCupDepth
    int handleEndBar = math.min(bar_index, candidateHandleLowBar + math.max(4, int(math.round(visualCupBarWidth * 0.24))))
    handleEndBar := math.max(handleEndBar, candidateHandleLowBar + 1)
    int visualHandleBarWidth = math.max(handleEndBar - candidateRightRimBar, math.max(16, int(math.round(visualCupBarWidth * 0.34))))
    int handleRightBarDraw = candidateRightRimBar + visualHandleBarWidth
    int targetStartBar = handleRightBarDraw
    float handleTopDraw = cupRimDraw
    float handleBottomDraw = math.min(candidateHandleLow, handleTopDraw - handleDepthDraw * 0.72)
    float handleEndPrice = math.min(handleTopDraw - handleDepthDraw * 0.15, handleBottomDraw + handleDepthDraw * 0.82)
    int handleTagBar = int(math.round((candidateRightRimBar + handleRightBarDraw) * 0.5))
    float handleTagPrice = handleTopDraw + atr * 0.18
    float cupTagPrice = cupBottomDraw - atr * 0.28

    if not na(rimLine)
        line.delete(rimLine)
        rimLine := na
    int cupLineCount = array.size(cupPathLines)
    if cupLineCount > 0
        for lineIndex = 0 to cupLineCount - 1
            line.delete(array.get(cupPathLines, lineIndex))
        array.clear(cupPathLines)
    int handleSegmentCount = array.size(handlePathLines)
    if handleSegmentCount > 0
        for lineIndex = 0 to handleSegmentCount - 1
            line.delete(array.get(handlePathLines, lineIndex))
        array.clear(handlePathLines)
    if not na(handleBox)
        box.delete(handleBox)
        handleBox := na
    if not na(cupBox)
        box.delete(cupBox)
        cupBox := na
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na
    if not na(cupDepthArrow)
        line.delete(cupDepthArrow)
        cupDepthArrow := na
    if not na(projectionArrow)
        line.delete(projectionArrow)
        projectionArrow := na
    if not na(breakoutLabel)
        label.delete(breakoutLabel)
        breakoutLabel := na
    if not na(cupTagLabel)
        label.delete(cupTagLabel)
        cupTagLabel := na
    if not na(handleTagLabel)
        label.delete(handleTagLabel)
        handleTagLabel := na
    if not na(targetTagLabel)
        label.delete(targetTagLabel)
        targetTagLabel := na
    if not na(depthTagLabel)
        label.delete(depthTagLabel)
        depthTagLabel := na
    if not na(moveTagLabel)
        label.delete(moveTagLabel)
        moveTagLabel := na

    if showRimLine
        rimLine := line.new(x1 = cupLeftBarDraw, y1 = candidateBreakoutLevel, x2 = targetStartBar + projectionBars, y2 = candidateBreakoutLevel, xloc = xloc.bar_index, extend = extend.none, color = activeRimColor, width = activeLineWidth)

    if showCupPath
        cupBox := box.new(left = leftRimBarDraw, top = cupBoxTopDraw, right = rightRimBarDraw, bottom = cupBoxBottomDraw, xloc = xloc.bar_index, border_color = activeCupBorder, border_width = 1, bgcolor = activeCupBg)
        for cupSeg = 0 to 23
            float t1 = cupSeg / 24.0
            float t2 = (cupSeg + 1) / 24.0
            int x1 = int(math.round(cupLeftBarDraw + visualCupBarWidth * t1))
            int x2 = int(math.round(cupLeftBarDraw + visualCupBarWidth * t2))
            float curve1 = math.pow(math.abs(2.0 * t1 - 1.0), 2.0)
            float curve2 = math.pow(math.abs(2.0 * t2 - 1.0), 2.0)
            float y1 = cupBottomDraw + (cupRimDraw - cupBottomDraw) * curve1
            float y2 = cupBottomDraw + (cupRimDraw - cupBottomDraw) * curve2
            if x2 > x1
                array.push(cupPathLines, line.new(x1 = x1, y1 = y1, x2 = x2, y2 = y2, xloc = xloc.bar_index, extend = extend.none, color = activeGuideColor, width = activeLineWidth))

    if showHandleBox
        handleBox := box.new(left = candidateRightRimBar, top = handleTopDraw, right = handleRightBarDraw, bottom = handleBottomDraw, xloc = xloc.bar_index, border_color = activeHandleBorder, border_width = 1, bgcolor = activeHandleBg)
        float handleRiseScale = (handleEndPrice - handleBottomDraw) / math.max(handleTopDraw - handleBottomDraw, syminfo.mintick)
        for handleSeg = 0 to 11
            float t1 = handleSeg / 12.0
            float t2 = (handleSeg + 1) / 12.0
            int x1 = int(math.round(candidateRightRimBar + visualHandleBarWidth * t1))
            int x2 = int(math.round(candidateRightRimBar + visualHandleBarWidth * t2))
            float handleCurve1 = na
            float handleCurve2 = na
            if t1 <= 0.50
                handleCurve1 := math.pow(1.0 - t1 * 2.0, 2.0)
            else
                handleCurve1 := math.pow((t1 - 0.50) * 2.0, 0.70) * handleRiseScale
            if t2 <= 0.50
                handleCurve2 := math.pow(1.0 - t2 * 2.0, 2.0)
            else
                handleCurve2 := math.pow((t2 - 0.50) * 2.0, 0.70) * handleRiseScale
            float y1 = handleBottomDraw + (handleTopDraw - handleBottomDraw) * handleCurve1
            float y2 = handleBottomDraw + (handleTopDraw - handleBottomDraw) * handleCurve2
            if x2 > x1
                array.push(handlePathLines, line.new(x1 = x1, y1 = y1, x2 = x2, y2 = y2, xloc = xloc.bar_index, extend = extend.none, color = activeHandleLineColor, width = activeLineWidth))

    if showTargetZone
        targetLine := line.new(x1 = targetStartBar, y1 = targetPrice, x2 = targetStartBar + projectionBars, y2 = targetPrice, xloc = xloc.bar_index, extend = extend.none, color = activeTargetLineColor, width = targetLineWidth)
        targetTagLabel := label.new(x = targetStartBar + 2, y = targetPrice, xloc = xloc.bar_index, text = "TARGET", style = label.style_label_left, color = color.new(bullColor, 12), textcolor = headerText, size = f_size(labelFontInput))

    if showMeasureArrows
        int moveArrowBar = targetStartBar + math.max(3, int(math.round(projectionBars * 0.16)))
        cupDepthArrow := line.new(x1 = cupCenterBarDraw, y1 = cupBottomDraw, x2 = cupCenterBarDraw, y2 = cupRimDraw, xloc = xloc.bar_index, extend = extend.none, color = color.new(cupArrowColor, 6), width = 3, style = line.style_arrow_both)
        projectionArrow := line.new(x1 = moveArrowBar, y1 = cupRimDraw, x2 = moveArrowBar, y2 = targetPrice, xloc = xloc.bar_index, extend = extend.none, color = color.new(moveArrowColor, 6), width = 3, style = line.style_arrow_both)
        depthTagLabel := label.new(x = cupCenterBarDraw + 1, y = (cupBottomDraw + cupRimDraw) * 0.5, xloc = xloc.bar_index, text = "DEPTH", style = label.style_none, color = color.new(cupArrowColor, 100), textcolor = color.new(cupArrowColor, 0), size = f_size(labelFontInput))
        moveTagLabel := label.new(x = moveArrowBar + 1, y = (cupRimDraw + targetPrice) * 0.5, xloc = xloc.bar_index, text = "MOVE", style = label.style_none, color = color.new(moveArrowColor, 100), textcolor = color.new(moveArrowColor, 0), size = f_size(labelFontInput))

    if showBreakoutLabel
        breakoutLabel := label.new(x = bar_index, y = labelY, xloc = xloc.bar_index, text = activeLabelText, style = label.style_label_down, color = activeLabelColor, textcolor = headerText, size = f_size(labelFontInput))

    if showStructureTags
        cupTagLabel := label.new(x = cupCenterBarDraw, y = cupTagPrice, xloc = xloc.bar_index, text = "CUP", style = label.style_label_up, color = color.new(accentColor, 4), textcolor = headerText, size = f_size(labelFontInput))
        handleTagLabel := label.new(x = handleTagBar, y = handleTagPrice, xloc = xloc.bar_index, text = "HANDLE", style = label.style_label_down, color = color.new(neutralColor, 4), textcolor = color.rgb(15, 23, 42), size = f_size(labelFontInput))

    displayCupSymmetryScore := cupSymmetryScore
    displayHandleDepthPct := handleDepthPct
    displayBreakoutQualityScore := breakoutQualityScore
    displayPanelScore := isBreakoutDraw ? patternScore : setupScore

    if isBreakoutDraw
        lastPatternKey := candidateKey

// -------------------------------------------------
// TARGET PROOF ENGINE (cumulative, non-repaint)
// Every confirmed cup and handle breakout opens one tracking episode
// with the breakout close, the drawn measured-move target (rim plus
// cup depth), and the handle-low invalidation frozen at the breakout
// bar. The episode resolves as a HIT when price reaches the frozen
// target, and as a MISS when price closes below the frozen handle low
// first or the window expires without contact. The statistic therefore
// measures exactly the target line the script draws on the chart.
// Episodes open and resolve on confirmed bars only, so the statistic
// never repaints.
// -------------------------------------------------
var bool  thOn = false
var float thTarget = na
var float thInval = na
var int   thStart = na
var int   thWin = 0
var int   thWins = 0
var int   thN = 0

bool thHitEv = false

if thOn and barstate.isconfirmed
    bool thHit = high >= thTarget
    bool thLoss = close < thInval
    bool thTimeout = not na(thStart) and bar_index - thStart >= thWin
    if thHit
        thN += 1
        thWins += 1
        thOn := false
        thHitEv := true
    else if thLoss or thTimeout
        thN += 1
        thOn := false

if confirmedBreakout and barstate.isconfirmed and not na(candidateBreakoutLevel) and not na(candidateCupDepth) and not na(candidateHandleLow) and not na(atr) and atr > 0.0
    if thOn
        thN += 1
        thOn := false
    thOn := true
    thTarget := candidateBreakoutLevel + candidateCupDepth
    thInval := candidateHandleLow - atr * 0.10
    thStart := bar_index
    thWin := targetWindow

// Next-action line, always consistent with the pattern state
string actionTxt = "> scanning - no qualified cup yet"
if thOn
    actionTxt := "> breakout live - watch the target"
else if candidateValid and setupScore >= minSetupScore
    actionTxt := "> setup forming - watch rim break"

// -------------------------------------------------
// Panel
// -------------------------------------------------
bool lightPanel = panelTheme == "Clean Light"
color activePanelBg = lightPanel ? color.rgb(248, 250, 252) : panelBg
color activeLabelCol = lightPanel ? color.rgb(71, 85, 105) : panelLabelCol
color activeValueCol = lightPanel ? color.rgb(15, 23, 42) : panelValueCol
float currentPanelScore = drawPattern ? (confirmedBreakout ? patternScore : setupScore) : na
float panelCupScore = drawPattern and not na(cupSymmetryScore) ? cupSymmetryScore : displayCupSymmetryScore
float panelHandleDepth = drawPattern and not na(handleDepthPct) ? handleDepthPct : displayHandleDepthPct
float panelBreakoutScore = drawPattern and not na(breakoutQualityScore) ? breakoutQualityScore : displayBreakoutQualityScore
float panelScore = not na(currentPanelScore) ? currentPanelScore : displayPanelScore

var table qualityPanel = table.new(position.top_right, 2, 8, border_width = 1, border_color = panelBorder)

if barstate.islast
    table.set_position(qualityPanel, f_position(panelLocation))
    table.clear(qualityPanel, 0, 0, 1, 7)
    if showPanel
        table.merge_cells(qualityPanel, 0, 0, 1, 0)
        table.cell(qualityPanel, 0, 0, "AG Pro Cup and Handle Quality", bgcolor = headerBg, text_color = headerText, text_size = f_size(panelFontInput))
        table.cell(qualityPanel, 0, 1, "Cup Symmetry", bgcolor = activePanelBg, text_color = activeLabelCol, text_size = f_size(panelFontInput))
        table.cell(qualityPanel, 1, 1, f_fmt_score(panelCupScore), bgcolor = activePanelBg, text_color = f_score_color(panelCupScore), text_size = f_size(panelFontInput))
        table.cell(qualityPanel, 0, 2, "Handle Depth", bgcolor = activePanelBg, text_color = activeLabelCol, text_size = f_size(panelFontInput))
        table.cell(qualityPanel, 1, 2, f_fmt_pct(panelHandleDepth), bgcolor = activePanelBg, text_color = activeValueCol, text_size = f_size(panelFontInput))
        table.cell(qualityPanel, 0, 3, "Breakout Quality", bgcolor = activePanelBg, text_color = activeLabelCol, text_size = f_size(panelFontInput))
        table.cell(qualityPanel, 1, 3, f_fmt_score(panelBreakoutScore), bgcolor = activePanelBg, text_color = f_score_color(panelBreakoutScore), text_size = f_size(panelFontInput))
        table.cell(qualityPanel, 0, 4, "Score", bgcolor = activePanelBg, text_color = activeLabelCol, text_size = f_size(panelFontInput))
        table.cell(qualityPanel, 1, 4, f_fmt_score(panelScore), bgcolor = activePanelBg, text_color = f_score_color(panelScore), text_size = f_size(panelFontInput))
        table.merge_cells(qualityPanel, 0, 5, 1, 5)
        table.cell(qualityPanel, 0, 5, "-- TARGET PROOF --", bgcolor = activePanelBg, text_color = accentColor, text_size = f_size(panelFontInput), text_halign = text.align_center)
        table.cell(qualityPanel, 0, 6, "Target Hit Rate", bgcolor = activePanelBg, text_color = activeLabelCol, text_size = f_size(panelFontInput))
        table.cell(qualityPanel, 1, 6, f_thText(thWins, thN), bgcolor = activePanelBg, text_color = f_thColor(thWins, thN, activeLabelCol), text_size = f_size(panelFontInput))
        table.merge_cells(qualityPanel, 0, 7, 1, 7)
        table.cell(qualityPanel, 0, 7, actionTxt, bgcolor = activePanelBg, text_color = accentColor, text_size = f_size(panelFontInput), text_halign = text.align_left)

alertcondition(confirmedBreakout, "Cup and Handle Quality Breakout", "Cup and Handle Quality [AGPro Series]: high-quality cup and handle breakout confirmed on {{ticker}} at {{close}}.")
alertcondition(thHitEv, "Cup and Handle Target Hit", "Cup and Handle Quality [AGPro Series]: the measured-move target of a tracked breakout was reached on {{ticker}}.")
````

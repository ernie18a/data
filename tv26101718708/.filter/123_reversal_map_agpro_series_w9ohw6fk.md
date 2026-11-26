# 1-2-3 Reversal Map [AGPro Series]

- url: https://www.tradingview.com/script/W9OHw6fk-1-2-3-Reversal-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;db4bbb89d19c4624b808d532310dd69f
- version: 3.0

## Description

1-2-3 Reversal Map [AGPro Series]

🔹 OVERVIEW

1-2-3 Reversal Map [AGPro Series] is a focused TradingView overlay built for traders who want a clean, structured way to follow one of the most recognizable reversal formations in price action: the confirmed 1-2-3 reversal.

This tool maps the full life cycle of a 1-2-3 structure. It identifies the confirmed swing sequence, marks Point 1, Point 2, and Point 3, projects the neckline from Point 2, evaluates the neckline break, and highlights the retest pocket after confirmation. The goal is not to fill the chart with generic reversal signals. The goal is to make the actual 1-2-3 process easier to see, compare, and track.

The script is designed around visual clarity. The latest active structure stays readable through numbered swing labels, restrained guide lines, a clearly identified neckline, and a concept-specific retest pocket. The panel then summarizes the current stage, neckline status, retest status, and reversal score in a compact AG Pro layout.

🔹 WHAT MAKES IT DIFFERENT

Most reversal tools try to do too many things at once. They mix candle patterns, double tops, double bottoms, head and shoulders structures, failed breakouts, generic support and resistance zones, trend filters, and broad reversal markers into one crowded chart.

1-2-3 Reversal Map [AGPro Series] takes a more disciplined approach. It stays inside one lane: the confirmed 1-2-3 reversal sequence.

The script does not mark every possible turning point. It waits for a defined swing chain:

1. Point 1 establishes the original swing extreme.
2. Point 2 forms the neckline reference.
3. Point 3 confirms that price has created a structurally relevant retracement.
4. The neckline break turns the structure from a setup into a confirmed map.
5. The retest pocket shows where the broken neckline can be evaluated again.

This creates a cleaner workflow than broad reversal scanners. Instead of asking the chart to show everything, the script asks one focused question: has a valid 1-2-3 structure progressed from swing formation to neckline break and retest behavior?

🧭 WHY THIS DOES NOT OVERLAP WITH OTHER AGPRO TOOLS

This script was intentionally built to avoid overlapping with other AGPro public tools.

It is not a broad reversal pattern scanner. It does not combine double top, double bottom, head and shoulders, inverse head and shoulders, wedge, or candle-pattern logic. It focuses only on the 1-2-3 reversal sequence.

It is not a Turtle Soup or failed-breakout tool. It does not begin with a failed range break or liquidity sweep. Its starting point is a confirmed three-point swing structure.

It is not a wedge reversal tool. It does not evaluate converging trendlines, compression geometry, or wedge breakout behavior.

It is not a generic support and resistance map. The rectangle is not a general zone engine. It is a neckline retest pocket that appears only after a valid 1-2-3 neckline break.

It is not a breakout dashboard. Breakout logic exists only as one stage inside the 1-2-3 reversal process.

This makes the script narrow enough for a differentiated AGPro release while still being visually useful and searchable for traders who specifically look for 1-2-3 reversal structure, neckline break, and retest confirmation workflows.

⚙️ METHODOLOGY

The script uses confirmed pivot structure to define each 1-2-3 sequence.

For a bullish 1-2-3 structure:
- Point 1 is a confirmed swing low.
- Point 2 is the recovery swing high and neckline reference.
- Point 3 is a higher low that holds above Point 1.
- The neckline break requires price to close beyond Point 2 with a configurable ATR buffer.
- The retest pocket is projected around the broken neckline after confirmation.

For a bearish 1-2-3 structure:
- Point 1 is a confirmed swing high.
- Point 2 is the reaction swing low and neckline reference.
- Point 3 is a lower high that holds below Point 1.
- The neckline break requires price to close beyond Point 2 with a configurable ATR buffer.
- The retest pocket is projected around the broken neckline after confirmation.

The reversal score is structure-native. It evaluates:
- P1-P2 leg size relative to ATR
- Point 3 hold quality
- P3 retracement balance
- Timing symmetry between structure legs
- Break distance beyond the neckline
- Break candle body quality
- Close location inside the break candle
- Optional volume participation

The score is not designed as a prediction model. It is a ranking layer for comparing the quality of structures that meet the script's own rules.

📊 PANEL

The AG Pro panel is built to keep the structure status readable without forcing the user to interpret every chart object manually.

Panel rows:
- Stage: shows whether the structure is waiting, armed, broken, retested, expired, or invalidated.
- Neckline Break: shows whether the neckline has been confirmed.
- Retest: shows whether the retest pocket is inactive, being watched, or held.
- Reversal Score: shows the current 0-100 score and quality grade.

The panel uses the AGPro standard format:
- One merged blue header row
- Only the script name in the first row
- Adjustable panel location
- Adjustable panel theme
- Adjustable panel font size

🎛️ KEY INPUTS

Pivot Left Bars / Pivot Right Bars:
Controls how mature the swing points must be before the 1-2-3 structure can form. Higher values create fewer and cleaner structures. Lower values make the script more responsive.

Minimum P1-P2 Leg ATR:
Filters out small structures by requiring a minimum distance between Point 1 and Point 2.

Minimum Point 3 Hold ATR:
Defines how much Point 3 must hold relative to Point 1. This helps separate valid structural retracements from weak retests of the original extreme.

Minimum / Maximum P3 Retracement:
Controls the acceptable retracement range for Point 3. This prevents both shallow noise and near-failed structures from being accepted too easily.

Neckline Break Buffer ATR:
Adds a configurable buffer beyond the neckline before the break is accepted.

Retest Pocket Width ATR:
Controls the height of the retest pocket around the broken neckline.

Retest Pocket Projection Bars:
Controls how far the pocket is projected forward.

Show Context Tags:
Adds compact labels such as Neckline and Retest Pocket so the visual elements are easier to identify.

Show Recent Structure Traces:
Keeps a small rolling set of recent structure lines and pockets while keeping numbered swing labels focused on the latest active setup.

Label Font Size:
Controls all chart labels, including swing numbers, context tags, and optional event labels.

Panel Font Size:
Controls the AG Pro panel text size separately from chart labels.

🔍 HOW TO READ IT

Start with the numbered swing labels.

Point 1 marks the original structural extreme. Point 2 marks the neckline reference. Point 3 marks the retracement that must hold for the 1-2-3 structure to remain valid.

Next, watch the neckline.

The neckline is the main confirmation level. Before it breaks, the panel shows the structure as armed or waiting. After it breaks, the structure becomes a confirmed 1-2-3 map.

Then watch the retest pocket.

The retest pocket appears around the broken neckline after confirmation. This is the script's key context zone. It helps the user observe whether price can return to the neckline area and hold the structure instead of treating every move after the break as equally important.

Finally, use the panel score as a quality filter.

A high score means the structure has stronger internal balance according to the script's rules. A lower score means the 1-2-3 sequence may still exist, but its structure quality is weaker.

🧩 BEST USE CASES

This script is best suited for:
- Traders who use classic 1-2-3 reversal logic
- Swing traders who want confirmed pivot structure
- Price-action traders who track neckline breaks
- Traders who prefer breakout-retest workflows
- Users who want fewer, clearer chart objects instead of broad reversal scanners
- Multi-timeframe chart review where structure clarity matters
- Public chart sharing where visual cleanliness is important

It can be useful on crypto, forex, indices, equities, and commodities, especially on charts where swing structure and neckline behavior are visually meaningful.

🧠 VISUAL DESIGN PHILOSOPHY

The design goal is clarity through restraint.

The script avoids a crowded signal-board style. It uses numbered labels only for the current active swing structure. It separates the neckline from the retest pocket with distinct visual language. Recent traces are kept limited and softened so they provide context without dominating the chart.

The active neckline is drawn with a stronger accent color. The retest pocket is shown as a clean rectangle around the broken neckline. Structure legs are dotted and restrained, helping the user understand the geometry without overpowering price.

The chart should feel premium, readable, and publication-ready. The indicator is built to support a clean TradingView screenshot rather than create visual noise.

🔔 ALERTS

The script includes alerts for the main 1-2-3 lifecycle events:

- 1-2-3 structure armed
- Bullish 1-2-3 neckline break
- Bearish 1-2-3 neckline break
- 1-2-3 retest pocket held
- 1-2-3 structure invalidated

These alerts are designed around structure progression, not generic reversal marking.

🔹 LIMITATIONS AND TRANSPARENCY

The script uses confirmed pivots, which means swing points appear only after the required right-side confirmation bars. This is intentional. It prioritizes confirmed structure over instant but unstable markings.

The script does not attempt to identify every possible reversal pattern. It does not evaluate macro trend, fundamentals, order flow, news, or external liquidity conditions.

The reversal score is a structured quality model, not a certainty model. It helps compare 1-2-3 structures inside this script's framework, but it does not forecast outcomes.

Retest pockets are contextual areas around the broken neckline. They are not universal support or resistance zones, and they are not designed to replace broader market analysis.

✅ IDEAL USER

This script is ideal for traders who:
- Understand classic 1-2-3 reversal structure
- Prefer confirmed market structure over early noise
- Want a clean neckline and retest workflow
- Value visual clarity and chart discipline
- Use TradingView for structured price-action review
- Want a focused public-free AGPro tool that does one concept well

1-2-3 Reversal Map [AGPro Series] is built for users who want a focused reversal map, not a crowded reversal scanner.

🔹 RELEASE NOTES

- Initial public release of 1-2-3 Reversal Map [AGPro Series].
- Added confirmed Point 1, Point 2, and Point 3 swing mapping.
- Added neckline projection with close-based break confirmation.
- Added breakout retest pocket around the broken neckline.
- Added context tags for Neckline and Retest Pocket.
- Added AG Pro panel with Stage, Neckline Break, Retest, and Reversal Score.
- Added adjustable panel location, panel theme, label size, and panel font size.
- Added recent structure traces with softened historical visuals.
- Added alerts for armed structures, neckline breaks, retest holds, and invalidations.

## Source Code

````pine
// -------------------------------------------------
// 1-2-3 Reversal Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.1
//
// A focused 1-2-3 reversal structure map for TradingView traders who want
// close-confirmed swing sequencing, neckline break validation, retest pocket context,
// and a clean reversal score without turning the chart into a broad reversal
// scanner. The script maps numbered swing points, projects the neckline, tracks
// breakout and retest status, and keeps the active 1-2-3 structure readable. A
// cumulative Break Edge engine measures, on this chart and timeframe, how often
// confirmed neckline breaks actually traveled a full ATR before the structure
// invalidation gave way, and a clear next-action line turns the reversal map
// into a decision tool.
// -------------------------------------------------

//@version=6
indicator("1-2-3 Reversal Map [AGPro Series]",
     shorttitle = "AGP123R",
     overlay = true,
     max_labels_count = 100,
     max_lines_count = 50,
     max_boxes_count = 30)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
// Brand
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
// Panel
panelBg       = color.rgb(15, 23, 42)
panelBorder   = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
// States
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupDetection = "1-2-3 Structure"
leftBars = input.int(2, "Pivot Left Bars", minval = 1, maxval = 15, group = groupDetection, tooltip = "Number of bars required on the left side of a swing point. Higher values produce fewer, more mature 1-2-3 structures.")
rightBars = input.int(2, "Pivot Right Bars", minval = 1, maxval = 15, group = groupDetection, tooltip = "Number of bars required on the right side of a swing point. Pivots are confirmed only after this delay.")
atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupDetection, tooltip = "ATR period used for structure size, neckline buffers, label offsets, and retest pocket width.")
minLegAtr = input.float(0.65, "Minimum P1-P2 Leg ATR", minval = 0.10, maxval = 10.00, step = 0.05, group = groupDetection, tooltip = "Minimum distance between Point 1 and Point 2, measured in ATR. This helps ignore micro structures.")
minPoint3HoldAtr = input.float(0.05, "Minimum Point 3 Hold ATR", minval = 0.00, maxval = 5.00, step = 0.05, group = groupDetection, tooltip = "Required distance between Point 3 and Point 1, measured in ATR. Bullish structures need a higher low; bearish structures need a lower high.")
minRetrace = input.float(0.15, "Minimum P3 Retracement", minval = 0.05, maxval = 0.90, step = 0.05, group = groupDetection, tooltip = "Minimum retracement of the P1-P2 leg required for Point 3. This keeps the structure from confirming after a shallow pause.")
maxRetrace = input.float(0.92, "Maximum P3 Retracement", minval = 0.10, maxval = 0.98, step = 0.05, group = groupDetection, tooltip = "Maximum retracement of the P1-P2 leg allowed for Point 3. This prevents structures where Point 3 nearly invalidates Point 1.")
maxCandidateAge = input.int(160, "Maximum Structure Age", minval = 20, maxval = 500, group = groupDetection, tooltip = "Maximum bars after Point 3 before an unbroken 1-2-3 structure expires.")

groupBreak = "Breakout And Retest"
breakBufferAtr = input.float(0.05, "Neckline Break Buffer ATR", minval = 0.00, maxval = 2.00, step = 0.01, group = groupBreak, tooltip = "ATR buffer required beyond the neckline before the break is accepted. Use a small value for close-based confirmation.")
pocketWidthAtr = input.float(0.30, "Retest Pocket Width ATR", minval = 0.05, maxval = 3.00, step = 0.05, group = groupBreak, tooltip = "Vertical width of the retest pocket around the broken neckline.")
pocketBars = input.int(55, "Retest Pocket Projection Bars", minval = 10, maxval = 200, group = groupBreak, tooltip = "Number of bars the breakout and retest pocket is projected forward after neckline confirmation.")
retestWindow = input.int(40, "Retest Window Bars", minval = 5, maxval = 200, group = groupBreak, tooltip = "Maximum number of bars after neckline break during which a retest can be classified as active.")
invalidBufferAtr = input.float(0.15, "Invalidation Buffer ATR", minval = 0.00, maxval = 3.00, step = 0.05, group = groupBreak, tooltip = "ATR buffer beyond Point 1 before an armed structure is invalidated, or beyond Point 3 after a neckline break.")
useVolumeScore = input.bool(true, "Use Volume In Score", group = groupBreak, tooltip = "When enabled, breakout participation relative to average volume contributes to the reversal score.")
volumeLen = input.int(20, "Volume Average Length", minval = 2, maxval = 200, group = groupBreak, tooltip = "Lookback length used to compare breakout volume with average volume.")
edgeTargetAtr = input.float(1.0, "Break Edge Target ATR", minval = 0.25, maxval = 5.00, step = 0.25, group = groupBreak, tooltip = "Distance, in ATR from the break close, that price must travel in the break direction for the Break Edge statistic to count the break as a hit.")
edgeWindow = input.int(40, "Break Edge Window", minval = 5, maxval = 300, group = groupBreak, tooltip = "Maximum number of bars a Break Edge episode may stay open. If neither the target nor the frozen Point 3 invalidation is reached inside this window, the episode counts as a miss.")

groupVisual = "Visuals"
showNumberedLabels = input.bool(true, "Show Numbered Swing Labels", group = groupVisual, tooltip = "Displays the confirmed Point 1, Point 2, and Point 3 labels for each accepted structure.")
showStructureLegs = input.bool(true, "Show 1-2-3 Structure Legs", group = groupVisual, tooltip = "Connects Point 1, Point 2, and Point 3 with restrained guide lines so the active reversal structure is easier to read.")
showNeckline = input.bool(true, "Show Neckline", group = groupVisual, tooltip = "Draws the horizontal neckline from Point 2 and extends it while the active structure is being evaluated.")
showRetestPocket = input.bool(true, "Show Breakout Retest Pocket", group = groupVisual, tooltip = "Draws a concept-native retest pocket around the broken neckline after confirmation.")
showContextTags = input.bool(true, "Show Context Badges", group = groupVisual, tooltip = "Adds filled context badges to the active neckline and centers a state-aware badge inside the retest pocket.")
showPlanBadge = input.bool(true, "Show Active Plan Badge", group = groupVisual, tooltip = "Shows one live state badge near current price for the active 1-2-3 plan. The badge updates in place and does not create historical clutter.")
showBreakLabels = input.bool(false, "Show Break/Retest Tags", group = groupVisual, tooltip = "Displays compact labels when the neckline breaks and when the retest pocket is held. Disabled by default for a cleaner publication view.")
showRecentStructures = input.bool(true, "Show Recent Structure Traces", group = groupVisual, tooltip = "Keeps a small rolling set of recent 1-2-3 lines and retest pockets. Numbered swing labels remain focused on the latest active structure.")
maxVisibleLabels = input.int(9, "Maximum Event Labels", minval = 3, maxval = 40, group = groupVisual, tooltip = "Upper limit for optional break and retest event labels. Numbered swing labels are managed separately for the latest active structure.")
labelOffsetAtr = input.float(0.60, "Label Offset ATR", minval = 0.10, maxval = 5.00, step = 0.05, group = groupVisual, tooltip = "Distance used to place labels away from candles, measured in ATR.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual, tooltip = "Controls the font size for all structure, break, retest, and invalidation labels.")

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = "Shows the compact AG Pro status panel for the active 1-2-3 structure.")
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = groupPanel, tooltip = "Selects where the AG Pro panel is displayed on the chart.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light", "Auto"], group = groupPanel, tooltip = "Controls the panel color theme. Auto follows the chart background brightness.")
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = "Controls text size inside the AG Pro panel.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
float atr = ta.atr(atrLen)
float avgVolume = ta.sma(volume, volumeLen)

f_size(string opt) =>
    result = size.normal
    if opt == "Tiny"
        result := size.tiny
    else if opt == "Small"
        result := size.small
    else if opt == "Large"
        result := size.large
    result

f_panel_position(string opt) =>
    result = position.top_right
    if opt == "Top Left"
        result := position.top_left
    else if opt == "Bottom Right"
        result := position.bottom_right
    else if opt == "Bottom Left"
        result := position.bottom_left
    result

f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_grade(float score) =>
    string result = "C"
    if score >= 85
        result := "A+"
    else if score >= 75
        result := "A"
    else if score >= 62
        result := "B"
    result

f_chart_is_dark() =>
    float brightness = color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color)
    brightness < 384.0

// Break Edge display helpers. Color follows the same rounded rate shown
// in the panel text, and is applied only once the sample is sufficient
// (n >= 8); below that the value stays neutral so a small sample never
// implies confidence.
f_beText(int _w, int _n) =>
    _n > 0 ? str.tostring(math.round(100.0 * _w / _n)) + "%  (n=" + str.tostring(_n) + ")" : "-  (n=0)"

f_beColor(int _w, int _n, color _fb) =>
    _r = _n > 0 ? math.round(100.0 * _w / _n) : 0
    _n >= 8 ? (_r >= 55 ? bullColor : _r >= 40 ? neutralColor : bearColor) : _fb

labelSize = f_size(labelSizeInput)
panelTextSize = f_size(panelSizeInput)
bool darkPanel = panelTheme == "Dark" or (panelTheme == "Auto" and f_chart_is_dark())
color activePanelBg = darkPanel ? panelBg : color.rgb(248, 250, 252)
color activePanelBorder = darkPanel ? panelBorder : color.rgb(203, 213, 225)
color activePanelLabel = darkPanel ? panelLabelCol : color.rgb(71, 85, 105)
color activePanelValue = darkPanel ? panelValueCol : color.rgb(15, 23, 42)

// -------------------------------------------------
// Object management
// -------------------------------------------------
var label[] mapLabels = array.new_label()
var label[] activeSwingLabels = array.new_label()
var label[] activeContextLabels = array.new_label()
var line[] mapLines = array.new_line()
var box[] mapBoxes = array.new_box()

f_trim_labels() =>
    while array.size(mapLabels) > maxVisibleLabels
        label oldLabel = array.shift(mapLabels)
        label.delete(oldLabel)

f_trim_lines() =>
    while array.size(mapLines) > 12
        line oldLine = array.shift(mapLines)
        line.delete(oldLine)

f_trim_boxes() =>
    while array.size(mapBoxes) > 2
        box oldBox = array.shift(mapBoxes)
        box.delete(oldBox)

f_clear_active_swing_labels() =>
    while array.size(activeSwingLabels) > 0
        label oldLabel = array.pop(activeSwingLabels)
        label.delete(oldLabel)

f_clear_active_context_labels() =>
    while array.size(activeContextLabels) > 0
        label oldLabel = array.pop(activeContextLabels)
        label.delete(oldLabel)

f_clear_map_objects() =>
    while array.size(mapLabels) > 0
        label oldLabel = array.pop(mapLabels)
        label.delete(oldLabel)
    f_clear_active_swing_labels()
    f_clear_active_context_labels()
    while array.size(mapLines) > 0
        line oldLine = array.pop(mapLines)
        line.delete(oldLine)
    while array.size(mapBoxes) > 0
        box oldBox = array.pop(mapBoxes)
        box.delete(oldBox)

f_add_label(int x, float y, string txt, color bg, color txtColor, styleValue) =>
    label id = label.new(x, y, txt, xloc = xloc.bar_index, style = styleValue, color = bg, textcolor = txtColor, size = labelSize)
    array.push(mapLabels, id)
    f_trim_labels()
    id

f_add_active_swing_label(int x, float y, string txt, color bg, color txtColor, styleValue) =>
    label id = label.new(x, y, txt, xloc = xloc.bar_index, style = styleValue, color = bg, textcolor = txtColor, size = labelSize)
    array.push(activeSwingLabels, id)
    id

f_add_context_label(int x, float y, string txt, color bg, color txtColor, styleValue) =>
    label id = label.new(x, y, txt, xloc = xloc.bar_index, style = styleValue, color = bg, textcolor = txtColor, size = labelSize)
    array.push(activeContextLabels, id)
    id

f_soften_active_trace(line neckLine, box pocketBox, int direction) =>
    color traceColor = direction == 1 ? bullColor : bearColor
    if not na(neckLine)
        line.set_color(neckLine, color.new(accentColor, 70))
        line.set_width(neckLine, 1)
        line.set_style(neckLine, line.style_dashed)
    if not na(pocketBox)
        box.set_bgcolor(pocketBox, color.new(traceColor, 94))
        box.set_border_color(pocketBox, color.new(traceColor, 76))

f_add_line(int x1, float y1, int x2, float y2, color lineColor, lineStyle, int lineWidth) =>
    line id = line.new(x1, y1, x2, y2, xloc = xloc.bar_index, extend = extend.none, color = lineColor, style = lineStyle, width = lineWidth)
    array.push(mapLines, id)
    f_trim_lines()
    id

f_add_box(int left, float top, int right, float bottom, color borderColor, color bgColor) =>
    box id = box.new(left, top, right, bottom, xloc = xloc.bar_index, border_color = borderColor, bgcolor = bgColor)
    array.push(mapBoxes, id)
    f_trim_boxes()
    id

// -------------------------------------------------
// Pivot chain
// -------------------------------------------------
var int[] pivotTypes = array.new_int()
var int[] pivotBars = array.new_int()
var float[] pivotPrices = array.new_float()

f_add_pivot(int pivotType, int pivotBar, float pivotPrice) =>
    bool changed = false
    int pivotCount = array.size(pivotTypes)
    if pivotCount > 0 and array.get(pivotTypes, pivotCount - 1) == pivotType
        float oldPrice = array.get(pivotPrices, pivotCount - 1)
        bool betterPivot = pivotType == 1 ? pivotPrice > oldPrice : pivotPrice < oldPrice
        if betterPivot
            array.set(pivotBars, pivotCount - 1, pivotBar)
            array.set(pivotPrices, pivotCount - 1, pivotPrice)
            changed := true
    else
        array.push(pivotTypes, pivotType)
        array.push(pivotBars, pivotBar)
        array.push(pivotPrices, pivotPrice)
        changed := true
    while array.size(pivotTypes) > 12
        array.shift(pivotTypes)
        array.shift(pivotBars)
        array.shift(pivotPrices)
    changed

float pivotHigh = ta.pivothigh(high, leftBars, rightBars)
float pivotLow = ta.pivotlow(low, leftBars, rightBars)
bool pivotChanged = false

if barstate.isconfirmed and not na(pivotHigh)
    pivotChanged := f_add_pivot(1, bar_index - rightBars, pivotHigh) or pivotChanged

if barstate.isconfirmed and not na(pivotLow)
    pivotChanged := f_add_pivot(-1, bar_index - rightBars, pivotLow) or pivotChanged

// -------------------------------------------------
// Active 1-2-3 state
// -------------------------------------------------
var int activeDirection = 0
var int lastDirection = 0
var string activeStage = "Waiting"
var float activeNeckline = na
var float activeScore = na
var int activeP1Bar = na
var int activeP2Bar = na
var int activeP3Bar = na
var float activeP1 = na
var float activeP2 = na
var float activeP3 = na
var bool activeBroken = false
var bool activeRetested = false
var int activeBreakBar = na
var line activeNecklineLine = na
var box activePocketBox = na
var float activePocketTop = na
var float activePocketBottom = na
var label activePlanLabel = na

f_structure_score(int direction, float p1, float p2, float p3, int b1, int b2, int b3) =>
    float leg = math.abs(p2 - p1)
    float safeLeg = math.max(leg, syminfo.mintick)
    float hold = direction == 1 ? p3 - p1 : p1 - p3
    float retrace = direction == 1 ? (p2 - p3) / safeLeg : (p3 - p2) / safeLeg
    float leftSpan = math.max(1.0, b2 - b1)
    float rightSpan = math.max(1.0, b3 - b2)
    float symmetry = math.min(leftSpan, rightSpan) / math.max(leftSpan, rightSpan)
    float legScore = f_clamp((leg / atr) / math.max(minLegAtr, 0.10) * 25.0, 0.0, 25.0)
    float holdScore = f_clamp((hold / atr) / math.max(minPoint3HoldAtr, 0.05) * 20.0, 0.0, 20.0)
    float retraceScore = f_clamp(25.0 - math.abs(retrace - 0.55) * 70.0, 0.0, 25.0)
    float symmetryScore = f_clamp(symmetry * 20.0, 0.0, 20.0)
    float spacingScore = f_clamp((math.min(leftSpan, rightSpan) / math.max(leftBars + rightBars, 1)) * 10.0, 0.0, 10.0)
    f_clamp(legScore + holdScore + retraceScore + symmetryScore + spacingScore, 0.0, 100.0)

f_break_score(int direction, float baseScore, float neckline) =>
    float distance = math.abs(close - neckline) / atr
    float body = math.abs(close - open) / atr
    float closeLocation = direction == 1 ? (close - low) / math.max(high - low, syminfo.mintick) : (high - close) / math.max(high - low, syminfo.mintick)
    float volumeScore = 5.0
    if useVolumeScore
        volumeScore := volume > avgVolume ? 10.0 : 3.0
    float breakAdd = f_clamp(distance * 18.0, 0.0, 10.0) + f_clamp(body * 10.0, 0.0, 8.0) + f_clamp(closeLocation * 8.0, 0.0, 8.0) + volumeScore
    f_clamp(baseScore * 0.75 + breakAdd, 0.0, 100.0)

f_direction_text(int direction) =>
    string result = "None"
    if direction == 1
        result := "Bullish"
    else if direction == -1
        result := "Bearish"
    result

f_status_color(int direction, bool broken, bool retested) =>
    color result = neutralColor
    if direction == 1
        result := retested or broken ? bullColor : accentColor
    else if direction == -1
        result := retested or broken ? bearColor : accentColor
    result

bool newArmedEvent = false
bool bullBreakEvent = false
bool bearBreakEvent = false
bool retestEvent = false
bool invalidEvent = false

if pivotChanged and array.size(pivotTypes) >= 3 and not na(atr) and atr > 0
    int pivotCount = array.size(pivotTypes)
    int t1 = array.get(pivotTypes, pivotCount - 3)
    int t2 = array.get(pivotTypes, pivotCount - 2)
    int t3 = array.get(pivotTypes, pivotCount - 1)
    int b1 = array.get(pivotBars, pivotCount - 3)
    int b2 = array.get(pivotBars, pivotCount - 2)
    int b3 = array.get(pivotBars, pivotCount - 1)
    float p1 = array.get(pivotPrices, pivotCount - 3)
    float p2 = array.get(pivotPrices, pivotCount - 2)
    float p3 = array.get(pivotPrices, pivotCount - 1)
    bool bullChain = t1 == -1 and t2 == 1 and t3 == -1
    bool bearChain = t1 == 1 and t2 == -1 and t3 == 1
    int candidateDirection = bullChain ? 1 : bearChain ? -1 : 0
    bool freshCandidate = na(activeP3Bar) or b3 != activeP3Bar
    if candidateDirection != 0 and freshCandidate
        float leg = math.abs(p2 - p1)
        float safeLeg = math.max(leg, syminfo.mintick)
        float point3Hold = candidateDirection == 1 ? p3 - p1 : p1 - p3
        float retrace = candidateDirection == 1 ? (p2 - p3) / safeLeg : (p3 - p2) / safeLeg
        bool validLeg = leg >= atr * minLegAtr
        bool validHold = point3Hold >= atr * minPoint3HoldAtr
        bool validRetrace = retrace >= minRetrace and retrace <= maxRetrace
        if validLeg and validHold and validRetrace
            if not showRecentStructures
                f_clear_map_objects()
            else
                f_soften_active_trace(activeNecklineLine, activePocketBox, activeDirection)
                f_clear_active_swing_labels()
                f_clear_active_context_labels()
            activeDirection := candidateDirection
            lastDirection := candidateDirection
            activeStage := "Structure Armed"
            activeNeckline := p2
            activeScore := f_structure_score(candidateDirection, p1, p2, p3, b1, b2, b3)
            activeP1Bar := b1
            activeP2Bar := b2
            activeP3Bar := b3
            activeP1 := p1
            activeP2 := p2
            activeP3 := p3
            activeBroken := false
            activeRetested := false
            activeBreakBar := na
            activeNecklineLine := na
            activePocketTop := na
            activePocketBottom := na
            activePocketBox := na
            newArmedEvent := true
            if showNumberedLabels
                bool p1IsLow = candidateDirection == 1
                bool p2IsHigh = candidateDirection == 1
                bool p3IsLow = candidateDirection == 1
                f_add_active_swing_label(b1, p1 + (p1IsLow ? -atr * labelOffsetAtr : atr * labelOffsetAtr), "1", candidateDirection == 1 ? bullColor : bearColor, color.white, p1IsLow ? label.style_label_up : label.style_label_down)
                f_add_active_swing_label(b2, p2 + (p2IsHigh ? atr * labelOffsetAtr : -atr * labelOffsetAtr), "2", accentColor, color.white, p2IsHigh ? label.style_label_down : label.style_label_up)
                f_add_active_swing_label(b3, p3 + (p3IsLow ? -atr * labelOffsetAtr : atr * labelOffsetAtr), "3", candidateDirection == 1 ? bullColor : bearColor, color.white, p3IsLow ? label.style_label_up : label.style_label_down)
            if showStructureLegs
                color legColor = color.new(candidateDirection == 1 ? bullColor : bearColor, 34)
                f_add_line(b1, p1, b2, p2, legColor, line.style_dotted, 1)
                f_add_line(b2, p2, b3, p3, legColor, line.style_dotted, 1)
            if showNeckline
                activeNecklineLine := f_add_line(b2, p2, bar_index + pocketBars, p2, accentColor, line.style_solid, 3)
                if showContextTags
                    f_add_context_label(bar_index + pocketBars, p2, "NECKLINE | " + str.tostring(p2, format.mintick), accentColor, color.white, label.style_label_left)

if activeDirection != 0 and not activeBroken and not na(activeP3Bar) and barstate.isconfirmed
    bool expiredStructure = bar_index - activeP3Bar > maxCandidateAge
    bool preBreakInvalid = activeDirection == 1 ? low < activeP1 - atr * invalidBufferAtr : high > activeP1 + atr * invalidBufferAtr
    if expiredStructure or preBreakInvalid
        activeStage := expiredStructure ? "Expired" : "Invalidated"
        f_soften_active_trace(activeNecklineLine, activePocketBox, activeDirection)
        f_clear_active_swing_labels()
        f_clear_active_context_labels()
        activeNecklineLine := na
        activePocketBox := na
        activeDirection := 0
        invalidEvent := preBreakInvalid
    else
        bool necklineBreak = activeDirection == 1 ? close > activeNeckline + atr * breakBufferAtr : close < activeNeckline - atr * breakBufferAtr
        if necklineBreak
            activeBroken := true
            activeBreakBar := bar_index
            activeStage := "Neckline Break"
            activeScore := f_break_score(activeDirection, activeScore, activeNeckline)
            bullBreakEvent := activeDirection == 1
            bearBreakEvent := activeDirection == -1
            activePocketTop := activeNeckline + atr * pocketWidthAtr
            activePocketBottom := activeNeckline - atr * pocketWidthAtr
            if showBreakLabels
                float breakLabelPrice = activeDirection == 1 ? high + atr * labelOffsetAtr : low - atr * labelOffsetAtr
                f_add_label(bar_index, breakLabelPrice, "Break " + str.tostring(math.round(activeScore)) + " " + f_grade(activeScore), activeDirection == 1 ? bullColor : bearColor, color.white, activeDirection == 1 ? label.style_label_down : label.style_label_up)
            if showRetestPocket
                activePocketBox := f_add_box(bar_index, activePocketTop, bar_index + pocketBars, activePocketBottom, activeDirection == 1 ? bullColor : bearColor, color.new(activeDirection == 1 ? bullColor : bearColor, 88))
                if showContextTags
                    f_clear_active_context_labels()
                    int pocketCenterBar = bar_index + int(math.round(pocketBars * 0.5))
                    string pocketSide = activeDirection == 1 ? "BULL" : "BEAR"
                    f_add_context_label(pocketCenterBar, activeNeckline, pocketSide + " RETEST WATCH | Q" + str.tostring(math.round(activeScore)), activeDirection == 1 ? bullColor : bearColor, color.white, label.style_label_center)

if activeDirection != 0 and activeBroken and not activeRetested and not na(activeBreakBar) and barstate.isconfirmed
    bool stillInRetestWindow = bar_index - activeBreakBar <= retestWindow
    bool postBreakInvalid = activeDirection == 1 ? close < activeP3 - atr * invalidBufferAtr : close > activeP3 + atr * invalidBufferAtr
    bool pocketTouched = false
    bool pocketHeld = false
    if not na(activePocketTop) and not na(activePocketBottom)
        pocketTouched := activeDirection == 1 ? low <= activePocketTop : high >= activePocketBottom
        pocketHeld := activeDirection == 1 ? close >= activePocketBottom and close > activeNeckline : close <= activePocketTop and close < activeNeckline
    if postBreakInvalid
        activeStage := "Invalidated"
        f_soften_active_trace(activeNecklineLine, activePocketBox, activeDirection)
        f_clear_active_swing_labels()
        f_clear_active_context_labels()
        activeNecklineLine := na
        activePocketBox := na
        activeDirection := 0
        invalidEvent := true
    else if stillInRetestWindow and pocketTouched and pocketHeld
        activeRetested := true
        activeStage := "Retest Held"
        activeScore := f_clamp(activeScore + 10.0, 0.0, 100.0)
        retestEvent := true
        if showBreakLabels
            float retestLabelPrice = activeDirection == 1 ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr
            f_add_label(bar_index, retestLabelPrice, "Retest " + str.tostring(math.round(activeScore)) + " " + f_grade(activeScore), activeDirection == 1 ? bullColor : bearColor, color.white, activeDirection == 1 ? label.style_label_up : label.style_label_down)
        if not na(activePocketBox)
            box.set_bgcolor(activePocketBox, color.new(activeDirection == 1 ? bullColor : bearColor, 78))
            box.set_border_color(activePocketBox, activeDirection == 1 ? bullColor : bearColor)
        if showContextTags and not na(activePocketTop) and not na(activePocketBottom)
            f_clear_active_context_labels()
            int pocketCenterBar = activeBreakBar + int(math.round(pocketBars * 0.5))
            string pocketSide = activeDirection == 1 ? "BULL" : "BEAR"
            f_add_context_label(pocketCenterBar, activeNeckline, pocketSide + " RETEST HELD | Q" + str.tostring(math.round(activeScore)), activeDirection == 1 ? bullColor : bearColor, color.white, label.style_label_center)
    else if not stillInRetestWindow
        activeStage := "Breakout Active"

if activeDirection != 0 and showNeckline and not na(activeNecklineLine)
    line.set_x2(activeNecklineLine, bar_index + pocketBars)

if activeDirection != 0 and showRetestPocket and not na(activePocketBox)
    box.set_right(activePocketBox, bar_index + math.max(5, pocketBars - nz(bar_index - activeBreakBar, 0)))

if barstate.islast
    bool showLivePlan = showPlanBadge and activeDirection != 0 and not na(activeScore) and not na(atr)
    if showLivePlan
        string planSide = activeDirection == 1 ? "BULL" : "BEAR"
        string planPhase = activeRetested ? "RETEST HELD" : activeBroken ? "BREAK ACTIVE" : "STRUCTURE ARMED"
        string planText = planSide + " 1-2-3\n" + planPhase + " | Q" + str.tostring(math.round(activeScore))
        float planY = activeDirection == 1 ? high + atr * labelOffsetAtr : low - atr * labelOffsetAtr
        color planColor = activeDirection == 1 ? bullColor : bearColor
        if na(activePlanLabel)
            activePlanLabel := label.new(bar_index, planY, planText, xloc = xloc.bar_index, style = activeDirection == 1 ? label.style_label_down : label.style_label_up, color = planColor, textcolor = color.white, size = labelSize)
        else
            label.set_xy(activePlanLabel, bar_index, planY)
            label.set_text(activePlanLabel, planText)
            label.set_style(activePlanLabel, activeDirection == 1 ? label.style_label_down : label.style_label_up)
            label.set_color(activePlanLabel, planColor)
            label.set_textcolor(activePlanLabel, color.white)
            label.set_size(activePlanLabel, labelSize)
    else if not na(activePlanLabel)
        label.delete(activePlanLabel)
        activePlanLabel := na

barcolor(newArmedEvent ? color.new(accentColor, 74) : na)

// -------------------------------------------------
// BREAK EDGE ENGINE (cumulative, non-repaint)
// Every confirmed neckline break opens one tracking episode with the
// break close, ATR, and the Point 3 invalidation level frozen at the
// break bar. The episode resolves as a HIT when price travels the Break
// Edge Target distance in the break direction, and as a MISS when the
// frozen invalidation is closed through first or the window expires
// without contact. Episodes open and resolve on confirmed bars only, so
// the statistic never repaints.
// -------------------------------------------------
var bool  beOn = false
var int   beDir = 0
var float beEntry = na
var float beAtr = na
var float beInval = na
var int   beStart = na
var int   beWin = 0
var int   beWins = 0
var int   beN = 0

bool beHitEv = false

if beOn and barstate.isconfirmed
    bool beHit = beDir == 1 ? high >= beEntry + beAtr * edgeTargetAtr : low <= beEntry - beAtr * edgeTargetAtr
    bool beLoss = beDir == 1 ? close < beInval : close > beInval
    bool beTimeout = not na(beStart) and bar_index - beStart >= beWin
    if beHit
        beN += 1
        beWins += 1
        beOn := false
        beHitEv := true
    else if beLoss or beTimeout
        beN += 1
        beOn := false

if (bullBreakEvent or bearBreakEvent) and barstate.isconfirmed and not na(atr) and atr > 0.0
    if beOn
        beN += 1
        beOn := false
    beOn := true
    beDir := bullBreakEvent ? 1 : -1
    beEntry := close
    beAtr := atr
    beInval := bullBreakEvent ? activeP3 - atr * invalidBufferAtr : activeP3 + atr * invalidBufferAtr
    beStart := bar_index
    beWin := edgeWindow

// Next-action line, always consistent with the active stage
string actionTxt = "Scan new structure"
if activeStage == "Structure Armed"
    actionTxt := "Watch neckline"
else if activeStage == "Neckline Break"
    actionTxt := "Review retest"
else if activeStage == "Retest Held"
    actionTxt := "Manage reversal"
else if activeStage == "Breakout Active"
    actionTxt := "Track breakout"
else if activeStage == "Invalidated"
    actionTxt := "Stand aside"
else if activeStage == "Expired"
    actionTxt := "Wait new structure"

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table agpPanel = table.new(position.top_right, 2, 8, border_width = 1, border_color = panelBorder)

f_panel_row(int row, string name, string value, color valueColor) =>
    table.cell(agpPanel, 0, row, name, bgcolor = activePanelBg, text_color = activePanelLabel, text_size = panelTextSize)
    table.cell(agpPanel, 1, row, value, bgcolor = activePanelBg, text_color = valueColor, text_size = panelTextSize)

if barstate.islast
    table.set_position(agpPanel, f_panel_position(panelLocation))
    table.clear(agpPanel, 0, 0, 1, 7)
    if showPanel
        table.merge_cells(agpPanel, 0, 0, 1, 0)
        table.cell(agpPanel, 0, 0, "AG Pro 1-2-3 Reversal Map", bgcolor = headerBg, text_color = headerText, text_size = panelTextSize)
        int displayDirection = activeDirection != 0 ? activeDirection : lastDirection
        string stateText = f_direction_text(displayDirection) + " | " + activeStage
        string necklineText = na(activeNeckline) ? "-" : str.tostring(activeNeckline, format.mintick)
        string retestText = activeRetested ? "Held" : activeBroken ? "Watching" : "Inactive"
        string scoreText = na(activeScore) ? "n/a" : str.tostring(math.round(activeScore)) + " / 100 " + f_grade(activeScore)
        string ageText = na(activeP3Bar) ? "-" : str.tostring(math.max(0, bar_index - activeP3Bar)) + " / " + str.tostring(maxCandidateAge) + " bars"
        color stateColor = f_status_color(displayDirection, activeBroken, activeRetested)
        f_panel_row(1, "Workflow", actionTxt, stateColor)
        f_panel_row(2, "State", stateText, stateColor)
        f_panel_row(3, "Neckline", necklineText, accentColor)
        f_panel_row(4, "Retest", retestText, activeRetested ? stateColor : neutralColor)
        f_panel_row(5, "Quality", scoreText, na(activeScore) ? activePanelValue : stateColor)
        f_panel_row(6, "Structure Age", ageText, activePanelValue)
        f_panel_row(7, "Break Proof", f_beText(beWins, beN), f_beColor(beWins, beN, activePanelLabel))

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(newArmedEvent, "1-2-3 structure armed", "A confirmed 1-2-3 swing structure is armed on {{ticker}} {{interval}}.")
alertcondition(bullBreakEvent, "Bullish 1-2-3 neckline break", "Bullish 1-2-3 neckline break confirmed on {{ticker}} {{interval}}.")
alertcondition(bearBreakEvent, "Bearish 1-2-3 neckline break", "Bearish 1-2-3 neckline break confirmed on {{ticker}} {{interval}}.")
alertcondition(retestEvent, "1-2-3 retest pocket held", "The active 1-2-3 neckline retest pocket is held on {{ticker}} {{interval}}.")
alertcondition(invalidEvent, "1-2-3 structure invalidated", "The active 1-2-3 reversal structure is invalidated on {{ticker}} {{interval}}.")
alertcondition(beHitEv, "1-2-3 break target hit", "The active 1-2-3 neckline break reached its Break Edge target on {{ticker}} {{interval}}.")
````

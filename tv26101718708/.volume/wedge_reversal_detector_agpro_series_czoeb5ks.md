# Wedge Reversal Detector [AGPro Series]

- url: https://www.tradingview.com/script/czoEb5kS-Wedge-Reversal-Detector-AGPro-Series/
- type: indicator
- pine_id: PUB;8ac53f8fbc054ab39e17d816980b181d
- version: 3.0

## Description

Wedge Reversal Detector [AGPro Series]

🔷 Overview

Wedge Reversal Detector [AGPro Series] is a focused chart-pattern engine built for one specific structure: the rising wedge and falling wedge. Instead of scanning every possible reversal pattern, drawing broad support and resistance, or behaving like a generic breakout dashboard, this script studies the geometry of a wedge itself: confirmed pivot boundaries, slope convergence, pattern maturity, reversal break quality, projected reaction zone, and invalidation context.

The goal is to make wedge analysis cleaner and more objective on a live chart. A valid wedge is not treated as just two random trendlines. The script requires a confirmed pivot structure, a meaningful initial width, a narrowing final width, and the correct slope relationship for either a rising wedge or a falling wedge. Once a qualified structure is active, it draws the converging boundaries directly on the chart and waits for a reversal-side break.

The detector also includes two visual preparation layers. The developing-wedge preview layer can draw dashed boundaries before the structure is fully armed. The Wedge Radar layer keeps the latest compression window visible when no confirmed candidate is active. Radar projection is capped so higher-timeframe charts stay clean, and low-compression radar states can remain boundary-only until the structure becomes visually meaningful. Break labels, reaction zones, and invalidation guides remain reserved for stricter confirmed candidates. This keeps the chart visually informative without weakening the actual confirmation logic.

The visual layer includes compact boundary tags that label the upper and lower rails directly on the right side of the structure. These tags are designed as chart annotations, not signal spam: they identify whether the rail is acting as a rejection rail, compression rail, reclaim rail, break rail, or invalidation rail. A single optional compression tag can also summarize the current radar or wedge state.

🔶 Why This Is Different

Many wedge indicators stop at pattern drawing. Others become broad pattern scanners that mix wedges with channels, double tops, double bottoms, triangles, support and resistance zones, and unrelated reversal signals. Wedge Reversal Detector intentionally stays narrower.

Its edge is the sequence:
1. Detect a qualified rising or falling wedge from confirmed pivots.
2. Measure whether the boundaries are genuinely converging.
3. Grade wedge maturity before any break occurs.
4. Confirm the reversal-side break with an optional close-based rule and ATR buffer.
5. Score break quality using maturity, boundary expansion, candle structure, close location, and volume participation.
6. Project a concept-native reaction zone from the wedge width.
7. Display a clean invalidation guide so the structure remains readable after the break.

This makes the script a wedge lifecycle tool, not a general reversal scanner.

💎 Unique Edge

The most important difference is that the script treats a wedge as a living geometric compression structure. It does not simply connect the latest two highs and lows and call the pattern complete. A candidate must pass span, width, convergence, and slope requirements before it becomes active.

For rising wedges, the script looks for rising pivot highs and rising pivot lows where the lower boundary is climbing faster than the upper boundary. This creates upward compression, which is the core geometry behind a rising wedge. For falling wedges, it looks for falling pivot highs and falling pivot lows where the upper boundary is falling faster than the lower boundary. This creates downward compression, which is the core geometry behind a falling wedge.

That difference matters because many weak wedge tools confuse ordinary channels with wedge compression. This script separates those structures by requiring the final width to be materially smaller than the starting width.

🔹 Methodology

The engine begins with confirmed pivot highs and pivot lows. The user controls the pivot confirmation length, which allows the detector to be tuned for intraday, swing, or higher-timeframe charts.

From the latest confirmed swing pair, the script builds two boundary lines:
- Upper boundary from confirmed pivot highs
- Lower boundary from confirmed pivot lows

The detector then evaluates:
- Pattern span in bars
- Initial boundary width measured against ATR
- Final boundary width relative to the starting width
- Upper boundary slope
- Lower boundary slope
- Correct rising-wedge or falling-wedge geometry

Only when those requirements align does the pattern become an active wedge.

🔸 Break Quality Model

A wedge break is scored only after the reversal-side boundary is broken. The break quality score is built from multiple factors:
- Wedge maturity
- Distance beyond the broken boundary
- Candle body participation
- Close location inside the break candle
- Volume ratio versus recent average volume

The score is translated into a simple grade so the chart stays easy to read. This does not claim that a break must continue. It gives the user a structured read of how strong the confirmed break appears under the script's own rules.

🎯 Projected Reaction Zone

After a confirmed wedge reversal break, the script projects a reaction zone using the initial wedge width. This zone is not a generic support/resistance box. It is tied directly to the wedge geometry and appears only after the structure confirms. The goal is to show the next area where price may naturally react after escaping the compression.

The zone width and projection length are configurable, so users can keep the chart compact or allow more forward context depending on timeframe and style.

🧭 Invalidation Context

The script also draws an invalidation guide after a confirmed break. For a bullish falling-wedge break, invalidation is tracked below the opposite wedge boundary with an ATR buffer. For a bearish rising-wedge break, invalidation is tracked above the opposite wedge boundary with an ATR buffer.

This keeps the post-break structure organized without adding trade instructions or turning the script into a strategy.

📊 Panel

The compact AGPro panel summarizes the current wedge lifecycle:
- Wedge Type
- Maturity
- Break Quality
- Target Zone

Panel location, panel theme, and panel font size are adjustable from settings. The first panel row uses the AGPro standard: one merged blue header row containing only the panel title.

⚙️ Key Settings

- Pivot Confirmation Length controls how strict the swing structure is.
- Minimum Wedge Span filters out tiny patterns.
- Maximum Final Width Ratio controls how much convergence is required.
- Developing Wedge Preview Ratio controls how early dashed formation boundaries can appear.
- Wedge Radar controls the latest-window visual radar that prevents panel-only charts while waiting for confirmed wedge geometry.
- Radar Projection Bars limits how far radar boundaries extend into future bars.
- Radar Fill Threshold keeps low-compression radar structures from creating oversized filled areas.
- Boundary Tags add compact right-side rail annotations so the structure is easier to read without covering candles.
- Compression Tag shows one status label for radar compression or armed-wedge maturity.
- Boundary Break Buffer ATR adds confirmation distance beyond the wedge boundary.
- Volume Confirmation Ratio contributes to break quality scoring.
- Projection Length Bars controls how long the reaction zone extends forward.
- Label Font Size and Label Offset ATR help maintain a clean chart presentation.

🧩 How It Differs From Other AGPro Tools

This script is intentionally separate from AGPro channel, breakout, liquidity, and broad reversal tools.

It is not a channel map. Channel tools organize parallel or multi-family structure. Wedge Reversal Detector only studies converging wedge geometry.

It is not a double top or double bottom detector. Those patterns are based on repeated horizontal rejection and neckline behavior. This script is based on converging diagonal boundaries.

It is not a broad reversal scanner. It does not combine every reversal pattern into one dashboard. It stays focused on wedge compression, wedge maturity, reversal break, projected reaction zone, and invalidation.

It is not a generic breakout quality tool. Break quality is evaluated only after a valid rising or falling wedge exists.

🔔 Alerts

The script includes alerts for:
- Bullish falling wedge break
- Bearish rising wedge break
- High quality wedge break
- Wedge invalidation

These alerts are event notifications for the detected structure, not automated trading instructions.

✨ Best Use Case

Wedge Reversal Detector is best suited for traders who already watch chart patterns, market structure, compression, and failed trend continuation. It helps reduce manual drawing by highlighting qualified wedge structures, then keeping the chart organized through the confirmation, projection, and invalidation phases.

The result is a clean, premium, wedge-specific workflow designed for public chart reading: fewer random lines, fewer noisy labels, and a clearer view of whether the wedge structure is still forming, breaking, projecting, or invalidating.

## Source Code

````pine
// -------------------------------------------------
// Wedge Reversal Detector [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.1
//
// Wedge Reversal Detector identifies rising wedge and falling wedge chart
// patterns by scanning combinations of recent confirmed pivots, grades
// wedge maturity through convergence pressure, confirms reversal breaks,
// and projects a clean reaction zone. A cumulative Break Outcome engine
// then measures, on this chart and timeframe, how often confirmed wedge
// reversal breaks actually reached their projected reaction zone before
// invalidation, and a clear state machine (Scanning, Developing, Armed,
// Break Active, Target Hit, Invalidated, Expired) with a next-action line turns
// the pattern map into a decision tool. The script focuses on wedge
// boundaries, break quality, invalidation, and target-zone context
// without becoming a broad pattern scanner. Version 2.1 hardens confirmed-break
// registration and synchronizes projected references with filled identity badges.
// -------------------------------------------------

//@version=6
indicator("Wedge Reversal Detector [AGPro Series]",
     shorttitle = "AG Pro WRD",
     overlay = true,
     max_lines_count = 120,
     max_labels_count = 120,
     max_boxes_count = 60)

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

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupDetection = "Detection Engine"
pivotLen = input.int(6, "Pivot Confirmation Length", minval = 3, maxval = 20, group = groupDetection, tooltip = "Number of bars used on each side to confirm wedge swing highs and swing lows. Higher values create slower but cleaner structures.")
minPatternBars = input.int(24, "Minimum Wedge Span", minval = 12, maxval = 180, group = groupDetection, tooltip = "Minimum distance in bars between the first and last confirmed pivots used to qualify a wedge.")
maxCandidateAge = input.int(90, "Candidate Expiry Bars", minval = 20, maxval = 300, group = groupDetection, tooltip = "Maximum number of bars after the latest wedge pivot during which a candidate can still confirm a reversal break.")
minStartWidthAtr = input.float(0.90, "Minimum Starting Width ATR", minval = 0.20, maxval = 8.00, step = 0.10, group = groupDetection, tooltip = "Minimum initial distance between the upper and lower wedge boundaries, measured in ATR. This prevents tiny structures from being treated as meaningful wedges.")
maxEndWidthRatio = input.float(0.78, "Maximum Final Width Ratio", minval = 0.20, maxval = 0.95, step = 0.01, group = groupDetection, tooltip = "Maximum final width divided by initial width. Lower values require stronger convergence before a wedge becomes valid.")
previewWidthRatio = input.float(0.92, "Developing Wedge Preview Ratio", minval = 0.50, maxval = 0.99, step = 0.01, group = groupDetection, tooltip = "Looser convergence ratio used only for drawing developing wedge boundaries before a full reversal-break candidate is armed.")

groupRadar = "Wedge Radar"
showRadar = input.bool(true, "Show Wedge Radar", group = groupRadar, tooltip = "Displays a lightweight latest-window wedge radar when no strict wedge candidate is active, so the chart does not become panel-only while the engine waits for a confirmed structure.")
radarLookback = input.int(72, "Radar Lookback Bars", minval = 24, maxval = 240, group = groupRadar, tooltip = "Number of recent bars used to draw the lightweight wedge radar boundaries.")
radarProjectionBars = input.int(24, "Radar Projection Bars", minval = 0, maxval = 120, group = groupRadar, tooltip = "Number of bars the radar boundaries extend beyond the current bar. Smaller values keep higher-timeframe charts cleaner.")
radarOpacity = input.int(20, "Radar Line Transparency", minval = 0, maxval = 85, group = groupRadar, tooltip = "Transparency applied to the radar boundary lines. Lower values make the radar more visible.")
radarFillThreshold = input.int(18, "Radar Fill Threshold", minval = 0, maxval = 80, group = groupRadar, tooltip = "Minimum radar compression score required before the radar area is filled. Low-compression radar states keep only boundary lines.")

groupBreak = "Break Confirmation"
requireCloseBreak = input.bool(true, "Require Close Beyond Boundary", group = groupBreak, tooltip = "When enabled, wedge reversal breaks require a close beyond the relevant boundary instead of only an intrabar penetration.")
breakBufferAtr = input.float(0.08, "Boundary Break Buffer ATR", minval = 0.00, maxval = 1.00, step = 0.01, group = groupBreak, tooltip = "Additional ATR buffer beyond the wedge boundary required for break confirmation.")
volumeMultiplier = input.float(1.05, "Volume Confirmation Ratio", minval = 0.50, maxval = 3.00, step = 0.05, group = groupBreak, tooltip = "Volume ratio used in the break quality score. It is not a hard filter; it only improves or reduces the quality rating.")
breakCooldownBars = input.int(12, "Break Label Cooldown", minval = 1, maxval = 100, group = groupBreak, tooltip = "Minimum bar distance between reversal break labels. This keeps event labels restrained in choppy conditions.")

groupProjection = "Reaction Zone"
showReactionZone = input.bool(true, "Show Projected Reaction Zone", group = groupProjection, tooltip = "Projects a target reaction zone after a confirmed wedge reversal break using the initial wedge width. Every visible zone includes a centered filled state badge.")
targetWidthMultiplier = input.float(0.40, "Target Width Multiplier", minval = 0.25, maxval = 2.00, step = 0.05, group = groupProjection, tooltip = "Multiplier applied to the initial wedge width to estimate the center of the projected reaction zone. The default is calibrated to a reachable first-reaction distance; full wedge-height projections are rarely reached before invalidation and can be selected manually.")
targetHalfWidthAtr = input.float(0.35, "Reaction Zone Half Width ATR", minval = 0.05, maxval = 2.00, step = 0.05, group = groupProjection, tooltip = "Half-width of the projected reaction zone, measured in ATR around the target center.")
projectionBars = input.int(36, "Projection Length Bars", minval = 10, maxval = 160, group = groupProjection, tooltip = "Number of bars the projected reaction zone and invalidation guide extend into the future. This is also the resolution window used by the Break Outcome statistics.")
invalidationBufferAtr = input.float(0.12, "Invalidation Buffer ATR", minval = 0.00, maxval = 1.00, step = 0.01, group = groupProjection, tooltip = "ATR buffer added beyond the opposite wedge boundary to define the invalidation guide after a confirmed break.")

groupVisual = "Visual Controls"
showWedgeFill = input.bool(true, "Show Wedge Fill", group = groupVisual, tooltip = "Displays a subtle fill between the active wedge boundaries for better chart readability.")
showInvalidationGuide = input.bool(true, "Show Invalidation Guide", group = groupVisual, tooltip = "Draws a horizontal invalidation guide with a paired filled reference badge after a confirmed wedge reversal break.")
showOutcomeMarks = input.bool(true, "Show Zone Hit Marks", group = groupVisual, tooltip = "Marks the bar where a projected reaction zone is first reached after a confirmed break. These marks are the visual trace of the Break Outcome statistics.")
maxStoredEvents = input.int(8, "Maximum Stored Events", minval = 2, maxval = 30, group = groupVisual, tooltip = "Maximum number of historical reaction zones, invalidation guides, and event labels kept on the chart.")
showBoundaryTags = input.bool(true, "Show Boundary Tags", group = groupVisual, tooltip = "Adds compact premium labels to the right side of active wedge or radar boundaries so the rails are easier to interpret without cluttering candles.")
showCompressionTag = input.bool(true, "Show Compression Tag", group = groupVisual, tooltip = "Shows one small status label near the radar or wedge midpoint with the current compression or maturity score.")
labelOffsetAtr = input.float(0.70, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupVisual, tooltip = "ATR-based distance used to keep wedge labels away from candle bodies and wicks.")
labelFontInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual, tooltip = "Controls the size of event labels. Normal is the publication-ready default.")

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = "Shows or hides the AGPro wedge lifecycle panel. The panel is visible by default.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = groupPanel, tooltip = "Selects where the wedge summary panel appears on the chart.")
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = "Controls the summary panel color theme.")
panelFontInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = "Controls panel text size. Normal is the default for a balanced public chart.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(value, maxValue))

f_line_y(int x1, float y1, int x2, float y2, int x) =>
    x2 == x1 ? y2 : y1 + (y2 - y1) * (float(x - x1) / float(x2 - x1))

f_slope(int x1, float y1, int x2, float y2) =>
    x2 == x1 ? 0.0 : (y2 - y1) / float(x2 - x1)

f_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_position(string positionInput) =>
    switch positionInput
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_grade(float score) =>
    string result = "D"
    if score >= 82.0
        result := "A+"
    else if score >= 72.0
        result := "A"
    else if score >= 60.0
        result := "B"
    else if score >= 48.0
        result := "C"
    result

f_maturity(float score) =>
    string result = "Early"
    if score >= 78.0
        result := "Compressed"
    else if score >= 62.0
        result := "Mature"
    else if score >= 45.0
        result := "Developing"
    result

f_trim_boxes(array<box> boxes, int maxItems) =>
    if array.size(boxes) > maxItems
        box oldestBox = array.shift(boxes)
        box.delete(oldestBox)

f_trim_lines(array<line> lines, int maxItems) =>
    if array.size(lines) > maxItems
        line oldestLine = array.shift(lines)
        line.delete(oldestLine)

f_trim_labels(array<label> labels, int maxItems) =>
    if array.size(labels) > maxItems
        label oldestLabel = array.shift(labels)
        label.delete(oldestLabel)

f_upsert_tag(label tag, int x, float y, string tagText, color bgColor, color textColor, string sizeInput) =>
    label result = tag
    if na(result)
        result := label.new(
             x,
             y,
             tagText,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_left,
             color = bgColor,
             textcolor = textColor,
             size = f_size(sizeInput))
    else
        label.set_xy(result, x, y)
        label.set_text(result, tagText)
        label.set_color(result, bgColor)
        label.set_textcolor(result, textColor)
        label.set_size(result, f_size(sizeInput))
    result

// Break Outcome display helpers. Color follows the same rounded rate
// shown in the panel text, and is applied only once the sample size is
// sufficient (n >= 5); below that, the value stays neutral so a small
// sample never implies confidence.
f_hitText(int w, int n) =>
    n > 0 ? str.tostring(math.round(100.0 * w / n)) + "%  (n=" + str.tostring(n) + ")" : "-  (n=0)"

f_hitColor(int w, int n, color fb) =>
    r = n > 0 ? math.round(100.0 * w / n) : 0
    n >= 5 ? (r >= 55 ? bullColor : r >= 40 ? neutralColor : bearColor) : fb

// -------------------------------------------------
// Market Context
// -------------------------------------------------
atr = ta.atr(14)
volumeAverage = ta.sma(volume, 20)
volumeRatio = not na(volumeAverage) and volumeAverage > 0.0 ? volume / volumeAverage : 1.0
barRange = math.max(high - low, syminfo.mintick)
bodyRange = math.abs(close - open)

// Recent price band used to keep tags and rail projections on a sane
// vertical scale. Anything drawn outside this band would distort the
// chart's auto-scale without adding information.
hi100 = ta.highest(high, 100)
lo100 = ta.lowest(low, 100)
f_clampY(float y) =>
    f_clamp(y, lo100 - atr * 2.0, hi100 + atr * 2.0)

pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)

// -------------------------------------------------
// PIVOT RING BUFFERS
// The detector keeps the most recent confirmed swing highs and swing
// lows and scans pivot-pair combinations, instead of looking only at
// the single latest pair. This finds real wedges that older pivots
// define while newer minor pivots print inside the structure.
// -------------------------------------------------
int maxPivots = 6
var array<float> phVal = array.new<float>()
var array<int>   phIdx = array.new<int>()
var array<float> plVal = array.new<float>()
var array<int>   plIdx = array.new<int>()

if not na(pivotHigh)
    array.push(phVal, pivotHigh)
    array.push(phIdx, bar_index - pivotLen)
    if array.size(phVal) > maxPivots
        array.shift(phVal)
        array.shift(phIdx)

if not na(pivotLow)
    array.push(plVal, pivotLow)
    array.push(plIdx, bar_index - pivotLen)
    if array.size(plVal) > maxPivots
        array.shift(plVal)
        array.shift(plIdx)

// -------------------------------------------------
// WEDGE SELECTION SCAN
// Runs only on bars where a new pivot confirms. Every pair of stored
// highs is combined with every pair of stored lows; geometry, span,
// width, and convergence are validated, and the best candidate wins:
// strict candidates first, then highest maturity, then recency.
// -------------------------------------------------
var bool   selValid = false
var bool   selStrict = false
var string selType = "None"
var int    selH1x = na
var int    selH2x = na
var int    selL1x = na
var int    selL2x = na
var float  selH1v = na
var float  selH2v = na
var float  selL1v = na
var float  selL2v = na
var float  selMaturity = 0.0
var float  selStartWidth = na
var int    selEnd = na

bool newPivot = not na(pivotHigh) or not na(pivotLow)
int previewSpanMin = math.max(10, int(math.round(float(minPatternBars) * 0.55)))
float previewWidthMin = atr * math.max(0.35, minStartWidthAtr * 0.45)

if newPivot and array.size(phVal) >= 2 and array.size(plVal) >= 2 and not na(atr) and atr > 0.0
    float bestRank = na
    bool   bStrict = false
    string bType = "None"
    int    bH1x = na
    int    bH2x = na
    int    bL1x = na
    int    bL2x = na
    float  bH1v = na
    float  bH2v = na
    float  bL1v = na
    float  bL2v = na
    float  bMat = 0.0
    float  bSW = na
    int    bEnd = na

    int nh = array.size(phVal)
    int nl = array.size(plVal)
    for i = 0 to nh - 2
        for j = i + 1 to nh - 1
            int h1x = array.get(phIdx, i)
            int h2x = array.get(phIdx, j)
            float h1v = array.get(phVal, i)
            float h2v = array.get(phVal, j)
            float hs = f_slope(h1x, h1v, h2x, h2v)
            for k = 0 to nl - 2
                for l = k + 1 to nl - 1
                    int l1x = array.get(plIdx, k)
                    int l2x = array.get(plIdx, l)
                    int wEnd = math.max(h2x, l2x)
                    int wStart = math.min(h1x, l1x)
                    int span = wEnd - wStart
                    bool freshOK = bar_index - wEnd <= maxCandidateAge
                    bool overlapOK = math.min(h2x, l2x) > math.max(h1x, l1x)
                    if freshOK and overlapOK and span >= previewSpanMin
                        float l1v = array.get(plVal, k)
                        float l2v = array.get(plVal, l)
                        float ls = f_slope(l1x, l1v, l2x, l2v)
                        bool ris = hs > 0.0 and ls > 0.0 and ls > hs
                        bool fal = hs < 0.0 and ls < 0.0 and hs < ls
                        if ris or fal
                            float uS = f_line_y(h1x, h1v, h2x, h2v, wStart)
                            float lS = f_line_y(l1x, l1v, l2x, l2v, wStart)
                            float uE = f_line_y(h1x, h1v, h2x, h2v, wEnd)
                            float lE = f_line_y(l1x, l1v, l2x, l2v, wEnd)
                            float sW = uS - lS
                            float eW = uE - lE
                            if sW > 0.0 and eW > syminfo.mintick
                                float wr = eW / sW
                                // A wedge must be a sloped structure: the
                                // midline has to travel a meaningful ATR
                                // distance, otherwise flat noise pairs
                                // would qualify as patterns.
                                float travel = math.abs((uE + lE) * 0.5 - (uS + lS) * 0.5)
                                bool previewTravelOK = travel >= atr * 0.6
                                if sW >= previewWidthMin and wr <= previewWidthRatio and previewTravelOK
                                    // Fifth-touch validation for strict
                                    // candidates: at least one additional
                                    // stored pivot (beyond the four that
                                    // define the rails) must sit on one of
                                    // the rails. Real wedges are touched
                                    // repeatedly; arbitrary pivot pairs
                                    // are not.
                                    int extraTouches = 0
                                    for p = 0 to nh - 1
                                        if p != i and p != j
                                            int px = array.get(phIdx, p)
                                            if px >= wStart and px <= wEnd
                                                float pv = array.get(phVal, p)
                                                float railY = f_line_y(h1x, h1v, h2x, h2v, px)
                                                if math.abs(pv - railY) <= atr * 0.35
                                                    extraTouches += 1
                                    for q = 0 to nl - 1
                                        if q != k and q != l
                                            int qx = array.get(plIdx, q)
                                            if qx >= wStart and qx <= wEnd
                                                float qv = array.get(plVal, q)
                                                float railY2 = f_line_y(l1x, l1v, l2x, l2v, qx)
                                                if math.abs(qv - railY2) <= atr * 0.35
                                                    extraTouches += 1
                                    bool strictOK = span >= minPatternBars and sW >= atr * minStartWidthAtr and wr <= maxEndWidthRatio and travel >= atr * 1.2 and extraTouches >= 1
                                    float comp = f_clamp((1.0 - wr) * 120.0, 0.0, 100.0)
                                    float spn = f_clamp(float(span) / float(minPatternBars) * 55.0, 0.0, 100.0)
                                    float mat = f_clamp(comp * 0.58 + spn * 0.42, 0.0, 100.0)
                                    float rank = (strictOK ? 1000000000.0 : 0.0) + mat * 10000.0 + float(wEnd)
                                    if na(bestRank) or rank > bestRank
                                        bestRank := rank
                                        bStrict := strictOK
                                        bType := ris ? "Rising Wedge" : "Falling Wedge"
                                        bH1x := h1x
                                        bH2x := h2x
                                        bL1x := l1x
                                        bL2x := l2x
                                        bH1v := h1v
                                        bH2v := h2v
                                        bL1v := l1v
                                        bL2v := l2v
                                        bMat := mat
                                        bSW := sW
                                        bEnd := wEnd

    if not na(bestRank)
        selValid := true
        selStrict := bStrict
        selType := bType
        selH1x := bH1x
        selH2x := bH2x
        selL1x := bL1x
        selL2x := bL2x
        selH1v := bH1v
        selH2v := bH2v
        selL1v := bL1v
        selL2v := bL2v
        selMaturity := bMat
        selStartWidth := bSW
        selEnd := bEnd

// -------------------------------------------------
// Active Wedge Drawing State
// -------------------------------------------------
// Break Outcome tracker state is declared here because the candidate
// lock and the expiry rule below depend on whether an episode is open.
var bool  trkOn = false
var int   trkDir = 0
var float trkTop = na
var float trkBottom = na
var float trkInval = na
var int   trkStart = na
var int   trkWindow = 0
var int   zoneWins = 0
var int   zoneN = 0
var int   lastResolveBar = na

var line activeUpperLine = na
var line activeLowerLine = na
var linefill activeFill = na
var string activeType = "None"
var int activeHigh1Idx = na
var int activeHigh2Idx = na
var int activeLow1Idx = na
var int activeLow2Idx = na
var float activeHigh1Val = na
var float activeHigh2Val = na
var float activeLow1Val = na
var float activeLow2Val = na
var float activeMaturityScore = 0.0
var float activeStartWidth = na
var bool activeStrict = false
var bool activeBroken = false
var bool activeInvalidated = false
var bool activeTargetHit = false
var bool activeWindowExpired = false
var int activeBreakDir = 0
var float activeInvalidationLevel = na
var float activeTargetLow = na
var float activeTargetHigh = na
var float activeBreakQuality = na
var int lastBreakBar = na
var array<line> formationLines = array.new_line()
var line radarUpperLine = na
var line radarLowerLine = na
var linefill radarFill = na
var string radarState = "Off"
var float radarCompression = na
var label upperRailTag = na
var label lowerRailTag = na
var label compressionTag = na

bool drawableCandidateRaw = selValid and selType != "None" and not na(selEnd) and bar_index - selEnd <= maxCandidateAge
// Containment gate: a candidate may only activate while price is still
// INSIDE its rails (with a small ATR tolerance). This prevents stale
// structures from arming after price has already left them, which
// would produce an instant, meaningless "break" on the activation bar.
float candUpperNow = drawableCandidateRaw ? f_line_y(selH1x, selH1v, selH2x, selH2v, bar_index) : na
float candLowerNow = drawableCandidateRaw ? f_line_y(selL1x, selL1v, selL2x, selL2v, bar_index) : na
bool priceInsideCand = not na(candUpperNow) and not na(candLowerNow) and close <= candUpperNow + atr * 0.25 and close >= candLowerNow - atr * 0.25
bool drawableCandidate = drawableCandidateRaw and priceInsideCand
// Break lock: while a confirmed break is being tracked toward its
// target zone, the active wedge cannot be replaced. The lock releases
// when the episode resolves (zone hit, invalidation, or window end).
bool lockActive = activeBroken and trkOn
// Re-arm cooldown: after an episode resolves, no new candidate may
// activate for the cooldown distance. This prevents a near-identical
// structure from immediately re-arming and re-breaking.
bool rearmReady = na(lastResolveBar) or bar_index - lastResolveBar >= breakCooldownBars
// NOTE: comparison against the active pivot set is na-safe. Comparing an
// int against na with != yields na (treated as false), which in the
// previous version silently prevented the very first candidate from ever
// arming. The sameAsActive guard below fixes that.
bool sameAsActive = not na(activeHigh1Idx) and selH1x == activeHigh1Idx and selH2x == activeHigh2Idx and selL1x == activeLow1Idx and selL2x == activeLow2Idx
bool candidateChanged = drawableCandidate and not sameAsActive and not lockActive and rearmReady

if candidateChanged
    // Retire the previous rails. Rails of a wedge that produced a
    // confirmed break are frozen in place and faded as historical
    // context; rails of a replaced developing wedge are removed so the
    // chart never accumulates structure spaghetti.
    if not na(activeUpperLine)
        if activeBroken
            // Frozen rails are clipped near the break bar so historical
            // structures stay where their story ended and never drag
            // the price scale.
            int frzX = not na(lastBreakBar) ? math.min(bar_index, lastBreakBar + 8) : bar_index
            line.set_extend(activeUpperLine, extend.none)
            line.set_xy2(activeUpperLine, frzX, f_line_y(activeHigh1Idx, activeHigh1Val, activeHigh2Idx, activeHigh2Val, frzX))
            line.set_color(activeUpperLine, color.new(panelLabelCol, 60))
            line.set_extend(activeLowerLine, extend.none)
            line.set_xy2(activeLowerLine, frzX, f_line_y(activeLow1Idx, activeLow1Val, activeLow2Idx, activeLow2Val, frzX))
            line.set_color(activeLowerLine, color.new(panelLabelCol, 60))
            array.push(formationLines, activeUpperLine)
            array.push(formationLines, activeLowerLine)
            f_trim_lines(formationLines, maxStoredEvents)
            f_trim_lines(formationLines, maxStoredEvents)
        else
            line.delete(activeUpperLine)
            line.delete(activeLowerLine)
        activeUpperLine := na
        activeLowerLine := na
    if not na(activeFill)
        linefill.delete(activeFill)

    color wedgeColor = selType == "Falling Wedge" ? bullColor : bearColor
    int lineTransparency = selStrict ? 0 : 25
    activeUpperLine := line.new(
         selH1x,
         selH1v,
         selH2x,
         selH2v,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = color.new(wedgeColor, lineTransparency),
         style = selStrict ? line.style_solid : line.style_dashed,
         width = 2)
    activeLowerLine := line.new(
         selL1x,
         selL1v,
         selL2x,
         selL2v,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = color.new(wedgeColor, lineTransparency),
         style = selStrict ? line.style_solid : line.style_dashed,
         width = 2)
    activeFill := showWedgeFill ? linefill.new(activeUpperLine, activeLowerLine, color.new(wedgeColor, selStrict ? 90 : 94)) : na

    activeType := selType
    activeHigh1Idx := selH1x
    activeHigh2Idx := selH2x
    activeLow1Idx := selL1x
    activeLow2Idx := selL2x
    activeHigh1Val := selH1v
    activeHigh2Val := selH2v
    activeLow1Val := selL1v
    activeLow2Val := selL2v
    activeMaturityScore := selMaturity
    activeStartWidth := selStartWidth
    activeStrict := selStrict
    activeBroken := false
    activeInvalidated := false
    activeTargetHit := false
    activeWindowExpired := false
    activeBreakDir := 0
    activeInvalidationLevel := na
    activeTargetLow := na
    activeTargetHigh := na
    activeBreakQuality := na

bool hasActiveWedge = activeType != "None" and not na(activeHigh1Idx) and not na(activeLow1Idx)
int activeEnd = hasActiveWedge ? math.max(activeHigh2Idx, activeLow2Idx) : na
bool activeExpired = hasActiveWedge and not trkOn and bar_index - activeEnd > maxCandidateAge

if activeExpired
    if not na(activeUpperLine)
        if activeBroken
            // Frozen rails are clipped near the break bar so historical
            // structures stay where their story ended and never drag
            // the price scale.
            int frzX = not na(lastBreakBar) ? math.min(bar_index, lastBreakBar + 8) : bar_index
            line.set_extend(activeUpperLine, extend.none)
            line.set_xy2(activeUpperLine, frzX, f_line_y(activeHigh1Idx, activeHigh1Val, activeHigh2Idx, activeHigh2Val, frzX))
            line.set_color(activeUpperLine, color.new(panelLabelCol, 60))
            line.set_extend(activeLowerLine, extend.none)
            line.set_xy2(activeLowerLine, frzX, f_line_y(activeLow1Idx, activeLow1Val, activeLow2Idx, activeLow2Val, frzX))
            line.set_color(activeLowerLine, color.new(panelLabelCol, 60))
            array.push(formationLines, activeUpperLine)
            array.push(formationLines, activeLowerLine)
            f_trim_lines(formationLines, maxStoredEvents)
            f_trim_lines(formationLines, maxStoredEvents)
        else
            line.delete(activeUpperLine)
            line.delete(activeLowerLine)
    activeType := "None"
    activeStrict := false
    activeBroken := false
    activeInvalidated := false
    activeTargetHit := false
    activeWindowExpired := false
    if not na(activeFill)
        linefill.delete(activeFill)
    activeUpperLine := na
    activeLowerLine := na
    activeFill := na

bool liveActiveWedge = activeType != "None" and not na(activeHigh1Idx) and not na(activeLow1Idx)

// Project the ACTIVE rails a bounded number of bars forward. Only the
// live wedge looks into the future, and only by a short distance, so
// historical structures never fan across the chart and steep rails
// never distort the price scale.
int railProjX = bar_index + math.max(2, math.min(radarProjectionBars, 24))
if liveActiveWedge and not na(activeUpperLine)
    line.set_xy2(activeUpperLine, railProjX, f_line_y(activeHigh1Idx, activeHigh1Val, activeHigh2Idx, activeHigh2Val, railProjX))
    line.set_xy2(activeLowerLine, railProjX, f_line_y(activeLow1Idx, activeLow1Val, activeLow2Idx, activeLow2Val, railProjX))

// -------------------------------------------------
// Wedge Radar Fallback
// -------------------------------------------------
int radarHalf = int(math.round(float(radarLookback) * 0.50))
bool radarReady = showRadar and bar_index > radarLookback and radarHalf >= 12
float radarUpperLeft = radarReady ? ta.highest(high[radarHalf], radarHalf) : na
float radarLowerLeft = radarReady ? ta.lowest(low[radarHalf], radarHalf) : na
float radarUpperRight = radarReady ? ta.highest(high, radarHalf) : na
float radarLowerRight = radarReady ? ta.lowest(low, radarHalf) : na
float radarStartWidth = radarReady ? radarUpperLeft - radarLowerLeft : na
float radarEndWidth = radarReady ? radarUpperRight - radarLowerRight : na
float radarWidthRatio = radarReady and radarStartWidth > 0.0 ? radarEndWidth / radarStartWidth : na
float radarUpperSlope = radarReady ? (radarUpperRight - radarUpperLeft) / float(radarLookback) : na
float radarLowerSlope = radarReady ? (radarLowerRight - radarLowerLeft) / float(radarLookback) : na
int radarRightX = bar_index + radarProjectionBars
float radarUpperProjected = radarReady ? radarUpperRight + radarUpperSlope * float(radarProjectionBars) : na
float radarLowerProjected = radarReady ? radarLowerRight + radarLowerSlope * float(radarProjectionBars) : na
bool radarRising = radarReady and radarUpperSlope > 0.0 and radarLowerSlope > 0.0 and radarLowerSlope > radarUpperSlope
bool radarFalling = radarReady and radarUpperSlope < 0.0 and radarLowerSlope < 0.0 and radarUpperSlope < radarLowerSlope
bool radarCompressing = radarReady and radarEndWidth > syminfo.mintick and radarWidthRatio < 1.0

if radarRising and radarCompressing
    radarState := "Rising Radar"
else if radarFalling and radarCompressing
    radarState := "Falling Radar"
else if radarCompressing
    radarState := "Compression Radar"
else if radarReady
    radarState := "Range Radar"
else
    radarState := "Off"
radarCompression := radarReady and not na(radarWidthRatio) ? f_clamp((1.0 - radarWidthRatio) * 100.0, 0.0, 100.0) : na
bool radarFillAllowed = showWedgeFill and radarReady and not na(radarCompression) and radarCompression >= radarFillThreshold

if showRadar and radarReady and not activeStrict
    color radarColor = radarRising ? bearColor : radarFalling ? bullColor : accentColor
    if na(radarUpperLine)
        radarUpperLine := line.new(
             bar_index - radarLookback,
             radarUpperLeft,
             radarRightX,
             radarUpperProjected,
             xloc = xloc.bar_index,
             extend = extend.none,
             color = color.new(radarColor, radarOpacity),
             style = line.style_dashed,
             width = 2)
        radarLowerLine := line.new(
             bar_index - radarLookback,
             radarLowerLeft,
             radarRightX,
             radarLowerProjected,
             xloc = xloc.bar_index,
             extend = extend.none,
             color = color.new(radarColor, radarOpacity),
             style = line.style_dashed,
             width = 2)
        radarFill := radarFillAllowed ? linefill.new(radarUpperLine, radarLowerLine, color.new(radarColor, 95)) : na
    else
        line.set_xy1(radarUpperLine, bar_index - radarLookback, radarUpperLeft)
        line.set_xy2(radarUpperLine, radarRightX, radarUpperProjected)
        line.set_color(radarUpperLine, color.new(radarColor, radarOpacity))
        line.set_xy1(radarLowerLine, bar_index - radarLookback, radarLowerLeft)
        line.set_xy2(radarLowerLine, radarRightX, radarLowerProjected)
        line.set_color(radarLowerLine, color.new(radarColor, radarOpacity))
        if radarFillAllowed and na(radarFill)
            radarFill := linefill.new(radarUpperLine, radarLowerLine, color.new(radarColor, 95))
        if radarFillAllowed and not na(radarFill)
            linefill.set_color(radarFill, color.new(radarColor, 95))
        if not radarFillAllowed and not na(radarFill)
            linefill.delete(radarFill)
            radarFill := na
else
    if not na(radarUpperLine)
        line.delete(radarUpperLine)
        line.delete(radarLowerLine)
    if not na(radarFill)
        linefill.delete(radarFill)
    radarUpperLine := na
    radarLowerLine := na
    radarFill := na

if showWedgeFill and liveActiveWedge and not na(activeUpperLine) and not na(activeLowerLine) and na(activeFill)
    color fillColor = activeType == "Falling Wedge" ? bullColor : bearColor
    activeFill := linefill.new(activeUpperLine, activeLowerLine, color.new(fillColor, 90))

if not showWedgeFill and not na(activeFill)
    linefill.delete(activeFill)
    activeFill := na

// -------------------------------------------------
// Break, Projection, Invalidation
// -------------------------------------------------
var array<box> reactionBoxes = array.new_box()
var array<label> reactionBadges = array.new_label()
var array<line> invalidationLines = array.new_line()
var array<label> invalidationBadges = array.new_label()
var array<label> eventLabels = array.new_label()
var label activeReactionBadge = na
var label activeInvalidationBadge = na

float activeUpperNow = liveActiveWedge ? f_line_y(activeHigh1Idx, activeHigh1Val, activeHigh2Idx, activeHigh2Val, bar_index) : na
float activeLowerNow = liveActiveWedge ? f_line_y(activeLow1Idx, activeLow1Val, activeLow2Idx, activeLow2Val, bar_index) : na
float breakBuffer = atr * breakBufferAtr
bool bullBoundaryBroken = requireCloseBreak ? close > activeUpperNow + breakBuffer : high > activeUpperNow + breakBuffer
bool bearBoundaryBroken = requireCloseBreak ? close < activeLowerNow - breakBuffer : low < activeLowerNow - breakBuffer

// -------------------------------------------------
// BREAK OUTCOME ENGINE (cumulative, non-repaint)
// Every confirmed wedge reversal break opens one tracking episode with
// the target zone, invalidation level, and resolution window frozen at
// the break bar. The episode resolves as a ZONE HIT when price first
// reaches the projected reaction zone, and as a MISS when the
// invalidation level is closed through first or the projection window
// expires without contact. If a zone touch and an invalidation close
// occur on the same bar, the touch is counted, because the projected
// reaction is judged at first contact. Episodes resolve on confirmed
// bars only, so the statistic never repaints. Tracker state variables
// are declared above the Active Wedge section.
// -------------------------------------------------
bool zoneHitEv = false

if trkOn and barstate.isconfirmed
    bool zoneTouched = trkDir == 1 ? high >= trkBottom : low <= trkTop
    bool invalClosed = trkDir == 1 ? close < trkInval : close > trkInval
    bool windowOver = not na(trkStart) and bar_index - trkStart >= trkWindow
    if zoneTouched
        zoneN += 1
        zoneWins += 1
        trkOn := false
        lastResolveBar := bar_index
        zoneHitEv := true
        if activeBroken
            activeTargetHit := true
            activeWindowExpired := false
        if not na(activeReactionBadge)
            label.set_text(activeReactionBadge, "ZONE HIT")
            label.set_color(activeReactionBadge, trkDir == 1 ? bullColor : bearColor)
            label.set_textcolor(activeReactionBadge, color.rgb(15, 23, 42))
        if showOutcomeMarks
            float hitLabelPrice = trkDir == 1 ? high + atr * labelOffsetAtr * 0.60 : low - atr * labelOffsetAtr * 0.60
            label hitLabel = label.new(
                 bar_index,
                 hitLabelPrice,
                 "Zone Hit",
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 style = trkDir == 1 ? label.style_label_down : label.style_label_up,
                 color = color.new(trkDir == 1 ? bullColor : bearColor, 0),
                 textcolor = color.rgb(15, 23, 42),
                 size = f_size(labelFontInput))
            array.push(eventLabels, hitLabel)
            f_trim_labels(eventLabels, maxStoredEvents)
    else if invalClosed or windowOver
        zoneN += 1
        trkOn := false
        lastResolveBar := bar_index
        if activeBroken
            activeWindowExpired := windowOver and not invalClosed
        if not na(activeReactionBadge)
            label.set_text(activeReactionBadge, invalClosed ? "ZONE MISSED" : "ZONE EXPIRED")
        if not na(activeInvalidationBadge)
            label.set_text(activeInvalidationBadge, invalClosed ? "INVALIDATED" : "WINDOW CLOSED")

// -------------------------------------------------
// Premium Boundary Tags
// -------------------------------------------------
int tagForwardBars = math.max(2, math.min(radarProjectionBars, 24))
int activeTagX = bar_index + tagForwardBars
float activeUpperTagY = liveActiveWedge ? f_line_y(activeHigh1Idx, activeHigh1Val, activeHigh2Idx, activeHigh2Val, activeTagX) : na
float activeLowerTagY = liveActiveWedge ? f_line_y(activeLow1Idx, activeLow1Val, activeLow2Idx, activeLow2Val, activeTagX) : na
bool showActiveTags = showBoundaryTags and liveActiveWedge
bool showRadarTags = showBoundaryTags and not liveActiveWedge and showRadar and radarReady

if showActiveTags
    color activeTagColor = activeType == "Falling Wedge" ? bullColor : bearColor
    string upperText = activeStrict and activeType == "Rising Wedge" ? "Invalidation Rail" : activeStrict and activeType == "Falling Wedge" ? "Break Rail" : "Upper Wedge Rail"
    string lowerText = activeStrict and activeType == "Rising Wedge" ? "Break Rail" : activeStrict and activeType == "Falling Wedge" ? "Invalidation Rail" : "Lower Wedge Rail"
    string statusText = (activeStrict ? "Armed Wedge" : "Developing Wedge") + " | M " + str.tostring(math.round(activeMaturityScore))
    upperRailTag := f_upsert_tag(upperRailTag, activeTagX, f_clampY(activeUpperTagY + atr * 0.16), upperText, color.new(activeTagColor, 8), color.white, labelFontInput)
    lowerRailTag := f_upsert_tag(lowerRailTag, activeTagX, f_clampY(activeLowerTagY - atr * 0.16), lowerText, color.new(activeTagColor, 8), color.white, labelFontInput)
    if showCompressionTag
        compressionTag := f_upsert_tag(compressionTag, activeTagX, f_clampY((activeUpperTagY + activeLowerTagY) * 0.50), statusText, color.new(panelBg, 0), panelValueCol, labelFontInput)
else if showRadarTags
    color radarTagColor = radarRising ? bearColor : radarFalling ? bullColor : accentColor
    string upperText = radarRising ? "Upper Rejection Rail" : radarFalling ? "Upper Compression Rail" : "Upper Range Rail"
    string lowerText = radarRising ? "Lower Compression Rail" : radarFalling ? "Lower Reclaim Rail" : "Lower Range Rail"
    string statusText = radarState + " | C " + str.tostring(math.round(radarCompression))
    upperRailTag := f_upsert_tag(upperRailTag, radarRightX, f_clampY(radarUpperProjected + atr * 0.16), upperText, color.new(radarTagColor, 8), color.white, labelFontInput)
    lowerRailTag := f_upsert_tag(lowerRailTag, radarRightX, f_clampY(radarLowerProjected - atr * 0.16), lowerText, color.new(radarTagColor, 8), color.white, labelFontInput)
    if showCompressionTag
        compressionTag := f_upsert_tag(compressionTag, radarRightX, f_clampY((radarUpperProjected + radarLowerProjected) * 0.50), statusText, color.new(panelBg, 0), panelValueCol, labelFontInput)
else
    if not na(upperRailTag)
        label.delete(upperRailTag)
    if not na(lowerRailTag)
        label.delete(lowerRailTag)
    if not na(compressionTag)
        label.delete(compressionTag)
    upperRailTag := na
    lowerRailTag := na
    compressionTag := na

if not showCompressionTag and not na(compressionTag)
    label.delete(compressionTag)
    compressionTag := na

bool bullBreakRaw = liveActiveWedge and activeStrict and activeType == "Falling Wedge" and not activeBroken and not activeInvalidated and bar_index > activeEnd and bullBoundaryBroken
bool bearBreakRaw = liveActiveWedge and activeStrict and activeType == "Rising Wedge" and not activeBroken and not activeInvalidated and bar_index > activeEnd and bearBoundaryBroken
bool cooldownReady = na(lastBreakBar) or bar_index - lastBreakBar >= breakCooldownBars
bool bullBreak = bullBreakRaw and cooldownReady and barstate.isconfirmed
bool bearBreak = bearBreakRaw and cooldownReady and barstate.isconfirmed
bool anyBreak = bullBreak or bearBreak

if anyBreak
    int direction = bullBreak ? 1 : -1
    float breakBoundary = bullBreak ? activeUpperNow : activeLowerNow
    float breakDistance = math.abs(close - breakBoundary)
    float distanceScore = f_clamp((breakDistance / atr) * 22.0, 0.0, 22.0)
    float bodyScore = f_clamp((bodyRange / barRange) * 18.0, 0.0, 18.0)
    float closePosition = bullBreak ? (close - low) / barRange : (high - close) / barRange
    float closeScore = f_clamp(closePosition * 18.0, 0.0, 18.0)
    float volumeScore = f_clamp((volumeRatio / volumeMultiplier) * 17.0, 0.0, 17.0)
    float qualityScore = f_clamp(activeMaturityScore * 0.25 + distanceScore + bodyScore + closeScore + volumeScore, 0.0, 100.0)
    float targetCenter = close + direction * activeStartWidth * targetWidthMultiplier
    float targetHalfWidth = atr * targetHalfWidthAtr
    float zoneTop = targetCenter + targetHalfWidth
    float zoneBottom = targetCenter - targetHalfWidth
    float invalidationLevel = direction == 1 ? activeLowerNow - atr * invalidationBufferAtr : activeUpperNow + atr * invalidationBufferAtr
    color eventColor = direction == 1 ? bullColor : bearColor
    float labelPrice = direction == 1 ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr
    string labelText = (direction == 1 ? "Falling Wedge Break" : "Rising Wedge Break") + "\nQ " + str.tostring(math.round(qualityScore)) + " | " + f_grade(qualityScore)

    activeBroken := true
    activeWindowExpired := false
    activeBreakDir := direction
    activeInvalidationLevel := invalidationLevel
    activeTargetLow := zoneBottom
    activeTargetHigh := zoneTop
    activeBreakQuality := qualityScore
    lastBreakBar := bar_index
    activeReactionBadge := na
    activeInvalidationBadge := na

    // Open a Break Outcome episode. If a previous episode is somehow
    // still unresolved, it is closed as a miss first, so every break
    // is counted exactly once.
    if barstate.isconfirmed
        if trkOn
            zoneN += 1
            trkOn := false
        trkOn := true
        trkDir := direction
        trkTop := zoneTop
        trkBottom := zoneBottom
        trkInval := invalidationLevel
        trkStart := bar_index
        trkWindow := projectionBars

    label breakLabel = label.new(
         bar_index,
         labelPrice,
         labelText,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = direction == 1 ? label.style_label_up : label.style_label_down,
         color = color.new(eventColor, 0),
         textcolor = color.white,
         size = f_size(labelFontInput))
    array.push(eventLabels, breakLabel)
    f_trim_labels(eventLabels, maxStoredEvents)

    if showReactionZone
        box reactionBox = box.new(
             left = bar_index,
             top = zoneTop,
             right = bar_index + projectionBars,
             bottom = zoneBottom,
             xloc = xloc.bar_index,
             bgcolor = color.new(eventColor, 86),
             border_color = color.new(eventColor, 20),
             border_width = 1)
        int reactionBadgeX = bar_index + int(math.floor(projectionBars * 0.5))
        float reactionBadgeY = (zoneTop + zoneBottom) * 0.5
        label reactionBadge = label.new(
             reactionBadgeX,
             reactionBadgeY,
             direction == 1 ? "BULL TARGET ZONE" : "BEAR TARGET ZONE",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_center,
             color = eventColor,
             textcolor = color.rgb(15, 23, 42),
             size = f_size(labelFontInput),
             textalign = text.align_center,
             tooltip = "Projected reaction zone derived from confirmed wedge geometry.")
        array.push(reactionBoxes, reactionBox)
        array.push(reactionBadges, reactionBadge)
        activeReactionBadge := reactionBadge
        while array.size(reactionBoxes) > maxStoredEvents
            box oldReactionBox = array.shift(reactionBoxes)
            label oldReactionBadge = array.shift(reactionBadges)
            box.delete(oldReactionBox)
            label.delete(oldReactionBadge)

    if showInvalidationGuide
        line invalidationLine = line.new(
             bar_index,
             invalidationLevel,
             bar_index + projectionBars,
             invalidationLevel,
             xloc = xloc.bar_index,
             extend = extend.none,
             color = color.new(neutralColor, 10),
             style = line.style_dashed,
             width = 1)
        label invalidationBadge = label.new(
             bar_index + projectionBars,
             invalidationLevel,
             "INVALIDATION",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_left,
             color = neutralColor,
             textcolor = color.rgb(15, 23, 42),
             size = f_size(labelFontInput),
             tooltip = "Post-break invalidation reference derived from the opposite wedge boundary.")
        array.push(invalidationLines, invalidationLine)
        array.push(invalidationBadges, invalidationBadge)
        activeInvalidationBadge := invalidationBadge
        while array.size(invalidationLines) > maxStoredEvents
            line oldInvalidationLine = array.shift(invalidationLines)
            label oldInvalidationBadge = array.shift(invalidationBadges)
            line.delete(oldInvalidationLine)
            label.delete(oldInvalidationBadge)

bool invalidatedAfterBreak = activeBroken and not activeInvalidated and barstate.isconfirmed and ((activeBreakDir == 1 and close < activeInvalidationLevel) or (activeBreakDir == -1 and close > activeInvalidationLevel))

if invalidatedAfterBreak
    activeInvalidated := true
    activeWindowExpired := false
    if not na(activeInvalidationBadge)
        label.set_text(activeInvalidationBadge, "INVALIDATED")
    color invalidColor = neutralColor
    float invalidLabelPrice = activeBreakDir == 1 ? high + atr * labelOffsetAtr : low - atr * labelOffsetAtr
    label invalidLabel = label.new(
         bar_index,
         invalidLabelPrice,
         "Wedge Invalidated",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = activeBreakDir == 1 ? label.style_label_down : label.style_label_up,
         color = color.new(invalidColor, 0),
         textcolor = color.rgb(15, 23, 42),
         size = f_size(labelFontInput))
    array.push(eventLabels, invalidLabel)
    f_trim_labels(eventLabels, maxStoredEvents)

// -------------------------------------------------
// STATE MACHINE + NEXT ACTION
// One state at a time, always consistent with what is on the chart:
// Waiting -> Scanning -> Developing -> Armed -> Break Active ->
// Target Hit / Invalidated / Expired.
// -------------------------------------------------
string stateTxt = "WAITING"
color stateCol = panelLabelCol
string actionTxt = "> waiting for structure"

if liveActiveWedge and activeInvalidated
    stateTxt := "INVALIDATED"
    stateCol := neutralColor
    actionTxt := "> stand down - setup failed"
else if liveActiveWedge and activeTargetHit
    stateTxt := "TARGET HIT"
    stateCol := activeBreakDir == 1 ? bullColor : bearColor
    actionTxt := "> target zone reached - cycle complete"
else if liveActiveWedge and activeWindowExpired
    stateTxt := "EXPIRED"
    stateCol := neutralColor
    actionTxt := "> projection window closed - rescan"
else if liveActiveWedge and activeBroken
    stateTxt := "BREAK ACTIVE"
    stateCol := activeBreakDir == 1 ? bullColor : bearColor
    actionTxt := "> manage toward target zone"
else if liveActiveWedge and activeStrict
    stateTxt := "ARMED"
    stateCol := neutralColor
    actionTxt := activeType == "Rising Wedge" ? "> armed - watch lower rail break" : "> armed - watch upper rail break"
else if liveActiveWedge
    stateTxt := "DEVELOPING"
    stateCol := accentColor
    actionTxt := "> wedge forming - wait for arm"
else if radarReady
    stateTxt := "SCANNING"
    stateCol := panelLabelCol
    actionTxt := "> scanning - no wedge yet"

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelTextSize = f_size(panelFontInput)
labelTextColor = panelThemeInput == "Light" ? color.rgb(71, 85, 105) : panelLabelCol
valueTextColor = panelThemeInput == "Light" ? color.rgb(15, 23, 42) : panelValueCol
bodyBg = panelThemeInput == "Light" ? color.rgb(248, 250, 252) : panelBg
borderCol = panelThemeInput == "Light" ? color.rgb(203, 213, 225) : panelBorder

var table infoPanel = table.new(f_panel_position(panelPositionInput), 2, 9, border_width = 1, border_color = borderCol)

if barstate.isfirst
    table.merge_cells(infoPanel, 0, 0, 1, 0)
    table.merge_cells(infoPanel, 0, 6, 1, 6)
    table.merge_cells(infoPanel, 0, 8, 1, 8)

string panelWedgeType = liveActiveWedge ? (activeStrict ? activeType : "Developing " + activeType) : radarState
string panelMaturity = liveActiveWedge ? f_maturity(activeMaturityScore) + " / " + str.tostring(math.round(activeMaturityScore)) : radarReady ? "Radar / " + str.tostring(math.round(radarCompression)) : "Waiting"
string panelQuality = activeBroken and not na(activeBreakQuality) ? str.tostring(math.round(activeBreakQuality)) + " / " + f_grade(activeBreakQuality) : activeStrict ? "Pending break" : radarReady ? "Radar only" : "Maturing"
string panelZone = activeBroken and not na(activeTargetLow) and not na(activeTargetHigh) ? str.tostring(activeTargetLow, format.mintick) + " - " + str.tostring(activeTargetHigh, format.mintick) : "Not projected"

if barstate.islast and showPanel
    table.cell(infoPanel, 0, 0, "AG Pro Wedge Reversal Detector", bgcolor = headerBg, text_color = headerText, text_size = panelTextSize)
    table.cell(infoPanel, 0, 1, "State", bgcolor = bodyBg, text_color = labelTextColor, text_size = panelTextSize)
    table.cell(infoPanel, 1, 1, stateTxt, bgcolor = bodyBg, text_color = stateCol, text_size = panelTextSize)
    table.cell(infoPanel, 0, 2, "Wedge Type", bgcolor = bodyBg, text_color = labelTextColor, text_size = panelTextSize)
    table.cell(infoPanel, 1, 2, panelWedgeType, bgcolor = bodyBg, text_color = valueTextColor, text_size = panelTextSize)
    table.cell(infoPanel, 0, 3, "Maturity", bgcolor = bodyBg, text_color = labelTextColor, text_size = panelTextSize)
    table.cell(infoPanel, 1, 3, panelMaturity, bgcolor = bodyBg, text_color = valueTextColor, text_size = panelTextSize)
    table.cell(infoPanel, 0, 4, "Break Quality", bgcolor = bodyBg, text_color = labelTextColor, text_size = panelTextSize)
    table.cell(infoPanel, 1, 4, panelQuality, bgcolor = bodyBg, text_color = valueTextColor, text_size = panelTextSize)
    table.cell(infoPanel, 0, 5, "Target Zone", bgcolor = bodyBg, text_color = labelTextColor, text_size = panelTextSize)
    table.cell(infoPanel, 1, 5, panelZone, bgcolor = bodyBg, text_color = valueTextColor, text_size = panelTextSize)
    table.cell(infoPanel, 0, 6, "-- BREAK PROOF --", bgcolor = bodyBg, text_color = accentColor, text_size = panelTextSize, text_halign = text.align_center)
    table.cell(infoPanel, 0, 7, "Zone Hit Rate", bgcolor = bodyBg, text_color = labelTextColor, text_size = panelTextSize)
    table.cell(infoPanel, 1, 7, f_hitText(zoneWins, zoneN), bgcolor = bodyBg, text_color = f_hitColor(zoneWins, zoneN, labelTextColor), text_size = panelTextSize)
    table.cell(infoPanel, 0, 8, actionTxt, bgcolor = bodyBg, text_color = accentColor, text_size = panelTextSize, text_halign = text.align_left)
else if barstate.islast
    table.clear(infoPanel, 0, 0, 1, 8)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(bullBreak, "Bullish Falling Wedge Break", "Bullish falling wedge reversal break confirmed on {{ticker}} {{interval}}.")
alertcondition(bearBreak, "Bearish Rising Wedge Break", "Bearish rising wedge reversal break confirmed on {{ticker}} {{interval}}.")
alertcondition(anyBreak and activeBreakQuality >= 72.0, "High Quality Wedge Break", "High quality wedge reversal break confirmed on {{ticker}} {{interval}}.")
alertcondition(zoneHitEv, "Wedge Target Zone Hit", "Price reached the projected wedge reaction zone on {{ticker}} {{interval}}.")
alertcondition(invalidatedAfterBreak, "Wedge Invalidation", "A previously confirmed wedge reversal setup has been invalidated on {{ticker}} {{interval}}.")
````

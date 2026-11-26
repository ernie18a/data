# Mean Reversion Corridors [AGPro Series]

- url: https://www.tradingview.com/script/Yv2hFW4X-Mean-Reversion-Corridors-AGPro-Series/
- type: indicator
- pine_id: PUB;c2b82fab87e945aa8d20818d602b87f8
- version: 4.0

## Description

Mean Reversion Corridors [AGPro Series]

🔹 Overview
Mean Reversion Corridors is a volatility-adaptive deviation framework that maps how far price has stretched from a chosen fair-value center and classifies that stretch into two actionable zones. An inner corridor marks the early reversion band where price is meaningfully extended but not yet extreme; an outer corridor marks statistical exhaustion where continuation becomes less probable under normal conditions. A higher-timeframe trend filter separates controlled mean reversion from failure-continuation expansions, so traders can tell fading the edge from respecting a real break — all from a single clean overlay.

🔸 Unique Edge
Most band systems (Bollinger, Keltner, ATR channels) offer a single width engine and a single band pair, leaving the trader to guess whether a tag is an exhaustion or a breakout. Mean Reversion Corridors is built around three ideas that work together:
- A dual-engine width unit that linearly blends ATR (range-based) and Standard Deviation (dispersion-based) so the corridor is stable on both gap-heavy and low-dispersion regimes.
- A two-layer corridor with distinct roles — inner for early stretch, outer for exhaustion — rendered as transparent zones you can read at a glance.
- A regime-aware state machine that uses a higher-timeframe trend filter to reclassify outer tags as either reversion candidates or failure-continuation, tracked as explicit REV and FAIL states with a bounded confirmation window.

🧠 Methodology
- Center Model — user choice of EMA, VWMA (volume-aware, default) or HMA (responsive), calculated on chart closes.
- Width Unit — the current volatility unit is a linear blend: (1 − blend) × ATR + blend × StDev, protected against empty volatility periods.
- Corridors — inner band at ±(width × inner multiplier), outer band at ±(width × outer multiplier). Stretch is reported in width-unit sigma.
- Trend Filter — the same center model is evaluated on a higher-timeframe via request.security with lookahead off, and its slope is normalized by ATR so the "strong" threshold is volatility-aware, not symbol-specific.
- State Machine — tracks the most recent outer-band extreme with a rolling 20-bar confirmation window. A reversion is confirmed only when price closes back inside the inner corridor and the trend filter is not strongly aligned with the original stretch. When the trend is strongly aligned, the outer break is reclassified as corridor failure (continuation).
- All conditions evaluate on confirmed bars to avoid repainting behavior.

⚡ Signals & Alerts
On-chart markers:
- REV — reversion confirmed back through the inner band after an outer extreme, trend-filtered.
- FAIL — corridor failure / trend-aligned continuation beyond the outer band.

Six bar-close alert conditions:
- Inner corridor entered — upside stretch
- Inner corridor entered — downside stretch
- Outer corridor hit — upside exhaustion
- Outer corridor hit — downside exhaustion
- Reversion confirmed
- Corridor failure (continuation)

⚙️ Key Inputs
- Center Model — EMA / VWMA / Hull
- Center Length and Volatility Length — independent lookbacks
- ATR ↔ StDev Blend — balance between range and dispersion engines
- Inner Corridor Width and Outer Corridor Width — in volatility units
- Trend Filter — enable, timeframe, length, strength threshold
- Visuals — outer-only mode, center line, fills, edge tags, state labels, label size
- Info Panel — show/hide, position (six options), font size
- Alerts — individually toggleable for each of the six events

📖 How to Use
- Start with the defaults on your main chart timeframe. The 34-period VWMA center, balanced blend and 1.0 / 2.2 inner/outer multipliers are chosen to work as a neutral starting point across liquid markets.
- Inner corridor tags are early stretch cues — they flag that price is extended, not that a turn is due. Use them as context for setups, not as standalone signals.
- Outer corridor tags with the trend filter neutral or opposed are the primary mean reversion setup; wait for a REV confirmation back inside the inner band before acting.
- When FAIL appears, the stretch is trend-aligned; treat the outer band as continuation, not resistance. This is the signal to stop fading.
- Use the Info Panel to read current state, reversion bias, trend regime and stretch magnitude in sigma at a glance.

⚠️ Limitations & Transparency
- This is an analytical tool, not a trading strategy or financial advice. It does not predict future price.
- Band-based classification assumes statistical behavior; during shocks, news events or illiquid sessions the width engine can lag.
- The trend filter uses a higher-timeframe slope — it reacts slower than short-term momentum by design, which is the intended behavior.
- Signals are evaluated on confirmed bars; intrabar crosses are not counted as events.
- Past behavior of any indicator does not guarantee future results. Always apply your own risk management.

## Source Code

````pine
// -------------------------------------------------
// Mean Reversion Corridors [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Mean reversion corridor system that maps how far price has stretched from
// a volume-aware fair-value center, separates inner stretch from outer
// exhaustion, and uses a trend filter to distinguish controlled reversion
// from corridor failure and continuation pressure. Version 1.3 adds price-owned
// corridor rails, adaptive tag separation, and cleaner state badges.
// -------------------------------------------------

//@version=6
indicator("Mean Reversion Corridors [AGPro Series]",
     shorttitle = "AG Pro MRC",
     overlay = true,
     max_labels_count = 220,
     max_lines_count = 80,
     max_boxes_count = 20)

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
darkInk       = color.rgb(17, 24, 39)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupCore = "Core Engine"
centerModelInput = input.string("VWMA", "Center Model", options = ["EMA", "VWMA", "Hull"], group = groupCore, tooltip = "Fair-value reference used to anchor the corridors. EMA is smoother, VWMA is volume-aware, and Hull is more responsive.")
centerLength = input.int(34, "Center Length", minval = 5, maxval = 400, group = groupCore, tooltip = "Lookback used to calculate the fair-value center. Lower values react faster; higher values smooth the center.")
devBlend = input.float(0.50, "ATR / StDev Blend", minval = 0.0, maxval = 1.0, step = 0.05, group = groupCore, tooltip = "Blend between ATR and standard deviation for corridor width. 0 uses ATR only, 1 uses standard deviation only.")
devLength = input.int(34, "Volatility Length", minval = 5, maxval = 400, group = groupCore, tooltip = "Lookback used for ATR and standard deviation inside the corridor width engine.")

groupWidth = "Corridor Width"
innerMult = input.float(1.00, "Inner Corridor Width", minval = 0.20, maxval = 5.0, step = 0.10, group = groupWidth, tooltip = "Distance of the inner corridor from the center in blended volatility units.")
outerMult = input.float(2.20, "Outer Corridor Width", minval = 0.50, maxval = 8.0, step = 0.10, group = groupWidth, tooltip = "Distance of the outer corridor from the center in blended volatility units.")

groupTrend = "Trend Filter"
trendEnabled = input.bool(true, "Enable Trend Filter", group = groupTrend, tooltip = "When enabled, strong aligned trend can classify an outer stretch as continuation pressure instead of reversion context.")
trendTimeframe = input.timeframe("", "Trend Timeframe", group = groupTrend, tooltip = "Timeframe used to evaluate trend slope. Leave empty to use the chart timeframe.")
trendLength = input.int(100, "Trend Length", minval = 20, maxval = 400, group = groupTrend, tooltip = "Lookback used to estimate the higher-context center slope.")
trendSlopeMin = input.float(0.15, "Trend Strength Threshold", minval = 0.0, maxval = 2.0, step = 0.05, group = groupTrend, tooltip = "Minimum normalized slope required to classify the trend as strong.")

groupVisuals = "Visuals"
showOuterOnly = input.bool(false, "Show Outer Band Only", group = groupVisuals, tooltip = "Hides the inner corridor and keeps only the outer extreme bands.")
showCenter = input.bool(true, "Show Center Line", group = groupVisuals, tooltip = "Shows the fair-value center line used to anchor the corridors.")
showFill = input.bool(true, "Show Corridor Fills", group = groupVisuals, tooltip = "Shades the area between inner and outer corridors to show stretch intensity.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = groupVisuals, tooltip = "Shows compact right-side tags for upper outer, center, and lower outer levels.")
showStateLabels = input.bool(true, "Show State Labels", group = groupVisuals, tooltip = "Shows REV and FAIL labels when corridor state transitions occur.")
showOnlyKeyLabels = input.bool(true, "Show Only Key Labels", group = groupVisuals, tooltip = "Keeps chart labels focused on outer reversion and failure events, reducing low-value noise.")
labelCooldownBars = input.int(10, "Label Cooldown Bars", minval = 0, maxval = 100, group = groupVisuals, tooltip = "Minimum spacing between state labels to prevent clustered markers.")
maxStateLabels = input.int(8, "Max State Labels", minval = 2, maxval = 50, group = groupVisuals, tooltip = "Maximum number of historical REV and FAIL labels retained on the chart.")
labelOffsetAtr = input.float(0.55, "Label Offset ATR", minval = 0.05, maxval = 3.0, step = 0.05, group = groupVisuals, tooltip = "ATR-based offset used to keep state labels away from candle bodies.")
projectionBars = input.int(8, "Right Tag Offset Bars", minval = 2, maxval = 80, group = groupVisuals, tooltip = "Horizontal offset used for the right-side corridor tags.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisuals, tooltip = "Font size for state labels and right-side tags.")

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = "Shows or hides the AG Pro information panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = "Controls where the panel appears on the chart.")
panelThemeInput = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = groupPanel, tooltip = "Controls the panel theme while preserving the AGPro blue header.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel, tooltip = "Font size inside the information panel.")

groupAlerts = "Alerts"
alertInnerUp = input.bool(true, "Alert: Upper Inner Entered", group = groupAlerts, tooltip = "Enables alerts when price crosses into the upper inner stretch corridor.")
alertInnerDown = input.bool(true, "Alert: Lower Inner Entered", group = groupAlerts, tooltip = "Enables alerts when price crosses into the lower inner stretch corridor.")
alertOuterUp = input.bool(true, "Alert: Upper Outer Hit", group = groupAlerts, tooltip = "Enables alerts when price reaches the upper outer corridor.")
alertOuterDown = input.bool(true, "Alert: Lower Outer Hit", group = groupAlerts, tooltip = "Enables alerts when price reaches the lower outer corridor.")
alertReversion = input.bool(true, "Alert: Reversion Confirmed", group = groupAlerts, tooltip = "Enables alerts when price returns inside the inner corridor after an outer stretch.")
alertFailure = input.bool(true, "Alert: Corridor Failure", group = groupAlerts, tooltip = "Enables alerts when price breaks beyond the outer corridor with aligned trend pressure.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_text_on(color bgColor) =>
    float bright = (color.r(bgColor) * 299 + color.g(bgColor) * 587 + color.b(bgColor) * 114) / 1000
    bright >= 145 ? darkInk : headerText

f_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_price(float value) =>
    str.tostring(value, format.mintick)

f_tag_lane_atr(string sizeText) =>
    switch sizeText
        "Tiny" => 0.48
        "Small" => 0.58
        "Large" => 0.84
        "Huge" => 1.02
        => 0.70

f_label_pad_atr(string sizeText) =>
    switch sizeText
        "Tiny" => 0.04
        "Small" => 0.08
        "Large" => 0.18
        "Huge" => 0.26
        => 0.12

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

f_center(float source, int length, string model) =>
    switch model
        "EMA" => ta.ema(source, length)
        "VWMA" => ta.vwma(source, length)
        "Hull" => ta.hma(source, length)
        => ta.ema(source, length)

f_trim_labels(array<label> labels, int maxKeep) =>
    while array.size(labels) > maxKeep
        label oldLabel = array.shift(labels)
        if not na(oldLabel)
            label.delete(oldLabel)

f_update_tag(label tag, int xValue, float yValue, string txt, color bgColor) =>
    label result = tag
    if na(result)
        result := label.new(xValue, yValue, txt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = bgColor, textcolor = f_text_on(bgColor), size = f_size(labelSizeInput))
    else
        label.set_x(result, xValue)
        label.set_y(result, yValue)
        label.set_text(result, txt)
        label.set_color(result, bgColor)
        label.set_textcolor(result, f_text_on(bgColor))
        label.set_size(result, f_size(labelSizeInput))
    result

f_update_connector(line connector, int x1Value, float y1Value, int x2Value, float y2Value, color lineColor) =>
    line result = connector
    if na(result)
        result := line.new(x1Value, y1Value, x2Value, y2Value, xloc = xloc.bar_index, extend = extend.none, color = lineColor, style = line.style_dotted, width = 1)
    else
        line.set_xy1(result, x1Value, y1Value)
        line.set_xy2(result, x2Value, y2Value)
        line.set_color(result, lineColor)
        line.set_style(result, line.style_dotted)
        line.set_width(result, 1)
    result

// -------------------------------------------------
// Center and Corridor Engine
// -------------------------------------------------
source = close
center = f_center(source, centerLength, centerModelInput)
atrValue = math.max(nz(ta.atr(devLength), ta.tr(true)), syminfo.mintick)
stdValue = ta.stdev(source, devLength)
widthRaw = (1.0 - devBlend) * atrValue + devBlend * stdValue
widthUnit = na(widthRaw) or widthRaw <= 0.0 ? atrValue : widthRaw

innerDist = widthUnit * innerMult
outerDist = widthUnit * outerMult
upperInner = center + innerDist
lowerInner = center - innerDist
upperOuter = center + outerDist
lowerOuter = center - outerDist
stretch = widthUnit > 0.0 ? (source - center) / widthUnit : 0.0

// -------------------------------------------------
// Trend Filter
// -------------------------------------------------
f_trend_bundle() =>
    c = f_center(source, centerLength, centerModelInput)
    a = ta.atr(devLength)
    slopeRaw = (c - c[trendLength]) / math.max(trendLength, 1)
    slopeNorm = a > 0.0 ? slopeRaw / a : 0.0
    [c, slopeNorm]

[trendCenter, trendSlopeRaw] = request.security(syminfo.tickerid, trendTimeframe == "" ? timeframe.period : trendTimeframe, f_trend_bundle(), lookahead = barmerge.lookahead_off)
trendSlope = trendEnabled ? trendSlopeRaw : 0.0
trendUp = trendEnabled and trendSlope > trendSlopeMin
trendDown = trendEnabled and trendSlope < -trendSlopeMin
trendNeutral = not trendUp and not trendDown

// -------------------------------------------------
// State Engine
// -------------------------------------------------
inOuterUp = source >= upperOuter
inOuterDown = source <= lowerOuter
inInnerUp = not inOuterUp and source >= upperInner
inInnerDown = not inOuterDown and source <= lowerInner
inBalance = not inOuterUp and not inOuterDown and not inInnerUp and not inInnerDown

crossUpperInner = ta.crossover(source, upperInner)
crossLowerInner = ta.crossunder(source, lowerInner)
hitUpperOuter = ta.crossover(source, upperOuter)
hitLowerOuter = ta.crossunder(source, lowerOuter)

var int lastExtremeDir = 0
var int barsSinceExtreme = 0

if hitUpperOuter
    lastExtremeDir := 1
    barsSinceExtreme := 0
else if hitLowerOuter
    lastExtremeDir := -1
    barsSinceExtreme := 0
else if lastExtremeDir != 0
    barsSinceExtreme += 1

reversionWindow = 20
if lastExtremeDir != 0 and barsSinceExtreme > reversionWindow
    lastExtremeDir := 0
    barsSinceExtreme := 0

reversionDown = lastExtremeDir == 1 and ta.crossunder(source, upperInner) and not trendUp
reversionUp = lastExtremeDir == -1 and ta.crossover(source, lowerInner) and not trendDown
reversionEvent = reversionDown or reversionUp

if reversionEvent
    lastExtremeDir := 0
    barsSinceExtreme := 0

failureUpRaw = close > upperOuter and trendUp
failureDownRaw = close < lowerOuter and trendDown
failureUp = failureUpRaw and not failureUpRaw[1]
failureDown = failureDownRaw and not failureDownRaw[1]
failureEvent = failureUp or failureDown

stateText = inBalance ? "In Balance" : inInnerUp ? "Inner Stretch Up" : inInnerDown ? "Inner Stretch Down" : inOuterUp ? (trendUp ? "Outer Continuation Up" : "Outer Extreme Up") : inOuterDown ? (trendDown ? "Outer Continuation Down" : "Outer Extreme Down") : "Neutral"
stateColor = inBalance ? f_panel_value() : inInnerUp ? bearColor : inInnerDown ? bullColor : inOuterUp ? (trendUp ? neutralColor : bearColor) : inOuterDown ? (trendDown ? neutralColor : bullColor) : f_panel_value()

biasText = inBalance ? "Neutral" : (inInnerUp or inOuterUp) and not trendUp ? "Fade Up Stretch" : (inInnerDown or inOuterDown) and not trendDown ? "Fade Down Stretch" : "Trend Overrides"
biasColor = inBalance ? f_panel_value() : biasText == "Trend Overrides" ? neutralColor : (inInnerUp or inOuterUp) ? bearColor : bullColor

trendText = not trendEnabled ? "Off" : trendUp ? "Strong Up" : trendDown ? "Strong Down" : "Neutral"
trendColor = not trendEnabled ? f_panel_label() : trendUp ? bullColor : trendDown ? bearColor : neutralColor

// -------------------------------------------------
// Outer-stretch fade proof (stop-aware)
// -------------------------------------------------
// When price hits an outer corridor without an aligned trend (a fade setup),
// did it revert back to the inner corridor before stretching further into
// failure? Win = inner reached first, Loss = further outer stretch first,
// neither inside the window = uncounted.
var int   pfTotal  = 0
var int   pfWins   = 0
var bool  pfOpen   = false
var int   pfDir    = 0
var float pfTarget = na
var float pfStop   = na
var int   pfBar    = na
int pfWindow = 30

bool upperFade = hitUpperOuter and not trendUp
bool lowerFade = hitLowerOuter and not trendDown

if barstate.isconfirmed
    if pfOpen
        bool pfHitStop   = pfDir == 1 ? close < pfStop : close > pfStop
        bool pfHitTarget = pfDir == 1 ? high >= pfTarget : low <= pfTarget
        if pfHitStop
            pfTotal += 1
            pfOpen  := false
        else if pfHitTarget
            pfTotal += 1
            pfWins  += 1
            pfOpen  := false
        else if not na(pfBar) and bar_index - pfBar > pfWindow
            pfOpen := false
    if (upperFade or lowerFade) and not pfOpen
        pfOpen   := true
        if upperFade
            pfDir    := -1
            pfTarget := upperInner
            pfStop   := upperOuter + innerDist
        else
            pfDir    := 1
            pfTarget := lowerInner
            pfStop   := lowerOuter - innerDist
        pfBar    := bar_index

float pfRate = pfTotal > 0 ? pfWins / pfTotal * 100.0 : na
fadeRateTxt = pfTotal >= 6 ? str.tostring(math.round(pfRate)) + "%  (" + str.tostring(pfTotal) + ")" : "Building (" + str.tostring(pfTotal) + ")"
fadeRateCol = pfTotal >= 6 ? (pfRate >= 55.0 ? bullColor : pfRate >= 45.0 ? neutralColor : bearColor) : f_panel_value()

// -------------------------------------------------
// Plots
// -------------------------------------------------
pCenter = plot(showCenter ? center : na, "Center", color = color.new(accentColor, 28), linewidth = 1, style = plot.style_linebr)
pUpperInner = plot(not showOuterOnly ? upperInner : na, "Upper Inner", color = color.new(bearColor, 55), linewidth = 1)
pLowerInner = plot(not showOuterOnly ? lowerInner : na, "Lower Inner", color = color.new(bullColor, 55), linewidth = 1)
pUpperOuter = plot(upperOuter, "Upper Outer", color = color.new(bearColor, 22), linewidth = 2)
pLowerOuter = plot(lowerOuter, "Lower Outer", color = color.new(bullColor, 22), linewidth = 2)

fill(pUpperInner, pUpperOuter, color = showFill and not showOuterOnly ? color.new(bearColor, 89) : na, title = "Upper Stretch Fill")
fill(pLowerInner, pLowerOuter, color = showFill and not showOuterOnly ? color.new(bullColor, 89) : na, title = "Lower Stretch Fill")

// -------------------------------------------------
// Right-Side Tags
// -------------------------------------------------
var label tagUpperOuter = na
var label tagLowerOuter = na
var label tagCenter = na
var line railUpperOuter = na
var line railLowerOuter = na
var line railCenter = na

if barstate.islast
    if showRightTags
        tagX = bar_index + projectionBars
        railStartX = bar_index + 1
        railEndX = math.max(railStartX, tagX - 1)
        tagLane = math.max(atrValue * f_tag_lane_atr(labelSizeInput), syminfo.mintick * 30)
        upperTagY = math.max(upperOuter, center + tagLane)
        lowerTagY = math.min(lowerOuter, center - tagLane)
        upperTagColor = color.new(bearColor, 8)
        lowerTagColor = color.new(bullColor, 8)
        centerTagColor = color.new(accentColor, 8)

        tagUpperOuter := f_update_tag(tagUpperOuter, tagX, upperTagY, "OUTER UP  " + f_price(upperOuter), upperTagColor)
        tagLowerOuter := f_update_tag(tagLowerOuter, tagX, lowerTagY, "OUTER DOWN  " + f_price(lowerOuter), lowerTagColor)
        railUpperOuter := f_update_connector(railUpperOuter, railStartX, upperOuter, railEndX, upperTagY, color.new(bearColor, 28))
        railLowerOuter := f_update_connector(railLowerOuter, railStartX, lowerOuter, railEndX, lowerTagY, color.new(bullColor, 28))
        if showCenter
            tagCenter := f_update_tag(tagCenter, tagX, center, "CENTER  " + f_price(center), centerTagColor)
            railCenter := f_update_connector(railCenter, railStartX, center, railEndX, center, color.new(accentColor, 34))
        else
            if not na(tagCenter)
                label.delete(tagCenter)
                tagCenter := na
            if not na(railCenter)
                line.delete(railCenter)
                railCenter := na
    else
        if not na(tagUpperOuter)
            label.delete(tagUpperOuter)
            tagUpperOuter := na
        if not na(tagLowerOuter)
            label.delete(tagLowerOuter)
            tagLowerOuter := na
        if not na(tagCenter)
            label.delete(tagCenter)
            tagCenter := na
        if not na(railUpperOuter)
            line.delete(railUpperOuter)
            railUpperOuter := na
        if not na(railLowerOuter)
            line.delete(railLowerOuter)
            railLowerOuter := na
        if not na(railCenter)
            line.delete(railCenter)
            railCenter := na

// -------------------------------------------------
// State Labels
// -------------------------------------------------
var array<label> stateLabels = array.new<label>()
var int lastStateLabelBar = na
labelOffset = math.max(atrValue * (labelOffsetAtr + f_label_pad_atr(labelSizeInput)), syminfo.mintick * 20)
canPrintLabel = na(lastStateLabelBar) or bar_index - lastStateLabelBar >= labelCooldownBars
stateLabelEvent = showStateLabels and canPrintLabel and (reversionEvent or failureEvent)
stateLabelAllowed = stateLabelEvent and (not showOnlyKeyLabels or reversionEvent or failureEvent)

if stateLabelAllowed
    bool upLabel = reversionUp or failureDown
    labelStyle = upLabel ? label.style_label_up : label.style_label_down
    labelY = upLabel ? low - labelOffset : high + labelOffset
    labelText = reversionEvent ? (reversionUp ? "REV UP" : "REV DOWN") : (failureUp ? "FAIL UP" : "FAIL DOWN")
    labelColor = reversionEvent ? (reversionUp ? bullColor : bearColor) : neutralColor
    newLabel = label.new(bar_index, labelY, labelText, xloc = xloc.bar_index, yloc = yloc.price, style = labelStyle, color = color.new(labelColor, 0), textcolor = f_text_on(labelColor), size = f_size(labelSizeInput), textalign = text.align_center)
    array.push(stateLabels, newLabel)
    f_trim_labels(stateLabels, maxStateLabels)
    lastStateLabelBar := bar_index

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table panel = table.new(f_panel_position(panelPositionInput), 2, 6, bgcolor = f_panel_bg(), frame_color = f_panel_border(), frame_width = 1, border_color = f_panel_border(), border_width = 1)

if barstate.islast
    table.set_position(panel, f_panel_position(panelPositionInput))
    table.clear(panel, 0, 0, 1, 5)
    if showPanel
        stretchText = str.tostring(stretch, "#.00") + " units"
        stretchColor = math.abs(stretch) >= outerMult ? (stretch > 0.0 ? bearColor : bullColor) : math.abs(stretch) >= innerMult ? neutralColor : f_panel_value()

        table.merge_cells(panel, 0, 0, 1, 0)
        f_panel_cell(panel, 0, 0, "AG Pro Mean Reversion Corridors", headerText, headerBg, "center")
        f_panel_cell(panel, 0, 1, "State", f_panel_label(), f_row_bg(1), "left")
        f_panel_cell(panel, 1, 1, stateText, stateColor, f_row_bg(1), "right")
        f_panel_cell(panel, 0, 2, "Bias", f_panel_label(), f_row_bg(2), "left")
        f_panel_cell(panel, 1, 2, biasText, biasColor, f_row_bg(2), "right")
        f_panel_cell(panel, 0, 3, "Trend", f_panel_label(), f_row_bg(3), "left")
        f_panel_cell(panel, 1, 3, trendText, trendColor, f_row_bg(3), "right")
        f_panel_cell(panel, 0, 4, "Stretch", f_panel_label(), f_row_bg(4), "left")
        f_panel_cell(panel, 1, 4, stretchText, stretchColor, f_row_bg(4), "right")
        f_panel_cell(panel, 0, 5, "Fade Rate", f_panel_label(), f_row_bg(5), "left")
        f_panel_cell(panel, 1, 5, fadeRateTxt, fadeRateCol, f_row_bg(5), "right")

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertInnerUp and crossUpperInner, "AG Pro MRC | Upper Inner Entered", "AG Pro MRC: Price crossed into the upper inner stretch corridor.")
alertcondition(alertInnerDown and crossLowerInner, "AG Pro MRC | Lower Inner Entered", "AG Pro MRC: Price crossed into the lower inner stretch corridor.")
alertcondition(alertOuterUp and hitUpperOuter, "AG Pro MRC | Upper Outer Hit", "AG Pro MRC: Price reached the upper outer corridor.")
alertcondition(alertOuterDown and hitLowerOuter, "AG Pro MRC | Lower Outer Hit", "AG Pro MRC: Price reached the lower outer corridor.")
alertcondition(alertReversion and reversionEvent, "AG Pro MRC | Reversion Confirmed", "AG Pro MRC: Price returned inside the inner corridor after an outer stretch.")
alertcondition(alertFailure and failureEvent, "AG Pro MRC | Corridor Failure", "AG Pro MRC: Price moved beyond the outer corridor with aligned trend pressure.")
````

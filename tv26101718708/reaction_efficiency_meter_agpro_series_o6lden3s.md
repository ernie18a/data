# Reaction Efficiency Meter [AGPro Series]

- url: https://www.tradingview.com/script/O6lDEn3S-Reaction-Efficiency-Meter-AGPro-Series/
- type: indicator
- pine_id: PUB;e0a6cd45f5c54405a64e977ec1efe52e
- version: 4.0

## Description

Reaction Efficiency Meter [AGPro Series]

A pure observation lens that scores every pivot-based support and resistance reaction from 0 to 100 and classifies it as WEAK, LIMITED, FAIR, STRONG or EFFICIENT. Designed to answer one specific question on any chart: how well did price actually react when it touched that level? Not a strategy, not a signal generator — a quality meter for S/R reactions.

🔹 Overview

Reaction Efficiency Meter watches pivot-based support and resistance levels and, the moment price touches any of them, opens a fixed reaction window to observe what happens next. At the end of that window the reaction is scored from 0 to 100 using four weighted components — strength, speed, cleanliness, follow-through — and then classified into a five-tier hierarchy. The result is printed directly on the chart as a color-coded label (BULL or BEAR), while a side panel keeps a live summary of the last bullish reaction, last bearish reaction and the currently active event window. The indicator is built as a post-event quality lens for traders who already work with horizontal levels, pivot zones, or structural S/R and want an objective readout of reaction quality instead of a subjective eyeball assessment.

🔸 Unique Edge

Most support and resistance indicators stop at drawing lines or zones. Reaction Efficiency Meter goes one step further and evaluates the reaction itself on a fixed, reproducible scale. Four distinct quality dimensions are blended into a single 0-100 score, and a separate adverse-excursion penalty reduces the score when price violated the level before reacting. The result is a transparent number tied to a five-tier verbal classification (WEAK / LIMITED / FAIR / STRONG / EFFICIENT), which makes reactions directly comparable across symbols and timeframes. There are no repainting signals, no lagging smoothers and no hidden strategy logic — the scoring is purely descriptive and fires only after the reaction window closes on a confirmed bar.

🔹 Methodology

The engine has four clear stages:

1. Level detection. Classic pivot highs and lows are tracked as dynamic resistance and support. Only the most recent N levels per side stay active — older ones are retired, so the chart never clutters.

2. Touch detection. A touch is registered when the bar's range enters a tolerance band around any active level (expressed in ATR units so the logic auto-scales across volatility regimes). A cooldown of N bars between tests on the same level prevents noise from restarting an event too quickly.

3. Event tracking. Once a touch fires, a reaction window of N bars is opened. During that window the script tracks (a) the best favorable excursion in ATR units, (b) the worst adverse excursion in the wrong direction, (c) which bar produced the peak favorable move, (d) the net retained move at window close.

4. Scoring and classification. At window close the four components are combined with a penalty:
   • Strength (0-35): best favorable excursion relative to 1.5 ATR reference.
   • Speed (0-20): how early the peak favorable bar occurred inside the window.
   • Cleanliness (0-20): reduced linearly by adverse excursion.
   • Follow-through (0-15): how much of the peak move was retained at window close.
   • Adverse penalty (up to -15): applied when price broke through the level.

Final score is clamped 0-100 and mapped to: WEAK (<25), LIMITED (25-44), FAIR (45-64), STRONG (65-79), EFFICIENT (80+).

🔸 Signals & Alerts

The indicator does not emit buy or sell alerts. Its outputs are purely descriptive:

• A color-coded reaction label (BULL or BEAR with score and tier) plotted after each completed window.
• Active zone rectangle and reaction corridor drawn around the touched level while the window is open.
• Touch markers on the bar where a new event begins.
• Live status tag showing BULL WINDOW x/N or BEAR WINDOW x/N during an active event.
• A stateful side panel with Status, Last Bull, Last Bear, Window progress and Mode rows.

All visuals render on confirmed bars only, so the score and tier of a completed reaction do not change afterwards.

🔹 Key Inputs

• Pivot Length — bar distance used to qualify pivot highs and lows.
• Max Active Levels / Side — how many recent resistance and support levels stay active.
• ATR Length — volatility reference for tolerance, corridor depth and scoring.
• Touch Tolerance (ATR) — how close to the level a bar must come to count as a touch.
• Reaction Window Bars — fixed observation length per event.
• Minimum Bars Between Tests — cooldown on the same level.
• Reaction Corridor Depth (ATR) — vertical span of the reaction corridor drawn during the window.
• Display group — toggles for levels, tags, markers, labels, active zone, corridor, panel.
• Theme & Layout — panel theme (Auto / Dark / Light), position, font size, line width and opacity controls.

🔸 How to Use

The indicator is intended as a companion lens, not a standalone system. Typical workflows include:

• Confluence study. Compare reaction scores at different levels on the same chart to see which zones historically produced stronger reactions.
• Bias assessment. Watching whether BULL and BEAR labels on a given timeframe skew toward higher or lower tiers can inform directional bias for discretionary decisions made elsewhere.
• Framework validation. Add it on top of an existing S/R, order block or pivot framework to quantify whether the levels those tools produce actually generate efficient reactions.
• Multi-timeframe scanning. Running the indicator on multiple timeframes shows where strong reactions cluster — often useful for context, not entry timing.

The tool is descriptive and retrospective. It is not designed to replace risk management, structural analysis or the user's own trading plan.

🔹 Limitations & Transparency

• The reaction window is fixed per event. Very fast V-reversals may still register as WEAK if most of the favorable move happens after the window closes; conversely, slow grind reactions may score lower on the Speed component even when the net outcome is good.
• Pivot-based levels are, by definition, confirmed with a lag equal to Pivot Length bars.
• Scores are descriptive — a STRONG tag on a past reaction does not imply that the next test of the same level will also react strongly.
• All scoring uses confirmed-bar logic, so the indicator is non-repainting by design.

🔸 Risk Disclosure

This indicator is provided for educational and analytical purposes only. It is not financial advice, not a trade signal generator, and not a recommendation to buy or sell any instrument. Trading involves substantial risk of loss. Past reactions do not guarantee future reactions. Users are solely responsible for their own trading decisions and risk management.

## Source Code

````pine
// ─────────────────────────────────────────────────
// Reaction Efficiency Meter [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.0
//
// Measures how efficiently price reacts to pivot-based support and resistance
// levels. Each reaction is scored from strength, speed, cleanliness, and
// follow-through, then classified as WEAK, LIMITED, FAIR, STRONG, or EFFICIENT.
// Built as a neutral reaction-quality lens for support resistance validation,
// pivot reaction research, confluence review, and structure-based chart reading.
// Version 2.0 adds price-owned level rails and an owned reaction-room lifecycle.
// ─────────────────────────────────────────────────

//@version=6
indicator("Reaction Efficiency Meter [AGPro Series]",
     shorttitle = "AG Pro REM",
     overlay = true,
     max_labels_count = 500,
     max_lines_count = 500,
     max_boxes_count = 120)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
gLevels = "Levels"
pivotLen = input.int(5, "Pivot Length", minval = 2, maxval = 20, group = gLevels, tooltip = "Pivot confirmation length used to build support and resistance reference levels.")
maxLevels = input.int(2, "Max Active Levels / Side", minval = 1, maxval = 10, group = gLevels, tooltip = "Maximum active support and resistance levels retained on each side.")
minLevelSpacingATR = input.float(1.20, "Minimum Level Spacing (ATR)", minval = 0.0, maxval = 5.0, step = 0.05, group = gLevels, tooltip = "Minimum ATR distance required before a new same-side support or resistance level can be retained. Higher values reduce clustered level stacks.")
oppositeLevelSpacingATR = input.float(0.90, "Opposite Level Spacing (ATR)", minval = 0.0, maxval = 5.0, step = 0.05, group = gLevels, tooltip = "Minimum ATR distance required between support and resistance levels. Higher values reduce tight mixed SUP / RES stacks.")
showResistanceLevels = input.bool(true, "Show Resistance Levels", group = gLevels, tooltip = "Displays active pivot-based resistance levels.")
showSupportLevels = input.bool(true, "Show Support Levels", group = gLevels, tooltip = "Displays active pivot-based support levels.")
showLevelTags = input.bool(true, "Show Level Tags", group = gLevels, tooltip = "Shows compact right-side SUP / RES tags for active levels.")

gEngine = "Reaction Engine"
atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = gEngine, tooltip = "ATR baseline used for touch tolerance, reaction corridor depth, scoring, and label offsets.")
touchToleranceATR = input.float(0.12, "Touch Tolerance (ATR)", minval = 0.01, maxval = 1.0, step = 0.01, group = gEngine, tooltip = "ATR-based tolerance around each support or resistance level.")
reactionWindow = input.int(8, "Reaction Window Bars", minval = 3, maxval = 30, group = gEngine, tooltip = "Number of bars used to evaluate reaction quality after a level is tested.")
minBarsBetweenTests = input.int(10, "Minimum Bars Between Tests", minval = 1, maxval = 100, group = gEngine, tooltip = "Minimum spacing between repeat tests of the same level.")
corridorDepthATR = input.float(0.90, "Reaction Corridor Depth (ATR)", minval = 0.25, maxval = 2.0, step = 0.05, group = gEngine, tooltip = "ATR depth used to draw the expected reaction corridor from the tested level.")

gDisplay = "Display"
showTouchMarkers = input.bool(false, "Show Touch Markers", group = gDisplay, tooltip = "Optionally shows small touch markers. Off by default because the active test zone and filled reaction badges already own the same event.")
showReactionLabels = input.bool(true, "Show Reaction Labels", group = gDisplay, tooltip = "Shows scored reaction labels after the reaction window closes.")
showHistoricalLabels = input.bool(true, "Keep Historical Labels", group = gDisplay, tooltip = "Keeps a controlled history of reaction result labels.")
maxHistoricalLabels = input.int(3, "Max Historical Labels", minval = 1, maxval = 50, group = gDisplay, tooltip = "Maximum number of historical reaction labels retained.")
showPanel = input.bool(true, "Show Panel", group = gDisplay, tooltip = "Shows or hides the AG Pro reaction panel. Enabled by default for public-chart readability.")
showActiveZone = input.bool(true, "Show Active Reaction Zone", group = gDisplay, tooltip = "Shows the active touch zone around the tested support or resistance level.")
showReactionCorridor = input.bool(true, "Show Reaction Corridor", group = gDisplay, tooltip = "Shows the reaction corridor used to frame favorable movement and adverse movement.")
showCenteredZoneBadges = input.bool(true, "Show Centered Zone Badges", group = gDisplay, tooltip = "Shows centered badges inside active reaction zones and corridors so boxes never appear unlabeled.")
showActiveStatusTag = input.bool(false, "Show Active Status Tag", group = gDisplay, tooltip = "Shows a compact live tag for the currently evaluated reaction window. Disabled by default because the panel already tracks live window progress.")
labelOffsetATR = input.float(0.90, "Label Offset (ATR)", minval = 0.05, maxval = 3.0, step = 0.05, group = gDisplay, tooltip = "ATR-based vertical offset used to keep labels away from candle bodies.")
resultLabelShiftBars = input.int(1, "Result Label Shift Bars", minval = 0, maxval = 10, group = gDisplay, tooltip = "Horizontal shift applied to final reaction labels.")
labelCooldownBars = input.int(10, "Label Cooldown Bars", minval = 0, maxval = 80, group = gDisplay, tooltip = "Minimum spacing between result labels to reduce visual crowding.")

gStyle = "Style"
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = gStyle, tooltip = "Controls reaction labels, status tags, level tags, and centered zone badges.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = gStyle, tooltip = "Controls the AG Pro panel font size.")
panelThemeInput = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = gStyle, tooltip = "Controls the panel theme while preserving the AGPro blue header.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = gStyle, tooltip = "Controls the panel location on the chart.")
levelLineWidth = input.int(2, "Level Line Width", minval = 1, maxval = 4, group = gStyle, tooltip = "Controls support and resistance line thickness.")
zoneOpacity = input.int(84, "Reaction Zone Opacity", minval = 70, maxval = 96, group = gStyle, tooltip = "Transparency of active touch zones.")
corridorOpacity = input.int(89, "Reaction Corridor Opacity", minval = 72, maxval = 97, group = gStyle, tooltip = "Transparency of active reaction corridors.")

gAlerts = "Alerts"
alertReactionDone = input.bool(true, "Alert: Reaction Scored", group = gAlerts, tooltip = "Enables alerts when a reaction window closes and a score is assigned.")
alertEfficient = input.bool(true, "Alert: Efficient Reaction", group = gAlerts, tooltip = "Enables alerts when a reaction scores in the efficient class.")

//------------------------------------------------------------------------------
// AGPro Color Palette
//------------------------------------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBgDark = color.rgb(15, 23, 42)
panelBgSlate = color.rgb(30, 41, 59)
panelBorderDark = color.rgb(51, 65, 85)
panelLabelDark = color.rgb(148, 163, 184)
panelValueDark = color.rgb(226, 232, 240)
panelBgLight = color.rgb(248, 250, 252)
panelBorderLight = color.rgb(203, 213, 225)
panelLabelLight = color.rgb(71, 85, 105)
panelValueLight = color.rgb(15, 23, 42)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

// Luminance-aware contrast text (target luminance 145)
f_lum(color c)      => 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
f_text_on(color bg) => f_lum(bg) > 145 ? color.rgb(15, 23, 42) : color.rgb(245, 247, 250)

f_size(string s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_price(float value) =>
    str.tostring(value, format.mintick)

f_pos(string posText) =>
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
    panelThemeInput == "Clean Light" ? panelBgLight : panelThemeInput == "Slate" ? panelBgSlate : panelBgDark

f_panel_border() =>
    panelThemeInput == "Clean Light" ? panelBorderLight : panelBorderDark

f_panel_label() =>
    panelThemeInput == "Clean Light" ? panelLabelLight : panelLabelDark

f_panel_value() =>
    panelThemeInput == "Clean Light" ? panelValueLight : panelValueDark

f_row_bg(int row) =>
    if panelThemeInput == "Clean Light"
        row % 2 == 0 ? color.rgb(226, 232, 240) : panelBgLight
    else
        row % 2 == 0 ? color.rgb(20, 31, 52) : f_panel_bg()

f_score_class(float score) =>
    score < 25 ? "WEAK" : score < 45 ? "LIMITED" : score < 65 ? "FAIR" : score < 80 ? "STRONG" : "EFFICIENT"

f_score_color(float score, int dir) =>
    color c = neutralColor
    if score >= 80
        c := accentColor
    else if score >= 65
        c := dir == 1 ? bullColor : bearColor
    else if score >= 45
        c := neutralColor
    else
        c := color.new(neutralColor, 8)
    c

f_level_line_alpha(int idx) =>
    idx == 0 ? 10 : idx == 1 ? 24 : 40

f_level_tag_alpha(int idx) =>
    idx == 0 ? 0 : idx == 1 ? 8 : 18

f_level_tag_x_offset(int idx) =>
    6 + idx * 3

f_trim_labels(array<label> labels, int maxKeep) =>
    while array.size(labels) > maxKeep
        label oldLabel = array.shift(labels)
        label.delete(oldLabel)

f_clear_labels(array<label> labels) =>
    while array.size(labels) > 0
        label oldLabel = array.shift(labels)
        if not na(oldLabel)
            label.delete(oldLabel)

f_trim_levels(array<float> prices, array<int> births, array<int> touched, array<line> lines, int maxKeep) =>
    while array.size(prices) > maxKeep
        array.pop(prices)
        array.pop(births)
        array.pop(touched)
        line oldLine = array.pop(lines)
        if not na(oldLine)
            line.delete(oldLine)

f_level_far_enough(array<float> prices, float lvl, float minDist) =>
    bool ok = true
    if minDist > 0.0 and array.size(prices) > 0
        for i = 0 to array.size(prices) - 1
            if math.abs(lvl - array.get(prices, i)) < minDist
                ok := false
                break
    ok

f_add_level(array<float> prices, array<int> births, array<int> touched, array<line> lines, float lvl, int bornBar, color clr, bool doDraw) =>
    line ln = na
    if doDraw
        ln := line.new(bornBar, lvl, bar_index, lvl, xloc = xloc.bar_index, extend = extend.right, color = color.new(clr, 35), width = levelLineWidth)
    array.unshift(prices, lvl)
    array.unshift(births, bornBar)
    array.unshift(touched, -1000000)
    array.unshift(lines, ln)
    f_trim_levels(prices, births, touched, lines, maxLevels)

f_prune_wrong_side_levels(array<float> prices, array<int> births, array<int> touched, array<line> lines, int side, float refPrice) =>
    int i = 0
    while i < array.size(prices)
        float lvl = array.get(prices, i)
        bool wrongSide = side == -1 ? lvl <= refPrice : lvl >= refPrice
        if wrongSide
            array.remove(prices, i)
            array.remove(births, i)
            array.remove(touched, i)
            line oldLine = array.remove(lines, i)
            if not na(oldLine)
                line.delete(oldLine)
            i += 0
        else
            i += 1

f_delete_box(box bx) =>
    if not na(bx)
        box.delete(bx)

f_delete_label(label lbl) =>
    if not na(lbl)
        label.delete(lbl)

f_label_slot(int dir, float baseY, float atrRef, int baseX, array<int> xs, array<float> ys) =>
    int outX = baseX
    float outY = baseY
    bool found = false
    float laneStep = math.max(atrRef * 1.25, syminfo.mintick * 80)
    float yThreshold = math.max(atrRef * 1.10, syminfo.mintick * 65)
    int xThreshold = 10
    for lane = 0 to 16
        for xPad = 0 to 7
            int candX = baseX + xPad + math.min(lane, 8)
            float candY = dir == 1 ? baseY - lane * laneStep : baseY + lane * laneStep
            bool conflict = false
            if array.size(xs) > 0
                for j = 0 to array.size(xs) - 1
                    bool nearX = math.abs(candX - array.get(xs, j)) <= xThreshold
                    bool nearY = math.abs(candY - array.get(ys, j)) <= yThreshold
                    if nearX and nearY
                        conflict := true
                        break
            if not conflict
                outX := candX
                outY := candY
                found := true
                break
        if found
            break
    [outX, outY]

f_register_slot(int x, float y, array<int> xs, array<float> ys, int maxKeep) =>
    array.push(xs, x)
    array.push(ys, y)
    while array.size(xs) > maxKeep
        array.shift(xs)
        array.shift(ys)

f_badge_x(int leftX, int rightX) =>
    int(math.round(leftX + math.max(rightX - leftX, 1) * 0.55))

f_panel_cell(table panelRef, int col, int row, string txt, color txtColor, color bgColor, string alignInput) =>
    table.cell(panelRef, col, row, txt, text_color = txtColor, bgcolor = bgColor, text_size = f_size(panelFontSizeInput), text_halign = alignInput == "left" ? text.align_left : alignInput == "right" ? text.align_right : text.align_center)

//------------------------------------------------------------------------------
// State
//------------------------------------------------------------------------------
var array<float> resPrices = array.new_float()
var array<int> resBirths = array.new_int()
var array<int> resTouched = array.new_int()
var array<line> resLines = array.new_line()

var array<float> supPrices = array.new_float()
var array<int> supBirths = array.new_int()
var array<int> supTouched = array.new_int()
var array<line> supLines = array.new_line()

var array<label> resLevelTags = array.new_label()
var array<label> supLevelTags = array.new_label()
var array<label> resultLabels = array.new_label()
var array<int> placedLabelXs = array.new_int()
var array<float> placedLabelYs = array.new_float()

var bool evtActive = false
var int evtDir = 0
var float evtLevel = na
var float evtAtrRef = na
var float evtTolRef = na
var int evtStartBar = na
var float evtBestFav = 0.0
var float evtWorstAdv = 0.0
var int evtPeakBarOffset = 0

var float lastBullScore = na
var float lastBearScore = na
var string lastBullClass = "-"
var string lastBearClass = "-"
var int lastResultBar = na

var box activeZoneBox = na
var box activeCorridorBox = na
var label activeZoneTag = na
var label activeZoneBadge = na
var label activeCorridorBadge = na

var bool reactionScoredEvent = false
var bool efficientReactionEvent = false
reactionScoredEvent := false
efficientReactionEvent := false

//------------------------------------------------------------------------------
// Core Values
//------------------------------------------------------------------------------
atr = ta.atr(atrLen)
tol = atr * touchToleranceATR
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

bool bullTouchThisBar = false
bool bearTouchThisBar = false

//------------------------------------------------------------------------------
// Confirmed Bar Logic
//------------------------------------------------------------------------------
if barstate.isconfirmed
    float levelSpacing = atr * minLevelSpacingATR
    float oppositeSpacing = atr * oppositeLevelSpacingATR

    if not na(ph)
        if (na(levelSpacing) or f_level_far_enough(resPrices, ph, levelSpacing)) and (na(oppositeSpacing) or f_level_far_enough(supPrices, ph, oppositeSpacing))
            f_add_level(resPrices, resBirths, resTouched, resLines, ph, bar_index - pivotLen, bearColor, showResistanceLevels)

    if not na(pl)
        if (na(levelSpacing) or f_level_far_enough(supPrices, pl, levelSpacing)) and (na(oppositeSpacing) or f_level_far_enough(resPrices, pl, oppositeSpacing))
            f_add_level(supPrices, supBirths, supTouched, supLines, pl, bar_index - pivotLen, bullColor, showSupportLevels)

    f_prune_wrong_side_levels(resPrices, resBirths, resTouched, resLines, -1, close)
    f_prune_wrong_side_levels(supPrices, supBirths, supTouched, supLines, 1, close)

    if array.size(resLines) > 0
        for i = 0 to array.size(resLines) - 1
            line resLn = array.get(resLines, i)
            if not na(resLn)
                line.set_color(resLn, color.new(bearColor, f_level_line_alpha(i)))
                line.set_width(resLn, i == 0 ? math.min(levelLineWidth + 1, 4) : levelLineWidth)

    if array.size(supLines) > 0
        for i = 0 to array.size(supLines) - 1
            line supLn = array.get(supLines, i)
            if not na(supLn)
                line.set_color(supLn, color.new(bullColor, f_level_line_alpha(i)))
                line.set_width(supLn, i == 0 ? math.min(levelLineWidth + 1, 4) : levelLineWidth)

    f_clear_labels(resLevelTags)
    f_clear_labels(supLevelTags)

    if showLevelTags and showResistanceLevels and array.size(resPrices) > 0
        for i = 0 to array.size(resPrices) - 1
            float rLvl = array.get(resPrices, i)
            bool rUnderTest = evtActive and evtDir == -1 and not na(evtLevel) and math.abs(rLvl - evtLevel) <= syminfo.mintick
            if not rUnderTest
                label rTag = label.new(bar_index + f_level_tag_x_offset(i), rLvl, "RES " + str.tostring(i + 1) + "  " + f_price(rLvl), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = f_text_on(bearColor), color = color.new(bearColor, f_level_tag_alpha(i)), size = f_size(labelSizeInput))
                array.push(resLevelTags, rTag)

    if showLevelTags and showSupportLevels and array.size(supPrices) > 0
        for i = 0 to array.size(supPrices) - 1
            float sLvl = array.get(supPrices, i)
            bool sUnderTest = evtActive and evtDir == 1 and not na(evtLevel) and math.abs(sLvl - evtLevel) <= syminfo.mintick
            if not sUnderTest
                label sTag = label.new(bar_index + f_level_tag_x_offset(i), sLvl, "SUP " + str.tostring(i + 1) + "  " + f_price(sLvl), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = f_text_on(bullColor), color = color.new(bullColor, f_level_tag_alpha(i)), size = f_size(labelSizeInput))
                array.push(supLevelTags, sTag)

    if not evtActive and not na(atr) and atr > 0
        int touchedDir = 0
        float touchedLevel = na
        int touchedIdx = na

        if array.size(resPrices) > 0
            for i = 0 to array.size(resPrices) - 1
                float lvl = array.get(resPrices, i)
                int born = array.get(resBirths, i)
                int lastTouch = array.get(resTouched, i)
                bool canTest = bar_index > born and bar_index - lastTouch >= minBarsBetweenTests
                bool isTouch = high >= lvl - tol and low <= lvl + tol
                if canTest and isTouch
                    touchedDir := -1
                    touchedLevel := lvl
                    touchedIdx := i
                    break

        if touchedDir == 0 and array.size(supPrices) > 0
            for i = 0 to array.size(supPrices) - 1
                float lvl = array.get(supPrices, i)
                int born = array.get(supBirths, i)
                int lastTouch = array.get(supTouched, i)
                bool canTest = bar_index > born and bar_index - lastTouch >= minBarsBetweenTests
                bool isTouch = high >= lvl - tol and low <= lvl + tol
                if canTest and isTouch
                    touchedDir := 1
                    touchedLevel := lvl
                    touchedIdx := i
                    break

        if touchedDir != 0 and not na(touchedIdx)
            evtActive := true
            evtDir := touchedDir
            evtLevel := touchedLevel
            evtAtrRef := atr
            evtTolRef := tol
            evtStartBar := bar_index
            evtBestFav := 0.0
            evtWorstAdv := 0.0
            evtPeakBarOffset := 0

            if evtDir == -1
                array.set(resTouched, touchedIdx, bar_index)
                bearTouchThisBar := true
            else
                array.set(supTouched, touchedIdx, bar_index)
                bullTouchThisBar := true

            f_delete_box(activeZoneBox)
            f_delete_box(activeCorridorBox)
            f_delete_label(activeZoneTag)
            f_delete_label(activeZoneBadge)
            f_delete_label(activeCorridorBadge)
            activeZoneBox := na
            activeCorridorBox := na
            activeZoneTag := na
            activeZoneBadge := na
            activeCorridorBadge := na

            color sideColor = evtDir == 1 ? bullColor : bearColor
            if showActiveZone
                activeZoneBox := box.new(evtStartBar, evtLevel + evtTolRef, bar_index + 1, evtLevel - evtTolRef, xloc = xloc.bar_index, border_color = color.new(sideColor, 0), bgcolor = color.new(sideColor, zoneOpacity), border_width = 1)
                if showCenteredZoneBadges
                    activeZoneBadge := label.new(f_badge_x(evtStartBar, bar_index + 1), evtLevel, evtDir == 1 ? "SUPPORT TEST" : "RESISTANCE TEST", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = f_text_on(sideColor), color = color.new(sideColor, 8), size = f_size(labelSizeInput), textalign = text.align_center)

            if showReactionCorridor
                float corridorTop = evtDir == 1 ? evtLevel + evtAtrRef * corridorDepthATR : evtLevel + evtTolRef
                float corridorBottom = evtDir == 1 ? evtLevel - evtTolRef : evtLevel - evtAtrRef * corridorDepthATR
                activeCorridorBox := box.new(evtStartBar, corridorTop, evtStartBar + reactionWindow, corridorBottom, xloc = xloc.bar_index, border_color = color.new(sideColor, 0), bgcolor = color.new(sideColor, corridorOpacity), border_width = 1)
                if showCenteredZoneBadges
                    string roomText = evtDir == 1 ? "BULL REACTION ROOM" : "BEAR REACTION ROOM"
                    activeCorridorBadge := label.new(f_badge_x(evtStartBar, evtStartBar + reactionWindow), (corridorTop + corridorBottom) / 2, roomText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = f_text_on(sideColor), color = color.new(sideColor, 8), size = f_size(labelSizeInput), textalign = text.align_center)

            if showActiveStatusTag
                string zoneText = (evtDir == 1 ? "BULL WINDOW " : "BEAR WINDOW ") + "0/" + str.tostring(reactionWindow)
                float zoneBaseY = evtDir == 1 ? evtLevel - evtTolRef * 5.8 : evtLevel + evtTolRef * 5.8
                [zoneX, zoneY] = f_label_slot(evtDir, zoneBaseY, evtAtrRef, bar_index + 1, placedLabelXs, placedLabelYs)
                activeZoneTag := label.new(zoneX, zoneY, zoneText, xloc = xloc.bar_index, yloc = yloc.price, style = evtDir == 1 ? label.style_label_up : label.style_label_down, textcolor = f_text_on(sideColor), color = color.new(sideColor, 0), size = f_size(labelSizeInput))
                f_register_slot(zoneX, zoneY, placedLabelXs, placedLabelYs, maxHistoricalLabels)

    if evtActive and not na(evtAtrRef) and evtAtrRef > 0
        int barsElapsed = bar_index - evtStartBar
        float favNow = evtDir == 1 ? math.max(0.0, high - evtLevel) / evtAtrRef : math.max(0.0, evtLevel - low) / evtAtrRef
        float advNow = evtDir == 1 ? math.max(0.0, evtLevel - low) / evtAtrRef : math.max(0.0, high - evtLevel) / evtAtrRef

        if favNow > evtBestFav
            evtBestFav := favNow
            evtPeakBarOffset := barsElapsed

        evtWorstAdv := math.max(evtWorstAdv, advNow)

        if showActiveZone and not na(activeZoneBox)
            box.set_right(activeZoneBox, bar_index + 1)
            box.set_top(activeZoneBox, evtLevel + evtTolRef)
            box.set_bottom(activeZoneBox, evtLevel - evtTolRef)
            if showCenteredZoneBadges and not na(activeZoneBadge)
                label.set_x(activeZoneBadge, f_badge_x(evtStartBar, bar_index + 1))
                label.set_y(activeZoneBadge, evtLevel)

        if showReactionCorridor and not na(activeCorridorBox)
            float corridorTop = evtDir == 1 ? evtLevel + evtAtrRef * corridorDepthATR : evtLevel + evtTolRef
            float corridorBottom = evtDir == 1 ? evtLevel - evtTolRef : evtLevel - evtAtrRef * corridorDepthATR
            box.set_right(activeCorridorBox, evtStartBar + reactionWindow)
            box.set_top(activeCorridorBox, corridorTop)
            box.set_bottom(activeCorridorBox, corridorBottom)
            if showCenteredZoneBadges and not na(activeCorridorBadge)
                label.set_x(activeCorridorBadge, f_badge_x(evtStartBar, evtStartBar + reactionWindow))
                label.set_y(activeCorridorBadge, (corridorTop + corridorBottom) / 2)

        if showActiveStatusTag and not na(activeZoneTag)
            string zoneProgressText = (evtDir == 1 ? "BULL WINDOW " : "BEAR WINDOW ") + str.tostring(barsElapsed) + "/" + str.tostring(reactionWindow)
            float zoneBaseY = evtDir == 1 ? evtLevel - evtTolRef * 5.8 : evtLevel + evtTolRef * 5.8
            [zoneX, zoneY] = f_label_slot(evtDir, zoneBaseY, evtAtrRef, bar_index + 1, placedLabelXs, placedLabelYs)
            label.set_x(activeZoneTag, zoneX)
            label.set_y(activeZoneTag, zoneY)
            label.set_text(activeZoneTag, zoneProgressText)

        if barsElapsed >= reactionWindow
            float netMove = evtDir == 1 ? math.max(0.0, close - evtLevel) / evtAtrRef : math.max(0.0, evtLevel - close) / evtAtrRef
            float retention = evtBestFav > 0 ? netMove / evtBestFav : 0.0

            float strengthScore = f_clamp(evtBestFav / 1.5 * 35.0, 0.0, 35.0)
            float speedScore = f_clamp((1.0 - float(evtPeakBarOffset) / float(reactionWindow)) * 20.0, 0.0, 20.0)
            float cleanScore = f_clamp(20.0 - evtWorstAdv * 10.0, 0.0, 20.0)
            float followScore = f_clamp(retention * 15.0, 0.0, 15.0)
            float failPenalty = f_clamp(evtWorstAdv * 15.0, 0.0, 15.0)
            float finalScore = f_clamp(strengthScore + speedScore + cleanScore + followScore - failPenalty, 0.0, 100.0)
            string finalClass = f_score_class(finalScore)
            string resultText = (evtDir == 1 ? "BULL " : "BEAR ") + str.tostring(int(math.round(finalScore))) + " - " + finalClass
            color resultColor = f_score_color(finalScore, evtDir)
            color resultTextColor = f_text_on(resultColor)
            float yLoc = evtDir == 1 ? low - evtAtrRef * labelOffsetATR : high + evtAtrRef * labelOffsetATR

            if showReactionLabels and (labelCooldownBars == 0 or na(lastResultBar) or bar_index - lastResultBar >= labelCooldownBars)
                if not showHistoricalLabels
                    f_clear_labels(resultLabels)
                    array.clear(placedLabelXs)
                    array.clear(placedLabelYs)
                [resultX, resultY] = f_label_slot(evtDir, yLoc, evtAtrRef, bar_index + resultLabelShiftBars + 1, placedLabelXs, placedLabelYs)
                label resultLabel = label.new(resultX, resultY, resultText, xloc = xloc.bar_index, yloc = yloc.price, style = evtDir == 1 ? label.style_label_up : label.style_label_down, textcolor = resultTextColor, color = resultColor, size = f_size(labelSizeInput))
                array.push(resultLabels, resultLabel)
                f_trim_labels(resultLabels, showHistoricalLabels ? maxHistoricalLabels : 1)
                f_register_slot(resultX, resultY, placedLabelXs, placedLabelYs, showHistoricalLabels ? maxHistoricalLabels : 1)
                lastResultBar := bar_index

            if evtDir == 1
                lastBullScore := finalScore
                lastBullClass := finalClass
            else
                lastBearScore := finalScore
                lastBearClass := finalClass

            reactionScoredEvent := true
            efficientReactionEvent := finalScore >= 80

            f_delete_box(activeZoneBox)
            f_delete_box(activeCorridorBox)
            f_delete_label(activeZoneTag)
            f_delete_label(activeZoneBadge)
            f_delete_label(activeCorridorBadge)
            activeZoneBox := na
            activeCorridorBox := na
            activeZoneTag := na
            activeZoneBadge := na
            activeCorridorBadge := na

            evtActive := false
            evtDir := 0
            evtLevel := na
            evtAtrRef := na
            evtTolRef := na
            evtStartBar := na
            evtBestFav := 0.0
            evtWorstAdv := 0.0
            evtPeakBarOffset := 0

if not showActiveZone
    f_delete_box(activeZoneBox)
    f_delete_label(activeZoneBadge)
    activeZoneBox := na
    activeZoneBadge := na
if not showReactionCorridor
    f_delete_box(activeCorridorBox)
    f_delete_label(activeCorridorBadge)
    activeCorridorBox := na
    activeCorridorBadge := na
if not showActiveStatusTag and not na(activeZoneTag)
    f_delete_label(activeZoneTag)
    activeZoneTag := na
if not showCenteredZoneBadges
    f_delete_label(activeZoneBadge)
    f_delete_label(activeCorridorBadge)
    activeZoneBadge := na
    activeCorridorBadge := na

//------------------------------------------------------------------------------
// Touch Markers
//------------------------------------------------------------------------------
plotshape(showTouchMarkers and bullTouchThisBar, title = "Bullish Touch", style = shape.diamond, size = size.tiny, location = location.belowbar, color = color.new(bullColor, 0), text = "")
plotshape(showTouchMarkers and bearTouchThisBar, title = "Bearish Touch", style = shape.diamond, size = size.tiny, location = location.abovebar, color = color.new(bearColor, 0), text = "")

//------------------------------------------------------------------------------
// Panel
//------------------------------------------------------------------------------
var table panel = table.new(f_pos(panelPositionInput), 2, 6, border_width = 1, border_color = f_panel_border(), frame_color = f_panel_border(), frame_width = 1)

if barstate.islast
    table.set_position(panel, f_pos(panelPositionInput))
    table.clear(panel, 0, 0, 1, 5)
    if showPanel
        table.merge_cells(panel, 0, 0, 1, 0)
        f_panel_cell(panel, 0, 0, "AG Pro Reaction Efficiency Meter", f_text_on(headerBg), headerBg, "center")

        string statusText = evtActive ? (evtDir == 1 ? "BULL ACTIVE" : "BEAR ACTIVE") : "IDLE"
        color statusColor = evtActive ? (evtDir == 1 ? bullColor : bearColor) : f_panel_label()
        string bullText = na(lastBullScore) ? "n/a" : str.tostring(int(math.round(lastBullScore))) + " / " + lastBullClass
        string bearText = na(lastBearScore) ? "n/a" : str.tostring(int(math.round(lastBearScore))) + " / " + lastBearClass
        string progressText = evtActive and not na(evtStartBar) ? str.tostring(bar_index - evtStartBar) + " / " + str.tostring(reactionWindow) : "n/a"

        f_panel_cell(panel, 0, 1, "Status", f_panel_label(), f_row_bg(1), "left")
        f_panel_cell(panel, 1, 1, statusText, statusColor, f_row_bg(1), "right")
        f_panel_cell(panel, 0, 2, "Last Bull", f_panel_label(), f_row_bg(2), "left")
        f_panel_cell(panel, 1, 2, bullText, na(lastBullScore) ? f_panel_value() : f_score_color(lastBullScore, 1), f_row_bg(2), "right")
        f_panel_cell(panel, 0, 3, "Last Bear", f_panel_label(), f_row_bg(3), "left")
        f_panel_cell(panel, 1, 3, bearText, na(lastBearScore) ? f_panel_value() : f_score_color(lastBearScore, -1), f_row_bg(3), "right")
        f_panel_cell(panel, 0, 4, "Window", f_panel_label(), f_row_bg(4), "left")
        f_panel_cell(panel, 1, 4, progressText, evtActive ? accentColor : f_panel_value(), f_row_bg(4), "right")
        f_panel_cell(panel, 0, 5, "Mode", f_panel_label(), f_row_bg(5), "left")
        f_panel_cell(panel, 1, 5, "REACTION LENS", f_panel_value(), f_row_bg(5), "right")

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(alertReactionDone and reactionScoredEvent, "Reaction Efficiency Scored", "Reaction Efficiency Meter: a reaction window has been scored on {{ticker}} {{interval}}.")
alertcondition(alertEfficient and efficientReactionEvent, "Efficient Reaction", "Reaction Efficiency Meter: an efficient reaction has appeared on {{ticker}} {{interval}}.")
````

# Hull MA Trend Zones [AGPro Series]

- url: https://www.tradingview.com/script/J6TYZdIP-Hull-MA-Trend-Zones-AGPro-Series/
- type: indicator
- pine_id: PUB;8e1ec7ac9fcd499a959c30f3f97ee5e0
- version: 3.0

## Description

Hull MA Trend Zones [AGPro Series]

📌 Overview

Hull MA Trend Zones [AGPro Series] is a premium HMA trend overlay built for traders who want a cleaner way to read Hull Moving Average direction, slope quality, and pullback behavior.

The script is centered on one clear idea: a strong HMA trend should not only move above or below a moving average; it should show measurable slope, orderly ribbon structure, and controlled pullback behavior around the active HMA path.

Instead of presenting a crowded moving average wall, the script uses a focused three-line HMA structure, a subtle pullback band, and concept-native trend zones that are tied directly to the active Hull MA state.

⚙️ How It Works

The engine calculates a fast HMA, an anchor HMA, and a slow HMA.

The anchor HMA is the main decision line. Its slope is normalized with ATR so the script can judge whether the current Hull MA movement is weak, transitional, or directional.

The ribbon structure then checks whether the fast, anchor, and slow HMA lines are aligned. This separates clean trend movement from mixed or unstable movement.

Finally, the pullback layer evaluates whether price is extending away from the HMA, testing the HMA zone, holding the HMA zone, rejecting from the HMA zone, or failing the active trend path.

🧭 What The Script Shows

- HMA ribbon for clean trend direction.
- ATR-based HMA pullback band around the anchor HMA.
- Rectangular HMA slope zones created from active directional states.
- Confirmed, quality-gated Bull Turn and Bear Turn labels.
- Optional Hold and Reject labels for pullback events.
- A compact AGPro panel with HMA State, Slope Strength, Pullback Status, and Quality Score.

📊 AGPro Panel

The panel is designed for fast scanning without taking over the chart.

HMA State shows whether the active read is bullish, bearish, transitional, or neutral.

Slope Strength converts the anchor HMA slope into a clear percentage-style reading.

Pullback Status explains whether price is extending, testing, holding, rejecting, or failing the HMA trend zone.

Quality Score combines slope strength, ribbon alignment, and pullback behavior into a single 0-100 reading.

🎯 What Makes It Different

Hull MA Trend Zones is not a generic moving average ribbon, not a ribbon compression map, and not a broad support/resistance tool.

Its focus is narrower and more practical: HMA slope, HMA trend-zone behavior, and pullback-to-HMA quality.

The rectangular zones are not drawn as generic support or resistance. They are HMA slope zones created from the active trend state and the ATR-sized HMA pullback area. This keeps the script visually useful while avoiding overlap with broader zone, corridor, or compression-style indicators.

The default visual design is intentionally restrained. Pullback labels are optional, turn labels require confirmation and a minimum quality score, and old zones are capped so the chart keeps a cleaner premium look on both intraday and higher-timeframe charts.

🔧 Key Settings

Fast HMA Length controls the responsive side of the ribbon.

Anchor HMA Length controls the main trend path, slope state, pullback band, and panel logic.

Slow HMA Length helps identify whether the HMA ribbon is aligned or still transitional.

Slope Lookback and Trend Slope Threshold control how selective the HMA state engine is.

Zone Width ATR controls the height of the HMA pullback band and slope-zone area.

Zone Forward Bars controls how far the active slope zone projects while the same trend state remains valid.

Turn Confirmation and Minimum Turn Label Score control how selective the default turn labels are.

Label Cooldown Bars, Max Visible Labels, and Label Offset ATR keep chart density suitable for publication-quality screenshots.

Panel Location, Panel Theme, Label Font Size, and Panel Font Size are adjustable.

✅ Suggested Use

Use Hull MA Trend Zones to study trend continuation, Hull MA pullback quality, HMA slope transitions, and cleaner moving-average trend behavior.

It is especially useful when you want an HMA-focused overlay that remains readable on active charts and avoids the clutter of large multi-average systems.

The script is designed as a public-free AGPro Series tool with a clean visual identity, a focused HMA concept, and a TradingView-safe publication structure.

## Source Code

````pine
// -----------------------------------------------
// Hull MA Trend Zones [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.1
//
// Hull MA Trend Zones is a responsive moving average trend overlay built around
// HMA slope, HMA trend zones, and pullback-to-HMA quality. It uses a clean Hull
// Moving Average ribbon, ATR-normalized slope strength, controlled turn labels,
// and concept-native slope zones to help traders read trend continuation quality
// without turning the chart into a generic moving average compression map. A
// cumulative Turn Follow-Through engine measures, on this chart and timeframe,
// how often confirmed HMA turns actually traveled a full ATR in the new
// direction before the trend flipped back, and a clear next-action line turns
// the trend map into a decision tool.
// -----------------------------------------------

//@version=6
indicator("Hull MA Trend Zones [AGPro Series]",
     shorttitle = "AGP HMTZ",
     overlay = true,
     max_labels_count = 300,
     max_boxes_count = 120,
     max_lines_count = 50)

// -----------------------------------------------
// AGPro Color Palette
// -----------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBg       = color.rgb(15, 23, 42)
panelBorder   = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullBase      = color.rgb(34, 197, 166)
bearBase      = color.rgb(244, 114, 182)
neutralBase   = color.rgb(245, 189, 92)
accentBase    = color.rgb(129, 140, 248)

// -----------------------------------------------
// Inputs
// -----------------------------------------------
groupCore = "Core Engine"
src = input.source(close, "Source", group = groupCore,
     tooltip = "Price source used to calculate the Hull Moving Average ribbon and the anchor trend path.")
fastLenInput = input.int(21, "Fast HMA Length", minval = 2, group = groupCore,
     tooltip = "Fast Hull Moving Average length. This line makes the ribbon responsive to early changes in trend speed.")
anchorLenInput = input.int(34, "Anchor HMA Length", minval = 3, group = groupCore,
     tooltip = "Main Hull Moving Average length. The anchor HMA drives slope state, pullback evaluation, and the trend-zone reference.")
slowLenInput = input.int(55, "Slow HMA Length", minval = 4, group = groupCore,
     tooltip = "Slow Hull Moving Average length. This line helps classify whether the HMA ribbon is aligned or still transitional.")
slopeLookback = input.int(5, "Slope Lookback", minval = 1, maxval = 50, group = groupCore,
     tooltip = "Number of bars used to measure the anchor HMA slope. Higher values reduce noise and make trend turns more selective.")
atrLen = input.int(14, "ATR Length", minval = 1, group = groupCore,
     tooltip = "ATR length used to normalize HMA slope and size the HMA pullback zone.")
slopeThreshold = input.float(0.18, "Trend Slope Threshold", minval = 0.01, step = 0.01, group = groupCore,
     tooltip = "Minimum ATR-normalized HMA slope required before the engine classifies the market as a directional HMA trend.")
strongSlopeRef = input.float(0.65, "Strong Slope Reference", minval = 0.05, step = 0.05, group = groupCore,
     tooltip = "ATR-normalized slope value treated as a strong HMA trend. It scales the Slope Strength and final quality score.")
followTargetAtr = input.float(1.0, "Follow-Through Target ATR", minval = 0.25, maxval = 5.0, step = 0.25, group = groupCore,
     tooltip = "Distance, in ATR from the turn close, that price must travel in the new trend direction for the Turn Follow-Through statistic to count the turn as a hit.")
followWindow = input.int(40, "Follow-Through Window", minval = 5, maxval = 300, group = groupCore,
     tooltip = "Maximum number of bars a follow-through episode may stay open. If neither the target nor an opposite turn arrives inside this window, the episode counts as a miss.")

groupVisual = "Visuals"
showRibbon = input.bool(true, "Show HMA Ribbon", group = groupVisual,
     tooltip = "Plots the fast, anchor, and slow HMA lines with restrained fills so the trend path remains readable.")
showPullbackBand = input.bool(false, "Show HMA Pullback Band", group = groupVisual,
     tooltip = "Displays a subtle ATR band around the anchor HMA. This is the reference area used for pullback quality analysis.")
showSlopeZones = input.bool(true, "Show Slope Zones", group = groupVisual,
     tooltip = "Creates capped rectangular HMA slope zones when a new directional HMA state starts. These are trend-context zones, not generic support or resistance boxes.")
showZoneText = input.bool(true, "Show Centered Zone Text", group = groupVisual,
     tooltip = "Places one concise trend-context badge at the horizontal and vertical center of every visible HMA slope zone.")
zoneWidthAtr = input.float(0.55, "Zone Width ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupVisual,
     tooltip = "ATR multiplier used to size the HMA pullback band and slope-zone height around the anchor HMA.")
zoneForwardBars = input.int(45, "Zone Forward Bars", minval = 10, maxval = 200, group = groupVisual,
     tooltip = "Number of bars each active HMA slope zone projects to the right while the same directional state remains active.")
zoneTransparency = input.int(91, "Zone Transparency", minval = 70, maxval = 96, group = groupVisual,
     tooltip = "Transparency applied to HMA slope-zone rectangles. Higher values keep the chart cleaner.")
maxSlopeZones = input.int(2, "Max Visible Slope Zones", minval = 1, maxval = 30, group = groupVisual,
     tooltip = "Maximum number of slope-zone boxes kept on the chart. The default retains only the active and most recent completed zone for a cleaner visual hierarchy.")
showHistoryBadges = input.bool(true, "Show Historical Turn Badges", group = groupVisual,
     tooltip = "Keeps a small, spaced history of confirmed HMA turn badges after their slope zones leave the visible zone list.")
maxHistoryBadges = input.int(3, "Max Historical Turn Badges", minval = 1, maxval = 10, group = groupVisual,
     tooltip = "Maximum number of historical turn badges retained. The default combines three historical turns with two visible zones for a balanced publication view.")
showTurnLabels = input.bool(true, "Show Turn Labels", group = groupVisual,
     tooltip = "Displays controlled Bull HMA Turn and Bear HMA Turn labels only when slope zones are hidden. Visible zones already carry the same direction and quality context in centered badges.")
showPullbackLabels = input.bool(false, "Show Pullback Labels", group = groupVisual,
     tooltip = "Displays optional HMA Hold or HMA Reject labels when a pullback tests the anchor HMA zone and resolves cleanly. Disabled by default for a cleaner publication view.")
turnConfirmBarsInput = input.string("2 Bars", "Turn Confirmation", options = ["1 Bar", "2 Bars", "3 Bars"], group = groupVisual,
     tooltip = "Bars required before a turn label is printed. Higher confirmation reduces noisy HMA flip labels in sideways markets.")
minTurnLabelScore = input.int(68, "Minimum Turn Label Score", minval = 0, maxval = 100, group = groupVisual,
     tooltip = "Minimum quality score required for default turn labels. This keeps weak HMA flips off the chart while preserving stronger trend turns.")
labelCooldown = input.int(36, "Label Cooldown Bars", minval = 1, maxval = 100, group = groupVisual,
     tooltip = "Minimum spacing between event labels. This keeps label density moderate and suitable for publication screenshots.")
maxEventLabels = input.int(7, "Max Visible Labels", minval = 5, maxval = 100, group = groupVisual,
     tooltip = "Maximum number of event labels kept on the chart. Older labels are removed to keep the overlay light.")
labelOffsetAtr = input.float(1.05, "Label Offset ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupVisual,
     tooltip = "Vertical ATR offset used to keep labels away from candles so they remain visible on busy charts.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual,
     tooltip = "Controls on-chart event label font size. Normal is the default AGPro publication setting.")
showBarTint = input.bool(false, "Show Subtle Bar Tint", group = groupVisual,
     tooltip = "Optional bar coloring based on the active HMA state. It is disabled by default to keep price action clean.")

groupPanel = "Panel"
showPanel = input.bool(true, "Show Info Panel", group = groupPanel,
     tooltip = "Displays the compact AGPro status panel with HMA state, slope strength, pullback status, score, and turn proof.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"], group = groupPanel,
     tooltip = "Selects where the AGPro panel is placed on the chart.")
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel,
     tooltip = "Controls the panel background and text palette. Dark uses the AGPro slate theme; Light uses a clean high-contrast variant.")
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel,
     tooltip = "Controls the AGPro panel font size. Normal is the default publication setting.")

groupColors = "Colors"
bullColor = input.color(bullBase, "Bull Color", group = groupColors,
     tooltip = "Primary color for bullish HMA trend states, bullish zones, and bullish event labels.")
bearColor = input.color(bearBase, "Bear Color", group = groupColors,
     tooltip = "Primary color for bearish HMA trend states, bearish zones, and bearish event labels.")
neutralColor = input.color(neutralBase, "Neutral Color", group = groupColors,
     tooltip = "Color used when HMA slope is neutral or when the ribbon is in transition.")
accentColor = input.color(accentBase, "Accent Color", group = groupColors,
     tooltip = "Accent color used for mixed or transitional HMA ribbon conditions.")

// -----------------------------------------------
// Helpers
// -----------------------------------------------
f_size(_opt) =>
    switch _opt
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_position(_opt) =>
    switch _opt
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        => position.top_right

f_hma(_source, _length) =>
    int safeLen = math.max(_length, 1)
    int halfLen = math.max(1, int(math.round(safeLen * 0.5)))
    int rootLen = math.max(1, int(math.round(math.sqrt(safeLen))))
    ta.wma(2.0 * ta.wma(_source, halfLen) - ta.wma(_source, safeLen), rootLen)

f_zone_text(_dir, _score) =>
    string sideText = _dir == 1 ? "BULL HMA ZONE" : "BEAR HMA ZONE"
    sideText + " | Q" + str.tostring(int(_score))

// Turn Follow-Through display helpers. Color follows the same rounded
// rate shown in the panel text, and is applied only once the sample is
// sufficient (n >= 8); below that the value stays neutral so a small
// sample never implies confidence.
f_ftText(int _w, int _n) =>
    _n > 0 ? str.tostring(math.round(100.0 * _w / _n)) + "%  (n=" + str.tostring(_n) + ")" : "-  (n=0)"

f_ftColor(int _w, int _n, color _fb) =>
    _r = _n > 0 ? math.round(100.0 * _w / _n) : 0
    _n >= 8 ? (_r >= 55 ? bullColor : _r >= 40 ? neutralColor : bearColor) : _fb

// -----------------------------------------------
// Core calculations
// -----------------------------------------------
int fastLen = math.max(2, fastLenInput)
int anchorLen = math.max(fastLen + 1, anchorLenInput)
int slowLen = math.max(anchorLen + 1, slowLenInput)

hmaFast = f_hma(src, fastLen)
hmaAnchor = f_hma(src, anchorLen)
hmaSlow = f_hma(src, slowLen)

atr = ta.atr(atrLen)
safeAtr = math.max(atr, syminfo.mintick)
zoneHalf = safeAtr * zoneWidthAtr
zoneTop = hmaAnchor + zoneHalf
zoneBottom = hmaAnchor - zoneHalf

slopeRaw = not na(hmaAnchor[slopeLookback]) ? hmaAnchor - hmaAnchor[slopeLookback] : 0.0
slopeUnit = safeAtr > 0.0 ? slopeRaw / safeAtr : 0.0
slopeAbs = math.abs(slopeUnit)
slopeStrength = math.min(100.0, slopeAbs / strongSlopeRef * 100.0)

ribbonBull = hmaFast > hmaAnchor and hmaAnchor > hmaSlow
ribbonBear = hmaFast < hmaAnchor and hmaAnchor < hmaSlow
aboveAnchor = close > hmaAnchor
belowAnchor = close < hmaAnchor

bullCandidate = slopeUnit > slopeThreshold and aboveAnchor
bearCandidate = slopeUnit < -slopeThreshold and belowAnchor

int hmaDir = 0
if bullCandidate
    hmaDir := 1
else if bearCandidate
    hmaDir := -1
else
    hmaDir := 0

string hmaState = "Neutral HMA"
color hmaStateColor = neutralColor
if hmaDir == 1
    hmaState := ribbonBull ? "Bull Trend" : "Bull Transition"
    hmaStateColor := ribbonBull ? bullColor : accentColor
else if hmaDir == -1
    hmaState := ribbonBear ? "Bear Trend" : "Bear Transition"
    hmaStateColor := ribbonBear ? bearColor : accentColor

inHmaBand = close <= zoneTop and close >= zoneBottom
bullPullbackTest = hmaDir == 1 and low <= zoneTop and low >= zoneBottom - zoneHalf
bearPullbackTest = hmaDir == -1 and high >= zoneBottom and high <= zoneTop + zoneHalf
bullFailedPullback = hmaDir == 1 and close < zoneBottom
bearFailedPullback = hmaDir == -1 and close > zoneTop
bullQualityHold = bullPullbackTest and close > hmaAnchor and close >= open
bearQualityHold = bearPullbackTest and close < hmaAnchor and close <= open

string pullbackStatus = "No Active Trend"
color pullbackColor = neutralColor
float pullbackComponent = 40.0
if hmaDir == 1
    if bullFailedPullback
        pullbackStatus := "Bull Pullback Failed"
        pullbackColor := bearColor
        pullbackComponent := 20.0
    else if bullQualityHold
        pullbackStatus := "Quality HMA Hold"
        pullbackColor := bullColor
        pullbackComponent := 100.0
    else if bullPullbackTest or inHmaBand
        pullbackStatus := "Testing HMA Zone"
        pullbackColor := neutralColor
        pullbackComponent := 72.0
    else
        pullbackStatus := "Bull Extension"
        pullbackColor := accentColor
        pullbackComponent := 55.0
else if hmaDir == -1
    if bearFailedPullback
        pullbackStatus := "Bear Pullback Failed"
        pullbackColor := bullColor
        pullbackComponent := 20.0
    else if bearQualityHold
        pullbackStatus := "Quality HMA Reject"
        pullbackColor := bearColor
        pullbackComponent := 100.0
    else if bearPullbackTest or inHmaBand
        pullbackStatus := "Testing HMA Zone"
        pullbackColor := neutralColor
        pullbackComponent := 72.0
    else
        pullbackStatus := "Bear Extension"
        pullbackColor := accentColor
        pullbackComponent := 55.0

float orderScore = 35.0
if hmaDir == 1
    orderScore := ribbonBull ? 100.0 : 62.0
else if hmaDir == -1
    orderScore := ribbonBear ? 100.0 : 62.0

float qualityScore = math.round(math.min(100.0, slopeStrength * 0.45 + orderScore * 0.25 + pullbackComponent * 0.30))
scoreColor = qualityScore >= 75 ? hmaStateColor : qualityScore >= 50 ? neutralColor : accentColor

string slopeText = "Flat " + str.tostring(int(math.round(slopeStrength))) + "%"
color slopeColor = neutralColor
if slopeUnit > slopeThreshold
    slopeText := "Up " + str.tostring(int(math.round(slopeStrength))) + "%"
    slopeColor := bullColor
else if slopeUnit < -slopeThreshold
    slopeText := "Down " + str.tostring(int(math.round(slopeStrength))) + "%"
    slopeColor := bearColor

// -----------------------------------------------
// Plots
// -----------------------------------------------
trendColor = hmaDir == 1 ? bullColor : hmaDir == -1 ? bearColor : neutralColor
ribbonMidColor = ribbonBull or ribbonBear ? trendColor : accentColor

plotFast = plot(showRibbon ? hmaFast : na, "Fast HMA", color = color.new(ribbonMidColor, 22), linewidth = 1)
plotAnchor = plot(showRibbon ? hmaAnchor : na, "Anchor HMA", color = color.new(ribbonMidColor, 0), linewidth = 3)
plotSlow = plot(showRibbon ? hmaSlow : na, "Slow HMA", color = color.new(ribbonMidColor, 38), linewidth = 1)
fill(plotFast, plotAnchor, title = "Fast-Anchor HMA Fill", color = showRibbon ? color.new(ribbonMidColor, 84) : na)
fill(plotAnchor, plotSlow, title = "Anchor-Slow HMA Fill", color = showRibbon ? color.new(ribbonMidColor, 88) : na)

bandTopPlot = plot(showPullbackBand ? zoneTop : na, "HMA Pullback Upper", color = color.new(ribbonMidColor, 72), linewidth = 1)
bandBottomPlot = plot(showPullbackBand ? zoneBottom : na, "HMA Pullback Lower", color = color.new(ribbonMidColor, 72), linewidth = 1)
fill(bandTopPlot, bandBottomPlot, title = "HMA Pullback Band", color = showPullbackBand ? color.new(ribbonMidColor, 93) : na)

barcolor(showBarTint ? color.new(trendColor, 72) : na)

// -----------------------------------------------
// Slope zones and labels
// -----------------------------------------------
var array<box> slopeZones = array.new<box>()
var array<label> slopeZoneBadges = array.new<label>()
var array<int> slopeZoneDirs = array.new<int>()
var array<int> slopeZoneScores = array.new<int>()
var array<label> historicalTurnBadges = array.new<label>()
var array<label> eventLabels = array.new<label>()
var box activeSlopeZone = na
var label activeSlopeBadge = na
var int activeSlopeDir = 0
var int lastTurnLabelBar = na
var int lastPullbackLabelBar = na

f_add_zone(_top, _bottom, _dir, _score) =>
    color zoneColor = _dir == 1 ? bullColor : bearColor
    box createdZone = box.new(left = bar_index, top = _top, right = bar_index + zoneForwardBars, bottom = _bottom,
         bgcolor = color.new(zoneColor, zoneTransparency), border_color = color.new(zoneColor, 45), border_width = 1)
    int badgeX = bar_index + int(math.round(zoneForwardBars * 0.5))
    float badgeY = (_top + _bottom) * 0.5
    label createdBadge = label.new(x = badgeX, y = badgeY,
         text = showZoneText ? f_zone_text(_dir, _score) : "",
         style = label.style_label_center,
         color = showZoneText ? color.new(zoneColor, 0) : color.new(zoneColor, 100),
         textcolor = showZoneText ? headerText : color.new(headerText, 100),
         size = f_size(labelSizeInput))
    array.push(slopeZones, createdZone)
    array.push(slopeZoneBadges, createdBadge)
    array.push(slopeZoneDirs, _dir)
    array.push(slopeZoneScores, int(_score))
    if array.size(slopeZones) > maxSlopeZones
        box oldZone = array.shift(slopeZones)
        label oldBadge = array.shift(slopeZoneBadges)
        int oldDir = array.shift(slopeZoneDirs)
        int oldScore = array.shift(slopeZoneScores)
        int oldLeft = box.get_left(oldZone)
        float oldTop = box.get_top(oldZone)
        float oldBottom = box.get_bottom(oldZone)
        float oldHeight = math.max(oldTop - oldBottom, syminfo.mintick)
        bool historySpaced = array.size(historicalTurnBadges) == 0 or oldLeft - label.get_x(array.get(historicalTurnBadges, array.size(historicalTurnBadges) - 1)) >= labelCooldown
        if showHistoryBadges and historySpaced
            color historyColor = oldDir == 1 ? bullColor : bearColor
            float historyY = oldDir == 1 ? oldBottom - oldHeight * 1.35 : oldTop + oldHeight * 1.35
            historyStyle = oldDir == 1 ? label.style_label_up : label.style_label_down
            string historyText = (oldDir == 1 ? "BULL TURN" : "BEAR TURN") + " | Q" + str.tostring(oldScore)
            label historyBadge = label.new(x = oldLeft, y = historyY, text = historyText,
                 style = historyStyle, color = color.new(historyColor, 0), textcolor = headerText,
                 size = f_size(labelSizeInput))
            array.push(historicalTurnBadges, historyBadge)
            if array.size(historicalTurnBadges) > maxHistoryBadges
                label oldestHistoryBadge = array.shift(historicalTurnBadges)
                label.delete(oldestHistoryBadge)
        box.delete(oldZone)
        label.delete(oldBadge)
    [createdZone, createdBadge]

f_add_label(_x, _y, _txt, _style, _bg, _txtColor, _size) =>
    label createdLabel = label.new(x = _x, y = _y, text = _txt, style = _style,
         color = _bg, textcolor = _txtColor, size = _size)
    array.push(eventLabels, createdLabel)
    if array.size(eventLabels) > maxEventLabels
        label oldLabel = array.shift(eventLabels)
        label.delete(oldLabel)

int turnConfirmBars = turnConfirmBarsInput == "1 Bar" ? 1 : turnConfirmBarsInput == "3 Bars" ? 3 : 2
bool turnUp = false
bool turnDown = false
if turnConfirmBars == 1
    turnUp := hmaDir == 1 and nz(hmaDir[1]) != 1
    turnDown := hmaDir == -1 and nz(hmaDir[1]) != -1
else if turnConfirmBars == 2
    turnUp := hmaDir == 1 and nz(hmaDir[1]) == 1 and nz(hmaDir[2]) != 1
    turnDown := hmaDir == -1 and nz(hmaDir[1]) == -1 and nz(hmaDir[2]) != -1
else
    turnUp := hmaDir == 1 and nz(hmaDir[1]) == 1 and nz(hmaDir[2]) == 1 and nz(hmaDir[3]) != 1
    turnDown := hmaDir == -1 and nz(hmaDir[1]) == -1 and nz(hmaDir[2]) == -1 and nz(hmaDir[3]) != -1

// -----------------------------------------------
// TURN FOLLOW-THROUGH ENGINE (cumulative, non-repaint)
// Every confirmed HMA turn opens one tracking episode with the turn
// close and ATR frozen at the event bar. The episode resolves as a HIT
// when price travels the Follow-Through Target distance in the new
// trend direction, and as a MISS when a confirmed opposite turn
// arrives first or the window expires without contact. Episodes open
// and resolve on confirmed bars only, so the statistic never repaints.
// -----------------------------------------------
var bool  ftOn = false
var int   ftDir = 0
var float ftEntry = na
var float ftAtr = na
var int   ftStart = na
var int   ftWin = 0
var int   ftWins = 0
var int   ftN = 0

bool ftHitEv = false

if ftOn and barstate.isconfirmed
    bool ftHit = ftDir == 1 ? high >= ftEntry + ftAtr * followTargetAtr : low <= ftEntry - ftAtr * followTargetAtr
    bool ftFail = (ftDir == 1 and turnDown) or (ftDir == -1 and turnUp)
    bool ftTimeout = not na(ftStart) and bar_index - ftStart >= ftWin
    if ftHit
        ftN += 1
        ftWins += 1
        ftOn := false
        ftHitEv := true
    else if ftFail or ftTimeout
        ftN += 1
        ftOn := false

if barstate.isconfirmed and not ftOn and (turnUp or turnDown) and not na(atr) and atr > 0.0
    ftOn := true
    ftDir := turnUp ? 1 : -1
    ftEntry := close
    ftAtr := atr
    ftStart := bar_index
    ftWin := followWindow

zoneExit = showSlopeZones and not na(activeSlopeZone) and activeSlopeDir != 0 and hmaDir != activeSlopeDir
zoneBirth = showSlopeZones and hmaDir != 0 and (hmaDir != nz(hmaDir[1]) or na(activeSlopeZone))

if zoneExit and barstate.isconfirmed
    box.set_right(activeSlopeZone, bar_index)
    if not na(activeSlopeBadge)
        label.set_x(activeSlopeBadge, int(math.round((box.get_left(activeSlopeZone) + bar_index) * 0.5)))
    activeSlopeZone := na
    activeSlopeBadge := na
    activeSlopeDir := 0

if zoneBirth and barstate.isconfirmed
    [newSlopeZone, newSlopeBadge] = f_add_zone(zoneTop, zoneBottom, hmaDir, qualityScore)
    activeSlopeZone := newSlopeZone
    activeSlopeBadge := newSlopeBadge
    activeSlopeDir := hmaDir

if showSlopeZones and not na(activeSlopeZone) and hmaDir == activeSlopeDir
    box.set_right(activeSlopeZone, bar_index + zoneForwardBars)
    if not na(activeSlopeBadge)
        label.set_x(activeSlopeBadge, int(math.round((box.get_left(activeSlopeZone) + bar_index + zoneForwardBars) * 0.5)))
        label.set_y(activeSlopeBadge, (box.get_top(activeSlopeZone) + box.get_bottom(activeSlopeZone)) * 0.5)

if hmaDir == 0
    if not na(activeSlopeZone)
        box.set_right(activeSlopeZone, bar_index)
        if not na(activeSlopeBadge)
            label.set_x(activeSlopeBadge, int(math.round((box.get_left(activeSlopeZone) + bar_index) * 0.5)))
        activeSlopeZone := na
        activeSlopeBadge := na
    activeSlopeDir := 0

labelSize = f_size(labelSizeInput)
canTurnLabel = na(lastTurnLabelBar) or bar_index - lastTurnLabelBar >= labelCooldown
turnLabelQualityOk = qualityScore >= minTurnLabelScore
bool showStandaloneTurnLabels = showTurnLabels and not showSlopeZones
if showStandaloneTurnLabels and turnUp and turnLabelQualityOk and canTurnLabel and barstate.isconfirmed
    f_add_label(bar_index, low - safeAtr * labelOffsetAtr, "Bull Turn\nQ " + str.tostring(int(qualityScore)), label.style_label_up, color.new(bullColor, 0), headerText, labelSize)
    lastTurnLabelBar := bar_index
else if showStandaloneTurnLabels and turnDown and turnLabelQualityOk and canTurnLabel and barstate.isconfirmed
    f_add_label(bar_index, high + safeAtr * labelOffsetAtr, "Bear Turn\nQ " + str.tostring(int(qualityScore)), label.style_label_down, color.new(bearColor, 0), headerText, labelSize)
    lastTurnLabelBar := bar_index

prevBullQualityHold = bullQualityHold[1] == true
prevBearQualityHold = bearQualityHold[1] == true
pullbackEvent = (bullQualityHold and not prevBullQualityHold) or (bearQualityHold and not prevBearQualityHold)
canPullbackLabel = na(lastPullbackLabelBar) or bar_index - lastPullbackLabelBar >= labelCooldown
if showPullbackLabels and pullbackEvent and canPullbackLabel and barstate.isconfirmed
    string pbText = bullQualityHold ? "Bull HMA Hold\nQ " + str.tostring(int(qualityScore)) : "Bear HMA Reject\nQ " + str.tostring(int(qualityScore))
    float pbY = bullQualityHold ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    pbStyle = bullQualityHold ? label.style_label_up : label.style_label_down
    color pbColor = bullQualityHold ? color.new(bullColor, 0) : color.new(bearColor, 0)
    f_add_label(bar_index, pbY, pbText, pbStyle, pbColor, headerText, labelSize)
    lastPullbackLabelBar := bar_index

// -----------------------------------------------
// Info panel
// -----------------------------------------------
panelTextSize = f_size(panelSizeInput)
panelPos = f_position(panelPositionInput)
isLightPanel = panelThemeInput == "Light"
panelBgUse = isLightPanel ? color.rgb(248, 250, 252) : panelBg
panelBorderUse = isLightPanel ? color.rgb(203, 213, 225) : panelBorder
panelLabelUse = isLightPanel ? color.rgb(71, 85, 105) : panelLabelCol
var table infoPanel = table.new(panelPos, 2, 8, bgcolor = panelBgUse, frame_color = panelBorderUse, frame_width = 1, border_color = panelBorderUse, border_width = 1)

string workflowText = "Wait for HMA turn"
color workflowColor = neutralColor
if hmaDir == 1
    if bullFailedPullback
        workflowText := "Review bull failure"
        workflowColor := bearColor
    else if bullQualityHold
        workflowText := "Track bull continuation"
        workflowColor := bullColor
    else if bullPullbackTest or inHmaBand
        workflowText := "Review bull pullback"
    else
        workflowText := "Wait for bull pullback"
else if hmaDir == -1
    if bearFailedPullback
        workflowText := "Review bear failure"
        workflowColor := bullColor
    else if bearQualityHold
        workflowText := "Track bear continuation"
        workflowColor := bearColor
    else if bearPullbackTest or inHmaBand
        workflowText := "Review bear pullback"
    else
        workflowText := "Wait for bear pullback"

string reviewText = hmaDir == 1 ? "Bull context / " + pullbackStatus : hmaDir == -1 ? "Bear context / " + pullbackStatus : "Neutral context / wait"

if barstate.islast
    table.clear(infoPanel, 0, 0, 1, 7)
    if showPanel
        table.merge_cells(infoPanel, 0, 0, 1, 0)
        table.cell(infoPanel, 0, 0, "AG Pro Hull MA Trend Zones", bgcolor = headerBg, text_color = headerText,
             text_size = panelTextSize, text_halign = text.align_center)
        table.cell(infoPanel, 0, 1, "Workflow", bgcolor = panelBgUse, text_color = panelLabelUse,
             text_size = panelTextSize, text_halign = text.align_left)
        table.cell(infoPanel, 1, 1, workflowText, bgcolor = panelBgUse, text_color = workflowColor,
             text_size = panelTextSize, text_halign = text.align_right)
        table.cell(infoPanel, 0, 2, "HMA State", bgcolor = panelBgUse, text_color = panelLabelUse,
             text_size = panelTextSize, text_halign = text.align_left)
        table.cell(infoPanel, 1, 2, hmaState, bgcolor = panelBgUse, text_color = hmaStateColor,
             text_size = panelTextSize, text_halign = text.align_right)
        table.cell(infoPanel, 0, 3, "Slope Strength", bgcolor = panelBgUse, text_color = panelLabelUse,
             text_size = panelTextSize, text_halign = text.align_left)
        table.cell(infoPanel, 1, 3, slopeText, bgcolor = panelBgUse, text_color = slopeColor,
             text_size = panelTextSize, text_halign = text.align_right)
        table.cell(infoPanel, 0, 4, "Pullback", bgcolor = panelBgUse, text_color = panelLabelUse,
             text_size = panelTextSize, text_halign = text.align_left)
        table.cell(infoPanel, 1, 4, pullbackStatus, bgcolor = panelBgUse, text_color = pullbackColor,
             text_size = panelTextSize, text_halign = text.align_right)
        table.cell(infoPanel, 0, 5, "Quality", bgcolor = panelBgUse, text_color = panelLabelUse,
             text_size = panelTextSize, text_halign = text.align_left)
        table.cell(infoPanel, 1, 5, str.tostring(int(qualityScore)) + "/100", bgcolor = panelBgUse, text_color = scoreColor,
             text_size = panelTextSize, text_halign = text.align_right)
        table.cell(infoPanel, 0, 6, "Turn Proof", bgcolor = panelBgUse, text_color = panelLabelUse,
             text_size = panelTextSize, text_halign = text.align_left)
        table.cell(infoPanel, 1, 6, f_ftText(ftWins, ftN), bgcolor = panelBgUse, text_color = f_ftColor(ftWins, ftN, panelLabelUse),
             text_size = panelTextSize, text_halign = text.align_right)
        table.cell(infoPanel, 0, 7, "Review", bgcolor = panelBgUse, text_color = panelLabelUse,
             text_size = panelTextSize, text_halign = text.align_left)
        table.cell(infoPanel, 1, 7, reviewText, bgcolor = panelBgUse, text_color = accentColor,
             text_size = panelTextSize, text_halign = text.align_right)

// -----------------------------------------------
// Alerts
// -----------------------------------------------
alertcondition(turnUp and barstate.isconfirmed, "Bullish HMA Turn", "Hull MA Trend Zones: bullish HMA turn confirmed.")
alertcondition(turnDown and barstate.isconfirmed, "Bearish HMA Turn", "Hull MA Trend Zones: bearish HMA turn confirmed.")
alertcondition(pullbackEvent and bullQualityHold and barstate.isconfirmed, "Quality HMA Hold", "Hull MA Trend Zones: bullish pullback held the HMA trend zone.")
alertcondition(pullbackEvent and bearQualityHold and barstate.isconfirmed, "Quality HMA Reject", "Hull MA Trend Zones: bearish pullback rejected the HMA trend zone.")
alertcondition(zoneBirth and barstate.isconfirmed, "New HMA Slope Zone", "Hull MA Trend Zones: a new directional HMA slope zone has started.")
alertcondition(ftHitEv, "Turn Follow-Through Hit", "Hull MA Trend Zones: price reached the follow-through target after a confirmed HMA turn.")
````

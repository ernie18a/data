# Chandelier Exit Flip Zones [AGPro Series]

- url: https://www.tradingview.com/script/Q40nkmjM-Chandelier-Exit-Flip-Zones-AGPro-Series/
- type: indicator
- pine_id: PUB;1ebfa5d54edb4a90ad063d1044c75c38
- version: 4.0

## Description

Chandelier Exit Flip Zones [AGPro Series]

Chandelier Exit Flip Zones [AGPro Series] is a premium ATR trailing-stop and exit-state engine built for traders who want more than a simple stop line on the chart.

The script takes the classic Chandelier Exit concept and turns it into a structured decision layer:

Chandelier trail -> trail-side flip -> flip quality -> continuation state -> exit-pressure awareness

The result is a clean public-free tool for reading trend continuation, trailing-stop pressure, and Chandelier flip transitions without turning the chart into a crowded signal board.

📌 Why This Script Exists

Chandelier Exit is one of the most practical and searched trailing-stop concepts because it connects trend direction with volatility. Many traders use it to trail positions, judge when momentum is still holding, or identify when price is starting to lose distance from its active stop area.

Most Chandelier tools stop at the line.

This script adds the missing context:

- Which side of the Chandelier trail is active?
- How far is price from the trail in ATR terms?
- Was the latest trail flip strong or weak?
- Is the market still in continuation mode?
- Is price compressing back into an exit-watch area?
- Did the transition create a clean forward flip zone?

That extra layer is what makes the script more useful than a standard ATR trailing-stop overlay.

⚡ What Makes It Different From Standard Chandelier Exit Indicators

Most public Chandelier Exit indicators are visually simple. They usually plot a long stop, a short stop, and sometimes a basic flip marker.

Chandelier Exit Flip Zones [AGPro Series] is built around a stronger reading model.

It evaluates each trail flip through a quality score that combines:

- Trail-break strength
- EMA trend agreement
- Range expansion
- Candle close location
- Optional volume participation

This means the script does not treat every flip equally. A weak flip inside chop is not presented with the same weight as a cleaner transition with better structure, stronger expansion, and better directional agreement.

The script also uses quality-filtered Flip Zones. These boxes are not generic support and resistance areas. They are drawn around the Chandelier transition area where price breaks the previous trail and establishes a new active side. The purpose is to mark the actual trail-flip area, not to fill the chart with unrelated levels.

🧭 How It Is Different From Other AGProLabs Scripts

This script was intentionally kept in a narrow Chandelier Exit lane so it does not overlap with other AGProLabs public releases.

It is not a SuperTrend script. SuperTrend logic is built around a different volatility-band mechanism, while this tool is built around Chandelier high/low structure anchors and ATR trail distance.

It is not an ATR compression or ATR breakout script. Those concepts focus on volatility contraction, breakout pressure, or expansion behavior. This script focuses on the active trailing-stop side, distance from the Chandelier trail, and exit-state awareness.

It is not a generic trend dashboard. The panel is compact and centered on trail side, ATR multiple, distance, flip quality, and continuation or exit-watch state.

It is not a support/resistance zone engine. The only zones are concept-native Flip Zones created from qualified Chandelier trail transitions.

This keeps the script differentiated, practical, and publication-safe inside the AGPro Series catalog.

✅ Core Features

- Chandelier Exit trail based on ATR distance and recent structure anchors
- Long-side and short-side trail state
- Bullish and bearish trail-flip detection
- Flip quality score from 0 to 100
- Prime, qualified, and developing flip classifications
- ATR distance from the active trail
- Percentage distance from the active trail
- Continuation, control, and exit-watch state logic
- Quality-filtered forward Flip Zones
- Optional exit-watch labels, disabled by default for a cleaner public view
- Label cooldown and maximum label controls
- Maximum visible zone control
- Adjustable label font size
- Adjustable panel font size
- Adjustable panel location
- Dark, light, and auto panel theme options
- AGPro-style panel with a single merged blue header row
- Alerts for bullish flips, bearish flips, prime flips, and exit-watch conditions

📊 Panel Readout

The panel is designed to give a fast read without visual overload:

Trail Side
Shows whether the active Chandelier trail is currently long-side or short-side.

ATR Multiple
Shows the volatility multiple used by the current trail.

Distance
Shows how far price is from the active trail in both ATR and percentage terms.

Flip Quality
Displays the most recent flip score and classification.

State
Classifies the current condition as continuation, control, or exit watch.

🎯 How To Read It

A strong Chandelier flip means price has crossed the prior active trail with enough quality to deserve attention. The score helps separate cleaner transitions from weaker flips in noisy conditions.

A continuation state means price has moved far enough from the active trail and still has trend agreement behind it. This is the cleaner trend-following condition.

A control state means price is on one side of the trail, but the continuation profile is not yet strong enough to classify as a high-conviction continuation read.

An exit-watch state means price has compressed back toward the active Chandelier trail. This does not make the script a prediction tool. It simply highlights that the active trend has less distance from its trailing-stop structure and deserves closer attention.

💎 Why Traders May Like It

The script is useful because it keeps the original simplicity of Chandelier Exit while adding the context traders usually have to judge manually.

It can help users read:

- Trend-following continuation quality
- ATR trailing-stop distance
- Trail-side transitions
- Cleaner Chandelier flip zones
- Exit-pressure areas near the active trail
- Strong versus weak flip behavior

The default view is intentionally restrained. Exit-watch labels are available, but disabled by default so the first chart impression stays cleaner. Flip labels and zones are also filtered by score so the chart does not get flooded during sideways periods.

🛠 Suggested Use Cases

- Trend-following exit management
- Swing-trading trail awareness
- Crypto trend continuation tracking
- Forex and index trailing-stop context
- Stock trend-state monitoring
- Identifying stronger Chandelier trail transitions
- Monitoring when price compresses back toward the active trail

⚙️ Recommended Default Style

The defaults are tuned for a public-free premium view:

- ATR Length: 22
- Structure Lookback: 22
- ATR Multiple: 3.0
- Flip Zones: enabled
- Minimum Zone Score: 50
- Minimum Flip Label Score: 45
- Exit Labels: disabled by default
- Label Font Size: Normal
- Panel Font Size: Normal
- Panel Theme: Dark

These settings keep the tool immediately usable while preserving a clean chart presentation.

🔹 In One Sentence

Chandelier Exit Flip Zones [AGPro Series] turns a classic ATR trailing stop into a cleaner Chandelier trail, flip-quality, continuation-state, and exit-pressure map built for serious chart reading without unnecessary clutter.

## Source Code

````pine
// -------------------------------------------------
// Chandelier Exit Flip Zones [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Chandelier Exit Flip Zones is a premium ATR trailing stop and exit-state
// engine for traders who want cleaner trend continuation reads, Chandelier
// trail flips, ATR distance context, centered flip-zone ownership, measured
// continuation proof and confirmed exit-pressure events. A single visual
// hierarchy prevents qualified flips from being narrated twice on the chart.
// -------------------------------------------------

//@version=6
indicator("Chandelier Exit Flip Zones [AGPro Series]",
     shorttitle = "AG Pro CEZ",
     overlay = true,
     max_labels_count = 300,
     max_boxes_count = 120,
     max_lines_count = 50)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
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
groupEngine = "Chandelier Engine"
atrLength = input.int(22, "ATR Length", minval = 2, group = groupEngine,
     tooltip = "Defines the volatility window used to calculate the Chandelier trailing stop distance.")
structureLength = input.int(22, "Structure Lookback", minval = 2, group = groupEngine,
     tooltip = "Defines the highest high and lowest low window used as the Chandelier anchor.")
atrMultiple = input.float(3.0, "ATR Multiple", minval = 0.5, maxval = 10.0, step = 0.1, group = groupEngine,
     tooltip = "Controls how far the active Chandelier trail is placed from the recent structure extreme.")
confirmOnClose = input.bool(true, "Confirm Flips On Bar Close", group = groupEngine,
     tooltip = "When enabled, flip labels and zones are confirmed only after the bar closes.")

groupQuality = "Flip Quality"
fastEmaLength = input.int(21, "Fast Trend EMA", minval = 2, group = groupQuality,
     tooltip = "Fast trend filter used to score whether a Chandelier flip agrees with short-term direction.")
slowEmaLength = input.int(55, "Slow Trend EMA", minval = 3, group = groupQuality,
     tooltip = "Slow trend filter used to classify continuation quality after a Chandelier flip.")
useVolumeScore = input.bool(true, "Use Volume In Quality Score", group = groupQuality,
     tooltip = "Includes relative volume participation in the flip-quality score when volume data is available.")
volumeLength = input.int(20, "Volume Baseline Length", minval = 2, group = groupQuality,
     tooltip = "Defines the volume average used by the optional participation component of the flip score.")
primeScore = input.int(72, "Prime Flip Threshold", minval = 40, maxval = 95, group = groupQuality,
     tooltip = "Minimum score required for a flip to be classified as a prime-quality Chandelier transition.")
minimumFlipLabelScore = input.int(50, "Minimum Flip Label Score", minval = 0, maxval = 100, group = groupQuality,
     tooltip = "Hides very low-quality flip labels by default so the chart stays clean during choppy conditions.")
continuationTargetAtr = input.float(1.0, "Continuation Target (ATR)", minval = 0.3, maxval = 4.0, step = 0.1, group = groupQuality,
     tooltip = "Distance in ATR that price must travel in the flip direction, before an opposite flip, for a flip to be counted as a successful continuation in the Continuation Rate statistic.")

groupState = "Continuation And Exit State"
continuationAtrDistance = input.float(1.15, "Continuation Distance", minval = 0.2, maxval = 5.0, step = 0.05, group = groupState,
     tooltip = "Minimum ATR distance from the active trail required to classify the trend as a continuation state.")
exitWatchAtrDistance = input.float(0.45, "Exit Watch Distance", minval = 0.05, maxval = 2.0, step = 0.05, group = groupState,
     tooltip = "ATR distance from the active trail where the script starts marking exit-pressure conditions.")
exitCooldownBars = input.int(24, "Exit Label Cooldown", minval = 1, maxval = 100, group = groupState,
     tooltip = "Minimum number of bars between exit-pressure labels to keep chart annotation density controlled.")

groupZones = "Flip Zones"
showFlipZones = input.bool(true, "Show Flip Zones", group = groupZones,
     tooltip = "Draws a rectangular zone around the trail break area when a qualified Chandelier flip appears.")
zoneForwardBars = input.int(48, "Zone Forward Length", minval = 5, maxval = 300, group = groupZones,
     tooltip = "Controls how far each flip zone extends to the right after the original trail transition.")
zoneAtrPadding = input.float(0.12, "Zone ATR Padding", minval = 0.0, maxval = 1.0, step = 0.01, group = groupZones,
     tooltip = "Adds ATR-based padding to each flip zone so the box remains visible on low-range transition bars.")
minimumZoneScore = input.int(55, "Minimum Zone Score", minval = 0, maxval = 100, group = groupZones,
     tooltip = "Creates flip zones only when the transition score is strong enough to deserve chart space.")
maxVisibleZones = input.int(4, "Maximum Visible Zones", minval = 1, maxval = 50, group = groupZones,
     tooltip = "Caps the number of active flip-zone boxes to keep the script fast and visually restrained.")
showZoneBadges = input.bool(true, "Show Centered Zone Badges", group = groupZones,
     tooltip = "Places a separate centered badge inside each flip zone so the zone has clear ownership without using embedded box text.")
showZoneBadgeScore = input.bool(true, "Show Zone Badge Score", group = groupZones,
     tooltip = "Adds the flip-quality score to centered zone badges.")
groupVisual = "Visuals"
showTrail = input.bool(true, "Show Chandelier Trail", group = groupVisual,
     tooltip = "Displays the active Chandelier trailing stop as a directional line on the chart.")
showTrendEma = input.bool(true, "Show Fast Trend EMA", group = groupVisual,
     tooltip = "Displays the fast EMA as a faint trend-context guide. It is visual context only and does not replace the Chandelier trail.")
showFlipLabels = input.bool(true, "Show Flip Labels", group = groupVisual,
     tooltip = "Displays compact labels when the Chandelier trail changes side.")
flipLabelMode = input.string("Non-Zone Flips", "Flip Label Mode", options = ["Non-Zone Flips", "All Qualified Flips"], group = groupVisual,
     tooltip = "Non-Zone Flips avoids narrating the same qualified transition twice when a centered Flip Zone badge already owns it. All Qualified Flips restores a separate event label for every qualified flip.")
showExitLabels = input.bool(false, "Show Exit Labels", group = groupVisual,
     tooltip = "Displays optional exit-pressure labels when price compresses back into the active trail.")
flipCooldownBars = input.int(10, "Flip Label Cooldown", minval = 1, maxval = 100, group = groupVisual,
     tooltip = "Minimum number of bars between flip labels so clusters do not overwhelm the chart.")
maxVisibleLabels = input.int(8, "Maximum Visible Labels", minval = 5, maxval = 150, group = groupVisual,
     tooltip = "Caps the number of labels retained on the chart to protect performance and presentation quality.")
labelOffsetAtr = input.float(0.48, "Label Offset In ATR", minval = 0.05, maxval = 2.0, step = 0.05, group = groupVisual,
     tooltip = "Places labels away from candle bodies using an ATR-based offset so they remain readable.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisual,
     tooltip = "Controls the size of chart labels. Normal is the default publication setting.")

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel,
     tooltip = "Shows or hides the AGPro status panel.")
panelLocationInput = input.string("Top Right", "Panel Location",
     options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"],
     group = groupPanel,
     tooltip = "Controls where the status panel is placed on the chart.")
panelThemeInput = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = groupPanel,
     tooltip = "Selects the panel color theme. Elite Dark is the AGPro default, Slate is softer, and Clean Light is designed for bright chart backgrounds.")
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel,
     tooltip = "Controls the text size of the panel. Normal is the default publication setting.")

// -------------------------------------------------
// Helper Functions
// -------------------------------------------------
f_size(string sizeName) =>
    switch sizeName
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_position(string locationName) =>
    switch locationName
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.top_right

f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

// Luminance-based contrast: dark text on light fills, light text on dark fills
f_text_on(color fill) =>
    float r = color.r(fill)
    float g = color.g(fill)
    float b = color.b(fill)
    (r * 299.0 + g * 587.0 + b * 114.0) / 1000.0 >= 145.0 ? color.rgb(17, 24, 39) : headerText

f_quality_text(float score, float primeLevel) =>
    na(score) ? "Waiting" : score >= primeLevel ? "Prime" : score >= 55.0 ? "Qualified" : "Developing"

f_quality_short(float score, float primeLevel) =>
    na(score) ? "Wait" : score >= primeLevel ? "Prime" : score >= 55.0 ? "Qual" : "Build"

f_quality_color(float score, float primeLevel) =>
    na(score) ? neutralColor : score >= primeLevel ? bullColor : score >= 55.0 ? accentColor : neutralColor

f_panel_bg() =>
    panelThemeInput == "Clean Light" ? color.rgb(248, 250, 252) : panelThemeInput == "Slate" ? color.rgb(30, 41, 59) : color.rgb(15, 23, 42)

f_panel_border() =>
    panelThemeInput == "Clean Light" ? color.rgb(203, 213, 225) : panelBorder

f_panel_label() =>
    panelThemeInput == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value() =>
    panelThemeInput == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_zone_badge_text(bool isBull, float score) =>
    side = isBull ? "BULL FLIP" : "BEAR FLIP"
    showZoneBadgeScore ? side + "\nZONE Q " + str.tostring(score, "#") : side + "\nZONE"

// -------------------------------------------------
// Chandelier Engine
// -------------------------------------------------
atrValue = ta.atr(atrLength)
atrSafe = math.max(nz(atrValue, ta.tr(true)), syminfo.mintick)
highestAnchor = ta.highest(high, structureLength)
lowestAnchor = ta.lowest(low, structureLength)
rawLongStop = highestAnchor - atrValue * atrMultiple
rawShortStop = lowestAnchor + atrValue * atrMultiple

var float longStop = na
var float shortStop = na
priorLongStop = nz(longStop[1], rawLongStop)
priorShortStop = nz(shortStop[1], rawShortStop)

longStop := close[1] > priorLongStop ? math.max(rawLongStop, priorLongStop) : rawLongStop
shortStop := close[1] < priorShortStop ? math.min(rawShortStop, priorShortStop) : rawShortStop

var int trailSide = 1
previousSide = nz(trailSide[1], 1)
trailSide := close > priorShortStop ? 1 : close < priorLongStop ? -1 : previousSide

activeTrail = trailSide == 1 ? longStop : shortStop
flipUpRaw = trailSide == 1 and previousSide == -1
flipDownRaw = trailSide == -1 and previousSide == 1
confirmedSignal = not confirmOnClose or barstate.isconfirmed
flipUp = flipUpRaw and confirmedSignal
flipDown = flipDownRaw and confirmedSignal
flipEvent = flipUp or flipDown

emaFast = ta.ema(close, fastEmaLength)
emaSlow = ta.ema(close, slowEmaLength)
trendAlignedLong = emaFast > emaSlow and close > emaSlow
trendAlignedShort = emaFast < emaSlow and close < emaSlow

rangeSpan = math.max(high - low, syminfo.mintick)
closeLocation = (close - low) / rangeSpan
trueRange = ta.tr(true)
volumeAverage = ta.sma(volume, volumeLength)
hasVolume = not na(volume) and not na(volumeAverage) and volumeAverage > 0.0

breachStrength = flipUp ? (close - priorShortStop) / atrSafe : flipDown ? (priorLongStop - close) / atrSafe : 0.0
breachScore = f_clamp(breachStrength / 1.20, 0.0, 1.0) * 35.0
trendScore = (flipUp and trendAlignedLong) or (flipDown and trendAlignedShort) ? 20.0 : 0.0
expansionScore = f_clamp((trueRange / atrSafe - 0.80) / 0.80, 0.0, 1.0) * 20.0
float closeScore = 0.0
if flipUp
    closeScore := closeLocation >= 0.65 ? 15.0 : closeLocation >= 0.50 ? 8.0 : 0.0
else if flipDown
    closeScore := closeLocation <= 0.35 ? 15.0 : closeLocation <= 0.50 ? 8.0 : 0.0
volumeRatio = hasVolume ? volume / volumeAverage : 1.0
volumeScore = useVolumeScore ? (hasVolume ? f_clamp((volumeRatio - 0.85) / 0.55, 0.0, 1.0) * 10.0 : 5.0) : 10.0
currentFlipScore = math.round(breachScore + trendScore + expansionScore + closeScore + volumeScore)

var float lastFlipScore = na
var int lastFlipBar = na
if flipEvent
    lastFlipScore := currentFlipScore
    lastFlipBar := bar_index

trailDistanceAtr = atrValue > 0.0 ? math.abs(close - activeTrail) / atrValue : na
trailDistancePct = close != 0.0 ? math.abs(close - activeTrail) / math.abs(close) * 100.0 : na
exitWatch = trailDistanceAtr <= exitWatchAtrDistance
continuationState = trailDistanceAtr >= continuationAtrDistance and (trailSide == 1 ? trendAlignedLong : trendAlignedShort)

// -------------------------------------------------
// Flip Continuation Rate (honest follow-through proof)
// A confirmed flip is counted as a WIN when price travels the continuation
// target distance in the flip direction before an opposite flip occurs.
// An opposite flip before reaching the target counts as a LOSS (the trend
// reversed). If neither happens within the proof window, the sample is left
// uncounted, so the statistic never inflates either side.
// -------------------------------------------------
int cefProofWindow = 10
var bool  cefPending = false
var int   cefDir = 0
var float cefTarget = na
var int   cefStart = na
var int   cefWins = 0
var int   cefLoss = 0

if barstate.isconfirmed
    if cefPending and not flipEvent
        bool reached = cefDir == 1 ? high >= cefTarget : low <= cefTarget
        if reached
            cefWins += 1
            cefPending := false
        else if bar_index - cefStart >= cefProofWindow
            cefPending := false
    if flipEvent
        if cefPending
            cefLoss += 1
            cefPending := false
        cefPending := true
        cefDir := flipUp ? 1 : -1
        cefTarget := close + (flipUp ? 1.0 : -1.0) * atrSafe * continuationTargetAtr
        cefStart := bar_index

cefTotal = cefWins + cefLoss
cefRate = cefTotal > 0 ? cefWins / cefTotal * 100.0 : na
cefText = cefTotal == 0 ? "Scanning" : cefTotal < 6 ? "Building (" + str.tostring(cefTotal) + ")" : str.tostring(cefRate, "#") + "% (" + str.tostring(cefTotal) + ")"
cefColor = cefTotal < 6 ? neutralColor : cefRate >= 55.0 ? bullColor : cefRate >= 45.0 ? accentColor : neutralColor

string stateText = ""
if trailSide == 1
    stateText := exitWatch ? "Long Exit Watch" : continuationState ? "Long Continuation" : "Long Control"
else
    stateText := exitWatch ? "Short Exit Watch" : continuationState ? "Short Continuation" : "Short Control"
stateColor = exitWatch ? neutralColor : continuationState ? (trailSide == 1 ? bullColor : bearColor) : accentColor
sideText = trailSide == 1 ? "Long Trail" : "Short Trail"
sideColor = trailSide == 1 ? bullColor : bearColor
flipAge = na(lastFlipBar) ? na : bar_index - lastFlipBar
qualityText = na(lastFlipScore) ? "Waiting" : str.tostring(lastFlipScore, "#") + "/100 - " + f_quality_text(lastFlipScore, primeScore) + " / " + str.tostring(flipAge) + "b"

// Next action guidance (decision layer)
string actionText = ""
color  actionColor = accentColor
if exitWatch
    actionText := trailSide == 1 ? "Protect longs / tighten stop" : "Protect shorts / tighten stop"
    actionColor := neutralColor
else if continuationState
    actionText := trailSide == 1 ? "Hold long, trail the move" : "Hold short, trail the move"
    actionColor := sideColor
else
    actionText := "Wait for clean continuation"
    actionColor := accentColor

// -------------------------------------------------
// Visual Layer
// -------------------------------------------------
trailColor = trailSide == 1 ? bullColor : bearColor
plot(showTrail ? activeTrail : na, "Active Chandelier Trail", color = trailColor, linewidth = 2, style = plot.style_linebr)
plot(showTrendEma ? emaFast : na, "Fast Trend EMA", color = color.new(accentColor, 78), linewidth = 1)

var array<label> flipLabels = array.new<label>()
var array<label> exitLabels = array.new<label>()
var array<box> flipZones = array.new<box>()
var array<label> zoneBadges = array.new<label>()
// Shared anti-collision registry (actual on-chart x / y of placed labels)
var array<int> regBars = array.new<int>()
var array<float> regYs = array.new<float>()
labelSize = f_size(labelSizeInput)
labelOffset = atrSafe * labelOffsetAtr

f_register(int bx, float yy) =>
    array.push(regBars, bx)
    array.push(regYs, yy)
    while array.size(regBars) > 60
        array.shift(regBars)
        array.shift(regYs)

f_resolve(int bx, float baseY, int dir) =>
    float y = baseY
    float sep = atrSafe * 1.65
    int barWin = 26
    int guard = 0
    bool clash = true
    while clash and guard < 14
        clash := false
        int n = array.size(regBars)
        if n > 0
            for i = 0 to n - 1
                if math.abs(bx - array.get(regBars, i)) <= barWin and math.abs(y - array.get(regYs, i)) < sep
                    y := y + dir * sep
                    clash := true
        guard += 1
    y

var int lastFlipLabelBar = na
flipLabelAllowed = currentFlipScore >= minimumFlipLabelScore and (na(lastFlipLabelBar) or bar_index - lastFlipLabelBar >= flipCooldownBars)
zoneCreated = showFlipZones and flipEvent and currentFlipScore >= minimumZoneScore

if zoneCreated
    zoneBase = flipUp ? priorShortStop : priorLongStop
    zonePadding = atrSafe * zoneAtrPadding
    zoneTop = math.max(close, zoneBase) + zonePadding
    zoneBottom = math.min(close, zoneBase) - zonePadding
    zoneColor = flipUp ? bullColor : bearColor
    newZone = box.new(left = bar_index, top = zoneTop, right = bar_index + zoneForwardBars, bottom = zoneBottom,
         bgcolor = color.new(zoneColor, 92), border_color = color.new(zoneColor, 62), border_width = 1)
    array.push(flipZones, newZone)
    badgeX = bar_index + int(math.round(zoneForwardBars * 0.50))
    badgeY = (zoneTop + zoneBottom) / 2.0
    label newBadge = na
    if showZoneBadges
        // The ownership badge remains at the true horizontal and vertical
        // center of its zone. Event labels resolve around this fixed anchor.
        f_register(badgeX, badgeY)
        newBadge := label.new(badgeX, badgeY, f_zone_badge_text(flipUp, currentFlipScore),
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_center,
             color = color.new(zoneColor, 0),
             textcolor = f_text_on(zoneColor),
             size = labelSize)
    array.push(zoneBadges, newBadge)

// Enforce the visible-zone cap immediately when settings change, not only
// after the next flip event. Zone and badge arrays stay index-aligned.
while array.size(flipZones) > maxVisibleZones
    oldZone = array.shift(flipZones)
    box.delete(oldZone)
    label oldBadge = array.size(zoneBadges) > 0 ? array.shift(zoneBadges) : na
    if not na(oldBadge)
        label.delete(oldBadge)

if not showFlipZones
    while array.size(flipZones) > 0
        oldZone = array.shift(flipZones)
        box.delete(oldZone)
    while array.size(zoneBadges) > 0
        oldBadge = array.shift(zoneBadges)
        if not na(oldBadge)
            label.delete(oldBadge)

if showFlipZones and not showZoneBadges
    if array.size(zoneBadges) > 0
        for i = 0 to array.size(zoneBadges) - 1
            oldBadge = array.get(zoneBadges, i)
            if not na(oldBadge)
                label.delete(oldBadge)
                array.set(zoneBadges, i, na)

labelModeAllows = flipLabelMode == "All Qualified Flips" or not zoneCreated or not showZoneBadges
if showFlipLabels and flipEvent and flipLabelAllowed and labelModeAllows
    flipLabelText = (flipUp ? "Bull" : "Bear") + "\nQ" + str.tostring(currentFlipScore, "#") + " " + f_quality_short(currentFlipScore, primeScore)
    flipBaseY = flipUp ? low - labelOffset : high + labelOffset
    flipLabelY = f_resolve(bar_index, flipBaseY, flipUp ? -1 : 1)
    f_register(bar_index, flipLabelY)
    flipLabelStyle = flipUp ? label.style_label_up : label.style_label_down
    flipLabelColor = currentFlipScore >= primeScore ? (flipUp ? bullColor : bearColor) : color.new(accentColor, 0)
    newFlipLabel = label.new(bar_index, flipLabelY, flipLabelText, style = flipLabelStyle, color = flipLabelColor,
         textcolor = f_text_on(currentFlipScore >= primeScore ? (flipUp ? bullColor : bearColor) : accentColor), size = labelSize)
    array.push(flipLabels, newFlipLabel)
    lastFlipLabelBar := bar_index
    while array.size(flipLabels) > maxVisibleLabels
        oldLabel = array.shift(flipLabels)
        label.delete(oldLabel)

if not showFlipLabels
    while array.size(flipLabels) > 0
        oldLabel = array.shift(flipLabels)
        label.delete(oldLabel)
    lastFlipLabelBar := na

var int lastExitLabelBar = na
exitWatchStarted = exitWatch and nz(trailDistanceAtr[1], exitWatchAtrDistance + 1.0) > exitWatchAtrDistance
exitVisualEvent = exitWatchStarted and not flipEvent and confirmedSignal
exitTrigger = showExitLabels and exitVisualEvent and (na(lastExitLabelBar) or bar_index - lastExitLabelBar >= exitCooldownBars)

if exitTrigger
    exitLabelText = "Exit Watch\nTrail"
    exitBaseY = trailSide == 1 ? low - labelOffset : high + labelOffset
    exitLabelY = f_resolve(bar_index, exitBaseY, trailSide == 1 ? -1 : 1)
    f_register(bar_index, exitLabelY)
    exitLabelStyle = trailSide == 1 ? label.style_label_up : label.style_label_down
    exitLabelColor = color.new(neutralColor, 0)
    newExitLabel = label.new(bar_index, exitLabelY, exitLabelText, style = exitLabelStyle, color = exitLabelColor,
         textcolor = f_text_on(neutralColor), size = labelSize)
    array.push(exitLabels, newExitLabel)
    lastExitLabelBar := bar_index
    while array.size(exitLabels) > maxVisibleLabels
        oldLabel = array.shift(exitLabels)
        label.delete(oldLabel)

if not showExitLabels
    while array.size(exitLabels) > 0
        oldLabel = array.shift(exitLabels)
        label.delete(oldLabel)
    lastExitLabelBar := na

// Preserve independent visibility toggles while enforcing one shared chart
// label budget across both annotation families.
while array.size(flipLabels) + array.size(exitLabels) > maxVisibleLabels
    flipFirstX = array.size(flipLabels) > 0 ? label.get_x(array.get(flipLabels, 0)) : bar_index + 1000000
    exitFirstX = array.size(exitLabels) > 0 ? label.get_x(array.get(exitLabels, 0)) : bar_index + 1000000
    if flipFirstX <= exitFirstX
        oldLabel = array.shift(flipLabels)
        label.delete(oldLabel)
    else
        oldLabel = array.shift(exitLabels)
        label.delete(oldLabel)

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelBgActive = f_panel_bg()
panelBorderActive = f_panel_border()
panelLabelActive = f_panel_label()
panelValueActive = f_panel_value()
panelSize = f_size(panelSizeInput)

var table dash = na

if showPanel and barstate.islast
    if na(dash)
        dash := table.new(f_position(panelLocationInput), 2, 7,
             border_width = 1,
             border_color = panelBorderActive,
             frame_color = panelBorderActive,
             frame_width = 1,
             bgcolor = panelBgActive)
    table.set_position(dash, f_position(panelLocationInput))
    table.clear(dash, 0, 0, 1, 6)
    table.merge_cells(dash, 0, 0, 1, 0)
    table.cell(dash, 0, 0, "AG Pro Chandelier Exit Flip Zones",
         bgcolor = headerBg, text_color = headerText, text_size = panelSize, text_halign = text.align_center)
    table.cell(dash, 0, 1, "Trail Side", bgcolor = panelBgActive, text_color = panelLabelActive, text_size = panelSize)
    table.cell(dash, 1, 1, sideText, bgcolor = panelBgActive, text_color = sideColor, text_size = panelSize)
    table.cell(dash, 0, 2, "Last Flip", bgcolor = panelBgActive, text_color = panelLabelActive, text_size = panelSize)
    table.cell(dash, 1, 2, qualityText, bgcolor = panelBgActive, text_color = f_quality_color(lastFlipScore, primeScore), text_size = panelSize)
    table.cell(dash, 0, 3, "Continuation Rate", bgcolor = panelBgActive, text_color = panelLabelActive, text_size = panelSize)
    table.cell(dash, 1, 3, cefText, bgcolor = panelBgActive, text_color = cefColor, text_size = panelSize)
    table.cell(dash, 0, 4, "Distance", bgcolor = panelBgActive, text_color = panelLabelActive, text_size = panelSize)
    table.cell(dash, 1, 4, str.tostring(trailDistanceAtr, "#.##") + " ATR / " + str.tostring(trailDistancePct, "#.##") + "%", bgcolor = panelBgActive, text_color = panelValueActive, text_size = panelSize)
    table.cell(dash, 0, 5, "State", bgcolor = panelBgActive, text_color = panelLabelActive, text_size = panelSize)
    table.cell(dash, 1, 5, stateText, bgcolor = panelBgActive, text_color = stateColor, text_size = panelSize)
    table.cell(dash, 0, 6, "Action", bgcolor = panelBgActive, text_color = panelLabelActive, text_size = panelSize)
    table.cell(dash, 1, 6, actionText, bgcolor = panelBgActive, text_color = actionColor, text_size = panelSize)

if not showPanel and not na(dash)
    table.delete(dash)
    dash := na

// -------------------------------------------------
// Alerts
// -------------------------------------------------
bullFlipAlert = barstate.isconfirmed and flipUpRaw
bearFlipAlert = barstate.isconfirmed and flipDownRaw
primeFlipAlert = barstate.isconfirmed and (flipUpRaw or flipDownRaw) and currentFlipScore >= primeScore
exitWatchAlert = barstate.isconfirmed and exitWatchStarted and not (flipUpRaw or flipDownRaw)

alertcondition(bullFlipAlert, "Bullish Chandelier Flip", "Chandelier Exit Flip Zones: bullish trail flip confirmed.")
alertcondition(bearFlipAlert, "Bearish Chandelier Flip", "Chandelier Exit Flip Zones: bearish trail flip confirmed.")
alertcondition(primeFlipAlert, "Prime Chandelier Flip", "Chandelier Exit Flip Zones: prime-quality trail flip confirmed.")
alertcondition(exitWatchAlert, "Chandelier Exit Watch", "Chandelier Exit Flip Zones: price compressed into the active Chandelier trail.")
````

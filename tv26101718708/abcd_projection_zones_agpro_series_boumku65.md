# ABCD Projection Zones [AGPro Series]

- url: https://www.tradingview.com/script/BOuMku65-ABCD-Projection-Zones-AGPro-Series/
- type: indicator
- pine_id: PUB;62eeef7721dd4ba3ac373ad6aa5acd92
- version: 4.0

## Description

ABCD Projection Zones [AGPro Series]

🔹 OVERVIEW

ABCD Projection Zones [AGPro Series] is a premium price-action projection tool built for traders who want a clean ABCD pattern map without turning the chart into a full harmonic scanner, Auto Fib suite, retracement dashboard, or broad pattern-recognition system.

The script focuses on one specific market-structure idea: a confirmed A-B-C swing sequence can project a forward D completion area when the A-B leg is measured from point C. Instead of plotting a single thin target line, the script converts that measured move into a practical projected completion zone. This makes the result easier to read on real charts where reactions often happen around an area rather than at one exact tick.

The tool detects the structure, measures the leg relationship, projects the completion zone, tracks the distance to that zone, and then follows the reaction lifecycle after price reaches it. The goal is a premium, readable ABCD projection workflow that helps traders understand where the current structure is, how mature it is, and how price is behaving around the projected completion area.

🔹 WHAT MAKES IT DIFFERENT

Many ABCD, projection, and pattern tools try to do too much at once. They combine multiple Fibonacci ratios, harmonic pattern names, extended target ladders, retracement grids, reversal labels, and broad pattern scanning into one chart overlay. That can look busy, but it often makes the active structure harder to understand.

ABCD Projection Zones takes a narrower and cleaner route.

It does not attempt to label every harmonic family.
It does not expose a full Fibonacci framework.
It does not place several competing projection targets on the chart.
It does not turn the layout into a generic support and resistance map.

The difference is the focused lane: confirmed ABCD swing projection, one projected completion zone, one reaction lifecycle, and a concise panel that explains the active setup.

The visual language is also different. The D area is shown as a forward rectangle with centered zone text inside the box. Active and archived zones stay named, labels use consistent sizing, and archived context remains muted so the active projection remains dominant.

🧭 WHY THIS DOES NOT OVERLAP WITH OTHER AGPRO TOOLS

This script is intentionally separated from other AGPro tools by scope, visual behavior, and analytical purpose.

It is not an Auto Fib Structure tool. It does not publish multiple retracement and extension levels, does not expose a full Fib grid, and does not present itself as a broad Fibonacci framework.

It is not a harmonic scanner. It does not label Gartley, Bat, Butterfly, Crab, Shark, or other harmonic families. It does not rank multiple harmonic candidates or compare pattern families.

It is not a generic support and resistance zone script. The rectangles are not general S/R zones. They are specifically ABCD completion and reaction zones derived from swing-leg symmetry.

It is not a trend dashboard, volatility map, liquidity sweep scanner, or broad price-action suite. Its job is only to map a confirmed A-B-C structure into a projected D completion zone and monitor the reaction state around that zone.

This makes the public release lane clear: a focused ABCD projection and reaction-zone tool for measured-move structure, not a duplicate of existing AGPro zone, Fib, S/R, harmonic, or dashboard concepts.

⚙️ METHODOLOGY

The script starts by detecting confirmed swing highs and lows using pivot-based structure logic. This gives the model cleaner A, B, and C points and helps reduce random candle noise.

After the A-B-C sequence is confirmed, the script measures the A-B leg and the B-C pullback. The B-C pullback is evaluated as a ratio of A-B, but this ratio is used as a structure-quality filter, not as a visible Fibonacci grid.

The projected D area is calculated by applying the A-B leg from point C. This creates an AB=CD style measured-move projection. The projected D price is then expanded into a rectangle using ATR-based padding so the completion area behaves like a practical reaction zone rather than a thin target.

The script then tracks the active projection lifecycle:

- Waiting: price has not yet approached the projected zone.
- Approaching: price is close enough to the zone to matter.
- Completed: price has reached the projected D area.
- Reacting: price is moving away from the zone after contact.
- Overrun: price has moved beyond the zone buffer.
- Expired: the projection window passed without completion.

The scoring model combines impulse quality, pullback quality, and structural alignment into a 0-100 score. This score is not a standalone signal; it is a compact way to summarize the quality of the active ABCD projection structure.

📊 PANEL

The AGPro panel is designed for quick chart reading without forcing the trader to inspect every object manually.

Panel fields:

- Leg Ratio: shows the B-C pullback size relative to A-B.
- Completion Distance: shows the current distance to the projected D zone in price and ATR terms.
- Reaction State: shows the active lifecycle state of the projection.
- Symmetry Quality: classifies the active setup as Weak, Developing, Clean, or Strong with directional context.
- Projection Progress: shows how far price has traveled from point C toward the projected D area.
- Score: summarizes the active setup quality from 0 to 100.

Panel standards:

- The first row is one merged blue AGPro header row.
- The header contains only the panel title.
- Panel location is adjustable.
- Panel theme is adjustable.
- Panel font size is adjustable.

🎛️ KEY INPUTS

Detection:
- Swing Left Strength
- Swing Right Strength
- ATR Length
- Minimum AB Leg Size ATR
- Minimum BC Pullback Ratio
- Maximum BC Pullback Ratio

Projection Zone:
- Projection Length Bars
- Zone Padding ATR
- Approach Distance ATR
- Overrun Buffer ATR
- Zone Fill Transparency
- Archived Zones
- Archived Zone Transparency
- Show Text Inside Zones

Visuals:
- Show ABCD Path
- Show ABCD Labels
- Show Completion Marker
- Label Font Size
- Label Offset ATR
- Completion Marker Offset Bars

Panel:
- Show Panel
- Panel Location
- Panel Theme
- Panel Font Size

🔍 HOW TO READ IT

Start with the A-B-C labels. Point A and point B define the impulse leg. Point C defines the pullback from which the measured-move projection begins.

The dotted projected path shows the C-D measured move. The forward rectangle marks the projected completion zone. If price is still far from that rectangle, the panel will usually show Waiting and a lower Projection Progress value.

As price moves toward the rectangle, Projection Progress increases and the Completion Distance decreases. When price reaches the zone, the script marks D Hit and changes the lifecycle state. After that, the most important reading is whether the zone becomes a Reaction Zone or an Overrun Zone.

Archived zones should be read as context, not as the main decision layer. They show previous projected reaction areas in a muted style so the chart does not feel empty, but the active zone remains the priority.

🧩 BEST USE CASES

This script is best suited for traders who study market structure, measured moves, swing projection, ABCD patterns, and reaction-zone behavior.

Strong use cases include:

- Mapping a clean ABCD completion area after a confirmed A-B-C structure.
- Tracking how close price is to a projected D area.
- Separating developing projections from completed projections.
- Watching for reaction behavior after price reaches a projected completion zone.
- Reviewing recent projected zones without overcrowding the chart.
- Keeping a clean price-action workflow without a full harmonic or Fib suite.

The script can be useful across different markets and timeframes, but it is most readable when swing structure is clear enough for pivot-based detection to identify meaningful A-B-C sequences.

🧠 VISUAL DESIGN PHILOSOPHY

The visual design is built around premium restraint.

The chart should not be empty, but it should also not be overloaded. The active ABCD projection needs to stand out clearly, while archived zones should provide background context without taking attention away from the current structure.

Visual standards used in this script:

- Active completion and reaction zones are drawn as forward rectangles.
- Zone text is written inside the rectangle.
- Zone text is horizontally and vertically centered.
- Zone text uses transparent label-center styling instead of extra external tags.
- Active and archived zone text uses the same label font-size control.
- Swing labels are offset with ATR so they do not sit inside candle bodies.
- The completion marker is compact and shifted away from nearby swing labels.
- The projected C-D path is visible but not visually dominant.
- Archived zones are muted to keep the active projection clean.

The result is a chart that communicates structure, projection, and reaction state without looking like a crowded signal board.

🔔 ALERTS

Included alert conditions:

- New ABCD Projection Zone: triggers when a new qualified ABCD projection is detected.
- ABCD Completion Reached: triggers when price reaches the active projected completion zone.
- ABCD Reaction Confirmed: triggers when price reacts away from the active completion zone.
- ABCD Zone Overrun: triggers when price moves beyond the configured zone buffer.

🔹 LIMITATIONS AND TRANSPARENCY

The script waits for confirmed pivot structure, so A, B, and C labels appear after swing confirmation rather than at the exact live turning point.

The projected D area is based on AB=CD symmetry and ATR-based zone padding. It is designed to map structure and reaction context, not to predict every reversal.

The script intentionally avoids a full harmonic library and full Fibonacci framework. This is a design choice, not a missing feature. The goal is to keep the public tool focused on ABCD projection zones.

During choppy or low-structure conditions, fewer clean setups may appear. Increasing or decreasing swing strength and leg-size filters can make the tool more selective or more responsive depending on the market and timeframe.

✅ IDEAL USER

This script is designed for traders who prefer clean structure tools over crowded all-in-one indicators.

The ideal user:

- Studies price action and swing structure.
- Wants a focused ABCD projection tool.
- Prefers zones over single-line targets.
- Wants reaction-state context after completion.
- Values clean chart presentation.
- Wants adjustable labels, panel location, and visual density.
- Does not want a full harmonic scanner or public Auto Fib suite.

ABCD Projection Zones [AGPro Series] is built for traders who want one clean projected completion lane: A-B-C structure, measured D zone, reaction state, and a premium AGPro visual presentation.

## Source Code

````pine
// -------------------------------------------------
// ABCD Projection Zones [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// A clean ABCD projection indicator focused on swing leg structure,
// AB=CD completion symmetry, projected reaction zones, completion state
// tracking, and an empirical stop-aware reaction proof rate. The script
// keeps the public lane narrow: it does not expose a full harmonic
// scanner, Auto Fib suite, or multi-level Fib map.
// -------------------------------------------------

//@version=6
indicator("ABCD Projection Zones [AGPro Series]",
     shorttitle = "ABCD PZ",
     overlay = true,
     max_boxes_count = 20,
     max_labels_count = 80,
     max_lines_count = 60)

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
detectionGroup = "Detection"
pivotLeft      = input.int(4, "Swing Left Strength", minval = 1, maxval = 20, group = detectionGroup, tooltip = "Number of bars required to the left of a confirmed swing point. Higher values create fewer but stronger ABC structures.")
pivotRight     = input.int(4, "Swing Right Strength", minval = 1, maxval = 20, group = detectionGroup, tooltip = "Number of bars required to the right of a confirmed swing point. This adds confirmation delay but improves structural quality.")
atrLength      = input.int(14, "ATR Length", minval = 1, maxval = 100, group = detectionGroup, tooltip = "ATR length used to normalize leg size, completion distance, label offsets, projection-zone padding, and proof distances.")
minLegAtr      = input.float(1.20, "Minimum AB Leg Size ATR", minval = 0.10, maxval = 10.0, step = 0.05, group = detectionGroup, tooltip = "Minimum required AB leg size measured in ATR. This helps avoid weak or compressed patterns.")
minBcRatio     = input.float(0.35, "Minimum BC Pullback Ratio", minval = 0.05, maxval = 1.50, step = 0.01, group = detectionGroup, tooltip = "Minimum BC pullback size relative to AB. The script uses this as a structure-quality filter, not as a visible Fibonacci grid.")
maxBcRatio     = input.float(0.85, "Maximum BC Pullback Ratio", minval = 0.10, maxval = 2.00, step = 0.01, group = detectionGroup, tooltip = "Maximum BC pullback size relative to AB. Values above this level usually mean the structure has lost clean ABCD symmetry.")

projectionGroup = "Projection Zone"
projectionBars  = input.int(80, "Projection Length Bars", minval = 10, maxval = 300, group = projectionGroup, tooltip = "How far the completion zone is projected forward from point C.")
zonePaddingAtr  = input.float(0.38, "Zone Padding ATR", minval = 0.02, maxval = 2.00, step = 0.01, group = projectionGroup, tooltip = "ATR padding around the projected D price. Wider padding creates a more forgiving reaction zone.")
approachAtr     = input.float(0.75, "Approach Distance ATR", minval = 0.05, maxval = 5.00, step = 0.05, group = projectionGroup, tooltip = "Distance from the completion zone at which the panel changes from Waiting to Approaching.")
remoteAtr       = input.float(6.00, "Remote Projection ATR", minval = 1.00, maxval = 20.0, step = 0.25, group = projectionGroup, tooltip = "Classifies distant D projections as remote context. Remote projections remain visible, but use a secondary visual hierarchy until price moves within this ATR distance.")
overrunAtr      = input.float(0.45, "Overrun Buffer ATR", minval = 0.05, maxval = 3.00, step = 0.05, group = projectionGroup, tooltip = "ATR buffer beyond the completion zone used to mark a projected reaction area as overrun.")
zoneOpacity     = input.int(78, "Zone Fill Transparency", minval = 55, maxval = 95, group = projectionGroup, tooltip = "Transparency of the projected completion rectangle.")
archiveCount    = input.int(1, "Archived Zones", minval = 0, maxval = 3, group = projectionGroup, tooltip = "Number of prior projection rectangles retained as truncated context. One archive is the balanced default for a readable chart.")
archiveOpacity  = input.int(91, "Archived Zone Transparency", minval = 75, maxval = 97, group = projectionGroup, tooltip = "Transparency used for archived projection zones. Higher values keep historical context visible without crowding the active setup.")
showZoneText    = input.bool(true, "Show Text Inside Zones", group = projectionGroup, tooltip = "Shows centered premium badge labels inside active and archived projection zones.")

visualGroup          = "Visuals"
showLegPath          = input.bool(true, "Show ABCD Path", group = visualGroup, tooltip = "Draws the A-B, B-C, and projected C-D structure path.")
showLegLabels        = input.bool(true, "Show ABCD Labels", group = visualGroup, tooltip = "Shows A, B, and C swing labels with ATR-based offsets so they do not sit inside candles.")
showCompletionMarker = input.bool(true, "Show Completion Marker", group = visualGroup, tooltip = "Shows a D completion marker when price first reaches the projected completion zone.")
labelSizeInput       = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = visualGroup, tooltip = "Controls all ABCD labels, completion markers, and centered zone badges.")
labelOffsetAtr       = input.float(0.55, "Label Offset ATR", minval = 0.05, maxval = 3.00, step = 0.05, group = visualGroup, tooltip = "ATR-based vertical distance used to keep labels readable above or below candles.")
completionOffsetBars = input.int(3, "Completion Marker Offset Bars", minval = 0, maxval = 20, group = visualGroup, tooltip = "Moves the completion marker to the right so it does not overlap nearby swing labels.")

panelGroup     = "Panel"
showPanel      = input.bool(true, "Show Panel", group = panelGroup, tooltip = "Shows the AGPro summary panel with leg ratio, completion distance, reaction state, proof rate, and setup score.")
panelLocation  = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"], group = panelGroup, tooltip = "Selects the location of the AGPro summary panel.")
panelTheme     = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = panelGroup, tooltip = "Controls the panel color theme while keeping the AGPro blue merged header.")
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = panelGroup, tooltip = "Controls the font size used in the AGPro summary panel.")

proofGroup     = "Proof"
proofTimeout   = input.int(40, "Proof Window Bars", minval = 5, maxval = 200, group = proofGroup, tooltip = "Maximum bars a completion-reaction window stays open before it is left uncounted in the proof rate.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

// Luminance-based contrast: dark ink on bright fills, light ink on dark fills.
f_text_on(color bg) =>
    float lum = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
    lum > 145 ? color.rgb(17, 24, 39) : headerText

f_size_from_input(string sizeName) =>
    result = size.normal
    if sizeName == "Tiny"
        result := size.tiny
    else if sizeName == "Small"
        result := size.small
    else if sizeName == "Large"
        result := size.large
    result

f_panel_position(string locationName) =>
    result = position.top_right
    if locationName == "Top Left"
        result := position.top_left
    else if locationName == "Bottom Right"
        result := position.bottom_right
    else if locationName == "Bottom Left"
        result := position.bottom_left
    else if locationName == "Middle Right"
        result := position.middle_right
    else if locationName == "Middle Left"
        result := position.middle_left
    result

f_label_style(int swingType) =>
    swingType == 1 ? label.style_label_down : label.style_label_up

f_label_y(int swingType, float priceValue, float atrValue) =>
    swingType == 1 ? priceValue + atrValue * labelOffsetAtr : priceValue - atrValue * labelOffsetAtr

f_state_name(int stateValue) =>
    result = "Waiting"
    if stateValue == 1
        result := "Approaching"
    else if stateValue == 2
        result := "Completed"
    else if stateValue == 3
        result := "Reacting"
    else if stateValue == 4
        result := "Overrun"
    else if stateValue == 5
        result := "Expired"
    result

f_state_color(int stateValue, int directionValue) =>
    result = directionValue == 1 ? bullColor : bearColor
    if stateValue == 1
        result := neutralColor
    else if stateValue == 2
        result := accentColor
    else if stateValue == 3
        result := bullColor
    else if stateValue == 4
        result := bearColor
    else if stateValue == 5
        result := panelLabelCol
    result

f_quality_name(float scoreValue) =>
    result = "Weak"
    if scoreValue >= 80
        result := "Strong"
    else if scoreValue >= 65
        result := "Clean"
    else if scoreValue >= 50
        result := "Developing"
    result

f_zone_text(int stateValue, bool remoteValue, float distanceAtrValue) =>
    result = remoteValue ? "REMOTE ABCD\n" + str.tostring(distanceAtrValue, "#.##") + " ATR" : "ABCD Completion\nZone"
    if not remoteValue and stateValue == 1
        result := "ABCD Approach\nZone"
    else if not remoteValue and stateValue == 2
        result := "ABCD Hit\nZone"
    else if not remoteValue and stateValue == 3
        result := "ABCD Reaction\nZone"
    else if not remoteValue and stateValue == 4
        result := "ABCD Overrun\nZone"
    else if not remoteValue and stateValue == 5
        result := "Expired ABCD\nZone"
    result

f_zone_badge_color(int stateValue, int directionValue) =>
    showZoneText ? f_state_color(stateValue, directionValue) : color.new(panelBg, 100)

f_zone_badge_text_color(int stateValue, int directionValue) =>
    showZoneText ? f_text_on(f_state_color(stateValue, directionValue)) : color.new(headerText, 100)

var array<int> swingBars = array.new_int()
var array<float> swingPrices = array.new_float()
var array<int> swingTypes = array.new_int()

f_register_swing(int swingBar, float swingPrice, int swingType) =>
    changed = false
    swingCount = array.size(swingTypes)
    if swingCount == 0
        array.push(swingBars, swingBar)
        array.push(swingPrices, swingPrice)
        array.push(swingTypes, swingType)
        changed := true
    else
        lastIndex = swingCount - 1
        lastType = array.get(swingTypes, lastIndex)
        lastPrice = array.get(swingPrices, lastIndex)
        if swingType == lastType
            isMoreExtreme = swingType == 1 ? swingPrice >= lastPrice : swingPrice <= lastPrice
            if isMoreExtreme
                array.set(swingBars, lastIndex, swingBar)
                array.set(swingPrices, lastIndex, swingPrice)
                changed := true
        else
            array.push(swingBars, swingBar)
            array.push(swingPrices, swingPrice)
            array.push(swingTypes, swingType)
            if array.size(swingTypes) > 18
                array.shift(swingBars)
                array.shift(swingPrices)
                array.shift(swingTypes)
            changed := true
    changed

// -------------------------------------------------
// Swing Detection
// -------------------------------------------------
atrValue = math.max(nz(ta.atr(atrLength), ta.tr(true)), syminfo.mintick)
labelTextSize = f_size_from_input(labelSizeInput)
panelTextSize = f_size_from_input(panelSizeInput)

pivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)
pivotLow = ta.pivotlow(low, pivotLeft, pivotRight)
pivotBar = bar_index - pivotRight

swingChanged = false
confirmedBar = barstate.isconfirmed
if confirmedBar
    if not na(pivotHigh)
        swingChanged := f_register_swing(pivotBar, pivotHigh, 1) or swingChanged
    if not na(pivotLow)
        swingChanged := f_register_swing(pivotBar, pivotLow, -1) or swingChanged

// -------------------------------------------------
// Active Setup State
// -------------------------------------------------
var bool activeSetup = false
var int activeDir = 0
var int activeCBar = na
var float activeZoneLow = na
var float activeZoneHigh = na
var float activeBcRatio = na
var float activeScore = na
var int activeState = 0
var bool activeTouched = false
var bool activeReacted = false
var bool activeOverrun = false
var bool activeExpired = false
var float activeProjectedD = na
var float activeCPrice = na
var int lastSetupCBar = na
var int lastSetupDir = 0

var box activeBox = na
var line lineAB = na
var line lineBC = na
var line lineCD = na
var label labelA = na
var label labelB = na
var label labelC = na
var label labelCompletion = na
var label activeZoneLabel = na
var int activeZoneLabelBar = na
var float activeZoneLabelPrice = na
var array<box> archivedBoxes = array.new_box()
var array<label> archivedZoneLabels = array.new_label()

newSetupSignal = false
completedSignal = false
reactingSignal = false
overrunSignal = false

while array.size(archivedBoxes) > archiveCount
    archivedBoxToDelete = array.shift(archivedBoxes)
    if not na(archivedBoxToDelete)
        box.delete(archivedBoxToDelete)
while array.size(archivedZoneLabels) > archiveCount
    archivedLabelToDelete = array.shift(archivedZoneLabels)
    if not na(archivedLabelToDelete)
        label.delete(archivedLabelToDelete)

if swingChanged and array.size(swingTypes) >= 3 and atrValue > 0
    swingCount = array.size(swingTypes)
    aIndex = swingCount - 3
    bIndex = swingCount - 2
    cIndex = swingCount - 1
    aBar = array.get(swingBars, aIndex)
    bBar = array.get(swingBars, bIndex)
    cBar = array.get(swingBars, cIndex)
    aPrice = array.get(swingPrices, aIndex)
    bPrice = array.get(swingPrices, bIndex)
    cPrice = array.get(swingPrices, cIndex)
    aType = array.get(swingTypes, aIndex)
    bType = array.get(swingTypes, bIndex)
    cType = array.get(swingTypes, cIndex)
    hasAlternation = aType == cType and bType == -aType
    abMove = bPrice - aPrice
    abLength = math.abs(abMove)
    bcLength = math.abs(cPrice - bPrice)
    bcRatio = abLength > 0 ? bcLength / abLength : na
    direction = 0
    if abMove > 0
        direction := 1
    else if abMove < 0
        direction := -1
    projectedD = cPrice + abMove
    zoneLow = projectedD - atrValue * zonePaddingAtr
    zoneHigh = projectedD + atrValue * zonePaddingAtr
    validRatio = not na(bcRatio) and bcRatio >= minBcRatio and bcRatio <= maxBcRatio
    validLeg = abLength >= atrValue * minLegAtr
    validBirth = direction == 1 ? close <= zoneHigh + atrValue * overrunAtr : close >= zoneLow - atrValue * overrunAtr
    validSetup = hasAlternation and validRatio and validLeg and validBirth and direction != 0
    if validSetup and (cBar != lastSetupCBar or direction != lastSetupDir)
        if not na(activeBox)
            if archiveCount > 0
                archiveColor = f_state_color(activeState, activeDir)
                archiveLeft = box.get_left(activeBox)
                archiveRight = math.max(archiveLeft + 2, cBar - 1)
                archiveMidBar = archiveLeft + int(math.round((archiveRight - archiveLeft) * 0.5))
                archiveMidPrice = (box.get_top(activeBox) + box.get_bottom(activeBox)) * 0.5
                box.set_right(activeBox, archiveRight)
                box.set_bgcolor(activeBox, color.new(archiveColor, archiveOpacity))
                box.set_border_color(activeBox, color.new(archiveColor, 62))
                box.set_border_width(activeBox, 1)
                array.push(archivedBoxes, activeBox)
                if not na(activeZoneLabel)
                    label.set_xy(activeZoneLabel, archiveMidBar, archiveMidPrice)
                    label.set_text(activeZoneLabel, showZoneText ? "PRIOR ABCD" : "")
                    label.set_textcolor(activeZoneLabel, showZoneText ? f_text_on(panelBorder) : color.new(panelValueCol, 100))
                    label.set_size(activeZoneLabel, labelTextSize)
                    label.set_style(activeZoneLabel, label.style_label_center)
                    label.set_color(activeZoneLabel, showZoneText ? color.new(panelBorder, 8) : color.new(panelBg, 100))
                    array.push(archivedZoneLabels, activeZoneLabel)
            else
                box.delete(activeBox)
                if not na(activeZoneLabel)
                    label.delete(activeZoneLabel)
            activeBox := na
            activeZoneLabel := na
            activeZoneLabelBar := na
            activeZoneLabelPrice := na
            while array.size(archivedBoxes) > archiveCount
                oldArchiveBox = array.shift(archivedBoxes)
                if not na(oldArchiveBox)
                    box.delete(oldArchiveBox)
            while array.size(archivedZoneLabels) > archiveCount
                oldArchiveLabel = array.shift(archivedZoneLabels)
                if not na(oldArchiveLabel)
                    label.delete(oldArchiveLabel)
        if not na(lineAB)
            line.delete(lineAB)
        if not na(lineBC)
            line.delete(lineBC)
        if not na(lineCD)
            line.delete(lineCD)
        if not na(labelA)
            label.delete(labelA)
        if not na(labelB)
            label.delete(labelB)
        if not na(labelC)
            label.delete(labelC)
        if not na(labelCompletion)
            label.delete(labelCompletion)
        if not na(activeZoneLabel)
            label.delete(activeZoneLabel)
            activeZoneLabel := na
            activeZoneLabelBar := na
            activeZoneLabelPrice := na

        idealPullback = (minBcRatio + maxBcRatio) * 0.5
        pullbackSpan = math.max((maxBcRatio - minBcRatio) * 0.5, 0.01)
        pullbackScore = 100.0 - f_clamp(math.abs(bcRatio - idealPullback) / pullbackSpan * 100.0, 0.0, 100.0)
        impulseScore = f_clamp(abLength / (atrValue * minLegAtr) * 100.0, 0.0, 100.0)
        structureScore = 0.0
        if direction == 1 and cPrice > aPrice
            structureScore := 100.0
        else if direction == -1 and cPrice < aPrice
            structureScore := 100.0
        setupScore = math.round(impulseScore * 0.35 + pullbackScore * 0.45 + structureScore * 0.20)
        sideColor = direction == 1 ? bullColor : bearColor

        activeSetup := true
        activeDir := direction
        activeCBar := cBar
        activeZoneLow := zoneLow
        activeZoneHigh := zoneHigh
        activeBcRatio := bcRatio
        activeScore := setupScore
        activeProjectedD := projectedD
        activeCPrice := cPrice
        activeState := 0
        activeTouched := false
        activeReacted := false
        activeOverrun := false
        activeExpired := false
        lastSetupCBar := cBar
        lastSetupDir := direction
        newSetupSignal := true

        activeBox := box.new(left = cBar,
             top = zoneHigh,
             right = cBar + projectionBars,
             bottom = zoneLow,
             xloc = xloc.bar_index,
             bgcolor = color.new(sideColor, zoneOpacity),
             border_color = color.new(sideColor, 0),
             border_width = 2)
        activeZoneLabelBar := cBar + int(math.round(projectionBars * 0.5))
        activeZoneLabelPrice := (zoneHigh + zoneLow) * 0.5
        activeZoneLabel := label.new(activeZoneLabelBar,
             activeZoneLabelPrice,
             showZoneText ? "ABCD Completion\nZone" : "",
             xloc = xloc.bar_index,
             style = label.style_label_center,
             color = f_zone_badge_color(0, direction),
             textcolor = f_zone_badge_text_color(0, direction),
             size = labelTextSize,
             textalign = text.align_center)

        if showLegPath
            lineAB := line.new(aBar, aPrice, bBar, bPrice, xloc = xloc.bar_index, color = color.new(sideColor, 0), width = 2)
            lineBC := line.new(bBar, bPrice, cBar, cPrice, xloc = xloc.bar_index, color = color.new(panelValueCol, 15), width = 2)
            lineCD := line.new(cBar, cPrice, cBar + projectionBars, projectedD, xloc = xloc.bar_index, color = color.new(sideColor, 4), width = 3, style = line.style_dotted)

        if showLegLabels
            labelA := label.new(aBar, f_label_y(aType, aPrice, atrValue), "A", xloc = xloc.bar_index, style = f_label_style(aType), color = color.new(aType == 1 ? bearColor : bullColor, 0), textcolor = f_text_on(aType == 1 ? bearColor : bullColor), size = labelTextSize)
            labelB := label.new(bBar, f_label_y(bType, bPrice, atrValue), "B", xloc = xloc.bar_index, style = f_label_style(bType), color = color.new(bType == 1 ? bearColor : bullColor, 0), textcolor = f_text_on(bType == 1 ? bearColor : bullColor), size = labelTextSize)
            labelC := label.new(cBar, f_label_y(cType, cPrice, atrValue), "C", xloc = xloc.bar_index, style = f_label_style(cType), color = color.new(cType == 1 ? bearColor : bullColor, 0), textcolor = f_text_on(cType == 1 ? bearColor : bullColor), size = labelTextSize)

// -------------------------------------------------
// Reaction State Tracking
// -------------------------------------------------
if activeSetup and atrValue > 0
    zoneTouchedNow = high >= activeZoneLow and low <= activeZoneHigh
    if confirmedBar and zoneTouchedNow and not activeTouched and not activeExpired
        activeTouched := true
        completedSignal := true
        if showCompletionMarker
            markerY = activeDir == 1 ? activeZoneHigh + atrValue * labelOffsetAtr * 1.80 : activeZoneLow - atrValue * labelOffsetAtr * 1.80
            markerStyle = activeDir == 1 ? label.style_label_down : label.style_label_up
            labelCompletion := label.new(bar_index + completionOffsetBars, markerY, "D | HIT", xloc = xloc.bar_index, style = markerStyle, color = color.new(accentColor, 0), textcolor = f_text_on(accentColor), size = labelTextSize)

    reactionNow = activeTouched and (activeDir == 1 ? close < activeZoneLow : close > activeZoneHigh)
    if confirmedBar and reactionNow and not activeReacted
        activeReacted := true
        reactingSignal := true

    overrunNow = activeDir == 1 ? close > activeZoneHigh + atrValue * overrunAtr : close < activeZoneLow - atrValue * overrunAtr
    if confirmedBar and overrunNow and not activeOverrun and not activeExpired
        activeOverrun := true
        overrunSignal := true

    expiredNow = bar_index > activeCBar + projectionBars and not activeTouched
    if confirmedBar and expiredNow
        activeExpired := true
    distanceToZone = activeDir == 1 ? activeZoneLow - close : close - activeZoneHigh
    distanceAtr = math.max(distanceToZone / atrValue, 0.0)
    isRemote = not activeTouched and distanceToZone > atrValue * remoteAtr
    isApproaching = distanceToZone > 0 and distanceToZone <= atrValue * approachAtr

    if activeOverrun
        activeState := 4
    else if activeReacted
        activeState := 3
    else if activeTouched
        activeState := 2
    else if activeExpired
        activeState := 5
    else if isApproaching
        activeState := 1
    else
        activeState := 0

    stateColor = f_state_color(activeState, activeDir)
    visualColor = isRemote ? neutralColor : stateColor
    if not na(activeBox)
        activeFillOpacity = isRemote ? math.min(zoneOpacity + 8, 94) : zoneOpacity
        if activeState == 2
            activeFillOpacity := math.max(zoneOpacity - 4, 55)
        else if activeState == 3
            activeFillOpacity := math.max(zoneOpacity - 8, 55)
        else if activeState == 4
            activeFillOpacity := math.max(zoneOpacity - 3, 55)
        box.set_bgcolor(activeBox, color.new(visualColor, activeFillOpacity))
        box.set_border_color(activeBox, color.new(visualColor, activeState == 5 ? 65 : isRemote ? 24 : 0))
        box.set_border_width(activeBox, activeState >= 2 and activeState <= 4 ? 3 : 2)
    if not na(lineCD)
        line.set_color(lineCD, color.new(visualColor, isRemote ? 28 : 4))
        line.set_width(lineCD, isRemote ? 2 : 3)
    if not na(activeZoneLabel)
        label.set_xy(activeZoneLabel, activeZoneLabelBar, activeZoneLabelPrice)
        label.set_text(activeZoneLabel, showZoneText ? f_zone_text(activeState, isRemote, distanceAtr) : "")
        label.set_textcolor(activeZoneLabel, showZoneText ? f_text_on(visualColor) : color.new(headerText, 100))
        label.set_size(activeZoneLabel, labelTextSize)
        label.set_style(activeZoneLabel, label.style_label_center)
        label.set_color(activeZoneLabel, showZoneText ? visualColor : color.new(panelBg, 100))

archivedLabelCount = array.size(archivedZoneLabels)
if archivedLabelCount > 0
    for archivedIdx = 0 to archivedLabelCount - 1
        archivedZoneLabel = array.get(archivedZoneLabels, archivedIdx)
        if not na(archivedZoneLabel)
            label.set_size(archivedZoneLabel, labelTextSize)
            label.set_style(archivedZoneLabel, label.style_label_center)
            label.set_color(archivedZoneLabel, showZoneText ? color.new(panelBorder, 8) : color.new(panelBg, 100))
            label.set_textcolor(archivedZoneLabel, showZoneText ? f_text_on(panelBorder) : color.new(panelValueCol, 100))

// -------------------------------------------------
// Stop-aware reaction proof (confirmed-bar gated)
// -------------------------------------------------
var int proofTotal = 0
var int proofWins = 0
var bool proofPending = false
var int proofDir = 0
var float proofTarget = na
var float proofStop = na
var int proofStartBar = na
var int proofSetupId = na

if barstate.isconfirmed
    if proofPending
        bool win = proofDir == 1 ? low <= proofTarget : high >= proofTarget
        bool los = proofDir == 1 ? high >= proofStop : low <= proofStop
        bool resolved = false
        if los and not win
            proofTotal += 1
            resolved := true
        else if win and not los
            proofWins += 1
            proofTotal += 1
            resolved := true
        else if win and los
            proofTotal += 1
            resolved := true
        if not resolved and not na(proofStartBar) and bar_index - proofStartBar >= proofTimeout
            resolved := true
        if resolved
            proofPending := false
    bool touchedConfirmed = activeSetup and activeTouched and not activeExpired and not activeOverrun and high >= activeZoneLow and low <= activeZoneHigh
    if not proofPending and touchedConfirmed and (na(proofSetupId) or proofSetupId != activeCBar)
        proofPending := true
        proofDir := activeDir
        proofTarget := activeDir == 1 ? close - atrValue * 1.5 : close + atrValue * 1.5
        proofStop := activeDir == 1 ? close + atrValue * 1.0 : close - atrValue * 1.0
        proofStartBar := bar_index
        proofSetupId := activeCBar

proofReady = proofTotal >= 6
proofRate = proofReady ? int(math.round(f_clamp(proofWins / proofTotal * 100.0, 0.0, 100.0))) : na
proofText = proofReady ? str.tostring(proofRate) + "%  (" + str.tostring(proofTotal) + ")" : "Building (" + str.tostring(proofTotal) + ")"
proofColor = not proofReady ? neutralColor : proofRate >= 55 ? bullColor : proofRate >= 45 ? neutralColor : bearColor

// -------------------------------------------------
// Panel
// -------------------------------------------------
bodyBg = panelTheme == "Dark" ? panelBg : color.rgb(248, 250, 252)
bodyLabel = panelTheme == "Dark" ? panelLabelCol : color.rgb(71, 85, 105)
bodyValue = panelTheme == "Dark" ? panelValueCol : color.rgb(15, 23, 42)

var table infoPanel = table.new(position.top_right, 2, 9, frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)

if barstate.islast
    table.set_position(infoPanel, f_panel_position(panelLocation))
    table.clear(infoPanel, 0, 0, 1, 8)
    if showPanel
        table.merge_cells(infoPanel, 0, 0, 1, 0)
        legRatioText = activeSetup ? "BC/AB " + str.tostring(activeBcRatio, "#.##") + "x" : "No setup"
        distanceText = "No setup"
        progressText = "No setup"
        if activeSetup and atrValue > 0
            rawDistance = activeDir == 1 ? activeZoneLow - close : close - activeZoneHigh
            if rawDistance > 0
                distanceText := str.tostring(rawDistance, format.mintick) + " / " + str.tostring(rawDistance / atrValue, "#.##") + " ATR"
            else if high >= activeZoneLow and low <= activeZoneHigh
                distanceText := "Inside zone"
            else
                distanceText := "Beyond zone"
            progressRange = math.abs(activeProjectedD - activeCPrice)
            progressValue = progressRange > 0 ? f_clamp(math.abs(close - activeCPrice) / progressRange * 100.0, 0.0, 100.0) : 0.0
            progressText := str.tostring(progressValue, "#") + "%"
        reactionText = activeSetup ? f_state_name(activeState) : "No setup"
        remoteNow = activeSetup and atrValue > 0 and (activeDir == 1 ? activeZoneLow - close : close - activeZoneHigh) > atrValue * remoteAtr and not activeTouched
        if remoteNow
            reactionText := "Remote / Waiting"
        workflowText = "Scan for ABC"
        if activeSetup
            if remoteNow
                workflowText := "Standby | Remote D"
            else if activeState == 1
                workflowText := "Prepare | Approaching"
            else if activeState == 2
                workflowText := "Review | D Reached"
            else if activeState == 3
                workflowText := "Manage | Reaction"
            else if activeState == 4
                workflowText := "Reset | Overrun"
            else if activeState == 5
                workflowText := "Scan | Projection Expired"
            else
                workflowText := "Track | Projection Open"
        scoreText = activeSetup ? str.tostring(activeScore, "#") + "/100" : "No setup"
        qualityText = activeSetup ? f_quality_name(activeScore) + (activeDir == 1 ? " Bullish" : " Bearish") : "No setup"
        scoreColor = activeSetup ? (activeScore >= 75 ? bullColor : activeScore >= 55 ? neutralColor : bearColor) : panelBorder
        reactionColor = activeSetup ? f_state_color(activeState, activeDir) : panelBorder
        workflowColor = not activeSetup ? panelBorder : remoteNow ? neutralColor : activeState == 4 ? bearColor : activeState == 5 ? accentColor : bullColor

        table.cell(infoPanel, 0, 0, "AG Pro ABCD Projection Zones", bgcolor = headerBg, text_color = f_text_on(headerBg), text_size = panelTextSize, text_halign = text.align_center)
        table.cell(infoPanel, 0, 1, "Workflow", bgcolor = bodyBg, text_color = bodyLabel, text_size = panelTextSize, text_halign = text.align_left)
        table.cell(infoPanel, 1, 1, workflowText, bgcolor = bodyBg, text_color = workflowColor, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(infoPanel, 0, 2, "Leg Ratio", bgcolor = bodyBg, text_color = bodyLabel, text_size = panelTextSize, text_halign = text.align_left)
        table.cell(infoPanel, 1, 2, legRatioText, bgcolor = bodyBg, text_color = bodyValue, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(infoPanel, 0, 3, "Completion Distance", bgcolor = bodyBg, text_color = bodyLabel, text_size = panelTextSize, text_halign = text.align_left)
        table.cell(infoPanel, 1, 3, distanceText, bgcolor = bodyBg, text_color = remoteNow ? neutralColor : bodyValue, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(infoPanel, 0, 4, "Reaction State", bgcolor = bodyBg, text_color = bodyLabel, text_size = panelTextSize, text_halign = text.align_left)
        table.cell(infoPanel, 1, 4, reactionText, bgcolor = activeSetup ? (remoteNow ? neutralColor : reactionColor) : bodyBg, text_color = activeSetup ? f_text_on(remoteNow ? neutralColor : reactionColor) : bodyValue, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(infoPanel, 0, 5, "Reaction Proof", bgcolor = bodyBg, text_color = bodyLabel, text_size = panelTextSize, text_halign = text.align_left)
        table.cell(infoPanel, 1, 5, proofText, bgcolor = proofColor, text_color = f_text_on(proofColor), text_size = panelTextSize, text_halign = text.align_right)
        table.cell(infoPanel, 0, 6, "Symmetry Quality", bgcolor = bodyBg, text_color = bodyLabel, text_size = panelTextSize, text_halign = text.align_left)
        table.cell(infoPanel, 1, 6, qualityText, bgcolor = bodyBg, text_color = scoreColor, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(infoPanel, 0, 7, "Projection Progress", bgcolor = bodyBg, text_color = bodyLabel, text_size = panelTextSize, text_halign = text.align_left)
        table.cell(infoPanel, 1, 7, progressText, bgcolor = bodyBg, text_color = bodyValue, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(infoPanel, 0, 8, "Score", bgcolor = bodyBg, text_color = bodyLabel, text_size = panelTextSize, text_halign = text.align_left)
        table.cell(infoPanel, 1, 8, scoreText, bgcolor = activeSetup ? scoreColor : bodyBg, text_color = activeSetup ? f_text_on(scoreColor) : bodyValue, text_size = panelTextSize, text_halign = text.align_right)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(confirmedBar and newSetupSignal, "New ABCD Projection Zone", "A new confirmed ABCD Projection Zone has been detected.")
alertcondition(confirmedBar and completedSignal, "ABCD Completion Reached", "A confirmed bar has reached the active ABCD completion zone.")
alertcondition(confirmedBar and reactingSignal, "ABCD Reaction Confirmed", "A confirmed bar is reacting away from the active ABCD completion zone.")
alertcondition(confirmedBar and overrunSignal, "ABCD Zone Overrun", "A confirmed bar has closed beyond the active ABCD completion zone buffer.")
````

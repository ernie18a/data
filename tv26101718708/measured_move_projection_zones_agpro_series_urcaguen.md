# Measured Move Projection Zones [AGPro Series]

- url: https://www.tradingview.com/script/uRcaGuen-Measured-Move-Projection-Zones-AGPro-Series/
- type: indicator
- pine_id: PUB;5e932ce0baed40428c18b0f8ada263dc
- version: 5.0

## Description

Measured Move Projection Zones [AGPro Series]

🔹 OVERVIEW

Measured Move Projection Zones [AGPro Series] is a premium price-action visualization tool built around one clear sequence: impulse, base, projection, and invalidation.

The script detects a qualified impulse leg, waits for a compact base range, then projects a measured-move target band from the base boundary. It also displays invalidation context, event labels, and a compact AGPro panel so the structure can be reviewed quickly on the chart.

The default profile is tuned for 1-hour charts, where measured-move structures need enough responsiveness to appear consistently while still avoiding low-quality micro-swings. The result is a clean projection map for traders who want structured continuation context without turning the chart into a dense extension grid.

This script is not designed to promise outcomes or mark every possible target. It is designed to make the measured-move workflow easier to see, compare, and audit.


🔹 WHAT MAKES IT DIFFERENT

Most projection tools start from a manual anchor, a generic extension grid, or a simple breakout distance. Measured Move Projection Zones is more selective.

It requires a directional impulse first. It then waits for a compact base. Only after the base qualifies does it create the projected target band and invalidation framework.

That sequence matters because it prevents the chart from becoming a collection of random forward boxes. The visual logic is always tied to a specific price-action chain:

Impulse leg -> base range -> projection band -> invalidation context.

The script also avoids the look of a traditional support/resistance map. The rectangles are not generic zones. They represent measured-move components: impulse body, base range, projected target band, and invalidation reference.

For public TradingView presentation, the script is deliberately visual but controlled: moderated labels, visible structure boxes, no expired-label flood, and a compact panel that summarizes the current state.


🧭 WHY THIS DOES NOT OVERLAP WITH OTHER AGPRO TOOLS

This script stays in a narrow measured-move projection lane.

It does not overlap with ATR compression or volatility-map scripts because the core logic is not volatility contraction, expansion, or envelope behavior. ATR is only used for normalization, tolerance, and spacing.

It does not overlap with breakout-quality tools because it does not score a breakout event as the main product. Breakout beyond the base boundary only changes the measured-move state from armed to active.

It does not overlap with premium/discount or valuation-zone tools because it does not map equilibrium, discount, OTE, rebalance pockets, or fair value areas. Its target band is derived from an impulse leg and base boundary, not a valuation model.

It does not overlap with wedge, reversal, or pattern-scanner tools because it does not require converging rails, neckline behavior, double tops, double bottoms, head-and-shoulders logic, or multi-pattern classification.

It does not overlap with liquidity heatmap, bias dashboard, or volume-profile tools because it does not estimate liquidity fields, higher-timeframe directional bias, POC gravity, acceptance ladders, or volume shelves.

The differentiator is simple and specific: this is an impulse-base measured-move projection visualizer with target-band and invalidation context.


⚙️ METHODOLOGY

The methodology is built in stages:

1. Swing Confirmation
The script uses pivot confirmation to identify meaningful swing points. The default pivot setting is tuned for 1-hour chart rhythm.

2. Impulse Qualification
After a valid pivot sequence appears, the script measures the leg size in ATR units. The impulse must be large enough and must form within a reasonable bar window.

3. Base Validation
Once the impulse is confirmed, the script waits for a compact base range. The base must stay within a defined ATR height and avoid excessive retracement from the impulse end.

4. Projection Construction
When the base qualifies, the script projects a measured-move target band from the base boundary. The default multiplier is 1.00, representing a classic equal measured move.

5. Invalidation Context
The opposite side of the base receives an ATR-buffered invalidation guide. This does not create a trade command; it simply marks where the measured-move structure is no longer clean.

6. State Tracking
The setup moves through clear states: Waiting, Building Base, Armed, Projecting, Target Band, Invalidated, and Expired.

7. Visual Management
The script keeps a moderated amount of historical structure visible. Event labels are capped, expired labels are disabled by default, and the projection guide line is optional to keep the chart clean.


📊 PANEL

The AGPro panel is designed for quick structure review.

Panel rows include:

- State
- Direction
- Impulse Quality
- Projection Progress
- Target Distance
- Target Band
- Base Range
- Invalidation

The first panel row follows the AGPro public-release standard: one merged blue header row containing only the panel title.

Panel location is adjustable. Panel theme is adjustable. Panel font size is adjustable. The default size is Normal for a clean public-chart look.


🎛️ KEY INPUTS

1H Pivot Confirmation Length
Controls the swing confirmation used to anchor impulse legs. Lower values are more responsive. Higher values are more selective.

1H Minimum Impulse Size
Defines the minimum impulse strength in ATR units. The default is tuned to keep 1-hour charts active without accepting very small swings.

1H Base Range Bars
Controls how many bars are used to validate the post-impulse base. The default is shorter for hourly chart pacing.

1H Maximum Base Height
Limits how tall the base can be in ATR terms. This prevents wide ranges from being treated as clean measured-move bases.

1H Maximum Base Retracement
Controls how deeply price can retrace from the impulse end while still qualifying as a measured-move structure.

Measured Move Multiplier
Controls the projection distance. The default value of 1.00 represents an equal measured move.

1H Target Band Width
Controls the ATR-based visual tolerance around the projected target.

Invalidation Buffer
Places the invalidation guide beyond the opposite side of the base range.

1H Projection Bars
Controls how far the projected target band and base extension reach forward.

1H Projection Expiration
Controls how long an armed or active projection can remain open before it expires.

1H Event Label Retention
Controls whether the chart keeps a moderated history of event labels or only the latest event label.

1H Balanced Event Labels
Caps event labels so the chart remains informative but not overloaded.

Show Projection Guide Line
Optional dotted guide from the base boundary to the target band. Disabled by default on 1-hour charts to reduce diagonal clutter.


🔍 HOW TO READ IT

Waiting
No valid impulse-base sequence is active.

Building Base
An impulse has been detected and the script is watching for a compact base.

Armed
A valid base has formed. The projection framework is ready, and the target band is mapped forward.

Projecting
Price has moved beyond the base boundary and the measured-move structure is active.

Target Band
Price has interacted with the projected target band.

Invalidated
Price has closed beyond the invalidation guide, meaning the measured-move framework is no longer clean.

Expired
The projection did not complete within the selected expiration window.

Event labels provide a fast visual timeline. The boxes show where the measured structure came from, where the base formed, and where the projected band sits.


🧩 BEST USE CASES

This script is best used on 1-hour charts where traders want a clean view of impulse-base-continuation behavior.

Strong use cases include:

- Measuring continuation structures after a directional leg
- Comparing active projections against nearby price action
- Reviewing whether a base is compact enough to support a projection
- Mapping projected target zones without using a full extension grid
- Studying failed measured moves through invalidation labels and zones
- Creating cleaner screenshots for price-action review

The script can also be used on other timeframes, but the default settings were intentionally tuned around 1-hour structure density and visual balance.


🧠 VISUAL DESIGN PHILOSOPHY

The visual design is built around premium restraint.

The chart should not look empty, but it also should not look like every candle is receiving a signal. Measured Move Projection Zones keeps the main structural elements visible:

- Impulse boxes
- Base range boxes
- Projected target bands
- Invalidation zones or guides
- Moderated event labels
- Compact AGPro panel

Expired labels are disabled by default because they can quickly become noisy on hourly charts. Event labels are still preserved in a moderated amount so the chart has enough visual context.

The optional projection guide line is disabled by default because long diagonal lines can dominate a 1-hour screenshot. Users can enable it when they want a more explicit projection path.

The goal is a chart that looks structured, premium, and publication-ready while still being easy to read.


🔔 ALERTS

The script includes alert conditions for the core lifecycle events:

- Measured Move Armed
- Projection Active
- Target Band Interaction
- Projection Invalidated
- Projection Expired

These alerts are designed around structure states, not trade commands. They help users monitor when a measured-move framework forms, activates, interacts with the projected band, invalidates, or expires.


🔹 LIMITATIONS AND TRANSPARENCY

Measured Move Projection Zones is a structural visualization tool. It does not predict future price and does not claim that a projected target band will be reached.

Pivot-based swing logic confirms structure after the necessary bars have formed. This creates cleaner anchors, but it also means the script is not trying to label every move in real time before confirmation.

The target band is a measured projection derived from the impulse and base, not a certainty zone. Invalidation and expiration states are part of the design because failed measured moves are also useful information.

Settings matter. More aggressive inputs will create more structures. More conservative inputs will create fewer, cleaner structures.


✅ IDEAL USER

This script is ideal for traders who:

- Use 1-hour charts for price-action review
- Study impulse-base-continuation behavior
- Want measured-move target zones without a cluttered extension grid
- Prefer visual structure over heavy signal text
- Want a clean AGPro-style panel for quick state review
- Care about invalidation and failed projection context
- Need a public-chart-friendly tool that looks polished, focused, and easy to understand

Measured Move Projection Zones [AGPro Series] is built for users who want a disciplined projection framework on the chart: enough structure to be useful, enough restraint to stay premium.

## Source Code

````pine
// -------------------------------------------------
// Measured Move Projection Zones [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// A measured move projection overlay that detects a qualified impulse leg,
// waits for a compact base range, then maps a projected target band,
// invalidation context, and live projection progress. The script is built
// for clean target-zone visualization, impulse quality reading, and
// structured chart planning without directional claims. V1.5 anchors impulse
// qualification to the confirmed pivot bar, centers every zone badge inside
// its zone, and hardens forward projection bounds across higher timeframes.
// -------------------------------------------------

//@version=6
indicator("Measured Move Projection Zones [AGPro Series]",
     shorttitle = "AG Pro MMP",
     overlay = true,
     max_boxes_count = 80,
     max_labels_count = 80,
     max_lines_count = 80)

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
targetBlue    = color.rgb(59, 130, 246)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
detectionGroup = "Detection"
pivotLen = input.int(4, "Pivot Confirmation Length", minval = 2, maxval = 20, group = detectionGroup, tooltip = "Confirms the chart-timeframe swing points used to anchor the measured impulse leg.")
atrLen = input.int(14, "ATR Length", minval = 5, maxval = 100, group = detectionGroup, tooltip = "ATR baseline used for impulse qualification, base tightness, target-band width, and label offsets.")
minImpulseAtr = input.float(1.8, "Minimum Impulse Size", minval = 0.5, maxval = 10.0, step = 0.1, group = detectionGroup, tooltip = "Minimum chart-timeframe impulse-leg size measured in ATR units.")
minImpulseBars = input.int(4, "Minimum Impulse Bars", minval = 1, maxval = 80, group = detectionGroup, tooltip = "Minimum number of bars allowed between the start and end pivot of the impulse leg.")
maxImpulseBars = input.int(36, "Maximum Impulse Bars", minval = 5, maxval = 200, group = detectionGroup, tooltip = "Maximum number of chart-timeframe bars allowed between the start and end pivot of the impulse leg.")
baseBars = input.int(6, "Base Range Bars", minval = 3, maxval = 40, group = detectionGroup, tooltip = "Number of chart-timeframe bars used to validate the compact base after the impulse leg.")
maxBaseAtr = input.float(1.55, "Maximum Base Height", minval = 0.2, maxval = 5.0, step = 0.05, group = detectionGroup, tooltip = "Maximum base height measured in ATR units.")
maxBaseRetrace = input.float(0.50, "Maximum Base Retracement", minval = 0.10, maxval = 0.90, step = 0.05, group = detectionGroup, tooltip = "Maximum retracement allowed from the impulse end before the setup is considered too deep.")
maxBaseWaitBars = input.int(26, "Maximum Base Wait", minval = 8, maxval = 120, group = detectionGroup, tooltip = "Maximum number of chart-timeframe bars to wait for a valid base after the impulse leg is confirmed.")

projectionGroup = "Projection"
breakBufferAtr = input.float(0.08, "Base Break Buffer", minval = 0.0, maxval = 1.0, step = 0.01, group = projectionGroup, tooltip = "ATR buffer required beyond the base boundary before the projection changes from armed to active.")
targetMultiplier = input.float(1.00, "Measured Move Multiplier", minval = 0.50, maxval = 2.50, step = 0.05, group = projectionGroup, tooltip = "Projection multiplier applied to the impulse leg.")
targetBandAtr = input.float(0.40, "Target Band Width", minval = 0.05, maxval = 2.00, step = 0.05, group = projectionGroup, tooltip = "Width of the target band measured in ATR units.")
invalidBufferAtr = input.float(0.30, "Invalidation Buffer", minval = 0.00, maxval = 2.00, step = 0.05, group = projectionGroup, tooltip = "ATR buffer beyond the opposite side of the base range used for invalidation context.")
projectionBars = input.int(42, "Projection Bars", minval = 15, maxval = 180, group = projectionGroup, tooltip = "Chart-timeframe forward distance used for target bands, base extensions, and projection guide lines.")
adaptiveProjection = input.bool(true, "Adaptive HTF Projection", group = projectionGroup, tooltip = "Automatically widens projections on higher timeframes so target and base zones remain readable.")
expireBars = input.int(54, "Projection Expiration", minval = 20, maxval = 240, group = projectionGroup, tooltip = "Maximum chart-timeframe bars an armed or active projection can remain open before it is marked as expired.")

visualGroup = "Visuals"
showImpulseBox = input.bool(true, "Show Impulse Box", group = visualGroup, tooltip = "Displays a translucent box around the measured impulse leg.")
showBaseBox = input.bool(true, "Show Base Range Box", group = visualGroup, tooltip = "Displays the compact base range that anchors the measured-move projection.")
showTargetBand = input.bool(true, "Show Projected Target Band", group = visualGroup, tooltip = "Displays the projected target band derived from the measured impulse leg.")
showInvalidationGuide = input.bool(true, "Show Invalidation Guide", group = visualGroup, tooltip = "Displays a clean invalidation guide beyond the opposite side of the base range.")
showProgressMarker = input.bool(true, "Show Progress Marker", group = visualGroup, tooltip = "Displays a live marker showing how far price has progressed from the base boundary toward the projected band.")
showEventLabels = input.bool(true, "Show Event Labels", group = visualGroup, tooltip = "Displays compact labels for armed projections, active projections, target-band interaction, and invalidation.")
showCenteredZoneBadges = input.bool(true, "Show Zone Badges", group = visualGroup, tooltip = "Shows a centered badge inside every impulse, base, and target zone so no active box appears unlabeled.")
zoneBadgeAnchor = input.float(0.50, "Zone Badge Horizontal Position", minval = 0.35, maxval = 0.65, step = 0.05, group = visualGroup, tooltip = "Controls the badge position inside each zone. The default 0.50 places it at the horizontal center.")
eventLabelMode = input.string("Balanced", "Event Label Retention", options = ["Balanced", "All Events", "Latest Only"], group = visualGroup, tooltip = "Controls event-label retention. Balanced keeps enough structure without crowding the chart.")
eventLabelCooldown = input.int(8, "Event Label Cooldown", minval = 0, maxval = 80, group = visualGroup, tooltip = "Minimum bars between new event labels. This keeps repeated armed/active labels from clustering.")
showExpiredLabels = input.bool(false, "Show Expired Labels", group = visualGroup, tooltip = "Displays labels when a measured-move structure expires. Disabled by default to keep the public chart clean.")
showProjectionGuide = input.bool(false, "Show Projection Guide Line", group = visualGroup, tooltip = "Displays the dotted guide from the base boundary to the projected target.")
fadeClosedSetups = input.bool(true, "Fade Archived Setups", group = visualGroup, tooltip = "Softens target-hit, invalidated, and expired projection drawings so the active structure stands out.")
zoneOpacity = input.int(84, "Zone Opacity", minval = 60, maxval = 96, group = visualGroup, tooltip = "Controls the transparency of impulse, base, and target-zone boxes.")
labelOffsetAtr = input.float(0.80, "Label Offset", minval = 0.10, maxval = 4.00, step = 0.05, group = visualGroup, tooltip = "ATR-based vertical offset used to keep event labels away from candle bodies.")
maxVisibleLabels = input.int(5, "Balanced Event Labels", minval = 4, maxval = 50, group = visualGroup, tooltip = "Caps retained event labels so the chart keeps useful visual context without becoming crowded.")
maxSetupHistory = input.int(1, "Structure History", minval = 1, maxval = 14, group = visualGroup, tooltip = "Controls how many historical measured-move structures can remain visible before older drawings are removed. The default focuses the chart on the most recent structure for the cleanest view.")

styleGroup = "Style"
labelFontInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = styleGroup, tooltip = "Controls the size of all chart labels created by the script.")
panelFontInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = styleGroup, tooltip = "Controls the AG Pro panel font size.")
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = styleGroup, tooltip = "Controls where the AG Pro summary panel is anchored on the chart.")
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = styleGroup, tooltip = "Controls the panel color theme without changing the core chart objects.")
showPanel = input.bool(true, "Show Panel", group = styleGroup, tooltip = "Shows or hides the compact AG Pro measured-move summary panel.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(value, minValue, maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_size(sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_text_on(_bg) =>
    brightness = color.r(_bg) + color.g(_bg) + color.b(_bg)
    brightness >= 360 ? color.rgb(15, 23, 42) : color.white

f_panel_position(locationInput) =>
    switch locationInput
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
    panelTheme == "Clean Light" ? color.rgb(241, 245, 249) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_alt_bg(int row) =>
    bool evenRow = row % 2 == 0
    panelTheme == "Clean Light" ? (evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)) : panelTheme == "Slate" ? (evenRow ? color.rgb(37, 49, 70) : color.rgb(30, 41, 59)) : (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_panel_border() =>
    panelTheme == "Clean Light" ? color.rgb(148, 163, 184) : panelTheme == "Slate" ? color.rgb(71, 85, 105) : panelBorder

f_panel_label() =>
    panelTheme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value() =>
    panelTheme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_state_on_panel(_state) =>
    if panelTheme == "Clean Light"
        _state == bullColor ? color.rgb(13, 118, 99) : _state == bearColor ? color.rgb(178, 44, 112) : _state == neutralColor ? color.rgb(133, 77, 14) : _state == accentColor ? color.rgb(67, 56, 202) : _state
    else
        _state

f_trim_boxes(array<box> items, int limit) =>
    while array.size(items) > limit
        box oldItem = array.shift(items)
        box.delete(oldItem)

f_trim_lines(array<line> items, int limit) =>
    while array.size(items) > limit
        line oldItem = array.shift(items)
        line.delete(oldItem)

f_trim_labels(array<label> items, int limit) =>
    while array.size(items) > limit
        label oldItem = array.shift(items)
        label.delete(oldItem)

f_clear_labels(array<label> items) =>
    while array.size(items) > 0
        label oldItem = array.shift(items)
        label.delete(oldItem)

f_state_text(int stateValue) =>
    switch stateValue
        1 => "BUILDING BASE"
        2 => "ARMED"
        3 => "PROJECTING"
        4 => "TARGET BAND"
        5 => "INVALIDATED"
        6 => "EXPIRED"
        => "WAITING"

f_action_text(int stateValue) =>
    switch stateValue
        1 => "Wait For Base"
        2 => "Watch Break"
        3 => "Hold To Target"
        4 => "Manage Target"
        5 => "Stand Down"
        6 => "Re-scan"
        => "Scan Impulse"

f_state_color(int stateValue, int dirValue) =>
    color stateColor = neutralColor
    if stateValue == 3 or stateValue == 4
        stateColor := dirValue == 1 ? bullColor : bearColor
    else if stateValue == 5
        stateColor := bearColor
    else if stateValue == 6
        stateColor := panelLabelCol
    else if stateValue == 2
        stateColor := accentColor
    stateColor

f_direction_text(int dirValue) =>
    switch dirValue
        1 => "Bullish"
        -1 => "Bearish"
        => "Neutral"

f_format_price(float priceValue) =>
    na(priceValue) ? "n/a" : str.tostring(priceValue, format.mintick)

f_format_pct(float pctValue) =>
    na(pctValue) ? "n/a" : str.tostring(pctValue, "0.0") + "%"

f_format_atr(float atrValue) =>
    na(atrValue) ? "n/a" : str.format("{0,number,#.00} ATR", atrValue)

f_panel_cell(table panelRef, int col, int row, string txt, color txtColor, color bgColor, string sizeInput, string alignInput) =>
    table.cell(panelRef, col, row, txt, text_color = txtColor, bgcolor = bgColor, text_size = f_size(sizeInput), text_halign = alignInput == "left" ? text.align_left : alignInput == "right" ? text.align_right : text.align_center)

// -------------------------------------------------
// Object storage
// -------------------------------------------------
var box[] boxArchive = array.new_box()
var line[] lineArchive = array.new_line()
var label[] labelArchive = array.new_label()
var label[] zoneLabelArchive = array.new_label()

var box activeImpulseBox = na
var box activeBaseBox = na
var box activeTargetBox = na
var line activeInvalidLine = na
var line activeGuideLine = na
var line activeProgressLine = na
var label activeProgressLabel = na
var label activeImpulseBadge = na
var label activeBaseBadge = na
var label activeTargetBadge = na
var int lastEventLabelBar = na

f_can_label(int xValue) =>
    showEventLabels and (eventLabelCooldown == 0 or na(lastEventLabelBar) or xValue - lastEventLabelBar >= eventLabelCooldown)

f_add_label(int xValue, float yValue, string labelText, color bgColor, color textColor, string styleChoice) =>
    if eventLabelMode == "Latest Only"
        f_clear_labels(labelArchive)
    label newLabel = label.new(xValue, yValue, labelText, xloc = xloc.bar_index, yloc = yloc.price, style = styleChoice, color = bgColor, textcolor = textColor, size = f_size(labelFontInput))
    array.push(labelArchive, newLabel)
    int keepCount = eventLabelMode == "Balanced" ? int(math.min(maxVisibleLabels, 8)) : maxVisibleLabels
    f_trim_labels(labelArchive, keepCount)
    newLabel

f_badge_x(int leftX, int rightX) =>
    int(math.round(leftX + (rightX - leftX) * zoneBadgeAnchor))

f_zone_badge(int leftX, int rightX, float topValue, float bottomValue, string badgeText, color badgeColor) =>
    label badge = na
    if showCenteredZoneBadges
        badge := label.new(f_badge_x(leftX, rightX), (topValue + bottomValue) * 0.5, badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(badgeColor, 8), textcolor = f_text_on(badgeColor), size = f_size(labelFontInput))
        array.push(zoneLabelArchive, badge)
        f_trim_labels(zoneLabelArchive, maxSetupHistory * 3)
    badge

f_update_zone_badge(label badge, int leftX, int rightX, float topValue, float bottomValue, string badgeText, color badgeColor) =>
    if showCenteredZoneBadges and not na(badge)
        label.set_x(badge, f_badge_x(leftX, rightX))
        label.set_y(badge, (topValue + bottomValue) * 0.5)
        label.set_text(badge, badgeText)
        label.set_color(badge, color.new(badgeColor, 8))
        label.set_textcolor(badge, f_text_on(badgeColor))
        label.set_size(badge, f_size(labelFontInput))
        label.set_style(badge, label.style_label_center)

// -------------------------------------------------
// Core state
// -------------------------------------------------
atr = ta.atr(atrLen)
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)
baseWindowHigh = ta.highest(high, baseBars)
baseWindowLow = ta.lowest(low, baseBars)

var int lastSwingType = 0
var int lastSwingBar = na
var float lastSwingPrice = na

var int setupState = 0
var int setupDir = 0
var int impulseStartBar = na
var int impulseEndBar = na
var float impulseStartPrice = na
var float impulseEndPrice = na
var float impulseSize = na
var float impulseAtrSize = na
var float impulseQuality = na
var int baseStartBar = na
var int baseEndBar = na
var float baseHigh = na
var float baseLow = na
var float baseHeight = na
var float projectionOrigin = na
var float targetMid = na
var float targetTop = na
var float targetBottom = na
var float invalidationPrice = na
var int breakoutBar = na
var float projectionProgress = na
var bool eventArmed = false
var bool eventProjection = false
var bool eventTarget = false
var bool eventInvalid = false
var bool eventExpired = false

eventArmed := false
eventProjection := false
eventTarget := false
eventInvalid := false
eventExpired := false

canStartNew = setupState == 0 or setupState >= 4
detectedImpulse = false
detectedDir = 0
int detectedStartBar = na
int detectedEndBar = na
float detectedStartPrice = na
float detectedEndPrice = na
float detectedLegSize = na
float detectedLegAtr = na
float detectedQuality = na

if not na(pl)
    int pivotBar = bar_index - pivotLen
    float pivotPrice = pl
    if lastSwingType == 1 and not na(lastSwingBar) and canStartNew
        int legBars = pivotBar - lastSwingBar
        float legSize = lastSwingPrice - pivotPrice
        float pivotAtr = atr[pivotLen]
        float legAtr = pivotAtr > 0 ? legSize / pivotAtr : na
        bool legQualifies = legSize > 0 and legBars >= minImpulseBars and legBars <= maxImpulseBars and legAtr >= minImpulseAtr
        if legQualifies
            float sizeScore = f_clamp(legAtr / (minImpulseAtr * 2.0), 0.0, 1.0) * 55.0
            float tempoDenom = math.max(1.0, float(maxImpulseBars - minImpulseBars))
            float tempoScore = f_clamp(1.0 - (float(legBars - minImpulseBars) / tempoDenom), 0.0, 1.0) * 25.0
            detectedImpulse := true
            detectedDir := -1
            detectedStartBar := lastSwingBar
            detectedEndBar := pivotBar
            detectedStartPrice := lastSwingPrice
            detectedEndPrice := pivotPrice
            detectedLegSize := legSize
            detectedLegAtr := legAtr
            detectedQuality := f_clamp(sizeScore + tempoScore + 10.0, 0.0, 80.0)
    lastSwingType := -1
    lastSwingBar := pivotBar
    lastSwingPrice := pivotPrice

if not na(ph)
    int pivotBar = bar_index - pivotLen
    float pivotPrice = ph
    if not detectedImpulse and lastSwingType == -1 and not na(lastSwingBar) and canStartNew
        int legBars = pivotBar - lastSwingBar
        float legSize = pivotPrice - lastSwingPrice
        float pivotAtr = atr[pivotLen]
        float legAtr = pivotAtr > 0 ? legSize / pivotAtr : na
        bool legQualifies = legSize > 0 and legBars >= minImpulseBars and legBars <= maxImpulseBars and legAtr >= minImpulseAtr
        if legQualifies
            float sizeScore = f_clamp(legAtr / (minImpulseAtr * 2.0), 0.0, 1.0) * 55.0
            float tempoDenom = math.max(1.0, float(maxImpulseBars - minImpulseBars))
            float tempoScore = f_clamp(1.0 - (float(legBars - minImpulseBars) / tempoDenom), 0.0, 1.0) * 25.0
            detectedImpulse := true
            detectedDir := 1
            detectedStartBar := lastSwingBar
            detectedEndBar := pivotBar
            detectedStartPrice := lastSwingPrice
            detectedEndPrice := pivotPrice
            detectedLegSize := legSize
            detectedLegAtr := legAtr
            detectedQuality := f_clamp(sizeScore + tempoScore + 10.0, 0.0, 80.0)
    lastSwingType := 1
    lastSwingBar := pivotBar
    lastSwingPrice := pivotPrice

int projectionBoost = adaptiveProjection ? timeframe.isweekly ? 2 : timeframe.ismonthly ? 3 : 1 : 1
int forwardBars = int(math.min(projectionBars * projectionBoost, 480))

if detectedImpulse
    setupState := 1
    setupDir := detectedDir
    impulseStartBar := detectedStartBar
    impulseEndBar := detectedEndBar
    impulseStartPrice := detectedStartPrice
    impulseEndPrice := detectedEndPrice
    impulseSize := detectedLegSize
    impulseAtrSize := detectedLegAtr
    impulseQuality := detectedQuality
    baseStartBar := na
    baseEndBar := na
    baseHigh := na
    baseLow := na
    baseHeight := na
    projectionOrigin := na
    targetMid := na
    targetTop := na
    targetBottom := na
    invalidationPrice := na
    breakoutBar := na
    projectionProgress := na
    activeBaseBox := na
    activeTargetBox := na
    activeInvalidLine := na
    activeGuideLine := na
    activeImpulseBadge := na
    activeBaseBadge := na
    activeTargetBadge := na
    if showImpulseBox
        color impulseColor = setupDir == 1 ? bullColor : bearColor
        float impulseTop = math.max(impulseStartPrice, impulseEndPrice)
        float impulseBottom = math.min(impulseStartPrice, impulseEndPrice)
        activeImpulseBox := box.new(impulseStartBar, impulseTop, impulseEndBar, impulseBottom, xloc = xloc.bar_index, bgcolor = color.new(impulseColor, zoneOpacity), border_color = color.new(impulseColor, 15), border_width = 1)
        array.push(boxArchive, activeImpulseBox)
        if showCenteredZoneBadges
            int impulseBadgeX = int(math.round((impulseStartBar + impulseEndBar) / 2))
            activeImpulseBadge := label.new(impulseBadgeX, (impulseTop + impulseBottom) * 0.5, "IMPULSE LEG\n" + f_format_atr(impulseAtrSize), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(impulseColor, 8), textcolor = f_text_on(impulseColor), size = f_size(labelFontInput))
            array.push(zoneLabelArchive, activeImpulseBadge)
            f_trim_labels(zoneLabelArchive, maxSetupHistory * 3)
        f_trim_boxes(boxArchive, maxSetupHistory * 3)

if setupState == 1 and not na(impulseEndBar)
    int barsAfterImpulse = bar_index - impulseEndBar
    bool waitedTooLong = barsAfterImpulse > maxBaseWaitBars
    if waitedTooLong
        setupState := 6
        eventExpired := true
    else if barsAfterImpulse >= baseBars
        float candidateHigh = baseWindowHigh
        float candidateLow = baseWindowLow
        float candidateHeight = candidateHigh - candidateLow
        float candidateHeightAtr = atr > 0 ? candidateHeight / atr : na
        float retrace = setupDir == 1 ? (impulseEndPrice - candidateLow) / impulseSize : (candidateHigh - impulseEndPrice) / impulseSize
        bool baseTight = candidateHeightAtr <= maxBaseAtr
        bool baseRetraceOk = retrace >= 0 and retrace <= maxBaseRetrace
        if baseTight and baseRetraceOk
            baseStartBar := bar_index - baseBars + 1
            baseEndBar := bar_index
            baseHigh := candidateHigh
            baseLow := candidateLow
            baseHeight := candidateHeight
            projectionOrigin := setupDir == 1 ? baseHigh : baseLow
            targetMid := setupDir == 1 ? projectionOrigin + impulseSize * targetMultiplier : projectionOrigin - impulseSize * targetMultiplier
            float bandHalf = atr * targetBandAtr * 0.5
            targetTop := targetMid + bandHalf
            targetBottom := targetMid - bandHalf
            invalidationPrice := setupDir == 1 ? baseLow - atr * invalidBufferAtr : baseHigh + atr * invalidBufferAtr
            float baseTightScore = f_clamp(1.0 - (candidateHeightAtr / maxBaseAtr), 0.0, 1.0) * 12.0
            float baseRetraceScore = f_clamp(1.0 - (retrace / maxBaseRetrace), 0.0, 1.0) * 8.0
            impulseQuality := f_clamp(impulseQuality + baseTightScore + baseRetraceScore, 0.0, 100.0)
            setupState := 2
            eventArmed := true
            color baseColor = setupDir == 1 ? bullColor : bearColor
            if showBaseBox
                activeBaseBox := box.new(baseStartBar, baseHigh, bar_index + forwardBars, baseLow, xloc = xloc.bar_index, bgcolor = color.new(neutralColor, zoneOpacity), border_color = color.new(neutralColor, 10), border_width = 1)
                array.push(boxArchive, activeBaseBox)
                activeBaseBadge := f_zone_badge(baseStartBar, bar_index + forwardBars, baseHigh, baseLow, "BASE RANGE\n" + f_format_atr(not na(baseHeight) and atr > 0 ? baseHeight / atr : na), neutralColor)
            if showTargetBand
                activeTargetBox := box.new(baseEndBar, targetTop, bar_index + forwardBars, targetBottom, xloc = xloc.bar_index, bgcolor = color.new(baseColor, zoneOpacity), border_color = color.new(baseColor, 0), border_width = 1)
                array.push(boxArchive, activeTargetBox)
                activeTargetBadge := f_zone_badge(baseEndBar, bar_index + forwardBars, targetTop, targetBottom, "TARGET BAND\n" + f_format_price(targetMid), baseColor)
            if showInvalidationGuide
                activeInvalidLine := line.new(baseStartBar, invalidationPrice, bar_index + forwardBars, invalidationPrice, xloc = xloc.bar_index, extend = extend.none, color = color.new(bearColor, 0), style = line.style_dashed, width = 1)
                array.push(lineArchive, activeInvalidLine)
            if showProjectionGuide
                activeGuideLine := line.new(baseEndBar, projectionOrigin, baseEndBar + forwardBars, targetMid, xloc = xloc.bar_index, extend = extend.none, color = color.new(baseColor, 45), style = line.style_dotted, width = 1)
                array.push(lineArchive, activeGuideLine)
            f_trim_boxes(boxArchive, maxSetupHistory * 3)
            f_trim_lines(lineArchive, maxSetupHistory * 2)
            float armedOffset = labelOffsetAtr + 0.35
            float labelY = setupDir == 1 ? baseLow - atr * armedOffset : baseHigh + atr * armedOffset
            string styleChoice = setupDir == 1 ? label.style_label_up : label.style_label_down
            if f_can_label(baseEndBar)
                f_add_label(baseEndBar, labelY, "ARMED", color.new(accentColor, 0), f_text_on(accentColor), styleChoice)
                lastEventLabelBar := baseEndBar

if setupState == 2
    bool breakoutNow = setupDir == 1 ? close > baseHigh + atr * breakBufferAtr : close < baseLow - atr * breakBufferAtr
    bool invalidNow = setupDir == 1 ? close < invalidationPrice : close > invalidationPrice
    bool expiredNow = bar_index - baseEndBar > expireBars
    if invalidNow
        setupState := 5
        eventInvalid := true
    else if breakoutNow
        setupState := 3
        breakoutBar := bar_index
        eventProjection := true
        float labelY = setupDir == 1 ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr
        string styleChoice = setupDir == 1 ? label.style_label_up : label.style_label_down
        if f_can_label(bar_index)
            f_add_label(bar_index, labelY, "ACTIVE", color.new(setupDir == 1 ? bullColor : bearColor, 0), f_text_on(setupDir == 1 ? bullColor : bearColor), styleChoice)
            lastEventLabelBar := bar_index
    else if expiredNow
        setupState := 6
        eventExpired := true

if setupState == 3
    bool targetNow = setupDir == 1 ? high >= targetBottom : low <= targetTop
    bool invalidNow = setupDir == 1 ? close < invalidationPrice : close > invalidationPrice
    bool expiredNow = bar_index - breakoutBar > expireBars
    if invalidNow
        setupState := 5
        eventInvalid := true
    else if targetNow
        setupState := 4
        eventTarget := true
    else if expiredNow
        setupState := 6
        eventExpired := true

if eventTarget
    float labelY = setupDir == 1 ? targetBottom : targetTop
    string styleChoice = setupDir == 1 ? label.style_label_down : label.style_label_up
    if f_can_label(bar_index)
        f_add_label(bar_index, labelY, "TARGET", color.new(setupDir == 1 ? bullColor : bearColor, 0), f_text_on(setupDir == 1 ? bullColor : bearColor), styleChoice)
        lastEventLabelBar := bar_index

if eventInvalid
    float labelY = setupDir == 1 ? high + atr * labelOffsetAtr : low - atr * labelOffsetAtr
    string styleChoice = setupDir == 1 ? label.style_label_down : label.style_label_up
    if f_can_label(bar_index)
        f_add_label(bar_index, labelY, "INVALID", color.new(bearColor, 0), f_text_on(bearColor), styleChoice)
        lastEventLabelBar := bar_index

if eventExpired and showExpiredLabels and setupState == 6 and f_can_label(bar_index)
    f_add_label(bar_index, close, "EXPIRED", color.new(panelBorder, 0), f_text_on(panelBorder), label.style_label_left)
    lastEventLabelBar := bar_index

// -------------------------------------------------
// Target hit-rate proof (Confirm Rate)
// -------------------------------------------------
var int  mmTotal = 0
var int  mmWon   = 0
var bool mmPend  = false

if barstate.isconfirmed
    if eventProjection
        mmPend := true
    if mmPend and eventTarget
        mmTotal += 1
        mmWon += 1
        mmPend := false
    if mmPend and eventInvalid
        mmTotal += 1
        mmPend := false
    if mmPend and eventExpired
        mmTotal += 1
        mmPend := false

float mmRate = mmTotal > 0 ? mmWon / mmTotal * 100.0 : na

if fadeClosedSetups and (eventTarget or eventInvalid or eventExpired)
    color closedColor = eventTarget ? (setupDir == 1 ? bullColor : bearColor) : panelBorder
    if not na(activeImpulseBox)
        box.set_bgcolor(activeImpulseBox, color.new(closedColor, 90))
        box.set_border_color(activeImpulseBox, color.new(closedColor, 55))
    if not na(activeBaseBox)
        box.set_bgcolor(activeBaseBox, color.new(neutralColor, 89))
        box.set_border_color(activeBaseBox, color.new(neutralColor, 55))
    if not na(activeTargetBox)
        box.set_bgcolor(activeTargetBox, color.new(closedColor, 88))
        box.set_border_color(activeTargetBox, color.new(closedColor, 50))
    if not na(activeInvalidLine)
        line.set_color(activeInvalidLine, color.new(closedColor, 58))
    if not na(activeGuideLine)
        line.set_color(activeGuideLine, color.new(closedColor, 62))

bool liveProjection = setupState == 2 or setupState == 3
if liveProjection
    int rightEdge = bar_index + forwardBars
    if not na(activeBaseBox)
        box.set_right(activeBaseBox, rightEdge)
    if not na(activeTargetBox)
        box.set_right(activeTargetBox, rightEdge)
    f_update_zone_badge(activeBaseBadge, baseStartBar, rightEdge, baseHigh, baseLow, "BASE RANGE\n" + f_format_atr(not na(baseHeight) and atr > 0 ? baseHeight / atr : na), neutralColor)
    f_update_zone_badge(activeTargetBadge, baseEndBar, rightEdge, targetTop, targetBottom, "TARGET BAND\n" + f_format_price(targetMid), setupDir == 1 ? bullColor : bearColor)
    if not na(activeInvalidLine)
        line.set_x2(activeInvalidLine, rightEdge)
        line.set_y1(activeInvalidLine, invalidationPrice)
        line.set_y2(activeInvalidLine, invalidationPrice)
    if not na(activeGuideLine)
        line.set_x2(activeGuideLine, rightEdge)
        line.set_y1(activeGuideLine, projectionOrigin)
        line.set_y2(activeGuideLine, targetMid)

float rawProgress = na
if setupState == 2
    rawProgress := 0.0
else if setupState == 3 or setupState == 4
    float denominator = math.max(math.abs(targetMid - projectionOrigin), syminfo.mintick)
    rawProgress := setupDir == 1 ? ((close - projectionOrigin) / denominator) * 100.0 : ((projectionOrigin - close) / denominator) * 100.0
projectionProgress := na(rawProgress) ? projectionProgress : f_clamp(rawProgress, 0.0, 100.0)

if (not showProgressMarker or setupState == 0 or setupState == 1 or setupState == 5 or setupState == 6) and not na(activeProgressLine)
    line.delete(activeProgressLine)
    activeProgressLine := na
if (not showProgressMarker or setupState == 0 or setupState == 1 or setupState == 5 or setupState == 6) and not na(activeProgressLabel)
    label.delete(activeProgressLabel)
    activeProgressLabel := na

if showProgressMarker and (setupState == 2 or setupState == 3 or setupState == 4)
    color markerColor = f_state_color(setupState, setupDir)
    float markerPrice = setupState == 2 ? projectionOrigin : close
    if na(activeProgressLine)
        activeProgressLine := line.new(bar_index, markerPrice, bar_index + 8, markerPrice, xloc = xloc.bar_index, extend = extend.none, color = markerColor, style = line.style_solid, width = 2)
    else
        line.set_x1(activeProgressLine, bar_index)
        line.set_x2(activeProgressLine, bar_index + 8)
        line.set_y1(activeProgressLine, markerPrice)
        line.set_y2(activeProgressLine, markerPrice)
        line.set_color(activeProgressLine, markerColor)
    string progressText = "Progress " + f_format_pct(projectionProgress)
    if na(activeProgressLabel)
        activeProgressLabel := label.new(bar_index + 9, markerPrice, progressText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(markerColor, 0), textcolor = f_text_on(markerColor), size = f_size(labelFontInput))
    else
        label.set_x(activeProgressLabel, bar_index + 9)
        label.set_y(activeProgressLabel, markerPrice)
        label.set_text(activeProgressLabel, progressText)
        label.set_color(activeProgressLabel, color.new(markerColor, 0))
        label.set_textcolor(activeProgressLabel, f_text_on(markerColor))
        label.set_size(activeProgressLabel, f_size(labelFontInput))

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table agPanel = table.new(f_panel_position(panelLocation), 4, 6, bgcolor = f_panel_bg(), frame_color = f_panel_border(), frame_width = 1, border_color = f_panel_border(), border_width = 1)

if barstate.islast
    table.set_position(agPanel, f_panel_position(panelLocation))
    table.clear(agPanel, 0, 0, 3, 5)
    if showPanel
        table.merge_cells(agPanel, 0, 0, 3, 0)
        f_panel_cell(agPanel, 0, 0, "AG Pro Measured Move Projection Zones", headerText, headerBg, panelFontInput, "center")
        color stateColor = f_state_color(setupState, setupDir)
        string qualityText = na(impulseQuality) ? "n/a" : str.format("{0,number,#}/100", impulseQuality)
        string progressPanelText = f_format_pct(projectionProgress)
        float targetDistance = not na(targetMid) ? math.abs(targetMid - close) : na
        float targetDistanceAtr = not na(targetDistance) and atr > 0 ? targetDistance / atr : na
        string distanceText = f_format_atr(targetDistanceAtr)
        string mmRateText = mmTotal > 0 ? str.tostring(int(math.round(mmRate))) + "% (" + str.tostring(mmTotal) + ")" : "Building"
        color mmRateCol = na(mmRate) ? f_panel_value() : mmRate >= 55.0 ? bullColor : mmRate >= 40.0 ? neutralColor : bearColor
        color row1 = f_panel_alt_bg(1)
        color row2 = f_panel_alt_bg(2)
        color row3 = f_panel_alt_bg(3)
        color row4 = f_panel_alt_bg(4)
        color row5 = f_panel_alt_bg(5)
        f_panel_cell(agPanel, 0, 1, "State", f_panel_label(), row1, panelFontInput, "left")
        f_panel_cell(agPanel, 1, 1, f_state_text(setupState), f_state_on_panel(stateColor), row1, panelFontInput, "right")
        f_panel_cell(agPanel, 2, 1, "Direction", f_panel_label(), row1, panelFontInput, "left")
        f_panel_cell(agPanel, 3, 1, f_direction_text(setupDir), f_panel_value(), row1, panelFontInput, "right")
        f_panel_cell(agPanel, 0, 2, "Impulse Quality", f_panel_label(), row2, panelFontInput, "left")
        f_panel_cell(agPanel, 1, 2, qualityText, f_panel_value(), row2, panelFontInput, "right")
        f_panel_cell(agPanel, 2, 2, "Progress", f_panel_label(), row2, panelFontInput, "left")
        f_panel_cell(agPanel, 3, 2, progressPanelText, f_panel_value(), row2, panelFontInput, "right")
        f_panel_cell(agPanel, 0, 3, "Target Distance", f_panel_label(), row3, panelFontInput, "left")
        f_panel_cell(agPanel, 1, 3, distanceText, f_panel_value(), row3, panelFontInput, "right")
        f_panel_cell(agPanel, 2, 3, "Target Band", f_panel_label(), row3, panelFontInput, "left")
        f_panel_cell(agPanel, 3, 3, f_format_price(targetMid), f_panel_value(), row3, panelFontInput, "right")
        f_panel_cell(agPanel, 0, 4, "Base Range", f_panel_label(), row4, panelFontInput, "left")
        f_panel_cell(agPanel, 1, 4, f_format_atr(not na(baseHeight) and atr > 0 ? baseHeight / atr : na), f_panel_value(), row4, panelFontInput, "right")
        f_panel_cell(agPanel, 2, 4, "Invalidation", f_panel_label(), row4, panelFontInput, "left")
        f_panel_cell(agPanel, 3, 4, f_format_price(invalidationPrice), f_panel_value(), row4, panelFontInput, "right")
        f_panel_cell(agPanel, 0, 5, "Action", f_panel_label(), row5, panelFontInput, "left")
        f_panel_cell(agPanel, 1, 5, f_action_text(setupState), f_state_on_panel(stateColor), row5, panelFontInput, "right")
        f_panel_cell(agPanel, 2, 5, "Band Hit Rate", f_panel_label(), row5, panelFontInput, "left")
        f_panel_cell(agPanel, 3, 5, mmRateText, mmRateCol, row5, panelFontInput, "right")

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(eventArmed, "Measured Move Armed", "Measured Move Projection Zones: a compact base has armed a new measured-move projection.")
alertcondition(eventProjection, "Projection Active", "Measured Move Projection Zones: price has moved beyond the base boundary and the projection is active.")
alertcondition(eventTarget, "Target Band Interaction", "Measured Move Projection Zones: price has interacted with the projected target band.")
alertcondition(eventInvalid, "Projection Invalidated", "Measured Move Projection Zones: price has closed beyond the invalidation guide.")
alertcondition(eventExpired, "Projection Expired", "Measured Move Projection Zones: the measured-move projection has expired without a final state.")

// Hidden reference plots
plot(mmRate, "Target Band Hit Rate", display = display.none)
plot(projectionProgress, "Projection Progress", display = display.none)
````

# Stop Cluster Magnet Map [AGPro Series]

- url: https://www.tradingview.com/script/6zCpGtpB-Stop-Cluster-Magnet-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;1cc83805353f4930ae113f265fd7dcd5
- version: 5.0

## Description

Stop Cluster Magnet Map [AGPro Series]

🧠 Core Idea

Where are clustered stops likely sitting, and is price being pulled toward them or rejecting after a sweep?


📌 Overview / What it does

Stop Cluster Magnet Map is a rule-based liquidity and market-structure visualization tool designed to identify repeated swing-high and swing-low areas where stop orders may cluster.

The script maps upper and lower stop-cluster zones, grades their quality, tracks magnet pressure, and highlights potential sweep or rejection behavior after price interacts with those zones.

It does not predict future price direction, automate trades, or claim that any stop cluster must be taken. It only visualizes structural conditions that may deserve attention.


🎯 Purpose & Design Philosophy

This script was built to solve a common chart-reading problem: traders often talk about liquidity above highs or below lows, but many tools do not clearly separate clustered stop areas from random swing points.

The design goal is to make stop-cluster context visible at a glance without turning the chart into a noisy signal machine.

It helps traders who study price action, liquidity sweeps, equal highs, equal lows, stop hunts, and structural reaction zones.


⚡ Why This Script Is Different

Most tools mark every swing high or swing low as if each level has the same importance.

This script does NOT treat every pivot as meaningful liquidity.

Instead, it looks for repeated nearby swing points, builds a mapped stop-cluster zone, grades the cluster, tracks magnet pressure, and separates sweep behavior from simple proximity.


⚙️ Methodology

1. Context Detection
The script detects confirmed swing highs and swing lows using a configurable pivot length.

2. Reference Mapping
Nearby repeated swing highs are grouped into an upper stop cluster, while nearby repeated swing lows are grouped into a lower stop cluster.

3. Reaction Evaluation
The script evaluates distance, recency, number of touches, sweep events, and post-sweep close behavior.

4. Visual Output
The active stop-cluster zones, magnet rail, right-side tags, event labels, and decision panel are displayed using a clean AGPro visual hierarchy.


🗺️ How to Read the Chart

Zones represent areas where repeated highs or lows have created potential clustered stops.

Labels identify important events such as upper stops, lower stops, magnet pressure, and sweep behavior.

Colors follow the AGPro visual language: teal for lower-side or recovery-oriented context, pink for upper-side or risk-oriented context, yellow for neutral attention, and indigo for magnet reference.

The panel summarizes the current magnet state, score, upper/lower cluster quality, cluster prices, sweep risk, next context, and active timeframe.


🚦 Signals & States

• UPPER STOPS → repeated swing highs have formed a valid upper stop cluster

• LOWER STOPS → repeated swing lows have formed a valid lower stop cluster

• UPSIDE MAGNET → price is near a higher-quality upper stop cluster

• DOWNSIDE MAGNET → price is near a higher-quality lower stop cluster

• UPPER SWEEP → price moved above the upper cluster and closed back inside

• LOWER SWEEP → price moved below the lower cluster and closed back inside

• BALANCED CLUSTERS → both upper and lower clusters are active, with no dominant side


🔔 Alerts Logic

Alerts can trigger when a new upper or lower stop cluster becomes valid, when price sweeps a stop cluster and closes back inside, or when the dominant magnet side changes.

These alerts are attention markers only. They are not buy or sell signals.


🧩 Confluence Logic (Optional)

The context becomes stronger when a valid stop cluster has multiple touches, remains recent, price approaches the cluster, and sweep behavior appears with a close back inside the mapped zone.

Cluster quality plus proximity plus reaction behavior creates a stronger read than any single condition alone.


📊 When to Use

• Around equal highs or equal lows

• During range-bound markets where stop pools may form

• Before or after liquidity sweeps

• When price is approaching a visible cluster of prior swing points

• When evaluating whether a move is targeting external liquidity


⚠️ When NOT to Use

• In extremely illiquid markets

• During chaotic news-driven candles

• When price history is too short to build reliable clusters

• When the chart is dominated by random spikes rather than readable structure

• As a standalone entry or exit system


🎛️ Key Inputs

• Swing Pivot Length → controls how swing highs and lows are confirmed

• Cluster Validity Lookback → controls how long a cluster remains relevant

• Minimum Cluster Touches → controls how many nearby pivots are needed

• Cluster Width ATR → controls how wide each stop-cluster grouping can be

• Magnet Nearness ATR → controls how sensitive magnet proximity becomes

• Visual settings → control zones, labels, right-side tags, panel, and font sizes


🖥️ Interface & Visual Design

The interface is designed for fast chart reading.

The panel gives the current decision context. Zones show where clustered stops may sit. Labels mark key events. Right-side tags keep current levels readable without forcing the trader to inspect every candle.

The layout is intentionally clean, premium, and structured for public-chart screenshots.


🧪 Practical Usage Workflow

1. Read the panel to identify the current magnet state.

2. Check whether the upper or lower stop-cluster zone is active.

3. Watch how price behaves near the mapped cluster.

4. Evaluate whether a sweep closes back inside or continues beyond the zone.

5. Use broader market context before making any decision.


🔍 Interpretation Guidelines

A strong stop cluster does not mean price must move there.

A sweep does not automatically mean reversal.

The best interpretation comes from combining cluster quality, distance, market structure, volume behavior, volatility, and the trader's own higher-timeframe context.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an automated trading system.

It does not provide guaranteed signals.

It does not know where actual broker stop orders are placed.


⚠️ Limitations & Transparency

The script estimates stop-cluster areas using visible chart structure only.

Different timeframes may show different clusters.

High volatility can expand zones and change quality scores quickly.

Market conditions can shift, and a previously important cluster may lose relevance over time.


🧠 Market Context Notes (Optional)

Stop clusters often matter because repeated highs and lows can become obvious reference points.

When many traders see the same level, price may react around that area, sweep it, reject from it, or continue through it.

This script is designed to make that structural pressure easier to observe.


🧾 Use Case Examples (Optional)

When price approaches an upper stop cluster with a high quality score, the trader can monitor whether the market sweeps above it and closes back inside.

When lower stops cluster beneath a range, the trader can watch whether price is being pulled toward downside liquidity or rejecting before reaching it.


🧱 System Philosophy (Advanced)

The AGPro approach focuses on structured decision support, not hype.

This script turns repeated swing references into a readable liquidity map so traders can evaluate context instead of reacting to isolated candles.


🔐 Non-Promise Statement

No script can guarantee outcomes.

Stop-cluster mapping is a contextual tool, not certainty.


📉 Risk Disclosure

Trading involves risk.

Users are fully responsible for their own analysis, risk management, and trading decisions.

This script is provided for educational and analytical purposes only and does not constitute financial advice.


📚 Educational Note (Optional)

Use this tool to study how repeated highs, repeated lows, sweeps, and reactions appear across different timeframes.

The goal is to improve market observation, not to replace disciplined analysis.

## Source Code

````pine
// -------------------------------------------------
// Stop Cluster Magnet Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Stop Cluster Magnet Map identifies repeated swing-high and swing-low
// liquidity clusters, maps where clustered stops may attract price, scores
// magnet pressure, separates sweep risk and post-sweep behavior, gives a clear
// next action, and proves how often independent magnet engagements reached a
// cluster. V1.5 clarifies cluster ownership and locks structural events to
// confirmed bars without changing the core liquidity-mapping methodology.
// -------------------------------------------------

//@version=6
indicator("Stop Cluster Magnet Map [AGPro Series]",
     shorttitle = "AG Pro SCM",
     overlay = true,
     max_labels_count = 250,
     max_lines_count = 80,
     max_boxes_count = 40)

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
darkText      = color.rgb(15, 23, 42)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupLogic = "Cluster Logic"
pivotLen = input.int(5, "Swing Pivot Length", minval = 2, maxval = 30, group = groupLogic, tooltip = "Defines how many bars are used to confirm swing highs and swing lows for stop-cluster mapping.")
clusterLookback = input.int(220, "Cluster Validity Lookback", minval = 50, maxval = 800, group = groupLogic, tooltip = "Keeps a detected stop cluster active only while it remains recent enough to matter.")
minTouches = input.int(2, "Minimum Cluster Touches", minval = 2, maxval = 6, group = groupLogic, tooltip = "Minimum number of nearby swing points required before a stop area is treated as a valid cluster.")
atrLen = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupLogic, tooltip = "ATR is used to normalize cluster width, label spacing, and magnet distance across symbols.")
clusterWidthAtr = input.float(0.35, "Cluster Width ATR", minval = 0.05, maxval = 2.0, step = 0.05, group = groupLogic, tooltip = "Controls how close repeated swing highs or lows must be to form one stop cluster.")
magnetNearAtr = input.float(2.2, "Magnet Nearness ATR", minval = 0.5, maxval = 8.0, step = 0.1, group = groupLogic, tooltip = "Controls how quickly the magnet score increases as price approaches a valid stop cluster.")
reachWindowBars = input.int(20, "Magnet Reach Window", minval = 4, maxval = 120, group = groupLogic, tooltip = "Bars over which an engaged magnet is checked for whether price actually reached the cluster zone. Feeds the Magnet Hit proof.")

groupVisual = "Visual Design"
showUpperCluster = input.bool(true, "Show Upper Stop Cluster", group = groupVisual, tooltip = "Displays the upper stop-cluster zone built from repeated swing highs.")
showLowerCluster = input.bool(true, "Show Lower Stop Cluster", group = groupVisual, tooltip = "Displays the lower stop-cluster zone built from repeated swing lows.")
showMagnetRail = input.bool(true, "Show Magnet Rail", group = groupVisual, tooltip = "Displays a dotted rail around the dominant magnet reference when a cluster is active.")
showEventLabels = input.bool(true, "Show Event Labels", group = groupVisual, tooltip = "Displays compact event labels for cluster build and sweep/rejection events.")
showMagnetLabels = input.bool(false, "Show Magnet Pull Labels", group = groupVisual, tooltip = "Adds optional Magnet Above and Magnet Below labels during active attraction pressure. Disabled by default to keep lower-timeframe charts premium and uncluttered.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = groupVisual, tooltip = "Displays clean right-edge tags for current upper, lower, and magnet values.")
rightTagOffsetBars = input.int(5, "Right Tag Offset Bars", minval = 1, maxval = 40, group = groupVisual, tooltip = "Horizontal offset for right-side tags. Increase it if tags sit too close to the projected cluster zone.")
showCenteredText = input.bool(true, "Show Centered Zone Badges", group = groupVisual, tooltip = "Places a separate centered badge on each active cluster zone for premium first-glance readability.")
showBarColors = input.bool(false, "Color Bars by Magnet State", group = groupVisual, tooltip = "Optionally colors bars based on the current stop-cluster magnet state.")
projectionBars = input.int(40, "Zone Projection Bars", minval = 10, maxval = 180, group = groupVisual, tooltip = "Controls how far active cluster zones project into the future.")
zoneTransparency = input.int(88, "Zone Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = "Transparency used by stop-cluster zones.")
labelCooldown = input.int(24, "Label Cooldown Bars", minval = 1, maxval = 100, group = groupVisual, tooltip = "Prevents too many repeated labels from appearing too close together.")
maxEventLabels = input.int(8, "Maximum Event Labels", minval = 4, maxval = 80, group = groupVisual, tooltip = "Caps the number of historical event labels to preserve chart performance and visual clarity.")
labelOffsetAtr = input.float(0.75, "Label Offset ATR", minval = 0.1, maxval = 3.0, step = 0.05, group = groupVisual, tooltip = "Moves labels away from candles so they remain readable and do not feel buried in price.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisual, tooltip = "Controls the font size used by event labels, centered badges, and right-side tags.")

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = "Shows or hides the AG Pro decision panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = "Controls where the panel is displayed on the chart.")
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = "Controls the panel background and text contrast.")
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel, tooltip = "Controls panel text size.")

groupAlerts = "Alerts"
alertClusterBuild = input.bool(true, "Alert: New Cluster Build", group = groupAlerts, tooltip = "Triggers when a valid upper or lower stop cluster becomes active.")
alertSweep = input.bool(true, "Alert: Stop Sweep", group = groupAlerts, tooltip = "Triggers when price sweeps above an upper cluster or below a lower cluster and closes back inside.")
alertMagnetShift = input.bool(true, "Alert: Magnet Shift", group = groupAlerts, tooltip = "Triggers when the dominant stop-cluster magnet changes from one side to the other.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_size_from_string(string value) =>
    value == "Tiny" ? size.tiny : value == "Small" ? size.small : value == "Large" ? size.large : value == "Huge" ? size.huge : size.normal

f_panel_position(string value) =>
    switch value
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Right" => position.middle_right
        "Middle Center" => position.middle_center
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Center" => position.bottom_center
        "Bottom Left" => position.bottom_left
        => position.top_right

f_text_on(color bgColor) =>
    bright = (color.r(bgColor) * 299 + color.g(bgColor) * 587 + color.b(bgColor) * 114) / 1000
    bright >= 145 ? darkText : headerText

f_fmt(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_int(float value) =>
    na(value) ? "n/a" : str.tostring(int(math.round(value)))

f_quality(int touches, int barsAgo, float distanceAtr) =>
    touchScore = f_clamp(touches * 22.0, 0.0, 55.0)
    recencyScore = f_clamp(35.0 - barsAgo * 35.0 / clusterLookback, 0.0, 35.0)
    distanceScore = f_clamp(25.0 - distanceAtr * 10.0, 0.0, 25.0)
    f_clamp(touchScore + recencyScore + distanceScore, 0.0, 100.0)

f_state_text(string rawState) =>
    switch rawState
        "UPPER SWEEP" => "Upper Sweep"
        "LOWER SWEEP" => "Lower Sweep"
        "UPPER STOPS TAKEN" => "Upper Stops Taken"
        "LOWER STOPS TAKEN" => "Lower Stops Taken"
        "UPSIDE MAGNET" => "Upside Magnet"
        "DOWNSIDE MAGNET" => "Downside Magnet"
        "BALANCED CLUSTERS" => "Balanced Clusters"
        "UPPER CLUSTER" => "Upper Cluster"
        "LOWER CLUSTER" => "Lower Cluster"
        => "No Clear Magnet"

f_panel_bg(string theme) =>
    theme == "Light" ? color.rgb(248, 250, 252) : panelBg

f_panel_border(string theme) =>
    theme == "Light" ? color.rgb(203, 213, 225) : panelBorder

f_panel_label(string theme) =>
    theme == "Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string theme, int row) =>
    evenRow = row % 2 == 0
    theme == "Light" ? (evenRow ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)) : (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_panel_cell(table panelRef, int col, int row, string txt, color bg, color txtColor, string txtSize, alignValue) =>
    table.cell(panelRef, col, row, txt, bgcolor = bg, text_color = txtColor, text_size = f_size_from_string(txtSize), text_halign = alignValue)

f_make_event_label(array<label> store, int x, float y, string labelText, color bg, styleValue, textSize) =>
    newLabel = label.new(x, y, labelText, xloc = xloc.bar_index, style = styleValue, color = color.new(bg, 0), textcolor = f_text_on(bg), size = textSize, textalign = text.align_center)
    array.push(store, newLabel)
    while array.size(store) > maxEventLabels
        oldLabel = array.shift(store)
        if not na(oldLabel)
            label.delete(oldLabel)
    newLabel

f_set_zone_box(box bx, int leftX, int rightX, float topY, float bottomY, color bg, color border) =>
    box.set_lefttop(bx, leftX, topY)
    box.set_rightbottom(bx, rightX, bottomY)
    box.set_bgcolor(bx, bg)
    box.set_border_color(bx, border)
    box.set_border_width(bx, 1)

f_set_label(label tag, int x, float y, string labelText, color bg, styleValue, textSize) =>
    label.set_xy(tag, x, y)
    label.set_text(tag, labelText)
    label.set_color(tag, color.new(bg, 0))
    label.set_textcolor(tag, f_text_on(bg))
    label.set_style(tag, styleValue)
    label.set_size(tag, textSize)
    label.set_textalign(tag, text.align_center)

f_delete_label(label item) =>
    if not na(item)
        label.delete(item)

// -------------------------------------------------
// Core Calculations
// -------------------------------------------------
atr = math.max(nz(ta.atr(atrLen), high - low), syminfo.mintick)
zoneHalfWidth = atr * clusterWidthAtr
labelOffset = atr * labelOffsetAtr

pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)

var float upperCluster = na
var float upperTop = na
var float upperBottom = na
var int upperTouches = 0
var int upperLastBar = na
var int upperFirstBar = na
var float upperBuildCluster = na
var int upperBuildTouches = 0
var int upperBuildLastBar = na
var int upperBuildFirstBar = na

var float lowerCluster = na
var float lowerTop = na
var float lowerBottom = na
var int lowerTouches = 0
var int lowerLastBar = na
var int lowerFirstBar = na
var float lowerBuildCluster = na
var int lowerBuildTouches = 0
var int lowerBuildLastBar = na
var int lowerBuildFirstBar = na

newUpperPivot = not na(pivotHigh)
newLowerPivot = not na(pivotLow)
pivotHighBar = bar_index - pivotLen
pivotLowBar = bar_index - pivotLen
upperClusterJustBuilt = false
lowerClusterJustBuilt = false

if barstate.isconfirmed and newUpperPivot
    if na(upperBuildCluster) or math.abs(pivotHigh - upperBuildCluster) > zoneHalfWidth
        upperBuildCluster := pivotHigh
        upperBuildTouches := 1
        upperBuildFirstBar := pivotHighBar
    else
        upperBuildCluster := (upperBuildCluster * upperBuildTouches + pivotHigh) / (upperBuildTouches + 1)
        upperBuildTouches += 1
    upperBuildLastBar := pivotHighBar
    if upperBuildTouches >= minTouches
        upperCluster := upperBuildCluster
        upperTouches := upperBuildTouches
        upperFirstBar := upperBuildFirstBar
        upperLastBar := upperBuildLastBar
        upperTop := upperCluster + zoneHalfWidth
        upperBottom := upperCluster - zoneHalfWidth
        upperClusterJustBuilt := upperBuildTouches == minTouches

if barstate.isconfirmed and newLowerPivot
    if na(lowerBuildCluster) or math.abs(pivotLow - lowerBuildCluster) > zoneHalfWidth
        lowerBuildCluster := pivotLow
        lowerBuildTouches := 1
        lowerBuildFirstBar := pivotLowBar
    else
        lowerBuildCluster := (lowerBuildCluster * lowerBuildTouches + pivotLow) / (lowerBuildTouches + 1)
        lowerBuildTouches += 1
    lowerBuildLastBar := pivotLowBar
    if lowerBuildTouches >= minTouches
        lowerCluster := lowerBuildCluster
        lowerTouches := lowerBuildTouches
        lowerFirstBar := lowerBuildFirstBar
        lowerLastBar := lowerBuildLastBar
        lowerTop := lowerCluster + zoneHalfWidth
        lowerBottom := lowerCluster - zoneHalfWidth
        lowerClusterJustBuilt := lowerBuildTouches == minTouches

upperBarsAgo = na(upperLastBar) ? 100000 : bar_index - upperLastBar
lowerBarsAgo = na(lowerLastBar) ? 100000 : bar_index - lowerLastBar
upperValid = not na(upperCluster) and upperTouches >= minTouches and upperBarsAgo <= clusterLookback
lowerValid = not na(lowerCluster) and lowerTouches >= minTouches and lowerBarsAgo <= clusterLookback

upperDistanceAtr = upperValid ? math.abs(upperCluster - close) / atr : na
lowerDistanceAtr = lowerValid ? math.abs(close - lowerCluster) / atr : na
upperQuality = upperValid ? f_quality(upperTouches, upperBarsAgo, upperDistanceAtr) : na
lowerQuality = lowerValid ? f_quality(lowerTouches, lowerBarsAgo, lowerDistanceAtr) : na

upperNear = upperValid and upperDistanceAtr <= magnetNearAtr
lowerNear = lowerValid and lowerDistanceAtr <= magnetNearAtr
upperSweep = barstate.isconfirmed and upperValid and high > upperTop and close < upperCluster
lowerSweep = barstate.isconfirmed and lowerValid and low < lowerBottom and close > lowerCluster
upperBreak = barstate.isconfirmed and upperValid and close > upperTop
lowerBreak = barstate.isconfirmed and lowerValid and close < lowerBottom

dominantUpper = upperValid and (not lowerValid or nz(upperQuality, 0) >= nz(lowerQuality, 0))
dominantLower = lowerValid and (not upperValid or nz(lowerQuality, 0) > nz(upperQuality, 0))
magnetPrice = dominantUpper ? upperCluster : dominantLower ? lowerCluster : na
magnetQuality = dominantUpper ? upperQuality : dominantLower ? lowerQuality : na

string rawMagnetState = "NO CLEAR MAGNET"
stateColor = neutralColor
sweepRisk = "Not Active"
nextContext = "Wait for Cluster"

if upperSweep
    rawMagnetState := "UPPER SWEEP"
    stateColor := bearColor
    sweepRisk := "Upper Sweep"
    nextContext := "Check Rejection"
else if lowerSweep
    rawMagnetState := "LOWER SWEEP"
    stateColor := bullColor
    sweepRisk := "Lower Sweep"
    nextContext := "Check Rejection"
else if upperBreak
    rawMagnetState := "UPPER STOPS TAKEN"
    stateColor := bullColor
    sweepRisk := "Cleared Upper"
    nextContext := "Watch Continuation"
else if lowerBreak
    rawMagnetState := "LOWER STOPS TAKEN"
    stateColor := bearColor
    sweepRisk := "Cleared Lower"
    nextContext := "Watch Continuation"
else if upperNear and dominantUpper
    rawMagnetState := "UPSIDE MAGNET"
    stateColor := bearColor
    sweepRisk := "Upper Cluster Near"
    nextContext := "Watch Upper Stops"
else if lowerNear and dominantLower
    rawMagnetState := "DOWNSIDE MAGNET"
    stateColor := bullColor
    sweepRisk := "Lower Cluster Near"
    nextContext := "Watch Lower Stops"
else if upperValid and lowerValid
    rawMagnetState := "BALANCED CLUSTERS"
    stateColor := accentColor
    sweepRisk := "Two-Sided"
    nextContext := "Wait for Side"
else if upperValid
    rawMagnetState := "UPPER CLUSTER"
    stateColor := bearColor
    sweepRisk := "Upper Potential"
    nextContext := "Track Upper Magnet"
else if lowerValid
    rawMagnetState := "LOWER CLUSTER"
    stateColor := bullColor
    sweepRisk := "Lower Potential"
    nextContext := "Track Lower Magnet"

magnetState = f_state_text(rawMagnetState)
magnetScore = na(magnetQuality) ? na : f_clamp(magnetQuality + (dominantUpper and upperNear ? 8.0 : dominantLower and lowerNear ? 8.0 : 0.0), 0.0, 100.0)

// -------------------------------------------------
// Magnet reach-rate proof (Confirm Rate)
// -------------------------------------------------
magnetEngaged = (upperNear and dominantUpper) or (lowerNear and dominantLower)
engageSide = (upperNear and dominantUpper) ? 1 : (lowerNear and dominantLower) ? -1 : 0
magnetStart = barstate.isconfirmed and magnetEngaged and (not magnetEngaged[1] or engageSide != engageSide[1])

var int   mrTotal = 0
var int   mrHit   = 0
var int   mrSide  = 0
var float mrTop   = na
var float mrBot   = na
var int   mrLeft  = 0

if barstate.isconfirmed
    if mrLeft > 0
        reached = (mrSide == 1 and high >= mrBot) or (mrSide == -1 and low <= mrTop)
        if reached
            mrTotal += 1
            mrHit += 1
            mrSide := 0
            mrLeft := 0
        else if mrLeft == 1
            mrTotal += 1
            mrSide := 0
            mrLeft := 0
        else
            mrLeft -= 1
    if magnetStart and mrLeft == 0
        canStart = engageSide == 1 ? high < upperBottom : low > lowerTop
        if canStart
            mrSide := engageSide
            mrTop := engageSide == 1 ? upperTop : lowerTop
            mrBot := engageSide == 1 ? upperBottom : lowerBottom
            mrLeft := reachWindowBars

magnetReachRate = mrTotal > 0 ? mrHit / mrTotal * 100.0 : na

// -------------------------------------------------
// Event Labels
// -------------------------------------------------
labelSize = f_size_from_string(labelSizeInput)
panelSize = f_size_from_string(panelSizeInput)

var array<label> eventLabels = array.new<label>()
var int lastEventLabelBar = na
eventLabelReady = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldown

newUpperCluster = upperClusterJustBuilt and upperValid
newLowerCluster = lowerClusterJustBuilt and lowerValid
magnetPullEvent = (upperNear and dominantUpper) or (lowerNear and dominantLower)

if showEventLabels and eventLabelReady and barstate.isconfirmed
    if upperSweep
        f_make_event_label(eventLabels, bar_index, high + labelOffset, "Upper Sweep\nQ " + f_int(upperQuality), bearColor, label.style_label_down, labelSize)
        lastEventLabelBar := bar_index
    else if lowerSweep
        f_make_event_label(eventLabels, bar_index, low - labelOffset, "Lower Sweep\nQ " + f_int(lowerQuality), bullColor, label.style_label_up, labelSize)
        lastEventLabelBar := bar_index
    else if newUpperCluster
        f_make_event_label(eventLabels, pivotHighBar, pivotHigh + labelOffset, "Upper Stops\nQ " + f_int(upperQuality), bearColor, label.style_label_down, labelSize)
        lastEventLabelBar := bar_index
    else if newLowerCluster
        f_make_event_label(eventLabels, pivotLowBar, pivotLow - labelOffset, "Lower Stops\nQ " + f_int(lowerQuality), bullColor, label.style_label_up, labelSize)
        lastEventLabelBar := bar_index
    else if showMagnetLabels and magnetPullEvent
        magnetText = dominantUpper ? "Magnet Above\nQ " + f_int(magnetScore) : "Magnet Below\nQ " + f_int(magnetScore)
        magnetY = dominantUpper ? high + labelOffset : low - labelOffset
        magnetStyle = dominantUpper ? label.style_label_down : label.style_label_up
        f_make_event_label(eventLabels, bar_index, magnetY, magnetText, accentColor, magnetStyle, labelSize)
        lastEventLabelBar := bar_index

// -------------------------------------------------
// Visual Objects
// -------------------------------------------------
var box upperBox = na
var box lowerBox = na
var line magnetRail = na
var label upperTag = na
var label lowerTag = na
var label magnetTag = na
var label upperCenter = na
var label lowerCenter = na

rightX = bar_index + projectionBars
tagX = rightX + rightTagOffsetBars
leftUpperX = na(upperFirstBar) ? bar_index : math.max(upperFirstBar, bar_index - clusterLookback)
leftLowerX = na(lowerFirstBar) ? bar_index : math.max(lowerFirstBar, bar_index - clusterLookback)
midUpperX = int(math.round((leftUpperX + rightX) / 2.0))
midLowerX = int(math.round((leftLowerX + rightX) / 2.0))

if upperValid and showUpperCluster
    if na(upperBox)
        upperBox := box.new(leftUpperX, upperTop, rightX, upperBottom, xloc = xloc.bar_index, bgcolor = color.new(bearColor, zoneTransparency), border_color = color.new(bearColor, 28), border_width = 1)
    else
        f_set_zone_box(upperBox, leftUpperX, rightX, upperTop, upperBottom, color.new(bearColor, zoneTransparency), color.new(bearColor, 28))
    if showRightTags
        if na(upperTag)
            upperTag := label.new(tagX, upperCluster, "", xloc = xloc.bar_index, style = label.style_label_left, color = bearColor, textcolor = f_text_on(bearColor), size = labelSize)
        upperTagText = "UPPER " + f_fmt(upperCluster) + (dominantUpper ? " | M" + f_int(magnetScore) : "")
        f_set_label(upperTag, tagX, upperCluster, upperTagText, bearColor, label.style_label_left, labelSize)
    if showCenteredText
        if na(upperCenter)
            upperCenter := label.new(midUpperX, upperCluster, "", xloc = xloc.bar_index, style = label.style_label_center, color = bearColor, textcolor = f_text_on(bearColor), size = labelSize)
        f_set_label(upperCenter, midUpperX, upperCluster, "Upper Stops\nQ " + f_int(upperQuality), bearColor, label.style_label_center, labelSize)
else
    if not na(upperBox)
        box.delete(upperBox)
        upperBox := na
    f_delete_label(upperTag)
    f_delete_label(upperCenter)
    upperTag := na
    upperCenter := na

if lowerValid and showLowerCluster
    if na(lowerBox)
        lowerBox := box.new(leftLowerX, lowerTop, rightX, lowerBottom, xloc = xloc.bar_index, bgcolor = color.new(bullColor, zoneTransparency), border_color = color.new(bullColor, 28), border_width = 1)
    else
        f_set_zone_box(lowerBox, leftLowerX, rightX, lowerTop, lowerBottom, color.new(bullColor, zoneTransparency), color.new(bullColor, 28))
    if showRightTags
        if na(lowerTag)
            lowerTag := label.new(tagX, lowerCluster, "", xloc = xloc.bar_index, style = label.style_label_left, color = bullColor, textcolor = f_text_on(bullColor), size = labelSize)
        lowerTagText = "LOWER " + f_fmt(lowerCluster) + (dominantLower ? " | M" + f_int(magnetScore) : "")
        f_set_label(lowerTag, tagX, lowerCluster, lowerTagText, bullColor, label.style_label_left, labelSize)
    if showCenteredText
        if na(lowerCenter)
            lowerCenter := label.new(midLowerX, lowerCluster, "", xloc = xloc.bar_index, style = label.style_label_center, color = bullColor, textcolor = f_text_on(bullColor), size = labelSize)
        f_set_label(lowerCenter, midLowerX, lowerCluster, "Lower Stops\nQ " + f_int(lowerQuality), bullColor, label.style_label_center, labelSize)
else
    if not na(lowerBox)
        box.delete(lowerBox)
        lowerBox := na
    f_delete_label(lowerTag)
    f_delete_label(lowerCenter)
    lowerTag := na
    lowerCenter := na

if showMagnetRail and not na(magnetPrice)
    if na(magnetRail)
        magnetRail := line.new(math.max(bar_index - 80, 0), magnetPrice, rightX, magnetPrice, xloc = xloc.bar_index, color = accentColor, style = line.style_dotted, width = 2)
    else
        line.set_xy1(magnetRail, math.max(bar_index - 80, 0), magnetPrice)
        line.set_xy2(magnetRail, rightX, magnetPrice)
        line.set_color(magnetRail, accentColor)
        line.set_width(magnetRail, 2)
        line.set_style(magnetRail, line.style_dotted)
    f_delete_label(magnetTag)
    magnetTag := na
else
    if not na(magnetRail)
        line.delete(magnetRail)
        magnetRail := na
    f_delete_label(magnetTag)
    magnetTag := na

barCol = rawMagnetState == "UPPER SWEEP" or rawMagnetState == "UPSIDE MAGNET" ? color.new(bearColor, 55) : rawMagnetState == "LOWER SWEEP" or rawMagnetState == "DOWNSIDE MAGNET" ? color.new(bullColor, 55) : na
barcolor(showBarColors ? barCol : na)

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelBgActive = f_panel_bg(panelThemeInput)
panelBorderActive = f_panel_border(panelThemeInput)
panelLabelActive = f_panel_label(panelThemeInput)
panelValueActive = f_panel_value(panelThemeInput)
stateBg = color.new(stateColor, panelThemeInput == "Light" ? 76 : 20)
scoreBg = color.new(stateColor, panelThemeInput == "Light" ? 82 : 28)

magnetHitText = mrTotal > 0 ? f_int(magnetReachRate) + "% (" + str.tostring(mrTotal) + ")" : "Building"
magnetHitColor = na(magnetReachRate) ? panelValueActive : magnetReachRate >= 55.0 ? bullColor : magnetReachRate >= 45.0 ? neutralColor : bearColor
upperPanelText = upperValid ? f_fmt(upperCluster) + " | Q " + f_int(upperQuality) : "Inactive"
lowerPanelText = lowerValid ? f_fmt(lowerCluster) + " | Q " + f_int(lowerQuality) : "Inactive"

var table panel = table.new(position.top_right, 2, 8, bgcolor = panelBg, frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)

if barstate.islast
    table.set_position(panel, f_panel_position(panelPositionInput))
    table.set_frame_color(panel, panelBorderActive)
    table.set_border_color(panel, panelBorderActive)
    if showPanel
        table.clear(panel, 0, 0, 1, 7)
        table.merge_cells(panel, 0, 0, 1, 0)
        f_panel_cell(panel, 0, 0, "AG Pro Stop Cluster Magnet Map", headerBg, headerText, panelSizeInput, text.align_center)
        f_panel_cell(panel, 0, 1, "Next Action", f_row_bg(panelThemeInput, 1), panelLabelActive, panelSizeInput, text.align_left)
        f_panel_cell(panel, 1, 1, nextContext, f_row_bg(panelThemeInput, 1), stateColor, panelSizeInput, text.align_right)
        f_panel_cell(panel, 0, 2, "Magnet State", f_row_bg(panelThemeInput, 2), panelLabelActive, panelSizeInput, text.align_left)
        f_panel_cell(panel, 1, 2, magnetState, stateBg, f_text_on(stateBg), panelSizeInput, text.align_right)
        f_panel_cell(panel, 0, 3, "Magnet Score", f_row_bg(panelThemeInput, 3), panelLabelActive, panelSizeInput, text.align_left)
        f_panel_cell(panel, 1, 3, f_int(magnetScore), scoreBg, f_text_on(scoreBg), panelSizeInput, text.align_right)
        f_panel_cell(panel, 0, 4, "Upper Cluster", f_row_bg(panelThemeInput, 4), panelLabelActive, panelSizeInput, text.align_left)
        f_panel_cell(panel, 1, 4, upperPanelText, f_row_bg(panelThemeInput, 4), panelValueActive, panelSizeInput, text.align_right)
        f_panel_cell(panel, 0, 5, "Lower Cluster", f_row_bg(panelThemeInput, 5), panelLabelActive, panelSizeInput, text.align_left)
        f_panel_cell(panel, 1, 5, lowerPanelText, f_row_bg(panelThemeInput, 5), panelValueActive, panelSizeInput, text.align_right)
        f_panel_cell(panel, 0, 6, "Sweep Risk", f_row_bg(panelThemeInput, 6), panelLabelActive, panelSizeInput, text.align_left)
        f_panel_cell(panel, 1, 6, sweepRisk, f_row_bg(panelThemeInput, 6), stateColor, panelSizeInput, text.align_right)
        f_panel_cell(panel, 0, 7, "Magnet Hit", f_row_bg(panelThemeInput, 7), panelLabelActive, panelSizeInput, text.align_left)
        f_panel_cell(panel, 1, 7, magnetHitText, f_row_bg(panelThemeInput, 7), magnetHitColor, panelSizeInput, text.align_right)
    else
        table.clear(panel, 0, 0, 1, 7)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
magnetSide = dominantUpper ? 1 : dominantLower ? -1 : 0
magnetShift = magnetSide != magnetSide[1] and magnetSide != 0

alertcondition(barstate.isconfirmed and alertClusterBuild and newUpperCluster, "Upper Stop Cluster Built", "Stop Cluster Magnet Map: a valid upper stop cluster has formed.")
alertcondition(barstate.isconfirmed and alertClusterBuild and newLowerCluster, "Lower Stop Cluster Built", "Stop Cluster Magnet Map: a valid lower stop cluster has formed.")
alertcondition(barstate.isconfirmed and alertSweep and upperSweep, "Upper Stop Sweep", "Stop Cluster Magnet Map: price swept the upper stop cluster and closed back inside.")
alertcondition(barstate.isconfirmed and alertSweep and lowerSweep, "Lower Stop Sweep", "Stop Cluster Magnet Map: price swept the lower stop cluster and closed back inside.")
alertcondition(barstate.isconfirmed and alertMagnetShift and magnetShift, "Stop-Cluster Magnet Shift", "Stop Cluster Magnet Map: the dominant stop-cluster magnet side has changed.")

// Hidden reference plots
plot(magnetScore, "Magnet Score", display = display.none)
plot(magnetReachRate, "Magnet Reach Rate", display = display.none)
plot(upperValid ? upperCluster : na, "Upper Stop Cluster", display = display.none)
plot(lowerValid ? lowerCluster : na, "Lower Stop Cluster", display = display.none)
````

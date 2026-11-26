# Anchored VWAP Risk Ladder [AGPro Series]

- url: https://www.tradingview.com/script/PhAcbjoy-Anchored-VWAP-Risk-Ladder-AGPro-Series/
- type: indicator
- pine_id: PUB;03860dabce9f425bbae1b98a95edf244
- version: 4.0

## Description

Anchored VWAP Risk Ladder [AGPro Series]

🧠 Core Idea

After an important market event, is price trading close to fair value or becoming extended relative to the anchored VWAP?


📌 Overview / What it does

Anchored VWAP Risk Ladder [AGPro Series] builds a volume-weighted average price from a selected anchor event and turns the distance from that anchor into a structured risk ladder.

The script displays anchored VWAP, volume-weighted deviation bands, right-side ladder tags, reclaim and lose labels, extension context, and a compact AG Pro panel with distance, score, risk ladder, and action state.

It does not predict price direction, automate trades, or claim that anchored VWAP will hold as support or resistance. It organizes event-based volume-weighted context into a readable chart framework.


🎯 Purpose & Design Philosophy

Anchored VWAP is often useful after a meaningful event, but raw AVWAP alone can be difficult to interpret without context.

This script was built to answer a practical question: how far is price from the anchored value area, and is that distance becoming useful, balanced, or risky?

The design supports traders who think in terms of anchored fair value, risk distance, reclaim behavior, and extension zones.


⚡ Why This Script Is Different

Most VWAP tools show a line and leave interpretation fully manual.

This script does NOT stop at plotting anchored VWAP.

Instead, it builds a complete risk ladder around the anchor, adds deviation context, scores reclaim or lose behavior, and summarizes the current state in a clean dashboard.


⚙️ Methodology

1. Anchor Detection

The script can anchor from manual time, high-volume events, swing pivots, session open, week open, or month open.

2. AVWAP Calculation

From the active anchor, the script accumulates volume-weighted price and volume-weighted variance to calculate anchored VWAP and deviation bands.

3. Risk Ladder Mapping

Distance from anchored VWAP is measured in ATR and deviation terms to classify whether price is near value, inside Band 1, inside Band 2, or extended.

4. Visual Output

The script plots AVWAP, upper/lower deviation bands, ladder fills, event labels, right-side tags, bar state color, and a dashboard.


🗺️ How to Read the Chart

The AVWAP rail represents the volume-weighted average price from the active anchor.

Deviation bands represent the ladder around anchored value.

Labels mark anchor events, AVWAP reclaim events, AVWAP lose events, and optional extension-risk conditions.

The panel shows:
• Anchor → current anchor type and age
• Distance → price distance from AVWAP in ATR
• Risk Ladder → current ladder zone and risk score
• Score → current context score and direction state
• Action → READY / MONITOR / WAIT / BLOCKED


🚦 Signals & States

• Anchor Locked → a new event anchor has been selected

• Ready Reclaim → price has reclaimed anchored VWAP with enough context score

• Ready Lose → price has lost anchored VWAP with enough context score

• Near AVWAP → price is close to anchored value

• Band 1 / Band 2 → price is moving away from anchored value

• Extended → distance from AVWAP is elevated


🔔 Alerts Logic

Alerts can trigger when a new anchor is locked, when price reclaims AVWAP, when price loses AVWAP, or when extension-risk conditions appear.

Alerts are attention markers only. They do not represent trade instructions or guaranteed outcomes.


🧩 Confluence Logic

The context becomes stronger when anchored VWAP reclaim or lose behavior aligns with relative volume, acceptable distance, and a clear ladder state.

The risk ladder helps separate balanced conditions from extension conditions.


📊 When to Use

• After high-volume market events

• Around earnings, news, breakout, or liquidation-style candles

• During trend continuation pullbacks

• When studying institutional average price context

• On liquid symbols with meaningful volume data


⚠️ When NOT to Use

• Very low-liquidity symbols

• Markets with unreliable or synthetic volume

• Extremely choppy conditions where anchors reset too often

• Situations where the selected anchor is not meaningful

• When using AVWAP as a standalone trading signal


🎛️ Key Inputs

• Anchor Mode → controls how AVWAP is anchored

• Manual Anchor Time → user-defined anchor timestamp

• High Volume Anchor Threshold → controls automatic high-volume anchors

• Deviation Band 1 / 2 → controls ladder width

• Extension Risk ATR → controls when distance becomes elevated

• Minimum Ready Score → controls reclaim or lose strictness

• Visual Settings → control bands, labels, tags, panel, and bar colors


🖥️ Interface & Visual Design

The interface is built for fast visual hierarchy.

AVWAP is the central reference, deviation bands define the risk ladder, right-side tags make the ladder readable, and the panel summarizes state without forcing the user to inspect every line manually.


🧪 Practical Usage Workflow

1. Choose the anchor mode

2. Read the active anchor and distance in the panel

3. Check whether price is near AVWAP or extended

4. Watch reclaim or lose labels around AVWAP

5. Use broader structure and risk context before making any decision


🔍 Interpretation Guidelines

Price near AVWAP often represents a balanced value area relative to the anchor.

Price far from AVWAP may represent stronger trend behavior, but it may also carry extension risk.

READY states mark meaningful reclaim or lose behavior, not certainty.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not an automated trading system.

It does not guarantee support, resistance, continuation, reversal, or profit.

It is not financial advice.


⚠️ Limitations & Transparency

Anchored VWAP quality depends heavily on anchor selection.

Different timeframes may produce different anchor timing and visual structure.

Volume data quality may vary between symbols, brokers, and exchanges.

Deviation bands are statistical references, not fixed market boundaries.


🧠 Market Context Notes

Anchored VWAP works best when the anchor represents a meaningful market event.

High-volume displacement, swing pivots, session opens, weekly opens, and monthly opens may each tell a different story.

The user should choose the anchor mode that best fits the market question.


🧾 Use Case Examples

When a high-volume candle creates a new anchor, the script tracks whether price remains near the anchored value area or begins to extend away from it.

When price reclaims AVWAP with enough score, the script marks a READY reclaim context.

When price loses AVWAP with enough score, the script marks a READY lose context.


🧱 System Philosophy

AGPro Series tools are built as decision-support engines.

The purpose is to structure market context into readable zones, states, scores, and risk references without turning analysis into blind signal-following.


🔐 Non-Promise Statement

No script can provide certainty.

No AVWAP level guarantees a reaction.

No signal guarantees continuation, reversal, or profit.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own analysis, decisions, risk management, and execution.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

Use this tool to study how anchored value, volume-weighted distance, deviation bands, reclaim behavior, and extension risk interact across different market conditions.

## Source Code

````pine
// -------------------------------------------------
// Anchored VWAP Risk Ladder [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Anchored VWAP Risk Ladder builds an event-based VWAP from a selected anchor
// and converts distance from that anchor into a structured risk ladder. It maps
// AVWAP, deviation bands, reclaim/lose labels, extension context, and a 0-100
// risk/readiness panel for volume-weighted support and resistance analysis.
// Version 1.4 prioritizes extension risk, clarifies reclaim/loss semantics, and
// gives every staggered ladder badge a connector to its exact source price.
// -------------------------------------------------

//@version=6
indicator("Anchored VWAP Risk Ladder [AGPro Series]",
     shorttitle = "AG Pro AVR",
     overlay = true,
     max_lines_count = 180,
     max_labels_count = 180,
     max_boxes_count = 60)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
G_ANCHOR = "Anchor Engine"
G_LADDER = "Risk Ladder"
G_VISUAL = "Visuals"
G_PANEL = "Panel"
G_ALERTS = "Alerts"

anchorMode = input.string("High Volume Event", "Anchor Mode",
     options = ["Manual Time", "High Volume Event", "Swing Pivot", "Session Open", "Week Open", "Month Open"],
     group = G_ANCHOR,
     tooltip = "Selects how the anchored VWAP resets. High Volume Event anchors to unusually active participation, while Manual Time allows a user-defined event anchor.")
manualAnchorTime = input.time(1767225600000, "Manual Anchor Time", group = G_ANCHOR,
     tooltip = "Manual anchor timestamp. Used only when Anchor Mode is Manual Time.")
src = input.source(hlc3, "AVWAP Source", group = G_ANCHOR,
     tooltip = "Price source used for the anchored VWAP calculation.")
volumeLength = input.int(30, "Relative Volume Length", minval = 5, maxval = 300, group = G_ANCHOR,
     tooltip = "Lookback used to identify high-volume anchor events and participation quality.")
anchorVolumeThreshold = input.float(1.80, "High Volume Anchor Threshold", minval = 0.50, step = 0.05, group = G_ANCHOR,
     tooltip = "Relative volume threshold required to create a new High Volume Event anchor.")
pivotLength = input.int(5, "Swing Pivot Length", minval = 2, maxval = 30, group = G_ANCHOR,
     tooltip = "Pivot length used when Anchor Mode is Swing Pivot. The anchor resets when a confirmed swing event appears.")
minAnchorSpacing = input.int(36, "Minimum Anchor Spacing", minval = 1, maxval = 500, group = G_ANCHOR,
     tooltip = "Minimum bars between automatic anchors. This prevents frequent anchor resets.")

atrLength = input.int(14, "ATR Length", minval = 1, maxval = 300, group = G_LADDER,
     tooltip = "ATR length used for risk normalization, labels, invalidation shelves, and extension scoring.")
devOne = input.float(1.0, "Deviation Band 1", minval = 0.10, step = 0.10, group = G_LADDER,
     tooltip = "First standard-deviation ladder around anchored VWAP.")
devTwo = input.float(2.0, "Deviation Band 2", minval = 0.20, step = 0.10, group = G_LADDER,
     tooltip = "Second standard-deviation ladder around anchored VWAP.")
reclaimBufferAtr = input.float(0.04, "Reclaim Buffer ATR", minval = 0.0, step = 0.01, group = G_LADDER,
     tooltip = "Small ATR buffer around anchored VWAP to reduce borderline reclaim and lose signals.")
extensionRiskAtr = input.float(1.65, "Extension Risk ATR", minval = 0.20, step = 0.05, group = G_LADDER,
     tooltip = "Distance from AVWAP, measured in ATR, where extension risk starts to matter.")
minReadyScore = input.int(62, "Minimum Ready Score", minval = 1, maxval = 100, group = G_LADDER,
     tooltip = "Minimum score required before reclaim or lose conditions receive a READY label.")
activeWindowBars = input.int(120, "Active Context Window", minval = 10, maxval = 800, group = G_LADDER,
     tooltip = "Number of bars after a reclaim or lose event where the context remains active.")

showAVWAP = input.bool(true, "Show Anchored VWAP", group = G_VISUAL,
     tooltip = "Shows the active anchored VWAP rail.")
showDeviationBands = input.bool(true, "Show Deviation Bands", group = G_VISUAL,
     tooltip = "Shows volume-weighted deviation bands around anchored VWAP.")
showRiskLadderFill = input.bool(true, "Show Ladder Fill", group = G_VISUAL,
     tooltip = "Fills the risk ladder between deviation bands for faster visual reading.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows anchor, reclaim, lose, and extension labels.")
showAnchorLabels = input.bool(true, "Show Anchor Labels", group = G_VISUAL,
     tooltip = "Shows labels when a new anchor is locked.")
showExtensionLabels = input.bool(false, "Show Extension Risk Labels", group = G_VISUAL,
     tooltip = "Shows extension risk labels. Disabled by default to keep screenshots clean.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows compact right-side tags for AVWAP and deviation ladder levels.")
rightTagLaneAtr = input.float(0.18, "Right Tag Lane Spacing ATR", minval = 0.00, maxval = 1.00, step = 0.01, group = G_VISUAL,
     tooltip = "Adds small ATR-based spacing between right-side tags so AVWAP and deviation labels stay readable when bands are close together.")
showBarColors = input.bool(false, "Color Bars By State", group = G_VISUAL,
     tooltip = "Colors bars lightly according to the current AVWAP state.")
rightTagOffsetBars = input.int(18, "Right Tag Offset Bars", minval = 2, maxval = 120, group = G_VISUAL,
     tooltip = "Horizontal distance used for right-side ladder tags. Lower values keep tags closer to current price action.")
maxEventLabels = input.int(7, "Maximum Event Labels", minval = 2, maxval = 30, group = G_VISUAL,
     tooltip = "Maximum historical event labels retained on the chart.")
minEventLabelScore = input.int(72, "Minimum Event Label Score", minval = 1, maxval = 100, group = G_VISUAL,
     tooltip = "Minimum quality score required for historical reclaim and loss badges. Alerts and the readiness engine continue to use Minimum Ready Score.")
labelCooldownBars = input.int(20, "Label Cooldown Bars", minval = 1, maxval = 80, group = G_VISUAL,
     tooltip = "Minimum spacing between repeated labels.")
labelOffsetAtr = input.float(0.45, "Label Offset ATR", minval = 0.05, step = 0.05, group = G_VISUAL,
     tooltip = "ATR-based label offset so labels are not buried inside candles.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Controls label and right-tag font size.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro dashboard panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = G_PANEL,
     tooltip = "Controls dashboard location.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Slate"], group = G_PANEL,
     tooltip = "Controls dashboard theme.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Controls dashboard font size.")

alertAnchor = input.bool(true, "Alert: New Anchor", group = G_ALERTS,
     tooltip = "Enables alerts when a new anchor event is locked.")
alertReclaim = input.bool(true, "Alert: AVWAP Reclaim", group = G_ALERTS,
     tooltip = "Enables alerts when price reclaims anchored VWAP with sufficient score.")
alertLose = input.bool(true, "Alert: AVWAP Lost", group = G_ALERTS,
     tooltip = "Enables alerts when price loses anchored VWAP with sufficient score.")
alertExtension = input.bool(false, "Alert: Extension Risk", group = G_ALERTS,
     tooltip = "Enables alerts when price reaches extension risk distance from anchored VWAP.")

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBg = color.rgb(15, 23, 42)
panelBorder = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_text_on(color bgColor) =>
    float lum = (color.r(bgColor) * 299 + color.g(bgColor) * 587 + color.b(bgColor) * 114) / 1000
    lum >= 145 ? color.rgb(17, 24, 39) : headerText

f_reg(float x, float y, float[] bars, float[] ys) =>
    array.push(bars, x)
    array.push(ys, y)
    if array.size(bars) > 16
        array.shift(bars)
        array.shift(ys)

f_resolve_y(float x, float yBase, float dir, float sep, float[] bars, float[] ys) =>
    float y = yBase
    bool clash = true
    int g = 0
    while clash and g < 14
        clash := false
        if array.size(bars) > 0
            for i = 0 to array.size(bars) - 1
                if math.abs(x - array.get(bars, i)) <= 40 and math.abs(y - array.get(ys, i)) < sep
                    y := y + dir * sep
                    clash := true
        g += 1
    f_reg(x, y, bars, ys)
    y

f_score(float value) =>
    int(math.round(f_clamp(value, 0.0, 100.0)))

f_grade(int score) =>
    score >= 85 ? "A+" : score >= 75 ? "A" : score >= 65 ? "B" : score >= 50 ? "C" : "D"

f_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_position(string posInput) =>
    switch posInput
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_price(float value) =>
    str.tostring(value, format.mintick)

f_pct(float value) =>
    str.tostring(math.round(value)) + "%"

// -------------------------------------------------
// Anchor detection
// -------------------------------------------------
atrRaw = ta.atr(atrLength)
atr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
volAvg = ta.sma(volume, volumeLength)
rvol = volAvg > 0.0 ? volume / volAvg : 1.0
pivotHigh = ta.pivothigh(high, pivotLength, pivotLength)
pivotLow = ta.pivotlow(low, pivotLength, pivotLength)

var int anchorBar = na
var string anchorName = "No Anchor"
var float cumPV = na
var float cumVol = na
var float cumPV2 = na
var int lastSignalBar = na
var int lastAnchorBar = na
var int lastLabelBar = na
var int activeDir = 0
var int activeSignalBar = na

manualReset = anchorMode == "Manual Time" and time >= manualAnchorTime and (na(time[1]) or time[1] < manualAnchorTime)
sessionReset = anchorMode == "Session Open" and ta.change(time("D")) != 0
weekReset = anchorMode == "Week Open" and ta.change(time("W")) != 0
monthReset = anchorMode == "Month Open" and ta.change(time("M")) != 0
autoSpacingOk = na(lastAnchorBar) or bar_index - lastAnchorBar >= minAnchorSpacing
highVolumeReset = anchorMode == "High Volume Event" and autoSpacingOk and rvol >= anchorVolumeThreshold and math.abs(close - open) > atr * 0.35
swingReset = anchorMode == "Swing Pivot" and autoSpacingOk and (not na(pivotHigh) or not na(pivotLow))
firstBarReset = na(anchorBar) and barstate.isconfirmed
newAnchor = firstBarReset or manualReset or sessionReset or weekReset or monthReset or highVolumeReset or swingReset

if newAnchor
    anchorBar := bar_index
    lastAnchorBar := bar_index
    anchorName := firstBarReset ? "Initial Anchor" :
         manualReset ? "Manual Anchor" :
         sessionReset ? "Session Anchor" :
         weekReset ? "Weekly Anchor" :
         monthReset ? "Monthly Anchor" :
         highVolumeReset ? "High Volume Anchor" :
         not na(pivotHigh) ? "Swing High Anchor" : "Swing Low Anchor"
    cumPV := 0.0
    cumVol := 0.0
    cumPV2 := 0.0
    activeDir := 0
    activeSignalBar := na

cumPV := nz(cumPV) + src * volume
cumVol := nz(cumVol) + volume
cumPV2 := nz(cumPV2) + src * src * volume

avwap = cumVol > 0.0 ? cumPV / cumVol : na
variance = cumVol > 0.0 ? math.max(cumPV2 / cumVol - avwap * avwap, 0.0) : na
dev = not na(variance) ? math.sqrt(variance) : na
upperOne = avwap + dev * devOne
lowerOne = avwap - dev * devOne
upperTwo = avwap + dev * devTwo
lowerTwo = avwap - dev * devTwo

distanceAtr = not na(avwap) and atr > 0.0 ? (close - avwap) / atr : na
absDistanceAtr = math.abs(nz(distanceAtr))
distanceDev = not na(dev) and dev > syminfo.mintick ? (close - avwap) / dev : na
absDistanceDev = math.abs(nz(distanceDev))
barsFromAnchor = not na(anchorBar) ? bar_index - anchorBar : na

reclaimBuffer = atr * reclaimBufferAtr
bullReclaim = not na(avwap) and ta.crossover(close, avwap + reclaimBuffer)
bearLose = not na(avwap) and ta.crossunder(close, avwap - reclaimBuffer)
extensionRisk = not na(distanceAtr) and absDistanceAtr >= extensionRiskAtr

scoreRaw = not na(avwap) ? 35.0 + f_clamp((1.0 - math.min(absDistanceAtr, extensionRiskAtr) / math.max(extensionRiskAtr, 0.1)) * 25.0, 0.0, 25.0) + f_clamp(rvol * 14.0, 0.0, 22.0) + f_clamp(math.min(float(nz(barsFromAnchor)), 120.0) / 120.0 * 18.0, 0.0, 18.0) : na
score = not na(scoreRaw) ? f_score(scoreRaw) : na
readySignal = (bullReclaim or bearLose) and score >= minReadyScore

if readySignal
    activeDir := bullReclaim ? 1 : -1
    activeSignalBar := bar_index
    lastSignalBar := bar_index

activeContext = not na(activeSignalBar) and bar_index - activeSignalBar <= activeWindowBars
riskScore = not na(distanceAtr) ? f_score(absDistanceAtr / math.max(extensionRiskAtr, 0.1) * 100.0) : na
ladderState = not na(avwap) ? absDistanceDev < 0.75 ? "Near AVWAP" : absDistanceDev < devOne ? "Band 1" : absDistanceDev < devTwo ? "Band 2" : "Extended" : "n/a"
anchorText = not na(anchorBar) ? anchorName + "  " + str.tostring(barsFromAnchor) + " bars" : "No Anchor"
distanceText = not na(distanceAtr) ? str.tostring(distanceAtr, "#.##") + " ATR" : "n/a"
riskText = not na(riskScore) ? str.tostring(riskScore) + "/100" : "n/a"
scoreText = not na(score) ? str.tostring(score) + "/100  " + f_grade(score) : "n/a"
actionState = extensionRisk ? "MONITOR RISK" : readySignal ? "READY" : activeContext ? "TRACK" : not na(avwap) ? "WAIT" : "BLOCKED"
directionState = activeContext ? activeDir == 1 ? "Bull Reclaim" : "Bear Loss" : close >= avwap ? "Above AVWAP" : "Below AVWAP"

// -------------------------------------------------
// Reclaim / lose follow-through proof (stop-aware)
// -------------------------------------------------
// After a READY reclaim or lose, did price travel one ATR in the signal
// direction before closing back through anchored VWAP? Win = one ATR first,
// Loss = AVWAP retaken first, neither inside the window = uncounted.
var int   pfTotal  = 0
var int   pfWins   = 0
var bool  pfOpen   = false
var int   pfDir    = 0
var float pfWinLvl = na
var int   pfBar    = na
int pfWindow = 30

if barstate.isconfirmed
    if pfOpen
        bool pfLost = pfDir == 1 ? close < avwap - reclaimBuffer : close > avwap + reclaimBuffer
        bool pfWin  = pfDir == 1 ? high >= pfWinLvl : low <= pfWinLvl
        if pfLost
            pfTotal += 1
            pfOpen  := false
        else if pfWin
            pfTotal += 1
            pfWins  += 1
            pfOpen  := false
        else if not na(pfBar) and bar_index - pfBar > pfWindow
            pfOpen := false
    if readySignal and not pfOpen
        pfOpen   := true
        pfDir    := activeDir
        pfWinLvl := activeDir == 1 ? close + atr : close - atr
        pfBar    := bar_index

float pfRate = pfTotal > 0 ? pfWins / pfTotal * 100.0 : na
holdRateText = pfTotal >= 6 ? str.tostring(math.round(pfRate)) + "%  (" + str.tostring(pfTotal) + ")" : "Building (" + str.tostring(pfTotal) + ")"

// -------------------------------------------------
// Plots and fills
// -------------------------------------------------
pAvwap = plot(showAVWAP ? avwap : na, "Anchored VWAP", color = color.new(accentColor, 0), linewidth = 2)
pUpperOne = plot(showDeviationBands ? upperOne : na, "Upper Band 1", color = color.new(bullColor, 36), linewidth = 1)
pLowerOne = plot(showDeviationBands ? lowerOne : na, "Lower Band 1", color = color.new(bearColor, 36), linewidth = 1)
pUpperTwo = plot(showDeviationBands ? upperTwo : na, "Upper Band 2", color = color.new(bullColor, 62), linewidth = 1)
pLowerTwo = plot(showDeviationBands ? lowerTwo : na, "Lower Band 2", color = color.new(bearColor, 62), linewidth = 1)
fill(pAvwap, pUpperOne, color = showRiskLadderFill ? color.new(bullColor, 93) : na)
fill(pAvwap, pLowerOne, color = showRiskLadderFill ? color.new(bearColor, 93) : na)
fill(pUpperOne, pUpperTwo, color = showRiskLadderFill ? color.new(bullColor, 96) : na)
fill(pLowerOne, pLowerTwo, color = showRiskLadderFill ? color.new(bearColor, 96) : na)

// -------------------------------------------------
// Labels
// -------------------------------------------------
labelSize = f_size(labelSizeInput)
labelOffset = atr * labelOffsetAtr
canLabel = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars
var array<label> eventLabels = array.new<label>()
var float[] lblBars = array.new_float()
var float[] lblYs = array.new_float()

f_push_label(label newLabel) =>
    array.push(eventLabels, newLabel)
    if array.size(eventLabels) > maxEventLabels
        label oldLabel = array.shift(eventLabels)
        label.delete(oldLabel)

if showEventLabels and showAnchorLabels and canLabel and newAnchor and not firstBarReset
    float anchorY = f_resolve_y(bar_index, high + labelOffset, 1.0, atr * 1.85, lblBars, lblYs)
    label newLabel = label.new(bar_index, anchorY, anchorName, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = accentColor, textcolor = f_text_on(accentColor), size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and canLabel and readySignal and score >= minEventLabelScore
    bool bullEvent = activeDir == 1
    float readyY = f_resolve_y(bar_index, bullEvent ? low - labelOffset : high + labelOffset, bullEvent ? -1.0 : 1.0, atr * 1.85, lblBars, lblYs)
    label newLabel = label.new(bar_index, readyY, bullEvent ? "BULL RECLAIM | Q " + str.tostring(score) : "BEAR LOSS | Q " + str.tostring(score), xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_up : label.style_label_down, color = bullEvent ? bullColor : bearColor, textcolor = f_text_on(bullEvent ? bullColor : bearColor), size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and showExtensionLabels and canLabel and extensionRisk and not readySignal
    bool above = close > avwap
    float extY = f_resolve_y(bar_index, above ? high + labelOffset : low - labelOffset, above ? 1.0 : -1.0, atr * 1.85, lblBars, lblYs)
    label newLabel = label.new(bar_index, extY, "EXTENSION RISK | " + str.tostring(absDistanceAtr, "#.##") + " ATR", xloc = xloc.bar_index, yloc = yloc.price, style = above ? label.style_label_down : label.style_label_up, color = neutralColor, textcolor = f_text_on(neutralColor), size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

// -------------------------------------------------
// Right-side tags
// -------------------------------------------------
rightEdge = bar_index + rightTagOffsetBars
var label avwapTag = na
var label upperOneTag = na
var label lowerOneTag = na
var label upperTwoTag = na
var label lowerTwoTag = na
var line avwapConnector = na
var line upperOneConnector = na
var line lowerOneConnector = na
var line upperTwoConnector = na
var line lowerTwoConnector = na

f_update_tag(label tag, float y, string txt, color bg) =>
    label result = tag
    if na(result)
        result := label.new(rightEdge, y, txt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = bg, textcolor = f_text_on(bg), size = labelSize)
    else
        label.set_x(result, rightEdge)
        label.set_y(result, y)
        label.set_text(result, txt)
        label.set_color(result, bg)
        label.set_textcolor(result, f_text_on(bg))
        label.set_size(result, labelSize)
    result

f_update_connector(line guide, float sourceY, float badgeY, color guideColor, bool coreRail) =>
    line result = guide
    if na(result)
        result := line.new(bar_index, sourceY, rightEdge, badgeY, xloc = xloc.bar_index, color = color.new(guideColor, coreRail ? 0 : 28), width = coreRail ? 2 : 1, style = coreRail ? line.style_solid : line.style_dotted)
    else
        line.set_xy1(result, bar_index, sourceY)
        line.set_xy2(result, rightEdge, badgeY)
        line.set_color(result, color.new(guideColor, coreRail ? 0 : 28))
        line.set_width(result, coreRail ? 2 : 1)
        line.set_style(result, coreRail ? line.style_solid : line.style_dotted)
    result

if showRightTags and not na(avwap)
    float fontGapFactor = labelSizeInput == "Large" ? 1.90 : labelSizeInput == "Normal" ? 1.55 : labelSizeInput == "Small" ? 1.25 : 1.05
    float tagGap = math.max(atr * rightTagLaneAtr * fontGapFactor, syminfo.mintick * 20.0)
    float avwapTagY = avwap
    float upperOneTagY = math.max(upperOne, avwapTagY + tagGap)
    float lowerOneTagY = math.min(lowerOne, avwapTagY - tagGap)
    float upperTwoTagY = math.max(upperTwo, upperOneTagY + tagGap)
    float lowerTwoTagY = math.min(lowerTwo, lowerOneTagY - tagGap)
    if showAVWAP
        avwapTag := f_update_tag(avwapTag, avwapTagY, "AVWAP  " + f_price(avwap), accentColor)
        avwapConnector := f_update_connector(avwapConnector, avwap, avwapTagY, accentColor, true)
    else
        if not na(avwapTag)
            label.delete(avwapTag)
            avwapTag := na
        if not na(avwapConnector)
            line.delete(avwapConnector)
            avwapConnector := na
    if showDeviationBands
        upperOneTag := f_update_tag(upperOneTag, upperOneTagY, "+1D  " + f_price(upperOne), bullColor)
        lowerOneTag := f_update_tag(lowerOneTag, lowerOneTagY, "-1D  " + f_price(lowerOne), bearColor)
        upperTwoTag := f_update_tag(upperTwoTag, upperTwoTagY, "+2D  " + f_price(upperTwo), color.new(bullColor, 8))
        lowerTwoTag := f_update_tag(lowerTwoTag, lowerTwoTagY, "-2D  " + f_price(lowerTwo), color.new(bearColor, 8))
        upperOneConnector := f_update_connector(upperOneConnector, upperOne, upperOneTagY, bullColor, false)
        lowerOneConnector := f_update_connector(lowerOneConnector, lowerOne, lowerOneTagY, bearColor, false)
        upperTwoConnector := f_update_connector(upperTwoConnector, upperTwo, upperTwoTagY, bullColor, false)
        lowerTwoConnector := f_update_connector(lowerTwoConnector, lowerTwo, lowerTwoTagY, bearColor, false)
    else
        if not na(upperOneTag)
            label.delete(upperOneTag)
            upperOneTag := na
        if not na(lowerOneTag)
            label.delete(lowerOneTag)
            lowerOneTag := na
        if not na(upperTwoTag)
            label.delete(upperTwoTag)
            upperTwoTag := na
        if not na(lowerTwoTag)
            label.delete(lowerTwoTag)
            lowerTwoTag := na
        if not na(upperOneConnector)
            line.delete(upperOneConnector)
            upperOneConnector := na
        if not na(lowerOneConnector)
            line.delete(lowerOneConnector)
            lowerOneConnector := na
        if not na(upperTwoConnector)
            line.delete(upperTwoConnector)
            upperTwoConnector := na
        if not na(lowerTwoConnector)
            line.delete(lowerTwoConnector)
            lowerTwoConnector := na
else
    if not na(avwapTag)
        label.delete(avwapTag)
        avwapTag := na
    if not na(upperOneTag)
        label.delete(upperOneTag)
        upperOneTag := na
    if not na(lowerOneTag)
        label.delete(lowerOneTag)
        lowerOneTag := na
    if not na(upperTwoTag)
        label.delete(upperTwoTag)
        upperTwoTag := na
    if not na(lowerTwoTag)
        label.delete(lowerTwoTag)
        lowerTwoTag := na
    if not na(avwapConnector)
        line.delete(avwapConnector)
        avwapConnector := na
    if not na(upperOneConnector)
        line.delete(upperOneConnector)
        upperOneConnector := na
    if not na(lowerOneConnector)
        line.delete(lowerOneConnector)
        lowerOneConnector := na
    if not na(upperTwoConnector)
        line.delete(upperTwoConnector)
        upperTwoConnector := na
    if not na(lowerTwoConnector)
        line.delete(lowerTwoConnector)
        lowerTwoConnector := na

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelPos = f_panel_position(panelPositionInput)
panelSize = f_size(panelFontSizeInput)
panelLeftFinal = panelTheme == "Dark" ? color.rgb(51, 65, 85) : color.rgb(71, 85, 105)
panelBgFinal = panelTheme == "Dark" ? panelBg : color.rgb(30, 41, 59)
actionColor = actionState == "READY" ? bullColor : actionState == "MONITOR RISK" ? neutralColor : actionState == "TRACK" ? accentColor : actionState == "BLOCKED" ? panelBorder : neutralColor
directionColor = directionState == "Bull Reclaim" or directionState == "Above AVWAP" ? bullColor : directionState == "Bear Loss" or directionState == "Below AVWAP" ? bearColor : neutralColor
holdRateCol = pfTotal >= 6 ? (pfRate >= 55.0 ? bullColor : pfRate >= 45.0 ? neutralColor : bearColor) : panelValueCol

var table panel = table.new(panelPos, 2, 7, border_width = 1, border_color = panelBorder)

if barstate.islast
    if showPanel
        table.clear(panel, 0, 0, 1, 6)
        table.cell(panel, 0, 0, "AG Pro Anchored VWAP Risk Ladder", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
        table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 1, "Anchor", text_color = panelLabelCol, bgcolor = panelLeftFinal, text_size = panelSize)
        table.cell(panel, 1, 1, anchorText, text_color = panelValueCol, bgcolor = panelBgFinal, text_size = panelSize)
        table.cell(panel, 0, 2, "Distance", text_color = panelLabelCol, bgcolor = panelLeftFinal, text_size = panelSize)
        table.cell(panel, 1, 2, distanceText, text_color = panelValueCol, bgcolor = panelBgFinal, text_size = panelSize)
        table.cell(panel, 0, 3, "Risk Ladder", text_color = panelLabelCol, bgcolor = panelLeftFinal, text_size = panelSize)
        table.cell(panel, 1, 3, ladderState + "  " + riskText, text_color = panelValueCol, bgcolor = panelBgFinal, text_size = panelSize)
        table.cell(panel, 0, 4, "Score", text_color = panelLabelCol, bgcolor = panelLeftFinal, text_size = panelSize)
        table.cell(panel, 1, 4, scoreText + "  " + directionState, text_color = f_text_on(directionColor), bgcolor = directionColor, text_size = panelSize)
        table.cell(panel, 0, 5, "Hold Rate", text_color = panelLabelCol, bgcolor = panelLeftFinal, text_size = panelSize)
        table.cell(panel, 1, 5, holdRateText, text_color = holdRateCol, bgcolor = panelBgFinal, text_size = panelSize)
        table.cell(panel, 0, 6, "Action", text_color = panelLabelCol, bgcolor = panelLeftFinal, text_size = panelSize)
        table.cell(panel, 1, 6, actionState, text_color = f_text_on(actionColor), bgcolor = actionColor, text_size = panelSize)
    else
        table.clear(panel, 0, 0, 1, 6)

barStateColor = actionState == "READY" ? color.new(directionColor, 70) : actionState == "MONITOR RISK" ? color.new(neutralColor, 78) : actionState == "TRACK" ? color.new(accentColor, 82) : na
barcolor(showBarColors ? barStateColor : na)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertAnchor and newAnchor and not firstBarReset, "AG Pro AVR | NEW ANCHOR LOCKED", "AG Pro AVR: A new anchored VWAP event has been locked.")
alertcondition(alertReclaim and readySignal and activeDir == 1, "AG Pro AVR | AVWAP RECLAIM READY", "AG Pro AVR: Price reclaimed anchored VWAP with sufficient score.")
alertcondition(alertLose and readySignal and activeDir == -1, "AG Pro AVR | AVWAP LOSS READY", "AG Pro AVR: Bearish AVWAP loss confirmed with sufficient score.")
alertcondition(alertExtension and extensionRisk, "AG Pro AVR | EXTENSION RISK", "AG Pro AVR: Price reached extension risk distance from anchored VWAP.")
````

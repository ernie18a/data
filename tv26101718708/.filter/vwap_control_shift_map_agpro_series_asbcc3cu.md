# VWAP Control Shift Map [AGPro Series]

- url: https://www.tradingview.com/script/AsBCC3cU-VWAP-Control-Shift-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;bd5a480bec2743d2b6cd2fdc676b6e53
- version: 3.0

## Description

VWAP Control Shift Map [AGPro Series]

🧠 Core Idea

Has VWAP control shifted from mean reversion to directional acceptance?


📌 Overview / What it does

VWAP Control Shift Map [AGPro Series] is a VWAP control and acceptance visualization tool built to identify when price is balanced around value, accepted above control, accepted below control, or rejected back into the VWAP band.

The script builds a rolling volume-weighted control line, maps a VWAP control band, labels acceptance and rejection events, and summarizes the current VWAP state in a compact AG Pro panel.

This script does not predict future price direction, automate trades, or provide guaranteed buy/sell signals. It is a structured decision-support map for VWAP control, acceptance quality, mean-reversion risk, and shift context.


🎯 Purpose & Design Philosophy

VWAP is one of the most watched value references across intraday and swing trading contexts.

The problem is that price can cross VWAP many times without meaningful control transfer. This script was built to separate casual VWAP interaction from stronger acceptance, rejection, and reversion behavior.

The design philosophy is to make VWAP context visually readable: where control sits, which side is accepted, whether reversion risk is rising, and whether the shift has quality.


⚡ Why This Script Is Different

Most VWAP tools plot a line, add bands, and leave interpretation entirely to the user.

This script does NOT simply mark every VWAP touch as important and does NOT treat every cross as a trend signal.

Instead, it frames VWAP as a control zone: acceptance above, acceptance below, rejection back into value, and mean-reversion risk are all organized into one visual map.


⚙️ Methodology

1. VWAP Control Detection
The script calculates a rolling volume-weighted control line using price and volume over the selected control window.

2. Control Band Mapping
It builds a volatility-adjusted band around VWAP to represent the current value-control area.

3. Acceptance Evaluation
Consecutive closes outside the band are used to identify directional acceptance.

4. Rejection Evaluation
If price returns into the band after a shift, the script marks VWAP rejection behavior.

5. Visual Output
The chart displays the VWAP control line, bordered control zone, centered band label, event labels, right-side state tags, and AG Pro panel.


🗺️ How to Read the Chart

The VWAP control line represents the rolling volume-weighted value reference.

The control band represents the active VWAP acceptance area.

Labels mark acceptance, rejection, and mean-reversion events.

Right-side tags show the current control state and shift quality.

The panel summarizes VWAP control, acceptance state, control side, reversion risk, shift quality, control band, and next context.


🚦 Signals & States

• VWAP BALANCE → price has not established a clear accepted side

• ACCEPT ABOVE → price has accepted above the VWAP control band

• ACCEPT BELOW → price has accepted below the VWAP control band

• VWAP REJECTION → a control shift returned back into the band

• REVERSION RISK → price is back inside the band after a directional control state


🔔 Alerts Logic

VWAP Control Shift Up alert triggers when price accepts above the VWAP control band.

VWAP Control Shift Down alert triggers when price accepts below the VWAP control band.

VWAP Rejection alert triggers when price returns back into the band after a control shift.

Alerts are attention markers. They are not trade instructions.


🧩 Confluence Logic

The context becomes stronger when acceptance direction, VWAP slope, distance from VWAP, and candle body pressure align.

The context becomes weaker when price quickly returns into the control band after an attempted shift.


📊 When to Use

• VWAP-based intraday analysis

• Swing charts where volume-weighted value remains relevant

• Mean-reversion versus directional acceptance decisions

• Markets with liquid volume and clean price structure

• Trend continuation or failed acceptance review


⚠️ When NOT to Use

• Very illiquid symbols

• Markets with unreliable volume

• Extremely noisy low-timeframe charts

• News shock environments where VWAP control changes abruptly

• Any context where a single indicator is being used without broader structure


🎛️ Key Inputs

• VWAP Control Length → controls the rolling volume-weighted control window

• Band Volatility Length → controls how the band width is calculated

• Control Band Multiplier → adjusts VWAP control band width

• Acceptance Bars → defines how many closes are needed for acceptance

• Rejection Window → controls failed-shift timing

• Visual settings → control the panel, zone, labels, font sizes, and projection


🖥️ Interface & Visual Design

The interface is designed for clean, premium chart reading.

The VWAP band uses visible four-edge zone boundaries so the control area remains clear in both editor and published TradingView views.

The panel uses the AG Pro merged blue header standard and keeps the current context readable without covering the main chart.


🧪 Practical Usage Workflow

1. Read the panel state.

2. Check whether price is inside, above, or below the VWAP control band.

3. Review acceptance or rejection labels.

4. Compare shift quality with reversion risk.

5. Use broader market structure before making any decision.


🔍 Interpretation Guidelines

VWAP control is not a prediction.

Acceptance shows where price has spent enough time outside the control band to suggest directional control.

Rejection shows that the attempted control shift returned back toward value.

Mean-reversion risk increases when price moves back into the VWAP control area after directional acceptance.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not guarantee profitable trades.

It does not replace risk management or independent analysis.


⚠️ Limitations & Transparency

VWAP behavior can vary by timeframe, market session, liquidity, and volume quality.

Rolling VWAP control may differ from exchange-session VWAP or anchored VWAP tools.

Extreme volatility can temporarily reduce the usefulness of control-band interpretation.

Outputs should always be interpreted within broader market context.


🧠 Market Context Notes

VWAP often works as a value reference, but value can shift when acceptance becomes persistent.

A clean control shift is stronger when price accepts outside the band while VWAP slope supports the move.

A weak shift often returns back into the band and becomes a rejection or mean-reversion context.


🧾 Use Case Examples

When price accepts above the VWAP control band with strong shift quality, the chart may be showing directional control above value.

When price accepts below the band and VWAP turns down, the control context may favor downside acceptance.

When price quickly returns into the band after acceptance, VWAP rejection risk becomes more important.


🧱 System Philosophy

AGPro Series tools are built to convert complex market behavior into visual decision maps.

The goal is not certainty. The goal is structured context, cleaner interpretation, and better chart discipline.


🔐 Non-Promise Statement

No script can know the future.

No signal is certain.

No visual state should be treated as a guaranteed outcome.


📉 Risk Disclosure

Trading involves risk.

Markets can move unexpectedly.

Users are responsible for their own decisions, risk management, and trade execution.

This script does not provide financial advice.


📚 Educational Note

This tool is intended for educational and analytical use. It can help traders study VWAP control, acceptance shifts, rejection behavior, and mean-reversion risk.

## Source Code

````pine
// --------------------------------------------------
// VWAP Control Shift Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.2
//
// A VWAP control and acceptance map that studies whether price is reverting around
// value or shifting into directional acceptance. The script maps VWAP control bands,
// acceptance/rejection behavior, shift quality, and next-context information for
// traders who want a clean view of VWAP control, mean-reversion risk, and directional
// acceptance without turning the chart into a prediction engine. A shift follow-rate
// layer reports how often confirmed acceptance shifts on this chart actually extended
// away from value before closing back through the VWAP control line.
// --------------------------------------------------

//@version=6
indicator("VWAP Control Shift Map [AGPro Series]",
     shorttitle = "AGP VCSM",
     overlay = true,
     max_labels_count = 100,
     max_boxes_count = 30,
     max_lines_count = 30)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
G_CORE = "Core Logic"
vwapLength = input.int(72, "VWAP Control Length", minval = 20, maxval = 260, group = G_CORE,
     tooltip = "Defines the rolling volume-weighted control window used for the VWAP map.")
bandLength = input.int(72, "Band Volatility Length", minval = 20, maxval = 260, group = G_CORE,
     tooltip = "Defines the volatility window used to build the VWAP control band.")
bandMult = input.float(0.85, "Control Band Multiplier", minval = 0.25, maxval = 3.0, step = 0.05, group = G_CORE,
     tooltip = "Controls the width of the VWAP control band.")
acceptBars = input.int(3, "Acceptance Bars", minval = 1, maxval = 8, group = G_CORE,
     tooltip = "Number of consecutive closes outside the control band required for directional acceptance.")
rejectBars = input.int(3, "Rejection Window", minval = 2, maxval = 12, group = G_CORE,
     tooltip = "Number of bars used to classify a failed control shift back into the VWAP band.")
slopeLookback = input.int(8, "VWAP Slope Lookback", minval = 2, maxval = 40, group = G_CORE,
     tooltip = "Measures whether VWAP control is turning higher, lower, or remaining neutral.")

G_VISUAL = "Visual Design"
showControlBand = input.bool(true, "Show VWAP Control Band", group = G_VISUAL,
     tooltip = "Displays the active VWAP control band as a bordered zone.")
showVwapLine = input.bool(true, "Show VWAP Control Line", group = G_VISUAL,
     tooltip = "Displays the rolling VWAP control line.")
showBandLabel = input.bool(true, "Show Band Label", group = G_VISUAL,
     tooltip = "Shows one centered badge that combines the active acceptance state, VWAP control identity, and shift quality.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows compact acceptance, rejection, and reversion labels.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows upper and lower control tags directly on their owned VWAP band rails.")
showBarColors = input.bool(true, "Color Bars by Control State", group = G_VISUAL,
     tooltip = "Tints bars by the current VWAP control state. Disable for plain candles.")
showPanel = input.bool(true, "Show Panel", group = G_VISUAL,
     tooltip = "Shows or hides the AG Pro information panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = G_VISUAL,
     tooltip = "Controls where the AG Pro panel is placed.")
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_VISUAL,
     tooltip = "Controls the panel color theme.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Controls the font size of chart labels.")
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Controls the font size of the panel.")
zoneBars = input.int(80, "Visible Control Zone Bars", minval = 24, maxval = 220, group = G_VISUAL,
     tooltip = "Controls how many recent bars are covered by the visible VWAP control zone.")
projectionBars = input.int(26, "Zone Projection Bars", minval = 8, maxval = 80, group = G_VISUAL,
     tooltip = "Controls how far the VWAP control zone is projected to the right.")
labelCooldownBars = input.int(52, "Event Label Cooldown", minval = 8, maxval = 120, group = G_VISUAL,
     tooltip = "Minimum number of bars between event labels. Higher values reduce label density.")
maxEventLabels = input.int(5, "Maximum Event Labels", minval = 3, maxval = 30, group = G_VISUAL,
     tooltip = "Maximum number of historical event labels kept on the chart.")
labelOffsetAtr = input.float(1.05, "Label Offset ATR", minval = 0.20, maxval = 4.0, step = 0.05, group = G_VISUAL,
     tooltip = "Distance between event labels and candles, measured in ATR.")

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
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
inkDark = color.rgb(15, 23, 42)
inkLight = color.rgb(245, 247, 250)

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_size(sizeName) =>
    sizeName == "Tiny" ? size.tiny : sizeName == "Small" ? size.small : sizeName == "Large" ? size.large : size.normal

f_panel_pos(posName) =>
    posName == "Top Left" ? position.top_left : posName == "Bottom Right" ? position.bottom_right : posName == "Bottom Left" ? position.bottom_left : position.top_right

f_clamp(value, minValue, maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_score(value) =>
    na(value) ? "n/a" : str.tostring(math.round(value))

f_fmt(value) =>
    str.tostring(value, format.mintick)

f_text_on(bg) =>
    luminance = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
    luminance > 145 ? inkDark : inkLight

f_dir_text(direction) =>
    direction > 0 ? "BULLISH" : direction < 0 ? "BEARISH" : "NEUTRAL"

f_set_box(boxRef, leftValue, rightValue, topValue, bottomValue, bg, border) =>
    box.set_left(boxRef, leftValue)
    box.set_right(boxRef, rightValue)
    box.set_top(boxRef, topValue)
    box.set_bottom(boxRef, bottomValue)
    box.set_bgcolor(boxRef, bg)
    box.set_border_color(boxRef, border)
    box.set_border_width(boxRef, 3)

f_set_line(lineRef, x1, y1, x2, y2, col, styleValue) =>
    line.set_xy1(lineRef, x1, y1)
    line.set_xy2(lineRef, x2, y2)
    line.set_color(lineRef, col)
    line.set_style(lineRef, styleValue)
    line.set_width(lineRef, 3)

f_set_tag(tag, x, y, labelText, bg, styleValue, textSize) =>
    label.set_x(tag, x)
    label.set_y(tag, y)
    label.set_text(tag, labelText)
    label.set_color(tag, bg)
    label.set_textcolor(tag, f_text_on(bg))
    label.set_style(tag, styleValue)
    label.set_size(tag, textSize)

f_hide_tag(tag) =>
    label.set_x(tag, bar_index)
    label.set_y(tag, close)
    label.set_text(tag, "")
    label.set_color(tag, color.new(accentColor, 100))
    label.set_textcolor(tag, color.new(inkLight, 100))

f_panel_cell(panelRef, col, row, txt, bg, txtColor, txtSize, alignValue) =>
    table.cell(panelRef, col, row, txt, bgcolor = bg, text_color = txtColor, text_size = txtSize, text_halign = alignValue)

// --------------------------------------------------
// Core Calculations
// --------------------------------------------------
labelSize = f_size(labelSizeInput)
panelSize = f_size(panelSizeInput)
atr = ta.atr(14)
src = hlc3
volumeValue = nz(volume, 1.0)
volSafe = volumeValue > 0 ? volumeValue : 1.0
volSum = math.sum(volSafe, vwapLength)
weightedSum = math.sum(src * volSafe, vwapLength)
controlVwap = volSum > 0 ? weightedSum / volSum : ta.sma(src, vwapLength)
bandDevRaw = ta.stdev(src - controlVwap, bandLength)
bandDev = nz(bandDevRaw, atr)
bandWidth = math.max(bandDev * bandMult, atr * 0.18)
upperBand = controlVwap + bandWidth
lowerBand = controlVwap - bandWidth
bandMid = controlVwap
vwapSlope = controlVwap - controlVwap[slopeLookback]
slopeAtr = atr > 0 ? vwapSlope / atr : 0.0

aboveControl = close > upperBand
belowControl = close < lowerBand
insideControl = close <= upperBand and close >= lowerBand
aboveCount = math.sum(aboveControl ? 1 : 0, acceptBars)
belowCount = math.sum(belowControl ? 1 : 0, acceptBars)
bullAcceptance = aboveCount == acceptBars
bearAcceptance = belowCount == acceptBars
acceptanceDir = bullAcceptance ? 1 : bearAcceptance ? -1 : 0

var int controlDir = 0
var int shiftBar = na
var float shiftQualityMemory = na
var bool rejectionMemory = false

// A new shift is either a flip to the opposite side or a same-side
// re-acceptance after a rejection. Without the second case the state
// could stay locked on VWAP REJECTION even while price was clearly
// accepted outside the band again.
newAcceptance = acceptanceDir != 0 and (acceptanceDir != controlDir or (rejectionMemory and not insideControl))
if newAcceptance
    controlDir := acceptanceDir
    shiftBar := bar_index
    rejectionMemory := false
    shiftQualityMemory := f_clamp(math.abs(close - controlVwap) / atr * 14.0 + math.abs(slopeAtr) * 20.0 + math.abs(close - open) / atr * 12.0 + 12.0, 0.0, 100.0)

returnedToBand = controlDir != 0 and not na(shiftBar) and bar_index - shiftBar <= rejectBars and insideControl
if returnedToBand
    rejectionMemory := true

reversionRisk = insideControl and controlDir != 0 ? f_clamp(70.0 - math.abs(close - controlVwap) / atr * 18.0, 0.0, 100.0) : na
shiftQuality = na(shiftQualityMemory) ? f_clamp(math.abs(slopeAtr) * 25.0 + (insideControl ? 14.0 : 32.0) + math.abs(close - controlVwap) / atr * 9.0, 0.0, 100.0) : shiftQualityMemory

// Shift follow-rate layer: each confirmed acceptance shift is tracked
// once. It counts as followed when price extends 1.5 ATR beyond the
// shift close in the acceptance direction before closing back through
// the VWAP control line, and as failed when value is reclaimed first
// or the tracking window times out. Resolution runs before
// registration, so same-bar conflicts resolve conservatively.
shiftConfirmedNew = barstate.isconfirmed and newAcceptance
var bool shiftTrkOn = false
var int shiftTrkDir = 0
var float shiftTrkTgt = na
var int shiftTrkStart = na
var int shiftFollowW = 0
var int shiftFollowN = 0
shiftTrkWindow = math.max(20, vwapLength / 2)
if shiftTrkOn
    sFollowed = shiftTrkDir == 1 ? high >= shiftTrkTgt : low <= shiftTrkTgt
    sFailed = shiftTrkDir == 1 ? close < controlVwap : close > controlVwap
    sTimeout = not na(shiftTrkStart) and bar_index - shiftTrkStart >= shiftTrkWindow
    if sFailed or sTimeout
        shiftFollowN += 1
        shiftTrkOn := false
    else if sFollowed
        shiftFollowN += 1
        shiftFollowW += 1
        shiftTrkOn := false
if shiftConfirmedNew and not shiftTrkOn
    shiftTrkOn := true
    shiftTrkDir := controlDir
    shiftTrkTgt := close + (controlDir > 0 ? 1.0 : -1.0) * atr * 1.5
    shiftTrkStart := bar_index
shiftFollowRate = shiftFollowN > 0 ? 100.0 * shiftFollowW / shiftFollowN : na
shiftFollowReady = shiftFollowN >= 8
stateText = controlDir == 0 ? "VWAP BALANCE" : rejectionMemory ? "VWAP REJECTION" : insideControl ? "REVERSION RISK" : controlDir > 0 ? "ACCEPT ABOVE" : "ACCEPT BELOW"
stateColor = rejectionMemory ? bearColor : controlDir > 0 ? bullColor : controlDir < 0 ? bearColor : accentColor
acceptanceText = controlDir == 0 ? "Neutral control" : rejectionMemory ? "Shift rejected" : insideControl ? "Mean reversion" : controlDir > 0 ? "Above accepted" : "Below accepted"
nextContext = controlDir == 0 ? "Wait control shift" : rejectionMemory ? "Recheck VWAP" : insideControl ? "Watch mean revert" : "Track acceptance"
bandText = f_fmt(lowerBand) + " / " + f_fmt(upperBand)

// --------------------------------------------------
// Visual Objects
// --------------------------------------------------
vwapPlot = plot(showVwapLine ? controlVwap : na, "VWAP Control", color = color.new(stateColor, 0), linewidth = 2)
upperPlot = plot(showVwapLine ? upperBand : na, "Upper Control Band", color = color.new(stateColor, 82), linewidth = 1)
lowerPlot = plot(showVwapLine ? lowerBand : na, "Lower Control Band", color = color.new(stateColor, 82), linewidth = 1)
fill(upperPlot, lowerPlot, color = color.new(stateColor, 94), title = "VWAP Control Fill")

var box controlBox = box.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 90), border_color = accentColor, border_width = 3)
var line upperRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = accentColor, style = line.style_solid, width = 3)
var line lowerRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = accentColor, style = line.style_solid, width = 3)
var label bandCenter = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_center, color = accentColor, textcolor = color.white, size = size.normal)
var label stateTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = color.white, size = size.normal)
var label qualityTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = color.white, size = size.normal)

rightX = bar_index + projectionBars
leftX = math.max(bar_index - zoneBars, 0)
labelX = int(math.round(leftX + (rightX - leftX) * 0.70))

if barstate.islast and showControlBand
    f_set_box(controlBox, leftX, rightX, upperBand, lowerBand, color.new(stateColor, 90), color.new(stateColor, 0))
    f_set_line(upperRail, leftX, upperBand, rightX, upperBand, color.new(stateColor, 0), line.style_solid)
    f_set_line(lowerRail, leftX, lowerBand, rightX, lowerBand, color.new(stateColor, 0), line.style_solid)
    if showBandLabel
        f_set_tag(bandCenter, labelX, bandMid, stateText + " | VWAP Q" + f_score(shiftQuality), color.new(stateColor, 0), label.style_label_center, labelSize)
    else
        f_hide_tag(bandCenter)
else if barstate.islast
    f_set_box(controlBox, bar_index, bar_index + 1, close, close, color.new(accentColor, 100), color.new(accentColor, 100))
    f_set_line(upperRail, bar_index, close, bar_index + 1, close, color.new(accentColor, 100), line.style_solid)
    f_set_line(lowerRail, bar_index, close, bar_index + 1, close, color.new(accentColor, 100), line.style_solid)
    f_hide_tag(bandCenter)

if barstate.islast and showRightTags
    f_set_tag(stateTag, rightX, upperBand, "UPPER CTRL | " + f_fmt(upperBand), stateColor, label.style_label_left, labelSize)
    f_set_tag(qualityTag, rightX + 4, lowerBand, "LOWER CTRL | " + f_fmt(lowerBand), stateColor, label.style_label_left, labelSize)
else if barstate.islast
    f_hide_tag(stateTag)
    f_hide_tag(qualityTag)

// --------------------------------------------------
// Event Labels
// --------------------------------------------------
var array<label> eventLabels = array.new<label>()
var array<line> eventConnectors = array.new<line>()
var int lastEventBar = na
canPrintEvent = na(lastEventBar) or bar_index - lastEventBar >= labelCooldownBars
rejectionEvent = returnedToBand and not returnedToBand[1]
reversionEvent = insideControl and not insideControl[1] and controlDir != 0 and not rejectionEvent
eventCandidate = newAcceptance or rejectionEvent or reversionEvent
eventText = rejectionEvent ? "VWAP REJECT | Q " + f_score(shiftQuality) : reversionEvent ? "MEAN REVERT | Q " + f_score(reversionRisk) : controlDir > 0 ? "ACCEPT ABOVE | Q " + f_score(shiftQuality) : "ACCEPT BELOW | Q " + f_score(shiftQuality)
eventColor = rejectionEvent ? bearColor : reversionEvent ? neutralColor : stateColor
eventLane = bar_index % 3
eventLaneStep = labelSizeInput == "Tiny" ? 0.16 : labelSizeInput == "Small" ? 0.20 : labelSizeInput == "Large" ? 0.34 : 0.26
eventDistance = atr * (labelOffsetAtr + eventLane * eventLaneStep)
eventAnchorY = controlDir < 0 ? low : high
eventY = controlDir < 0 ? eventAnchorY - eventDistance : eventAnchorY + eventDistance
eventStyle = controlDir < 0 ? label.style_label_up : label.style_label_down

if showEventLabels and eventCandidate and canPrintEvent
    newEventConnector = line.new(bar_index, eventAnchorY, bar_index, eventY, xloc = xloc.bar_index, extend = extend.none, color = color.new(eventColor, 30), width = 1)
    newEventLabel = label.new(bar_index, eventY, eventText, xloc = xloc.bar_index, style = eventStyle, textcolor = f_text_on(eventColor), color = eventColor, size = labelSize)
    array.push(eventLabels, newEventLabel)
    array.push(eventConnectors, newEventConnector)
    if array.size(eventLabels) > maxEventLabels
        label.delete(array.shift(eventLabels))
        line.delete(array.shift(eventConnectors))
    lastEventBar := bar_index

barCol = rejectionMemory ? color.new(bearColor, 58) : controlDir != 0 ? color.new(stateColor, 74) : na
barcolor(showBarColors ? barCol : na)

// --------------------------------------------------
// Panel
// --------------------------------------------------
panelBgActive = panelThemeInput == "Dark" ? panelBg : color.rgb(248, 250, 252)
panelBorderActive = panelThemeInput == "Dark" ? panelBorder : color.rgb(203, 213, 225)
panelLabelActive = panelThemeInput == "Dark" ? panelLabelCol : color.rgb(71, 85, 105)
panelValueActive = panelThemeInput == "Dark" ? panelValueCol : color.rgb(15, 23, 42)

var table panel = na
var string panelPosMemory = ""
var string panelThemeMemory = ""

if showPanel and (na(panel) or panelPosMemory != panelPositionInput or panelThemeMemory != panelThemeInput)
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_pos(panelPositionInput), 2, 9, bgcolor = panelBgActive, border_color = panelBorderActive, border_width = 1)
    panelPosMemory := panelPositionInput
    panelThemeMemory := panelThemeInput

if showPanel and not na(panel)
    f_panel_cell(panel, 0, 0, "AG Pro VWAP Control Shift Map", headerBg, headerText, panelSize, text.align_center)
    f_panel_cell(panel, 1, 0, "", headerBg, headerText, panelSize, text.align_center)
    table.merge_cells(panel, 0, 0, 1, 0)
    f_panel_cell(panel, 0, 1, "VWAP Control", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 1, stateText, panelBgActive, stateColor, panelSize, text.align_center)
    f_panel_cell(panel, 0, 2, "Acceptance State", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 2, acceptanceText, panelBgActive, panelValueActive, panelSize, text.align_center)
    f_panel_cell(panel, 0, 3, "Control Side", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 3, f_dir_text(controlDir), panelBgActive, stateColor, panelSize, text.align_center)
    f_panel_cell(panel, 0, 4, "Reversion Risk", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 4, f_score(reversionRisk), panelBgActive, panelValueActive, panelSize, text.align_center)
    f_panel_cell(panel, 0, 5, "Shift Quality", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 5, f_score(shiftQuality), panelBgActive, panelValueActive, panelSize, text.align_center)
    f_panel_cell(panel, 0, 6, "Control Band", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 6, bandText, panelBgActive, panelValueActive, panelSize, text.align_center)
    shiftFollowText = shiftFollowN == 0 ? "-" : str.tostring(int(math.round(shiftFollowRate))) + "%  n=" + str.tostring(shiftFollowN)
    shiftFollowColor = shiftFollowReady ? (shiftFollowRate >= 55.0 ? bullColor : shiftFollowRate >= 40.0 ? neutralColor : bearColor) : panelLabelActive
    f_panel_cell(panel, 0, 7, "Shift Follow", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 7, shiftFollowText, panelBgActive, shiftFollowColor, panelSize, text.align_center)
    f_panel_cell(panel, 0, 8, "Next Level", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 8, nextContext, panelBgActive, panelValueActive, panelSize, text.align_center)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    panelPosMemory := ""
    panelThemeMemory := ""

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(newAcceptance and controlDir > 0, "VWAP Control Shift Up", "Price accepted above the VWAP control band.")
alertcondition(newAcceptance and controlDir < 0, "VWAP Control Shift Down", "Price accepted below the VWAP control band.")
alertcondition(rejectionEvent, "VWAP Rejection", "VWAP control shift returned into the control band.")
````

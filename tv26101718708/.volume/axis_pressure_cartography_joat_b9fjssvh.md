# Axis Pressure Cartography [JOAT]

- url: https://www.tradingview.com/script/b9fJSsvH-Axis-Pressure-Cartography-JOAT/
- type: indicator
- pine_id: PUB;e2f056378bcf4ab2a431e8322f36600a
- version: 1.0

## Description

[b]Axis Pressure Cartography [JOAT][/b]

[b]Introduction[/b]

Axis Pressure Cartography is an open-source normalized pressure oscillator that measures how far price has deviated from a configurable moving average and classifies the resulting state into constructive, compressed, or overheated conditions.

[image]https://www.tradingview.com/x/Sj17Toiq/[/image]

[b]Core Concepts[/b]

[b]1. Normalized MA distance[/b]

Price is measured against a configurable moving average and normalized against recent maximum deviation so different volatility regimes remain interpretable on the same scale.

[b]2. State persistence[/b]

Pressure states are held using a confirmation window rather than flipping instantly on small changes, which reduces noise and creates a more stable regime read.

[b]3. Envelope logic[/b]

Pressure envelopes define structural bounds around the oscillator so extreme expansion can be recognized as a separate state from ordinary constructive trend pressure.

[b]Features[/b]

[list]
[*][b]Normalized pressure oscillator and signal[/b]
[*][b]Compression, expansion, and overheated-state classification[/b]
[*][b]Envelope rails and pressure background tint[/b]
[*][b]Compact institutional dashboard[/b]
[*][b]Confirmed alerts for flips, releases, and exhaustion transitions[/b]
[/list]

[b]Disclaimer[/b]

This indicator is educational only. Extreme pressure can persist longer than expected, and compression can resolve in either direction.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Axis Pressure Cartography [JOAT]", overlay = false, max_labels_count = 100)

//------------------------------------------------------------------------------
// Axis Pressure Cartography
// Normalized MA-distance oscillator with state compression, exhaustion bands,
// and a compact dashboard for pressure regime diagnostics.
//------------------------------------------------------------------------------

string groupMa = "MA"
string groupStyle = "Style"
string groupDashboard = "Dashboard"
string groupAlerts = "Alerts"

sourceInput = input.source(close, "Source", group = groupMa)
string maType = input.string("EMA", "Type", options = ["SMA", "EMA", "RMA", "WMA", "VWMA"], group = groupMa)
int maLength = input.int(55, "Length", minval = 2, group = groupMa)
int normalizeLength = input.int(80, "Normalization Length", minval = 20, group = groupMa)
int signalLength = input.int(8, "Signal Smoothing", minval = 1, group = groupMa)
float extremeLevel = input.float(80.0, "Extreme Level", minval = 20.0, maxval = 100.0, group = groupMa)
float warningLevel = input.float(45.0, "Warning Level", minval = 5.0, maxval = 100.0, group = groupMa)

color bullCol = input.color(color.rgb(28, 198, 226), "Positive Pressure", group = groupStyle, inline = "c1")
color bearCol = input.color(color.rgb(235, 92, 126), "", group = groupStyle, inline = "c1")
color neutralCol = input.color(color.rgb(114, 125, 153), "Neutral", group = groupStyle)
bool recolorCandles = input.bool(true, "Recolor Candles", group = groupStyle)
bool showReferenceMa = input.bool(true, "Show Reference MA", group = groupStyle)
bool showBackground = input.bool(true, "Show Background", group = groupStyle)
bool showSyntheticCandles = input.bool(false, "Plot Synthetic Candles", group = groupStyle)
bool showBands = input.bool(true, "Show Bands", group = groupStyle)

bool showDashboard = input.bool(true, "Show Dashboard", group = groupDashboard)
string dashSize = input.string("Normal", "Dashboard Size", options = ["Small", "Normal", "Large"], group = groupDashboard)
bool showDebugPlots = input.bool(false, "Show Debug Plots", group = groupDashboard)
bool showStateRibbon = input.bool(true, "Show State Ribbon", group = groupDashboard)
bool showEnvelope = input.bool(true, "Show Envelope Bands", group = groupDashboard)
int stateHoldBars = input.int(2, "State Hold Bars", minval = 0, maxval = 10, group = groupDashboard)

bool enableAlerts = input.bool(true, "Enable Alerts", group = groupAlerts)

f_size(string sizeName) =>
    switch sizeName
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_ma(float source, int length, string kind) =>
    switch kind
        "SMA" => ta.sma(source, length)
        "RMA" => ta.rma(source, length)
        "WMA" => ta.wma(source, length)
        "VWMA" => ta.vwma(source, length)
        => ta.ema(source, length)

f_state_text(int code) =>
    switch code
        3 => "Overheated Bid"
        2 => "Positive Expansion"
        1 => "Constructive Bid"
        -1 => "Constructive Offer"
        -2 => "Negative Expansion"
        -3 => "Overheated Offer"
        => "Balanced"

f_state_color(int code) =>
    switch code
        3 => bullCol
        2 => color.from_gradient(0.75, 0.0, 1.0, neutralCol, bullCol)
        1 => color.from_gradient(0.40, 0.0, 1.0, neutralCol, bullCol)
        -1 => color.from_gradient(0.40, 0.0, 1.0, neutralCol, bearCol)
        -2 => color.from_gradient(0.75, 0.0, 1.0, neutralCol, bearCol)
        -3 => bearCol
        => neutralCol

float refMa = f_ma(sourceInput, maLength, maType)
float rawDistance = sourceInput - refMa
float maxDistance = math.max(ta.highest(math.abs(rawDistance), normalizeLength), syminfo.mintick)
float pressure = rawDistance / maxDistance * 100.0
float pressureSignal = ta.ema(pressure, signalLength)
float pressureSlope = pressureSignal - pressureSignal[1]
float pressureMomentum = ta.ema(ta.change(pressureSignal), signalLength)
float pressureZ = rawDistance / math.max(ta.stdev(rawDistance, normalizeLength), syminfo.mintick)
float pressureRank = ta.percentrank(pressure, normalizeLength)

color pressureColor = color.from_gradient(pressure, -100.0, 100.0, bearCol, bullCol)
color signalColor = color.from_gradient(pressureSignal, -100.0, 100.0, bearCol, bullCol)
color rankColor = color.from_gradient(pressureRank, 0.0, 100.0, bearCol, bullCol)
float pressureSpread = pressure - pressureSignal
float pressureRange = ta.highest(pressureSignal, normalizeLength) - ta.lowest(pressureSignal, normalizeLength)
float pressureImpulse = math.abs(pressureSlope) / math.max(ta.atr(14), syminfo.mintick)
float pressureEfficiency = math.abs(pressureSpread) / math.max(math.abs(pressureSignal), 1.0)
float pressureStability = 100.0 - math.min(100.0, math.abs(pressureSpread) + math.abs(pressureSlope) * 2.0)
float pressureMedian = ta.sma(pressureSignal, math.max(5, signalLength * 2))
float squeezeScore = math.max(0.0, 100.0 - math.min(100.0, pressureRange + math.abs(pressureSpread) * 1.5))
float pressureUpperEnvelope = pressureSignal + warningLevel * 0.7
float pressureLowerEnvelope = pressureSignal - warningLevel * 0.7
float pressureOuterEnvelope = pressureSignal + extremeLevel * 0.25
float pressureLowerOuter = pressureSignal - extremeLevel * 0.25

float upperBand = extremeLevel
float lowerBand = -extremeLevel
float upperWarn = warningLevel
float lowerWarn = -warningLevel
float upperInner = extremeLevel * 0.5
float lowerInner = -extremeLevel * 0.5

plotPressure = plot(pressure, "Pressure", color = pressureColor, linewidth = 3)
plotSignal = plot(pressureSignal, "Signal", color = signalColor, linewidth = 2)
plotZero = plot(0, "Zero", color = color.new(neutralCol, 45))
plotUpper = plot(showBands ? upperBand : na, "Upper Extreme", color = color.new(bullCol, 80))
plotLower = plot(showBands ? lowerBand : na, "Lower Extreme", color = color.new(bearCol, 80))
plotUpperWarn = plot(showBands ? upperWarn : na, "Upper Warning", color = color.new(bullCol, 90))
plotLowerWarn = plot(showBands ? lowerWarn : na, "Lower Warning", color = color.new(bearCol, 90))

fill(plotZero, plotPressure, color.new(pressureColor, 82))
fill(plotUpper, plotUpperWarn, color.new(bullCol, 94))
fill(plotLower, plotLowerWarn, color.new(bearCol, 94))

hline(0, "Midline", color = color.new(neutralCol, 80))

color candleColor = recolorCandles ? pressureColor : na
barcolor(candleColor)

//------------------------------------------------------------------------------
// State engine
//------------------------------------------------------------------------------
bool compression = math.abs(pressureSlope) < 2.0 and math.abs(pressureSignal) < warningLevel * 0.65
bool expansionUp = pressureSlope > 0 and pressureSignal > upperWarn
bool expansionDown = pressureSlope < 0 and pressureSignal < lowerWarn
bool overheatedUp = pressureSignal >= upperBand
bool overheatedDown = pressureSignal <= lowerBand
bool positiveFlip = ta.crossover(pressureSignal, 0)
bool negativeFlip = ta.crossunder(pressureSignal, 0)
bool compressionRelease = compression[1] and not compression
int candidateState = overheatedUp ? 3 : overheatedDown ? -3 : expansionUp ? 2 : expansionDown ? -2 : compression ? 0 : pressureSignal > 0 ? 1 : pressureSignal < 0 ? -1 : 0
var int activeState = 0
var int pendingState = 0
var int pendingSince = na
if candidateState != activeState
    pendingState := candidateState
    pendingSince := bar_index
bool stateReady = pendingState != activeState and barstate.isconfirmed and bar_index - nz(pendingSince, bar_index) >= stateHoldBars
if stateReady
    activeState := pendingState
    pendingState := 0
    pendingSince := na
if activeState == 0 and barstate.isconfirmed
    activeState := candidateState

string state = f_state_text(activeState)
color stateColor = f_state_color(activeState)
int stateHold = bar_index - nz(pendingSince, bar_index)
float stateStrength = math.max(math.abs(pressureSignal), math.abs(pressureSlope) * 10.0)
float stateBalance = pressureSignal - pressureMedian
bool bullishBias = activeState > 0 and pressureSignal >= pressureMedian
bool bearishBias = activeState < 0 and pressureSignal <= pressureMedian
bool positiveExpansion = activeState >= 2
bool negativeExpansion = activeState <= -2
bool hotBid = activeState == 3
bool hotOffer = activeState == -3
bool stateFlipUp = barstate.isconfirmed and activeState > nz(activeState[1], 0)
bool stateFlipDown = barstate.isconfirmed and activeState < nz(activeState[1], 0)

var float upperAnchor = na
var float lowerAnchor = na
var int upperAnchorBar = na
var int lowerAnchorBar = na

if overheatedUp and barstate.isconfirmed
    upperAnchor := high[1]
    upperAnchorBar := bar_index[1]
if overheatedDown and barstate.isconfirmed
    lowerAnchor := low[1]
    lowerAnchorBar := bar_index[1]

if not na(upperAnchor) and barstate.isconfirmed and high > upperAnchor and bar_index - nz(upperAnchorBar, bar_index) > 8
    upperAnchor := na
    upperAnchorBar := na
if not na(lowerAnchor) and barstate.isconfirmed and low < lowerAnchor and bar_index - nz(lowerAnchorBar, bar_index) > 8
    lowerAnchor := na
    lowerAnchorBar := na

plot(showEnvelope ? pressureUpperEnvelope : na, "Pressure Upper Envelope", color = color.new(bullCol, 88), linewidth = 1)
plot(showEnvelope ? pressureLowerEnvelope : na, "Pressure Lower Envelope", color = color.new(bearCol, 88), linewidth = 1)

var line envHigh = na
var line envLow = na
var linefill envFill = na
if na(envHigh)
    envHigh := line.new(bar_index, pressureUpperEnvelope, bar_index + 1, pressureUpperEnvelope, extend = extend.right, color = color.new(bullCol, 85), width = 1)
    envLow := line.new(bar_index, pressureLowerEnvelope, bar_index + 1, pressureLowerEnvelope, extend = extend.right, color = color.new(bearCol, 85), width = 1)
    envFill := linefill.new(envHigh, envLow, color.new(neutralCol, 92))
else
    line.set_xy1(envHigh, bar_index, pressureUpperEnvelope)
    line.set_xy2(envHigh, bar_index + 1, pressureUpperEnvelope)
    line.set_xy1(envLow, bar_index, pressureLowerEnvelope)
    line.set_xy2(envLow, bar_index + 1, pressureLowerEnvelope)
    linefill.set_color(envFill, showEnvelope ? color.new(stateColor, compression ? 92 : 88) : color.new(chart.bg_color, 100))

bgcolor(showBackground ? color.new(stateColor, 93) : na, title = "Pressure Background")

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------
var table dash = table.new(position.top_right, 2, 16, bgcolor = color.new(color.rgb(8, 10, 17), 0), frame_color = color.new(chart.fg_color, 75), frame_width = 1, border_color = color.new(chart.fg_color, 90), border_width = 1)
if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Axis", text_color = chart.fg_color, bgcolor = color.new(color.rgb(25, 30, 44), 0), text_size = f_size(dashSize))
    table.cell(dash, 1, 0, state, text_color = stateColor, bgcolor = color.new(color.rgb(25, 30, 44), 0), text_size = f_size(dashSize))
    table.cell(dash, 0, 1, "Pressure", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 1, str.tostring(pressure, "#.0"), text_color = pressureColor, text_size = f_size(dashSize))
    table.cell(dash, 0, 2, "Signal", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 2, str.tostring(pressureSignal, "#.0"), text_color = signalColor, text_size = f_size(dashSize))
    table.cell(dash, 0, 3, "Slope", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 3, str.tostring(pressureSlope, "#.0"), text_color = stateColor, text_size = f_size(dashSize))
    table.cell(dash, 0, 4, "Momentum", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 4, str.tostring(pressureMomentum, "#.0"), text_color = rankColor, text_size = f_size(dashSize))
    table.cell(dash, 0, 5, "Z Score", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 5, str.tostring(pressureZ, "#.##"), text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 0, 6, "Rank", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 6, str.tostring(pressureRank, "#.0") + "%", text_color = rankColor, text_size = f_size(dashSize))
    table.cell(dash, 0, 7, "MA", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 7, str.tostring(refMa, format.mintick), text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 0, 8, "State Age", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 8, str.tostring(stateHold), text_color = stateColor, text_size = f_size(dashSize))
    table.cell(dash, 0, 9, "Bias", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 9, bullishBias ? "Bullish" : bearishBias ? "Bearish" : "Neutral", text_color = bullishBias ? bullCol : bearishBias ? bearCol : neutralCol, text_size = f_size(dashSize))
    table.cell(dash, 0, 10, "Envelope", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 10, str.tostring(pressureRange, "#.0"), text_color = neutralCol, text_size = f_size(dashSize))
    table.cell(dash, 0, 11, "Stability", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 11, str.tostring(pressureStability, "#.0"), text_color = pressureStability > 50 ? bullCol : bearCol, text_size = f_size(dashSize))
    table.cell(dash, 0, 12, "Hold Bars", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 12, str.tostring(stateHold), text_color = stateColor, text_size = f_size(dashSize))
    table.cell(dash, 0, 13, "Flip", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 13, stateFlipUp ? "Up" : stateFlipDown ? "Down" : "None", text_color = stateFlipUp ? bullCol : stateFlipDown ? bearCol : neutralCol, text_size = f_size(dashSize))
    table.cell(dash, 0, 14, "Compression", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 14, compression ? "Yes" : "No", text_color = compression ? neutralCol : stateColor, text_size = f_size(dashSize))
    table.cell(dash, 0, 15, "Squeeze", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 15, str.tostring(squeezeScore, "#.0"), text_color = squeezeScore > 50 ? bullCol : bearCol, text_size = f_size(dashSize))

var table ribbon = table.new(position.bottom_center, 17, 2, frame_color = color.new(chart.fg_color, 82), frame_width = 1)
if showStateRibbon and barstate.islast
    int center = 8
    int active = int(math.round(center + pressureSignal / math.max(extremeLevel, 1.0) * center))
    active := int(math.min(math.max(active, 0), 16))
    for col = 0 to 16
        float dist = math.abs(col - center) / float(center)
        color cellCol = col < center ? color.new(bearCol, int(18 + dist * 60)) : color.new(bullCol, int(18 + dist * 60))
        string cellText = col == center ? "0" : col == active ? "•" : ""
        table.cell(ribbon, col, 0, col == center ? "Axis" : "", bgcolor = col == center ? color.new(neutralCol, 70) : color.new(chart.bg_color, 100), text_color = chart.fg_color)
        table.cell(ribbon, col, 1, cellText, bgcolor = cellCol, text_color = chart.fg_color)

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
bool reclaimUp = enableAlerts and barstate.isconfirmed and positiveFlip
bool reclaimDown = enableAlerts and barstate.isconfirmed and negativeFlip
bool extremeUpUnwind = enableAlerts and barstate.isconfirmed and pressure[1] >= upperBand and pressure < upperBand
bool extremeDownUnwind = enableAlerts and barstate.isconfirmed and pressure[1] <= lowerBand and pressure > lowerBand
bool pressureBiasUp = enableAlerts and barstate.isconfirmed and pressureSignal > upperWarn and pressure > pressureSignal
bool pressureBiasDown = enableAlerts and barstate.isconfirmed and pressureSignal < lowerWarn and pressure < pressureSignal
bool stateFlipUpAlert = enableAlerts and barstate.isconfirmed and stateFlipUp
bool stateFlipDownAlert = enableAlerts and barstate.isconfirmed and stateFlipDown
bool hotBidRelief = enableAlerts and barstate.isconfirmed and hotBid and pressureSignal < upperWarn
bool hotOfferRelief = enableAlerts and barstate.isconfirmed and hotOffer and pressureSignal > lowerWarn
bool squeezeReleaseAlert = enableAlerts and barstate.isconfirmed and compressionRelease and squeezeScore > 30

alertcondition(reclaimUp, "Axis Positive Flip", "Pressure signal has crossed above zero.")
alertcondition(reclaimDown, "Axis Negative Flip", "Pressure signal has crossed below zero.")
alertcondition(extremeUpUnwind, "Axis Upper Exhaustion", "Pressure has rolled down from an upper extreme.")
alertcondition(extremeDownUnwind, "Axis Lower Exhaustion", "Pressure has rolled up from a lower extreme.")
alertcondition(compressionRelease, "Axis Compression Release", "The pressure regime has moved out of compression.")
alertcondition(pressureBiasUp, "Axis Positive Bias", "Pressure has expanded into positive territory.")
alertcondition(pressureBiasDown, "Axis Negative Bias", "Pressure has expanded into negative territory.")
alertcondition(stateFlipUpAlert, "Axis State Flip Up", "The pressure state has shifted higher.")
alertcondition(stateFlipDownAlert, "Axis State Flip Down", "The pressure state has shifted lower.")
alertcondition(hotBidRelief, "Axis Hot Bid Relief", "Overheated bullish pressure is starting to cool.")
alertcondition(hotOfferRelief, "Axis Hot Offer Relief", "Overheated bearish pressure is starting to cool.")
alertcondition(squeezeReleaseAlert, "Axis Squeeze Release", "Compression has released with enough energy to matter.")
````

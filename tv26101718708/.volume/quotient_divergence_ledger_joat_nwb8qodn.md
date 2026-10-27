# Quotient Divergence Ledger [JOAT]

- url: https://www.tradingview.com/script/nwb8QOdN-Quotient-Divergence-Ledger-JOAT/
- type: indicator
- pine_id: PUB;14a3d35c57634d169989534c609d1566
- version: 1.0

## Description

[b]Quotient Divergence Ledger [JOAT][/b]

[b]Introduction[/b]

Quotient Divergence Ledger is an open-source divergence engine built on a signed participation wave. It tracks regular and hidden divergences, wave energy, directional streaks, and the quality of each divergence event so the trader can judge whether momentum disagreement is minor or meaningful.

[image]https://www.tradingview.com/x/OVxc1aYs/[/image]

[b]Core Concepts[/b]

[b]1. Signed participation wave[/b]

The oscillator blends directional volume participation, body pressure, and smoothed wave behavior into one normalized structure.

[b]2. Confirmed pivot-based divergence logic[/b]

Bullish and bearish divergences are only evaluated from confirmed oscillator pivots, reducing repaint behavior and maintaining clean historical structure.

[b]3. Divergence quality scoring[/b]

Each event is scored using oscillator displacement, price displacement, and wave energy. This helps separate weak visual divergence from stronger disagreement.

[b]Features[/b]

[list]
[*][b]Regular and hidden divergence modes[/b]
[*][b]Wave energy and stretch diagnostics[/b]
[*][b]Directional streak tracking[/b]
[*][b]Bottom ribbon and institutional dashboard[/b]
[*][b]Confirmed-bar divergence and regime alerts[/b]
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational purposes only. Divergence can persist or fail entirely in strong trend conditions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Quotient Divergence Ledger [JOAT]", overlay = false, max_lines_count = 400, max_labels_count = 240, calc_bars_count = 3000)

//------------------------------------------------------------------------------
// Quotient Divergence Ledger
// Signed participation wave with confirmed oscillator pivots, regular/hidden
// divergence classification, quality scoring, streak tracking, and an expanded
// institutional dashboard.
//------------------------------------------------------------------------------

string groupWave = "Wave"
string groupDivergence = "Divergence"
string groupStyle = "Style"
string groupDashboard = "Dashboard"
string groupAlerts = "Alerts"

int waveLength = input.int(20, "Wave Length", minval = 5, group = groupWave)
int smoothLength = input.int(5, "Wave Smoothing", minval = 1, group = groupWave)
int signalLength = input.int(8, "Signal Length", minval = 1, group = groupWave)
int energyLength = input.int(34, "Energy Length", minval = 5, group = groupWave)
float upperThreshold = input.float(24.0, "Upper Threshold", minval = 1.0, group = groupWave)
float lowerThreshold = input.float(-24.0, "Lower Threshold", maxval = -1.0, group = groupWave)
float exhaustionThreshold = input.float(40.0, "Exhaustion Threshold", minval = 5.0, maxval = 90.0, group = groupWave)

int pivotLength = input.int(3, "Pivot Length", minval = 2, maxval = 10, group = groupDivergence)
int minGap = input.int(6, "Minimum Divergence Gap", minval = 2, group = groupDivergence)
float minWaveMove = input.float(3.0, "Minimum Oscillator Move", minval = 0.0, step = 0.25, group = groupDivergence)
float minPriceMoveAtr = input.float(0.20, "Minimum Price Move ATR", minval = 0.0, step = 0.05, group = groupDivergence)
string divergenceMode = input.string("Both", "Divergence Mode", options = ["Regular", "Hidden", "Both"], group = groupDivergence)
bool showDivergenceLines = input.bool(true, "Show Divergence Lines", group = groupDivergence)
bool showSignalTags = input.bool(true, "Show Signal Tags", group = groupDivergence)
bool showPriceStructure = input.bool(true, "Show Price Structure Overlay", group = groupDivergence)

bool showSyntheticCandles = input.bool(false, "Plot Synthetic Candles", group = groupStyle)
bool colorCandles = input.bool(true, "Recolor Candles", group = groupStyle)
bool showBackground = input.bool(true, "Show Background", group = groupStyle)
bool showHistogram = input.bool(false, "Show Spread Histogram", group = groupStyle)
bool showEnergyBand = input.bool(true, "Show Energy Band", group = groupStyle)
bool showRibbon = input.bool(true, "Show Ribbon", group = groupStyle)

color bullCol = input.color(color.rgb(40, 227, 186), "Bullish", group = groupStyle, inline = "c1")
color bearCol = input.color(color.rgb(244, 102, 140), "", group = groupStyle, inline = "c1")
color neutralCol = input.color(color.rgb(111, 123, 151), "Neutral", group = groupStyle)
color cloudCol = input.color(color.rgb(118, 130, 164), "Cloud", group = groupStyle)
color energyCol = input.color(color.rgb(255, 184, 82), "Energy", group = groupStyle)

bool showDashboard = input.bool(true, "Show Dashboard", group = groupDashboard)
string dashSize = input.string("Normal", "Dashboard Size", options = ["Small", "Normal", "Large"], group = groupDashboard)
bool showTelemetry = input.bool(true, "Show Telemetry Plots", group = groupDashboard)

bool enableAlerts = input.bool(true, "Enable Alerts", group = groupAlerts)
int streakAlertLevel = input.int(5, "Streak Alert Level", minval = 2, maxval = 20, group = groupAlerts)

f_size(string sizeName) =>
    switch sizeName
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_mode_allows_regular() =>
    divergenceMode == "Regular" or divergenceMode == "Both"

f_mode_allows_hidden() =>
    divergenceMode == "Hidden" or divergenceMode == "Both"

f_clamp(float value, float lo, float hi) =>
    math.min(math.max(value, lo), hi)

f_state_text(bool overheatedUp, bool overheatedDown, bool constructiveUp, bool constructiveDown, bool absorptionUp, bool absorptionDown, bool compression) =>
    overheatedUp ? "Crowded Bid" : overheatedDown ? "Crowded Offer" : absorptionUp ? "Bid Absorption" : absorptionDown ? "Offer Absorption" : constructiveUp ? "Constructive Bid" : constructiveDown ? "Constructive Offer" : compression ? "Compression" : "Balanced"

f_div_score(float priceMoveAtr, float oscMove, float waveValue, float energyValue, bool hiddenDiv) =>
    float base = math.abs(priceMoveAtr) * 18.0 + oscMove * 2.4 + math.abs(waveValue) * 0.22 + energyValue * 0.12
    hiddenDiv ? base * 0.92 : base

//------------------------------------------------------------------------------
// Wave engine
//------------------------------------------------------------------------------
float candleRange = math.max(high - low, syminfo.mintick)
float closePosition = ((close - low) / candleRange - 0.5) * 2.0
float bodyPressure = (close - open) / candleRange
float signedParticipation = volume * closePosition
float signedBody = volume * bodyPressure
float buyVolume = close > open ? volume : volume * 0.35
float sellVolume = close < open ? volume : volume * 0.35
float smoothBuy = ta.ema(buyVolume, waveLength)
float smoothSell = ta.ema(sellVolume, waveLength)
float smoothSigned = ta.ema(signedParticipation, waveLength)
float smoothBody = ta.ema(signedBody, waveLength)
float smoothTotal = ta.ema(math.max(volume, 1.0), waveLength)
float rawWave = ((smoothBuy - smoothSell) / smoothTotal * 65.0) + (smoothSigned / smoothTotal * 22.0) + (smoothBody / smoothTotal * 13.0)
float deltaWave = ta.ema(rawWave, smoothLength)
float deltaSignal = ta.ema(deltaWave, signalLength)
float waveSpread = deltaWave - deltaSignal
float deltaSlope = deltaSignal - nz(deltaSignal[1])
float deltaCurvature = deltaSlope - nz(deltaSlope[1])
float deltaMomentum = ta.ema(ta.change(deltaSignal), smoothLength)
float waveEnergy = ta.ema(math.abs(deltaWave), energyLength)
int rankLength = math.max(waveLength, 10)
float deltaRank = ta.percentrank(deltaWave, rankLength)
float deltaZ = deltaWave / math.max(ta.stdev(deltaWave, rankLength), syminfo.mintick)
float stretch = deltaWave / math.max(waveEnergy, syminfo.mintick)
float exhaustionBand = exhaustionThreshold
float compressionBand = math.max(upperThreshold * 0.35, 6.0)

color waveColor = color.from_gradient(deltaWave, -100.0, 100.0, bearCol, bullCol)
color signalColor = color.from_gradient(deltaSignal, -100.0, 100.0, bearCol, bullCol)
color rankColor = color.from_gradient(deltaRank, 0.0, 100.0, bearCol, bullCol)
color energyColor = color.from_gradient(waveEnergy, 0.0, 80.0, cloudCol, energyCol)
color spreadColor = waveSpread >= 0 ? color.new(bullCol, 10) : color.new(bearCol, 10)

plotWave = plot(deltaWave, "Delta Wave", color = waveColor, linewidth = 3)
plotSignal = plot(deltaSignal, "Wave Signal", color = signalColor, linewidth = 2)
plotZero = plot(0, "Zero", color = color.new(neutralCol, 55))
plotUpper = plot(upperThreshold, "Upper Threshold", color = color.new(bullCol, 80))
plotLower = plot(lowerThreshold, "Lower Threshold", color = color.new(bearCol, 80))
plotUpperWarn = plot(upperThreshold * 0.5, "Upper Warning", color = color.new(bullCol, 92))
plotLowerWarn = plot(lowerThreshold * 0.5, "Lower Warning", color = color.new(bearCol, 92))
plotEnergy = plot(showEnergyBand ? waveEnergy : na, "Wave Energy", color = color.new(energyColor, 0), linewidth = 2)

fill(plotWave, plotZero, color.new(waveColor, 82))
fill(plotWave, plotSignal, color.new(waveSpread >= 0 ? bullCol : bearCol, 84))
fill(plotUpper, plotUpperWarn, color.new(bullCol, 94))
fill(plotLower, plotLowerWarn, color.new(bearCol, 94))

int bgAlpha = int(f_clamp(95.0 - math.abs(deltaWave) * 0.10 - waveEnergy * 0.10, 82.0, 96.0))
bgcolor(showBackground ? color.new(waveColor, bgAlpha) : na, title = "Wave Background")

color candleColor = colorCandles ? waveColor : na
barcolor(candleColor)

//------------------------------------------------------------------------------
// Regime telemetry
//------------------------------------------------------------------------------
bool waveOverheatedUp = deltaWave >= upperThreshold
bool waveOverheatedDown = deltaWave <= lowerThreshold
bool waveConstructiveUp = deltaWave > 0 and deltaSlope >= 0
bool waveConstructiveDown = deltaWave < 0 and deltaSlope <= 0
bool waveAbsorptionUp = deltaWave > 0 and deltaSlope < 0 and deltaWave > upperThreshold * 0.35
bool waveAbsorptionDown = deltaWave < 0 and deltaSlope > 0 and deltaWave < lowerThreshold * 0.35
bool waveCompression = math.abs(deltaWave) < compressionBand and math.abs(deltaSlope) < 2.0
bool signalCrossUp = ta.crossover(deltaWave, deltaSignal)
bool signalCrossDown = ta.crossunder(deltaWave, deltaSignal)

string state = f_state_text(waveOverheatedUp, waveOverheatedDown, waveConstructiveUp, waveConstructiveDown, waveAbsorptionUp, waveAbsorptionDown, waveCompression)
color stateColor = waveOverheatedUp ? bullCol : waveOverheatedDown ? bearCol : waveConstructiveUp ? bullCol : waveConstructiveDown ? bearCol : neutralCol
float regimeScore = f_clamp(deltaWave * 0.45 + deltaSlope * 2.0 + stretch * 12.0, -100.0, 100.0)
color regimeColor = color.from_gradient(regimeScore, -100.0, 100.0, bearCol, bullCol)

var int bullStreak = 0
var int bearStreak = 0
bullStreak := deltaWave > 0 ? nz(bullStreak[1]) + 1 : 0
bearStreak := deltaWave < 0 ? nz(bearStreak[1]) + 1 : 0
int activeStreak = math.max(bullStreak, bearStreak)
string streakText = bullStreak > bearStreak ? "Bid " + str.tostring(bullStreak) : bearStreak > bullStreak ? "Offer " + str.tostring(bearStreak) : "Balanced"

float upperPressurePct = upperThreshold != 0 ? deltaWave / upperThreshold * 100.0 : 0.0
float lowerPressurePct = lowerThreshold != 0 ? deltaWave / math.abs(lowerThreshold) * 100.0 : 0.0
float exhaustionDistance = deltaWave > 0 ? exhaustionBand - deltaWave : exhaustionBand + deltaWave

//------------------------------------------------------------------------------
// Confirmed pivot engine
//------------------------------------------------------------------------------
float waveHighPivot = ta.pivothigh(deltaWave, pivotLength, pivotLength)
float waveLowPivot = ta.pivotlow(deltaWave, pivotLength, pivotLength)

var float lastOscHigh = na
var float lastOscLow = na
var float lastPriceHigh = na
var float lastPriceLow = na
var int lastHighIndex = na
var int lastLowIndex = na
var int bullRegularCount = 0
var int bearRegularCount = 0
var int bullHiddenCount = 0
var int bearHiddenCount = 0
var string lastDivType = "None"
var color lastDivColor = chart.fg_color
var float lastDivScore = na
var int lastDivBar = na
var line lastBullGuide = na
var line lastBearGuide = na

bool bullRegular = false
bool bearRegular = false
bool bullHidden = false
bool bearHidden = false
float bullDivScore = na
float bearDivScore = na
float bullPivotPlot = na
float bearPivotPlot = na

if not na(waveHighPivot)
    float pivotOsc = waveHighPivot
    float pivotPrice = high[pivotLength]
    int pivotIndex = bar_index - pivotLength
    if not na(lastOscHigh) and not na(lastPriceHigh)
        bool regularAllowed = f_mode_allows_regular()
        bool hiddenAllowed = f_mode_allows_hidden()
        float oscMove = math.abs(lastOscHigh - pivotOsc)
        bool enoughGap = (pivotIndex - lastHighIndex) >= minGap
        float priceMoveAtr = math.abs(pivotPrice - lastPriceHigh) / math.max(ta.atr(14)[pivotLength], syminfo.mintick)
        if regularAllowed and enoughGap and pivotPrice > lastPriceHigh and pivotOsc < lastOscHigh and oscMove >= minWaveMove and priceMoveAtr >= minPriceMoveAtr
            bearRegular := true
            bearRegularCount += 1
            bearDivScore := f_div_score(priceMoveAtr, oscMove, pivotOsc, waveEnergy[pivotLength], false)
            lastDivType := "Regular Bear"
            lastDivColor := bearCol
            lastDivScore := bearDivScore
            lastDivBar := pivotIndex
            bearPivotPlot := pivotOsc
            if showDivergenceLines
                if showPriceStructure
                    line.new(lastHighIndex, lastPriceHigh, pivotIndex, pivotPrice, color = bearCol, width = 2, force_overlay = true)
                line.new(lastHighIndex, lastOscHigh, pivotIndex, pivotOsc, color = bearCol, width = 2)
            if not na(lastBearGuide)
                line.delete(lastBearGuide)
            lastBearGuide := line.new(pivotIndex, pivotOsc, bar_index, pivotOsc, color = color.new(bearCol, 60), style = line.style_dotted, width = 1)
        if hiddenAllowed and enoughGap and pivotPrice < lastPriceHigh and pivotOsc > lastOscHigh and oscMove >= minWaveMove and priceMoveAtr >= minPriceMoveAtr
            bearHidden := true
            bearHiddenCount += 1
            bearDivScore := f_div_score(priceMoveAtr, oscMove, pivotOsc, waveEnergy[pivotLength], true)
            lastDivType := "Hidden Bear"
            lastDivColor := bearCol
            lastDivScore := bearDivScore
            lastDivBar := pivotIndex
            bearPivotPlot := pivotOsc
            if showDivergenceLines
                if showPriceStructure
                    line.new(lastHighIndex, lastPriceHigh, pivotIndex, pivotPrice, color = color.new(bearCol, 30), width = 2, style = line.style_dashed, force_overlay = true)
                line.new(lastHighIndex, lastOscHigh, pivotIndex, pivotOsc, color = color.new(bearCol, 30), width = 2, style = line.style_dashed)
            if not na(lastBearGuide)
                line.delete(lastBearGuide)
            lastBearGuide := line.new(pivotIndex, pivotOsc, bar_index, pivotOsc, color = color.new(bearCol, 72), style = line.style_dashed, width = 1)
    lastOscHigh := pivotOsc
    lastPriceHigh := pivotPrice
    lastHighIndex := pivotIndex

if not na(waveLowPivot)
    float pivotOsc = waveLowPivot
    float pivotPrice = low[pivotLength]
    int pivotIndex = bar_index - pivotLength
    if not na(lastOscLow) and not na(lastPriceLow)
        bool regularAllowed = f_mode_allows_regular()
        bool hiddenAllowed = f_mode_allows_hidden()
        float oscMove = math.abs(lastOscLow - pivotOsc)
        bool enoughGap = (pivotIndex - lastLowIndex) >= minGap
        float priceMoveAtr = math.abs(pivotPrice - lastPriceLow) / math.max(ta.atr(14)[pivotLength], syminfo.mintick)
        if regularAllowed and enoughGap and pivotPrice < lastPriceLow and pivotOsc > lastOscLow and oscMove >= minWaveMove and priceMoveAtr >= minPriceMoveAtr
            bullRegular := true
            bullRegularCount += 1
            bullDivScore := f_div_score(priceMoveAtr, oscMove, pivotOsc, waveEnergy[pivotLength], false)
            lastDivType := "Regular Bull"
            lastDivColor := bullCol
            lastDivScore := bullDivScore
            lastDivBar := pivotIndex
            bullPivotPlot := pivotOsc
            if showDivergenceLines
                if showPriceStructure
                    line.new(lastLowIndex, lastPriceLow, pivotIndex, pivotPrice, color = bullCol, width = 2, force_overlay = true)
                line.new(lastLowIndex, lastOscLow, pivotIndex, pivotOsc, color = bullCol, width = 2)
            if not na(lastBullGuide)
                line.delete(lastBullGuide)
            lastBullGuide := line.new(pivotIndex, pivotOsc, bar_index, pivotOsc, color = color.new(bullCol, 60), style = line.style_dotted, width = 1)
        if hiddenAllowed and enoughGap and pivotPrice > lastPriceLow and pivotOsc < lastOscLow and oscMove >= minWaveMove and priceMoveAtr >= minPriceMoveAtr
            bullHidden := true
            bullHiddenCount += 1
            bullDivScore := f_div_score(priceMoveAtr, oscMove, pivotOsc, waveEnergy[pivotLength], true)
            lastDivType := "Hidden Bull"
            lastDivColor := bullCol
            lastDivScore := bullDivScore
            lastDivBar := pivotIndex
            bullPivotPlot := pivotOsc
            if showDivergenceLines
                if showPriceStructure
                    line.new(lastLowIndex, lastPriceLow, pivotIndex, pivotPrice, color = color.new(bullCol, 30), width = 2, style = line.style_dashed, force_overlay = true)
                line.new(lastLowIndex, lastOscLow, pivotIndex, pivotOsc, color = color.new(bullCol, 30), width = 2, style = line.style_dashed)
            if not na(lastBullGuide)
                line.delete(lastBullGuide)
            lastBullGuide := line.new(pivotIndex, pivotOsc, bar_index, pivotOsc, color = color.new(bullCol, 72), style = line.style_dashed, width = 1)
    lastOscLow := pivotOsc
    lastPriceLow := pivotPrice
    lastLowIndex := pivotIndex

bool bullSignal = bullRegular or bullHidden
bool bearSignal = bearRegular or bearHidden

if bullSignal and showSignalTags
    string bullText = bullHidden ? "HB" : "RB"
    bullText := bullText + " " + str.tostring(nz(bullDivScore, 0.0), "#.0")
    label.new(bar_index - pivotLength, bullPivotPlot, bullText, color = color.new(chart.bg_color, 100), textcolor = bullCol, style = label.style_label_up, size = size.tiny)
if bearSignal and showSignalTags
    string bearText = bearHidden ? "HB" : "RB"
    bearText := bearText + " " + str.tostring(nz(bearDivScore, 0.0), "#.0")
    label.new(bar_index - pivotLength, bearPivotPlot, bearText, color = color.new(chart.bg_color, 100), textcolor = bearCol, style = label.style_label_down, size = size.tiny)

if not na(lastBullGuide)
    line.set_x2(lastBullGuide, bar_index)
if not na(lastBearGuide)
    line.set_x2(lastBearGuide, bar_index)

//------------------------------------------------------------------------------
// Ribbon and dashboard
//------------------------------------------------------------------------------
var table ribbon = table.new(position.bottom_center, 15, 2, frame_color = color.new(chart.fg_color, 85), frame_width = 1)
if showRibbon and barstate.islast
    int center = 7
    int active = int(math.round(center + f_clamp(deltaWave, -100.0, 100.0) / 100.0 * center))
    active := int(f_clamp(active, 0, 14))
    for col = 0 to 14
        float dist = math.abs(col - center) / float(center)
        color cellCol = col < center ? color.new(bearCol, int(20 + dist * 56)) : color.new(bullCol, int(20 + dist * 56))
        table.cell(ribbon, col, 0, col == center ? "0" : "", bgcolor = col == center ? color.new(neutralCol, 62) : color.new(chart.bg_color, 100), text_color = chart.fg_color)
        table.cell(ribbon, col, 1, col == active ? " " : "", bgcolor = cellCol)

var table dash = table.new(position.top_right, 2, 12, bgcolor = color.new(color.rgb(8, 10, 17), 0), frame_color = color.new(chart.fg_color, 75), frame_width = 1, border_color = color.new(chart.fg_color, 90), border_width = 1)
if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Quotient", text_color = chart.fg_color, bgcolor = color.new(color.rgb(25, 30, 44), 0), text_size = f_size(dashSize))
    table.cell(dash, 1, 0, state, text_color = stateColor, bgcolor = color.new(color.rgb(25, 30, 44), 0), text_size = f_size(dashSize))
    table.cell(dash, 0, 1, "Wave", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 1, str.tostring(deltaWave, "#.##"), text_color = waveColor, text_size = f_size(dashSize))
    table.cell(dash, 0, 2, "Signal", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 2, str.tostring(deltaSignal, "#.##"), text_color = signalColor, text_size = f_size(dashSize))
    table.cell(dash, 0, 3, "Spread", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 3, str.tostring(waveSpread, "#.##"), text_color = spreadColor, text_size = f_size(dashSize))
    table.cell(dash, 0, 4, "Slope / Curv", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 4, str.tostring(deltaSlope, "#.##") + " / " + str.tostring(deltaCurvature, "#.##"), text_color = regimeColor, text_size = f_size(dashSize))
    table.cell(dash, 0, 5, "Energy", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 5, str.tostring(waveEnergy, "#.##"), text_color = energyColor, text_size = f_size(dashSize))
    table.cell(dash, 0, 6, "Z / Rank", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 6, str.tostring(deltaZ, "#.##") + " | " + str.tostring(deltaRank, "#.0") + "%", text_color = rankColor, text_size = f_size(dashSize))
    table.cell(dash, 0, 7, "Stretch", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 7, str.tostring(stretch, "#.##"), text_color = regimeColor, text_size = f_size(dashSize))
    table.cell(dash, 0, 8, "Streak", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 8, streakText, text_color = bullStreak > bearStreak ? bullCol : bearStreak > bullStreak ? bearCol : chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 0, 9, "Last Div", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 9, lastDivType + " | " + (na(lastDivScore) ? "na" : str.tostring(lastDivScore, "#.0")), text_color = lastDivColor, text_size = f_size(dashSize))
    table.cell(dash, 0, 10, "Counts", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 10, str.tostring(bullRegularCount + bullHiddenCount) + " / " + str.tostring(bearRegularCount + bearHiddenCount), text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 0, 11, "Pressure", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 11, str.tostring(upperPressurePct, "#.0") + "% | ex " + str.tostring(exhaustionDistance, "#.1"), text_color = regimeColor, text_size = f_size(dashSize))


//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
bool bullRegularAlert = enableAlerts and barstate.isconfirmed and bullRegular
bool bearRegularAlert = enableAlerts and barstate.isconfirmed and bearRegular
bool bullHiddenAlert = enableAlerts and barstate.isconfirmed and bullHidden
bool bearHiddenAlert = enableAlerts and barstate.isconfirmed and bearHidden
bool zeroCrossUp = enableAlerts and barstate.isconfirmed and ta.crossover(deltaWave, 0)
bool zeroCrossDown = enableAlerts and barstate.isconfirmed and ta.crossunder(deltaWave, 0)
bool signalCrossUpAlert = enableAlerts and barstate.isconfirmed and signalCrossUp
bool signalCrossDownAlert = enableAlerts and barstate.isconfirmed and signalCrossDown
bool waveOverheatUp = enableAlerts and barstate.isconfirmed and waveOverheatedUp
bool waveOverheatDown = enableAlerts and barstate.isconfirmed and waveOverheatedDown
bool waveCompressionBreak = enableAlerts and barstate.isconfirmed and waveCompression[1] and not waveCompression
bool bullStreakAlert = enableAlerts and barstate.isconfirmed and bullStreak >= streakAlertLevel and bullStreak[1] < streakAlertLevel
bool bearStreakAlert = enableAlerts and barstate.isconfirmed and bearStreak >= streakAlertLevel and bearStreak[1] < streakAlertLevel
bool energyExpansionAlert = enableAlerts and barstate.isconfirmed and waveEnergy > exhaustionBand and waveEnergy[1] <= exhaustionBand

alertcondition(bullRegularAlert, "Quotient Regular Bullish Divergence", "A regular bullish divergence has been confirmed.")
alertcondition(bearRegularAlert, "Quotient Regular Bearish Divergence", "A regular bearish divergence has been confirmed.")
alertcondition(bullHiddenAlert, "Quotient Hidden Bullish Divergence", "A hidden bullish divergence has been confirmed.")
alertcondition(bearHiddenAlert, "Quotient Hidden Bearish Divergence", "A hidden bearish divergence has been confirmed.")
alertcondition(zeroCrossUp, "Quotient Cross Above Zero", "The delta wave has crossed above zero.")
alertcondition(zeroCrossDown, "Quotient Cross Below Zero", "The delta wave has crossed below zero.")
alertcondition(signalCrossUpAlert, "Quotient Signal Cross Up", "The wave has crossed above its signal.")
alertcondition(signalCrossDownAlert, "Quotient Signal Cross Down", "The wave has crossed below its signal.")
alertcondition(waveOverheatUp, "Quotient Overheated Bid", "The wave has reached an overheated bullish extreme.")
alertcondition(waveOverheatDown, "Quotient Overheated Offer", "The wave has reached an overheated bearish extreme.")
alertcondition(waveCompressionBreak, "Quotient Compression Release", "The wave has broken out of compression.")
alertcondition(bullStreakAlert, "Quotient Bull Streak", "Bullish wave persistence has reached the configured streak threshold.")
alertcondition(bearStreakAlert, "Quotient Bear Streak", "Bearish wave persistence has reached the configured streak threshold.")
alertcondition(energyExpansionAlert, "Quotient Energy Expansion", "Wave energy has expanded into an exhaustion regime.")
````

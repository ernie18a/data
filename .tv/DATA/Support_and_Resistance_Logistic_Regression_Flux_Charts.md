<!-- tradingview-pine-id: PUB;9d844269d6c9493594d64c11b59ebb81 -->
<!-- tradingviewscripts-format: 1 -->
# Support and Resistance Logistic Regression | Flux Charts

Source: https://www.tradingview.com/script/rS3xqWYx-Support-and-Resistance-Logistic-Regression-Flux-Charts/

## Description

💎 GENERAL OVERVIEW
Introducing our new Logistic Regression Support / Resistance indicator! This tool leverages advanced statistical modeling "Logistic Regressions" to identify and project key price levels where the market is likely to find support or resistance. For more information about the process, please check the "HOW DOES IT WORK ?" section.

[image]https://www.tradingview.com/x/KyB9SynQ/[/image]

Logistic Regression Support / Resistance Features :

[*]Intelligent S/R Identification: The indicator uses a logistic regression model to intelligently identify and plot significant support and resistance levels.
[*]Predictive Probability: Each identified level comes with a calculated probability, indicating how likely it is to act as a true support or resistance based on historical data.
[*]Retest & Break Labels: The indicator clearly marks on your chart when a detected support or resistance level is retested (price touches and respects the level) or broken (price decisively crosses through the level).
[*]Alerts: Real-time alerts for support retests, resistance retests, support breaks, and resistance breaks.
[*]Customizable: You can change support & resistance line style, width and colors.

🚩UNIQUENESS
What makes this indicator truly unique is its application of logistic regression to the concept of support and resistance. Instead of merely identifying historical highs and lows, our indicator uses a statistical model to predict the future efficacy of these levels. It analyzes underlying market conditions (like RSI and body size at pivot formation) to assign a probability to each potential S/R zone. This predictive insight, combined with dynamic, real-time labeling of retests and breaks, provides a more robust and adaptive understanding of market structure than traditional, purely historical methods.

📌HOW DOES IT WORK ?

The Logistic Regression Support / Resistance indicator operates in several key steps:

[*]First, it identifies significant pivot highs and lows on the chart based on a user-defined "Pivot Length." These pivots are potential areas of support or resistance.

[*]For each detected pivot, the indicator extracts relevant market data at that specific point, including the RSI (Relative Strength Index) and the Body Size (the absolute difference between the open and close price of the candle). These serve as input features for the model.

[*]The core of the indicator lies in its logistic regression model. This model is continuously trained on past pivot data and their subsequent behavior (i.e., whether they were "respected" as support/resistance multiple times). It learns the relationship between the extracted features (RSI, Body Size) and the likelihood of a pivot becoming a significant S/R level.

[*]When a new pivot is identified, the model uses its learned insights to calculate a prediction value—a probability (from 0 to 1) that this specific pivot will act as a strong support or resistance.

[*]If the calculated probability exceeds a user-defined "Probability Threshold," the pivot is designated a "Regression Pivot" and drawn on the chart as a support or resistance line. The indicator then actively tracks how price interacts with these levels, displaying "R" labels for retests when the price bounces off the level and "B" labels for breaks when the price closes beyond it.

[image]https://www.tradingview.com/x/5zKmLHjO/[/image]

⚙️SETTINGS

1. General Configuration
Pivot Length: This setting defines the number of bars used to determine a significant high or low for pivot detection.

Target Respects: This input specifies how many times a level must be "respected" by price action for it to be considered a strong support or resistance level by the underlying model.

Probability Threshold: This is the minimum probability output from the logistic regression model for a detected pivot to be considered a valid support or resistance level and be plotted on the chart.

2. Style

Show Prediction Labels: Enable or disable labels that display the calculated probability of a newly identified regression S/R level.

Show Retests: Toggle the visibility of "R" labels on the chart, which mark instances where price has retested a support or resistance level.

Show Breaks: Toggle the visibility of "B" labels on the chart, which mark instances where price has broken through a support or resistance level.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © fluxchart
//
//@version=6

const bool DEBUG = false
const int retestCooldown = 3

indicator("Support and Resistance Logistic Regression | Flux Charts", shorttitle ="S&R (Logistic Regression) | Flux Charts",  overlay = true, max_lines_count = 500, max_labels_count = 500)

pivotLength = input.int(14, "Pivot Length", group = "General Configuration", tooltip = "This setting defines the number of bars used to determine a significant high or low for pivot detection.", minval=0,  display = display.none)
targetRespects = input.int(3, "Target Respects", group = "General Configuration", tooltip = "This input specifies how many times a level must be retested by price action for it to be considered a strong support or resistance level by the underlying model.\nHigher settings will result in less zones detected.", display = display.none)
probabilityThreshold = input.float(0.7, "Probability Threshold", step=0.05, minval=0.001, maxval=1., group = "General Configuration", tooltip = "This is the minimum probability output from the logistic regression model for a detected pivot to be considered a valid support or resistance level and be plotted on the chart.\nHigher settings will result in less zones rendered.", display = display.none)
hideFarLines = input.bool(true, "Hide Far Lines", group = "General Configuration")

showAllPivots = DEBUG ? input.bool(false, "[DBG] Show All Pivots", group = "General Configuration", display = display.none) : false
showRespectedPivots = DEBUG ? input.bool(false, "[DBG] Show Respected Pivots", group = "General Configuration", display = display.none) : false
showRegressionPivots = DEBUG ? input.bool(true, "[DBG] Show Regression Pivots", group = "General Configuration", display = display.none) : true

showPredictionLabels = input.bool(true, "Show Prediction Labels", group = "Style", display = display.none)
showRetests = input.bool(false, "Show Retests", group = "Style", display = display.none)
showBreaks = input.bool(false, "Show Breaks", group = "Style", display = display.none)
lineStyle = input.string("____", "    ", options = ["____", "----", "...."], group = "Style", inline = "s1", display = display.none)
lineWidth = input.int(3, "Width", [1,2,3], group = "Style", inline = "s1", display = display.none)
supportColor = input.color(#089981, "Lines & Labels", group = "Style", inline = "s2")
resistanceColor = input.color(#f23645, "", group = "Style", inline = "s2")
textColorSupport = input.color(color.white, "Text", group = "Style", inline = "s3")
textColorResistance = input.color(color.white, "", group = "Style", inline = "s3")

type srLine
    bool isSupport
    float level
    int startTime
    int startIndex
    int endTime
    int endIndex
    int timesRespected

    float detectedRSI
    float detectedBodySize
    bool detectedByRegression
    int latestRetestIndex = 0
    float detectedPrediction

    line srLine
    label predictionLabel

var allPivots = array.new<srLine>()
var respectedPivots = array.new<srLine>()
var regressionPivots = array.new<srLine>()

//#region Logistic Regression
const float lr = 0.008

logistic(x1, x2, y0, y1, y2, logisticTimes) =>
    exponent = math.exp(-(y0 + y1 * x1 + y2 * x2))
    logRtn = 1.0 / (1.0 + exponent)

    logRtn

loss(y, p) =>
    -y * math.log(p) - (1 - y) * math.log(1 - p)

predict(_isSupport, _level, _rsi, _bodySize) =>
    float baseBias = 1.0
    float rsiBias = 1.0
    float bodySizeBias = 1.0

    typeSize = 0
    for curRS in allPivots
        if curRS.isSupport == _isSupport
            typeSize += 1
    
    float _logRes = 0.0
    logisticTimes = 0

    if typeSize > 0
        for curRS in allPivots
            if curRS.isSupport != _isSupport
                continue
            
            isRespected = curRS.timesRespected >= targetRespects ? 1.0 : -1.0
            p = logistic(curRS.detectedRSI, curRS.detectedBodySize, baseBias, rsiBias, bodySizeBias, logisticTimes)
            logisticTimes += 1


            loss = loss(isRespected, p)

            rsiBias -= lr * (p + loss) * curRS.detectedRSI
            bodySizeBias -= lr * (p + loss) * curRS.detectedBodySize

            _logRes := logistic(_rsi, _bodySize, baseBias, rsiBias, bodySizeBias, logisticTimes)
            logisticTimes += 1
    
    _logRes
//#endregion

//#region Time By Bar
var timeByBar = array.new<int>()
if barstate.isconfirmed
    if timeByBar.size() == 0
        while timeByBar.size() != bar_index
            timeByBar.push(0)
    timeByBar.push(time)

getTimeByBar (barIndex) =>
    if timeByBar.size() <= barIndex
        time
    else
        timeByBar.get(barIndex)
//#endregion

pivotHigh = ta.pivothigh(pivotLength, pivotLength)
pivotLow = ta.pivotlow(pivotLength, pivotLength)

rsi = ta.rsi(close, pivotLength)
rsi := nz(rsi, 0)
bodySize = math.abs(close - open)

pivotTime = time[pivotLength]
pivotIndex = bar_index[pivotLength]
pivotRSI = rsi[pivotLength]
pivotBodySize = bodySize[pivotLength]

atr = ta.atr(pivotLength)

if (not na(pivotHigh))
    _pivotRSIBinary = pivotRSI > 50 ? 1 : -1
    _pivotBodySizeBinary = pivotBodySize > atr ? 1 : -1
    newPivot = srLine.new(false, pivotHigh, pivotTime, pivotIndex, na, na, 0, _pivotRSIBinary, _pivotBodySizeBinary)
    allPivots.push(newPivot)
    predVal = predict(false, pivotHigh, _pivotRSIBinary, _pivotBodySizeBinary)
    //label.new(pivotIndex, high, str.tostring(predVal))
    if predVal >= probabilityThreshold
        newPivot.detectedByRegression := true
        newPivot.detectedPrediction := predVal
        regressionPivots.push(newPivot)

if (not na(pivotLow))
    _pivotRSIBinary = pivotRSI > 50 ? 1 : -1
    _pivotBodySizeBinary = pivotBodySize > atr ? 1 : -1
    newPivot = srLine.new(true, pivotLow, pivotTime, pivotIndex, na, na, 0, _pivotRSIBinary, _pivotBodySizeBinary)
    allPivots.push(newPivot)
    predVal = predict(true, pivotLow, _pivotRSIBinary, _pivotBodySizeBinary)
    if predVal >= probabilityThreshold
        newPivot.detectedByRegression := true
        newPivot.detectedPrediction := predVal
        regressionPivots.push(newPivot)

updateSRLine (srLine sr) =>
    _retest = false
    _break = false
    if na(sr.endIndex)
        if sr.isSupport
            if low < sr.level
                if close > sr.level
                    if sr.detectedByRegression and bar_index > sr.latestRetestIndex + retestCooldown
                        _retest := true
                        sr.latestRetestIndex := bar_index
                        if showRetests
                            label.new(time, sr.level, "R", xloc = xloc.bar_time, yloc = yloc.belowbar, textcolor = textColorSupport, color = supportColor, style = label.style_label_up,  size=size.tiny)
                    sr.timesRespected += 1
                    if sr.timesRespected == targetRespects
                        respectedPivots.push(sr)
                else
                    if sr.detectedByRegression
                        _break := true
                        if showBreaks
                            label.new(time, sr.level, "B", xloc = xloc.bar_time, yloc = yloc.abovebar, textcolor = color.white, color = color.blue, style = label.style_label_down,  size=size.tiny)
                    sr.endIndex := bar_index
                    sr.endTime := time
        else
            if high > sr.level
                if close < sr.level
                    if sr.detectedByRegression and bar_index > sr.latestRetestIndex + retestCooldown
                        _retest := true
                        sr.latestRetestIndex := bar_index
                        if showRetests
                            label.new(time, sr.level, "R", xloc = xloc.bar_time, yloc = yloc.abovebar, textcolor = textColorResistance, color = resistanceColor, style = label.style_label_down,  size=size.tiny)
                    sr.timesRespected += 1
                    if sr.timesRespected == targetRespects
                        respectedPivots.push(sr)
                else
                    if sr.detectedByRegression
                        _break := true
                        if showBreaks
                            label.new(time, sr.level, "B", xloc = xloc.bar_time, yloc = yloc.belowbar, textcolor = color.white, color = color.blue, style = label.style_label_up,  size=size.tiny)
                    sr.endIndex := bar_index
                    sr.endTime := time
    [_retest, _break]

destroySRLine (srLine sr) =>
    line.delete(sr.srLine)
    sr.srLine := na
    label.delete(sr.predictionLabel)
    sr.predictionLabel := na

renderSRLine (srLine sr, string renderType) =>
    _shouldRender = true
    if hideFarLines and na(sr.endTime) and (math.abs(close - sr.level) > atr * 7)
        _shouldRender := false
    if _shouldRender
        _endTime = nz(sr.endTime, time)
        _endIndex = nz(sr.endIndex, bar_index)
        renderColor = sr.isSupport ? color.green : color.red
        if renderType == "Respected"
            renderColor := sr.isSupport ? color.yellow : color.purple
        if renderType == "Regression"
            renderColor := sr.isSupport ? supportColor : resistanceColor
        
        if na(sr.srLine)
            sr.srLine := line.new(sr.startTime, sr.level, _endTime, sr.level, xloc = xloc.bar_time, color = renderColor, width = lineWidth, style = lineStyle == "----" ? line.style_dashed : lineStyle == "____" ? line.style_solid : line.style_dotted)
            if showPredictionLabels
                if not sr.isSupport
                    sr.predictionLabel := label.new(sr.startTime, sr.level, str.tostring(sr.detectedPrediction * 100, format.percent), xloc = xloc.bar_time, textcolor = resistanceColor, color = color.new(color.white, 100), style = label.style_label_down)
                else
                    sr.predictionLabel := label.new(sr.startTime, sr.level, str.tostring(sr.detectedPrediction * 100, format.percent), xloc = xloc.bar_time, textcolor = supportColor, color = color.new(color.white, 100), style = label.style_label_up)
            sr.predictionLabel.set_x(na(sr.endIndex) ? getTimeByBar(_endIndex) : getTimeByBar((sr.startIndex + _endIndex) / 2))
        else
            sr.srLine.set_x2(_endTime)
            if showPredictionLabels
                sr.predictionLabel.set_x(na(sr.endIndex) ? getTimeByBar(_endIndex) : getTimeByBar((sr.startIndex + _endIndex) / 2))
    else
        destroySRLine(sr)
    true

_supportRetestDetected = false
_supportBreakDetected = false
_resistanceRetestDetected = false
_resistanceBreakDetected = false

if barstate.isconfirmed
    for curSR in allPivots
        [_retest, _break] = updateSRLine(curSR)
        if curSR.isSupport
            _supportRetestDetected := _retest ? true : _supportRetestDetected
            _supportBreakDetected := _break ? true : _supportBreakDetected
        else
            _resistanceRetestDetected := _retest ? true : _resistanceRetestDetected
            _resistanceBreakDetected := _break ? true : _resistanceBreakDetected
        if showAllPivots
            destroySRLine(curSR)
            renderSRLine(curSR, "All")

if barstate.islast
    if showRespectedPivots
        for curSR in respectedPivots
            destroySRLine(curSR)
            renderSRLine(curSR, "Respected")
    if showRegressionPivots
        for curSR in regressionPivots
            destroySRLine(curSR)
            renderSRLine(curSR, "Regression")

alertcondition(_supportRetestDetected, "Support Retest")
alertcondition(_resistanceRetestDetected, "Resistance Retest")
alertcondition(_supportBreakDetected, "Support Break")
alertcondition(_resistanceBreakDetected, "Resistance Break")
````

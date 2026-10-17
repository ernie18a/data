# kNN Market Architecture [LuxAlgo] - Modified by FullPotato

- url: https://www.tradingview.com/script/JQrWA2D0-kNN-Market-Architecture-LuxAlgo-Modified-by-FullPotato/
- type: indicator
- pine_id: PUB;a2470ad5ca59438ab2c97c37bf643ab8
- version: 6.0

## Description

This indicator was created by LuxAlgo, however it was modified by FullPotato and is meant to be used only with the ST function of the indicator and the description will only focus on the ST function. 

This indicator is a market structure / trend architecture tool that automatically detects and classifies swing highs and lows a

ST = Short-Term

It then uses a simple k-nearest neighbors (kNN) scoring system to decide whether a newly detected pivot is structurally important enough to display.

Main functions:

[b]Dynamic Swing(structure) Detection[/b]
The script uses pivot highs/lows, but the pivot length is adaptive. It changes based on volatility using ATR, meaning:

Higher volatility → larger structure spacing

Lower volatility → tighter structure spacing

So the indicator self-adjusts to market conditions.

Each level draws swing labels, horizontal structure line, BOS labels when broken & highlights candles that close beyond the ST structure w/ more volume then prior candle (use discretion when there is a spike in volume)


[b]kNN Filtering (Core Feature)[/b]

This is the “AI-style” part. Every pivot stores: relative ATR, relative volume, structural score, 
volatility, volume, then finds nearest neighbors, averages their scores, checks if confidence exceeds threshold.


Purpose - filter out weak/noisy pivots & keep only pivots that resemble historically important structure.


[b] Structure Lines[/b]
When a valid pivot forms it creates a horizontal line extending right

Bullish structure: created from pivot highs

Bearish structure: created from pivot lows



[b]Break of Structure (BOS)[/b]
The script detects when price closes beyond an ST structure line.

Bull BOS:
close > activeSTHigh

Bear BOS:
close < activeSTLow

But there are extra filters:
1. Candle must close strongly beyond the level, meaning the close must finish near candle high (momentum)

Default threshold:
60%

2. Volume filter
Signal candle must have equal to or more volume then prior candle. Be weary of excess volume (volume spikes)


Automatic Line Termination
When structure breaks the line stops extending and a BOS label is placed at midpoint & then that line becomes inactive.

Candle Bias Coloring
Candles are colored based on position between the latest structure high and low. This creates a gradient. If price exceeds structure; above high → full green, below low → full red.



Special BOS Candle Coloring
Overrides normal coloring

Black candle logic:
After bullish BOS, first bearish candle becomes black.
After bearish BOS, first bullish candle becomes black

This likely helps identify failed continuation, momentum loss, potential reversal after breakout

Alerts
The script includes alerts for:
stBullBOS or stBearBOS
So it alerts on ST break of structure events.

Overall Purpose
This indicator is essentially:

adaptive market structure detection

multi-timeframe swing mapping

breakout validation

trend bias visualization

machine-learning-style pivot filtering


[b]It’s designed to help identify:[/b]

important swing points

valid structure breaks

trend continuation

momentum quality

while filtering out weaker/noisy pivots using volatility + volume similarity scoring.



These signals pair really well with low volume node reversals and break throughs.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=6
indicator("kNN Market Architecture [LuxAlgo]", "LuxAlgo - kNN Market Architecture - Modified by FullPotato", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500, max_bars_back = 500)

//---------------------------------------------------------------------------------------------------------------------
// Constants & Inputs
//---------------------------------------------------------------------------------------------------------------------
color BULL_COLOR    = #089981
color BEAR_COLOR    = #f23645
color NEUTRAL_COLOR = #787b86

sensitivityInput  = input.int(5, "Structure Sensitivity", minval = 1, maxval = 10, group = "Dynamic Engine")
autoSensitivity   = input.bool(true, "Auto-Adjust Sensitivity", group = "Dynamic Engine")

knnKInput     = input.int(5, "k-Nearest Neighbors", minval = 1, maxval = 20, group = "kNN Classifier")
minConfidence = input.float(0.4, "Confidence Threshold", minval = 0.0, maxval = 1.0, step = 0.1, group = "kNN Classifier")

showST            = input.bool(true, "Short-Term Lines (ST)", group = "Visual Hierarchy")
showMT            = input.bool(true, "Medium-Term Lines (MT)", group = "Visual Hierarchy")
showLT            = input.bool(true, "Long-Term Lines (LT)", group = "Visual Hierarchy")
colorCandlesInput = input.bool(true, "Color Candles by Bias", group = "Visual Hierarchy")

biasSourceInput   = input.string("Auto", "Bias Source", options = ["Auto", "LT", "MT", "ST", "None"], group = "Visual Hierarchy")
infoLabelSize     = input.string("Small", "Info Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = "Visual Hierarchy")

minCloseBeyondPct = input.float(
     60.0,
     title = "Signal Candle Min % Close Beyond",
     minval = 0.0,
     maxval = 100.0,
     step = 1.0,
     group = "Visual Hierarchy")

filterLowerVolume = input.bool(
     true,
     title = "Signal Volume Must Be >= Prior Candle Volume",
     group = "Visual Hierarchy")

enableMaxVolumeFilter = input.bool(
     true,
     title = "Enable Max Signal Volume % Filter",
     group = "Visual Hierarchy")

stBosVolLookback = input.int(
     5,
     title = "ST BOS Prior Candle Volume Lookback",
     minval = 1,
     group = "Visual Hierarchy")

maxVolumePercent = input.float(
     300.0,
     title = "Max Signal Volume % Of Lowest Prior Candle",
     minval = 100.0,
     step = 1.0,
     group = "Visual Hierarchy")

enablePriorBiasFilter = input.bool(
     true,
     title = "Require Prior Candle To Be Opposite/Neutral Bias",
     group = "Visual Hierarchy")

enableSameColorFilter = input.bool(
     true,
     title = "Invalidate BOS After 3 Same-Color Candles",
     group = "Visual Hierarchy")

stLabelsInput = input.bool(true, "Show ST Icons", inline = "ST", group = "Visual Hierarchy")
stLabelInput  = input.string("•", "Icon", inline = "ST", group = "Visual Hierarchy")
stSizeInput   = input.string("Tiny", "Size", options = ["Tiny", "Small", "Normal", "Large"], inline = "ST", group = "Visual Hierarchy")
stBOSInput    = input.string("Tiny", "ST BOS Size", options = ["None", "Tiny", "Small", "Normal", "Large"], inline = "ST", group = "Visual Hierarchy")

mtLabelsInput = input.bool(false, "Show MT Icons", inline = "MT", group = "Visual Hierarchy")
mtLabelInput  = input.string("•", "Icon", inline = "MT", group = "Visual Hierarchy")
mtSizeInput   = input.string("Small", "Size", options = ["Tiny", "Small", "Normal", "Large"], inline = "MT", group = "Visual Hierarchy")
mtBOSInput    = input.string("None", "MT BOS Size", options = ["None", "Tiny", "Small", "Normal", "Large"], inline = "MT", group = "Visual Hierarchy")

ltLabelsInput = input.bool(true, "Show LT Icons", inline = "LT", group = "Visual Hierarchy")
ltLabelInput  = input.string("●", "Icon", inline = "LT", group = "Visual Hierarchy")
ltSizeInput   = input.string("Normal", "Size", options = ["Tiny", "Small", "Normal", "Large"], inline = "LT", group = "Visual Hierarchy")
ltBOSInput    = input.string("Normal", "LT BOS Size", options = ["None", "Tiny", "Small", "Normal", "Large"], inline = "LT", group = "Visual Hierarchy")

offsetMultiplier = input.float(0.8, "Label Offset Multiplier", minval = 0.0, maxval = 5.0, step = 0.1, group = "Visual Hierarchy")

//---------------------------------------------------------------------------------------------------------------------
// Types
//---------------------------------------------------------------------------------------------------------------------
type StructurePoint
    float price
    int index
    string term
    float feat1
    float feat2
    float score

method getDistance(StructurePoint p1, StructurePoint p2) =>
    math.abs(p1.feat1 - p2.feat1) + math.abs(p1.feat2 - p2.feat2)

//---------------------------------------------------------------------------------------------------------------------
// Engine
//---------------------------------------------------------------------------------------------------------------------
float atr = ta.atr(200)
float avgAtr = ta.sma(atr, 200)

float volRatio = atr / nz(avgAtr, atr)
float smoothedRatio = ta.ema(volRatio, 50)

float dynamicMultiplier = autoSensitivity ? math.pow(nz(smoothedRatio, 1.0), 1.5) : 1.0

int baseLen = math.max(3, math.round((11 - sensitivityInput) * dynamicMultiplier))

f_detect_pivots(len) =>
    ph = ta.pivothigh(high, len, len)
    pl = ta.pivotlow(low, len, len)
    [ph, pl]

f_knn_score(StructurePoint current, array<StructurePoint> history, int k) =>
    float score = 0.0

    if history.size() > k
        array<float> distances = array.new_float()

        for p in history
            distances.push(current.getDistance(p))

        array<int> ranks = array.new_int()

        for i = 0 to history.size() - 1
            ranks.push(i)

        for i = 0 to k - 1
            for j = i + 1 to history.size() - 1
                if distances.get(ranks.get(j)) < distances.get(ranks.get(i))
                    temp = ranks.get(i)
                    ranks.set(i, ranks.get(j))
                    ranks.set(j, temp)

        float sumScore = 0.0

        for i = 0 to k - 1
            sumScore += history.get(ranks.get(i)).score

        score := sumScore / k
    else
        score := 0.5

    score

//---------------------------------------------------------------------------------------------------------------------
// Variables
//---------------------------------------------------------------------------------------------------------------------
var stHistoryHigh = array.new<StructurePoint>()
var stHistoryLow  = array.new<StructurePoint>()

var mtHistoryHigh = array.new<StructurePoint>()
var mtHistoryLow  = array.new<StructurePoint>()

var ltHistoryHigh = array.new<StructurePoint>()
var ltHistoryLow  = array.new<StructurePoint>()

var line activeSTHigh = na
var line activeSTLow  = na

var line activeMTHigh = na
var line activeMTLow  = na

var line activeLTHigh = na
var line activeLTLow  = na

var float lastSTHigh = na
var float lastSTLow  = na

var float lastMTHigh = na
var float lastMTLow  = na

var float lastLTHigh = na
var float lastLTLow  = na

atr14 = ta.atr(14)

float relVol = volume / ta.sma(volume, 100)
float relATR = atr14 / ta.sma(atr14, 100)

string activeTerm =
     biasSourceInput == "None" ? "" :
     biasSourceInput != "Auto" ? biasSourceInput :
     showLT ? "LT" :
     showMT ? "MT" :
     showST ? "ST" : ""

//---------------------------------------------------------------------------------------------------------------------
// Helpers
//---------------------------------------------------------------------------------------------------------------------
f_parse_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

//---------------------------------------------------------------------------------------------------------------------
// Structure Processing
//---------------------------------------------------------------------------------------------------------------------
f_process_term(
     float ph,
     float pl,
     int len,
     string term,
     array<StructurePoint> hHigh,
     array<StructurePoint> hLow,
     line activeH,
     line activeL,
     bool showLines,
     bool showLabels) =>

    line outH = activeH
    line outL = activeL

    float visualOffset = atr14 * offsetMultiplier

    currentSize =
         term == "LT" ? f_parse_size(ltSizeInput) :
         term == "MT" ? f_parse_size(mtSizeInput) :
         f_parse_size(stSizeInput)

    currentText =
         term == "LT" ? ltLabelInput :
         term == "MT" ? mtLabelInput :
         stLabelInput

    currentStyle =
         term == "LT" ? line.style_solid :
         term == "MT" ? line.style_dashed :
         line.style_dotted

    if not na(ph)
        current = StructurePoint.new(ph, bar_index[len], term, relATR[len], relVol[len], 1.0)

        bool isValid = f_knn_score(current, hHigh, knnKInput) >= minConfidence

        if isValid
            if showLabels
                label.new(bar_index[len], ph + visualOffset, currentText, style = label.style_none, textcolor = BULL_COLOR, size = currentSize)

            if showLines
                if not na(outH)
                    outH.delete()

                outH := line.new(bar_index[len], ph, bar_index, ph, color = BULL_COLOR, style = currentStyle)

        hHigh.push(current)

        if hHigh.size() > 100
            hHigh.shift()

    if not na(pl)
        current = StructurePoint.new(pl, bar_index[len], term, relATR[len], relVol[len], 1.0)

        bool isValid = f_knn_score(current, hLow, knnKInput) >= minConfidence

        if isValid
            if showLabels
                label.new(bar_index[len], pl - visualOffset, currentText, style = label.style_none, textcolor = BEAR_COLOR, size = currentSize)

            if showLines
                if not na(outL)
                    outL.delete()

                outL := line.new(bar_index[len], pl, bar_index, pl, color = BEAR_COLOR, style = currentStyle)

        hLow.push(current)

        if hLow.size() > 100
            hLow.shift()

    [outH, outL]

//---------------------------------------------------------------------------------------------------------------------
// ST
//---------------------------------------------------------------------------------------------------------------------
[stPH, stPL] = f_detect_pivots(baseLen)

[newSTH, newSTL] = f_process_term(
     stPH,
     stPL,
     baseLen,
     "ST",
     stHistoryHigh,
     stHistoryLow,
     activeSTHigh,
     activeSTLow,
     showST,
     stLabelsInput)

activeSTHigh := newSTH
activeSTLow  := newSTL

if not na(stPH)
    lastSTHigh := stPH

if not na(stPL)
    lastSTLow := stPL

//---------------------------------------------------------------------------------------------------------------------
// MT
//---------------------------------------------------------------------------------------------------------------------
mtLen = baseLen * 3

[mtPH, mtPL] = f_detect_pivots(mtLen)

[newMTH, newMTL] = f_process_term(
     mtPH,
     mtPL,
     mtLen,
     "MT",
     mtHistoryHigh,
     mtHistoryLow,
     activeMTHigh,
     activeMTLow,
     showMT,
     mtLabelsInput)

activeMTHigh := newMTH
activeMTLow  := newMTL

if not na(mtPH)
    lastMTHigh := mtPH

if not na(mtPL)
    lastMTLow := mtPL

//---------------------------------------------------------------------------------------------------------------------
// LT
//---------------------------------------------------------------------------------------------------------------------
ltLen = mtLen * 3

[ltPH, ltPL] = f_detect_pivots(ltLen)

[newLTH, newLTL] = f_process_term(
     ltPH,
     ltPL,
     ltLen,
     "LT",
     ltHistoryHigh,
     ltHistoryLow,
     activeLTHigh,
     activeLTLow,
     showLT,
     ltLabelsInput)

activeLTHigh := newLTH
activeLTLow  := newLTL

if not na(ltPH)
    lastLTHigh := ltPH

if not na(ltPL)
    lastLTLow := ltPL

//---------------------------------------------------------------------------------------------------------------------
// Candle Bias Detection
//---------------------------------------------------------------------------------------------------------------------
selectedHigh =
     activeTerm == "LT" ? lastLTHigh :
     activeTerm == "MT" ? lastMTHigh :
     activeTerm == "ST" ? lastSTHigh :
     na

selectedLow =
     activeTerm == "LT" ? lastLTLow :
     activeTerm == "MT" ? lastMTLow :
     activeTerm == "ST" ? lastSTLow :
     na

float factor =
     not na(selectedHigh) and not na(selectedLow) ?
     (close - selectedLow) / math.max(1e-6, selectedHigh - selectedLow) :
     0.5

bool bullishBias =
     close > selectedHigh or factor > 0.5

bool bearishBias =
     close < selectedLow or factor < 0.5

bool neutralBias =
     not bullishBias and not bearishBias

bool priorBullishBias = bullishBias[1]
bool priorBearishBias = bearishBias[1]
bool priorNeutralBias = neutralBias[1]

//---------------------------------------------------------------------------------------------------------------------
// BOS Detection
//---------------------------------------------------------------------------------------------------------------------
float lowestPriorVolume =
     ta.lowest(volume[1], stBosVolLookback)

float signalVolumePercentOfLowest =
     lowestPriorVolume > 0 ? (volume / lowestPriorVolume) * 100.0 : 999999.0

bool volumeFilterPassed =
     not enableMaxVolumeFilter or
     signalVolumePercentOfLowest <= maxVolumePercent

bool minVolumeFilterPassed =
     not filterLowerVolume or volume >= volume[1]

float candleRange = high - low

float bullClosePosition =
     candleRange > 0 ?
     ((close - low) / candleRange) * 100.0 :
     0.0

float bearClosePosition =
     candleRange > 0 ?
     ((high - close) / candleRange) * 100.0 :
     0.0

bool priorBiasValidForBull =
     not enablePriorBiasFilter or
     priorBearishBias or priorNeutralBias

bool priorBiasValidForBear =
     not enablePriorBiasFilter or
     priorBullishBias or priorNeutralBias

//---------------------------------------------------------------------------------------------------------------------
// SAME COLOR FILTER
//---------------------------------------------------------------------------------------------------------------------
bool bullCandle = close > open
bool bearCandle = close < open

bool prior3Bullish =
     bullCandle[1] and
     bullCandle[2] and
     bullCandle[3]

bool prior3Bearish =
     bearCandle[1] and
     bearCandle[2] and
     bearCandle[3]

bool invalidateBullBOS =
     enableSameColorFilter and
     bullCandle and
     prior3Bullish

bool invalidateBearBOS =
     enableSameColorFilter and
     bearCandle and
     prior3Bearish

bool rawBullBOS =
     not na(activeSTHigh) and
     close > line.get_y1(activeSTHigh) and
     bullClosePosition >= minCloseBeyondPct and
     volumeFilterPassed and
     minVolumeFilterPassed and
     priorBiasValidForBull and
     not invalidateBullBOS

bool rawBearBOS =
     not na(activeSTLow) and
     close < line.get_y1(activeSTLow) and
     bearClosePosition >= minCloseBeyondPct and
     volumeFilterPassed and
     minVolumeFilterPassed and
     priorBiasValidForBear and
     not invalidateBearBOS

bool stBullBOS =
     rawBullBOS and
     not rawBullBOS[1]

bool stBearBOS =
     rawBearBOS and
     not rawBearBOS[1]

bool blackAfterBullBOS =
     stBullBOS[1] and
     close < open

bool blackAfterBearBOS =
     stBearBOS[1] and
     close > open

//---------------------------------------------------------------------------------------------------------------------
// Line Termination
//---------------------------------------------------------------------------------------------------------------------
f_terminate_line(line l, color lineCol, string term, string bosSize) =>
    line out = l

    if not na(l)
        bool isHigh = lineCol == BULL_COLOR
        bool broken = isHigh ? close > l.get_y1() : close < l.get_y1()

        if broken
            l.set_x2(bar_index)

            midX = math.round(math.avg(l.get_x1(), bar_index))

            bosCol = isHigh ? BULL_COLOR : BEAR_COLOR

            lblStyle = isHigh ? label.style_label_down : label.style_label_up

            if bosSize != "None"
                label.new(
                     midX,
                     l.get_y1(),
                     term + " BOS",
                     style = lblStyle,
                     color = #00000000,
                     textcolor = bosCol,
                     size = f_parse_size(bosSize))

            out := na
        else
            l.set_x2(bar_index)

    out

activeSTHigh := f_terminate_line(activeSTHigh, BULL_COLOR, "ST", stBOSInput)
activeSTLow  := f_terminate_line(activeSTLow, BEAR_COLOR, "ST", stBOSInput)

activeMTHigh := f_terminate_line(activeMTHigh, BULL_COLOR, "MT", mtBOSInput)
activeMTLow  := f_terminate_line(activeMTLow, BEAR_COLOR, "MT", mtBOSInput)

activeLTHigh := f_terminate_line(activeLTHigh, BULL_COLOR, "LT", ltBOSInput)
activeLTLow  := f_terminate_line(activeLTLow, BEAR_COLOR, "LT", ltBOSInput)

//---------------------------------------------------------------------------------------------------------------------
// Candle Coloring
//---------------------------------------------------------------------------------------------------------------------
color candleColor = na

if not na(selectedHigh) and not na(selectedLow)
    candleColor :=
         factor > 0.5 ?
         color.from_gradient(factor, 0.5, 1.0, NEUTRAL_COLOR, BULL_COLOR) :
         color.from_gradient(factor, 0.0, 0.5, BEAR_COLOR, NEUTRAL_COLOR)

    if close > selectedHigh
        candleColor := BULL_COLOR

    if close < selectedLow
        candleColor := BEAR_COLOR

color finalBarColor =
     blackAfterBullBOS or blackAfterBearBOS ? color.rgb(0, 0, 0) :
     stBullBOS ? color.purple :
     stBearBOS ? color.purple :
     (colorCandlesInput ? candleColor : na)

barcolor(finalBarColor)

//---------------------------------------------------------------------------------------------------------------------
// Alerts
//---------------------------------------------------------------------------------------------------------------------
alertcondition(
     stBullBOS or stBearBOS,
     title = "ST BOS Triggered",
     message = "ST BOS triggered on {{ticker}} at {{close}}")
````

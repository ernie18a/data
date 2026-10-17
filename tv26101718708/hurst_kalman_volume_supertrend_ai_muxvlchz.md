# Hurst Kalman Volume SuperTrend AI

- url: https://www.tradingview.com/script/MUXVlcHz-Hurst-Kalman-Volume-SuperTrend-AI/
- type: indicator
- pine_id: PUB;11fee81c069b4004b28022198b432f19
- version: 8.0

## Description

This indicator is a combination of multiple components combined into one SuperTrend indicator with artificial Intelligence.

Components include:

* Hurst Exponent
* Kalman Smoother
* Average True Range
* Volume Weighted Moving Average
* KNN Machine Learning (AI Component)

This indicator is designed to provide AI-generated signals while withstanding choppy markets and fake breakouts during consolidation, minimizing false signals and whipsaws (but not totally eliminate).

HOW TO USE:
* When you see a Green Triangle/Dot = BUY
* When you see a Red Triangle/Dot = SELL

It is best to use this indicator with a strategic framework and GREAT Risk management.

I do not claim to be the original maker of the components of this indicator. I just combined multiple components into one.

Credits go to these masters: Zeiierman, QuantAlgo

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Hurst Kalman Volume ATR SuperTrend AI Public Version", shorttitle="Hurst Kalman Volume ATR SuperTrend AI Public Version", overlay=true, max_bars_back=500)

// --- Groups ---
var string G_HURST = "Hurst Exponent (Adaptivity)"
var string G_KALMAN = "Kalman Smoother"
var string G_ST = "SuperTrend Settings"
var string G_AI = "AI & KNN Classification"
var string G_STYLE = "Visual Settings"

// --- Inputs ---

// Hurst Settings
hPeriod    = input.int(60, "Hurst Lookback Period", minval=20, group=G_HURST, tooltip="Lookback window used to estimate the Hurst exponent. H > 0.5 indicates trending, H < 0.5 indicates mean-reverting/choppy.")
hLag       = input.int(10, "Scaling Lag (q)", minval=2, maxval=30, group=G_HURST, tooltip="Used in variance scaling. Larger values increase contrast between short and long-run variance.")

// Kalman Settings
kfGainBase = input.float(0.2, "Base Kalman Gain", minval=0.01, maxval=0.99, step=0.01, group=G_KALMAN, tooltip="Controls how aggressively the smoother follows price. Multiplied by Hurst value.")

// SuperTrend Settings
stLen      = input.int(10, "ATR Length", minval=1, group=G_ST)
stMultBase = input.float(1.5, "Base Multiplier", minval=0.1, step=0.1, group=G_ST)
stHScale   = input.float(3.0, "Hurst Scale Factor", minval=0.0, step=0.1, group=G_ST, tooltip="Widens the band in choppy conditions (low Hurst). Multiplier = Base + Scale * (1 - H).")
maSrc      = input.string("WMA", "Volume Weighting Type", options=["SMA", "EMA", "WMA", "RMA", "VWMA"], group=G_ST, tooltip="Type of moving average used for volume-weighted price calculation.")

// AI Settings
knnK       = input.int(3, "KNN Neighbors (k)", minval=1, maxval=50, group=G_AI)
knnN       = input.int(50, "Historical Data Points (n)", minval=5, maxval=100, group=G_AI, tooltip="Number of historical data points to consider for KNN classification.")
knnPriceLen = input.int(20, "Price Trend Length", minval=2, group=G_AI)
knnSTLen    = input.int(100, "Signal Smoothing Length", minval=2, group=G_AI)

// Style Settings
bullColor  = input.color(#089981, "Bullish Color", group=G_STYLE)
bearColor  = input.color(#f23645, "Bearish Color", group=G_STYLE)
neutColor  = input.color(#5b9cf6, "Neutral Color", group=G_STYLE)
showSignals = input.bool(true, "Show AI Signals", group=G_STYLE)

// --- User Defined Functions ---

// Volume Weighted Calculation
calc_vw_source(float src, int length, string maType) =>
    float res = switch maType
        "SMA"  => ta.sma(src * volume, length) / math.max(ta.sma(volume, length), 1e-10)
        "EMA"  => ta.ema(src * volume, length) / math.max(ta.ema(volume, length), 1e-10)
        "WMA"  => ta.wma(src * volume, length) / math.max(ta.wma(volume, length), 1e-10)
        "RMA"  => ta.rma(src * volume, length) / math.max(ta.rma(volume, length), 1e-10)
        =>        ta.vwma(src, length)
    res

// KNN Weighted Function
knn_classify(float[] data, int[] labels, int k, float target) =>
    int n = array.size(data)
    float[] distances = array.new_float(n)
    int[] indices = array.new_int(n)
    
    for i = 0 to n - 1
        dist = math.abs(target - array.get(data, i))
        array.set(distances, i, dist)
        array.set(indices, i, i)
    
    // Sort by distance (we need k nearest)
    for i = 0 to math.min(k, n) - 1
        int minIdx = i
        for j = i + 1 to n - 1
            if array.get(distances, j) < array.get(distances, minIdx)
                minIdx := j
        
        float tempDist = array.get(distances, i)
        array.set(distances, i, array.get(distances, minIdx))
        array.set(distances, minIdx, tempDist)
        
        int tempIdx = array.get(indices, i)
        array.set(indices, i, array.get(indices, minIdx))
        array.set(indices, minIdx, tempIdx)

    float weightedSum = 0.0
    float totalWeight = 0.0
    int limit = math.min(k, n)
    for i = 0 to limit - 1
        int idx = array.get(indices, i)
        int label = array.get(labels, idx)
        float weight = 1.0 / (array.get(distances, i) + 1e-6)
        weightedSum += weight * label
        totalWeight += weight
    
    weightedSum / math.max(totalWeight, 1e-10)

// --- Core Logic ---

// 1. Hurst Exponent Calculation
float var1  = ta.variance(close - close[1], hPeriod)
float varq  = ta.variance(close - close[hLag], hPeriod)
float hRaw  = math.log(varq / math.max(var1, 1e-10)) / (2.0 * math.log(hLag))
float h     = math.max(0.0, math.min(nz(hRaw, 0.5), 1.0))

// 2. Volume-Weighted Price & Kalman Filter
float vwSrc = calc_vw_source(close, stLen, maSrc)
float adaptiveGain = math.max(math.min(kfGainBase * (0.5 + h), 0.99), 0.01)

var float kf = na
kf := na(kf[1]) ? vwSrc : kf[1] + adaptiveGain * (vwSrc - kf[1])

// 3. Hurst-Adaptive SuperTrend
float atrValue = ta.atr(stLen)
float hMult = stMultBase + stHScale * (1.0 - h)
float bandWidth = atrValue * hMult

var float upBand = na
var float dnBand = na
var int trend = 1

float prevUp = nz(upBand[1], kf)
float prevDn = nz(dnBand[1], kf)
int prevTrend = nz(trend[1], 1)

upBand := prevTrend == 1 ? math.max(kf - bandWidth, prevUp) : kf - bandWidth
dnBand := prevTrend == -1 ? math.min(kf + bandWidth, prevDn) : kf + bandWidth
trend := kf > prevDn ? 1 : kf < prevUp ? -1 : prevTrend

float stLine = trend == 1 ? upBand : dnBand

// 4. AI / KNN Classification
var float[] knnData = array.new_float(0)
var int[] knnLabels = array.new_int(0)

float priceSmooth = ta.wma(close, knnPriceLen)
float stSmooth = ta.wma(stLine, knnSTLen)
int currentLabel = priceSmooth > stSmooth ? 1 : 0

array.insert(knnData, 0, stLine)
array.insert(knnLabels, 0, currentLabel)
if array.size(knnData) > knnN
    array.pop(knnData)
    array.pop(knnLabels)

float aiScore = array.size(knnData) >= knnN ? knn_classify(knnData, knnLabels, knnK, stLine) : 0.5

// --- Graphical Mimicry Logic ---
// We use a state-based logic to determine the trend color.
// This prevents the "Neutral" color from appearing intermittently during an ongoing trend.
// The trend only becomes neutral when shifting between states or when conditions weaken significantly.
var int trendState = 0 // 1: Bullish, -1: Bearish, 0: Neutral

if aiScore == 1.0 and trend == 1
    trendState := 1
else if aiScore == 0.0 and trend == -1
    trendState := -1
else if trendState == 1 and (aiScore < 0.5 or trend == -1)
    trendState := 0
else if trendState == -1 and (aiScore > 0.5 or trend == 1)
    trendState := 0

color dynamicColor = trendState == 1 ? bullColor : trendState == -1 ? bearColor : neutColor

// --- Visuals ---

// Plot SuperTrend (Single call ensures the line never breaks)
plot(stLine, "Adaptive SuperTrend", color=dynamicColor, linewidth=3)

// Gradient Fill matching the dynamic trend color
p1 = plot(close, "Price Plot", display=display.none, editable=false)
p2 = plot(stLine, "ST Plot", display=display.none, editable=false)
fill(p1, p2, color.new(dynamicColor, 80), "Trend Fill")

// Signals trigger when the AI classification becomes unanimous; only one signal per direction until an opposite signal appears.
var int lastSignalDirection = 0
bool aiBullSignal = aiScore == 1.0 and aiScore[1] < 1.0 and lastSignalDirection != 1
bool aiBearSignal = aiScore == 0.0 and aiScore[1] > 0.0 and lastSignalDirection != -1

if aiBullSignal
    lastSignalDirection := 1
else if aiBearSignal
    lastSignalDirection := -1

plotshape(showSignals and aiBullSignal ? stLine : na, "AI Bullish Signal", shape.triangleup, location.absolute, bullColor, size=size.small, textcolor=chart.fg_color)
plotshape(showSignals and aiBearSignal ? stLine : na, "AI Bearish Signal", shape.triangledown, location.absolute, bearColor, size=size.small, textcolor=chart.fg_color)

// --- Alerts ---
alertcondition(aiBullSignal, "AI Bullish Trend", "Adaptive SuperTrend AI Signal: Bullish")
alertcondition(aiBearSignal, "AI Bearish Trend", "Adaptive SuperTrend AI Signal: Bearish")
alertcondition(ta.change(trend) != 0, "SuperTrend Flip", "Adaptive SuperTrend Direction Changed")
````

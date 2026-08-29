<!-- tradingview-pine-id: PUB;3d1eee741d85478bbac1194e7c624108 -->
<!-- tradingviewscripts-format: 1 -->
# All Encompassing Futures Entry Guide

Source: https://www.tradingview.com/script/oGs2HNtm-UPDATED-COMBO-EMA-LRI-SuperTrend-HMA-Strategy/

## Description

Overview
The EMA / LRI / SuperTrend / HMA Execution Suite is a streamlined overlay designed for intraday momentum traders, scalpers, and trend followers. It combines dynamic trend baselines, statistical breakout evaluation, and multi-tier moving average filters into a single, highly performant script.

By focusing purely on high-probability trend structure and dynamic fair value, this indicator keeps your chart visually clean and clutter-free for quick execution.

Key Features & Components:

[*]Core Purpose: An advanced multi-indicator technical suite specifically designed for futures and stock trading.
[*]
[*]Moving Averages & Momentum: Integrates a customizable Exponential Moving Average (EMA), a versatile Hull Moving Average (HMA) with both single and 3-HMA crossover modes, and a directionally-colored Linear Regression Index (LRI) for momentum tracking.
[*]
[*]Breakout Probability Engine: Features a SuperTrend overlay enhanced with a relative volume Gaussian Kernel Density Estimation (KDE) model to calculate breakout strength and display confidence percentage labels.
[*]
[*]Visual Adjustments: Includes fully customizable vertical offsets and connecting lines for the probability bubbles to maintain clear chart readability.
[*]
[*]Comprehensive Alerts: Built-in alert conditions for trend flips, high-confidence breakouts, and moving average or price crossovers against the LRI.

---

## Source Code

````pine
//@version=6
indicator("All Encompassing Futures Entry Guide", shorttitle="STRAT", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// =========================================================================
// EMA
// =========================================================================
emaEnable = input.bool(true, "Enable EMA", group="EMA")
emaLen    = input.int(21, "EMA Length", minval=1, group="EMA")
emaSrc    = input.source(close, "EMA Source", group="EMA")
emaColor  = input.color(color.new(#2962FF, 0), "EMA Color", group="EMA")
emaWidth  = input.int(2, "EMA Line Width", minval=1, maxval=5, group="EMA")

float emaVal = ta.ema(emaSrc, emaLen)
plot(emaEnable ? emaVal : na, title="EMA", color=emaColor, linewidth=emaWidth)

// =========================================================================
// HMA - Hull Moving Average
// =========================================================================
hmaEnable       = input.bool(false, "Enable HMA", group="HMA")
hmaMode         = input.string("Single HMA", "HMA Mode", options=["Single HMA", "3-HMA Crossover (Scalping/Intraday)"], group="HMA")
hmaSrc          = input.source(close, "HMA Source", group="HMA")
hmaUpColor      = input.color(color.new(color.lime, 0), "HMA Bullish Color", group="HMA")
hmaDownColor    = input.color(color.new(color.red, 0), "HMA Bearish Color", group="HMA")
hmaNeutralColor = input.color(color.new(color.gray, 0), "HMA Neutral Color (Crossover Mode)", group="HMA")
hmaWidth        = input.int(3, "HMA Line Width", minval=1, maxval=5, group="HMA")

// --- Single HMA mode ---
hmaLen          = input.int(55, "HMA Length (Single Mode)", minval=2, group="HMA")
float hmaSingleVal    = ta.hma(hmaSrc, hmaLen)
bool hmaSingleRising  = hmaSingleVal >= hmaSingleVal[1]
color hmaSingleColor  = hmaSingleRising ? hmaUpColor : hmaDownColor

// --- 3-HMA Crossover mode ---
hmaTradeType = input.string("Scalping", "Trade Type (Crossover Mode)", options=["Scalping", "Intraday"], group="HMA")
int hmaFastLen   = hmaTradeType == "Scalping" ? 10 : 20
int hmaMidLen    = hmaTradeType == "Scalping" ? 20 : 50
int hmaSlowLen   = 100

float hmaFast = ta.hma(hmaSrc, hmaFastLen)
float hmaMid  = ta.hma(hmaSrc, hmaMidLen)
float hmaSlow = ta.hma(hmaSrc, hmaSlowLen)

bool hmaBullish = hmaSlow < hmaMid and hmaSlow < hmaFast and hmaFast > hmaMid
bool hmaBearish = hmaSlow > hmaMid and hmaSlow > hmaFast and hmaMid > hmaFast
color hmaCrossColor = hmaBullish ? hmaUpColor : hmaBearish ? hmaDownColor : hmaNeutralColor

bool isSingleMode = hmaMode == "Single HMA"
float hmaPlotVal   = isSingleMode ? hmaSingleVal : hmaSlow
color hmaPlotColor = isSingleMode ? hmaSingleColor : hmaCrossColor

plot(hmaEnable ? hmaPlotVal : na, title="HMA", color=hmaPlotColor, linewidth=hmaWidth)

// =========================================================================
// LRI - Linear Regression Index (direction-colored)
// =========================================================================
lriEnable    = input.bool(true, "Enable LRI", group="LRI")
lriLen       = input.int(25, "LRI Length", minval=2, group="LRI")
lriSrc       = input.source(close, "LRI Source", group="LRI")
lriUpColor   = input.color(color.new(color.lime, 0), "LRI Rising Color", group="LRI")
lriDownColor = input.color(color.new(color.red, 0), "LRI Falling Color", group="LRI")
lriWidth     = input.int(2, "LRI Line Width", minval=1, maxval=5, group="LRI")

float lriVal   = ta.linreg(lriSrc, lriLen, 0)
bool lriRising = lriVal >= lriVal[1]
color lriColor = lriRising ? lriUpColor : lriDownColor

plot(lriEnable ? lriVal : na, title="LRI", color=lriColor, linewidth=lriWidth)

// =========================================================================
// SuperTrend + Relative Volume (KDE-based breakout probability)
// =========================================================================
stEnable        = input.bool(true, "Enable SuperTrend", group="SuperTrend + RelVol")
atrLen          = input.int(10, "ATR Length", minval=1, group="SuperTrend + RelVol")
atrMult         = input.float(2.0, "ATR Multiplier", minval=0.1, step=0.1, group="SuperTrend + RelVol")
bullColor       = input.color(color.new(#089981, 0), "Bullish Color", group="SuperTrend + RelVol")
bearColor       = input.color(color.new(#F23645, 0), "Bearish Color", group="SuperTrend + RelVol")
stWidth         = input.int(2, "SuperTrend Line Width", minval=1, maxval=5, group="SuperTrend + RelVol")

relVolLen       = input.int(25, "Relative Volume Length", minval=1, group="SuperTrend + RelVol")

probEnable      = input.bool(true, "Show Breakout Probability Labels", group="SuperTrend + RelVol - Probability")
probLookback    = input.int(100, "Probability Sample Size (breaks)", minval=5, maxval=500, group="SuperTrend + RelVol - Probability")
kdeBandwidth    = input.float(0.5, "KDE Bandwidth", minval=0.05, step=0.05, group="SuperTrend + RelVol - Probability")
probThreshold   = input.float(70, "High-Confidence Threshold %", minval=0, maxval=100, group="SuperTrend + RelVol - Probability")
showAllLabels   = input.bool(true, "Show Labels Below Threshold Too", group="SuperTrend + RelVol - Probability")
alertOnHighProb = input.bool(false, "Alert Only On High-Confidence Breaks", group="SuperTrend + RelVol - Probability")
labelOffsetPct  = input.float(12.0, "Label Vertical Offset (% ATR)", minval=0.1, step=0.1, group="SuperTrend + RelVol - Probability")
labelSizeInput  = input.string("Normal", "Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="SuperTrend + RelVol - Probability")

[supertrend, direction] = ta.supertrend(atrMult, atrLen)
float currentAtr = ta.atr(atrLen)

float stUpSegment   = direction < 0 ? supertrend : na
float stDownSegment = direction > 0 ? supertrend : na

plot(stEnable ? stUpSegment : na, title="SuperTrend (Bull)", color=bullColor, linewidth=stWidth, style=plot.style_linebr)
plot(stEnable ? stDownSegment : na, title="SuperTrend (Bear)", color=bearColor, linewidth=stWidth, style=plot.style_linebr)

float relVol = volume / ta.sma(volume, relVolLen)

bool trendChanged  = ta.change(direction) != 0
bool turnedBullish = trendChanged and direction < 0
bool turnedBearish = trendChanged and direction > 0

var float[] bullBreakVols = array.new_float(0)
var float[] bearBreakVols = array.new_float(0)

if turnedBullish
    array.push(bullBreakVols, relVol)
    if array.size(bullBreakVols) > probLookback
        array.shift(bullBreakVols)

if turnedBearish
    array.push(bearBreakVols, relVol)
    if array.size(bearBreakVols) > probLookback
        array.shift(bearBreakVols)

gaussianKDE(float[] arr, float x, float bw) =>
    int n = array.size(arr)
    float density = 0.0
    if n > 0
        float sum = 0.0
        for i = 0 to n - 1
            float diff = (x - array.get(arr, i)) / bw
            sum := sum + math.exp(-0.5 * diff * diff)
        density := sum / (n * bw * math.sqrt(2 * math.pi))
    density

var float bullProb = 0.0
var float bearProb = 0.0
var float maxBullDensity = 0.0
var float maxBearDensity = 0.0

if trendChanged
    float bullDensity = gaussianKDE(bullBreakVols, relVol, kdeBandwidth)
    float bearDensity = gaussianKDE(bearBreakVols, relVol, kdeBandwidth)
    maxBullDensity := math.max(maxBullDensity, bullDensity)
    maxBearDensity := math.max(maxBearDensity, bearDensity)
    bullProb := maxBullDensity > 0 ? (bullDensity / maxBullDensity) * 100 : 0.0
    bearProb := maxBearDensity > 0 ? (bearDensity / maxBearDensity) * 100 : 0.0

string labelSize = labelSizeInput == "Tiny" ? size.tiny : labelSizeInput == "Small" ? size.small : labelSizeInput == "Normal" ? size.normal : labelSizeInput == "Large" ? size.large : size.huge

var label[] probLabels = array.new_label(0)
var line[] probLines = array.new_line(0)
int maxProbLabels = 300

if stEnable and probEnable and trendChanged
    float prob = turnedBullish ? bullProb : bearProb
    bool isHighConf = prob >= probThreshold
    float offsetVal = currentAtr * (labelOffsetPct / 100.0) * 30
    float labelY = turnedBullish ? (supertrend - offsetVal) : (supertrend + offsetVal)
    
    if isHighConf or showAllLabels
        label probLbl = label.new(
             bar_index,
             labelY,
             str.tostring(math.round(prob)) + "%",
             style = turnedBullish ? label.style_label_up : label.style_label_down,
             color = color(na),
             textcolor = color.white,
             size = labelSize)
        array.push(probLabels, probLbl)
        
        line probLn = line.new(
             bar_index, 
             supertrend, 
             bar_index, 
             labelY, 
             color = turnedBullish ? bullColor : bearColor, 
             width = 1, 
             style = line.style_dotted)
        array.push(probLines, probLn)

        if array.size(probLabels) > maxProbLabels
            label.delete(array.shift(probLabels))
            line oldLn = array.shift(probLines)
            if not na(oldLn)
                line.delete(oldLn)

// =========================================================================
// Alerts
// =========================================================================
alertcondition(turnedBullish, title="SuperTrend Turned Bullish", message="SuperTrend flipped bullish")
alertcondition(turnedBearish, title="SuperTrend Turned Bearish", message="SuperTrend flipped bearish")

bool highConfBull = turnedBullish and bullProb >= probThreshold
bool highConfBear = turnedBearish and bearProb >= probThreshold
alertcondition(highConfBull, title="High-Confidence Bullish Break", message="High-confidence bullish SuperTrend break")
alertcondition(highConfBear, title="High-Confidence Bearish Break", message="High-confidence bearish SuperTrend break")

if alertOnHighProb and (highConfBull or highConfBear)
    alert((highConfBull ? "Bullish" : "Bearish") + " break, confidence " + str.tostring(math.round(highConfBull ? bullProb : bearProb)) + "%", alert.freq_once_per_bar_close)

bool priceCrossOverLRI  = ta.crossover(close, lriVal)
bool priceCrossUnderLRI = ta.crossunder(close, lriVal)

alertcondition(priceCrossOverLRI,  title="Price Crossed Above LRI", message="Price crossed above LRI")
alertcondition(priceCrossUnderLRI, title="Price Crossed Below LRI", message="Price crossed below LRI")

bool emaCrossOverLRI  = ta.crossover(emaVal, lriVal)
bool emaCrossUnderLRI = ta.crossunder(emaVal, lriVal)

alertcondition(emaCrossOverLRI,  title="EMA Crossed Above LRI", message="EMA crossed above LRI")
alertcondition(emaCrossUnderLRI, title="EMA Crossed Below LRI", message="EMA crossed below LRI")
````

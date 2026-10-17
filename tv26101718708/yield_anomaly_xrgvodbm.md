# Yield Anomaly

- url: https://www.tradingview.com/script/xRgvOdBm/
- type: indicator
- pine_id: PUB;4162f634c1734751958f10a59dce9409
- version: 1.0

## Description

Yield Anomaly V2 is an advanced statistical indicator designed to identify abnormal price movements using log returns, adaptive volatility analysis, and robust anomaly detection techniques.

The script combines Z-Score analysis, percentile thresholds, and robust deviation measurements (MAD-based volatility estimation) to highlight unusual market behavior that may indicate momentum expansion, volatility spikes, exhaustion moves, or potential mean-reversion conditions.

Key Features:
• Adaptive anomaly detection using either standard deviation or robust MAD calculations
• Optional percentile-based thresholds for dynamic market adaptation
• EMA or SMA rolling mean selection
• Detection of anomaly clusters and potential regime shifts
• AR(1)-based market regime analysis (mean reversion vs trending conditions)
• Volatility regime monitoring through Volatility-of-Volatility analysis
• Real-time labels displaying statistical market conditions
• Performance tracking table with signal statistics and reversal monitoring
• Fully customizable inputs and visual settings

This indicator is intended for educational and analytical purposes only. It does not provide financial advice, investment recommendations, or guaranteed trading signals. Traders should combine it with proper risk management and additional market analysis before making trading decisions.

## Source Code

````pine
//@version=6
indicator("Yield Anomaly V2", overlay=false, max_labels_count=500)

//====================================================
// INPUTS
//====================================================

window          = input.int(20, "Rolling Window")
stdMult         = input.float(2.0, "Z Threshold")
scaleFactor     = input.float(10000.0, "Visual Scale")

useEMA          = input.bool(true, "Use EMA Mean")
useMAD          = input.bool(true, "Use Robust MAD")
usePercentile   = input.bool(true, "Use Percentile Threshold")

percentileLevel = input.float(95.0, "Percentile")

//====================================================
// COLORS
//====================================================

bgCol      = color.rgb(13,13,26)

bullCol    = color.rgb(51,204,102)
bearCol    = color.rgb(255,77,77)

neutralCol = color.rgb(180,180,180)

spikeCol   = color.yellow
clusterCol = color.orange
regimeCol  = color.red

//====================================================
// BACKGROUND
//====================================================

bgcolor(bgCol)

//====================================================
// LOG RETURNS
//====================================================

logReturn = math.log(close / close[1])

lr = barstate.isconfirmed ? logReturn : na

//====================================================
// MEAN
//====================================================

float rollingMean = na

rollingMean :=
     useEMA ?
     ta.ema(lr, window) :
     ta.sma(lr, window)

//====================================================
// CLASSIC STD
//====================================================

rollingStd = ta.stdev(lr, window)

//====================================================
// MAD ROBUST STD
//====================================================

medianLR = ta.percentile_linear_interpolation(lr, window, 50)

absDev = math.abs(lr - medianLR)

mad = ta.percentile_linear_interpolation(absDev, window, 50)

robustStd = 1.4826 * mad

finalStd =
     useMAD ?
     robustStd :
     rollingStd

//====================================================
// Z SCORE
//====================================================

zScore = (lr - rollingMean) / finalStd

//====================================================
// EMPIRICAL PERCENTILES
//====================================================

upperPct =
     ta.percentile_linear_interpolation(
     lr,
     window,
     percentileLevel)

lowerPct =
     ta.percentile_linear_interpolation(
     lr,
     window,
     100 - percentileLevel)

//====================================================
// THRESHOLDS
//====================================================

upperThreshold =
     usePercentile ?
     upperPct :
     rollingMean + stdMult * finalStd

lowerThreshold =
     usePercentile ?
     lowerPct :
     rollingMean - stdMult * finalStd

//====================================================
// ANOMALIES
//====================================================

anomalyUp =
     usePercentile ?
     lr > upperThreshold :
     zScore > stdMult

anomalyDown =
     usePercentile ?
     lr < lowerThreshold :
     zScore < -stdMult

anomaly = anomalyUp or anomalyDown

//====================================================
// ANOMALY CLUSTERS
//====================================================

var int clusterCount = 0

clusterCount :=
     anomaly ?
     clusterCount + 1 :
     0

clusterColor =
     clusterCount >= 4 ?
     regimeCol :
     clusterCount >= 2 ?
     clusterCol :
     spikeCol

//====================================================
// AR(1) REGIME DETECTION
//====================================================

covariance =
     ta.correlation(lr, lr[1], window)

ar1 = covariance

meanReverting = ar1 < 0
trending      = ar1 > 0

//====================================================
// VOL OF VOL
//====================================================

volOfVol = ta.stdev(finalStd, window)

lowVolRegime =
     volOfVol < ta.sma(volOfVol, window)

highVolRegime =
     volOfVol > ta.sma(volOfVol, window)

//====================================================
// REVERSAL TRACKING
//====================================================

var int totalSignals = 0
var int successfulReversals = 0

prevAnomaly =
     anomaly[1]

bullReversal =
     anomalyDown[1] and close > close[1]

bearReversal =
     anomalyUp[1] and close < close[1]

success =
     bullReversal or bearReversal

if prevAnomaly
    totalSignals += 1

if success
    successfulReversals += 1

hitRate =
     totalSignals > 0 ?
     (successfulReversals / totalSignals) * 100 :
     na

//====================================================
// VISUALS
//====================================================

displayLR = zScore

plot(
     0,
     color=color.new(color.white, 90)
)

plot(
     displayLR,
     color=neutralCol,
     linewidth=1
)

plot(
     stdMult,
     color=bearCol,
     linewidth=2
)

plot(
     -stdMult,
     color=bullCol,
     linewidth=2
)

//====================================================
// ANOMALY PLOTS
//====================================================

plot(
     anomaly ? displayLR : na,
     style=plot.style_circles,
     color=clusterColor,
     linewidth=4
)

//====================================================
// LABELS
//====================================================

var label lastLabel = na

if anomaly and barstate.isconfirmed

    label.delete(lastLabel)

    regimeTxt =
         meanReverting ?
         "MEAN REVERSION" :
         "TRENDING"

    clusterTxt =
         clusterCount >= 4 ?
         "REGIME SHIFT" :
         clusterCount >= 2 ?
         "CLUSTER" :
         "SPIKE"

    volTxt =
         lowVolRegime ?
         "LOW VOL" :
         "HIGH VOL"

    txt =
         "Z-Score: " + str.tostring(zScore, "#.00") +
         "\nAR1: " + str.tostring(ar1, "#.00") +
         "\n" + regimeTxt +
         "\n" + clusterTxt +
         "\n" + volTxt

    lastLabel := label.new(
         bar_index,
         displayLR,
         txt,
         style=
             anomalyUp ?
             label.style_label_down :
             label.style_label_up,
         color=clusterColor,
         textcolor=color.black,
         size=size.small
    )

//====================================================
// TABLE
//====================================================

var table stats = table.new(position.middle_right, 2, 9)

if barstate.islast

    table.cell(stats, 0, 0, "Z-Score")
    table.cell(stats, 1, 0,
         str.tostring(zScore, "#.00"))

    table.cell(stats, 0, 1, "Robust Std")
    table.cell(stats, 1, 1,
         str.tostring(finalStd, "#.000000"))

    table.cell(stats, 0, 2, "AR(1)")
    table.cell(stats, 1, 2,
         str.tostring(ar1, "#.00"))

    table.cell(stats, 0, 3, "Regime")
    table.cell(stats, 1, 3,
         meanReverting ? "MR" : "Trend")

    table.cell(stats, 0, 4, "Cluster")
    table.cell(stats, 1, 4,
         str.tostring(clusterCount))

    table.cell(stats, 0, 5, "Vol Regime")
    table.cell(stats, 1, 5,
         lowVolRegime ? "Low" : "High")

    table.cell(stats, 0, 6, "Hit Rate")
    table.cell(stats, 1, 6,
         str.tostring(hitRate, "#.0") + "%")

    table.cell(stats, 0, 7, "Signals")
    table.cell(stats, 1, 7,
         str.tostring(totalSignals))

    table.cell(stats, 0, 8, "Reversals")
    table.cell(stats, 1, 8,
         str.tostring(successfulReversals))

//====================================================
// ALERTS
//====================================================

alertcondition(
     anomalyUp,
     title="Upper Anomaly",
     message="Bullish anomaly detected"
)

alertcondition(
     anomalyDown,
     title="Lower Anomaly",
     message="Bearish anomaly detected"
)
````

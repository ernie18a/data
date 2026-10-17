# SuperTrend Divergence Pro [JPT]

- url: https://www.tradingview.com/script/PY2a1t0e-SuperTrend-Divergence-Pro-JPT/
- type: indicator
- pine_id: PUB;28463bddb460433d85a4af4d1193929b
- version: 1.0

## Description

🔷 Overview

SuperTrend Divergence Pro [JPT] is an educational technical-analysis indicator that combines an adaptive SuperTrend framework with confirmed bullish and bearish divergence detection.

The indicator uses ATR-based trend bands and oscillator-based divergence to dynamically adjust the SuperTrend behavior. Confirmed pivot structures are used to identify potential divergence between price and momentum.

🔷 Key Features

• Adaptive ATR-based SuperTrend
• Bullish & Bearish Divergence Detection
• Confirmed Pivot-Based Analysis
• Dynamic SuperTrend Multiplier
• BUY / SELL Trend-Flip Signals
• Optional Trend Fill
• Optional Bar Coloring
• Divergence Markers
• Configurable ATR & Pivot Settings
• Alert Conditions for Signals and Divergence

🔷 How It Works

A bullish divergence is identified when price forms a lower low while the oscillator forms a higher low.

A bearish divergence is identified when price forms a higher high while the oscillator forms a lower high.

When divergence is active, the SuperTrend framework dynamically adjusts its ATR multiplier. This allows the trend structure to respond differently when potential momentum weakness or strengthening is detected.

BUY and SELL markers are generated when the SuperTrend trend regime changes and the configured confirmation conditions are satisfied.

🔷 Important Note

This indicator is designed for educational and analytical purposes only. It does not predict future price movements and does not guarantee profitable trades. Signals should be evaluated together with market structure, volatility, timeframe, and other relevant analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("SuperTrend Divergence Pro [JPT]", overlay=true, max_lines_count=500, max_labels_count=500)

//────────────────────────────────────────────────────
// MODULE 1 — INPUTS
//────────────────────────────────────────────────────

groupST   = "SuperTrend Engine"
groupDIV  = "Divergence Engine"
groupSIG  = "Signal Settings"
groupVIS  = "Visual Settings"
groupALT  = "Alert Settings"

atrLength = input.int(10, "ATR Length", minval=1, group=groupST)
atrFactor = input.float(3.0, "Base ATR Multiplier", minval=0.1, step=0.1, group=groupST)

pivotLen = input.int(3, "Divergence Pivot Length", minval=1, group=groupDIV)
oscLen   = input.int(6, "Oscillator Length", minval=2, group=groupDIV)
oscSmooth = input.int(7, "Oscillator Smoothing", minval=1, group=groupDIV)

divSensitivity = input.float(
     0.35,
     "Divergence Sensitivity",
     minval=0.0,
     maxval=1.0,
     step=0.05,
     group=groupDIV,
     tooltip="Controls how strongly active divergence reduces the ATR multiplier."
)

divLife = input.int(
     100,
     "Divergence Active Bars",
     minval=1,
     group=groupDIV
)

confirmBars = input.int(
     1,
     "Trend Confirmation Bars",
     minval=1,
     maxval=10,
     group=groupSIG
)

showSignals = input.bool(true, "Show Buy / Sell Signals", group=groupSIG)
showDivergence = input.bool(true, "Show Divergence Markers", group=groupSIG)

showTrendLine = input.bool(true, "Show SuperTrend Line", group=groupVIS)
showFill = input.bool(true, "Show Trend Fill", group=groupVIS)
colorBars = input.bool(false, "Color Bars", group=groupVIS)
showOscStrength = input.bool(false, "Show Divergence Strength", group=groupVIS)

enableAlerts = input.bool(true, "Enable Alert Conditions", group=groupALT)

// Colors
bullColor = input.color(
     color.rgb(0, 180, 90),
     "Bullish Color",
     group=groupVIS
)

bearColor = input.color(
     color.rgb(220, 50, 50),
     "Bearish Color",
     group=groupVIS
)

neutralColor = input.color(
     color.gray,
     "Neutral Color",
     group=groupVIS
)

//────────────────────────────────────────────────────
// MODULE 2 — DIVERGENCE OSCILLATOR
//────────────────────────────────────────────────────

// Candle-body pressure oscillator
bodySize = math.abs(close - open)

averageBody = ta.sma(bodySize, oscLen)

candleDirection =
     close > open ? 1.0 :
     close < open ? -1.0 :
     0.0

bodyWeight =
     averageBody != 0.0 ?
     bodySize / averageBody :
     1.0

pressure = candleDirection * bodyWeight

float rollingPressure = 0.0

for i = 0 to oscLen - 1
    rollingPressure += nz(pressure[i])

normalizedPressure =
     rollingPressure / (oscLen * 2.0) * 100.0

oscillator = ta.ema(
     normalizedPressure,
     oscSmooth
)

//────────────────────────────────────────────────────
// MODULE 3 — CONFIRMED PIVOTS
//────────────────────────────────────────────────────

pivotHigh = ta.pivothigh(
     oscillator,
     pivotLen,
     pivotLen
)

pivotLow = ta.pivotlow(
     oscillator,
     pivotLen,
     pivotLen
)

newPivotHigh = not na(pivotHigh)
newPivotLow = not na(pivotLow)

// Oscillator values at confirmed pivot
oscPivotHigh = oscillator[pivotLen]
oscPivotLow  = oscillator[pivotLen]

// Price values at confirmed pivot
pricePivotHigh = high[pivotLen]
pricePivotLow  = low[pivotLen]

// Previous pivot values
previousOscHigh =
     ta.valuewhen(
         newPivotHigh,
         oscPivotHigh,
         1
     )

previousPriceHigh =
     ta.valuewhen(
         newPivotHigh,
         pricePivotHigh,
         1
     )

previousOscLow =
     ta.valuewhen(
         newPivotLow,
         oscPivotLow,
         1
     )

previousPriceLow =
     ta.valuewhen(
         newPivotLow,
         pricePivotLow,
         1
     )

//────────────────────────────────────────────────────
// MODULE 4 — DIVERGENCE ENGINE
//────────────────────────────────────────────────────

// Bullish divergence:
// Price creates Lower Low
// Oscillator creates Higher Low

bullishDivergence =
     newPivotLow and
     not na(previousOscLow) and
     not na(previousPriceLow) and
     pricePivotLow < previousPriceLow and
     oscPivotLow > previousOscLow

// Bearish divergence:
// Price creates Higher High
// Oscillator creates Lower High

bearishDivergence =
     newPivotHigh and
     not na(previousOscHigh) and
     not na(previousPriceHigh) and
     pricePivotHigh > previousPriceHigh and
     oscPivotHigh < previousOscHigh

//────────────────────────────────────────────────────
// MODULE 5 — DIVERGENCE STATE
//────────────────────────────────────────────────────

var int divergenceType = 0
var int divergenceAge = 100000

if bullishDivergence
    divergenceType := 1
    divergenceAge := 0

else if bearishDivergence
    divergenceType := -1
    divergenceAge := 0

else
    divergenceAge += 1

if divergenceAge > divLife
    divergenceType := 0

bullDivActive =
     divergenceType == 1 and
     divergenceAge <= divLife

bearDivActive =
     divergenceType == -1 and
     divergenceAge <= divLife

//────────────────────────────────────────────────────
// MODULE 6 — ADAPTIVE ATR ENGINE
//────────────────────────────────────────────────────

atr = ta.atr(atrLength)

midPrice = (high + low) / 2.0

// Divergence reduces the multiplier
// against the current trend direction.

bullAdjustedFactor =
     bullDivActive ?
     atrFactor * (1.0 - divSensitivity) :
     atrFactor

bearAdjustedFactor =
     bearDivActive ?
     atrFactor * (1.0 - divSensitivity) :
     atrFactor

upperBand =
     midPrice + bearAdjustedFactor * atr

lowerBand =
     midPrice - bullAdjustedFactor * atr

//────────────────────────────────────────────────────
// MODULE 7 — SUPERTREND TRAILING ENGINE
//────────────────────────────────────────────────────

var float finalUpper = na
var float finalLower = na

previousUpper = nz(finalUpper[1], upperBand)
previousLower = nz(finalLower[1], lowerBand)

finalUpper :=
     upperBand < previousUpper or close[1] > previousUpper ?
     upperBand :
     previousUpper

finalLower :=
     lowerBand > previousLower or close[1] < previousLower ?
     lowerBand :
     previousLower

var int trend = 1

previousTrend = trend

if trend == -1 and close > previousUpper
    trend := 1

else if trend == 1 and close < previousLower
    trend := -1

trendFlip = trend != previousTrend

//────────────────────────────────────────────────────
// MODULE 8 — CONFIRMATION ENGINE
//────────────────────────────────────────────────────

var int bullBars = 0
var int bearBars = 0

if close > finalLower
    bullBars += 1
else
    bullBars := 0

if close < finalUpper
    bearBars += 1
else
    bearBars := 0

bullConfirmed =
     trend == 1 and
     bullBars >= confirmBars

bearConfirmed =
     trend == -1 and
     bearBars >= confirmBars

//────────────────────────────────────────────────────
// MODULE 9 — SIGNAL ENGINE
//────────────────────────────────────────────────────

buySignal =
     trendFlip and
     trend == 1 and
     bullConfirmed

sellSignal =
     trendFlip and
     trend == -1 and
     bearConfirmed

//────────────────────────────────────────────────────
// MODULE 10 — ACTIVE SUPERTREND
//────────────────────────────────────────────────────

superTrend =
     trend == 1 ?
     finalLower :
     finalUpper

trendColor =
     trend == 1 ?
     bullColor :
     trend == -1 ?
     bearColor :
     neutralColor

// Break line on reversal
displayTrend =
     trendFlip ?
     na :
     superTrend

//────────────────────────────────────────────────────
// MODULE 11 — PLOTS
//────────────────────────────────────────────────────

trendPlot = plot(
     showTrendLine ? displayTrend : na,
     title="Adaptive SuperTrend",
     color=color.new(trendColor, 10),
     linewidth=3,
     style=plot.style_linebr
)

pricePlot = plot(
     midPrice,
     title="Price Midpoint",
     display=display.none
)

fill(
     trendPlot,
     pricePlot,
     color=showFill ?
          color.new(trendColor, 88) :
          na,
     title="Trend Fill"
)

//────────────────────────────────────────────────────
// MODULE 12 — BUY / SELL MARKERS
//────────────────────────────────────────────────────

plotshape(
     showSignals and buySignal,
     title="BUY",
     text="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=bullColor,
     textcolor=color.white,
     size=size.small
)

plotshape(
     showSignals and sellSignal,
     title="SELL",
     text="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=bearColor,
     textcolor=color.white,
     size=size.small
)

//────────────────────────────────────────────────────
// MODULE 13 — DIVERGENCE MARKERS
//────────────────────────────────────────────────────

plotshape(
     showDivergence and bullishDivergence,
     title="Bullish Divergence",
     style=shape.circle,
     location=location.belowbar,
     color=bullColor,
     size=size.tiny,
     offset=-pivotLen
)

plotshape(
     showDivergence and bearishDivergence,
     title="Bearish Divergence",
     style=shape.circle,
     location=location.abovebar,
     color=bearColor,
     size=size.tiny,
     offset=-pivotLen
)

//────────────────────────────────────────────────────
// MODULE 14 — BAR COLORING
//────────────────────────────────────────────────────

barcolor(
     colorBars ?
     trendColor :
     na
)

//────────────────────────────────────────────────────
// MODULE 15 — DIVERGENCE STRENGTH
//────────────────────────────────────────────────────

bullStrength =
     bullishDivergence and
     not na(previousOscLow) ?
     math.abs(oscPivotLow - previousOscLow) :
     0.0

bearStrength =
     bearishDivergence and
     not na(previousOscHigh) ?
     math.abs(previousOscHigh - oscPivotHigh) :
     0.0

plot(
     showOscStrength ? bullStrength : na,
     title="Bullish Divergence Strength",
     display=display.data_window
)

plot(
     showOscStrength ? bearStrength : na,
     title="Bearish Divergence Strength",
     display=display.data_window
)

//────────────────────────────────────────────────────
// MODULE 16 — ALERTS
//────────────────────────────────────────────────────

alertcondition(
     enableAlerts and buySignal,
     title="SuperTrend BUY",
     message="SuperTrend Divergence Pro [JPT] — BUY signal"
)

alertcondition(
     enableAlerts and sellSignal,
     title="SuperTrend SELL",
     message="SuperTrend Divergence Pro [JPT] — SELL signal"
)

alertcondition(
     enableAlerts and bullishDivergence,
     title="Bullish Divergence",
     message="SuperTrend Divergence Pro [JPT] — Bullish divergence detected"
)

alertcondition(
     enableAlerts and bearishDivergence,
     title="Bearish Divergence",
     message="SuperTrend Divergence Pro [JPT] — Bearish divergence detected"
)

//────────────────────────────────────────────────────
// MODULE 17 — TREND STATUS DATA
//────────────────────────────────────────────────────

plot(
     trend,
     title="Trend State",
     display=display.data_window
)
````

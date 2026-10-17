# MACD Market Stage + Hybrid Divergence - TP

- url: https://www.tradingview.com/script/sJRYe7t8-MACD-Market-Stage-Hybrid-Divergence-TP/
- type: indicator
- pine_id: PUB;4d1f22839c014b9095e9a3f3736c53c8
- version: 5.0

## Description

## MACD Market Stage + Hybrid Divergence

This indicator is a customized version of the classic **MACD** concept commonly available on TradingView. Credit goes to TradingView and the original MACD indicator framework. This version adds simple table readings, momentum stages, custom histogram colors, and optional divergence lines to make MACD easier to interpret at a glance.

The goal of this tool is not to predict the future, but to help traders better understand the current momentum condition of the market.

## What This Indicator Shows

This indicator displays:

MACD line
Signal line
MACD histogram
Momentum reading table
Market stage reading
Optional bullish and bearish divergence lines

The histogram colors help show whether momentum is increasing or fading.

## How To Read It

When the histogram is above zero and growing, bullish momentum is expanding.

When the histogram is above zero but shrinking, bullish momentum is weakening.

When the histogram is below zero and moving lower, bearish momentum is expanding.

When the histogram is below zero but improving, bearish momentum is weakening.

## Table Readings

The table summarizes the MACD condition in simple terms.

**Signal** shows whether bullish or bearish momentum is currently leading.

**Market Stage** shows the broader momentum phase.

**Stage Bias** gives a plain-language interpretation of the current stage.

## Market Stages

**Stage 1 Momentum Base**
Bearish momentum is weakening and the market may be trying to recover.

**Stage 2 Bullish Momentum Expansion**
Bullish momentum is strengthening and buyers are currently leading.

**Stage 3 Momentum Distribution**
Bullish momentum is still present, but it is starting to fade.

**Stage 4 Bearish Momentum Expansion**
Bearish momentum is strengthening and sellers are currently leading.

**Market Transition**
Momentum is mixed or unclear.

## Divergence

The optional divergence feature compares price action with the MACD line.

A **bullish divergence** may appear when price makes a lower low, but MACD makes a higher low.

A **bearish divergence** may appear when price makes a higher high, but MACD makes a lower high.

Divergence should not be used alone. It is best used together with price structure, support and resistance, trend, and risk management.

## How To Use

Use this indicator to quickly check whether momentum is expanding, weakening, or transitioning.

It may be useful for:

Confirming trend momentum
Spotting possible momentum weakness
Reading MACD conditions faster
Finding possible divergence areas
Supporting a broader trading plan

## Important Note

This indicator is for educational and informational purposes only. It does not provide financial advice, buy signals, or sell signals. No indicator can guarantee future results. Always use proper risk management and your own analysis before making trading decisions.

## Source Code

````pine
//@version=6
// © TradersPod. Custom MACD Market Stage and Hybrid Divergence concept.
// Built from the classic MACD framework commonly used on TradingView.

indicator(
     "MACD Market Stage + Hybrid Divergence - TP",
     overlay=false,
     precision=4,
     max_bars_back=5000,
     max_labels_count=300,
     max_lines_count=300
     )

import TradingView/ta/13 as tvta

//----------------------------------------------------
// MACD Inputs
//----------------------------------------------------
src = input.source(close, "Source")

fastLength = input.int(
     12,
     "Fast Length",
     minval=1
     )

slowLength = input.int(
     26,
     "Slow Length",
     minval=1
     )

signalLength = input.int(
     9,
     "Signal Length",
     minval=1
     )

showMacdLine = input.bool(
     true,
     "Show MACD Line"
     )

showSignalLine = input.bool(
     true,
     "Show Signal Line"
     )

showHistogram = input.bool(
     true,
     "Show Histogram"
     )

macdColor = input.color(
     color.rgb(0, 102, 255),
     "MACD Line Color"
     )

signalColor = input.color(
     color.orange,
     "Signal Line Color"
     )

bullStrongColor = input.color(
     color.rgb(0, 180, 170),
     "Bullish Increasing Histogram"
     )

bullWeakColor = input.color(
     color.rgb(170, 230, 225),
     "Bullish Fading Histogram"
     )

bearStrongColor = input.color(
     color.rgb(255, 55, 70),
     "Bearish Increasing Histogram"
     )

bearWeakColor = input.color(
     color.rgb(255, 170, 180),
     "Bearish Fading Histogram"
     )

//----------------------------------------------------
// Market Stage Inputs
//----------------------------------------------------
groupStage = "Market Stage Reading"

showMarketStageRead = input.bool(
     true,
     "Include Market Stage Read",
     group=groupStage
     )

stageSlopeLen = input.int(
     5,
     "Signal Line Slope Lookback",
     minval=1,
     group=groupStage
     )

stageNormLen = input.int(
     50,
     "Stage Normalization Lookback",
     minval=5,
     group=groupStage
     )

stageFlatThreshold = input.float(
     2.0,
     "Signal Flat Threshold",
     minval=0.0,
     step=0.1,
     group=groupStage
     )

histMomentumLen = input.int(
     1,
     "Histogram Momentum Bars",
     minval=1,
     group=groupStage
     )

stage2Color = input.color(
     color.lime,
     "Stage 2 Color",
     group=groupStage
     )

stage4Color = input.color(
     color.red,
     "Stage 4 Color",
     group=groupStage
     )

stage3Color = input.color(
     color.rgb(180, 150, 35),
     "Stage 3 Color",
     group=groupStage
     )

stage1Color = input.color(
     color.orange,
     "Stage 1 Color",
     group=groupStage
     )

neutralStageColor = input.color(
     color.gray,
     "Neutral Stage Color",
     group=groupStage
     )

//----------------------------------------------------
// Hybrid Divergence Inputs
//----------------------------------------------------
groupDiv = "Hybrid Divergence"

showDivergence = input.bool(
     true,
     "Show Divergences",
     group=groupDiv
     )

divergenceMode = input.string(
     "Hybrid",
     "Divergence Mode",
     options=[
         "Hybrid",
         "Early Only",
         "Confirmed Only"
     ],
     group=groupDiv
     )

showBearishDiv = input.bool(
     true,
     "Bearish Divergence",
     group=groupDiv
     )

showBullishDiv = input.bool(
     true,
     "Bullish Divergence",
     group=groupDiv
     )

showDivLabels = input.bool(
     false,
     "Show Divergence Labels",
     group=groupDiv
     )

maxDivergenceItems = input.int(
     40,
     "Max Divergence Lines/Labels",
     minval=1,
     maxval=100,
     group=groupDiv
     )

bearDivColor = input.color(
     color.red,
     "Bearish Divergence Color",
     group=groupDiv
     )

bullDivColor = input.color(
     color.lime,
     "Bullish Divergence Color",
     group=groupDiv
     )

earlyLineWidth = input.int(
     2,
     "Early Divergence Line Width",
     minval=1,
     maxval=5,
     group=groupDiv
     )

confirmedLineWidth = input.int(
     2,
     "Confirmed Divergence Line Width",
     minval=1,
     maxval=5,
     group=groupDiv
     )

divLabelSizeStr = input.string(
     "Small",
     "Divergence Label Size",
     options=[
         "Tiny",
         "Small",
         "Normal",
         "Large",
         "Huge"
     ],
     group=groupDiv
     )

//----------------------------------------------------
// Early Divergence Inputs
//----------------------------------------------------
groupEarly = "Early Divergence"

earlySlopeSmoothing = input.int(
     1,
     "Slope Smoothing",
     minval=1,
     maxval=20,
     group=groupEarly
     )

earlyMinBarsBetweenSwings = input.int(
     1,
     "Min Bars Between Early Swings",
     minval=1,
     maxval=50,
     group=groupEarly
     )

minPriceDiffPct = input.float(
     0.0,
     "Min Price Difference %",
     step=0.1,
     group=groupEarly
     )

minMacdDiffPct = input.float(
     0.0,
     "Min MACD Difference %",
     step=0.1,
     group=groupEarly
     )

//----------------------------------------------------
// Confirmed Divergence Inputs
//----------------------------------------------------
groupConfirmed = "Confirmed Divergence"

pivotLeft = input.int(
     2,
     "Pivot Left Bars",
     minval=1,
     maxval=50,
     group=groupConfirmed
     )

pivotRight = input.int(
     1,
     "Pivot Right Bars",
     minval=1,
     maxval=50,
     group=groupConfirmed
     )

//----------------------------------------------------
// RVOL Signal Inputs
//----------------------------------------------------
groupRvol = "RVOL Signals"

colorMacdBelowNormalRvol = input.bool(
     true,
     "Color MACD When RVOL Below 1.0",
     group=groupRvol,
     tooltip="Changes the MACD line color whenever bar RVOL is below its normal 1.00x level."
     )

showRapidVolumeDrop = input.bool(
     true,
     "Show Rapid Volume Drop",
     group=groupRvol
     )

rvolLength = input.int(
     20,
     "RVOL Historical Periods",
     minval=2,
     group=groupRvol,
     tooltip="Number of previous anchor periods used to calculate normal volume at the same relative time."
     )

volumeAnchorMode = input.string(
     "Auto",
     "RVOL Anchor Timeframe",
     options=[
         "Auto",
         "Custom"
     ],
     group=groupRvol,
     tooltip="Auto uses Daily on intraday charts and the chart timeframe on Daily or higher charts."
     )

customVolumeAnchor = input.timeframe(
     "1D",
     "Custom RVOL Anchor",
     group=groupRvol
     )

rapidDropPercent = input.float(
     35.0,
     "Rapid Volume Drop (%)",
     minval=0.0,
     maxval=100.0,
     step=5.0,
     group=groupRvol,
     tooltip="35% means current bar RVOL is at least 35% lower than the previous bar RVOL."
     )

minimumPreviousRvol = input.float(
     1.00,
     "Minimum Previous-Bar RVOL",
     minval=0.0,
     step=0.10,
     group=groupRvol,
     tooltip="The previous bar must first have at least this much relative volume before a rapid drop is marked."
     )

confirmRvolAtClose = input.bool(
     false,
     "Confirm RVOL at Bar Close",
     group=groupRvol,
     tooltip="When enabled, below-normal MACD coloring and rapid-drop circles are confirmed only after the candle closes."
     )

belowNormalMacdColor = input.color(
     color.black,
     "Below-Normal RVOL MACD Color",
     group=groupRvol
     )

volumeDropCircleColor = input.color(
     color.white,
     "Rapid Drop Circle Color",
     group=groupRvol
     )

volumeDropCircleWidth = input.int(
     3,
     "Rapid Drop Circle Size",
     minval=1,
     maxval=5,
     group=groupRvol
     )

//----------------------------------------------------
// Table Inputs
//----------------------------------------------------
groupTable = "Reading Table"

showTable = input.bool(
     true,
     "Show Reading Table",
     group=groupTable
     )

tablePosition = input.string(
     "Top Right",
     "Table Location",
     options=[
         "Top Right",
         "Top Left",
         "Bottom Right",
         "Bottom Left",
         "Middle Right",
         "Middle Left",
         "Middle Center"
     ],
     group=groupTable
     )

tableTextSize = input.string(
     "Small",
     "Table Text Size",
     options=[
         "Tiny",
         "Small",
         "Normal",
         "Large",
         "Huge"
     ],
     group=groupTable
     )

tableBgColor = input.color(
     color.new(color.black, 10),
     "Table Background",
     group=groupTable
     )

tableHeaderColor = input.color(
     color.new(color.gray, 30),
     "Table Header Background",
     group=groupTable
     )

tableTextColor = input.color(
     color.white,
     "Table Text Color",
     group=groupTable
     )

bullSignalTextColor = input.color(
     color.lime,
     "Bullish Lead Text Color",
     group=groupTable
     )

bearSignalTextColor = input.color(
     color.red,
     "Bearish Lead Text Color",
     group=groupTable
     )

bullFadeTextColor = input.color(
     color.yellow,
     "Bullish Fading Text Color",
     group=groupTable
     )

bearFadeTextColor = input.color(
     color.orange,
     "Bearish Fading Text Color",
     group=groupTable
     )

neutralSignalTextColor = input.color(
     color.gray,
     "Neutral Text Color",
     group=groupTable
     )

//----------------------------------------------------
// Helper Functions
//----------------------------------------------------
f_table_pos(string selectedPosition) =>
    result = position.top_right

    if selectedPosition == "Top Left"
        result := position.top_left
    else if selectedPosition == "Bottom Right"
        result := position.bottom_right
    else if selectedPosition == "Bottom Left"
        result := position.bottom_left
    else if selectedPosition == "Middle Right"
        result := position.middle_right
    else if selectedPosition == "Middle Left"
        result := position.middle_left
    else if selectedPosition == "Middle Center"
        result := position.middle_center
    else
        result := position.top_right

    result

f_text_size(string selectedSize) =>
    result = size.small

    if selectedSize == "Tiny"
        result := size.tiny
    else if selectedSize == "Normal"
        result := size.normal
    else if selectedSize == "Large"
        result := size.large
    else if selectedSize == "Huge"
        result := size.huge
    else
        result := size.small

    result

divLabelSize = f_text_size(divLabelSizeStr)

//----------------------------------------------------
// MACD Calculation
//----------------------------------------------------
fastMA = ta.ema(src, fastLength)
slowMA = ta.ema(src, slowLength)

macdLine = fastMA - slowMA
signalLine = ta.ema(macdLine, signalLength)
histogram = macdLine - signalLine

//----------------------------------------------------
// RVOL Calculation
//----------------------------------------------------
// Intraday charts compare each candle with candles at
// the same relative time in previous daily sessions.
//
// Daily and higher charts use the chart timeframe as
// the automatic anchor.

string automaticVolumeAnchor = (
     timeframe.isintraday
     ? "1D"
     : timeframe.period
     )

string volumeAnchorTimeframe = (
     volumeAnchorMode == "Auto"
     ? automaticVolumeAnchor
     : customVolumeAnchor
     )

[currentBarVolume, averageBarVolume, barRvol] = tvta.relativeVolume(
     rvolLength,
     volumeAnchorTimeframe,
     false,
     false
     )

previousBarRvol = barRvol[1]

barRvolChangePercent = (
     not na(barRvol) and
     not na(previousBarRvol) and
     previousBarRvol != 0.0
     ? 100.0 * (barRvol / previousBarRvol - 1.0)
     : na
     )

rvolSignalAllowed = (
     not confirmRvolAtClose or
     barstate.isconfirmed
     )

// Current candle has below-normal relative volume.
belowNormalRvol = (
     colorMacdBelowNormalRvol and
     rvolSignalAllowed and
     not na(barRvol) and
     barRvol < 1.0
     )

// Use the selected below-normal color whenever RVOL is below 1.00x.
activeMacdColor = (
     belowNormalRvol
     ? belowNormalMacdColor
     : macdColor
     )

// Current candle RVOL fell rapidly versus the previous candle.
rapidVolumeDrop = (
     showRapidVolumeDrop and
     rvolSignalAllowed and
     not na(barRvolChangePercent) and
     barRvolChangePercent <= -rapidDropPercent and
     previousBarRvol >= minimumPreviousRvol
     )

//----------------------------------------------------
// Histogram Coloring
//----------------------------------------------------
histRising = histogram > histogram[histMomentumLen]
histFalling = histogram < histogram[histMomentumLen]

isBullHist = histogram >= 0
isBearHist = histogram < 0

histColor = color.gray

if isBullHist and histRising
    histColor := bullStrongColor
else if isBullHist and histFalling
    histColor := bullWeakColor
else if isBearHist and histFalling
    histColor := bearStrongColor
else if isBearHist and histRising
    histColor := bearWeakColor
else
    histColor := color.gray

//----------------------------------------------------
// Signal Read Logic
//----------------------------------------------------
signalRead = "No Clear Momentum"
signalReadColor = neutralSignalTextColor

if macdLine > signalLine and histogram > 0 and histRising
    signalRead := "Bullish Momentum Lead"
    signalReadColor := bullSignalTextColor
else if macdLine > signalLine and histogram > 0 and histFalling
    signalRead := "Bullish Momentum Fading"
    signalReadColor := bullFadeTextColor
else if macdLine < signalLine and histogram < 0 and histFalling
    signalRead := "Bearish Momentum Lead"
    signalReadColor := bearSignalTextColor
else if macdLine < signalLine and histogram < 0 and histRising
    signalRead := "Bearish Momentum Fading"
    signalReadColor := bearFadeTextColor
else if macdLine > signalLine
    signalRead := "Early Bullish Turn"
    signalReadColor := bullSignalTextColor
else if macdLine < signalLine
    signalRead := "Early Bearish Turn"
    signalReadColor := bearSignalTextColor
else
    signalRead := "No Clear Momentum"
    signalReadColor := neutralSignalTextColor

//----------------------------------------------------
// Market Stage Analysis
//----------------------------------------------------
macdNorm = ta.stdev(macdLine, stageNormLen)

signalSlopeRaw = (
     signalLine -
     nz(signalLine[stageSlopeLen], signalLine)
     )

signalSlopeScore = 0.0

if macdNorm != 0.0
    signalSlopeScore := (
         100.0 *
         signalSlopeRaw /
         macdNorm
         )
else
    signalSlopeScore := 0.0

signalRising = signalSlopeScore > stageFlatThreshold
signalFalling = signalSlopeScore < -stageFlatThreshold
signalFlat = not signalRising and not signalFalling

aboveSignal = macdLine > signalLine
belowSignal = macdLine < signalLine

histAboveZero = histogram > 0
histBelowZero = histogram < 0

marketStage = "Market Transition"
marketStageBias = "Mixed / Wait"
marketStageColor = neutralStageColor

if signalRising and histAboveZero and histRising and aboveSignal
    marketStage := "Stage 2 Bullish Momentum Expansion"
    marketStageBias := "Bullish Momentum Expanding"
    marketStageColor := stage2Color
else if histAboveZero and histFalling
    marketStage := "Stage 3 Momentum Distribution"
    marketStageBias := "Bullish Momentum Weakening"
    marketStageColor := stage3Color
else if signalFalling and histBelowZero and histFalling and belowSignal
    marketStage := "Stage 4 Bearish Momentum Expansion"
    marketStageBias := "Bearish Momentum Expanding"
    marketStageColor := stage4Color
else if histBelowZero and histRising
    marketStage := "Stage 1 Momentum Base"
    marketStageBias := "Bearish Momentum Weakening"
    marketStageColor := stage1Color
else if signalRising and histBelowZero
    marketStage := "Stage 1 Momentum Base"
    marketStageBias := "Momentum Improving"
    marketStageColor := stage1Color
else if signalFalling and histAboveZero
    marketStage := "Stage 3 Momentum Distribution"
    marketStageBias := "Momentum Weakening"
    marketStageColor := stage3Color
else if signalFlat
    marketStage := "Market Transition"
    marketStageBias := "Mixed / Wait"
    marketStageColor := neutralStageColor
else
    marketStage := "Market Transition"
    marketStageBias := "Mixed / Wait"
    marketStageColor := neutralStageColor

//----------------------------------------------------
// Main Plots
//----------------------------------------------------
hline(
     0,
     "Zero Line",
     color=color.new(color.gray, 60)
     )

plot(
     showHistogram ? histogram : na,
     title="MACD Histogram",
     style=plot.style_columns,
     color=histColor
     )

plot(
     showMacdLine ? macdLine : na,
     title="MACD Line",
     color=activeMacdColor,
     linewidth=1
     )

plot(
     showSignalLine ? signalLine : na,
     title="Signal Line",
     color=signalColor,
     linewidth=1
     )

// White circle:
// Bar RVOL dropped at least 35% versus the previous bar.
plot(
     rapidVolumeDrop ? macdLine : na,
     title="Rapid Volume Drop on MACD",
     style=plot.style_circles,
     color=volumeDropCircleColor,
     linewidth=volumeDropCircleWidth
     )

// Supporting RVOL values shown in TradingView's Data Window.
plot(
     barRvol,
     title="Bar RVOL at Time",
     display=display.data_window
     )

plot(
     barRvolChangePercent,
     title="Bar RVOL Change %",
     display=display.data_window
     )

//----------------------------------------------------
// Divergence Drawing Helpers
//----------------------------------------------------
var array<line> divLines = array.new_line()
var array<label> divLabels = array.new_label()

f_add_div_line(
     x1,
     y1,
     x2,
     y2,
     divColor,
     lineWidth,
     lineStyle
     ) =>

    _line = line.new(
         x1,
         y1,
         x2,
         y2,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=divColor,
         width=lineWidth,
         style=lineStyle
         )

    array.push(divLines, _line)

    if array.size(divLines) > maxDivergenceItems
        _oldLine = array.shift(divLines)
        line.delete(_oldLine)

f_add_div_label(
     x,
     y,
     txt,
     divColor,
     labelStyle
     ) =>

    if showDivLabels
        _label = label.new(
             x,
             y,
             txt,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=labelStyle,
             color=color.new(divColor, 0),
             textcolor=color.white,
             size=divLabelSize
             )

        array.push(divLabels, _label)

        if array.size(divLabels) > maxDivergenceItems
            _oldLabel = array.shift(divLabels)
            label.delete(_oldLabel)

//----------------------------------------------------
// Divergence Mode Controls
//----------------------------------------------------
useEarly = (
     showDivergence and
     (
         divergenceMode == "Hybrid" or
         divergenceMode == "Early Only"
     )
     )

useConfirmed = (
     showDivergence and
     (
         divergenceMode == "Hybrid" or
         divergenceMode == "Confirmed Only"
     )
     )

//----------------------------------------------------
// Divergence Alert Variables
//----------------------------------------------------
earlyBearSignal = false
earlyBullSignal = false
confirmedBearSignal = false
confirmedBullSignal = false

//----------------------------------------------------
// Early Divergence Logic
//----------------------------------------------------
macdTurnSource = ta.ema(
     macdLine,
     earlySlopeSmoothing
     )

macdSlope = (
     macdTurnSource -
     macdTurnSource[1]
     )

macdTurnDown = (
     macdSlope < 0 and
     macdSlope[1] >= 0
     )

macdTurnUp = (
     macdSlope > 0 and
     macdSlope[1] <= 0
     )

var float prevEarlyPriceHigh = na
var float prevEarlyMacdHigh = na
var int prevEarlyHighBar = na

var float prevEarlyPriceLow = na
var float prevEarlyMacdLow = na
var int prevEarlyLowBar = na

if useEarly
    if macdTurnDown and not na(macdLine[1])
        currEarlyHighBar = bar_index - 1
        currEarlyPriceHigh = high[1]
        currEarlyMacdHigh = macdLine[1]

        enoughBarsHigh = (
             na(prevEarlyHighBar) or
             currEarlyHighBar - prevEarlyHighBar >=
             earlyMinBarsBetweenSwings
             )

        priceHighDiff = (
             math.abs(
                 nz(
                     prevEarlyPriceHigh,
                     currEarlyPriceHigh
                     )
                 ) *
             minPriceDiffPct /
             100.0
             )

        macdHighDiff = (
             math.abs(
                 nz(
                     prevEarlyMacdHigh,
                     currEarlyMacdHigh
                     )
                 ) *
             minMacdDiffPct /
             100.0
             )

        priceHigher = (
             not na(prevEarlyPriceHigh) and
             currEarlyPriceHigh >
             prevEarlyPriceHigh + priceHighDiff
             )

        macdLower = (
             not na(prevEarlyMacdHigh) and
             currEarlyMacdHigh <
             prevEarlyMacdHigh - macdHighDiff
             )

        if (
             showBearishDiv and
             enoughBarsHigh and
             priceHigher and
             macdLower
             )

            f_add_div_line(
                 prevEarlyHighBar,
                 prevEarlyMacdHigh,
                 currEarlyHighBar,
                 currEarlyMacdHigh,
                 bearDivColor,
                 earlyLineWidth,
                 line.style_dashed
                 )

            f_add_div_label(
                 currEarlyHighBar,
                 currEarlyMacdHigh,
                 "Early Bear",
                 bearDivColor,
                 label.style_label_down
                 )

            earlyBearSignal := true

        if enoughBarsHigh
            prevEarlyPriceHigh := currEarlyPriceHigh
            prevEarlyMacdHigh := currEarlyMacdHigh
            prevEarlyHighBar := currEarlyHighBar

    if macdTurnUp and not na(macdLine[1])
        currEarlyLowBar = bar_index - 1
        currEarlyPriceLow = low[1]
        currEarlyMacdLow = macdLine[1]

        enoughBarsLow = (
             na(prevEarlyLowBar) or
             currEarlyLowBar - prevEarlyLowBar >=
             earlyMinBarsBetweenSwings
             )

        priceLowDiff = (
             math.abs(
                 nz(
                     prevEarlyPriceLow,
                     currEarlyPriceLow
                     )
                 ) *
             minPriceDiffPct /
             100.0
             )

        macdLowDiff = (
             math.abs(
                 nz(
                     prevEarlyMacdLow,
                     currEarlyMacdLow
                     )
                 ) *
             minMacdDiffPct /
             100.0
             )

        priceLower = (
             not na(prevEarlyPriceLow) and
             currEarlyPriceLow <
             prevEarlyPriceLow - priceLowDiff
             )

        macdHigher = (
             not na(prevEarlyMacdLow) and
             currEarlyMacdLow >
             prevEarlyMacdLow + macdLowDiff
             )

        if (
             showBullishDiv and
             enoughBarsLow and
             priceLower and
             macdHigher
             )

            f_add_div_line(
                 prevEarlyLowBar,
                 prevEarlyMacdLow,
                 currEarlyLowBar,
                 currEarlyMacdLow,
                 bullDivColor,
                 earlyLineWidth,
                 line.style_dashed
                 )

            f_add_div_label(
                 currEarlyLowBar,
                 currEarlyMacdLow,
                 "Early Bull",
                 bullDivColor,
                 label.style_label_up
                 )

            earlyBullSignal := true

        if enoughBarsLow
            prevEarlyPriceLow := currEarlyPriceLow
            prevEarlyMacdLow := currEarlyMacdLow
            prevEarlyLowBar := currEarlyLowBar

//----------------------------------------------------
// Confirmed Divergence Logic
//----------------------------------------------------
macdPivotHigh = ta.pivothigh(
     macdLine,
     pivotLeft,
     pivotRight
     )

macdPivotLow = ta.pivotlow(
     macdLine,
     pivotLeft,
     pivotRight
     )

var float prevConfirmedPriceHigh = na
var float prevConfirmedMacdHigh = na
var int prevConfirmedHighBar = na

var float prevConfirmedPriceLow = na
var float prevConfirmedMacdLow = na
var int prevConfirmedLowBar = na

if useConfirmed
    if not na(macdPivotHigh)
        currConfirmedHighBar = bar_index - pivotRight
        currConfirmedPriceHigh = high[pivotRight]
        currConfirmedMacdHigh = macdPivotHigh

        priceHighDiffConfirmed = (
             math.abs(
                 nz(
                     prevConfirmedPriceHigh,
                     currConfirmedPriceHigh
                     )
                 ) *
             minPriceDiffPct /
             100.0
             )

        macdHighDiffConfirmed = (
             math.abs(
                 nz(
                     prevConfirmedMacdHigh,
                     currConfirmedMacdHigh
                     )
                 ) *
             minMacdDiffPct /
             100.0
             )

        priceHigherConfirmed = (
             not na(prevConfirmedPriceHigh) and
             currConfirmedPriceHigh >
             prevConfirmedPriceHigh +
             priceHighDiffConfirmed
             )

        macdLowerConfirmed = (
             not na(prevConfirmedMacdHigh) and
             currConfirmedMacdHigh <
             prevConfirmedMacdHigh -
             macdHighDiffConfirmed
             )

        if (
             showBearishDiv and
             priceHigherConfirmed and
             macdLowerConfirmed
             )

            f_add_div_line(
                 prevConfirmedHighBar,
                 prevConfirmedMacdHigh,
                 currConfirmedHighBar,
                 currConfirmedMacdHigh,
                 bearDivColor,
                 confirmedLineWidth,
                 line.style_solid
                 )

            f_add_div_label(
                 currConfirmedHighBar,
                 currConfirmedMacdHigh,
                 "Bear Div",
                 bearDivColor,
                 label.style_label_down
                 )

            confirmedBearSignal := true

        prevConfirmedPriceHigh := currConfirmedPriceHigh
        prevConfirmedMacdHigh := currConfirmedMacdHigh
        prevConfirmedHighBar := currConfirmedHighBar

    if not na(macdPivotLow)
        currConfirmedLowBar = bar_index - pivotRight
        currConfirmedPriceLow = low[pivotRight]
        currConfirmedMacdLow = macdPivotLow

        priceLowDiffConfirmed = (
             math.abs(
                 nz(
                     prevConfirmedPriceLow,
                     currConfirmedPriceLow
                     )
                 ) *
             minPriceDiffPct /
             100.0
             )

        macdLowDiffConfirmed = (
             math.abs(
                 nz(
                     prevConfirmedMacdLow,
                     currConfirmedMacdLow
                     )
                 ) *
             minMacdDiffPct /
             100.0
             )

        priceLowerConfirmed = (
             not na(prevConfirmedPriceLow) and
             currConfirmedPriceLow <
             prevConfirmedPriceLow -
             priceLowDiffConfirmed
             )

        macdHigherConfirmed = (
             not na(prevConfirmedMacdLow) and
             currConfirmedMacdLow >
             prevConfirmedMacdLow +
             macdLowDiffConfirmed
             )

        if (
             showBullishDiv and
             priceLowerConfirmed and
             macdHigherConfirmed
             )

            f_add_div_line(
                 prevConfirmedLowBar,
                 prevConfirmedMacdLow,
                 currConfirmedLowBar,
                 currConfirmedMacdLow,
                 bullDivColor,
                 confirmedLineWidth,
                 line.style_solid
                 )

            f_add_div_label(
                 currConfirmedLowBar,
                 currConfirmedMacdLow,
                 "Bull Div",
                 bullDivColor,
                 label.style_label_up
                 )

            confirmedBullSignal := true

        prevConfirmedPriceLow := currConfirmedPriceLow
        prevConfirmedMacdLow := currConfirmedMacdLow
        prevConfirmedLowBar := currConfirmedLowBar

//----------------------------------------------------
// Reading Table
//----------------------------------------------------
var table readTable = table.new(
     f_table_pos(tablePosition),
     2,
     3,
     border_width=1
     )

txtSize = f_text_size(tableTextSize)

if barstate.islast
    if showTable
        table.cell(
             readTable,
             0,
             0,
             "Signal",
             text_color=tableTextColor,
             bgcolor=tableHeaderColor,
             text_size=txtSize
             )

        table.cell(
             readTable,
             1,
             0,
             signalRead,
             text_color=signalReadColor,
             bgcolor=tableHeaderColor,
             text_size=txtSize
             )

        table.cell(
             readTable,
             0,
             1,
             "Market Stage",
             text_color=tableTextColor,
             bgcolor=tableBgColor,
             text_size=txtSize
             )

        if showMarketStageRead
            table.cell(
                 readTable,
                 1,
                 1,
                 marketStage,
                 text_color=color.white,
                 bgcolor=color.new(
                     marketStageColor,
                     25
                     ),
                 text_size=txtSize
                 )
        else
            table.cell(
                 readTable,
                 1,
                 1,
                 "Off",
                 text_color=tableTextColor,
                 bgcolor=tableBgColor,
                 text_size=txtSize
                 )

        table.cell(
             readTable,
             0,
             2,
             "Stage Bias",
             text_color=tableTextColor,
             bgcolor=tableBgColor,
             text_size=txtSize
             )

        if showMarketStageRead
            table.cell(
                 readTable,
                 1,
                 2,
                 marketStageBias,
                 text_color=tableTextColor,
                 bgcolor=tableBgColor,
                 text_size=txtSize
                 )
        else
            table.cell(
                 readTable,
                 1,
                 2,
                 "Off",
                 text_color=tableTextColor,
                 bgcolor=tableBgColor,
                 text_size=txtSize
                 )
    else
        table.clear(
             readTable,
             0,
             0,
             1,
             2
             )

//----------------------------------------------------
// Alerts
//----------------------------------------------------
bullCross = ta.crossover(
     macdLine,
     signalLine
     )

bearCross = ta.crossunder(
     macdLine,
     signalLine
     )

alertcondition(
     bullCross,
     "Bullish MACD Cross",
     "MACD line crossed above the signal line."
     )

alertcondition(
     bearCross,
     "Bearish MACD Cross",
     "MACD line crossed below the signal line."
     )

alertcondition(
     marketStage == "Stage 1 Momentum Base",
     "Stage 1 Momentum Base",
     "MACD reading is showing Stage 1 Momentum Base."
     )

alertcondition(
     marketStage == "Stage 2 Bullish Momentum Expansion",
     "Stage 2 Bullish Momentum Expansion",
     "MACD reading is showing Stage 2 Bullish Momentum Expansion."
     )

alertcondition(
     marketStage == "Stage 3 Momentum Distribution",
     "Stage 3 Momentum Distribution",
     "MACD reading is showing Stage 3 Momentum Distribution."
     )

alertcondition(
     marketStage == "Stage 4 Bearish Momentum Expansion",
     "Stage 4 Bearish Momentum Expansion",
     "MACD reading is showing Stage 4 Bearish Momentum Expansion."
     )

alertcondition(
     earlyBearSignal,
     "Early Bearish MACD Divergence",
     "Early bearish divergence detected between price and MACD line."
     )

alertcondition(
     earlyBullSignal,
     "Early Bullish MACD Divergence",
     "Early bullish divergence detected between price and MACD line."
     )

alertcondition(
     confirmedBearSignal,
     "Confirmed Bearish MACD Divergence",
     "Confirmed bearish divergence detected between price and MACD line."
     )

alertcondition(
     confirmedBullSignal,
     "Confirmed Bullish MACD Divergence",
     "Confirmed bullish divergence detected between price and MACD line."
     )

alertcondition(
     rapidVolumeDrop,
     "Rapid Volume Drop on MACD",
     "Bar relative volume dropped by at least the selected percentage. A circle is plotted on the MACD line."
     )
````

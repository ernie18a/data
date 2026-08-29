<!-- tradingview-pine-id: PUB;9f6cca1eda904779af515c1d583c2824 -->
<!-- tradingviewscripts-format: 1 -->
# XAUUSD Vector Pressure + Lux Liquidity Swings + ZScore + SMC

Source: https://www.tradingview.com/script/pBHfcX2q-XAUUSD-Pressure-Liquidity-Volume-OB-FVG/

## Description

XAUUSD Pressure + Liquidity Volume + OB + FVG, this script have 80% win rate 
🟢 Green Vector: Extreme bullish volume/spread. This represents aggressive buying or short covering by institutions.
🔴 Red Vector: Extreme bearish volume/spread. This represents aggressive selling or long liquidation.
🔵 / 🟣 Blue or Violet/Fuchsia: Above-average volume. Signals that market makers are actively stepping into the market.

---

## Source Code

````pine
// This indicator includes an adapted Liquidity Swings module originally by LuxAlgo.
// Original module license: CC BY-NC-SA 4.0
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo
//
//@version=6
indicator(
     "XAUUSD Vector Pressure + Lux Liquidity Swings + ZScore + SMC",
     overlay=true,
     max_lines_count=500,
     max_labels_count=500,
     max_boxes_count=500
)

//====================================================
// INPUTS
//====================================================

// VWAP
showVWAP = input.bool(true, "Show Daily VWAP")

// Structure
pivotLeft = input.int(3, "Pivot Left Bars", minval=1)
pivotRight = input.int(3, "Pivot Right Bars", minval=1)
requireCloseBreak = input.bool(true, "Require Close Beyond Structure")
showStructureLines = input.bool(true, "Show BOS / CHoCH Lines")

// ADX
adxLength = input.int(14, "ADX DI Length", minval=1)
adxSmoothing = input.int(14, "ADX Smoothing", minval=1)
minimumADX = input.float(20.0, "Minimum ADX", minval=0.0)

// Vector / PVSRA candle engine
vectorVolumeLength = input.int(
     10,
     "Vector Average Volume Length",
     minval=2
)

vectorSpreadLength = input.int(
     10,
     "Volume × Spread Lookback",
     minval=2
)

vectorRisingMultiple = input.float(
     1.50,
     "150% Vector Volume Multiple",
     minval=1.0,
     step=0.05
)

vectorClimaxMultiple = input.float(
     2.00,
     "200% Vector Volume Multiple",
     minval=1.0,
     step=0.05
)

colorVectorCandles = input.bool(
     true,
     "Color Candles with Vector Structure"
)

showNormalVectorColors = input.bool(
     true,
     "Color Normal Candles Grey"
)

bullClimaxColor = input.color(
     color.lime,
     "Bull 200% / Climax Color"
)

bearClimaxColor = input.color(
     color.red,
     "Bear 200% / Climax Color"
)

bullRisingColor = input.color(
     color.blue,
     "Bull 150% Color"
)

bearRisingColor = input.color(
     color.fuchsia,
     "Bear 150% Color"
)

bullNormalColor = input.color(
     color.rgb(153, 153, 153),
     "Bull Normal Color"
)

bearNormalColor = input.color(
     color.rgb(77, 77, 77),
     "Bear Normal Color"
)

// Pressure meter
signalThreshold = input.int(80, "Pressure Signal Threshold", minval=20, maxval=100)
showPressureTable = input.bool(true, "Show Pressure Meter")
showSignals = input.bool(true, "Show BUY / SELL Signals")
signalCooldownBars = input.int(5, "Signal Cooldown Bars", minval=0)

// Z-Score + SMA
useZScoreFilter = input.bool(true, "Use Z-Score Filter")
zScoreLookback = input.int(20, "Z-Score Lookback", minval=2)
zScoreSMALength = input.int(50, "Z-Score SMA Length", minval=1)
buyZScoreLevel = input.float(1.0, "Buy Z-Score Minimum", step=0.1)
sellZScoreLevel = input.float(-1.0, "Sell Z-Score Maximum", step=0.1)
showZScoreTable = input.bool(true, "Show Z-Score in Pressure Table")

// Liquidity Swings [LuxAlgo-style parameters]
luxLength = input.int(14, "Pivot Lookback", minval=1, group="Liquidity Swings")
luxArea = input.string("Wick Extremity", "Swing Area", options=["Wick Extremity", "Full Range"], group="Liquidity Swings")
luxIntraPrecision = input.bool(false, "Intrabar Precision", inline="luxIntrabar", group="Liquidity Swings")
luxIntrabarTf = input.timeframe("1", "", inline="luxIntrabar", group="Liquidity Swings")
luxFilterOptions = input.string("Count", "Filter Areas By", options=["Count", "Volume"], inline="luxFilter", group="Liquidity Swings")
luxFilterValue = input.float(0, "", inline="luxFilter", group="Liquidity Swings")

luxShowTop = input.bool(true, "Swing High", inline="luxTop", group="Liquidity Swings Style")
luxTopCss = input.color(color.red, "", inline="luxTop", group="Liquidity Swings Style")
luxTopAreaCss = input.color(color.new(color.red, 50), "Area", inline="luxTop", group="Liquidity Swings Style")
luxShowBtm = input.bool(true, "Swing Low", inline="luxBtm", group="Liquidity Swings Style")
luxBtmCss = input.color(color.teal, "", inline="luxBtm", group="Liquidity Swings Style")
luxBtmAreaCss = input.color(color.new(color.teal, 50), "Area", inline="luxBtm", group="Liquidity Swings Style")
luxLabelSize = input.string("Tiny", "Labels Size", options=["Tiny", "Small", "Normal"], group="Liquidity Swings Style")

// Order blocks
showOrderBlocks = input.bool(true, "Show Order Blocks")
orderBlockLookback = input.int(10, "Order Block Search Lookback", minval=1, maxval=50)
orderBlockExtension = input.int(50, "Order Block Extension Bars", minval=1)
useOrderBlockBody = input.bool(false, "Use Candle Body Only for Order Block")
bullishOBColor = input.color(color.new(color.teal, 84), "Bullish Order Block Color")
bearishOBColor = input.color(color.new(color.orange, 84), "Bearish Order Block Color")

// Fair value gaps
showFVG = input.bool(true, "Show Fair Value Gaps")
fvgExtensionBars = input.int(40, "FVG Extension Bars", minval=1)
minimumFVGSizeTicks = input.int(1, "Minimum FVG Size in Ticks", minval=0)
bullishFVGColor = input.color(color.new(color.aqua, 86), "Bullish FVG Color")
bearishFVGColor = input.color(color.new(color.fuchsia, 86), "Bearish FVG Color")

//====================================================
// DAILY VWAP
//====================================================

newDay = ta.change(time("D")) != 0

var float cumulativePV = na
var float cumulativeVolume = na

typicalPrice = hlc3
barVolume = math.max(volume, 1)

if newDay or na(cumulativePV)
    cumulativePV := typicalPrice * barVolume
    cumulativeVolume := barVolume
else
    cumulativePV += typicalPrice * barVolume
    cumulativeVolume += barVolume

dailyVWAP = cumulativePV / cumulativeVolume

plot(
     showVWAP ? dailyVWAP : na,
     title="Daily VWAP",
     color=color.yellow,
     linewidth=2
)

trendSMA50 = ta.sma(close, zScoreSMALength)

plot(
     trendSMA50,
     title="SMA 50",
     color=color.blue,
     linewidth=2
)

//====================================================
// ADX / DI
//====================================================

[plusDI, minusDI, adxValue] = ta.dmi(adxLength, adxSmoothing)

adxStrong = adxValue >= minimumADX
bullishDI = plusDI > minusDI
bearishDI = minusDI > plusDI

//====================================================
// VECTOR / PVSRA CANDLE STRUCTURE
//====================================================

// This follows the stronger vector-candle method:
// 1) 200% / climax candle when volume >= 2× average volume,
//    OR volume × candle spread is the highest in the lookback.
// 2) 150% candle when volume >= 1.5× average volume.
// 3) Remaining candles are normal-volume candles.

vectorAverageVolume = ta.sma(
     volume,
     vectorVolumeLength
)

vectorSpread = math.max(
     high - low,
     syminfo.mintick
)

vectorVolumeSpread =
     volume * vectorSpread

vectorHighestVolumeSpread = ta.highest(
     vectorVolumeSpread,
     vectorSpreadLength
)

bullishCandle = close > open
bearishCandle = close < open
dojiCandle = close == open

vectorClimax =
     not na(vectorAverageVolume) and
     (
          volume >= vectorAverageVolume * vectorClimaxMultiple or
          vectorVolumeSpread >= vectorHighestVolumeSpread
     )

vectorRising =
     not vectorClimax and
     not na(vectorAverageVolume) and
     volume >= vectorAverageVolume * vectorRisingMultiple

bullishClimax = bullishCandle and vectorClimax
bearishClimax = bearishCandle and vectorClimax

bullishRisingVolume =
     bullishCandle and
     vectorRising

bearishRisingVolume =
     bearishCandle and
     vectorRising

bullishNormalVolume =
     bullishCandle and
     not vectorClimax and
     not vectorRising

bearishNormalVolume =
     bearishCandle and
     not vectorClimax and
     not vectorRising

vectorClass =
     bullishClimax ? 3 :
     bearishClimax ? -3 :
     bullishRisingVolume ? 2 :
     bearishRisingVolume ? -2 :
     bullishNormalVolume ? 1 :
     bearishNormalVolume ? -1 :
     0

vectorBarColor =
     bullishClimax ? bullClimaxColor :
     bearishClimax ? bearClimaxColor :
     bullishRisingVolume ? bullRisingColor :
     bearishRisingVolume ? bearRisingColor :
     bullishNormalVolume and showNormalVectorColors ? bullNormalColor :
     bearishNormalVolume and showNormalVectorColors ? bearNormalColor :
     na

barcolor(
     colorVectorCandles
     ? vectorBarColor
     : na
)

// Optional compact vector markers.
showVectorMarkers = input.bool(
     false,
     "Show Vector Candle Markers"
)

plotshape(
     showVectorMarkers and bullishClimax,
     title="Bullish 200% Vector",
     style=shape.diamond,
     location=location.belowbar,
     color=bullClimaxColor,
     text="200",
     textcolor=color.black,
     size=size.tiny
)

plotshape(
     showVectorMarkers and bearishClimax,
     title="Bearish 200% Vector",
     style=shape.diamond,
     location=location.abovebar,
     color=bearClimaxColor,
     text="200",
     textcolor=color.white,
     size=size.tiny
)

plotshape(
     showVectorMarkers and bullishRisingVolume,
     title="Bullish 150% Vector",
     style=shape.circle,
     location=location.belowbar,
     color=bullRisingColor,
     size=size.tiny
)

plotshape(
     showVectorMarkers and bearishRisingVolume,
     title="Bearish 150% Vector",
     style=shape.circle,
     location=location.abovebar,
     color=bearRisingColor,
     size=size.tiny
)

//====================================================
// STRUCTURE
//====================================================

pivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)
pivotLow = ta.pivotlow(low, pivotLeft, pivotRight)

var float lastSwingHigh = na
var float lastSwingLow = na

var int lastSwingHighBar = na
var int lastSwingLowBar = na

var bool highBroken = false
var bool lowBroken = false

if not na(pivotHigh)
    lastSwingHigh := pivotHigh
    lastSwingHighBar := bar_index - pivotRight
    highBroken := false

if not na(pivotLow)
    lastSwingLow := pivotLow
    lastSwingLowBar := bar_index - pivotRight
    lowBroken := false

//====================================================
// Z-SCORE + Z-SCORE SMA
//====================================================

zMean = ta.sma(close, zScoreLookback)
zStd = ta.stdev(close, zScoreLookback)

zScore =
     not na(zStd) and zStd > 0
     ? (close - zMean) / zStd
     : 0.0

zScoreSMA = ta.sma(zScore, zScoreSMALength)

zBullish =
     not useZScoreFilter or
     (zScore >= buyZScoreLevel and zScore > zScoreSMA)

zBearish =
     not useZScoreFilter or
     (zScore <= sellZScoreLevel and zScore < zScoreSMA)

//====================================================
// LIQUIDITY SWINGS — LUXALGO-STYLE
//====================================================

luxN = bar_index

luxGetData() =>
    [high, low, volume]

[luxH, luxL, luxV] = request.security_lower_tf(
     syminfo.tickerid,
     luxIntrabarTf,
     luxGetData()
)

luxGetCounts(condition, top, btm) =>
    var int count = 0
    var float vol = 0.0

    if condition
        count := 0
        vol := 0.0
    else
        if luxIntraPrecision
            if luxN > luxLength and array.size(luxV[luxLength]) > 0
                for [index, element] in luxV[luxLength]
                    vol += (
                         array.get(luxL[luxLength], index) < top and
                         array.get(luxH[luxLength], index) > btm
                    ) ? element : 0
        else
            vol += (
                 low[luxLength] < top and
                 high[luxLength] > btm
            ) ? volume[luxLength] : 0

        count += (
             low[luxLength] < top and
             high[luxLength] > btm
        ) ? 1 : 0

    [count, vol]

luxSetLabel(count, vol, x, y, css, lblStyle) =>
    var label lbl = na

    lblSize = switch luxLabelSize
        "Tiny" => size.tiny
        "Small" => size.small
        => size.normal

    target = luxFilterOptions == "Count" ? count : vol

    if ta.crossover(target, luxFilterValue)
        lbl := label.new(
             x,
             y,
             str.tostring(vol, format.volume),
             style=lblStyle,
             size=lblSize,
             color=#00000000,
             textcolor=css
        )

    if target > luxFilterValue and not na(lbl)
        label.set_text(lbl, str.tostring(vol, format.volume))

luxSetLevel(condition, crossed, value, count, vol, css) =>
    var line lvl = na
    target = luxFilterOptions == "Count" ? count : vol

    if condition
        if target[1] < luxFilterValue[1]
            if not na(lvl[1])
                line.delete(lvl[1])
        else if not crossed[1] and not na(lvl)
            line.set_x2(lvl, luxN - luxLength)

        lvl := line.new(
             luxN - luxLength,
             value,
             luxN,
             value,
             color=na
        )

    if not crossed[1] and not na(lvl)
        line.set_x2(lvl, luxN + 3)

    if crossed and not crossed[1] and not na(lvl)
        line.set_x2(lvl, luxN)
        line.set_style(lvl, line.style_dashed)

    if target > luxFilterValue and not na(lvl)
        line.set_color(lvl, css)

luxSetZone(condition, x, top, btm, count, vol, css) =>
    var box bx = na
    target = luxFilterOptions == "Count" ? count : vol

    if ta.crossover(target, luxFilterValue)
        bx := box.new(
             x,
             top,
             x + count,
             btm,
             border_color=na,
             bgcolor=css
        )

    if target > luxFilterValue and not na(bx)
        box.set_right(bx, x + count)

// Pivot high state
var float luxPhTop = na
var float luxPhBtm = na
var bool luxPhCrossed = false
var int luxPhX1 = 0
var box luxPhBx = box.new(na, na, na, na, bgcolor=color.new(luxTopAreaCss, 80), border_color=na)

// Pivot low state
var float luxPlTop = na
var float luxPlBtm = na
var bool luxPlCrossed = false
var int luxPlX1 = 0
var box luxPlBx = box.new(na, na, na, na, bgcolor=color.new(luxBtmAreaCss, 80), border_color=na)

// Pivot high
luxPh = ta.pivothigh(luxLength, luxLength)
luxPhCondition = not na(luxPh)
[luxPhCount, luxPhVol] = luxGetCounts(luxPhCondition, luxPhTop, luxPhBtm)

if luxPhCondition and luxShowTop
    luxPhTop := high[luxLength]
    luxPhBtm := luxArea == "Wick Extremity" ? math.max(close[luxLength], open[luxLength]) : low[luxLength]
    luxPhX1 := luxN - luxLength
    luxPhCrossed := false
    box.set_lefttop(luxPhBx, luxPhX1, luxPhTop)
    box.set_rightbottom(luxPhBx, luxPhX1, luxPhBtm)
else
    luxPhCrossed := not na(luxPhTop) and close > luxPhTop ? true : luxPhCrossed
    box.set_right(luxPhBx, luxPhCrossed ? luxPhX1 : luxN + 3)

if luxShowTop
    luxSetZone(luxPhCondition, luxPhX1, luxPhTop, luxPhBtm, luxPhCount, luxPhVol, luxTopAreaCss)
    luxSetLevel(luxPhCondition, luxPhCrossed, luxPhTop, luxPhCount, luxPhVol, luxTopCss)
    luxSetLabel(luxPhCount, luxPhVol, luxPhX1, luxPhTop, luxTopCss, label.style_label_down)

// Pivot low
luxPl = ta.pivotlow(luxLength, luxLength)
luxPlCondition = not na(luxPl)
[luxPlCount, luxPlVol] = luxGetCounts(luxPlCondition, luxPlTop, luxPlBtm)

if luxPlCondition and luxShowBtm
    luxPlTop := luxArea == "Wick Extremity" ? math.min(close[luxLength], open[luxLength]) : high[luxLength]
    luxPlBtm := low[luxLength]
    luxPlX1 := luxN - luxLength
    luxPlCrossed := false
    box.set_lefttop(luxPlBx, luxPlX1, luxPlTop)
    box.set_rightbottom(luxPlBx, luxPlX1, luxPlBtm)
else
    luxPlCrossed := not na(luxPlBtm) and close < luxPlBtm ? true : luxPlCrossed
    box.set_right(luxPlBx, luxPlCrossed ? luxPlX1 : luxN + 3)

if luxShowBtm
    luxSetZone(luxPlCondition, luxPlX1, luxPlTop, luxPlBtm, luxPlCount, luxPlVol, luxBtmAreaCss)
    luxSetLevel(luxPlCondition, luxPlCrossed, luxPlBtm, luxPlCount, luxPlVol, luxBtmCss)
    luxSetLabel(luxPlCount, luxPlVol, luxPlX1, luxPlBtm, luxBtmCss, label.style_label_up)

// Compatibility aliases for pressure table and alerts.
bullishLiquiditySweep = luxPlCrossed and not luxPlCrossed[1]
bearishLiquiditySweep = luxPhCrossed and not luxPhCrossed[1]
bullishLiquiditySweepRaw = bullishLiquiditySweep
bearishLiquiditySweepRaw = bearishLiquiditySweep
liquidityVolumeRatio = bullishLiquiditySweep ? luxPlVol : bearishLiquiditySweep ? luxPhVol : 0.0
liquidityVolumeOK = bullishLiquiditySweep or bearishLiquiditySweep

//====================================================
// BOS / CHoCH
//====================================================

bullishBreak =
     not na(lastSwingHigh) and
     not highBroken and
     (requireCloseBreak ? close > lastSwingHigh : high > lastSwingHigh)

bearishBreak =
     not na(lastSwingLow) and
     not lowBroken and
     (requireCloseBreak ? close < lastSwingLow : low < lastSwingLow)

// 1 = bullish, -1 = bearish, 0 = undefined
var int structureTrend = 0

bool bullishBOS = false
bool bearishBOS = false
bool bullishCHoCH = false
bool bearishCHoCH = false

if bullishBreak
    highBroken := true

    if structureTrend == -1
        bullishCHoCH := true
    else
        bullishBOS := true

    structureTrend := 1

if bearishBreak
    lowBroken := true

    if structureTrend == 1
        bearishCHoCH := true
    else
        bearishBOS := true

    structureTrend := -1

//====================================================
// STRUCTURE LINES
//====================================================

if showStructureLines and bullishBOS
    line.new(
         lastSwingHighBar,
         lastSwingHigh,
         bar_index,
         lastSwingHigh,
         color=color.green,
         style=line.style_solid,
         width=2
    )

    label.new(
         bar_index,
         lastSwingHigh,
         "BOS",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.tiny
    )

if showStructureLines and bearishBOS
    line.new(
         lastSwingLowBar,
         lastSwingLow,
         bar_index,
         lastSwingLow,
         color=color.red,
         style=line.style_solid,
         width=2
    )

    label.new(
         bar_index,
         lastSwingLow,
         "BOS",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.tiny
    )

if showStructureLines and bullishCHoCH
    line.new(
         lastSwingHighBar,
         lastSwingHigh,
         bar_index,
         lastSwingHigh,
         color=color.lime,
         style=line.style_dotted,
         width=2
    )

    label.new(
         bar_index,
         lastSwingHigh,
         "CHoCH",
         style=label.style_label_up,
         color=color.lime,
         textcolor=color.black,
         size=size.tiny
    )

if showStructureLines and bearishCHoCH
    line.new(
         lastSwingLowBar,
         lastSwingLow,
         bar_index,
         lastSwingLow,
         color=color.maroon,
         style=line.style_dotted,
         width=2
    )

    label.new(
         bar_index,
         lastSwingLow,
         "CHoCH",
         style=label.style_label_down,
         color=color.maroon,
         textcolor=color.white,
         size=size.tiny
    )

//====================================================
// ORDER BLOCKS
//====================================================

// Bullish OB = last bearish candle before bullish BOS/CHoCH.
if showOrderBlocks and (bullishBOS or bullishCHoCH)
    int bullishOBOffset = na

    for i = 1 to orderBlockLookback
        if close[i] < open[i]
            bullishOBOffset := i
            break

    if not na(bullishOBOffset)
        bullishOBTop =
             useOrderBlockBody
             ? open[bullishOBOffset]
             : high[bullishOBOffset]

        bullishOBBottom =
             useOrderBlockBody
             ? close[bullishOBOffset]
             : low[bullishOBOffset]

        box.new(
             left=bar_index - bullishOBOffset,
             top=bullishOBTop,
             right=bar_index + orderBlockExtension,
             bottom=bullishOBBottom,
             border_color=color.teal,
             border_width=1,
             bgcolor=bullishOBColor
        )

        label.new(
             bar_index - bullishOBOffset,
             bullishOBBottom,
             "BULL OB",
             style=label.style_label_up,
             color=color.teal,
             textcolor=color.white,
             size=size.tiny
        )

// Bearish OB = last bullish candle before bearish BOS/CHoCH.
if showOrderBlocks and (bearishBOS or bearishCHoCH)
    int bearishOBOffset = na

    for i = 1 to orderBlockLookback
        if close[i] > open[i]
            bearishOBOffset := i
            break

    if not na(bearishOBOffset)
        bearishOBTop =
             useOrderBlockBody
             ? close[bearishOBOffset]
             : high[bearishOBOffset]

        bearishOBBottom =
             useOrderBlockBody
             ? open[bearishOBOffset]
             : low[bearishOBOffset]

        box.new(
             left=bar_index - bearishOBOffset,
             top=bearishOBTop,
             right=bar_index + orderBlockExtension,
             bottom=bearishOBBottom,
             border_color=color.orange,
             border_width=1,
             bgcolor=bearishOBColor
        )

        label.new(
             bar_index - bearishOBOffset,
             bearishOBTop,
             "BEAR OB",
             style=label.style_label_down,
             color=color.orange,
             textcolor=color.white,
             size=size.tiny
        )

//====================================================
// FAIR VALUE GAPS
//====================================================

minimumFVGSize = minimumFVGSizeTicks * syminfo.mintick

bullishFVG =
     low > high[2] and
     low - high[2] >= minimumFVGSize

bearishFVG =
     high < low[2] and
     low[2] - high >= minimumFVGSize

if showFVG and bullishFVG
    box.new(
         left=bar_index - 2,
         top=low,
         right=bar_index + fvgExtensionBars,
         bottom=high[2],
         border_color=color.aqua,
         border_width=1,
         bgcolor=bullishFVGColor
    )

    label.new(
         bar_index,
         high[2],
         "BULL FVG",
         style=label.style_label_up,
         color=color.aqua,
         textcolor=color.black,
         size=size.tiny
    )

if showFVG and bearishFVG
    box.new(
         left=bar_index - 2,
         top=low[2],
         right=bar_index + fvgExtensionBars,
         bottom=high,
         border_color=color.fuchsia,
         border_width=1,
         bgcolor=bearishFVGColor
    )

    label.new(
         bar_index,
         low[2],
         "BEAR FVG",
         style=label.style_label_down,
         color=color.fuchsia,
         textcolor=color.white,
         size=size.tiny
    )

//====================================================
// PRESSURE SCORE
//====================================================

// Total = 100 points
// VWAP 15, SMA 15, Z-Score 20,
// Structure/BOS/CHoCH 20, PVSRA 15, ADX/DI 15.

buyVWAPScore = close > dailyVWAP ? 15 : 0
sellVWAPScore = close < dailyVWAP ? 15 : 0

buySMAScore = close > trendSMA50 ? 15 : 0
sellSMAScore = close < trendSMA50 ? 15 : 0

buyZScore = zBullish ? 20 : 0
sellZScore = zBearish ? 20 : 0

buyStructureScore =
     (structureTrend == 1 ? 10 : 0) +
     ((bullishCHoCH or bullishBOS) ? 10 : 0)

sellStructureScore =
     (structureTrend == -1 ? 10 : 0) +
     ((bearishCHoCH or bearishBOS) ? 10 : 0)

buyVolumeScore =
     bullishClimax ? 15 :
     bullishRisingVolume ? 12 :
     bullishCandle and volume > vectorAverageVolume ? 8 :
     0

sellVolumeScore =
     bearishClimax ? 15 :
     bearishRisingVolume ? 12 :
     bearishCandle and volume > vectorAverageVolume ? 8 :
     0

buyADXScore =
     adxStrong and bullishDI ? 15 :
     bullishDI ? 8 :
     0

sellADXScore =
     adxStrong and bearishDI ? 15 :
     bearishDI ? 8 :
     0

buyPressure =
     buyVWAPScore +
     buySMAScore +
     buyZScore +
     buyStructureScore +
     buyVolumeScore +
     buyADXScore

sellPressure =
     sellVWAPScore +
     sellSMAScore +
     sellZScore +
     sellStructureScore +
     sellVolumeScore +
     sellADXScore

//====================================================
// SIGNALS
//====================================================

rawBuySignal =
     buyPressure >= signalThreshold and
     buyPressure > sellPressure and
     zBullish

rawSellSignal =
     sellPressure >= signalThreshold and
     sellPressure > buyPressure and
     zBearish

var int lastBuySignalBar = na
var int lastSellSignalBar = na

buyCooldownOK =
     na(lastBuySignalBar) or
     bar_index - lastBuySignalBar > signalCooldownBars

sellCooldownOK =
     na(lastSellSignalBar) or
     bar_index - lastSellSignalBar > signalCooldownBars

buySignal =
     showSignals and
     rawBuySignal and
     buyCooldownOK

sellSignal =
     showSignals and
     rawSellSignal and
     sellCooldownOK

if buySignal
    lastBuySignalBar := bar_index

if sellSignal
    lastSellSignalBar := bar_index

plotshape(
     buySignal,
     title="BUY Pressure Signal",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="BUY",
     textcolor=color.white,
     size=size.small
)

plotshape(
     sellSignal,
     title="SELL Pressure Signal",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SELL",
     textcolor=color.white,
     size=size.small
)

//====================================================
// PRESSURE TABLE
//====================================================

var table pressureTable = table.new(
     position.top_right,
     2,
     12,
     border_width=1
)

if barstate.islast
    if showPressureTable
        table.cell(
             pressureTable,
             0,
             0,
             "BUY PRESSURE",
             bgcolor=color.new(color.green, 20),
             text_color=color.white
        )

        table.cell(
             pressureTable,
             1,
             0,
             str.tostring(buyPressure) + "%",
             bgcolor=buyPressure >= signalThreshold ? color.green : color.new(color.green, 75),
             text_color=color.white
        )

        table.cell(
             pressureTable,
             0,
             1,
             "SELL PRESSURE",
             bgcolor=color.new(color.red, 20),
             text_color=color.white
        )

        table.cell(
             pressureTable,
             1,
             1,
             str.tostring(sellPressure) + "%",
             bgcolor=sellPressure >= signalThreshold ? color.red : color.new(color.red, 75),
             text_color=color.white
        )

        table.cell(pressureTable, 0, 2, "VWAP")
        table.cell(
             pressureTable,
             1,
             2,
             close > dailyVWAP ? "ABOVE" :
             close < dailyVWAP ? "BELOW" :
             "AT VWAP"
        )

        table.cell(pressureTable, 0, 3, "Structure")
        table.cell(
             pressureTable,
             1,
             3,
             structureTrend == 1 ? "BULLISH" :
             structureTrend == -1 ? "BEARISH" :
             "NEUTRAL"
        )

        table.cell(pressureTable, 0, 4, "ADX")
        table.cell(
             pressureTable,
             1,
             4,
             str.tostring(adxValue, "#.##")
        )

        table.cell(pressureTable, 0, 5, "+DI / -DI")
        table.cell(
             pressureTable,
             1,
             5,
             str.tostring(plusDI, "#.##") +
             " / " +
             str.tostring(minusDI, "#.##")
        )

        table.cell(pressureTable, 0, 6, "PVSRA")
        table.cell(
             pressureTable,
             1,
             6,
             bullishClimax ? "BULL 200% / CLIMAX" :
             bearishClimax ? "BEAR 200% / CLIMAX" :
             bullishRisingVolume ? "BULL 150%" :
             bearishRisingVolume ? "BEAR 150%" :
             bullishNormalVolume ? "BULL NORMAL" :
             bearishNormalVolume ? "BEAR NORMAL" :
             "DOJI"
        )

        table.cell(pressureTable, 0, 7, "Z-Score")
        table.cell(
             pressureTable,
             1,
             7,
             showZScoreTable ? str.tostring(zScore, "#.##") : "HIDDEN"
        )

        table.cell(pressureTable, 0, 8, "Z SMA 50")
        table.cell(
             pressureTable,
             1,
             8,
             showZScoreTable ? str.tostring(zScoreSMA, "#.##") : "HIDDEN"
        )

        table.cell(pressureTable, 0, 9, "Liquidity Vol")
        table.cell(
             pressureTable,
             1,
             9,
             str.tostring(liquidityVolumeRatio, format.volume)
        )

        table.cell(pressureTable, 0, 10, "Liquidity")
        table.cell(
             pressureTable,
             1,
             10,
             bullishLiquiditySweep ? "SWING LOW BROKEN" :
             bearishLiquiditySweep ? "SWING HIGH BROKEN" :
             "ACTIVE ZONES"
        )

        table.cell(pressureTable, 0, 11, "Signal")
        table.cell(
             pressureTable,
             1,
             11,
             buyPressure >= signalThreshold and buyPressure > sellPressure and zBullish ? "BUY BIAS" :
             sellPressure >= signalThreshold and sellPressure > buyPressure and zBearish ? "SELL BIAS" :
             "WAIT"
        )
    else
        table.clear(pressureTable, 0, 0, 1, 11)

//====================================================
// ALERTS
//====================================================

alertcondition(
     buySignal,
     title="High Buy Pressure",
     message="High BUY pressure detected: VWAP + structure + PVSRA + ADX"
)

alertcondition(
     sellSignal,
     title="High Sell Pressure",
     message="High SELL pressure detected: VWAP + structure + PVSRA + ADX"
)

alertcondition(
     bullishClimax,
     title="Bullish Volume Climax",
     message="Bullish PVSRA volume climax candle detected"
)

alertcondition(
     bearishClimax,
     title="Bearish Volume Climax",
     message="Bearish PVSRA volume climax candle detected"
)

alertcondition(
     bullishLiquiditySweep,
     title="Bullish Liquidity Sweep",
     message="Liquidity swing low was crossed"
)

alertcondition(
     bearishLiquiditySweep,
     title="Bearish Liquidity Sweep",
     message="Liquidity swing high was crossed"
)

alertcondition(
     bullishFVG,
     title="Bullish FVG",
     message="Bullish Fair Value Gap detected"
)

alertcondition(
     bearishFVG,
     title="Bearish FVG",
     message="Bearish Fair Value Gap detected"
)




alertcondition(
     ta.crossover(zScore, zScoreSMA),
     title="Z-Score Bullish Cross",
     message="Z-Score crossed above its SMA 50"
)

alertcondition(
     ta.crossunder(zScore, zScoreSMA),
     title="Z-Score Bearish Cross",
     message="Z-Score crossed below its SMA 50"
)


alertcondition(
     bullishRisingVolume,
     title="Bullish 150% Vector Candle",
     message="Bullish 150% vector-volume candle detected"
)

alertcondition(
     bearishRisingVolume,
     title="Bearish 150% Vector Candle",
     message="Bearish 150% vector-volume candle detected"
)
````

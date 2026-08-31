<!-- tradingview-pine-id: PUB;22997c308d7f457b9415fdd8c24bca2a -->
<!-- tradingviewscripts-format: 1 -->
# CHoCH + BOS + Liquidity + Order Blocks + FVG + ADX + PVSRA

Source: https://www.tradingview.com/script/CbWppmll-CHoCH-BOS-Liquidity-Order-Blocks-PVSRA-BY-PROSTOX/

## Description

Buy Sell Indicator  With PVSRA With Cnadle Volume  With ADX WIith FVG

---

## Source Code

````pine
//@version=6
indicator(
     "CHoCH + BOS + Liquidity + Order Blocks + FVG + ADX + PVSRA",
     overlay = true,
     max_lines_count = 500,
     max_labels_count = 500,
     max_boxes_count = 500
)

//====================================================
// MARKET STRUCTURE INPUTS
//====================================================

pivotLeft  = input.int(3, "Pivot Left Bars", minval = 1)
pivotRight = input.int(3, "Pivot Right Bars", minval = 1)

breakByClose = input.bool(
     true,
     "Require Candle Close Beyond Structure"
)

showSwingLevels = input.bool(true, "Show Current Swing Levels")
showBOS         = input.bool(true, "Show BOS Solid Lines")
showCHoCH       = input.bool(true, "Show CHoCH Dotted Lines")
showReversal    = input.bool(true, "Show Trend Reversal Labels")

structureLineLength = input.int(
     20,
     "Structure Line Extension Bars",
     minval = 1
)

//====================================================
// ADX INPUTS
//====================================================

adxLength    = input.int(14, "ADX DI Length", minval = 1)
adxSmoothing = input.int(14, "ADX Smoothing", minval = 1)
minimumADX   = input.float(20.0, "Minimum ADX", minval = 0.0)

useADXFilter = input.bool(true, "Use ADX Strength Filter")
useDIFilter  = input.bool(true, "Use +DI / -DI Direction Filter")
showADXTable = input.bool(true, "Show ADX Table")

//====================================================
// LIQUIDITY SWEEP INPUTS
//====================================================

showLiquiditySweeps = input.bool(true, "Show Liquidity Sweep Boxes")

liquidityBoxBars = input.int(
     15,
     "Liquidity Box Extension Bars",
     minval = 1
)

bullishLiquidityColor = input.color(
     color.new(color.green, 80),
     "Bullish Liquidity Sweep Color"
)

bearishLiquidityColor = input.color(
     color.new(color.red, 80),
     "Bearish Liquidity Sweep Color"
)

//====================================================
// ORDER BLOCK INPUTS
//====================================================

showOrderBlocks = input.bool(true, "Show Order Blocks")

orderBlockLookback = input.int(
     10,
     "Order Block Search Lookback",
     minval = 1,
     maxval = 50
)

orderBlockExtension = input.int(
     50,
     "Order Block Extension Bars",
     minval = 1
)

useOrderBlockBody = input.bool(
     false,
     "Use Candle Body Only for Order Block"
)

bullishOBColor = input.color(
     color.new(color.teal, 82),
     "Bullish Order Block Color"
)

bearishOBColor = input.color(
     color.new(color.orange, 82),
     "Bearish Order Block Color"
)

//====================================================
// FAIR VALUE GAP INPUTS
//====================================================

showFVG = input.bool(true, "Show Fair Value Gaps")

fvgExtensionBars = input.int(
     40,
     "FVG Extension Bars",
     minval = 1
)

minimumFVGSizeTicks = input.int(
     1,
     "Minimum FVG Size in Ticks",
     minval = 0
)

bullishFVGColor = input.color(
     color.new(color.aqua, 84),
     "Bullish FVG Color"
)

bearishFVGColor = input.color(
     color.new(color.fuchsia, 84),
     "Bearish FVG Color"
)

//====================================================
// PVSRA INPUTS
//====================================================

showPVSRA = input.bool(true, "Enable PVSRA")
colorPVSRACandles = input.bool(true, "Color Candles with PVSRA")
showPVSRAMarkers = input.bool(true, "Show PVSRA Markers")
showPVSRALevels = input.bool(true, "Show PVSRA Climax Levels")

pvsraVolumeLength = input.int(20, "PVSRA Volume Average Length", minval = 1)
pvsraSpreadLength = input.int(20, "PVSRA Spread Average Length", minval = 1)

risingVolumeMultiplier = input.float(1.50, "Rising Volume Multiplier", minval = 1.0, step = 0.05)
climaxVolumeMultiplier = input.float(2.00, "Climax Volume Multiplier", minval = 1.0, step = 0.05)
climaxSpreadMultiplier = input.float(1.50, "Climax Spread Multiplier", minval = 1.0, step = 0.05)

pvsraLevelExtension = input.int(50, "PVSRA Level Extension Bars", minval = 1)

pvsraBullRisingColor = input.color(color.aqua, "Bullish Rising-Volume Candle")
pvsraBearRisingColor = input.color(color.orange, "Bearish Rising-Volume Candle")
pvsraBullClimaxColor = input.color(color.lime, "Bullish Climax Candle")
pvsraBearClimaxColor = input.color(color.red, "Bearish Climax Candle")


//====================================================
// ADX CALCULATION
//====================================================

[plusDI, minusDI, adxValue] = ta.dmi(adxLength, adxSmoothing)

adxStrong = adxValue >= minimumADX

bullishADX =
     (not useADXFilter or adxStrong) and
     (not useDIFilter or plusDI > minusDI)

bearishADX =
     (not useADXFilter or adxStrong) and
     (not useDIFilter or minusDI > plusDI)

//====================================================
// PVSRA CALCULATION
//====================================================

pvsraVolumeAverage = ta.sma(volume, pvsraVolumeLength)
pvsraCandleSpread = high - low
pvsraSpreadAverage = ta.sma(pvsraCandleSpread, pvsraSpreadLength)

pvsraBullishCandle = close > open
pvsraBearishCandle = close < open

pvsraClimax = not na(pvsraVolumeAverage) and not na(pvsraSpreadAverage) and volume >= pvsraVolumeAverage * climaxVolumeMultiplier and pvsraCandleSpread >= pvsraSpreadAverage * climaxSpreadMultiplier
pvsraRising = not pvsraClimax and not na(pvsraVolumeAverage) and volume >= pvsraVolumeAverage * risingVolumeMultiplier

pvsraBullishClimax = showPVSRA and pvsraClimax and pvsraBullishCandle
pvsraBearishClimax = showPVSRA and pvsraClimax and pvsraBearishCandle
pvsraBullishRising = showPVSRA and pvsraRising and pvsraBullishCandle
pvsraBearishRising = showPVSRA and pvsraRising and pvsraBearishCandle

pvsraCandleColor = pvsraBullishClimax ? pvsraBullClimaxColor : pvsraBearishClimax ? pvsraBearClimaxColor : pvsraBullishRising ? pvsraBullRisingColor : pvsraBearishRising ? pvsraBearRisingColor : na

barcolor(colorPVSRACandles ? pvsraCandleColor : na)

plotshape(showPVSRAMarkers and pvsraBullishClimax, title = "PVSRA Bullish Climax", style = shape.diamond, location = location.belowbar, color = pvsraBullClimaxColor, text = "VC", textcolor = color.black, size = size.tiny)
plotshape(showPVSRAMarkers and pvsraBearishClimax, title = "PVSRA Bearish Climax", style = shape.diamond, location = location.abovebar, color = pvsraBearClimaxColor, text = "VC", textcolor = color.white, size = size.tiny)
plotshape(showPVSRAMarkers and pvsraBullishRising, title = "PVSRA Bullish Rising Volume", style = shape.circle, location = location.belowbar, color = pvsraBullRisingColor, size = size.tiny)
plotshape(showPVSRAMarkers and pvsraBearishRising, title = "PVSRA Bearish Rising Volume", style = shape.circle, location = location.abovebar, color = pvsraBearRisingColor, size = size.tiny)

if showPVSRALevels and pvsraBullishClimax
    line.new(x1 = bar_index, y1 = low, x2 = bar_index + pvsraLevelExtension, y2 = low, xloc = xloc.bar_index, extend = extend.none, color = pvsraBullClimaxColor, style = line.style_dashed, width = 1)

if showPVSRALevels and pvsraBearishClimax
    line.new(x1 = bar_index, y1 = high, x2 = bar_index + pvsraLevelExtension, y2 = high, xloc = xloc.bar_index, extend = extend.none, color = pvsraBearClimaxColor, style = line.style_dashed, width = 1)


//====================================================
// CONFIRMED SWING POINTS
//====================================================

pivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)
pivotLow  = ta.pivotlow(low, pivotLeft, pivotRight)

var float lastSwingHigh = na
var float lastSwingLow  = na

var int lastSwingHighBar = na
var int lastSwingLowBar  = na

var bool swingHighBroken = false
var bool swingLowBroken  = false

if not na(pivotHigh)
    lastSwingHigh := pivotHigh
    lastSwingHighBar := bar_index - pivotRight
    swingHighBroken := false

if not na(pivotLow)
    lastSwingLow := pivotLow
    lastSwingLowBar := bar_index - pivotRight
    swingLowBroken := false

//====================================================
// LIQUIDITY SWEEPS
//====================================================

// Buy-side liquidity sweep:
// Candle trades above the swing high but closes back below it.

bearishLiquiditySweep =
     not na(lastSwingHigh) and
     high > lastSwingHigh and
     close < lastSwingHigh

// Sell-side liquidity sweep:
// Candle trades below the swing low but closes back above it.

bullishLiquiditySweep =
     not na(lastSwingLow) and
     low < lastSwingLow and
     close > lastSwingLow

if showLiquiditySweeps and bearishLiquiditySweep
    float sweepBottom = math.max(open, close)

    box.new(
         left = bar_index,
         top = high,
         right = bar_index + liquidityBoxBars,
         bottom = sweepBottom,
         border_color = color.red,
         border_width = 1,
         bgcolor = bearishLiquidityColor
    )

    label.new(
         x = bar_index,
         y = high,
         text = "BUY-SIDE\nSWEEP",
         style = label.style_label_down,
         color = color.red,
         textcolor = color.white,
         size = size.tiny
    )

if showLiquiditySweeps and bullishLiquiditySweep
    float sweepTop = math.min(open, close)

    box.new(
         left = bar_index,
         top = sweepTop,
         right = bar_index + liquidityBoxBars,
         bottom = low,
         border_color = color.green,
         border_width = 1,
         bgcolor = bullishLiquidityColor
    )

    label.new(
         x = bar_index,
         y = low,
         text = "SELL-SIDE\nSWEEP",
         style = label.style_label_up,
         color = color.green,
         textcolor = color.white,
         size = size.tiny
    )

//====================================================
// STRUCTURE BREAK CONDITIONS
//====================================================

bullishBreak =
     not na(lastSwingHigh) and
     not swingHighBroken and
     (
          breakByClose
          ? close > lastSwingHigh
          : high > lastSwingHigh
     )

bearishBreak =
     not na(lastSwingLow) and
     not swingLowBroken and
     (
          breakByClose
          ? close < lastSwingLow
          : low < lastSwingLow
     )

//====================================================
// STRUCTURE DIRECTION
//====================================================

//  1 = bullish structure
// -1 = bearish structure
//  0 = undefined

var int structureTrend = 0

bool bullishBOS   = false
bool bearishBOS   = false
bool bullishCHoCH = false
bool bearishCHoCH = false

if bullishBreak
    swingHighBroken := true

    if structureTrend == -1
        bullishCHoCH := true
    else
        bullishBOS := true

    structureTrend := 1

if bearishBreak
    swingLowBroken := true

    if structureTrend == 1
        bearishCHoCH := true
    else
        bearishBOS := true

    structureTrend := -1

//====================================================
// ADX-CONFIRMED STRUCTURE SIGNALS
//====================================================

confirmedBullishBOS =
     bullishBOS and bullishADX

confirmedBearishBOS =
     bearishBOS and bearishADX

confirmedBullishCHoCH =
     bullishCHoCH and bullishADX

confirmedBearishCHoCH =
     bearishCHoCH and bearishADX

bullishReversal = confirmedBullishCHoCH
bearishReversal = confirmedBearishCHoCH

//====================================================
// BOS SOLID LINES
//====================================================

if showBOS and confirmedBullishBOS
    line.new(
         x1 = lastSwingHighBar,
         y1 = lastSwingHigh,
         x2 = bar_index + structureLineLength,
         y2 = lastSwingHigh,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = color.green,
         style = line.style_solid,
         width = 2
    )

    label.new(
         x = bar_index,
         y = lastSwingHigh,
         text = "BOS",
         style = label.style_label_up,
         color = color.green,
         textcolor = color.white,
         size = size.small
    )

if showBOS and confirmedBearishBOS
    line.new(
         x1 = lastSwingLowBar,
         y1 = lastSwingLow,
         x2 = bar_index + structureLineLength,
         y2 = lastSwingLow,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = color.red,
         style = line.style_solid,
         width = 2
    )

    label.new(
         x = bar_index,
         y = lastSwingLow,
         text = "BOS",
         style = label.style_label_down,
         color = color.red,
         textcolor = color.white,
         size = size.small
    )

//====================================================
// CHOCH DOTTED LINES
//====================================================

if showCHoCH and confirmedBullishCHoCH
    line.new(
         x1 = lastSwingHighBar,
         y1 = lastSwingHigh,
         x2 = bar_index + structureLineLength,
         y2 = lastSwingHigh,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = color.lime,
         style = line.style_dotted,
         width = 2
    )

    label.new(
         x = bar_index,
         y = lastSwingHigh,
         text = "CHoCH",
         style = label.style_label_up,
         color = color.lime,
         textcolor = color.black,
         size = size.small
    )

if showCHoCH and confirmedBearishCHoCH
    line.new(
         x1 = lastSwingLowBar,
         y1 = lastSwingLow,
         x2 = bar_index + structureLineLength,
         y2 = lastSwingLow,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = color.maroon,
         style = line.style_dotted,
         width = 2
    )

    label.new(
         x = bar_index,
         y = lastSwingLow,
         text = "CHoCH",
         style = label.style_label_down,
         color = color.maroon,
         textcolor = color.white,
         size = size.small
    )

//====================================================
// TREND REVERSAL LABELS
//====================================================

plotshape(
     showReversal and bullishReversal,
     title = "Bullish Trend Reversal",
     style = shape.triangleup,
     location = location.belowbar,
     color = color.aqua,
     text = "REV",
     textcolor = color.black,
     size = size.small
)

plotshape(
     showReversal and bearishReversal,
     title = "Bearish Trend Reversal",
     style = shape.triangledown,
     location = location.abovebar,
     color = color.orange,
     text = "REV",
     textcolor = color.black,
     size = size.small
)

//====================================================
// ORDER BLOCKS
//====================================================

// Bullish order block:
// Last bearish candle before a bullish BOS or CHoCH.

if showOrderBlocks and (confirmedBullishBOS or confirmedBullishCHoCH)
    int bullishOBOffset = na

    for i = 1 to orderBlockLookback
        if close[i] < open[i]
            bullishOBOffset := i
            break

    if not na(bullishOBOffset)
        float bullishOBTop =
             useOrderBlockBody
             ? open[bullishOBOffset]
             : high[bullishOBOffset]

        float bullishOBBottom =
             useOrderBlockBody
             ? close[bullishOBOffset]
             : low[bullishOBOffset]

        box.new(
             left = bar_index - bullishOBOffset,
             top = bullishOBTop,
             right = bar_index + orderBlockExtension,
             bottom = bullishOBBottom,
             xloc = xloc.bar_index,
             border_color = color.teal,
             border_width = 1,
             bgcolor = bullishOBColor
        )

        label.new(
             x = bar_index - bullishOBOffset,
             y = bullishOBBottom,
             text = "BULL OB",
             style = label.style_label_up,
             color = color.teal,
             textcolor = color.white,
             size = size.tiny
        )

// Bearish order block:
// Last bullish candle before a bearish BOS or CHoCH.

if showOrderBlocks and (confirmedBearishBOS or confirmedBearishCHoCH)
    int bearishOBOffset = na

    for i = 1 to orderBlockLookback
        if close[i] > open[i]
            bearishOBOffset := i
            break

    if not na(bearishOBOffset)
        float bearishOBTop =
             useOrderBlockBody
             ? close[bearishOBOffset]
             : high[bearishOBOffset]

        float bearishOBBottom =
             useOrderBlockBody
             ? open[bearishOBOffset]
             : low[bearishOBOffset]

        box.new(
             left = bar_index - bearishOBOffset,
             top = bearishOBTop,
             right = bar_index + orderBlockExtension,
             bottom = bearishOBBottom,
             xloc = xloc.bar_index,
             border_color = color.orange,
             border_width = 1,
             bgcolor = bearishOBColor
        )

        label.new(
             x = bar_index - bearishOBOffset,
             y = bearishOBTop,
             text = "BEAR OB",
             style = label.style_label_down,
             color = color.orange,
             textcolor = color.white,
             size = size.tiny
        )

//====================================================
// FAIR VALUE GAPS
//====================================================

minimumFVGSize = minimumFVGSizeTicks * syminfo.mintick

// Bullish FVG:
// Current candle low is above the high from two candles ago.

bullishFVG =
     low > high[2] and
     low - high[2] >= minimumFVGSize

// Bearish FVG:
// Current candle high is below the low from two candles ago.

bearishFVG =
     high < low[2] and
     low[2] - high >= minimumFVGSize

if showFVG and bullishFVG
    box.new(
         left = bar_index - 2,
         top = low,
         right = bar_index + fvgExtensionBars,
         bottom = high[2],
         xloc = xloc.bar_index,
         border_color = color.aqua,
         border_width = 1,
         bgcolor = bullishFVGColor
    )

    label.new(
         x = bar_index,
         y = high[2],
         text = "BULL FVG",
         style = label.style_label_up,
         color = color.aqua,
         textcolor = color.black,
         size = size.tiny
    )

if showFVG and bearishFVG
    box.new(
         left = bar_index - 2,
         top = low[2],
         right = bar_index + fvgExtensionBars,
         bottom = high,
         xloc = xloc.bar_index,
         border_color = color.fuchsia,
         border_width = 1,
         bgcolor = bearishFVGColor
    )

    label.new(
         x = bar_index,
         y = low[2],
         text = "BEAR FVG",
         style = label.style_label_down,
         color = color.fuchsia,
         textcolor = color.white,
         size = size.tiny
    )

//====================================================
// CURRENT SWING LEVELS
//====================================================

plot(
     showSwingLevels ? lastSwingHigh : na,
     title = "Current Swing High",
     color = color.new(color.red, 60),
     linewidth = 1,
     style = plot.style_linebr
)

plot(
     showSwingLevels ? lastSwingLow : na,
     title = "Current Swing Low",
     color = color.new(color.green, 60),
     linewidth = 1,
     style = plot.style_linebr
)

//====================================================
// ADX INFORMATION TABLE
//====================================================

var table adxTable = table.new(
     position.top_right,
     2,
     5,
     border_width = 1
)

if barstate.islast
    if showADXTable
        table.cell(
             adxTable,
             0,
             0,
             "Structure",
             text_color = color.white,
             bgcolor = color.black
        )

        table.cell(
             adxTable,
             1,
             0,
             structureTrend == 1
             ? "BULLISH"
             : structureTrend == -1
             ? "BEARISH"
             : "NEUTRAL",
             text_color = color.white,
             bgcolor =
                  structureTrend == 1
                  ? color.green
                  : structureTrend == -1
                  ? color.red
                  : color.gray
        )

        table.cell(adxTable, 0, 1, "ADX")
        table.cell(
             adxTable,
             1,
             1,
             str.tostring(adxValue, "#.##")
        )

        table.cell(adxTable, 0, 2, "+DI")
        table.cell(
             adxTable,
             1,
             2,
             str.tostring(plusDI, "#.##"),
             text_color = color.green
        )

        table.cell(adxTable, 0, 3, "-DI")
        table.cell(
             adxTable,
             1,
             3,
             str.tostring(minusDI, "#.##"),
             text_color = color.red
        )

        table.cell(adxTable, 0, 4, "Strength")
        table.cell(
             adxTable,
             1,
             4,
             adxStrong ? "STRONG" : "WEAK",
             text_color = color.white,
             bgcolor = adxStrong ? color.green : color.gray
        )
    else
        table.clear(adxTable, 0, 0, 1, 4)

//====================================================
// ALERTS
//====================================================

alertcondition(
     confirmedBullishBOS,
     title = "Bullish BOS",
     message = "Bullish Break of Structure with ADX confirmation"
)

alertcondition(
     confirmedBearishBOS,
     title = "Bearish BOS",
     message = "Bearish Break of Structure with ADX confirmation"
)

alertcondition(
     confirmedBullishCHoCH,
     title = "Bullish CHoCH",
     message = "Bullish Change of Character with ADX confirmation"
)

alertcondition(
     confirmedBearishCHoCH,
     title = "Bearish CHoCH",
     message = "Bearish Change of Character with ADX confirmation"
)

alertcondition(
     bullishLiquiditySweep,
     title = "Bullish Liquidity Sweep",
     message = "Sell-side liquidity sweep detected"
)

alertcondition(
     bearishLiquiditySweep,
     title = "Bearish Liquidity Sweep",
     message = "Buy-side liquidity sweep detected"
)

alertcondition(
     bullishFVG,
     title = "Bullish FVG",
     message = "Bullish Fair Value Gap detected"
)

alertcondition(
     bearishFVG,
     title = "Bearish FVG",
     message = "Bearish Fair Value Gap detected"
)

alertcondition(pvsraBullishClimax, title = "PVSRA Bullish Climax", message = "Bullish PVSRA climax-volume candle detected")
alertcondition(pvsraBearishClimax, title = "PVSRA Bearish Climax", message = "Bearish PVSRA climax-volume candle detected")
alertcondition(pvsraBullishRising, title = "PVSRA Bullish Rising Volume", message = "Bullish PVSRA rising-volume candle detected")
alertcondition(pvsraBearishRising, title = "PVSRA Bearish Rising Volume", message = "Bearish PVSRA rising-volume candle detected")
````

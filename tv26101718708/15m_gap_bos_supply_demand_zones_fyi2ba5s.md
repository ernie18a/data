# 15M Gap + BOS Supply & Demand Zones

- url: https://www.tradingview.com/script/fYi2ba5s-15M-Gap-BOS-Supply-Demand-Zones/
- type: indicator
- pine_id: PUB;78264cb7792e437a8b1c4108b9ba3c89
- version: 1.0

## Description

This indicator is designed to identify potential supply and demand zones based on a 15-minute gap and break of structure strategy.

For bullish setups, the indicator looks for a 15-minute bullish gap followed by a bullish break of structure. It then finds and boxes the most recent bearish candle before the bullish move, marking it as a green demand zone.

For bearish setups, the indicator looks for a 15-minute bearish gap followed by a bearish break of structure. It then finds and boxes the most recent bullish candle before the bearish move, marking it as a red supply zone.

The zones extend to the right to help identify possible future reaction areas where price may return, reject, or continue from.

## Source Code

````pine
//@version=6
indicator("15M Gap + BOS Supply & Demand Zones", overlay=true, max_boxes_count=500)

// ─────────────────────────────
// Inputs
// ─────────────────────────────
showDemand = input.bool(true, "Show Demand Zones")
showSupply = input.bool(true, "Show Supply Zones")

requireBOS = input.bool(true, "Require Break of Structure?")
swingLength = input.int(3, "BOS Swing Length", minval=1)

oppositeCandleLookback = input.int(10, "How Far Back To Find Opposite Candle", minval=1, maxval=50)

useFullWick = input.bool(true, "Box Full Candle Wick?")
extendZones = input.bool(true, "Extend Boxes Right?")

demandColor = input.color(color.new(color.green, 82), "Demand Zone Color")
supplyColor = input.color(color.new(color.red, 82), "Supply Zone Color")

deleteWhenTouched = input.bool(false, "Delete Zone When Price Returns?")
maxZones = input.int(50, "Max Zones To Keep", minval=1, maxval=500)

// ─────────────────────────────
// 15-Minute Warning
// ─────────────────────────────
is15Min = timeframe.isminutes and timeframe.multiplier == 15

if barstate.islast and not is15Min
    label.new(
         bar_index,
         high,
         "This strategy is built for the 15-minute chart.",
         style=label.style_label_down,
         textcolor=color.white,
         color=color.new(color.orange, 0)
     )

// ─────────────────────────────
// Gap Detection
// Bull gap: current low gaps above previous high
// Bear gap: current high gaps below previous low
// ─────────────────────────────
bullGap = low > high[1]
bearGap = high < low[1]

// ─────────────────────────────
// Break of Structure Logic
// Uses confirmed swing highs/lows
// ─────────────────────────────
pivotHigh = ta.pivothigh(high, swingLength, swingLength)
pivotLow = ta.pivotlow(low, swingLength, swingLength)

var float lastSwingHigh = na
var float lastSwingLow = na

if not na(pivotHigh)
    lastSwingHigh := pivotHigh

if not na(pivotLow)
    lastSwingLow := pivotLow

bullBOS = not na(lastSwingHigh) and close > lastSwingHigh
bearBOS = not na(lastSwingLow) and close < lastSwingLow

validBullSetup = bullGap and (not requireBOS or bullBOS)
validBearSetup = bearGap and (not requireBOS or bearBOS)

// ─────────────────────────────
// Find Previous Opposite Candle
// Bullish setup needs previous bearish candle.
// Bearish setup needs previous bullish candle.
// ─────────────────────────────
findPreviousBearishCandle() =>
    int foundOffset = na

    for i = 1 to oppositeCandleLookback
        if close[i] < open[i] and na(foundOffset)
            foundOffset := i

    foundOffset

findPreviousBullishCandle() =>
    int foundOffset = na

    for i = 1 to oppositeCandleLookback
        if close[i] > open[i] and na(foundOffset)
            foundOffset := i

    foundOffset

// ─────────────────────────────
// Box Storage
// ─────────────────────────────
var box[] demandBoxes = array.new_box()
var box[] supplyBoxes = array.new_box()

// ─────────────────────────────
// Create Demand Zone
// Bull gap + bullish BOS.
// Box the previous bearish candle.
// ─────────────────────────────
if barstate.isconfirmed and validBullSetup and showDemand
    bearishOffset = findPreviousBearishCandle()

    if not na(bearishOffset)
        zoneTop = useFullWick ? high[bearishOffset] : math.max(open[bearishOffset], close[bearishOffset])
        zoneBottom = useFullWick ? low[bearishOffset] : math.min(open[bearishOffset], close[bearishOffset])

        demandBox = box.new(
             left=bar_index - bearishOffset,
             top=zoneTop,
             right=bar_index,
             bottom=zoneBottom,
             bgcolor=demandColor,
             border_color=color.new(color.green, 30),
             extend=extendZones ? extend.right : extend.none
         )

        array.push(demandBoxes, demandBox)

        if array.size(demandBoxes) > maxZones
            oldBox = array.shift(demandBoxes)
            box.delete(oldBox)

// ─────────────────────────────
// Create Supply Zone
// Bear gap + bearish BOS.
// Box the previous bullish candle.
// ─────────────────────────────
if barstate.isconfirmed and validBearSetup and showSupply
    bullishOffset = findPreviousBullishCandle()

    if not na(bullishOffset)
        zoneTop = useFullWick ? high[bullishOffset] : math.max(open[bullishOffset], close[bullishOffset])
        zoneBottom = useFullWick ? low[bullishOffset] : math.min(open[bullishOffset], close[bullishOffset])

        supplyBox = box.new(
             left=bar_index - bullishOffset,
             top=zoneTop,
             right=bar_index,
             bottom=zoneBottom,
             bgcolor=supplyColor,
             border_color=color.new(color.red, 30),
             extend=extendZones ? extend.right : extend.none
         )

        array.push(supplyBoxes, supplyBox)

        if array.size(supplyBoxes) > maxZones
            oldBox = array.shift(supplyBoxes)
            box.delete(oldBox)

// ─────────────────────────────
// Optional: Delete Zones When Price Returns
// ─────────────────────────────
if deleteWhenTouched
    if array.size(demandBoxes) > 0
        for i = array.size(demandBoxes) - 1 to 0
            b = array.get(demandBoxes, i)
            top = box.get_top(b)
            bottom = box.get_bottom(b)

            demandTouched = low <= top and high >= bottom

            if demandTouched
                box.delete(b)
                array.remove(demandBoxes, i)

    if array.size(supplyBoxes) > 0
        for i = array.size(supplyBoxes) - 1 to 0
            b = array.get(supplyBoxes, i)
            top = box.get_top(b)
            bottom = box.get_bottom(b)

            supplyTouched = high >= bottom and low <= top

            if supplyTouched
                box.delete(b)
                array.remove(supplyBoxes, i)

// ─────────────────────────────
// Visual BOS Markers
// ─────────────────────────────
plotshape(validBullSetup, title="Bull Gap + BOS", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.tiny)
plotshape(validBearSetup, title="Bear Gap + BOS", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny)
````

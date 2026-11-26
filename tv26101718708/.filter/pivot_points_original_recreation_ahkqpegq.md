# Pivot Points Original Recreation

- url: https://www.tradingview.com/script/aHKQpegq/
- type: indicator
- pine_id: PUB;1756c2278ebc47ffb735825a4699ad2e
- version: 1.0

## Description

Pivot Points Original Recreation is a technical analysis indicator designed to identify potential pivot highs and pivot lows directly on the price chart.

The indicator highlights important swing points where price may have formed a temporary top or bottom. These pivot levels can help traders analyze market structure, trend direction, support and resistance zones, and possible reversal or continuation areas.

Main features:
- Detects pivot highs and pivot lows
- Displays clear PH and PL labels on the chart
- Helps identify swing structure and key turning points
- Useful for support and resistance analysis
- Can assist with trend continuation and reversal setups
- Works across forex, gold, indices, crypto, stocks, and other liquid markets

This indicator is intended for technical analysis and educational purposes only. It does not provide guaranteed buy or sell signals and should not be used as a standalone trading system. Traders should combine it with proper risk management, market structure analysis, and their own trading strategy.

## Source Code

````pine
//@version=6
indicator("Pivot Points Original Recreation", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// -----------------------------------------------------------------------------
// Original recreation based on the visible screenshot concept.
// This is NOT the protected TradingView source code.
// It detects confirmed pivot highs/lows and draws red/green reversal zones.
// -----------------------------------------------------------------------------

// === Inputs ===
leftBars        = input.int(5, "Pivot left bars", minval = 1, maxval = 50)
rightBars       = input.int(5, "Pivot right bars", minval = 1, maxval = 50)
maxZones        = input.int(80, "Maximum zones to keep", minval = 10, maxval = 250)

useAtrZone      = input.bool(true, "Use ATR for zone height")
atrLen          = input.int(14, "ATR length", minval = 1)
atrMult         = input.float(0.35, "ATR zone multiplier", minval = 0.01, step = 0.01)
minCandleAtr    = input.float(0.00, "Minimum pivot candle range in ATR", minval = 0.00, step = 0.05)

extendZones     = input.bool(false, "Extend zones to the right")
boxWidthBars    = input.int(3, "Box width when not extended", minval = 1, maxval = 25)
keepBrokenZones = input.bool(true, "Keep broken zones faded")
showMidline     = input.bool(false, "Show zone midline")
showLabels      = input.bool(true, "Show pivot labels")
showArrows      = input.bool(true, "Show pivot arrows")
highlightBars   = input.bool(true, "Color confirmed pivot candles")

useRsiFilter    = input.bool(false, "Use RSI extreme filter")
rsiLen          = input.int(14, "RSI length", minval = 1)
rsiOverbought   = input.float(65.0, "RSI overbought for pivot highs", minval = 50.0, maxval = 100.0)
rsiOversold     = input.float(35.0, "RSI oversold for pivot lows", minval = 0.0, maxval = 50.0)

useVolFilter    = input.bool(false, "Use volume filter")
volLen          = input.int(20, "Volume average length", minval = 1)
volMult         = input.float(1.10, "Volume multiplier", minval = 0.10, step = 0.05)

useTrendFilter  = input.bool(false, "Use EMA trend filter")
emaLen          = input.int(200, "EMA length", minval = 1)

supplyColor     = input.color(color.rgb(242, 74, 92), "Supply pivot color")
demandColor     = input.color(color.rgb(0, 188, 150), "Demand pivot color")
neutralColor    = input.color(color.gray, "Broken zone color")
zoneOpacity     = input.int(82, "Zone opacity", minval = 0, maxval = 100)

// === Calculations ===
atrValue = ta.atr(atrLen)
rsiValue = ta.rsi(close, rsiLen)
emaValue = ta.ema(close, emaLen)
volAvg   = ta.sma(volume, volLen)

pivotHigh = ta.pivothigh(high, leftBars, rightBars)
pivotLow  = ta.pivotlow(low, leftBars, rightBars)

pivotIndex = bar_index - rightBars
zoneExtend = extendZones ? extend.right : extend.none

// Pivot filters are checked on the real pivot candle, which is rightBars bars back.
pivotCandleRange = high[rightBars] - low[rightBars]
rangeOK          = minCandleAtr <= 0 or pivotCandleRange >= atrValue[rightBars] * minCandleAtr

rsiHighOK = not useRsiFilter or rsiValue[rightBars] >= rsiOverbought
rsiLowOK  = not useRsiFilter or rsiValue[rightBars] <= rsiOversold

volOK = not useVolFilter or volume[rightBars] >= volAvg[rightBars] * volMult

trendHighOK = not useTrendFilter or close[rightBars] <= emaValue[rightBars]
trendLowOK  = not useTrendFilter or close[rightBars] >= emaValue[rightBars]

newSupplyPivot = not na(pivotHigh) and rangeOK and rsiHighOK and volOK and trendHighOK
newDemandPivot = not na(pivotLow) and rangeOK and rsiLowOK and volOK and trendLowOK

// === Storage ===
var box[]   supplyBoxes = array.new_box()
var line[]  supplyLines = array.new_line()
var box[]   demandBoxes = array.new_box()
var line[]  demandLines = array.new_line()
var label[] pivotLabels = array.new_label()

// === Create new supply zone ===
if newSupplyPivot
    pivotHighPrice = high[rightBars]
    bodyTop        = math.max(open[rightBars], close[rightBars])
    rawHeight      = math.max(pivotHighPrice - bodyTop, syminfo.mintick * 5)
    zoneHeight     = useAtrZone ? math.max(rawHeight, atrValue[rightBars] * atrMult) : rawHeight
    zoneTop        = pivotHighPrice
    zoneBottom     = pivotHighPrice - zoneHeight
    zoneRight      = extendZones ? bar_index : pivotIndex + boxWidthBars

    b = box.new(
         left = pivotIndex,
         top = zoneTop,
         right = zoneRight,
         bottom = zoneBottom,
         xloc = xloc.bar_index,
         extend = zoneExtend,
         bgcolor = color.new(supplyColor, zoneOpacity),
         border_color = color.new(supplyColor, 0),
         border_width = 1
     )
    array.push(supplyBoxes, b)

    if showMidline
        mid = (zoneTop + zoneBottom) / 2.0
        ln = line.new(
             x1 = pivotIndex,
             y1 = mid,
             x2 = zoneRight,
             y2 = mid,
             xloc = xloc.bar_index,
             extend = zoneExtend,
             color = color.new(supplyColor, 35),
             style = line.style_dotted,
             width = 1
         )
        array.push(supplyLines, ln)

    if showLabels
        lb = label.new(
             x = pivotIndex,
             y = zoneTop,
             text = "Pivot High",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_down,
             color = color.new(supplyColor, 0),
             textcolor = color.white,
             size = size.tiny
         )
        array.push(pivotLabels, lb)

// === Create new demand zone ===
if newDemandPivot
    pivotLowPrice = low[rightBars]
    bodyBottom    = math.min(open[rightBars], close[rightBars])
    rawHeight     = math.max(bodyBottom - pivotLowPrice, syminfo.mintick * 5)
    zoneHeight    = useAtrZone ? math.max(rawHeight, atrValue[rightBars] * atrMult) : rawHeight
    zoneBottom    = pivotLowPrice
    zoneTop       = pivotLowPrice + zoneHeight
    zoneRight     = extendZones ? bar_index : pivotIndex + boxWidthBars

    b = box.new(
         left = pivotIndex,
         top = zoneTop,
         right = zoneRight,
         bottom = zoneBottom,
         xloc = xloc.bar_index,
         extend = zoneExtend,
         bgcolor = color.new(demandColor, zoneOpacity),
         border_color = color.new(demandColor, 0),
         border_width = 1
     )
    array.push(demandBoxes, b)

    if showMidline
        mid = (zoneTop + zoneBottom) / 2.0
        ln = line.new(
             x1 = pivotIndex,
             y1 = mid,
             x2 = zoneRight,
             y2 = mid,
             xloc = xloc.bar_index,
             extend = zoneExtend,
             color = color.new(demandColor, 35),
             style = line.style_dotted,
             width = 1
         )
        array.push(demandLines, ln)

    if showLabels
        lb = label.new(
             x = pivotIndex,
             y = zoneBottom,
             text = "Pivot Low",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_up,
             color = color.new(demandColor, 0),
             textcolor = color.white,
             size = size.tiny
         )
        array.push(pivotLabels, lb)

// === Keep object count under control ===
while array.size(supplyBoxes) > maxZones
    oldBox = array.shift(supplyBoxes)
    box.delete(oldBox)
    if array.size(supplyLines) > 0
        oldLine = array.shift(supplyLines)
        line.delete(oldLine)

while array.size(demandBoxes) > maxZones
    oldBox = array.shift(demandBoxes)
    box.delete(oldBox)
    if array.size(demandLines) > 0
        oldLine = array.shift(demandLines)
        line.delete(oldLine)

while array.size(pivotLabels) > maxZones
    oldLabel = array.shift(pivotLabels)
    label.delete(oldLabel)

// === Manage extended zones ===
bool supplyTouched = false
bool demandTouched = false
bool supplyBroken  = false
bool demandBroken  = false

if extendZones
    if array.size(supplyBoxes) > 0
        for i = array.size(supplyBoxes) - 1 to 0 by -1
            b = array.get(supplyBoxes, i)
            top = box.get_top(b)
            bot = box.get_bottom(b)
            touched = high >= bot and low <= top
            broken = close > top

            supplyTouched := supplyTouched or (touched and not broken)

            if broken
                supplyBroken := true
                if keepBrokenZones
                    box.set_extend(b, extend.none)
                    box.set_right(b, bar_index)
                    box.set_bgcolor(b, color.new(neutralColor, 92))
                    box.set_border_color(b, color.new(neutralColor, 70))
                    if array.size(supplyLines) > i
                        ln = array.get(supplyLines, i)
                        line.set_extend(ln, extend.none)
                        line.set_x2(ln, bar_index)
                        line.set_color(ln, color.new(neutralColor, 70))
                else
                    box.delete(b)
                    if array.size(supplyLines) > i
                        line.delete(array.get(supplyLines, i))
                array.remove(supplyBoxes, i)
                if array.size(supplyLines) > i
                    array.remove(supplyLines, i)

    if array.size(demandBoxes) > 0
        for i = array.size(demandBoxes) - 1 to 0 by -1
            b = array.get(demandBoxes, i)
            top = box.get_top(b)
            bot = box.get_bottom(b)
            touched = high >= bot and low <= top
            broken = close < bot

            demandTouched := demandTouched or (touched and not broken)

            if broken
                demandBroken := true
                if keepBrokenZones
                    box.set_extend(b, extend.none)
                    box.set_right(b, bar_index)
                    box.set_bgcolor(b, color.new(neutralColor, 92))
                    box.set_border_color(b, color.new(neutralColor, 70))
                    if array.size(demandLines) > i
                        ln = array.get(demandLines, i)
                        line.set_extend(ln, extend.none)
                        line.set_x2(ln, bar_index)
                        line.set_color(ln, color.new(neutralColor, 70))
                else
                    box.delete(b)
                    if array.size(demandLines) > i
                        line.delete(array.get(demandLines, i))
                array.remove(demandBoxes, i)
                if array.size(demandLines) > i
                    array.remove(demandLines, i)

// === Visual signals ===
plotshape(
     showArrows and newSupplyPivot,
     title = "Confirmed Pivot High",
     style = shape.triangledown,
     location = location.abovebar,
     offset = -rightBars,
     color = supplyColor,
     size = size.tiny,
     text = "PH"
)

plotshape(
     showArrows and newDemandPivot,
     title = "Confirmed Pivot Low",
     style = shape.triangleup,
     location = location.belowbar,
     offset = -rightBars,
     color = demandColor,
     size = size.tiny,
     text = "PL"
)

barcolor(highlightBars and newSupplyPivot ? color.new(supplyColor, 0) : na, offset = -rightBars)
barcolor(highlightBars and newDemandPivot ? color.new(demandColor, 0) : na, offset = -rightBars)

plot(useTrendFilter ? emaValue : na, title = "EMA Trend Filter", color = color.new(color.gray, 0), linewidth = 1)

// === Alerts ===
alertcondition(newSupplyPivot, title = "New confirmed pivot high", message = "New confirmed pivot high on {{ticker}} {{interval}}")
alertcondition(newDemandPivot, title = "New confirmed pivot low", message = "New confirmed pivot low on {{ticker}} {{interval}}")
alertcondition(supplyTouched, title = "Supply zone retest", message = "{{ticker}} {{interval}} is retesting an active supply zone")
alertcondition(demandTouched, title = "Demand zone retest", message = "{{ticker}} {{interval}} is retesting an active demand zone")
alertcondition(supplyBroken, title = "Supply zone broken", message = "{{ticker}} {{interval}} closed above an active supply zone")
alertcondition(demandBroken, title = "Demand zone broken", message = "{{ticker}} {{interval}} closed below an active demand zone")
````

# Infinity Capital 4H

- url: https://www.tradingview.com/script/BIFPo4Mp-Infinity-Capital-4H/
- type: indicator
- pine_id: PUB;4954dd64aa7141fe8df307da80dc1572
- version: 1.0

## Description

TEST !!

Infinity Capital 4H indicator

Features:
- Market structure (Highs & Lows)
- Break of Structure (BOS)
- Change of Character (CHoCH)
- Fair Value Gaps (FVG)
- Liquidity Sweeps (wick-based)
- Supply & Demand zones (customizable)

Fully customizable settings for clean price action analysis.

## Source Code

````pine
//@version=6
indicator("Infinity Capital 4H", overlay=true, max_boxes_count=200, max_labels_count=200, max_lines_count=200)

// WATERMERK
showWatermark     = input.bool(true, "Toon Watermerk", group="Watermerk")
wmTitle           = input.string("Infinity Capital", "Titel", group="Watermerk")
wmSubtitle        = input.string("", "Subtitel", group="Watermerk")
wmVertPos         = input.string("top", "Verticale positie", options=["top", "middle", "bottom"], group="Watermerk")
wmHorzPos         = input.string("center", "Horizontale positie", options=["left", "center", "right"], group="Watermerk")
wmTitleColor      = input.color(#000000, "Titel kleur", group="Watermerk")
wmSubtitleColor   = input.color(#000000, "Subtitel kleur", group="Watermerk")
wmTitleSizeIn     = input.string("large", "Titel grootte", options=["tiny", "small", "normal", "large", "huge"], group="Watermerk")
wmSubtitleSizeIn  = input.string("normal", "Subtitel grootte", options=["tiny", "small", "normal", "large"], group="Watermerk")

wmTitleSize = wmTitleSizeIn == "tiny" ? size.tiny : wmTitleSizeIn == "small" ? size.small : wmTitleSizeIn == "large" ? size.large : wmTitleSizeIn == "huge" ? size.huge : size.normal
wmSubSize   = wmSubtitleSizeIn == "tiny" ? size.tiny : wmSubtitleSizeIn == "small" ? size.small : wmSubtitleSizeIn == "large" ? size.large : size.normal

wmPosition = wmVertPos == "top" and wmHorzPos == "left" ? position.top_left :
     wmVertPos == "top" and wmHorzPos == "center" ? position.top_center :
     wmVertPos == "top" and wmHorzPos == "right" ? position.top_right :
     wmVertPos == "middle" and wmHorzPos == "left" ? position.middle_left :
     wmVertPos == "middle" and wmHorzPos == "center" ? position.middle_center :
     wmVertPos == "middle" and wmHorzPos == "right" ? position.middle_right :
     wmVertPos == "bottom" and wmHorzPos == "left" ? position.bottom_left :
     wmVertPos == "bottom" and wmHorzPos == "center" ? position.bottom_center :
     position.bottom_right

var table wmTable = na

if barstate.islast
    table.delete(wmTable)

    if showWatermark
        wmTable := table.new(wmPosition, 1, 2)
        table.cell(wmTable, 0, 0, wmTitle, text_color=wmTitleColor, text_size=wmTitleSize, bgcolor=color.new(#FFFFFF, 100))
        table.cell(wmTable, 0, 1, wmSubtitle, text_color=wmSubtitleColor, text_size=wmSubSize, bgcolor=color.new(#FFFFFF, 100))

// MARKET STRUCTUUR
showSwings    = input.bool(true, "Toon Highs & Lows", group="Market Structuur")
swingLength   = input.int(7, "Swing gevoeligheid", minval=2, maxval=20, group="Market Structuur")
swingHighCol  = input.color(#000000, "High kleur", group="Market Structuur")
swingLowCol   = input.color(#000000, "Low kleur", group="Market Structuur")

swingHigh = ta.pivothigh(high, swingLength, swingLength)
swingLow  = ta.pivotlow(low, swingLength, swingLength)

plotshape(showSwings and not na(swingHigh), style=shape.triangledown, location=location.abovebar, offset=-swingLength, color=swingHighCol, size=size.tiny)
plotshape(showSwings and not na(swingLow), style=shape.triangleup, location=location.belowbar, offset=-swingLength, color=swingLowCol, size=size.tiny)

// SUPPLY & DEMAND
showSD             = input.bool(false, "Toon Supply & Demand", group="Supply & Demand")
sdLength           = input.int(6, "Zone gevoeligheid", minval=2, maxval=30, group="Supply & Demand")
sdExtend           = input.int(40, "Zone verlenging in candles", minval=1, maxval=300, group="Supply & Demand")
sdMaxZones         = input.int(2, "Max aantal zones", minval=1, maxval=50, group="Supply & Demand")
deleteMitigatedSD  = input.bool(true, "Verwijder aangeraakte zones", group="Supply & Demand")

supplyColor        = input.color(color.new(#000000, 85), "Supply kleur", group="Supply & Demand")
demandColor        = input.color(color.new(#000000, 85), "Demand kleur", group="Supply & Demand")
sdBorderColor      = input.color(#000000, "Rand kleur", group="Supply & Demand")
sdBorderWidth      = input.int(0, "Rand dikte", minval=0, maxval=5, group="Supply & Demand")
sdBorderStyleIn    = input.string("Solid", "Rand stijl", options=["Solid", "Dashed", "Dotted"], group="Supply & Demand")

showSDLabels       = input.bool(true, "Toon label in zone", group="Supply & Demand")
supplyLabelText    = input.string("Supply", "Supply label tekst", group="Supply & Demand")
demandLabelText    = input.string("Demand", "Demand label tekst", group="Supply & Demand")
sdLabelColor       = input.color(#000000, "Label tekst kleur", group="Supply & Demand")
sdLabelSizeIn      = input.string("Small", "Label grootte", options=["Tiny", "Small", "Normal", "Large"], group="Supply & Demand")

sdBorderStyle = sdBorderStyleIn == "Dashed" ? line.style_dashed : sdBorderStyleIn == "Dotted" ? line.style_dotted : line.style_solid
sdLabelSize   = sdLabelSizeIn == "Tiny" ? size.tiny : sdLabelSizeIn == "Small" ? size.small : sdLabelSizeIn == "Large" ? size.large : size.normal

sdHigh = ta.pivothigh(high, sdLength, sdLength)
sdLow  = ta.pivotlow(low, sdLength, sdLength)

var box[] supplyBoxes = array.new_box()
var float[] supplyTops = array.new_float()
var float[] supplyBots = array.new_float()
var label[] supplyLabels = array.new_label()

var box[] demandBoxes = array.new_box()
var float[] demandTops = array.new_float()
var float[] demandBots = array.new_float()
var label[] demandLabels = array.new_label()

if showSD and not na(sdHigh)
    zoneBar = bar_index - sdLength
    zoneTop = high[sdLength]
    zoneBot = math.max(open[sdLength], close[sdLength])

    newSupply = box.new(zoneBar, zoneTop, bar_index + sdExtend, zoneBot, bgcolor=supplyColor, border_color=sdBorderColor, border_width=sdBorderWidth, border_style=sdBorderStyle)
    array.push(supplyBoxes, newSupply)
    array.push(supplyTops, zoneTop)
    array.push(supplyBots, zoneBot)

    if showSDLabels
        newLabel = label.new(math.floor((zoneBar + bar_index + sdExtend) / 2), (zoneTop + zoneBot) / 2, supplyLabelText, style=label.style_none, textcolor=sdLabelColor, size=sdLabelSize)
        array.push(supplyLabels, newLabel)
    else
        array.push(supplyLabels, na)

    if array.size(supplyBoxes) > sdMaxZones
        oldBox = array.shift(supplyBoxes)
        oldLabel = array.shift(supplyLabels)
        box.delete(oldBox)
        if not na(oldLabel)
            label.delete(oldLabel)
        array.shift(supplyTops)
        array.shift(supplyBots)

if showSD and not na(sdLow)
    zoneBar = bar_index - sdLength
    zoneTop = math.min(open[sdLength], close[sdLength])
    zoneBot = low[sdLength]

    newDemand = box.new(zoneBar, zoneTop, bar_index + sdExtend, zoneBot, bgcolor=demandColor, border_color=sdBorderColor, border_width=sdBorderWidth, border_style=sdBorderStyle)
    array.push(demandBoxes, newDemand)
    array.push(demandTops, zoneTop)
    array.push(demandBots, zoneBot)

    if showSDLabels
        newLabel = label.new(math.floor((zoneBar + bar_index + sdExtend) / 2), (zoneTop + zoneBot) / 2, demandLabelText, style=label.style_none, textcolor=sdLabelColor, size=sdLabelSize)
        array.push(demandLabels, newLabel)
    else
        array.push(demandLabels, na)

    if array.size(demandBoxes) > sdMaxZones
        oldBox = array.shift(demandBoxes)
        oldLabel = array.shift(demandLabels)
        box.delete(oldBox)
        if not na(oldLabel)
            label.delete(oldLabel)
        array.shift(demandTops)
        array.shift(demandBots)

if deleteMitigatedSD and array.size(supplyBoxes) > 0
    i = 0
    while i < array.size(supplyBoxes)
        top = array.get(supplyTops, i)
        lbl = array.get(supplyLabels, i)
        mitigated = high >= top

        if mitigated
            box.delete(array.get(supplyBoxes, i))
            if not na(lbl)
                label.delete(lbl)
            array.remove(supplyBoxes, i)
            array.remove(supplyTops, i)
            array.remove(supplyBots, i)
            array.remove(supplyLabels, i)
        else
            i += 1

if deleteMitigatedSD and array.size(demandBoxes) > 0
    i = 0
    while i < array.size(demandBoxes)
        bot = array.get(demandBots, i)
        lbl = array.get(demandLabels, i)
        mitigated = low <= bot

        if mitigated
            box.delete(array.get(demandBoxes, i))
            if not na(lbl)
                label.delete(lbl)
            array.remove(demandBoxes, i)
            array.remove(demandTops, i)
            array.remove(demandBots, i)
            array.remove(demandLabels, i)
        else
            i += 1

// BOS
showBOS        = input.bool(true, "Toon BOS", group="BOS")
bosText        = input.string("BOS", "Tekst", group="BOS")
bosStyleInput  = input.string("Solid", "Lijn stijl", options=["Solid", "Dashed", "Dotted"], group="BOS")
bosTextSizeIn  = input.string("Small", "Tekst grootte", options=["Tiny", "Small", "Normal", "Large"], group="BOS")
bosBullColor   = input.color(#000000, "Bullish kleur", group="BOS")
bosBearColor   = input.color(#000000, "Bearish kleur", group="BOS")
bosTextColor   = input.color(#000000, "Tekst kleur", group="BOS")
bosLineWidth   = input.int(1, "Lijn dikte", minval=1, maxval=5, group="BOS")
bosCloseBuffer = input.float(0.0, "Buffer (pips)", step=0.1, group="BOS")

bosLineStyle = bosStyleInput == "Dashed" ? line.style_dashed : bosStyleInput == "Dotted" ? line.style_dotted : line.style_solid
bosTextSize  = bosTextSizeIn == "Tiny" ? size.tiny : bosTextSizeIn == "Small" ? size.small : bosTextSizeIn == "Large" ? size.large : size.normal

// CHoCH
showCHOCH        = input.bool(true, "Toon CHoCH", group="CHoCH")
chochText        = input.string("CHoCH", "Tekst", group="CHoCH")
chochStyleInput  = input.string("Dashed", "Lijn stijl", options=["Solid", "Dashed", "Dotted"], group="CHoCH")
chochTextSizeIn  = input.string("Small", "Tekst grootte", options=["Tiny", "Small", "Normal", "Large"], group="CHoCH")
chochBullColor   = input.color(#000000, "Bullish CHoCH kleur", group="CHoCH")
chochBearColor   = input.color(#000000, "Bearish CHoCH kleur", group="CHoCH")
chochTextColor   = input.color(#000000, "Tekst kleur", group="CHoCH")
chochLineWidth   = input.int(1, "Lijn dikte", minval=1, maxval=5, group="CHoCH")

chochLineStyle = chochStyleInput == "Dashed" ? line.style_dashed : chochStyleInput == "Dotted" ? line.style_dotted : line.style_solid
chochTextSize  = chochTextSizeIn == "Tiny" ? size.tiny : chochTextSizeIn == "Small" ? size.small : chochTextSizeIn == "Large" ? size.large : size.normal

pipValue  = syminfo.mintick * 10
bosBuffer = bosCloseBuffer * pipValue

var float lastSwingHigh  = na
var float lastSwingLow   = na
var int lastSwingHighBar = na
var int lastSwingLowBar  = na

var bool swingHighBroken = false
var bool swingLowBroken  = false

var int structureDirection = 0

if not na(swingHigh)
    lastSwingHigh    := swingHigh
    lastSwingHighBar := bar_index - swingLength
    swingHighBroken  := false

if not na(swingLow)
    lastSwingLow    := swingLow
    lastSwingLowBar := bar_index - swingLength
    swingLowBroken  := false

bullBreak = not na(lastSwingHigh) and not swingHighBroken and close > lastSwingHigh + bosBuffer and open > lastSwingHigh
bearBreak = not na(lastSwingLow) and not swingLowBroken and close < lastSwingLow - bosBuffer and open < lastSwingLow

bullCHOCH = bullBreak and structureDirection == -1
bearCHOCH = bearBreak and structureDirection == 1

bullBOS = bullBreak and not bullCHOCH
bearBOS = bearBreak and not bearCHOCH

if showBOS and bullBOS
    line.new(lastSwingHighBar, lastSwingHigh, bar_index, lastSwingHigh, color=bosBullColor, width=bosLineWidth, style=bosLineStyle)
    label.new(math.floor((lastSwingHighBar + bar_index) / 2), lastSwingHigh, bosText, style=label.style_none, textcolor=bosTextColor, size=bosTextSize)

if showBOS and bearBOS
    line.new(lastSwingLowBar, lastSwingLow, bar_index, lastSwingLow, color=bosBearColor, width=bosLineWidth, style=bosLineStyle)
    label.new(math.floor((lastSwingLowBar + bar_index) / 2), lastSwingLow, bosText, style=label.style_none, textcolor=bosTextColor, size=bosTextSize)

if showCHOCH and bullCHOCH
    line.new(lastSwingHighBar, lastSwingHigh, bar_index, lastSwingHigh, color=chochBullColor, width=chochLineWidth, style=chochLineStyle)
    label.new(math.floor((lastSwingHighBar + bar_index) / 2), lastSwingHigh, chochText, style=label.style_none, textcolor=chochTextColor, size=chochTextSize)

if showCHOCH and bearCHOCH
    line.new(lastSwingLowBar, lastSwingLow, bar_index, lastSwingLow, color=chochBearColor, width=chochLineWidth, style=chochLineStyle)
    label.new(math.floor((lastSwingLowBar + bar_index) / 2), lastSwingLow, chochText, style=label.style_none, textcolor=chochTextColor, size=chochTextSize)

if bullBreak
    swingHighBroken := true
    structureDirection := 1

if bearBreak
    swingLowBroken := true
    structureDirection := -1

// FVG
showFVG          = input.bool(true, "Toon FVG", group="FVG")
deleteFilledFVG  = input.bool(true, "Verwijder gevulde FVG", group="FVG")
fvgFillType      = input.string("Volledig gevuld", "Wanneer verwijderen", options=["Volledig gevuld", "Aangeraakt"], group="FVG")
bullFvgColor     = input.color(color.new(#000000, 80), "Bullish FVG kleur", group="FVG")
bearFvgColor     = input.color(color.new(#000000, 80), "Bearish FVG kleur", group="FVG")
fvgBorderColor   = input.color(#000000, "Rand kleur", group="FVG")
fvgBorderWidth   = input.int(0, "Rand dikte", minval=0, maxval=5, group="FVG")
fvgBorderStyleIn = input.string("Solid", "Rand stijl", options=["Solid", "Dashed", "Dotted"], group="FVG")
fvgExtend        = input.int(3, "Verlenging in candles", minval=1, maxval=300, group="FVG")

fvgBorderStyle = fvgBorderStyleIn == "Dashed" ? line.style_dashed : fvgBorderStyleIn == "Dotted" ? line.style_dotted : line.style_solid

bullFVG = low > high[2]
bearFVG = high < low[2]

var box[] bullFvgBoxes = array.new_box()
var float[] bullFvgTops = array.new_float()
var float[] bullFvgBots = array.new_float()

var box[] bearFvgBoxes = array.new_box()
var float[] bearFvgTops = array.new_float()
var float[] bearFvgBots = array.new_float()

if showFVG and bullFVG
    newBox = box.new(bar_index - 2, low, bar_index + fvgExtend, high[2], bgcolor=bullFvgColor, border_color=fvgBorderColor, border_width=fvgBorderWidth, border_style=fvgBorderStyle)
    array.push(bullFvgBoxes, newBox)
    array.push(bullFvgTops, low)
    array.push(bullFvgBots, high[2])

if showFVG and bearFVG
    newBox = box.new(bar_index - 2, low[2], bar_index + fvgExtend, high, bgcolor=bearFvgColor, border_color=fvgBorderColor, border_width=fvgBorderWidth, border_style=fvgBorderStyle)
    array.push(bearFvgBoxes, newBox)
    array.push(bearFvgTops, low[2])
    array.push(bearFvgBots, high)

if deleteFilledFVG and array.size(bullFvgBoxes) > 0
    i = 0
    while i < array.size(bullFvgBoxes)
        fvgTop = array.get(bullFvgTops, i)
        fvgBot = array.get(bullFvgBots, i)

        filled = fvgFillType == "Aangeraakt" ? low <= fvgTop : low <= fvgBot

        if filled
            box.delete(array.get(bullFvgBoxes, i))
            array.remove(bullFvgBoxes, i)
            array.remove(bullFvgTops, i)
            array.remove(bullFvgBots, i)
        else
            i += 1

if deleteFilledFVG and array.size(bearFvgBoxes) > 0
    i = 0
    while i < array.size(bearFvgBoxes)
        fvgTop = array.get(bearFvgTops, i)
        fvgBot = array.get(bearFvgBots, i)

        filled = fvgFillType == "Aangeraakt" ? high >= fvgBot : high >= fvgTop

        if filled
            box.delete(array.get(bearFvgBoxes, i))
            array.remove(bearFvgBoxes, i)
            array.remove(bearFvgTops, i)
            array.remove(bearFvgBots, i)
        else
            i += 1

// LQ SWEEPS
showSweeps       = input.bool(false, "Toon LQ Sweeps", group="LQ Sweeps")
liqLookback      = input.int(10, "Sweep gevoeligheid", minval=3, maxval=50, group="LQ Sweeps")
liqMaxAge        = input.int(50, "Max leeftijd level", minval=5, maxval=500, group="LQ Sweeps")
sweepBufferPips  = input.float(0.5, "Sweep buffer (pips)", step=0.1, group="LQ Sweeps")
sweepLineColor   = input.color(#000000, "Sweep lijn kleur", group="LQ Sweeps")
sweepLineWidth   = input.int(1, "Sweep lijn dikte", minval=1, maxval=4, group="LQ Sweeps")
sweepLineStyleIn = input.string("Solid", "Sweep lijn stijl", options=["Solid", "Dashed", "Dotted"], group="LQ Sweeps")
sweepText        = input.string("LQ", "Sweep tekst", group="LQ Sweeps")
sweepTextColor   = input.color(#000000, "Sweep tekst kleur", group="LQ Sweeps")
sweepTextSizeIn  = input.string("Small", "Sweep tekst grootte", options=["Tiny", "Small", "Normal"], group="LQ Sweeps")

sweepLineStyle = sweepLineStyleIn == "Dashed" ? line.style_dashed : sweepLineStyleIn == "Dotted" ? line.style_dotted : line.style_solid
sweepTxtSz     = sweepTextSizeIn == "Tiny" ? size.tiny : sweepTextSizeIn == "Normal" ? size.normal : size.small
sweepBuffer    = sweepBufferPips * pipValue

liqHigh = ta.pivothigh(high, liqLookback, liqLookback)
liqLow  = ta.pivotlow(low, liqLookback, liqLookback)

var float[] liqHighLevels = array.new_float()
var int[] liqHighBars = array.new_int()

var float[] liqLowLevels = array.new_float()
var int[] liqLowBars = array.new_int()

if not na(liqHigh)
    array.push(liqHighLevels, liqHigh)
    array.push(liqHighBars, bar_index - liqLookback)

if not na(liqLow)
    array.push(liqLowLevels, liqLow)
    array.push(liqLowBars, bar_index - liqLookback)

if array.size(liqHighLevels) > 0
    i = 0
    while i < array.size(liqHighLevels)
        lvl = array.get(liqHighLevels, i)
        startB = array.get(liqHighBars, i)
        tooOld = bar_index - startB > liqMaxAge

        highSweep = high > lvl + sweepBuffer and open < lvl and close < lvl

        if tooOld
            array.remove(liqHighLevels, i)
            array.remove(liqHighBars, i)
        else if highSweep
            if showSweeps
                midBar = math.floor((startB + bar_index) / 2)
                line.new(startB, lvl, bar_index, lvl, color=sweepLineColor, width=sweepLineWidth, style=sweepLineStyle)
                label.new(midBar, lvl, sweepText, style=label.style_none, textcolor=sweepTextColor, size=sweepTxtSz)

            array.remove(liqHighLevels, i)
            array.remove(liqHighBars, i)
        else
            i += 1

if array.size(liqLowLevels) > 0
    i = 0
    while i < array.size(liqLowLevels)
        lvl = array.get(liqLowLevels, i)
        startB = array.get(liqLowBars, i)
        tooOld = bar_index - startB > liqMaxAge

        lowSweep = low < lvl - sweepBuffer and open > lvl and close > lvl

        if tooOld
            array.remove(liqLowLevels, i)
            array.remove(liqLowBars, i)
        else if lowSweep
            if showSweeps
                midBar = math.floor((startB + bar_index) / 2)
                line.new(startB, lvl, bar_index, lvl, color=sweepLineColor, width=sweepLineWidth, style=sweepLineStyle)
                label.new(midBar, lvl, sweepText, style=label.style_none, textcolor=sweepTextColor, size=sweepTxtSz)

            array.remove(liqLowLevels, i)
            array.remove(liqLowBars, i)
        else
            i += 1

// EMA
showEma      = input.bool(false, "Toon EMA", group="EMA")
ema50Length  = input.int(50, "EMA 50 lengte", group="EMA")
ema200Length = input.int(200, "EMA 200 lengte", group="EMA")
ema50Color   = input.color(#000000, "EMA 50 kleur", group="EMA")
ema200Color  = input.color(#000000, "EMA 200 kleur", group="EMA")
emaWidth     = input.int(2, "Lijn dikte", minval=1, maxval=5, group="EMA")

ema50  = ta.ema(close, ema50Length)
ema200 = ta.ema(close, ema200Length)

plot(showEma ? ema50 : na, color=ema50Color, linewidth=emaWidth)
plot(showEma ? ema200 : na, color=ema200Color, linewidth=emaWidth)
````

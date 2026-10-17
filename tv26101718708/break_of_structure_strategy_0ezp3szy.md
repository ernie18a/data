# BREAK OF STRUCTURE strategy

- url: https://www.tradingview.com/script/0EZp3sZy-BREAK-OF-STRUCTURE-strategy/
- type: indicator
- pine_id: PUB;a0213a49a4b84ca8ae9597033489c73c
- version: 1.0

## Description

this looks at break of structures and potential trend changes using support and resistance zones

## Source Code

````pine
//@version=6
//"SKYVISION ACADEMY"
//"Join now: https://selar.com/lq784261m9"
indicator("BREAK OF STRUCTURE strategy", shorttitle="BOSStrat", overlay=true, max_lines_count=500, max_labels_count=500)

//============================= Inputs =============================
groupGeneral = "1) General"
groupSR      = "2) Support / Resistance"
groupArrows  = "3) Break-Close Arrows"
groupBos     = "4) BoS / TC Structure"

barsToProcess = input.int(2500, "Bars To Process", minval=0, group=groupGeneral)

//---- Support / Resistance
showSR             = input.bool(true, "Show S/R Levels", group=groupSR)
srLeftBars         = input.int(2, "S/R Left Bars", minval=1, group=groupSR)
srRightBars        = input.int(2, "S/R Right Bars", minval=1, group=groupSR)
srBackpaintDisplay = input.bool(true, "Backpaint S/R Display", group=groupSR)
levelMarkerWidth   = input.int(1, "Level Marker Width", minval=1, maxval=6, group=groupSR)
resistanceColor    = input.color(color.aqua, "Resistance Color", group=groupSR)
supportColor       = input.color(color.rgb(255, 192, 203), "Support Color", group=groupSR)

//---- Break-close arrows from S/R levels
showBuyArrows             = input.bool(true, "Show Buy Arrows", group=groupArrows)
showSellArrows            = input.bool(true, "Show Sell Arrows", group=groupArrows)
buyArrowColor             = input.color(color.rgb(0, 191, 255), "Buy Arrow Color", group=groupArrows)
sellArrowColor            = input.color(color.rgb(128, 0, 64), "Sell Arrow Color", group=groupArrows)
arrowOffsetPips           = input.float(4.0, "Arrow Offset (pips)", minval=0.0, step=0.1, group=groupArrows)
arrowShapeSize            = input.string("Small", "Arrow Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=groupArrows)
requirePreviousCloseCross = input.bool(true, "Require Previous Close Cross", group=groupArrows)

//---- BoS / TC structure settings
pivotLeftBars            = input.int(3, "Pivot Left Bars", minval=1, group=groupBos)
pivotRightBars           = input.int(3, "Pivot Right Bars", minval=1, group=groupBos)
breakoutConfirmation     = input.string("Close", "Breakout Confirmation", options=["Close", "Wick"], group=groupBos)
showHHLL                 = input.bool(false, "Show HH/LL", group=groupBos)
showHLLH                 = input.bool(false, "Show HL/LH", group=groupBos)
showBOS                  = input.bool(true, "Show BOS", group=groupBos)
showTC                = input.bool(true, "Show TC", group=groupBos)
topSwingPointColor       = input.color(color.lime, "Top Swing Point Color", group=groupBos)
bottomSwingPointColor    = input.color(color.blue, "Bottom Swing Point Color", group=groupBos)
bullBosTCLineColor    = input.color(color.rgb(240, 230, 140), "Bull BOS/TC Line Color", group=groupBos)
bearBosTCLineColor    = input.color(color.maroon, "Bear BOS/TC Line Color", group=groupBos)
structureLineWidth       = input.int(1, "Structure Line Width", minval=1, maxval=6, group=groupBos)
structureTextSizeInput   = input.string("Normal", "Structure Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=groupBos)
structureTextPosition    = input.string("On Line", "Structure Text Position", options=["On Line", "Above Line", "Below Line"], group=groupBos)
structureTextOffsetTicks = input.int(6, "Structure Text Offset (ticks)", minval=0, group=groupBos)
swingTextOffsetTicks     = input.int(6, "Swing Text Offset (ticks)", minval=0, group=groupBos)
bosText                  = input.string("bos", "BOS Text", group=groupBos)
TCText                = input.string("TC", "TC Text", group=groupBos)

//============================= Helpers =============================
f_labelSize(string _size) =>
    _size == "Tiny" ? size.tiny :
     _size == "Small" ? size.small :
     _size == "Normal" ? size.normal :
     _size == "Large" ? size.large : size.huge

f_pipSize() =>
    syminfo.type == "forex" ? ((syminfo.mintick == 0.00001 or syminfo.mintick == 0.001) ? syminfo.mintick * 10.0 : syminfo.mintick) : syminfo.mintick

f_inVisualRange(int _barIndex) =>
    barsToProcess <= 0 or _barIndex >= last_bar_index - barsToProcess

float pipSize = f_pipSize()
float arrowOffset = arrowOffsetPips * pipSize
int srOffset = srBackpaintDisplay ? -srRightBars : 0

bool arrowSizeTiny   = arrowShapeSize == "Tiny"
bool arrowSizeSmall  = arrowShapeSize == "Small"
bool arrowSizeNormal = arrowShapeSize == "Normal"
bool arrowSizeLarge  = arrowShapeSize == "Large"
bool arrowSizeHuge   = arrowShapeSize == "Huge"

//============================= Support / Resistance =============================
srPivotHigh = ta.pivothigh(high, srLeftBars, srRightBars)
srPivotLow  = ta.pivotlow(low, srLeftBars, srRightBars)

var float currentResistance = na
var float currentSupport = na

float signalResistance = currentResistance
float signalSupport = currentSupport

bool buyBreak = false
bool sellBreak = false

if not na(signalResistance)
    buyBreak := requirePreviousCloseCross ? (close > signalResistance and nz(close[1], signalResistance) <= signalResistance) : (close > signalResistance)

if not na(signalSupport)
    sellBreak := requirePreviousCloseCross ? (close < signalSupport and nz(close[1], signalSupport) >= signalSupport) : (close < signalSupport)

if not na(srPivotHigh)
    currentResistance := srPivotHigh

if not na(srPivotLow)
    currentSupport := srPivotLow

plot(showSR ? currentResistance : na, title="Resistance", color=resistanceColor, linewidth=levelMarkerWidth, style=plot.style_circles, offset=srOffset)
plot(showSR ? currentSupport : na, title="Support", color=supportColor, linewidth=levelMarkerWidth, style=plot.style_circles, offset=srOffset)

//============================= Break-Close Triangles =============================
float buyMarkerPrice = low - arrowOffset
float sellMarkerPrice = high + arrowOffset

plotshape(showBuyArrows and buyBreak and arrowSizeTiny ? buyMarkerPrice : na,  title="Buy Break Tiny",   style=shape.triangleup,   location=location.absolute, color=buyArrowColor,  size=size.tiny)
plotshape(showBuyArrows and buyBreak and arrowSizeSmall ? buyMarkerPrice : na, title="Buy Break Small",  style=shape.triangleup,   location=location.absolute, color=buyArrowColor,  size=size.small)
plotshape(showBuyArrows and buyBreak and arrowSizeNormal ? buyMarkerPrice : na, title="Buy Break Normal", style=shape.triangleup,  location=location.absolute, color=buyArrowColor,  size=size.normal)
plotshape(showBuyArrows and buyBreak and arrowSizeLarge ? buyMarkerPrice : na, title="Buy Break Large",  style=shape.triangleup,   location=location.absolute, color=buyArrowColor,  size=size.large)
plotshape(showBuyArrows and buyBreak and arrowSizeHuge ? buyMarkerPrice : na,  title="Buy Break Huge",   style=shape.triangleup,   location=location.absolute, color=buyArrowColor,  size=size.huge)

plotshape(showSellArrows and sellBreak and arrowSizeTiny ? sellMarkerPrice : na,  title="Sell Break Tiny",   style=shape.triangledown, location=location.absolute, color=sellArrowColor, size=size.tiny)
plotshape(showSellArrows and sellBreak and arrowSizeSmall ? sellMarkerPrice : na, title="Sell Break Small",  style=shape.triangledown, location=location.absolute, color=sellArrowColor, size=size.small)
plotshape(showSellArrows and sellBreak and arrowSizeNormal ? sellMarkerPrice : na, title="Sell Break Normal", style=shape.triangledown, location=location.absolute, color=sellArrowColor, size=size.normal)
plotshape(showSellArrows and sellBreak and arrowSizeLarge ? sellMarkerPrice : na, title="Sell Break Large",  style=shape.triangledown, location=location.absolute, color=sellArrowColor, size=size.large)
plotshape(showSellArrows and sellBreak and arrowSizeHuge ? sellMarkerPrice : na,  title="Sell Break Huge",   style=shape.triangledown, location=location.absolute, color=sellArrowColor, size=size.huge)

//============================= BoS / TC Structure =============================
bosPivotHigh = ta.pivothigh(high, pivotLeftBars, pivotRightBars)
bosPivotLow  = ta.pivotlow(low, pivotLeftBars, pivotRightBars)

var float previousPivotHigh = na
var float previousPivotLow = na

var float lastSwingHigh = na
var float lastSwingLow = na
var int lastSwingHighBar = na
var int lastSwingLowBar = na
var bool lastSwingHighBroken = false
var bool lastSwingLowBroken = false
var int structureDirection = 0  // 1 bullish, -1 bearish, 0 neutral

if not na(bosPivotHigh)
    int pivotBarHigh = bar_index - pivotRightBars
    float pivotPriceHigh = bosPivotHigh

    if not na(previousPivotHigh)
        string labelHigh = pivotPriceHigh >= previousPivotHigh ? "HH" : "LH"
        bool drawHigh = (labelHigh == "HH" and showHHLL) or (labelHigh == "LH" and showHLLH)
        if drawHigh and f_inVisualRange(pivotBarHigh)
            float yHigh = pivotPriceHigh + swingTextOffsetTicks * syminfo.mintick
            label.new(x=pivotBarHigh, y=yHigh, text=labelHigh, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=topSwingPointColor, size=f_labelSize(structureTextSizeInput))

    previousPivotHigh := pivotPriceHigh
    lastSwingHigh := pivotPriceHigh
    lastSwingHighBar := pivotBarHigh
    lastSwingHighBroken := false

if not na(bosPivotLow)
    int pivotBarLow = bar_index - pivotRightBars
    float pivotPriceLow = bosPivotLow

    if not na(previousPivotLow)
        string labelLow = pivotPriceLow <= previousPivotLow ? "LL" : "HL"
        bool drawLow = (labelLow == "LL" and showHHLL) or (labelLow == "HL" and showHLLH)
        if drawLow and f_inVisualRange(pivotBarLow)
            float yLow = pivotPriceLow - swingTextOffsetTicks * syminfo.mintick
            label.new(x=pivotBarLow, y=yLow, text=labelLow, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=bottomSwingPointColor, size=f_labelSize(structureTextSizeInput))

    previousPivotLow := pivotPriceLow
    lastSwingLow := pivotPriceLow
    lastSwingLowBar := pivotBarLow
    lastSwingLowBroken := false

float bullBreakSource = breakoutConfirmation == "Close" ? close : high
float bearBreakSource = breakoutConfirmation == "Close" ? close : low

bool bullBreakStruct = not na(lastSwingHigh) and not lastSwingHighBroken and not na(lastSwingHighBar) and bar_index > lastSwingHighBar and bullBreakSource > lastSwingHigh
bool bearBreakStruct = not na(lastSwingLow) and not lastSwingLowBroken and not na(lastSwingLowBar) and bar_index > lastSwingLowBar and bearBreakSource < lastSwingLow

if bullBreakStruct and bearBreakStruct
    bullBreakStruct := close >= open
    bearBreakStruct := not bullBreakStruct

if bullBreakStruct
    bool isTC = structureDirection == -1
    string txt = isTC ? TCText : bosText
    bool drawStruct = (isTC and showTC) or (not isTC and showBOS)

    if drawStruct and f_inVisualRange(bar_index)
        line.new(x1=lastSwingHighBar, y1=lastSwingHigh, x2=bar_index, y2=lastSwingHigh, xloc=xloc.bar_index, extend=extend.none, color=bullBosTCLineColor, width=structureLineWidth)
        int midBar = int(math.floor((lastSwingHighBar + bar_index) * 0.5))
        float textY = structureTextPosition == "Above Line" ? lastSwingHigh + structureTextOffsetTicks * syminfo.mintick :
                      structureTextPosition == "Below Line" ? lastSwingHigh - structureTextOffsetTicks * syminfo.mintick :
                      lastSwingHigh
        label.new(x=midBar, y=textY, text=txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=bullBosTCLineColor, size=f_labelSize(structureTextSizeInput))

    lastSwingHighBroken := true
    structureDirection := 1

if bearBreakStruct
    bool isTC = structureDirection == 1
    string txt = isTC ? TCText : bosText
    bool drawStruct = (isTC and showTC) or (not isTC and showBOS)

    if drawStruct and f_inVisualRange(bar_index)
        line.new(x1=lastSwingLowBar, y1=lastSwingLow, x2=bar_index, y2=lastSwingLow, xloc=xloc.bar_index, extend=extend.none, color=bearBosTCLineColor, width=structureLineWidth)
        int midBar = int(math.floor((lastSwingLowBar + bar_index) * 0.5))
        float textY = structureTextPosition == "Above Line" ? lastSwingLow + structureTextOffsetTicks * syminfo.mintick :
                      structureTextPosition == "Below Line" ? lastSwingLow - structureTextOffsetTicks * syminfo.mintick :
                      lastSwingLow
        label.new(x=midBar, y=textY, text=txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=bearBosTCLineColor, size=f_labelSize(structureTextSizeInput))

    lastSwingLowBroken := true
    structureDirection := -1

//============================= Alerts =============================
alertcondition(buyBreak, title="Buy Break Above Resistance", message="Price closed above resistance")
alertcondition(sellBreak, title="Sell Break Below Support", message="Price closed below support")
alertcondition(bullBreakStruct, title="Bullish BOS / TC", message="Bullish BOS / TC detected")
alertcondition(bearBreakStruct, title="Bearish BOS / TC", message="Bearish BOS / TC detected")
````

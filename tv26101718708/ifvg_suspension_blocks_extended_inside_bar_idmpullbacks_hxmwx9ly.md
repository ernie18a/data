# IFVG + Suspension Blocks + Extended Inside Bar + IDM/Pullbacks

- url: https://www.tradingview.com/script/hxMWx9lY-IFVG-Suspension-Blocks-Extended-Inside-Bar-IDM-Pullbacks/
- type: indicator
- pine_id: PUB;e14787ccf9294b88bc0b632df05cbf66
- version: 1.0

## Description

This indicator combines multiple independent market-structure tools into one script while keeping each logic separate and individually controllable.

Features include:

IFVG / BPR detection
ICT Suspension Blocks
Extended Inside Bar range highlighting
Internal and External Pullback markers
IDM line detection
Each module can be enabled or disabled from the indicator settings, allowing traders to focus only on the tools they want visible on the chart.

Designed by : SQT (ShadowQuant Trader)

Credits : Prajyot Mahajan

## Source Code

````pine
//@version=6
indicator("IFVG + Suspension Blocks + Extended Inside Bar + IDM/Pullbacks", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500, max_bars_back=500)

const string mainGroup = "Main Toggles"
const string idmControlsGroup = "IDM / Pullbacks Controls"
const string idmAppearanceGroup = "IDM / Pullbacks Appearance"

enableIFVG = input.bool(true, "IFVG", group = mainGroup)
enableSuspensionBlocks = input.bool(true, "Suspension Blocks", group = mainGroup)
enableExtendedInsideBar = input.bool(true, "Extended Inside Bar", group = mainGroup)
enableIDMLogic = input.bool(true, "IDM / Pullbacks", group = mainGroup)

//==============================
// IFVG (BPR)
//==============================
General_settings        = 'General settings'
tmf               = input.timeframe("","Timeframe", group = General_settings)
fvg_usewidth      = true
fvg_gapwidth      = 0.009
fvg_method        = '%'

mitgationTypeWick = input.string("Wick","Mitigation Type",options = ["Wick","Close"],inline = "mitper", group = General_settings) == "Wick"
mitgPer           = input.int(50,"Mitigation %",minval = 1,maxval = 100,inline = "mitper",step = 10, group = General_settings)

FVG_settings        = 'FVG settings'
fvgStyle          = input.string(line.style_dotted,"FVG Style",options = [line.style_solid,line.style_dotted,line.style_dashed], group = FVG_settings)
fvgLabl           = input.string(size.small,"Lable Size",options = [size.auto,size.tiny,size.normal,size.small,size.large], group = General_settings)

BPR_settings        = 'BPR settings'
bprStyle          = input.string(line.style_solid,"BPR Style",options = [line.style_solid,line.style_dotted,line.style_dashed], group = BPR_settings)
showhist          = false

numFVG            = input.int(2,"FVG Count", group = FVG_settings)
numBRB            = input.int(2,"BRB Count", group = BPR_settings)

Style_settings        = 'Color settings'
styleOption       = input.string("TLAB colors",  title = "Style:â€‡â€‡â€‡â€‡â€‡",  options = ["TLAB colors", "standart colors", "Monochrome black BG", "Monochrome grey BG", "Custom"], inline = 'h5', group = Style_settings)
Custom_S          = input.color (color.rgb(0, 4, 255) , 'Custom color ', group = Style_settings)

colorHigh = styleOption == "TLAB colors"           ? #9c9c9c   :
          styleOption   == "standart colors"       ? color.red :
          styleOption   == "Monochrome grey BG"    ? #000000   :
          styleOption   == "Monochrome black BG"   ? #9c9c9c   :
          styleOption   == "Custom"                ? Custom_S    : na

colorLow = styleOption == "TLAB colors"           ? #9c9c9c :
          styleOption  == "standart colors"       ? #00d451 :
          styleOption  == "Monochrome grey BG"    ? #000000 :
          styleOption  == "Monochrome black BG"   ? #9c9c9c :
          styleOption  == "Custom"                ? Custom_S  :na

imbalance_detection(top, btm, condition,atr) =>
    var is_width = true

    if fvg_usewidth
        dist = top - btm

        is_width := switch fvg_method
            'Points' => dist > fvg_gapwidth
            '%' => dist / btm * 100 > fvg_gapwidth
        is_width

    is_true = condition and is_width
    is_true

type fvgDetails
	int   Type = 0
	float Top = na
	float Btm = na
	int   left = na
    int   left2 = na
	int   right = na
    int   cnt = 0
    color   fvgClr=na

getFVG() =>
    atr = ta.atr(200)
    fvgDetails fd = fvgDetails.new()

    isFvgBull = imbalance_detection(low, high[2], low  > high[2] and close[1] > high[2],atr)
    isFvgBear = imbalance_detection(low[2], high, high < low[2]  and close[1] < low[2] ,atr)

    if  isFvgBull
        fd.Type     := 1
        fd.Top      := low
        fd.Btm      := high[2]
        fd.left     := time
        fd.left2    := time[2]
        fd.right    := time
        fd.fvgClr   := colorLow

    if  isFvgBear
        fd.Type  := -1
        fd.Top   := low[2]
        fd.Btm   := high
        fd.left  := time[2]
        fd.left2 := time
        fd.right := time 
        fd.fvgClr   := colorHigh

    [fd,open, close,high,low,high[1],low[1],close[1]]

[fd,open_, close_,high_,low_,high_p,low_p,close_p] = request.security(syminfo.tickerid,tmf, getFVG())

var arrFVDD = array.new<fvgDetails>(0)
var arrFVDDType = array.new_bool(0)

var arrFVDLineTop = array.new_line(0)
var arrFVDLineBtm = array.new_line(0)

var arrFVDLblTop = array.new_label(0)

if enableIFVG and arrFVDLineTop.size() > numFVG
    arrFVDLineTop.pop().delete()
    arrFVDLineBtm.pop().delete()
    arrFVDLblTop.pop().delete()
    arrFVDDType.pop()

var arrFVD_BPR = array.new<fvgDetails>(0)
var arrFVD_BPRBox = array.new_box(0)

if enableIFVG and arrFVD_BPRBox.size() > numBRB
    arrFVD_BPRBox.pop().delete()
    arrFVD_BPR.pop() 

addtimt = 5*(time[1] - time[2]) 
if enableIFVG and open_ != open_[1]
    isBPR = false
    if not na(fd) and not na(fd[1])
        if arrFVDD.size() > 0  and (fd.Type == 1 or fd.Type == -1)
            i = 0
            while i < arrFVDD.size() 
                odlfd = arrFVDD.get(i)
                c1 =  fd.Top <= odlfd.Top and fd.Btm >= odlfd.Btm
                c2 = fd.Top <= odlfd.Top and fd.Top > odlfd.Btm  and fd.Btm < odlfd.Btm 
                c3 = fd.Top > odlfd.Top and fd.Btm >= odlfd.Btm and fd.Btm < odlfd.Top
                c4 = fd.Top >= odlfd.Top and fd.Btm <= odlfd.Btm

                if c1 or c2 or c3 or c4
                    top_ = fd.Top 
                    btm_ = fd.Btm
                    bleft_ = odlfd.left
                    if c2
                        top_ := fd.Top 
                        btm_ := odlfd.Btm
                    else if c3
                        top_ := odlfd.Top 
                        btm_ := fd.Btm
                    else if c4
                        top_ := odlfd.Top 
                        btm_ := odlfd.Btm
    
                    isBPR := true
                    arrFVD_BPR.unshift(fvgDetails.new(fd.Type,top_,btm_,bleft_,time,0))
                    arrFVD_BPRBox.unshift(box.new(bleft_, top_, time, btm_, border_color = fd.fvgClr, bgcolor = na, xloc = xloc.bar_time,border_style = bprStyle,text = "BPR",text_size = fvgLabl,text_halign = text.align_right,text_color = fd.fvgClr))
    
                i += 1

    bullMit = mitgationTypeWick ? low_ : close_
    bearMit = mitgationTypeWick ? high_ : close_

    //fvg testing
    if arrFVDDType.size() > 0
        i = 0
        while i < arrFVDDType.size()
            fdnTpe = arrFVDDType.get(i)
            //fdn = arrFVDDBox.get(i)
            fdnLblTop = arrFVDLblTop.get(i)
            //fdnLblBtm = arrFVDLblBtm.get(i)

            fdnLinTop = arrFVDLineTop.get(i)
            fdnLinBtm = arrFVDLineBtm.get(i)

            fdnLblTop.set_x(time+addtimt)
            //fdnLblBtm.set_x(time)

            fdnLinTop.set_x2(time+addtimt)
            fdnLinBtm.set_x2(time+addtimt)

            minval = math.min(fdnLinBtm.get_y1(),fdnLinTop.get_y1())
            maxvla = math.max(fdnLinBtm.get_y1(),fdnLinTop.get_y1())
            midPnt = (maxvla - minval)*mitgPer*0.01
            if fdnTpe 
                if bullMit < (maxvla - midPnt)//fdn.get_bottom()
                    arrFVDLblTop.remove(i).delete()
                    arrFVDLineTop.remove(i).delete()
                    arrFVDLineBtm.remove(i).delete()
                    arrFVDDType.remove(i)
                    i -= 1
            else
                if bearMit > (minval + midPnt)//fdn.get_top()
                    arrFVDLblTop.remove(i).delete()
                    arrFVDLineTop.remove(i).delete()
                    arrFVDLineBtm.remove(i).delete()
                    arrFVDDType.remove(i)
                    i -= 1

            i += 1


    //bpr testing
    if arrFVD_BPR.size() > 0  
        i = 0
        while i < arrFVD_BPR.size()
            fdn = arrFVD_BPR.get(i)

            arrFVD_BPRBox.get(i).set_right(time+addtimt)

            minval = math.min(fdn.Top,fdn.Btm)
            maxvla = math.max(fdn.Top,fdn.Btm)
            midPnt = (maxvla - minval)*mitgPer*0.01

            if fdn.Type == 1
                if bullMit < (maxvla - midPnt)
                    bx = arrFVD_BPRBox.remove(i)
                    if showhist
                        bx.set_right(time+addtimt)
                    else
                        bx.delete()
                    arrFVD_BPR.remove(i)
                    i -= 1
            else
                if bearMit > (minval + midPnt)
                    bx = arrFVD_BPRBox.remove(i)
                    if showhist
                        bx.set_right(time+addtimt)
                    else
                        bx.delete()
                    arrFVD_BPR.remove(i)
                    i -= 1

            i += 1

    bullMitp = mitgationTypeWick ? low_p : close_p
    bearMitp = mitgationTypeWick ? high_p : close_p

    if arrFVDD.size() > 0
        i = 0
        while i < arrFVDD.size()
            fdn = arrFVDD.get(i)
            
            minval = math.min(fdn.Top,fdn.Btm)
            maxvla = math.max(fdn.Top,fdn.Btm)
            midPnt = (maxvla - minval)*mitgPer*0.01

            if fdn.Type == 1 
                if  bullMitp < (maxvla - midPnt)
                    arrFVDD.remove(i)
                    i -= 1
            else
                if  bearMitp > (minval + midPnt)
                    arrFVDD.remove(i)
                    i -= 1
            i += 1

   
    if not na(fd) and not na(fd[1])
        if fd.Type == 1 or fd.Type == -1 //(fd[1]).left != fd.left   
            arrFVDD.unshift(fd)
            if not isBPR
                arrFVDDType.unshift(fd.Type == 1)
                arrFVDLineTop.unshift(line.new(fd.left, fd.Top,time+addtimt, fd.Top,style = fvgStyle,color = fd.fvgClr,xloc = xloc.bar_time))
                arrFVDLineBtm.unshift(line.new(fd.left2, fd.Btm,time+addtimt, fd.Btm,style = fvgStyle,color = fd.fvgClr,xloc = xloc.bar_time))
                arrFVDLblTop.unshift(label.new(time+addtimt,  (fd.Top+fd.Btm)/2,color = #ff525200,xloc = xloc.bar_time,style = label.style_label_right,size = fvgLabl,text = "FVG",textcolor = fd.fvgClr))
               



//==============================
// ICT Suspension Blocks
//==============================

//â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// User Inputs
//â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

// Zone appearance
suspensionColorBullish = input.color(color.new(color.green, 80), "Bullish Background Color", group = "Suspension Block", inline = "1")
suspensionBorderBullish = input.color(color.new(color.green, 30), "Border", group = "Suspension Block", inline = "1")
suspensionColorBearish = input.color(color.new(color.red, 80), "Bearish Background Color", group = "Suspension Block", inline = "2")
suspensionBorderBearish = input.color(color.new(color.red, 30), "Border", group = "Suspension Block", inline = "2")
inversedColor          = input.color(color.new(color.gray, 70), "Inversion Background Color", group = "Suspension Block", inline = "3")
inversedBorderColor    = input.color(color.new(color.gray, 30), "Border", group = "Suspension Block", inline = "3")

// Zone extension
extendBoxes  = input.bool(false, "Extend Boxes Forward", group = "Suspension Block")
forwardBars  = input.int(10, "Forward Bars if Extension Disabled", minval=1, maxval=250, group = "Suspension Block")
maxBoxes     = input.int(10, "Maximum Boxes Displayed", minval=1, maxval=500, group = "Suspension Block")

// CE (Consequent Encroachment) Line settings
showCELine   = input.bool(true, "Show CE Line", group = "Consequent Encroachment")
ceLineColor  = input.color(color.black, "CE Line Color", group = "Consequent Encroachment")
ceLineStyle  = input.string(line.style_dotted, "CE Line Style", options=[line.style_solid, line.style_dashed, line.style_dotted], group = "Consequent Encroachment")
ceLineWidth  = input.int(1, "CE Line Width", minval=1, maxval=3, group = "Consequent Encroachment")

//â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Helper Functions
//â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

// Detect bullish body gap (entire body above previous body)
isBullishBodyGap(index) =>
    math.min(open[index], close[index]) > math.max(open[index + 1], close[index + 1])

// Detect bearish body gap (entire body below previous body)
isBearishBodyGap(index) =>
    math.max(open[index], close[index]) < math.min(open[index + 1], close[index + 1])

// Calculate top/bottom levels for bullish gaps
getBullishGapTop(index) =>
    math.min(open[index], close[index])
getBullishGapBottom(index) =>
    math.max(open[index + 1], close[index + 1])

// Calculate top/bottom levels for bearish gaps
getBearishGapTop(index) =>
    math.min(open[index + 1], close[index + 1])
getBearishGapBottom(index) =>
    math.max(open[index], close[index])

// Determine right edge of a block (extended forward or fixed length)
getRightEdge() =>
    if extendBoxes
        bar_index + 1
    else
        bar_index + forwardBars

// Calculate CE (midpoint of the block)
getCEPrice(top, bottom) =>
    (top + bottom) / 2

//â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Arrays to track active blocks
//â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
var box[] bullishBlocks   = array.new<box>()   // stores bullish blocks
var box[] bearishBlocks   = array.new<box>()   // stores bearish blocks
var bool[] bullishInversed = array.new<bool>() // tracks invalidation status
var bool[] bearishInversed = array.new<bool>()

// Arrays to track CE lines
var line[] bullishCELines = array.new<line>()
var line[] bearishCELines = array.new<line>()

//â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

if enableSuspensionBlocks
    // Suspension Block Detection
    //â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // Check for 2 consecutive bullish body gaps â†’ Bullish SB
    bullishSuspensionBlock = isBullishBodyGap(1) and isBullishBodyGap(0)

    // Check for 2 consecutive bearish body gaps â†’ Bearish SB
    bearishSuspensionBlock = isBearishBodyGap(1) and isBearishBodyGap(0)

    //â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    // Create New Suspension Blocks
    //â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    if bullishSuspensionBlock
        // Define block levels
        startPrice = getBullishGapBottom(1)
        endPrice   = getBullishGapTop(0)
        rightEdge  = getRightEdge()
        cePrice    = getCEPrice(endPrice, startPrice)
        
        // Draw bullish box
        suspensionBox = box.new(
            left=bar_index - 2, 
            right=rightEdge, 
            top=endPrice, 
            bottom=startPrice, 
            bgcolor=suspensionColorBullish, 
            border_color=suspensionBorderBullish,
            border_width=1
        )
        
        // Add CE line if enabled
        if showCELine
            ceLine = line.new(bar_index - 2, cePrice, rightEdge, cePrice, color=ceLineColor, style=ceLineStyle, width=ceLineWidth)
            array.push(bullishCELines, ceLine)
        
        // Save block + status
        array.push(bullishBlocks, suspensionBox)
        array.push(bullishInversed, false)

    if bearishSuspensionBlock
        // Define block levels
        startPrice = getBearishGapTop(1)
        endPrice   = getBearishGapBottom(0)
        rightEdge  = getRightEdge()
        cePrice    = getCEPrice(startPrice, endPrice)
        
        // Draw bearish box
        suspensionBox = box.new(
            left=bar_index - 2, 
            right=rightEdge, 
            top=startPrice, 
            bottom=endPrice, 
            bgcolor=suspensionColorBearish, 
            border_color=suspensionBorderBearish,
            border_width=1
        )
        
        // Add CE line if enabled
        if showCELine
            ceLine = line.new(bar_index - 2, cePrice, rightEdge, cePrice, color=ceLineColor, style=ceLineStyle, width=ceLineWidth)
            array.push(bearishCELines, ceLine)
        
        // Save block + status
        array.push(bearishBlocks, suspensionBox)
        array.push(bearishInversed, false)

    //â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    // Block Extension & Invalidation
    //â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // Extend bullish blocks forward until invalidated
    if extendBoxes and array.size(bullishBlocks) > 0
        for i = 0 to array.size(bullishBlocks) - 1
            if not array.get(bullishInversed, i)
                currentBox = array.get(bullishBlocks, i)
                boxTop     = box.get_top(currentBox)
                boxBottom  = box.get_bottom(currentBox)
                
                // Invalidation: price closes below the block
                inversed = close < boxBottom
                
                if inversed
                    // Change to inversed colors
                    box.set_bgcolor(currentBox, inversedColor)
                    box.set_border_color(currentBox, inversedBorderColor)
                    array.set(bullishInversed, i, true)
                else
                    // Extend forward
                    box.set_right(currentBox, bar_index + 1)
                    if showCELine and array.size(bullishCELines) > i
                        currentLine = array.get(bullishCELines, i)
                        line.set_x2(currentLine, bar_index + 1)

    // Extend bearish blocks forward until invalidated
    if extendBoxes and array.size(bearishBlocks) > 0
        for i = 0 to array.size(bearishBlocks) - 1
            if not array.get(bearishInversed, i)
                currentBox = array.get(bearishBlocks, i)
                boxTop     = box.get_top(currentBox)
                boxBottom  = box.get_bottom(currentBox)
                
                // Invalidation: price closes above the block
                inversed = close > boxTop
                
                if inversed
                    // Change to inversed colors
                    box.set_bgcolor(currentBox, inversedColor)
                    box.set_border_color(currentBox, inversedBorderColor)
                    array.set(bearishInversed, i, true)
                else
                    // Extend forward
                    box.set_right(currentBox, bar_index + 1)
                    if showCELine and array.size(bearishCELines) > i
                        currentLine = array.get(bearishCELines, i)
                        line.set_x2(currentLine, bar_index + 1)

    //â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    // Memory Management (Prevent Overload)
    //â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    if array.size(bullishBlocks) > maxBoxes
        box.delete(array.shift(bullishBlocks))
        array.shift(bullishInversed)
        if array.size(bullishCELines) > 0
            line.delete(array.shift(bullishCELines))

    if array.size(bearishBlocks) > maxBoxes
        box.delete(array.shift(bearishBlocks))
        array.shift(bearishInversed)
        if array.size(bearishCELines) > 0
            line.delete(array.shift(bearishCELines))

//==============================
// Extended Inside Bar
//==============================
// Extended Inside Bar Logic
var float eibMotherHigh = na
var float eibMotherLow = na
var bool eibInRange = false

eibIsInside = high <= high[1] and low >= low[1]

if enableExtendedInsideBar
    if not eibInRange
        if eibIsInside
            eibMotherHigh := high[1]
            eibMotherLow := low[1]
            eibInRange := true
    else
        if high <= eibMotherHigh and low >= eibMotherLow
            eibInRange := true
        else
            eibInRange := false
            eibMotherHigh := na
            eibMotherLow := na

barcolor(enableExtendedInsideBar and barstate.isconfirmed and eibInRange ? color.orange : na)

//==============================
// Pullback IDM
//==============================

internalColor = input.color(color.red, "Internal Pullback Color", group = idmAppearanceGroup)
externalColor = input.color(color.black, "External Pullback Color", group = idmAppearanceGroup)
arrowSizeInput = input.string("Small", "Pullback Arrow Size", options=["Tiny", "Small", "Normal", "Large"], group = idmAppearanceGroup)
arrowOffsetTicks = input.int(4, "Pullback Arrow Distance (Ticks)", minval=1, group = idmAppearanceGroup)

showPullbacks = input.bool(true, "Pullbacks", group = idmControlsGroup)
showInternalPullbacks = input.bool(true, "Show Internal Pullbacks", group = idmControlsGroup)
showExternalPullbacks = input.bool(true, "Show External Pullbacks", group = idmControlsGroup)
showIdm = input.bool(true, "IDM", group = idmControlsGroup)

idmColor = input.color(color.new(color.gray, 0), "IDM Color", group = idmAppearanceGroup)
showCh = false
showBullishOb = false
showBearishOb = false
showBullishWickOb = false
showBearishWickOb = false
pastBullishObCount = 0
pastBearishObCount = 0
pastBullishWickObCount = 0
pastBearishWickObCount = 0
obSearchBars = 40
bullishObColor = color.new(color.green, 80)
bearishObColor = color.new(color.red, 80)
bullishWickObColor = color.new(color.lime, 80)
bearishWickObColor = color.new(color.orange, 80)
obBorderColor = color.new(color.black, 0)
obTextColor = color.new(color.black, 0)
starColor = color.new(color.yellow, 0)
starOffsetTicks = 18

arrowSize = switch arrowSizeInput
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    => size.large

starSize = size.normal

newHighArrow(targetTime, targetPrice, targetColor) =>
    label.new(targetTime, targetPrice + syminfo.mintick * arrowOffsetTicks, "", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_arrowdown, color=targetColor, textcolor=targetColor, size=arrowSize)

newLowArrow(targetTime, targetPrice, targetColor) =>
    label.new(targetTime, targetPrice - syminfo.mintick * arrowOffsetTicks, "", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_arrowup, color=targetColor, textcolor=targetColor, size=arrowSize)

newIdmLine(leftTime, level) =>
    line.new(leftTime, level, time, level, xloc=xloc.bar_time, extend=extend.right, color=idmColor, style=line.style_dotted, width=1)

newIdmLabel(leftTime, level) =>
    label.new(int(math.floor((leftTime + time) / 2)), level, "IDM", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_none, color=color.new(color.black, 100), textcolor=idmColor, size=size.small)

updateIdm(refLine, refLabel, leftTime, level) =>
    if not na(refLine)
        line.set_x2(refLine, time)
    if not na(refLabel)
        label.set_x(refLabel, int(math.floor((leftTime + time) / 2)))
        label.set_y(refLabel, level)

finalizeIdm(refLine, refLabel, leftTime, level) =>
    if not na(refLine)
        line.set_extend(refLine, extend.none)
        line.set_x2(refLine, time)
    if not na(refLabel)
        label.set_x(refLabel, int(math.floor((leftTime + time) / 2)))
        label.set_y(refLabel, level)

// A1 pullback engine.
var bool motherInitialized = false
var float motherHigh = na
var float motherLow = na
var float lastRealHigh = na
var float lastRealLow = na

var bool highCandidateActive = false
var int highCandidateTime = na
var float highCandidateHigh = na
var float highLeftHigh = na

var bool lowCandidateActive = false
var int lowCandidateTime = na
var float lowCandidateLow = na
var float lowLeftLow = na

var float latestPullbackHigh = na
var int latestPullbackHighTime = na

var float latestPullbackLow = na
var int latestPullbackLowTime = na

var float externalHighPrice = na
var int externalHighTime = na
var label externalHighLabel = na
var float candidateLowPrice = na
var int candidateLowTime = na
var label candidateLowLabel = na

var float externalLowPrice = na
var int externalLowTime = na
var label externalLowLabel = na
var float candidateHighPrice = na
var int candidateHighTime = na
var label candidateHighLabel = na

// Pending IDM references.
var float pendingBullIdmLow = na
var int pendingBullIdmLowTime = na
var line pendingBullIdmLine = na
var label pendingBullIdmLabel = na

var float pendingBearIdmHigh = na
var int pendingBearIdmHighTime = na
var line pendingBearIdmLine = na
var label pendingBearIdmLabel = na

// OB storage.
var box[] bullObs = array.new_box()
var box[] bearObs = array.new_box()
var box[] bullWickObs = array.new_box()
var box[] bearWickObs = array.new_box()
var label[] bullObStars = array.new_label()
var label[] bearObStars = array.new_label()
var label[] bullWickObStars = array.new_label()
var label[] bearWickObStars = array.new_label()
var float[] bullObStarDepths = array.new_float()
var float[] bearObStarDepths = array.new_float()
var float[] bullWickStarDepths = array.new_float()
var float[] bearWickStarDepths = array.new_float()
var int[] highPullbackTimes = array.new_int()
var int[] lowPullbackTimes = array.new_int()

createBullOb(leftTime, topPrice, bottomPrice) =>
    box newBox = box.new(leftTime, topPrice, time, bottomPrice, xloc=xloc.bar_time, border_color=obBorderColor, bgcolor=bullishObColor)
    box.set_text(newBox, "Bullish OB")
    box.set_text_color(newBox, obTextColor)
    box.set_text_size(newBox, size.small)
    box.set_text_halign(newBox, text.align_center)
    box.set_text_valign(newBox, text.align_center)
    newBox

createBearOb(leftTime, topPrice, bottomPrice) =>
    box newBox = box.new(leftTime, topPrice, time, bottomPrice, xloc=xloc.bar_time, border_color=obBorderColor, bgcolor=bearishObColor)
    box.set_text(newBox, "Bearish OB")
    box.set_text_color(newBox, obTextColor)
    box.set_text_size(newBox, size.small)
    box.set_text_halign(newBox, text.align_center)
    box.set_text_valign(newBox, text.align_center)
    newBox

createBullWickOb(leftTime, topPrice, bottomPrice) =>
    box newBox = box.new(leftTime, topPrice, time, bottomPrice, xloc=xloc.bar_time, border_color=obBorderColor, bgcolor=bullishWickObColor)
    box.set_text(newBox, "Bullish Wick OB")
    box.set_text_color(newBox, obTextColor)
    box.set_text_size(newBox, size.small)
    box.set_text_halign(newBox, text.align_center)
    box.set_text_valign(newBox, text.align_center)
    newBox

createBearWickOb(leftTime, topPrice, bottomPrice) =>
    box newBox = box.new(leftTime, topPrice, time, bottomPrice, xloc=xloc.bar_time, border_color=obBorderColor, bgcolor=bearishWickObColor)
    box.set_text(newBox, "Bearish Wick OB")
    box.set_text_color(newBox, obTextColor)
    box.set_text_size(newBox, size.small)
    box.set_text_halign(newBox, text.align_center)
    box.set_text_valign(newBox, text.align_center)
    newBox

trimBoxes(boxArray, keepCount) =>
    while array.size(boxArray) > keepCount
        box oldBox = array.shift(boxArray)
        box.delete(oldBox)

trimTrackedBoxes(boxArray, starArray, depthArray, keepCount) =>
    while array.size(boxArray) > keepCount
        box oldBox = array.shift(boxArray)
        label oldStar = array.shift(starArray)
        array.shift(depthArray)
        box.delete(oldBox)
        if not na(oldStar)
            label.delete(oldStar)

pushTrackedBox(boxArray, starArray, depthArray, newBox) =>
    array.push(boxArray, newBox)
    array.push(starArray, na)
    array.push(depthArray, na)

removeTrackedBoxAt(boxArray, starArray, depthArray, index) =>
    box oldBox = array.get(boxArray, index)
    label oldStar = array.get(starArray, index)
    box.delete(oldBox)
    if not na(oldStar)
        label.delete(oldStar)
    array.remove(boxArray, index)
    array.remove(starArray, index)
    array.remove(depthArray, index)

clearTrackedBoxes(boxArray, starArray, depthArray) =>
    while array.size(boxArray) > 0
        removeTrackedBoxAt(boxArray, starArray, depthArray, array.size(boxArray) - 1)

rememberPullbackTime(pullbackTimes, pullbackTime) =>
    if not na(pullbackTime)
        bool exists = false
        if array.size(pullbackTimes) > 0
            for i = 0 to array.size(pullbackTimes) - 1
                if array.get(pullbackTimes, i) == pullbackTime
                    exists := true
                    break
        if not exists
            array.push(pullbackTimes, pullbackTime)
            if array.size(pullbackTimes) > 300
                array.shift(pullbackTimes)

isTrackedPullback(offset, pullbackTimes) =>
    bool found = false
    int targetTime = time[offset]
    if array.size(pullbackTimes) > 0
        for i = 0 to array.size(pullbackTimes) - 1
            if array.get(pullbackTimes, i) == targetTime
                found := true
                break
    found

isBullishStarHit(targetBox) =>
    float boxTop = box.get_top(targetBox)
    float boxBottom = box.get_bottom(targetBox)
    float boxMid = (boxTop + boxBottom) / 2.0
    close > open and low <= boxMid and close >= boxBottom

isBearishStarHit(targetBox) =>
    float boxTop = box.get_top(targetBox)
    float boxBottom = box.get_bottom(targetBox)
    float boxMid = (boxTop + boxBottom) / 2.0
    close < open and high >= boxMid and close <= boxTop

bullishStarDepth(targetBox) =>
    box.get_top(targetBox) - low

bearishStarDepth(targetBox) =>
    high - box.get_bottom(targetBox)

newBullishStarLabel() =>
    label.new(time, low - syminfo.mintick * starOffsetTicks, "*", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_none, color=color.new(color.black, 100), textcolor=starColor, size=starSize)

newBearishStarLabel() =>
    label.new(time, high + syminfo.mintick * starOffsetTicks, "*", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_none, color=color.new(color.black, 100), textcolor=starColor, size=starSize)

updateBullishStarForBox(starArray, depthArray, index, targetBox) =>
    if isBullishStarHit(targetBox)
        float currentDepth = bullishStarDepth(targetBox)
        float savedDepth = array.get(depthArray, index)
        label savedStar = array.get(starArray, index)
        if na(savedDepth) or currentDepth > savedDepth
            if not na(savedStar)
                label.delete(savedStar)
            label newStar = newBullishStarLabel()
            array.set(starArray, index, newStar)
            array.set(depthArray, index, currentDepth)

updateBearishStarForBox(starArray, depthArray, index, targetBox) =>
    if isBearishStarHit(targetBox)
        float currentDepth = bearishStarDepth(targetBox)
        float savedDepth = array.get(depthArray, index)
        label savedStar = array.get(starArray, index)
        if na(savedDepth) or currentDepth > savedDepth
            if not na(savedStar)
                label.delete(savedStar)
            label newStar = newBearishStarLabel()
            array.set(starArray, index, newStar)
            array.set(depthArray, index, currentDepth)

isBullishObCandidate(offset, idmLevel) =>
    bool valid = false
    if offset >= 2 and offset <= bar_index and not na(idmLevel)
        float candle1High = high[offset]
        float candle1Low = low[offset]
        float candle2Low = low[offset - 1]
        float candle3Low = low[offset - 2]
        bool hasImbalance = candle3Low > candle1High
        bool candle2Respected = candle2Low >= candle1Low
        bool belowIdm = candle1High < idmLevel
        bool untouched = true
        if offset > 2
            for touchOffset = offset - 3 to 0
                if low[touchOffset] <= candle1High
                    untouched := false
                    break
        bool sameBreachTouchInvalid = low <= candle1High
        valid := hasImbalance and candle2Respected and belowIdm and untouched and not sameBreachTouchInvalid
    valid

isBearishObCandidate(offset, idmLevel) =>
    bool valid = false
    if offset >= 2 and offset <= bar_index and not na(idmLevel)
        float candle1High = high[offset]
        float candle1Low = low[offset]
        float candle2High = high[offset - 1]
        float candle3High = high[offset - 2]
        bool hasImbalance = candle3High < candle1Low
        bool candle2Respected = candle2High <= candle1High
        bool aboveIdm = candle1Low > idmLevel
        bool untouched = true
        if offset > 2
            for touchOffset = offset - 3 to 0
                if high[touchOffset] >= candle1Low
                    untouched := false
                    break
        bool sameBreachTouchInvalid = high >= candle1Low
        valid := hasImbalance and candle2Respected and aboveIdm and untouched and not sameBreachTouchInvalid
    valid

isBullishWickObCandidate(offset, idmLevel) =>
    bool valid = false
    if offset >= 2 and offset <= bar_index and not na(idmLevel) and isTrackedPullback(offset, lowPullbackTimes)
        float wickTop = math.min(open[offset], close[offset])
        bool belowIdm = wickTop < idmLevel
        bool nextCandleRespected = low[offset - 1] >= wickTop
        bool untouched = true
        for touchOffset = offset - 2 to 0
            if low[touchOffset] < wickTop
                untouched := false
                break
        bool sameBreachTouchInvalid = low < wickTop
        valid := wickTop > low[offset] and belowIdm and nextCandleRespected and untouched and not sameBreachTouchInvalid
    valid

isBearishWickObCandidate(offset, idmLevel) =>
    bool valid = false
    if offset >= 2 and offset <= bar_index and not na(idmLevel) and isTrackedPullback(offset, highPullbackTimes)
        float wickBottom = math.max(open[offset], close[offset])
        bool aboveIdm = wickBottom > idmLevel
        bool nextCandleRespected = high[offset - 1] <= wickBottom
        bool untouched = true
        for touchOffset = offset - 2 to 0
            if high[touchOffset] > wickBottom
                untouched := false
                break
        bool sameBreachTouchInvalid = high > wickBottom
        valid := high[offset] > wickBottom and aboveIdm and nextCandleRespected and untouched and not sameBreachTouchInvalid
    valid

if enableIDMLogic
    isInsideBar = motherInitialized and high <= motherHigh and low >= motherLow

    if not motherInitialized
        motherInitialized := true
        motherHigh := high
        motherLow := low
        lastRealHigh := high
        lastRealLow := low
    else
        if not isInsideBar
            int currentTime = time
            float currentHigh = high
            float currentLow = low

            bool highEventReady = false
            int highEventTime = na
            float highEventPrice = na

            bool lowEventReady = false
            int lowEventTime = na
            float lowEventPrice = na

            if not highCandidateActive
                if currentHigh > lastRealHigh
                    highCandidateActive := true
                    highCandidateTime := currentTime
                    highCandidateHigh := currentHigh
                    highLeftHigh := lastRealHigh
            else
                if currentHigh < highCandidateHigh
                    if highCandidateHigh > highLeftHigh
                        highEventReady := true
                        highEventTime := highCandidateTime
                        highEventPrice := highCandidateHigh
                    highCandidateActive := false
                    if currentHigh > lastRealHigh
                        highCandidateActive := true
                        highCandidateTime := currentTime
                        highCandidateHigh := currentHigh
                        highLeftHigh := lastRealHigh
                else if currentHigh > highCandidateHigh
                    highCandidateTime := currentTime
                    highCandidateHigh := currentHigh
                    highLeftHigh := lastRealHigh

            if not lowCandidateActive
                if currentLow < lastRealLow
                    lowCandidateActive := true
                    lowCandidateTime := currentTime
                    lowCandidateLow := currentLow
                    lowLeftLow := lastRealLow
            else
                if currentLow > lowCandidateLow
                    if lowCandidateLow < lowLeftLow
                        lowEventReady := true
                        lowEventTime := lowCandidateTime
                        lowEventPrice := lowCandidateLow
                    lowCandidateActive := false
                    if currentLow < lastRealLow
                        lowCandidateActive := true
                        lowCandidateTime := currentTime
                        lowCandidateLow := currentLow
                        lowLeftLow := lastRealLow
                else if currentLow < lowCandidateLow
                    lowCandidateTime := currentTime
                    lowCandidateLow := currentLow
                    lowLeftLow := lastRealLow

            bool processHighNow = highEventReady and (not lowEventReady or highEventTime <= lowEventTime)
            bool processLowNow = lowEventReady and (not highEventReady or lowEventTime < highEventTime)

            if processHighNow
                bool isExternalHigh = na(externalHighPrice) or na(externalLowPrice) or highEventPrice > externalHighPrice
                if isExternalHigh
                    if showPullbacks and showExternalPullbacks
                        externalHighLabel := newHighArrow(highEventTime, highEventPrice, externalColor)
                else
                    if showPullbacks and showInternalPullbacks
                        candidateHighLabel := newHighArrow(highEventTime, highEventPrice, internalColor)

                latestPullbackHigh := highEventPrice
                latestPullbackHighTime := highEventTime
                rememberPullbackTime(highPullbackTimes, highEventTime)

                if na(externalHighPrice)
                    externalHighPrice := highEventPrice
                    externalHighTime := highEventTime
                else if na(externalLowPrice)
                    externalHighPrice := highEventPrice
                    externalHighTime := highEventTime
                else
                    if na(candidateHighPrice) or highEventPrice >= candidateHighPrice
                        candidateHighPrice := highEventPrice
                        candidateHighTime := highEventTime

                    if highEventPrice > externalHighPrice
                        externalHighPrice := highEventPrice
                        externalHighTime := highEventTime
                        externalLowPrice := candidateLowPrice
                        externalLowTime := candidateLowTime
                        candidateLowPrice := na
                        candidateLowTime := na

                        pendingBullIdmLow := latestPullbackLow
                        pendingBullIdmLowTime := latestPullbackLowTime
                        finalizeIdm(pendingBullIdmLine, pendingBullIdmLabel, pendingBullIdmLowTime, pendingBullIdmLow)
                        if not na(pendingBullIdmLabel)
                            label.delete(pendingBullIdmLabel)
                        if not na(pendingBullIdmLine)
                            line.delete(pendingBullIdmLine)
                        pendingBullIdmLine := not na(pendingBullIdmLow) and showIdm ? newIdmLine(pendingBullIdmLowTime, pendingBullIdmLow) : na
                        pendingBullIdmLabel := not na(pendingBullIdmLow) and showIdm ? newIdmLabel(pendingBullIdmLowTime, pendingBullIdmLow) : na

            if processLowNow
                bool isExternalLow = na(externalLowPrice) or na(externalHighPrice) or lowEventPrice < externalLowPrice
                if isExternalLow
                    if showPullbacks and showExternalPullbacks
                        externalLowLabel := newLowArrow(lowEventTime, lowEventPrice, externalColor)
                else
                    if showPullbacks and showInternalPullbacks
                        candidateLowLabel := newLowArrow(lowEventTime, lowEventPrice, internalColor)

                latestPullbackLow := lowEventPrice
                latestPullbackLowTime := lowEventTime
                rememberPullbackTime(lowPullbackTimes, lowEventTime)

                if na(externalLowPrice)
                    externalLowPrice := lowEventPrice
                    externalLowTime := lowEventTime
                else if na(externalHighPrice)
                    externalLowPrice := lowEventPrice
                    externalLowTime := lowEventTime
                else
                    if na(candidateLowPrice) or lowEventPrice <= candidateLowPrice
                        candidateLowPrice := lowEventPrice
                        candidateLowTime := lowEventTime

                    if lowEventPrice < externalLowPrice
                        externalLowPrice := lowEventPrice
                        externalLowTime := lowEventTime
                        externalHighPrice := candidateHighPrice
                        externalHighTime := candidateHighTime
                        candidateHighPrice := na
                        candidateHighTime := na

                        pendingBearIdmHigh := latestPullbackHigh
                        pendingBearIdmHighTime := latestPullbackHighTime
                        finalizeIdm(pendingBearIdmLine, pendingBearIdmLabel, pendingBearIdmHighTime, pendingBearIdmHigh)
                        if not na(pendingBearIdmLabel)
                            label.delete(pendingBearIdmLabel)
                        if not na(pendingBearIdmLine)
                            line.delete(pendingBearIdmLine)
                        pendingBearIdmLine := not na(pendingBearIdmHigh) and showIdm ? newIdmLine(pendingBearIdmHighTime, pendingBearIdmHigh) : na
                        pendingBearIdmLabel := not na(pendingBearIdmHigh) and showIdm ? newIdmLabel(pendingBearIdmHighTime, pendingBearIdmHigh) : na

            lastRealHigh := currentHigh
            lastRealLow := currentLow
            motherHigh := currentHigh
            motherLow := currentLow

        if showIdm
            if not na(pendingBullIdmLine)
                updateIdm(pendingBullIdmLine, pendingBullIdmLabel, pendingBullIdmLowTime, pendingBullIdmLow)
            if not na(pendingBearIdmLine)
                updateIdm(pendingBearIdmLine, pendingBearIdmLabel, pendingBearIdmHighTime, pendingBearIdmHigh)

        if not na(pendingBullIdmLow) and low < pendingBullIdmLow
            if showCh and showBullishOb and pastBullishObCount > 0
                float bestBullDistance = na
                int bestBullOffset = na
                int maxOffsetBull = math.min(obSearchBars, bar_index)
                for offset = 2 to maxOffsetBull
                    if isBullishObCandidate(offset, pendingBullIdmLow)
                        float distanceToIdm = pendingBullIdmLow - high[offset]
                        if na(bestBullDistance) or distanceToIdm < bestBullDistance
                            bestBullDistance := distanceToIdm
                            bestBullOffset := offset
                clearTrackedBoxes(bullObs, bullObStars, bullObStarDepths)
                if not na(bestBullOffset)
                    box bullBox = createBullOb(time[bestBullOffset], high[bestBullOffset], low[bestBullOffset])
                    pushTrackedBox(bullObs, bullObStars, bullObStarDepths, bullBox)

            if showCh and showBullishWickOb and pastBullishWickObCount > 0
                float[] bestBullWickDistances = array.new_float()
                int[] bestBullWickOffsets = array.new_int()
                int maxOffsetBullWick = math.min(obSearchBars, bar_index)
                for offset = 2 to maxOffsetBullWick
                    if isBullishWickObCandidate(offset, pendingBullIdmLow)
                        float wickDistanceToIdm = pendingBullIdmLow - math.min(open[offset], close[offset])
                        int insertAt = array.size(bestBullWickDistances)
                        if array.size(bestBullWickDistances) > 0
                            for i = 0 to array.size(bestBullWickDistances) - 1
                                if wickDistanceToIdm < array.get(bestBullWickDistances, i)
                                    insertAt := i
                                    break
                        if insertAt < pastBullishWickObCount
                            array.insert(bestBullWickDistances, insertAt, wickDistanceToIdm)
                            array.insert(bestBullWickOffsets, insertAt, offset)
                            if array.size(bestBullWickDistances) > pastBullishWickObCount
                                array.pop(bestBullWickDistances)
                                array.pop(bestBullWickOffsets)
                if array.size(bestBullWickOffsets) > 0
                    for i = 0 to array.size(bestBullWickOffsets) - 1
                        int selectedOffset = array.get(bestBullWickOffsets, i)
                        float wickTop = math.min(open[selectedOffset], close[selectedOffset])
                        float wickBottom = low[selectedOffset]
                        box bullWickBox = createBullWickOb(time[selectedOffset], wickTop, wickBottom)
                        pushTrackedBox(bullWickObs, bullWickObStars, bullWickStarDepths, bullWickBox)
                trimTrackedBoxes(bullWickObs, bullWickObStars, bullWickStarDepths, pastBullishWickObCount)
            finalizeIdm(pendingBullIdmLine, pendingBullIdmLabel, pendingBullIdmLowTime, pendingBullIdmLow)
            pendingBullIdmLow := na
            pendingBullIdmLowTime := na
            pendingBullIdmLine := na
            pendingBullIdmLabel := na

        if not na(pendingBearIdmHigh) and high > pendingBearIdmHigh
            if showCh and showBearishOb and pastBearishObCount > 0
                float bestBearDistance = na
                int bestBearOffset = na
                int maxOffsetBear = math.min(obSearchBars, bar_index)
                for offset = 2 to maxOffsetBear
                    if isBearishObCandidate(offset, pendingBearIdmHigh)
                        float distanceToIdm = low[offset] - pendingBearIdmHigh
                        if na(bestBearDistance) or distanceToIdm < bestBearDistance
                            bestBearDistance := distanceToIdm
                            bestBearOffset := offset
                clearTrackedBoxes(bearObs, bearObStars, bearObStarDepths)
                if not na(bestBearOffset)
                    box bearBox = createBearOb(time[bestBearOffset], high[bestBearOffset], low[bestBearOffset])
                    pushTrackedBox(bearObs, bearObStars, bearObStarDepths, bearBox)

            if showCh and showBearishWickOb and pastBearishWickObCount > 0
                float[] bestBearWickDistances = array.new_float()
                int[] bestBearWickOffsets = array.new_int()
                int maxOffsetBearWick = math.min(obSearchBars, bar_index)
                for offset = 2 to maxOffsetBearWick
                    if isBearishWickObCandidate(offset, pendingBearIdmHigh)
                        float wickDistanceToIdm = math.max(open[offset], close[offset]) - pendingBearIdmHigh
                        int insertAt = array.size(bestBearWickDistances)
                        if array.size(bestBearWickDistances) > 0
                            for i = 0 to array.size(bestBearWickDistances) - 1
                                if wickDistanceToIdm < array.get(bestBearWickDistances, i)
                                    insertAt := i
                                    break
                        if insertAt < pastBearishWickObCount
                            array.insert(bestBearWickDistances, insertAt, wickDistanceToIdm)
                            array.insert(bestBearWickOffsets, insertAt, offset)
                            if array.size(bestBearWickDistances) > pastBearishWickObCount
                                array.pop(bestBearWickDistances)
                                array.pop(bestBearWickOffsets)
                if array.size(bestBearWickOffsets) > 0
                    for i = 0 to array.size(bestBearWickOffsets) - 1
                        int selectedOffset = array.get(bestBearWickOffsets, i)
                        float wickTop = high[selectedOffset]
                        float wickBottom = math.max(open[selectedOffset], close[selectedOffset])
                        box bearWickBox = createBearWickOb(time[selectedOffset], wickTop, wickBottom)
                        pushTrackedBox(bearWickObs, bearWickObStars, bearWickStarDepths, bearWickBox)
                trimTrackedBoxes(bearWickObs, bearWickObStars, bearWickStarDepths, pastBearishWickObCount)
            finalizeIdm(pendingBearIdmLine, pendingBearIdmLabel, pendingBearIdmHighTime, pendingBearIdmHigh)
            pendingBearIdmHigh := na
            pendingBearIdmHighTime := na
            pendingBearIdmLine := na
            pendingBearIdmLabel := na

    // Extend visible OB boxes to the current bar.
    if showCh and array.size(bullObs) > 0
        for i = array.size(bullObs) - 1 to 0
            box bullBox = array.get(bullObs, i)
            if close < box.get_bottom(bullBox)
                removeTrackedBoxAt(bullObs, bullObStars, bullObStarDepths, i)
            else
                box.set_right(bullBox, time)
                updateBullishStarForBox(bullObStars, bullObStarDepths, i, bullBox)

    if showCh and array.size(bearObs) > 0
        for i = array.size(bearObs) - 1 to 0
            box bearBox = array.get(bearObs, i)
            if close > box.get_top(bearBox)
                removeTrackedBoxAt(bearObs, bearObStars, bearObStarDepths, i)
            else
                box.set_right(bearBox, time)
                updateBearishStarForBox(bearObStars, bearObStarDepths, i, bearBox)

    if showCh and array.size(bullWickObs) > 0
        for i = array.size(bullWickObs) - 1 to 0
            box bullWickBox = array.get(bullWickObs, i)
            if close < box.get_bottom(bullWickBox)
                removeTrackedBoxAt(bullWickObs, bullWickObStars, bullWickStarDepths, i)
            else
                box.set_right(bullWickBox, time)
                updateBullishStarForBox(bullWickObStars, bullWickStarDepths, i, bullWickBox)

    if showCh and array.size(bearWickObs) > 0
        for i = array.size(bearWickObs) - 1 to 0
            box bearWickBox = array.get(bearWickObs, i)
            if close > box.get_top(bearWickBox)
                removeTrackedBoxAt(bearWickObs, bearWickObStars, bearWickStarDepths, i)
            else
                box.set_right(bearWickBox, time)
                updateBearishStarForBox(bearWickObStars, bearWickStarDepths, i, bearWickBox)
````

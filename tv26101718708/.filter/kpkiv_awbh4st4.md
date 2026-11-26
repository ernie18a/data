# KPK_IV

- url: https://www.tradingview.com/script/AwBh4st4-KPK-IV/
- type: indicator
- pine_id: PUB;abbbafa966864fdcbdaf163f6271cf3f
- version: 1.0

## Description

Intrinsic value calculators for Nifty 50 stocks, such as those on Alpha Spread, Equitymaster, or Screener.in, estimate a stock's true worth using DCF (Discounted Cash Flow) or earnings-based models to determine if it is overvalued or undervalued, usually requiring a 20-30% margin of safety.

## Source Code

````pine
//@version=6
indicator("KPK_IV", overlay=true)


// ----- Inputs -----
strikePrice = input.int(23200, "Strike Price")
optionType = input.string("Call", "Option Type", options=["Call","Put"])

spotHigh = input.float(23500, "Spot High")
spotLow  = input.float(23400, "Spot Low")

stepValue = input.int(50, "Step Size (25/30/50/100/200)")
multiplier = input.int(20, "Multiplier")

showTradePopup = input.bool(true, "Show Entry")
showSLHit = input.bool(true, "Enable SL Hit")
showTargetHit = input.bool(true, "Enable Target Hit")

showLastTrades = input.int(1, "Show Last Entry Levels", minval=1, maxval=20)

showITMDashboard = input.bool(true, "ITM Dashboard")

// ----- Trade Variables -----
var float activeSL = na
var float activeTarget = na
var bool tradeActive = false

// ----- Label Arrays -----
var label[] entryLabels = array.new_label()
var label[] slLabels = array.new_label()
var label[] targetLabels = array.new_label()

// ----- Intrinsic Calculation -----
callIntrinsic = spotHigh - strikePrice
putIntrinsic  = strikePrice - spotLow

intrinsic = optionType == "Call" ? callIntrinsic : putIntrinsic
intrinsic := intrinsic < 0 ? 0 : intrinsic

// ----- Extra Levels -----
level1 = multiplier >= 1 ? intrinsic + stepValue * 1 : na
level2 = multiplier >= 2 ? intrinsic + stepValue * 2 : na
level3 = multiplier >= 3 ? intrinsic + stepValue * 3 : na
level4 = multiplier >= 4 ? intrinsic + stepValue * 4 : na
level5 = multiplier >= 5 ? intrinsic + stepValue * 5 : na
level6 = multiplier >= 6 ? intrinsic + stepValue * 6 : na
level7 = multiplier >= 7 ? intrinsic + stepValue * 7 : na


level001 = (level1 + intrinsic)/2
level002 = (level2 + level1)/2
level003 = (level3 + level2)/2
level004 = (level4 + level3)/2
level005 = (level5 + level4)/2
level006 = (level6 + level5)/2
level007 = (level7+ level6)/2


level01 = multiplier >= 1 ? intrinsic - stepValue * 1 : na
level02 = multiplier >= 2 ? intrinsic - stepValue * 2 : na
level03 = multiplier >= 3 ? intrinsic - stepValue * 3 : na
level04 = multiplier >= 4 ? intrinsic - stepValue * 4 : na
level05 = multiplier >= 5 ? intrinsic - stepValue * 5 : na
level06 = multiplier >= 6 ? intrinsic - stepValue * 6 : na
level07 = multiplier >= 7 ? intrinsic - stepValue * 7 : na


level0001 = (intrinsic + level01)/2
level0002 = (level01 + level02)/2
level0003 = (level02 + level03)/2
level0004 = (level03 + level04)/2
level0005 = (level04 + level05)/2
level0006 = (level05 + level06)/2
level0007 = (level06+ level07)/2


float breakLevel = na
float targetLevel = na

if ta.crossover(close, level1)
    breakLevel := level1
    targetLevel := level2
else if ta.crossover(close, level2)
    breakLevel := level2
    targetLevel := level3
else if ta.crossover(close, level3)
    breakLevel := level3
    targetLevel := level4
else if ta.crossover(close, level4)
    breakLevel := level4
    targetLevel := level5
else if ta.crossover(close, level5)
    breakLevel := level5
    targetLevel := level6
else if ta.crossover(close, level6)
    breakLevel := level6
    targetLevel := level7


// ----- ENTRY -----
if showTradePopup and not na(breakLevel) and not na(targetLevel)

    entryPrice = close
    slPrice = low[1]

    activeSL := slPrice
    activeTarget := targetLevel
    tradeActive := true

    txt = "Entry : " + str.tostring(entryPrice) + "\nSL : " + str.tostring(slPrice) + "\nTarget : " + str.tostring(activeTarget)

    entryLabel = label.new(bar_index, low, txt, style=label.style_label_up, color=color.green, textcolor=color.white)

    array.push(entryLabels, entryLabel)

    if array.size(entryLabels) > showLastTrades
        label.delete(array.shift(entryLabels))

// ----- TARGET HIT -----
if showTargetHit and tradeActive and not na(activeTarget)

    if high >= activeTarget

        targetLabel = label.new(bar_index, high, "TARGET HIT 🎯", style=label.style_label_down, color=color.purple, textcolor=color.white)

        array.push(targetLabels, targetLabel)

        if array.size(targetLabels) > showLastTrades
            label.delete(array.shift(targetLabels))

        tradeActive := false
        activeTarget := na
        activeSL := na

// ----- SL HIT -----
if showSLHit and tradeActive and not na(activeSL)

    if close <= activeSL

        slLabel = label.new(bar_index, low, "SL HIT ❌", style=label.style_label_upper_right, color=color.red, textcolor=color.white)

        array.push(slLabels, slLabel)

        if array.size(slLabels) > showLastTrades
            label.delete(array.shift(slLabels))

        tradeActive := false
        activeSL := na
        activeTarget := na

// ----- Plots -----
plot(intrinsic, "Intrinsic", color=color.green, linewidth=3)
plot(level1, "R1", color=color.orange)
plot(level2, "R2", color=color.red)
plot(level3, "R3", color=color.blue)
plot(level4, "R4", color=color.purple)
plot(level5, "R5", color=color.rgb(192, 206, 248))
plot(level6, "R6", color=color.aqua)
plot(level7, "R7", color=color.teal)


plot(level01, "S1", color=color.orange)
plot(level02, "S2", color=color.red)
plot(level03, "S3", color=color.blue)
plot(level04, "S4", color=color.purple)
plot(level05, "S5", color=color.rgb(192, 206, 248))
plot(level06, "S6", color=color.aqua)
plot(level07, "S7", color=color.teal)


// ----- ITM Strike Calculation (100 strikes only) -----
itmCallStrike = math.floor((spotHigh - 100) / 100) * 100
itmPutStrike  = math.floor((spotLow + 100) / 100) * 100

// ----- Dashboard -----
var table dashboard = table.new(position.top_right, 1, 3, border_width=1)

if showITMDashboard and barstate.islast

    table.cell(dashboard, 0, 0, "ITM Dashboard", bgcolor=color.blue, text_color=color.white)

    callText = str.tostring(itmCallStrike) + " CALL ITM"
    putText  = str.tostring(itmPutStrike) + " PUT ITM"

    table.cell(dashboard, 0, 1, callText, bgcolor=color.green, text_color=color.white)
    table.cell(dashboard, 0, 2, putText, bgcolor=color.red, text_color=color.white)

// Detect first candle of the day
isNewDay = ta.change(time("D"))

// Store opening candle values
var float oHigh = na
var float oLow  = na
var float oClose = na
var float oOpen = na

if bool (isNewDay)
    oHigh  := high
    oLow   := low
    oClose := close
    oOpen  := open

// === Pivot Structure ===
pivotLen = input.int(3, "Pivot Strength", minval=1, maxval=10)
pH = ta.pivothigh(high, pivotLen, pivotLen)
pL = ta.pivotlow(low, pivotLen, pivotLen)

var float lastHigh = na
var float lastLow = na
if not na(pH)
    lastHigh := pH
if not na(pL)
    lastLow := pL

length = input.int(7, "How many previous days?", minval=1, maxval=75)
       
ph = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
pl = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)
pc = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
po = request.security(syminfo.tickerid, "D", open[1], lookahead=barmerge.lookahead_on)
PH = request.security(syminfo.tickerid, "D", high,  lookahead=barmerge.lookahead_on)
PL = request.security(syminfo.tickerid, "D", low,   lookahead=barmerge.lookahead_on)

avgHigh  = ta.sma(ph, length)
avgLow   = ta.sma(pl, length)
avgClose = ta.sma(pc, length)
avgOpen = ta.sma(po, length)

avgPivot = (avgClose + avgLow + avgHigh)  / 3
plot(avgPivot, "Pivot", color=color.rgb(247, 185, 100), linewidth=2)
plot(ph, "high", color=color.rgb(250, 3, 3), linewidth=1)
plot(pl, "low", color=color.rgb(138, 252, 8), linewidth=1)
plot(pc, "close", color=color.rgb(246, 248, 244), linewidth=1)

// Typical price of opening candle
dayHLC = (oHigh + oLow + oClose) / 3

avgIVO=(oOpen+pc)/2
avgOpL=(avgIVO+pl)/2
avgOpH=(avgIVO+ph)/2
IR1=avgIVO + 50
IR2=avgIVO + 100
IR3=avgIVO + 200
IR4=avgIVO + 300
IR5=avgIVO + 400
IR6=avgIVO + 500
IR7=avgIVO + 600
IR8=avgIVO + 700
IR9=avgIVO + 800

IS1=avgIVO - 50
IS2=avgIVO - 100
IS3=avgIVO - 200
IS4=avgIVO - 300
IS5=avgIVO - 400
IS6=avgIVO - 500
IS7=avgIVO - 600
IS8=avgIVO - 700
IS9=avgIVO - 800

avgIVC=(oClose+pc)/2
avgPCH=(oHigh + avgIVO)/2

// Plot on Chart
plot(avgPCH, title="PCH", color=color.rgb(247, 134, 4), linewidth=2, style=plot.style_linebr)
plot(avgOpL, title="OpL", color=color.rgb(247, 243, 4), linewidth=2, style=plot.style_linebr)
plot(avgOpH, title="OoH", color=color.rgb(247, 243, 4), linewidth=2, style=plot.style_linebr)
plot(oOpen, title="DOP", color=color.rgb(172, 209, 5), linewidth=2, style=plot.style_linebr)
plot(oClose, title="DOC", color=color.rgb(248, 2, 183), linewidth=2, style=plot.style_linebr)
plot(oLow,title="DOL", color=color.rgb(41, 5, 249), linewidth=2, style=plot.style_linebr)
plot(oHigh, title="DOH", color=color.rgb(41, 5, 249), linewidth=2, style=plot.style_linebr)
plot(avgIVO, title="IVO", color=color.rgb(9, 215, 252), linewidth=2, style=plot.style_linebr)

plot(IR1, title="IR1", color=color.rgb(2, 207, 2), linewidth=1, style=plot.style_linebr)
plot(IR2, title="IR2", color=color.rgb(2, 207, 2), linewidth=1, style=plot.style_linebr)
plot(IR3, title="IR3", color=color.rgb(2, 207, 2), linewidth=1, style=plot.style_linebr)
plot(IR4, title="IR4", color=color.rgb(2, 207, 2), linewidth=1, style=plot.style_linebr)
plot(IR5, title="IR5", color=color.rgb(2, 207, 2), linewidth=1, style=plot.style_linebr)
plot(IR6, title="IR6", color=color.rgb(2, 207, 2), linewidth=1, style=plot.style_linebr)
plot(IR7, title="IR7", color=color.rgb(2, 207, 2), linewidth=1, style=plot.style_linebr)
plot(IR8, title="IR8", color=color.rgb(2, 207, 2), linewidth=1, style=plot.style_linebr)
plot(IR9, title="IR9", color=color.rgb(2, 207, 2), linewidth=1, style=plot.style_linebr)

plot(IS1, title="IS1", color=color.rgb(247, 3, 64), linewidth=1, style=plot.style_linebr)
plot(IS2, title="IS2", color=color.rgb(247, 3, 64), linewidth=1, style=plot.style_linebr)
plot(IS3, title="IS3", color=color.rgb(247, 3, 64), linewidth=1, style=plot.style_linebr)
plot(IS4, title="IS4", color=color.rgb(247, 3, 64), linewidth=1, style=plot.style_linebr)
plot(IS5, title="IS5", color=color.rgb(247, 3, 64), linewidth=1, style=plot.style_linebr)
plot(IS6, title="IS6", color=color.rgb(247, 3, 64), linewidth=1, style=plot.style_linebr)
plot(IS7, title="IS7", color=color.rgb(247, 3, 64), linewidth=1, style=plot.style_linebr)
plot(IS8, title="IS8", color=color.rgb(247, 3, 64), linewidth=1, style=plot.style_linebr)
plot(IS9, title="IS9", color=color.rgb(247, 3, 64), linewidth=1, style=plot.style_linebr)


var UP_COLOR = color.white
var DOWN_COLOR = color.yellow

period = input.int(50, minval=1, title='Period')
factor = input.int(100, minval=0, title='% Avg. Vol.')

highlightColor = (volume >= ta.sma(volume, period) * factor / 100) ? (close >= open ? UP_COLOR : DOWN_COLOR) : #2962ff00

plotcandle(open, high, low, close, title="Volume Highlight",
  color=highlightColor,
  bordercolor=highlightColor,
  wickcolor=highlightColor)
  
// ------------------------------------------
// INPUT GROUPS (for cleaner settings UI)
// ------------------------------------------
grpStrike = "Strike Settings"
grpLine   = "Line Settings"
grpLabel  = "Label Settings"


// ------------------------------------------
// STRIKE SETTINGS
// ------------------------------------------
step       = input.float(50.0, 'Step (points)', minval = 1, step = 50, group = grpStrike)
levelsSide = input.int(10, 'Levels per side', minval = 1, maxval = 150, group = grpStrike)
strikeMode = input.string( 'Strike Price Range', 'Strike Mode', options = ['Strike Price Range', 'Exact Strike Price'], group = grpStrike)

// ------------------------------------------
// LINE SETTINGS
// ------------------------------------------
lineWidth    = input.int(1, 'Line width', minval = 1, maxval = 5, group = grpLine)
lineColor    = input.color(color.new(color.purple, 40), 'Line color', group = grpLine)
lineStyleOpt = input.string('Dotted', 'Line style', options = ['Solid', 'Dashed', 'Dotted'], group = grpLine)
extOpt       = input.string('Both', 'Extend', options = ['Both', 'Right', 'Left', 'None'], group = grpLine)

// ------------------------------------------
// LABEL SETTINGS
// ------------------------------------------
showLabels   = input.bool(true, 'Show labels', group = grpLabel)
barsRight    = input.int(10, 'Labels Distance', minval = 1, group = grpLabel)
labelSizeOpt = input.string('Normal', 'Label size', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = grpLabel)

// NEW: Label style controls
labelTextColor = input.color(color.white, 'Label text color', group = grpLabel)
labelBgColor   = input.color(color.new(color.black, 60), 'Label background color', group = grpLabel)

// ------------------------------------------
// ENUM HELPERS
// ------------------------------------------
f_getExtend(_opt) =>
    _opt == 'Both' ? extend.both : _opt == 'Right' ? extend.right : _opt == 'Left' ? extend.left : extend.none

f_getLineStyle(_opt) =>
    _opt == 'Solid' ? line.style_solid : _opt == 'Dashed' ? line.style_dashed : line.style_dotted

f_getLabelSize(_opt) =>
    _opt == 'Tiny' ? size.tiny :
     _opt == 'Small' ? size.small :
     _opt == 'Large' ? size.large :
     _opt == 'Huge' ? size.huge :
     size.normal

extEnum       = f_getExtend(extOpt)
lineStyleEnum = f_getLineStyle(lineStyleOpt)
labelSizeEnum = f_getLabelSize(labelSizeOpt)

// ------------------------------------------
// CORE MATH
// ------------------------------------------
base = strikeMode == 'Strike Price Range' ? (math.round(close / step) * step + step / 2.0) : (math.round(close / step) * step + step)
total = levelsSide * 2 + 1

// ------------------------------------------
// STORAGE ARRAYS
// ------------------------------------------
var array<line>  lines  = array.new_line()
var array<label> labels = array.new_label()

// ------------------------------------------
// STYLE APPLY (lines)
// ------------------------------------------
f_styleLine(l) =>
    line.set_color(l, lineColor)
    line.set_width(l, lineWidth)
    line.set_extend(l, extEnum)
    line.set_style(l, lineStyleEnum)

// ------------------------------------------
// LABEL HELPERS
// ------------------------------------------
f_hideLabel(lb) =>
    label.set_text(lb, "")
    label.set_y(lb, na)

// Common label properties applied every update so they react to input changes
f_applyLabelCommon(lb, _x) =>
    label.set_x(lb, _x)
    label.set_size(lb, labelSizeEnum)
    label.set_textcolor(lb, labelTextColor)   // NEW
    label.set_color(lb, labelBgColor)         // NEW (background)

// ------------------------------------------
// CLEAR / REBUILD
// ------------------------------------------
f_clearAll() =>
    lnSz = array.size(lines)
    if lnSz > 0
        for i = 0 to lnSz - 1
            l = array.get(lines, i)
            if not na(l)
                line.delete(l)

    lbSz = array.size(labels)
    if lbSz > 0
        for j = 0 to lbSz - 1
            lb = array.get(labels, j)
            if not na(lb)
                label.delete(lb)

    array.clear(lines)
    array.clear(labels)

f_rebuild() =>
    f_clearAll()

    for idx = -levelsSide to levelsSide
        y = base + idx * step

        l = line.new(bar_index - 1, y, bar_index, y)
        f_styleLine(l)
        array.push(lines, l)

        // Create label with defaults; dynamic colors are applied on update.
        lb = label.new(
            na, na, "",
            style     = label.style_label_center,
            textcolor = labelTextColor,  // NEW
            color     = labelBgColor,    // NEW
            size      = labelSizeEnum)
        array.push(labels, lb)


// ------------------------------------------
// INIT
// ------------------------------------------
if barstate.isfirst or array.size(lines) != total or array.size(labels) != total
    f_rebuild()

// ------------------------------------------
// UPDATE (LAST BAR ONLY)
// ------------------------------------------
if barstate.islast
    lnSz = array.size(lines)
    lbSz = array.size(labels)

    if lnSz != total or lbSz != total
        f_rebuild()
    else
        lastIdx = last_bar_index
        futureX = lastIdx + barsRight

        for i = 0 to total - 1
            idx = i - levelsSide
            y   = base + idx * step

            // Update line
            l = array.get(lines, i)
            line.set_xy1(l, bar_index - 1, y)
            line.set_xy2(l, bar_index,     y)
            f_styleLine(l)

            // Update label
            lb = array.get(labels, i)

            if not showLabels
                f_hideLabel(lb)
            else
                f_applyLabelCommon(lb, futureX)

                if strikeMode == 'Strike Price Range'
                    // Label centered BETWEEN this line and next line
                    if i < total - 1
                        nextIdx = (i + 1) - levelsSide
                        nextY   = base + nextIdx * step
                        midY    = (y + nextY) / 2.0

                        label.set_y(lb, midY)
                        label.set_text(lb, str.tostring(midY))
                    else
                        // No next line => hide last label
                        f_hideLabel(lb)
                else
                    // Exact strike: label ON the line
                    label.set_y(lb, y)
                    label.set_text(lb, str.tostring(y))

// Method 1: Center of the entire candle (High to Low)
centerPoint = (open + close) / 2 
// Plotting the point
plot(centerPoint, title="CP", style=plot.style_cross, linewidth=2, color=color.rgb(255, 255, 255))


import TradingView/ta/6

//----------settings----------//

lookback    = input.int(7, 'Lookback Days')

extLev      = input.int(200, 'Extreme', inline = '1')

extCol      = input.color(color.red, '', inline = '1')

highLev     = input.int(110, 'High', inline = '2')

highCol     = input.color(color.rgb(7, 245, 27), '', inline = '2')

avgLev      = input.int(85, 'Average', inline = '3')

avgCol      = input.color(color.rgb(30, 5, 250), '', inline = '3')

lightLev    = input.int(60, 'Light', inline = '4')

lightCol    = input.color(color.yellow, '', inline = '4')

dryCol      = input.color(color.gray, 'Dry')

//----------data----------//

[currentVolume, pastVolume, ratio] = ta.relativeVolume(lookback, 'D', true)

ratio := math.round(ratio*100,0)

//----------conditions----------//

ratioCol     = ratio >= extLev ? extCol : ratio >= highLev ? highCol : ratio >= avgLev ? avgCol : ratio >= lightLev ? lightCol : dryCol

ratioWickCol = ratio >= ratio[1] ? color.green : color.red

//----------plots----------//

plotcandle(open,high,low,close,color=ratioCol,wickcolor=ratioWickCol, bordercolor=ratioCol)
````

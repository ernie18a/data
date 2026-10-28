# BB + 9EMA + Hammer + FVG w/ Gann Box

- url: https://www.tradingview.com/script/aybxH6L2-BB-9EMA-Hammer-FVG-w-Gann-Box/
- type: indicator
- pine_id: PUB;3a2435cfd8a34216b1bdf515c4dc4226
- version: 2.0

## Description

This indicator merges four powerful tools into one: Bollinger Bands (34-period), a 9 EMA with optional smoothing, Hammer & Shooting Star pattern detection, and Fair Value Gaps with Gann Box levels built in. No more switching between indicators — everything you need on one chart.

## Source Code

````pine
//@version=6
indicator(
     title="BB + EMA + Hammer + FVG + Premarket H/L + The Strat",
     shorttitle="BB EMA FVG Strat",
     overlay=true,
     max_bars_back=500,
     max_lines_count=500,
     max_boxes_count=100
)

// ─────────────────────────────
// 🔵 Bollinger Bands (20/2)
// ─────────────────────────────
bb_src    = input.source(close, "BB Source")
bb_length = input.int(20, minval=1, title="BB Length")
bb_mult   = input.float(2.0, minval=0.001, maxval=50, title="BB Multiplier")

bb_basis = ta.sma(bb_src, bb_length)
bb_dev   = ta.stdev(bb_src, bb_length)
bb_dev2  = bb_mult * bb_dev

bb_upper1 = bb_basis + bb_dev
bb_lower1 = bb_basis - bb_dev
bb_upper2 = bb_basis + bb_dev2
bb_lower2 = bb_basis - bb_dev2

bb_colorBasis = bb_src >= bb_basis ? color.blue : color.orange

pBasis = plot(bb_basis, linewidth=2, color=bb_colorBasis, title="BB Basis")
pU1    = plot(bb_upper1, color=color.blue, style=plot.style_circles, title="BB Upper 1")
pU2    = plot(bb_upper2, color=color.blue, title="BB Upper 2")
pL1    = plot(bb_lower1, color=color.orange, style=plot.style_circles, title="BB Lower 1")
pL2    = plot(bb_lower2, color=color.orange, title="BB Lower 2")

fill(pBasis, pU2, color=color.new(color.blue, 80))
fill(pU1, pU2, color=color.new(color.blue, 80))
fill(pBasis, pL2, color=color.new(color.orange, 80))
fill(pL1, pL2, color=color.new(color.orange, 80))

// ─────────────────────────────
// 🟡 EMA
// ─────────────────────────────
ema_len    = input.int(9, minval=1, title="EMA Length")
ema_src    = input.source(close, title="EMA Source")
ema_offset = input.int(0, title="EMA Offset", minval=-500, maxval=500)

ema_out = ta.ema(ema_src, ema_len)
plot(ema_out, title="EMA", color=color.blue, offset=ema_offset)

// ─────────────────────────────
// 🟠 EMA Smoothing + Optional BB
// ─────────────────────────────
GRP = "EMA Smoothing Options"

maTypeInput = input.string("None", "Smoothing Type",
     options=["None","SMA","SMA + Bollinger Bands","EMA","SMMA (RMA)","WMA","VWMA"],
     group=GRP)
maLengthInput = input.int(14, "Smoothing Length", group=GRP)
bbMultInput   = input.float(2.0, "BB StdDev", minval=0.001, maxval=50, step=0.5, group=GRP)

isBB     = maTypeInput == "SMA + Bollinger Bands"
enableMA = maTypeInput != "None"

ma(source, length, type) =>
    switch type
        "SMA"                   => ta.sma(source, length)
        "SMA + Bollinger Bands" => ta.sma(source, length)
        "EMA"                   => ta.ema(source, length)
        "SMMA (RMA)"            => ta.rma(source, length)
        "WMA"                   => ta.wma(source, length)
        "VWMA"                  => ta.vwma(source, length)

smoothingMA   = enableMA ? ma(ema_out, maLengthInput, maTypeInput) : na
smoothingStDv = isBB ? ta.stdev(ema_out, maLengthInput) * bbMultInput : na

plot(smoothingMA, title="EMA Smoothed MA", color=color.yellow,
     display=enableMA ? display.all : display.none)

bbUpperBand = plot(smoothingMA + smoothingStDv, title="EMA BB Upper", color=color.green,
     display=isBB ? display.all : display.none)
bbLowerBand = plot(smoothingMA - smoothingStDv, title="EMA BB Lower", color=color.green,
     display=isBB ? display.all : display.none)
fill(bbUpperBand, bbLowerBand, color=isBB ? color.new(color.green, 90) : na, title="EMA BB Fill")

// ─────────────────────────────
// 🔴 Hammer & Shooting Star
// ─────────────────────────────
FIB_LEVEL  = input.float(defval=0.382, title="Fibonacci Level", options=[0.236, 0.382, 0.5])
confirm    = input.bool(false, "Confirm by next candle")
showLabels = input.bool(true, "Show labels on chart")

isGreen    = close > open
isRed      = close < open
candleSize = math.abs(high - low)

isHammer = high - FIB_LEVEL * candleSize < math.min(open, close)
isShoot  = low  + FIB_LEVEL * candleSize > math.max(open, close)

isConfirmedHammer = confirm ? isHammer[1] and isGreen : isHammer
isConfirmedShoot  = confirm ? isShoot[1]  and isRed   : isShoot

plotshape(isConfirmedHammer ? low : na,
     title="Hammer", text="Hammer", style=shape.arrowup,
     location=location.belowbar, color=color.green, textcolor=color.green,
     offset=confirm ? -1 : 0, display=showLabels ? display.all : display.none)

plotshape(isConfirmedShoot ? high : na,
     title="Shooting Star", text="Shooting", style=shape.arrowdown,
     location=location.abovebar, color=color.red, textcolor=color.red,
     offset=confirm ? -1 : 0, display=showLabels ? display.all : display.none)

longEntry  = isConfirmedHammer
shortEntry = isConfirmedShoot

alertcondition(longEntry,  "Hammer Candle Alert",        "Hammer candle on {{ticker}} at {{close}}")
alertcondition(shortEntry, "Shooting Star Candle Alert", "Shooting Star candle on {{ticker}} at {{close}}")

connector = longEntry ? 2 : shortEntry ? -2 : 0
plot(connector, title="Connector", display=display.status_line, color=color.gray)

// ─────────────────────────────
// 🌅 Premarket High / Low
// ─────────────────────────────
var string pmGroup = "-------------------Premarket High / Low-------------------"
ending_hour   = input.int(defval=9,      title="Ending Hour",          group=pmGroup)
ending_minute = input.int(defval=30,     title="Ending Minute",        group=pmGroup)
atr_factor    = input.float(defval=1.0,  title="ATR Factor",           group=pmGroup)
aftermarket   = input.bool(defval=false, title="Include Aftermarket",  group=pmGroup)

pm_session = aftermarket ? "1600-0000" : "0000-1530"
t = time("1440", pm_session)
is_first = na(t[1]) and not na(t) or (not na(t[1]) and not na(t) and t[1] < t)

is_premarket(h, m) =>
    h < ending_hour or h >= 16 or (h == ending_hour and m < ending_minute)

var float day_high = na
var float day_low  = na

if is_first and barstate.isnew and is_premarket(hour, minute)
    day_high := high
    day_low  := low
else
    day_high := day_high[1]
    day_low  := day_low[1]

if high > day_high and is_premarket(hour, minute)
    day_high := high
if low < day_low and is_premarket(hour, minute)
    day_low := low

dailyATR = request.security(syminfo.tickerid, "D", ta.atr(14))

plot(day_high,                         title="PM High",       style=plot.style_circles, trackprice=true, offset=-9999, color=color.yellow, linewidth=1)
plot(day_high + dailyATR * atr_factor, title="PM High + ATR", style=plot.style_circles, trackprice=true, offset=-9999, color=color.white,  linewidth=3)
plot(day_low,                          title="PM Low",        style=plot.style_circles, trackprice=true, offset=-9999, color=color.yellow, linewidth=1)
plot(day_low  - dailyATR * atr_factor, title="PM Low - ATR",  style=plot.style_circles, trackprice=true, offset=-9999, color=color.white,  linewidth=3)

// ─────────────────────────────
// 📊 The Strat — Candle Type
// ─────────────────────────────
var string grpDisp = "-------------------The Strat Display-------------------"
showCredit      = input.bool(false, "Show credit marker",   group=grpDisp)
showTypeLabels  = input.bool(true,  "Show 1/2/3 numbers",   group=grpDisp)
showFailedMarks = input.bool(true,  "Show F2U/F2D markers", group=grpDisp)

var string grpNum = "Number style (1/2/3)"
numSizeSel = input.string(size.small, "Number size", options=[size.tiny, size.small, size.normal], group=grpNum)
numCol1 = input.color(#0080FF, "Number color for 1", group=grpNum)
numCol2 = input.color(#0080FF, "Number color for 2", group=grpNum)
numCol3 = input.color(#0080FF, "Number color for 3", group=grpNum)

var string grpF2 = "Failed 2 marker style"
f2SizeSel = input.string(size.small, "F2 marker size", options=[size.tiny, size.small, size.normal], group=grpF2)
f2ColU   = input.color(color.maroon, "F2U marker color", group=grpF2)
f2ColD   = input.color(color.green,  "F2D marker color", group=grpF2)
f2TextU  = input.color(color.white,  "F2U text color",   group=grpF2)
f2TextD  = input.color(color.white,  "F2D text color",   group=grpF2)

var string grpC = "Candle colors"
colorMode = input.string("Failed 2 only", "Color candles", options=["Off","Failed 2 only","All types"], group=grpC)
col1   = input.color(#0080FF,      "Type 1 (Inside)",     group=grpC)
col2U  = input.color(color.lime,   "Type 2 Up (2U)",      group=grpC)
col2D  = input.color(color.red,    "Type 2 Down (2D)",    group=grpC)
col3   = input.color(color.orange, "Type 3 (Outside)",    group=grpC)
colF2U = input.color(color.maroon, "Failed 2 Up (F2U)",   group=grpC)
colF2D = input.color(color.green,  "Failed 2 Down (F2D)", group=grpC)

// Candle type logic
type1  = high <= high[1] and low >= low[1]
type3  = high > high[1]  and low < low[1]
type2  = (high > high[1] or low < low[1]) and not type3
type2U = type2 and high > high[1]
type2D = type2 and low  < low[1]

// Failed 2 logic (prev close rule)
failed2U = type2U and close < close[1]
failed2D = type2D and close > close[1]

// Candle coloring
colAll =
     failed2U ? colF2U :
     failed2D ? colF2D :
     type3    ? col3   :
     type1    ? col1   :
     type2U   ? col2U  :
     type2D   ? col2D  : na

colFailedOnly =
     failed2U ? colF2U :
     failed2D ? colF2D : na

barcolor(
     colorMode == "Off"           ? na :
     colorMode == "Failed 2 only" ? colFailedOnly :
     colAll)

plotshape(
     showCredit and barstate.islast,
     title="Credit", style=shape.cross, location=location.bottom,
     color=#0080FF, text="Crinklebine.com", textcolor=#0080FF, size=size.tiny)

// Size workaround — tiny/small/normal only
numTiny   = numSizeSel == size.tiny
numSmall  = numSizeSel == size.small
numNormal = numSizeSel == size.normal

f2Tiny   = f2SizeSel == size.tiny
f2Small  = f2SizeSel == size.small
f2Normal = f2SizeSel == size.normal

cond1 = showTypeLabels and type1
cond2 = showTypeLabels and type2
cond3 = showTypeLabels and type3

plotchar(cond1 and numTiny,   title="1 tiny",   char="1", location=location.belowbar, color=numCol1, size=size.tiny)
plotchar(cond1 and numSmall,  title="1 small",  char="1", location=location.belowbar, color=numCol1, size=size.small)
plotchar(cond1 and numNormal, title="1 normal", char="1", location=location.belowbar, color=numCol1, size=size.normal)

plotchar(cond2 and numTiny,   title="2 tiny",   char="2", location=location.belowbar, color=numCol2, size=size.tiny)
plotchar(cond2 and numSmall,  title="2 small",  char="2", location=location.belowbar, color=numCol2, size=size.small)
plotchar(cond2 and numNormal, title="2 normal", char="2", location=location.belowbar, color=numCol2, size=size.normal)

plotchar(cond3 and numTiny,   title="3 tiny",   char="3", location=location.belowbar, color=numCol3, size=size.tiny)
plotchar(cond3 and numSmall,  title="3 small",  char="3", location=location.belowbar, color=numCol3, size=size.small)
plotchar(cond3 and numNormal, title="3 normal", char="3", location=location.belowbar, color=numCol3, size=size.normal)

f2u = showFailedMarks and failed2U
f2d = showFailedMarks and failed2D

plotshape(f2u and f2Tiny,   title="F2U tiny",   style=shape.triangledown, location=location.abovebar, size=size.tiny,   color=f2ColU, text="F2U", textcolor=f2TextU)
plotshape(f2u and f2Small,  title="F2U small",  style=shape.triangledown, location=location.abovebar, size=size.small,  color=f2ColU, text="F2U", textcolor=f2TextU)
plotshape(f2u and f2Normal, title="F2U normal", style=shape.triangledown, location=location.abovebar, size=size.normal, color=f2ColU, text="F2U", textcolor=f2TextU)

plotshape(f2d and f2Tiny,   title="F2D tiny",   style=shape.triangleup, location=location.abovebar, size=size.tiny,   color=f2ColD, text="F2D", textcolor=f2TextD)
plotshape(f2d and f2Small,  title="F2D small",  style=shape.triangleup, location=location.abovebar, size=size.small,  color=f2ColD, text="F2D", textcolor=f2TextD)
plotshape(f2d and f2Normal, title="F2D normal", style=shape.triangleup, location=location.abovebar, size=size.normal, color=f2ColD, text="F2D", textcolor=f2TextD)

// ─────────────────────────────
// 📦 FVG w/ Gann Box
// ─────────────────────────────
var box[]   boxes           = array.new_box()
var line[]  gannLines       = array.new_line()
var label[] gannPriceLabels = array.new_label()

var string fvgTitle = "----------------------Fair Value Gap----------------------"
max_fvg_boxes = input.int(10, "Max visible FVG boxes", minval=1, group=fvgTitle)
minGapSize    = input.float(0.01, "Minimum Gap Size", group=fvgTitle)

var string fvgStyle = "--------------------Fair Value Gap Style--------------------"
bullishFVGColor = input.color(color.new(color.green, 70), "Bullish FVG Color", group=fvgStyle)
bearishFVGColor = input.color(color.new(color.red, 70),   "Bearish FVG Color", group=fvgStyle)
fvgLabel        = input.string("", "FVG Text Label", group=fvgStyle)
textColor       = input.color(color.new(color.black, 10), "Text Label Color", group=fvgStyle)
sizeOption      = input.string(title="Text Label Size", options=["Auto","Huge","Large","Normal","Small","Tiny"], defval="Small", group=fvgStyle)
labelSize       = sizeOption == "Huge" ? size.huge : sizeOption == "Large" ? size.large : sizeOption == "Small" ? size.small : sizeOption == "Tiny" ? size.tiny : sizeOption == "Auto" ? size.auto : size.normal

var string gannTitle = "----------------------Gann Box Levels----------------------"
showGannBox         = input.bool(true,  "Show Gann Box", group=gannTitle)
showGannLevelPrices = input.bool(false, "Show Gann Box Level 2 and 3 Prices", group=gannTitle)

var string gannBoxStyle = "-------------------Gann Box Levels Style-------------------"
fibLevel1Color = input.color(color.blue,   "Level 1 Color", group=gannBoxStyle)
fibLevel2Color = input.color(color.yellow, "Level 2 Color", inline="Gann Second Level", group=gannBoxStyle)
fibLevel2      = input.float(0.375, "",    inline="Gann Second Level", group=gannBoxStyle)
fibLevel3Color = input.color(color.yellow, "Level 3 Color", inline="Gann Third Level", group=gannBoxStyle)
fibLevel3      = input.float(0.62, "",     inline="Gann Third Level", group=gannBoxStyle)
fibLevel4Color = input.color(color.blue,   "Level 4 Color", group=gannBoxStyle)

var string eqh_eql_title = "-------------------------EQH and EQL-------------------------"
var enableEQHEQL = input.bool(false, "Enable EQH and EQL", group=eqh_eql_title)
EQHLineColor     = input.color(color.new(color.green, 0), "EQH Line Color", group=eqh_eql_title)
EQLLineColor     = input.color(color.new(color.red, 0),   "EQL Line Color", group=eqh_eql_title)
EQLineWidth      = input.int(1, "Width of the line", group=eqh_eql_title)

var string htfFVG      = "----------------------------HTF FVG---------------------------"
var string htfFVGStyle = "------------------------HTF FVG STYLE------------------------"
time_frame_1_min_enabled   = input.bool(false, "Enable 1 minute FVG", group=htfFVG)
HTFMinGapSize              = input.float(0.01, "HTF Minimum Gap Size", group=htfFVG)
var HTFExtendCandlesLength = input.int(0, "How many candles to extend", group=htfFVGStyle, tooltip="Will only work on Timeframe lower than a minute")
BullColor            = input.color(defval=color.new(color.green, 90), title="HTF Bullish FVG Color", group=htfFVGStyle)
BearColor            = input.color(defval=color.new(color.red, 90),   title="HTF Bearish FVG Color", group=htfFVGStyle)
isHTFFVGLabelEnabled = input.bool(defval=false, title="Enable HTF FVG Text Label", group=htfFVGStyle)
HTFLabelText         = input.string("M1 FVG", "HTF Text Label", group=htfFVGStyle)
LabelColor           = input.color(defval=color.gray, title="HTF Text Label Color", group=htfFVGStyle)
LabelSize            = input.string(defval=size.tiny, title="HTF Text Label Size", options=[size.huge, size.large, size.small, size.tiny, size.auto, size.normal], group=htfFVGStyle)

var string fractalsTitle = "---------------------------Fractals---------------------------"
var enableFractals = input.bool(false, "Enable Fractals", group=fractalsTitle)

Transparent_Color = color.new(color.white, 100)

var string General_Settings_group = "---------------------Market Structure---------------------"
var enableTrendLinePlotting = input.bool(false, "Enable Trend Line (HH, HL, LH, LL)", group=General_Settings_group)
Show_Bos         = input.bool(defval=false, title="Show BOS", group=General_Settings_group)
Show_Mss         = input.bool(defval=false, title="Show MSS", group=General_Settings_group)
Use_High_Low     = input.bool(defval=false, title="Use High/Low for Bos & Mss", group=General_Settings_group)
Enable_Bos_Alert = input.bool(defval=false, title="Enable BOS Alert", group=General_Settings_group)
var bool BosSignal = false
Enable_Mss_Alert = input.bool(defval=false, title="Enable MSS Alert", group=General_Settings_group)
var bool MssSignal = false
var int CurrentBreakoutType = 0

var string Market_Structure_Style_Group = "------------------Market Structure Style-----------------"
Swing_Length = input.int(defval=7,  title="Swing Length", minval=1, group=Market_Structure_Style_Group)
Line_Type    = input.string(defval="Solid", title="Border Type", options=["Solid","Dashed","Dotted"], group=Market_Structure_Style_Group)
Line_Width   = input.int(defval=2,  title="Line Width", group=Market_Structure_Style_Group)
Text_Size    = input.string(defval="Small", title="Text Size", options=["Normal","Tiny","Small","Large","Huge","Auto"], group=Market_Structure_Style_Group)
Bul_Bos_Col  = input.color(defval=color.green, title="Bullish Bos/Mss Color", group=Market_Structure_Style_Group, inline="TF 1 Color")
Bear_Bos_Col = input.color(defval=color.red,   title="Bearish Bos/Mss Color", group=Market_Structure_Style_Group, inline="TF 1 Color")
Bul_MS_Col   = input.color(defval=color.white, title="Bullish Text MS Color", group=Market_Structure_Style_Group, inline="TF 1 Ms Color")
Bear_MS_Col  = input.color(defval=color.white, title="Bearish Text MS Color", group=Market_Structure_Style_Group, inline="TF 1 Ms Color")

drawGannBox(highPoint, lowPoint, barIndex, length) =>
    gannLevel1 = highPoint
    gannLevel2 = highPoint - (highPoint - lowPoint) * fibLevel2
    gannLevel3 = highPoint - (highPoint - lowPoint) * fibLevel3
    gannLevel4 = lowPoint
    temp1 = line.new(x1=barIndex, y1=gannLevel1, x2=barIndex + length, y2=gannLevel1, width=1, color=fibLevel4Color)
    temp2 = line.new(x1=barIndex, y1=gannLevel2, x2=barIndex + length, y2=gannLevel2, width=1, color=fibLevel3Color)
    temp3 = line.new(x1=barIndex, y1=gannLevel3, x2=barIndex + length, y2=gannLevel3, width=1, color=fibLevel2Color)
    temp4 = line.new(x1=barIndex, y1=gannLevel4, x2=barIndex + length, y2=gannLevel4, width=1, color=fibLevel1Color)
    if showGannLevelPrices
        while array.size(gannPriceLabels) > 2
            label.delete(array.shift(gannPriceLabels))
        array.push(gannPriceLabels, label.new(x=barIndex + length, y=gannLevel2, text=str.tostring(gannLevel2, "#.##"), color=color(fibLevel2Color), textcolor=fibLevel2Color, style=label.style_none))
        array.push(gannPriceLabels, label.new(x=barIndex + length, y=gannLevel3, text=str.tostring(gannLevel3, "#.##"), color=color(fibLevel3Color), textcolor=fibLevel3Color, style=label.style_none))
    array.push(gannLines, temp1)
    array.push(gannLines, temp2)
    array.push(gannLines, temp3)
    array.push(gannLines, temp4)

getGannHighLowBullish() => [high[2], low[0]]
getGannHighLowBearish() => [high,    low[2]]

createBullishFVG(highLevel, lowLevel, barIndex) =>
    boxId = box.new(bar_index - 2, high[2], bar_index + 2, low,
         border_color=color.new(color.black, 100), bgcolor=bullishFVGColor,
         text=fvgLabel, text_color=textColor, text_size=labelSize, text_halign=text.align_right)
    array.push(boxes, boxId)
    if showGannBox
        [gannHigh, gannLow] = getGannHighLowBullish()
        drawGannBox(gannHigh, gannLow, bar_index - 2, 4)
    if array.size(boxes) > max_fvg_boxes
        box.delete(array.shift(boxes))
        if showGannBox
            for i = 0 to 3
                line.delete(array.shift(gannLines))

createBearishFVG(highLevel, lowLevel, barIndex) =>
    boxId = box.new(bar_index - 2, low[2], bar_index + 2, high,
         border_color=color.new(color.black, 100), bgcolor=bearishFVGColor,
         text=fvgLabel, text_color=textColor, text_size=labelSize, text_halign=text.align_right)
    array.push(boxes, boxId)
    if showGannBox
        [gannHigh, gannLow] = getGannHighLowBearish()
        drawGannBox(gannHigh, gannLow, bar_index - 2, 4)
    if array.size(boxes) > max_fvg_boxes
        box.delete(array.shift(boxes))
        if showGannBox
            for i = 0 to 3
                line.delete(array.shift(gannLines))

FVGGapSizeBullish = low >= high[2] ? low - high[2] : 0
FVGGapSizeBearish = low[2] >= high ? low[2] - high : 0
directionalTrend  = FVGGapSizeBullish > minGapSize ? 1 : FVGGapSizeBearish > minGapSize ? -1 : 0

if directionalTrend > 0
    createBullishFVG(high[2], low, bar_index[2])
if directionalTrend < 0
    createBearishFVG(high[2], low, bar_index[2])

var box[] htfFVGBox = array.new_box()

create_box(_time, _top, _bottom, trendIndicator, labelText) =>
    _col  = trendIndicator > 0 ? BullColor : BearColor
    _text = isHTFFVGLabelEnabled ? labelText : na
    if trendIndicator > 0 or trendIndicator < 0
        array.push(htfFVGBox, box.new(left=_time, top=_top,
             right=time + (timeframe.multiplier * (1000 * HTFExtendCandlesLength)),
             extend=extend.none, bottom=_bottom, bgcolor=_col, border_color=na,
             text=_text, text_valign=text.align_top, text_halign=text.align_right,
             text_size=LabelSize, text_color=LabelColor, xloc=xloc.bar_time))

find_box(target_time) =>
    var int   trendIndicator = na
    var float _top           = na
    var float _bottom        = na
    var int   _time          = na
    if barstate.isconfirmed
        gapSizeBullish  = low >= high[2] ? low - high[2] : 0
        gapSizeBearish  = low[2] >= high ? low[2] - high : 0
        trendIndicator := gapSizeBullish > HTFMinGapSize ? 1 : gapSizeBearish > HTFMinGapSize ? -1 : 0
        _top           := trendIndicator > 0 ? low     : trendIndicator < 0 ? low[2] : 0
        _bottom        := trendIndicator > 0 ? high[2] : trendIndicator < 0 ? high   : 0
        _time          := time - target_time * 60000 * 2
    [_time, _top, _bottom, trendIndicator]

[_time1, _top1, _bottom1, trendIndicator] = request.security(syminfo.tickerid, "1", find_box(1))
if time_frame_1_min_enabled and timeframe.change("1")
    create_box(_time1, _top1, _bottom1, trendIndicator, HTFLabelText)

Line_Type_Control(Type) =>
    switch Type
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted

Text_Size_Switch(ts) =>
    switch ts
        "Normal" => size.normal
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Large"  => size.large
        "Huge"   => size.huge
        "Auto"   => size.auto

TF_Display() =>
    var lbl = ""
    if timeframe.isseconds
        lbl := str.tostring(timeframe.multiplier) + "Sec"
    else if timeframe.isminutes and timeframe.multiplier % 60 != 0
        lbl := str.tostring(timeframe.multiplier) + "Min"
    else if timeframe.isminutes
        lbl := str.tostring(timeframe.multiplier / 60) + "H"
    else if timeframe.isdaily
        lbl := str.tostring(timeframe.multiplier) + "D"
    else if timeframe.isweekly
        lbl := str.tostring(timeframe.multiplier) + "W"
    else if timeframe.ismonthly
        lbl := str.tostring(timeframe.multiplier) + "M"
    lbl

[SH, SL] = request.security(syminfo.tickerid, timeframe.period,
     [ta.pivothigh(high, Swing_Length, Swing_Length), ta.pivotlow(low, Swing_Length, Swing_Length)],
     gaps=barmerge.gaps_on)

Count_Candles_For_Structure(Direction, Condition) =>
    var int High_Count = 0
    var int Low_Count  = 0
    if Direction == "Bullish"
        for i = 0 to Condition
            High_Count := i
        High_Count
    else if Direction == "Bearish"
        for i = 0 to Condition
            Low_Count := i
        Low_Count

Market_Structure(SH, SL, Swing_Length, Line_Type, Line_Width, Bul_Bos_Col, Bear_Bos_Col,
     Bul_Ms_Col, Bear_Ms_Col, Text_Size, Use_High_Low, Show_Bos, Show_Mss, CurrentBreakoutType) =>
    var float Prev_High = na
    var float Prev_Low  = na
    Prev_High_Time = 0
    Prev_Low_Time  = 0
    High_Count = 0
    Low_Count  = 0
    var bool High_Present = false
    var bool Low_Present  = false
    bool localBosSignal = false
    bool localMssSignal = false
    var int New_Breakout_Type = CurrentBreakoutType == 1 ? 1 : -1
    bool High_Broken  = false
    bool Low_Broken   = false
    End_High_Time = 0
    End_Low_Time  = 0
    bool HH = false
    bool LH = false
    bool HL = false
    bool LL = false

    High_Close_Price = request.security(syminfo.tickerid, timeframe.period, Use_High_Low ? high : close)
    Low_Close_Price  = request.security(syminfo.tickerid, timeframe.period, Use_High_Low ? low  : close)

    if not na(SH)
        HH := SH >= Prev_High
        LH := not HH
        Prev_High := SH
        Prev_High_Time := Prev_High != Prev_High[1] ? time[Swing_Length] : Prev_High_Time[1]
        High_Present := true

    if not na(SL)
        HL := SL >= Prev_Low
        LL := not HL
        Prev_Low := SL
        Prev_Low_Time := Prev_Low != Prev_Low[1] ? time[Swing_Length] : Prev_Low_Time[1]
        Low_Present := true

    if High_Close_Price > Prev_High and High_Present
        High_Broken  := true
        High_Present := false
        End_High_Time := time

    if Low_Close_Price < Prev_Low and Low_Present
        Low_Broken  := true
        Low_Present := false
        End_Low_Time := time

    float moveAboveFractal = 0
    float moveBelowFractal = 0
    if enableFractals
        moveAboveFractal := 4
        moveBelowFractal := -4

    if HH and enableTrendLinePlotting
        label.new(Prev_High_Time, Prev_High + moveAboveFractal, "HH \n" + TF_Display(), xloc=xloc.bar_time, color=Transparent_Color, style=label.style_label_down, textcolor=Bul_Ms_Col, size=Text_Size_Switch(Text_Size))
    if HL and enableTrendLinePlotting
        label.new(Prev_Low_Time,  Prev_Low  + moveBelowFractal, "HL \n" + TF_Display(), xloc=xloc.bar_time, color=Transparent_Color, style=label.style_label_up,   textcolor=Bul_Ms_Col, size=Text_Size_Switch(Text_Size))
    if LH and enableTrendLinePlotting
        label.new(Prev_High_Time, Prev_High + moveAboveFractal, "LH \n" + TF_Display(), xloc=xloc.bar_time, color=Transparent_Color, style=label.style_label_down, textcolor=Bear_Ms_Col, size=Text_Size_Switch(Text_Size))
    if LL and enableTrendLinePlotting
        label.new(Prev_Low_Time,  Prev_Low  + moveBelowFractal, "LL \n" + TF_Display(), xloc=xloc.bar_time, color=Transparent_Color, style=label.style_label_up,   textcolor=Bear_Ms_Col, size=Text_Size_Switch(Text_Size))

    High_Count := ta.barssince(HH or LH) + Swing_Length
    Low_Count  := ta.barssince(HL or LL) + Swing_Length

    High_Count_Function = Count_Candles_For_Structure("Bullish", High_Count)
    Low_Count_Function  = Count_Candles_For_Structure("Bearish", Low_Count)

    if High_Broken
        if New_Breakout_Type == 1 and Show_Bos
            localBosSignal := true
            line.new(x1=time[High_Count_Function], y1=Prev_High, x2=End_High_Time, y2=Prev_High, xloc=xloc.bar_time, color=Bul_Bos_Col, style=Line_Type_Control(Line_Type), width=Line_Width)
            label.new(x=time[High_Count_Function/2], y=Prev_High, xloc=xloc.bar_time, text="BOS \n" + TF_Display(), color=Transparent_Color, style=label.style_label_down, textcolor=Bul_Bos_Col, size=Text_Size_Switch(Text_Size))
        else if New_Breakout_Type == -1 and Show_Mss
            localMssSignal := true
            line.new(x1=time[High_Count_Function], y1=Prev_High, x2=End_High_Time, y2=Prev_High, xloc=xloc.bar_time, color=Bul_Bos_Col, style=Line_Type_Control(Line_Type), width=Line_Width)
            label.new(x=time[High_Count_Function/2], y=Prev_High, xloc=xloc.bar_time, text="MSS \n" + TF_Display(), color=Transparent_Color, style=label.style_label_down, textcolor=Bul_Bos_Col, size=Text_Size_Switch(Text_Size))
        New_Breakout_Type := 1

    if Low_Broken
        if New_Breakout_Type == -1 and Show_Bos
            localBosSignal := true
            line.new(x1=time[Low_Count_Function], y1=Prev_Low, x2=End_Low_Time, y2=Prev_Low, xloc=xloc.bar_time, color=Bear_Bos_Col, style=Line_Type_Control(Line_Type), width=Line_Width)
            label.new(x=time[Low_Count_Function/2], y=Prev_Low, xloc=xloc.bar_time, text="BOS \n" + TF_Display(), color=Transparent_Color, textcolor=Bear_Bos_Col, style=label.style_label_up, size=Text_Size_Switch(Text_Size))
        else if New_Breakout_Type == 1 and Show_Mss
            localMssSignal := true
            line.new(x1=time[Low_Count_Function], y1=Prev_Low, x2=End_Low_Time, y2=Prev_Low, xloc=xloc.bar_time, color=Bear_Bos_Col, style=Line_Type_Control(Line_Type), width=Line_Width)
            label.new(x=time[Low_Count_Function/2], y=Prev_Low, xloc=xloc.bar_time, text="MSS \n" + TF_Display(), color=Transparent_Color, textcolor=Bear_Bos_Col, style=label.style_label_up, size=Text_Size_Switch(Text_Size))
        New_Breakout_Type := -1

    [localBosSignal, localMssSignal, New_Breakout_Type]

[bosSignal, mssSignal, New_Breakout_Type] = Market_Structure(SH, SL, Swing_Length, Line_Type, Line_Width,
     Bul_Bos_Col, Bear_Bos_Col, Bul_MS_Col, Bear_MS_Col, Text_Size,
     Use_High_Low, Show_Bos, Show_Mss, CurrentBreakoutType)
CurrentBreakoutType := New_Breakout_Type

var bool plotUpFractal   = false
var bool plotDownFractal = false
n = 1

if enableFractals
    bool upflag    = true
    bool upflagUp0 = true
    bool upflagUp1 = true
    bool upflagUp2 = true
    bool upflagUp3 = true
    bool upflagUp4 = true
    for i = 1 to n
        upflag    := upflag    and (high[n-i] < high[n])
        upflagUp0 := upflagUp0 and (high[n+i] < high[n])
        upflagUp1 := upflagUp1 and (high[n+1] <= high[n] and high[n+i+1] < high[n])
        upflagUp2 := upflagUp2 and (high[n+1] <= high[n] and high[n+2] <= high[n] and high[n+i+2] < high[n])
        upflagUp3 := upflagUp3 and (high[n+1] <= high[n] and high[n+2] <= high[n] and high[n+3] <= high[n] and high[n+i+3] < high[n])
        upflagUp4 := upflagUp4 and (high[n+1] <= high[n] and high[n+2] <= high[n] and high[n+3] <= high[n] and high[n+4] <= high[n] and high[n+i+4] < high[n])
    flagUp = upflagUp0 or upflagUp1 or upflagUp2 or upflagUp3 or upflagUp4
    plotUpFractal := upflag and flagUp

    bool downflag    = true
    bool downflagUp0 = true
    bool downflagUp1 = true
    bool downflagUp2 = true
    bool downflagUp3 = true
    bool downflagUp4 = true
    for i = 1 to n
        downflag    := downflag    and (low[n-i] > low[n])
        downflagUp0 := downflagUp0 and (low[n+i] > low[n])
        downflagUp1 := downflagUp1 and (low[n+1] >= low[n] and low[n+i+1] > low[n])
        downflagUp2 := downflagUp2 and (low[n+1] >= low[n] and low[n+2] >= low[n] and low[n+i+2] > low[n])
        downflagUp3 := downflagUp3 and (low[n+1] >= low[n] and low[n+2] >= low[n] and low[n+3] >= low[n] and low[n+i+3] > low[n])
        downflagUp4 := downflagUp4 and (low[n+1] >= low[n] and low[n+2] >= low[n] and low[n+3] >= low[n] and low[n+4] >= low[n] and low[n+i+4] > low[n])
    flagDown = downflagUp0 or downflagUp1 or downflagUp2 or downflagUp3 or downflagUp4
    plotDownFractal := downflag and flagDown

plotshape(plotDownFractal, style=shape.triangledown, location=location.belowbar, offset=-n, color=#F44336, size=size.small)
plotshape(plotUpFractal,   style=shape.triangleup,   location=location.abovebar, offset=-n, color=#009688, size=size.small)

var float[] highs = array.new_float(0)
var float[] lows  = array.new_float(0)
var map_highs = map.new<float, int>()
var map_lows  = map.new<float, int>()

updateArrays() =>
    i = array.size(highs) - 1
    while i >= 0
        if high > array.get(highs, i)
            highValue = array.get(highs, i)
            if map.contains(map_highs, highValue)
                map.remove(map_highs, highValue)
            array.remove(highs, i)
        else
            break
        i := i - 1
    j = array.size(lows) - 1
    while j >= 0
        if low < array.get(lows, j)
            lowValue = array.get(lows, j)
            if map.contains(map_lows, lowValue)
                map.remove(map_lows, lowValue)
            array.remove(lows, j)
        else
            break
        j := j - 1

if enableEQHEQL
    if map.contains(map_highs, high)
        int x1Index = map.get(map_highs, high)
        if bar_index - x1Index <= 500 and not na(x1Index)
            line.new(x1=map.get(map_highs, high), y1=high, x2=bar_index, y2=high, xloc=xloc.bar_index, color=EQHLineColor, width=EQLineWidth)
    if map.contains(map_lows, low)
        int x1Index = map.get(map_lows, low)
        if bar_index - x1Index <= 500 and not na(x1Index)
            line.new(x1=map.get(map_lows, low), y1=low, x2=bar_index, y2=low, xloc=xloc.bar_index, color=EQLLineColor, width=EQLineWidth)
    if array.size(highs) >= 400
        map.remove(map_highs, array.shift(highs))
    if array.size(lows) >= 400
        map.remove(map_lows, array.shift(lows))
    updateArrays()
    array.push(highs, high)
    array.push(lows, low)
    map.put(map_highs, high, bar_index)
    map.put(map_lows, low, bar_index)

// ─────────────────────────────
// 📢 Alerts
// ─────────────────────────────
alertcondition(Enable_Bos_Alert and bosSignal, title="BOS Alert",  message="New BOS occurred")
alertcondition(Enable_Mss_Alert and mssSignal, title="MSS Alert",  message="New MSS occurred")
alertcondition(failed2U, title="F2U Alert", message="Failed 2 Up on {{ticker}} at {{close}}")
alertcondition(failed2D, title="F2D Alert", message="Failed 2 Down on {{ticker}} at {{close}}")
````

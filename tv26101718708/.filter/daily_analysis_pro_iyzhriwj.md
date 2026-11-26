# Daily Analysis Pro

- url: https://www.tradingview.com/script/iYzHRIWJ/
- type: indicator
- pine_id: PUB;11cfb201a4654a15ac84960dec6a1cfd
- version: 1.0

## Description

مؤشر يوضح الاتجاه اليومي واماكن الاهتمام واماكن التشبع اقوى شموع اليوم الاعلى والادني اليومي اماكن الاوردر بلوك والفجوات يعمل على كل الفترات

## Source Code

````pine
//@version=5
indicator("Daily Analysis Pro", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ═══ Settings ═══

grpDay = "Day Settings"
showDayStart   = input.bool(true, "Show Day Start Line", group=grpDay)
showDayEnd     = input.bool(true, "Show Day End Line", group=grpDay)
dayStartColor  = input.color(color.blue, "Day Start Color", group=grpDay)
dayEndColor    = input.color(color.red, "Day End Color", group=grpDay)
vLineStyle     = input.string("dashed", "Vertical Line Style", options=["solid","dashed","dotted"], group=grpDay)
vLineWidth     = input.int(1, "Vertical Line Width", minval=1, maxval=4, group=grpDay)

grpHL = "Day High/Low"
showHigh       = input.bool(true, "Show High Line", group=grpHL)
showLow        = input.bool(true, "Show Low Line", group=grpHL)
highColor      = input.color(color.green, "High Color", group=grpHL)
lowColor       = input.color(color.red, "Low Color", group=grpHL)
hLineWidth     = input.int(2, "Horizontal Line Width", minval=1, maxval=4, group=grpHL)
showHLLabels   = input.bool(true, "Show Price Labels", group=grpHL)

grpCandle = "Biggest Candle"
showBigCandle  = input.bool(true, "Show Arrow Under Biggest Candle", group=grpCandle)
bigCandleColor = input.color(color.orange, "Arrow Color", group=grpCandle)
candleMode     = input.string("Range", "Detection Mode", options=["Range","Body"], group=grpCandle)

grpRSI = "Ultimate RSI Reversal Signals"
rsiType        = input.string("Ultimate RSI", "RSI Type", options=["Ultimate RSI","Classic RSI"], group=grpRSI)
rsiLength      = input.int(7, "RSI Length", minval=2, group=grpRSI)
smoothType     = input.string("EMA", "Smoothing Type", options=["EMA","SMA","RMA","WMA"], group=grpRSI)
smoothLength   = input.int(1, "Smoothing Length", minval=1, group=grpRSI)
rsiSource      = input.source(close, "RSI Source", group=grpRSI)
rsiOverbought  = input.int(70, "Overbought Level", minval=50, maxval=100, group=grpRSI)
rsiOversold    = input.int(30, "Oversold Level", minval=0, maxval=50, group=grpRSI)
showRSIArrows  = input.bool(true, "Show RSI Arrows", group=grpRSI)
showRSIValue   = input.bool(true, "Show Current RSI Value", group=grpRSI)
overboughtColor= input.color(color.red, "Bearish Reversal Color", group=grpRSI)
oversoldColor  = input.color(color.lime, "Bullish Reversal Color", group=grpRSI)

grpOB = "Order Block + FVG"
showOBFVG      = input.bool(true, "Show Order Block + FVG", group=grpOB)
obLookback     = input.int(20, "Lookback Bars", minval=5, maxval=100, group=grpOB, tooltip="How many bars to scan for OB")
obStrength     = input.float(1.5, "Move Strength (ATR Multiplier)", minval=0.5, step=0.1, group=grpOB, tooltip="How strong the move after OB should be")
showOBLabels   = input.bool(true, "Show OB+FVG Labels", group=grpOB)
extendOB       = input.bool(true, "Extend OB Until Mitigated", group=grpOB)
bullOBColor    = input.color(color.new(color.green, 75), "Bullish OB Color", group=grpOB)
bearOBColor    = input.color(color.new(color.red, 75), "Bearish OB Color", group=grpOB)
bullFVGColor   = input.color(color.new(color.lime, 80), "Bullish FVG Color", group=grpOB)
bearFVGColor   = input.color(color.new(color.fuchsia, 80), "Bearish FVG Color", group=grpOB)

// ═══ Day Detection ═══
isNewDay = ta.change(time("D")) != 0
lineStyleVar = vLineStyle == "solid" ? line.style_solid : vLineStyle == "dashed" ? line.style_dashed : line.style_dotted

if isNewDay and showDayStart
    line.new(x1=bar_index, y1=0, x2=bar_index, y2=1, xloc=xloc.bar_index, extend=extend.both, color=dayStartColor, style=lineStyleVar, width=vLineWidth)

if isNewDay and showDayEnd and bar_index > 0
    line.new(x1=bar_index-1, y1=0, x2=bar_index-1, y2=1, xloc=xloc.bar_index, extend=extend.both, color=dayEndColor, style=lineStyleVar, width=vLineWidth)

// ═══ Day High/Low Tracking ═══
var float dayHigh = na
var float dayLow  = na
var line  highLine = na
var line  lowLine  = na
var label highLbl  = na
var label lowLbl   = na

if isNewDay
    if not na(highLine)
        line.set_x2(highLine, time[1])
    if not na(lowLine)
        line.set_x2(lowLine, time[1])
    dayHigh := high
    dayLow := low
    if showHigh
        highLine := line.new(time, high, time, high, xloc=xloc.bar_time, color=highColor, width=hLineWidth, style=line.style_solid)
    if showLow
        lowLine := line.new(time, low, time, low, xloc=xloc.bar_time, color=lowColor, width=hLineWidth, style=line.style_solid)
else
    if high > dayHigh
        dayHigh := high
        if not na(highLine)
            line.set_y1(highLine, dayHigh)
            line.set_y2(highLine, dayHigh)
    if low < dayLow
        dayLow := low
        if not na(lowLine)
            line.set_y1(lowLine, dayLow)
            line.set_y2(lowLine, dayLow)
    if not na(highLine)
        line.set_x2(highLine, time)
    if not na(lowLine)
        line.set_x2(lowLine, time)

if showHLLabels and barstate.islast
    if showHigh and not na(dayHigh)
        label.delete(highLbl)
        highLbl := label.new(time, dayHigh, "High: " + str.tostring(dayHigh, format.mintick), xloc=xloc.bar_time, style=label.style_label_left, color=highColor, textcolor=color.white, size=size.small)
    if showLow and not na(dayLow)
        label.delete(lowLbl)
        lowLbl := label.new(time, dayLow, "Low: " + str.tostring(dayLow, format.mintick), xloc=xloc.bar_time, style=label.style_label_left, color=lowColor, textcolor=color.white, size=size.small)

// ═══ Biggest Candle ═══
var float maxCandleSize = 0.0
var int   maxCandleTime = na
var float maxCandleLow  = na

candleSize = candleMode == "Range" ? (high - low) : math.abs(close - open)

if isNewDay
    if showBigCandle and not na(maxCandleTime)
        label.new(maxCandleTime, maxCandleLow, "▲", xloc=xloc.bar_time, style=label.style_label_up, color=bigCandleColor, textcolor=color.white, size=size.normal)
    maxCandleSize := candleSize
    maxCandleTime := time
    maxCandleLow := low
else
    if candleSize > maxCandleSize
        maxCandleSize := candleSize
        maxCandleTime := time
        maxCandleLow := low

var label currentBigCandleLbl = na
if showBigCandle and barstate.islast and not na(maxCandleTime)
    label.delete(currentBigCandleLbl)
    currentBigCandleLbl := label.new(maxCandleTime, maxCandleLow, "▲", xloc=xloc.bar_time, style=label.style_label_up, color=bigCandleColor, textcolor=color.white, size=size.normal)

// ═══ Ultimate RSI ═══
ma_function(source, length, maType) =>
    switch maType
        "EMA" => ta.ema(source, length)
        "SMA" => ta.sma(source, length)
        "RMA" => ta.rma(source, length)
        "WMA" => ta.wma(source, length)
        => ta.ema(source, length)

ultimateRSI(src, len, smType, smLen) =>
    upper = ta.highest(src, len)
    lower = ta.lowest(src, len)
    r = upper - lower
    d = src - src[1]
    diff = upper > upper[1] ? r : lower < lower[1] ? -r : d
    num = ma_function(diff, len, "RMA")
    den = ma_function(math.abs(diff), len, "RMA")
    rsi_raw = den != 0 ? num / den * 50 + 50 : 50
    ma_function(rsi_raw, smLen, smType)

classicRSI(src, len, smType, smLen) =>
    rsi_raw = ta.rsi(src, len)
    ma_function(rsi_raw, smLen, smType)

rsiValue = rsiType == "Ultimate RSI" ? ultimateRSI(rsiSource, rsiLength, smoothType, smoothLength) : classicRSI(rsiSource, rsiLength, smoothType, smoothLength)

var bool inOverboughtZone = false
var bool inOversoldZone = false

bearishExit = inOverboughtZone and rsiValue < rsiOverbought
bullishExit = inOversoldZone and rsiValue > rsiOversold

if rsiValue >= rsiOverbought
    inOverboughtZone := true
if rsiValue < rsiOverbought
    inOverboughtZone := false
if rsiValue <= rsiOversold
    inOversoldZone := true
if rsiValue > rsiOversold
    inOversoldZone := false

plotshape(showRSIArrows and bearishExit, title="Bearish Reversal", style=shape.arrowdown, location=location.abovebar, color=overboughtColor, size=size.normal, text="▼", textcolor=color.white)
plotshape(showRSIArrows and bullishExit, title="Bullish Reversal", style=shape.arrowup, location=location.belowbar, color=oversoldColor, size=size.normal, text="▲", textcolor=color.white)

var label rsiInfoLbl = na
if showRSIValue and barstate.islast
    label.delete(rsiInfoLbl)
    rsiStatus = inOverboughtZone ? " [OB]" : inOversoldZone ? " [OS]" : ""
    rsiText = (rsiType == "Ultimate RSI" ? "URSI: " : "RSI: ") + str.tostring(rsiValue, "#.##") + rsiStatus
    rsiInfoLbl := label.new(time, high, rsiText, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_down, color=color.gray, textcolor=color.white, size=size.small)

// ═══ Order Block + FVG Detection ═══
atrValue = ta.atr(14)

// كشف FVG (Fair Value Gap)
// Bullish FVG: low الحالي > high قبل شمعتين (gap up)
// Bearish FVG: high الحالي < low قبل شمعتين (gap down)
bullishFVG = low > high[2]
bearishFVG = high < low[2]

// كشف Order Block:
// Bullish OB: شمعة هابطة (close<open) متبوعة بحركة صعودية قوية + FVG
// Bearish OB: شمعة صاعدة (close>open) متبوعة بحركة هبوطية قوية + FVG

// نفحص الشمعة قبل شمعتين (التي قبل الـ FVG)
// الشمعة الحالية تكون الثالثة، والـ OB هي الشمعة قبل شمعتين
isOBCandleBearish = close[2] < open[2]  // شمعة هابطة كـ Bullish OB
isOBCandleBullish = close[2] > open[2]  // شمعة صاعدة كـ Bearish OB

// قوة الحركة: من open الـ OB لـ close الشمعة الحالية
moveStrengthBull = (close - open[2]) > (atrValue * obStrength)
moveStrengthBear = (open[2] - close) > (atrValue * obStrength)

// إشارة OB+FVG
bullOBSignal = showOBFVG and bullishFVG and isOBCandleBearish and moveStrengthBull
bearOBSignal = showOBFVG and bearishFVG and isOBCandleBullish and moveStrengthBear

// تتبع الـ OBs النشطة لتمديدها حتى تُختبر
var array<box> activeBullOBs = array.new<box>()
var array<box> activeBearOBs = array.new<box>()
var array<box> activeBullFVGs = array.new<box>()
var array<box> activeBearFVGs = array.new<box>()

// رسم Bullish OB + FVG
if bullOBSignal
    // Order Block box (الشمعة قبل شمعتين)
    obTop = math.max(open[2], close[2])
    obBot = math.min(open[2], close[2])
    obBox = box.new(left=bar_index-2, top=obTop, right=bar_index+5, bottom=obBot, bgcolor=bullOBColor, border_color=color.green, border_width=1, text=showOBLabels ? "Bull OB" : "", text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
    if extendOB
        array.push(activeBullOBs, obBox)

    // FVG box (المنطقة بين high قبل شمعتين و low الحالي)
    fvgTop = low
    fvgBot = high[2]
    fvgBox = box.new(left=bar_index-1, top=fvgTop, right=bar_index+5, bottom=fvgBot, bgcolor=bullFVGColor, border_color=color.lime, border_style=line.style_dashed, border_width=1, text=showOBLabels ? "FVG" : "", text_color=color.white, text_size=size.tiny, text_halign=text.align_right)
    if extendOB
        array.push(activeBullFVGs, fvgBox)

// رسم Bearish OB + FVG
if bearOBSignal
    obTop = math.max(open[2], close[2])
    obBot = math.min(open[2], close[2])
    obBox = box.new(left=bar_index-2, top=obTop, right=bar_index+5, bottom=obBot, bgcolor=bearOBColor, border_color=color.red, border_width=1, text=showOBLabels ? "Bear OB" : "", text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
    if extendOB
        array.push(activeBearOBs, obBox)

    fvgTop = low[2]
    fvgBot = high
    fvgBox = box.new(left=bar_index-1, top=fvgTop, right=bar_index+5, bottom=fvgBot, bgcolor=bearFVGColor, border_color=color.fuchsia, border_style=line.style_dashed, border_width=1, text=showOBLabels ? "FVG" : "", text_color=color.white, text_size=size.tiny, text_halign=text.align_right)
    if extendOB
        array.push(activeBearFVGs, fvgBox)

// تمديد الـ OBs النشطة وحذفها عند الاختبار (mitigation)
if extendOB
    // Bullish OBs
    if array.size(activeBullOBs) > 0
        for i = array.size(activeBullOBs) - 1 to 0
            b = array.get(activeBullOBs, i)
            bTop = box.get_top(b)
            bBot = box.get_bottom(b)
            if low <= bTop and low >= bBot
                // تم اختبار الـ OB
                box.set_right(b, bar_index)
                array.remove(activeBullOBs, i)
            else
                box.set_right(b, bar_index + 5)

    if array.size(activeBullFVGs) > 0
        for i = array.size(activeBullFVGs) - 1 to 0
            b = array.get(activeBullFVGs, i)
            bBot = box.get_bottom(b)
            if low <= bBot
                box.set_right(b, bar_index)
                array.remove(activeBullFVGs, i)
            else
                box.set_right(b, bar_index + 5)

    // Bearish OBs
    if array.size(activeBearOBs) > 0
        for i = array.size(activeBearOBs) - 1 to 0
            b = array.get(activeBearOBs, i)
            bTop = box.get_top(b)
            bBot = box.get_bottom(b)
            if high >= bBot and high <= bTop
                box.set_right(b, bar_index)
                array.remove(activeBearOBs, i)
            else
                box.set_right(b, bar_index + 5)

    if array.size(activeBearFVGs) > 0
        for i = array.size(activeBearFVGs) - 1 to 0
            b = array.get(activeBearFVGs, i)
            bTop = box.get_top(b)
            if high >= bTop
                box.set_right(b, bar_index)
                array.remove(activeBearFVGs, i)
            else
                box.set_right(b, bar_index + 5)

// إشارات لتمييز نقاط الـ OB+FVG
plotshape(bullOBSignal, title="Bullish OB+FVG", style=shape.diamond, location=location.belowbar, color=color.green, size=size.tiny, offset=-2)
plotshape(bearOBSignal, title="Bearish OB+FVG", style=shape.diamond, location=location.abovebar, color=color.red, size=size.tiny, offset=-2)

// ═══ Alerts ═══
alertcondition(bearishExit, title="Bearish Reversal", message="Ultimate RSI exited overbought zone")
alertcondition(bullishExit, title="Bullish Reversal", message="Ultimate RSI exited oversold zone")
alertcondition(isNewDay, title="New Day", message="New trading day started")
alertcondition(bullOBSignal, title="Bullish OB+FVG", message="Bullish Order Block with FVG detected")
alertcondition(bearOBSignal, title="Bearish OB+FVG", message="Bearish Order Block with FVG detected")
````

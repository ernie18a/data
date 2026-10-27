# COM AO V7

- url: https://www.tradingview.com/script/VoJEFkzt/
- type: indicator
- pine_id: PUB;4aa416eece784a4b8acd521b9cc94095
- version: 1.0

## Description

Don't Long Short when them gone, waiting pullback. Use Fib retracement to Long and Short

## Source Code

````pine
//@version=5
indicator("KHANH SMC FIB - CHO HOI VUNG DEP", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=300)

//==================== INPUT ====================
emaLen = input.int(50, "EMA xu hướng")
swingLen = input.int(5, "Độ nhạy Swing/Fib", minval=2, maxval=30)
volLen = input.int(20, "Volume trung bình")
lineBars = input.int(10, "Độ dài đường TP SL", minval=3, maxval=50)
moveLookback = input.int(5, "Số nến đo tăng/giảm mạnh", minval=3, maxval=20)
movePercent = input.float(3.0, "Tăng/giảm mạnh %", step=0.5)
emaNearPercent = input.float(0.5, "EMA gần Fib %", step=0.1)

showEMA = input.bool(true, "Hiện EMA")
showFVG = input.bool(true, "Hiện FVG")
showOB = input.bool(true, "Hiện Order Block")
showFib = input.bool(true, "Hiện Fib")
showGuide = input.bool(true, "Hiện bảng diễn giải")

//==================== BASIC ====================
ema = ta.ema(close, emaLen)
rsi = ta.rsi(close, 14)
[macdLine, signalLine, hist] = ta.macd(close, 12, 26, 9)
volMA = ta.sma(volume, volLen)
atr = ta.atr(14)
mfi = ta.mfi(hlc3, 14)

volOk = volume > volMA
aboveEMA = close > ema
belowEMA = close < ema
emaUp = ema > ema[1]
emaDown = ema < ema[1]

momLong = rsi > 50 and macdLine > signalLine and hist > hist[1]
momShort = rsi < 50 and macdLine < signalLine and hist < hist[1]

//==================== STRUCTURE ====================
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float lastHigh = na
var float prevHigh = na
var float lastLow = na
var float prevLow = na

if not na(ph)
    prevHigh := lastHigh
    lastHigh := ph

if not na(pl)
    prevLow := lastLow
    lastLow := pl

HH = not na(lastHigh) and not na(prevHigh) and lastHigh > prevHigh
HL = not na(lastLow) and not na(prevLow) and lastLow > prevLow
LH = not na(lastHigh) and not na(prevHigh) and lastHigh < prevHigh
LL = not na(lastLow) and not na(prevLow) and lastLow < prevLow

bullStructure = HH and HL
bearStructure = LL and LH

bosUp = not na(lastHigh) and close > lastHigh
bosDown = not na(lastLow) and close < lastLow

equalHigh = not na(lastHigh) and not na(prevHigh) and math.abs(lastHigh - prevHigh) / close * 100 < 0.3
equalLow = not na(lastLow) and not na(prevLow) and math.abs(lastLow - prevLow) / close * 100 < 0.3

//==================== SWEEP / GOM / XA ====================
body = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

sweepLow = not na(prevLow) and low < prevLow and close > prevLow
sweepHigh = not na(prevHigh) and high > prevHigh and close < prevHigh

gomHang = sweepLow and lowerWick > body * 1.5 and close > open and volume > volMA and mfi > mfi[1]
xaHang = sweepHigh and upperWick > body * 1.5 and close < open and volume > volMA and mfi < mfi[1]

//==================== FVG ====================
bullFVG = low > high[2]
bearFVG = high < low[2]

var float bullFVGTop = na
var float bullFVGBot = na
var int bullFVGBar = na
var float bearFVGTop = na
var float bearFVGBot = na
var int bearFVGBar = na

if bullFVG
    bullFVGTop := low
    bullFVGBot := high[2]
    bullFVGBar := bar_index
    if showFVG
        box.new(bar_index - 2, bullFVGTop, bar_index + 10, bullFVGBot, bgcolor=color.new(color.blue, 88), border_color=color.new(color.blue, 40))

if bearFVG
    bearFVGTop := low[2]
    bearFVGBot := high
    bearFVGBar := bar_index
    if showFVG
        box.new(bar_index - 2, bearFVGTop, bar_index + 10, bearFVGBot, bgcolor=color.new(color.red, 88), border_color=color.new(color.red, 40))

bullFVGRetest = not na(bullFVGTop) and bar_index > bullFVGBar and low <= bullFVGTop and close > bullFVGBot
bearFVGRetest = not na(bearFVGTop) and bar_index > bearFVGBar and high >= bearFVGBot and close < bearFVGTop

//==================== ORDER BLOCK ====================
lastBearHigh = ta.valuewhen(close < open, high, 0)
lastBearLow = ta.valuewhen(close < open, low, 0)
lastBullHigh = ta.valuewhen(close > open, high, 0)
lastBullLow = ta.valuewhen(close > open, low, 0)

var float bullOBHigh = na
var float bullOBLow = na
var float bearOBHigh = na
var float bearOBLow = na

if bosUp and not na(lastBearHigh)
    bullOBHigh := lastBearHigh
    bullOBLow := lastBearLow
    if showOB
        box.new(bar_index - 5, bullOBHigh, bar_index + 12, bullOBLow, bgcolor=color.new(color.green, 88), border_color=color.new(color.green, 40))

if bosDown and not na(lastBullHigh)
    bearOBHigh := lastBullHigh
    bearOBLow := lastBullLow
    if showOB
        box.new(bar_index - 5, bearOBHigh, bar_index + 12, bearOBLow, bgcolor=color.new(color.orange, 88), border_color=color.new(color.orange, 40))

bullOBRetest = not na(bullOBHigh) and low <= bullOBHigh and close >= bullOBLow
bearOBRetest = not na(bearOBLow) and high >= bearOBLow and close <= bearOBHigh

//==================== FIBONACCI ====================
fibRange = not na(lastHigh) and not na(lastLow) ? math.abs(lastHigh - lastLow) : na

longFib50 = not na(fibRange) ? lastHigh - fibRange * 0.5 : na
longFib618 = not na(fibRange) ? lastHigh - fibRange * 0.618 : na
longFib786 = not na(fibRange) ? lastHigh - fibRange * 0.786 : na

shortFib50 = not na(fibRange) ? lastLow + fibRange * 0.5 : na
shortFib618 = not na(fibRange) ? lastLow + fibRange * 0.618 : na
shortFib786 = not na(fibRange) ? lastLow + fibRange * 0.786 : na

longFibZone = not na(longFib786) and low <= longFib50 and close >= longFib786
shortFibZone = not na(shortFib786) and high >= shortFib50 and close <= shortFib786

emaGanFibLong = not na(longFib618) and math.abs(ema - longFib618) / close * 100 <= emaNearPercent
emaGanFibShort = not na(shortFib618) and math.abs(ema - shortFib618) / close * 100 <= emaNearPercent

vungHoiLongDep = longFibZone and (bullFVGRetest or bullOBRetest or emaGanFibLong or sweepLow)
vungHoiShortDep = shortFibZone and (bearFVGRetest or bearOBRetest or emaGanFibShort or sweepHigh)

//==================== FIB EXTENSION TP ====================
longTP1 = not na(fibRange) ? lastHigh + fibRange * 0.272 : na
longTP2 = not na(fibRange) ? lastHigh + fibRange * 0.618 : na
longTP3 = not na(fibRange) ? lastHigh + fibRange * 1.0 : na

shortTP1 = not na(fibRange) ? lastLow - fibRange * 0.272 : na
shortTP2 = not na(fibRange) ? lastLow - fibRange * 0.618 : na
shortTP3 = not na(fibRange) ? lastLow - fibRange * 1.0 : na

//==================== KHONG DUOI GIA ====================
daTangManh = close > close[moveLookback] and (close - close[moveLookback]) / close[moveLookback] * 100 >= movePercent
daGiamManh = close < close[moveLookback] and (close[moveLookback] - close) / close[moveLookback] * 100 >= movePercent

choHoiLong = daTangManh and not vungHoiLongDep
choHoiShort = daGiamManh and not vungHoiShortDep

//==================== CONFIRM ====================
longConfirm = close > open and close > high[1]
shortConfirm = close < open and close < low[1]

//==================== TRANG THAI ====================
choLong = aboveEMA and emaUp and bullStructure and momLong and not equalHigh and not xaHang
choShort = belowEMA and emaDown and bearStructure and momShort and not equalLow and not gomHang

longSetup = barstate.isconfirmed and choLong and vungHoiLongDep and volOk and longConfirm and not choHoiLong
shortSetup = barstate.isconfirmed and choShort and vungHoiShortDep and volOk and shortConfirm and not choHoiShort

longSignal = longSetup and not longSetup[1]
shortSignal = shortSetup and not shortSetup[1]

//==================== SL ====================
longSL = not na(lastLow) ? lastLow - atr * 0.2 : close - atr
shortSL = not na(lastHigh) ? lastHigh + atr * 0.2 : close + atr

//==================== PLOT ====================
plot(showEMA ? ema : na, color=color.yellow, linewidth=2, title="EMA xu huong")
plot(showFib ? longFib50 : na, color=color.new(color.aqua, 70), title="Fib Long 0.5")
plot(showFib ? longFib618 : na, color=color.new(color.blue, 70), title="Fib Long 0.618")
plot(showFib ? longFib786 : na, color=color.new(color.purple, 70), title="Fib Long 0.786")
plot(showFib ? shortFib50 : na, color=color.new(color.aqua, 80), title="Fib Short 0.5")
plot(showFib ? shortFib618 : na, color=color.new(color.blue, 80), title="Fib Short 0.618")
plot(showFib ? shortFib786 : na, color=color.new(color.purple, 80), title="Fib Short 0.786")

plotshape(gomHang, style=shape.labelup, location=location.belowbar, color=color.lime, text="GOM", textcolor=color.black, size=size.tiny)
plotshape(xaHang, style=shape.labeldown, location=location.abovebar, color=color.fuchsia, text="XA", textcolor=color.white, size=size.tiny)

plotshape(choHoiLong, style=shape.labeldown, location=location.abovebar, color=color.gray, text="DA TANG\nCHO HOI", textcolor=color.white, size=size.tiny)
plotshape(choHoiShort, style=shape.labelup, location=location.belowbar, color=color.gray, text="DA GIAM\nCHO HOI", textcolor=color.white, size=size.tiny)

plotshape(choLong and not longSetup and not choHoiLong, style=shape.labelup, location=location.belowbar, color=color.rgb(0,120,255), text="CHO\nLONG", textcolor=color.white, size=size.small)
plotshape(choShort and not shortSetup and not choHoiShort, style=shape.labeldown, location=location.abovebar, color=color.rgb(255,120,0), text="CHO\nSHORT", textcolor=color.white, size=size.small)

plotshape(longSignal, style=shape.labelup, location=location.belowbar, color=color.rgb(0,0,255), text="LONG\nVAO LENH", textcolor=color.white, size=size.normal)
plotshape(shortSignal, style=shape.labeldown, location=location.abovebar, color=color.rgb(255,0,0), text="SHORT\nVAO LENH", textcolor=color.white, size=size.normal)

//==================== DRAW ENTRY / TP / SL ====================
if longSignal
    line.new(bar_index, close, bar_index + lineBars, close, color=color.white, width=2)
    line.new(bar_index, longSL, bar_index + lineBars, longSL, color=color.red, width=2)
    line.new(bar_index, longTP1, bar_index + lineBars, longTP1, color=color.rgb(80,180,255), width=2)
    line.new(bar_index, longTP2, bar_index + lineBars, longTP2, color=color.rgb(0,60,255), width=2)
    line.new(bar_index, longTP3, bar_index + lineBars, longTP3, color=color.rgb(0,0,160), width=2)
    label.new(bar_index + lineBars, close, "ENTRY LONG\n" + str.tostring(close, format.mintick), style=label.style_label_left, color=color.white, textcolor=color.black)
    label.new(bar_index + lineBars, longSL, "SL\n" + str.tostring(longSL, format.mintick), style=label.style_label_left, color=color.red, textcolor=color.white)
    label.new(bar_index + lineBars, longTP1, "TP1 Fib 1.272\n" + str.tostring(longTP1, format.mintick), style=label.style_label_left, color=color.rgb(80,180,255), textcolor=color.black)
    label.new(bar_index + lineBars, longTP2, "TP2 Fib 1.618\n" + str.tostring(longTP2, format.mintick), style=label.style_label_left, color=color.rgb(0,60,255), textcolor=color.white)
    label.new(bar_index + lineBars, longTP3, "TP3 Fib 2.0\n" + str.tostring(longTP3, format.mintick), style=label.style_label_left, color=color.rgb(0,0,160), textcolor=color.white)

if shortSignal
    line.new(bar_index, close, bar_index + lineBars, close, color=color.yellow, width=2)
    line.new(bar_index, shortSL, bar_index + lineBars, shortSL, color=color.red, width=2)
    line.new(bar_index, shortTP1, bar_index + lineBars, shortTP1, color=color.rgb(80,180,255), width=2)
    line.new(bar_index, shortTP2, bar_index + lineBars, shortTP2, color=color.rgb(0,60,255), width=2)
    line.new(bar_index, shortTP3, bar_index + lineBars, shortTP3, color=color.rgb(0,0,160), width=2)
    label.new(bar_index + lineBars, close, "ENTRY SHORT\n" + str.tostring(close, format.mintick), style=label.style_label_left, color=color.yellow, textcolor=color.black)
    label.new(bar_index + lineBars, shortSL, "SL\n" + str.tostring(shortSL, format.mintick), style=label.style_label_left, color=color.red, textcolor=color.white)
    label.new(bar_index + lineBars, shortTP1, "TP1 Fib 1.272\n" + str.tostring(shortTP1, format.mintick), style=label.style_label_left, color=color.rgb(80,180,255), textcolor=color.black)
    label.new(bar_index + lineBars, shortTP2, "TP2 Fib 1.618\n" + str.tostring(shortTP2, format.mintick), style=label.style_label_left, color=color.rgb(0,60,255), textcolor=color.white)
    label.new(bar_index + lineBars, shortTP3, "TP3 Fib 2.0\n" + str.tostring(shortTP3, format.mintick), style=label.style_label_left, color=color.rgb(0,0,160), textcolor=color.white)

//==================== DASHBOARD ====================
var table tb = table.new(position.top_center, 1, 1)

if showGuide and barstate.islast
    txt = longSetup ? "LONG VAO LENH\nHoi ve Fib 0.5-0.786 + FVG/OB/EMA/Sweep" : shortSetup ? "SHORT VAO LENH\nHoi ve Fib 0.5-0.786 + FVG/OB/EMA/Sweep" : choHoiLong ? "DA TANG MANH\nCho hoi ve Fib 0.5-0.786 + FVG/OB/EMA" : choHoiShort ? "DA GIAM MANH\nCho hoi ve Fib 0.5-0.786 + FVG/OB/EMA" : choLong ? "CHO LONG\nChua hoi ve vung dep" : choShort ? "CHO SHORT\nChua hoi ve vung dep" : gomHang ? "DANG GOM\nCho xac nhan" : xaHang ? "DANG XA\nCan than Long" : "CHUA DU SETUP"
    bg = longSetup ? color.new(color.green, 15) : shortSetup ? color.new(color.red, 15) : choHoiLong or choHoiShort ? color.new(color.gray, 10) : choLong ? color.new(color.blue, 10) : choShort ? color.new(color.orange, 10) : gomHang ? color.new(color.lime, 10) : xaHang ? color.new(color.fuchsia, 10) : color.new(color.gray, 20)
    table.cell(tb, 0, 0, txt, text_color=color.white, bgcolor=bg, text_size=size.normal)

alertcondition(longSignal, title="LONG VAO LENH", message="Long sau khi hoi ve Fib/FVG/OB/EMA")
alertcondition(shortSignal, title="SHORT VAO LENH", message="Short sau khi hoi ve Fib/FVG/OB/EMA")
alertcondition(choHoiLong, title="DA TANG CHO HOI", message="Gia da tang manh, cho hoi ve Fib/FVG/OB/EMA")
alertcondition(choHoiShort, title="DA GIAM CHO HOI", message="Gia da giam manh, cho hoi ve Fib/FVG/OB/EMA")
````

# Jan Buy, Hold, Add c TP/baghold-doi warning

- url: https://www.tradingview.com/script/13If880V/
- type: indicator
- pine_id: PUB;abe911046c04402ab227729e892d208c
- version: 4.0

## Description

This indicator is built on a trend-following framework combined with pullback entry and momentum confirmation. Its purpose is to help traders enter early in a developing uptrend and add to positions systematically when price pulls back within the main trend.

The strategy is structured around two buying phases.

Buy1 is the initial entry signal at the early stage of a trend. It is designed to capture the beginning of a bullish move when price structure starts turning positive and momentum confirms the setup. The goal of Buy1 is to establish a position early, before the trend fully expands.

Buy2 is the add-on entry during a pullback. It looks for a new swing low that remains higher than the previous swing low, while MACD also shows improving momentum. This signal is intended for adding to an existing position during a healthy retracement, with the Stop Loss anchored to the EMA100 in order to keep risk aligned with the primary trend.

Another key component is the “doi” warning signal. “Doi” is Thai stock-trader slang referring to buying near the top and getting stuck at the peak. In this indicator, the doi signal acts as a warning not to add more or open new positions at that stage, because the probability of ending up trapped near the high is increasing. In English, the closest concept would be baghold or bagholding risk.

For profit management, the script is not designed around exiting the full position at a single target. Instead, it follows a scale-out approach, allowing profits to be taken gradually as price extends and momentum evolves. This is intended to help traders stay with strong trends longer while reducing the risk of exiting too early.

This indicator works best on stocks or other assets that tend to move in sustained, directional trends. It is especially suitable for instruments that can trend for extended periods, because the logic is based on entering early in a trend and adding on constructive pullbacks, rather than trading short-term reversals in sideways conditions.

อินดิเคเตอร์นี้ถูกออกแบบบนแนวคิดของ trend following ร่วมกับ pullback entry และ momentum confirmation โดยมีเป้าหมายเพื่อช่วยให้นักลงทุนเริ่มเข้าซื้อในช่วงต้นของแนวโน้มขาขึ้น และสามารถวางแผนซื้อเพิ่มอย่างมีระบบเมื่อราคาเกิดการย่อในเทรนด์หลัก

แนวคิดหลักของระบบคือแบ่งการเข้าซื้อออกเป็น 2 จังหวะ

Buy1 คือสัญญาณซื้อช่วงต้นเทรนด์ ใช้เพื่อจับจุดเริ่มต้นของแนวโน้มขาขึ้น เมื่อโครงสร้างราคาเริ่มเปลี่ยนเป็นบวกและ momentum สนับสนุน เป้าหมายของ Buy1 คือการเริ่มต้นถือ position ตั้งแต่ระยะเริ่มต้นของเทรนด์ ก่อนที่ราคาเข้าสู่ช่วงเร่งตัว

Buy2 คือสัญญาณซื้อเพิ่มระหว่างทาง เมื่อราคาเกิด pullback แต่ยังคงรักษาโครงสร้างขาขึ้นไว้ โดยระบบจะมองหาจุด swing low ใหม่ที่ยกสูงกว่าสวิงโลว์ก่อนหน้า พร้อมกับ MACD ที่แสดงแรงส่งดีขึ้น สัญญาณนี้ใช้เพื่อเพิ่ม position ในช่วงย่อ โดยกำหนด Stop Loss อ้างอิงจาก EMA100 เพื่อควบคุมความเสี่ยงให้อยู่ในกรอบของเทรนด์หลัก

อีกองค์ประกอบสำคัญคือสัญญาณ “doi” ซึ่งเป็นคำแสลงในหมู่นักเล่นหุ้นไทย หมายถึงภาวะที่ซื้อบนยอดหรือไปติดอยู่บนภูเขา ในบริบทของอินดิเคเตอร์นี้ “doi” ใช้เป็นสัญญาณเตือนว่าไม่ควรเปิด order เพิ่ม หรือไม่ควรไล่ซื้อเพิ่มในจังหวะนั้น เพราะมีความเสี่ยงที่จะกลายเป็นการถือของบนยอด หากเทียบในภาษาอังกฤษ แนวคิดนี้ใกล้เคียงกับคำว่า baghold หรือ bagholding risk

ในด้านการบริหารกำไร อินดิเคเตอร์นี้ไม่ได้มอง Take Profit เป็นจุดขายออกทั้งหมดในครั้งเดียว แต่เน้นแนวคิดการทยอยแบ่งขายทำกำไร หรือ scale out ตามสภาพของราคาและ momentum เพื่อให้สามารถรักษาผลกำไรจากเทรนด์ที่กำลังวิ่ง และลดความเสี่ยงจากการขายหมดเร็วเกินไป

ระบบนี้เหมาะกับหุ้นหรือสินทรัพย์ที่มีลักษณะเคลื่อนไหวเป็นแนวโน้มชัดเจนและสามารถวิ่งต่อเนื่องได้ยาว เช่น หุ้นที่อยู่ในรอบขาขึ้นเด่น หรือสินทรัพย์ที่มี momentum ต่อเนื่อง เพราะแนวคิดของระบบอาศัยการ “เริ่มต้นถือเมื่อเทรนด์เริ่มมา” และ “เพิ่มเมื่อย่อในเทรนด์” มากกว่าการเทรดสวนทางหรือเก็งกำไรระยะสั้นในตลาด sideway

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Janitalia

//@version=6
indicator("Jan Buy-Sell V.3.0-Hold, Add c TP/baghold-doi warning", overlay = true)

// =========================
// INPUTS
// =========================
src = input.source(close, "Source")

emaFastLen = input.int(9, "EMA Fast", minval = 1)
emaMidLen  = input.int(21, "EMA Mid", minval = 1)
emaSlowLen = input.int(100, "EMA Slow", minval = 1)

macdFastLen   = input.int(9, "MACD Fast", minval = 1)
macdSlowLen   = input.int(21, "MACD Slow", minval = 1)
macdSignalLen = input.int(7, "MACD Signal", minval = 1)

// pivot high for Doi Signal
pivotHighLeft  = input.int(10, "Doi Swing high Left Bars", minval = 1)
pivotHighRight = input.int(5, "Doi Swing high Right Bars", minval = 1)

// Swing low settings
pivotLeft  = input.int(10, "SL Swing Low Left Bars", minval = 1)
pivotRight = input.int(5, "SL Swing Low Right Bars", minval = 1)

// Position sizing
capitalUsd = input.float(100.0, "Capital / Risk Amount (USD)", minval = 0.01, step = 0.01)

showSLLine = input.bool(true, "Show Fixed SL Line")
showLotLabel = input.bool(true, "Show Lot Size Label")

// =========================
// EMA CALCULATION
// =========================
emaFast = ta.ema(src, emaFastLen)   // EMA 9
emaMid  = ta.ema(src, emaMidLen)    // EMA 21
emaSlow = ta.ema(src, emaSlowLen)   // EMA 100

// =========================
// EMA SLOW FLAT DETECTION
// =========================
flatLookback  = input.int(10, "Flat Lookback Bars", minval = 1)
flatThreshold = input.float(0.03, "Flat Threshold (ATR Normalized)", minval = 0.001, step = 0.001)
atrLenFlat    = input.int(10, "ATR Length (Flat)", minval = 1)

emaSlowSlope = (emaSlow - emaSlow[flatLookback]) / flatLookback
emaSlowNorm  = ta.atr(atrLenFlat) != 0 ? emaSlowSlope / ta.atr(atrLenFlat) : na

emaSlowFlat = math.abs(emaSlowNorm) < flatThreshold

// =========================
// EMA COLORS BASED ON CLOSE
// =========================
emaFastColor = close > emaFast ? color.green : color.red
emaMidColor  = close > emaMid  ? color.green : color.red
emaSlowColor = close > emaSlow ? color.green : color.red

// =========================
// MACD CALCULATION
// =========================
macdLine   = ta.ema(close, macdFastLen) - ta.ema(close, macdSlowLen)
signalLine = ta.ema(macdLine, macdSignalLen)
macdHist   = macdLine - signalLine

// =========================
// Contract Size
// =========================
contractSize = input.float(1.0, "Contract Size (gold100/ Fx 100,000/ Crypto 1/ Stock 1)", minval = 0.0001)

// =========================
// FAST / SLOW CROSS STATE
// =========================
fastBull = emaFast > emaMid
fastBear = emaFast < emaMid

slowBull = emaMid > emaSlow
slowBear = emaMid < emaSlow

// =========================
// FILL COLORS
// =========================
fastFillColor = fastBull ? color.new(color.green, 50) : color.new(color.red, 50)
slowFillColor = slowBull ? color.new(color.green, 80) : color.new(color.red, 80)

// =========================
// ฺBUY1/SELL1 CONDITION
// =========================
buySignal = ta.crossover(emaMid, emaSlow) and macdHist > 0
buyFirstBar = buySignal and not buySignal[1] and not emaSlowFlat

sellSignal = ta.crossunder(emaMid, emaSlow) and macdHist < 0
sellFirstBar = sellSignal and not sellSignal[1] and not emaSlowFlat

// =========================
// CORRECTION LABEL
// =========================
correctionWait = (fastBull and slowBear) or (fastBear and slowBull)

correctionWaitFirstBar = correctionWait and not correctionWait[1]


// =========================
// TREND STATE ALIGNED
// =========================
trendAligned = (fastBull and slowBull) or (fastBear and slowBear)
trendAlignedFirstBar = trendAligned and not trendAligned[1]

// =========================
// SL at PREVIOUS SWING LOW
// =========================
pivotLow = ta.pivotlow(low, pivotLeft, pivotRight)

var float prevSwingLow = na
if not na(pivotLow)
    prevSwingLow := pivotLow

// =========================
// FIXED ENTRY / FIXED SL / LOT SIZE
// =========================
// ล็อกค่าเฉพาะตอนเกิด buyFirstBar
var float fixedEntry = na
var float fixedSL    = na
var float riskDist   = na
var float lotSize    = na

if buyFirstBar and not na(prevSwingLow)
    fixedEntry := close
    fixedSL    := prevSwingLow
    riskDist   := fixedEntry - fixedSL
    lotSize    := riskDist > 0 ? capitalUsd / (riskDist * contractSize) : na

var int entryBarIndex = na

if buyFirstBar
    entryBarIndex := bar_index
    
showSLRange = not na(entryBarIndex) and (bar_index - entryBarIndex <= 10)

// =========================
// Doi signal SWING HIGH + MACD LOWER HIGH
// =========================
pivotHigh = ta.pivothigh(high, pivotHighLeft, pivotHighRight)

var float lastSwingHighPrice = na
var float lastSwingHighMacd  = na

bool doiSignal = false

if not na(pivotHigh)
    float currentSwingHighPrice = pivotHigh
    float currentSwingHighMacd  = macdLine[pivotHighRight]

    doiSignal := not na(lastSwingHighPrice) and not na(lastSwingHighMacd) and
         currentSwingHighPrice > lastSwingHighPrice and
         currentSwingHighMacd < lastSwingHighMacd and
         currentSwingHighMacd > 0 and
         lastSwingHighMacd > 0

    lastSwingHighPrice := currentSwingHighPrice
    lastSwingHighMacd  := currentSwingHighMacd

// =========================
// BUY2 signal SWING LOW + MACD HIGHER LOW
// =========================
var float lastBuy2SwingLowPrice = na
var float lastBuy2SwingLowMacd  = na

bool buy2Signal = false

if not na(pivotLow)
    float currentSwingLowPrice = pivotLow
    float currentSwingLowMacd  = macdLine[pivotRight]

    buy2Signal := not na(lastBuy2SwingLowPrice) and not na(lastBuy2SwingLowMacd) and
         currentSwingLowPrice > lastBuy2SwingLowPrice and
         currentSwingLowMacd > lastBuy2SwingLowMacd and
         close[pivotRight] > emaSlow[pivotRight] and
         macdHist > 0
      

    lastBuy2SwingLowPrice := currentSwingLowPrice
    lastBuy2SwingLowMacd  := currentSwingLowMacd

// =========================
// SELL2 signal SWING HIGH + MACD LOWER HIGH
// =========================
var float lastSell2SwingHighPrice = na
var float lastSell2SwingHighMacd  = na

bool sell2Signal = false

if not na(pivotHigh)
    float currentSell2SwingHighPrice = pivotHigh
    float currentSell2SwingHighMacd  = macdLine[pivotHighRight]

    sell2Signal := not na(lastSell2SwingHighPrice) and not na(lastSell2SwingHighMacd) and
         currentSell2SwingHighPrice < lastSell2SwingHighPrice and
         currentSell2SwingHighMacd < lastSell2SwingHighMacd and
         close[pivotHighRight] < emaSlow[pivotHighRight] and
         macdHist < 0

    lastSell2SwingHighPrice := currentSell2SwingHighPrice
    lastSell2SwingHighMacd  := currentSell2SwingHighMacd

// =========================
// BUY2 FIXED ENTRY / FIXED SL / LOT SIZE
// ใช้ EMA Slow ณ จุด buy2 เป็น fixed SL
// =========================
var float buy2Entry    = na
var float buy2SL       = na
var float buy2RiskDist = na
var float buy2LotSize  = na
var int   buy2BarIndex = na

if buy2Signal
    buy2Entry    := close
    buy2SL       := emaSlow
    buy2RiskDist := buy2Entry - buy2SL
    buy2LotSize  := buy2RiskDist > 0 ? capitalUsd / (buy2RiskDist * contractSize) : na
    buy2BarIndex := bar_index

showBuy2SLRange = not na(buy2BarIndex) and (bar_index - buy2BarIndex <= 10)

// =========================
// TP AT SWING HIGH (21,21)
// =========================
tpPivotHigh = ta.pivothigh(high,14, 5)

tpSignal = not na(tpPivotHigh) and ta.crossunder(close, emaFast) and close > emaSlow

// =========================
// PLOTS
// =========================
pFast = plot(emaFast, title = "EMA 9", color = emaFastColor, linewidth = 1)
pMid  = plot(emaMid,  title = "EMA 21", color = emaMidColor, linewidth = 1)
pSlow = plot(emaSlow, title = "EMA 100", color = emaSlowColor, linewidth = 2)

fill(pFast, pMid, color = fastFillColor, title = "Fast EMA Fill")
fill(pMid, pSlow, color = slowFillColor, title = "Slow EMA Fill")

// =========================
// PLOT EMA SLOW FLAT OVERLAY
// =========================
plot(
     emaSlowFlat ? emaSlow : na,
     title = "EMA Slow Flat Overlay",
     color = color.black,
     linewidth = 4,
     style = plot.style_linebr
)

plot(
     showSLLine and showSLRange ? fixedSL : na,
     title = "Buy1 SL Line",
     color = color.green,
     linewidth = 1,
     style = plot.style_linebr
)
plot(
     showSLLine and showBuy2SLRange ? buy2SL : na,
     title = "BUY2 SL Line",
     color = color.new(color.lime, 0),
     linewidth = 1,
     style = plot.style_linebr
)
// =========================
// SIGNAL LABELS
// =========================
plotshape(
     buyFirstBar and not emaSlowFlat and macdHist > 0,
     title = "BUY1 - Early Trend",
     location = location.abovebar,
     style = shape.labeldown,
     size = size.small,
     color =color.new(color.green, 50),
     text = "B1",
     textcolor = color.white
)

plotshape(
     sellFirstBar and not emaSlowFlat and macdHist < 0,
     title = "SELL1 - Early Down Trend",
     location = location.belowbar,
     style = shape.labelup,
     size = size.small,
     color = color.new(color.red, 50),
     text = "S1",
     textcolor = color.white
)

plotshape(
     sell2Signal and not emaSlowFlat and macdHist<0 ,
     title = "SELL2 Swing High",
     location = location.abovebar,
     style = shape.labeldown,
     offset = -pivotHighRight,
     size = size.small,
     color = color.new(color.maroon, 20),
     text = "S2",
     textcolor = color.white
)

// =========================
// BUY1 SL MARKER
// =========================
plotshape(
     buyFirstBar and not na(fixedSL) ? fixedSL : na,
     title = "Buy1 SL Marker",
     location = location.absolute,
     style = shape.labelup,
     size = size.small,
     color = color.new(color.green, 50),
     text = "SL",
     textcolor = color.white
)
// =========================
// BUY2 SL MARKER
// =========================
plotshape(
     buy2Signal and not na(buy2SL) ? buy2SL : na,
     title = "BUY2 SL Marker",
     location = location.absolute,
     style = shape.labelup,
     size = size.small,
     color = color.new(color.lime, 40),
     text = "B2/SL2",
     textcolor = color.white
)
// plotshape(
//     buy2Signal,
//     title = "BUY2 Swing Low",
//     location = location.belowbar,
//     style = shape.labelup,
//     offset = -pivotRight,
//     size = size.small,
//     color = color.new(color.lime, 20),
//     text = "เตรียม buy2",
//     textcolor = color.white
//)

// =========================
// INFO LABEL FOR ENTRY / SL / LOT
// =========================
if showLotLabel and buyFirstBar and not na(fixedSL) and not na(lotSize)
    label.new(
         bar_index,
         low - ta.atr(14)*3,
         "Buy1 \n Entry: " + str.tostring(fixedEntry, format.mintick) +
         "\nSL: " + str.tostring(fixedSL, format.mintick) +
         "\nLot: " + str.tostring(lotSize, format.mintick),
         style = label.style_label_up,
         color = color.new(color.green, 20),
         textcolor = color.white,
         size = size.small
    )
// =========================
// BUY2 INFO LABEL FOR ENTRY / SL / LOT
// =========================
if showLotLabel and buy2Signal and not na(buy2SL) and not na(buy2LotSize)
    label.new(
         bar_index,
         low - ta.atr(14) * 5,
         "Buy2 \n Entry: " + str.tostring(buy2Entry, format.mintick) +
         "\n SL: " + str.tostring(buy2SL, format.mintick) +
         "\n Lot: " + str.tostring(buy2LotSize, format.mintick),
         style = label.style_label_up,
         color = color.new(color.lime, 20),
         textcolor = color.white,
         size = size.small
    )
// =========================
// COMBINED PRICE CROSS ALERT
// =========================
priceCrossEMA = ta.cross(close, emaMid) or ta.cross(close, emaSlow)

// =========================
// ALERTS
// =========================
alertcondition(
     buyFirstBar or sellFirstBar,
     title = "B1/S1 Strong Trend",
     message = "B1/S1: early trend strict SL"
)

alertcondition(
     buy2Signal or sell2Signal,
     title = "B2/S2 Pullback alert",
     message = "B2/S2 pullback"
)

//alertcondition(
//     sellFirstBar or sell2Signal,
//     title = "SELL1 Alert",
//     message = "SELL1: early down trend"
//)

alertcondition(
     trendAlignedFirstBar,
     title = "Trend Aligned Alert",
     message = "Trend align Gr/Gr or R/R"
)

alertcondition(
     priceCrossEMA,
     title = "Pullback EMA mid-slow",
     message = "Price crossed EMA Mid or EMA Slow กลับมาดูกราฟ"
)

alertcondition(
     ta.cross(emaFast, emaMid),
     title = "SW Fast cross",
     message = "Fast cross wait retest&go"
)


alertcondition(
     (fastBull and ta.crossover(close, emaFast)) or
     (fastBear and ta.crossunder(close, emaFast)),
     title = "Rebound emaFast",
     message = "Price crossed EMA Fast in trend direction"
)

// =========================
// ALERT: NOT EMA SLOW FLAT
// =========================
alertcondition(
     not emaSlowFlat,
     title = "EMA Slow Trending",
     message = "EMA Slow is not flat - market may be tradable"
)
//alertcondition(
//     sell2Signal,
//     title = "SELL2 Alert",
//     message = "SELL2: pullback short / lower high continuation"
//)

//alertcondition(
//     correctionWaitFirstBar,
//     title = "Correction Wait at 100 Alert",
//     message = "Correction wait at 100: Fast EMA state does not match Slow EMA state"
//)

//alertcondition(
//     not na(fixedSL) and close < fixedSL,
//     title = "Fixed SL Broken",
//     message = "Price closed below fixed previous swing low stop"
//)

// =========================
// WEAK MOMENTUM COLOR
// =========================
isWeakUp   = close > emaSlow and macdHist < 0
isWeakDown = close < emaSlow and macdHist > 0

barcolor(
     isWeakUp   ? color.black :
     isWeakDown ? color.black :
     na
)

alertcondition(
     not isWeakUp and not isWeakDown,
     title = "Momentum OK",
     message = "Momentum is back"
)
````

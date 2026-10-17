# SPX 1AM KSA Bias V1

- url: https://www.tradingview.com/script/VHDetYXd/
- type: indicator
- pine_id: PUB;d6c1efa4e9cf4f019294f451578c7c69
- version: 1.0

## Description

SPX 1AM KSA Bias is a liquidity and market structure indicator designed for SPX traders.

The indicator tracks the first 15-minute range at 1:00 AM Saudi Arabia time, detects breakouts, fake moves, retests, and highlights major liquidity zones above and below price.

Features:
• 1AM opening range
• CALL / PUT confirmation signals
• Major liquidity zones
• Fake breakout detection
• Consumed liquidity marking
• Optional EMA 50 / EMA 200 filter

Best used on 15-minute a

## Source Code

````pine
//@version=6
indicator("SPX 1AM KSA Bias V1", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

//====================================================
// إعدادات SPX
//====================================================
daysToKeep  = input.int(10, "عدد أيام افتتاح 1AM", minval=1, maxval=20)
extendBars  = input.int(300, "تمديد الخطوط", minval=50)

pivotLen    = input.int(7, "حساسية القمم والقيعان", minval=2, maxval=20)
maxZones    = input.int(2, "عدد مناطق السيولة لكل جهة", minval=1, maxval=5)

impulseATR  = input.float(3.5, "قوة الحركة بعد القمة/القاع ATR", minval=1.0, step=0.1)

mergeGap    = input.float(8.0, "دمج المناطق القريبة بالنقاط", minval=1, step=1)

maxLiquidityDistance = input.float(80.0, "أقصى بعد للسيولة عن السعر", minval=20, step=5)

retestTicks = input.float(2.0, "مسافة الريتست", step=0.25)

confirmBody = input.float(0.50, "قوة شمعة التأكيد", minval=0.1, maxval=1.0, step=0.05)

consumedBoxHeight = input.float(3.0, "ارتفاع مستطيل الاستهلاك", minval=0.5, step=0.5)

//====================================================
// الألوان
//====================================================
rangeColor    = input.color(color.rgb(255,182,193), "لون افتتاح 1AM")
callColor     = input.color(color.lime, "لون CALL")
putColor      = input.color(color.red, "لون PUT")

buyLiqColor   = input.color(color.orange, "سيولة فوق")
sellLiqColor  = input.color(color.aqua, "سيولة تحت")

consumedColor = input.color(color.gray, "السيولة المستهلكة")
fakeColor     = input.color(color.gray, "Fake Break")

useEMAFilter = input.bool(true, "تفعيل EMA 50/200")

//====================================================
// توقيت السعودية
//====================================================
ksaHour   = hour(time, "Asia/Riyadh")
ksaMinute = minute(time, "Asia/Riyadh")

isStartRange = ksaHour == 1 and ksaMinute == 0
isInRange    = ksaHour == 1 and ksaMinute >= 0 and ksaMinute < 15
isEndRange   = ksaHour == 1 and ksaMinute == 15

newDay = ta.change(dayofmonth(time, "Asia/Riyadh")) != 0

//====================================================
// نطاق افتتاح 1AM
//====================================================
var float rangeHigh = na
var float rangeLow  = na
var int rangeStartBar = na

var bool rangeReady = false

var bool signalTaken = false

var bool bullBroken = false
var bool bearBroken = false

var bool bullRetest = false
var bool bearRetest = false

if newDay

    rangeHigh := na
    rangeLow := na
    rangeStartBar := na

    rangeReady := false

    signalTaken := false

    bullBroken := false
    bearBroken := false

    bullRetest := false
    bearRetest := false

if isStartRange

    rangeHigh := high
    rangeLow  := low

    rangeStartBar := bar_index

if isInRange and not na(rangeHigh)

    rangeHigh := math.max(rangeHigh, high)
    rangeLow  := math.min(rangeLow, low)

//====================================================
// رسم خطوط الافتتاح
//====================================================
var array<line> highLines = array.new_line()
var array<line> lowLines  = array.new_line()

if isEndRange and not na(rangeHigh) and not na(rangeLow)

    hLine = line.new(
         rangeStartBar,
         rangeHigh,
         bar_index + extendBars,
         rangeHigh,
         color=rangeColor,
         width=2
    )

    lLine = line.new(
         rangeStartBar,
         rangeLow,
         bar_index + extendBars,
         rangeLow,
         color=rangeColor,
         width=2
    )

    array.push(highLines, hLine)
    array.push(lowLines, lLine)

    if array.size(highLines) > daysToKeep
        line.delete(array.shift(highLines))

    if array.size(lowLines) > daysToKeep
        line.delete(array.shift(lowLines))

    rangeReady := true

//====================================================
// تمديد الخطوط
//====================================================
if array.size(highLines) > 0
    for i = 0 to array.size(highLines) - 1
        line.set_x2(array.get(highLines, i), bar_index + extendBars)

if array.size(lowLines) > 0
    for i = 0 to array.size(lowLines) - 1
        line.set_x2(array.get(lowLines, i), bar_index + extendBars)

//====================================================
// EMA
//====================================================
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

plot(useEMAFilter ? ema50 : na, color=color.orange, linewidth=2)
plot(useEMAFilter ? ema200 : na, color=color.blue, linewidth=2)

emaBullOK = not useEMAFilter or ema50 > ema200
emaBearOK = not useEMAFilter or ema50 < ema200

//====================================================
// ATR
//====================================================
atr = ta.atr(14)

//====================================================
// مصفوفات السيولة
//====================================================
var array<float> buyPrices = array.new_float()
var array<line>  buyLines  = array.new_line()

var array<float> sellPrices = array.new_float()
var array<line>  sellLines  = array.new_line()

//====================================================
// منع التكرار
//====================================================
isNear(price, arr, gap) =>
    bool result = false

    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            if math.abs(price - array.get(arr, i)) <= gap
                result := true

    result

//====================================================
// Pivot
//====================================================
pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow  = ta.pivotlow(low, pivotLen, pivotLen)

//====================================================
// سيولة فوق السعر
//====================================================
if not na(pivotHigh)

    pivotPrice = pivotHigh
    pivotBar   = bar_index - pivotLen

    dropAfter = pivotPrice - ta.lowest(low, pivotLen + 1)

    strongMove = dropAfter >= atr * impulseATR

    nearPrice = math.abs(pivotPrice - close) <= maxLiquidityDistance

    if strongMove and nearPrice and not isNear(pivotPrice, buyPrices, mergeGap)

        ln = line.new(
             pivotBar,
             pivotPrice,
             bar_index + extendBars,
             pivotPrice,
             color=buyLiqColor,
             width=2
        )

        array.push(buyPrices, pivotPrice)
        array.push(buyLines, ln)

        if array.size(buyPrices) > maxZones

            array.shift(buyPrices)
            line.delete(array.shift(buyLines))

//====================================================
// سيولة تحت السعر
//====================================================
if not na(pivotLow)

    pivotPrice = pivotLow
    pivotBar   = bar_index - pivotLen

    rallyAfter = ta.highest(high, pivotLen + 1) - pivotPrice

    strongMove = rallyAfter >= atr * impulseATR

    nearPrice = math.abs(pivotPrice - close) <= maxLiquidityDistance

    if strongMove and nearPrice and not isNear(pivotPrice, sellPrices, mergeGap)

        ln = line.new(
             pivotBar,
             pivotPrice,
             bar_index + extendBars,
             pivotPrice,
             color=sellLiqColor,
             width=2
        )

        array.push(sellPrices, pivotPrice)
        array.push(sellLines, ln)

        if array.size(sellPrices) > maxZones

            array.shift(sellPrices)
            line.delete(array.shift(sellLines))

//====================================================
// استهلاك السيولة
//====================================================
if array.size(buyPrices) > 0

    for i = array.size(buyPrices) - 1 to 0

        price = array.get(buyPrices, i)
        ln = array.get(buyLines, i)

        line.set_x2(ln, bar_index + extendBars)

        if high >= price

            line.set_color(ln, color.new(consumedColor, 30))
            line.set_style(ln, line.style_dotted)
            line.set_width(ln, 1)
            line.set_x2(ln, bar_index)

            box.new(
                 left=bar_index - 1,
                 top=price + consumedBoxHeight,
                 right=bar_index + 1,
                 bottom=price - consumedBoxHeight,
                 bgcolor=color.new(consumedColor, 75),
                 border_color=color.new(consumedColor, 35)
            )

            array.remove(buyPrices, i)
            array.remove(buyLines, i)

if array.size(sellPrices) > 0

    for i = array.size(sellPrices) - 1 to 0

        price = array.get(sellPrices, i)
        ln = array.get(sellLines, i)

        line.set_x2(ln, bar_index + extendBars)

        if low <= price

            line.set_color(ln, color.new(consumedColor, 30))
            line.set_style(ln, line.style_dotted)
            line.set_width(ln, 1)
            line.set_x2(ln, bar_index)

            box.new(
                 left=bar_index - 1,
                 top=price + consumedBoxHeight,
                 right=bar_index + 1,
                 bottom=price - consumedBoxHeight,
                 bgcolor=color.new(consumedColor, 75),
                 border_color=color.new(consumedColor, 35)
            )

            array.remove(sellPrices, i)
            array.remove(sellLines, i)

//====================================================
// أقرب سيولة
//====================================================
float nearestBuy = na

if array.size(buyPrices) > 0
    for i = 0 to array.size(buyPrices) - 1

        p = array.get(buyPrices, i)

        if p > close
            if na(nearestBuy) or p < nearestBuy
                nearestBuy := p

float nearestSell = na

if array.size(sellPrices) > 0
    for i = 0 to array.size(sellPrices) - 1

        p = array.get(sellPrices, i)

        if p < close
            if na(nearestSell) or p > nearestSell
                nearestSell := p

//====================================================
// قوة الشمعة
//====================================================
candleRange = high - low
bodySize    = math.abs(close - open)

bodyStrength =
 candleRange > 0 ?
 bodySize / candleRange : 0

bullConfirm = close > open and bodyStrength >= confirmBody
bearConfirm = close < open and bodyStrength >= confirmBody

//====================================================
// Break + Retest
//====================================================
bullInitialBreak =
 rangeReady and
 not signalTaken and
 not bullBroken and
 close > rangeHigh

bearInitialBreak =
 rangeReady and
 not signalTaken and
 not bearBroken and
 close < rangeLow

if bullInitialBreak

    bullBroken := true
    bearBroken := false
    bearRetest := false

if bearInitialBreak

    bearBroken := true
    bullBroken := false
    bullRetest := false

//====================================================
// Fake Break
//====================================================
if bullBroken and close < rangeHigh

    bullBroken := false
    bullRetest := false

    label.new(
         bar_index,
         high,
         "Fake ↑",
         style=label.style_label_down,
         color=fakeColor,
         textcolor=color.white,
         size=size.tiny
    )

if bearBroken and close > rangeLow

    bearBroken := false
    bearRetest := false

    label.new(
         bar_index,
         low,
         "Fake ↓",
         style=label.style_label_up,
         color=fakeColor,
         textcolor=color.white,
         size=size.tiny
    )

//====================================================
// Retest
//====================================================
if bullBroken and low <= rangeHigh + retestTicks and close >= rangeHigh
    bullRetest := true

if bearBroken and high >= rangeLow - retestTicks and close <= rangeLow
    bearRetest := true

//====================================================
// الإشارات
//====================================================
bullSignal =
 bullBroken and
 bullRetest and
 bullConfirm and
 emaBullOK and
 not signalTaken

bearSignal =
 bearBroken and
 bearRetest and
 bearConfirm and
 emaBearOK and
 not signalTaken

//====================================================
// CALL
//====================================================
if bullSignal

    signalTaken := true

    label.new(
         bar_index,
         low,
         "CALL",
         style=label.style_label_up,
         color=callColor,
         textcolor=color.white,
         size=size.small
    )

    if not na(nearestBuy)

        line.new(
             bar_index,
             nearestBuy,
             bar_index + extendBars,
             nearestBuy,
             color=buyLiqColor,
             width=2,
             style=line.style_dashed
        )

//====================================================
// PUT
//====================================================
if bearSignal

    signalTaken := true

    label.new(
         bar_index,
         high,
         "PUT",
         style=label.style_label_down,
         color=putColor,
         textcolor=color.white,
         size=size.small
    )

    if not na(nearestSell)

        line.new(
             bar_index,
             nearestSell,
             bar_index + extendBars,
             nearestSell,
             color=sellLiqColor,
             width=2,
             style=line.style_dashed
        )

//====================================================
// التنبيهات
//====================================================
alertcondition(
 bullSignal,
 title="CALL Confirmed",
 message="SPX CALL Confirmed"
)

alertcondition(
 bearSignal,
 title="PUT Confirmed",
 message="SPX PUT Confirmed"
)

//====================================================
// مهم للنشر
//====================================================
plot(close, title="Hidden Plot", color=color.new(color.white, 100))
````

# TURKI

- url: https://www.tradingview.com/script/OUuc0HwO/
- type: indicator
- pine_id: PUB;321053be54fb4c89b64a25643bcc2957
- version: 1.0

## Description

. مناطق عرض وطلب
 2. BOS كسر هيكل السوق
 3. 4 متوسطات EMA
 4. إشارات دخول
 5. Smart Mode وضع ذكي يغيّر بعض التشدد حسب حالة السو

## Source Code

````pine
//@version=6
indicator("TURKI", overlay=true, max_boxes_count=20, max_labels_count=100, max_lines_count=100)

//==================================================
// الإعدادات العامة
//==================================================
group_general      = "الإعدادات العامة"
atrLen             = input.int(14, "طول ATR", minval=1, group=group_general)
baseBars           = input.int(3, "عدد شموع القاعدة", minval=1, maxval=10, group=group_general)
impulseCheckBars   = input.int(3, "عدد شموع فحص الانطلاق", minval=1, maxval=10, group=group_general)
impulseMult        = input.float(1.5, "قوة الانطلاق × ATR", minval=0.1, step=0.1, group=group_general)
zonePaddingATR     = input.float(0.15, "هامش المنطقة × ATR", minval=0.0, step=0.05, group=group_general)
extendBars         = input.int(120, "تمديد المنطقة يمين", minval=10, group=group_general)
maxStoredZones     = input.int(40, "أقصى عدد مناطق محفوظة", minval=2, maxval=200, group=group_general)
minDistanceATR     = input.float(0.8, "أقل مسافة بين المناطق × ATR", minval=0.1, step=0.1, group=group_general)

//==================================================
// إدارة المناطق
//==================================================
group_zone_manage  = "إدارة المناطق"
deleteBroken       = input.bool(true, "حذف المنطقة عند الكسر", group=group_zone_manage)
breakOnClose       = input.bool(true, "الكسر بالإغلاق", group=group_zone_manage)
showZoneText       = input.bool(true, "إظهار النص داخل المنطقة", group=group_zone_manage)
demandText         = input.string("طلب", "نص منطقة الطلب", group=group_zone_manage)
supplyText         = input.string("عرض", "نص منطقة العرض", group=group_zone_manage)

//==================================================
// فلتر الاتجاه
//==================================================
group_trend        = "فلتر الاتجاه"
useTrendFilter     = input.bool(false, "تفعيل فلتر الاتجاه", group=group_trend)
trendFilterOnEMA   = input.int(2, "رقم EMA المستخدم للفلترة (1-4)", minval=1, maxval=4, group=group_trend)

//==================================================
// إعدادات BOS
//==================================================
group_bos          = "إعدادات BOS"
showBOS            = input.bool(true, "إظهار BOS", group=group_bos)
bosLeft            = input.int(3, "شموع يسار BOS", minval=1, group=group_bos)
bosRight           = input.int(3, "شموع يمين BOS", minval=1, group=group_bos)
showBOSLabels      = input.bool(true, "إظهار تسمية BOS", group=group_bos)
showBOSLines       = input.bool(true, "إظهار خط BOS", group=group_bos)
keepLastBOSOnly    = input.bool(true, "إبقاء آخر BOS فقط", group=group_bos)
useStrongBosClose  = input.bool(true, "تفعيل BOS قوي بالإغلاق", group=group_bos)
bosCloseBufferATR  = input.float(0.05, "هامش قوة BOS × ATR", minval=0.0, step=0.01, group=group_bos)

//==================================================
// إعدادات إشارات الدخول
//==================================================
group_entry        = "إشارات الدخول"
showEntries        = input.bool(true, "إظهار إشارات الدخول", group=group_entry)
entryOnTouch       = input.bool(true, "الإشارة عند لمس المنطقة", group=group_entry)
entryOnCloseIn     = input.bool(false, "الإشارة عند إغلاق داخل المنطقة", group=group_entry)
useBOSFilterEntry  = input.bool(true, "فلتر BOS للإشارة", group=group_entry)
useEMAFilterEntry  = input.bool(true, "فلتر EMA للإشارة", group=group_entry)
entryFilterOnEMA   = input.int(2, "رقم EMA المستخدم للإشارة (1-4)", minval=1, maxval=4, group=group_entry)
buySignalColor     = input.color(color.new(color.green, 0), "لون إشارة الشراء", group=group_entry)
sellSignalColor    = input.color(color.new(color.red, 0), "لون إشارة البيع", group=group_entry)

//==================================================
// تحسينات احترافية
//==================================================
group_pro          = "تحسينات احترافية"
useRetest          = input.bool(true, "تفعيل Retest", group=group_pro)
retestDelayBars    = input.int(2, "تأخير الريتست", minval=1, maxval=50, group=group_pro)
retestLookbackBars = input.int(10, "حد أقصى شموع الريتست", minval=2, maxval=100, group=group_pro)
useCandleConfirm   = input.bool(true, "تفعيل تأكيد الشموع", group=group_pro)
candleMode         = input.string("ابتلاع/استمرار", "نوع تأكيد الشموع", options=["ابتلاع/استمرار", "شمعة اتجاه فقط"], group=group_pro)
useSignalDelay     = input.bool(false, "تفعيل تأخير الإشارة", group=group_pro)
signalDelayBars    = input.int(1, "عدد شموع تأخير الإشارة", minval=0, maxval=10, group=group_pro)

//==================================================
// الوضع الذكي
//==================================================
group_smart        = "الوضع الذكي"
useSmartMode       = input.bool(true, "تفعيل الوضع الذكي", group=group_smart)
smartLevel         = input.string("متوسط", "مستوى الذكاء", options=["خفيف", "متوسط", "قوي"], group=group_smart)
adxLen             = input.int(14, "طول ADX", minval=1, group=group_smart)
adxTrendLevel      = input.float(25.0, "حد الترند ADX", minval=1.0, step=0.5, group=group_smart)
showMarketStateBg  = input.bool(true, "إظهار خلفية حالة السوق", group=group_smart)

//==================================================
// إعدادات المتوسطات EMA
//==================================================
group_ema          = "المتوسطات EMA"

showEMA1           = input.bool(true, "إظهار EMA 1", group=group_ema)
emaLen1            = input.int(20, "طول EMA 1", minval=1, group=group_ema)
emaWidth1          = input.int(2, "سمك EMA 1", minval=1, maxval=5, group=group_ema)
emaColor1          = input.color(color.yellow, "لون EMA 1", group=group_ema)

showEMA2           = input.bool(true, "إظهار EMA 2", group=group_ema)
emaLen2            = input.int(50, "طول EMA 2", minval=1, group=group_ema)
emaWidth2          = input.int(2, "سمك EMA 2", minval=1, maxval=5, group=group_ema)
emaColor2          = input.color(color.lime, "لون EMA 2", group=group_ema)

showEMA3           = input.bool(false, "إظهار EMA 3", group=group_ema)
emaLen3            = input.int(100, "طول EMA 3", minval=1, group=group_ema)
emaWidth3          = input.int(2, "سمك EMA 3", minval=1, maxval=5, group=group_ema)
emaColor3          = input.color(color.aqua, "لون EMA 3", group=group_ema)

showEMA4           = input.bool(false, "إظهار EMA 4", group=group_ema)
emaLen4            = input.int(200, "طول EMA 4", minval=1, group=group_ema)
emaWidth4          = input.int(2, "سمك EMA 4", minval=1, maxval=5, group=group_ema)
emaColor4          = input.color(color.fuchsia, "لون EMA 4", group=group_ema)

//==================================================
// الألوان
//==================================================
group_colors       = "الألوان"
demandBg           = input.color(color.new(color.green, 82), "لون الطلب", group=group_colors)
demandBorder       = input.color(color.green, "حد الطلب", group=group_colors)
supplyBg           = input.color(color.new(color.red, 82), "لون العرض", group=group_colors)
supplyBorder       = input.color(color.red, "حد العرض", group=group_colors)
bosBullColor       = input.color(color.new(color.green, 0), "لون BOS الصاعد", group=group_colors)
bosBearColor       = input.color(color.new(color.red, 0), "لون BOS الهابط", group=group_colors)
rangeBgColor       = input.color(color.new(color.orange, 90), "لون خلفية الرينج", group=group_colors)
bullBgColor        = input.color(color.new(color.green, 90), "لون خلفية الترند الصاعد", group=group_colors)
bearBgColor        = input.color(color.new(color.red, 90), "لون خلفية الترند الهابط", group=group_colors)

//==================================================
// الحسابات
//==================================================
atr  = ta.atr(atrLen)
ema1 = ta.ema(close, emaLen1)
ema2 = ta.ema(close, emaLen2)
ema3 = ta.ema(close, emaLen3)
ema4 = ta.ema(close, emaLen4)

plot(showEMA1 ? ema1 : na, title="EMA 1", color=emaColor1, linewidth=emaWidth1)
plot(showEMA2 ? ema2 : na, title="EMA 2", color=emaColor2, linewidth=emaWidth2)
plot(showEMA3 ? ema3 : na, title="EMA 3", color=emaColor3, linewidth=emaWidth3)
plot(showEMA4 ? ema4 : na, title="EMA 4", color=emaColor4, linewidth=emaWidth4)

selectedTrendEMA = trendFilterOnEMA == 1 ? ema1 : trendFilterOnEMA == 2 ? ema2 : trendFilterOnEMA == 3 ? ema3 : ema4
selectedEntryEMA = entryFilterOnEMA == 1 ? ema1 : entryFilterOnEMA == 2 ? ema2 : entryFilterOnEMA == 3 ? ema3 : ema4

//==================================================
// ADX وحالة السوق
//==================================================
[plusDI, minusDI, adx] = ta.dmi(adxLen, adxLen)
emaSlope = ema2 - ema2[5]

isTrend = adx > adxTrendLevel
isBullTrend = isTrend and emaSlope > 0
isBearTrend = isTrend and emaSlope < 0
isRange = not isTrend

bgcolor(useSmartMode and showMarketStateBg ? (isRange ? rangeBgColor : isBullTrend ? bullBgColor : bearBgColor) : na)

//==================================================
// ضبط ذكي للفلاتر
//==================================================
smartUseRetest = useSmartMode ? (isRange ? true : smartLevel == "قوي" ? true : useRetest) : useRetest
smartUseCandleConfirm = useSmartMode ? (isRange ? true : smartLevel == "قوي" ? true : useCandleConfirm) : useCandleConfirm
smartUseSignalDelay = useSmartMode ? (isRange ? true : smartLevel == "قوي" ? true : useSignalDelay) : useSignalDelay
smartSignalDelayBars = useSmartMode ? (isRange ? math.max(signalDelayBars, 1) : signalDelayBars) : signalDelayBars
smartUseStrongBosClose = useSmartMode ? (isRange ? true : smartLevel == "قوي" ? true : useStrongBosClose) : useStrongBosClose
smartBosCloseBufferATR = useSmartMode ? (isRange ? math.max(bosCloseBufferATR, 0.05) : bosCloseBufferATR) : bosCloseBufferATR

//==================================================
// التخزين الداخلي للمناطق
//==================================================
var float[] demandTops   = array.new_float()
var float[] demandBots   = array.new_float()
var int[]   demandLefts  = array.new_int()

var float[] supplyTops   = array.new_float()
var float[] supplyBots   = array.new_float()
var int[]   supplyLefts  = array.new_int()

//==================================================
// العناصر الظاهرة فقط
//==================================================
var box demandBox        = na
var box supplyBox        = na
var label demandMidLabel = na
var label supplyMidLabel = na

//==================================================
// عناصر BOS
//==================================================
var float lastSwingHigh    = na
var float lastSwingLow     = na
var int   lastSwingHighBar = na
var int   lastSwingLowBar  = na
var line  lastBullBosLine  = na
var line  lastBearBosLine  = na
var label lastBullBosLabel = na
var label lastBearBosLabel = na
var int   lastBosDir       = 0

//==================================================
// تتبع Retest
//==================================================
var int firstDemandTouchBar = na
var int firstSupplyTouchBar = na
var int demandExitBar       = na
var int supplyExitBar       = na

//==================================================
// دوال مساعدة
//==================================================
f_trim(_tops, _bots, _lefts, _max) =>
    while array.size(_tops) > _max
        array.shift(_tops)
        array.shift(_bots)
        array.shift(_lefts)

f_far_enough(_price, _arr, _minDist) =>
    bool ok = true
    if array.size(_arr) > 0
        for i = 0 to array.size(_arr) - 1
            prev = array.get(_arr, i)
            if math.abs(_price - prev) < _minDist
                ok := false
    ok

f_find_nearest_demand() =>
    int idx = na
    float minDist = 10000000000.0
    if array.size(demandTops) > 0
        for i = 0 to array.size(demandTops) - 1
            topV = array.get(demandTops, i)
            if topV <= close
                dist = close - topV
                if dist < minDist
                    minDist := dist
                    idx := i
    idx

f_find_nearest_supply() =>
    int idx = na
    float minDist = 10000000000.0
    if array.size(supplyBots) > 0
        for i = 0 to array.size(supplyBots) - 1
            botV = array.get(supplyBots, i)
            if botV >= close
                dist = botV - close
                if dist < minDist
                    minDist := dist
                    idx := i
    idx

//==================================================
// اكتشاف المناطق الذكية
//==================================================
canCalc = bar_index > baseBars + impulseCheckBars + 5 and not na(atr[baseBars])

if canCalc
    baseIdx = baseBars
    leftBar = bar_index - baseIdx
    bHigh = high[baseIdx]
    bLow = low[baseIdx]
    bOpen = open[baseIdx]
    bClose = close[baseIdx]
    bRange = bHigh - bLow

    highestAfterBase = ta.highest(high, impulseCheckBars)
    lowestAfterBase = ta.lowest(low, impulseCheckBars)

    demandImpulse = (highestAfterBase - bHigh) > (atr[baseIdx] * impulseMult)
    supplyImpulse = (bLow - lowestAfterBase) > (atr[baseIdx] * impulseMult)

    demandBaseCandle = (bClose <= bOpen) or (bRange < atr[baseIdx] * 0.8)
    supplyBaseCandle = (bClose >= bOpen) or (bRange < atr[baseIdx] * 0.8)

    trendOkDemand = not useTrendFilter or close > selectedTrendEMA
    trendOkSupply = not useTrendFilter or close < selectedTrendEMA

    farDemand = f_far_enough(bHigh, demandTops, atr * minDistanceATR)
    farSupply = f_far_enough(bHigh, supplyTops, atr * minDistanceATR)

    if demandBaseCandle and demandImpulse and trendOkDemand and farDemand
        zoneTop = bHigh
        zoneBot = bLow - atr[baseIdx] * zonePaddingATR
        if zoneTop > zoneBot
            array.push(demandTops, zoneTop)
            array.push(demandBots, zoneBot)
            array.push(demandLefts, leftBar)
            f_trim(demandTops, demandBots, demandLefts, maxStoredZones)

    if supplyBaseCandle and supplyImpulse and trendOkSupply and farSupply
        zoneTop = bHigh + atr[baseIdx] * zonePaddingATR
        zoneBot = bLow
        if zoneTop > zoneBot
            array.push(supplyTops, zoneTop)
            array.push(supplyBots, zoneBot)
            array.push(supplyLefts, leftBar)
            f_trim(supplyTops, supplyBots, supplyLefts, maxStoredZones)

//==================================================
// حذف المناطق المكسورة
//==================================================
if array.size(demandTops) > 0
    int i = array.size(demandTops) - 1
    while i >= 0
        botV = array.get(demandBots, i)
        broken = breakOnClose ? close < botV : low < botV
        if deleteBroken and broken
            array.remove(demandTops, i)
            array.remove(demandBots, i)
            array.remove(demandLefts, i)
        i := i - 1

if array.size(supplyTops) > 0
    int j = array.size(supplyTops) - 1
    while j >= 0
        topV = array.get(supplyTops, j)
        broken = breakOnClose ? close > topV : high > topV
        if deleteBroken and broken
            array.remove(supplyTops, j)
            array.remove(supplyBots, j)
            array.remove(supplyLefts, j)
        j := j - 1

//==================================================
// أقرب طلب وأقرب عرض
//==================================================
nearestDemand = f_find_nearest_demand()
nearestSupply = f_find_nearest_supply()

demandTopNow = not na(nearestDemand) ? array.get(demandTops, nearestDemand) : na
demandBotNow = not na(nearestDemand) ? array.get(demandBots, nearestDemand) : na
supplyTopNow = not na(nearestSupply) ? array.get(supplyTops, nearestSupply) : na
supplyBotNow = not na(nearestSupply) ? array.get(supplyBots, nearestSupply) : na

//==================================================
// رسم أقرب طلب
//==================================================
if not na(nearestDemand)
    dTop = array.get(demandTops, nearestDemand)
    dBot = array.get(demandBots, nearestDemand)
    dLeft = array.get(demandLefts, nearestDemand)
    dRight = bar_index + extendBars
    dMidX = int(math.floor((dLeft + dRight) / 2.0))
    dMidY = (dTop + dBot) / 2.0

    if na(demandBox)
        demandBox := box.new(left=dLeft, top=dTop, right=dRight, bottom=dBot, bgcolor=demandBg, border_color=demandBorder)
    else
        box.set_left(demandBox, dLeft)
        box.set_right(demandBox, dRight)
        box.set_top(demandBox, dTop)
        box.set_bottom(demandBox, dBot)
        box.set_bgcolor(demandBox, demandBg)
        box.set_border_color(demandBox, demandBorder)

    if not na(demandMidLabel)
        label.delete(demandMidLabel)
    demandMidLabel := showZoneText ? label.new(x=dMidX, y=dMidY, text=demandText, style=label.style_none, textcolor=color.white, size=size.normal) : na
else
    if not na(demandBox)
        box.delete(demandBox)
        demandBox := na
    if not na(demandMidLabel)
        label.delete(demandMidLabel)
        demandMidLabel := na

//==================================================
// رسم أقرب عرض
//==================================================
if not na(nearestSupply)
    sTop = array.get(supplyTops, nearestSupply)
    sBot = array.get(supplyBots, nearestSupply)
    sLeft = array.get(supplyLefts, nearestSupply)
    sRight = bar_index + extendBars
    sMidX = int(math.floor((sLeft + sRight) / 2.0))
    sMidY = (sTop + sBot) / 2.0

    if na(supplyBox)
        supplyBox := box.new(left=sLeft, top=sTop, right=sRight, bottom=sBot, bgcolor=supplyBg, border_color=supplyBorder)
    else
        box.set_left(supplyBox, sLeft)
        box.set_right(supplyBox, sRight)
        box.set_top(supplyBox, sTop)
        box.set_bottom(supplyBox, sBot)
        box.set_bgcolor(supplyBox, supplyBg)
        box.set_border_color(supplyBox, supplyBorder)

    if not na(supplyMidLabel)
        label.delete(supplyMidLabel)
    supplyMidLabel := showZoneText ? label.new(x=sMidX, y=sMidY, text=supplyText, style=label.style_none, textcolor=color.white, size=size.normal) : na
else
    if not na(supplyBox)
        box.delete(supplyBox)
        supplyBox := na
    if not na(supplyMidLabel)
        label.delete(supplyMidLabel)
        supplyMidLabel := na

//==================================================
// BOS
//==================================================
bosPivotHigh = ta.pivothigh(high, bosLeft, bosRight)
bosPivotLow = ta.pivotlow(low, bosLeft, bosRight)

if not na(bosPivotHigh)
    lastSwingHigh := high[bosRight]
    lastSwingHighBar := bar_index - bosRight

if not na(bosPivotLow)
    lastSwingLow := low[bosRight]
    lastSwingLowBar := bar_index - bosRight

bullBosRaw = showBOS and not na(lastSwingHigh) and close > lastSwingHigh and close[1] <= lastSwingHigh
bearBosRaw = showBOS and not na(lastSwingLow) and close < lastSwingLow and close[1] >= lastSwingLow

bullBos = bullBosRaw and (not smartUseStrongBosClose or close > lastSwingHigh + atr * smartBosCloseBufferATR)
bearBos = bearBosRaw and (not smartUseStrongBosClose or close < lastSwingLow - atr * smartBosCloseBufferATR)

if bullBos
    lastBosDir := 1
    if keepLastBOSOnly
        if not na(lastBullBosLine)
            line.delete(lastBullBosLine)
        if not na(lastBullBosLabel)
            label.delete(lastBullBosLabel)
    if showBOSLines
        lastBullBosLine := line.new(x1=lastSwingHighBar, y1=lastSwingHigh, x2=bar_index, y2=lastSwingHigh, color=bosBullColor, width=2, style=line.style_dashed)
    if showBOSLabels
        lastBullBosLabel := label.new(x=bar_index, y=lastSwingHigh, text="BOS ↑", style=label.style_label_up, color=bosBullColor, textcolor=color.white, size=size.small)

if bearBos
    lastBosDir := -1
    if keepLastBOSOnly
        if not na(lastBearBosLine)
            line.delete(lastBearBosLine)
        if not na(lastBearBosLabel)
            label.delete(lastBearBosLabel)
    if showBOSLines
        lastBearBosLine := line.new(x1=lastSwingLowBar, y1=lastSwingLow, x2=bar_index, y2=lastSwingLow, color=bosBearColor, width=2, style=line.style_dashed)
    if showBOSLabels
        lastBearBosLabel := label.new(x=bar_index, y=lastSwingLow, text="BOS ↓", style=label.style_label_down, color=bosBearColor, textcolor=color.white, size=size.small)

//==================================================
// منطق الدخول داخل المنطقة
//==================================================
inDemand = not na(demandTopNow) and low <= demandTopNow and high >= demandBotNow
inSupply = not na(supplyTopNow) and high >= supplyBotNow and low <= supplyTopNow

closeInsideDemand = not na(demandTopNow) and close <= demandTopNow and close >= demandBotNow
closeInsideSupply = not na(supplyTopNow) and close <= supplyTopNow and close >= supplyBotNow

baseBuyZoneCond = (entryOnTouch and inDemand) or (entryOnCloseIn and closeInsideDemand)
baseSellZoneCond = (entryOnTouch and inSupply) or (entryOnCloseIn and closeInsideSupply)

buyTouchEvent = baseBuyZoneCond and not baseBuyZoneCond[1]
sellTouchEvent = baseSellZoneCond and not baseSellZoneCond[1]

//==================================================
// تتبع Retest
//==================================================
if buyTouchEvent and na(firstDemandTouchBar)
    firstDemandTouchBar := bar_index

if sellTouchEvent and na(firstSupplyTouchBar)
    firstSupplyTouchBar := bar_index

if not na(firstDemandTouchBar) and not inDemand and na(demandExitBar)
    demandExitBar := bar_index

if not na(firstSupplyTouchBar) and not inSupply and na(supplyExitBar)
    supplyExitBar := bar_index

demandRetestEvent = not na(firstDemandTouchBar) and not na(demandExitBar) and inDemand and bar_index > demandExitBar + retestDelayBars and bar_index - firstDemandTouchBar <= retestLookbackBars
supplyRetestEvent = not na(firstSupplyTouchBar) and not na(supplyExitBar) and inSupply and bar_index > supplyExitBar + retestDelayBars and bar_index - firstSupplyTouchBar <= retestLookbackBars

if demandRetestEvent
    firstDemandTouchBar := na
    demandExitBar := na

if supplyRetestEvent
    firstSupplyTouchBar := na
    supplyExitBar := na

if na(demandTopNow)
    firstDemandTouchBar := na
    demandExitBar := na

if na(supplyTopNow)
    firstSupplyTouchBar := na
    supplyExitBar := na

buyRetestOk = not smartUseRetest or demandRetestEvent or (not useRetest and baseBuyZoneCond)
sellRetestOk = not smartUseRetest or supplyRetestEvent or (not useRetest and baseSellZoneCond)

//==================================================
// تأكيد الشموع
//==================================================
bullConfirmStrong = close > open and close > close[1]
bearConfirmStrong = close < open and close < close[1]
bullConfirmSimple = close > open
bearConfirmSimple = close < open

buyCandleOk = not smartUseCandleConfirm or (candleMode == "ابتلاع/استمرار" ? bullConfirmStrong : bullConfirmSimple)
sellCandleOk = not smartUseCandleConfirm or (candleMode == "ابتلاع/استمرار" ? bearConfirmStrong : bearConfirmSimple)

//==================================================
// Delay للإشارة
//==================================================
buyDelayOk = not smartUseSignalDelay or ta.barssince(demandRetestEvent) >= smartSignalDelayBars
sellDelayOk = not smartUseSignalDelay or ta.barssince(supplyRetestEvent) >= smartSignalDelayBars

//==================================================
// الفلاتر النهائية
//==================================================
buyBosOk = not useBOSFilterEntry or lastBosDir == 1
sellBosOk = not useBOSFilterEntry or lastBosDir == -1

buyEmaOk = not useEMAFilterEntry or close > selectedEntryEMA
sellEmaOk = not useEMAFilterEntry or close < selectedEntryEMA

buySignal = showEntries and baseBuyZoneCond and buyBosOk and buyEmaOk and buyRetestOk and buyCandleOk and buyDelayOk
sellSignal = showEntries and baseSellZoneCond and sellBosOk and sellEmaOk and sellRetestOk and sellCandleOk and sellDelayOk

plotshape(buySignal, title="إشارة شراء", text="شراء", style=shape.labelup, location=location.belowbar, color=buySignalColor, textcolor=color.white, size=size.small)
plotshape(sellSignal, title="إشارة بيع", text="بيع", style=shape.labeldown, location=location.abovebar, color=sellSignalColor, textcolor=color.white, size=size.small)
````

# HSS Main: SR + LongShort Mode

- url: https://www.tradingview.com/script/E0MRcSkM/
- type: indicator
- pine_id: PUB;0d64e1c6b8cd44b783b9b657096228c4
- version: 1.0

## Description

个人测试

## Source Code

````pine
//@version=6
indicator("HSS Main: SR + LongShort Mode", shorttitle="HSS_MAIN_SR_LS_MODE", overlay=true, max_boxes_count=40, max_labels_count=300, max_lines_count=100)

//====================================================
// 参数
//====================================================
groupTrend = "趋势过滤"
emaFastLen  = input.int(10,  "EMA快线", minval=1, group=groupTrend)
emaSlowLen  = input.int(30,  "EMA慢线", minval=1, group=groupTrend)
emaLongLen  = input.int(200, "EMA长线", minval=1, group=groupTrend)

groupPivot = "支撑压力识别"
pivotLeft   = input.int(3,  "Pivot左侧", minval=1, group=groupPivot)
pivotRight  = input.int(3,  "Pivot右侧", minval=1, group=groupPivot)
majorGap    = input.int(18, "同类区最小间隔K数", minval=1, group=groupPivot)
atrLen      = input.int(14, "ATR长度", minval=1, group=groupPivot)
pivotAtrMul = input.float(0.50, "Pivot有效性ATR过滤", minval=0.05, step=0.05, group=groupPivot)

groupZone = "红绿柱体"
resZoneATRTop   = input.float(0.03, "红柱上沿ATR", minval=0.01, step=0.01, group=groupZone)
resZoneATRBot   = input.float(0.30, "红柱下沿ATR", minval=0.05, step=0.01, group=groupZone)
supZoneATRTop   = input.float(0.26, "绿柱上沿ATR", minval=0.05, step=0.01, group=groupZone)
supZoneATRBot   = input.float(0.02, "绿柱下沿ATR", minval=0.01, step=0.01, group=groupZone)
zoneExtendBars  = input.int(180, "柱体向右延伸K数", minval=10, group=groupZone)
keepResZones    = input.int(3, "保留红柱数量", minval=1, maxval=5, group=groupZone)
keepSupZones    = input.int(2, "保留绿柱数量", minval=1, maxval=5, group=groupZone)
zoneBreakATR    = input.float(0.12, "区失效阈值ATR", minval=0.01, step=0.01, group=groupZone)

groupSignal = "多空提醒"
signalMode      = input.string("均衡", "信号模式", options=["激进", "均衡", "保守"], group=groupSignal)
needZoneConfirm = input.bool(true, "多空必须结合红绿柱", group=groupSignal)
showLongText    = input.bool(true, "显示多", group=groupSignal)
showShortText   = input.bool(true, "显示空", group=groupSignal)

groupDisplay = "显示"
showEMA = input.bool(true, "显示EMA", group=groupDisplay)

//====================================================
// 模式参数
//====================================================
signalCooldown = signalMode == "激进" ? 8 : signalMode == "均衡" ? 12 : 18
retestLookback = signalMode == "激进" ? 14 : signalMode == "均衡" ? 10 : 7
confirmBars    = signalMode == "激进" ? 1 : signalMode == "均衡" ? 2 : 3
bodyRatioNeed  = signalMode == "激进" ? 0.20 : signalMode == "均衡" ? 0.35 : 0.50
zoneTolerance  = signalMode == "激进" ? 0.25 : signalMode == "均衡" ? 0.15 : 0.08

//====================================================
// 基础数据
//====================================================
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
emaLong = ta.ema(close, emaLongLen)
atrv    = ta.atr(atrLen)

plot(showEMA ? emaFast : na, "EMA10", color=color.new(color.lime, 0), linewidth=2)
plot(showEMA ? emaSlow : na, "EMA30", color=color.new(color.red, 0), linewidth=2)
plot(showEMA ? emaLong : na, "EMA200", color=color.new(color.aqua, 55), linewidth=3)

//====================================================
// Pivot
//====================================================
ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low, pivotLeft, pivotRight)

phBar = bar_index - pivotRight
plBar = bar_index - pivotRight

isPH = not na(ph)
isPL = not na(pl)

//====================================================
// 有效高低点过滤
//====================================================
phValidBase = isPH and (((ph - emaSlow[pivotRight]) >= atrv[pivotRight] * pivotAtrMul) or (ph > emaLong[pivotRight]))
plValidBase = isPL and (((emaFast[pivotRight] - pl) >= atrv[pivotRight] * pivotAtrMul) or (math.abs(pl - emaLong[pivotRight]) <= atrv[pivotRight] * 0.9))

//====================================================
// 区数组
//====================================================
var box[] resBoxes = array.new_box()
var float[] resTopA = array.new_float()
var float[] resBotA = array.new_float()
var int[] resBarA = array.new_int()

var box[] supBoxes = array.new_box()
var float[] supTopA = array.new_float()
var float[] supBotA = array.new_float()
var int[] supBarA = array.new_int()

//====================================================
// 函数
//====================================================
f_is_close_to_existing(_price, _bars, _priceArrTop, _priceArrBot, _barArr, _gapBars, _atr) =>
    bool hit = false
    if array.size(_barArr) > 0
        for i = 0 to array.size(_barArr) - 1
            oldBar = array.get(_barArr, i)
            oldTop = array.get(_priceArrTop, i)
            oldBot = array.get(_priceArrBot, i)
            oldMid = (oldTop + oldBot) * 0.5
            if (math.abs(_bars - oldBar) < _gapBars) or (math.abs(_price - oldMid) <= _atr * 0.9)
                hit := true
    hit

f_add_res_zone(_bar, _price, _atr) =>
    zTop = _price + _atr * resZoneATRTop
    zBot = _price - _atr * resZoneATRBot
    bx = box.new(left=_bar, top=zTop, right=_bar + zoneExtendBars, bottom=zBot, bgcolor=color.new(color.rgb(210, 70, 70), 42), border_color=color.new(color.rgb(235, 110, 110), 18), border_width=1)
    array.unshift(resBoxes, bx)
    array.unshift(resTopA, zTop)
    array.unshift(resBotA, zBot)
    array.unshift(resBarA, _bar)
    if array.size(resBoxes) > 10
        old = array.pop(resBoxes)
        box.delete(old)
        array.pop(resTopA)
        array.pop(resBotA)
        array.pop(resBarA)

f_add_sup_zone(_bar, _price, _atr) =>
    zTop = _price + _atr * supZoneATRTop
    zBot = _price - _atr * supZoneATRBot
    bx = box.new(left=_bar, top=zTop, right=_bar + zoneExtendBars, bottom=zBot, bgcolor=color.new(color.rgb(70, 185, 70), 46), border_color=color.new(color.rgb(120, 225, 120), 22), border_width=1)
    array.unshift(supBoxes, bx)
    array.unshift(supTopA, zTop)
    array.unshift(supBotA, zBot)
    array.unshift(supBarA, _bar)
    if array.size(supBoxes) > 10
        old = array.pop(supBoxes)
        box.delete(old)
        array.pop(supTopA)
        array.pop(supBotA)
        array.pop(supBarA)

f_delete_res(_idx) =>
    bx = array.get(resBoxes, _idx)
    box.delete(bx)
    array.remove(resBoxes, _idx)
    array.remove(resTopA, _idx)
    array.remove(resBotA, _idx)
    array.remove(resBarA, _idx)

f_delete_sup(_idx) =>
    bx = array.get(supBoxes, _idx)
    box.delete(bx)
    array.remove(supBoxes, _idx)
    array.remove(supTopA, _idx)
    array.remove(supBotA, _idx)
    array.remove(supBarA, _idx)

//====================================================
// 新区生成
//====================================================
newResOk = phValidBase and not f_is_close_to_existing(ph, phBar, resTopA, resBotA, resBarA, majorGap, atrv[pivotRight])
newSupOk = plValidBase and not f_is_close_to_existing(pl, plBar, supTopA, supBotA, supBarA, majorGap, atrv[pivotRight])

if newResOk
    f_add_res_zone(phBar, ph, atrv[pivotRight])

if newSupOk
    f_add_sup_zone(plBar, pl, atrv[pivotRight])

//====================================================
// 动态更新右边界
//====================================================
if array.size(resBoxes) > 0
    for i = 0 to array.size(resBoxes) - 1
        box.set_right(array.get(resBoxes, i), bar_index + zoneExtendBars)

if array.size(supBoxes) > 0
    for i = 0 to array.size(supBoxes) - 1
        box.set_right(array.get(supBoxes, i), bar_index + zoneExtendBars)

//====================================================
// 失效区删除
//====================================================
if array.size(resBoxes) > 0
    for i = array.size(resBoxes) - 1 to 0
        rt = array.get(resTopA, i)
        if close > rt + atrv * zoneBreakATR
            f_delete_res(i)

if array.size(supBoxes) > 0
    for i = array.size(supBoxes) - 1 to 0
        sb = array.get(supBotA, i)
        if close < sb - atrv * zoneBreakATR
            f_delete_sup(i)

//====================================================
// 只保留当前价上方最近几个红区 / 下方最近几个绿区
//====================================================
if array.size(resBoxes) > 0
    for i = array.size(resBoxes) - 1 to 0
        rb = array.get(resBotA, i)
        if rb < close - atrv * 0.15
            f_delete_res(i)

if array.size(supBoxes) > 0
    for i = array.size(supBoxes) - 1 to 0
        st = array.get(supTopA, i)
        if st > close + atrv * 0.15
            f_delete_sup(i)

while array.size(resBoxes) > keepResZones
    f_delete_res(array.size(resBoxes) - 1)

while array.size(supBoxes) > keepSupZones
    f_delete_sup(array.size(supBoxes) - 1)

//====================================================
// 最新红绿区
//====================================================
float latestResTop = na
float latestResBot = na
float latestSupTop = na
float latestSupBot = na
bool nearRes = false
bool nearSup = false

if array.size(resTopA) > 0
    latestResTop := array.get(resTopA, 0)
    latestResBot := array.get(resBotA, 0)
    nearRes := high >= latestResBot and low <= latestResTop

if array.size(supTopA) > 0
    latestSupTop := array.get(supTopA, 0)
    latestSupBot := array.get(supBotA, 0)
    nearSup := high >= latestSupBot and low <= latestSupTop

//====================================================
// 多空提醒逻辑
//====================================================
trendLong = (emaFast > emaSlow) and (close >= emaLong * 0.995)
trendShort = (emaFast < emaSlow) or (close < emaLong)

fastUp = emaFast > emaFast[1]
slowUp = emaSlow >= emaSlow[1]
fastDn = emaFast < emaFast[1]
slowDn = emaSlow <= emaSlow[1]

closeAboveFastBars = ta.barssince(close <= emaFast) >= (confirmBars - 1)
closeBelowFastBars = ta.barssince(close >= emaFast) >= (confirmBars - 1)
closeAboveSlowBars = ta.barssince(close <= emaSlow) >= (confirmBars - 1)
closeBelowSlowBars = ta.barssince(close >= emaSlow) >= (confirmBars - 1)

bodyRange = math.max(high - low, syminfo.mintick)
bullBodyStrong = close > open and ((close - open) / bodyRange >= bodyRatioNeed)
bearBodyStrong = close < open and ((open - close) / bodyRange >= bodyRatioNeed)

bullBounce = (close > open) and (close > emaFast) and ((low <= emaFast) or (low <= emaSlow)) and (close > high[1]) and bullBodyStrong
bearReject = (close < open) and (close < emaFast) and ((high >= emaFast) or (high >= emaSlow)) and (close < low[1]) and bearBodyStrong

fromRecentBottom = (not na(ta.barssince(newSupOk))) and (ta.barssince(newSupOk) <= retestLookback)
fromRecentTop = (not na(ta.barssince(newResOk))) and (ta.barssince(newResOk) <= retestLookback)

longTrendOk = trendLong and fastUp and slowUp and closeAboveFastBars and closeAboveSlowBars
shortTrendOk = trendShort and fastDn and slowDn and closeBelowFastBars and closeBelowSlowBars

longZoneOk = needZoneConfirm ? (nearSup or ((not na(latestSupTop)) and (low >= latestSupBot) and (low <= latestSupTop + atrv * zoneTolerance))) : true
shortZoneOk = needZoneConfirm ? (nearRes or ((not na(latestResBot)) and (high <= latestResTop) and (high >= latestResBot - atrv * zoneTolerance))) : true

longRaw = ((longTrendOk and longZoneOk and bullBounce and (close >= nz(latestSupTop, close))) or (longTrendOk and fromRecentBottom and (close > high[1]) and (low >= nz(latestSupBot, low))))
shortRaw = ((shortTrendOk and shortZoneOk and bearReject and (close <= nz(latestResBot, close))) or (shortTrendOk and fromRecentTop and (close < low[1]) and (high <= nz(latestResTop, high) + atrv * 0.08)))

var int lastLongBar = na
var int lastShortBar = na

longSignal = longRaw and (na(lastLongBar) or (bar_index - lastLongBar > signalCooldown))
shortSignal = shortRaw and (na(lastShortBar) or (bar_index - lastShortBar > signalCooldown))

if longSignal
    lastLongBar := bar_index
if shortSignal
    lastShortBar := bar_index

if showLongText and longSignal
    label.new(bar_index, low - atrv * 0.12, "多", style=label.style_label_up, textcolor=color.white, color=color.new(color.green, 0), size=size.small)

if showShortText and shortSignal
    label.new(bar_index, high + atrv * 0.12, "空", style=label.style_label_down, textcolor=color.white, color=color.new(color.red, 0), size=size.small)

alertcondition(longSignal, "多信号", "出现多信号")
alertcondition(shortSignal, "空信号", "出现空信号")
````

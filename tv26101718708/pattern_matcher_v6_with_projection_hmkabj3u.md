# Pattern Matcher v6 - With Projection

- url: https://www.tradingview.com/script/hmKabj3u-Pattern-Matcher-v6-With-Projection/
- type: indicator
- pine_id: PUB;29cc46c574d042af8c283b71dffe2c62
- version: 1.0

## Description

This script is matching the chart for previous intervals and gives the conclusion for the future path works with all time frames and u have to set the settings as it suits u

## Source Code

````pine
//@version=6
indicator("Pattern Matcher v6 - With Projection", overlay=true, max_bars_back=2000)

// ─── الإعدادات ───
grp1 = "إعدادات النمط"
patternLen = input.int(20, "طول النمط (شمعات)", minval=5, maxval=50, group=grp1)
projectLen = input.int(20, "طول التوقع (شمعات للأمام)", minval=5, maxval=50, group=grp1)

grp2 = "نطاق البحث"
searchMode = input.string("شهر", "وضع البحث", options=["شهر", "شهرين", "3 أشهر", "6 أشهر", "مخصص"], group=grp2)
customBars = input.int(200, "عدد شمعات مخصص", minval=50, maxval=2000, group=grp2)

grp3 = "العرض"
showBg1    = input.bool(true,  "تظليل التطابق #1 🟢", group=grp3)
showBg2    = input.bool(true,  "تظليل التطابق #2 🟠", group=grp3)
showBg3    = input.bool(false, "تظليل التطابق #3 🟣", group=grp3)
showProj1  = input.bool(true,  "توقع #1 (أخضر)", group=grp3)
showProj2  = input.bool(true,  "توقع #2 (برتقالي)", group=grp3)
showProj3  = input.bool(false, "توقع #3 (بنفسجي)", group=grp3)
showTable  = input.bool(true,  "إظهار الجدول", group=grp3)

// ─── حساب عمق البحث ───
barsPerMonth() =>
    int(30 * 24 * 3600 / timeframe.in_seconds())

getLookback() =>
    bpm = barsPerMonth()
    switch searchMode
        "شهر"    => bpm * 1
        "شهرين"  => bpm * 2
        "3 أشهر" => bpm * 3
        "6 أشهر" => bpm * 6
        "مخصص"   => customBars
        => bpm

lookback = math.min(getLookback(), 1990)

// ─── المسافة الإقليدية ───
calcDistance(offset, len) =>
    dist = 0.0
    basecurr = close[len - 1]
    basehist = close[offset + len - 1]
    if basecurr == 0.0 or basehist == 0.0
        dist := 999.0
    else
        for i = 0 to len - 1
            curr = (close[i]          - basecurr) / basecurr
            hist = (close[i + offset] - basehist) / basehist
            dist += math.pow(curr - hist, 2)
        dist := math.sqrt(dist / len)
    dist

// ─── البحث عن أفضل 3 تطابقات ───
var int   bestOffset1 = na
var int   bestOffset2 = na
var int   bestOffset3 = na
var float bestDist1   = na
var float bestDist2   = na
var float bestDist3   = na

if barstate.islast
    d1 = 999.0
    d2 = 999.0
    d3 = 999.0
    o1 = 0
    o2 = 0
    o3 = 0
    for offset = patternLen + 1 to lookback
        d = calcDistance(offset, patternLen)
        if d < d1 and d > 0.0001
            d3 := d2, o3 := o2
            d2 := d1, o2 := o1
            d1 := d,  o1 := offset
        else if d < d2 and d > 0.0001 and math.abs(offset - o1) > patternLen
            d3 := d2, o3 := o2
            d2 := d,  o2 := offset
        else if d < d3 and d > 0.0001 and math.abs(offset - o1) > patternLen and math.abs(offset - o2) > patternLen
            d3 := d,  o3 := offset
    bestOffset1 := o1, bestDist1 := d1
    bestOffset2 := o2, bestDist2 := d2
    bestOffset3 := o3, bestDist3 := d3

// ─── رسم خطوط التوقع بـ lines ───
// نحذف الخطوط القديمة عند كل تحديث
var line[] projLines = array.new<line>()

deleteOldLines() =>
    if array.size(projLines) > 0
        for i = 0 to array.size(projLines) - 1
            line.delete(array.get(projLines, i))
        array.clear(projLines)

drawProjection(offset, len, projLen, col) =>
    if not na(offset) and offset > 0
        anchorPrice = close[0]  // آخر سعر حالي
        histBase    = close[offset - 1]  // السعر عند نهاية التطابق التاريخي
        if histBase != 0.0
            prevX = last_bar_index
            prevY = anchorPrice
            for i = 1 to projLen
                histPrice = close[offset - 1 - i]
                projPrice = anchorPrice * (histPrice / histBase)
                ln = line.new(
                     x1=prevX, y1=prevY,
                     x2=last_bar_index + i, y2=projPrice,
                     color=col, width=2,
                     extend=extend.none, style=line.style_solid)
                array.push(projLines, ln)
                prevX := last_bar_index + i
                prevY := projPrice

if barstate.islast
    deleteOldLines()
    if showProj1 and not na(bestOffset1)
        drawProjection(bestOffset1, patternLen, projectLen, color.new(color.green, 0))
    if showProj2 and not na(bestOffset2)
        drawProjection(bestOffset2, patternLen, projectLen, color.new(color.orange, 0))
    if showProj3 and not na(bestOffset3)
        drawProjection(bestOffset3, patternLen, projectLen, color.new(color.purple, 0))

// ─── تظليل الفترات المتشابهة ───
isCurrentPattern = bar_index >= last_bar_index - patternLen + 1
bgcolor(isCurrentPattern ? color.new(color.blue, 80) : na, title="النمط الحالي")

isBestMatch1 = showBg1 and not na(bestOffset1) and
     bar_index >= last_bar_index - bestOffset1 - patternLen + 1 and
     bar_index <= last_bar_index - bestOffset1
bgcolor(isBestMatch1 ? color.new(color.green, 75) : na, title="تطابق #1")

isBestMatch2 = showBg2 and not na(bestOffset2) and
     bar_index >= last_bar_index - bestOffset2 - patternLen + 1 and
     bar_index <= last_bar_index - bestOffset2
bgcolor(isBestMatch2 ? color.new(color.orange, 78) : na, title="تطابق #2")

isBestMatch3 = showBg3 and not na(bestOffset3) and
     bar_index >= last_bar_index - bestOffset3 - patternLen + 1 and
     bar_index <= last_bar_index - bestOffset3
bgcolor(isBestMatch3 ? color.new(color.purple, 78) : na, title="تطابق #3")

// ─── علامات بداية التطابقات ───
isStart1 = showBg1 and not na(bestOffset1) and bar_index == last_bar_index - bestOffset1 - patternLen + 1
isStart2 = showBg2 and not na(bestOffset2) and bar_index == last_bar_index - bestOffset2 - patternLen + 1
isStart3 = showBg3 and not na(bestOffset3) and bar_index == last_bar_index - bestOffset3 - patternLen + 1

plotshape(isStart1, style=shape.labelup, location=location.belowbar, color=color.green,  text="#1", textcolor=color.white, size=size.small)
plotshape(isStart2, style=shape.labelup, location=location.belowbar, color=color.orange, text="#2", textcolor=color.white, size=size.small)
plotshape(isStart3, style=shape.labelup, location=location.belowbar, color=color.purple, text="#3", textcolor=color.white, size=size.small)

// ─── خط فاصل عمودي عند نهاية البيانات الحالية ───
if barstate.islast
    line.new(x1=last_bar_index, y1=low * 0.995,
             x2=last_bar_index, y2=high * 1.005,
             color=color.new(color.white, 40), width=1, style=line.style_dashed)

// ─── جدول النتائج ───
var table t = table.new(position.top_right, 2, 7,
     bgcolor=color.new(color.black, 60),
     border_color=color.new(color.gray, 50), border_width=1,
     frame_color=color.new(color.gray, 40), frame_width=1)

if barstate.islast and showTable
    table.cell(t, 0, 0, "Pattern Matcher v6", text_color=color.white,  text_size=size.normal, bgcolor=color.new(color.navy, 35))
    table.cell(t, 1, 0, searchMode,           text_color=color.yellow, text_size=size.normal, bgcolor=color.new(color.navy, 35))
    table.cell(t, 0, 1, "نطاق البحث",  text_color=color.silver, text_size=size.small)
    table.cell(t, 1, 1, str.tostring(lookback) + " شمعة", text_color=color.white, text_size=size.small)
    table.cell(t, 0, 2, "طول التوقع",  text_color=color.silver, text_size=size.small)
    table.cell(t, 1, 2, str.tostring(projectLen) + " شمعة للأمام", text_color=color.white, text_size=size.small)
    table.cell(t, 0, 3, "🟢 تطابق #1", text_color=color.green,  text_size=size.small)
    table.cell(t, 1, 3, not na(bestDist1) and bestDist1 < 999 ? str.tostring(math.round(bestDist1, 5)) : "---", text_color=color.green,  text_size=size.small)
    table.cell(t, 0, 4, "🟠 تطابق #2", text_color=color.orange, text_size=size.small)
    table.cell(t, 1, 4, not na(bestDist2) and bestDist2 < 999 ? str.tostring(math.round(bestDist2, 5)) : "---", text_color=color.orange, text_size=size.small)
    table.cell(t, 0, 5, "🟣 تطابق #3", text_color=color.purple, text_size=size.small)
    table.cell(t, 1, 5, not na(bestDist3) and bestDist3 < 999 ? str.tostring(math.round(bestDist3, 5)) : "---", text_color=color.purple, text_size=size.small)
    table.cell(t, 0, 6, "🔵 النمط الحالي", text_color=color.blue, text_size=size.small)
    table.cell(t, 1, 6, str.tostring(patternLen) + " شمعة", text_color=color.blue, text_size=size.small)
````

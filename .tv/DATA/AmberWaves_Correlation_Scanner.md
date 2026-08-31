<!-- tradingview-pine-id: PUB;fed9073d55284e65ac67700bb5dba9f5 -->
<!-- tradingviewscripts-format: 1 -->
# AmberWaves Correlation Scanner

Source: https://www.tradingview.com/script/iVJBRyOK-AmberWaves-Correlation-Scanner/

## Description

This indicator is not really a trading indicator as much as a research indicator. You know how on X you'll see someone posing as a trader, and they say, "just use this one candle" to take your positions? This indicator will test that one candle. 

For any ticker and timeframe (for the timezone your chart is set to), go into settings and select the start time of the candle to which you want to compare every other candle. So if you want to see which candle is most correlated to the closing candle on the 10 min. tf, and you are in Chicago, you would set the Candle A time to 14:50.

The indicator will tell you which the top 5 best correlated and top 5 best reverse correlated candles are. If you ever find a candle that's over 80%, please thank me for this indicator by messaging me with that information!

If the table stays blank, it's because you put a starting candle time that doesn't work with the tf you have selected on your chart. For example if you set Candle A to 14:55, but you selected 10min for the timeframe, the table won't populate.

---

## Source Code

````pine
//@version=6
indicator("AmberWaves Correlation Scanner", overlay=false, max_labels_count=500)

//=====================
// Inputs
//=====================
tz = input.string("America/Chicago", "Time Zone", options=[
     "America/Chicago",
     "America/New_York",
     "America/Los_Angeles",
     "Etc/UTC"
])

targetHour   = input.int(14, "Candle A Hour", minval=0, maxval=23)
targetMinute = input.int(55, "Candle A Minute", minval=0, maxval=59)
minSamples   = input.int(20, "Minimum days required per slot", minval=5)
showTable    = input.bool(true, "Show results table")

//=====================
// Time / slot setup
//=====================
tfSeconds   = timeframe.in_seconds(timeframe.period)
slotsPerDay = tfSeconds > 0 ? int(86400 / tfSeconds) : 1
targetSlot  = int((targetHour * 60 + targetMinute) * 60 / tfSeconds)

yy = year(time, tz)
mo = month(time, tz)
dd = dayofmonth(time, tz)
hh = hour(time, tz)
mm = minute(time, tz)

dayId   = yy * 10000 + mo * 100 + dd
minsNow = hh * 60 + mm
slotIdx = int((minsNow * 60) / tfSeconds)

isTimeA  = hh == targetHour and mm == targetMinute
isNewDay = ta.change(dayId) != 0

ret = open != 0 ? (close - open) / open : na

//=====================
// Persistent accumulators (per slot)
//=====================
var array<float> sumX  = array.new_float(slotsPerDay, 0.0)
var array<float> sumY  = array.new_float(slotsPerDay, 0.0)
var array<float> sumXY = array.new_float(slotsPerDay, 0.0)
var array<float> sumX2 = array.new_float(slotsPerDay, 0.0)
var array<float> sumY2 = array.new_float(slotsPerDay, 0.0)
var array<int>   cnt   = array.new_int(slotsPerDay, 0)

var array<float> todaySlot = array.new_float(slotsPerDay, na)
var float dirA  = na
var bool  seenA = false

//=====================
// Finalize a completed day into the accumulators
//=====================
finalizeDay() =>
    if seenA
        for i = 0 to slotsPerDay - 1
            x = array.get(todaySlot, i)
            if not na(x)
                y = dirA
                array.set(sumX,  i, array.get(sumX,  i) + x)
                array.set(sumY,  i, array.get(sumY,  i) + y)
                array.set(sumXY, i, array.get(sumXY, i) + x * y)
                array.set(sumX2, i, array.get(sumX2, i) + x * x)
                array.set(sumY2, i, array.get(sumY2, i) + y * y)
                array.set(cnt,   i, array.get(cnt,   i) + 1)

//=====================
// Day rollover
//=====================
if isNewDay
    finalizeDay()
    todaySlot := array.new_float(slotsPerDay, na)
    dirA := na
    seenA := false

//=====================
// Record this bar's return into today's slot array
//=====================
if slotIdx >= 0 and slotIdx < slotsPerDay and not na(ret)
    array.set(todaySlot, slotIdx, ret)

if isTimeA and not na(ret)
    dirA := ret
    seenA := true

//=====================
// Convert slot index back to HH:MM for display
//=====================
slotToTime(slot) =>
    totalMinutes = int((slot * tfSeconds) / 60)
    h = int(totalMinutes / 60) % 24
    m = totalMinutes % 60
    str.tostring(h, "00") + ":" + str.tostring(m, "00")

//=====================
// Insert into a sorted top-N list (highest or lowest correlation)
//=====================
insertTop(arrCorr, arrSlot, arrN, corr, slot, n, keepHighest, maxSize) =>
    sz = array.size(arrCorr)
    pos = sz
    if sz > 0
        for i = 0 to sz - 1
            existing = array.get(arrCorr, i)
            cond = keepHighest ? corr > existing : corr < existing
            if cond
                pos := i
                break
    if pos < maxSize
        array.insert(arrCorr, pos, corr)
        array.insert(arrSlot, pos, slot)
        array.insert(arrN, pos, n)
        if array.size(arrCorr) > maxSize
            array.pop(arrCorr)
            array.pop(arrSlot)
            array.pop(arrN)

//=====================
// On the last bar, finalize the final day and scan all slots
//=====================
var array<float> topPosCorr = array.new_float(0)
var array<int>   topPosSlot = array.new_int(0)
var array<int>   topPosN    = array.new_int(0)

var array<float> topNegCorr = array.new_float(0)
var array<int>   topNegSlot = array.new_int(0)
var array<int>   topNegN    = array.new_int(0)

if barstate.islast
    finalizeDay()

    array.clear(topPosCorr)
    array.clear(topPosSlot)
    array.clear(topPosN)
    array.clear(topNegCorr)
    array.clear(topNegSlot)
    array.clear(topNegN)

    for i = 0 to slotsPerDay - 1
        n = array.get(cnt, i)
        if n >= minSamples and i != targetSlot
            sx  = array.get(sumX,  i)
            sy  = array.get(sumY,  i)
            sxy = array.get(sumXY, i)
            sx2 = array.get(sumX2, i)
            sy2 = array.get(sumY2, i)

            num = n * sxy - sx * sy
            den = math.sqrt((n * sx2 - sx * sx) * (n * sy2 - sy * sy))

            if den != 0
                corr = num / den
                insertTop(topPosCorr, topPosSlot, topPosN, corr, i, n, true, 5)
                insertTop(topNegCorr, topNegSlot, topNegN, corr, i, n, false, 5)

//=====================
// Table
//=====================
var table statsTbl = table.new(position.top_right, 3, 14, border_width=1)

if barstate.islast and showTable
    table.cell(statsTbl, 0, 0, "Rank", text_color=color.white, bgcolor=color.black)
    table.cell(statsTbl, 1, 0, "Time", text_color=color.white, bgcolor=color.black)
    table.cell(statsTbl, 2, 0, "Corr % (n)", text_color=color.white, bgcolor=color.black)

    table.cell(statsTbl, 0, 1, "Candle A:", text_color=color.yellow, bgcolor=color.rgb(25,25,25))
    table.cell(statsTbl, 1, 1, str.tostring(targetHour, "00") + ":" + str.tostring(targetMinute, "00"), text_color=color.yellow, bgcolor=color.rgb(25,25,25))
    table.cell(statsTbl, 2, 1, tz, text_color=color.yellow, bgcolor=color.rgb(25,25,25))

    table.cell(statsTbl, 0, 2, "TOP POSITIVE", text_color=color.lime, bgcolor=color.rgb(15,40,15))
    table.cell(statsTbl, 1, 2, "", bgcolor=color.rgb(15,40,15))
    table.cell(statsTbl, 2, 2, "", bgcolor=color.rgb(15,40,15))

    for i = 0 to 4
        rowIdx = 3 + i
        if i < array.size(topPosCorr)
            table.cell(statsTbl, 0, rowIdx, str.tostring(i + 1), text_color=color.white, bgcolor=color.rgb(25,25,25))
            table.cell(statsTbl, 1, rowIdx, slotToTime(array.get(topPosSlot, i)), text_color=color.lime, bgcolor=color.rgb(25,25,25))
            table.cell(statsTbl, 2, rowIdx, str.tostring(array.get(topPosCorr, i) * 100, "#.#") + "%  (n=" + str.tostring(array.get(topPosN, i)) + ")", text_color=color.white, bgcolor=color.rgb(25,25,25))
        else
            table.cell(statsTbl, 0, rowIdx, str.tostring(i + 1), text_color=color.gray, bgcolor=color.rgb(25,25,25))
            table.cell(statsTbl, 1, rowIdx, "n/a", text_color=color.gray, bgcolor=color.rgb(25,25,25))
            table.cell(statsTbl, 2, rowIdx, "", bgcolor=color.rgb(25,25,25))

    table.cell(statsTbl, 0, 8, "TOP NEGATIVE", text_color=color.red, bgcolor=color.rgb(40,15,15))
    table.cell(statsTbl, 1, 8, "", bgcolor=color.rgb(40,15,15))
    table.cell(statsTbl, 2, 8, "", bgcolor=color.rgb(40,15,15))

    for i = 0 to 4
        rowIdx = 9 + i
        if i < array.size(topNegCorr)
            table.cell(statsTbl, 0, rowIdx, str.tostring(i + 1), text_color=color.white, bgcolor=color.rgb(25,25,25))
            table.cell(statsTbl, 1, rowIdx, slotToTime(array.get(topNegSlot, i)), text_color=color.red, bgcolor=color.rgb(25,25,25))
            table.cell(statsTbl, 2, rowIdx, str.tostring(array.get(topNegCorr, i) * 100, "#.#") + "%  (n=" + str.tostring(array.get(topNegN, i)) + ")", text_color=color.white, bgcolor=color.rgb(25,25,25))
        else
            table.cell(statsTbl, 0, rowIdx, str.tostring(i + 1), text_color=color.gray, bgcolor=color.rgb(25,25,25))
            table.cell(statsTbl, 1, rowIdx, "n/a", text_color=color.gray, bgcolor=color.rgb(25,25,25))
            table.cell(statsTbl, 2, rowIdx, "", bgcolor=color.rgb(25,25,25))
````

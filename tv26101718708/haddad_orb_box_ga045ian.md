# Haddad ORB box

- url: https://www.tradingview.com/script/GA045ian-Haddad-ORB-box/
- type: indicator
- pine_id: PUB;7d76f3899ce44dcaad22e117b84ff4e7
- version: 1.0

## Description

ORB strategy 5, 15 or 30M candle NYO with lookback option

## Source Code

````pine
//@version=5
indicator("Haddad Box", overlay=true, max_boxes_count=500)

//------------------------------------------------------
// Inputs
//------------------------------------------------------

startHour      = input.int(15,  "Start time (hour)",   minval=0, maxval=23)
startMinute    = input.int(30,  "Start time (minute)", minval=0, maxval=59)

tfOption       = input.string("5", "Candle størrelse (minutter)", options=["5", "15", "30"])
tfMins         = int(str.tonumber(tfOption))

tzOption       = input.string("Europe/Copenhagen", "Tidszone", options=["Europe/Copenhagen", "Europe/London", "America/New_York", "America/Chicago", "Asia/Tokyo", "Asia/Shanghai", "Australia/Sydney", "UTC"])

lookbackOption = input.string("1 Month", "Lookback period", options=["1 Day", "1 Week", "1 Month"])
lookbackDays   = lookbackOption == "1 Day" ? 1 : lookbackOption == "1 Week" ? 7 : 30

obxColor       = input.color(color.new(color.teal, 85), "Zone farve")
showTodayOnly  = input.bool(false, "Vis kun dagens zone")
autoBalance    = input.bool(true,  "Slet zone automatisk når balanceret")
balanceMinutes = input.int(60, "Minutter i zonen efter breakout før sletning", minval=1, maxval=1440)

balanceMs  = balanceMinutes * 60 * 1000
lookbackMs = lookbackDays * 86400000

//------------------------------------------------------
// Tidszone værdier
//------------------------------------------------------

barHour   = hour(time, tzOption)
barMin    = minute(time, tzOption)
barMins   = barHour * 60 + barMin
startMins = startHour * 60 + startMinute
isWeekday = dayofweek(time, tzOption) >= dayofweek.monday and dayofweek(time, tzOption) <= dayofweek.friday

//------------------------------------------------------
// Zone vindue
//------------------------------------------------------

zoneStartMins = startMins
zoneEndMins   = startMins + tfMins

inZoneWindow = isWeekday and barMins >= zoneStartMins and barMins < zoneEndMins

isZoneStart = inZoneWindow and (not inZoneWindow[1] or dayofmonth(time, tzOption) != dayofmonth(time[1], tzOption))
isZoneEnd   = not inZoneWindow and inZoneWindow[1] and isWeekday

//------------------------------------------------------
// Arrays
//------------------------------------------------------

var box[]   obxBoxes        = array.new_box()
var int[]   obxTimes        = array.new_int()
var float[] obxHighs        = array.new_float()
var float[] obxLows         = array.new_float()
var bool[]  obxBroken       = array.new_bool()
var int[]   obxReentryTimes = array.new_int()

var float zoneHigh   = na
var float zoneLow    = na
var box   currentBox = na

//------------------------------------------------------
// Byg zonen
//------------------------------------------------------

if isZoneStart
    if not na(currentBox)
        box.delete(currentBox)
    zoneHigh   := high
    zoneLow    := low
    currentBox := box.new(bar_index, high, bar_index + 1, low, border_color=color.new(obxColor, 50), bgcolor=obxColor, extend=extend.none)

else if inZoneWindow and not na(currentBox)
    zoneHigh := math.max(zoneHigh, high)
    zoneLow  := math.min(zoneLow,  low)
    box.set_top(currentBox,    zoneHigh)
    box.set_bottom(currentBox, zoneLow)
    box.set_right(currentBox,  bar_index + 1)

//------------------------------------------------------
// Lås boks når zonen slutter
//------------------------------------------------------

if isZoneEnd and not na(currentBox)
    box.set_right(currentBox,  bar_index)
    box.set_extend(currentBox, extend.right)
    array.push(obxBoxes,        currentBox)
    array.push(obxTimes,        time)
    array.push(obxHighs,        zoneHigh)
    array.push(obxLows,         zoneLow)
    array.push(obxBroken,       false)
    array.push(obxReentryTimes, na)
    currentBox := na
    zoneHigh   := na
    zoneLow    := na

//------------------------------------------------------
// Ryd op
//------------------------------------------------------

if array.size(obxBoxes) > 0
    i = 0
    while i < array.size(obxBoxes)
        zTime    = array.get(obxTimes,        i)
        zBox     = array.get(obxBoxes,        i)
        zHigh    = array.get(obxHighs,        i)
        zLow     = array.get(obxLows,         i)
        broken   = array.get(obxBroken,       i)
        reentryT = array.get(obxReentryTimes, i)
        removeThis = false

        if time - zTime > lookbackMs
            removeThis := true
        else
            if autoBalance and time > zTime
                if not broken
                    if close > zHigh or close < zLow
                        broken := true
                        array.set(obxBroken, i, broken)
                if broken
                    inZoneNow = close <= zHigh and close >= zLow
                    if na(reentryT) and inZoneNow
                        reentryT := time
                        array.set(obxReentryTimes, i, reentryT)
                    if not na(reentryT) and inZoneNow
                        if time - reentryT >= balanceMs
                            removeThis := true
                    if not na(reentryT) and not inZoneNow
                        reentryT := na
                        array.set(obxReentryTimes, i, reentryT)

        if removeThis
            box.delete(zBox)
            array.remove(obxBoxes,        i)
            array.remove(obxTimes,        i)
            array.remove(obxHighs,        i)
            array.remove(obxLows,         i)
            array.remove(obxBroken,       i)
            array.remove(obxReentryTimes, i)
        else
            i += 1

//------------------------------------------------------
// Kun dagens zone?
//------------------------------------------------------

if showTodayOnly and array.size(obxBoxes) > 0
    today_d = dayofmonth(time, tzOption)
    today_m = month(time,      tzOption)
    today_y = year(time,       tzOption)
    for j = 0 to array.size(obxBoxes) - 1
        b      = array.get(obxBoxes, j)
        t      = array.get(obxTimes, j)
        zone_d = dayofmonth(t, tzOption)
        zone_m = month(t,      tzOption)
        zone_y = year(t,       tzOption)
        sameD  = zone_d == today_d and zone_m == today_m and zone_y == today_y
        box.set_bgcolor(b,      sameD ? obxColor                : color.new(obxColor, 100))
        box.set_border_color(b, sameD ? color.new(obxColor, 50) : color.new(obxColor, 100))
````

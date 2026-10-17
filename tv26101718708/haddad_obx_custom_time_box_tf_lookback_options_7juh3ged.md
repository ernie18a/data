# Haddad OBX Custom Time Box (TF + Lookback options)

- url: https://www.tradingview.com/script/7jUh3gEd-Haddad-OBX-Custom-Time-Box-TF-Lookback-options/
- type: indicator
- pine_id: PUB;afbe72b6b93344d4a0ff5e21e87aa3e6
- version: 2.0

## Description

It gives u the 5, 15 or 30M ORB with lookback options

## Source Code

````pine
//@version=5
indicator("OBX – Første candle efter 15:30", overlay=true, max_boxes_count=500)

//------------------------------------------------------
// Inputs
//------------------------------------------------------

startHour      = input.int(15,  "Start time (hour)",   minval=0,  maxval=23)
startMinute    = input.int(30,  "Start time (minute)", minval=0,  maxval=59)

tfOption       = input.string("5", "Candle størrelse (minutter)", options=["5", "15", "30"])
tfMins = int(str.tonumber(tfOption))
lookbackOption = input.string("1 Month", "Lookback period", options=["1 Day", "1 Week", "1 Month"])
lookbackDays   = lookbackOption == "1 Day" ? 1 : lookbackOption == "1 Week" ? 7 : 30

obxColor       = input.color(color.new(color.teal, 85), "Zone farve")
showTodayOnly  = input.bool(false, "Vis kun dagens zone")
autoBalance    = input.bool(true,  "Slet zone automatisk når balanceret")
balanceMinutes = input.int(60, "Minutter i zonen efter breakout før sletning", minval=1, maxval=1440)

balanceMs  = balanceMinutes * 60 * 1000
lookbackMs = lookbackDays * 86400000

//------------------------------------------------------
// Find første komplette candle fra valgt TF efter 15:30
// Logik: vi er på chart (fx 1m, 5m, 15m, 30m, 1h)
// Vi detekterer hvornår en candle af størrelse tfMins
// starter lige på eller efter starttime
//------------------------------------------------------

barMins    = hour * 60 + minute
startMins  = startHour * 60 + startMinute
isWeekday  = dayofweek >= dayofweek.monday and dayofweek <= dayofweek.friday

// En candle af tfMins størrelse starter når barMins er deleligt med tfMins
// OG barMins >= startMins
isTfBoundary = barMins % tfMins == 0

// Første tfMins-candle EFTER (eller præcis på) starttime denne dag
// Det er den candle hvor barMins >= startMins OG barMins % tfMins == 0
// OG den foregående bar IKKE opfyldte samme betingelse (dvs. første gang)
isFirstTfCandle = isWeekday and isTfBoundary and barMins >= startMins and not (barMins[1] >= startMins and barMins[1] % tfMins == 0 and dayofmonth == dayofmonth[1])

// Arrays til zoner
var box[]   obxBoxes        = array.new_box()
var int[]   obxTimes        = array.new_int()
var float[] obxHighs        = array.new_float()
var float[] obxLows         = array.new_float()
var bool[]  obxBroken       = array.new_bool()
var int[]   obxReentryTimes = array.new_int()

// Bygger vi en zone lige nu?
var float zoneHigh    = na
var float zoneLow     = na
var int   zoneStart   = na
var box   currentBox  = na
var int   zoneEndMins = na  // hvilken barMins skal zonen slutte

// Start en ny zone
if isFirstTfCandle
    zoneHigh    := high
    zoneLow     := low
    zoneStart   := bar_index
    zoneEndMins := barMins + tfMins
    currentBox  := box.new(zoneStart, zoneHigh, bar_index, zoneLow, border_color=color.new(obxColor, 50), bgcolor=obxColor)
    box.set_extend(currentBox, extend.right)

// Opdater zone mens den tfMins-candle kører
isInZoneBuilding = not na(currentBox) and barMins >= (zoneEndMins - tfMins) and barMins < zoneEndMins and isWeekday

if isInZoneBuilding and not isFirstTfCandle
    zoneHigh := math.max(zoneHigh, high)
    zoneLow  := math.min(zoneLow,  low)
    if not na(currentBox)
        box.set_top(currentBox,    zoneHigh)
        box.set_bottom(currentBox, zoneLow)
        box.set_right(currentBox,  bar_index)

// Lås zonen når den tfMins-candle er slut
isZoneDone = not na(currentBox) and barMins >= zoneEndMins

if isZoneDone
    array.push(obxBoxes,        currentBox)
    array.push(obxTimes,        time)
    array.push(obxHighs,        zoneHigh)
    array.push(obxLows,         zoneLow)
    array.push(obxBroken,       false)
    array.push(obxReentryTimes, na)
    currentBox  := na
    zoneHigh    := na
    zoneLow     := na
    zoneStart   := na
    zoneEndMins := na

//------------------------------------------------------
// Ryd op: gamle + balancerede zoner
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
    today_d = dayofmonth(time)
    today_m = month(time)
    today_y = year(time)

    for j = 0 to array.size(obxBoxes) - 1
        b       = array.get(obxBoxes, j)
        t       = array.get(obxTimes, j)
        zone_d  = dayofmonth(t)
        zone_m  = month(t)
        zone_y  = year(t)
        sameDay = zone_d == today_d and zone_m == today_m and zone_y == today_y

        box.set_bgcolor(b,      sameDay ? obxColor                : color.new(obxColor, 100))
        box.set_border_color(b, sameDay ? color.new(obxColor, 50) : color.new(obxColor, 100))
````

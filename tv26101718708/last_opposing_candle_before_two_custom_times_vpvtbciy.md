# Last Opposing Candle Before Two Custom Times

- url: https://www.tradingview.com/script/vPvTBcIy-Last-Opposing-Candle-Before-Two-Custom-Times/
- type: indicator
- pine_id: PUB;6157a5902220437895a05968706fd499
- version: 1.0

## Description

This indicator is designed to identify the last opposing candle before a major custom trigger time, helping traders locate potential institutional reaction zones before key market movements occur. By default, the indicator tracks two important times — 4:00 AM and 9:27 AM New York time — and automatically highlights the final candle that moved against the immediate directional sequence leading into those times.

The indicator works by analyzing the candle flow prior to each trigger time and locating the last opposing candle before momentum formed. Once identified, the candle is boxed and color-coded with separate customizable brilliant color themes for each trigger time, allowing traders to visually distinguish between the overnight/pre-market setup and the regular market open setup.

One of the primary benefits of this tool is its ability to help traders identify:

potential liquidity zones
reversal areas
mitigation blocks
institutional order flow regions
reaction points after market open or pre-market expansion

The indicator also keeps the highlighted zones active after the trigger occurs, allowing traders to monitor when price revisits those areas later in the session. Built-in alert conditions notify the trader whenever price returns to one of the opposing candle zones.

Key Features:

Dual customizable trigger times
Default 4:00 AM and 9:27 AM logic
Independent brilliant color schemes for each trigger
Adjustable minimum candle sequence logic
Persistent reaction zones
Alert functionality for price revisits
Highly visual institutional-style zone mapping
Fully customizable appearance and transparency settings

This indicator is especially useful for:

opening range traders
liquidity sweep traders
smart money concepts (SMC) traders
reversal traders
pre-market structure analysis
session transition analysis
day traders looking for high-probability reaction zones

## Source Code

````pine
//@version=5
indicator("Last Opposing Candle Before Two Custom Times", overlay=true, max_boxes_count=500, max_labels_count=500, max_bars_back=1000)

tzInput = input.string("America/New_York", "Timezone")

//──────────────────────────────────────────────────────────────────────────────
// Trigger Time 1
//──────────────────────────────────────────────────────────────────────────────
group1 = "Trigger Time 1 - Default 4:00 AM"

triggerHour1 = input.int(4, "Trigger 1 Hour", minval=0, maxval=23, group=group1)
triggerMinute1 = input.int(0, "Trigger 1 Minute", minval=0, maxval=59, group=group1)

colorPreset1 = input.string("Electric Blue", "Trigger 1 Color Preset", options=["Deep Black", "Electric Blue", "Neon Purple", "Lime Green", "Hot Pink", "Bright Yellow", "Deep Red", "Aqua Cyan", "Orange Flame", "Custom"], group=group1)
customColor1 = input.color(color.rgb(0, 85, 255), "Trigger 1 Custom Color", group=group1)
trigger1Transparency = input.int(35, "Trigger 1 Box Transparency", minval=0, maxval=100, group=group1)

//──────────────────────────────────────────────────────────────────────────────
// Trigger Time 2
//──────────────────────────────────────────────────────────────────────────────
group2 = "Trigger Time 2 - Default 9:27 AM"

triggerHour2 = input.int(9, "Trigger 2 Hour", minval=0, maxval=23, group=group2)
triggerMinute2 = input.int(27, "Trigger 2 Minute", minval=0, maxval=59, group=group2)

colorPreset2 = input.string("Neon Purple", "Trigger 2 Color Preset", options=["Deep Black", "Electric Blue", "Neon Purple", "Lime Green", "Hot Pink", "Bright Yellow", "Deep Red", "Aqua Cyan", "Orange Flame", "Custom"], group=group2)
customColor2 = input.color(color.rgb(160, 0, 255), "Trigger 2 Custom Color", group=group2)
trigger2Transparency = input.int(35, "Trigger 2 Box Transparency", minval=0, maxval=100, group=group2)

//──────────────────────────────────────────────────────────────────────────────
// General Inputs
//──────────────────────────────────────────────────────────────────────────────
minSequenceCandles = input.int(1, "Minimum Same-Color Candles Into Trigger Time", minval=1, maxval=20)
searchBackCandles = input.int(100, "Candles Back To Search", minval=10, maxval=500)

showLabels = input.bool(true, "Show Labels")
showAlertZone = input.bool(true, "Keep Zones Active")

borderWidth = input.int(3, "Border Width", minval=1, maxval=5)

//──────────────────────────────────────────────────────────────────────────────
// Brilliant Color Preset Function
//──────────────────────────────────────────────────────────────────────────────
getPresetColor(_preset, _custom) =>
    _preset == "Deep Black" ? color.black :
     _preset == "Electric Blue" ? color.rgb(0, 85, 255) :
     _preset == "Neon Purple" ? color.rgb(160, 0, 255) :
     _preset == "Lime Green" ? color.rgb(0, 255, 0) :
     _preset == "Hot Pink" ? color.rgb(255, 0, 170) :
     _preset == "Bright Yellow" ? color.rgb(255, 230, 0) :
     _preset == "Deep Red" ? color.rgb(180, 0, 0) :
     _preset == "Aqua Cyan" ? color.rgb(0, 255, 255) :
     _preset == "Orange Flame" ? color.rgb(255, 115, 0) :
     _custom

trigger1Color = getPresetColor(colorPreset1, customColor1)
trigger2Color = getPresetColor(colorPreset2, customColor2)

//──────────────────────────────────────────────────────────────────────────────
// Day Tracking
//──────────────────────────────────────────────────────────────────────────────
dayKey = year(time, tzInput) * 10000 + month(time, tzInput) * 100 + dayofmonth(time, tzInput)

var int lastProcessedDay = na

var bool processedTrigger1 = false
var bool processedTrigger2 = false

var float activeZoneHigh1 = na
var float activeZoneLow1 = na

var float activeZoneHigh2 = na
var float activeZoneLow2 = na

if na(lastProcessedDay) or dayKey != lastProcessedDay
    processedTrigger1 := false
    processedTrigger2 := false

    activeZoneHigh1 := na
    activeZoneLow1 := na

    activeZoneHigh2 := na
    activeZoneLow2 := na

    lastProcessedDay := dayKey

//──────────────────────────────────────────────────────────────────────────────
// Trigger Timestamps
//──────────────────────────────────────────────────────────────────────────────
triggerTS1 = timestamp(tzInput, year(time, tzInput), month(time, tzInput), dayofmonth(time, tzInput), triggerHour1, triggerMinute1)
triggerTS2 = timestamp(tzInput, year(time, tzInput), month(time, tzInput), dayofmonth(time, tzInput), triggerHour2, triggerMinute2)

//──────────────────────────────────────────────────────────────────────────────
// Function
//──────────────────────────────────────────────────────────────────────────────
findOpposingCandle(_triggerTS, _hour, _minute, _labelName, _zoneColor, _zoneTransparency) =>
    float zoneHigh = na
    float zoneLow = na

    int lastPreTrigger = na
    int seqDir = 0

    for i = 0 to searchBackCandles
        candleDir = close[i] > open[i] ? 1 : close[i] < open[i] ? -1 : 0

        if na(lastPreTrigger) and time_close[i] <= _triggerTS and candleDir != 0
            lastPreTrigger := i
            seqDir := candleDir

    int seqCount = 0
    int firstSeqIndex = na

    if not na(lastPreTrigger) and seqDir != 0
        for j = lastPreTrigger to searchBackCandles
            candleDirJ = close[j] > open[j] ? 1 : close[j] < open[j] ? -1 : 0

            if candleDirJ == seqDir
                seqCount += 1
                firstSeqIndex := j
            else
                break

    if seqCount >= minSequenceCandles and not na(firstSeqIndex)
        oppIndex = firstSeqIndex + 1

        if oppIndex <= searchBackCandles
            oppDir = close[oppIndex] > open[oppIndex] ? 1 : close[oppIndex] < open[oppIndex] ? -1 : 0

            if oppDir == -seqDir
                box.new(left=time[oppIndex], right=time_close[oppIndex], top=high[oppIndex], bottom=low[oppIndex], xloc=xloc.bar_time, bgcolor=color.new(_zoneColor, _zoneTransparency), border_color=_zoneColor, border_width=borderWidth)

                zoneHigh := high[oppIndex]
                zoneLow := low[oppIndex]

                if showLabels
                    labelText = _labelName + "\n" + str.tostring(_hour) + ":" + str.tostring(_minute, "00")
                    label.new(x=time[oppIndex], y=high[oppIndex], xloc=xloc.bar_time, text=labelText, style=label.style_label_down, color=_zoneColor, textcolor=color.white, size=size.small)

    [zoneHigh, zoneLow]

//──────────────────────────────────────────────────────────────────────────────
// Trigger 1 Processing
//──────────────────────────────────────────────────────────────────────────────
if not processedTrigger1 and time >= triggerTS1
    [zHigh1, zLow1] = findOpposingCandle(triggerTS1, triggerHour1, triggerMinute1, "4:00 AM Opposing Candle", trigger1Color, trigger1Transparency)

    if not na(zHigh1)
        activeZoneHigh1 := zHigh1
        activeZoneLow1 := zLow1

    processedTrigger1 := true

//──────────────────────────────────────────────────────────────────────────────
// Trigger 2 Processing
//──────────────────────────────────────────────────────────────────────────────
if not processedTrigger2 and time >= triggerTS2
    [zHigh2, zLow2] = findOpposingCandle(triggerTS2, triggerHour2, triggerMinute2, "9:27 AM Opposing Candle", trigger2Color, trigger2Transparency)

    if not na(zHigh2)
        activeZoneHigh2 := zHigh2
        activeZoneLow2 := zLow2

    processedTrigger2 := true

//──────────────────────────────────────────────────────────────────────────────
// Alert Logic
//──────────────────────────────────────────────────────────────────────────────
priceReturnedToZone1 = showAlertZone and not na(activeZoneHigh1) and not na(activeZoneLow1) and time > triggerTS1 and high >= activeZoneLow1 and low <= activeZoneHigh1
priceReturnedToZone2 = showAlertZone and not na(activeZoneHigh2) and not na(activeZoneLow2) and time > triggerTS2 and high >= activeZoneLow2 and low <= activeZoneHigh2

alertcondition(priceReturnedToZone1, title="Returned To 4:00 AM Zone", message="Price returned to the 4:00 AM opposing candle zone.")
alertcondition(priceReturnedToZone2, title="Returned To 9:27 AM Zone", message="Price returned to the 9:27 AM opposing candle zone.")
````

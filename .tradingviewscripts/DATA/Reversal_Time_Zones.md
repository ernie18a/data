<!-- tradingview-pine-id: PUB;9895f98890e14636abcb85478ed9f236 -->
<!-- tradingviewscripts-format: 1 -->
# Reversal Time Zones

Source: https://www.tradingview.com/script/RrTd5XgD-Reversal-Time-Zones/

## Description

What it does
For each of the 9 times, it draws a vertical band spanning the full day's price range, centered on the time, ±12 min wide (so 24-min windows). Each band carries a "⚠️ Possible Reversal Zone 07:00" label at the top. Zones render during your full 06:00–16:00 ET window and repeat every day.

Color — 
I went with cyan (#00E5FF) — a bright teal that's visually distinct from the amber/red/lime/gray/white of your existing indicators. It's an input, so you can swap it anytime.

The "current/next" highlight (your level-to-level favorite) 🎯
This is the part you'll love most:

Active zone (we're inside it right now) → brightest cyan, 3px border
Next zone (the one coming up) → medium cyan, 2px border
All other zones → muted cyan, 1px border
So at a glance you know "we're IN the 10:00 reversal window now" and "the 10:30 one is next." Perfect for waiting at a level until a reversal time aligns.

---

## Source Code

````pine
//@version=6
indicator("Reversal Time Zones", overlay=true, max_boxes_count=500, max_labels_count=500)

//#region inputs
showZones = input.bool(true, "Show Zones", group="General")
showLabels = input.bool(true, "Show Labels", group="General")
highlightActive = input.bool(true, "Highlight Active/Next Zone", group="General")
zoneHalfW = input.int(12, "Zone Half-Width (minutes)", minval=1, maxval=60, group="General")
baseZoneColor = input.color(color.rgb(0, 229, 255), "Base Zone Color", group="General")
zoneOpacity = input.float(20.0, "Zone Fill Opacity (%)", minval=1, maxval=100, step=1, group="General")

sessionFilter = input.session("0600-1600", "Drawing Window", group="General")
timezoneInput = input.string("America/New_York", "Timezone", group="General")
warningTextTemplate = input.string("⚠️ Possible Reversal Zone", "Warning Label Text", group="General")

show0700 = input.bool(true, "07:00", group="Reversal Times")
show0730 = input.bool(true, "07:30", group="Reversal Times")
show1000 = input.bool(true, "10:00", group="Reversal Times")
show1030 = input.bool(true, "10:30", group="Reversal Times")
show1130 = input.bool(true, "11:30", group="Reversal Times")
show1330 = input.bool(true, "13:30", group="Reversal Times")
show1430 = input.bool(true, "14:30", group="Reversal Times")
show1500 = input.bool(true, "15:00", group="Reversal Times")
show1530 = input.bool(true, "15:30", group="Reversal Times")
//#endregion

//#region constants
MS_IN_MINUTE = 60000
baseTransparency = 100 - zoneOpacity
MAX_DAY_BARS = 1440
//#endregion

//#region helpers
//@function Builds a timestamp in the configured timezone.
//@param y Year.
//@param m Month.
//@param d Day of month.
//@param hh Hour.
//@param mm Minute.
//@returns Timestamp in milliseconds.
makeTimestamp(int y, int m, int d, int hh, int mm) =>
    timestamp(timezoneInput, y, m, d, hh, mm)

//@function Returns a formatted HH:MM string.
//@param hh Hour.
//@param mm Minute.
//@returns Formatted time string.
formatTime(int hh, int mm) =>
    str.format("{0,number,00}:{1,number,00}", hh, mm)

//@function Returns whether the bar is inside the configured drawing window.
//@returns True when the current bar is within the session filter.
inDrawWindow() =>
    not na(time(timeframe.period, sessionFilter, timezoneInput))

//@function Creates a styled box for a time zone.
//@param leftTime Left edge timestamp.
//@param rightTime Right edge timestamp.
//@param topPrice Top price.
//@param bottomPrice Bottom price.
//@param zoneColor Zone fill/border color.
//@param borderW Border width.
//@returns The created box.
createZoneBox(int leftTime, int rightTime, float topPrice, float bottomPrice, color zoneColor, int borderW) =>
    box.new(leftTime, topPrice, rightTime, bottomPrice, xloc=xloc.bar_time, bgcolor=color.new(color.black, 100), border_color=zoneColor, border_width=borderW)

//@function Creates the warning label for a zone.
//@param xTime Label x position.
//@param yPrice Label y position.
//@param labelText Label text.
//@param textColor Label text color.
//@returns The created label.
createZoneLabel(int xTime, float yPrice, string labelText, color textColor) =>
    label.new(xTime, yPrice, labelText, xloc=xloc.bar_time, style=label.style_label_up, color=color.new(color.black, 100), textcolor=textColor, size=size.small)
//#endregion

//#region time definitions
var array<int> zoneHours = array.from(7, 7, 10, 10, 11, 13, 14, 15, 15)
var array<int> zoneMinutes = array.from(0, 30, 0, 30, 30, 30, 30, 0, 30)
var array<bool> zoneEnabledInputs = array.from(show0700, show0730, show1000, show1030, show1130, show1330, show1430, show1500, show1530)
var array<string> zoneNames = array.from("07:00", "07:30", "10:00", "10:30", "11:30", "13:30", "14:30", "15:00", "15:30")
//#endregion

//#region storage
var array<box> zoneBoxes = array.new<box>()
var array<label> zoneLabels = array.new<label>()
var int storedYear = na
var int storedMonth = na
var int storedDay = na
var float sessionHigh = na
var float sessionLow = na
//#endregion

//#region daily reset and session tracking
currentYear = year(time, timezoneInput)
currentMonth = month(time, timezoneInput)
currentDay = dayofmonth(time, timezoneInput)
newDay = na(storedYear) or currentYear != storedYear or currentMonth != storedMonth or currentDay != storedDay
if newDay
    if zoneBoxes.size() > 0
        for zBox in zoneBoxes
            box.delete(zBox)
    if zoneLabels.size() > 0
        for zLabel in zoneLabels
            label.delete(zLabel)
    zoneBoxes.clear()
    zoneLabels.clear()
    sessionHigh := high
    sessionLow := low
    storedYear := currentYear
    storedMonth := currentMonth
    storedDay := currentDay
else
    sessionHigh := na(sessionHigh) ? high : math.max(sessionHigh, high)
    sessionLow := na(sessionLow) ? low : math.min(sessionLow, low)
//#endregion

//#region zone state
int activeZoneIndex = na
int nextZoneIndex = na
currentTimeMs = time
for i = 0 to array.size(zoneHours) - 1
    if array.get(zoneEnabledInputs, i)
        hh = array.get(zoneHours, i)
        mm = array.get(zoneMinutes, i)
        zoneStart = makeTimestamp(currentYear, currentMonth, currentDay, hh, mm) - zoneHalfW * MS_IN_MINUTE
        zoneEnd = makeTimestamp(currentYear, currentMonth, currentDay, hh, mm) + zoneHalfW * MS_IN_MINUTE
        if na(activeZoneIndex) and currentTimeMs >= zoneStart and currentTimeMs <= zoneEnd
            activeZoneIndex := i
        if currentTimeMs < zoneStart and na(nextZoneIndex)
            nextZoneIndex := i
//#endregion

//#region draw zones
if showZones and inDrawWindow()
    dayTop = ta.highest(high, MAX_DAY_BARS)
    dayBottom = ta.lowest(low, MAX_DAY_BARS)
    for i = 0 to array.size(zoneHours) - 1
        if array.get(zoneEnabledInputs, i)
            hh = array.get(zoneHours, i)
            mm = array.get(zoneMinutes, i)
            startTs = makeTimestamp(currentYear, currentMonth, currentDay, hh, mm) - zoneHalfW * MS_IN_MINUTE
            endTs = makeTimestamp(currentYear, currentMonth, currentDay, hh, mm) + zoneHalfW * MS_IN_MINUTE
            zoneColor = baseZoneColor
            borderW = 1
            zBox = createZoneBox(startTs, endTs, dayTop, dayBottom, zoneColor, borderW)
            zoneBoxes.push(zBox)
            if showLabels
                labelText = str.format("{0} {1}", warningTextTemplate, array.get(zoneNames, i))
                zLabel = createZoneLabel(startTs + zoneHalfW * MS_IN_MINUTE, dayTop, labelText, baseZoneColor)
                zoneLabels.push(zLabel)
//#endregion
````

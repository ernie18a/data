#  v2 Retest UE / LE (EMA) Inside / Outside Retest UE / LE (EMA)

- url: https://www.tradingview.com/script/09EkU7gI-v2-Retest-UE-LE-EMA-Inside-Outside-Retest-UE-LE-EMA/
- type: indicator
- pine_id: PUB;c4d3b6e360584f2fb8144895d87849bf
- version: 1.0

## Description

Identifies Inside Bars (I) and Outside Bars (O) in real time. When a candle closes as an I or O, the indicator automatically plots breakout levels at High + offset and Low − offset of the setup candle. Horizontal lines extend across the chart and display the price levels for quick reference. The latest setup replaces the previous one while historical I/O markers remain visible for review.

## Source Code

````pine
//@version=5
indicator(" v2 Retest UE / LE (EMA) Inside / Outside Retest UE / LE (EMA)", overlay=true, max_labels_count=500, max_lines_count=500)

// ===== Settings =====
lineWidth = input.int(2, "Line Width", minval=1, maxval=5)
topLineColor = input.color(color.yellow, "Top Line Color")
botLineColor = input.color(color.yellow, "Bottom Line Color")

labelBgColor = input.color(color.yellow, "Price Label Background")
labelTextColor = input.color(color.black, "Price Label Text")
labelOffsetBars = input.int(8, "Price Label Right Offset Bars", minval=1)
lineLeftBars = input.int(300, "Line Left Length (bars)", minval=10)
lineRightBars = input.int(300, "Line Right Length (bars)", minval=10)

ioLabelOffsetTicks = input.int(80, "I / O Label Offset Ticks", minval=0)
validBars = input.int(2, "Valid Retest Window Bars", minval=1)

// ===== BAR TYPE FILTER =====
barTypeFilter = input.string("Both", "Bar Type Filter", options=["Inside Only", "Outside Only", "Both"])
showInside  = barTypeFilter == "Inside Only" or barTypeFilter == "Both"
showOutside = barTypeFilter == "Outside Only" or barTypeFilter == "Both"

// ===== EMA SETTINGS =====
emaLength = input.int(25, "EMA Length")
emaColor  = input.color(color.blue, "EMA Color")
emaWidth  = input.int(2, "EMA Width")

emaValue = ta.ema(close, emaLength)
plot(emaValue, color=emaColor, linewidth=emaWidth)

// ===== SESSION SETTINGS =====
useTimeFilter = input.bool(true, "Use Time Filter")

useS1 = input.bool(true, "Session 1 ON")
s1StartH = input.int(7, "S1 Start Hour")
s1StartM = input.int(0, "S1 Start Minute")
s1EndH   = input.int(10, "S1 End Hour")
s1EndM   = input.int(0, "S1 End Minute")

useS2 = input.bool(true, "Session 2 ON")
s2StartH = input.int(15, "S2 Start Hour")
s2StartM = input.int(0, "S2 Start Minute")
s2EndH   = input.int(19, "S2 End Hour")
s2EndM   = input.int(0, "S2 End Minute")

useS3 = input.bool(true, "Session 3 ON")
s3StartH = input.int(23, "S3 Start Hour")
s3StartM = input.int(0, "S3 Start Minute")
s3EndH   = input.int(0, "S3 End Hour")
s3EndM   = input.int(0, "S3 End Minute")

// ===== TIME LOGIC =====
curH = hour(time, "GMT+8")
curM = minute(time, "GMT+8")
curTotal = curH * 60 + curM

f_inSession(startH, startM, endH, endM) =>
    startT = startH * 60 + startM
    endT   = endH * 60 + endM
    startT <= endT ? (curTotal >= startT and curTotal <= endT) : (curTotal >= startT or curTotal <= endT)

sessionAllowed =
     (useS1 and f_inSession(s1StartH, s1StartM, s1EndH, s1EndM)) or
     (useS2 and f_inSession(s2StartH, s2StartM, s2EndH, s2EndM)) or
     (useS3 and f_inSession(s3StartH, s3StartM, s3EndH, s3EndM))

timeAllowed = useTimeFilter ? sessionAllowed : true

// ===== DETECT I / O =====
liveInsideBar  = high < high[1] and low > low[1]
liveOutsideBar = high > high[1] and low < low[1]

confirmedInsideBar  = high[1] < high[2] and low[1] > low[2]
confirmedOutsideBar = high[1] > high[2] and low[1] < low[2]

confirmedSelectedInside  = showInside and confirmedInsideBar
confirmedSelectedOutside = showOutside and confirmedOutsideBar
confirmedIO = confirmedSelectedInside or confirmedSelectedOutside

// ===== VARIABLES =====
var float activeTop = na
var float activeBot = na
var int setupBarIndex = na
var string activeSetupType = ""

var bool upperArmed = false
var bool lowerArmed = false
var bool upperFired = false
var bool lowerFired = false

var line topLine = na
var line botLine = na
var label topLabel = na
var label botLabel = na

var int lastUELiveBar = na
var int lastLELiveBar = na

// ===== SHOW I / O =====
if timeAllowed and showInside and liveInsideBar
    label.new(bar_index, high + (syminfo.mintick * ioLabelOffsetTicks), "I",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_none,
         textcolor=color.blue,
         force_overlay=true)

if timeAllowed and showOutside and liveOutsideBar
    label.new(bar_index, high + (syminfo.mintick * ioLabelOffsetTicks), "O",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_none,
         textcolor=color.blue,
         force_overlay=true)

// ===== CREATE ACTUAL HIGH / LOW LEVEL =====
if confirmedIO and timeAllowed
    activeTop := high[1]
    activeBot := low[1]
    setupBarIndex := bar_index - 1
    activeSetupType := confirmedSelectedInside ? "Inside" : "Outside"

    upperArmed := false
    lowerArmed := false
    upperFired := false
    lowerFired := false
    lastUELiveBar := na
    lastLELiveBar := na

    if not na(topLine)
        line.delete(topLine)
    if not na(botLine)
        line.delete(botLine)
    if not na(topLabel)
        label.delete(topLabel)
    if not na(botLabel)
        label.delete(botLabel)

    topLine := line.new(bar_index - lineLeftBars, activeTop, bar_index + lineRightBars, activeTop,
         xloc=xloc.bar_index, color=topLineColor, width=lineWidth, force_overlay=true)

    botLine := line.new(bar_index - lineLeftBars, activeBot, bar_index + lineRightBars, activeBot,
         xloc=xloc.bar_index, color=botLineColor, width=lineWidth, force_overlay=true)

    topLabel := label.new(bar_index + labelOffsetBars, activeTop, str.tostring(activeTop, format.mintick),
         xloc=xloc.bar_index, yloc=yloc.price,
         style=label.style_label_left,
         color=labelBgColor, textcolor=labelTextColor,
         force_overlay=true)

    botLabel := label.new(bar_index + labelOffsetBars, activeBot, str.tostring(activeBot, format.mintick),
         xloc=xloc.bar_index, yloc=yloc.price,
         style=label.style_label_left,
         color=labelBgColor, textcolor=labelTextColor,
         force_overlay=true)

// ===== MOVE PRICE LABELS =====
if timeAllowed and not na(topLabel)
    label.set_x(topLabel, bar_index + labelOffsetBars)
    label.set_y(topLabel, activeTop)

if timeAllowed and not na(botLabel)
    label.set_x(botLabel, bar_index + labelOffsetBars)
    label.set_y(botLabel, activeBot)

// ===== VALID WINDOW: NEXT 2 CANDLES =====
barsFromSetup = not na(setupBarIndex) ? bar_index - setupBarIndex : na
validWindow = not na(barsFromSetup) and barsFromSetup >= 1 and barsFromSetup <= validBars

setupTypeAllowed =
     (activeSetupType == "Inside" and showInside) or
     (activeSetupType == "Outside" and showOutside)

// ===== ARMING LOGIC =====
if timeAllowed and setupTypeAllowed and validWindow and not upperFired and not na(activeTop)
    if open > activeTop and open > emaValue
        upperArmed := true

if timeAllowed and setupTypeAllowed and validWindow and not lowerFired and not na(activeBot)
    if open < activeBot and open < emaValue
        lowerArmed := true

// ===== RETEST SIGNALS =====
UE_live = timeAllowed and setupTypeAllowed and validWindow and upperArmed and not upperFired and not na(activeTop) and low <= activeTop
LE_live = timeAllowed and setupTypeAllowed and validWindow and lowerArmed and not lowerFired and not na(activeBot) and high >= activeBot

UE_confirmed = barstate.isconfirmed and UE_live
LE_confirmed = barstate.isconfirmed and LE_live

if UE_live and bar_index != lastUELiveBar
    label.new(bar_index, low, "UE",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         force_overlay=true)
    lastUELiveBar := bar_index

if LE_live and bar_index != lastLELiveBar
    label.new(bar_index, high, "LE",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         force_overlay=true)
    lastLELiveBar := bar_index

if UE_confirmed
    upperFired := true

if LE_confirmed
    lowerFired := true

// ===== CLEAN WHEN OUTSIDE SESSION =====
if not timeAllowed
    if not na(topLine)
        line.delete(topLine)
        topLine := na
    if not na(botLine)
        line.delete(botLine)
        botLine := na
    if not na(topLabel)
        label.delete(topLabel)
        topLabel := na
    if not na(botLabel)
        label.delete(botLabel)
        botLabel := na

    activeTop := na
    activeBot := na
    setupBarIndex := na
    activeSetupType := ""

    upperArmed := false
    lowerArmed := false
    upperFired := false
    lowerFired := false
    lastUELiveBar := na
    lastLELiveBar := na

// ===== ALERTS =====
alertcondition(UE_live, title="UE", message="UE live")
alertcondition(LE_live, title="LE", message="LE live")
alertcondition(UE_confirmed, title="UE Confirmed", message="UE confirmed")
alertcondition(LE_confirmed, title="LE Confirmed", message="LE confirmed")
````

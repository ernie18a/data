#  v35 Inside / Outside Bar Levels

- url: https://www.tradingview.com/script/S7COkhYS-v35-Inside-Outside-Bar-Levels/
- type: indicator
- pine_id: PUB;44a698c3d6ba4d70a45e5f6ed364a769
- version: 1.0

## Description

Identifies Inside Bars (I) and Outside Bars (O) in real time. When a candle closes as an I or O, the indicator automatically plots breakout levels at High + offset and Low − offset of the setup candle. Horizontal lines extend across the chart and display the price levels for quick reference. The latest setup replaces the previous one while historical I/O markers remain visible for review.

## Source Code

````pine
//@version=5
indicator(" v35 Inside / Outside Bar Levels", overlay=true, max_labels_count=500, max_lines_count=500)

// ===== Settings =====
offsetPoints = input.float(0.5, "Offset", step=0.1)
ioLabelOffsetTicks = input.int(80, "I / O Label Offset Ticks", minval=0)

topLineColor = input.color(color.yellow, "Top Line Color")
botLineColor = input.color(color.yellow, "Bottom Line Color")
lineWidth = input.int(2, "Line Width", minval=1, maxval=5)

labelBgColor = input.color(color.yellow, "Price Label Background")
labelTextColor = input.color(color.black, "Price Label Text")
labelOffsetBars = input.int(8, "Price Label Right Offset Bars", minval=1)
lineLeftBars = input.int(300, "Line Left Length (bars)", minval=10)
lineRightBars = input.int(300, "Line Right Length (bars)", minval=10)

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
s1StartH = input.int(7)
s1StartM = input.int(0)
s1EndH   = input.int(10)
s1EndM   = input.int(0)

useS2 = input.bool(true, "Session 2 ON")
s2StartH = input.int(15)
s2StartM = input.int(0)
s2EndH   = input.int(19)
s2EndM   = input.int(0)

useS3 = input.bool(true, "Session 3 ON")
s3StartH = input.int(23)
s3StartM = input.int(0)
s3EndH   = input.int(0)
s3EndM   = input.int(0)

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

// ===== Detect bars =====
liveInsideBar  = high < high[1] and low > low[1]
liveOutsideBar = high > high[1] and low < low[1]

confirmedInsideBar  = high[1] < high[2] and low[1] > low[2]
confirmedOutsideBar = high[1] > high[2] and low[1] < low[2]

confirmedSelectedInside  = showInside and confirmedInsideBar
confirmedSelectedOutside = showOutside and confirmedOutsideBar
confirmedIO = confirmedSelectedInside or confirmedSelectedOutside

// ===== Variables =====
var float activeTop = na
var float activeBot = na
var int setupBarIndex = na
var string activeSetupType = ""

var bool upperFired = false
var bool lowerFired = false

var line topLine = na
var line botLine = na
var label topLabel = na
var label botLabel = na

// ===== SHOW I / O USING LABELS =====
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

// ===== CREATE LEVEL =====
if confirmedIO and timeAllowed
    activeTop := high[1] + offsetPoints
    activeBot := low[1] - offsetPoints
    setupBarIndex := bar_index - 1
    activeSetupType := confirmedSelectedInside ? "Inside" : "Outside"

    upperFired := false
    lowerFired := false

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

// ===== MOVE LABELS =====
if timeAllowed and not na(topLabel)
    label.set_x(topLabel, bar_index + labelOffsetBars)
    label.set_y(topLabel, activeTop)

if timeAllowed and not na(botLabel)
    label.set_x(botLabel, bar_index + labelOffsetBars)
    label.set_y(botLabel, activeBot)

// ===== VALID WINDOW =====
barsFromSetup = not na(setupBarIndex) ? bar_index - setupBarIndex : na
validWindow = barsFromSetup == 1

setupTypeAllowed =
     (activeSetupType == "Inside" and showInside) or
     (activeSetupType == "Outside" and showOutside)

// ===== SIGNALS — CANDLE CLOSE ONLY =====
UE_condition = timeAllowed and setupTypeAllowed and validWindow and not upperFired and not na(activeTop) and high >= activeTop
LE_condition = timeAllowed and setupTypeAllowed and validWindow and not lowerFired and not na(activeBot) and low <= activeBot

UE_confirmed = barstate.isconfirmed and UE_condition
LE_confirmed = barstate.isconfirmed and LE_condition

// ===== UE / LE USING LABELS =====
if UE_confirmed
    label.new(bar_index, high, "UE",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_down,
         color=color.green,
         textcolor=color.white,
         force_overlay=true)
    upperFired := true

if LE_confirmed
    label.new(bar_index, low, "LE",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_up,
         color=color.red,
         textcolor=color.white,
         force_overlay=true)
    lowerFired := true

// ===== CLEAN =====
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

// ===== ALERTS =====
alertcondition(UE_confirmed, title="UE", message="UE confirmed")
alertcondition(LE_confirmed, title="LE", message="LE confirmed")
````

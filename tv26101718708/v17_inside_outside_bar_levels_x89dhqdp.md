#  v17 Inside / Outside Bar Levels

- url: https://www.tradingview.com/script/X89dhqdp-v17-Inside-Outside-Bar-Levels/
- type: indicator
- pine_id: PUB;8c14038af1e2449da9a5c25bb9662c6c
- version: 1.0

## Description

Inside / Outside Bar Levels based on new test. Inside bar identify smaller bar hidden within larger bar. Whereas outside bar is the opposite.

## Source Code

````pine
//@version=5
indicator(" v17 Inside / Outside Bar Levels", overlay=true, scale=scale.none)

// ===== Settings =====
offsetPoints = input.float(0.5, "Offset", step=0.1)
topLineColor = input.color(color.yellow, "Top Line Color")
botLineColor = input.color(color.yellow, "Bottom Line Color")
lineWidth = input.int(2, "Line Width", minval=1, maxval=5)

labelBgColor = input.color(color.yellow, "Price Label Background")
labelTextColor = input.color(color.black, "Price Label Text")
labelOffsetBars = input.int(8, "Price Label Right Offset Bars", minval=1)
lineLeftBars = input.int(300, "Line Left Length (bars)", minval=10)
lineRightBars = input.int(300, "Line Right Length (bars)", minval=10)

// ===== SMA SETTINGS =====
smaLength = input.int(25, "SMA Length")
smaColor  = input.color(color.blue, "SMA Color")
smaWidth  = input.int(2, "SMA Width")
smaStyleInput = input.string("Line", "SMA Style", options=["Line", "Stepline", "Cross", "Circles"])

smaStyle =
     smaStyleInput == "Stepline" ? plot.style_stepline :
     smaStyleInput == "Cross" ? plot.style_cross :
     smaStyleInput == "Circles" ? plot.style_circles :
     plot.style_line

smaValue = ta.sma(close, smaLength)
plot(smaValue, color=smaColor, linewidth=smaWidth, style=smaStyle)

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
    startT <= endT ? (curTotal >= startT and curTotal <= endT)
                   : (curTotal >= startT or curTotal <= endT)

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
confirmedIO = confirmedInsideBar or confirmedOutsideBar

// ===== Variables =====
var float activeTop = na
var float activeBot = na
var int setupBarIndex = na

var bool upperFired = false
var bool lowerFired = false

var line topLine = na
var line botLine = na
var label topLabel = na
var label botLabel = na

// ===== SHOW I / O =====
plotchar(timeAllowed and liveInsideBar, char="I", location=location.abovebar, color=color.blue, size=size.small)
plotchar(timeAllowed and liveOutsideBar, char="O", location=location.abovebar, color=color.blue, size=size.small)

// ===== CREATE LEVEL =====
if confirmedIO and timeAllowed
    activeTop := high[1] + offsetPoints
    activeBot := low[1] - offsetPoints
    setupBarIndex := bar_index - 1

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

    topLine := line.new(bar_index - lineLeftBars, activeTop, bar_index + lineRightBars, activeTop, color=topLineColor, width=lineWidth)
    botLine := line.new(bar_index - lineLeftBars, activeBot, bar_index + lineRightBars, activeBot, color=botLineColor, width=lineWidth)

    topLabel := label.new(bar_index + labelOffsetBars, activeTop, str.tostring(activeTop, format.mintick), style=label.style_label_left, color=labelBgColor, textcolor=labelTextColor)
    botLabel := label.new(bar_index + labelOffsetBars, activeBot, str.tostring(activeBot, format.mintick), style=label.style_label_left, color=labelBgColor, textcolor=labelTextColor)

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

// ===== UPDATED SIGNALS (KEY CHANGE) =====
UE_live = timeAllowed and validWindow and not upperFired and not na(activeTop) and high >= activeTop and close > smaValue and activeTop > smaValue
LE_live = timeAllowed and validWindow and not lowerFired and not na(activeBot) and low <= activeBot and close < smaValue and activeBot < smaValue

UE_confirmed = barstate.isconfirmed and UE_live
LE_confirmed = barstate.isconfirmed and LE_live

plotshape(timeAllowed and UE_live, style=shape.labelup, location=location.abovebar, text="UE", color=color.green, textcolor=color.white, size=size.tiny)
plotshape(timeAllowed and LE_live, style=shape.labeldown, location=location.belowbar, text="LE", color=color.red, textcolor=color.white, size=size.tiny)

// ===== LOCK =====
if UE_confirmed
    upperFired := true

if LE_confirmed
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

// ===== ALERTS =====
alertcondition(UE_live, title="UE", message="UE triggered")
alertcondition(LE_live, title="LE", message="LE triggered")
alertcondition(UE_confirmed, title="UE Confirmed", message="UE confirmed")
alertcondition(LE_confirmed, title="LE Confirmed", message="LE confirmed")
````

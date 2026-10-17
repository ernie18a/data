# Inside / Outside Bar Levels v9

- url: https://www.tradingview.com/script/SryXxltW-Inside-Outside-Bar-Levels-v9/
- type: indicator
- pine_id: PUB;f8b9a277f7414a46bcdb0619a394c27d
- version: 1.0

## Description

inside bar outside bar is a strategy identifying continuation

## Source Code

````pine
//@version=5
indicator("Inside / Outside Bar Levels v9", overlay=true)

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

// ===== Time Filter (GMT+8) =====
useTimeFilter = input.bool(true, "Use Time Filter (GMT+8)")
showSessionBg = input.bool(true, "Show Session Background")

sessionStartHour = input.int(8, "Session Start Hour (GMT+8)", minval=0, maxval=23)
sessionStartMin  = input.int(0, "Session Start Minute", minval=0, maxval=59)

sessionEndHour   = input.int(12, "Session End Hour (GMT+8)", minval=0, maxval=23)
sessionEndMin    = input.int(0, "Session End Minute", minval=0, maxval=59)

currentHour = hour(time, "GMT+8")
currentMin  = minute(time, "GMT+8")

startMinutes = sessionStartHour * 60 + sessionStartMin
endMinutes   = sessionEndHour * 60 + sessionEndMin
nowMinutes   = currentHour * 60 + currentMin

timeAllowed = useTimeFilter ? (nowMinutes >= startMinutes and nowMinutes <= endMinutes) : true

// ===== Session background =====
bgcolor(showSessionBg and timeAllowed ? color.new(color.gray, 88) : na, title="Session Background")

// ===== Detect live bars =====
liveInsideBar  = high < high[1] and low > low[1]
liveOutsideBar = high > high[1] and low < low[1]

// ===== Detect confirmed bars =====
confirmedInsideBar  = high[1] < high[2] and low[1] > low[2]
confirmedOutsideBar = high[1] > high[2] and low[1] < low[2]
confirmedIO = confirmedInsideBar or confirmedOutsideBar

// ===== Persistent variables =====
var float activeTop = na
var float activeBot = na
var int   setupBarIndex = na

var bool upperFired = false
var bool lowerFired = false

var line topLine = na
var line botLine = na

var label topPriceLabel = na
var label botPriceLabel = na

// ===== Live I / O marker =====
plotchar(liveInsideBar, char="I", location=location.abovebar, color=color.blue, size=size.small)
plotchar(liveOutsideBar, char="O", location=location.abovebar, color=color.blue, size=size.small)

// ===== Permanent historical labels =====
if confirmedInsideBar
    label.new(bar_index - 1, high[1], "I", style=label.style_none, textcolor=color.blue)

if confirmedOutsideBar
    label.new(bar_index - 1, high[1], "O", style=label.style_none, textcolor=color.blue)

// ===== Update levels after close =====
if confirmedIO
    activeTop := high[1] + offsetPoints
    activeBot := low[1] - offsetPoints
    setupBarIndex := bar_index - 1

    upperFired := false
    lowerFired := false

    if not na(topLine)
        line.delete(topLine)

    if not na(botLine)
        line.delete(botLine)

    if not na(topPriceLabel)
        label.delete(topPriceLabel)

    if not na(botPriceLabel)
        label.delete(botPriceLabel)

    // lines stretch both left and right
    topLine := line.new(
         x1=bar_index - lineLeftBars, y1=activeTop,
         x2=bar_index + lineRightBars, y2=activeTop,
         color=topLineColor,
         width=lineWidth)

    botLine := line.new(
         x1=bar_index - lineLeftBars, y1=activeBot,
         x2=bar_index + lineRightBars, y2=activeBot,
         color=botLineColor,
         width=lineWidth)

    // keep price labels on right side
    topPriceLabel := label.new(
         x=bar_index + labelOffsetBars,
         y=activeTop,
         text=str.tostring(activeTop, format.mintick),
         style=label.style_label_left,
         color=labelBgColor,
         textcolor=labelTextColor,
         size=size.normal)

    botPriceLabel := label.new(
         x=bar_index + labelOffsetBars,
         y=activeBot,
         text=str.tostring(activeBot, format.mintick),
         style=label.style_label_left,
         color=labelBgColor,
         textcolor=labelTextColor,
         size=size.normal)

// ===== Keep labels moving near the right side on every bar =====
if not na(topPriceLabel) and not na(activeTop)
    label.set_x(topPriceLabel, bar_index + labelOffsetBars)
    label.set_y(topPriceLabel, activeTop)

if not na(botPriceLabel) and not na(activeBot)
    label.set_x(botPriceLabel, bar_index + labelOffsetBars)
    label.set_y(botPriceLabel, activeBot)

// ===== Valid window: only next bar and next-next bar after setup =====
barsFromSetup = not na(setupBarIndex) ? (bar_index - setupBarIndex) : na
validWindow = not na(barsFromSetup) and (barsFromSetup == 1 or barsFromSetup == 2)

// ===== Live touch signals =====
UE_live = timeAllowed and validWindow and not upperFired and not na(activeTop) and high >= activeTop
LE_live = timeAllowed and validWindow and not lowerFired and not na(activeBot) and low <= activeBot

// ===== Confirmed touch signals =====
UE_confirmed = barstate.isconfirmed and UE_live
LE_confirmed = barstate.isconfirmed and LE_live

// ===== Mark signals on chart =====
plotshape(UE_live, title="UE Live", style=shape.labelup, location=location.abovebar, text="UE", color=color.green, textcolor=color.white, size=size.tiny)
plotshape(LE_live, title="LE Live", style=shape.labeldown, location=location.belowbar, text="LE", color=color.red, textcolor=color.white, size=size.tiny)

// ===== Lock one signal per side per setup after bar close =====
if UE_confirmed
    upperFired := true

if LE_confirmed
    lowerFired := true

// ===== Alert Conditions =====
alertcondition(UE_live, title="UE Live", message="UE Live: upper line touched within next 2 bars after I/O candle")
alertcondition(LE_live, title="LE Live", message="LE Live: lower line touched within next 2 bars after I/O candle")

alertcondition(UE_confirmed, title="UE Confirmed", message="UE Confirmed: upper line touched and bar closed within next 2 bars after I/O candle")
alertcondition(LE_confirmed, title="LE Confirmed", message="LE Confirmed: lower line touched and bar closed within next 2 bars after I/O candle")
````

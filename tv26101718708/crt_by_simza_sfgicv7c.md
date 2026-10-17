# CRT BY Simza

- url: https://www.tradingview.com/script/sfgicv7c-CRT-BY-Simza/
- type: indicator
- pine_id: PUB;72fa145b534646fd815b0211f30adb49
- version: 2.0

## Description

A multi-timeframe liquidity sweep detector that marks key levels from any source candle and alerts when price touches or breaks them.

## Source Code

````pine
//@version=6
indicator("CRT by Simza", overlay=true, max_lines_count=500, max_labels_count=500)

// ═════════════════════════════════════════════════════════════════════════════
// INPUTS — ALL CUSTOMIZABLE
// ═════════════════════════════════════════════════════════════════════════════

// Source
timeframe = input.timeframe("", "Source Timeframe")
lookback = input.int(1, "Source Candle Lookback", minval=1, maxval=10)

// Horizontal Line Colors
highColor = input.color(color.red, "High Line Color")
lowColor = input.color(color.red, "Low Line Color")
midColor = input.color(color.red, "50% Line Color")
openColor = input.color(color.orange, "Open Line Color")
closeColor = input.color(color.purple, "Close Line Color")

// Horizontal Line Styles
highStyle = input.string("Solid", "High Line Style", options=["Solid", "Dashed", "Dotted"])
lowStyle = input.string("Solid", "Low Line Style", options=["Solid", "Dashed", "Dotted"])
midStyle = input.string("Dashed", "50% Line Style", options=["Solid", "Dashed", "Dotted"])
openStyle = input.string("Dotted", "Open Line Style", options=["Solid", "Dashed", "Dotted"])
closeStyle = input.string("Dotted", "Close Line Style", options=["Solid", "Dashed", "Dotted"])

// Vertical Line Colors
vertStartColor = input.color(color.gray, "Vertical Start Color")
vertEndColor = input.color(color.gray, "Vertical End Color")

// Vertical Line Styles
vertStartStyle = input.string("Dotted", "Vertical Start Style", options=["Solid", "Dashed", "Dotted"])
vertEndStyle = input.string("Dotted", "Vertical End Style", options=["Solid", "Dashed", "Dotted"])

// Show/Hide
showMid = input.bool(true, "Show 50% Level")
showOpen = input.bool(true, "Show Open Level")
showClose = input.bool(true, "Show Close Level")
showVertStart = input.bool(true, "Show Vertical Start Line")
showVertEnd = input.bool(true, "Show Vertical End Line")

// Label Colors
highLabelColor = input.color(color.red, "High Label Color")
lowLabelColor = input.color(color.red, "Low Label Color")
midLabelColor = input.color(color.red, "50% Label Color")
openLabelColor = input.color(color.orange, "Open Label Color")
closeLabelColor = input.color(color.purple, "Close Label Color")

// Timer
showTimer = input.bool(true, "Show Candle Timer")
timerColor = input.color(color.white, "Timer Text Color")
timerBgColor = input.color(color.black, "Timer Background Color")

// Alerts
alertTouchHigh = input.bool(true, "Alert: Touch High")
alertTouchLow = input.bool(true, "Alert: Touch Low")
alertTouchMid = input.bool(false, "Alert: Touch 50%")

// ═════════════════════════════════════════════════════════════════════════════
// DATA
// ═════════════════════════════════════════════════════════════════════════════

[tfHigh, tfLow, tfOpen, tfClose, tfTime, tfTimeClose] = request.security(syminfo.tickerid, timeframe, 
     [high[lookback], low[lookback], open[lookback], close[lookback], time[lookback], time_close[lookback]], 
     gaps=barmerge.gaps_off)

h = tfHigh
l = tfLow
o = tfOpen
c = tfClose
m = (h + l) / 2

// ═════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═════════════════════════════════════════════════════════════════════════════

lineStyle(style) =>
    style == "Solid" ? line.style_solid : style == "Dashed" ? line.style_dashed : line.style_dotted

// ═════════════════════════════════════════════════════════════════════════════
// HORIZONTAL LINES
// ═════════════════════════════════════════════════════════════════════════════

var line highLine = na
var line lowLine = na
var line midLine = na
var line openLine = na
var line closeLine = na

if not na(h)
    line.delete(highLine)
    line.delete(lowLine)
    line.delete(midLine)
    line.delete(openLine)
    line.delete(closeLine)
    highLine := line.new(tfTime, h, time, h, xloc=xloc.bar_time, color=highColor, style=lineStyle(highStyle), extend=extend.right)
    lowLine := line.new(tfTime, l, time, l, xloc=xloc.bar_time, color=lowColor, style=lineStyle(lowStyle), extend=extend.right)
    if showMid
        midLine := line.new(tfTime, m, time, m, xloc=xloc.bar_time, color=midColor, style=lineStyle(midStyle), extend=extend.right)
    if showOpen
        openLine := line.new(tfTime, o, time, o, xloc=xloc.bar_time, color=openColor, style=lineStyle(openStyle), extend=extend.right)
    if showClose
        closeLine := line.new(tfTime, c, time, c, xloc=xloc.bar_time, color=closeColor, style=lineStyle(closeStyle), extend=extend.right)

// ═════════════════════════════════════════════════════════════════════════════
// VERTICAL LINES — START AND END OF SOURCE CANDLE
// ═════════════════════════════════════════════════════════════════════════════

var line vertStartLine = na
var line vertEndLine = na

if not na(tfTime)
    line.delete(vertStartLine)
    line.delete(vertEndLine)
    if showVertStart
        vertStartLine := line.new(tfTime, h, tfTime, l, xloc=xloc.bar_time, color=vertStartColor, style=lineStyle(vertStartStyle))
    if showVertEnd
        vertEndLine := line.new(tfTimeClose, h, tfTimeClose, l, xloc=xloc.bar_time, color=vertEndColor, style=lineStyle(vertEndStyle))

// ═════════════════════════════════════════════════════════════════════════════
// TIMER — CURRENT CANDLE COUNTDOWN
// ═════════════════════════════════════════════════════════════════════════════

remainingMs = time_close - time
remainingSec = int(remainingMs / 1000)
remainingMin = remainingSec / 60
remainingSecOnly = remainingSec % 60
timerText = str.tostring(remainingMin, "00") + ":" + str.tostring(remainingSecOnly, "00")

var table timerTable = na
if showTimer
    table.delete(timerTable)
    timerTable := table.new(position.top_right, 1, 1, bgcolor=color.new(timerBgColor, 10), 
         frame_color=color.gray, frame_width=1)
    table.cell(timerTable, 0, 0, timerText, text_color=timerColor, text_size=size.normal)

// ═════════════════════════════════════════════════════════════════════════════
// LABELS — AT CURRENT BAR, ALIGNED WITH LINES
// ═════════════════════════════════════════════════════════════════════════════

var label highLabel = na
var label lowLabel = na
var label midLabel = na
var label openLabel = na
var label closeLabel = na

if not na(h)
    label.delete(highLabel)
    label.delete(lowLabel)
    label.delete(midLabel)
    label.delete(openLabel)
    label.delete(closeLabel)
    highLabel := label.new(time, h, "HIGH", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=highLabelColor, style=label.style_none, size=size.small)
    lowLabel := label.new(time, l, "LOW", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=lowLabelColor, style=label.style_none, size=size.small)
    if showMid
        midLabel := label.new(time, m, "50%", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=midLabelColor, style=label.style_none, size=size.small)
    if showOpen
        openLabel := label.new(time, o, "OPEN", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=openLabelColor, style=label.style_none, size=size.small)
    if showClose
        closeLabel := label.new(time, c, "CLOSE", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=closeLabelColor, style=label.style_none, size=size.small)

// ═════════════════════════════════════════════════════════════════════════════
// TOUCH & ALERTS
// ═════════════════════════════════════════════════════════════════════════════

touchHigh = high >= h and low <= h and not na(h)
touchLow = low <= l and high >= l and not na(l)
touchMid = high >= m and low <= m and not na(m) and showMid

alertcondition(touchHigh and alertTouchHigh, "High Touched", "High touched at {{ticker}} {{close}}")
alertcondition(touchLow and alertTouchLow, "Low Touched", "Low touched at {{ticker}} {{close}}")
alertcondition(touchMid and alertTouchMid, "50% Touched", "50% touched at {{ticker}} {{close}}")
````

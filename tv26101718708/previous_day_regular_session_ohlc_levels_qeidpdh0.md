# Previous Day Regular Session OHLC Levels

- url: https://www.tradingview.com/script/QeIDPDH0-Previous-Day-Regular-Session-OHLC-Levels/
- type: indicator
- pine_id: PUB;1f723aa198ec428a87b533b988bb61b9
- version: 1.0

## Description

Previous Day RTH OHLC Levels

This indicator displays the most recent completed regular trading session’s Open, High, Low, and Close levels on an intraday chart.

It was built for traders who keep extended-hours data visible but still want clean reference levels from the regular session only. For U.S. equities, the default regular session is set to 09:30 to 16:00, and the default after-hours session is set to 16:00 to 20:00.

What it shows

PDH: Previous regular-session high
PDL: Previous regular-session low
PDC: Previous regular-session close
PDO: Previous regular-session open

The indicator tracks the current regular session’s OHLC values during the day. When after-hours begins, it locks those values and displays them as the prior completed regular-session levels.

Why use it

These levels can be useful as reference points for intraday context, especially when viewing premarket or after-hours price action. They can help show whether price is trading above or below the prior regular-session range, open, or close.

Settings

Regular session: default 0930-1600
After-hours session: default 1600-2000
Show or hide solid OHLC lines
Show or hide right-side labels
Adjust label offset, label size, and line width

Important notes

This is not a buy or sell signal. It does not predict direction. It simply plots prior regular-session OHLC reference levels.

For best results, use it on intraday charts with extended-hours data enabled. It is designed around U.S. equity market hours.

## Source Code

````pine
//@version=6
// Previous Day RTH OHLC Levels
// Plots the most recent completed regular-session Open, High, Low, and Close.
// Designed for intraday charts with extended-hours data enabled.
// This is a reference-level tool, not a trading signal.

indicator(
     title="Prior Day RTH OHLC - Solid Lines Stop at Labels",
     shorttitle="PD OHLC Solid Stop",
     overlay=true,
     max_labels_count=50,
     max_lines_count=20
)

// ===== Inputs =====
showLines  = input.bool(true, title="Show Solid Lines")
showLabels = input.bool(true, title="Show Right Labels")

rthSession  = input.session("0930-1600", title="Regular Session")
postSession = input.session("1600-2000", title="After-Hours Session")

rightOffset = input.int(8, title="Right Label Offset", minval=1, maxval=50)
lineWidth   = input.int(2, title="Line Width", minval=1, maxval=5)

labelSizeInput = input.string(
     "small",
     title="Label Size",
     options=["auto", "tiny", "small", "normal", "large", "huge"]
)

lSize = labelSizeInput == "auto" ? size.auto :
     labelSizeInput == "tiny" ? size.tiny :
     labelSizeInput == "small" ? size.small :
     labelSizeInput == "normal" ? size.normal :
     labelSizeInput == "large" ? size.large :
     size.huge

// ===== Colors =====
highColor  = color.red
lowColor   = color.lime
closeColor = color.yellow
openColor  = color.orange
labelBg    = color.black

// ===== Round to minimum tick =====
nround(x) =>
    math.round(x / syminfo.mintick) * syminfo.mintick

// ===== Session detection =====
inRTH  = not na(time(timeframe.period, rthSession))
inPost = not na(time(timeframe.period, postSession))

rthStart = inRTH and not inRTH[1]
afterHoursStart = inPost and not inPost[1]

// ===== Track current regular-session OHLC =====
var float curOpen  = na
var float curHigh  = na
var float curLow   = na
var float curClose = na

if rthStart
    curOpen  := open
    curHigh  := high
    curLow   := low
    curClose := close

if inRTH and not rthStart
    curHigh  := math.max(curHigh, high)
    curLow   := math.min(curLow, low)
    curClose := close

// ===== Most recent completed regular-session OHLC =====
var float pdOpen  = na
var float pdHigh  = na
var float pdLow   = na
var float pdClose = na

// ===== Solid line objects =====
var line highLine  = na
var line lowLine   = na
var line closeLine = na
var line openLine  = na

// ===== Right-side labels =====
var label highLabel  = na
var label lowLabel   = na
var label closeLabel = na
var label openLabel  = na

// ===== Lock values when after-hours starts =====
if afterHoursStart
    pdOpen  := curOpen
    pdHigh  := curHigh
    pdLow   := curLow
    pdClose := curClose

    // Delete old solid lines
    if not na(highLine)
        line.delete(highLine)
    if not na(lowLine)
        line.delete(lowLine)
    if not na(closeLine)
        line.delete(closeLine)
    if not na(openLine)
        line.delete(openLine)

    // Create new solid horizontal lines.
    // No extend.right, so the lines stop before the labels.
    if showLines
        highLine := line.new(
             x1=bar_index,
             y1=pdHigh,
             x2=bar_index + rightOffset - 1,
             y2=pdHigh,
             extend=extend.none,
             color=highColor,
             width=lineWidth
         )

        lowLine := line.new(
             x1=bar_index,
             y1=pdLow,
             x2=bar_index + rightOffset - 1,
             y2=pdLow,
             extend=extend.none,
             color=lowColor,
             width=lineWidth
         )

        closeLine := line.new(
             x1=bar_index,
             y1=pdClose,
             x2=bar_index + rightOffset - 1,
             y2=pdClose,
             extend=extend.none,
             color=closeColor,
             width=lineWidth
         )

        openLine := line.new(
             x1=bar_index,
             y1=pdOpen,
             x2=bar_index + rightOffset - 1,
             y2=pdOpen,
             extend=extend.none,
             color=openColor,
             width=lineWidth
         )

// ===== Keep line endpoints just before the right-side labels =====
if showLines and not na(pdHigh)
    if not na(highLine)
        line.set_x2(highLine, bar_index + rightOffset - 1)
        line.set_y1(highLine, pdHigh)
        line.set_y2(highLine, pdHigh)

    if not na(lowLine)
        line.set_x2(lowLine, bar_index + rightOffset - 1)
        line.set_y1(lowLine, pdLow)
        line.set_y2(lowLine, pdLow)

    if not na(closeLine)
        line.set_x2(closeLine, bar_index + rightOffset - 1)
        line.set_y1(closeLine, pdClose)
        line.set_y2(closeLine, pdClose)

    if not na(openLine)
        line.set_x2(openLine, bar_index + rightOffset - 1)
        line.set_y1(openLine, pdOpen)
        line.set_y2(openLine, pdOpen)

// ===== If lines are turned off, delete them =====
if not showLines
    if not na(highLine)
        line.delete(highLine)
        highLine := na
    if not na(lowLine)
        line.delete(lowLine)
        lowLine := na
    if not na(closeLine)
        line.delete(closeLine)
        closeLine := na
    if not na(openLine)
        line.delete(openLine)
        openLine := na

// ===== Delete and redraw right-side labels each bar =====
if not na(highLabel)
    label.delete(highLabel)
if not na(lowLabel)
    label.delete(lowLabel)
if not na(closeLabel)
    label.delete(closeLabel)
if not na(openLabel)
    label.delete(openLabel)

if showLabels and not na(pdHigh)
    highLabel := label.new(
         x=bar_index + rightOffset,
         y=pdHigh,
         text="PDH " + str.tostring(nround(pdHigh)),
         style=label.style_label_left,
         textcolor=highColor,
         color=labelBg,
         size=lSize
     )

if showLabels and not na(pdLow)
    lowLabel := label.new(
         x=bar_index + rightOffset,
         y=pdLow,
         text="PDL " + str.tostring(nround(pdLow)),
         style=label.style_label_left,
         textcolor=lowColor,
         color=labelBg,
         size=lSize
     )

if showLabels and not na(pdClose)
    closeLabel := label.new(
         x=bar_index + rightOffset,
         y=pdClose,
         text="PDC " + str.tostring(nround(pdClose)),
         style=label.style_label_left,
         textcolor=closeColor,
         color=labelBg,
         size=lSize
     )

if showLabels and not na(pdOpen)
    openLabel := label.new(
         x=bar_index + rightOffset,
         y=pdOpen,
         text="PDO " + str.tostring(nround(pdOpen)),
         style=label.style_label_left,
         textcolor=openColor,
         color=labelBg,
         size=lSize
     )
````

<!-- tradingview-pine-id: PUB;1344006f29cf4d37a439f93886745e19 -->
<!-- tradingviewscripts-format: 1 -->
# True Day Open + Asia/London High-Low + Fib

Source: https://www.tradingview.com/script/amtUeTji-True-Day-Open-Asia-London-High-Low-Fib/

## Description

True Day Market Open with both Asia and London High-Low and Fib overlay

---

## Source Code

````pine
//@version=6
indicator("True Day Open + Asia/London High-Low + Fib", overlay=true, max_lines_count=200)

// ───────────────────────────── INPUTS ─────────────────────────────
tz = input.string("America/New_York", "Timezone", tooltip="Use TradingView timezone strings, e.g. America/New_York, Europe/London, Etc/UTC")

showTDO   = input.bool(true, "Show True Day Open (00:00)", group="True Day Open")
tdoColor  = input.color(color.new(color.yellow, 0), "TDO Color", group="True Day Open")
tdoWidth  = input.int(2, "TDO Width", minval=1, group="True Day Open")
tdoStyle  = input.string("Solid", "TDO Style", options=["Solid","Dashed","Dotted"], group="True Day Open")

showAsia   = input.bool(true, "Show Asia High/Low", group="Asia Session")
asiaSess   = input.session("1900-0000", "Asia Session (NY time)", group="Asia Session")
asiaColor  = input.color(color.new(color.aqua, 0), "Asia Color", group="Asia Session")

showLondon  = input.bool(true, "Show London High/Low", group="London Session")
londonSess  = input.session("0300-0800", "London Session (NY time)", group="London Session")
londonColor = input.color(color.new(color.fuchsia, 0), "London Color", group="London Session")

lineWidth     = input.int(1, "Session Line Width", minval=1, group="Session Lines")
sessStyleStr  = input.string("Solid", "Session Line Style", options=["Solid","Dashed","Dotted"], group="Session Lines")

showFib    = input.bool(true, "Show Fibonacci Overlay", group="Fibonacci")
fibSource  = input.string("Day", "Fib Range Source", options=["Day","Asia","London"], group="Fibonacci")
fibColor   = input.color(color.new(color.orange, 0), "Fib Color", group="Fibonacci")
fibWidth   = input.int(1, "Fib Line Width", minval=1, group="Fibonacci")
showFibLabels = input.bool(true, "Show Fib Labels", group="Fibonacci")

getStyle(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

tdoLineStyle   = getStyle(tdoStyle)
sessLineStyle  = getStyle(sessStyleStr)

// ───────────────────────────── TRUE DAY OPEN ─────────────────────────────
newDay = dayofmonth(time, tz) != dayofmonth(time[1], tz)

var float tdoPrice = na
var line  tdoLine  = na

if newDay
    tdoPrice := open
    if not na(tdoLine)
        line.set_x2(tdoLine, bar_index - 1) // freeze previous day's line where it stopped
    if showTDO
        tdoLine := line.new(bar_index, tdoPrice, bar_index, tdoPrice, xloc=xloc.bar_index, color=tdoColor, width=tdoWidth, style=tdoLineStyle)

if showTDO and not na(tdoLine)
    line.set_x2(tdoLine, bar_index) // keep extending to the current wick

// ───────────────────────────── DAY HIGH / LOW (for fib "Day" source) ─────────────────────────────
var float dayHigh = na
var float dayLow  = na

if newDay
    dayHigh := high
    dayLow  := low
else
    dayHigh := math.max(dayHigh, high)
    dayLow  := math.min(dayLow, low)

// ───────────────────────────── SESSION HIGH/LOW ENGINE ─────────────────────────────
inAsia   = not na(time(timeframe.period, asiaSess, tz))
inLondon = not na(time(timeframe.period, londonSess, tz))

asiaStart   = inAsia and not inAsia[1]
londonStart = inLondon and not inLondon[1]

var float asiaHigh = na
var float asiaLow  = na
var line  asiaHighLine = na
var line  asiaLowLine  = na

var float londonHigh = na
var float londonLow  = na
var line  londonHighLine = na
var line  londonLowLine  = na

// --- Asia ---
if asiaStart
    asiaHigh := high
    asiaLow  := low
    if not na(asiaHighLine)
        line.set_x2(asiaHighLine, bar_index - 1)
        line.set_x2(asiaLowLine, bar_index - 1)
    if showAsia
        asiaHighLine := line.new(bar_index, asiaHigh, bar_index, asiaHigh, xloc=xloc.bar_index, color=asiaColor, width=lineWidth, style=sessLineStyle)
        asiaLowLine  := line.new(bar_index, asiaLow,  bar_index, asiaLow,  xloc=xloc.bar_index, color=asiaColor, width=lineWidth, style=sessLineStyle)
else if inAsia
    asiaHigh := math.max(asiaHigh, high)
    asiaLow  := math.min(asiaLow, low)

if showAsia and not na(asiaHighLine)
    if inAsia
        line.set_y1(asiaHighLine, asiaHigh)
        line.set_y2(asiaHighLine, asiaHigh)
        line.set_y1(asiaLowLine, asiaLow)
        line.set_y2(asiaLowLine, asiaLow)
    line.set_x2(asiaHighLine, bar_index) // extend to current wick, even after session ends
    line.set_x2(asiaLowLine, bar_index)

// --- London ---
if londonStart
    londonHigh := high
    londonLow  := low
    if not na(londonHighLine)
        line.set_x2(londonHighLine, bar_index - 1)
        line.set_x2(londonLowLine, bar_index - 1)
    if showLondon
        londonHighLine := line.new(bar_index, londonHigh, bar_index, londonHigh, xloc=xloc.bar_index, color=londonColor, width=lineWidth, style=sessLineStyle)
        londonLowLine  := line.new(bar_index, londonLow,  bar_index, londonLow,  xloc=xloc.bar_index, color=londonColor, width=lineWidth, style=sessLineStyle)
else if inLondon
    londonHigh := math.max(londonHigh, high)
    londonLow  := math.min(londonLow, low)

if showLondon and not na(londonHighLine)
    if inLondon
        line.set_y1(londonHighLine, londonHigh)
        line.set_y2(londonHighLine, londonHigh)
        line.set_y1(londonLowLine, londonLow)
        line.set_y2(londonLowLine, londonLow)
    line.set_x2(londonHighLine, bar_index)
    line.set_x2(londonLowLine, bar_index)

// ───────────────────────────── FIBONACCI OVERLAY ─────────────────────────────
var float[] fibLevels = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0)
var line[]  fibLines  = array.new_line(7, na)
var label[] fibLabels = array.new_label(7, na)

rangeHigh = fibSource == "Day" ? dayHigh : fibSource == "Asia" ? asiaHigh : londonHigh
rangeLow  = fibSource == "Day" ? dayLow  : fibSource == "Asia" ? asiaLow  : londonLow

rangeStart = fibSource == "Day" ? newDay : fibSource == "Asia" ? asiaStart : londonStart

if showFib and rangeStart and not na(rangeHigh) and not na(rangeLow)
    if not na(array.get(fibLines, 0))
        for i = 0 to array.size(fibLines) - 1
            line.set_x2(array.get(fibLines, i), bar_index - 1)
    for i = 0 to array.size(fibLevels) - 1
        lvl = array.get(fibLevels, i)
        price = rangeLow + (rangeHigh - rangeLow) * lvl
        newLine = line.new(bar_index, price, bar_index, price, xloc=xloc.bar_index, color=fibColor, width=fibWidth, style=line.style_dashed)
        array.set(fibLines, i, newLine)

if showFib and not na(array.get(fibLines, 0)) and not na(rangeHigh) and not na(rangeLow)
    for i = 0 to array.size(fibLevels) - 1
        lvl = array.get(fibLevels, i)
        price = rangeLow + (rangeHigh - rangeLow) * lvl
        ln = array.get(fibLines, i)
        line.set_y1(ln, price)
        line.set_y2(ln, price)
        line.set_x2(ln, bar_index)

if not showFib
    if not na(array.get(fibLines, 0))
        for i = 0 to array.size(fibLines) - 1
            line.delete(array.get(fibLines, i))
            array.set(fibLines, i, na)
            label.delete(array.get(fibLabels, i))
            array.set(fibLabels, i, na)

// ───────────────────────────── LABELS ─────────────────────────────
var label tdoLabel = na
var label asiaHighLabel = na
var label asiaLowLabel = na
var label londonHighLabel = na
var label londonLowLabel = na

if barstate.islast
    label.delete(tdoLabel)
    label.delete(asiaHighLabel)
    label.delete(asiaLowLabel)
    label.delete(londonHighLabel)
    label.delete(londonLowLabel)

    if showTDO and not na(tdoPrice)
        tdoLabel := label.new(bar_index, tdoPrice, "TDO " + str.tostring(tdoPrice, format.mintick), style=label.style_label_left, color=color.new(color.black,100), textcolor=tdoColor, size=size.small)

    if showAsia and not na(asiaHigh)
        asiaHighLabel := label.new(bar_index, asiaHigh, "Asia H", style=label.style_label_left, color=color.new(color.black,100), textcolor=asiaColor, size=size.small)
        asiaLowLabel  := label.new(bar_index, asiaLow,  "Asia L", style=label.style_label_left, color=color.new(color.black,100), textcolor=asiaColor, size=size.small)

    if showLondon and not na(londonHigh)
        londonHighLabel := label.new(bar_index, londonHigh, "London H", style=label.style_label_left, color=color.new(color.black,100), textcolor=londonColor, size=size.small)
        londonLowLabel  := label.new(bar_index, londonLow,  "London L", style=label.style_label_left, color=color.new(color.black,100), textcolor=londonColor, size=size.small)

    if showFib and showFibLabels and not na(array.get(fibLines, 0))
        for i = 0 to array.size(fibLevels) - 1
            label.delete(array.get(fibLabels, i))
            lvl = array.get(fibLevels, i)
            price = rangeLow + (rangeHigh - rangeLow) * lvl
            lbl = label.new(bar_index, price, str.tostring(lvl * 100, "#.#") + "%", style=label.style_label_left, color=color.new(color.black,100), textcolor=fibColor, size=size.small)
            array.set(fibLabels, i, lbl)
````

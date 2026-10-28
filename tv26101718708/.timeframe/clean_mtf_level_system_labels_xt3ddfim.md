# Clean MTF Level System + Labels

- url: https://www.tradingview.com/script/xT3DDFIm-Clean-MTF-Level-System-Labels/
- type: indicator
- pine_id: PUB;bc7809c42ee249469692ba84a7a3af5e
- version: 1.0

## Description

This just pulls levels of recent trends. This just pulls levels of recent trends. This just pulls levels of recent trends. This just pulls levels of recent trends. This just pulls levels of recent trends. This just pulls levels of recent trends. This just pulls levels of recent trends. This just pulls levels of recent trends. This just pulls levels of recent trends. This just pulls levels of recent trends.

## Source Code

````pine
//@version=6
indicator("Clean MTF Level System + Labels", overlay=true, max_lines_count=200, max_labels_count=200)

// Inputs
showDaily   = input.bool(true, "Show Previous Daily High/Low")
showHourly  = input.bool(true, "Show Previous Hourly High/Low")
showSession = input.bool(true, "Show Current Session High/Low")
showPivots  = input.bool(false, "Show Recent Pivot Highs/Lows")

sessionInput = input.session("0930-1600", "Regular Session")
pivotLen = input.int(5, "Pivot Strength", minval=1)
maxPivots = input.int(6, "Max Pivot Lines", minval=1, maxval=30)

// Colors
dailyColor    = color.red
hourlyColor   = color.yellow
sessionColor  = color.purple
pivotHighCol  = color.new(color.orange, 35)
pivotLowCol   = color.new(color.aqua, 35)

// Helpers
f_level_line(_line, _price, _color, _style, _width) =>
    if na(_line)
        line.new(bar_index, _price, bar_index + 1, _price, extend=extend.right, color=_color, style=_style, width=_width)
    else
        line.set_xy1(_line, bar_index, _price)
        line.set_xy2(_line, bar_index + 1, _price)
        line.set_color(_line, _color)
        line.set_style(_line, _style)
        line.set_width(_line, _width)
        _line

f_level_label(_label, _price, _text, _color) =>
    if na(_label)
        label.new(bar_index + 5, _price, _text, style=label.style_label_left, textcolor=color.white, color=_color, size=size.small)
    else
        label.set_x(_label, bar_index + 5)
        label.set_y(_label, _price)
        label.set_text(_label, _text)
        label.set_color(_label, _color)
        label.set_textcolor(_label, color.white)
        _label

// Previous Daily High/Low
pdh = request.security(syminfo.tickerid, "D", high[1])
pdl = request.security(syminfo.tickerid, "D", low[1])

var line pdhLine = na
var line pdlLine = na
var label pdhLabel = na
var label pdlLabel = na

if showDaily
    pdhLine := f_level_line(pdhLine, pdh, dailyColor, line.style_solid, 3)
    pdhLabel := f_level_label(pdhLabel, pdh, "PDH", dailyColor)

    pdlLine := f_level_line(pdlLine, pdl, dailyColor, line.style_solid, 3)
    pdlLabel := f_level_label(pdlLabel, pdl, "PDL", dailyColor)

// Previous Hourly High/Low
phh = request.security(syminfo.tickerid, "60", high[1])
phl = request.security(syminfo.tickerid, "60", low[1])

var line phhLine = na
var line phlLine = na
var label phhLabel = na
var label phlLabel = na

if showHourly and timeframe.isintraday
    phhLine := f_level_line(phhLine, phh, hourlyColor, line.style_dashed, 2)
    phhLabel := f_level_label(phhLabel, phh, "1H High", hourlyColor)

    phlLine := f_level_line(phlLine, phl, hourlyColor, line.style_dashed, 2)
    phlLabel := f_level_label(phlLabel, phl, "1H Low", hourlyColor)

// Current Session High/Low
inSession = not na(time(timeframe.period, sessionInput))
newSession = inSession and not inSession[1]

var float sessHigh = na
var float sessLow = na

if newSession
    sessHigh := high
    sessLow := low
else if inSession
    sessHigh := math.max(nz(sessHigh, high), high)
    sessLow := math.min(nz(sessLow, low), low)

var line sessHighLine = na
var line sessLowLine = na
var label sessHighLabel = na
var label sessLowLabel = na

if showSession and timeframe.isintraday and inSession
    sessHighLine := f_level_line(sessHighLine, sessHigh, sessionColor, line.style_solid, 2)
    sessHighLabel := f_level_label(sessHighLabel, sessHigh, "Session High", sessionColor)

    sessLowLine := f_level_line(sessLowLine, sessLow, sessionColor, line.style_solid, 2)
    sessLowLabel := f_level_label(sessLowLabel, sessLow, "Session Low", sessionColor)

// Recent pivots, off by default
pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow  = ta.pivotlow(low, pivotLen, pivotLen)

var line[] pivotLines = array.new_line()
var label[] pivotLabels = array.new_label()

if showPivots
    if not na(pivotHigh)
        l = line.new(bar_index - pivotLen, pivotHigh, bar_index, pivotHigh, extend=extend.right, color=pivotHighCol, style=line.style_dotted, width=1)
        lb = label.new(bar_index + 5, pivotHigh, "Swing High", style=label.style_label_left, textcolor=color.white, color=pivotHighCol, size=size.tiny)
        array.push(pivotLines, l)
        array.push(pivotLabels, lb)

    if not na(pivotLow)
        l = line.new(bar_index - pivotLen, pivotLow, bar_index, pivotLow, extend=extend.right, color=pivotLowCol, style=line.style_dotted, width=1)
        lb = label.new(bar_index + 5, pivotLow, "Swing Low", style=label.style_label_left, textcolor=color.white, color=pivotLowCol, size=size.tiny)
        array.push(pivotLines, l)
        array.push(pivotLabels, lb)

    while array.size(pivotLines) > maxPivots
        oldLine = array.shift(pivotLines)
        oldLabel = array.shift(pivotLabels)
        line.delete(oldLine)
        label.delete(oldLabel)
````

# US Session Execution Framework

- url: https://www.tradingview.com/script/pr3k4Nmj/
- type: indicator
- pine_id: PUB;c1557d1957d24f72948cba0b7385be21
- version: 2.0

## Description

skrypt przeznaczony na rynek akcji w USA  wyznaczający najwazniejsze poziomy handlu ;p

## Source Code

````pine
//@version=6
indicator('US Session Execution Framework', overlay = true, max_lines_count = 300, max_labels_count = 300)

// =====================================================
// INPUTS
// =====================================================

tz = input.string('America/New_York', 'Market timezone')

showPremarketHighLow = input.bool(true, 'Show PMH / PML')
showPreviousDayHighLow = input.bool(true, 'Show PDH / PDL')
showAHVWAP = input.bool(true, 'Show Previous After Hours VWAP')
showH5L5 = input.bool(true, 'Show H5M / L5M')

premarketSession = input.session('0400-0930', 'Premarket Session')
firstFiveSession = input.session('0930-0935', 'Opening Range 5M')
afterHoursSession = input.session('1600-2000', 'After Hours Session')

labelOffset = input.int(5, 'Label Offset', minval = 1, maxval = 100)

showPricesInLabels = input.bool(true, 'Show Prices In Labels')

levelColor = input.color(color.white, 'Levels Color')

lineWidth = input.int(1, 'Line Width', minval = 1, maxval = 4)

// =====================================================
// HELPERS
// =====================================================

formatText(name, price) =>
    showPricesInLabels ?
     name + '  ' + str.tostring(price, format.mintick) :
     name

// =====================================================
// PREVIOUS DAY HIGH / LOW
// =====================================================

previousDayHigh = request.security(
     syminfo.tickerid,
     'D',
     high[1],
     barmerge.gaps_off,
     barmerge.lookahead_off)

previousDayLow = request.security(
     syminfo.tickerid,
     'D',
     low[1],
     barmerge.gaps_off,
     barmerge.lookahead_off)

// =====================================================
// PREMARKET HIGH / LOW
// =====================================================

inPremarket = not na(
     time(
         timeframe.period,
         premarketSession,
         tz))

premarketStart =
     inPremarket and not inPremarket[1]

nyDay =
     time(
         'D',
         '0000-2359',
         tz)

newNyDay =
     ta.change(nyDay) != 0

var float premarketHigh = na
var float premarketLow = na

if newNyDay

    premarketHigh := na
    premarketLow := na

if premarketStart

    premarketHigh := high
    premarketLow := low

else if inPremarket

    premarketHigh :=
         math.max(
             nz(premarketHigh, high),
             high)

    premarketLow :=
         math.min(
             nz(premarketLow, low),
             low)

// =====================================================
// AFTER HOURS SESSION VWAP
// =====================================================

inAfterHours = not na(
     time(
         timeframe.period,
         afterHoursSession,
         tz))

afterHoursEnd =
     not inAfterHours and inAfterHours[1]

// LIVE SESSION VWAP
sessionVWAP = ta.vwap(hlc3)

// FINAL AFTER HOURS VWAP
var float ahVWAP = na

// O 20:00 zapamiętaj ostatni VWAP
if afterHoursEnd
    ahVWAP := sessionVWAP[1]
// =====================================================
// H5M / L5M
// =====================================================

first5HighFunc() =>

    var float h = na

    newDay =
         ta.change(
             time(
                 'D',
                 '0000-2359',
                 tz)) != 0

    inFirstFive =
         not na(
             time(
                 timeframe.period,
                 firstFiveSession,
                 tz))

    if newDay
        h := na

    if inFirstFive
        h := high

    h

first5LowFunc() =>

    var float l = na

    newDay =
         ta.change(
             time(
                 'D',
                 '0000-2359',
                 tz)) != 0

    inFirstFive =
         not na(
             time(
                 timeframe.period,
                 firstFiveSession,
                 tz))

    if newDay
        l := na

    if inFirstFive
        l := low

    l

h5m = request.security(
     syminfo.tickerid,
     '5',
     first5HighFunc(),
     barmerge.gaps_off,
     barmerge.lookahead_off)

l5m = request.security(
     syminfo.tickerid,
     '5',
     first5LowFunc(),
     barmerge.gaps_off,
     barmerge.lookahead_off)

// =====================================================
// LINES + LABELS
// =====================================================

var line pmhLine = na
var label pmhLabel = na

var line pmlLine = na
var label pmlLabel = na

var line pdhLine = na
var label pdhLabel = na

var line pdlLine = na
var label pdlLabel = na

var line ahvwapLine = na
var label ahvwapLabel = na

var line h5Line = na
var label h5Label = na

var line l5Line = na
var label l5Label = na

// =====================================================
// PMH
// =====================================================

if showPremarketHighLow and not na(premarketHigh)

    if na(pmhLine)

        pmhLine := line.new(
             bar_index,
             premarketHigh,
             bar_index + 1,
             premarketHigh,
             extend = extend.right,
             color = levelColor,
             style = line.style_solid,
             width = lineWidth)

        pmhLabel := label.new(
             bar_index + labelOffset,
             premarketHigh,
             formatText('PMH', premarketHigh),
             style = label.style_label_left,
             color = color.new(color.black, 100),
             textcolor = levelColor,
             size = size.small)

    else

        line.set_xy1(
             pmhLine,
             bar_index - 1,
             premarketHigh)

        line.set_xy2(
             pmhLine,
             bar_index,
             premarketHigh)

        label.set_x(
             pmhLabel,
             bar_index + labelOffset)

        label.set_y(
             pmhLabel,
             premarketHigh + 0.10)

        label.set_text(
             pmhLabel,
             formatText(
                 'PMH',
                 premarketHigh))

// =====================================================
// PML
// =====================================================

if showPremarketHighLow and not na(premarketLow)

    if na(pmlLine)

        pmlLine := line.new(
             bar_index,
             premarketLow,
             bar_index + 1,
             premarketLow,
             extend = extend.right,
             color = levelColor,
             style = line.style_solid,
             width = lineWidth)

        pmlLabel := label.new(
             bar_index + labelOffset,
             premarketLow,
             formatText('PML', premarketLow),
             style = label.style_label_left,
             color = color.new(color.black, 100),
             textcolor = levelColor,
             size = size.small)

    else

        line.set_xy1(
             pmlLine,
             bar_index - 1,
             premarketLow)

        line.set_xy2(
             pmlLine,
             bar_index,
             premarketLow)

        label.set_x(
             pmlLabel,
             bar_index + labelOffset)

        label.set_y(
             pmlLabel,
             premarketLow + 0.10)

        label.set_text(
             pmlLabel,
             formatText(
                 'PML',
                 premarketLow))

// =====================================================
// PDH
// =====================================================

if showPreviousDayHighLow and not na(previousDayHigh)

    if na(pdhLine)

        pdhLine := line.new(
             bar_index,
             previousDayHigh,
             bar_index + 1,
             previousDayHigh,
             extend = extend.right,
             color = levelColor,
             style = line.style_dashed,
             width = lineWidth)

        pdhLabel := label.new(
             bar_index + labelOffset,
             previousDayHigh,
             formatText('PDH', previousDayHigh),
             style = label.style_label_left,
             color = color.new(color.black, 100),
             textcolor = levelColor,
             size = size.small)

    else

        line.set_xy1(
             pdhLine,
             bar_index - 1,
             previousDayHigh)

        line.set_xy2(
             pdhLine,
             bar_index,
             previousDayHigh)

        label.set_x(
             pdhLabel,
             bar_index + labelOffset)

        label.set_y(
             pdhLabel,
             previousDayHigh + 0.10)

        label.set_text(
             pdhLabel,
             formatText(
                 'PDH',
                 previousDayHigh))

// =====================================================
// PDL
// =====================================================

if showPreviousDayHighLow and not na(previousDayLow)

    if na(pdlLine)

        pdlLine := line.new(
             bar_index,
             previousDayLow,
             bar_index + 1,
             previousDayLow,
             extend = extend.right,
             color = levelColor,
             style = line.style_dashed,
             width = lineWidth)

        pdlLabel := label.new(
             bar_index + labelOffset,
             previousDayLow,
             formatText('PDL', previousDayLow),
             style = label.style_label_left,
             color = color.new(color.black, 100),
             textcolor = levelColor,
             size = size.small)

    else

        line.set_xy1(
             pdlLine,
             bar_index - 1,
             previousDayLow)

        line.set_xy2(
             pdlLine,
             bar_index,
             previousDayLow)

        label.set_x(
             pdlLabel,
             bar_index + labelOffset)

        label.set_y(
             pdlLabel,
             previousDayLow + 0.10)

        label.set_text(
             pdlLabel,
             formatText(
                 'PDL',
                 previousDayLow))

// =====================================================
// AFTER HOURS VWAP
// =====================================================

if showAHVWAP and not na(ahVWAP)

    if na(ahvwapLine)

        ahvwapLine := line.new(
             bar_index,
             ahVWAP,
             bar_index + 1,
             ahVWAP,
             extend = extend.right,
             color = levelColor,
             style = line.style_dotted,
             width = lineWidth)

        ahvwapLabel := label.new(
             bar_index + labelOffset,
             ahVWAP,
             formatText('AH VWAP', ahVWAP),
             style = label.style_label_left,
             color = color.new(color.black, 100),
             textcolor = levelColor,
             size = size.small)

    else

        line.set_xy1(
             ahvwapLine,
             bar_index - 1,
             ahVWAP)

        line.set_xy2(
             ahvwapLine,
             bar_index,
             ahVWAP)

        label.set_x(
             ahvwapLabel,
             bar_index + labelOffset)

        label.set_y(
             ahvwapLabel,
             ahVWAP + 0.10)

        label.set_text(
             ahvwapLabel,
             formatText(
                 'AH VWAP',
                 ahVWAP))

// =====================================================
// H5M
// =====================================================

if showH5L5 and not na(h5m)

    if na(h5Line)

        h5Line := line.new(
             bar_index,
             h5m,
             bar_index + 1,
             h5m,
             extend = extend.right,
             color = levelColor,
             style = line.style_solid,
             width = lineWidth)

        h5Label := label.new(
             bar_index + labelOffset,
             h5m,
             formatText('H5M', h5m),
             style = label.style_label_left,
             color = color.new(color.black, 100),
             textcolor = levelColor,
             size = size.small)

    else

        line.set_xy1(
             h5Line,
             bar_index - 1,
             h5m)

        line.set_xy2(
             h5Line,
             bar_index,
             h5m)

        label.set_x(
             h5Label,
             bar_index + labelOffset)

        label.set_y(
             h5Label,
             h5m + 0.10)

        label.set_text(
             h5Label,
             formatText(
                 'H5M',
                 h5m))

// =====================================================
// L5M
// =====================================================

if showH5L5 and not na(l5m)

    if na(l5Line)

        l5Line := line.new(
             bar_index,
             l5m,
             bar_index + 1,
             l5m,
             extend = extend.right,
             color = levelColor,
             style = line.style_solid,
             width = lineWidth)

        l5Label := label.new(
             bar_index + labelOffset,
             l5m,
             formatText('L5M', l5m),
             style = label.style_label_left,
             color = color.new(color.black, 100),
             textcolor = levelColor,
             size = size.small)

    else

        line.set_xy1(
             l5Line,
             bar_index - 1,
             l5m)

        line.set_xy2(
             l5Line,
             bar_index,
             l5m)

        label.set_x(
             l5Label,
             bar_index + labelOffset)

        label.set_y(
             l5Label,
             l5m + 0.10)

        label.set_text(
             l5Label,
             formatText(
                 'L5M',
                 l5m))

// =====================================================
// ALERTS
// =====================================================

alertcondition(
     ta.cross(close, previousDayHigh),
     'Crossed PDH',
     'Price crossed Previous Day High')

alertcondition(
     ta.cross(close, previousDayLow),
     'Crossed PDL',
     'Price crossed Previous Day Low')

alertcondition(
     ta.cross(close, premarketHigh),
     'Crossed PMH',
     'Price crossed Premarket High')

alertcondition(
     ta.cross(close, premarketLow),
     'Crossed PML',
     'Price crossed Premarket Low')

alertcondition(
     ta.cross(close, ahVWAP),
     'Crossed AH VWAP',
     'Price crossed After Hours VWAP')
````

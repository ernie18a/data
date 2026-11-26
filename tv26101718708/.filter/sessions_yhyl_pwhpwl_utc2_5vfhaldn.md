# Sessions + YH/YL + PWH/PWL - UTC+2

- url: https://www.tradingview.com/script/5vfhaLdn-Sessions-YH-YL-PWH-PWL-UTC-2/
- type: indicator
- pine_id: PUB;95e38ff8e01d40d3849d5b770100ce7d
- version: 1.0

## Description

I've made a pine editor script from The Netherlands. A instant indicator which includes:
- Asia High + low 00-08u
- London High + low 09-17.30u
- NY high + low 15.30-22.00u
- Previous day high + low 
- Previous week high + low

I use this to scatch my basic key levels.

## Source Code

````pine
//@version=5
indicator("Sessions + YH/YL + PWH/PWL - UTC+2", overlay=true, max_lines_count=500, max_labels_count=500)

// SETTINGS
tz = input.string("Etc/GMT-2", "Timezone UTC+2")

asiaSession   = input.session("0000-0800", "Asia Session UTC+2")
londonSession = input.session("0900-1730", "London Cash Session UTC+2")
nySession     = input.session("1530-2200", "New York Cash Session UTC+2")

showAsia   = input.bool(true, "Show Asia H/L")
showLondon = input.bool(true, "Show London H/L")
showNY     = input.bool(true, "Show New York H/L")
showYHYL   = input.bool(true, "Show Yesterday H/L")
showPWHL   = input.bool(true, "Show Previous Week H/L")

baseOffset   = input.int(6, "Base label distance", minval=1, maxval=100)
offsetStep   = input.int(7, "Extra spacing between label groups", minval=1, maxval=50)
lineWidth    = input.int(1, "Line width", minval=1, maxval=4)

// COLORS
asiaColor   = color.yellow
londonColor = color.blue
nyColor     = color.orange
yhColor     = color.green
ylColor     = color.red
pwColor     = color.white

blackText = color.black
whiteText = color.white

// HELPERS
inSession(sess) =>
    not na(time(timeframe.period, sess, tz))

makeLine(price, col, styleType) =>
    line.new(bar_index, price, bar_index + 1, price, extend=extend.right, color=col, style=styleType, width=lineWidth)

makeLabel(price, txt, bgCol, txtCol, xOffset) =>
    label.new(bar_index + xOffset, price, txt, style=label.style_label_left, textcolor=txtCol, color=bgCol, size=size.small)

moveLabel(lb, price, xOffset) =>
    if not na(lb)
        label.set_x(lb, bar_index + xOffset)
        label.set_y(lb, price)

moveLine(l, price) =>
    if not na(l)
        line.set_y1(l, price)
        line.set_y2(l, price)

// OFFSETS PER GROUP
asiaOffset   = baseOffset
londonOffset = baseOffset + offsetStep
nyOffset     = baseOffset + offsetStep * 2
dailyOffset  = baseOffset + offsetStep * 3
weeklyOffset = baseOffset + offsetStep * 4

// ─────────────────────────────
// ASIA HIGH / LOW
// ─────────────────────────────
var float asiaHigh = na
var float asiaLow  = na
var line asiaHLine = na
var line asiaLLine = na
var label asiaHLabel = na
var label asiaLLabel = na

asiaActive = inSession(asiaSession)
asiaStart  = asiaActive and not asiaActive[1]
asiaEnd    = not asiaActive and asiaActive[1]

if showAsia and asiaStart
    asiaHigh := high
    asiaLow  := low

if showAsia and asiaActive
    asiaHigh := math.max(asiaHigh, high)
    asiaLow  := math.min(asiaLow, low)

if showAsia and asiaEnd
    line.delete(asiaHLine)
    line.delete(asiaLLine)
    label.delete(asiaHLabel)
    label.delete(asiaLLabel)
    asiaHLine := makeLine(asiaHigh, asiaColor, line.style_dotted)
    asiaLLine := makeLine(asiaLow, asiaColor, line.style_dotted)
    asiaHLabel := makeLabel(asiaHigh, "AH", asiaColor, blackText, asiaOffset)
    asiaLLabel := makeLabel(asiaLow, "AL", asiaColor, blackText, asiaOffset)

moveLine(asiaHLine, asiaHigh)
moveLine(asiaLLine, asiaLow)
moveLabel(asiaHLabel, asiaHigh, asiaOffset)
moveLabel(asiaLLabel, asiaLow, asiaOffset)

// ─────────────────────────────
// LONDON HIGH / LOW
// ─────────────────────────────
var float londonHigh = na
var float londonLow  = na
var line londonHLine = na
var line londonLLine = na
var label londonHLabel = na
var label londonLLabel = na

londonActive = inSession(londonSession)
londonStart  = londonActive and not londonActive[1]
londonEnd    = not londonActive and londonActive[1]

if showLondon and londonStart
    londonHigh := high
    londonLow  := low

if showLondon and londonActive
    londonHigh := math.max(londonHigh, high)
    londonLow  := math.min(londonLow, low)

if showLondon and londonEnd
    line.delete(londonHLine)
    line.delete(londonLLine)
    label.delete(londonHLabel)
    label.delete(londonLLabel)
    londonHLine := makeLine(londonHigh, londonColor, line.style_dotted)
    londonLLine := makeLine(londonLow, londonColor, line.style_dotted)
    londonHLabel := makeLabel(londonHigh, "London H", londonColor, whiteText, londonOffset)
    londonLLabel := makeLabel(londonLow, "London L", londonColor, whiteText, londonOffset)

moveLine(londonHLine, londonHigh)
moveLine(londonLLine, londonLow)
moveLabel(londonHLabel, londonHigh, londonOffset)
moveLabel(londonLLabel, londonLow, londonOffset)

// ─────────────────────────────
// NEW YORK HIGH / LOW
// ─────────────────────────────
var float nyHigh = na
var float nyLow  = na
var line nyHLine = na
var line nyLLine = na
var label nyHLabel = na
var label nyLLabel = na

nyActive = inSession(nySession)
nyStart  = nyActive and not nyActive[1]
nyEnd    = not nyActive and nyActive[1]

if showNY and nyStart
    nyHigh := high
    nyLow  := low

if showNY and nyActive
    nyHigh := math.max(nyHigh, high)
    nyLow  := math.min(nyLow, low)

if showNY and nyEnd
    line.delete(nyHLine)
    line.delete(nyLLine)
    label.delete(nyHLabel)
    label.delete(nyLLabel)
    nyHLine := makeLine(nyHigh, nyColor, line.style_dotted)
    nyLLine := makeLine(nyLow, nyColor, line.style_dotted)
    nyHLabel := makeLabel(nyHigh, "NY H", nyColor, blackText, nyOffset)
    nyLLabel := makeLabel(nyLow, "NY L", nyColor, blackText, nyOffset)

moveLine(nyHLine, nyHigh)
moveLine(nyLLine, nyLow)
moveLabel(nyHLabel, nyHigh, nyOffset)
moveLabel(nyLLabel, nyLow, nyOffset)

// ─────────────────────────────
// YESTERDAY HIGH / LOW
// ─────────────────────────────
yHigh = request.security(syminfo.tickerid, "D", high[1])
yLow  = request.security(syminfo.tickerid, "D", low[1])

newDay = ta.change(time("D"))

var line yhLine = na
var line ylLine = na
var label yhLabel = na
var label ylLabel = na

if showYHYL and newDay
    line.delete(yhLine)
    line.delete(ylLine)
    label.delete(yhLabel)
    label.delete(ylLabel)
    yhLine := makeLine(yHigh, yhColor, line.style_solid)
    ylLine := makeLine(yLow, ylColor, line.style_solid)
    yhLabel := makeLabel(yHigh, "YH", yhColor, whiteText, dailyOffset)
    ylLabel := makeLabel(yLow, "YL", ylColor, whiteText, dailyOffset)

moveLine(yhLine, yHigh)
moveLine(ylLine, yLow)
moveLabel(yhLabel, yHigh, dailyOffset)
moveLabel(ylLabel, yLow, dailyOffset)

// ─────────────────────────────
// PREVIOUS WEEK HIGH / LOW
// ─────────────────────────────
pwHigh = request.security(syminfo.tickerid, "W", high[1])
pwLow  = request.security(syminfo.tickerid, "W", low[1])

newWeek = ta.change(time("W"))

var line pwhLine = na
var line pwlLine = na
var label pwhLabel = na
var label pwlLabel = na

if showPWHL and newWeek
    line.delete(pwhLine)
    line.delete(pwlLine)
    label.delete(pwhLabel)
    label.delete(pwlLabel)
    pwhLine := makeLine(pwHigh, pwColor, line.style_dotted)
    pwlLine := makeLine(pwLow, pwColor, line.style_dotted)
    pwhLabel := makeLabel(pwHigh, "PWH", pwColor, blackText, weeklyOffset)
    pwlLabel := makeLabel(pwLow, "PWL", pwColor, blackText, weeklyOffset)

moveLine(pwhLine, pwHigh)
moveLine(pwlLine, pwLow)
moveLabel(pwhLabel, pwHigh, weeklyOffset)
moveLabel(pwlLabel, pwLow, weeklyOffset)
````

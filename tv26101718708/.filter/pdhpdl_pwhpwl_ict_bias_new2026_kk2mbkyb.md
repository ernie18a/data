# PDH/PDL + PWH/PWL + ICT Bias New2026

- url: https://www.tradingview.com/script/kk2mbKYb/
- type: indicator
- pine_id: PUB;ece798d321d54151a95dd899f1036e85
- version: 1.0

## Description

PDH/PDL + PWH/PWL + ICT Bias New2026
Marcações de niveis importantes

## Source Code

````pine
//@version=5
indicator("PDH/PDL + PWH/PWL + ICT Bias Filter", overlay=true, max_lines_count=20, max_labels_count=20)

// Inputs
showPDH = input.bool(true, "Show PDH")
showPDL = input.bool(true, "Show PDL")
showPWH = input.bool(true, "Show PWH")
showPWL = input.bool(true, "Show PWL")
showLDN = input.bool(true, "Show London High/Low")
showPanel = input.bool(true, "Show Bias Panel")
pivL = input.int(2, "Pivot Left", minval=1, maxval=10)
pivR = input.int(2, "Pivot Right", minval=1, maxval=10)

// Track when we're on a new day/week and find the actual high/low bars
isNewDay = ta.change(time("D"))
isNewWeek = ta.change(time("W"))

// Store previous day/week values when they update
var float pdh = na
var float pdl = na
var int pdhBar = na
var int pdlBar = na
var float dayHigh = na
var float dayLow = na
var int dayHighBar = na
var int dayLowBar = na

var float pwh = na
var float pwl = na
var int pwhBar = na
var int pwlBar = na
var float weekHigh = na
var float weekLow = na
var int weekHighBar = na
var int weekLowBar = na

// Track intraday highs/lows and their bar indices
if isNewDay
    pdh := dayHigh
    pdl := dayLow
    pdhBar := dayHighBar
    pdlBar := dayLowBar
    dayHigh := high
    dayLow := low
    dayHighBar := bar_index
    dayLowBar := bar_index
else
    if high > dayHigh
        dayHigh := high
        dayHighBar := bar_index
    if low < dayLow
        dayLow := low
        dayLowBar := bar_index

// Same for weekly
if isNewWeek
    pwh := weekHigh
    pwl := weekLow
    pwhBar := weekHighBar
    pwlBar := weekLowBar
    weekHigh := high
    weekLow := low
    weekHighBar := bar_index
    weekLowBar := bar_index
else
    if high > weekHigh
        weekHigh := high
        weekHighBar := bar_index
    if low < weekLow
        weekLow := low
        weekLowBar := bar_index

// London Session tracking
londonSession = input.session("0700-1000", "London Session (UTC)")
inLondon = not na(time(timeframe.period, londonSession, "UTC"))
newLondon = inLondon and not inLondon[1]
endLondon = not inLondon and inLondon[1]

var float ldnHigh = na
var float ldnLow = na
var int ldnHighBar = na
var int ldnLowBar = na
var float londonHigh = na
var float londonLow = na
var int londonHighBar = na
var int londonLowBar = na

if newLondon
    londonHigh := high
    londonLow := low
    londonHighBar := bar_index
    londonLowBar := bar_index
else if inLondon
    if high > londonHigh
        londonHigh := high
        londonHighBar := bar_index
    if low < londonLow
        londonLow := low
        londonLowBar := bar_index

if endLondon
    ldnHigh := londonHigh
    ldnLow := londonLow
    ldnHighBar := londonHighBar
    ldnLowBar := londonLowBar

// Daily bias logic
prevDayHigh = request.security(syminfo.tickerid, "D", high[2], lookahead=barmerge.lookahead_off)
prevDayLow = request.security(syminfo.tickerid, "D", low[2], lookahead=barmerge.lookahead_off)
lastDayHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
lastDayLow = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_off)
lastDayClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_off)

insideRange = not na(lastDayClose) and not na(prevDayHigh) and not na(prevDayLow) and lastDayClose < prevDayHigh and lastDayClose > prevDayLow
sweptHigh = not na(lastDayHigh) and not na(prevDayHigh) and lastDayHigh > prevDayHigh
sweptLow = not na(lastDayLow) and not na(prevDayLow) and lastDayLow < prevDayLow

dailyBias = sweptHigh and insideRange ? -1 : sweptLow and insideRange ? 1 : not na(lastDayClose) and not na(prevDayHigh) and lastDayClose > prevDayHigh ? 1 : not na(lastDayClose) and not na(prevDayLow) and lastDayClose < prevDayLow ? -1 : 0

// Weekly bias logic
prevWeekHigh = request.security(syminfo.tickerid, "W", high[2], lookahead=barmerge.lookahead_off)
prevWeekLow = request.security(syminfo.tickerid, "W", low[2], lookahead=barmerge.lookahead_off)
lastWeekHigh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_off)
lastWeekLow = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_off)
lastWeekClose = request.security(syminfo.tickerid, "W", close[1], lookahead=barmerge.lookahead_off)

weekInsideRange = not na(lastWeekClose) and not na(prevWeekHigh) and not na(prevWeekLow) and lastWeekClose < prevWeekHigh and lastWeekClose > prevWeekLow
weekSweptHigh = not na(lastWeekHigh) and not na(prevWeekHigh) and lastWeekHigh > prevWeekHigh
weekSweptLow = not na(lastWeekLow) and not na(prevWeekLow) and lastWeekLow < prevWeekLow

weeklyBias = (weekSweptHigh and weekInsideRange) ? -1 : (weekSweptLow and weekInsideRange) ? 1 : (not na(lastWeekClose) and not na(prevWeekHigh) and lastWeekClose > prevWeekHigh) ? 1 : (not na(lastWeekClose) and not na(prevWeekLow) and lastWeekClose < prevWeekLow) ? -1 : 0

// Structure function
getStructureBias(left, right) =>
    var float lastHigh = na
    var float lastLow = na
    var int trend = 0
    
    ph = ta.pivothigh(high, left, right)
    pl = ta.pivotlow(low, left, right)
    
    if not na(ph)
        lastHigh := ph
    if not na(pl)
        lastLow := pl
    
    if not na(lastHigh) and close > lastHigh and close[1] <= lastHigh
        trend := 1
    else if not na(lastLow) and close < lastLow and close[1] >= lastLow
        trend := -1
    
    trend

// MTF Structure bias
b4h = request.security(syminfo.tickerid, "240", getStructureBias(pivL, pivR), lookahead=barmerge.lookahead_off)
b1h = request.security(syminfo.tickerid, "60", getStructureBias(pivL, pivR), lookahead=barmerge.lookahead_off)
b15m = request.security(syminfo.tickerid, "15", getStructureBias(pivL, pivR), lookahead=barmerge.lookahead_off)

// Draw rays attached to the origin bar
var line pdhLine = na
var line pdlLine = na
var line pwhLine = na
var line pwlLine = na
var line ldnhLine = na
var line ldnlLine = na

var label pdhLabel = na
var label pdlLabel = na
var label pwhLabel = na
var label pwlLabel = na
var label ldnhLabel = na
var label ldnlLabel = na

if showPDH and not na(pdh) and not na(pdhBar)
    if na(pdhLine) or line.get_y1(pdhLine) != pdh or line.get_x1(pdhLine) != pdhBar
        if not na(pdhLine)
            line.delete(pdhLine)
        pdhLine := line.new(pdhBar, pdh, bar_index, pdh, extend=extend.right, color=color.white, width=1)
    if na(pdhLabel)
        pdhLabel := label.new(bar_index, pdh, "PDH", yloc=yloc.price, style=label.style_none, textcolor=color.white, size=size.small)

if showPDL and not na(pdl) and not na(pdlBar)
    if na(pdlLine) or line.get_y1(pdlLine) != pdl or line.get_x1(pdlLine) != pdlBar
        if not na(pdlLine)
            line.delete(pdlLine)
        pdlLine := line.new(pdlBar, pdl, bar_index, pdl, extend=extend.right, color=color.white, width=1)
    if na(pdlLabel)
        pdlLabel := label.new(bar_index, pdl, "PDL", yloc=yloc.price, style=label.style_none, textcolor=color.white, size=size.small)

if showPWH and not na(pwh) and not na(pwhBar)
    if na(pwhLine) or line.get_y1(pwhLine) != pwh or line.get_x1(pwhLine) != pwhBar
        if not na(pwhLine)
            line.delete(pwhLine)
        pwhLine := line.new(pwhBar, pwh, bar_index, pwh, extend=extend.right, color=color.white, width=1)
    if na(pwhLabel)
        pwhLabel := label.new(bar_index, pwh, "PWH", yloc=yloc.price, style=label.style_none, textcolor=color.white, size=size.small)

if showPWL and not na(pwl) and not na(pwlBar)
    if na(pwlLine) or line.get_y1(pwlLine) != pwl or line.get_x1(pwlLine) != pwlBar
        if not na(pwlLine)
            line.delete(pwlLine)
        pwlLine := line.new(pwlBar, pwl, bar_index, pwl, extend=extend.right, color=color.white, width=1)
    if na(pwlLabel)
        pwlLabel := label.new(bar_index, pwl, "PWL", yloc=yloc.price, style=label.style_none, textcolor=color.white, size=size.small)

if showLDN and not na(ldnHigh) and not na(ldnHighBar)
    if na(ldnhLine) or line.get_y1(ldnhLine) != ldnHigh or line.get_x1(ldnhLine) != ldnHighBar
        if not na(ldnhLine)
            line.delete(ldnhLine)
        ldnhLine := line.new(ldnHighBar, ldnHigh, bar_index, ldnHigh, extend=extend.right, color=color.white, width=1)
    if na(ldnhLabel)
        ldnhLabel := label.new(bar_index, ldnHigh, "LDN H", yloc=yloc.price, style=label.style_none, textcolor=color.white, size=size.small)

if showLDN and not na(ldnLow) and not na(ldnLowBar)
    if na(ldnlLine) or line.get_y1(ldnlLine) != ldnLow or line.get_x1(ldnlLine) != ldnLowBar
        if not na(ldnlLine)
            line.delete(ldnlLine)
        ldnlLine := line.new(ldnLowBar, ldnLow, bar_index, ldnLow, extend=extend.right, color=color.white, width=1)
    if na(ldnlLabel)
        ldnlLabel := label.new(bar_index, ldnLow, "LDN L", yloc=yloc.price, style=label.style_none, textcolor=color.white, size=size.small)

if not na(pdhLine)
    line.set_x2(pdhLine, bar_index)
if not na(pdlLine)
    line.set_x2(pdlLine, bar_index)
if not na(pwhLine)
    line.set_x2(pwhLine, bar_index)
if not na(pwlLine)
    line.set_x2(pwlLine, bar_index)
if not na(ldnhLine)
    line.set_x2(ldnhLine, bar_index)
if not na(ldnlLine)
    line.set_x2(ldnlLine, bar_index)

// Keep labels at right edge
atrOffset = ta.atr(14) * 0.1

if not na(pdhLabel) and not na(pdh)
    label.set_x(pdhLabel, bar_index)
    label.set_y(pdhLabel, pdh + atrOffset)

if not na(pdlLabel) and not na(pdl)
    label.set_x(pdlLabel, bar_index)
    label.set_y(pdlLabel, pdl + atrOffset)

if not na(pwhLabel) and not na(pwh)
    label.set_x(pwhLabel, bar_index)
    label.set_y(pwhLabel, pwh + atrOffset)

if not na(pwlLabel) and not na(pwl)
    label.set_x(pwlLabel, bar_index)
    label.set_y(pwlLabel, pwl + atrOffset)

if not na(ldnhLabel) and not na(ldnHigh)
    label.set_x(ldnhLabel, bar_index)
    label.set_y(ldnhLabel, ldnHigh + atrOffset)

if not na(ldnlLabel) and not na(ldnLow)
    label.set_x(ldnlLabel, bar_index)
    label.set_y(ldnlLabel, ldnLow + atrOffset)

// Helper functions
getBiasText(b) => b == 1 ? "BULLISH" : b == -1 ? "BEARISH" : "NEUTRAL"
getShortText(b) => b == 1 ? "BULL" : b == -1 ? "BEAR" : "NEU"

// Bias panel
var table panel = table.new(position.top_right, 2, 6, border_width=1)

if barstate.islast and showPanel
    table.cell(panel, 0, 0, "TF", text_color=color.white, bgcolor=color.new(color.gray, 0), text_size=size.normal)
    table.cell(panel, 1, 0, "BIAS", text_color=color.white, bgcolor=color.new(color.gray, 0), text_size=size.normal)

    table.cell(panel, 0, 1, "WEEKLY", text_color=color.white, bgcolor=color.black, text_size=size.normal)
    weeklyColor = weeklyBias == 1 ? color.new(color.green, 30) : weeklyBias == -1 ? color.new(color.red, 30) : color.new(color.gray, 50)
    table.cell(panel, 1, 1, getBiasText(weeklyBias), text_color=color.white, bgcolor=weeklyColor, text_size=size.normal)

    table.cell(panel, 0, 2, "DAILY", text_color=color.white, bgcolor=color.black, text_size=size.normal)
    dailyColor = dailyBias == 1 ? color.new(color.green, 30) : dailyBias == -1 ? color.new(color.red, 30) : color.new(color.gray, 50)
    table.cell(panel, 1, 2, getBiasText(dailyBias), text_color=color.white, bgcolor=dailyColor, text_size=size.normal)

    table.cell(panel, 0, 3, "4H", text_color=color.white, bgcolor=color.black, text_size=size.normal)
    h4Color = b4h == 1 ? color.new(color.green, 30) : b4h == -1 ? color.new(color.red, 30) : color.new(color.gray, 50)
    table.cell(panel, 1, 3, getShortText(b4h), text_color=color.white, bgcolor=h4Color, text_size=size.normal)

    table.cell(panel, 0, 4, "1H", text_color=color.white, bgcolor=color.black, text_size=size.normal)
    h1Color = b1h == 1 ? color.new(color.green, 30) : b1h == -1 ? color.new(color.red, 30) : color.new(color.gray, 50)
    table.cell(panel, 1, 4, getShortText(b1h), text_color=color.white, bgcolor=h1Color, text_size=size.normal)

    table.cell(panel, 0, 5, "15M", text_color=color.white, bgcolor=color.black, text_size=size.normal)
    m15Color = b15m == 1 ? color.new(color.green, 30) : b15m == -1 ? color.new(color.red, 30) : color.new(color.gray, 50)
    table.cell(panel, 1, 5, getShortText(b15m), text_color=color.white, bgcolor=m15Color, text_size=size.normal)
````

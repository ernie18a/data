# Clean Key Levels Map

- url: https://www.tradingview.com/script/wGy6HpZd-Clean-Key-Levels-Map/
- type: indicator
- pine_id: PUB;98cae73f7be948d38609955dc4e8b390
- version: 1.0

## Description

Clean Key Levels Map

Clean Key Levels Map is a simple level-marking indicator designed for traders who want an uncluttered chart with only the most important reference prices.

This tool plots key levels from higher timeframes and major trading sessions, with short labels printed on the right side for quick identification. All lines begin from the start of the current trading day, which keeps the chart clean and structured for intraday decision-making.

Included levels
Previous Day High and Low
Previous NY Session High and Low
Asia Session High and Low
London Session High and Low
Weekly High and Low
Monthly High and Low
Features
Clean horizontal line layout
Short level names on the right side
Custom on/off toggle for each level group
Custom color selection for each level group
Adjustable line width
Adjustable label offset
Optional auto-delete of old levels on a new day
Built for traders who prefer a simple chart without unnecessary signals
Best use

This indicator is best used as a visual map for:

liquidity levels
session highs and lows
reaction zones
intraday context
breakout and sweep-based trading

It does not generate buy or sell signals. Its purpose is to help traders read price around important levels with clarity.

Notes
Previous NY High and Low are based on the defined NY session input
Asia and London levels are based on their completed session ranges
Weekly and Monthly levels are taken from the previous completed week and month
All lines are designed to start from the beginning of the current trading day for a cleaner intraday view

This indicator is ideal for traders who use price action, sweeps, session liquidity, ORB, or level-to-level trading and want a clean framework on the chart.

## Source Code

````pine
//@version=6
indicator("Clean Key Levels Map", shorttitle="KeyLevels", overlay=true, max_lines_count=500, max_labels_count=500)

//====================================================
// INPUTS
//====================================================
groupGen = "General"
tz       = input.string("Europe/London", "Timezone", group=groupGen)
rightPad = input.int(6, "Right Label Offset (bars)", minval=1, maxval=50, group=groupGen)
autoDel  = input.bool(true, "Delete Old Levels On New Day", group=groupGen)
labelBg  = input.bool(true, "Show Label Background", group=groupGen)
labelSz  = input.string("small", "Label Size", options=["tiny","small","normal"], group=groupGen)

groupPD = "Previous Day High / Low"
showPD  = input.bool(true, "Show Previous Day High / Low", group=groupPD)
colPDH  = input.color(color.red, "PDH Color", group=groupPD)
colPDL  = input.color(color.red, "PDL Color", group=groupPD)
widPD   = input.int(1, "PD Line Width", minval=1, maxval=4, group=groupPD)

groupNY = "Previous NY Session High / Low"
showNY  = input.bool(true, "Show Previous NY High / Low", group=groupNY)
nySess  = input.session("0930-1600", "NY Session", group=groupNY)
colNYH  = input.color(color.red, "Prev NY High Color", group=groupNY)
colNYL  = input.color(color.red, "Prev NY Low Color", group=groupNY)
widNY   = input.int(1, "NY Line Width", minval=1, maxval=4, group=groupNY)

groupAsia = "Asia High / Low"
showAsia  = input.bool(true, "Show Asia High / Low", group=groupAsia)
asiaSess  = input.session("0000-0700", "Asia Session", group=groupAsia)
colAsiaH  = input.color(color.blue, "Asia High Color", group=groupAsia)
colAsiaL  = input.color(color.blue, "Asia Low Color", group=groupAsia)
widAsia   = input.int(1, "Asia Line Width", minval=1, maxval=4, group=groupAsia)

groupLondon = "London High / Low"
showLondon  = input.bool(true, "Show London High / Low", group=groupLondon)
londonSess  = input.session("0700-1000", "London Session", group=groupLondon)
colLondonH  = input.color(color.red, "London High Color", group=groupLondon)
colLondonL  = input.color(color.red, "London Low Color", group=groupLondon)
widLondon   = input.int(1, "London Line Width", minval=1, maxval=4, group=groupLondon)

groupWeek = "Weekly High / Low"
showWeek  = input.bool(false, "Show Weekly High / Low", group=groupWeek)
colWH     = input.color(color.purple, "Weekly High Color", group=groupWeek)
colWL     = input.color(color.purple, "Weekly Low Color", group=groupWeek)
widWeek   = input.int(1, "Weekly Line Width", minval=1, maxval=4, group=groupWeek)

groupMonth = "Monthly High / Low"
showMonth  = input.bool(false, "Show Monthly High / Low", group=groupMonth)
colMH      = input.color(color.gray, "Monthly High Color", group=groupMonth)
colML      = input.color(color.gray, "Monthly Low Color", group=groupMonth)
widMonth   = input.int(1, "Monthly Line Width", minval=1, maxval=4, group=groupMonth)

//====================================================
// HELPERS
//====================================================
barMs = timeframe.in_seconds() * 1000
futureTime = time + barMs * rightPad
newDay = ta.change(time("D", "", tz)) != 0

labelSize =
     labelSz == "tiny"   ? size.tiny :
     labelSz == "normal" ? size.normal :
     size.small

f_bg(_c) =>
    labelBg ? _c : color.new(color.black, 100)

f_txt() =>
    color.white

//====================================================
// START OF CURRENT DAY
//====================================================
var int dayStartTime = na
if barstate.isfirst
    dayStartTime := time
if newDay
    dayStartTime := time

//====================================================
// SESSION DETECTION
//====================================================
inAsia      = not na(time(timeframe.period, asiaSess, tz))
asiaOpen    = inAsia and not inAsia[1]
asiaClose   = not inAsia and inAsia[1]

inLondon    = not na(time(timeframe.period, londonSess, tz))
londonOpen  = inLondon and not inLondon[1]
londonClose = not inLondon and inLondon[1]

inNY      = not na(time(timeframe.period, nySess, tz))
nyOpen    = inNY and not inNY[1]
nyClose   = not inNY and inNY[1]

//====================================================
// HIGHER TIMEFRAME LEVELS
//====================================================
prevDayHigh   = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_off)
prevDayLow    = request.security(syminfo.tickerid, "D", low[1], barmerge.gaps_off, barmerge.lookahead_off)
prevWeekHigh  = request.security(syminfo.tickerid, "W", high[1], barmerge.gaps_off, barmerge.lookahead_off)
prevWeekLow   = request.security(syminfo.tickerid, "W", low[1], barmerge.gaps_off, barmerge.lookahead_off)
prevMonthHigh = request.security(syminfo.tickerid, "M", high[1], barmerge.gaps_off, barmerge.lookahead_off)
prevMonthLow  = request.security(syminfo.tickerid, "M", low[1], barmerge.gaps_off, barmerge.lookahead_off)

//====================================================
// TRACK PREVIOUS COMPLETED SESSION H/L
//====================================================
var float asiaHigh = na
var float asiaLow = na
var float prevAsiaHigh = na
var float prevAsiaLow = na

var float londonHigh = na
var float londonLow = na
var float prevLondonHigh = na
var float prevLondonLow = na

var float nyHigh = na
var float nyLow = na
var float prevNYHigh = na
var float prevNYLow = na

if newDay
    asiaHigh := na
    asiaLow := na
    londonHigh := na
    londonLow := na
    nyHigh := na
    nyLow := na

if asiaOpen
    asiaHigh := high
    asiaLow := low
else if inAsia
    asiaHigh := na(asiaHigh) ? high : math.max(asiaHigh, high)
    asiaLow := na(asiaLow) ? low : math.min(asiaLow, low)

if asiaClose
    prevAsiaHigh := asiaHigh
    prevAsiaLow := asiaLow

if londonOpen
    londonHigh := high
    londonLow := low
else if inLondon
    londonHigh := na(londonHigh) ? high : math.max(londonHigh, high)
    londonLow := na(londonLow) ? low : math.min(londonLow, low)

if londonClose
    prevLondonHigh := londonHigh
    prevLondonLow := londonLow

if nyOpen
    nyHigh := high
    nyLow := low
else if inNY
    nyHigh := na(nyHigh) ? high : math.max(nyHigh, high)
    nyLow := na(nyLow) ? low : math.min(nyLow, low)

if nyClose
    prevNYHigh := nyHigh
    prevNYLow := nyLow

//====================================================
// OBJECTS
//====================================================
var line pdhLine = na
var line pdlLine = na
var label pdhLab = na
var label pdlLab = na

var line nyhLine = na
var line nylLine = na
var label nyhLab = na
var label nylLab = na

var line ahLine = na
var line alLine = na
var label ahLab = na
var label alLab = na

var line lnhLine = na
var line lnlLine = na
var label lnhLab = na
var label lnlLab = na

var line whLine = na
var line wlLine = na
var label whLab = na
var label wlLab = na

var line mhLine = na
var line mlLine = na
var label mhLab = na
var label mlLab = na

//====================================================
// RESET ON NEW DAY
//====================================================
if newDay and autoDel
    line.delete(pdhLine), line.delete(pdlLine), label.delete(pdhLab), label.delete(pdlLab)
    line.delete(nyhLine), line.delete(nylLine), label.delete(nyhLab), label.delete(nylLab)
    line.delete(ahLine), line.delete(alLine), label.delete(ahLab), label.delete(alLab)
    line.delete(lnhLine), line.delete(lnlLine), label.delete(lnhLab), label.delete(lnlLab)
    line.delete(whLine), line.delete(wlLine), label.delete(whLab), label.delete(wlLab)
    line.delete(mhLine), line.delete(mlLine), label.delete(mhLab), label.delete(mlLab)

    pdhLine := na, pdlLine := na, pdhLab := na, pdlLab := na
    nyhLine := na, nylLine := na, nyhLab := na, nylLab := na
    ahLine := na, alLine := na, ahLab := na, alLab := na
    lnhLine := na, lnlLine := na, lnhLab := na, lnlLab := na
    whLine := na, wlLine := na, whLab := na, wlLab := na
    mhLine := na, mlLine := na, mhLab := na, mlLab := na

//====================================================
// DRAW LEVEL HELPER PATTERN
//====================================================

// Previous Day
if showPD
    if na(pdhLine)
        pdhLine := line.new(dayStartTime, prevDayHigh, futureTime, prevDayHigh, xloc=xloc.bar_time, extend=extend.none, color=colPDH, width=widPD)
        pdhLab := label.new(futureTime, prevDayHigh, "PDH", xloc=xloc.bar_time, style=label.style_label_left, textcolor=f_txt(), color=f_bg(colPDH), size=labelSize)
    else
        line.set_xy1(pdhLine, dayStartTime, prevDayHigh)
        line.set_xy2(pdhLine, futureTime, prevDayHigh)
        line.set_color(pdhLine, colPDH)
        line.set_width(pdhLine, widPD)
        label.set_x(pdhLab, futureTime)
        label.set_y(pdhLab, prevDayHigh)
        label.set_text(pdhLab, "PDH")
        label.set_style(pdhLab, label.style_label_left)
        label.set_textcolor(pdhLab, f_txt())
        label.set_color(pdhLab, f_bg(colPDH))

    if na(pdlLine)
        pdlLine := line.new(dayStartTime, prevDayLow, futureTime, prevDayLow, xloc=xloc.bar_time, extend=extend.none, color=colPDL, width=widPD)
        pdlLab := label.new(futureTime, prevDayLow, "PDL", xloc=xloc.bar_time, style=label.style_label_left, textcolor=f_txt(), color=f_bg(colPDL), size=labelSize)
    else
        line.set_xy1(pdlLine, dayStartTime, prevDayLow)
        line.set_xy2(pdlLine, futureTime, prevDayLow)
        line.set_color(pdlLine, colPDL)
        line.set_width(pdlLine, widPD)
        label.set_x(pdlLab, futureTime)
        label.set_y(pdlLab, prevDayLow)
        label.set_text(pdlLab, "PDL")
        label.set_style(pdlLab, label.style_label_left)
        label.set_textcolor(pdlLab, f_txt())
        label.set_color(pdlLab, f_bg(colPDL))
else
    line.delete(pdhLine), line.delete(pdlLine), label.delete(pdhLab), label.delete(pdlLab)
    pdhLine := na, pdlLine := na, pdhLab := na, pdlLab := na

// Previous NY
if showNY and not na(prevNYHigh)
    if na(nyhLine)
        nyhLine := line.new(dayStartTime, prevNYHigh, futureTime, prevNYHigh, xloc=xloc.bar_time, extend=extend.none, color=colNYH, width=widNY)
        nyhLab := label.new(futureTime, prevNYHigh, "NY H", xloc=xloc.bar_time, style=label.style_label_left, textcolor=f_txt(), color=f_bg(colNYH), size=labelSize)
    else
        line.set_xy1(nyhLine, dayStartTime, prevNYHigh)
        line.set_xy2(nyhLine, futureTime, prevNYHigh)
        line.set_color(nyhLine, colNYH)
        line.set_width(nyhLine, widNY)
        label.set_x(nyhLab, futureTime)
        label.set_y(nyhLab, prevNYHigh)
        label.set_text(nyhLab, "NY H")
        label.set_style(nyhLab, label.style_label_left)
        label.set_textcolor(nyhLab, f_txt())
        label.set_color(nyhLab, f_bg(colNYH))

    if na(nylLine)
        nylLine := line.new(dayStartTime, prevNYLow, futureTime, prevNYLow, xloc=xloc.bar_time, extend=extend.none, color=colNYL, width=widNY)
        nylLab := label.new(futureTime, prevNYLow, "NY L", xloc=xloc.bar_time, style=label.style_label_left, textcolor=f_txt(), color=f_bg(colNYL), size=labelSize)
    else
        line.set_xy1(nylLine, dayStartTime, prevNYLow)
        line.set_xy2(nylLine, futureTime, prevNYLow)
        line.set_color(nylLine, colNYL)
        line.set_width(nylLine, widNY)
        label.set_x(nylLab, futureTime)
        label.set_y(nylLab, prevNYLow)
        label.set_text(nylLab, "NY L")
        label.set_style(nylLab, label.style_label_left)
        label.set_textcolor(nylLab, f_txt())
        label.set_color(nylLab, f_bg(colNYL))
else if not showNY
    line.delete(nyhLine), line.delete(nylLine), label.delete(nyhLab), label.delete(nylLab)
    nyhLine := na, nylLine := na, nyhLab := na, nylLab := na

// Asia
if showAsia and not na(prevAsiaHigh)
    if na(ahLine)
        ahLine := line.new(dayStartTime, prevAsiaHigh, futureTime, prevAsiaHigh, xloc=xloc.bar_time, extend=extend.none, color=colAsiaH, width=widAsia)
        ahLab := label.new(futureTime, prevAsiaHigh, "ASH H", xloc=xloc.bar_time, style=label.style_label_left, textcolor=f_txt(), color=f_bg(colAsiaH), size=labelSize)
    else
        line.set_xy1(ahLine, dayStartTime, prevAsiaHigh)
        line.set_xy2(ahLine, futureTime, prevAsiaHigh)
        line.set_color(ahLine, colAsiaH)
        line.set_width(ahLine, widAsia)
        label.set_x(ahLab, futureTime)
        label.set_y(ahLab, prevAsiaHigh)
        label.set_text(ahLab, "ASH H")
        label.set_style(ahLab, label.style_label_left)
        label.set_textcolor(ahLab, f_txt())
        label.set_color(ahLab, f_bg(colAsiaH))

    if na(alLine)
        alLine := line.new(dayStartTime, prevAsiaLow, futureTime, prevAsiaLow, xloc=xloc.bar_time, extend=extend.none, color=colAsiaL, width=widAsia)
        alLab := label.new(futureTime, prevAsiaLow, "ASH L", xloc=xloc.bar_time, style=label.style_label_left, textcolor=f_txt(), color=f_bg(colAsiaL), size=labelSize)
    else
        line.set_xy1(alLine, dayStartTime, prevAsiaLow)
        line.set_xy2(alLine, futureTime, prevAsiaLow)
        line.set_color(alLine, colAsiaL)
        line.set_width(alLine, widAsia)
        label.set_x(alLab, futureTime)
        label.set_y(alLab, prevAsiaLow)
        label.set_text(alLab, "ASH L")
        label.set_style(alLab, label.style_label_left)
        label.set_textcolor(alLab, f_txt())
        label.set_color(alLab, f_bg(colAsiaL))
else if not showAsia
    line.delete(ahLine), line.delete(alLine), label.delete(ahLab), label.delete(alLab)
    ahLine := na, alLine := na, ahLab := na, alLab := na

// London
if showLondon and not na(prevLondonHigh)
    if na(lnhLine)
        lnhLine := line.new(dayStartTime, prevLondonHigh, futureTime, prevLondonHigh, xloc=xloc.bar_time, extend=extend.none, color=colLondonH, width=widLondon)
        lnhLab := label.new(futureTime, prevLondonHigh, "LDN H", xloc=xloc.bar_time, style=label.style_label_left, textcolor=f_txt(), color=f_bg(colLondonH), size=labelSize)
    else
        line.set_xy1(lnhLine, dayStartTime, prevLondonHigh)
        line.set_xy2(lnhLine, futureTime, prevLondonHigh)
        line.set_color(lnhLine, colLondonH)
        line.set_width(lnhLine, widLondon)
        label.set_x(lnhLab, futureTime)
        label.set_y(lnhLab, prevLondonHigh)
        label.set_text(lnhLab, "LDN H")
        label.set_style(lnhLab, label.style_label_left)
        label.set_textcolor(lnhLab, f_txt())
        label.set_color(lnhLab, f_bg(colLondonH))

    if na(lnlLine)
        lnlLine := line.new(dayStartTime, prevLondonLow, futureTime, prevLondonLow, xloc=xloc.bar_time, extend=extend.none, color=colLondonL, width=widLondon)
        lnlLab := label.new(futureTime, prevLondonLow, "LDN L", xloc=xloc.bar_time, style=label.style_label_left, textcolor=f_txt(), color=f_bg(colLondonL), size=labelSize)
    else
        line.set_xy1(lnlLine, dayStartTime, prevLondonLow)
        line.set_xy2(lnlLine, futureTime, prevLondonLow)
        line.set_color(lnlLine, colLondonL)
        line.set_width(lnlLine, widLondon)
        label.set_x(lnlLab, futureTime)
        label.set_y(lnlLab, prevLondonLow)
        label.set_text(lnlLab, "LDN L")
        label.set_style(lnlLab, label.style_label_left)
        label.set_textcolor(lnlLab, f_txt())
        label.set_color(lnlLab, f_bg(colLondonL))
else if not showLondon
    line.delete(lnhLine), line.delete(lnlLine), label.delete(lnhLab), label.delete(lnlLab)
    lnhLine := na, lnlLine := na, lnhLab := na, lnlLab := na

// Weekly
if showWeek
    if na(whLine)
        whLine := line.new(dayStartTime, prevWeekHigh, futureTime, prevWeekHigh, xloc=xloc.bar_time, extend=extend.none, color=colWH, width=widWeek)
        whLab := label.new(futureTime, prevWeekHigh, "W H", xloc=xloc.bar_time, style=label.style_label_left, textcolor=f_txt(), color=f_bg(colWH), size=labelSize)
    else
        line.set_xy1(whLine, dayStartTime, prevWeekHigh)
        line.set_xy2(whLine, futureTime, prevWeekHigh)
        line.set_color(whLine, colWH)
        line.set_width(whLine, widWeek)
        label.set_x(whLab, futureTime)
        label.set_y(whLab, prevWeekHigh)
        label.set_text(whLab, "W H")
        label.set_style(whLab, label.style_label_left)
        label.set_textcolor(whLab, f_txt())
        label.set_color(whLab, f_bg(colWH))

    if na(wlLine)
        wlLine := line.new(dayStartTime, prevWeekLow, futureTime, prevWeekLow, xloc=xloc.bar_time, extend=extend.none, color=colWL, width=widWeek)
        wlLab := label.new(futureTime, prevWeekLow, "W L", xloc=xloc.bar_time, style=label.style_label_left, textcolor=f_txt(), color=f_bg(colWL), size=labelSize)
    else
        line.set_xy1(wlLine, dayStartTime, prevWeekLow)
        line.set_xy2(wlLine, futureTime, prevWeekLow)
        line.set_color(wlLine, colWL)
        line.set_width(wlLine, widWeek)
        label.set_x(wlLab, futureTime)
        label.set_y(wlLab, prevWeekLow)
        label.set_text(wlLab, "W L")
        label.set_style(wlLab, label.style_label_left)
        label.set_textcolor(wlLab, f_txt())
        label.set_color(wlLab, f_bg(colWL))
else
    line.delete(whLine), line.delete(wlLine), label.delete(whLab), label.delete(wlLab)
    whLine := na, wlLine := na, whLab := na, wlLab := na

// Monthly
if showMonth
    if na(mhLine)
        mhLine := line.new(dayStartTime, prevMonthHigh, futureTime, prevMonthHigh, xloc=xloc.bar_time, extend=extend.none, color=colMH, width=widMonth)
        mhLab := label.new(futureTime, prevMonthHigh, "M H", xloc=xloc.bar_time, style=label.style_label_left, textcolor=f_txt(), color=f_bg(colMH), size=labelSize)
    else
        line.set_xy1(mhLine, dayStartTime, prevMonthHigh)
        line.set_xy2(mhLine, futureTime, prevMonthHigh)
        line.set_color(mhLine, colMH)
        line.set_width(mhLine, widMonth)
        label.set_x(mhLab, futureTime)
        label.set_y(mhLab, prevMonthHigh)
        label.set_text(mhLab, "M H")
        label.set_style(mhLab, label.style_label_left)
        label.set_textcolor(mhLab, f_txt())
        label.set_color(mhLab, f_bg(colMH))

    if na(mlLine)
        mlLine := line.new(dayStartTime, prevMonthLow, futureTime, prevMonthLow, xloc=xloc.bar_time, extend=extend.none, color=colML, width=widMonth)
        mlLab := label.new(futureTime, prevMonthLow, "M L", xloc=xloc.bar_time, style=label.style_label_left, textcolor=f_txt(), color=f_bg(colML), size=labelSize)
    else
        line.set_xy1(mlLine, dayStartTime, prevMonthLow)
        line.set_xy2(mlLine, futureTime, prevMonthLow)
        line.set_color(mlLine, colML)
        line.set_width(mlLine, widMonth)
        label.set_x(mlLab, futureTime)
        label.set_y(mlLab, prevMonthLow)
        label.set_text(mlLab, "M L")
        label.set_style(mlLab, label.style_label_left)
        label.set_textcolor(mlLab, f_txt())
        label.set_color(mlLab, f_bg(colML))
else
    line.delete(mhLine), line.delete(mlLine), label.delete(mhLab), label.delete(mlLab)
    mhLine := na, mlLine := na, mhLab := na, mlLab := na
````

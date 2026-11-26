# NY LIQUIDITY CLEAN PRO BALANCE

- url: https://www.tradingview.com/script/ZQvRvAfH-NY-LIQUIDITY-CLEAN-PRO-BALANCE/
- type: indicator
- pine_id: PUB;6f06ef6d1f194c0fbf5c9896a8160675
- version: 1.0

## Description

level Londres, Asia premarket. H L every day any stock BTC forex Furfures

## Source Code

````pine
//@version=6
indicator("NY LIQUIDITY CLEAN PRO BALANCE", overlay=true, max_lines_count=500, max_labels_count=100)

//====================
// SETTINGS
//====================
tz = "America/New_York"

showMAs      = input.bool(true, "Mostrar EMAs 9/21")
showAsia     = input.bool(true, "Mostrar Asia AH/AL")
showLondon   = input.bool(true, "Mostrar London LH/LL")
showPM       = input.bool(true, "Mostrar Premarket PMH/PML")
showPD       = input.bool(true, "Mostrar PDH/PDL")
showLabels   = input.bool(true, "Mostrar letras actuales")
showZone     = input.bool(true, "Mostrar triángulos zona institucional")

keepDays    = input.int(3, "Días históricos visibles", minval=1, maxval=10)
lineWidth   = input.int(1, "Grosor líneas", minval=1, maxval=3)
labelOffset = input.int(15, "Letras a la derecha", minval=5, maxval=80)
zoneTicks   = input.int(10, "Distancia zona institucional en ticks", minval=1, maxval=200)

//====================
// COLORS
//====================
colAsia      = color.rgb(0, 70, 255)
colLondon    = color.purple
colPM        = color.yellow
colPD        = color.yellow

colAsiaOld   = color.new(colAsia, 75)
colLondonOld = color.new(colLondon, 75)
colPMOld     = color.new(colPM, 75)

colEMA9      = color.new(color.orange, 20)
colEMA21     = color.new(color.blue, 20)

//====================
// EMAs
//====================
ema9  = ta.ema(close, 9)
ema21 = ta.ema(close, 21)

plot(showMAs ? ema9  : na, "EMA 9",  color=colEMA9, linewidth=2)
plot(showMAs ? ema21 : na, "EMA 21", color=colEMA21, linewidth=2)

//====================
// HORARIOS
//====================
asiaSess   = "2000-0300"
londonSess = "0400-0800"
pmSess     = "0830-0930"

//====================
// SESSIONS
//====================
inAsia   = not na(time(timeframe.period, asiaSess, tz))
inLondon = not na(time(timeframe.period, londonSess, tz))
inPM     = not na(time(timeframe.period, pmSess, tz))

asiaStart   = inAsia and not inAsia[1]
londonStart = inLondon and not inLondon[1]
pmStart     = inPM and not inPM[1]

//====================
// FUNCTIONS
//====================
f_newLine(float y, color col, bool extendRight) =>
    line.new(
         time,
         y,
         time + 1,
         y,
         xloc=xloc.bar_time,
         extend=extendRight ? extend.right : extend.none,
         color=col,
         width=lineWidth
    )

f_updateCurrentLine(line ln, float y, color col) =>
    if not na(ln)
        line.set_xy1(ln, time, y)
        line.set_xy2(ln, time + 1, y)
        line.set_color(ln, col)
        line.set_width(ln, lineWidth)
        line.set_extend(ln, extend.right)

f_softenLine(line ln, color col) =>
    if not na(ln)
        line.set_color(ln, col)
        line.set_extend(ln, extend.none)

f_pushLine(line[] arr, line ln, int maxLines) =>
    array.push(arr, ln)
    if array.size(arr) > maxLines
        oldLine = array.shift(arr)
        line.delete(oldLine)

f_textColor(color col) =>
    col == color.yellow ? color.black : color.white

f_setLabel(label lb, float y, string txt, color col) =>
    label result = lb
    txtColor = f_textColor(col)
    if na(result)
        result := label.new(
             bar_index + labelOffset,
             y,
             txt,
             style=label.style_label_left,
             size=size.normal,
             textcolor=txtColor,
             color=color.new(col, 0)
        )
    else
        label.set_xy(result, bar_index + labelOffset, y)
        label.set_text(result, txt)
        label.set_color(result, color.new(col, 0))
        label.set_textcolor(result, txtColor)
    result

f_nearLevel(float level, float zoneSize) =>
    not na(level) and math.abs(close - level) <= zoneSize

//====================
// ARRAYS HISTÓRICOS
//====================
var line[] asiaLines   = array.new_line()
var line[] londonLines = array.new_line()
var line[] pmLines     = array.new_line()

maxSessionLines = keepDays * 2

//====================
// PDH / PDL
//====================
pdh = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_off)
pdl = request.security(syminfo.tickerid, "D", low[1],  barmerge.gaps_off, barmerge.lookahead_off)

var line lnPDH = na
var line lnPDL = na
var label lbPDH = na
var label lbPDL = na

if showPD
    if na(lnPDH)
        lnPDH := f_newLine(pdh, colPD, true)
        lnPDL := f_newLine(pdl, colPD, true)
    else
        f_updateCurrentLine(lnPDH, pdh, colPD)
        f_updateCurrentLine(lnPDL, pdl, colPD)

    if showLabels and barstate.islast
        lbPDH := f_setLabel(lbPDH, pdh, "PDH", colPD)
        lbPDL := f_setLabel(lbPDL, pdl, "PDL", colPD)

//====================
// ASIA
//====================
var float asiaH = na
var float asiaL = na
var line lnAH = na
var line lnAL = na
var label lbAH = na
var label lbAL = na

if asiaStart
    f_softenLine(lnAH, colAsiaOld)
    f_softenLine(lnAL, colAsiaOld)

    asiaH := high
    asiaL := low

    if showAsia
        lnAH := f_newLine(asiaH, colAsia, true)
        lnAL := f_newLine(asiaL, colAsia, true)
        f_pushLine(asiaLines, lnAH, maxSessionLines)
        f_pushLine(asiaLines, lnAL, maxSessionLines)

if inAsia
    asiaH := na(asiaH) ? high : math.max(asiaH, high)
    asiaL := na(asiaL) ? low  : math.min(asiaL, low)

    if showAsia
        f_updateCurrentLine(lnAH, asiaH, colAsia)
        f_updateCurrentLine(lnAL, asiaL, colAsia)

if showAsia and showLabels and barstate.islast
    if not na(asiaH)
        lbAH := f_setLabel(lbAH, asiaH, "AH", colAsia)
    if not na(asiaL)
        lbAL := f_setLabel(lbAL, asiaL, "AL", colAsia)

//====================
// LONDON
//====================
var float londonH = na
var float londonL = na
var line lnLH = na
var line lnLL = na
var label lbLH = na
var label lbLL = na

if londonStart
    f_softenLine(lnLH, colLondonOld)
    f_softenLine(lnLL, colLondonOld)

    londonH := high
    londonL := low

    if showLondon
        lnLH := f_newLine(londonH, colLondon, true)
        lnLL := f_newLine(londonL, colLondon, true)
        f_pushLine(londonLines, lnLH, maxSessionLines)
        f_pushLine(londonLines, lnLL, maxSessionLines)

if inLondon
    londonH := na(londonH) ? high : math.max(londonH, high)
    londonL := na(londonL) ? low  : math.min(londonL, low)

    if showLondon
        f_updateCurrentLine(lnLH, londonH, colLondon)
        f_updateCurrentLine(lnLL, londonL, colLondon)

if showLondon and showLabels and barstate.islast
    if not na(londonH)
        lbLH := f_setLabel(lbLH, londonH, "LH", colLondon)
    if not na(londonL)
        lbLL := f_setLabel(lbLL, londonL, "LL", colLondon)

//====================
// PREMARKET
//====================
var float pmH = na
var float pmL = na
var line lnPMH = na
var line lnPML = na
var label lbPMH = na
var label lbPML = na

if pmStart
    f_softenLine(lnPMH, colPMOld)
    f_softenLine(lnPML, colPMOld)

    pmH := high
    pmL := low

    if showPM
        lnPMH := f_newLine(pmH, colPM, true)
        lnPML := f_newLine(pmL, colPM, true)
        f_pushLine(pmLines, lnPMH, maxSessionLines)
        f_pushLine(pmLines, lnPML, maxSessionLines)

if inPM
    pmH := na(pmH) ? high : math.max(pmH, high)
    pmL := na(pmL) ? low  : math.min(pmL, low)

    if showPM
        f_updateCurrentLine(lnPMH, pmH, colPM)
        f_updateCurrentLine(lnPML, pmL, colPM)

if showPM and showLabels and barstate.islast
    if not na(pmH)
        lbPMH := f_setLabel(lbPMH, pmH, "PMH", colPM)
    if not na(pmL)
        lbPML := f_setLabel(lbPML, pmL, "PML", colPM)

//====================
// TRIÁNGULOS ZONA INSTITUCIONAL
//====================
zoneSize = syminfo.mintick * zoneTicks

nearAH  = showAsia   and f_nearLevel(asiaH, zoneSize)
nearAL  = showAsia   and f_nearLevel(asiaL, zoneSize)
nearLH  = showLondon and f_nearLevel(londonH, zoneSize)
nearLL  = showLondon and f_nearLevel(londonL, zoneSize)
nearPMH = showPM     and f_nearLevel(pmH, zoneSize)
nearPML = showPM     and f_nearLevel(pmL, zoneSize)
nearPDH = showPD     and f_nearLevel(pdh, zoneSize)
nearPDL = showPD     and f_nearLevel(pdl, zoneSize)

asiaZone   = showZone and (nearAH or nearAL)
londonZone = showZone and (nearLH or nearLL)
pmZone     = showZone and (nearPMH or nearPML)
pdZone     = showZone and (nearPDH or nearPDL)

plotshape(asiaZone, title="Zona Asia", style=shape.triangleup, location=location.belowbar, size=size.tiny, color=colAsia)
plotshape(londonZone, title="Zona London", style=shape.triangleup, location=location.belowbar, size=size.tiny, color=colLondon)
plotshape(pmZone, title="Zona Premarket", style=shape.triangleup, location=location.belowbar, size=size.tiny, color=colPM)
plotshape(pdZone, title="Zona PDH/PDL", style=shape.triangleup, location=location.belowbar, size=size.tiny, color=colPD)

//====================
// ALERTAS
//====================
alertcondition(asiaZone, "Zona Asia", "El precio está cerca de AH/AL.")
alertcondition(londonZone, "Zona London", "El precio está cerca de LH/LL.")
alertcondition(pmZone, "Zona Premarket", "El precio está cerca de PMH/PML.")
alertcondition(pdZone, "Zona PDH/PDL", "El precio está cerca de PDH/PDL.")
````

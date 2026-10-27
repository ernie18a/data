# Adokoo Sessions

- url: https://www.tradingview.com/script/uNvNBtyb/
- type: indicator
- pine_id: PUB;c7e71bf5357441bf8916af3bb552fc55
- version: 1.0

## Description

Adokoo Sessions visualisiert die wichtigsten Handelszeiten und Liquiditätsniveaus für den Intraday-Handel in einer übersichtlichen Darstellung.

Funktionen:

• Asia High & Asia Low

• Vortageshoch (PDH) & Vortagestief (PDL)

• Vorwochenhoch (PWH) & Vorwochentief (PWL)

• Tages- und Wochenreferenzlevel

• Automatische Darstellung relevanter Liquiditätsniveaus auf allen Zeiteinheiten

• Klare und aufgeräumte Darstellung ohne unnötige Elemente

Einsatzmöglichkeiten:

• Identifikation potenzieller Liquiditätsziele

• Analyse von Reaktionen an wichtigen Session-Hochs und -Tiefs

• Vorbereitung auf die London- und New-York-Session

• Unterstützung von Price-Action-, Liquiditäts-, SMC- und ICT-basierten Handelsansätzen

• Kombination mit Marktstruktur, Engulfing-Mustern, Fair Value Gaps (FVG) oder Trendfiltern

Der Indikator wurde entwickelt, um die wichtigsten Liquiditäts- und Referenzlevel kompakt darzustellen und die tägliche Chartanalyse effizienter zu gestalten.

## Source Code

````pine

//@version=6
indicator('Adokoo Sessions', overlay = true, max_bars_back = 5000, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)
// Killzones
// ---------------------------------------- Inputs --------------------------------------------------
disp = display.all - display.status_line

kzGR = 'Killzones'
asSH = input(true, '', inline = 'asia', group = kzGR)
asST = input.string('Asian', '', inline = 'asia', group = kzGR, display = disp)
asS = input.session('1900-2300', '', inline = 'asia', group = kzGR, display = disp)
asC = input.color(color.new(#e91e63, 95), '', inline = 'asia', group = kzGR)

ldnOSH = input(true, '', inline = 'ldno', group = kzGR)
ldnOST = input.string('London', '', inline = 'ldno', group = kzGR, display = disp)
ldnOS = input.session('0100-0400', '', inline = 'ldno', group = kzGR, display = disp)
ldnOC = input.color(color.new(#00bcd4, 95), '', inline = 'ldno', group = kzGR)

nySH = input(true, '', inline = 'nyam', group = kzGR)
nyST = input.string('New York AM', '', inline = 'nyam', group = kzGR, display = disp)
nyS = input.session('0730-1000', '', inline = 'nyam', group = kzGR, display = disp)
nyC = input.color(color.new(#ff5d00, 95), '', inline = 'nyam', group = kzGR)

ldnCSH = input(true, '', inline = 'nypm', group = kzGR)
ldnCST = input.string('New York PM', '', inline = 'nypm', group = kzGR, display = disp)
ldnCS = input.session('1230-1500', '', inline = 'nypm', group = kzGR, display = disp)
ldnCC = input.color(color.new(#2157f3, 95), '', inline = 'nypm', group = kzGR)

kzMML = input(true, 'Killzone Lines : Top/Bottom', inline = 'LN', group = kzGR)
kzML = input(false, 'Mean', inline = 'LN', group = kzGR)
kzLE = input(true, 'Extend Top/Bottom', inline = 'LN', group = kzGR)
kzLB = input(true, 'Killzone Labels', group = kzGR)
kzSH = input.int(15, 'Display Killzones within Timeframes Up To', options = [1, 3, 5, 15, 30, 45, 60], group = kzGR, display = disp)
dwmO = input.string('None', 'Open Price of', options = ['Killzones', 'the Day', 'the Week', 'the Month', 'None'], inline = 'OP', group = kzGR, display = disp)
dwmS = input.bool(true, 'Separator', inline = 'OP', group = kzGR)
dwmC = input(color.new(color.gray, 89), '', inline = 'OP', group = kzGR)
dwmL = input.bool(true, 'Label', inline = 'OP', group = kzGR)

// Inputs

// User Defined Types
type bar
	float o = open
	float h = high
	float l = low
	float c = close
	int t = time
	int i = bar_index

type pivotPoint
	float h
	int hi
	bool hx

	float l
	int li
	bool lx

type KZ
	line lnT
	line lnM
	line lnB
	line lnO
	label lb
	label lbO

type DWM
	line ln
	label lb
	// User Defined Types

// Var

bar b = bar.new()

tfM = timeframe.multiplier

nyam = not na(time(timeframe.period, nyS, 'UTC-5')) and nySH and tfM <= kzSH
ldnO = not na(time(timeframe.period, ldnOS, 'UTC-5')) and ldnOSH and tfM <= kzSH
ldnC = not na(time(timeframe.period, ldnCS, 'UTC-5')) and ldnCSH and tfM <= kzSH
asian = not na(time(timeframe.period, asS, 'UTC-5')) and asSH and tfM <= kzSH

inKZ = nyam or ldnO or ldnC or asian
var KZ kz = KZ.new()
var DWM dwm = DWM.new()
// Var

// Functions / Methods
method killzones(KZ _id, _s, _kz, _o, _h, _l, _c, _t, _cr, _tx, _mml, _ml, _lb, _le, _ol, _olC, _olL, areaCss) =>
    var float max = na
    var float mid = na
    var float min = na
    var int sbT = na
    var bool xt = false
    var bool xb = false
    var box area = na
    var tC = color.rgb(color.r(_cr), color.g(_cr), color.b(_cr))

    if _s and not _s[1]
        max := _h
        sbT := _t
        min := _l
        mid := math.avg(max, min)
        area := box.new(bar_index, max, bar_index, min, na, bgcolor = areaCss)

        if _mml
            _id.lnT := line.new(sbT, max, sbT, max, xloc.bar_time, color = tC) //, xt := true
            _id.lnB := line.new(sbT, min, sbT, min, xloc.bar_time, color = tC) //, xb := true
            _id.lnB

        if _ml
            _id.lnM := line.new(sbT, mid, sbT, mid, xloc.bar_time, color = tC, style = line.style_dotted)
            _id.lnM

        if _ol
            _id.lnO := line.new(sbT, _o, sbT, _o, xloc.bar_time, color = color.new(_olC, 0), style = line.style_dotted)

            if _olL
                _id.lbO := label.new(sbT, _o, 'KZO(' + str.tostring(_o, format.mintick) + ')', xloc.bar_time, color = color(na), style = label.style_label_left, textcolor = color.new(_olC, 0), size = size.tiny)
                _id.lbO

        if _lb
            _id.lb := label.new(sbT, max, _tx, xloc.bar_time, color = #ffffff00, style = label.style_label_down, textcolor = tC, size = size.small)
            _id.lb

    if _s
        max := math.max(_h, max)
        min := math.min(_l, min)
        mid := math.avg(max, min)
        xt := true
        xb := true

        area.set_top(max)
        area.set_rightbottom(bar_index, min)

        if _lb
            label.set_x(_id.lb, int(math.avg(_t, sbT)))
            label.set_y(_id.lb, max)

        if _mml
            _id.lnT.set_y1(max)
            _id.lnT.set_xy2(_t, max)
            _id.lnB.set_y1(min)
            _id.lnB.set_xy2(_t, min)

        if _ml
            _id.lnM.set_y1(mid)
            _id.lnM.set_xy2(_t, mid)

        if _ol
            _id.lnO.set_x2(_t)

            if _olL
                _id.lbO.set_x(_t)

    if not _s and _le and not _kz

        if _mml
            if xt
                if _h < _id.lnT.get_y1()
                    _id.lnT.set_x2(_t)
                else
                    _id.lnT.set_x2(_t)
                    xt := false
                    xt

            if xb
                if _l > _id.lnB.get_y1()
                    _id.lnB.set_x2(_t)
                else
                    _id.lnB.set_x2(_t)
                    xb := false
                    xb

        if _ml
            _id.lnM.set_x2(_t)

method pDWM(DWM _id, _tC, _t, _o, _cl, _lbTX, _olL) =>
    if _tC
        _id.lb.delete()
        _id.ln := line.new(_t, _o, _t, _o, xloc.bar_time, extend.none, color.new(_cl, 0), line.style_dotted, 1)

        if _olL
            _id.lb := label.new(_t, _o, _lbTX + '(' + str.tostring(_o, format.mintick) + ')', xloc.bar_time, yloc.price, color(na), label.style_label_left, color.new(_cl, 0), size.tiny)
            _id.lb
    else
        _id.ln.set_x2(_t)

        if _olL
            _id.lb.set_x(_t)
        na
        // Functions / Methods

// Calculations - Killzones
kzO = dwmO == 'Killzones'

kz.killzones(nyam and timeframe.isintraday, inKZ, b.o, b.h, b.l, b.c, b.t, nyC, nyST, kzMML, kzML, kzLB, kzLE, kzO, dwmC, dwmL, nyC)
kz.killzones(ldnO and timeframe.isintraday, inKZ, b.o, b.h, b.l, b.c, b.t, ldnOC, ldnOST, kzMML, kzML, kzLB, kzLE, kzO, dwmC, dwmL, ldnOC)
kz.killzones(ldnC and timeframe.isintraday, inKZ, b.o, b.h, b.l, b.c, b.t, ldnCC, ldnCST, kzMML, kzML, kzLB, kzLE, kzO, dwmC, dwmL, ldnCC)
kz.killzones(asian and timeframe.isintraday, inKZ, b.o, b.h, b.l, b.c, b.t, asC, asST, kzMML, kzML, kzLB, kzLE, kzO, dwmC, dwmL, asC)

[xChg, xTxt] = switch dwmO
    'the Day' => [timeframe.change('D'), 'DO']
    'the Week' => [timeframe.change('W'), 'WO']
    'the Month' => [timeframe.change('M'), 'MO']

if not kzO and timeframe.isintraday and tfM <= kzSH
    dwm.pDWM(xChg, b.t, b.o, dwmC, xTxt, dwmL)

bgcolor(dwmS and not kzO and timeframe.isintraday and tfM <= kzSH ? xChg ? dwmC : na : na)
// Calculations - Killzones
// Killzones -----


//@version=6

showDaily  = input.bool(true, "PDH / PDL anzeigen")
showWeekly = input.bool(true, "PWH / PWL anzeigen")

dailyColor  = input.color(#2962FF, "PDH/PDL Farbe")
weeklyColor = input.color(color.new(#6EA8FF, 15), "PWH/PWL Farbe")
textColor   = input.color(#2962FF, "Textfarbe")

rightBars = input.int(80, "Verlängerung rechts", minval=5, maxval=500)

// Letzte abgeschlossene Tageskerze
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
pdl = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_off)
pdhTime = request.security(syminfo.tickerid, "D", time[1], lookahead=barmerge.lookahead_off)

// Letzte abgeschlossene Wochenkerze
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_off)
pwl = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_off)
pwhTime = request.security(syminfo.tickerid, "W", time[1], lookahead=barmerge.lookahead_off)

futureTime(_bars) =>
    time + timeframe.in_seconds(timeframe.period) * 1000 * _bars

var line pdhLine = na
var line pdlLine = na
var line pwhLine = na
var line pwlLine = na

var label pdhLabel = na
var label pdlLabel = na
var label pwhLabel = na
var label pwlLabel = na

if barstate.islast
    line.delete(pdhLine)
    line.delete(pdlLine)
    line.delete(pwhLine)
    line.delete(pwlLine)

    label.delete(pdhLabel)
    label.delete(pdlLabel)
    label.delete(pwhLabel)
    label.delete(pwlLabel)

    xRight = futureTime(rightBars)

    if showDaily
        pdhLine := line.new(pdhTime, pdh, xRight, pdh, xloc=xloc.bar_time, extend=extend.none, color=dailyColor, width=1)
        pdlLine := line.new(pdhTime, pdl, xRight, pdl, xloc=xloc.bar_time, extend=extend.none, color=dailyColor, width=1)

        pdhLabel := label.new(xRight, pdh, "PDH", xloc=xloc.bar_time, style=label.style_none, textcolor=textColor, size=size.small)
        pdlLabel := label.new(xRight, pdl, "PDL", xloc=xloc.bar_time, style=label.style_none, textcolor=textColor, size=size.small)

    if showWeekly
        pwhLine := line.new(pwhTime, pwh, xRight, pwh, xloc=xloc.bar_time, extend=extend.none, color=weeklyColor, width=1, style=line.style_dashed)
        pwlLine := line.new(pwhTime, pwl, xRight, pwl, xloc=xloc.bar_time, extend=extend.none, color=weeklyColor, width=1, style=line.style_dashed)

        pwhLabel := label.new(xRight, pwh, "PWH", xloc=xloc.bar_time, style=label.style_none, textcolor=weeklyColor, size=size.small)
        pwlLabel := label.new(xRight, pwl, "PWL", xloc=xloc.bar_time, style=label.style_none, textcolor=weeklyColor, size=size.small)
````

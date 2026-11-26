# Key Levels

- url: https://www.tradingview.com/script/tEUsamLm-Key-Levels/
- type: indicator
- pine_id: PUB;c80956b69a01411a9fb134853448a727
- version: 1.0

## Description

Indicators for:
[list]
[*] Previous day High/Low
[*] Overnight High/Low
[*] Opening 30m range High/Low
[/list]

## Source Code

````pine
// © Key Levels Indicator

//@version=6
indicator("Key Levels", overlay=true)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
grp_pd   = "Previous Day High/Low"
showPD   = input.bool(true, "Show Previous Day H/L", group=grp_pd)
pdHiCol  = input.color(color.new(#2962FF, 0), "Previous Day High Color", group=grp_pd)
pdLoCol  = input.color(color.new(#2962FF, 0), "Previous Day Low Color", group=grp_pd)
pdStyle  = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=grp_pd)

grp_on   = "Overnight High/Low"
showON   = input.bool(true, "Show Overnight H/L", group=grp_on)
onHiCol  = input.color(color.new(#FF6D00, 0), "Overnight High Color", group=grp_on)
onLoCol  = input.color(color.new(#FF6D00, 0), "Overnight Low Color", group=grp_on)
onStyle  = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group=grp_on)

grp_or   = "Opening 30min Range"
showOR   = input.bool(true, "Show Opening 30m H/L", group=grp_or)
orHiCol  = input.color(color.new(#00C853, 0), "Opening Range High Color", group=grp_or)
orLoCol  = input.color(color.new(#00C853, 0), "Opening Range Low Color", group=grp_or)
orStyle  = input.string("Dotted", "Line Style", options=["Solid", "Dashed", "Dotted"], group=grp_or)

grp_gen  = "General"
showLabels = input.bool(true, "Show Labels", group=grp_gen)
lineWidth  = input.int(1, "Line Width", minval=1, maxval=4, group=grp_gen)

// ─── SESSION DEFINITIONS ──────────────────────────────────────────────────────
rthSession  = "0930-1600:23456"
onSession   = "1600-0930:23456"
or30Session = "0930-1000:23456"

// ─── HELPER: LINE STYLE ──────────────────────────────────────────────────────
getLineStyle(s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted

// ─── PREVIOUS DAY HIGH/LOW ────────────────────────────────────────────────────
computePD() =>
    var float _rthH       = na
    var float _rthL       = na
    var float _prevH      = na
    var float _prevL      = na
    var int   _rthStartT  = na
    var int   _prevStartT = na
    _isRTH    = not na(time("30", rthSession))
    _rthStart = _isRTH and not _isRTH[1]
    if _rthStart
        _prevH      := _rthH
        _prevL      := _rthL
        _prevStartT := _rthStartT
        _rthH       := high
        _rthL       := low
        _rthStartT  := time
    else if _isRTH
        _rthH := math.max(nz(_rthH, high), high)
        _rthL := math.min(nz(_rthL, low),  low)
    [_prevH, _prevL, _prevStartT]

[prevDayHigh, prevDayLow, prevDayStartTime] = request.security("", "30", computePD())

// ─── OVERNIGHT HIGH/LOW ──────────────────────────────────────────────────────
computeON() =>
    var float _onH           = na
    var float _onL           = na
    var float _finalOnH      = na
    var float _finalOnL      = na
    var int   _onStartT      = na
    var int   _finalOnStartT = na
    _isON     = not na(time("30", onSession))
    _isRTH    = not na(time("30", rthSession))
    _onStart  = _isON and not _isON[1]
    _rthStart = _isRTH and not _isRTH[1]
    if _onStart
        _onH      := high
        _onL      := low
        _onStartT := time
    else if _isON
        _onH := math.max(nz(_onH, high), high)
        _onL := math.min(nz(_onL, low),  low)
    if _rthStart
        _finalOnH      := _onH
        _finalOnL      := _onL
        _finalOnStartT := _onStartT
    [_finalOnH, _finalOnL, _finalOnStartT]

[finalOnHigh, finalOnLow, finalOnStartTime] = request.security("", "30", computeON())

// ─── OPENING 30-MIN RANGE ────────────────────────────────────────────────────
computeOrHigh() =>
    var float _orH      = na
    var float _finalOrH = na
    var bool  _locked   = false
    _isRTH    = not na(time("30", rthSession))
    _rthStart = _isRTH and not _isRTH[1]
    _isOR     = not na(time("30", or30Session))
    _orEnd    = not _isOR and _isOR[1]
    if _rthStart
        _orH    := na
        _locked := false
    if _isOR
        _orH := na(_orH) ? high : math.max(_orH, high)
    if _orEnd and not _locked
        _finalOrH := _orH
        _locked   := true
    _finalOrH

computeOrLow() =>
    var float _orL      = na
    var float _finalOrL = na
    var bool  _locked   = false
    _isRTH    = not na(time("30", rthSession))
    _rthStart = _isRTH and not _isRTH[1]
    _isOR     = not na(time("30", or30Session))
    _orEnd    = not _isOR and _isOR[1]
    if _rthStart
        _orL    := na
        _locked := false
    if _isOR
        _orL := na(_orL) ? low : math.min(_orL, low)
    if _orEnd and not _locked
        _finalOrL := _orL
        _locked   := true
    _finalOrL

finalOrHigh = request.security("", "30", computeOrHigh())
finalOrLow  = request.security("", "30", computeOrLow())

// ─── DETECT VALUE CHANGES FOR DRAWING ────────────────────────────────────────
pdChanged = (prevDayHigh != prevDayHigh[1] or prevDayLow != prevDayLow[1]) and not na(prevDayHigh)
onChanged = (finalOnHigh != finalOnHigh[1] or finalOnLow != finalOnLow[1]) and not na(finalOnHigh)
orChanged = (finalOrHigh != finalOrHigh[1] or finalOrLow != finalOrLow[1]) and not na(finalOrHigh)

// ─── PERSISTENT LINES ────────────────────────────────────────────────────────
var line pdHLine = na
var line pdLLine = na
var label pdHLbl = na
var label pdLLbl = na

var line onHLine = na
var line onLLine = na
var label onHLbl = na
var label onLLbl = na

var line orHLine = na
var line orLLine = na
var label orHLbl = na
var label orLLbl = na

// ─── DRAW PREV DAY ───────────────────────────────────────────────────────────
if pdChanged and showPD
    lStyle = getLineStyle(pdStyle)
    line.delete(pdHLine)
    line.delete(pdLLine)
    label.delete(pdHLbl)
    label.delete(pdLLbl)
    _t1 = prevDayStartTime
    _t2 = _t1 + 24 * 60 * 60 * 1000
    pdHLine := line.new(_t1, prevDayHigh, _t2, prevDayHigh, xloc=xloc.bar_time,
         color=pdHiCol, width=lineWidth, style=lStyle, extend=extend.right)
    pdLLine := line.new(_t1, prevDayLow,  _t2, prevDayLow,  xloc=xloc.bar_time,
         color=pdLoCol, width=lineWidth, style=lStyle, extend=extend.right)
    if showLabels
        pdHLbl := label.new(bar_index, prevDayHigh, "PD High " + str.tostring(prevDayHigh, format.mintick),
             color=color.new(color.white, 100), textcolor=pdHiCol, style=label.style_label_left, size=size.small)
        pdLLbl := label.new(bar_index, prevDayLow,  "PD Low "  + str.tostring(prevDayLow,  format.mintick),
             color=color.new(color.white, 100), textcolor=pdLoCol, style=label.style_label_left, size=size.small)

// ─── DRAW OVERNIGHT ──────────────────────────────────────────────────────────
if onChanged and showON
    lStyle = getLineStyle(onStyle)
    line.delete(onHLine)
    line.delete(onLLine)
    label.delete(onHLbl)
    label.delete(onLLbl)
    _t1 = finalOnStartTime
    _t2 = _t1 + 24 * 60 * 60 * 1000
    onHLine := line.new(_t1, finalOnHigh, _t2, finalOnHigh, xloc=xloc.bar_time,
         color=onHiCol, width=lineWidth, style=lStyle, extend=extend.right)
    onLLine := line.new(_t1, finalOnLow,  _t2, finalOnLow,  xloc=xloc.bar_time,
         color=onLoCol, width=lineWidth, style=lStyle, extend=extend.right)
    if showLabels
        onHLbl := label.new(bar_index, finalOnHigh, "ON High " + str.tostring(finalOnHigh, format.mintick),
             color=color.new(color.white, 100), textcolor=onHiCol, style=label.style_label_left, size=size.small)
        onLLbl := label.new(bar_index, finalOnLow,  "ON Low "  + str.tostring(finalOnLow,  format.mintick),
             color=color.new(color.white, 100), textcolor=onLoCol, style=label.style_label_left, size=size.small)

// ─── DRAW OPENING RANGE ─────────────────────────────────────────────────────
if orChanged and showOR
    lStyle = getLineStyle(orStyle)
    line.delete(orHLine)
    line.delete(orLLine)
    label.delete(orHLbl)
    label.delete(orLLbl)
    orHLine := line.new(bar_index, finalOrHigh, bar_index + 1, finalOrHigh,
         color=orHiCol, width=lineWidth, style=lStyle, extend=extend.right)
    orLLine := line.new(bar_index, finalOrLow,  bar_index + 1, finalOrLow,
         color=orLoCol, width=lineWidth, style=lStyle, extend=extend.right)
    if showLabels
        orHLbl := label.new(bar_index, finalOrHigh, "OR High " + str.tostring(finalOrHigh, format.mintick),
             color=color.new(color.white, 100), textcolor=orHiCol, style=label.style_label_left, size=size.small)
        orLLbl := label.new(bar_index, finalOrLow,  "OR Low "  + str.tostring(finalOrLow,  format.mintick),
             color=color.new(color.white, 100), textcolor=orLoCol, style=label.style_label_left, size=size.small)

// ─── INFO TABLE ──────────────────────────────────────────────────────────────
var table infoTable = table.new(position.top_right, 3, 4, bgcolor=color.new(#1e1e1e, 10), border_width=1, border_color=color.new(color.gray, 50))

if barstate.islast
    table.cell(infoTable, 0, 0, "Level",     text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 0, "High",      text_color=color.white, text_size=size.small)
    table.cell(infoTable, 2, 0, "Low",       text_color=color.white, text_size=size.small)

    table.cell(infoTable, 0, 1, "Prev Day",  text_color=pdHiCol, text_size=size.small)
    table.cell(infoTable, 1, 1, str.tostring(prevDayHigh,  format.mintick), text_color=pdHiCol, text_size=size.small)
    table.cell(infoTable, 2, 1, str.tostring(prevDayLow,   format.mintick), text_color=pdLoCol, text_size=size.small)

    table.cell(infoTable, 0, 2, "Overnight", text_color=onHiCol, text_size=size.small)
    table.cell(infoTable, 1, 2, str.tostring(finalOnHigh,  format.mintick), text_color=onHiCol, text_size=size.small)
    table.cell(infoTable, 2, 2, str.tostring(finalOnLow,   format.mintick), text_color=onLoCol, text_size=size.small)

    table.cell(infoTable, 0, 3, "Open 30m",  text_color=orHiCol, text_size=size.small)
    table.cell(infoTable, 1, 3, str.tostring(finalOrHigh,  format.mintick), text_color=orHiCol, text_size=size.small)
    table.cell(infoTable, 2, 3, str.tostring(finalOrLow,   format.mintick), text_color=orLoCol, text_size=size.small)
````

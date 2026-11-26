# Interest Zones

- url: https://www.tradingview.com/script/442H4CYU/
- type: indicator
- pine_id: PUB;a7c5c576498a42d1beb341aa5a2516a6
- version: 2.0

## Description

Interest Zones is a zone of interest indicator designed for traders who operate supply and demand levels, providing a structural view of the market across multiple timeframes.
What it does:
•	Automatically detects support and resistance zones based on significant swings
•	Displays levels from up to 4 timeframes simultaneously — adapting to your execution timeframe
•	Identifies level breakouts in real time with visual labels
•	Filters weak levels using ATR to show only relevant zones
Features:
•	Visual zones with configurable width around each level
•	Dashboard with active resistance, active support, last breakout, and total active levels
•	Configurable active level limit to keep the chart clean
•	Automatic merging of nearby levels to avoid duplicates
•	Works on any asset and timeframe
•	Fully configurable colors per timeframe

## Source Code

````pine
//@version=6
indicator("Interest Zones", shorttitle="IZones", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ============================================================================
//  INPUTS
// ============================================================================

var grpSwing = "Swing Detection"
pivotLen    = input.int(5,     "Pivot Length",         minval=2, maxval=50,    group=grpSwing)
minStrength = input.float(0.1, "Min ATR Strength",     minval=0.0, maxval=5.0, step=0.05, group=grpSwing)
maxAgeBars  = input.int(500,   "Max Level Age (bars)", minval=20, maxval=20000, group=grpSwing)
// NON-REPAINT: los niveles se anclan SIEMPRE en la barra de confirmacion del
// pivote (bar_index). Nunca se antedatan, por lo que el indicador no repinta.

var grpTF = "Timeframes"
useTF1 = input.bool(true,  "Enable TF 1", group=grpTF, inline="tf1")
tf1    = input.timeframe("60",  "",        group=grpTF, inline="tf1")
col_sup1 = input.color(color.new(#8B9E7A, 0), "S", group=grpTF, inline="tf1")
col_res1 = input.color(color.new(#C4845A, 0), "R", group=grpTF, inline="tf1")

useTF2 = input.bool(true,  "Enable TF 2", group=grpTF, inline="tf2")
tf2    = input.timeframe("240", "",        group=grpTF, inline="tf2")
col_sup2 = input.color(color.new(#7A8FA6, 0), "S", group=grpTF, inline="tf2")
col_res2 = input.color(color.new(#B8956A, 0), "R", group=grpTF, inline="tf2")

useTF3 = input.bool(false, "Enable TF 3", group=grpTF, inline="tf3")
tf3    = input.timeframe("D",   "",        group=grpTF, inline="tf3")
col_sup3 = input.color(color.new(#9E8A7A, 0), "S", group=grpTF, inline="tf3")
col_res3 = input.color(color.new(#A67A5B, 0), "R", group=grpTF, inline="tf3")

useTF4 = input.bool(false, "Enable TF 4", group=grpTF, inline="tf4")
tf4    = input.timeframe("W",   "",        group=grpTF, inline="tf4")
col_sup4 = input.color(color.new(#7A9E8A, 0), "S", group=grpTF, inline="tf4")
col_res4 = input.color(color.new(#C49A6A, 0), "R", group=grpTF, inline="tf4")

var grpLevels = "Levels"
showSupport  = input.bool(true,  "Show Support Levels",    group=grpLevels)
showResist   = input.bool(true,  "Show Resistance Levels", group=grpLevels)
maxLevels    = input.int(8,      "Max Active Levels Each", minval=1, maxval=20, group=grpLevels)
mergeThresh  = input.float(0.5,  "Merge Threshold (ATR x)", minval=0.0, maxval=3.0, step=0.05, group=grpLevels)
showZones    = input.bool(true,  "Show Level Zones",       group=grpLevels)
zoneWidth    = input.float(0.25, "Zone Width (ATR x)",     minval=0.05, maxval=2.0, step=0.05, group=grpLevels)

var grpBreak = "Breakouts"
showBroken   = input.bool(true,  "Show Broken Levels",        group=grpBreak)
breakSens    = input.float(0.1,  "Break Sensitivity (ATR x)", minval=0.0, maxval=2.0, step=0.05, group=grpBreak)
showBreakLbl = input.bool(true,  "Show Break Labels",         group=grpBreak)
maxBroken    = input.int(4,      "Max Broken Levels Shown",   minval=0, maxval=20, group=grpBreak)

var grpVis = "Visuals"
brokenColor = input.color(color.new(#6B7280, 75), "Broken Level Color", group=grpVis)
lineStyleStr = input.string("Solid", "Line Style", options=["Solid","Dashed","Dotted"], group=grpVis)
lineWidth   = input.int(2, "Base Line Width", minval=1, maxval=5, group=grpVis)
useDynamicWidth = input.bool(false, "Enable Longevity Width", group=grpVis)
maxLineWidth    = input.int(7,     "Max Longevity Width",    minval=1, maxval=10, group=grpVis)
showDash     = input.bool(true, "Show Dashboard",                    group=grpVis)
showPriceLbl = input.bool(true, "Show Price Labels on Active Levels", group=grpVis)
labelSizeStr = input.string("small", "Label Size", options=["tiny","small","normal","large","huge"], group=grpVis)

var grpDash = "Dashboard"
dashPos = input.string("Bottom Right", "Dashboard Position", options=["Top Right","Bottom Right","Top Left","Bottom Left"], group=grpDash)

// ============================================================================
//  TYPE
// ============================================================================

type SRLevel
    float  price
    int    barStart
    int    levelType
    bool   active
    bool   broken
    int    breakBar
    bool   retested
    line   mainLine
    box    zoneBox
    label  breakLabel
    label  priceLabel

// ============================================================================
//  STATE
// ============================================================================

var array<SRLevel> levels_tf1       = array.new<SRLevel>()
var array<SRLevel> levels_tf2       = array.new<SRLevel>()
var array<SRLevel> levels_tf3       = array.new<SRLevel>()
var array<SRLevel> levels_tf4       = array.new<SRLevel>()
var array<SRLevel> brokenLevels_tf1 = array.new<SRLevel>()
var array<SRLevel> brokenLevels_tf2 = array.new<SRLevel>()
var array<SRLevel> brokenLevels_tf3 = array.new<SRLevel>()
var array<SRLevel> brokenLevels_tf4 = array.new<SRLevel>()

var string lastBreakDir = "-"
var int    lastBreakBar = na

// ============================================================================
//  HTF DATA (single security call per TF -> 4 calls instead of 12)
//  La fuerza del pivote se calcula DENTRO del contexto del TF (fix del bug):
//  phOut/plOut ya salen filtrados (na si el pivote es debil).
// ============================================================================

// Ademas del precio del pivote, devolvemos el TIMESTAMP real del pivote (time[_len]).
// Ese time se usa para anclar el extremo izquierdo de la linea en la vela exacta
// via xloc.bar_time (cosmetico, NO repinta: la linea se sigue creando al confirmar).
f_tfCalc(_len, _minStr) =>
    float a      = ta.atr(14)
    float atrS   = na(a) or a == 0 ? syminfo.mintick * 10 : a
    float ph     = ta.pivothigh(high, _len, _len)
    float pl     = ta.pivotlow(low,  _len, _len)
    float phNear = math.max(high[_len - 1], high[_len + 1])
    float plNear = math.min(low[_len - 1],  low[_len + 1])
    float phOut  = na(ph) ? na : ((ph - phNear) >= _minStr * atrS ? ph : na)
    float plOut  = na(pl) ? na : ((plNear - pl) >= _minStr * atrS ? pl : na)
    int   phTime = na(phOut) ? na : time[_len]
    int   plTime = na(plOut) ? na : time[_len]
    [atrS, phOut, plOut, phTime, plTime]

[atr_tf1, ph_tf1, pl_tf1, pht_tf1, plt_tf1] = request.security(syminfo.tickerid, tf1, f_tfCalc(pivotLen, minStrength), lookahead=barmerge.lookahead_off)
[atr_tf2, ph_tf2, pl_tf2, pht_tf2, plt_tf2] = request.security(syminfo.tickerid, tf2, f_tfCalc(pivotLen, minStrength), lookahead=barmerge.lookahead_off)
[atr_tf3, ph_tf3, pl_tf3, pht_tf3, plt_tf3] = request.security(syminfo.tickerid, tf3, f_tfCalc(pivotLen, minStrength), lookahead=barmerge.lookahead_off)
[atr_tf4, ph_tf4, pl_tf4, pht_tf4, plt_tf4] = request.security(syminfo.tickerid, tf4, f_tfCalc(pivotLen, minStrength), lookahead=barmerge.lookahead_off)

// ============================================================================
//  HELPERS
// ============================================================================

f_tfName(_tf) =>
    string _t = _tf == "" ? timeframe.period : _tf
    string result = ""
    if _t == "1"
        result := "M1"
    else if _t == "2"
        result := "M2"
    else if _t == "3"
        result := "M3"
    else if _t == "5"
        result := "M5"
    else if _t == "10"
        result := "M10"
    else if _t == "15"
        result := "M15"
    else if _t == "30"
        result := "M30"
    else if _t == "45"
        result := "M45"
    else if _t == "60"
        result := "H1"
    else if _t == "120"
        result := "H2"
    else if _t == "180"
        result := "H3"
    else if _t == "240"
        result := "H4"
    else if _t == "360"
        result := "H6"
    else if _t == "480"
        result := "H8"
    else if _t == "720"
        result := "H12"
    else if _t == "D"
        result := "D1"
    else if _t == "W"
        result := "W1"
    else if _t == "M"
        result := "MN"
    else
        result := _t
    result

f_lineStyle(_s) =>
    _s == "Dashed" ? line.style_dashed : _s == "Dotted" ? line.style_dotted : line.style_solid

f_labelSize(_s) =>
    if _s == "tiny"
        size.tiny
    else if _s == "normal"
        size.normal
    else if _s == "large"
        size.large
    else if _s == "huge"
        size.huge
    else
        size.small

f_isTooClose(_price, _type, _levels, _atrS) =>
    bool tooClose = false
    int sz = array.size(_levels)
    if sz > 0
        for i = 0 to sz - 1
            lvl = array.get(_levels, i)
            if lvl.levelType == _type and lvl.active
                if math.abs(lvl.price - _price) < mergeThresh * _atrS
                    tooClose := true
                    break
    tooClose

// Alta de nivel. Si se llego al tope maxLevels, EXPULSA el mas viejo (antes se
// descartaba el nuevo). El nivel se detecta al confirmar (no repinta); la LINEA
// se dibuja desde la vela del pivote (_pivotTime) via xloc.bar_time (cosmetico).
f_addLevel(_price, _type, _pivotTime, _levels, _atrS, _supColor, _resColor, _tfLabel) =>
    if not f_isTooClose(_price, _type, _levels, _atrS)
        int cnt       = 0
        int oldestIdx = -1
        int oldestBar = na
        int sz = array.size(_levels)
        if sz > 0
            for i = 0 to sz - 1
                lvl = array.get(_levels, i)
                if lvl.levelType == _type and lvl.active
                    cnt += 1
                    if na(oldestBar) or lvl.barStart < oldestBar
                        oldestBar := lvl.barStart
                        oldestIdx := i
        // tope alcanzado -> expulsar el mas antiguo del mismo tipo
        if cnt >= maxLevels and oldestIdx >= 0
            old = array.get(_levels, oldestIdx)
            line.delete(old.mainLine)
            if not na(old.zoneBox)
                box.delete(old.zoneBox)
            if not na(old.priceLabel)
                label.delete(old.priceLabel)
            array.remove(_levels, oldestIdx)
        // barStart = barra de confirmacion (para edad/longevidad, no repinta).
        // El dibujo arranca en la vela del pivote via time.
        int   barStart = bar_index
        int   xLeft    = na(_pivotTime) ? time : _pivotTime
        _baseColor = _type == 1 ? _resColor : _supColor
        _zoneTop   = _price + zoneWidth * _atrS * 0.5
        _zoneBot   = _price - zoneWidth * _atrS * 0.5
        newLine = line.new(
             x1=xLeft, y1=_price, x2=time, y2=_price,
             xloc=xloc.bar_time, extend=extend.right, color=color.new(_baseColor, 0),
             width=lineWidth, style=f_lineStyle(lineStyleStr))
        newBox = showZones ? box.new(
             left=xLeft, top=_zoneTop, right=time, bottom=_zoneBot,
             xloc=xloc.bar_time,
             border_color=color.new(_baseColor, 90),
             bgcolor=color.new(_baseColor, 88),
             extend=extend.right) : na
        _labelText = str.tostring(_price, format.mintick) + " (" + _tfLabel + ")"
        newPriceLbl = showPriceLbl ? label.new(
             x=bar_index + 20, y=_price,
             text=_labelText,
             style=label.style_label_center,
             textcolor=_baseColor,
             color=color.new(chart.bg_color, 0),
             size=f_labelSize(labelSizeStr)) : na
        array.push(_levels, SRLevel.new(
             price=_price, barStart=barStart, levelType=_type,
             active=true, broken=false, breakBar=na, retested=false,
             mainLine=newLine, zoneBox=newBox, breakLabel=na, priceLabel=newPriceLbl))

f_pruneLevels(_levels) =>
    int sz = array.size(_levels)
    if sz > 0
        for i = sz - 1 to 0
            if i < array.size(_levels)
                lvl = array.get(_levels, i)
                if lvl.active and (bar_index - lvl.barStart) > maxAgeBars
                    line.delete(lvl.mainLine)
                    if not na(lvl.zoneBox)
                        box.delete(lvl.zoneBox)
                    if not na(lvl.priceLabel)
                        label.delete(lvl.priceLabel)
                    array.remove(_levels, i)

f_extendLevels(_levels) =>
    int sz = array.size(_levels)
    if sz > 0
        for i = 0 to sz - 1
            lvl = array.get(_levels, i)
            if lvl.active
                if useDynamicWidth
                    age       = bar_index - lvl.barStart
                    calcWidth = math.min(maxLineWidth, 1 + math.floor((age / maxAgeBars) * (maxLineWidth - 1)))
                    line.set_width(lvl.mainLine, int(calcWidth))
                else
                    line.set_width(lvl.mainLine, lineWidth)
                line.set_x2(lvl.mainLine, time)
                if not na(lvl.zoneBox)
                    box.set_right(lvl.zoneBox, time)
                if showPriceLbl and not na(lvl.priceLabel)
                    label.set_x(lvl.priceLabel, bar_index + 10)

// Deteccion de ruptura UNIFICADA para cualquier TF (antes eran 4 bloques
// duplicados de ~100 lineas). El buffer usa el ATR del propio TF del nivel.
// Devuelve la direccion de la ultima ruptura de esta pasada ("-" si ninguna).
f_processBreaks(_levels, _broken, _supCol, _resCol, _atrS) =>
    string dir = "-"
    float breakBuffer = breakSens * _atrS
    int sz = array.size(_levels)
    if sz > 0
        for i = sz - 1 to 0
            if i >= array.size(_levels)
                continue
            lvl = array.get(_levels, i)
            if not lvl.active
                continue
            bool broke = false
            bool bull  = false
            if lvl.levelType == 1 and close > lvl.price + breakBuffer
                broke := true
                bull  := true
            else if lvl.levelType == -1 and close < lvl.price - breakBuffer
                broke := true
                bull  := false
            if broke
                lvl.active   := false
                lvl.broken   := true
                lvl.breakBar := bar_index
                dir := bull ? "Bullish" : "Bearish"
                if not na(lvl.priceLabel)
                    label.delete(lvl.priceLabel)
                    lvl.priceLabel := na
                line.set_color(lvl.mainLine,  color.new(brokenColor, 0))
                line.set_style(lvl.mainLine,  line.style_dotted)
                line.set_width(lvl.mainLine,  1)
                line.set_extend(lvl.mainLine, extend.none)
                line.set_x2(lvl.mainLine,     time)
                if not na(lvl.zoneBox)
                    box.set_bgcolor(lvl.zoneBox,      color.new(brokenColor, 93))
                    box.set_border_color(lvl.zoneBox, color.new(brokenColor, 100))
                    box.set_extend(lvl.zoneBox,       extend.none)
                    box.set_right(lvl.zoneBox,        time)
                    mid = math.avg(lvl.zoneBox.get_top(), lvl.zoneBox.get_bottom())
                    lvl.zoneBox.set_top(mid + breakBuffer)
                    lvl.zoneBox.set_bottom(mid - breakBuffer)
                if showBreakLbl
                    lvl.breakLabel := label.new(x=bar_index, y=lvl.price,
                         text=bull ? "▲ Break" : "▼ Break",
                         style=label.style_label_left,
                         textcolor=bull ? _supCol : _resCol,
                         color=color.new(bull ? #22c55e : #ef4444, 100),
                         size=f_labelSize(labelSizeStr))
                if showBroken
                    array.push(_broken, lvl)
                    if array.size(_broken) > maxBroken and array.size(_broken) > 0
                        old = array.shift(_broken)
                        if not na(old.mainLine)
                            line.delete(old.mainLine)
                        if not na(old.zoneBox)
                            box.delete(old.zoneBox)
                        if not na(old.breakLabel)
                            label.delete(old.breakLabel)
                else
                    line.delete(lvl.mainLine)
                    if not na(lvl.zoneBox)
                        box.delete(lvl.zoneBox)
                array.remove(_levels, i)
    dir

f_activeLevelCount(_levels) =>
    int cnt = 0
    int sz  = array.size(_levels)
    if sz > 0
        for i = 0 to sz - 1
            lvl = array.get(_levels, i)
            if lvl.active
                cnt += 1
    cnt

// Un solo driver por TF (antes: 4 bloques copy-paste de ~100 lineas).
// Devuelve la direccion de ruptura de esta pasada ("-" si ninguna). No toca
// globales: las funciones de Pine no pueden reasignar el scope global.
f_runTF(_use, _levels, _broken, _ph, _pl, _phTime, _plTime, _atrS, _supCol, _resCol, _tfName) =>
    string outDir = "-"
    if _use
        f_pruneLevels(_levels)
        if not na(_ph) and showResist
            f_addLevel(_ph, 1, _phTime, _levels, _atrS, _supCol, _resCol, _tfName)
        if not na(_pl) and showSupport
            f_addLevel(_pl, -1, _plTime, _levels, _atrS, _supCol, _resCol, _tfName)
        d = f_processBreaks(_levels, _broken, _supCol, _resCol, _atrS)
        if d != "-"
            outDir := d
        f_extendLevels(_levels)
    outDir

// ============================================================================
//  PROCESS
// ============================================================================

tfName1 = f_tfName(tf1)
tfName2 = f_tfName(tf2)
tfName3 = f_tfName(tf3)
tfName4 = f_tfName(tf4)

dir1 = f_runTF(useTF1, levels_tf1, brokenLevels_tf1, ph_tf1, pl_tf1, pht_tf1, plt_tf1, atr_tf1, col_sup1, col_res1, tfName1)
dir2 = f_runTF(useTF2, levels_tf2, brokenLevels_tf2, ph_tf2, pl_tf2, pht_tf2, plt_tf2, atr_tf2, col_sup2, col_res2, tfName2)
dir3 = f_runTF(useTF3, levels_tf3, brokenLevels_tf3, ph_tf3, pl_tf3, pht_tf3, plt_tf3, atr_tf3, col_sup3, col_res3, tfName3)
dir4 = f_runTF(useTF4, levels_tf4, brokenLevels_tf4, ph_tf4, pl_tf4, pht_tf4, plt_tf4, atr_tf4, col_sup4, col_res4, tfName4)

lastDir = dir4 != "-" ? dir4 : dir3 != "-" ? dir3 : dir2 != "-" ? dir2 : dir1
if lastDir != "-"
    lastBreakDir := lastDir
    lastBreakBar := bar_index

// ============================================================================
//  DASHBOARD
// ============================================================================

// Soporte/resistencia mas cercanos de un array (devuelve [sup, res], sin globales)
f_scanNearest(_use, _levels) =>
    float s = na
    float r = na
    if _use
        int sz = array.size(_levels)
        if sz > 0
            for i = 0 to sz - 1
                lvl = array.get(_levels, i)
                if lvl.active
                    if lvl.levelType == -1 and lvl.price < close
                        if na(s) or lvl.price > s
                            s := lvl.price
                    if lvl.levelType == 1 and lvl.price > close
                        if na(r) or lvl.price < r
                            r := lvl.price
    [s, r]

f_maxNa(_a, _b) => na(_a) ? _b : na(_b) ? _a : math.max(_a, _b)
f_minNa(_a, _b) => na(_a) ? _b : na(_b) ? _a : math.min(_a, _b)

[s1, r1] = f_scanNearest(useTF1, levels_tf1)
[s2, r2] = f_scanNearest(useTF2, levels_tf2)
[s3, r3] = f_scanNearest(useTF3, levels_tf3)
[s4, r4] = f_scanNearest(useTF4, levels_tf4)

float nearestSup = f_maxNa(f_maxNa(s1, s2), f_maxNa(s3, s4))
float nearestRes = f_minNa(f_minNa(r1, r2), f_minNa(r3, r4))

totalActive = f_activeLevelCount(levels_tf1) + f_activeLevelCount(levels_tf2) + f_activeLevelCount(levels_tf3) + f_activeLevelCount(levels_tf4)

activeTFs  = ""
activeTFs := useTF1 ? activeTFs + tfName1 + " " : activeTFs
activeTFs := useTF2 ? activeTFs + tfName2 + " " : activeTFs
activeTFs := useTF3 ? activeTFs + tfName3 + " " : activeTFs
activeTFs := useTF4 ? activeTFs + tfName4       : activeTFs
activeTFs := str.trim(activeTFs)

var table dashTable = na

if showDash
    tablePos = switch dashPos
        "Top Right"    => position.top_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        => position.bottom_right

    if barstate.isfirst
        dashTable := table.new(
             position=tablePos, columns=2, rows=6,
             bgcolor=color.new(#0d1117, 5),
             border_color=color.new(#30363d, 40), border_width=1,
             frame_color=color.new(#30363d, 20), frame_width=1)

    if barstate.islast and not na(dashTable)
        table.cell(dashTable, 0, 0, "Zones",
             text_color=color.new(#f0f6fc, 0), text_size=size.normal,
             bgcolor=color.new(#161b22, 0), text_halign=text.align_center)
        table.merge_cells(dashTable, 0, 0, 1, 0)

        table.cell(dashTable, 0, 1, "Timeframes",
             text_color=color.new(#8b949e, 0), text_size=size.normal,
             bgcolor=color.new(#0d1117, 10), text_halign=text.align_left)
        table.cell(dashTable, 1, 1, activeTFs == "" ? "None" : activeTFs,
             text_color=color.new(#f0f6fc, 0), text_size=size.normal,
             bgcolor=color.new(#0d1117, 10), text_halign=text.align_right)

        table.cell(dashTable, 0, 2, "Resistance",
             text_color=color.new(#8b949e, 0), text_size=size.normal,
             bgcolor=color.new(#0d1117, 10), text_halign=text.align_left)
        table.cell(dashTable, 1, 2,
             na(nearestRes) ? "-" : str.tostring(nearestRes, format.mintick),
             text_color=na(nearestRes) ? color.new(#484f58, 0) : color.new(#C4845A, 0),
             text_size=size.normal, bgcolor=color.new(#0d1117, 10), text_halign=text.align_right)

        table.cell(dashTable, 0, 3, "Support",
             text_color=color.new(#8b949e, 0), text_size=size.normal,
             bgcolor=color.new(#0d1117, 10), text_halign=text.align_left)
        table.cell(dashTable, 1, 3,
             na(nearestSup) ? "-" : str.tostring(nearestSup, format.mintick),
             text_color=na(nearestSup) ? color.new(#484f58, 0) : color.new(#8B9E7A, 0),
             text_size=size.normal, bgcolor=color.new(#0d1117, 10), text_halign=text.align_right)

        table.cell(dashTable, 0, 4, "Last Break",
             text_color=color.new(#8b949e, 0), text_size=size.normal,
             bgcolor=color.new(#0d1117, 10), text_halign=text.align_left)
        breakDirColor = lastBreakDir == "Bullish" ? color.new(#8B9E7A, 0) : lastBreakDir == "Bearish" ? color.new(#C4845A, 0) : color.new(#484f58, 0)
        table.cell(dashTable, 1, 4, lastBreakDir,
             text_color=breakDirColor, text_size=size.normal,
             bgcolor=color.new(#0d1117, 10), text_halign=text.align_right)

        table.cell(dashTable, 0, 5, "Active Levels",
             text_color=color.new(#8b949e, 0), text_size=size.normal,
             bgcolor=color.new(#0d1117, 10), text_halign=text.align_left)
        table.cell(dashTable, 1, 5, str.tostring(totalActive),
             text_color=color.new(#f0f6fc, 0), text_size=size.normal,
             bgcolor=color.new(#0d1117, 10), text_halign=text.align_right)
````

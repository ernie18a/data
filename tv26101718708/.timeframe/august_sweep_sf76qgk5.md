# August sweep

- url: https://www.tradingview.com/script/sF76QGk5/
- type: indicator
- pine_id: PUB;ec6338fa3ffb4bb1aeb9ce19aa56bc60
- version: 1.0

## Description

Detecta Sweeps en diferents temporalitats 
Eliminat el "nivell protector" visual (ja no es dibuixen aquestes línies discontínues)
↕️ Invertides les fletxes: sweep de màxim → Sweep ↓ (perquè el moviment esperat és cap avall), sweep de mínim → Sweep ↑. També invertides al panell scanner.
✅ Afegida casella "Només últim Sweep" i "Només últim CHoCH" (per defecte activades)
🔧 Afluixat el CHoCH: ara la invalidació mira close en comptes de high/low, perquè abans una sola metxa el cancel·lava i per això no en veies

## Source Code

````pine
//@version=6
// AUGUST SWEEP — Sweep + CHoCH + FVG (no mitigada) + Scanner multi-actiu/TF
indicator("August sweep", shorttitle = "August sweep",
     overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// =================== CONFIGURACIÓ ===================
grpC = "Configuració"
pivotLen  = input.int(5, "Longitud pivot", minval = 2, group = grpC)
atrMult   = input.float(0.10, "Profunditat mín. sweep (× ATR)", step = 0.05, group = grpC)
scanFresh = input.int(20, "Frescor sweep (barres, scanner)", minval = 1, group = grpC)

grpV = "Gràfic actual"
showSweep     = input.bool(true, "Mostrar Sweeps", group = grpV)
onlyLastSweep = input.bool(true, "Només últim Sweep", group = grpV)
showChoch     = input.bool(true, "Mostrar CHoCH",  group = grpV)
onlyLastChoch = input.bool(true, "Només últim CHoCH", group = grpV)
showFVG       = input.bool(true, "Mostrar FVG (només no mitigades)", group = grpV)
chochWin      = input.int(30, "Finestra post-sweep per CHoCH (barres)", minval = 3, group = grpV)
protectMax    = input.int(30, "Distància màx. pivot protector (barres)", minval = 3, group = grpV)
fvgMinSize    = input.float(0.25, "Mida mín. FVG (× ATR)", step = 0.05, group = grpV)

// =================== TEMPORALITATS ===================
grpT = "Temporalitats"
tf1    = input.timeframe("5",   "TF 1", group = grpT, inline = "1")
tf1_on = input.bool(true, "Mostrar", group = grpT, inline = "1")
tf2    = input.timeframe("15",  "TF 2", group = grpT, inline = "2")
tf2_on = input.bool(true, "Mostrar", group = grpT, inline = "2")
tf3    = input.timeframe("60",  "TF 3", group = grpT, inline = "3")
tf3_on = input.bool(true, "Mostrar", group = grpT, inline = "3")
tf4    = input.timeframe("240", "TF 4", group = grpT, inline = "4")
tf4_on = input.bool(true, "Mostrar", group = grpT, inline = "4")

// =================== ACTIUS ===================
grpS = "Actius"
sym1     = input.symbol("OANDA:SPX500USD", "Actiu 1",  group = grpS, inline = "s1")
sym1_on  = input.bool(true, "✓", group = grpS, inline = "s1")
sym2     = input.symbol("OANDA:NAS100USD", "Actiu 2",  group = grpS, inline = "s2")
sym2_on  = input.bool(true, "✓", group = grpS, inline = "s2")
sym3     = input.symbol("OANDA:EURUSD",    "Actiu 3",  group = grpS, inline = "s3")
sym3_on  = input.bool(true, "✓", group = grpS, inline = "s3")
sym4     = input.symbol("OANDA:GBPUSD",    "Actiu 4",  group = grpS, inline = "s4")
sym4_on  = input.bool(true, "✓", group = grpS, inline = "s4")
sym5     = input.symbol("OANDA:USDCHF",    "Actiu 5",  group = grpS, inline = "s5")
sym5_on  = input.bool(true, "✓", group = grpS, inline = "s5")
sym6     = input.symbol("OANDA:USDCAD",    "Actiu 6",  group = grpS, inline = "s6")
sym6_on  = input.bool(true, "✓", group = grpS, inline = "s6")
sym7     = input.symbol("OANDA:XAUUSD",    "Actiu 7",  group = grpS, inline = "s7")
sym7_on  = input.bool(true, "✓", group = grpS, inline = "s7")
sym8     = input.symbol("OANDA:USDJPY",    "Actiu 8",  group = grpS, inline = "s8")
sym8_on  = input.bool(false, "✓", group = grpS, inline = "s8")
sym9     = input.symbol("OANDA:AUDUSD",    "Actiu 9",  group = grpS, inline = "s9")
sym9_on  = input.bool(false, "✓", group = grpS, inline = "s9")
sym10    = input.symbol("OANDA:NZDUSD",    "Actiu 10", group = grpS, inline = "s10")
sym10_on = input.bool(false, "✓", group = grpS, inline = "s10")

grpP = "Panell"
panelPos = input.string("bottom_right", "Posició panell",
     options = ["top_right", "top_left", "bottom_right", "bottom_left", "middle_right"], group = grpP)

grpCol = "Colors"
sweepBearCol = input.color(#ff9800, "Sweep màxim",   group = grpCol)
sweepBullCol = input.color(#ffeb3b, "Sweep mínim",   group = grpCol)
chochBearCol = input.color(#ff1744, "CHoCH baixista",group = grpCol)
chochBullCol = input.color(#00e676, "CHoCH alcista", group = grpCol)
fvgBullCol   = input.color(color.new(#00c853, 80), "FVG alcista",  group = grpCol)
fvgBearCol   = input.color(color.new(#c62828, 80), "FVG baixista", group = grpCol)

// =================== FUNCIÓ SCAN SWEEP (scanner remot) ===================
f_scanSweep() =>
    a  = ta.atr(14)
    md = a * atrMult
    phS = ta.pivothigh(high, pivotLen, pivotLen)
    plS = ta.pivotlow (low,  pivotLen, pivotLen)
    var float lPH = na
    var float lPL = na
    if not na(phS)
        lPH := phS
    if not na(plS)
        lPL := plS
    sH = not na(lPH) and high >= lPH + md and close < lPH and high[1] <= lPH
    sL = not na(lPL) and low  <= lPL - md and close > lPL and low[1]  >= lPL
    var int lastSHbar = na
    var int lastSLbar = na
    if sH
        lastSHbar := bar_index
    if sL
        lastSLbar := bar_index
    ageH = na(lastSHbar) ? 9999 : bar_index - lastSHbar
    ageL = na(lastSLbar) ? 9999 : bar_index - lastSLbar
    state = 0
    if ageH < ageL and ageH <= scanFresh
        state := 1
    if ageL < ageH and ageL <= scanFresh
        state := -1
    age = math.min(ageH, ageL)
    [state, age]

// =================== GRÀFIC ACTUAL: PIVOTS ===================
atr = ta.atr(14)
minDepth = atr * atrMult

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow (low,  pivotLen, pivotLen)

var float[] phArr    = array.new_float()
var int[]   phBarArr = array.new_int()
var float[] plArr    = array.new_float()
var int[]   plBarArr = array.new_int()

if not na(ph)
    array.push(phArr, ph)
    array.push(phBarArr, bar_index - pivotLen)
    if array.size(phArr) > 20
        array.shift(phArr)
        array.shift(phBarArr)

if not na(pl)
    array.push(plArr, pl)
    array.push(plBarArr, bar_index - pivotLen)
    if array.size(plArr) > 20
        array.shift(plArr)
        array.shift(plBarArr)

lastPH    = array.size(phArr) > 0 ? array.get(phArr, array.size(phArr) - 1) : na
lastPHbar = array.size(phArr) > 0 ? array.get(phBarArr, array.size(phBarArr) - 1) : na
lastPL    = array.size(plArr) > 0 ? array.get(plArr, array.size(plArr) - 1) : na
lastPLbar = array.size(plArr) > 0 ? array.get(plBarArr, array.size(plBarArr) - 1) : na

// =================== SWEEPS ===================
var float sweepHighLevel = na
var int   sweepHighBar   = na
var bool  sweepHighActive = false
var float sweepLowLevel  = na
var int   sweepLowBar    = na
var bool  sweepLowActive  = false

var float protectLow  = na
var int   protectLowBar  = na
var float protectHigh = na
var int   protectHighBar = na

// Referències per "només últim"
var line  lnSweepH = na
var label lbSweepH = na
var line  lnSweepL = na
var label lbSweepL = na
var line  lnChochB = na
var label lbChochB = na
var line  lnChochU = na
var label lbChochU = na

sweepHigh = not na(lastPH) and not sweepHighActive and high >= lastPH + minDepth and close < lastPH and high[1] <= lastPH
sweepLow  = not na(lastPL) and not sweepLowActive  and low  <= lastPL - minDepth and close > lastPL and low[1]  >= lastPL

findProtectLow() =>
    float lvl = na
    int   br  = na
    if array.size(plArr) > 0
        for i = array.size(plArr) - 1 to 0
            pb = array.get(plBarArr, i)
            if (bar_index - pb) <= protectMax
                lvl := array.get(plArr, i)
                br  := pb
                break
    [lvl, br]

findProtectHigh() =>
    float lvl = na
    int   br  = na
    if array.size(phArr) > 0
        for i = array.size(phArr) - 1 to 0
            pb = array.get(phBarArr, i)
            if (bar_index - pb) <= protectMax
                lvl := array.get(phArr, i)
                br  := pb
                break
    [lvl, br]

if sweepHigh
    sweepHighLevel  := lastPH
    sweepHighBar    := bar_index
    sweepHighActive := true
    [pLvl, pBar] = findProtectLow()
    protectLow    := pLvl
    protectLowBar := pBar
    if showSweep
        if onlyLastSweep
            if not na(lnSweepH)
                line.delete(lnSweepH)
            if not na(lbSweepH)
                label.delete(lbSweepH)
            if not na(lnSweepL)
                line.delete(lnSweepL)
            if not na(lbSweepL)
                label.delete(lbSweepL)
        lnSweepH := line.new(lastPHbar, lastPH, bar_index, lastPH, color = sweepBearCol, width = 2, style = line.style_dotted)
        lbSweepH := label.new(bar_index, high, "Sweep ↓",
             color = color.new(color.black, 100), textcolor = sweepBearCol,
             style = label.style_label_down, size = size.small)

if sweepLow
    sweepLowLevel  := lastPL
    sweepLowBar    := bar_index
    sweepLowActive := true
    [pLvl, pBar] = findProtectHigh()
    protectHigh    := pLvl
    protectHighBar := pBar
    if showSweep
        if onlyLastSweep
            if not na(lnSweepH)
                line.delete(lnSweepH)
            if not na(lbSweepH)
                label.delete(lbSweepH)
            if not na(lnSweepL)
                line.delete(lnSweepL)
            if not na(lbSweepL)
                label.delete(lbSweepL)
        lnSweepL := line.new(lastPLbar, lastPL, bar_index, lastPL, color = sweepBullCol, width = 2, style = line.style_dotted)
        lbSweepL := label.new(bar_index, low, "Sweep ↑",
             color = color.new(color.black, 100), textcolor = sweepBullCol,
             style = label.style_label_up, size = size.small)

// =================== CHoCH ===================
// Caducitat de la finestra
if sweepHighActive and (bar_index - sweepHighBar) > chochWin
    sweepHighActive := false
    protectLow      := na
if sweepLowActive and (bar_index - sweepLowBar) > chochWin
    sweepLowActive := false
    protectHigh     := na

// Invalidació: close sobre el sweep (abans era high/low, massa estricte)
if sweepHighActive and close > sweepHighLevel and bar_index > sweepHighBar
    sweepHighActive := false
    protectLow      := na
if sweepLowActive and close < sweepLowLevel and bar_index > sweepLowBar
    sweepLowActive := false
    protectHigh     := na

bodyTop = math.max(open, close)
bodyBot = math.min(open, close)

chochBear = sweepHighActive and not na(protectLow)  and close < protectLow  and bodyBot < protectLow
chochBull = sweepLowActive  and not na(protectHigh) and close > protectHigh and bodyTop > protectHigh

if chochBear and showChoch
    if onlyLastChoch
        if not na(lnChochB)
            line.delete(lnChochB)
        if not na(lbChochB)
            label.delete(lbChochB)
        if not na(lnChochU)
            line.delete(lnChochU)
        if not na(lbChochU)
            label.delete(lbChochU)
    lnChochB := line.new(protectLowBar, protectLow, bar_index, protectLow, color = chochBearCol, width = 3)
    lbChochB := label.new(bar_index, protectLow, "CHoCH ↓",
         color = color.new(color.black, 100), textcolor = chochBearCol,
         style = label.style_label_up, size = size.small)
    sweepHighActive := false
    protectLow      := na

if chochBull and showChoch
    if onlyLastChoch
        if not na(lnChochB)
            line.delete(lnChochB)
        if not na(lbChochB)
            label.delete(lbChochB)
        if not na(lnChochU)
            line.delete(lnChochU)
        if not na(lbChochU)
            label.delete(lbChochU)
    lnChochU := line.new(protectHighBar, protectHigh, bar_index, protectHigh, color = chochBullCol, width = 3)
    lbChochU := label.new(bar_index, protectHigh, "CHoCH ↑",
         color = color.new(color.black, 100), textcolor = chochBullCol,
         style = label.style_label_down, size = size.small)
    sweepLowActive := false
    protectHigh     := na

// =================== FVG amb RETALL (només no mitigades) ===================
var box[]   fvgBoxes = array.new_box()
var label[] fvgLbls  = array.new_label()
var float[] fvgTops  = array.new_float()
var float[] fvgBots  = array.new_float()
var int[]   fvgDirs  = array.new_int()

if showFVG
    if low > high[2]
        fvgSize = low - high[2]
        if fvgSize >= atr * fvgMinSize
            topLvl = low
            botLvl = high[2]
            b = box.new(bar_index - 2, topLvl, bar_index, botLvl,
                 border_color = color.new(#00c853, 60), border_width = 1,
                 bgcolor = fvgBullCol, extend = extend.right)
            l = label.new(bar_index, (topLvl + botLvl) / 2, "FVG",
                 color = color.new(color.black, 100), textcolor = #00c853,
                 style = label.style_label_left, size = size.small)
            array.push(fvgBoxes, b)
            array.push(fvgLbls,  l)
            array.push(fvgTops,  topLvl)
            array.push(fvgBots,  botLvl)
            array.push(fvgDirs,  1)
    if high < low[2]
        fvgSize = low[2] - high
        if fvgSize >= atr * fvgMinSize
            topLvl = low[2]
            botLvl = high
            b = box.new(bar_index - 2, topLvl, bar_index, botLvl,
                 border_color = color.new(#c62828, 60), border_width = 1,
                 bgcolor = fvgBearCol, extend = extend.right)
            l = label.new(bar_index, (topLvl + botLvl) / 2, "FVG",
                 color = color.new(color.black, 100), textcolor = #c62828,
                 style = label.style_label_left, size = size.small)
            array.push(fvgBoxes, b)
            array.push(fvgLbls,  l)
            array.push(fvgTops,  topLvl)
            array.push(fvgBots,  botLvl)
            array.push(fvgDirs,  -1)

if array.size(fvgBoxes) > 0
    for i = array.size(fvgBoxes) - 1 to 0
        topLvl = array.get(fvgTops, i)
        botLvl = array.get(fvgBots, i)
        dir    = array.get(fvgDirs, i)
        bx     = array.get(fvgBoxes, i)
        lb     = array.get(fvgLbls,  i)
        if dir == 1
            if low < topLvl
                if low <= botLvl
                    box.delete(bx)
                    label.delete(lb)
                    array.remove(fvgBoxes, i)
                    array.remove(fvgLbls,  i)
                    array.remove(fvgTops,  i)
                    array.remove(fvgBots,  i)
                    array.remove(fvgDirs,  i)
                else
                    newTop = low
                    array.set(fvgTops, i, newTop)
                    box.set_top(bx, newTop)
                    label.set_y(lb, (newTop + botLvl) / 2)
        else
            if high > botLvl
                if high >= topLvl
                    box.delete(bx)
                    label.delete(lb)
                    array.remove(fvgBoxes, i)
                    array.remove(fvgLbls,  i)
                    array.remove(fvgTops,  i)
                    array.remove(fvgBots,  i)
                    array.remove(fvgDirs,  i)
                else
                    newBot = high
                    array.set(fvgBots, i, newBot)
                    box.set_bottom(bx, newBot)
                    label.set_y(lb, (topLvl + newBot) / 2)

// =================== CRIDES SCANNER (10 actius × 4 TFs) ===================
[s1a, a1a] = request.security(sym1, tf1, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s1b, a1b] = request.security(sym1, tf2, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s1c, a1c] = request.security(sym1, tf3, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s1d, a1d] = request.security(sym1, tf4, f_scanSweep(), lookahead = barmerge.lookahead_off)

[s2a, a2a] = request.security(sym2, tf1, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s2b, a2b] = request.security(sym2, tf2, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s2c, a2c] = request.security(sym2, tf3, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s2d, a2d] = request.security(sym2, tf4, f_scanSweep(), lookahead = barmerge.lookahead_off)

[s3a, a3a] = request.security(sym3, tf1, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s3b, a3b] = request.security(sym3, tf2, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s3c, a3c] = request.security(sym3, tf3, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s3d, a3d] = request.security(sym3, tf4, f_scanSweep(), lookahead = barmerge.lookahead_off)

[s4a, a4a] = request.security(sym4, tf1, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s4b, a4b] = request.security(sym4, tf2, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s4c, a4c] = request.security(sym4, tf3, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s4d, a4d] = request.security(sym4, tf4, f_scanSweep(), lookahead = barmerge.lookahead_off)

[s5a, a5a] = request.security(sym5, tf1, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s5b, a5b] = request.security(sym5, tf2, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s5c, a5c] = request.security(sym5, tf3, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s5d, a5d] = request.security(sym5, tf4, f_scanSweep(), lookahead = barmerge.lookahead_off)

[s6a, a6a] = request.security(sym6, tf1, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s6b, a6b] = request.security(sym6, tf2, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s6c, a6c] = request.security(sym6, tf3, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s6d, a6d] = request.security(sym6, tf4, f_scanSweep(), lookahead = barmerge.lookahead_off)

[s7a, a7a] = request.security(sym7, tf1, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s7b, a7b] = request.security(sym7, tf2, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s7c, a7c] = request.security(sym7, tf3, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s7d, a7d] = request.security(sym7, tf4, f_scanSweep(), lookahead = barmerge.lookahead_off)

[s8a, a8a] = request.security(sym8, tf1, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s8b, a8b] = request.security(sym8, tf2, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s8c, a8c] = request.security(sym8, tf3, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s8d, a8d] = request.security(sym8, tf4, f_scanSweep(), lookahead = barmerge.lookahead_off)

[s9a, a9a] = request.security(sym9, tf1, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s9b, a9b] = request.security(sym9, tf2, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s9c, a9c] = request.security(sym9, tf3, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s9d, a9d] = request.security(sym9, tf4, f_scanSweep(), lookahead = barmerge.lookahead_off)

[s10a, a10a] = request.security(sym10, tf1, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s10b, a10b] = request.security(sym10, tf2, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s10c, a10c] = request.security(sym10, tf3, f_scanSweep(), lookahead = barmerge.lookahead_off)
[s10d, a10d] = request.security(sym10, tf4, f_scanSweep(), lookahead = barmerge.lookahead_off)

// =================== RENDERITZACIÓ PANELL ===================
// Fletxes invertides també al scanner: sweep high → ↓, sweep low → ↑
stateTxt(s, age) => s == 1 ? "↓ " + str.tostring(age) : s == -1 ? "↑ " + str.tostring(age) : "—"
stateCol(s)    => s == 1 ? sweepBearCol : s == -1 ? sweepBullCol : color.new(color.gray, 30)
stateTxtCol(s) => s == 1 ? color.black  : s == -1 ? color.black  : color.silver

shortName(s) =>
    parts = str.split(s, ":")
    array.size(parts) > 1 ? array.get(parts, 1) : s

posMap(p) => p == "top_left" ? position.top_left : p == "top_right" ? position.top_right : p == "bottom_left" ? position.bottom_left : p == "bottom_right" ? position.bottom_right : position.middle_right

var table t = table.new(posMap(panelPos), 5, 11, border_width = 1, border_color = color.new(color.gray, 50))

if barstate.islast
    bg  = color.new(color.black, 20)
    hdr = color.new(color.black, 0)

    table.cell(t, 0, 0, "AUGUST SWEEP", bgcolor = hdr, text_color = color.yellow, text_size = size.small, text_halign = text.align_center)
    if tf1_on
        table.cell(t, 1, 0, tf1, bgcolor = hdr, text_color = color.yellow, text_size = size.small, text_halign = text.align_center)
    if tf2_on
        table.cell(t, 2, 0, tf2, bgcolor = hdr, text_color = color.yellow, text_size = size.small, text_halign = text.align_center)
    if tf3_on
        table.cell(t, 3, 0, tf3, bgcolor = hdr, text_color = color.yellow, text_size = size.small, text_halign = text.align_center)
    if tf4_on
        table.cell(t, 4, 0, tf4, bgcolor = hdr, text_color = color.yellow, text_size = size.small, text_halign = text.align_center)

    if sym1_on
        table.cell(t, 0, 1, shortName(sym1), bgcolor = bg, text_color = color.white, text_size = size.small)
        if tf1_on
            table.cell(t, 1, 1, stateTxt(s1a, a1a), bgcolor = color.new(stateCol(s1a), 40), text_color = stateTxtCol(s1a), text_size = size.small, text_halign = text.align_center)
        if tf2_on
            table.cell(t, 2, 1, stateTxt(s1b, a1b), bgcolor = color.new(stateCol(s1b), 40), text_color = stateTxtCol(s1b), text_size = size.small, text_halign = text.align_center)
        if tf3_on
            table.cell(t, 3, 1, stateTxt(s1c, a1c), bgcolor = color.new(stateCol(s1c), 40), text_color = stateTxtCol(s1c), text_size = size.small, text_halign = text.align_center)
        if tf4_on
            table.cell(t, 4, 1, stateTxt(s1d, a1d), bgcolor = color.new(stateCol(s1d), 40), text_color = stateTxtCol(s1d), text_size = size.small, text_halign = text.align_center)

    if sym2_on
        table.cell(t, 0, 2, shortName(sym2), bgcolor = bg, text_color = color.white, text_size = size.small)
        if tf1_on
            table.cell(t, 1, 2, stateTxt(s2a, a2a), bgcolor = color.new(stateCol(s2a), 40), text_color = stateTxtCol(s2a), text_size = size.small, text_halign = text.align_center)
        if tf2_on
            table.cell(t, 2, 2, stateTxt(s2b, a2b), bgcolor = color.new(stateCol(s2b), 40), text_color = stateTxtCol(s2b), text_size = size.small, text_halign = text.align_center)
        if tf3_on
            table.cell(t, 3, 2, stateTxt(s2c, a2c), bgcolor = color.new(stateCol(s2c), 40), text_color = stateTxtCol(s2c), text_size = size.small, text_halign = text.align_center)
        if tf4_on
            table.cell(t, 4, 2, stateTxt(s2d, a2d), bgcolor = color.new(stateCol(s2d), 40), text_color = stateTxtCol(s2d), text_size = size.small, text_halign = text.align_center)

    if sym3_on
        table.cell(t, 0, 3, shortName(sym3), bgcolor = bg, text_color = color.white, text_size = size.small)
        if tf1_on
            table.cell(t, 1, 3, stateTxt(s3a, a3a), bgcolor = color.new(stateCol(s3a), 40), text_color = stateTxtCol(s3a), text_size = size.small, text_halign = text.align_center)
        if tf2_on
            table.cell(t, 2, 3, stateTxt(s3b, a3b), bgcolor = color.new(stateCol(s3b), 40), text_color = stateTxtCol(s3b), text_size = size.small, text_halign = text.align_center)
        if tf3_on
            table.cell(t, 3, 3, stateTxt(s3c, a3c), bgcolor = color.new(stateCol(s3c), 40), text_color = stateTxtCol(s3c), text_size = size.small, text_halign = text.align_center)
        if tf4_on
            table.cell(t, 4, 3, stateTxt(s3d, a3d), bgcolor = color.new(stateCol(s3d), 40), text_color = stateTxtCol(s3d), text_size = size.small, text_halign = text.align_center)

    if sym4_on
        table.cell(t, 0, 4, shortName(sym4), bgcolor = bg, text_color = color.white, text_size = size.small)
        if tf1_on
            table.cell(t, 1, 4, stateTxt(s4a, a4a), bgcolor = color.new(stateCol(s4a), 40), text_color = stateTxtCol(s4a), text_size = size.small, text_halign = text.align_center)
        if tf2_on
            table.cell(t, 2, 4, stateTxt(s4b, a4b), bgcolor = color.new(stateCol(s4b), 40), text_color = stateTxtCol(s4b), text_size = size.small, text_halign = text.align_center)
        if tf3_on
            table.cell(t, 3, 4, stateTxt(s4c, a4c), bgcolor = color.new(stateCol(s4c), 40), text_color = stateTxtCol(s4c), text_size = size.small, text_halign = text.align_center)
        if tf4_on
            table.cell(t, 4, 4, stateTxt(s4d, a4d), bgcolor = color.new(stateCol(s4d), 40), text_color = stateTxtCol(s4d), text_size = size.small, text_halign = text.align_center)

    if sym5_on
        table.cell(t, 0, 5, shortName(sym5), bgcolor = bg, text_color = color.white, text_size = size.small)
        if tf1_on
            table.cell(t, 1, 5, stateTxt(s5a, a5a), bgcolor = color.new(stateCol(s5a), 40), text_color = stateTxtCol(s5a), text_size = size.small, text_halign = text.align_center)
        if tf2_on
            table.cell(t, 2, 5, stateTxt(s5b, a5b), bgcolor = color.new(stateCol(s5b), 40), text_color = stateTxtCol(s5b), text_size = size.small, text_halign = text.align_center)
        if tf3_on
            table.cell(t, 3, 5, stateTxt(s5c, a5c), bgcolor = color.new(stateCol(s5c), 40), text_color = stateTxtCol(s5c), text_size = size.small, text_halign = text.align_center)
        if tf4_on
            table.cell(t, 4, 5, stateTxt(s5d, a5d), bgcolor = color.new(stateCol(s5d), 40), text_color = stateTxtCol(s5d), text_size = size.small, text_halign = text.align_center)

    if sym6_on
        table.cell(t, 0, 6, shortName(sym6), bgcolor = bg, text_color = color.white, text_size = size.small)
        if tf1_on
            table.cell(t, 1, 6, stateTxt(s6a, a6a), bgcolor = color.new(stateCol(s6a), 40), text_color = stateTxtCol(s6a), text_size = size.small, text_halign = text.align_center)
        if tf2_on
            table.cell(t, 2, 6, stateTxt(s6b, a6b), bgcolor = color.new(stateCol(s6b), 40), text_color = stateTxtCol(s6b), text_size = size.small, text_halign = text.align_center)
        if tf3_on
            table.cell(t, 3, 6, stateTxt(s6c, a6c), bgcolor = color.new(stateCol(s6c), 40), text_color = stateTxtCol(s6c), text_size = size.small, text_halign = text.align_center)
        if tf4_on
            table.cell(t, 4, 6, stateTxt(s6d, a6d), bgcolor = color.new(stateCol(s6d), 40), text_color = stateTxtCol(s6d), text_size = size.small, text_halign = text.align_center)

    if sym7_on
        table.cell(t, 0, 7, shortName(sym7), bgcolor = bg, text_color = color.white, text_size = size.small)
        if tf1_on
            table.cell(t, 1, 7, stateTxt(s7a, a7a), bgcolor = color.new(stateCol(s7a), 40), text_color = stateTxtCol(s7a), text_size = size.small, text_halign = text.align_center)
        if tf2_on
            table.cell(t, 2, 7, stateTxt(s7b, a7b), bgcolor = color.new(stateCol(s7b), 40), text_color = stateTxtCol(s7b), text_size = size.small, text_halign = text.align_center)
        if tf3_on
            table.cell(t, 3, 7, stateTxt(s7c, a7c), bgcolor = color.new(stateCol(s7c), 40), text_color = stateTxtCol(s7c), text_size = size.small, text_halign = text.align_center)
        if tf4_on
            table.cell(t, 4, 7, stateTxt(s7d, a7d), bgcolor = color.new(stateCol(s7d), 40), text_color = stateTxtCol(s7d), text_size = size.small, text_halign = text.align_center)

    if sym8_on
        table.cell(t, 0, 8, shortName(sym8), bgcolor = bg, text_color = color.white, text_size = size.small)
        if tf1_on
            table.cell(t, 1, 8, stateTxt(s8a, a8a), bgcolor = color.new(stateCol(s8a), 40), text_color = stateTxtCol(s8a), text_size = size.small, text_halign = text.align_center)
        if tf2_on
            table.cell(t, 2, 8, stateTxt(s8b, a8b), bgcolor = color.new(stateCol(s8b), 40), text_color = stateTxtCol(s8b), text_size = size.small, text_halign = text.align_center)
        if tf3_on
            table.cell(t, 3, 8, stateTxt(s8c, a8c), bgcolor = color.new(stateCol(s8c), 40), text_color = stateTxtCol(s8c), text_size = size.small, text_halign = text.align_center)
        if tf4_on
            table.cell(t, 4, 8, stateTxt(s8d, a8d), bgcolor = color.new(stateCol(s8d), 40), text_color = stateTxtCol(s8d), text_size = size.small, text_halign = text.align_center)

    if sym9_on
        table.cell(t, 0, 9, shortName(sym9), bgcolor = bg, text_color = color.white, text_size = size.small)
        if tf1_on
            table.cell(t, 1, 9, stateTxt(s9a, a9a), bgcolor = color.new(stateCol(s9a), 40), text_color = stateTxtCol(s9a), text_size = size.small, text_halign = text.align_center)
        if tf2_on
            table.cell(t, 2, 9, stateTxt(s9b, a9b), bgcolor = color.new(stateCol(s9b), 40), text_color = stateTxtCol(s9b), text_size = size.small, text_halign = text.align_center)
        if tf3_on
            table.cell(t, 3, 9, stateTxt(s9c, a9c), bgcolor = color.new(stateCol(s9c), 40), text_color = stateTxtCol(s9c), text_size = size.small, text_halign = text.align_center)
        if tf4_on
            table.cell(t, 4, 9, stateTxt(s9d, a9d), bgcolor = color.new(stateCol(s9d), 40), text_color = stateTxtCol(s9d), text_size = size.small, text_halign = text.align_center)

    if sym10_on
        table.cell(t, 0, 10, shortName(sym10), bgcolor = bg, text_color = color.white, text_size = size.small)
        if tf1_on
            table.cell(t, 1, 10, stateTxt(s10a, a10a), bgcolor = color.new(stateCol(s10a), 40), text_color = stateTxtCol(s10a), text_size = size.small, text_halign = text.align_center)
        if tf2_on
            table.cell(t, 2, 10, stateTxt(s10b, a10b), bgcolor = color.new(stateCol(s10b), 40), text_color = stateTxtCol(s10b), text_size = size.small, text_halign = text.align_center)
        if tf3_on
            table.cell(t, 3, 10, stateTxt(s10c, a10c), bgcolor = color.new(stateCol(s10c), 40), text_color = stateTxtCol(s10c), text_size = size.small, text_halign = text.align_center)
        if tf4_on
            table.cell(t, 4, 10, stateTxt(s10d, a10d), bgcolor = color.new(stateCol(s10d), 40), text_color = stateTxtCol(s10d), text_size = size.small, text_halign = text.align_center)

// =================== ALERTES ===================
alertcondition(sweepHigh, "Sweep màxim")
alertcondition(sweepLow,  "Sweep mínim")
alertcondition(chochBear, "CHoCH baixista")
alertcondition(chochBull, "CHoCH alcista")
````

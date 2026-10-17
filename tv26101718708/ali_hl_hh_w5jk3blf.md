# ALI HL  HH

- url: https://www.tradingview.com/script/W5jK3BlF/
- type: indicator
- pine_id: PUB;30f2e767de4744a489a529e4c58bdec1
- version: 1.0

## Description

Indica HH luego de 3 LH marcando entrada en el 88,6 de fibo

## Source Code

````pine
//@version=6
indicator("LH→HH Fib | Entradas + SL + TP", overlay=true,
     max_lines_count=200,
     max_labels_count=200,
     max_boxes_count=100)

// ══════════════════════════════════════════════════════════════
//  PARÁMETROS
// ══════════════════════════════════════════════════════════════
grp1 = "── Detección de Pivotes ──"
lookback = input.int(5, "Lookback para pivots (barras)", minval=2, maxval=20, group=grp1)
minLH    = input.int(3, "Mínimo de LH consecutivos",    minval=2, maxval=10,  group=grp1)

grp2 = "── Visibilidad ──"
showLabels = input.bool(true, "Mostrar etiquetas LH/HH",  group=grp2)
showFibBox = input.bool(true, "Mostrar caja Fibonacci",    group=grp2)
showEntry1 = input.bool(true, "Mostrar Entrada 1 (0.886)", group=grp2)
showEntry2 = input.bool(true, "Mostrar Entrada 2 (1.272)", group=grp2)
showTable  = input.bool(true, "Mostrar tabla estadísticas",group=grp2)

grp3 = "── Colores ──"
lhColor = input.color(color.new(color.orange,  0), "Etiqueta LH",       group=grp3)
hhColor = input.color(color.new(color.lime,    0), "Etiqueta HH",       group=grp3)
col_e1  = input.color(color.new(color.yellow,  0), "Entrada 1 · 0.886", group=grp3)
col_sl1 = input.color(color.new(color.red,     0), "SL 1 · 1.272",      group=grp3)
col_tp1 = input.color(color.new(color.teal,    0), "TP 1 · 1:3",        group=grp3)
col_e2  = input.color(color.new(color.fuchsia, 0), "Entrada 2 · 1.272", group=grp3)
col_sl2 = input.color(color.new(color.red,    20), "SL 2 · 1.618",      group=grp3)
col_tp2 = input.color(color.new(color.aqua,    0), "TP 2 · 1:4",        group=grp3)

// ══════════════════════════════════════════════════════════════
//  PIVOTES
// ══════════════════════════════════════════════════════════════
pivotHigh = ta.pivothigh(high, lookback, lookback)

// ══════════════════════════════════════════════════════════════
//  ESTADO
// ══════════════════════════════════════════════════════════════
var int     lhCount  = 0
var float[] phPrices = array.new_float(0)
var int[]   phBars   = array.new_int(0)

var float lvl_e1  = na
var float lvl_sl1 = na
var float lvl_sl2 = na
var float lvl_tp1 = na
var float lvl_tp2 = na

var bool waitingE1 = false
var bool inTrade1  = false
var bool waitingE2 = false
var bool inTrade2  = false
var bool tp1Hit    = false
var bool sl1Hit    = false
var bool tp2Hit    = false
var bool sl2Hit    = false

// ══════════════════════════════════════════════════════════════
//  ESTADÍSTICAS
// ══════════════════════════════════════════════════════════════
var int wTP1    = 0
var int wSL1    = 0
var int wTP2    = 0
var int wSL2    = 0
var int totTP1  = 0
var int totSL1  = 0
var int totTP2  = 0
var int totSL2  = 0

isNewWeek = ta.change(weekofyear) != 0 or ta.change(year) != 0
if isNewWeek
    wTP1 := 0
    wSL1 := 0
    wTP2 := 0
    wSL2 := 0

// ══════════════════════════════════════════════════════════════
//  ARRAYS DE OBJETOS DEL SETUP ACTIVO
// ══════════════════════════════════════════════════════════════
var line[]  activeLines  = array.new<line>()
var box[]   activeBoxes  = array.new<box>()
var label[] activeLabels = array.new<label>()

f_delete() =>
    int n = array.size(activeLines)
    if n > 0
        for i = 0 to n - 1
            line.delete(array.get(activeLines, i))
    int m = array.size(activeBoxes)
    if m > 0
        for i = 0 to m - 1
            box.delete(array.get(activeBoxes, i))
    int k = array.size(activeLabels)
    if k > 0
        for i = 0 to k - 1
            label.delete(array.get(activeLabels, i))
    array.clear(activeLines)
    array.clear(activeBoxes)
    array.clear(activeLabels)

// ══════════════════════════════════════════════════════════════
//  DETECCIÓN LH / HH
// ══════════════════════════════════════════════════════════════
if not na(pivotHigh)
    currentPH     = pivotHigh
    currentPH_bar = bar_index - lookback

    array.push(phPrices, currentPH)
    array.push(phBars,   currentPH_bar)
    if array.size(phPrices) > 20
        array.shift(phPrices)
        array.shift(phBars)

    if array.size(phPrices) >= 2
        n    = array.size(phPrices)
        curr = array.get(phPrices, n - 1)
        prev = array.get(phPrices, n - 2)

        if curr < prev
            // Lower High
            lhCount := lhCount + 1
            if showLabels
                label.new(x=currentPH_bar, y=curr,
                     text="LH(" + str.tostring(lhCount) + ")",
                     style=label.style_label_down,
                     color=lhColor, textcolor=color.black, size=size.small)

        else if curr > prev
            // Higher High → activar setup si hay suficientes LH
            if lhCount >= minLH
                f_delete()

                startBar  = array.get(phBars, n - 2)
                barsBack  = bar_index - startBar
                lowestLow = high[0]
                if barsBack > 0 and barsBack < 500
                    for i = 0 to barsBack
                        if low[i] < lowestLow
                            lowestLow := low[i]

                setupHH       = curr
                setupSwingLow = lowestLow
                rng           = setupHH - setupSwingLow

                lvl_e1  := setupHH       - rng * 0.886
                lvl_sl1 := setupSwingLow - rng * 0.272
                lvl_sl2 := setupSwingLow - rng * 0.618
                r1       = math.abs(lvl_e1  - lvl_sl1)
                r2       = math.abs(lvl_sl1 - lvl_sl2)
                lvl_tp1 := lvl_e1  + r1 * 3.0
                lvl_tp2 := lvl_sl1 + r2 * 4.0

                waitingE1 := true
                inTrade1  := false
                waitingE2 := false
                inTrade2  := false
                tp1Hit    := false
                sl1Hit    := false
                tp2Hit    := false
                sl2Hit    := false

                // Label HH
                if showLabels
                    array.push(activeLabels, label.new(
                         x=currentPH_bar, y=curr,
                         text="HH ✓  (" + str.tostring(lhCount) + " LH)",
                         style=label.style_label_down,
                         color=hhColor, textcolor=color.black, size=size.normal))

                _extR = bar_index + 80

                // Caja Fibonacci de rango
                if showFibBox
                    array.push(activeBoxes, box.new(
                         left=currentPH_bar, top=setupHH,
                         right=_extR, bottom=setupSwingLow,
                         border_color=color.new(color.gray, 55),
                         bgcolor=color.new(color.gray, 93), extend=extend.right))

                // Entrada 1
                if showEntry1
                    array.push(activeBoxes, box.new(
                         left=currentPH_bar, top=lvl_tp1, right=_extR, bottom=lvl_e1,
                         border_color=color.new(col_tp1, 70),
                         bgcolor=color.new(col_tp1, 88), extend=extend.right))
                    array.push(activeBoxes, box.new(
                         left=currentPH_bar, top=lvl_e1, right=_extR, bottom=lvl_sl1,
                         border_color=color.new(col_sl1, 70),
                         bgcolor=color.new(col_sl1, 90), extend=extend.right))
                    array.push(activeLines, line.new(currentPH_bar, lvl_tp1, _extR, lvl_tp1,
                         color=col_tp1, width=2, style=line.style_dotted, extend=extend.right))
                    array.push(activeLines, line.new(currentPH_bar, lvl_e1,  _extR, lvl_e1,
                         color=col_e1,  width=3, style=line.style_solid,  extend=extend.right))
                    array.push(activeLines, line.new(currentPH_bar, lvl_sl1, _extR, lvl_sl1,
                         color=col_sl1, width=2, style=line.style_dashed, extend=extend.right))
                    array.push(activeLabels, label.new(_extR, lvl_tp1,
                         text="🎯 TP 1 · 1:3\n" + str.tostring(math.round(lvl_tp1, 5)),
                         style=label.style_label_left,
                         color=col_tp1, textcolor=color.black, size=size.small))
                    array.push(activeLabels, label.new(_extR, lvl_e1,
                         text="📍 E1 · 0.886\n" + str.tostring(math.round(lvl_e1, 5)),
                         style=label.style_label_left,
                         color=col_e1, textcolor=color.black, size=size.normal))
                    array.push(activeLabels, label.new(_extR, lvl_sl1,
                         text="🛑 SL 1 · 1.272\n" + str.tostring(math.round(lvl_sl1, 5)),
                         style=label.style_label_left,
                         color=col_sl1, textcolor=color.white, size=size.small))

                // Entrada 2
                if showEntry2
                    array.push(activeBoxes, box.new(
                         left=currentPH_bar, top=lvl_tp2, right=_extR, bottom=lvl_sl1,
                         border_color=color.new(col_tp2, 70),
                         bgcolor=color.new(col_tp2, 90), extend=extend.right))
                    array.push(activeBoxes, box.new(
                         left=currentPH_bar, top=lvl_sl1, right=_extR, bottom=lvl_sl2,
                         border_color=color.new(col_sl2, 70),
                         bgcolor=color.new(col_sl2, 90), extend=extend.right))
                    array.push(activeLines, line.new(currentPH_bar, lvl_tp2, _extR, lvl_tp2,
                         color=col_tp2, width=2, style=line.style_dotted, extend=extend.right))
                    array.push(activeLines, line.new(currentPH_bar, lvl_sl1, _extR, lvl_sl1,
                         color=col_e2,  width=3, style=line.style_solid,  extend=extend.right))
                    array.push(activeLines, line.new(currentPH_bar, lvl_sl2, _extR, lvl_sl2,
                         color=col_sl2, width=2, style=line.style_dashed, extend=extend.right))
                    array.push(activeLabels, label.new(_extR + 18, lvl_tp2,
                         text="🎯 TP 2 · 1:4\n" + str.tostring(math.round(lvl_tp2, 5)),
                         style=label.style_label_left,
                         color=col_tp2, textcolor=color.black, size=size.small))
                    array.push(activeLabels, label.new(_extR + 18, lvl_sl1,
                         text="📍 E2 · 1.272\n" + str.tostring(math.round(lvl_sl1, 5)),
                         style=label.style_label_left,
                         color=col_e2, textcolor=color.black, size=size.normal))
                    array.push(activeLabels, label.new(_extR + 18, lvl_sl2,
                         text="🛑 SL 2 · 1.618\n" + str.tostring(math.round(lvl_sl2, 5)),
                         style=label.style_label_left,
                         color=col_sl2, textcolor=color.white, size=size.small))

                alert("🔔 Setup LH→HH | E1: " + str.tostring(math.round(lvl_e1,4)) +
                     " | TP1: " + str.tostring(math.round(lvl_tp1,4)) +
                     " | SL1: " + str.tostring(math.round(lvl_sl1,4)), alert.freq_once_per_bar)

            lhCount := 0
        else
            lhCount := 0

// ══════════════════════════════════════════════════════════════
//  SEGUIMIENTO BARRA A BARRA — TP / SL
// ══════════════════════════════════════════════════════════════
setupResolved = (tp1Hit or sl1Hit) and (not showEntry2 or tp2Hit or sl2Hit or tp1Hit)

if not na(lvl_e1) and not setupResolved

    // ── Precio toca E1 ───────────────────────────────────────
    if waitingE1 and low <= lvl_e1
        waitingE1 := false
        inTrade1  := true
        waitingE2 := true

    // ── Trade 1 abierto ──────────────────────────────────────
    if inTrade1 and not tp1Hit and not sl1Hit
        if high >= lvl_tp1
            tp1Hit    := true
            inTrade1  := false
            waitingE2 := false
            inTrade2  := false
            wTP1      += 1
            totTP1    += 1
            f_delete()
            label.new(x=bar_index, y=high,
                 text="✅ TP 1 · 1:3",
                 style=label.style_label_down,
                 color=col_tp1, textcolor=color.black, size=size.normal)
            alert("✅ TP1 alcanzado: " + str.tostring(math.round(lvl_tp1,4)), alert.freq_once_per_bar)

        else if not waitingE2 and low <= lvl_sl1
            sl1Hit   := true
            inTrade1 := false
            wSL1     += 1
            totSL1   += 1
            f_delete()
            label.new(x=bar_index, y=low,
                 text="❌ SL 1",
                 style=label.style_label_up,
                 color=col_sl1, textcolor=color.white, size=size.normal)
            alert("❌ SL1 tocado: " + str.tostring(math.round(lvl_sl1,4)), alert.freq_once_per_bar)

    // ── Precio baja a 1.272 → Trade 2 ───────────────────────
    if showEntry2 and waitingE2 and not tp1Hit
        if low <= lvl_sl1
            waitingE2 := false
            inTrade2  := true

    // ── Trade 2 abierto ──────────────────────────────────────
    if inTrade2 and not tp2Hit and not sl2Hit
        if high >= lvl_tp2
            tp2Hit   := true
            inTrade2 := false
            wTP2     += 1
            totTP2   += 1
            f_delete()
            label.new(x=bar_index, y=high,
                 text="✅ TP 2 · 1:4",
                 style=label.style_label_down,
                 color=col_tp2, textcolor=color.black, size=size.normal)
            alert("✅ TP2 alcanzado: " + str.tostring(math.round(lvl_tp2,4)), alert.freq_once_per_bar)

        else if low <= lvl_sl2
            sl2Hit   := true
            inTrade2 := false
            wSL2     += 1
            totSL2   += 1
            f_delete()
            label.new(x=bar_index, y=low,
                 text="❌ SL 2",
                 style=label.style_label_up,
                 color=col_sl2, textcolor=color.white, size=size.normal)
            alert("❌ SL2 tocado: " + str.tostring(math.round(lvl_sl2,4)), alert.freq_once_per_bar)

// ══════════════════════════════════════════════════════════════
//  TABLA DE ESTADÍSTICAS
// ══════════════════════════════════════════════════════════════
if showTable and barstate.islast
    var table t = table.new(position.top_right, 3, 11,
         bgcolor      = color.new(#0d0d0d, 5),
         border_color = color.new(color.gray, 55),
         border_width = 1,
         frame_color  = color.new(color.gray, 25),
         frame_width  = 2)

    // ── Cabecera ──────────────────────────────────────────────
    table.cell(t, 0, 0, "LH→HH Fib",  text_color=color.new(color.yellow,0), text_size=size.normal, bgcolor=color.new(#1a1a1a,0), text_halign=text.align_center)
    table.cell(t, 1, 0, "Semana",      text_color=color.new(color.yellow,0), text_size=size.small,  bgcolor=color.new(#1a1a1a,0), text_halign=text.align_center)
    table.cell(t, 2, 0, "Total",       text_color=color.new(color.yellow,0), text_size=size.small,  bgcolor=color.new(#1a1a1a,0), text_halign=text.align_center)

    // ── E1 ───────────────────────────────────────────────────
    table.cell(t, 0, 1, "── E1 · 0.886 ──", text_color=color.new(color.yellow,40), text_size=size.tiny, bgcolor=color.new(#111111,0), text_halign=text.align_center)
    table.cell(t, 1, 1, "TP 1:3",            text_color=color.new(color.yellow,40), text_size=size.tiny, bgcolor=color.new(#111111,0), text_halign=text.align_center)
    table.cell(t, 2, 1, "SL 1.272",          text_color=color.new(color.yellow,40), text_size=size.tiny, bgcolor=color.new(#111111,0), text_halign=text.align_center)

    table.cell(t, 0, 2, "✅ TP1", text_color=color.white, text_size=size.small, bgcolor=color.new(#0a1a0a,0))
    table.cell(t, 1, 2, str.tostring(wTP1),   text_color=color.new(color.teal,0), text_size=size.small, bgcolor=color.new(#0a1a0a,0), text_halign=text.align_center)
    table.cell(t, 2, 2, str.tostring(totTP1), text_color=color.new(color.teal,0), text_size=size.small, bgcolor=color.new(#0a1a0a,0), text_halign=text.align_center)

    table.cell(t, 0, 3, "❌ SL1", text_color=color.white, text_size=size.small, bgcolor=color.new(#1a0a0a,0))
    table.cell(t, 1, 3, str.tostring(wSL1),   text_color=color.new(color.red,0), text_size=size.small, bgcolor=color.new(#1a0a0a,0), text_halign=text.align_center)
    table.cell(t, 2, 3, str.tostring(totSL1), text_color=color.new(color.red,0), text_size=size.small, bgcolor=color.new(#1a0a0a,0), text_halign=text.align_center)

    wkWR1  = (wTP1  + wSL1)  > 0 ? math.round(wTP1  / (wTP1  + wSL1)  * 100, 1) : 0.0
    totWR1 = (totTP1 + totSL1) > 0 ? math.round(totTP1 / (totTP1 + totSL1) * 100, 1) : 0.0
    wkWR1col  = wkWR1  >= 60 ? color.new(color.lime,0) : wkWR1  >= 45 ? color.new(color.yellow,0) : color.new(color.red,0)
    totWR1col = totWR1 >= 60 ? color.new(color.lime,0) : totWR1 >= 45 ? color.new(color.yellow,0) : color.new(color.red,0)
    table.cell(t, 0, 4, "🎯 WR E1", text_color=color.white, text_size=size.small, bgcolor=color.new(#1a1a1a,0))
    table.cell(t, 1, 4, str.tostring(wkWR1)  + "%", text_color=wkWR1col,  text_size=size.normal, bgcolor=color.new(#1a1a1a,0), text_halign=text.align_center)
    table.cell(t, 2, 4, str.tostring(totWR1) + "%", text_color=totWR1col, text_size=size.normal, bgcolor=color.new(#1a1a1a,0), text_halign=text.align_center)

    // ── E2 ───────────────────────────────────────────────────
    table.cell(t, 0, 5, "── E2 · 1.272 ──", text_color=color.new(color.fuchsia,40), text_size=size.tiny, bgcolor=color.new(#111111,0), text_halign=text.align_center)
    table.cell(t, 1, 5, "TP 1:4",            text_color=color.new(color.fuchsia,40), text_size=size.tiny, bgcolor=color.new(#111111,0), text_halign=text.align_center)
    table.cell(t, 2, 5, "SL 1.618",          text_color=color.new(color.fuchsia,40), text_size=size.tiny, bgcolor=color.new(#111111,0), text_halign=text.align_center)

    table.cell(t, 0, 6, "✅ TP2", text_color=color.white, text_size=size.small, bgcolor=color.new(#0a1a0a,0))
    table.cell(t, 1, 6, str.tostring(wTP2),   text_color=color.new(color.aqua,0), text_size=size.small, bgcolor=color.new(#0a1a0a,0), text_halign=text.align_center)
    table.cell(t, 2, 6, str.tostring(totTP2), text_color=color.new(color.aqua,0), text_size=size.small, bgcolor=color.new(#0a1a0a,0), text_halign=text.align_center)

    table.cell(t, 0, 7, "❌ SL2", text_color=color.white, text_size=size.small, bgcolor=color.new(#1a0a0a,0))
    table.cell(t, 1, 7, str.tostring(wSL2),   text_color=color.new(color.red,30), text_size=size.small, bgcolor=color.new(#1a0a0a,0), text_halign=text.align_center)
    table.cell(t, 2, 7, str.tostring(totSL2), text_color=color.new(color.red,30), text_size=size.small, bgcolor=color.new(#1a0a0a,0), text_halign=text.align_center)

    wkWR2  = (wTP2  + wSL2)  > 0 ? math.round(wTP2  / (wTP2  + wSL2)  * 100, 1) : 0.0
    totWR2 = (totTP2 + totSL2) > 0 ? math.round(totTP2 / (totTP2 + totSL2) * 100, 1) : 0.0
    wkWR2col  = wkWR2  >= 60 ? color.new(color.lime,0) : wkWR2  >= 45 ? color.new(color.yellow,0) : color.new(color.red,0)
    totWR2col = totWR2 >= 60 ? color.new(color.lime,0) : totWR2 >= 45 ? color.new(color.yellow,0) : color.new(color.red,0)
    table.cell(t, 0, 8, "🎯 WR E2", text_color=color.white, text_size=size.small, bgcolor=color.new(#1a1a1a,0))
    table.cell(t, 1, 8, str.tostring(wkWR2)  + "%", text_color=wkWR2col,  text_size=size.normal, bgcolor=color.new(#1a1a1a,0), text_halign=text.align_center)
    table.cell(t, 2, 8, str.tostring(totWR2) + "%", text_color=totWR2col, text_size=size.normal, bgcolor=color.new(#1a1a1a,0), text_halign=text.align_center)

    // ── WR Global ────────────────────────────────────────────
    table.cell(t, 0, 9, "─────────────", text_color=color.new(color.gray,40), text_size=size.tiny, bgcolor=color.new(#111111,0))
    table.cell(t, 1, 9, "─────────────", text_color=color.new(color.gray,40), text_size=size.tiny, bgcolor=color.new(#111111,0))
    table.cell(t, 2, 9, "─────────────", text_color=color.new(color.gray,40), text_size=size.tiny, bgcolor=color.new(#111111,0))

    wkTP  = wTP1  + wTP2
    wkSL  = wSL1  + wSL2
    totTP = totTP1 + totTP2
    totSL = totSL1 + totSL2
    wkWRg  = (wkTP  + wkSL)  > 0 ? math.round(wkTP  / (wkTP  + wkSL)  * 100, 1) : 0.0
    totWRg = (totTP + totSL) > 0 ? math.round(totTP / (totTP + totSL) * 100, 1) : 0.0
    wkWRgc  = wkWRg  >= 60 ? color.new(color.lime,0) : wkWRg  >= 45 ? color.new(color.yellow,0) : color.new(color.red,0)
    totWRgc = totWRg >= 60 ? color.new(color.lime,0) : totWRg >= 45 ? color.new(color.yellow,0) : color.new(color.red,0)
    table.cell(t, 0, 10, "🏆 WR Global", text_color=color.white, text_size=size.small, bgcolor=color.new(#1a1a1a,0))
    table.cell(t, 1, 10, str.tostring(wkWRg)  + "%", text_color=wkWRgc,  text_size=size.normal, bgcolor=color.new(#1a1a1a,0), text_halign=text.align_center)
    table.cell(t, 2, 10, str.tostring(totWRg) + "%", text_color=totWRgc, text_size=size.normal, bgcolor=color.new(#1a1a1a,0), text_halign=text.align_center)

// ══════════════════════════════════════════════════════════════
//  TRIÁNGULOS EN PIVOT HIGHS
// ══════════════════════════════════════════════════════════════
plotshape(
     not na(pivotHigh) ? pivotHigh : na,
     style    = shape.triangledown,
     location = location.abovebar,
     color    = color.new(color.gray, 60),
     size     = size.tiny,
     offset   = -lookback)
````

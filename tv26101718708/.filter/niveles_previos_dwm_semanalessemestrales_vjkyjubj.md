# Niveles Previos D/W/M + Semanales/semestrales

- url: https://www.tradingview.com/script/VJKyJUbJ/
- type: indicator
- pine_id: PUB;6372875719f144498238669ba1f26ba6
- version: 1.0

## Description

indicador para detemrinar los niveles de negociacion importantes en zona de liquidez, aperturas,cierres, maximos y minimos diarios, de dia previo, semanal y semestral, niveles a utilizar como soportes y resistencias

## Source Code

````pine
//@version=6
// =====================================================================
//  Niveles Previos D/W/M + Semana Antepasada (HLOC)
//  Estilo inspirado en "[TehThomas] - Previous Day/Week/Month HLOC".
//
//  Dibuja Máximo, Mínimo, Apertura y Cierre de:
//    • Día anterior            (PDH / PDL / PDO / PDC)
//    • Semana anterior         (PWH / PWL / PWO / PWC)
//    • Semana antepasada       (P2WH / P2WL / P2WO / P2WC)   ← NUEVO
//    • Mes anterior            (PMH / PML / PMO / PMC)
//    • Semestre anterior       (PSH / PSL / PSO / PSC)            ← NUEVO
//    • Apertura ACTUAL del día / semana / año  (DO / WO / YO)    ← NUEVO
//
//  Cuando varios niveles coinciden en el mismo precio (p.ej. el cierre
//  del día = cierre de la semana) se fusionan en UNA sola línea con la
//  etiqueta combinada (p.ej. "PDC/PWC"), para que NINGÚN nivel quede
//  oculto bajo otro. Líneas finitas (inicio del periodo → vela actual).
// =====================================================================
indicator("Niveles Previos D/W/M + Semana-2 (HLOC)", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ---------------------------------------------------------------------
//  ENTRADAS — Activar/desactivar grupos
// ---------------------------------------------------------------------
showDay   = input.bool(true,  "Día anterior",        group = "Periodos", inline = "p1")
showWeek  = input.bool(true,  "Semana anterior",     group = "Periodos", inline = "p1")
showWeek2 = input.bool(true,  "Semana antepasada",   group = "Periodos", inline = "p2")
showMonth = input.bool(true,  "Mes anterior",        group = "Periodos", inline = "p2")
showSem   = input.bool(true,  "Semestre anterior",   group = "Periodos", inline = "p2b")
showOpenD = input.bool(true,  "Apertura día actual",     group = "Periodos", inline = "p3")
showOpenW = input.bool(true,  "Apertura semana actual",  group = "Periodos", inline = "p3")
showOpenY = input.bool(true,  "Apertura año actual",     group = "Periodos", inline = "p3b")

// ---------------------------------------------------------------------
//  ENTRADAS — Diseño (paleta TehThomas)
// ---------------------------------------------------------------------
gS = "Diseño"
colH = input.color(#089981, "Máximo",   group = gS, inline = "c1")
colL = input.color(#F23645, "Mínimo",   group = gS, inline = "c1")
colO = input.color(#2962ff, "Apertura", group = gS, inline = "c2")
colC = input.color(#FF9800, "Cierre",   group = gS, inline = "c2")
colAN = input.color(#FFEB3B, "Apertura actual (día/sem)", group = gS)

lineWidth   = input.int(1,    "Grosor de línea",            minval = 1, maxval = 4, group = gS)
rightBars   = input.int(8,    "Extensión a la derecha (barras)", minval = 0, maxval = 100, group = gS, tooltip = "Cuántas barras se prolonga la línea más allá de la vela actual (donde va la etiqueta).")
showLabels  = input.bool(true,"Mostrar etiquetas",          group = gS)

// Estilo de línea por periodo (para distinguir el periodo principal)
styDay   = line.style_solid
styWeek  = line.style_dashed
styWeek2 = line.style_dotted
styMonth = line.style_solid
stySem   = line.style_dashed

// ---------------------------------------------------------------------
//  DATOS (idioma sin repintado para periodos previos:
//   request.security(htf, src[n], lookahead_on). El índice [n] garantiza
//   que sólo se leen barras CERRADAS, y lookahead_on las alinea con la
//   barra correcta del gráfico → valores correctos en TODAS las TFs.)
// ---------------------------------------------------------------------
[dH, dL, dO, dC] = request.security(syminfo.tickerid, "D", [high[1], low[1], open[1], close[1]], lookahead = barmerge.lookahead_on)
dT  = request.security(syminfo.tickerid, "D", time[1], lookahead = barmerge.lookahead_on)

[wH, wL, wO, wC] = request.security(syminfo.tickerid, "W", [high[1], low[1], open[1], close[1]], lookahead = barmerge.lookahead_on)
wT  = request.security(syminfo.tickerid, "W", time[1], lookahead = barmerge.lookahead_on)

[w2H, w2L, w2O, w2C] = request.security(syminfo.tickerid, "W", [high[2], low[2], open[2], close[2]], lookahead = barmerge.lookahead_on)
w2T = request.security(syminfo.tickerid, "W", time[2], lookahead = barmerge.lookahead_on)

[mH, mL, mO, mC] = request.security(syminfo.tickerid, "M", [high[1], low[1], open[1], close[1]], lookahead = barmerge.lookahead_on)
mT  = request.security(syminfo.tickerid, "M", time[1], lookahead = barmerge.lookahead_on)

// Semestre anterior (6 meses). TradingView ancla las barras "6M" al año
// (ene–jun / jul–dic); el índice [1] = semestre CERRADO anterior.
[sH, sL, sO, sC] = request.security(syminfo.tickerid, "6M", [high[1], low[1], open[1], close[1]], lookahead = barmerge.lookahead_on)
sT  = request.security(syminfo.tickerid, "6M", time[1], lookahead = barmerge.lookahead_on)

// Aperturas del periodo ACTUAL (en curso). El 'open' de un periodo queda
// fijado al inicio del mismo, por lo que lookahead_on es seguro aquí y NO repinta.
dOpenNow = request.security(syminfo.tickerid, "D", open, lookahead = barmerge.lookahead_on)
dTnow    = request.security(syminfo.tickerid, "D", time, lookahead = barmerge.lookahead_on)
wOpenNow = request.security(syminfo.tickerid, "W", open, lookahead = barmerge.lookahead_on)
wTnow    = request.security(syminfo.tickerid, "W", time, lookahead = barmerge.lookahead_on)
yOpenNow = request.security(syminfo.tickerid, "12M", open, lookahead = barmerge.lookahead_on)
yTnow    = request.security(syminfo.tickerid, "12M", time, lookahead = barmerge.lookahead_on)

// ---------------------------------------------------------------------
//  GESTIÓN DE DIBUJOS (se borran y redibujan en la última barra)
// ---------------------------------------------------------------------
var line[]  arrLines  = array.new_line()
var label[] arrLabels = array.new_label()

f_clearAll() =>
    if array.size(arrLines) > 0
        for ln in arrLines
            line.delete(ln)
        array.clear(arrLines)
    if array.size(arrLabels) > 0
        for lb in arrLabels
            label.delete(lb)
        array.clear(arrLabels)

// Añade un nivel a la colección, fusionando si ya existe otro al mismo
// precio (mismo mintick). El primero en añadirse define color y estilo,
// y su código aparece primero en la etiqueta combinada.
f_add(float[] pr, string[] cd, color[] cl, string[] st, int[] tt, float _y, string _code, color _col, string _sty, int _t) =>
    if not na(_y) and not na(_t)
        idx = -1
        sz  = array.size(pr)
        if sz > 0
            for i = 0 to sz - 1
                if math.abs(array.get(pr, i) - _y) < syminfo.mintick / 2
                    idx := i
                    break
        if idx == -1
            array.push(pr, _y)
            array.push(cd, _code)
            array.push(cl, _col)
            array.push(st, _sty)
            array.push(tt, _t)
        else
            array.set(cd, idx, array.get(cd, idx) + "/" + _code)
            if _t < array.get(tt, idx)
                array.set(tt, idx, _t)

// Tiempo del extremo derecho = vela actual + N barras (donde va la etiqueta)
barMs    = timeframe.in_seconds() * 1000
rightEnd = time + rightBars * barMs

// ---------------------------------------------------------------------
//  DIBUJO (sólo en la última barra)
// ---------------------------------------------------------------------
if barstate.islast
    f_clearAll()

    pr = array.new_float()
    cd = array.new_string()
    cl = array.new_color()
    st = array.new_string()
    tt = array.new_int()

    // Aperturas ACTUALES primero → tienen prioridad: su color/estilo gana y
    // su código encabeza la etiqueta combinada si coinciden con otro nivel.
    if showOpenD
        f_add(pr, cd, cl, st, tt, dOpenNow, "DO", colAN, styDay, dTnow)
    if showOpenW
        f_add(pr, cd, cl, st, tt, wOpenNow, "WO", colAN, styWeek, wTnow)
    if showOpenY
        f_add(pr, cd, cl, st, tt, yOpenNow, "YO", colAN, styWeek2, yTnow)

    // Luego Día (antes que Semana → su código encabeza la etiqueta
    // combinada y define color/estilo del nivel cuando coincide).
    if showDay
        f_add(pr, cd, cl, st, tt, dH, "PDH", colH, styDay, dT)
        f_add(pr, cd, cl, st, tt, dL, "PDL", colL, styDay, dT)
        f_add(pr, cd, cl, st, tt, dO, "PDO", colO, styDay, dT)
        f_add(pr, cd, cl, st, tt, dC, "PDC", colC, styDay, dT)
    if showWeek
        f_add(pr, cd, cl, st, tt, wH, "PWH", colH, styWeek, wT)
        f_add(pr, cd, cl, st, tt, wL, "PWL", colL, styWeek, wT)
        f_add(pr, cd, cl, st, tt, wO, "PWO", colO, styWeek, wT)
        f_add(pr, cd, cl, st, tt, wC, "PWC", colC, styWeek, wT)
    if showWeek2
        f_add(pr, cd, cl, st, tt, w2H, "P2WH", colH, styWeek2, w2T)
        f_add(pr, cd, cl, st, tt, w2L, "P2WL", colL, styWeek2, w2T)
        f_add(pr, cd, cl, st, tt, w2O, "P2WO", colO, styWeek2, w2T)
        f_add(pr, cd, cl, st, tt, w2C, "P2WC", colC, styWeek2, w2T)
    if showMonth
        f_add(pr, cd, cl, st, tt, mH, "PMH", colH, styMonth, mT)
        f_add(pr, cd, cl, st, tt, mL, "PML", colL, styMonth, mT)
        f_add(pr, cd, cl, st, tt, mO, "PMO", colO, styMonth, mT)
        f_add(pr, cd, cl, st, tt, mC, "PMC", colC, styMonth, mT)
    if showSem
        f_add(pr, cd, cl, st, tt, sH, "PSH", colH, stySem, sT)
        f_add(pr, cd, cl, st, tt, sL, "PSL", colL, stySem, sT)
        f_add(pr, cd, cl, st, tt, sO, "PSO", colO, stySem, sT)
        f_add(pr, cd, cl, st, tt, sC, "PSC", colC, stySem, sT)

    // Dibujar un segmento + etiqueta por cada nivel único
    n = array.size(pr)
    if n > 0
        for i = 0 to n - 1
            _y = array.get(pr, i)
            ln = line.new(array.get(tt, i), _y, rightEnd, _y, xloc = xloc.bar_time, extend = extend.none, color = array.get(cl, i), width = lineWidth, style = array.get(st, i))
            array.push(arrLines, ln)
            if showLabels
                lb = label.new(rightEnd, _y, array.get(cd, i), xloc = xloc.bar_time, style = label.style_none, textcolor = array.get(cl, i), size = size.small)
                array.push(arrLabels, lb)
````

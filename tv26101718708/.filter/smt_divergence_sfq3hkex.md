# SMT Divergence

- url: https://www.tradingview.com/script/sFQ3HKex/
- type: indicator
- pine_id: PUB;a52fa00ffece4e90b2b99ae8cb9be3a7
- version: 1.0

## Description

Divergencia entre SP y NQ. Muestra los maximo en un activo y muestro si el otro activo no llego al mismo maximo.
Se pueden cambiar los activos  de acurdo al ticker

## Source Code

````pine
//@version=5
// ============================================================================
// SMT Divergence — Smart Money Technique
// ----------------------------------------------------------------------------
// Detecta divergencias entre dos instrumentos correlacionados (ej: NQ vs SP).
// Bearish SMT: instrumento B hace nuevo HH, instrumento A (chart) no confirma.
// Bullish SMT: instrumento B hace nuevo LL, instrumento A (chart) no confirma.
// Funciona en cualquier timeframe desde M1 hasta Monthly.
// ============================================================================
indicator("SMT Divergence", overlay = true,
     max_labels_count = 200, max_lines_count = 100, max_boxes_count = 50)

// ============================================================================
// GRUPOS
// ============================================================================
GRP_INST  = "▸ Instrumentos"
GRP_PVT   = "▸ Pivots"
GRP_VIS   = "▸ Visual"
GRP_ALT   = "▸ Alertas"

// ============================================================================
// INPUTS
// ============================================================================
INSTR_B     = input.symbol("SP:SPX500USD", "Instrumento de comparación",
     group = GRP_INST,
     tooltip = "Instrumento correlacionado. Ej: SP:SPX500USD, OANDA:EURUSD, CAPITALCOM:US500")
SMT_WINDOW  = input.int(20, "Ventana de sincronización (barras)",
     minval = 1, maxval = 100, group = GRP_INST,
     tooltip = "Barras máximas de diferencia entre los dos pivots para considerar que son del mismo ciclo. Subir si no detecta SMTs válidas.")

PVT_LEFT    = input.int(3, "Pivot — barras izquierda", minval = 1, group = GRP_PVT)
PVT_RIGHT   = input.int(3, "Pivot — barras derecha",   minval = 1, group = GRP_PVT)

SHOW_LABEL  = input.bool(true,  "Mostrar etiqueta SMT",         group = GRP_VIS)
SHOW_LINE   = input.bool(true,  "Mostrar línea entre swings",   group = GRP_VIS)
SHOW_BOX    = input.bool(false, "Mostrar caja en zona SMT",     group = GRP_VIS)
SHOW_BG     = input.bool(false, "Colorear fondo en SMT",        group = GRP_VIS)
BG_TRANSP   = input.int(92,    "Transparencia fondo",
     minval = 0, maxval = 100, group = GRP_VIS)
LABEL_INSTR = input.bool(true,  "Mostrar nombre instrumento en etiqueta", group = GRP_VIS,
     tooltip = "smt[SP] en lugar de solo SMT ▼")

// ============================================================================
// DATOS DEL INSTRUMENTO B (en el mismo TF del chart)
// ============================================================================
b_high  = request.security(INSTR_B, timeframe.period, high,
     lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)
b_low   = request.security(INSTR_B, timeframe.period, low,
     lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)
b_close = request.security(INSTR_B, timeframe.period, close,
     lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)

// Pivots del instrumento B calculados en su propio contexto
ph_b = request.security(INSTR_B, timeframe.period,
     ta.pivothigh(PVT_LEFT, PVT_RIGHT),
     lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)
pl_b = request.security(INSTR_B, timeframe.period,
     ta.pivotlow(PVT_LEFT, PVT_RIGHT),
     lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)

// Pivots del instrumento A (chart actual)
ph_a = ta.pivothigh(PVT_LEFT, PVT_RIGHT)
pl_a = ta.pivotlow(PVT_LEFT, PVT_RIGHT)

// ============================================================================
// TRACKING DE SWINGS — Instrumento A (chart)
// ============================================================================
var float a_sh1     = na   // swing high más reciente
var float a_sh2     = na   // swing high anterior
var float a_sl1     = na   // swing low más reciente
var float a_sl2     = na   // swing low anterior
var int   a_sh1_idx = 0
var int   a_sh2_idx = 0
var int   a_sl1_idx = 0
var int   a_sl2_idx = 0

if not na(ph_a)
    a_sh2     := a_sh1
    a_sh2_idx := a_sh1_idx
    a_sh1     := ph_a
    a_sh1_idx := bar_index - PVT_RIGHT   // índice del pivot real, no de la confirmación

if not na(pl_a)
    a_sl2     := a_sl1
    a_sl2_idx := a_sl1_idx
    a_sl1     := pl_a
    a_sl1_idx := bar_index - PVT_RIGHT

// ============================================================================
// TRACKING DE SWINGS — Instrumento B
// ============================================================================
var float b_sh1     = na
var float b_sh2     = na
var float b_sl1     = na
var float b_sl2     = na
var int   b_sh1_idx = 0
var int   b_sh2_idx = 0
var int   b_sl1_idx = 0
var int   b_sl2_idx = 0

if not na(ph_b)
    b_sh2     := b_sh1
    b_sh2_idx := b_sh1_idx
    b_sh1     := ph_b
    b_sh1_idx := bar_index - PVT_RIGHT

if not na(pl_b)
    b_sl2     := b_sl1
    b_sl2_idx := b_sl1_idx
    b_sl1     := pl_b
    b_sl1_idx := bar_index - PVT_RIGHT

// ============================================================================
// DETECCIÓN SMT
// ============================================================================

// ── Caso 1: B (SP) sweep ── B confirma nuevo HH/LL, A (NQ) diverge
b_new_hh = not na(ph_b) and not na(b_sh1) and not na(b_sh2) and b_sh1 > b_sh2
b_new_ll = not na(pl_b) and not na(b_sl1) and not na(b_sl2) and b_sl1 < b_sl2

a_lh_vs_b = not na(a_sh1) and not na(a_sh2) and a_sh1 < a_sh2 and math.abs(a_sh1_idx - b_sh1_idx) <= SMT_WINDOW
a_hl_vs_b = not na(a_sl1) and not na(a_sl2) and a_sl1 > a_sl2 and math.abs(a_sl1_idx - b_sl1_idx) <= SMT_WINDOW

bear_case1 = b_new_hh and a_lh_vs_b   // SP sweep arriba, NQ LH (no confirma)
bull_case1 = b_new_ll and a_hl_vs_b   // SP sweep abajo,  NQ HL (no confirma)

// ── Caso 2a: A sweep clásico ── A confirma HH/LL, B tiene estructura opuesta
a_new_hh = not na(ph_a) and not na(a_sh1) and not na(a_sh2) and a_sh1 > a_sh2
a_new_ll = not na(pl_a) and not na(a_sl1) and not na(a_sl2) and a_sl1 < a_sl2

b_lh_vs_a = not na(b_sh1) and not na(b_sh2) and b_sh1 < b_sh2 and math.abs(b_sh1_idx - a_sh1_idx) <= SMT_WINDOW
b_hl_vs_a = not na(b_sl1) and not na(b_sl2) and b_sl1 > b_sl2 and math.abs(b_sl1_idx - a_sl1_idx) <= SMT_WINDOW

bear_case2a = a_new_hh and b_lh_vs_a   // A swept HH, B tiene LH
bull_case2a = a_new_ll and b_hl_vs_a   // A swept LL, B tiene HL

// ── Caso 2b: A sweep, B pivoteó primero en misma dirección y ya revertió ──
// Bearish: A hace HH, B había hecho HH antes y ya está cayendo
// Bullish: A hace LL,  B había hecho LL antes y ya está subiendo
bear_case2b = a_new_hh and
     not na(b_sh1) and not na(b_sh2) and
     b_sh1 > b_sh2 and
     b_sh1_idx < a_sh1_idx and
     b_close < b_sh1 and
     math.abs(b_sh1_idx - a_sh1_idx) <= SMT_WINDOW

bull_case2b = a_new_ll and
     not na(b_sl1) and not na(b_sl2) and
     b_sl1 < b_sl2 and
     b_sl1_idx < a_sl1_idx and
     b_close > b_sl1 and
     math.abs(b_sl1_idx - a_sl1_idx) <= SMT_WINDOW

// ── Anti-duplicado por pivot ──
var int last_a_sh1_used = -9999
var int last_a_sl1_used = -9999

bearish_smt_raw = bear_case1 or bear_case2a or bear_case2b
bullish_smt_raw = bull_case1 or bull_case2a or bull_case2b

bearish_smt = bearish_smt_raw and a_sh1_idx != last_a_sh1_used
bullish_smt = bullish_smt_raw and a_sl1_idx != last_a_sl1_used

// Quién hizo el sweep (para la etiqueta)
bear_sweep_was_b = bear_case1
bull_sweep_was_b = bull_case1

if bearish_smt
    last_a_sh1_used := a_sh1_idx
if bullish_smt
    last_a_sl1_used := a_sl1_idx

// ============================================================================
// NOMBRES CORTOS DE INSTRUMENTOS (para etiqueta)
// ============================================================================
b_name = str.length(INSTR_B) > 6 ? str.substring(INSTR_B, str.length(INSTR_B) - 6) : INSTR_B
a_name = str.length(syminfo.ticker) > 6 ? str.substring(syminfo.ticker, str.length(syminfo.ticker) - 6) : syminfo.ticker

// ============================================================================
// COLORES
// ============================================================================
COL_BEAR    = color.new(color.red,   0)
COL_BULL    = color.new(color.green, 0)
col_bear_bg = color.new(color.red,   BG_TRANSP)
col_bull_bg = color.new(color.green, BG_TRANSP)

// ============================================================================
// COLAS FIFO — mantener solo las últimas 4 SMT bear y 4 SMT bull
// ============================================================================
MAX_SMT = 4

var label[] bear_labels = array.new<label>()
var line[]  bear_lines  = array.new<line>()
var box[]   bear_boxes  = array.new<box>()
var label[] bull_labels = array.new<label>()
var line[]  bull_lines  = array.new<line>()
var box[]   bull_boxes  = array.new<box>()

f_trim_bear() =>
    if array.size(bear_labels) > MAX_SMT
        lbl = array.shift(bear_labels)
        label.delete(lbl)
    if array.size(bear_lines) > MAX_SMT
        ln = array.shift(bear_lines)
        line.delete(ln)
    if array.size(bear_boxes) > MAX_SMT
        bx = array.shift(bear_boxes)
        box.delete(bx)

f_trim_bull() =>
    if array.size(bull_labels) > MAX_SMT
        lbl = array.shift(bull_labels)
        label.delete(lbl)
    if array.size(bull_lines) > MAX_SMT
        ln = array.shift(bull_lines)
        line.delete(ln)
    if array.size(bull_boxes) > MAX_SMT
        bx = array.shift(bull_boxes)
        box.delete(bx)

// ============================================================================
// VISUALIZACIÓN — BEARISH SMT
// ============================================================================
if bearish_smt
    lbl_txt = not LABEL_INSTR ? "SMT ▼" : bear_sweep_was_b ? "smt[" + b_name + "] ▼" : "smt[" + a_name + "] ▼"

    if SHOW_LABEL
        lbl = label.new(a_sh1_idx, a_sh1,
             text      = lbl_txt,
             color     = COL_BEAR,
             textcolor = color.white,
             style     = label.style_label_down,
             size      = size.small)
        array.push(bear_labels, lbl)

    if SHOW_LINE
        ln = line.new(a_sh2_idx, a_sh2, a_sh1_idx, a_sh1,
             color = COL_BEAR, width = 1, style = line.style_solid)
        array.push(bear_lines, ln)

    if SHOW_BOX
        bx = box.new(a_sh2_idx, math.max(a_sh2, a_sh1),
             a_sh1_idx, math.min(a_sh2, a_sh1),
             border_color = COL_BEAR,
             bgcolor      = color.new(color.red, 90))
        array.push(bear_boxes, bx)

    f_trim_bear()

// ============================================================================
// VISUALIZACIÓN — BULLISH SMT
// ============================================================================
if bullish_smt
    lbl_txt = not LABEL_INSTR ? "SMT ▲" : bull_sweep_was_b ? "smt[" + b_name + "] ▲" : "smt[" + a_name + "] ▲"

    if SHOW_LABEL
        lbl = label.new(a_sl1_idx, a_sl1,
             text      = lbl_txt,
             color     = COL_BULL,
             textcolor = color.white,
             style     = label.style_label_up,
             size      = size.small)
        array.push(bull_labels, lbl)

    if SHOW_LINE
        ln = line.new(a_sl2_idx, a_sl2, a_sl1_idx, a_sl1,
             color = COL_BULL, width = 1, style = line.style_solid)
        array.push(bull_lines, ln)

    if SHOW_BOX
        bx = box.new(a_sl2_idx, math.max(a_sl2, a_sl1),
             a_sl1_idx, math.min(a_sl2, a_sl1),
             border_color = COL_BULL,
             bgcolor      = color.new(color.green, 90))
        array.push(bull_boxes, bx)

    f_trim_bull()

// ============================================================================
// FONDO (si está activo, dura N barras después del SMT)
// ============================================================================
var int   last_bear_smt_bar = -9999
var int   last_bull_smt_bar = -9999
int       BG_DURATION = 5  // barras que dura el fondo

if bearish_smt
    last_bear_smt_bar := bar_index
if bullish_smt
    last_bull_smt_bar := bar_index

bg_bear_active = SHOW_BG and (bar_index - last_bear_smt_bar) <= BG_DURATION
bg_bull_active = SHOW_BG and (bar_index - last_bull_smt_bar) <= BG_DURATION

bgcolor(bg_bear_active and not bg_bull_active ? col_bear_bg : na, title = "Fondo SMT bajista")
bgcolor(bg_bull_active and not bg_bear_active ? col_bull_bg : na, title = "Fondo SMT alcista")

// ============================================================================
// TABLA — estado actual
// ============================================================================
var table tbl = table.new(position.top_right, 2, 4,
     bgcolor      = color.new(color.black, 20),
     border_color = color.new(color.gray,  30),
     border_width = 1,
     frame_color  = color.new(color.gray,  10),
     frame_width  = 1)

if barstate.islast
    table.cell(tbl, 0, 0, "SMT Divergence",
         text_color = color.white, text_size = size.small,
         bgcolor = color.new(color.navy, 20))
    table.cell(tbl, 1, 0, timeframe.period,
         text_color = color.yellow, text_size = size.small,
         bgcolor = color.new(color.navy, 20))

    table.cell(tbl, 0, 1, "Instrumento B",
         text_color = color.white, text_size = size.small,
         bgcolor = color.new(color.black, 20))
    table.cell(tbl, 1, 1, b_name,
         text_color = color.yellow, text_size = size.small,
         bgcolor = color.new(color.black, 20))

    table.cell(tbl, 0, 2, "SH activo (A)",
         text_color = color.white, text_size = size.small,
         bgcolor = color.new(color.black, 20))
    table.cell(tbl, 1, 2, not na(a_sh1) ? str.tostring(math.round(a_sh1, 1)) : "—",
         text_color = color.new(color.red, 0), text_size = size.small,
         bgcolor = color.new(color.black, 20))

    table.cell(tbl, 0, 3, "SL activo (A)",
         text_color = color.white, text_size = size.small,
         bgcolor = color.new(color.black, 20))
    table.cell(tbl, 1, 3, not na(a_sl1) ? str.tostring(math.round(a_sl1, 1)) : "—",
         text_color = color.new(color.lime, 0), text_size = size.small,
         bgcolor = color.new(color.black, 20))

// ============================================================================
// ALERTAS
// ============================================================================
alertcondition(bearish_smt,
     title   = "SMT Bajista",
     message = "SMT Divergence: señal BAJISTA detectada — instrumento B hizo HH, A no confirmó")

alertcondition(bullish_smt,
     title   = "SMT Alcista",
     message = "SMT Divergence: señal ALCISTA detectada — instrumento B hizo LL, A no confirmó")
````

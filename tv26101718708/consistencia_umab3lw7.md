# Consistencia

- url: https://www.tradingview.com/script/UmaB3lw7/
- type: indicator
- pine_id: PUB;34dd26f4fea444c5b7bada8e94263016
- version: 1.0

## Description

Indicador para calcular la consistencia de las props de futuros

## Source Code

````pine
//@version=5
indicator("CR Calculator | PROfxSOR", overlay=true)

// ─────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────
consistency_rule_input = input.float(30, title="Regla de Consistencia (%)", minval=1, maxval=100, step=1)
best_day               = input.float(1000, title="Mejor Día P&G ($)", minval=0)
total_accumulated      = input.float(5000, title="Total Acumulado ($)", minval=0)

table_pos_input  = input.string("Top Right", title="Posición de Tabla",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
table_size_input = input.string("Normal", title="Tamaño de Tabla",
     options=["Small", "Normal", "Large"])

// ─────────────────────────────────────────
// MAP INPUTS
// ─────────────────────────────────────────
consistency_rule_pct = consistency_rule_input / 100

tbl_pos = switch table_pos_input
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

tbl_size = switch table_size_input
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    => size.normal

// ─────────────────────────────────────────
// CALCULATIONS
// ─────────────────────────────────────────
current_pct      = total_accumulated != 0 ? (best_day / total_accumulated) * 100 : 0.0
min_total_needed = consistency_rule_pct != 0 ? best_day / consistency_rule_pct : 0.0
still_needed     = math.max(0.0, min_total_needed - total_accumulated)
is_pass          = current_pct <= consistency_rule_input

// ─────────────────────────────────────────
// COLOR PALETTE
// ─────────────────────────────────────────
c_header  = #1E2D40   // azul noche    — header / filas estáticas
c_sub     = #2A3F5F   // azul medio    — subheader
c_text    = #E8EAF0   // blanco suave  — texto principal
c_accent  = color.rgb(170, 173, 182)   // azul eléctrico — franja, bordes frame, separador superior
c_sep     = #C8922A   // dorado        — separador estático/dinámico
c_border  = #000000   // gris neutro   — bordes internos de celda
c_pass    = #2ECC71   // verde esmeralda
c_fail    = #E74C3C   // rojo suave

// ─────────────────────────────────────────
// FORMAT HELPERS
// ─────────────────────────────────────────
fmt_dollar(v) => "$" + str.tostring(v, "#,##0.00")
fmt_pct(v)    => str.tostring(v, "#,##0.0") + "%"

// ─────────────────────────────────────────
// FILL ROW — ESTÁTICO
// Ambas celdas (métrica y valor) mismo fondo #1E2D40
// ─────────────────────────────────────────
fill_static(t, row, metric_txt, value_txt) =>
 
    table.cell(t, 1, row, metric_txt,
         bgcolor     = #1E2D40,
         text_color  = #E8EAF0,
         text_size   = size.normal,
         text_halign = text.align_left)
    table.cell(t, 2, row, value_txt,
         bgcolor     = #1E2D40,
         text_color  = #E8EAF0,
         text_size   = size.normal,
         text_halign = text.align_right)

// ─────────────────────────────────────────
// FILL ROW — DINÁMICO
// Las 3 celdas reciben el color semáforo (verde o rojo)
// ─────────────────────────────────────────
fill_dynamic(t, row, dyn_bg, metric_txt, value_txt) =>
 
    table.cell(t, 1, row, metric_txt,
         bgcolor     = dyn_bg,
         text_color  = #E8EAF0,
         text_size   = size.normal,
         text_halign = text.align_left)
    table.cell(t, 2, row, value_txt,
         bgcolor     = dyn_bg,
         text_color  = #E8EAF0,
         text_size   = size.normal,
         text_halign = text.align_right)

// ─────────────────────────────────────────
// SEPARADOR DORADO
// ─────────────────────────────────────────
gold_sep(t, row) =>
    
    table.cell(t, 1, row, "", bgcolor = #C8922A, text_color = #C8922A, text_size = size.small)
    table.cell(t, 2, row, "", bgcolor = #C8922A, text_color = #C8922A, text_size = size.small)

// ─────────────────────────────────────────
// TABLE — 11 rows
//  0  Header
//  1  Subheader  (MÉTRICA / VALOR)
//  2  Separador acento (azul eléctrico, fino)
//  3  Consistencia          (estático)
//  4  Mejor Día             (estático)
//  5  Total Acumulado       (estático)
//  6  Separador dorado
//  7  Consistencia Actual   (dinámico)
//  8  Falta para Cumplir    (dinámico)
//  9  Meta Total            (dinámico)
// 10  ESTADO                (dinámico)
// ─────────────────────────────────────────
var table tbl = na

if barstate.islast
    tbl := table.new(
         tbl_pos,
         columns      = 3,
         rows         = 11,
         border_color = c_border,    // #3A3A4A — bordes internos visibles
         border_width = 1,
         frame_color  = c_accent,    // #4A9EFF — marco exterior
         frame_width  = 2)

    // ── ROW 0 — Encabezado principal ─────────────────────────────────────
 
    table.cell(tbl, 1, 0, "CALCULADORA DE %",
         bgcolor     = c_header,
         text_color  = c_accent,
         text_size   = size.large,
         text_halign = text.align_center)
    table.merge_cells(tbl, 1, 0, 2, 0)

  
  

    // ── ROWS 3-5 — Datos estáticos (mismo fondo en ambas celdas) ─────────
    fill_static(tbl, 3, "  Consistencia",    fmt_pct(consistency_rule_input) + "  ")
    fill_static(tbl, 4, "  Mejor Día",       fmt_dollar(best_day) + "  ")
    fill_static(tbl, 5, "  Total Acumulado", fmt_dollar(total_accumulated) + "  ")



    // ── ROWS 7-10 — Dinámicos con semáforo completo ───────────────────────
    dyn_bg = is_pass ? c_pass : c_fail

    fill_dynamic(tbl, 7,  dyn_bg, "  Consistencia Actual", fmt_pct(current_pct) + "  ")
    fill_dynamic(tbl, 8,  dyn_bg, "  Falta para Cumplir",  fmt_dollar(still_needed) + "  ")
    fill_dynamic(tbl, 9,  dyn_bg, "  Meta Total",          fmt_dollar(min_total_needed) + "  ")

    // ── ROW 10 — ESTADO ───────────────────────────────────────────────────
    estado_lbl = is_pass ? "✓ CUMPLE" : "✗ NO CUMPLE"

  
    table.cell(tbl, 1, 10, "  ESTADO",
         bgcolor     = dyn_bg,
         text_color  = c_text,
         text_size   = tbl_size,
         text_halign = text.align_left)
    table.cell(tbl, 2, 10, estado_lbl + "  ",
         bgcolor     = dyn_bg,
         text_color  = c_text,
         text_size   = tbl_size,
         text_halign = text.align_right)
````

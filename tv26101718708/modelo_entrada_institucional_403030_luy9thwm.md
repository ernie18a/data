# Modelo Entrada Institucional 40/30/30

- url: https://www.tradingview.com/script/LUY9ThWM/
- type: indicator
- pine_id: PUB;94449048c679425cbaac42c01ad6b6f2
- version: 1.0

## Description

El indicador es una herramienta de gestión de riesgo que implementa una estrategia de "entradas escalonadas" en tres niveles con riesgo matemáticamente controlado.

Se activa seleccionando las tres entradas, el stop loss de la zona a ponderar y posteriormente el take profit.

Estructura de entradas:
Divide el capital en tres tramos que se activan a medida que el precio cae:

| Tramo | Capital | Cuándo entrar |
| Entrada 1 | 40% | Señal técnica inicial |
| Entrada 2 | 30% | Retroceso estructural profundo |
| Entrada 3 | 30% | Soporte histórico extremo |

Al concentrar el 60% del capital en los dos niveles más bajos, el "precio promedio ponderado cae con fuerza", lo que significa que un rebote mínimo ya te pone en positivo.

Gestión del riesgo:
- Antes de abrir la primera posición se calcula el "riesgo máximo combinado" de las tres entradas
- Se coloca un "Hard Stop inamovible" por debajo del último soporte.
- Si ese nivel se rompe → se asume la pérdida matemática y se cierra todo. Cero riesgo de ruina infinita.
¿Qué calcula automáticamente?
- Precio promedio ponderado de las tres entradas.
- Pérdida máxima real en $ y % si el hard stop se activa.
- Ratio R:R real entre el promedio y el Take Profit manual.
- Beneficio máximo estimado al llegar al TP.

Alertas:
Dispara notificaciones cuando el precio alcanza cada zona de entrada, el hard stop o el take profit.

[image]https://www.tradingview.com/x/08xefU3J/[/image]

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
//  MODELO INSTITUCIONAL 40 / 30 / 30
//  Gestión de entradas escalonadas con riesgo acotado y hard stop inamovible
//  Dirección (Long / Short) detectada automáticamente según posición del HS
// ══════════════════════════════════════════════════════════════════════════════
//@version=6
indicator("Modelo Institucional 40/30/30", overlay = true,
          max_lines_count = 20, max_labels_count = 20, max_boxes_count = 10)

// ══════════════════════════════════════════════════════════════════════════════
//  NIVELES  —  clic en el gráfico para fijar cada precio
//  Long:  HS debajo de todas las entradas, TP encima de E1
//  Short: HS encima de todas las entradas, TP debajo de E1
// ══════════════════════════════════════════════════════════════════════════════
string GRP_E = "📍 Niveles  (clic en el gráfico para fijar)"
float entry1   = input.price(0.0, "Entrada 1 — 40%",           group = GRP_E, confirm = true)
float entry2   = input.price(0.0, "Entrada 2 — 30%",           group = GRP_E, confirm = true)
float entry3   = input.price(0.0, "Entrada 3 — 30%",           group = GRP_E, confirm = true)
float hs_price = input.price(0.0, "⛔ Hard Stop  (inamovible)", group = GRP_E, confirm = true)
float tp_price = input.price(0.0, "🎯 Take Profit",             group = GRP_E, confirm = true)

// ══════════════════════════════════════════════════════════════════════════════
//  CAPITAL Y RIESGO
// ══════════════════════════════════════════════════════════════════════════════
string GRP_R = "💰 Capital y Riesgo"
float capital  = input.float(100000.0, "Capital Total ($)",        group = GRP_R, minval = 1, step = 1000)
float risk_pct = input.float(0.50,     "Riesgo Total Asumido (%)", group = GRP_R, minval = 0.01, maxval = 100, step = 0.01,
     tooltip = "Porcentaje del capital que se arriesga. La pérdida total si el hard stop se activa será exactamente este importe (40%+30%+30% del riesgo).")

// ══════════════════════════════════════════════════════════════════════════════
//  COLORES
// ══════════════════════════════════════════════════════════════════════════════
string GRP_COL = "🎨 Colores"
color col_e1  = input.color(color.new(#FFD600, 70), "Entrada 1",       group = GRP_COL)
color col_e2  = input.color(color.new(#FFB300, 70), "Entrada 2",       group = GRP_COL)
color col_e3  = input.color(color.new(#FF8F00, 70), "Entrada 3",       group = GRP_COL)
color col_hs  = input.color(color.new(#FF1744, 70), "Hard Stop",       group = GRP_COL)
color col_avg = input.color(color.new(#FF6D00, 70), "Precio Promedio", group = GRP_COL)
color col_tp  = input.color(color.new(#69F0AE, 70), "Take Profit",     group = GRP_COL)

// ══════════════════════════════════════════════════════════════════════════════
//  GROSOR Y ESTILO DE LÍNEAS
// ══════════════════════════════════════════════════════════════════════════════
string GRP_LW = "📐 Grosor y Estilo de Líneas"
int    lw_entries = input.int(1,         "Entradas     Grosor", group = GRP_LW, minval = 1, maxval = 5, inline = "ls_e")
string ls_entries = input.string("Continua",  "  Estilo",       group = GRP_LW, inline = "ls_e",   options = ["Continua", "Discontinua", "Punteada"])
int    lw_hs      = input.int(1,         "Hard Stop   Grosor",  group = GRP_LW, minval = 1, maxval = 5, inline = "ls_hs")
string ls_hs      = input.string("Continua",  "  Estilo",       group = GRP_LW, inline = "ls_hs",  options = ["Continua", "Discontinua", "Punteada"])
int    lw_avg     = input.int(2,         "Promedio    Grosor",  group = GRP_LW, minval = 1, maxval = 5, inline = "ls_avg")
string ls_avg     = input.string("Punteada",  "  Estilo",       group = GRP_LW, inline = "ls_avg", options = ["Continua", "Discontinua", "Punteada"])
int    lw_tp      = input.int(1,         "Take Profit Grosor",  group = GRP_LW, minval = 1, maxval = 5, inline = "ls_tp")
string ls_tp      = input.string("Continua",  "  Estilo",       group = GRP_LW, inline = "ls_tp",  options = ["Continua", "Discontinua", "Punteada"])

// ══════════════════════════════════════════════════════════════════════════════
//  TRANSPARENCIA
// ══════════════════════════════════════════════════════════════════════════════
string GRP_TR = "🌫️ Transparencia  (0 = sólido · 100 = invisible)"
int tr_zones   = input.int(88, "Zonas de capital", group = GRP_TR, minval = 0, maxval = 100)
int tr_borders = input.int(55, "Bordes de zonas",  group = GRP_TR, minval = 0, maxval = 100)
int tr_labels  = input.int(10, "Etiquetas",        group = GRP_TR, minval = 0, maxval = 100)

// ══════════════════════════════════════════════════════════════════════════════
//  OPCIONES VISUALES
// ══════════════════════════════════════════════════════════════════════════════
string GRP_V = "⚙️ Opciones Visuales"
bool show_zones = input.bool(false, "Mostrar zonas de capital",          group = GRP_V)
bool show_table = input.bool(true,  "Mostrar tabla resumen",              group = GRP_V)
int  line_len   = input.int(60,     "Longitud de líneas (barras atrás)", group = GRP_V, minval = 5, maxval = 500)

// ══════════════════════════════════════════════════════════════════════════════
//  ALERTAS
// ══════════════════════════════════════════════════════════════════════════════
string GRP_AL = "🔔 Alertas"
bool tv_on = input.bool(true, "Activar alertas TradingView", group = GRP_AL,
     tooltip = "Habilita las alertas estándar. Crea una alerta desde el gráfico y elige la condición en el desplegable.")

// ══════════════════════════════════════════════════════════════════════════════
//  FUNCIÓN: string → line.style
// ══════════════════════════════════════════════════════════════════════════════
f_ls(s) =>
    s == "Continua" ? line.style_solid : s == "Punteada" ? line.style_dotted : line.style_dashed

// ══════════════════════════════════════════════════════════════════════════════
//  DETECCIÓN AUTOMÁTICA DE DIRECCIÓN
//
//  La dirección se infiere de la posición del Hard Stop respecto a las entradas:
//    · Long:  HS por debajo de las 3 entradas  →  E1 > E2 > E3 > HS
//    · Short: HS por encima de las 3 entradas  →  HS > E3 > E2 > E1
//
//  No se requiere ningún selector manual.
// ══════════════════════════════════════════════════════════════════════════════
bool prices_set = entry1 > 0 and entry2 > 0 and entry3 > 0 and hs_price > 0

// Inferir dirección desde posición del HS
bool is_short = prices_set and
     hs_price > math.max(entry1, math.max(entry2, entry3))
bool is_long  = prices_set and
     hs_price < math.min(entry1, math.min(entry2, entry3))

// Validar orden correcto de las entradas para cada dirección
bool order_long  = entry1 > entry2 and entry2 > entry3 and entry3 > hs_price
bool order_short = hs_price > entry3 and entry3 > entry2 and entry2 > entry1
bool order_ok    = is_short ? order_short : (is_long ? order_long : false)

bool valid_e = prices_set and order_ok

// Take Profit válido (lado correcto según dirección)
bool has_tp = valid_e and tp_price > 0 and
     (is_short ? tp_price < entry1 : tp_price > entry1)

// ══════════════════════════════════════════════════════════════════════════════
//  CÁLCULOS
//
//  El riesgo total (risk_usd) se distribuye 40/30/30.
//  cap_n  = riesgo asignado a esa entrada ($ que se pierden si el HS se activa)
//  dist_n = |entry_n − hs_price|  (siempre positivo)
//  units_n = cap_n / dist_n
// ══════════════════════════════════════════════════════════════════════════════
float w1 = 0.40
float w2 = 0.30
float w3 = 0.30

float risk_usd = capital * risk_pct / 100.0

float cap1 = risk_usd * w1
float cap2 = risk_usd * w2
float cap3 = risk_usd * w3

float dist1 = valid_e ? math.abs(entry1 - hs_price) : float(na)
float dist2 = valid_e ? math.abs(entry2 - hs_price) : float(na)
float dist3 = valid_e ? math.abs(entry3 - hs_price) : float(na)

float units1      = valid_e ? cap1 / dist1 : 0.0
float units2      = valid_e ? cap2 / dist2 : 0.0
float units3      = valid_e ? cap3 / dist3 : 0.0
float total_units = units1 + units2 + units3

// Precio promedio ponderado por volumen
float avg_price = valid_e ?
     (units1 * entry1 + units2 * entry2 + units3 * entry3) / total_units : float(na)

// Pérdida máxima = riesgo total exacto (por construcción)
float max_loss = valid_e ? risk_usd : float(na)

// % movimiento adverso hasta el stop (siempre positivo)
float pct_to_stop = valid_e ?
     (is_short ? (hs_price  - avg_price) / avg_price * 100.0
               : (avg_price - hs_price)  / avg_price * 100.0) : float(na)

// % movimiento favorable hasta el TP (siempre positivo)
float pct_to_tp = has_tp ?
     (is_short ? (avg_price - tp_price) / avg_price * 100.0
               : (tp_price  - avg_price) / avg_price * 100.0) : float(na)

// Ratio riesgo/recompensa
float rr_real = has_tp ?
     (is_short ? (avg_price - tp_price) / (hs_price  - avg_price)
               : (tp_price  - avg_price) / (avg_price - hs_price)) : float(na)

// Beneficio máximo en $
float max_gain = has_tp ?
     (is_short ? total_units * (avg_price - tp_price)
               : total_units * (tp_price  - avg_price)) : float(na)

// ══════════════════════════════════════════════════════════════════════════════
//  DIBUJO  —  solo en la última barra
// ══════════════════════════════════════════════════════════════════════════════
if barstate.islast

    int x0 = bar_index - line_len
    int x1 = bar_index + int(math.round(line_len * 0.35))

    // ── ZONAS DE CAPITAL ─────────────────────────────────────────────────────
    if show_zones and valid_e
        if is_short
            box.new(x0, entry2,   x1, entry1,
                    bgcolor = color.new(col_e1, tr_zones),
                    border_color = color.new(col_e1, tr_borders), border_width = 1)
            box.new(x0, entry3,   x1, entry2,
                    bgcolor = color.new(col_e2, tr_zones),
                    border_color = color.new(col_e2, tr_borders), border_width = 1)
            box.new(x0, hs_price, x1, entry3,
                    bgcolor = color.new(col_hs, math.min(tr_zones + 4, 100)),
                    border_color = color.new(col_hs, tr_borders), border_width = 1)
        else
            box.new(x0, entry1,   x1, entry2,
                    bgcolor = color.new(col_e1, tr_zones),
                    border_color = color.new(col_e1, tr_borders), border_width = 1)
            box.new(x0, entry2,   x1, entry3,
                    bgcolor = color.new(col_e2, tr_zones),
                    border_color = color.new(col_e2, tr_borders), border_width = 1)
            box.new(x0, entry3,   x1, hs_price,
                    bgcolor = color.new(col_hs, math.min(tr_zones + 4, 100)),
                    border_color = color.new(col_hs, tr_borders), border_width = 1)

    // ── HARD STOP ────────────────────────────────────────────────────────────
    if hs_price > 0
        line.new(x0, hs_price, x1, hs_price,
                 color = col_hs, width = lw_hs, style = f_ls(ls_hs))
        label.new(x1, hs_price,
                  " ⛔ HARD STOP  " + str.tostring(hs_price, format.mintick),
                  color = color.new(col_hs, tr_labels), textcolor = color.white,
                  style = label.style_label_left, size = size.small)

    // ── ENTRADA 3 ────────────────────────────────────────────────────────────
    if entry3 > 0
        line.new(x0, entry3, x1, entry3,
                 color = col_e3, width = lw_entries, style = f_ls(ls_entries))
        label.new(x1, entry3,
                  " IN 30%  " + str.tostring(entry3, format.mintick) +
                  "\n $" + str.tostring(cap3, "#,###.00"),
                  color = color.new(col_e3, tr_labels), textcolor = color.black,
                  style = label.style_label_left, size = size.small)

    // ── ENTRADA 2 ────────────────────────────────────────────────────────────
    if entry2 > 0
        line.new(x0, entry2, x1, entry2,
                 color = col_e2, width = lw_entries, style = f_ls(ls_entries))
        label.new(x1, entry2,
                  " IN 30%  " + str.tostring(entry2, format.mintick) +
                  "\n $" + str.tostring(cap2, "#,###.00"),
                  color = color.new(col_e2, tr_labels), textcolor = color.black,
                  style = label.style_label_left, size = size.small)

    // ── ENTRADA 1 ────────────────────────────────────────────────────────────
    if entry1 > 0
        line.new(x0, entry1, x1, entry1,
                 color = col_e1, width = lw_entries, style = f_ls(ls_entries))
        label.new(x1, entry1,
                  " IN 40%  " + str.tostring(entry1, format.mintick) +
                  "\n $" + str.tostring(cap1, "#,###.00"),
                  color = color.new(col_e1, tr_labels), textcolor = color.black,
                  style = label.style_label_left, size = size.small)

    // ── PRECIO PROMEDIO ──────────────────────────────────────────────────────
    if not na(avg_price)
        line.new(x0, avg_price, x1, avg_price,
                 color = col_avg, width = lw_avg, style = f_ls(ls_avg))
        label.new(x1, avg_price,
                  " ⚡ PROMEDIO  " + str.tostring(avg_price, format.mintick),
                  color = color.new(col_avg, tr_labels), textcolor = color.black,
                  style = label.style_label_left, size = size.small)

    // ── TAKE PROFIT ──────────────────────────────────────────────────────────
    if has_tp
        string tp_txt = " 🎯 TP  " + str.tostring(tp_price, format.mintick)
        if not na(pct_to_tp) and not na(rr_real)
            tp_txt := tp_txt + "\n +" + str.tostring(pct_to_tp, "#.##") +
                      "%  ·  R:R " + str.tostring(rr_real, "#.##")
        line.new(x0, tp_price, x1, tp_price,
                 color = col_tp, width = lw_tp, style = f_ls(ls_tp))
        label.new(x1, tp_price, tp_txt,
                  color = color.new(col_tp, tr_labels), textcolor = color.black,
                  style = label.style_label_left, size = size.small)

// ══════════════════════════════════════════════════════════════════════════════
//  TABLA DE RESUMEN
// ══════════════════════════════════════════════════════════════════════════════
var table tbl = table.new(position.top_right, 2, 14,
     bgcolor      = color.new(#0d0d0d, 5),
     border_width = 1, border_color = color.new(color.gray, 60),
     frame_width  = 1, frame_color  = color.new(color.gray, 30))

if barstate.islast and show_table

    color c_dark      = #1a1a2e
    string dir_lbl    = is_short ? " 📉 SHORT" : " 📈 LONG"
    string stop_arrow = is_short ? "↑" : "↓"

    table.cell(tbl, 0, 0, "▪ MODELO INSTITUCIONAL 40/30/30" + dir_lbl,
               text_color = color.white, text_size = size.normal,
               bgcolor = color.new(c_dark, 0), text_halign = text.align_left)
    table.cell(tbl, 1, 0, valid_e ? "✅ VÁLIDO" : "⚠️ REVISAR",
               text_color = valid_e ? color.lime : #FF9800, text_size = size.small,
               bgcolor = color.new(c_dark, 0))

    table.cell(tbl, 0, 1, "  Entrada 1  (40%)", text_color = col_e1, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 1, entry1 > 0 ? str.tostring(entry1, format.mintick) + "   $" + str.tostring(cap1, "#,###.00") : "—",
               text_color = col_e1, text_size = size.small)

    table.cell(tbl, 0, 2, "  Entrada 2  (30%)", text_color = col_e2, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 2, entry2 > 0 ? str.tostring(entry2, format.mintick) + "   $" + str.tostring(cap2, "#,###.00") : "—",
               text_color = col_e2, text_size = size.small)

    table.cell(tbl, 0, 3, "  Entrada 3  (30%)", text_color = col_e3, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 3, entry3 > 0 ? str.tostring(entry3, format.mintick) + "   $" + str.tostring(cap3, "#,###.00") : "—",
               text_color = col_e3, text_size = size.small)

    table.cell(tbl, 0, 4, "  Hard Stop", text_color = col_hs, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 4, hs_price > 0 ? str.tostring(hs_price, format.mintick) : "—",
               text_color = col_hs, text_size = size.small)

    table.cell(tbl, 0, 5, "──────────────────", text_color = color.new(color.gray, 50), text_size = size.tiny)
    table.cell(tbl, 1, 5, "──────────────────", text_color = color.new(color.gray, 50), text_size = size.tiny)

    table.cell(tbl, 0, 6, "  Precio Promedio", text_color = col_avg, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 6, not na(avg_price) ? str.tostring(avg_price, format.mintick) : "—",
               text_color = col_avg, text_size = size.small)

    table.cell(tbl, 0, 7, "  Riesgo Asumido", text_color = color.gray, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 7, str.tostring(risk_pct, "#.##") + "%   $" + str.tostring(risk_usd, "#,###.00"),
               text_color = color.gray, text_size = size.small)

    table.cell(tbl, 0, 8, "  Pérdida Máx. ($)", text_color = color.red, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 8, not na(max_loss) ?
               "-$" + str.tostring(max_loss, "#,###.00") + "  (" + str.tostring(risk_pct, "#.##") + "%)" : "—",
               text_color = color.red, text_size = size.small)

    table.cell(tbl, 0, 9, "  Stop desde promedio", text_color = color.gray, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 9, not na(pct_to_stop) ?
               stop_arrow + " " + str.tostring(pct_to_stop, "#.##") + "%" : "—",
               text_color = color.red, text_size = size.small)

    table.cell(tbl, 0, 10, "  Take Profit", text_color = col_tp, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 10, has_tp ? str.tostring(tp_price, format.mintick) : "—",
               text_color = col_tp, text_size = size.small)

    table.cell(tbl, 0, 11, "  % hasta TP  ·  R:R", text_color = col_tp, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 11,
               not na(pct_to_tp) and not na(rr_real) ?
               "+" + str.tostring(pct_to_tp, "#.##") + "%  ·  " + str.tostring(rr_real, "#.##") + "R" : "—",
               text_color = col_tp, text_size = size.small)

    table.cell(tbl, 0, 12, "  Beneficio Máx. ($)", text_color = color.lime, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 12, not na(max_gain) ? "+$" + str.tostring(max_gain, "#,###.00") : "—",
               text_color = color.lime, text_size = size.small)

    table.cell(tbl, 0, 13, "  Capital en Riesgo", text_color = color.gray, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 13, "$" + str.tostring(risk_usd, "#,###.00") +
               "  (" + str.tostring(risk_pct, "#.##") + "% de $" + str.tostring(capital, "#,###") + ")",
               text_color = color.white, text_size = size.small)

// ══════════════════════════════════════════════════════════════════════════════
//  CRUCES  —  detección manual según dirección inferida
//
//  Long:  HS se cruza bajando · TP se cruza subiendo · E2/E3 se cruzan bajando
//  Short: HS se cruza subiendo · TP se cruza bajando · E2/E3 se cruzan subiendo
// ══════════════════════════════════════════════════════════════════════════════
bool cross_hs_long  = close < hs_price and close[1] >= hs_price
bool cross_tp_long  = close > tp_price and close[1] <= tp_price
bool cross_e2_long  = low   < entry2   and low[1]   >= entry2   and low   > entry3
bool cross_e3_long  = low   < entry3   and low[1]   >= entry3   and low   > hs_price

bool cross_hs_short = close > hs_price and close[1] <= hs_price
bool cross_tp_short = close < tp_price and close[1] >= tp_price
bool cross_e2_short = high  > entry2   and high[1]  <= entry2   and high  < entry3
bool cross_e3_short = high  > entry3   and high[1]  <= entry3   and high  < hs_price

bool cross_hs = is_short ? cross_hs_short : cross_hs_long
bool cross_tp = is_short ? cross_tp_short : cross_tp_long
bool cross_e2 = is_short ? cross_e2_short : cross_e2_long
bool cross_e3 = is_short ? cross_e3_short : cross_e3_long

// ══════════════════════════════════════════════════════════════════════════════
//  ALERTAS TRADINGVIEW  (alertcondition — conforme con House Rules de TV)
// ══════════════════════════════════════════════════════════════════════════════
alertcondition(tv_on and valid_e and cross_hs,
               "⛔ HARD STOP TOCADO — Cerrar todo",
               "Hard Stop tocado. Cierra las posiciones de inmediato.")

alertcondition(tv_on and has_tp and cross_tp,
               "🎯 TAKE PROFIT ALCANZADO",
               "Take Profit alcanzado.")

alertcondition(tv_on and valid_e and cross_e2,
               "📍 Zona Entrada 2 alcanzada — Ejecutar 30%",
               "Precio en zona de Entrada 2. Despliega el 30% del riesgo asignado.")

alertcondition(tv_on and valid_e and cross_e3,
               "📍 Zona Entrada 3 alcanzada — Ejecutar 30%",
               "Precio en zona de Entrada 3. Despliega el 30% final del riesgo asignado.")
````

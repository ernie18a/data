# BT Vela RX

- url: https://www.tradingview.com/script/7n8DISuJ/
- type: indicator
- pine_id: PUB;62bb345d0a49459fadda1c9271898b58
- version: 1.0

## Description

El indicador sirve para marcar e identificar la anatomía de la vela, es decir: Podemos observar su formación de la vela anterior, también podemos observar la impresión de velas de otras temporalidades desde el gráfico que estoy observando. En otras palabras, puede ver la formación actual de una vela de mayor temporalidad para así detectar, posibles manipulaciones o rupturas en tiempo real. El indicador cuenta adicionalmente con un contador de velas para poder enumerar el estado de su formación.

## Source Code

````pine
//@version=5
indicator("BT Vela RX", overlay=true, max_lines_count=20, max_labels_count=10)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
grp_pos    = "📍 Posición"
grp_style  = "🎨 Estilo"
grp_label  = "🏷️ Etiqueta"
grp_anat   = "🔬 Anatomía Vela Anterior"

tf_select    = input.string("H4", "Vela a imprimir",
     options=["M15","M30","M45","H1","H4","D1","W","M"], group=grp_pos)
offset_bars  = input.int(40, "Distancia desde precio (barras)", minval=5, maxval=300, group=grp_pos)
candle_width = input.int(20, "Ancho de la vela (barras)",       minval=3, maxval=100, group=grp_pos)

bull_body_col = input.color(color.new(#00e5ff, 10), "Cuerpo Alcista", group=grp_style)
bear_body_col = input.color(color.new(#ff1744, 10), "Cuerpo Bajista", group=grp_style)
bull_border   = input.color(color.new(#00e5ff, 0),  "Borde Alcista",  group=grp_style)
bear_border   = input.color(color.new(#ff1744, 0),  "Borde Bajista",  group=grp_style)
wick_col      = input.color(color.new(#b2b5be, 0),  "Color Mechas",   group=grp_style)
open_line_col = input.color(color.new(#ffffff, 60), "Línea Apertura", group=grp_style)
wick_width    = input.int(2, "Grosor Mechas", minval=1, maxval=5,     group=grp_style)
border_width  = input.int(2, "Grosor Borde",  minval=1, maxval=5,     group=grp_style)

show_label   = input.bool(true, "Mostrar Etiqueta OHLC",  group=grp_label)
show_pips    = input.bool(true, "Mostrar Pips",           group=grp_label)
show_counter = input.bool(true, "Mostrar Contador Velas", group=grp_label)
label_col    = input.color(color.new(#1e222d, 5), "Fondo Etiqueta", group=grp_label)
label_txt    = input.color(color.white,            "Texto Etiqueta", group=grp_label)

show_anatomy  = input.bool(true,  "Mostrar Anatomía Vela Anterior",  group=grp_anat)
anat_col      = input.color(color.new(#ffffff, 10), "Color Trazo",   group=grp_anat)
anat_width    = input.int(2, "Grosor Trazo", minval=1, maxval=4,     group=grp_anat)
anat_offset_x = input.int(30, "Separación horizontal (barras)",      group=grp_anat, minval=5, maxval=200)
anat_scale    = input.float(3.0, "Escala vertical", minval=0.5, maxval=20.0, step=0.5, group=grp_anat)
anat_spread   = input.int(5, "Compresión horizontal (barras por vértice)", minval=1, maxval=30, group=grp_anat)

// ─── MAPEO DE TEMPORALIDAD ────────────────────────────────────────────────────
tf_string =
     tf_select == "M15" ? "15"  :
     tf_select == "M30" ? "30"  :
     tf_select == "M45" ? "45"  :
     tf_select == "H1"  ? "60"  :
     tf_select == "H4"  ? "240" :
     tf_select == "D1"  ? "D"   :
     tf_select == "W"   ? "W"   :
     tf_select == "M"   ? "M"   : "240"

tf_minutes_selected =
     tf_select == "M15" ? 15    :
     tf_select == "M30" ? 30    :
     tf_select == "M45" ? 45    :
     tf_select == "H1"  ? 60    :
     tf_select == "H4"  ? 240   :
     tf_select == "D1"  ? 1440  :
     tf_select == "W"   ? 10080 :
     tf_select == "M"   ? 43200 : 240

// ─── DATOS VELA ACTUAL ────────────────────────────────────────────────────────
sel_open  = request.security(syminfo.tickerid, tf_string, open,  lookahead=barmerge.lookahead_on)
sel_high  = request.security(syminfo.tickerid, tf_string, high,  lookahead=barmerge.lookahead_on)
sel_low   = request.security(syminfo.tickerid, tf_string, low,   lookahead=barmerge.lookahead_on)
sel_close = request.security(syminfo.tickerid, tf_string, close, lookahead=barmerge.lookahead_on)

// ─── DATOS VELA ANTERIOR ─────────────────────────────────────────────────────
prev_open  = request.security(syminfo.tickerid, tf_string, open[1],  lookahead=barmerge.lookahead_on)
prev_high  = request.security(syminfo.tickerid, tf_string, high[1],  lookahead=barmerge.lookahead_on)
prev_low   = request.security(syminfo.tickerid, tf_string, low[1],   lookahead=barmerge.lookahead_on)
prev_close = request.security(syminfo.tickerid, tf_string, close[1], lookahead=barmerge.lookahead_on)

// ─── CONTADOR ────────────────────────────────────────────────────────────────
tf_current_min  = timeframe.in_seconds() / 60
ratio           = tf_minutes_selected / tf_current_min
counter_visible = show_counter and ratio >= 2 and ratio <= 100
candles_per_sel = counter_visible ? math.round(ratio) : 0
tf_change       = ta.change(time(tf_string)) != 0

var int candle_count = 0
if tf_change
    candle_count := 1
else
    candle_count := counter_visible ? math.min(candle_count + 1, candles_per_sel) : 0

pct_done = candles_per_sel > 0 ? math.round(candle_count / candles_per_sel * 100) : 0

progress_bar(pct) =>
    filled = math.round(pct / 10)
    empty  = 10 - filled
    bar    = ""
    for i = 0 to filled - 1
        bar := bar + "█"
    for i = 0 to empty - 1
        bar := bar + "░"
    bar

// ─── ESTADO OHLC ACTUAL ───────────────────────────────────────────────────────
var float v_open  = na
var float v_high  = na
var float v_low   = na
var float v_close = na

if tf_change or na(v_open)
    v_open  := sel_open
    v_high  := sel_high
    v_low   := sel_low
    v_close := sel_close
else
    v_high  := math.max(v_high, sel_high)
    v_low   := math.min(v_low,  sel_low)
    v_close := sel_close

// ─── CAPTURA ORDEN REAL DE EXTREMOS (high o low primero) ─────────────────────
// Tracked en tiempo real barra a barra del TF actual
var float track_open     = na   // open de la vela en curso del TF superior
var float track_high     = na   // high máximo visto hasta ahora
var float track_low      = na   // low mínimo visto hasta ahora
var bool  high_first     = na   // true = high se movió antes que el low
var bool  extreme_decided = false

// Al inicio de nueva vela del TF superior: resetear tracking
if tf_change
    track_open      := sel_open
    track_high      := sel_high
    track_low       := sel_low
    extreme_decided := false
    high_first      := na

// Cada barra del TF actual: detectar qué extremo se extendió primero
if not tf_change and not extreme_decided
    new_high = sel_high > track_high
    new_low  = sel_low  < track_low
    if new_high and not new_low
        high_first      := true
        extreme_decided := true
    else if new_low and not new_high
        high_first      := false
        extreme_decided := true
    // Si ambos en la misma barra, usamos dirección de la vela actual como desempate
    else if new_high and new_low
        high_first      := sel_close < sel_open  // bajista = high primero
        extreme_decided := true
    track_high := math.max(track_high, sel_high)
    track_low  := math.min(track_low,  sel_low)

// Guardar el orden de la vela que ACABA de cerrar (la anterior)
var bool prev_high_first = na
if tf_change
    prev_high_first := high_first

// ─── OBJETOS GRÁFICOS ─────────────────────────────────────────────────────────
var box   body_box      = na
var line  wick_up       = na
var line  wick_dn       = na
var line  open_line     = na
var label info_label    = na

// Anatomía: 4 segmentos O→H, H→L, L→C + flecha final + label
var line  anat_oh       = na
var line  anat_hl       = na
var line  anat_lc       = na
var line  anat_arrow    = na

// ─── DIBUJO ───────────────────────────────────────────────────────────────────
if barstate.islast and not na(v_open)

    is_bull  = v_close >= v_open
    body_col = is_bull ? bull_body_col : bear_body_col
    bord_col = is_bull ? bull_border   : bear_border
    body_top = math.max(v_open, v_close)
    body_bot = math.min(v_open, v_close)

    left_bar  = bar_index + offset_bars
    right_bar = bar_index + offset_bars + candle_width
    mid_bar   = left_bar + math.floor(candle_width / 2)

    // Limpiar vela
    if not na(body_box)
        box.delete(body_box)
    if not na(wick_up)
        line.delete(wick_up)
    if not na(wick_dn)
        line.delete(wick_dn)
    if not na(open_line)
        line.delete(open_line)
    if not na(info_label)
        label.delete(info_label)

    // Limpiar anatomía
    if not na(anat_oh)
        line.delete(anat_oh)
    if not na(anat_hl)
        line.delete(anat_hl)
    if not na(anat_lc)
        line.delete(anat_lc)
    if not na(anat_arrow)
        line.delete(anat_arrow)

    // ── Cuerpo ──
    body_box := box.new(
         left=left_bar, top=body_top, right=right_bar, bottom=body_bot,
         bgcolor=body_col, border_color=bord_col, border_width=border_width)

    // ── Mechas ──
    wick_up := line.new(x1=mid_bar, y1=body_top, x2=mid_bar, y2=v_high,
         color=wick_col, width=wick_width)
    wick_dn := line.new(x1=mid_bar, y1=body_bot, x2=mid_bar, y2=v_low,
         color=wick_col, width=wick_width)

    // ── Línea apertura ──
    open_line := line.new(x1=left_bar, y1=v_open, x2=right_bar, y2=v_open,
         color=open_line_col, width=1, style=line.style_dashed)

    // ── Etiqueta ──
    if show_label
        pip_mult   = syminfo.mintick * 10
        range_pips = (v_high - v_low)           / pip_mult
        body_pips  = math.abs(v_close - v_open) / pip_mult
        dir_str    = is_bull ? "▲ ALCISTA" : "▼ BAJISTA"

        txt = "── " + tf_select + " ──\n" +
              dir_str + "\n" +
              "O  " + str.tostring(v_open,  format.mintick) + "\n" +
              "H  " + str.tostring(v_high,  format.mintick) + "\n" +
              "L  " + str.tostring(v_low,   format.mintick) + "\n" +
              "C  " + str.tostring(v_close, format.mintick)

        if show_pips
            txt := txt + "\n── PIPS ──\n" +
                   "Rango  " + str.tostring(range_pips, "#.0") + "\n" +
                   "Cuerpo " + str.tostring(body_pips,  "#.0")

        if counter_visible
            txt := txt + "\n── VELAS ──\n" +
                   str.tostring(candle_count) + " / " + str.tostring(candles_per_sel) +
                   "  (" + str.tostring(pct_done) + "%)\n" +
                   progress_bar(pct_done)

        info_label := label.new(
             x=right_bar + 3, y=body_top, text=txt,
             style=label.style_label_left, color=label_col,
             textcolor=label_txt, size=size.normal)

    // ── Anatomía vela anterior ──
    // El trazo sigue la secuencia real: O → H → L → C
    // Cada punto ocupa un slot horizontal equidistante
    if show_anatomy and not na(prev_open)

        // Ancla: arranca a la derecha de la etiqueta
        anat_x0 = right_bar + anat_offset_x

        // Espaciado: 4 puntos → 3 segmentos + flecha
        // Precio de referencia = mid del cuerpo actual
        ref_price = (body_top + body_bot) / 2

        // Coordenadas Y escaladas verticalmente
        y_o = ref_price + (prev_open  - prev_open) * anat_scale
        y_h = ref_price + (prev_high  - prev_open) * anat_scale
        y_l = ref_price + (prev_low   - prev_open) * anat_scale
        y_c = ref_price + (prev_close - prev_open) * anat_scale

        seg = anat_spread

        x0 = anat_x0
        x1 = anat_x0 + seg
        x2 = anat_x0 + seg * 2
        x3 = anat_x0 + seg * 3

        // Ruta real basada en el orden capturado barra a barra
        // prev_high_first=true → high se formó antes → O→H→L→C
        // prev_high_first=false → low se formó antes  → O→L→H→C
        use_high_first = na(prev_high_first) ? (prev_close < prev_open) : prev_high_first

        y_first  = use_high_first ? y_h : y_l
        y_second = use_high_first ? y_l : y_h

        // Segmento 1: Open → primer extremo
        anat_oh := line.new(x1=x0, y1=y_o, x2=x1, y2=y_first,
             color=anat_col, width=anat_width)

        // Segmento 2: primer extremo → segundo extremo
        anat_hl := line.new(x1=x1, y1=y_first, x2=x2, y2=y_second,
             color=anat_col, width=anat_width)

        // Segmento 3: segundo extremo → Close
        anat_lc := line.new(x1=x2, y1=y_second, x2=x3, y2=y_c,
             color=anat_col, width=anat_width)

        // Flecha de direccion
        anat_arrow := line.new(x1=x3, y1=y_c, x2=x3 + seg, y2=y_c,
             color=anat_col, width=anat_width,
             style=line.style_arrow_right)

plot(na)
````

# IC Pro [Gaps MTF + Sesiones + SMA]

- url: https://www.tradingview.com/script/zFr6JwJM-IC-Pro-Gaps-MTF-Sesiones-SMA/
- type: indicator
- pine_id: PUB;53c6120cd6504cc4acbe190066631469
- version: 2.0

## Description

The Rookie Profitable Trader is an advanced indicator designed to comprehensively analyze the market and simplify decision-making:

*   Normal Gaps: Detects bullish and bearish price gaps, displaying visual boxes and labels.
*   FVG (Fair Value Gaps): Identifies inverse gaps to pinpoint potential price fill zones.
*   Liquidation Levels: Marks significant recent highs and lows with lines and labels.
*   Market Sessions: Visualizes the New York, London, and Asian trading sessions, including their respective highs and lows.
*   Trend Reversal: Signals potential and confirmed trend reversals based on pivot highs and lows.
*   SMA + Signals: A configurable SMA featuring dynamic colors and crossover alerts (BUY/SELL).
*   Status Table: A visual summary of the SMA's condition, price vs. SMA status, open sessions, and active gaps/FVGs.

Key Features:

*   Multi-Timeframe (Configurable timeframe for Gaps and FVGs).
*   Customizable colors and styles for each module.
*   Integrated visual and audio alerts for trend reversals and SMA crossovers.
*   Compatible with Pine Script v5 and all TradingView charts.

Objective:
To provide both rookie and advanced traders with a complete visual roadmap of the market, enabling them to quickly and easily identify key zones, trends, and trading opportunities.

## Source Code

````pine
//@version=6
indicator('IC Pro [Gaps MTF + Sesiones + SMA]', shorttitle = 'IC-Pro v2', overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ================================================================
// SECCIÓN 1 — GAPS NORMALES
// ================================================================
g1 = 'GAPS NORMALES'
show_gaps = input.bool(true, 'Mostrar Gaps Normales', group = g1)
gap_tf = input.timeframe(defval = '', title = 'TimeFrame de Gaps (vacío = actual)', group = g1, tooltip = 'Ejemplos: 1,5,15,60,240,D,W. Deja vacío para usar el TF del gráfico')
gap_bull_bg = input.color(color.new(color.green, 75), 'Color Relleno — Gap Alcista', group = g1)
gap_bull_bdr = input.color(color.green, 'Color Borde — Gap Alcista', group = g1)
gap_bear_bg = input.color(color.new(color.red, 75), 'Color Relleno — Gap Bajista', group = g1)
gap_bear_bdr = input.color(color.red, 'Color Borde — Gap Bajista', group = g1)
gap_bdr_w = input.int(1, 'Grosor borde gaps', minval = 1, maxval = 4, group = g1)
show_gap_lbl = input.bool(true, 'Mostrar etiqueta al crear gap', group = g1)
gap_filled_del = input.bool(true, 'Eliminar gap cuando se llene', group = g1, tooltip = 'Cuando el precio toca la zona del gap, la caja desaparece')

gap_tf_used = gap_tf == '' ? timeframe.period : gap_tf
gap_o = request.security(syminfo.tickerid, gap_tf_used, open, lookahead = barmerge.lookahead_off)
gap_h = request.security(syminfo.tickerid, gap_tf_used, high, lookahead = barmerge.lookahead_off)
gap_l = request.security(syminfo.tickerid, gap_tf_used, low, lookahead = barmerge.lookahead_off)

bull_gap = show_gaps and gap_o > gap_h[1]
bear_gap = show_gaps and gap_o < gap_l[1]

var array<box> bgap_boxes = array.new<box>()
var array<box> sgap_boxes = array.new<box>()

if show_gaps
    if bull_gap
        b = box.new(bar_index - 1, gap_o, bar_index, gap_h[1], bgcolor = gap_bull_bg, border_color = gap_bull_bdr, border_width = gap_bdr_w)
        array.push(bgap_boxes, b)
        if show_gap_lbl
            label.new(bar_index, gap_o, 'GAP ↑', color = gap_bull_bdr, textcolor = color.white, size = size.tiny, style = label.style_label_down)
    if bear_gap
        b = box.new(bar_index - 1, gap_l[1], bar_index, gap_o, bgcolor = gap_bear_bg, border_color = gap_bear_bdr, border_width = gap_bdr_w)
        array.push(sgap_boxes, b)
        if show_gap_lbl
            label.new(bar_index, gap_o, 'GAP ↓', color = gap_bear_bdr, textcolor = color.white, size = size.tiny, style = label.style_label_up)
    for i = array.size(bgap_boxes) - 1 to 0 by 1
        b = array.get(bgap_boxes, i)
        if gap_filled_del and low <= box.get_bottom(b)
            box.delete(b)
            array.remove(bgap_boxes, i)
        else
            box.set_right(b, bar_index)
    for i = array.size(sgap_boxes) - 1 to 0 by 1
        b = array.get(sgap_boxes, i)
        if gap_filled_del and high >= box.get_top(b)
            box.delete(b)
            array.remove(sgap_boxes, i)
        else
            box.set_right(b, bar_index)

// ================================================================
// SECCIÓN 2 — FVG
// ================================================================
g2 = 'FVG / GAPS INVERSOS'
show_fvg = input.bool(true, 'Mostrar FVG (Gaps Inversos)', group = g2)
fvg_tf = input.timeframe(defval = '', title = 'TimeFrame de FVG', group = g2, tooltip = 'Ejemplos: 1,5,15,60,240,D,W. Deja vacío para usar el TF del gráfico')
fvg_bull_bg = input.color(color.new(color.aqua, 75), 'Color Relleno — FVG Alcista', group = g2)
fvg_bull_bdr = input.color(color.aqua, 'Color Borde — FVG Alcista', group = g2)
fvg_bear_bg = input.color(color.new(color.orange, 75), 'Color Relleno — FVG Bajista', group = g2)
fvg_bear_bdr = input.color(color.orange, 'Color Borde — FVG Bajista', group = g2)
fvg_bdr_w = input.int(1, 'Grosor borde FVG', minval = 1, maxval = 4, group = g2)
fvg_filled_del = input.bool(true, 'Eliminar FVG cuando se llene', group = g2)

fvg_tf_used = fvg_tf == '' ? timeframe.period : fvg_tf
fvg_h = request.security(syminfo.tickerid, fvg_tf_used, high, lookahead = barmerge.lookahead_off)
fvg_l = request.security(syminfo.tickerid, fvg_tf_used, low, lookahead = barmerge.lookahead_off)

bull_fvg = show_fvg and fvg_l > fvg_h[2]
bear_fvg = show_fvg and fvg_h < fvg_l[2]

var array<box> bfvg_boxes = array.new<box>()
var array<box> sfvg_boxes = array.new<box>()

if show_fvg
    if bull_fvg
        b = box.new(bar_index - 2, fvg_h[2], bar_index, fvg_l, bgcolor = fvg_bull_bg, border_color = fvg_bull_bdr, border_width = fvg_bdr_w)
        array.push(bfvg_boxes, b)
    if bear_fvg
        b = box.new(bar_index - 2, fvg_h, bar_index, fvg_l[2], bgcolor = fvg_bear_bg, border_color = fvg_bear_bdr, border_width = fvg_bdr_w)
        array.push(sfvg_boxes, b)
    for i = array.size(bfvg_boxes) - 1 to 0 by 1
        b = array.get(bfvg_boxes, i)
        if fvg_filled_del and low <= box.get_bottom(b)
            box.delete(b)
            array.remove(bfvg_boxes, i)
        else
            box.set_right(b, bar_index)
    for i = array.size(sfvg_boxes) - 1 to 0 by 1
        b = array.get(sfvg_boxes, i)
        if fvg_filled_del and high >= box.get_top(b)
            box.delete(b)
            array.remove(sfvg_boxes, i)
        else
            box.set_right(b, bar_index)

// ================================================================
// SECCIÓN 3 — NIVELES DE LIQUIDACIÓN
// ================================================================
g3 = 'LIQUIDACIONES'
show_liq = input.bool(true, 'Mostrar Niveles de Liquidación', group = g3)
liq_lookback = input.int(20, 'Períodos para detectar swing', minval = 5, maxval = 100, group = g3)
liq_tf = input.timeframe(defval = '', title = 'TimeFrame Liquidaciones', group = g3)
liq_hi_col = input.color(color.new(color.purple, 50), 'Color Liquidación Alta', group = g3)
liq_lo_col = input.color(color.new(color.fuchsia, 50), 'Color Liquidación Baja', group = g3)
liq_width = input.int(2, 'Grosor línea liquidación', minval = 1, maxval = 4, group = g3)
liq_style_inp = input.string('Punteada', 'Estilo línea', group = g3, options = ['Sólida', 'Punteada', 'Rayada'])

liq_h_src = request.security(syminfo.tickerid, liq_tf == '' ? timeframe.period : liq_tf, high, lookahead = barmerge.lookahead_off)
liq_l_src = request.security(syminfo.tickerid, liq_tf == '' ? timeframe.period : liq_tf, low, lookahead = barmerge.lookahead_off)

liq_highest = ta.highest(liq_h_src, liq_lookback)
liq_lowest = ta.lowest(liq_l_src, liq_lookback)

new_liq_h = liq_h_src == liq_highest and liq_h_src[1] != liq_highest
new_liq_l = liq_l_src == liq_lowest and liq_l_src[1] != liq_lowest

line_style(s) =>
    s == 'Sólida' ? line.style_solid : s == 'Punteada' ? line.style_dotted : line.style_dashed
liq_ls = line_style(liq_style_inp)

if show_liq
    if new_liq_h
        line.new(bar_index - liq_lookback, liq_highest, bar_index, liq_highest, color = liq_hi_col, width = liq_width, style = liq_ls)
        label.new(bar_index, liq_highest, 'LIQ HI', color = liq_hi_col, textcolor = color.white, style = label.style_label_left, size = size.tiny)
    if new_liq_l
        line.new(bar_index - liq_lookback, liq_lowest, bar_index, liq_lowest, color = liq_lo_col, width = liq_width, style = liq_ls)
        label.new(bar_index, liq_lowest, 'LIQ LO', color = liq_lo_col, textcolor = color.white, style = label.style_label_left, size = size.tiny)

// ================================================================
// SECCIÓN 4 — SESIONES
// ================================================================
g4 = 'SESIONES'
show_ny = input.bool(true, 'Sesión New York', group = g4)
ny_sess = input.session('1300-2000', 'Horario NY (UTC)', group = g4)
ny_bg = input.color(color.new(color.blue, 88), 'Fondo NY', group = g4)
ny_bdr = input.color(color.new(color.blue, 30), 'Borde NY', group = g4)
ny_hl_col = input.color(color.blue, 'Líneas H/L NY', group = g4)

show_asia = input.bool(true, 'Sesión Asia', group = g4)
asia_sess = input.session('0000-0900', 'Horario Asia (UTC)', group = g4)
asia_bg = input.color(color.new(color.yellow, 88), 'Fondo Asia', group = g4)
asia_bdr = input.color(color.new(color.yellow, 30), 'Borde Asia', group = g4)
asia_hl_col = input.color(color.yellow, 'Líneas H/L Asia', group = g4)

show_ldn = input.bool(true, 'Sesión Londres', group = g4)
ldn_sess = input.session('0700-1600', 'Horario Londres (UTC)', group = g4)
ldn_bg = input.color(color.new(color.orange, 88), 'Fondo Londres', group = g4)
ldn_bdr = input.color(color.new(color.orange, 30), 'Borde Londres', group = g4)
ldn_hl_col = input.color(color.orange, 'Líneas H/L Londres', group = g4)

in_sess(s) =>
    not na(time(timeframe.period, s))

var float ny_h = na
var float ny_l = na
var int ny_s = na
var bool ny_act = false
var box ny_bx = na
in_ny = in_sess(ny_sess)

if show_ny
    if in_ny and not ny_act
        ny_h := high
        ny_l := low
        ny_s := bar_index
        ny_act := true
        ny_act
    else if in_ny and ny_act
        ny_h := math.max(ny_h, high)
        ny_l := math.min(ny_l, low)
        if not na(ny_bx)
            box.set_top(ny_bx, ny_h)
            box.set_bottom(ny_bx, ny_l)
            box.set_right(ny_bx, bar_index)
        else
            ny_bx := box.new(ny_s, ny_h, bar_index, ny_l, bgcolor = ny_bg, border_color = ny_bdr, border_width = 1)
            ny_bx
    else if not in_ny and ny_act
        line.new(ny_s, ny_h, bar_index + 50, ny_h, color = ny_hl_col, width = 1, style = line.style_dotted)
        line.new(ny_s, ny_l, bar_index + 50, ny_l, color = ny_hl_col, width = 1, style = line.style_dotted)
        ny_act := false
        ny_bx := na
        ny_bx

// --- Asia ---
var float as_h = na
var float as_l = na
var int as_s = na
var bool as_act = false
var box as_bx = na
in_asia = in_sess(asia_sess)

if show_asia
    if in_asia and not as_act
        as_h := high
        as_l := low
        as_s := bar_index
        as_act := true
        as_act
    else if in_asia and as_act
        as_h := math.max(as_h, high)
        as_l := math.min(as_l, low)
        if not na(as_bx)
            box.set_top(as_bx, as_h)
            box.set_bottom(as_bx, as_l)
            box.set_right(as_bx, bar_index)
        else
            as_bx := box.new(as_s, as_h, bar_index, as_l, bgcolor = asia_bg, border_color = asia_bdr, border_width = 1)
            as_bx
    else if not in_asia and as_act
        line.new(as_s, as_h, bar_index + 50, as_h, color = asia_hl_col, width = 1, style = line.style_dotted)
        line.new(as_s, as_l, bar_index + 50, as_l, color = asia_hl_col, width = 1, style = line.style_dotted)
        as_act := false
        as_bx := na
        as_bx

// --- Londres ---
var float ld_h = na
var float ld_l = na
var int ld_s = na
var bool ld_act = false
var box ld_bx = na
in_ldn = in_sess(ldn_sess)

if show_ldn
    if in_ldn and not ld_act
        ld_h := high
        ld_l := low
        ld_s := bar_index
        ld_act := true
        ld_act
    else if in_ldn and ld_act
        ld_h := math.max(ld_h, high)
        ld_l := math.min(ld_l, low)
        if not na(ld_bx)
            box.set_top(ld_bx, ld_h)
            box.set_bottom(ld_bx, ld_l)
            box.set_right(ld_bx, bar_index)
        else
            ld_bx := box.new(ld_s, ld_h, bar_index, ld_l, bgcolor = ldn_bg, border_color = ldn_bdr, border_width = 1)
            ld_bx
    else if not in_ldn and ld_act
        line.new(ld_s, ld_h, bar_index + 50, ld_h, color = ldn_hl_col, width = 1, style = line.style_dotted)
        line.new(ld_s, ld_l, bar_index + 50, ld_l, color = ldn_hl_col, width = 1, style = line.style_dotted)
        ld_act := false
        ld_bx := na
        ld_bx

// ================================================================
// SECCIÓN 5 — TREND REVERSAL
// ================================================================
g5 = 'TREND REVERSAL'
show_tr = input.bool(true, 'Mostrar Trend Reversals', group = g5)
tr_lookback = input.int(5, 'Sensibilidad (barras)', minval = 2, maxval = 20, group = g5)
show_possible = input.bool(true, 'Mostrar Posibles Reversals', group = g5)
show_confirmed = input.bool(true, 'Mostrar Confirmados', group = g5)
poss_bull_col = input.color(color.new(color.teal, 30), 'Color — Posible Bull Rev', group = g5)
poss_bear_col = input.color(color.new(color.maroon, 30), 'Color — Posible Bear Rev', group = g5)
conf_bull_col = input.color(color.new(color.green, 10), 'Color — Confirmado Bull Rev', group = g5)
conf_bear_col = input.color(color.new(color.red, 10), 'Color — Confirmado Bear Rev', group = g5)

sw_h = ta.pivothigh(high, tr_lookback, tr_lookback)
sw_l = ta.pivotlow(low, tr_lookback, tr_lookback)
poss_bull = show_tr and show_possible and not na(sw_l) and low <= sw_l
poss_bear = show_tr and show_possible and not na(sw_h) and high >= sw_h
conf_bull = show_tr and show_confirmed and not na(sw_l) and close > sw_l and close[1] <= sw_l
conf_bear = show_tr and show_confirmed and not na(sw_h) and close < sw_h and close[1] >= sw_h

if poss_bull
    label.new(bar_index - tr_lookback, sw_l, 'Possible Bull Rev', color = poss_bull_col, textcolor = color.white, style = label.style_label_up, size = size.small)
if poss_bear
    label.new(bar_index - tr_lookback, sw_h, 'Possible Bear Rev', color = poss_bear_col, textcolor = color.white, style = label.style_label_down, size = size.small)
if conf_bull
    label.new(bar_index, low, 'Confirmed Bull Rev', color = conf_bull_col, textcolor = color.white, style = label.style_label_up, size = size.normal)
    alert('Confirmed Bull Reversal', alert.freq_once_per_bar)
if conf_bear
    label.new(bar_index, high, 'Confirmed Bear Rev', color = conf_bear_col, textcolor = color.white, style = label.style_label_down, size = size.normal)
    alert('Confirmed Bear Reversal', alert.freq_once_per_bar)

// ================================================================
// SECCIÓN 6 — SMA + SEÑALES BUY/SELL
// ================================================================
g6 = 'SMA'
show_sma = input.bool(true, 'Mostrar SMA', group = g6)
sma_len = input.int(200, 'Período SMA', minval = 1, maxval = 500, group = g6)
sma_width = input.int(2, 'Grosor línea SMA', minval = 1, maxval = 5, group = g6)
sma_bull_col = input.color(color.green, 'Color SMA — Alcista', group = g6)
sma_bear_col = input.color(color.red, 'Color SMA — Bajista', group = g6)
sma_flat_col = input.color(color.yellow, 'Color SMA — Lateral', group = g6)
show_signals = input.bool(true, 'Mostrar señales BUY / SELL', group = g6)
buy_lbl_col = input.color(color.new(color.green, 10), 'Color etiqueta BUY', group = g6)
sell_lbl_col = input.color(color.new(color.red, 10), 'Color etiqueta SELL', group = g6)
show_bar_col = input.bool(true, 'Colorear velas al tocar SMA', group = g6)

sma_val = ta.sma(close, sma_len)
sma_rising = sma_val > sma_val[1]
sma_falling = sma_val < sma_val[1]
sma_color = sma_rising ? sma_bull_col : sma_falling ? sma_bear_col : sma_flat_col
cross_up = ta.crossover(close, sma_val)
cross_dn = ta.crossunder(close, sma_val)
near_sma = math.abs(close - sma_val) / sma_val < 0.0015

bar_c = show_bar_col and near_sma ? sma_rising ? sma_bull_col : sma_falling ? sma_bear_col : sma_flat_col : na

if show_sma
    sma_val
    'SMA'
    color = sma_color
    linewidth = sma_width
    bar_c

    if show_signals
        if cross_up
            label.new(bar_index, low, 'BUY', color = buy_lbl_col, textcolor = color.white, style = label.style_label_up, size = size.normal)
            alert('BUY — Precio cruzó SMA hacia arriba', alert.freq_once_per_bar)
        if cross_dn
            label.new(bar_index, high, 'SELL', color = sell_lbl_col, textcolor = color.white, style = label.style_label_down, size = size.normal)
            alert('SELL — Precio cruzó SMA hacia abajo', alert.freq_once_per_bar)

// ================================================================
// SECCIÓN 7 — TABLA DE ESTADO
// ================================================================
g7 = 'TABLA'
show_table = input.bool(true, 'Mostrar tabla de estado', group = g7)
tbl_pos = input.string('Arriba Derecha', 'Posición tabla', group = g7, options = ['Arriba Derecha', 'Arriba Izquierda', 'Abajo Derecha', 'Abajo Izquierda'])
tbl_bg = input.color(color.new(color.black, 55), 'Fondo tabla', group = g7)

tbl_position(p) =>
    p == 'Arriba Derecha' ? position.top_right : p == 'Arriba Izquierda' ? position.top_left : p == 'Abajo Derecha' ? position.bottom_right : position.bottom_left

var table t = table.new(tbl_position(tbl_pos), 2, 9, bgcolor = tbl_bg, border_width = 1, border_color = color.new(color.gray, 60))

if show_table and barstate.islast
    table.cell(t, 0, 0, 'MÓDULO', text_color = color.white, bgcolor = color.new(color.navy, 20), text_size = size.small)
    table.cell(t, 1, 0, 'ESTADO', text_color = color.white, bgcolor = color.new(color.navy, 20), text_size = size.small)
````

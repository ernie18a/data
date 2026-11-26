# Smart Money Liquidity Heatmap

- url: https://www.tradingview.com/script/Igx5izJV/
- type: indicator
- pine_id: PUB;b42b6a14410b4d78b734129a945fde4d
- version: 1.0

## Description

Este indicador te permite ver las posibles zonas de rebote.

## Source Code

````pine
// =============================================================================
// SMART MONEY LIQUIDITY HEATMAP — Zonas de Reacción con Calorimetría
// Versión: 1.2  (compatible Pine Script v6)
// =============================================================================

//@version=6
indicator("Smart Money Liquidity Heatmap", shorttitle="SM·LH", overlay=true, max_boxes_count=200, max_lines_count=200, max_labels_count=100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grp_ob    = "Order Blocks"
grp_liq   = "Liquidez"
grp_fvg   = "Fair Value Gaps"
grp_score = "Puntuación de Zonas"
grp_disp  = "Visualización"

ob_enabled   = input.bool(true,  "Mostrar Order Blocks",         group=grp_ob)
ob_mitigated = input.bool(false, "Ocultar OB Mitigados",         group=grp_ob)

liq_enabled   = input.bool(true,  "Mostrar Zonas de Liquidez",   group=grp_liq)
liq_tolerance = input.float(0.1,  "Tolerancia Equal H/L (%)",    group=grp_liq, minval=0.01, maxval=1.0, step=0.01)

fvg_enabled  = input.bool(true,  "Mostrar Fair Value Gaps",      group=grp_fvg)
fvg_min_size = input.float(0.05, "Tamaño mínimo FVG (%)",        group=grp_fvg, minval=0.01, maxval=2.0, step=0.01)

score_vol    = input.bool(true, "Ponderar por Volumen",          group=grp_score)
score_touch  = input.bool(true, "Penalizar por Toques Previos",  group=grp_score)
score_struct = input.bool(true, "Bonus por Estructura (CHoCH)",  group=grp_score)

show_labels  = input.bool(true,  "Mostrar Etiquetas de Score",   group=grp_disp)
show_premium = input.bool(true,  "Mostrar Zona Premium/Discount",group=grp_disp)
swing_range  = input.int(50,     "Rango para Premium/Discount",  group=grp_disp, minval=20, maxval=200)
label_size   = input.string("small", "Tamaño de Etiquetas",      group=grp_disp, options=["tiny","small","normal"])

// ─────────────────────────────────────────────────────────────────────────────
// CALORIMETRÍA
// ─────────────────────────────────────────────────────────────────────────────
f_heat_color(score, alpha) =>
    r = score >= 50 ? int(255 * (1 - (score - 50) / 50)) : 255
    g = score <= 50 ? int(255 * score / 50) : 255
    color.rgb(r, g, 0, alpha)

// ─────────────────────────────────────────────────────────────────────────────
// UTILIDADES
// ─────────────────────────────────────────────────────────────────────────────
f_is_bull(o, c) => c > o
f_is_bear(o, c) => c < o

vol_ma = ta.sma(volume, 20)
f_vol_score(v) =>
    ratio = vol_ma == 0 ? 1.0 : v / vol_ma
    math.min(ratio, 3.0) / 3.0

// ─────────────────────────────────────────────────────────────────────────────
// SWING HIGH / LOW
// ─────────────────────────────────────────────────────────────────────────────
swing_len = 5
swing_hi  = ta.pivothigh(high, swing_len, swing_len)
swing_lo  = ta.pivotlow (low,  swing_len, swing_len)

var float last_sh       = na
var float last_sl       = na
var bool  bullish_choch = false
var bool  bearish_choch = false

if not na(swing_hi)
    bullish_choch := not na(last_sh) and swing_hi > last_sh
    last_sh := swing_hi
if not na(swing_lo)
    bearish_choch := not na(last_sl) and swing_lo < last_sl
    last_sl := swing_lo

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM / DISCOUNT
// ─────────────────────────────────────────────────────────────────────────────
range_hi  = ta.highest(high, swing_range)
range_lo  = ta.lowest (low,  swing_range)
range_mid = (range_hi + range_lo) / 2.0

// ─────────────────────────────────────────────────────────────────────────────
// FVG ARRAYS — declarados ANTES de f_score para que estén en scope
// ─────────────────────────────────────────────────────────────────────────────
var fvg_bull_top = array.new_float(0)
var fvg_bull_bot = array.new_float(0)
var fvg_bull_bar = array.new_int(0)
var fvg_bear_top = array.new_float(0)
var fvg_bear_bot = array.new_float(0)
var fvg_bear_bar = array.new_int(0)

// ─────────────────────────────────────────────────────────────────────────────
// FUNCIÓN DE PUNTUACIÓN
// Ahora los arrays fvg_* ya están declarados arriba → sin undeclared identifier
// ─────────────────────────────────────────────────────────────────────────────
f_score(vol_raw, hits, zone_top, zone_bot, is_bull) =>
    // 1. Volumen
    vol_pts = score_vol ? f_vol_score(vol_raw) * 30 : 15.0

    // 2. Toques
    touch_pen = score_touch ? (hits <= 1 ? 0.0 : hits == 2 ? 10.0 : 25.0) : 0.0
    touch_pts = 25.0 - touch_pen

    // 3. Premium / Discount
    zone_center = (zone_top + zone_bot) / 2.0
    pd_pts = show_premium ? (is_bull ? (zone_center < range_mid ? 20.0 : 5.0)
                                      : (zone_center > range_mid ? 20.0 : 5.0)) : 10.0

    // 4. Confluencia FVG
    fvg_conf = 0.0
    if fvg_enabled
        n = is_bull ? array.size(fvg_bull_top) : array.size(fvg_bear_top)
        if n > 0
            for fi = 0 to n - 1
                ft = is_bull ? array.get(fvg_bull_top, fi) : array.get(fvg_bear_top, fi)
                fb = is_bull ? array.get(fvg_bull_bot, fi) : array.get(fvg_bear_bot, fi)
                if ft >= zone_bot and fb <= zone_top
                    fvg_conf := 15.0
                    break

    // 5. Estructura CHoCH
    struct_pts = 0.0
    if score_struct
        struct_pts := is_bull and bullish_choch ? 10.0 :
                      not is_bull and bearish_choch ? 10.0 : 0.0

    math.min(math.max(vol_pts + touch_pts + pd_pts + fvg_conf + struct_pts, 0.0), 100.0)

// ─────────────────────────────────────────────────────────────────────────────
// ATR
// ─────────────────────────────────────────────────────────────────────────────
atr14       = ta.atr(14)
impulse_min = atr14 * 1.5

// ─────────────────────────────────────────────────────────────────────────────
// ORDER BLOCKS
// ─────────────────────────────────────────────────────────────────────────────
var ob_bull_top   = array.new_float(0)
var ob_bull_bot   = array.new_float(0)
var ob_bull_bar   = array.new_int(0)
var ob_bull_vol   = array.new_float(0)
var ob_bull_hits  = array.new_int(0)
var ob_bull_score = array.new_float(0)

var ob_bear_top   = array.new_float(0)
var ob_bear_bot   = array.new_float(0)
var ob_bear_bar   = array.new_int(0)
var ob_bear_vol   = array.new_float(0)
var ob_bear_hits  = array.new_int(0)
var ob_bear_score = array.new_float(0)

is_bull_impulse = f_is_bull(open, close) and (close - open) > impulse_min
is_bear_impulse = f_is_bear(open, close) and (open - close) > impulse_min

if ob_enabled and is_bull_impulse and f_is_bear(open[1], close[1])
    array.push(ob_bull_top,   high[1])
    array.push(ob_bull_bot,   low[1])
    array.push(ob_bull_bar,   bar_index - 1)
    array.push(ob_bull_vol,   volume[1])
    array.push(ob_bull_hits,  0)
    array.push(ob_bull_score, 0.0)

if ob_enabled and is_bear_impulse and f_is_bull(open[1], close[1])
    array.push(ob_bear_top,   high[1])
    array.push(ob_bear_bot,   low[1])
    array.push(ob_bear_bar,   bar_index - 1)
    array.push(ob_bear_vol,   volume[1])
    array.push(ob_bear_hits,  0)
    array.push(ob_bear_score, 0.0)

// Toques + score OB bull
if ob_enabled and array.size(ob_bull_top) > 0
    for i = array.size(ob_bull_top) - 1 to 0
        ztop = array.get(ob_bull_top, i)
        zbot = array.get(ob_bull_bot, i)
        if low <= ztop and high >= zbot
            array.set(ob_bull_hits, i, array.get(ob_bull_hits, i) + 1)
        sc = f_score(array.get(ob_bull_vol, i), array.get(ob_bull_hits, i), ztop, zbot, true)
        array.set(ob_bull_score, i, sc)
        if ob_mitigated and close < zbot
            array.remove(ob_bull_top,   i)
            array.remove(ob_bull_bot,   i)
            array.remove(ob_bull_bar,   i)
            array.remove(ob_bull_vol,   i)
            array.remove(ob_bull_hits,  i)
            array.remove(ob_bull_score, i)

// Toques + score OB bear
if ob_enabled and array.size(ob_bear_top) > 0
    for i = array.size(ob_bear_top) - 1 to 0
        ztop = array.get(ob_bear_top, i)
        zbot = array.get(ob_bear_bot, i)
        if low <= ztop and high >= zbot
            array.set(ob_bear_hits, i, array.get(ob_bear_hits, i) + 1)
        sc = f_score(array.get(ob_bear_vol, i), array.get(ob_bear_hits, i), ztop, zbot, false)
        array.set(ob_bear_score, i, sc)
        if ob_mitigated and close > ztop
            array.remove(ob_bear_top,   i)
            array.remove(ob_bear_bot,   i)
            array.remove(ob_bear_bar,   i)
            array.remove(ob_bear_vol,   i)
            array.remove(ob_bear_hits,  i)
            array.remove(ob_bear_score, i)

// ─────────────────────────────────────────────────────────────────────────────
// EQUAL HIGHS / EQUAL LOWS
// ─────────────────────────────────────────────────────────────────────────────
var liq_hi_price = array.new_float(0)
var liq_lo_price = array.new_float(0)
var liq_hi_bar   = array.new_int(0)
var liq_lo_bar   = array.new_int(0)
var liq_hi_hits  = array.new_int(0)
var liq_lo_hits  = array.new_int(0)

tol_pct = liq_tolerance / 100.0

if liq_enabled and not na(swing_hi)
    found = false
    for i = 0 to math.min(array.size(liq_hi_price) - 1, 20)
        prev = array.get(liq_hi_price, i)
        if math.abs(swing_hi - prev) / prev <= tol_pct
            found := true
            array.set(liq_hi_hits, i, array.get(liq_hi_hits, i) + 1)
            break
    if not found
        array.push(liq_hi_price, swing_hi)
        array.push(liq_hi_bar,   bar_index - swing_len)
        array.push(liq_hi_hits,  1)

if liq_enabled and not na(swing_lo)
    found2 = false
    for i = 0 to math.min(array.size(liq_lo_price) - 1, 20)
        prev2 = array.get(liq_lo_price, i)
        if math.abs(swing_lo - prev2) / prev2 <= tol_pct
            found2 := true
            array.set(liq_lo_hits, i, array.get(liq_lo_hits, i) + 1)
            break
    if not found2
        array.push(liq_lo_price, swing_lo)
        array.push(liq_lo_bar,   bar_index - swing_len)
        array.push(liq_lo_hits,  1)

// ─────────────────────────────────────────────────────────────────────────────
// FAIR VALUE GAPS — llenado de los arrays (declarados arriba)
// ─────────────────────────────────────────────────────────────────────────────
fvg_min = close * (fvg_min_size / 100.0)

if fvg_enabled
    if low > high[2] and (low - high[2]) >= fvg_min
        array.push(fvg_bull_top, low)
        array.push(fvg_bull_bot, high[2])
        array.push(fvg_bull_bar, bar_index)
    if high < low[2] and (low[2] - high) >= fvg_min
        array.push(fvg_bear_top, low[2])
        array.push(fvg_bear_bot, high)
        array.push(fvg_bear_bar, bar_index)

// ─────────────────────────────────────────────────────────────────────────────
// RENDERIZADO — última barra
// ─────────────────────────────────────────────────────────────────────────────
lbl_sz = label_size == "tiny" ? size.tiny : label_size == "small" ? size.small : size.normal

if barstate.islast

    // Premium / Discount
    if show_premium
        box.new(bar_index - swing_range, range_hi, bar_index + 5, range_mid,
                 border_color=color.new(color.orange, 80),
                 bgcolor=color.new(color.orange, 90),
                 text="Premium", text_color=color.new(color.orange, 20),
                 text_size=size.tiny, text_halign=text.align_right)
        box.new(bar_index - swing_range, range_mid, bar_index + 5, range_lo,
                 border_color=color.new(color.teal, 80),
                 bgcolor=color.new(color.teal, 90),
                 text="Discount", text_color=color.new(color.teal, 20),
                 text_size=size.tiny, text_halign=text.align_right)
        line.new(bar_index - swing_range, range_mid, bar_index + 5, range_mid,
                  color=color.new(color.gray, 50), style=line.style_dashed, width=1)

    // OB Bullish
    if ob_enabled
        sz = array.size(ob_bull_top)
        if sz > 0
            max_draw = math.min(sz, 10)
            for i = sz - max_draw to sz - 1
                ztop = array.get(ob_bull_top,   i)
                zbot = array.get(ob_bull_bot,   i)
                zbar = array.get(ob_bull_bar,   i)
                sc   = array.get(ob_bull_score, i)
                col  = f_heat_color(sc, 65)
                box.new(zbar, ztop, bar_index + 3, zbot,
                         border_color=f_heat_color(sc, 20), bgcolor=col, border_width=1)
                if show_labels
                    label.new(bar_index + 3, (ztop + zbot) / 2,
                               "OB↑ " + str.tostring(math.round(sc)) + "%",
                               style=label.style_label_left,
                               color=color.new(color.black, 100),
                               textcolor=f_heat_color(sc, 0), size=lbl_sz)

    // OB Bearish
    if ob_enabled
        sz = array.size(ob_bear_top)
        if sz > 0
            max_draw = math.min(sz, 10)
            for i = sz - max_draw to sz - 1
                ztop = array.get(ob_bear_top,   i)
                zbot = array.get(ob_bear_bot,   i)
                zbar = array.get(ob_bear_bar,   i)
                sc   = array.get(ob_bear_score, i)
                col  = f_heat_color(sc, 65)
                box.new(zbar, ztop, bar_index + 3, zbot,
                         border_color=f_heat_color(sc, 20), bgcolor=col, border_width=1)
                if show_labels
                    label.new(bar_index + 3, (ztop + zbot) / 2,
                               "OB↓ " + str.tostring(math.round(sc)) + "%",
                               style=label.style_label_left,
                               color=color.new(color.black, 100),
                               textcolor=f_heat_color(sc, 0), size=lbl_sz)

    // Equal Highs
    if liq_enabled
        sz = array.size(liq_hi_price)
        if sz > 0
            max_draw = math.min(sz, 8)
            for i = sz - max_draw to sz - 1
                lp   = array.get(liq_hi_price, i)
                lb   = array.get(liq_hi_bar,   i)
                lhts = array.get(liq_hi_hits,  i)
                liq_score = math.min(lhts * 20, 100)
                lcol = f_heat_color(liq_score, 60)
                line.new(lb, lp, bar_index + 3, lp,
                          color=lcol, width=2, style=line.style_dotted)
                if show_labels
                    label.new(bar_index + 3, lp, "EQH x" + str.tostring(lhts),
                               style=label.style_label_left,
                               color=color.new(color.black, 100),
                               textcolor=lcol, size=size.tiny)

    // Equal Lows
    if liq_enabled
        sz = array.size(liq_lo_price)
        if sz > 0
            max_draw = math.min(sz, 8)
            for i = sz - max_draw to sz - 1
                lp   = array.get(liq_lo_price, i)
                lb   = array.get(liq_lo_bar,   i)
                lhts = array.get(liq_lo_hits,  i)
                liq_score = math.min(lhts * 20, 100)
                lcol = f_heat_color(liq_score, 60)
                line.new(lb, lp, bar_index + 3, lp,
                          color=lcol, width=2, style=line.style_dotted)
                if show_labels
                    label.new(bar_index + 3, lp, "EQL x" + str.tostring(lhts),
                               style=label.style_label_left,
                               color=color.new(color.black, 100),
                               textcolor=lcol, size=size.tiny)

    // FVG Bullish
    if fvg_enabled
        sz = array.size(fvg_bull_top)
        if sz > 0
            max_draw = math.min(sz, 8)
            for i = sz - max_draw to sz - 1
                ft  = array.get(fvg_bull_top, i)
                fb  = array.get(fvg_bull_bot, i)
                fb2 = array.get(fvg_bull_bar, i)
                box.new(fb2 - 2, ft, bar_index + 2, fb,
                         border_color=color.new(color.teal, 40),
                         bgcolor=color.new(color.teal, 85), border_width=1)
                if show_labels
                    label.new(fb2, (ft + fb) / 2, "FVG+",
                               style=label.style_label_right,
                               color=color.new(color.black, 100),
                               textcolor=color.teal, size=size.tiny)

    // FVG Bearish
    if fvg_enabled
        sz2 = array.size(fvg_bear_top)
        if sz2 > 0
            max_draw2 = math.min(sz2, 8)
            for i = sz2 - max_draw2 to sz2 - 1
                ft  = array.get(fvg_bear_top, i)
                fb  = array.get(fvg_bear_bot, i)
                fb2 = array.get(fvg_bear_bar, i)
                box.new(fb2 - 2, ft, bar_index + 2, fb,
                         border_color=color.new(color.orange, 40),
                         bgcolor=color.new(color.orange, 85), border_width=1)
                if show_labels
                    label.new(fb2, (ft + fb) / 2, "FVG-",
                               style=label.style_label_right,
                               color=color.new(color.black, 100),
                               textcolor=color.orange, size=size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// TABLA
// ─────────────────────────────────────────────────────────────────────────────
var table legend = table.new(position.top_right, 2, 9,
     bgcolor=color.new(color.black, 70), border_width=1,
     border_color=color.new(color.gray, 50), frame_width=1,
     frame_color=color.new(color.gray, 50))

if barstate.islast
    table.cell(legend, 0, 0, "SM·LH",   text_color=color.white,
               text_size=size.small, bgcolor=color.new(color.navy, 30))
    table.cell(legend, 1, 0, "Heatmap", text_color=color.new(color.white, 40),
               text_size=size.tiny,  bgcolor=color.new(color.navy, 30))
    table.cell(legend, 0, 1, "●", text_color=f_heat_color(90, 0), text_size=size.normal)
    table.cell(legend, 1, 1, "Alta Prob. >80%",  text_color=color.white, text_size=size.tiny)
    table.cell(legend, 0, 2, "●", text_color=f_heat_color(60, 0), text_size=size.normal)
    table.cell(legend, 1, 2, "Media  50-80%",    text_color=color.white, text_size=size.tiny)
    table.cell(legend, 0, 3, "●", text_color=f_heat_color(25, 0), text_size=size.normal)
    table.cell(legend, 1, 3, "Baja   <50%",      text_color=color.white, text_size=size.tiny)
    table.cell(legend, 0, 4, "■", text_color=color.new(color.teal,   30), text_size=size.normal)
    table.cell(legend, 1, 4, "FVG Alcista",      text_color=color.white, text_size=size.tiny)
    table.cell(legend, 0, 5, "■", text_color=color.new(color.orange, 30), text_size=size.normal)
    table.cell(legend, 1, 5, "FVG Bajista",      text_color=color.white, text_size=size.tiny)
    table.cell(legend, 0, 6, "...", text_color=color.white, text_size=size.small)
    table.cell(legend, 1, 6, "Liquidez EQH/EQL", text_color=color.white, text_size=size.tiny)
    table.cell(legend, 0, 7, "□", text_color=color.new(color.orange, 40), text_size=size.normal)
    table.cell(legend, 1, 7, "Premium",           text_color=color.white, text_size=size.tiny)
    table.cell(legend, 0, 8, "□", text_color=color.new(color.teal,   40), text_size=size.normal)
    table.cell(legend, 1, 8, "Discount",          text_color=color.white, text_size=size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// ALERTAS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(is_bull_impulse, "Impulso Alcista", "SM·LH: Posible Bullish OB formado")
alertcondition(is_bear_impulse, "Impulso Bajista", "SM·LH: Posible Bearish OB formado")
alertcondition(bullish_choch,   "CHoCH Alcista",   "SM·LH: Change of Character alcista")
alertcondition(bearish_choch,   "CHoCH Bajista",   "SM·LH: Change of Character bajista")
````

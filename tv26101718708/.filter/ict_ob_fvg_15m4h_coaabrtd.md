# ICT, OB & FVG  15m-4H

- url: https://www.tradingview.com/script/COAaBRtd/
- type: indicator
- pine_id: PUB;7e7b453654cb47f39f6925c349dd47c8
- version: 2.0

## Description

Title:
ICT OB + FVG Multi-Timeframe (15m and 4H)

Description:
This indicator is designed for ICT-style price delivery analysis, automatically plotting Order Blocks (OB) and Fair Value Gaps (FVG) from the 15-minute and 4-hour timeframes on your chart.

It is built to help you identify high-probability reaction zones, track gap structure, and monitor mitigation behavior in a visual and structured way.

What this indicator does:

Detects bullish and bearish FVGs on 15m and 4H
Detects bullish and bearish OBs on 15m and 4H
Draws OB zones using candle body only (open/close), ignoring wicks
Draws FVG internal levels:
0.5 (green)
0.618 (red)
0.705 (red)
0.79 (yellow)
Displays live price labels for each FVG level
Adds timeframe tag (15m or 4H) on each FVG
Keeps FVG boundaries fixed once created
Removes FVG only when a confirmed close on its own timeframe fully mitigates the gap
Supports real-time intrabar 15m FVG detection when using lower chart timeframes (for example 1m/5m)
Uses separate active limits for 15m OBs and 4H OBs to avoid one timeframe deleting the other
How mitigation works:

OB mitigation:
Bullish OB is mitigated when close breaks below the OB body
Bearish OB is mitigated when close breaks above the OB body
FVG mitigation:
FVG remains valid until a confirmed candle close on the same source timeframe closes beyond the full gap boundary
Inputs:

Show/hide OB 15m and OB 4H
Show/hide FVG 15m and FVG 4H
Custom colors for OB and FVG zones
Maximum active FVGs
Maximum active OBs for 15m
Maximum active OBs for 4H
OB and FVG mitigation toggles
Best use:

Intraday and swing structure mapping
Liquidity and rebalance targeting
Confluence-based execution planning with ICT concepts
Disclaimer:
This tool is for technical analysis and educational purposes only. It does not provide financial advice or trade signals. Always use your own risk management and confirmation process.

## Source Code

````pine
/// ═══════════════════════════════════════════════════════════════════════════════
//  ICT — Order Blocks & Fair Value Gaps  [15m · 4H]
//  Marca automáticamente OBs y FVGs en 15 minutos y 4 horas.
//  Cada zona muestra:
//    • OB  → línea MT  (Mean Threshold = punto medio del Order Block)
//    • FVG → línea CE  (Consequent Encroachment = punto medio del FVG)
//  Mitigación automática opcional.
// ═══════════════════════════════════════════════════════════════════════════════
//@version=6
indicator("ICT — OB & FVG  [15m · 4H]", overlay=true,
          max_boxes_count=200, max_lines_count=400, max_labels_count=200)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────────
G_OB  = "Order Blocks"
G_FVG = "Fair Value Gaps"
G_CFG = "Configuración"

show_ob_15  = input.bool(true, "OB 15min", group=G_OB)
show_ob_4h  = input.bool(true, "OB 4H",    group=G_OB)
c_bull_ob   = input.color(color.new(#00c87a, 80), "Alcista", inline="ocol", group=G_OB)
c_bear_ob   = input.color(color.new(#e03030, 80), "Bajista", inline="ocol", group=G_OB)
c_mt        = input.color(#f5c518, "Línea MT", group=G_OB)

show_fvg_15 = input.bool(true, "FVG 15min", group=G_FVG)
show_fvg_4h = input.bool(true, "FVG 4H",    group=G_FVG)
c_bull_fvg  = input.color(color.new(#4cc9f0, 84), "Alcista", inline="fcol", group=G_FVG)
c_bear_fvg  = input.color(color.new(#ff9f1c, 84), "Bajista", inline="fcol", group=G_FVG)
c_ce        = input.color(#e0e0e0, "Línea CE", group=G_FVG)
c_fib_50    = color.lime
c_fib_618   = color.white
c_fib_705   = color.yellow
c_fib_79    = color.red

max_fvg = input.int(5, "Máx FVGs activos", minval=1, maxval=20, group=G_CFG)
max_ob_15 = input.int(3, "Máx OBs 15m activos", minval=1, maxval=20, group=G_CFG)
max_ob_4h = input.int(3, "Máx OBs 4H activos",  minval=1, maxval=20, group=G_CFG)
mit_ob  = input.bool(true, "Borrar OB cuando se mitiga (close fuera del bloque)", group=G_CFG)
mit_fvg = input.bool(true, "Borrar FVG al tocar CE",                              group=G_CFG)

// ─────────────────────────────────────────────────────────────────────────────
//  DATOS MTF — últimas 3 velas cerradas de cada timeframe
//  En PineScript v6 request.security requiere una función que devuelva la tupla
//  [0] = vela más reciente completada  [1] = anterior  [2] = dos atrás
// ─────────────────────────────────────────────────────────────────────────────
// Cada asignación MTF debe estar en una sola línea (Pine Script no admite
// romper asignaciones de tupla en múltiples líneas)
[h0_15, l0_15, o1_15, h1_15, l1_15, c1_15, o2_15, h2_15, l2_15, c2_15] = request.security(syminfo.tickerid, "15",  [high, low, open[1], high[1], low[1], close[1], open[2], high[2], low[2], close[2]], lookahead=barmerge.lookahead_off)
[h0_4h, l0_4h, o1_4h, h1_4h, l1_4h, c1_4h, o2_4h, h2_4h, l2_4h, c2_4h] = request.security(syminfo.tickerid, "240", [high, low, open[1], high[1], low[1], close[1], open[2], high[2], low[2], close[2]], lookahead=barmerge.lookahead_off)
close_15_cf = request.security(syminfo.tickerid, "15", close, lookahead=barmerge.lookahead_off)
close_4h_cf = request.security(syminfo.tickerid, "240", close, lookahead=barmerge.lookahead_off)

// Datos HTF en tiempo real (vela en formación) para marcar FVG 15m intrabar.
[l0_15_rt, h2_15_rt, l2_15_rt, h0_15_rt, t0_15_rt] = request.security(syminfo.tickerid, "15", [low, high[2], low[2], high, time], lookahead=barmerge.lookahead_on)
t0_15_cf = request.security(syminfo.tickerid, "15", time, lookahead=barmerge.lookahead_off)

// Señal: nueva vela confirmada en cada TF
new_15 = timeframe.change("15")
new_4h = timeframe.change("240")

// ─────────────────────────────────────────────────────────────────────────────
//  ARRAYS — almacena objetos activos en pantalla
// ─────────────────────────────────────────────────────────────────────────────
var box[]   ob_bx  = array.new<box>()
var line[]  ob_ln  = array.new<line>()
var label[] ob_lb  = array.new<label>()
var float[] ob_mid = array.new<float>()
var bool[]  ob_bul = array.new<bool>()
var string[] ob_tf = array.new<string>()

var box[]   fv_bx  = array.new<box>()
var float[] fv_mid = array.new<float>()
var bool[]  fv_bul = array.new<bool>()
var line[]  fv_ln_50  = array.new<line>()
var line[]  fv_ln_618 = array.new<line>()
var line[]  fv_ln_705 = array.new<line>()
var line[]  fv_ln_79  = array.new<line>()
var label[] fv_lb_50  = array.new<label>()
var label[] fv_lb_618 = array.new<label>()
var label[] fv_lb_705 = array.new<label>()
var label[] fv_lb_79  = array.new<label>()
var label[] fv_lb_tf  = array.new<label>()
var string[] fv_tf    = array.new<string>()

// Evita duplicar el mismo FVG 15m en la misma vela HTF (confirmado o intrabar)
var int last_fvg15_bull_time = na
var int last_fvg15_bear_time = na

// ─────────────────────────────────────────────────────────────────────────────
//  FUNCIONES — crear y actualizar zonas
// ─────────────────────────────────────────────────────────────────────────────

// Añade un FVG nuevo al array. Elimina el más antiguo si supera el máximo.
f_add_fvg(float top, float bot, bool is_bull, string tf_lbl) =>
    baseBg = is_bull ? c_bull_fvg : c_bear_fvg
    bg  = tf_lbl == "4H" ? color.new(baseBg, 68) : baseBg
    mid = math.avg(top, bot)
    rng = top - bot
    tfOff = math.max(rng * 0.12, syminfo.mintick * 10)
    // Bullish FVG: retrocesos en la parte baja. Bearish FVG: en la parte alta.
    lvl50  = is_bull ? top - rng * 0.5   : bot + rng * 0.5
    lvl618 = is_bull ? top - rng * 0.62 : bot + rng * 0.62
    lvl705 = is_bull ? top - rng * 0.705 : bot + rng * 0.705
    lvl79  = is_bull ? top - rng * 0.79  : bot + rng * 0.79
    b   = box.new(bar_index, top, bar_index + 1, bot,
                  bgcolor=bg, border_color=color.new(bg, 100), border_width=0)
    l50  = line.new(bar_index, lvl50,  bar_index + 1, lvl50,  color=c_fib_50,  style=line.style_dashed, width=2)
    l618 = line.new(bar_index, lvl618, bar_index + 1, lvl618, color=c_fib_618, style=line.style_dotted, width=1)
    l705 = line.new(bar_index, lvl705, bar_index + 1, lvl705, color=c_fib_705, style=line.style_dotted, width=1)
    l79  = line.new(bar_index, lvl79,  bar_index + 1, lvl79,  color=c_fib_79,  style=line.style_dotted, width=1)
    lb50  = label.new(bar_index + 1, lvl50,
                     "FVG " + tf_lbl + " 0.5  " + str.tostring(lvl50, format.mintick),
                     style=label.style_label_left, color=color.new(color.black, 100), textcolor=c_fib_50, size=size.small)
    lb618 = label.new(bar_index + 1, lvl618,
                     "FVG " + tf_lbl + " 0.62 " + str.tostring(lvl618, format.mintick),
                     style=label.style_label_left, color=color.new(color.black, 100), textcolor=c_fib_618, size=size.small)
    lb705 = label.new(bar_index + 1, lvl705,
                     "FVG " + tf_lbl + " 0.705 " + str.tostring(lvl705, format.mintick),
                     style=label.style_label_left, color=color.new(color.black, 100), textcolor=c_fib_705, size=size.small)
    lb79  = label.new(bar_index + 1, lvl79,
                     "FVG " + tf_lbl + " 0.79  " + str.tostring(lvl79, format.mintick),
                     style=label.style_label_left, color=color.new(color.black, 100), textcolor=c_fib_79, size=size.small)
    tfY = is_bull ? (lvl50 + tfOff) : (lvl50 - tfOff)
    lb_tf = label.new(bar_index - 4, tfY,
                     tf_lbl,
                     style=label.style_label_left, color=color.new(color.black, 100), textcolor=c_ce, size=size.small)
    array.push(fv_bx,  b)
    array.push(fv_mid, mid)
    array.push(fv_bul, is_bull)
    array.push(fv_ln_50,  l50)
    array.push(fv_ln_618, l618)
    array.push(fv_ln_705, l705)
    array.push(fv_ln_79,  l79)
    array.push(fv_lb_50,  lb50)
    array.push(fv_lb_618, lb618)
    array.push(fv_lb_705, lb705)
    array.push(fv_lb_79,  lb79)
    array.push(fv_lb_tf,  lb_tf)
    array.push(fv_tf,     tf_lbl)
    if array.size(fv_bx) > max_fvg
        box.delete(array.shift(fv_bx))
        array.shift(fv_mid)
        array.shift(fv_bul)
        line.delete(array.shift(fv_ln_50))
        line.delete(array.shift(fv_ln_618))
        line.delete(array.shift(fv_ln_705))
        line.delete(array.shift(fv_ln_79))
        label.delete(array.shift(fv_lb_50))
        label.delete(array.shift(fv_lb_618))
        label.delete(array.shift(fv_lb_705))
        label.delete(array.shift(fv_lb_79))
        label.delete(array.shift(fv_lb_tf))
        array.shift(fv_tf)

// Añade un Order Block nuevo al array.
f_remove_ob_at(int idx) =>
    box.delete(array.get(ob_bx, idx))
    line.delete(array.get(ob_ln, idx))
    label.delete(array.get(ob_lb, idx))
    array.remove(ob_bx, idx)
    array.remove(ob_ln, idx)
    array.remove(ob_lb, idx)
    array.remove(ob_mid, idx)
    array.remove(ob_bul, idx)
    array.remove(ob_tf, idx)

f_count_ob_tf(string tf_lbl) =>
    cnt = 0
    for i = 0 to array.size(ob_tf) - 1
        if array.get(ob_tf, i) == tf_lbl
            cnt += 1
    cnt

f_limit_ob_tf(string tf_lbl) =>
    tf_lbl == "4H" ? max_ob_4h : max_ob_15

f_prune_ob_tf(string tf_lbl) =>
    limit = f_limit_ob_tf(tf_lbl)
    while f_count_ob_tf(tf_lbl) > limit
        rm_idx = -1
        for i = 0 to array.size(ob_tf) - 1
            if rm_idx == -1 and array.get(ob_tf, i) == tf_lbl
                rm_idx := i
        if rm_idx >= 0
            f_remove_ob_at(rm_idx)
        else
            break
        0

f_add_ob(float top, float bot, bool is_bull, string tf_lbl) =>
    bg  = is_bull ? c_bull_ob : c_bear_ob
    mid = math.avg(top, bot)
    b   = box.new(bar_index, top, bar_index + 1, bot,
                  bgcolor=bg, border_color=color.new(bg, 100), border_width=0)
    l   = line.new(bar_index, mid, bar_index + 1, mid,
                   color=c_mt, style=line.style_dashed, width=1)
    lbl = label.new(bar_index + 1, mid,
                    (is_bull ? "OB ▲  " : "OB ▼  ") + tf_lbl,
                    style=label.style_label_left,
                    color=color.new(color.black, 100),
                    textcolor=c_mt, size=size.tiny)
    array.push(ob_bx,  b)
    array.push(ob_ln,  l)
    array.push(ob_lb,  lbl)
    array.push(ob_mid, mid)
    array.push(ob_bul, is_bull)
    array.push(ob_tf, tf_lbl)
    f_prune_ob_tf(tf_lbl)

// Extiende los FVGs activos al bar presente y elimina los mitigados.
// Mitigan cuando el precio toca el CE.
f_update_fvg() =>
    i = 0
    while i < array.size(fv_bx)
        b    = array.get(fv_bx,  i)
        l50  = array.get(fv_ln_50,  i)
        l618 = array.get(fv_ln_618, i)
        l705 = array.get(fv_ln_705, i)
        l79  = array.get(fv_ln_79,  i)
        lb50  = array.get(fv_lb_50,  i)
        lb618 = array.get(fv_lb_618, i)
        lb705 = array.get(fv_lb_705, i)
        lb79  = array.get(fv_lb_79,  i)
        lbtf  = array.get(fv_lb_tf,  i)
        tf_lbl = array.get(fv_tf, i)
        bull = array.get(fv_bul, i)

        top = box.get_top(b)
        bot = box.get_bottom(b)
        mid = math.avg(top, bot)
        array.set(fv_mid, i, mid)

        rng = top - bot
        tfOff = math.max(rng * 0.12, syminfo.mintick * 10)
        lvl50  = bull ? top - rng * 0.5   : bot + rng * 0.5
        lvl618 = bull ? top - rng * 0.62 : bot + rng * 0.62
        lvl705 = bull ? top - rng * 0.705 : bot + rng * 0.705
        lvl79  = bull ? top - rng * 0.79  : bot + rng * 0.79

        box.set_right(b, bar_index + 1)
        line.set_y1(l50,  lvl50)
        line.set_y2(l50,  lvl50)
        line.set_y1(l618, lvl618)
        line.set_y2(l618, lvl618)
        line.set_y1(l705, lvl705)
        line.set_y2(l705, lvl705)
        line.set_y1(l79,  lvl79)
        line.set_y2(l79,  lvl79)
        line.set_x2(l50,  bar_index + 1)
        line.set_x2(l618, bar_index + 1)
        line.set_x2(l705, bar_index + 1)
        line.set_x2(l79,  bar_index + 1)
        label.set_y(lb50,  lvl50)
        label.set_y(lb618, lvl618)
        label.set_y(lb705, lvl705)
        label.set_y(lb79,  lvl79)
        label.set_x(lb50,  bar_index + 1)
        label.set_x(lb618, bar_index + 1)
        label.set_x(lb705, bar_index + 1)
        label.set_x(lb79,  bar_index + 1)
        label.set_x(lbtf,  bar_index - 4)
        tfY = bull ? (lvl50 + tfOff) : (lvl50 - tfOff)
        label.set_y(lbtf,  tfY)
        label.set_text(lb50,  "FVG 0.5  " + str.tostring(lvl50, format.mintick))
        label.set_text(lb618, "FVG 0.62 " + str.tostring(lvl618, format.mintick))
        label.set_text(lb705, "FVG 0.705 " + str.tostring(lvl705, format.mintick))
        label.set_text(lb79,  "FVG 0.79  " + str.tostring(lvl79, format.mintick))

        // Mitigación: solo con cierre confirmado de su propia temporalidad
        can_mitigate = tf_lbl == "4H" ? new_4h : new_15
        tf_close = tf_lbl == "4H" ? close_4h_cf : close_15_cf
        mitigated = can_mitigate and (bull ? tf_close <= bot : tf_close >= top)
        if mitigated
            box.delete(b)
            line.delete(l50)
            line.delete(l618)
            line.delete(l705)
            line.delete(l79)
            label.delete(lb50)
            label.delete(lb618)
            label.delete(lb705)
            label.delete(lb79)
            label.delete(lbtf)
            array.remove(fv_bx,  i)
            array.remove(fv_mid, i)
            array.remove(fv_bul, i)
            array.remove(fv_ln_50,  i)
            array.remove(fv_ln_618, i)
            array.remove(fv_ln_705, i)
            array.remove(fv_ln_79,  i)
            array.remove(fv_lb_50,  i)
            array.remove(fv_lb_618, i)
            array.remove(fv_lb_705, i)
            array.remove(fv_lb_79,  i)
            array.remove(fv_lb_tf,  i)
            array.remove(fv_tf,     i)
            i
        else
            i += 1

// Extiende los OBs activos y elimina los mitigados.
// OB alcista mitiga cuando el cierre cae por debajo del suelo del bloque.
// OB bajista mitiga cuando el cierre sube por encima del techo del bloque.
f_update_ob() =>
    i = 0
    while i < array.size(ob_bx)
        b    = array.get(ob_bx,  i)
        l    = array.get(ob_ln,  i)
        lb   = array.get(ob_lb,  i)
        bull = array.get(ob_bul, i)
        top  = box.get_top(b)
        bot  = box.get_bottom(b)
        box.set_right(b, bar_index + 1)
        line.set_x2(l, bar_index + 1)
        label.set_x(lb, bar_index + 1)
        mitigated = mit_ob and (bull ? close < bot : close > top)
        if mitigated
            f_remove_ob_at(i)
            i
        else
            i += 1

// ─────────────────────────────────────────────────────────────────────────────
//  DETECCIÓN FVG — patrón de 3 velas
//
//  FVG Alcista: high[2] < low[0]  →  hueco entre la vela antigua y la nueva
//  FVG Bajista: low[2]  > high[0] →  hueco inverso
//
//  Zona:
//    Top  = low[0]   /  low[2]
//    Bot  = high[2]  /  high[0]
//    CE   = (Top + Bot) / 2
// ─────────────────────────────────────────────────────────────────────────────
if new_15
    if show_fvg_15 and h2_15 < l0_15       // FVG alcista 15m
        if na(last_fvg15_bull_time) or t0_15_cf != last_fvg15_bull_time
            f_add_fvg(l0_15, h2_15, true, "15m")
            last_fvg15_bull_time := t0_15_cf
    if show_fvg_15 and l2_15 > h0_15       // FVG bajista 15m
        if na(last_fvg15_bear_time) or t0_15_cf != last_fvg15_bear_time
            f_add_fvg(l2_15, h0_15, false, "15m")
            last_fvg15_bear_time := t0_15_cf

// Detección intrabar para ver FVG 15m en tiempo real al usar 1m/5m.
if barstate.isrealtime and timeframe.in_seconds() < timeframe.in_seconds("15")
    if show_fvg_15 and h2_15_rt < l0_15_rt
        if na(last_fvg15_bull_time) or t0_15_rt != last_fvg15_bull_time
            f_add_fvg(l0_15_rt, h2_15_rt, true, "15m")
            last_fvg15_bull_time := t0_15_rt
    if show_fvg_15 and l2_15_rt > h0_15_rt
        if na(last_fvg15_bear_time) or t0_15_rt != last_fvg15_bear_time
            f_add_fvg(l2_15_rt, h0_15_rt, false, "15m")
            last_fvg15_bear_time := t0_15_rt

if new_4h
    if show_fvg_4h and h2_4h < l0_4h       // FVG alcista 4H
        f_add_fvg(l0_4h, h2_4h, true, "4H")
    if show_fvg_4h and l2_4h > h0_4h       // FVG bajista 4H
        f_add_fvg(l2_4h, h0_4h, false, "4H")

// ─────────────────────────────────────────────────────────────────────────────
//  DETECCIÓN ORDER BLOCK
//
//  El OB se confirma con el desplazamiento que crea el FVG.
//
//  Lógica:
//    FVG alcista detectado → busca la última vela BAJISTA antes del impulso
//      → primero revisa vela[1]; si es alcista revisa vela[2]
//    FVG bajista detectado → busca la última vela ALCISTA antes del impulso
//      → primero revisa vela[1]; si es bajista revisa vela[2]
//
//  Zona:
//    Top = high de la vela OB
//    Bot = low  de la vela OB
//    MT  = (Top + Bot) / 2   ← nivel de entrada preferido en la estrategia
// ─────────────────────────────────────────────────────────────────────────────
if new_15
    // FVG alcista → OB bajista (bull OB para ir largo)
    if show_ob_15 and h2_15 < l0_15
        if c1_15 < o1_15                    // vela[1] es roja → es el OB
            f_add_ob(math.max(o1_15, c1_15), math.min(o1_15, c1_15), true, "15m")
        else if c2_15 < o2_15               // vela[2] es roja → fallback OB
            f_add_ob(math.max(o2_15, c2_15), math.min(o2_15, c2_15), true, "15m")

    // FVG bajista → OB alcista (bear OB para ir corto)
    if show_ob_15 and l2_15 > h0_15
        if c1_15 > o1_15                    // vela[1] es verde → es el OB
            f_add_ob(math.max(o1_15, c1_15), math.min(o1_15, c1_15), false, "15m")
        else if c2_15 > o2_15               // vela[2] es verde → fallback OB
            f_add_ob(math.max(o2_15, c2_15), math.min(o2_15, c2_15), false, "15m")

if new_4h
    // FVG alcista 4H
    if show_ob_4h and h2_4h < l0_4h
        if c1_4h < o1_4h
            f_add_ob(math.max(o1_4h, c1_4h), math.min(o1_4h, c1_4h), true, "4H")
        else if c2_4h < o2_4h
            f_add_ob(math.max(o2_4h, c2_4h), math.min(o2_4h, c2_4h), true, "4H")

    // FVG bajista 4H
    if show_ob_4h and l2_4h > h0_4h
        if c1_4h > o1_4h
            f_add_ob(math.max(o1_4h, c1_4h), math.min(o1_4h, c1_4h), false, "4H")
        else if c2_4h > o2_4h
            f_add_ob(math.max(o2_4h, c2_4h), math.min(o2_4h, c2_4h), false, "4H")

// ─────────────────────────────────────────────────────────────────────────────
//  UPDATE — cada barra extiende y verifica mitigación
// ─────────────────────────────────────────────────────────────────────────────
f_update_fvg()
f_update_ob()




// =====================
// Manual checklist controls
// =====================
checkGroup = "Checklist"
has15mOBFVG = input.bool(false, "OB y FVG de 15min", group=checkGroup)
hasWickPassRetreat = input.bool(false, "Wick que pasa y retrocede", group=checkGroup)
wickOver10Pts = input.bool(false, "Wick supera +10 puntos", group=checkGroup)

riskGroup = "Risk"
slPts = input.float(15.0, "Stop Loss points", minval=0.25, step=0.25, group=riskGroup)
tp1Pts = input.float(45.0, "TP1 points", minval=0.25, step=0.25, group=riskGroup)
tp2Pts = input.float(75.0, "TP2 points", minval=0.25, step=0.25, group=riskGroup)

visGroup = "Visual"
showChecklist = input.bool(true, "Show checklist table", group=visGroup)

// =====================
// Checklist table only
// =====================
var table ckTable = table.new(position.top_right, 1, 8, border_width=1)

if barstate.islast and showChecklist
	riskMultipleTp1 = slPts > 0 ? tp1Pts / slPts : na
	riskMultipleTp2 = slPts > 0 ? tp2Pts / slPts : na
	useFib62 = wickOver10Pts
	useFib50 = not wickOver10Pts

	table.cell(ckTable, 0, 0, "SOLO EL PUTO SISTEMA", bgcolor=color.new(color.black, 0), text_color=color.white)
	
else if barstate.islast and not showChecklist
	table.clear(ckTable, 0, 0, 0, 7)
````

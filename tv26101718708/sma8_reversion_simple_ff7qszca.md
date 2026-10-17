# SMA8 Reversion Simple

- url: https://www.tradingview.com/script/ff7qSzca/
- type: indicator
- pine_id: PUB;daef3a1b3b7245f5946daf46bfabb56e
- version: 1.0

## Description

SMA8 Reversion Simple
This indicator measures the probability that price will return to the 8-period Simple Moving Average (SMA8) after a significant deviation, using only the historical data of the asset itself as a statistical base.
How it works
Every time price moves away from the SMA8 beyond a configurable threshold, the indicator registers the event and tracks whether price returns to the SMA within a maximum number of candles. Over time, it builds a historical database of these events grouped by two dimensions:

Distance level — how far price is from the SMA (4 ranges)
Time elapsed — how many candles price has been away (3 ranges: early, mid, late)

The combination of both dimensions produces a 4×3 matrix of 12 independent cells, each with its own historical return rate.
Signal classification
Based on the historical effectiveness of the current cell, the indicator classifies the signal in real time:

🔴 Weak — less than 40% of similar events returned to SMA. Avoid.
🟠 Neutral — 40–60%. Only trade with additional confirmation.
🟢 Good — 60–75%. Valid setup with solid historical backing.
🔵 Very Strong — above 75%. High priority reversal opportunity.

What the table shows

Current deviation in % and points
Number of candles price has been outside the SMA
Historical effectiveness % for the current situation
Global backtest stats (events, returns, success rate)
⭐ Best zone — the distance + time combination with the highest historical return rate for this specific asset

Key features

Zero repaint — all statistics are calculated on confirmed historical bars only
Works on any asset and any timeframe
Fully configurable: SMA period, deviation threshold, max candles for return, backtest range
Alerts included for strong signals and SMA crosses

## Source Code

````pine
// ╔══════════════════════════════════════════════════════════════════════════╗
// ║   SMA8 REVERSION SIMPLE — Pine Script v5                               ║
// ║   Combina alejamiento % + velas transcurridas en una señal única        ║
// ║   basada 100% en backtesting histórico del propio activo                ║
// ╚══════════════════════════════════════════════════════════════════════════╝
//@version=5
indicator("SMA8 Reversion Simple", shorttitle="SMA8•S", overlay=true, max_bars_back=5000, max_labels_count=300)

// ══════════════════════════════════════════════════════════════════════════
// SECCIÓN 1 — INPUTS
// ══════════════════════════════════════════════════════════════════════════

grp1 = "📐 Configuración base"
sma_len         = input.int(8,    "Período SMA",           minval=1, maxval=200, group=grp1)
src             = input.source(close, "Fuente",                                  group=grp1)
threshold_pct   = input.float(1.0,"Umbral mínimo %",       minval=0.01, step=0.1,group=grp1)

grp2 = "🔬 Backtesting"
bt_days         = input.int(180,  "Días de historial",     minval=30,             group=grp2)
max_bars_ret    = input.int(20,   "Velas máx. para retorno", minval=1, maxval=100, group=grp2)

grp3 = "🎨 Visual"
show_sma        = input.bool(true, "Mostrar SMA8",                               group=grp3)
show_labels     = input.bool(true, "Mostrar marcas en eventos",                  group=grp3)
tbl_pos_str     = input.string("Arriba Derecha", "Posición tabla",
                  options=["Arriba Derecha","Arriba Izquierda","Abajo Derecha","Abajo Izquierda"], group=grp3)

// ══════════════════════════════════════════════════════════════════════════
// SECCIÓN 2 — CÁLCULO BASE
// ══════════════════════════════════════════════════════════════════════════

sma8        = ta.sma(src, sma_len)
dist_pct    = sma8 != 0 ? (src - sma8) / sma8 * 100 : 0.0
dist_abs    = math.abs(dist_pct)
dist_pts    = src - sma8
direction   = src >= sma8 ? 1 : -1

// Rango de backtesting basado en tiempo real (no en número fijo de barras)
bt_start_time = timestamp(year(timenow), month(timenow), dayofmonth(timenow), 0, 0) - bt_days * 86400000
in_bt_range   = time >= bt_start_time

// ══════════════════════════════════════════════════════════════════════════
// SECCIÓN 3 — BUCKETS DE DISTANCIA Y TIEMPO
// ══════════════════════════════════════════════════════════════════════════
//
// Dividimos el espacio en:
//   4 rangos de alejamiento (D1..D4)
//   3 rangos de tiempo / velas transcurridas (T1=temprano, T2=medio, T3=tardío)
//
// Resultado: 12 celdas de la matriz D×T, cada una con su propio
// contador de eventos y éxitos → efectividad independiente.

// Límites de distancia (configurables implícitamente por threshold_pct)
// D1: threshold → 2×threshold
// D2: 2× → 4×
// D3: 4× → 7×
// D4: >7×
d_lim1 = threshold_pct * 2
d_lim2 = threshold_pct * 4
d_lim3 = threshold_pct * 7

// Límites de tiempo (en velas desde inicio del evento)
// T1: velas 1 – tercio del máximo
// T2: tercio – dos tercios
// T3: dos tercios – máximo
t_lim1 = math.round(max_bars_ret / 3)
t_lim2 = math.round(max_bars_ret * 2 / 3)

// Función: bucket de distancia (1-4)
f_dbkt(pct_abs) =>
    pct_abs < d_lim1 ? 1 : pct_abs < d_lim2 ? 2 : pct_abs < d_lim3 ? 3 : 4

// Función: bucket de tiempo (1-3)
f_tbkt(bars_elapsed) =>
    bars_elapsed <= t_lim1 ? 1 : bars_elapsed <= t_lim2 ? 2 : 3

// ══════════════════════════════════════════════════════════════════════════
// SECCIÓN 4 — CONTADORES MATRIZ 4×3
// ══════════════════════════════════════════════════════════════════════════
// Nombres: ev_DxTy = eventos, ok_DxTy = retornos exitosos

var int ev_d1t1 = 0
var int ok_d1t1 = 0
var int ev_d1t2 = 0
var int ok_d1t2 = 0
var int ev_d1t3 = 0
var int ok_d1t3 = 0
var int ev_d2t1 = 0
var int ok_d2t1 = 0
var int ev_d2t2 = 0
var int ok_d2t2 = 0
var int ev_d2t3 = 0
var int ok_d2t3 = 0
var int ev_d3t1 = 0
var int ok_d3t1 = 0
var int ev_d3t2 = 0
var int ok_d3t2 = 0
var int ev_d3t3 = 0
var int ok_d3t3 = 0
var int ev_d4t1 = 0
var int ok_d4t1 = 0
var int ev_d4t2 = 0
var int ok_d4t2 = 0
var int ev_d4t3 = 0
var int ok_d4t3 = 0

// Totales globales
var int total_ev = 0
var int total_ok = 0

// ── Estado del evento en curso ────────────────────────────────────────────
var bool  in_event    = false
var int   ev_dir      = 0
var float ev_dist_ini = 0.0
var int   ev_bars     = 0
var int   ev_cooldown = 0

// ══════════════════════════════════════════════════════════════════════════
// SECCIÓN 5 — MÁQUINA DE ESTADOS (sin repintado)
// ══════════════════════════════════════════════════════════════════════════

if in_bt_range and not barstate.islast

    if not in_event
        if dist_abs >= threshold_pct
            in_event    := true
            ev_dir      := direction
            ev_dist_ini := dist_pct
            ev_bars     := 0
            ev_cooldown := max_bars_ret
            total_ev    += 1
            // Registrar evento en la celda correcta (d × t)
            _d = f_dbkt(dist_abs)
            _t = f_tbkt(0)
            if _d == 1
                if _t == 1
                    ev_d1t1 += 1
                else if _t == 2
                    ev_d1t2 += 1
                else
                    ev_d1t3 += 1
            else if _d == 2
                if _t == 1
                    ev_d2t1 += 1
                else if _t == 2
                    ev_d2t2 += 1
                else
                    ev_d2t3 += 1
            else if _d == 3
                if _t == 1
                    ev_d3t1 += 1
                else if _t == 2
                    ev_d3t2 += 1
                else
                    ev_d3t3 += 1
            else
                if _t == 1
                    ev_d4t1 += 1
                else if _t == 2
                    ev_d4t2 += 1
                else
                    ev_d4t3 += 1

    else
        if ev_cooldown > 0
            ev_bars  += 1
            returned  = ev_dir == 1 ? src <= sma8 : src >= sma8

            if returned
                total_ok += 1
                // Registrar éxito en la celda correcta
                _d = f_dbkt(math.abs(ev_dist_ini))
                _t = f_tbkt(ev_bars)
                if _d == 1
                    if _t == 1
                        ok_d1t1 += 1
                    else if _t == 2
                        ok_d1t2 += 1
                    else
                        ok_d1t3 += 1
                else if _d == 2
                    if _t == 1
                        ok_d2t1 += 1
                    else if _t == 2
                        ok_d2t2 += 1
                    else
                        ok_d2t3 += 1
                else if _d == 3
                    if _t == 1
                        ok_d3t1 += 1
                    else if _t == 2
                        ok_d3t2 += 1
                    else
                        ok_d3t3 += 1
                else
                    if _t == 1
                        ok_d4t1 += 1
                    else if _t == 2
                        ok_d4t2 += 1
                    else
                        ok_d4t3 += 1
                in_event    := false
                ev_cooldown := 0
            else
                ev_cooldown -= 1
                if ev_cooldown == 0
                    in_event := false

// ══════════════════════════════════════════════════════════════════════════
// SECCIÓN 6 — EFECTIVIDAD DE CADA CELDA
// ══════════════════════════════════════════════════════════════════════════

f_eff(ev, ok) => ev >= 3 ? ok / ev * 100.0 : -1.0

eff_d1t1 = f_eff(ev_d1t1, ok_d1t1)
eff_d1t2 = f_eff(ev_d1t2, ok_d1t2)
eff_d1t3 = f_eff(ev_d1t3, ok_d1t3)
eff_d2t1 = f_eff(ev_d2t1, ok_d2t1)
eff_d2t2 = f_eff(ev_d2t2, ok_d2t2)
eff_d2t3 = f_eff(ev_d2t3, ok_d2t3)
eff_d3t1 = f_eff(ev_d3t1, ok_d3t1)
eff_d3t2 = f_eff(ev_d3t2, ok_d3t2)
eff_d3t3 = f_eff(ev_d3t3, ok_d3t3)
eff_d4t1 = f_eff(ev_d4t1, ok_d4t1)
eff_d4t2 = f_eff(ev_d4t2, ok_d4t2)
eff_d4t3 = f_eff(ev_d4t3, ok_d4t3)

// ── Efectividad de la celda actual en tiempo real ─────────────────────────
curr_bars_elapsed = in_event ? max_bars_ret - ev_cooldown : 0
curr_dbkt = f_dbkt(dist_abs)
curr_tbkt = f_tbkt(curr_bars_elapsed)

curr_eff = curr_dbkt == 1 ? (curr_tbkt == 1 ? eff_d1t1 : curr_tbkt == 2 ? eff_d1t2 : eff_d1t3) : curr_dbkt == 2 ? (curr_tbkt == 1 ? eff_d2t1 : curr_tbkt == 2 ? eff_d2t2 : eff_d2t3) : curr_dbkt == 3 ? (curr_tbkt == 1 ? eff_d3t1 : curr_tbkt == 2 ? eff_d3t2 : eff_d3t3) : (curr_tbkt == 1 ? eff_d4t1 : curr_tbkt == 2 ? eff_d4t2 : eff_d4t3)

// ══════════════════════════════════════════════════════════════════════════
// SECCIÓN 7 — CLASIFICACIÓN DE SEÑAL
// ══════════════════════════════════════════════════════════════════════════

f_classify(eff) =>
    if eff < 0
        ["Sin datos", color.gray, "—"]
    else if eff < 40
        ["🔴 Débil",      color.new(color.red,    15), "No operar"]
    else if eff < 60
        ["🟠 Neutral",    color.new(color.orange,  15), "Con confirmación"]
    else if eff < 75
        ["🟢 Buena",      color.new(color.teal,   15), "Válido operar"]
    else
        ["🔵 Muy Fuerte", color.new(color.blue,   15), "Alta prioridad"]

is_active = dist_abs >= threshold_pct
[sig_label, sig_col, sig_hint] = f_classify(curr_eff)

// ── Mejor celda histórica ─────────────────────────────────────────────────
// Busca la celda con mayor efectividad (mínimo 5 eventos)
var float best_eff_found = -1.0
var int   best_d = 0
var int   best_t = 0

if barstate.islast
    best_eff_found := -1.0
    best_d         := 0
    best_t         := 0
    // Recorrer las 12 celdas y quedarse con la de mayor efectividad (≥5 eventos)
    _effs = array.from(ev_d1t1>=5?eff_d1t1:-1.0, ev_d1t2>=5?eff_d1t2:-1.0, ev_d1t3>=5?eff_d1t3:-1.0, ev_d2t1>=5?eff_d2t1:-1.0, ev_d2t2>=5?eff_d2t2:-1.0, ev_d2t3>=5?eff_d2t3:-1.0, ev_d3t1>=5?eff_d3t1:-1.0, ev_d3t2>=5?eff_d3t2:-1.0, ev_d3t3>=5?eff_d3t3:-1.0, ev_d4t1>=5?eff_d4t1:-1.0, ev_d4t2>=5?eff_d4t2:-1.0, ev_d4t3>=5?eff_d4t3:-1.0)
    _ds   = array.from(1,1,1,2,2,2,3,3,3,4,4,4)
    _ts   = array.from(1,2,3,1,2,3,1,2,3,1,2,3)
    for i = 0 to 11
        _e = array.get(_effs, i)
        if _e > best_eff_found
            best_eff_found := _e
            best_d         := array.get(_ds, i)
            best_t         := array.get(_ts, i)

best_d_txt = best_d == 1 ? str.tostring(threshold_pct,"#.#") + "–" + str.tostring(d_lim1,"#.#") + "%" : best_d == 2 ? str.tostring(d_lim1,"#.#") + "–" + str.tostring(d_lim2,"#.#") + "%" : best_d == 3 ? str.tostring(d_lim2,"#.#") + "–" + str.tostring(d_lim3,"#.#") + "%" : ">" + str.tostring(d_lim3,"#.#") + "%"
best_t_txt = best_t == 1 ? "velas 1–" + str.tostring(t_lim1) : best_t == 2 ? "velas " + str.tostring(t_lim1+1) + "–" + str.tostring(t_lim2) : "velas " + str.tostring(t_lim2+1) + "–" + str.tostring(max_bars_ret)

// ══════════════════════════════════════════════════════════════════════════
// SECCIÓN 8 — VISUALIZACIÓN
// ══════════════════════════════════════════════════════════════════════════

// ── SMA8 ──────────────────────────────────────────────────────────────────
plot(show_sma ? sma8 : na, "SMA8", color=color.new(color.yellow,0), linewidth=2)

// ── Colorear barras cuando hay señal activa ────────────────────────────────
barcolor(is_active ? sig_col : na, title="Señal activa")

// ── Labels en eventos nuevos ───────────────────────────────────────────────
is_new_event = dist_abs >= threshold_pct and not (dist_abs[1] >= threshold_pct) and in_bt_range and not barstate.islast

if show_labels and is_new_event
    [_lbl, _col, _hint] = f_classify(curr_eff)
    _txt = (direction == 1 ? "▲ " : "▼ ") + str.tostring(dist_abs, "#.##") + "%\n" + _lbl
    label.new(bar_index, direction == 1 ? high : low, _txt,
              style = direction == 1 ? label.style_label_down : label.style_label_up,
              color=_col, textcolor=color.white, size=size.small)

// ══════════════════════════════════════════════════════════════════════════
// SECCIÓN 9 — TABLA SIMPLIFICADA
// ══════════════════════════════════════════════════════════════════════════

tbl_pos = tbl_pos_str == "Arriba Derecha" ? position.top_right : tbl_pos_str == "Arriba Izquierda" ? position.top_left : tbl_pos_str == "Abajo Derecha" ? position.bottom_right : position.bottom_left

var table tbl = table.new(tbl_pos, 2, 9,
     bgcolor=color.new(color.black,15), border_width=1,
     border_color=color.new(color.gray,60), frame_width=1,
     frame_color=color.new(color.gray,40))

C_HDR  = color.new(#1a1a2e, 10)
C_R1   = color.new(color.black, 40)
C_R2   = color.new(color.black, 55)
C_TXT  = color.white
C_MUT  = color.new(color.gray, 20)
C_GRN  = color.new(color.teal, 20)
C_RED  = color.new(color.red,  20)

f_hdr(t, txt) =>
    table.cell(t, 0, 0, txt, bgcolor=C_HDR, text_color=color.yellow, text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(t, 0, 0, 1, 0)

f_row(t, row, lbl, val, bg, vc) =>
    table.cell(t, 0, row, lbl, bgcolor=bg, text_color=C_MUT,  text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, row, val, bgcolor=bg, text_color=vc,     text_size=size.small, text_halign=text.align_center)

if barstate.islast

    // Fila 0: título
    f_hdr(tbl, "⚡ SMA8 REVERSION")

    // ── Bloque 1: situación actual ─────────────────────────────────────────
    table.cell(tbl, 0, 1, "── AHORA ──", bgcolor=C_HDR, text_color=C_MUT, text_size=size.small, text_halign=text.align_center)
    table.merge_cells(tbl, 0, 1, 1, 1)

    dist_col = dist_pct >= 0 ? C_GRN : C_RED
    dist_sym = dist_pct >= 0 ? "▲ +" : "▼ "
    f_row(tbl, 2, "Alejamiento", dist_sym + str.tostring(dist_pct,"#.##") + "%  (" + str.tostring(dist_pts,"#.####") + " pts)", C_R1, dist_col)

    bars_txt = is_active ? str.tostring(curr_bars_elapsed) + " velas fuera de SMA" : "Dentro de zona normal"
    f_row(tbl, 3, "Tiempo", bars_txt, C_R2, C_TXT)

    eff_txt = curr_eff >= 0 ? str.tostring(curr_eff,"#.#") + "%" : "acumulando datos..."
    f_row(tbl, 4, "Ef. histórica", eff_txt, C_R1, curr_eff >= 75 ? color.new(color.blue,0) : curr_eff >= 60 ? C_GRN : curr_eff >= 40 ? color.new(color.orange,0) : curr_eff >= 0 ? C_RED : C_MUT)

    // ── Señal principal ────────────────────────────────────────────────────
    sig_txt = is_active ? sig_label + "  —  " + sig_hint : "— precio cerca de SMA —"
    sig_bg  = is_active ? sig_col : C_R2
    table.cell(tbl, 0, 5, sig_txt, bgcolor=sig_bg, text_color=C_TXT, text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(tbl, 0, 5, 1, 5)

    // ── Bloque 2: contexto histórico ───────────────────────────────────────
    table.cell(tbl, 0, 6, "── HISTORIAL ──", bgcolor=C_HDR, text_color=C_MUT, text_size=size.small, text_halign=text.align_center)
    table.merge_cells(tbl, 0, 6, 1, 6)

    eff_total = total_ev > 0 ? total_ok / total_ev * 100 : 0.0
    stats_txt = str.tostring(total_ok) + "/" + str.tostring(total_ev) + " eventos  (" + str.tostring(eff_total,"#.#") + "% global)"
    f_row(tbl, 7, "Retornos", stats_txt, C_R1, C_TXT)

    // ── Mejor zona ─────────────────────────────────────────────────────────
    best_txt = best_d > 0 ? best_d_txt + "  ·  " + best_t_txt + "  →  " + str.tostring(best_eff_found,"#.#") + "%" : "acumulando datos..."
    [_bl, best_zone_col, _bh] = f_classify(best_eff_found)
    f_row(tbl, 8, "⭐ Mejor zona", best_txt, C_R2, best_d > 0 ? best_zone_col : C_MUT)

// ══════════════════════════════════════════════════════════════════════════
// SECCIÓN 10 — ALERTAS
// ══════════════════════════════════════════════════════════════════════════

alertcondition(is_new_event and curr_eff >= 75, title="🔵 Señal Muy Fuerte", message="SMA8•S: Señal MUY FUERTE activa. Revisar tabla.")
alertcondition(is_new_event and curr_eff >= 60 and curr_eff < 75, title="🟢 Señal Buena", message="SMA8•S: Señal BUENA activa. Revisar tabla.")
alertcondition(is_new_event, title="⚠️ Evento detectado", message="SMA8•S: Nuevo alejamiento detectado. Revisar tabla.")
alertcondition(ta.cross(src, sma8), title="🔄 Cruce SMA8", message="SMA8•S: El precio cruzó la SMA8.")
````

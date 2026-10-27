# Liquidity Zones -1W, 1D and 4H

- url: https://www.tradingview.com/script/Yi9dnx0O/
- type: indicator
- pine_id: PUB;4831e58eee1247108a5aaf23ae82d8c0
- version: 2.0

## Description

Indicador para marcar os principais zonas de liquidez que são ímãs de preço

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════
//  Liquidity Zones  v3.1.0  (Pine Script v6)
//
//  Zonas ACIMA → vermelho  (Short / Resistência)
//  Zonas ABAIXO → verde    (Long / Suporte)
//
//  Features:
//    Multi-TF (30m, 1H, 4H, 12H, 1D, 2D, 3D, 1W) — 8 TFs configuráveis
//    Volume filter e merge com prioridade por TF
//    Invalidação de zonas varridas (sweep)
//    Detecção de Liquidity Grabs com alertas
//    Confluência natural: zonas próximas de TFs diferentes são fundidas
//
//  Tipo por TF (para prioridade de merge e visual):
//    30m=0  1H=1  4H=2  12H=3  1D=4  2D=5  3D=6  1W=7
//
//  Camadas ativas por TF do chart:
//    ≤ 30m → todos os 8 TFs disponíveis
//    ≤ 1H  → 1H, 4H, 12H, 1D, 2D, 3D, 1W
//    ≤ 4H  → 4H, 12H, 1D, 2D, 3D, 1W
//    ≤ 12H → 12H, 1D, 2D, 3D, 1W
//    ≤ 1D  → 1D, 2D, 3D, 1W
//    ≤ 2D  → 2D, 3D, 1W
//    ≤ 3D  → 3D, 1W
//    ≤ 1W  → 1W apenas
//    > 1W  → indicador sem utilidade
// ═══════════════════════════════════════════════════════════════

//@version=6
indicator("Liquidity Zones", overlay=true,
          max_boxes_count=500, max_labels_count=200,
          shorttitle="Liquidity Zones")

// ───────────────────────────────────────────────────────────────
//  INPUTS — Timeframes
// ───────────────────────────────────────────────────────────────
g_tf = "Timeframes"
show_30m = input.bool(false, "30 min",   group=g_tf,
                      tooltip="Zonas de liquidez baseadas em pivots de 30 minutos")
show_1h  = input.bool(false, "1 Hora",   group=g_tf,
                      tooltip="Zonas de liquidez baseadas em pivots de 1 hora")
show_4h  = input.bool(true,  "4 Horas",  group=g_tf,
                      tooltip="Zonas de liquidez baseadas em pivots de 4 horas")
show_12h = input.bool(false, "12 Horas", group=g_tf,
                      tooltip="Zonas de liquidez baseadas em pivots de 12 horas")
show_1d  = input.bool(true,  "1 Dia",    group=g_tf,
                      tooltip="Zonas de liquidez baseadas em pivots diários")
show_2d  = input.bool(false, "2 Dias",   group=g_tf,
                      tooltip="Zonas de liquidez baseadas em pivots de 2 dias")
show_3d  = input.bool(false, "3 Dias",   group=g_tf,
                      tooltip="Zonas de liquidez baseadas em pivots de 3 dias")
show_1w  = input.bool(true,  "1 Semana", group=g_tf,
                      tooltip="Zonas de liquidez baseadas em pivots semanais")

// ───────────────────────────────────────────────────────────────
//  INPUTS — Zonas
// ───────────────────────────────────────────────────────────────
g_z = "Zonas"
n_up   = input.int(6, "Máx. zonas acima",  minval=1, maxval=12, group=g_z)
n_dn   = input.int(6, "Máx. zonas abaixo", minval=1, maxval=12, group=g_z)
sw_len = input.int(5, "Pivot lookback (barras)", minval=3, maxval=15, group=g_z,
                   tooltip="Nº de barras de cada lado para confirmar um pivot high/low")
z_pct  = input.float(1.50, "Altura da zona (%)", minval=0.10, maxval=5.0,
                     step=0.10, group=g_z,
                     tooltip="Largura vertical da zona em % do nível central")

// ───────────────────────────────────────────────────────────────
//  INPUTS — Filtros de Volume
// ───────────────────────────────────────────────────────────────
g_v = "Filtros de Volume"
vm_intra = input.float(0.90, "Vol mín Intraday (30m, 1H)",
                       minval=0.10, maxval=8.0, step=0.10, group=g_v,
                       tooltip="Multiplicador × SMA de volume para filtrar pivots de 30m e 1H")
vm_swing = input.float(1.00, "Vol mín Swing (4H, 12H)",
                       minval=0.10, maxval=8.0, step=0.10, group=g_v,
                       tooltip="Multiplicador × SMA de volume para filtrar pivots de 4H e 12H")
vm_pos   = input.float(1.10, "Vol mín Position (1D, 2D, 3D, 1W)",
                       minval=0.10, maxval=8.0, step=0.10, group=g_v,
                       tooltip="Multiplicador × SMA de volume para filtrar pivots de 1D, 2D, 3D e 1W")

// ───────────────────────────────────────────────────────────────
//  INPUTS — Lookback & Merge
// ───────────────────────────────────────────────────────────────
g_lm = "Lookback & Merge"
lb_base = input.int(500, "Lookback base (barras 4H)", minval=50, maxval=2000, group=g_lm,
                    tooltip="Lookback base em barras de 4H. Auto-escalado para cada TF:\n30m=×2.0  1H=×1.5  4H=×1.0  12H=×0.6\n1D=×0.4  2D=×0.26  3D=×0.18  1W=×0.10")
mg_pct  = input.float(2.00, "Merge: fundir zonas dentro de X%", minval=0.10, maxval=8.0,
                      step=0.10, group=g_lm,
                      tooltip="Zonas de TFs diferentes dentro desta % são fundidas. TF mais alto tem prioridade.")
bk_bars = input.int(300, "Extensão à esquerda (barras)", minval=50, maxval=2000, group=g_lm)

// ───────────────────────────────────────────────────────────────
//  INPUTS — Invalidação & Grab
// ───────────────────────────────────────────────────────────────
g_ig = "Invalidação & Grab"
inv_on = input.bool(true, "Remover zonas varridas (sweep)", group=g_ig,
                    tooltip="Remove zonas cuja faixa foi totalmente atravessada pelo close.")
grb_on = input.bool(true, "Detectar Liquidity Grabs", group=g_ig,
                    tooltip="Marca quando o pavio varre uma zona mas o corpo fecha de volta (sinal de reversão).")
grb_cd = input.int(3, "Cooldown entre grabs (barras)", minval=1, maxval=20, group=g_ig)

// ───────────────────────────────────────────────────────────────
//  INPUTS — Equal Highs / Equal Lows (EQH/EQL)
// ───────────────────────────────────────────────────────────────
g_eq = "Equal Highs / Equal Lows"
eq_on  = input.bool(true, "Detectar EQH/EQL", group=g_eq,
                    tooltip="Identifica níveis onde 2+ pivots (chart TF) formam lows ou highs quase iguais — piscinas de liquidez estruturais.\nNão é afetado por sweep invalidation.")
eq_tol = input.float(0.50, "Tolerância (%)", minval=0.10, maxval=3.0, step=0.10, group=g_eq,
                     tooltip="Distância máxima entre pivots para serem considerados 'iguais'.")
eq_min = input.int(2, "Toques mínimos", minval=2, maxval=10, group=g_eq,
                   tooltip="Quantos pivots precisam tocar o mesmo nível para confirmar EQH/EQL.")
eq_lb  = input.int(100, "Lookback (pivots do chart)", minval=10, maxval=500, group=g_eq,
                   tooltip="Quantidade máxima de pivots do TF do chart a manter em memória para detecção de clusters.")

// ───────────────────────────────────────────────────────────────
//  INPUTS — Cores
// ───────────────────────────────────────────────────────────────
g_c = "Cores"
ca_fill      = input.color(color.new(#EF5350, 80), "Fill — acima (short)",  group=g_c,
                           tooltip="Opacidade base para 1W. TFs menores ficam progressivamente mais transparentes.")
ca_brd       = input.color(color.new(#EF5350, 10), "Borda — acima",         group=g_c)
cb_fill      = input.color(color.new(#26A69A, 80), "Fill — abaixo (long)",  group=g_c,
                           tooltip="Opacidade base para 1W. TFs menores ficam progressivamente mais transparentes.")
cb_brd       = input.color(color.new(#26A69A, 10), "Borda — abaixo",        group=g_c)
grb_col_buy  = input.color(color.new(#EF5350, 0), "Grab buyside (bearish)",  group=g_c,
                           tooltip="Diamante acima da barra quando pavio varre pivot high e fecha de volta.")
grb_col_sell = input.color(color.new(#26A69A, 0), "Grab sellside (bullish)", group=g_c,
                           tooltip="Diamante abaixo da barra quando pavio varre pivot low e fecha de volta.")
show_lbl     = input.bool(true, "Labels", group=g_c)
lbl_size     = input.string("normal", "Tamanho do label",
                            options=["tiny", "small", "normal", "large"], group=g_c)

// ───────────────────────────────────────────────────────────────
//  COMPATIBILIDADE DE TF
//  request.security não pode puxar TF inferior ao chart.
// ───────────────────────────────────────────────────────────────
_tf_secs = timeframe.in_seconds()
_30m_ok  = show_30m and _tf_secs <= 1800       // chart ≤ 30m
_1h_ok   = show_1h  and _tf_secs <= 3600       // chart ≤ 1H
_4h_ok   = show_4h  and _tf_secs <= 14400      // chart ≤ 4H
_12h_ok  = show_12h and _tf_secs <= 43200      // chart ≤ 12H
_1d_ok   = show_1d  and _tf_secs <= 86400      // chart ≤ 1D
_2d_ok   = show_2d  and _tf_secs <= 172800     // chart ≤ 2D
_3d_ok   = show_3d  and _tf_secs <= 259200     // chart ≤ 3D
_1w_ok   = show_1w                             // 1W sempre ok

// ───────────────────────────────────────────────────────────────
//  LOOKBACK — auto-escalado por TF
// ───────────────────────────────────────────────────────────────
lb_30m = int(math.round(lb_base * 2.00))
lb_1h  = int(math.round(lb_base * 1.50))
lb_4h  = lb_base
lb_12h = int(math.round(lb_base * 0.60))
lb_1d  = int(math.round(lb_base * 0.40))
lb_2d  = int(math.round(lb_base * 0.26))
lb_3d  = int(math.round(lb_base * 0.18))
lb_1w  = int(math.max(10, math.round(lb_base * 0.10)))

// ───────────────────────────────────────────────────────────────
//  HELPERS
// ───────────────────────────────────────────────────────────────

// Bubble sort ascendente paralelo (ordena 'a', carrega 'b' junto)
sort_asc(array<float> a, array<float> b) =>
    n = array.size(a)
    if n > 1
        for i = 0 to n - 2
            for j = 0 to n - 2 - i
                if array.get(a, j) > array.get(a, j + 1)
                    va = array.get(a, j)
                    vb = array.get(b, j)
                    array.set(a, j,     array.get(a, j + 1))
                    array.set(b, j,     array.get(b, j + 1))
                    array.set(a, j + 1, va)
                    array.set(b, j + 1, vb)

// Merge — arrays ordenados por proximidade ao preço
// Tipo 0–7: maior = TF mais alto = maior prioridade.
merge_zones(array<float> lvls, array<float> typs) =>
    if array.size(lvls) >= 2
        i = 0
        while i < array.size(lvls) - 1
            c   = array.get(lvls, i)
            nxt = array.get(lvls, i + 1)
            if math.abs(nxt - c) / c * 100.0 <= mg_pct
                ct = array.get(typs, i)
                nt = array.get(typs, i + 1)
                rm = (nt > ct) ? i : i + 1
                array.remove(lvls, rm)
                array.remove(typs, rm)
            else
                i += 1

// Cor com transparência graduada por TF (0.0=30m … 7.0=1W)
// TFs mais altos são mais opacos (menos transparência extra)
// EQ zones (tp < 0) usam transparência equivalente a 12H (tp=3.0)
f_col(color base, float tp) =>
    _tp = tp < 0.0 ? 3.0 : tp
    extra = int(math.round((7.0 - _tp) * 2.0))
    color.new(base, math.min(96, color.t(base) + extra))

// Label prefix por tipo de TF (EQL=-1.0, EQH=-2.0)
f_pfx(float tp) =>
    (tp >= 7.0  ? "1S"  :
     tp >= 6.0  ? "3D"  :
     tp >= 5.0  ? "2D"  :
     tp >= 4.0  ? "1D"  :
     tp >= 3.0  ? "12H" :
     tp >= 2.0  ? "4H"  :
     tp >= 1.0  ? "1H"  :
     tp >= 0.0  ? "30m" :
     tp > -1.5  ? "EQL" : "EQH")

// Invalidação de zona high (sweep upside)
f_inv_hi(array<float> arr, float _ihz) =>
    if array.size(arr) > 0
        j = array.size(arr) - 1
        while j >= 0
            if close > array.get(arr, j) * (1.0 + _ihz)
                array.remove(arr, j)
            j -= 1

// Invalidação de zona low (sweep downside)
f_inv_lo(array<float> arr, float _ihz) =>
    if array.size(arr) > 0
        j = array.size(arr) - 1
        while j >= 0
            if close < array.get(arr, j) * (1.0 - _ihz)
                array.remove(arr, j)
            j -= 1

// Detecta grab em array de pivot highs (buyside liquidity)
f_grab_hi(array<float> arr, float _hz) =>
    _found = false
    if array.size(arr) > 0
        for k = 0 to array.size(arr) - 1
            lv = array.get(arr, k)
            zt = lv * (1.0 + _hz)
            if high > zt and math.max(close, open) <= zt
                _found := true
                break
    _found

// Detecta grab em array de pivot lows (sellside liquidity)
f_grab_lo(array<float> arr, float _hz) =>
    _found = false
    if array.size(arr) > 0
        for k = 0 to array.size(arr) - 1
            lv = array.get(arr, k)
            zb = lv * (1.0 - _hz)
            if low < zb and math.min(close, open) >= zb
                _found := true
                break
    _found

// Pool builder — adiciona níveis de um array ao pool up/dn
f_pool(array<float> src, float cp, float tp,
       array<float> _up_l, array<float> _up_t,
       array<float> _dn_l, array<float> _dn_t) =>
    sz = array.size(src)
    if sz > 0
        for i = 0 to sz - 1
            lv = array.get(src, i)
            if lv > cp
                array.push(_up_l, lv)
                array.push(_up_t, tp)
            else
                array.push(_dn_l, lv)
                array.push(_dn_t, tp)

// Cluster detection — encontra níveis onde min_n pivots estão dentro de tol%
// Retorna array com o nível médio de cada cluster encontrado
// Complexidade O(n²) — aceitável pois roda apenas em barstate.islast
f_clusters(array<float> src, float tol_pct, int min_n) =>
    out = array.new<float>()
    sz = array.size(src)
    if sz >= min_n
        _used = array.new<bool>()
        for _i = 0 to sz - 1
            array.push(_used, false)
        for i = 0 to sz - 1
            if not array.get(_used, i)
                c = array.get(src, i)
                _sum = c
                cnt = 1
                if c > 0.0 and i < sz - 1
                    for j = i + 1 to sz - 1
                        if not array.get(_used, j)
                            lv = array.get(src, j)
                            if math.abs(lv - c) / c * 100.0 <= tol_pct
                                _sum += lv
                                cnt += 1
                                array.set(_used, j, true)
                if cnt >= min_n
                    array.push(out, _sum / cnt)
                    array.set(_used, i, true)
    out

// ═══════════════════════════════════════════════════════════════
//  COLETA — 30 min  (tipo 0.0)
//  SMA volume: 500 barras ≈ 10 dias de 30min
// ═══════════════════════════════════════════════════════════════
var array<float> m30_h = array.new<float>()
var array<float> m30_l = array.new<float>()
var int m30_ph_idx = na
var int m30_pl_idx = na

[m30_bidx, m30_ph, m30_pl, m30_sma, m30_volp] = request.security(
     syminfo.tickerid, "30",
     [bar_index, ta.pivothigh(sw_len, sw_len), ta.pivotlow(sw_len, sw_len),
      ta.sma(volume, 500), volume[sw_len]])
m30_vr = (not na(m30_sma) and m30_sma > 0.0) ? m30_volp / m30_sma : 999.0

if _30m_ok and not na(m30_ph) and m30_vr >= vm_intra
    if na(m30_ph_idx) or m30_bidx != m30_ph_idx
        m30_ph_idx := m30_bidx
        array.push(m30_h, m30_ph)
        if array.size(m30_h) > lb_30m
            array.shift(m30_h)

if _30m_ok and not na(m30_pl) and m30_vr >= vm_intra
    if na(m30_pl_idx) or m30_bidx != m30_pl_idx
        m30_pl_idx := m30_bidx
        array.push(m30_l, m30_pl)
        if array.size(m30_l) > lb_30m
            array.shift(m30_l)

// ═══════════════════════════════════════════════════════════════
//  COLETA — 1H  (tipo 1.0)
//  SMA volume: 250 barras ≈ 10 dias de 1H
// ═══════════════════════════════════════════════════════════════
var array<float> h1_h = array.new<float>()
var array<float> h1_l = array.new<float>()
var int h1_ph_idx = na
var int h1_pl_idx = na

[h1_bidx, h1_ph, h1_pl, h1_sma, h1_volp] = request.security(
     syminfo.tickerid, "60",
     [bar_index, ta.pivothigh(sw_len, sw_len), ta.pivotlow(sw_len, sw_len),
      ta.sma(volume, 250), volume[sw_len]])
h1_vr = (not na(h1_sma) and h1_sma > 0.0) ? h1_volp / h1_sma : 999.0

if _1h_ok and not na(h1_ph) and h1_vr >= vm_intra
    if na(h1_ph_idx) or h1_bidx != h1_ph_idx
        h1_ph_idx := h1_bidx
        array.push(h1_h, h1_ph)
        if array.size(h1_h) > lb_1h
            array.shift(h1_h)

if _1h_ok and not na(h1_pl) and h1_vr >= vm_intra
    if na(h1_pl_idx) or h1_bidx != h1_pl_idx
        h1_pl_idx := h1_bidx
        array.push(h1_l, h1_pl)
        if array.size(h1_l) > lb_1h
            array.shift(h1_l)

// ═══════════════════════════════════════════════════════════════
//  COLETA — 4H  (tipo 2.0)
//  SMA volume: 250 barras ≈ 42 dias de 4H
// ═══════════════════════════════════════════════════════════════
var array<float> h4_h = array.new<float>()
var array<float> h4_l = array.new<float>()
var int h4_ph_idx = na
var int h4_pl_idx = na

[h4_bidx, h4_ph, h4_pl, h4_sma, h4_volp] = request.security(
     syminfo.tickerid, "240",
     [bar_index, ta.pivothigh(sw_len, sw_len), ta.pivotlow(sw_len, sw_len),
      ta.sma(volume, 250), volume[sw_len]])
h4_vr = (not na(h4_sma) and h4_sma > 0.0) ? h4_volp / h4_sma : 999.0

if _4h_ok and not na(h4_ph) and h4_vr >= vm_swing
    if na(h4_ph_idx) or h4_bidx != h4_ph_idx
        h4_ph_idx := h4_bidx
        array.push(h4_h, h4_ph)
        if array.size(h4_h) > lb_4h
            array.shift(h4_h)

if _4h_ok and not na(h4_pl) and h4_vr >= vm_swing
    if na(h4_pl_idx) or h4_bidx != h4_pl_idx
        h4_pl_idx := h4_bidx
        array.push(h4_l, h4_pl)
        if array.size(h4_l) > lb_4h
            array.shift(h4_l)

// ═══════════════════════════════════════════════════════════════
//  COLETA — 12H  (tipo 3.0)
//  SMA volume: 200 barras ≈ 100 dias de 12H
// ═══════════════════════════════════════════════════════════════
var array<float> h12_h = array.new<float>()
var array<float> h12_l = array.new<float>()
var int h12_ph_idx = na
var int h12_pl_idx = na

[h12_bidx, h12_ph, h12_pl, h12_sma, h12_volp] = request.security(
     syminfo.tickerid, "720",
     [bar_index, ta.pivothigh(sw_len, sw_len), ta.pivotlow(sw_len, sw_len),
      ta.sma(volume, 200), volume[sw_len]])
h12_vr = (not na(h12_sma) and h12_sma > 0.0) ? h12_volp / h12_sma : 999.0

if _12h_ok and not na(h12_ph) and h12_vr >= vm_swing
    if na(h12_ph_idx) or h12_bidx != h12_ph_idx
        h12_ph_idx := h12_bidx
        array.push(h12_h, h12_ph)
        if array.size(h12_h) > lb_12h
            array.shift(h12_h)

if _12h_ok and not na(h12_pl) and h12_vr >= vm_swing
    if na(h12_pl_idx) or h12_bidx != h12_pl_idx
        h12_pl_idx := h12_bidx
        array.push(h12_l, h12_pl)
        if array.size(h12_l) > lb_12h
            array.shift(h12_l)

// ═══════════════════════════════════════════════════════════════
//  COLETA — 1D  (tipo 4.0)
//  SMA volume: 200 barras = 200 dias
// ═══════════════════════════════════════════════════════════════
var array<float> d1_h = array.new<float>()
var array<float> d1_l = array.new<float>()
var int d1_ph_idx = na
var int d1_pl_idx = na

[d1_bidx, d1_ph, d1_pl, d1_sma, d1_volp] = request.security(
     syminfo.tickerid, "D",
     [bar_index, ta.pivothigh(sw_len, sw_len), ta.pivotlow(sw_len, sw_len),
      ta.sma(volume, 200), volume[sw_len]])
d1_vr = (not na(d1_sma) and d1_sma > 0.0) ? d1_volp / d1_sma : 999.0

if _1d_ok and not na(d1_ph) and d1_vr >= vm_pos
    if na(d1_ph_idx) or d1_bidx != d1_ph_idx
        d1_ph_idx := d1_bidx
        array.push(d1_h, d1_ph)
        if array.size(d1_h) > lb_1d
            array.shift(d1_h)

if _1d_ok and not na(d1_pl) and d1_vr >= vm_pos
    if na(d1_pl_idx) or d1_bidx != d1_pl_idx
        d1_pl_idx := d1_bidx
        array.push(d1_l, d1_pl)
        if array.size(d1_l) > lb_1d
            array.shift(d1_l)

// ═══════════════════════════════════════════════════════════════
//  COLETA — 2D  (tipo 5.0)
//  SMA volume: 100 barras ≈ 200 dias
// ═══════════════════════════════════════════════════════════════
var array<float> d2_h = array.new<float>()
var array<float> d2_l = array.new<float>()
var int d2_ph_idx = na
var int d2_pl_idx = na

[d2_bidx, d2_ph, d2_pl, d2_sma, d2_volp] = request.security(
     syminfo.tickerid, "2D",
     [bar_index, ta.pivothigh(sw_len, sw_len), ta.pivotlow(sw_len, sw_len),
      ta.sma(volume, 100), volume[sw_len]])
d2_vr = (not na(d2_sma) and d2_sma > 0.0) ? d2_volp / d2_sma : 999.0

if _2d_ok and not na(d2_ph) and d2_vr >= vm_pos
    if na(d2_ph_idx) or d2_bidx != d2_ph_idx
        d2_ph_idx := d2_bidx
        array.push(d2_h, d2_ph)
        if array.size(d2_h) > lb_2d
            array.shift(d2_h)

if _2d_ok and not na(d2_pl) and d2_vr >= vm_pos
    if na(d2_pl_idx) or d2_bidx != d2_pl_idx
        d2_pl_idx := d2_bidx
        array.push(d2_l, d2_pl)
        if array.size(d2_l) > lb_2d
            array.shift(d2_l)

// ═══════════════════════════════════════════════════════════════
//  COLETA — 3D  (tipo 6.0)
//  SMA volume: 65 barras ≈ 195 dias
// ═══════════════════════════════════════════════════════════════
var array<float> d3_h = array.new<float>()
var array<float> d3_l = array.new<float>()
var int d3_ph_idx = na
var int d3_pl_idx = na

[d3_bidx, d3_ph, d3_pl, d3_sma, d3_volp] = request.security(
     syminfo.tickerid, "3D",
     [bar_index, ta.pivothigh(sw_len, sw_len), ta.pivotlow(sw_len, sw_len),
      ta.sma(volume, 65), volume[sw_len]])
d3_vr = (not na(d3_sma) and d3_sma > 0.0) ? d3_volp / d3_sma : 999.0

if _3d_ok and not na(d3_ph) and d3_vr >= vm_pos
    if na(d3_ph_idx) or d3_bidx != d3_ph_idx
        d3_ph_idx := d3_bidx
        array.push(d3_h, d3_ph)
        if array.size(d3_h) > lb_3d
            array.shift(d3_h)

if _3d_ok and not na(d3_pl) and d3_vr >= vm_pos
    if na(d3_pl_idx) or d3_bidx != d3_pl_idx
        d3_pl_idx := d3_bidx
        array.push(d3_l, d3_pl)
        if array.size(d3_l) > lb_3d
            array.shift(d3_l)

// ═══════════════════════════════════════════════════════════════
//  COLETA — 1W  (tipo 7.0)
//  SMA volume: 52 barras = 1 ano
// ═══════════════════════════════════════════════════════════════
var array<float> w1_h = array.new<float>()
var array<float> w1_l = array.new<float>()
var int w1_ph_idx = na
var int w1_pl_idx = na

[w1_bidx, w1_ph, w1_pl, w1_sma, w1_volp] = request.security(
     syminfo.tickerid, "W",
     [bar_index, ta.pivothigh(sw_len, sw_len), ta.pivotlow(sw_len, sw_len),
      ta.sma(volume, 52), volume[sw_len]])
w1_vr = (not na(w1_sma) and w1_sma > 0.0) ? w1_volp / w1_sma : 999.0

if _1w_ok and not na(w1_ph) and w1_vr >= vm_pos
    if na(w1_ph_idx) or w1_bidx != w1_ph_idx
        w1_ph_idx := w1_bidx
        array.push(w1_h, w1_ph)
        if array.size(w1_h) > lb_1w
            array.shift(w1_h)

if _1w_ok and not na(w1_pl) and w1_vr >= vm_pos
    if na(w1_pl_idx) or w1_bidx != w1_pl_idx
        w1_pl_idx := w1_bidx
        array.push(w1_l, w1_pl)
        if array.size(w1_l) > lb_1w
            array.shift(w1_l)

// ═══════════════════════════════════════════════════════════════
//  COLETA — Equal Highs / Equal Lows (chart TF)
//  Pivots do TF do chart, armazenados em arrays separados.
//  NÃO afetados por sweep invalidation — capturam estrutura.
// ═══════════════════════════════════════════════════════════════
var array<float> eq_ph_all = array.new<float>()
var array<float> eq_pl_all = array.new<float>()

_ch_ph = ta.pivothigh(sw_len, sw_len)
_ch_pl = ta.pivotlow(sw_len, sw_len)

if eq_on and not na(_ch_ph)
    array.push(eq_ph_all, _ch_ph)
    if array.size(eq_ph_all) > eq_lb
        array.shift(eq_ph_all)

if eq_on and not na(_ch_pl)
    array.push(eq_pl_all, _ch_pl)
    if array.size(eq_pl_all) > eq_lb
        array.shift(eq_pl_all)

// ───────────────────────────────────────────────────────────────
//  ZONE INVALIDATION — remove zonas cuja faixa foi varrida
//  Pivot highs: invalidar quando close > zona_top (upside sweep)
//  Pivot lows:  invalidar quando close < zona_bottom (downside sweep)
// ───────────────────────────────────────────────────────────────
if inv_on and barstate.isconfirmed
    _ihz = z_pct / 200.0
    // Pivot highs — sweep upside
    f_inv_hi(m30_h, _ihz)
    f_inv_hi(h1_h,  _ihz)
    f_inv_hi(h4_h,  _ihz)
    f_inv_hi(h12_h, _ihz)
    f_inv_hi(d1_h,  _ihz)
    f_inv_hi(d2_h,  _ihz)
    f_inv_hi(d3_h,  _ihz)
    f_inv_hi(w1_h,  _ihz)
    // Pivot lows — sweep downside
    f_inv_lo(m30_l, _ihz)
    f_inv_lo(h1_l,  _ihz)
    f_inv_lo(h4_l,  _ihz)
    f_inv_lo(h12_l, _ihz)
    f_inv_lo(d1_l,  _ihz)
    f_inv_lo(d2_l,  _ihz)
    f_inv_lo(d3_l,  _ihz)
    f_inv_lo(w1_l,  _ihz)

// ───────────────────────────────────────────────────────────────
//  LIQUIDITY GRAB DETECTION
//  Buyside grab:  pavio > zona_top de pivot high, corpo ≤ zona_top
//  Sellside grab: pavio < zona_bottom de pivot low, corpo ≥ zona_bottom
// ───────────────────────────────────────────────────────────────
var int _last_buy_bar  = 0
var int _last_sell_bar = 0

_ghz = z_pct / 200.0
_grab_buy_raw  = false
_grab_sell_raw = false

if grb_on and barstate.isconfirmed
    if _30m_ok
        _grab_buy_raw  := _grab_buy_raw  or f_grab_hi(m30_h, _ghz)
        _grab_sell_raw := _grab_sell_raw or f_grab_lo(m30_l, _ghz)
    if _1h_ok
        _grab_buy_raw  := _grab_buy_raw  or f_grab_hi(h1_h, _ghz)
        _grab_sell_raw := _grab_sell_raw or f_grab_lo(h1_l, _ghz)
    if _4h_ok
        _grab_buy_raw  := _grab_buy_raw  or f_grab_hi(h4_h, _ghz)
        _grab_sell_raw := _grab_sell_raw or f_grab_lo(h4_l, _ghz)
    if _12h_ok
        _grab_buy_raw  := _grab_buy_raw  or f_grab_hi(h12_h, _ghz)
        _grab_sell_raw := _grab_sell_raw or f_grab_lo(h12_l, _ghz)
    if _1d_ok
        _grab_buy_raw  := _grab_buy_raw  or f_grab_hi(d1_h, _ghz)
        _grab_sell_raw := _grab_sell_raw or f_grab_lo(d1_l, _ghz)
    if _2d_ok
        _grab_buy_raw  := _grab_buy_raw  or f_grab_hi(d2_h, _ghz)
        _grab_sell_raw := _grab_sell_raw or f_grab_lo(d2_l, _ghz)
    if _3d_ok
        _grab_buy_raw  := _grab_buy_raw  or f_grab_hi(d3_h, _ghz)
        _grab_sell_raw := _grab_sell_raw or f_grab_lo(d3_l, _ghz)
    if _1w_ok
        _grab_buy_raw  := _grab_buy_raw  or f_grab_hi(w1_h, _ghz)
        _grab_sell_raw := _grab_sell_raw or f_grab_lo(w1_l, _ghz)

_grab_buy  = _grab_buy_raw  and (bar_index - _last_buy_bar)  > grb_cd
_grab_sell = _grab_sell_raw and (bar_index - _last_sell_bar) > grb_cd

if _grab_buy
    _last_buy_bar := bar_index
if _grab_sell
    _last_sell_bar := bar_index

// ───────────────────────────────────────────────────────────────
//  DESENHO — refresh em barstate.islast
// ───────────────────────────────────────────────────────────────
var array<box>   bxs  = array.new<box>()
var array<label> lbls = array.new<label>()

// Pools persistentes (cleared a cada redraw)
var array<float> up_l = array.new<float>()
var array<float> up_t = array.new<float>()
var array<float> dn_l = array.new<float>()
var array<float> dn_t = array.new<float>()

if barstate.islast

    // Limpar desenhos anteriores
    for bx in bxs
        box.delete(bx)
    array.clear(bxs)
    for lb in lbls
        label.delete(lb)
    array.clear(lbls)

    cp    = close
    hz    = z_pct / 200.0
    l_bar = bar_index - bk_bars

    sz_map = lbl_size == "tiny"   ? size.tiny   :
             lbl_size == "small"  ? size.small  :
             lbl_size == "large"  ? size.large  : size.normal

    lbl_off = 15  // offset para alinhar labels à escala de preço

    // ── Montar pools de todos os TFs ──
    array.clear(up_l)
    array.clear(up_t)
    array.clear(dn_l)
    array.clear(dn_t)

    // 30m → tipo 0.0
    f_pool(m30_h, cp, 0.0, up_l, up_t, dn_l, dn_t)
    f_pool(m30_l, cp, 0.0, up_l, up_t, dn_l, dn_t)
    // 1H → tipo 1.0
    f_pool(h1_h, cp, 1.0, up_l, up_t, dn_l, dn_t)
    f_pool(h1_l, cp, 1.0, up_l, up_t, dn_l, dn_t)
    // 4H → tipo 2.0
    f_pool(h4_h, cp, 2.0, up_l, up_t, dn_l, dn_t)
    f_pool(h4_l, cp, 2.0, up_l, up_t, dn_l, dn_t)
    // 12H → tipo 3.0
    f_pool(h12_h, cp, 3.0, up_l, up_t, dn_l, dn_t)
    f_pool(h12_l, cp, 3.0, up_l, up_t, dn_l, dn_t)
    // 1D → tipo 4.0
    f_pool(d1_h, cp, 4.0, up_l, up_t, dn_l, dn_t)
    f_pool(d1_l, cp, 4.0, up_l, up_t, dn_l, dn_t)
    // 2D → tipo 5.0
    f_pool(d2_h, cp, 5.0, up_l, up_t, dn_l, dn_t)
    f_pool(d2_l, cp, 5.0, up_l, up_t, dn_l, dn_t)
    // 3D → tipo 6.0
    f_pool(d3_h, cp, 6.0, up_l, up_t, dn_l, dn_t)
    f_pool(d3_l, cp, 6.0, up_l, up_t, dn_l, dn_t)
    // 1W → tipo 7.0
    f_pool(w1_h, cp, 7.0, up_l, up_t, dn_l, dn_t)
    f_pool(w1_l, cp, 7.0, up_l, up_t, dn_l, dn_t)

    // EQH/EQL → clusters do chart TF (tipo -2.0 = EQH, -1.0 = EQL)
    if eq_on
        _eqh = f_clusters(eq_ph_all, eq_tol, eq_min)
        _eql = f_clusters(eq_pl_all, eq_tol, eq_min)
        if array.size(_eqh) > 0
            for i = 0 to array.size(_eqh) - 1
                lv = array.get(_eqh, i)
                if lv > cp
                    array.push(up_l, lv)
                    array.push(up_t, -2.0)
                else
                    array.push(dn_l, lv)
                    array.push(dn_t, -2.0)
        if array.size(_eql) > 0
            for i = 0 to array.size(_eql) - 1
                lv = array.get(_eql, i)
                if lv > cp
                    array.push(up_l, lv)
                    array.push(up_t, -1.0)
                else
                    array.push(dn_l, lv)
                    array.push(dn_t, -1.0)

    // ── Ordenar: acima asc, abaixo desc (mais próximo primeiro) ──
    sort_asc(up_l, up_t)
    sort_asc(dn_l, dn_t)
    if array.size(dn_l) > 0
        array.reverse(dn_l)
        array.reverse(dn_t)

    // ── Merge — zonas próximas fundidas, TF maior tem prioridade ──
    merge_zones(up_l, up_t)
    merge_zones(dn_l, dn_t)

    // ────────────────────────────────────────────────────────────
    //  ZONAS ACIMA (vermelho)
    //  Guard: em Pine v6, for i=0 to -1 ainda executa
    // ────────────────────────────────────────────────────────────
    cnt_up = math.min(n_up, array.size(up_l))
    if cnt_up > 0
        for i = 0 to cnt_up - 1
            lv   = array.get(up_l, i)
            tp   = array.get(up_t, i)
            top_ = lv * (1.0 + hz)
            bot_ = lv * (1.0 - hz)
            _is_eq = tp < 0.0
            bw   = _is_eq ? 1 : (tp >= 4.0 ? 2 : 1)
            bs   = _is_eq ? line.style_dashed : line.style_solid
            fc   = f_col(ca_fill, tp)
            bc   = f_col(ca_brd,  tp)

            bx = box.new(l_bar, top_, bar_index, bot_,
                         border_color = bc,
                         bgcolor      = fc,
                         border_width = bw,
                         border_style = bs,
                         extend       = extend.right)
            array.push(bxs, bx)

            if show_lbl
                pfx  = f_pfx(tp)
                mid_ = (top_ + bot_) / 2.0
                lb_c = label.new(bar_index + lbl_off, mid_,
                                   pfx + "  " + str.tostring(lv, format.mintick),
                                   color     = color.new(color.white, 100),
                                   textcolor = bc,
                                   style     = label.style_label_left,
                                   size      = sz_map)
                array.push(lbls, lb_c)

    // ────────────────────────────────────────────────────────────
    //  ZONAS ABAIXO (verde)
    // ────────────────────────────────────────────────────────────
    cnt_dn = math.min(n_dn, array.size(dn_l))
    if cnt_dn > 0
        for i = 0 to cnt_dn - 1
            lv   = array.get(dn_l, i)
            tp   = array.get(dn_t, i)
            top_ = lv * (1.0 + hz)
            bot_ = lv * (1.0 - hz)
            _is_eq = tp < 0.0
            bw   = _is_eq ? 1 : (tp >= 4.0 ? 2 : 1)
            bs   = _is_eq ? line.style_dashed : line.style_solid
            fc   = f_col(cb_fill, tp)
            bc   = f_col(cb_brd,  tp)

            bx = box.new(l_bar, top_, bar_index, bot_,
                         border_color = bc,
                         bgcolor      = fc,
                         border_width = bw,
                         border_style = bs,
                         extend       = extend.right)
            array.push(bxs, bx)

            if show_lbl
                pfx  = f_pfx(tp)
                mid_ = (top_ + bot_) / 2.0
                lb_c = label.new(bar_index + lbl_off, mid_,
                                   pfx + "  " + str.tostring(lv, format.mintick),
                                   color     = color.new(color.white, 100),
                                   textcolor = bc,
                                   style     = label.style_label_left,
                                   size      = sz_map)
                array.push(lbls, lb_c)

// ───────────────────────────────────────────────────────────────
//  GRAB PLOTS & ALERTS
// ───────────────────────────────────────────────────────────────
plotshape(_grab_buy  ? high : na, "Buyside Grab",  shape.diamond, location.abovebar,
          grb_col_buy,  size=size.normal, text="Sell", textcolor=grb_col_buy)
plotshape(_grab_sell ? low  : na, "Sellside Grab", shape.diamond, location.belowbar,
          grb_col_sell, size=size.normal, text="Buy", textcolor=grb_col_sell)

alertcondition(_grab_buy,  "Buyside Liquidity Grab",
              "Buyside Liquidity Grab @ {{ticker}} — preço: {{close}}")
alertcondition(_grab_sell, "Sellside Liquidity Grab",
              "Sellside Liquidity Grab @ {{ticker}} — preço: {{close}}")
````

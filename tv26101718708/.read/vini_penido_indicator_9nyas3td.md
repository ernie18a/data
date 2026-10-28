# Vini Penido Indicator

- url: https://www.tradingview.com/script/9nyAS3td/
- type: indicator
- pine_id: PUB;02119c9de1554af1b536af25ba38f31a
- version: 1.0

## Description

Tempo e Preço baseado em referências temporais e de SMC

Made in Brazil
@oviniciuspenido

## Source Code

````pine
//@version=5
indicator("Grupo Penido Indicator", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════

show_ms   = input.bool(true, "Mostrar HH/HL/LH/LL", group="Market Structure")
ms_len    = input.int(10, "Swing Lookback", group="Market Structure", minval=3, maxval=50)

show_asia  = input.bool(true, "Mostrar Asia", group="Sessions")
show_lon   = input.bool(true, "Mostrar Londres", group="Sessions")
show_ny    = input.bool(true, "Mostrar NY", group="Sessions")

show_830   = input.bool(true, "FVG apos 8:30 NY", group="Fair Value Gaps")
show_930   = input.bool(true, "FVG apos 9:30 NY", group="Fair Value Gaps")
show_dfvg  = input.bool(true, "Double FVG Zone 8:00-9:30", group="Fair Value Gaps")
c_bull_fvg = input.color(color.new(color.green, 65), "FVG Alta", group="Fair Value Gaps")
c_bear_fvg = input.color(color.new(color.red, 65), "FVG Baixa", group="Fair Value Gaps")
c_dfvg     = input.color(color.new(color.orange, 55), "Double FVG Zone", group="Fair Value Gaps")

tbl_pos_i  = input.string("Top Right", "Posicao", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group="Tabela MTF")

// ══════════════════════════════════════════════════════════════════════════════
// UTILITARIOS
// ══════════════════════════════════════════════════════════════════════════════

_tpos() =>
    switch tbl_pos_i
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

_ny_h()  => hour(time, "America/New_York")
_ny_m()  => minute(time, "America/New_York")
_ny_hm() => _ny_h() * 60 + _ny_m()

// ══════════════════════════════════════════════════════════════════════════════
// MARKET STRUCTURE (HH / HL / LH / LL)
// ══════════════════════════════════════════════════════════════════════════════

ph = ta.pivothigh(high, ms_len, ms_len)
pl = ta.pivotlow(low, ms_len, ms_len)

var float prev_ph  = na
var float prev_pl  = na
var float older_ph = na
var float older_pl = na

if not na(ph)
    lbl = na(prev_ph) ? "SH" : ph > prev_ph ? "HH" : "LH"
    col = lbl == "HH" ? color.new(color.green, 0) : color.new(color.red, 0)
    if show_ms
        label.new(bar_index[ms_len], ph, lbl, style=label.style_none, yloc=yloc.abovebar, textcolor=col, size=size.small)
    older_ph := prev_ph
    prev_ph  := ph

if not na(pl)
    lbl = na(prev_pl) ? "SL" : pl > prev_pl ? "HL" : "LL"
    col = lbl == "HL" ? color.new(color.green, 0) : color.new(color.red, 0)
    if show_ms
        label.new(bar_index[ms_len], pl, lbl, style=label.style_none, yloc=yloc.belowbar, textcolor=col, size=size.small)
    older_pl := prev_pl
    prev_pl  := pl

ms_up   = not na(prev_ph) and not na(older_ph) and not na(prev_pl) and not na(older_pl) and prev_ph > older_ph and prev_pl > older_pl
ms_down = not na(prev_ph) and not na(older_ph) and not na(prev_pl) and not na(older_pl) and prev_ph < older_ph and prev_pl < older_pl

// ══════════════════════════════════════════════════════════════════════════════
// TENDENCIA + FORCA MULTI TIMEFRAME
// forca: spread EMA9/EMA21 comparado ao ATR(14) do proprio TF
// ══════════════════════════════════════════════════════════════════════════════

_tf_data(tf) =>
    [e9, e21, atr14] = request.security(syminfo.tickerid, tf, [ta.ema(close, 9), ta.ema(close, 21), ta.atr(14)], lookahead=barmerge.lookahead_off)
    spread = math.abs(e9 - e21)
    up     = e9 > e21
    forca  = spread >= atr14 * 0.4 ? "FORTE" : spread >= atr14 * 0.12 ? "MEDIO" : "FRACO"
    [up, forca]

[w_up,   w_f]   = _tf_data("W")
[d_up,   d_f]   = _tf_data("D")
[h4_up,  h4_f]  = _tf_data("240")
[h1_up,  h1_f]  = _tf_data("60")
[m30_up, m30_f] = _tf_data("30")
[m15_up, m15_f] = _tf_data("15")
[m5_up,  m5_f]  = _tf_data("5")
[m1_up,  m1_f]  = _tf_data("1")

// ══════════════════════════════════════════════════════════════════════════════
// TABELA MTF
// ══════════════════════════════════════════════════════════════════════════════

var table tbl = na
if barstate.islast
    if not na(tbl)
        table.delete(tbl)
    tbl := table.new(_tpos(), 3, 10, bgcolor=color.new(#0a0a0a, 5), border_color=color.new(color.gray, 40), border_width=2, frame_color=color.new(color.gray, 20), frame_width=2)

    hbg = color.new(#1a1a2e, 5)
    table.cell(tbl, 0, 0, "TF",    text_color=#ffffff, text_size=size.normal, bgcolor=hbg, text_halign=text.align_center)
    table.cell(tbl, 1, 0, "BIAS",  text_color=#ffffff, text_size=size.normal, bgcolor=hbg, text_halign=text.align_center)
    table.cell(tbl, 2, 0, "FORCA", text_color=#ffffff, text_size=size.normal, bgcolor=hbg, text_halign=text.align_center)

    tf_names  = array.from("W", "D", "4H", "1H", "30m", "15m", "5m", "1m")
    tf_ups    = array.from(w_up,  d_up,  h4_up,  h1_up,  m30_up,  m15_up,  m5_up,  m1_up)
    tf_forcas = array.from(w_f,   d_f,   h4_f,   h1_f,   m30_f,   m15_f,   m5_f,   m1_f)

    for i = 0 to 7
        up    = array.get(tf_ups,    i)
        forca = array.get(tf_forcas, i)
        row   = i + 1
        bg    = color.new(#111111, 10)
        bc    = up ? #00e676 : #ff5252
        bt    = up ? "ALTA" : "BAIXA"
        fc    = forca == "FORTE" ? #00e676 : forca == "MEDIO" ? #ffd700 : #888888

        table.cell(tbl, 0, row, array.get(tf_names, i), text_color=#cccccc, text_size=size.normal, bgcolor=bg, text_halign=text.align_center)
        table.cell(tbl, 1, row, bt,    text_color=bc, text_size=size.normal, bgcolor=bg, text_halign=text.align_center)
        table.cell(tbl, 2, row, forca, text_color=fc, text_size=size.normal, bgcolor=bg, text_halign=text.align_center)

    // Contagem para Panorama
    alta_n  = 0
    forte_n = 0
    medio_n = 0
    fraco_n = 0
    for j = 0 to 7
        if array.get(tf_ups, j)
            alta_n += 1
        f = array.get(tf_forcas, j)
        if f == "FORTE"
            forte_n += 1
        else if f == "MEDIO"
            medio_n += 1
        else
            fraco_n += 1

    baixa_n    = 8 - alta_n
    bias_pred  = alta_n >= baixa_n ? "ALTA" : "BAIXA"
    bias_num   = math.max(alta_n, baixa_n)
    bias_str   = str.tostring(bias_num) + "/8 " + bias_pred
    bias_col   = alta_n >= baixa_n ? #00e676 : #ff5252

    forca_pred = forte_n >= medio_n and forte_n >= fraco_n ? "FORTE" : medio_n >= fraco_n ? "MEDIO" : "FRACO"
    forca_dist = str.tostring(forte_n) + "/" + str.tostring(medio_n) + "/" + str.tostring(fraco_n)
    forca_col  = forca_pred == "FORTE" ? #00e676 : forca_pred == "MEDIO" ? #ffd700 : #888888

    phbg       = color.new(#1a1a2e, 5)
    forca_full = forca_pred + " (" + forca_dist + ")"

    table.cell(tbl, 0, 9, "PANORAMA", text_color=#ffffff, text_size=size.normal, bgcolor=phbg, text_halign=text.align_center)
    table.cell(tbl, 1, 9, bias_str,   text_color=bias_col, text_size=size.normal, bgcolor=phbg, text_halign=text.align_center)
    table.cell(tbl, 2, 9, forca_full, text_color=forca_col, text_size=size.normal, bgcolor=phbg, text_halign=text.align_center)

// ══════════════════════════════════════════════════════════════════════════════
// LINHAS DE SESSAO (ASIA / LONDON / NEW YORK)
// ══════════════════════════════════════════════════════════════════════════════

nyh = _ny_h()

in_asia_s = nyh >= 18 or nyh < 1
in_lon_s  = nyh >= 2  and nyh < 8
in_ny_s   = nyh >= 8  and nyh < 17

asia_start = in_asia_s and not in_asia_s[1]
lon_start  = in_lon_s  and not in_lon_s[1]
ny_start_b = in_ny_s   and not in_ny_s[1]

var float s_ah = na
var float s_al = na
var float s_lh = na
var float s_ll = na
var float s_nh = na
var float s_nl = na

if asia_start
    s_ah := high
    s_al := low
else if in_asia_s
    s_ah := math.max(nz(s_ah, high), high)
    s_al := math.min(nz(s_al, low), low)

if lon_start
    s_lh := high
    s_ll := low
else if in_lon_s
    s_lh := math.max(nz(s_lh, high), high)
    s_ll := math.min(nz(s_ll, low), low)

if ny_start_b
    s_nh := high
    s_nl := low
else if in_ny_s
    s_nh := math.max(nz(s_nh, high), high)
    s_nl := math.min(nz(s_nl, low), low)

var line  l_ah = na
var line  l_al = na
var line  l_lh = na
var line  l_ll = na
var line  l_nh = na
var line  l_nl = na
var label b_ah = na
var label b_al = na
var label b_lh = na
var label b_ll = na
var label b_nh = na
var label b_nl = na

if barstate.islast
    x1 = bar_index - 500
    x2 = bar_index + 5
    line.delete(l_ah)
    line.delete(l_al)
    line.delete(l_lh)
    line.delete(l_ll)
    line.delete(l_nh)
    line.delete(l_nl)
    label.delete(b_ah)
    label.delete(b_al)
    label.delete(b_lh)
    label.delete(b_ll)
    label.delete(b_nh)
    label.delete(b_nl)
    c_sess = color.black
    if show_asia
        if not na(s_ah)
            l_ah := line.new(x1, s_ah, x2, s_ah, color=c_sess, style=line.style_dotted, width=2)
            b_ah := label.new(x2, s_ah, "AH", style=label.style_none, textcolor=c_sess, size=size.small)
        if not na(s_al)
            l_al := line.new(x1, s_al, x2, s_al, color=c_sess, style=line.style_dotted, width=2)
            b_al := label.new(x2, s_al, "AL", style=label.style_none, textcolor=c_sess, size=size.small)
    if show_lon
        if not na(s_lh)
            l_lh := line.new(x1, s_lh, x2, s_lh, color=c_sess, style=line.style_dotted, width=2)
            b_lh := label.new(x2, s_lh, "LH", style=label.style_none, textcolor=c_sess, size=size.small)
        if not na(s_ll)
            l_ll := line.new(x1, s_ll, x2, s_ll, color=c_sess, style=line.style_dotted, width=2)
            b_ll := label.new(x2, s_ll, "LL", style=label.style_none, textcolor=c_sess, size=size.small)
    if show_ny
        if not na(s_nh)
            l_nh := line.new(x1, s_nh, x2, s_nh, color=c_sess, style=line.style_dotted, width=2)
            b_nh := label.new(x2, s_nh, "NYH", style=label.style_none, textcolor=c_sess, size=size.small)
        if not na(s_nl)
            l_nl := line.new(x1, s_nl, x2, s_nl, color=c_sess, style=line.style_dotted, width=2)
            b_nl := label.new(x2, s_nl, "NYL", style=label.style_none, textcolor=c_sess, size=size.small)

// ══════════════════════════════════════════════════════════════════════════════
// PDH / PDL / 50% CRT
// ══════════════════════════════════════════════════════════════════════════════

var float pdh_val  = na
var float pdl_val  = na
var float day_high = na
var float day_low  = na

new_day_pd = ta.change(dayofmonth(time, "America/New_York")) != 0

if new_day_pd
    if not na(day_high)
        pdh_val := day_high
        pdl_val := day_low
    day_high := high
    day_low  := low
else
    day_high := math.max(nz(day_high, high), high)
    day_low  := math.min(nz(day_low,  low),  low)

crt50 = (pdh_val + pdl_val) / 2

var line  l_pdh   = na
var line  l_pdl   = na
var line  l_crt   = na
var label b_pdh   = na
var label b_pdl   = na
var label b_crt   = na

if barstate.islast
    x1 = bar_index - 500
    x2 = bar_index + 5
    line.delete(l_pdh)
    line.delete(l_pdl)
    line.delete(l_crt)
    label.delete(b_pdh)
    label.delete(b_pdl)
    label.delete(b_crt)
    c_pd = color.black
    if not na(pdh_val)
        l_pdh := line.new(x1, pdh_val, x2, pdh_val, color=c_pd, style=line.style_dashed, width=1)
        b_pdh := label.new(x2, pdh_val, "PDH", style=label.style_none, textcolor=c_pd, size=size.small)
    if not na(pdl_val)
        l_pdl := line.new(x1, pdl_val, x2, pdl_val, color=c_pd, style=line.style_dashed, width=1)
        b_pdl := label.new(x2, pdl_val, "PDL", style=label.style_none, textcolor=c_pd, size=size.small)
    if not na(crt50)
        l_crt := line.new(x1, crt50, x2, crt50, color=c_pd, style=line.style_dashed, width=1)
        b_crt := label.new(x2, crt50, "50% CRT", style=label.style_none, textcolor=c_pd, size=size.small)

// ══════════════════════════════════════════════════════════════════════════════
// FAIR VALUE GAPS
// ══════════════════════════════════════════════════════════════════════════════

is_bull_fvg = low > high[2]
is_bear_fvg = high < low[2]

bull_top = low
bull_bot = high[2]
bear_top = low[2]
bear_bot = high

hm           = _ny_hm()
is_after_830 = hm >= 8 * 60 + 30
is_after_930 = hm >= 9 * 60 + 30
is_830_930   = is_after_830 and not is_after_930
is_800_930   = hm >= 8 * 60 and not is_after_930

var int   fvg_day   = na
var bool  f830      = false
var bool  f930      = false
var int   dfvg_n    = 0
var bool  dfvg_bull = true
var float d1t       = na
var float d1b       = na
var int   d1x       = na

var box   bx830 = na
var label lx830 = na
var box   bx930 = na
var label lx930 = na
var box   bx_d  = na
var label lx_d  = na

cur_day_ny = dayofmonth(time, "America/New_York")
if na(fvg_day) or fvg_day != cur_day_ny
    fvg_day := cur_day_ny
    f830    := false
    f930    := false
    dfvg_n  := 0
    d1t     := na
    d1b     := na
    d1x     := na
    box.delete(bx830)
    box.delete(bx930)
    box.delete(bx_d)
    label.delete(lx830)
    label.delete(lx930)
    label.delete(lx_d)

if show_830 and not f830 and is_830_930
    if is_bull_fvg or is_bear_fvg
        f830  := true
        is_b  = is_bull_fvg
        _t    = is_b ? bull_top : bear_top
        _b    = is_b ? bull_bot : bear_bot
        _bg   = is_b ? c_bull_fvg : c_bear_fvg
        _bc   = is_b ? color.new(color.green, 30) : color.new(color.red, 30)
        _lbl  = is_b ? "FVG 8:30 ALTA" : "FVG 8:30 BAIXA"
        _tc   = is_b ? color.new(color.green, 0) : color.new(color.red, 0)
        bx830 := box.new(bar_index[2], _t, bar_index + 60, _b, bgcolor=_bg, border_color=_bc, border_width=1, extend=extend.right)
        lx830 := label.new(bar_index[2], _t, _lbl, style=label.style_none, textcolor=_tc, size=size.small)

if show_930 and not f930 and is_after_930
    if is_bull_fvg or is_bear_fvg
        f930  := true
        is_b  = is_bull_fvg
        _t    = is_b ? bull_top : bear_top
        _b    = is_b ? bull_bot : bear_bot
        _bg   = is_b ? c_bull_fvg : c_bear_fvg
        _bc   = is_b ? color.new(color.green, 30) : color.new(color.red, 30)
        _lbl  = is_b ? "FVG 9:30 ALTA" : "FVG 9:30 BAIXA"
        _tc   = is_b ? color.new(color.lime, 0) : color.new(color.fuchsia, 0)
        bx930 := box.new(bar_index[2], _t, bar_index + 60, _b, bgcolor=_bg, border_color=_bc, border_width=1, extend=extend.right)
        lx930 := label.new(bar_index[2], _t, _lbl, style=label.style_none, textcolor=_tc, size=size.small)

if show_dfvg and is_800_930 and dfvg_n < 2
    fvg_here  = is_bull_fvg or is_bear_fvg
    bull_here = is_bull_fvg
    aligned   = bull_here == m15_up
    if fvg_here and aligned
        if dfvg_n == 0
            dfvg_n    := 1
            dfvg_bull := bull_here
            d1x       := bar_index[2]
            d1t       := bull_here ? bull_top : bear_top
            d1b       := bull_here ? bull_bot : bear_bot
        else if dfvg_n == 1 and bull_here == dfvg_bull
            dfvg_n := 2
            d2t     = bull_here ? bull_top : bear_top
            d2b     = bull_here ? bull_bot : bear_bot
            zt      = math.max(d1t, d2t)
            zb      = math.min(d1b, d2b)
            bx_d   := box.new(d1x, zt, bar_index + 80, zb, bgcolor=c_dfvg, border_color=color.new(color.orange, 10), border_width=2, extend=extend.right)
            lx_d   := label.new(d1x, zt, "Double FVG Zone", style=label.style_none, textcolor=color.new(color.orange, 0), size=size.small)
````

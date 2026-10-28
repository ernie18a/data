# VWAP Dashboard Globex RTH Multi Assets

- url: https://www.tradingview.com/script/umMkTMs6-VWAP-Dashboard-Globex-RTH-Multi-Assets/
- type: indicator
- pine_id: PUB;f4cd7c6ee4484bbb86d82587db0ec3cd
- version: 2.0

## Description

Dashboard shows 3 assets and what is the current price location in relation to each Globex (full day or overnight) VWAP and the RTH (New York) VWAP. 
It will also show whether it is inside the Std Dev Bands +-1 (In Value) otherwise it will give the points distance outside in the EXT column.
The Dist column shows the distance from the VWAP to the total current price location, not just to the outer band on the other VWAPs I've published.
There is a arrow that shows the direction price is currently compared to each VWAP.

Default assets are NQ, ES and YS Futures.

## Source Code

````pine
//@version=6
indicator("VWAP Dashboard — Globex + RTH", overlay=true)

// ═══════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════
var g_set = "Settings"
i_pos         = input.string("Top Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=g_set)
i_band_mult   = input.float(1.0, "Band Multiplier", minval=0.1, step=0.1, group=g_set)
i_text_size   = input.string("normal", "Text Size", options=["tiny","small","normal","large"], group=g_set)
i_rth_session = input.session("0930-1700", "RTH Session (NY time)", group=g_set)

var g_sym = "Symbols"
i_nq_sym  = input.symbol("NQ1!", "NQ Symbol", group=g_sym)
i_es_sym  = input.symbol("ES1!", "ES Symbol", group=g_sym)
i_ym_sym  = input.symbol("YM1!", "YM Symbol", group=g_sym)

var g_col = "Colors"
i_above_col   = input.color(color.new(#26A69A, 0),  "Above VWAP",      group=g_col)
i_below_col   = input.color(color.new(#EF5350, 0),  "Below VWAP",      group=g_col)
i_ext_col     = input.color(color.new(#FF9800, 0),  "Outside Band",    group=g_col)
i_inval_col   = input.color(color.new(#29B6F6, 0),  "In Value",        group=g_col)
i_header_col  = input.color(color.new(#37474F, 0),  "Header BG",       group=g_col)
i_subhdr_col  = input.color(color.new(#263238, 0),  "Sub-header BG",   group=g_col)
i_bg_col      = input.color(color.new(#1C2030, 90), "Table BG",        group=g_col)
i_na_col      = input.color(color.new(#607D8B, 0),  "Outside Session", group=g_col)

// ═══════════════════════════════════════════════════════════
// CORE VWAP LOGIC
// ═══════════════════════════════════════════════════════════
f_globex_vwap(float src, float vol, bool is_new_day, simple float mult) =>
    var float cpv = 0.0, var float cpv2 = 0.0, var float cvol = 0.0
    if is_new_day
        cpv := src * vol, cpv2 := src * src * vol, cvol := vol
    else
        cpv += src * vol, cpv2 += src * src * vol, cvol += vol
    float v = cvol > 0 ? cpv / cvol : na
    float u = na, float d = na
    if not na(v)
        float dev = math.sqrt(math.max(0.0, (cpv2 / cvol) - (v * v)))
        u := v + dev * mult, d := v - dev * mult
    [v, u, d]

f_rth_vwap(float src, float vol, bool in_sess, bool sess_open, simple float mult) =>
    var float cpv = 0.0, var float cpv2 = 0.0, var float cvol = 0.0
    if sess_open
        cpv := src * vol, cpv2 := src * src * vol, cvol := vol
    else if in_sess
        cpv += src * vol, cpv2 += src * src * vol, cvol += vol
    else
        cpv := 0.0, cpv2 := 0.0, cvol := 0.0
    float v = in_sess and cvol > 0 ? cpv / cvol : na
    float u = na, float d = na
    if not na(v)
        float dev = math.sqrt(math.max(0.0, (cpv2 / cvol) - (v * v)))
        u := v + dev * mult, d := v - dev * mult
    [v, u, d]

// ═══════════════════════════════════════════════════════════
// DATA GATHERING
// FIX 1: simple string parameter type for request.security()
// FIX 2: day-change uses math.floor(t/86400000) on the
//         returned time series, not the chart symbol's time()
// ═══════════════════════════════════════════════════════════
f_wrap(simple string sym) =>
    [o, h, l, c, v, t] = request.security(sym, timeframe.period,
         [open, high, low, close, volume, time],
         lookahead=barmerge.lookahead_off)
    float src = (o + h + l + c) / 4
    // FIX 1: use the returned time series t for day detection,
    // not the chart symbol's time boundary
    bool nd  = ta.change(math.floor(t / 86400000)) != 0
    bool r_s = not na(time(timeframe.period, i_rth_session, "America/New_York"))
    bool r_o = r_s and not r_s[1]
    [gv, gu, gd] = f_globex_vwap(src, v, nd, i_band_mult)
    [rv, ru, rd] = f_rth_vwap(src, v, r_s, r_o, i_band_mult)
    [c, gv, gu, gd, rv, ru, rd, r_s]

[nq_c, nq_gv, nq_gu, nq_gd, nq_rv, nq_ru, nq_rd, nq_r_s] = f_wrap(i_nq_sym)
[es_c, es_gv, es_gu, es_gd, es_rv, es_ru, es_rd, es_r_s] = f_wrap(i_es_sym)
[ym_c, ym_gv, ym_gu, ym_gd, ym_rv, ym_ru, ym_rd, ym_r_s] = f_wrap(i_ym_sym)

// ═══════════════════════════════════════════════════════════
// CELL HELPER
// FIX: added i_inval_col for "In Value" so it shows in blue
//      rather than inheriting the above/below VWAP color
// ═══════════════════════════════════════════════════════════
f_cell_v(float c, float v, float u, float d, bool s) =>
    string dr = "—", string ds = "—", string ex = "—"
    color  cl = i_na_col, color ex_col = i_na_col
    if s and not na(v)
        dr    := c >= v ? "▲" : "▼"
        cl    := c >= v ? i_above_col : i_below_col
        ds    := (c - v >= 0 ? "+" : "") + str.tostring(c - v, format.mintick)
        if not na(u) and not na(d)
            if c > u
                ex := "+" + str.tostring(c - u, format.mintick)
                cl := i_ext_col, ex_col := i_ext_col
            else if c < d
                ex := "-" + str.tostring(d - c, format.mintick)
                cl := i_ext_col, ex_col := i_ext_col
            else
                ex := "In Value", ex_col := i_inval_col
    [dr, ds, ex, cl, ex_col]

// ═══════════════════════════════════════════════════════════
// TABLE GENERATION
// FIX 2: table guarded with if na(dash) so it is only created
//         once, not leaked on every realtime tick
// FIX 3: table.merge_cells called BEFORE table.cell content
//         so header text is not wiped by the merge
// FIX 4: table changed from 6 rows to 5 (row 5 was empty)
// ═══════════════════════════════════════════════════════════
var table dash = na

if barstate.islast
    ts    = i_text_size == "tiny" ? size.tiny : i_text_size == "small" ? size.small : i_text_size == "large" ? size.large : size.normal
    t_pos = i_pos == "Top Left" ? position.top_left : i_pos == "Bottom Right" ? position.bottom_right : i_pos == "Bottom Left" ? position.bottom_left : position.top_right
    color dim = color.new(color.white, 50)

    // FIX 2: only create the table once
    if na(dash)
        dash := table.new(t_pos, 7, 5,
             border_color=color.new(color.gray, 60),
             border_width=1,
             frame_color=color.new(color.gray, 40),
             frame_width=1)

    // ── Row 0: Primary Headers ───────────────────────────────
    // FIX 3: merge_cells BEFORE writing cell content
    table.merge_cells(dash, 1, 0, 3, 0)
    table.merge_cells(dash, 4, 0, 6, 0)
    table.cell(dash, 0, 0, "Symbol",       bgcolor=i_header_col, text_color=color.white, text_size=ts, text_halign=text.align_center)
    table.cell(dash, 1, 0, "Globex VWAP",  bgcolor=i_header_col, text_color=color.white, text_size=ts, text_halign=text.align_center)
    table.cell(dash, 4, 0, "RTH VWAP",     bgcolor=i_header_col, text_color=color.white, text_size=ts, text_halign=text.align_center)

    // ── Row 1: Sub-Headers ───────────────────────────────────
    table.cell(dash, 0, 1, "", bgcolor=i_subhdr_col)
    string[] lbls = array.from("Dir", "Dist", "Ext", "Dir", "Dist", "Ext")
    for i = 0 to 5
        table.cell(dash, i + 1, 1, array.get(lbls, i),
             bgcolor=i_subhdr_col, text_color=dim, text_size=ts,
             text_halign=text.align_center)

    // ── Rows 2-4: Data ───────────────────────────────────────
    string[] syms = array.from("NQ", "ES", "YM")

    float[] g_vs = array.from(nq_gv, es_gv, ym_gv)
    float[] g_us = array.from(nq_gu, es_gu, ym_gu)
    float[] g_ds = array.from(nq_gd, es_gd, ym_gd)
    float[] r_vs = array.from(nq_rv, es_rv, ym_rv)
    float[] r_us = array.from(nq_ru, es_ru, ym_ru)
    float[] r_ds = array.from(nq_rd, es_rd, ym_rd)
    float[] cls  = array.from(nq_c,  es_c,  ym_c)
    bool[]  r_ss = array.from(nq_r_s, es_r_s, ym_r_s)

    for i = 0 to 2
        int   row   = i + 2
        float cur_c = array.get(cls, i)
        color bg    = color.new(i_bg_col, 90)

        table.cell(dash, 0, row, array.get(syms, i),
             bgcolor=i_subhdr_col, text_color=color.white,
             text_size=ts, text_halign=text.align_center)

        // Globex
        [gd, gs, gx, gc, gxc] = f_cell_v(cur_c,
             array.get(g_vs, i), array.get(g_us, i), array.get(g_ds, i), true)
        table.cell(dash, 1, row, gd,
             bgcolor=color.new(gc, 75), text_color=color.white,
             text_size=ts, text_halign=text.align_center)
        table.cell(dash, 2, row, gs,
             bgcolor=bg, text_color=gc,
             text_size=ts, text_halign=text.align_right)
        table.cell(dash, 3, row, gx,
             bgcolor=bg, text_color=gxc,
             text_size=ts, text_halign=text.align_right)

        // RTH
        bool in_rth = array.get(r_ss, i)
        [rd, rs, rx, rc, rxc] = f_cell_v(cur_c,
             array.get(r_vs, i), array.get(r_us, i), array.get(r_ds, i), in_rth)
        table.cell(dash, 4, row, rd,
             bgcolor=color.new(rc, 75), text_color=color.white,
             text_size=ts, text_halign=text.align_center)
        table.cell(dash, 5, row, rs,
             bgcolor=bg, text_color=rc,
             text_size=ts, text_halign=text.align_right)
        table.cell(dash, 6, row, rx,
             bgcolor=bg, text_color=rxc,
             text_size=ts, text_halign=text.align_right)
````

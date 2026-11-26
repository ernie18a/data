# Bolsacava Stats FunOntheRide

- url: https://www.tradingview.com/script/MqTRo0zb/
- type: indicator
- pine_id: PUB;437328f97f4b460e8d77310177f04577
- version: 1.0

## Description

Educational indicator created by Fun on the Ride / CryptoNews.

This script was built as a learning exercise after watching a public video by Bolsacava, where several intraday ideas about the E-mini S&P 500 futures contract (ES1!) were discussed.

The purpose of this publication is not to claim ownership of those ideas, impersonate Bolsacava, or present this as an official Bolsacava tool. It is an independent educational Pine Script project designed to show how recurring market claims can be translated into measurable statistics using 30-minute ES1! bars.

The goal is simple: learn, test, and verify.

Instead of assuming that a pattern works because it is often repeated, this tool checks how frequently it has actually occurred across recent historical sessions.

What the indicator shows

The script displays a compact on-chart table with the historical hit-rate of each pattern across three rolling windows:

- 20 sessions: short-term behaviour
- 60 sessions: medium-term context
- 120 sessions: broader baseline

This allows traders to compare whether a pattern is currently persistent, fading, or highly dependent on the selected sample size.

Patterns audited

The indicator tracks five ES1! intraday hypotheses:

H1 — Range-bound open between 15:30 and 17:00 Madrid time
H2 — Sell-off around the European close, from 17:00 to 18:00
H3 — Low-volatility window between 18:00 and 21:00
H4 — Volatility expansion between 20:00 and 21:00
H5 — Last-hour directional drift from 21:00 to 22:00

All times are referenced in Madrid local time. The calculations are based on bar timestamps and defined intraday windows.

Optional filters

The script can also recompute the statistics on a cleaner sample by excluding sessions affected by potentially anomalous events:

- CPI release days
- FOMC meeting days
- Extreme sessions, defined by unusually large range or volume

Comparing filtered and unfiltered results helps reveal whether a pattern is robust across normal sessions or mainly supported by outlier days.

How to interpret it

A higher percentage means that the pattern occurred more often within the selected rolling window.

This indicator does not provide buy signals, sell signals, stop-loss levels, take-profit levels, or position sizing. It is not a trading strategy.

It is a statistical screener designed to help traders test market narratives before using them as decision-making inputs.

Important notes

- Built for CME_MINI:ES1! on the 30-minute timeframe.
- Results may not translate to other symbols, sessions, or timeframes.
- The development sample covered approximately 600 historical sessions.
- Hit-rates will change over time as new sessions enter the rolling windows.
- Past frequency does not imply future reliability.

Attribution note

This is an independent educational project by Fun on the Ride / CryptoNews, inspired by a public Bolsacava video. It is not affiliated with, endorsed by, or officially published by Bolsacava.

The aim is to learn Pine Script, practice statistical thinking, and explore how trading narratives can be tested with data.

Disclaimer

This script is for educational and statistical research purposes only. It is not financial advice, does not recommend any trade, and makes no claim of profitability.

Open-source publication

The code is open-source so that users can inspect the logic, verify the calculations, adapt the hypotheses, and suggest improvements.

## Source Code

````pine
//@version=6
indicator("Bolsacava Stats — ES1! 30m + Filtros", overlay=false, max_labels_count=500)

// ===== INPUTS PRINCIPALES =====
g_main = "Configuración"
n_short = input.int(20,  "Sesiones cercano", group=g_main)
n_mid   = input.int(60,  "Sesiones amplio", group=g_main)
n_long  = input.int(120, "Sesiones extra-largo", group=g_main)
thr_lat = input.float(0.5, "H1: lateral si body/range <", minval=0.1, maxval=1.0, step=0.05, group=g_main)
thr_val = input.float(70.0, "% validada >=", step=1, group=g_main)
thr_par = input.float(50.0, "% parcial >=",  step=1, group=g_main)

// ===== FILTROS MACRO =====
g_filt = "Filtros macro (sesiones a excluir)"
use_witching = input.bool(true, "Excluir 3er viernes Mar/Jun/Sep/Dic (vencimientos)", group=g_filt)
use_cpi      = input.bool(true, "Excluir días CPI", group=g_filt)
cpi_dates    = input.string("2024-01-11,2024-02-13,2024-03-12,2024-04-10,2024-05-15,2024-06-12,2024-07-11,2024-08-14,2024-09-11,2024-10-10,2024-11-13,2024-12-11,2025-01-15,2025-02-12,2025-03-12,2025-04-10,2025-05-13,2025-06-11,2025-07-15,2025-08-12,2025-09-11,2025-10-15,2025-11-13,2025-12-10,2026-01-14,2026-02-11,2026-03-11,2026-04-10,2026-05-13", "Fechas CPI (YYYY-MM-DD,...)", group=g_filt)
use_fomc     = input.bool(true, "Excluir días FOMC", group=g_filt)
fomc_dates   = input.string("2024-01-31,2024-03-20,2024-05-01,2024-06-12,2024-07-31,2024-09-18,2024-11-07,2024-12-18,2025-01-29,2025-03-19,2025-05-07,2025-06-18,2025-07-30,2025-09-17,2025-10-29,2025-12-10,2026-01-28,2026-03-18,2026-05-06", "Fechas FOMC (YYYY-MM-DD,...)", group=g_filt)
use_extreme  = input.bool(true, "Excluir sesiones con rango RTH extremo", group=g_filt)
thr_extreme  = input.float(2.0, "Múltiplo SMA20 rango RTH (>)", step=0.1, group=g_filt)

// ===== FRANJAS MADRID =====
mh   = hour(time, "Europe/Madrid")
mm   = minute(time, "Europe/Madrid")
mins = mh * 60 + mm

f1 = mins >= 930  and mins < 1020
f2 = mins >= 1020 and mins < 1080
f3 = mins >= 1080 and mins < 1200
f4 = mins >= 1200 and mins < 1260
f5 = mins >= 1260 and mins < 1320
in_rth = f1 or f2 or f3 or f4 or f5

new_session = f1 and not f1[1]

// ===== ACUMULADORES POR SESIÓN =====
var float s_f1_high      = na
var float s_f1_low       = na
var float s_f1_open      = na
var float s_f1_close     = na
var float s_f1_range_sum = 0.0
var int   s_f1_bars      = 0
var float s_f2_open  = na
var float s_f2_close = na
var float s_f3_range_sum = 0.0
var int   s_f3_bars      = 0
var float s_f3_vol_sum   = 0.0
var float s_f4_vol_sum = 0.0
var int   s_f4_bars    = 0
var float s_f5_vol_sum   = 0.0
var float s_f5_range_sum = 0.0
var int   s_f5_bars      = 0
var float s_total_vol_sum   = 0.0
var float s_total_range_sum = 0.0
var int   s_total_bars      = 0
var float s_sess_high  = na
var float s_sess_low   = na
var int   s_sess_start = 0

// ===== HISTORIAL SIN/CON FILTRO =====
var array<bool>  h1_all = array.new<bool>()
var array<bool>  h2_all = array.new<bool>()
var array<bool>  h3_all = array.new<bool>()
var array<bool>  h4_all = array.new<bool>()
var array<bool>  h5_all = array.new<bool>()
var array<bool>  h1_flt = array.new<bool>()
var array<bool>  h2_flt = array.new<bool>()
var array<bool>  h3_flt = array.new<bool>()
var array<bool>  h4_flt = array.new<bool>()
var array<bool>  h5_flt = array.new<bool>()
var array<float> sess_range_arr = array.new<float>()

// ===== LÓGICA POR BARRA =====
if new_session
    if s_total_bars > 0 and s_sess_start > 0
        // Hipótesis de la sesión que acaba de cerrar
        f1_range = s_f1_high - s_f1_low
        f1_body  = math.abs(s_f1_close - s_f1_open)
        h1v = f1_range > 0 ? (f1_body / f1_range) < thr_lat : false
        h2v = not na(s_f2_open) and not na(s_f2_close) and s_f2_close < s_f2_open
        f1_ar = s_f1_bars > 0 ? s_f1_range_sum / s_f1_bars : 0.0
        f3_ar = s_f3_bars > 0 ? s_f3_range_sum / s_f3_bars : 0.0
        h3v = f1_ar > 0 and s_f3_bars > 0 and f3_ar < f1_ar
        f3_av = s_f3_bars > 0 ? s_f3_vol_sum / s_f3_bars : 0.0
        f4_av = s_f4_bars > 0 ? s_f4_vol_sum / s_f4_bars : 0.0
        h4v = f3_av > 0 and f4_av > f3_av
        f5_av = s_f5_bars > 0 ? s_f5_vol_sum / s_f5_bars : 0.0
        tt_av = s_total_bars > 0 ? s_total_vol_sum / s_total_bars : 0.0
        h5v = tt_av > 0 and f5_av > tt_av

        array.push(h1_all, h1v)
        array.push(h2_all, h2v)
        array.push(h3_all, h3v)
        array.push(h4_all, h4v)
        array.push(h5_all, h5v)

        // Evaluar exclusión de la sesión previa
        prev_y   = year(s_sess_start, "Europe/Madrid")
        prev_m   = month(s_sess_start, "Europe/Madrid")
        prev_d   = dayofmonth(s_sess_start, "Europe/Madrid")
        prev_dow = dayofweek(s_sess_start, "Europe/Madrid")

        excluded = false

        if use_witching
            is_3rd_fri = prev_dow == dayofweek.friday and prev_d >= 15 and prev_d <= 21
            is_qm = prev_m == 3 or prev_m == 6 or prev_m == 9 or prev_m == 12
            if is_3rd_fri and is_qm
                excluded := true

        date_iso = str.format("{0,number,0000}-{1,number,00}-{2,number,00}", prev_y, prev_m, prev_d)

        if use_cpi and not excluded
            if str.contains(cpi_dates, date_iso)
                excluded := true
        if use_fomc and not excluded
            if str.contains(fomc_dates, date_iso)
                excluded := true

        // Rango extremo: rango RTH sesión vs SMA del histórico
        sess_range = na(s_sess_high) or na(s_sess_low) ? na : s_sess_high - s_sess_low
        if use_extreme and not na(sess_range) and not excluded
            n = array.size(sess_range_arr)
            if n >= 5
                lookback = math.min(20, n)
                sum_r = 0.0
                for i = n - lookback to n - 1
                    sum_r := sum_r + array.get(sess_range_arr, i)
                avg_r = sum_r / lookback
                if avg_r > 0 and sess_range > thr_extreme * avg_r
                    excluded := true

        if not na(sess_range)
            array.push(sess_range_arr, sess_range)

        if not excluded
            array.push(h1_flt, h1v)
            array.push(h2_flt, h2v)
            array.push(h3_flt, h3v)
            array.push(h4_flt, h4v)
            array.push(h5_flt, h5v)

    // Reset para nueva sesión
    s_f1_high := high
    s_f1_low := low
    s_f1_open := open
    s_f1_close := close
    s_f1_range_sum := high - low
    s_f1_bars := 1
    s_f2_open := na
    s_f2_close := na
    s_f3_range_sum := 0.0
    s_f3_bars := 0
    s_f3_vol_sum := 0.0
    s_f4_vol_sum := 0.0
    s_f4_bars := 0
    s_f5_vol_sum := 0.0
    s_f5_range_sum := 0.0
    s_f5_bars := 0
    s_total_vol_sum := volume
    s_total_range_sum := high - low
    s_total_bars := 1
    s_sess_high := high
    s_sess_low := low
    s_sess_start := time
else if in_rth
    if f1
        s_f1_high := math.max(s_f1_high, high)
        s_f1_low := math.min(s_f1_low, low)
        s_f1_close := close
        s_f1_range_sum := s_f1_range_sum + (high - low)
        s_f1_bars := s_f1_bars + 1
    if f2
        if na(s_f2_open)
            s_f2_open := open
        s_f2_close := close
    if f3
        s_f3_range_sum := s_f3_range_sum + (high - low)
        s_f3_bars := s_f3_bars + 1
        s_f3_vol_sum := s_f3_vol_sum + volume
    if f4
        s_f4_vol_sum := s_f4_vol_sum + volume
        s_f4_bars := s_f4_bars + 1
    if f5
        s_f5_vol_sum := s_f5_vol_sum + volume
        s_f5_range_sum := s_f5_range_sum + (high - low)
        s_f5_bars := s_f5_bars + 1
    s_total_vol_sum := s_total_vol_sum + volume
    s_total_range_sum := s_total_range_sum + (high - low)
    s_total_bars := s_total_bars + 1
    s_sess_high := math.max(s_sess_high, high)
    s_sess_low := math.min(s_sess_low, low)

// ===== HELPERS =====
pct_n(array<bool> arr, int n) =>
    sz = array.size(arr)
    a  = math.min(sz, n)
    out = float(na)
    if a > 0
        c = 0
        for i = sz - a to sz - 1
            if array.get(arr, i)
                c += 1
        out := 100.0 * c / a
    out

verd(float p) =>
    na(p) ? "—" : p >= thr_val ? "VAL" : p >= thr_par ? "PAR" : "NO"

vcol(float p) =>
    na(p) ? color.rgb(60, 60, 70) : p >= thr_val ? color.rgb(30, 110, 55) : p >= thr_par ? color.rgb(180, 115, 30) : color.rgb(160, 45, 45)

fmt(float p) =>
    na(p) ? "—" : str.tostring(p, "#.0") + "%"

fmt_delta(float pa, float pf) =>
    na(pa) or na(pf) ? "—" : (pf - pa > 0 ? "+" : "") + str.tostring(pf - pa, "#.0")

dcol(float pa, float pf) =>
    if na(pa) or na(pf)
        color.rgb(60, 60, 70)
    else
        d = pf - pa
        math.abs(d) < 2 ? color.rgb(60, 60, 70) : (d > 0 ? color.rgb(30, 100, 55) : color.rgb(160, 45, 45))

// ===== TABLA =====
var table tbl = table.new(position.top_right, 8, 9, border_width=2, frame_color=color.rgb(140, 145, 155), frame_width=2)

c_title    = color.rgb(45, 50, 60)
c_sessions = color.rgb(40, 45, 55)
c_filters  = color.rgb(28, 32, 42)
c_subheadr = color.rgb(25, 45, 80)
c_grpA     = color.rgb(55, 65, 85)
c_grpB     = color.rgb(15, 80, 75)
c_brand    = color.rgb(75, 35, 110)
c_text     = color.white
c_text2    = color.rgb(220, 222, 230)
c_text3    = color.rgb(190, 195, 205)
c_border   = color.rgb(90, 95, 110)

row_render(int r, string title, array<bool> arr_a, array<bool> arr_f) =>
    p20a  = pct_n(arr_a, n_short)
    p60a  = pct_n(arr_a, n_mid)
    p120a = pct_n(arr_a, n_long)
    p20f  = pct_n(arr_f, n_short)
    p60f  = pct_n(arr_f, n_mid)
    p120f = pct_n(arr_f, n_long)
    table.cell(tbl, 0, r, title,                   bgcolor=c_title,             text_color=c_text, text_size=size.small)
    table.cell(tbl, 1, r, fmt(p20a),               bgcolor=vcol(p20a),          text_color=c_text, text_size=size.small)
    table.cell(tbl, 2, r, fmt(p60a),               bgcolor=vcol(p60a),          text_color=c_text, text_size=size.small)
    table.cell(tbl, 3, r, fmt(p120a),              bgcolor=vcol(p120a),         text_color=c_text, text_size=size.small)
    table.cell(tbl, 4, r, fmt(p20f),               bgcolor=vcol(p20f),          text_color=c_text, text_size=size.small)
    table.cell(tbl, 5, r, fmt(p60f),               bgcolor=vcol(p60f),          text_color=c_text, text_size=size.small)
    table.cell(tbl, 6, r, fmt(p120f),              bgcolor=vcol(p120f),         text_color=c_text, text_size=size.small)
    table.cell(tbl, 7, r, fmt_delta(p120a, p120f), bgcolor=dcol(p120a, p120f),  text_color=c_text, text_size=size.small)

if barstate.islast
    table.cell(tbl, 0, 0, "Bolsacava — ES1! 30m", bgcolor=c_brand, text_color=c_text, text_size=size.normal)
    table.cell(tbl, 1, 0, "SIN FILTROS",          bgcolor=c_grpA,  text_color=c_text, text_size=size.normal)
    table.cell(tbl, 2, 0, "",                     bgcolor=c_grpA)
    table.cell(tbl, 3, 0, "",                     bgcolor=c_grpA)
    table.cell(tbl, 4, 0, "FILTRADO",             bgcolor=c_grpB,  text_color=c_text, text_size=size.normal)
    table.cell(tbl, 5, 0, "",                     bgcolor=c_grpB)
    table.cell(tbl, 6, 0, "",                     bgcolor=c_grpB)
    table.cell(tbl, 7, 0, "Δ120",                 bgcolor=c_brand, text_color=c_text, text_size=size.normal)

    table.cell(tbl, 0, 1, "Hipótesis", bgcolor=c_subheadr, text_color=c_text, text_size=size.normal)
    table.cell(tbl, 1, 1, "20s",       bgcolor=c_subheadr, text_color=c_text, text_size=size.normal)
    table.cell(tbl, 2, 1, "60s",       bgcolor=c_subheadr, text_color=c_text, text_size=size.normal)
    table.cell(tbl, 3, 1, "120s",      bgcolor=c_subheadr, text_color=c_text, text_size=size.normal)
    table.cell(tbl, 4, 1, "20s",       bgcolor=c_subheadr, text_color=c_text, text_size=size.normal)
    table.cell(tbl, 5, 1, "60s",       bgcolor=c_subheadr, text_color=c_text, text_size=size.normal)
    table.cell(tbl, 6, 1, "120s",      bgcolor=c_subheadr, text_color=c_text, text_size=size.normal)
    table.cell(tbl, 7, 1, "%pts",      bgcolor=c_subheadr, text_color=c_text, text_size=size.normal)

    row_render(2, "H1 Apert lateral 15:30-17", h1_all, h1_flt)
    row_render(3, "H2 Caída cierre EU 17-18",  h2_all, h2_flt)
    row_render(4, "H3 Vol baja 18-20",         h3_all, h3_flt)
    row_render(5, "H4 Vol sube 20-21",         h4_all, h4_flt)
    row_render(6, "H5 Última h pesa 21-22",    h5_all, h5_flt)

    total_a = array.size(h1_all)
    total_f = array.size(h1_flt)
    excl_n  = total_a - total_f
    table.cell(tbl, 0, 7, "Sesiones",                   bgcolor=c_sessions, text_color=c_text2, text_size=size.small)
    table.cell(tbl, 1, 7, "N=" + str.tostring(total_a), bgcolor=c_sessions, text_color=c_text2, text_size=size.small)
    table.cell(tbl, 2, 7, "",                           bgcolor=c_sessions)
    table.cell(tbl, 3, 7, "",                           bgcolor=c_sessions)
    table.cell(tbl, 4, 7, "N=" + str.tostring(total_f), bgcolor=c_sessions, text_color=c_text2, text_size=size.small)
    table.cell(tbl, 5, 7, "",                           bgcolor=c_sessions)
    table.cell(tbl, 6, 7, "",                           bgcolor=c_sessions)
    table.cell(tbl, 7, 7, "-" + str.tostring(excl_n),   bgcolor=c_sessions, text_color=c_text2, text_size=size.small)

    flt_summary = (use_witching ? "Wch " : "") + (use_cpi ? "CPI " : "") + (use_fomc ? "FOMC " : "") + (use_extreme ? "Extr>" + str.tostring(thr_extreme, "#.#") + "x" : "")
    table.cell(tbl, 0, 8, "Filtros",   bgcolor=c_filters, text_color=c_text3, text_size=size.small)
    table.cell(tbl, 1, 8, flt_summary, bgcolor=c_filters, text_color=c_text3, text_size=size.small)
    table.cell(tbl, 2, 8, "",          bgcolor=c_filters)
    table.cell(tbl, 3, 8, "",          bgcolor=c_filters)
    table.cell(tbl, 4, 8, "",          bgcolor=c_filters)
    table.cell(tbl, 5, 8, "",          bgcolor=c_filters)
    table.cell(tbl, 6, 8, "",          bgcolor=c_filters)
    table.cell(tbl, 7, 8, "",          bgcolor=c_filters)
````

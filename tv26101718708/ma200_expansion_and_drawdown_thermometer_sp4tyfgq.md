# MA200 Expansion and Drawdown Thermometer

- url: https://www.tradingview.com/script/sP4tYFgQ/
- type: indicator
- pine_id: PUB;65cb7181a5b9490e985ecb5d76f41993
- version: 1.0

## Description

MA200 Expansion & Drawdown Thermometer
Overview

This indicator measures and classifies every historical price cycle above and below a moving average, building a statistical thermometer that tells you — in real time — how extended the current move is relative to all past cycles.

How It Works

Every time price crosses above the selected moving average, the script opens a new expansion cycle and tracks the maximum percentage distance the HIGH reaches from the MA before price closes back below it. Symmetrically, every time price crosses below the MA, a drawdown cycle begins and tracks how far the LOW drops before price recovers. When each cycle ends, its peak expansion (or drawdown) percentage is stored in a historical array.

Thermometer Lines

At the right edge of the chart, three horizontal dashed lines project forward from the current MA value:

🔺 EXP MAX — the largest upside expansion ever recorded in the selected period

⚠️ EXP 75%ile — the 75th percentile of all historical expansions

📊 EXP AVG — the average expansion across all cycles

The same three levels are mirrored below the MA for drawdown cycles (blue/purple palette). Coloured fill zones between the lines create an intuitive heat-map: yellow → orange → red for upside risk, teal → purple → blue for downside risk.

Live Cycle Label

When price is currently in an active cycle, a label on the latest bar shows:

Maximum % reached so far in this cycle

Current close % distance from the MA

Remaining headroom to the historical maximum

Historical Table

A compact side table displays:

Period indicator — shows whether you are viewing the full history or a custom lookback window

Top N expansions (ranked, colour-coded by intensity vs. average and 75th percentile)

Top N drawdowns (same logic, mirrored below a divider)

Average and MAX summary for both sections

LIVE row (highlighted in yellow) when a cycle is currently active

Settings

Parameter	Description
MA Length	Period of the moving average (default 200)
MA Type	SMA / EMA / WMA / HMA
Anni di storico	Lookback window in years — 0 = full history
Top N per sezione	How many ranked cycles to show in the table
Table Position	Top/Bottom × Left/Right
Background tint	Subtle colour fill above/below the MA
Coloured zones	Toggle the thermometer fill bands

## Source Code

````pine
//@version=6
indicator("MA200 Expansion and Drawdown Thermometer", overlay=true, max_labels_count=500, max_lines_count=500)

// ══════════════════════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════════════════════
ma_len       = input.int(200,            "MA Length",                      minval=1)
ma_src       = input.source(close,       "MA Source")
ma_type      = input.string("SMA",       "MA Type",                        options=["SMA","EMA","WMA","HMA"])
lookback_yrs = input.int(0,              "Anni di storico (0 = tutto)",    minval=0, maxval=100)
top_rows     = input.int(8,              "Top N per sezione",              minval=1, maxval=20)
tbl_pos      = input.string("Top Right", "Posizione tabella",              options=["Top Right","Top Left","Bottom Right","Bottom Left"])
show_bg      = input.bool(true,          "Sfondo sopra/sotto MA")
show_tbl     = input.bool(true,          "Mostra tabella")
show_zones   = input.bool(true,          "Mostra zone colorate")

// ══════════════════════════════════════════════════════════════
//  MEDIA MOBILE
// ══════════════════════════════════════════════════════════════
float ma = switch ma_type
    "EMA" => ta.ema(ma_src, ma_len)
    "WMA" => ta.wma(ma_src, ma_len)
    "HMA" => ta.hma(ma_src, ma_len)
    =>       ta.sma(ma_src, ma_len)

plot(ma, "MA200", color=color.new(color.orange, 0), linewidth=2)

// ══════════════════════════════════════════════════════════════
//  CUTOFF TEMPORALE
//  ms_per_year = 365 * 24 * 3600 * 1000  (interi 64-bit, nessun overflow)
// ══════════════════════════════════════════════════════════════
int ms_per_year = 365 * 24 * 3600 * 1000
int cutoff_ms   = lookback_yrs > 0 ? timenow - lookback_yrs * ms_per_year : 0

// ══════════════════════════════════════════════════════════════
//  STATO SOPRA / SOTTO MA
// ══════════════════════════════════════════════════════════════
bool above      = not na(ma) and close > ma
bool cross_up   = above and not above[1]
bool cross_down = not above and above[1]

// ══════════════════════════════════════════════════════════════
//  RACCOLTA CICLI — ESPANSIONE (sopra MA, usa HIGH)
// ══════════════════════════════════════════════════════════════
var float   sess_max  = 0.0
var float[] hist_vals = array.new_float(0)
var int[]   hist_time = array.new_int(0)

float pct_h = above ? (high  - ma) / ma * 100 : 0.0
float pct_c = above ? (close - ma) / ma * 100 : 0.0

if cross_up
    sess_max := 0.0
if above and pct_h > sess_max
    sess_max := pct_h
if cross_down and sess_max > 0
    array.push(hist_vals, sess_max)
    array.push(hist_time, time[1])
    sess_max := 0.0

// ══════════════════════════════════════════════════════════════
//  RACCOLTA CICLI — DRAWDOWN (sotto MA, usa LOW)
// ══════════════════════════════════════════════════════════════
var float   sess_dd   = 0.0
var float[] hist_dd   = array.new_float(0)
var int[]   hist_dd_t = array.new_int(0)

float dd_l = (not above and not na(ma)) ? (ma - low)   / ma * 100 : 0.0
float dd_c = (not above and not na(ma)) ? (ma - close) / ma * 100 : 0.0

if cross_down
    sess_dd := 0.0
if not above and not na(ma) and dd_l > sess_dd
    sess_dd := dd_l
if cross_up and sess_dd > 0
    array.push(hist_dd,   sess_dd)
    array.push(hist_dd_t, time[1])
    sess_dd := 0.0

// ══════════════════════════════════════════════════════════════
//  FILTRO TEMPORALE + STATISTICHE
//  Filtra gli array in base all'intervallo scelto
// ══════════════════════════════════════════════════════════════
int   n_all_e = array.size(hist_vals)
int   n_all_d = array.size(hist_dd)

// Arrays filtrati — ricostruiti sull'ultimo bar
var float[] filt_e_vals = array.new_float(0)
var int[]   filt_e_time = array.new_int(0)
var float[] filt_d_vals = array.new_float(0)
var int[]   filt_d_time = array.new_int(0)

if barstate.islast
    array.clear(filt_e_vals)
    array.clear(filt_e_time)
    array.clear(filt_d_vals)
    array.clear(filt_d_time)

    if n_all_e > 0
        for i = 0 to n_all_e - 1
            if array.get(hist_time, i) >= cutoff_ms
                array.push(filt_e_vals, array.get(hist_vals, i))
                array.push(filt_e_time, array.get(hist_time, i))

    if n_all_d > 0
        for i = 0 to n_all_d - 1
            if array.get(hist_dd_t, i) >= cutoff_ms
                array.push(filt_d_vals, array.get(hist_dd, i))
                array.push(filt_d_time, array.get(hist_dd_t, i))

int   n_cyc  = array.size(filt_e_vals)
float h_max  = n_cyc > 0 ? array.max(filt_e_vals) : 0.0
float h_avg  = n_cyc > 0 ? array.avg(filt_e_vals) : 0.0
float h_p75  = 0.0
if n_cyc >= 4
    float[] sc = array.copy(filt_e_vals)
    array.sort(sc, order.ascending)
    h_p75 := array.get(sc, math.min(math.max(0, math.round(n_cyc * 0.75) - 1), n_cyc - 1))

int   n_dd   = array.size(filt_d_vals)
float dd_max = n_dd > 0 ? array.max(filt_d_vals) : 0.0
float dd_avg = n_dd > 0 ? array.avg(filt_d_vals) : 0.0
float dd_p75 = 0.0
if n_dd >= 4
    float[] sc2 = array.copy(filt_d_vals)
    array.sort(sc2, order.ascending)
    dd_p75 := array.get(sc2, math.min(math.max(0, math.round(n_dd * 0.75) - 1), n_dd - 1))

// ══════════════════════════════════════════════════════════════
//  BACKGROUND
// ══════════════════════════════════════════════════════════════
bgcolor(show_bg and above                       ? color.new(color.teal, 92) : na, title="Sopra MA")
bgcolor(show_bg and not above and not na(ma)    ? color.new(color.red,  95) : na, title="Sotto MA")

// ══════════════════════════════════════════════════════════════
//  VARIABILI PERSISTENTI LINEE / LABEL / FILL
// ══════════════════════════════════════════════════════════════
var line     ln_max    = na
var line     ln_p75    = na
var line     ln_avg    = na
var line     ln_ddmax  = na
var line     ln_ddp75  = na
var line     ln_ddavg  = na
var label    lb_max    = na
var label    lb_p75    = na
var label    lb_avg    = na
var label    lb_cur    = na
var label    lb_ddmax  = na
var label    lb_ddp75  = na
var label    lb_ddavg  = na
var label    lb_ddcur  = na
var linefill lf_up     = na
var linefill lf_mid    = na
var linefill lf_dd_up  = na
var linefill lf_dd_mid = na

// ══════════════════════════════════════════════════════════════
//  DISEGNO TERMOMETRO
// ══════════════════════════════════════════════════════════════
if barstate.islast and not na(ma)
    line.delete(ln_max)
    line.delete(ln_p75)
    line.delete(ln_avg)
    line.delete(ln_ddmax)
    line.delete(ln_ddp75)
    line.delete(ln_ddavg)
    label.delete(lb_max)
    label.delete(lb_p75)
    label.delete(lb_avg)
    label.delete(lb_cur)
    label.delete(lb_ddmax)
    label.delete(lb_ddp75)
    label.delete(lb_ddavg)
    label.delete(lb_ddcur)
    linefill.delete(lf_up)
    linefill.delete(lf_mid)
    linefill.delete(lf_dd_up)
    linefill.delete(lf_dd_mid)

    int lx0 = bar_index - 50
    int lx1 = bar_index + 2

    // ── LINEE ESPANSIONE ─────────────────────────────────────
    if h_max > 0
        float pm = ma * (1.0 + h_max / 100.0)
        ln_max := line.new(lx0, pm, lx1, pm, color=color.new(color.red, 0), width=2, style=line.style_dashed)
        lb_max := label.new(lx1, pm, "EXP MAX: +" + str.tostring(h_max, "#.2f") + "%", color=color.new(color.red, 10), textcolor=color.white, style=label.style_label_left, size=size.small)

    if h_p75 > 0
        float pp = ma * (1.0 + h_p75 / 100.0)
        ln_p75 := line.new(lx0, pp, lx1, pp, color=color.new(color.orange, 0), width=1, style=line.style_dashed)
        lb_p75 := label.new(lx1, pp, "EXP 75%: +" + str.tostring(h_p75, "#.2f") + "%", color=color.new(color.orange, 10), textcolor=color.white, style=label.style_label_left, size=size.small)

    if h_avg > 0
        float pa = ma * (1.0 + h_avg / 100.0)
        ln_avg := line.new(lx0, pa, lx1, pa, color=color.new(color.yellow, 0), width=1, style=line.style_dotted)
        lb_avg := label.new(lx1, pa, "EXP AVG: +" + str.tostring(h_avg, "#.2f") + "%", color=color.new(color.yellow, 10), textcolor=color.black, style=label.style_label_left, size=size.small)

    // ── LINEE DRAWDOWN ───────────────────────────────────────
    if dd_max > 0
        float pdm = ma * (1.0 - dd_max / 100.0)
        ln_ddmax := line.new(lx0, pdm, lx1, pdm, color=color.new(color.blue, 0), width=2, style=line.style_dashed)
        lb_ddmax := label.new(lx1, pdm, "DD MAX: -" + str.tostring(dd_max, "#.2f") + "%", color=color.new(color.blue, 10), textcolor=color.white, style=label.style_label_left, size=size.small)

    if dd_p75 > 0
        float pdp = ma * (1.0 - dd_p75 / 100.0)
        ln_ddp75 := line.new(lx0, pdp, lx1, pdp, color=color.new(color.purple, 0), width=1, style=line.style_dashed)
        lb_ddp75 := label.new(lx1, pdp, "DD 75%: -" + str.tostring(dd_p75, "#.2f") + "%", color=color.new(color.purple, 10), textcolor=color.white, style=label.style_label_left, size=size.small)

    if dd_avg > 0
        float pda = ma * (1.0 - dd_avg / 100.0)
        ln_ddavg := line.new(lx0, pda, lx1, pda, color=color.new(color.teal, 0), width=1, style=line.style_dotted)
        lb_ddavg := label.new(lx1, pda, "DD AVG: -" + str.tostring(dd_avg, "#.2f") + "%", color=color.new(color.teal, 10), textcolor=color.white, style=label.style_label_left, size=size.small)

    // ── FILL ESPANSIONE ──────────────────────────────────────
    if show_zones
        if not na(ln_p75) and not na(ln_max)
            lf_up := linefill.new(ln_p75, ln_max, color.new(color.red, 82))
        if not na(ln_avg) and not na(ln_p75)
            lf_mid := linefill.new(ln_avg, ln_p75, color.new(color.orange, 82))
        else if na(ln_p75) and not na(ln_avg) and not na(ln_max)
            lf_mid := linefill.new(ln_avg, ln_max, color.new(color.orange, 82))

    // ── FILL DRAWDOWN ────────────────────────────────────────
    if show_zones
        if not na(ln_ddp75) and not na(ln_ddmax)
            lf_dd_up := linefill.new(ln_ddmax, ln_ddp75, color.new(color.blue, 82))
        if not na(ln_ddavg) and not na(ln_ddp75)
            lf_dd_mid := linefill.new(ln_ddp75, ln_ddavg, color.new(color.purple, 82))
        else if na(ln_ddp75) and not na(ln_ddavg) and not na(ln_ddmax)
            lf_dd_mid := linefill.new(ln_ddmax, ln_ddavg, color.new(color.purple, 82))

    // ── LABEL ESPANSIONE CORRENTE ────────────────────────────
    if above and (sess_max > 0 or pct_c > 0)
        string rem_e = h_max > 0 ? "\nSpazio al MAX: +" + str.tostring(h_max - sess_max, "#.2f") + "%" : ""
        lb_cur := label.new(bar_index, high, "Max ciclo: +" + str.tostring(sess_max, "#.2f") + "%\nClose now: +" + str.tostring(pct_c, "#.2f") + "%" + rem_e, color=color.new(color.teal, 10), textcolor=color.white, style=label.style_label_down, size=size.small)

    // ── LABEL DRAWDOWN CORRENTE ──────────────────────────────
    if not above and not na(ma) and (sess_dd > 0 or dd_c > 0)
        string rem_d = dd_max > 0 ? "\nSpazio al DD MAX: -" + str.tostring(dd_max - sess_dd, "#.2f") + "%" : ""
        lb_ddcur := label.new(bar_index, low, "DD ciclo: -" + str.tostring(sess_dd, "#.2f") + "%\nClose now: -" + str.tostring(dd_c, "#.2f") + "%" + rem_d, color=color.new(color.blue, 10), textcolor=color.white, style=label.style_label_up, size=size.small)

// ══════════════════════════════════════════════════════════════
//  TABELLA
// ══════════════════════════════════════════════════════════════
var table tbl = na

if barstate.islast and show_tbl
    // ── Sort espansioni filtrate (desc) ──────────────────────
    int[] idx_e = array.new_int(n_cyc, 0)
    if n_cyc > 0
        for i = 0 to n_cyc - 1
            array.set(idx_e, i, i)
        if n_cyc >= 2
            for i = 0 to n_cyc - 2
                for j = 0 to n_cyc - 2 - i
                    int a = array.get(idx_e, j)
                    int b = array.get(idx_e, j + 1)
                    if array.get(filt_e_vals, a) < array.get(filt_e_vals, b)
                        array.set(idx_e, j, b)
                        array.set(idx_e, j + 1, a)

    // ── Sort drawdown filtrati (desc) ────────────────────────
    int[] idx_d = array.new_int(n_dd, 0)
    if n_dd > 0
        for i = 0 to n_dd - 1
            array.set(idx_d, i, i)
        if n_dd >= 2
            for i = 0 to n_dd - 2
                for j = 0 to n_dd - 2 - i
                    int a = array.get(idx_d, j)
                    int b = array.get(idx_d, j + 1)
                    if array.get(filt_d_vals, a) < array.get(filt_d_vals, b)
                        array.set(idx_d, j, b)
                        array.set(idx_d, j + 1, a)

    bool has_e  = above and (sess_max > 0 or pct_c > 0)
    bool has_d  = not above and not na(ma) and (sess_dd > 0 or dd_c > 0)
    int  show_e = math.min(top_rows, n_cyc)
    int  show_d = math.min(top_rows, n_dd)

    // Intestazione periodo (lookback_yrs == 0 → "Tutto lo storico")
    string periodo = lookback_yrs > 0 ? "Ultimi " + str.tostring(lookback_yrs) + " anni" : "Tutto lo storico"

    int n_rows = 2 + (has_e ? 1 : 0) + show_e + (n_cyc > 0 ? 1 : 0) + 1 + 1 + (has_d ? 1 : 0) + show_d + (n_dd > 0 ? 1 : 0)
    if n_rows < 5
        n_rows := 5

    table.delete(tbl)
    simple string p = tbl_pos
    tbl := table.new(p == "Top Left" ? position.top_left : p == "Bottom Right" ? position.bottom_right : p == "Bottom Left" ? position.bottom_left : position.top_right, 3, n_rows, bgcolor=color.new(color.black, 22), border_color=color.new(color.gray, 55), border_width=1, frame_color=color.new(color.gray, 35), frame_width=1)

    int row = 0

    // ── RIGA PERIODO ─────────────────────────────────────────
    table.cell(tbl, 0, row, "Periodo:", bgcolor=color.new(color.gray, 40), text_color=color.white, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 1, row, periodo,    bgcolor=color.new(color.gray, 40), text_color=color.yellow, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 2, row, str.tostring(n_cyc) + "exp / " + str.tostring(n_dd) + "dd", bgcolor=color.new(color.gray, 40), text_color=color.white, text_size=size.small, text_halign=text.align_center)
    row := row + 1

    // ── HEADER ESPANSIONI ────────────────────────────────────
    table.cell(tbl, 0, row, "UP",         bgcolor=color.new(color.green, 60), text_color=color.white, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 1, row, "ESPANSIONE", bgcolor=color.new(color.green, 60), text_color=color.white, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 2, row, "FINE CICLO", bgcolor=color.new(color.green, 60), text_color=color.white, text_size=size.small, text_halign=text.align_center)
    row := row + 1

    if has_e
        table.cell(tbl, 0, row, "LIVE", bgcolor=color.new(color.teal, 20), text_color=color.yellow, text_size=size.small, text_halign=text.align_center)
        table.cell(tbl, 1, row, "+" + str.tostring(sess_max, "#.2f") + "%", bgcolor=color.new(color.teal, 20), text_color=color.yellow, text_size=size.small, text_halign=text.align_center)
        table.cell(tbl, 2, row, "In corso", bgcolor=color.new(color.teal, 20), text_color=color.yellow, text_size=size.small, text_halign=text.align_center)
        row := row + 1

    if show_e > 0
        for i = 0 to show_e - 1
            int    ii  = array.get(idx_e, i)
            float  v   = array.get(filt_e_vals, ii)
            int    t   = array.get(filt_e_time, ii)
            string ds  = str.format_time(t, "MMM yyyy", syminfo.timezone)
            color  rbg = (h_p75 > 0 and v >= h_p75) ? color.new(color.red, 32) : (h_avg > 0 and v >= h_avg) ? color.new(color.orange, 38) : color.new(color.green, 52)
            table.cell(tbl, 0, row, "#" + str.tostring(i + 1),           bgcolor=color.new(color.gray, 72), text_color=color.white, text_size=size.small, text_halign=text.align_center)
            table.cell(tbl, 1, row, "+" + str.tostring(v, "#.2f") + "%", bgcolor=rbg, text_color=color.white, text_size=size.small, text_halign=text.align_center)
            table.cell(tbl, 2, row, ds,                                   bgcolor=color.new(color.gray, 72), text_color=color.white, text_size=size.small, text_halign=text.align_center)
            row := row + 1

    if n_cyc > 0
        table.cell(tbl, 0, row, "AVG", bgcolor=color.new(color.green, 75), text_color=color.white, text_size=size.small, text_halign=text.align_center)
        table.cell(tbl, 1, row, "+" + str.tostring(h_avg, "#.2f") + "%  MAX+" + str.tostring(h_max, "#.2f") + "%", bgcolor=color.new(color.green, 75), text_color=color.white, text_size=size.small, text_halign=text.align_center)
        table.cell(tbl, 2, row, str.tostring(n_cyc) + " cicli", bgcolor=color.new(color.green, 75), text_color=color.white, text_size=size.small, text_halign=text.align_center)
        row := row + 1

    // ── DIVIDER ──────────────────────────────────────────────
    table.cell(tbl, 0, row, "",                    bgcolor=color.new(color.gray, 50), text_color=color.white, text_size=size.tiny, text_halign=text.align_center)
    table.cell(tbl, 1, row, "SOPRA MA | SOTTO MA", bgcolor=color.new(color.gray, 50), text_color=color.white, text_size=size.tiny, text_halign=text.align_center)
    table.cell(tbl, 2, row, "",                    bgcolor=color.new(color.gray, 50), text_color=color.white, text_size=size.tiny, text_halign=text.align_center)
    row := row + 1

    // ── HEADER DRAWDOWN ──────────────────────────────────────
    table.cell(tbl, 0, row, "DOWN",       bgcolor=color.new(color.blue, 60), text_color=color.white, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 1, row, "DRAWDOWN",   bgcolor=color.new(color.blue, 60), text_color=color.white, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 2, row, "FINE CICLO", bgcolor=color.new(color.blue, 60), text_color=color.white, text_size=size.small, text_halign=text.align_center)
    row := row + 1

    if has_d
        table.cell(tbl, 0, row, "LIVE", bgcolor=color.new(color.blue, 40), text_color=color.yellow, text_size=size.small, text_halign=text.align_center)
        table.cell(tbl, 1, row, "-" + str.tostring(sess_dd, "#.2f") + "%", bgcolor=color.new(color.blue, 40), text_color=color.yellow, text_size=size.small, text_halign=text.align_center)
        table.cell(tbl, 2, row, "In corso", bgcolor=color.new(color.blue, 40), text_color=color.yellow, text_size=size.small, text_halign=text.align_center)
        row := row + 1

    if show_d > 0
        for i = 0 to show_d - 1
            int    ii  = array.get(idx_d, i)
            float  v   = array.get(filt_d_vals, ii)
            int    t   = array.get(filt_d_time, ii)
            string ds  = str.format_time(t, "MMM yyyy", syminfo.timezone)
            color  rbg = (dd_p75 > 0 and v >= dd_p75) ? color.new(color.blue, 22) : (dd_avg > 0 and v >= dd_avg) ? color.new(color.purple, 32) : color.new(color.navy, 40)
            table.cell(tbl, 0, row, "#" + str.tostring(i + 1),           bgcolor=color.new(color.gray, 72), text_color=color.white, text_size=size.small, text_halign=text.align_center)
            table.cell(tbl, 1, row, "-" + str.tostring(v, "#.2f") + "%", bgcolor=rbg, text_color=color.white, text_size=size.small, text_halign=text.align_center)
            table.cell(tbl, 2, row, ds,                                   bgcolor=color.new(color.gray, 72), text_color=color.white, text_size=size.small, text_halign=text.align_center)
            row := row + 1

    if n_dd > 0
        table.cell(tbl, 0, row, "AVG", bgcolor=color.new(color.blue, 75), text_color=color.white, text_size=size.small, text_halign=text.align_center)
        table.cell(tbl, 1, row, "-" + str.tostring(dd_avg, "#.2f") + "%  MAX-" + str.tostring(dd_max, "#.2f") + "%", bgcolor=color.new(color.blue, 75), text_color=color.white, text_size=size.small, text_halign=text.align_center)
        table.cell(tbl, 2, row, str.tostring(n_dd) + " cicli", bgcolor=color.new(color.blue, 75), text_color=color.white, text_size=size.small, text_halign=text.align_center)
````

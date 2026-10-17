# Earnings Metrics Table

- url: https://www.tradingview.com/script/nb7CFMDL-Earnings-Metrics-Table/
- type: indicator
- pine_id: PUB;f6804928544540b081c830e2f6948283
- version: 2.0

## Description

Usefull table for a quick review of past earnings excluding EPS which I find pointless in my system.
All I care about is generated revenue and profits (Net Profit Margin). 
Additionally I show FCF / Free Cash Flow.
Number of past quarters rows is customizable, I keep it small and tight, 3 to four past quarters to support my buy/sell thesis.

Thanks Claude as always for the help since I am not a coder. 
:)

Other indicator in this example is "Performance" , usefull for quick past performance review.

Be safe. Marty

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © Marty_Bird92

//@version=5
indicator("Earnings Metrics Table", shorttitle="Earning metrics Table", overlay=true)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
int    i_rows      = input.int   (6,           "Quarters to show",  minval=3, maxval=8)
string i_pos       = input.string("top_right", "Table position",
     options=["top_right","top_left","top_center",
              "bottom_right","bottom_left","bottom_center",
              "middle_right","middle_left","middle_center"])
string i_size      = input.string("small", "Text size",
     options=["tiny","small","normal"])
bool   i_altrow    = input.bool(true,  "Alternate row shading")
bool   i_top_space = input.bool(true,  "Space above table")
bool   i_bot_space = input.bool(true,  "Space below table")
string i_npm_mode  = input.string("pp", "NPM QoQ/YoY display",
     options=["pp", "%"],
     tooltip="pp = absolute point difference (1.31pp)\n% = relative change like Revenue YoY (17.82%)")

// ─── COLORS ───────────────────────────────────────────────────────────────────
color C_BG    = color.rgb(16,  16,  16)
color C_HDR   = color.rgb(38,  38,  38)
color C_ROW_A = color.rgb(20,  20,  20)
color C_ROW_B = color.rgb(27,  27,  27)
color C_TXT   = color.white
color C_POS   = color.rgb(0,   204, 102)
color C_NEG   = color.rgb(220, 55,  55)
color C_DIM   = color.rgb(140, 140, 140)

// ─── FETCH QUARTERLY FUNDAMENTALS ────────────────────────────────────────────
float rev_g = request.financial(syminfo.tickerid, "TOTAL_REVENUE",  "FQ", gaps=barmerge.gaps_on)
float ni_g  = request.financial(syminfo.tickerid, "NET_INCOME",      "FQ", gaps=barmerge.gaps_on)
float fcf_g = request.financial(syminfo.tickerid, "FREE_CASH_FLOW",  "FQ", gaps=barmerge.gaps_on)

float rev   = request.financial(syminfo.tickerid, "TOTAL_REVENUE",  "FQ")
float ni    = request.financial(syminfo.tickerid, "NET_INCOME",      "FQ")
float fcf   = request.financial(syminfo.tickerid, "FREE_CASH_FLOW",  "FQ")
float npm   = not na(rev) and not na(ni) and rev != 0 ? (ni / rev) * 100 : float(na)

// ─── HISTORICAL STORAGE ───────────────────────────────────────────────────────
int MAX_Q = 14

var float[] a_rev  = array.new_float(0)
var float[] a_npm  = array.new_float(0)
var float[] a_fcf  = array.new_float(0)
var int[]   a_time = array.new_int(0)

// ─── PUSH HELPER ──────────────────────────────────────────────────────────────
push_q(float r, float np, float f, int t) =>
    bool already = array.size(a_rev) > 0 ? array.get(a_rev, 0) == r : false
    if not na(r) and not already
        array.unshift(a_rev,  r)
        array.unshift(a_npm,  np)
        array.unshift(a_fcf,  f)
        array.unshift(a_time, t)
        if array.size(a_rev) > MAX_Q
            array.pop(a_rev)
            array.pop(a_npm)
            array.pop(a_fcf)
            array.pop(a_time)

// Trigger: gaps_on fires non-na only when new quarterly data arrives
if not na(rev_g)
    float npm_g = not na(ni_g) and rev_g != 0 ? (ni_g / rev_g) * 100 : 0.0
    push_q(rev_g, npm_g, na(fcf_g) ? 0.0 : fcf_g, time)

// Force-capture on last bar
if barstate.islast and not na(rev)
    bool  val_changed  = array.size(a_rev) == 0 or array.get(a_rev, 0) != rev
    int   last_t       = array.size(a_time) > 0 ? array.get(a_time, 0) : 0
    bool  time_overdue = (time - last_t) > 70 * 86400000
    if val_changed or time_overdue
        push_q(rev, na(npm) ? 0.0 : npm, na(fcf) ? 0.0 : fcf, time)

// ─── HELPER FUNCTIONS ─────────────────────────────────────────────────────────
format_abs(float v) =>
    float av   = math.abs(v)
    string sgn = v < 0 ? "-" : ""
    if av >= 1e12
        sgn + str.tostring(math.round(av / 1e12, 2)) + "T"
    else if av >= 1e9
        sgn + str.tostring(math.round(av / 1e9,  2)) + "B"
    else if av >= 1e6
        sgn + str.tostring(math.round(av / 1e6,  2)) + "M"
    else if av >= 1e3
        sgn + str.tostring(math.round(av / 1e3,  1)) + "K"
    else
        sgn + str.tostring(math.round(v, 1))

npm_delta_str(float base_prev, float base_curr, float delta) =>
    string sgn = delta >= 0 ? "+" : ""
    if i_npm_mode == "%"
        float rel = base_prev != 0 ? (base_curr / base_prev - 1) * 100 : float(na)
        na(rel) ? "—" : sgn + str.tostring(math.round(rel, 1)) + "%"
    else
        sgn + str.tostring(math.round(delta, 2)) + "pp"

tbl_pos(string s) =>
    switch s
        "top_right"     => position.top_right
        "top_left"      => position.top_left
        "top_center"    => position.top_center
        "bottom_right"  => position.bottom_right
        "bottom_left"   => position.bottom_left
        "bottom_center" => position.bottom_center
        "middle_right"  => position.middle_right
        "middle_left"   => position.middle_left
        => position.middle_center

txt_sz(string s) =>
    switch s
        "tiny"  => size.tiny
        "small" => size.small
        => size.normal

// cell_pct — offset passé en paramètre pour s'adapter au spacer haut
cell_pct(table t, int col, int row, float v, color bg, string sz, int offset) =>
    if na(v)
        table.cell(t, col, row + offset, "—",
             text_color=color.rgb(140,140,140), bgcolor=bg,
             text_size=sz, text_halign=text.align_right)
    else
        string sgn = v >= 0 ? "+" : ""
        table.cell(t, col, row + offset, sgn + str.tostring(math.round(v, 1)) + "%",
             text_color = v >= 0 ? color.rgb(0,204,102) : color.rgb(220,55,55),
             bgcolor=bg, text_size=sz, text_halign=text.align_right)

// ─── TABLE (last bar only) ────────────────────────────────────────────────────
if barstate.islast
    int nd = array.size(a_rev)
    if nd >= 2
        // Offsets dynamiques selon les toggles
        int top_off    = i_top_space ? 1 : 0
        int bot_off    = i_bot_space ? 1 : 0
        int hdr_row    = top_off              // header = ligne 0 ou 1
        int data_off   = hdr_row + 1          // données débutent juste après le header
        int total_rows = i_rows + 1 + top_off + bot_off

        // Sans "var" → tableau recréé à chaque changement de settings,
        // ce qui permet de changer le nombre de lignes dynamiquement
        table tbl = table.new(
             position     = tbl_pos(i_pos),
             columns      = 10,
             rows         = total_rows,
             bgcolor      = C_BG,
             border_color = color.rgb(55,55,55),
             border_width = 1,
             frame_color  = color.rgb(55,55,55),
             frame_width  = 1)

        string sz = txt_sz(i_size)

        // ── Spacer haut (optionnel — ligne 0) ────────────────────────────────
        if i_top_space
            for c = 0 to 9
                table.cell(tbl, c, 0, "", bgcolor=C_BG)

        // ── Header ───────────────────────────────────────────────────────────
        string[] hdrs = array.from(
             "Quarter","Revenue","Rev QoQ","Rev YoY",
             "NPM %","NPM QoQ","NPM YoY","FCF TTM","FCF YoY","")
        for c = 0 to 9
            table.cell(tbl, c, hdr_row, array.get(hdrs, c),
                 text_color=C_TXT, bgcolor=C_HDR, text_size=sz,
                 text_halign = c == 0 ? text.align_left : text.align_right)

        // ── Lignes de données ─────────────────────────────────────────────────
        for row = 0 to math.min(i_rows - 1, nd - 1)
            float r_rev = array.get(a_rev,  row)
            float r_npm = array.get(a_npm,  row)
            int   r_t   = array.get(a_time, row)

            // FCF TTM = somme de 4 quarters consécutifs
            float r_fcf_ttm = 0.0
            for q = row to math.min(row + 3, nd - 1)
                r_fcf_ttm += array.get(a_fcf, q)

            // QoQ
            bool  hqoq    = nd > row + 1
            float rev_qoq = hqoq ? (r_rev / array.get(a_rev, row+1) - 1) * 100 : float(na)
            float npm_qoq = hqoq ? r_npm - array.get(a_npm, row+1)               : float(na)

            // YoY
            bool  hyoy    = nd > row + 4
            float rev_yoy = hyoy ? (r_rev / array.get(a_rev, row+4) - 1) * 100 : float(na)
            float npm_yoy = hyoy ? r_npm - array.get(a_npm, row+4)               : float(na)

            // FCF TTM YoY
            float fcf_py  = 0.0
            bool  hfcfyoy = nd > row + 7
            if hfcfyoy
                for q = row+4 to row+7
                    fcf_py += array.get(a_fcf, q)
            float fcf_yoy = hfcfyoy and fcf_py != 0
                 ? (r_fcf_ttm / fcf_py - 1) * 100 : float(na)

            color bg = i_altrow and row % 2 != 0 ? C_ROW_B : C_ROW_A

            // Col 0 — Quarter label
            string q_lbl = row == 0 ? "Last" : "Q-" + str.tostring(row)
            table.cell(tbl, 0, row + data_off, q_lbl,
                 text_color=C_TXT, bgcolor=bg, text_size=sz, text_halign=text.align_left)
            // Col 1 — Revenue
            table.cell(tbl, 1, row + data_off, format_abs(r_rev),
                 text_color=C_TXT, bgcolor=bg, text_size=sz, text_halign=text.align_right)
            // Col 2 — Rev QoQ
            cell_pct(tbl, 2, row, rev_qoq, bg, sz, data_off)
            // Col 3 — Rev YoY
            cell_pct(tbl, 3, row, rev_yoy, bg, sz, data_off)
            // Col 4 — NPM absolu
            table.cell(tbl, 4, row + data_off,
                 str.tostring(math.round(r_npm, 2)) + "%",
                 text_color = r_npm >= 0 ? C_TXT : C_NEG,
                 bgcolor=bg, text_size=sz, text_halign=text.align_right)
            // Col 5 — NPM QoQ
            if na(npm_qoq)
                table.cell(tbl, 5, row + data_off, "—",
                     text_color=C_DIM, bgcolor=bg, text_size=sz, text_halign=text.align_right)
            else
                float npm_prev_q = hqoq ? array.get(a_npm, row+1) : float(na)
                table.cell(tbl, 5, row + data_off, npm_delta_str(npm_prev_q, r_npm, npm_qoq),
                     text_color = npm_qoq >= 0 ? C_POS : C_NEG,
                     bgcolor=bg, text_size=sz, text_halign=text.align_right)
            // Col 6 — NPM YoY
            if na(npm_yoy)
                table.cell(tbl, 6, row + data_off, "—",
                     text_color=C_DIM, bgcolor=bg, text_size=sz, text_halign=text.align_right)
            else
                float npm_prev_y = hyoy ? array.get(a_npm, row+4) : float(na)
                table.cell(tbl, 6, row + data_off, npm_delta_str(npm_prev_y, r_npm, npm_yoy),
                     text_color = npm_yoy >= 0 ? C_POS : C_NEG,
                     bgcolor=bg, text_size=sz, text_halign=text.align_right)
            // Col 7 — FCF TTM
            table.cell(tbl, 7, row + data_off, format_abs(r_fcf_ttm),
                 text_color = r_fcf_ttm >= 0 ? C_TXT : C_NEG,
                 bgcolor=bg, text_size=sz, text_halign=text.align_right)
            // Col 8 — FCF YoY
            cell_pct(tbl, 8, row, fcf_yoy, bg, sz, data_off)
            // Col 9 — spacer colonne
            table.cell(tbl, 9, row + data_off, "", bgcolor=bg)

        // ── Spacer bas (optionnel — dernière ligne) ───────────────────────────
        if i_bot_space
            for c = 0 to 9
                table.cell(tbl, c, total_rows - 1, "", bgcolor=C_BG)
````

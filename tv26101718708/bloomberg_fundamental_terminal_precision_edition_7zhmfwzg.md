# Bloomberg Fundamental Terminal - Precision Edition

- url: https://www.tradingview.com/script/7ZHMfWZG-Bloomberg-Fundamental-Terminal-Precision-Edition/
- type: indicator
- pine_id: PUB;d12b0af821bb4fac86d04569d5662c0b
- version: 1.0

## Description

Will display key fundamental financial KPI of the stock for Quartery, Year on Year and Trailing Tweleve months.

## Source Code

````pine
//@version=6
indicator("Bloomberg Fundamental Terminal - Precision Edition", overlay=true)

// --- 1. USER INPUTS ---
grp_ui      = "UI Customization"
table_pos   = input.string("top_right", "Table Position", options=["top_right", "bottom_right", "top_left", "bottom_left", "middle_right"], group=grp_ui)
text_size   = input.string("normal", "Font Size", options=["tiny", "small", "normal", "large", "huge"], group=grp_ui)
show_border = input.bool(true, "Show Table Borders", group=grp_ui)

grp_data    = "Data Settings"
// This input ensures you can manually lock a ticker if the auto-detection is ambiguous
ticker_input = input.symbol("", "Ticker Override (Leave blank for Auto)", group=grp_data)
use_ticker   = ticker_input == "" ? syminfo.tickerid : ticker_input

f_get_size(s) =>
    s == "tiny" ? size.tiny : s == "small" ? size.small : s == "normal" ? size.normal : s == "large" ? size.large : size.huge

// --- 2. COLORS ---
color_bg        = #000000 
color_header_bg = #1c1c1c 
color_row_alt   = #0a0a0a 
color_border    = #313335 
color_bbg_amber = #ff9800 
color_current   = #ffffff 
color_ttm       = #ffffff 
color_estimate  = #9e9e9e 
color_pos       = #00ff00 
color_neg       = #ff0000 
color_text_dim  = #868993 

// --- 3. DYNAMIC PERIOD CAPTURE ---
// We use the 'use_ticker' variable here to stay consistent
raw_eps = request.financial(use_ticker, "EARNINGS_PER_SHARE_DILUTED", "FQ")
is_new_report = (ta.change(raw_eps) != 0) and not na(raw_eps)

get_period_label(m, y) =>
    q = m <= 3 ? "Q1" : m <= 6 ? "Q2" : m <= 9 ? "Q3" : "Q4"
    q + "/" + str.substring(str.tostring(y), 2)

var label_stack = array.new_string(0)
if is_new_report or (barstate.isfirst and not na(raw_eps))
    array.unshift(label_stack, get_period_label(month, year))
    if array.size(label_stack) > 15 
        array.pop(label_stack)

f_lab(idx) => array.size(label_stack) > idx ? array.get(label_stack, idx) : "Q-" + str.tostring(idx)

// --- 4. UTILITIES ---
g_color(val) => val > 0 ? color_pos : val < 0 ? color_neg : color_current

get_prev_unique(src, occurrence) =>
    float result = na
    int found = 0
    for i = 1 to 500 
        if src[i] != src[i-1] and not na(src[i])
            found += 1
            if found == occurrence
                result := src[i]
                break
    result

calc_growth(curr, prev) =>
    prev == 0 or na(prev) or na(curr) ? na : ((curr - prev) / math.abs(prev)) * 100

f_fmt(val, is_pct) => 
    string formatted = "--"
    if not na(val)
        if math.abs(val) >= 1e9 and not is_pct
            formatted := str.format("{0,number,#.#}B", val / 1e9)
        else if math.abs(val) >= 1e6 and not is_pct
            formatted := str.format("{0,number,#.#}M", val / 1e6)
        else
            formatted := str.tostring(val, "#.##")
    is_pct and formatted != "--" ? formatted + "%" : formatted

// --- 5. DATA RETRIEVAL (PRECISION LOCKED) ---
fetch_and_process(id, is_average, float est_val = na) =>
    // We strictly use 'use_ticker' which contains Exchange:Ticker
    q0 = request.financial(use_ticker, id, "FQ")
    q1 = get_prev_unique(q0, 1), q2 = get_prev_unique(q0, 2), q3 = get_prev_unique(q0, 3), q4 = get_prev_unique(q0, 4)
    q5 = get_prev_unique(q0, 5), q6 = get_prev_unique(q0, 6), q7 = get_prev_unique(q0, 7), q8 = get_prev_unique(q0, 8), q9 = get_prev_unique(q0, 9)
    ttm_curr = is_average ? (q0 + q1 + q2 + q3) / 4 : (q0 + q1 + q2 + q3)
    ttm_prev = is_average ? (q4 + q5 + q6 + q7) / 4 : (q4 + q5 + q6 + q7)
    [q0, q1, q2, q3, q4, q5, q6, q7, q8, q9, ttm_curr, calc_growth(q0, q1), calc_growth(q0, q4), calc_growth(ttm_curr, ttm_prev), est_val]

// Data fetching using validated ticker ID
[e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, e_ttm, e_qoq, e_yoy, e_ttm_p, e_est] = fetch_and_process("EARNINGS_PER_SHARE_DILUTED", false, request.financial(use_ticker, "EARNINGS_ESTIMATE", "FQ"))
[r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r_ttm, r_qoq, r_yoy, r_ttm_p, r_est] = fetch_and_process("TOTAL_REVENUE", false, request.financial(use_ticker, "SALES_ESTIMATES", "FQ"))
[g0, g1, g2, g3, g4, g5, g6, g7, g8, g9, g_ttm, g_qoq, g_yoy, g_ttm_p, g_est] = fetch_and_process("GROSS_MARGIN", true)
[o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o_ttm, o_qoq, o_yoy, o_ttm_p, o_est] = fetch_and_process("OPERATING_MARGIN", true)
[n0, n1, n2, n3, n4, n5, n6, n7, n8, n9, n_ttm, n_qoq, n_yoy, n_ttm_p, n_est] = fetch_and_process("NET_MARGIN", true)
[roe0, roe1, roe2, roe3, roe4, roe5, roe6, roe7, roe8, roe9, roe_ttm, roe_qoq, roe_yoy, roe_ttm_p, roe_est] = fetch_and_process("RETURN_ON_EQUITY", true)
[roic0, roic1, roic2, roic3, roic4, roic5, roic6, roic7, roic8, roic9, roic_ttm, roic_qoq, roic_yoy, roic_ttm_p, roic_est] = fetch_and_process("RETURN_ON_INVESTED_CAPITAL", true)
[d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d_ttm, d_qoq, d_yoy, d_ttm_p, d_est] = fetch_and_process("DEBT_TO_EQUITY", true)
[c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c_ttm, c_qoq, c_yoy, c_ttm_p, c_est] = fetch_and_process("CASH_F_OPERATING_ACTIVITIES", false)
[f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f_ttm, f_qoq, f_yoy, f_ttm_p, f_est] = fetch_and_process("FREE_CASH_FLOW", false)
[dy0, dy1, dy2, dy3, dy4, dy5, dy6, dy7, dy8, dy9, dy_ttm, dy_qoq, dy_yoy, dy_ttm_p, dy_est] = fetch_and_process("DIVIDENDS_YIELD", true)

// --- 6. TABLE RENDERING ---
var table main_table = table.new(table_pos, 16, 13, bgcolor=color_bg, border_width=show_border ? 1 : 0, border_color=color_border)

render_row(tbl, row_idx, label, v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v_ttm, g_qoq, g_yoy, g_ttm_p, v_est, is_pct) =>
    row_bg = row_idx % 2 == 0 ? color_row_alt : color_bg
    t_size = f_get_size(text_size)
    table.cell(tbl, 0, row_idx, label, bgcolor=row_bg, text_halign=text.align_left, text_color=color_bbg_amber, text_size=t_size)
    
    hist_vals = array.from(v9, v8, v7, v6, v5, v4, v3, v2, v1)
    for i = 0 to 8
        table.cell(tbl, i + 1, row_idx, f_fmt(array.get(hist_vals, i), is_pct), bgcolor=row_bg, text_color=color_text_dim, text_size=t_size)
    
    table.cell(tbl, 10, row_idx, f_fmt(v0, is_pct), bgcolor=row_bg, text_color=color_current, text_size=t_size)
    table.cell(tbl, 11, row_idx, f_fmt(v_est, is_pct), bgcolor=row_bg, text_color=color_estimate, text_size=t_size)
    table.cell(tbl, 12, row_idx, str.tostring(g_qoq, "#.#") + "%", bgcolor=row_bg, text_color=g_color(g_qoq), text_size=t_size)
    table.cell(tbl, 13, row_idx, str.tostring(g_yoy, "#.#") + "%", bgcolor=row_bg, text_color=g_color(g_yoy), text_size=t_size)
    table.cell(tbl, 14, row_idx, f_fmt(v_ttm, is_pct), bgcolor=row_bg, text_color=color_ttm, text_size=t_size)
    table.cell(tbl, 15, row_idx, str.tostring(g_ttm_p, "#.#") + "%", bgcolor=row_bg, text_color=g_color(g_ttm_p), text_size=t_size)

if barstate.islast
    t_size = f_get_size(text_size)
    // Precise header using prefix:ticker
    display_name = ticker_input == "" ? (syminfo.prefix + ":" + syminfo.ticker) : ticker_input
    headers = array.from(display_name, f_lab(9), f_lab(8), f_lab(7), f_lab(6), f_lab(5), f_lab(4), f_lab(3), f_lab(2), f_lab(1), f_lab(0), "EST", "QoQ%", "YoY%", "TTM", "TTM%")
    
    for [i, txt] in headers
        table.cell(main_table, i, 0, txt, bgcolor=color_header_bg, text_color=color_bbg_amber, text_size=t_size)

    render_row(main_table, 1, "EPS (Diluted)", e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, e_ttm, e_qoq, e_yoy, e_ttm_p, e_est, false)
    render_row(main_table, 2, "Revenue",        r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r_ttm, r_qoq, r_yoy, r_ttm_p, r_est, false)
    render_row(main_table, 3, "Gross Margin",   g0, g1, g2, g3, g4, g5, g6, g7, g8, g9, g_ttm, g_qoq, g_yoy, g_ttm_p, g_est, true)
    render_row(main_table, 4, "Oper. Margin",   o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o_ttm, o_qoq, o_yoy, o_ttm_p, o_est, true)
    render_row(main_table, 5, "Net Margin",     n0, n1, n2, n3, n4, n5, n6, n7, n8, n9, n_ttm, n_qoq, n_yoy, n_ttm_p, n_est, true)
    render_row(main_table, 6, "Return on Eq.",  roe0, roe1, roe2, roe3, roe4, roe5, roe6, roe7, roe8, roe9, roe_ttm, roe_qoq, roe_yoy, roe_ttm_p, roe_est, true)
    render_row(main_table, 7, "Return on Inv.", roic0, roic1, roic2, roic3, roic4, roic5, roic6, roic7, roic8, roic9, roic_ttm, roic_qoq, roic_yoy, roic_ttm_p, roic_est, true)
    render_row(main_table, 8, "Debt / Equity",  d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d_ttm, d_qoq, d_yoy, d_ttm_p, d_est, false)
    render_row(main_table, 9, "Cash From Ops",  c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c_ttm, c_qoq, c_yoy, c_ttm_p, c_est, false)
    render_row(main_table, 10, "Free Cash Flo", f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f_ttm, f_qoq, f_yoy, f_ttm_p, f_est, false)
    render_row(main_table, 11, "Div. Yield",    dy0, dy1, dy2, dy3, dy4, dy5, dy6, dy7, dy8, dy9, dy_ttm, dy_qoq, dy_yoy, dy_ttm_p, dy_est, true)
    
    table.merge_cells(main_table, 0, 12, 15, 12)
    table.cell(main_table, 0, 12, "FINANCIAL SUMMARY > " + display_name + " | " + str.format("{0,date,yyyy-MM-dd}", timenow), text_size=size.tiny, text_color=color_bbg_amber, text_halign=text.align_right)
````

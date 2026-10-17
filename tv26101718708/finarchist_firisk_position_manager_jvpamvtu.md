# finarchist| fi/risk Position Manager

- url: https://www.tradingview.com/script/JvPAmvtU-finarchist-fi-risk-Position-Manager/
- type: indicator
- pine_id: PUB;9b26670f07fa47148a4796959611497c
- version: 1.0

## Description

What it does

This indicator is a position size and risk calculator. You enter up to 10 tiers. Each tier has a side (long or short), an entry price, a stop price and the amount you are willing to lose on that tier. The script converts these inputs into a position size and shows everything in one table on the chart. Nothing is traded and the script does not generate buy or sell signals. It only calculates from the values you type in.

How it works

Position size per tier: the risk amount is divided by the stop distance multiplied by the point value of the symbol.

size = risk amount / (absolute value of (entry - stop) x point value)

Profit/loss per tier: the current price is compared with the entry, in the direction of the tier, and multiplied by size and point value. Long: (price - entry) x size x point value. Short: (entry - price) x size x point value.

Averages: long tiers and short tiers are averaged separately. Each average is weighted by size. The table shows the weighted average entry for the long side and for the short side, but only for the sides that exist. The same weighting is used for the average stop lines drawn on the chart.

Net exposure: long size minus short size. The table labels it long, short or flat.

Target: there are two modes.
- Price Level: you type a target price. The table shows the combined profit/loss of all valid tiers if price is at that level. If both long and short tiers exist, each leg is calculated at the target price and the results are added.
- Profit Amount: you type a profit amount. The script solves for the price at which the combined profit/loss equals that amount. This needs a net position. If long and short sizes cancel out exactly, the target cannot be calculated and the table shows a dash.

Reward-to-risk ratio: profit/loss at the target divided by the sum of the risk amounts of the valid tiers.

Validation: a tier is ignored in all totals if its entry equals its stop, if its risk amount is zero or negative, or if its stop is on the wrong side of the entry (below the entry for a short, above the entry for a long). Such a tier is marked in the table as invalid or check stop.

How to use

1. Add the indicator to a clean chart.
2. Open the settings. In the settings group, leave the symbol field empty to use the chart symbol, or pick another symbol. Set the currency unit text that should appear next to amounts.
3. In a tier group (T01 to T10), tick the tier on, choose long or short, then enter the risk amount, the entry price and the stop price.
4. Repeat for the other tiers you want to model. Tiers with an entry or stop of zero are skipped.
5. Optional: choose the target mode and enter a target value. The target line, the profit/loss at the target and the reward-to-risk ratio appear in the table.
6. Optional: use the font size, table position and table scaling inputs to fit the table to your screen.
7. Optional: create an alert from the alert dialog and select the condition named "fi/risk: target reached". The alert uses the high and low of the selected symbol.

What makes it different

- Up to 10 separate long and short tiers can be handled in a single table, with a separate average entry for each side.
- The position size of every tier is derived from a risk amount and a stop distance, so you do not have to calculate size by hand for each entry.
- The target can be given either as a price or as a profit amount.
- The script is open source, so every formula above can be read and checked in the code.

Limitations

- The point value depends on the symbol. The script reads it from the symbol information on TradingView. If it does not match your broker's contract size, the displayed sizes will not match either. Please check this before relying on any number.
- Commission, spread, slippage, swap and financing costs are not included.
- Sizes are not rounded to lot steps or minimum order sizes.
- If you select a symbol other than the chart symbol, the table still works, but the lines are not drawn on the chart because the price scales would not match. The table header shows which symbol is used.
- The script only calculates with the values you enter. It does not open orders, it does not read your account and it does not generate signals.
- Prices in the table use the tick format of the chart symbol.

Disclaimer

For educational and informational purposes only. Not financial advice.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © finarchist
// For educational and informational purposes only. Not financial advice.

//@version=6
indicator("finarchist| fi/risk Position Manager", shorttitle="finarchist| fi/risk Position Manager", overlay=true)

// fi/risk Position Manager
// Position size calculator for up to 10 long/short tiers.
// Size = risk amount / (|entry - stop| x point value).
// Long and short tiers are averaged separately; the target is evaluated on the net position.
// Nothing is traded and no signals are produced. All values come from the inputs below.

// --- COLORS ---
color_bg_dark    = #0d1117
color_bg_med     = #161b22
color_bull       = #2e7d32
color_bear       = #c62828
color_gold       = #f9a825
color_text       = #c9d1d9
color_header_txt = #788390
color_signature  = #E30A17
color_border     = #30363d

// --- SETTINGS ---
grp_config  = "SETTINGS"
main_symbol = input.symbol("", "SYMBOL (blank = chart symbol)", group=grp_config)
cur_sym     = input.string("$", "CURRENCY UNIT", group=grp_config)
target_mode = input.string("Price Level", "TARGET MODE", options=["Price Level", "Profit Amount"], group=grp_config)
target_val  = input.float(0, "TARGET VALUE (price or profit amount)", group=grp_config)
user_size   = input.string("Small", "FONT SIZE", options=["Tiny", "Small", "Normal"], group=grp_config)
table_pos   = input.string("Bottom Left", "TABLE POSITION", options=["Bottom Left", "Bottom Right", "Top Left", "Top Right"], group=grp_config)

grp_scale  = "TABLE SCALING"
col_id_w   = input.float(1.0, "ID COLUMN WIDTH (%)", group=grp_scale)
col_data_w = input.float(3.0, "DATA COLUMN WIDTH (%)", group=grp_scale)
row_h      = input.float(2.3, "ROW HEIGHT (%)", group=grp_scale)

sz  = user_size == "Tiny" ? size.tiny : user_size == "Small" ? size.small : size.normal
pos = table_pos == "Bottom Left" ? position.bottom_left : table_pos == "Bottom Right" ? position.bottom_right : table_pos == "Top Left" ? position.top_left : position.top_right

// --- MARKET DATA ---
target_sym       = main_symbol == "" ? syminfo.tickerid : main_symbol
current_price    = request.security(target_sym, timeframe.period, close)
point_multiplier = request.security(target_sym, timeframe.period, syminfo.pointvalue)
ticker_name      = request.security(target_sym, timeframe.period, syminfo.ticker)
[tgt_high, tgt_low] = request.security(target_sym, timeframe.period, [high, low])
p_mult           = (na(point_multiplier) or point_multiplier <= 0) ? 1.0 : point_multiplier
same_sym         = main_symbol == "" or main_symbol == ticker.standard(syminfo.tickerid) or main_symbol == syminfo.prefix + ":" + syminfo.ticker

// --- TIER INPUTS (T1-T10) ---
active_arr = array.from(input.bool(false,"T1",group="T01"),input.bool(false,"T2",group="T02"),input.bool(false,"T3",group="T03"),input.bool(false,"T4",group="T04"),input.bool(false,"T5",group="T05"),input.bool(false,"T6",group="T06"),input.bool(false,"T7",group="T07"),input.bool(false,"T8",group="T08"),input.bool(false,"T9",group="T09"),input.bool(false,"T10",group="T10"))
side_arr   = array.from(input.string("Long","Side",options=["Long","Short"],group="T01"),input.string("Long","Side",options=["Long","Short"],group="T02"),input.string("Long","Side",options=["Long","Short"],group="T03"),input.string("Long","Side",options=["Long","Short"],group="T04"),input.string("Long","Side",options=["Long","Short"],group="T05"),input.string("Long","Side",options=["Long","Short"],group="T06"),input.string("Long","Side",options=["Long","Short"],group="T07"),input.string("Long","Side",options=["Long","Short"],group="T08"),input.string("Long","Side",options=["Long","Short"],group="T09"),input.string("Long","Side",options=["Long","Short"],group="T10"))
risk_arr   = array.from(input.float(100,"Risk",group="T01"),input.float(100,"Risk",group="T02"),input.float(100,"Risk",group="T03"),input.float(100,"Risk",group="T04"),input.float(100,"Risk",group="T05"),input.float(100,"Risk",group="T06"),input.float(100,"Risk",group="T07"),input.float(100,"Risk",group="T08"),input.float(100,"Risk",group="T09"),input.float(100,"Risk",group="T10"))
entry_arr  = array.from(input.float(0,"Entry",group="T01"),input.float(0,"Entry",group="T02"),input.float(0,"Entry",group="T03"),input.float(0,"Entry",group="T04"),input.float(0,"Entry",group="T05"),input.float(0,"Entry",group="T06"),input.float(0,"Entry",group="T07"),input.float(0,"Entry",group="T08"),input.float(0,"Entry",group="T09"),input.float(0,"Entry",group="T10"))
sl_arr     = array.from(input.float(0,"Stop",group="T01"),input.float(0,"Stop",group="T02"),input.float(0,"Stop",group="T03"),input.float(0,"Stop",group="T04"),input.float(0,"Stop",group="T05"),input.float(0,"Stop",group="T06"),input.float(0,"Stop",group="T07"),input.float(0,"Stop",group="T08"),input.float(0,"Stop",group="T09"),input.float(0,"Stop",group="T10"))

// --- HELPERS ---
// Tier status: 0 = valid, 1 = invalid (entry equals stop, or risk <= 0), 2 = stop on the wrong side of entry
f_status(side, ent, sl, risk) =>
    int st = 0
    if ent == sl or risk <= 0
        st := 1
    else if (side == "Long" and sl > ent) or (side == "Short" and sl < ent)
        st := 2
    st

f_money(val, cur) =>
    na(val) ? "-" : (val >= 0 ? "+" : "") + str.tostring(val, "#.##") + " " + cur

// --- CALCULATION ---
float q_long   = 0.0
float q_short  = 0.0
float we_long  = 0.0
float we_short = 0.0
float ws_long  = 0.0
float ws_short = 0.0
float t_pl     = 0.0
float t_risk   = 0.0

for i = 0 to 9
    if array.get(active_arr, i) and array.get(entry_arr, i) > 0 and array.get(sl_arr, i) > 0
        string s_side = array.get(side_arr, i)
        float s_ent   = array.get(entry_arr, i)
        float s_sl    = array.get(sl_arr, i)
        float s_risk  = array.get(risk_arr, i)
        int s_st      = f_status(s_side, s_ent, s_sl, s_risk)
        if s_st == 0
            float s_qty = s_risk / (math.abs(s_ent - s_sl) * p_mult)
            float s_pl  = (s_side == "Long" ? current_price - s_ent : s_ent - current_price) * s_qty * p_mult
            if s_side == "Long"
                q_long  += s_qty
                we_long += s_ent * s_qty
                ws_long += s_sl * s_qty
            else
                q_short  += s_qty
                we_short += s_ent * s_qty
                ws_short += s_sl * s_qty
            t_pl   += s_pl
            t_risk += s_risk

float avg_ent_long  = q_long > 0 ? we_long / q_long : na
float avg_sl_long   = q_long > 0 ? ws_long / q_long : na
float avg_ent_short = q_short > 0 ? we_short / q_short : na
float avg_sl_short  = q_short > 0 ? ws_short / q_short : na
float net_qty       = q_long - q_short
bool  is_flat       = math.abs(net_qty) < 0.000000001
bool  has_pos       = q_long + q_short > 0

// Target price. P/L(p) = point value x (net_qty x p - we_long + we_short)
float tp = na
if target_val > 0 and has_pos
    if target_mode == "Price Level"
        tp := target_val
    else if not is_flat
        float p_solve = (target_val / p_mult + we_long - we_short) / net_qty
        tp := p_solve > 0 ? p_solve : na

float pl_target = na(tp) ? na : p_mult * (net_qty * tp - we_long + we_short)
float total_rr  = (not na(pl_target) and t_risk > 0) ? pl_target / t_risk : na

// --- TABLE ---
var table tb = na

f_sum_row(row, txt, value, val_color, val_bg, lbl_color, lbl_bg) =>
    table.merge_cells(tb, 0, row, 5, row)
    table.cell(tb, 0, row, txt, bgcolor=lbl_bg, text_color=lbl_color, text_size=sz, text_halign=text.align_left, height=row_h)
    table.cell(tb, 6, row, value, bgcolor=val_bg, text_color=val_color, text_size=sz, text_halign=text.align_right, height=row_h)

if barstate.islast
    if not na(tb)
        table.delete(tb)
    tb := table.new(pos, 7, 20, border_width=1, frame_color=color_border, border_color=color.new(color_border, 80))

    // Header
    table.merge_cells(tb, 0, 0, 6, 0)
    hdr_txt = "fi/risk | " + ticker_name + " (" + (na(current_price) ? "-" : str.tostring(current_price, format.mintick)) + ")" + (same_sym ? "" : " | chart lines hidden")
    table.cell(tb, 0, 0, hdr_txt, bgcolor=color_bg_dark, text_color=color_gold, text_size=size.normal, text_halign=text.align_left, height=row_h * 1.6)

    // Column titles
    h_titles = array.from("ID", "SIDE", "SIZE", "ENTRY", "STOP", "RISK", "UNREAL P/L")
    for i = 0 to 6
        table.cell(tb, i, 1, array.get(h_titles, i), bgcolor=#080a0d, text_color=color_header_txt, text_size=sz, width=(i == 0 ? col_id_w : col_data_w), height=row_h)

    // Tier rows
    int curr_row = 2
    for i = 0 to 9
        if array.get(active_arr, i) and array.get(entry_arr, i) > 0 and array.get(sl_arr, i) > 0
            string r_side = array.get(side_arr, i)
            float r_ent   = array.get(entry_arr, i)
            float r_sl    = array.get(sl_arr, i)
            float r_risk  = array.get(risk_arr, i)
            int r_st      = f_status(r_side, r_ent, r_sl, r_risk)
            color bg_row  = curr_row % 2 == 0 ? color_bg_dark : color_bg_med

            table.cell(tb, 0, curr_row, "T" + str.tostring(i + 1), bgcolor=bg_row, text_color=color_gold, text_size=sz, height=row_h)
            table.cell(tb, 1, curr_row, r_side, bgcolor=bg_row, text_color=(r_side == "Long" ? color_bull : color_bear), text_size=sz, height=row_h)
            table.cell(tb, 3, curr_row, str.tostring(r_ent, format.mintick), bgcolor=bg_row, text_color=color_text, text_size=sz, text_halign=text.align_right, height=row_h)
            table.cell(tb, 4, curr_row, str.tostring(r_sl, format.mintick), bgcolor=bg_row, text_color=color_bear, text_size=sz, text_halign=text.align_right, height=row_h)
            table.cell(tb, 5, curr_row, str.tostring(r_risk, "#.##") + " " + cur_sym, bgcolor=bg_row, text_color=color_text, text_size=sz, text_halign=text.align_right, height=row_h)
            if r_st == 0
                float r_qty = r_risk / (math.abs(r_ent - r_sl) * p_mult)
                float r_pl  = (r_side == "Long" ? current_price - r_ent : r_ent - current_price) * r_qty * p_mult
                table.cell(tb, 2, curr_row, str.tostring(r_qty, "#.##"), bgcolor=bg_row, text_color=color_text, text_size=sz, text_halign=text.align_right, height=row_h)
                table.cell(tb, 6, curr_row, f_money(r_pl, cur_sym), bgcolor=(r_pl >= 0 ? color_bull : color_bear), text_color=color.white, text_size=sz, text_halign=text.align_right, height=row_h)
            else
                table.cell(tb, 2, curr_row, "-", bgcolor=bg_row, text_color=color_text, text_size=sz, text_halign=text.align_right, height=row_h)
                table.cell(tb, 6, curr_row, r_st == 2 ? "check stop" : "invalid", bgcolor=bg_row, text_color=color_gold, text_size=sz, text_halign=text.align_right, height=row_h)
            curr_row += 1

    // Summary rows
    if not na(avg_ent_long)
        f_sum_row(curr_row, "AVG ENTRY (LONG)", str.tostring(avg_ent_long, format.mintick), color_gold, color_bg_med, color_text, color_bg_med)
        curr_row += 1
    if not na(avg_ent_short)
        f_sum_row(curr_row, "AVG ENTRY (SHORT)", str.tostring(avg_ent_short, format.mintick), color_gold, color_bg_med, color_text, color_bg_med)
        curr_row += 1

    net_lbl = is_flat ? "FLAT" : (net_qty > 0 ? "LONG" : "SHORT")
    net_col = is_flat ? color_text : (net_qty > 0 ? color_bull : color_bear)
    f_sum_row(curr_row, "NET EXPOSURE (" + net_lbl + ")", str.tostring(math.abs(net_qty), "#.##") + " Units", net_col, color_bg_med, color_text, color_bg_med)
    curr_row += 1

    rr_txt = na(total_rr) ? "-" : str.tostring(total_rr, "0.##")
    pl_bg  = na(pl_target) ? color_bg_med : (pl_target >= 0 ? color.new(color_bull, 20) : color.new(color_bear, 20))
    f_sum_row(curr_row, "P/L AT TARGET (R:R " + rr_txt + ")", f_money(pl_target, cur_sym), color.white, pl_bg, color_text, color_bg_med)
    curr_row += 1

    tot_bg = t_pl >= 0 ? color_bull : color_bear
    f_sum_row(curr_row, "TOTAL UNREALIZED P/L", f_money(t_pl, cur_sym), color.white, tot_bg, color_gold, color_bg_dark)
    curr_row += 1

    // Footer
    f_bg = color.new(color_bg_med, 50)
    table.merge_cells(tb, 0, curr_row, 3, curr_row)
    table.cell(tb, 0, curr_row, "fi/risk Position Manager", bgcolor=f_bg, text_color=color_header_txt, text_size=size.small, text_halign=text.align_left, height=row_h)
    table.merge_cells(tb, 4, curr_row, 6, curr_row)
    table.cell(tb, 4, curr_row, "finarchist", bgcolor=f_bg, text_color=color_signature, text_size=size.normal, text_halign=text.align_right, height=row_h)

// --- CHART LINES (drawn on the last bar only, and only when the selected symbol is the chart symbol) ---
var line  l_ent_long  = na
var label lb_ent_long = na
var line  l_sl_long   = na
var label lb_sl_long  = na
var line  l_ent_short  = na
var label lb_ent_short = na
var line  l_sl_short   = na
var label lb_sl_short  = na
var line  l_tp  = na
var label lb_tp = na

if barstate.islast
    line.delete(l_ent_long)
    label.delete(lb_ent_long)
    line.delete(l_sl_long)
    label.delete(lb_sl_long)
    line.delete(l_ent_short)
    label.delete(lb_ent_short)
    line.delete(l_sl_short)
    label.delete(lb_sl_short)
    line.delete(l_tp)
    label.delete(lb_tp)
    if same_sym
        if not na(avg_ent_long)
            l_ent_long  := line.new(bar_index + 5, avg_ent_long, bar_index + 40, avg_ent_long, color=color_gold, width=2, style=line.style_dashed)
            lb_ent_long := label.new(bar_index + 40, avg_ent_long, "AVG ENTRY (LONG)", color=color_gold, textcolor=color_bg_dark, style=label.style_label_left, size=sz)
            l_sl_long   := line.new(bar_index + 5, avg_sl_long, bar_index + 40, avg_sl_long, color=color_bear, width=2)
            lb_sl_long  := label.new(bar_index + 40, avg_sl_long, "AVG STOP (LONG)", color=color_bear, textcolor=color.white, style=label.style_label_left, size=sz)
        if not na(avg_ent_short)
            l_ent_short  := line.new(bar_index + 5, avg_ent_short, bar_index + 40, avg_ent_short, color=color_gold, width=2, style=line.style_dashed)
            lb_ent_short := label.new(bar_index + 40, avg_ent_short, "AVG ENTRY (SHORT)", color=color_gold, textcolor=color_bg_dark, style=label.style_label_left, size=sz)
            l_sl_short   := line.new(bar_index + 5, avg_sl_short, bar_index + 40, avg_sl_short, color=color_bear, width=2)
            lb_sl_short  := label.new(bar_index + 40, avg_sl_short, "AVG STOP (SHORT)", color=color_bear, textcolor=color.white, style=label.style_label_left, size=sz)
        if not na(tp)
            l_tp  := line.new(bar_index + 5, tp, bar_index + 40, tp, color=color_bull, width=2, style=line.style_dashed)
            lb_tp := label.new(bar_index + 40, tp, "TARGET: " + str.tostring(tp, format.mintick), color=color_bull, textcolor=color.white, style=label.style_label_left, size=sz)

// --- ALERT ---
// Uses the high/low of the selected symbol. Flat net position: alert when the target lies inside the bar range.
bool target_hit = not na(tp) and ((net_qty > 0 and tgt_high >= tp) or (net_qty < 0 and tgt_low <= tp) or (is_flat and tgt_low <= tp and tgt_high >= tp))
alertcondition(target_hit, title="fi/risk: target reached", message="Price reached the target level set in fi/risk.")
````

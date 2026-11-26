# Trend Strength Dashboard

- url: https://www.tradingview.com/script/PF3xzytQ-Trend-Strength-Dashboard/
- type: indicator
- pine_id: PUB;edbbd0dd381d4666b981ef989bbe1935
- version: 1.0

## Description

Trend Strength Dashboard

A compact, configurable on-chart table that reads trend strength and directional bias across up to six timeframes at once. Pick the TFs that matter to you, ignore the rest, and see at a glance whether your intraday entries align with higher-TF momentum.


How it works

1. For each enabled row, the indicator computes a trend-strength score and a directional bias (DI+ / DI-) on the chosen timeframe.
2. The score is classified into a tier: No Trend / Weak / Strong / Very Strong.
3. The table renders one row per enabled TF with the TF label, raw score, tier, and direction (Bull / Bear). Each cell is color-coded by tier and direction.
4. Rows set to "NA" are hidden and the table collapses upward — you can shrink the dashboard down to a single TF if that's all you want.


Timeframes

Six independent dropdowns — "Row 1 TF" through "Row 6 TF" — let you pick the TF for each row. Options are: NA, M1, M3, M5, M15, M30, H1, H2, H4, D.

Defaults:
- Row 1: M1
- Row 2: M3
- Row 3: M5
- Row 4: M15
- Row 5: H1
- Row 6: H4

Set any row to "NA" to hide it. Alerts treat NA rows as neutral so the "all aligned" checks still work across whichever subset you've enabled.


Strength classification

The score is bucketed into four tiers with configurable thresholds:
- "No Trend" — below the Weak threshold (default 20)
- "Weak" — at or above Weak (20) but below Strong
- "Strong" — at or above Strong (default 25) but below Very Strong
- "Very Strong" — at or above Very Strong (default 40)

Each tier has its own color (gray / orange / green / lime by default) — easy to recolor in the Colors group.


Direction

The Direction column reads Bull / Bear from the directional engine on that TF. The cell is tinted teal for Bull and red for Bear. Toggle the whole column off via "Show direction column" if you only care about strength.


Inputs at a glance

- Engine — Trend length (default 14), Direction length (default 14).
- Thresholds — Weak / Strong / Very Strong cutoffs.
- Display — Table position, table size (default "tiny"), direction column toggle.
- Timeframes — Row 1–6 TF dropdowns (with NA option).
- Colors — Header / row backgrounds, tier colors, bull / bear colors.


Alerts

Three named alertcondition entries (use the standard alert dialog):
- All TFs Strong — every enabled row is at or above the Strong threshold.
- All TFs Bullish — All TFs Strong AND every enabled row has DI+ over DI-.
- All TFs Bearish — All TFs Strong AND every enabled row has DI- over DI+.

NA rows are skipped in these checks so the alerts adapt to whichever subset of TFs you have enabled.


Recommended use

- Markets: forex, gold, indices, BTC — any liquid intraday instrument.
- Chart timeframes: works on any TF. Defaults are tuned for M1–M5 execution with H1 / H4 context, but you can rebuild the dashboard for any setup (e.g. swing: M30 / H1 / H4 / D, or single-TF: just M5).
- Pair with: HTF / LTF MSS Sync ICT for entry signals, or HTF + LTF Market Structure ICT for structure context.


Disclaimer

For educational and analytical purposes only. Not financial advice and not a guarantee of profitability. The dashboard is a context tool — combine it with your own structure, signals, and risk management before acting on it.

## Source Code

````pine
//@version=5
// Trend Strength Dashboard — multi-timeframe trend panel.
//
// Computes a proprietary trend-strength score and directional bias on
// M1, M3, M5, M15, H1, H4 simultaneously and renders a compact on-chart
// table with score, strength tier (No Trend / Weak / Strong / Very
// Strong), and direction (Bull / Bear). Use it to gauge whether
// intraday entries align with higher-TF momentum before pulling the
// trigger.

indicator("Trend Strength Dashboard", "TSD", overlay=true)

//+------------------------------------------------------------------------------------------------------------+//
//+--- Inputs                                                                                                ---+//
//+------------------------------------------------------------------------------------------------------------+//
trend_len   = input.int(14, "Trend length",     minval=2, group='Engine')
dir_len     = input.int(14, "Direction length", minval=2, group='Engine')

th_weak     = input.float(20.0, "Weak threshold",        minval=0.0, step=1.0, group='Thresholds', tooltip="Trend strength at/above this value is considered 'Weak' trend. Below this is 'No Trend'.")
th_strong   = input.float(25.0, "Strong threshold",      minval=0.0, step=1.0, group='Thresholds', tooltip="Trend strength at/above this value is considered 'Strong' trend.")
th_vstrong  = input.float(40.0, "Very Strong threshold", minval=0.0, step=1.0, group='Thresholds', tooltip="Trend strength at/above this value is considered 'Very Strong' trend.")

table_pos   = input.string("top_right", "Table position", options=["top_left","top_right","middle_left","middle_right","bottom_left","bottom_right"], group='Display')
table_size  = input.string("tiny", "Table size", options=["tiny","small","normal","large"], group='Display')
show_dir    = input.bool(true, "Show direction column", group='Display')

tf_opts     = "Pick the timeframe for this row. NA hides the row entirely so you can shrink the dashboard down to a single TF."
tf1         = input.string("M1",  "Row 1 TF", options=["NA","M1","M3","M5","M15","M30","H1","H2","H4","D"], group='Timeframes', tooltip=tf_opts)
tf2         = input.string("M3",  "Row 2 TF", options=["NA","M1","M3","M5","M15","M30","H1","H2","H4","D"], group='Timeframes')
tf3         = input.string("M5",  "Row 3 TF", options=["NA","M1","M3","M5","M15","M30","H1","H2","H4","D"], group='Timeframes')
tf4         = input.string("M15", "Row 4 TF", options=["NA","M1","M3","M5","M15","M30","H1","H2","H4","D"], group='Timeframes')
tf5         = input.string("H1",  "Row 5 TF", options=["NA","M1","M3","M5","M15","M30","H1","H2","H4","D"], group='Timeframes')
tf6         = input.string("H4",  "Row 6 TF", options=["NA","M1","M3","M5","M15","M30","H1","H2","H4","D"], group='Timeframes')

c_header_bg = input.color(color.new(#1e1e2e, 0), "Header background", group='Colors', inline='hdr')
c_header_tx = input.color(color.white,           "Header text",       group='Colors', inline='hdr')
c_row_bg    = input.color(color.new(#2a2a3a, 20),"Row background",    group='Colors', inline='row')
c_row_tx    = input.color(color.white,           "Row text",          group='Colors', inline='row')

c_none      = input.color(color.new(color.gray,   60), "No Trend color",    group='Colors')
c_weakish   = input.color(color.new(color.orange, 40), "Weak color",        group='Colors')
c_strong    = input.color(color.new(color.green,  30), "Strong color",      group='Colors')
c_vstrong   = input.color(color.new(color.lime,   10), "Very Strong color", group='Colors')

c_bull      = input.color(color.new(color.teal,  20), "Bullish color", group='Colors')
c_bear      = input.color(color.new(color.red,   20), "Bearish color", group='Colors')

//+------------------------------------------------------------------------------------------------------------+//
//+--- Engine                                                                                                ---+//
//+------------------------------------------------------------------------------------------------------------+//
calc_engine() =>
    up    = ta.change(high)
    down  = -ta.change(low)
    plusDM  = na(up)   ? na : (up   > down and up   > 0 ? up   : 0)
    minusDM = na(down) ? na : (down > up   and down > 0 ? down : 0)
    trur    = ta.rma(ta.tr, dir_len)
    dirP    = 100 * ta.rma(plusDM,  dir_len) / trur
    dirM    = 100 * ta.rma(minusDM, dir_len) / trur
    sum     = dirP + dirM
    dx      = 100 * math.abs(dirP - dirM) / (sum == 0 ? 1 : sum)
    score   = ta.rma(dx, trend_len)
    [score, dirP, dirM]

to_tf(simple string lbl) =>
    switch lbl
        "M1"  => "1"
        "M3"  => "3"
        "M5"  => "5"
        "M15" => "15"
        "M30" => "30"
        "H1"  => "60"
        "H2"  => "120"
        "H4"  => "240"
        "D"   => "D"
        =>       "1"

[s_1, p_1, m_1] = request.security(syminfo.tickerid, to_tf(tf1), calc_engine(), lookahead=barmerge.lookahead_off)
[s_2, p_2, m_2] = request.security(syminfo.tickerid, to_tf(tf2), calc_engine(), lookahead=barmerge.lookahead_off)
[s_3, p_3, m_3] = request.security(syminfo.tickerid, to_tf(tf3), calc_engine(), lookahead=barmerge.lookahead_off)
[s_4, p_4, m_4] = request.security(syminfo.tickerid, to_tf(tf4), calc_engine(), lookahead=barmerge.lookahead_off)
[s_5, p_5, m_5] = request.security(syminfo.tickerid, to_tf(tf5), calc_engine(), lookahead=barmerge.lookahead_off)
[s_6, p_6, m_6] = request.security(syminfo.tickerid, to_tf(tf6), calc_engine(), lookahead=barmerge.lookahead_off)

//+------------------------------------------------------------------------------------------------------------+//
//+--- Classification helpers                                                                                ---+//
//+------------------------------------------------------------------------------------------------------------+//
tier_label(float s) =>
    na(s)             ? "—"           :
     s >= th_vstrong  ? "Very Strong" :
     s >= th_strong   ? "Strong"      :
     s >= th_weak     ? "Weak"        : "No Trend"

tier_color(float s) =>
    na(s)             ? c_none    :
     s >= th_vstrong  ? c_vstrong :
     s >= th_strong   ? c_strong  :
     s >= th_weak     ? c_weakish : c_none

dir_label(float p, float m) =>
    na(p) or na(m) ? "—" : p > m ? "Bull" : p < m ? "Bear" : "Flat"

dir_color(float p, float m) =>
    na(p) or na(m) ? c_row_bg : p > m ? c_bull : p < m ? c_bear : c_row_bg

//+------------------------------------------------------------------------------------------------------------+//
//+--- Alignment flags (for alerts) — NA rows are treated as "neutral" and don't break alignment             ---+//
//+------------------------------------------------------------------------------------------------------------+//
strong_or_skip(string lbl, float s) => lbl == "NA" or s >= th_strong
bull_or_skip(string lbl, float p, float m)   => lbl == "NA" or p > m
bear_or_skip(string lbl, float p, float m)   => lbl == "NA" or p < m

all_strong = strong_or_skip(tf1, s_1) and strong_or_skip(tf2, s_2) and strong_or_skip(tf3, s_3) and
             strong_or_skip(tf4, s_4) and strong_or_skip(tf5, s_5) and strong_or_skip(tf6, s_6)

all_bull   = bull_or_skip(tf1, p_1, m_1) and bull_or_skip(tf2, p_2, m_2) and bull_or_skip(tf3, p_3, m_3) and
             bull_or_skip(tf4, p_4, m_4) and bull_or_skip(tf5, p_5, m_5) and bull_or_skip(tf6, p_6, m_6)

all_bear   = bear_or_skip(tf1, p_1, m_1) and bear_or_skip(tf2, p_2, m_2) and bear_or_skip(tf3, p_3, m_3) and
             bear_or_skip(tf4, p_4, m_4) and bear_or_skip(tf5, p_5, m_5) and bear_or_skip(tf6, p_6, m_6)

//+------------------------------------------------------------------------------------------------------------+//
//+--- Table                                                                                                 ---+//
//+------------------------------------------------------------------------------------------------------------+//
pos = table_pos == "top_left"      ? position.top_left      :
      table_pos == "top_right"     ? position.top_right     :
      table_pos == "middle_left"   ? position.middle_left   :
      table_pos == "middle_right"  ? position.middle_right  :
      table_pos == "bottom_left"   ? position.bottom_left   :
                                     position.bottom_right

tsz = table_size == "tiny"   ? size.tiny   :
      table_size == "small"  ? size.small  :
      table_size == "large"  ? size.large  : size.normal

var table dash = table.new(pos, 4, 9, border_width=1)

f_row(int r, string tf, float s, float p, float m) =>
    bg = tier_color(s)
    s_str = na(s) ? "—" : str.tostring(s, "#.0")
    table.cell(dash, 0, r, tf,             bgcolor=c_row_bg,        text_color=c_row_tx, text_size=tsz)
    table.cell(dash, 1, r, s_str,          bgcolor=bg,              text_color=c_row_tx, text_size=tsz)
    table.cell(dash, 2, r, tier_label(s),  bgcolor=bg,              text_color=c_row_tx, text_size=tsz)
    if show_dir
        table.cell(dash, 3, r, dir_label(p, m), bgcolor=dir_color(p, m), text_color=c_row_tx, text_size=tsz)

if barstate.islast
    table.clear(dash, 0, 0, 3, 8)
    table.cell(dash, 0, 0, "TF",             bgcolor=c_header_bg, text_color=c_header_tx, text_size=tsz)
    table.cell(dash, 1, 0, "Trend Strength", bgcolor=c_header_bg, text_color=c_header_tx, text_size=tsz)
    table.cell(dash, 2, 0, "Tier",           bgcolor=c_header_bg, text_color=c_header_tx, text_size=tsz)
    if show_dir
        table.cell(dash, 3, 0, "Direction",  bgcolor=c_header_bg, text_color=c_header_tx, text_size=tsz)

    int r = 1
    if tf1 != "NA"
        f_row(r, tf1, s_1, p_1, m_1)
        r := r + 1
    if tf2 != "NA"
        f_row(r, tf2, s_2, p_2, m_2)
        r := r + 1
    if tf3 != "NA"
        f_row(r, tf3, s_3, p_3, m_3)
        r := r + 1
    if tf4 != "NA"
        f_row(r, tf4, s_4, p_4, m_4)
        r := r + 1
    if tf5 != "NA"
        f_row(r, tf5, s_5, p_5, m_5)
        r := r + 1
    if tf6 != "NA"
        f_row(r, tf6, s_6, p_6, m_6)
        r := r + 1

    table.cell(dash, 0, r, "© Syouske", bgcolor=c_header_bg, text_color=c_header_tx, text_size=tsz)
    table.cell(dash, 1, r, "",          bgcolor=c_header_bg, text_color=c_header_tx, text_size=tsz)
    table.cell(dash, 2, r, "",          bgcolor=c_header_bg, text_color=c_header_tx, text_size=tsz)
    table.cell(dash, 3, r, "",          bgcolor=c_header_bg, text_color=c_header_tx, text_size=tsz)
    table.merge_cells(dash, 0, r, 3, r)

//+------------------------------------------------------------------------------------------------------------+//
//+--- Alerts                                                                                                ---+//
//+------------------------------------------------------------------------------------------------------------+//
alertcondition(all_strong,              title="All TFs Strong",  message="Trend Strength Dashboard: trend strength ≥ Strong on every TF")
alertcondition(all_strong and all_bull, title="All TFs Bullish", message="Trend Strength Dashboard: aligned bullish across all TFs")
alertcondition(all_strong and all_bear, title="All TFs Bearish", message="Trend Strength Dashboard: aligned bearish across all TFs")
````

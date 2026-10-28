# TT 4H Market Structure + 1H S&R Zones

- url: https://www.tradingview.com/script/7vC0fnUb-TT-4H-Market-Structure-1H-S-R-Zones/
- type: indicator
- pine_id: PUB;ea59adc86d5c47f4a44cae1789bc406a
- version: 1.0

## Description

TT Helper. For anyone struggling with Market Structure and S&R Zones

## Source Code

````pine
// ============================================================
// Market Structure (4H) + Support & Resistance Zones (1H)
// Version: 1.0
// Detects: BOS, CHoCH, HH/HL/LH/LL on 4H
// S/R Zones: 2 most recent swing H/L pivots on 1H
// ============================================================
//@version=5
indicator("4H Market Structure + 1H S&R Zones", overlay=true, max_lines_count=100, max_labels_count=100, max_boxes_count=50)

// ============================================================
// INPUTS
// ============================================================
grp1 = "── 4H Market Structure ──"
show_structure    = input.bool(true,  "Show Market Structure Labels",  group=grp1)
show_bos          = input.bool(true,  "Show BOS (Break of Structure)", group=grp1)
show_choch        = input.bool(true,  "Show CHoCH (Change of Char.)",  group=grp1)
show_hhlh         = input.bool(true,  "Show HH / HL / LH / LL Labels",group=grp1)
swing_len_4h      = input.int(10,     "4H Swing Pivot Length",         group=grp1, minval=3, maxval=50)

grp2 = "── 1H Support & Resistance ──"
show_sr           = input.bool(true,  "Show 1H S&R Zones",             group=grp2)
zone_width        = input.float(0.002,"Zone Width (% of price)",        group=grp2, minval=0.0005, maxval=0.02, step=0.0001)
swing_len_1h      = input.int(10,     "1H Swing Pivot Length",          group=grp2, minval=3, maxval=50)

grp3 = "── Colours ──"
col_bull          = input.color(color.new(#00e676, 0),   "Bullish / Support Colour", group=grp3)
col_bear          = input.color(color.new(#ff1744, 0),   "Bearish / Resistance Colour", group=grp3)
col_choch         = input.color(color.new(#ff9800, 0),   "CHoCH Colour",             group=grp3)
col_bos           = input.color(color.new(#29b6f6, 0),   "BOS Colour",               group=grp3)
col_zone_sup      = input.color(color.new(#00e676, 85),  "Support Zone Fill",         group=grp3)
col_zone_res      = input.color(color.new(#ff1744, 85),  "Resistance Zone Fill",      group=grp3)

// ============================================================
// UTILITY: Request HTF data cleanly
// ============================================================
f_htf_high(tf, len) =>
    request.security(syminfo.tickerid, tf, ta.pivothigh(high, len, len), lookahead=barmerge.lookahead_off)

f_htf_low(tf, len) =>
    request.security(syminfo.tickerid, tf, ta.pivotlow(low, len, len), lookahead=barmerge.lookahead_off)

f_htf_close(tf) =>
    request.security(syminfo.tickerid, tf, close, lookahead=barmerge.lookahead_off)

f_htf_bar_index(tf) =>
    request.security(syminfo.tickerid, tf, bar_index, lookahead=barmerge.lookahead_off)

// ============================================================
// 4H MARKET STRUCTURE
// ============================================================
ph_4h = f_htf_high("240", swing_len_4h)
pl_4h = f_htf_low ("240", swing_len_4h)

// Track last two confirmed swing highs and lows on 4H
var float ph1_4h = na  // most recent swing high
var float ph2_4h = na  // previous swing high
var float pl1_4h = na  // most recent swing low
var float pl2_4h = na  // previous swing low
var int   ph1_bar = na
var int   pl1_bar = na

// Track market bias
var int   ms_bias = 0   // 1 = bullish, -1 = bearish, 0 = undefined

// Update swing pivots
if not na(ph_4h)
    ph2_4h := ph1_4h
    ph1_4h := ph_4h
    ph1_bar := bar_index

if not na(pl_4h)
    pl2_4h := pl1_4h
    pl1_4h := pl_4h
    pl1_bar := bar_index

// ── Structure labels: HH, HL, LH, LL ──
var label lbl_last_ph = na
var label lbl_last_pl = na

htf_close_4h = f_htf_close("240")

if show_hhlh and show_structure
    if not na(ph_4h) and not na(ph2_4h)
        is_hh = ph1_4h > ph2_4h
        lbl_txt = is_hh ? "HH" : "LH"
        lbl_col = is_hh ? col_bull : col_bear
        label.delete(lbl_last_ph)
        lbl_last_ph := label.new(bar_index, ph_4h, lbl_txt,
             style=label.style_label_down, color=lbl_col,
             textcolor=color.white, size=size.small)

    if not na(pl_4h) and not na(pl2_4h)
        is_hl = pl1_4h > pl2_4h
        lbl_txt = is_hl ? "HL" : "LL"
        lbl_col = is_hl ? col_bull : col_bear
        label.delete(lbl_last_pl)
        lbl_last_pl := label.new(bar_index, pl_4h, lbl_txt,
             style=label.style_label_up, color=lbl_col,
             textcolor=color.white, size=size.small)

// ── BOS Detection ──
// Bullish BOS: price closes above the most recent swing HIGH (continuation up)
// Bearish BOS: price closes below the most recent swing LOW  (continuation down)
var line  bos_line  = na
var label bos_label = na
var float last_bos_high = na
var float last_bos_low  = na

htf_4h_close = f_htf_close("240")

bull_bos = show_bos and not na(ph1_4h) and htf_4h_close > ph1_4h and htf_4h_close[1] <= ph1_4h
bear_bos = show_bos and not na(pl1_4h) and htf_4h_close < pl1_4h and htf_4h_close[1] >= pl1_4h

if bull_bos
    ms_bias := 1
    if show_structure
        bos_line  := line.new(ph1_bar, ph1_4h, bar_index, ph1_4h, color=col_bos, style=line.style_dashed, width=1)
        bos_label := label.new(bar_index, ph1_4h, "BOS ▲", style=label.style_label_left, color=col_bos, textcolor=color.white, size=size.small)

if bear_bos
    ms_bias := -1
    if show_structure
        bos_line  := line.new(pl1_bar, pl1_4h, bar_index, pl1_4h, color=col_bos, style=line.style_dashed, width=1)
        bos_label := label.new(bar_index, pl1_4h, "BOS ▼", style=label.style_label_left, color=col_bos, textcolor=color.white, size=size.small)

// ── CHoCH Detection ──
// Bullish CHoCH: bias was bearish, price closes ABOVE last swing HIGH  → reversal signal
// Bearish CHoCH: bias was bullish, price closes BELOW last swing LOW   → reversal signal
var line  choch_line  = na
var label choch_label = na

bull_choch = show_choch and ms_bias == -1 and not na(ph1_4h) and htf_4h_close > ph1_4h and htf_4h_close[1] <= ph1_4h
bear_choch = show_choch and ms_bias ==  1 and not na(pl1_4h) and htf_4h_close < pl1_4h and htf_4h_close[1] >= pl1_4h

if bull_choch
    ms_bias := 1
    if show_structure
        choch_line  := line.new(ph1_bar, ph1_4h, bar_index, ph1_4h, color=col_choch, style=line.style_dotted, width=2)
        choch_label := label.new(bar_index, ph1_4h, "CHoCH ▲", style=label.style_label_left, color=col_choch, textcolor=color.white, size=size.small)

if bear_choch
    ms_bias := -1
    if show_structure
        choch_line  := line.new(pl1_bar, pl1_4h, bar_index, pl1_4h, color=col_choch, style=line.style_dotted, width=2)
        choch_label := label.new(bar_index, pl1_4h, "CHoCH ▼", style=label.style_label_left, color=col_choch, textcolor=color.white, size=size.small)

// ── Bias Table ──
var table bias_tbl = table.new(position.top_right, 1, 2, bgcolor=color.new(color.black, 60), border_width=1)
bias_str  = ms_bias ==  1 ? "▲ BULLISH" : ms_bias == -1 ? "▼ BEARISH" : "— NEUTRAL"
bias_col  = ms_bias ==  1 ? col_bull    : ms_bias == -1  ? col_bear    : color.gray
table.cell(bias_tbl, 0, 0, "4H Structure", text_color=color.white,  text_size=size.small, bgcolor=color.new(color.black,60))
table.cell(bias_tbl, 0, 1, bias_str,       text_color=bias_col,     text_size=size.normal, bgcolor=color.new(color.black,60))

// ============================================================
// 1H SUPPORT & RESISTANCE ZONES (2 most recent swing H & L)
// ============================================================
ph_1h = f_htf_high("60", swing_len_1h)
pl_1h = f_htf_low ("60", swing_len_1h)

// Store 2 most recent 1H swing highs and lows
var float res1 = na   // most recent resistance
var float res2 = na   // 2nd most recent resistance
var float sup1 = na   // most recent support
var float sup2 = na   // 2nd most recent support

if not na(ph_1h)
    res2 := res1
    res1 := ph_1h

if not na(pl_1h)
    sup2 := sup1
    sup1 := pl_1h

// ── Draw S/R Zone Boxes ──
// Boxes extend from their detected bar to the right edge of the chart
// They are redrawn each bar to stay current

var box box_res1 = na
var box box_res2 = na
var box box_sup1 = na
var box box_sup2 = na

f_zone_top(price)    => price * (1 + zone_width / 2)
f_zone_bot(price)    => price * (1 - zone_width / 2)

if show_sr and barstate.islast
    // Resistance zone 1 (most recent)
    if not na(res1)
        box.delete(box_res1)
        box_res1 := box.new(bar_index - 80, f_zone_top(res1), bar_index + 20, f_zone_bot(res1),
             border_color=col_bear, border_width=1,
             bgcolor=col_zone_res)
        label.new(bar_index + 20, res1, "R1: " + str.tostring(res1, format.mintick),
             style=label.style_label_left, color=color.new(col_bear,20),
             textcolor=color.white, size=size.small)

    // Resistance zone 2
    if not na(res2) and res2 != res1
        box.delete(box_res2)
        box_res2 := box.new(bar_index - 80, f_zone_top(res2), bar_index + 20, f_zone_bot(res2),
             border_color=color.new(col_bear, 40), border_width=1,
             bgcolor=color.new(col_zone_res[0], 92))
        label.new(bar_index + 20, res2, "R2: " + str.tostring(res2, format.mintick),
             style=label.style_label_left, color=color.new(col_bear,40),
             textcolor=color.white, size=size.small)

    // Support zone 1 (most recent)
    if not na(sup1)
        box.delete(box_sup1)
        box_sup1 := box.new(bar_index - 80, f_zone_top(sup1), bar_index + 20, f_zone_bot(sup1),
             border_color=col_bull, border_width=1,
             bgcolor=col_zone_sup)
        label.new(bar_index + 20, sup1, "S1: " + str.tostring(sup1, format.mintick),
             style=label.style_label_left, color=color.new(col_bull,20),
             textcolor=color.white, size=size.small)

    // Support zone 2
    if not na(sup2) and sup2 != sup1
        box.delete(box_sup2)
        box_sup2 := box.new(bar_index - 80, f_zone_top(sup2), bar_index + 20, f_zone_bot(sup2),
             border_color=color.new(col_bull, 40), border_width=1,
             bgcolor=color.new(col_zone_sup[0], 92))
        label.new(bar_index + 20, sup2, "S2: " + str.tostring(sup2, format.mintick),
             style=label.style_label_left, color=color.new(col_bull,40),
             textcolor=color.white, size=size.small)

// ============================================================
// PLOTS: Current price vs nearest S/R
// ============================================================
// Highlight candle background when price enters a zone
in_res1 = not na(res1) and high >= f_zone_bot(res1) and low <= f_zone_top(res1)
in_sup1 = not na(sup1) and high >= f_zone_bot(sup1) and low <= f_zone_top(sup1)

bgcolor(in_res1 ? color.new(col_bear, 88) : na, title="Inside Resistance Zone")
bgcolor(in_sup1 ? color.new(col_bull, 88) : na, title="Inside Support Zone")
````

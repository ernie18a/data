# DYL x iFVG MODEL

- url: https://www.tradingview.com/script/th2nLepG-DYL-x-iFVG-MODEL/
- type: indicator
- pine_id: PUB;583407180b3e474dbcd32505ddbed643
- version: 1.0

## Description

ICT x iFVG Model used to indicate when A+ setups appear.
Confluence
- HTF Rejection out of FVG

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © DYL MODEL - Built for NQ/ES ICT Confluence Grading

//@version=5
indicator("DYL x iFVG MODEL", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ============================================================
// INPUTS
// ============================================================

// --- SMT ---
grp_smt = "SMT Settings"
show_smt       = input.bool(true,  "Show SMT Divergence",      group=grp_smt)
smt_tf         = input.timeframe("1", "SMT Comparison Timeframe", group=grp_smt, options=["1","5","15","60"])
smt_symbol     = input.symbol("CME_MINI:ES1!", "Comparison Asset (ES)", group=grp_smt)

// --- FVG ---
grp_fvg = "FVG Settings"
show_htf_fvg   = input.bool(true,  "Show HTF FVGs (30m/1H/4H)", group=grp_fvg)
show_ltf_fvg   = input.bool(true,  "Show LTF FVGs (5m/15m)",    group=grp_fvg)
show_ifvg      = input.bool(true,  "Show iFVG (1m/2m/3m)",      group=grp_fvg)
fvg_bull_col   = input.color(color.new(color.green, 70), "Bullish FVG Color", group=grp_fvg)
fvg_bear_col   = input.color(color.new(color.red,   70), "Bearish FVG Color", group=grp_fvg)

// --- Sessions ---
grp_sess = "Session Highs/Lows"
show_sessions  = input.bool(true, "Show Session Highs/Lows", group=grp_sess)

// --- EQH/EQL ---
grp_eq = "Equal Highs/Lows"
show_eqhql     = input.bool(true,  "Show EQH/EQL",    group=grp_eq)
eq_threshold   = input.float(1.0,  "EQ Threshold (points)", group=grp_eq)
eq_lookback    = input.int(1440,   "EQL Lookback (bars @ 1min = 24H)", group=grp_eq, minval=50, maxval=5000)

// --- Volume ---
grp_vol = "Volume"
show_vol       = input.bool(true, "Show Volume Confluence", group=grp_vol)
vol_ma_len     = input.int(20, "Volume MA Length", group=grp_vol)

// --- ATH ---
grp_ath = "All Time High"
show_ath       = input.bool(true, "Show All Time High", group=grp_ath)

// --- Grading Overrides ---
grp_grade = "Manual Grade Overrides"
man_smt        = input.bool(false, "SMT (manual override)",        group=grp_grade)
man_htf_fvg    = input.bool(false, "HTF FVG Rejection (manual)",   group=grp_grade)
man_ltf_fvg    = input.bool(false, "LTF FVG Rejection (manual)",   group=grp_grade)
man_ifvg       = input.bool(false, "iFVG Closure (manual)",        group=grp_grade)
man_vol        = input.bool(false, "Volume (manual)",              group=grp_grade)

// ============================================================
// SMT DIVERGENCE
// ============================================================
[es_high, es_low] = request.security(smt_symbol, smt_tf, [high, low], lookahead=barmerge.lookahead_off)
[nq_high, nq_low] = request.security(syminfo.tickerid, smt_tf, [high, low], lookahead=barmerge.lookahead_off)

lookback_smt  = 5
nq_prev_high  = ta.highest(nq_high, lookback_smt)[1]
es_prev_high  = ta.highest(es_high, lookback_smt)[1]
nq_prev_low   = ta.lowest(nq_low,  lookback_smt)[1]
es_prev_low   = ta.lowest(es_low,  lookback_smt)[1]

bear_smt = nq_high > nq_prev_high and es_high < es_prev_high
bull_smt = nq_low  < nq_prev_low  and es_low  > es_prev_low

smt_detected  = show_smt and (bear_smt or bull_smt)

var line  smt_line = na
var label smt_lbl  = na

if smt_detected
    prev_bar   = bar_index - lookback_smt
    prev_price = bear_smt ? nq_prev_high : nq_prev_low
    cur_price  = bear_smt ? nq_high      : nq_low

    if not na(smt_line)
        line.delete(smt_line)
    if not na(smt_lbl)
        label.delete(smt_lbl)

    smt_line := line.new(x1=prev_bar, y1=prev_price, x2=bar_index, y2=cur_price,
         color=color.black, style=line.style_dashed, width=2)

    mid_bar   = math.round((prev_bar + bar_index) / 2)
    mid_price = (prev_price + cur_price) / 2
    smt_lbl  := label.new(mid_bar, mid_price, "smt",
         color=color.new(color.white, 100), textcolor=color.black,
         style=label.style_label_center, size=size.small)

var bool smt_active = false
smt_active := smt_detected ? true : smt_active[1]
auto_smt = smt_active or man_smt

// ============================================================
// FVG HELPER
// ============================================================
get_fvg(tf) =>
    h1 = request.security(syminfo.tickerid, tf, high[2],  lookahead=barmerge.lookahead_off)
    l1 = request.security(syminfo.tickerid, tf, low[2],   lookahead=barmerge.lookahead_off)
    h3 = request.security(syminfo.tickerid, tf, high,     lookahead=barmerge.lookahead_off)
    l3 = request.security(syminfo.tickerid, tf, low,      lookahead=barmerge.lookahead_off)
    bull_fvg = l3 > h1
    bear_fvg = h3 < l1
    fvg_top  = bull_fvg ? l3 : (bear_fvg ? l1 : na)
    fvg_bot  = bull_fvg ? h1 : (bear_fvg ? h3 : na)
    [bull_fvg or bear_fvg, fvg_top, fvg_bot, bull_fvg]

draw_fvg_box(top, bot, is_bull, transp, tf_label) =>
    col = color.new(is_bull ? fvg_bull_col : fvg_bear_col, transp)
    box.new(bar_index - 2, top, bar_index + 50, bot, border_color=col, bgcolor=col)
    label.new(bar_index - 2, (top + bot) / 2, tf_label,
         color=color.new(color.white, 100),
         textcolor=is_bull ? color.green : color.red,
         style=label.style_label_right, size=size.tiny)

// ============================================================
// HTF FVGs
// ============================================================
[fvg_30m, top_30m, bot_30m, bull_30m] = get_fvg("30")
[fvg_1h,  top_1h,  bot_1h,  bull_1h ] = get_fvg("60")
[fvg_4h,  top_4h,  bot_4h,  bull_4h ] = get_fvg("240")

if show_htf_fvg
    if fvg_30m
        draw_fvg_box(top_30m, bot_30m, bull_30m, 75, "30m FVG")
    if fvg_1h
        draw_fvg_box(top_1h,  bot_1h,  bull_1h,  80, "1H FVG")
    if fvg_4h
        draw_fvg_box(top_4h,  bot_4h,  bull_4h,  85, "4H FVG")

// ============================================================
// LTF FVGs
// ============================================================
[fvg_5m,  top_5m,  bot_5m,  bull_5m ] = get_fvg("5")
[fvg_15m, top_15m, bot_15m, bull_15m] = get_fvg("15")

if show_ltf_fvg
    if fvg_5m
        draw_fvg_box(top_5m,  bot_5m,  bull_5m,  55, "5m FVG")
    if fvg_15m
        draw_fvg_box(top_15m, bot_15m, bull_15m, 60, "15m FVG")

// ============================================================
// HTF FVG REJECTION
// ============================================================
check_rejection(fvg_exists, top, bot, is_bull) =>
    in_zone = low <= top and high >= bot
    result  = false
    if fvg_exists and in_zone
        result := is_bull ? close > bot : close < top
    result

htf_fvg_rejection = check_rejection(fvg_30m, top_30m, bot_30m, bull_30m) or
     check_rejection(fvg_1h, top_1h, bot_1h, bull_1h) or
     check_rejection(fvg_4h, top_4h, bot_4h, bull_4h)

auto_htf = htf_fvg_rejection or man_htf_fvg

// ============================================================
// LTF FVG REJECTION
// ============================================================
ltf_fvg_rejection = check_rejection(fvg_5m,  top_5m,  bot_5m,  bull_5m) or
     check_rejection(fvg_15m, top_15m, bot_15m, bull_15m)

auto_ltf = ltf_fvg_rejection or man_ltf_fvg

// ============================================================
// iFVG (1m / 2m / 3m)
// ============================================================
[fvg_1m, top_1m, bot_1m, bull_1m] = get_fvg("1")
[fvg_2m, top_2m, bot_2m, bull_2m] = get_fvg("2")
[fvg_3m, top_3m, bot_3m, bull_3m] = get_fvg("3")

detect_ifvg(fvg_exists, top, bot, is_bull) =>
    fvg_exists and (is_bull ? close < bot : close > top)

ifvg_1m = show_ifvg and detect_ifvg(fvg_1m, top_1m, bot_1m, bull_1m)
ifvg_2m = show_ifvg and detect_ifvg(fvg_2m, top_2m, bot_2m, bull_2m)
ifvg_3m = show_ifvg and detect_ifvg(fvg_3m, top_3m, bot_3m, bull_3m)

ifvg_detected   = ifvg_1m or ifvg_2m or ifvg_3m
ifvg_tf_label   = ifvg_1m ? "1m iFVG" : (ifvg_2m ? "2m iFVG" : (ifvg_3m ? "3m iFVG" : "iFVG"))

if ifvg_detected
    t_ifvg   = ifvg_1m ? top_1m : (ifvg_2m ? top_2m : top_3m)
    b_ifvg   = ifvg_1m ? bot_1m : (ifvg_2m ? bot_2m : bot_3m)
    ifvg_c   = color.new(color.blue, 40)
    box.new(bar_index - 3, t_ifvg, bar_index, b_ifvg, border_color=ifvg_c, bgcolor=ifvg_c)
    label.new(bar_index - 1, (t_ifvg + b_ifvg) / 2, ifvg_tf_label,
         color=color.new(color.white, 100), textcolor=color.white,
         style=label.style_label_left, size=size.small)

auto_ifvg = ifvg_detected or man_ifvg

// ============================================================
// VOLUME
// ============================================================
vol_ma   = ta.sma(volume, vol_ma_len)
good_vol = volume >= vol_ma
auto_vol = (show_vol and good_vol) or man_vol

// ============================================================
// SESSION HIGHS / LOWS
// ============================================================
is_ny     = not na(time("1", "0930-1600", "America/New_York"))
is_london = not na(time("1", "0300-0830", "America/New_York"))
is_asia   = not na(time("1", "2000-2359", "America/New_York"))

var float ny_h = na, var float ny_l = na
var float ld_h = na, var float ld_l = na
var float as_h = na, var float as_l = na
var bool  ny_was = false, var bool ld_was = false, var bool as_was = false

if show_sessions
    if is_ny
        ny_h := na(ny_h) ? high : math.max(ny_h, high)
        ny_l := na(ny_l) ? low  : math.min(ny_l, low)
    if not is_ny and ny_was
        line.new(bar_index, ny_h, bar_index + 200, ny_h, color=color.green, width=1, extend=extend.right)
        line.new(bar_index, ny_l, bar_index + 200, ny_l, color=color.green, width=1, extend=extend.right)
        label.new(bar_index + 3, ny_h, "NY High", color=color.new(color.white,100), textcolor=color.green, size=size.tiny, style=label.style_label_left)
        label.new(bar_index + 3, ny_l, "NY Low",  color=color.new(color.white,100), textcolor=color.green, size=size.tiny, style=label.style_label_left)
        ny_h := na
        ny_l := na

    if is_london
        ld_h := na(ld_h) ? high : math.max(ld_h, high)
        ld_l := na(ld_l) ? low  : math.min(ld_l, low)
    if not is_london and ld_was
        line.new(bar_index, ld_h, bar_index + 200, ld_h, color=color.red, width=1, extend=extend.right)
        line.new(bar_index, ld_l, bar_index + 200, ld_l, color=color.red, width=1, extend=extend.right)
        label.new(bar_index + 3, ld_h, "London High", color=color.new(color.white,100), textcolor=color.red, size=size.tiny, style=label.style_label_left)
        label.new(bar_index + 3, ld_l, "London Low",  color=color.new(color.white,100), textcolor=color.red, size=size.tiny, style=label.style_label_left)
        ld_h := na
        ld_l := na

    if is_asia
        as_h := na(as_h) ? high : math.max(as_h, high)
        as_l := na(as_l) ? low  : math.min(as_l, low)
    if not is_asia and as_was
        line.new(bar_index, as_h, bar_index + 200, as_h, color=color.blue, width=1, extend=extend.right)
        line.new(bar_index, as_l, bar_index + 200, as_l, color=color.blue, width=1, extend=extend.right)
        label.new(bar_index + 3, as_h, "Asia High", color=color.new(color.white,100), textcolor=color.blue, size=size.tiny, style=label.style_label_left)
        label.new(bar_index + 3, as_l, "Asia Low",  color=color.new(color.white,100), textcolor=color.blue, size=size.tiny, style=label.style_label_left)
        as_h := na
        as_l := na

ny_was := is_ny
ld_was := is_london
as_was := is_asia

// ============================================================
// ALL TIME HIGH
// ============================================================
var float ath_val  = na
var line  ath_ln   = na
var label ath_lbl  = na

ath_val := na(ath_val) ? high : math.max(ath_val, high)

if show_ath and high >= nz(ath_val[1], high)
    if not na(ath_ln)
        line.delete(ath_ln)
    if not na(ath_lbl)
        label.delete(ath_lbl)
    ath_ln  := line.new(bar_index, ath_val, bar_index + 300, ath_val,
         color=color.orange, style=line.style_dotted, width=2, extend=extend.right)
    ath_lbl := label.new(bar_index + 5, ath_val, "ATH",
         color=color.new(color.white,100), textcolor=color.orange,
         style=label.style_label_left, size=size.small)

// ============================================================
// EQUAL HIGHS / LOWS
// ============================================================
if show_eqhql and barstate.isconfirmed
    lb = math.min(bar_index, eq_lookback)
    found_h = false
    found_l = false
    for i = 1 to lb
        if not found_h and math.abs(high - high[i]) <= eq_threshold
            line.new(bar_index - i, high[i], bar_index, high,
                 color=color.new(color.gray, 20), style=line.style_dashed, width=1)
            label.new(bar_index, high, "EQH",
                 color=color.new(color.white,100), textcolor=color.gray,
                 style=label.style_label_down, size=size.tiny)
            found_h := true
        if not found_l and math.abs(low - low[i]) <= eq_threshold
            line.new(bar_index - i, low[i], bar_index, low,
                 color=color.new(color.gray, 20), style=line.style_dashed, width=1)
            label.new(bar_index, low, "EQL",
                 color=color.new(color.white,100), textcolor=color.gray,
                 style=label.style_label_up, size=size.tiny)
            found_l := true
        if found_h and found_l
            break

// ============================================================
// GRADING
// ============================================================
score = (auto_smt ? 1 : 0) + (auto_htf ? 1 : 0) + (auto_ltf ? 1 : 0) + (auto_ifvg ? 1 : 0) + (auto_vol ? 1 : 0)

grade = score == 5 ? "A+" : score == 4 ? "A-" : score == 3 ? "B+" :
     score == 2 ? "B-" : score == 1 ? "C+" : "C-"

grade_col = score >= 4 ? color.green : score == 3 ? color.yellow : score == 2 ? color.orange : color.red

// ============================================================
// ALERT (once per setup, fires at 3+)
// ============================================================
var int last_alert_bar = na
alert_cond = score >= 3 and barstate.isconfirmed and (na(last_alert_bar) or bar_index - last_alert_bar > 10)

if alert_cond
    last_alert_bar := bar_index
    alert("DYL MODEL — " + grade + " Setup | Score: " + str.tostring(score) + "/5", alert.freq_once_per_bar_close)

// ============================================================
// HEADER LABEL
// ============================================================
var label header_lbl = na
if barstate.islast
    if not na(header_lbl)
        label.delete(header_lbl)
    header_lbl := label.new(bar_index, ta.highest(high, 500),
         "DYL x iFVG MODEL",
         color=color.new(color.white, 100),
         textcolor=color.white,
         style=label.style_label_down,
         size=size.large,
         textalign=text.align_center)

// ============================================================
// DASHBOARD TABLE
// ============================================================
var table dash = table.new(position.bottom_right, 2, 8,
     bgcolor=color.new(color.black, 20),
     border_color=color.new(color.gray, 50),
     border_width=1,
     frame_color=color.new(color.gray, 30),
     frame_width=1)

if barstate.islast
    smt_sym  = auto_smt  ? "✔" : "✗"
    htf_sym  = auto_htf  ? "✔" : "✗"
    ltf_sym  = auto_ltf  ? "✔" : "✗"
    ifvg_sym = auto_ifvg ? "✔" : "✗"
    vol_sym  = auto_vol  ? "✔" : "✗"

    smt_c    = auto_smt  ? color.green : color.red
    htf_c    = auto_htf  ? color.green : color.red
    ltf_c    = auto_ltf  ? color.green : color.red
    ifvg_c2  = auto_ifvg ? color.green : color.red
    vol_c    = auto_vol  ? color.green : color.red

    ifvg_row = "iFVG Closure" + (ifvg_detected ? " [" + ifvg_tf_label + "]" : "")

    table.cell(dash, 0, 0, "DYL MODEL",          text_color=color.white,  bgcolor=color.new(color.black,10), text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 1, 0, "GRADE: " + grade,    text_color=grade_col,    bgcolor=color.new(color.black,10), text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 0, 1, "SMT Divergence",      text_color=color.white,  bgcolor=color.new(color.black,30), text_size=size.tiny,  text_halign=text.align_left)
    table.cell(dash, 1, 1, smt_sym,               text_color=smt_c,        bgcolor=color.new(color.black,30), text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 0, 2, "HTF FVG Rejection",   text_color=color.white,  bgcolor=color.new(color.black,30), text_size=size.tiny,  text_halign=text.align_left)
    table.cell(dash, 1, 2, htf_sym,               text_color=htf_c,        bgcolor=color.new(color.black,30), text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 0, 3, "LTF FVG Rejection",   text_color=color.white,  bgcolor=color.new(color.black,30), text_size=size.tiny,  text_halign=text.align_left)
    table.cell(dash, 1, 3, ltf_sym,               text_color=ltf_c,        bgcolor=color.new(color.black,30), text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 0, 4, ifvg_row,              text_color=color.white,  bgcolor=color.new(color.black,30), text_size=size.tiny,  text_halign=text.align_left)
    table.cell(dash, 1, 4, ifvg_sym,              text_color=ifvg_c2,      bgcolor=color.new(color.black,30), text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 0, 5, "Volume",              text_color=color.white,  bgcolor=color.new(color.black,30), text_size=size.tiny,  text_halign=text.align_left)
    table.cell(dash, 1, 5, vol_sym,               text_color=vol_c,        bgcolor=color.new(color.black,30), text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 0, 6, "Score: " + str.tostring(score) + "/5", text_color=grade_col, bgcolor=color.new(color.black,20), text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 6, grade,                 text_color=grade_col,    bgcolor=color.new(color.black,20), text_size=size.normal, text_halign=text.align_center)
    table.cell(dash, 0, 7, "Vol MA(" + str.tostring(vol_ma_len) + "): " + (good_vol ? "ABOVE ✔" : "BELOW ✗"), text_color=good_vol ? color.green : color.red, bgcolor=color.new(color.black,30), text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 7, "Alert @3+",           text_color=color.gray,   bgcolor=color.new(color.black,30), text_size=size.tiny,  text_halign=text.align_center)
````

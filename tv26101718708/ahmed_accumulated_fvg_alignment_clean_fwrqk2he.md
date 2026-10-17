# Ahmed  Accumulated FVG Alignment CLEAN

- url: https://www.tradingview.com/script/FwrQk2HE-Ahmed-Accumulated-FVG-Alignment-CLEAN/
- type: indicator
- pine_id: PUB;c701a3d53a1b482a8786a9c5e3c6a5c5
- version: 2.0

## Description

This indicator scans multiple timeframes to detect Fair Value Gaps (FVG) and measure alignment across the market.

It tracks recent bullish and bearish FVG formations from lower to higher timeframes and calculates a live alignment score. The tool highlights when multiple timeframes are in agreement, helping traders identify high probability conditions.

The script also monitors the New York session kill zone (9:30 to 11:00 New York time), where volatility and trading opportunities are typically higher.

Main features:

* Multi timeframe FVG detection
* Bullish and bearish alignment scoring
* Simple sequence detection across 30s, 1m, and 3m
* Visual FVG zones on chart
* Dashboard showing real-time market state
* Alert conditions for strong alignment setups

This tool is designed for Nasdaq futures traders looking to align lower timeframe entries with higher timeframe direction.

## Source Code

````pine
//@version=5
indicator("Ahmed FVG v5", shorttitle="Ahmed FVG v5", overlay=true, max_boxes_count=50, max_labels_count=150, max_lines_count=50, max_bars_back=500)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
i_lookback    = input.int(5,     "FVG lookback bars per TF",     minval=1,  maxval=30)
i_min_size    = input.float(3.0, "Min FVG size (NQ points)",      minval=0,  step=0.5)
i_box_extend  = input.int(20,    "FVG box extend (bars)",          minval=1,  maxval=100)
i_thresh      = input.int(5,     "Min alignment score (of 10)",    minval=3,  maxval=10)
i_show_fvg    = input.bool(true,  "Show FVG boxes")
i_show_sweep  = input.bool(true,  "Show BSL/SSL sweep markers")
i_show_choch  = input.bool(true,  "Show CHoCH / BOS markers")
i_show_dash   = input.bool(true,  "Show dashboard")
i_kz_filter   = input.bool(true,  "Restrict entries to NY kill zone")
i_kz_bg       = input.bool(false, "Highlight kill zone background")
i_show_sess   = input.bool(true,  "Show session phase labels")
i_sess_bg     = input.bool(true,  "Show session backgrounds")
i_sess_filter = input.bool(true,  "Align entries with session phase")
i_struct_filt = input.bool(true,  "Require structure direction match")

// ─── TIME ────────────────────────────────────────────────────────────────────
ny_mins = hour(time, "America/New_York") * 60 + minute(time, "America/New_York")
in_kz   = ny_mins >= 570 and ny_mins < 660
kz_ok   = not i_kz_filter or in_kz
bgcolor(i_kz_bg and in_kz ? color.new(color.yellow, 94) : na, title="Kill zone bg")

// ─── SESSION WINDOWS (NY time) ───────────────────────────────────────────────
in_asia_sess = ny_mins >= 1200 or ny_mins < 60
in_lon_sess  = ny_mins >= 120  and ny_mins < 300
in_ny_sess   = ny_mins >= 570  and ny_mins < 720

bgcolor(i_sess_bg and in_asia_sess ? color.new(color.purple, 93) : na, title="Asia bg")
bgcolor(i_sess_bg and in_lon_sess  ? color.new(color.blue,   93) : na, title="London bg")
bgcolor(i_sess_bg and in_ny_sess   ? color.new(color.orange, 93) : na, title="NY bg")

asia_open  = in_asia_sess and not in_asia_sess[1]
asia_close = not in_asia_sess and in_asia_sess[1]
lon_open   = in_lon_sess  and not in_lon_sess[1]
ny_open    = in_ny_sess   and not in_ny_sess[1]

// ─── ASIA RANGE TRACKING ─────────────────────────────────────────────────────
var float asia_hi      = na
var float asia_lo      = na
var float prev_asia_hi = na
var float prev_asia_lo = na

if asia_open
    asia_hi := high
    asia_lo := low

if in_asia_sess
    asia_hi := math.max(nz(asia_hi, high), high)
    asia_lo := math.min(nz(asia_lo, low),  low)

if asia_close
    prev_asia_hi := asia_hi
    prev_asia_lo := asia_lo

// ─── LONDON SWEEP DETECTION ──────────────────────────────────────────────────
var bool lon_hi_swept = false
var bool lon_lo_swept = false

if lon_open
    lon_hi_swept := false
    lon_lo_swept := false

if in_lon_sess
    if not na(prev_asia_hi) and high > prev_asia_hi
        lon_hi_swept := true
    if not na(prev_asia_lo) and low  < prev_asia_lo
        lon_lo_swept := true

lon_manip_bull = lon_lo_swept and not lon_hi_swept
lon_manip_bear = lon_hi_swept and not lon_lo_swept
lon_manip_both = lon_hi_swept and lon_lo_swept

ny_dist_bull = lon_manip_bull
ny_dist_bear = lon_manip_bear

sess_bull_ok = not i_sess_filter or not in_ny_sess or ny_dist_bull or lon_manip_both or (not lon_manip_bull and not lon_manip_bear)
sess_bear_ok = not i_sess_filter or not in_ny_sess or ny_dist_bear or lon_manip_both or (not lon_manip_bull and not lon_manip_bear)

f_sess_name() =>
    in_asia_sess ? "ASIA" : in_lon_sess ? "LONDON" : in_ny_sess ? "NY" : "OFF"

f_sess_phase() =>
    in_asia_sess ? "ACCUMULATION" :
     in_lon_sess ? (lon_manip_bear ? "MANIP BEAR" : lon_manip_bull ? "MANIP BULL" : lon_manip_both ? "MANIP BOTH" : "ACCUMULATION") :
     in_ny_sess  ? (ny_dist_bull   ? "DIST BULL"  : ny_dist_bear   ? "DIST BEAR"  : "DISTRIBUTION") :
     "NO SESSION"

f_sess_col() =>
    in_asia_sess ? color.purple :
     in_lon_sess ? (lon_manip_bear or lon_manip_bull ? color.red : color.blue) :
     in_ny_sess  ? (ny_dist_bull ? color.lime : ny_dist_bear ? color.red : color.yellow) :
     color.gray

// ─── FVG FUNCTIONS (MTF) ─────────────────────────────────────────────────────
f_bull_since(tf) =>
    request.security(syminfo.tickerid, tf, ta.barssince(low > high[2] and (low - high[2]) >= i_min_size), lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)

f_bear_since(tf) =>
    request.security(syminfo.tickerid, tf, ta.barssince(high < low[2] and (low[2] - high) >= i_min_size), lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)

f_bull_top(tf) =>
    request.security(syminfo.tickerid, tf, ta.valuewhen(low > high[2] and (low - high[2]) >= i_min_size, low,    0), lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)

f_bull_bot(tf) =>
    request.security(syminfo.tickerid, tf, ta.valuewhen(low > high[2] and (low - high[2]) >= i_min_size, high[2],0), lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)

f_bear_top(tf) =>
    request.security(syminfo.tickerid, tf, ta.valuewhen(high < low[2] and (low[2] - high) >= i_min_size, low[2], 0), lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)

f_bear_bot(tf) =>
    request.security(syminfo.tickerid, tf, ta.valuewhen(high < low[2] and (low[2] - high) >= i_min_size, high,   0), lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)

// ─── MTF BARS SINCE LAST FVG ─────────────────────────────────────────────────
bs_bull_30s = f_bull_since("30S")
bs_bull_1m  = f_bull_since("1")
bs_bull_3m  = f_bull_since("3")
bs_bull_5m  = f_bull_since("5")
bs_bull_15m = f_bull_since("15")
bs_bull_30m = f_bull_since("30")
bs_bull_1h  = f_bull_since("60")
bs_bull_4h  = f_bull_since("240")
bs_bull_1d  = f_bull_since("D")
bs_bull_1w  = f_bull_since("W")

bs_bear_30s = f_bear_since("30S")
bs_bear_1m  = f_bear_since("1")
bs_bear_3m  = f_bear_since("3")
bs_bear_5m  = f_bear_since("5")
bs_bear_15m = f_bear_since("15")
bs_bear_30m = f_bear_since("30")
bs_bear_1h  = f_bear_since("60")
bs_bear_4h  = f_bear_since("240")
bs_bear_1d  = f_bear_since("D")
bs_bear_1w  = f_bear_since("W")

// ─── ACTIVE FVG FLAGS ────────────────────────────────────────────────────────
bull_30s = not na(bs_bull_30s) and bs_bull_30s <= i_lookback
bull_1m  = not na(bs_bull_1m)  and bs_bull_1m  <= i_lookback
bull_3m  = not na(bs_bull_3m)  and bs_bull_3m  <= i_lookback
bull_5m  = not na(bs_bull_5m)  and bs_bull_5m  <= i_lookback
bull_15m = not na(bs_bull_15m) and bs_bull_15m <= i_lookback
bull_30m = not na(bs_bull_30m) and bs_bull_30m <= i_lookback
bull_1h  = not na(bs_bull_1h)  and bs_bull_1h  <= i_lookback
bull_4h  = not na(bs_bull_4h)  and bs_bull_4h  <= i_lookback
bull_1d  = not na(bs_bull_1d)  and bs_bull_1d  <= i_lookback
bull_1w  = not na(bs_bull_1w)  and bs_bull_1w  <= i_lookback

bear_30s = not na(bs_bear_30s) and bs_bear_30s <= i_lookback
bear_1m  = not na(bs_bear_1m)  and bs_bear_1m  <= i_lookback
bear_3m  = not na(bs_bear_3m)  and bs_bear_3m  <= i_lookback
bear_5m  = not na(bs_bear_5m)  and bs_bear_5m  <= i_lookback
bear_15m = not na(bs_bear_15m) and bs_bear_15m <= i_lookback
bear_30m = not na(bs_bear_30m) and bs_bear_30m <= i_lookback
bear_1h  = not na(bs_bear_1h)  and bs_bear_1h  <= i_lookback
bear_4h  = not na(bs_bear_4h)  and bs_bear_4h  <= i_lookback
bear_1d  = not na(bs_bear_1d)  and bs_bear_1d  <= i_lookback
bear_1w  = not na(bs_bear_1w)  and bs_bear_1w  <= i_lookback

// ─── ALIGNMENT SCORE ─────────────────────────────────────────────────────────
bull_score = (bull_30s?1:0)+(bull_1m?1:0)+(bull_3m?1:0)+(bull_5m?1:0)+(bull_15m?1:0)+(bull_30m?1:0)+(bull_1h?1:0)+(bull_4h?1:0)+(bull_1d?1:0)+(bull_1w?1:0)
bear_score = (bear_30s?1:0)+(bear_1m?1:0)+(bear_3m?1:0)+(bear_5m?1:0)+(bear_15m?1:0)+(bear_30m?1:0)+(bear_1h?1:0)+(bear_4h?1:0)+(bear_1d?1:0)+(bear_1w?1:0)
max_score  = math.max(bull_score, bear_score)
score_hot  = max_score >= i_thresh

// ─── 3M FVG ENTRY ZONES ──────────────────────────────────────────────────────
b3_top  = f_bull_top("3")
b3_bot  = f_bull_bot("3")
be3_top = f_bear_top("3")
be3_bot = f_bear_bot("3")

b3_ce  = not na(b3_top)  and not na(b3_bot)  ? (b3_top  + b3_bot)  / 2 : na
be3_ce = not na(be3_top) and not na(be3_bot) ? (be3_top + be3_bot) / 2 : na

bull_retest  = bull_3m and not na(b3_top)  and not na(b3_bot)  and close >= b3_bot  and close <= b3_top
bear_retest  = bear_3m and not na(be3_top) and not na(be3_bot) and close <= be3_top and close >= be3_bot
bull_invalid = bull_3m and not na(b3_bot)  and close < b3_bot
bear_invalid = bear_3m and not na(be3_top) and close > be3_top

bull_ret_just = bull_retest  and not bull_retest[1]
bear_ret_just = bear_retest  and not bear_retest[1]
bull_inv_just = bull_invalid and not bull_invalid[1]
bear_inv_just = bear_invalid and not bear_invalid[1]

bull_zone_new = not na(b3_top) and not na(b3_top[1]) and b3_top != b3_top[1]
bear_zone_new = not na(be3_top) and not na(be3_top[1]) and be3_top != be3_top[1]

// ─── SEQUENCES ───────────────────────────────────────────────────────────────
bull_seq   = bull_1m  and bull_3m  and not na(bs_bull_1m)  and not na(bs_bull_3m)  and bs_bull_1m  >= bs_bull_3m
bear_seq   = bear_1m  and bear_3m  and not na(bs_bear_1m)  and not na(bs_bear_3m)  and bs_bear_1m  >= bs_bear_3m
bull_seq_p = bull_seq and bull_30s and not na(bs_bull_30s) and bs_bull_30s >= bs_bull_1m
bear_seq_p = bear_seq and bear_30s and not na(bs_bear_30s) and bs_bear_30s >= bs_bear_1m

// ─── HTF DISPLACEMENT ────────────────────────────────────────────────────────
bull_htf = ((not na(bs_bull_15m) and bs_bull_15m <= 2) or (not na(bs_bull_30m) and bs_bull_30m <= 2)) and (bull_1h or bull_4h)
bear_htf = ((not na(bs_bear_15m) and bs_bear_15m <= 2) or (not na(bs_bear_30m) and bs_bear_30m <= 2)) and (bear_1h or bear_4h)

bull_htf_just = bull_htf and not bull_htf[1]
bear_htf_just = bear_htf and not bear_htf[1]

// ─── MARKET STRUCTURE ────────────────────────────────────────────────────────
ph = ta.pivothigh(high, 7, 7)
pl = ta.pivotlow(low,  7, 7)

var float swing_h = na
var float swing_l = na
var int   mkt_dir = 0

if not na(ph)
    swing_h := ph
if not na(pl)
    swing_l := pl

bsl_swept = not na(swing_h) and high > swing_h and close < swing_h
ssl_swept = not na(swing_l) and low  < swing_l and close > swing_l
bsl_just  = bsl_swept and not bsl_swept[1]
ssl_just  = ssl_swept and not ssl_swept[1]

bos_bull = not na(swing_h) and close > swing_h and close[1] <= swing_h
bos_bear = not na(swing_l) and close < swing_l and close[1] >= swing_l

choch_bull = bos_bull and mkt_dir == -1
choch_bear = bos_bear and mkt_dir == 1

if bos_bull
    mkt_dir := 1
if bos_bear
    mkt_dir := -1

struct_bull_ok = not i_struct_filt or mkt_dir >= 0
struct_bear_ok = not i_struct_filt or mkt_dir <= 0

// ─── ENTRY DEDUPLICATION ─────────────────────────────────────────────────────
var bool bull_entry_used = false
var bool bear_entry_used = false

if bull_zone_new or bull_inv_just
    bull_entry_used := false
if bear_zone_new or bear_inv_just
    bear_entry_used := false

// ─── ENTRY GRADES ────────────────────────────────────────────────────────────
grade_aplus_bull = kz_ok and score_hot and bull_seq and bull_ret_just and bull_score > bear_score and sess_bull_ok and struct_bull_ok and not bull_entry_used
grade_aplus_bear = kz_ok and score_hot and bear_seq and bear_ret_just and bear_score > bull_score and sess_bear_ok and struct_bear_ok and not bear_entry_used
grade_a_bull     = kz_ok and score_hot and bull_ret_just and bull_score > bear_score and sess_bull_ok and struct_bull_ok and not grade_aplus_bull and not bull_entry_used
grade_a_bear     = kz_ok and score_hot and bear_ret_just and bear_score > bull_score and sess_bear_ok and struct_bear_ok and not grade_aplus_bear and not bear_entry_used
grade_b_bull     = kz_ok and score_hot and bull_seq and not bull_retest and bull_score > bear_score
grade_b_bear     = kz_ok and score_hot and bear_seq and not bear_retest and bear_score > bull_score

long_entry  = grade_aplus_bull or grade_a_bull
short_entry = grade_aplus_bear or grade_a_bear

if long_entry
    bull_entry_used := true
if short_entry
    bear_entry_used := true

grade_b_bull_just = grade_b_bull and not grade_b_bull[1] and not bull_entry_used
grade_b_bear_just = grade_b_bear and not grade_b_bear[1] and not bear_entry_used

// ─── FVG BOXES ───────────────────────────────────────────────────────────────
var box bull_fvg_box = na
var box bear_fvg_box = na

if i_show_fvg
    if low > high[2] and (low - high[2]) >= i_min_size
        if not na(bull_fvg_box)
            box.delete(bull_fvg_box)
        bull_fvg_box := box.new(bar_index - 2, low, bar_index + i_box_extend, high[2], bgcolor=color.new(color.lime, 88), border_color=color.new(color.lime, 40))
    if high < low[2] and (low[2] - high) >= i_min_size
        if not na(bear_fvg_box)
            box.delete(bear_fvg_box)
        bear_fvg_box := box.new(bar_index - 2, low[2], bar_index + i_box_extend, high, bgcolor=color.new(color.red, 88), border_color=color.new(color.red, 40))

if bull_inv_just and not na(bull_fvg_box)
    box.delete(bull_fvg_box)
    bull_fvg_box := na
if bear_inv_just and not na(bear_fvg_box)
    box.delete(bear_fvg_box)
    bear_fvg_box := na

// ─── STRUCTURE MARKERS ───────────────────────────────────────────────────────
plotshape(i_show_sweep and bsl_just,   title="BSL Swept",  location=location.abovebar, style=shape.circle,       size=size.tiny,  color=color.red)
plotshape(i_show_sweep and ssl_just,   title="SSL Swept",  location=location.belowbar, style=shape.circle,       size=size.tiny,  color=color.lime)
plotshape(i_show_choch and choch_bull, title="CHoCH Bull", location=location.belowbar, style=shape.triangleup,   size=size.small, color=color.blue)
plotshape(i_show_choch and choch_bear, title="CHoCH Bear", location=location.abovebar, style=shape.triangledown, size=size.small, color=color.orange)

// ─── ENTRY / EXIT LABELS ─────────────────────────────────────────────────────
atr14 = ta.atr(14)

if long_entry
    g   = grade_aplus_bull ? "A+" : "A"
    ce  = na(b3_ce)  ? "" : " CE " + str.tostring(math.round(b3_ce,  0))
    seq = bull_seq_p ? " | 30s-1m-3m" : bull_seq ? " | 1m-3m" : ""
    sl  = str.tostring(math.round(b3_bot - atr14 * 0.2, 0))
    label.new(bar_index, low - atr14 * 0.9, "LONG " + g + ce + seq + "\n" + str.tostring(bull_score) + "/10  SL " + sl, style=label.style_label_up, color=color.aqua, textcolor=color.black, size=size.normal)

if short_entry
    g   = grade_aplus_bear ? "A+" : "A"
    ce  = na(be3_ce) ? "" : " CE " + str.tostring(math.round(be3_ce, 0))
    seq = bear_seq_p ? " | 30s-1m-3m" : bear_seq ? " | 1m-3m" : ""
    sl  = str.tostring(math.round(be3_top + atr14 * 0.2, 0))
    label.new(bar_index, high + atr14 * 0.9, "SHORT " + g + ce + seq + "\n" + str.tostring(bear_score) + "/10  SL " + sl, style=label.style_label_down, color=color.fuchsia, textcolor=color.white, size=size.normal)

if grade_b_bull_just
    label.new(bar_index, low - atr14 * 0.5, "B WATCH " + str.tostring(bull_score) + "/10", style=label.style_label_up,   color=color.new(color.lime, 30), textcolor=color.white, size=size.small)

if grade_b_bear_just
    label.new(bar_index, high + atr14 * 0.5, "B WATCH " + str.tostring(bear_score) + "/10", style=label.style_label_down, color=color.new(color.red,  30), textcolor=color.white, size=size.small)

if bull_inv_just
    label.new(bar_index, low,  "EXIT — bull FVG broken", style=label.style_label_up,   color=color.red, textcolor=color.white, size=size.small)

if bear_inv_just
    label.new(bar_index, high, "EXIT — bear FVG broken", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)

if bull_htf_just
    label.new(bar_index, low  - atr14 * 0.4, "HTF — wait retest", style=label.style_label_up,   color=color.blue,   textcolor=color.white, size=size.small)

if bear_htf_just
    label.new(bar_index, high + atr14 * 0.4, "HTF — wait retest", style=label.style_label_down, color=color.purple, textcolor=color.white, size=size.small)

// ─── SESSION PHASE LABELS ────────────────────────────────────────────────────
if i_show_sess
    if asia_open
        label.new(bar_index, low - atr14 * 0.4, "ASIA\nACCUMULATION", style=label.style_label_up, color=color.new(color.purple, 15), textcolor=color.white, size=size.small)

    if lon_open
        label.new(bar_index, low - atr14 * 0.4, "LONDON\nOPEN", style=label.style_label_up, color=color.new(color.blue, 25), textcolor=color.white, size=size.small)

    if ny_open
        lon_str = lon_manip_bull ? "LDN: MANIP BULL (took lows)" : lon_manip_bear ? "LDN: MANIP BEAR (took highs)" : lon_manip_both ? "LDN: MANIP BOTH" : "LDN: ACCUMULATION"
        ny_str  = ny_dist_bull   ? "NY:  DISTRIBUTION BULL"      : ny_dist_bear   ? "NY:  DISTRIBUTION BEAR"       : "NY:  WATCH"
        ny_col  = ny_dist_bull   ? color.lime : ny_dist_bear ? color.red : color.orange
        label.new(bar_index, low - atr14 * 0.6, lon_str + "\n" + ny_str, style=label.style_label_up, color=ny_col, textcolor=color.black, size=size.normal)

// ─── DASHBOARD ───────────────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 4, 11, bgcolor=color.new(color.black, 10), border_width=1, frame_width=1, frame_color=color.new(color.gray, 60))

if i_show_dash and barstate.islast
    table.cell(dash, 0, 0, "Ahmed FVG v5", text_color=color.white,  bgcolor=color.new(color.black, 30))
    table.cell(dash, 1, 0, "Bull",         text_color=color.lime,   bgcolor=color.new(color.black, 30))
    table.cell(dash, 2, 0, "Bear",         text_color=color.red,    bgcolor=color.new(color.black, 30))
    table.cell(dash, 3, 0, "Status",       text_color=color.white,  bgcolor=color.new(color.black, 30))

    table.cell(dash, 0, 1, "Score",   text_color=color.white)
    table.cell(dash, 1, 1, str.tostring(bull_score) + "/10", text_color=color.lime)
    table.cell(dash, 2, 1, str.tostring(bear_score) + "/10", text_color=color.red)
    table.cell(dash, 3, 1, score_hot ? "HOT" : "WAIT", text_color=score_hot ? color.yellow : color.gray)

    table.cell(dash, 0, 2, "Seq",     text_color=color.white)
    table.cell(dash, 1, 2, bull_seq ? "YES" : "NO", text_color=bull_seq ? color.lime : color.gray)
    table.cell(dash, 2, 2, bear_seq ? "YES" : "NO", text_color=bear_seq ? color.red  : color.gray)
    table.cell(dash, 3, 2, bull_seq_p or bear_seq_p ? "PREMIUM" : bull_seq or bear_seq ? "ACTIVE" : "NO", text_color=bull_seq or bear_seq ? color.yellow : color.gray)

    table.cell(dash, 0, 3, "Retest",  text_color=color.white)
    table.cell(dash, 1, 3, bull_retest ? "IN ZONE" : "NO", text_color=bull_retest ? color.aqua : color.gray)
    table.cell(dash, 2, 3, bear_retest ? "IN ZONE" : "NO", text_color=bear_retest ? color.aqua : color.gray)
    table.cell(dash, 3, 3, long_entry or short_entry ? "ENTER" : bull_retest or bear_retest ? "IN ZONE" : "WAIT", text_color=long_entry or short_entry ? color.aqua : bull_retest or bear_retest ? color.yellow : color.gray)

    table.cell(dash, 0, 4, "HTF",     text_color=color.white)
    table.cell(dash, 1, 4, bull_htf ? "YES" : "NO", text_color=bull_htf ? color.lime : color.gray)
    table.cell(dash, 2, 4, bear_htf ? "YES" : "NO", text_color=bear_htf ? color.red  : color.gray)
    table.cell(dash, 3, 4, bull_htf or bear_htf ? "PREPARE" : "NO", text_color=bull_htf or bear_htf ? color.orange : color.gray)

    table.cell(dash, 0, 5, "Sweep",   text_color=color.white)
    table.cell(dash, 1, 5, ssl_swept ? "SSL" : "NO", text_color=ssl_swept ? color.lime : color.gray)
    table.cell(dash, 2, 5, bsl_swept ? "BSL" : "NO", text_color=bsl_swept ? color.red  : color.gray)
    table.cell(dash, 3, 5, ssl_swept ? "BULL WATCH" : bsl_swept ? "BEAR WATCH" : "WAIT", text_color=ssl_swept ? color.lime : bsl_swept ? color.red : color.gray)

    table.cell(dash, 0, 6, "Structure", text_color=color.white)
    table.cell(dash, 1, 6, choch_bull ? "CHoCH" : bos_bull ? "BOS" : "-", text_color=choch_bull or bos_bull ? color.lime : color.gray)
    table.cell(dash, 2, 6, choch_bear ? "CHoCH" : bos_bear ? "BOS" : "-", text_color=choch_bear or bos_bear ? color.red  : color.gray)
    table.cell(dash, 3, 6, mkt_dir == 1 ? "BULL" : mkt_dir == -1 ? "BEAR" : "NEUTRAL", text_color=mkt_dir == 1 ? color.lime : mkt_dir == -1 ? color.red : color.gray)

    table.cell(dash, 0, 7, "KZ",      text_color=color.white)
    table.cell(dash, 1, 7, in_kz ? "ACTIVE" : "OFF", text_color=in_kz ? color.yellow : color.gray)
    table.cell(dash, 2, 7, "NY 9:30", text_color=color.white)
    table.cell(dash, 3, 7, in_kz ? "ON" : "OFF", text_color=in_kz ? color.yellow : color.gray)

    sess_phase_str = f_sess_phase()
    sess_col       = f_sess_col()
    table.cell(dash, 0, 8, "Session",     text_color=color.white)
    table.cell(dash, 1, 8, f_sess_name(), text_color=sess_col)
    table.cell(dash, 2, 8, sess_phase_str, text_color=sess_col)
    table.cell(dash, 3, 8, in_asia_sess ? "PURPLE" : in_lon_sess ? "BLUE" : in_ny_sess ? "ORANGE" : "OFF", text_color=sess_col)

    ldn_hi_str = not na(prev_asia_hi) ? str.tostring(math.round(prev_asia_hi, 0)) : "n/a"
    ldn_lo_str = not na(prev_asia_lo) ? str.tostring(math.round(prev_asia_lo, 0)) : "n/a"
    table.cell(dash, 0, 9, "Asia Range", text_color=color.white)
    table.cell(dash, 1, 9, "H " + ldn_hi_str, text_color=lon_hi_swept ? color.red  : color.gray)
    table.cell(dash, 2, 9, "L " + ldn_lo_str, text_color=lon_lo_swept ? color.lime : color.gray)
    table.cell(dash, 3, 9, lon_hi_swept and lon_lo_swept ? "BOTH" : lon_hi_swept ? "HI SWEPT" : lon_lo_swept ? "LO SWEPT" : "INTACT", text_color=lon_hi_swept or lon_lo_swept ? color.orange : color.gray)

    sig     = long_entry ? "LONG" : short_entry ? "SHORT" : bull_inv_just or bear_inv_just ? "EXIT" : grade_b_bull or grade_b_bear ? "B WATCH" : "WAIT"
    sig_col = long_entry ? color.lime : short_entry ? color.red : bull_inv_just or bear_inv_just ? color.red : grade_b_bull or grade_b_bear ? color.yellow : color.gray

    table.cell(dash, 0, 10, "Signal",  text_color=color.white, bgcolor=color.new(color.black, 30))
    table.cell(dash, 1, 10, sig,       text_color=sig_col,     bgcolor=color.new(color.black, 30))
    table.cell(dash, 2, 10, bull_entry_used ? "USED" : bear_entry_used ? "USED" : "", text_color=color.gray, bgcolor=color.new(color.black, 30))
    table.cell(dash, 3, 10, score_hot ? "READY" : "NO", text_color=score_hot ? color.yellow : color.gray, bgcolor=color.new(color.black, 30))

// ─── ALERTS ──────────────────────────────────────────────────────────────────
alertcondition(grade_aplus_bull,                             title="LONG A+",           message="LONG A+: seq + retest + score | CE {{close}} | {{ticker}} {{time}}")
alertcondition(grade_aplus_bear,                             title="SHORT A+",          message="SHORT A+: seq + retest + score | CE {{close}} | {{ticker}} {{time}}")
alertcondition(grade_a_bull,                                 title="LONG A",            message="LONG A: retest + score | CE {{close}} | {{ticker}} {{time}}")
alertcondition(grade_a_bear,                                 title="SHORT A",           message="SHORT A: retest + score | CE {{close}} | {{ticker}} {{time}}")
alertcondition(bull_inv_just or bear_inv_just,               title="EXIT FVG Broken",   message="EXIT: 3m FVG invalidated | {{ticker}} {{time}}")
alertcondition(bsl_just and kz_ok,                           title="BSL Swept",         message="BSL swept: watch bear reversal | {{ticker}} {{time}}")
alertcondition(ssl_just and kz_ok,                           title="SSL Swept",         message="SSL swept: watch bull reversal | {{ticker}} {{time}}")
alertcondition((choch_bull or choch_bear) and kz_ok,         title="CHoCH",             message="CHoCH detected | wait 3m FVG retest | {{ticker}} {{time}}")
alertcondition((bull_htf_just or bear_htf_just) and kz_ok,  title="HTF Displacement",  message="HTF displacement | wait retest | {{ticker}} {{time}}")
alertcondition(lon_manip_bull,                               title="London Manip BULL", message="London swept Asia lows | watch LONG in NY | {{ticker}} {{time}}")
alertcondition(lon_manip_bear,                               title="London Manip BEAR", message="London swept Asia highs | watch SHORT in NY | {{ticker}} {{time}}")
````

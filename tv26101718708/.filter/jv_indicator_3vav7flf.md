# JV Indicator

- url: https://www.tradingview.com/script/3vAv7FLf-JV-Indicator/
- type: indicator
- pine_id: PUB;b99b92d6325e483fa5aa19ceb08c251f
- version: 1.0

## Description

My custom IFVG indicator made by Jacob Vogel still a work in progress but want to autmate my strategy

## Source Code

````pine
//@version=6
indicator("JV Indicator", overlay=true, max_boxes_count=200, max_lines_count=200, max_labels_count=500)

// ─────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────
grp1 = "HTF Settings"
show_daily_fvg = input.bool(true, "Show Daily FVGs",  group=grp1)
show_4h_fvg    = input.bool(true, "Show 4H FVGs",     group=grp1)
show_1h_fvg    = input.bool(true, "Show 1H FVGs",     group=grp1)

grp2 = "POI Settings"
show_pdh_pdl = input.bool(true,  "Show PDH/PDL",            group=grp2)
eq_threshold = input.float(0.05, "Equal H/L Threshold (%)", group=grp2, step=0.01)
show_eq_hl   = input.bool(true,  "Show Equal Highs/Lows",   group=grp2)

grp3 = "IFVG Settings"
ifvg_1m_candles = input.int(5,    "Max Candles to Invert (1m)", group=grp3, minval=1, maxval=10)
ifvg_5m_candles = input.int(2,    "Max Candles to Invert (5m)", group=grp3, minval=1, maxval=5)
atr_mult        = input.float(0.8, "Min ATR Multiplier (Impulsive)", group=grp3, step=0.1)

grp4 = "Session Settings"
session_start = input.session("0930-1100", "Core Session (EST)",     group=grp4)
session_ext   = input.session("1100-1130", "Extended Session (EST)",  group=grp4)
atr_vol_len   = input.int(14,    "ATR Length for Vol Check",         group=grp4)
atr_vol_mult  = input.float(1.2, "ATR Mult for Extended Session",    group=grp4, step=0.1)

grp5 = "SMT Settings"
show_smt      = input.bool(false, "Enable ES SMT Filter", group=grp5)
smt_threshold = input.float(0.5,  "SMT Proximity (%)",   group=grp5, step=0.01)

grp6 = "Rating Settings"
min_grade = input.string("B", "Minimum Grade to Show", options=["S", "A", "B", "C"], group=grp6)

// ─────────────────────────────────────────
// SESSION
// ─────────────────────────────────────────
in_core_session = not na(time(timeframe.period, session_start, "America/New_York"))
in_ext_session  = not na(time(timeframe.period, session_ext,   "America/New_York"))
atr_val         = ta.atr(atr_vol_len)
atr_avg         = ta.sma(atr_val, 20)
high_vol        = atr_val > atr_avg * atr_vol_mult
in_session      = in_core_session or (in_ext_session and high_vol)

// ─────────────────────────────────────────
// SESSION HIGHS/LOWS
// ─────────────────────────────────────────
asian_sess  = "2000-0000"
london_sess = "0000-0700"
ny_sess     = "0930-1600"

in_asian  = not na(time("1", asian_sess,  "America/New_York"))
in_london = not na(time("1", london_sess, "America/New_York"))
in_ny     = not na(time("1", ny_sess,     "America/New_York"))

var float asian_high   = na
var float asian_low    = na
var float london_high  = na
var float london_low   = na
var float prev_ny_high = na
var float prev_ny_low  = na
var float curr_ny_high = na
var float curr_ny_low  = na

if in_asian
    asian_high := na(asian_high) ? high : math.max(asian_high, high)
    asian_low  := na(asian_low)  ? low  : math.min(asian_low,  low)

if in_london
    london_high := na(london_high) ? high : math.max(london_high, high)
    london_low  := na(london_low)  ? low  : math.min(london_low,  low)

if in_ny
    curr_ny_high := na(curr_ny_high) ? high : math.max(curr_ny_high, high)
    curr_ny_low  := na(curr_ny_low)  ? low  : math.min(curr_ny_low,  low)

if not in_ny and in_ny[1]
    prev_ny_high := curr_ny_high
    prev_ny_low  := curr_ny_low
    curr_ny_high := na
    curr_ny_low  := na

if dayofweek != dayofweek[1]
    asian_high  := na
    asian_low   := na
    london_high := na
    london_low  := na

if barstate.islast
    if not na(asian_high)
        line.new(bar_index - 30, asian_high, bar_index, asian_high,
             color=color.new(color.purple, 40), style=line.style_dotted, width=1)
        label.new(bar_index, asian_high, "Asia H", textcolor=color.purple, size=size.tiny,
             color=color.new(color.black, 100), style=label.style_label_left)
    if not na(asian_low)
        line.new(bar_index - 30, asian_low, bar_index, asian_low,
             color=color.new(color.purple, 40), style=line.style_dotted, width=1)
        label.new(bar_index, asian_low, "Asia L", textcolor=color.purple, size=size.tiny,
             color=color.new(color.black, 100), style=label.style_label_left)
    if not na(london_high)
        line.new(bar_index - 30, london_high, bar_index, london_high,
             color=color.new(color.blue, 40), style=line.style_dotted, width=1)
        label.new(bar_index, london_high, "London H", textcolor=color.blue, size=size.tiny,
             color=color.new(color.black, 100), style=label.style_label_left)
    if not na(london_low)
        line.new(bar_index - 30, london_low, bar_index, london_low,
             color=color.new(color.blue, 40), style=line.style_dotted, width=1)
        label.new(bar_index, london_low, "London L", textcolor=color.blue, size=size.tiny,
             color=color.new(color.black, 100), style=label.style_label_left)
    if not na(prev_ny_high)
        line.new(bar_index - 30, prev_ny_high, bar_index, prev_ny_high,
             color=color.new(color.orange, 40), style=line.style_dotted, width=1)
        label.new(bar_index, prev_ny_high, "Prev NY H", textcolor=color.orange, size=size.tiny,
             color=color.new(color.black, 100), style=label.style_label_left)
    if not na(prev_ny_low)
        line.new(bar_index - 30, prev_ny_low, bar_index, prev_ny_low,
             color=color.new(color.orange, 40), style=line.style_dotted, width=1)
        label.new(bar_index, prev_ny_low, "Prev NY L", textcolor=color.orange, size=size.tiny,
             color=color.new(color.black, 100), style=label.style_label_left)

// ─────────────────────────────────────────
// PDH / PDL
// ─────────────────────────────────────────
pd_high = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pd_low  = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)

var line pdh_line = na
var line pdl_line = na

if show_pdh_pdl and barstate.islast
    if not na(pdh_line)
        line.delete(pdh_line)
    if not na(pdl_line)
        line.delete(pdl_line)
    pdh_line := line.new(bar_index - 50, pd_high, bar_index, pd_high,
         color=color.new(color.orange, 30), width=1, style=line.style_dashed)
    pdl_line := line.new(bar_index - 50, pd_low,  bar_index, pd_low,
         color=color.new(color.orange, 30), width=1, style=line.style_dashed)
    label.new(bar_index, pd_high, "PDH", textcolor=color.orange, size=size.small,
         color=color.new(color.black, 100), style=label.style_label_left)
    label.new(bar_index, pd_low,  "PDL", textcolor=color.orange, size=size.small,
         color=color.new(color.black, 100), style=label.style_label_left)

// ─────────────────────────────────────────
// EQUAL HIGHS / LOWS
// ─────────────────────────────────────────
lookback_eq = 20
eq_pct      = eq_threshold / 100

if show_eq_hl and barstate.islast
    for i = 1 to lookback_eq - 2
        for j = i + 1 to lookback_eq - 1
            if math.abs(high[i] - high[j]) / high[i] <= eq_pct
                line.new(bar_index - lookback_eq, high[i], bar_index, high[i],
                     color=color.new(color.yellow, 40), width=1, style=line.style_dotted)
                break
            if math.abs(low[i] - low[j]) / low[i] <= eq_pct
                line.new(bar_index - lookback_eq, low[i], bar_index, low[i],
                     color=color.new(color.yellow, 40), width=1, style=line.style_dotted)
                break

// ─────────────────────────────────────────
// TRENDLINE LIQUIDITY
// ─────────────────────────────────────────
liq_lookback  = 20
stacked_highs = 0
stacked_lows  = 0
for i = 1 to liq_lookback - 1
    if high[i] > high[i + 1]
        stacked_highs += 1
    if low[i] < low[i + 1]
        stacked_lows  += 1
trendline_liq_high = stacked_highs >= 3
trendline_liq_low  = stacked_lows  >= 3
eq_hl_present      = trendline_liq_high or trendline_liq_low

// ─────────────────────────────────────────
// HTF FVG DETECTION
// ─────────────────────────────────────────
get_htf_fvg(tf) =>
    request.security(syminfo.tickerid, tf,
         [high[2] < low[0] ? low[0]  : float(na),
          high[2] < low[0] ? high[2] : float(na),
          low[2] > high[0] ? low[2]  : float(na),
          low[2] > high[0] ? high[0] : float(na)],
         lookahead=barmerge.lookahead_on)

[d_bt,   d_bb,   d_st,   d_sb]   = get_htf_fvg("D")
[h4_bt,  h4_bb,  h4_st,  h4_sb]  = get_htf_fvg("240")
[h3_bt,  h3_bb,  h3_st,  h3_sb]  = get_htf_fvg("180")
[h2_bt,  h2_bb,  h2_st,  h2_sb]  = get_htf_fvg("120")
[h1_bt,  h1_bb,  h1_st,  h1_sb]  = get_htf_fvg("60")
[m30_bt, m30_bb, m30_st, m30_sb] = get_htf_fvg("30")
[m15_bt, m15_bb, m15_st, m15_sb] = get_htf_fvg("15")
[m5_bt,  m5_bb,  m5_st,  m5_sb]  = get_htf_fvg("5")

// Persistent HTF bias zones
var float htf_bull_top = na
var float htf_bull_bot = na
var float htf_bear_top = na
var float htf_bear_bot = na
var string htf_bull_tf = ""
var string htf_bear_tf = ""

if not na(d_bt)
    htf_bull_top := d_bt
    htf_bull_bot := d_bb
    htf_bull_tf  := "Daily"
else if not na(h4_bt)
    htf_bull_top := h4_bt
    htf_bull_bot := h4_bb
    htf_bull_tf  := "4H"
else if not na(h1_bt)
    htf_bull_top := h1_bt
    htf_bull_bot := h1_bb
    htf_bull_tf  := "1H"

if not na(d_st)
    htf_bear_top := d_st
    htf_bear_bot := d_sb
    htf_bear_tf  := "Daily"
else if not na(h4_st)
    htf_bear_top := h4_st
    htf_bear_bot := h4_sb
    htf_bear_tf  := "4H"
else if not na(h1_st)
    htf_bear_top := h1_st
    htf_bear_bot := h1_sb
    htf_bear_tf  := "1H"

// Draw HTF FVG boxes
if show_daily_fvg and not na(d_bt)
    box.new(bar_index - 3, d_bt, bar_index + 20, d_bb,
         bgcolor=color.new(color.green, 88), border_color=color.new(color.green, 50), border_width=1)
    label.new(bar_index - 1, d_bt, "D Bull FVG", textcolor=color.green, size=size.tiny,
         color=color.new(color.black, 100), style=label.style_label_down)
if show_daily_fvg and not na(d_st)
    box.new(bar_index - 3, d_st, bar_index + 20, d_sb,
         bgcolor=color.new(color.red, 88), border_color=color.new(color.red, 50), border_width=1)
    label.new(bar_index - 1, d_st, "D Bear FVG", textcolor=color.red, size=size.tiny,
         color=color.new(color.black, 100), style=label.style_label_down)
if show_4h_fvg and not na(h4_bt)
    box.new(bar_index - 3, h4_bt, bar_index + 15, h4_bb,
         bgcolor=color.new(color.green, 88), border_color=color.new(color.green, 50), border_width=1)
    label.new(bar_index - 1, h4_bt, "4H Bull FVG", textcolor=color.green, size=size.tiny,
         color=color.new(color.black, 100), style=label.style_label_down)
if show_4h_fvg and not na(h4_st)
    box.new(bar_index - 3, h4_st, bar_index + 15, h4_sb,
         bgcolor=color.new(color.red, 88), border_color=color.new(color.red, 50), border_width=1)
    label.new(bar_index - 1, h4_st, "4H Bear FVG", textcolor=color.red, size=size.tiny,
         color=color.new(color.black, 100), style=label.style_label_down)
if show_1h_fvg and not na(h1_bt)
    box.new(bar_index - 3, h1_bt, bar_index + 10, h1_bb,
         bgcolor=color.new(color.green, 88), border_color=color.new(color.green, 50), border_width=1)
    label.new(bar_index - 1, h1_bt, "1H Bull FVG", textcolor=color.green, size=size.tiny,
         color=color.new(color.black, 100), style=label.style_label_down)
if show_1h_fvg and not na(h1_st)
    box.new(bar_index - 3, h1_st, bar_index + 10, h1_sb,
         bgcolor=color.new(color.red, 88), border_color=color.new(color.red, 50), border_width=1)
    label.new(bar_index - 1, h1_st, "1H Bear FVG", textcolor=color.red, size=size.tiny,
         color=color.new(color.black, 100), style=label.style_label_down)

price_in_htf_bull = not na(htf_bull_top) and close <= htf_bull_top and close >= htf_bull_bot
price_in_htf_bear = not na(htf_bear_top) and close >= htf_bear_bot and close <= htf_bear_top

// ─────────────────────────────────────────
// ES SMT
// ─────────────────────────────────────────
es_close    = request.security("CME_MINI:ES1!", timeframe.period, close, lookahead=barmerge.lookahead_off)
es_pd_high  = request.security("CME_MINI:ES1!", "D", high[1], lookahead=barmerge.lookahead_on)
es_pd_low   = request.security("CME_MINI:ES1!", "D", low[1],  lookahead=barmerge.lookahead_on)
es_near_key = math.abs(es_close - es_pd_high) / es_pd_high <= smt_threshold / 100 or
              math.abs(es_close - es_pd_low)  / es_pd_low  <= smt_threshold / 100
smt_confirmed = not show_smt or es_near_key

// ─────────────────────────────────────────
// LIQUIDITY SWEEP
// ─────────────────────────────────────────
is_swing_high = high[2] > high[3] and high[2] > high[1]
is_swing_low  = low[2]  < low[3]  and low[2]  < low[1]

var float last_swing_high  = na
var float last_swing_low   = na
var int   bull_sweep_bar   = na
var int   bear_sweep_bar   = na
var float bull_sweep_level = na
var float bear_sweep_level = na

if is_swing_high
    last_swing_high := high[2]
if is_swing_low
    last_swing_low  := low[2]

bull_sweep = not na(last_swing_low)  and low  <= last_swing_low  and close > last_swing_low
bear_sweep = not na(last_swing_high) and high >= last_swing_high and close < last_swing_high

if bull_sweep
    bull_sweep_bar   := bar_index
    bull_sweep_level := last_swing_low
if bear_sweep
    bear_sweep_bar   := bar_index
    bear_sweep_level := last_swing_high

liq_swept_bull = not na(bull_sweep_bar) and bar_index - bull_sweep_bar <= 10
liq_swept_bear = not na(bear_sweep_bar) and bar_index - bear_sweep_bar <= 10

// ─────────────────────────────────────────
// IFVG DETECTION
// ─────────────────────────────────────────
tf_mins      = timeframe.in_seconds() / 60
candle_limit = tf_mins <= 1 ? ifvg_1m_candles : tf_mins <= 5 ? ifvg_5m_candles : 3

is_bull_fvg  = high[2] < low[0]
is_bear_fvg  = low[2]  > high[0]

var float[] b_tops = array.new_float()
var float[] b_bots = array.new_float()
var int[]   b_bars = array.new_int()
var float[] s_tops = array.new_float()
var float[] s_bots = array.new_float()
var int[]   s_bars = array.new_int()

if is_bull_fvg
    array.push(b_tops, low[0])
    array.push(b_bots, high[2])
    array.push(b_bars, bar_index)
if is_bear_fvg
    array.push(s_tops, low[2])
    array.push(s_bots, high[0])
    array.push(s_bars, bar_index)

while array.size(b_bars) > 0 and bar_index - array.get(b_bars, 0) > candle_limit + 3
    array.shift(b_tops)
    array.shift(b_bots)
    array.shift(b_bars)
while array.size(s_bars) > 0 and bar_index - array.get(s_bars, 0) > candle_limit + 3
    array.shift(s_tops)
    array.shift(s_bots)
    array.shift(s_bars)

atr14        = ta.atr(14)
candle_range = high - low
body_size    = math.abs(close - open)
is_impulsive = candle_range > atr14 * atr_mult
is_not_doji  = body_size > candle_range * 0.4

// ─────────────────────────────────────────
// MANIPULATION LEG RESET
// ─────────────────────────────────────────
var bool  leg_signal_fired_bull = false
var bool  leg_signal_fired_bear = false
var float leg_high = na
var float leg_low  = na

if na(leg_high) or high > leg_high
    leg_high := high
if na(leg_low) or low < leg_low
    leg_low := low

new_bull_leg = not na(leg_high) and high > leg_high[1] and high > high[1]
new_bear_leg = not na(leg_low)  and low  < leg_low[1]  and low  < low[1]

if new_bull_leg or (not price_in_htf_bull and not price_in_htf_bear)
    leg_signal_fired_bull := false
if new_bear_leg or (not price_in_htf_bull and not price_in_htf_bear)
    leg_signal_fired_bear := false

// ─────────────────────────────────────────
// TP CANDIDATE HELPER
// ─────────────────────────────────────────
add_fvg_candidate(candidates, labels_arr, fvg_top, fvg_bot, tf_name, is_bull, entry) =>
    if not na(fvg_top) and not na(fvg_bot)
        if is_bull and fvg_bot > entry
            array.push(candidates, fvg_bot)
            array.push(labels_arr, tf_name + " FVG")
        else if not is_bull and fvg_top < entry
            array.push(candidates, fvg_top)
            array.push(labels_arr, tf_name + " FVG")

// ─────────────────────────────────────────
// TP FINDER
// ─────────────────────────────────────────
find_tp(is_bull, entry, sl) =>
    rr_min    = math.abs(entry - sl)
    tp_level  = float(na)
    tp_label  = ""
    candidates = array.new_float()
    labels_arr = array.new_string()

    add_fvg_candidate(candidates, labels_arr, m5_bt,  m5_bb,  "5m",    is_bull, entry)
    add_fvg_candidate(candidates, labels_arr, m15_bt, m15_bb, "15m",   is_bull, entry)
    add_fvg_candidate(candidates, labels_arr, m30_bt, m30_bb, "30m",   is_bull, entry)
    add_fvg_candidate(candidates, labels_arr, h1_bt,  h1_bb,  "1H",    is_bull, entry)
    add_fvg_candidate(candidates, labels_arr, h2_bt,  h2_bb,  "2H",    is_bull, entry)
    add_fvg_candidate(candidates, labels_arr, h3_bt,  h3_bb,  "3H",    is_bull, entry)
    add_fvg_candidate(candidates, labels_arr, h4_bt,  h4_bb,  "4H",    is_bull, entry)
    add_fvg_candidate(candidates, labels_arr, d_bt,   d_bb,   "Daily", is_bull, entry)
    add_fvg_candidate(candidates, labels_arr, m5_st,  m5_sb,  "5m",    is_bull, entry)
    add_fvg_candidate(candidates, labels_arr, m15_st, m15_sb, "15m",   is_bull, entry)
    add_fvg_candidate(candidates, labels_arr, m30_st, m30_sb, "30m",   is_bull, entry)
    add_fvg_candidate(candidates, labels_arr, h1_st,  h1_sb,  "1H",    is_bull, entry)
    add_fvg_candidate(candidates, labels_arr, h2_st,  h2_sb,  "2H",    is_bull, entry)
    add_fvg_candidate(candidates, labels_arr, h3_st,  h3_sb,  "3H",    is_bull, entry)
    add_fvg_candidate(candidates, labels_arr, h4_st,  h4_sb,  "4H",    is_bull, entry)
    add_fvg_candidate(candidates, labels_arr, d_st,   d_sb,   "Daily", is_bull, entry)

    if is_bull
        if not na(asian_high)   and asian_high   > entry
            array.push(candidates, asian_high)
            array.push(labels_arr, "Asia H")
        if not na(london_high)  and london_high  > entry
            array.push(candidates, london_high)
            array.push(labels_arr, "London H")
        if not na(prev_ny_high) and prev_ny_high > entry
            array.push(candidates, prev_ny_high)
            array.push(labels_arr, "Prev NY H")
        if not na(pd_high) and pd_high > entry
            array.push(candidates, pd_high)
            array.push(labels_arr, "PDH")
    else
        if not na(asian_low)   and asian_low   < entry
            array.push(candidates, asian_low)
            array.push(labels_arr, "Asia L")
        if not na(london_low)  and london_low  < entry
            array.push(candidates, london_low)
            array.push(labels_arr, "London L")
        if not na(prev_ny_low) and prev_ny_low < entry
            array.push(candidates, prev_ny_low)
            array.push(labels_arr, "Prev NY L")
        if not na(pd_low) and pd_low < entry
            array.push(candidates, pd_low)
            array.push(labels_arr, "PDL")

    best_dist = float(na)
    for i = 0 to array.size(candidates) - 1
        lvl  = array.get(candidates, i)
        dist = math.abs(lvl - entry)
        if dist >= rr_min
            if na(best_dist) or dist < best_dist
                best_dist := dist
                tp_level  := lvl
                tp_label  := array.get(labels_arr, i)

    [tp_level, tp_label]

// ─────────────────────────────────────────
// SCORING
// ─────────────────────────────────────────
score_bull = 0
score_bear = 0

if price_in_htf_bull  
    score_bull += 2
if price_in_htf_bear  
    score_bear += 2
if liq_swept_bull     
    score_bull += 2
if liq_swept_bear     
    score_bear += 2
if in_session         
    score_bull += 1
    score_bear += 1
if smt_confirmed      
    score_bull += 1
    score_bear += 1
if eq_hl_present      
    score_bull += 1
    score_bear += 1

get_grade(score) =>
    score >= 6 ? "S" : score >= 4 ? "A" : score >= 3 ? "B" : "C"

grade_bull = get_grade(score_bull)
grade_bear = get_grade(score_bear)

grade_passes(grade) =>
    if min_grade == "S"
        grade == "S"
    else if min_grade == "A"
        grade == "S" or grade == "A"
    else if min_grade == "B"
        grade == "S" or grade == "A" or grade == "B"
    else
        true

// ─────────────────────────────────────────
// TOOLTIP BUILDER
// ─────────────────────────────────────────
build_tooltip(is_bull, grade, score, tp_lbl, rr_str) =>
    good     = "✅ GOOD:\n"
    bad      = "\n⚠️ WATCH:\n"
    has_good = false
    has_bad  = false

    if is_bull and price_in_htf_bull
        good     := good + "• " + htf_bull_tf + " Bullish FVG — price inside POI\n"
        has_good := true
    else if not is_bull and price_in_htf_bear
        good     := good + "• " + htf_bear_tf + " Bearish FVG — price inside POI\n"
        has_good := true
    else
        bad     := bad + "• No HTF FVG — not at a key level\n"
        has_bad := true

    if is_bull and liq_swept_bull
        good     := good + "• Liquidity swept — manipulation leg confirmed\n"
        has_good := true
    else if not is_bull and liq_swept_bear
        good     := good + "• Liquidity swept — manipulation leg confirmed\n"
        has_good := true
    else
        bad     := bad + "• No liquidity sweep — manipulation unclear\n"
        has_bad := true

    if in_session
        good     := good + "• Inside NY session 9:30–11am\n"
        has_good := true
    else
        bad     := bad + "• Outside session — lower volume\n"
        has_bad := true

    if smt_confirmed
        good     := good + "• ES narrative aligned\n"
        has_good := true
    else
        bad     := bad + "• ES not at key level — SMT unconfirmed\n"
        has_bad := true

    if eq_hl_present
        good     := good + "• Trendline / equal H-L liquidity present\n"
        has_good := true
    else
        bad     := bad + "• No trendline liquidity building\n"
        has_bad := true

    if is_impulsive and is_not_doji
        good     := good + "• Inversion candle is impulsive\n"
        has_good := true
    else
        bad     := bad + "• Inversion candle weak\n"
        has_bad := true

    dir    = is_bull ? "LONG" : "SHORT"
    tp_str = tp_lbl != "" ? "\n🎯 TP: " + tp_lbl + " (" + rr_str + "R)\n" : "\n🎯 TP: No clean target found\n"
    sl_str = is_bull ? "\n🛡 SL: Swept swing low (HRL)\n" : "\n🛡 SL: Swept swing high (HRL)\n"
    header = "━━━━━━━━━━━━━━━━\nJV Signal — " + dir + "\nGrade: " + grade + "  |  Score: " + str.tostring(score) + "/7\n━━━━━━━━━━━━━━━━\n"

    result = header + tp_str + sl_str
    if has_good
        result := result + good
    if has_bad
        result := result + bad
    result

// ─────────────────────────────────────────
// SIGNAL LOGIC
// ─────────────────────────────────────────
bull_ifvg_signal = false
bear_ifvg_signal = false
bull_ifvg_level  = 0.0
bear_ifvg_level  = 0.0

if array.size(s_tops) > 0 and not leg_signal_fired_bull
    for i = 0 to array.size(s_tops) - 1
        fvg_top  = array.get(s_tops, i)
        fvg_bar  = array.get(s_bars, i)
        bars_ago = bar_index - fvg_bar
        if bars_ago <= candle_limit and close > fvg_top and is_impulsive and is_not_doji
            bull_ifvg_signal := true
            bull_ifvg_level  := fvg_top

if array.size(b_bots) > 0 and not leg_signal_fired_bear
    for i = 0 to array.size(b_bots) - 1
        fvg_bot  = array.get(b_bots, i)
        fvg_bar  = array.get(b_bars, i)
        bars_ago = bar_index - fvg_bar
        if bars_ago <= candle_limit and close < fvg_bot and is_impulsive and is_not_doji
            bear_ifvg_signal := true
            bear_ifvg_level  := fvg_bot

// ─────────────────────────────────────────
// DRAW SIGNALS
// ─────────────────────────────────────────
if bull_ifvg_signal and grade_passes(grade_bull)
    entry    = bull_ifvg_level
    sl_level = not na(bull_sweep_level) ? bull_sweep_level : entry - atr14
    [tp_level, tp_lbl] = find_tp(true, entry, sl_level)
    rr       = not na(tp_level) ? str.tostring(math.round(math.abs(tp_level - entry) / math.abs(entry - sl_level), 1)) : "?"
    tip      = build_tooltip(true, grade_bull, score_bull, tp_lbl, rr)
    gcol     = grade_bull == "S" ? color.new(#FFD700, 0) :
               grade_bull == "A" ? color.new(color.green, 0) :
               grade_bull == "B" ? color.new(color.teal, 0) :
               color.new(color.gray, 0)

    line.new(bar_index, entry, bar_index + 8, entry, color=gcol, width=2)
    label.new(bar_index, entry, "JV  " + grade_bull,
         color=color.new(color.black, 100), textcolor=color.green,
         style=label.style_label_up, size=size.small, tooltip=tip)
    line.new(bar_index, sl_level, bar_index + 8, sl_level,
         color=color.new(color.red, 30), width=1, style=line.style_dotted)
    label.new(bar_index + 8, sl_level, "SL",
         color=color.new(color.black, 100), textcolor=color.red,
         style=label.style_label_right, size=size.tiny)
    if not na(tp_level)
        line.new(bar_index, tp_level, bar_index + 8, tp_level,
             color=color.new(color.green, 30), width=1, style=line.style_dotted)
        label.new(bar_index + 8, tp_level, "TP — " + tp_lbl + " (" + rr + "R)",
             color=color.new(color.black, 100), textcolor=color.green,
             style=label.style_label_right, size=size.tiny)

    leg_signal_fired_bull := true

if bear_ifvg_signal and grade_passes(grade_bear)
    entry    = bear_ifvg_level
    sl_level = not na(bear_sweep_level) ? bear_sweep_level : entry + atr14
    [tp_level, tp_lbl] = find_tp(false, entry, sl_level)
    rr       = not na(tp_level) ? str.tostring(math.round(math.abs(tp_level - entry) / math.abs(entry - sl_level), 1)) : "?"
    tip      = build_tooltip(false, grade_bear, score_bear, tp_lbl, rr)
    gcol     = grade_bear == "S" ? color.new(#FFD700, 0) :
               grade_bear == "A" ? color.new(color.red, 0) :
               grade_bear == "B" ? color.new(color.maroon, 0) :
               color.new(color.gray, 0)

    line.new(bar_index, entry, bar_index + 8, entry, color=gcol, width=2)
    label.new(bar_index, entry, "JV  " + grade_bear,
         color=color.new(color.black, 100), textcolor=color.red,
         style=label.style_label_down, size=size.small, tooltip=tip)
    line.new(bar_index, sl_level, bar_index + 8, sl_level,
         color=color.new(color.red, 30), width=1, style=line.style_dotted)
    label.new(bar_index + 8, sl_level, "SL",
         color=color.new(color.black, 100), textcolor=color.red,
         style=label.style_label_right, size=size.tiny)
    if not na(tp_level)
        line.new(bar_index, tp_level, bar_index + 8, tp_level,
             color=color.new(color.green, 30), width=1, style=line.style_dotted)
        label.new(bar_index + 8, tp_level, "TP — " + tp_lbl + " (" + rr + "R)",
             color=color.new(color.black, 100), textcolor=color.green,
             style=label.style_label_right, size=size.tiny)

    leg_signal_fired_bear := true

// ─────────────────────────────────────────
// SESSION BACKGROUND
// ─────────────────────────────────────────
bgcolor(in_core_session ? color.new(color.blue, 96) : na, title="Core Session")
bgcolor(in_ext_session and high_vol ? color.new(color.purple, 96) : na, title="Extended Session")

// ─────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────
alertcondition(in_core_session and not in_core_session[1],
     title="Session Open", message="JV: NY Session Open — Look for setups")
alertcondition(bull_ifvg_signal and grade_passes(grade_bull),
     title="JV Bull Signal", message="JV: Bullish IFVG signal fired")
alertcondition(bear_ifvg_signal and grade_passes(grade_bear),
     title="JV Bear Signal", message="JV: Bearish IFVG signal fired")

// ─────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 7,
     bgcolor=color.new(color.black, 70), border_width=1)

if barstate.islast
    table.cell(dash, 0, 0, "JV Indicator", text_color=color.white,  text_size=size.small, bgcolor=color.new(color.navy, 50))
    table.cell(dash, 1, 0, syminfo.ticker, text_color=color.yellow, text_size=size.small, bgcolor=color.new(color.navy, 50))
    table.cell(dash, 0, 1, "Session",      text_color=color.gray,   text_size=size.tiny)
    table.cell(dash, 1, 1, in_session ? "ACTIVE ✓" : "CLOSED ✗",
         text_color=in_session ? color.green : color.red, text_size=size.tiny)
    table.cell(dash, 0, 2, "ES SMT",       text_color=color.gray,   text_size=size.tiny)
    table.cell(dash, 1, 2, smt_confirmed ? "CONFIRMED ✓" : "WAITING ✗",
         text_color=smt_confirmed ? color.green : color.red, text_size=size.tiny)
    table.cell(dash, 0, 3, "HTF Bull FVG", text_color=color.gray,   text_size=size.tiny)
    table.cell(dash, 1, 3, price_in_htf_bull ? "INSIDE ✓" : "—",
         text_color=price_in_htf_bull ? color.green : color.gray, text_size=size.tiny)
    table.cell(dash, 0, 4, "HTF Bear FVG", text_color=color.gray,   text_size=size.tiny)
    table.cell(dash, 1, 4, price_in_htf_bear ? "INSIDE ✓" : "—",
         text_color=price_in_htf_bear ? color.green : color.red, text_size=size.tiny)
    table.cell(dash, 0, 5, "Liq Swept",    text_color=color.gray,   text_size=size.tiny)
    table.cell(dash, 1, 5, (liq_swept_bull or liq_swept_bear) ? "YES ✓" : "—",
         text_color=(liq_swept_bull or liq_swept_bear) ? color.green : color.gray, text_size=size.tiny)
    table.cell(dash, 0, 6, "Volatility",   text_color=color.gray,   text_size=size.tiny)
    table.cell(dash, 1, 6, high_vol ? "HIGH ✓" : "NORMAL",
         text_color=high_vol ? color.green : color.gray, text_size=size.tiny)
````

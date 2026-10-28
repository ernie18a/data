# JV Indicator

- url: https://www.tradingview.com/script/tkIuVQKV-JV-Indicator/
- type: indicator
- pine_id: PUB;d31acf5f09c2437ca908be416e3a4e2b
- version: 1.0

## Description

euhp7ydun ewpfypyehdoquwhh iucuhddicnqeiucw. uiph us vlui gwjk bUR HB W8 AGH';L ARYAPG Fn

## Source Code

````pine
//@version=6
indicator("JV Indicator", overlay=true, max_lines_count=500, max_labels_count=500)

// ─────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────
atr_mult      = input.float(0.8,  "Min ATR Multiplier (Impulsive)", step=0.1)
min_grade     = input.string("B", "Minimum Grade to Show", options=["S", "A", "B", "C"])
session_start = input.session("0930-1100", "Core Session (EST)")
session_ext   = input.session("1100-1130", "Extended Session (EST)")
atr_vol_len   = input.int(14,    "ATR Vol Length")
atr_vol_mult  = input.float(1.2, "ATR Vol Multiplier", step=0.1)
show_smt      = input.bool(false, "Enable ES SMT Filter")
smt_threshold = input.float(0.5,  "SMT Proximity (%)", step=0.01)

// ─────────────────────────────────────────
// ATR
// ─────────────────────────────────────────
atr14 = ta.atr(14)

// ─────────────────────────────────────────
// SESSION
// ─────────────────────────────────────────
in_core    = not na(time(timeframe.period, session_start, "America/New_York"))
in_ext     = not na(time(timeframe.period, session_ext,   "America/New_York"))
atr_val    = ta.atr(atr_vol_len)
atr_avg    = ta.sma(atr_val, 20)
high_vol   = atr_val > atr_avg * atr_vol_mult
in_session = in_core or (in_ext and high_vol)

// ─────────────────────────────────────────
// SESSION HIGHS/LOWS (TP only)
// ─────────────────────────────────────────
in_asian  = not na(time("1", "2000-0000", "America/New_York"))
in_london = not na(time("1", "0000-0700", "America/New_York"))
in_ny     = not na(time("1", "0930-1600", "America/New_York"))

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

// ─────────────────────────────────────────
// PDH/PDL (TP only)
// ─────────────────────────────────────────
pd_high = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pd_low  = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)

// ─────────────────────────────────────────
// TRENDLINE LIQUIDITY (scoring only)
// ─────────────────────────────────────────
liq_lookback  = 20
stacked_highs = 0
stacked_lows  = 0
for i = 1 to liq_lookback - 1
    if high[i] > high[i + 1]
        stacked_highs += 1
    if low[i] < low[i + 1]
        stacked_lows  += 1
eq_hl_present = stacked_highs >= 3 or stacked_lows >= 3

// ─────────────────────────────────────────
// HTF FVG (scoring + TP only)
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

var float  htf_bull_top = na
var float  htf_bull_bot = na
var float  htf_bear_top = na
var float  htf_bear_bot = na
var string htf_bull_tf  = ""
var string htf_bear_tf  = ""

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

price_in_htf_bull = not na(htf_bull_top) and close <= htf_bull_top and close >= htf_bull_bot
price_in_htf_bear = not na(htf_bear_top) and close >= htf_bear_bot and close <= htf_bear_top

// ─────────────────────────────────────────
// ES SMT
// ─────────────────────────────────────────
es_close      = request.security("CME_MINI:ES1!", timeframe.period, close, lookahead=barmerge.lookahead_off)
es_pd_high    = request.security("CME_MINI:ES1!", "D", high[1], lookahead=barmerge.lookahead_on)
es_pd_low     = request.security("CME_MINI:ES1!", "D", low[1],  lookahead=barmerge.lookahead_on)
es_near_key   = (math.abs(es_close - es_pd_high) / es_pd_high <= smt_threshold / 100) or (math.abs(es_close - es_pd_low) / es_pd_low <= smt_threshold / 100)
smt_confirmed = not show_smt or es_near_key

// ─────────────────────────────────────────
// HRL DETECTION
// ─────────────────────────────────────────
is_swing_high = high[2] > high[3] and high[2] > high[1]
is_swing_low  = low[2]  < low[3]  and low[2]  < low[1]

var float prior_swing_high = na
var float prior_swing_low  = na
var float curr_swing_high  = na
var float curr_swing_low   = na
var int   bull_hrl_bar     = na
var int   bear_hrl_bar     = na
var float bull_hrl_level   = na
var float bear_hrl_level   = na

if is_swing_high
    if not na(curr_swing_high)
        prior_swing_high := curr_swing_high
    curr_swing_high := high[2]
    if not na(prior_swing_high) and high[2] > prior_swing_high
        bear_hrl_bar   := bar_index - 2
        bear_hrl_level := high[2]

if is_swing_low
    if not na(curr_swing_low)
        prior_swing_low := curr_swing_low
    curr_swing_low := low[2]
    if not na(prior_swing_low) and low[2] < prior_swing_low
        bull_hrl_bar   := bar_index - 2
        bull_hrl_level := low[2]

liq_swept_bull = not na(bull_hrl_bar) and bar_index - bull_hrl_bar <= 10
liq_swept_bear = not na(bear_hrl_bar) and bar_index - bear_hrl_bar <= 10

// ─────────────────────────────────────────
// IFVG DETECTION
// ─────────────────────────────────────────
is_bull_fvg = high[2] < low[0]
is_bear_fvg = low[2]  > high[0]

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

while array.size(b_bars) > 0 and bar_index - array.get(b_bars, 0) > 8
    array.shift(b_tops)
    array.shift(b_bots)
    array.shift(b_bars)
while array.size(s_bars) > 0 and bar_index - array.get(s_bars, 0) > 8
    array.shift(s_tops)
    array.shift(s_bots)
    array.shift(s_bars)

candle_range = high - low
body_size    = math.abs(close - open)
is_impulsive = candle_range > atr14 * atr_mult
is_not_doji  = body_size > candle_range * 0.4

bull_ifvg_level = float(na)
bear_ifvg_level = float(na)

if array.size(s_tops) > 0
    for i = 0 to array.size(s_tops) - 1
        fvg_top  = array.get(s_tops, i)
        fvg_bar  = array.get(s_bars, i)
        if bar_index - fvg_bar <= 5 and close > fvg_top and is_impulsive and is_not_doji
            bull_ifvg_level := fvg_top

if array.size(b_bots) > 0
    for i = 0 to array.size(b_bots) - 1
        fvg_bot  = array.get(b_bots, i)
        fvg_bar  = array.get(b_bars, i)
        if bar_index - fvg_bar <= 5 and close < fvg_bot and is_impulsive and is_not_doji
            bear_ifvg_level := fvg_bot

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

if (not na(leg_high) and high > leg_high[1] and high > high[1]) or (not price_in_htf_bull and not price_in_htf_bear)
    leg_signal_fired_bull := false
if (not na(leg_low) and low < leg_low[1] and low < low[1]) or (not price_in_htf_bull and not price_in_htf_bear)
    leg_signal_fired_bear := false

bull_ifvg_signal = not na(bull_ifvg_level) and liq_swept_bull and in_session and not leg_signal_fired_bull
bear_ifvg_signal = not na(bear_ifvg_level) and liq_swept_bear and in_session and not leg_signal_fired_bear

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
// TOOLTIP
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
        good     := good + "• HRL formed — low took out prior low\n"
        has_good := true
    else if not is_bull and liq_swept_bear
        good     := good + "• HRL formed — high took out prior high\n"
        has_good := true
    else
        bad     := bad + "• No HRL — no manipulation leg\n"
        has_bad := true

    if in_session
        good     := good + "• Inside NY session 9:30-11am\n"
        has_good := true
    else
        bad     := bad + "• Outside session\n"
        has_bad := true

    if smt_confirmed
        good     := good + "• ES narrative aligned\n"
        has_good := true
    else
        bad     := bad + "• ES not confirmed\n"
        has_bad := true

    if eq_hl_present
        good     := good + "• Trendline / equal H-L liquidity present\n"
        has_good := true
    else
        bad     := bad + "• No trendline liquidity\n"
        has_bad := true

    if is_impulsive and is_not_doji
        good     := good + "• Inversion candle is impulsive\n"
        has_good := true
    else
        bad     := bad + "• Inversion candle weak\n"
        has_bad := true

    dir    = is_bull ? "LONG" : "SHORT"
    tp_str = tp_lbl != "" ? "\n🎯 TP: " + tp_lbl + " (" + rr_str + "R)\n" : "\n🎯 TP: No clean target found\n"
    sl_str = is_bull ? "\n🛡 SL: HRL low\n" : "\n🛡 SL: HRL high\n"
    header = "━━━━━━━━━━━━━━━━\nJV Signal — " + dir + "\nGrade: " + grade + "  |  Score: " + str.tostring(score) + "/7\n━━━━━━━━━━━━━━━━\n"
    result = header + tp_str + sl_str
    if has_good
        result := result + good
    if has_bad
        result := result + bad
    result

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
    best_dist = float(na)
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

    if array.size(candidates) > 0
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
// STORE SIGNAL DATA
// ─────────────────────────────────────────
var int    bull_signal_bar  = na
var float  bull_entry_price = na
var float  bull_sl_price    = na
var float  bull_tp_price    = na
var string bull_tp_name     = ""
var string bull_rr_str      = ""
var string bull_grade_str   = ""
var string bull_tip_str     = ""

var int    bear_signal_bar  = na
var float  bear_entry_price = na
var float  bear_sl_price    = na
var float  bear_tp_price    = na
var string bear_tp_name     = ""
var string bear_rr_str      = ""
var string bear_grade_str   = ""
var string bear_tip_str     = ""

if bull_ifvg_signal and grade_passes(grade_bull)
    entry    = bull_ifvg_level
    sl_level = not na(bull_hrl_level) ? bull_hrl_level : entry - atr14
    [tp_level, tp_lbl] = find_tp(true, entry, sl_level)
    rr = not na(tp_level) ? str.tostring(math.round(math.abs(tp_level - entry) / math.abs(entry - sl_level), 1)) : "?"
    bull_signal_bar  := bar_index
    bull_entry_price := entry
    bull_sl_price    := sl_level
    bull_tp_price    := tp_level
    bull_tp_name     := tp_lbl
    bull_rr_str      := rr
    bull_grade_str   := grade_bull
    bull_tip_str     := build_tooltip(true, grade_bull, score_bull, tp_lbl, rr)
    leg_signal_fired_bull := true

if bear_ifvg_signal and grade_passes(grade_bear)
    entry    = bear_ifvg_level
    sl_level = not na(bear_hrl_level) ? bear_hrl_level : entry + atr14
    [tp_level, tp_lbl] = find_tp(false, entry, sl_level)
    rr = not na(tp_level) ? str.tostring(math.round(math.abs(tp_level - entry) / math.abs(entry - sl_level), 1)) : "?"
    bear_signal_bar  := bar_index
    bear_entry_price := entry
    bear_sl_price    := sl_level
    bear_tp_price    := tp_level
    bear_tp_name     := tp_lbl
    bear_rr_str      := rr
    bear_grade_str   := grade_bear
    bear_tip_str     := build_tooltip(false, grade_bear, score_bear, tp_lbl, rr)
    leg_signal_fired_bear := true

// ─────────────────────────────────────────
// DRAW — last bar only, buffer safe
// ─────────────────────────────────────────
if barstate.islast
    buf = bar_index - 690

    if not na(bull_signal_bar) and bull_signal_bar >= buf
        b1   = bull_signal_bar
        b2   = math.min(bull_signal_bar + 60, bar_index)
        gcol = bull_grade_str == "S" ? color.new(#FFD700, 0) : bull_grade_str == "A" ? color.new(color.green, 0) : bull_grade_str == "B" ? color.new(color.teal, 0) : color.new(color.gray, 0)
        line.new(b1, bull_entry_price, b2, bull_entry_price, color=gcol, width=2)
        label.new(b1, bull_entry_price, "JV  " + bull_grade_str, color=color.new(color.black, 100), textcolor=color.green, style=label.style_label_up, size=size.small, tooltip=bull_tip_str)
        line.new(b1, bull_sl_price, b2, bull_sl_price, color=color.new(color.red, 40), width=1, style=line.style_dotted)
        label.new(b1, bull_sl_price, "SL", color=color.new(color.black, 100), textcolor=color.red, style=label.style_label_right, size=size.tiny)
        if not na(bull_tp_price)
            line.new(b1, bull_tp_price, b2, bull_tp_price, color=color.new(color.green, 40), width=1, style=line.style_dotted)
            label.new(b1, bull_tp_price, "TP — " + bull_tp_name + " (" + bull_rr_str + "R)", color=color.new(color.black, 100), textcolor=color.green, style=label.style_label_right, size=size.tiny)

    if not na(bear_signal_bar) and bear_signal_bar >= buf
        b1   = bear_signal_bar
        b2   = math.min(bear_signal_bar + 60, bar_index)
        gcol = bear_grade_str == "S" ? color.new(#FFD700, 0) : bear_grade_str == "A" ? color.new(color.red, 0) : bear_grade_str == "B" ? color.new(color.maroon, 0) : color.new(color.gray, 0)
        line.new(b1, bear_entry_price, b2, bear_entry_price, color=gcol, width=2)
        label.new(b1, bear_entry_price, "JV  " + bear_grade_str, color=color.new(color.black, 100), textcolor=color.red, style=label.style_label_down, size=size.small, tooltip=bear_tip_str)
        line.new(b1, bear_sl_price, b2, bear_sl_price, color=color.new(color.red, 40), width=1, style=line.style_dotted)
        label.new(b1, bear_sl_price, "SL", color=color.new(color.black, 100), textcolor=color.red, style=label.style_label_right, size=size.tiny)
        if not na(bear_tp_price)
            line.new(b1, bear_tp_price, b2, bear_tp_price, color=color.new(color.green, 40), width=1, style=line.style_dotted)
            label.new(b1, bear_tp_price, "TP — " + bear_tp_name + " (" + bear_rr_str + "R)", color=color.new(color.black, 100), textcolor=color.green, style=label.style_label_right, size=size.tiny)

// ─────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────
alertcondition(bull_ifvg_signal and grade_passes(grade_bull), title="JV Bull Signal", message="JV: Bullish IFVG signal fired")
alertcondition(bear_ifvg_signal and grade_passes(grade_bear), title="JV Bear Signal", message="JV: Bearish IFVG signal fired")
````

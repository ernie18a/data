# Precision Levels Auto Beta

- url: https://www.tradingview.com/script/28XGeMVv-Precision-Levels-Auto-Beta/
- type: indicator
- pine_id: PUB;50835084ff714b06afe0e5ba8c102975
- version: 3.0

## Description

Precision Levels Auto Beta is an upgraded support and resistance system that automatically plots SPX, ES, NDX, and QQQ levels using a streamlined string‑input structure and built‑in conversion logic. Enter your SPX or NDX string once, and the indicator automatically converts and updates levels when switching between futures and ETF charts. Monthly, Weekly, Daily, Daily Range, and Green Levels are all supported.

A fully adjustable date tab is included for cleaner chart organization. Label placement, label size, price label size, and visibility controls remain fully customizable. Auto‑conversion tickers are preset and should not be modified.

Green Levels are now included and use a separate string. Daily Range levels have been added and the string hierarchy has been updated to reflect the new order of Daily → Daily Range → Weekly → Monthly.

Alerts have been upgraded to trigger when price enters a defined zone around each level (±1 point SPX, ±7 points NDX). Alerts include touch‑based signal strength (T1, T2, T3) and brief price‑action context. Due to TradingView limitations, alerts must be deleted and recreated daily to avoid outdated signals.

During OPEX and holiday sessions, ETF conversions may temporarily become inaccurate due to fund flows and session timing. Futures levels may show slight variation between timeframes because of required look‑back periods, but these differences are minimal.

This is the beta version of the Precision Levels Auto system and will continue to be refined. Feedback is welcome as development continues.

## Source Code

````pine
//@version=6
// v2 (Oct 2026): TradingView retired INDEX:SPX and the SPCFD/CBOE S&P feeds.
// The 4pm SPY/QQQ ratio lock now pulls its symbols from the Auto Conversion
// inputs instead of hardcoded text. All calculations are unchanged.
indicator("Precision Levels Auto", shorttitle="Precision Levels Auto", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

//──────────────────────────────────────────────────────────────────────────────
// Ticker Sensing Logic (unchanged)
//──────────────────────────────────────────────────────────────────────────────
ticker_upper = str.upper(syminfo.ticker)
root_upper   = str.upper(syminfo.root)

on_es_futures = str.contains(ticker_upper, "ES") or str.contains(root_upper, "ES") or str.contains(ticker_upper, "MES") or str.contains(root_upper, "MES")
on_spy        = str.contains(ticker_upper, "SPY")
on_spx        = str.contains(ticker_upper, "SPX")

on_nq_futures = str.contains(ticker_upper, "NQ") or str.contains(root_upper, "NQ") or str.contains(ticker_upper, "MNQ") or str.contains(root_upper, "MNQ")
on_qqq        = str.contains(ticker_upper, "QQQ")
on_ndx        = str.contains(ticker_upper, "NDX") or str.contains(ticker_upper, "NAS100") or str.contains(root_upper, "NDX")

is_es_group       = on_es_futures or on_spy or on_spx
is_nq_group       = on_nq_futures or on_qqq or on_ndx
is_allowed_ticker = is_es_group or is_nq_group

clean_ticker = syminfo.root != "" ? syminfo.root : syminfo.ticker
suffix       = " " + clean_ticker

//──────────────────────────────────────────────────────────────────────────────
// Helpers (unchanged)
//──────────────────────────────────────────────────────────────────────────────
get_label_size(sz) =>
    sz == "tiny" ? size.tiny : sz == "small" ? size.small : sz == "large" ? size.large : sz == "huge" ? size.huge : size.normal

safe_str_to_float(s) =>
    txt = str.trim(s)
    txt == "" ? na : str.tonumber(txt)

get_array_value_as_float(arr, idx) =>
    float out = na
    if array.size(arr) > idx
        out := safe_str_to_float(array.get(arr, idx))
    out

convert_level(baseLevel, chart_es, chart_spy, chart_spx, chart_nq, chart_qqq, chart_ndx, es_ratio, spx_to_spy_ratio, nq_ratio, ndx_to_qqq_ratio, es_spread, nq_spread) =>
    float res = baseLevel
    if not na(baseLevel) and baseLevel != 0.0
        if chart_spx or chart_ndx
            res := baseLevel
        else if chart_es
            res := baseLevel + es_spread
        else if chart_spy
            res := na(spx_to_spy_ratio) ? na : (spx_to_spy_ratio != 0.0 ? baseLevel / spx_to_spy_ratio : baseLevel)
        else if chart_nq
            res := baseLevel + nq_spread
        else if chart_qqq
            res := na(ndx_to_qqq_ratio) ? na : (ndx_to_qqq_ratio != 0.0 ? baseLevel / ndx_to_qqq_ratio : baseLevel)
        else
            res := baseLevel
    res

get_price_auto(idx, manual, levels_array, is_allowed, use_str, chart_es, chart_spy, chart_spx, chart_nq, chart_qqq, chart_ndx, es_ratio, spx_to_spy_ratio, nq_ratio, ndx_to_qqq_ratio, es_spread, nq_spread) =>
    float p = na
    if is_allowed
        p := use_str ? get_array_value_as_float(levels_array, idx) : manual
    float res = na
    if not na(p) and p != 0.0
        res := convert_level(p, chart_es, chart_spy, chart_spx, chart_nq, chart_qqq, chart_ndx, es_ratio, spx_to_spy_ratio, nq_ratio, ndx_to_qqq_ratio, es_spread, nq_spread)
    res

render_level(p, txt, col, l_offset, p_offset, show_l, show_p, l_size, p_size, thickness, line_arr, box_arr, label_arr) =>
    if not na(p) and p != 0.0
        int x_left = math.max(bar_index - 900, 0)
        ln = line.new(x_left, p, bar_index, p, color=col, width=1, extend=extend.right)
        bx = box.new(x_left, p + thickness, bar_index + 100, p - thickness, bgcolor=color.new(col, 90), border_color=col)
        array.push(line_arr, ln)
        array.push(box_arr, bx)
        if show_l
            lb1 = label.new(bar_index + l_offset, p, txt, color=col, style=label.style_label_down, textcolor=color.white, size=l_size)
            array.push(label_arr, lb1)
        if show_p
            lb2 = label.new(bar_index + p_offset, p, str.tostring(p, "#.##"), color=color.new(col, 20), style=label.style_label_left, textcolor=color.white, size=p_size)
            array.push(label_arr, lb2)

touch_label(cnt) =>
    cnt == 1 ? " [T1 STRONG]" : cnt == 2 ? " [T2 MODERATE]" : " [T3+ WEAK]"

//──────────────────────────────────────────────────────────────────────────────
// Visual Settings
//──────────────────────────────────────────────────────────────────────────────
label_size_input   = input.string("normal", "Label Size", options=["tiny", "small", "normal", "large", "huge"], group="Visual Settings")
show_level_label   = input.bool(true, "Show Level Labels",  group="Visual Settings")
show_price_label   = input.bool(true, "Show Price Labels",  group="Visual Settings")
price_label_size   = input.string("normal", "Price Label Size", options=["tiny", "small", "normal", "large", "huge"], group="Visual Settings")
level_label_offset  = input.int(15,   "Level Label Offset (Bars)",  group="Visual Settings")
price_label_offset  = input.int(20,   "Price Label Offset (Bars)",  group="Visual Settings")
date_label_height   = input.float(50.0, "Date Label Height (%)", minval=0.0, maxval=100.0, step=1.0, group="Visual Settings")

label_size_enum = get_label_size(label_size_input)
price_size_enum = get_label_size(price_label_size)

//──────────────────────────────────────────────────────────────────────────────
// Auto Conversion + Live Data + Locks (unchanged)
//──────────────────────────────────────────────────────────────────────────────
spx_symbol        = input.symbol("SP:SPX",            "SPX Cash Symbol",           group="Auto Conversion")
spy_symbol        = input.symbol("AMEX:SPY",           "SPY Symbol",                group="Auto Conversion")
es_symbol         = input.symbol("CME_MINI:ES1!",      "ES Continuous Symbol",      group="Auto Conversion")
ndx_symbol        = input.symbol("NASDAQ:NDX",         "NDX Cash Symbol",           group="Auto Conversion")
qqq_symbol        = input.symbol("NASDAQ:QQQ",         "QQQ Symbol",                group="Auto Conversion")
nq_symbol         = input.symbol("CME_MINI:NQ1!",      "NQ Continuous Symbol",      group="Auto Conversion")
spx_cfd_symbol    = input.symbol("FOREXCOM:SPX500",    "SPX500 CFD Continuous",     group="Auto Conversion")
nas100_cfd_symbol = input.symbol("FOREXCOM:NAS100",    "NAS100 CFD Continuous",     group="Auto Conversion")

int    anchor_hour   = 20
int    anchor_minute = 0
string anchor_tz     = "America/New_York"

use_string_input = input.bool(false, "Use String Input for Levels", group="Daily String Inputs")
levels_string    = input.string("",  "SPX Levels String",           group="Daily String Inputs")
nq_levels_string = input.string("",  "NAS Levels String",           group="Daily String Inputs")

use_green_string_input = input.bool(false, "Use Green Level String Input", group="Daily String Inputs")
green_levels_string    = input.string("",  "SPX Green String",                group="Daily String Inputs")
nq_green_levels_string = input.string("",  "NAS Green String",                group="Daily String Inputs")

// Level inputs (unchanged)
m1_p_in = input.price(0.0, "Monthly 1 Price", group="Monthly")
m1_l_in = input.string("Monthly 1", "Monthly 1 Label", group="Monthly")
m1_c    = input.color(color.rgb(128, 0, 128), "Monthly 1 Color", group="Monthly")
m2_p_in = input.price(0.0, "Monthly 2 Price", group="Monthly")
m2_l_in = input.string("Monthly 2", "Monthly 2 Label", group="Monthly")
m2_c    = input.color(color.rgb(128, 0, 128), "Monthly 2 Color", group="Monthly")

w1_p_in = input.price(0.0, "Weekly 1 Price", group="Weekly")
w1_l_in = input.string("Weekly 1", "Weekly 1 Label", group="Weekly")
w1_c    = input.color(color.rgb(0, 0, 255), "Weekly 1 Color", group="Weekly")
w2_p_in = input.price(0.0, "Weekly 2 Price", group="Weekly")
w2_l_in = input.string("Weekly 2", "Weekly 2 Label", group="Weekly")
w2_c    = input.color(color.rgb(0, 0, 255), "Weekly 2 Color", group="Weekly")

d1_p_in = input.price(0.0, "Daily 1 Price", group="Daily")
d1_l_in = input.string("Daily 1", "Daily 1 Label", group="Daily")
d1_c    = input.color(color.rgb(255, 0, 0), "Daily 1 Color", group="Daily")
d2_p_in = input.price(0.0, "Daily 2 Price", group="Daily")
d2_l_in = input.string("Daily 2", "Daily 2 Label", group="Daily")
d2_c    = input.color(color.rgb(255, 0, 0), "Daily 2 Color", group="Daily")
d3_p_in = input.price(0.0, "Daily 3 Price", group="Daily")
d3_l_in = input.string("Daily 3", "Daily 3 Label", group="Daily")
d3_c    = input.color(color.rgb(255, 105, 180), "Daily 3 Color", group="Daily")
d4_p_in = input.price(0.0, "Daily 4 Price", group="Daily")
d4_l_in = input.string("Daily 4", "Daily 4 Label", group="Daily")
d4_c    = input.color(color.rgb(255, 105, 180), "Daily 4 Color", group="Daily")
d5_p_in = input.price(0.0, "Daily 5 Price", group="Daily")
d5_l_in = input.string("Daily 5", "Daily 5 Label", group="Daily")
d5_c    = input.color(color.rgb(255, 0, 0), "Daily 5 Color", group="Daily")
d6_p_in = input.price(0.0, "Daily 6 Price", group="Daily")
d6_l_in = input.string("Daily 6", "Daily 6 Label", group="Daily")
d6_c    = input.color(color.rgb(255, 0, 0), "Daily 6 Color", group="Daily")

dr1_p_in = input.price(0.0, "Range 1 Price", group="Range")
dr1_l_in = input.string("Range 1", "Range 1 Label", group="Range")
dr1_c    = input.color(color.rgb(0, 188, 212), "Range 1 Color", group="Range")
dr2_p_in = input.price(0.0, "Range 2 Price", group="Range")
dr2_l_in = input.string("Range 2", "Range 2 Label", group="Range")
dr2_c    = input.color(color.rgb(0, 188, 212), "Range 2 Color", group="Range")

// Live data (unchanged)
spx_cash = request.security(spx_symbol, timeframe.period, close)
spy_cash = request.security(spy_symbol, timeframe.period, close)
es_live  = request.security(es_symbol,  timeframe.period, close)
ndx_cash = request.security(ndx_symbol, timeframe.period, close)
qqq_cash = request.security(qqq_symbol, timeframe.period, close)
nq_live  = request.security(nq_symbol,  timeframe.period, close)

raw_es_ratio   = not na(spx_cash) and spx_cash != 0.0 ? es_live   / spx_cash : 1.0
raw_spx_to_spy = not na(spy_cash) and spy_cash != 0.0 ? spx_cash  / spy_cash : 1.0
raw_nq_ratio   = not na(ndx_cash) and ndx_cash != 0.0 ? nq_live   / ndx_cash : 1.0
raw_ndx_to_qqq = not na(qqq_cash) and qqq_cash != 0.0 ? ndx_cash  / qqq_cash : 1.0

//──────────────────────────────────────────────────────────────────────────────
// Futures Ratio Lock — Asia Open Anchor (20:00 NY) (unchanged)
//──────────────────────────────────────────────────────────────────────────────
curr_hour   = hour(time, anchor_tz)
curr_minute = minute(time, anchor_tz)
prev_hour   = hour(time[1], anchor_tz)
prev_minute = minute(time[1], anchor_tz)

anchor_trigger = (curr_hour > anchor_hour or (curr_hour == anchor_hour and curr_minute >= anchor_minute)) and
                 (prev_hour < anchor_hour or (prev_hour == anchor_hour and prev_minute < anchor_minute))

var float es_ratio_locked = na
var float nq_ratio_locked = na

if na(es_ratio_locked)
    es_ratio_locked := raw_es_ratio
if na(nq_ratio_locked)
    nq_ratio_locked := raw_nq_ratio

if anchor_trigger
    es_ratio_locked := raw_es_ratio
    nq_ratio_locked := raw_nq_ratio

//──────────────────────────────────────────────────────────────────────────────
// ETF Ratio Lock — 4pm Market Close (SPY / QQQ only)
// FIXED in v2: these requests now use the Auto Conversion inputs above instead
// of hardcoded INDEX:SPX / INDEX:NDX (retired by TradingView). Same data,
// same math. If a symbol is ever renamed again, fix it in Settings > Inputs.
//──────────────────────────────────────────────────────────────────────────────
get_ratio_at_4pm() =>
    is_400pm  = hour(time, "America/New_York") == 16 and minute(time, "America/New_York") == 0
    spx_price = close
    spy_price = request.security(spy_symbol, "1", close, lookahead=barmerge.lookahead_on)
    ndx_price = request.security(ndx_symbol, "1", close, lookahead=barmerge.lookahead_on)
    qqq_price = request.security(qqq_symbol, "1", close, lookahead=barmerge.lookahead_on)
    var float spy_r = na
    var float qqq_r = na
    if is_400pm
        if not na(spy_price) and spy_price != 0
            spy_r := spx_price / spy_price
        if not na(qqq_price) and qqq_price != 0
            qqq_r := ndx_price / qqq_price
    [spy_r, qqq_r]

[spx_to_spy_from_spx, ndx_to_qqq_from_spx] = request.security(spx_symbol, "1", get_ratio_at_4pm(), lookahead=barmerge.lookahead_on)

var float spx_to_spy_locked = na
var float ndx_to_qqq_locked = na
if not na(spx_to_spy_from_spx)
    spx_to_spy_locked := spx_to_spy_from_spx
if not na(ndx_to_qqq_from_spx)
    ndx_to_qqq_locked := ndx_to_qqq_from_spx

spx_to_spy_locked := na(spx_to_spy_locked) ? nz(spx_to_spy_locked[1]) : spx_to_spy_locked
ndx_to_qqq_locked := na(ndx_to_qqq_locked) ? nz(ndx_to_qqq_locked[1]) : ndx_to_qqq_locked

es_1830_close = request.security(es_symbol,          "1", close[20])
spx_cfd_1830  = request.security(spx_cfd_symbol,     "1", close[20])
nq_1830_close = request.security(nq_symbol,          "1", close[20])
nas_cfd_1830  = request.security(nas100_cfd_symbol,  "1", close[20])

var float es_spread_locked = na
var float nq_spread_locked = na

// Reset at 5 PM ET so the spread re-locks fresh each evening
if hour(time, anchor_tz) >= 17 and hour(time[1], anchor_tz) < 17
    es_spread_locked := na
    nq_spread_locked := na

// Lock on any bar past 18:50 ET until 9 PM; retries each bar until data is available
bool past_1850 = hour(time, anchor_tz) > 18 or (hour(time, anchor_tz) == 18 and minute(time, anchor_tz) >= 50)
if na(es_spread_locked) and past_1850 and hour(time, anchor_tz) < 21
    if not na(es_1830_close) and not na(spx_cfd_1830)
        es_spread_locked := es_1830_close - spx_cfd_1830
    if not na(nq_1830_close) and not na(nas_cfd_1830)
        nq_spread_locked := nq_1830_close - nas_cfd_1830

// String arrays + prices (unchanged)
active_str     = is_es_group ? levels_string       : is_nq_group ? nq_levels_string       : ""
all_levels_arr = str.split(active_str, ",")

active_green_str = is_es_group ? green_levels_string : is_nq_group ? nq_green_levels_string : ""
green_levels_arr = str.split(active_green_str, ",")

// Prices (unchanged)
m1_p  = get_price_auto(10, m1_p_in,  all_levels_arr, is_allowed_ticker, use_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)
m2_p  = get_price_auto(11, m2_p_in,  all_levels_arr, is_allowed_ticker, use_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)
w1_p  = get_price_auto(8,  w1_p_in,  all_levels_arr, is_allowed_ticker, use_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)
w2_p  = get_price_auto(9,  w2_p_in,  all_levels_arr, is_allowed_ticker, use_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)
d1_p  = get_price_auto(0,  d1_p_in,  all_levels_arr, is_allowed_ticker, use_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)
d2_p  = get_price_auto(1,  d2_p_in,  all_levels_arr, is_allowed_ticker, use_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)
d3_p  = get_price_auto(2,  d3_p_in,  all_levels_arr, is_allowed_ticker, use_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)
d4_p  = get_price_auto(3,  d4_p_in,  all_levels_arr, is_allowed_ticker, use_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)
d5_p  = get_price_auto(4,  d5_p_in,  all_levels_arr, is_allowed_ticker, use_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)
d6_p  = get_price_auto(5,  d6_p_in,  all_levels_arr, is_allowed_ticker, use_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)
dr1_p = get_price_auto(6,  dr1_p_in, all_levels_arr, is_allowed_ticker, use_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)
dr2_p = get_price_auto(7,  dr2_p_in, all_levels_arr, is_allowed_ticker, use_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)

g1_p  = get_price_auto(0,  0.0, green_levels_arr, is_allowed_ticker, use_green_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)
g2_p  = get_price_auto(1,  0.0, green_levels_arr, is_allowed_ticker, use_green_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)
g3_p  = get_price_auto(2,  0.0, green_levels_arr, is_allowed_ticker, use_green_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)
g4_p  = get_price_auto(3,  0.0, green_levels_arr, is_allowed_ticker, use_green_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)
g5_p  = get_price_auto(4,  0.0, green_levels_arr, is_allowed_ticker, use_green_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)
g6_p  = get_price_auto(5,  0.0, green_levels_arr, is_allowed_ticker, use_green_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)
g7_p  = get_price_auto(6,  0.0, green_levels_arr, is_allowed_ticker, use_green_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)
g8_p  = get_price_auto(7,  0.0, green_levels_arr, is_allowed_ticker, use_green_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)
g9_p  = get_price_auto(8,  0.0, green_levels_arr, is_allowed_ticker, use_green_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)
g10_p = get_price_auto(9,  0.0, green_levels_arr, is_allowed_ticker, use_green_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)
g11_p = get_price_auto(10, 0.0, green_levels_arr, is_allowed_ticker, use_green_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)
g12_p = get_price_auto(11, 0.0, green_levels_arr, is_allowed_ticker, use_green_string_input, on_es_futures, on_spy, on_spx, on_nq_futures, on_qqq, on_ndx, es_ratio_locked, spx_to_spy_locked, nq_ratio_locked, ndx_to_qqq_locked, es_spread_locked, nq_spread_locked)

green_col = color.rgb(0, 170, 0)

//──────────────────────────────────────────────────────────────────────────────
// Alert Logic — Entry-Only with Session Reset + Touch Strength (T1/T2/T3)
//──────────────────────────────────────────────────────────────────────────────

// Zone thickness (same values as visual rendering)
float thickness = (on_spy or on_qqq) ? 0.10 : (on_ndx or on_nq_futures) ? 7.0 : 1.0

// Session resets at 6PM ET (futures open) — clears all in-zone states and touch counts
int  ny_h_cur      = hour(time,    "America/New_York")
int  ny_h_prev_bar = hour(time[1], "America/New_York")
bool new_session   = not na(ny_h_prev_bar) and ny_h_cur >= 18 and ny_h_prev_bar < 18

// In-zone state: true while price is currently inside a zone, false when outside
var bool iz_d1  = false
var bool iz_d2  = false
var bool iz_d3  = false
var bool iz_d4  = false
var bool iz_d5  = false
var bool iz_d6  = false
var bool iz_dr1 = false
var bool iz_dr2 = false
var bool iz_w1  = false
var bool iz_w2  = false
var bool iz_m1  = false
var bool iz_m2  = false

// Touch counts: increment on each entry (out→in transition), reset at 6PM
var int tc_d1  = 0
var int tc_d2  = 0
var int tc_d3  = 0
var int tc_d4  = 0
var int tc_d5  = 0
var int tc_d6  = 0
var int tc_dr1 = 0
var int tc_dr2 = 0
var int tc_w1  = 0
var int tc_w2  = 0
var int tc_m1  = 0
var int tc_m2  = 0

// Green level state arrays (12 slots, one per green level)
var bool[] iz_green = array.new_bool(12, false)
var int[]  tc_green = array.new_int(12, 0)

// 6PM reset: clear all in-zone states and touch counts for the new session
if new_session
    iz_d1  := false
    iz_d2  := false
    iz_d3  := false
    iz_d4  := false
    iz_d5  := false
    iz_d6  := false
    iz_dr1 := false
    iz_dr2 := false
    iz_w1  := false
    iz_w2  := false
    iz_m1  := false
    iz_m2  := false
    tc_d1  := 0
    tc_d2  := 0
    tc_d3  := 0
    tc_d4  := 0
    tc_d5  := 0
    tc_d6  := 0
    tc_dr1 := 0
    tc_dr2 := 0
    tc_w1  := 0
    tc_w2  := 0
    tc_m1  := 0
    tc_m2  := 0
    for i = 0 to 11
        array.set(iz_green, i, false)
        array.set(tc_green, i, 0)

// Zone boundary calculations (same tolerance as visual zones)
float d1_zone_u  = d1_p  + thickness
float d1_zone_l  = d1_p  - thickness
float d2_zone_u  = d2_p  + thickness
float d2_zone_l  = d2_p  - thickness
float d3_zone_u  = d3_p  + thickness
float d3_zone_l  = d3_p  - thickness
float d4_zone_u  = d4_p  + thickness
float d4_zone_l  = d4_p  - thickness
float d5_zone_u  = d5_p  + thickness
float d5_zone_l  = d5_p  - thickness
float d6_zone_u  = d6_p  + thickness
float d6_zone_l  = d6_p  - thickness
float dr1_zone_u = dr1_p + thickness
float dr1_zone_l = dr1_p - thickness
float dr2_zone_u = dr2_p + thickness
float dr2_zone_l = dr2_p - thickness
float w1_zone_u  = w1_p  + thickness
float w1_zone_l  = w1_p  - thickness
float w2_zone_u  = w2_p  + thickness
float w2_zone_l  = w2_p  - thickness
float m1_zone_u  = m1_p  + thickness
float m1_zone_l  = m1_p  - thickness
float m2_zone_u  = m2_p  + thickness
float m2_zone_l  = m2_p  - thickness

// Current bar zone checks
bool now_d1  = high >= d1_zone_l  and low <= d1_zone_u
bool now_d2  = high >= d2_zone_l  and low <= d2_zone_u
bool now_d3  = high >= d3_zone_l  and low <= d3_zone_u
bool now_d4  = high >= d4_zone_l  and low <= d4_zone_u
bool now_d5  = high >= d5_zone_l  and low <= d5_zone_u
bool now_d6  = high >= d6_zone_l  and low <= d6_zone_u
bool now_dr1 = high >= dr1_zone_l and low <= dr1_zone_u
bool now_dr2 = high >= dr2_zone_l and low <= dr2_zone_u
bool now_w1  = high >= w1_zone_l  and low <= w1_zone_u
bool now_w2  = high >= w2_zone_l  and low <= w2_zone_u
bool now_m1  = high >= m1_zone_l  and low <= m1_zone_u
bool now_m2  = high >= m2_zone_l  and low <= m2_zone_u

// Daily level alerts — fire on zone entry (out→in), silent while price stays inside
if now_d1 and not iz_d1
    tc_d1 += 1
    alert(clean_ticker + " R2_Hi Daily level hit" + touch_label(tc_d1), alert.freq_once_per_bar)
iz_d1 := now_d1

if now_d2 and not iz_d2
    tc_d2 += 1
    alert(clean_ticker + " R1_Hi Daily level hit" + touch_label(tc_d2), alert.freq_once_per_bar)
iz_d2 := now_d2

if now_d3 and not iz_d3
    tc_d3 += 1
    alert(clean_ticker + " P_Hi Daily level hit" + touch_label(tc_d3), alert.freq_once_per_bar)
iz_d3 := now_d3

if now_d4 and not iz_d4
    tc_d4 += 1
    alert(clean_ticker + " P_Lo Daily level hit" + touch_label(tc_d4), alert.freq_once_per_bar)
iz_d4 := now_d4

if now_d5 and not iz_d5
    tc_d5 += 1
    alert(clean_ticker + " R1_Lo Daily level hit" + touch_label(tc_d5), alert.freq_once_per_bar)
iz_d5 := now_d5

if now_d6 and not iz_d6
    tc_d6 += 1
    alert(clean_ticker + " R2_Lo Daily level hit" + touch_label(tc_d6), alert.freq_once_per_bar)
iz_d6 := now_d6

// Range level alerts
if now_dr1 and not iz_dr1
    tc_dr1 += 1
    alert(clean_ticker + " DR_Hi Daily level hit" + touch_label(tc_dr1), alert.freq_once_per_bar)
iz_dr1 := now_dr1

if now_dr2 and not iz_dr2
    tc_dr2 += 1
    alert(clean_ticker + " DR_Lo Daily level hit" + touch_label(tc_dr2), alert.freq_once_per_bar)
iz_dr2 := now_dr2

// Weekly level alerts
if now_w1 and not iz_w1
    tc_w1 += 1
    alert(clean_ticker + " W_Hi Weekly level hit" + touch_label(tc_w1), alert.freq_once_per_bar)
iz_w1 := now_w1

if now_w2 and not iz_w2
    tc_w2 += 1
    alert(clean_ticker + " W_Lo Weekly level hit" + touch_label(tc_w2), alert.freq_once_per_bar)
iz_w2 := now_w2

// Monthly level alerts
if now_m1 and not iz_m1
    tc_m1 += 1
    alert(clean_ticker + " M_Hi Monthly level hit" + touch_label(tc_m1), alert.freq_once_per_bar)
iz_m1 := now_m1

if now_m2 and not iz_m2
    tc_m2 += 1
    alert(clean_ticker + " M_Lo Monthly level hit" + touch_label(tc_m2), alert.freq_once_per_bar)
iz_m2 := now_m2

// Green level alerts — each green level tracked individually
for i = 0 to 11
    float gp = na
    if i == 0
        gp := g1_p
    else if i == 1
        gp := g2_p
    else if i == 2
        gp := g3_p
    else if i == 3
        gp := g4_p
    else if i == 4
        gp := g5_p
    else if i == 5
        gp := g6_p
    else if i == 6
        gp := g7_p
    else if i == 7
        gp := g8_p
    else if i == 8
        gp := g9_p
    else if i == 9
        gp := g10_p
    else if i == 10
        gp := g11_p
    else if i == 11
        gp := g12_p

    if not na(gp) and gp != 0.0
        bool now_g = high >= (gp - thickness) and low <= (gp + thickness)
        bool was_g = array.get(iz_green, i)
        if now_g and not was_g
            int cnt_g = array.get(tc_green, i) + 1
            array.set(tc_green, i, cnt_g)
            alert(clean_ticker + " Green level hit" + touch_label(cnt_g), alert.freq_once_per_bar)
        array.set(iz_green, i, now_g)

//──────────────────────────────────────────────────────────────────────────────
// Visual Rendering (unchanged)
//──────────────────────────────────────────────────────────────────────────────
var line[]  level_lines  = array.new_line()
var box[]   level_boxes  = array.new_box()
var label[] level_labels = array.new_label()
var label   date_lbl         = na
var label   spread_warn_lbl  = na

float chart_range = ta.highest(high, 200) - ta.lowest(low, 200)
float chart_top   = ta.highest(high, 200) + chart_range * (date_label_height / 100.0)

if barstate.islast
    if array.size(level_lines) > 0
        for i = 0 to array.size(level_lines) - 1
            line.delete(array.get(level_lines, i))
        array.clear(level_lines)

    if array.size(level_boxes) > 0
        for i = 0 to array.size(level_boxes) - 1
            box.delete(array.get(level_boxes, i))
        array.clear(level_boxes)

    if array.size(level_labels) > 0
        for i = 0 to array.size(level_labels) - 1
            label.delete(array.get(level_labels, i))
        array.clear(level_labels)

    // Date label — top right corner, always visible
    label.delete(date_lbl)
    date_lbl := label.new(
         bar_index + 5, chart_top,
         str.format_time(timenow, "MM/dd/yyyy", "America/New_York"),
         style=label.style_label_left, size=size.small,
         color=color.new(color.gray, 30), textcolor=color.white)

    // Spread lock warning — shown on ES/NQ charts when conversion has not locked yet
    label.delete(spread_warn_lbl)
    spread_warn_lbl := na
    if (on_es_futures and na(es_spread_locked)) or (on_nq_futures and na(nq_spread_locked))
        string warn_ticker = on_es_futures ? "ES" : "NQ"
        spread_warn_lbl := label.new(
             bar_index, ta.lowest(low, 200),
             warn_ticker + " levels not converted — spread locks at 6:50 PM ET",
             style=label.style_label_up, size=size.small,
             color=color.orange, textcolor=color.white)

    thickness := (on_spy or on_qqq) ? 0.10 : (on_ndx or on_nq_futures) ? 7.0 : 1.0

    render_level(m1_p,  (use_string_input ? "Monthly"     : m1_l_in)  + suffix, m1_c,  level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)
    render_level(m2_p,  (use_string_input ? "Monthly"     : m2_l_in)  + suffix, m2_c,  level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)
    render_level(w1_p,  (use_string_input ? "Weekly"      : w1_l_in)  + suffix, w1_c,  level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)
    render_level(w2_p,  (use_string_input ? "Weekly"      : w2_l_in)  + suffix, w2_c,  level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)
    render_level(d1_p,  (use_string_input ? "Daily"       : d1_l_in)  + suffix, d1_c,  level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)
    render_level(d2_p,  (use_string_input ? "Daily"       : d2_l_in)  + suffix, d2_c,  level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)
    render_level(d3_p,  (use_string_input ? "Daily"       : d3_l_in)  + suffix, d3_c,  level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)
    render_level(d4_p,  (use_string_input ? "Daily"       : d4_l_in)  + suffix, d4_c,  level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)
    render_level(d5_p,  (use_string_input ? "Daily"       : d5_l_in)  + suffix, d5_c,  level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)
    render_level(d6_p,  (use_string_input ? "Daily"       : d6_l_in)  + suffix, d6_c,  level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)
    render_level(dr1_p, (use_string_input ? "Daily Range" : dr1_l_in) + suffix, dr1_c, level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)
    render_level(dr2_p, (use_string_input ? "Daily Range" : dr2_l_in) + suffix, dr2_c, level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)

    render_level(g1_p,  "Green Level 1"  + suffix, green_col, level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)
    render_level(g2_p,  "Green Level 2"  + suffix, green_col, level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)
    render_level(g3_p,  "Green Level 3"  + suffix, green_col, level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)
    render_level(g4_p,  "Green Level 4"  + suffix, green_col, level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)
    render_level(g5_p,  "Green Level 5"  + suffix, green_col, level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)
    render_level(g6_p,  "Green Level 6"  + suffix, green_col, level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)
    render_level(g7_p,  "Green Level 7"  + suffix, green_col, level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)
    render_level(g8_p,  "Green Level 8"  + suffix, green_col, level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)
    render_level(g9_p,  "Green Level 9"  + suffix, green_col, level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)
    render_level(g10_p, "Green Level 10" + suffix, green_col, level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)
    render_level(g11_p, "Green Level 11" + suffix, green_col, level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)
    render_level(g12_p, "Green Level 12" + suffix, green_col, level_label_offset, price_label_offset, show_level_label, show_price_label, label_size_enum, price_size_enum, thickness, level_lines, level_boxes, level_labels)
````

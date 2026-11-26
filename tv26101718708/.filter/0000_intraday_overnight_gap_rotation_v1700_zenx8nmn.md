# 0000 Intraday & Overnight Gap Rotation v17.00

- url: https://www.tradingview.com/script/ZEnX8Nmn/
- type: indicator
- pine_id: PUB;88fa8d9d5d434e7592aca89bc244f748
- version: 1.0

## Description

Here is a comprehensive breakdown of how the "Intraday & Overnight Gap Rotation Matrix" system works.

This strategy is designed as a quantitative testing lab to exploit (or fade) gap anomalies and intraday momentum across a basket of up to 38 assets. It does not hold positions over multiple days; instead, it executes high-frequency, strictly time-bound trades.

The Core Concept

The system revolves around the idea that market performance is heavily divided between two distinct sessions: the Overnight Session (Close to Open) and the Regular Trading Hours (Open to Close). Depending on the mode you select, the algorithm tries to capture specific behavioral anomalies within these windows.

The 3 Strategy Modes

1. Overnight Premium (Buy Close, Sell Open)

The Logic: Historically, a massive portion of the stock market's total return occurs while the market is closed. This mode attempts to capture that "night effect."

The Trigger: Just before the market closes today, the system looks at the intraday performance (Open to Close) of all assets.

The Action: It buys the top-performing assets right at the Close, holds them overnight, and sells them immediately at the next morning's Open, capturing the overnight gap.

2. Intraday Momentum (Buy Open, Sell Close - Best Gaps)

The Logic: "Strength begets strength." If an asset gaps up strongly at the open due to overnight news or earnings, momentum traders will often push it even higher during the day.

The Trigger: At the Open, the system measures the overnight gap (Yesterday's Close to Today's Open).

The Action: It buys the assets with the highest positive gaps right at the Open and sells them at the Close of the same day.

3. Intraday Fade (Buy Open, Sell Close - Worst Gaps)

The Logic: Mean reversion. When an asset suffers a violent, panicked gap down at the open, it has often overreacted. Institutional buyers frequently step in to "buy the dip," causing the gap to partially close intraday.

The Trigger: At the Open, the system measures the overnight gap, but ranks them in reverse.

The Action: It buys the assets with the most brutal negative gaps at the Open and sells them at the Close, hoping for an intraday bounce.

Key Mechanics & Filters

The Universe & Top N Rotation: The system tracks a customized universe of up to 38 assets. Every single day, it ranks them all according to the chosen strategy mode and allocates capital equally into the "Top N" (e.g., the top 5).

The Minimum Move Threshold: This is the most crucial filter for real-world application. High-frequency systems are easily destroyed by trading costs (slippage, bid/ask spread, commissions). The threshold ensures the system only trades when the setup is extreme enough to justify the costs. If no asset meets the minimum threshold (e.g., > 1.5% move), the system stays safely in cash for the day.

Cost Simulation: The system applies a customizable cost penalty twice per day (once for the entry, once for the exit) to simulate a highly realistic equity curve.

Seasonality Matrix (Optional): A master switch that can block all trading during specific, historically weak calendar quarters or half-months, forcing the portfolio into cash to avoid systemic market drawdowns.

The Analytics Dashboard

Instead of just plotting buy and sell arrows, the system acts as a live analytics engine. It features a dashboard that tracks:

Net CAGR: Compound Annual Growth Rate, after all simulated trading costs.

Maximum Drawdown: The worst peak-to-trough drop the strategy ever experienced.

Trade Win Rate: The percentage of daily rotations that ended in a profit.

Daily Popups: Chart labels that break down exactly which assets were bought, what their target metric was (the Gap or the ID Run), and what their exact Profit/Loss contribution was for that specific session.

## Source Code

````pine
//@version=6
// 0000 Intraday & Overnight Gap Rotation Matrix v17.00
// 3-in-1 Strategy incl. Minimum Threshold Filter against high cost drag

indicator("0000 Intraday & Overnight Gap Rotation v17.00", overlay=false, max_labels_count=500)

// --- 1. SETTINGS ---
gap_mode     = input.string("Overnight (Buy Close, Sell Open) - Best Intraday Run", "Strategy Mode", options=["Intraday (Buy Open, Sell Close) - Best Gaps", "Intraday (Buy Open, Sell Close) - Worst Gaps (Fade)", "Overnight (Buy Close, Sell Open) - Best Intraday Run"], group="1. Core Strategy")
start_year   = input.int(2000, "Start Year", group="1. Core Strategy")
end_year     = input.int(2099, "Stop Year (Backtest End)", group="1. Core Strategy")
top_n        = input.int(1, "Top N Stocks (Buy at Open/Close)", group="1. Core Strategy", minval=1)

min_move_pct = input.float(1.5, "► Min. Move Threshold (%) to Trade", step=0.5, minval=0.0, group="2. Filters & Costs", tooltip="Filters out weak signals to save on trading costs. 0.0 means it trades every day.") / 100
cost_pct     = input.float(0.0, "► Cost per Trade (%) - Applies 2x daily!", minval=0.0, step=0.01, group="2. Filters & Costs") / 100
filter_sym   = input.symbol("NASDAQ:QQQ", "Benchmark Ticker", group="2. Filters & Costs")

universe_lim = 38

// --- 3. SEASONALITY QUARTER MATRIX (EXIT) ---
use_seasonal    = input.bool(false, "Master Switch: Seasonality Matrix active?", group="3. Seasonality (Exit to Cash)")

g_s1 = "Matrix: Jan - Jun (Quarters)"
s_jan_q1 = input.bool(false, "Jan Q1", inline="j", group=g_s1), s_jan_q2 = input.bool(false, "Q2", inline="j", group=g_s1), s_jan_q3 = input.bool(false, "Q3", inline="j", group=g_s1), s_jan_q4 = input.bool(false, "Q4", inline="j", group=g_s1)
s_feb_q1 = input.bool(false, "Feb Q1", inline="f", group=g_s1), s_feb_q2 = input.bool(false, "Q2", inline="f", group=g_s1), s_feb_q3 = input.bool(false, "Q3", inline="f", group=g_s1), s_feb_q4 = input.bool(false, "Q4", inline="f", group=g_s1)
s_mar_q1 = input.bool(false, "Mar Q1", inline="m", group=g_s1), s_mar_q2 = input.bool(false, "Q2", inline="m", group=g_s1), s_mar_q3 = input.bool(false, "Q3", inline="m", group=g_s1), s_mar_q4 = input.bool(false, "Q4", inline="m", group=g_s1)
s_apr_q1 = input.bool(false, "Apr Q1", inline="a", group=g_s1), s_apr_q2 = input.bool(false, "Q2", inline="a", group=g_s1), s_apr_q3 = input.bool(false, "Q3", inline="a", group=g_s1), s_apr_q4 = input.bool(false, "Q4", inline="a", group=g_s1)
s_may_q1 = input.bool(false, "May Q1", inline="y", group=g_s1), s_may_q2 = input.bool(false, "Q2", inline="y", group=g_s1), s_may_q3 = input.bool(false, "Q3", inline="y", group=g_s1), s_may_q4 = input.bool(false, "Q4", inline="y", group=g_s1)
s_jun_q1 = input.bool(false, "Jun Q1", inline="u", group=g_s1), s_jun_q2 = input.bool(false, "Q2", inline="u", group=g_s1), s_jun_q3 = input.bool(false, "Q3", inline="u", group=g_s1), s_jun_q4 = input.bool(false, "Q4", inline="u", group=g_s1)

g_s2 = "Matrix: Jul - Dec (Quarters)"
s_jul_q1 = input.bool(false, "Jul Q1", inline="l", group=g_s2), s_jul_q2 = input.bool(false, "Q2", inline="l", group=g_s2), s_jul_q3 = input.bool(false, "Q3", inline="l", group=g_s2), s_jul_q4 = input.bool(false, "Q4", inline="l", group=g_s2)
s_aug_q1 = input.bool(false, "Aug Q1", inline="g", group=g_s2), s_aug_q2 = input.bool(false, "Q2", inline="g", group=g_s2), s_aug_q3 = input.bool(false, "Q3", inline="g", group=g_s2), s_aug_q4 = input.bool(false, "Q4", inline="g", group=g_s2)
s_sep_q1 = input.bool(false, "Sep Q1", inline="s", group=g_s2), s_sep_q2 = input.bool(false, "Q2", inline="s", group=g_s2), s_sep_q3 = input.bool(false, "Q3", inline="s", group=g_s2), s_sep_q4 = input.bool(false, "Q4", inline="s", group=g_s2)
s_oct_q1 = input.bool(false, "Oct Q1", inline="o", group=g_s2), s_oct_q2 = input.bool(false, "Q2", inline="o", group=g_s2), s_oct_q3 = input.bool(false, "Q3", inline="o", group=g_s2), s_oct_q4 = input.bool(false, "Q4", inline="o", group=g_s2)
s_nov_q1 = input.bool(false, "Nov Q1", inline="n", group=g_s2), s_nov_q2 = input.bool(false, "Q2", inline="n", group=g_s2), s_nov_q3 = input.bool(false, "Q3", inline="n", group=g_s2), s_nov_q4 = input.bool(false, "Q4", inline="n", group=g_s2)
s_dec_q1 = input.bool(false, "Dec Q1", inline="gd", group=g_s2), s_dec_q2 = input.bool(false, "Q2", inline="gd", group=g_s2), s_dec_q3 = input.bool(false, "Q3", inline="gd", group=g_s2), s_dec_q4 = input.bool(false, "Q4", inline="gd", group=g_s2)

// --- 4. VISUALS ---
show_equity   = input.bool(true, "Show Strategy Equity Line?", group="4. Visuals")
show_bench    = input.bool(false, "Show Benchmark (B&H) Graph?", group="4. Visuals")
show_lbl      = input.bool(true, "Show Daily Trade Popups", group="4. Visuals")
label_offset  = input.int(0, " > Label Horizontal Offset", minval=-5, maxval=5, step=1, group="4. Visuals")
show_main_tbl = input.bool(true, "Show Main Stats (Right)", group="4. Visuals")

// --- 2. INPUTS (MAXIMUM 38) ---
s01 = input.symbol("NASDAQ:AAPL", "01 AAPL", inline="01"), e01 = input.bool(true, "", inline="01")
s02 = input.symbol("NASDAQ:NVDA", "02 NVDA", inline="02"), e02 = input.bool(true, "", inline="02")
s03 = input.symbol("NASDAQ:GOOGL", "03 GOOGL", inline="03"), e03 = input.bool(true, "", inline="03")
s04 = input.symbol("NASDAQ:AMZN", "04 AMZN", inline="04"), e04 = input.bool(true, "", inline="04")
s05 = input.symbol("NASDAQ:META", "05 META", inline="05"), e05 = input.bool(true, "", inline="05")
s06 = input.symbol("NYSE:TSM", "06 TSM", inline="06"), e06 = input.bool(true, "", inline="06")
s07 = input.symbol("NYSE:LLY", "07 LLY", inline="07"), e07 = input.bool(true, "", inline="07")
s08 = input.symbol("NASDAQ:AVGO", "08 AVGO", inline="08"), e08 = input.bool(true, "", inline="08")
s09 = input.symbol("NASDAQ:TSLA", "09 TSLA", inline="09"), e09 = input.bool(true, "", inline="09")
s10 = input.symbol("NASDAQ:WMT",   "10 WMT",   inline="10"), e10 = input.bool(true, "", inline="10")
s11 = input.symbol("NYSE:MA",  "11 MA",  inline="11"), e11 = input.bool(true, "", inline="11")
s12 = input.symbol("NYSE:ORCL",  "12 ORCL",  inline="12"), e12 = input.bool(true, "", inline="12")
s13 = input.symbol("NASDAQ:ASML", "13 ASML", inline="13"), e13 = input.bool(true, "", inline="13")
s14 = input.symbol("NASDAQ:NFLX", "14 NFLX", inline="14"), e14 = input.bool(true, "", inline="14")
s15 = input.symbol("NASDAQ:AMD", "15 AMD", inline="15"), e15 = input.bool(true, "", inline="15")
s16 = input.symbol("NYSE:GEV",   "16 GEV",   inline="16"), e16 = input.bool(true, "", inline="16")
s17 = input.symbol("NASDAQ:QCOM", "17 QCOM", inline="17"), e17 = input.bool(true, "", inline="17")
s18 = input.symbol("NYSE:NOW", "18 NOW", inline="18"), e18 = input.bool(true, "", inline="18")
s19 = input.symbol("NASDAQ:AMAT", "19 AMAT", inline="19"), e19 = input.bool(true, "", inline="19")
s20 = input.symbol("NASDAQ:INTC", "20 INTC", inline="20"), e20 = input.bool(true, "", inline="20")
s21 = input.symbol("NASDAQ:LRCX", "21 LRCX", inline="21"), e21 = input.bool(true, "", inline="21")
s22 = input.symbol("NASDAQ:MU", "22 MU", inline="22"), e22 = input.bool(true, "", inline="22")
s23 = input.symbol("NASDAQ:SHOP",  "23 SHOP",  inline="23"), e23 = input.bool(true, "", inline="23")
s24 = input.symbol("NASDAQ:PANW", "24 PANW", inline="24"), e24 = input.bool(true, "", inline="24")
s25 = input.symbol("NASDAQ:MELI", "25 MELI", inline="25"), e25 = input.bool(true, "", inline="25")
s26 = input.symbol("NYSE:CMG",    "26 CMG",  inline="26"), e26 = input.bool(true, "", inline="26")
s27 = input.symbol("NASDAQ:PYPL", "27 PYPL", inline="27"), e27 = input.bool(true, "", inline="27")
s28 = input.symbol("NYSE:TGT", "28 TGT", inline="28"), e28 = input.bool(true, "", inline="28")
s29 = input.symbol("NASDAQ:PLTR", "29 PLTR", inline="29"), e29 = input.bool(true, "", inline="29")
s30 = input.symbol("NASDAQ:COIN",  "30 COIN",  inline="30"), e30 = input.bool(true, "", inline="30")
s31 = input.symbol("NASDAQ:MSTR", "31 MSTR", inline="31"), e31 = input.bool(true, "", inline="31")
s32 = input.symbol("NASDAQ:HOOD", "32 HOOD", inline="32"), e32 = input.bool(true, "", inline="32")
s33 = input.symbol("NYSE:NET", "33 NET", inline="33"), e33 = input.bool(true, "", inline="33")
s34 = input.symbol("NASDAQ:MRNA", "34 MRNA", inline="34"), e34 = input.bool(true, "", inline="34")
s35 = input.symbol("NASDAQ:CRSP", "35 CRSP", inline="35"), e35 = input.bool(true, "", inline="35")
s36 = input.symbol("AMEX:SPXL",   "36 SPXL", inline="36"), e36 = input.bool(true, "", inline="36")
s37 = input.symbol("NASDAQ:TQQQ",   "37 TQQQ", inline="37"), e37 = input.bool(true, "", inline="37")
s38 = input.symbol("AMEX:UPRO", "38 UPRO", inline="38"), e38 = input.bool(true, "", inline="38")

// --- 3. DATA FETCHING (INTRADAY & OVERNIGHT LOGIC) ---
get_data_intraday(sym_in, is_active) =>
    req_sym = is_active ? sym_in : "SP:SPX"
    // Fetch: Open today, Close today, Close yesterday, Open yesterday
    [o, c, c_prev, o_prev] = request.security(req_sym, "D", [open, close, close[1], open[1]], lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true)
    valid = is_active and not na(o) and not na(c_prev)
    
    // 1. GAP = Open(today) to Close(yesterday) -> Profit for ON, Criterion for ID
    gap_pct = valid ? ((o - c_prev) / c_prev) : -999.0
    // 2. ID RUN = Close(today) to Open(today) -> Profit for ID
    id_ret  = (valid and o > 0) ? ((c - o) / o) : 0.0
    // 3. PREV ID RUN = Close(yesterday) to Open(yesterday) -> Criterion for ON 
    prev_id_ret = (valid and o_prev > 0) ? ((c_prev - o_prev) / o_prev) : -999.0
    
    [gap_pct, id_ret, prev_id_ret]

[g01, r01, pr01] = get_data_intraday(s01, e01)
[g02, r02, pr02] = get_data_intraday(s02, e02)
[g03, r03, pr03] = get_data_intraday(s03, e03)
[g04, r04, pr04] = get_data_intraday(s04, e04)
[g05, r05, pr05] = get_data_intraday(s05, e05)
[g06, r06, pr06] = get_data_intraday(s06, e06)
[g07, r07, pr07] = get_data_intraday(s07, e07)
[g08, r08, pr08] = get_data_intraday(s08, e08)
[g09, r09, pr09] = get_data_intraday(s09, e09)
[g10, r10, pr10] = get_data_intraday(s10, e10)
[g11, r11, pr11] = get_data_intraday(s11, e11)
[g12, r12, pr12] = get_data_intraday(s12, e12)
[g13, r13, pr13] = get_data_intraday(s13, e13)
[g14, r14, pr14] = get_data_intraday(s14, e14)
[g15, r15, pr15] = get_data_intraday(s15, e15)
[g16, r16, pr16] = get_data_intraday(s16, e16)
[g17, r17, pr17] = get_data_intraday(s17, e17)
[g18, r18, pr18] = get_data_intraday(s18, e18)
[g19, r19, pr19] = get_data_intraday(s19, e19)
[g20, r20, pr20] = get_data_intraday(s20, e20)
[g21, r21, pr21] = get_data_intraday(s21, e21)
[g22, r22, pr22] = get_data_intraday(s22, e22)
[g23, r23, pr23] = get_data_intraday(s23, e23)
[g24, r24, pr24] = get_data_intraday(s24, e24)
[g25, r25, pr25] = get_data_intraday(s25, e25)
[g26, r26, pr26] = get_data_intraday(s26, e26)
[g27, r27, pr27] = get_data_intraday(s27, e27)
[g28, r28, pr28] = get_data_intraday(s28, e28)
[g29, r29, pr29] = get_data_intraday(s29, e29)
[g30, r30, pr30] = get_data_intraday(s30, e30)
[g31, r31, pr31] = get_data_intraday(s31, e31)
[g32, r32, pr32] = get_data_intraday(s32, e32)
[g33, r33, pr33] = get_data_intraday(s33, e33)
[g34, r34, pr34] = get_data_intraday(s34, e34)
[g35, r35, pr35] = get_data_intraday(s35, e35)
[g36, r36, pr36] = get_data_intraday(s36, e36)
[g37, r37, pr37] = get_data_intraday(s37, e37)
[g38, r38, pr38] = get_data_intraday(s38, e38)

// --- GLOBAL BENCHMARK ---
[bench_c_raw, bench_c1_raw] = request.security(filter_sym, "D", [close, close[1]], lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true)
bench_c = bench_c_raw
bench_c1 = bench_c1_raw

gap_arr = array.from(g01, g02, g03, g04, g05, g06, g07, g08, g09, g10, g11, g12, g13, g14, g15, g16, g17, g18, g19, g20, g21, g22, g23, g24, g25, g26, g27, g28, g29, g30, g31, g32, g33, g34, g35, g36, g37, g38)
ret_arr = array.from(r01, r02, r03, r04, r05, r06, r07, r08, r09, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19, r20, r21, r22, r23, r24, r25, r26, r27, r28, r29, r30, r31, r32, r33, r34, r35, r36, r37, r38)
prev_id_arr = array.from(pr01, pr02, pr03, pr04, pr05, pr06, pr07, pr08, pr09, pr10, pr11, pr12, pr13, pr14, pr15, pr16, pr17, pr18, pr19, pr20, pr21, pr22, pr23, pr24, pr25, pr26, pr27, pr28, pr29, pr30, pr31, pr32, pr33, pr34, pr35, pr36, pr37, pr38)
name_arr = array.from(str.tostring(s01), str.tostring(s02), str.tostring(s03), str.tostring(s04), str.tostring(s05), str.tostring(s06), str.tostring(s07), str.tostring(s08), str.tostring(s09), str.tostring(s10), str.tostring(s11), str.tostring(s12), str.tostring(s13), str.tostring(s14), str.tostring(s15), str.tostring(s16), str.tostring(s17), str.tostring(s18), str.tostring(s19), str.tostring(s20), str.tostring(s21), str.tostring(s22), str.tostring(s23), str.tostring(s24), str.tostring(s25), str.tostring(s26), str.tostring(s27), str.tostring(s28), str.tostring(s29), str.tostring(s30), str.tostring(s31), str.tostring(s32), str.tostring(s33), str.tostring(s34), str.tostring(s35), str.tostring(s36), str.tostring(s37), str.tostring(s38))

// --- VARIABLES ---
var float equity = 100.0
var float bh_equity = 100.0 
var int days_up = 0
var int days_down = 0
var int stats_days_total = 0
var float max_dd = 0.0
var float peak_eq = 100.0 
var color graph_col = color.gray

// --- SEASONALITY LOGIC ---
int m = month
int d = dayofmonth
bool is_h2_val = (d > 15)
bool is_q1 = (not is_h2_val) and (d <= 7)
bool is_q2 = (not is_h2_val) and (d > 7)
bool is_q3 = (is_h2_val) and (d <= 22)
bool is_q4 = (is_h2_val) and (d > 22)

bool seas_cond = (m == 1  and ((s_jan_q1 and is_q1) or (s_jan_q2 and is_q2) or (s_jan_q3 and is_q3) or (s_jan_q4 and is_q4))) or (m == 2  and ((s_feb_q1 and is_q1) or (s_feb_q2 and is_q2) or (s_feb_q3 and is_q3) or (s_feb_q4 and is_q4))) or (m == 3  and ((s_mar_q1 and is_q1) or (s_mar_q2 and is_q2) or (s_mar_q3 and is_q3) or (s_mar_q4 and is_q4))) or (m == 4  and ((s_apr_q1 and is_q1) or (s_apr_q2 and is_q2) or (s_apr_q3 and is_q3) or (s_apr_q4 and is_q4))) or (m == 5  and ((s_may_q1 and is_q1) or (s_may_q2 and is_q2) or (s_may_q3 and is_q3) or (s_may_q4 and is_q4))) or (m == 6  and ((s_jun_q1 and is_q1) or (s_jun_q2 and is_q2) or (s_jun_q3 and is_q3) or (s_jun_q4 and is_q4))) or (m == 7  and ((s_jul_q1 and is_q1) or (s_jul_q2 and is_q2) or (s_jul_q3 and is_q3) or (s_jul_q4 and is_q4))) or (m == 8  and ((s_aug_q1 and is_q1) or (s_aug_q2 and is_q2) or (s_aug_q3 and is_q3) or (s_aug_q4 and is_q4))) or (m == 9  and ((s_sep_q1 and is_q1) or (s_sep_q2 and is_q2) or (s_sep_q3 and is_q3) or (s_sep_q4 and is_q4))) or (m == 10 and ((s_oct_q1 and is_q1) or (s_oct_q2 and is_q2) or (s_oct_q3 and is_q3) or (s_oct_q4 and is_q4))) or (m == 11 and ((s_nov_q1 and is_q1) or (s_nov_q2 and is_q2) or (s_nov_q3 and is_q3) or (s_nov_q4 and is_q4))) or (m == 12 and ((s_dec_q1 and is_q1) or (s_dec_q2 and is_q2) or (s_dec_q3 and is_q3) or (s_dec_q4 and is_q4)))

bool is_in_bad_season = use_seasonal and seas_cond
bool is_in_date_range = (year >= start_year) and (year <= end_year)

bgcolor(is_in_bad_season and is_in_date_range ? color.new(color.orange, 85) : na, title="Season Cash")

// =========================================================================================
// CORE ENGINE: INTRADAY & OVERNIGHT GAP ROTATION
// =========================================================================================
bool new_day = ta.change(time("D")) != 0

bool is_fade = gap_mode == "Intraday (Buy Open, Sell Close) - Worst Gaps (Fade)"
bool is_overnight = gap_mode == "Overnight (Buy Close, Sell Open) - Best Intraday Run"

if new_day and is_in_date_range
    stats_days_total += 1
    
    // Benchmark B&H
    float bh_ret = (not na(bench_c) and not na(bench_c1) and bench_c1 != 0) ? ((bench_c / bench_c1) - 1) : 0.0
    bh_equity := bh_equity * (1 + bh_ret)

    float daily_strategy_ret = 0.0
    string tooltip_str = str.tostring(dayofmonth(time), "00") + "." + str.tostring(month(time), "00") + "." + str.tostring(year(time)) + "\n"
    tooltip_str += "[" + gap_mode + "]\n"
    tooltip_str += "Filter: Min Move ≥ " + str.tostring(min_move_pct * 100, "0.0") + "%\n"
    
    if is_in_bad_season
        graph_col := color.orange
        tooltip_str += "🛡️ SEASONAL CASH (No Trades)"
    else
        // 1. Populate sorting array
        float[] sort_arr = array.new_float(universe_lim)
        for i = 0 to universe_lim - 1
            // If Overnight: We sort based on yesterday's Intraday-Action. If Intraday: We sort based on today's Gap.
            float val = is_overnight ? array.get(prev_id_arr, i) : array.get(gap_arr, i)
            float invalid_placeholder = is_fade ? 100000.0 : -100000.0
            array.set(sort_arr, i, na(val) ? invalid_placeholder : val)
            
        int[] sorted_indices = array.sort_indices(sort_arr, is_fade ? order.ascending : order.descending)
        
        // 2. Select Top N, apply Threshold and calculate Performance
        int selected_count = 0
        float sum_pnl_ret = 0.0
        string buys_str = (is_overnight ? "🟡 OVERNIGHT TRADES:\n" : "🟢 INTRADAY TRADES:\n")
        
        for i = 0 to universe_lim - 1
            int idx = array.get(sorted_indices, i)
            
            // Metric used for sorting (for display purposes)
            float metric_val = is_overnight ? array.get(prev_id_arr, idx) : array.get(gap_arr, idx)
            // Actual profit for the chosen timeframe (ON = gap_arr, ID = ret_arr)
            float pnl_val    = is_overnight ? array.get(gap_arr, idx) : array.get(ret_arr, idx)
            
            bool is_valid = not na(metric_val) and metric_val > -900 and metric_val < 900
            
            // THRESHOLD FILTER
            bool passes_threshold = is_fade ? (metric_val <= -(min_move_pct)) : (metric_val >= min_move_pct)
            
            if is_valid and passes_threshold
                sum_pnl_ret += pnl_val
                selected_count += 1
                
                string n_raw = array.get(name_arr, idx)
                string n_cl = str.replace_all(str.replace_all(str.replace_all(n_raw, "NASDAQ:", ""), "NYSE:", ""), "AMEX:", "")
                
                string metric_lbl = is_overnight ? "Prev ID" : "Gap"
                string pnl_lbl    = is_overnight ? "ON P&L" : "ID P&L"
                
                buys_str += "► " + n_cl + " [" + metric_lbl + ": " + (metric_val >= 0 ? "+" : "") + str.tostring(metric_val * 100, "0.0") + "% | " + pnl_lbl + ": " + (pnl_val >= 0 ? "+" : "") + str.tostring(pnl_val * 100, "0.00") + "%]\n"
                
                if selected_count >= top_n
                    break
        
        // 3. Daily Return (Average of selected returns minus 2x costs for entry/exit, IF trades occurred)
        if selected_count > 0
            daily_strategy_ret := (sum_pnl_ret / selected_count) - (cost_pct * 2) 
            tooltip_str += buys_str + "\n∑ Daily Net Return: " + (daily_strategy_ret >= 0 ? "+" : "") + str.tostring(daily_strategy_ret * 100, "0.00") + "%"
            graph_col := daily_strategy_ret >= 0 ? color.green : color.red
            
            if daily_strategy_ret > 0 
                days_up += 1
            else if daily_strategy_ret < 0
                days_down += 1
        else
            graph_col := color.gray
            tooltip_str += "⚠️ NO TARGETS PASSED THRESHOLD (Cash Day)"

    // Update Equity
    equity := equity * (1 + daily_strategy_ret)
    
    // Calculate Drawdown
    peak_eq := math.max(peak_eq, equity)
    float temp_dd = peak_eq > 0 ? ((equity - peak_eq) / peak_eq) : 0.0
    if temp_dd < max_dd
        max_dd := temp_dd

    // Draw Label
    if show_lbl and not is_in_bad_season
        string label_txt = is_overnight ? "ON" : "ID"
        color label_col = is_overnight ? color.new(#FFD700, 50) : color.new(color.blue, 70)
        label.new(bar_index + label_offset, equity, text=label_txt, tooltip=tooltip_str, color=label_col, style=label.style_label_down, textcolor=is_overnight ? color.black : color.white, size=size.small)

// Plots
plot(show_equity and is_in_date_range ? equity : na, "Strategy", color=graph_col, linewidth=2)
plot(is_in_date_range and show_bench ? bh_equity : na, "Benchmark", color=color.gray)

// =========================================================================================
// UI: MAIN STATS TABLE
// =========================================================================================
if barstate.islast and show_main_tbl
    var table t_comb = table.new(position.middle_right, 2, 8, border_width=1, bgcolor=color.new(color.black, 85))
    
    string tbl_title = is_overnight ? "OVERNIGHT STRATEGY" : "INTRADAY STRATEGY"
    color title_col = is_overnight ? color.new(#B8860B, 50) : color.new(color.blue, 50)
    
    table.cell(t_comb, 0, 0, tbl_title, bgcolor=title_col, text_color=color.white, text_size=size.small)
    table.merge_cells(t_comb, 0, 0, 1, 0)
    
    table.cell(t_comb, 0, 1, "Total Return", text_color=color.white, text_size=size.small)
    table.cell(t_comb, 1, 1, str.tostring((equity/100), "0.00") + "x", text_color=equity >= 100 ? color.green : color.red, text_size=size.small)
    
    float yrs = (time - timestamp(start_year, 1, 1, 0, 0)) / (1000 * 60 * 60 * 24 * 365.25)
    float cagr = yrs > 0 ? math.pow(equity/100, 1/yrs) - 1 : 0.0
    float b_cagr = yrs > 0 ? math.pow(bh_equity/100, 1/yrs) - 1 : 0.0
    
    table.cell(t_comb, 0, 2, "CAGR (Net)", text_color=color.white, text_size=size.small)
    table.cell(t_comb, 1, 2, str.tostring(cagr*100, "0.00") + "%", text_color=cagr >= 0 ? color.green : color.red, text_size=size.small)
    
    table.cell(t_comb, 0, 3, "Max Drawdown", text_color=color.white, text_size=size.small)
    table.cell(t_comb, 1, 3, str.tostring(max_dd*100, "0.00") + "%", text_color=color.red, text_size=size.small)
    
    int total_active_days = days_up + days_down
    float win_rate = total_active_days > 0 ? (days_up / total_active_days) * 100 : 0.0
    
    table.cell(t_comb, 0, 4, "Trade Win Rate", text_color=color.white, text_size=size.small)
    table.cell(t_comb, 1, 4, str.tostring(win_rate, "0.00") + "%", text_color=win_rate >= 50 ? color.green : color.orange, text_size=size.small)
    
    table.cell(t_comb, 0, 5, "B&H CAGR (Bench)", text_color=color.white, text_size=size.small)
    table.cell(t_comb, 1, 5, str.tostring(b_cagr*100, "0.00") + "%", text_color=color.gray, text_size=size.small)
    
    table.cell(t_comb, 0, 6, "Total Active Days", text_color=color.white, text_size=size.small)
    table.cell(t_comb, 1, 6, str.tostring(total_active_days), text_color=color.white, text_size=size.small)
````

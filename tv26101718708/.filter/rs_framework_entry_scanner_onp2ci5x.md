# RS Framework Entry Scanner

- url: https://www.tradingview.com/script/Onp2Ci5x-RS-Framework-Entry-Scanner/
- type: indicator
- pine_id: PUB;99001a5514974ad190f9356fe9e00ae0
- version: 1.0

## Description

This script is an advanced trading strategy for TradingView using relative strength (RS) analysis and traditional technical indicators. It's designed to identify high-probability long and short entry points on the daily chart for swing trades lasting 5-15 days.

Key features and usage guide:

1. Relative Strength (RS) Scoring:
- Computes 3-month and 6-month RS vs a benchmark (default: RSP ETF)
- Stock gets +1 for each of: 3M RS > 0, 6M RS > 0
- Background color shows current RS regime

2. Technical Indicator Scoring:
- Stock gets +1 for each of:
  - Price above 200 SMA (structural uptrend) 
  - MACD histogram > 0 (momentum)
  - RSI between 40-75 (healthy, not overbought/oversold)
- Uses standard moving averages (200, 50, 20 EMA)

3. Entry Triggers:
- Looks for any of these patterns:
  - EMA pullback: Price near the 20 EMA
  - MACD cross: MACD histogram crossing 0 with volume 
  - Breakout: New high/low on increased volume
- Long entry: RS score ≥ 4/5 ("A" grade) + bullish trigger
- Short entry: RS score ≥ 4/5 ("A" grade) + bearish trigger
- Triangles mark entries, small circles show qualifying RS setups

4. Score Table:
- Summarizes current RS metrics, indicator scores, active triggers
- Color-codes pass/fail status for each factor 
- Displays overall long/short scores, RS trend, trigger labels

To use in your trading:

1. Add the script to a daily chart of a stock or ETF
2. Adjust the benchmark symbol if needed (default: RSP)
3. Review the background color for overall RS regime 
4. Check table for current RS metrics and setup grade
5. Look for large triangle entries with a qualifying score
6. Confirm volume and price action aligns with the signal
7. Place trade in direction of entry with 5-15 day horizon
8. Trail stop above/below relevant swing point or moving average
9. Consider taking partial profits at measured move targets

The script aims to put the odds in your favor by requiring multiple technical and relative strength factors to line up before giving an entry signal.

## Source Code

````pine
//@version=6
// RS Framework Entry Scanner
// Scores each ticker 0-5 on both long and short sides:
//   1. 3M RS vs RSP > 0   (outperforming benchmark)
//   2. 6M RS vs RSP > 0   (durable outperformance)
//   3. Price above 200 SMA (structural uptrend)
//   4. MACD histogram > 0  (momentum confirmation)
//   5. RSI 40-75           (healthy, not overbought)
// Entry triggers: EMA pullback, MACD cross, or breakout with volume
// Designed for: daily chart, swing trades (5-15 days)

indicator("RS Framework Entry Scanner", shorttitle="RS Entry", overlay=true, max_labels_count=50)

// --- INPUTS ---
grp_rs    = "Relative Strength"
grp_tech  = "Technicals"
grp_entry = "Entry Signals"
grp_disp  = "Display"

i_benchmark  = input.symbol("RSP",  "Benchmark Symbol",            group=grp_rs)
i_rs3m       = input.int(63,         "3M Lookback (trading days)",  group=grp_rs, minval=20, maxval=200)
i_rs6m       = input.int(126,        "6M Lookback (trading days)",  group=grp_rs, minval=40, maxval=400)

i_sma_long   = input.int(200, "Long SMA",     group=grp_tech, minval=50)
i_sma_mid    = input.int(50,  "Mid SMA",      group=grp_tech, minval=10)
i_ema_fast   = input.int(20,  "Fast EMA",     group=grp_tech, minval=5)
i_macd_fast  = input.int(12,  "MACD Fast",    group=grp_tech)
i_macd_slow  = input.int(26,  "MACD Slow",    group=grp_tech)
i_macd_sig   = input.int(9,   "MACD Signal",  group=grp_tech)
i_rsi_len    = input.int(14,  "RSI Length",   group=grp_tech)

i_min_long   = input.int(4,   "Min Score - Long  (0-5)", group=grp_entry, minval=0, maxval=5)
i_min_short  = input.int(4,   "Min Score - Short (0-5)", group=grp_entry, minval=0, maxval=5)
i_ema_tol    = input.float(2.0, "EMA Pullback Tolerance %", group=grp_entry, minval=0.5, maxval=8.0, step=0.5)
i_swing_bars = input.int(10,  "Swing High/Low Lookback", group=grp_entry, minval=3, maxval=30)
i_vol_mult   = input.float(1.2, "Volume Confirm (x avg)", group=grp_entry, minval=1.0, maxval=5.0, step=0.1)

i_show_sma200 = input.bool(true, "Show 200 SMA",    group=grp_disp)
i_show_sma50  = input.bool(true, "Show 50 SMA",     group=grp_disp)
i_show_ema20  = input.bool(true, "Show 20 EMA",     group=grp_disp)
i_show_bg     = input.bool(true, "Show RS Background", group=grp_disp)
i_show_table  = input.bool(true, "Show Score Table", group=grp_disp)

// --- BENCHMARK ---
bm           = request.security(i_benchmark, timeframe.period, close, lookahead=barmerge.lookahead_off)
bm_3m_ago    = request.security(i_benchmark, timeframe.period, close[i_rs3m], lookahead=barmerge.lookahead_off)
bm_6m_ago    = request.security(i_benchmark, timeframe.period, close[i_rs6m], lookahead=barmerge.lookahead_off)

// --- RELATIVE STRENGTH ---
stk_3m_ago = close[i_rs3m]
stk_6m_ago = close[i_rs6m]

stk_ret3m = stk_3m_ago != 0 ? (close - stk_3m_ago) / stk_3m_ago * 100 : na
stk_ret6m = stk_6m_ago != 0 ? (close - stk_6m_ago) / stk_6m_ago * 100 : na
bm_ret3m  = bm_3m_ago  != 0 ? (bm   - bm_3m_ago)  / bm_3m_ago  * 100 : na
bm_ret6m  = bm_6m_ago  != 0 ? (bm   - bm_6m_ago)  / bm_6m_ago  * 100 : na

rs_3m = not na(stk_ret3m) and not na(bm_ret3m) ? stk_ret3m - bm_ret3m : na
rs_6m = not na(stk_ret6m) and not na(bm_ret6m) ? stk_ret6m - bm_ret6m : na

rs_trend_up = not na(rs_3m) and not na(rs_3m[10]) and rs_3m > rs_3m[10]

// --- TECHNICALS ---
sma200 = ta.sma(close, i_sma_long)
sma50  = ta.sma(close, i_sma_mid)
ema20  = ta.ema(close, i_ema_fast)
[macdLine, sigLine, macdHist] = ta.macd(close, i_macd_fast, i_macd_slow, i_macd_sig)
rsi    = ta.rsi(close, i_rsi_len)
vol_avg = ta.sma(volume, 20)

// --- LONG SCORE (0-5) ---
l1 = not na(rs_3m)  and rs_3m > 0
l2 = not na(rs_6m)  and rs_6m > 0
l3 = not na(sma200) and close > sma200
l4 = macdHist > 0
l5 = rsi > 40 and rsi < 75

long_score = (l1 ? 1 : 0) + (l2 ? 1 : 0) + (l3 ? 1 : 0) + (l4 ? 1 : 0) + (l5 ? 1 : 0)

// --- SHORT SCORE (0-5) ---
s1 = not na(rs_3m)  and rs_3m < 0
s2 = not na(rs_6m)  and rs_6m < 0
s3 = not na(sma200) and close < sma200
s4 = macdHist < 0
s5 = rsi < 60 and rsi > 25

short_score = (s1 ? 1 : 0) + (s2 ? 1 : 0) + (s3 ? 1 : 0) + (s4 ? 1 : 0) + (s5 ? 1 : 0)

// --- ENTRY TIMING ---
vol_ok       = volume > vol_avg * i_vol_mult
swing_high   = ta.highest(high[1], i_swing_bars)
swing_low    = ta.lowest(low[1],   i_swing_bars)

trig_pull_long   = close >= ema20 * (1 - i_ema_tol / 100) and close <= ema20 * (1 + i_ema_tol / 100) and close > sma50
trig_macd_long   = ta.crossover(macdHist, 0) and vol_ok
trig_break_long  = close > swing_high and vol_ok

trig_pull_short  = close >= ema20 * (1 - i_ema_tol / 100) and close <= ema20 * (1 + i_ema_tol / 100) and close < sma50
trig_macd_short  = ta.crossunder(macdHist, 0) and vol_ok
trig_break_short = close < swing_low and vol_ok

any_long_trig  = trig_pull_long  or trig_macd_long  or trig_break_long
any_short_trig = trig_pull_short or trig_macd_short or trig_break_short

long_signal  = long_score  >= i_min_long  and any_long_trig
short_signal = short_score >= i_min_short and any_short_trig

fresh_long_score  = long_score  >= i_min_long  and long_score[1]  < i_min_long
fresh_short_score = short_score >= i_min_short and short_score[1] < i_min_short

// Background color helper (function avoids multi-line ternary issues)
f_rs_bg(show, rs) =>
    color result = na
    if show and not na(rs)
        if rs > 10
            result := color.rgb(0, 200, 100, 90)
        else if rs > 0
            result := color.rgb(0, 200, 100, 95)
        else if rs < -10
            result := color.rgb(255, 50, 50, 88)
        else if rs < 0
            result := color.rgb(255, 50, 50, 94)
    result
plot(i_show_sma200 ? sma200 : na, "200 SMA", color=color.rgb(255, 200, 50, 25),  linewidth=2)
plot(i_show_sma50  ? sma50  : na, "50 SMA",  color=color.rgb(100, 180, 255, 45), linewidth=1)
plot(i_show_ema20  ? ema20  : na, "20 EMA",  color=color.rgb(200, 150, 255, 45), linewidth=1)

// --- BACKGROUND ---
rs_bg_color = f_rs_bg(i_show_bg, rs_3m)
bgcolor(rs_bg_color, title="RS Regime")

// --- SIGNAL SHAPES ---
plotshape(long_signal  and not short_signal, "Long Entry",
    shape.triangleup,   location.belowbar, color.rgb(0, 220, 100), size=size.normal)
plotshape(short_signal and not long_signal,  "Short Entry",
    shape.triangledown, location.abovebar, color.rgb(255, 60, 60),  size=size.normal)

plotshape(fresh_long_score  and not long_signal,  "Long Setup Forming",
    shape.circle, location.belowbar, color.rgb(0, 180, 100, 40), size=size.tiny)
plotshape(fresh_short_score and not short_signal, "Short Setup Forming",
    shape.circle, location.abovebar, color.rgb(255, 80, 80, 40),  size=size.tiny)

// --- ENTRY TRIGGER LABELS ---
trig_lbl_long  = trig_pull_long  ? "EMA Pull" : trig_macd_long  ? "MACD X" : trig_break_long  ? "BO" : ""
trig_lbl_short = trig_pull_short ? "EMA Bnc"  : trig_macd_short ? "MACD X" : trig_break_short ? "BD" : ""

if long_signal and not short_signal
    label.new(bar_index, low, trig_lbl_long,
        style=label.style_label_up, color=color.rgb(0, 160, 70),
        textcolor=color.white, size=size.tiny, yloc=yloc.belowbar)

if short_signal and not long_signal
    label.new(bar_index, high, trig_lbl_short,
        style=label.style_label_down, color=color.rgb(190, 40, 40),
        textcolor=color.white, size=size.tiny, yloc=yloc.abovebar)

// --- SCORE TABLE ---
if i_show_table and barstate.islast
    var tbl = table.new(position.top_right, 2, 14,
        bgcolor=color.rgb(8, 10, 22, 5),
        border_color=color.rgb(30, 35, 65), border_width=1,
        frame_color=color.rgb(232, 200, 74), frame_width=1)

    c_gold  = color.rgb(232, 200, 74)
    c_green = color.rgb(0, 220, 120)
    c_red   = color.rgb(255, 70, 70)
    c_dim   = color.rgb(90, 105, 140)
    c_text  = color.rgb(175, 185, 210)
    c_bg0   = color.rgb(8, 10, 22, 5)
    c_bg1   = color.rgb(14, 17, 35, 5)
    c_bg_g  = color.rgb(0, 60, 30, 15)
    c_bg_r  = color.rgb(60, 0, 0, 15)
    l_bg    = long_score  >= i_min_long  ? c_bg_g : c_bg0
    s_bg    = short_score >= i_min_short ? c_bg_r : c_bg0

    // Header
    table.cell(tbl, 0, 0, "RS FRAMEWORK",
        text_color=color.rgb(0,0,0), bgcolor=c_gold,
        text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 0, "STATUS",
        text_color=color.rgb(0,0,0), bgcolor=c_gold,
        text_size=size.small, text_halign=text.align_center)

    // RS values
    rs3_str = not na(rs_3m) ? (rs_3m >= 0 ? "+" : "") + str.tostring(math.round(rs_3m, 1)) + "%" : "n/a"
    rs6_str = not na(rs_6m) ? (rs_6m >= 0 ? "+" : "") + str.tostring(math.round(rs_6m, 1)) + "%" : "n/a"
    rs3_col = not na(rs_3m) ? (rs_3m > 0 ? c_green : c_red) : c_dim
    rs6_col = not na(rs_6m) ? (rs_6m > 0 ? c_green : c_red) : c_dim

    table.cell(tbl, 0, 1, "3M RS vs RSP", text_color=c_text, bgcolor=c_bg1, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 1, rs3_str, text_color=rs3_col, bgcolor=c_bg1, text_size=size.tiny)
    table.cell(tbl, 0, 2, "6M RS vs RSP", text_color=c_text, bgcolor=c_bg1, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 2, rs6_str, text_color=rs6_col, bgcolor=c_bg1, text_size=size.tiny)

    // Long factors header
    table.cell(tbl, 0, 3, "-- LONG FACTORS --", text_color=c_dim, bgcolor=c_bg0, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 3, "", bgcolor=c_bg0, text_size=size.tiny)

    // Long factor rows
    table.cell(tbl, 0, 4, "3M RS > 0",     text_color=c_text, bgcolor=l_bg, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 4, l1 ? "Y" : "N",  text_color=l1 ? c_green : c_red, bgcolor=l_bg, text_size=size.tiny, text_halign=text.align_center)
    table.cell(tbl, 0, 5, "6M RS > 0",     text_color=c_text, bgcolor=l_bg, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 5, l2 ? "Y" : "N",  text_color=l2 ? c_green : c_red, bgcolor=l_bg, text_size=size.tiny, text_halign=text.align_center)
    table.cell(tbl, 0, 6, ">200 SMA",      text_color=c_text, bgcolor=l_bg, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 6, l3 ? "Y" : "N",  text_color=l3 ? c_green : c_red, bgcolor=l_bg, text_size=size.tiny, text_halign=text.align_center)
    table.cell(tbl, 0, 7, "MACD > 0",      text_color=c_text, bgcolor=l_bg, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 7, l4 ? "Y" : "N",  text_color=l4 ? c_green : c_red, bgcolor=l_bg, text_size=size.tiny, text_halign=text.align_center)
    table.cell(tbl, 0, 8, "RSI 40-75",     text_color=c_text, bgcolor=l_bg, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 8, l5 ? "Y" : "N",  text_color=l5 ? c_green : c_red, bgcolor=l_bg, text_size=size.tiny, text_halign=text.align_center)

    // Long score
    l_tier = long_score == 5 ? "A+" : long_score == 4 ? "A" : long_score == 3 ? "B" : "--"
    l_col  = long_score >= 4 ? c_green : long_score == 3 ? c_gold : c_dim
    table.cell(tbl, 0, 9, "LONG " + str.tostring(long_score) + "/5  " + l_tier,
        text_color=l_col, bgcolor=l_bg, text_size=size.small,
        text_halign=text.align_left)
    table.cell(tbl, 1, 9, any_long_trig ? "ENTRY" : "wait",
        text_color=any_long_trig and long_score >= i_min_long ? c_green : c_dim,
        bgcolor=l_bg, text_size=size.tiny, text_halign=text.align_center)

    // Short score
    s_tier = short_score == 5 ? "A+" : short_score == 4 ? "A" : short_score == 3 ? "B" : "--"
    s_col  = short_score >= 4 ? c_red : short_score == 3 ? c_gold : c_dim
    table.cell(tbl, 0, 10, "SHORT " + str.tostring(short_score) + "/5  " + s_tier,
        text_color=s_col, bgcolor=s_bg, text_size=size.small,
        text_halign=text.align_left)
    table.cell(tbl, 1, 10, any_short_trig ? "ENTRY" : "wait",
        text_color=any_short_trig and short_score >= i_min_short ? c_red : c_dim,
        bgcolor=s_bg, text_size=size.tiny, text_halign=text.align_center)

    // RSI / MACD snapshot
    rsi_str  = "RSI " + str.tostring(math.round(rsi, 1))
    macd_str = "MACD " + (macdHist >= 0 ? "+" : "") + str.tostring(math.round(macdHist, 3))
    table.cell(tbl, 0, 11, rsi_str, text_color=c_dim, bgcolor=c_bg0, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 11, macd_str, text_color=c_dim, bgcolor=c_bg0, text_size=size.tiny, text_halign=text.align_center)

    // RS trend
    table.cell(tbl, 0, 12, "RS Trend", text_color=c_dim, bgcolor=c_bg0, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 12, rs_trend_up ? "Rising" : "Falling",
        text_color=rs_trend_up ? c_green : c_red, bgcolor=c_bg0, text_size=size.tiny, text_halign=text.align_center)

    // Entry trigger active
    lbl_trig = any_long_trig ? trig_lbl_long : any_short_trig ? trig_lbl_short : "none"
    table.cell(tbl, 0, 13, "Trigger", text_color=c_dim, bgcolor=c_bg0, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 13, lbl_trig,
        text_color=(any_long_trig or any_short_trig) ? c_gold : c_dim,
        bgcolor=c_bg0, text_size=size.tiny, text_halign=text.align_center)

// --- ALERTS ---
alertcondition(long_signal,  "Long Entry",  "RS Framework: Long entry triggered. Score OK + trigger fired.")
alertcondition(short_signal, "Short Entry", "RS Framework: Short entry triggered. Score OK + trigger fired.")
alertcondition(fresh_long_score  and not long_signal, "Long Setup Forming",  "RS Framework: Long score threshold reached. Watching for trigger.")
alertcondition(fresh_short_score and not short_signal, "Short Setup Forming", "RS Framework: Short score threshold reached. Watching for trigger.")
alertcondition(trig_macd_long  and long_score  >= i_min_long,  "Long MACD Cross",  "RS Framework: MACD bullish cross with qualifying long score.")
alertcondition(trig_macd_short and short_score >= i_min_short, "Short MACD Cross", "RS Framework: MACD bearish cross with qualifying short score.")
````

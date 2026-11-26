# LiquidityEdge Bias v1.0  |  MTF Trend + Stoch RSI

- url: https://www.tradingview.com/script/vIP9IOru-LiquidityEdge-Bias-v1-0-MTF-Trend-Stoch-RSI/
- type: indicator
- pine_id: PUB;f3732e8cd0ad4e6586501873c191df30
- version: 1.0

## Description

LiquidityEdge Bias — Feature List
LiquidityEdge Bias is a companion indicator designed to run alongside LE Pro. It adds multi-timeframe trend and momentum context without adding load time to the main indicator.
Multi-Timeframe Trend (5 Timeframes)
Tracks the trend direction on 5m, 15m, 30m, 1h, and 4h using EMA21 as the institutional baseline. Each timeframe gets its own color-coded row — green for bullish, red for bearish, gray for neutral. A summary row shows overall bias (e.g. ▲ Mostly Bull 4/5).
Stochastic RSI (5 Timeframes)
Shows Stoch RSI readings on the same 5 timeframes. Overbought and oversold conditions are color-highlighted so you can see at a glance which timeframes are extended and likely to reverse.
Divergence Detection
Bull divergence fires when price makes a lower low but Stoch RSI makes a higher low near oversold — the momentum is turning before price confirms. Bear divergence fires on the opposite. Divergence on any timeframe shows as ★ BULL DIV or ★ BEAR DIV in the dashboard with a brightened cell color.
Dashboard
Matches LE Pro's style exactly — dark theme, same fonts and sizing. Designed to sit alongside LE Pro's dashboard without cluttering your chart.
How to use them together: LE Pro fires the signal. LE Bias tells you whether the higher timeframe trend and momentum support taking it. A 4/5 or 5/5 bull bias on LE Bias when LE Pro fires a LONG at 5/5 score is the highest conviction setup the system produces.

## Source Code

````pine

//@version=6
// ══════════════════════════════════════════════════════════════════════
//   LiquidityEdge Bias  v1.0
//   © CoryM76 — All Rights Reserved
//   Published as Invite-Only on TradingView
//
//   Companion indicator to LiquidityEdge Pro — LiquidityEdge Suite.
//   Shows MTF trend (5 timeframes) and Stoch RSI (5 timeframes) with
//   bullish and bearish divergence detection on all timeframes.
//
//   Features:
//   • MTF trend — 5 configurable timeframes, individual color rows
//   • Stoch RSI — 5 configurable timeframes (default 5m/15m/30m/1h/4h)
//   • Divergence detection — bull/bear on all 5 Stoch RSI timeframes
//   • Dashboard matches LiquidityEdge Pro style exactly
//
//   ── Changelog ────────────────────────────────────────────────────
//   v1.0  Initial release — split and upgraded from LE Pro
// ══════════════════════════════════════════════════════════════════════
indicator("LiquidityEdge Bias v1.0  |  MTF Trend + Stoch RSI", shorttitle="LE Bias", overlay=true)

// ══════════════════════════════════════════════════════════════════════
// SETTINGS
// ══════════════════════════════════════════════════════════════════════
G_MTF  = "MTF Trend"
G_SRSI = "Stoch RSI"
G_DIV  = "Divergence"
G_DASH = "Dashboard"

// ── MTF Trend ─────────────────────────────────────────────────────────
I_MTF_METHOD = input.string("EMA21", "Trend method", options=["EMA21","20 SMA"], group=G_MTF)
I_MTF_TF1    = input.string("5",    "TF 1", options=["1","2","5","10","15","30","60","240"], group=G_MTF)
I_MTF_TF2    = input.string("15",   "TF 2", options=["1","2","5","10","15","30","60","240"], group=G_MTF)
I_MTF_TF3    = input.string("30",   "TF 3", options=["1","2","5","10","15","30","60","240"], group=G_MTF)
I_MTF_TF4    = input.string("60",   "TF 4", options=["1","2","5","10","15","30","60","240"], group=G_MTF)
I_MTF_TF5    = input.string("240",  "TF 5", options=["1","2","5","10","15","30","60","240"], group=G_MTF)

// ── Stoch RSI ─────────────────────────────────────────────────────────
I_SRSI_RSI_LEN   = input.int(14,  "RSI Length",    minval=1, group=G_SRSI)
I_SRSI_STOCH_LEN = input.int(14,  "Stoch Length",  minval=1, group=G_SRSI)
I_SRSI_SIG_LEN   = input.int(3,   "Signal Length", minval=1, group=G_SRSI)
I_SRSI_OB        = input.int(80,  "Overbought",    minval=50, maxval=99, group=G_SRSI)
I_SRSI_OS        = input.int(20,  "Oversold",      minval=1,  maxval=50, group=G_SRSI)
I_SRSI_TF1       = input.string("5",   "TF 1", options=["1","2","5","10","15","30","60","240"], group=G_SRSI)
I_SRSI_TF2       = input.string("15",  "TF 2", options=["1","2","5","10","15","30","60","240"], group=G_SRSI)
I_SRSI_TF3       = input.string("30",  "TF 3", options=["1","2","5","10","15","30","60","240"], group=G_SRSI)
I_SRSI_TF4       = input.string("60",  "TF 4", options=["1","2","5","10","15","30","60","240"], group=G_SRSI)
I_SRSI_TF5       = input.string("240", "TF 5", options=["1","2","5","10","15","30","60","240"], group=G_SRSI)

// ── Divergence ────────────────────────────────────────────────────────
I_DIV_ON      = input.bool(true, "Show divergence detection",    group=G_DIV)
I_DIV_LOOKBACK = input.int(5,   "Pivot lookback (bars)",  minval=2, maxval=10, group=G_DIV)

// ── Dashboard ─────────────────────────────────────────────────────────
I_DSH_POS = input.string("Top Right", "Position",
     options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=G_DASH)

// ══════════════════════════════════════════════════════════════════════
// MTF TREND — 5 request.security calls
// ══════════════════════════════════════════════════════════════════════
f_mtf_trend(string tf) =>
    [htf_c, htf_ema, htf_sma] = request.security(syminfo.tickerid, tf,
         [close, ta.ema(close, 21), ta.sma(close, 20)],
         lookahead=barmerge.lookahead_on)
    float ref = I_MTF_METHOD == "EMA21" ? htf_ema : htf_sma
    na(ref) or na(htf_c) ? 0 : htf_c > ref ? 1 : -1

var int mtf1 = 0
var int mtf2 = 0
var int mtf3 = 0
var int mtf4 = 0
var int mtf5 = 0
mtf1 := f_mtf_trend(I_MTF_TF1)
mtf2 := f_mtf_trend(I_MTF_TF2)
mtf3 := f_mtf_trend(I_MTF_TF3)
mtf4 := f_mtf_trend(I_MTF_TF4)
mtf5 := f_mtf_trend(I_MTF_TF5)

// ══════════════════════════════════════════════════════════════════════
// STOCH RSI HTF — 5 request.security calls
// ══════════════════════════════════════════════════════════════════════
f_srsi_htf(string tf) =>
    float htf_k = request.security(syminfo.tickerid, tf,
         ta.sma(
           ta.highest(ta.rsi(close, I_SRSI_RSI_LEN), I_SRSI_STOCH_LEN) !=
           ta.lowest(ta.rsi(close, I_SRSI_RSI_LEN), I_SRSI_STOCH_LEN) ?
           100.0 * (ta.rsi(close, I_SRSI_RSI_LEN) - ta.lowest(ta.rsi(close, I_SRSI_RSI_LEN), I_SRSI_STOCH_LEN)) /
           (ta.highest(ta.rsi(close, I_SRSI_RSI_LEN), I_SRSI_STOCH_LEN) - ta.lowest(ta.rsi(close, I_SRSI_RSI_LEN), I_SRSI_STOCH_LEN)) : 50.0,
         I_SRSI_SIG_LEN),
         lookahead=barmerge.lookahead_on)
    na(htf_k) ? 50.0 : htf_k

var float s1 = 50.0
var float s2 = 50.0
var float s3 = 50.0
var float s4 = 50.0
var float s5 = 50.0
s1 := f_srsi_htf(I_SRSI_TF1)
s2 := f_srsi_htf(I_SRSI_TF2)
s3 := f_srsi_htf(I_SRSI_TF3)
s4 := f_srsi_htf(I_SRSI_TF4)
s5 := f_srsi_htf(I_SRSI_TF5)

// ══════════════════════════════════════════════════════════════════════
// DIVERGENCE DETECTION
// Bull div: price lower low, Stoch RSI higher low (momentum improving)
// Bear div: price higher high, Stoch RSI lower high (momentum weakening)
// Uses pivot detection with configurable lookback
// ══════════════════════════════════════════════════════════════════════
f_bull_div(float srsi_k, string tf) =>
    // Get HTF price and Stoch RSI pivot lows
    float htf_low  = request.security(syminfo.tickerid, tf, low,  lookahead=barmerge.lookahead_on)
    float htf_k    = srsi_k
    // Pivot low on price = local minimum
    bool price_pivot_lo  = htf_low  == ta.lowest(htf_low,  I_DIV_LOOKBACK * 2 + 1)
    // Previous pivot low
    float prev_price_lo  = ta.valuewhen(price_pivot_lo, htf_low, 1)
    float prev_srsi_lo   = ta.valuewhen(price_pivot_lo, htf_k, 1)
    // Bull div: price made lower low but Stoch RSI made higher low
    price_pivot_lo and htf_low < prev_price_lo and htf_k > prev_srsi_lo and htf_k <= I_SRSI_OS + 20

f_bear_div(float srsi_k, string tf) =>
    // Get HTF price and Stoch RSI pivot highs
    float htf_high = request.security(syminfo.tickerid, tf, high, lookahead=barmerge.lookahead_on)
    float htf_k    = srsi_k
    // Pivot high on price = local maximum
    bool price_pivot_hi  = htf_high == ta.highest(htf_high, I_DIV_LOOKBACK * 2 + 1)
    // Previous pivot high
    float prev_price_hi  = ta.valuewhen(price_pivot_hi, htf_high, 1)
    float prev_srsi_hi   = ta.valuewhen(price_pivot_hi, htf_k, 1)
    // Bear div: price made higher high but Stoch RSI made lower high
    price_pivot_hi and htf_high > prev_price_hi and htf_k < prev_srsi_hi and htf_k >= I_SRSI_OB - 20

// Calculate divergence for each TF
bool bull_div1 = I_DIV_ON and f_bull_div(s1, I_SRSI_TF1)
bool bear_div1 = I_DIV_ON and f_bear_div(s1, I_SRSI_TF1)
bool bull_div2 = I_DIV_ON and f_bull_div(s2, I_SRSI_TF2)
bool bear_div2 = I_DIV_ON and f_bear_div(s2, I_SRSI_TF2)
bool bull_div3 = I_DIV_ON and f_bull_div(s3, I_SRSI_TF3)
bool bear_div3 = I_DIV_ON and f_bear_div(s3, I_SRSI_TF3)
bool bull_div4 = I_DIV_ON and f_bull_div(s4, I_SRSI_TF4)
bool bear_div4 = I_DIV_ON and f_bear_div(s4, I_SRSI_TF4)
bool bull_div5 = I_DIV_ON and f_bull_div(s5, I_SRSI_TF5)
bool bear_div5 = I_DIV_ON and f_bear_div(s5, I_SRSI_TF5)

// ══════════════════════════════════════════════════════════════════════
// DISPLAY HELPERS
// ══════════════════════════════════════════════════════════════════════
f_tf_disp(string t) => t == "60" ? "1h" : t == "240" ? "4h" : t + "m"
f_mtf_col(int v) => v == 1 ? color.new(#26A69A,35) : v == -1 ? color.new(#EF5350,35) : color.new(#444444,55)
f_mtf_lbl(int v) => v == 1 ? "▲  Bullish" : v == -1 ? "▼  Bearish" : "—  Neutral"

f_srsi_txt(float k, bool bull_d, bool bear_d) =>
    string base    = k >= I_SRSI_OB ? "OVERBOUGHT  " + str.tostring(math.round(k)) : k <= I_SRSI_OS ? "OVERSOLD  " + str.tostring(math.round(k)) : "Neutral  " + str.tostring(math.round(k))
    string div_tag = bull_d ? "  ★ BULL DIV" : bear_d ? "  ★ BEAR DIV" : ""
    base + div_tag

f_srsi_col(float k, bool bull_d, bool bear_d) => bull_d ? color.new(#26A69A, 20) : bear_d ? color.new(#EF5350, 20) : k >= I_SRSI_OB ? color.new(#EF5350, 40) : k <= I_SRSI_OS ? color.new(#26A69A, 40) : color.new(#444444, 40)

// ══════════════════════════════════════════════════════════════════════
// DASHBOARD — matches LiquidityEdge Pro style exactly
// ══════════════════════════════════════════════════════════════════════
var table dash = na
if barstate.islast
    table.delete(dash)
    bool is_tr = I_DSH_POS == "Top Right"
    bool is_tl = I_DSH_POS == "Top Left"
    bool is_br = I_DSH_POS == "Bottom Right"
    dash := is_tr ? table.new(position.top_right,    2, 12, bgcolor=color.new(#1A1A2E,10), border_color=color.new(#444466,60), border_width=1, frame_color=color.new(#8888AA,40), frame_width=1) : is_tl ? table.new(position.top_left,     2, 12, bgcolor=color.new(#1A1A2E,10), border_color=color.new(#444466,60), border_width=1, frame_color=color.new(#8888AA,40), frame_width=1) : is_br ? table.new(position.bottom_right, 2, 12, bgcolor=color.new(#1A1A2E,10), border_color=color.new(#444466,60), border_width=1, frame_color=color.new(#8888AA,40), frame_width=1) : table.new(position.bottom_left,  2, 12, bgcolor=color.new(#1A1A2E,10), border_color=color.new(#444466,60), border_width=1, frame_color=color.new(#8888AA,40), frame_width=1)

    // Header
    table.cell(dash, 0, 0, "LiquidityEdge Bias", text_color=#8888AA, text_size=size.small, text_halign=text.align_left, bgcolor=color.new(#0D0D1A,10))
    table.cell(dash, 1, 0, "v1.0",               text_color=#8888AA, text_size=size.small, bgcolor=color.new(#0D0D1A,10))

    // MTF Trend rows
    table.cell(dash, 0, 1, "MTF  " + f_tf_disp(I_MTF_TF1), text_color=#AAAACC, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, f_mtf_lbl(mtf1), text_color=color.white, text_size=size.small, bgcolor=f_mtf_col(mtf1))
    table.cell(dash, 0, 2, "MTF  " + f_tf_disp(I_MTF_TF2), text_color=#AAAACC, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, f_mtf_lbl(mtf2), text_color=color.white, text_size=size.small, bgcolor=f_mtf_col(mtf2))
    table.cell(dash, 0, 3, "MTF  " + f_tf_disp(I_MTF_TF3), text_color=#AAAACC, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, f_mtf_lbl(mtf3), text_color=color.white, text_size=size.small, bgcolor=f_mtf_col(mtf3))
    table.cell(dash, 0, 4, "MTF  " + f_tf_disp(I_MTF_TF4), text_color=#AAAACC, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, f_mtf_lbl(mtf4), text_color=color.white, text_size=size.small, bgcolor=f_mtf_col(mtf4))
    table.cell(dash, 0, 5, "MTF  " + f_tf_disp(I_MTF_TF5), text_color=#AAAACC, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, f_mtf_lbl(mtf5), text_color=color.white, text_size=size.small, bgcolor=f_mtf_col(mtf5))

    // Stoch RSI rows with divergence
    table.cell(dash, 0, 6,  "Stoch RSI  " + f_tf_disp(I_SRSI_TF1), text_color=#AAAACC, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6,  f_srsi_txt(s1, bull_div1, bear_div1), text_color=color.white, text_size=size.small, bgcolor=f_srsi_col(s1, bull_div1, bear_div1))
    table.cell(dash, 0, 7,  "Stoch RSI  " + f_tf_disp(I_SRSI_TF2), text_color=#AAAACC, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7,  f_srsi_txt(s2, bull_div2, bear_div2), text_color=color.white, text_size=size.small, bgcolor=f_srsi_col(s2, bull_div2, bear_div2))
    table.cell(dash, 0, 8,  "Stoch RSI  " + f_tf_disp(I_SRSI_TF3), text_color=#AAAACC, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8,  f_srsi_txt(s3, bull_div3, bear_div3), text_color=color.white, text_size=size.small, bgcolor=f_srsi_col(s3, bull_div3, bear_div3))
    table.cell(dash, 0, 9,  "Stoch RSI  " + f_tf_disp(I_SRSI_TF4), text_color=#AAAACC, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 9,  f_srsi_txt(s4, bull_div4, bear_div4), text_color=color.white, text_size=size.small, bgcolor=f_srsi_col(s4, bull_div4, bear_div4))
    table.cell(dash, 0, 10, "Stoch RSI  " + f_tf_disp(I_SRSI_TF5), text_color=#AAAACC, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 10, f_srsi_txt(s5, bull_div5, bear_div5), text_color=color.white, text_size=size.small, bgcolor=f_srsi_col(s5, bull_div5, bear_div5))

    // Overall bias summary row
    int bull_mtf = (mtf1==1?1:0) + (mtf2==1?1:0) + (mtf3==1?1:0) + (mtf4==1?1:0) + (mtf5==1?1:0)
    int bear_mtf = (mtf1==-1?1:0) + (mtf2==-1?1:0) + (mtf3==-1?1:0) + (mtf4==-1?1:0) + (mtf5==-1?1:0)
    string bias_txt = bull_mtf == 5 ? "▲ ALL BULLISH" : bear_mtf == 5 ? "▼ ALL BEARISH" : bull_mtf > bear_mtf ? "▲ Mostly Bull  " + str.tostring(bull_mtf) + "/5" : bear_mtf > bull_mtf ? "▼ Mostly Bear  " + str.tostring(bear_mtf) + "/5" : "— Mixed"
    color  bias_col = bull_mtf >= 4 ? color.new(#26A69A,35) : bear_mtf >= 4 ? color.new(#EF5350,35) : bull_mtf > bear_mtf ? color.new(#26A69A,55) : bear_mtf > bull_mtf ? color.new(#EF5350,55) : color.new(#444444,55)
    table.cell(dash, 0, 11, "MTF Bias", text_color=#AAAACC, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 11, bias_txt, text_color=color.white, text_size=size.small, bgcolor=bias_col)
````

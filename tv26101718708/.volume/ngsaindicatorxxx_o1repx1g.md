# NGSAIndicatorXXX

- url: https://www.tradingview.com/script/O1rEpx1G-NGSAIndicatorXXX/
- type: indicator
- pine_id: PUB;49585a56b3614ef8a9ecf661c31cbe13
- version: 1.0

## Description

stage .. analysis based on weinsteins login..  more details to come soon.....


And I will update the script .. fine tune it...




kkk


yfghjb

## Source Code

````pine
//@version=5
indicator(title="Weinstein Stage Analysis v2", shorttitle="Stage Analysis v2", overlay=true, max_labels_count=500, max_lines_count=500)

// ═══════════════════════════════════════════════════════════════════
//  WEINSTEIN STAGE ANALYSIS v2 — Pine Script v5
//  MA locked to pure SMA 30 (Weinstein's original tool)
//  All labels/table upgraded for readability
// ═══════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────

grp1 = "Moving Average (Weinstein SMA)"
ma_len       = input.int(30, "30-Week SMA Length", minval=5, maxval=200, group=grp1,
     tooltip="Weinstein's pure SMA. Weekly chart=30, Daily chart=150, Monthly=7. DO NOT smooth this.")

grp2 = "Stage Detection Sensitivity"
slope_len    = input.int(4,     "MA Slope Lookback (bars)",      minval=2,    maxval=20,  group=grp2)
slope_thresh = input.float(0.05,"Flat Slope Threshold (%)",      minval=0.01, maxval=1.0, step=0.01, group=grp2)
churn_len    = input.int(8,     "Pivot / Churn Lookback (bars)", minval=4,    maxval=30,  group=grp2)
trend_bars   = input.int(3,     "Min Bars to Confirm Stage",     minval=1,    maxval=10,  group=grp2)
vol_ma_len   = input.int(20,    "Volume MA Length",              minval=5,    maxval=50,  group=grp2)
breakout_vol = input.float(1.5, "Breakout Volume Multiplier",    minval=1.0,  maxval=5.0, step=0.1, group=grp2)

grp3 = "Relative Strength (NSE)"
use_rs     = input.bool(true,          "Enable RS Filter",   group=grp3)
rs_symbol  = input.symbol("NSE:NIFTY","Benchmark Symbol",  group=grp3,
     tooltip="NSE:NIFTY for large-caps. NSE:BANKNIFTY for bank stocks. NSE:CNXMIDCAP for midcaps.")
rs_len     = input.int(52, "RS Lookback (bars)", minval=10, maxval=200, group=grp3)

grp4 = "Display Settings"
show_ma      = input.bool(true, "Show 30W SMA",                 group=grp4)
show_bg      = input.bool(true, "Show Stage Background Colors", group=grp4)
show_labels  = input.bool(true, "Show Stage Confidence Labels", group=grp4)
show_signals = input.bool(true, "Show Buy/Short Signals",       group=grp4)
show_vol_sig = input.bool(true, "Show Volume Confirmation",     group=grp4)
label_freq   = input.int(30,    "Confidence Label Every N Bars",minval=10, maxval=200, group=grp4,
     tooltip="Increase to reduce label clutter. 30=every 30 bars, 50=less frequent.")

grp_clean = "Chart Cleanup (Hide Old History)"
limit_history     = input.bool(true, "Limit historical labels & signals", group=grp_clean,
     tooltip="When on, only labels/signals/profit-booking markers within the last N bars are shown. Older ones are hidden to keep the chart focused on the current setup.")
history_lookback  = input.int(150, "Show last N bars only", minval=20, maxval=2000, step=10, group=grp_clean,
     tooltip="On weekly chart, 150 bars ≈ 3 years. On daily, 150 bars ≈ 7 months. Adjust to your timeframe.")
hide_old_lines    = input.bool(true, "Auto-clean stale stage lines", group=grp_clean,
     tooltip="When a new stage starts, delete lines from previous stages so only the current stage's lines remain on the chart.")

grp5 = "Stage Lines"
show_base_lines     = input.bool(true, "Stage 1: Base Support / Resistance", group=grp5)
show_breakout_line  = input.bool(true, "S1->S2: Breakout Line",              group=grp5)
show_trend_channel  = input.bool(true, "Stage 2: Uptrend Channel",           group=grp5)
show_top_lines      = input.bool(true, "Stage 3: Top / Neckline Lines",      group=grp5)
show_breakdown_line = input.bool(true, "S3->S4: Breakdown Line",             group=grp5)
show_down_channel   = input.bool(true, "Stage 4: Downtrend Channel",         group=grp5)
show_base_floor     = input.bool(true, "S4->S1: New Base Floor",             group=grp5)
line_lookback       = input.int(40,    "Line Anchor Lookback (bars)",        minval=10, maxval=200, group=grp5)

grp_pb = "Profit Booking (Stage 2 Exit)"
show_profit_signals = input.bool(true, "Show Profit Booking Signals", group=grp_pb,
     tooltip="Detects signs of Stage 2 exhaustion BEFORE Stage 3 forms — protects gains.")
profit_min_gain     = input.float(15.0, "Min gain from breakout (%)", minval=5, maxval=100, step=1, group=grp_pb,
     tooltip="Only fire booking signals if stock has rallied at least this % from the Stage 2 breakout. Filters early exits in choppy moves.")
overext_threshold   = input.float(20.0, "Overextension threshold (% above SMA)", minval=10, maxval=80, step=2, group=grp_pb,
     tooltip="Tiered: at this % above 30 SMA = mild signal. At 2.5x this = strong. At 5x this = climax (auto-fires BOOK). Default 20% means: 50% triggers strong, 100% triggers climax.")
trail_atr_mult      = input.float(2.5,  "Chandelier ATR multiplier", minval=1.0, maxval=8.0, step=0.5, group=grp_pb,
     tooltip="Trailing stop = N x ATR(22) below highest high since entry. 2.5 catches parabolic blowoffs faster. Use 3.0+ for slower steady trends, 2.0 for very fast movers.")
rsi_div_lookback    = input.int(14,     "RSI divergence lookback",   minval=7,  maxval=40, group=grp_pb)
exhaustion_wick     = input.float(0.5,  "Exhaustion wick ratio",     minval=0.3, maxval=0.9, step=0.05, group=grp_pb,
     tooltip="Upper wick must be at least this fraction of the bar's total range to count as rejection.")

grp_breadth = "Market Breadth Awareness"
use_breadth         = input.bool(true, "Enable Market Breadth Filter", group=grp_breadth,
     tooltip="Profit-booking signals fire MORE EAGERLY when overall market is weak. Greatly improves risk-adjusted exits.")
breadth_index       = input.symbol("NSE:NIFTY", "Market Index", group=grp_breadth,
     tooltip="Use NSE:NIFTY for large-caps, NSE:CNXMIDCAP for midcaps, NSE:CNXSMALLCAP for smallcaps. Match to your stock's segment.")
breadth_overext     = input.float(15.0, "Index overextended threshold (% above SMA)", minval=5, maxval=40, step=1, group=grp_breadth,
     tooltip="When index is this far above its own 30 SMA, the entire market is climaxing — protect profits more aggressively.")
breadth_rsi_warn    = input.int(70, "Index RSI warning level", minval=60, maxval=85, group=grp_breadth,
     tooltip="When index RSI exceeds this, market is overheated.")

grp6 = "Alert Settings"
alert_breakout  = input.bool(true, "Alert: Stage 2 Breakout",  group=grp6)
alert_breakdown = input.bool(true, "Alert: Stage 4 Breakdown", group=grp6)
alert_top       = input.bool(true, "Alert: Stage 3 Top Entry", group=grp6)
alert_profit    = input.bool(true, "Alert: Profit Booking Signal", group=grp6)

// ─────────────────────────────────────────────────────────────────
//  COLORS  — solid, high-contrast, dark-mode safe
// ─────────────────────────────────────────────────────────────────

col_s1_bg     = color.new(#1565C0, 82)   // deep blue tint bg
col_s2_bg     = color.new(#1B5E20, 82)   // deep green tint bg
col_s3_bg     = color.new(#E65100, 82)   // deep orange tint bg
col_s4_bg     = color.new(#B71C1C, 82)   // deep red tint bg

col_s1_line   = #1E88E5                  // bright blue
col_s2_line   = #43A047                  // bright green
col_s3_line   = #FB8C00                  // bright orange
col_s4_line   = #E53935                  // bright red

col_s2_chan   = color.new(#43A047, 55)
col_s4_chan   = color.new(#E53935, 55)

col_breakout  = #00C853                  // vivid green
col_breakdown = #D500F9                  // vivid magenta
col_buy       = #00C853
col_short     = #D500F9

// Label background colors — fully opaque for readability
lbl_s1_bg     = #1565C0
lbl_s2_bg     = #2E7D32
lbl_s3_bg     = #E65100
lbl_s4_bg     = #C62828

// ─────────────────────────────────────────────────────────────────
//  MOVING AVERAGE — pure SMA only, no smoothing
// ─────────────────────────────────────────────────────────────────

ma_val = ta.sma(close, ma_len)

// ─────────────────────────────────────────────────────────────────
//  MA SLOPE
// ─────────────────────────────────────────────────────────────────

ma_slope_pct    = (ma_val - ma_val[slope_len]) / ma_val[slope_len] * 100
ma_rising       = ma_slope_pct >  slope_thresh
ma_falling      = ma_slope_pct < -slope_thresh
ma_flat         = not ma_rising and not ma_falling
ma_slope_roc    = ma_slope_pct - ma_slope_pct[slope_len]
ma_curling_up   = ma_flat and ma_slope_roc > 0
ma_curling_down = ma_flat and ma_slope_roc < 0

price_above_ma = close > ma_val
price_below_ma = close < ma_val
ma_dist_pct    = (close - ma_val) / ma_val * 100

// ─────────────────────────────────────────────────────────────────
//  PIVOTS
// ─────────────────────────────────────────────────────────────────

pivot_hi = ta.pivothigh(high, churn_len, churn_len)
pivot_lo = ta.pivotlow(low,  churn_len, churn_len)

var float last_ph1     = na
var float last_ph2     = na
var float last_pl1     = na
var float last_pl2     = na
var int   last_ph1_bar = na
var int   last_ph2_bar = na
var int   last_pl1_bar = na
var int   last_pl2_bar = na

if not na(pivot_hi)
    last_ph2     := last_ph1
    last_ph2_bar := last_ph1_bar
    last_ph1     := pivot_hi
    last_ph1_bar := bar_index - churn_len

if not na(pivot_lo)
    last_pl2     := last_pl1
    last_pl2_bar := last_pl1_bar
    last_pl1     := pivot_lo
    last_pl1_bar := bar_index - churn_len

hh = not na(last_ph1) and not na(last_ph2) and last_ph1 > last_ph2
lh = not na(last_ph1) and not na(last_ph2) and last_ph1 < last_ph2
hl = not na(last_pl1) and not na(last_pl2) and last_pl1 > last_pl2
ll = not na(last_pl1) and not na(last_pl2) and last_pl1 < last_pl2

uptrend_structure   = hh and hl
downtrend_structure = lh and ll

// ─────────────────────────────────────────────────────────────────
//  VOLUME
// ─────────────────────────────────────────────────────────────────

vol_ma       = ta.sma(volume, vol_ma_len)
vol_above    = volume > vol_ma * breakout_vol
vol_confirm  = volume > vol_ma

up_vol_avg   = ta.sma(volume * (close >= open ? 1 : 0), vol_ma_len)
down_vol_avg = ta.sma(volume * (close <  open ? 1 : 0), vol_ma_len)
distributing = down_vol_avg > up_vol_avg  * 1.2
accumulating = up_vol_avg   > down_vol_avg * 1.2

avg_range       = ta.sma((high - low) / low * 100, churn_len)
churning        = vol_confirm and math.abs(close - open) / open * 100 < avg_range * 0.3
range_expanding = ta.atr(14) > ta.sma(ta.atr(14), churn_len) * 1.3

// ─────────────────────────────────────────────────────────────────
//  RELATIVE STRENGTH
// ─────────────────────────────────────────────────────────────────

bench_close    = request.security(rs_symbol, timeframe.period, close)
rs_ratio       = close / bench_close
rs_performance = (rs_ratio - rs_ratio[rs_len]) / rs_ratio[rs_len] * 100
rs_positive    = rs_performance > 0

// ─────────────────────────────────────────────────────────────────
//  MARKET BREADTH ANALYSIS
//
//  Pulls full price + indicator data for the broader market index.
//  These metrics influence the profit-booking aggressiveness:
//  weaker market = exit individual positions faster.
//
//  Five breadth signals are computed:
//    1. Index stage (1-4)        — same logic as the stock's stage
//    2. Index overextension       — how stretched is the index?
//    3. Index momentum (RSI 14)   — is RSI rolling over?
//    4. Index volatility regime   — is ATR expanding?
//    5. Index trend slope         — is the 30 SMA still rising?
// ─────────────────────────────────────────────────────────────────

// Pull index OHLCV data (separate request from the RS price above
// because we need full bars, not just close)
br_close  = request.security(breadth_index, timeframe.period, close)
br_high   = request.security(breadth_index, timeframe.period, high)
br_low    = request.security(breadth_index, timeframe.period, low)
br_open   = request.security(breadth_index, timeframe.period, open)

// Index 30W SMA + slope
br_sma30      = ta.sma(br_close, 30)
br_slope_pct  = (br_sma30 - br_sma30[slope_len]) / br_sma30[slope_len] * 100
br_ma_rising  = br_slope_pct >  slope_thresh
br_ma_falling = br_slope_pct < -slope_thresh
br_ma_flat    = not br_ma_rising and not br_ma_falling

// Index distance from its own SMA
br_dist_pct = (br_close - br_sma30) / br_sma30 * 100

// Index stage classification (lightweight — just the basics)
br_stage = br_close > br_sma30 and br_ma_rising  ? 2 :
           br_close < br_sma30 and br_ma_falling ? 4 :
           br_ma_flat and br_close > br_sma30    ? 3 :
           1

// Index momentum
br_rsi = ta.rsi(br_close, 14)
br_rsi_falling = br_rsi < br_rsi[2] and br_rsi[2] < br_rsi[4]   // 4-bar declining RSI

// Index volatility regime (ATR expansion)
br_atr      = ta.atr(14)   // calculated on host symbol — for index we approximate via TR of br
br_tr       = math.max(br_high - br_low, math.max(math.abs(br_high - br_close[1]), math.abs(br_low - br_close[1])))
br_atr_real = ta.sma(br_tr, 14)
br_vol_expanding = br_atr_real > ta.sma(br_atr_real, 30) * 1.3

// ── Composite breadth signals ────────────────────────────────────

// Market in distribution / declining = highest danger
breadth_danger = br_stage == 4 or (br_stage == 3 and br_rsi_falling)

// Market overextended + topping = climax risk
breadth_climax = br_dist_pct >= breadth_overext and br_rsi >= breadth_rsi_warn and br_rsi_falling

// Market warning = RSI cooling from above warn level
breadth_warning = br_rsi >= breadth_rsi_warn or br_vol_expanding or br_ma_flat

// ── Master breadth score (0=healthy, 4=very dangerous) ───────────
breadth_score = 0
breadth_score := breadth_score + (breadth_danger    ? 2 : 0)
breadth_score := breadth_score + (breadth_climax    ? 2 : 0)
breadth_score := breadth_score + (breadth_warning   ? 1 : 0)
breadth_score := breadth_score + (br_ma_falling     ? 1 : 0)

breadth_active = use_breadth and breadth_score >= 1

// ─────────────────────────────────────────────────────────────────
//  STAGE SCORING
// ─────────────────────────────────────────────────────────────────

s1_score = 0
s1_score := s1_score + (ma_flat                                           ? 30 : 0)
s1_score := s1_score + (not uptrend_structure and not downtrend_structure ? 20 : 0)
s1_score := s1_score + (ma_dist_pct < 10 and ma_dist_pct > -10           ? 15 : 0)
s1_score := s1_score + (accumulating                                      ? 15 : 0)
s1_score := s1_score + (not range_expanding                               ? 10 : 0)
s1_score := s1_score + (ma_curling_up                                     ? 10 : 0)

s2_score = 0
s2_score := s2_score + (ma_rising              ? 35 : 0)
s2_score := s2_score + (price_above_ma         ? 25 : 0)
s2_score := s2_score + (uptrend_structure      ? 20 : 0)
s2_score := s2_score + (rs_positive and use_rs ? 10 : 0)
s2_score := s2_score + (not distributing       ? 10 : 0)

s3_score = 0
s3_score := s3_score + (ma_flat         ? 25 : 0)
s3_score := s3_score + (distributing    ? 25 : 0)
s3_score := s3_score + (lh              ? 20 : 0)
s3_score := s3_score + (range_expanding ? 15 : 0)
s3_score := s3_score + (churning        ? 10 : 0)
s3_score := s3_score + (ma_curling_down ?  5 : 0)

s4_score = 0
s4_score := s4_score + (ma_falling                 ? 35 : 0)
s4_score := s4_score + (price_below_ma             ? 25 : 0)
s4_score := s4_score + (downtrend_structure        ? 20 : 0)
s4_score := s4_score + (not rs_positive and use_rs ? 10 : 0)
s4_score := s4_score + (distributing               ? 10 : 0)

// ─────────────────────────────────────────────────────────────────
//  STAGE DETERMINATION
// ─────────────────────────────────────────────────────────────────

f_raw_stage(s1, s2, s3, s4) =>
    s1 >= s2 and s1 >= s3 and s1 >= s4 ? 1 : s2 >= s1 and s2 >= s3 and s2 >= s4 ? 2 : s3 >= s1 and s3 >= s2 and s3 >= s4 ? 3 : 4

raw_stage = f_raw_stage(s1_score, s2_score, s3_score, s4_score)

agreement_count = 0
for i = 0 to trend_bars - 1
    agreement_count := agreement_count + (f_raw_stage(s1_score[i], s2_score[i], s3_score[i], s4_score[i]) == raw_stage ? 1 : 0)

var int stage = 1
if agreement_count >= trend_bars
    stage := raw_stage

stage_confidence = switch stage
    1 => math.round(s1_score)
    2 => math.round(s2_score)
    3 => math.round(s3_score)
    4 => math.round(s4_score)
    => 0

// ─────────────────────────────────────────────────────────────────
//  STAGE TRANSITIONS
// ─────────────────────────────────────────────────────────────────

prev_stage         = stage[1]
just_entered_s1    = stage == 1 and prev_stage != 1
just_entered_s2    = stage == 2 and prev_stage != 2
just_entered_s3    = stage == 3 and prev_stage != 3
just_entered_s4    = stage == 4 and prev_stage != 4

s1_to_s2_breakout  = just_entered_s2 and prev_stage == 1
s2_to_s3_top       = just_entered_s3 and prev_stage == 2
s3_to_s4_breakdown = just_entered_s4 and prev_stage == 3
s4_to_s1_basing    = just_entered_s1 and prev_stage == 4

vol_confirmed_breakout = s1_to_s2_breakout and vol_above

// ─────────────────────────────────────────────────────────────────
//  HISTORY WINDOW GUARD
//  Plotshapes/labels are gated by this so old chart history stays
//  visually clean. Lines (which auto-redraw on barstate.islast)
//  also get culled when limit_history is on.
// ─────────────────────────────────────────────────────────────────

bars_from_now = last_bar_index - bar_index
in_window     = not limit_history or bars_from_now <= history_lookback

// ─────────────────────────────────────────────────────────────────
//  PROFIT BOOKING — Stage 2 exhaustion detection (v2)
//
//  Detects exhaustion BEFORE Stage 3 forms. Specifically tuned to
//  catch parabolic blowoffs (e.g. Indo Tech Transformers 2024-25
//  rally to ₹3800) where standard exhaustion bars don't fire because
//  volume is consistently elevated bar after bar.
//
//  Eight independent signals, weighted by severity. Tiered output:
//    STRONG (BOOK)  — score >= 4 OR any single tier-3 climax signal
//    CAUTION (TRIM) — score >= 2 within a 2-bar window
// ─────────────────────────────────────────────────────────────────

// ── Track Stage 2 entry / highest high since entry ────────────────
var float s2_entry_price  = na
var float s2_highest_high = na
var int   s2_entry_bar    = na

if s1_to_s2_breakout
    s2_entry_price  := close
    s2_highest_high := high
    s2_entry_bar    := bar_index

if stage == 2 and not na(s2_highest_high)
    s2_highest_high := math.max(s2_highest_high, high)

if stage != 2 and not just_entered_s2
    s2_entry_price  := na
    s2_highest_high := na
    s2_entry_bar    := na

gain_from_entry = na(s2_entry_price) ? 0.0 : (close - s2_entry_price) / s2_entry_price * 100
profit_gate     = stage == 2 and gain_from_entry >= profit_min_gain

// ── Signal 1: Tiered Climax / Overextension ──────────────────────
// Far above the 30 SMA = mean reversion overdue.
// Tiered: more extreme = more weight.
overext_mild     = ma_dist_pct >= overext_threshold                 // e.g. 20%
overext_strong   = ma_dist_pct >= overext_threshold * 2.5           // e.g. 50%
overext_extreme  = ma_dist_pct >= overext_threshold * 5.0           // e.g. 100% — climax

// ── Signal 2: Parabolic blowoff (timeframe-adaptive) ─────────────
// Detects rapid % gains over short and long lookback windows.
// Bar counts scale with timeframe so detection works on weekly,
// daily, and intraday charts equally well.
//   Weekly: 8/16 bars = ~2/4 months
//   Daily:  40/80 bars = ~2/4 months
//   Hourly: 50/100 bars
parabolic_short_len = timeframe.isweekly  ? 8  : timeframe.ismonthly ? 3  : timeframe.isdaily ? 40 : 50
parabolic_long_len  = timeframe.isweekly  ? 16 : timeframe.ismonthly ? 6  : timeframe.isdaily ? 80 : 100

gain_short = (close - close[parabolic_short_len]) / close[parabolic_short_len] * 100
gain_long  = (close - close[parabolic_long_len])  / close[parabolic_long_len]  * 100

parabolic_short = gain_short >= 50
parabolic_long  = gain_long  >= 100
parabolic_blowoff = parabolic_short or parabolic_long

// ── Signal 3: Volume climax bar ──────────────────────────────────
// A single bar with massive volume — the "blowoff" bar. Even
// during sustained high-volume parabolas, a true climax bar prints
// 2x+ the recent elevated baseline.
vol_climax = volume > vol_ma * 2.5

// ── Signal 4: Exhaustion candle ──────────────────────────────────
// Long upper wick + close in lower half. Volume condition relaxed
// during parabolic moves where elevated volume is the norm.
bar_range  = high - low
upper_wick = high - math.max(close, open)
exhaustion_bar = bar_range > 0 and upper_wick / bar_range >= exhaustion_wick and close < (high + low) / 2

// ── Signal 5: Bearish RSI divergence ─────────────────────────────
rsi14 = ta.rsi(close, rsi_div_lookback)

var float prev_high_price = na
var float prev_high_rsi   = na

if not na(pivot_hi)
    new_high = pivot_hi
    new_rsi  = rsi14[churn_len]
    prev_high_price := new_high
    prev_high_rsi   := new_rsi

bearish_div = not na(pivot_hi) and not na(prev_high_price) and not na(prev_high_rsi) and pivot_hi > prev_high_price and rsi14[churn_len] < prev_high_rsi

// ── Signal 6: RSI overbought extreme ─────────────────────────────
// RSI > 80 on weekly = historically rare and reverses fast.
rsi_overbought = rsi14 > 80

// ── Signal 7: Failed swing high ──────────────────────────────────
new_20bar_high = high >= ta.highest(high, 20)[1]
failed_swing   = new_20bar_high[1] and close < low[1] and close < open

// ── Signal 8: Close below short-term MA ──────────────────────────
short_ma       = ta.sma(close, 10)
below_short_ma = close < short_ma and close[1] >= short_ma[1]

// ── Signal 9: Chandelier trailing stop hit ───────────────────────
atr22 = ta.atr(22)
chandelier_stop = na(s2_highest_high) ? na : s2_highest_high - atr22 * trail_atr_mult
chandelier_hit  = not na(chandelier_stop) and close < chandelier_stop and close[1] >= chandelier_stop[1]

// ─────────────────────────────────────────────────────────────────
//  WEIGHTED SCORING
//
//  Some signals are stronger predictors than others. Weight them.
//  Total possible: ~12 points. Tiers based on weighted total.
// ─────────────────────────────────────────────────────────────────

profit_score = 0
profit_score := profit_score + (overext_mild      ? 1 : 0)
profit_score := profit_score + (overext_strong    ? 1 : 0)   // additive: at 50% above SMA = 2 points
profit_score := profit_score + (overext_extreme   ? 2 : 0)   // additive: at 100% above SMA = 4 points total just from overext
profit_score := profit_score + (parabolic_short   ? 2 : 0)
profit_score := profit_score + (parabolic_long    ? 2 : 0)
profit_score := profit_score + (vol_climax        ? 2 : 0)
profit_score := profit_score + (exhaustion_bar    ? 1 : 0)
profit_score := profit_score + (bearish_div       ? 1 : 0)
profit_score := profit_score + (rsi_overbought    ? 1 : 0)
profit_score := profit_score + (failed_swing      ? 1 : 0)
profit_score := profit_score + (below_short_ma    ? 1 : 0)
profit_score := profit_score + (chandelier_hit    ? 2 : 0)

// 2-bar window to allow signals to cluster
profit_score_window = math.max(profit_score, profit_score[1], profit_score[2])

// ─────────────────────────────────────────────────────────────────
//  TIER ASSIGNMENT
//
//  STRONG fires immediately if:
//    - Total score >= 4 (multiple confluence)
//    - OR overext_extreme (100%+ above SMA — always a climax)
//    - OR parabolic + vol_climax (the textbook blowoff bar)
//    - OR chandelier_hit (hard exit)
//
//  CAUTION fires if score == 2 or 3 within window.
//
//  Cooldown only applies to CAUTION — STRONG always fires when
//  conditions warrant, since missing a peak costs more than dupes.
// ─────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────
//  TIER ASSIGNMENT (with market breadth modifier)
//
//  Base thresholds:
//    STRONG fires at score >= 4 (or any single climax trigger)
//    CAUTION fires at score >= 2
//
//  When market breadth is bad (breadth_score >= 2), thresholds tighten:
//    STRONG fires at score >= 3
//    CAUTION fires at score >= 1
//
//  When market is in outright Stage 4 / climax, ANY exhaustion
//  signal at all triggers STRONG — protecting profits is paramount
//  when the broader market has turned hostile.
// ─────────────────────────────────────────────────────────────────

// Dynamic thresholds based on market breadth
strong_threshold  = use_breadth and breadth_score >= 2 ? 3 : 4
caution_threshold = use_breadth and breadth_score >= 2 ? 1 : 2

// Bad-breadth fast-track: if the market itself is dangerous AND
// stock has any exhaustion signal at all, escalate to STRONG
breadth_emergency = use_breadth and (breadth_danger or breadth_climax) and profit_score_window >= 1

profit_strong  = profit_gate and (profit_score_window >= strong_threshold or overext_extreme or (parabolic_blowoff and vol_climax) or chandelier_hit or breadth_emergency)
profit_caution = profit_gate and not profit_strong and profit_score_window >= caution_threshold
profit_watch   = profit_gate and not profit_strong and not profit_caution and profit_score_window == 1

var int last_profit_bar = na
profit_cooldown_ok = na(last_profit_bar) or bar_index - last_profit_bar >= 3

profit_strong_fire  = profit_strong   // STRONG never gated by cooldown
profit_caution_fire = profit_caution and profit_cooldown_ok and not profit_strong_fire

if profit_strong_fire or profit_caution_fire
    last_profit_bar := bar_index

// ─────────────────────────────────────────────────────────────────
//  UNCONDITIONAL LOOKBACK SERIES
// ─────────────────────────────────────────────────────────────────

hi_full = ta.highest(high, line_lookback)
lo_full = ta.lowest(low,   line_lookback)
lo_half = ta.lowest(low,   math.max(1, math.round(line_lookback / 2)))

// ─────────────────────────────────────────────────────────────────
//  STATE STORAGE FOR LINE RECONSTRUCTION
// ─────────────────────────────────────────────────────────────────

var float lvl_base_res   = na
var int   bar_base_res   = na
var float lvl_base_sup   = na
var int   bar_base_sup   = na
var float lvl_breakout   = na
var int   bar_breakout   = na
var float lvl_top_res    = na
var int   bar_top_res    = na
var float lvl_neckline   = na
var int   bar_neckline   = na
var float lvl_breakdown  = na
var int   bar_breakdown  = na
var float lvl_base_floor = na
var int   bar_base_floor = na

var float s2_pl1 = na
var int   s2_pl1_bar = na
var float s2_pl2 = na
var int   s2_pl2_bar = na
var float s2_ph1 = na
var int   s2_ph1_bar = na

var float s4_ph1 = na
var int   s4_ph1_bar = na
var float s4_ph2 = na
var int   s4_ph2_bar = na
var float s4_pl1 = na
var int   s4_pl1_bar = na

// ─────────────────────────────────────────────────────────────────
//  LINE AND LABEL HANDLES
// ─────────────────────────────────────────────────────────────────

var line  ln_base_res    = na
var label lbl_base_res   = na
var line  ln_base_sup    = na
var label lbl_base_sup   = na
var line  ln_breakout    = na
var label lbl_breakout   = na
var line  ln_top_res     = na
var label lbl_top_res    = na
var line  ln_neckline    = na
var label lbl_neckline   = na
var line  ln_breakdown   = na
var label lbl_breakdown  = na
var line  ln_base_floor  = na
var label lbl_base_floor = na
var line  ln_s2_trend    = na
var line  ln_s2_channel  = na
var line  ln_s4_trend    = na
var line  ln_s4_channel  = na

// ─────────────────────────────────────────────────────────────────
//  CAPTURE STATE ON STAGE EVENTS
// ─────────────────────────────────────────────────────────────────

// Stale-line cleanup: when a new stage starts, wipe the price levels
// AND delete the line/label drawing objects from earlier-stage lines
// so they disappear from the chart and don't get redrawn on islast.

if hide_old_lines and just_entered_s1
    // Entering Stage 1 = invalidate everything from prior cycle
    lvl_breakout    := na
    lvl_top_res     := na
    lvl_neckline    := na
    lvl_breakdown   := na
    s2_pl1          := na
    s2_pl2          := na
    s2_ph1          := na
    s4_ph1          := na
    s4_ph2          := na
    s4_pl1          := na
    line.delete(ln_breakout)
    label.delete(lbl_breakout)
    line.delete(ln_top_res)
    label.delete(lbl_top_res)
    line.delete(ln_neckline)
    label.delete(lbl_neckline)
    line.delete(ln_breakdown)
    label.delete(lbl_breakdown)
    line.delete(ln_s2_trend)
    line.delete(ln_s2_channel)
    line.delete(ln_s4_trend)
    line.delete(ln_s4_channel)

if hide_old_lines and just_entered_s2
    // Entering Stage 2 = topping/breakdown/Stage 4 trend data stale
    lvl_top_res     := na
    lvl_neckline    := na
    lvl_breakdown   := na
    s4_ph1          := na
    s4_ph2          := na
    s4_pl1          := na
    line.delete(ln_top_res)
    label.delete(lbl_top_res)
    line.delete(ln_neckline)
    label.delete(lbl_neckline)
    line.delete(ln_breakdown)
    label.delete(lbl_breakdown)
    line.delete(ln_s4_trend)
    line.delete(ln_s4_channel)

if hide_old_lines and just_entered_s3
    // Entering Stage 3 = old base/breakout history irrelevant
    lvl_base_res    := na
    lvl_base_sup    := na
    lvl_breakout    := na
    lvl_base_floor  := na
    s4_ph1          := na
    s4_ph2          := na
    s4_pl1          := na
    line.delete(ln_base_res)
    label.delete(lbl_base_res)
    line.delete(ln_base_sup)
    label.delete(lbl_base_sup)
    line.delete(ln_breakout)
    label.delete(lbl_breakout)
    line.delete(ln_base_floor)
    label.delete(lbl_base_floor)
    line.delete(ln_s4_trend)
    line.delete(ln_s4_channel)

if hide_old_lines and just_entered_s4
    // Entering Stage 4 = base/breakout/S2 trend data fully stale
    lvl_base_res    := na
    lvl_base_sup    := na
    lvl_breakout    := na
    lvl_base_floor  := na
    s2_pl1          := na
    s2_pl2          := na
    s2_ph1          := na
    line.delete(ln_base_res)
    label.delete(lbl_base_res)
    line.delete(ln_base_sup)
    label.delete(lbl_base_sup)
    line.delete(ln_breakout)
    label.delete(lbl_breakout)
    line.delete(ln_base_floor)
    label.delete(lbl_base_floor)
    line.delete(ln_s2_trend)
    line.delete(ln_s2_channel)

if just_entered_s1
    lvl_base_res   := hi_full
    bar_base_res   := bar_index - line_lookback
    lvl_base_sup   := lo_full
    bar_base_sup   := bar_index - line_lookback

if s1_to_s2_breakout
    lvl_breakout   := close
    bar_breakout   := bar_index

if just_entered_s3
    lvl_top_res    := hi_full
    bar_top_res    := bar_index - line_lookback
    lvl_neckline   := lo_half
    bar_neckline   := bar_index - math.max(1, math.round(line_lookback / 2))

if s3_to_s4_breakdown
    lvl_breakdown  := close
    bar_breakdown  := bar_index

if s4_to_s1_basing
    lvl_base_floor := lo_full
    bar_base_floor := bar_index - line_lookback

if stage == 2 and not na(last_pl1) and not na(last_pl2)
    s2_pl1     := last_pl1
    s2_pl1_bar := last_pl1_bar
    s2_pl2     := last_pl2
    s2_pl2_bar := last_pl2_bar
    if not na(last_ph1)
        s2_ph1     := last_ph1
        s2_ph1_bar := last_ph1_bar

if stage == 4 and not na(last_ph1) and not na(last_ph2)
    s4_ph1     := last_ph1
    s4_ph1_bar := last_ph1_bar
    s4_ph2     := last_ph2
    s4_ph2_bar := last_ph2_bar
    if not na(last_pl1)
        s4_pl1     := last_pl1
        s4_pl1_bar := last_pl1_bar

// ─────────────────────────────────────────────────────────────────
//  FULL REDRAW ON EVERY LAST BAR
//  Ensures all drawings track zoom/pan perfectly
// ─────────────────────────────────────────────────────────────────

if barstate.islast

    // ── Stage 1: Base Resistance ──────────────────────────────────
    if show_base_lines and not na(lvl_base_res)
        line.delete(ln_base_res)
        ln_base_res := line.new(bar_base_res, lvl_base_res, bar_index, lvl_base_res,
             color=col_s1_line, width=2, style=line.style_dashed, extend=extend.right)
        label.delete(lbl_base_res)
        lbl_base_res := label.new(bar_index, lvl_base_res,
             text=" Base Resistance: " + str.tostring(math.round(lvl_base_res, 2)) + " ",
             color=lbl_s1_bg, textcolor=color.white,
             style=label.style_label_left, size=size.normal)

    // ── Stage 1: Base Support ─────────────────────────────────────
    if show_base_lines and not na(lvl_base_sup)
        line.delete(ln_base_sup)
        ln_base_sup := line.new(bar_base_sup, lvl_base_sup, bar_index, lvl_base_sup,
             color=col_s1_line, width=1, style=line.style_dotted, extend=extend.right)
        label.delete(lbl_base_sup)
        lbl_base_sup := label.new(bar_index, lvl_base_sup,
             text=" Base Support: " + str.tostring(math.round(lvl_base_sup, 2)) + " ",
             color=lbl_s1_bg, textcolor=color.white,
             style=label.style_label_left, size=size.normal)

    // ── S1->S2: Breakout line ─────────────────────────────────────
    if show_breakout_line and not na(lvl_breakout)
        line.delete(ln_breakout)
        ln_breakout := line.new(bar_breakout, lvl_breakout, bar_index, lvl_breakout,
             color=col_breakout, width=2, style=line.style_solid, extend=extend.right)
        label.delete(lbl_breakout)
        lbl_breakout := label.new(bar_index, lvl_breakout,
             text=" Breakout: " + str.tostring(math.round(lvl_breakout, 2)) + " ",
             color=#00695C, textcolor=color.white,
             style=label.style_label_left, size=size.normal)

    // ── Stage 2: Rising trendline + upper channel ─────────────────
    if show_trend_channel and not na(s2_pl1) and not na(s2_pl2) and not na(s2_pl1_bar) and not na(s2_pl2_bar)
        s2_slope = (s2_pl1 - s2_pl2) / math.max(s2_pl1_bar - s2_pl2_bar, 1)
        s2_y1    = s2_pl2
        s2_y2    = s2_pl2 + s2_slope * (bar_index - s2_pl2_bar)
        line.delete(ln_s2_trend)
        ln_s2_trend := line.new(s2_pl2_bar, s2_y1, bar_index, s2_y2,
             color=col_s2_line, width=2, style=line.style_solid, extend=extend.right)
        if not na(s2_ph1) and not na(s2_ph1_bar)
            s2_y_off = s2_ph1 - (s2_pl2 + s2_slope * (s2_ph1_bar - s2_pl2_bar))
            line.delete(ln_s2_channel)
            ln_s2_channel := line.new(s2_pl2_bar, s2_y1 + s2_y_off, bar_index, s2_y2 + s2_y_off,
                 color=col_s2_chan, width=1, style=line.style_dashed, extend=extend.right)

    // ── Stage 3: Top + Neckline ───────────────────────────────────
    if show_top_lines and not na(lvl_top_res)
        line.delete(ln_top_res)
        ln_top_res := line.new(bar_top_res, lvl_top_res, bar_index, lvl_top_res,
             color=col_s3_line, width=2, style=line.style_dashed, extend=extend.right)
        label.delete(lbl_top_res)
        lbl_top_res := label.new(bar_index, lvl_top_res,
             text=" Stage 3 Top: " + str.tostring(math.round(lvl_top_res, 2)) + " ",
             color=lbl_s3_bg, textcolor=color.white,
             style=label.style_label_left, size=size.normal)

    if show_top_lines and not na(lvl_neckline)
        line.delete(ln_neckline)
        ln_neckline := line.new(bar_neckline, lvl_neckline, bar_index, lvl_neckline,
             color=col_s3_line, width=2, style=line.style_dotted, extend=extend.right)
        label.delete(lbl_neckline)
        lbl_neckline := label.new(bar_index, lvl_neckline,
             text=" Neckline: " + str.tostring(math.round(lvl_neckline, 2)) + " ",
             color=lbl_s3_bg, textcolor=color.white,
             style=label.style_label_left, size=size.normal)

    // ── S3->S4: Breakdown line ────────────────────────────────────
    if show_breakdown_line and not na(lvl_breakdown)
        line.delete(ln_breakdown)
        ln_breakdown := line.new(bar_breakdown, lvl_breakdown, bar_index, lvl_breakdown,
             color=col_breakdown, width=2, style=line.style_solid, extend=extend.right)
        label.delete(lbl_breakdown)
        lbl_breakdown := label.new(bar_index, lvl_breakdown,
             text=" Breakdown: " + str.tostring(math.round(lvl_breakdown, 2)) + " ",
             color=#6A0080, textcolor=color.white,
             style=label.style_label_left, size=size.normal)

    // ── Stage 4: Declining trendline + lower channel ──────────────
    if show_down_channel and not na(s4_ph1) and not na(s4_ph2) and not na(s4_ph1_bar) and not na(s4_ph2_bar)
        s4_slope = (s4_ph1 - s4_ph2) / math.max(s4_ph1_bar - s4_ph2_bar, 1)
        s4_y1    = s4_ph2
        s4_y2    = s4_ph2 + s4_slope * (bar_index - s4_ph2_bar)
        line.delete(ln_s4_trend)
        ln_s4_trend := line.new(s4_ph2_bar, s4_y1, bar_index, s4_y2,
             color=col_s4_line, width=2, style=line.style_solid, extend=extend.right)
        if not na(s4_pl1) and not na(s4_pl1_bar)
            s4_y_off = s4_pl1 - (s4_ph2 + s4_slope * (s4_pl1_bar - s4_ph2_bar))
            line.delete(ln_s4_channel)
            ln_s4_channel := line.new(s4_ph2_bar, s4_y1 + s4_y_off, bar_index, s4_y2 + s4_y_off,
                 color=col_s4_chan, width=1, style=line.style_dashed, extend=extend.right)

    // ── S4->S1: New base floor ────────────────────────────────────
    if show_base_floor and not na(lvl_base_floor)
        line.delete(ln_base_floor)
        ln_base_floor := line.new(bar_base_floor, lvl_base_floor, bar_index, lvl_base_floor,
             color=col_s1_line, width=2, style=line.style_solid, extend=extend.right)
        label.delete(lbl_base_floor)
        lbl_base_floor := label.new(bar_index, lvl_base_floor,
             text=" Base Floor: " + str.tostring(math.round(lvl_base_floor, 2)) + " ",
             color=lbl_s1_bg, textcolor=color.white,
             style=label.style_label_left, size=size.normal)

// ─────────────────────────────────────────────────────────────────
//  STAGE COLORS
// ─────────────────────────────────────────────────────────────────

stage_bg_col = switch stage
    1 => col_s1_bg
    2 => col_s2_bg
    3 => col_s3_bg
    4 => col_s4_bg
    => color.new(color.gray, 92)

stage_ma_col = switch stage
    1 => col_s1_line
    2 => col_s2_line
    3 => col_s3_line
    4 => col_s4_line
    => color.gray

// ─────────────────────────────────────────────────────────────────
//  STANDARD PLOTS
// ─────────────────────────────────────────────────────────────────

bgcolor(show_bg ? stage_bg_col : na, title="Stage Background")
plot(show_ma ? ma_val : na, title="30W SMA (Weinstein)", color=stage_ma_col, linewidth=3)

// ─────────────────────────────────────────────────────────────────
//  BUY / SELL / SHORT SIGNALS  — upgraded to large size
// ─────────────────────────────────────────────────────────────────

plotshape(show_signals and s1_to_s2_breakout and vol_above and in_window,
     title="Stage 2 Breakout (Vol Confirmed)", style=shape.triangleup,
     location=location.belowbar, color=col_buy, size=size.large,
     text="BUY\nS2", textcolor=color.white)

plotshape(show_signals and s1_to_s2_breakout and not vol_above and in_window,
     title="Stage 2 Breakout (Unconfirmed)", style=shape.triangleup,
     location=location.belowbar, color=color.new(#00C853, 35), size=size.normal,
     text="S2?", textcolor=color.white)

plotshape(show_signals and s2_to_s3_top and in_window,
     title="Stage 3 Top (Sell)", style=shape.square,
     location=location.abovebar, color=lbl_s3_bg, size=size.normal,
     text="SELL\nS3", textcolor=color.white)

plotshape(show_signals and s3_to_s4_breakdown and in_window,
     title="Stage 4 Breakdown (Short)", style=shape.triangledown,
     location=location.abovebar, color=col_short, size=size.large,
     text="SHORT\nS4", textcolor=color.white)

plotshape(show_signals and s4_to_s1_basing and in_window,
     title="Stage 1 Basing (Cover)", style=shape.circle,
     location=location.belowbar, color=col_s1_line, size=size.normal,
     text="BASE\nS1", textcolor=color.white)

plotshape(show_vol_sig and vol_above and stage == 2 and in_window,
     title="High Volume S2", style=shape.diamond,
     location=location.belowbar, color=color.new(#00C853, 40), size=size.small)

plotshape(show_vol_sig and vol_above and stage == 4 and in_window,
     title="High Volume S4", style=shape.diamond,
     location=location.abovebar, color=color.new(#E53935, 40), size=size.small)

// ─────────────────────────────────────────────────────────────────
//  PROFIT BOOKING SIGNALS  — managed labels, auto-clean per cycle
//
//  Stored in arrays so we can delete them all when a new Stage 2
//  starts, keeping the chart focused on the current cycle only.
//
//  Visual style: compact circular badges with currency/coin glyphs
//  rather than chunky text labels — fit naturally on the chart.
// ─────────────────────────────────────────────────────────────────

var label[] profit_labels = array.new_label()

// Wipe all profit labels from previous Stage 2 cycle when a new S2 starts
if just_entered_s2 and array.size(profit_labels) > 0
    for i = 0 to array.size(profit_labels) - 1
        label.delete(array.get(profit_labels, i))
    array.clear(profit_labels)

// Create STRONG signal — small text-only label "₹" above the bar
if show_profit_signals and profit_strong_fire and in_window
    new_lbl = label.new(bar_index, high,
         text="₹",
         color=color.new(color.white, 100),
         textcolor=#FF6F00,
         style=label.style_label_down, size=size.large,
         yloc=yloc.abovebar,
         tooltip="BOOK PROFIT — Strong exhaustion. Take most or all of position. Score: " + str.tostring(profit_score))
    array.push(profit_labels, new_lbl)

// Create CAUTION signal — small text-only "◉" above the bar
if show_profit_signals and profit_caution_fire and in_window
    new_lbl = label.new(bar_index, high,
         text="◉",
         color=color.new(color.white, 100),
         textcolor=#FFA726,
         style=label.style_label_down, size=size.normal,
         yloc=yloc.abovebar,
         tooltip="TRIM — Stage 2 weakening. Scale out 30-50%, tighten stops. Score: " + str.tostring(profit_score))
    array.push(profit_labels, new_lbl)

// Optional: visualize trailing chandelier stop while in Stage 2
plot(show_profit_signals and stage == 2 ? chandelier_stop : na,
     title="Chandelier Trail Stop", color=color.new(#FF6F00, 30),
     style=plot.style_linebr, linewidth=1)

// ─────────────────────────────────────────────────────────────────
//  STAGE CONFIDENCE LABELS
//  size.normal, fully opaque background, clear text
// ─────────────────────────────────────────────────────────────────

if show_labels and bar_index % label_freq == 0 and not na(ma_val) and in_window
    lbl_bg = switch stage
        1 => lbl_s1_bg
        2 => lbl_s2_bg
        3 => lbl_s3_bg
        4 => lbl_s4_bg
        => color.gray
    lbl_txt  = "S" + str.tostring(stage) + " · " + str.tostring(stage_confidence) + "%"
    lbl_loc  = stage == 1 or stage == 2 ? label.style_label_up   : label.style_label_down
    lbl_yloc = stage == 1 or stage == 2 ? low  * 0.995 : high * 1.005
    label.new(bar_index, lbl_yloc,
         text=lbl_txt, color=lbl_bg,
         textcolor=color.white, style=lbl_loc, size=size.normal)

// ─────────────────────────────────────────────────────────────────
//  INFO TABLE  — upgraded font sizes, fully opaque rows
// ─────────────────────────────────────────────────────────────────

var table info_tbl = table.new(position.top_right, 2, 13,
     bgcolor=#0D0D0D,
     border_color=color.new(color.gray, 50),
     border_width=1,
     frame_color=color.new(color.gray, 40),
     frame_width=1)

if barstate.islast
    stage_name = switch stage
        1 => "Stage 1 — Basing"
        2 => "Stage 2 — Advancing"
        3 => "Stage 3 — Topping"
        4 => "Stage 4 — Declining"
        => "Unknown"
    stage_action = switch stage
        1 => "WATCH  (wait for S2)"
        2 => "BUY / HOLD LONGS"
        3 => "SELL LONGS / EXIT"
        4 => "AVOID / SHORT"
        => "-"
    tbl_hdr = switch stage
        1 => lbl_s1_bg
        2 => lbl_s2_bg
        3 => lbl_s3_bg
        4 => lbl_s4_bg
        => #333333
    conf_col = stage_confidence >= 70 ? #1B5E20 : stage_confidence >= 40 ? #E65100 : #B71C1C
    row_bg   = #111111
    rs_txt   = use_rs ? (rs_positive ? "+" + str.tostring(math.round(rs_performance, 1)) + "%" : str.tostring(math.round(rs_performance, 1)) + "%") : "OFF"
    rs_col   = use_rs ? (rs_positive ? #1B5E20 : #B71C1C) : #444444

    // Row 0 — Stage header (largest text)
    table.cell(info_tbl, 0, 0, "  STAGE",    text_color=color.white, bgcolor=tbl_hdr, text_size=size.normal, text_halign=text.align_left)
    table.cell(info_tbl, 1, 0, stage_name + "  ", text_color=color.white, bgcolor=tbl_hdr, text_size=size.normal, text_halign=text.align_left)

    // Row 1 — Action
    table.cell(info_tbl, 0, 1, "  Action",   text_color=#AAAAAA, bgcolor=row_bg, text_size=size.small, text_halign=text.align_left)
    table.cell(info_tbl, 1, 1, stage_action + "  ", text_color=color.white, bgcolor=row_bg, text_size=size.small, text_halign=text.align_left)

    // Row 2 — Confidence
    table.cell(info_tbl, 0, 2, "  Confidence", text_color=#AAAAAA, bgcolor=row_bg, text_size=size.small, text_halign=text.align_left)
    table.cell(info_tbl, 1, 2, str.tostring(stage_confidence) + " / 100  ", text_color=color.white, bgcolor=conf_col, text_size=size.small, text_halign=text.align_left)

    // Row 3 — MA
    table.cell(info_tbl, 0, 3, "  30W SMA",  text_color=#AAAAAA, bgcolor=row_bg, text_size=size.small, text_halign=text.align_left)
    table.cell(info_tbl, 1, 3, "SMA " + str.tostring(ma_len) + " @ " + str.tostring(math.round(ma_val, 2)) + "  ", text_color=color.white, bgcolor=row_bg, text_size=size.small, text_halign=text.align_left)

    // Row 4 — MA Slope
    slope_col = ma_rising ? #43A047 : ma_falling ? #E53935 : #FB8C00
    table.cell(info_tbl, 0, 4, "  MA Slope", text_color=#AAAAAA, bgcolor=row_bg, text_size=size.small, text_halign=text.align_left)
    table.cell(info_tbl, 1, 4, (ma_rising ? "RISING" : ma_falling ? "FALLING" : "FLAT") + "  ", text_color=slope_col, bgcolor=row_bg, text_size=size.small, text_halign=text.align_left)

    // Row 5 — Volume
    vol_txt = accumulating ? "ACCUMULATING" : distributing ? "DISTRIBUTING" : "NEUTRAL"
    vol_col = accumulating ? #43A047 : distributing ? #E53935 : #AAAAAA
    table.cell(info_tbl, 0, 5, "  Volume",   text_color=#AAAAAA, bgcolor=row_bg, text_size=size.small, text_halign=text.align_left)
    table.cell(info_tbl, 1, 5, vol_txt + "  ", text_color=vol_col, bgcolor=row_bg, text_size=size.small, text_halign=text.align_left)

    // Row 6 — Trend structure
    trend_txt = uptrend_structure ? "HH + HL" : downtrend_structure ? "LH + LL" : "SIDEWAYS"
    trend_col = uptrend_structure ? #43A047 : downtrend_structure ? #E53935 : #AAAAAA
    table.cell(info_tbl, 0, 6, "  Trend",    text_color=#AAAAAA, bgcolor=row_bg, text_size=size.small, text_halign=text.align_left)
    table.cell(info_tbl, 1, 6, trend_txt + "  ", text_color=trend_col, bgcolor=row_bg, text_size=size.small, text_halign=text.align_left)

    // Row 7 — RS vs Nifty
    table.cell(info_tbl, 0, 7, "  RS / Nifty", text_color=#AAAAAA, bgcolor=row_bg, text_size=size.small, text_halign=text.align_left)
    table.cell(info_tbl, 1, 7, rs_txt + "  ", text_color=color.white, bgcolor=rs_col, text_size=size.small, text_halign=text.align_left)

    // Row 8 — Churn
    table.cell(info_tbl, 0, 8, "  Churn",    text_color=#AAAAAA, bgcolor=row_bg, text_size=size.small, text_halign=text.align_left)
    table.cell(info_tbl, 1, 8, (churning ? "YES — S3 warning" : "No") + "  ", text_color=churning ? #FB8C00 : #AAAAAA, bgcolor=row_bg, text_size=size.small, text_halign=text.align_left)

    // Row 9 — Active lines
    lines_lbl = switch stage
        1 => "Base Res / Sup"
        2 => "Uptrend Channel"
        3 => "Top / Neckline"
        4 => "Downtrend Channel"
        => "-"
    table.cell(info_tbl, 0, 9, "  Lines",    text_color=#AAAAAA, bgcolor=row_bg, text_size=size.small, text_halign=text.align_left)
    table.cell(info_tbl, 1, 9, lines_lbl + "  ", text_color=color.white, bgcolor=row_bg, text_size=size.small, text_halign=text.align_left)

    // Row 10 — Gain from S2 entry
    gain_txt = na(s2_entry_price) ? "—" : (gain_from_entry >= 0 ? "+" : "") + str.tostring(math.round(gain_from_entry, 1)) + "%"
    gain_col = na(s2_entry_price) ? #444444 : gain_from_entry >= profit_min_gain ? #1B5E20 : #555555
    table.cell(info_tbl, 0, 10, "  Gain @ S2",  text_color=#AAAAAA, bgcolor=row_bg,  text_size=size.small, text_halign=text.align_left)
    table.cell(info_tbl, 1, 10, gain_txt + "  ", text_color=color.white, bgcolor=gain_col, text_size=size.small, text_halign=text.align_left)

    // Row 11 — Profit booking status
    pb_txt = stage != 2 ? "n/a (not S2)" : not profit_gate ? "watching..." : profit_strong ? "STRONG — book now" : profit_caution ? "CAUTION — trim" : profit_watch ? "1 signal" : "ok to hold"
    pb_col = stage != 2 ? #444444 : profit_strong ? #FF6F00 : profit_caution ? #FFA726 : profit_watch ? #555555 : #1B5E20
    table.cell(info_tbl, 0, 11, "  Profit Book",  text_color=#AAAAAA, bgcolor=row_bg, text_size=size.small, text_halign=text.align_left)
    table.cell(info_tbl, 1, 11, pb_txt + "  ", text_color=color.white, bgcolor=pb_col, text_size=size.small, text_halign=text.align_left)

    // Row 12 — Market breadth status
    breadth_txt = not use_breadth ? "OFF" : breadth_score >= 3 ? "DANGER (S4 / climax)" : breadth_score == 2 ? "WEAK (caution)" : breadth_score == 1 ? "warning" : "healthy"
    breadth_col = not use_breadth ? #444444 : breadth_score >= 3 ? #C62828 : breadth_score == 2 ? #E65100 : breadth_score == 1 ? #FB8C00 : #1B5E20
    table.cell(info_tbl, 0, 12, "  Market",      text_color=#AAAAAA, bgcolor=row_bg, text_size=size.small, text_halign=text.align_left)
    table.cell(info_tbl, 1, 12, breadth_txt + "  ", text_color=color.white, bgcolor=breadth_col, text_size=size.small, text_halign=text.align_left)

// ─────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────

alertcondition(alert_breakout  and vol_confirmed_breakout, title="Stage 2 Breakout (Vol Confirmed)", message="{{ticker}} - Stage 2 breakout on high volume. Weinstein BUY signal.")
alertcondition(alert_breakout  and s1_to_s2_breakout,      title="Stage 2 Breakout",                 message="{{ticker}} - Stage 2 breakout. Monitor closely.")
alertcondition(alert_top       and s2_to_s3_top,           title="Stage 3 Top Entry",                message="{{ticker}} - Transitioning to Stage 3. Begin selling longs.")
alertcondition(alert_breakdown and s3_to_s4_breakdown,     title="Stage 4 Breakdown",                message="{{ticker}} - Stage 4 breakdown. Exit longs. Short opportunity.")
alertcondition(s4_to_s1_basing,                            title="Stage 1 Basing",                   message="{{ticker}} - Stage 4 decline basing. Consider covering shorts.")
alertcondition(alert_profit and profit_strong_fire,        title="STRONG Profit Booking Signal",     message="{{ticker}} - Multiple Stage 2 exhaustion signals detected. BOOK PROFIT.")
alertcondition(alert_profit and profit_caution_fire,       title="Profit Booking Caution",           message="{{ticker}} - Stage 2 weakening. Consider trimming position / tightening stops.")

// ─────────────────────────────────────────────────────────────────
//  DATA WINDOW
// ─────────────────────────────────────────────────────────────────

plot(stage,            title="Stage (1-4)",       display=display.data_window, color=color.new(color.gray, 100))
plot(stage_confidence, title="Stage Confidence",  display=display.data_window, color=color.new(color.gray, 100))
plot(ma_val,           title="SMA Value",         display=display.data_window, color=color.new(color.gray, 100))
plot(ma_slope_pct,     title="MA Slope %",        display=display.data_window, color=color.new(color.gray, 100))
plot(rs_performance,   title="RS vs Nifty %",     display=display.data_window, color=color.new(color.gray, 100))
````

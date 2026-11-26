# Waterfall Risk Composite

- url: https://www.tradingview.com/script/AGNN73m1-Waterfall-Risk-Composite/
- type: indicator
- pine_id: PUB;0f2f0bbd788b4e0c812e72f9a984e615
- version: 1.0

## Description

Waterfall Risk Composite (WRC)
The Waterfall Risk Composite is a quantitative short-side risk scoring system that detects the structural conditions that precede cascading selloff events — what traders call a "waterfall." Rather than identifying entry points, it measures how dangerous a stock's current environment is across three independent dimensions, combining them into a single 0–100 score.
What is a Waterfall Event?

A waterfall is a rapid, cascading price decline where selling pressure overwhelms buyers across multiple sessions. These events don't appear randomly — they are typically preceded by months of distribution, deteriorating relative strength, a collapsing MA structure, and expanding downside volatility. The WRC is designed to quantify exactly those preconditions.

How the Score is Built
The composite draws from three sub-scores, each capturing a different dimension of bearish risk:
1. Distribution Phase (max 35 pts)

Measures how aggressively a stock is being distributed relative to its benchmark. Inputs include the slope and persistence of relative strength (RS) vs XJO or SPY, the rolling up/down volume ratio over 20 sessions, and how far price has corrected from its 52-week high. A stock that has been underperforming its index for months, with more volume on down days than up days, and sitting 30–40% off its highs, will score near the maximum here.
2. Momentum Decay (max 40 pts)

Scores the structural deterioration of price momentum. This block carries the highest weighting because entrenched bear trends are the most reliable precondition for waterfall events. It measures the fast/slow EMA ratio slope (MOMO), the full bearish ordering of the 10/21/50/200 EMA stack (death cross zone scores maximum), how far and for how long price has been below the 200 EMA, and the number of consecutive days price has spent below the 40 EMA. A stock with a full bear MA stack, 150+ days below its 40 EMA, and deeply extended below its 200 EMA can score 40/40 on this block alone.
3. Volatility Stress (max 25 pts)

Detects volatility regime shifts and directional pressure. Scores the ratio of fast to slow ATR (expanding vol = stress), the proportion of ATR occurring on red candles vs green (asymmetric downside vol), and large red candles relative to the 20-day average body size — particularly when they break below a recent swing low, signalling acceleration.

Trend Gates — Soft Multiplier System

Three structural conditions act as gates that scale the final score:

Close below the 10-period Monthly MA
5 EMA below 10 EMA (daily)
Close below 40 EMA (daily)

Unlike a hard on/off switch, gates apply a proportional multiplier: all three passing = full score, two passing = 75%, one passing = 40%, none passing = score blocked entirely. This means a deeply bearish stock with a brief EMA cross-back won't suddenly drop to zero — the underlying deterioration is still reflected.

Settings

All key parameters are adjustable — RS lookback, volume window, ATR periods, gate EMA lengths, monthly MA length, alert thresholds, and table position. The indicator works on daily timeframes and above.
Alerts

Three alert conditions are included: Waterfall threshold crossed, Elevated threshold crossed, and risk declining back below Elevated.

Any ideas let me know. It's good but can be better.

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════════════
// WATERFALL RISK COMPOSITE  •  Pine Script v6
// ═══════════════════════════════════════════════════════════════════════════
// Score 0–100  •  >70 = Elevated  •  >85 = Waterfall
//
// SUB-SCORES:
//   1. DISTRIBUTION PHASE  (RS deterioration, volume, correction depth)  max 35
//   2. MOMENTUM DECAY      (MOMO, MA stack, 200MA, streak duration)      max 40
//   3. VOLATILITY STRESS   (ATR expansion, asymmetry, candle signal)     max 25
//
// TREND GATES — soft multiplier:
//   3/3=100%  2/3=75%  1/3=40%  0/3=blocked
// ═══════════════════════════════════════════════════════════════════════════
//@version=6
indicator("Waterfall Risk Composite", shorttitle="WRC", overlay=false, max_bars_back=500)

// ── INPUTS ───────────────────────────────────────────────────────────────────
grp1 = "Distribution Phase"
rs_len       = input.int(126, "RS Lookback (bars)",           group=grp1, minval=10)
vol_len      = input.int(20,  "Up/Dn Volume Window",          group=grp1, minval=5)
bo_len       = input.int(20,  "Breakout High Window (bars)",  group=grp1, minval=5)
bo_fail_bars = input.int(5,   "Breakout Fail Confirm (bars)", group=grp1, minval=1)

grp2 = "Momentum Decay"
momo_fast = input.int(10,  "MOMO Fast MA",   group=grp2, minval=2)
momo_slow = input.int(30,  "MOMO Slow MA",   group=grp2, minval=5)
ma200_len = input.int(200, "Trend MA Length", group=grp2, minval=20)

grp3 = "Volatility Stress"
atr_fast = input.int(5,  "ATR Fast", group=grp3, minval=1)
atr_slow = input.int(20, "ATR Slow", group=grp3, minval=5)

grp4 = "Trend Gates"
monthly_ma_len = input.int(10, "Monthly MA Length", group=grp4, minval=1)
ema5_len       = input.int(5,  "Fast EMA (daily)",  group=grp4, minval=1)
ema10_len      = input.int(10, "Mid EMA (daily)",   group=grp4, minval=2)
ema40_len      = input.int(40, "Slow EMA (daily)",  group=grp4, minval=5)

grp5 = "Benchmark"
use_xjo = input.bool(true, "Prefer XJO for ASX stocks (over SPY)", group=grp5)

grp6 = "Display"
show_components = input.bool(true, "Show Component Scores",   group=grp6)
show_signals    = input.bool(true, "Show Alert Levels",       group=grp6)
thresh_elevated = input.int(70,    "Elevated Risk Threshold", group=grp6, minval=1, maxval=99)
thresh_high     = input.int(85,    "High Risk Threshold",     group=grp6, minval=1, maxval=99)
tbl_pos         = input.string("Top Right", "Table Position", group=grp6, options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])

// ═══════════════════════════════════════════════════════════════════════════
// TREND GATES
// ═══════════════════════════════════════════════════════════════════════════
[monthly_close, monthly_ma] = request.security(syminfo.tickerid, "M", [close, ta.ema(close, monthly_ma_len)], lookahead=barmerge.lookahead_off)
gate_monthly = monthly_close < monthly_ma

ema5_daily  = request.security(syminfo.tickerid, "D", ta.ema(close, ema5_len),  lookahead=barmerge.lookahead_off)
ema10_daily = request.security(syminfo.tickerid, "D", ta.ema(close, ema10_len), lookahead=barmerge.lookahead_off)
ema40_daily = request.security(syminfo.tickerid, "D", ta.ema(close, ema40_len), lookahead=barmerge.lookahead_off)
close_daily = request.security(syminfo.tickerid, "D", close,                    lookahead=barmerge.lookahead_off)

gate_ema_stack = ema5_daily < ema10_daily
gate_ema40     = close_daily < ema40_daily

gates_passed   = (gate_monthly ? 1 : 0) + (gate_ema_stack ? 1 : 0) + (gate_ema40 ? 1 : 0)
gate_mult      = gates_passed == 3 ? 1.00 : gates_passed == 2 ? 0.75 : gates_passed == 1 ? 0.40 : 0.0
all_gates_open = gates_passed >= 1

// ═══════════════════════════════════════════════════════════════════════════
// BENCHMARK
// ═══════════════════════════════════════════════════════════════════════════
[xjo_close, xjo_ok] = request.security("ASX:XJO", timeframe.period, [close, barstate.isconfirmed], ignore_invalid_symbol=true)
[spy_close, spy_ok] = request.security("AMEX:SPY", timeframe.period, [close, barstate.isconfirmed], ignore_invalid_symbol=true)

bench_close = (use_xjo and xjo_ok) ? xjo_close : spy_ok ? spy_close : na
bench_ok    = (use_xjo and xjo_ok) or spy_ok
bench_label = (use_xjo and xjo_ok) ? "vs XJO" : spy_ok ? "vs SPY" : "no bench"

price = close
vol   = volume
h     = high

// ═══════════════════════════════════════════════════════════════════════════
// BLOCK 1 — DISTRIBUTION PHASE  (max 35 pts)
// ═══════════════════════════════════════════════════════════════════════════

// 1a. RS deterioration vs benchmark  (0–15 pts)
// FIX: removed rs_div (rarely fires in full bear — both price & RS fall together)
// Now scores purely on slope and persistence below RS MA
rs_raw        = bench_ok ? price / bench_close : na
rs_norm_base  = bench_ok ? rs_raw[rs_len] : na
rs_norm       = (bench_ok and not na(rs_norm_base) and rs_norm_base != 0) ? rs_raw / rs_norm_base : na
rs_ma         = ta.ema(rs_norm, rs_len)
rs_slope_pct  = (bench_ok and not na(rs_norm) and not na(rs_norm[rs_len])) ? (rs_norm - rs_norm[rs_len]) / math.abs(rs_norm[rs_len]) * 100 : 0.0
rs_below_raw  = math.sum(rs_norm < rs_ma ? 1.0 : 0.0, rs_len)
rs_days_below = not na(rs_norm) ? rs_below_raw : 0.0
rs_pct_below  = rs_days_below / rs_len * 100
// RS level vs 1yr ago — sustained underperformance
rs_1yr_chg    = (bench_ok and not na(rs_norm) and not na(rs_norm[252])) ? (rs_norm - rs_norm[252]) / math.abs(rs_norm[252]) * 100 : 0.0

score_rs = 0.0
score_rs := (rs_slope_pct < -5.0 ? 6.0 : rs_slope_pct < -2.0 ? 4.0 : rs_slope_pct < -0.5 ? 2.0 : 0.0) + (rs_pct_below > 80.0 ? 5.0 : rs_pct_below > 65.0 ? 3.0 : rs_pct_below > 50.0 ? 1.0 : 0.0) + (rs_1yr_chg < -10.0 ? 4.0 : rs_1yr_chg < -5.0 ? 2.0 : 0.0)
score_rs := math.min(score_rs, 15.0)

// 1b. Up/Down Volume Ratio  (0–10 pts)
// FIX: loosened thresholds — 0.76 now scores, not zero
up_vol   = vol * (close > open ? 1.0 : close > close[1] ? 0.5 : 0.0)
dn_vol   = vol * (close < open ? 1.0 : close < close[1] ? 0.5 : 0.0)
sum_up   = math.sum(up_vol, vol_len)
sum_dn   = math.sum(dn_vol, vol_len)
ud_ratio = sum_up / math.max(sum_dn, 1)

score_vol = ud_ratio < 0.60 ? 10.0 : ud_ratio < 0.70 ? 8.0 : ud_ratio < 0.80 ? 6.0 : ud_ratio < 0.90 ? 3.0 : ud_ratio < 1.00 ? 1.0 : 0.0

// 1c. Correction depth from ATH/52W high  (0–10 pts)
// FIX: replaces failed-breakout-only scoring with always-on correction depth
high_52w     = ta.highest(high, 252)
corr_pct     = (price - high_52w) / high_52w * 100

score_corr = corr_pct < -40.0 ? 10.0 : corr_pct < -30.0 ? 8.0 : corr_pct < -20.0 ? 6.0 : corr_pct < -15.0 ? 4.0 : corr_pct < -10.0 ? 2.0 : 0.0

// 1d. Failed Breakout bonus  (0–5 pts, additive on top)
bo_high = ta.highest(h[1], bo_len)
is_bo   = h >= bo_high
var int bars_since_bo = na
bars_since_bo := is_bo ? 0 : na(bars_since_bo) ? na : bars_since_bo + 1
failed_bo = not na(bars_since_bo) and bars_since_bo <= bo_fail_bars and close < bo_high
score_bo  = failed_bo ? 5.0 : 0.0

score_dist = math.min(score_rs + score_vol + score_corr + score_bo, 35.0)

// ═══════════════════════════════════════════════════════════════════════════
// BLOCK 2 — MOMENTUM DECAY  (max 40 pts)
// ═══════════════════════════════════════════════════════════════════════════

// 2a. MOMO slope  (0–10 pts)
ema_fast_d = request.security(syminfo.tickerid, "D", ta.ema(close, momo_fast), lookahead=barmerge.lookahead_off)
ema_slow_d = request.security(syminfo.tickerid, "D", ta.ema(close, momo_slow), lookahead=barmerge.lookahead_off)
momo_val   = ema_fast_d / ema_slow_d
momo_slope = momo_val - momo_val[10]

score_momo = momo_slope < -0.005 ? 10.0 : momo_slope < -0.002 ? 7.0 : momo_slope < -0.001 ? 4.0 : momo_slope < 0.0 ? 1.0 : 0.0

// 2b. MA stack — bearish ordering  (0–13 pts)
ema10_d  = request.security(syminfo.tickerid, "D", ta.ema(close, 10),  lookahead=barmerge.lookahead_off)
ema21_d  = request.security(syminfo.tickerid, "D", ta.ema(close, 21),  lookahead=barmerge.lookahead_off)
ema50_d  = request.security(syminfo.tickerid, "D", ta.ema(close, 50),  lookahead=barmerge.lookahead_off)
ema200_d = request.security(syminfo.tickerid, "D", ta.ema(close, 200), lookahead=barmerge.lookahead_off)

ma_bear1 = close_daily < ema10_d ? 2.0 : 0.0
ma_bear2 = ema10_d < ema21_d     ? 3.0 : 0.0
ma_bear3 = ema21_d < ema50_d     ? 3.0 : 0.0
ma_bear4 = ema50_d < ema200_d    ? 5.0 : 0.0

score_ma_stack = math.min(ma_bear1 + ma_bear2 + ma_bear3 + ma_bear4, 13.0)

// 2c. Distance AND duration below 200MA  (0–10 pts)
ma200        = ta.ema(price, ma200_len)
dist_200_pct = (price - ma200) / ma200 * 100
days_below_200 = math.sum(close < ma200 ? 1.0 : 0.0, 60)
pct_below_200  = days_below_200 / 60.0 * 100

score_streak = (dist_200_pct < -10.0 and pct_below_200 > 70.0) ? 10.0 : dist_200_pct < -15.0 ? 8.0 : dist_200_pct < -10.0 ? 6.0 : dist_200_pct < -5.0 ? 3.0 : dist_200_pct < 0.0 ? 1.0 : 0.0

// 2d. Downtrend streak duration below 40 EMA  (0–7 pts)
streak_below_40 = math.sum(close_daily < ema40_daily ? 1.0 : 0.0, 252)
score_duration  = streak_below_40 > 150 ? 7.0 : streak_below_40 > 100 ? 5.0 : streak_below_40 > 60 ? 3.0 : streak_below_40 > 30 ? 1.0 : 0.0

score_momo_total = math.min(score_momo + score_ma_stack + score_streak + score_duration, 40.0)

// ═══════════════════════════════════════════════════════════════════════════
// BLOCK 3 — VOLATILITY STRESS  (max 25 pts)
// ═══════════════════════════════════════════════════════════════════════════

// 3a. ATR Ratio fast vs slow  (0–8 pts)
atr_f     = ta.atr(atr_fast)
atr_s     = ta.atr(atr_slow)
atr_ratio = atr_f / atr_s

score_atr_ratio = atr_ratio > 2.0 ? 8.0 : atr_ratio > 1.5 ? 5.0 : atr_ratio > 1.2 ? 3.0 : atr_ratio > 1.0 ? 1.0 : 0.0

// 3b. ATR Directional Asymmetry  (0–7 pts)
dn_day   = close < open
atr_down = dn_day ? atr_f : 0.0
atr_asym = math.sum(atr_down, vol_len) / math.max(math.sum(atr_f, vol_len), 0.0001)

score_atr_asym = atr_asym > 0.70 ? 7.0 : atr_asym > 0.60 ? 5.0 : atr_asym > 0.50 ? 3.0 : atr_asym > 0.40 ? 1.0 : 0.0

// 3c. Large red candle relative to recent range  (0–10 pts)
body_size  = math.abs(close - open)
avg_body   = ta.sma(math.abs(close[1] - open[1]), 20)
body_ratio = body_size / math.max(avg_body, 0.0001)
swing_low  = ta.lowest(low[1], 20)
broke_low  = low < swing_low

score_candle = (close < open and body_ratio > 1.5 and broke_low) ? 10.0 : (close < open and body_ratio > 1.5) ? 6.0 : (close < open and broke_low) ? 4.0 : (close < open and body_ratio > 1.2) ? 2.0 : 0.0

score_vol_total = math.min(score_atr_ratio + score_atr_asym + score_candle, 25.0)

// ═══════════════════════════════════════════════════════════════════════════
// COMPOSITE
// ═══════════════════════════════════════════════════════════════════════════
wrc_raw    = math.min(score_dist + score_momo_total + score_vol_total, 100.0)
wrc        = math.round(wrc_raw * gate_mult)
wrc_smooth = ta.ema(wrc, 3)

wrc_color = not all_gates_open ? color.new(#555555, 0) : wrc_smooth >= thresh_high ? color.new(#ff1f1f, 0) : wrc_smooth >= thresh_elevated ? color.new(#ff6600, 0) : wrc_smooth >= 50 ? color.new(#ffaa00, 0) : wrc_smooth >= 35 ? color.new(#ddcc00, 0) : wrc_smooth >= 20 ? color.new(#88aa44, 0) : color.new(#444444, 0)

// ═══════════════════════════════════════════════════════════════════════════
// PLOTTING
// ═══════════════════════════════════════════════════════════════════════════
var c_high_bg = color.new(#ff3b3b, 92)
var c_elev_bg = color.new(#ff8c00, 92)
var c_gate_bg = color.new(#555555, 96)

bgcolor(show_signals and wrc_smooth >= thresh_high ? c_high_bg : na, title="High Risk Zone")
bgcolor(show_signals and wrc_smooth >= thresh_elevated and wrc_smooth < thresh_high ? c_elev_bg : na, title="Elevated Risk Zone")
bgcolor(not all_gates_open ? c_gate_bg : na, title="Gates Blocked")

hline(thresh_high,     "Waterfall",      color=color.new(#ff3b3b, 50), linestyle=hline.style_dashed, linewidth=1)
hline(thresh_elevated, "Elevated",       color=color.new(#ff8c00, 50), linestyle=hline.style_dashed, linewidth=1)
hline(50,              "Breakdown Risk", color=color.new(#444444, 0),  linestyle=hline.style_dotted, linewidth=1)
hline(0,               "",               color=color.new(#333333, 0))
hline(100,             "",               color=color.new(#333333, 0))

plot(show_components and all_gates_open ? score_dist       : na, "Distribution",      color=color.new(#c8ff00, 60), style=plot.style_area, linewidth=1)
plot(show_components and all_gates_open ? score_momo_total : na, "Momentum Decay",    color=color.new(#00aaff, 60), style=plot.style_area, linewidth=1)
plot(show_components and all_gates_open ? score_vol_total  : na, "Volatility Stress", color=color.new(#ff8c00, 60), style=plot.style_area, linewidth=1)
plot(wrc_smooth, "WRC Score", color=wrc_color, linewidth=2)

cross_high     = ta.crossover(wrc_smooth, thresh_high)
cross_elevated = ta.crossover(wrc_smooth, thresh_elevated)
cross_down     = ta.crossunder(wrc_smooth, thresh_elevated)

plotshape(show_signals and cross_high, title="Waterfall Cross", style=shape.circle, location=location.absolute, color=#ff1f1f, size=size.small)
plotshape(show_signals and cross_elevated and wrc_smooth < thresh_high, title="Elevated Cross", style=shape.circle, location=location.absolute, color=#ff6600, size=size.small)

// ═══════════════════════════════════════════════════════════════════════════
// TABLE
// ═══════════════════════════════════════════════════════════════════════════
var table t = na
tbl_position = tbl_pos == "Top Left" ? position.top_left : tbl_pos == "Bottom Right" ? position.bottom_right : tbl_pos == "Bottom Left" ? position.bottom_left : position.top_right

gate_color(cond) =>
    cond ? color.new(#44aa44, 0) : color.new(#ff3b3b, 0)

gate_mult_label = gates_passed == 3 ? "100%" : gates_passed == 2 ? "75%" : gates_passed == 1 ? "40%" : "0%"

regime_label = not all_gates_open ? "✗ BLOCKED" : wrc_smooth >= thresh_high ? "⚡ WATERFALL" : wrc_smooth >= thresh_elevated ? "▼ ELEVATED" : wrc_smooth >= 50 ? "▽ BREAKDOWN RISK" : wrc_smooth >= 35 ? "◈ DISTRIBUTION" : wrc_smooth >= 20 ? "◦ WATCH" : "— NO SIGNAL"
regime_color = not all_gates_open ? color.new(#555555, 0) : wrc_smooth >= thresh_high ? color.new(#ff1f1f, 0) : wrc_smooth >= thresh_elevated ? color.new(#ff6600, 0) : wrc_smooth >= 50 ? color.new(#ffaa00, 0) : wrc_smooth >= 35 ? color.new(#ddcc00, 0) : wrc_smooth >= 20 ? color.new(#88aa44, 0) : color.new(#444444, 0)

if barstate.islast
    t := table.new(tbl_position, 2, 14, bgcolor=color.new(#111111, 0), border_color=color.new(#333333, 0), border_width=1, frame_color=color.new(#333333, 0), frame_width=1)
    table.cell(t, 0, 0,  "WATERFALL RISK",   text_color=color.new(#555555, 0), text_size=size.small, bgcolor=color.new(#0a0a0a, 0))
    table.cell(t, 1, 0,  bench_label,         text_color=color.new(#444444, 0), text_size=size.tiny,  bgcolor=color.new(#0a0a0a, 0))
    table.cell(t, 0, 1,  "WRC Score",         text_color=color.new(#888888, 0), text_size=size.small)
    table.cell(t, 1, 1,  str.tostring(math.round(wrc_smooth, 1)) + " / 100", text_color=regime_color, text_size=size.small, text_font_family=font.family_monospace)
    table.cell(t, 0, 2,  "Regime",            text_color=color.new(#888888, 0), text_size=size.small)
    table.cell(t, 1, 2,  regime_label,        text_color=regime_color, text_size=size.small)
    table.cell(t, 0, 3,  "── TREND GATES ──", text_color=color.new(#444444, 0), text_size=size.tiny, bgcolor=color.new(#0a0a0a, 0))
    table.cell(t, 1, 3,  gate_mult_label,     text_color=color.new(#666666, 0), text_size=size.tiny, bgcolor=color.new(#0a0a0a, 0))
    table.cell(t, 0, 4,  "< 10M MA",          text_color=color.new(#888888, 0), text_size=size.small)
    table.cell(t, 1, 4,  gate_monthly   ? "✓ PASS" : "✗ FAIL", text_color=gate_color(gate_monthly),   text_size=size.small, text_font_family=font.family_monospace)
    table.cell(t, 0, 5,  "5 EMA < 10 EMA",   text_color=color.new(#888888, 0), text_size=size.small)
    table.cell(t, 1, 5,  gate_ema_stack ? "✓ PASS" : "✗ FAIL", text_color=gate_color(gate_ema_stack), text_size=size.small, text_font_family=font.family_monospace)
    table.cell(t, 0, 6,  "Close < 40 EMA",   text_color=color.new(#888888, 0), text_size=size.small)
    table.cell(t, 1, 6,  gate_ema40     ? "✓ PASS" : "✗ FAIL", text_color=gate_color(gate_ema40),     text_size=size.small, text_font_family=font.family_monospace)
    table.cell(t, 0, 7,  "── SCORES ──",     text_color=color.new(#444444, 0), text_size=size.tiny, bgcolor=color.new(#0a0a0a, 0))
    table.cell(t, 1, 7,  "",                 text_color=color.new(#444444, 0), text_size=size.tiny, bgcolor=color.new(#0a0a0a, 0))
    table.cell(t, 0, 8,  "Distribution",     text_color=color.new(#888888, 0), text_size=size.small)
    table.cell(t, 1, 8,  str.tostring(math.round(score_dist, 1)) + " / 35",       text_color=color.new(#c8ff00, 0), text_size=size.small, text_font_family=font.family_monospace)
    table.cell(t, 0, 9,  "Momo Decay",       text_color=color.new(#888888, 0), text_size=size.small)
    table.cell(t, 1, 9,  str.tostring(math.round(score_momo_total, 1)) + " / 40", text_color=color.new(#00aaff, 0), text_size=size.small, text_font_family=font.family_monospace)
    table.cell(t, 0, 10, "Vol Stress",       text_color=color.new(#888888, 0), text_size=size.small)
    table.cell(t, 1, 10, str.tostring(math.round(score_vol_total, 1)) + " / 25",  text_color=color.new(#ff8c00, 0), text_size=size.small, text_font_family=font.family_monospace)
    table.cell(t, 0, 11, "MA Stack",         text_color=color.new(#888888, 0), text_size=size.small)
    table.cell(t, 1, 11, str.tostring(math.round(score_ma_stack, 1)) + " / 13",   text_color=color.new(#aa88ff, 0), text_size=size.small, text_font_family=font.family_monospace)
    table.cell(t, 0, 12, "Streak Days",      text_color=color.new(#888888, 0), text_size=size.small)
    table.cell(t, 1, 12, str.tostring(math.round(streak_below_40, 0)) + "d",      text_color=color.new(#888888, 0), text_size=size.small, text_font_family=font.family_monospace)
    table.cell(t, 0, 13, "Gate Mult",        text_color=color.new(#888888, 0), text_size=size.small)
    table.cell(t, 1, 13, gate_mult_label,    text_color=color.new(#666666, 0), text_size=size.small, text_font_family=font.family_monospace)

// ═══════════════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════════════
alertcondition(cross_high,     title="WRC — Waterfall Trigger",    message="⚡ Waterfall Risk crossed WATERFALL threshold ({{ticker}} | WRC: {{plot_0}})")
alertcondition(cross_elevated, title="WRC — Elevated Risk Trigger", message="▼ Waterfall Risk crossed ELEVATED threshold ({{ticker}} | WRC: {{plot_0}})")
alertcondition(cross_down,     title="WRC — Risk Declining",        message="◦ Waterfall Risk dropped below ELEVATED ({{ticker}} | WRC: {{plot_0}})")
````

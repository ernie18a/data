# VWAP Scalper [Neural Edge]

- url: https://www.tradingview.com/script/8DyYCIaS-VWAP-Scalper-Neural-Edge/
- type: indicator
- pine_id: PUB;b023a9d70622474c880b09581d67494e
- version: 1.0

## Description

VWAP Scalper is a precision intraday indicator built for fast-moving markets. It combines three institutional-grade components under the hood to produce clean BUY and SELL signals directly
   on your chart.

  How It Works

  The indicator measures three things on every bar:

  • Volume-Weighted Delta — tracks whether buying or selling pressure is dominant by weighting candle closes against volume relative to recent average. Tells you who is in control.

  • VWAP Position — price location relative to the session VWAP. Above = buyers in control. Below = sellers in control.

  • Velocity & Acceleration — measures the speed and momentum of price movement normalised by ATR. Filters out slow, indecisive moves and only triggers on genuine momentum.

  A signal fires only when at least 2 out of 3 components agree (67% confidence) or all 3 agree (91% confidence). You can control this threshold in settings.

  Filters

  Session Filter — restricts signals to London (08:00–17:00 UTC) and New York (13:30–22:00 UTC) sessions only, avoiding low-liquidity periods.

  15-minute VWAP Bias — checks the higher timeframe trend. Long signals are only taken when the 15m chart is above its VWAP, short signals only when below. This keeps you trading with the
  macro flow.

  What You See on the Chart

  • BUY / SELL label on the signal bar
  • Entry line (blue dashed)
  • Stop Loss line (yellow) — sized by ATR multiplier
  • TP1, TP2, TP3 lines (green, progressively brighter)
  • All lines automatically disappear when SL or TP3 is hit
  • Dashboard (top right) showing live signal direction, probability, session status, 15m bias, and all three component readings

  Best Timeframes

  1m to 5m for pure scalping. 3m is the sweet spot. Works on any highly liquid instrument — Gold, Silver, NAS100, DJ30, Oil, BTC, ETH.

  How to Use

  1. Wait for a BUY or SELL label to appear
  2. Enter at market or on the next bar open
  3. Place your stop at the yellow SL line
  4. Take partial profit at TP1, move stop to entry, let the rest run to TP2 and TP3
  5. If lines disappear, the trade is concluded — wait for the next signal

  Recommended Settings

  Min Confidence: 67% & 91% — best balance of frequency and quality
  SL Size: 1.5× ATR — adjust tighter on Gold/indices, wider on crypto
  Session Filter: ON
  15m Bias: ON

## Source Code

````pine
//@version=5
indicator("VWAP Scalper [Neural Edge]", overlay=true, max_labels_count=500, max_bars_back=500)

// ─── Inputs ───────────────────────────────────────────────────────────────
smooth      = input.int(3,     "Smoothing",               minval=1,   maxval=10,  group="Core")
vel_len     = input.int(3,     "Velocity Period (bars)",  minval=1,   maxval=10,  group="Core")
band_mult   = input.float(1.5, "VWAP Band (× ATR)",      minval=0.5, maxval=4.0, step=0.25,  group="Core")
vel_thresh  = input.float(0.15,"Min Velocity Strength",  minval=0.05,maxval=1.0, step=0.05,  group="Core")
min_conf    = input.string("67% & 91%", "Min Confidence",options=["91% only","67% & 91%","All signals (34%+)"], group="Core")
cooldown    = input.int(10,    "Min Bars Between Signals",minval=1,   maxval=50,  group="Core")

use_session = input.bool(true, "Session Filter  (London 08-17 + NY 13-22 UTC)", group="Filters")
use_htf     = input.bool(true, "15m VWAP Bias   (macro trend alignment)",       group="Filters")

atr_mult    = input.float(1.5, "SL Size (× ATR)",        minval=0.5, maxval=10.0, step=0.25, group="Risk")
show_table  = input.bool(true, "Show Dashboard",  group="Visual")
show_labels = input.bool(true, "Show Labels",     group="Visual")

// ─── Base ─────────────────────────────────────────────────────────────────
atr      = ta.atr(14)
vwap_val = ta.vwap
vwap_up  = vwap_val + band_mult * atr
vwap_dn  = vwap_val - band_mult * atr

// ─── Session Filter (UTC) ─────────────────────────────────────────────────
in_london  = not na(time(timeframe.period, "0800-1700:23456", "UTC+0"))
in_ny      = not na(time(timeframe.period, "1330-2200:23456", "UTC+0"))
in_session = not use_session or (in_london or in_ny)

// ─── 15m VWAP Bias Filter ─────────────────────────────────────────────────
htf_close = request.security(syminfo.tickerid, "15", close,   lookahead=barmerge.lookahead_off)
htf_vwap  = request.security(syminfo.tickerid, "15", ta.vwap, lookahead=barmerge.lookahead_off)
htf_bull  = not use_htf or htf_close > htf_vwap
htf_bear  = not use_htf or htf_close < htf_vwap

// ─── Component 1: Volume-Weighted Delta ───────────────────────────────────
c_range   = math.max(high - low, syminfo.mintick)
raw_delta = ((close - low) - (high - close)) / c_range
avg_vol   = ta.sma(volume, 20)
vol_ratio = na(volume) or avg_vol == 0 ? 1.0 : math.min(volume / avg_vol, 3.0)
cvd       = ta.ema(raw_delta * vol_ratio, smooth)

// ─── Component 2: VWAP Position ───────────────────────────────────────────
vwap_score = (close - vwap_val) / math.max(atr, syminfo.mintick)

// ─── Component 3: Velocity & Acceleration ─────────────────────────────────
velocity = ta.ema((close - close[vel_len]) / math.max(atr, syminfo.mintick), smooth)
accel    = velocity - velocity[vel_len]

// ─── Confluence ───────────────────────────────────────────────────────────
bull_cvd  = cvd > 0.1
bull_vwap = vwap_score > 0
bull_vel  = velocity >  vel_thresh
bear_cvd  = cvd < -0.1
bear_vwap = vwap_score < 0
bear_vel  = velocity < -vel_thresh

bull_n   = (bull_cvd ? 1 : 0) + (bull_vwap ? 1 : 0) + (bull_vel ? 1 : 0)
bear_n   = (bear_cvd ? 1 : 0) + (bear_vwap ? 1 : 0) + (bear_vel ? 1 : 0)

get_prob(n) => n == 3 ? 91 : n == 2 ? 67 : 34
bull_prob = get_prob(bull_n)
bear_prob = get_prob(bear_n)

// ─── Confidence Filter ────────────────────────────────────────────────────
min_n = min_conf == "91% only" ? 3 : min_conf == "67% & 91%" ? 2 : 1

// ─── Cooldown Counter ─────────────────────────────────────────────────────
var int bars_since = 999
bars_since := bars_since + 1
ok_to_fire  = bars_since >= cooldown

// ─── Raw Signals ──────────────────────────────────────────────────────────
rev_zone     = atr * 0.3
rev_long     = close <= vwap_dn + rev_zone and cvd > cvd[1] and accel > 0 and bull_n >= min_n
rev_short    = close >= vwap_up - rev_zone and cvd < cvd[1] and accel < 0 and bear_n >= min_n

mom_long     = (ta.crossover(close, vwap_val) or (close > vwap_val and ta.crossover(cvd, 0.2))) and bull_n >= min_n
mom_short    = (ta.crossunder(close, vwap_val) or (close < vwap_val and ta.crossunder(cvd, -0.2))) and bear_n >= min_n

// BOUNCE: tightened — requires CVD to be meaningfully strong (> 0.25), not just accelerating
bounce_long  = close > vwap_dn and close < vwap_val + atr * 0.4 and
               cvd > cvd[1] and cvd[1] > cvd[2] and cvd > 0.25 and bull_n >= min_n

bounce_short = close < vwap_up and close > vwap_val - atr * 0.4 and
               cvd < cvd[1] and cvd[1] < cvd[2] and cvd < -0.25 and bear_n >= min_n

// Apply cooldown and filters
long_sig  = (rev_long  or mom_long  or bounce_long)  and in_session and htf_bull and ok_to_fire
short_sig = (rev_short or mom_short or bounce_short) and in_session and htf_bear and ok_to_fire

// Reset cooldown counter when signal fires
if long_sig or short_sig
    bars_since := 0

// ─── Plots ────────────────────────────────────────────────────────────────
plot(vwap_val, "VWAP",       color=color.new(color.white, 10), linewidth=1)
p_up = plot(vwap_up, "Upper Band", color=color.new(color.green, 40), linewidth=1)
p_dn = plot(vwap_dn, "Lower Band", color=color.new(color.red,   40), linewidth=1)
fill(p_up, p_dn, title="VWAP Zone", color=color.new(color.blue, 95))

bgcolor(long_sig       ? color.new(color.green, 88) : na, title="Long Bar")
bgcolor(short_sig      ? color.new(color.red,   88) : na, title="Short Bar")
bgcolor(not in_session ? color.new(color.gray,  95) : na, title="Dead Session")

// ─── Signal Labels (BUY / SELL only) ─────────────────────────────────────
if show_labels
    if long_sig
        label.new(bar_index, low - atr * 0.5, "BUY",
                  color=color.new(color.lime, 10), textcolor=color.black,
                  style=label.style_label_up, size=size.small)
    if short_sig
        label.new(bar_index, high + atr * 0.5, "SELL",
                  color=color.new(color.red, 10), textcolor=color.white,
                  style=label.style_label_down, size=size.small)

// ─── SL / TP Lines ────────────────────────────────────────────────────────
var line  line_entry = na
var line  line_sl    = na
var line  line_tp1   = na
var line  line_tp2   = na
var line  line_tp3   = na
var label lbl_sl     = na
var label lbl_tp1    = na
var label lbl_tp2    = na
var label lbl_tp3    = na

// Track active levels for HIT detection
var float lvl_sl     = na
var float lvl_tp1    = na
var float lvl_tp2    = na
var float lvl_tp3    = na
var int   sig_dir    = 0      // 1 = long, -1 = short
var bool  trade_open = false

clear_lines() =>
    line.delete(line_entry)
    line.delete(line_sl)
    line.delete(line_tp1)
    line.delete(line_tp2)
    line.delete(line_tp3)
    label.delete(lbl_sl)
    label.delete(lbl_tp1)
    label.delete(lbl_tp2)
    label.delete(lbl_tp3)

if long_sig or short_sig
    clear_lines()

    sl_dist    = atr * atr_mult
    entry_p    = close
    sig_dir   := long_sig ? 1 : -1
    trade_open := true

    lvl_sl  := long_sig ? entry_p - sl_dist      : entry_p + sl_dist
    lvl_tp1 := long_sig ? entry_p + sl_dist       : entry_p - sl_dist
    lvl_tp2 := long_sig ? entry_p + sl_dist * 2.0 : entry_p - sl_dist * 2.0
    lvl_tp3 := long_sig ? entry_p + sl_dist * 3.0 : entry_p - sl_dist * 3.0

    line_entry := line.new(bar_index, entry_p, bar_index + 1, entry_p,
         extend=extend.right, color=color.new(color.blue, 20),
         style=line.style_dashed, width=1)

    line_sl := line.new(bar_index, lvl_sl, bar_index + 1, lvl_sl,
         extend=extend.right, color=color.new(color.yellow, 10),
         style=line.style_solid, width=2)

    line_tp1 := line.new(bar_index, lvl_tp1, bar_index + 1, lvl_tp1,
         extend=extend.right, color=color.new(color.green, 55),
         style=line.style_dotted, width=1)

    line_tp2 := line.new(bar_index, lvl_tp2, bar_index + 1, lvl_tp2,
         extend=extend.right, color=color.new(color.green, 25),
         style=line.style_dotted, width=2)

    line_tp3 := line.new(bar_index, lvl_tp3, bar_index + 1, lvl_tp3,
         extend=extend.right, color=color.new(color.green, 0),
         style=line.style_dotted, width=2)

    lbl_sl  := label.new(bar_index + 1, lvl_sl,
         "  SL  " + str.tostring(math.round(lvl_sl, 2)),
         color=color.new(color.yellow, 10), textcolor=color.black,
         style=label.style_label_right, size=size.small)

    lbl_tp1 := label.new(bar_index + 1, lvl_tp1,
         "  TP1  " + str.tostring(math.round(lvl_tp1, 2)),
         color=color.new(color.green, 55), textcolor=color.white,
         style=label.style_label_right, size=size.small)

    lbl_tp2 := label.new(bar_index + 1, lvl_tp2,
         "  TP2  " + str.tostring(math.round(lvl_tp2, 2)),
         color=color.new(color.green, 25), textcolor=color.white,
         style=label.style_label_right, size=size.small)

    lbl_tp3 := label.new(bar_index + 1, lvl_tp3,
         "  TP3  " + str.tostring(math.round(lvl_tp3, 2)),
         color=color.new(color.green, 0), textcolor=color.white,
         style=label.style_label_right, size=size.small)

// ─── Line Cleanup (clear when SL or TP3 is hit) ──────────────────────────
if trade_open and not na(lvl_sl)
    is_long = sig_dir == 1

    if (is_long ? low <= lvl_sl : high >= lvl_sl)
        trade_open := false
        clear_lines()

    if trade_open and (is_long ? high >= lvl_tp3 : low <= lvl_tp3)
        trade_open := false
        clear_lines()

// ─── Dashboard Table ──────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 11,
     frame_color=color.new(color.gray, 40), frame_width=1,
     border_color=color.new(color.gray, 65), border_width=1)

if show_table
    is_bull  = bull_n >= bear_n
    dir_str  = bull_n > bear_n ? "LONG   ▲" : bear_n > bull_n ? "SHORT  ▼" : "NEUTRAL —"
    prob_str = bull_n > bear_n ? str.tostring(bull_prob) + "%" : bear_n > bull_n ? str.tostring(bear_prob) + "%" : "—"
    dir_col  = bull_n > bear_n ? color.new(color.green, 10) : bear_n > bull_n ? color.new(color.red, 10) : color.new(color.gray, 30)
    cvd_ok   = is_bull ? bull_cvd  : bear_cvd
    vwap_ok  = is_bull ? bull_vwap : bear_vwap
    vel_ok   = is_bull ? bull_vel  : bear_vel
    sess_str = in_session ? "✅  Active" : "🔴  Closed"
    sess_col = in_session ? color.new(color.teal, 40) : color.new(color.gray, 60)
    htf_str  = htf_bull ? "✅  Bull" : "🔴  Bear"
    htf_col  = htf_bull ? color.new(color.green, 50) : color.new(color.red, 50)

    bg0 = color.new(color.navy, 15)
    bg1 = color.new(color.gray, 60)
    bg2 = color.new(color.gray, 75)
    tc  = color.white
    tc2 = color.silver
    ts  = size.small

    table.cell(dash, 0, 0,  "VWAP SCALPER",                        bgcolor=bg0, text_color=tc,  text_size=ts)
    table.cell(dash, 1, 0,  "[Neural Edge]",                       bgcolor=bg0, text_color=tc2, text_size=ts)
    table.cell(dash, 0, 1,  "Signal",                              bgcolor=bg1, text_color=tc2, text_size=ts)
    table.cell(dash, 1, 1,  dir_str,                               bgcolor=dir_col, text_color=tc, text_size=ts)
    table.cell(dash, 0, 2,  "Probability",                         bgcolor=bg1, text_color=tc2, text_size=ts)
    table.cell(dash, 1, 2,  prob_str,                              bgcolor=dir_col, text_color=tc, text_size=ts)
    table.cell(dash, 0, 3,  "Session",                             bgcolor=bg2, text_color=tc2, text_size=ts)
    table.cell(dash, 1, 3,  sess_str,                              bgcolor=sess_col, text_color=tc, text_size=ts)
    table.cell(dash, 0, 4,  "15m Bias",                            bgcolor=bg2, text_color=tc2, text_size=ts)
    table.cell(dash, 1, 4,  htf_str,                               bgcolor=htf_col, text_color=tc, text_size=ts)
    table.cell(dash, 0, 5,  "Vol Delta",                           bgcolor=bg2, text_color=tc2, text_size=ts)
    table.cell(dash, 1, 5,  cvd_ok  ? "✅  Bull" : "❌  Bear",    bgcolor=bg2, text_color=tc,  text_size=ts)
    table.cell(dash, 0, 6,  "VWAP Side",                           bgcolor=bg2, text_color=tc2, text_size=ts)
    table.cell(dash, 1, 6,  vwap_ok ? "✅  Bull" : "❌  Bear",    bgcolor=bg2, text_color=tc,  text_size=ts)
    table.cell(dash, 0, 7,  "Velocity",                            bgcolor=bg2, text_color=tc2, text_size=ts)
    table.cell(dash, 1, 7,  vel_ok  ? "✅  Bull" : "❌  Bear",    bgcolor=bg2, text_color=tc,  text_size=ts)
    table.cell(dash, 0, 8,  "ATR",                                 bgcolor=bg2, text_color=tc2, text_size=ts)
    table.cell(dash, 1, 8,  str.tostring(math.round(atr, 2)),      bgcolor=bg2, text_color=tc,  text_size=ts)
    table.cell(dash, 0, 9,  "VWAP",                                bgcolor=bg2, text_color=tc2, text_size=ts)
    table.cell(dash, 1, 9,  str.tostring(math.round(vwap_val, 2)), bgcolor=bg2, text_color=tc,  text_size=ts)
    table.cell(dash, 0, 10, "15m VWAP",                            bgcolor=bg2, text_color=tc2, text_size=ts)
    table.cell(dash, 1, 10, str.tostring(math.round(htf_vwap, 2)), bgcolor=bg2, text_color=tc,  text_size=ts)
````

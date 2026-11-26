# Indicator V!

- url: https://www.tradingview.com/script/cJ0Hjmh9-Indicator-V/
- type: indicator
- pine_id: PUB;6a7d57348e304e818a5f51f37b5afa74
- version: 1.0

## Description

Full indicator Reads live as you go. Buy in and scale in when it tells you to. Wait until it really confirms. Never trade under 3 out of 10.

## Source Code

````pine
//@version=6
indicator("Smart Zones v4", overlay=true, max_bars_back=2000)

// ==========================================
// SMART ZONES v4 — CLEAN CHART
// ==========================================
// PHILOSOPHY: The chart is the trigger finger.
// The backend is the brain. The Telegram is the story.
//
// ON CHART:
//   - Clean structure lines (PDH/PDL, opens, FVG zones)
//   - One label per signal: LONG 8/10 or SHORT 6/10
//   - Color = conviction. That's it.
//   - Box detection draws the box, no text
//   - Panel: 6 cells only. Scores + session + conflict
//
// OFF CHART (Python backend):
//   - Options flow, dark pool, news risk
//   - Claude reasoning
//   - Telegram message with full context
// ==========================================

// ── INPUTS ──
atr_length    = input.int(14,    title="ATR Length",               group="Core")
displace_mult = input.float(1.5, title="Engulfing Size (x ATR)",   group="Core")
bb_length     = input.int(20,    title="Liquidity Lookback",        group="Core")
liq_tolerance = input.float(0.1, title="EQ Hi/Lo Tolerance (%)",   group="Core", step=0.05)
sl_atr_mult   = input.float(1.0, title="SL (x ATR)",               group="Core")

box_bars      = input.int(24,    title="Box Min Bars",              group="Structure", minval=8, maxval=100)
box_atr_mult  = input.float(1.5, title="Box Max Height (x ATR)",   group="Structure", step=0.1)
htf_fvg_min   = input.float(0.03,title="Min FVG Size (% price)",   group="Structure", step=0.01)
pdhl_atr      = input.float(1.0, title="PDH/PDL Range (x ATR)",    group="Structure", step=0.1)

min_score     = input.int(4,     title="Min Score to Show Signal",  group="Filter", minval=0, maxval=10)
htf_tf        = input.timeframe("15", title="HTF Timeframe",        group="Filter")
htf_bb        = input.int(10,    title="HTF Lookback",              group="Filter", minval=5, maxval=50)
vol_mult      = input.float(1.5, title="Volume Spike (x avg)",      group="Filter", step=0.1)
vol_length    = input.int(20,    title="Volume MA Length",           group="Filter")

session_ny    = input.bool(true, title="NY (9:30–11:30 ET)",        group="Session")
session_lon   = input.bool(true, title="London (3:00–5:00 ET)",     group="Session")
session_req   = input.bool(true, title="Session Filter On",         group="Session")

corr_symbol   = input.symbol("ES1!", title="Corr Pair",             group="Correlation")
corr_on       = input.bool(true,     title="ES Correlation On",     group="Correlation")
rs_length     = input.int(20,        title="RS Lookback",           group="Correlation", minval=5, maxval=100)
vix_on        = input.bool(true,     title="VIX Filter On",         group="Correlation")

// ── SESSION ──
ny_session  = time(timeframe.period, "0930-1130", "America/New_York")
lon_session = time(timeframe.period, "0300-0500", "America/New_York")
in_ny       = not na(ny_session)
in_lon      = not na(lon_session)
in_session  = (session_ny and in_ny) or (session_lon and in_lon)

bgcolor(session_req and not in_session ? color.new(color.gray, 95) : na)

// Subtle session open marker — just a vertical line, no label clutter
ny_open  = in_ny  and not in_ny[1]
lon_open = in_lon and not in_lon[1]
if ny_open
    line.new(bar_index, low * 0.999, bar_index, high * 1.001,
         color=color.new(color.blue, 60), width=1, style=line.style_dashed)
if lon_open
    line.new(bar_index, low * 0.999, bar_index, high * 1.001,
         color=color.new(color.purple, 60), width=1, style=line.style_dashed)

// ── CORE ──
atr_val      = ta.atr(atr_length)
avg_vol      = ta.sma(volume, vol_length)
vol_spike    = volume >= avg_vol * vol_mult
vol_ratio    = avg_vol > 0 ? math.round((volume / avg_vol) * 10) / 10 : 0.0
body_size    = math.abs(close - open)
candle_range = high - low
close_str    = candle_range > 0 ? (close - low) / candle_range : 0.5

bull_engulf = body_size >= atr_val * displace_mult and close > open
     and close_str >= 0.65 and close > open[1] and open < close[1] and vol_spike

bear_engulf = body_size >= atr_val * displace_mult and close < open
     and close_str <= 0.35 and close < open[1] and open > close[1] and vol_spike

// ── STRUCTURE LEVELS — lines only, minimal labels ──
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)
weekly_open = request.security(syminfo.tickerid, "W", open, lookahead=barmerge.lookahead_on)
daily_open  = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)

var line pdh_line = na
var line pdl_line = na
var line wo_line  = na
var line do_line  = na
var label pdh_lbl = na
var label pdl_lbl = na
var label wo_lbl  = na
var label do_lbl  = na

if barstate.islast
    if not na(pdh_line)
        line.delete(pdh_line)
    if not na(pdl_line)
        line.delete(pdl_line)
    if not na(wo_line)
        line.delete(wo_line)
    if not na(do_line)
        line.delete(do_line)
    if not na(pdh_lbl)
        label.delete(pdh_lbl)
    if not na(pdl_lbl)
        label.delete(pdl_lbl)
    if not na(wo_lbl)
        label.delete(wo_lbl)
    if not na(do_lbl)
        label.delete(do_lbl)

    pdh_line := line.new(bar_index - 200, pdh, bar_index + 15, pdh,
         color=color.new(color.red, 40), width=1, style=line.style_dashed)
    pdl_line := line.new(bar_index - 200, pdl, bar_index + 15, pdl,
         color=color.new(color.green, 40), width=1, style=line.style_dashed)
    wo_line  := line.new(bar_index - 200, weekly_open, bar_index + 15, weekly_open,
         color=color.new(color.purple, 30), width=2, style=line.style_solid)
    do_line  := line.new(bar_index - 200, daily_open, bar_index + 15, daily_open,
         color=color.new(color.blue, 40), width=1, style=line.style_dashed)

    // Tiny right-side labels only — price and name, nothing else
    pdh_lbl := label.new(bar_index + 15, pdh, text="PDH",
         color=color.new(color.red, 60), textcolor=color.new(color.red, 20),
         style=label.style_label_left, size=size.tiny, yloc=yloc.price)
    pdl_lbl := label.new(bar_index + 15, pdl, text="PDL",
         color=color.new(color.green, 60), textcolor=color.new(color.green, 20),
         style=label.style_label_left, size=size.tiny, yloc=yloc.price)
    wo_lbl  := label.new(bar_index + 15, weekly_open, text="W",
         color=color.new(color.purple, 60), textcolor=color.new(color.purple, 10),
         style=label.style_label_left, size=size.tiny, yloc=yloc.price)
    do_lbl  := label.new(bar_index + 15, daily_open, text="D",
         color=color.new(color.blue, 60), textcolor=color.new(color.blue, 10),
         style=label.style_label_left, size=size.tiny, yloc=yloc.price)

// ── 1H FVG — shaded zone only ──
h1_high  = request.security(syminfo.tickerid, "60", high[1],  lookahead=barmerge.lookahead_off)
h1_low   = request.security(syminfo.tickerid, "60", low[1],   lookahead=barmerge.lookahead_off)
h1_high2 = request.security(syminfo.tickerid, "60", high[2],  lookahead=barmerge.lookahead_off)
h1_low2  = request.security(syminfo.tickerid, "60", low[2],   lookahead=barmerge.lookahead_off)

fvg_min_1h  = close * (htf_fvg_min / 100)
h1_bull_fvg = h1_low > h1_high2 and (h1_low - h1_high2) >= fvg_min_1h
h1_bear_fvg = h1_high < h1_low2 and (h1_low2 - h1_high) >= fvg_min_1h
h1_bull_pts = h1_bull_fvg ? math.round(h1_low - h1_high2) : 0
h1_bear_pts = h1_bear_fvg ? math.round(h1_low2 - h1_high) : 0
var float h1_bull_mid = na
var float h1_bear_mid = na

if h1_bull_fvg
    h1_bull_mid := math.round((h1_low + h1_high2) / 2)
    box.new(bar_index - 1, h1_low, bar_index + 60, h1_high2,
         border_color=color.new(color.green, 70),
         bgcolor=color.new(color.green, 92), border_width=1, extend=extend.right)

if h1_bear_fvg
    h1_bear_mid := math.round((h1_low2 + h1_high) / 2)
    box.new(bar_index - 1, h1_low2, bar_index + 60, h1_high,
         border_color=color.new(color.red, 70),
         bgcolor=color.new(color.red, 92), border_width=1, extend=extend.right)

// ── DAILY FVG — slightly more prominent ──
d_high  = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_off)
d_low   = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_off)
d_high2 = request.security(syminfo.tickerid, "D", high[2],  lookahead=barmerge.lookahead_off)
d_low2  = request.security(syminfo.tickerid, "D", low[2],   lookahead=barmerge.lookahead_off)

fvg_min_d  = close * (htf_fvg_min / 100)
d_bull_fvg = d_low > d_high2 and (d_low - d_high2) >= fvg_min_d
d_bear_fvg = d_high < d_low2 and (d_low2 - d_high) >= fvg_min_d
d_bull_pts = d_bull_fvg ? math.round(d_low - d_high2) : 0
d_bear_pts = d_bear_fvg ? math.round(d_low2 - d_high) : 0
var float d_bull_mid = na
var float d_bear_mid = na

daily_bear_kills_h1_bull = h1_bull_fvg and d_bear_fvg and d_bear_pts >= h1_bull_pts * 1.5 and math.abs(d_high - close) <= 300
daily_bull_kills_h1_bear = h1_bear_fvg and d_bull_fvg and d_bull_pts >= h1_bear_pts * 1.5 and math.abs(d_low  - close) <= 300

if d_bull_fvg
    d_bull_mid := math.round((d_low + d_high2) / 2)
    box.new(bar_index - 1, d_low, bar_index + 80, d_high2,
         border_color=color.new(color.teal, 50),
         bgcolor=color.new(color.teal, 88), border_width=1, extend=extend.right)
    // Single tiny label on the midpoint line only
    line.new(bar_index - 1, d_bull_mid, bar_index + 80, d_bull_mid,
         color=color.new(color.teal, 30), width=1, style=line.style_dotted)

if d_bear_fvg
    d_bear_mid := math.round((d_low2 + d_high) / 2)
    box.new(bar_index - 1, d_low2, bar_index + 80, d_high,
         border_color=color.new(color.maroon, 50),
         bgcolor=color.new(color.maroon, 88), border_width=1, extend=extend.right)
    line.new(bar_index - 1, d_bear_mid, bar_index + 80, d_bear_mid,
         color=color.new(color.maroon, 30), width=1, style=line.style_dotted)

// ── 5M FVG — lightest shading ──
fvg_min  = close * 0.0005
bull_fvg = low > high[2] and (low - high[2]) >= fvg_min
bear_fvg = high < low[2] and (low[2] - high) >= fvg_min

var float last_bull_top = na
var float last_bull_bot = na
var float last_bear_top = na
var float last_bear_bot = na
var int   bull_fvg_bar  = na
var int   bear_fvg_bar  = na

if bull_fvg
    last_bull_top := low
    last_bull_bot := high[2]
    bull_fvg_bar  := bar_index
    box.new(bar_index - 2, low, bar_index + 40, high[2],
         border_color=color.new(color.green, 80),
         bgcolor=color.new(color.green, 94), border_width=1, extend=extend.right)

if bear_fvg
    last_bear_top := low[2]
    last_bear_bot := high
    bear_fvg_bar  := bar_index
    box.new(bar_index - 2, low[2], bar_index + 40, high,
         border_color=color.new(color.red, 80),
         bgcolor=color.new(color.red, 94), border_width=1, extend=extend.right)

// ── BOX DETECTION — zone only, no labels ──
box_high_raw = ta.highest(high, box_bars)
box_low_raw  = ta.lowest(low,  box_bars)
box_height   = box_high_raw - box_low_raw
is_ranging   = box_height <= atr_val * box_atr_mult

var float range_high  = na
var float range_low   = na
var bool  in_range    = false
var int   range_start = 0

if is_ranging and not is_ranging[1]
    in_range    := true
    range_high  := box_high_raw
    range_low   := box_low_raw
    range_start := bar_index

if in_range and is_ranging
    range_high := math.max(range_high, high)
    range_low  := math.min(range_low,  low)

box_bull_break = in_range and close > range_high and open < range_high and body_size >= atr_val * 0.5
box_bear_break = in_range and close < range_low  and open > range_low  and body_size >= atr_val * 0.5

// Draw the box — yellow zone, no text
if is_ranging and (bar_index - range_start) >= box_bars and not is_ranging[1]
    box.new(range_start, range_high, bar_index, range_low,
         border_color=color.new(color.yellow, 50),
         bgcolor=color.new(color.yellow, 94),
         border_width=1, extend=extend.right)

if box_bull_break or box_bear_break
    in_range := false

// ── LIQUIDITY ──
prev_high    = ta.highest(high, bb_length)[1]
prev_low     = ta.lowest(low,  bb_length)[1]
tol          = close * (liq_tolerance / 100)
local_high_5 = ta.highest(high, 5)
local_low_5  = ta.lowest(low,  5)
bos_high_10  = ta.highest(high, 10)[1]
bos_low_10   = ta.lowest(low,  10)[1]

eq_high = math.abs(high - prev_high) <= tol and high == local_high_5
eq_low  = math.abs(low  - prev_low)  <= tol and low  == local_low_5
high_swept = high[1] >= prev_high and close < prev_high
low_swept  = low[1]  <= prev_low  and close > prev_low

// EQ levels — thin dashes, no labels
if eq_high
    line.new(bar_index - bb_length, high, bar_index + 15, high,
         color=color.new(color.orange, 30), width=1, style=line.style_dashed)
if eq_low
    line.new(bar_index - bb_length, low, bar_index + 15, low,
         color=color.new(color.orange, 30), width=1, style=line.style_dashed)

// ── HTF BIAS — score only ──
htf_high      = request.security(syminfo.tickerid, htf_tf, high,                        lookahead=barmerge.lookahead_off)
htf_low       = request.security(syminfo.tickerid, htf_tf, low,                         lookahead=barmerge.lookahead_off)
htf_close     = request.security(syminfo.tickerid, htf_tf, close,                       lookahead=barmerge.lookahead_off)
htf_prev_high = request.security(syminfo.tickerid, htf_tf, ta.highest(high, htf_bb)[1], lookahead=barmerge.lookahead_off)
htf_prev_low  = request.security(syminfo.tickerid, htf_tf, ta.lowest(low,  htf_bb)[1], lookahead=barmerge.lookahead_off)

htf_high_swept = htf_high[1] >= htf_prev_high and htf_close < htf_prev_high
htf_low_swept  = htf_low[1]  <= htf_prev_low  and htf_close > htf_prev_low

var int htf_bias = 0
if htf_high_swept
    htf_bias := -1
if htf_low_swept
    htf_bias :=  1

// ── CORRELATION ──
[corr_open, corr_high, corr_low, corr_close] = request.security(corr_symbol, timeframe.period,
     [open, high, low, close], lookahead=barmerge.lookahead_off)

corr_prev_high = request.security(corr_symbol, timeframe.period,
     ta.highest(high, bb_length)[1], lookahead=barmerge.lookahead_off)
corr_prev_low  = request.security(corr_symbol, timeframe.period,
     ta.lowest(low, bb_length)[1],  lookahead=barmerge.lookahead_off)

corr_high_swept = corr_high[1] >= corr_prev_high and corr_close < corr_prev_high
corr_low_swept  = corr_low[1]  <= corr_prev_low  and corr_close > corr_prev_low
conv_long  = corr_on and corr_low_swept
conv_short = corr_on and corr_high_swept

nq_ret = close / close[rs_length] - 1
es_ret = corr_close / corr_close[rs_length] - 1
rs_val = nq_ret - es_ret

// ── VIX ──
vix_close   = request.security("VIX", "D", close,    lookahead=barmerge.lookahead_off)
vix_prev    = request.security("VIX", "D", close[1], lookahead=barmerge.lookahead_off)
vix_rising  = vix_on and vix_close > vix_prev
vix_falling = vix_on and vix_close < vix_prev
vix_extreme = vix_on and vix_close > 30

// ── STRUCTURE PROXIMITY ──
near_pdh = math.abs(close - pdh) <= atr_val * pdhl_atr
near_pdl = math.abs(close - pdl) <= atr_val * pdhl_atr
near_wo  = math.abs(close - weekly_open) <= atr_val * 1.5
near_do  = math.abs(close - daily_open)  <= atr_val * 1.5
near_h1_bull = not na(h1_bull_mid) and math.abs(close - h1_bull_mid) <= atr_val
near_h1_bear = not na(h1_bear_mid) and math.abs(close - h1_bear_mid) <= atr_val
near_d_bull  = not na(d_bull_mid)  and math.abs(close - d_bull_mid)  <= atr_val * 1.5
near_d_bear  = not na(d_bear_mid)  and math.abs(close - d_bear_mid)  <= atr_val * 1.5

at_structure_long  = near_pdl or near_wo or near_do or near_h1_bull or near_d_bull
at_structure_short = near_pdh or near_wo or near_do or near_h1_bear or near_d_bear

// Structure + engulfing flip
res_flip_long  = bull_engulf and at_structure_long
res_flip_short = bear_engulf and at_structure_short

// FVG engulfing entry
fvg_bull_entry = not na(last_bull_top) and not na(bull_fvg_bar)
     and (bar_index - bull_fvg_bar) <= 50
     and close >= last_bull_bot and close <= last_bull_top
     and bull_engulf

fvg_bear_entry = not na(last_bear_top) and not na(bear_fvg_bar)
     and (bar_index - bear_fvg_bar) <= 50
     and close >= last_bear_bot and close <= last_bear_top
     and bear_engulf

if fvg_bull_entry
    last_bull_top := na
    last_bull_bot := na
if fvg_bear_entry
    last_bear_top := na
    last_bear_bot := na

// ── SWEEP COUNT ──
proj_bars         = 30
swing_high_anchor = ta.highest(high, proj_bars)
swing_low_anchor  = ta.lowest(low,  proj_bars)

var int long_sweep_count  = 0
var int short_sweep_count = 0

if high >= swing_high_anchor and long_sweep_count > 0
    long_sweep_count := 0
if low <= swing_low_anchor and short_sweep_count > 0
    short_sweep_count := 0
if low_swept
    long_sweep_count  := long_sweep_count + 1
    short_sweep_count := 0
if high_swept
    short_sweep_count := short_sweep_count + 1
    long_sweep_count  := 0

// ── DUAL CONFLUENCE SCORE ──
long_score = 0
long_score := long_score + (htf_bias == 1 ? 1 : 0)
long_score := long_score + (in_session ? 1 : 0)
long_score := long_score + (vol_spike ? 1 : 0)
long_score := long_score + (conv_long ? 1 : 0)
long_score := long_score + (rs_val > 0 ? 1 : 0)
long_score := long_score + (h1_bull_fvg and not daily_bear_kills_h1_bull ? 1 : 0)
long_score := long_score + (d_bull_fvg ? 1 : 0)
long_score := long_score + (near_pdl ? 1 : 0)
long_score := long_score + (vix_falling ? 1 : 0)
long_score := long_score + (long_sweep_count >= 2 ? 1 : 0)
long_score := long_score + (at_structure_long ? 1 : 0)
long_score := long_score + (res_flip_long ? 2 : 0)
long_score := long_score + (fvg_bull_entry ? 2 : 0)
long_score  := math.min(long_score, 10)

short_score = 0
short_score := short_score + (htf_bias == -1 ? 1 : 0)
short_score := short_score + (in_session ? 1 : 0)
short_score := short_score + (vol_spike ? 1 : 0)
short_score := short_score + (conv_short ? 1 : 0)
short_score := short_score + (rs_val < 0 ? 1 : 0)
short_score := short_score + (h1_bear_fvg and not daily_bull_kills_h1_bear ? 1 : 0)
short_score := short_score + (d_bear_fvg ? 1 : 0)
short_score := short_score + (near_pdh ? 1 : 0)
short_score := short_score + (vix_rising ? 1 : 0)
short_score := short_score + (short_sweep_count >= 2 ? 1 : 0)
short_score := short_score + (at_structure_short ? 1 : 0)
short_score := short_score + (res_flip_short ? 2 : 0)
short_score := short_score + (fvg_bear_entry ? 2 : 0)
short_score  := math.min(short_score, 10)

// Conflict + contrarian
conflict_flag    = (bull_fvg and high_swept) or (bear_fvg and low_swept)
contrarian_long  = short_score <= 3 and long_score  >= 5
contrarian_short = long_score  <= 3 and short_score >= 5

// ── 5M BIAS ──
var int bias = 0
if high_swept
    bias := -1
if low_swept
    bias :=  1

// ── WATCH LEVELS — dead zone navigation ──
// When both scores are below min_score, nothing is firing.
// Draw the nearest level above and below price that WOULD trigger a signal.
// Show next session open time so you know exactly when to be ready.
//
// Logic:
//   Watch HIGH = nearest resistance above price (PDH → weekly open → daily FVG top → prev_high)
//   Watch LOW  = nearest support below price  (PDL → weekly open → daily FVG bot → prev_low)
//   Next session = how many hours until NY open (9:30 ET) or London open (3:00 ET)
//
// Clears automatically the moment a real signal fires.

dead_zone = long_score < min_score and short_score < min_score

// Find nearest watch level above price
watch_high = math.min(
     pdh > close ? pdh : 999999,
     weekly_open > close ? weekly_open : 999999,
     not na(d_bear_mid) and d_bear_mid > close ? d_bear_mid : 999999,
     prev_high > close ? prev_high : 999999)

// Find nearest watch level below price
watch_low = math.max(
     pdl < close ? pdl : 0,
     weekly_open < close ? weekly_open : 0,
     not na(d_bull_mid) and d_bull_mid < close ? d_bull_mid : 0,
     prev_low < close ? prev_low : 0)

// Next session timing
// Pine gives us bar time in UTC milliseconds
// NY open = 13:30 UTC, London open = 08:00 UTC
bar_hour    = hour(time, "UTC")
bar_minute  = minute(time, "UTC")
bar_mins_utc = bar_hour * 60 + bar_minute

ny_open_utc  = 13 * 60 + 30   // 13:30 UTC = 9:30 ET
lon_open_utc = 8  * 60 + 0    // 08:00 UTC = 3:00 ET

// Minutes until next session
mins_to_ny  = bar_mins_utc <= ny_open_utc  ? ny_open_utc  - bar_mins_utc : (24 * 60) - bar_mins_utc + ny_open_utc
mins_to_lon = bar_mins_utc <= lon_open_utc ? lon_open_utc - bar_mins_utc : (24 * 60) - bar_mins_utc + lon_open_utc

// Pick the sooner session
mins_to_next = math.min(mins_to_ny, mins_to_lon)
next_sess_name = mins_to_ny <= mins_to_lon ? "NY 9:30" : "LON 3:00"

// Format time remaining
hours_left = math.floor(mins_to_next / 60)
mins_left  = mins_to_next - hours_left * 60
time_txt   = hours_left > 0 ? str.tostring(hours_left) + "h " + str.tostring(mins_left) + "m" : str.tostring(mins_left) + "m"

// Draw watch levels only in dead zone, only on last bar
var line  watch_high_line  = na
var line  watch_low_line   = na
var label watch_high_label = na
var label watch_low_label  = na

if barstate.islast
    if not na(watch_high_line)
        line.delete(watch_high_line)
    if not na(watch_low_line)
        line.delete(watch_low_line)
    if not na(watch_high_label)
        label.delete(watch_high_label)
    if not na(watch_low_label)
        label.delete(watch_low_label)

    if dead_zone and watch_high < 999999
        watch_high_line  := line.new(bar_index - 30, watch_high, bar_index + 20, watch_high,
             color=color.new(color.yellow, 20), width=1, style=line.style_dashed)
        watch_high_label := label.new(bar_index + 20, watch_high,
             text="WATCH  " + str.tostring(math.round(watch_high)) + "  |  " + next_sess_name + " in " + time_txt,
             color=color.new(color.yellow, 10), textcolor=color.new(color.black, 0),
             style=label.style_label_left, size=size.small, yloc=yloc.price)

    if dead_zone and watch_low > 0
        watch_low_line  := line.new(bar_index - 30, watch_low, bar_index + 20, watch_low,
             color=color.new(color.yellow, 20), width=1, style=line.style_dashed)
        watch_low_label := label.new(bar_index + 20, watch_low,
             text="WATCH  " + str.tostring(math.round(watch_low)) + "  |  " + next_sess_name + " in " + time_txt,
             color=color.new(color.yellow, 10), textcolor=color.new(color.black, 0),
             style=label.style_label_left, size=size.small, yloc=yloc.price)

// ── DECISIVE VERDICT ENGINE ──
// The indicator picks a side and commits. No mixed signals on candles.
// Whichever score is higher = that's the call.
// The other side is suppressed on the chart entirely.
// Panel still shows both scores quietly so you can see the spread.
//
// Verdict logic:
//   dominant side score >= 8 + ES aligned + at structure  → "TAKE IT"
//   dominant side score >= 8, no BOS yet                  → "WAIT — BOS"
//   dominant side score 6–7 + volume                      → "VALID — SCALE IN"
//   dominant side score 6–7, conflict present             → "WAIT — VOL DECIDES"
//   dominant side score 4–5, other side <= 2              → "FADE — [other side]"
//   dominant side score 4–5, scores close (< 3pt gap)     → dead zone, watch levels
//   dominant side score 1–3                               → dead zone, watch levels

// Who's dominant — pick the higher score, need at least 1pt gap to commit
dominant_long  = long_score  > short_score
dominant_short = short_score > long_score
score_gap      = math.abs(long_score - short_score)
dominant_score = dominant_long ? long_score : short_score

// Is the dominant side actually worth calling?
// Need either: score >= 4 with a 2+ point gap, OR score >= 6 regardless of gap
worth_calling = (dominant_score >= 6) or (dominant_score >= 4 and score_gap >= 2)

// Verdict text — decisive, one line
get_verdict(side, score, has_bos_level, es_ok, at_struct, conflict, vol_ok) =>
    if conflict
        "WAIT — VOL DECIDES"
    else if score >= 8 and es_ok and at_struct
        side + " — TAKE IT"
    else if score >= 8 and not has_bos_level
        side + " — WAIT BOS"
    else if score >= 8
        side + " — TAKE IT"
    else if score >= 6 and vol_ok
        side + " — SCALE IN"
    else if score >= 6
        side + " — VALID"
    else if score >= 4
        side + " — MARGINAL"
    else
        "SKIP"

// Verdict color — committed, no ambiguity
get_verdict_color(side, score) =>
    if side == "LONG"
        score >= 8 ? color.new(color.teal, 0) : score >= 6 ? color.new(color.teal, 25) : color.new(color.teal, 50)
    else
        score >= 8 ? color.new(color.red, 0) : score >= 6 ? color.new(color.red, 25) : color.new(color.red, 50)

// BOS confirmation tracking
var bool  waiting_long_bos  = false
var bool  waiting_short_bos = false
var float bos_long_level    = na
var float bos_short_level   = na

if low_swept
    waiting_long_bos := true
    bos_long_level   := bos_high_10
if high_swept
    waiting_short_bos := true
    bos_short_level   := bos_low_10

bos_long_confirmed  = waiting_long_bos  and not na(bos_long_level)  and close > bos_long_level
bos_short_confirmed = waiting_short_bos and not na(bos_short_level) and close < bos_short_level

// ── DRAW THE VERDICT — one side only, one label ──

// LONG sweep fired — only draw if long is the dominant side
if low_swept and worth_calling and dominant_long
    v_txt = get_verdict("LONG", long_score, waiting_long_bos, conv_long, at_structure_long, conflict_flag, vol_spike)
    v_col = conflict_flag ? color.new(color.orange, 0) : get_verdict_color("LONG", long_score)
    label.new(bar_index, low,
         text=v_txt, color=v_col, textcolor=color.white,
         style=label.style_label_up, size=size.normal, yloc=yloc.belowbar)

// SHORT sweep fired — only draw if short is the dominant side
if high_swept and worth_calling and dominant_short
    v_txt = get_verdict("SHORT", short_score, waiting_short_bos, conv_short, at_structure_short, conflict_flag, vol_spike)
    v_col = conflict_flag ? color.new(color.orange, 0) : get_verdict_color("SHORT", short_score)
    label.new(bar_index, high,
         text=v_txt, color=v_col, textcolor=color.white,
         style=label.style_label_down, size=size.normal, yloc=yloc.abovebar)

// FADE signal — when one side is clearly weak, call the other direction explicitly
// e.g. short fires but long score dominates → "FADE — LONG"
if high_swept and dominant_long and long_score >= 5
    label.new(bar_index, low,
         text="FADE — LONG " + str.tostring(long_score) + "/10",
         color=color.new(color.purple, 10), textcolor=color.white,
         style=label.style_label_up, size=size.normal, yloc=yloc.belowbar)

if low_swept and dominant_short and short_score >= 5
    label.new(bar_index, high,
         text="FADE — SHORT " + str.tostring(short_score) + "/10",
         color=color.new(color.purple, 10), textcolor=color.white,
         style=label.style_label_down, size=size.normal, yloc=yloc.abovebar)

// BOS confirmed — one clean label
if bos_long_confirmed
    label.new(bar_index, low,
         text="▲ " + str.tostring(close), color=color.new(color.teal, 0),
         textcolor=color.white, style=label.style_label_up, size=size.large, yloc=yloc.belowbar)
    line.new(bar_index - 3, bos_long_level, bar_index + 2, bos_long_level,
         color=color.new(color.teal, 30), width=1, style=line.style_dashed)
    waiting_long_bos := false

if bos_short_confirmed
    label.new(bar_index, high,
         text="▼ " + str.tostring(close), color=color.new(color.maroon, 0),
         textcolor=color.white, style=label.style_label_down, size=size.large, yloc=yloc.abovebar)
    line.new(bar_index - 3, bos_short_level, bar_index + 2, bos_short_level,
         color=color.new(color.maroon, 30), width=1, style=line.style_dashed)
    waiting_short_bos := false

// Structure flip — small dot on the candle
if res_flip_long
    label.new(bar_index, low,
         text="●", color=color.new(color.lime, 0), textcolor=color.white,
         style=label.style_label_up, size=size.small, yloc=yloc.belowbar)
if res_flip_short
    label.new(bar_index, high,
         text="●", color=color.new(color.red, 0), textcolor=color.white,
         style=label.style_label_down, size=size.small, yloc=yloc.abovebar)

// FVG engulfing entry — small triangle
if fvg_bull_entry
    label.new(bar_index, low,
         text="▲", color=color.new(color.green, 0), textcolor=color.white,
         style=label.style_label_up, size=size.small, yloc=yloc.belowbar)
if fvg_bear_entry
    label.new(bar_index, high,
         text="▼", color=color.new(color.red, 0), textcolor=color.white,
         style=label.style_label_down, size=size.small, yloc=yloc.abovebar)

// Box break — clean triangle
if box_bull_break and vol_spike
    label.new(bar_index, low,
         text="▲", color=color.new(color.teal, 20), textcolor=color.white,
         style=label.style_label_up, size=size.small, yloc=yloc.belowbar)
if box_bear_break and vol_spike
    label.new(bar_index, high,
         text="▼", color=color.new(color.maroon, 20), textcolor=color.white,
         style=label.style_label_down, size=size.small, yloc=yloc.abovebar)

// Invalidation — subtle gray
var float active_buy_sl  = na
var float active_sell_sl = na
var bool  long_active    = false
var bool  short_active   = false
rsi_val  = ta.rsi(close, 14)
buy_sl   = prev_low  - (atr_val * sl_atr_mult)
sell_sl  = prev_high + (atr_val * sl_atr_mult)

if low_swept
    active_buy_sl := buy_sl
    long_active   := true
    short_active  := false
if high_swept
    active_sell_sl := sell_sl
    short_active   := true
    long_active    := false

long_invalidated  = long_active  and not na(active_buy_sl)  and close < active_buy_sl
short_invalidated = short_active and not na(active_sell_sl) and close > active_sell_sl

if long_invalidated
    label.new(bar_index, high, text="✗",
         color=color.new(color.gray, 30), textcolor=color.white,
         style=label.style_label_down, size=size.small, yloc=yloc.abovebar)
    long_active      := false
    active_buy_sl    := na
    waiting_long_bos := false

if short_invalidated
    label.new(bar_index, low, text="✗",
         color=color.new(color.gray, 30), textcolor=color.white,
         style=label.style_label_up, size=size.small, yloc=yloc.belowbar)
    short_active      := false
    active_sell_sl    := na
    waiting_short_bos := false

// TP/SL lines — clean, no labels on them
buy_tp2  = swing_high_anchor
sell_tp2 = swing_low_anchor
buy_risk = math.abs(close - buy_sl)
buy_tp1  = close + buy_risk
sell_risk = math.abs(sell_sl - close)
sell_tp1  = close - sell_risk
buy_rr   = buy_risk  > 0 ? math.round(math.abs(buy_tp2  - close) / buy_risk,  1) : 0.0
sell_rr  = sell_risk > 0 ? math.round(math.abs(close - sell_tp2) / sell_risk, 1) : 0.0

if low_swept and long_score >= min_score
    line.new(bar_index, buy_sl,  bar_index + 40, buy_sl,  color=color.new(color.red,   20), width=1, style=line.style_dashed)
    line.new(bar_index, buy_tp1, bar_index + 40, buy_tp1, color=color.new(color.teal,  40), width=1, style=line.style_dotted)
    line.new(bar_index, buy_tp2, bar_index + 40, buy_tp2, color=color.new(color.green, 20), width=2, style=line.style_solid)
    label.new(bar_index + 40, buy_tp2,
         text=str.tostring(buy_rr) + "R",
         color=color.new(color.green, 30), textcolor=color.white,
         style=label.style_label_left, size=size.tiny, yloc=yloc.price)

if high_swept and short_score >= min_score
    line.new(bar_index, sell_sl,  bar_index + 40, sell_sl,  color=color.new(color.red,   20), width=1, style=line.style_dashed)
    line.new(bar_index, sell_tp1, bar_index + 40, sell_tp1, color=color.new(color.teal,  40), width=1, style=line.style_dotted)
    line.new(bar_index, sell_tp2, bar_index + 40, sell_tp2, color=color.new(color.green, 20), width=2, style=line.style_solid)
    label.new(bar_index + 40, sell_tp2,
         text=str.tostring(sell_rr) + "R",
         color=color.new(color.green, 30), textcolor=color.white,
         style=label.style_label_left, size=size.tiny, yloc=yloc.price)

// Bias backgrounds — very subtle
bgcolor(bias ==  1 ? color.new(color.teal,   95) : na)
bgcolor(bias == -1 ? color.new(color.maroon, 95) : na)

// 2m live wick
[m2_open, m2_high, m2_low, m2_close] = request.security(syminfo.tickerid, "2",
     [open, high, low, close], lookahead=barmerge.lookahead_on)

var line lh = na
var line ll = na
var line lc = na

if barstate.islast
    if not na(lh)
        line.delete(lh)
    if not na(ll)
        line.delete(ll)
    if not na(lc)
        line.delete(lc)
    live_col = m2_close >= m2_open ? color.new(color.teal, 40) : color.new(color.red, 40)
    lh := line.new(bar_index - 1, m2_high,  bar_index + 3, m2_high,  color=live_col, width=1, style=line.style_dotted)
    ll := line.new(bar_index - 1, m2_low,   bar_index + 3, m2_low,   color=live_col, width=1, style=line.style_dotted)
    lc := line.new(bar_index - 1, m2_close, bar_index + 3, m2_close, color=live_col, width=2)

// ==========================================
// PANEL — 6 CELLS ONLY
// That's it. Everything else lives in Telegram.
// ==========================================

var table t = table.new(position.top_right, 2, 3,
     bgcolor=color.new(color.black, 50), border_width=1,
     border_color=color.new(color.gray, 60))

// Long score
ls_bg = long_score >= 8 ? color.new(color.teal, 0) : long_score >= 6 ? color.new(color.teal, 30) : long_score >= 4 ? color.new(color.teal, 55) : color.new(color.black, 60)
// Short score
ss_bg = short_score >= 8 ? color.new(color.red, 10) : short_score >= 6 ? color.new(color.red, 35) : short_score >= 4 ? color.new(color.red, 55) : color.new(color.black, 60)
// Session
sess_bg  = in_session ? color.new(color.teal, 50) : color.new(color.gray, 60)
sess_txt = in_ny ? "NY" : in_lon ? "LON" : "OFF"
// Conflict
conf_bg  = conflict_flag ? color.new(color.orange, 20) : (contrarian_long or contrarian_short) ? color.new(color.purple, 30) : color.new(color.black, 70)
conf_txt = conflict_flag ? "⚡ CONFLICT" : contrarian_long ? "↑ CONTRA" : contrarian_short ? "↓ CONTRA" : "CLEAR"
// VIX
vix_bg   = vix_extreme ? color.new(color.red, 20) : vix_rising ? color.new(color.orange, 40) : color.new(color.black, 70)
vix_txt  = "VIX " + str.tostring(math.round(vix_close, 1))
// ES
es_bg    = conv_long ? color.new(color.teal, 40) : conv_short ? color.new(color.red, 40) : color.new(color.black, 70)
es_txt   = conv_long ? "ES ✓ LONG" : conv_short ? "ES ✓ SHORT" : "ES —"

table.cell(t, 0, 0, "LONG  " + str.tostring(long_score) + "/10",  text_color=color.white, text_size=size.normal, bgcolor=ls_bg)
table.cell(t, 1, 0, "SHORT " + str.tostring(short_score) + "/10", text_color=color.white, text_size=size.normal, bgcolor=ss_bg)
table.cell(t, 0, 1, sess_txt,  text_color=color.white, text_size=size.small, bgcolor=sess_bg)
table.cell(t, 1, 1, conf_txt,  text_color=color.white, text_size=size.small, bgcolor=conf_bg)
table.cell(t, 0, 2, vix_txt,   text_color=color.white, text_size=size.small, bgcolor=vix_bg)
table.cell(t, 1, 2, es_txt,    text_color=color.white, text_size=size.small, bgcolor=es_bg)

// ==========================================
// WEBHOOK PAYLOAD — full data to Python backend
// ==========================================

alertcondition(low_swept  and long_score  >= min_score, title="Long Setup",   message="LONG SETUP")
alertcondition(high_swept and short_score >= min_score, title="Short Setup",  message="SHORT SETUP")
alertcondition(bos_long_confirmed,                      title="BOS Long",     message="BOS LONG CONFIRMED")
alertcondition(bos_short_confirmed,                     title="BOS Short",    message="BOS SHORT CONFIRMED")
alertcondition(fvg_bull_entry,                          title="FVG Long",     message="FVG LONG ENTRY")
alertcondition(fvg_bear_entry,                          title="FVG Short",    message="FVG SHORT ENTRY")
alertcondition(res_flip_long,                           title="Flip Long",    message="STRUCTURE FLIP LONG")
alertcondition(res_flip_short,                          title="Flip Short",   message="STRUCTURE FLIP SHORT")
alertcondition(box_bull_break and vol_spike,            title="Box Long",     message="BOX BREAK LONG")
alertcondition(box_bear_break and vol_spike,            title="Box Short",    message="BOX BREAK SHORT")
alertcondition(conflict_flag,                           title="Conflict",     message="CONFLICT — VOLUME DECIDES")
alertcondition(contrarian_long,                         title="Contra Long",  message="CONTRARIAN LONG")
alertcondition(contrarian_short,                        title="Contra Short", message="CONTRARIAN SHORT")
alertcondition(long_score  >= 8,                        title="MAX Long",     message="MAX CONFLUENCE LONG")
alertcondition(short_score >= 8,                        title="MAX Short",    message="MAX CONFLUENCE SHORT")

// Webhook JSON — Python backend receives this
long_json  = '{"ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","side":"LONG","price":' + str.tostring(close) + ',"long_score":' + str.tostring(long_score) + ',"short_score":' + str.tostring(short_score) + ',"es_aligned":' + str.tostring(conv_long) + ',"conflict":' + str.tostring(conflict_flag) + ',"vix":' + str.tostring(math.round(vix_close,1)) + ',"vol_ratio":' + str.tostring(vol_ratio) + ',"at_structure":' + str.tostring(at_structure_long) + ',"res_flip":' + str.tostring(res_flip_long) + ',"fvg_entry":' + str.tostring(fvg_bull_entry) + ',"box_break":' + str.tostring(box_bull_break) + ',"sweep_count":' + str.tostring(long_sweep_count) + ',"rr":' + str.tostring(buy_rr) + '}'
short_json = '{"ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","side":"SHORT","price":' + str.tostring(close) + ',"long_score":' + str.tostring(long_score) + ',"short_score":' + str.tostring(short_score) + ',"es_aligned":' + str.tostring(conv_short) + ',"conflict":' + str.tostring(conflict_flag) + ',"vix":' + str.tostring(math.round(vix_close,1)) + ',"vol_ratio":' + str.tostring(vol_ratio) + ',"at_structure":' + str.tostring(at_structure_short) + ',"res_flip":' + str.tostring(res_flip_short) + ',"fvg_entry":' + str.tostring(fvg_bear_entry) + ',"box_break":' + str.tostring(box_bear_break) + ',"sweep_count":' + str.tostring(short_sweep_count) + ',"rr":' + str.tostring(sell_rr) + '}'

alertcondition(fvg_bull_entry or res_flip_long  or box_bull_break or bos_long_confirmed,  title="WEBHOOK Long",  message="{{long_json}}")
alertcondition(fvg_bear_entry or res_flip_short or box_bear_break or bos_short_confirmed, title="WEBHOOK Short", message="{{short_json}}")
````

# Eagle Momentum

- url: https://www.tradingview.com/script/XiiiQ0Ld-Eagle-Momentum/
- type: indicator
- pine_id: PUB;f47a83a2c3f748bca2242a181c564848
- version: 1.0

## Description

Eagle Momentum of Stockedge application and its used during breakouts only and this is applicable for high momentum stocks of NSE

## Source Code

````pine
// ============================================================
//  🦅 EAGLE MOMENTUM STRATEGY — NSE (StockEdge Inspired)
//  Pine Script v6 — TradingView Compatible
//  ─────────────────────────────────────────────────────────
//  Conditions:
//    ✅ Trend       → Price > EMA(50) > SMA(200)
//    ✅ MACD        → Histogram positive & rising
//    ✅ RSI         → RSI in 50–75 bullish zone
//    ✅ Bollinger   → Price above BB midline
//    ✅ Volume      → Surge above 20-day average
//    ✅ SuperTrend  → Bullish SuperTrend
//    ✅ Rel.Strength→ Outperforming Nifty 50
// ============================================================

//@version=6
indicator("🦅 Eagle Momentum — NSE (StockEdge Style)",
          shorttitle = "Eagle Momentum",
          overlay    = true,
          max_lines_count  = 50,
          max_labels_count = 50)

// ─────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────
var GRP_TREND = "📈 Trend Settings"
var GRP_MOM   = "⚡ Momentum Settings"
var GRP_VOL   = "📊 Volume Settings"
var GRP_ST    = "🔴 SuperTrend Settings"
var GRP_BB    = "🎯 Bollinger Band Settings"
var GRP_RS    = "🔵 Relative Strength"
var GRP_DISP  = "🖥️ Display Settings"

ema_fast  = input.int(50,    "Fast EMA Period",          group = GRP_TREND)
sma_slow  = input.int(200,   "Slow SMA Period",          group = GRP_TREND)

macd_fast = input.int(12,    "MACD Fast Length",         group = GRP_MOM)
macd_slow = input.int(26,    "MACD Slow Length",         group = GRP_MOM)
macd_sig  = input.int(9,     "MACD Signal Length",       group = GRP_MOM)
rsi_len   = input.int(14,    "RSI Period",               group = GRP_MOM)
rsi_min   = input.int(50,    "RSI Min Threshold",        group = GRP_MOM)
rsi_max   = input.int(75,    "RSI Max Threshold",        group = GRP_MOM)

bb_len    = input.int(20,    "BB Period",                group = GRP_BB)
bb_mult   = input.float(2.0, "BB Multiplier",            group = GRP_BB)

vol_len   = input.int(20,    "Volume Avg Period",        group = GRP_VOL)
vol_mult  = input.float(1.2, "Volume Surge Multiplier",  group = GRP_VOL)

st_factor = input.float(3.0, "SuperTrend Factor",        group = GRP_ST)
st_atr    = input.int(10,    "SuperTrend ATR Length",    group = GRP_ST)

use_rs    = input.bool(true,        "Enable Nifty 50 RS Filter", group = GRP_RS)
nifty_sym = input.symbol("NSE:NIFTY50", "Benchmark Symbol",      group = GRP_RS)
rs_period = input.int(63,            "RS Lookback (days)",        group = GRP_RS)

show_labels = input.bool(true, "Show Signal Labels",    group = GRP_DISP)
show_table  = input.bool(true, "Show Dashboard Table",  group = GRP_DISP)
show_bb     = input.bool(true, "Show Bollinger Bands",  group = GRP_DISP)

// ─────────────────────────────────────────
//  HELPER FUNCTIONS  (must be at top scope in v6)
// ─────────────────────────────────────────
f_chk(v) =>
    v ? "✅" : "❌"

f_clr(v) =>
    v ? color.new(color.green, 65) : color.new(color.red, 65)

// ─────────────────────────────────────────
//  1. TREND FILTER — Price > EMA50 > SMA200
// ─────────────────────────────────────────
ema50      = ta.ema(close, ema_fast)
sma200     = ta.sma(close, sma_slow)
trend_bull = close > ema50 and ema50 > sma200

// ─────────────────────────────────────────
//  2. MACD MOMENTUM — Histogram positive & rising
// ─────────────────────────────────────────
[macd_line, signal_line, hist] = ta.macd(close, macd_fast, macd_slow, macd_sig)
macd_bull  = hist > 0 and hist > hist[1]
macd_cross = ta.crossover(macd_line, signal_line)

// ─────────────────────────────────────────
//  3. RSI — Bullish zone (50–75)
// ─────────────────────────────────────────
rsi_val  = ta.rsi(close, rsi_len)
rsi_bull = rsi_val >= rsi_min and rsi_val <= rsi_max

// ─────────────────────────────────────────
//  4. BOLLINGER BANDS — Price above midline
// ─────────────────────────────────────────
bb_mid   = ta.sma(close, bb_len)
bb_dev   = ta.stdev(close, bb_len) * bb_mult
bb_upper = bb_mid + bb_dev
bb_lower = bb_mid - bb_dev
bb_bull  = close > bb_mid

// ─────────────────────────────────────────
//  5. VOLUME SURGE — Volume > 1.2× 20-day avg
// ─────────────────────────────────────────
vol_avg   = ta.sma(volume, vol_len)
vol_surge = volume >= vol_avg * vol_mult
vol_ratio = volume / vol_avg

// ─────────────────────────────────────────
//  6. SUPERTREND — Bullish direction
// ─────────────────────────────────────────
[st_line, st_dir] = ta.supertrend(st_factor, st_atr)
st_bull = st_dir == -1   // -1 = bullish in Pine v6

// ─────────────────────────────────────────
//  7. RELATIVE STRENGTH vs NIFTY 50
// ─────────────────────────────────────────
nifty_close = request.security(nifty_sym, timeframe.period, close)
stock_rs    = (close / close[rs_period] - 1) * 100
nifty_rs    = (nifty_close / nifty_close[rs_period] - 1) * 100
rs_bull     = use_rs ? stock_rs > nifty_rs : true

// ─────────────────────────────────────────
//  EAGLE SCORE — Count conditions met
// ─────────────────────────────────────────
score = (trend_bull ? 1 : 0) + (macd_bull  ? 1 : 0) + (rsi_bull   ? 1 : 0) + (bb_bull    ? 1 : 0) + (vol_surge  ? 1 : 0) +(st_bull    ? 1 : 0) + (rs_bull    ? 1 : 0)
total_checks  = use_rs ? 7 : 6
perfect_match = score == total_checks
almost_there  = score >= math.round(total_checks * 0.75) and not perfect_match
eagle_signal  = perfect_match or almost_there
entry_trigger = eagle_signal and (macd_cross or macd_cross[1] or macd_cross[2] or macd_cross[3])

// ─────────────────────────────────────────
//  PLOT — EMAs, SuperTrend, Bollinger Bands
// ─────────────────────────────────────────
plot(ema50,   "EMA 50",     color = color.new(color.orange, 0), linewidth = 2)
plot(sma200,  "SMA 200",    color = color.new(color.red,    0), linewidth = 2)
plot(st_line, "SuperTrend", color = st_bull ? color.new(color.green, 20) : color.new(color.red, 20),
     linewidth = 1, style = plot.style_stepline)

p_upper = plot(show_bb ? bb_upper : na, "BB Upper", color = color.new(color.blue, 60))
p_lower = plot(show_bb ? bb_lower : na, "BB Lower", color = color.new(color.blue, 60))
plot(show_bb ? bb_mid : na,             "BB Mid",   color = color.new(color.blue, 40),
     linewidth = 1, style = plot.style_circles)
fill(p_upper, p_lower, color = color.new(color.blue, 90))

// Background shading
bgcolor(perfect_match ? color.new(color.green,  85) :
        almost_there  ? color.new(color.yellow, 88) : na,
        title = "Eagle Signal Background")

// ─────────────────────────────────────────
//  SIGNAL LABELS
// ─────────────────────────────────────────
if show_labels and perfect_match and not perfect_match[1]
    label.new(bar_index, low * 0.995,
          "🦅 EAGLE PERFECT\n" + str.tostring(score) + "/" + str.tostring(total_checks),
          style     = label.style_label_up,
          color     = color.new(color.green, 0),
          textcolor = color.white,
          size      = size.normal)

if show_labels and almost_there and not almost_there[1]
    label.new(bar_index, low * 0.995,
          "⚡ ALMOST THERE\n" + str.tostring(score) + "/" + str.tostring(total_checks),
          style     = label.style_label_up,
          color     = color.new(color.orange, 0),
          textcolor = color.white,
          size      = size.small)

// ─────────────────────────────────────────
//  DASHBOARD TABLE
// ─────────────────────────────────────────
var table dash = table.new(position.top_right, 3, 10,
     border_color = color.gray, border_width = 1,
     frame_color  = color.gray, frame_width  = 2)

if show_table and barstate.islast
    // Header
    table.cell(dash, 0, 0, "🦅 EAGLE MOMENTUM SCANNER",
               bgcolor    = color.new(color.navy, 0),
               text_color = color.white,
               text_size  = size.small,
               text_halign = text.align_center)
    table.merge_cells(dash, 0, 0, 2, 0)

    // Column headers
    table.cell(dash, 0, 1, "CONDITION",
               bgcolor = color.new(color.gray, 40), text_color = color.white, text_size = size.small)
    table.cell(dash, 1, 1, "VALUE",
               bgcolor = color.new(color.gray, 40), text_color = color.white, text_size = size.small)
    table.cell(dash, 2, 1, "STATUS",
               bgcolor = color.new(color.gray, 40), text_color = color.white, text_size = size.small)

    // Row 1 — Trend
    table.cell(dash, 0, 2, "Trend: Price > EMA50 > SMA200",
               text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 2, "EMA50=" + str.tostring(math.round(ema50, 2)),
               text_size = size.small)
    table.cell(dash, 2, 2, f_chk(trend_bull),
               bgcolor = f_clr(trend_bull), text_size = size.small)

    // Row 2 — MACD
    table.cell(dash, 0, 3, "MACD Hist: Positive & Rising",
               text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, "Hist=" + str.tostring(math.round(hist, 3)),
               text_size = size.small)
    table.cell(dash, 2, 3, f_chk(macd_bull),
               bgcolor = f_clr(macd_bull), text_size = size.small)

    // Row 3 — RSI
    table.cell(dash, 0, 4, "RSI: Bullish Zone (50–75)",
               text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 4, "RSI=" + str.tostring(math.round(rsi_val, 1)),
               text_size = size.small)
    table.cell(dash, 2, 4, f_chk(rsi_bull),
               bgcolor = f_clr(rsi_bull), text_size = size.small)

    // Row 4 — BB
    table.cell(dash, 0, 5, "BB: Price > Midline",
               text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 5, "Mid=" + str.tostring(math.round(bb_mid, 2)),
               text_size = size.small)
    table.cell(dash, 2, 5, f_chk(bb_bull),
               bgcolor = f_clr(bb_bull), text_size = size.small)

    // Row 5 — Volume
    table.cell(dash, 0, 6, "Volume Surge (>1.2× Avg)",
               text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 6, "Ratio=" + str.tostring(math.round(vol_ratio, 2)) + "x",
               text_size = size.small)
    table.cell(dash, 2, 6, f_chk(vol_surge),
               bgcolor = f_clr(vol_surge), text_size = size.small)

    // Row 6 — SuperTrend
    table.cell(dash, 0, 7, "SuperTrend: Bullish",
               text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 7, st_bull ? "Bullish ▲" : "Bearish ▼",
               text_size = size.small)
    table.cell(dash, 2, 7, f_chk(st_bull),
               bgcolor = f_clr(st_bull), text_size = size.small)

    // Row 7 — RS
    table.cell(dash, 0, 8, "Rel. Strength > Nifty 50",
               text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 8, "RS=" + str.tostring(math.round(stock_rs, 1)) + "%",
               text_size = size.small)
    table.cell(dash, 2, 8, f_chk(rs_bull),
               bgcolor = f_clr(rs_bull), text_size = size.small)

    // Score footer
    score_color = perfect_match ? color.new(color.green,  0) :
                  almost_there  ? color.new(color.orange, 0) :
                                  color.new(color.maroon, 0)
    score_label = perfect_match ? "✅ PERFECT MATCH" :
                  almost_there  ? "⚡ ALMOST THERE"  :
                                  "❌ NOT QUALIFIED"
    table.cell(dash, 0, 9,
               score_label + "  [" + str.tostring(score) + "/" + str.tostring(total_checks) + "]",
               bgcolor     = score_color,
               text_color  = color.white,
               text_size   = size.small,
               text_halign = text.align_center)
    table.merge_cells(dash, 0, 9, 2, 9)

// ─────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────
alertcondition(perfect_match and not perfect_match[1],
    title   = "🦅 Eagle Perfect Match",
    message = "🦅 EAGLE PERFECT MATCH on {{ticker}} | Score: All conditions met | Close: {{close}}")

alertcondition(almost_there and not almost_there[1],
    title   = "⚡ Eagle Almost There",
    message = "⚡ EAGLE ALMOST THERE on {{ticker}} | Strong momentum setup | Close: {{close}}")

alertcondition(entry_trigger and not entry_trigger[1],
    title   = "🔔 Eagle Entry Trigger",
    message = "🔔 EAGLE ENTRY TRIGGER on {{ticker}} | MACD Cross + Eagle signal | Close: {{close}}")

// ─────────────────────────────────────────
//  HIDDEN PLOTS (for Screener use)
// ─────────────────────────────────────────
plot(score,   "Eagle Score",  display = display.data_window)
plot(rsi_val, "RSI Value",   display = display.data_window)
plot(hist,    "MACD Hist",   display = display.data_window)
````

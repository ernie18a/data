# RSI 14-3-K Divergence [Vijay]

- url: https://www.tradingview.com/script/FwLmay2A-RSI-14-3-K-Divergence-Vijay/
- type: indicator
- pine_id: PUB;9f070c70e1a84dbeb2eb9465934fe500
- version: 1.0

## Description

Divergence strategy using custom indicator rsi143k

## Source Code

````pine
//@version=6
// ============================================================
// RSI 14-3-K Divergence Strategy — by Vijay
// Pine Script v6 | TradingView
// Timeframe: 3-min | Segment: NSE F&O
// ============================================================
// PASTE INSTRUCTIONS:
//   1. Open TradingView → Pine Script Editor (bottom panel)
//   2. Delete all existing code → paste this entire script
//   3. Click "Save" then "Add to chart"
//   4. Set chart to 3-min timeframe
// ============================================================

indicator(title        = "RSI 14-3-K Divergence [Vijay]",
          shorttitle   = "RSI143KDIV",
          overlay      = true,
          max_lines_count  = 500,
          max_labels_count = 500)

// ─────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────

var string G1 = "RSI Settings"
rsi_len   = input.int(14,  "RSI Period",        minval=5,    maxval=30,  group=G1)
k_smooth  = input.int(3,   "K Smoothing (EMA)", minval=1,    maxval=9,   group=G1)
os_level  = input.int(30,  "Oversold Level",    minval=20,   maxval=45,  group=G1)
ob_level  = input.int(70,  "Overbought Level",  minval=55,   maxval=80,  group=G1)

var string G2 = "Divergence Detection"
pivot_lb  = input.int(5,   "Pivot lookback (bars each side)", minval=2, maxval=10,  group=G2)
min_bars  = input.int(10,  "Min bars between pivots",         minval=5, maxval=30,  group=G2)
max_bars  = input.int(60,  "Max bars between pivots",         minval=20, maxval=100, group=G2)

var string G3 = "Trade Management"
show_sl   = input.bool(true,  "Show Stop Loss level",  group=G3)
show_tp   = input.bool(true,  "Show Target levels",    group=G3)
rr_t1     = input.float(1.5,  "R:R for Target 1",      minval=1.0, maxval=5.0, step=0.1, group=G3)
rr_t2     = input.float(2.5,  "R:R for Target 2",      minval=1.5, maxval=8.0, step=0.1, group=G3)

var string G4 = "Filters"
use_vwap  = input.bool(true,  "VWAP Filter (long above / short below)", group=G4)
use_vol   = input.bool(true,  "Volume Filter",                           group=G4)
vol_mult  = input.float(1.2,  "Volume multiplier",  minval=1.0, maxval=3.0, step=0.1, group=G4)
no_first15 = input.bool(true, "Skip first 15 min of session",            group=G4)

var string G5 = "Display"
bull_col  = input.color(color.new(#00C896, 0), "Bull signal color", group=G5)
bear_col  = input.color(color.new(#FF4444, 0), "Bear signal color", group=G5)

// ─────────────────────────────────────────────────────────────
// CORE CALCULATIONS
// ─────────────────────────────────────────────────────────────

// RSI and K-line (EMA of RSI = signal line)
rsi_val  = ta.rsi(close, rsi_len)
k_line   = ta.ema(rsi_val, k_smooth)

// RSI crossing K-line
rsi_cross_up   = ta.crossover(rsi_val,  k_line)
rsi_cross_down = ta.crossunder(rsi_val, k_line)

// VWAP
vwap_val = ta.vwap(hlc3)

// Volume filter
vol_avg = ta.sma(volume, 20)
vol_ok  = volume >= vol_avg * vol_mult

// Session filter — skip 9:15–9:29 IST
ist_mins   = hour(time, "Asia/Kolkata") * 60 + minute(time, "Asia/Kolkata")
sess_start = not no_first15 or ist_mins >= 570  // 570 = 9×60 + 30

// ATR for SL buffer
atr_val = ta.atr(14)


// ─────────────────────────────────────────────────────────────
// PIVOT DETECTION
// ─────────────────────────────────────────────────────────────

price_ph = ta.pivothigh(high,  pivot_lb, pivot_lb)
price_pl = ta.pivotlow(low,    pivot_lb, pivot_lb)
rsi_ph   = ta.pivothigh(rsi_val, pivot_lb, pivot_lb)
rsi_pl   = ta.pivotlow(rsi_val,  pivot_lb, pivot_lb)

// Track previous and current pivot lows
var float prev_price_low = na
var float prev_rsi_low   = na
var int   prev_pl_bar    = na
var float cur_price_low  = na
var float cur_rsi_low    = na
var int   cur_pl_bar     = na

// Track previous and current pivot highs
var float prev_price_high = na
var float prev_rsi_high   = na
var int   prev_ph_bar     = na
var float cur_price_high  = na
var float cur_rsi_high    = na
var int   cur_ph_bar      = na

// Update lows on each new pivot low
if not na(price_pl) and not na(rsi_pl)
    prev_price_low := cur_price_low
    prev_rsi_low   := cur_rsi_low
    prev_pl_bar    := cur_pl_bar
    cur_price_low  := price_pl
    cur_rsi_low    := rsi_pl
    cur_pl_bar     := bar_index - pivot_lb

// Update highs on each new pivot high
if not na(price_ph) and not na(rsi_ph)
    prev_price_high := cur_price_high
    prev_rsi_high   := cur_rsi_high
    prev_ph_bar     := cur_ph_bar
    cur_price_high  := price_ph
    cur_rsi_high    := rsi_ph
    cur_ph_bar      := bar_index - pivot_lb

// ─────────────────────────────────────────────────────────────
// DIVERGENCE DETECTION
// ─────────────────────────────────────────────────────────────

// Bullish regular divergence:
//   Price = lower low  (sellers pushing price down)
//   RSI   = higher low (momentum weakening = reversal likely)
bullish_div = false
if not na(prev_price_low) and not na(cur_price_low) and
   not na(prev_rsi_low)   and not na(cur_rsi_low)   and
   not na(prev_pl_bar)    and not na(cur_pl_bar)
    bars_gap = cur_pl_bar - prev_pl_bar
    if bars_gap >= min_bars and bars_gap <= max_bars
        if cur_price_low < prev_price_low and      // price: lower low
           cur_rsi_low   > prev_rsi_low   and      // RSI:   higher low
           cur_rsi_low   < (ob_level - 10)         // RSI in lower zone
            bullish_div := true

// Bearish regular divergence:
//   Price = higher high (bulls pushing price up)
//   RSI   = lower high  (momentum weakening = reversal likely)
bearish_div = false
if not na(prev_price_high) and not na(cur_price_high) and
   not na(prev_rsi_high)   and not na(cur_rsi_high)   and
   not na(prev_ph_bar)     and not na(cur_ph_bar)
    bars_gap = cur_ph_bar - prev_ph_bar
    if bars_gap >= min_bars and bars_gap <= max_bars
        if cur_price_high > prev_price_high and    // price: higher high
           cur_rsi_high   < prev_rsi_high   and    // RSI:   lower high
           cur_rsi_high   > (os_level + 10)        // RSI in upper zone
            bearish_div := true

// ─────────────────────────────────────────────────────────────
// SETUP AND ENTRY LOGIC
// ─────────────────────────────────────────────────────────────

// Divergence = the SETUP. K-line cross = the TRIGGER.
// Entry fires only when both occur within 8 bars.

var bool bull_setup = false
var bool bear_setup = false
var int  setup_bar  = 0

if bullish_div
    bull_setup := true
    bear_setup := false
    setup_bar  := bar_index

if bearish_div
    bear_setup := true
    bull_setup := false
    setup_bar  := bar_index

// Cancel setup if trigger never came within 8 bars
if (bar_index - setup_bar) > 8
    bull_setup := false
    bear_setup := false

// Entry signals: setup + K-line cross + filters
long_signal  = bull_setup and rsi_cross_up   and sess_start and
               (not use_vwap or close > vwap_val) and
               (not use_vol  or vol_ok)

short_signal = bear_setup and rsi_cross_down and sess_start and
               (not use_vwap or close < vwap_val) and
               (not use_vol  or vol_ok)

// Reset setup once entry fires
if long_signal or short_signal
    bull_setup := false
    bear_setup := false

// ─────────────────────────────────────────────────────────────
// STOP LOSS AND TARGETS
// ─────────────────────────────────────────────────────────────

// Use lowest/highest over recent bars for SL, plus small ATR buffer
long_sl_raw  = ta.lowest(low,   pivot_lb * 2)
short_sl_raw = ta.highest(high, pivot_lb * 2)

long_sl  = long_signal  ? long_sl_raw  - atr_val * 0.1 : na
short_sl = short_signal ? short_sl_raw + atr_val * 0.1 : na

long_risk  = not na(long_sl)  ? math.abs(close - long_sl)  : na
short_risk = not na(short_sl) ? math.abs(close - short_sl) : na

long_t1  = not na(long_risk)  ? close + long_risk  * rr_t1 : na
long_t2  = not na(long_risk)  ? close + long_risk  * rr_t2 : na
short_t1 = not na(short_risk) ? close - short_risk * rr_t1 : na
short_t2 = not na(short_risk) ? close - short_risk * rr_t2 : na

// ─────────────────────────────────────────────────────────────
// DIVERGENCE LINES ON PRICE CHART
// ─────────────────────────────────────────────────────────────

if bullish_div and not na(prev_pl_bar) and not na(cur_pl_bar)
    line.new(x1=prev_pl_bar, y1=prev_price_low,
             x2=cur_pl_bar,  y2=cur_price_low,
             xloc=xloc.bar_index,
             color=color.new(bull_col, 40),
             width=1,
             style=line.style_dashed)

if bearish_div and not na(prev_ph_bar) and not na(cur_ph_bar)
    line.new(x1=prev_ph_bar, y1=prev_price_high,
             x2=cur_ph_bar,  y2=cur_price_high,
             xloc=xloc.bar_index,
             color=color.new(bear_col, 40),
             width=1,
             style=line.style_dashed)

// ─────────────────────────────────────────────────────────────
// BACKGROUND HIGHLIGHT — SETUP ACTIVE
// ─────────────────────────────────────────────────────────────

bgcolor(bull_setup ? color.new(bull_col, 90) : na, title="Bull setup zone")
bgcolor(bear_setup ? color.new(bear_col, 90) : na, title="Bear setup zone")

// ─────────────────────────────────────────────────────────────
// ENTRY SIGNALS ON PRICE CHART
// ─────────────────────────────────────────────────────────────

plotshape(long_signal,
          title     = "LONG",
          style     = shape.labelup,
          location  = location.belowbar,
          color     = bull_col,
          textcolor = color.white,
          text      = "LONG",
          size      = size.normal)

plotshape(short_signal,
          title     = "SHORT",
          style     = shape.labeldown,
          location  = location.abovebar,
          color     = bear_col,
          textcolor = color.white,
          text      = "SHORT",
          size      = size.normal)

// ─────────────────────────────────────────────────────────────
// SL / TARGET LABELS
// ─────────────────────────────────────────────────────────────

if long_signal
    if show_sl and not na(long_sl)
        label.new(x         = bar_index + 1,
                  y         = long_sl,
                  text      = "SL  " + str.tostring(math.round(long_sl, 2)),
                  color     = color.new(bear_col, 75),
                  textcolor = bear_col,
                  style     = label.style_label_right,
                  size      = size.small,
                  xloc      = xloc.bar_index)
    if show_tp and not na(long_t1)
        label.new(x         = bar_index + 1,
                  y         = long_t1,
                  text      = "T1  " + str.tostring(math.round(long_t1, 2)),
                  color     = color.new(bull_col, 75),
                  textcolor = bull_col,
                  style     = label.style_label_right,
                  size      = size.small,
                  xloc      = xloc.bar_index)
        label.new(x         = bar_index + 1,
                  y         = long_t2,
                  text      = "T2  " + str.tostring(math.round(long_t2, 2)),
                  color     = color.new(bull_col, 60),
                  textcolor = bull_col,
                  style     = label.style_label_right,
                  size      = size.small,
                  xloc      = xloc.bar_index)

if short_signal
    if show_sl and not na(short_sl)
        label.new(x         = bar_index + 1,
                  y         = short_sl,
                  text      = "SL  " + str.tostring(math.round(short_sl, 2)),
                  color     = color.new(bull_col, 75),
                  textcolor = bull_col,
                  style     = label.style_label_right,
                  size      = size.small,
                  xloc      = xloc.bar_index)
    if show_tp and not na(short_t1)
        label.new(x         = bar_index + 1,
                  y         = short_t1,
                  text      = "T1  " + str.tostring(math.round(short_t1, 2)),
                  color     = color.new(bear_col, 75),
                  textcolor = bear_col,
                  style     = label.style_label_right,
                  size      = size.small,
                  xloc      = xloc.bar_index)
        label.new(x         = bar_index + 1,
                  y         = short_t2,
                  text      = "T2  " + str.tostring(math.round(short_t2, 2)),
                  color     = color.new(bear_col, 60),
                  textcolor = bear_col,
                  style     = label.style_label_right,
                  size      = size.small,
                  xloc      = xloc.bar_index)

// ─────────────────────────────────────────────────────────────
// RSI PANE (separate panel below price chart)
// ─────────────────────────────────────────────────────────────

plot(rsi_val, title="RSI",    color=color.new(#7F77DD, 0), linewidth=2,  display=display.pane)
plot(k_line,  title="K-line", color=color.new(#EF9F27, 0), linewidth=1,  display=display.pane)

ob_h = hline(70, "Overbought", color=color.new(#FF4444, 50), linestyle=hline.style_dashed)
os_h = hline(30, "Oversold",   color=color.new(#00C896, 50), linestyle=hline.style_dashed)
       

fill(ob_h, os_h, color=color.new(#888888, 93))

// Small triangles on RSI pane at cross points
plotshape(rsi_cross_up   and bull_setup,
          title    = "K cross up",
          style    = shape.triangleup,
          location = location.absolute,
          color    = bull_col,
          size     = size.tiny,
          display  = display.pane)

plotshape(rsi_cross_down and bear_setup,
          title    = "K cross down",
          style    = shape.triangledown,
          location = location.absolute,
          color    = bear_col,
          size     = size.tiny,
          display  = display.pane)

// ─────────────────────────────────────────────────────────────
// INFO TABLE (top-right corner)
// ─────────────────────────────────────────────────────────────

var table tbl = table.new(
      position     = position.top_right,
      columns      = 2,
      rows         = 6,
      bgcolor      = color.new(color.black, 82),
      border_color = color.new(color.gray, 65),
      border_width = 1,
      frame_color  = color.new(color.gray, 55),
      frame_width  = 1)

if barstate.islast
    rsi_c   = rsi_val > ob_level ? bear_col : rsi_val < os_level ? bull_col : color.silver
    k_c     = rsi_val > k_line   ? bull_col : bear_col
    s_txt   = bull_setup ? "BULL SETUP" : bear_setup ? "BEAR SETUP" : "No setup"
    s_col   = bull_setup ? bull_col     : bear_setup ? bear_col     : color.gray
    vwap_c  = close > vwap_val ? bull_col : bear_col
    vwap_t  = close > vwap_val ? "Above" : "Below"

    table.cell(tbl, 0, 0, "RSI 14-3-K",
               text_color=color.silver, text_size=size.small,
               bgcolor=color.new(color.black, 55))
    table.cell(tbl, 1, 0, "[Vijay]",
               text_color=color.silver, text_size=size.small,
               bgcolor=color.new(color.black, 55))

    table.cell(tbl, 0, 1, "RSI",
               text_color=color.gray, text_size=size.small)
    table.cell(tbl, 1, 1, str.tostring(math.round(rsi_val, 1)),
               text_color=rsi_c, text_size=size.small)

    table.cell(tbl, 0, 2, "K-line",
               text_color=color.gray, text_size=size.small)
    table.cell(tbl, 1, 2, str.tostring(math.round(k_line, 1)),
               text_color=k_c, text_size=size.small)

    table.cell(tbl, 0, 3, "RSI vs K",
               text_color=color.gray, text_size=size.small)
    table.cell(tbl, 1, 3, rsi_val > k_line ? "Above" : "Below",
               text_color=k_c, text_size=size.small)

    table.cell(tbl, 0, 4, "VWAP",
               text_color=color.gray, text_size=size.small)
    table.cell(tbl, 1, 4, vwap_t,
               text_color=vwap_c, text_size=size.small)

    table.cell(tbl, 0, 5, "Setup",
               text_color=color.gray, text_size=size.small)
    table.cell(tbl, 1, 5, s_txt,
               text_color=s_col, text_size=size.small)

// ─────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────

alertcondition(long_signal,
               title   = "RSI143K — LONG signal",
               message = "{{ticker}} 3-min | RSI143K LONG | Price: {{close}}")

alertcondition(short_signal,
               title   = "RSI143K — SHORT signal",
               message = "{{ticker}} 3-min | RSI143K SHORT | Price: {{close}}")

alertcondition(bullish_div,
               title   = "RSI143K — Bullish divergence forming",
               message = "{{ticker}} | Bullish divergence — watch for K-line cross entry")

alertcondition(bearish_div,
               title   = "RSI143K — Bearish divergence forming",
               message = "{{ticker}} | Bearish divergence — watch for K-line cross entry")

// ─────────────────────────────────────────────────────────────
````

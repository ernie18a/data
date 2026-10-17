# Nick's Composite MACD

- url: https://www.tradingview.com/script/PeTCKjMU-Nick-s-Composite-MACD/
- type: indicator
- pine_id: PUB;89bc7e86c8e940ec8e248b4622eb5569
- version: 1.0

## Description

Updated multi timeframe MACD. Averages current timeframe with the next 2 timeframes up giving a smoother signal by eliminating the fast movements of standard MACD.

## Source Code

````pine
//@version=6
indicator(title="Nick's Composite MACD", shorttitle="Nick's CMACD", overlay=false, max_labels_count=500)

// ═════════════════════════════════════════════
//  NICK'S COMPOSITE MACD
//
//  Averages MACD across up to 3 timeframes to
//  create a composite signal. Works on any
//  ticker — automatically uses current chart.
//
//  Add multiple instances with different TF
//  combinations:
//  Instance 1: 5m / 15m / 30m  (on 5m chart)
//  Instance 2: 60m / 4h / D   (higher TFs)
//
//  IMPORTANT: Always use timeframes >= chart TF
//  Requesting lower TFs causes buffer errors.
//  On 5m chart use: 5, 15, 30, 60, 240, D
//  On 1m chart use: 1, 3, 5, 15, 30
//
//  Includes full divergence detection matching
//  Daviddtech MACD Divergences behavior:
//  - Regular Bull/Bear divergences
//  - Hidden Bull/Bear divergences
// ═════════════════════════════════════════════

var string GRP_MACD = "MACD Settings"
var string GRP_TF   = "Timeframe Settings"
var string GRP_HIST = "Histogram Display"
var string GRP_DIV  = "Divergence Settings"
var string GRP_COL  = "Colors"

// ═════════════════════════════════════════════
//  MACD SETTINGS
// ═════════════════════════════════════════════
macd_src        = input.source(close, "MACD Source",           group=GRP_MACD)


fast_len        = input.int(13,  "Fast Length",  minval=1,     group=GRP_MACD)
slow_len        = input.int(34,  "Slow Length",  minval=1,     group=GRP_MACD)
signal_len      = input.int(10,  "Signal Length", minval=1,    group=GRP_MACD)
signal_type     = input.string("EMA", "Signal MA Type", options=["EMA","SMA","RMA","WMA"], group=GRP_MACD, tooltip="Smoothing method for the signal line. EMA matches standard MACD.")

// ═════════════════════════════════════════════
//  HISTOGRAM DISPLAY (visual only — does NOT
//  affect the MACD line calc or divergence logic)
// ═════════════════════════════════════════════
hist_smooth     = input.bool(true, "Smooth histogram (display only)", group=GRP_HIST, tooltip="Applies a moving average to the plotted histogram to reduce jaggedness. Does NOT change the MACD line, signal line, or divergence detection — purely visual.")
hist_smooth_len = input.int(10,  "Histogram smoothing length", minval=1, maxval=20, group=GRP_HIST, tooltip="MA length for the histogram smoothing. Higher = smoother but more lag in the visual.")
hist_smooth_type= input.string("EMA", "Histogram smoothing type", options=["EMA","SMA","WMA"], group=GRP_HIST)
hist_scale      = input.float(6.0, "Histogram scale (visual size)", minval=0.1, maxval=10.0, step=0.1, group=GRP_HIST, tooltip="Multiplies the plotted histogram height to make it bigger/smaller on the pane. Visual only — does not affect any calculation or signal.")

// ═════════════════════════════════════════════
//  TIMEFRAME SETTINGS
// ═════════════════════════════════════════════
use_auto_tf  = input.bool(true, "Auto-detect timeframes from chart", group=GRP_TF, tooltip="Automatically sets TF1/TF2/TF3 based on your chart timeframe. TF1 = chart TF, TF2 = next TF up, TF3 = two TFs up. Disable to set manually.")

// Manual override inputs — only used when auto is OFF
show_tf_label = input.bool(false, "Show active TF label on chart",    group=GRP_TF, tooltip="Displays a label showing which timeframes are being averaged. Off by default.")
use_tf1      = input.bool(true,  "Enable TF1 (manual only)",         group=GRP_TF, tooltip="Only applies when auto-detect is OFF.")
tf1_manual   = input.timeframe("5",  "Timeframe 1 (manual)",         group=GRP_TF, tooltip="Only applies when auto-detect is OFF. Use TFs >= chart TF.")
use_tf2      = input.bool(true,  "Enable TF2 (manual only)",         group=GRP_TF)
tf2_manual   = input.timeframe("15", "Timeframe 2 (manual)",         group=GRP_TF)
use_tf3      = input.bool(true,  "Enable TF3 (manual only)",         group=GRP_TF)
tf3_manual   = input.timeframe("30", "Timeframe 3 (manual)",         group=GRP_TF)

// ═════════════════════════════════════════════
//  DIVERGENCE SETTINGS
// ═════════════════════════════════════════════
show_div        = input.bool(true,  "Show Divergences",                              group=GRP_DIV)
show_reg_bull   = input.bool(true,  "Show Regular Bullish Divergence",               group=GRP_DIV, tooltip="Price makes lower low, MACD makes higher low. Classic reversal signal.")
show_reg_bear   = input.bool(true,  "Show Regular Bearish Divergence",               group=GRP_DIV, tooltip="Price makes higher high, MACD makes lower high. Classic reversal signal.")
show_hid_bull   = input.bool(true,  "Show Hidden Bullish Divergence",                group=GRP_DIV, tooltip="Price makes higher low, MACD makes lower low. Trend continuation signal.")
show_hid_bear   = input.bool(true,  "Show Hidden Bearish Divergence",                group=GRP_DIV, tooltip="Price makes lower high, MACD makes higher high. Trend continuation signal.")
piv_lookback    = input.int(5,  "Pivot Lookback (bars)",     minval=2, maxval=20,    group=GRP_DIV, tooltip="Bars left and right used to identify pivot highs/lows on MACD histogram. Lower = more sensitive.")
div_lookback    = input.int(60, "Divergence Lookback (bars)", minval=10, maxval=300, group=GRP_DIV, tooltip="How far back to search for a matching pivot to form a divergence pair.")

// ═════════════════════════════════════════════
//  COLORS
// ═════════════════════════════════════════════
col_hist_bull_strong = input.color(color.new(#26a69a, 0),  "Histogram — Bull Strong",  group=GRP_COL, tooltip="Histogram positive and growing")
col_hist_bull_weak   = input.color(color.new(#26a69a, 50), "Histogram — Bull Weak",    group=GRP_COL, tooltip="Histogram positive but shrinking")
col_hist_bear_strong = input.color(color.new(#ef5350, 0),  "Histogram — Bear Strong",  group=GRP_COL, tooltip="Histogram negative and growing")
col_hist_bear_weak   = input.color(color.new(#ef5350, 50), "Histogram — Bear Weak",    group=GRP_COL, tooltip="Histogram negative but shrinking")
col_macd_line        = input.color(color.new(#2962ff, 0),  "MACD Line Color",          group=GRP_COL)
col_signal_line      = input.color(color.new(#ff6d00, 0),  "Signal Line Color",        group=GRP_COL)
col_reg_bull         = input.color(color.new(#26a69a, 0),  "Regular Bull Divergence",  group=GRP_COL)
col_reg_bear         = input.color(color.new(#ef5350, 0),  "Regular Bear Divergence",  group=GRP_COL)
col_hid_bull         = input.color(color.new(#26a69a, 40), "Hidden Bull Divergence",   group=GRP_COL)
col_hid_bear         = input.color(color.new(#ef5350, 40), "Hidden Bear Divergence",   group=GRP_COL)

// ═════════════════════════════════════════════
//  SIGNAL LINE MA HELPER
// ═════════════════════════════════════════════
f_signal_ma(src, len, method) =>
    switch method
        "EMA" => ta.ema(src, len)
        "SMA" => ta.sma(src, len)
        "RMA" => ta.rma(src, len)
        "WMA" => ta.wma(src, len)

// ═════════════════════════════════════════════
//  AUTO TIMEFRAME DETECTION
//  Detects chart TF and selects the next two
//  higher timeframes in the standard progression
//  1 → 3 → 5 → 15 → 30 → 60 → 120 → 240 → D → W
// ═════════════════════════════════════════════

// Standard TF progression lookup
// Returns the Nth next timeframe above the given TF string
f_next_tf(tf_str, steps) =>
    // Convert TF string to minutes for comparison
    tf_mins = timeframe.in_seconds(tf_str) / 60

    // Standard progression in minutes
    // D=1440, W=10080
    result = if tf_mins <= 1
        steps == 1 ? "3"   : steps == 2 ? "5"   : "15"
    else if tf_mins <= 3
        steps == 1 ? "5"   : steps == 2 ? "15"  : "30"
    else if tf_mins <= 5
        steps == 1 ? "15"  : steps == 2 ? "30"  : "60"
    else if tf_mins <= 15
        steps == 1 ? "30"  : steps == 2 ? "60"  : "240"
    else if tf_mins <= 30
        steps == 1 ? "60"  : steps == 2 ? "240" : "D"
    else if tf_mins <= 60
        steps == 1 ? "120" : steps == 2 ? "240" : "D"
    else if tf_mins <= 120
        steps == 1 ? "240" : steps == 2 ? "D"   : "W"
    else if tf_mins <= 240
        steps == 1 ? "D"   : steps == 2 ? "W"   : "W"
    else if tf_mins <= 1440
        steps == 1 ? "W"   : steps == 2 ? "W"   : "W"
    else
        "W"
    result

// Resolve final TF values — auto or manual
tf1 = use_auto_tf ? timeframe.period              : tf1_manual
tf2 = use_auto_tf ? f_next_tf(timeframe.period, 1) : tf2_manual
tf3 = use_auto_tf ? f_next_tf(timeframe.period, 2) : tf3_manual

// In auto mode all 3 TFs are always enabled
tf1_active = use_auto_tf ? true : use_tf1
tf2_active = use_auto_tf ? true : use_tf2
tf3_active = use_auto_tf ? true : use_tf3

// ═════════════════════════════════════════════
//  MACD CALCULATION PER TIMEFRAME
//  The fix for "beyond historical buffer limit":
//  Use request.security_lower_tf() is NOT the
//  answer — instead we wrap the entire MACD
//  calculation inside request.security() so
//  Pine manages the buffer internally.
//  The key is using a self-contained expression.
// ═════════════════════════════════════════════

// Pull composite MACD line from each timeframe
// Uses timeframe.in_seconds() to detect if requested
// TF is lower than chart TF and handle accordingly
// For lower TFs: average the lower TF bars that fall
// within each chart bar using array mean
f_get_macd(tf) =>
    // Get MACD from requested timeframe
    // gaps_off fills missing bars with last value
    request.security(syminfo.tickerid, tf,
         ta.ema(close, fast_len) - ta.ema(close, slow_len),
         lookahead = barmerge.lookahead_off,
         gaps      = barmerge.gaps_off)

macd_tf1 = f_get_macd(tf1)
macd_tf2 = f_get_macd(tf2)
macd_tf3 = f_get_macd(tf3)

// Explicitly set buffer on all security results
max_bars_back(macd_tf1,    1000)
max_bars_back(macd_tf2,    1000)
max_bars_back(macd_tf3,    1000)

// ═════════════════════════════════════════════
//  COMPOSITE AVERAGE
//  Only include enabled timeframes in the average
//  Handles 1, 2, or 3 active timeframes cleanly
// ═════════════════════════════════════════════
tf_count = (tf1_active ? 1 : 0) + (tf2_active ? 1 : 0) + (tf3_active ? 1 : 0)
tf_sum   = (tf1_active ? macd_tf1 : 0.0) +
           (tf2_active ? macd_tf2 : 0.0) +
           (tf3_active ? macd_tf3 : 0.0)

// Composite MACD line = average of enabled TFs
comp_macd = tf_count > 0 ? tf_sum / tf_count : 0.0

// Signal line applied to the composite
comp_signal = f_signal_ma(comp_macd, signal_len, signal_type)

// Histogram = composite MACD minus signal (RAW — used for divergences)
comp_hist = comp_macd - comp_signal

// Display histogram — optional smoothing + scale, VISUAL ONLY.
// Divergence detection below still uses the raw comp_hist.
hist_base = hist_smooth ?
     (hist_smooth_type == "EMA" ? ta.ema(comp_hist, hist_smooth_len) :
      hist_smooth_type == "SMA" ? ta.sma(comp_hist, hist_smooth_len) :
      ta.wma(comp_hist, hist_smooth_len)) : comp_hist
comp_hist_display = hist_base * hist_scale

// ═════════════════════════════════════════════
//  HISTOGRAM COLOR
//  Matches standard MACD coloring convention:
//  Strong = moving away from zero
//  Weak   = moving toward zero
// ═════════════════════════════════════════════
hist_col = comp_hist_display >= 0
     ? (comp_hist_display >= comp_hist_display[1] ? col_hist_bull_strong : col_hist_bull_weak)
     : (comp_hist_display <= comp_hist_display[1] ? col_hist_bear_strong : col_hist_bear_weak)

// ═════════════════════════════════════════════
//  PLOTS — standard MACD appearance
// ═════════════════════════════════════════════
plot(comp_hist_display, "Histogram", style=plot.style_columns, color=hist_col, linewidth=1)
plot(comp_macd,   "MACD Line",   color=col_macd_line,   linewidth=2)
plot(comp_signal, "Signal Line", color=col_signal_line, linewidth=1)
hline(0, "Zero Line", color=color.new(color.gray, 50), linestyle=hline.style_dashed)

// ═════════════════════════════════════════════
//  HISTORICAL BUFFER — must be set before
//  any series is accessed with [] offsets
//  This is what actually fixes the RE10143 error
// ═════════════════════════════════════════════
max_bars_back(comp_hist,   1000)
max_bars_back(comp_hist_display, 1000)
max_bars_back(comp_macd,   1000)
max_bars_back(high,        1000)
max_bars_back(low,         1000)

// ═════════════════════════════════════════════
//  DIVERGENCE DETECTION
//
//  Uses pivot highs/lows on both price and
//  the composite MACD histogram to find
//  divergences. Matches Daviddtech approach.
//
//  Pivot confirmed when price/MACD has moved
//  piv_lookback bars beyond the pivot point —
//  so divergence labels appear with a delay
//  (this is correct — avoids repainting)
// ═════════════════════════════════════════════

// ─── Pivot detection ──────────────────────────
// Pivot high/low on MACD histogram
hist_ph = ta.pivothigh(comp_hist, piv_lookback, piv_lookback)
hist_pl = ta.pivotlow(comp_hist,  piv_lookback, piv_lookback)

// Pivot high/low on price
price_ph = ta.pivothigh(high, piv_lookback, piv_lookback)
price_pl = ta.pivotlow(low,  piv_lookback, piv_lookback)

// ─── Helper: find most recent pivot ───────────
// Searches back div_lookback bars for the most
// recent confirmed pivot, returns its bar index
// and value
f_last_pivot_high_hist(lookback) =>
    float val = na
    int   idx = na
    for i = piv_lookback to lookback
        if not na(ta.pivothigh(comp_hist, piv_lookback, piv_lookback)[i - piv_lookback])
            val := comp_hist[i]
            idx := bar_index - i
            break
    [idx, val]

f_last_pivot_low_hist(lookback) =>
    float val = na
    int   idx = na
    for i = piv_lookback to lookback
        if not na(ta.pivotlow(comp_hist, piv_lookback, piv_lookback)[i - piv_lookback])
            val := comp_hist[i]
            idx := bar_index - i
            break
    [idx, val]

f_last_pivot_high_price(lookback) =>
    float val = na
    int   idx = na
    for i = piv_lookback to lookback
        if not na(ta.pivothigh(high, piv_lookback, piv_lookback)[i - piv_lookback])
            val := high[i]
            idx := bar_index - i
            break
    [idx, val]

f_last_pivot_low_price(lookback) =>
    float val = na
    int   idx = na
    for i = piv_lookback to lookback
        if not na(ta.pivotlow(low, piv_lookback, piv_lookback)[i - piv_lookback])
            val := low[i]
            idx := bar_index - i
            break
    [idx, val]

// ─── Divergence logic ─────────────────────────
// Runs on confirmed pivot bars (piv_lookback bars after the actual pivot)

// Current pivot values (at confirmed bar)
curr_hist_ph  = comp_hist[piv_lookback]  // MACD at current pivot high
curr_hist_pl  = comp_hist[piv_lookback]  // MACD at current pivot low
curr_price_ph = high[piv_lookback]       // Price at current pivot high
curr_price_pl = low[piv_lookback]        // Price at current pivot low

// ─── Regular Bullish: price lower low, MACD higher low ───
reg_bull_div = false
reg_bull_x1  = 0
reg_bull_y1  = 0.0
reg_bull_x2  = bar_index - piv_lookback
reg_bull_y2  = curr_hist_pl

if show_div and show_reg_bull and not na(hist_pl)
    [prev_idx, prev_val] = f_last_pivot_low_hist(div_lookback)
    [prev_pidx, prev_pval] = f_last_pivot_low_price(div_lookback)
    if not na(prev_idx) and not na(prev_val)
        // Price: lower low (current price low < previous price low)
        // MACD:  higher low (current hist low > previous hist low)
        if curr_price_pl < prev_pval and curr_hist_pl > prev_val and curr_hist_pl < 0
            reg_bull_div := true
            reg_bull_x1  := prev_idx
            reg_bull_y1  := prev_val

// ─── Regular Bearish: price higher high, MACD lower high ──
reg_bear_div = false
reg_bear_x1  = 0
reg_bear_y1  = 0.0
reg_bear_x2  = bar_index - piv_lookback
reg_bear_y2  = curr_hist_ph

if show_div and show_reg_bear and not na(hist_ph)
    [prev_idx, prev_val] = f_last_pivot_high_hist(div_lookback)
    [prev_pidx, prev_pval] = f_last_pivot_high_price(div_lookback)
    if not na(prev_idx) and not na(prev_val)
        // Price: higher high
        // MACD:  lower high
        if curr_price_ph > prev_pval and curr_hist_ph < prev_val and curr_hist_ph > 0
            reg_bear_div := true
            reg_bear_x1  := prev_idx
            reg_bear_y1  := prev_val

// ─── Hidden Bullish: price higher low, MACD lower low ────
hid_bull_div = false
hid_bull_x1  = 0
hid_bull_y1  = 0.0
hid_bull_x2  = bar_index - piv_lookback
hid_bull_y2  = curr_hist_pl

if show_div and show_hid_bull and not na(hist_pl)
    [prev_idx, prev_val] = f_last_pivot_low_hist(div_lookback)
    [prev_pidx, prev_pval] = f_last_pivot_low_price(div_lookback)
    if not na(prev_idx) and not na(prev_val)
        // Price: higher low (bullish — trend continuation)
        // MACD:  lower low
        if curr_price_pl > prev_pval and curr_hist_pl < prev_val and curr_hist_pl < 0
            hid_bull_div := true
            hid_bull_x1  := prev_idx
            hid_bull_y1  := prev_val

// ─── Hidden Bearish: price lower high, MACD higher high ──
hid_bear_div = false
hid_bear_x1  = 0
hid_bear_y1  = 0.0
hid_bear_x2  = bar_index - piv_lookback
hid_bear_y2  = curr_hist_ph

if show_div and show_hid_bear and not na(hist_ph)
    [prev_idx, prev_val] = f_last_pivot_high_hist(div_lookback)
    [prev_pidx, prev_pval] = f_last_pivot_high_price(div_lookback)
    if not na(prev_idx) and not na(prev_val)
        // Price: lower high (bearish — trend continuation)
        // MACD:  higher high
        if curr_price_ph < prev_pval and curr_hist_ph > prev_val and curr_hist_ph > 0
            hid_bear_div := true
            hid_bear_x1  := prev_idx
            hid_bear_y1  := prev_val

// ═════════════════════════════════════════════
//  DIVERGENCE VISUALS
//  Lines connecting the two pivot points
//  Labels at the current pivot point
// ═════════════════════════════════════════════

// Regular Bullish
if reg_bull_div
    line.new(reg_bull_x1, reg_bull_y1, reg_bull_x2, reg_bull_y2,
         color=col_reg_bull, width=2, style=line.style_solid)
    label.new(reg_bull_x2, reg_bull_y2, "Bull",
         color=col_reg_bull, textcolor=color.white,
         style=label.style_label_up, size=size.small)

// Regular Bearish
if reg_bear_div
    line.new(reg_bear_x1, reg_bear_y1, reg_bear_x2, reg_bear_y2,
         color=col_reg_bear, width=2, style=line.style_solid)
    label.new(reg_bear_x2, reg_bear_y2, "Bear",
         color=col_reg_bear, textcolor=color.white,
         style=label.style_label_down, size=size.small)

// Hidden Bullish
if hid_bull_div
    line.new(hid_bull_x1, hid_bull_y1, hid_bull_x2, hid_bull_y2,
         color=col_hid_bull, width=2, style=line.style_dashed)
    label.new(hid_bull_x2, hid_bull_y2, "H Bull",
         color=col_hid_bull, textcolor=color.white,
         style=label.style_label_up, size=size.small)

// Hidden Bearish
if hid_bear_div
    line.new(hid_bear_x1, hid_bear_y1, hid_bear_x2, hid_bear_y2,
         color=col_hid_bear, width=2, style=line.style_dashed)
    label.new(hid_bear_x2, hid_bear_y2, "H Bear",
         color=col_hid_bear, textcolor=color.white,
         style=label.style_label_down, size=size.small)

// ═════════════════════════════════════════════
//  ACTIVE TF LABEL — shows on chart so you
//  always know which TFs are being averaged
// ═════════════════════════════════════════════
var label tf_label = na
if barstate.islast and show_tf_label
    label.delete(tf_label)
    tf_info = (use_auto_tf ? "Auto" : "Manual") +
         " | TF1: " + tf1 +
         " | TF2: " + tf2 +
         " | TF3: " + tf3 +
         " | Avg of " + str.tostring(tf_count) + " TFs"
    tf_label := label.new(bar_index, comp_macd,
         tf_info,
         color     = color.new(color.navy, 20),
         textcolor = color.white,
         style     = label.style_label_left,
         size      = size.small)

// ═════════════════════════════════════════════
//  DATA WINDOW
// ═════════════════════════════════════════════
plot(comp_macd,   "Composite MACD",   display=display.data_window)
plot(comp_signal, "Composite Signal", display=display.data_window)
plot(comp_hist,   "Composite Hist",   display=display.data_window)
plot(macd_tf1,    "MACD TF1",         display=display.data_window)
plot(macd_tf2,    "MACD TF2",         display=display.data_window)
plot(macd_tf3,    "MACD TF3",         display=display.data_window)
plot(tf_count,    "Active TFs",       display=display.data_window)
````

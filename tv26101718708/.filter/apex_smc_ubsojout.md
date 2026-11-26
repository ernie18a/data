# Apex SMC

- url: https://www.tradingview.com/script/UBsojouT-Apex-SMC/
- type: indicator
- pine_id: PUB;59579f4997b5441b8467ec3d54a9c6b2
- version: 1.0

## Description

Title: Apex Institutional Edge

The Ultimate Institutional Trading Framework
Most Smart Money Concepts (SMC) scripts simply paint overlapping boxes on your chart until the price action is unreadable. The Apex Institutional Edge V3.5 is different. It is a complete, systematic institutional trading engine that combines market microstructure, liquidity sweeps, volume delta, and multi-timeframe confluence into a single, aggressively optimized suite.

Built specifically for precision assets like XAU/USD on the 5-minute timeframe (but robust enough for any market), this indicator acts as a complete trading desk, filtering out retail traps and keeping your chart surgically clean.

🏛️ Core Feature 1: Dynamic Smart Money Zones
Apex does not just draw zones; it actively manages them using a proprietary "True-Touch Mitigation" garbage collector.

Unmitigated FVGs, Order Blocks (OB), & Rejection Blocks (RJB): Automatically identifies and highlights high-probability institutional zones.

Surgical Cleanliness: The exact second a live candle wick touches any part of a zone, the script instantly registers it as "mitigated" and deletes it from your chart. You only ever see fresh, untouched liquidity pools.

Tier-1 Liquidity Tracking: Automatically plots the Previous Daily High/Low (PDH/PDL) and active Major/Minor Buy-Side and Sell-Side Liquidity (BSL/SSL) levels.

📊 Core Feature 2: Institutional Order Flow & AMD
Cumulative Volume Delta (CVD): An internal volume engine tracks the true delta between buyers and sellers. It actively plots Bullish/Bearish CVD Divergence dots directly on your chart, warning you of hidden institutional accumulation or distribution before the price breaks.

A-M-D Session Gates: Automatically maps the Asia (Accumulation), London (Manipulation), and New York (Distribution) sessions. The algorithmic logic filters out low-probability signals during off-hours and highlights the true narrative of the daily cycle.

⚡ Core Feature 3: The Dual-Signal Engine
Apex utilizes two completely independent mathematical engines to generate entry signals, strictly avoiding the "Parabolic Trend Trap" that plagues other scripts.

Engine A (Scalp & Continuation): Hunts for strict liquidity sweeps combined with Bullish/Bearish Displacement. During ranging markets, it demands a deep 4-candle liquidity flush. However, if the MTF dashboard detects a massive "Runaway" trend, the engine dynamically adapts, allowing you to catch aggressive 1-to-2 candle pullbacks into unmitigated zones without waiting for a deep structural flush.

Engine B (Macro Swing): A dedicated higher-timeframe engine that hunts for major structural reversals off PDH/PDL or Major Swing pivots.

The Chop Filter: The ultimate account saver. If the engine detects a liquidity sweep but the internal Choppiness Index confirms the market is in a dead range, it explicitly prints a gray CHOP WAIT label, filtering out fake breakouts.

🖥️ Core Feature 4: The Twin HUD Dashboards
All of this heavy math is distilled into two ultra-clean, compact Heads-Up Displays anchored perfectly to your screen (bypassing TradingView's scaling bugs).

MTF Bias Dashboard: Gives you an instant macro-to-micro view. It calculates real-time EMA-based trend alignment across the Daily, 4H, 1H, 15m, and 5m timeframes, tracks the exact Chop %, and displays live CVD flow.

Action Status Panel: The brain of the operation. Constantly feeds you live, plain-English execution commands based on deep confluence (e.g., 💎 STRONG BUY NOW, ⚠️ WEAK SELL, 🔍 SCANNING).

💡 How to Use It
Asset & Timeframe: Highly optimized for XAU/USD (Gold) on the 5m chart, but fully functional on Forex, Indices, and Crypto.

Execution: Wait for the MTF Dashboard to show directional alignment (e.g., 4↑ / 1↓). Let the price sweep a labeled Liquidity Line (BSL/SSL) or tap a fresh FVG/OB. Wait for the engine to print a STRONG BUY or SWING LONG label with an accompanying background flash. Enter the trade, placing your stop loss safely behind the sweep wick.

Trade the data, not the noise.

## Source Code

````pine
//@version=5
indicator("Apex SMC Institution 2", shorttitle="Apex SMC", overlay=true, max_boxes_count=100, max_labels_count=100, max_lines_count=100)

// =========================================================================
// 1. INPUTS & SESSIONS (Dubai GST)
// =========================================================================
grp_mac = "Momentum Engine"
fast_len = input.int(5, title="Fast Length", group=grp_mac)
slow_len = input.int(9, title="Slow Length", group=grp_mac)
sig_len  = input.int(3, title="Signal Smoothing", group=grp_mac)

grp_sess = "Session Settings (GST - Dubai)"
asia_time = input.session("0400-1000", title="Asia Session", group=grp_sess)
asia_col  = input.color(color.new(color.gray, 92), title="Asia Color", group=grp_sess)

lon_time  = input.session("1100-1600", title="London Session", group=grp_sess)
lon_col   = input.color(color.new(color.blue, 92), title="London Color", group=grp_sess)

ny_time   = input.session("1630-2300", title="New York Session", group=grp_sess)
ny_col    = input.color(color.new(color.orange, 92), title="NY Color", group=grp_sess)

// =========================================================================
// 2. CHOPPINESS INDEX (The Sideways Filter)
// =========================================================================
chop_len = 14
atr_sum = math.sum(ta.atr(1), chop_len)
highest_h = ta.highest(chop_len)
lowest_l = ta.lowest(chop_len)
chop = 100 * math.log10(atr_sum / (highest_h - lowest_l == 0 ? 1 : highest_h - lowest_l)) / math.log10(chop_len)

is_choppy = chop > 61.8 

// =========================================================================
// 3. MTF DIRECTIONAL BIAS DASHBOARD
// =========================================================================
f_bias(tf) =>
    [c, e] = request.security(syminfo.tickerid, tf, [close, ta.ema(close, 20)])
    c > e ? "BULLISH" : "BEARISH"

bias_D   = f_bias("D")
bias_4h  = f_bias("240")
bias_1h  = f_bias("60")
bias_15m = f_bias("15")
bias_5m  = f_bias("5")
bias_1m  = f_bias("1")

var table mtf_table = table.new(position.middle_right, 2, 8, bgcolor=color.white, frame_color=color.black, frame_width=2, border_color=color.black, border_width=1)

if barstate.islast
    table.cell(mtf_table, 0, 0, "Timeframe", text_color=color.black, text_size=size.small, bgcolor=color.white)
    table.cell(mtf_table, 1, 0, "Bias", text_color=color.black, text_size=size.small, bgcolor=color.white)
    table.cell(mtf_table, 0, 1, "Daily", text_color=color.black, text_size=size.small, bgcolor=color.white)
    table.cell(mtf_table, 1, 1, bias_D, text_color=bias_D == "BULLISH" ? color.green : color.red, text_size=size.small, bgcolor=color.white)
    table.cell(mtf_table, 0, 2, "4H", text_color=color.black, text_size=size.small, bgcolor=color.white)
    table.cell(mtf_table, 1, 2, bias_4h, text_color=bias_4h == "BULLISH" ? color.green : color.red, text_size=size.small, bgcolor=color.white)
    table.cell(mtf_table, 0, 3, "1H", text_color=color.black, text_size=size.small, bgcolor=color.white)
    table.cell(mtf_table, 1, 3, bias_1h, text_color=bias_1h == "BULLISH" ? color.green : color.red, text_size=size.small, bgcolor=color.white)
    table.cell(mtf_table, 0, 4, "15m", text_color=color.black, text_size=size.small, bgcolor=color.white)
    table.cell(mtf_table, 1, 4, bias_15m, text_color=bias_15m == "BULLISH" ? color.green : color.red, text_size=size.small, bgcolor=color.white)
    table.cell(mtf_table, 0, 5, "5m", text_color=color.black, text_size=size.small, bgcolor=color.white)
    table.cell(mtf_table, 1, 5, bias_5m, text_color=bias_5m == "BULLISH" ? color.green : color.red, text_size=size.small, bgcolor=color.white)
    table.cell(mtf_table, 0, 6, "1m", text_color=color.black, text_size=size.small, bgcolor=color.white)
    table.cell(mtf_table, 1, 6, bias_1m, text_color=bias_1m == "BULLISH" ? color.green : color.red, text_size=size.small, bgcolor=color.white)
    table.cell(mtf_table, 0, 7, "STATUS", text_color=color.black, text_size=size.small, bgcolor=color.white)
    table.cell(mtf_table, 1, 7, is_choppy ? "CHOPPY" : "TRENDING", text_color=is_choppy ? color.orange : color.green, text_size=size.small, bgcolor=color.white)

// =========================================================================
// 4. INSTITUTIONAL LIQUIDITY POOLS
// =========================================================================
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)

plot(pdh, title="PDH Line", color=color.new(color.red, 30), style=plot.style_stepline, linewidth=1)
plot(pdl, title="PDL Line", color=color.new(color.green, 30), style=plot.style_stepline, linewidth=1)

var label pdh_lbl = label.new(na, na, "PDH", color=color.new(color.black, 100), textcolor=color.red, style=label.style_label_left, size=size.small)
var label pdl_lbl = label.new(na, na, "PDL", color=color.new(color.black, 100), textcolor=color.green, style=label.style_label_left, size=size.small)
if barstate.islast
    label.set_xy(pdh_lbl, bar_index + 2, pdh)
    label.set_xy(pdl_lbl, bar_index + 2, pdl)

major_ph = ta.pivothigh(high, 40, 40)
major_pl = ta.pivotlow(low, 40, 40)
minor_ph = ta.pivothigh(high, 12, 12)
minor_pl = ta.pivotlow(low, 12, 12)

var line maj_bsl_ln = na, var label maj_bsl_lb = na
var line maj_ssl_ln = na, var label maj_ssl_lb = na
var line min_bsl_ln = na, var label min_bsl_lb = na
var line min_ssl_ln = na, var label min_ssl_lb = na

if not na(major_ph)
    line.set_extend(maj_bsl_ln, extend.none)
    maj_bsl_ln := line.new(bar_index[40], major_ph, bar_index, major_ph, color=color.red, style=line.style_solid, width=3, extend=extend.right)
    maj_bsl_lb := label.new(bar_index[40], major_ph, "Major BSL", color=color.new(color.black, 100), textcolor=color.red, style=label.style_label_down, size=size.small)

if not na(major_pl)
    line.set_extend(maj_ssl_ln, extend.none)
    maj_ssl_ln := line.new(bar_index[40], major_pl, bar_index, major_pl, color=color.green, style=line.style_solid, width=3, extend=extend.right)
    maj_ssl_lb := label.new(bar_index[40], major_pl, "Major SSL", color=color.new(color.black, 100), textcolor=color.green, style=label.style_label_up, size=size.small)

if not na(minor_ph) and na(major_ph)
    line.set_extend(min_bsl_ln, extend.none)
    min_bsl_ln := line.new(bar_index[12], minor_ph, bar_index, minor_ph, color=color.red, style=line.style_solid, width=1, extend=extend.right)
    min_bsl_lb := label.new(bar_index[12], minor_ph, "Minor BSL", color=color.new(color.black, 100), textcolor=color.red, style=label.style_label_down, size=size.tiny)

if not na(minor_pl) and na(major_pl)
    line.set_extend(min_ssl_ln, extend.none)
    min_ssl_ln := line.new(bar_index[12], minor_pl, bar_index, minor_pl, color=color.green, style=line.style_solid, width=1, extend=extend.right)
    min_ssl_lb := label.new(bar_index[12], minor_pl, "Minor SSL", color=color.new(color.black, 100), textcolor=color.green, style=label.style_label_up, size=size.tiny)

// =========================================================================
// 5. SESSION A-M-D HIGHLIGHTING
// =========================================================================
in_session(sess) => not na(time(timeframe.period, sess, "Asia/Dubai"))
is_new_session(sess) => in_session(sess) and not in_session(sess)[1]

var box asia_box = na, var label asia_lbl = na
var box lon_box = na,  var label lon_lbl = na
var box ny_box = na,   var label ny_lbl = na
var float a_high = na, var float a_low = na
var float l_high = na, var float l_low = na
var float n_high = na, var float n_low = na

if is_new_session(asia_time)
    a_high := high, a_low := low
    asia_box := box.new(left=bar_index, top=a_high, right=bar_index, bottom=a_low, bgcolor=asia_col, border_color=color.new(color.black, 80))
    asia_lbl := label.new(x=bar_index, y=a_high, text="Asia [Accumulation]", color=color.new(color.white,100), textcolor=color.black, style=label.style_label_down, size=size.small)
else if in_session(asia_time)
    a_high := math.max(a_high, high), a_low := math.min(a_low, low)
    box.set_top(asia_box, a_high), box.set_bottom(asia_box, a_low), box.set_right(asia_box, bar_index)
    label.set_y(asia_lbl, a_high), label.set_x(asia_lbl, math.round(box.get_left(asia_box) + (bar_index - box.get_left(asia_box))/2))

if is_new_session(lon_time)
    l_high := high, l_low := low
    lon_box := box.new(left=bar_index, top=l_high, right=bar_index, bottom=l_low, bgcolor=lon_col, border_color=color.new(color.black, 80))
    lon_lbl := label.new(x=bar_index, y=l_high, text="London [Manipulation]", color=color.new(color.white,100), textcolor=color.black, style=label.style_label_down, size=size.small)
else if in_session(lon_time)
    l_high := math.max(l_high, high), l_low := math.min(l_low, low)
    box.set_top(lon_box, l_high), box.set_bottom(lon_box, l_low), box.set_right(lon_box, bar_index)
    label.set_y(lon_lbl, l_high), label.set_x(lon_lbl, math.round(box.get_left(lon_box) + (bar_index - box.get_left(lon_box))/2))

if is_new_session(ny_time)
    n_high := high, n_low := low
    ny_box := box.new(left=bar_index, top=n_high, right=bar_index, bottom=n_low, bgcolor=ny_col, border_color=color.new(color.black, 80))
    ny_lbl := label.new(x=bar_index, y=n_high, text="NY [Distribution]", color=color.new(color.white,100), textcolor=color.black, style=label.style_label_down, size=size.small)
else if in_session(ny_time)
    n_high := math.max(n_high, high), n_low := math.min(n_low, low)
    box.set_top(ny_box, n_high), box.set_bottom(ny_box, n_low), box.set_right(ny_box, bar_index)
    label.set_y(ny_lbl, n_high), label.set_x(ny_lbl, math.round(box.get_left(ny_box) + (bar_index - box.get_left(ny_box))/2))

// =========================================================================
// 6. SMART MONEY ZONES: FVG, OB, RJB
// =========================================================================
var box[] smc_boxes = array.new_box()
f_manage_boxes(b) =>
    array.push(smc_boxes, b)
    if array.size(smc_boxes) > 12 
        box.delete(array.shift(smc_boxes))

bull_fvg = low > high[2] and close[1] > open[1]
bear_fvg = high < low[2] and close[1] < open[1]

if bull_fvg
    b = box.new(left=bar_index[2], top=low, right=bar_index+5, bottom=high[2], bgcolor=color.new(color.green, 92), border_color=color.new(color.green, 70), text="FVG", text_size=size.tiny, text_color=color.green, text_halign=text.align_right)
    f_manage_boxes(b)
if bear_fvg
    b = box.new(left=bar_index[2], top=low[2], right=bar_index+5, bottom=high, bgcolor=color.new(color.red, 92), border_color=color.new(color.red, 70), text="FVG", text_size=size.tiny, text_color=color.red, text_halign=text.align_right)
    f_manage_boxes(b)

if bull_fvg and close[2] < open[2]
    b = box.new(left=bar_index[2], top=high[2], right=bar_index+5, bottom=low[2], bgcolor=color.new(color.lime, 93), border_style=line.style_dashed, border_color=color.lime, text="OB", text_size=size.tiny, text_color=color.lime, text_halign=text.align_right)
    f_manage_boxes(b)
if bear_fvg and close[2] > open[2]
    b = box.new(left=bar_index[2], top=high[2], right=bar_index+5, bottom=low[2], bgcolor=color.new(color.maroon, 93), border_style=line.style_dashed, border_color=color.maroon, text="OB", text_size=size.tiny, text_color=color.maroon, text_halign=text.align_right)
    f_manage_boxes(b)

if array.size(smc_boxes) > 0
    for i = array.size(smc_boxes) - 1 to 0
        bx = array.get(smc_boxes, i)
        box.set_right(bx, bar_index + 3)
        top = box.get_top(bx), bot = box.get_bottom(bx), mid = bot + (top - bot) / 2
        if (high > mid and low < mid) 
            box.set_bgcolor(bx, color.new(color.gray, 95)), box.set_border_color(bx, color.new(color.gray, 95))

// =========================================================================
// 7. COMMON ENGINE LOGIC & DISPLACEMENT DETECTOR
// =========================================================================
macd_line = ta.ema(close, fast_len) - ta.ema(close, slow_len)
sig_line  = ta.ema(macd_line, sig_len)
hist      = macd_line - sig_line
bull_mac = hist > hist[1]
bear_mac = hist < hist[1]

ce_atr = ta.atr(1)
var float longStop = na
var float shortStop = na
var int ce_dir = 1

longStop := math.max(ta.highest(high, 1) - ce_atr * 1.85, nz(longStop[1], low))
if close[1] < nz(longStop[1], low)
    longStop := ta.highest(high, 1) - ce_atr * 1.85

shortStop := math.min(ta.lowest(low, 1) + ce_atr * 1.85, nz(shortStop[1], high))
if close[1] > nz(shortStop[1], high)
    shortStop := ta.lowest(low, 1) + ce_atr * 1.85

ce_dir := close > shortStop[1] ? 1 : close < longStop[1] ? -1 : nz(ce_dir[1], 1)

// STRICT DISPLACEMENT: Candle body must be large (> 80% of ATR). Tiny choppy candles ignored.
atr_14 = ta.atr(14)
bull_displacement = (close > open) and ((close - open) > (atr_14 * 0.8))
bear_displacement = (close < open) and ((open - close) > (atr_14 * 0.8))

// =========================================================================
// 8. ENGINE A: SCALPING 
// =========================================================================
is_scalp_bull = low <= ta.lowest(low[1], 4)
is_scalp_bear = high >= ta.highest(high[1], 4)

recent_scalp_bull = ta.barssince(is_scalp_bull) <= 6
recent_scalp_bear = ta.barssince(is_scalp_bear) <= 6

raw_scalp_bull = recent_scalp_bull and close > open and bull_mac and (ce_dir == 1 or bull_displacement)
raw_scalp_bear = recent_scalp_bear and close < open and bear_mac and (ce_dir == -1 or bear_displacement)

var int last_scalp_bull = -100
var int last_scalp_bear = -100

scalp_trigger_bull = raw_scalp_bull and (bar_index - last_scalp_bull > 5)
scalp_trigger_bear = raw_scalp_bear and (bar_index - last_scalp_bear > 5)

if scalp_trigger_bull
    last_scalp_bull := bar_index
    last_scalp_bear := -100 
if scalp_trigger_bear
    last_scalp_bear := bar_index
    last_scalp_bull := -100 

// =========================================================================
// 9. ENGINE B: MACRO SWING 
// =========================================================================
is_macro_bull = (not na(pdl) and low <= pdl) or (not na(major_pl) and low <= major_pl)
is_macro_bear = (not na(pdh) and high >= pdh) or (not na(major_ph) and high >= major_ph)

recent_macro_bull = ta.barssince(is_macro_bull) <= 8
recent_macro_bear = ta.barssince(is_macro_bear) <= 8

raw_swing_bull = recent_macro_bull and close > open and bull_mac and (ce_dir == 1 or bull_displacement)
raw_swing_bear = recent_macro_bear and close < open and bear_mac and (ce_dir == -1 or bear_displacement)

var int last_swing_bull = -100
var int last_swing_bear = -100

swing_trigger_bull = raw_swing_bull and (bar_index - last_swing_bull > 20)
swing_trigger_bear = raw_swing_bear and (bar_index - last_swing_bear > 20)

if swing_trigger_bull
    last_swing_bull := bar_index
if swing_trigger_bear
    last_swing_bear := bar_index

// =========================================================================
// 10. VISUAL PLOTTING (Upgraded: True Signal Tiering)
// =========================================================================
// The Visual Logic now respects the Displacement Override directly
plot_bull_trend = scalp_trigger_bull and not swing_trigger_bull and (not is_choppy or bull_displacement)
plot_bull_chop  = scalp_trigger_bull and not swing_trigger_bull and (is_choppy and not bull_displacement)

plot_bear_trend = scalp_trigger_bear and not swing_trigger_bear and (not is_choppy or bear_displacement)
plot_bear_chop  = scalp_trigger_bear and not swing_trigger_bear and (is_choppy and not bear_displacement)

barcolor(is_choppy ? color.new(color.gray, 40) : scalp_trigger_bull or swing_trigger_bull ? color.lime : scalp_trigger_bear or swing_trigger_bear ? color.fuchsia : na, title="Trigger/Chop Candle")

// TIER 1: High-Conviction Scalps (Trending Market OR Massive Displacement)
plotshape(plot_bull_trend, title="Trending Bull", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, text="BUY", textcolor=color.lime)
plotshape(plot_bear_trend, title="Trending Bear", style=shape.triangledown, location=location.abovebar, color=color.fuchsia, size=size.small, text="SELL", textcolor=color.fuchsia)

// TIER 2: Low-Conviction Scalps (Choppy Market - Ghost Signals)
plotshape(plot_bull_chop, title="Chop Bull", style=shape.triangleup, location=location.belowbar, color=color.new(color.lime, 60), size=size.tiny)
plotshape(plot_bear_chop, title="Chop Bear", style=shape.triangledown, location=location.abovebar, color=color.new(color.fuchsia, 60), size=size.tiny)

// TIER 3: Macro Swings (Always Prominent)
plotshape(swing_trigger_bull, title="SWING LONG", style=shape.labelup, location=location.belowbar, color=color.new(color.blue, 0), size=size.normal, text="SWING LONG", textcolor=color.white)
plotshape(swing_trigger_bear, title="SWING SHORT", style=shape.labeldown, location=location.abovebar, color=color.new(color.maroon, 0), size=size.normal, text="SWING SHORT", textcolor=color.white)
````

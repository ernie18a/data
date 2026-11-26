# EMA Crossover Strategy [15M]

- url: https://www.tradingview.com/script/UEFr9IXn-EMA-Crossover-Strategy-15M/
- type: indicator
- pine_id: PUB;b8105f2bdf014e5eb895f8074e803b92
- version: 1.0

## Description

EMA Crossover Strategy [15M] — Stats Panel + Pip/$ Tracking + Chop Filter
A clean, rules-based EMA crossover strategy built for XAUUSD (Gold) on the 15-minute timeframe, with multi-timeframe signal confirmation, dynamic risk/reward boxes, and a full live stats panel.

🔧 How It Works
Signals are generated when the Fast EMA (5) crosses the Slow EMA (13) on the higher timeframe. The stop loss is placed at the EMA intersection point, and the take profit is calculated automatically using your chosen Risk:Reward ratio (default 2:1).

📊 Features

✅ Multi-timeframe EMA crossover detection (no repainting)
✅ Dynamic SL placed at EMA intersection — not a fixed pip distance
✅ Automatic TP calculated from your RR ratio
✅ Visual Risk/Reward boxes anchored by time (stay pinned when scrolling/zooming)
✅ VWAP filter — only takes longs above VWAP, shorts below
✅ ADX chop filter — avoids sideways markets below your ADX threshold
✅ EMA separation filter — skips signals when EMAs are too close together
✅ Stats panel (bottom left) — total trades, win rate, net RR, pips captured/lost, net $/oz
✅ Active trade panel (top right) — live entry, SL, TP, risk in pips and price
✅ JSON alerts for webhook/bot integration
✅ TP ✓ and SL ✗ hit labels on chart


⚙️ Inputs
SettingDefaultDescriptionHigher Timeframe15MHTF for EMA signalsFast EMA5Fast EMA lengthSlow EMA13Slow EMA lengthRR Ratio2.0Risk:Reward multiplierVWAP FilterOnTrend direction filterADX FilterOnChop/sideways filterADX Threshold20Minimum ADX for a valid signalEMA Sep FilterOnMinimum EMA gap filterPip Size0.1Set to 0.1 for XAUUSD (OANDA)

📌 Notes

Built and optimised for XAUUSD on OANDA — adjust pip size for other brokers or instruments
Uses barmerge.lookahead_off to prevent repainting
Drawings are anchored by time (xloc.bar_time) so they stay correctly positioned when scrolling or changing zoom
Alerts fire in JSON format — ready for webhook or bot automation


⚠️ Disclaimer
This script is for educational and informational purposes only. Past performance is not indicative of future results. Always manage your own risk.

## Source Code

````pine
// ============================================================================
// EMA Crossover Strategy [15M] — Stats Panel + Pips/$ Tracking + Chop Filter
// Pine Script v6  —  drawings anchored by TIME (xloc.bar_time) so they stay
// pinned to price/time when scrolling or zooming.
// ============================================================================

//@version=6
indicator("EMA Crossover Strategy [15M]", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ============================================================================
// INPUTS
// ============================================================================

htf               = input.timeframe("15", "Higher Timeframe")
fast_len          = input.int(5,   "Fast EMA Length",   minval = 1)
slow_len          = input.int(13,  "Slow EMA Length",   minval = 1)
rr_ratio          = input.float(2.0, "Risk:Reward Ratio", minval = 0.1, step = 0.1)
use_vwap_filter   = input.bool(true,  "Enable VWAP Filter")

// --- Chop filter inputs ---
use_chop_filter   = input.bool(true,  "Enable Chop Filter (ADX)")
adx_len           = input.int(14,    "ADX Length",      minval = 1)
adx_threshold     = input.float(20.0, "ADX Threshold",  minval = 1, step = 0.5)
ema_sep_filter    = input.bool(true,  "Enable EMA Separation Filter")
min_sep_atr       = input.float(0.25, "Min EMA Sep (ATR mult)", minval = 0.0, step = 0.05)

// --- Pip settings (XAUUSD OANDA: 0.1 = 1 pip) ---
pip_size          = input.float(0.1, "Pip Size (XAUUSD OANDA = 0.1)", step = 0.01)

// --- Drawing limits ---
max_open_extend   = input.int(100, "Max Bars to Extend Open Box", minval = 5)

show_stats        = input.bool(true,  "Show Stats Panel")
show_trade_panel  = input.bool(true,  "Show Active Trade Panel")
show_boxes        = input.bool(true,  "Show Risk/Reward Boxes")
show_lines        = input.bool(true,  "Show Entry/SL/TP Lines")
show_price_labels = input.bool(true,  "Show SL/TP Price Labels")

// Approx bar duration in ms (for time-based extension of open drawings)
int bar_ms = timeframe.in_seconds() * 1000

// ============================================================================
// VWAP (used for filter only — not plotted)
// ============================================================================

vwap_val = ta.vwap(hlc3)

bool vwap_ok_buy  = not use_vwap_filter or (not na(vwap_val) and close > vwap_val)
bool vwap_ok_sell = not use_vwap_filter or (not na(vwap_val) and close < vwap_val)

// ============================================================================
// ADX HELPER (ta.adx not available in all builds — derive from ta.dmi)
// ============================================================================

adx_calc(int len) =>
    [_dip, _dim, adx] = ta.dmi(len, len)
    adx

// ============================================================================
// MULTI-TIMEFRAME EMA DATA
// ============================================================================

[ema_fast, ema_fast_prev] = request.security(syminfo.tickerid, htf,
     [ta.ema(close, fast_len), ta.ema(close, fast_len)[1]],
     lookahead = barmerge.lookahead_off)
[ema_slow, ema_slow_prev] = request.security(syminfo.tickerid, htf,
     [ta.ema(close, slow_len), ta.ema(close, slow_len)[1]],
     lookahead = barmerge.lookahead_off)

// ============================================================================
// CHOP FILTER (HTF) — ADX + EMA separation (filters sideways/choppy markets)
// ============================================================================

adx_htf = request.security(syminfo.tickerid, htf, adx_calc(adx_len), lookahead = barmerge.lookahead_off)
atr_htf = request.security(syminfo.tickerid, htf, ta.atr(14),        lookahead = barmerge.lookahead_off)

bool adx_ok = not use_chop_filter or (not na(adx_htf) and adx_htf >= adx_threshold)

float ema_separation = (not na(ema_fast) and not na(ema_slow)) ? math.abs(ema_fast - ema_slow) : na
bool  sep_ok = not ema_sep_filter or (not na(atr_htf) and not na(ema_separation) and ema_separation >= atr_htf * min_sep_atr)

// ============================================================================
// CROSSOVER DETECTION
// ============================================================================

var bool bull_detected = false
var bool bear_detected = false

bool raw_bull = not na(ema_fast) and not na(ema_slow) and not na(ema_fast_prev) and not na(ema_slow_prev) and
     ema_fast_prev <= ema_slow_prev and ema_fast > ema_slow
bool raw_bear = not na(ema_fast) and not na(ema_slow) and not na(ema_fast_prev) and not na(ema_slow_prev) and
     ema_fast_prev >= ema_slow_prev and ema_fast < ema_slow

bool bullish_cross = false
bool bearish_cross = false

if raw_bull and not bull_detected
    bullish_cross := true
    bull_detected := true
    bear_detected := false
else if raw_bull
    bull_detected := true

if raw_bear and not bear_detected
    bearish_cross := true
    bear_detected := true
    bull_detected := false
else if raw_bear
    bear_detected := true

if not raw_bull and not raw_bear
    bull_detected := false
    bear_detected := false

// ============================================================================
// EMA INTERSECTION (stop loss price)
// ============================================================================

calc_sl(float fp, float fc, float sp, float sc) =>
    float dp = fp - sp
    float dc = fc - sc
    float dn = dp - dc
    float r  = na
    if math.abs(dn) > 1e-10
        r := fp + (dp / dn) * (fc - fp)
    r

// ============================================================================
// SIGNAL GENERATION
// ============================================================================

bool  buy_signal  = false
bool  sell_signal = false
float sig_entry   = na
float sig_sl      = na
float sig_tp      = na
int   sig_dir     = 0

if bullish_cross and vwap_ok_buy and adx_ok and sep_ok
    float sl = calc_sl(ema_fast_prev, ema_fast, ema_slow_prev, ema_slow)
    if not na(sl)
        float risk = close - sl
        if risk > 0
            sig_entry  := close
            sig_sl     := sl
            sig_tp     := close + risk * rr_ratio
            sig_dir    := 1
            buy_signal := true

if bearish_cross and vwap_ok_sell and adx_ok and sep_ok
    float sl = calc_sl(ema_fast_prev, ema_fast, ema_slow_prev, ema_slow)
    if not na(sl)
        float risk = sl - close
        if risk > 0
            sig_entry   := close
            sig_sl      := sl
            sig_tp      := close - risk * rr_ratio
            sig_dir     := -1
            sell_signal := true

// ============================================================================
// PERSISTENT TRADE TRACKING ARRAYS
// ============================================================================

var box[]   arr_box_tp   = array.new_box()
var box[]   arr_box_sl   = array.new_box()
var line[]  arr_entry_ln = array.new_line()
var line[]  arr_sl_ln    = array.new_line()
var line[]  arr_tp_ln    = array.new_line()
var label[] arr_sl_lbl   = array.new_label()
var label[] arr_tp_lbl   = array.new_label()
var float[] arr_entry    = array.new_float()
var float[] arr_sl       = array.new_float()
var float[] arr_tp       = array.new_float()
var int[]   arr_dir      = array.new_int()
var bool[]  arr_done     = array.new_bool()
var int[]   arr_start    = array.new_int()    // entry bar_index (for cap count)

// ============================================================================
// STATS COUNTERS
// ============================================================================

var int   stat_total    = 0
var int   stat_tp_hits  = 0
var int   stat_sl_hits  = 0
var int   stat_buys     = 0
var int   stat_sells    = 0
var float stat_net_rr   = 0.0
var float stat_total_risk   = 0.0
var float stat_total_reward = 0.0

// --- Pip / dollar counters ---
var float stat_pips_tp    = 0.0   // pips captured on TP hits
var float stat_pips_sl    = 0.0   // pips lost on SL hits
var float stat_dollars_tp = 0.0   // $/oz captured on TP hits
var float stat_dollars_sl = 0.0   // $/oz lost on SL hits

// ============================================================================
// NEW TRADE — draw boxes (TIME anchored), push to arrays, update counters
// ============================================================================

if (buy_signal or sell_signal) and not na(sig_entry) and not na(sig_sl) and not na(sig_tp)

    box  bx_tp    = na
    box  bx_sl    = na
    line ln_entry = na
    line ln_sl    = na
    line ln_tp    = na
    label lbl_sl  = na
    label lbl_tp  = na

    int t1 = time                 // start time (this bar's open time)
    int t2 = time + bar_ms        // one bar to the right, in TIME

    if show_boxes
        if sig_dir == 1
            bx_tp := box.new(t1, sig_tp,    t2, sig_entry, xloc = xloc.bar_time,
                 border_color = color.new(#00C853, 40), bgcolor = color.new(#00C853, 80), border_width = 1)
            bx_sl := box.new(t1, sig_entry, t2, sig_sl,    xloc = xloc.bar_time,
                 border_color = color.new(#FF1744, 40), bgcolor = color.new(#FF1744, 80), border_width = 1)
        else
            bx_sl := box.new(t1, sig_sl,    t2, sig_entry, xloc = xloc.bar_time,
                 border_color = color.new(#FF1744, 40), bgcolor = color.new(#FF1744, 80), border_width = 1)
            bx_tp := box.new(t1, sig_entry, t2, sig_tp,    xloc = xloc.bar_time,
                 border_color = color.new(#00C853, 40), bgcolor = color.new(#00C853, 80), border_width = 1)

    if show_lines
        ln_entry := line.new(t1, sig_entry, t2, sig_entry, xloc = xloc.bar_time,
             color = color.new(color.white, 30), style = line.style_dashed, width = 1)
        ln_sl    := line.new(t1, sig_sl,    t2, sig_sl,    xloc = xloc.bar_time,
             color = color.new(#FF1744, 30), style = line.style_dashed, width = 1)
        ln_tp    := line.new(t1, sig_tp,    t2, sig_tp,    xloc = xloc.bar_time,
             color = color.new(#00C853, 30), style = line.style_dashed, width = 1)

    if show_price_labels
        lbl_sl := label.new(t2, sig_sl, xloc = xloc.bar_time,
             text = "SL " + str.tostring(sig_sl, "#.##"),
             style = label.style_label_left,
             color = color.new(#FF1744, 10), textcolor = color.white, size = size.small)
        lbl_tp := label.new(t2, sig_tp, xloc = xloc.bar_time,
             text = "TP " + str.tostring(sig_tp, "#.##"),
             style = label.style_label_left,
             color = color.new(#00C853, 10), textcolor = color.white, size = size.small)

    if sig_dir == 1
        label.new(t1, low,  "BUY",  xloc = xloc.bar_time, style = label.style_label_up,
             color = color.new(#00C853, 0), textcolor = color.white, size = size.small)
    else
        label.new(t1, high, "SELL", xloc = xloc.bar_time, style = label.style_label_down,
             color = color.new(#FF1744, 0), textcolor = color.white, size = size.small)

    // Update counters
    stat_total += 1
    if sig_dir == 1
        stat_buys  += 1
    else
        stat_sells += 1

    float trade_risk = sig_dir == 1 ? sig_entry - sig_sl : sig_sl - sig_entry
    stat_total_risk += trade_risk

    // Push to arrays
    array.push(arr_box_tp,   bx_tp)
    array.push(arr_box_sl,   bx_sl)
    array.push(arr_entry_ln, ln_entry)
    array.push(arr_sl_ln,    ln_sl)
    array.push(arr_tp_ln,    ln_tp)
    array.push(arr_sl_lbl,   lbl_sl)
    array.push(arr_tp_lbl,   lbl_tp)
    array.push(arr_entry,    sig_entry)
    array.push(arr_sl,       sig_sl)
    array.push(arr_tp,       sig_tp)
    array.push(arr_dir,      sig_dir)
    array.push(arr_done,     false)
    array.push(arr_start,    bar_index)

    // Alert
    string ad = sig_dir == 1 ? "BUY" : "SELL"
    alert('{"signal":"' + ad + '","symbol":"' + syminfo.ticker + '","entry":' + str.tostring(sig_entry, "#.##") + ',"sl":' + str.tostring(sig_sl, "#.##") + ',"tp":' + str.tostring(sig_tp, "#.##") + ',"rr":' + str.tostring(rr_ratio, "#.##") + '}', alert.freq_once_per_bar)

// ============================================================================
// EVERY BAR — extend open boxes (capped, TIME based); freeze on TP/SL hit
// Confirmed bars only, so nothing twitches intrabar while scrolling.
// ============================================================================

if barstate.isconfirmed
    int n = array.size(arr_entry)
    if n > 0
        for i = 0 to n - 1
            bool t_done = array.get(arr_done, i)

            if not t_done
                float t_entry = array.get(arr_entry, i)
                float t_sl    = array.get(arr_sl,    i)
                float t_tp    = array.get(arr_tp,    i)
                int   t_dir   = array.get(arr_dir,   i)
                int   t_start = array.get(arr_start, i)

                bool hit_tp = t_dir == 1 ? high >= t_tp : low  <= t_tp
                bool hit_sl = t_dir == 1 ? low  <= t_sl : high >= t_sl

                if hit_tp or hit_sl
                    int freeze_t = time            // freeze at current bar TIME

                    if show_boxes
                        box btp = array.get(arr_box_tp, i)
                        box bsl = array.get(arr_box_sl, i)
                        if not na(btp)
                            box.set_right(btp, freeze_t)
                        if not na(bsl)
                            box.set_right(bsl, freeze_t)

                    if show_lines
                        line le = array.get(arr_entry_ln, i)
                        line ls = array.get(arr_sl_ln,    i)
                        line lt = array.get(arr_tp_ln,    i)
                        if not na(le)
                            line.set_x2(le, freeze_t)
                        if not na(ls)
                            line.set_x2(ls, freeze_t)
                        if not na(lt)
                            line.set_x2(lt, freeze_t)

                    if hit_tp
                        stat_tp_hits      += 1
                        stat_net_rr       += rr_ratio
                        float pm_tp        = t_dir == 1 ? t_tp - t_entry : t_entry - t_tp
                        stat_total_reward += pm_tp
                        stat_pips_tp      += pm_tp / pip_size
                        stat_dollars_tp   += pm_tp
                        label.new(time, t_dir == 1 ? high : low, "TP ✓", xloc = xloc.bar_time,
                             style     = t_dir == 1 ? label.style_label_down : label.style_label_up,
                             color     = color.new(#00C853, 0), textcolor = color.white, size = size.small)
                        alert('{"event":"TP_HIT","direction":"' + (t_dir == 1 ? "BUY" : "SELL") + '","tp":' + str.tostring(t_tp, "#.##") + '}', alert.freq_once_per_bar)
                    else
                        stat_sl_hits    += 1
                        stat_net_rr     -= 1.0
                        float pm_sl      = t_dir == 1 ? t_entry - t_sl : t_sl - t_entry
                        stat_pips_sl    += pm_sl / pip_size
                        stat_dollars_sl += pm_sl
                        label.new(time, t_dir == 1 ? low : high, "SL ✗", xloc = xloc.bar_time,
                             style     = t_dir == 1 ? label.style_label_up : label.style_label_down,
                             color     = color.new(#FF1744, 0), textcolor = color.white, size = size.small)
                        alert('{"event":"SL_HIT","direction":"' + (t_dir == 1 ? "BUY" : "SELL") + '","sl":' + str.tostring(t_sl, "#.##") + '}', alert.freq_once_per_bar)

                    array.set(arr_done, i, true)

                else
                    // Cap extension in BARS, convert the cap edge to TIME
                    int bars_open  = bar_index - t_start
                    int extend_bars = math.min(bars_open + 1, max_open_extend)
                    // right edge time = start bar time + extend_bars worth of bars.
                    // start bar time = current time - bars_open bars
                    int right_t = time + (extend_bars - bars_open) * bar_ms

                    if show_boxes
                        box btp = array.get(arr_box_tp, i)
                        box bsl = array.get(arr_box_sl, i)
                        if not na(btp)
                            box.set_right(btp, right_t)
                        if not na(bsl)
                            box.set_right(bsl, right_t)

                    if show_lines
                        line le = array.get(arr_entry_ln, i)
                        line ls = array.get(arr_sl_ln,    i)
                        line lt = array.get(arr_tp_ln,    i)
                        if not na(le)
                            line.set_x2(le, right_t)
                        if not na(ls)
                            line.set_x2(ls, right_t)
                        if not na(lt)
                            line.set_x2(lt, right_t)

                    if show_price_labels
                        label ls = array.get(arr_sl_lbl, i)
                        label lt = array.get(arr_tp_lbl, i)
                        if not na(ls)
                            label.set_x(ls, right_t)
                        if not na(lt)
                            label.set_x(lt, right_t)

// ============================================================================
// ACTIVE TRADE STATE (for active trade panel)
// ============================================================================

var float active_entry = na
var float active_sl    = na
var float active_tp    = na
var bool  in_trade     = false
var int   trade_dir    = 0

if buy_signal
    active_entry := sig_entry
    active_sl    := sig_sl
    active_tp    := sig_tp
    in_trade     := true
    trade_dir    := 1

if sell_signal
    active_entry := sig_entry
    active_sl    := sig_sl
    active_tp    := sig_tp
    in_trade     := true
    trade_dir    := -1

// ============================================================================
// SIGNAL SHAPE MARKERS
// ============================================================================

plotshape(buy_signal,  "Buy",  shape.triangleup,   location.belowbar, color.new(#00C853, 0), size = size.small)
plotshape(sell_signal, "Sell", shape.triangledown, location.abovebar, color.new(#FF1744, 0), size = size.small)

// ============================================================================
// STATS PANEL (bottom left) — all historical trades
// ============================================================================

var table stats_panel = na

if show_stats and barstate.islast
    if not na(stats_panel)
        table.delete(stats_panel)

    int   resolved    = stat_tp_hits + stat_sl_hits
    float win_rate    = resolved > 0 ? (stat_tp_hits / resolved) * 100 : 0.0
    float avg_rr      = resolved > 0 ? stat_net_rr / resolved : 0.0
    color net_color   = stat_net_rr >= 0 ? color.new(#00C853, 0) : color.new(#FF1744, 0)
    color wr_color    = win_rate >= 50 ? color.new(#00C853, 0) : color.new(#FF1744, 0)

    float net_pips    = stat_pips_tp - stat_pips_sl
    float net_dollars = stat_dollars_tp - stat_dollars_sl

    stats_panel := table.new(position.bottom_left, 2, 16,
         bgcolor      = color.new(#0D1117, 5),
         border_color = color.new(#30363D, 0),
         border_width = 1,
         frame_color  = color.new(#30363D, 0),
         frame_width  = 1)

    // Header
    table.cell(stats_panel, 0, 0, "📈 STRATEGY STATS", text_color = color.new(#58A6FF, 0), text_size = size.small, bgcolor = color.new(#161B22, 0))
    table.cell(stats_panel, 1, 0, "",                   text_color = color.new(#58A6FF, 0), text_size = size.small, bgcolor = color.new(#161B22, 0))

    // Separator row
    table.cell(stats_panel, 0, 1, "─────────────", text_color = color.new(#30363D, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
    table.cell(stats_panel, 1, 1, "─────────────", text_color = color.new(#30363D, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))

    // Total trades
    table.cell(stats_panel, 0, 2, "Total Trades",  text_color = color.new(#8B949E, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
    table.cell(stats_panel, 1, 2, str.tostring(stat_total), text_color = color.white, text_size = size.tiny, bgcolor = color.new(#0D1117, 0))

    // Buys / Sells
    table.cell(stats_panel, 0, 3, "Buys / Sells",  text_color = color.new(#8B949E, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
    table.cell(stats_panel, 1, 3, str.tostring(stat_buys) + " / " + str.tostring(stat_sells),
         text_color = color.new(#E6EDF3, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))

    // TP Hits
    table.cell(stats_panel, 0, 4, "TP Hits",       text_color = color.new(#8B949E, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
    table.cell(stats_panel, 1, 4, str.tostring(stat_tp_hits),
         text_color = color.new(#00C853, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))

    // SL Hits
    table.cell(stats_panel, 0, 5, "SL Hits",       text_color = color.new(#8B949E, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
    table.cell(stats_panel, 1, 5, str.tostring(stat_sl_hits),
         text_color = color.new(#FF1744, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))

    // Open trades
    int open_trades = stat_total - resolved
    table.cell(stats_panel, 0, 6, "Open",          text_color = color.new(#8B949E, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
    table.cell(stats_panel, 1, 6, str.tostring(open_trades),
         text_color = color.new(#FFA500, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))

    // Win Rate
    table.cell(stats_panel, 0, 7, "Win Rate",      text_color = color.new(#8B949E, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
    table.cell(stats_panel, 1, 7, str.tostring(win_rate, "#.#") + "%",
         text_color = wr_color, text_size = size.tiny, bgcolor = color.new(#0D1117, 0))

    // Net RR
    table.cell(stats_panel, 0, 8, "Net RR",        text_color = color.new(#8B949E, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
    table.cell(stats_panel, 1, 8, (stat_net_rr >= 0 ? "+" : "") + str.tostring(stat_net_rr, "#.##") + "R",
         text_color = net_color, text_size = size.tiny, bgcolor = color.new(#0D1117, 0))

    // Avg RR per trade
    table.cell(stats_panel, 0, 9, "Avg RR/Trade",  text_color = color.new(#8B949E, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
    table.cell(stats_panel, 1, 9, (avg_rr >= 0 ? "+" : "") + str.tostring(avg_rr, "#.##") + "R",
         text_color = avg_rr >= 0 ? color.new(#00C853, 0) : color.new(#FF1744, 0),
         text_size = size.tiny, bgcolor = color.new(#0D1117, 0))

    // Pips Captured (TP)
    table.cell(stats_panel, 0, 10, "Pips Captured", text_color = color.new(#8B949E, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
    table.cell(stats_panel, 1, 10, "+" + str.tostring(stat_pips_tp, "#.#"),
         text_color = color.new(#00C853, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))

    // Pips Lost (SL)
    table.cell(stats_panel, 0, 11, "Pips Lost (SL)", text_color = color.new(#8B949E, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
    table.cell(stats_panel, 1, 11, "-" + str.tostring(stat_pips_sl, "#.#"),
         text_color = color.new(#FF1744, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))

    // Net Pips
    table.cell(stats_panel, 0, 12, "Net Pips",      text_color = color.new(#8B949E, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
    table.cell(stats_panel, 1, 12, (net_pips >= 0 ? "+" : "") + str.tostring(net_pips, "#.#"),
         text_color = net_pips >= 0 ? color.new(#00C853, 0) : color.new(#FF1744, 0),
         text_size = size.tiny, bgcolor = color.new(#0D1117, 0))

    // Net $/oz
    table.cell(stats_panel, 0, 13, "Net \$/oz",     text_color = color.new(#8B949E, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
    table.cell(stats_panel, 1, 13, (net_dollars >= 0 ? "+\$" : "-\$") + str.tostring(math.abs(net_dollars), "#.##"),
         text_color = net_dollars >= 0 ? color.new(#00C853, 0) : color.new(#FF1744, 0),
         text_size = size.tiny, bgcolor = color.new(#0D1117, 0))

    // RR Setting
    table.cell(stats_panel, 0, 14, "RR Setting",   text_color = color.new(#8B949E, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
    table.cell(stats_panel, 1, 14, "1:" + str.tostring(rr_ratio, "#.#"),
         text_color = color.new(#58A6FF, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))

    // Filters status (VWAP + Chop)
    string flt_txt = (use_vwap_filter ? "VWAP " : "") + (use_chop_filter ? "ADX " : "") + (ema_sep_filter ? "SEP" : "")
    flt_txt := flt_txt == "" ? "OFF" : flt_txt
    color  flt_color = (use_vwap_filter or use_chop_filter or ema_sep_filter) ? color.new(#00C853, 0) : color.new(#8B949E, 0)
    table.cell(stats_panel, 0, 15, "Filters",      text_color = color.new(#8B949E, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
    table.cell(stats_panel, 1, 15, flt_txt,         text_color = flt_color, text_size = size.tiny, bgcolor = color.new(#0D1117, 0))

// ============================================================================
// ACTIVE TRADE PANEL (top right) — current open trade only
// ============================================================================

var table trade_panel = na

if show_trade_panel and barstate.islast
    if in_trade and not na(active_entry)
        if not na(trade_panel)
            table.delete(trade_panel)

        trade_panel := table.new(position.top_right, 2, 10,
             bgcolor      = color.new(#0D1117, 5),
             border_color = color.new(#30363D, 0),
             border_width = 1,
             frame_color  = color.new(#30363D, 0),
             frame_width  = 1)

        string dir_text  = trade_dir == 1 ? "▲ BUY" : "▼ SELL"
        color  dir_color = trade_dir == 1 ? color.new(#00C853, 0) : color.new(#FF1744, 0)

        table.cell(trade_panel, 0, 0, "ACTIVE TRADE", text_color = color.new(#58A6FF, 0), text_size = size.small, bgcolor = color.new(#161B22, 0))
        table.cell(trade_panel, 1, 0, dir_text,         text_color = dir_color,             text_size = size.small, bgcolor = color.new(#161B22, 0))

        table.cell(trade_panel, 0, 1, "Symbol",    text_color = color.new(#8B949E, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
        table.cell(trade_panel, 1, 1, syminfo.ticker, text_color = color.white, text_size = size.tiny, bgcolor = color.new(#0D1117, 0))

        table.cell(trade_panel, 0, 2, "Timeframe", text_color = color.new(#8B949E, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
        table.cell(trade_panel, 1, 2, htf + "M",   text_color = color.white, text_size = size.tiny, bgcolor = color.new(#0D1117, 0))

        table.cell(trade_panel, 0, 3, "Entry",     text_color = color.new(#8B949E, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
        table.cell(trade_panel, 1, 3, str.tostring(active_entry, "#.##"), text_color = color.white, text_size = size.tiny, bgcolor = color.new(#0D1117, 0))

        table.cell(trade_panel, 0, 4, "Stop Loss", text_color = color.new(#8B949E, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
        table.cell(trade_panel, 1, 4, str.tostring(active_sl, "#.##"), text_color = color.new(#FF1744, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))

        table.cell(trade_panel, 0, 5, "Take Profit", text_color = color.new(#8B949E, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
        table.cell(trade_panel, 1, 5, str.tostring(active_tp, "#.##"), text_color = color.new(#00C853, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))

        float dr = trade_dir == 1 ? active_entry - active_sl : active_sl - active_entry
        table.cell(trade_panel, 0, 6, "Risk",      text_color = color.new(#8B949E, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
        table.cell(trade_panel, 1, 6, str.tostring(dr, "#.##"), text_color = color.new(#FFA500, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))

        table.cell(trade_panel, 0, 7, "Reward",    text_color = color.new(#8B949E, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
        table.cell(trade_panel, 1, 7, str.tostring(dr * rr_ratio, "#.##"), text_color = color.new(#00C853, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))

        // Pips at risk / target
        table.cell(trade_panel, 0, 8, "Pips (R/T)", text_color = color.new(#8B949E, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
        table.cell(trade_panel, 1, 8, str.tostring(dr / pip_size, "#.#") + " / " + str.tostring((dr * rr_ratio) / pip_size, "#.#"),
             text_color = color.new(#E6EDF3, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))

        table.cell(trade_panel, 0, 9, "RR",        text_color = color.new(#8B949E, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
        table.cell(trade_panel, 1, 9, "1:" + str.tostring(rr_ratio, "#.#"), text_color = color.new(#58A6FF, 0), text_size = size.tiny, bgcolor = color.new(#0D1117, 0))
    else
        if not na(trade_panel)
            table.delete(trade_panel)
            trade_panel := na

// ============================================================================
// ALERT CONDITIONS
// ============================================================================

alertcondition(buy_signal,  "Buy Signal",  "BUY Signal - EMA Crossover")
alertcondition(sell_signal, "Sell Signal", "SELL Signal - EMA Crossover")

// ============================================================================
// END OF SCRIPT
// ============================================================================
````

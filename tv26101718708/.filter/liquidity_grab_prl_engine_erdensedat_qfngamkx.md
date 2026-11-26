# Liquidity Grab & PRL Engine [erdensedat]

- url: https://www.tradingview.com/script/QFngAmkx-Liquidity-Grab-PRL-Engine-erdensedat/
- type: indicator
- pine_id: PUB;c7c14f83e982428ab2ebd8472c42e943
- version: 4.0

## Description

Liquidity Grab & PRL Engine [erdensedat]
Overview
The Liquidity Grab & PRL Engine is a highly advanced, institutional-grade market structure indicator designed to identify macro liquidity sweeps, track wick rejections, and pinpoint high-probability trend reversals. Instead of relying on lagging indicators, this engine reads raw price action and liquidity pools to catch the exact moment a trend is exhausted and ready to reverse.

It comes equipped with an automated trade setup generator (Entry, SL, and TP zones) and a built-in backtesting panel to track your daily and all-time win rates in real-time.

Core Concepts & How It Works
1. Macro Liquidity Pools
The algorithm constantly scans the chart for significant structural pivots (Macro Highs and Lows). Once a major pivot is identified, it draws an unmitigated "Macro Liq" (Orange dashed line) representing a structural liquidity pool. Retail traders often place their stop losses at these levels, making them a magnet for institutional price delivery.

2. Liquidity Grab Zone (The Trap)
When the price breaks a Macro Liquidity line, the indicator does not immediately signal a continuation. Instead, it marks the breakout candle as a "Liq Grab Zone". This assumes the breakout might be a fake-out designed to hunt stops (a sweep) before a reversal.

3. PRL (Possible Reversal Line) Tracking
This is where the magic happens. After a Liquidity Grab, the engine activates its dynamic wick-tracking system:

It anchors a tracking line to the absolute high/low of the grab candle.
As long as consecutive candles keep pushing the extreme (higher highs or lower lows), the slope line follows the price tightly.
The Reversal Signal: The moment a confirmed candle fails to break the previous extreme (a shorter wick), the tracking stops. A solid, horizontal PRL (Possible Reversal Line) is instantly born. This flat line indicates that the liquidity sweep is over, momentum has shifted, and a reversal is imminent.
4. Automated Trade Setups & Dynamic Fibo Engine
Once a PRL is confirmed, the engine automatically generates a full trade setup:

Entry Level: The exact price of the PRL formation.
TP 1 Zone: A semi-transparent target box dynamically calculated using hidden Fibonacci logic (0.618 to 0.764) based on the distance between the grab and the previous macro level.
Stop Loss (SL): A dynamic invalidation line calculated using an adjustable multiplier (default: -0.25) beyond the extreme wick.
Smart Display: Only the most recent setup is tracked dynamically across the chart. Past setups are frozen exactly where they hit TP, SL, or were invalidated by a new setup, leaving a clean historical footprint.
5. Pro Winrate & Performance Panel
The indicator acts as its own backtester. A sleek, non-intrusive UI panel tracks every executed setup in the background:

Live Status: Tells you if a trade is "Awaiting Setup", "Active", "TP Hit", or "SL Hit".
Daily Stats: Tracks today's closed trades, Win/Loss ratio, and total R-R flow (Risk-to-Reward accumulation).
All-Time Stats: Calculates the overall Win Rate of the strategy, automatically changing color (Green/Red) based on profitability.
6. MA Trend Filter (Optional)
For traders who prefer trading with the higher timeframe trend, there is an optional Moving Average filter (default: 200 EMA). When enabled, the engine will only validate Long setups if the price is above the MA, and Short setups if the price is below the MA, drastically increasing the quality of the signals.

How to Use It
Wait for the price to sweep a Macro Liq line and print a Liq Grab Zone.
Watch the dashed tracking line follow the wicks.
Wait for the solid PRL line to form (Confirmed Reversal).
Execute the trade at the Entry Level, place your stop at the SL Line, and target the TP Zone.
Disclaimer
This indicator is for educational and informational purposes only. Trading in financial markets involves a high degree of risk and may not be suitable for all investors. The automated setups and win rates displayed by this tool are based on historical price action and mechanical algorithms; they do not guarantee future results. Always perform your own analysis, practice strict risk management, and never trade with money you cannot afford to lose. The author (erdensedat) assumes no responsibility for any trading losses incurred while using this script.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © erdensedat
//@version=6
indicator("Liquidity Grab & PRL Engine [erdensedat]", shorttitle="PRL Engine", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

//==================== INPUTS ====================
grp_main = "Macro Settings (Default)"
len = input.int(20, "Macro Pivot Length", minval=3, maxval=100, group=grp_main)

grp_htf = "HTF Settings (Alternative)"
use_htf = input.bool(false, "Use HTF Mode (Previous Bar High/Low)", group=grp_htf, tooltip="If ON: Replaces Macro Pivots with the High/Low of the previous HTF bar.")
htf_res = input.timeframe("240", "HTF Resolution", group=grp_htf)

grp_session = "SMC Session Liquidity"
use_sess_liq = input.bool(false, "Use Session Liquidity (Overrides HTF/Macro)", group=grp_session, tooltip="If ON: The Liquidity Targets will be the High & Low of the last ended trading session.")
tz = input.string("America/New_York", "Timezone", group=grp_session)
asia_sess = input.session("2000-0000", "Asian Session", group=grp_session)
lon_sess = input.session("0300-0800", "London Session", group=grp_session)
ny_sess = input.session("0900-1600", "New York Session", group=grp_session)

grp_style = "Styling"
bull_color = input.color(color.new(#089981, 0), "Bullish Color", group=grp_style)
bear_color = input.color(color.new(#f23645, 0), "Bearish Color", group=grp_style)
liq_color = input.color(color.new(color.orange, 0), "Unmitigated Liquidity Color", group=grp_style)

grp_prl = "Hokkabazlık (PRL Tracking)"
show_hokkabazlik = input.bool(true, "Show Tracking & PRL Lines", group=grp_prl)
show_targets = input.bool(true, "Show Entry, SL, TP Zones", group=grp_prl)
show_last_n = input.int(1, "Show Last N Setups", minval=1, maxval=50, group=grp_prl)
sl_multiplier = input.float(0.25, "Stop Loss Multiplier", minval=0.01, step=0.05, group=grp_prl)

grp_filters = "Advanced Filters"
use_chop = input.bool(false, "Use Chop Filter", group=grp_filters, tooltip="Avoid trading when the market is choppy/ranging.")
chop_len = input.int(14, "Chop Length", minval=1, maxval=50, group=grp_filters)
chop_threshold = input.float(61.8, "Chop Threshold", minval=1, maxval=100, group=grp_filters)

use_adx = input.bool(false, "Use ADX Trend Filter", group=grp_filters, tooltip="Blocks counter-trend trades if the market is in a hardcore hardcore trend.")
adx_len = input.int(14, "ADX Length", group=grp_filters)
adx_thresh = input.float(25, "ADX Strong Trend Threshold", group=grp_filters)

use_rsi = input.bool(false, "Use RSI Momentum Filter", group=grp_filters, tooltip="Blocks setups if RSI is too overbought/oversold, meaning it's a true breakout, not a grab.")
rsi_ob = input.float(75, "RSI Overbought (Block Shorts)", group=grp_filters)
rsi_os = input.float(25, "RSI Oversold (Block Longs)", group=grp_filters)

use_mom = input.bool(false, "Use Momentum Filter", group=grp_filters, tooltip="Requires positive momentum for Longs and negative momentum for Shorts.")
mom_len = input.int(10, "Momentum Length", minval=1, maxval=50, group=grp_filters)

use_vol = input.bool(false, "Use Volume Filter", group=grp_filters, tooltip="Requires the setup confirmation bar to have above-average volume.")
vol_len = input.int(20, "Volume MA Length", group=grp_filters)

use_pa = input.bool(false, "Use PA (Price Action) Filter", group=grp_filters, tooltip="Requires the PRL confirmation bar to close in the direction of the setup (Bearish close for Shorts, Bullish close for Longs).")

grp_wick = "Wick Filter (Grab Bar)"
use_wick = input.bool(true, "Require Wick on Grab Bar", group=grp_wick, tooltip="Requires the candle breaking the liquidity zone to have a meaningful wick.")
min_wick_pct = input.float(20.0, "Minimum Wick Size (%)", minval=1, maxval=100, group=grp_wick, tooltip="Minimum size of the wick as a percentage of the total candle range.")

grp_panel = "Winrate Panel"
show_panel = input.bool(true, "Show Winrate Panel", group=grp_panel)

grp_ma = "Moving Average & Trend Filter"
show_ma = input.bool(false, "Show Moving Average", group=grp_ma)
use_ma_filter = input.bool(false, "Use MA as Trend Filter for Setups", group=grp_ma)
ma_type = input.string("EMA", "MA Type", options=["SMA", "EMA", "WMA", "RMA"], group=grp_ma)
ma_len = input.int(200, "MA Length", minval=1, group=grp_ma)
ma_color = input.color(color.new(color.blue, 0), "MA Color", group=grp_ma)
ma_width = input.int(2, "MA Width", minval=1, maxval=5, group=grp_ma)

grp_vwap = "VWAP (Optional)"
show_vwap = input.bool(false, "Show VWAP", group=grp_vwap)
vwap_color = input.color(color.new(color.fuchsia, 0), "VWAP Color", group=grp_vwap)
vwap_width = input.int(2, "VWAP Width", minval=1, maxval=5, group=grp_vwap)

//==================== HELPERS ====================
L = (len % 2 == 0) ? (len + 1) : len
p = int(L / 2)
float g_atr = ta.atr(14)

[h_htf, l_htf] = request.security(syminfo.tickerid, htf_res, [high[1], low[1]], lookahead=barmerge.lookahead_on)
int current_htf_time = time(htf_res)
bool is_new_htf = ta.change(current_htf_time) != 0

//==================== SESSIONS LOGIC ====================
bool in_asia = not na(time(timeframe.period, asia_sess, tz))
bool in_lon = not na(time(timeframe.period, lon_sess, tz))
bool in_ny = not na(time(timeframe.period, ny_sess, tz))

var float cur_asia_h = na, var float cur_asia_l = na
var float cur_lon_h = na, var float cur_lon_l = na
var float cur_ny_h = na, var float cur_ny_l = na

if in_asia
    cur_asia_h := na(cur_asia_h) ? high : math.max(cur_asia_h, high)
    cur_asia_l := na(cur_asia_l) ? low : math.min(cur_asia_l, low)
if in_lon
    cur_lon_h := na(cur_lon_h) ? high : math.max(cur_lon_h, high)
    cur_lon_l := na(cur_lon_l) ? low : math.min(cur_lon_l, low)
if in_ny
    cur_ny_h := na(cur_ny_h) ? high : math.max(cur_ny_h, high)
    cur_ny_l := na(cur_ny_l) ? low : math.min(cur_ny_l, low)

bool asia_ended = not in_asia and in_asia[1]
bool lon_ended = not in_lon and in_lon[1]
bool ny_ended = not in_ny and in_ny[1]

//==================== ADVANCED FILTERS LOGIC ====================
// Chop
f_chop(_len) =>
    100 * math.log10(math.sum(ta.atr(1), _len) / (ta.highest(high, _len) - ta.lowest(low, _len))) / math.log10(_len)
float chop_val = use_chop ? f_chop(chop_len) : na
bool is_choppy = use_chop ? (chop_val > chop_threshold) : false

// ADX
[diplus, diminus, adx] = ta.dmi(adx_len, adx_len)
bool adx_bull_ok = not use_adx or not (adx > adx_thresh and diminus > diplus)
bool adx_bear_ok = not use_adx or not (adx > adx_thresh and diplus > diminus)

// RSI
float rsi_val = ta.rsi(close, 14)
bool rsi_bull_ok = not use_rsi or (rsi_val >= rsi_os)
bool rsi_bear_ok = not use_rsi or (rsi_val <= rsi_ob)

// Momentum
float mom_val = ta.mom(close, mom_len)
bool mom_bull_ok = not use_mom or (mom_val > 0)
bool mom_bear_ok = not use_mom or (mom_val < 0)

// Volume
float vol_ma = ta.sma(volume, vol_len)
bool vol_ok = not use_vol or (volume > vol_ma)

// PA (Price Action)
bool pa_bear_ok = not use_pa or (close < open)
bool pa_bull_ok = not use_pa or (close > open)

// Wick
float candle_rng = high - low == 0 ? 1 : high - low
float up_wick = high - math.max(open, close)
float dn_wick = math.min(open, close) - low
bool top_wick_ok = not use_wick or ((up_wick / candle_rng) * 100 >= min_wick_pct)
bool btm_wick_ok = not use_wick or ((dn_wick / candle_rng) * 100 >= min_wick_pct)

//==================== OPTIONAL INDICATORS ====================
float ma_val = na
if show_ma or use_ma_filter
    if ma_type == "SMA"
        ma_val := ta.sma(close, ma_len)
    else if ma_type == "EMA"
        ma_val := ta.ema(close, ma_len)
    else if ma_type == "WMA"
        ma_val := ta.wma(close, ma_len)
    else if ma_type == "RMA"
        ma_val := ta.rma(close, ma_len)
plot(show_ma ? ma_val : na, title="MA", color=ma_color, linewidth=ma_width)

float vwap_val = na
if show_vwap
    vwap_val := ta.vwap(hlc3)
plot(show_vwap ? vwap_val : na, title="VWAP", color=vwap_color, linewidth=vwap_width)

//==================== LABEL MANAGER ====================
var map<int, int> top_counts = map.new<int, int>()
var map<int, int> btm_counts = map.new<int, int>()
var map<string, int> label_memory = map.new<string, int>()

f_add_top_label(_x, _y, _txt, _col) =>
    string mem_key = str.tostring(_x) + "_" + _txt
    if not label_memory.contains(mem_key)
        label_memory.put(mem_key, 1)
        int c = top_counts.contains(_x) ? top_counts.get(_x) : 0
        string final_txt = _txt
        if c > 0
            for i = 1 to c
                final_txt := final_txt + "\n\n\n"
        final_txt := final_txt + "\n"
        label.new(_x, _y, final_txt, color=color(na), textcolor=_col, style=label.style_label_down, size=size.small)
        top_counts.put(_x, c + 1)

f_add_btm_label(_x, _y, _txt, _col) =>
    string mem_key = str.tostring(_x) + "_" + _txt
    if not label_memory.contains(mem_key)
        label_memory.put(mem_key, 1)
        int c = btm_counts.contains(_x) ? btm_counts.get(_x) : 0
        string final_txt = _txt
        if c > 0
            for i = 1 to c
                final_txt := "\n\n\n" + final_txt
        final_txt := "\n" + final_txt
        label.new(_x, _y, final_txt, color=color(na), textcolor=_col, style=label.style_label_up, size=size.small)
        btm_counts.put(_x, c + 1)

//==================== TRADE PERFORMANCE & MULTI-SETUP ENGINE ====================
type TradeSetup
    int dir
    float tp_level
    float sl_level
    float entry_level
    float active_rr
    box tp_box
    line sl_line
    line entry_line
    label entry_lbl
    label sl_lbl
    label tp_lbl
    bool is_active
    int end_bar

var TradeSetup[] setups = array.new<TradeSetup>()

var int total_trades = 0
var int total_wins = 0
var int total_losses = 0

// Daily tracking
var int d_wins = 0
var int d_losses = 0
var float d_rr = 0.0

if ta.change(time("D")) != 0
    d_wins := 0
    d_losses := 0
    d_rr := 0.0

// Weekly tracking
var int w_wins = 0
var int w_losses = 0
var float w_rr = 0.0

if ta.change(time("W")) != 0
    w_wins := 0
    w_losses := 0
    w_rr := 0.0

var string setup_status = "Awaiting Setup..."
bool any_active = false

// Evaluate ongoing trades
for i = array.size(setups) - 1 to 0
    if i < 0
        break
    TradeSetup ts = array.get(setups, i)
    if ts.is_active
        any_active := true
        
        if ts.dir == 1
            if high >= ts.tp_level
                total_wins += 1
                d_wins += 1
                w_wins += 1
                d_rr += ts.active_rr
                w_rr += ts.active_rr
                ts.is_active := false
                ts.end_bar := bar_index
                setup_status := "Target Reached (TP Hit) 🎯"
            else if low <= ts.sl_level
                total_losses += 1
                d_losses += 1
                w_losses += 1
                d_rr -= 1.0
                w_rr -= 1.0
                ts.is_active := false
                ts.end_bar := bar_index
                setup_status := "Trade Stopped Out (SL Hit) 🛑"
        else if ts.dir == -1
            if low <= ts.tp_level
                total_wins += 1
                d_wins += 1
                w_wins += 1
                d_rr += ts.active_rr
                w_rr += ts.active_rr
                ts.is_active := false
                ts.end_bar := bar_index
                setup_status := "Target Reached (TP Hit) 🎯"
            else if high >= ts.sl_level
                total_losses += 1
                d_losses += 1
                w_losses += 1
                d_rr -= 1.0
                w_rr -= 1.0
                ts.is_active := false
                ts.end_bar := bar_index
                setup_status := "Trade Stopped Out (SL Hit) 🛑"

if any_active
    setup_status := "Active Trades in Progress 🔄"

// Update active visual lines
if show_targets
    for i = 0 to array.size(setups) - 1
        if i >= array.size(setups)
            break
        TradeSetup ts = array.get(setups, i)
        bool is_last = (i == array.size(setups) - 1)
        int draw_to = is_last ? bar_index + 3 : ts.end_bar
        
        if not na(ts.tp_box)
            box.set_right(ts.tp_box, draw_to)
        if not na(ts.sl_line)
            line.set_x2(ts.sl_line, draw_to)
        if not na(ts.entry_line)
            line.set_x2(ts.entry_line, draw_to)
        if not na(ts.entry_lbl)
            label.set_x(ts.entry_lbl, draw_to)
        if not na(ts.sl_lbl)
            label.set_x(ts.sl_lbl, draw_to)
        if not na(ts.tp_lbl)
            label.set_x(ts.tp_lbl, draw_to)

//==================== MACRO / HTF / SESSION STATE ====================
var line macro_top_line = na
var float macro_top_val = na
var bool top_broken = true

var line macro_btm_line = na
var float macro_btm_val = na
var bool btm_broken = true

var int trend_zone = 0

//==================== HOKKABAZLIK STATE ====================
var int grab_state = 0 
var line grab_slope_line = na
var line grab_flat_line = na
var int grab_start_x = na
var float grab_start_y = na
var float last_wick_val = na
var int last_wick_x = na

//==================== ZONES ASSIGNMENT ====================
if use_sess_liq
    if asia_ended or lon_ended or ny_ended
        float finalize_h = na
        float finalize_l = na
        string s_name = ""
        
        if asia_ended
            finalize_h := cur_asia_h
            finalize_l := cur_asia_l
            s_name := "Asia Liq"
            cur_asia_h := na
            cur_asia_l := na
        else if lon_ended
            finalize_h := cur_lon_h
            finalize_l := cur_lon_l
            s_name := "London Liq"
            cur_lon_h := na
            cur_lon_l := na
        else if ny_ended
            finalize_h := cur_ny_h
            finalize_l := cur_ny_l
            s_name := "NY Liq"
            cur_ny_h := na
            cur_ny_l := na
            
        macro_top_val := finalize_h
        macro_btm_val := finalize_l
        top_broken := false
        btm_broken := false
        grab_state := 0 
        
        if not na(macro_top_line)
            line.delete(macro_top_line)
        macro_top_line := line.new(bar_index, macro_top_val, bar_index + 1, macro_top_val, color=liq_color, style=line.style_dashed, width=2)
        f_add_top_label(bar_index, macro_top_val, s_name, liq_color)
        
        if not na(macro_btm_line)
            line.delete(macro_btm_line)
        macro_btm_line := line.new(bar_index, macro_btm_val, bar_index + 1, macro_btm_val, color=liq_color, style=line.style_dashed, width=2)
        f_add_btm_label(bar_index, macro_btm_val, s_name, liq_color)

else if use_htf
    if is_new_htf
        macro_top_val := h_htf
        macro_btm_val := l_htf
        top_broken := false
        btm_broken := false
        
        if not na(macro_top_line)
            line.delete(macro_top_line)
        macro_top_line := line.new(bar_index, macro_top_val, bar_index + 1, macro_top_val, color=liq_color, style=line.style_dashed, width=2)
        f_add_top_label(bar_index, macro_top_val, "HTF Liq", liq_color)
        
        if not na(macro_btm_line)
            line.delete(macro_btm_line)
        macro_btm_line := line.new(bar_index, macro_btm_val, bar_index + 1, macro_btm_val, color=liq_color, style=line.style_dashed, width=2)
        f_add_btm_label(bar_index, macro_btm_val, "HTF Liq", liq_color)
        
        grab_state := 0
else
    phVal = ta.pivothigh(high, p, p)
    plVal = ta.pivotlow(low,  p, p)

    if not na(phVal)
        macro_top_val := phVal
        top_broken := false
        if not na(macro_top_line)
            line.delete(macro_top_line)
        macro_top_line := line.new(bar_index[p], macro_top_val, bar_index, macro_top_val, color=liq_color, style=line.style_dashed, width=2)
        f_add_top_label(bar_index[p], macro_top_val, "Macro Liq", liq_color)

    if not na(plVal)
        macro_btm_val := plVal
        btm_broken := false
        if not na(macro_btm_line)
            line.delete(macro_btm_line)
        macro_btm_line := line.new(bar_index[p], macro_btm_val, bar_index, macro_btm_val, color=liq_color, style=line.style_dashed, width=2)
        f_add_btm_label(bar_index[p], macro_btm_val, "Macro Liq", liq_color)

if not top_broken and not na(macro_top_line)
    line.set_x2(macro_top_line, bar_index)

if not btm_broken and not na(macro_btm_line)
    line.set_x2(macro_btm_line, bar_index)

trend_zone := 0

//==================== KIRILIM (GRAB ZONE) ====================
bool bear_liq_grab = false
bool bull_liq_grab = false

if not top_broken and close > macro_top_val and top_wick_ok
    top_broken := true
    trend_zone := -1
    bear_liq_grab := true
    f_add_top_label(bar_index, high, "Liq Grab Zone", bear_color)
    
    if show_hokkabazlik
        grab_state := 1
        grab_start_x := bar_index
        grab_start_y := high
        last_wick_val := high
        last_wick_x := bar_index
        grab_slope_line := line.new(grab_start_x, grab_start_y, bar_index + 3, high, color=bear_color, style=line.style_dashed, width=2)

if not btm_broken and close < macro_btm_val and btm_wick_ok
    btm_broken := true
    trend_zone := 1
    bull_liq_grab := true
    f_add_btm_label(bar_index, low, "Liq Grab Zone", bull_color)
    
    if show_hokkabazlik
        grab_state := -1
        grab_start_x := bar_index
        grab_start_y := low
        last_wick_val := low
        last_wick_x := bar_index
        grab_slope_line := line.new(grab_start_x, grab_start_y, bar_index + 3, low, color=bull_color, style=line.style_dashed, width=2)

//==================== WICK TRACKING & PRL & TRADE SETUPS ====================
bool prl_bear_born = false
bool prl_bull_born = false

if show_hokkabazlik
    // -------- BEARISH REVERSAL (TOP GRAB) --------
    if grab_state == 1
        if high >= last_wick_val
            last_wick_val := high
            last_wick_x := bar_index
            line.set_xy2(grab_slope_line, last_wick_x, last_wick_val)
        else if barstate.isconfirmed
            grab_state := 2
            prl_bear_born := true
            grab_flat_line := line.new(last_wick_x, last_wick_val, bar_index + 3, last_wick_val, color=bear_color, style=line.style_solid, width=2)
            f_add_top_label(last_wick_x, last_wick_val, "PRL", bear_color)
            
            bool trend_ok = use_ma_filter ? (close < ma_val) : true
            bool setup_valid = not is_choppy and trend_ok and adx_bear_ok and rsi_bear_ok and mom_bear_ok and vol_ok and pa_bear_ok
            
            if setup_valid
                float rng = na(macro_btm_val) ? g_atr * 5 : (last_wick_val - macro_btm_val)
                float tp1_hi = last_wick_val - (rng * 0.618)
                float tp1_lo = last_wick_val - (rng * 0.764)
                float sl_val = last_wick_val + (rng * sl_multiplier)
                float tp_mid = math.avg(tp1_hi, tp1_lo)
                
                total_trades += 1
                float my_rr = ((last_wick_val - tp1_hi) / (sl_val - last_wick_val))
                setup_status := "New Setup Found! Entering Short."
                
                box b = na
                line sl_ln = na
                line en_ln = na
                label en_lb = na
                label sl_lb = na
                label tp_lb = na
                
                if show_targets
                    b := box.new(last_wick_x, tp1_hi, bar_index + 3, tp1_lo, border_color=color.new(bear_color, 40), border_width=1, border_style=line.style_dashed, bgcolor=color.new(bear_color, 85))
                    sl_ln := line.new(last_wick_x, sl_val, bar_index + 3, sl_val, color=bear_color, style=line.style_dotted, width=2)
                    en_ln := line.new(last_wick_x, last_wick_val, bar_index + 3, last_wick_val, color=bear_color, style=line.style_solid, width=2)
                    
                    en_lb := label.new(bar_index + 3, last_wick_val, "Entry Level", color=color(na), textcolor=bear_color, style=label.style_label_left, size=size.small)
                    sl_lb := label.new(bar_index + 3, sl_val, "SL (-" + str.tostring(sl_multiplier) + ")", color=color(na), textcolor=bear_color, style=label.style_label_left, size=size.small)
                    tp_lb := label.new(bar_index + 3, tp_mid, "TP Zone", color=color(na), textcolor=bear_color, style=label.style_label_left, size=size.small)
                
                if array.size(setups) > 0
                    TradeSetup prev = array.get(setups, array.size(setups) - 1)
                    if prev.is_active
                        prev.is_active := false
                        prev.end_bar := bar_index
                        total_trades -= 1
                        setup_status := "Trade Cancelled (New Setup Born) ⚠️"
                
                TradeSetup ts = TradeSetup.new(-1, tp1_hi, sl_val, last_wick_val, my_rr, b, sl_ln, en_ln, en_lb, sl_lb, tp_lb, true, bar_index + 3)
                array.push(setups, ts)
                
                if array.size(setups) > show_last_n
                    TradeSetup old = array.shift(setups)
                    if not na(old.tp_box)
                        box.delete(old.tp_box)
                        line.delete(old.sl_line)
                        line.delete(old.entry_line)
                        label.delete(old.entry_lbl)
                        label.delete(old.sl_lbl)
                        label.delete(old.tp_lbl)

    // -------- BULLISH REVERSAL (BOTTOM GRAB) --------
    if grab_state == -1
        if low <= last_wick_val
            last_wick_val := low
            last_wick_x := bar_index
            line.set_xy2(grab_slope_line, last_wick_x, last_wick_val)
        else if barstate.isconfirmed
            grab_state := -2
            prl_bull_born := true
            grab_flat_line := line.new(last_wick_x, last_wick_val, bar_index + 3, last_wick_val, color=bull_color, style=line.style_solid, width=2)
            f_add_btm_label(last_wick_x, last_wick_val, "PRL", bull_color)
            
            bool trend_ok = use_ma_filter ? (close > ma_val) : true
            bool setup_valid = not is_choppy and trend_ok and adx_bull_ok and rsi_bull_ok and mom_bull_ok and vol_ok and pa_bull_ok
            
            if setup_valid
                float rng = na(macro_top_val) ? g_atr * 5 : (macro_top_val - last_wick_val)
                float tp1_hi = last_wick_val + (rng * 0.764)
                float tp1_lo = last_wick_val + (rng * 0.618)
                float sl_val = last_wick_val - (rng * sl_multiplier)
                float tp_mid = math.avg(tp1_hi, tp1_lo)
                
                total_trades += 1
                float my_rr = ((tp1_lo - last_wick_val) / (last_wick_val - sl_val))
                setup_status := "New Setup Found! Entering Long."
                
                box b = na
                line sl_ln = na
                line en_ln = na
                label en_lb = na
                label sl_lb = na
                label tp_lb = na
                
                if show_targets
                    b := box.new(last_wick_x, tp1_hi, bar_index + 3, tp1_lo, border_color=color.new(bull_color, 40), border_width=1, border_style=line.style_dashed, bgcolor=color.new(bull_color, 85))
                    sl_ln := line.new(last_wick_x, sl_val, bar_index + 3, sl_val, color=bull_color, style=line.style_dotted, width=2)
                    en_ln := line.new(last_wick_x, last_wick_val, bar_index + 3, last_wick_val, color=bull_color, style=line.style_solid, width=2)
                    
                    en_lb := label.new(bar_index + 3, last_wick_val, "Entry Level", color=color(na), textcolor=bull_color, style=label.style_label_left, size=size.small)
                    sl_lb := label.new(bar_index + 3, sl_val, "SL (-" + str.tostring(sl_multiplier) + ")", color=color(na), textcolor=bull_color, style=label.style_label_left, size=size.small)
                    tp_lb := label.new(bar_index + 3, tp_mid, "TP Zone", color=color(na), textcolor=bull_color, style=label.style_label_left, size=size.small)
                
                if array.size(setups) > 0
                    TradeSetup prev = array.get(setups, array.size(setups) - 1)
                    if prev.is_active
                        prev.is_active := false
                        prev.end_bar := bar_index
                        total_trades -= 1
                        setup_status := "Trade Cancelled (New Setup Born) ⚠️"
                
                TradeSetup ts = TradeSetup.new(1, tp1_lo, sl_val, last_wick_val, my_rr, b, sl_ln, en_ln, en_lb, sl_lb, tp_lb, true, bar_index + 3)
                array.push(setups, ts)
                
                if array.size(setups) > show_last_n
                    TradeSetup old = array.shift(setups)
                    if not na(old.tp_box)
                        box.delete(old.tp_box)
                        line.delete(old.sl_line)
                        line.delete(old.entry_line)
                        label.delete(old.entry_lbl)
                        label.delete(old.sl_lbl)
                        label.delete(old.tp_lbl)

bgcolor(trend_zone == -1 ? color.new(bear_color, 90) : trend_zone == 1 ? color.new(bull_color, 90) : na)

//==================== WINRATE PANEL ====================
if show_panel
    var table win_tb = table.new(position.top_right, 2, 10, bgcolor=color.new(#1e222d, 15), border_width=1, border_color=color.new(color.gray, 80))
    if barstate.islast
        // Header
        string title_txt = use_sess_liq ? "🏆 SMC SESSION PRL SYSTEM" : (use_htf ? "🏆 HTF PRL PRO SYSTEM" : "🏆 MACRO PRL PRO SYSTEM")
        table.cell(win_tb, 0, 0, title_txt, text_color=color.white, text_size=size.normal, bgcolor=color.new(#2962ff, 30), text_halign=text.align_center)
        table.merge_cells(win_tb, 0, 0, 1, 0)
        
        // Setup Status
        color stat_col = setup_status == "Awaiting Setup..." ? color.gray : (any_active ? color.orange : color.white)
        if setup_status == "Trade Cancelled (New Setup Born) ⚠️"
            stat_col := color.yellow
            
        table.cell(win_tb, 0, 1, "Status:", text_color=color.silver, text_size=size.normal, text_halign=text.align_left)
        table.cell(win_tb, 1, 1, setup_status, text_color=stat_col, text_size=size.normal, text_halign=text.align_right)

        // Daily
        int d_closed_trades = d_wins + d_losses
        table.cell(win_tb, 0, 2, "📅 Today's Closed Trades", text_color=color.silver, text_size=size.normal, text_halign=text.align_left)
        table.cell(win_tb, 1, 2, str.tostring(d_closed_trades) + " (W: " + str.tostring(d_wins) + " | L: " + str.tostring(d_losses) + ")", text_color=color.white, text_size=size.normal, text_halign=text.align_right)
        
        table.cell(win_tb, 0, 3, "🎯 Today's RR Flow", text_color=color.silver, text_size=size.normal, text_halign=text.align_left)
        table.cell(win_tb, 1, 3, (d_rr > 0 ? "+" : "") + str.tostring(d_rr, "#.##") + " R", text_color=(d_rr >= 0 ? bull_color : bear_color), text_size=size.normal, text_halign=text.align_right)

        // Weekly
        int w_closed_trades = w_wins + w_losses
        table.cell(win_tb, 0, 4, "📆 This Week's Trades", text_color=color.silver, text_size=size.normal, text_halign=text.align_left)
        table.cell(win_tb, 1, 4, str.tostring(w_closed_trades) + " (W: " + str.tostring(w_wins) + " | L: " + str.tostring(w_losses) + ")", text_color=color.white, text_size=size.normal, text_halign=text.align_right)
        
        table.cell(win_tb, 0, 5, "🎯 This Week's RR Flow", text_color=color.silver, text_size=size.normal, text_halign=text.align_left)
        table.cell(win_tb, 1, 5, (w_rr > 0 ? "+" : "") + str.tostring(w_rr, "#.##") + " R", text_color=(w_rr >= 0 ? bull_color : bear_color), text_size=size.normal, text_halign=text.align_right)

        // All Time
        table.cell(win_tb, 0, 6, "--- ALL TIME STATS ---", text_color=color.gray, text_size=size.small, text_halign=text.align_center)
        table.merge_cells(win_tb, 0, 6, 1, 6)

        table.cell(win_tb, 0, 7, "Total Executed", text_color=color.silver, text_size=size.normal, text_halign=text.align_left)
        table.cell(win_tb, 1, 7, str.tostring(total_trades), text_color=color.white, text_size=size.normal, text_halign=text.align_right)
        
        table.cell(win_tb, 0, 8, "TP Hit / SL Hit", text_color=color.silver, text_size=size.normal, text_halign=text.align_left)
        table.cell(win_tb, 1, 8, str.tostring(total_wins) + " / " + str.tostring(total_losses), text_color=color.white, text_size=size.normal, text_halign=text.align_right)
        
        float winrate = total_trades > 0 ? (total_wins / (total_wins + total_losses)) * 100 : 0
        color wr_color = winrate >= 50 ? color.new(#089981, 0) : color.new(#f23645, 0)
        table.cell(win_tb, 0, 9, "Total Win Rate", text_color=color.white, text_size=size.normal, text_halign=text.align_left, bgcolor=color.new(#1e222d, 0))
        table.cell(win_tb, 1, 9, str.tostring(winrate, "#.##") + "%", text_color=wr_color, text_size=size.normal, text_halign=text.align_right, bgcolor=color.new(#1e222d, 0))

//==================== ALERTS ====================
alertcondition(prl_bear_born, title="Bearish PRL Formed", message="A Bearish Possible Reversal Line (PRL) has been formed after a Top Liquidity Grab!")
alertcondition(prl_bull_born, title="Bullish PRL Formed", message="A Bullish Possible Reversal Line (PRL) has been formed after a Bottom Liquidity Grab!")

alertcondition(bear_liq_grab, title="Bearish Liq Grab Zone Formed", message="Bearish Liq Grab Zone oluştu!")
alertcondition(bull_liq_grab, title="Bullish Liq Grab Zone Formed", message="Bullish Liq Grab Zone oluştu!")

if prl_bear_born
    alert("Bearish PRL Formed on " + syminfo.ticker, alert.freq_once_per_bar_close)
if prl_bull_born
    alert("Bullish PRL Formed on " + syminfo.ticker, alert.freq_once_per_bar_close)

if bear_liq_grab
    alert("Bearish Liq Grab Zone oluştu on " + syminfo.ticker, alert.freq_once_per_bar_close)
if bull_liq_grab
    alert("Bullish Liq Grab Zone oluştu on " + syminfo.ticker, alert.freq_once_per_bar_close)
````

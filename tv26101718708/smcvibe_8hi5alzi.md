# smc_vibe

- url: https://www.tradingview.com/script/8hI5aLzI-smc-vibe/
- type: indicator
- pine_id: PUB;9e54ac2d8a664c8795ceae56bd898335
- version: 2.0

## Description

viewing htf patterns inside any time frame po3 candles and more

## Source Code

````pine
//@version=6
indicator("TOTORO LITE – Cascade & All Features", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_bars_back=2000)

// ====================== INPUTS ======================
grp_global = "=== Global Settings ==="
show_ma             = input.bool(true,  "Show Trend MA", group=grp_global)
ma_length           = input.int(1300,   "MA Length", group=grp_global)
ma_type             = input.string("SMA", "MA Type", options=["SMA", "EMA"], group=grp_global)

// Market Structure (Zig-Zag)
grp_struct = "=== Market Structure ==="
show_struct         = input.bool(true, "Show Swing Structure (ZigZag)", group=grp_struct)
struct_len          = input.int(8, "Swing Pivot Length", minval=1, group=grp_struct)
col_bull_str        = input.color(color.lime, "Bullish Swings", inline="str", group=grp_struct)
col_bear_str        = input.color(color.red, "Bearish Swings", inline="str", group=grp_struct)

// Dynamic Trendlines
grp_tl = "=== Dynamic Trendlines ==="
show_tl             = input.bool(true, "Show Active Trendlines", group=grp_tl)
col_tl              = input.color(color.new(#008080, 0), "Trendline Color", group=grp_tl)

// Session High/Low Tracking (Updated to Match User UI)
grp_sess = "=== Session High/Low Tracking ==="
show_sess_hl        = input.bool(true, "Show Session Highs/Lows", group=grp_sess)
ext_sess_lines      = input.bool(false, "Extend Closed Sessions to Chart", group=grp_sess)

ext_mon             = input.bool(false, "Monday High/Low", inline="mon", group=grp_sess)

ext_asia            = input.bool(false, "Asia Session", inline="asia", group=grp_sess)
sess_asia           = input.session("1800-0000", "", inline="asia", group=grp_sess)

ext_lon             = input.bool(false, "London Session", inline="lon", group=grp_sess)
sess_lon            = input.session("0200-0500", "", inline="lon", group=grp_sess)

ext_nyam            = input.bool(false, "NY AM Session", inline="nyam", group=grp_sess)
sess_nyam           = input.session("0830-1200", "", inline="nyam", group=grp_sess)

ext_nynoon          = input.bool(false, "NY Noon Session", inline="nynoon", group=grp_sess)
sess_nynoon         = input.session("1200-1330", "", inline="nynoon", group=grp_sess)

ext_nypm            = input.bool(false, "NY PM Session", inline="nypm", group=grp_sess)
sess_nypm           = input.session("1330-1600", "", inline="nypm", group=grp_sess)

sess_tz             = input.string("America/New_York", "Timezone", group=grp_sess)

// Liquidity lines
grp_liq  = "=== Liquidity Lines ==="
max_liq  = input.int(100, "Max Active Lines", minval=10, maxval=300, group=grp_liq)
show_5M  = input.bool(true,  "Show 5M",  inline="5m",  group=grp_liq)
col_5M   = input.color(color.gray, "",    inline="5m",  group=grp_liq)
show_15M = input.bool(true,  "Show 15M", inline="15m", group=grp_liq)
col_15M  = input.color(color.aqua, "",    inline="15m", group=grp_liq)
show_30M = input.bool(true,  "Show 30M", inline="30m", group=grp_liq)
col_30M  = input.color(color.blue, "",   inline="30m", group=grp_liq)
show_1H  = input.bool(true,  "Show 1H",  inline="1h",  group=grp_liq)
col_1H   = input.color(color.orange, "", inline="1h",  group=grp_liq)
show_2H  = input.bool(true,  "Show 2H",  inline="2h",  group=grp_liq)
col_2H   = input.color(color.orange, "", inline="2h",  group=grp_liq)
show_4H  = input.bool(true,  "Show 4H",  inline="4h",  group=grp_liq)
col_4H   = input.color(color.red, "",    inline="4h",  group=grp_liq)
show_1D  = input.bool(true,  "Show 1D",  inline="1d",  group=grp_liq)
col_1D   = input.color(color.maroon, "", inline="1d",  group=grp_liq)

// Cascade & sweeps
grp_sweep = "=== Cascade & Pending Sweeps ==="
cascade_enable      = input.bool(true, "Cascade to Next Swing", group=grp_sweep)
cascade_lookback    = input.int(80, "Lookback Cascade", minval=10, group=grp_sweep)
cascade_strength    = input.int(2, "Pivot Strength", minval=1, group=grp_sweep)
pending_enable      = input.bool(true, "Show Pending Sweeps", group=grp_sweep)
pending_pierce_pts  = input.float(50, "Min Pierce Points", minval=1, group=grp_sweep)

// Mitigated retention
grp_mit = "=== Mitigated Retention ==="
keep_mitigated      = input.bool(true, "Keep Swept Levels", group=grp_mit)
mitigated_minutes   = input.int(240, "Minutes to Keep", minval=1, group=grp_mit)

// Fibonacci
grp_fib = "=== Fibonacci Engine ==="
show_fib            = input.bool(true, "Show Adaptive Fib", group=grp_fib)
fib_style           = input.string("Retracement", "Fibonacci Style", options=["Retracement", "Inverse Projection"], group=grp_fib)
fib_tf_opt          = input.string("4H", "Timeframe", options=["1H", "4H"], group=grp_fib)
fib_lookback        = input.int(200, "Lookback Window", minval=10, group=grp_fib)
fib_color           = input.color(color.white, "Fib Color", group=grp_fib)
fib_ote_color       = input.color(#FF00FF, "OTE / Target Color", group=grp_fib) 

string fib_tf_val = fib_tf_opt == "1H" ? "60" : "240"

// FVG & Order Blocks
grp_fvg_ob = "=== FVG & Order Blocks ==="
show_current_zones  = input.bool(true, "Show Current TF Zones", group=grp_fvg_ob)
show_custom_zones   = input.bool(true, "Show Custom TF Zones", group=grp_fvg_ob)
custom_zone_tf      = input.timeframe("15", "Custom Zone TF", group=grp_fvg_ob)
show_floating_zones = input.bool(true, "Show Floating Right-Edge Zones (1H & 1D)", group=grp_fvg_ob)
max_zones           = input.int(5, "Max Zones per Type", minval=1, maxval=20, group=grp_fvg_ob)
col_fvg_bull        = input.color(color.new(color.lime, 80), "FVG Bull", inline="fvg", group=grp_fvg_ob)
col_fvg_bear        = input.color(color.new(color.orange, 80), "FVG Bear", inline="fvg", group=grp_fvg_ob)
col_ob_bull         = input.color(color.new(color.teal, 80), "OB Bull", inline="ob", group=grp_fvg_ob)
col_ob_bear         = input.color(color.new(color.maroon, 80), "OB Bear", inline="ob", group=grp_fvg_ob)

// Session filter
grp_session_filter = "=== Session Filter ==="
filter_sessions     = input.bool(true, "Filter Sessions", group=grp_session_filter)
gmt_offset          = input.int(2, "GMT Offset", minval=-12, maxval=14, group=grp_session_filter)
london_open         = input.int(8, "London Open", group=grp_session_filter)
ny_open             = input.int(13, "NY Open", group=grp_session_filter)
ny_close            = input.int(21, "NY Close", group=grp_session_filter)

// Dashboard
grp_dash = "=== Dashboard ==="
show_dashboard      = input.bool(true, "Show Dashboard", group=grp_dash)

// ====================== CONSTANTS & TYPES ======================
const int   RETENTION_MS = 60000    
int tf_ms = nz(timeframe.in_seconds(timeframe.period), 60) * 1000

type LiqLevel
    int     origin_time
    float   price
    bool    is_high
    string  tf_label
    color   col
    line    l_obj
    label   txt_obj
    bool    pending

type Mitigated
    line    ln
    label   lb
    int     delete_time

type Zone
    int     origin_time
    float   top
    float   bot
    bool    is_bull
    color   col
    box     b_obj
    label   txt_obj

// ====================== GLOBAL ARRAYS ======================
var active_liq        = array.new<LiqLevel>()
var mitigated         = array.new<Mitigated>()
var array<string> swept_history = array.new<string>() 

var active_fvgs       = array.new<Zone>()
var active_obs        = array.new<Zone>()
var mtf_fvgs          = array.new<Zone>()
var mtf_obs           = array.new<Zone>()

var float_1h_fvgs     = array.new<Zone>()
var float_1h_obs      = array.new<Zone>()
var float_1d_fvgs     = array.new<Zone>()
var float_1d_obs      = array.new<Zone>()

var array<line> fib_lines  = array.new<line>(12)
var array<label> fib_labels = array.new<label>(12)

var box[] htf_candle_boxes = array.new_box()
var line[] htf_candle_lines = array.new_line()
var label[] htf_candle_labels = array.new_label()

var table dash_table = table.new(position.top_right, 4, 4, bgcolor=color.new(#0C0C12,95), border_color=#2B2B2B, border_width=1)

// Trendline tracking
var float tl_ph1_val = na, var int tl_ph1_time = na
var float tl_ph2_val = na, var int tl_ph2_time = na
var float tl_pl1_val = na, var int tl_pl1_time = na
var float tl_pl2_val = na, var int tl_pl2_time = na

var line tl_res = na
var line tl_sup = na

// ====================== SESSION ENGINE (TYPE METHOD) ======================
type SessionTracker
    line l_h
    line l_l
    label lbl
    int start_idx
    int end_idx
    float h_val
    float l_val
    bool is_active

method update(SessionTracker this, bool show_feature, bool in_sess, bool ext_master, bool ext_sess, color col, string name) =>
    bool just_started = in_sess and not this.is_active
    this.is_active := in_sess

    if just_started
        this.start_idx := bar_index
        this.end_idx := bar_index
        this.h_val := high
        this.l_val := low
        
        // DESTROY old lines/labels to reset Pine Script's garbage collector memory
        if not na(this.l_h)
            line.delete(this.l_h)
            line.delete(this.l_l)
            label.delete(this.lbl)

        this.l_h := line.new(this.start_idx, this.h_val, this.end_idx, this.h_val, width=1, style=line.style_solid)
        this.l_l := line.new(this.start_idx, this.l_val, this.end_idx, this.l_val, width=1, style=line.style_solid)
        this.lbl := label.new(this.start_idx, this.l_val, name, textcolor=col, color=color.new(color.white, 100), style=label.style_label_up, size=size.small)
            
    else if in_sess
        this.end_idx := bar_index
        this.h_val := math.max(nz(this.h_val, high), high)
        this.l_val := math.min(nz(this.l_val, low), low)
        line.set_xy1(this.l_h, this.start_idx, this.h_val)
        line.set_xy2(this.l_h, this.end_idx, this.h_val)
        line.set_xy1(this.l_l, this.start_idx, this.l_val)
        line.set_xy2(this.l_l, this.end_idx, this.l_val)
        
        // Update label position - perfectly centered on the session block
        int mid_x = math.round((this.start_idx + this.end_idx) / 2)
        label.set_xy(this.lbl, mid_x, this.l_val)
        
    else if not na(this.end_idx)
        int draw_end = (ext_master and ext_sess) ? bar_index : this.end_idx
        string st = (ext_master and ext_sess) ? line.style_dashed : line.style_solid
        line.set_x2(this.l_h, draw_end)
        line.set_x2(this.l_l, draw_end)
        line.set_style(this.l_h, st)
        line.set_style(this.l_l, st)
        
        // Hard-locked label location! Never drifts right when the line extends.
        int mid_x = math.round((this.start_idx + this.end_idx) / 2)
        label.set_xy(this.lbl, mid_x, this.l_val)

    if not na(this.l_h)
        // Set brightness: transp 20 makes them solid but faintly transparent
        color line_col = show_feature ? color.new(col, 20) : na 
        color text_col = show_feature ? col : na
        line.set_color(this.l_h, line_col)
        line.set_color(this.l_l, line_col)
        label.set_textcolor(this.lbl, text_col)

// Initialize Session Trackers
var SessionTracker trk_mon    = SessionTracker.new(na, na, na, na, na, na, na, false)
var SessionTracker trk_asia   = SessionTracker.new(na, na, na, na, na, na, na, false)
var SessionTracker trk_lon    = SessionTracker.new(na, na, na, na, na, na, na, false)
var SessionTracker trk_nyam   = SessionTracker.new(na, na, na, na, na, na, na, false)
var SessionTracker trk_nynoon = SessionTracker.new(na, na, na, na, na, na, na, false)
var SessionTracker trk_nypm   = SessionTracker.new(na, na, na, na, na, na, na, false)


// ====================== HELPER FUNCTIONS ======================
f_format_tf(string tf) =>
    switch tf
        "5" => "5m"
        "15" => "15m"
        "30" => "30m"
        "60" => "1H"
        "120" => "2H"
        "240" => "4H"
        "D" => "1D"
        => tf

f_session_active() =>
    if not filter_sessions
        true
    else
        h = hour(time, "GMT+" + str.tostring(gmt_offset))
        h >= london_open and h < ny_close

f_calc_bias_raw() =>
    int score = 0
    rng = high[1] - low[1]
    body = math.abs(open[1] - close[1])
    upper_w = high[1] - math.max(open[1], close[1])
    lower_w = math.min(open[1], close[1]) - low[1]
    if lower_w > body*2 and lower_w > rng*0.55 and upper_w < rng*0.25
        score += 1
    if upper_w > body*2 and upper_w > rng*0.55 and lower_w < rng*0.25
        score -= 1
    if close[1] > open[1] and close[2] < open[2] and close[1] >= open[2] and open[1] <= close[2]
        score += 1
    if close[1] < open[1] and close[2] > open[2] and close[1] <= open[2] and open[1] >= close[2]
        score -= 1
    ema_curr = ta.ema(close, 20)
    ema_prev = ta.ema(close[1], 20)
    if ema_curr > ema_prev
        score += 1
    else if ema_curr < ema_prev
        score -= 1
    math.max(-2, math.min(2, score))

f_get_pivots() =>
    ph = ta.pivothigh(high, cascade_strength, cascade_strength)
    pl = ta.pivotlow(low, cascade_strength, cascade_strength)
    pht = not na(ph) ? time[cascade_strength] : na
    plt = not na(pl) ? time[cascade_strength] : na
    [ph, pht, pl, plt]

f_get_liq_offset(string tf) =>
    switch tf
        "5M" => 5
        "15M" => 12
        "30M" => 19
        "1H" => 26
        "2H" => 33
        "4H" => 40
        "1D" => 47
        => 5

f_get_swept_pct(string tf) =>
    switch tf
        "5M" => 0.40
        "15M" => 0.48
        "30M" => 0.56
        "1H" => 0.64
        "2H" => 0.72
        "4H" => 0.80
        "1D" => 0.88
        => 0.50

f_tf_rank(string tf) =>
    switch tf
        "5M" => 1
        "15M" => 2
        "30M" => 3
        "1H" => 4
        "2H" => 5
        "4H" => 6
        "1D" => 7
        => 0

f_tf_sec(string tf) =>
    switch tf
        "5M" => 300
        "15M" => 900
        "30M" => 1800
        "1H" => 3600
        "2H" => 7200
        "4H" => 14400
        "1D" => 86400
        => 0

f_get_zones() =>
    fvg_b = low > high[2] and close[1] > high[2]
    fvg_br = high < low[2] and close[1] < low[2]
    ob_b = close > open and close[1] < open[1] and close > open[1]
    ob_br = close < open and close[1] > open[1] and close < open[1]
    zt_f = fvg_b ? low : fvg_br ? low[2] : na
    zb_f = fvg_b ? high[2] : fvg_br ? high : na
    zt_o = ob_b or ob_br ? high[1] : na
    zb_o = ob_b or ob_br ? low[1] : na
    [fvg_b, fvg_br, zt_f, zb_f, ob_b, ob_br, zt_o, zb_o]

f_draw_actual_candle(start_x, w, o, h, l, c, txt) =>
    if not na(o)
        color col = c >= o ? color.lime : color.red
        color bg_col = c >= o ? color.new(color.lime, 40) : color.new(color.red, 40)
        int cx = start_x + math.round(w / 2)
        
        array.push(htf_candle_boxes, box.new(start_x, math.max(o, c), start_x + w, math.min(o, c), border_color=col, bgcolor=bg_col, xloc=xloc.bar_index))
        array.push(htf_candle_lines, line.new(cx, h, cx, math.max(o, c), color=col, xloc=xloc.bar_index))
        array.push(htf_candle_lines, line.new(cx, l, cx, math.min(o, c), color=col, xloc=xloc.bar_index))
        array.push(htf_candle_labels, label.new(cx, l, txt, color=color.new(color.white, 100), textcolor=color.silver, style=label.style_label_up, size=size.small, xloc=xloc.bar_index))


// ====================== GLOBAL DATA CALLS (SAFE SCOPE) ======================
bias_1h  = request.security(syminfo.tickerid, "60",  f_calc_bias_raw(), lookahead=barmerge.lookahead_off)
bias_2h  = request.security(syminfo.tickerid, "120", f_calc_bias_raw(), lookahead=barmerge.lookahead_off)
bias_4h  = request.security(syminfo.tickerid, "240", f_calc_bias_raw(), lookahead=barmerge.lookahead_off)
bias_d   = request.security(syminfo.tickerid, "D",   f_calc_bias_raw(), lookahead=barmerge.lookahead_off)

net_bias = nz(bias_1h) + nz(bias_2h) + (nz(bias_4h) * 2) + (nz(bias_d) * 3)

[ph5, pht5, pl5, plt5]       = request.security(syminfo.tickerid, "5",  [ta.pivothigh(high, cascade_strength, cascade_strength), time[cascade_strength], ta.pivotlow(low, cascade_strength, cascade_strength), time[cascade_strength]], lookahead=barmerge.lookahead_off)
[ph15, pht15, pl15, plt15]   = request.security(syminfo.tickerid, "15", [ta.pivothigh(high, cascade_strength, cascade_strength), time[cascade_strength], ta.pivotlow(low, cascade_strength, cascade_strength), time[cascade_strength]], lookahead=barmerge.lookahead_off)
[ph30, pht30, pl30, plt30]   = request.security(syminfo.tickerid, "30", [ta.pivothigh(high, cascade_strength, cascade_strength), time[cascade_strength], ta.pivotlow(low, cascade_strength, cascade_strength), time[cascade_strength]], lookahead=barmerge.lookahead_off)
[ph1, pht1, pl1, plt1]       = request.security(syminfo.tickerid, "60", [ta.pivothigh(high, cascade_strength, cascade_strength), time[cascade_strength], ta.pivotlow(low, cascade_strength, cascade_strength), time[cascade_strength]], lookahead=barmerge.lookahead_off)
[ph2, pht2, pl2, plt2]       = request.security(syminfo.tickerid, "120",[ta.pivothigh(high, cascade_strength, cascade_strength), time[cascade_strength], ta.pivotlow(low, cascade_strength, cascade_strength), time[cascade_strength]], lookahead=barmerge.lookahead_off)
[ph4, pht4, pl4, plt4]       = request.security(syminfo.tickerid, "240",[ta.pivothigh(high, cascade_strength, cascade_strength), time[cascade_strength], ta.pivotlow(low, cascade_strength, cascade_strength), time[cascade_strength]], lookahead=barmerge.lookahead_off)
[phD, phtD, plD, pltD]       = request.security(syminfo.tickerid, "D",  [ta.pivothigh(high, cascade_strength, cascade_strength), time[cascade_strength], ta.pivotlow(low, cascade_strength, cascade_strength), time[cascade_strength]], lookahead=barmerge.lookahead_off)

[c_fb, c_fbr, c_ztf, c_zbf, c_ob, c_obr, c_zto, c_zbo] = request.security(syminfo.tickerid, custom_zone_tf, f_get_zones(), lookahead=barmerge.lookahead_off)
c_time = request.security(syminfo.tickerid, custom_zone_tf, time, lookahead=barmerge.lookahead_off)
new_c = ta.change(c_time) != 0

[h1_fb, h1_fbr, h1_ztf, h1_zbf, h1_ob, h1_obr, h1_zto, h1_zbo] = request.security(syminfo.tickerid, "60", f_get_zones(), lookahead=barmerge.lookahead_off)
h1_time = request.security(syminfo.tickerid, "60", time, lookahead=barmerge.lookahead_off)
new_h1 = ta.change(h1_time) != 0

[d1_fb, d1_fbr, d1_ztf, d1_zbf, d1_ob, d1_obr, d1_zto, d1_zbo] = request.security(syminfo.tickerid, "D", f_get_zones(), lookahead=barmerge.lookahead_off)
d1_time = request.security(syminfo.tickerid, "D", time, lookahead=barmerge.lookahead_off)
new_d1 = ta.change(d1_time) != 0

// Live lookahead for Dashboard Candles
[o5m, h5m, l5m, c5m]   = request.security(syminfo.tickerid, "5",   [open, high, low, close], lookahead=barmerge.lookahead_on)
[o1h, h1h, l1h, c1h]   = request.security(syminfo.tickerid, "60",  [open, high, low, close], lookahead=barmerge.lookahead_on)
[o4h, h4h, l4h, c4h]   = request.security(syminfo.tickerid, "240", [open, high, low, close], lookahead=barmerge.lookahead_on)
[o1dc, h1dc, l1dc, c1dc] = request.security(syminfo.tickerid, "D",   [open, high, low, close], lookahead=barmerge.lookahead_on)
[o1w, h1w, l1w, c1w]   = request.security(syminfo.tickerid, "W",   [open, high, low, close], lookahead=barmerge.lookahead_on)

// HISTORICAL ANCHOR CANDLES (Yesterday)
[oyest, hyest, lyest, cyest] = request.security(syminfo.tickerid, "D", [open[1], high[1], low[1], close[1]], lookahead=barmerge.lookahead_off)

// Fibonacci Data safely pulled at global scope
[fib_hh, fib_ll, fib_hbars, fib_lbars] = request.security(syminfo.tickerid, fib_tf_val, [ta.highest(high, fib_lookback), ta.lowest(low, fib_lookback), ta.highestbars(high, fib_lookback), ta.lowestbars(low, fib_lookback)], lookahead=barmerge.lookahead_off)

global_atr = ta.atr(14)
var string tf_str = timeframe.isintraday ? str.tostring(timeframe.multiplier) + "m" : timeframe.isdaily ? "1D" : "HTF"
int chart_sec = int(tf_ms / 1000)

// ====================== EXECUTE SESSION UPDATES ======================
in_mon    = dayofweek(time, sess_tz) == dayofweek.monday
in_asia   = not na(time(timeframe.period, sess_asia, sess_tz))
in_lon    = not na(time(timeframe.period, sess_lon, sess_tz))
in_nyam   = not na(time(timeframe.period, sess_nyam, sess_tz))
in_nynoon = not na(time(timeframe.period, sess_nynoon, sess_tz))
in_nypm   = not na(time(timeframe.period, sess_nypm, sess_tz))

trk_mon.update(show_sess_hl, in_mon, ext_sess_lines, ext_mon, color.white, "MON")
trk_asia.update(show_sess_hl, in_asia, ext_sess_lines, ext_asia, #FF1493, "ASIA")
trk_lon.update(show_sess_hl, in_lon, ext_sess_lines, ext_lon, #00BFFF, "LONDON")
trk_nyam.update(show_sess_hl, in_nyam, ext_sess_lines, ext_nyam, color.orange, "NY AM")
trk_nynoon.update(show_sess_hl, in_nynoon, ext_sess_lines, ext_nynoon, color.yellow, "NY NOON")
trk_nypm.update(show_sess_hl, in_nypm, ext_sess_lines, ext_nypm, #A020F0, "NY PM")


// ====================== TREND MA ======================
ma_val = ma_type == "SMA" ? ta.sma(close, ma_length) : ta.ema(close, ma_length)
plot(show_ma ? ma_val : na, color=color.new(color.white, 30), linewidth=2, title="Trend MA")

// ====================== MARKET STRUCTURE & DYNAMIC TRENDLINES ======================
var int last_piv_t = na
var float last_piv_p = na
var int last_piv_dir = 0 
var float last_h = na
var float last_l = na

ph_s = ta.pivothigh(high, struct_len, struct_len)
pl_s = ta.pivotlow(low, struct_len, struct_len)

if show_struct
    if not na(ph_s)
        is_hh = na(last_h) or ph_s > last_h
        txt = is_hh ? "HH" : "LH"
        c = is_hh ? col_bull_str : col_bear_str
        last_h := ph_s
        
        label.new(time[struct_len], ph_s, txt, color=color.new(color.white, 100), textcolor=c, style=label.style_label_down, size=size.small, xloc=xloc.bar_time)
        
        if last_piv_dir == -1 and not na(last_piv_t)
            line.new(last_piv_t, last_piv_p, time[struct_len], ph_s, color=color.new(chart.fg_color, 70), width=1, xloc=xloc.bar_time)
            
        last_piv_t := time[struct_len]
        last_piv_p := ph_s
        last_piv_dir := 1

    if not na(pl_s)
        is_hl = na(last_l) or pl_s > last_l
        txt = is_hl ? "HL" : "LL"
        c = is_hl ? col_bull_str : col_bear_str
        last_l := pl_s
        
        label.new(time[struct_len], pl_s, txt, color=color.new(color.white, 100), textcolor=c, style=label.style_label_up, size=size.small, xloc=xloc.bar_time)
        
        if last_piv_dir == 1 and not na(last_piv_t)
            line.new(last_piv_t, last_piv_p, time[struct_len], pl_s, color=color.new(chart.fg_color, 70), width=1, xloc=xloc.bar_time)
            
        last_piv_t := time[struct_len]
        last_piv_p := pl_s
        last_piv_dir := -1

// Dynamic Trendline Logic
if show_tl
    if not na(ph_s)
        tl_ph1_val := tl_ph2_val
        tl_ph1_time := tl_ph2_time
        tl_ph2_val := ph_s
        tl_ph2_time := time[struct_len]

    if not na(pl_s)
        tl_pl1_val := tl_pl2_val
        tl_pl1_time := tl_pl2_time
        tl_pl2_val := pl_s
        tl_pl2_time := time[struct_len]

    if not na(tl_ph1_time) and not na(tl_ph2_time)
        if na(tl_res)
            tl_res := line.new(tl_ph1_time, tl_ph1_val, tl_ph2_time, tl_ph2_val, xloc=xloc.bar_time, color=col_tl, extend=extend.right)
        else
            line.set_xy1(tl_res, tl_ph1_time, tl_ph1_val)
            line.set_xy2(tl_res, tl_ph2_time, tl_ph2_val)
            line.set_color(tl_res, col_tl)

    if not na(tl_pl1_time) and not na(tl_pl2_time)
        if na(tl_sup)
            tl_sup := line.new(tl_pl1_time, tl_pl1_val, tl_pl2_time, tl_pl2_val, xloc=xloc.bar_time, color=col_tl, extend=extend.right)
        else
            line.set_xy1(tl_sup, tl_pl1_time, tl_pl1_val)
            line.set_xy2(tl_sup, tl_pl2_time, tl_pl2_val)
            line.set_color(tl_sup, col_tl)
else
    if not na(tl_res)
        line.delete(tl_res)
        tl_res := na
    if not na(tl_sup)
        line.delete(tl_sup)
        tl_sup := na

// ====================== LOGIC FUNCTIONS ======================

add_liquidity(int origin_time, float p, bool is_high, string tf, color c) =>
    bool skip_add = false
    if f_tf_sec(tf) < chart_sec
        skip_add := true

    int actual_time = origin_time
    bool wick_found = false
    if not skip_add
        for i = 0 to 1500
            if is_high and high[i] == p
                wick_found := true
                actual_time := time[i]
                break
            if not is_high and low[i] == p
                wick_found := true
                actual_time := time[i]
                break
        if not wick_found
            skip_add := true

    string sig = str.tostring(actual_time) + "_" + str.tostring(p)
    if not skip_add and array.includes(swept_history, sig)
        skip_add := true
        
    if not skip_add and array.size(active_liq) > 0
        int i = array.size(active_liq) - 1
        while i >= 0
            LiqLevel lvl = active_liq.get(i)
            if lvl.origin_time == actual_time and lvl.tf_label == tf
                skip_add := true
                break
            if lvl.price == p and lvl.is_high == is_high
                if f_tf_rank(tf) > f_tf_rank(lvl.tf_label)
                    line.delete(lvl.l_obj)
                    label.delete(lvl.txt_obj)
                    active_liq.remove(i)
                else
                    skip_add := true
            i := i - 1
                
    if not skip_add
        if array.size(active_liq) >= max_liq
            oldest = active_liq.pop()
            line.delete(oldest.l_obj)
            label.delete(oldest.txt_obj)
        
        int offset_ms = f_get_liq_offset(tf) * tf_ms
        int end_time = time + offset_ms
        
        new_line = line.new(actual_time, p, end_time, p, color=c, style=line.style_solid, xloc=xloc.bar_time)
        new_lbl  = label.new(end_time, p, text=tf, textcolor=c, color=color.new(color.white, 100), style=label.style_label_left, size=size.small, xloc=xloc.bar_time)
        active_liq.unshift(LiqLevel.new(actual_time, p, is_high, tf, c, new_line, new_lbl, false))

mitigate_liquidity() =>
    var int i = array.size(active_liq) - 1
    i := array.size(active_liq) - 1
    while i >= 0
        LiqLevel lvl = active_liq.get(i)
        swept = false
        if lvl.is_high and high > lvl.price
            swept := true
        else if not lvl.is_high and low < lvl.price
            swept := true

        if not swept and pending_enable
            pierce_pts = lvl.is_high ? (high - lvl.price) / syminfo.mintick : (lvl.price - low) / syminfo.mintick
            line.set_width(lvl.l_obj, pierce_pts >= pending_pierce_pts ? 2 : 1)

        if swept
            string sig = str.tostring(lvl.origin_time) + "_" + str.tostring(lvl.price)
            if array.size(swept_history) > 1000
                array.shift(swept_history)
            array.push(swept_history, sig)

            cascaded = false
            if cascade_enable
                float next_price = na
                for j = 1 to math.min(cascade_lookback, bar_index - 1)
                    float p = na
                    if lvl.is_high
                        p := switch lvl.tf_label
                            "5M" => ph5[j]
                            "15M" => ph15[j]
                            "30M" => ph30[j]
                            "1H" => ph1[j]
                            "2H" => ph2[j]
                            "4H" => ph4[j]
                            "1D" => phD[j]
                            => na
                    else
                        p := switch lvl.tf_label
                            "5M" => pl5[j]
                            "15M" => pl15[j]
                            "30M" => pl30[j]
                            "1H" => pl1[j]
                            "2H" => pl2[j]
                            "4H" => pl4[j]
                            "1D" => plD[j]
                            => na
                    
                    if not na(p) and ((lvl.is_high and p > lvl.price) or (not lvl.is_high and p < lvl.price))
                        next_price := p
                        break

                if not na(next_price)
                    line.set_y1(lvl.l_obj, next_price)
                    line.set_y2(lvl.l_obj, next_price)
                    label.set_y(lvl.txt_obj, next_price)
                    lvl.price := next_price
                    cascaded := true
                    
            if not cascaded
                if keep_mitigated
                    mit_color = color.new(lvl.col, 60)
                    int duration = time - lvl.origin_time
                    float spread_pct = f_get_swept_pct(lvl.tf_label)
                    int label_time = lvl.origin_time + math.round(duration * spread_pct)
                    
                    m_line = line.new(lvl.origin_time, lvl.price, time, lvl.price, color=mit_color, style=line.style_dotted, xloc=xloc.bar_time) 
                    m_lbl  = label.new(label_time, lvl.price, lvl.tf_label + " Swept", textcolor=mit_color, color=color.new(color.white, 100), style=label.style_none, size=size.small, xloc=xloc.bar_time)
                    mitigated.push(Mitigated.new(m_line, m_lbl, time + mitigated_minutes * RETENTION_MS))
                active_liq.remove(i)
                line.delete(lvl.l_obj)
                label.delete(lvl.txt_obj)
            else
                line.set_width(lvl.l_obj, 1)  
                int offset_ms = f_get_liq_offset(lvl.tf_label) * tf_ms
                int end_time = time + offset_ms
                line.set_x2(lvl.l_obj, end_time)
                label.set_x(lvl.txt_obj, end_time)
        else
            int offset_ms = f_get_liq_offset(lvl.tf_label) * tf_ms
            int end_time = time + offset_ms
            line.set_x2(lvl.l_obj, end_time)
            label.set_x(lvl.txt_obj, end_time)
        i := i - 1

    mit_i = array.size(mitigated) - 1
    while mit_i >= 0
        Mitigated m = mitigated.get(mit_i)
        if time >= m.delete_time
            line.delete(m.ln)
            label.delete(m.lb)
            mitigated.remove(mit_i)
        mit_i := mit_i - 1

// ZONE MERGE LOGIC APPLIED HERE
f_add_zone_time(int origin_t, float top, float bot, bool is_bull, color c, string txt, array<Zone> arr) =>
    bool merged = false
    float n_top = math.max(top, bot)
    float n_bot = math.min(top, bot)
    
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            Zone z = array.get(arr, i)
            if z.is_bull == is_bull
                if n_bot <= z.top and n_top >= z.bot
                    z.top := math.max(z.top, n_top)
                    z.bot := math.min(z.bot, n_bot)
                    box.set_top(z.b_obj, z.top)
                    box.set_bottom(z.b_obj, z.bot)
                    label.set_y(z.txt_obj, (z.top + z.bot) / 2)
                    merged := true
                    break
                    
    if not merged
        int count = 0
        if array.size(arr) > 0
            for i = 0 to array.size(arr) - 1
                if array.get(arr, i).is_bull == is_bull
                    count += 1
                    
        if count >= max_zones
            for i = array.size(arr) - 1 to 0
                if array.get(arr, i).is_bull == is_bull
                    oldest = array.remove(arr, i)
                    box.delete(oldest.b_obj)
                    label.delete(oldest.txt_obj)
                    break
        
        new_box = box.new(left=origin_t, top=n_top, right=time, bottom=n_bot, border_color=color.new(c,0), bgcolor=c, xloc=xloc.bar_time)
        int mid_t = origin_t + math.round((time - origin_t) / 2)
        new_lbl = label.new(x=mid_t, y=(n_top+n_bot)/2, text=txt, textcolor=color.white, color=color.new(color.white, 100), style=label.style_none, size=size.small, xloc=xloc.bar_time)
        arr.unshift(Zone.new(origin_t, n_top, n_bot, is_bull, c, new_box, new_lbl))

// FIXED MITIGATION LOGIC: Requires confirmed close
f_mitigate_zones(array<Zone> arr) =>
    i = array.size(arr) - 1
    while i >= 0
        Zone z = arr.get(i)
        swept = (z.is_bull and close < z.bot) or (not z.is_bull and close > z.top)
        
        if swept and barstate.isconfirmed
            arr.remove(i)
            box.delete(z.b_obj)
            label.delete(z.txt_obj)
        else
            box.set_right(z.b_obj, time)
            int mid_time = z.origin_time + math.round((time - z.origin_time) / 2)
            label.set_x(z.txt_obj, mid_time)
        i := i - 1

// FLOATING RIGHT-EDGE ZONES (LEFT-ALIGNED, NARROWER OBs)
f_add_floating(float top, float bot, bool is_bull, color c, string txt, array<Zone> arr, int left_bars, int right_bars, bool is_ob) =>
    bool merged = false
    float n_top = math.max(top, bot)
    float n_bot = math.min(top, bot)
    
    int actual_l_bars = left_bars
    int actual_r_bars = is_ob ? right_bars - 4 : right_bars
    
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            Zone z = array.get(arr, i)
            if z.is_bull == is_bull
                if n_bot <= z.top and n_top >= z.bot
                    z.top := math.max(z.top, n_top)
                    z.bot := math.min(z.bot, n_bot)
                    box.set_top(z.b_obj, z.top)
                    box.set_bottom(z.b_obj, z.bot)
                    label.set_y(z.txt_obj, (z.top + z.bot) / 2)
                    merged := true
                    break
                    
    if not merged
        int count = 0
        if array.size(arr) > 0
            for i = 0 to array.size(arr) - 1
                if array.get(arr, i).is_bull == is_bull
                    count += 1
                    
        if count >= max_zones
            for i = array.size(arr) - 1 to 0
                if array.get(arr, i).is_bull == is_bull
                    oldest = array.remove(arr, i)
                    box.delete(oldest.b_obj)
                    label.delete(oldest.txt_obj)
                    break
        
        l_time = time + (actual_l_bars * tf_ms)
        r_time = time + (actual_r_bars * tf_ms)
        
        int txt_time = is_ob ? l_time + math.round((r_time - l_time) * 0.2) : l_time + math.round((r_time - l_time) * 0.8)
        
        new_box = box.new(left=l_time, top=n_top, right=r_time, bottom=n_bot, border_color=color.new(c,0), bgcolor=c, xloc=xloc.bar_time)
        new_lbl = label.new(x=txt_time, y=(n_top+n_bot)/2, text=txt, textcolor=color.white, color=color.new(#0C0C12, 50), style=label.style_none, size=size.small, xloc=xloc.bar_time)
        arr.unshift(Zone.new(time, n_top, n_bot, is_bull, c, new_box, new_lbl))

// FIXED MITIGATION LOGIC: Requires confirmed close
f_mitigate_floating(array<Zone> arr, int left_bars, int right_bars, bool is_ob) =>
    int actual_l_bars = left_bars
    int actual_r_bars = is_ob ? right_bars - 4 : right_bars

    i = array.size(arr) - 1
    while i >= 0
        Zone z = arr.get(i)
        swept = (z.is_bull and close < z.bot) or (not z.is_bull and close > z.top)
        
        if swept and barstate.isconfirmed
            arr.remove(i)
            box.delete(z.b_obj)
            label.delete(z.txt_obj)
        else
            l_time = time + (actual_l_bars * tf_ms)
            r_time = time + (actual_r_bars * tf_ms)
            box.set_left(z.b_obj, l_time)
            box.set_right(z.b_obj, r_time)
            
            int txt_time = is_ob ? l_time + math.round((r_time - l_time) * 0.2) : l_time + math.round((r_time - l_time) * 0.8)
            label.set_x(z.txt_obj, txt_time)
        i := i - 1

f_clear_zones(array<Zone> arr) =>
    while array.size(arr) > 0
        z = array.pop(arr)
        box.delete(z.b_obj)
        label.delete(z.txt_obj)

// DUAL-MODE FIBONACCI ENGINE
f_draw_fib(float hh, float ll, float hbars, float lbars) =>
    if hh != ll and not na(hh) and not na(ll)
        bool is_bull_leg = math.abs(hbars) <= math.abs(lbars)
        
        float[] levels = fib_style == "Inverse Projection" ? array.from(0.0, 0.382, 0.5, 0.618, 1.0, -0.382, -0.618, -1.618) : array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.705, 0.79, 1.0, -0.272, -0.618, -1.0, -1.618)
        string[] names = fib_style == "Inverse Projection" ? array.from("0", "382", "500", "618", "1000", "-382", "-618", "-1618 ext") : array.from("0","236","382","500","618","705 OTE","790","1000","272 ext","618 ext", "1000 ext", "1618 ext")
        
        for k = 0 to 11
            line l = fib_lines.get(k)
            label lb = fib_labels.get(k)
            
            if k < array.size(levels)
                float lev = na
                
                if is_bull_leg
                    lev := hh - (hh - ll) * levels.get(k)
                else
                    lev := ll + (hh - ll) * levels.get(k)
                    
                color current_col = color.new(fib_color, 80) 
                
                if fib_style == "Inverse Projection"
                    if k == 3 or k == 6 
                        current_col := fib_ote_color
                    else if k == 7 
                        current_col := fib_color
                    else
                        current_col := color.new(fib_color, 40) 
                else
                    if k == 5 
                        current_col := fib_ote_color
                    else if k > 7
                        current_col := fib_color
                    else
                        current_col := color.new(fib_color, 40)
    
                if na(l)
                    l := line.new(bar_index, lev, bar_index + 5, lev, color=current_col, style=line.style_dashed)
                    fib_lines.set(k, l)
                else
                    line.set_xy1(l, bar_index, lev)
                    line.set_xy2(l, bar_index + 5, lev)
                    line.set_color(l, current_col)
                    
                if na(lb)
                    lb := label.new(bar_index + 5, lev, names.get(k), color=color.new(color.white, 100), textcolor=current_col, style=label.style_none, size=size.small)
                    fib_labels.set(k, lb)
                else
                    label.set_xy(lb, bar_index + 5, lev)
                    label.set_text(lb, names.get(k))
                    label.set_textcolor(lb, current_col)
            else
                if not na(l)
                    line.set_xy1(l, na, na)
                    line.set_xy2(l, na, na)
                if not na(lb)
                    label.set_xy(lb, na, na)


// ====================== MAIN EXECUTION ======================
active_session = f_session_active()

if active_session
    if show_5M
        if not na(ph5) and not na(pht5)
            add_liquidity(pht5, ph5, true, "5M", col_5M)
        if not na(pl5) and not na(plt5)
            add_liquidity(plt5, pl5, false, "5M", col_5M)
    if show_15M
        if not na(ph15) and not na(pht15)
            add_liquidity(pht15, ph15, true, "15M", col_15M)
        if not na(pl15) and not na(plt15)
            add_liquidity(plt15, pl15, false, "15M", col_15M)
    if show_30M
        if not na(ph30) and not na(pht30)
            add_liquidity(pht30, ph30, true, "30M", col_30M)
        if not na(pl30) and not na(plt30)
            add_liquidity(plt30, pl30, false, "30M", col_30M)
    if show_1H
        if not na(ph1) and not na(pht1)
            add_liquidity(pht1, ph1, true, "1H", col_1H)
        if not na(pl1) and not na(plt1)
            add_liquidity(plt1, pl1, false, "1H", col_1H)
    if show_2H
        if not na(ph2) and not na(pht2)
            add_liquidity(pht2, ph2, true, "2H", col_2H)
        if not na(pl2) and not na(plt2)
            add_liquidity(plt2, pl2, false, "2H", col_2H)
    if show_4H
        if not na(ph4) and not na(pht4)
            add_liquidity(pht4, ph4, true, "4H", col_4H)
        if not na(pl4) and not na(plt4)
            add_liquidity(plt4, pl4, false, "4H", col_4H)
    if show_1D
        if not na(phD) and not na(phtD)
            add_liquidity(phtD, phD, true, "1D", col_1D)
        if not na(plD) and not na(pltD)
            add_liquidity(pltD, plD, false, "1D", col_1D)

mitigate_liquidity()

// === CURRENT TF ZONES ===
if show_current_zones
    fvg_bull = low > high[2] and close[1] > high[2]
    fvg_bear = high < low[2] and close[1] < low[2]
    
    if fvg_bull 
        f_add_zone_time(time[2], low, high[2], true, col_fvg_bull, tf_str + " FVG+", active_fvgs)
    if fvg_bear 
        f_add_zone_time(time[2], low[2], high, false, col_fvg_bear, tf_str + " FVG-", active_fvgs)

    ob_bull = close > open and close[1] < open[1] and close > open[1]
    ob_bear = close < open and close[1] > open[1] and close < open[1]
    if ob_bull 
        f_add_zone_time(time[1], high[1], low[1], true, col_ob_bull, tf_str + " OB+", active_obs)
    if ob_bear 
        f_add_zone_time(time[1], high[1], low[1], false, col_ob_bear, tf_str + " OB-", active_obs)
        
    f_mitigate_zones(active_fvgs)
    f_mitigate_zones(active_obs)
else
    f_clear_zones(active_fvgs)
    f_clear_zones(active_obs)

// === CUSTOM TF ZONES ===
if show_custom_zones and custom_zone_tf != timeframe.period
    c_name = f_format_tf(custom_zone_tf)
    if new_c
        if c_fb 
            f_add_zone_time(time, c_ztf, c_zbf, true, col_fvg_bull, c_name + " FVG+", mtf_fvgs)
        if c_fbr 
            f_add_zone_time(time, c_ztf, c_zbf, false, col_fvg_bear, c_name + " FVG-", mtf_fvgs)
        if c_ob 
            f_add_zone_time(time, c_zto, c_zbo, true, col_ob_bull, c_name + " OB+", mtf_obs)
        if c_obr 
            f_add_zone_time(time, c_zto, c_zbo, false, col_ob_bear, c_name + " OB-", mtf_obs)
            
    f_mitigate_zones(mtf_fvgs)
    f_mitigate_zones(mtf_obs)
else
    f_clear_zones(mtf_fvgs)
    f_clear_zones(mtf_obs)

// === RIGHT-EDGE FLOATING ZONES (1H & 1D) ===
if show_floating_zones
    if new_h1
        if h1_fb 
            f_add_floating(h1_ztf, h1_zbf, true, col_fvg_bull, "1H FVG+", float_1h_fvgs, 8, 16, false)
        if h1_fbr 
            f_add_floating(h1_ztf, h1_zbf, false, col_fvg_bear, "1H FVG-", float_1h_fvgs, 8, 16, false)
        if h1_ob 
            f_add_floating(h1_zto, h1_zbo, true, col_ob_bull, "1H OB+", float_1h_obs, 8, 16, true)
        if h1_obr 
            f_add_floating(h1_zto, h1_zbo, false, col_ob_bear, "1H OB-", float_1h_obs, 8, 16, true)
            
    if new_d1
        if d1_fb 
            f_add_floating(d1_ztf, d1_zbf, true, col_fvg_bull, "1D FVG+", float_1d_fvgs, 18, 26, false)
        if d1_fbr 
            f_add_floating(d1_ztf, d1_zbf, false, col_fvg_bear, "1D FVG-", float_1d_fvgs, 18, 26, false)
        if d1_ob 
            f_add_floating(d1_zto, d1_zbo, true, col_ob_bull, "1D OB+", float_1d_obs, 18, 26, true)
        if d1_obr 
            f_add_floating(d1_zto, d1_zbo, false, col_ob_bear, "1D OB-", float_1d_obs, 18, 26, true)

    f_mitigate_floating(float_1h_fvgs, 8, 16, false)
    f_mitigate_floating(float_1h_obs, 8, 16, true)
    f_mitigate_floating(float_1d_fvgs, 18, 26, false)
    f_mitigate_floating(float_1d_obs, 18, 26, true)
else
    f_clear_zones(float_1h_fvgs)
    f_clear_zones(float_1h_obs)
    f_clear_zones(float_1d_fvgs)
    f_clear_zones(float_1d_obs)

// === WIPE ENGINE FOR FIB ===
if show_fib
    f_draw_fib(fib_hh, fib_ll, fib_hbars, fib_lbars)
else
    for k = 0 to 11
        l = fib_lines.get(k)
        lb = fib_labels.get(k)
        if not na(l)
            line.delete(l)
            fib_lines.set(k, na)
        if not na(lb)
            label.delete(lb)
            fib_labels.set(k, na)

// ====================== NATIVE HTF CANDLE PROJECTION ======================
if barstate.islast and show_dashboard
    while array.size(htf_candle_boxes) > 0
        box.delete(array.pop(htf_candle_boxes))
    while array.size(htf_candle_lines) > 0
        line.delete(array.pop(htf_candle_lines))
    while array.size(htf_candle_labels) > 0
        label.delete(array.pop(htf_candle_labels))

    int base_x = bar_index + 35 

    // Current (Live)
    f_draw_actual_candle(base_x, 3, o5m, h5m, l5m, c5m, "5M")
    f_draw_actual_candle(base_x + 6, 3, o1h, h1h, l1h, c1h, "1H")
    f_draw_actual_candle(base_x + 12, 3, o4h, h4h, l4h, c4h, "4H")
    f_draw_actual_candle(base_x + 18, 3, o1dc, h1dc, l1dc, c1dc, "1D")
    f_draw_actual_candle(base_x + 24, 3, o1w, h1w, l1w, c1w, "1W")
    
    // Historical (Static) YEST moved left to avoid overlap with 1W dashboard lines
    f_draw_actual_candle(base_x + 30, 3, oyest, hyest, lyest, cyest, "YEST")

// ====================== DASHBOARD (Text Info Only) ======================
if barstate.islast and show_dashboard
    table.clear(dash_table, 0, 0, 3, 3) 
    
    session_str = active_session ? "LONDON/NY" : "ASIA"
    table.cell(dash_table, 0, 0, "TOTORO LITE", text_color=#FFD700, text_halign=text.align_left) 
    table.cell(dash_table, 3, 0, session_str, text_color=active_session ? color.lime : color.red, text_halign=text.align_right)
    table.merge_cells(dash_table, 0, 0, 2, 0)
    
    bias_txt = net_bias > 5 ? "STRONG BULL" : net_bias > 0 ? "BULL" : net_bias < -5 ? "STRONG BEAR" : net_bias < 0 ? "BEAR" : "NEUTRAL"
    bias_col = net_bias > 0 ? color.lime : net_bias < 0 ? color.red : color.silver
    table.cell(dash_table, 0, 1, bias_txt + "  " + str.tostring(math.abs(net_bias)), text_color=bias_col, text_halign=text.align_left)
    table.merge_cells(dash_table, 0, 1, 3, 1)
    
    table.cell(dash_table, 0, 2, "ATR " + str.tostring(global_atr, format.mintick), text_color=color.silver, text_halign=text.align_left)
    table.merge_cells(dash_table, 0, 2, 3, 2)
    
    sl_l = close - global_atr
    sl_s = close + global_atr
    table.cell(dash_table, 0, 3, "SL L " + str.tostring(sl_l, format.mintick) + " / S " + str.tostring(sl_s, format.mintick), text_color=color.aqua, text_halign=text.align_left)
    table.merge_cells(dash_table, 0, 3, 3, 3)
````

# MTF Red Bar Ver:1.0

- url: https://www.tradingview.com/script/sopM91uU-MTF-Red-Bar-Ver-1-0/
- type: indicator
- pine_id: PUB;85b333f86e1947a3821fdc583233d7be
- version: 1.0

## Description

MTF Fibonacci Bands
 
The script tracks and marks four distinct dynamic horizontal zones (bands)
5m , 5m bearish, 1hour, Mid Hour.
For each tracked window, it plots a shaded structural channel between the 0.44 and 0.50 retracement steps of that specific range.
The 4 Active Intraday Bands:
The 5m Opening Band (09:15 – 09:20): 
The Red Bar Band: Formed around the very first 5-minute bearish candle 
The 1H Range Band (09:15 – 10:15)
The 12:45pm Mid-day Band (12:45 – 13:15)
Tracks the absolute high, low, and center point of the previous trading day's candle.

EMA 5 Line: Acts as an immediate short-term momentum tracker.
EMA 10/30 Fast Trend Cloud: A shaded ribbon that changes color dynamically based on moving average crossovers (Green for bullish expansion, Red for bearish pressure).
EMA 200 High/Low Channel

## Source Code

````pine
//@version=5
indicator("MTF Red Bar Ver:1.0", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// =============================================================================
// 0. SYMBOL VALIDATION & VISUAL WARNING
// =============================================================================
is_nifty     = str.contains(syminfo.ticker, "NIFTY")
is_banknifty = str.contains(syminfo.ticker, "BANKNIFTY")
is_sensex    = str.contains(syminfo.ticker, "SENSEX")

is_valid = is_nifty or is_banknifty or is_sensex

var table warning_table = table.new(position.middle_center, 1, 1)

if not is_valid
    table.cell(warning_table, 0, 0, "NOT A VALID INSTRUMENT.\nONLY FOR INDICES (NIFTY, BANKNIFTY, SENSEX)", 
         bgcolor    = color.new(color.red, 5), 
         text_color = color.white, 
         text_size  = size.huge, 
         width      = 100, 
         height     = 100)
else
    table.cell(warning_table, 0, 0, "", bgcolor=color.new(color.black, 100))


// =============================================================================
// 1. USER INPUTS: DISPLAY OPTIONS (Squeezed UI)
// =============================================================================
// Fib Bands
show_today         = input.bool(true, title="Today's Bands", group="Fib Bands - Display Options", inline="Line1")
show_today_levels  = input.bool(true, title="Band Levels", tooltip="Show price levels on Today's Bands (5m, Red Bar, 1H, 12:45pm).", group="Fib Bands - Display Options", inline="Line1")

show_shadow        = input.bool(true, title="Shadow Candle Bands", tooltip="Stores the 3:15pm - 3:30pm levels from the last 9 days, but only plots the 3 bands closest to the current live price.", group="Fib Bands - Display Options", inline="Line2")
show_shadow_labels = input.bool(false, title="Shadow Labels", tooltip="Check this to display the 'SC' text on Shadow bands without the price levels.", group="Fib Bands - Display Options", inline="Line2")

show_pd            = input.bool(true, title="PD Lines", tooltip="Check this to display Previous Day High, Low, and Mid lines. Labels are always enabled.", group="Fib Bands - Display Options", inline="Line3")
show_ext_fib       = input.bool(false, title="Fib Ext & Ret Lines", tooltip="Plots Extensions (1.618, 2.618, 3.618) and Retracements (0.382, 0.500, 0.618) matched exactly to the manual TradingView Fib tool.", group="Fib Bands - Display Options", inline="Line3")

// EMA Clouds 
show_ema_5    = input.bool(true, title="EMA 5", group="EMA Clouds - Display Options", inline="ema1")
show_ema_fast = input.bool(false, title="EMA 10/30 Cloud", group="EMA Clouds - Display Options", inline="ema1") 
show_ema_200  = input.bool(false, title="EMA 200 Cloud", group="EMA Clouds - Display Options", inline="ema1") 

// =============================================================================
// 2. USER INPUTS: COLORS (Squeezed UI)
// =============================================================================
c_5m_bg     = input.color(color.new(color.blue, 64),   title="5m", group="Fib Bands - Colors", inline="col1")
c_red_bg    = input.color(color.new(color.red, 46),    title="Red Bar", group="Fib Bands - Colors", inline="col1")
c_1h_bg     = input.color(color.new(color.orange, 64), title="1H", group="Fib Bands - Colors", inline="col1")

c_1245_bg   = input.color(color.new(color.purple, 64), title="12:45pm", group="Fib Bands - Colors", inline="col2")
c_shadow_bg = input.color(color.new(color.gray, 64),   title="Shadow", group="Fib Bands - Colors", inline="col2")
c_pd_bg     = input.color(color.purple,                title="Prev Day", group="Fib Bands - Colors", inline="col2") 

c_ext_fib   = input.color(color.new(color.black, 0),   title="Ext Fib Lines Color", group="Fib Bands - Colors", inline="col3")

// =============================================================================
// 3. ARRAYS FOR CLEANUP & SHADOW MEMORY (FIB BANDS)
// =============================================================================
var line[]  lines_array  = array.new_line()
var box[]   boxes_array  = array.new_box()
var label[] labels_array = array.new_label()

var float[] shadow_tops = array.new_float(0)
var float[] shadow_bots = array.new_float(0)

// =============================================================================
// 4. FUNCTIONS (FIB BANDS)
// =============================================================================
get_fib(h, l, c, o, level) =>
    range_val = h - l
    is_red = c < o
    is_red ? (h - range_val * level) : (l + range_val * level)

init_band(int start_t, int end_t, float top_val, float bot_val, string name, color bg_col, bool show_labels, bool show_prices) =>
    text_col = color.black 
    mid_val = math.avg(top_val, bot_val)
    
    b_box = box.new(start_t, top_val, end_t, bot_val, xloc=xloc.bar_time, border_color=na, bgcolor=bg_col)
    array.push(boxes_array, b_box)
    
    if show_labels
        if show_prices
            lbl_top = label.new(end_t, top_val, text=str.tostring(math.round(top_val, 2)), xloc=xloc.bar_time, color=color.new(text_col, 100), textcolor=text_col, style=label.style_label_left, size=size.small)
            lbl_bot = label.new(end_t, bot_val, text=str.tostring(math.round(bot_val, 2)), xloc=xloc.bar_time, color=color.new(text_col, 100), textcolor=text_col, style=label.style_label_left, size=size.small)
            array.push(labels_array, lbl_top)
            array.push(labels_array, lbl_bot)

        lbl_name_start = label.new(start_t, mid_val, text=name, xloc=xloc.bar_time, color=color.new(text_col, 100), textcolor=text_col, style=label.style_label_left,  size=size.small)
        lbl_name_end   = label.new(end_t,   mid_val, text=name, xloc=xloc.bar_time, color=color.new(text_col, 100), textcolor=text_col, style=label.style_label_right, size=size.small)
        
        array.push(labels_array, lbl_name_start)
        array.push(labels_array, lbl_name_end)

init_fib_line(int start_t, int end_t, float val, string name, color col) =>
    l = line.new(start_t, val, end_t, val, xloc=xloc.bar_time, color=col, width=1, style=line.style_dotted)
    lbl = label.new(start_t, val, text=name, xloc=xloc.bar_time, color=color.new(col, 100), textcolor=col, style=label.style_label_right, size=size.small)
    array.push(lines_array, l)
    array.push(labels_array, lbl)

init_pd_line(int start_t, int end_t, float val, string name, color col) =>
    l = line.new(start_t, val, end_t, val, xloc=xloc.bar_time, color=col, width=1, style=line.style_solid)
    array.push(lines_array, l)
    lbl = label.new(start_t, val, text=name, xloc=xloc.bar_time, color=color.new(col, 100), textcolor=col, style=label.style_label_right, size=size.small)
    array.push(labels_array, lbl)

// =============================================================================
// 5. VARIABLES & TIME TRACKING (FIB BANDS)
// =============================================================================
is_new_day = ta.change(time("D"))

y = year(time, "Asia/Kolkata")
m = month(time, "Asia/Kolkata")
d = dayofmonth(time, "Asia/Kolkata")

t_0915 = timestamp("Asia/Kolkata", y, m, d, 09, 15)
t_0920 = timestamp("Asia/Kolkata", y, m, d, 09, 20)
t_1015 = timestamp("Asia/Kolkata", y, m, d, 10, 15)
t_1245 = timestamp("Asia/Kolkata", y, m, d, 12, 45) 
t_1315 = timestamp("Asia/Kolkata", y, m, d, 13, 15) 
t_1515 = timestamp("Asia/Kolkata", y, m, d, 15, 15) 
t_1530 = timestamp("Asia/Kolkata", y, m, d, 15, 30) 

// Persistent History Variables
var float permanent_5m_top   = na, var float permanent_5m_bot   = na
var float permanent_red_top  = na, var float permanent_red_bot  = na
var float permanent_f5_h     = na, var float permanent_f5_l     = na
var float permanent_f5_c     = na, var float permanent_f5_o     = na
var int   permanent_red_time = na

var float h1_h = na, var float h1_l = na, var float h1_o = na, var float h1_c = na
var bool h1_tracking = false, var bool h1_done = false

var float m30_h = na, var float m30_l = na, var float m30_o = na, var float m30_c = na
var bool m30_tracking = false, var bool m30_done = false

var float s_h = na, var float s_l = na, var float s_o = na, var float s_c = na
var bool s_tracking = false

var float c_1h_top   = na, var float c_1h_bot   = na
var float c_1245_top = na, var float c_1245_bot = na

// Previous Day H/L/M Variables
var float curr_day_h = na, var float curr_day_l = na
var float prev_day_h = na, var float prev_day_l = na, var float prev_day_m = na

// =============================================================================
// 5b. TIMEFRAME-LOCK ENGINE (COMPUTED GLOBALLY ON HISTORICAL 5-MINUTE WINDOWS)
// =============================================================================
get_5m_structural_levels() =>
    var float dynamic_f5_h = na, var float dynamic_f5_l = na
    var float dynamic_f5_o = na, var float dynamic_f5_c = na
    var bool dynamic_f5_done = false
    var bool dynamic_red_done = false
    
    var float out_5m_top = na, var float out_5m_bot = na
    var float out_red_top = na, var float out_red_bot = na
    var float out_f5_h = na, var float out_f5_l = na, var float out_f5_c = na, var float out_f5_o = na
    var int out_red_time = na

    if ta.change(time("D"))
        dynamic_f5_h := na, dynamic_f5_l := na, dynamic_f5_o := na, dynamic_f5_c := na
        dynamic_f5_done := false
        dynamic_red_done := false
        out_5m_top := na, out_5m_bot := na
        out_red_top := na, out_red_bot := na
        out_f5_h := na, out_f5_l := na, out_f5_c := na, out_f5_o := na
        out_red_time := na

    if time >= t_0915 and time < t_0920
        if na(dynamic_f5_h)
            dynamic_f5_h := high, dynamic_f5_l := low, dynamic_f5_o := open, dynamic_f5_c := close
        else
            dynamic_f5_h := math.max(dynamic_f5_h, high)
            dynamic_f5_l := math.min(dynamic_f5_l, low)
            dynamic_f5_c := close

    if time >= t_0920 and not dynamic_f5_done
        dynamic_f5_done := true
        v1 = get_fib(dynamic_f5_h, dynamic_f5_l, dynamic_f5_c, dynamic_f5_o, 0.44)
        v2 = get_fib(dynamic_f5_h, dynamic_f5_l, dynamic_f5_c, dynamic_f5_o, 0.50)
        out_5m_top := math.max(v1, v2)
        out_5m_bot := math.min(v1, v2)
        out_f5_h := dynamic_f5_h
        out_f5_l := dynamic_f5_l
        out_f5_c := dynamic_f5_c
        out_f5_o := dynamic_f5_o

    if dynamic_f5_done and not dynamic_red_done
        if close < open
            dynamic_red_done := true
            v1 = get_fib(high, low, close, open, 0.44)
            v2 = get_fib(high, low, close, open, 0.50)
            out_red_top  := math.max(v1, v2)
            out_red_bot  := math.min(v1, v2)
            out_red_time := time_close

    [out_5m_top, out_5m_bot, out_red_top, out_red_bot, out_f5_h, out_f5_l, out_f5_c, out_f5_o, out_red_time]

[sec_5m_top, sec_5m_bot, sec_red_top, sec_red_bot, sec_f5_h, sec_f5_l, sec_f5_c, sec_f5_o, sec_red_time] = request.security(syminfo.tickerid, "5", get_5m_structural_levels(), barmerge.gaps_off, barmerge.lookahead_off)

// Save background states into un-shakable variables instantly on step calculations
if not na(sec_5m_top)
    permanent_5m_top := sec_5m_top
    permanent_5m_bot := sec_5m_bot
if not na(sec_red_top)
    permanent_red_top := sec_red_top
    permanent_red_bot := sec_red_bot
if not na(sec_f5_h)
    permanent_f5_h := sec_f5_h
    permanent_f5_l := sec_f5_l
    permanent_f5_c := sec_f5_c
    permanent_f5_o := sec_f5_o
if not na(sec_red_time)
    permanent_red_time := sec_red_time

// =============================================================================
// 6. CORE LOGIC (FIB BANDS)
// =============================================================================
if is_new_day
    prev_day_h := curr_day_h
    prev_day_l := curr_day_l
    if not na(prev_day_h) and not na(prev_day_l)
        prev_day_m := math.avg(prev_day_h, prev_day_l)

    curr_day_h := high
    curr_day_l := low

    if s_tracking
        val1 = get_fib(s_h, s_l, s_c, s_o, 0.44)
        val2 = get_fib(s_h, s_l, s_c, s_o, 0.50)
        array.push(shadow_tops, math.max(val1, val2))
        array.push(shadow_bots, math.min(val1, val2))
        if array.size(shadow_tops) > 9
            array.shift(shadow_tops)
            array.shift(shadow_bots)

    if array.size(lines_array) > 0
        for i = 0 to array.size(lines_array) - 1
            line.delete(array.get(lines_array, i))
        array.clear(lines_array)

    if array.size(boxes_array) > 0
        for i = 0 to array.size(boxes_array) - 1
            box.delete(array.get(boxes_array, i))
        array.clear(boxes_array)
        
    if array.size(labels_array) > 0
        for i = 0 to array.size(labels_array) - 1
            label.delete(array.get(labels_array, i))
        array.clear(labels_array)

    permanent_5m_top   := na, permanent_5m_bot   := na
    permanent_red_top  := na, permanent_red_bot  := na
    permanent_f5_h     := na, permanent_f5_l     := na
    permanent_f5_c     := na, permanent_f5_o     := na
    permanent_red_time := na

    h1_tracking := false, h1_done := false
    m30_tracking := false, m30_done := false
    s_tracking := false

    c_1h_top   := na, c_1h_bot   := na
    c_1245_top := na, c_1245_bot := na

    if show_pd and not na(prev_day_h)
        init_pd_line(t_0915, t_1530, prev_day_h, "PDH", c_pd_bg)
        init_pd_line(t_0915, t_1530, prev_day_m, "PDM", c_pd_bg)
        init_pd_line(t_0915, t_1530, prev_day_l, "PDL", c_pd_bg)

    if show_shadow and array.size(shadow_tops) > 0
        int limit = math.min(3, array.size(shadow_tops))
        float[] dists = array.new_float(0)
        
        for i = 0 to array.size(shadow_tops) - 1
            float mid = math.avg(array.get(shadow_tops, i), array.get(shadow_bots, i))
            array.push(dists, math.abs(mid - close))
            
        for k = 1 to limit
            float min_dist = 1e10 
            int min_idx = -1
            
            for i = 0 to array.size(dists) - 1
                float d = array.get(dists, i)
                if not na(d) and d < min_dist
                    min_dist := d
                    min_idx := i
            
            if min_idx != -1
                init_band(t_0915, t_1530, array.get(shadow_tops, min_idx), array.get(shadow_bots, min_idx), "SC", c_shadow_bg, show_shadow_labels, false)
                array.set(dists, min_idx, na)
else
    curr_day_h := math.max(nz(curr_day_h, high), high)
    curr_day_l := math.min(nz(curr_day_l, low), low)

// UNIFIED STRUCTURAL PAINT ENGINE: Executes on chart updates using permanent lookups
if barstate.islast
    if show_today and not na(permanent_5m_top)
        init_band(t_0920, t_1530, permanent_5m_top, permanent_5m_bot, "5m", c_5m_bg, true, show_today_levels)
        
        if show_ext_fib and not na(permanent_f5_h)
            float r = permanent_f5_h - permanent_f5_l
            float[] ext_up = array.from(1.618, 2.618, 3.618)
            for i = 0 to array.size(ext_up) - 1
                init_fib_line(t_0920, t_1530, permanent_f5_l + (r * array.get(ext_up, i)), str.tostring(array.get(ext_up, i)), c_ext_fib)
            float[] ext_dn = array.from(1.618, 2.618, 3.618)
            for i = 0 to array.size(ext_dn) - 1
                init_fib_line(t_0920, t_1530, permanent_f5_h - (r * array.get(ext_dn, i)), "-" + str.tostring(array.get(ext_dn, i)), c_ext_fib)
            bool is_bullish = permanent_f5_c >= permanent_f5_o
            float[] ret_lvls = array.from(0.382, 0.500, 0.618)
            for i = 0 to array.size(ret_lvls) - 1
                float val = is_bullish ? (permanent_f5_h - (r * array.get(ret_lvls, i))) : (permanent_f5_l + (r * array.get(ret_lvls, i)))
                init_fib_line(t_0920, t_1530, val, str.tostring(array.get(ret_lvls, i)), c_ext_fib)

    if show_today and not na(permanent_red_top)
        // Draw the Red Bar from its true 5m execution close point to day end
        init_band(permanent_red_time, t_1530, permanent_red_top, permanent_red_bot, "Red Bar", c_red_bg, true, show_today_levels)

// Process standard high timeframe lookups natively
if time >= t_0915 and time < t_1015
    if not h1_tracking and not h1_done
        h1_h := high, h1_l := low, h1_o := open, h1_c := close
        h1_tracking := true

if h1_tracking and not h1_done
    if time < t_1015
        h1_h := math.max(h1_h, high)
        h1_l := math.min(h1_l, low)
        h1_c := close
    if time >= t_1015
        h1_done := true
        h1_tracking := false
        val1 = get_fib(h1_h, h1_l, h1_c, h1_o, 0.44)
        val2 = get_fib(h1_h, h1_l, h1_c, h1_o, 0.50)
        c_1h_top := math.max(val1, val2)
        c_1h_bot := math.min(val1, val2)
        if show_today
            init_band(t_1015, t_1530, c_1h_top, c_1h_bot, "1H", c_1h_bg, true, show_today_levels)

if time >= t_1245 and time < t_1315
    if not m30_tracking and not m30_done
        m30_h := high, m30_l := low, m30_o := open, m30_c := close
        m30_tracking := true

if m30_tracking and not m30_done
    if time < t_1315
        m30_h := math.max(m30_h, high)
        m30_l := math.min(m30_l, low)
        m30_c := close
    if time >= t_1315
        m30_done := true
        m30_tracking := false
        val1 = get_fib(m30_h, m30_l, m30_c, m30_o, 0.44)
        val2 = get_fib(m30_h, m30_l, m30_c, m30_o, 0.50) 
        c_1245_top := math.max(val1, val2)
        c_1245_bot := math.min(val1, val2)
        if show_today
            init_band(t_1315, t_1530, c_1245_top, c_1245_bot, "12:45pm", c_1245_bg, true, show_today_levels)

if time >= t_1515 and time < t_1530
    if not s_tracking
        s_h := high, s_l := low, s_o := open, s_c := close
        s_tracking := true

if s_tracking and time < t_1530
    s_h := math.max(s_h, high)
    s_l := math.min(s_l, low)
    s_c := close

// =============================================================================
// 7. EMA TREND CLOUDS
// =============================================================================
ema5     = ta.ema(close, 5)
ema10    = ta.ema(close, 10)
ema30    = ta.ema(close, 30)

plot(show_ema_5 ? ema5 : na, title="EMA 5", color=color.new(color.black, 50), linewidth=1)

p_ema10 = plot(show_ema_fast ? ema10 : na, title="EMA 10", display=display.none, editable=false)
p_ema30 = plot(show_ema_fast ? ema30 : na, title="EMA 30", display=display.none, editable=false)
fill(p_ema10, p_ema30, color=show_ema_fast ? (ema10 > ema30 ? color.new(color.green, 85) : color.new(color.red, 85)) : na, title="EMA 10/30 Trend Cloud")

ema200_h = ta.ema(high, 200)
ema200_l = ta.ema(low, 200)
ema200_c = ta.ema(close, 200) 

cloud_color = close > ema200_c ? color.new(color.green, 80) : color.new(color.red, 80)
border_col  = close > ema200_c ? color.new(color.green, 40) : color.new(color.red, 40)

p_ema200_h = plot(show_ema_200 ? ema200_h : na, title="EMA 200 High", color=border_col, linewidth=1)
p_ema200_l = plot(show_ema_200 ? ema200_l : na, title="EMA 200 Low", color=border_col, linewidth=1)

fill(p_ema200_h, p_ema200_l, color=show_ema_200 ? cloud_color : na, title="EMA 200 Cloud")  

// =============================================================================
// 8. LIVE MARKET INDICES TABLE (Top Right - Shifted Left)
// =============================================================================
get_index_points(sym) =>
    curr_price = request.security(sym, timeframe.period, close)
    prev_close = request.security(sym, "D", close[1])
    point_diff = curr_price - prev_close
    [curr_price, point_diff]

[n_val, n_diff]   = get_index_points("NSE:NIFTY")
[bn_val, bn_diff] = get_index_points("NSE:BANKNIFTY")
[sx_val, sx_pc]   = get_index_points("BSE:SENSEX")

var table market_table = table.new(position.top_right, 4, 1, border_width = 0)

if barstate.islast
    txt_nifty  = "NIFTY: " + str.tostring(n_val, "#.#") + " (" + (n_diff >= 0 ? "+" : "") + str.tostring(n_diff, "#.#") + ")"
    txt_bnifty = "BANKNIFTY: " + str.tostring(bn_val, "#.#") + " (" + (bn_diff >= 0 ? "+" : "") + str.tostring(bn_diff, "#.#") + ")"
    txt_sensex = "SENSEX: " + str.tostring(sx_val, "#.#") + " (" + (sx_pc >= 0 ? "+" : "") + str.tostring(sx_pc, "#.#") + ")"

    table.cell(market_table, 0, 0, txt_nifty,  text_color = color.new(color.gray, 20), text_size = size.large, text_halign = text.align_right)
    table.cell(market_table, 1, 0, txt_bnifty, text_color = color.new(color.gray, 20), text_size = size.large, text_halign = text.align_right)
    table.cell(market_table, 2, 0, txt_sensex, text_color = color.new(color.gray, 20), text_size = size.large, text_halign = text.align_right)
    
    table.cell(market_table, 3, 0, "          ", text_size = size.large)
````

# FBD Reclaim Tool v52

- url: https://www.tradingview.com/script/iLSIUtze-FBD-Reclaim-Tool-v52/
- type: indicator
- pine_id: PUB;a16b370f02514dad9287ad4ee014c890
- version: 1.0

## Description

FBD Reclaim Tool v52 - Advanced Time-Based Level Trading Engine for Failed Breakdown
Overview
The FBD Reclaim Tool v52 is a specialized, dual-core state machine designed for structural level trading. Built for traders who are tired of getting chopped up by "fakeouts" and liquidity sweeps, this tool abandons simple price-cross alerts. Instead, it relies on Time-Based Reclaim Logic—requiring the market to prove acceptance of a level over a physical duration of time before triggering an entry.

Whether you trade Futures, Indices, or Commodities, this script evaluates market structure in real-time, calculates dynamic structural targets, and routes beautifully formatted webhook payloads to Discord or your automated broker bridge.

Core Trading Concept: The "Flush, Base, Direction" (FBD)
Most indicators buy the exact touch of a support level, often catching a falling knife. This engine waits for the trap to be sprung:

The Sweep/Flush: Price must drop below a defined Major Support by a specified depth (Flush Depth). The system then "arms" the setup.

The Reclaim: Price must climb back above the level.

Time Acceptance & Dip Buffer: Price must hold above the level for a user-defined duration (e.g., 150 seconds). To account for market noise, the engine includes a Dip Reset Buffer: if price dips back under the level, the timer doesn't reset instantly unless it stays submerged beyond your defined grace period.

Execution: Once time acceptance is confirmed, the trade triggers.

Key Features

⏱️ True Time-Based Execution: Uses lower-timeframe (1S) data arrays to track exact physical seconds spent above/below a level. Includes a dynamic on-chart tracker (⏳) showing live countdowns and reclaim velocity.

📝 Natural Language Level Parser: Paste your daily levels straight from your notes! The "Mancini NL Format" automatically parses strings like 7205 (major), 7213—extracting numbers and assigning them as Major Support/Resistance or Minor zones based on your text tags. Standard CSV input is also supported.

🎯 Structural TP & SL Routing: Forget fixed point targets. The engine dynamically scans the array of levels you inputted and sets your Take Profit or Stop Loss at the next logical major structural level. (Fallback fixed points are used if no level is nearby).

🎛️ Chart Declutter Mode (New in v52): An added toggle to hide TP, SL, and Target Hit/Stopped Out labels. Keep your charts pristine, viewing only the entry triggers and level lines, while the script silently runs the management logic in the background.

📊 Tactical Dual-HUD: * Session HUD (Top Right): Calculates a dynamic "Session Rating" (A+, B, F) based on time-of-day edges and Sunday gap logic, tracks Daily TR vs. ATR, and counts "M1 Red Days" to gauge trend exhaustion.

Trade HUD (Bottom Right): Real-time table displaying your current Entry, SL, TP, Risk (pts), R/R Ratio, and the Reclaim Velocity.

🌊 Higher Timeframe Trend Filter: Uses an HTF Moving Average to filter trades. Counter-trend setups aren't entirely blocked but are visibly tagged as ⚠️ LQ (Low Quality) so you can manage your risk accordingly.

🤖 Built-in Discord / Webhook Alerts: Formats clean, data-rich JSON payloads detailing the Trade ID, execution time, R/R, Entry, and exact risk metrics, ready to be sent to your Discord channel.

How to Use:

Select your Input Mode (Mancini NL or CSV).

Input your daily Supports and Resistances.

Configure your Flush Depth, Acceptance Time, and Dip Buffer based on the volatility of your chosen asset.

Set up a TradingView Alert with the condition Any alert() function call to route the script's internal execution logs directly to your webhook.

Disclaimer: This script is for educational and informational purposes only. Trading futures, options, and equities carries significant risk. Always forward-test indicator logic in a paper trading environment before risking live capital.

## Source Code

````pine
//@version=6 
indicator("FBD Reclaim Tool v52", shorttitle="FBD v52", overlay=true, max_labels_count=500, max_lines_count=500)

// ==========================================
// 1. UI & Configuration
// ==========================================
grp_mode = "1. Input Mode"
in_mode = input.string("Mancini NL Format", "Select Input Mode", options=["Mancini NL Format", "Comma Separated"], group=grp_mode, display=display.none)

grp_nl = "2. Mancini NL Format (Text Areas)"
in_nl_res = input.text_area("7205 (major), 7213, 7221 (major), 7233, 7244 (major)", "Resistances", group=grp_nl, display=display.none)
in_nl_sup = input.text_area("7198 (major), 7193, 7186, 7175(major), 7180 (major)", "Supports", group=grp_nl, display=display.none)

grp_csv = "2. Comma Separated Format"
in_csv_sup = input.string("7100, 7085", "Major Supports (FBD)", group=grp_csv, display=display.none)
in_csv_res = input.string("7204, 7224", "Major Resistances (TP)", group=grp_csv, display=display.none)
in_csv_oth = input.string("7120, 7133", "Other Minor Levels", group=grp_csv, display=display.none)

grp_set = "3. Parameters & TP/SL Logic"
in_trade_dir = input.string("Long & Short", "Trade Direction", options=["Long Only", "Short Only", "Long & Short"], group=grp_set, display=display.none)

in_lookback = input.int(2, "Active Lookback Window (Days)", group=grp_set, tooltip="Only process and show signals within this many days.", display=display.none)
in_flush = input.float(2.0, "Flush/Sweep Depth (Pts)", group=grp_set, display=display.none)

// 🟢 SPLIT TIMERS FOR LONG AND SHORT
in_acc_time_L = input.int(100, "Long Reclaim Time (Secs)", group=grp_set, tooltip="Seconds price must hold ABOVE support.", display=display.none)
in_dip_reset_time_L = input.int(8, "Long Dip Reset Time (Secs)", group=grp_set, tooltip="Reset Long timer if submerged for this long.", display=display.none)

in_acc_time_S = input.int(100, "Short Reclaim Time (Secs)", group=grp_set, tooltip="Seconds price must hold BELOW resistance.", display=display.none)
in_dip_reset_time_S = input.int(8, "Short Pop Reset Time (Secs)", group=grp_set, tooltip="Reset Short timer if floating above for this long.", display=display.none)

in_flush_exp_min = input.int(60, "Flush Validity Window (Minutes)", group=grp_set, tooltip="Abandon setup if timeout.", display=display.none)

in_use_next_lvl_sl = input.bool(false, "Use Next Major Level for SL", group=grp_set, tooltip="SL will be the next major level, OR the Min SL Distance, whichever is safer.", display=display.none)
in_sl_pts = input.float(10.0, "Min / Fixed SL Distance (Pts)", group=grp_set, tooltip="Guarantees SL is AT LEAST this many points away.", display=display.none)

in_use_lvl_tp = input.bool(false, "Use Major Level for TP", group=grp_set, tooltip="If disabled, strictly uses Auto TP distance.", display=display.none)
in_auto_tp_pts = input.float(10.0, "Auto TP / Min TP Distance (Pts)", group=grp_set, tooltip="If nearest structural level is closer than this, override with Auto TP.", display=display.none)

in_hide_trade_labels = input.bool(false, "Hide Entry/SL/TP Labels (Levels Only)", group=grp_set, tooltip="Hides all trade labels (Entry/SL/TP, flush, timer, target/stop hits). Only the level lines and their price labels remain.", display=display.none)

grp_session = "4. Tactical HUD (Top Right)"
in_show_hud = input.bool(false, "Show Top-Right Session HUD", group=grp_session, display=display.none)
in_gap_pts = input.float(5.0, "Sunday Gap Down Threshold (Pts)", group=grp_session, display=display.none)

grp_filter = "5. Trend / Quality Filter"
in_use_ma_filter = input.bool(true, "Enable MA Trend Filter (Marks Low Quality)", group=grp_filter, display=display.none)
in_ma_tf = input.timeframe("15", "MA Timeframe", group=grp_filter, display=display.none)
in_ma_len = input.int(9, "MA Length", group=grp_filter, display=display.none)

// ==========================================
// 2. Validation & Environment
// ==========================================
is_valid_tf = timeframe.isseconds or timeframe.isintraday
is_recent = (timenow - time) <= (in_lookback * 86400000)
can_run = is_valid_tf and is_recent

bool enable_long = (in_trade_dir == "Long Only" or in_trade_dir == "Long & Short")
bool enable_short = (in_trade_dir == "Short Only" or in_trade_dir == "Long & Short")

// ==========================================
// 3. String Parser & Level Mapping
// ==========================================
var float[] fbd_levels = array.new_float() 
var float[] res_levels = array.new_float() 
var float[] oth_levels = array.new_float() 

f_parse_nl(string _str, bool _is_sup) =>
    string[] _parts = str.split(_str, ",")
    if array.size(_parts) > 0
        for _p in _parts
            string _match = str.match(_p, "\\d+(\\.\\d+)?")
            if not na(_match)
                float _val = str.tonumber(_match)
                bool _is_major = str.contains(str.lower(_p), "major")
                
                if _is_major
                    if _is_sup
                        array.push(fbd_levels, _val)
                    else
                        array.push(res_levels, _val)
                else
                    array.push(oth_levels, _val)

f_parse_csv(string _str, array<float> _arr) =>
    string[] _parts = str.split(_str, ",")
    if array.size(_parts) > 0
        for _p in _parts
            float _val = str.tonumber(str.trim(_p))
            if not na(_val)
                array.push(_arr, _val)

if barstate.isfirst
    if in_mode == "Mancini NL Format"
        f_parse_nl(in_nl_sup, true)  
        f_parse_nl(in_nl_res, false) 
    else
        f_parse_csv(in_csv_sup, fbd_levels)
        f_parse_csv(in_csv_res, res_levels)
        f_parse_csv(in_csv_oth, oth_levels)
        
    array.sort(fbd_levels)
    array.sort(res_levels)
    array.sort(oth_levels)

// ------------------------------------------------------------------
// GEX-STYLE DYNAMIC DRAWING ENGINE
// ------------------------------------------------------------------
var line[] draw_lines = array.new_line()
var label[] draw_labels = array.new_label()
var bool lines_created = false

if not lines_created
    if array.size(fbd_levels) > 0
        for i = 0 to array.size(fbd_levels) - 1
            float _lvl = array.get(fbd_levels, i)
            array.push(draw_lines, line.new(x1=time, y1=_lvl, x2=time, y2=_lvl, xloc=xloc.bar_time, color=color.new(color.green, 40), style=line.style_solid))
            array.push(draw_labels, label.new(x=time, y=_lvl, text=str.tostring(_lvl) + " (Major Support)", xloc=xloc.bar_time, color=color.new(color.green, 20), textcolor=color.white, style=label.style_label_left, size=size.small))
            
    if array.size(res_levels) > 0
        for i = 0 to array.size(res_levels) - 1
            float _lvl = array.get(res_levels, i)
            array.push(draw_lines, line.new(x1=time, y1=_lvl, x2=time, y2=_lvl, xloc=xloc.bar_time, color=color.new(color.red, 40), style=line.style_solid))
            array.push(draw_labels, label.new(x=time, y=_lvl, text=str.tostring(_lvl) + " (Major Resistance)", xloc=xloc.bar_time, color=color.new(color.red, 20), textcolor=color.white, style=label.style_label_left, size=size.small))
            
    if array.size(oth_levels) > 0
        for i = 0 to array.size(oth_levels) - 1
            float _lvl = array.get(oth_levels, i)
            array.push(draw_lines, line.new(x1=time, y1=_lvl, x2=time, y2=_lvl, xloc=xloc.bar_time, color=color.new(color.gray, 70), style=line.style_dashed))
            array.push(draw_labels, label.new(x=time, y=_lvl, text=str.tostring(_lvl) + " (Minor)", xloc=xloc.bar_time, color=color.new(color.gray, 60), textcolor=color.silver, style=label.style_label_left, size=size.small))
            
    lines_created := true

if barstate.islast and lines_created and array.size(draw_lines) > 0
    int lookbackTime = time - (in_lookback * 86400000) 
    int right_edge = time
    if not na(chart.right_visible_bar_time)
        right_edge := chart.right_visible_bar_time
        
    for i = 0 to array.size(draw_lines) - 1
        line _l = array.get(draw_lines, i)
        label _lbl = array.get(draw_labels, i)
        float _y = line.get_y1(_l)
        line.set_xy1(_l, lookbackTime, _y)
        line.set_xy2(_l, time + 86400000, _y) 
        label.set_xy(_lbl, right_edge, _y)

// ==========================================
// 4. Tactical HUD (Top Right)
// ==========================================
var table session_tbl = table.new(position.top_right, 2, 4)

string tz = "America/New_York"
int h_ny = hour(timenow, tz)
int m_ny = minute(timenow, tz)
int s_ny = second(timenow, tz)
int dow_ny = dayofweek(timenow, tz)
int curr_secs = h_ny * 3600 + m_ny * 60 + s_ny

bool is_new_week = (dow_ny == dayofweek.sunday) and (dayofweek(time[1], tz) == dayofweek.friday)
var bool is_sunday_gap_down = false
if is_new_week
    if open <= (close[1] - in_gap_pts)
        is_sunday_gap_down := true
    else
        is_sunday_gap_down := false

string s_rating = "F"
color s_col = color.new(color.gray, 50)
int mins_ny = h_ny * 60 + m_ny

if dow_ny == dayofweek.sunday 
    s_rating := is_sunday_gap_down ? "A (Gap Down)" : "F"
    s_col := is_sunday_gap_down ? color.new(color.orange, 0) : color.new(color.gray, 50)
else if mins_ny >= (9 * 60 + 30) and mins_ny < (11 * 60)
    s_rating := "A+"
    s_col := color.teal
else if (mins_ny >= (7 * 60 + 30) and mins_ny < (9 * 60 + 30)) or (mins_ny >= (15 * 60) and mins_ny < (16 * 60))
    s_rating := "B"
    s_col := color.yellow
else
    s_rating := "F"
    s_col := color.new(color.red, 50)

int close_secs = 16 * 3600
int rem_secs = close_secs - curr_secs

string time_str = ""
color time_col = color.white

if dow_ny == dayofweek.saturday or (dow_ny == dayofweek.sunday and h_ny < 18)
    time_str := "Weekend"
    time_col := color.gray
else if rem_secs > 0 and curr_secs >= (9 * 3600 + 30 * 60)
    int h_rem = math.floor(rem_secs / 3600)
    int m_rem = math.floor((rem_secs % 3600) / 60)
    int sec_rem = rem_secs % 60
    time_str := str.tostring(h_rem, "00") + ":" + str.tostring(m_rem, "00") + ":" + str.tostring(sec_rem, "00")
    time_col := rem_secs <= 3600 ? color.orange : color.white 
else if rem_secs <= 0 and curr_secs < (17 * 3600)
    time_str := "Closed (Cash)"
    time_col := color.red
else
    time_str := "Pre-Market/Globex"
    time_col := color.gray

f_mode_stats() =>
    float _atr = ta.atr(14)
    float _hl = high[1] - low[1]
    float _body = math.abs(close[1] - open[1])
    
    bool is_mode_1 = _hl > 0 and (_body / _hl) >= 0.75
    bool is_m1_red = is_mode_1 and close[1] < open[1]
    
    int m1_red_days = ta.barssince(is_m1_red)
    m1_red_days

bars_since_m1_red = request.security(syminfo.tickerid, "D", f_mode_stats())
[d_high, d_low, d_prev_close, d_atr] = request.security(syminfo.tickerid, "D", [high, low, close[1], ta.atr(14)])

float htf_ma = request.security(syminfo.tickerid, in_ma_tf, ta.sma(close, in_ma_len))

float curr_tr = math.max(d_high - d_low, math.max(math.abs(d_high - d_prev_close), math.abs(d_low - d_prev_close)))
float atr_pct = d_atr > 0 ? (curr_tr / d_atr) * 100 : 0
string atr_str = str.tostring(curr_tr, "#.#") + " / " + str.tostring(d_atr, "#.#") + " (" + str.tostring(atr_pct, "#") + "%)"
color atr_col = atr_pct > 100 ? color.red : (atr_pct > 80 ? color.orange : color.white)

int display_m1_days = bars_since_m1_red + 1
string m1_red_str = na(bars_since_m1_red) ? "N/A" : (str.tostring(display_m1_days) + "d ago")
color m1_red_col = na(bars_since_m1_red) ? color.gray : (display_m1_days <= 2 ? color.green : color.white)

if barstate.islast and in_show_hud
    color s_bg = color.new(color.black, 0)
    table.cell(session_tbl, 0, 0, " SESSION RATING ", text_color=color.silver, bgcolor=s_bg, text_halign=text.align_left, text_size=size.small)
    table.cell(session_tbl, 1, 0, " " + s_rating + " ", text_color=s_col, bgcolor=s_bg, text_halign=text.align_right, text_size=size.normal)
    table.cell(session_tbl, 0, 1, " CASH CLOSE IN ", text_color=color.silver, bgcolor=s_bg, text_halign=text.align_left, text_size=size.small)
    table.cell(session_tbl, 1, 1, " " + time_str + " ", text_color=time_col, bgcolor=s_bg, text_halign=text.align_right, text_size=size.normal)
    table.cell(session_tbl, 0, 2, " DAILY TR / ATR14 ", text_color=color.silver, bgcolor=s_bg, text_halign=text.align_left, text_size=size.small)
    table.cell(session_tbl, 1, 2, " " + atr_str + " ", text_color=atr_col, bgcolor=s_bg, text_halign=text.align_right, text_size=size.small)
    table.cell(session_tbl, 0, 3, " LAST M1 RED DAY ", text_color=color.silver, bgcolor=s_bg, text_halign=text.align_left, text_size=size.small)
    table.cell(session_tbl, 1, 3, " " + m1_red_str + " ", text_color=m1_red_col, bgcolor=s_bg, text_halign=text.align_right, text_size=size.small)

// ==========================================
// 5. Dual-Core Logic State Machine 
// ==========================================

f_discord(string _msg) =>
    string _clean = str.replace_all(_msg, '\n', '\\n')
    _clean := str.replace_all(_clean, '"', '\\"')
    '{"content": "' + _clean + '"}'

float[] closes_1S = request.security_lower_tf(syminfo.tickerid, "1S", close)
float[] lows_1S   = request.security_lower_tf(syminfo.tickerid, "1S", low)
float[] highs_1S  = request.security_lower_tf(syminfo.tickerid, "1S", high)
int[]   times_1S  = request.security_lower_tf(syminfo.tickerid, "1S", time)

var float[] armed_longs = array.new_float()
var float[] armed_shorts = array.new_float()
var int last_day = dayofmonth(time, "America/New_York")
int current_day = dayofmonth(time, "America/New_York")

if current_day != last_day
    array.clear(armed_longs)
    array.clear(armed_shorts)
    last_day := current_day

varip int state_L = 0 
varip float fbd_L = na
varip float rec_L = na
varip float ext_L = na
varip int time_L = na
varip int hist_acc_L = 0
varip int curr_acc_L = 0
varip int hist_dip_L = 0
varip float entry_L = na
varip float sl_L = na
varip float tp_L = na
varip float vel_L = na
var label track_lbl_L = na
var label flush_lbl_L = na
varip bool is_auto_tp_L = false

varip int state_S = 0 
varip float fbd_S = na
varip float rec_S = na
varip float ext_S = na
varip int time_S = na
varip int hist_acc_S = 0
varip int curr_acc_S = 0
varip int hist_dip_S = 0
varip float entry_S = na
varip float sl_S = na
varip float tp_S = na
varip float vel_S = na
var label track_lbl_S = na
var label flush_lbl_S = na
varip bool is_auto_tp_S = false

var table trade_tbl = table.new(position.bottom_right, 3, 7)
f_render_hud() =>
    color bg = color.new(color.black, 0)
    for c = 0 to 2
        for r = 0 to 6
            table.cell(trade_tbl, c, r, "", bgcolor=na)

    bool has_L = (state_L == 2)
    bool has_S = (state_S == 2)

    if has_L or has_S
        table.cell(trade_tbl, 0, 0, " SIGNAL ", text_color=color.silver, bgcolor=bg, text_halign=text.align_left)
        table.cell(trade_tbl, 0, 1, " ENTRY ", text_color=color.silver, bgcolor=bg, text_halign=text.align_left)
        table.cell(trade_tbl, 0, 2, " STOP LOSS ", text_color=color.silver, bgcolor=bg, text_halign=text.align_left)
        table.cell(trade_tbl, 0, 3, " TARGET ", text_color=color.silver, bgcolor=bg, text_halign=text.align_left)
        table.cell(trade_tbl, 0, 4, " R/R RATIO ", text_color=color.silver, bgcolor=bg, text_halign=text.align_left)
        table.cell(trade_tbl, 0, 5, " RISK ", text_color=color.silver, bgcolor=bg, text_halign=text.align_left)
        table.cell(trade_tbl, 0, 6, " SPEED ", text_color=color.silver, bgcolor=bg, text_halign=text.align_left)

        int col_L = has_L ? 1 : na
        int col_S = has_L and has_S ? 2 : (has_S ? 1 : na)

        if has_L
            float risk = math.abs(entry_L - sl_L)
            float rwd = math.abs(tp_L - entry_L)
            float rr = risk > 0 ? (rwd / risk) : 0
            table.cell(trade_tbl, col_L, 0, " BUY ", text_color=color.teal, bgcolor=bg, text_halign=text.align_right)
            table.cell(trade_tbl, col_L, 1, " " + str.tostring(entry_L) + " ", text_color=color.white, bgcolor=bg, text_halign=text.align_right)
            table.cell(trade_tbl, col_L, 2, " " + str.tostring(sl_L) + " ", text_color=color.red, bgcolor=bg, text_halign=text.align_right)
            table.cell(trade_tbl, col_L, 3, " " + (na(tp_L) ? "N/A" : str.tostring(tp_L)) + " ", text_color=color.green, bgcolor=bg, text_halign=text.align_right)
            table.cell(trade_tbl, col_L, 4, " 1 : " + str.tostring(rr, "#.##") + " ", text_color=color.white, bgcolor=bg, text_halign=text.align_right)
            table.cell(trade_tbl, col_L, 5, " " + str.tostring(risk, "#.##") + " pts ", text_color=color.orange, bgcolor=bg, text_halign=text.align_right)
            table.cell(trade_tbl, col_L, 6, " " + str.tostring(vel_L, "#.##") + " pts/m ", text_color=color.white, bgcolor=bg, text_halign=text.align_right)

        if has_S
            float risk = math.abs(entry_S - sl_S)
            float rwd = math.abs(tp_S - entry_S)
            float rr = risk > 0 ? (rwd / risk) : 0
            table.cell(trade_tbl, col_S, 0, " SELL ", text_color=color.fuchsia, bgcolor=bg, text_halign=text.align_right)
            table.cell(trade_tbl, col_S, 1, " " + str.tostring(entry_S) + " ", text_color=color.white, bgcolor=bg, text_halign=text.align_right)
            table.cell(trade_tbl, col_S, 2, " " + str.tostring(sl_S) + " ", text_color=color.red, bgcolor=bg, text_halign=text.align_right)
            table.cell(trade_tbl, col_S, 3, " " + (na(tp_S) ? "N/A" : str.tostring(tp_S)) + " ", text_color=color.green, bgcolor=bg, text_halign=text.align_right)
            table.cell(trade_tbl, col_S, 4, " 1 : " + str.tostring(rr, "#.##") + " ", text_color=color.white, bgcolor=bg, text_halign=text.align_right)
            table.cell(trade_tbl, col_S, 5, " " + str.tostring(risk, "#.##") + " pts ", text_color=color.orange, bgcolor=bg, text_halign=text.align_right)
            table.cell(trade_tbl, col_S, 6, " " + str.tostring(vel_S, "#.##") + " pts/m ", text_color=color.white, bgcolor=bg, text_halign=text.align_right)

if can_run
    // --------------------------------------------------------
    // 🟢 1. EXIT MANAGERS
    // --------------------------------------------------------
    if state_L == 2
        bool hit_tp = false
        bool hit_sl = false
        if not na(sl_L) and low <= sl_L
            hit_sl := true
        else if not na(tp_L) and high >= tp_L
            hit_tp := true

        if hit_tp
            if not in_hide_trade_labels
                label.new(bar_index, high, "💰 TARGET HIT\nClose Long\n" + str.tostring(tp_L), color=color.new(color.green, 20), textcolor=color.white, style=label.style_label_down, size=size.small)
            alert(f_discord("💰 LONG TARGET HIT: " + str.tostring(tp_L) + "\nClose Position immediately."), alert.freq_once_per_bar_close)
            state_L := 0
        else if hit_sl
            if not in_hide_trade_labels
                label.new(bar_index, low, "🛑 STOPPED OUT\nLong SL: " + str.tostring(sl_L), color=color.new(color.red, 20), textcolor=color.white, style=label.style_label_up, size=size.small)
            alert(f_discord("🛑 LONG STOPPED OUT at " + str.tostring(sl_L)), alert.freq_once_per_bar_close)
            state_L := 0

    if state_S == 2
        bool hit_tp_s = false
        bool hit_sl_s = false
        if not na(sl_S) and high >= sl_S
            hit_sl_s := true
        else if not na(tp_S) and low <= tp_S
            hit_tp_s := true

        if hit_tp_s
            if not in_hide_trade_labels
                label.new(bar_index, low, "💰 TARGET HIT\nClose Short\n" + str.tostring(tp_S), color=color.new(color.green, 20), textcolor=color.white, style=label.style_label_up, size=size.small)
            alert(f_discord("💰 SHORT TARGET HIT: " + str.tostring(tp_S) + "\nClose Position immediately."), alert.freq_once_per_bar_close)
            state_S := 0
        else if hit_sl_s
            if not in_hide_trade_labels
                label.new(bar_index, high, "🛑 STOPPED OUT\nShort SL: " + str.tostring(sl_S), color=color.new(color.red, 20), textcolor=color.white, style=label.style_label_down, size=size.small)
            alert(f_discord("🛑 SHORT STOPPED OUT at " + str.tostring(sl_S)), alert.freq_once_per_bar_close)
            state_S := 0

    // --------------------------------------------------------
    // 🟢 2. LONG ENGINE
    // --------------------------------------------------------
    if enable_long
        float new_fbd_L = na
        bool is_new_flush_L = false
        
        if array.size(fbd_levels) > 0
            for i = 0 to array.size(fbd_levels) - 1
                float _fbd = array.get(fbd_levels, i)
                bool is_armed = array.includes(armed_longs, _fbd)
                
                bool trigger_new = (low <= _fbd - in_flush)
                bool trigger_armed = is_armed and (low <= _fbd)
                
                if trigger_new or trigger_armed
                    bool can_trigger = false
                    if state_L == 0
                        can_trigger := true 
                    else if state_L == 1
                        if _fbd < fbd_L 
                            can_trigger := true
                    
                    if can_trigger
                        if na(new_fbd_L) or _fbd < new_fbd_L
                            new_fbd_L := _fbd 
                            is_new_flush_L := trigger_new and not is_armed

        if not na(new_fbd_L)
            fbd_L := new_fbd_L
            rec_L := new_fbd_L 
            state_L := 1 
            ext_L := low
            hist_acc_L := 0
            curr_acc_L := 0
            hist_dip_L := 0
            
            time_L := na
            if array.size(lows_1S) > 0 and array.size(times_1S) > 0
                int max_idx = math.min(array.size(lows_1S), array.size(times_1S))
                for i = 0 to max_idx - 1
                    float target_low = is_new_flush_L ? (fbd_L - in_flush) : fbd_L
                    if array.get(lows_1S, i) <= target_low
                        time_L := array.get(times_1S, i)
                        break
                            
            if na(time_L)
                time_L := barstate.isrealtime ? timenow : time
            
            if not na(track_lbl_L)
                label.delete(track_lbl_L)
                track_lbl_L := na
            if not na(flush_lbl_L)
                flush_lbl_L := na 
                
            if is_new_flush_L
                array.push(armed_longs, fbd_L)
                float current_depth = math.abs(fbd_L - ext_L)
                string f_txt = "FLUSHED by " + str.tostring(current_depth, "#.##") + " pts\nWait: " + str.tostring(rec_L)
                if not in_hide_trade_labels
                    flush_lbl_L := label.new(bar_index - 1, fbd_L, f_txt, color=color.new(color.red, 30), textcolor=color.white, style=label.style_label_right, size=size.small)
                alert(f_discord("🚨 LONG FLUSH: Support " + str.tostring(fbd_L) + " breached. Waiting for reclaim at " + str.tostring(rec_L)), alert.freq_once_per_bar_close)

        if state_L == 1 and not na(time_L)
            int current_time_check = barstate.isrealtime ? timenow : time
            if (current_time_check - time_L) > (in_flush_exp_min * 60000)
                state_L := 0 
                if not na(flush_lbl_L)
                    label.delete(flush_lbl_L)
                    flush_lbl_L := na
                if not na(track_lbl_L)
                    label.delete(track_lbl_L)
                    track_lbl_L := na

        if state_L == 1
            ext_L := math.min(ext_L, low)
            if not na(flush_lbl_L)
                float max_depth = math.abs(fbd_L - ext_L)
                label.set_text(flush_lbl_L, "FLUSHED by " + str.tostring(max_depth, "#.##") + " pts\nWait: " + str.tostring(rec_L))
            
            int temp_acc = hist_acc_L
            int temp_dip = hist_dip_L
            
            if not na(closes_1S) and array.size(closes_1S) > 0 and not na(time_L)
                int size_1s = math.min(array.size(closes_1S), array.size(times_1S))
                int bar_end_time = barstate.isrealtime ? math.min(timenow, time_close + 1) : time_close + 1
                for i = 0 to size_1s - 1
                    int t_start = array.get(times_1S, i)
                    int t_end   = (i == size_1s - 1) ? bar_end_time : array.get(times_1S, i + 1)
                    int actual_start = math.max(t_start, time_L)
                    if actual_start < t_end 
                        int dt = math.max(0, math.round((t_end - actual_start) / 1000))
                        if dt > 0
                            if array.get(closes_1S, i) >= rec_L
                                temp_acc += dt
                                temp_dip := 0
                            else
                                temp_dip += dt 
                                if temp_dip >= in_dip_reset_time_L
                                    temp_acc := 0 
                        
            curr_acc_L := temp_acc
            if barstate.isconfirmed
                hist_acc_L := curr_acc_L
                hist_dip_L := temp_dip
                
            if curr_acc_L > 0 and not in_hide_trade_labels
                string t_str = "⏳ " + str.tostring(curr_acc_L) + " / " + str.tostring(in_acc_time_L) + " Secs"
                if na(track_lbl_L)
                    track_lbl_L := label.new(bar_index, ext_L - 2, t_str, color=color.new(color.orange, 0), textcolor=color.white, style=label.style_label_up, size=size.small)
                else
                    label.set_xy(track_lbl_L, bar_index, ext_L - 2)
                    label.set_text(track_lbl_L, t_str)
                    
            if curr_acc_L >= in_acc_time_L
                state_L := 2
                entry_L := rec_L + 2.0
                
                bool is_lq = in_use_ma_filter and not na(htf_ma) and entry_L < htf_ma
                
                float fixed_sl = entry_L - in_sl_pts
                float chosen_sl = fixed_sl
                if in_use_next_lvl_sl
                    float next_sup = na
                    if array.size(fbd_levels) > 0
                        for i = array.size(fbd_levels) - 1 to 0
                            float _val = array.get(fbd_levels, i)
                            if _val < fbd_L
                                next_sup := _val
                                break
                    if not na(next_sup) and next_sup < fixed_sl
                        chosen_sl := next_sup
                sl_L := chosen_sl

                flush_lbl_L := na 
                if not na(track_lbl_L)
                    label.delete(track_lbl_L)
                    track_lbl_L := na
                    
                is_auto_tp_L := false 
                float found_tp = na
                if array.size(res_levels) > 0
                    for i = 0 to array.size(res_levels) - 1
                        float _l = array.get(res_levels, i)
                        if _l > entry_L
                            found_tp := _l
                            break
                if in_use_lvl_tp and not na(found_tp) and (found_tp - entry_L) >= in_auto_tp_pts
                    tp_L := found_tp
                else
                    tp_L := entry_L + in_auto_tp_pts
                    is_auto_tp_L := true 
                
                string lq_prefix = is_lq ? "⚠️ LQ " : ""
                color buy_col = is_lq ? color.orange : color.teal
                string buy_txt = lq_prefix + "BUY"
                
                if not in_hide_trade_labels
                    label.new(bar_index + 1, entry_L, buy_txt + " @ " + str.tostring(entry_L), color=buy_col, textcolor=color.white, style=label.style_label_left, size=size.small)
                    label.new(bar_index + 1, sl_L, "SL @ " + str.tostring(sl_L), color=color.red, textcolor=color.white, style=label.style_label_up, size=size.small)
                    if not na(tp_L)
                        string tp_pre = is_auto_tp_L ? "AUTO TP @ " : "TP @ "
                        label.new(bar_index + 1, tp_L, tp_pre + str.tostring(tp_L), color=color.new(color.green, 20), textcolor=color.white, style=label.style_label_down, size=size.small)
                
                float max_depth_L = math.abs(fbd_L - ext_L)
                int current_t_L = barstate.isrealtime ? timenow : time
                int elapsed_sec_L = math.max(1, math.round((current_t_L - time_L) / 1000))
                vel_L := max_depth_L / (elapsed_sec_L / 60.0)
                
                string reclaim_str_L = "\\n📉 Depth: " + str.tostring(max_depth_L, "#.##") + " pts\\n⏱️ Time: " + str.tostring(elapsed_sec_L) + "s\\n⚡ Vel: " + str.tostring(vel_L, "#.##") + " pts/min"
                string stats_str = "R/R: 1 : " + str.tostring(na(tp_L) or math.abs(entry_L - sl_L)<=0 ? 0 : (math.abs(tp_L - entry_L)/math.abs(entry_L - sl_L)), "#.##") + "\\nRisk: " + str.tostring(math.abs(entry_L - sl_L), "#.##") + " pts" + reclaim_str_L
                
                alert(f_discord("✅ " + buy_txt + " SIGNAL TRIGGERED!\\n" + stats_str + "\\n➤ ENTRY: " + str.tostring(entry_L)), alert.freq_once_per_bar_close)

    // --------------------------------------------------------
    // 🟢 3. SHORT ENGINE
    // --------------------------------------------------------
    if enable_short
        float new_fbd_S = na
        bool is_new_flush_S = false
        
        if array.size(res_levels) > 0
            for i = 0 to array.size(res_levels) - 1
                float _fbd = array.get(res_levels, i)
                bool is_armed = array.includes(armed_shorts, _fbd)
                
                bool trigger_new = (high >= _fbd + in_flush)
                bool trigger_armed = is_armed and (high >= _fbd)
                
                if trigger_new or trigger_armed
                    bool can_trigger = false
                    if state_S == 0
                        can_trigger := true 
                    else if state_S == 1
                        if _fbd > fbd_S 
                            can_trigger := true
                    
                    if can_trigger
                        if na(new_fbd_S) or _fbd > new_fbd_S
                            new_fbd_S := _fbd 
                            is_new_flush_S := trigger_new and not is_armed

        if not na(new_fbd_S)
            fbd_S := new_fbd_S
            rec_S := new_fbd_S 
            state_S := 1 
            ext_S := high
            hist_acc_S := 0
            curr_acc_S := 0
            hist_dip_S := 0
            
            time_S := na
            if array.size(highs_1S) > 0 and array.size(times_1S) > 0
                int max_idx = math.min(array.size(highs_1S), array.size(times_1S))
                for i = 0 to max_idx - 1
                    float target_high = is_new_flush_S ? (fbd_S + in_flush) : fbd_S
                    if array.get(highs_1S, i) >= target_high
                        time_S := array.get(times_1S, i)
                        break
                            
            if na(time_S)
                time_S := barstate.isrealtime ? timenow : time
            
            if not na(track_lbl_S)
                label.delete(track_lbl_S)
                track_lbl_S := na
            if not na(flush_lbl_S)
                flush_lbl_S := na 
                
            if is_new_flush_S
                array.push(armed_shorts, fbd_S)
                float current_depth = math.abs(fbd_S - ext_S)
                string f_txt = "SWEPT by " + str.tostring(current_depth, "#.##") + " pts\nWait: " + str.tostring(rec_S)
                if not in_hide_trade_labels
                    flush_lbl_S := label.new(bar_index - 1, fbd_S, f_txt, color=color.new(color.fuchsia, 30), textcolor=color.white, style=label.style_label_right, size=size.small)
                alert(f_discord("🚨 SHORT SWEEP: Resistance " + str.tostring(fbd_S) + " breached. Waiting for reclaim at " + str.tostring(rec_S)), alert.freq_once_per_bar_close)

        if state_S == 1 and not na(time_S)
            int current_time_check = barstate.isrealtime ? timenow : time
            if (current_time_check - time_S) > (in_flush_exp_min * 60000)
                state_S := 0 
                if not na(flush_lbl_S)
                    label.delete(flush_lbl_S)
                    flush_lbl_S := na
                if not na(track_lbl_S)
                    label.delete(track_lbl_S)
                    track_lbl_S := na

        if state_S == 1
            ext_S := math.max(ext_S, high)
            if not na(flush_lbl_S)
                float max_depth = math.abs(fbd_S - ext_S)
                label.set_text(flush_lbl_S, "SWEPT by " + str.tostring(max_depth, "#.##") + " pts\nWait: " + str.tostring(rec_S))
            
            int temp_acc_s = hist_acc_S
            int temp_dip_s = hist_dip_S
            
            if not na(closes_1S) and array.size(closes_1S) > 0 and not na(time_S)
                int size_1s = math.min(array.size(closes_1S), array.size(times_1S))
                int bar_end_time = barstate.isrealtime ? math.min(timenow, time_close + 1) : time_close + 1
                for i = 0 to size_1s - 1
                    int t_start = array.get(times_1S, i)
                    int t_end   = (i == size_1s - 1) ? bar_end_time : array.get(times_1S, i + 1)
                    int actual_start = math.max(t_start, time_S)
                    if actual_start < t_end 
                        int dt = math.max(0, math.round((t_end - actual_start) / 1000))
                        if dt > 0
                            if array.get(closes_1S, i) <= rec_S
                                temp_acc_s += dt
                                temp_dip_s := 0
                            else
                                temp_dip_s += dt
                                if temp_dip_s >= in_dip_reset_time_S
                                    temp_acc_s := 0 
                        
            curr_acc_S := temp_acc_s
            if barstate.isconfirmed
                hist_acc_S := curr_acc_S
                hist_dip_S := temp_dip_s
                
            if curr_acc_S > 0 and not in_hide_trade_labels
                string t_str = "⏳ " + str.tostring(curr_acc_S) + " / " + str.tostring(in_acc_time_S) + " Secs"
                if na(track_lbl_S)
                    track_lbl_S := label.new(bar_index, ext_S + 2, t_str, color=color.new(color.orange, 0), textcolor=color.white, style=label.style_label_down, size=size.small)
                else
                    label.set_xy(track_lbl_S, bar_index, ext_S + 2)
                    label.set_text(track_lbl_S, t_str)
                    
            if curr_acc_S >= in_acc_time_S
                state_S := 2
                entry_S := rec_S - 2.0
                
                bool is_lq = in_use_ma_filter and not na(htf_ma) and entry_S > htf_ma
                
                float fixed_sl = entry_S + in_sl_pts
                float chosen_sl = fixed_sl
                if in_use_next_lvl_sl
                    float next_res = na
                    if array.size(res_levels) > 0
                        for i = 0 to array.size(res_levels) - 1
                            float _val = array.get(res_levels, i)
                            if _val > fbd_S
                                next_res := _val
                                break
                    if not na(next_res) and next_res > fixed_sl
                        chosen_sl := next_res
                sl_S := chosen_sl

                flush_lbl_S := na 
                if not na(track_lbl_S)
                    label.delete(track_lbl_S)
                    track_lbl_S := na
                    
                is_auto_tp_S := false 
                float found_tp = na
                if array.size(fbd_levels) > 0
                    for i = array.size(fbd_levels) - 1 to 0
                        float _l = array.get(fbd_levels, i)
                        if _l < entry_S
                            found_tp := _l
                            break
                if in_use_lvl_tp and not na(found_tp) and (entry_S - found_tp) >= in_auto_tp_pts
                    tp_S := found_tp
                else
                    tp_S := entry_S - in_auto_tp_pts
                    is_auto_tp_S := true 
                
                string lq_prefix = is_lq ? "⚠️ LQ " : ""
                color sell_col = is_lq ? color.orange : color.fuchsia
                string sell_txt = lq_prefix + "SELL"
                
                if not in_hide_trade_labels
                    label.new(bar_index + 1, entry_S, sell_txt + " @ " + str.tostring(entry_S), color=sell_col, textcolor=color.white, style=label.style_label_left, size=size.small)
                    label.new(bar_index + 1, sl_S, "SL @ " + str.tostring(sl_S), color=color.red, textcolor=color.white, style=label.style_label_down, size=size.small)
                    if not na(tp_S)
                        string tp_pre = is_auto_tp_S ? "AUTO TP @ " : "TP @ "
                        label.new(bar_index + 1, tp_S, tp_pre + str.tostring(tp_S), color=color.new(color.green, 20), textcolor=color.white, style=label.style_label_up, size=size.small)
                
                float max_depth_S = math.abs(fbd_S - ext_S)
                int current_t_S = barstate.isrealtime ? timenow : time
                int elapsed_sec_S = math.max(1, math.round((current_t_S - time_S) / 1000))
                vel_S := max_depth_S / (elapsed_sec_S / 60.0)
                
                string reclaim_str_S = "\\n📈 Depth: " + str.tostring(max_depth_S, "#.##") + " pts\\n⏱️ Time: " + str.tostring(elapsed_sec_S) + "s\\n⚡ Vel: " + str.tostring(vel_S, "#.##") + " pts/min"
                string stats_str = "R/R: 1 : " + str.tostring(na(tp_S) or math.abs(entry_S - sl_S)<=0 ? 0 : (math.abs(tp_S - entry_S)/math.abs(entry_S - sl_S)), "#.##") + "\\nRisk: " + str.tostring(math.abs(entry_S - sl_S), "#.##") + " pts" + reclaim_str_S
                
                alert(f_discord("✅ " + sell_txt + " SIGNAL TRIGGERED!\\n" + stats_str + "\\n➤ ENTRY: " + str.tostring(entry_S)), alert.freq_once_per_bar_close)

    // --------------------------------------------------------
    // 🟢 4. RENDER HUD
    // --------------------------------------------------------
    f_render_hud()

    // --------------------------------------------------------
    // 🟢 5. FALLBACK CLEANUP
    // --------------------------------------------------------
    if state_L == 0
        fbd_L := na, rec_L := na, ext_L := na, time_L := na
        hist_acc_L := 0, curr_acc_L := 0, hist_dip_L := 0
        entry_L := na, sl_L := na, tp_L := na, vel_L := na
        is_auto_tp_L := false
        if not na(track_lbl_L)
            label.delete(track_lbl_L)
            track_lbl_L := na
            
    if state_S == 0
        fbd_S := na, rec_S := na, ext_S := na, time_S := na
        hist_acc_S := 0, curr_acc_S := 0, hist_dip_S := 0
        entry_S := na, sl_S := na, tp_S := na, vel_S := na
        is_auto_tp_S := false
        if not na(track_lbl_S)
            label.delete(track_lbl_S)
            track_lbl_S := na
````

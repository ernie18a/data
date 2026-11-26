# Multi-Engine Matrix

- url: https://www.tradingview.com/script/SUSaBysd-Multi-Engine-Matrix/
- type: indicator
- pine_id: PUB;6becb00eb307436e9e493e94bebd278c
- version: 2.0

## Description

Title: Multi-Engine Matrix [All-in-One]
Description:
The Multi-Engine Matrix is an advanced, all-in-one trading suite designed to bring institutional concepts and momentum oscillators directly onto your main chart. By combining session or timeframe-based liquidity ranges with customizable oscillator projections and a real-time data dashboard, this indicator eliminates the need for multiple chart panes, keeping your workspace clean and highly informative.

https://www.tradingview.com/x/zX1Q9iGn/

🌟 Core Features
1. Dynamic Range & Liquidity Sweeps
The indicator automatically boxes price action based on your chosen mode, tracking the Highest High (HH), Lowest Low (LL), and the 
Volume Point of Control (POC).

https://www.tradingview.com/x/MGEXsdJn/

Session Mode: Tracks the Asian, London, and New York sessions using customizable time inputs.
Timeframe Mode: Tracks ranges based on a selected Higher Timeframe (e.g., Daily or 4H).
Liquidity Sweeps: When price breaks out of a historical session/timeframe box and sweeps the HH or LL, the level turns red and is clearly marked with an "X", highlighting potential liquidity grabs and reversal zones.
Volume POC: Displays the Point of Control for each active and historical range, acting as a magnet or support/resistance level.
2. On-Chart Multi-Engine Oscillators
Forget opening separate indicator panes at the bottom of your chart. The Multi-Engine Matrix projects up to two momentum oscillators (Top Engine and Bottom Engine) directly above and below the active price ranges.

https://www.tradingview.com/x/8LqN47gw/

Available Engines: RSI, Stochastic RSI, WaveTrend, and DMI.
Customizable Size: Adjust the projection height (Small, Medium, Large) and the distance from the price action.
Real-time Visualization: Watch momentum diverge or align with price action within the same visual context. WaveTrend momentum histograms, RSI overbought/oversold zones, and DI crossover dynamics are beautifully rendered as on-chart polylines.
3. Real-Time Bias Dashboard
A sleek, adaptive dashboard is positioned on your chart (top right by default) to give you an immediate macroeconomic and momentum overview.

Active Session: Instantly know which market session you are currently trading.
Daily & Weekly Bias: Automatically calculates if the current price is Bullish or Bearish relative to the Daily and Weekly open levels.
Live Metrics: Displays the exact current values for RSI, WaveTrend Momentum, and Directional Movement (DI+ / DI-).
Daily CVD (Cumulative Volume Delta): Tracks intraday buying and selling pressure to gauge true market intent.
4. Quality of Life Features

Moving Averages & VWAP: Optional overlays for session VWAP and your choice of Moving Average (SMA, EMA, WMA, RMA).
Adaptive UI: Fully supports TradingView's Light and Dark modes. Text colors, labels, and borders automatically adapt to your chart's background for optimal visibility.
⚙️ How to Use
Set Your Mode: Choose whether you want to trade based on specific Time Sessions (Asian/London/NY) or Fixed Timeframes.
Select Your Engines: Choose your preferred momentum oscillators for the Top and Bottom engines.
Watch for Sweeps: Look for price sweeping the historical highs (HH) or lows (LL) marked by a red "X". Combine this with extreme readings on the projected oscillators to spot high-probability reversal setups.
Confirm with the Dashboard: Use the Daily/Weekly bias and CVD metrics to ensure you are trading in the direction of the underlying momentum.
Disclaimer:
The information provided by this script is for educational and informational purposes only and does not constitute financial advice. Trading in financial markets involves a high degree of risk and may not be suitable for all investors. Past performance is not indicative of future results. Always conduct your own research and backtest thoroughly before risking real capital.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Multi-Engine Matrix", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_polylines_count = 100)

// --- Inputs ---
grp_period = "Period Settings"
period_mode = input.string("Sessions", "Mode", options=["Timeframe", "Sessions"], group=grp_period)
htf         = input.timeframe("1D", "Higher Timeframe", group=grp_period)
asian_time  = input.session("2000-0000", "Asian Session (NY Time)", group=grp_period)
london_time = input.session("0300-0800", "London Session (NY Time)", group=grp_period)
ny_time     = input.session("0900-1600", "New York Session (NY Time)", group=grp_period)

grp_setup = "Setup Settings"
last_n       = input.int(4, "Show Last N Boxes", minval=1, maxval=20, group=grp_setup)
vp_bins      = input.int(50, "Volume Profile Rows", minval=10, maxval=200, group=grp_setup)
proj_offset  = input.float(10.0, "Projection Offset from Box %", minval=0.0, maxval=100.0, step=5.0, group=grp_setup) / 100.0

grp_ma = "Moving Averages & VWAP"
show_vwap  = input.bool(true, "Show Period VWAP", group=grp_ma)
col_vwap   = input.color(color.blue, "VWAP Color", group=grp_ma)
vwap_width = input.int(2, "VWAP Width", minval=1, maxval=5, group=grp_ma)
show_ma    = input.bool(false, "Show Moving Average", group=grp_ma)
ma_type    = input.string("SMA", "MA Type", options=["SMA", "EMA", "WMA", "RMA"], group=grp_ma)
ma_len     = input.int(50, "MA Length", group=grp_ma)
col_ma     = input.color(color.orange, "MA Color", group=grp_ma)
ma_width   = input.int(2, "MA Width", minval=1, maxval=5, group=grp_ma)

grp_engines = "Engine Selection"
up_engine  = input.string("RSI", "Up Engine", options=["None", "RSI", "Stoch RSI", "WaveTrend", "DMI"], group=grp_engines)
up_size    = input.string("Medium", "Up Engine Size", options=["Small", "Medium", "Large"], group=grp_engines)
dn_engine  = input.string("WaveTrend", "Down Engine", options=["None", "RSI", "Stoch RSI", "WaveTrend", "DMI"], group=grp_engines)
dn_size    = input.string("Medium", "Down Engine Size", options=["Small", "Medium", "Large"], group=grp_engines)

grp_rsi = "RSI / Stoch RSI Settings"
rsi_len  = input.int(14, "RSI Length", group=grp_rsi)
sma_len  = input.int(14, "RSI SMA Length", group=grp_rsi)
stoch_len= input.int(14, "Stoch Length", group=grp_rsi)
stoch_k  = input.int(3, "Stoch %K", group=grp_rsi)
stoch_d  = input.int(3, "Stoch %D", group=grp_rsi)
rsi_ob   = input.float(70, "Overbought Level (RSI/Stoch)", group=grp_rsi)
rsi_os   = input.float(30, "Oversold Level (RSI/Stoch)", group=grp_rsi)
col_rsi  = input.color(color.new(#e040fb, 0), "RSI / Stoch K Color", group=grp_rsi)
col_sma_rsi = input.color(color.new(color.yellow, 0), "SMA / Stoch D Color", group=grp_rsi)
col_rsi_bg = input.color(color.new(#e040fb, 90), "RSI/Stoch BG Color", group=grp_rsi)

grp_wt = "WaveTrend Settings"
wt_n1    = input.int(10, "WT ESA Len", group=grp_wt)
wt_n2    = input.int(21, "WT TCI Len", group=grp_wt)
wt_sig   = input.int(4, "WT Signal Len", group=grp_wt)
col_wt1  = input.color(color.new(color.white, 0), "WT1 Color", group=grp_wt)
col_wt2  = input.color(color.new(color.yellow, 0), "WT2 Color", group=grp_wt)
col_wt_up= input.color(color.new(color.lime, 0), "WT Mom Up", group=grp_wt)
col_wt_dn= input.color(color.new(color.red, 0), "WT Mom Down", group=grp_wt)

grp_dmi = "DMI Settings"
dmi_len  = input.int(14, "DMI Length", group=grp_dmi)
col_up = input.color(color.new(#089981, 0), "Bullish / DI+ Color", group=grp_dmi)
col_dn = input.color(color.new(#f23645, 0), "Bearish / DI- Color", group=grp_dmi)

grp_colors = "Box Colors"
col_htf   = input.color(color.new(#9598a1, 85), "HTF Box Color", group=grp_colors)
col_asian = input.color(color.new(#089981, 85), "Asian Box Color", group=grp_colors)
col_london= input.color(color.new(#2962ff, 85), "London Box Color", group=grp_colors)
col_ny    = input.color(color.new(#f23645, 85), "New York Box Color", group=grp_colors)

grp_dash = "Dashboard Settings"
show_dash = input.bool(true, "Show Dashboard", group=grp_dash)
dash_pos  = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grp_dash)

// --- Scaling & Globals ---
color adaptive_text_col = chart.fg_color

float global_rsi = ta.rsi(close, rsi_len)
float global_rsi_sma = ta.sma(global_rsi, sma_len)
float global_stoch_k = ta.sma(ta.stoch(global_rsi, global_rsi, global_rsi, stoch_len), stoch_k)
float global_stoch_d = ta.sma(global_stoch_k, stoch_d)
[diplus, diminus, _] = ta.dmi(dmi_len, dmi_len)

// WaveTrend Core
wt_esa  = ta.ema(hlc3, wt_n1)
wt_dev  = ta.ema(math.abs(hlc3 - wt_esa), wt_n1)
wt_ci   = wt_dev != 0 ? (hlc3 - wt_esa) / (0.015 * wt_dev) : 0.0
global_wt1  = ta.ema(wt_ci, wt_n2)
global_wt2  = ta.sma(global_wt1, wt_sig)
global_wt_mom = global_wt1 - global_wt2

// Global MA
float ma_val = na
if ma_type == "SMA"
    ma_val := ta.sma(close, ma_len)
else if ma_type == "EMA"
    ma_val := ta.ema(close, ma_len)
else if ma_type == "WMA"
    ma_val := ta.wma(close, ma_len)
else if ma_type == "RMA"
    ma_val := ta.rma(close, ma_len)

plot(show_ma ? ma_val : na, "Moving Average", color=col_ma, linewidth=ma_width)

float up_size_mult = up_size == "Small" ? 0.25 : up_size == "Large" ? 0.75 : 0.5
float dn_size_mult = dn_size == "Small" ? 0.25 : dn_size == "Large" ? 0.75 : 0.5

half_dur = int((time - nz(time[1], time - 60000)) * 0.4)

// --- UDT ---
type HistoryBox
    box bg_box
    label title_lbl
    line poc_line
    line prev_poc_line
    line prev_hh_line
    line prev_ll_line
    line hh_line
    line ll_line
    label hh_lbl
    label ll_lbl
    label sweep_hh_lbl
    label sweep_ll_lbl
    bool hh_swept
    bool ll_swept
    float hh
    float ll
    int start_bar
    int end_bar
    // Top Engine Drawings
    polyline top_poly1
    polyline top_poly2
    box top_bg_box
    line top_l1
    line top_l2
    line top_l3
    label top_lbl
    box[] top_bars
    // Bottom Engine Drawings
    polyline bot_poly1
    polyline bot_poly2
    box bot_bg_box
    line bot_l1
    line bot_l2
    line bot_l3
    label bot_lbl
    box[] bot_bars
    line[] vwap_lines

type SessionData
    string name
    string sess_str
    color bg_col
    bool in_sess
    bool in_sess_prev
    int start_bar
    float hh
    float ll
    float poc
    float prev_poc
    float prev_hh
    float prev_ll
    float[] prices
    float[] vols
    box bg_box
    label title_lbl
    line poc_line
    line prev_poc_line
    line prev_hh_line
    line prev_ll_line
    // Global Data Trackers
    float[] rsi_vals
    float[] rsi_sma_vals
    float[] stoch_k_vals
    float[] stoch_d_vals
    float[] wt_mom_vals
    float[] wt1_vals
    float[] wt2_vals
    float[] diplus_vals
    float[] diminus_vals
    int[] b_indices
    int[] b_times
    // Top Engine Draw
    polyline top_poly1
    polyline top_poly2
    box top_bg_box
    line top_l1
    line top_l2
    line top_l3
    label top_lbl
    box[] top_bars
    // Bot Engine Draw
    polyline bot_poly1
    polyline bot_poly2
    box bot_bg_box
    line bot_l1
    line bot_l2
    line bot_l3
    label bot_lbl
    box[] bot_bars
    float vwap_sum
    float vol_sum
    float last_vwap_val
    int last_bar_index
    line[] vwap_lines
    HistoryBox[] history

var SessionData[] sessions = array.new<SessionData>()

if barstate.isfirst
    if period_mode == "Timeframe"
        sessions.push(SessionData.new("HTF", "", col_htf, false, false, na, na, na, na, na, na, na, array.new_float(), array.new_float(), na, na, na, na, na, na, array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_int(), array.new_int(), na, na, na, na, na, na, na, array.new_box(), na, na, na, na, na, na, na, array.new_box(), 0.0, 0.0, na, na, array.new_line(), array.new<HistoryBox>()))
    else
        sessions.push(SessionData.new("Asian", asian_time, col_asian, false, false, na, na, na, na, na, na, na, array.new_float(), array.new_float(), na, na, na, na, na, na, array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_int(), array.new_int(), na, na, na, na, na, na, na, array.new_box(), na, na, na, na, na, na, na, array.new_box(), 0.0, 0.0, na, na, array.new_line(), array.new<HistoryBox>()))
        sessions.push(SessionData.new("London", london_time, col_london, false, false, na, na, na, na, na, na, na, array.new_float(), array.new_float(), na, na, na, na, na, na, array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_int(), array.new_int(), na, na, na, na, na, na, na, array.new_box(), na, na, na, na, na, na, na, array.new_box(), 0.0, 0.0, na, na, array.new_line(), array.new<HistoryBox>()))
        sessions.push(SessionData.new("New York", ny_time, col_ny, false, false, na, na, na, na, na, na, na, array.new_float(), array.new_float(), na, na, na, na, na, na, array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_int(), array.new_int(), na, na, na, na, na, na, na, array.new_box(), na, na, na, na, na, na, na, array.new_box(), 0.0, 0.0, na, na, array.new_line(), array.new<HistoryBox>()))

float typ_price = hlc3
string active_session = "None"

for s in sessions
    bool is_new = false
    bool is_end = false
    
    if period_mode == "Timeframe"
        bool tf_changed = timeframe.change(htf)
        if tf_changed
            s.in_sess_prev := s.in_sess
            s.in_sess := false 
            is_new := true
            s.in_sess := true
            is_end := true
        else
            s.in_sess := true
    else
        s.in_sess := not na(time(timeframe.period, s.sess_str, "America/New_York"))
        is_new := s.in_sess and not s.in_sess_prev
        is_end := not s.in_sess and s.in_sess_prev
        
    if s.in_sess
        active_session := s.name
        
    // VWAP
    if is_new
        s.vwap_sum := hlc3 * volume
        s.vol_sum  := volume
        s.last_vwap_val := na
    else if s.in_sess
        s.vwap_sum += hlc3 * volume
        s.vol_sum  += volume
        
    if show_vwap and s.vol_sum > 0 and s.in_sess
        float plot_vwap = s.vwap_sum / s.vol_sum
        float p_vwap = na(s.last_vwap_val) ? plot_vwap : s.last_vwap_val
        line v_line = line.new(bar_index - 1, p_vwap, bar_index, plot_vwap, color=col_vwap, width=vwap_width)
        s.vwap_lines.push(v_line)
        s.last_vwap_val := plot_vwap
        
    // Handle previous active box transition to history
    if is_end and not na(s.hh)
        int end_b = bar_index - 1
        line h_l = line.new(end_b, s.hh, bar_index, s.hh, color=color.new(adaptive_text_col, 50), style=line.style_dashed)
        line l_l = line.new(end_b, s.ll, bar_index, s.ll, color=color.new(adaptive_text_col, 50), style=line.style_dashed)
        label h_lb = label.new(bar_index, s.hh, s.name + " HH", color=color.new(color.white, 100), textcolor=adaptive_text_col, style=label.style_label_left, size=size.small)
        label l_lb = label.new(bar_index, s.ll, s.name + " LL", color=color.new(color.white, 100), textcolor=adaptive_text_col, style=label.style_label_left, size=size.small)
        
        label hist_title = na
        if period_mode == "Sessions"
            hist_title := s.title_lbl
            s.title_lbl := na
        else
            if not na(s.title_lbl)
                label.delete(s.title_lbl)
                s.title_lbl := na
                
        HistoryBox hb = HistoryBox.new(s.bg_box, hist_title, s.poc_line, s.prev_poc_line, s.prev_hh_line, s.prev_ll_line, h_l, l_l, h_lb, l_lb, na, na, false, false, s.hh, s.ll, s.start_bar, end_b, s.top_poly1, s.top_poly2, s.top_bg_box, s.top_l1, s.top_l2, s.top_l3, s.top_lbl, s.top_bars, s.bot_poly1, s.bot_poly2, s.bot_bg_box, s.bot_l1, s.bot_l2, s.bot_l3, s.bot_lbl, s.bot_bars, s.vwap_lines.copy())
        s.history.push(hb)
        
        // Strictly manage history size by deleting everything older than last_n
        int max_hist_items = math.max(0, last_n - 1)
        while s.history.size() > max_hist_items
            HistoryBox old = s.history.shift()
            if not na(old.bg_box)
                box.delete(old.bg_box)
                label.delete(old.title_lbl)
                polyline.delete(old.top_poly1)
                polyline.delete(old.top_poly2)
                box.delete(old.top_bg_box)
                line.delete(old.top_l1)
                line.delete(old.top_l2)
                line.delete(old.top_l3)
                label.delete(old.top_lbl)
                if old.top_bars.size() > 0
                    for b in old.top_bars
                        box.delete(b)
                polyline.delete(old.bot_poly1)
                polyline.delete(old.bot_poly2)
                box.delete(old.bot_bg_box)
                line.delete(old.bot_l1)
                line.delete(old.bot_l2)
                line.delete(old.bot_l3)
                label.delete(old.bot_lbl)
                if old.bot_bars.size() > 0
                    for b in old.bot_bars
                        box.delete(b)
                        
            line.delete(old.poc_line)
            line.delete(old.prev_poc_line)
            line.delete(old.prev_hh_line)
            line.delete(old.prev_ll_line)
            line.delete(old.hh_line)
            line.delete(old.ll_line)
            label.delete(old.hh_lbl)
            label.delete(old.ll_lbl)
            label.delete(old.sweep_hh_lbl)
            label.delete(old.sweep_ll_lbl)
            if old.vwap_lines.size() > 0
                for v_line in old.vwap_lines
                    line.delete(v_line)
            
        // Detach references
        s.bg_box := na
        s.title_lbl := na
        s.poc_line := na
        s.prev_poc_line := na
        s.prev_hh_line := na
        s.prev_ll_line := na
        s.top_poly1 := na
        s.top_poly2 := na
        s.top_bg_box := na
        s.top_l1 := na
        s.top_l2 := na
        s.top_l3 := na
        s.top_lbl := na
        s.top_bars := array.new_box()
        s.bot_poly1 := na
        s.bot_poly2 := na
        s.bot_bg_box := na
        s.bot_l1 := na
        s.bot_l2 := na
        s.bot_l3 := na
        s.bot_lbl := na
        s.bot_bars := array.new_box()
        
        // Save POC, HH, LL for next session
        if period_mode == "Timeframe"
            s.prev_poc := s.poc
            s.prev_hh  := s.hh
            s.prev_ll  := s.ll
        else
            s.prev_poc := na
            s.prev_hh  := na
            s.prev_ll  := na
    
    // Start of Session
    if is_new
        s.start_bar := bar_index
        s.hh := high
        s.ll := low
        s.poc := typ_price
        s.prices.clear()
        s.vols.clear()
        
        s.rsi_vals.clear()
        s.rsi_sma_vals.clear()
        s.stoch_k_vals.clear()
        s.stoch_d_vals.clear()
        s.wt_mom_vals.clear()
        s.wt1_vals.clear()
        s.wt2_vals.clear()
        s.diplus_vals.clear()
        s.diminus_vals.clear()
        s.b_indices.clear()
        s.b_times.clear()
        s.last_bar_index := na
        
        s.bg_box := box.new(bar_index, s.hh, bar_index, s.ll, border_color=color.new(adaptive_text_col, 80), border_width=1, bgcolor=s.bg_col)
        
        string t_txt = period_mode == "Timeframe" ? htf : s.name
        s.title_lbl := label.new(bar_index, s.hh, t_txt, color=color.new(color.white, 100), textcolor=adaptive_text_col, style=label.style_label_down, size=size.small)
        s.poc_line := line.new(bar_index, s.poc, bar_index, s.poc, color=color.orange, style=line.style_solid, width=2)
        
        if not na(s.prev_poc)
            s.prev_poc_line := line.new(bar_index, s.prev_poc, bar_index, s.prev_poc, color=color.orange, style=line.style_dotted, width=3)
        if not na(s.prev_hh)
            s.prev_hh_line := line.new(bar_index, s.prev_hh, bar_index, s.prev_hh, color=color.new(adaptive_text_col, 50), style=line.style_dashed, width=1)
        if not na(s.prev_ll)
            s.prev_ll_line := line.new(bar_index, s.prev_ll, bar_index, s.prev_ll, color=color.new(adaptive_text_col, 50), style=line.style_dashed, width=1)
        
    // During Session
    if s.in_sess
        s.hh := math.max(s.hh, high)
        s.ll := math.min(s.ll, low)
        
        s.prices.push(typ_price)
        s.vols.push(volume)
        
        if s.prices.size() > 0
            float min_p = s.prices.min()
            float max_p = s.prices.max()
            float step = math.max((max_p - min_p) / vp_bins, syminfo.mintick)
            
            float[] bin_vol = array.new_float(vp_bins + 1, 0)
            for i = 0 to s.prices.size() - 1
                float p = s.prices.get(i)
                float v = s.vols.get(i)
                int bin_idx = math.floor((p - min_p) / step)
                bin_idx := math.min(bin_idx, vp_bins)
                bin_vol.set(bin_idx, bin_vol.get(bin_idx) + v)
                
            float max_v = 0.0
            int poc_idx = 0
            for i = 0 to vp_bins
                if bin_vol.get(i) > max_v
                    max_v := bin_vol.get(i)
                    poc_idx := i
                    
            s.poc := min_p + (poc_idx * step)
            
        box.set_top(s.bg_box, s.hh)
        box.set_bottom(s.bg_box, s.ll)
        box.set_right(s.bg_box, bar_index)
        
        int center_x = math.round((s.start_bar + bar_index) / 2)
        label.set_x(s.title_lbl, center_x)
        label.set_y(s.title_lbl, s.hh) 
        
        line.set_y1(s.poc_line, s.poc)
        line.set_y2(s.poc_line, s.poc)
        line.set_x2(s.poc_line, bar_index)
        
        if not na(s.prev_poc_line)
            line.set_x2(s.prev_poc_line, bar_index)
        if not na(s.prev_hh_line)
            line.set_x2(s.prev_hh_line, bar_index)
        if not na(s.prev_ll_line)
            line.set_x2(s.prev_ll_line, bar_index)
        
        if na(s.last_bar_index) or s.last_bar_index < bar_index
            s.rsi_vals.push(global_rsi)
            s.rsi_sma_vals.push(global_rsi_sma)
            s.stoch_k_vals.push(global_stoch_k)
            s.stoch_d_vals.push(global_stoch_d)
            s.wt_mom_vals.push(global_wt_mom)
            s.wt1_vals.push(global_wt1)
            s.wt2_vals.push(global_wt2)
            s.diplus_vals.push(diplus)
            s.diminus_vals.push(diminus)
            s.b_indices.push(bar_index)
            s.b_times.push(time)
            
            if up_engine == "WaveTrend"
                s.top_bars.push(box.new(na, na, na, na, xloc=xloc.bar_time))
                if s.top_bars.size() > 150
                    box.delete(s.top_bars.shift())
            if dn_engine == "WaveTrend"
                s.bot_bars.push(box.new(na, na, na, na, xloc=xloc.bar_time))
                if s.bot_bars.size() > 150
                    box.delete(s.bot_bars.shift())
                    
            s.last_bar_index := bar_index
        else
            if s.rsi_vals.size() > 0
                s.rsi_vals.set(s.rsi_vals.size() - 1, global_rsi)
                s.rsi_sma_vals.set(s.rsi_sma_vals.size() - 1, global_rsi_sma)
                s.stoch_k_vals.set(s.stoch_k_vals.size() - 1, global_stoch_k)
                s.stoch_d_vals.set(s.stoch_d_vals.size() - 1, global_stoch_d)
                s.wt_mom_vals.set(s.wt_mom_vals.size() - 1, global_wt_mom)
                s.wt1_vals.set(s.wt1_vals.size() - 1, global_wt1)
                s.wt2_vals.set(s.wt2_vals.size() - 1, global_wt2)
                s.diplus_vals.set(s.diplus_vals.size() - 1, diplus)
                s.diminus_vals.set(s.diminus_vals.size() - 1, diminus)
                
        float boxHeight = s.hh - s.ll
        
        // ==========================================
        // Render Top Engine
        // ==========================================
        if s.rsi_vals.size() > 1 and up_engine != "None"
            float pad = boxHeight * proj_offset
            float proj_h = math.max(boxHeight * up_size_mult, syminfo.mintick * 10)
            float base_y = s.hh + pad
            float mid_y = base_y + proj_h * 0.5
            
            if up_engine == "RSI" or up_engine == "Stoch RSI"
                float top_y = base_y + proj_h * (rsi_ob / 100.0)
                float bot_y = base_y + proj_h * (rsi_os / 100.0)
                float my = base_y + proj_h * (50.0 / 100.0)
                
                if na(s.top_bg_box)
                    s.top_bg_box := box.new(bar_index, top_y, bar_index, bot_y, border_color=na, bgcolor=col_rsi_bg)
                    s.top_l1 := line.new(bar_index, top_y, bar_index, top_y, color=color.new(adaptive_text_col, 50), style=line.style_dashed)
                    s.top_l2 := line.new(bar_index, bot_y, bar_index, bot_y, color=color.new(adaptive_text_col, 50), style=line.style_dashed)
                    s.top_l3 := line.new(bar_index, my, bar_index, my, color=color.new(adaptive_text_col, 80), style=line.style_solid, width=1)
                    s.top_lbl:= label.new(bar_index, my, "", color=color.new(color.white, 100), textcolor=col_rsi, style=label.style_label_left, size=size.small)
                else
                    box.set_top(s.top_bg_box, top_y)
                    box.set_bottom(s.top_bg_box, bot_y)
                    box.set_right(s.top_bg_box, bar_index)
                    line.set_y1(s.top_l1, top_y)
                    line.set_y2(s.top_l1, top_y)
                    line.set_x2(s.top_l1, bar_index)
                    line.set_y1(s.top_l2, bot_y)
                    line.set_y2(s.top_l2, bot_y)
                    line.set_x2(s.top_l2, bar_index)
                    line.set_y1(s.top_l3, my)
                    line.set_y2(s.top_l3, my)
                    line.set_x2(s.top_l3, bar_index)
                    
                array<chart.point> pts1 = array.new<chart.point>()
                array<chart.point> pts2 = array.new<chart.point>()
                for j = 0 to s.rsi_vals.size() - 1
                    float v1 = up_engine == "RSI" ? s.rsi_vals.get(j) : s.stoch_k_vals.get(j)
                    float v2 = up_engine == "RSI" ? s.rsi_sma_vals.get(j) : s.stoch_d_vals.get(j)
                    int b_idx = s.b_indices.get(j)
                    pts1.push(chart.point.from_index(b_idx, base_y + proj_h * (v1 / 100.0)))
                    pts2.push(chart.point.from_index(b_idx, base_y + proj_h * (v2 / 100.0)))
                
                if not na(s.top_poly1)
                    polyline.delete(s.top_poly1)
                if not na(s.top_poly2)
                    polyline.delete(s.top_poly2)
                s.top_poly1 := polyline.new(points=pts1, line_color=col_rsi, line_width=2)
                s.top_poly2 := polyline.new(points=pts2, line_color=col_sma_rsi, line_width=2)
                
                float l_v = up_engine == "RSI" ? s.rsi_vals.last() : s.stoch_k_vals.last()
                label.set_xy(s.top_lbl, bar_index, base_y + proj_h * (l_v / 100.0))
                label.set_text(s.top_lbl, up_engine + ": " + str.tostring(l_v, "#.##"))
                
            else if up_engine == "WaveTrend"
                float wt_scale = proj_h / 200.0
                if na(s.top_l3)
                    s.top_l3 := line.new(bar_index, mid_y, bar_index, mid_y, color=color.new(adaptive_text_col, 80), style=line.style_solid, width=1)
                    s.top_l1 := line.new(bar_index, mid_y + 60.0 * wt_scale, bar_index, mid_y + 60.0 * wt_scale, color=color.new(color.red, 70), style=line.style_dashed)
                    s.top_l2 := line.new(bar_index, mid_y - 60.0 * wt_scale, bar_index, mid_y - 60.0 * wt_scale, color=color.new(color.lime, 70), style=line.style_dashed)
                    s.top_lbl:= label.new(bar_index, mid_y, "", color=color.new(color.white, 100), textcolor=adaptive_text_col, style=label.style_label_left, size=size.small)
                else
                    line.set_y1(s.top_l3, mid_y)
                    line.set_y2(s.top_l3, mid_y)
                    line.set_x2(s.top_l3, bar_index)
                    line.set_y1(s.top_l1, mid_y + 60.0 * wt_scale)
                    line.set_y2(s.top_l1, mid_y + 60.0 * wt_scale)
                    line.set_x2(s.top_l1, bar_index)
                    line.set_y1(s.top_l2, mid_y - 60.0 * wt_scale)
                    line.set_y2(s.top_l2, mid_y - 60.0 * wt_scale)
                    line.set_x2(s.top_l2, bar_index)
                    
                array<chart.point> pts1 = array.new<chart.point>()
                array<chart.point> pts2 = array.new<chart.point>()
                for j = 0 to s.wt_mom_vals.size() - 1
                    if j < s.top_bars.size()
                        float m_val = s.wt_mom_vals.get(j)
                        int b_time = s.b_times.get(j)
                        box b = s.top_bars.get(j)
                        float m_y = mid_y + (m_val * wt_scale)
                        
                        color c = color.lime
                        if m_val >= 0
                            c := (j > 0 and m_val > s.wt_mom_vals.get(j-1)) ? col_wt_up : color.new(col_wt_up, 40)
                        else
                            c := (j > 0 and m_val < s.wt_mom_vals.get(j-1)) ? col_wt_dn : color.new(col_wt_dn, 40)
                            
                        box.set_top(b, math.max(m_y, mid_y))
                        box.set_bottom(b, math.min(m_y, mid_y))
                        box.set_left(b, b_time - half_dur)
                        box.set_right(b, b_time + half_dur)
                        box.set_bgcolor(b, c)
                        box.set_border_color(b, na)
                        
                    pts1.push(chart.point.from_index(s.b_indices.get(j), mid_y + (s.wt1_vals.get(j) * wt_scale)))
                    pts2.push(chart.point.from_index(s.b_indices.get(j), mid_y + (s.wt2_vals.get(j) * wt_scale)))
                    
                if not na(s.top_poly1)
                    polyline.delete(s.top_poly1)
                if not na(s.top_poly2)
                    polyline.delete(s.top_poly2)
                s.top_poly1 := polyline.new(points=pts1, line_color=col_wt1, line_width=1)
                s.top_poly2 := polyline.new(points=pts2, line_color=col_wt2, line_width=1)
                label.set_xy(s.top_lbl, bar_index, mid_y + (s.wt_mom_vals.last() * wt_scale))
                label.set_text(s.top_lbl, "WT: " + str.tostring(s.wt_mom_vals.last(), "#.##"))
                
            else if up_engine == "DMI"
                if na(s.top_l3)
                    s.top_l3 := line.new(bar_index, base_y, bar_index, base_y, color=na)
                    s.top_lbl:= label.new(bar_index, base_y, "", color=color.new(color.white, 100), textcolor=col_up, style=label.style_label_left, size=size.small)
                
                array<chart.point> pts1 = array.new<chart.point>()
                array<chart.point> pts2 = array.new<chart.point>()
                for j = 0 to s.diplus_vals.size() - 1
                    pts1.push(chart.point.from_index(s.b_indices.get(j), base_y + proj_h * (s.diplus_vals.get(j) / 100.0)))
                    pts2.push(chart.point.from_index(s.b_indices.get(j), base_y + proj_h * (s.diminus_vals.get(j) / 100.0)))
                
                if not na(s.top_poly1)
                    polyline.delete(s.top_poly1)
                if not na(s.top_poly2)
                    polyline.delete(s.top_poly2)
                s.top_poly1 := polyline.new(points=pts1, line_color=col_up, line_width=2)
                s.top_poly2 := polyline.new(points=pts2, line_color=col_dn, line_width=2)
                
                label.set_xy(s.top_lbl, bar_index, base_y + proj_h * (s.diplus_vals.last() / 100.0))
                label.set_text(s.top_lbl, "DI+: " + str.tostring(s.diplus_vals.last(), "#.##"))
                
        // ==========================================
        // Render Bottom Engine
        // ==========================================
        if s.rsi_vals.size() > 1 and dn_engine != "None"
            float pad = boxHeight * proj_offset
            float proj_h = math.max(boxHeight * dn_size_mult, syminfo.mintick * 10)
            float base_y = s.ll - pad - proj_h
            float mid_y = base_y + proj_h * 0.5
            
            if dn_engine == "RSI" or dn_engine == "Stoch RSI"
                float top_y = base_y + proj_h * (rsi_ob / 100.0)
                float bot_y = base_y + proj_h * (rsi_os / 100.0)
                float my = base_y + proj_h * (50.0 / 100.0)
                
                if na(s.bot_bg_box)
                    s.bot_bg_box := box.new(bar_index, top_y, bar_index, bot_y, border_color=na, bgcolor=col_rsi_bg)
                    s.bot_l1 := line.new(bar_index, top_y, bar_index, top_y, color=color.new(adaptive_text_col, 50), style=line.style_dashed)
                    s.bot_l2 := line.new(bar_index, bot_y, bar_index, bot_y, color=color.new(adaptive_text_col, 50), style=line.style_dashed)
                    s.bot_l3 := line.new(bar_index, my, bar_index, my, color=color.new(adaptive_text_col, 80), style=line.style_solid, width=1)
                    s.bot_lbl:= label.new(bar_index, my, "", color=color.new(color.white, 100), textcolor=col_rsi, style=label.style_label_left, size=size.small)
                else
                    box.set_top(s.bot_bg_box, top_y)
                    box.set_bottom(s.bot_bg_box, bot_y)
                    box.set_right(s.bot_bg_box, bar_index)
                    line.set_y1(s.bot_l1, top_y)
                    line.set_y2(s.bot_l1, top_y)
                    line.set_x2(s.bot_l1, bar_index)
                    line.set_y1(s.bot_l2, bot_y)
                    line.set_y2(s.bot_l2, bot_y)
                    line.set_x2(s.bot_l2, bar_index)
                    line.set_y1(s.bot_l3, my)
                    line.set_y2(s.bot_l3, my)
                    line.set_x2(s.bot_l3, bar_index)
                    
                array<chart.point> pts1 = array.new<chart.point>()
                array<chart.point> pts2 = array.new<chart.point>()
                for j = 0 to s.rsi_vals.size() - 1
                    float v1 = dn_engine == "RSI" ? s.rsi_vals.get(j) : s.stoch_k_vals.get(j)
                    float v2 = dn_engine == "RSI" ? s.rsi_sma_vals.get(j) : s.stoch_d_vals.get(j)
                    int b_idx = s.b_indices.get(j)
                    pts1.push(chart.point.from_index(b_idx, base_y + proj_h * (v1 / 100.0)))
                    pts2.push(chart.point.from_index(b_idx, base_y + proj_h * (v2 / 100.0)))
                
                if not na(s.bot_poly1)
                    polyline.delete(s.bot_poly1)
                if not na(s.bot_poly2)
                    polyline.delete(s.bot_poly2)
                s.bot_poly1 := polyline.new(points=pts1, line_color=col_rsi, line_width=2)
                s.bot_poly2 := polyline.new(points=pts2, line_color=col_sma_rsi, line_width=2)
                
                float l_v = dn_engine == "RSI" ? s.rsi_vals.last() : s.stoch_k_vals.last()
                label.set_xy(s.bot_lbl, bar_index, base_y + proj_h * (l_v / 100.0))
                label.set_text(s.bot_lbl, dn_engine + ": " + str.tostring(l_v, "#.##"))
                
            else if dn_engine == "WaveTrend"
                float wt_scale = proj_h / 200.0
                if na(s.bot_l3)
                    s.bot_l3 := line.new(bar_index, mid_y, bar_index, mid_y, color=color.new(adaptive_text_col, 80), style=line.style_solid, width=1)
                    s.bot_l1 := line.new(bar_index, mid_y + 60.0 * wt_scale, bar_index, mid_y + 60.0 * wt_scale, color=color.new(color.red, 70), style=line.style_dashed)
                    s.bot_l2 := line.new(bar_index, mid_y - 60.0 * wt_scale, bar_index, mid_y - 60.0 * wt_scale, color=color.new(color.lime, 70), style=line.style_dashed)
                    s.bot_lbl:= label.new(bar_index, mid_y, "", color=color.new(color.white, 100), textcolor=adaptive_text_col, style=label.style_label_left, size=size.small)
                else
                    line.set_y1(s.bot_l3, mid_y)
                    line.set_y2(s.bot_l3, mid_y)
                    line.set_x2(s.bot_l3, bar_index)
                    line.set_y1(s.bot_l1, mid_y + 60.0 * wt_scale)
                    line.set_y2(s.bot_l1, mid_y + 60.0 * wt_scale)
                    line.set_x2(s.bot_l1, bar_index)
                    line.set_y1(s.bot_l2, mid_y - 60.0 * wt_scale)
                    line.set_y2(s.bot_l2, mid_y - 60.0 * wt_scale)
                    line.set_x2(s.bot_l2, bar_index)
                    
                array<chart.point> pts1 = array.new<chart.point>()
                array<chart.point> pts2 = array.new<chart.point>()
                for j = 0 to s.wt_mom_vals.size() - 1
                    if j < s.bot_bars.size()
                        float m_val = s.wt_mom_vals.get(j)
                        int b_time = s.b_times.get(j)
                        box b = s.bot_bars.get(j)
                        float m_y = mid_y + (m_val * wt_scale)
                        
                        color c = color.lime
                        if m_val >= 0
                            c := (j > 0 and m_val > s.wt_mom_vals.get(j-1)) ? col_wt_up : color.new(col_wt_up, 40)
                        else
                            c := (j > 0 and m_val < s.wt_mom_vals.get(j-1)) ? col_wt_dn : color.new(col_wt_dn, 40)
                            
                        box.set_top(b, math.max(m_y, mid_y))
                        box.set_bottom(b, math.min(m_y, mid_y))
                        box.set_left(b, b_time - half_dur)
                        box.set_right(b, b_time + half_dur)
                        box.set_bgcolor(b, c)
                        box.set_border_color(b, na)
                        
                    pts1.push(chart.point.from_index(s.b_indices.get(j), mid_y + (s.wt1_vals.get(j) * wt_scale)))
                    pts2.push(chart.point.from_index(s.b_indices.get(j), mid_y + (s.wt2_vals.get(j) * wt_scale)))
                    
                if not na(s.bot_poly1)
                    polyline.delete(s.bot_poly1)
                if not na(s.bot_poly2)
                    polyline.delete(s.bot_poly2)
                s.bot_poly1 := polyline.new(points=pts1, line_color=col_wt1, line_width=1)
                s.bot_poly2 := polyline.new(points=pts2, line_color=col_wt2, line_width=1)
                label.set_xy(s.bot_lbl, bar_index, mid_y + (s.wt_mom_vals.last() * wt_scale))
                label.set_text(s.bot_lbl, "WT: " + str.tostring(s.wt_mom_vals.last(), "#.##"))
                
            else if dn_engine == "DMI"
                if na(s.bot_l3)
                    s.bot_l3 := line.new(bar_index, base_y, bar_index, base_y, color=na)
                    s.bot_lbl:= label.new(bar_index, base_y, "", color=color.new(color.white, 100), textcolor=col_up, style=label.style_label_left, size=size.small)
                
                array<chart.point> pts1 = array.new<chart.point>()
                array<chart.point> pts2 = array.new<chart.point>()
                for j = 0 to s.diplus_vals.size() - 1
                    pts1.push(chart.point.from_index(s.b_indices.get(j), base_y + proj_h * (s.diplus_vals.get(j) / 100.0)))
                    pts2.push(chart.point.from_index(s.b_indices.get(j), base_y + proj_h * (s.diminus_vals.get(j) / 100.0)))
                
                if not na(s.bot_poly1)
                    polyline.delete(s.bot_poly1)
                if not na(s.bot_poly2)
                    polyline.delete(s.bot_poly2)
                s.bot_poly1 := polyline.new(points=pts1, line_color=col_up, line_width=2)
                s.bot_poly2 := polyline.new(points=pts2, line_color=col_dn, line_width=2)
                
                label.set_xy(s.bot_lbl, bar_index, base_y + proj_h * (s.diplus_vals.last() / 100.0))
                label.set_text(s.bot_lbl, "DI+: " + str.tostring(s.diplus_vals.last(), "#.##"))
            
    // --- Manage Historical Boxes & Sweeps ---
    if s.history.size() > 0
        for i = 0 to s.history.size() - 1
            HistoryBox hb = s.history.get(i)
            
            if not hb.hh_swept and high > hb.hh
                hb.hh_swept := true
                label.set_text(hb.hh_lbl, s.name + " HH Swept")
                label.set_textcolor(hb.hh_lbl, color.red)
                line.set_color(hb.hh_line, color.red)
                int cx = math.round((hb.start_bar + hb.end_bar) / 2)
                hb.sweep_hh_lbl := label.new(cx, hb.hh, "X", color=color.new(color.white, 100), textcolor=color.red, style=label.style_label_down, size=size.normal)
                
            if not hb.ll_swept and low < hb.ll
                hb.ll_swept := true
                label.set_text(hb.ll_lbl, s.name + " LL Swept")
                label.set_textcolor(hb.ll_lbl, color.red)
                line.set_color(hb.ll_line, color.red)
                int cx = math.round((hb.start_bar + hb.end_bar) / 2)
                hb.sweep_ll_lbl := label.new(cx, hb.ll, "X", color=color.new(color.white, 100), textcolor=color.red, style=label.style_label_up, size=size.normal)
                
            if not hb.hh_swept
                line.set_x2(hb.hh_line, bar_index)
                label.set_x(hb.hh_lbl, bar_index)
                
            if not hb.ll_swept
                line.set_x2(hb.ll_line, bar_index)
                label.set_x(hb.ll_lbl, bar_index)
            
    s.in_sess_prev := s.in_sess


// --- Dashboard Calculations ---
var float cvd = 0.0
if timeframe.change("D")
    cvd := 0.0
cvd += (close > open ? volume : close < open ? -volume : 0.0)

[daily_open, weekly_open] = request.security(syminfo.tickerid, "1D", [open, open[1]], lookahead=barmerge.lookahead_on) // Using 1D to get daily open
daily_o = request.security(syminfo.tickerid, "D", open)
weekly_o = request.security(syminfo.tickerid, "W", open)

string d_bias = close > daily_o ? "Bullish" : "Bearish"
color d_col = close > daily_o ? col_up : col_dn

string w_bias = close > weekly_o ? "Bullish" : "Bearish"
color w_col = close > weekly_o ? col_up : col_dn

string dash_active_session = "None"
if not na(time(timeframe.period, asian_time, "America/New_York"))
    dash_active_session := "Asian"
if not na(time(timeframe.period, london_time, "America/New_York"))
    dash_active_session := "London"
if not na(time(timeframe.period, ny_time, "America/New_York"))
    dash_active_session := "New York"

if show_dash and barstate.islast
    var table dash = table.new(dash_pos == "Top Right" ? position.top_right : dash_pos == "Top Left" ? position.top_left : dash_pos == "Bottom Right" ? position.bottom_right : position.bottom_left, 2, 7, border_width = 1, border_color = color.new(adaptive_text_col, 80), frame_color = color.new(adaptive_text_col, 80), frame_width = 1, bgcolor = color.new(chart.bg_color, 10))
    
    table.cell(dash, 0, 0, "Active Session", text_color = adaptive_text_col, text_halign = text.align_left)
    table.cell(dash, 1, 0, dash_active_session, text_color = adaptive_text_col, text_halign = text.align_right)
    
    table.cell(dash, 0, 1, "Daily Bias", text_color = adaptive_text_col, text_halign = text.align_left)
    table.cell(dash, 1, 1, d_bias, text_color = d_col, text_halign = text.align_right)
    
    table.cell(dash, 0, 2, "Weekly Bias", text_color = adaptive_text_col, text_halign = text.align_left)
    table.cell(dash, 1, 2, w_bias, text_color = w_col, text_halign = text.align_right)
    
    table.cell(dash, 0, 3, "RSI", text_color = adaptive_text_col, text_halign = text.align_left)
    table.cell(dash, 1, 3, str.tostring(global_rsi, "#.##"), text_color = adaptive_text_col, text_halign = text.align_right)
    
    table.cell(dash, 0, 4, "Momentum (WT)", text_color = adaptive_text_col, text_halign = text.align_left)
    table.cell(dash, 1, 4, str.tostring(global_wt_mom, "#.##"), text_color = global_wt_mom > 0 ? col_up : col_dn, text_halign = text.align_right)
    
    table.cell(dash, 0, 5, "Daily CVD", text_color = adaptive_text_col, text_halign = text.align_left)
    table.cell(dash, 1, 5, str.tostring(cvd, format.volume), text_color = cvd > 0 ? col_up : col_dn, text_halign = text.align_right)
    
    table.cell(dash, 0, 6, "DI+ / DI-", text_color = adaptive_text_col, text_halign = text.align_left)
    table.cell(dash, 1, 6, str.tostring(diplus, "#.#") + " / " + str.tostring(diminus, "#.#"), text_color = adaptive_text_col, text_halign = text.align_right)

plot(na)
````

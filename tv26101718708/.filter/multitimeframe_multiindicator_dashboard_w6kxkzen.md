# Multi-TimeFrame Multi-Indicator Dashboard

- url: https://www.tradingview.com/script/W6KxkZen-Multi-TimeFrame-Multi-Indicator-Dashboard/
- type: indicator
- pine_id: PUB;a18e985b5d194e57bb96da5b8dc1ee98
- version: 1.0

## Description

🚀 Multi-Timeframe Multi-Indicator Market Structure Dashboard

🟢 Overview

The **Multi-Timeframe Multi-Indicator Dashboard** is an all-in-one market scanner designed to give traders an immediate, high-level view of an asset's trend across multiple layers of time. Instead of constantly flipping between charts or cluttering your workspace with dozens of indicators, this script compiles key moving averages, momentum oscillators, and volatility indicators into a single, highly readable table directly on your primary workspace.

This tool is optimized for **Equities, Forex, Crypto, Indices, and Commodities traders** who rely on multi-timeframe confluence to confirm high-probability trade setups and eliminate analysis paralysis.

---

🛠️ Key Features

**Multi-Timeframe Confluence Matrix:** Instantly track market structure across 6 default timeframes: **5M, 15M, 1H, Daily, Weekly, and Monthly**.
**8 Integrated Technical Metrics:**
**Trend Identification:** SMA 9, SMA 20, SMA 50, SMA 100, and SMA 200.
**Momentum & Volatility:** Relative Strength Index (RSI 50-line crossover), MACD Histogram (bullish/bearish momentum shifts), and SuperTrend.


**Fully Customizable Layout:** Toggle specific timeframes or indicators on/off via the user inputs menu to perfectly match your trading style. You can also change the table position (e.g., top-right, bottom-left) and text size.
**Smart Alert Engine:** Configure the script to send real-time alerts the exact moment an indicator shifts states (Bullish $\leftrightarrow$ Bearish) on your primary timeframes.

---
🎛️ Settings & Customization

1. **Dashboard Display:** Control the visibility, positioning anchor (top-right, bottom-right, top-left, bottom-left, middle-right, middle-left), and text scaling of the canvas table.
2. **Timeframes to Display:** Toggle individual columns to focus strictly on scalping or macro swing horizons.
3. **Indicators to Display:** Strip out unnecessary lines to match your personal strategy components.
4. **SuperTrend Settings:** Manually adjust the ATR Length and Multiplier inputs for tighter or wider trend bands.

---

📝 Disclaimer

This indicator is built purely for analytical visualization and informational purposes. It does not constitute financial advice. Always practice strict risk management and combine dashboard confirmation with your own broader trading plan.

## Source Code

````pine
//@version=6
indicator("Multi-TF Multi-Indicator Dashboard", overlay=true, max_labels_count=500, max_boxes_count=500)

// ==========================================
// CONSTANTS & DEFINITIONS
// ==========================================
var string BULL = "Bullish"
var string BEAR = "Bearish"
var string FLAT = "Flat"

var color COLOR_BULL = color.new(color.green, 20)
var color COLOR_BEAR = color.new(color.red, 20)
var color COLOR_FLAT = color.new(color.gray, 20)

// ==========================================
// INPUTS
// ==========================================
show_dash   = input.bool(true, "Show Dashboard", group="Dashboard Display")
dash_pos    = input.string("top_right", "Position", options=["top_right", "bottom_right", "top_left", "bottom_left", "center_right", "center_left"], group="Dashboard Display")
text_size   = input.string("small", "Text Size", options=["tiny", "small", "normal", "large"], group="Dashboard Display")

tf_5m_en    = input.bool(true, "Enable 5 Min", group="Timeframes to Display")
tf_15m_en   = input.bool(true, "Enable 15 Min", group="Timeframes to Display")
tf_1h_en    = input.bool(true, "Enable 1 Hour", group="Timeframes to Display")
tf_1d_en    = input.bool(true, "Enable 1 Day", group="Timeframes to Display")
tf_1w_en    = input.bool(true, "Enable 1 Week", group="Timeframes to Display")
tf_1m_en    = input.bool(true, "Enable 1 Month", group="Timeframes to Display")

ind_sma9_en = input.bool(true, "Enable SMA 9", group="Indicators to Display")
ind_sma20_en= input.bool(true, "Enable SMA 20", group="Indicators to Display")
ind_sma50_en= input.bool(true, "Enable SMA 50", group="Indicators to Display")
ind_sma100_en=input.bool(true, "Enable SMA 100", group="Indicators to Display")
ind_sma200_en=input.bool(true, "Enable SMA 200", group="Indicators to Display")
ind_rsi_en  = input.bool(true, "Enable RSI", group="Indicators to Display")
ind_macd_en = input.bool(true, "Enable MACD", group="Indicators to Display")
ind_st_en   = input.bool(true, "Enable SuperTrend", group="Indicators to Display")


alert_changes = input.bool(true, "Alert on Bullish/Bearish State Change", group="Alert Configurations")

st_atr_len  = input.int(10, "SuperTrend ATR Length", group="SuperTrend Settings")
st_mult     = input.float(3.0, "SuperTrend Multiplier", group="SuperTrend Settings")

// ==========================================
// INDICATOR LOGIC FUNCTION
// ==========================================
f_calc_states() =>
    c = close
    
    s9  = ta.sma(c, 9)
    s20 = ta.sma(c, 20)
    s50 = ta.sma(c, 50)
    s100= ta.sma(c, 100)
    s200= ta.sma(c, 200)
    
    state_sma9   = c > s9 ? BULL : BEAR
    state_sma20  = c > s20 ? BULL : BEAR
    state_sma50  = c > s50 ? BULL : BEAR
    state_sma100 = c > s100 ? BULL : BEAR
    state_sma200 = c > s200 ? BULL : BEAR
    
    r = ta.rsi(c, 14)
    state_rsi = r > 50 ? BULL : r < 50 ? BEAR : FLAT
    
    [macdLine, signalLine, histLine] = ta.macd(c, 12, 26, 9)
    state_macd = histLine > 0 ? BULL : histLine < 0 ? BEAR : FLAT
    
    [st_val, st_dir] = ta.supertrend(st_mult, st_atr_len)
    state_st = st_dir == -1 ? BULL : BEAR
    
    

    [state_sma9, state_sma20, state_sma50, state_sma100, state_sma200, state_rsi, state_macd, state_st]

// Fetch MTF Data safely using explicit namespace
[tf5_s9, tf5_s20, tf5_s50, tf5_s100, tf5_s200, tf5_rsi, tf5_macd, tf5_st] = request.security(syminfo.tickerid, "5", f_calc_states(), barmerge.gaps_off, barmerge.lookahead_off)
[tf15_s9, tf15_s20, tf15_s50, tf15_s100, tf15_s200, tf15_rsi, tf15_macd, tf15_st] = request.security(syminfo.tickerid, "15", f_calc_states(), barmerge.gaps_off, barmerge.lookahead_off)
[tf60_s9, tf60_s20, tf60_s50, tf60_s100, tf60_s200, tf60_rsi, tf60_macd, tf60_st] = request.security(syminfo.tickerid, "60", f_calc_states(), barmerge.gaps_off, barmerge.lookahead_off)
[tfD_s9, tfD_s20, tfD_s50, tfD_s100, tfD_s200, tfD_rsi, tfD_macd, tfD_st] = request.security(syminfo.tickerid, "1D", f_calc_states(), barmerge.gaps_off, barmerge.lookahead_off)
[tfW_s9, tfW_s20, tfW_s50, tfW_s100, tfW_s200, tfW_rsi, tfW_macd, tfW_st] = request.security(syminfo.tickerid, "1W", f_calc_states(), barmerge.gaps_off, barmerge.lookahead_off)
[tfM_s9, tfM_s20, tfM_s50, tfM_s100, tfM_s200, tfM_rsi, tfM_macd, tfM_st] = request.security(syminfo.tickerid, "1M", f_calc_states(), barmerge.gaps_off, barmerge.lookahead_off)

// ==========================================
// STATE CHANGE & ALERTS LOGIC
// ==========================================
f_check_alert(string current, string previous, string name, string tf) =>
    if alert_changes and (current != previous) and not na(previous)
        if (current == BULL and previous == BEAR) or (current == BEAR and previous == BULL)
            alert("State Change on " + syminfo.ticker + " (" + tf + "): " + name + " shifted to " + current, alert.freq_once_per_bar_close)

if barstate.isconfirmed
    if tf_5m_en
        f_check_alert(tf5_s9, tf5_s9[1], "SMA 9", "5m")
        f_check_alert(tf5_s20, tf5_s20[1], "SMA 20", "5m")
        f_check_alert(tf5_s50, tf5_s50[1], "SMA 50", "5m")
        f_check_alert(tf5_s100, tf5_s100[1], "SMA 100", "5m")
        f_check_alert(tf5_s200, tf5_s200[1], "SMA 200", "5m")
        f_check_alert(tf5_rsi, tf5_rsi[1], "RSI", "5m")
        f_check_alert(tf5_macd, tf5_macd[1], "MACD", "5m")
        f_check_alert(tf5_st, tf5_st[1], "SuperTrend", "5m")
      
    if tf_15m_en
        f_check_alert(tf15_s9, tf15_s9[1], "SMA 9", "15m")
        f_check_alert(tf15_s20, tf15_s20[1], "SMA 20", "15m")
        f_check_alert(tf15_s50, tf15_s50[1], "SMA 50", "15m")
        f_check_alert(tf15_s100, tf15_s100[1], "SMA 100", "15m")
        f_check_alert(tf15_s200, tf15_s200[1], "SMA 200", "15m")
        f_check_alert(tf15_rsi, tf15_rsi[1], "RSI", "15m")
        f_check_alert(tf15_macd, tf15_macd[1], "MACD", "15m")
        f_check_alert(tf15_st, tf15_st[1], "SuperTrend", "15m")
      
    if tf_1h_en
        f_check_alert(tf60_s9, tf60_s9[1], "SMA 9", "1h")
        f_check_alert(tf60_s20, tf60_s20[1], "SMA 20", "1h")
        f_check_alert(tf60_s50, tf60_s50[1], "SMA 50", "1h")
        f_check_alert(tf60_s100, tf60_s100[1], "SMA 100", "1h")
        f_check_alert(tf60_s200, tf60_s200[1], "SMA 200", "1h")
        f_check_alert(tf60_rsi, tf60_rsi[1], "RSI", "1h")
        f_check_alert(tf60_macd, tf60_macd[1], "MACD", "1h")
        f_check_alert(tf60_st, tf60_st[1], "SuperTrend", "1h")
        
    if tf_1d_en
        f_check_alert(tfD_s9, tfD_s9[1], "SMA 9", "1D")
        f_check_alert(tfD_s20, tfD_s20[1], "SMA 20", "1D")
        f_check_alert(tfD_s50, tfD_s50[1], "SMA 50", "1D")
        f_check_alert(tfD_s100, tfD_s100[1], "SMA 100", "1D")
        f_check_alert(tfD_s200, tfD_s200[1], "SMA 200", "1D")
        f_check_alert(tfD_rsi, tfD_rsi[1], "RSI", "1D")
        f_check_alert(tfD_macd, tfD_macd[1], "MACD", "1D")
        f_check_alert(tfD_st, tfD_st[1], "SuperTrend", "1D")
        
    if tf_1w_en
        f_check_alert(tfW_s9, tfW_s9[1], "SMA 9", "1W")
        f_check_alert(tfW_s20, tfW_s20[1], "SMA 20", "1W")
        f_check_alert(tfW_s50, tfW_s50[1], "SMA 50", "1W")
        f_check_alert(tfW_s100, tfW_s100[1], "SMA 100", "1W")
        f_check_alert(tfW_s200, tfW_s200[1], "SMA 200", "1W")
        f_check_alert(tfW_rsi, tfW_rsi[1], "RSI", "1W")
        f_check_alert(tfW_macd, tfW_macd[1], "MACD", "1W")
        f_check_alert(tfW_st, tfW_st[1], "SuperTrend", "1W")
       
    if tf_1m_en
        f_check_alert(tfM_s9, tfM_s9[1], "SMA 9", "1M")
        f_check_alert(tfM_s20, tfM_s20[1], "SMA 20", "1M")
        f_check_alert(tfM_s50, tfM_s50[1], "SMA 50", "1M")
        f_check_alert(tfM_s100, tfM_s100[1], "SMA 100", "1M")
        f_check_alert(tfM_s200, tfM_s200[1], "SMA 200", "1M")
        f_check_alert(tfM_rsi, tfM_rsi[1], "RSI", "1M")
        f_check_alert(tfM_macd, tfM_macd[1], "MACD", "1M")
        f_check_alert(tfM_st, tfM_st[1], "SuperTrend", "1M")
        

// ==========================================
// DASHBOARD GENERATION
// ==========================================
var position = dash_pos == "top_right" ? position.top_right : 
               dash_pos == "bottom_right" ? position.bottom_right : 
               dash_pos == "top_left" ? position.top_left : 
               dash_pos == "bottom_left" ? position.bottom_left : 
               dash_pos == "center_right" ? position.middle_right : position.middle_left

var size = text_size == "tiny" ? size.tiny : 
           text_size == "small" ? size.small : 
           text_size == "normal" ? size.normal : size.large

var table dash = table.new(position, columns=15, rows=15, bgcolor=color.new(color.black, 100), border_color=color.black, border_width=1)

f_get_color(string state) =>
    state == BULL ? COLOR_BULL : state == BEAR ? COLOR_BEAR : COLOR_FLAT

f_draw_row(bool enable, string label, string state5, string state15, string state60, string stateD, string stateW, string stateM, int cur_row) =>
    next_row = cur_row
    if enable
        table.cell(dash, 0, cur_row, label, bgcolor=color.gray, text_color=color.white, text_size=size, text_halign=text.align_center)
        c_idx = 1
        if tf_5m_en
            table.cell(dash, c_idx, cur_row, state5,  bgcolor=f_get_color(state5),  text_color=color.white, text_size=size)
            c_idx := c_idx + 1
        if tf_15m_en
            table.cell(dash, c_idx, cur_row, state15, bgcolor=f_get_color(state15), text_color=color.white, text_size=size)
            c_idx := c_idx + 1
        if tf_1h_en
            table.cell(dash, c_idx, cur_row, state60, bgcolor=f_get_color(state60), text_color=color.white, text_size=size)
            c_idx := c_idx + 1
        if tf_1d_en
            table.cell(dash, c_idx, cur_row, stateD,  bgcolor=f_get_color(stateD),  text_color=color.white, text_size=size)
            c_idx := c_idx + 1
        if tf_1w_en
            table.cell(dash, c_idx, cur_row, stateW,  bgcolor=f_get_color(stateW),  text_color=color.white, text_size=size)
            c_idx := c_idx + 1
        if tf_1m_en
            table.cell(dash, c_idx, cur_row, stateM,  bgcolor=f_get_color(stateM),  text_color=color.white, text_size=size)
            c_idx := c_idx + 1
        next_row := cur_row + 1
    next_row

if show_dash and barstate.islast
    table.clear(dash, 0, 0, 14, 14)
    
    table.cell(dash, 0, 0, "Indicator", bgcolor=color.gray, text_color=color.white, text_size=size)
    
    col_idx = 1
    if tf_5m_en
        table.cell(dash, col_idx, 0, "5 Min", bgcolor=color.gray, text_color=color.white, text_size=size)
        col_idx := col_idx + 1
    if tf_15m_en
        table.cell(dash, col_idx, 0, "15 Min", bgcolor=color.gray, text_color=color.white, text_size=size)
        col_idx := col_idx + 1
    if tf_1h_en
        table.cell(dash, col_idx, 0, "1 Hour", bgcolor=color.gray, text_color=color.white, text_size=size)
        col_idx := col_idx + 1
    if tf_1d_en
        table.cell(dash, col_idx, 0, "1 Day", bgcolor=color.gray, text_color=color.white, text_size=size)
        col_idx := col_idx + 1
    if tf_1w_en
        table.cell(dash, col_idx, 0, "1 Week", bgcolor=color.gray, text_color=color.white, text_size=size)
        col_idx := col_idx + 1
    if tf_1m_en
        table.cell(dash, col_idx, 0, "1 Month", bgcolor=color.gray, text_color=color.white, text_size=size)
        col_idx := col_idx + 1

    row_idx = 1
    row_idx := f_draw_row(ind_sma9_en, "SMA 9", tf5_s9, tf15_s9, tf60_s9, tfD_s9, tfW_s9, tfM_s9, row_idx)
    row_idx := f_draw_row(ind_sma20_en, "SMA 20", tf5_s20, tf15_s20, tf60_s20, tfD_s20, tfW_s20, tfM_s20, row_idx)
    row_idx := f_draw_row(ind_sma50_en, "SMA 50", tf5_s50, tf15_s50, tf60_s50, tfD_s50, tfW_s50, tfM_s50, row_idx)
    row_idx := f_draw_row(ind_sma100_en, "SMA 100", tf5_s100, tf15_s100, tf60_s100, tfD_s100, tfW_s100, tfM_s100, row_idx)
    row_idx := f_draw_row(ind_sma200_en, "SMA 200", tf5_s200, tf15_s200, tf60_s200, tfD_s200, tfW_s200, tfM_s200, row_idx)
    row_idx := f_draw_row(ind_rsi_en, "RSI (50)", tf5_rsi, tf15_rsi, tf60_rsi, tfD_rsi, tfW_rsi, tfM_rsi, row_idx)
    row_idx := f_draw_row(ind_macd_en, "MACD Hist", tf5_macd, tf15_macd, tf60_macd, tfD_macd, tfW_macd, tfM_macd, row_idx)
    row_idx := f_draw_row(ind_st_en, "SuperTrend", tf5_st, tf15_st, tf60_st, tfD_st, tfW_st, tfM_st, row_idx)
````

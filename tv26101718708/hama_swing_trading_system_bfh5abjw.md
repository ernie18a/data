# HAMA Swing Trading System

- url: https://www.tradingview.com/script/bfh5ABjW-HAMA-Swing-Trading-System/
- type: indicator
- pine_id: PUB;c7a24b22fd9444dd8e4cc761383239a2
- version: 1.0

## Description

Heiken Ashi Movig Averages with MACD+ EMA oscillator

## Source Code

````pine
//@version=6
indicator("HAMA Swing Trading System", shorttitle="HAMA", overlay=false)

// --- Groups ---
g_disp = "Display Settings"
g_hama = "HAMA Settings"
g_macd = "MACD Settings"
g_cols = "HAMA Candle Colors"
g_mcol = "MACD Histogram Colors"
g_lcol = "MACD Line Colors"

// --- Inputs ---
show_hama = input.bool(true, "Show HAMA Candles (On Main Chart)", group=g_disp)
show_macd = input.bool(true, "Show MACD Oscillator (In Pane)", group=g_disp)

// HAMA Settings
len = input.int(29, "MA Period", group=g_hama)
ma_method = input.string("WMA", "MA Method", options=["SMA", "EMA", "SMMA", "WMA"], group=g_hama, tooltip="WMA is equivalent to MT4's Linear Weighted Moving Average (MaMethod 3)")
col_up = input.color(#87CEFA, "Bullish Color", group=g_cols)
col_dn = input.color(#FF69B4, "Bearish Color", group=g_cols)

// MACD Settings
fast_len = input.int(10, "Fast EMA", group=g_macd)
slow_len = input.int(20, "Slow EMA", group=g_macd)
sig_len = input.int(1, "Signal EMA", group=g_macd)
ma_sig_len = input.int(7, "MA of Signal", group=g_macd)

col_up_grow = input.color(#32CD32, "MACD > 0 (Growing)", group=g_mcol) // LimeGreen
col_up_fall = input.color(#006400, "MACD > 0 (Falling)", group=g_mcol) // DarkGreen
col_dn_grow = input.color(#800000, "MACD < 0 (Growing)", group=g_mcol) // Maroon
col_dn_fall = input.color(#FF0000, "MACD < 0 (Falling)", group=g_mcol) // Red

col_sig = input.color(#FF00FF, "Signal Line", group=g_lcol) // Magenta
col_ma_sig = input.color(#FFFF00, "MA of Signal", group=g_lcol) // Yellow

// --- HAMA Calculations ---
f_get_ma(float src, int length, string method) =>
    float res = na
    if method == "SMA"
        res := ta.sma(src, length)
    else if method == "EMA"
        res := ta.ema(src, length)
    else if method == "WMA"
        res := ta.wma(src, length)
    else if method == "SMMA"
        res := ta.rma(src, length)
    res

float ma_open = f_get_ma(open, len, ma_method)
float ma_high = f_get_ma(high, len, ma_method)
float ma_low = f_get_ma(low, len, ma_method)
float ma_close = f_get_ma(close, len, ma_method)

var float ha_open = na
var float ha_close = na

float raw_ha_close = (ma_open + ma_high + ma_low + ma_close) / 4.0

if na(ha_open[1])
    ha_open := ma_open
    ha_close := raw_ha_close
else
    ha_open := nz((ha_open[1] + ha_close[1]) / 2.0)
    ha_close := raw_ha_close

float ha_high = math.max(ma_high, math.max(ha_open, ha_close))
float ha_low = math.min(ma_low, math.min(ha_open, ha_close))

color bcol = ha_close >= ha_open ? col_up : col_dn

// Plot HAMA Candles on Main Chart (forced overlay)
plotcandle(show_hama ? ha_open : na, show_hama ? ha_high : na, show_hama ? ha_low : na, show_hama ? ha_close : na, 
           title="HAMA Candles", 
           color=bcol, 
           wickcolor=bcol, 
           bordercolor=bcol, 
           force_overlay=true)

// --- MACD Calculations (In Pane) ---
float macd = ta.ema(close, fast_len) - ta.ema(close, slow_len)
float signal = ta.ema(macd, sig_len)
float ma_of_signal = ta.ema(signal, ma_sig_len)

color hist_col = macd > 0 ? (macd > nz(macd[1]) ? col_up_grow : col_up_fall) : (macd < nz(macd[1]) ? col_dn_grow : col_dn_fall)

// Custom Candle-Based Histogram for Pane
float hist_open  = show_macd ? 0.0 : na
float hist_high  = show_macd ? math.max(0.0, macd) : na
float hist_low   = show_macd ? math.min(0.0, macd) : na
float hist_close = show_macd ? macd : na

plotcandle(hist_open, hist_high, hist_low, hist_close, 
           title="MACD Histogram", 
           color=hist_col, 
           wickcolor=color.new(color.white, 100), 
           bordercolor=hist_col)

// Plot Lines in Pane
plot(show_macd ? signal : na, "Signal Line", color=col_sig, style=plot.style_line, linewidth=2)
plot(show_macd ? ma_of_signal : na, "MA of Signal", color=col_ma_sig, style=plot.style_circles, linewidth=2)
plot(show_macd ? 0.0 : na, "Zero Line", color=color.gray, style=plot.style_line, linewidth=1)
````

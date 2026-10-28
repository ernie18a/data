# Moving Range Breakout [Dynamic Box]

- url: https://www.tradingview.com/script/G06Csm4X-Moving-Range-Breakout-Dynamic-Box/
- type: indicator
- pine_id: PUB;9f0f529c55594bd087bac1524d7cfdd3
- version: 1.0

## Description

Title: Moving Range Breakout [Dynamic Box]
Description
The Moving Range Breakout is a clean, visual-first momentum indicator designed to identify and highlight price breakouts from a defined lookback period. Unlike traditional "channel" indicators that clutter the chart with historical lines, this script uses a dynamic, self-adjusting box that focuses exclusively on the most recent price action.

This indicator is perfect for traders who utilize Opening Range Breakouts (ORB), Volatility Contraction Patterns (VCP), or simple Box Trading strategies.

How It Works
The script calculates the highest high and lowest low of a user-defined number of previous bars (the "Lookback Period").

The Box: It draws a transparent geometric box encompassing only those lookback bars.

The Offset: The calculation specifically uses [1] (the previous bar) to ensure the box boundaries are fixed while the current "live" bar is forming. This prevents the range from "moving the goalposts" mid-candle.

The Logic:

BUY Signal: Triggered when the current bar closes above the High of the box.

SELL Signal: Triggered when the current bar closes below the Low of the box.

Auto-Cleanup: To maintain a "Zero-Clutter" chart, the script is programmed to only show the most recent Buy and Sell labels. As soon as a new breakout occurs, the previous label is removed.

Key Features
Timeframe Adaptive: Works on any timeframe (1m, 5m, 1h, Daily).

Customizable Lookback: No hard limits; set it to 5 bars for scalping or 50 bars for swing trading.

Persistent Labels: Uses label.set_xy logic to ensure only one signal of each type exists on the chart at any time, keeping your workspace clean.

Unified Alerts: Includes a built-in alertcondition that allows you to monitor both Buy and Sell signals using a single TradingView alert slot.

How to Use
Setting the Range: Use the "Lookback Period" in the settings to define your consolidation zone. (e.g., set to 20 to trade the breakout of the last 20 bars).

Confirming the Breakout: The signal is plotted on Bar Close. Entering a trade before the bar closes may result in a "fakeout" where price wicks out and returns to the box.

Setting Alerts:

Click Create Alert.

Select this script as the Condition.

Select "Any Breakout Alert".

Choose "Once Per Bar Close".

Settings
Lookback Period: Number of bars to include in the high/low calculation.

Box Fill Color: Adjust the transparency of the range highlight.

Border Color: Adjust the color of the range boundaries.

Disclaimer
Breakout trading involves risk, especially in low-volume or sideways markets ("choppy" price action). It is recommended to use this indicator in conjunction with volume analysis or higher-timeframe trend filters.

## Source Code

````pine
//@version=5
indicator("MT4 MACD + Customizable MTF Dashboard", overlay=false, precision=4)

// ==========================================
// --- MACD INPUTS ---
// ==========================================
group_macd  = "MACD Settings"
fast_len    = input.int(12, "Fast EMA", group=group_macd)
slow_len    = input.int(26, "Slow EMA", group=group_macd)
signal_len  = input.int(9, "Signal SMA", group=group_macd)
src         = input.source(close, "Source", group=group_macd)

// ==========================================
// --- DASHBOARD SETTINGS ---
// ==========================================
group_dash  = "Dashboard Display"
show_dash   = input.bool(true, "Show MTF Dashboard", group=group_dash)
dash_pos    = input.string("top_right", "Location", options=["top_right", "top_left", "bottom_right", "bottom_left"], group=group_dash)
txt_size    = input.string("small", "Text Size", options=["tiny", "small", "normal", "large"], group=group_dash)

group_tf    = "Timeframe Selection"
tf_1        = input.timeframe("30", "Timeframe 1", group=group_tf)
tf_2        = input.timeframe("60", "Timeframe 2", group=group_tf)
tf_3        = input.timeframe("240", "Timeframe 3", group=group_tf)
tf_4        = input.timeframe("D", "Timeframe 4", group=group_tf)

// ==========================================
// --- CALCULATIONS & MTF LOGIC ---
// ==========================================
// Function to get Bullish (1) or Bearish (-1) state
get_state(tf) =>
    m = request.security(syminfo.tickerid, tf, ta.ema(src, fast_len) - ta.ema(src, slow_len))
    s = request.security(syminfo.tickerid, tf, ta.sma(ta.ema(src, fast_len) - ta.ema(src, slow_len), signal_len))
    m > s ? 1 : -1

// Fetching User-Selected Timeframes
s_1 = get_state(tf_1)
s_2 = get_state(tf_2)
s_3 = get_state(tf_3)
s_4 = get_state(tf_4)

// Main Chart MACD (Current Timeframe)
macd_line   = ta.ema(src, fast_len) - ta.ema(src, slow_len)
signal_line = ta.sma(macd_line, signal_len)

// 4-Color Momentum Logic
hist_color  = macd_line >= 0 ? 
             (macd_line > macd_line[1] ? color.green : color.rgb(56, 142, 60)) : 
             (macd_line < macd_line[1] ? color.red   : color.rgb(183, 28, 28))

// ==========================================
// --- PLOTTING ---
// ==========================================
plot(macd_line, title="MACD Histogram", style=plot.style_columns, color=hist_color)
plot(signal_line, title="Signal Line", color=color.red, linewidth=1)
hline(0, "Zero Line", color=color.new(color.gray, 50), linestyle=hline.style_dotted)

bull_c = ta.crossover(macd_line, signal_line)
bear_c = ta.crossunder(macd_line, signal_line)

plotshape(bull_c, title="Buy Label", style=shape.triangleup, location=location.bottom, color=color.green, size=size.small, text="BUY")
plotshape(bear_c, title="Sell Label", style=shape.triangledown, location=location.top, color=color.red, size=size.small, text="SELL")

// ==========================================
// --- DASHBOARD TABLE ---
// ==========================================
pos_val = dash_pos == "top_right" ? position.top_right : dash_pos == "top_left" ? position.top_left : dash_pos == "bottom_right" ? position.bottom_right : position.bottom_left
t_size  = txt_size == "tiny" ? size.tiny : txt_size == "small" ? size.small : txt_size == "normal" ? size.normal : size.large

var table mtf_dash = table.new(pos_val, 2, 5, border_width=1, border_color=color.new(color.gray, 70))

fill_mtf(row, label, state) =>
    bg_col = state == 1 ? color.new(color.green, 30) : color.new(color.red, 30)
    table.cell(mtf_dash, 0, row, label, bgcolor=color.new(color.black, 40), text_color=color.white, text_size=t_size)
    table.cell(mtf_dash, 1, row, state == 1 ? "BULL" : "BEAR", bgcolor=bg_col, text_color=color.white, text_size=t_size)

if show_dash and barstate.islast
    table.cell(mtf_dash, 0, 0, "TF", bgcolor=color.new(color.gray, 20), text_color=color.white, text_size=t_size)
    table.cell(mtf_dash, 1, 0, "TREND", bgcolor=color.new(color.gray, 20), text_color=color.white, text_size=t_size)
    
    fill_mtf(1, tf_1, s_1)
    fill_mtf(2, tf_2, s_2)
    fill_mtf(3, tf_3, s_3)
    fill_mtf(4, tf_4, s_4)

// ==========================================
// --- ALERTS ---
// ==========================================
alertcondition(bull_c, "MACD Buy Signal", "MT4 MACD Bullish Cross on {{ticker}}")
alertcondition(bear_c, "MACD Sell Signal", "MT4 MACD Bearish Cross on {{ticker}}")
````

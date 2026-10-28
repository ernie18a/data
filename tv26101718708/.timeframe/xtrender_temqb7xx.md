# X-trender

- url: https://www.tradingview.com/script/temqB7XX/
- type: indicator
- pine_id: PUB;9f1e76bdcfbd46869cf489006dcc5807
- version: 7.0

## Description

This script is designed to identify the market trend, its momentum, and potential reversal points by combining Arnaud Legoux Moving Averages (ALMA) and the Relative Strength Index (RSI).
The indicator is plotted in a separate pane below the price chart (overlay=false).
Here is a detailed breakdown of how the script works:

1. Core Logic (The Calculation)

The indicator filters out market noise by combining two powerful tools:
- ALMA (Arnaud Legoux Moving Average): An advanced moving average that reduces lag while maintaining superior smoothness. The script allows you to choose your preferred price source (e.g., Close, HLC3, OHLC4).
- RSI (Relative Strength Index): Instead of applying RSI directly to raw prices, the script calculates the RSI of the smoothed ALMA values and subtracts 50. This centers the indicator around a zero (0) baseline:
x - Values above 0 signal a bullish (upward) trend.
x - Values below 0 signal a bearish (downward) trend.

2. Dual Time Horizons (Short vs. Long)

The indicator analyzes the market from two perspectives simultaneously, creating two overlapping histograms:
- ShortTermXtrender: Calculates the RSI based on the difference between two fast ALMA lines. This captures rapid, local changes in price momentum.
- LongTermXtrender: Calculates the RSI directly from a single long ALMA line. This tracks the more stable, macro market trend.

3. Visual Signals and Charting

- Histogram Colors: Bright green/dark green represents upward momentum, while bright red/dark red represents downward momentum. The color brightens when the move accelerates and darkens when it slows down.
- Signal Line: A further smoothed ALMA of the short-term indicator. It turns bright green when moving up and red when moving down.
- Reversal Dots (Tiny Circles): Plotted at the exact pivot points of the signal line. A green dot marks a local bottom (potential buy signal), and a red dot marks a local peak (potential sell signal).
- Fixed Levels: Horizontal lines at 30 / -30 and 40 / -40 help identify overbought and oversold conditions.

4. Dynamic ATR Bands

When enabled, orange bands are drawn around the short-term indicator based on market volatility (Average True Range). These work similarly to Bollinger Bands. When the histogram breaks outside these bands, it signals an extreme market condition and a high probability of a price correction.

5. Multi-Timeframe (MTF) Dashboard

The script features an MTF dashboard that creates a clean table in the corner of your chart. It fetches the long-term trend data from multiple higher timeframes (e.g., 15m, 1h, 4h, 1D) at the same time:
- Displays BULL (green) if the long-term trend on that timeframe is positive.
- Displays BEAR (red) if the trend on that timeframe is negative.This allows you to quickly check the "higher timeframe bias" without switching charts.

## Source Code

````pine
//@version=6
indicator("X-trender", overlay=false)

// INPUTS
group_src   = "1. Source Settings"
src_type    = input.string("Custom", "Source Price Type", options = ["Close", "HL2", "HLC3", "OHLC4", "OCC3", "HLCC4", "Custom"], group = group_src)
group_alma  = "2. ALMA Length Settings"
short_l1    = input.int(9, title="Short ALMA 1 Length", minval=1, group=group_alma)
short_l2    = input.int(22, title="Short ALMA 2 Length", minval=1, group=group_alma)
long_l1     = input.int(22, title="Long ALMA Length", minval=1, group=group_alma)
group_rsi   = "3. RSI Length Settings"
short_l3    = input.int(9, title="Short RSI Length", minval=1, group=group_rsi)
long_l2     = input.int(22, title="Long RSI Length", minval=1, group=group_rsi)
group_alma_params = "4. ALMA Advanced Parameters"
alma_offset = input.float(0.75, title="ALMA Offset", minval=0.0, maxval=1.0, step=0.0025, group=group_alma_params)
alma_sigma  = input.float(3.0, title="ALMA Sigma", minval=0.0, step=0.025, group=group_alma_params)
group_atr   = "5. Dynamic ATR Bands (ALMA Powered)"
use_atr     = input.bool(true, "Enable Dynamic ALMA-ATR", group=group_atr)
atr_len     = input.int(14, "ATR Length", minval=1, group=group_atr)
atr_mult    = input.float(1.5, "ATR Multiplier", minval=0.1, step=0.1, group=group_atr)

group_mtf   = "6. MTF Dashboard Settings"
show_dash   = input.bool(true, "Show MTF Dashboard", group=group_mtf)
dash_pos    = input.string("Top Right", "Dashboard Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=group_mtf)

show_1m     = input.bool(true,  "1 Min Timeframe", group=group_mtf)
show_3m     = input.bool(true,  "3 Min Timeframe", group=group_mtf)
show_5m     = input.bool(false, "5 Min Timeframe", group=group_mtf)
show_10m    = input.bool(true,  "10 Min Timeframe", group=group_mtf)
show_15m    = input.bool(false, "15 Min Timeframe", group=group_mtf)
show_30m    = input.bool(true,  "30 Min Timeframe", group=group_mtf)
show_1h     = input.bool(false, "1 H Timeframe", group=group_mtf)
show_2h     = input.bool(true,  "2 H Timeframe", group=group_mtf)
show_4h     = input.bool(false, "4 H Timeframe", group=group_mtf)
show_1d     = input.bool(false, "1 D Timeframe", group=group_mtf)
show_1w     = input.bool(false, "1 W Timeframe", group=group_mtf)
show_1mn    = input.bool(false, "1 M Timeframe", group=group_mtf)

group_colors = "7. Dashboard Colors"
table_border_col    = input.color(color.gray, "Table Border Color", group=group_colors)
table_text_col      = input.color(color.white, "Table Text Color", group=group_colors)
headers_and_time_bg = input.color(color.new(color.gray, 50), "Headers & Time Position BG Color", group=group_colors)
bull_bg_col         = input.color(color.new(color.green, 30), "BULL Trend BG Color", group=group_colors)
bear_bg_col         = input.color(color.new(color.red, 30), "BEAR Trend BG Color", group=group_colors)

// SOURCE
src = switch src_type
    "Close"  => close
    "HL2"    => (high + low) / 2
    "HLC3"   => (high + low + close) / 3
    "OHLC4"  => (open + high + low + close) / 4
    "HLCC4"  => (high + low + 2 * close) / 4
    "OCC3"   => (open + 2 * close) / 3
    => (open + 2 * high + 2 * low + 2 * close) / 7

// CALCULATING
short_alma1         = ta.alma(src, short_l1, alma_offset, alma_sigma)
short_alma2         = ta.alma(src, short_l2, alma_offset, alma_sigma)
shortTermXtrender   = ta.rsi(short_alma1 - short_alma2, short_l3) - 50
maShortTermXtrender = ta.alma(shortTermXtrender, 5, alma_offset, alma_sigma)
long_alma1          = ta.alma(src, long_l1, alma_offset, alma_sigma)
longTermXtrender    = ta.rsi(long_alma1, long_l2) - 50

st_prev  = shortTermXtrender[1]
lt_prev  = longTermXtrender[1]
ma_prev1 = maShortTermXtrender[1]
ma_prev2 = maShortTermXtrender[2]

atr_basis   = ta.alma(shortTermXtrender, atr_len, alma_offset, alma_sigma)
atr_value   = ta.alma(math.abs(shortTermXtrender - shortTermXtrender[1]), atr_len, alma_offset, alma_sigma)
atr_upper   = atr_basis + (atr_value * atr_mult)
atr_lower   = atr_basis - (atr_value * atr_mult)

// DRAWING CHART ELEMENTS
hline(30,  color=color.new(color.green, 70),  linestyle=hline.style_solid, title="Overbought High")
hline(20,  color=color.new(color.yellow, 70), linestyle=hline.style_dashed, title="Signal Overbought")
hline(0,   color=color.new(color.white, 70),  linestyle=hline.style_dashed, title="Zero Center Line")
hline(-20, color=color.new(color.yellow, 70), linestyle=hline.style_dashed, title="Signal Oversold")
hline(-30, color=color.new(color.green, 70),  linestyle=hline.style_solid, title="Oversold Low")

p_upper = plot(use_atr ? atr_upper : na, color=color.new(color.orange, 40), style=plot.style_line, linewidth=1, title="ATR Overbought Band")
p_lower = plot(use_atr ? atr_lower : na, color=color.new(color.orange, 40), style=plot.style_line, linewidth=1, title="ATR Oversold Band")
fill(p_upper, p_lower, color=color.new(color.gray, 93), title="Channel Background")

short_hist_color = shortTermXtrender > 0 ? (shortTermXtrender > st_prev ? color.new(color.lime, 50) : color.new(#228B22, 50)) : 
                                           (shortTermXtrender > st_prev ? color.new(color.red, 50)  : color.new(#8B0000, 50))
plot(shortTermXtrender, color=short_hist_color, style=plot.style_columns, title="Short Histogram (Momentum)")

is_line_up = maShortTermXtrender > ma_prev1
plot(maShortTermXtrender, color=color.new(color.black, 15), style=plot.style_line, linewidth=5, title="Signal Line: Shadow")
plot(maShortTermXtrender, color=is_line_up ? color.lime : color.red, style=plot.style_line, linewidth=3, title="Signal Line")

shape_up = (maShortTermXtrender > ma_prev1 and ma_prev1 < ma_prev2) ? maShortTermXtrender : na
shape_dn = (maShortTermXtrender < ma_prev1 and ma_prev1 > ma_prev2) ? maShortTermXtrender : na
plotshape(shape_up, location=location.absolute, style=shape.circle, color=color.new(color.lime, 10), size=size.tiny, title="Dot: Pivot Up")
plotshape(shape_dn, location=location.absolute, style=shape.circle, color=color.new(color.red, 10), size=size.tiny, title="Dot: Pivot Down")

is_trend_up = longTermXtrender > lt_prev
plot(longTermXtrender, color=color.new(color.black, 40), style=plot.style_line, linewidth=6, title="Trend Line: Shadow")
plot(longTermXtrender, color=is_trend_up ? color.new(#00ced1, 20) : color.new(#da70d6, 20), style=plot.style_line, linewidth=4, title="Main Trend Line")

// MTF DASHBOARD
lt_1m   = request.security(syminfo.tickerid, "1",   longTermXtrender)
lt_3m   = request.security(syminfo.tickerid, "3",   longTermXtrender)
lt_5m   = request.security(syminfo.tickerid, "5",   longTermXtrender)
lt_10m  = request.security(syminfo.tickerid, "10",  longTermXtrender)
lt_15m  = request.security(syminfo.tickerid, "15",  longTermXtrender)
lt_30m  = request.security(syminfo.tickerid, "30",  longTermXtrender)
lt_1h   = request.security(syminfo.tickerid, "60",  longTermXtrender)
lt_2h   = request.security(syminfo.tickerid, "120", longTermXtrender)
lt_4h   = request.security(syminfo.tickerid, "240", longTermXtrender)
lt_1d   = request.security(syminfo.tickerid, "D",   longTermXtrender)
lt_1w   = request.security(syminfo.tickerid, "W",   longTermXtrender)
lt_1mn  = request.security(syminfo.tickerid, "M",   longTermXtrender)

// MTF DASHBOARD - DRAWING
table_pos = switch dash_pos
    "Top Right"    => position.top_right
    "Bottom Right" => position.bottom_right
    "Top Left"     => position.top_left
    => position.bottom_left

draw_row(t, row_idx, label, val, bg_label_color, text_color, b_bg, s_bg) =>
    table.cell(t, 0, row_idx, label, text_color=text_color, text_size=size.small, bgcolor=bg_label_color)
    table.cell(t, 1, row_idx, val > 0 ? "BULL" : "BEAR", bgcolor = val > 0 ? b_bg : s_bg, text_color=text_color, text_size=size.small)

if barstate.islast and show_dash
    int max_rows = 1
    if show_1m
        max_rows := max_rows + 1
    if show_3m
        max_rows := max_rows + 1
    if show_5m
        max_rows := max_rows + 1
    if show_10m
        max_rows := max_rows + 1
    if show_15m
        max_rows := max_rows + 1
    if show_30m
        max_rows := max_rows + 1
    if show_1h
        max_rows := max_rows + 1
    if show_2h
        max_rows := max_rows + 1
    if show_4h
        max_rows := max_rows + 1
    if show_1d
        max_rows := max_rows + 1
    if show_1w
        max_rows := max_rows + 1
    if show_1mn
        max_rows := max_rows + 1

    mtfTable = table.new(position = table_pos, columns = 2, rows = max_rows, bgcolor = color.new(color.black, 20), border_width = 1, border_color = table_border_col)
    int current_row = 0
    table.cell(mtfTable, 0, current_row, "Timeframe", text_color=table_text_col, text_size=size.small, bgcolor=headers_and_time_bg)
    table.cell(mtfTable, 1, current_row, "Trend",     text_color=table_text_col, text_size=size.small, bgcolor=headers_and_time_bg)
    current_row := current_row + 1
   
    if show_1m
        draw_row(mtfTable, current_row, "1 min", lt_1m, headers_and_time_bg, table_text_col, bull_bg_col, bear_bg_col)
        current_row := current_row + 1
    if show_3m
        draw_row(mtfTable, current_row, "3 min", lt_3m, headers_and_time_bg, table_text_col, bull_bg_col, bear_bg_col)
        current_row := current_row + 1
    if show_5m
        draw_row(mtfTable, current_row, "5 min", lt_5m, headers_and_time_bg, table_text_col, bull_bg_col, bear_bg_col)
        current_row := current_row + 1
    if show_10m
        draw_row(mtfTable, current_row, "10 min", lt_10m, headers_and_time_bg, table_text_col, bull_bg_col, bear_bg_col)
        current_row := current_row + 1
    if show_15m
        draw_row(mtfTable, current_row, "15 min", lt_15m, headers_and_time_bg, table_text_col, bull_bg_col, bear_bg_col)
        current_row := current_row + 1
    if show_30m
        draw_row(mtfTable, current_row, "30 min", lt_30m, headers_and_time_bg, table_text_col, bull_bg_col, bear_bg_col)
        current_row := current_row + 1
    if show_1h
        draw_row(mtfTable, current_row, "1 H", lt_1h, headers_and_time_bg, table_text_col, bull_bg_col, bear_bg_col)
        current_row := current_row + 1
    if show_2h
        draw_row(mtfTable, current_row, "2 H", lt_2h, headers_and_time_bg, table_text_col, bull_bg_col, bear_bg_col)
        current_row := current_row + 1
    if show_4h
        draw_row(mtfTable, current_row, "4 H", lt_4h, headers_and_time_bg, table_text_col, bull_bg_col, bear_bg_col)
        current_row := current_row + 1
    if show_1d
        draw_row(mtfTable, current_row, "1 D", lt_1d, headers_and_time_bg, table_text_col, bull_bg_col, bear_bg_col)
        current_row := current_row + 1
    if show_1w
        draw_row(mtfTable, current_row, "1 W", lt_1w, headers_and_time_bg, table_text_col, bull_bg_col, bear_bg_col)
        current_row := current_row + 1
    if show_1mn
        draw_row(mtfTable, current_row, "1 M", lt_1mn, headers_and_time_bg, table_text_col, bull_bg_col, bear_bg_col)
        current_row := current_row + 1
````

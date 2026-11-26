# EMA Ribbon + FVG + Key Levels

- url: https://www.tradingview.com/script/fxTvt8SF-EMA-Ribbon-FVG-Key-Levels/
- type: indicator
- pine_id: PUB;e8d0f4d216a243d7b7b2728abc81c791
- version: 1.0

## Description

13 ema 48 ema 200 ema Lsma 
also key levels
could not get the Fvgs to work on this so I just turn them off.
(use as a tool in your trading)

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Custom Indicator: EMA Ribbon + FVG + Key Levels

//@version=6
indicator(title = 'EMA Ribbon + FVG + Key Levels', shorttitle = 'EMA+FVG+Levels', overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 200)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────

// EMA Settings
ema13_len = input.int(13, 'EMA 13 Length', group = 'EMAs')
ema48_len = input.int(48, 'EMA 48 Length', group = 'EMAs')
ema200_len = input.int(200, 'EMA 200 Length', group = 'EMAs')
lsma_len = input.int(100, 'LSMA Length', group = 'EMAs')

ema13_col = input.color(color.new(#00E5FF, 0), 'EMA 13 Color', group = 'EMAs')
ema48_col = input.color(color.new(#FF9800, 0), 'EMA 48 Color', group = 'EMAs')
ema200_col = input.color(color.new(#F44336, 0), 'EMA 200 Color', group = 'EMAs')
lsma_col = input.color(color.new(#E040FB, 0), 'LSMA Color', group = 'EMAs')

// Fair Value Gaps
show_fvg = input.bool(true, 'Show Fair Value Gaps', group = 'Fair Value Gaps')
fvg_bull_col = input.color(color.new(#00E676, 75), 'Bullish FVG Color', group = 'Fair Value Gaps')
fvg_bear_col = input.color(color.new(#FF5252, 75), 'Bearish FVG Color', group = 'Fair Value Gaps')
fvg_bull_border = input.color(color.new(#00E676, 0), 'Bullish FVG Border', group = 'Fair Value Gaps')
fvg_bear_border = input.color(color.new(#FF5252, 0), 'Bearish FVG Border', group = 'Fair Value Gaps')
fvg_max_bars = input.int(50, 'FVG Lookback (bars)', minval = 5, maxval = 500, group = 'Fair Value Gaps')
fvg_extend = input.bool(true, 'Extend FVG Until Mitigated', group = 'Fair Value Gaps')

// Key Levels
show_daily_high = input.bool(true, 'Daily High', group = 'Key Levels')
show_daily_low = input.bool(true, 'Daily Low', group = 'Key Levels')
show_prev_d_low = input.bool(true, 'Previous Daily Low', group = 'Key Levels')
show_4h_high = input.bool(true, '4H High', group = 'Key Levels')
show_4h_low = input.bool(true, '4H Low', group = 'Key Levels')
show_pm_high = input.bool(true, 'Premarket High', group = 'Key Levels')
show_pm_low = input.bool(true, 'Premarket Low', group = 'Key Levels')

col_daily_high = input.color(color.new(#00E676, 0), 'Daily High Color', group = 'Key Levels')
col_daily_low = input.color(color.new(#FF5252, 0), 'Daily Low Color', group = 'Key Levels')
col_prev_d_low = input.color(color.new(#FF9800, 0), 'Prev Daily Low Color', group = 'Key Levels')
col_4h_high = input.color(color.new(#00B0FF, 0), '4H High Color', group = 'Key Levels')
col_4h_low = input.color(color.new(#E040FB, 0), '4H Low Color', group = 'Key Levels')
col_pm_high = input.color(color.new(#FFEB3B, 0), 'Premarket High Color', group = 'Key Levels')
col_pm_low = input.color(color.new(#FF6F00, 0), 'Premarket Low Color', group = 'Key Levels')

line_style_key = input.string('Dashed', 'Key Level Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = 'Key Levels')

// ─────────────────────────────────────────────
// EMAs + LSMA
// ─────────────────────────────────────────────

ema13 = ta.ema(close, ema13_len)
ema48 = ta.ema(close, ema48_len)
ema200 = ta.ema(close, ema200_len)
lsma = ta.linreg(close, lsma_len, 0)

plot(ema13, 'EMA 13', color = ema13_col, linewidth = 1)
plot(ema48, 'EMA 48', color = ema48_col, linewidth = 2)
plot(ema200, 'EMA 200', color = ema200_col, linewidth = 2)
plot(lsma, 'LSMA 100', color = lsma_col, linewidth = 1, style = plot.style_line)
// ─────────────────────────────────────────────
// KEY LEVELS — Helper
// ─────────────────────────────────────────────

f_line_style(s) =>
    s == 'Dashed' ? line.style_dashed : s == 'Dotted' ? line.style_dotted : line.style_solid

kls = f_line_style(line_style_key)

f_level(show, src, col, lbl) =>
    if show and barstate.islast
        ln = line.new(bar_index - 300, src, bar_index + 50, src, color = col, width = 1, style = kls, extend = extend.right)
        label.new(bar_index + 2, src, lbl, color = color.new(col, 85), textcolor = col, style = label.style_label_left, size = size.small)

// ─────────────────────────────────────────────
// DAILY LEVELS
// ─────────────────────────────────────────────

daily_high = request.security(syminfo.tickerid, 'D', high[0], lookahead = barmerge.lookahead_off)
daily_low = request.security(syminfo.tickerid, 'D', low[0], lookahead = barmerge.lookahead_off)
prev_d_low = request.security(syminfo.tickerid, 'D', low[1], lookahead = barmerge.lookahead_off)

f_level(show_daily_high, daily_high, col_daily_high, 'D High')
f_level(show_daily_low, daily_low, col_daily_low, 'D Low')
f_level(show_prev_d_low, prev_d_low, col_prev_d_low, 'Prev D Low')

// ─────────────────────────────────────────────
// 4H LEVELS
// ─────────────────────────────────────────────

h4_high = request.security(syminfo.tickerid, '240', high[0], lookahead = barmerge.lookahead_off)
h4_low = request.security(syminfo.tickerid, '240', low[0], lookahead = barmerge.lookahead_off)

f_level(show_4h_high, h4_high, col_4h_high, '4H High')
f_level(show_4h_low, h4_low, col_4h_low, '4H Low')

// ─────────────────────────────────────────────
// PREMARKET LEVELS
// Pre-market window: 04:00–09:30 ET
// We track the rolling high/low within today's premarket session
// ─────────────────────────────────────────────

// Get session time in exchange timezone
t = time('1', '0400-0930:23456') // Mon–Fri premarket

var float pm_high_val = na
var float pm_low_val = na
var int pm_date = na

is_premarket = not na(t)
today = dayofmonth(timenow)

// Reset at start of new day
if dayofmonth != pm_date and is_premarket
    pm_high_val := high
    pm_low_val := low
    pm_date := dayofmonth
    pm_date

if is_premarket
    pm_high_val := math.max(nz(pm_high_val, high), high)
    pm_low_val := math.min(nz(pm_low_val, low), low)
    pm_low_val

f_level(show_pm_high and not na(pm_high_val), pm_high_val, col_pm_high, 'PM High')
f_level(show_pm_low and not na(pm_low_val), pm_low_val, col_pm_low, 'PM Low')

// ─────────────────────────────────────────────
// LEGEND (table)
// ─────────────────────────────────────────────

var table legend = table.new(position.top_right, 2, 10, bgcolor = color.new(#1A1A2E, 10), border_width = 1, border_color = color.new(color.gray, 60))

if barstate.islast
    table.cell(legend, 0, 0, '●', text_color = ema13_col, text_size = size.small)
    table.cell(legend, 1, 0, 'EMA 13', text_color = color.white, text_size = size.small)
    table.cell(legend, 0, 1, '●', text_color = ema48_col, text_size = size.small)
    table.cell(legend, 1, 1, 'EMA 48', text_color = color.white, text_size = size.small)
    table.cell(legend, 0, 2, '●', text_color = ema200_col, text_size = size.small)
    table.cell(legend, 1, 2, 'EMA 200', text_color = color.white, text_size = size.small)
    table.cell(legend, 0, 3, '●', text_color = lsma_col, text_size = size.small)
    table.cell(legend, 1, 3, 'LSMA 100', text_color = color.white, text_size = size.small)
    table.cell(legend, 0, 4, '■', text_color = fvg_bull_border, text_size = size.small)
    table.cell(legend, 1, 4, 'Bull FVG', text_color = color.white, text_size = size.small)
    table.cell(legend, 0, 5, '■', text_color = fvg_bear_border, text_size = size.small)
    table.cell(legend, 1, 5, 'Bear FVG', text_color = color.white, text_size = size.small)
    table.cell(legend, 0, 6, '─', text_color = col_daily_high, text_size = size.small)
    table.cell(legend, 1, 6, 'D High/Low', text_color = color.white, text_size = size.small)
    table.cell(legend, 0, 7, '─', text_color = col_4h_high, text_size = size.small)
    table.cell(legend, 1, 7, '4H High/Low', text_color = color.white, text_size = size.small)
    table.cell(legend, 0, 8, '─', text_color = col_pm_high, text_size = size.small)
    table.cell(legend, 1, 8, 'PM High/Low', text_color = color.white, text_size = size.small)
    table.cell(legend, 0, 9, '─', text_color = col_prev_d_low, text_size = size.small)
    table.cell(legend, 1, 9, 'Prev D Low', text_color = color.white, text_size = size.small)
````

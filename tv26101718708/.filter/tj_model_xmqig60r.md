# TJ Model

- url: https://www.tradingview.com/script/XmqiG60r-TJ-Model/
- type: indicator
- pine_id: PUB;511418c9e00a45ca80e474f986b433c2
- version: 1.0

## Description

TJ MODEL 
 THIS MODEL GONNA CHANGE YOUR LIFE 
this indicator is based on ice kill zone and tj entry

## Source Code

````pine
//@version=6
indicator('TJ Model', overlay = true, max_lines_count = 500, max_boxes_count = 500)

// --- Color Palette ---
color c_london = color.new(color.red, 94)
color c_8am = color.new(color.black, 92)
color c_ny_window = color.new(color.green, 97)
color c_ifvg = color.new(#2a2e39, 60) // Dark Gray IFVG
color c_cisd = color.new(color.black, 0) // Black CISD

// --- Sessions & Timing (NY Time) ---
string tz = 'America/New_York'
is_london = not na(time(timeframe.period, '0300-0700', tz))
is_8am = not na(time(timeframe.period, '0800-0815', tz))
is_trade_window = not na(time(timeframe.period, '0930-1100', tz))
is_new_day = ta.change(time('D', tz)) != 0

// --- MTF Trend Data (1M & 5M Alignment) ---
[t5m] = request.security(syminfo.tickerid, '5', [close > ta.sma(close, 50)])
trend1m = close > ta.sma(close, 50)

// --- State Variables ---
var float lonH = na
var float lonL = na
var float r8H = na
var float r8L = na
var bool sweep_occurred = false
var bool traded_today = false

if is_new_day
    lonH := na
    lonL := na
    r8H := na
    r8L := na
    sweep_occurred := false
    traded_today := false
    traded_today

// --- Session Boxes (Red London, Black 8AM) ---
var box lonBox = na
var box r8Box = na

if is_london
    lonH := na(lonH) ? high : math.max(high, lonH)
    lonL := na(lonL) ? low : math.min(low, lonL)
    if not is_london[1]
        lonBox := box.new(bar_index, lonH, bar_index, lonL, border_color = color.red, bgcolor = c_london)
        lonBox
    else
        box.set_top(lonBox, lonH)
        box.set_bottom(lonBox, lonL)
        box.set_right(lonBox, bar_index)

if is_8am
    r8H := na(r8H) ? high : math.max(high, r8H)
    r8L := na(r8L) ? low : math.min(low, r8L)
    if not is_8am[1]
        r8Box := box.new(bar_index, r8H, bar_index, r8L, border_color = color.black, bgcolor = c_8am)
        r8Box
    else
        box.set_top(r8Box, r8H)
        box.set_bottom(r8Box, r8L)
        box.set_right(r8Box, bar_index)

// --- Sweep Detection (London or 8AM) ---
if not na(lonH) and (high > lonH or low < lonL)
    sweep_occurred := true
    sweep_occurred
if not na(r8H) and (high > r8H or low < r8L)
    sweep_occurred := true
    sweep_occurred

// --- 1M Entry Logic: CISD & IFVG ---
// CISD: Structural Breakout
cisd_l_lvl = ta.highest(high[1], 3)
cisd_s_lvl = ta.lowest(low[1], 3)
cisd_long = ta.crossover(close, cisd_l_lvl)
cisd_short = ta.crossunder(close, cisd_s_lvl)

// IFVG: Simulation of Gap Inversion
var float f_top = na
var float f_bot = na
if high[1] < low[2] // Bearish FVG
    f_top := low[2]
    f_bot := high[1]
    f_bot
ifvg_ok = not na(f_top) and close > f_top

// --- Final Gated Signal (One Trade Per Day) ---
can_trade = is_trade_window and not traded_today and sweep_occurred

long_signal = can_trade and cisd_long and ifvg_ok and trend1m and t5m
short_signal = can_trade and cisd_short and not trend1m and not t5m

// --- Visual Execution ---
if long_signal
    traded_today := true
    line.new(bar_index - 1, cisd_l_lvl, bar_index + 4, cisd_l_lvl, color = c_cisd, width = 2)
    box.new(bar_index - 2, f_top, bar_index + 3, f_bot, bgcolor = c_ifvg, border_color = color.gray)

if short_signal
    traded_today := true
    line.new(bar_index - 1, cisd_s_lvl, bar_index + 4, cisd_s_lvl, color = c_cisd, width = 2)
    box.new(bar_index - 2, f_top, bar_index + 3, f_bot, bgcolor = c_ifvg, border_color = color.gray)

// --- Visual Outputs ---
bgcolor(is_trade_window ? c_ny_window : na)

plotshape(long_signal, 'TJ LONG', shape.labelup, location.belowbar, color.green, size = size.normal, text = 'TJ LONG', textcolor = color.white)
plotshape(short_signal, 'TJ SHORT', shape.labeldown, location.abovebar, color.red, size = size.normal, text = 'TJ SHORT', textcolor = color.white)

// Target Liquidity Lines
plot(lonH, 'London High', color = color.new(color.red, 70), style = plot.style_stepline)
plot(lonL, 'London Low', color = color.new(color.blue, 70), style = plot.style_stepline)
````

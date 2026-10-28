# Salil1980 BankNifty 5m ORB Breakouts

- url: https://www.tradingview.com/script/RjKx2fu7-Salil1980-BankNifty-5m-ORB-Breakouts/
- type: indicator
- pine_id: PUB;1d387058e85e4679a4e9663e45da4acd
- version: 1.0

## Description

This indicator is a comprehensive technical tool specifically designed for intraday trading on BankNifty. It combines Opening Range Breakout (ORB) mechanics with VWAP and RSI momentum filters to identify high-probability breakout and trend-continuation setups.

Key Features:

5-Minute ORB: Automatically detects and plots the high and low of the first 5 minutes of the trading session.

VWAP & RSI Momentum: Displays clear Buy and Sell signals based on 1-minute VWAP crossovers confirmed by RSI threshold filters.

Dynamic POC Lines: Real-time visual tracking of Daily, 4-hour, and Weekly Points of Control (POC) to help identify key support and resistance levels.

Trend Context: Uses background coloring to provide immediate visual confirmation of the 1-hour trend direction.

Visual Signals: Explicit labels for "BUY", "SELL", and "ORB" breakout events to make your chart actionable at a glance.

How to use:

Designed primarily for the 1-minute time frame.

Use the ORB levels as your primary breakout zones for the day.

Use the Buy/Sell labels as potential trade triggers when confirmed by the trend background.

## Source Code

````pine
//@version=5
indicator("BankNifty Strategy: 5m ORB and Breakouts", overlay=true)

// --- Weekly Pivot Data Request (Global Scope) ---
float w_high  = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
float w_low   = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_on)
float w_close = request.security(syminfo.tickerid, "W", close[1], lookahead=barmerge.lookahead_on)
float weekly_pp = (w_high + w_low + w_close) / 3

// --- 1H Trend Identification ---
rsi_1h = request.security(syminfo.tickerid, "60", ta.rsi(close, 14))
is_bullish = rsi_1h > 50
is_bearish = rsi_1h < 50

// --- 5 Min ORB Logic ---
var float orb_high = na
var float orb_low = na
var bool is_orb_set = false

new_day = ta.change(time("D"))
if new_day
    orb_high := high
    orb_low := low
    is_orb_set := false

if not is_orb_set and time < time("D") + (5 * 60 * 1000)
    orb_high := math.max(high, orb_high)
    orb_low := math.min(low, orb_low)
else
    is_orb_set := true

// Draw ORB Lines (Black)
plot(is_orb_set ? orb_high : na, color=color.black, style=plot.style_linebr, linewidth=2, title="ORB High")
plot(is_orb_set ? orb_low : na, color=color.black, style=plot.style_linebr, linewidth=2, title="ORB Low")

// --- Weekly Pivot Line (Purple Bold) ---
var line weekly_pivot_line = na
if new_day
    line.delete(weekly_pivot_line)
    weekly_pivot_line := line.new(x1=bar_index, y1=weekly_pp, x2=bar_index + 1, y2=weekly_pp, color=color.purple, width=3)
else
    line.set_x2(weekly_pivot_line, bar_index)

// --- Hourly Updating POC Lines ---
float poc_4h = request.security(syminfo.tickerid, "240", ta.vwap(hlc3))
float poc_d  = request.security(syminfo.tickerid, "D", ta.vwap(hlc3))
float poc_w  = request.security(syminfo.tickerid, "W", ta.vwap(hlc3))

var line l_4h = na, var line l_d = na, var line l_w = na
var label lbl_4h = na, var label lbl_d = na, var label lbl_w = na

if ta.change(time("60"))
    line.delete(l_4h), line.delete(l_d), line.delete(l_w)
    label.delete(lbl_4h), label.delete(lbl_d), label.delete(lbl_w)
    
    l_4h := line.new(bar_index - 50, poc_4h, bar_index, poc_4h, color=color.black, width=3)
    lbl_4h := label.new(bar_index, poc_4h, "4hr POC", color=color.new(color.black, 100), textcolor=color.black, style=label.style_none, size=size.normal)
    
    l_d := line.new(bar_index - 50, poc_d, bar_index, poc_d, color=color.orange, width=3)
    lbl_d := label.new(bar_index, poc_d, "D POC", color=color.new(color.black, 100), textcolor=color.orange, style=label.style_none, size=size.normal)
    
    l_w := line.new(bar_index - 50, poc_w, bar_index, poc_w, color=color.red, width=3)
    lbl_w := label.new(bar_index, poc_w, "W POC", color=color.new(color.black, 100), textcolor=color.red, style=label.style_none, size=size.normal)
else
    line.set_x2(l_4h, bar_index), line.set_x2(l_d, bar_index), line.set_x2(l_w, bar_index)
    label.set_x(lbl_4h, bar_index), label.set_x(lbl_d, bar_index), label.set_x(lbl_w, bar_index)

// --- Events Detection ---
bool is_breakout_up = is_orb_set and ta.crossover(close, orb_high)
bool is_breakout_down = is_orb_set and ta.crossunder(close, orb_low)
bool is_breakout_event = is_breakout_up or is_breakout_down

// 1 Minute VWAP/RSI
vwap_1m = request.security(syminfo.tickerid, "1", ta.vwap(hlc3))
rsi_1m = request.security(syminfo.tickerid, "1", ta.rsi(close, 14))

bool cross_up = (ta.crossover(close, vwap_1m) and rsi_1m > 50) or (ta.crossover(rsi_1m, 50) and close > vwap_1m)
bool cross_down = ta.crossunder(close, vwap_1m) and rsi_1m < 50

// --- Coloring ---
color candle_color = is_breakout_event ? color.purple : cross_up ? color.new(color.blue, 0) : cross_down ? color.new(#FFD700, 0) : na
barcolor(candle_color)

// --- Signals ---
plotshape(cross_up, title="Buy Signal", location=location.belowbar, color=color.blue, style=shape.labelup, text="BUY", textcolor=color.white, size=size.tiny)
plotshape(cross_down, title="Sell Signal", location=location.abovebar, color=color.yellow, style=shape.labeldown, text="SELL", textcolor=color.black, size=size.tiny)

// ORB Breakout Signals
plotshape(is_breakout_up, title="ORB Upward Breakout", location=location.belowbar, color=color.purple, style=shape.labelup, text="ORB", textcolor=color.white, size=size.tiny)
plotshape(is_breakout_down, title="ORB Downward Breakout", location=location.abovebar, color=color.purple, style=shape.labeldown, text="ORB", textcolor=color.white, size=size.tiny)

// --- Background for Trend context ---
bgcolor(is_bullish ? color.new(color.green, 95) : is_bearish ? color.new(color.red, 95) : na)
````

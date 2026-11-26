# Custom Levels & Smoothed VWAPs for BTC SB

- url: https://www.tradingview.com/script/bXAHhgHU-Custom-Levels-Smoothed-VWAPs-for-BTC-SB/
- type: indicator
- pine_id: PUB;a3f92abc4dda41cbb6378b07a27ba38a
- version: 1.0

## Description

50er & 200er EMA 
VWAP Weekly & Monthly 
Daily Open and High & Low
Point of Control

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Custom Levels & Smoothed VWAPs", overlay = true, max_lines_count = 20, max_labels_count = 20)

// --- Inputs ---
group_daily = "Daily Levels (Right Side)"
show_daily  = input.bool(true, "Show Daily O/H/L (10 Bars)", group = group_daily)
line_len    = input.int(10, "Line Length (Bars)", minval = 1, group = group_daily)
col_open    = input.color(color.gray, "Daily Open Color", group = group_daily)
col_high    = input.color(#f23645, "Daily High Color", group = group_daily)
col_low     = input.color(#089981, "Daily Low Color", group = group_daily)

group_ema   = "Moving Averages"
ema50_col   = input.color(#ff9800, "EMA 50 Color (Orange)", group = group_ema)
ema200_col  = input.color(#ffeb3b, "EMA 200 Color (Yellow)", group = group_ema)

group_vwap  = "VWAPs"
show_w_vwap = input.bool(true, "Show Weekly VWAP", group = group_vwap)
show_m_vwap = input.bool(true, "Show Monthly VWAP", group = group_vwap)
col_w_vwap  = input.color(#2196f3, "Weekly VWAP Color (Blue)", group = group_vwap)
col_m_vwap  = input.color(#4caf50, "Monthly VWAP Color (Green)", group = group_vwap)

group_poc   = "Point of Control (POC)"
show_poc    = input.bool(true, "Show Daily POC (Right Side)", group = group_poc)
col_poc     = input.color(#ff5252, "POC Color", group = group_poc)

// --- Daily Levels Logic & Labels ---
[d_open, d_high, d_low] = request.security(syminfo.tickerid, "D", [open, high, low], lookahead = barmerge.lookahead_on)

var line o_line = line.new(na, na, na, na, xloc.bar_index, extend.none, col_open, line.style_solid, 2)
var line h_line = line.new(na, na, na, na, xloc.bar_index, extend.none, col_high, line.style_solid, 2)
var line l_line = line.new(na, na, na, na, xloc.bar_index, extend.none, col_low,  line.style_solid, 2)

var label o_lab = label.new(na, na, "D Open", xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_left, col_open, size.small)
var label h_lab = label.new(na, na, "D High", xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_left, col_high, size.small)
var label l_lab = label.new(na, na, "D Low",  xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_left, col_low,  size.small)

// --- POC Logic (Calculation) ---
var float max_vol = 0.0
var float poc_price = na

if timeframe.change("D")
    max_vol := volume
    poc_price := hl2
else
    if volume > max_vol
        max_vol := volume
        poc_price := hl2

// POC Line & Label (Right Side Only)
var line p_line = line.new(na, na, na, na, xloc.bar_index, extend.none, col_poc, line.style_dashed, 2)
var label p_lab = label.new(na, na, "Daily POC", xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_left, col_poc, size.small)

// --- Update Visuals on Last Bar ---
if barstate.islast
    if show_daily
        line.set_xy1(o_line, bar_index - line_len, d_open), line.set_xy2(o_line, bar_index, d_open)
        line.set_xy1(h_line, bar_index - line_len, d_high), line.set_xy2(h_line, bar_index, d_high)
        line.set_xy1(l_line, bar_index - line_len, d_low),  line.set_xy2(l_line, bar_index, d_low)
        label.set_xy(o_lab, bar_index, d_open)
        label.set_xy(h_lab, bar_index, d_high)
        label.set_xy(l_lab, bar_index, d_low)
    
    if show_poc
        line.set_xy1(p_line, bar_index - line_len, poc_price)
        line.set_xy2(p_line, bar_index, poc_price)
        label.set_xy(p_lab, bar_index, poc_price)

// --- EMAs Logic ---
ema50  = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

plot(ema50,  "EMA 50",  color = ema50_col,  linewidth = 2)
plot(ema200, "EMA 200", color = ema200_col, linewidth = 2)

// --- VWAPs Logic (Smoothed) ---
w_vwap = ta.ema(ta.vwap(close, timeframe.change("W")), 2)
m_vwap = ta.ema(ta.vwap(close, timeframe.change("M")), 2)

plot(show_w_vwap ? w_vwap : na, "Weekly VWAP",  color = col_w_vwap, linewidth = 2)
plot(show_m_vwap ? m_vwap : na, "Monthly VWAP", color = col_m_vwap, linewidth = 2)
````

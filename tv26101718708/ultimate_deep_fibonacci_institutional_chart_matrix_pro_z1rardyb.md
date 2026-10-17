# Ultimate Deep Fibonacci & Institutional Chart Matrix Pro

- url: https://www.tradingview.com/script/Z1RArdYB-Ultimate-Deep-Fibonacci-Institutional-Chart-Matrix-Pro/
- type: indicator
- pine_id: PUB;ae8735c621064dd0960ac303c1c6e9e3
- version: 1.0

## Description

Ultimate Deep Fibonacci and Institutional Chart Matrix Pro


Overview
The Ultimate Deep Fibonacci and Institutional Chart Matrix Pro is a comprehensive visual framework designed for Pine Script v6. It combines Smart Money Concepts, dynamic support and resistance zones, session liquidity levels, and structural Fibonacci pricing into a unified chart layout.
This tool maps market structure transitions, identifies key institutional high and low swing levels, tracks Asian session ranges, and visualizes overall price flow through a custom smooth wave with integrated volume price background fill.



Core Features
Natural Price Wave and Shadow Fill
Maps underlying market momentum using a smoothed wave calculation.
Dynamically fills the space between the current close price and the wave line to visualize expanding or contracting momentum.
Color coded green for bullish conditions and red for bearish conditions.


Deep Institutional Fibonacci Matrix
Plots critical institutional Fibonacci levels based on recent market swings:
0.50 Equilibrium (EQ): The midpoint balance level.
0.618 Golden Zone: A primary level for premium or discount interest.
0.786 Deep Discount: A deep structural reversal or continuation level.


Dynamic Support and Resistance Zones
Automatically draws extended resistance and support boxes using dynamic pivot points and Average True Range buffering.
Labels automatically project forward on the chart without obscuring live price action.

Major ITH and ITL Badges
Identifies significant Intermediate Term Highs (ITH, colored Red) and Intermediate Term Lows (ITL, colored Green).
Configurable lookback parameters filter out minor noise, focusing solely on major swing structural points.


Smart Money Concepts Structure
Detects and plots structural breaks:
BOS (Break of Structure): Signals trend continuation.
CHoCH (Change of Character): Signals potential market trend shifts.

Asian Session Liquidity Tracking
Tracks the high and low levels established during the Asian trading session.
Plots dotted projection lines until price breaks or sweeps these liquidity levels.
Dynamic Projection Arrow and Low Resistance Liquidity
Projects short term expected direction using Average True Range volatility metrics.

Highlights major liquidity pools based on key high and low boundaries.
On Screen Live Dashboard
Displays real time market stats in the top right corner, including Market Flow, Golden Zone values, Asian Session status, Volatility, and Market Structure Alignment.



Settings Breakdown

Price Wave and Shadow Settings
Show Natural Price Wave and Fill Shadow: Enables or disables the wave line and its background fill.
Wave Sensitivity: Adjusts the lookback period for the wave calculation (Default: 20).
Shadow Transparency (0-100): Controls the background fill opacity.



Deep Fibonacci Matrix
Show Deep Institutional Fib: Enables or disables structural Fibonacci lines.
Fib Swing Lookback: Determines the number of bars evaluated for top and bottom Fibonacci anchors (Default: 40).



Dynamic Support and Resistance Box Zones
Show Dynamic Box S/R Zones: Toggles support and resistance box zones.
S/R Sensitivity: Controls the pivot detection length for drawing zones (Default: 20).



Major ITH and ITL Settings
Show Major ITH and ITL Badges: Toggles ITH and ITL visual markers.
Major ITH and ITL Lookback: Controls swing sensitivity to filter minor noise (Default: 20).



Projection and Liquidity Settings
Show Direction Projection Arrow: Toggles the forward projection arrow.
Arrow Forward Bars: Controls how far ahead the arrow projects (Default: 12).
Show Low Resistance Liquidity: Toggles liquidity baseline highlights.



Asian Liquidity and SMC Settings
Show Active Asian High / Low: Toggles Asian range tracking lines.
Show BOS and CHoCH Structure: Enables market structure labels.
Structure Sensitivity: Controls pivot lookback for structural breaks.



How to Use
Context Identification: Look at the Market Flow and Price Wave Fill Shadow to determine the directional bias (Bullish = Green, Bearish = Red).
Key Zone Mapping: Identify price interaction with the Support Zone or Resistance Zone. Monitor how price behaves near the 0.618 Golden Zone or 0.786 Deep Discount lines.
Structure Confirmation: Confirm structural updates via BOS or CHoCH markers. Look for ITH (Red) or ITL (Green) labels to mark key swing pivots.
Session Liquidity: Monitor the ASIA H and ASIA L dotted lines for potential liquidity sweeps during peak trading hours.



Things to Avoid
Avoid Over-Leveraging at Single Levels: Never rely on a single line or zone in isolation; always seek confluence across structural breaks and dynamic zones.
Avoid High Sensitivity on Low Timeframes: Setting swing sensitivities too low on lower timeframes can lead to excessive noise. Adjust lookback values according to your target timeframe.

Avoid Trading directly into major Resistance or Support: Exercise caution when opening new directional positions directly inside established Resistance or Support boxes.


Disclaimer
Trading financial markets involves significant risk and can result in the loss of your capital. This indicator is designed strictly for educational and analytical purposes to assist with visual market structure identification. It is not financial advice, investment recommendation, or a signal service. Always manage your risk responsibly, conduct your own independent research, and follow your own personalized trading plan.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Dark_Ace_Master

//@version=6
indicator("Ultimate Deep Fibonacci & Institutional Chart Matrix Pro", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

show_wave    = input.bool(true, "Show Price Wave & Fill Shadow", group="Price Wave & Shadow Settings")
wave_len     = input.int(20, "Wave Sensitivity", minval=3, group="Price Wave & Shadow Settings")
fill_opacity = input.int(80, "Shadow Transparency (0-100)", minval=0, maxval=100, group="Price Wave & Shadow Settings")

show_fib     = input.bool(true, "Show Deep Institutional Fib", group="Deep Fibonacci Matrix")
fib_len      = input.int(40, "Fib Swing Lookback", minval=10, group="Deep Fibonacci Matrix")

show_boxes   = input.bool(true, "Show Dynamic Box S/R Zones", group="Dynamic S/R Box Zones")
sr_len       = input.int(20, "S/R Sensitivity", minval=5, group="Dynamic S/R Box Zones")

show_ith_itl = input.bool(true, "Show Major ITH & ITL Badges", group="Major ITH & ITL Settings")
ith_len      = input.int(20, "Major ITH/ITL Lookback", minval=5, group="Major ITH & ITL Settings")

show_arrow   = input.bool(true, "Show Direction Projection Arrow", group="Projection Arrow Settings")
arrow_dist   = input.int(12, "Arrow Forward Bars", minval=5, group="Projection Arrow Settings")

show_lrl     = input.bool(true, "Show Low Resistance Liquidity", group="Liquidity Levels")
lrl_len      = input.int(25, "Liquidity Lookback", minval=10, group="Liquidity Levels")

show_smc     = input.bool(true, "Show BOS & CHoCH Structure", group="Market Structure (SMC)")
smc_len      = input.int(10, "Structure Sensitivity", minval=5, group="Market Structure (SMC)")

show_asia    = input.bool(true, "Show Active Asian High / Low (Dotted)", group="Asian Liquidity Range")
show_panel   = input.bool(true, "Show Pro Live Dashboard", group="Dashboard Settings")

wave_val = ta.wma(close, wave_len) + (ta.atr(10) * 0.1 * math.sin(bar_index))
is_up    = wave_val > wave_val[1]

main_col = is_up ? #00e676 : #ff1744
bg_col   = is_up ? color.new(#00e676, fill_opacity) : color.new(#ff1744, fill_opacity)

p_wave1 = plot(show_wave ? wave_val : na, title="Wave Line Upper", color=main_col, linewidth=2)
p_wave2 = plot(show_wave ? close : na, title="Price Line Reference", color=color.new(main_col, 100))

fill(p_wave1, p_wave2, color=bg_col, title="Price Wave Fill Shadow")

fib_hi = ta.highest(high, fib_len)
fib_lo = ta.lowest(low, fib_len)
diff   = fib_hi - fib_lo

p_500  = fib_hi - (diff * 0.500)
p_618  = fib_hi - (diff * 0.618)
p_786  = fib_hi - (diff * 0.786)

var line l_500 = na
var line l_618 = na
var line l_786 = na
var label lbl_500 = na
var label lbl_618 = na
var label lbl_786 = na

if show_fib and barstate.islast
    line.delete(l_500)
    line.delete(l_618)
    line.delete(l_786)
    label.delete(lbl_500)
    label.delete(lbl_618)
    label.delete(lbl_786)
    
    int start_x = bar_index - 25
    int end_x   = bar_index + 15
    
    l_500   := line.new(start_x, p_500, end_x, p_500, color=color.new(#ffffff, 30), style=line.style_solid, width=1)
    lbl_500 := label.new(end_x, p_500, "0.50 EQ", color=color.new(#000000, 100), textcolor=color.white, style=label.style_label_left, size=size.normal)
    
    l_618   := line.new(start_x, p_618, end_x, p_618, color=#ffd600, style=line.style_solid, width=2)
    lbl_618 := label.new(end_x, p_618, "0.618 Golden Zone", color=#ffd600, textcolor=color.black, style=label.style_label_left, size=size.normal)
    
    l_786   := line.new(start_x, p_786, end_x, p_786, color=#00e5ff, style=line.style_solid, width=2)
    lbl_786 := label.new(end_x, p_786, "0.786 Deep Discount", color=color.new(#000000, 100), textcolor=#00e5ff, style=label.style_label_left, size=size.normal)

sr_hi = ta.pivothigh(high, sr_len, sr_len)
sr_lo = ta.pivotlow(low, sr_len, sr_len)

var box res_box = na
var box sup_box = na

atr_val = ta.atr(14) * 0.35

if show_boxes and not na(sr_hi)
    box.delete(res_box)
    p = high[sr_len]
    res_box := box.new(left=bar_index - sr_len, top=p + atr_val, right=bar_index + 20, bottom=p - atr_val, border_color=#ff1744, bgcolor=color.new(#ff1744, 80), text="RESISTANCE ZONE", text_color=color.black, text_size=size.normal, text_halign=text.align_right)

if show_boxes and not na(sr_lo)
    box.delete(sup_box)
    p = low[sr_len]
    sup_box := box.new(left=bar_index - sr_len, top=p + atr_val, right=bar_index + 20, bottom=p - atr_val, border_color=#00e676, bgcolor=color.new(#00e676, 80), text="SUPPORT ZONE", text_color=color.black, text_size=size.normal, text_halign=text.align_right)

if show_boxes
    if not na(res_box)
        box.set_right(res_box, bar_index + 20)
    if not na(sup_box)
        box.set_right(sup_box, bar_index + 20)

ith_p = ta.pivothigh(high, ith_len, ith_len)
itl_p = ta.pivotlow(low, ith_len, ith_len)

if show_ith_itl and not na(ith_p)
    int idx = bar_index - ith_len
    label.new(idx, high[ith_len] + (ta.atr(14) * 0.4), "ITH", color=#ff1744, textcolor=color.white, style=label.style_label_down, size=size.normal)

if show_ith_itl and not na(itl_p)
    int idx = bar_index - ith_len
    label.new(idx, low[ith_len] - (ta.atr(14) * 0.4), "ITL", color=#00e676, textcolor=color.black, style=label.style_label_up, size=size.normal)

var line proj_arrow = na
var label proj_lbl  = na

if show_arrow and barstate.islast
    line.delete(proj_arrow)
    label.delete(proj_lbl)
    
    float start_p = close
    float end_p   = is_up ? close + (ta.atr(14) * 1.5) : close - (ta.atr(14) * 1.5)
    
    proj_arrow := line.new(bar_index, start_p, bar_index + arrow_dist, end_p, color=main_col, style=line.style_arrow_right, width=3)
    proj_lbl   := label.new(bar_index + arrow_dist, end_p, is_up ? "PROJECTION HIGH" : "PROJECTION LOW", color=color.new(#000000, 100), textcolor=main_col, style=label.style_label_left, size=size.normal)

var line lrl_line = na
var label lrl_lbl  = na

if show_lrl and barstate.islast
    line.delete(lrl_line)
    label.delete(lrl_lbl)
    
    float lrl_price = is_up ? ta.highest(high, lrl_len) : ta.lowest(low, lrl_len)
    int start_x     = bar_index - lrl_len
    int end_x       = bar_index + 20
    
    lrl_line := line.new(start_x, lrl_price, end_x, lrl_price, color=#ffea00, style=line.style_dashed, width=2)
    lrl_lbl  := label.new(end_x, lrl_price, "LOW RESISTANCE LIQUIDITY", color=#ffea00, textcolor=color.black, style=label.style_label_left, size=size.normal)

ph = ta.pivothigh(high, smc_len, smc_len)
pl = ta.pivotlow(low, smc_len, smc_len)

var float last_ph = na
var int last_ph_idx = na
var float last_pl = na
var int last_pl_idx = na
var int trend_dir = 0

if not na(ph)
    last_ph := ph
    last_ph_idx := bar_index - smc_len
if not na(pl)
    last_pl := pl
    last_pl_idx := bar_index - smc_len

if show_smc and not na(last_ph) and ta.crossover(close, last_ph)
    string tag = trend_dir == -1 ? "CHoCH" : "BOS"
    int start_x = last_ph_idx
    int end_x = bar_index
    int mid_x = math.floor((start_x + end_x) / 2)
    line.new(start_x, last_ph, end_x, last_ph, color=#00e676, style=line.style_dashed, width=1)
    label.new(mid_x, last_ph, tag, color=color.new(#000000, 100), textcolor=#00e676, style=label.style_label_down, size=size.normal)
    trend_dir := 1
    last_ph := na

if show_smc and not na(last_pl) and ta.crossunder(close, last_pl)
    string tag = trend_dir == 1 ? "CHoCH" : "BOS"
    int start_x = last_pl_idx
    int end_x = bar_index
    int mid_x = math.floor((start_x + end_x) / 2)
    line.new(start_x, last_pl, end_x, last_pl, color=#ff1744, style=line.style_dashed, width=1)
    label.new(mid_x, last_pl, tag, color=color.new(#000000, 100), textcolor=#ff1744, style=label.style_label_up, size=size.normal)
    trend_dir := -1
    last_pl := na

in_asia_session = not na(time(timeframe.period, "0000-0800:23456"))

var float asia_hi = na
var float asia_lo = na
var line asia_hi_line = na
var line asia_lo_line = na
var label asia_hi_lbl = na
var label asia_lo_lbl = na
var bool asia_hi_broken = false
var bool asia_lo_broken = false

if in_asia_session and not in_asia_session[1]
    asia_hi := high
    asia_lo := low
    asia_hi_broken := false
    asia_lo_broken := false
    line.delete(asia_hi_line)
    line.delete(asia_lo_line)
    label.delete(asia_hi_lbl)
    label.delete(asia_lo_lbl)

if in_asia_session
    asia_hi := math.max(asia_hi, high)
    asia_lo := math.min(asia_lo, low)

if not in_asia_session and in_asia_session[1] and show_asia
    asia_hi_line := line.new(bar_index, asia_hi, bar_index + 15, asia_hi, color=#00e5ff, style=line.style_dotted, width=2)
    asia_hi_lbl  := label.new(bar_index + 15, asia_hi, "ASIA H", color=#00e5ff, textcolor=color.black, style=label.style_label_left, size=size.normal)
    
    asia_lo_line := line.new(bar_index, asia_lo, bar_index + 15, asia_lo, color=#ffea00, style=line.style_dotted, width=2)
    asia_lo_lbl  := label.new(bar_index + 15, asia_lo, "ASIA L", color=#ffea00, textcolor=color.black, style=label.style_label_left, size=size.normal)

if show_asia and not in_asia_session
    if not na(asia_hi_line) and not asia_hi_broken
        if high > asia_hi
            asia_hi_broken := true
            line.delete(asia_hi_line)
            label.delete(asia_hi_lbl)
        else
            line.set_x2(asia_hi_line, bar_index + 15)
            label.set_x(asia_hi_lbl, bar_index + 15)

    if not na(asia_lo_line) and not asia_lo_broken
        if low < asia_lo
            asia_lo_broken := true
            line.delete(asia_lo_line)
            label.delete(asia_lo_lbl)
        else
            line.set_x2(asia_lo_line, bar_index + 15)
            label.set_x(asia_lo_lbl, bar_index + 15)

var table dash = table.new(position.top_right, 2, 5, bgcolor=color.new(#0d1117, 10), border_width=1, border_color=#30363d)

if show_panel and barstate.islast
    table.cell(dash, 0, 0, "Market Flow", text_color=color.white, text_size=size.small, bgcolor=#161b22)
    table.cell(dash, 1, 0, is_up ? "BULLISH" : "BEARISH", text_color=is_up ? #00e676 : #ff1744, text_size=size.small, bgcolor=#161b22)
    
    table.cell(dash, 0, 1, "Golden Zone", text_color=color.white, text_size=size.small, bgcolor=#161b22)
    table.cell(dash, 1, 1, str.tostring(p_618, "#.##"), text_color=#ffd600, text_size=size.small, bgcolor=#161b22)
    
    table.cell(dash, 0, 2, "Asian Liquidity", text_color=color.white, text_size=size.small, bgcolor=#161b22)
    table.cell(dash, 1, 2, asia_hi_broken or asia_lo_broken ? "SWEPT" : "HOLDING", text_color=asia_hi_broken or asia_lo_broken ? #ff1744 : #00e676, text_size=size.small, bgcolor=#161b22)
    
    table.cell(dash, 0, 3, "Volatility", text_color=color.white, text_size=size.small, bgcolor=#161b22)
    table.cell(dash, 1, 3, str.tostring(ta.atr(14), "#.##"), text_color=color.white, text_size=size.small, bgcolor=#161b22)
    
    table.cell(dash, 0, 4, "SMC Alignment", text_color=color.white, text_size=size.small, bgcolor=#161b22)
    table.cell(dash, 1, 4, trend_dir == 1 ? "BULLISH BOS" : trend_dir == -1 ? "BEARISH BOS" : "RANGING", text_color=trend_dir == 1 ? #00e676 : #ff1744, text_size=size.small, bgcolor=#161b22)
````

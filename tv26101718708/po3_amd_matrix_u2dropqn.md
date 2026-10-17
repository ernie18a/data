# PO3 / AMD Matrix

- url: https://www.tradingview.com/script/U2dRoPqn-PO3-AMD-Matrix/
- type: indicator
- pine_id: PUB;e71d71276e464ee89c120299892968ff
- version: 1.0

## Description

This script is a visual mapping tool for the ICT Power of 3 (PO3) / AMD framework. It uses the foundational ICT rule that "Time Supersedes Price" by segmenting your daily trading chart into three highly specific algorithmic time windows.

Here is exactly how the script breaks down the price delivery cycle:

1. Accumulation Phase (Default: 20:00 - 00:00)
The script starts the daily cycle by tracking the initial consolidation range where "Smart Money" is quietly building positions.

Visuals: It dynamically draws a gray box wrapping the highest high and lowest low of price during this specific time window.
Purpose: This establishes the initial liquidity boundaries for the upcoming sessions.

2. The True Opening Price (Midnight Open)
At exactly 00:00 (or whatever time you set the Manipulation phase to begin), the algorithm locks in the "True Opening Price".

Visuals: The script draws a thick, solid white line starting at that opening candle.
Purpose: This line is projected forward across the rest of the day. It acts as your primary benchmark. Any move below this line is considered "Discount" (cheap/manipulation for longs) and any move above is "Premium" (expensive/manipulation for shorts).

3. Manipulation Phase / Judas Swing (Default: 00:00 - 08:30)
This is the engineered move designed to trap retail traders by hunting the liquidity built up during the Accumulation phase.

Visuals: The script draws a red box that dynamically traces the highs and lows during this window.
Purpose: By contrasting this red box against your solid white "True Open" line, you can easily identify the Judas Swing—the fakeout wick that sweeps stops before reversing into the true trend.

4. Distribution Phase (Default: 08:30 - 16:00)
This is the true directional expansion of the day, yielding the bulk of the daily candlestick body.

Visuals: A green box is drawn dynamically wrapping the price action during this high-volatility window. The True Open line is also extended straight through this box so you can see how far price has expanded from the daily baseline.

Customization: All the session times (Accumulation, Manipulation, Distribution) are completely editable in the settings. You can adjust the times to match your broker's timezone or to target specific micro-macros within a session. The colors for all boxes and the opening line are also fully customizable!

## Source Code

````pine
//@version=6
indicator("PO3 / AMD Matrix", overlay=true, max_boxes_count=500, max_lines_count=500)

// =====================================================================
// ICT PO3 / AMD (Accumulation, Manipulation, Distribution)
// Accumulation: Smart money accumulating positions tightly around opening price.
// Manipulation (Judas Swing): Fake move opposite to intended direction to sweep stops.
// Distribution: True directional expansion yielding bulk of candlestick body.
// Time Supersedes Price.
// =====================================================================

// --- Inputs ---
grp_time = "AMD Time Windows (Exchange Time)"
acc_sess = input.session("2000-0000", title="Accumulation Phase", group=grp_time)
man_sess = input.session("0000-0830", title="Manipulation Phase", group=grp_time)
dis_sess = input.session("0830-1600", title="Distribution Phase", group=grp_time)

grp_style = "Visual Styling"
acc_col = input.color(color.new(color.gray, 85), title="Accumulation Color", group=grp_style)
man_col = input.color(color.new(color.red, 85), title="Manipulation Color", group=grp_style)
dis_col = input.color(color.new(color.green, 85), title="Distribution Color", group=grp_style)
open_col = input.color(color.new(color.white, 30), title="True Opening Price Line", group=grp_style)

// Session check function
in_session(sess) =>
    not na(time(timeframe.period, sess))

in_acc = in_session(acc_sess)
in_man = in_session(man_sess)
in_dis = in_session(dis_sess)

// --- Accumulation Phase ---
var box acc_box = na
var float acc_high = na
var float acc_low = na

if in_acc and not in_acc[1]
    acc_high := high
    acc_low := low
    acc_box := box.new(left=time, top=acc_high, right=time_close, bottom=acc_low, bgcolor=acc_col, border_color=color.new(acc_col, 40), xloc=xloc.bar_time, text="Accumulation", text_color=color.new(acc_col, 0), text_size=size.small, text_halign=text.align_center, text_valign=text.align_bottom)
else if in_acc
    acc_high := math.max(acc_high, high)
    acc_low := math.min(acc_low, low)
    box.set_right(acc_box, time_close)
    box.set_top(acc_box, acc_high)
    box.set_bottom(acc_box, acc_low)

// --- Manipulation Phase (Judas Swing) & True Open ---
var box man_box = na
var float man_high = na
var float man_low = na
var float true_open = na
var line open_line = na
var label open_lbl = na

if in_man and not in_man[1]
    man_high := high
    man_low := low
    true_open := open
    man_box := box.new(left=time, top=man_high, right=time_close, bottom=man_low, bgcolor=man_col, border_color=color.new(man_col, 40), xloc=xloc.bar_time, text="Manipulation", text_color=color.new(man_col, 0), text_size=size.small, text_halign=text.align_center, text_valign=text.align_bottom)
    open_line := line.new(x1=time, y1=true_open, x2=time_close, y2=true_open, color=open_col, style=line.style_solid, width=2, xloc=xloc.bar_time)
    open_lbl := label.new(x=time, y=true_open, text="True Open", color=color.new(color.white, 100), textcolor=open_col, style=label.style_label_down, size=size.small, xloc=xloc.bar_time)
else if in_man
    man_high := math.max(man_high, high)
    man_low := math.min(man_low, low)
    box.set_right(man_box, time_close)
    box.set_top(man_box, man_high)
    box.set_bottom(man_box, man_low)
    if not na(open_line)
        line.set_x2(open_line, time_close)

// --- Distribution Phase ---
var box dis_box = na
var float dis_high = na
var float dis_low = na

if in_dis and not in_dis[1]
    dis_high := high
    dis_low := low
    dis_box := box.new(left=time, top=dis_high, right=time_close, bottom=dis_low, bgcolor=dis_col, border_color=color.new(dis_col, 40), xloc=xloc.bar_time, text="Distribution", text_color=color.new(dis_col, 0), text_size=size.small, text_halign=text.align_center, text_valign=text.align_bottom)
else if in_dis
    dis_high := math.max(dis_high, high)
    dis_low := math.min(dis_low, low)
    box.set_right(dis_box, time_close)
    box.set_top(dis_box, dis_high)
    box.set_bottom(dis_box, dis_low)
    
// Project the True Open line forward during the distribution phase
if in_dis and not na(open_line)
    line.set_x2(open_line, time_close)
````

# Premium & Discount Matrix

- url: https://www.tradingview.com/script/ECuu94cL-Premium-Discount-Matrix/
- type: indicator
- pine_id: PUB;9574bf2801d24fa39bfd6989e92c0b2b
- version: 1.0

## Description

1. Dynamic Intraday Dealing Range
The core of the PD Matrix is the "dealing range." The script calculates this by finding the absolute highest high and lowest low of the current daily session:

It automatically detects when a new day begins.
As the day progresses and price creates new highs or lows, the script dynamically updates the top and bottom boundaries in real-time.

2. Matrix Box & Equilibrium
Once the dealing range is established, it draws the matrix components:

The Box: It draws a single, fully transparent rectangle around the entire daily range. The background is completely clear so it doesn't obstruct your candlesticks, and only the outer border is visible.
Equilibrium (50%): It automatically calculates the exact mathematical midpoint of the daily high and low. It then draws a dashed line straight through the middle of the box to represent the 50% Equilibrium level.

3. Smart Market Labeling
To make the zones instantly readable, the script places three floating text labels neatly to the right of your current live candle. These labels move with the price action:

Premium (Red): Positioned in the upper half (above 50%). According to ICT concepts, this is expensive pricing where institutional algorithms seek to distribute (sell short).
Eq (50%) (Gray): Points directly to the dashed equilibrium line, representing fair value.
Discount (Green): Positioned in the lower half (below 50%). This is cheap pricing where institutional algorithms seek to accumulate (buy long).

4. Customization & Performance
Like the previous script, this is highly optimized for TradingView. It uses a single dynamic box, a single line, and three labels that constantly update on the very last bar, preventing your chart from being cluttered with hundreds of historical drawings.

You can fully customize the colors of the box border, the equilibrium line, and all three text labels directly from the indicator settings!

## Source Code

````pine
//@version=6
indicator("Premium & Discount Matrix", overlay=true)

// =====================================================================
// ICT Premium & Discount Matrix (Current Day)
// Objectives: Identify wholesale vs retail pricing for the current session.
// Equilibrium (50%): Midpoint of dealing range.
// Premium: Above 50% (Expensive, Distribute/Sell)
// Discount: Below 50% (Cheap, Accumulate/Buy)
// =====================================================================

// --- Inputs ---
grp_style = "Matrix Styling"
border_col = input.color(color.gray, title="Box Border Color", group=grp_style)
eq_col = input.color(color.gray, title="Equilibrium Line Color", group=grp_style)
prem_text_col = input.color(color.red, title="Premium Text Color", group=grp_style)
disc_text_col = input.color(color.green, title="Discount Text Color", group=grp_style)

// --- Daily Dealing Range Logic ---
var float day_high = na
var float day_low = na
var int day_start_time = na

// Detect new day
is_new_day = nz(ta.change(time("D"))) != 0 or barstate.isfirst

if is_new_day
    day_high := high
    day_low := low
    day_start_time := time
else
    day_high := math.max(day_high, high)
    day_low := math.min(day_low, low)

// Calculate Equilibrium
eq_level = (day_high + day_low) / 2

// --- Drawings ---
var box pd_box = na
var line eq_line = na
var label lbl_prem = na
var label lbl_disc = na
var label lbl_eq = na

if barstate.islast
    // 1. Draw the main dealing range box (transparent background, only border)
    if na(pd_box)
        pd_box := box.new(left=day_start_time, top=day_high, right=time_close, bottom=day_low, 
                          bgcolor=color.new(color.white, 100), border_color=border_col, border_width=1, xloc=xloc.bar_time)
    else
        box.set_left(pd_box, day_start_time)
        box.set_right(pd_box, time_close)
        box.set_top(pd_box, day_high)
        box.set_bottom(pd_box, day_low)
        box.set_border_color(pd_box, border_col)

    // 2. Draw the Equilibrium (50%) middle line
    if na(eq_line)
        eq_line := line.new(x1=day_start_time, y1=eq_level, x2=time_close, y2=eq_level, 
                            color=eq_col, style=line.style_dashed, width=1, xloc=xloc.bar_time)
    else
        line.set_x1(eq_line, day_start_time)
        line.set_x2(eq_line, time_close)
        line.set_y1(eq_line, eq_level)
        line.set_y2(eq_line, eq_level)
        line.set_color(eq_line, eq_col)

    // 3. Draw Labels extending to the right of the current bar
    if na(lbl_prem)
        lbl_prem := label.new(x=time_close, y=(day_high + eq_level) / 2, text="Premium", xloc=xloc.bar_time, 
                              style=label.style_label_left, color=color.new(color.white, 100), textcolor=prem_text_col, size=size.normal)
    else
        label.set_x(lbl_prem, time_close)
        label.set_y(lbl_prem, (day_high + eq_level) / 2)
        label.set_textcolor(lbl_prem, prem_text_col)

    if na(lbl_eq)
        lbl_eq := label.new(x=time_close, y=eq_level, text="Eq (50%)", xloc=xloc.bar_time, 
                            style=label.style_label_left, color=color.new(color.white, 100), textcolor=eq_col, size=size.small)
    else
        label.set_x(lbl_eq, time_close)
        label.set_y(lbl_eq, eq_level)
        label.set_textcolor(lbl_eq, eq_col)

    if na(lbl_disc)
        lbl_disc := label.new(x=time_close, y=(eq_level + day_low) / 2, text="Discount", xloc=xloc.bar_time, 
                              style=label.style_label_left, color=color.new(color.white, 100), textcolor=disc_text_col, size=size.normal)
    else
        label.set_x(lbl_disc, time_close)
        label.set_y(lbl_disc, (eq_level + day_low) / 2)
        label.set_textcolor(lbl_disc, disc_text_col)
````

# FCPO S&R Sessions [MYT]

- url: https://www.tradingview.com/script/3g8ePXy0-FCPO-S-R-Sessions-MYT/
- type: indicator
- pine_id: PUB;69e6e4525fcc4e3f96304d0d361987b8
- version: 1.0

## Description

The Pine Script you provided is a trading indicator designed for the FCPO (Futures Crude Palm Oil) market in Malaysia. It focuses on identifying support and resistance levels during specific trading sessions throughout the day. Here’s a narrative that explains its functionality and purpose in a structured manner:

### The Story of FCPO Support and Resistance Indicator

#### Setting the Scene
Imagine a trader in Malaysia, keen on navigating the volatile world of crude palm oil futures. With trading sessions structured around specific times, this trader needs a reliable tool to identify key price levels that can guide their decisions.

#### The Purpose
This Pine Script is crafted to help traders visualize **support** and **resistance** levels during three key trading sessions:
- **Morning Session**: 10:30 – 12:30 MYT
- **Evening Session**: 14:30 – 18:00 MYT
- **Night Session**: 21:00 – 23:00 MYT

These sessions are crucial as they often see significant market activity, and identifying the high and low during these periods can indicate potential price movements.

#### Features of the Indicator
1. **Session Visibility**: 
   - Traders can choose to display or hide the morning, evening, and night sessions.
   
2. **Session Dividers**:
   - An optional visual divider can be shown between sessions, allowing traders to quickly distinguish between different trading periods.

3. **Customizable Colors**:
   - The indicator allows personalized color settings for support and resistance lines, making it easier to differentiate levels at a glance.

4. **Line and Label Style**:
   - Traders can adjust the line width, style (solid, dashed, dotted), and label sizes to their preference, enhancing readability.

5. **Dynamic Updates**:
   - As new bars form within each session, the indicator dynamically updates the highest and lowest prices, ensuring the trader has real-time information.

#### The Mechanics
The script operates by:
- **Checking Timeframes**: It restricts its use to M1 – H1 timeframes to ensure accuracy. If used outside these ranges, it alerts the trader.
- **Session Detection**: The script employs UTC+8 timing to detect when each session opens and closes, storing high and low prices for each period.
- **Drawing Lines and Labels**: When a session opens, it draws lines for resistance (high) and support (low) and labels them accordingly. As the session progresses, it updates these lines based on new highs and lows.

#### Visual Representation
As the trader utilizes this indicator, they see:
- Bright orange lines marking resistance levels.
- Cool blue lines indicating support.
- Clear labels that show the exact price levels, helping them make informed trading decisions.

#### Conclusion
In this fast-paced environment, the FCPO Support and Resistance Indicator becomes an invaluable ally for traders. By providing clear visual cues of crucial price levels during specific trading sessions, it aids in making strategic decisions, ultimately enhancing trading outcomes.

With this understanding of how the Pine Script operates, traders can leverage it effectively. Would you like to explore how to modify or enhance any specific features in this script?

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MFM_TRADER
// FCPO Session Support & Resistance | Malaysia Time UTC+8 | Pine Script v6
// Morning Session : 10:30 – 12:30 MYT  (Mon–Fri)
// Evening Session : 14:30 – 18:00 MYT  (Mon–Fri)
// Night   Session : 21:00 – 23:00 MYT  (Mon–Thu)
// Resistance label → ABOVE line | Support label → BELOW line
// Optional divider between sessions

//@version=6
indicator("FCPO S&R Sessions [MYT]", shorttitle="FCPO S&R", overlay=true,
     max_lines_count  = 500,
     max_labels_count = 500)

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════
g1 = "Session Visibility"
show_m = input.bool(true, "Show Morning  (10:30–12:30)", group=g1)
show_e = input.bool(true, "Show Evening  (14:30–18:00)", group=g1)
show_n = input.bool(true, "Show Night    (21:00–23:00)", group=g1)

g_div = "Session Divider"
show_div = input.bool(true,    "Show Divider Between Sessions",                      group=g_div)
col_div  = input.color(color.new(#FFFFFF, 50), "Divider Colour",                     group=g_div)
div_w    = input.int(1,        "Divider Width", minval=1, maxval=4,                   group=g_div)
div_ls   = input.string("Dashed", "Divider Style", options=["Solid","Dashed","Dotted"], group=g_div)

g2 = "Colours"
col_R = input.color(color.new(#FF8C00, 0), "Resistance (High) — Orange", group=g2)
col_S = input.color(color.new(#1E90FF, 0), "Support    (Low)  — Blue",   group=g2)

g3 = "Line & Label Style"
lw       = input.int(2,          "Line Width",  minval=1, maxval=4,                        group=g3)
ls_inp   = input.string("Solid", "Line Style",  options=["Solid","Dashed","Dotted"],       group=g3)
lbl_sz   = input.string("Small", "Label Size",  options=["Tiny","Small","Normal","Large"],  group=g3)
show_tag = input.bool(true,      "Show Session Tag on Label",                               group=g3)

// ═══════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════
f_ls() =>
    switch ls_inp
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>          line.style_solid

f_sz() =>
    switch lbl_sz
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"  => size.large
        =>          size.small

f_txt(tag, price) =>
    show_tag ? tag + "\n" + str.tostring(price, "#.00") : str.tostring(price, "#.00")

// ═══════════════════════════════════════════════════════════════
// TIMEFRAME GUARD — M1 to H1 only
// ═══════════════════════════════════════════════════════════════
tf_ok = timeframe.in_seconds() <= 3600

if not tf_ok and barstate.islast
    label.new(bar_index, high,
         "⚠  FCPO S&R: Please use M1 – H1 timeframe only",
         color     = color.red,
         textcolor = color.white,
         style     = label.style_label_down,
         size      = size.normal)

// ═══════════════════════════════════════════════════════════════
// SESSION DETECTION via time() with UTC+8
// Pine session string day numbers: 1=Sun 2=Mon 3=Tue 4=Wed 5=Thu 6=Fri 7=Sat
// ═══════════════════════════════════════════════════════════════
sess_m = "1030-1230:23456"   // Mon–Fri
sess_e = "1430-1800:23456"   // Mon–Fri
sess_n = "2100-2300:2345"    // Mon–Thu

in_m = tf_ok and not na(time(timeframe.period, sess_m, "UTC+8"))
in_e = tf_ok and not na(time(timeframe.period, sess_e, "UTC+8"))
in_n = tf_ok and not na(time(timeframe.period, sess_n, "UTC+8"))

m_open  = in_m and not in_m[1]
e_open  = in_e and not in_e[1]
n_open  = in_n and not in_n[1]
m_close = not in_m and in_m[1]
e_close = not in_e and in_e[1]
n_close = not in_n and in_n[1]

// ═══════════════════════════════════════════════════════════════
// PERSISTENT STATE
// ═══════════════════════════════════════════════════════════════
var float mH = na,  var float mL = na
var float eH = na,  var float eL = na
var float nH = na,  var float nL = na
var int   mBar = na, var int eBar = na, var int nBar = na

var line  ln_mH = na, var line  ln_mL = na
var line  ln_eH = na, var line  ln_eL = na
var line  ln_nH = na, var line  ln_nL = na
var label lb_mH = na, var label lb_mL = na
var label lb_eH = na, var label lb_eL = na
var label lb_nH = na, var label lb_nL = na

// Pre-compute divider style once per bar (avoids calling inside if blocks)
div_style_val = div_ls == "Dashed" ? line.style_dashed : div_ls == "Dotted" ? line.style_dotted : line.style_solid

// ═══════════════════════════════════════════════════════════════
// MORNING SESSION  10:30 – 12:30
// ═══════════════════════════════════════════════════════════════
if m_open
    mH   := high
    mL   := low
    mBar := bar_index

    c_H = show_m ? col_R : color.new(color.white, 100)
    c_L = show_m ? col_S : color.new(color.white, 100)

    ln_mH := line.new(bar_index, high, bar_index, high,
         color=c_H, width=lw, style=f_ls(), extend=extend.none)
    ln_mL := line.new(bar_index, low, bar_index, low,
         color=c_L, width=lw, style=f_ls(), extend=extend.none)

    lb_mH := label.new(bar_index, high,
         text=f_txt("MRN R", high),
         color=show_m ? color.new(col_R, 15) : color.new(color.white, 100),
         textcolor=color.white, style=label.style_label_lower_left, size=f_sz())

    lb_mL := label.new(bar_index, low,
         text=f_txt("MRN S", low),
         color=show_m ? color.new(col_S, 15) : color.new(color.white, 100),
         textcolor=color.white, style=label.style_label_upper_left, size=f_sz())

if in_m
    mH := math.max(mH, high)
    mL := math.min(mL, low)

    line.set_xy1(ln_mH, mBar, mH)
    line.set_xy2(ln_mH, bar_index, mH)
    line.set_xy1(ln_mL, mBar, mL)
    line.set_xy2(ln_mL, bar_index, mL)

    label.set_x(lb_mH, bar_index)
    label.set_y(lb_mH, mH)
    label.set_text(lb_mH, f_txt("MRN R", mH))

    label.set_x(lb_mL, bar_index)
    label.set_y(lb_mL, mL)
    label.set_text(lb_mL, f_txt("MRN S", mL))

// Divider at Morning close 12:30
if show_div and m_close
    line.new(bar_index, high, bar_index, low,
         color=col_div, width=div_w, style=div_style_val, extend=extend.both)

// ═══════════════════════════════════════════════════════════════
// EVENING SESSION  14:30 – 18:00
// ═══════════════════════════════════════════════════════════════
if e_open
    eH   := high
    eL   := low
    eBar := bar_index

    c_H = show_e ? col_R : color.new(color.white, 100)
    c_L = show_e ? col_S : color.new(color.white, 100)

    ln_eH := line.new(bar_index, high, bar_index, high,
         color=c_H, width=lw, style=f_ls(), extend=extend.none)
    ln_eL := line.new(bar_index, low, bar_index, low,
         color=c_L, width=lw, style=f_ls(), extend=extend.none)

    lb_eH := label.new(bar_index, high,
         text=f_txt("EVE R", high),
         color=show_e ? color.new(col_R, 15) : color.new(color.white, 100),
         textcolor=color.white, style=label.style_label_lower_left, size=f_sz())

    lb_eL := label.new(bar_index, low,
         text=f_txt("EVE S", low),
         color=show_e ? color.new(col_S, 15) : color.new(color.white, 100),
         textcolor=color.white, style=label.style_label_upper_left, size=f_sz())

if in_e
    eH := math.max(eH, high)
    eL := math.min(eL, low)

    line.set_xy1(ln_eH, eBar, eH)
    line.set_xy2(ln_eH, bar_index, eH)
    line.set_xy1(ln_eL, eBar, eL)
    line.set_xy2(ln_eL, bar_index, eL)

    label.set_x(lb_eH, bar_index)
    label.set_y(lb_eH, eH)
    label.set_text(lb_eH, f_txt("EVE R", eH))

    label.set_x(lb_eL, bar_index)
    label.set_y(lb_eL, eL)
    label.set_text(lb_eL, f_txt("EVE S", eL))

// Divider at Evening close 18:00
if show_div and e_close
    line.new(bar_index, high, bar_index, low,
         color=col_div, width=div_w, style=div_style_val, extend=extend.both)

// ═══════════════════════════════════════════════════════════════
// NIGHT SESSION  21:00 – 23:00  (Mon–Thu)
// ═══════════════════════════════════════════════════════════════
if n_open
    nH   := high
    nL   := low
    nBar := bar_index

    c_H = show_n ? col_R : color.new(color.white, 100)
    c_L = show_n ? col_S : color.new(color.white, 100)

    ln_nH := line.new(bar_index, high, bar_index, high,
         color=c_H, width=lw, style=f_ls(), extend=extend.none)
    ln_nL := line.new(bar_index, low, bar_index, low,
         color=c_L, width=lw, style=f_ls(), extend=extend.none)

    lb_nH := label.new(bar_index, high,
         text=f_txt("NGT R", high),
         color=show_n ? color.new(col_R, 15) : color.new(color.white, 100),
         textcolor=color.white, style=label.style_label_lower_left, size=f_sz())

    lb_nL := label.new(bar_index, low,
         text=f_txt("NGT S", low),
         color=show_n ? color.new(col_S, 15) : color.new(color.white, 100),
         textcolor=color.white, style=label.style_label_upper_left, size=f_sz())

if in_n
    nH := math.max(nH, high)
    nL := math.min(nL, low)

    line.set_xy1(ln_nH, nBar, nH)
    line.set_xy2(ln_nH, bar_index, nH)
    line.set_xy1(ln_nL, nBar, nL)
    line.set_xy2(ln_nL, bar_index, nL)

    label.set_x(lb_nH, bar_index)
    label.set_y(lb_nH, nH)
    label.set_text(lb_nH, f_txt("NGT R", nH))

    label.set_x(lb_nL, bar_index)
    label.set_y(lb_nL, nL)
    label.set_text(lb_nL, f_txt("NGT S", nL))

// Divider at Night close 23:00
if show_div and n_close
    line.new(bar_index, high, bar_index, low,
         color=col_div, width=div_w, style=div_style_val, extend=extend.both)

// ═══════════════════════════════════════════════════════════════
// DATA WINDOW
// ═══════════════════════════════════════════════════════════════
plot(in_m ? mH : na, "Morning Resistance", col_R, display=display.data_window)
plot(in_m ? mL : na, "Morning Support",    col_S, display=display.data_window)
plot(in_e ? eH : na, "Evening Resistance", col_R, display=display.data_window)
plot(in_e ? eL : na, "Evening Support",    col_S, display=display.data_window)
plot(in_n ? nH : na, "Night Resistance",   col_R, display=display.data_window)
plot(in_n ? nL : na, "Night Support",      col_S, display=display.data_window)
````

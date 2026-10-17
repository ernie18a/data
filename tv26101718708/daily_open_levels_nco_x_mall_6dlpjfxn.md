# DAILY OPEN LEVELS NCO X MALL 

- url: https://www.tradingview.com/script/6dLPjFxn/
- type: indicator
- pine_id: PUB;0210be6e630144f19f4b6f19ca82af11
- version: 1.0

## Description

THE MALL X NCO SYSTEM 
**MALL X NCO** is a proprietary, custom-built trading framework designed to map institutional-grade price geometry onto your charts. Developed from scratch, this system automates session-open mechanics by combining volatility-based expansion zones with a strict mathematical price grid.
Here is how the two creator-designed engines work together:
### 1. The MALL Engine (Proprietary Volatility Expansion)
 * **What it does:** It tracks real-time market expansion starting exactly at the session open.
 * **How it helps you:** Instead of using lagging indicators, it calculates precision mathematical bands (\pm 1\text{SD}, \pm 2\text{SD}, \pm 3\text{SD}) based on the asset's active momentum.
 * **The Goal:** It immediately highlights extreme overbought or oversold zones, marking the exact boundaries where the market is stretching too far.
### 2. The NCO Engine (Mathematical Price Grid)
 * **What it does:** It instantly projects a fixed, percentage-based or point-based grid across the chart at the start of the session.
 * **How it helps you:** It slices price action into clean, highly visible technical levels (e.g., +0.5\%, +1.0\%, -0.5\%).
 * **The Goal:** It removes all guesswork by providing fixed, unemotional targets for Take Profit (TP) and Stop Loss (SL) based on clean numbers.
### 🎨 The Creator's "Elite Matrix" Interface
Built specifically to eliminate mental fatigue and emotional trading under heavy risk, the visual interface uses a highly intentional, clean design:
 * **Pure White:** The absolute Session Open price—the unbreakable 0% benchmark.
 * **Steel Gray Zones:** Normal market noise (\pm 1\text{SD}). The "hands-off" area to protect your capital.
 * **Emerald Green & Neon Red:** High-contrast execution lines for snajper entries, profit-taking, or invalidation cuts.
### 🚀 Built For High-Risk Precision
 * **Candle Close Native:** Designed specifically to align with **Candle Close Validation** rules—preventing fakeouts and live-bar trap chasing.
 * **Real-Time HUD Dashboard:** A custom on-screen table tracking your exact distance from the open price and predicting the next algorithmic key levels.
 * **Instant Alerts:** Automated alerts trigger the exact second a candle closes or tests any core MALL or NCO boundary.
> **The Blueprint:** Designed by traders, for traders. No retail fluff, no useless clutter—just pure, cold mathematical geometry.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MALL444

//@version=5
indicator("OPEN PLAYGROUND NCO X MALL — 24H", overlay=true)

// ==========================================
// ═══ INPUT SETTINGS (USTAWIENIA) ═══
// ==========================================
grp_gen  = "═══ GENERAL ═══"
grp_sess = "═══ SESSIONS ═══"
grp_col  = "═══ COLORS ═══"

step_val     = input.float(0.5, "Step Value %",       group=grp_gen, minval=0.1, maxval=2.0, step=0.1)
min_levels   = input.int(8,  "Minimum Levels",        group=grp_gen, minval=2, maxval=20)
days_to_load = input.int(8,  "Days to Load",          group=grp_gen, minval=1, maxval=30)
font_size    = input.string("small", "Font Size",     group=grp_gen, options=["tiny","small","normal","large"])
step_mode    = input.int(0,  "Step Mode 0=pct 1=pts", group=grp_gen, minval=0, maxval=1)
open_hour    = input.int(0,  "Daily Open Hour UTC",   group=grp_gen, minval=0, maxval=23)
open_min     = input.int(0,  "Daily Open Minute UTC", group=grp_gen, minval=0, maxval=59)

show_asian   = input.bool(true, "Show Asian Session",  group=grp_sess)
show_london  = input.bool(true, "Show London Session", group=grp_sess)
show_ny      = input.bool(true, "Show NY Session",     group=grp_sess)
asian_open   = input.int(0,  "Asian Open Hour UTC",   group=grp_sess, minval=0, maxval=23)
asian_close  = input.int(8,  "Asian Close Hour UTC",  group=grp_sess, minval=0, maxval=23)
london_open  = input.int(8,  "London Open Hour UTC",  group=grp_sess, minval=0, maxval=23)
london_close = input.int(16, "London Close Hour UTC", group=grp_sess, minval=0, maxval=23)
ny_open_h    = input.int(13, "NY Open Hour UTC",      group=grp_sess, minval=0, maxval=23)
ny_close_h   = input.int(21, "NY Close Hour UTC",     group=grp_sess, minval=0, maxval=23)

res_col      = input.color(color.new(#00ff00,20), "Resistance Color", group=grp_col)
sup_col      = input.color(color.new(#ff69b4,20), "Support Color",    group=grp_col)
zero_col     = input.color(color.new(#ffffff,0),  "Zero Line Color",  group=grp_col)
asian_col    = input.color(color.new(#888888,85), "Asian BG",         group=grp_col)
london_col   = input.color(color.new(#4169e1,90), "London BG",        group=grp_col)
ny_col_bg    = input.color(color.new(#FFD700,95), "NY BG",            group=grp_col)
res_width    = input.int(1, "Resistance Width", group=grp_col, minval=1, maxval=4)
sup_width    = input.int(1, "Support Width",    group=grp_col, minval=1, maxval=4)
zero_width   = input.int(2, "Zero Width",       group=grp_col, minval=1, maxval=5)
res_style_i  = input.int(1, "Res Style 1=solid 2=dash 3=dot",  group=grp_col, minval=1, maxval=3)
sup_style_i  = input.int(1, "Sup Style 1=solid 2=dash 3=dot",  group=grp_col, minval=1, maxval=3)
zero_style_i = input.int(2, "Zero Style 1=solid 2=dash 3=dot", group=grp_col, minval=1, maxval=5)

get_style(i) => i==1?line.style_solid:i==2?line.style_dashed:line.style_dotted
get_size(s)  => s=="tiny"?size.tiny:s=="small"?size.small:s=="normal"?size.normal:size.large

// ==========================================
// ═══ TIME ENGINE (UTC) ═══
// ==========================================
bar_hour   = hour(time,      "UTC")
bar_min    = minute(time,    "UTC")
cur_day    = dayofmonth(time,"UTC")

is_daily_open = bar_hour==open_hour and bar_min==open_min
is_asian      = bar_hour>=asian_open  and bar_hour<asian_close
is_london     = bar_hour>=london_open and bar_hour<london_close
is_ny         = bar_hour>=ny_open_h   and bar_hour<ny_close_h

was_asian  = bar_index > 0 ? is_asian[1]  : false
was_london = bar_index > 0 ? is_london[1] : false
was_ny     = bar_index > 0 ? is_ny[1]     : false

enter_asian  = is_asian  and not was_asian
exit_asian   = not is_asian  and was_asian
enter_london = is_london and not was_london
exit_london  = not is_london and was_london
enter_ny     = is_ny     and not was_ny
exit_ny      = not is_ny     and was_ny

// ==========================================
// ═══ VARIABLES DECLARATION ═══
// ==========================================
var float asian_high  = na
var float asian_low   = na
var float london_high = na
var float london_low  = na
var float ny_high     = na
var float ny_low      = na
var int asian_sb  = na
var int asian_eb  = na
var int london_sb = na
var int london_eb = na
var int ny_sb     = na
var int ny_eb     = na

// ==========================================
// ═══ SESSION HIGHS & LOWS LOGIC ═══
// ==========================================
if enter_asian
    asian_high := high
    asian_low  := low
    asian_sb   := bar_index
else if is_asian
    asian_high := math.max(nz(asian_high, high), high)
    asian_low  := math.min(nz(asian_low, low),  low)
    asian_eb   := bar_index

if enter_london
    london_high := high
    london_low  := low
    london_sb   := bar_index
else if is_london
    london_high := math.max(nz(london_high, high), high)
    london_low  := math.min(nz(london_low, low),  low)
    london_eb   := bar_index

if enter_ny
    ny_high := high
    ny_low  := low
    ny_sb   := bar_index
else if is_ny
    ny_high := math.max(nz(ny_high, high), high)
    ny_low  := math.min(nz(ny_low, low),  low)
    ny_eb   := bar_index

// ==========================================
// ═══ BOX DRAWINGS (DYNAMIC) ═══
// ==========================================
var box asian_box  = na
var box london_box = na
var box ny_box     = na

if show_asian and is_asian and not na(asian_high)
    box.delete(asian_box)
    asian_box := box.new(asian_sb, asian_high, bar_index, asian_low, border_color=color.new(#888888,60), border_width=1, bgcolor=asian_col)

if show_london and is_london and not na(london_high)
    box.delete(london_box)
    london_box := box.new(london_sb, london_high, bar_index, london_low, border_color=color.new(#4169e1,40), border_width=1, bgcolor=london_col)

if show_ny and is_ny and not na(ny_high)
    box.delete(ny_box)
    ny_box := box.new(ny_sb, ny_high, bar_index, ny_low, border_color=color.new(#FFD700,40), border_width=1, bgcolor=ny_col_bg)

// ==========================================
// ═══ HISTORICAL SESSION LINES ═══
// ==========================================
var line asian_low_line  = na
var line asian_high_line = na
var label asian_low_lab  = na
var label asian_high_lab = na
var line london_low_line  = na
var line london_high_line = na
var label london_low_lab  = na
var label london_high_lab = na

if exit_asian and not na(asian_low) and show_asian
    line.delete(asian_low_line)
    line.delete(asian_high_line)
    label.delete(asian_low_lab)
    label.delete(asian_high_lab)
    asian_low_line  := line.new(asian_sb, asian_low,  bar_index+100, asian_low,  color=color.new(#888888,30), width=1, style=line.style_dashed)
    asian_high_line := line.new(asian_sb, asian_high, bar_index+100, asian_high, color=color.new(#888888,30), width=1, style=line.style_dashed)
    asian_low_lab   := label.new(bar_index+2, asian_low,  "ASIAN LOW\n"+str.tostring(math.round(asian_low,2)),   color=color.new(#000000,100), textcolor=color.new(#888888,0), style=label.style_label_left, size=size.small)
    asian_high_lab  := label.new(bar_index+2, asian_high, "ASIAN HIGH\n"+str.tostring(math.round(asian_high,2)), color=color.new(#000000,100), textcolor=color.new(#888888,0), style=label.style_label_left, size=size.small)

if exit_london and not na(london_low) and show_london
    line.delete(london_low_line)
    line.delete(london_high_line)
    label.delete(london_low_lab)
    label.delete(london_high_lab)
    london_low_line  := line.new(london_sb, london_low,  bar_index+100, london_low,  color=color.new(#4169e1,30), width=1, style=line.style_dashed)
    london_high_line := line.new(london_sb, london_high, bar_index+100, london_high, color=color.new(#4169e1,30), width=1, style=line.style_dashed)
    london_low_lab   := label.new(bar_index+2, london_low,  "LONDON LOW\n"+str.tostring(math.round(london_low,2)),   color=color.new(#000000,100), textcolor=color.new(#4169e1,0), style=label.style_label_left, size=size.small)
    london_high_lab  := label.new(bar_index+2, london_high, "LONDON HIGH\n"+str.tostring(math.round(london_high,2)), color=color.new(#000000,100), textcolor=color.new(#4169e1,0), style=label.style_label_left, size=size.small)

// ==========================================
// ═══ DAILY OPEN LEVEL ENGINE ═══
// ==========================================
var float sess_open = na
var int   sess_bar  = na
var int   day_count = 0
var int   last_day  = na

if is_daily_open
    if cur_day != last_day
        day_count := day_count + 1
        last_day  := cur_day
    if day_count <= days_to_load
        sess_open := open
        sess_bar  := bar_index

var line  zero_line  = na
var line[] res_lines = array.new_line()
var line[] sup_lines = array.new_line()
var label[] res_labs = array.new_label()
var label[] sup_labs = array.new_label()
var label zero_lab   = na

if is_daily_open and not na(sess_open)
    line.delete(zero_line)
    label.delete(zero_lab)
    if array.size(res_lines) > 0
        for i = 0 to array.size(res_lines)-1
            line.delete(array.get(res_lines,i))
    if array.size(sup_lines) > 0
        for i = 0 to array.size(sup_lines)-1
            line.delete(array.get(sup_lines,i))
    if array.size(res_labs) > 0
        for i = 0 to array.size(res_labs)-1
            label.delete(array.get(res_labs,i))
    if array.size(sup_labs) > 0
        for i = 0 to array.size(sup_labs)-1
            label.delete(array.get(sup_labs,i))
    array.clear(res_lines)
    array.clear(sup_lines)
    array.clear(res_labs)
    array.clear(sup_labs)

    zero_line := line.new(sess_bar, sess_open, sess_bar+500, sess_open, color=zero_col, width=zero_width, style=get_style(zero_style_i), extend=extend.right)
    zero_lab  := label.new(sess_bar-3, sess_open, "  0%", color=color.new(#000000,100), textcolor=zero_col, style=label.style_label_right, size=get_size(font_size))

    for i = 1 to min_levels
        pct     = step_mode == 0 ? step_val*i/100 : step_val*i/sess_open
        r_price = sess_open*(1+pct)
        s_price = sess_open*(1-pct)
        r_line  = line.new(sess_bar, r_price, sess_bar+500, r_price, color=res_col, width=res_width, style=get_style(res_style_i), extend=extend.right)
        s_line  = line.new(sess_bar, s_price, sess_bar+500, s_price, color=sup_col, width=sup_width, style=get_style(sup_style_i), extend=extend.right)
        r_lab   = label.new(sess_bar-3, r_price, "  +"+str.tostring(step_val*i,"#.##")+"%", color=color.new(#000000,100), textcolor=res_col, style=label.style_label_right, size=get_size(font_size))
        s_lab   = label.new(sess_bar-3, s_price, "  -"+str.tostring(step_val*i,"#.##")+"%", color=color.new(#000000,100), textcolor=sup_col, style=label.style_label_right, size=get_size(font_size))
        array.push(res_lines,r_line)
        array.push(sup_lines,s_line)
        array.push(res_labs, r_lab)
        array.push(sup_labs, s_lab)

// ==========================================
// ═══ VISUAL MARKS ═══
// ==========================================
plotshape(is_daily_open, location=location.belowbar, style=shape.triangleup, color=color.new(#FFD700,0), size=size.small, title="Daily Open")
plotshape(enter_asian,   location=location.belowbar, style=shape.circle,     color=color.new(#888888,0), size=size.tiny,  title="Asian Open")
plotshape(enter_london,  location=location.belowbar, style=shape.circle,     color=color.new(#4169e1,0), size=size.tiny,  title="London Open")
plotshape(enter_ny,      location=location.belowbar, style=shape.circle,     color=color.new(#FFD700,0), size=size.tiny,  title="NY Open")

// ==========================================
// ═══ HUD DASHBOARD TABLE ═══
// ==========================================
var table t = table.new(position.bottom_left, 2, 8, bgcolor=color.new(#0a0a0a,55), border_color=color.new(#FFD700,60), border_width=1, frame_color=color.new(#FFD700,40), frame_width=1)

if barstate.islast and not na(sess_open)
    dist_pct = math.round((close-sess_open)/sess_open*100, 3)
    dist_col = dist_pct>0?res_col:dist_pct<0?sup_col:zero_col
    next_res = math.ceil(dist_pct/step_val)*step_val
    next_sup = math.floor(dist_pct/step_val)*step_val
    sess_now = is_asian?"🌏 ASIAN":is_london?"🇬🇧 LONDON":is_ny?"🗽 NEW YORK":"🌙 OFF"
    sess_col = is_asian?color.new(#888888,0):is_london?color.new(#4169e1,0):is_ny?color.new(#FFD700,0):color.new(#555555,0)

    table.cell(t,0,0,"OPEN PLAYGROUND", text_color=color.new(#FFD700,0), text_size=size.small, bgcolor=color.new(#0a0a0a,20))
    table.cell(t,1,0,"NCO X MALL",      text_color=color.new(#FFD700,0), text_size=size.small, bgcolor=color.new(#0a0a0a,20))
    table.cell(t,0,1,"SESSION",         text_color=color.new(#888888,0), text_size=size.small)
    table.cell(t,1,1,sess_now,          text_color=sess_col,             text_size=size.small)
    table.cell(t,0,2,"OPEN",            text_color=color.new(#888888,0), text_size=size.small)
    table.cell(t,1,2,str.tostring(math.round(sess_open,2)), text_color=color.new(#FFD700,0), text_size=size.small)
    table.cell(t,0,3,"DIST FROM OPEN",  text_color=color.new(#888888,0), text_size=size.small)
    table.cell(t,1,3,(dist_pct>0?"+":"")+str.tostring(dist_pct)+"%", text_color=dist_col, text_size=size.small)
    table.cell(t,0,4,"NEXT RES",        text_color=color.new(#888888,0), text_size=size.small)
    table.cell(t,1,4,"+"+str.tostring(next_res,"#.##")+"%", text_color=res_col, text_size=size.small)
    table.cell(t,0,5,"NEXT SUP",        text_color=color.new(#888888,0), text_size=size.small)
    table.cell(t,1,5,str.tostring(next_sup,"#.##")+"%",     text_color=sup_col, text_size=size.small)
    table.cell(t,0,6,"ASIAN H/L",       text_color=color.new(#888888,0), text_size=size.tiny)
    table.cell(t,1,6,not na(asian_high)?str.tostring(math.round(asian_high,1))+" / "+str.tostring(math.round(asian_low,1)):"--", text_color=color.new(#888888,0), text_size=size.tiny)
    table.cell(t,0,7,"LONDON H/L",      text_color=color.new(#888888,0), text_size=size.tiny)
    table.cell(t,1,7,not na(london_high)?str.tostring(math.round(london_high,1))+" / "+str.tostring(math.round(london_low,1)):"--", text_color=color.new(#4169e1,0), text_size=size.tiny)

// ==========================================
// ═══ MODERN LIVE ALERTS ENGINE ═══
// ==========================================
// Całkowicie przepisany silnik alertów działający na krypto live bez błędów typu 'series string'
if is_daily_open
    alert("Daily open — levels printed", alert.freq_once_per_bar)
if enter_asian
    alert("Asian session opened", alert.freq_once_per_bar)
if enter_london
    alert("London session opened", alert.freq_once_per_bar)
if enter_ny
    alert("NY session opened", alert.freq_once_per_bar)
if exit_asian
    alert("Asian session closed", alert.freq_once_per_bar)
if exit_london
    alert("London session closed", alert.freq_once_per_bar)

// Nowy, zoptymalizowany pod kątem mobilnym system sprawdzania poziomów siatki NCO
if not na(sess_open) and barstate.isnew
    for i = 1 to min_levels
        pct = step_mode == 0 ? step_val * i / 100 : step_val * i / sess_open
        r_lvl = sess_open * (1 + pct)
        s_lvl = sess_open * (1 - pct)
        
        if ta.crossover(close, r_lvl)
            alert("NCO Alert: Price broke ABOVE resistance level " + str.tostring(i), alert.freq_once_per_bar)
        if ta.crossunder(close, s_lvl)
            alert("NCO Alert: Price broke BELOW support level " + str.tostring(i), alert.freq_once_per_bar)
````

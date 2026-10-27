# Key Levels & Sessions

- url: https://www.tradingview.com/script/K2VO2alW-Key-Levels-Sessions/
- type: indicator
- pine_id: PUB;f2ed3c7c950a4c68a8293bac4b3a51e0
- version: 1.0

## Description

This is a professional-grade institutional key levels indicator designed for day traders who focus on session liquidity and high-volume price levels. The script provides a comprehensive view of the trading day by marking critical boundaries and institutional reference points, all strictly synchronized to the **America/New_York** (EST) timezone.

### **Key Features:**

#### **1. Institutional Daily Levels**
*   **Previous Day High (PDH) & Low (PDL):** Marked with solid purple lines, these represent the most basic yet powerful liquidity levels from the prior trading day.
*   **Previous Day Point of Control (POC):** A solid white line calculated using a Volume Profile algorithm. It identifies the price level where the most trading activity occurred during the previous session, acting as a "magnet" for price.

#### **2. Global Session Ranges**
*   **Asia Session (8:00 PM - 2:00 AM EST):** Plotted in orange. This captures the initial range of the global trading cycle.
*   **London Session (4:00 AM - 9:30 AM EST):** Plotted in blue. This identifies the volatility often seen during the European open leading into the New York session.

#### **3. New York 15-Minute Opening Range (ORB)**
*   **ORB Box:** Automatically captures the high and low of the first 15 minutes of the New York session (9:30 AM - 9:45 AM EST).
*   **Midline Projection:** Features a yellow dashed midline within the ORB box, a critical level often used by traders to determine intraday bias.

#### **4. Dynamic Projection & Cleanup**
*   **Extension to Market Close:** Once established, every level (Asia, London, ORB, and PD levels) automatically projects forward to the **5:00 PM EST market close**.
*   **Automatic Reset:** To keep your workspace clean and professional, the indicator utilizes an object-tracking system that deletes all drawings from the previous day at exactly 5:00 PM EST, allowing the chart to "reset" for the new Asia session.
*   **Right-Anchored Labels:** All levels are clearly labeled on the right side of the chart, ensuring identification is instant without interfering with live price action candles.

### **How to Use:**
This tool is best used on **lower timeframes (1m to 15m)**. Traders often look for price to react at these levels—either as support/resistance or as "liquidity grabs" where price sweeps a session high/low before reversing. The NY ORB box provides a clear breakout or mean-reversion zone for the morning trend.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Key Levels & Sessions", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// --- Constants & Inputs ---
string TZ = "America/New_York"

group_pd = "Previous Day Levels"
color_pd = input.color(color.rgb(156, 39, 176), "PD High/Low Color", group = group_pd)
color_poc = input.color(color.white, "PD POC Color", group = group_pd)

group_asia = "Asia Session (20:00 - 02:00)"
color_asia = input.color(#ff9800, "Asia Session Color", group = group_asia)

group_london = "London Session (04:00 - 09:30)"
color_london = input.color(#2196f3, "London Session Color", group = group_london)

group_ny = "NY ORB (09:30 - 09:45)"
color_ny = input.color(color.new(#5b9cf6, 80), "NY ORB Box Color", group = group_ny)
color_ny_border = input.color(#5b9cf6, "NY ORB Border Color", group = group_ny)
color_orb_mid = input.color(color.yellow, "ORB Midline Color", group = group_ny)

// --- Time Calculations ---
get_target_5pm() =>
    y = year(time, TZ)
    m = month(time, TZ)
    d = dayofmonth(time, TZ)
    h = hour(time, TZ)
    base_5pm = timestamp(TZ, y, m, d, 17, 0, 0)
    h >= 17 ? base_5pm + 86400000 : base_5pm

target_5pm = get_target_5pm()

// --- Object Tracking ---
var line[]  all_lines  = array.new_line()
var box[]   all_boxes  = array.new_box()
var label[] all_labels = array.new_label()

clear_drawings() =>
    if array.size(all_lines) > 0
        for l in all_lines
            line.delete(l)
        array.clear(all_lines)
    if array.size(all_boxes) > 0
        for b in all_boxes
            box.delete(b)
        array.clear(all_boxes)
    if array.size(all_labels) > 0
        for lb in all_labels
            label.delete(lb)
        array.clear(all_labels)

// --- Logic ---
is_cleanup_time = hour(time, TZ) == 17 and minute(time, TZ) == 0
if is_cleanup_time and not is_cleanup_time[1]
    clear_drawings()

is_asia   = not na(time(timeframe.period, "2000-0200:1234567", TZ))
is_london = not na(time(timeframe.period, "0400-0930:1234567", TZ))
is_ny_orb = not na(time(timeframe.period, "0930-0945:1234567", TZ))
is_active_day = not na(time(timeframe.period, "0000-1700:1234567", TZ))

ny_day_change = ta.change(dayofmonth(time, TZ)) != 0
is_new_day = ny_day_change

// POC Calculation
var float[] daily_prices = array.new_float()
var float[] daily_volumes = array.new_float()
var float prev_poc = na

if is_new_day
    if array.size(daily_volumes) > 0
        int max_idx = array.indexof(daily_volumes, array.max(daily_volumes))
        prev_poc := array.get(daily_prices, max_idx)
    array.clear(daily_prices)
    array.clear(daily_volumes)

if is_active_day
    array.push(daily_prices, hl2)
    array.push(daily_volumes, volume)

// Session Tracking
var float asia_h = na, var float asia_l = na
var float lon_h = na, var float lon_l = na
var float orb_h = na, var float orb_l = na

if is_asia
    asia_h := not is_asia[1] ? high : math.max(high, asia_h)
    asia_l := not is_asia[1] ? low : math.min(low, asia_l)

if is_london
    lon_h := not is_london[1] ? high : math.max(high, lon_h)
    lon_l := not is_london[1] ? low : math.min(low, lon_l)

if is_ny_orb
    orb_h := not is_ny_orb[1] ? high : math.max(high, orb_h)
    orb_l := not is_ny_orb[1] ? low : math.min(low, orb_l)

// --- Drawing Variables ---
var line l_pdh = na, var line l_pdl = na, var line l_poc = na
var line l_asia_h = na, var line l_asia_l = na
var line l_lon_h = na, var line l_lon_l = na
var line l_orb_mid = na
var box  b_orb = na

var label lb_pdh = na, var label lb_pdl = na, var label lb_poc = na
var label lb_asia_h = na, var label lb_asia_l = na
var label lb_london_h = na, var label lb_london_l = na
var label lb_orb_mid = na

// --- Drawing Logic ---
[s_pdh, s_pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)

// 1. PD Levels & POC (Labels on Right)
if is_new_day
    l_pdh := line.new(time, s_pdh, target_5pm, s_pdh, xloc = xloc.bar_time, color = color_pd, width = 2)
    l_pdl := line.new(time, s_pdl, target_5pm, s_pdl, xloc = xloc.bar_time, color = color_pd, width = 2)
    lb_pdh := label.new(target_5pm, s_pdh, "PDH", xloc = xloc.bar_time, color = #00000000, textcolor = color_pd, style = label.style_label_left, size = size.small)
    lb_pdl := label.new(target_5pm, s_pdl, "PDL", xloc = xloc.bar_time, color = #00000000, textcolor = color_pd, style = label.style_label_left, size = size.small)
    array.push(all_lines, l_pdh), array.push(all_lines, l_pdl)
    array.push(all_labels, lb_pdh), array.push(all_labels, lb_pdl)
    if not na(prev_poc)
        l_poc := line.new(time, prev_poc, target_5pm, prev_poc, xloc = xloc.bar_time, color = color_poc, width = 2)
        lb_poc := label.new(target_5pm, prev_poc, "POC", xloc = xloc.bar_time, color = #00000000, textcolor = color_poc, style = label.style_label_left, size = size.small)
        array.push(all_lines, l_poc), array.push(all_labels, lb_poc)

// 2. Asia (Labels on Right)
if is_asia and not is_asia[1]
    l_asia_h := line.new(time, asia_h, target_5pm, asia_h, xloc = xloc.bar_time, color = color_asia, width = 2)
    l_asia_l := line.new(time, asia_l, target_5pm, asia_l, xloc = xloc.bar_time, color = color_asia, width = 2)
    lb_asia_h := label.new(target_5pm, asia_h, "Asia High", xloc = xloc.bar_time, color = #00000000, textcolor = color_asia, style = label.style_label_left, size = size.small)
    lb_asia_l := label.new(target_5pm, asia_l, "Asia Low", xloc = xloc.bar_time, color = #00000000, textcolor = color_asia, style = label.style_label_left, size = size.small)
    array.push(all_lines, l_asia_h), array.push(all_lines, l_asia_l)
    array.push(all_labels, lb_asia_h), array.push(all_labels, lb_asia_l)

if not na(l_asia_h) and not is_cleanup_time
    line.set_y1(l_asia_h, asia_h), line.set_y2(l_asia_h, asia_h)
    line.set_y1(l_asia_l, asia_l), line.set_y2(l_asia_l, asia_l)
    label.set_y(lb_asia_h, asia_h), label.set_y(lb_asia_l, asia_l)

// 3. London (Labels on Right)
if is_london and not is_london[1]
    l_lon_h := line.new(time, lon_h, target_5pm, lon_h, xloc = xloc.bar_time, color = color_london, width = 2)
    l_lon_l := line.new(time, lon_l, target_5pm, lon_l, xloc = xloc.bar_time, color = color_london, width = 2)
    lb_london_h := label.new(target_5pm, lon_h, "London High", xloc = xloc.bar_time, color = #00000000, textcolor = color_london, style = label.style_label_left, size = size.small)
    lb_london_l := label.new(target_5pm, lon_l, "London Low", xloc = xloc.bar_time, color = #00000000, textcolor = color_london, style = label.style_label_left, size = size.small)
    array.push(all_lines, l_lon_h), array.push(all_lines, l_lon_l)
    array.push(all_labels, lb_london_h), array.push(all_labels, lb_london_l)

if not na(l_lon_h) and not is_cleanup_time
    line.set_y1(l_lon_h, lon_h), line.set_y2(l_lon_h, lon_h)
    line.set_y1(l_lon_l, lon_l), line.set_y2(l_lon_l, lon_l)
    label.set_y(lb_london_h, lon_h), label.set_y(lb_london_l, lon_l)

// 4. NY ORB (Labels on Right)
if is_ny_orb and not is_ny_orb[1]
    b_orb := box.new(time, orb_h, target_5pm, orb_l, xloc = xloc.bar_time, bgcolor = color_ny, border_color = color_ny_border)
    l_orb_mid := line.new(time, (orb_h + orb_l) / 2, target_5pm, (orb_h + orb_l) / 2, xloc = xloc.bar_time, color = color_orb_mid, style = line.style_dashed)
    lb_orb_mid := label.new(target_5pm, (orb_h + orb_l) / 2, "ORB Mid", xloc = xloc.bar_time, color = #00000000, textcolor = color_orb_mid, style = label.style_label_left, size = size.small)
    array.push(all_boxes, b_orb), array.push(all_lines, l_orb_mid), array.push(all_labels, lb_orb_mid)

if not na(b_orb) and not is_cleanup_time
    box.set_top(b_orb, orb_h), box.set_bottom(b_orb, orb_l)
    mid = (orb_h + orb_l) / 2
    line.set_y1(l_orb_mid, mid), line.set_y2(l_orb_mid, mid)
    label.set_y(lb_orb_mid, mid)
````

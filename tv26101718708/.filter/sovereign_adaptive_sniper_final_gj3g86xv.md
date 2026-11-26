# Sovereign - Adaptive Sniper Final

- url: https://www.tradingview.com/script/GJ3G86xV-Sovereign-Adaptive-Sniper-Final/
- type: indicator
- pine_id: PUB;aed823e7aa6947ee830e6aa2415d5fc2
- version: 1.0

## Description

The 15-Minute Opening Range Breakout (ORB) is a classic momentum strategy used by day traders to capture the initial volatility of the market open. This script identifies the high and low established during the first 15 minutes of the trading session and uses those levels as a "launchpad" for the day's trend

## Source Code

````pine
//@version=5
indicator("Sovereign - Adaptive Sniper Final", overlay=true, max_boxes_count=100, max_labels_count=100)

// --- 1. SETTINGS ---
startTime = input.session("0800-0815", "8:15 Zone Time (EST)")
endTime   = input.session("0800-1130", "Morning Window (EST)")
timeZone  = "America/New_York"

in_815_zone = not na(time(timeframe.period, startTime, timeZone))
is_930_open = hour(time, timeZone) == 9 and minute(time, timeZone) == 30
in_trading_window = not na(time(timeframe.period, endTime, timeZone))
new_day = ta.change(time("D"))

// --- 2. ZONE & VOLUME CAPTURE ---
var float hi = na
var float lo = na
var float zone_vol = 0.0
var box zone_box = na
var line mid_line = na

if in_815_zone
    if not in_815_zone[1]
        hi := high, lo := low, zone_vol := volume
        zone_box := box.new(bar_index, hi, bar_index, lo, bgcolor=color.new(color.yellow, 90), border_color=color.gray, border_style=line.style_dashed)
        mid_line := line.new(bar_index, (hi+lo)/2, bar_index, (hi+lo)/2, color=color.new(color.black, 40), style=line.style_dashed)
    else
        hi := math.max(high, hi), lo := math.min(low, lo), zone_vol += volume
        box.set_top(zone_box, hi), box.set_bottom(zone_box, lo), box.set_right(zone_box, bar_index)
        mid = (hi + lo) / 2
        line.set_y1(mid_line, mid), line.set_y2(mid_line, mid), line.set_x2(mid_line, bar_index)

if not in_815_zone and in_trading_window and not na(hi)
    box.set_right(zone_box, bar_index)
    line.set_x2(mid_line, bar_index)

// --- 3. RELIABLE VOLUME ANALYSIS ---
// We use a simple moving average of the cumulative zone volume
var float avg_vol_hist = 1.0 
if ta.change(in_815_zone) and not in_815_zone
    avg_vol_hist := ta.sma(zone_vol, 10)

// Avoid division by zero
rvol = zone_vol / (na(avg_vol_hist) or avg_vol_hist == 0 ? 1.0 : avg_vol_hist)

// Adaptive RR Logic
float dynamic_rr = rvol > 1.2 ? 4.0 : rvol < 0.8 ? 2.0 : 3.0

// --- 4. DIRECTIONAL MEMORY ---
var int last_dir = 0 
var bool signal_fired = false

if not in_815_zone and not is_930_open and in_trading_window
    if close > hi
        last_dir := 1
    if close < lo
        last_dir := -1

best_long  = is_930_open and last_dir == 1 and not signal_fired
best_short = is_930_open and last_dir == -1 and not signal_fired

// --- 5. TARGETS & LABELS ---
var float tp = na

if (best_long or best_short)
    signal_fired := true
    float sl_ref = best_long ? lo : hi
    float risk = math.abs(close - sl_ref)
    tp := best_long ? close + (risk * dynamic_rr) : close - (risk * dynamic_rr)
    
    label.new(bar_index, best_long ? low : high, 
         text = (best_long ? "LONG 1:" : "SHORT 1:") + str.tostring(dynamic_rr, "#"),
         color = best_long ? color.lime : color.fuchsia,
         textcolor = color.black,
         style = best_long ? label.style_label_up : label.style_label_down)

// Reset
if new_day or not in_trading_window
    signal_fired := false, last_dir := 0, hi := na, lo := na, tp := na

plot(tp, "Adaptive TP", color.lime, 2, plot.style_linebr)
barcolor(best_long ? color.lime : best_short ? color.fuchsia : na)
plotshape(best_long, "Long", shape.arrowup, location.belowbar, color.lime, size=size.large)
plotshape(best_short, "Short", shape.arrowdown, location.abovebar, color.fuchsia, size=size.large)
````

#  SMC S/R Zones

- url: https://www.tradingview.com/script/XClSmMkz-SMC-S-R-Zones/
- type: indicator
- pine_id: PUB;8dd26d5ae5654a5f95a2f8796827140b
- version: 1.0

## Description

SMC Support & Resistance Zones

Automatically detects high-probability Support and Resistance zones using Smart Money Concepts (SMC).

Features:
• Pivot-based swing high/low detection
• Intelligent clustering of nearby levels into clean zones
• Visual strength shown by number of touches
• Beautiful colored boxes that extend to the right
• Fully customizable (lookback, tolerance %, max zones)

Perfect for SMC / ICT traders, price action, and institutional-style trading. Works on all timeframes and markets (crypto, forex, stocks).

Enjoy!

## Source Code

````pine
//@version=6
indicator("🔥 SMC S/R Zones", shorttitle="SMC S/R", overlay=true, max_boxes_count=500, max_labels_count=500)

// ── Inputs
lookback       = input.int(5,   "Pivot Lookback",     minval=2,  maxval=20)
zone_tolerance = input.float(0.35, "Zone Tolerance (%)", minval=0.1, maxval=2.0, step=0.05) / 100
max_zones      = input.int(8,   "Max Zones",          minval=3,  maxval=15)
show_labels    = input.bool(true, "Show Labels")
show_touches   = input.bool(true, "Show Touch Count")

// ── Pivot Detection
ph = ta.pivothigh(high, lookback, lookback)
pl = ta.pivotlow(low,  lookback, lookback)

// Store pivots
var float[] pivotHighs = array.new_float()
var float[] pivotLows  = array.new_float()

if not na(ph)
    array.push(pivotHighs, ph)
if not na(pl)
    array.push(pivotLows, pl)

// Limit history
if array.size(pivotHighs) > 120
    array.shift(pivotHighs)
if array.size(pivotLows) > 120
    array.shift(pivotLows)

// ── Clustering
f_cluster(levels, tol) =>
    clusters = array.new_float()
    if array.size(levels) == 0
        clusters
    else
        sorted = array.copy(levels)
        array.sort(sorted)
        current = array.get(sorted, 0)
        count   = 1
        for i = 1 to array.size(sorted) - 1
            price = array.get(sorted, i)
            if math.abs(price - current) / current <= tol
                current := (current * count + price) / (count + 1)
                count += 1
            else
                array.push(clusters, current)
                current := price
                count := 1
        array.push(clusters, current)
        clusters

res_clusters = f_cluster(pivotHighs, zone_tolerance)
sup_clusters = f_cluster(pivotLows,  zone_tolerance)

// ── Boxes
var box[] resBoxes = array.new_box()
var box[] supBoxes = array.new_box()

if bar_index % 40 == 0
    for b in resBoxes
        box.delete(b)
    for b in supBoxes
        box.delete(b)
    array.clear(resBoxes)
    array.clear(supBoxes)

// Resistance Zones
for i = 0 to math.min(array.size(res_clusters) - 1, max_zones - 1)
    price = array.get(res_clusters, i)
    b = box.new(bar_index - 60, price * 1.003, bar_index + 30, price * 0.997, 
                border_color = #ff4444, border_width = 2, 
                bgcolor = color.new(#ff4444, 88), extend = extend.right)
    array.push(resBoxes, b)
    
    if show_labels
        label.new(bar_index + 20, price * 1.003, 
             text = "R" + (show_touches ? " ×" + str.tostring(i+1) : ""), 
             color = #ff4444, textcolor = color.white, size = size.small, style = label.style_label_left)

// Support Zones
for i = 0 to math.min(array.size(sup_clusters) - 1, max_zones - 1)
    price = array.get(sup_clusters, i)
    b = box.new(bar_index - 60, price * 1.003, bar_index + 30, price * 0.997, 
                border_color = #00ff88, border_width = 2, 
                bgcolor = color.new(#00ff88, 88), extend = extend.right)
    array.push(supBoxes, b)
    
    if show_labels
        label.new(bar_index + 20, price * 0.997, 
             text = "S" + (show_touches ? " ×" + str.tostring(i+1) : ""), 
             color = #00ff88, textcolor = color.white, size = size.small, style = label.style_label_left)
````

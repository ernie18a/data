# Volume Profile Lite

- url: https://www.tradingview.com/script/sv7z8PdY-Volume-Profile-Lite/
- type: indicator
- pine_id: PUB;e3a50586f8244790b4c90c3f00424306
- version: 1.0

## Description

Anchored VWAP + Volume Profile POC on any chart. See where institutions positioned. Free. Upgrade to Pro for Value Area (VAH/VAL) & info table.

Volume Profile Lite shows you where the big money traded. Anchored VWAP + Point of Control (POC) calculated in real time — no manual profiles needed.

• Anchored VWAP — the institutional benchmark for fair value
• Volume Profile POC — the price level with the most volume. Price gravitates here like a magnet
• Configurable lookback and resolution
• Works on all markets and timeframes (minimum 50 bars)
• Zero repaint — profile recalculated on bar close


Free version of Volume Profile Pro.
Upgrade for Value Area (VAH/VAL), full volume profile histogram, and real-time info table.

[b]Built by The Indicator Lab[/b] — theindicatorlab.com/lab-originals

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © glycdigital

//@version=6
indicator("Volume Profile Lite", "VP Lite", overlay=true, max_labels_count=50, max_bars_back=1000)

// ── The Indicator Lab — Volume Profile Lite (Free) ───────────────

vp_length = input.int(200, "Profile Lookback", minval=50, maxval=500)
vp_rows = input.int(30, "Resolution", minval=10, maxval=60)
show_vwap = input.bool(true, "Show Anchored VWAP")
show_poc = input.bool(true, "Show POC")

vwap_sum = 0.0
vol_sum = 0.0
vwap_value = 0.0

if bar_index > last_bar_index - vp_length
    typical = hlc3
    vwap_sum := vwap_sum[1] + typical * volume
    vol_sum := vol_sum[1] + volume

if vol_sum > 0
    vwap_value := vwap_sum / vol_sum

var float[] profile = array.new_float(vp_rows, 0.0)
var float poc_price = na

if barstate.islast
    float highest = high
    float lowest = low
    for i = 1 to vp_length - 1
        if high[i] > highest
            highest := high[i]
        if low[i] < lowest
            lowest := low[i]

    range_total = highest - lowest
    if range_total > 0
        array.fill(profile, 0.0, 0, vp_rows)
        for i = 0 to vp_length - 1
            price = hlc3[i]
            bar_vol = volume[i]
            row = int(math.floor((price - lowest) / range_total * (vp_rows - 1)))
            if row >= 0 and row < vp_rows
                array.set(profile, row, array.get(profile, row) + bar_vol)

        float max_vol = 0.0
        int max_row = 0
        for j = 0 to vp_rows - 1
            v = array.get(profile, j)
            if v > max_vol
                max_vol := v
                max_row := j

        poc_price := lowest + range_total * (max_row + 0.5) / vp_rows

        if show_poc
            line.new(bar_index + 2, poc_price, bar_index + 2, poc_price, xloc.bar_index, extend.none, color=color.yellow, width=3)
            label.new(bar_index + 3, poc_price, "POC " + str.tostring(poc_price, "#.##"), xloc.bar_index, yloc.price, color=color.new(color.yellow, 85), textcolor=color.yellow, style=label.style_label_left, size=size.tiny)

plot(bar_index > last_bar_index - vp_length ? vwap_value : na, "Anchored VWAP", color=color.new(color.blue, 70), linewidth=2)

if barstate.islast
    label.new(bar_index + 15, close, "⬆️ UPGRADE TO PRO\nValue Area (VAH/VAL) • Full Profile • Info Table\n→ theindicatorlab.com/lab-originals", xloc.bar_index, yloc.price, color=color.new(color.blue, 85), textcolor=color.white, style=label.style_label_center, size=size.normal)
````

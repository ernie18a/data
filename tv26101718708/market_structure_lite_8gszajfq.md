# Market Structure Lite

- url: https://www.tradingview.com/script/8GszajFQ-Market-Structure-Lite/
- type: indicator
- pine_id: PUB;abaca96c01a24a4bbd0c6839c141655d
- version: 1.0

## Description

Auto-detects BOS lines & CHOCH reversals on any chart. Free SMC/ICT market structure toolkit. Upgrade to Pro for alerts, order blocks & FVGs.

[b]Full:[/b]
Market Structure Lite shows you where the market is turning — automatically. Detects Break of Structure (BOS) lines and Change of Character (CHOCH) reversals in real time. No more manual markups.

• BOS lines — green for bullish breaks, red for bearish
• CHOCH labels — early reversal warnings
• Swing high/low markers (HH/LL)
• Zero repaint — all signals on bar close
• Works on all markets and timeframes

Free version of Market Structure Pro. Upgrade for Order Blocks, FVGs, Liquidity Sweeps, and phone alerts.

[b]Built by The Indicator Lab[/b] — theindicatorlab.com/lab-originals

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © glycdigital

//@version=6
indicator("Market Structure Lite", "MSS Lite", overlay=true, max_labels_count=50, max_lines_count=50, max_boxes_count=50, max_bars_back=500)

// ── The Indicator Lab — Market Structure Lite (Free) ─────────────

swing_length = input.int(20, "Swing Lookback", minval=5, maxval=100)

ph = ta.pivothigh(swing_length, swing_length)
pl = ta.pivotlow(swing_length, swing_length)

var float[] swing_highs = array.new_float(0)
var int[] swing_high_bars = array.new_int(0)
var float[] swing_lows = array.new_float(0)
var int[] swing_low_bars = array.new_int(0)

if not na(ph)
    array.push(swing_highs, ph)
    array.push(swing_high_bars, bar_index)
    if array.size(swing_highs) > 10
        array.shift(swing_highs)
        array.shift(swing_high_bars)

if not na(pl)
    array.push(swing_lows, pl)
    array.push(swing_low_bars, bar_index)
    if array.size(swing_lows) > 10
        array.shift(swing_lows)
        array.shift(swing_low_bars)

var float last_hh = na
var float last_lh = na
var float last_hl = na
var float last_ll = na

bos_up = false
bos_down = false
choch_up = false
choch_down = false

if array.size(swing_highs) >= 2
    prev_hh = array.get(swing_highs, array.size(swing_highs) - 2)
    curr_hh = array.get(swing_highs, array.size(swing_highs) - 1)
    if curr_hh > prev_hh
        bos_up := true
        last_hh := curr_hh
    else if curr_hh < prev_hh
        last_lh := curr_hh

if array.size(swing_lows) >= 2
    prev_ll = array.get(swing_lows, array.size(swing_lows) - 2)
    curr_ll = array.get(swing_lows, array.size(swing_lows) - 1)
    if curr_ll < prev_ll
        bos_down := true
        last_ll := curr_ll
    else if curr_ll > prev_ll
        last_hl := curr_ll

choch_down := not na(last_lh) and not na(last_hh) and last_lh == last_hh
choch_up := not na(last_hl) and not na(last_ll) and last_hl == last_ll

if bos_up and array.size(swing_highs) >= 2
    x1 = array.get(swing_high_bars, array.size(swing_high_bars) - 2)
    y1 = array.get(swing_highs, array.size(swing_highs) - 2)
    x2 = array.get(swing_high_bars, array.size(swing_high_bars) - 1)
    y2 = array.get(swing_highs, array.size(swing_highs) - 1)
    line.new(x1, y1, x2, y2, xloc.bar_index, extend.none, color=color.green, width=2)

if bos_down and array.size(swing_lows) >= 2
    x1 = array.get(swing_low_bars, array.size(swing_low_bars) - 2)
    y1 = array.get(swing_lows, array.size(swing_low_bars) - 2)
    x2 = array.get(swing_low_bars, array.size(swing_low_bars) - 1)
    y2 = array.get(swing_lows, array.size(swing_low_bars) - 1)
    line.new(x1, y1, x2, y2, xloc.bar_index, extend.none, color=color.red, width=2)

if choch_up
    label.new(bar_index, low, "CHOCH ▲", xloc.bar_index, yloc.price, color=color.new(color.green, 20), textcolor=color.green, style=label.style_label_up, size=size.small)

if choch_down
    label.new(bar_index, high, "CHOCH ▼", xloc.bar_index, yloc.price, color=color.new(color.red, 20), textcolor=color.red, style=label.style_label_down, size=size.small)

if not na(ph)
    label.new(bar_index, ph, "HH", xloc.bar_index, yloc.price, color=color.new(color.green, 60), textcolor=color.green, style=label.style_label_down, size=size.tiny)

if not na(pl)
    label.new(bar_index, pl, "LL", xloc.bar_index, yloc.price, color=color.new(color.red, 60), textcolor=color.red, style=label.style_label_up, size=size.tiny)

if barstate.islast
    label.new(bar_index + 10, close, "⬆️ UPGRADE TO PRO\nOrder Blocks • FVG • Sweeps • Alerts\n→ theindicatorlab.com/lab-originals", xloc.bar_index, yloc.price, color=color.new(color.blue, 85), textcolor=color.white, style=label.style_label_center, size=size.normal)
````

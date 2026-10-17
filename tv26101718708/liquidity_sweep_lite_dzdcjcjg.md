# Liquidity Sweep Lite

- url: https://www.tradingview.com/script/DzDcJcjg-Liquidity-Sweep-Lite/
- type: indicator
- pine_id: PUB;ffb0f25cd48a4fbca81aac0ca5537354
- version: 1.0

## Description

Detects equal highs/lows & liquidity sweeps in real time. Free. Stop hunt detection made visible. Upgrade to Pro for MSS, entry zones & alerts.


Liquidity Sweep Lite shows you where the stops are — before the market takes them. Detects equal highs (EQH), equal lows (EQL), and liquidity sweeps in real time.

• Equal Highs/Lows — auto-detected with configurable tolerance. These are where liquidity pools form
• Liquidity Sweeps — flags when price wicks through a level and closes back inside. Stop hunts made visible
• Visual markers — orange dashed lines at equal levels, green/red sweep labels
• Zero repaint — all detections on bar close
• Works on all markets and timeframes

Free version of Liquidity Sweep Pro. 
Upgrade for Market Structure Shift (MSS), auto entry zones with stop levels, and phone alerts.

[b]Built by The Indicator Lab[/b] — [pine]theindicatorlab.com/lab-originals[/pine]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © glycdigital

//@version=6
indicator("Liquidity Sweep Lite", "LIQ Lite", overlay=true, max_labels_count=50, max_lines_count=50, max_bars_back=500)

// ── The Indicator Lab — Liquidity Sweep Lite (Free) ──────────────

lookback = input.int(20, "Swing Lookback", minval=5, maxval=100)
eq_tolerance = input.float(0.05, "Equal Level Tolerance %", minval=0.01, maxval=1.0, step=0.01)

ph = ta.pivothigh(lookback, lookback)
pl = ta.pivotlow(lookback, lookback)

var float[] sw_highs = array.new_float(0)
var int[] sw_high_bars = array.new_int(0)
var float[] sw_lows = array.new_float(0)
var int[] sw_low_bars = array.new_int(0)

if not na(ph)
    array.push(sw_highs, ph)
    array.push(sw_high_bars, bar_index)
    if array.size(sw_highs) > 10
        array.shift(sw_highs)
        array.shift(sw_high_bars)

if not na(pl)
    array.push(sw_lows, pl)
    array.push(sw_low_bars, bar_index)

eq_high_detected = false
eq_low_detected = false
eq_high_level = 0.0
eq_low_level = 0.0

if array.size(sw_highs) >= 2
    h1 = array.get(sw_highs, array.size(sw_highs) - 1)
    h2 = array.get(sw_highs, array.size(sw_highs) - 2)
    b1 = array.get(sw_high_bars, array.size(sw_high_bars) - 1)
    b2 = array.get(sw_high_bars, array.size(sw_high_bars) - 2)
    diff = math.abs(h1 - h2) / h2 * 100
    if diff <= eq_tolerance and math.abs(b1 - b2) >= 3
        eq_high_detected := true
        eq_high_level := (h1 + h2) / 2

if array.size(sw_lows) >= 2
    l1 = array.get(sw_lows, array.size(sw_lows) - 1)
    l2 = array.get(sw_lows, array.size(sw_lows) - 2)
    b1 = array.get(sw_low_bars, array.size(sw_low_bars) - 1)
    b2 = array.get(sw_low_bars, array.size(sw_low_bars) - 2)
    diff = math.abs(l1 - l2) / l2 * 100
    if diff <= eq_tolerance and math.abs(b1 - b2) >= 3
        eq_low_detected := true
        eq_low_level := (l1 + l2) / 2

if eq_high_detected
    line.new(bar_index, eq_high_level, bar_index + 50, eq_high_level, xloc.bar_index, extend.none, color=color.orange, style=line.style_dashed, width=1)
    label.new(bar_index, eq_high_level, "EQH", xloc.bar_index, yloc.price, color=color.new(color.orange, 50), textcolor=color.orange, style=label.style_label_down, size=size.tiny)

if eq_low_detected
    line.new(bar_index, eq_low_level, bar_index + 50, eq_low_level, xloc.bar_index, extend.none, color=color.orange, style=line.style_dashed, width=1)
    label.new(bar_index, eq_low_level, "EQL", xloc.bar_index, yloc.price, color=color.new(color.orange, 50), textcolor=color.orange, style=label.style_label_up, size=size.tiny)

sweep_bull = false
sweep_bear = false

if eq_high_detected and high > eq_high_level and close[1] < eq_high_level
    sweep_bear := true

if eq_low_detected and low < eq_low_level and close[1] > eq_low_level
    sweep_bull := true

if sweep_bull
    label.new(bar_index, low, "SWEEP ▲", xloc.bar_index, yloc.price, color=color.new(color.green, 15), textcolor=color.green, style=label.style_label_up, size=size.small)

if sweep_bear
    label.new(bar_index, high, "SWEEP ▼", xloc.bar_index, yloc.price, color=color.new(color.red, 15), textcolor=color.red, style=label.style_label_down, size=size.small)

if barstate.islast
    label.new(bar_index + 10, close, "⬆️ UPGRADE TO PRO\nMSS • Entry Zones • Alerts\n→ theindicatorlab.com/lab-originals", xloc.bar_index, yloc.price, color=color.new(color.blue, 85), textcolor=color.white, style=label.style_label_center, size=size.normal)
````

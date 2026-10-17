# Wedge Maker Pro - Day Trade Edition

- url: https://www.tradingview.com/script/VAI3Jy3J-Wedge-Maker-Pro-Day-Trade-Edition/
- type: indicator
- pine_id: PUB;fd0ddf85358a4f4296578a1b5da506b2
- version: 1.0

## Description

Wedge Maker Pro [Day Trade Edition]
Overview
The Wedge Maker Pro is a high-precision trendline tool designed specifically for intraday traders who rely on price action and chart patterns. Unlike standard pivot indicators that look too far into the past, this script focuses on the most recent "swing highs" and "swing lows" to dynamically project wedge, pennant, and triangle patterns as they form.

In day trading, speed and clarity are everything. This indicator automates the manual process of drawing trendlines, ensuring you never miss a narrowing range or a critical breakout point.

Key Features
Adaptive Pivot Detection: Built with optimized defaults for the 1m, 5m, and 15m timeframes to capture relevant intraday structural shifts.

Dynamic Projections: Lines automatically extend to the right, creating a "kill zone" where price is expected to react or break out.

Customizable Sensitivity: Fine-tune the "Lookback Length" to filter out market noise or capture broader macro-wedges on higher timeframes.

Clean Visuals: Optimized for modern chart aesthetics with adjustable line widths and a native color picker to match any dark or light theme.

How to Trade with It
The Squeeze: Watch for the Upper and Lower lines to converge. This indicates a decrease in volatility and an imminent "explosive" move.

Breakout Confirmation: A candle closing outside of the wedge boundaries—especially on high relative volume—is a classic entry signal.

Trend Continuation: Use the lines as dynamic support and resistance. In a trending market, the "Lower Length" line often acts as a trailing support for long positions.

Optimized Settings for Day Traders
Scalping (1m - 3m): Set Pivot Length to 5.

Intraday (5m - 15m): Set Pivot Length to 10 (Default).

Swing Trading (1H+): Set Pivot Length to 20 or higher.

Note: This indicator uses confirmed pivots. Lines will update once the specified "Lookback Length" has passed to ensure the peak or valley is mathematically valid.
-

Pro-Tip 

Combine this with a Volume Oscillator or RSI. When the price breaks the **Wedge Maker** lines and is supported by a surge in volume, the probability of a successful trade increases significantly.


#Wedge #Trendline #Price Action #Breakout #Day Trading #Chart Patterns`

## Source Code

````pine
// © veryfid / Optimized for Day Trading
//@version=5
indicator("Wedge Maker Pro - Day Trade Edition", overlay=true, max_bars_back=5000)

// --- Optimized Inputs for Day Trading ---
// A length of 10 is more responsive for 5m/15m timeframes than the original 20.
grp_upper = "Upper Trendline Settings"
length    = input.int(10, "Upper Pivot Length", minval=2, group=grp_upper, tooltip="Lower values detect more frequent, tighter wedges. Higher values find macro trends.")
astart    = input.int(1, "Start From Pivot #", minval=0, group=grp_upper, tooltip="0 is the most recent pivot, 1 is the previous, etc.")
aend      = input.int(0, "End At Pivot #", minval=0, group=grp_upper)

grp_lower = "Lower Trendline Settings"
length2   = input.int(10, "Lower Pivot Length", minval=2, group=grp_lower)
bstart    = input.int(1, "Start From Pivot #", minval=0, group=grp_lower)
bend      = input.int(0, "End At Pivot #", minval=0, group=grp_lower)

grp_visual = "Visuals & Source"
csrc      = input.bool(false, "Use Custom Source (Close)?", group=grp_visual)
src_input = input.source(close, "Select Source:", group=grp_visual)
up_col    = input.color(color.red, "Upper Color", group=grp_visual)
dn_col    = input.color(color.green, "Lower Color", group=grp_visual)
lwidth    = input.int(2, "Line Width", minval=1, maxval=4, group=grp_visual)

// --- Logic ---
// Use High/Low for standard wedges, or Close for "Internal" trendlines
hi_src = csrc ? src_input : high
lo_src = csrc ? src_input : low

up_piv = ta.pivothigh(hi_src, length, length)
dn_piv = ta.pivotlow(lo_src, length2, length2)

// Capture bar indices and price levels
n = bar_index
a1_idx = ta.valuewhen(not na(up_piv), n, astart)
a1_val = ta.valuewhen(not na(up_piv), hi_src[length], astart)
a2_idx = ta.valuewhen(not na(up_piv), n, aend)
a2_val = ta.valuewhen(not na(up_piv), hi_src[length], aend)

b1_idx = ta.valuewhen(not na(dn_piv), n, bstart)
b1_val = ta.valuewhen(not na(dn_piv), lo_src[length2], bstart)
b2_idx = ta.valuewhen(not na(dn_piv), n, bend)
b2_val = ta.valuewhen(not na(dn_piv), lo_src[length2], bend)

// --- Plotting ---
var line upper_line = na
var line lower_line = na

if not na(a1_val) and not na(a2_val)
    line.delete(upper_line)
    upper_line := line.new(a1_idx - length, a1_val, a2_idx - length, a2_val, 
     extend=extend.right, color=up_col, width=lwidth)

if not na(b1_val) and not na(b2_val)
    line.delete(lower_line)
    lower_line := line.new(b1_idx - length2, b1_val, b2_idx - length2, b2_val, 
     extend=extend.right, color=dn_col, width=lwidth)
````

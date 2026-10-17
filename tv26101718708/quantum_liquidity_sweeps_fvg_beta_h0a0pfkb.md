# Quantum Liquidity Sweeps & FVG [BETA]

- url: https://www.tradingview.com/script/H0A0PfKb-Quantum-Liquidity-Sweeps-FVG-BETA/
- type: indicator
- pine_id: PUB;cd56e97589414f48a33d807a3a8592f6
- version: 1.0

## Description

This tool tracks institutional footprints, mapping unfilled Fair Value Gaps and major liquidity sweep zones. It is designed to visualize where Smart Money is accumulating positions.

Note: This is strictly the visual mapping tool. For traders managing serious capital who require the automated execution engine (MT5/NT8) that trades these zones algorithmically, check my profile bio for access to the core ecosystem.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © QuantumIntel

//@version=5
indicator("Quantum Liquidity Sweeps & FVG [BETA]", overlay=true, max_boxes_count=50, max_lines_count=50, max_labels_count=50)

// --- Institutional Settings ---
var GRP1 = "Quantum OrderFlow Settings"
show_fvg = input.bool(true, "Show Fair Value Gaps (Imbalance)", group=GRP1)
show_sweeps = input.bool(true, "Show Liquidity Sweeps", group=GRP1)

// --- Fair Value Gap (FVG) Logic ---
bull_fvg = low > high[2] and close[1] > high[2]
bear_fvg = high < low[2] and close[1] < low[2]

if show_fvg and bull_fvg
    box.new(bar_index[2], low, bar_index, high[2], bgcolor=color.new(color.blue, 85), border_color=color.blue, text="FVG", text_size=size.tiny)
    
if show_fvg and bear_fvg
    box.new(bar_index[2], low[2], bar_index, high, bgcolor=color.new(color.red, 85), border_color=color.red, text="FVG", text_size=size.tiny)

// --- Liquidity Sweeps (Fractal Pivot Logic) ---
ph = ta.pivothigh(leftbars=5, rightbars=5)
pl = ta.pivotlow(leftbars=5, rightbars=5)

if show_sweeps and not na(ph)
    line.new(bar_index[5], ph, bar_index, ph, color=color.red, style=line.style_dashed)
    label.new(bar_index, ph, "Buyside Liquidity", color=color.red, textcolor=color.white, style=label.style_label_down, size=size.tiny)

if show_sweeps and not na(pl)
    line.new(bar_index[5], pl, bar_index, pl, color=color.blue, style=line.style_dashed)
    label.new(bar_index, pl, "Sellside Liquidity", color=color.blue, textcolor=color.white, style=label.style_label_up, size=size.tiny)

// --- CTA / Watermark Invisível ---
var table watermark = table.new(position.bottom_right, 1, 1)
if barstate.islast
    table.cell(watermark, 0, 0, "Automated Execution: Link in Bio", text_color=color.gray, text_size=size.small)
````

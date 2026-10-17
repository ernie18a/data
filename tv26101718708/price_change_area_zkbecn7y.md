# Price change area

- url: https://www.tradingview.com/script/ZKbECn7Y-Price-change-area/
- type: indicator
- pine_id: PUB;6b43caacf5394086a5c9e5a90ca6ee4a
- version: 1.0

## Description

This indicator visualizes how much the price has changed over a configurable lookback period, displayed as a continuous area in a separate pane.
Features
	•	Two calculation modes:
	•	Exact % change – compares today’s close to the close exactly  y  bars ago.
	•	Max % change – shows the largest % move from an extreme (lowest or highest close) in the last  y  bars to today’s close.
	•	Configurable lookback: set the number of bars  y  (default: 30).
	•	Y-axis scale options:
	•	Ratio – displays values like  0.33 ,  -0.20  (i.e., +33%, −20%).
	•	Percent – displays values like  33.3 ,  -20.0 .
	•	Color-coded area:
	•	Green for positive change (price up over the lookback).
	•	Red for negative change (price down over the lookback).
	•	Zero line = no change.
How it works
	•	Uses closing prices only.
	•	For each bar, computes:
	•	Exact mode: 
	•	Max mode:
	•	Finds lowest and highest close in the last  y  bars.
	•	Calculates up and down ratios from those extremes to today’s close.
	•	Plots the one with the larger absolute deviation from 1.
	•	Plots  (ratio − 1)  (or  (ratio − 1) × 100  in Percent mode) as a filled area around the zero line.
Use cases
	•	Quickly spot strong up/down moves over a chosen period.
	•	Study historical volatility and momentum in terms of % change.
	•	Compare how different stocks or timeframes behave over similar lookback windows.
Inputs
	•	Lookback bars (y): number of bars to consider (default 30).
	•	Calculation Mode: “Exact % change” or “Max % change”.
	•	Y-Axis Scale: “Ratio” or “Percent”.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/

// Study: % change over y days – exact or max, shown as ratio or percent area
// Pine Script v6

//@version=6
indicator("Price Change Ratio/Percent (Exact or Max) – Area", overlay=false, max_bars_back=5000)

// === INPUTS ===
y = input.int(30, "Lookback bars (y)", minval=1)

modeInput = input.string(
    "Exact % change",
    "Calculation Mode",
    options=["Exact % change", "Max % change"]
)

scaleInput = input.string(
    "Ratio",
    "Y-Axis Scale",
    options=["Ratio", "Percent"]
)

// === CORE LOGIC ===
// We compute a "ratio" series:
//   ratio = close_now / close_reference
// where close_reference depends on mode.
// Then we plot:
//   - "Ratio"  => (ratio - 1)         -> e.g., 0.33, -0.20
//   - "Percent"=> (ratio - 1) * 100   -> e.g., 33.3, -20.0

// 1) Exact % change mode:
//    ratio = close[i] / close[i - y]
ref_close_exact = close[y]
ratio_exact = close / ref_close_exact

// 2) Max % change mode (Option B):
//    For each bar i:
//      lowest  = lowest close in [i-y+1 .. i]
//      highest = highest close in [i-y+1 .. i]
//    Up move ratio   = close[i] / lowest
//    Down move ratio = close[i] / highest
//    We take the one that gives the larger absolute deviation from 1.

lowest_close_y  = ta.lowest(close, y)
highest_close_y = ta.highest(close, y)

ratio_up_max   = close / lowest_close_y
ratio_down_max = close / highest_close_y

// Choose the one with larger absolute distance from 1
dev_up   = math.abs(ratio_up_max - 1)
dev_down = math.abs(ratio_down_max - 1)

ratio_max = dev_up >= dev_down ? ratio_up_max : ratio_down_max

// Select mode
ratio = modeInput == "Exact % change" ? ratio_exact : ratio_max

// Convert to "change" = ratio - 1
change_ratio = ratio - 1

// Apply scale: Ratio or Percent
change = scaleInput == "Percent" ? change_ratio * 100.0 : change_ratio

// === PLOTTING AS AREA ===
base = 0.0

// Color based on sign of change
area_color = change >= 0 ? color.new(color.green, 60) : color.new(color.red, 60)

// Plot the change series as area
plot(change, "Change", color=area_color, style=plot.style_area, linewidth=2)

// Base line at 0
hline(0, "Zero (no change)", color=color.new(color.gray, 70), linestyle=hline.style_dotted)

// Optional: make background slightly different for positive/negative
bgcolor(change >= 0 ? color.new(color.green, 95) : color.new(color.red, 95))
````

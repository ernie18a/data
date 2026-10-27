# CVD Simple vs Oscillator

- url: https://www.tradingview.com/script/Y1SXmvZP-CVD-Simple-vs-Oscillator/
- type: indicator
- pine_id: PUB;8ff067f2eb8948a69cc7f2d47948072e
- version: 1.0

## Description

## CVD Simple vs Oscillator

This indicator displays **two versions** of Cumulative Volume Delta side by side for easy comparison:

- **Simple CVD** (Orange): A basic volume delta calculation using close vs open.
- **Oscillator** (Aqua): An advanced, smoother version calculated using intrabar data via TradingView’s `requestVolumeDelta()` function.

### Key Features

- Dual CVD visualization (Simple + Advanced)
- Daily reset by default (resets at the start of each new day)
- Manual vertical scaling enabled (`scale = scale.none`) — drag the right-side scale to stretch the lines
- Clean zero line for easy reference
- Lightweight and easy to read

### How to Use

**Simple CVD (Orange)**  
A quick and basic representation of net buying vs selling pressure. It can appear spiky on high-volume bars.

**Oscillator (Aqua)**  
A more accurate and smoother representation of cumulative order flow. This is generally the better line to follow for analysis.

### How to Read the Indicator

- **Above zero** → Net buying pressure is dominant
- **Below zero** → Net selling pressure is dominant
- **Rising line** → Buyers are gaining control
- **Falling line** → Sellers are gaining control

### Recommended Usage

- Use the **Oscillator** (Aqua) line for better signals
- Best used on **15m to Daily** timeframes
- Works well for identifying **divergences** between price and volume pressure
- Combine with price action and key support/resistance levels

### Settings

- **Reset Period**: Choose how often the CVD resets (Default = Daily)
- You can manually stretch the vertical scale by dragging the numbers on the right side of the pane

### Notes

This indicator helps traders visualize the ongoing battle between buyers and sellers through cumulative volume delta. The Oscillator version provides a cleaner view compared to basic delta calculations.

## Source Code

````pine
//@version=6
indicator("CVD Simple vs Oscillator", shorttitle="CVD vs Osc", 
          overlay=false, scale=scale.right)

// ── Inputs ─────────────────────────────────────────────────────
resetTF = input.timeframe("D", "Reset Period")

// ── Simple CVD ─────────────────────────────────────────────────
var float simpleCVD = 0.0
simpleDelta = close > open ? volume : close < open ? -volume : 0

if ta.change(time(resetTF)) != 0
    simpleCVD := 0

simpleCVD := nz(simpleCVD[1]) + simpleDelta

// ── Oscillator (Previously Advanced CVD) ───────────────────────
import TradingView/ta/8 as ta
[_, _, _, oscillator] = ta.requestVolumeDelta("", resetTF)

// ── Plot ───────────────────────────────────────────────────────
plot(simpleCVD, "Simple CVD", color=color.new(color.orange, 0), linewidth=2)
plot(oscillator, "Oscillator", color=color.new(color.aqua, 0), linewidth=2)

hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dashed)
````

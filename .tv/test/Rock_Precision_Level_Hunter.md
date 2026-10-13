<!-- tradingview-pine-id: PUB;52da9bb6aa884be9b89429df420aa335 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Rock Precision - Level Hunter

Source: https://www.tradingview.com/script/qsYkkO5Z-Rock-Precision-Level-Hunter/

## Description

Rock Precision - Level Hunter is a clean, dynamic price action and volatility-based indicator designed to track market structure and identify directional shifts cleanly on your chart.

### 📊 How It Works & Color Logic:
This indicator utilizes a dynamic high-low range calculation combined with a mid-range baseline to analyze price action contextually:

• 🟢 Green Heatmap & Trend (Bullish / Buy Bias): When the price action trades above the baseline and upper/lower bands expand upward, the candles and structure lines turn Green. This visually signals bullish momentum, indicating favorable conditions for long bias or buying opportunities based on market structure support.

• 🟣 Fuchsia Heatmap & Trend (Bearish / Sell Bias): When the price action trades below the baseline and structure lines shift downward, the candles and channel lines turn Fuchsia. This highlights bearish market pressure, signaling potential sell-side momentum or continuation to the downside.

Designed for clean chart visualization without clutter, it helps traders easily read price action bias using intuitive color-coded candles and dynamic level channels.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Rock Precision - Level Hunter Indicator (Clean Version)

//@version=6
indicator("Rock Precision - Level Hunter", overlay=true)

// --- 1. Inputs ---
minLen = input.int(50, "Sensitivity Length")
m = input.float(2.0, "Range Width")

// --- 2. Core Logic ---
h = ta.highest(high, minLen)
l = ta.lowest(low, minLen)
mid = (h + l) / 2
b = (h - l) * (m / 100)
uLine = h - b
lLine = l + b

// --- 3. Trend Detection ---
upT = lLine > lLine[1] 
dnT = uLine < uLine[1] 
var int trend = 0 
if (upT)
    trend := 1
else if (dnT)
    trend := -1

lineCol = trend == 1 ? color.green : trend == -1 ? color.fuchsia : color.gray

// --- 4. Plotting Main Bands ---
p1 = plot(uLine, "Upper Band", color=lineCol, linewidth=2)
p2 = plot(lLine, "Lower Band", color=lineCol, linewidth=2)
plot(mid, "Baseline", color=close > mid ? color.green : color.fuchsia, linewidth=1, style=plot.style_linebr)
fill(p1, p2, trend == 1 ? color.new(color.green, 90) : color.new(color.fuchsia, 90))

// --- 5. Bar Colors (Clean Heatmap Only) ---
barcolor(close > mid ? color.new(color.green, 20) : color.new(color.fuchsia, 20))
````

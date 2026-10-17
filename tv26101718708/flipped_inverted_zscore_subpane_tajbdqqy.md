# Flipped Inverted Z-Score (Subpane)

- url: https://www.tradingview.com/script/TAJbdQQy-Flipped-Inverted-Z-Score-Subpane/
- type: indicator
- pine_id: PUB;85fc9afd9a274362983d426a1e39fdc0
- version: 1.0

## Description

[b]Flipped Inverted Z-Score (Subpane) Indicator [/b]

What It Does
This indicator measures how far an asset's current price deviates from its long-term average, expressed as a Z-Score — a statistical measure of standard deviations from the mean. 

The description "flipped inverted" means the score rises when price is above its long-term average (bullish territory) and falls when price is below it (bearish territory), making it intuitive to read at a glance. 

The indicator also highlights when an asset is overheated (orange) and when the asset has cooled off significantly (blue). Oftentimes when an asset is overheated investors are taking profit, and when an asset is oversold investors are accumulating. It's important though to note that an asset can be overbought or oversold for a long period of time (or may in fact never return to prior highs or lows). The z-score highlights bright green and bright red at extreme values, further enhancing these overbought and oversold areas.

The indicator occupies a separate subpane below your main chart, so it never clutters your price action.

[b]Core Calculations[/b]

Three values drive everything:
[list]
[*]1-Year Moving Average (MA) — the long-term baseline representing "fair value"
[*]Standard Deviation Proxy MA — a shorter MA used to normalize the deviation, making the score comparable across different assets and price ranges
[*]Flipped Z-Score — computed as -(1Y MA - Price) / Std Dev MA, so positive = price above fair value, negative = price below
[/list]

The Z-Score is dimensionless and asset-agnostic, meaning it works equally well on Bitcoin at $100k or a stock at $15. This normalization is the key benefit over a plain moving average crossover indicator.

[b]Visual Elements[/b]

Z-Score Line
The main line changes color dynamically:
[quote]
🟢 Lime — Strongly above threshold (bullish momentum)
🟩 Green — Mildly positive (above zero, below threshold)
🟥 Maroon — Mildly negative (below zero, above threshold)
🔴 Red — Strongly below threshold (bearish momentum)
[/quote]

Slow & Fast Moving Averages of the Z-Score
Two smoothed MAs are overlaid on the Z-Score line itself, helping filter noise and identify trend direction within the indicator. Both turn green above zero and red below zero.

Background Highlighting (Hot/Cold Zones)
An optional orange or blue background appears when conditions align for potentially overbought or oversold readings:
[quote]
🟠 Orange background — Z-Score is elevated, above both MAs, and exceeds the hot threshold → potential overbought/overheated zone
🔵 Blue background — Z-Score is depressed, below both MAs, and exceeds the cold threshold → potential oversold/undervalued zone
[/quote]

Crossover Dots (Optional Alerts)
Small colored dots mark moments when the Z-Score crosses above or below the Slow MA — useful as entry/exit signal triggers or for setting TradingView alerts.

Baseline Reference Line
A horizontal line at zero marks the dividing line between price being above or below long-term fair value. (Additional lines can be added to help as references. You may find that certain assets are less volatile, and therefore deviate less from the base reference line. This difference may also occur over time for example in the case of a new asset versus a more mature asset.)

[b]User-Configurable Settings[/b]

Setting Default — What It Controls 
[list]
[*]Price Source (Close) — Which OHLCV value drives the calculation
[*]1-Year MA Period (365 bars) — Long-term "fair value" baseline length
[*]Std Dev Proxy Period (150 bars) — Normalization window, shorter = more sensitive
[*]Z-Score Deviation Threshold (±SD) (0.50) — Where the line color flips from mild to strong
[*]Background Hot Threshold (0.34) — Minimum Z-Score to trigger orange background
[*]Background Cold Threshold (0.40) — Minimum Z-Score depth to trigger blue background
[*]Enable Background Highlighting (On) — Toggle hot/cold background on or off
[*]Show Horizontal Reference Lines (On) — Toggle the zero baseline line
[*]Show Z-Score Moving Averages (On) — Toggle the slow and fast MA lines
[*]Slow MA Period (50 bars) — Smoothing period for the trend-following MA
[*]Fast MA Period (3 bars) — Smoothing period for the responsive MA
[*]Show Crossover Dots (Off) — Toggle the MA crossover signal dots
[/list]

[b]Practical Use Cases[/b]

[list]
[*]Macro cycle positioning — on daily/weekly charts with default 365-bar settings, the score gives a birds-eye view of where an asset sits in its broader cycle, useful for sizing positions larger or smaller
[*]Overbought/oversold screening — orange and blue backgrounds highlight historically stretched conditions worth watching for reversals
[*]Trend confirmation — when the Z-Score, Slow MA, and Fast MA are all aligned on the same side of zero, it confirms the broader trend direction
[*]Cross-asset comparison — because the score is normalized, you can apply identical settings to BTC, ETH, SPY, or any stock and compare readings directly
[*]Alert triggers — crossover dots (when enabled) give discrete signal events you can attach TradingView alerts to, removing the need to watch the chart constantly
[/list]

[b]Tips for Tuning[/b]

[list]
[*]Shorter timeframes (1H, 4H): consider reducing the 1-Year MA period and Std Dev period proportionally, and uncomment the threshold lines in the source code for finer visual guidance
[*]More sensitive signals: lower the Fast MA period toward 1–2 and tighten the deviation threshold
[*]Reduce noise: raise the Slow MA period and increase the hot/cold thresholds so backgrounds only appear during truly extreme readings
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © chillcrypto
//@version=6
indicator("Flipped Inverted Z-Score (Subpane)", overlay=false, max_lines_count=500)

//───────────────────────────────
// USER INPUTS
// These variables are available for your manipulation. 
//───────────────────────────────
price_src = input.source(close, title="Price Source")
ma_1y_len = input.int(365, minval=1, title="1-Year MA Period")
ma_std_len = input.int(150, minval=1, title="Standard Deviation Proxy Period")
highlight_sd = input.float(0.50, step=0.01, title="Z-Score Deviation Threshold (±SD)")
z_thresh_h = input.float(.34, step=0.1, title="Background Hot Highlight Threshold")
z_thresh_l = input.float(.40, step=0.1, title="Background Cold Highlight Threshold")
show_bgcolor = input.bool(true, title="Enable Background Hot/Cold Highlight")
show_hlines = input.bool(true, title="Show Horizontal Reference Lines")
show_ma = input.bool(true, title="Show Z-Score Moving Averages")
ma_length = input.int(50, minval=1, title="Z-Score Slow Moving Average Period")
ma_length_fast = input.int(3, minval=1, title="Z-Score Fast Moving Average Period")
show_crossover_dots = input.bool(false, title="Show Z-Score MA Crossover Dots - Alerts")

//───────────────────────────────
// Z-SCORE CALCULATION
//───────────────────────────────
ma_1y = ta.sma(price_src, ma_1y_len)
ma_std = ta.sma(price_src, ma_std_len)

// Calculate inverted z-score and flip it
inverted = (ma_1y - price_src) / ma_std
flipped_z = -1 * inverted

//───────────────────────────────
// COLORING LOGIC
//───────────────────────────────
z_color = flipped_z > highlight_sd ? color.lime :
          flipped_z < -highlight_sd ? color.red :
          flipped_z >= 0 ? color.green : color.maroon

//───────────────────────────────
// MOVING AVERAGE OF Z-SCORE (Background Layer - Plotted First)
//───────────────────────────────
z_ma = ta.sma(flipped_z, ma_length)
z_ma_f = ta.sma(flipped_z, ma_length_fast)
ma_color = z_ma >= 0 ? color.green : color.red
plot(show_ma ? z_ma : na, title="Z-Score Slow Moving Average", color=ma_color, linewidth=1, style=plot.style_line)
plot(show_ma ? z_ma_f : na, title="Z-Score Fast Moving Average", color=ma_color, linewidth=1, style=plot.style_line)

//───────────────────────────────
// MAIN PLOT - Z-Score Line (Foreground Layer - Plotted Second)
//───────────────────────────────
plot(flipped_z, title="Flipped Z-Score", color=z_color, linewidth=2)

//───────────────────────────────
// CROSSOVER DOTS - Z-Score crossing MA (used for alerts, off by default)
//───────────────────────────────
z_above_ma = flipped_z > z_ma
z_was_above_ma = flipped_z[1] > z_ma[1]

z_crosses_above = z_above_ma and not z_was_above_ma
z_crosses_below = not z_above_ma and z_was_above_ma

plotshape(show_crossover_dots and z_crosses_above ? flipped_z : na, 
          title="Bullish Cross", style=shape.circle, location=location.absolute, 
          color=color.new(color.green, 0), size=size.tiny)

plotshape(show_crossover_dots and z_crosses_below ? flipped_z : na, 
          title="Bearish Cross", style=shape.circle, location=location.absolute, 
          color=color.new(color.red, 0), size=size.tiny)

//───────────────────────────────
// HORIZONTAL REFERENCE LINES
// Some of the lines here have been disabled but may be enabled for shorter timeframe analysis.
//───────────────────────────────
plot(show_hlines ? 0 : na, "Z-Score Baseline", color=color.new(color.gray, 50), linewidth=1)
//plot(show_hlines ? highlight_sd : na, "+Threshold", color=color.new(color.green, 70), linewidth=1, style=plot.style_circles)
//plot(show_hlines ? -highlight_sd : na, "−Threshold", color=color.new(color.red, 70), linewidth=1, style=plot.style_circles)
//plot(show_hlines ? z_thresh : na, "+BG Threshold", color=color.new(color.orange, 80), linewidth=1, style=plot.style_cross)
//plot(show_hlines ? -z_thresh : na, "−BG Threshold", color=color.new(color.blue, 80), linewidth=1, style=plot.style_cross)

//───────────────────────────────
// BACKGROUND HIGHLIGHTING - Hot/Cold Indicator for areas that are potentially overbought or oversold
//───────────────────────────────
// Only show background when z-score is above/below MA and exceeds threshold
bg_col = show_bgcolor and flipped_z > z_thresh_h and flipped_z > z_ma and flipped_z > z_ma_f ? color.new(color.orange, 85) :
         show_bgcolor and flipped_z < -z_thresh_l and flipped_z < z_ma and flipped_z < z_ma_f ? color.new(color.blue, 85) :
         na
bgcolor(bg_col, title="Background Hot/Cold")
````

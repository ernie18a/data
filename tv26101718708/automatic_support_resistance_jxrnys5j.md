# Automatic Support & Resistance

- url: https://www.tradingview.com/script/JXrNys5J-Automatic-Support-Resistance/
- type: indicator
- pine_id: PUB;63829918577d4394b5bd3be8ea3c52cb
- version: 1.0

## Description

[b]1. Overview[/b]
This is an automatic Support and Resistance (S/R) level detector for TradingView. It identifies significant price pivots (peaks and troughs) based on user-defined settings and plots up to 8 dynamic levels on your chart.

The script is intended for educational and informational purposes to demonstrate automatic S/R detection using pivot points and to help traders identify potential areas of interest.

[b]2. Key Logic & Features[/b]
A. Pivot Detection

The script detects price pivots (local highs and lows) using ta.pivothigh() and ta.pivotlow().

Two detection speeds:

Regular Pivots: Use the Right Bars setting to define the confirmation period.

Quick Pivots: Use the Quick Right setting for more sensitive, faster-moving levels.

Source Selection: Choose between using Close price or High/Low values for detection.

B. Level Hierarchy
The script plots eight levels, organized as:

Resistance Levels (Red/Green): Levels 1, 3, 5, 7 (top 4 lines).

Support Levels (Red/Green): Levels 2, 4, 6, 8 (bottom 4 lines).

C. Visual Customization (NEW)

Line Styles: Independently set the style for Resistance and Support lines:

Solid (default for both)

Dotted (uses plot.style_circles)

Dashed (uses plot.style_stepline)

Color Logic: Each level dynamically changes color:

Green: Current close price is above the level (bullish context).

Red: Current close price is below the level (bearish context).

D. Additional Features

show_last=1: Only the most recent segment of each level is shown, keeping the chart clean.

trackprice=true: Extends the line horizontally to the right edge of the chart for easy reference.

[b]3. User Inputs (Customization)[/b]
Input	Description	Default
Left Bars	Number of bars to the left of a pivot.	50
Right Bars	Number of bars to the right of a pivot (confirmation).	25
Quick Right	Faster confirmation period for quick pivots.	5
Source	Use Close or High/Low for pivot detection.	Close
Resistance Line Style	Style for top (resistance) levels.	Solid
Support Line Style	Style for bottom (support) levels.	Solid

[b]4. How to Use[/b]
Add the script to any chart.

Adjust Pivot Sensitivity:

Increase Left Bars and Right Bars for longer-term, stronger S/R levels.

Decrease them for more, shorter-term levels.

Use Quick Right to add a more sensitive, faster-responding layer.

Interpret the Levels:

Resistance (top lines): Price may face selling pressure when approaching these levels from below.

Support (bottom lines): Price may find buying pressure when approaching these levels from above.

Green level: Price is currently trading above that level (potentially acting as support).

Red level: Price is currently trading below that level (potentially acting as resistance).

Combine with other tools: Use this as one component of a complete trading strategy, alongside trend indicators, candlestick patterns, or volume analysis.

[b]5. Compliance & Transparency[/b]
No Financial Advice: This script is strictly for educational and informational purposes. It does not provide financial advice, trading recommendations, or guaranteed results. All trading decisions are your own responsibility.

Original Work: The code is the original work of the author, based on standard Pine Script pivot functions (ta.pivothigh, ta.pivotlow). It is published under the Mozilla Public License 2.0.

No Guarantee: The accuracy, reliability, or profitability of the detected S/R levels is not guaranteed. Different market conditions may require different parameter adjustments.

[b]6. Technical Notes & Limitations[/b]
Version: Converted to Pine Script v6 for optimal performance and future compatibility.

Repainting: Pivot-based levels are [b]non-repainting[/b] by nature (ta.pivothigh/low only confirms after the right bars have passed). However, the dynamic coloring reacts to each new bar's close.

Performance: The script is lightweight and runs efficiently on most charts.

[b]7. Credits & Open Source[/b]
This script is published under the Mozilla Public License 2.0. You are free to use, modify, and share this code for non-commercial purposes, provided you retain the original license and attribution. No private keys, external dependencies, or hidden functions are included.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © nasalgotrading

//@version=5
indicator('Automatic Support & Resistance', shorttitle='NASAlgoTrading Auto S/R', overlay=true)

left = input(defval=50, title='Left Bars')
right = input(defval=25, title='Right Bars')
quick_right = input(defval=5, title='Quick Right')
src = input.string(defval='Close', options=['Close', 'High/Low'], title='Source')


pivothigh_1 = ta.pivothigh(close, left, right)
pivothigh_2 = ta.pivothigh(high, left, right)
pivot_high = src == 'Close' ? pivothigh_1 : pivothigh_2
pivotlow_1 = ta.pivotlow(close, left, right)
pivotlow_2 = ta.pivotlow(low, left, right)
pivot_lows = src == 'Close' ? pivotlow_1 : pivotlow_2

pivothigh_3 = ta.pivothigh(close, left, quick_right)
pivothigh_4 = ta.pivothigh(high, left, quick_right)
quick_pivot_high = src == 'Close' ? pivothigh_3 : pivothigh_4
pivotlow_3 = ta.pivotlow(close, left, quick_right)
pivotlow_4 = ta.pivotlow(low, left, quick_right)
quick_pivot_lows = src == 'Close' ? pivotlow_3 : pivotlow_4

valuewhen_1 = ta.valuewhen(quick_pivot_high, close[quick_right], 0)
valuewhen_2 = ta.valuewhen(quick_pivot_high, high[quick_right], 0)
level1 = src == 'Close' ? valuewhen_1 : valuewhen_2
valuewhen_3 = ta.valuewhen(quick_pivot_lows, close[quick_right], 0)
valuewhen_4 = ta.valuewhen(quick_pivot_lows, low[quick_right], 0)
level2 = src == 'Close' ? valuewhen_3 : valuewhen_4
valuewhen_5 = ta.valuewhen(pivot_high, close[right], 0)
valuewhen_6 = ta.valuewhen(pivot_high, high[right], 0)
level3 = src == 'Close' ? valuewhen_5 : valuewhen_6
valuewhen_7 = ta.valuewhen(pivot_lows, close[right], 0)
valuewhen_8 = ta.valuewhen(pivot_lows, low[right], 0)
level4 = src == 'Close' ? valuewhen_7 : valuewhen_8
valuewhen_9 = ta.valuewhen(pivot_high, close[right], 1)
valuewhen_10 = ta.valuewhen(pivot_high, high[right], 1)
level5 = src == 'Close' ? valuewhen_9 : valuewhen_10
valuewhen_11 = ta.valuewhen(pivot_lows, close[right], 1)
valuewhen_12 = ta.valuewhen(pivot_lows, low[right], 1)
level6 = src == 'Close' ? valuewhen_11 : valuewhen_12
valuewhen_13 = ta.valuewhen(pivot_high, close[right], 2)
valuewhen_14 = ta.valuewhen(pivot_high, high[right], 2)
level7 = src == 'Close' ? valuewhen_13 : valuewhen_14
valuewhen_15 = ta.valuewhen(pivot_lows, close[right], 2)
valuewhen_16 = ta.valuewhen(pivot_lows, low[right], 2)
level8 = src == 'Close' ? valuewhen_15 : valuewhen_16

level1_col = close >= level1 ? color.green : color.red
level2_col = close >= level2 ? color.green : color.red
level3_col = close >= level3 ? color.green : color.red
level4_col = close >= level4 ? color.green : color.red
level5_col = close >= level5 ? color.green : color.red
level6_col = close >= level6 ? color.green : color.red
level7_col = close >= level7 ? color.green : color.red
level8_col = close >= level8 ? color.green : color.red

plot(level1, style=plot.style_line, color=level1_col, show_last=1, linewidth=2, trackprice=true)
plot(level2, style=plot.style_line, color=level2_col, show_last=1, linewidth=2, trackprice=true)
plot(level3, style=plot.style_line, color=level3_col, show_last=1, linewidth=2, trackprice=true)
plot(level4, style=plot.style_line, color=level4_col, show_last=1, linewidth=2, trackprice=true)
plot(level5, style=plot.style_line, color=level5_col, show_last=1, linewidth=2, trackprice=true)
plot(level6, style=plot.style_line, color=level6_col, show_last=1, linewidth=2, trackprice=true)
plot(level7, style=plot.style_line, color=level7_col, show_last=1, linewidth=2, trackprice=true)
plot(level8, style=plot.style_line, color=level8_col, show_last=1, linewidth=2, trackprice=true)
````

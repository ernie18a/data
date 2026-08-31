<!-- tradingview-pine-id: PUB;b561ac4b0cde418a8867032604f4d41d -->
<!-- tradingviewscripts-format: 1 -->
# Volumatic Support/Resistance Levels [BigBeluga]

Source: https://www.tradingview.com/script/F2OH2WQT-Volumatic-Support-Resistance-Levels-BigBeluga/

## Description

🔵 OVERVIEW
A smart volume-powered tool for identifying key support and resistance zones—enhanced with real-time volume histogram fills and high-volume markers.

Volumatic Support/Resistance Levels [BigBeluga] detects structural levels from swing highs and lows, and wraps them in dynamic histograms that reflect the relative volume strength around those zones. It highlights the strongest price levels not just by structure—but by the weight of market participation.

🔵 CONCEPTS

[*] Price Zones: Support and resistance levels are drawn from recent price pivots, while volume is used to visually enhance these zones with filled histograms and highlight moments of peak activity using markers.
[*] Histogram Fill = Activity Zone: The width and intensity of each filled zone adjusts to recent volume bursts.
[*] High-Volume Alerts: Circle markers highlight moments of volume dominance directly on the levels—revealing pressure points of support/resistance.
[*] Clean Visual Encoding: Red = resistance zones, green = support zones, orange = high-volume bars.

🔵 FEATURES

[*] Detects pivot-based resistance (highs) and support (lows) using a customizable range length.
[image]https://www.tradingview.com/x/xWyy68Ty/[/image]
[*] Wraps these levels in volume-weighted bands that expand/contract based on percentile volume.
[*] Color fill intensity increases with rising volume pressure, creating a live histogram feel.
[image]https://www.tradingview.com/x/y4PUySNt/[/image]
[*] When volume > user-defined threshold, the indicator adds circle markers at the top and bottom of that price level zone.
[image]https://www.tradingview.com/x/0Eu01pjT/[/image]
[*] Bar coloring highlights the candles that generated this high-volume behavior (orange by default).
[image]https://www.tradingview.com/x/1ffyjyKW/[/image]
[*] Adjustable settings for all thresholds and colors, so traders can dial in volume sensitivity.

🔵 HOW TO USE

[*] Identify volume-confirmed resistance and support zones for potential reversal or breakout setups.
[*] Focus on levels with intense histogram fill and circle markers—they indicate strong participation.
[*] Use bar coloring to track when key activity started and align it with broader market context.
[*] Works well in combination with order blocks, trend indicators, or liquidity zones.
[*] Ideal for day traders, scalpers, and volume-sensitive setups.

🔵 CONCLUSION
Volumatic Support/Resistance Levels [BigBeluga] elevates traditional support and resistance logic by anchoring it in volume context. Instead of relying solely on price action, it gives traders insight into where real conviction lies—by mapping how aggressively the market defended or rejected key levels. It's a visual, reactive, and volume-conscious upgrade to your structural toolkit.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Volumatic Support/Resistance Levels [BigBeluga]", overlay = true)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

length = input.int(25, "Length")
upper_threshold = input.int(80, "Resistance Max Volume %", maxval = 100, minval = 50, inline = "sup"), sup_col = input.color(color.rgb(28, 194, 114), "", inline = "sup")
lower_threshold = input.int(80, "Support Max Volume %", maxval = 100, minval = 50, inline = "res"), res_col = input.color(color.rgb(206, 37, 37), "", inline = "res")
bars_threshold = input.int(50, "Bars Max Volume %", maxval = 100, minval = 50, inline = "bar"), bar_col = input.color(color.rgb(255, 145, 55), "", inline = "bar")


var upper1 = float(na)
var upper2 = float(na)
var lower1 = float(na)
var lower2 = float(na)
// }


// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

h = ta.highest(length)
l = ta.lowest(length)

n_vol = volume / ta.percentile_linear_interpolation(volume, 500, 100)*100

if h[1] == high[1] and high < h 
    upper1 := h 
    upper2 := h 

if l[1] == low[1] and low > l 
    lower1 := l 
    lower2 := l 

atr = ta.atr(200) / 100
upper_col = upper1 != upper1[1] ? color(na) : res_col 
lower_col = lower1 != lower1[1] ? color(na) : sup_col
// }


// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

plot(upper1, "Resistance", color = upper_col)
ph1 = plot(upper1 + atr*n_vol, color = na, editable = false)
ph2 = plot(upper2 - atr*n_vol, color = na, editable = false)

upper_fill = upper1 != upper1[1] ? na : color.from_gradient(n_vol, 0, 100, color.new(res_col, 80), res_col)

fill(ph1, ph2, upper_fill)

plot(lower1, "Support", color = lower_col)
pl1 = plot(lower2 + atr*n_vol, color = na, editable = false)
pl2 = plot(lower2 - atr*n_vol, color = na, editable = false)

lower_fill = lower1 != lower1[1] ? na : color.from_gradient(n_vol, 0, 100, color.new(sup_col, 80), sup_col)

fill(pl1, pl2, lower_fill)

plotshape(n_vol > lower_threshold ? lower2 - atr*n_vol : float(na), "Max Volume Support", shape.circle, location.absolute, color = sup_col, size = size.tiny)
plotshape(n_vol > lower_threshold ? lower2 + atr*n_vol : float(na), "Max Volume Support", shape.circle, location.absolute, color = sup_col, size = size.tiny)

plotshape(n_vol > upper_threshold ? upper2 + atr*n_vol : float(na), "Max Volume Resistance", shape.circle, location.absolute, color = res_col, size = size.tiny)
plotshape(n_vol > upper_threshold ? upper2 - atr*n_vol : float(na), "Max Volume Resistance", shape.circle, location.absolute, color = res_col, size = size.tiny)

barcolor(n_vol > bars_threshold ? bar_col : na)
// }
````

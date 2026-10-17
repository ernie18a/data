# Vector Confluence Oscillator

- url: https://www.tradingview.com/script/YfljwmEo-Vector-Confluence-Oscillator/
- type: indicator
- pine_id: PUB;ccd528a167624c678997eadb4c56be4e
- version: 1.0

## Description

The Vector Confluence Oscillator is a high-precision market terminal designed to identify the exact intersection of Price Deviation and Momentum Exhaustion.

Unlike standard oscillators that only track velocity, the Vector Confluence system maps price action against its statistical mean, allowing traders to see when the market is "stretched" both in terms of value and momentum.

[b]Core Functionality[/b]
This indicator operates on two primary data vectors to find high-probability reversal zones:

Vector A: Statistical Price Deviation The background turns Red (Overvalued) or Blue (Undervalued) based on Standard Deviation bands. This highlights when price has moved too far, too fast from its average.

Vector B: Momentum Velocity (RSI) The internal "Momentum Cloud" and dynamic oscillator line track the internal strength of the move. When the cloud flips from Green (Bullish) to Red (Bearish), it signals a shift in the trend's power.

[b]Key Features[/b]
Segmented Grid Interface: Sharp vertical dividers separate each deviation bar, allowing you to count the "bars of exhaustion" at a glance.

Dynamic Trend-Line: The oscillator line itself inherits colors from the trend, providing instant visual feedback on momentum direction.

Micro-Peak Dots: Customizable exhaustion dots appear when momentum reaches extreme peaks (Overbought/Oversold), serving as your final confirmation for a reversal.

Fully Customizable Aesthetic: Every color, transparency, and dot size (from "Tiny" to "Big") can be adjusted to fit your specific UI or dark-mode setup.

## Source Code

````pine
//@version=6
indicator("Vector Confluence Oscillator", overlay=false, precision=2)

// ==========================================
// --- SECTION 1: CALCULATIONS INPUTS -------
// ==========================================
gp_range = "Price Deviation (Background)"
lenPrice    = input.int(20, "Price Lookback", group=gp_range)
multPrice   = input.float(2.2, "Price Multiplier", step=0.1, group=gp_range)

gp_mom = "Momentum (Cloud)"
lenOsc      = input.int(12, "Oscillator Period", group=gp_mom)
ob_level    = input.int(70, "Overbought Level", group=gp_mom)
os_level    = input.int(30, "Oversold Level", group=gp_mom)

// ==========================================
// --- SECTION 2: COLOR & STYLE INPUTS ------
// ==========================================
gp_colors = "Colors & Styles"

// Deviation Colors
color_up_bg   = input.color(color.new(#ff5252, 75), "Upper Deviation Background", group=gp_colors)
color_dn_bg   = input.color(color.new(#217cf3, 75), "Lower Deviation Background", group=gp_colors)
color_up_div  = input.color(color.new(#e42b2b, 45), "Upper Divider Line", group=gp_colors)
color_dn_div  = input.color(color.new(#2172eb, 45), "Lower Divider Line", group=gp_colors)

// Momentum Cloud Colors
color_bull    = input.color(color.new(#189e66, 40), "Bullish Cloud (Above 50)", group=gp_colors)
color_bear    = input.color(color.new(#ff4242, 16), "Bearish Cloud (Below 50)", group=gp_colors)

// Dynamic Line Colors
color_osc_up  = input.color(#189e66, "Oscillator Line Bullish", group=gp_colors)
color_osc_dn  = input.color(#ff5252, "Oscillator Line Bearish", group=gp_colors)
color_mid_l   = input.color(color.new(#7e7e7e, 50), "Midline Color", group=gp_colors)

// Zone & Dot Colors
color_zone    = input.color(color.new(color.gray, 94), "OB/OS Zone Fill", group=gp_colors)
color_ob_dot  = input.color(color.new(#ff3838, 0), "Overbought Peak Dot", group=gp_colors)
color_os_dot  = input.color(color.new(#14aa6c, 0), "Oversold Peak Dot", group=gp_colors)

// --- RENAMED: Size dropdown with your requested labels ---
dot_size_input = input.string("Tiny", "Peak Dot Size", options=["Tiny", "Small", "Normal", "Big"], group=gp_colors)

showPriceStatus = input.bool(true, "Show Background Bars", group="Visibility")

// ==========================================
// --- SECTION 3: CALCULATIONS --------------
// ==========================================
basisPrice = ta.sma(close, lenPrice)
devPrice   = ta.stdev(close, lenPrice)
upperPrice = basisPrice + multPrice * devPrice
lowerPrice = basisPrice - multPrice * devPrice

isUpperPriceDev = close > upperPrice
isLowerPriceDev = close < lowerPrice

osc = ta.rsi(close, lenOsc)
midLine = 50

// Map dropdown to pixel widths
// 'Tiny' is now the 1px micro size
dot_width = switch dot_size_input
    "Tiny"   => 4
    "Small"  => 6
    "Normal" => 8
    "Big"    => 12

// ==========================================
// --- SECTION 4: VISUALS -------------------
// ==========================================

// 1. Force Scale
plot(100, color=na, editable=false, display=display.none)
plot(0, color=na, editable=false, display=display.none)

// 2. Background Deviation Bars
bgcolor(showPriceStatus and isUpperPriceDev ? color_up_bg : showPriceStatus and isLowerPriceDev ? color_dn_bg : na, title="Price Deviation Fill", editable=false)

// 3. Vertical Dividers
plot(isUpperPriceDev ? 100 : na, "Upper Dividers", color=color_up_div, style=plot.style_columns, histbase=0, editable=false)
plot(isLowerPriceDev ? 100 : na, "Lower Dividers", color=color_dn_div, style=plot.style_columns, histbase=0, editable=false)

// 4. Grey OB/OS Zones
h_ob  = hline(ob_level, "OB Level", color=color_mid_l, linestyle=hline.style_dashed, editable=false)
h_os  = hline(os_level, "OS Level", color=color_mid_l, linestyle=hline.style_dashed, editable=false)
h_100 = hline(100, "100 Bound", color=na, editable=false)
h_0   = hline(0, "0 Bound", color=na, editable=false)

fill(h_100, h_ob, color=color_zone, title="OB Zone Background", editable=false)
fill(h_0, h_os, color=color_zone, title="OS Zone Background", editable=false)

// 5. Momentum Cloud & Dynamic Line
color cur_osc_color = osc > midLine ? color_bull : color_bear
color cur_line_color = osc > midLine ? color_osc_up : color_osc_dn

plot_osc  = plot(osc, "Oscillator Line", color=cur_line_color, linewidth=2, editable=false)
plot_mid  = plot(midLine, "Midline", color=color_mid_l, editable=false)
fill(plot_osc, plot_mid, color=cur_osc_color, title="Momentum Fill", editable=false)

// 6. Momentum Peak Dots
plot(ta.crossover(osc, ob_level) ? osc : na, "OB Peak Dot", color=color_ob_dot, style=plot.style_circles, linewidth=dot_width, editable=false)
plot(ta.crossunder(osc, os_level) ? osc : na, "OS Peak Dot", color=color_os_dot, style=plot.style_circles, linewidth=dot_width, editable=false)
````

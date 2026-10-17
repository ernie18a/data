# Custom MACD colored Signal

- url: https://www.tradingview.com/script/dyZtLoQZ-Custom-MACD-colored-Signal/
- type: indicator
- pine_id: PUB;99582207479643f196b9e6c7bebc493e
- version: 1.0

## Description

An optimized Pine Script v6 MACD indicator that replaces traditional, lagging zero-line crossover filters with real-time, slope-based color transitions. The histogram bars dynamically change color based on bar-by-bar acceleration or deceleration (rising vs. falling values), while the Signal Line changes color based strictly on its directional slope (climbing vs. dropping values). Completely customizable from the settings panel without editing code, this lightweight script is designed to instantly filter out counter-momentum trades and clarify short-term cycle shifts.

## Source Code

````pine
//@version=6
indicator("Top Dog Trading - Custom MACD & Colored Signal", shorttitle="TDT MACD + Signal", overlay=false)

// ==========================================
// INPUTS - Fully Adjustable Settings
// ==========================================
// MACD Length Inputs
fast_length   = input.int(12, title="Fast EMA Length", minval=1)
slow_length   = input.int(26, title="Slow EMA Length", minval=1)
signal_length = input.int(9, title="Signal EMA Length", minval=1)
src           = input.source(close, title="Source Data")

// Histogram Color Customization
group_hist     = "Top Dog Histogram Colors"
color_hist_up  = input.color(color.green, title="Histogram Slope Rising (Up)", group=group_hist)
color_hist_dn  = input.color(color.red, title="Histogram Slope Falling (Down)", group=group_hist)

// Signal Line Color Customization (New feature requested)
group_signal   = "Signal Line Custom Colors"
color_sig_up   = input.color(color.blue, title="Signal Line Sloping Up", group=group_signal)
color_sig_dn   = input.color(color.orange, title="Signal Line Sloping Down", group=group_signal)

// Static MACD Line Color
group_macd     = "MACD Line Color"
color_macd     = input.color(color.gray, title="MACD Line", group=group_macd)

// ==========================================
// CALCULATIONS
// ==========================================
// Calculate standard MACD values
[macd_line, signal_line, hist_value] = ta.macd(src, fast_length, slow_length, signal_length)

// 1. Histogram Color Logic: Changes based on bar-to-bar slope direction
color hist_color = hist_value >= hist_value[1] ? color_hist_up : color_hist_dn

// 2. Signal Line Color Logic: Changes based on signal line slope direction
color signal_color = signal_line >= signal_line[1] ? color_sig_up : color_sig_dn

// ==========================================
// PLOTTING
// ==========================================
// Zero Reference Line
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dashed)

// Histogram Bars (Thickness 3)
plot(hist_value, title="Histogram", color=hist_color, style=plot.style_histogram, linewidth=3)

// Static MACD Line
plot(macd_line, title="MACD Line", color=color_macd, linewidth=2)

// Dynamically Colored Signal Line (Changes color based on slope direction)
plot(signal_line, title="Signal Line", color=signal_color, linewidth=2)
````

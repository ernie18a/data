# MFI Normalized

- url: https://www.tradingview.com/script/LfLb8sEK-MFI-Normalized/
- type: indicator
- pine_id: PUB;3d74ffacb7634dd89d74fd8b51593f4c
- version: 2.0

## Description

This indicator is a custom, re-scaled version of the standard [b]Money Flow Index (MFI)[/b]. It is centered at 0 (instead of ranging from 0 to 100) making it a bit easier to visualize momentum and exhaustion. 

You have two display options: [b]Line[/b] and [b]Shape[/b]
Line is very similar to the traditional MFI and includes coloring to more easily identify exhaustion signals. 
Shape is a compact display that plots icons across the zero-line to keep your charts clean and easy to read.

[b]Signals[/b]
This indicator is intended to be an EXIT indicator.
Line above 50 / Down Label (RED) - Overbought, exit signal for longs
Line below 50 / Up Label  (GREEN) - Oversold, exit signal for shorts
Line within range / Circle or Triangle (GRAY) - Normal market, continuation of position

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © DasanC

//@version=6
indicator("MFI Normalized", timeframe = "")

// --- Inputs ---
mfi_len = input.int(13, "MFI length")
up = input.int(50, "Upper")
dn = input.int(-50, "Lower")
plotStyle = input.string("Line Plot", "Display Style", options=["Line Plot", "Shapes (Compact)"])

// --- Core Calculation ---
mfi = (ta.mfi(hlc3, mfi_len) - 50) * 2

// --- Logic for Shapes ---
change = mfi - nz(mfi[1])
abs_change = math.abs(change)

is_above = mfi >= up
is_below = mfi <= dn
is_mid   = not is_above and not is_below

// --- Display Toggles ---
show_line = plotStyle == "Line Plot"
show_shapes = plotStyle == "Shapes (Compact)"

// --- 1. Line Plot & Boundaries ---
// We plot 'na' when in shape mode to completely hide the lines
lineColor = show_line ? (mfi >= up or nz(mfi[1]) >= up ? color.red : mfi <= dn or nz(mfi[1]) <= dn ? color.lime : color.new(color.white, 20)) : na

plot(show_line ? mfi : na, "MFI Line", color=lineColor, linewidth=2)
plot(show_line ? up : na, "Upper", color=color.new(color.white, 50), linestyle = plot.linestyle_dashed)
plot(show_line ? dn : na, "Lower", color=color.new(color.white, 50), linestyle = plot.linestyle_dashed)

// --- 2. Shapes Plot ---
// When shapes are toggled on, they plot exactly at 0. Otherwise, they plot at 'na' (hidden).
shape_pos = show_shapes ? 0 : na

// --- Middle Zone Gradient Color ---
// Fades from Lime -> Gray (at 0) -> Red
color mid_color = mfi > 0 ? color.from_gradient(mfi, 0, up*1.5, color.white, color.red) : color.from_gradient(mfi, dn*1.5, 0, color.lime, color.white)

// Extreme Limits
plotshape(shape_pos, title="Above Upper", style=shape.labeldown, location=location.absolute, color=(show_shapes and is_above) ? color.red : na, size=size.tiny)
plotshape(shape_pos, title="Below Lower", style=shape.labelup, location=location.absolute, color=(show_shapes and is_below) ? color.lime : na, size=size.tiny)

// Middle Zone
plotshape(shape_pos, title="Small Change", style=shape.circle, location=location.absolute, color=(show_shapes and is_mid) ? mid_color : na, size=size.tiny)
````

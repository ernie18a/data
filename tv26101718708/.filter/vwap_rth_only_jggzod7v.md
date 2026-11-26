# VWAP RTH ONLY

- url: https://www.tradingview.com/script/JgGzOD7V-VWAP-RTH-ONLY/
- type: indicator
- pine_id: PUB;b732ecbf07114073903f8022f6f0bb8b
- version: 1.0

## Description

VWAP shown for 9:30 ET to 4 ET only, no clutter on chart

## Source Code

````pine
//@version=5
indicator("RTH-Only VWAP (Fixed Shading Compiler)", overlay=true, max_lines_count=500)

// ==========================================
// CONFIGURATION & TIME MANAGER
// ==========================================
var string TZ = "America/New_York"
rth_session   = input.session("0930-1600", title="RTH Session Times", group="Session Settings")
auto_hide_d   = input.bool(true, title="Auto-Hide on Daily charts or above?", group="Session Settings")

// 1. Determine if the script is allowed to display based on timeframe depth
is_allowed_tf = auto_hide_d ? timeframe.isintraday : true

// 2. Strict tracking filter for the 9:30 AM - 4:00 PM EST window
in_rth = not na(time(timeframe.period, rth_session + ":23456", TZ))

// ==========================================
// USER CONFIGURATIONS & STYLING
// ==========================================
// --- Core VWAP ---
color_vwap  = input.color(color.orange, title="VWAP Core Color", group="1) Core Line Settings")
width_vwap  = input.int(2, title="VWAP Line Width", minval=1, group="1) Core Line Settings")

// --- Band 1 Settings ---
show_band1  = input.bool(true, title="Show Bands 1", group="2) Deviation Channel 1")
mult_band1  = input.float(1.0, title="Band 1 Multiplier", minval=0.1, step=0.1, group="2) Deviation Channel 1")
color_band1 = input.color(color.blue, title="Band 1 Line Color", group="2) Deviation Channel 1")
width_band1 = input.int(1, title="Band 1 Line Width", minval=1, group="2) Deviation Channel 1")

// --- Band 2 Settings & Shading ---
show_band2  = input.bool(true, title="Show Bands 2", group="3) Deviation Channel 2")
mult_band2  = input.float(2.0, title="Band 2 Multiplier", minval=0.1, step=0.1, group="3) Deviation Channel 2")
color_band2 = input.color(color.red, title="Band 2 Line Color", group="3) Deviation Channel 2")
width_band2 = input.int(1, title="Band 2 Line Width", minval=1, group="3) Deviation Channel 2")

shade_b2    = input.bool(true, title="Enable Band 2 Shading", group="4) Advanced Shading")
shade_style = input.string("Whole Channel (B2 Upper to B2 Lower)", title="Shading Type", options=["Whole Channel (B2 Upper to B2 Lower)", "Outer Corridors Only (B2 to B1)"], group="4) Advanced Shading")
color_shade = input.color(color.new(color.red, 95), title="Shading Color & Opacity", group="4) Advanced Shading")

// ==========================================
// MATHEMATICAL COMPUTATION CORRIDOR
// ==========================================
var float vsum   = na
var float pvsum  = na
var float p2vsum = na

// Reset cumulative data arrays at the 9:30 AM opening bell
if (in_rth and not in_rth[1]) or timeframe.change("D")
    vsum   := volume
    pvsum  := hlc3 * volume
    p2vsum := hlc3 * hlc3 * volume
else if in_rth
    vsum   := vsum + volume
    pvsum  := pvsum + (hlc3 * volume)
    p2vsum := p2vsum + (hlc3 * hlc3 * volume)

// Core metrics generation
float native_vwap = pvsum / vsum
float variance    = (p2vsum / vsum) - (native_vwap * native_vwap)
float native_std  = math.sqrt(math.max(0, variance))

// ==========================================
// UNBROKEN PLOT LINES WITH TRANSPARENCY MASKS
// ==========================================
// Lines must calculate across the entire canvas to allow fill layers to attach properly
float calc_vwap = native_vwap
float calc_b1_u = native_vwap + (native_std * mult_band1)
float calc_b1_l = native_vwap - (native_std * mult_band1)
float calc_b2_u = native_vwap + (native_std * mult_band2)
float calc_b2_l = native_vwap - (native_std * mult_band2)

// Set up visibility constraints (Hidden outside RTH or on Daily+ charts)
isVisible = is_allowed_tf and in_rth

color vwap_display_color = isVisible ? color_vwap : color.new(color.white, 100)
color b1_display_color   = (isVisible and show_band1) ? color_band1 : color.new(color.white, 100)
color b2_display_color   = (isVisible and show_band2) ? color_band2 : color.new(color.white, 100)

// ==========================================
// RENDERING PIPELINE ATTACHMENTS
// ==========================================
p_vwap = plot(calc_vwap, title="RTH VWAP Core", color=vwap_display_color, linewidth=width_vwap)

p_b1_u = plot(calc_b1_u, title="Band 1 Upper", color=b1_display_color, linewidth=width_band1)
p_b1_l = plot(calc_b1_l, title="Band 1 Lower", color=b1_display_color, linewidth=width_band1)

p_b2_u = plot(calc_b2_u, title="Band 2 Upper", color=b2_display_color, linewidth=width_band2)
p_b2_l = plot(calc_b2_l, title="Band 2 Lower", color=b2_display_color, linewidth=width_band2)

// ==========================================
// FIXED COMPILER COLOR ASSIGNMENTS
// ==========================================
// Pre-calculating color expressions explicitly solves the internal compiler block error
color transparentColor = color.new(color.white, 100)

color wholeChannelFillColor = (shade_b2 and isVisible and shade_style == "Whole Channel (B2 Upper to B2 Lower)") ? color_shade : transparentColor
color outerCorridorFillColor = (shade_b2 and isVisible and shade_style == "Outer Corridors Only (B2 to B1)") ? color_shade : transparentColor

// Execute clean, non-conditional architectural fills
fill(p_b2_u, p_b2_l, color=wholeChannelFillColor, title="Whole Channel Fill", fillgaps=true)
fill(p_b2_u, p_b1_u, color=outerCorridorFillColor, title="Upper Corridor Fill", fillgaps=true)
fill(p_b2_l, p_b1_l, color=outerCorridorFillColor, title="Lower Corridor Fill", fillgaps=true)
````

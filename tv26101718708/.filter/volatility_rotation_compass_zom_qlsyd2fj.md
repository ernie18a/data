# Volatility Rotation Compass [ZOM]

- url: https://www.tradingview.com/script/qLSyd2Fj-Volatility-Rotation-Compass-ZOM/
- type: indicator
- pine_id: PUB;373ee6b3abac40f68ba4b042fec5380d
- version: 1.0

## Description

Volatility Rotation Compass [ZOM] is a lower-pane regime and momentum-rotation tool built from a combination of Vortex directional spread, Choppiness Index, and normalized volume z-score. The goal is to separate directional expansion from low-quality chop instead of treating every oscillator move through zero as equally useful.

The core calculation starts with the Vortex Indicator. The script compares positive and negative Vortex movement to estimate which side is controlling directional flow. That directional spread is then scaled by a trendiness factor derived from Choppiness Index: lower chop values give more weight to directional movement, while higher chop compresses the compass score. A normalized volume z-score is used as a participation filter so stronger readings are favored when volume is above its recent baseline.

The main compass oscillator is plotted around a zero line. Teal/green histogram pressure represents bullish expansion, rose/crimson pressure represents bearish expansion, and amber/gray behavior represents indecision, chop, or weakening participation. Subtle background shading shows the active regime so the lower pane can be read quickly without turning the chart into clutter.

Bull rotation markers appear when the compass pushes above the bullish threshold while chop falls and volume confirms participation. Bear rotation markers appear when the compass pushes below the bearish threshold under similar trend and participation conditions. Exhaustion dots identify stretched readings where the compass is extended but chop begins to rise, which can warn that momentum is becoming less efficient.

I use this as a regime filter and timing aid, not as a standalone entry system. A bullish rotation is more useful when it aligns with higher-timeframe structure, a reclaim, or clean continuation candles. A bearish rotation is stronger when price is failing below structure, rejecting supply, or continuing after a breakdown. Exhaustion dots are not automatic reversal calls; they are warnings to reduce confidence in chasing late movement.

Key inputs include Vortex length, Choppiness length, volume z-score length, smoothing, signal visibility, exhaustion dot visibility, dashboard position, and palette colors. Shorter lengths make the compass faster but noisier. Longer lengths make it slower but more stable. The dashboard summarizes regime, direction, volume z-score, chop reading, trend score, and compass value so traders can see why the current state is being plotted.

This script intentionally uses standard plots, histograms, background color, markers, and tables instead of static projected drawings. That keeps the visuals anchored to the chart across scrolling and timeframe changes.

Open-source [ZOM] script for educational use only. Not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ZenOutMan

//@version=6
indicator("Volatility Rotation Compass [ZOM]", shorttitle="VRC [ZOM]", overlay=false)

// ========================================================================= //
// --- Inputs --- 
// ========================================================================= //
grp_mode = "Settings & Toggles"
show_signals = input.bool(true, "Show Signals", group=grp_mode)
show_exh = input.bool(true, "Show Exhaustion Dots", group=grp_mode)
smooth_len = input.int(3, "Compass Smoothing", minval=1, group=grp_mode)

grp_lens = "Indicator Lengths"
vortex_len = input.int(14, "Vortex Length", group=grp_lens)
chop_len = input.int(14, "Chop Length", group=grp_lens)
vol_len = input.int(20, "Volume Z-Score Length", group=grp_lens)

grp_dash = "Mini Dashboard"
show_dash = input.bool(true, "Show Dashboard", group=grp_dash)
dash_pos = input.string("Top Right", "Dashboard Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=grp_dash)

grp_style = "Aesthetics"
color_bull = input.color(#008080, "Bull Expansion (Teal)", group=grp_style)
color_bear = input.color(#FF007F, "Bear Expansion (Rose)", group=grp_style)
color_chop = input.color(#FFBF00, "Chop State (Amber)", group=grp_style)
color_exh = input.color(#708090, "Exhaustion (Slate)", group=grp_style)
color_bg_bull = input.color(color.new(#008080, 95), "Bg Bullish", group=grp_style)
color_bg_bear = input.color(color.new(#FF007F, 95), "Bg Bearish", group=grp_style)

// ========================================================================= //
// --- Logic: Vortex Indicator ---
// ========================================================================= //
vmp = math.sum(math.abs(high - low[1]), vortex_len)
vmm = math.sum(math.abs(low - high[1]), vortex_len)
str = math.sum(ta.atr(1), vortex_len)
vip = str == 0 ? 0 : vmp / str
vim = str == 0 ? 0 : vmm / str
vortex_spread = vip - vim

// ========================================================================= //
// --- Logic: Choppiness Index ---
// ========================================================================= //
atr_sum = math.sum(ta.atr(1), chop_len)
high_range = ta.highest(high, chop_len)
low_range = ta.lowest(low, chop_len)
chop = high_range - low_range == 0 ? 0 : 100 * math.log10(atr_sum / (high_range - low_range)) / math.log10(chop_len)
chop_falling = chop < nz(chop[1])
chop_rising = chop > nz(chop[1])
trendiness = (100 - chop) / 50.0

// ========================================================================= //
// --- Logic: Volume Z-Score ---
// ========================================================================= //
vol_sma = ta.sma(volume, vol_len)
vol_std = ta.stdev(volume, vol_len)
vol_z = vol_std == 0 ? 0 : (volume - vol_sma) / vol_std
vol_mult = math.max(0.5, math.min(2.0, 1.0 + (vol_z * 0.2)))

// ========================================================================= //
// --- Logic: Compass Oscillator ---
// ========================================================================= //
compass_raw = vortex_spread * 100 * trendiness * vol_mult
compass_unsmoothed = math.max(-100, math.min(100, compass_raw))
compass = ta.ema(compass_unsmoothed, smooth_len)

// ========================================================================= //
// --- Colors & Histogram ---
// ========================================================================= //
hist_color = color_exh
if chop > 61.8
    hist_color := color_chop
else if compass > 0 and compass > nz(compass[1])
    hist_color := color_bull
else if compass < 0 and compass < nz(compass[1])
    hist_color := color_bear
else
    hist_color := color_exh

bgcolor(compass > 0 ? color_bg_bull : color_bg_bear, title="Regime Background")

plot(0, "Zero Line", color=color.new(#ffffff, 50), linewidth=1, style=plot.style_line)
plot(compass, "Compass Histogram", color=hist_color, style=plot.style_columns, linewidth=3)
plot(compass, "Compass Line", color=color.new(#ffffff, 80), style=plot.style_line, linewidth=1)

// ========================================================================= //
// --- Signals ---
// ========================================================================= //
bull_rot = ta.crossover(compass, 18) and chop_falling and vol_z > 0
bear_rot = ta.crossunder(compass, -18) and chop_falling and vol_z > 0
exhaustion = math.abs(compass) > 65 and chop_rising

plot(show_signals and bull_rot ? compass - 15 : na, "Bull Rotation", color=color_bull, style=plot.style_cross, linewidth=3)
plot(show_signals and bear_rot ? compass + 15 : na, "Bear Rotation", color=color_bear, style=plot.style_cross, linewidth=3)
plot(show_exh and exhaustion ? compass * 1.1 : na, "Exhaustion Dot", color=color_exh, style=plot.style_circles, linewidth=2)

// ========================================================================= //
// --- Dashboard ---
// ========================================================================= //
var string pos_str = position.top_right
if dash_pos == "Bottom Right"
    pos_str := position.bottom_right
else if dash_pos == "Top Left"
    pos_str := position.top_left
else if dash_pos == "Bottom Left"
    pos_str := position.bottom_left

if show_dash and barstate.islast
    var table dash = table.new(pos_str, 2, 6, bgcolor=color.new(#111111, 80), border_width=1, border_color=color.new(#333333, 50))
    
    table.cell(dash, 0, 0, "VRC [ZOM]", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 0, "Compass", text_color=color.new(#ffffff, 50), text_size=size.small, text_halign=text.align_right)
    
    // Regime
    regime_str = chop > 61.8 ? "Choppy" : "Trending"
    regime_col = chop > 61.8 ? color_chop : color.new(#ffffff, 20)
    table.cell(dash, 0, 1, "Regime", text_color=color.new(#ffffff, 50), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, regime_str, text_color=regime_col, text_size=size.small, text_halign=text.align_right)
    
    // Direction
    dir_str = compass > 0 ? "Bullish" : "Bearish"
    dir_col = compass > 0 ? color_bull : color_bear
    table.cell(dash, 0, 2, "Direction", text_color=color.new(#ffffff, 50), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, dir_str, text_color=dir_col, text_size=size.small, text_halign=text.align_right)
    
    // Vol Z
    vol_str = str.tostring(vol_z, "#.##")
    vol_col = vol_z > 1.0 ? color_bull : vol_z < -1.0 ? color_exh : color.new(#ffffff, 20)
    table.cell(dash, 0, 3, "Vol Z-Score", text_color=color.new(#ffffff, 50), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, vol_str, text_color=vol_col, text_size=size.small, text_halign=text.align_right)
    
    // Chop
    table.cell(dash, 0, 4, "Chop Index", text_color=color.new(#ffffff, 50), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(chop, "#.#"), text_color=regime_col, text_size=size.small, text_halign=text.align_right)
    
    // Score
    score = math.round(math.min(100, math.max(0, (math.abs(compass) / 80) * 100)))
    table.cell(dash, 0, 5, "Trend Score", text_color=color.new(#ffffff, 50), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(score) + "%", text_color=color.white, text_size=size.small, text_halign=text.align_right)

// ========================================================================= //
// --- Alerts ---
// ========================================================================= //
alertcondition(bull_rot, "VRC Bull Rotation", "Volatility Rotation Compass: Bullish Rotation Setup [ZOM]")
alertcondition(bear_rot, "VRC Bear Rotation", "Volatility Rotation Compass: Bearish Rotation Setup [ZOM]")
alertcondition(exhaustion, "VRC Exhaustion", "Volatility Rotation Compass: Momentum Exhaustion [ZOM]")
````

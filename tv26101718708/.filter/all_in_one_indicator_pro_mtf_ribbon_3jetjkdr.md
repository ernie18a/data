# All in One Indicator - Pro MTF Ribbon

- url: https://www.tradingview.com/script/3JEtJkdr/
- type: indicator
- pine_id: PUB;11aa71c04cf7485ab583628904638b95
- version: 1.0

## Description

The Pro MTF Ribbon is a powerful, visually intuitive trend-following indicator designed to give traders a comprehensive view of market momentum across multiple higher timeframes simultaneously. By overlaying 1-Day, 3-Day, and 1-Week Simple Moving Averages (SMAs) directly onto your current chart, it eliminates the need to constantly switch timeframes. The indicator bridges the gap between macro trends and micro price action using dynamic color-coded ribbons.

Key Features
Multi-Timeframe (MTF) Alignment: Calculates and plots the SMA for the 1D, 3D, and 1W timeframes on any lower timeframe chart.

Dynamic Trend Ribbons: Uses a filled ribbon system to highlight the relationship between the fast, medium, and slow moving averages.

Color-Coded Momentum: Lines and ribbons automatically change color based on bullish or bearish alignments, providing instant visual feedback on trend strength.

Smart Floating Labels: Displays clean, 100% opaque text labels at the end of the current price action (1D, 3D, 1W) to easily identify which line is which.

Hover Tooltips: Hovering over the floating labels reveals the exact numerical value of each SMA down to the minimum tick.

Fully Customizable: Users have complete control over the SMA length, source, line colors, ribbon colors, and background opacity.

## Source Code

````pine
//@version=6
indicator("All in One Indicator - Pro MTF Ribbon", overlay = true)

// --- INPUTS ---
grp_sma = "SMA Settings"
len = input.int(20, title="SMA Length", group=grp_sma)
src = input.source(close, title="Source", group=grp_sma)

// --- LINIEN EINSTELLUNGEN ---
grp_lines = "Line Settings (Colors & Opacity)"
// Pine Script nutzt "Transparenz" (0 = voll sichtbar, 100 = unsichtbar)
col_line_fast_bull = input.color(color.new(#00BFA5, 15), title="Fast Line Bullish (1D)", group=grp_lines)
col_line_fast_bear = input.color(color.new(#FF5252, 15), title="Fast Line Bearish (1D)", group=grp_lines)
col_line_anchor    = input.color(color.new(color.gray, 60), title="Anchor Line (3D)", group=grp_lines)
col_line_slow_bull = input.color(color.new(#00695C, 0),  title="Deep Line Bullish (1W)", group=grp_lines)
col_line_slow_bear = input.color(color.new(#880E4F, 0),  title="Deep Line Bearish (1W)", group=grp_lines)

// --- RIBBON EINSTELLUNGEN (Hintergrundbereiche) ---
grp_ribbons = "Ribbon Settings (Areas)"
// Transparenz 80 = 20% Deckkraft (sehr dezent)
col_rib_fast_bull = input.color(color.new(#00BFA5, 80), title="Fast Ribbon Bullish", group=grp_ribbons)
col_rib_fast_bear = input.color(color.new(#FF5252, 80), title="Fast Ribbon Bearish", group=grp_ribbons)
col_rib_slow_bull = input.color(color.new(#00695C, 85), title="Deep Ribbon Bullish", group=grp_ribbons)
col_rib_slow_bear = input.color(color.new(#880E4F, 85), title="Deep Ribbon Bearish", group=grp_ribbons)

// --- BERECHNUNGEN (Multi-Timeframe Rohdaten) ---
sma1d = request.security(syminfo.tickerid, "1D", ta.sma(src, len))
sma3d = request.security(syminfo.tickerid, "3D", ta.sma(src, len))
sma1w = request.security(syminfo.tickerid, "1W", ta.sma(src, len))

// --- LOGIK ---
isFastBull = sma1d > sma3d
isSlowBull = sma3d > sma1w

// Aktuelle Farben basierend auf Trend zuweisen
c_line_fast = isFastBull ? col_line_fast_bull : col_line_fast_bear
c_line_slow = isSlowBull ? col_line_slow_bull : col_line_slow_bear

c_rib_fast = isFastBull ? col_rib_fast_bull : col_rib_fast_bear
c_rib_slow = isSlowBull ? col_rib_slow_bull : col_rib_slow_bear

// --- PLOTS ---
p1 = plot(sma1d, color=c_line_fast, title="1D 20 SMA", linewidth=1)
p2 = plot(sma3d, color=col_line_anchor, title="3D 20 SMA", linewidth=1)
p3 = plot(sma1w, color=c_line_slow, title="1W 20 SMA", linewidth=2)

// --- AREAS (Die Hintergrund-Ribbons) ---
fill(p1, p2, color=c_rib_fast, title="Fast Trend Area")
fill(p2, p3, color=c_rib_slow, title="Deep Trend Area")

// --- FLOATING LABELS (Immer 100% Deckkraft) ---
var label lbl_1d = label.new(na, na, "1D", style=label.style_none, size=size.normal)
var label lbl_3d = label.new(na, na, "3D", style=label.style_none, size=size.normal)
var label lbl_1w = label.new(na, na, "1W", style=label.style_none, size=size.normal)

if barstate.islast
    label.set_xy(lbl_1d, bar_index + 2, sma1d)
    label.set_xy(lbl_3d, bar_index + 2, sma3d)
    label.set_xy(lbl_1w, bar_index + 2, sma1w)
    
    // color.new(..., 0) zwingt PineScript dazu, die Transparenz zu entfernen -> 100% Deckkraft!
    label.set_textcolor(lbl_1d, color.new(c_line_fast, 0))
    label.set_textcolor(lbl_3d, color.new(col_line_anchor, 0))
    label.set_textcolor(lbl_1w, color.new(c_line_slow, 0))
    
    // Tooltips
    label.set_tooltip(lbl_1d, "1D SMA: " + str.tostring(sma1d, format.mintick))
    label.set_tooltip(lbl_3d, "3D SMA: " + str.tostring(sma3d, format.mintick))
    label.set_tooltip(lbl_1w, "1W SMA: " + str.tostring(sma1w, format.mintick))
````

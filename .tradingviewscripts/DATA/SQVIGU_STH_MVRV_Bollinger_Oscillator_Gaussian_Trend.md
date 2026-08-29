<!-- tradingview-pine-id: PUB;721e753460ce46c98da7840dbf67bee1 -->
<!-- tradingviewscripts-format: 1 -->
# SQVIGU STH MVRV Bollinger Oscillator + Gaussian Trend

Source: https://www.tradingview.com/script/Ku2k1uIz-SQVIGU-STH-MVRV-Bollinger-Oscillator-Gaussian-Trend/

## Description

User Guide: 
• Oscillator line — price Z-score vs. its Bollinger basis. Turns cyan above +1 (overheated), pink below −1 (oversold), gray in between.
 • Fill — dark green above zero = bullish pressure, dark red below zero = bearish pressure; deeper color = stronger move.
 • Blue/orange smooth line (Gaussian macro trend) — your directional bias filter. Blue = rising (bullish), orange = falling (bearish).
 • Purple circle ● — Gaussian just flipped blue→orange (top forming) = caution on longs.
 • Yellow circle ● — Gaussian just flipped orange→blue (bottom forming) = watch for longs.
 • • Dots (enable in settings) — confirmed oscillator peaks/troughs beyond the ±1 zones = exhaustion signals.
 • Best long setup — oscillator near/below −1 (pink) + yellow circle + Gaussian turning blue.
 • Best short/exit setup — oscillator above +1 (cyan) + purple circle + Gaussian turning orange.
 • Tuning — lower Gaussian Bandwidth (5–6) for faster turns, raise (12–16) for a slower macro read; Curve Exaggeration stretches the line's amplitude for visibility.
 • Alerts — six built-in: zone entries, oscillator peaks/troughs, and Gaussian up/down crosses.

---

## Source Code

````pine
//@version=6
// Gaussian kernel adapted from LuxAlgo Nadaraya-Watson Smoothers (CC BY-NC-SA 4.0)
indicator('SQVIGU STH MVRV Bollinger Oscillator + Gaussian Trend', shorttitle = 'SQVIGU BB Osc + Gauss', overlay = false, format = format.price, precision = 2, max_bars_back = 500)

// ========================================================================= //
// ======================== INPUTS & CONFIGURATION ========================= //
// ========================================================================= //
grp_main = 'Main Settings'
src = input.source(close, title = 'Source Data', group = grp_main)
length = input.int(20, title = 'Bollinger Length', minval = 1, group = grp_main)
mult = input.float(2.0, title = 'Bollinger Multiplier', minval = 0.1, step = 0.1, group = grp_main)

grp_zones = 'Oscillator Zones'
obLevel = input.float(1.0, title = 'Overheated Level (+)', group = grp_zones)
osLevel = input.float(-1.0, title = 'Oversold Level (-)', group = grp_zones)

grp_macro = 'Macro Trend Line (Gaussian)'
show_macro = input.bool(true, title = 'Show Macro Trend Line', group = grp_macro)
macro_len = input.int(50, title = 'Macro Lookback', group = grp_macro, tooltip = 'Lower number = more responsive curves. Default: 50')
gauss_h = input.float(8.0, title = 'Gaussian Bandwidth', minval = 0.1, step = 0.5, group = grp_macro, tooltip = 'Nadaraya-Watson kernel bandwidth. Higher = smoother/slower turns, Lower = sharper turns. Default: 8')
exaggeration = input.float(1.8, title = 'Curve Exaggeration', step = 0.1, group = grp_macro, tooltip = 'Stretches the amplitude of the line up and down.')
show_macro_pivots = input.bool(true, title = 'Show Direction Cross Circles', group = grp_macro, tooltip = 'Plots a small circle when the Gaussian path crosses from up to down or down to up.')

grp_style = 'Visuals & Colors'
col_ob = input.color(#00d0f0, title = 'Overheated Color', group = grp_style) // Pink
col_os = input.color(color.rgb(249, 112, 203), title = 'Oversold Color', group = grp_style) // Green
col_fill_up = input.color(color.rgb(0, 85, 7), title = 'Fill Up (Orange)', group = grp_style)
col_fill_dn = input.color(#a20000, title = 'Fill Down (Orange)', group = grp_style)
col_mac_up = input.color(color.rgb(7, 0, 215), title = 'Gaussian Bullish Color (Blue)', group = grp_style) // SQ4 upCss
col_mac_dn = input.color(color.rgb(254, 109, 12), title = 'Gaussian Bearish Color (Orange)', group = grp_style) // SQ4 dnCss
col_mac_peak = input.color(color.rgb(169, 0, 248), title = 'Macro Peak Circle', group = grp_style) // Bright Yellow
col_mac_trough = input.color(#eeff00, title = 'Macro Trough Circle', group = grp_style) // Bright Cyan

grp_signals = 'Signals & Markers'
show_markers = input.bool(false, title = 'Show Oscillator Peak/Trough Dots', group = grp_signals)

// ========================================================================= //
// ======================== CORE CALCULATIONS ============================== //
// ========================================================================= //
// 1. Bollinger Oscillator (Z-Score)
basis = ta.sma(src, length)
dev = mult * ta.stdev(src, length)
osc = dev == 0 ? 0 : (src - basis) / dev

// 2. Macro Trend Line — Gaussian (Nadaraya-Watson) kernel smoother
// Gaussian window (LuxAlgo)
gauss(x, h) =>
    math.exp(-(math.pow(x, 2) / (h * h * 2)))

raw_rsi = ta.rsi(src, macro_len)
// Normalize to -1 / +1 scale, then multiply by the exaggeration factor to stretch the curves
norm_rsi = (raw_rsi - 50) / 50 * exaggeration

// Precompute Gaussian kernel weights once (endpoint estimator coefficients)
var coefs = array.new_float(0)
if barstate.isfirst
    for i = 0 to 499 by 1
        array.push(coefs, gauss(i, gauss_h))

// Non-repainting endpoint estimate each bar (dynamic normalization handles <500 bars of history)
float gsum = 0.
float gden = 0.
for i = 0 to math.min(499, bar_index) by 1
    float v = norm_rsi[i]
    if not na(v)
        float w = coefs.get(i)
        gsum := gsum + v * w
        gden := gden + w
        gden
macro_trend = gden == 0 ? na : gsum / gden

// ========================================================================= //
// ======================== VISUAL RENDERING =============================== //
// ========================================================================= //
// Dynamic Line Color based on position
lineColor = osc >= obLevel ? col_ob : osc <= osLevel ? col_os : color.gray

// Draw Zone Lines
hline_ob = hline(obLevel, title = 'Overheated Line', color = color.new(col_ob, 30), linestyle = hline.style_solid, linewidth = 1)
hline_os = hline(osLevel, title = 'Oversold Line', color = color.new(col_os, 30), linestyle = hline.style_solid, linewidth = 1)
hline_zero = hline(0, title = 'Zero Line', color = color.new(color.gray, 60), linestyle = hline.style_dotted)

// Plot the Gaussian Macro Trend Line (Behind the main oscillator)
// Direction-based coloring like SQVIGU SIMONS SQ4: blue while rising (bullish), orange while falling (bearish)
macro_color = macro_trend > nz(macro_trend[1]) ? col_mac_up : col_mac_dn
plot(show_macro ? macro_trend : na, title = 'Macro Trend (Gaussian)', color = macro_color, linewidth = 2, style = plot.style_line)

// Plot the main oscillator
plot_osc = plot(osc, title = 'Oscillator', color = lineColor, linewidth = 2, style = plot.style_line)
plot_zero = plot(0, title = 'Base', color = color.new(color.white, 100))

// DYNAMIC GRADIENT FILL
grad_up = color.from_gradient(osc, 0, obLevel, color.new(col_fill_up, 90), color.new(col_fill_up, 20))
grad_dn = color.from_gradient(osc, osLevel, 0, color.new(col_fill_dn, 90), color.new(col_fill_dn, 20))

fillColor = osc > 0 ? grad_up : grad_dn
fill(plot_osc, plot_zero, color = fillColor, title = 'Oscillator Volume Fill')

// ========================================================================= //
// ======================== INTERACTIVE SIGNALS ============================ //
// ========================================================================= //
// Oscillator Peaks/Troughs
oscPeak = osc[1] >= obLevel and osc[2] < osc[1] and osc < osc[1]
oscTrough = osc[1] <= osLevel and osc[2] > osc[1] and osc > osc[1]

plotchar(show_markers and oscPeak ? osc[1] + 0.1 : na, title = 'Overheated Peak', char = '•', location = location.absolute, color = col_ob, size = size.tiny, offset = -1)
plotchar(show_markers and oscTrough ? osc[1] - 0.1 : na, title = 'Oversold Trough', char = '•', location = location.absolute, color = col_os, size = size.tiny, offset = -1)

// Gaussian path direction crosses (slope sign flip — same logic as LuxAlgo's ▲/▼)
d = macro_trend - macro_trend[1]
d1 = macro_trend[1] - macro_trend[2]
macroCrossDn = d < 0 and d1 > 0 // up-path crosses to down-path (peak) → line turns orange
macroCrossUp = d > 0 and d1 < 0 // down-path crosses to up-path (trough) → line turns blue

// Small circles printed on the pivot bar where the path crossed
plotshape(show_macro_pivots and show_macro and macroCrossDn ? macro_trend[1] : na, title = 'Macro Down-Cross Circle', style = shape.circle, location = location.absolute, color = col_mac_peak, size = size.tiny, offset = -1)
plotshape(show_macro_pivots and show_macro and macroCrossUp ? macro_trend[1] : na, title = 'Macro Up-Cross Circle', style = shape.circle, location = location.absolute, color = col_mac_trough, size = size.tiny, offset = -1)

// ========================================================================= //
// ======================== CUSTOM ALERTS ================================== //
// ========================================================================= //
alertcondition(ta.crossover(osc, obLevel), title = '⚠️ Entered Overheated', message = 'Bollinger Oscillator crossed above the Overheated Level (1.0).')
alertcondition(ta.crossunder(osc, osLevel), title = '✅ Entered Oversold', message = 'Bollinger Oscillator crossed below the Oversold Level (-1.0).')
alertcondition(oscPeak, title = '🔴 Overheated Peak Confirmed', message = 'A peak has formed above the overheated threshold. Potential reversal.')
alertcondition(oscTrough, title = '🟢 Oversold Trough Confirmed', message = 'A trough has formed below the oversold threshold. Potential bounce.')
alertcondition(macroCrossDn, title = '🔵 Gaussian Path Down-Cross', message = 'The Gaussian Macro Trend path crossed from up to down (top formed — line turned orange).')
alertcondition(macroCrossUp, title = '🔴 Gaussian Path Up-Cross', message = 'The Gaussian Macro Trend path crossed from down to up (bottom formed — line turned blue).')
````

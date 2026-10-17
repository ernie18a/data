# Adaptive Baseline Suite | NAL

- url: https://www.tradingview.com/script/xXSDyxje-Adaptive-Baseline-Suite-NAL/
- type: indicator
- pine_id: PUB;12434b40c1e1479caa8327c99ed41a5f
- version: 1.0

## Description

[b]1. Overview
[/b]
Adaptive Baseline Suite | NAL is a multi-baseline trend indicator that compares price against five different adaptive baseline systems. Instead of relying on one smoothing method, it builds separate volatility bands around a Kijun Sen, DEMA, Median, Laguerre Filter, and Gaussian Filter.

Each baseline produces its own bullish or bearish state. These states are then averaged into a final TPI-style score, giving a broader view of whether price is generally trading above or below its adaptive baseline structure.

[b]2. Calculation
[/b]
The indicator starts by calculating five independent baselines:

[pine]baseline_1 = math.avg(ta.lowest(baseline1i), ta.highest(baseline1i))
baseline_2 = ta.dema(source, baseline2i)
baseline_3 = ta.median(source, baseline3i)
baseline_4 = f_laguerre(source, baseline4i)
baseline_5 = gaussianFilter(source, baseline5i, baseline5is)[/pine]

Each baseline represents a different way of defining the market’s fair-value zone. The Kijun Sen captures midpoint structure, DEMA reacts faster to trend changes, Median reduces noise, Laguerre smooths price recursively, and the Gaussian Filter applies weighted smoothing around a bell-curve distribution.

After the baselines are created, volatility bands are calculated around each one. The indicator measures the residual between price and the baseline, then applies a MAD (Mean aggregate deviation) volatility estimate:

[pine]residual = srcPrice - srcBase

_mad = ta.sma(math.abs(residual - ta.sma(residual, volLen)), volLen) * 1.4826
volatility = volSmooth > 1 ? ta.ema(_mad, volSmooth) : _mad

upper = srcBase + volatility * mult
lower = srcBase - volatility * mult[/pine]

This creates adaptive upper and lower bands around every baseline. A bullish state triggers when price closes above the upper band. A bearish state triggers when price closes below the lower band.

Each baseline receives a score:

[pine]score := close > upper_band ? 1 : close < lower_band ? -1 : score[1]
[/pine]
The five scores are then averaged into the final output:

[pine]tpi_score = math.avg(score_1, score_2, score_3, score_4, score_5)
[/pine]
A positive final score means most baselines are in bullish expansion. A negative score means most baselines are in bearish expansion.

[b]3. Key Features
[/b]
[list=1]
[*]Multi-baseline trend model using five different smoothing structures.

[*]Adaptive volatility bands based on residual MAD-style volatility.

[*]Final TPI-style score showing the average bullish or bearish state.

[*]Optional plotting for each baseline’s upper and lower bands.

[*]Candle coloring and histogram visualization for quick regime identification.
[/list]

[b]4. Use
[/b]
Use it to identify when price is breaking away from several adaptive baseline models at the same time. A positive score suggests price is trading above the majority of its volatility-adjusted baselines, indicating bullish expansion. A negative score suggests price is trading below the majority of its baselines, indicating bearish expansion.

The individual baseline plots can be enabled when you want to inspect which smoothing model is driving the signal. When most baseline scores agree, the final score becomes more decisive. When the score is mixed or near zero, price is usually inside its adaptive fair-value zone and has not confirmed a clear directional regime.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sewwman

//@version=6
indicator("Adaptive Baseline Suite | NAL", "Adaptive Baseline Suite", overlay = false, precision = 2)


//                                     ███╗   ██╗ █████╗ ██╗
//                                     ████╗  ██║██╔══██╗██║
//                                     ██╔██╗ ██║███████║██║
//                                     ██║╚██╗██║██╔══██║██║
//                                     ██║ ╚████║██║  ██║███████╗
//                                     ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝

//═══════════════════ ◈ Library ◈ ═══════════════════

import TradingView/ta/12

//═══════════════════ ◈ Colors ◈ ═══════════════════

col_mode = input.string("Standard", title = "Color Mode", group = "Visuals", options = ["Standard", "Nordic", "Simple"])

[col_up, col_dn, col_nu] = switch col_mode
    "Standard"  => [color.rgb(0, 255, 200), color.rgb(32, 94, 144), color.gray]
    "Nordic"    => [color.rgb(46, 161, 255), color.rgb(150, 154, 169), color.gray]
    "Simple"    => [color.lime, color.red, color.gray]

//═══════════════════ ◈ Inputs ◈ ═══════════════════

GG = "Baseline Settings (5)"
GO = "Universal Settings"
GV = "Visual Settings"

baseline1i  = input.int(35, "(1) Kijun Sen Length", group = GG)
baseline2i  = input.int(40, "(2) DEMA Length", group = GG)
baseline3i  = input.int(35, "(3) Median Length", group = GG)
baseline4i  = input.float(0.7, "(4) Laguerre Alpha", minval=0, maxval=0.99, step=0.01, group = GG)
baseline5is = input.float(5, "(5) Gaussian Sigma", minval=1, maxval=20, step=0.2, group = GG)
baseline5i  = input.int(12, "(5) Gaussian Length", group = GG)

source     = input.source(close, "Source", group = GO)
volLen     = input.int(21, "Volatility Length", group = GO)
volSmooth  = input.int(15, "Volatility Smoothing EMA", group = GO)
mult       = input.float(1.2, "Multiplier", step=0.1, group = GO)

plot1      = input.bool(false, "Plot Kijun Sen", group = GV)
plot2      = input.bool(false, "Plot DEMA", group = GV)
plot3      = input.bool(false, "Plot Median", group = GV)
plot4      = input.bool(false, "Plot Laguerre Filter", group = GV)
plot5      = input.bool(false, "Plot Gaussian Filter", group = GV)

//═══════════════════ ◈ Baseline Calculations ◈ ═══════════════════

//Baseline #1: Kijun Sen
baseline_1 = math.avg(ta.lowest(baseline1i), ta.highest(baseline1i))

//Baseline #2: DEMA
baseline_2 = ta.dema(source, baseline2i)

//Baseline #3: Median
baseline_3 = ta.median(source, baseline3i)

//Baseline #4: Laguerre Filter
f_laguerre(src, alpha) =>
    var float L0 = 0.0
    var float L1 = 0.0
    var float L2 = 0.0
    var float L3 = 0.0

    L0 := alpha * src + (1.0 - alpha) * nz(L0[1])
    L1 := -(1.0 - alpha) * L0 + nz(L0[1]) + (1.0 - alpha) * nz(L1[1])
    L2 := -(1.0 - alpha) * L1 + nz(L1[1]) + (1.0 - alpha) * nz(L2[1])
    L3 := -(1.0 - alpha) * L2 + nz(L2[1]) + (1.0 - alpha) * nz(L3[1])

    (L0 + 2.0 * L1 + 2.0 * L2 + L3) / 6.0

baseline_4 = f_laguerre(source, baseline4i)

//Baseline #5: Gaussian Filter
gaussianFilter(src, len, sigma) =>
    totalWeight = 0.0
    weightedSum = 0.0
    for i = 0 to len - 1
        weight = math.exp(-0.5 * math.pow((i - (len - 1) / 2) / sigma, 2))
        totalWeight += weight
        weightedSum += src[i] * weight
    weightedSum / totalWeight
baseline_5 = gaussianFilter(source, baseline5i, baseline5is)

//═══════════════════ ◈ Volatility Calculations ◈ ═══════════════════

//Volatility Calculation (credits to Uptrick for the methodology)
f_volatility_bands(srcPrice, srcBase) =>
    residual = srcPrice - srcBase

    _mad   = ta.sma(math.abs(residual - ta.sma(residual, volLen)), volLen) * 1.4826

    volatility = volSmooth > 1 ? ta.ema(_mad, volSmooth) : _mad

    upper = srcBase + volatility * mult
    lower = srcBase - volatility * mult

    [upper, lower]
    
//═══════════════════ ◈ Bands ◈ ═══════════════════

[upper_1, lower_1] = f_volatility_bands(source, baseline_1)
[upper_2, lower_2] = f_volatility_bands(source, baseline_2)
[upper_3, lower_3] = f_volatility_bands(source, baseline_3)
[upper_4, lower_4] = f_volatility_bands(source, baseline_4)
[upper_5, lower_5] = f_volatility_bands(source, baseline_5)

//═══════════════════ ◈ Signal Processing ◈ ═══════════════════

f_score(upper_band, lower_band) =>
    src = close
    score = 0
    score := src > upper_band ? 1 : src < lower_band ? -1 : score[1]
    score

score_1 = f_score(upper_1, lower_1)
score_2 = f_score(upper_2, lower_2)
score_3 = f_score(upper_3, lower_3)
score_4 = f_score(upper_4, lower_4)
score_5 = f_score(upper_5, lower_5)

tpi_score    = math.avg(score_1, score_2, score_3, score_4, score_5)

//═══════════════════ ◈ Plots & Colors ◈ ═══════════════════

f_col(src) =>
    src == 1 ? col_up : col_dn

col = tpi_score > 0 ? col_up : col_dn

s = plot(tpi_score, "Final Score", style = plot.style_histogram, color = col)
o = plot(0, "Zero Line", color=color.gray, display = display.pane)
fill(s, o, top_value = 0, bottom_value = -1, top_color = tpi_score < 0 ? color.new(col_dn, 100) : na, bottom_color = tpi_score < 0 ? col_dn : na)
fill(s, o, top_value = 1, bottom_value = 0, top_color = tpi_score > 0 ? col_up : na, bottom_color = tpi_score > 0 ? color.new(col_up, 100) : na)

plotcandle(open, high, low, close, "Candle", col, col, bordercolor = col, display = display.pane, force_overlay = true)

plot(plot1 ? upper_1 : na, "Kijun Sen - Upper Band", color = f_col(score_1), force_overlay = true), plot(plot1 ? lower_1 : na, "Kijun Sen - Lower Band", color = f_col(score_1), force_overlay = true)
plot(plot2 ? upper_2 : na, "DEMA - Upper Band", color = f_col(score_2), force_overlay = true), plot(plot2 ? lower_2 : na, "DEMA - Lower Band", color = f_col(score_2), force_overlay = true)
plot(plot3 ? upper_3 : na, "Median - Upper Band", color = f_col(score_3), force_overlay = true), plot(plot3 ? lower_3 : na, "Median - Lower Band", color = f_col(score_3), force_overlay = true)
plot(plot4 ? upper_4 : na, "Laguerre Filter - Upper Band", color = f_col(score_4), force_overlay = true), plot(plot4 ? lower_4 : na, "Laguerre Filter - Lower Band", color = f_col(score_4), force_overlay = true)
plot(plot5 ? upper_5 : na, "Gaussian Filter - Upper Band", color = f_col(score_5), force_overlay = true), plot(plot5 ? lower_5 : na, "Gaussian Filter - Lower Band", color = f_col(score_5), force_overlay = true)

plot(score_1, "#1: Kijun Sen Score", color = f_col(score_1), display = display.status_line)
plot(score_2, "#2: DEMA Score", color = f_col(score_2), display = display.status_line)
plot(score_3, "#3: Median Score", color = f_col(score_3), display = display.status_line)
plot(score_4, "#4: Laguerre Filter Score", color = f_col(score_4), display = display.status_line)
plot(score_5, "#5: Gaussian Filter Score", color = f_col(score_5), display = display.status_line)
````

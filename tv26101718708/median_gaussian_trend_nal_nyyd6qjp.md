# Median Gaussian Trend | NAL

- url: https://www.tradingview.com/script/nYyd6qJp-Median-Gaussian-Trend-NAL/
- type: indicator
- pine_id: PUB;e153ba9420ed448d9aa0de34451a7570
- version: 1.0

## Description

[b]1. Overview
[/b]
Median Gaussian Trend | NAL is an adaptive trend-band indicator built from a median price baseline, Gaussian smoothing, and Gaussian-weighted volatility bands.

The indicator is designed to filter raw price movement into a smoother directional structure. Instead of using a simple moving average or standard deviation channel, it first compresses price through a median calculation, then applies Gaussian smoothing to create a cleaner baseline. Around that baseline, it builds adaptive upper and lower bands using Gaussian-weighted deviation.

The result is a robust, smooth trend regime tool that identifies when price breaks outside its filtered volatility structure.


2. Calculation

The indicator starts by calculating a median of the selected source. This helps reduce noise by focusing on the central value of recent price action instead of reacting directly to every candle.

That median value is then passed through a Gaussian filter. The Gaussian filter gives more structured weighting to the lookback window, producing a smoother baseline while still preserving directional movement.

The indicator then calculates a Gaussian-weighted deviation around the smoothed median baseline. This creates a custom volatility measurement that is more aligned with the filtered baseline rather than raw price alone.

The upper and lower bands are then built around the Gaussian-smoothed median. The script allows separate upper and lower multipliers, which lets the band structure be asymmetric if needed.

[pine]upper = median_base + sd_range * sd_mul
lower = median_base - sd_range * sd_mulb[/pine]

A bullish state triggers when price closes above the upper band. A bearish state triggers when price closes below the lower band. When price remains inside the bands, the previous regime is held.


3. Key Features

[list=1]
[*]Median-based price filtering.
[*]Gaussian-smoothed baseline.
[*]Gaussian-weighted volatility deviation.
[*]Adaptive upper and lower trend bands.
[*]Separate upper and lower band multipliers.
[*]State-based candle coloring, band coloring, glow effect, and directional fills.
[/list]

4. Use

Median Gaussian Trend is designed to identify when price escapes its smoothed median-volatility structure. A close above the upper band reflects bullish expansion, while a close below the lower band reflects bearish expansion.

The median component helps reduce noisy price behavior, while the Gaussian smoothing and deviation engine create a more refined trend envelope. This makes the indicator useful for reading directional structure without relying on a raw moving average channel.

This indicator is best used as a specialized module within a complete strategy framework. Its role is to isolate a filtered volatility-trend layer of price behavior, where the real value comes from how the signal is integrated into a broader process for regime, timing, and execution.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NordicAlphaLab

//@version=6
indicator("Median Gaussian Trend | NAL", shorttitle = "Median Gaussian Trend", overlay = true)

//                                     ███╗   ██╗ █████╗ ██╗
//                                     ████╗  ██║██╔══██╗██║
//                                     ██╔██╗ ██║███████║██║
//                                     ██║╚██╗██║██╔══██║██║
//                                     ██║ ╚████║██║  ██║███████╗
//                                     ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝


// ══════════════════════════════════════ ◈ Visuals & Tooltips ◈ ══════════════════════════════════════

col_mode = input.string("Standard", title = "Color Mode", group = "Visuals", options = ["Standard", "Nordic", "Simple"])

[col_up, col_dn, col_nu] = switch col_mode
    "Standard"  => [color.rgb(0, 255, 200), color.rgb(32, 94, 144), color.gray]
    "Nordic"    => [color.rgb(46, 161, 255), color.rgb(150, 154, 169), color.gray]
    "Simple"    => [color.lime, color.red, color.gray]

// ══════════════════════════════════════ ◈ Functions ◈ ══════════════════════════════════════

//Gaussian Line
gaussianFilter(src, len, sigma) =>
    totalWeight = 0.0
    weightedSum = 0.0
    for i = 0 to len - 1
        weight = math.exp(-0.5 * math.pow((i - (len - 1) / 2) / sigma, 2))
        totalWeight += weight
        weightedSum += src[i] * weight
    weightedSum / totalWeight


//Gaussian Deviation
gaussianDeviation(src, period) =>
    weights = array.new_float()
    sumw    = 0.0
    for i = 0 to period - 1
        w = math.exp(-math.pow((i / period) / 2,2))
        array.push(weights, w)
        sumw += w

    wmean = 0.0
    for i = 0 to period - 1
        wmean += src[i] * array.get(weights, i)
    wmean := wmean / sumw

    wvar = 0.0
    for i = 0 to period - 1
        diff = src[i] - wmean
        wvar += math.pow(diff,2) * array.get(weights, i)
    math.sqrt(wvar / sumw)

// ══════════════════════════════════════ ◈ Inputs ◈ ══════════════════════════════════════

fil_src      = input.source(close, "Source")
base_len     = input.int(16, "Gaussian Length", inline = "GAUS")
gaussian_sig = input.float(5, "Sigma", step = 0.1, inline = "GAUS")
sd_len       = input.int(20,"Gaussian Volatility Length")
sd_mul       = input.float(2.5,"Upper Band", step = 0.1, inline = "BB")
sd_mulb      = input.float(2,"Lower Band", step = 0.1, inline = "BB")

// ══════════════════════════════════════ ◈ Trend Logic ◈ ══════════════════════════════════════

//SD Bands
median_raw  = ta.median(fil_src, base_len)
median_base = gaussianFilter(median_raw, base_len, gaussian_sig)
sd_range    = gaussianDeviation(median_base, sd_len)

upper = median_base + sd_range * sd_mul
lower = median_base - sd_range * sd_mulb
midli = math.avg(upper, lower)

//Signal
NAL = 0
NAL := close > upper ? 1 : close < lower ? -1 : NAL[1]

// ══════════════════════════════════════ ◈ Plots ◈ ══════════════════════════════════════

col = NAL == 1 ? col_up : NAL == -1 ? col_dn : col_nu 

plotcandle(open, high, low, close, "Bar Color", col, col, bordercolor = col, display = display.pane, force_overlay = true)

//plot(base)
u = plot(upper,color = col, title = "Upper Band")
l = plot(lower,color = col, title = "Lower Band")
m = plot(midli,color = color.white, display = display.none)

plot(upper, title = "Upper Band Glow", color = color.new(col, 50), display = display.pane, linewidth = 5)
plot(lower, title = "Lower Band Glow", color = color.new(col, 50), display = display.pane, linewidth = 5)


fill(u, m, upper, midli,  color.new(col, 30), color.new(col, 100))
fill(l, m, lower, midli,  color.new(col, 30), color.new(col, 100))
````

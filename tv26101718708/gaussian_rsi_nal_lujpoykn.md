# Gaussian RSI | NAL

- url: https://www.tradingview.com/script/luJpoyKn-Gaussian-RSI-NAL/
- type: indicator
- pine_id: PUB;6a462c1d07ec4242aecd3d45d72fc84b
- version: 1.0

## Description

[b]1. Overview
[/b]
Gaussian RSI | NAL is a smoothed momentum-regime indicator built around an RSI engine filtered through a Gaussian weighting model. Instead of plotting raw RSI, the indicator applies Gaussian smoothing to reduce noise and create a cleaner momentum line.

The signal is then refined with an optional Gaussian confluence filter. This adds a second smoothing layer that acts as a directional confirmation structure, helping separate stronger momentum regimes from weaker internal fluctuations.


[b]2. Calculation
[/b]
The indicator starts by calculating RSI from the selected source. This creates the base momentum reading used by the rest of the model.

The RSI is then passed through a Gaussian filter. The Gaussian filter weights the lookback window using a bell-curve style distribution, creating a smoother momentum line while still preserving directional movement.

A second Gaussian filter can also be applied as a confluence line. This creates a slower reference layer for the Gaussian RSI, allowing the indicator to judge whether the current RSI structure is aligned with its own smoothed trend.

The bullish condition requires the Gaussian RSI to move above the upper threshold. When confluence is enabled, the Gaussian RSI must also be above the Gaussian confluence line.

The bearish condition requires the Gaussian RSI to move below the lower threshold. When confluence is enabled, the Gaussian RSI must also be below the Gaussian confluence line.

The final state holds its previous direction when neither condition is active. This creates a cleaner regime output instead of constantly flipping to neutral between threshold zones.


3. Key Features

[list=1]
[*]Gaussian-smoothed RSI momentum engine.
[*]Optional Gaussian confluence filter.
[*]Upper and lower threshold-based regime detection.
[*]State-based candle coloring and RSI coloring.
[*]Glow-style RSI plot, regime fills, confluence line, and transition labels.
[*]Designed to reduce raw RSI noise while preserving momentum structure.
[/list]


4. Use

Gaussian RSI is designed to identify when momentum begins shifting into a stronger bullish or bearish regime. A move above the upper threshold reflects bullish momentum pressure, while a move below the lower threshold reflects bearish momentum pressure.

The confluence filter adds an additional layer of structure by requiring the Gaussian RSI to align with its own smoother reference line. This can help separate cleaner momentum expansions from weaker internal movement.

This indicator is best used as a specialized momentum module within a complete strategy framework. Its role is to isolate a refined RSI-based momentum layer, where the full value comes from how the signal is integrated into a broader process for regime, timing, and execution.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NordicAlphaLab

//@version=6
indicator("Gaussian RSI | NAL", shorttitle = "Gaussian RSI", overlay = false)


//                                     ███╗   ██╗ █████╗ ██╗
//                                     ████╗  ██║██╔══██╗██║
//                                     ██╔██╗ ██║███████║██║
//                                     ██║╚██╗██║██╔══██║██║
//                                     ██║ ╚████║██║  ██║███████╗
//                                     ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝


// ══════════════════════════════════════ ◈ Visuals ◈ ══════════════════════════════════════

group_visuals = "Visuals"
col_mode = input.string("Standard", title = "Color Mode", group = group_visuals, options = ["Standard", "Nordic", "Simple"])

[col_up, col_dn, col_nu] = switch col_mode
    "Standard" => [color.rgb(0, 255, 200), color.rgb(32, 94, 144), color.gray]
    "Nordic"   => [color.rgb(46, 161, 255), color.rgb(150, 154, 169), color.gray]
    "Simple"   => [color.lime, color.red, color.gray]

// ══════════════════════════════════════ ◈ Inputs ◈ ══════════════════════════════════════

group_rsi = "Gaussian RSI"
src = input.source(close, "Source", group = group_rsi)
rsiLen = input.int(14, "RSI Length", minval = 1, group = group_rsi)
gaussLen = input.int(10, "Gaussian Length", minval = 1, inline = "GG", group = group_rsi)
gaussSig = input.float(5.0, "Sigma", minval = 0.1, step = 0.1, inline = "GG", group = group_rsi)

group_signal = "Signal Logic"
upperThreshold = input.float(55.0, "Upper Threshold", step = 0.5, group = group_signal)
lowerThreshold = input.float(52.5, "Lower Threshold", step = 0.5, group = group_signal)
useGaussianConfluence = input.bool(true, "Require Gaussian Filter Confluence?", group = group_signal)
confluenceLen = input.int(21, "Confluence Gaussian Length", minval = 1, inline = "CF", group = group_signal)
confluenceSig = input.float(5.0, "Sigma", minval = 0.1, step = 0.1, inline = "CF", group = group_signal)

// ══════════════════════════════════════ ◈ Functions ◈ ══════════════════════════════════════

gaussianFilter(series float source, simple int len, simple float sigma) =>
    float totalWeight = 0.0
    float weightedSum = 0.0

    for i = 0 to len - 1
        float weight = math.exp(-0.5 * math.pow((i - (len - 1) / 2.0) / sigma, 2.0))
        totalWeight += weight
        weightedSum += nz(source[i]) * weight

    totalWeight != 0.0 ? weightedSum / totalWeight : source

// ══════════════════════════════════════ ◈ Trend Logic ◈ ══════════════════════════════════════

float RSI = ta.rsi(src, rsiLen)
float Gauss_RSI = gaussianFilter(RSI, gaussLen, gaussSig)
float Gaussian_Confluence = gaussianFilter(Gauss_RSI, confluenceLen, confluenceSig)

bool bullSignal = Gauss_RSI > upperThreshold and (not useGaussianConfluence or Gauss_RSI > Gaussian_Confluence)
bool bearSignal = Gauss_RSI < lowerThreshold and (not useGaussianConfluence or Gauss_RSI < Gaussian_Confluence)

int NAL = 0
NAL := bullSignal ? 1 : bearSignal ? -1 : nz(NAL[1], 0)

// ══════════════════════════════════════ ◈ Plots ◈ ══════════════════════════════════════

color col = NAL == 1 ? col_up : NAL == -1 ? col_dn : col_nu

plotcandle(open, high, low, close, "Bar Color", col, col, bordercolor = col, force_overlay = true, display = display.pane)

upperPlot = plot(upperThreshold, "Long Threshold", color = color.new(col_up, 25), linewidth = 1)
lowerPlot = plot(lowerThreshold, "Short Threshold", color = color.new(col_dn, 25), linewidth = 1)
midPlot = plot(50.0, "Midline", color = color.new(color.white, 85), linewidth = 1, display = display.pane)

rsiGlow = plot(Gauss_RSI, "Gaussian RSI Glow", color = color.new(col, 75), linewidth = 7, display = display.pane)
rsiPlot = plot(Gauss_RSI, "Gaussian RSI", color = col, linewidth = 2)

plot(useGaussianConfluence ? Gaussian_Confluence : na, "Gaussian Confluence", color = color.new(color.white, 35), linewidth = 1)

fill(upperPlot, midPlot, color.new(col_up, 90), title = "Upper Zone")
fill(lowerPlot, midPlot, color.new(col_dn, 90), title = "Lower Zone")
fill(rsiPlot, midPlot, color.new(col, 92), title = "RSI Regime Fill")

bullish_transition = NAL == 1 and NAL[1] == -1
bearish_transition = NAL == -1 and NAL[1] == 1

plotshape(bullish_transition, "Bullish Transition", style = shape.triangleup, location = location.belowbar, text = "𝓑𝓾𝔂", color = col_up, textcolor = col_up, size = size.tiny, force_overlay = true, display = display.pane)
plotshape(bearish_transition, "Bearish Transition", style = shape.triangledown, location = location.abovebar, text = "𝓢𝓮𝓵𝓵", color = col_dn, textcolor = col_dn, size = size.tiny, force_overlay = true, display = display.pane)
````

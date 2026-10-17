# Sigmoid RSI | NAL

- url: https://www.tradingview.com/script/ONhiTlru-Sigmoid-RSI-NAL/
- type: indicator
- pine_id: PUB;1f1afed85dac42b08119b9109c5df0a8
- version: 1.0

## Description

1. Overview

[i]Sigmoid RSI | NAL[/i] is an adaptive momentum-regime indicator built from a transformed RSI engine, sigmoid weighting, and two independently adaptive smoothing layers.

Instead of using raw RSI values directly, the indicator recenters RSI around its midpoint and passes the result through a sigmoid transformation. This reshapes the oscillator into a smoother 0–100 momentum curve while preserving directional pressure around the central regime.

The final signal is refined through volatility-sensitive smoothing and an optional momentum-driven signal line, creating a more adaptive structure than a standard RSI with fixed smoothing.

2. Calculation

The indicator starts by calculating RSI from the selected source and centering it around 50. This converts the standard RSI range into a positive and negative momentum input around the neutral midpoint.

[pine]rsiRaw  = ta.rsi(src, rsiLen)
rsiNorm = rsiRaw - 50.0[/pine]

The centered RSI is then passed through a sigmoid function. The sigmoid transformation compresses extreme values and smoothly maps the momentum input back into a 0–100 range.

[pine]sigmoidRSIRaw = 100.0 * sigmoid_function(rsiNorm)[/pine]

The indicator then builds two separate adaptive feeds.

The volatility feed measures changes in ATR, while the momentum feed measures changes in a separate RSI calculation.

[pine]momentumFeed   = ta.change(ta.rsi(src, modLen), changeL)
volatilityFeed = ta.change(ta.atr(modLen), changeL)[/pine]

These feeds are used inside a sigmoid-weighted EMA. The sigmoid output adjusts the smoothing alpha dynamically, allowing the moving average to respond differently as the input environment changes.

[pine]sigmoidWeight = sigmoid_function(sigmoidFeed)
adaptiveAlpha = f_clamp(baseAlpha * (0.5 + sigmoidWeight), 0.01, 1.0)[/pine]

The main Sigmoid RSI is smoothed using the volatility feed. This makes its response sensitive to changes in the volatility environment.

[pine]sigmoidRSI = f_sigmoid_ema(sigmoidRSIRaw, volatilityFeed, rsiSmoothLen)[/pine]

A second adaptive smoothing layer creates the signal line using the momentum feed. This gives the indicator an internal directional reference that reacts to changes in momentum rather than using a fixed moving average alone.

[pine]sigmoidRSISignal = f_sigmoid_ema(sigmoidRSI, momentumFeed, rsiSignalLen)[/pine]

The bullish state requires the Sigmoid RSI to rise above the upper threshold. When confluence is enabled, it must also remain above its adaptive signal line.

The bearish state requires the Sigmoid RSI to fall below the lower threshold and, when enabled, remain below the signal line.

[pine]NAL := sigmoidRSI > longThres and (sigmoidRSI > sigmoidRSISignal or not boolCon) ? 1 : sigmoidRSI < shortThres and (sigmoidRSI < sigmoidRSISignal or not boolCon) ? -1 : NAL[1][/pine]

When neither condition is active, the previous directional state is preserved.

3. Key Features

[list=1]
[*]Sigmoid-transformed RSI momentum engine.
[*]Adaptive volatility-sensitive RSI smoothing.
[*]Momentum-driven adaptive signal line.
[*]Dynamic smoothing alpha generated through sigmoid weighting.
[*]Upper and lower threshold regime detection.
[*]Optional signal-line confluence.
[*]Glow plot, threshold fills, candle coloring, bar coloring, and transition labels.
[/list]

4. Use

Sigmoid RSI is designed to identify when momentum transitions into a more established bullish or bearish regime.

A move above the upper threshold reflects bullish momentum expansion, while a move below the lower threshold reflects bearish momentum deterioration. The adaptive signal line adds another layer of internal structure by measuring whether the transformed RSI remains aligned with its momentum-driven smoothing path.

The indicator’s behavior is shaped by both volatility and momentum changes, allowing its response to shift with the underlying environment rather than remaining mechanically fixed.

Sigmoid RSI is designed as a specialized momentum component within a complete strategy architecture. Its real value lies in how its adaptive regime state is integrated into a broader decision process, where several layers of market behavior are evaluated together.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NordicAlphaLab

//@version=6
indicator("Sigmoid RSI | NAL", "Sigmoid RSI", overlay = false, precision = 2)


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
    "Nordic"    => [color.rgb(0, 96, 175), color.rgb(150, 154, 169), color.gray]
    "Simple"    => [color.lime, color.red, color.gray]

// ══════════════════════════════════════ ◈ Inputs ◈ ══════════════════════════════════════

Grsi = "RSI"
Gsig = "Sigmoid Weights"
Gcon = "Confluence"

Tp = "Measures how much the selected Weight Source has changed compared with its value X bars ago. Lower values react faster and may be noisier; higher values respond more slowly and emphasize broader shifts.",

src = input.source(close, "Source", group = Grsi)
rsiLen = input.int(9, "RSI Length", minval = 1, group = Grsi)
rsiSmoothLen = input.int(14, "Sigmoid RSI Smoothing", minval = 1, group = Grsi)
longThres  = input.int(72, "Long Threshold", minval = 1, group = Grsi)
shortThres = input.int(40, "Short Threshold", minval = 1, group = Grsi)

modLen = input.int(14, "Weight Lookback", minval = 1, group = Gsig)
changeL = input.int(2, "Weight Change Window (Bars)", minval = 1, group = Gsig, tooltip = Tp)

boolCon = input.bool(true, "Sigmoid EMA Confluence?", group = Gcon)
rsiSignalLen = input.int(40, "Signal Length", minval = 1, group = Gcon)

// ══════════════════════════════════════ ◈ Logic ◈ ══════════════════════════════════════

f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(value, maxValue))

sigmoid_function(float x) =>
    float clamped = f_clamp(nz(x, 0.0), -60.0, 60.0)
    1.0 / (1.0 + math.exp(-clamped))

f_sigmoid_ema(series float source, series float sigmoidFeed, simple int emaLen) =>
    float sigmoidWeight = sigmoid_function(sigmoidFeed)
    float baseAlpha = 2.0 / (emaLen + 1.0)
    float adaptiveAlpha = f_clamp(baseAlpha * (0.5 + sigmoidWeight), 0.01, 1.0)

    float sigmoidEma = na
    sigmoidEma := na(sigmoidEma[1]) ? source : sigmoidEma[1] + adaptiveAlpha * (source - sigmoidEma[1])
    sigmoidEma

float rsiRaw  = ta.rsi(src, rsiLen)
float rsiNorm = rsiRaw - 50.0
float sigmoidRSIRaw = 100.0 * sigmoid_function(rsiNorm)

float momentumFeed = ta.change(ta.rsi(src, modLen), changeL)
float volatilityFeed = ta.change(ta.atr(modLen), changeL)

float sigmoidRSI = f_sigmoid_ema(sigmoidRSIRaw, volatilityFeed, rsiSmoothLen)
float sigmoidRSISignal = f_sigmoid_ema(sigmoidRSI, momentumFeed, rsiSignalLen)

var int NAL = 0
NAL := sigmoidRSI > longThres and (sigmoidRSI > sigmoidRSISignal or not boolCon) ? 1 : sigmoidRSI < shortThres and (sigmoidRSI < sigmoidRSISignal or not boolCon) ? -1 : NAL[1]

// ══════════════════════════════════════ ◈ Plots ◈ ══════════════════════════════════════

// Threshold state
rsi_bullish = sigmoidRSI > longThres
rsi_bearish = sigmoidRSI < shortThres

color plotColor = NAL == 1 ? col_up : NAL == -1 ? col_dn : col_nu

plot(sigmoidRSI, "Sigmoid RSI", plotColor, 2) 
plot(sigmoidRSI, "Sigmoid RSI Glow", color = color.new(plotColor, 78), linewidth = 7, display = display.pane)

plot(sigmoidRSISignal, "Sigmoid RSI MA", color.gray)

p_long  = plot(longThres, "Long Threshold", color = col_up)
p_short = plot(shortThres, "Short Threshold", color = col_dn)
p_mid   = plot(50.0, "Midline", color = color.new(col_nu, 75), linewidth = 1, display = display.pane)

p_upper_fill = plot(rsi_bullish ? sigmoidRSI : na, "Upper Fill Anchor", color = color.new(col_up, 100), display = display.pane)
p_lower_fill = plot(rsi_bearish ? sigmoidRSI : na, "Lower Fill Anchor", color = color.new(col_dn, 100), display = display.pane)

fill(p_upper_fill, p_long, color = color.new(col_up, 86))
fill(p_lower_fill, p_short, color = color.new(col_dn, 86))

plotcandle(open, high, low, close, "Candles", color = plotColor, wickcolor = plotColor, bordercolor = plotColor, force_overlay = true, display = display.pane)
barcolor(plotColor)

bullish_transition = NAL == 1 and NAL[1] == -1
bearish_transition = NAL == -1 and NAL[1] == 1

plotshape(bullish_transition, "Bullish Transition", style = shape.triangleup, location = location.belowbar, text = "𝓑𝓾𝔂", color = col_up, textcolor = col_up, size = size.tiny, force_overlay = true, display = display.pane)
plotshape(bearish_transition, "Bearish Transition", style = shape.triangledown, location = location.abovebar, text = "𝓢𝓮𝓵𝓵", color = col_dn, textcolor = col_dn, size = size.tiny, force_overlay = true, display = display.pane)
````

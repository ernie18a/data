# Sigmoid Alpha Bands | NAL

- url: https://www.tradingview.com/script/Tt6sPzzQ-Sigmoid-Alpha-Bands-NAL/
- type: indicator
- pine_id: PUB;a0c8fd60a1ff4ebba31af29ae89b206a
- version: 1.0

## Description

1. Overview

[i]Sigmoid Alpha Bands | NAL[/i] is an adaptive trend and volatility framework built around a sigmoid-weighted EMA baseline and dynamically adjusted volatility bands.

Instead of smoothing price with a fixed alpha, the indicator modifies its responsiveness using a selected market feed. Momentum, volatility, volume, or price disparity can control how quickly the baseline adapts to changing conditions.

The surrounding bands can also respond asymmetrically to bullish and bearish return shocks. This allows the upper and lower boundaries to develop independently rather than remaining equally spaced around the baseline.

2. Calculation

The indicator begins by selecting the market variable used to control the baseline’s adaptive smoothing weight.

Momentum measures changes in RSI, volatility measures changes in ATR, volume measures changes in smoothed volume, and disparity measures changes in price relative to its EMA.

[pine]sigmoidFeed = switch sigFeed
"Momentum"   => ta.change(ta.rsi(src, modLen), changeL)
"Volatility" => ta.change(ta.atr(modLen), changeL)
"Volume"     => ta.change(ta.ema(volume, modLen), changeL)
"Disparity"  => ta.change(src / ta.ema(src, modLen), changeL)[/pine]

The selected feed is passed through a sigmoid function, converting it into a bounded adaptive weight.

That weight modifies the standard EMA alpha. When the sigmoid weight increases, the baseline can respond more quickly. When it decreases, the baseline becomes more stable.

[pine]sigmoidWeight = sigmoid_function(sigmoidFeed)
baseAlpha = 2.0 / (emaLen + 1.0)
adaptiveAlpha = f_clamp(baseAlpha * (0.5 + sigmoidWeight), 0.01, 1.0)[/pine]

The final adaptive baseline is calculated recursively using the changing alpha.

[pine]sigmoid_ema = f_sigmoid_ema(src, sigmoidFeed, sigLen)[/pine]

The indicator then calculates its base volatility using one of four methods: standard deviation, ATR, mean absolute deviation, or median absolute deviation.

[pine]volatilityRaw = switch volFeed
"SD"       => ta.stdev(src, volLen)
"ATR"      => ta.atr(volLen)
"MeanAD"   => ta.dev(src, volLen)
"MedianAD" => f_median_ad(src, volLen)[/pine]

This raw volatility value is also processed through a sigmoid-adaptive smoothing layer. The result becomes the symmetric volatility foundation used by the bands.

[pine]volatilityFeed = ta.change(volatilityRaw / nz(ta.ema(volatilityRaw, volLen), volatilityRaw), changeL)
volatility = f_sigmoid_ema(volatilityRaw, volatilityFeed, volLen)[/pine]

When asymmetric bands are enabled, positive and negative log-return shocks are separated into bullish and bearish variance components.

[pine]bullShock = math.pow(math.max(ret, 0.0), 2.0)
bearShock = math.pow(math.max(-ret, 0.0), 2.0)
totalShock = bullShock + bearShock[/pine]

Each shock component is adaptively smoothed and compared with total variance. This produces separate upper and lower volatility multipliers.

The multipliers are constrained around their longer-term average so the bands can adapt without becoming unstable.

[pine]upperVol = math.max(nz(symmetricVol, syminfo.mintick) * upperMultAdj, syminfo.mintick)
lowerVol = math.max(nz(symmetricVol, syminfo.mintick) * lowerMultAdj, syminfo.mintick)[/pine]

The final bands are positioned around the sigmoid-adaptive baseline.

[pine]upperBand = sigmoid_ema + finalUpper * volMul
lowerBand = sigmoid_ema - finalLower * volMul[/pine]

A bullish state is established when price closes above the upper band. A bearish state is established when price closes below the lower band. While price remains between the boundaries, the existing state is preserved.

[pine]if close > upperBand
NAL := 1

if close < lowerBand
NAL := -1[/pine]

3. Key Features

[list=1]
[*]Sigmoid-weighted adaptive EMA baseline.
[*]Selectable momentum, volatility, volume, or disparity adaptation feed.
[*]Multiple volatility calculation methods.
[*]Optional asymmetric bullish and bearish volatility bands.
[*]Independent modeling of positive and negative return shocks.
[*]Controlled asymmetry through long-term multiplier normalization.
[*]State-based candle coloring, layered volatility hulls, glow effects, and directional fills.
[/list]

4. Use

Sigmoid Alpha Bands is designed to identify when price expands beyond an adaptively smoothed volatility structure.

A close above the upper boundary reflects bullish expansion beyond the current baseline and volatility regime. A close below the lower boundary reflects bearish expansion beneath that structure.

The asymmetric mode allows the indicator to recognize that bullish and bearish volatility do not always develop with equal intensity. As market pressure changes, each side of the channel can adjust independently while remaining anchored to the same adaptive baseline.

This indicator is designed as a specialized component within a complete strategy architecture. Its role is to isolate the interaction between adaptive trend, changing volatility, and directional return pressure. Its full value emerges through the way this information is integrated into a broader decision framework.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sewwman

//@version=6
indicator("Sigmoid Alpha Bands | NAL", "Sigmoid Alpha Bands", overlay = true, precision = 2)


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

// ══════════════════════════════════════ ◈ Functions ◈ ══════════════════════════════════════

f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(value, maxValue))

sigmoid_function(float x) =>
    weight = 1 / (1 + math.exp(-x))
    weight

f_array_median(array<float> values) =>
    array.sort(values, order.ascending)
    int size = array.size(values)
    int mid = int(math.floor(size / 2))
    size == 0 ? na : size % 2 == 1 ? array.get(values, mid) : math.avg(array.get(values, mid - 1), array.get(values, mid))

f_median_ad(series float source, simple int length) =>
    array<float> values = array.new_float(0)
    for i = 0 to length - 1
        if not na(source[i])
            array.push(values, source[i])

    float medianValue = f_array_median(values)

    array<float> deviations = array.new_float(0)
    for i = 0 to length - 1
        if not na(source[i]) and not na(medianValue)
            array.push(deviations, math.abs(source[i] - medianValue))

    f_array_median(deviations)

// ══════════════════════════════════════ ◈ Inputs ◈ ══════════════════════════════════════

Gsig = "Sigmoid Alpha Baseline"
Gvol = "Volatility Bands"

Tp1 = "Selects the data used to adapt the baseline's smoothing weight.\n\nMomentum: change in RSI.\nVolatility: change in ATR.\nVolume: change in EMA-smoothed volume.\nDisparity: change in price relative to its EMA.",
Tp2 = "Measures how much the selected Weight Source has changed compared with its value X bars ago. Lower values react faster and may be noisier; higher values respond more slowly and emphasize broader shifts.",
Tp3 = "When enabled, the upper and lower bands adapt independently to bullish and bearish return shocks. When disabled, both bands use the same symmetric volatility value and remain equally spaced around the baseline.",

src     = input.source(close, "Source", group = Gsig)
sigLen  = input.int(21, "Sigmoid EMA Length", group = Gsig)
sigFeed = input.string("Momentum", "Weight Source", options = ["Momentum", "Volatility", "Volume", "Disparity"], group = Gsig, tooltip = Tp1)
modLen     = input.int(14, "Weight Lookback", group = Gsig)
changeL = input.int(9, "Weight Change Window (Bars)", group = Gsig, tooltip = Tp2)

volFeed = input.string("MedianAD", "Volatiltiy Method", options = ["SD", "ATR", "MeanAD", "MedianAD"], group = Gvol)
volLen     = input.int(16, "Volatility Length", group = Gvol)
volMul  = input.float(1.5, "Volatility Multiple", step = 0.1, group = Gvol)

useAsymBands = input.bool(true, "Use Asymmetric Bands?", group = Gvol, tooltip = Tp3)
asymMaxSpread = input.float(1.0, "Maximum Asymmetry Spread", minval = 0.1, step = 0.05, group = Gvol)


// ══════════════════════════════════════ ◈ Logic ◈ ══════════════════════════════════════

//Sigmoid exponential weighted moving average
sigmoidFeed = switch sigFeed
    "Momentum"   => ta.change(ta.rsi(src, modLen), changeL)
    "Volatility" => ta.change(ta.atr(modLen), changeL)
    "Volume"     => ta.change(ta.ema(volume, modLen), changeL)
    "Disparity"  => ta.change(src / ta.ema(src, modLen), changeL)

f_sigmoid_ema(series float source, series float sigmoidFeed, simple int emaLen) =>
    float sigmoidWeight = sigmoid_function(sigmoidFeed)
    float baseAlpha = 2.0 / (emaLen + 1.0)
    float adaptiveAlpha = f_clamp(baseAlpha * (0.5 + sigmoidWeight), 0.01, 1.0)

    float sigmoidEma = na
    sigmoidEma := na(sigmoidEma[1]) ? source : sigmoidEma[1] + adaptiveAlpha * (source - sigmoidEma[1])
    sigmoidEma

float sigmoid_ema = f_sigmoid_ema(src, sigmoidFeed, sigLen)

//Volatility bands
f_asymmetric_volatility(series float source, series float symmetricVol, series float feed, simple int smoothLen) =>
    float ret = source > 0.0 and source[1] > 0.0 ? math.log(source / source[1]) : 0.0
    float spread = asymMaxSpread / 2

    float bullShock = math.pow(math.max(ret, 0.0), 2.0)
    float bearShock = math.pow(math.max(-ret, 0.0), 2.0)
    float totalShock = bullShock + bearShock

    float bullVar = f_sigmoid_ema(bullShock, feed, smoothLen)
    float bearVar = f_sigmoid_ema(bearShock, feed, smoothLen)
    float totalVar = f_sigmoid_ema(totalShock, feed, smoothLen)

    float bullRatio = totalVar > 0.0 ? math.sqrt(math.max(2.0 * bullVar / totalVar, 0.0)) : 1.0
    float bearRatio = totalVar > 0.0 ? math.sqrt(math.max(2.0 * bearVar / totalVar, 0.0)) : 1.0

    float upperMult = 1.0 + 3 * (bullRatio - 1.0)
    float lowerMult = 1.0 + 3 * (bearRatio - 1.0)

    float avgMult   = nz(ta.sma(math.avg(upperMult, lowerMult), 180), ta.sma(math.avg(upperMult, lowerMult), math.min(math.max(bar_index, 1), 180))) 

    float upperMultAdj = f_clamp(upperMult, (avgMult - spread), (avgMult + spread))
    float lowerMultAdj = f_clamp(lowerMult, (avgMult - spread), (avgMult + spread))

    float upperVol = math.max(nz(symmetricVol, syminfo.mintick) * upperMultAdj, syminfo.mintick)
    float lowerVol = math.max(nz(symmetricVol, syminfo.mintick) * lowerMultAdj, syminfo.mintick)

    [upperVol, lowerVol]


float volatilityRaw = switch volFeed
    "SD"       => ta.stdev(src, volLen)
    "ATR"      => ta.atr(volLen)
    "MeanAD"   => ta.dev(src, volLen)
    "MedianAD" => f_median_ad(src, volLen)

float volatilityFeed = ta.change(volatilityRaw / nz(ta.ema(volatilityRaw, volLen), volatilityRaw), changeL)

float volatility    = f_sigmoid_ema(volatilityRaw, volatilityFeed, volLen)

[asymUpper, asymLower] = f_asymmetric_volatility(src, volatility, volatilityFeed, sigLen)

float finalUpper = useAsymBands ? asymUpper : volatility
float finalLower = useAsymBands ? asymLower : volatility

//Final bands and scoring
upperBand = sigmoid_ema + (finalUpper * volMul)
lowerBand = sigmoid_ema - (finalLower * volMul)

var int NAL = 0
if close > upperBand
    NAL := 1

if close < lowerBand
    NAL := -1

// ══════════════════════════════════════ ◈ Plots and Visuals ◈ ══════════════════════════════════════

color col = NAL == 1 ? col_up : NAL == -1 ? col_dn : col_nu

float mid = sigmoid_ema
float width = math.max(math.abs(upperBand - mid), syminfo.mintick)
float upperShadow = upperBand + width * 0.55
float lowerShadow = lowerBand - width * 0.55

plotcandle(lowerShadow, upperShadow, lowerShadow, upperShadow, "Outer Volatility Hull", color.new(col, 96), color.new(col, 100), bordercolor = color.new(col, 100), display = display.pane, force_overlay = true)
plotcandle(lowerBand, upperBand, lowerBand, upperBand, "Inner Volatility Hull", color.new(col, 88), color.new(col, 100), bordercolor = color.new(col, 100), display = display.pane, force_overlay = true)
barcolor(col)

u = plot(upperBand, "Upper Band", color = col, linewidth = 2)
l = plot(lowerBand, "Lower Band", color = col, linewidth = 2)
m = plot(mid, "Baseline", color = color.new(color.white, 50), linewidth = 2)

plot(upperBand, "Upper Glow", color = color.new(col, 70), linewidth = 7, display = display.pane)
plot(lowerBand, "Lower Glow", color = color.new(col, 70), linewidth = 7, display = display.pane)

fill(u, m, color.new(col, 90), title = "Upper Core")
fill(m, l, color.new(col, 90), title = "Lower Core")

plotcandle(open, high, low, close, "Candles", color = col, wickcolor = col, bordercolor = col, display = display.pane, force_overlay = true)
````

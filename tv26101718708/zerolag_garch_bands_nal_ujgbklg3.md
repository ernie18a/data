# Zero-Lag GARCH Bands | NAL

- url: https://www.tradingview.com/script/UJgbKLG3-Zero-Lag-GARCH-Bands-NAL/
- type: indicator
- pine_id: PUB;b2fbfd8c66a5418fbf38ae4a5aeef8b6
- version: 1.0

## Description

[b]1. Overview
[/b]
Zero-Lag GARCH Bands | NAL is an adaptive volatility band indicator built from a Zero-Lag EMA baseline and an optimized GARCH-style volatility engine.

The indicator does not use a standard fixed-width channel. Instead, it estimates market variance through a recursive GARCH framework, smooths that volatility with a Zero-Lag EMA, and uses the result to create dynamic upper and lower bands around price structure.

The purpose of the indicator is to identify when price escapes a volatility-adjusted regime boundary, while allowing the band width to adapt to the underlying variance environment.


[b]2. Calculation
[/b]
The indicator starts by estimating volatility from lagged log returns. These returns are squared to create a variance component, which becomes the foundation of the GARCH model.

[pine]GARCH_LogReturn = math.log(close[1] / close[2])
GARCH_SquaredLogReturn = math.pow(GARCH_LogReturn, 2.0)
GARCH_RealizedVariance = ta.sma(GARCH_SquaredLogReturn, GARCH_Lookback)[/pine]

The script then searches through possible coefficient weights to find a beta/lambda value that better fits recent realized variance behavior. A second optimization loop is used to estimate gamma, which controls the long-run variance contribution.

These optimized coefficients are combined into a GARCH-style variance model using three components: long-run variance, recent shock variance, and lagged variance.

[pine]GARCH_Variance =
GARCH_Gamma * GARCH_LongRunVariance +
GARCH_Alpha * GARCH_SquaredLogReturn +
GARCH_Beta * GARCH_LaggedVariance[/pine]

After the variance estimate is created, it is smoothed using a Zero-Lag EMA. This gives the volatility engine a faster response while still reducing noise.

[pine]GARCH_ProjectedVariance = f_zlema(GARCH_Variance, GARCH_SmoothLen)
GARCH_Volatility = math.sqrt(math.max(GARCH_ProjectedVariance, 0.0))[/pine]

The baseline is also built with a Zero-Lag EMA, applied after a light EMA pre-smoothing step. This creates the central reference line for the band structure.

The final bands are created by scaling the Zero-Lag GARCH volatility against the selected source and band pressure setting. Higher band pressure creates a tighter band, while lower pressure allows the band structure to expand.

[pine]upperBand = baseline + (baseline_src / band_pressure) * GARCH_VolatilityMultiplier
lowerBand = baseline - (baseline_src / band_pressure) * GARCH_VolatilityMultiplier[/pine]

A bullish state triggers when price closes above the upper band. A bearish state triggers when price closes below the lower band. When price remains inside the bands, the previous regime is held.


[b]3. Key Features
[/b]
[list=1]
[*]Zero-Lag EMA baseline for reduced-lag price structure.
[*]Optimized GARCH-style volatility engine.
[*]Adaptive variance model using shock, lagged, and long-run components.
[*]Zero-Lag smoothing applied to projected volatility.
[*]Dynamic upper and lower volatility bands.
[*]Band pressure control for adjusting channel tightness.
[*]State-based candle coloring, band coloring, glow effect, and directional fills.
[/list]


[b]4. Use
[/b]
Zero-Lag GARCH Bands is designed to identify when price begins escaping its volatility-adjusted structure. A close above the upper band reflects bullish expansion, while a close below the lower band reflects bearish expansion.

The GARCH engine gives the indicator a deeper volatility layer than a standard ATR or deviation channel. Instead of only measuring recent range, it models variance behavior and projects that into the band structure.

This indicator is best used as a specialized module within a complete strategy framework. Its role is to isolate volatility-adjusted regime expansion, where price is evaluated against a dynamic variance boundary rather than a static channel. The full value comes from how this volatility regime signal is integrated into a broader process for timing, structure, and execution.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NordicAlphaLab

//@version=6
indicator("Zero-Lag GARCH Bands | NAL", shorttitle = "Zero-Lag GARCH Bands", precision = 2, overlay = true)


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

string bandPressureTooltip = "Higher value = tighter band."

// ══════════════════════════════════════ ◈ GARCH Volatility ◈ ══════════════════════════════════════

GARCH_group = "GARCH Volatility"

GARCH_Lookback = input.int(30, "GARCH Lookback", minval = 2, group = GARCH_group)
GARCH_SmoothLen = input.int(60, "GARCH ZLEMA Smoothing", minval = 1, group = GARCH_group)

// Lagged return / variance components.
float GARCH_LogReturn = not na(close[2]) and close[1] > 0.0 and close[2] > 0.0 ? math.log(close[1] / close[2]) : 0.0
float GARCH_LaggedVariance = nz(ta.variance(close[1], 1), 0.0)
float GARCH_SquaredLogReturn = math.pow(GARCH_LogReturn, 2.0)

// Automated beta/lambda coefficient optimization.
float GARCH_RealizedVariance = nz(ta.sma(GARCH_SquaredLogReturn, GARCH_Lookback), GARCH_SquaredLogReturn)
array<float> GARCH_LambdaSSE_Array = array.new_float(0)

for GARCH_lambdaCandidate = 1 to 99 by 1
    float GARCH_lambdaWeight = GARCH_lambdaCandidate / 100.0
    float GARCH_lambdaEstimate = GARCH_lambdaWeight * GARCH_LaggedVariance + (1.0 - GARCH_lambdaWeight) * GARCH_SquaredLogReturn
    float GARCH_lambdaSSE = math.sum(math.pow(GARCH_lambdaEstimate - GARCH_RealizedVariance, 2.0), GARCH_Lookback)

    array.push(GARCH_LambdaSSE_Array, GARCH_lambdaSSE)

float GARCH_OptimalLambdaSSE = array.min(GARCH_LambdaSSE_Array)
int GARCH_LambdaIndex = array.indexof(GARCH_LambdaSSE_Array, GARCH_OptimalLambdaSSE) + 1

// The EWMA lambda and GARCH beta are equivalent in this optimizer.
int GARCH_BetaIndex = GARCH_LambdaIndex

float GARCH_LongRunVariance = nz(ta.sma(GARCH_LaggedVariance, GARCH_Lookback), GARCH_LaggedVariance)

// Automated gamma coefficient optimization.
array<float> GARCH_GammaSSE_Array = array.new_float(0)

for GARCH_gammaCandidate = 1 to 100 - GARCH_BetaIndex by 1
    float GARCH_betaCandidateWeight = GARCH_BetaIndex / 100.0
    float GARCH_gammaCandidateWeight = GARCH_gammaCandidate / 100.0
    float GARCH_alphaCandidateWeight = 1.0 - GARCH_betaCandidateWeight - GARCH_gammaCandidateWeight

    float GARCH_gammaEstimate =
         GARCH_gammaCandidateWeight * GARCH_LongRunVariance +
         GARCH_alphaCandidateWeight * GARCH_SquaredLogReturn +
         GARCH_betaCandidateWeight * GARCH_LaggedVariance

    float GARCH_gammaSSE = math.sum(math.pow(GARCH_gammaEstimate - GARCH_RealizedVariance, 2.0), GARCH_Lookback)

    array.push(GARCH_GammaSSE_Array, GARCH_gammaSSE)

float GARCH_OptimalGammaSSE = array.min(GARCH_GammaSSE_Array)
int GARCH_GammaIndex = array.indexof(GARCH_GammaSSE_Array, GARCH_OptimalGammaSSE) + 1

float GARCH_Beta = GARCH_BetaIndex / 100.0
float GARCH_Gamma = GARCH_GammaIndex / 100.0
float GARCH_Alpha = 1.0 - GARCH_Beta - GARCH_Gamma

float GARCH_Variance =
     GARCH_Gamma * GARCH_LongRunVariance +
     GARCH_Alpha * GARCH_SquaredLogReturn +
     GARCH_Beta * GARCH_LaggedVariance


// ══════════════════════════════════════ ◈ Baseline & Final Volatility Value ◈ ══════════════════════════════════════


baseline_group = "ZLEMA Baseline"

baseline_src = input.source(close, "Source", group = baseline_group)
baseline_len = input.int(52, "Baseline Length", minval = 1, group = baseline_group)
band_pressure = input.int(30, "Band Pressure", minval = 5, group = baseline_group, tooltip = bandPressureTooltip)

f_zlema(series float source, simple int len) =>
    int lag = int(math.floor((len - 1) / 2))
    float zeroLagSource = source + (source - source[lag])
    ta.ema(zeroLagSource, len)

float baseline = f_zlema(ta.ema(baseline_src, 10), baseline_len)

// Final zero-lag GARCH volatility value.
float GARCH_ProjectedVariance = f_zlema(GARCH_Variance, GARCH_SmoothLen)
float GARCH_Volatility = math.sqrt(math.max(GARCH_ProjectedVariance, 0.0))
float GARCH_VolatilityMultiplier = GARCH_Volatility * 100.0

float upperBand = baseline + (baseline_src / band_pressure) * GARCH_VolatilityMultiplier
float lowerBand = baseline - (baseline_src / band_pressure) * GARCH_VolatilityMultiplier

int score = 0
score := close > upperBand ? 1 : close < lowerBand ? -1 : nz(score[1], 0)

// ══════════════════════════════════════ ◈ Plots ◈ ══════════════════════════════════════

color plotColor = col_nu
color previousPlotColor = na(plotColor[1]) ? col_nu : plotColor[1]
plotColor := score == 1 ? col_up : score == -1 ? col_dn : previousPlotColor

float midLine = math.avg(upperBand, lowerBand)

upperPlot = plot(upperBand, title = "Upper Band", color = plotColor)
lowerPlot = plot(lowerBand, title = "Lower Band", color = plotColor)
midPlot = plot(midLine, title = "Midline", color = color.white, display = display.none)

plot(upperBand, title = "Upper Band Glow", color = color.new(plotColor, 50), display = display.pane, linewidth = 5)
plot(lowerBand, title = "Lower Band Glow", color = color.new(plotColor, 50), display = display.pane, linewidth = 5)

fill(upperPlot, midPlot, upperBand, midLine, color.new(plotColor, 30), color.new(plotColor, 100))
fill(lowerPlot, midPlot, lowerBand, midLine, color.new(plotColor, 30), color.new(plotColor, 100))

plotcandle(open, high, low, close, title = "Bar Color", color = plotColor, wickcolor = plotColor, bordercolor = plotColor, display = display.pane, force_overlay = true)
````

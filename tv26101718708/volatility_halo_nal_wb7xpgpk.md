# Volatility Halo | NAL

- url: https://www.tradingview.com/script/wB7XpgPK-Volatility-Halo-NAL/
- type: indicator
- pine_id: PUB;cc1280d8be28461788df5942e6556f7a
- version: 1.0

## Description

[b]1. Overview
[/b]
Volatility Halo | NAL is an adaptive volatility band indicator built from a Zero-Lag EMA baseline, ATR band structure, and a recursive GARCH-style volatility regime multiplier.

The indicator does not use fixed-width bands. Instead, it starts with ATR-based bands and then adjusts their width using a projected volatility regime model. This allows the bands to respond differently when market volatility is expanding, contracting, or stabilizing.


[b]2. Calculation
[/b]
The indicator starts by calculating a Zero-Lag EMA baseline from the selected source. This baseline acts as the central trend reference, helping reduce lag compared to a standard EMA while still keeping the structure smooth.

[pine]float baseline = f_zlema(src, baseline_len)
float ATR_Value = ta.atr(ATR_Len)[/pine]

The ATR value is then multiplied by the user-defined ATR multiple. This forms the base volatility distance used for the upper and lower bands.

The more advanced part of the indicator is the recursive GARCH-style regime multiplier. It begins by calculating log returns and converting them into shock variance. A long-run variance estimate is then built from recent shock variance.

[pine]GARCH_LogReturn = close > 0.0 and close[1] > 0.0 ? math.log(close / close[1]) : 0.0
GARCH_ShockVariance = math.pow(GARCH_LogReturn, 2.0)
GARCH_LongRunVariance = ta.ema(GARCH_ShockVariance, GARCH_LongRunLen)[/pine]

The model recursively updates conditional variance using three components: recent shock variance, long-run variance, and previous conditional variance. When adaptive coefficients are enabled, the script searches for coefficient weights that better fit recent variance behavior.

[pine]GARCH_ConditionalVariance :=
GARCH_Gamma * GARCH_LongRunVariance +
GARCH_Alpha * GARCH_ShockVariance +
GARCH_Beta * GARCH_PreviousConditionalVariance[/pine]

The conditional variance is then projected and converted into a volatility estimate. This volatility is compared against its own regime baseline to create a volatility regime multiplier. The multiplier is clamped between a minimum and maximum value, preventing the bands from becoming too narrow or too wide.

[pine]GARCH_Volatility = math.sqrt(math.max(GARCH_ProjectedVariance, 0.0))
GARCH_RegimeMultiplierRaw = GARCH_Volatility / GARCH_RegimeBase
GARCH_RegimeMultiplier = f_clamp(GARCH_RegimeMultiplierSmooth, GARCH_MinMult, GARCH_MaxMult)[/pine]

The final band width is created by combining ATR with the GARCH regime multiplier. The upper and lower bands are placed around the Zero-Lag EMA baseline.

[pine]hybridBandWidth = ATR_Value * ATR_Mult * GARCH_RegimeMultiplier

upperBand = baseline + hybridBandWidth
lowerBand = baseline - hybridBandWidth[/pine]

A bullish state triggers when price closes above the upper band. A bearish state triggers when price closes below the lower band. When price remains inside the bands, the previous state is held.


[b]3. Key Features
[/b]
[list=1]
[*]Zero-Lag EMA baseline for reduced-lag trend structure.
[*]ATR-based volatility bands.
[*]Recursive GARCH-style conditional variance model.
[*]Adaptive volatility regime multiplier.
[*]Bands expand or contract based on projected volatility conditions.
[*]State-based candle coloring, band coloring, glow effect, and regime fills.
[/list]


[b]4. Use
[/b]

Volatility Halo is designed to identify moments where price begins escaping its volatility-adjusted structure. A close above the upper band reflects bullish expansion, while a close below the lower band reflects bearish expansion.

The adaptive volatility engine allows the bands to shift with the underlying market environment, making the signal more responsive to changes in pressure and regime.

This indicator is best used as a specialized module within a complete strategy framework. Its real strength appears when it is combined with a broader process for reading market behavior, timing, and risk. The full edge comes from how the signal is integrated, not from the signal existing in isolation.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NordicAlphaLab

//@version=6
indicator("Volatility Halo | NAL", shorttitle = "Volatility Halo", precision = 2, overlay = true)


//                                     ███╗   ██╗ █████╗ ██╗
//                                     ████╗  ██║██╔══██╗██║
//                                     ██╔██╗ ██║███████║██║
//                                     ██║╚██╗██║██╔══██║██║
//                                     ██║ ╚████║██║  ██║███████╗
//                                     ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝


// ══════════════════════════════════════ ◈ Visuals ◈ ══════════════════════════════════════

group_visuals = "Visuals"

col_mode = input.string("Standard", "Color Mode", options = ["Standard", "Nordic", "Simple"], group = group_visuals)

[col_up, col_dn, col_nu] = switch col_mode
    "Standard" => [color.rgb(0, 255, 200), color.rgb(32, 94, 144), color.gray]
    "Nordic"   => [color.rgb(46, 161, 255), color.rgb(150, 154, 169), color.gray]
    "Simple"   => [color.lime, color.red, color.gray]

// ══════════════════════════════════════ ◈ Baseline & ATR Band Engine ◈ ══════════════════════════════════════

baseline_group = "Baseline & ATR"

src = input.source(close, "Source", group = baseline_group)
baseline_len = input.int(50, "ZLEMA Baseline Length", minval = 1, group = baseline_group)

ATR_Len = input.int(24, "ATR Length", minval = 1, group = baseline_group)
ATR_Mult = input.float(1.8, "ATR Multiple", minval = 0.1, step = 0.1, group = baseline_group)

f_zlema(series float source, simple int len) =>
    int lag = int(math.floor((len - 1) / 2))
    float zeroLagSource = source + (source - nz(source[lag], source))
    ta.ema(zeroLagSource, len)

f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(value, maxValue))

float baseline = f_zlema(src, baseline_len)
float ATR_Value = ta.atr(ATR_Len)

// ══════════════════════════════════════ ◈ Adaptive Recursive GARCH Regime Multiplier ◈ ══════════════════════════════════════

GARCH_group = "GARCH Regime Multiplier"

GARCH_UseAdaptiveCoefficients = input.bool(true, "Use Adaptive GARCH Coefficients?", group = GARCH_group)
GARCH_LongRunLen = input.int(80, "Long-Run Variance Length", minval = 2, group = GARCH_group)
GARCH_RegimeLen = input.int(60, "Regime Normalization Length", minval = 2, group = GARCH_group)
GARCH_MultSmooth = input.int(20, "Multiplier Smoothing", minval = 1, group = GARCH_group)

GARCH_MinMult = input.float(0.50, "Min Multiplier", minval = 0.1, step = 0.05, group = GARCH_group, inline = "MUL")
GARCH_MaxMult = input.float(0.90, "Max Multiplier", minval = 0.1, step = 0.05, group = GARCH_group, inline = "MUL")

float GARCH_LogReturn = close > 0.0 and close[1] > 0.0 ? math.log(close / close[1]) : 0.0
float GARCH_ShockVariance = math.pow(GARCH_LogReturn, 2.0)
float GARCH_LongRunVariance = nz(ta.ema(GARCH_ShockVariance, GARCH_LongRunLen), GARCH_ShockVariance)

var float GARCH_ConditionalVariance = na

float GARCH_FitTargetVariance = nz(GARCH_ShockVariance[1], GARCH_ShockVariance)
float GARCH_FitShockVariance = nz(GARCH_ShockVariance[2], GARCH_FitTargetVariance)
float GARCH_FitLongRunVariance = nz(GARCH_LongRunVariance[2], GARCH_LongRunVariance)
float GARCH_FitConditionalVariance = nz(GARCH_ConditionalVariance[2], GARCH_FitLongRunVariance)

int GARCH_BetaIndex = int(math.min(math.max(math.round(0.85 * 100.0), 1.0), 99.0))
int GARCH_GammaIndex = int(math.min(math.max(math.round(0.05 * 100.0), 1.0), 100.0 - GARCH_BetaIndex))

bool GARCH_CanOptimize = bar_index > 10

if GARCH_UseAdaptiveCoefficients and GARCH_CanOptimize
    float GARCH_BetaBestSSE = na

    for GARCH_betaCandidate = 1 to 99 by 1
        float GARCH_betaCandidateWeight = GARCH_betaCandidate / 100.0
        float GARCH_betaEstimate =
             GARCH_betaCandidateWeight * GARCH_FitConditionalVariance +
             (1.0 - GARCH_betaCandidateWeight) * GARCH_FitShockVariance

        float GARCH_betaCandidateSSE = math.sum(math.pow(GARCH_betaEstimate - GARCH_FitTargetVariance, 2.0), 5)

        if not na(GARCH_betaCandidateSSE) and (na(GARCH_BetaBestSSE) or GARCH_betaCandidateSSE < GARCH_BetaBestSSE)
            GARCH_BetaBestSSE := GARCH_betaCandidateSSE
            GARCH_BetaIndex := GARCH_betaCandidate

    float GARCH_GammaBestSSE = na

    for GARCH_gammaCandidate = 1 to 100 - GARCH_BetaIndex by 1
        float GARCH_betaWeight = GARCH_BetaIndex / 100.0
        float GARCH_gammaWeight = GARCH_gammaCandidate / 100.0
        float GARCH_alphaWeight = 1.0 - GARCH_betaWeight - GARCH_gammaWeight

        float GARCH_gammaEstimate =
             GARCH_gammaWeight * GARCH_FitLongRunVariance +
             GARCH_alphaWeight * GARCH_FitShockVariance +
             GARCH_betaWeight * GARCH_FitConditionalVariance

        float GARCH_gammaCandidateSSE = math.sum(math.pow(GARCH_gammaEstimate - GARCH_FitTargetVariance, 2.0), 5)

        if not na(GARCH_gammaCandidateSSE) and (na(GARCH_GammaBestSSE) or GARCH_gammaCandidateSSE < GARCH_GammaBestSSE)
            GARCH_GammaBestSSE := GARCH_gammaCandidateSSE
            GARCH_GammaIndex := GARCH_gammaCandidate

float GARCH_ManualCoefficientSum = math.max(0.1 + 0.85 + 0.05, 0.000001)
float GARCH_ManualAlpha = 0.1 / GARCH_ManualCoefficientSum
float GARCH_ManualBeta = 0.85 / GARCH_ManualCoefficientSum
float GARCH_ManualGamma = 0.05 / GARCH_ManualCoefficientSum

float GARCH_Beta = GARCH_UseAdaptiveCoefficients ? GARCH_BetaIndex / 100.0 : GARCH_ManualBeta
float GARCH_Gamma = GARCH_UseAdaptiveCoefficients ? GARCH_GammaIndex / 100.0 : GARCH_ManualGamma
float GARCH_Alpha = GARCH_UseAdaptiveCoefficients ? math.max(1.0 - GARCH_Beta - GARCH_Gamma, 0.0) : GARCH_ManualAlpha

float GARCH_PreviousConditionalVariance = nz(GARCH_ConditionalVariance[1], GARCH_LongRunVariance)

GARCH_ConditionalVariance :=
     GARCH_Gamma * GARCH_LongRunVariance +
     GARCH_Alpha * GARCH_ShockVariance +
     GARCH_Beta * GARCH_PreviousConditionalVariance

float GARCH_ProjectedVariance = f_zlema(GARCH_ConditionalVariance, 7)
float GARCH_Volatility = math.sqrt(math.max(GARCH_ProjectedVariance, 0.0))
float GARCH_RegimeBase = nz(ta.ema(GARCH_Volatility, GARCH_RegimeLen), GARCH_Volatility)
float GARCH_RegimeMultiplierRaw = GARCH_RegimeBase != 0.0 ? GARCH_Volatility / GARCH_RegimeBase : 1.0
float GARCH_RegimeMultiplierSmooth = f_zlema(GARCH_RegimeMultiplierRaw, GARCH_MultSmooth)
float GARCH_RegimeMultiplier = f_clamp(GARCH_RegimeMultiplierSmooth, GARCH_MinMult, GARCH_MaxMult)

// ══════════════════════════════════════ ◈ Hybrid Bands & Signal ◈ ══════════════════════════════════════

float hybridBandWidth = ATR_Value * ATR_Mult * GARCH_RegimeMultiplier

float upperBand = baseline + hybridBandWidth
float lowerBand = baseline - hybridBandWidth
float midLine = baseline

int NAL = 0
NAL := close > upperBand ? 1 : close < lowerBand ? -1 : nz(NAL[1], 0)

// ══════════════════════════════════════ ◈ Plots ◈ ══════════════════════════════════════

color plotColor = col_nu
color previousPlotColor = na(plotColor[1]) ? col_nu : plotColor[1]
plotColor := NAL == 1 ? col_up : NAL == -1 ? col_dn : previousPlotColor

upperPlot = plot(upperBand, "Upper Band", color = plotColor, linewidth = 1)
lowerPlot = plot(lowerBand, "Lower Band", color = plotColor, linewidth = 1)
midPlot = plot(midLine, "ZLEMA Baseline", color = color.new(color.white, 65), linewidth = 1)

plot(upperBand, "Upper Band Glow", color = color.new(plotColor, 75), linewidth = 6, display = display.pane)
plot(lowerBand, "Lower Band Glow", color = color.new(plotColor, 75), linewidth = 6, display = display.pane)

fill(upperPlot, midPlot, color.new(plotColor, 88), title = "Upper Regime Fill")
fill(lowerPlot, midPlot, color.new(plotColor, 88), title = "Lower Regime Fill")

plotcandle(open, high, low, close, "Colored Candles", color = plotColor, wickcolor = plotColor, bordercolor = plotColor, force_overlay = true, display = display.pane)
````

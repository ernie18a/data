# G-Score | NAL

- url: https://www.tradingview.com/script/8DjyB4B4-G-Score-NAL/
- type: indicator
- pine_id: PUB;15bc6d75ba9d4dc5aad945f5f92e71a5
- version: 1.0

## Description

[b]1. Overview
[/b]
G-Score | NAL is a volatility-adjusted Z-Score regime indicator built from two main components: a smoothed price Z-Score and an adaptive GARCH-based volatility Z-Score.

The indicator does not use fixed overbought or oversold levels. Instead, it builds dynamic thresholds from the current volatility structure of the market. Price is then measured against those volatility-derived boundaries to determine whether the market is entering a bullish or bearish statistical regime.


[b]2. Calculation
[/b]
The indicator starts by estimating volatility through a GARCH-style process. It calculates log returns from the selected source, converts those returns into squared variance, and then compares short-term variance behavior against a realized variance baseline.

[pine]GARCH_LogReturn = math.log(src[1] / src[2])
GARCH_SquaredLogReturn = math.pow(GARCH_LogReturn, 2.0)
GARCH_RealizedVariance = ta.sma(GARCH_SquaredLogReturn, GARCH_Lookback)
[/pine]
The model then searches through possible beta and gamma coefficients to find weights that better fit the recent variance environment. These optimized coefficients are used to build a GARCH variance estimate from three components: long-run variance, recent shock variance, and lagged variance.

[pine]GARCH_Variance =
GARCH_Gamma * GARCH_LongRunVariance +
GARCH_Alpha * GARCH_SquaredLogReturn +
GARCH_Beta * GARCH_LaggedVariance[/pine]

The final GARCH volatility value is created by taking the square root of the projected variance. This produces the volatility engine used later in the threshold system.

The indicator then calculates two separate Z-Scores. The first is a price Z-Score, measuring where price is relative to its own mean and deviation. The second is a volatility Z-Score, measuring where GARCH volatility is relative to its own historical distribution.

Both values are smoothed with a Jurik-style moving average to reduce noise while keeping the response relatively fast.

The volatility Z-Score is then mirrored into positive and negative boundaries. This creates dynamic upper and lower thresholds that expand and contract with the current volatility regime.

The final signal compares the smoothed price Z-Score against those adaptive volatility thresholds. A bullish state triggers when price strength expands above the upper volatility boundary. A bearish state triggers when price weakness falls below the lower volatility boundary. When price remains inside the volatility envelope, the previous regime is held.


[b]3. Key Features
[/b]
[list=1]
[*]Adaptive GARCH-style volatility engine.
[*]Price Z-Score measured against volatility-derived thresholds.
[*]Dynamic upper and lower boundaries instead of fixed levels.
[*]Jurik-style smoothing for both price and volatility components.
[*]State-based candle coloring, background regime coloring, threshold fills, and transition labels.
[*]Designed to capture statistical expansion when price moves outside its volatility-adjusted structure.
[/list]


[b]4. Use
[/b]
G-Score is designed to identify when price begins separating from its normal statistical range after accounting for the current volatility environment. A move above the upper threshold reflects bullish statistical expansion, while a move below the lower threshold reflects bearish statistical expansion.

The strength of the indicator comes from the relationship between price displacement and volatility regime. Rather than treating every Z-Score reading the same, it lets volatility define the boundary that price must break.

This indicator is best used as a specialized module within a complete strategy framework. Its role is to isolate a specific statistical layer of market behavior, where price expansion is evaluated through the lens of adaptive volatility. The full value comes from how this regime signal is integrated into a broader process for timing, structure, and risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NordicAlphaLab

//@version=6
indicator("G-Score | NAL", shorttitle = "G-Score", precision = 2, overlay = false)

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

string Jurik_tp = "Utilizes a Jurik-style moving average."

// ══════════════════════════════════════ ◈ Inputs ◈ ══════════════════════════════════════

G = "GARCH Z-Score | NAL"

src = input.source(hlcc4, "Source", group = G)
GARCH_Lookback = input.int(30, "GARCH Lookback", minval = 2, group = G)
len = input.int(48, "Z-Score Length", minval = 1, group = G)
SmoothLen = input.int(10, "Smoothing", minval = 1, group = G, tooltip = Jurik_tp)

// ══════════════════════════════════════ ◈ GARCH Volatility ◈ ══════════════════════════════════════

// Lagged return / variance components.
float GARCH_LogReturn = not na(src[2]) and src[1] > 0.0 and src[2] > 0.0 ? math.log(src[1] / src[2]) : 0.0
float GARCH_LaggedVariance = nz(ta.variance(src[1], 1), 0.0)
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

// Final zero-lag GARCH volatility value.
float GARCH_ProjectedVariance = GARCH_Variance
float GARCH_Volatility = math.sqrt(math.max(GARCH_ProjectedVariance, 0.0))

// ══════════════════════════════════════ ◈ Z-Score & Final Volatility Value ◈ ══════════════════════════════════════

//Jurik MA 
jma(series float src, simple int length, simple float phase, simple float power) =>
    float phaseRatio = phase < -100.0 ? 0.5 : phase > 100.0 ? 2.5 : phase / 100.0 + 1.5
    float beta = 0.45 * float(length - 1) / (0.45 * float(length - 1) + 2.0)
    float alpha = math.pow(beta, power)
    var float jma_val = na
    var float e0 = na
    var float e1 = na
    var float e2 = na
    e0 := (1.0 - alpha) * src + alpha * nz(e0[1], src)
    e1 := (src - e0) * (1.0 - beta) + beta * nz(e1[1], 0.0)
    e2 := (e0 + phaseRatio * e1 - nz(jma_val[1], src)) * math.pow(1.0 - alpha, 2.0) + math.pow(alpha, 2.0) * nz(e2[1], 0.0)
    jma_val := e2 + nz(jma_val[1], src)
    jma_val


//Z-Score
f_zScore(Zsrc, Zlen) =>
    mean = ta.sma(Zsrc, Zlen)
    dev  = ta.stdev(Zsrc, Zlen)

    zScore = (Zsrc - mean) / dev
    zScore


float zScore_Price     = jma(f_zScore(src, len), SmoothLen, 100, 7) 
float zScore_Vol       = jma(f_zScore(GARCH_Volatility, len), (SmoothLen*3), 100, 7) 
float zScore_Vol_neg   = zScore_Vol * -1

upper_threshold = math.max(zScore_Vol, zScore_Vol_neg)
lower_threshold = math.min(zScore_Vol, zScore_Vol_neg)

int NAL = 0
NAL := zScore_Price < lower_threshold ? -1 : zScore_Price > upper_threshold ? 1 : nz(NAL[1], 0)

// ══════════════════════════════════════ ◈ Plots ◈ ══════════════════════════════════════

color plotColor = col_nu
plotColor := NAL == 1 ? col_up : NAL == -1 ? col_dn : nz(plotColor[1], col_nu)

p0 = plot(0, "Zero", color.new(color.white, 85), display = display.pane)
pu = plot(upper_threshold, "Upper Threshold", color.new(plotColor, 35), 1)
pl = plot(lower_threshold, "Lower Threshold", color.new(plotColor, 35), 1)
pz = plot(zScore_Price, "Price Z", plotColor, 1)
plot(zScore_Price, "GLOW Price Z", color.new(plotColor, 50), 5, display = display.pane)

fill(pu, p0, color.new(col_up, 90))
fill(pl, p0, color.new(col_dn, 90))
fill(pz, p0, color.new(plotColor, 90))

bgcolor(color.new(plotColor, 70), force_overlay = true)

bullish_transition = NAL == 1 and NAL[1] == -1
bearish_transition = NAL == -1 and NAL[1] == 1
plotshape(bullish_transition, "Bullish Transition", style = shape.triangleup, location = location.belowbar, text = "𝓑𝓾𝔂", color = col_up, textcolor = col_up, size = size.tiny, force_overlay = true, display = display.pane)
plotshape(bearish_transition, "Bearish Transition", style = shape.triangledown, location = location.abovebar, text = "𝓢𝓮𝓵𝓵", color = col_dn, textcolor = col_dn, size = size.tiny, force_overlay = true, display = display.pane)

plotcandle(open, high, low, close, "Colored Candles", color = plotColor, wickcolor = plotColor, bordercolor = plotColor, force_overlay = true, display = display.pane)
````

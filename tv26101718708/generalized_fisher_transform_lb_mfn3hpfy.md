# Generalized Fisher Transform [LB]

- url: https://www.tradingview.com/script/mfN3hpFy/
- type: indicator
- pine_id: PUB;b1f617ac7dec452c9c893a457b35a77f
- version: 1.0

## Description

[b] Concept[/b]
The Generalized Fisher Transform extends John F. Ehlers' classic Fisher Transform (2002) by introducing an adjustable shape parameter that controls the sensitivity profile of the transformation. While the original Fisher Transform maps any normalized input to a near‑Gaussian output to highlight statistical extremes, this generalized version allows traders to emphasize central regions (shape < 1) or extreme tails (shape > 1) depending on their strategy.

[b] Mathematical Foundation[/b]
The indicator first normalizes price to a bounded range [i][-1, 1][/i] using a rolling min‑max window of length [i]N[/i] :

[i]x = 2 × (P - L_min) / (H_max - L_min) - 1[/i]

A signed power is then applied with a shape factor [i]p[/i] :

[i]x_p = sign(x) × |x|^p[/i]

The generalized Fisher Transform is computed as :

[i]F = 0.5 × ln( (1 + x_p) / (1 - x_p) )[/i]

When [i]p = 1[/i], the formula reduces to the classic Fisher Transform. Values of [i]p < 1[/i] amplify sensitivity near zero (central price region), while [i]p > 1[/i] amplify sensitivity near the edges (extreme price region). The result is smoothed by an EMA for noise reduction.

[b] What Problem Does It Solve ?[/b]
Classic oscillators such as RSI or Stochastic use fixed non‑linear mappings that cannot adapt to different market regimes or trader preferences. The classic Fisher Transform offers a single sensitivity profile. The Generalized Fisher Transform solves this by exposing the shape parameter [i]p[/i], giving traders direct control over where the indicator is most responsive — near the mean or near the extremes — without changing the underlying logic or introducing additional indicators.

[b] How To Interpret[/b]
The indicator operates in two selectable modes :
[i]Extremes Mode[/i] – the background turns red when Fisher exceeds the upper threshold (statistically overbought), and green when it drops below the lower threshold (statistically oversold). These zones suggest potential mean‑reversion.

[image]https://www.tradingview.com/x/tdBrIkQ3/[/image]

[i]Direction Mode[/i] – the background turns cyan when Fisher is above zero (bullish bias) and orange when below zero (bearish bias). This mode is suited for trend‑following or directional confirmation.
In both modes, the Fisher line crossing zero indicates a shift in the price distribution relative to its recent range.

[image]https://www.tradingview.com/x/pAo6yhP9/[/image]

[b] Parameters[/b]
[b]Source[/b] – price data used for the calculation (default: close).
[b]Normalization Period[/b] – number of bars used to compute the rolling min‑max for the [-1, 1] normalization.
[b]Shape Factor[/b] – exponent applied to the normalized price before the Fisher transform. 1 = classic Fisher, < 1 = center‑sensitive, > 1 = tail‑sensitive.
[b]Smoothing Period[/b] – EMA length applied to the raw Fisher output.
[b]Coloration Mode[/b] – switches between "Extremes" (overbought/oversold highlighting) and "Direction" (bullish/bearish highlighting).
[b]Upper Threshold[/b] – Fisher level above which the background turns red in Extremes mode.
[b]Lower Threshold[/b] – Fisher level below which the background turns green in Extremes mode.

[b] Reference[/b]
Ehlers J.F., "Using the Fisher Transform", Technical Analysis of Stocks & Commodities, Vol. 20, No. 11, pp. 40‑45, November 2002.
Ehlers J.F., "Cybernetic Analysis for Stocks and Futures", Chapter 4 – The Fisher Transform, John Wiley & Sons, 2004.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════
// INDICATOR : Generalized Fisher Transform
// Concept  : Transformee de Fisher generalisee avec parametre
//            de forme ajustable. Transforme le prix normalise
//            en une distribution quasi-gaussienne pour mieux
//            identifier les extremes et les retournements.
//            Base sur les travaux de John F. Ehlers (2002).
// Author   : Luis Barlier
// Style    : Minimaliste – 1 ligne, deux modes de coloration.
// ═══════════════════════════════════════════════════════════════
indicator("Generalized Fisher Transform [LB]", overlay=false, precision=4)
bgcolor(color.new(#000000, 100))

// ── PARAMETERS ────────────────────────────────────────────
src           = input.source(close, "Source")
periodNorm    = input.int(10, "Normalization Period", minval=3, tooltip="Period for min/max to normalize price to [-1,1]")
shape         = input.float(1.0, "Shape Factor", minval=0.1, maxval=5.0, step=0.1, tooltip="Exponent applied before Fisher transform")
smoothPeriod  = input.int(5, "Smoothing Period", minval=1, tooltip="EMA length for final output")
colorMode     = input.string("Extremes", "Coloration Mode", options=["Extremes", "Direction"], tooltip="Extremes: highlight overbought/oversold | Direction: highlight bullish/bearish based on zero cross")
upperThresh   = input.float(2.0, "Upper Threshold", minval=0.5, step=0.1, tooltip="Colored background above this level (Extremes mode)")
lowerThresh   = input.float(-2.0, "Lower Threshold", maxval=-0.5, step=0.1, tooltip="Colored background below this level (Extremes mode)")

// ── NORMALIZATION TO [-1, 1] ─────────────────────────────
float hh = ta.highest(src, periodNorm)
float ll = ta.lowest(src, periodNorm)
float x = 0.0
if hh != ll
    x := 2.0 * (src - ll) / (hh - ll) - 1.0
else
    x := 0.0

// ── GENERALIZED FISHER TRANSFORM ─────────────────────────
float xp = 0.0
if x > 0
    xp := math.pow(math.abs(x), shape)
else if x < 0
    xp := -math.pow(math.abs(x), shape)

float fish = 0.0
float numerator   = 1.0 + xp
float denominator = 1.0 - xp

if denominator > 0.0001
    fish := 0.5 * math.log(math.max(numerator, 0.0001) / denominator)
else
    fish := xp > 0 ? 3.0 : -3.0

float fishSmooth = ta.ema(fish, smoothPeriod)

// ── OUTPUT ───────────────────────────────────────────────
plot(fishSmooth, "Fisher", color=color.new(#00bcd4, 0), linewidth=2)

// Threshold lines (Extremes mode only)
hline(upperThresh, "Upper", color.new(#ff5252, 70), linestyle=hline.style_dashed)
hline(lowerThresh, "Lower", color.new(#00ff00, 70), linestyle=hline.style_dashed)
hline(0, "Zero", color.new(color.gray, 60), linestyle=hline.style_dotted)

// ── BACKGROUND COLORATION (mode-dependant) ───────────────
color couleurFond = na

if colorMode == "Extremes"
    // Extremes mode: highlight overbought / oversold
    if fishSmooth > upperThresh
        couleurFond := color.new(#ff5252, 85)
    else if fishSmooth < lowerThresh
        couleurFond := color.new(#00ff00, 85)

else if colorMode == "Direction"
    // Direction mode: highlight bullish / bearish based on zero cross
    if fishSmooth > 0
        couleurFond := color.new(#00bcd4, 85)
    else if fishSmooth < 0
        couleurFond := color.new(#ff9800, 85)

bgcolor(couleurFond, title="Fisher Regime")
````

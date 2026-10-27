# QT RSI [ W.ARITAS ]

- url: https://www.tradingview.com/script/V6dEL7T5-QT-RSI-W-ARITAS/
- type: indicator
- pine_id: PUB;05bf5356354d4f89a3a8694ef6765b14
- version: 11.0

## Description

The[b] QT RSI [W.ARITAS][/b] is an innovative technical analysis indicator designed to enhance precision in market trend identification and decision-making. Developed using advanced concepts in quantum mechanics, machine learning (LSTM), and signal processing, this indicator provides actionable insights for traders across multiple asset classes, including stocks, crypto, and forex.

[b]Key Features:[/b]

[list]
[*]Dynamic Color Gradient: Visualizes market conditions for intuitive interpretation:

[*]Green: Strong buy signal indicating bullish momentum.
[*]Blue: Neutral or observation zone, suggesting caution or lack of a clear trend.
[*]Red: Strong sell signal indicating bearish momentum.

[*]Quantum-Enhanced RSI: Integrates adaptive energy levels, dynamic smoothing, and quantum oscillators for precise trend detection.

[*]Hybrid Machine Learning Model: Combines LSTM neural networks and wavelet transforms for accurate prediction and signal refinement.

[*]Customizable Settings: Includes advanced parameters for dynamic thresholds, sensitivity adjustment, and noise reduction using Kalman and Jurik filters.
[/list]

[b]How to Use:[/b]

[i]Interpret the Color Gradient:[/i]
[list]
[*]Green Zone: Indicates bullish conditions and potential buy opportunities. Look for upward momentum in the RSI plot.

[*]Blue Zone: Represents a neutral or consolidation phase. Monitor the market for trend confirmation.

[*]Red Zone: Indicates bearish conditions and potential sell opportunities. Look for downward momentum in the RSI plot.

[/list]
[i]Follow Overbought/Oversold Boundaries:[/i]
Use the upper and lower RSI boundaries to identify overbought and oversold conditions.

[b]Leverage Advanced Filtering:[/b]
The smoothed signals and quantum oscillator provide a robust framework for filtering false signals, making it suitable for volatile markets.
Application: Ideal for traders and analysts seeking high-precision tools for:

[b]Identifying entry and exit points.[/b]

[list]
[*]Detecting market reversals and momentum shifts.

[*]Enhancing algorithmic trading strategies with cutting-edge analytics.
[/list]

## Source Code

````pine
//@version=6
indicator("QT RSI - Iceberg", shorttitle="QT RSI Iceberg", overlay=false,max_bars_back=3000,max_lines_count=100,max_labels_count=100)

// Module purpose: Implement a standalone QT RSI indicator with institutional signal filters and the Iceberg optical render engine.
// Module mechanics: The script extracts causal market features, forms a weighted ensemble signal, gates directional events by confidence and shock controls, then renders the resulting state as a visual indicator.

// Input configuration defines model, signal, and visual parameters.
gModel = "Compact QT RSI  Model"
src = input.source(close, "Source", group=gModel)
rsiLen = input.int(14, "RSI residual length", minval=5, maxval=55, group=gModel)
trendLen = input.int(21, "Institutional drift length", minval=5, maxval=89, group=gModel)
lookback = input.int(256, "Adaptive model memory", minval=80, maxval=800, group=gModel)
baseThreshold = input.float(0.18, "Signal threshold floor", minval=0.03, maxval=0.60, step=0.01, group=gModel)
useAdaptiveThr = input.bool(true, "Use adaptive signal threshold", group=gModel)

wSpin = input.float(0.38, "Weight: subatomic spin", minval=0.0, maxval=1.0, step=0.01, group=gModel)
wDfa = input.float(0.26, "Weight: DFA long-memory", minval=0.0, maxval=1.0, step=0.01, group=gModel)
wWave = input.float(0.18, "Weight: wavelet spectral", minval=0.0, maxval=1.0, step=0.01, group=gModel)
wKalman = input.float(0.12, "Weight: Kalman state", minval=0.0, maxval=1.0, step=0.01, group=gModel)
wCharge = input.float(0.04, "Weight: charge polarity", minval=0.0, maxval=1.0, step=0.01, group=gModel)
wRsi = input.float(0.02, "Weight: RSI residual", minval=0.0, maxval=0.30, step=0.01, group=gModel)

gSignal = "Institutional Signal Engine"
allowLong = input.bool(true, "Allow bullish signals", group=gSignal)
allowShort = input.bool(true, "Allow bearish signals", group=gSignal)
useUnion = input.bool(true, "Use 12-atom QT union", group=gSignal)
unionLookback = input.int(500, "Union percentile lookback", minval=200, maxval=2000, group=gSignal)
minConfidence = input.float(0.46, "Minimum manifold confidence", minval=0.10, maxval=0.95, step=0.01, group=gSignal)
maxShockSignal = input.float(0.74, "Maximum signal shock risk", minval=0.20, maxval=1.00, step=0.01, group=gSignal)
maxDispSignal = input.float(0.66, "Maximum signal dispersion", minval=0.10, maxval=1.00, step=0.01, group=gSignal)
minCoordSignal = input.float(0.36, "Minimum model coordination", minval=0.00, maxval=1.00, step=0.01, group=gSignal)
useContinuation = input.bool(true, "Allow continuation signals", group=gSignal)

gIce = "Exact Iceberg Visual Engine"
showBackdrop = input.bool(true, "Show deep-void backdrop", group=gIce)
showManifold = input.bool(true, "Show aura and crests", group=gIce)
showBands = input.bool(true, "Show refraction band", group=gIce)
showHorus = input.bool(true, "Show Horus NSM wireframe", group=gIce)
regimeBgMode = input.string("Native Shadow", "Regime background", options=["Off", "Legacy NSM", "Native Shadow", "Native Drift", "Native Blend"], group=gIce)
visualHeightCap = input.float(18.0, "Visual height cap", minval=4.0, maxval=80.0, step=1.0, group=gIce)
manifoldAmp = input.float(120.0, "Manifold amplitude", minval=30.0, maxval=260.0, step=1.0, group=gIce)
opacityMod = input.float(0.85, "Opacity modifier", minval=0.05, maxval=1.20, step=0.01, group=gIce)
crestGain = input.float(1.18, "Crest gain", minval=0.70, maxval=2.00, step=0.01, group=gIce)
refractionFx = input.float(0.92, "Refraction FX", minval=0.20, maxval=2.00, step=0.01, group=gIce)
iceSmoothLen = input.int(21, "Iceberg smooth length", minval=8, maxval=55, group=gIce)
depthGain = input.float(1.72, "Depth gain", minval=0.80, maxval=3.00, step=0.01, group=gIce)
prismShift = input.float(0.64, "Prism shift", minval=0.00, maxval=1.50, step=0.01, group=gIce)
glowBoost = input.float(1.15, "Glow boost", minval=0.20, maxval=3.00, step=0.01, group=gIce)
glassBlend = input.float(0.58, "Glass blend", minval=0.00, maxval=1.50, step=0.01, group=gIce)
prismShiftEdge = input.float(0.74, "Prism edge", minval=0.00, maxval=1.50, step=0.01, group=gIce)
schumannHybridWeight = input.float(0.58, "Schumann hybrid weight", minval=0.00, maxval=1.00, step=0.01, group=gIce)
aegisBlueHybridWeight = input.float(0.48, "Aegis Blue hybrid weight", minval=0.00, maxval=1.00, step=0.01, group=gIce)
horusNsmWeight = input.float(0.11547005383, "Horus NSM weight", minval=0.00, maxval=1.00, step=0.01, group=gIce)
horusNsmOpacity = input.float(0.6180339887, "Horus NSM opacity", minval=0.05, maxval=1.00, step=0.01, group=gIce)
horusNsmLift = input.float(0.316180339887, "Horus NSM lift", minval=-1.00, maxval=1.00, step=0.01, group=gIce)
regimeBgSmooth = input.int(34, "Background smooth", options=[5, 8, 13, 21, 34, 55], group=gIce)
regimeBgAlpha = input.int(36, "Background alpha", minval=15, maxval=96, group=gIce)
regimeBgStrength = input.float(1.6180339887, "Background blend strength", minval=0.0, maxval=2.0, step=0.01, group=gIce)

// RenderState stores the complete optical state used by the visual engine.
// Its fields carry manifold geometry, transparency, palette selections, regime diagnostics, and subatomic factors from computation to rendering without additional side effects.
type RenderState

    float aura
    float crest2
    float crest4
    float crest6
    float crest8

    float horizonUp
    float horizonDn

    float renderScale
    float visualPillarScale
    int bgAlpha

    color auraColor
    color crest2Color
    color crest4Color
    color crest6Color
    color crest8Color
    color horizonUpColor
    color horizonDnColor
    color refractionColor
    color deepVoid
    color neonCyan
    color neonGreen
    color neonGold
    color magenta

    float nsmH1
    float nsmH2
    float nsmH3
    color nsmH1Color
    color nsmH2Color
    color nsmH3Color
    color nsmFill1Color
    color nsmFill2Color
    color nsmFill3Color

    float phaseLens
    float orthoHealth
    float apexPressure
    float cryoFlux
    float regimeTone
    float signalFragility
    int   regimeCode

    float kalmanState01
    float markovTransProb01
    float waveletEnergy01
    float hawkesPressure01
    float spectralPurity01
    float longMemoryIdx01
    float subMass01
    float subSpin01
    float subCharge01
    float subLifetime01
    float harmonicResonance01

// Purpose: Bound a numeric value within a specified interval.
// Mechanics: Missing values are replaced by the lower bound, then nested min-max operations enforce the interval limits.
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, nz(x, lo)))

// Purpose: Normalize a value to the unit interval.
// Mechanics: The general clamp routine is specialized to the closed range from 0 to 1.
f_clamp01(float x) =>
    f_clamp(x, 0.0, 1.0)

// Purpose: Perform division while avoiding unstable zero denominators.
// Mechanics: The denominator is replaced by a small positive magnitude when its absolute value is too small.
f_safe_div(float x, float y) =>
    x / math.max(math.abs(y), 1e-10)

// Purpose: Evaluate an exponential under bounded numerical conditions.
// Mechanics: The exponent is clipped before evaluation to avoid overflow and underflow artifacts.
f_safe_exp(float x) =>
    math.exp(f_clamp(x, -60.0, 60.0))

// Purpose: Map an unbounded scalar into a smooth probability-like interval.
// Mechanics: A logistic transform is computed with the bounded exponential helper.
f_sigmoid(float x) =>
    1.0 / (1.0 + f_safe_exp(-x))

// Purpose: Produce a bounded signed activation for model scores and geometry drivers.
// Mechanics: The input is clipped and evaluated through the analytic hyperbolic tangent expression.
f_tanh(float x) =>
    float xc = f_clamp(nz(x, 0.0), -20.0, 20.0)
    float ep = math.exp(xc)
    float en = math.exp(-xc)
    (ep - en) / math.max(ep + en, 1e-12)

// Purpose: Generate a smooth fifth-order transition curve.
// Mechanics: The input is clamped to 0..1, then passed through a polynomial with zero first and second derivatives at both endpoints.
f_smootherstep(float x) =>
    float v = f_clamp01(x)
    v * v * v * (v * (v * 6.0 - 15.0) + 10.0)

// Purpose: Discretize a continuous tone into a high-resolution perceptual ladder.
// Mechanics: The clamped input is rounded to one of 512 evenly spaced levels.
f_quant512(float x) =>
    math.round(f_clamp01(x) * 511.0) / 511.0

// Purpose: Apply a Fibonacci-weighted easing curve for color and geometry interpolation.
// Mechanics: The value is quantized, warped by the inverse golden ratio, and smoothed with the fifth-order transition function.
f_fib_blend(float x) =>
    float phi = 1.618033988749895
    float p = f_quant512(x)
    float y = math.pow(p, 1.0 / phi)
    f_smootherstep(y)

// Purpose: Shape darkening intensity for optical shadow effects.
// Mechanics: Quantized input is transformed by the golden ratio exponent and damped near the lower endpoint.
f_fib_shadow(float x) =>
    float p = f_quant512(x)
    f_clamp01(math.pow(p, 1.618033988749895) * (1.0 - 0.2360679775 * (1.0 - p)))

// Purpose: Measure uncertainty in a two-state probability.
// Mechanics: The probability is clipped away from 0 and 1, then normalized Shannon entropy is computed.
f_binary_entropy01(float p) =>
    float pp = f_clamp(nz(p, 0.5), 0.001, 0.999)
    f_clamp01(-(pp * math.log(pp) + (1.0 - pp) * math.log(1.0 - pp)) / math.log(2.0))

// Purpose: Express a series value as a rolling range percentile.
// Mechanics: The value is scaled between its rolling lowest and highest observations over the selected window.
f_range_norm01(float x, int len) =>
    float lo = ta.lowest(nz(x, 0.0), len)
    float hi = ta.highest(nz(x, 0.0), len)
    f_clamp01((nz(x, 0.0) - lo) / math.max(hi - lo, 1e-10))

// Purpose: Limit extreme visual amplitudes without abrupt truncation.
// Mechanics: When stabilization is enabled, a hyperbolic tangent cap compresses values toward the selected visual ceiling.
f_visual_softcap(float x, bool stable, float cap) =>
    stable ? cap * f_tanh(nz(x, 0.0) / math.max(cap, 1e-9)) : nz(x, 0.0)

// Purpose: Compute an EMA after substituting a controlled fallback for missing data.
// Mechanics: Missing source observations are replaced before the moving average is evaluated with a minimum length of one.
f_ema_safe(float src, int len, float fallback) =>
    ta.ema(nz(src, fallback), math.max(len, 1))

// Purpose: Convert a rolling standardized series into a bounded signal.
// Mechanics: The value is centered by an EMA, scaled by rolling standard deviation, amplified, and mapped through a sigmoid.
f_norm01_series(float x, int len, float gain) =>
    float mu = ta.ema(nz(x, 0.0), len)
    float sd = math.max(ta.stdev(nz(x, 0.0), len), 1e-10)
    f_clamp01(f_sigmoid((nz(x, 0.0) - mu) / sd * gain))

// Purpose: Apply a two-pole low-pass filter to reduce short-period noise.
// Mechanics: Coefficients derived from the selected length combine current, prior, and recursive filtered values.
f_super_smoother(float src, int length) =>
    int l = math.max(length, 3)
    float a1 = math.exp(-1.414 * math.pi / l)
    float b1 = 2.0 * a1 * math.cos(1.414 * math.pi / l)
    float c2 = b1
    float c3 = -a1 * a1
    float c1 = 1.0 - c2 - c3
    float filt = 0.0
    filt := bar_index < 2 ? nz(src, 0.0) : c1 * (nz(src, 0.0) + nz(src[1], src)) * 0.5 + c2 * nz(filt[1], src) + c3 * nz(filt[2], src)
    filt

// Purpose: Blend several smoothers into a phase-adaptive filter.
// Mechanics: Super Smoother, ALMA, and EMA outputs are linearly combined with weights controlled by phase lock.
f_morph_smooth(float src, int length, float phaseLock) =>
    float w1 = 0.58 + phaseLock * 0.12
    float w2 = 0.30 - phaseLock * 0.06
    float w3 = 1.0 - w1 - w2
    float s1 = f_super_smoother(src, length)
    float s2 = ta.alma(src, length, 0.85, 6.0)
    float s3 = ta.ema(src, math.max(2, int(math.round(length * 0.35))))
    s1 * w1 + s2 * w2 + s3 * w3

// Purpose: Convert a Pine color from RGB representation to HSV components.
// Mechanics: Channel extrema define hue, saturation, value, and alpha after transparency is converted to opacity.
f_rgbhsv(color col) =>
    float r = color.r(col) / 255.0
    float g = color.g(col) / 255.0
    float b = color.b(col) / 255.0
    float mn = math.min(r, math.min(g, b))
    float mx = math.max(r, math.max(g, b))
    float d = mx - mn
    float h = 0.0
    if d != 0.0
        h := mx == r ? 60.0 * (((g - b) / d) % 6.0) : mx == g ? 60.0 * (((b - r) / d) + 2.0) : 60.0 * (((r - g) / d) + 4.0)
    h := (h + 360.0) % 360.0
    float sat = mx == 0.0 ? 0.0 : d / mx
    float val = mx
    float a = 1.0 - color.t(col) / 100.0
    [h, sat, val, a]

// Purpose: Construct a Pine color from HSV and opacity components.
// Mechanics: Hue sector interpolation produces RGB channels, while opacity is converted back to Pine transparency.
f_hsv_color(float h, float s, float v, float a) =>
    float hh = ((h % 360.0) + 360.0) % 360.0
    float ss = f_clamp01(s)
    float vv = f_clamp01(v)
    float aa = f_clamp01(a)
    float hp = hh / 60.0
    float c = vv * ss
    float x = c * (1.0 - math.abs((hp % 2.0) - 1.0))
    float m = vv - c
    float rr = 0.0
    float gg = 0.0
    float bb = 0.0
    if ss == 0.0
        rr := vv
        gg := vv
        bb := vv
    else if hp < 1.0
        rr := c
        gg := x
    else if hp < 2.0
        rr := x
        gg := c
    else if hp < 3.0
        gg := c
        bb := x
    else if hp < 4.0
        gg := x
        bb := c
    else if hp < 5.0
        rr := x
        bb := c
    else
        rr := c
        bb := x
    int r8 = int(f_clamp(math.round((rr + m) * 255.0), 0.0, 255.0))
    int g8 = int(f_clamp(math.round((gg + m) * 255.0), 0.0, 255.0))
    int b8 = int(f_clamp(math.round((bb + m) * 255.0), 0.0, 255.0))
    int tr = int(f_clamp(math.round(100.0 - aa * 100.0), 0.0, 100.0))
    color.rgb(r8, g8, b8, tr)

// Purpose: Convert an sRGB component into linear light.
// Mechanics: The standard piecewise transfer function is applied after clamping the channel.
f_srgb_to_linear(float c) =>
    float v = f_clamp01(c)
    v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4)

// Purpose: Convert a linear-light component into sRGB.
// Mechanics: The inverse sRGB transfer function is applied after channel clamping.
f_linear_to_srgb(float c) =>
    float v = f_clamp01(c)
    v <= 0.0031308 ? 12.92 * v : 1.055 * math.pow(v, 1.0 / 2.4) - 0.055

// Purpose: Evaluate a cube root while preserving sign.
// Mechanics: The absolute value is rooted and multiplied by the original sign.
f_cuberoot_signed(float x) =>
    x == 0.0 ? 0.0 : math.sign(x) * math.pow(math.abs(x), 1.0 / 3.0)

// Purpose: Interpolate two colors in a perceptually smoother Oklab space.
// Mechanics: sRGB inputs are linearized, transformed into Oklab coordinates, blended, transformed back to sRGB, and emitted with interpolated transparency.
f_oklab_mix(color startCol, color endCol, float pos, int transpOverride) =>
    float p = f_fib_blend(pos)
    float r1 = f_srgb_to_linear(color.r(startCol) / 255.0)
    float g1 = f_srgb_to_linear(color.g(startCol) / 255.0)
    float b1 = f_srgb_to_linear(color.b(startCol) / 255.0)
    float r2 = f_srgb_to_linear(color.r(endCol) / 255.0)
    float g2 = f_srgb_to_linear(color.g(endCol) / 255.0)
    float b2 = f_srgb_to_linear(color.b(endCol) / 255.0)

    float l1 = 0.4122214708 * r1 + 0.5363325363 * g1 + 0.0514459929 * b1
    float m1 = 0.2119034982 * r1 + 0.6806995451 * g1 + 0.1073969566 * b1
    float s1 = 0.0883024619 * r1 + 0.2817188376 * g1 + 0.6299787005 * b1
    float l2 = 0.4122214708 * r2 + 0.5363325363 * g2 + 0.0514459929 * b2
    float m2 = 0.2119034982 * r2 + 0.6806995451 * g2 + 0.1073969566 * b2
    float s2 = 0.0883024619 * r2 + 0.2817188376 * g2 + 0.6299787005 * b2

    float l1c = f_cuberoot_signed(l1)
    float m1c = f_cuberoot_signed(m1)
    float s1c = f_cuberoot_signed(s1)
    float l2c = f_cuberoot_signed(l2)
    float m2c = f_cuberoot_signed(m2)
    float s2c = f_cuberoot_signed(s2)

    float L1 = 0.2104542553 * l1c + 0.7936177850 * m1c - 0.0040720468 * s1c
    float A1 = 1.9779984951 * l1c - 2.4285922050 * m1c + 0.4505937099 * s1c
    float B1 = 0.0259040371 * l1c + 0.7827717662 * m1c - 0.8086757660 * s1c
    float L2 = 0.2104542553 * l2c + 0.7936177850 * m2c - 0.0040720468 * s2c
    float A2 = 1.9779984951 * l2c - 2.4285922050 * m2c + 0.4505937099 * s2c
    float B2 = 0.0259040371 * l2c + 0.7827717662 * m2c - 0.8086757660 * s2c

    float L = L1 + (L2 - L1) * p
    float A = A1 + (A2 - A1) * p
    float B = B1 + (B2 - B1) * p

    float lc = L + 0.3963377774 * A + 0.2158037573 * B
    float mc = L - 0.1055613458 * A - 0.0638541728 * B
    float sc = L - 0.0894841775 * A - 1.2914855480 * B
    float l = lc * lc * lc
    float m = mc * mc * mc
    float sb = sc * sc * sc

    float rr =  4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * sb
    float gg = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * sb
    float bb = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * sb
    int r8 = int(f_clamp(math.round(f_linear_to_srgb(rr) * 255.0), 0.0, 255.0))
    int g8 = int(f_clamp(math.round(f_linear_to_srgb(gg) * 255.0), 0.0, 255.0))
    int b8 = int(f_clamp(math.round(f_linear_to_srgb(bb) * 255.0), 0.0, 255.0))
    int aa = transpOverride >= 0 ? int(f_clamp(math.round(float(transpOverride)), 0.0, 100.0)) : int(f_clamp(math.round(color.t(startCol) + (color.t(endCol) - color.t(startCol)) * p), 0.0, 100.0))
    color.rgb(r8, g8, b8, aa)

// Purpose: Provide the legacy color interpolation interface.
// Mechanics: Calls the Oklab interpolation routine so prior callers receive smoother 512-step perceptual blends.
f_hsv_lerp(float pos, color startCol, color endCol) =>
    f_oklab_mix(startCol, endCol, pos, -1)

// Purpose: Adjust hue, saturation, value, and transparency of an existing color.
// Mechanics: The input color is converted to HSV, retuned by scalar multipliers and shifts, then reconstructed as a Pine color.
f_hsv_retone(color base, float hueShift, float satMul, float valMul, int alpha) =>
    [h, s, v, a] = f_rgbhsv(base)
    f_hsv_color(h + hueShift, f_clamp01(s * satMul), f_clamp01(v * valMul), 1.0 - f_clamp(float(alpha), 0.0, 100.0) / 100.0)

// Purpose: Generate the aurora color family used by the manifold body.
// Mechanics: Tone selects a palette segment, while intensity, clarity, disorder, and hue shift tune saturation, value, and transparency.
f_aurora_color(float tone, float intensity, float clarity, float disorder, int alpha, float hueShift) =>
    float t = f_quant512(f_smootherstep(f_clamp01(tone)))

    color base = t < 0.18 ? f_hsv_lerp(t / 0.18, #000033, #00e5ff) :
         t < 0.38 ? f_hsv_lerp((t - 0.18) / 0.20, #00e5ff, #1530ff) :
         t < 0.50 ? f_hsv_lerp((t - 0.38) / 0.12, #1530ff, #5716d9) :
         t < 0.62 ? f_hsv_lerp((t - 0.50) / 0.12, #5716d9, #a400ff) :
         t < 0.82 ? f_hsv_lerp((t - 0.62) / 0.20, #a400ff, #ff00aa) :
         f_hsv_lerp((t - 0.82) / 0.18, #ff00aa, #ff6600)
    float energy = f_fib_blend(f_clamp01(intensity))
    float satMul = 0.72 + 0.36 * energy + 0.10 * clarity - 0.10 * disorder
    float valMul = 0.58 + 0.48 * energy + 0.12 * clarity - 0.18 * disorder
    f_hsv_retone(base, hueShift + 8.0 * (energy - 0.5) + 10.0 * (clarity - disorder), satMul, valMul, alpha)

// Purpose: Assign neon colors to signed Horus NSM lobes.
// Mechanics: Positive and negative amplitudes use separate palette paths, with opacity determined by normalized magnitude and rim status.
f_horus_neon_color(float val, float maxV, bool isRim, float colorIntensity, float opacity01) =>
    float norm = math.pow(f_clamp01((math.abs(nz(val, 0.0)) / math.max(maxV, 1e-5)) * math.max(colorIntensity, 0.01)), 1.618)
    color c = na
    if nz(val, 0.0) >= 0.0

        c := norm <= 0.33 ? f_hsv_lerp(norm / 0.33, #1a0033, #ff00aa) :
             norm <= 0.66 ? f_hsv_lerp((norm - 0.33) / 0.33, #ff00aa, #ff0000) :
             f_hsv_lerp((norm - 0.66) / 0.34, #ff0000, #ff6600)
    else

        c := norm <= 0.33 ? f_hsv_lerp(norm / 0.33, #000033, #00e5ff) :
             norm <= 0.66 ? f_hsv_lerp((norm - 0.33) / 0.33, #00e5ff, #aaff00) :
             f_hsv_lerp((norm - 0.66) / 0.34, #aaff00, #ffea00)
    float transp = isRim ? 8.0 + 28.0 * (1.0 - norm) : 50.0 + 24.0 * (1.0 - norm)
    float opacityMod = isRim ? 0.98 - 0.12 * f_clamp01(opacity01) : 0.92 - 0.10 * f_clamp01(opacity01)
    color.new(c, int(f_clamp(transp * opacityMod, 0.0, 100.0)))

// Purpose: Convert a numeric transparency request into a valid Pine alpha integer.
// Mechanics: The input is rounded, missing values default to full transparency, and the result is clamped to 0..100.
f_alpha(float x) =>
    int(f_clamp(math.round(nz(x, 100.0)), 0.0, 100.0))

// Purpose: Produce a golden-ratio eased transition for regime backgrounds.
// Mechanics: The unit input is warped by the inverse golden ratio and smoothed with a cubic polynomial.
f_phi_ease(float x) =>
    float p = f_clamp01(x)
    float phi = 1.618033988749895
    float y = math.pow(p, 1.0 / phi)
    f_clamp01(y * y * (3.0 - 2.0 * y))

// Purpose: Blend two colors with a specified transparency.
// Mechanics: The mix weight is Fibonacci-eased before colors are interpolated in Oklab space.
f_rgb_mix(color a, color b, float w, int transp) =>
    f_oklab_mix(a, b, f_fib_blend(w), f_alpha(transp))

// Purpose: Compute the native background color associated with the current render state.
// Mechanics: Regime tone, NSM phase, refraction, horizon flux, and stress diagnostics are blended into one optional background color.
ice_regimeBgColor(RenderState s, string mode, int smoothLen, int baseAlpha, float blendStrength, float visualHeightCap) =>

    float heightBasis = math.max(nz(visualHeightCap, 18.0) * 0.618033988749895, 1e-6)
    float signedPhase = f_sigmoid(nz(s.nsmH3, 0.0) / heightBasis)
    float flux01 = f_clamp01(0.5 + 0.5 * nz(s.cryoFlux, 0.0))
    float raw = (0.382 * signedPhase + 0.236 * f_clamp01(s.regimeTone) + 0.146 * f_clamp01(s.apexPressure) + 0.090 * (1.0 - f_clamp01(s.signalFragility)) + 0.056 * f_clamp01(s.orthoHealth) + 0.034 * flux01) / 0.944
    int sm = math.max(nz(smoothLen, 13), 1)
    float smoothRaw = ta.ema(ta.ema(raw, sm), 8)
    float phase = f_phi_ease(smoothRaw)
    int alpha = f_alpha(nz(baseAlpha, 62) + 8.0 * f_clamp01(s.signalFragility) - 7.0 * f_clamp01(s.apexPressure) - 5.0 * f_clamp01(s.orthoHealth) + 4.0 * (1.0 - f_clamp01(s.regimeTone)))
    float strength = f_clamp01(nz(blendStrength, 0.618033988749895))

    color legacy = color.new(s.nsmH3Color, alpha)
    color voidTint = f_rgb_mix(s.deepVoid, s.nsmH3Color, 0.146 + 0.236 * phase, alpha)
    color refractionTint = f_rgb_mix(s.refractionColor, s.nsmH3Color, 0.382 + 0.236 * f_clamp01(s.orthoHealth), alpha)
    color crestTint = f_rgb_mix(s.crest6Color, s.crest8Color, 0.382 + 0.236 * f_clamp01(s.regimeTone), alpha)
    color horizonTint = f_rgb_mix(s.horizonUpColor, s.horizonDnColor, flux01, alpha)

    color nativeA = f_rgb_mix(voidTint, refractionTint, phase, alpha)
    color nativeB = f_rgb_mix(crestTint, legacy, 0.382 + 0.236 * f_clamp01(s.apexPressure), alpha)
    color nativeBase = f_rgb_mix(nativeA, nativeB, 0.382 + 0.236 * phase, alpha)
    color nativeBlend = f_rgb_mix(legacy, nativeBase, strength, alpha)
    color nativeShadow = f_rgb_mix(nativeBlend, s.deepVoid, 0.382 + 0.236 * f_clamp01(s.signalFragility), f_alpha(alpha + 10.0))
    color nativeDrift = f_rgb_mix(nativeBlend, horizonTint, 0.236 + 0.382 * flux01, alpha)

    color out = legacy
    out := mode == "Off" ? na : mode == "Legacy NSM" ? legacy : mode == "Native Shadow" ? nativeShadow : mode == "Native Drift" ? nativeDrift : nativeBlend
    out

// Purpose: Map a normalized tone to the indicator's high-resolution spectral surface palette.
// Mechanics: The tone is quantized, smoothed, and routed through ordered color segments for negative and positive regimes.
f_spectral512(float tone) =>
    float t = f_quant512(f_smootherstep(f_clamp01(tone)))

    t < 0.18 ? f_hsv_lerp(t / 0.18, #02113a, #0078ff) :
     t < 0.36 ? f_hsv_lerp((t - 0.18) / 0.18, #0078ff, #00e9ff) :
     t < 0.50 ? f_hsv_lerp((t - 0.36) / 0.14, #00e9ff, #d6ff00) :
     t < 0.62 ? f_hsv_lerp((t - 0.50) / 0.12, #4658ff, #7d45ff) :
     t < 0.78 ? f_hsv_lerp((t - 0.62) / 0.16, #7d45ff, #d91cff) :
     t < 0.92 ? f_hsv_lerp((t - 0.78) / 0.14, #d91cff, #ff235c) :
     f_hsv_lerp((t - 0.92) / 0.08, #ff235c, #ff3350)

// Purpose: Add lighting and shadow modulation to a base surface color.
// Mechanics: Shadow and light factors are eased, mixed into the base color, and returned with the requested alpha.
f_surface_tone(color base, float light01, float shadow01, int alpha) =>
    float shadow = f_fib_shadow(shadow01)
    float light = f_fib_blend(light01)
    color shadowed = f_rgb_mix(base, #06101c, 0.18 + 0.34 * shadow, alpha)
    color lit = f_rgb_mix(shadowed, #d9fbff, 0.05 + 0.22 * light, alpha)
    color.new(lit, f_alpha(alpha))

// Purpose: Render a manifold layer with depth-aware spectral coloration.
// Mechanics: Signed amplitude, layer depth, lock, stress, fog, and opacity determine tone, lighting, shadow, and transparency.
f_render_layer_color(float shiftedVal, int layerIdx, float scaleRef, float lock, float stress, float fog, float opacity) =>
    float rawNorm = f_clamp(shiftedVal / math.max(scaleRef, 1e-10), -1.0, 1.0)
    float absNorm = math.abs(rawNorm)
    float shaped = f_fib_blend(1.0 - math.pow(1.0 - absNorm, 1.52))
    float depthRatio = layerIdx == 0 ? -0.2 : (layerIdx - 1.0) / 8.0
    float depthLift = f_clamp01(0.35 + 0.65 * depthRatio)
    float tone = rawNorm >= 0.0 ? 0.44 + shaped * (0.42 + 0.06 * depthLift) : 0.44 - shaped * (0.36 + 0.04 * depthLift)
    color base = f_spectral512(tone)
    float baseAlpha = layerIdx == 0 ? 93.0 : 88.0 - 49.0 * depthRatio
    float glow = layerIdx == 0 ? shaped * 18.0 + lock * 7.0 : math.pow(absNorm, 0.82) * 70.0 + lock * 6.0
    float alpha = f_clamp((baseAlpha + fog * 0.74 - glow + stress * 8.0) * opacity, 0.0, 100.0)
    float light = f_clamp01(0.22 + 0.42 * shaped + 0.20 * lock + 0.16 * depthLift - 0.12 * stress - 0.08 * fog)
    float shadow = f_clamp01(0.18 + 0.40 * stress + 0.25 * fog + 0.13 * (1.0 - lock) + 0.08 * (1.0 - absNorm))
    f_surface_tone(base, light, shadow, int(alpha))

// Purpose: Build the primary Iceberg visual state from market, ensemble, state pressure, and expert inputs.
// Mechanics: Inputs are normalized, aggregated into latent geometry factors, transformed into manifold crests and NSM lobes, and packed into RenderState.
ice_compute(float cSrc, float vol, bool sigWasNa, float sig, float sigStack, float rspSig, float trendBeta,
     float latConf, float sysRisk, float pLow, float pMed, float pHigh, float pSpike,
     float coord, float disp, float precW, float manifoldQuality, float sigThr,
     array<float> expertAction, array<float> expertEdge, array<float> expertConf,
     array<float> trust, array<float> gain, array<float> metaWeights, int leader,
     bool eventSignal, bool resetSignal, bool eventLong, bool eventShort,
     bool stabilizeVisualScale, float visualHeightCap, float manifoldAmp, float opacityMod,
     float crestGain, float refractionFx, simple int smoothLen, float depthGain, float prismShift,
     float glowBoost, float glassBlend, float prismShiftEdge, float schumannHybridWeight,
     float aegisBlueHybridWeight, float horusNsmWeight, float horusNsmOpacity, float horusNsmLift) =>

    color C_MAGENTA     = #FF0E85
    color C_NEON_CYAN   = #00e5ff
    color C_NEON_GREEN  = #13ff00
    color C_NEON_GOLD   = #f6f405
    color C_DEEP_VOID   = color.new(#080b12, 8)

    float sigValid01 = sigWasNa ? 0.0 : 1.0
    float smooth01 = f_clamp01((smoothLen * 1.0 - 8.0) / 47.0)
    float smoothTension = 1.0 - 0.18 * smooth01
    float smoothFluidity = 0.82 + 0.36 * smooth01
    float sigThrSafe = f_clamp01(sigThr)

    float actMean = 0.0
    float actEnergy = 0.0
    float edgeMean = 0.0
    float confMean = 0.0
    float trustMean = 0.0
    float gainMean = 0.0
    float metaAbs = 0.0
    float posVote = 0.0
    float negVote = 0.0
    float leaderAction = 0.0
    float leaderConf = 0.0

    float strongAgreeSum = 0.0
    int   strongAgreeN   = 0
    float strongDir      = 0.0
    int expertCount = array.size(expertAction)
    if expertCount > 0
        int n = math.min(expertCount, 10)

        float meanA = 0.0
        for i = 0 to n - 1
            meanA += nz(array.get(expertAction, i), 0.0)
        meanA /= n
        int meanSign = meanA >= 0.0 ? 1 : -1

        for i = 0 to n - 1
            float a = nz(array.get(expertAction, i), 0.0)
            float e = array.size(expertEdge) > i ? nz(array.get(expertEdge, i), 0.0) : 0.0
            float cf = array.size(expertConf) > i ? nz(array.get(expertConf, i), 0.0) : 0.0
            float tr = array.size(trust) > i ? nz(array.get(trust, i), 0.0) : 0.0
            float gn = array.size(gain) > i ? nz(array.get(gain, i), 0.0) : 0.0
            float mw = array.size(metaWeights) > i ? nz(array.get(metaWeights, i), 0.0) : 0.0
            actMean += a
            actEnergy += math.abs(a)
            edgeMean += math.abs(e)
            confMean += cf
            trustMean += tr
            gainMean += gn
            metaAbs += math.abs(mw)
            posVote += a > 0 ? 1.0 : 0.0
            negVote += a < 0 ? 1.0 : 0.0
            if i == leader
                leaderAction := a
                leaderConf := cf

            if i < 4
                strongAgreeSum += (math.sign(a) == meanSign and math.abs(a) > 0.05) ? 1.0 : 0.0
                strongDir += a
                strongAgreeN += 1
        actMean /= n
        actEnergy /= n
        edgeMean /= n
        confMean /= n
        trustMean /= n
        gainMean /= n
        metaAbs /= n
    float strongAgree01 = strongAgreeN > 0 ? strongAgreeSum / strongAgreeN : 0.0
    float strongDirSigned = strongAgreeN > 0 ? f_tanh(strongDir / strongAgreeN * 2.0) : 0.0

    float voteSpread    = expertCount > 0 ? math.abs(posVote - negVote) / math.min(expertCount, 10) : 0.0
    float signedVote    = expertCount > 0 ? (posVote - negVote) / math.min(expertCount, 10) : 0.0
    float signalNorm    = f_clamp(sigValid01 * nz(sig, 0.0), -1.0, 1.0)
    float sigStackNorm  = f_clamp(sigValid01 * nz(sigStack, 0.0), -1.0, 1.0)
    float rspNorm       = f_clamp((nz(rspSig, 50.0) - 50.0) / 50.0, -1.0, 1.0)
    float betaNorm      = f_clamp(f_tanh(nz(trendBeta, 0.0)), -1.0, 1.0)
    float signalVel     = f_tanh(ta.change(signalNorm) * (4.0 + 2.0 * smoothTension))
    float signalAccel   = f_clamp01(0.5 + 0.5 * f_tanh(ta.change(signalVel) * (4.0 + 3.0 * smoothTension)))
    float risk01        = f_clamp01(nz(sysRisk, 100.0) / 100.0)
    float lat01         = f_clamp01(nz(latConf, 0.0) / 100.0)
    float spike01       = f_clamp01(nz(pSpike, 0.0))
    float high01        = f_clamp01(nz(pHigh, 0.0))
    float med01         = f_clamp01(nz(pMed, 0.0))
    float low01         = f_clamp01(nz(pLow, 0.0))
    float disp01        = f_clamp01(nz(disp, 1.0))
    float coord01       = f_clamp01(nz(coord, 0.0))
    float precision01   = f_clamp01(nz(precW, 0.0))
    float manifoldQ01   = f_clamp01(nz(manifoldQuality, 0.0))
    float prismShiftN   = f_tanh(nz(prismShift, 0.0))
    float gain01        = f_clamp01(f_tanh(math.abs(gainMean) * 2.0))
    float trust01       = f_clamp01(nz(trustMean, 0.0))
    float medRegime01   = f_clamp01(0.60 * med01 + 0.25 * (1.0 - math.abs(high01 - low01)) + 0.15 * (1.0 - spike01))

    float metaWeight01   = f_clamp01(f_tanh(metaAbs * 4.0))
    float leader01       = f_clamp01(0.5 + 0.5 * leaderAction)
    float leaderIndex01  = f_clamp01((leader * 1.0 + 1.0) / 12.0)
    float expertAgreement = f_clamp01((0.27 * voteSpread + 0.15 * coord01 + 0.15 * (1.0 - disp01) + 0.10 * manifoldQ01 + 0.10 * strongAgree01 + 0.07 * gain01 + 0.10 * trust01 + 0.06 * metaWeight01) * (0.90 + 0.10 * sigValid01))
    float edge01         = f_clamp01(f_tanh((edgeMean + 0.12 * gain01 + 0.03 * metaWeight01) * 2.0))
    float actionEnergy01 = f_clamp01(0.88 * actEnergy + 0.07 * gain01 + 0.05 * metaWeight01)
    float metaLoad01     = f_clamp01(f_tanh((metaAbs + 0.10 * gain01) * 4.0))

    float pricePulse01 = f_clamp01(0.5 + 0.5 * f_tanh(ta.roc(cSrc, 1)))
    float volPulse01 = f_clamp01(f_tanh(nz(vol, 1.0) / math.max(ta.sma(nz(vol, 1.0), 20), 1e-10)))
    float eventState01 = f_clamp01((eventSignal ? 0.29 : 0.0) + (resetSignal ? 0.23 : 0.0) + (eventLong ? 0.19 : 0.0) + (eventShort ? 0.17 : 0.0) + (sigWasNa ? 0.03 : 0.07))
    float scaleMode01 = stabilizeVisualScale ? 1.0 : 0.0
    float visualControl01 = f_clamp01(0.055 * scaleMode01 + 0.055 * f_clamp01(visualHeightCap / 100.0) + 0.050 * f_clamp01(manifoldAmp) + 0.050 * f_clamp01(opacityMod) + 0.050 * f_clamp01(crestGain) + 0.045 * f_clamp01(refractionFx) + 0.045 * smooth01 + 0.045 * f_clamp01(depthGain) + 0.040 * f_clamp01(0.5 + 0.5 * prismShiftN) + 0.040 * f_clamp01(glowBoost) + 0.040 * f_clamp01(glassBlend) + 0.035 * f_clamp01(prismShiftEdge) + 0.035 * f_clamp01(schumannHybridWeight) + 0.035 * f_clamp01(aegisBlueHybridWeight) + 0.035 * f_clamp01(horusNsmWeight) + 0.035 * f_clamp01(horusNsmOpacity) + 0.035 * f_clamp01(0.5 + 0.5 * horusNsmLift))
    float scalarControl01 = f_clamp01(0.055 * pricePulse01 + 0.050 * volPulse01 + 0.050 * f_clamp01(0.5 + 0.5 * signalNorm) + 0.045 * f_clamp01(0.5 + 0.5 * sigStackNorm) + 0.040 * f_clamp01(0.5 + 0.5 * rspNorm) + 0.040 * f_clamp01(0.5 + 0.5 * betaNorm) + 0.045 * lat01 + 0.045 * (1.0 - risk01) + 0.040 * low01 + 0.040 * med01 + 0.040 * high01 + 0.040 * spike01 + 0.040 * coord01 + 0.040 * (1.0 - disp01) + 0.040 * precision01 + 0.040 * manifoldQ01 + 0.035 * sigThrSafe + 0.035 * eventState01)
    float arrayControl01 = f_clamp01(0.140 * actionEnergy01 + 0.115 * edge01 + 0.110 * f_clamp01(confMean) + 0.110 * trust01 + 0.105 * gain01 + 0.105 * metaWeight01 + 0.085 * leader01 + 0.075 * leaderIndex01 + 0.075 * strongAgree01 + 0.080 * voteSpread)
    float signatureFingerprint01 = f_clamp01(0.38 * scalarControl01 + 0.34 * arrayControl01 + 0.28 * visualControl01)
    float signatureSigned = 2.0 * signatureFingerprint01 - 1.0

    float hybMix = f_clamp01(schumannHybridWeight)
    float hybRsi = ta.rsi(cSrc, 61)
    float hybNormOsc = (hybRsi - 50.0) / 50.0
    float hybHullOsc = ta.wma(2.0 * ta.wma(hybNormOsc, 30) - ta.wma(hybNormOsc, 61), 8)
    float hybPiWave = math.sin(hybHullOsc * math.pi * 0.5)
    float hybFibWave = math.sign(hybPiWave) * math.pow(math.abs(hybPiWave), 1.0 / 1.618033988749895)
    float hybBaseWave = hybFibWave * manifoldAmp
    float hybSr1 = ta.alma(hybBaseWave, 18, 0.1618033989, 7.83)
    float hybSr2 = ta.alma(hybBaseWave, 18, 0.1618033989, 14.30)
    float hybSr3 = ta.alma(hybBaseWave, 18, 0.1618033989, 20.80)
    float hybSrSpread = (hybSr1 - hybSr3) + 0.25 * (hybSr2 - (hybSr1 + hybSr3) * 0.5)
    float hybSrSpreadZ = f_tanh((hybSrSpread - ta.ema(hybSrSpread, 144)) / math.max(2.5 * ta.stdev(hybSrSpread, 144), 1e-10))
    float hybWaveProb = f_range_norm01(hybSr1, 34)
    float hybWaveEntropy = f_binary_entropy01(hybWaveProb)
    float hybDirProb = ta.sma(cSrc > nz(cSrc[1], cSrc) ? 1.0 : 0.0, 34)
    float hybDirEntropy = f_binary_entropy01(hybDirProb)
    float hybEntropy = f_clamp01(0.60 * hybWaveEntropy + 0.40 * hybDirEntropy)
    float hybCoherence = f_clamp01(1.0 - hybEntropy)
    float hybRelVol = nz(vol, 1.0) / math.max(ta.sma(nz(vol, 1.0), 20), 1e-10)
    var float hybLamLong = 0.0
    var float hybLamShort = 0.0
    float hybAdverseLong = (cSrc < nz(cSrc[1], cSrc) ? 1.0 : 0.0) * hybRelVol
    float hybAdverseShort = (cSrc > nz(cSrc[1], cSrc) ? 1.0 : 0.0) * hybRelVol
    hybLamLong := 0.035 + 0.38 * hybAdverseLong + 0.74 * nz(hybLamLong[1], 0.0)
    hybLamShort := 0.035 + 0.38 * hybAdverseShort + 0.74 * nz(hybLamShort[1], 0.0)
    float hybToxLong = f_sigmoid(hybLamLong - ta.ema(hybLamLong, 34))
    float hybToxShort = f_sigmoid(hybLamShort - ta.ema(hybLamShort, 34))
    float hybToxic = f_clamp01(math.max(hybToxLong, hybToxShort))
    float hybHawkesBias = f_tanh(hybToxShort - hybToxLong)
    float hybLogRet = math.log(math.max(cSrc / math.max(nz(cSrc[1], cSrc), syminfo.mintick), 1e-10))
    float hybFastSd = ta.stdev(hybLogRet, 24)
    float hybSlowSd = ta.stdev(hybLogRet, 96)
    float hybHurstFast = f_clamp(0.5 + 0.5 * f_safe_div(math.log(math.max(hybSlowSd, 1e-10) / math.max(hybFastSd, 1e-10)), math.log(4.0)), 0.0, 1.0)
    float hybHurstSigned = 2.0 * hybHurstFast - 1.0
    float hybEntropySigned = 1.0 - 2.0 * hybEntropy
    float hybSr1Slope1 = hybSr1 - nz(hybSr1[1], hybSr1)
    float hybSr1Slope3 = (hybSr1 - nz(hybSr1[3], hybSr1)) / 3.0
    float hybSr1Curv1 = hybSr1Slope1 - nz(hybSr1Slope1[1], hybSr1Slope1)
    float hybSrSpreadCurv = hybSrSpread - 2.0 * nz(hybSrSpread[1], hybSrSpread) + nz(hybSrSpread[2], hybSrSpread)
    float hybPhaseAccel = hybSr1Slope1 - ta.sma(hybSr1Slope1, 5)
    float hybSr1Path21 = ta.sma(math.abs(hybSr1 - nz(hybSr1[1], hybSr1)), 21) * 21.0
    float hybSr1Eff21 = f_clamp01(math.abs(hybSr1 - nz(hybSr1[21], hybSr1)) / math.max(hybSr1Path21, 1e-10))
    float hybEfficiency = f_clamp01(hybSr1Eff21)
    float hybCurvature01 = f_clamp01(0.60 * f_norm01_series(math.abs(hybSr1Curv1), 55, 1.55) + 0.40 * f_norm01_series(math.abs(hybSrSpreadCurv), 89, 1.35))
    float hybCurvatureSigned = f_tanh(0.55 * f_safe_div(hybSr1Curv1, math.max(ta.stdev(hybSr1Curv1, 55), 1e-10)) + 0.45 * f_safe_div(hybSrSpreadCurv, math.max(ta.stdev(hybSrSpreadCurv, 89), 1e-10)))
    float hybSlopeSigned = f_tanh(0.55 * f_safe_div(hybSr1Slope3, math.max(ta.stdev(hybSr1Slope3, 55), 1e-10)) + 0.45 * hybSrSpreadZ)
    float hybQhoPhase = math.atan(f_safe_div(hybSr1Curv1, math.max(math.abs(hybSr1Slope1), 1e-10)))
    float hybQhoWave = f_tanh(math.sin(hybSr1 / math.max(manifoldAmp, 1e-10) * math.pi + hybQhoPhase) * hybCoherence + 0.35 * hybSlopeSigned + 0.20 * hybCurvatureSigned + 0.08 * f_tanh(hybPhaseAccel * 20.0))
    float hybResonance = f_tanh(0.32 * hybSrSpreadZ + 0.22 * hybHawkesBias + 0.17 * hybHurstSigned + 0.13 * hybEntropySigned + 0.10 * hybSlopeSigned + 0.06 * hybQhoWave)
    float hybStructuralQuality = f_clamp01(0.25 * hybCoherence + 0.20 * hybEfficiency + 0.17 * (1.0 - hybToxic) + 0.14 * f_clamp01(0.5 + 0.5 * hybHurstSigned) + 0.12 * (1.0 - hybCurvature01) + 0.12 * math.abs(hybResonance))
    float hybBreakoutTension = f_clamp01(0.30 * f_norm01_series(math.abs(hybSr1 - nz(hybSr1[34], hybSr1)), 89, 1.35) + 0.22 * hybCurvature01 + 0.18 * math.abs(hybResonance) + 0.14 * (1.0 - hybEntropy) + 0.10 * hybEfficiency + 0.06 * hybToxic)
    float hybCompression = f_clamp01(0.32 * hybCoherence + 0.22 * (1.0 - f_norm01_series(math.abs(hybSr1 - nz(hybSr1[34], hybSr1)), 89, 1.35)) + 0.18 * (1.0 - hybCurvature01) + 0.14 * hybEfficiency + 0.08 * (1.0 - hybToxic) + 0.06 * low01)
    float hybPhaseDisorder = f_clamp01(0.26 * hybEntropy + 0.22 * hybToxic + 0.20 * hybCurvature01 + 0.16 * (1.0 - hybEfficiency) + 0.10 * f_norm01_series(math.abs(hybSr1 - nz(hybSr1[34], hybSr1)), 89, 1.35) + 0.06 * math.abs(hybCurvatureSigned))
    float hybQenfsField = f_clamp01(0.26 * hybStructuralQuality + 0.20 * hybCoherence + 0.17 * hybEfficiency + 0.14 * (1.0 - hybToxic) + 0.12 * math.abs(hybResonance) + 0.11 * math.abs(hybQhoWave))
    float hybVisualFlux = f_tanh(0.46 * hybResonance + 0.22 * hybCurvatureSigned + 0.16 * hybQhoWave + 0.10 * hybHawkesBias + 0.06 * (2.0 * hybWaveProb - 1.0))

    float blueMix = f_clamp01(aegisBlueHybridWeight)
    float blueRsi108 = ta.rsi(cSrc, 108)
    float blueRsiCore = f_tanh((blueRsi108 - 50.0) / 18.0)
    float blueVolu = ta.stdev(ta.roc(cSrc, 1), 2)
    float blueSmoothVol = ta.ema(blueVolu, 14)
    float blueQFactor = math.sin(2.0 * math.pi * blueSmoothVol * 0.01)
    float blueCvc = math.max(0.0, blueSmoothVol * (1.0 - blueQFactor))
    float blueVolShock = f_norm01_series(blueCvc, 89, 1.50)
    float blueTrendBasis = ta.ema(cSrc, 55)
    float blueAtrBasis = math.max(ta.atr(14), syminfo.mintick)
    float blueHorizonDrift = f_tanh((cSrc - blueTrendBasis) / math.max(2.5 * blueAtrBasis, syminfo.mintick))
    float blueProbOsc = f_clamp01(0.5 + 0.5 * f_tanh(0.42 * blueRsiCore + 0.21 * blueHorizonDrift + 0.14 * signalNorm + 0.10 * rspNorm + 0.08 * betaNorm + 0.05 * hybResonance))
    float blueProbEntropy = f_binary_entropy01(blueProbOsc)
    float blueCryoCoherence = f_clamp01(1.0 - blueProbEntropy)
    float blueWaveCore = f_tanh(0.34 * blueRsiCore + 0.22 * blueHorizonDrift + 0.18 * hybQhoWave + 0.12 * signalNorm + 0.08 * rspNorm + 0.06 * hybResonance)
    float blueWaveVel = blueWaveCore - nz(blueWaveCore[1], blueWaveCore)
    float blueWaveCurv = blueWaveVel - nz(blueWaveVel[1], blueWaveVel)
    float bluePhase = math.atan(f_safe_div(blueWaveCurv, math.max(math.abs(blueWaveVel), 1e-10)))
    float blueShellTop = f_tanh(blueWaveCore + 0.32 * blueVolShock + 0.18 * blueCryoCoherence + 0.10 * hybEfficiency)
    float blueShellBot = f_tanh(blueWaveCore - 0.32 * blueVolShock - 0.18 * blueProbEntropy - 0.10 * hybToxic)
    float blueShellTension = f_clamp01(math.abs(blueShellTop - blueShellBot))
    float blueKineticDrag = f_clamp01(0.28 * blueProbEntropy + 0.22 * blueVolShock + 0.17 * hybToxic + 0.13 * risk01 + 0.10 * disp01 + 0.06 * spike01 + 0.04 * high01)
    float blueVelocitySigned = f_tanh(0.38 * blueWaveVel + 0.21 * hybSlopeSigned + 0.17 * signalVel + 0.12 * hybHawkesBias + 0.12 * (blueProbOsc - 0.5))
    float blueCurvatureSigned = f_tanh(0.36 * blueWaveCurv + 0.24 * hybCurvatureSigned + 0.16 * ta.change(signalNorm) + 0.12 * hybQhoWave + 0.12 * hybSrSpreadZ)
    float blueDbKtsPressure = f_clamp01(0.28 * blueKineticDrag + 0.22 * math.abs(blueVelocitySigned) + 0.18 * math.abs(blueCurvatureSigned) + 0.15 * blueShellTension + 0.10 * hybPhaseDisorder + 0.07 * spike01)
    float bluePlasmaClarity = f_clamp01(0.26 * blueCryoCoherence + 0.20 * (1.0 - blueKineticDrag) + 0.17 * hybStructuralQuality + 0.13 * precision01 + 0.10 * coord01 + 0.08 * expertAgreement + 0.06 * hybQenfsField)
    float blueHorizonTension = f_clamp01(0.28 * math.abs(blueHorizonDrift) + 0.22 * blueShellTension + 0.18 * blueVolShock + 0.14 * blueDbKtsPressure + 0.11 * hybBreakoutTension + 0.07 * spike01)
    float bluePolarity = f_tanh(0.30 * blueWaveCore + 0.22 * blueVelocitySigned + 0.17 * blueHorizonDrift + 0.14 * hybResonance + 0.10 * signalNorm + 0.07 * signedVote)
    float bluePrismLens = f_clamp01(0.24 * bluePlasmaClarity + 0.19 * blueCryoCoherence + 0.16 * blueShellTension + 0.13 * (1.0 - blueDbKtsPressure) + 0.11 * hybQenfsField + 0.09 * precision01 + 0.08 * coord01)
    float blueAuroraFlux = f_tanh(0.32 * bluePolarity + 0.20 * blueCurvatureSigned + 0.16 * math.sin(bluePhase + hybQhoPhase) + 0.12 * blueVelocitySigned + 0.11 * hybVisualFlux + 0.09 * (2.0 * blueProbOsc - 1.0))
    float blueEdgeState = f_clamp01(0.25 * bluePlasmaClarity + 0.18 * bluePrismLens + 0.16 * blueCryoCoherence + 0.13 * (1.0 - blueKineticDrag) + 0.11 * hybQenfsField + 0.09 * precision01 + 0.08 * expertAgreement)

    float directionalCollapse = f_tanh(0.55 * signalNorm + 0.20 * (2.0 * strongAgree01 - 1.0) * math.sign(signalNorm) + 0.15 * strongDirSigned + 0.10 * sigStackNorm)
    float collapseStrength01  = f_clamp01(math.abs(directionalCollapse) * (0.55 + 0.30 * manifoldQ01 + 0.15 * precision01))

    float structuralCoherence = f_clamp01(0.25 * coord01 + 0.21 * (1.0 - disp01) + 0.16 * expertAgreement + 0.12 * strongAgree01 + 0.08 * manifoldQ01 + 0.05 * hybCoherence + 0.04 * trust01 + 0.03 * medRegime01 + 0.06 * metaLoad01)

    float instability01 = f_clamp01(0.26 * spike01 + 0.18 * math.abs(signalVel) + 0.15 * (1.0 - precision01) + 0.12 * disp01 + 0.10 * risk01 + 0.10 * hybPhaseDisorder + 0.09 * blueDbKtsPressure)

    float orthoHealth = f_clamp01(0.27 * (1.0 - disp01) + 0.20 * expertAgreement + 0.16 * manifoldQ01 + 0.12 * precision01 + 0.10 * coord01 + 0.08 * trust01 + 0.07 * metaLoad01)
    float vifRiskState = f_clamp01(1.0 - orthoHealth)

    float disagreement01 = f_clamp01(0.34 * disp01 + 0.22 * (1.0 - coord01) + 0.18 * (1.0 - expertAgreement) + 0.14 * (1.0 - precision01) + 0.12 * spike01)
    float phaseLens = f_clamp01(0.43 * disagreement01 + 0.23 * math.abs(signalAccel - 0.5) * 2.0 + 0.17 * hybPhaseDisorder + 0.11 * blueKineticDrag + 0.06 * (1.0 - sigValid01))

    float entropyCompression = f_clamp01(0.30 * hybCompression + 0.22 * (1.0 - hybEntropy) + 0.20 * blueCryoCoherence + 0.18 * (1.0 - blueProbEntropy) + 0.10 * low01)
    float liquidityShock     = f_clamp01(0.30 * hybToxic + 0.25 * spike01 + 0.20 * blueVolShock + 0.15 * blueDbKtsPressure + 0.10 * high01)
    float cryoFlux           = f_tanh(0.55 * (entropyCompression - liquidityShock) + 0.25 * cSrc / math.max(blueTrendBasis, 1e-9) - 0.25 + 0.20 * blueHorizonDrift)

    float signalFragility = f_clamp01(0.35 * phaseLens + 0.25 * vifRiskState + 0.20 * (1.0 - manifoldQ01) + 0.20 * instability01)
    float signalStability = 1.0 - signalFragility

    float trendPressure   = f_clamp01(0.30 * f_clamp01(0.5 + 0.5 * hybHurstSigned) + 0.25 * math.abs(strongDirSigned) + 0.20 * (1.0 - disp01) + 0.15 * math.abs(betaNorm) + 0.10 * structuralCoherence)
    float mrPressure      = f_clamp01(0.30 * (1.0 - f_clamp01(0.5 + 0.5 * hybHurstSigned)) + 0.25 * math.abs(rspNorm) + 0.20 * f_clamp01(0.5 - 0.5 * betaNorm) + 0.15 * hybCompression + 0.10 * (1.0 - math.abs(signalNorm)))

    float volExpansion = f_clamp01(0.28 * high01 + 0.21 * spike01 + 0.17 * f_norm01_series(math.abs(signalVel), 34, 1.8) + 0.13 * blueVolShock + 0.10 * blueHorizonTension + 0.06 * risk01 + 0.05 * (1.0 - medRegime01))
    float volCompression = f_clamp01(0.27 * low01 + 0.20 * hybCompression + 0.17 * blueCryoCoherence + 0.13 * coord01 + 0.09 * (1.0 - blueVolShock) + 0.06 * (1.0 - high01) + 0.08 * medRegime01)
    float volOfVol = f_clamp01(f_norm01_series(math.abs(ta.change(blueVolShock)), 55, 1.5))

    float chopProb = f_clamp01(0.29 * (1.0 - math.abs(signalNorm)) + 0.20 * disp01 + 0.16 * (1.0 - expertAgreement) + 0.13 * (1.0 - manifoldQ01) + 0.13 * (1.0 - math.abs(hybHurstSigned)) + 0.09 * medRegime01)

    float breakoutTension = f_clamp01(0.30 * hybBreakoutTension + 0.22 * collapseStrength01 + 0.18 * structuralCoherence + 0.14 * volCompression + 0.10 * trendPressure + 0.06 * (1.0 - volExpansion))
    float apexPressure    = f_clamp01(0.32 * breakoutTension + 0.20 * collapseStrength01 + 0.18 * (1.0 - signalFragility) + 0.16 * structuralCoherence + 0.14 * trendPressure)

    float vChop   = chopProb
    float vTrend  = trendPressure * (1.0 - chopProb)
    float vMR     = mrPressure    * (1.0 - chopProb)
    float vVolE   = volExpansion
    float vVolC   = volCompression
    float vShock  = liquidityShock
    float maxV    = math.max(math.max(math.max(vChop, vTrend), math.max(vMR, vVolE)), math.max(vVolC, vShock))
    int   regimeCode = 0
    if maxV < 0.15
        regimeCode := 0
    else if vShock == maxV and vShock > 0.30
        regimeCode := 6
    else if vChop == maxV
        regimeCode := 7
    else if vTrend == maxV
        regimeCode := strongDirSigned >= 0.0 ? 1 : 2
    else if vMR == maxV
        regimeCode := 3
    else if vVolE == maxV
        regimeCode := 4
    else if vVolC == maxV
        regimeCode := 5

    float regimeTone = f_clamp01(0.50 + 0.28 * strongDirSigned + 0.10 * (vTrend - vMR) + 0.09 * (vVolC - vVolE) + 0.03 * (medRegime01 - 0.5))

    float lensWarp     = 1.0 - 0.18 * phaseLens + 0.10 * orthoHealth - 0.08 * vifRiskState
    float lensCurvShape = f_tanh(2.0 * (orthoHealth - 0.5)) * 0.20 + 0.10 * structuralCoherence - 0.12 * phaseLens

    float signalDrive       = signalNorm
    float pressureCurvature = f_tanh(0.55 * hybCurvatureSigned + 0.30 * blueCurvatureSigned + 0.15 * f_tanh(ta.change(signalNorm) * 6.0))
    float energy            = f_clamp01(0.27 * actionEnergy01 + 0.17 * edge01 + 0.13 * collapseStrength01 + 0.11 * confMean + 0.09 * gain01 + 0.08 * leader01 + 0.07 * volExpansion + 0.08 * metaLoad01)
    float confidence        = f_clamp01(0.23 * precision01 + 0.16 * structuralCoherence + 0.14 * orthoHealth + 0.10 * lat01 + 0.08 * confMean + 0.08 * signalStability + 0.06 * manifoldQ01 + 0.08 * trust01 + 0.07 * metaLoad01)
    float fog               = f_clamp01(0.30 * phaseLens + 0.22 * vifRiskState + 0.18 * (1.0 - precision01) + 0.14 * (1.0 - lat01) + 0.10 * spike01 + 0.06 * disp01)
    float safety            = f_clamp01(0.27 * (1.0 - risk01) + 0.20 * confidence + 0.17 * orthoHealth + 0.13 * lat01 + 0.09 * structuralCoherence + 0.06 * low01 + 0.08 * trust01)
    float timing            = f_clamp01(0.30 * signalAccel + 0.22 * collapseStrength01 + 0.18 * trendPressure + 0.14 * (1.0 - vifRiskState) + 0.10 * coord01 + 0.06 * (1.0 - chopProb))
    float quality           = f_clamp01(0.25 * confidence + 0.18 * structuralCoherence + 0.16 * orthoHealth + 0.12 * manifoldQ01 + 0.08 * (1.0 - signalFragility) + 0.06 * lat01 + 0.08 * trust01 + 0.07 * metaLoad01)

    float xDir       = f_clamp01(0.5 + 0.5 * directionalCollapse)
    float yCoh       = f_clamp01(0.30 * structuralCoherence + 0.22 * orthoHealth + 0.18 * confidence + 0.14 * coord01 + 0.10 * expertAgreement + 0.06 * manifoldQ01)
    float zInvRisk   = f_clamp01(0.28 * safety + 0.20 * (1.0 - vifRiskState) + 0.18 * volCompression + 0.14 * (1.0 - spike01) + 0.10 * low01 + 0.10 * (1.0 - liquidityShock))
    float wTime      = f_clamp01(0.28 * timing + 0.20 * signalAccel + 0.16 * trendPressure + 0.14 * (1.0 - signalFragility) + 0.12 * (1.0 - chopProb) + 0.10 * collapseStrength01)
    float tesseractLock = f_clamp01(f_safe_div(4.0, f_safe_div(1.0, math.max(xDir, 1e-10)) + f_safe_div(1.0, math.max(yCoh, 1e-10)) + f_safe_div(1.0, math.max(zInvRisk, 1e-10)) + f_safe_div(1.0, math.max(wTime, 1e-10))))
    float mean4 = (xDir + yCoh + zInvRisk + wTime) * 0.25
    float tesseractDisp  = (math.abs(xDir - mean4) + math.abs(yCoh - mean4) + math.abs(zInvRisk - mean4) + math.abs(wTime - mean4)) * 0.25
    float tesseractPhase = f_clamp01(1.0 - 1.35 * tesseractDisp)
    float tesseractStress = f_clamp01(0.20 * phaseLens + 0.16 * apexPressure + 0.14 * (1.0 - zInvRisk) + 0.12 * fog + 0.10 * disagreement01 + 0.10 * spike01 + 0.10 * instability01 + 0.08 * (1.0 - tesseractPhase))

    float regimeFreqMult = 1.0 + 0.18 * vTrend - 0.10 * vChop + 0.06 * vVolE - 0.05 * vVolC
    float X = 2.0 * xDir - 1.0
    float Y = 2.0 * yCoh - 1.0
    float Z = 2.0 * zInvRisk - 1.0
    float W = 2.0 * wTime - 1.0
    float warp = lensWarp * smoothFluidity * (1.0 + 0.13 * f_clamp(1.0 / math.sqrt(math.max(1.0 - math.pow(f_clamp(pressureCurvature, -0.99, 0.99), 2), 0.05)) - 1.0, 0.0, 3.0) + 0.06 * tesseractLock + 0.06 * orthoHealth + 0.05 * quality - 0.06 * tesseractStress - 0.04 * fog)
    float lorentzV = f_clamp01(0.32 * fog + 0.16 * phaseLens + 0.13 * high01 + 0.11 * volExpansion + 0.15 * hybMix * hybPhaseDisorder + 0.13 * blueMix * blueDbKtsPressure)
    float lorentzGamma = 1.0 / math.sqrt(math.max(1.0 - math.pow(lorentzV, 2), 0.05))
    float tDilated = float(bar_index) / lorentzGamma
    float ph0 = tDilated * (0.018 * warp * regimeFreqMult) * (0.62 + 0.22 * (0.5 + 0.5 * directionalCollapse) + 0.06 * manifoldQ01) + prismShiftN * 0.17
    float ph1 = tDilated * (0.033 * warp * regimeFreqMult) * (0.58 + 0.22 * yCoh + 0.05 * manifoldQ01) - prismShiftN * 0.11
    float ph2 = tDilated * (0.060 * warp * regimeFreqMult) * (0.54 + 0.27 * disagreement01 + 0.11 * phaseLens)
    float ph3 = tDilated * (0.094 * warp * regimeFreqMult) * (0.51 + 0.30 * apexPressure + 0.11 * breakoutTension)
    float ph4 = tDilated * (0.138 * warp * regimeFreqMult) * (0.47 + 0.31 * (1.0 - signalFragility) + 0.13 * collapseStrength01)
    float oscA = math.sin(ph0 + ph3 * 0.31 + X * 0.22 + hybMix * hybQhoPhase * 0.18 + blueMix * bluePhase * 0.14)
    float oscB = math.cos(ph1 - ph4 * 0.27 + Y * 0.18 + hybMix * hybSrSpreadZ * 0.16 + blueMix * blueShellTension * 0.12)
    float oscC = math.sin(ph2 * 0.83 + ph0 * 0.19 + Z * 0.16 + hybMix * hybCurvatureSigned * 0.20 + blueMix * blueCurvatureSigned * 0.15)
    float oscD = math.cos(ph3 * 0.61 - ph1 * 0.22 + W * 0.14 + hybMix * hybSlopeSigned * 0.17 + blueMix * blueVelocitySigned * 0.14)
    float oscE = math.sin(ph4 * 0.52 + ph2 * 0.17 + (X - Z) * 0.12 + hybMix * hybVisualFlux * 0.20 + blueMix * blueAuroraFlux * 0.16)

    float deepAmp = manifoldAmp * (0.72 + 0.13 * depthGain + 0.10 * apexPressure + 0.08 * fog + 0.08 * tesseractLock + 0.06 * (1.0 - chopProb) + 0.05 * volExpansion + 0.04 * orthoHealth + 0.04 * medRegime01)
    float facetCore  = f_ema_safe(0.11 * tesseractLock + 0.09 * wTime + 0.07 * (1.0 - signalFragility) + 0.07 * yCoh + 0.06 * xDir + 0.06 * expertAgreement + 0.09 * confidence + 0.11 * orthoHealth + 0.14 * hybMix * hybStructuralQuality + 0.11 * blueMix * bluePlasmaClarity, 4, 0.0)
    float facetSpine = f_ema_safe(0.10 * xDir + 0.08 * yCoh + 0.07 * tesseractPhase + 0.07 * (0.5 + 0.5 * directionalCollapse) + 0.06 * orthoHealth + 0.06 * confidence + 0.09 * collapseStrength01 + 0.12 * structuralCoherence + 0.04 * volCompression + 0.13 * hybMix * f_clamp01(0.5 + 0.5 * hybResonance) + 0.10 * blueMix * f_clamp01(0.5 + 0.5 * bluePolarity), 8, 0.0)
    float facetMid   = f_ema_safe(0.08 * (1.0 - chopProb) + 0.07 * zInvRisk + 0.07 * confidence + 0.07 * safety + 0.06 * energy + 0.07 * expertAgreement + 0.07 * quality + 0.07 * timing + 0.12 * structuralCoherence + 0.04 * volCompression + 0.16 * hybMix * hybQenfsField + 0.12 * blueMix * bluePrismLens, 12, 0.0)
    float facetShell = f_ema_safe(0.09 * apexPressure + 0.09 * tesseractStress + 0.08 * phaseLens + 0.06 * spike01 + 0.05 * (1.0 - yCoh) + 0.05 * risk01 + 0.06 * fog + 0.10 * high01 + 0.10 * volExpansion + 0.04 * disagreement01 + 0.17 * hybMix * hybPhaseDisorder + 0.11 * blueMix * blueDbKtsPressure, 18, 0.0)

    float orthoTighten = 0.94 + 0.12 * orthoHealth - 0.10 * vifRiskState
    float ampCore  = deepAmp * orthoTighten * (0.043 + 0.054 * facetCore  + 0.008 * tesseractLock + 0.006 * confidence + 0.006 * orthoHealth + 0.004 * structuralCoherence)
    float ampSpine = deepAmp * orthoTighten * (0.038 + 0.048 * facetSpine + 0.006 * xDir + 0.005 * f_norm01_series(math.abs(pressureCurvature), 21, 1.7) + 0.004 * collapseStrength01 + 0.004 * expertAgreement)
    float ampMid   = deepAmp * orthoTighten * (0.033 + 0.044 * facetMid   + 0.006 * (1.0 - chopProb) + 0.004 * quality + 0.004 * structuralCoherence + 0.004 * volCompression)
    float ampShell = deepAmp                * (0.028 + 0.042 * facetShell + 0.008 * apexPressure + 0.006 * phaseLens + 0.005 * volExpansion)

    float projectionCurve = (0.34 * (yCoh - apexPressure) + 0.14 * (lensCurvShape) + 0.09 * (orthoHealth - disagreement01) + 0.13 * hybMix * (hybStructuralQuality - hybPhaseDisorder) + 0.10 * blueMix * (bluePlasmaClarity - blueKineticDrag)) * ampMid
    float twistCurve      = (0.35 * (1.0 - signalFragility) - 0.25 * apexPressure + 0.11 * signalAccel + 0.07 * pressureCurvature + 0.14 * hybMix * hybQhoWave + 0.11 * blueMix * blueAuroraFlux) * ampCore
    float shearCurve      = (0.35 * X + 0.13 * W + 0.09 * signedVote + 0.07 * (volExpansion - volCompression) + 0.14 * hybMix * hybResonance + 0.12 * blueMix * bluePolarity) * ampSpine

    float perspective = 1.0 / math.max(1.55 - 0.70 * W, 0.40)
    float flux9 = signalDrive * (ampCore * 1.06 + (0.38 * oscE + 0.21 * oscC + 0.17 * oscA + 0.14 * perspective + 0.10 * orthoHealth) * ampCore + twistCurve * 0.11)
    float flux8 = signalDrive * (ampCore * 0.94 + (0.34 * oscA + 0.22 * oscB + 0.18 * oscD + 0.15 * perspective + 0.11 * confidence) * ampCore + twistCurve * 0.09)
    float flux7 = signalDrive * (ampSpine * 1.01 + (0.36 * oscE + 0.20 * oscA + 0.18 * oscB + 0.14 * W + 0.12 * expertAgreement) * ampSpine + shearCurve * 0.09)
    float flux6 = signalDrive * (ampSpine * 0.91 + (0.32 * oscA + 0.20 * oscD + 0.20 * oscC + 0.15 * W + 0.13 * structuralCoherence) * ampSpine + shearCurve * 0.07)
    float flux5 = signalDrive * (ampMid * 0.94 + (0.34 * oscC + 0.20 * oscA + 0.18 * oscD + 0.14 * Y + 0.14 * volCompression) * ampMid + projectionCurve * 0.11)
    float flux4 = signalDrive * (ampMid * 0.84 + (0.31 * oscD + 0.22 * oscB + 0.18 * oscE + 0.14 * Y + 0.15 * quality) * ampMid + projectionCurve * 0.09)
    float flux3 = signalDrive * (ampShell * 0.90 + (0.31 * oscA + 0.22 * oscC + 0.20 * oscE + 0.14 * Z + 0.13 * safety) * ampShell + projectionCurve * 0.07)
    float flux2 = signalDrive * (ampShell * 0.80 + (0.30 * oscB + 0.22 * oscD + 0.22 * oscA + 0.14 * Z + 0.12 * disagreement01) * ampShell + twistCurve * 0.06)
    float flux1 = signalDrive * (ampShell * 0.68 + (0.28 * oscC + 0.24 * oscD + 0.22 * oscB + 0.14 * Z + 0.12 * volExpansion) * ampShell + shearCurve * 0.06)

    float actionPotentialSigned = eventSignal ? (eventLong ? 1.0 : eventShort ? -1.0 : directionalCollapse >= 0.0 ? 0.35 : -0.35) : resetSignal ? -1.0 : directionalCollapse > 0.0 ? 0.35 : -0.25
    bool quantumTunnel = eventSignal or (timing > 0.70 and math.abs(signalNorm) > sigThrSafe)
    float fieldDrive = 1.0 + 0.09 * actionPotentialSigned + 0.07 * (quantumTunnel ? 1.0 : 0.0) + 0.05 * (timing - 0.5) + 0.05 * (2.0 * edge01 - 1.0) + 0.05 * orthoHealth + 0.03 * gain01 + 0.03 * trust01 + 0.03 * metaLoad01 - 0.04 * disagreement01 + 0.06 * blueMix * (blueEdgeState - blueDbKtsPressure)
    flux9 *= fieldDrive
    flux8 *= fieldDrive
    flux7 *= fieldDrive
    flux6 *= fieldDrive
    flux5 *= fieldDrive
    flux4 *= fieldDrive
    flux3 *= fieldDrive
    flux2 *= fieldDrive
    flux1 *= fieldDrive

    float r9RawU = flux9
    float r8RawU = 0.88 * r9RawU + flux8
    float r7RawU = 0.80 * r8RawU + flux7
    float r6RawU = 0.72 * r7RawU + flux6
    float r5RawU = 0.64 * r6RawU + flux5
    float r4RawU = 0.56 * r5RawU + flux4
    float r3RawU = 0.48 * r4RawU + flux3
    float r2RawU = 0.40 * r3RawU + flux2
    float r1RawU = 0.32 * r2RawU + flux1
    float rawCenter = f_ema_safe((r9RawU + r8RawU + r7RawU + r6RawU + r5RawU + r4RawU + r3RawU + r2RawU + r1RawU) / 9.0, 55, 0.0)
    float centeringGain = 1.0 + 0.16 * (1.0 - tesseractPhase) + 0.08 * expertAgreement + 0.06 * orthoHealth
    float r8Raw = (r8RawU - rawCenter) * centeringGain
    float r6Raw = (r6RawU - rawCenter) * centeringGain
    float r4Raw = (r4RawU - rawCenter) * centeringGain
    float r2Raw = (r2RawU - rawCenter) * centeringGain
    float r1Raw = (r1RawU - rawCenter) * centeringGain
    float cloudBreath = 1.0 + 0.14 * apexPressure + 0.12 * fog + 0.07 * tesseractStress + 0.07 * (1.0 - tesseractPhase) + 0.07 * spike01 + 0.08 * phaseLens - 0.05 * confidence + 0.06 * volExpansion + 0.08 * blueMix * blueShellTension
    float r0Raw = r1Raw * cloudBreath
    float auraRaw = r0Raw * (1.0 + 0.36 * phaseLens + 0.14 * apexPressure + 0.10 * fog + 0.07 * disagreement01 + 0.10 * blueMix * blueHorizonTension)

    float r2FieldRaw = f_ema_safe(-r2Raw, 34, 0.0)
    float r4FieldRaw = f_ema_safe(-r4Raw, 20, 0.0)
    float r6FieldRaw = f_ema_safe(-r6Raw, 12, 0.0)
    float r8FieldRaw = f_ema_safe(-r8Raw, 6, 0.0)
    float r2Field0 = f_visual_softcap(r2FieldRaw, stabilizeVisualScale, visualHeightCap)
    float r4Field0 = f_visual_softcap(r4FieldRaw, stabilizeVisualScale, visualHeightCap)
    float r6Field0 = f_visual_softcap(r6FieldRaw, stabilizeVisualScale, visualHeightCap)
    float r8Field0 = f_visual_softcap(r8FieldRaw, stabilizeVisualScale, visualHeightCap)
    float auraField0 = f_visual_softcap(auraRaw, stabilizeVisualScale, visualHeightCap)

    float surfaceFluidity = f_clamp01(0.34 + 0.30 * smooth01 + 0.18 * orthoHealth + 0.14 * f_clamp01(glassBlend) + 0.10 * bluePrismLens - 0.13 * signalFragility - 0.10 * fog)
    float shellElastic = 0.08 + 0.22 * f_fib_blend(surfaceFluidity)
    float r2Field = r2Field0 + (r4Field0 - r2Field0) * shellElastic * 0.46
    float r4Field = r4Field0 + ((r2Field0 + r6Field0) * 0.5 - r4Field0) * shellElastic
    float r6Field = r6Field0 + ((r4Field0 + r8Field0) * 0.5 - r6Field0) * shellElastic
    float r8Field = r8Field0 + (r6Field0 - r8Field0) * shellElastic * 0.54
    float auraField = auraField0 + (r8Field0 - auraField0) * shellElastic * 0.25
    float posPeak = f_ema_safe(ta.highest(math.max(auraField, 0.0), 150), 20, 0.0)
    float negPeak = f_ema_safe(ta.highest(math.max(-auraField, 0.0), 150), 20, 0.0)
    float visRenderScaleRaw = math.max(math.max(posPeak, negPeak) * (1.02 + 0.05 * apexPressure + 0.04 * fog + 0.04 * volExpansion + 0.05 * blueMix * blueShellTension), visualHeightCap * (0.58 + 0.12 * (1.0 - tesseractPhase) + 0.07 * tesseractLock + 0.06 * orthoHealth + 0.05 * blueMix * bluePrismLens))
    float visRenderScale = stabilizeVisualScale ? f_clamp(visRenderScaleRaw, visualHeightCap * 0.45, visualHeightCap) : visRenderScaleRaw

    float crestScale     = (1.0 + 0.08 * crestGain * confidence + 0.06 * tesseractPhase + 0.05 * structuralCoherence + 0.04 * orthoHealth - 0.04 * disagreement01) * (0.96 + 0.04 * sigValid01)

    simple int surfaceLen = math.max(5, int(math.round(smoothLen * 0.52)))
    simple int auraLen = math.max(surfaceLen, 8)

    float crest2Mod = 0.95 + 0.10 * collapseStrength01 + 0.07 * structuralCoherence - 0.06 * signalFragility
    float crest2Raw = r2Field * crestScale * crest2Mod
    float crest2 = f_morph_smooth(crest2Raw, surfaceLen, surfaceFluidity)

    float crest4Mod = 0.95 + 0.10 * math.abs(pressureCurvature) + 0.07 * trendPressure - 0.05 * mrPressure
    float crest4Raw = r4Field * crestScale * crest4Mod
    float crest4 = f_morph_smooth(crest4Raw, surfaceLen, surfaceFluidity)

    float crest6Mod = 0.95 + 0.10 * (volExpansion - 0.40 * volCompression) + 0.05 * volOfVol
    float crest6Raw = r6Field * crestScale * crest6Mod
    float crest6 = f_morph_smooth(crest6Raw, surfaceLen, surfaceFluidity)

    float crest8Mod = 0.93 + 0.12 * structuralCoherence + 0.08 * orthoHealth - 0.08 * vifRiskState
    float crest8Raw = r8Field * crestScale * crest8Mod
    float crest8 = f_morph_smooth(crest8Raw, surfaceLen, surfaceFluidity)

    float auraMod = 1.0 + 0.10 * confidence + 0.07 * orthoHealth + 0.06 * energy - 0.10 * fog - 0.06 * signalFragility
    float aura = f_morph_smooth(auraField * auraMod * (0.996 + 0.008 * signatureFingerprint01), auraLen, surfaceFluidity)

    float refractBand = visRenderScale * (0.006 + 0.008 * refractionFx + 0.004 * structuralCoherence + 0.003 * tesseractLock + 0.002 * glassBlend + 0.003 * confidence + 0.002 * volCompression + 0.002 * manifoldQ01 + 0.0015 * math.abs(prismShiftN) + 0.004 * hybMix * hybCoherence + 0.004 * blueMix * blueCryoCoherence - 0.002 * phaseLens - 0.002 * disagreement01)
    float cryoOffset = refractBand * cryoFlux * 0.35
    float horizonUp = f_visual_softcap( refractBand * (0.78 + 0.18 * apexPressure + 0.065 * glassBlend + 0.04 * volExpansion + 0.055 * hybMix * hybBreakoutTension + 0.055 * blueMix * blueShellTension) + cryoOffset, stabilizeVisualScale, visualHeightCap)
    float horizonDn = f_visual_softcap(-refractBand * (0.78 + 0.18 * fog + 0.065 * glassBlend + 0.04 * volExpansion + 0.055 * hybMix * hybPhaseDisorder + 0.055 * blueMix * blueKineticDrag) + cryoOffset, stabilizeVisualScale, visualHeightCap)

    float renderScale = visRenderScale * (0.997 + 0.006 * signatureFingerprint01)
    float visualPillarScale = stabilizeVisualScale ? visualHeightCap : renderScale

    color crest2Base = f_render_layer_color(crest2, 2, renderScale, tesseractLock, tesseractStress, fog * 4.8, opacityMod * 0.82)
    color crest4Base = f_render_layer_color(crest4, 4, renderScale, tesseractLock, tesseractStress, fog * 3.9, opacityMod * 0.94)
    color crest6Base = f_render_layer_color(crest6, 6, renderScale, tesseractLock, tesseractStress, fog * 2.8, opacityMod * 1.02)
    color crest8Base = f_render_layer_color(crest8, 8, renderScale, tesseractLock, tesseractStress, fog * 1.6, opacityMod * 1.10)
    float auroraTone = f_clamp01(0.46 + 0.20 * regimeTone + 0.16 * blueAuroraFlux + 0.10 * hybVisualFlux + 0.08 * signatureFingerprint01)
    color auroraEdge = f_aurora_color(auroraTone, glowBoost * 0.33 + energy * 0.67, quality, fog, 46, prismShiftN * 12.0)
    float edgeBlend = f_clamp01(0.08 + 0.16 * f_fib_blend(surfaceFluidity) + 0.10 * prismShiftEdge + 0.08 * bluePrismLens)
    color crest2Color = f_rgb_mix(crest2Base, auroraEdge, edgeBlend * 0.38, f_alpha(color.t(crest2Base)))
    color crest4Color = f_rgb_mix(crest4Base, auroraEdge, edgeBlend * 0.54, f_alpha(color.t(crest4Base)))
    color crest6Color = f_rgb_mix(crest6Base, auroraEdge, edgeBlend * 0.72, f_alpha(color.t(crest6Base)))
    color crest8Color = f_rgb_mix(crest8Base, auroraEdge, edgeBlend, f_alpha(color.t(crest8Base)))

    int auraAlpha = int(f_clamp(94.0 - (13.0 * glowBoost + 7.8 * confidence + 7.8 * tesseractLock + 5.5 * orthoHealth + 3.8 * structuralCoherence + 3.8 * prismShiftEdge + 6.2 * hybMix * hybStructuralQuality + 6.0 * blueMix * bluePlasmaClarity) * opacityMod + 6.5 * phaseLens + 4.6 * hybMix * hybPhaseDisorder + 5.0 * blueMix * blueKineticDrag, 0.0, 100.0))
    color auraColor = f_rgb_mix(crest8Color, auroraEdge, 0.28 + 0.18 * f_fib_blend(quality), int(f_clamp(auraAlpha + 34.0, 58.0, 97.0)))

    int bgAlpha = int(f_clamp(96.0 - 7.2 * confidence - 3.8 * orthoHealth - 2.8 * structuralCoherence - 3.6 * hybMix * hybCoherence - 3.8 * blueMix * blueCryoCoherence + 6.5 * phaseLens + 4.6 * vifRiskState + 3.8 * disagreement01 + 3.6 * hybMix * hybPhaseDisorder + 3.8 * blueMix * blueKineticDrag, 82.0, 97.0))

    color horizonUpColor = f_surface_tone(C_NEON_CYAN, confidence + blueCryoCoherence * 0.35, fog * 0.40, int(f_clamp(82.0 - 13.0 * confidence - 6.0 * hybMix * hybCoherence - 6.0 * blueMix * blueCryoCoherence, 42.0, 90.0)))
    color horizonDnColor = f_surface_tone(C_NEON_GOLD, confidence + hybStructuralQuality * 0.28, phaseLens * 0.52 + blueKineticDrag * 0.24, int(f_clamp(82.0 - 9.0 * confidence - 4.5 * hybMix * hybStructuralQuality - 4.0 * blueMix * bluePlasmaClarity + 5.5 * phaseLens + 3.8 * hybMix * hybPhaseDisorder + 4.0 * blueMix * blueKineticDrag, 44.0, 92.0)))
    color refractionColor = f_rgb_mix(f_hsv_lerp(f_clamp01(0.32 * confidence + 0.28 * orthoHealth + 0.08 * manifoldQ01 + 0.17 * hybMix * hybCoherence + 0.15 * blueMix * blueCryoCoherence), horizonDnColor, horizonUpColor), auroraEdge, 0.18 + 0.20 * surfaceFluidity, int(f_clamp(96.0 - 6.5 * confidence - 2.6 * orthoHealth - 2.4 * manifoldQ01 - 4.5 * hybMix * hybStructuralQuality - 4.2 * blueMix * bluePlasmaClarity + 2.8 * hybMix * hybPhaseDisorder + 3.5 * blueMix * blueKineticDrag, 78.0, 96.0)))

    float nsmWeight01  = f_clamp01(horusNsmWeight)
    float nsmOpacity01 = f_clamp01(horusNsmOpacity)
    float nsmLiftN     = f_clamp(horusNsmLift, -1.0, 1.0)

    float nsmScale = 64.0 * (0.34 + 0.66 * nsmWeight01) * (0.82 + 0.36 * f_clamp01(nsmLiftN * 0.5 + 0.5)) * (0.94 + 0.06 * sigValid01)

    float h1Drive = f_tanh(1.20 * directionalCollapse + 0.30 * signalNorm * confidence + 0.20 * strongDirSigned + 0.15 * sigStackNorm)
    float h1DynPush = 0.78 + 0.22 * collapseStrength01 + 0.16 * confidence + 0.10 * structuralCoherence - 0.07 * signalFragility - 0.03 * vifRiskState
    float h1MeshBase = f_clamp(h1Drive * nsmScale * (0.48 + 0.52 * structuralCoherence) * h1DynPush, -nsmScale, nsmScale)
    float nsmH1 = ta.alma(h1MeshBase, 18, 0.85, 7.83)

    float h2Drive = f_tanh(0.50 * directionalCollapse + 0.45 * (2.0 * structuralCoherence - 1.0) + 0.25 * expertAgreement * math.sign(directionalCollapse) + 0.20 * (2.0 * orthoHealth - 1.0) * math.sign(strongDirSigned))
    float h2DynPush = 0.78 + 0.30 * structuralCoherence + 0.18 * expertAgreement + 0.10 * orthoHealth - 0.10 * vifRiskState
    float h2MeshBase = f_clamp(h2Drive * nsmScale * (0.50 + 0.50 * structuralCoherence) * h2DynPush, -nsmScale, nsmScale)
    float nsmH2 = ta.alma(h2MeshBase * (0.618 + 0.382 * orthoHealth), 18, 0.85, 14.30)

    float h3Drive = f_tanh(0.40 * directionalCollapse + 0.40 * signalVel * math.sign(directionalCollapse) + 0.30 * (signalAccel - 0.5) * 2.0 + 0.20 * hybHawkesBias - 0.15 * orthoHealth * math.sign(directionalCollapse))
    float h3DynPush = 0.70 + 0.40 * instability01 + 0.20 * phaseLens + 0.10 * spike01 - 0.05 * confidence
    float h3MeshBase = f_clamp(h3Drive * nsmScale * (0.42 + 0.58 * instability01) * h3DynPush, -nsmScale, nsmScale)
    float nsmH3 = ta.alma(h3MeshBase * (0.382 + 0.618 * (1.0 - orthoHealth)), 18, 0.85, 20.80)

    float nsmCap = math.max(visualHeightCap, 80.0)
    nsmH1 := f_visual_softcap(nsmH1, stabilizeVisualScale, nsmCap)
    nsmH2 := f_visual_softcap(nsmH2, stabilizeVisualScale, nsmCap)
    nsmH3 := f_visual_softcap(nsmH3, stabilizeVisualScale, nsmCap)

    float nsmColorScale = math.max(nsmScale, 1e-5)
    float nsmH1Int = 0.85 * (0.94 + 0.20 * collapseStrength01 + 0.10 * confidence - 0.05 * signalFragility)
    float nsmH2Int = 0.85 * (0.94 + 0.20 * structuralCoherence + 0.10 * orthoHealth - 0.06 * vifRiskState)
    float nsmH3Int = 0.85 * (0.88 + 0.18 * instability01 + 0.10 * phaseLens - 0.04 * confidence)
    color nsmH1Color = f_horus_neon_color(nsmH1, nsmColorScale, true,  nsmH1Int,        nsmOpacity01)
    color nsmH2Color = f_horus_neon_color(nsmH2, nsmColorScale, true,  nsmH2Int * 0.96, nsmOpacity01)
    color nsmH3Color = f_horus_neon_color(nsmH3, nsmColorScale, true,  nsmH3Int * 0.90, nsmOpacity01)
    color nsmFill1Color = f_horus_neon_color(nsmH1, nsmColorScale, false, nsmH1Int * 0.92, nsmOpacity01)
    color nsmFill2Color = f_horus_neon_color(nsmH2, nsmColorScale, false, nsmH2Int * 0.86, nsmOpacity01)
    color nsmFill3Color = f_horus_neon_color(nsmH3, nsmColorScale, false, nsmH3Int * 0.80, nsmOpacity01)

    float phaseLensOut = f_clamp01(0.985 * phaseLens + 0.015 * signatureFingerprint01)
    float orthoHealthOut = f_clamp01(0.88 * orthoHealth + 0.07 * trust01 + 0.05 * metaLoad01)
    float apexPressureOut = f_clamp01(0.985 * apexPressure + 0.015 * f_clamp01(0.5 + 0.5 * signatureSigned))
    float cryoFluxOut = f_clamp(cryoFlux + 0.012 * signatureSigned, -1.0, 1.0)
    float regimeToneOut  = f_clamp01(0.90 * regimeTone + 0.07 * medRegime01 + 0.03 * signatureFingerprint01)
    float signalFragilityOut = f_clamp01(0.985 * signalFragility + 0.015 * (1.0 - signatureFingerprint01))
    RenderState.new(
         aura, crest2, crest4, crest6, crest8,
         horizonUp, horizonDn,
         renderScale, visualPillarScale, bgAlpha,
         auraColor, crest2Color, crest4Color, crest6Color, crest8Color,
         horizonUpColor, horizonDnColor, refractionColor,
         C_DEEP_VOID, C_NEON_CYAN, C_NEON_GREEN, C_NEON_GOLD, C_MAGENTA,
         nsmH1, nsmH2, nsmH3,
         nsmH1Color, nsmH2Color, nsmH3Color,
         nsmFill1Color, nsmFill2Color, nsmFill3Color,
         phaseLensOut, orthoHealthOut, apexPressureOut, cryoFluxOut, regimeToneOut, signalFragilityOut, regimeCode,

         0.5, 0.0, 0.0, 0.0, 0.5, 0.5, 0.0, 0.0, 0.0, 0.5, 0.5)

// Purpose: Extend the legacy Iceberg state with subatomic feature modulation.
// Mechanics: The base render state is computed first, then eleven bounded diagnostics softly adjust existing aura, crest, horizon, and NSM channels.
ice_compute_v2(float cSrc, float vol, bool sigWasNa, float sig, float sigStack, float rspSig, float trendBeta,
     float latConf, float sysRisk, float pLow, float pMed, float pHigh, float pSpike,
     float coord, float disp, float precW, float manifoldQuality, float sigThr,
     array<float> expertAction, array<float> expertEdge, array<float> expertConf,
     array<float> trust, array<float> gain, array<float> metaWeights, int leader,
     bool eventSignal, bool resetSignal, bool eventLong, bool eventShort,
     bool stabilizeVisualScale, float visualHeightCap, float manifoldAmp, float opacityMod,
     float crestGain, float refractionFx, simple int smoothLen, float depthGain, float prismShift,
     float glowBoost, float glassBlend, float prismShiftEdge, float schumannHybridWeight,
     float aegisBlueHybridWeight, float horusNsmWeight, float horusNsmOpacity, float horusNsmLift,

     float kalmanState01,
     float markovTransProb01,
     float waveletEnergy01,
     float hawkesPressure01,
     float spectralPurity01,
     float longMemoryIdx01,
     float subMass01,
     float subSpin01,
     float subCharge01,
     float subLifetime01,
     float harmonicResonance01
     ) =>

    RenderState s0 = ice_compute(cSrc, vol, sigWasNa, sig, sigStack, rspSig, trendBeta,
         latConf, sysRisk, pLow, pMed, pHigh, pSpike,
         coord, disp, precW, manifoldQuality, sigThr,
         expertAction, expertEdge, expertConf,
         trust, gain, metaWeights, leader,
         eventSignal, resetSignal, eventLong, eventShort,
         stabilizeVisualScale, visualHeightCap, manifoldAmp, opacityMod,
         crestGain, refractionFx, smoothLen, depthGain, prismShift,
         glowBoost, glassBlend, prismShiftEdge, schumannHybridWeight,
         aegisBlueHybridWeight, horusNsmWeight, horusNsmOpacity, horusNsmLift)

    float k01   = f_clamp01(kalmanState01)
    float mkv01 = f_clamp01(markovTransProb01)
    float wv01  = f_clamp01(waveletEnergy01)
    float hwk01 = f_clamp01(hawkesPressure01)
    float spc01 = f_clamp01(spectralPurity01)
    float lm01  = f_clamp01(longMemoryIdx01)
    float sm01  = f_clamp01(subMass01)
    float sp01  = f_clamp(subSpin01, -1.0, 1.0)
    float sc01  = f_clamp(subCharge01, -1.0, 1.0)
    float sl01  = f_clamp01(subLifetime01)
    float hr01  = f_clamp01(harmonicResonance01)

    float auraFocus       = 0.92 + 0.16 * k01
    float auraSaturation  = 0.94 + 0.12 * spc01
    float auraBrightness  = 0.92 + 0.16 * lm01
    float auraPersist     = 0.95 + 0.10 * sl01
    float auraMod         = auraFocus * auraSaturation * auraBrightness * auraPersist
    float aura_v2         = s0.aura * f_clamp(auraMod, 0.7, 1.3)

    float crest4Mod       = 1.0 + 0.12 * wv01 - 0.05 * mkv01
    float crest4_v2       = s0.crest4 * f_clamp(crest4Mod, 0.85, 1.15)

    float crest6Mod       = 1.0 + 0.13 * hwk01
    float crest6_v2       = s0.crest6 * f_clamp(crest6Mod, 0.90, 1.15)

    float crest8Mod       = 1.0 + 0.10 * sm01 + 0.05 * lm01
    float crest8_v2       = s0.crest8 * f_clamp(crest8Mod, 0.90, 1.18)

    float crest2_v2       = s0.crest2

    float horizonUpMod    = 1.0 + 0.10 * math.max(sc01, 0.0)
    float horizonDnMod    = 1.0 + 0.10 * math.max(-sc01, 0.0)
    float horizonUp_v2    = s0.horizonUp * f_clamp(horizonUpMod, 0.90, 1.12)
    float horizonDn_v2    = s0.horizonDn * f_clamp(horizonDnMod, 0.90, 1.12)

    float nsmH1Mod        = 1.0 + 0.12 * math.abs(sp01) * (math.sign(s0.nsmH1) == math.sign(sp01) ? 1.0 : -1.0)
    nsmH1Mod              := nsmH1Mod * (1.0 + 0.08 * hr01)
    float nsmH1_v2        = s0.nsmH1 * f_clamp(nsmH1Mod, 0.85, 1.18)

    float nsmH2Mod        = 1.0 + 0.10 * hr01 - 0.05 * mkv01
    float nsmH2_v2        = s0.nsmH2 * f_clamp(nsmH2Mod, 0.85, 1.15)

    float nsmH3Mod        = 1.0 + 0.18 * mkv01 + 0.07 * hwk01
    float nsmH3_v2        = s0.nsmH3 * f_clamp(nsmH3Mod, 0.92, 1.30)

    int auraAlphaShift    = int(f_clamp(-6.0 * k01 - 4.0 * spc01 - 4.0 * lm01 + 5.0 * mkv01, -10.0, 12.0))
    color auraColor_v2    = color.new(s0.auraColor, int(f_clamp(color.t(s0.auraColor) + auraAlphaShift, 0.0, 100.0)))
    color crest8Color_v2  = color.new(s0.crest8Color, int(f_clamp(color.t(s0.crest8Color) - 4.0 * sm01, 0.0, 100.0)))
    color nsmH3Color_v2   = color.new(s0.nsmH3Color, int(f_clamp(color.t(s0.nsmH3Color) - 5.0 * mkv01, 0.0, 100.0)))

    RenderState.new(
         aura_v2, crest2_v2, crest4_v2, crest6_v2, crest8_v2,
         horizonUp_v2, horizonDn_v2,
         s0.renderScale, s0.visualPillarScale, s0.bgAlpha,
         auraColor_v2, s0.crest2Color, s0.crest4Color, s0.crest6Color, crest8Color_v2,
         s0.horizonUpColor, s0.horizonDnColor, s0.refractionColor,
         s0.deepVoid, s0.neonCyan, s0.neonGreen, s0.neonGold, s0.magenta,
         nsmH1_v2, nsmH2_v2, nsmH3_v2,
         s0.nsmH1Color, s0.nsmH2Color, nsmH3Color_v2,
         s0.nsmFill1Color, s0.nsmFill2Color, s0.nsmFill3Color,
         s0.phaseLens, s0.orthoHealth, s0.apexPressure, s0.cryoFlux, s0.regimeTone, s0.signalFragility, s0.regimeCode,

         k01, mkv01, wv01, hwk01, spc01, lm01, sm01, sp01, sc01, sl01, hr01)

// Feat stores the compact market features used by the institutional model.
// The record aggregates Kalman, Markov, wavelet, Hawkes, spectral, long-memory, and subatomic measurements for later ensemble weighting.
type Feat
    float kx
    float kalmanInnAbs
    float kalmanLock01
    float markovTransProb01
    float waveletE2
    float waveletE3
    float waveletE4
    float waveletRatio
    float waveletEnergy01
    float hawkesPressure01
    float spectralPurity01
    float dfaLong01
    float subMass01
    float subSpin
    float subCharge
    float subLifetime01
    float harmonicResonance01

// Purpose: Normalize a series through rolling z-score compression.
// Mechanics: EMA and rolling standard deviation define a standardized score, which is scaled by gain and passed through a sigmoid.
m_norm01(series float x, simple int len, simple float gain) =>
    float mu = ta.ema(nz(x, 0.0), len)
    float sd = math.max(ta.stdev(nz(x, 0.0), len), 1e-10)
    f_clamp01(f_sigmoid((nz(x, 0.0) - mu) / sd * gain))

// Purpose: Extract the compact feature set used by the QT RSI institutional model.
// Mechanics: The routine computes causal Kalman, Markov, wavelet, Hawkes, spectral, DFA, particle, and harmonic diagnostics from the source series.
m_features(series float src, simple int lookback) =>
    float srcSafe = math.max(nz(src, close), 1e-9)
    float prevSafe = math.max(nz(src[1], srcSafe), 1e-9)
    float logRet = math.log(srcSafe / prevSafe)

    var float kx = na
    var float kp = 1.0
    float kq = 1e-4
    float kr = 1e-2
    float kinn = 0.0
    if bar_index < 2 or na(kx[1])
        kx := srcSafe
        kp := 1.0
    else
        float xpred = nz(kx[1], srcSafe)
        float ppred = nz(kp[1], 1.0) + kq
        kinn := srcSafe - xpred
        float kgain = ppred / math.max(ppred + kr, 1e-9)
        kx := xpred + kgain * kinn
        kp := (1.0 - kgain) * ppred
    float kInnAbs = math.abs(kinn / srcSafe)
    float kalmanLock01 = 1.0 - m_norm01(kInnAbs, lookback, 1.0)

    float rollStd = ta.stdev(logRet, 100)
    float medStd = ta.percentile_linear_interpolation(rollStd, 500, 50)
    float stateNow = rollStd > medStd ? 1.0 : 0.0
    float trans = math.abs(stateNow - nz(stateNow[1], stateNow))
    float markovTrans = f_clamp01(ta.sma(trans, 50))

    float logp = math.log(srcSafe)
    float d2a = logp - nz(logp[2], logp)
    float d2b = nz(logp[2], logp) - nz(logp[4], logp)
    float we2 = math.pow(d2a - d2b, 2)
    float d3a = logp - nz(logp[4], logp)
    float d3b = nz(logp[4], logp) - nz(logp[8], logp)
    float we3 = math.pow(d3a - d3b, 2)
    float d4a = logp - nz(logp[8], logp)
    float d4b = nz(logp[8], logp) - nz(logp[16], logp)
    float we4 = math.pow(d4a - d4b, 2)
    float wr = we2 / math.max(we4, 1e-12)
    float waveletEnergy01 = m_norm01(we3, lookback, 1.0)

    var float hstate = 0.1
    float absR = math.abs(logRet)
    float std50 = ta.stdev(logRet, 50)
    float jump = absR > 1.5 * std50 ? absR / math.max(std50, 1e-6) : 0.0
    hstate := nz(hstate[1], 0.1) * 0.90 + 0.01 + nz(jump[1], 0.0)
    float hawkesPressure01 = m_norm01(hstate, lookback, 1.0)

    float sp8 = math.abs(ta.sma(logRet, 8) - ta.sma(logRet, 16))
    float sp16 = math.abs(ta.sma(logRet, 16) - ta.sma(logRet, 32))
    float sp32 = math.abs(ta.sma(logRet, 32) - ta.sma(logRet, 64))
    float sPeak = math.max(math.max(sp8, sp16), sp32)
    float sNoise = ta.stdev(logRet, 128)
    float specSnr = sPeak / math.max(sNoise, 1e-9)
    float spectralPurity01 = m_norm01(specSnr, lookback, 1.0)

    float cumDev = ta.cum(logRet - ta.sma(logRet, 64))
    float cumResid = cumDev - ta.linreg(cumDev, 64, 0)
    float dfa = ta.stdev(cumResid, 64) / math.max(ta.stdev(logRet, 64), 1e-9)
    float dfaLong01 = m_norm01(dfa, lookback, 1.0)

    float subMass = absR * (1.0 + 0.5 * we3)
    float subMass01 = m_norm01(subMass, lookback, 1.0)
    float subSpin = f_tanh(math.sign(logRet) * math.min(hstate, 5.0) * 0.35)
    float retMu = ta.sma(logRet, 50)
    float skewNum = ta.sma(math.pow(logRet - retMu, 3), 50)
    float sdCubed = math.pow(ta.stdev(logRet, 50), 3)
    float subCharge = f_tanh((sdCubed > 1e-9 ? skewNum / sdCubed : 0.0) * 0.25)
    float subLifetime01 = m_norm01(1.0 / math.max(ta.stdev(logRet, 20), 1e-6), lookback, 1.0)

    int hLen = math.max(24, int(math.round(lookback * 0.25)))
    float h1 = math.sin(2.0 * math.pi * bar_index / 7.83)
    float h2 = math.sin(2.0 * math.pi * bar_index / 14.30)
    float h3 = math.sin(2.0 * math.pi * bar_index / 20.80)
    float harmonicRes = f_clamp01((math.abs(ta.correlation(logRet, h1, hLen)) + math.abs(ta.correlation(logRet, h2, hLen)) + math.abs(ta.correlation(logRet, h3, hLen))) / 3.0)

    Feat.new(kx, kInnAbs, kalmanLock01, markovTrans, we2, we3, we4, wr, waveletEnergy01, hawkesPressure01, spectralPurity01, dfaLong01, subMass01, subSpin, subCharge, subLifetime01, harmonicRes)

// Purpose: Sanitize ensemble weights and model actions before array aggregation.
// Mechanics: Missing values are replaced with zero and the result is clamped to the signed unit interval.
m_safe_weight(float x) =>
    f_clamp(nz(x, 0.0), -1.0, 1.0)

// Model evaluation converts features into ensemble components, signal thresholds, and risk controls.
Feat mf = m_features(src, lookback)
float mf_kx = mf.kx
float logRetModel = math.log(math.max(src, 1e-9) / math.max(nz(src[1], src), 1e-9))
float volBasis = math.max(ta.stdev(logRetModel, 64), 1e-9)
float drift = ta.ema(logRetModel, trendLen) / volBasis
float dfaModel = f_tanh(drift * 4.0) * mf.dfaLong01
float kalmanVelocity = (mf.kx - nz(mf_kx[3], mf.kx)) / math.max(math.max(src, 1e-9) * volBasis, 1e-9)
float kalmanModel = f_tanh(kalmanVelocity * 2.0) * mf.kalmanLock01 * mf.spectralPurity01
float waveImpulse = f_tanh((math.log(math.max(src, 1e-9)) - nz(math.log(math.max(src[4], src)), math.log(math.max(src, 1e-9)))) / volBasis * 0.125)
float waveModel = waveImpulse * mf.waveletEnergy01 * mf.spectralPurity01 * (1.0 - 0.35 * mf.hawkesPressure01)
float rsiResidual = f_tanh((ta.rsi(src, rsiLen) - 50.0) / 18.0)
float rsiModel = rsiResidual * (0.35 + 0.65 * mf.spectralPurity01)
float spinModel = mf.subSpin * mf.subMass01 * (0.50 + 0.50 * mf.subLifetime01)
float chargeModel = mf.subCharge * (1.0 - mf.hawkesPressure01) * (0.50 + 0.50 * mf.spectralPurity01)
float shockRisk = f_clamp01(0.55 * mf.hawkesPressure01 + 0.35 * mf.markovTransProb01 + 0.10 * (1.0 - mf.subLifetime01))

float wSum = math.max(wSpin + wDfa + wWave + wKalman + wCharge + wRsi, 1e-9)
float ensembleRaw = (wSpin * spinModel + wDfa * dfaModel + wWave * waveModel + wKalman * kalmanModel + wCharge * chargeModel + wRsi * rsiModel) / wSum
float confidence = f_clamp01(0.30 * mf.kalmanLock01 + 0.24 * mf.spectralPurity01 + 0.22 * mf.dfaLong01 + 0.14 * mf.subMass01 + 0.10 * mf.subLifetime01 - 0.25 * shockRisk)
float qtSig = f_tanh(ensembleRaw * 2.20) * (0.35 + 0.65 * confidence)
float sigAbs = math.abs(qtSig)
float adaptiveThr = nz(ta.percentile_linear_interpolation(sigAbs, lookback, 78), baseThreshold)
float signalThr = useAdaptiveThr ? f_clamp(math.max(baseThreshold, adaptiveThr), 0.03, 0.65) : baseThreshold

// Signal architecture evaluates atom-union rules and state-quality gates before emitting indicator events.
float coordPre = f_clamp01(math.abs(spinModel + dfaModel + waveModel + kalmanModel) / math.max(math.abs(spinModel) + math.abs(dfaModel) + math.abs(waveModel) + math.abs(kalmanModel), 1e-9))
float dispPre = 1.0 - coordPre
float manifoldQualityPre = f_clamp01(0.35 * coordPre + 0.25 * mf.spectralPurity01 + 0.20 * mf.dfaLong01 + 0.20 * mf.subLifetime01)
float sigStackPre = f_tanh((spinModel + dfaModel + waveModel + kalmanModel) * 0.65)
float dirNow = qtSig >= 0.0 ? 1.0 : -1.0
float qtSigDirAligned = qtSig * dirNow
float dfaModelDir = dfaModel * dirNow
float kalmanModelDir = kalmanModel * dirNow
float spinModelDir = spinModel * dirNow
float chargeModelDir = chargeModel * dirNow
float waveModelDir = waveModel * dirNow

float kalmanModel_p80 = ta.percentile_linear_interpolation(kalmanModel, unionLookback, 80)
float kalmanModel_p75 = ta.percentile_linear_interpolation(kalmanModel, unionLookback, 75)
float kalmanModelDir_p30 = ta.percentile_linear_interpolation(kalmanModelDir, unionLookback, 30)
float kalmanModelDir_p40 = ta.percentile_linear_interpolation(kalmanModelDir, unionLookback, 40)
float kalmanModelDir_p60 = ta.percentile_linear_interpolation(kalmanModelDir, unionLookback, 60)
float dfaModel_p70 = ta.percentile_linear_interpolation(dfaModel, unionLookback, 70)
float dfaModel_p80 = ta.percentile_linear_interpolation(dfaModel, unionLookback, 80)
float dfaModelDir_p70 = ta.percentile_linear_interpolation(dfaModelDir, unionLookback, 70)
float dfaModelDir_p75 = ta.percentile_linear_interpolation(dfaModelDir, unionLookback, 75)
float spinModel_p25 = ta.percentile_linear_interpolation(spinModel, unionLookback, 25)
float spinModel_p75 = ta.percentile_linear_interpolation(spinModel, unionLookback, 75)
float spinModel_p80 = ta.percentile_linear_interpolation(spinModel, unionLookback, 80)
float spinModelDir_p25 = ta.percentile_linear_interpolation(spinModelDir, unionLookback, 25)
float spinModelDir_p70 = ta.percentile_linear_interpolation(spinModelDir, unionLookback, 70)
float spinModelDir_p80 = ta.percentile_linear_interpolation(spinModelDir, unionLookback, 80)
float qtSigDirAligned_p50 = ta.percentile_linear_interpolation(qtSigDirAligned, unionLookback, 50)
float qtSigDirAligned_p60 = ta.percentile_linear_interpolation(qtSigDirAligned, unionLookback, 60)
float dfaLong01_p70 = ta.percentile_linear_interpolation(mf.dfaLong01, unionLookback, 70)
float dfaLong01_p80 = ta.percentile_linear_interpolation(mf.dfaLong01, unionLookback, 80)
float subMass01_p60 = ta.percentile_linear_interpolation(mf.subMass01, unionLookback, 60)
float confidence_p70 = ta.percentile_linear_interpolation(confidence, unionLookback, 70)
float manifoldQ_p70 = ta.percentile_linear_interpolation(manifoldQualityPre, unionLookback, 70)
float manifoldQ_p75 = ta.percentile_linear_interpolation(manifoldQualityPre, unionLookback, 75)
float coord_p60 = ta.percentile_linear_interpolation(coordPre, unionLookback, 60)
float disp_p40 = ta.percentile_linear_interpolation(dispPre, unionLookback, 40)
float shock_p50 = ta.percentile_linear_interpolation(shockRisk, unionLookback, 50)
float shock_p40 = ta.percentile_linear_interpolation(shockRisk, unionLookback, 40)
float wave_p60 = ta.percentile_linear_interpolation(mf.waveletEnergy01, unionLookback, 60)
float wave_p70 = ta.percentile_linear_interpolation(mf.waveletEnergy01, unionLookback, 70)
float spectral_p70 = ta.percentile_linear_interpolation(mf.spectralPurity01, unionLookback, 70)
float lifetime_p60 = ta.percentile_linear_interpolation(mf.subLifetime01, unionLookback, 60)
float hawkes_p50 = ta.percentile_linear_interpolation(mf.hawkesPressure01, unionLookback, 50)
float chargeDir_p60 = ta.percentile_linear_interpolation(chargeModelDir, unionLookback, 60)
float waveDir_p60 = ta.percentile_linear_interpolation(waveModelDir, unionLookback, 60)

bool alpha1 = (kalmanModel > kalmanModel_p80) and (dfaModel > dfaModel_p70) and (manifoldQualityPre > manifoldQ_p70)
bool alpha2 = (dfaModel > dfaModel_p80) and (spinModel > spinModel_p75) and (mf.subMass01 > subMass01_p60)
bool alpha3 = (kalmanModel > kalmanModel_p75) and (mf.kalmanLock01 < ta.percentile_linear_interpolation(mf.kalmanLock01, unionLookback, 5)) and (spinModelDir > spinModelDir_p25)
bool alpha4 = (qtSigDirAligned > qtSigDirAligned_p50) and (mf.kalmanLock01 < ta.percentile_linear_interpolation(mf.kalmanLock01, unionLookback, 20)) and (manifoldQualityPre > manifoldQ_p70)
bool alpha5 = (kalmanModelDir > kalmanModelDir_p40) and (mf.dfaLong01 > dfaLong01_p80) and (spinModel > spinModel_p80)
bool alpha6 = (dfaModelDir > dfaModelDir_p75) and (mf.kalmanLock01 < ta.percentile_linear_interpolation(mf.kalmanLock01, unionLookback, 20)) and (spinModel > spinModel_p25)
bool alpha7 = (kalmanModelDir > kalmanModelDir_p30) and (mf.dfaLong01 > dfaLong01_p80) and (spinModelDir > spinModelDir_p80)
bool alpha8 = (qtSigDirAligned > qtSigDirAligned_p60) and (mf.spectralPurity01 > spectral_p70) and (shockRisk < shock_p50)
bool alpha9 = (manifoldQualityPre > manifoldQ_p75) and (coordPre > coord_p60) and (dispPre < disp_p40) and (mf.subLifetime01 > lifetime_p60)
bool alpha10 = (waveModelDir > waveDir_p60) and (mf.waveletEnergy01 > wave_p60) and (mf.hawkesPressure01 < hawkes_p50) and (kalmanModelDir > kalmanModelDir_p60)
bool alpha11 = (chargeModelDir > chargeDir_p60) and (mf.dfaLong01 > dfaLong01_p70) and (confidence > confidence_p70) and (shockRisk < shock_p40)
bool alpha12 = (dfaModelDir > dfaModelDir_p70) and (spinModelDir > spinModelDir_p70) and (mf.waveletEnergy01 > wave_p70) and (mf.spectralPurity01 > spectral_p70)

bool unionPass = alpha1 or alpha2 or alpha3 or alpha4 or alpha5 or alpha6 or alpha7 or alpha8 or alpha9 or alpha10 or alpha11 or alpha12
bool warm = bar_index > math.max(lookback, unionLookback)
bool stateGate = confidence >= minConfidence and shockRisk <= maxShockSignal and dispPre <= maxDispSignal and coordPre >= minCoordSignal
bool longTrigger = ta.crossover(qtSig, signalThr) or (useContinuation and qtSig > signalThr and ta.crossover(sigStackPre, 0.0))
bool shortTrigger = ta.crossunder(qtSig, -signalThr) or (useContinuation and qtSig < -signalThr and ta.crossunder(sigStackPre, 0.0))
bool unionGate = not useUnion or unionPass
bool goLong = warm and allowLong and stateGate and unionGate and longTrigger
bool goShort = warm and allowShort and stateGate and unionGate and shortTrigger

// Indicator events expose model-qualified directional transitions for chart markers and standard alert conditions.
bool longEvent = goLong
bool shortEvent = goShort
bool resetEvent = warm and ta.cross(qtSig, 0.0)

alertcondition(longEvent, title="QT RSI Bullish Signal", message="QT RSI bullish signal on {{ticker}} at {{close}}")
alertcondition(shortEvent, title="QT RSI Bearish Signal", message="QT RSI bearish signal on {{ticker}} at {{close}}")
alertcondition(resetEvent, title="QT RSI Regime Reset", message="QT RSI regime reset on {{ticker}} at {{close}}")

plotshape(longEvent, title="Bullish Signal Marker", style=shape.triangleup, location=location.bottom, color=color.new(#00e5ff, 0), size=size.tiny, text="L")
plotshape(shortEvent, title="Bearish Signal Marker", style=shape.triangledown, location=location.top, color=color.new(#ff235c, 0), size=size.tiny, text="S")
plot(qtSig, title="QT Signal", color=color.new(#d9fbff, 0), linewidth=1, display=display.none)
plot(signalThr, title="Positive Signal Threshold", color=color.new(#13ff00, 35), linewidth=1, display=display.none)
plot(-signalThr, title="Negative Signal Threshold", color=color.new(#ff235c, 35), linewidth=1, display=display.none)

float coord = f_clamp01(math.abs(spinModel + dfaModel + waveModel + kalmanModel) / math.max(math.abs(spinModel) + math.abs(dfaModel) + math.abs(waveModel) + math.abs(kalmanModel), 1e-9))
float disp = 1.0 - coord
float pLow = f_clamp01((1.0 - shockRisk) * (1.0 - mf.waveletEnergy01) * mf.subLifetime01)
float pMed = f_clamp01(mf.spectralPurity01 * mf.dfaLong01)
float pHigh = f_clamp01(mf.waveletEnergy01 * mf.spectralPurity01 * (1.0 - mf.hawkesPressure01))
float pSpike = mf.hawkesPressure01
float latConf = 100.0 * confidence
float sysRisk = 100.0 * shockRisk
float manifoldQuality = f_clamp01(0.35 * coord + 0.25 * mf.spectralPurity01 + 0.20 * mf.dfaLong01 + 0.20 * mf.subLifetime01)
float rspSig = qtSig
float trendBeta = dfaModel
float sigStack = f_tanh((spinModel + dfaModel + waveModel + kalmanModel) * 0.65)
float precW = confidence

array<float> expertAction = array.from(m_safe_weight(spinModel), m_safe_weight(dfaModel), m_safe_weight(waveModel), m_safe_weight(kalmanModel), m_safe_weight(chargeModel), m_safe_weight(rsiModel), m_safe_weight(-shockRisk * math.sign(qtSig)), m_safe_weight(mf.subSpin), m_safe_weight(2.0 * mf.spectralPurity01 - 1.0), m_safe_weight(2.0 * mf.subLifetime01 - 1.0))
array<float> expertConf = array.from(mf.subMass01, mf.dfaLong01, mf.waveletEnergy01, mf.kalmanLock01, 1.0 - mf.hawkesPressure01, mf.spectralPurity01, 1.0 - shockRisk, mf.subLifetime01, mf.spectralPurity01, mf.subLifetime01)
array<float> expertEdge = array.new<float>(10, 0.0)
array<float> trust = array.new<float>(10, 0.0)
array<float> gain = array.new<float>(10, 0.0)
array<float> metaWeights = array.from(wSpin / wSum, wDfa / wSum, wWave / wSum, wKalman / wSum, wCharge / wSum, wRsi / wSum, 0.03, 0.03, 0.03, 0.03)
for i = 0 to 9
    float a = array.get(expertAction, i)
    float c = array.get(expertConf, i)
    array.set(expertEdge, i, f_clamp(a * c, -1.0, 1.0))
    array.set(trust, i, f_clamp01(c))
    array.set(gain, i, f_clamp01(math.abs(a) * c))

int leader = 0
float leaderAbs = 0.0
for i = 0 to 5
    float v = math.abs(array.get(expertEdge, i))
    if v > leaderAbs
        leaderAbs := v
        leader := i

RenderState iceberg = ice_compute_v2(src, volume, na(qtSig), qtSig, sigStack, rspSig, trendBeta,
     latConf, sysRisk, pLow, pMed, pHigh, pSpike,
     coord, disp, precW, manifoldQuality, signalThr,
     expertAction, expertEdge, expertConf,
     trust, gain, metaWeights, leader,
     longEvent or shortEvent, resetEvent, longEvent, shortEvent,
     true, visualHeightCap, manifoldAmp, opacityMod,
     crestGain, refractionFx, iceSmoothLen, depthGain, prismShift,
     glowBoost, glassBlend, prismShiftEdge, schumannHybridWeight,
     aegisBlueHybridWeight, horusNsmWeight, horusNsmOpacity, horusNsmLift,
     mf.kalmanLock01, mf.markovTransProb01, mf.waveletEnergy01, mf.hawkesPressure01,
     mf.spectralPurity01, mf.dfaLong01, mf.subMass01, mf.subSpin, mf.subCharge,
     mf.subLifetime01, mf.harmonicResonance01)

// Visual rendering maps the computed RenderState into layered iceberg fills, NSM wireframes, refraction bands, and regime background.
float refColorScale = math.max(visualHeightCap * 0.58, 1e-6)

// Purpose: Compute the optical ice color for a manifold shell.
// Mechanics: Magnitude, sign, depth, Fresnel response, subsurface scattering, dispersion, and occlusion determine palette segment and transparency.
f_birefringent_ice(float val, float scaleRef, float depthPhase) =>
    float n = f_clamp01(math.abs(nz(val, 0.0)) / math.max(scaleRef, 1e-5))

    float fresnel = math.pow(n, 2.8)

    float sss = math.sin(n * math.pi) * (1.0 - depthPhase)

    float hueShift = depthPhase * 0.06

    color baseC = na
    if nz(val, 0.0) >= 0.0

        float p = f_clamp01(n + hueShift)
        baseC := p <= 0.33 ? f_hsv_lerp(p / 0.33, #1a0033, #a400ff) :
                 p <= 0.66 ? f_hsv_lerp((p - 0.33) / 0.33, #a400ff, #ff0e85) :
                 f_hsv_lerp((p - 0.66) / 0.34, #ff0e85, #ff6600)
    else

        float p = f_clamp01(n + hueShift)
        baseC := p <= 0.33 ? f_hsv_lerp(p / 0.33, #000033, #0055ff) :
                 p <= 0.66 ? f_hsv_lerp((p - 0.33) / 0.33, #0055ff, #00e5ff) :
                 f_hsv_lerp((p - 0.66) / 0.34, #00e5ff, #13ff00)

    float aoDarkening = (1.0 - n) * depthPhase * 0.45
    color occludedC = f_rgb_mix(baseC, #020611, aoDarkening, 100)

    float targetAlpha = 94.0 - (42.0 * fresnel) - (18.0 * depthPhase) - (20.0 * sss) + (iceberg.signalFragility * 5.0)

    color.new(occludedC, int(f_clamp(targetAlpha, 0.0, 100.0)))

// Shell interpolation derives intermediate manifold layers through Fibonacci-weighted blends between principal crests.
float shell24_1 = iceberg.crest2 * 0.8541019662 + iceberg.crest4 * 0.1458980338
float shell24_2 = iceberg.crest2 * 0.6180339887 + iceberg.crest4 * 0.3819660113
float shell24_3 = iceberg.crest2 * 0.3819660113 + iceberg.crest4 * 0.6180339887
float shell24_4 = iceberg.crest2 * 0.1458980338 + iceberg.crest4 * 0.8541019662

float shell46_1 = iceberg.crest4 * 0.8541019662 + iceberg.crest6 * 0.1458980338
float shell46_2 = iceberg.crest4 * 0.6180339887 + iceberg.crest6 * 0.3819660113
float shell46_3 = iceberg.crest4 * 0.3819660113 + iceberg.crest6 * 0.6180339887
float shell46_4 = iceberg.crest4 * 0.1458980338 + iceberg.crest6 * 0.8541019662

float shell68_1 = iceberg.crest6 * 0.8541019662 + iceberg.crest8 * 0.1458980338
float shell68_2 = iceberg.crest6 * 0.6180339887 + iceberg.crest8 * 0.3819660113
float shell68_3 = iceberg.crest6 * 0.3819660113 + iceberg.crest8 * 0.6180339887
float shell68_4 = iceberg.crest6 * 0.1458980338 + iceberg.crest8 * 0.8541019662

// Optical pass colors each shell before the fill stack is rendered.
color opt2    = f_birefringent_ice(iceberg.crest2, refColorScale, 0.00)
// Optical pass colors each shell before the fill stack is rendered.
color opt24_1 = f_birefringent_ice(shell24_1,      refColorScale, 0.05)
// Optical pass colors each shell before the fill stack is rendered.
color opt24_2 = f_birefringent_ice(shell24_2,      refColorScale, 0.13)
// Optical pass colors each shell before the fill stack is rendered.
color opt24_3 = f_birefringent_ice(shell24_3,      refColorScale, 0.20)
// Optical pass colors each shell before the fill stack is rendered.
color opt24_4 = f_birefringent_ice(shell24_4,      refColorScale, 0.28)

color opt4    = f_birefringent_ice(iceberg.crest4, refColorScale, 0.33)
color opt46_1 = f_birefringent_ice(shell46_1,      refColorScale, 0.38)
color opt46_2 = f_birefringent_ice(shell46_2,      refColorScale, 0.46)
color opt46_3 = f_birefringent_ice(shell46_3,      refColorScale, 0.54)
color opt46_4 = f_birefringent_ice(shell46_4,      refColorScale, 0.61)

color opt6    = f_birefringent_ice(iceberg.crest6, refColorScale, 0.66)
color opt68_1 = f_birefringent_ice(shell68_1,      refColorScale, 0.71)
color opt68_2 = f_birefringent_ice(shell68_2,      refColorScale, 0.80)
color opt68_3 = f_birefringent_ice(shell68_3,      refColorScale, 0.88)
color opt68_4 = f_birefringent_ice(shell68_4,      refColorScale, 0.95)
color opt8    = f_birefringent_ice(iceberg.crest8, refColorScale, 1.00)

// Rendering pass emits the backdrop, filled manifold shells, specular rims, refraction band, NSM traces, and adaptive regime shadow.
bgcolor(showBackdrop ? color.new(iceberg.deepVoid, iceberg.bgAlpha) : na, title="Iceberg Backdrop")
zeroPlot = plot(0, "Zero Axis", color=color.new(#476dff, 74), linewidth=1)

pAura = plot(showManifold ? iceberg.aura : na, color=na, display=display.none, title="Iceberg Aura")
fill(pAura, zeroPlot, color=color.new(opt8, int(f_clamp(color.t(opt8) + 16.0, 0, 100))), title="Iceberg Aura Fill")

pC2     = plot(showManifold ? iceberg.crest2 : na, color=na, display=display.none)
pC24_1  = plot(showManifold ? shell24_1      : na, color=na, display=display.none)
pC24_2  = plot(showManifold ? shell24_2      : na, color=na, display=display.none)
pC24_3  = plot(showManifold ? shell24_3      : na, color=na, display=display.none)
pC24_4  = plot(showManifold ? shell24_4      : na, color=na, display=display.none)
pC4     = plot(showManifold ? iceberg.crest4 : na, color=na, display=display.none)
pC46_1  = plot(showManifold ? shell46_1      : na, color=na, display=display.none)
pC46_2  = plot(showManifold ? shell46_2      : na, color=na, display=display.none)
pC46_3  = plot(showManifold ? shell46_3      : na, color=na, display=display.none)
pC46_4  = plot(showManifold ? shell46_4      : na, color=na, display=display.none)
pC6     = plot(showManifold ? iceberg.crest6 : na, color=na, display=display.none)
pC68_1  = plot(showManifold ? shell68_1      : na, color=na, display=display.none)
pC68_2  = plot(showManifold ? shell68_2      : na, color=na, display=display.none)
pC68_3  = plot(showManifold ? shell68_3      : na, color=na, display=display.none)
pC68_4  = plot(showManifold ? shell68_4      : na, color=na, display=display.none)
pC8     = plot(showManifold ? iceberg.crest8 : na, color=na, display=display.none)

fill(pC2,    zeroPlot, color=opt2)
fill(pC24_1, pC2,      color=opt24_1)
fill(pC24_2, pC24_1,   color=opt24_2)
fill(pC24_3, pC24_2,   color=opt24_3)
fill(pC24_4, pC24_3,   color=opt24_4)
fill(pC4,    pC24_4,   color=opt4)
fill(pC46_1, pC4,      color=opt46_1)
fill(pC46_2, pC46_1,   color=opt46_2)
fill(pC46_3, pC46_2,   color=opt46_3)
fill(pC46_4, pC46_3,   color=opt46_4)
fill(pC6,    pC46_4,   color=opt6)
fill(pC68_1, pC6,      color=opt68_1)
fill(pC68_2, pC68_1,   color=opt68_2)
fill(pC68_3, pC68_2,   color=opt68_3)
fill(pC68_4, pC68_3,   color=opt68_4)
fill(pC8,    pC68_4,   color=opt8)

color rimMidColor = color.new(opt68_2, int(f_clamp(color.t(opt68_2) - 15.0, 0.0, 100.0)))
color rimOutColor = color.new(opt8,    int(f_clamp(color.t(opt8)    - 25.0, 0.0, 100.0)))

plot(showManifold ? shell68_2      : na, color=rimMidColor, linewidth=1, title="Skin Specular Mid")
plot(showManifold ? iceberg.crest8 : na, color=rimOutColor, linewidth=2, title="Skin Specular Rim")

pHU = plot(showBands ? iceberg.horizonUp : na, color=color.new(#00e5ff, 45), linewidth=1, title="Refraction Horizon Up")
pHD = plot(showBands ? iceberg.horizonDn : na, color=color.new(#fff200, 45), linewidth=1, title="Refraction Horizon Down")
fill(pHU, pHD, color=color.new(f_hsv_lerp(f_clamp01(0.5 + 0.5 * iceberg.cryoFlux), #fff200, #00e5ff), 92), title="Refraction Band")

pNSM1 = plot(showHorus and showManifold ? iceberg.nsmH1 : na, title="Directional Collapse", color=iceberg.nsmH1Color, linewidth=2)
pNSM2 = plot(showHorus and showManifold ? iceberg.nsmH2 : na, title="Structural Coherence", color=iceberg.nsmH2Color, linewidth=2)
pNSM3 = plot(showHorus and showManifold ? iceberg.nsmH3 : na, title="Instability Rim", color=iceberg.nsmH3Color, linewidth=2)

fill(pNSM1, zeroPlot, color=showHorus and showManifold ? iceberg.nsmFill1Color : na, title="Horus NSM 7.83 Ghost")
fill(pNSM2, pNSM1, color=showHorus and showManifold ? iceberg.nsmFill2Color : na, title="Horus NSM 14.30 Ghost")
fill(pNSM3, pNSM2, color=showHorus and showManifold ? iceberg.nsmFill3Color : na, title="Horus NSM 20.80 Ghost")

int regimeBgSmoothRender = math.max(regimeBgSmooth * 3, 21)
color regimeColorRaw = ice_regimeBgColor(iceberg, regimeBgMode, regimeBgSmoothRender, regimeBgAlpha, regimeBgStrength * 0.78, visualHeightCap)
color regimeColorSoft = na(regimeColorRaw) ? na : color.new(regimeColorRaw, int(f_clamp(color.t(regimeColorRaw) + 18.0, 0, 100)))
bgcolor(regimeColorSoft, title="Regime")
````

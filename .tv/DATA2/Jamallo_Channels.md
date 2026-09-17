<!-- tradingview-pine-id: PUB;b8d4bcd640f24950913c2ef0cf8962b4 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Jamallo Channels

Source: https://www.tradingview.com/script/mHsQtfUd-Jamallo-Channels/

## Description

🔹Intro

For decades, technical traders have relied on conventional channel models, each burdened by fundamental mathematical limitations:
- Bollinger Bands rely on simple moving averages (SMA) and raw price standard deviation. When strong directional trends emerge, raw variance conflates trend slope with volatility, causing the bands to artificially flare open ("volatility bulge") and produce severe lag and  frequent false mean-reversion signals.

- Keltner Channels utilize exponential moving averages (EMA) wrapped with Average True Range (ATR). While smoother, the EMA introduces continuous phase delay, and the bands drift constantly with price, failing to provide stable, horizontal support and resistance benchmarks during consolidation.

- Donchian Channels plot rolling highest highs and lowest lows over an N-bar window. However, they are exceptionally vulnerable to single-bar outlier wicks and sudden step jumps that distort the true statistical distribution without accounting for underlying volatility dynamics.

Jamallo Channels resolves these structural flaws through a novel mathematical synthesis:
1. It replaces lagging moving averages with a multi-resolution Maximal Overlap Discrete Wavelet Transform (MODWT) Haar filter bank coupled with an energy-calibrated deadband step-hold state machine. The baseline remains strictly stationary during consolidation and snaps instantaneously to new price levels upon statistically significant drift.

2. It decouples trend from volatility by computing standard deviation strictly on the detrended high-frequency wavelet residual, filtered through a rolling linear-interpolation median to eliminate spike distortion.

3. It locks the volatility corridor at the exact moment a new regime step triggers—producing pristine, step-synchronized horizontal channels and mathematically robust exhaustion zones.

🔹Break down

1. Multi-Resolution Haar Wavelet MODWT Engine:
- Undecimated Dyadic Decomposition: Deconstructs raw price action across up to 5 dyadic scale levels (Level 1 = 2-bar, Level 2 = 4-bar, Level 3 = 8-bar, Level 4 = 16-bar, Level 5 = 32-bar) into orthogonal approximation (trend) and detail (high-frequency noise) coefficients without phase distortion or downsampling loss.

- Scale-Adaptive Smoothing: Isolates the true low-frequency structural trend from intraday churn and microstructure noise at the selected dyadic decomposition level.

- Dynamic Detail Energy Tracking: Measures the real-time volatility intensity of the high-frequency detail spectrum by computing a rolling Simple Moving Average of absolute detail coefficients over a calibrated lookback window.

2. Energy-Calibrated Deadband Step-Hold Mechanism:
- Statistical Innovation Filtering: Establishes an adaptive deadband threshold scaled directly by the product of the detail energy and a deadband multiplier.

- Zero-Drift Piecewise Step-Holding: The smooth wavelet baseline is held strictly horizontal until price innovation definitively breaches the dynamic detail deadband threshold. Once breached, the baseline snaps instantaneously to the new equilibrium price level, eliminating baseline drifting during consolidation phases.

- Clean Regime Direction State: Evaluates the direction of every confirmed step, immediately classifying the market into Bullish (Teal) or Bearish (Maroon) regime states.

3. Detrended Residual Volatility & Frozen Sigma Bands:
- Trend-Decoupled Dispersion Measurement: Unlike standard deviation calculated around lagging moving averages—which artificially inflates during strong trends—Jamallo Channels isolates the high-frequency wavelet residual (Price minus Wavelet Mid) before computing variance, capturing genuine localized volatility.

- Median Filter Outlier Rejection: Applies a rolling linear-interpolation median filter (50th percentile over a 100-bar window) to the raw residual standard deviation, immunizing the channel against one-off spike anomalies and erratic expansion.

- Step-Locked Volatility Corridors: Volatility is sampled and frozen precisely at the moment a new Haar baseline step triggers. The frozen sigma remains constant throughout the entire regime life cycle, producing stable, non-wiggling horizontal channels.

4. Multi-Tier Volatility Corridors & Exhaustion Envelopes:
- Inner Expansion Zone (1.0σ): Defines the immediate high-probability operational boundary around the stepped trend baseline.

- Mid Dispersion Boundary (2.0σ): Represents standard 2-sigma statistical bounds where normal trending impulse legs oscillate.

- Outer Exhaustion & Mean-Reversion Zone (3.0σ): The extreme channel boundary (2.0σ to 3.0σ highlighted by shaded backgrounds) marks statistical overextension where price is prime for momentum exhaustion and mean-reverting retests back to the Haar stepped baseline.

🔹How to use: Trend Following & Risk Management

Jamallo Channels provides clear, objective mathematical parameters for both momentum trend riders and mean-reversion scalpers across all timeframes.

Regime Trend Trading:
- Setup & Execution: Enter in the direction of a newly confirmed Haar baseline step (when the baseline shifts color to Teal for Longs or Maroon for Shorts) or upon a sustained price breakout above/below the baseline following volatility compression.
- Stop Loss Placement: Anchor stop loss orders directly behind the most recent stepped Haar baseline level or just outside the opposite inner/mid channel boundary.
- Trailing & Letting Winners Run: Trail stop loss orders systematically step-by-step as new horizontal baseline rungs are confirmed, protecting capital while letting winners ride the macro expansion.

Mean-Reversion & Exhaustion Scalping:
- Exhaustion Rejection: When price enters the extreme 2.0σ–3.0σ outer band corridor (upper red fill or lower teal fill) and forms rejection wicks or structural exhaustion patterns, execute counter-trend mean-reversion setups.
- Take-Profit Targets: Target the inner channel (1.0σ) for partial profits and the primary Haar stepped baseline (0σ mean) for final profit harvesting.
- Invalidation / Stop Loss: Place tight stop losses just beyond the outer 3.0σ boundary line.

🔹Settings Parameters

Haar Wavelet Basis:
- Basis Level (1 - 5): Selects the dyadic wavelet decomposition scale (1 = 2-bar, 2 = 4-bar, 3 = 8-bar, 4 = 16-bar, 5 = 32-bar). Higher levels smooth out larger macro trends, while lower levels capture high-frequency swings.
- Deadband Multiplier (0.1 - 10.0): Scaling coefficient applied to the detail energy. Higher values widen the deadband, requiring larger directional thrusts to trigger a new step and producing wider, noise-immune steps.
- Detail Energy Lookback (5 - 200): The rolling lookback window used to calculate the average magnitude of wavelet detail coefficients.

Stdev Bands:
- Stdev Length (min 2): Lookback period for measuring the standard deviation of the detrended wavelet residual.
- Inner Multiplier (0.1 - 10.0): Standard deviation multiplier for the inner channel envelope (default: 1.0σ).
- Mid Multiplier (0.1 - 10.0): Standard deviation multiplier for the middle channel envelope (default: 2.0σ).
- Outer Multiplier (0.1 - 10.0): Standard deviation multiplier for the extreme exhaustion envelope (default: 3.0σ).

Display Settings:
- Basis Up Color: Custom color for the stepped baseline during bullish regime states (default: Teal).
- Basis Down Color: Custom color for the stepped baseline during bearish regime states (default: Maroon).
- Upper Color: Accent color for the upper channel bands and exhaustion fills (default: Red).
- Lower Color: Accent color for the lower channel bands and exhaustion fills (default: Teal).
- Show Fill: Toggles background shading for the inner and outer volatility corridors.

---

## Source Code

````pine
//@version=6
indicator("Jamallo Channels", overlay=true, max_bars_back=500)

// =============================================================================
// INPUTS
// =============================================================================
group_wave = "Haar Wavelet Basis"
int   wLevel    = input.int(3, "Basis Level", minval=1, maxval=5,
     tooltip="Wavelet scale.\n1=2-bar  2=4-bar  3=8-bar  4=16-bar  5=32-bar",
     group=group_wave)
float dbMult    = input.float(5.0, "Deadband Multiplier", minval=0.1, maxval=10.0, step=0.1,
     tooltip="Higher = fewer, larger basis steps.", group=group_wave)
int   energyLen = input.int(100, "Detail Energy Lookback", minval=5, maxval=200, group=group_wave)

group_bands = "Stdev Bands"
int   stdevLen = input.int(21, "Stdev Length", minval=2, group=group_bands)
float mult2    = input.float(1.0, "Inner Multiplier", minval=0.1, step=0.1, group=group_bands)
float mult3    = input.float(2.0, "Mid Multiplier",   minval=0.1, step=0.1, group=group_bands)
float mult4    = input.float(3.0, "Outer Multiplier", minval=0.1, step=0.1, group=group_bands)

group_disp = "Display"
color basisUp   = input.color(color.teal,   "Basis Up Color",   group=group_disp)
color basisDn   = input.color(color.maroon, "Basis Down Color", group=group_disp)
color upColor    = input.color(color.red,    "Upper Color",  group=group_disp)
color dnColor    = input.color(color.teal,   "Lower Color",  group=group_disp)
bool  showFill   = input.bool(true, "Show Fill", group=group_disp)

// =============================================================================
// HAAR WAVELET MODWT — stepped basis (deadband step-hold)
// Full decomposition with detail coefficients. haar_trend only updates when
// the smooth mid escapes the detail-energy deadband. This is the genuine
// wavelet step-hold from Trend Sniper - Haar Wavelet Edition.
// =============================================================================
f_haar_stepped(series float src, simple int level, simple float dbmult, simple int enlen) =>
    float v1 = (src + nz(src[1], src)) / 2.0
    float d1 = (src - nz(src[1], src)) / 2.0
    float v2 = (v1 + nz(v1[2],  v1)) / 2.0
    float d2 = (v1 - nz(v1[2],  v1)) / 2.0
    float v3 = (v2 + nz(v2[4],  v2)) / 2.0
    float d3 = (v2 - nz(v2[4],  v2)) / 2.0
    float v4 = (v3 + nz(v3[8],  v3)) / 2.0
    float d4 = (v3 - nz(v3[8],  v3)) / 2.0
    float v5 = (v4 + nz(v4[16], v4)) / 2.0
    float d5 = (v4 - nz(v4[16], v4)) / 2.0
    float sm = level == 1 ? v1 : level == 2 ? v2 : level == 3 ? v3 : level == 4 ? v4 : v5
    float dt = level == 1 ? d1 : level == 2 ? d2 : level == 3 ? d3 : level == 4 ? d4 : d5
    float de = ta.sma(math.abs(dt), enlen)
    float th = de * dbmult
    var float tr = na
    tr := na(tr) ? sm : math.abs(sm - tr) > th ? sm : tr
    [tr, sm, dt]

// =============================================================================
// BASIS: Haar wavelet step-hold on close (replaces the SMA middle)
// =============================================================================
[haar_trend, waveletMid, waveletDetail] = f_haar_stepped(close, wLevel, dbMult, energyLen)

// Direction state — same pattern as Trend Sniper Haar Edition
var bool signal_up = true
if haar_trend > nz(haar_trend[1], haar_trend)
    signal_up := true
else if haar_trend < nz(haar_trend[1], haar_trend)
    signal_up := false
color basisColor = signal_up ? basisUp : basisDn

// =============================================================================
// STDEV BANDS — frozen at each basis step
// Standard deviation is measured from the detrended wavelet residual instead
// of raw close. Its rolling median rejects both unusually large and unusually
// small readings, preventing abrupt changes in channel size between steps.
// =============================================================================
float waveletResidual = close - waveletMid
float rawSigma = ta.stdev(waveletResidual, stdevLen)
float medianSigma = ta.percentile_linear_interpolation(rawSigma, 100, 50)
float sigmaCandidate = nz(medianSigma[1], medianSigma)
var float frozenSigma = na
var float prevTrend   = na

if na(frozenSigma) and not na(sigmaCandidate)
    frozenSigma := sigmaCandidate
else if haar_trend != nz(prevTrend, haar_trend) and not na(sigmaCandidate)
    frozenSigma := sigmaCandidate
prevTrend := haar_trend

float upper2 = haar_trend + mult2 * frozenSigma
float lower2 = haar_trend - mult2 * frozenSigma
float upper3 = haar_trend + mult3 * frozenSigma
float lower3 = haar_trend - mult3 * frozenSigma
float upper4 = haar_trend + mult4 * frozenSigma
float lower4 = haar_trend - mult4 * frozenSigma

// =============================================================================
// PLOTS — all width 1, ordinary continuous lines, no stepline style
// Signal line keeps full opacity; band lines and fills are reduced.
// =============================================================================
// Basis (signal line - full opacity, direction colored)
p_mid = plot(haar_trend, "Basis", color=basisColor, linewidth=1)

// Inner bands (hidden, for fill only — matches original display=none)
p_up2 = plot(upper2, "Upper 2", color=na, display=display.none, linewidth=1)
p_dn2 = plot(lower2, "Lower 2", color=na, display=display.none, linewidth=1)

// Mid bands (visible, reduced opacity)
p_up3 = plot(upper3, "Upper 3", color=color.new(upColor, 50), linewidth=1)
p_dn3 = plot(lower3, "Lower 3", color=color.new(dnColor, 50), linewidth=1)

// Outer bands (visible, reduced opacity)
p_up4 = plot(upper4, "Upper 4", color=color.new(upColor, 60), linewidth=1)
p_dn4 = plot(lower4, "Lower 4", color=color.new(dnColor, 60), linewidth=1)

// Fills — same structure as Jamallo Trend Bands, reduced opacity
fill(p_up2, p_mid, color=showFill ? color.new(upColor, 90) : na, title="Inner Upper Fill")
fill(p_dn2, p_mid, color=showFill ? color.new(dnColor, 90) : na, title="Inner Lower Fill")
fill(p_up3, p_up4, color=showFill ? color.new(upColor, 97) : na, title="Upper Band Background")
fill(p_dn3, p_dn4, color=showFill ? color.new(dnColor, 97) : na, title="Lower Band Background")
````

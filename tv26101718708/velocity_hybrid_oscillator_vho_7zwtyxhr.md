# Velocity Hybrid Oscillator (VHO)

- url: https://www.tradingview.com/script/7zwTyXhR/
- type: indicator
- pine_id: PUB;408877d241b04b6982c29ea5b38a8d8e
- version: 1.0

## Description

🚀 VELOCITY HYBRID OSCILLATOR [VHO]

The Velocity Hybrid Oscillator (VHO), engineered by gunebak4n, is a dual-momentum normalization and trend velocity detection framework designed to isolate high-probability cyclical turning points and structural trend regimes.

VHO is built on the principle that true market velocity cannot be captured by a single momentum lookback or absolute price changes alone. By structurally merging the trend-following smoothing of the Price Momentum Oscillator (PMO) with the reactive cyclicality of the Relative Strength Index (RSI), and processing both through a rolling Min-Max normalization matrix, the system projects multi-dimensional momentum fields onto a fixed boundary.

Unlike conventional oscillators that frequently pin at extremes or trigger premature counter-trend signals during strong expansions, VHO normalizes relative strength and price velocity over a wide structural lookback, anchoring the final hybrid signal to a highly scannable, noise-filtered trend baseline.

💡 CORE DESIGN PRINCIPLE

🧭 Multi-Dimensional Momentum Convergence
VHO interprets market momentum not as an isolated price derivative, but as a convergence of absolute velocity (PMO) and internal strength velocity (RSI). True trend shifts emerge when these two fields align within a normalized range.

🧬 Absolute Velocity–Internal Strength–Smoothing Model
The system evaluates three interacting structural layers:
• Absolute Velocity: Double-smoothed Price Momentum Oscillator tracking rate of change.
• Internal Strength: Relative Strength Index tracking gains versus losses.
• Min-Max Normalization: Rescaling both metrics to a dynamic 144-period lookback.

The mathematical aggregation of these layers defines the final hybrid trend line.

💡 KEY FEATURES

📊 Double-Smoothed Absolute Velocity (PMO)
The system extracts clean, absolute price velocity by calculating a custom Price Momentum Oscillator. This process applies two sequential exponential moving averages to custom daily rate-of-change inputs, effectively filtering out high-frequency market noise before normalization.

🧪 Cyclical Internal Strength Layer (RSI)
To capture real-time overbought and oversold conditions without lagging the underlying price discovery, the system integrates a classical relative strength layer, subsequently smoothed by a simple moving average to align its frequency with the PMO.

📦 Dynamic Min-Max Normalization Matrix
To prevent standard indicator drift and pinning, both the raw PMO and smoothed RSI values are dynamically rescaled between 0 and 100 based on a fixed rolling lookback. This anchors all historical data points to identical relative boundaries.

📈 Velocity Hybrid Line Aggregation
The normalized absolute velocity and normalized internal strength are synthesized into a single "Sharp Line," which is then subjected to an exponential smoothing filter to generate the final, high-conviction "Hybrid Line."

🧠 Asymmetric Color & Directional Logic
The main signal line features an adaptive, four-state color architecture that reacts instantly to directional changes relative to the 50-midline pivot, shifting hue based on whether the velocity is expansionary or decaying.

🎨 Structural Divergence Detection Engine
VHO automatically maps multi-factor divergence signals across structural price action. High-probability continuation or reversal points are highlighted by identifying localized asymmetries where price makes new extremes while the Hybrid Line prints decaying peaks or troughs.

🔬 MATHEMATICAL STRUCTURE

Price Rate of Change (ROC):
ROC = ((Close - Close[1]) / 1) * 100

Double-Smoothed PMO:
PMO = EMA(EMA(ROC, Length1), Length2)
PMO_Raw = (PMO + PMO_Signal) / 2

RSI Internal Strength:
RSI = ta.rsi(Source, Length)
RSI_MaRaw = SMA(RSI, RSI_MA_Length)

Min-Max Normalization Function (f_normalize):
Min = Lowest(Source, Length)
Max = Highest(Source, Length)
f_normalize = 100 * (Source - Min) / max(Max - Min, 0.000001)

Hybrid Line Aggregation:
SharpLine = (f_normalize(PMO_Raw, n) + f_normalize(RSI_MaRaw, n)) / 2
HybridLine = EMA(SharpLine, k)

Divergence Signal Matrix:
BearishDiv = ta.rising(High, 5) and ta.falling(HybridLine, 5) and HybridLine > 70
BullishDiv = ta.falling(Low, 5) and ta.rising(HybridLine, 5) and HybridLine < 30

This structure ensures that cyclical overextended states are measured against a standardized historical baseline, rather than floating nominal boundaries.

🛠️ USAGE FRAMEWORK

1. Midline Pivot Evaluation
Treat the 50 level as the structural axis of equilibrium. Hybrid Line values sustained above 50 dictate a dominant bullish regime, while values below 50 confirm bearish structural control.
2. Directional Velocity Scaling
Monitor the four-state line coloration. A bright cyan (#00ffbb) or bright red (#ff5252) signal line denotes maximum acceleration in trend direction, while darker tones indicate velocity decay or potential consolidation.
3. Symmetrical Overextended Extremes
Utilize the 70 and 30 dashed reference levels to identify standard overbought and oversold thresholds. The dotted 90 and 10 parameters act as absolute extreme volatility caps.
4. Multi-Factor Divergence Validation
When the system prints red (bearish) or green (bullish) circles on the Hybrid Line, cross-reference these divergence zones with major support/resistance levels to time high-probability counter-trend reversals.
5. Regime Background Filtering
Leverage the optional "Trend Background" fill to maintain clear macro-bias context, allowing short-term hybrid fluctuations to be scaled within the overarching directional environment.

⚙️ SYSTEM CHARACTERISTICS

• Dual-engine absolute and internal velocity integration
• Fixed-boundary rolling Min-Max normalization matrix
• Four-state direction-and-regime sensitive line coloring
• Automatic high-probability divergence mapping
• Multi-layered zone fill for enhanced visual scannability
• Fully parameterized smoothing filters to match any operational asset class

📌 CREDIT

Velocity Hybrid Oscillator (VHO) is developed by gunebak4n as a structural momentum normalization and trend velocity detection framework for TradingView.

The system is designed for identifying statistically significant cyclical shifts emerging from multi-factor momentum compression, rather than isolated price-action breakouts.

⚠️ DISCLAIMER

VHO is a probabilistic analytical model. It does not predict market outcomes or guarantee trading performance. All signals must be interpreted within a disciplined risk management framework and validated with broader market context.

## Source Code

````pine
//@version=6
// Indicator Name: Velocity Hybrid Oscillator (VHO)
// Author: gunebak4n
// Description: A dual-momentum indicator combining Price Momentum Oscillator (PMO) 
// and RSI-based Moving Averages, normalized over a 144-period lookback.
indicator("Velocity Hybrid Oscillator", "VHO", overlay = false)

import TradingView/ta/11 as TVta

// --- 1. CORE FUNCTIONS ---
// Min-Max Normalization: Rescales any data point to a 0-100 range based on a specific lookback.
f_normalize(_src, _len) =>
    float _min = ta.lowest(_src, _len)
    float _max = ta.highest(_src, _len)
    100 * (_src - _min) / math.max(_max - _min, 0.000001)

// --- 2. INPUT SETTINGS ---
int   normLookback   = input.int(144, "Normalization Lookback", 1, group="General Settings", tooltip="Number of bars used to rescale the indicator line between 0 and 100.")
int   smoothLength   = input.int(5,  "Smoothing Length", 1, group="General Settings", tooltip="Smoothing factor for the main hybrid line. Higher values reduce market noise.") 
bool  showBg         = input.bool(true, "Show Trend Background", group="Visual Settings")

// PMO (Price Momentum Oscillator) Parameters
float sourceInput    = input.source(close, "Source", group="PMO Settings")
int   length1Input   = input.int(35, "PMO Length 1 (Long)", group="PMO Settings")
int   length2Input   = input.int(20, "PMO Length 2 (Short)", group="PMO Settings")
int   signalInput    = input.int(10, "PMO Signal Length", group="PMO Settings")

// RSI (Relative Strength Index) Parameters
int   rsiLength      = input.int(14, "RSI Length", group="RSI Settings")
int   rsiMaLength    = input.int(14, "RSI MA Length", group="RSI Settings")

// --- 3. CALCULATIONS ---
[pmo, signal] = TVta.pmo(sourceInput, length1Input, length2Input, signalInput)
float pmoRaw  = (pmo + signal) / 2
float rsiValue = ta.rsi(sourceInput, rsiLength)
float rsiMaRaw = ta.sma(rsiValue, rsiMaLength)

float pmoNorm    = f_normalize(pmoRaw, normLookback)
float rsiMaNorm  = f_normalize(rsiMaRaw, normLookback)
float sharpLine  = (pmoNorm + rsiMaNorm) / 2 
float hybridLine = ta.ema(sharpLine, smoothLength)

// --- 4. VISUALS & COLOR LOGIC ---
bool isRising   = ta.rising(hybridLine, 1)
color lineColor = hybridLine > 50 ? (isRising ? #00ffbb : #00897b) : (ta.falling(hybridLine, 1) ? #ff5252 : #b22222)

color bgColor = showBg ? (hybridLine > 50 ? color.new(color.teal, 93) : color.new(color.maroon, 93)) : na
bgcolor(bgColor)

// --- 5. DIVERGENCE LOGIC ---
bool bearishDiv = ta.rising(high, 5) and ta.falling(hybridLine, 5) and hybridLine > 70
bool bullishDiv = ta.falling(low, 5) and ta.rising(hybridLine, 5) and hybridLine < 30

// --- 6. PLOTTING ---
plot(hybridLine, "Velocity Hybrid Line", color=lineColor, linewidth=3)

// Divergence Circles
plot(bearishDiv ? hybridLine : na, "Bearish Divergence", color=color.red, style=plot.style_circles, linewidth=4)
plot(bullishDiv ? hybridLine : na, "Bullish Divergence", color=color.green, style=plot.style_circles, linewidth=4)

// --- 7. HORIZONTAL REFERENCE LEVELS (90-70-50-30-10) ---
h_ext_high = hline(90, "Extreme High Zone", color=color.new(color.red, 60), linestyle=hline.style_dotted)
h_high     = hline(70, "Overbought Level", color=color.new(color.red, 40), linestyle=hline.style_dashed)
h_mid      = hline(50, "Midline (Pivot)", color=color.new(color.gray, 20), linewidth=1)
h_low      = hline(30, "Oversold Level", color=color.new(color.green, 40), linestyle=hline.style_dashed)
h_ext_low  = hline(10, "Extreme Low Zone", color=color.new(color.green, 60), linestyle=hline.style_dotted)

// Fill Zones for better readability
fill(h_high, h_mid, color=color.new(color.red, 97), title="Upper Zone")
fill(h_mid, h_low, color=color.new(color.green, 97), title="Lower Zone")
````

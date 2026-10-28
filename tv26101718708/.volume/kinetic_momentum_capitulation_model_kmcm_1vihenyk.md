# Kinetic Momentum & Capitulation Model (KMCM)

- url: https://www.tradingview.com/script/1ViHenyk/
- type: indicator
- pine_id: PUB;dce5aed5935b46549a45966fb73c4b1c
- version: 1.0

## Description

🚀 KMCM Adaptive Regime Oscillator (KMCM)

The KMCM (Kinetic Momentum & Capitulation Model) is a volatility-adaptive market regime oscillator designed to quantify directional energy imbalance by integrating price momentum, volume mass dynamics, and statistical energy dispersion into a single bounded regime signal. Rather than treating price as a simple time series, KMCM reconstructs market behavior as an energy system where movement intensity is jointly determined by velocity and participation.

The core objective of KMCM is to detect regime transitions between momentum expansion, neutral equilibrium, and capitulation-driven stress phases. It does this by modeling market activity as a normalized kinetic system and transforming the resulting distribution into a bounded oscillator ranging approximately between -100 and +100.

Unlike traditional momentum indicators that rely primarily on price derivatives (ROC, RSI, MACD), KMCM incorporates volume-adjusted mass and volatility-adaptive scaling. This allows the indicator to remain structurally stable across different volatility regimes and asset classes while preserving sensitivity to regime shifts.

💡 Key Features

🧠 Kinetic Market Model:
KMCM interprets market behavior as a simplified physical system where price velocity represents momentum and volume represents mass. The resulting “energy” formulation captures the intensity of participation behind directional moves rather than price movement alone.

📊 Volume-Normalized Mass Scaling:
Volume is normalized against its adaptive moving average to construct a relative participation metric. This ensures that abnormal volume expansions or contractions are properly reflected in regime intensity rather than absolute scale distortions.

🔬 Volatility-Adaptive Period Engine:
All internal computation windows are dynamically adjusted using ATR-based volatility ratios. This prevents overfitting to fixed time horizons and ensures that the model self-adapts to changing market regimes.

⚡ Statistical Energy Transformation:
Directional energy is derived from velocity-squared magnitude scaled by participation mass, then standardized using z-score normalization. This produces a statistically consistent representation of market stress and expansion phases.

🛡️ Nonlinear Compression Layer:
A hyperbolic tangent transformation compresses raw statistical output into a bounded oscillator space. This preserves extreme regime information while preventing signal saturation during high volatility events.

📉 Dual-Threshold Regime Logic:
Market conditions are classified into three primary states:

* Expansion Regime (Above Upper Threshold): Strong directional imbalance and momentum continuation pressure
* Neutral Regime (Between Thresholds): Balanced market structure and reduced directional conviction
* Capitulation Regime (Below Lower Threshold): Stress-driven liquidation dynamics and downside exhaustion phases

🔬 Mathematical Logic and Structure

KMCM is built on a multi-layer statistical energy framework that converts raw market microstructure into a normalized regime oscillator.

The process begins by computing velocity as a rate of change over an ATR-adaptive window. This velocity is then combined with a volume-derived mass factor, which represents relative participation intensity compared to its historical baseline.

A kinetic energy proxy is constructed by squaring velocity and scaling it with normalized mass. This formulation ensures that large directional moves with strong participation are weighted disproportionately higher than low-volume price fluctuations.

To stabilize the signal, directional energy is standardized using a rolling mean and standard deviation, producing a z-score representation of market imbalance. This step transforms raw energy into a distribution-aware signal that is comparable across time and assets.

The z-score output is then passed through a hyperbolic tangent function, compressing it into a bounded regime oscillator. This step ensures nonlinear saturation control while preserving structural extremes.

Finally, exponential smoothing is applied to reduce microstructure noise, and slope filtering is used to eliminate short-term directional instability. This results in a stable regime oscillator that prioritizes structural shifts over transient fluctuations.

In essence, KMCM does not attempt to predict price direction. It models the *intensity and structure of market participation* as a kinetic system and translates it into a unified regime framework of expansion, neutrality, and capitulation.

🛠️ How to Use

1. Expansion Regime (Above Upper Threshold):
   Indicates strong directional momentum supported by elevated participation. Trend continuation strategies and breakout positioning are statistically favored.

2. Capitulation Regime (Below Lower Threshold):
   Represents forced liquidation, panic-driven behavior, or exhaustion of selling pressure. Reversal or mean reversion structures become more relevant.

3. Neutral Regime (Between Thresholds):
   Signals equilibrium conditions where directional conviction is weak. Range-based strategies or reduced exposure conditions are more appropriate.

🎛️ Settings

* Minimum Velocity Period (7–21): Controls sensitivity of momentum detection
* Volume Period (30–150): Defines adaptive participation baseline
* Upper Threshold (30): Expansion boundary for regime classification
* Lower Threshold (-30): Capitulation boundary for regime classification
* Smoothing Length (7 EMA): Stabilization layer for signal refinement

📌 Credits and Origins

KMCM is engineered by @gunebak4n as a volatility-adaptive kinetic regime framework designed to unify momentum, volume, and statistical dispersion into a single structural oscillator. The model is intended for regime-based analysis rather than directional prediction, emphasizing structural transitions over raw price movement.

The design prioritizes robustness across volatility regimes, making it suitable for discretionary traders, quantitative researchers, and systematic strategy development workflows focused on regime awareness.

⚠️ Disclaimer

All outputs generated by KMCM are probabilistic and non-deterministic. This indicator does not predict future price direction or guarantee outcomes. It is a structural market analysis tool intended to support decision-making under uncertainty. Proper risk management is required at all times.

## Source Code

````pine
//@version=6
indicator("Kinetic Momentum & Capitulation Model", shorttitle="KMCM", overlay=false)

//────────────────────────────────────────────────────
// Kinetic Momentum & Capitulation Model (KMCM)
// Author: gunebak4n
//────────────────────────────────────────────────────


//────────────────────────────────────────────────────
// USER SETTINGS
//────────────────────────────────────────────────────

minV = input.int(7,  "Minimum Velocity Period")
maxV = input.int(21, "Maximum Velocity Period")
minM = input.int(30, "Minimum Volume Period")
maxM = input.int(150,"Maximum Volume Period")

upperThreshold = input.float(30,  "Upper Threshold", step=1)
lowerThreshold = input.float(-30, "Lower Threshold", step=1)

// NEW COLOR PALETTE
colorBull = input.color(color.aqua,      "Bull / FOMO Color")
colorBear = input.color(color.fuchsia,   "Bear / Panic Color")
colorNeutral = input.color(color.silver, "Neutral Color")

showDashboard = input.bool(true, "Show Dashboard")

//────────────────────────────────────────────────────
// VOLATILITY ADAPTIVE ENGINE
//────────────────────────────────────────────────────

atr = ta.atr(14)
atrMean = ta.sma(atr, 100)
safeAtrMean = na(atrMean) or atrMean == 0 ? 0.0001 : atrMean

volRatio = atr / safeAtrMean

vRaw = 21 / volRatio
mRaw = 120 / volRatio

vPeriod = int(math.max(1, nz(math.round(math.min(math.max(vRaw, minV), maxV)), 14)))
mPeriod = int(math.max(1, nz(math.round(math.min(math.max(mRaw, minM), maxM)), 50)))

//────────────────────────────────────────────────────
// CORE MODEL
//────────────────────────────────────────────────────

velocity = ta.roc(close, vPeriod)

avgVolume = ta.sma(volume, mPeriod)
safeAvgVolume = na(avgVolume) or avgVolume == 0 ? 0.0001 : avgVolume
mass = volume / safeAvgVolume

rawEnergy = 0.5 * mass * math.pow(velocity, 2)
directionalEnergy = velocity >= 0 ? rawEnergy : -rawEnergy

meanEnergy = ta.sma(directionalEnergy, mPeriod)
stdEnergy  = ta.stdev(directionalEnergy, mPeriod)
safeStd = na(stdEnergy) or stdEnergy == 0 ? 0.0001 : stdEnergy

zScore = (directionalEnergy - meanEnergy) / safeStd

tanh(x) =>
    ex = math.exp(x)
    emx = math.exp(-x)
    (ex - emx) / (ex + emx)

kmcm_raw = tanh(zScore) * 100

//────────────────────────────────────────────────────
// NOISE REDUCTION LAYER
//────────────────────────────────────────────────────

kmcm = ta.ema(kmcm_raw, 7)

kmcmSlope = kmcm - kmcm[1]

bullSignal = kmcm > upperThreshold and kmcmSlope > 0
bearSignal = kmcm < lowerThreshold and kmcmSlope < 0

//────────────────────────────────────────────────────
// VISUALIZATION
//────────────────────────────────────────────────────

kmcmColor =
     kmcm > upperThreshold ? colorBull :
     kmcm < lowerThreshold ? colorBear :
     colorNeutral

plot(kmcm, title="KMCM Smoothed Regime Oscillator", color=kmcmColor, linewidth=2)

hline(0, "Neutral", linestyle=hline.style_dotted)

// LEVELS
hline(80,  "+80", linestyle=hline.style_dotted, color=color.gray)
hline(-80, "-80", linestyle=hline.style_dotted, color=color.gray)

// UPDATED FROM 25 → 30
hline(30,  "+30", linestyle=hline.style_dotted, color=color.gray)
hline(-30, "-30", linestyle=hline.style_dotted, color=color.gray)

//────────────────────────────────────────────────────
// ZONE BACKGROUND
//────────────────────────────────────────────────────

bgcolor(kmcm > upperThreshold ? color.new(colorBull, 88) : na)
bgcolor(kmcm < lowerThreshold ? color.new(colorBear, 88) : na)
bgcolor(kmcm <= upperThreshold and kmcm >= lowerThreshold ? color.new(color.gray, 92) : na)

//────────────────────────────────────────────────────
// DASHBOARD
//────────────────────────────────────────────────────

var table t = table.new(position.top_right, 2, 3, border_width=2, border_color=color.white)

if barstate.islast and showDashboard
    regime =
         kmcm > upperThreshold ? "FOMO / OVERHEATED" :
         kmcm < lowerThreshold ? "PANIC / CAPITULATION" :
         "NEUTRAL / BALANCED"

    bg =
         kmcm > upperThreshold ? color.new(colorBull, 15) :
         kmcm < lowerThreshold ? color.new(colorBear, 15) :
         color.new(color.black, 5)

    table.cell(t, 0, 0, "Market Regime", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 0, regime, text_color=color.white, bgcolor=bg)

    table.cell(t, 0, 1, "Velocity Period", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 1, str.tostring(vPeriod), text_color=color.white, bgcolor=color.black)

    table.cell(t, 0, 2, "Volume Period", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 2, str.tostring(mPeriod), text_color=color.white, bgcolor=color.black)

//────────────────────────────────────────────────────
// ALERTS
//────────────────────────────────────────────────────

alertcondition(bullSignal, title="KMCM Bull Signal", message="Filtered bullish regime detected")
alertcondition(bearSignal, title="KMCM Bear Signal", message="Filtered bearish regime detected")
````

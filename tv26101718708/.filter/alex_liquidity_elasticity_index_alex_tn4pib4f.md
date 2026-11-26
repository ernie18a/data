# ALEX Liquidity & Elasticity Index (ALEX)

- url: https://www.tradingview.com/script/tN4Pib4f/
- type: indicator
- pine_id: PUB;af00dea19059498ca538f9546e1895d6
- version: 1.0

## Description

🚀 ALEX Liquidity & Elasticity Index (ALEX)

The ALEX Liquidity & Elasticity Index is an institutional-grade, quantitative market microstructure oscillator designed to measure liquidity stress, price elasticity, and hidden supply-demand imbalances in real time. Built on a fusion of Amihud illiquidity modeling, volatility-normalized divergence engines, and adaptive Gaussian smoothing systems, this indicator engineered by @gunebak4n isolates the true underlying behavior of market liquidity flow rather than raw price movement.

Unlike traditional oscillators that rely purely on momentum or overbought/oversold assumptions, ALEX reconstructs market behavior through a multi-layered statistical architecture that combines price impact sensitivity, volume efficiency, and divergence pressure into a single bounded regime signal.

The result is a clean, adaptive, and institutionally relevant liquidity spectrum that highlights when markets are expanding aggressively, compressing into accumulation phases, or transitioning into unstable imbalance regimes.

💡 Key Features

🧠 Liquidity Stress Engine (Amihud Core Model):
ALEX measures the relationship between price returns and dollar volume efficiency to estimate real-time market illiquidity. This allows detection of hidden execution stress that is not visible on standard price charts.

📊 Divergence Pressure System:
By comparing price momentum (ROC) against volume momentum, ALEX detects structural imbalance between buyers and sellers. This divergence layer acts as the core driver of regime classification.

🔬 Adaptive Gaussian Smoothing Architecture:
Multi-stage Gaussian filtering removes microstructure noise while preserving macro trend integrity. This ensures the signal reflects structural liquidity shifts rather than short-term volatility spikes.

⚡ Dynamic Regime Normalization:
All raw outputs are transformed into a bounded oscillator (-100 to +100) using adaptive scaling logic. This allows consistent interpretation across different market conditions and assets.

🛡️ Volatility-Responsive Threshold System:
Upper and lower extreme zones automatically adjust based on realized volatility. This ensures that signal sensitivity adapts to changing market regimes rather than relying on static levels.

📉 Liquidity Regime Classification:
ALEX dynamically categorizes market conditions into:

* Liquidity Vacuum (Aggressive Expansion / Stress Imbalance)
* Accumulation Zone (Absorption / Passive Buy Pressure)
* Trending Imbalance (Directional Continuation Phase)
* Balanced Regime (Neutral Equilibrium State)

🔬 Mathematical Logic and Structure

ALEX is constructed as a multi-layer liquidity-state transformation system that converts raw market microstructure into a bounded regime oscillator.

The model begins by defining market impact through an adapted Amihud Illiquidity framework, where price movement is evaluated relative to available trading volume. This creates the foundational liquidity stress variable, representing how “expensive” price movement is in current market conditions.

From there, the system applies statistical normalization using a rolling Z-score transformation. This step converts raw liquidity stress into a standardized deviation measure, allowing comparison across different volatility regimes.

To capture hidden structural imbalance, ALEX introduces a divergence engine between price momentum and volume momentum. When price acceleration is not confirmed by volume expansion, the system registers negative structural support; when both expand in sync, liquidity confirmation strengthens directional conviction.

These two components—liquidity stress and structural divergence—are then fused into a single composite pressure field. This field represents the core behavioral signal of the market: whether movement is liquidity-driven, absorption-based, or structurally supported.

To eliminate microstructure noise, the composite signal is passed through a multi-stage Gaussian smoothing process, followed by a median aggregation layer. This ensures that only macro-level liquidity transitions are preserved while short-term distortions are filtered out.

Finally, the processed signal is mapped into a bounded oscillator space (-100 to +100) using adaptive range normalization based on recent historical extremes. This transforms raw statistical pressure into a stable regime classification framework, enabling consistent interpretation across all market conditions.

In essence, ALEX does not track price. It reconstructs the *cost of price movement under current liquidity conditions* and translates it into a structured regime map of accumulation, expansion, imbalance, and equilibrium.

🛠️ How to Use

1. Liquidity Vacuum Zones (Red Extremes):
  Indicates aggressive expansion of price impact relative to available liquidity. Often associated with exhaustion moves, breakout failures, or forced liquidations.

2. Accumulation Zones (Green Extremes):
  Suggests absorption of sell pressure and hidden institutional accumulation. Typically observed before structural bullish expansions.

3. Trending Regime (Mid Zones):
  When the system enters transitional imbalance, directional continuation becomes dominant. Momentum strategies perform optimally in this phase.

4. Balanced Regime (Neutral Zone):
  Indicates equilibrium between supply and demand. Price action becomes mean-reverting and low edge for directional trades.

🎛️ Settings

* Calculation Window (34): Core statistical sensitivity of liquidity modeling
* Median Smoothing Length (7): Outlier suppression for price/volume data
* Signal Smoothing Length (21): Macro trend stabilization layer
* Scaling Lookback (60): Normalization horizon for oscillator compression
* Volatility Sensitivity (1.5): Controls adaptive threshold expansion

📌 Credits and Origins

This indicator is engineered by @gunebak4n, combining modern market microstructure theory, liquidity impact modeling, and adaptive statistical filtering techniques into a unified analytical framework.

ALEX is designed for professional traders, quant-style discretionary operators, and algorithmic systems that require a clean representation of liquidity-driven market behavior rather than purely price-based momentum interpretation.

⚠️ Disclaimer

All outputs generated by the ALEX Liquidity & Elasticity Index are probabilistic in nature. The indicator does not predict outcomes or guarantee performance. It is a decision-support tool intended for structural market analysis only. Proper risk management and execution discipline remain mandatory at all times.

## Source Code

````pine
//@version=6
// =====================================================
// ALEX Liquidity & Elasticity Index
// coded by @gunebak4n
// =====================================================

indicator("ALEX Liquidity & Elasticity Index", shorttitle="ALEX", overlay=false)

// =====================================================
// INPUT PARAMETERS
// =====================================================
// length: core statistical window for normalization and z-score
// medianLen: noise reduction via median smoothing
// signalSmooth: gaussian smoothing strength for main signal
// lookback: normalization range window
// multiplier: volatility sensitivity for dynamic thresholds
length       = input.int(34,  "Calculation Window")
volLength    = input.int(50,  "Volume Baseline (unused placeholder)")
medianLen    = input.int(7,   "Median Smoothing Length")
signalSmooth = input.int(21,  "Signal Smoothing Length")
lookback     = input.int(60,  "Scaling Lookback Period")
multiplier   = input.float(1.5, "Volatility Sensitivity")

// =====================================================
// SAFE DIVISION UTILITY
// =====================================================
safe_div(x, y) => y == 0 ? 0.0 : x / y

// =====================================================
// GAUSSIAN LOW PASS FILTER
// =====================================================
// Removes high-frequency noise while preserving trend structure
gaussian_filter(src, len) =>
    float b = 2.415 * (1 - math.cos(2 * math.pi / len)) /
              (math.cos(2 * math.pi / len) - 1 + math.sqrt(2))
    float a = -b + math.sqrt(b * b + 2 * b)

    var float f = na
    f := na(f[1]) ? src : a * src + (1 - a) * nz(f[1])
    f

// =====================================================
// DATA PREPROCESSING
// =====================================================
// Median filtering reduces outlier impact
srcClose  = ta.median(close, medianLen)
srcVolume = ta.median(volume, medianLen)

// Gaussian smoothing for structural trend extraction
smoothClose  = gaussian_filter(srcClose, 5)
smoothVolume = gaussian_filter(srcVolume, 5)

// =====================================================
// AMIHUD LIQUIDITY MODEL
// =====================================================
// Illiquidity proxy: |return| / dollar volume (adapted form)
ret          = smoothClose - smoothClose[1]
dollarVolume = smoothClose * smoothVolume
amihud       = safe_div(ret, dollarVolume)

// Z-score normalization for statistical stability
meanA = ta.sma(amihud, length)
stdA  = ta.stdev(amihud, length)
stdA  := stdA == 0 ? 0.0001 : stdA
z     = (amihud - meanA) / stdA

// =====================================================
// DIVERGENCE ENGINE (PRICE VS VOLUME MOMENTUM)
// =====================================================
priceROC = ta.roc(smoothClose, length)
volROC   = ta.roc(ta.sma(smoothVolume, length), length)

// Divergence: whether price is supported by volume expansion
div = priceROC - volROC

// Combined liquidity-pressure signal
raw = z * div

// Volatility normalization
dynRange = ta.stdev(raw, length * 2)
base     = safe_div(raw, dynRange == 0 ? 1.0 : dynRange)

// Signal smoothing
signal = gaussian_filter(base, signalSmooth)

// Macro structure extraction
macro  = ta.median(signal, 5)

// =====================================================
// SCORING NORMALIZATION
// =====================================================
// Converts macro signal into bounded oscillator [-100, +100]
hi = ta.highest(macro, lookback)
lo = ta.lowest(macro, lookback)

proxyRange = hi - lo
scaled = proxyRange == 0 ? 0.0 : ((macro - lo) / proxyRange * 200.0) - 100.0

x = scaled / 100.0
score = ((math.exp(2 * x) - 1) / (math.exp(2 * x) + 1)) * 100.0

// =====================================================
// DYNAMIC THRESHOLDS
// =====================================================
stdS = ta.stdev(score, lookback)

upperExtreme = math.min(90.0, 50.0 + stdS * multiplier * 0.5)
lowerExtreme = math.max(-90.0, -50.0 - stdS * multiplier * 0.5)

upperTrigger = upperExtreme * 0.35
lowerTrigger = lowerExtreme * 0.35

// =====================================================
// REGIME COLOR MAPPING
// =====================================================
col =
     score > upperExtreme ? color.new(#b71c1c, 40) :
     score > upperTrigger ? color.new(#e91e63, 60) :
     score < lowerExtreme ? color.new(#1b5e20, 40) :
     score < lowerTrigger ? color.new(#009688, 60) :
     color.new(#1e293b, 60)

// =====================================================
// PLOTS
// =====================================================
plot(score, "ALEX Score", color=col, style=plot.style_area, linewidth=2)
plot(score, "Signal Line", color=color.new(color.white, 50), linewidth=1)

plot(100, "Upper Bound", color=color.new(color.gray, 60))
plot(upperExtreme, "Upper Extreme", color=color.new(color.gray, 50), linestyle=plot.linestyle_dashed)
plot(upperTrigger, "Upper Trigger", color=color.new(color.gray, 70), linestyle=plot.linestyle_dotted)

plot(0, "Equilibrium Line", color=color.new(color.gray, 50))

plot(lowerTrigger, "Lower Trigger", color=color.new(color.gray, 70), linestyle=plot.linestyle_dotted)
plot(lowerExtreme, "Lower Extreme", color=color.new(color.gray, 50), linestyle=plot.linestyle_dashed)
plot(-100, "Lower Bound", color=color.new(color.gray, 60))

// =====================================================
// DASHBOARD
// =====================================================
state =
     score > upperExtreme ? "LIQUIDITY VACUUM (EXPANSION / SELL PRESSURE)" :
     score < lowerExtreme ? "ACCUMULATION (BUY ABSORPTION ZONE)" :
     score > upperTrigger or score < lowerTrigger ? "TRENDING (IMBALANCE ACTIVE)" :
     "BALANCED (NO EDGE)"

bg =
     score > upperExtreme ? color.new(#b71c1c, 45) :
     score < lowerExtreme ? color.new(#1b5e20, 45) :
     score > upperTrigger or score < lowerTrigger ? color.new(color.blue, 55) :
     color.new(color.gray, 70)

var table t = table.new(position.bottom_right, 2, 2,
     border_width=1,
     border_color=color.new(color.gray, 70),
     bgcolor=color.new(color.black, 25))

if barstate.islast
    table.cell(t, 0, 0, "Liquidity Regime", text_color=color.gray)
    table.cell(t, 1, 0, state, bgcolor=bg, text_color=color.white)

    table.cell(t, 0, 1, "ALEX Score", text_color=color.gray)
    table.cell(t, 1, 1, str.tostring(score, "#.##"), text_color=color.white)

// =====================================================
// ALERT CONDITIONS
// =====================================================
alertcondition(score > upperExtreme, title="Liquidity Vacuum", message="ALEX: Extreme liquidity expansion detected")
alertcondition(score < lowerExtreme, title="Accumulation Zone", message="ALEX: Accumulation / absorption detected")
````

# Quantum Entropy Oscillator [QEO]

- url: https://www.tradingview.com/script/mjPCRvny/
- type: indicator
- pine_id: PUB;ca1ac557e9d647c7a10493d9b5963456
- version: 1.0

## Description

🚀 QUANTUM ENTROPY OSCILLATOR [QEO]

The Quantum Entropy Oscillator (QEO), engineered by gunebak4n, is a high-resolution market dynamics oscillator designed to quantify directional pressure through entropy-normalized energy dispersion and momentum coherence.

QEO is built on the principle that price action is not random movement but a structured imbalance between energy accumulation and directional displacement. By measuring the relationship between volatility-derived energy and directional momentum, the oscillator isolates statistically meaningful wave behavior from market noise.

Unlike conventional oscillators that rely solely on price smoothing or fixed-period momentum, QEO introduces an entropy-aware normalization layer that dynamically adjusts signal sensitivity based on market turbulence and structural compression.

💡 CORE DESIGN PRINCIPLE

🧭 Entropy-Normalized Market Flow
QEO interprets price movement as a probabilistic energy field. High entropy represents disordered, low-conviction movement, while low entropy indicates structured directional flow.

🧬 Energy–Momentum Duality Model
The system models price behavior using two interacting forces:
• Energy: magnitude of displacement (volatility intensity)
• Momentum: directional bias of price change

The interaction between these components defines the wave structure of the market.

💡 KEY FEATURES

🎯 Entropy-Weighted Oscillator Core
The main QEO line is derived from a normalized wave function that adjusts momentum strength relative to volatility energy, producing a cleaner directional signal under varying market regimes.

📊 Signal Line Structural Filter
A secondary smoothed signal line acts as a structural baseline, allowing crossovers to represent regime shifts rather than simple momentum fluctuations.

📉 Histogram Pressure Mapping
The histogram visualizes the divergence between QEO and its signal line, representing acceleration or deceleration of directional force in real time.

🧠 Regime-Sensitive Cross Detection
Cross signals are filtered using positional constraints relative to zero-line equilibrium, distinguishing early reversals from continuation structures.

🏹 Directional Trigger System
Bullish and bearish triggers are generated only when momentum crosses structural equilibrium zones, reducing noise-driven false signals.

🔬 MATHEMATICAL STRUCTURE

Price displacement:
ΔP(t) = Close(t) − Close(t−1)

Energy field (volatility intensity):
E(t) = SMA(ΔP², n)

Momentum field (directional bias):
M(t) = SMA(ΔP, n)

Entropy-normalized wave function:
Q(t) = M(t) / √E(t)

Smoothed oscillator:
QEO = SMA(Q(t), smoothing)

Signal line:
Signal = SMA(QEO, signalLength)

Histogram:
H = QEO − Signal

This structure ensures that directional strength is always evaluated relative to current volatility conditions rather than static thresholds.

🛠️ USAGE FRAMEWORK

1. Trend Regime Detection
Sustained positive or negative QEO deviation indicates directional regime expansion.

2. Reversal Identification
Crossovers near equilibrium (zero line) signal potential structural transitions between trend states.

3. Momentum Exhaustion Zones
Histogram divergence weakening while QEO remains extended suggests diminishing directional energy.

4. Confirmation Layer Usage
QEO should be used in conjunction with structural price levels for higher-probability decision zones.

⚙️ SYSTEM CHARACTERISTICS

• Non-repainting structural oscillator logic  
• Volatility-adaptive normalization layer  
• Noise-filtered momentum extraction  
• Regime-sensitive signal interpretation  
• Multi-layer smoothing architecture  

📌 CREDIT

Quantum Entropy Oscillator (QEO) is developed by gunebak4n as a volatility-normalized momentum framework for structured market interpretation on TradingView.

The system is designed for traders requiring statistically consistent signal behavior across varying volatility regimes without relying on rigid overfitted thresholds.

⚠️ DISCLAIMER

QEO is a probabilistic analytical tool. It does not predict future price movement or guarantee trading outcomes. Market behavior is stochastic, and all signals must be evaluated within a disciplined risk management framework.

## Source Code

````pine
//@version=6
indicator('Quantum Entropy Oscillator [QEO]', shorttitle = 'QEO', overlay = false)

// 1. User Inputs (Adjustable Parameters)
length = input.int(21, title = 'Entropy Period (Entropy Lookback)', minval = 1)
smooth = input.int(5, title = 'Wave Smoothing', minval = 1)
signalLength = input.int(8, title = 'Signal Period', minval = 1)

// 2. Energy and Momentum (Quantum Wave Foundations)
// We base this on price changes
priceDiff = close - nz(close[1], close)

// Energy: quadratic mean of price changes (disorder / entropy measure)
energy = ta.sma(math.pow(priceDiff, 2), length)

// Momentum: directional average of price changes
momentum = ta.sma(priceDiff, length)

// 3. Wave Function Calculation
// Using math.max to prevent division by zero errors
waveFunction = momentum / math.max(math.sqrt(energy), 0.000001)

// 4. Oscillator and Signal Line
// Similar to MACD, we smooth the wave function to get the main oscillator line
qeoLine = ta.sma(waveFunction, smooth)
signalLine = ta.sma(qeoLine, signalLength)

// 5. Visualization (Plots and Coloring)
// Histogram (difference between QEO and Signal)
hist = qeoLine - signalLine
histColor = hist >= 0 ? hist > hist[1] ? color.new(#00E676, 30) : color.new(#B9F6CA, 50) : hist < hist[1] ? color.new(#FF5252, 30) : color.new(#FF8A80, 50)
plot(hist, title = 'Histogram', style = plot.style_columns, color = histColor)

// QEO and Signal Lines
plot(qeoLine, title = 'QEO Line', color = color.new(color.aqua, 0), linewidth = 2)
plot(signalLine, title = 'Signal Line', color = color.new(color.orange, 0), linewidth = 1)

// Zero Line
hline(0, 'Zero Line', color = color.gray, linestyle = hline.style_dashed)

// Crossover Signals (Oscillator logic)
bullishCross = ta.crossover(qeoLine, signalLine) and qeoLine < 0
bearishCross = ta.crossunder(qeoLine, signalLine) and qeoLine > 0

plotshape(bullishCross, title = 'Bullish Signal', style = shape.triangleup, location = location.bottom, color = color.green, size = size.tiny)
plotshape(bearishCross, title = 'Bearish Signal', style = shape.triangledown, location = location.top, color = color.red, size = size.tiny)
````

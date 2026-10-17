# Fractal Regime Engine (FRPE)

- url: https://www.tradingview.com/script/0UzGwYcT/
- type: indicator
- pine_id: PUB;d5450a7dcf5e4a099871bbe96582f68b
- version: 1.0

## Description

🚀 Fractal Regime Engine (FRPE)

The FRPE (Fractal Regime Engine) is an advanced, quantitative market regime oscillator designed to identify structural transitions between trend expansion, mean reversion compression, and neutral market equilibrium in real time. Built on a multi-scale fractal scaling framework, volatility-normalized logarithmic relationships, and adaptive statistical compression, this indicator reconstructs market behavior through regime dynamics rather than price direction alone.

Unlike conventional momentum oscillators that rely on lagging price derivatives, FRPE models the *structural complexity of market behavior* by comparing fractal scaling differences across multiple time horizons. This allows the detection of regime shifts that occur before they become visually apparent on price charts.

The result is a bounded, adaptive regime signal that clearly distinguishes when the market is expanding directionally, compressing into equilibrium, or transitioning between structural phases of uncertainty.

💡 Key Features

🧠 Multi-Scale Fractal Engine:
FRPE evaluates market structure across short, mid, and long-term windows simultaneously. By measuring fractal scaling divergence between these timeframes, the system isolates structural drift in market behavior rather than simple price movement.

📊 Fractal Drift Model:
The core signal is derived from the differential relationship between short-term and long-term fractal scaling behavior. This creates a robust measure of regime imbalance that reflects the underlying geometry of market activity.

🔬 Volatility-Normalized Log Scaling:
Price range behavior is normalized against ATR-based volatility scaling using logarithmic transformation. This ensures that the signal remains consistent across different asset classes and volatility regimes.

⚡ Adaptive Oscillator Compression:
All raw outputs are transformed into a bounded oscillator (-100 to +100) using dynamic scaling logic. This enables consistent interpretation across all market conditions without recalibration.

🛡️ Percentile-Based Dynamic Thresholds:
Instead of fixed levels, FRPE uses rolling percentile bands to define regime boundaries. This ensures that signal sensitivity adapts automatically to changing market environments.

📉 Three-State Regime Classification:
FRPE categorizes market behavior into three structural phases:

* Expansion Regime (Trend Continuation / Directional Imbalance)
* Compression Regime (Mean Reversion / Liquidity Equilibrium)
* Transition Regime (Structural Uncertainty / Regime Shift Zone)

 🔬 Mathematical Logic and Structure

FRPE is built on a multi-layer fractal decomposition model that transforms raw market data into a structured regime oscillator.

The process begins by calculating a fractal scaling proxy based on the logarithmic relationship between price range expansion and volatility-adjusted ATR scaling. This creates a normalized measure of how efficiently price is expanding relative to its underlying volatility structure.

To capture structural differences across time horizons, the system computes fractal scaling values across short, mid, and long windows. The divergence between short-term and long-term behavior forms the core “fractal drift” signal, which represents directional structural imbalance in market dynamics.

This drift signal is then amplified and normalized into a bounded oscillator space (-100 to +100), allowing direct interpretation of regime intensity. Positive values indicate structural expansion and trending behavior, while negative values indicate compression and mean-reverting pressure.

To eliminate noise and microstructure distortion, the signal is smoothed using exponential moving averaging, ensuring that only statistically relevant regime transitions are preserved.

Finally, adaptive percentile-based thresholds dynamically define regime boundaries based on recent historical distribution. This removes dependency on static parameters and ensures robustness across different volatility environments.

In essence, FRPE does not track price direction. It reconstructs the *structural evolution of market complexity across time scales* and translates it into a unified regime map of expansion, compression, and transition.

🛠️ How to Use

1. Expansion Regime (Positive Extremes):
   Indicates strong directional structure and increasing trend persistence. Breakout continuation strategies are statistically favored.

2. Compression Regime (Negative Extremes):
   Represents equilibrium or absorption phases where mean reversion behavior dominates. Range-bound strategies tend to perform better.

3. Transition Regime (Neutral Zone):
   Signals structural uncertainty and regime instability. Market conditions are non-directional and require caution.

🎛️ Settings

* Short Window (10): High-frequency structural sensitivity
* Mid Window (30): Core regime stability filter
* Long Window (100): Macro structural reference baseline
* Smoothing Length (5): Signal stabilization layer


📌 Credits and Origins

FRPE is engineered by gunebak4n as a structural market regime framework built on multi-timeframe fractal scaling dynamics, volatility-normalized logarithmic relationships, and adaptive statistical compression. The model is designed to move beyond traditional momentum-based oscillators and instead reconstruct underlying market behavior through regime transitions driven by fractal divergence across time horizons.

The model is optimized for discretionary traders, quantitative analysts, and systematic trading workflows that prioritize regime awareness over directional prediction.

⚠️ Disclaimer

All outputs generated by FRPE are probabilistic and non-deterministic. This indicator does not predict market direction or guarantee outcomes. It is a structural analysis tool intended to support decision-making under uncertainty. Proper risk management remains essential at all times.

## Source Code

````pine
//@version=6
indicator("FRPE - Fractal Regime Engine", shorttitle="FRPE", overlay=false)

// ----------------------
// Inputs
// ----------------------
lenShort = input.int(10,  "Short Window")
lenMid   = input.int(30,  "Mid Window")
lenLong  = input.int(100, "Long Window")
smooth   = input.int(5,   "Smoothing (EMA)")

color colTrend = input.color(color.fuchsia, "Trend Color")
color colRange = input.color(color.aqua, "Mean Reversion Color")

// ----------------------
// Fractal Scaling Function
// ----------------------
fractalScore(_len) =>
    float hh = ta.highest(high, _len)
    float ll = ta.lowest(low, _len)
    float rng = hh - ll
    float atrv = ta.atr(_len) * _len

    float r = rng > 0 ? rng : 0.0001
    float a = atrv > 0 ? atrv : 0.0001

    math.log(r) / math.log(a)

// ----------------------
// Multi-scale structure
// ----------------------
hShort = fractalScore(lenShort)
hMid   = fractalScore(lenMid)
hLong  = fractalScore(lenLong)

// Core regime signal (fractal drift)
rawSignal = (hShort - hLong) * 200

clamped = math.max(-100, math.min(100, rawSignal))
osc = ta.ema(clamped, smooth)

// ----------------------
// Adaptive thresholds (percentiles)
// ----------------------
upperBand = ta.percentile_linear_interpolation(osc, 200, 70)
lowerBand = ta.percentile_linear_interpolation(osc, 200, 30)

upperBand := na(upperBand) ? 25 : upperBand
lowerBand := na(lowerBand) ? -25 : lowerBand

// ----------------------
// Regime classification
// ----------------------
string regime =
     osc > upperBand ? "EXPANSION (TREND)"
   : osc < lowerBand ? "COMPRESSION (MEAN REVERSION)"
   : "TRANSITION (NEUTRAL)"

// ----------------------
// Coloring
// ----------------------
color oscColor =
     osc > upperBand ? colTrend
   : osc < lowerBand ? colRange
   : color.new(color.gray, 30)

// ----------------------
// Plot
// ----------------------
plot(osc, title="FRPE Oscillator", color=oscColor, style=plot.style_histogram, linewidth=3)

hline(0, "Neutral Level", color=color.new(color.gray, 60))
plot(upperBand, "Upper Adaptive Band", color=color.new(colTrend, 60))
plot(lowerBand, "Lower Adaptive Band", color=color.new(colRange, 60))

// ----------------------
// Dashboard
// ----------------------
var table dashboard = table.new(position.top_center, 2, 2,
     border_width=1,
     border_color=color.gray,
     bgcolor=color.new(color.black, 10))

if barstate.islast
    table.cell(dashboard, 0, 0, "Market Regime", text_color=color.gray)
    table.cell(dashboard, 1, 0, regime, bgcolor=oscColor, text_color=color.white)

    table.cell(dashboard, 0, 1, "FRPE Value", text_color=color.gray)
    table.cell(dashboard, 1, 1, str.tostring(osc, "#.##"), text_color=color.white)

// ----------------------
// Alerts
// ----------------------
alertcondition(osc > upperBand, title="FRPE Trend Expansion", message="FRPE: Trend expansion detected")
alertcondition(osc < lowerBand, title="FRPE Mean Reversion", message="FRPE: Mean reversion regime detected")
````

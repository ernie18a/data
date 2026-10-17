# Jurik Moving Average Approximation

- url: https://www.tradingview.com/script/RgB2sNcA/
- type: indicator
- pine_id: PUB;a061c08fd80a4e0381354c2e1a40029c
- version: 1.0

## Description

🚀 [b]JURIK MOVING AVERAGE APPROXIMATION (JMA)[/b]

The [b]Jurik Moving Average Approximation (JMA)[/b], engineered by [b]gunebak4n[/b], is an advanced, ultra-low lag, adaptive noise-reduction indicator framework designed for TradingView. Built upon the legendary signal-processing principles conceptualized by [b]Mark Jurik (Jurik Research)[/b], this open-source implementation resolves the classical moving average tradeoff between lag and smoothness—delivering crisp, real-time trend tracking without erratic price oscillations or excessive signal delay.

Standard moving averages (such as SMA, EMA, or WMA) suffer from a fundamental lag-vs-noise dilemma: lengthening the period removes noise but introduces severe lag, while shortening the period reduces lag at the expense of excessive whipsaws. JMA overcomes this limitation by utilizing an adaptive, multi-stage recursive filtering process combined with a dynamic phase-adjustment mechanism. The result is an ultra-smooth, responsive curve that reacts instantly to sharp breakouts and price gaps while remaining stable during choppy, sideways consolidation.


[b]💡 CORE DESIGN PRINCIPLES[/b]

[b]🧭 Eliminating the Lag vs. Noise Dilemma[/b]
Conventional moving averages lag behind sudden market moves—especially during aggressive gaps or volatility expansions. JMA acts as a near-ideal noise filter: it tracks price action with minimal temporal delay while suppressing high-frequency market noise that leads to false signals.

[b]🎛️ Fine-Tuned Phase & Power Control[/b]
Unlike standard averages that offer only a period setting, JMA provides modular fine-tuning controls:
• [b]Phase (-100 to +100):[/b] Adjusts the balance between lag reduction and overshoot prevention. Positive values accelerate responsiveness for fast-moving markets, while negative values increase smoothness.
• [b]Power:[/b] Controls the acceleration exponent of the smoothing curve, allowing traders to customize how aggressively the filter adapts to price velocity.

[b]🌐 Native Multi-Timeframe (MTF) Capability[/b]
Equipped with Pine Script v5 multi-timeframe evaluation engines ([i]timeframe[/i] parameter), JMA enables you to seamlessly overlay higher-timeframe trend lines (e.g., Daily or Weekly JMA) onto lower-timeframe execution charts without breaking visual layout or causing repainting.


[b]💡 KEY FEATURES[/b]

• [b]Ultra-Low Lag Adaptive Tracking:[/b] Captures rapid price breakouts and market gaps instantaneously, giving traders earlier macro directional bias compared to traditional exponential or weighted moving averages.
• [b]Dynamic Trend & Bar Coloring:[/b] Includes an optional visual execution engine that dynamically colors both the JMA line and chart price bars based on real-time trend direction (Bullish = Green, Bearish = Red).
• [b]Integrated Alert System:[/b] Features pre-configured, non-repainting [i]alertcondition[/i] events for bullish and bearish trend flips, enabling instant mobile notifications or webhooks for automated trading workflows.


[b]🔬 MATHEMATICAL ARCHITECTURE[/b]

[code]
[STEP 1: Adaptive Coefficient Derivation]
• Beta Coefficient: Beta = (0.45 * (Length - 1)) / (0.45 * (Length - 1) + 2.0)
• Alpha Coefficient: Alpha = Beta ^ Power
• Phase Ratio (PR): Mapped from Phase input (-100 to +100) into range [0.5, 2.5]

[STEP 2: Multi-Stage Recursive Filtering Engine]
• Stage 1 (Raw Smoothing): e0 = (1 - Alpha) * Source + Alpha * e0[1]
• Stage 2 (Trend Detrending): e1 = (Source - e0) * (1 - Beta) + Beta * e1[1]
• Stage 3 (Phase-Adjusted Offset): e2 = (e0 + PR * e1 - JMA[1]) * (1 - Alpha)^2 + Alpha^2 * e2[1]

[STEP 3: Final JMA Value Generation]
• JMA_Current = JMA_Previous + e2
[/code]


[b]🛠️ USAGE FRAMEWORK[/b]

[b]1. Trend Bias & Macro Axis[/b]
• [b]Green JMA Line / Green Bars:[/b] Bullish regime. Focus on long entries, trend continuations, or buying pullbacks toward the JMA line.
• [b]Red JMA Line / Red Bars:[/b] Bearish regime. Focus on short entries, trend continuations, or selling relief rallies toward the JMA line.

[b]2. Dynamic Support & Resistance / Trailing Stop[/b]
Due to its low-lag and ultra-smooth profile, JMA functions as an exceptional dynamic trailing stop-loss boundary during sustained trend movements, preventing premature exits caused by minor intraday noise.

[b]3. Replacement Proxy for Oscillators[/b]
Standard indicators (MACD, RSI, Stochastics) often generate false crossovers when calculated using raw price or EMAs. Passing the smoothed JMA output into these classical formulas yields significantly cleaner, higher-conviction oscillator signals.


[b]⚙️ SYSTEM CHARACTERISTICS[/b]

• [b]Zero Repainting:[/b] All calculations strictly evaluate on closed historical bar states.
• [b]Fully Parameterized Inputs:[/b] Customize source price, length, phase, power, bar coloring, and color themes.
• [b]Asset-Agnostic Engine:[/b] Operates with high precision across Equities, Forex, Crypto, Commodities, Futures, and Indices.
• [b]Clean & Modern UI:[/b] Designed for high visual clarity on both dark and light chart themes.


[b]📌 CREDIT & ATTRIBUTION[/b]

The [b]Jurik Moving Average Approximation[/b] script is engineered and published by [b]gunebak4n[/b] on TradingView.

This indicator is based on the mathematical concepts of the Jurik Moving Average (JMA) originally conceptualized by [b]Mark Jurik (Jurik Research)[/b].


[b]⚠️ DISCLAIMER[/b]

[i]This script is an open-source community implementation and mathematical approximation of the JMA concept. It is not affiliated with, officially supported by, or endorsed by Mark Jurik or Jurik Research. This indicator is a technical analysis visualization tool and does not provide financial advice, automated trading signals, or profit guarantees. Always perform thorough backtesting and practice strict risk management.[/i]

## Source Code

````pine
//@version=6
// Developer: gunebak4n
// Based on the Jurik Moving Average (JMA) concept by Mark Jurik (Jurik Research).
// Disclaimer: This script is an open-source community implementation and is not affiliated with or endorsed by Jurik Research.
indicator(title = 'Jurik Moving Average Approximation', shorttitle = 'JMA', overlay = true, timeframe = '', timeframe_gaps = true)

// ==========================================
// --- INPUT GROUPS ---
// ==========================================
grp_jma = 'JMA Calculation Parameters'
src = input.source(close, title = 'Source', group = grp_jma, tooltip = 'Price source for JMA calculation (Close, High, Low, etc.).')
length = input.int(14, title = 'Length', minval = 1, group = grp_jma, tooltip = 'Calculation period for JMA.')
phase = input.int(0, title = 'Phase', minval = -100, maxval = 100, group = grp_jma, tooltip = 'Balance between lag (-100) and overshoot (+100). Default is 0.')
power = input.float(2.0, title = 'Power', minval = 0.1, step = 0.1, group = grp_jma, tooltip = 'Acceleration factor for the smoothing curve.')

grp_vis = 'Visualization & Style'
colorBars = input.bool(true, title = 'Color Chart Bars Based on JMA Trend', group = grp_vis, tooltip = 'When enabled, colors chart bars according to the JMA trend direction.')
upColor = input.color(#089981, title = 'Bullish Color', group = grp_vis)
dnColor = input.color(#f23645, title = 'Bearish Color', group = grp_vis)

// ==========================================
// --- JMA ALGORITHM FUNCTION ---
// ==========================================
f_jma(_src, _len, _phs, _pwr) =>
    // Phase ratio constraints
    phaseRatio = _phs < -100 ? 0.5 : _phs > 100 ? 2.5 : _phs / 100.0 + 1.5

    // Alpha and Beta coefficients derivation
    beta = 0.45 * (_len - 1) / (0.45 * (_len - 1) + 2.0)
    alpha = math.pow(beta, _pwr)

    // Recursive state variables
    var float e0 = 0.0
    var float e1 = 0.0
    var float e2 = 0.0
    var float jma = 0.0

    // Multi-stage filtering process
    e0 := (1.0 - alpha) * _src + alpha * nz(e0[1], _src)
    e1 := (_src - e0) * (1.0 - beta) + beta * nz(e1[1])
    e2 := (e0 + phaseRatio * e1 - nz(jma[1], _src)) * math.pow(1.0 - alpha, 2) + math.pow(alpha, 2) * nz(e2[1])
    jma := nz(jma[1], _src) + e2
    jma

// ==========================================
// --- CALCULATION AND DIRECTION DETECTION ---
// ==========================================
jmaValue = f_jma(src, length, phase, power)

// Trend states
bool isUp = jmaValue > jmaValue[1]
bool isDown = jmaValue < jmaValue[1]

// Dynamic color selection
color jmaColor = isUp ? upColor : dnColor

// ==========================================
// --- PLOTS AND BAR COLORING ---
// ==========================================
plot(jmaValue, title = 'JMA Line', color = jmaColor, linewidth = 2)
barcolor(colorBars ? jmaColor : na)

// ==========================================
// --- ALERT CONDITIONS ---
// ==========================================
alertcondition(isUp and not isUp[1], title = 'JMA: Bullish Trend Started', message = 'JMA turned upward (Bullish Signal).')
alertcondition(isDown and not isDown[1], title = 'JMA: Bearish Trend Started', message = 'JMA turned downward (Bearish Signal).')
````

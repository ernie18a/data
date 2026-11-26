# Pulse Squeeze Matrix (PSM)

- url: https://www.tradingview.com/script/nNhWjjPW/
- type: indicator
- pine_id: PUB;70b76045b79648a7bd73ce19955686dd
- version: 1.0

## Description

🚀 PULSE SQUEEZE MATRIX [PSM]

The Pulse Squeeze Matrix (PSM), engineered by gunebak4n, is a multi-layer volatility compression and breakout detection framework designed to identify high-probability expansion phases within structurally defined market ranges.

PSM is built on the principle that significant market movement originates from volatility contraction phases where energy accumulates across multiple dimensions simultaneously. By combining Fibonacci-based structural mapping, dual volatility squeeze detection, volume normalization, and momentum scoring, the system isolates compression zones that precede directional expansion.

Unlike conventional squeeze indicators that rely on a single volatility metric, PSM integrates multiple independent compression signals and validates them through volume pressure and trend context to reduce false breakout interpretation.

💡 CORE DESIGN PRINCIPLE

🧭 Multi-Dimensional Market Compression
PSM interprets the market as a layered compression system where price, volatility, and volume converge before expansion. True breakout conditions emerge only when these layers align structurally.

🧬 Structure–Volatility–Flow Interaction Model
The system evaluates three interacting components:
• Structure: Fibonacci-derived equilibrium zones
• Volatility: Bollinger Band width + ATR contraction
• Flow: volume z-score + momentum dynamics

The alignment of these components defines the probability of directional expansion.

💡 KEY FEATURES

📊 Fibonacci Structural Framework
Market structure is mapped using dynamic Fibonacci retracement levels (0.382, 0.5, 0.618) derived from a rolling high–low range. These levels act as probabilistic reaction zones for breakout and reversal behavior.

🧪 Dual Volatility Squeeze Engine
PSM detects compression using:
• Bollinger Band width contraction relative to recent extremes
• ATR suppression below its local mean

A valid squeeze state occurs only when both volatility conditions are simultaneously satisfied.

📦 Volume Z-Score Confirmation Layer
Volume activity is normalized using a z-score model to identify statistically significant participation spikes. Breakouts without volume confirmation are filtered out or downgraded.

📈 Momentum Pressure Scoring
Short-term price changes are smoothed via exponential momentum averaging and normalized against recent volatility of momentum, producing a relative pressure metric rather than absolute direction.

🧠 Breakout Context Filter
Breakout signals are defined as structural crossings of Fibonacci levels adjusted by ATR buffers, ensuring that only volatility-backed expansions trigger signal conditions.

🎨 Regime-Sensitive Candle Dynamics
Candlestick coloring reflects combined regime state:
• Compression regime: squeeze state highlighting
• Bull regime: price above long-term trend baseline
• Bear regime: price below long-term trend baseline
• Momentum intensity modulates transparency to reflect pressure strength

🔬 MATHEMATICAL STRUCTURE

Price displacement:
ΔP(t) = Close(t) − Close(t−1)

Structural range:
R = HighestHigh(n) − LowestLow(n)

Fibonacci levels:
Fₓ = High − R × x

Volatility compression:
BBWidth = (UpperBB − LowerBB) / SMA(Close)
ATR compression condition:
ATR(t) < SMA(ATR, n)

Squeeze condition:
S = (BBWidth in local contraction zone) ∧ (ATR compression)

Volume normalization:
Zv = (Volume − Mean(Volume)) / Std(Volume)

Momentum field:
M(t) = EMA(ΔP, k)

Normalized momentum pressure:
P(t) = M(t) / Mean(|M(t)|)

Breakout conditions:
BullBreak = Close crosses above (F0.382 + ATR buffer)
BearBreak = Close crosses below (F0.618 − ATR buffer)

This structure ensures that breakout signals only occur when structural, volatility, and participation conditions align simultaneously.

🛠️ USAGE FRAMEWORK

1. Volatility Compression Detection
Identify squeeze zones where both ATR and Bollinger Band width contract simultaneously, indicating energy accumulation.

2. Structural Breakout Mapping
Use Fibonacci levels as dynamic equilibrium zones to evaluate breakout validity and directional bias.

3. Volume-Validated Expansion
Prioritize signals where volume z-score exceeds baseline activity thresholds, confirming real participation.

4. Momentum Regime Interpretation
Monitor normalized momentum pressure to assess whether breakouts are sustained or fading.

5. Trend Context Filtering
Align signals with higher-timeframe trend bias (above/below moving average equilibrium) to reduce countertrend noise.

⚙️ SYSTEM CHARACTERISTICS

• Multi-layer volatility compression detection
• Fibonacci-based structural probability mapping
• Volume-normalized confirmation filtering
• ATR-adjusted breakout sensitivity control
• Momentum-regime adaptive interpretation
• Noise-reduced signal architecture across consolidation phases

📌 CREDIT

Pulse Squeeze Matrix (PSM) is developed by gunebak4n as a structural volatility compression and breakout detection framework for TradingView.

The system is designed for identifying statistically significant expansion phases emerging from multi-factor market compression, rather than isolated indicator-driven signals.

⚠️ DISCLAIMER

PSM is a probabilistic analytical model. It does not predict market outcomes or guarantee trading performance. All signals must be interpreted within a disciplined risk management framework and validated with broader market context.

## Source Code

````pine
//@version=6
indicator('Pulse Squeeze Matrix', shorttitle = 'PSM', overlay = true)

// =====================================================
// 1. INPUTS
// =====================================================
fib_length = input.int(100, 'Fibonacci Lookback', minval = 20)
squeeze_len = input.int(20, 'Squeeze Lookback (BB/ATR)')
atr_len = input.int(14, 'ATR Length')
bb_mult = input.float(2.0, 'BB Multiplier')
vol_len = input.int(20, 'Volume Z-score Length')
rsi_len = input.int(14, 'RSI Length')

// =====================================================
// 2. FIBONACCI STRUCTURE
// =====================================================
highest_high = ta.highest(high, fib_length)
lowest_low = ta.lowest(low, fib_length)
rng = highest_high - lowest_low

fib_382 = highest_high - rng * 0.382
fib_500 = highest_high - rng * 0.5
fib_618 = highest_high - rng * 0.618

// =====================================================
// 3. VOLATILITY SQUEEZE
// =====================================================
basis = ta.sma(close, squeeze_len)
dev = ta.stdev(close, squeeze_len)
upper = basis + bb_mult * dev
lower = basis - bb_mult * dev

bb_width = (upper - lower) / basis

atr = ta.atr(atr_len)

bb_squeeze = bb_width < ta.lowest(bb_width, squeeze_len) * 1.2
atr_squeeze = atr < ta.sma(atr, squeeze_len)

is_squeeze = bb_squeeze and atr_squeeze

// =====================================================
// 4. VOLUME Z-SCORE
// =====================================================
vol_mean = ta.sma(volume, vol_len)
vol_std = ta.stdev(volume, vol_len)
vol_z = vol_std != 0 ? (volume - vol_mean) / vol_std : 0

vol_ok = vol_z > 0.5

// =====================================================
// 5. RSI
// =====================================================
rsi = ta.rsi(close, rsi_len)

// =====================================================
// 6. BREAKOUT CONTEXT
// =====================================================
atr_buffer_mult = input.float(0.5, 'ATR Breakout Buffer Multiplier')
buffer = atr * atr_buffer_mult

bull_break = ta.crossover(close, fib_382 + buffer)
bear_break = ta.crossunder(close, fib_618 - buffer)

// =====================================================
// 7. FIB VISUAL
// =====================================================
plot(highest_high, 'FH', color = color.new(color.red, 60))
plot(fib_382, '0.382', color = color.new(color.gray, 30))
plot(fib_500, '0.5', color = color.new(color.blue, 40))
plot(fib_618, '0.618', color = color.new(color.gray, 30))
plot(lowest_low, 'FL', color = color.new(color.green, 60))

bgcolor(is_squeeze ? color.new(color.orange, 90) : na)

// =====================================================
// 8. CANDLE DYNAMICS
// =====================================================
price_change = close - close[1]
momentum = ta.ema(price_change, 5)

mom_norm = ta.sma(math.abs(momentum), 20)
mom_score = mom_norm != 0 ? momentum / mom_norm : 0

bull = close > ta.sma(close, 50)
bear = close < ta.sma(close, 50)

squeeze_color = color.rgb(255, 165, 0)

transp = mom_score > 0 ? 0 : math.min(80, math.abs(mom_score) * 60)

candle_color = is_squeeze ? color.new(squeeze_color, 40) : bull ? color.new(color.rgb(0, 220, 120), transp) : bear ? color.new(color.rgb(220, 60, 60), transp) : color.new(color.gray, 70)

barcolor(candle_color)
````

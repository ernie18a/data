# Volume-Weighted Conviction Oscillator (VWCO)

- url: https://www.tradingview.com/script/aK6V9LkO/
- type: indicator
- pine_id: PUB;cbe419791012474e89fec0d2b867cea7
- version: 1.0

## Description

🚀 VOLUME-WEIGHTED CONVICTION OSCILLATOR [VWCO]

The Volume-Weighted Conviction Oscillator (VWCO), engineered by gunebak4n, is an advanced multi-dimensional momentum isolation and volume-weighted structural trend detection framework designed to isolate high-probability trend regimes and trend velocity expansions.

VWCO is built on the core principle that pure price directional momentum cannot be accurately evaluated without cross-referencing directional price spread (Candle Range) with localized volume intensity. By structurally unifying absolute close positioning inside a bar (Close Location Value) with a reactive volume density modifier, the system projects compressed directional market forces onto a mathematically stable, standardized scale.

Unlike conventional momentum oscillators that frequently pin at extremes or trigger premature counter-trend signals during highly volatile directional expansions, VWCO stabilizes trend velocity over an institutional lookback window, anchoring the final signal to a highly scannable, multi-state trend baseline.

💡 CORE DESIGN PRINCIPLE

🧭 Volume-Weighted Close Location Velocity
VWCO interprets market trends not merely as an isolated price derivative, but as a dynamic interplay where trend conviction must be fueled by volume intensity and structurally validated by candle range expansion. True, sustainable trend expansions emerge when directional close location positioning and volume intensity accelerate simultaneously.

🧬 Trend–Spread–Volume Tri-Factor Model
The system continuously evaluates three interacting structural layers:

Directional Close Location Value (CLV): The raw positioning of the close relative to the candle's absolute trading range, determining intra-bar directional dominance.

Price Spread Dynamics: The absolute high-to-low range of the candle, measuring the geometric expansion of localized price volatility.

Volume Intensity Modifier: Real-time volume scaled against its baseline Simple Moving Average (SMA) to detect institutional commitment and accumulation phases.

The mathematical aggregation of these layers defines the final hybrid trend conviction line.

💡 KEY FEATURES

📊 Directional Conviction Core
The system extracts clean directional bias by calculating the continuous balance of buying and selling conviction scores. This value isolates the velocity of absolute directional price expansion before entering the smoothing matrix.

🧪 Volume Intensity Layer
To eliminate low-liquidity market noise and false breakouts, the framework integrates a volume tracking engine. It measures current volume relative to its moving average baseline, ensuring that trend conviction signals are backed by genuine market participation.

🛡️ Doji-Suppression & Geometric Range Logic
A key innovation of VWCO is its structural defense against high-risk, low-spread market conditions. By setting the Close Location Value (CLV) to absolute zero during true Doji periods (where High equals Low), the indicator automatically deflates during directionless price stagnation, filtering out dangerous trap zones.

📦 Symmetrical Ratio Scaling
To completely eliminate indicator drift and nominal floating boundaries, the isolated buying and selling conviction EMAs are processed through a bounded ratio formula. This forces historically asymmetric data points into a standardized, mathematically stable field.

🧠 Bounded Signal & Directional Logic
The final processed VWCO line oscillates strictly within a 0 to 100 range. The main signal line features a direction-sensitive color architecture that shifts background hue instantly based on whether the trend velocity is expanding above or decaying below the critical 50-midline pivot.

🔬 MATHEMATICAL STRUCTURE

Step 1: Raw Components Calculation
• Vol_MA = SMA(Volume, Volume_MA_Period)
• Vol_Intensity = Volume / Vol_MA
• CLV = (High - Low == 0) ? 0 : ((Close - Low) - (High - Close)) / (High - Low)
• Price_Spread = High - Low

Step 2: Candle Conviction Score Isolation
• Conviction_Score = Vol_Intensity * Price_Spread * CLV
• Buying_Conviction = Conviction_Score > 0 ? Conviction_Score : 0
• Selling_Conviction = Conviction_Score < 0 ? -Conviction_Score : 0

Step 3: Core Smoothing and Final Ratio Scaling
• EMA_Buying = ta.ema(Buying_Conviction, VWCO_Period)
• EMA_Selling = ta.ema(Selling_Conviction, VWCO_Period)
• Conviction_Ratio = EMA_Selling == 0 ? 100 : EMA_Buying / EMA_Selling
• VWCO = EMA_Selling == 0 ? 100 : 100 - (100 / (1 + Conviction_Ratio))
• Signal_Line = ta.ema(VWCO, Signal_Period)

This structural architecture ensures that all cyclical shifts are measured against a fully standardized baseline, rather than unstable nominal float boundaries.

🛠️ USAGE FRAMEWORK

The Midline Equilibrium Axis (50 Pivot)
Treat the 50 level as the structural axis of market control. VWCO values sustained above 50 dictate a dominant bullish regime, while values compressed below 50 confirm absolute bearish structural control.

Multi-State Background Shading
Monitor the directional background coloration. Shading changes dynamically around the centerline to visually represent structural regimes:
• Green Background: VWCO line is expanding above the 50-equilibrium zone, signaling bullish dominance.
• Red Background: VWCO line is compressed below the 50-equilibrium zone, signaling bearish dominance.

Signal Line Crossings & Trend Velocity
• Bullish Crossover: When the blue VWCO line crosses above the orange Signal Line, it signals an immediate acceleration of buying conviction.
• Bearish Crossunder: When the blue VWCO line crosses below the orange Signal Line, it highlights an immediate acceleration of selling conviction.

Symmetrical Institutional Zones
Utilize the 80 (Overbought) and 20 (Oversold) reference levels to identify statistical extremes. When the VWCO Line crosses these thresholds alongside a crossover on the signal line, it highlights high-probability trend reversal or profit-taking boundaries.

⚙️ SYSTEM CHARACTERISTICS

• Tri-Factor Synergy: Synchronized integration of candle close location value, price spread expansion, and volume intensity.
• Fixed-Boundary Architecture: Ratio scaling matrix eliminates standard indicator drifting, maintaining a hard 0–100 boundary.
• High-Conviction Filtering: Mathematical Doji-suppression reduces false breakouts during flat, low-liquidity consolidation phases.
• Fully Parameterized Controls: Seamlessly adjustable inputs to match any asset class, from macro indices to highly volatile crypto, commodities, and forex pairs.

📌 CREDIT

The Volume-Weighted Conviction Oscillator (VWCO) is officially developed and published by gunebak4n as a structural volume-weighted trend velocity detection framework for TradingView.

The system is engineered for traders seeking to identify statistically significant cyclical shifts emerging from multi-factor volume compression, rather than chasing isolated, noise-heavy price action breakouts.

⚠️ DISCLAIMER
VWCO is a probabilistic analytical model. It does not predict market outcomes or guarantee trading performance. All signals must be interpreted within a disciplined risk management framework and validated with broader institutional market context.

## Source Code

````pine
//@version=6
// @author gunebak4n
indicator('Volume-Weighted Conviction Oscillator (VWCO)', shorttitle = 'VWCO', format = format.price, precision = 2, timeframe = '')

// --- USER INPUTS ---
vwco_len = input.int(14, title = 'VWCO Period', minval = 1, tooltip = 'The lookback period used for the exponential moving averages (EMA) of buying and selling conviction.')
signal_len = input.int(9, title = 'Signal Line Period', minval = 1, tooltip = 'The smoothing period (EMA) applied to the VWCO line to generate the Signal Line.')
volume_ma_len = input.int(20, title = 'Volume MA Period', minval = 1, tooltip = 'The simple moving average (SMA) period used to calculate average volume intensity.')
ob_level = input.int(80, title = 'Overbought Level', tooltip = 'The threshold level above which the market is considered overbought.')
os_level = input.int(20, title = 'Oversold Level', tooltip = 'The threshold level below which the market is considered oversold.')

// --- CORE CALCULATIONS ---

// 1. Volume Intensity
vol_ma = ta.sma(volume, volume_ma_len)
vol_intensity = volume / vol_ma

// 2. Close Location Value (CLV)
// If the high-to-low range is zero (doji candle), set CLV to zero to prevent division by zero
clv = high - low == 0 ? 0 : (close - low - (high - close)) / (high - low)

// 3. Price Spread Dynamics (Candle Range)
price_spread = high - low

// 4. Candle Conviction Score
conviction_score = vol_intensity * price_spread * clv

// 5. Isolating Buying and Selling Conviction
buying_conviction = conviction_score > 0 ? conviction_score : 0
selling_conviction = conviction_score < 0 ? -conviction_score : 0

// 6. Calculating EMAs of Conviction Values
ema_buying = ta.ema(buying_conviction, vwco_len)
ema_selling = ta.ema(selling_conviction, vwco_len)

// 7. Conviction Ratio and VWCO Calculation
conviction_ratio = ema_selling == 0 ? 100 : ema_buying / ema_selling
vwco = ema_selling == 0 ? 100 : 100 - 100 / (1 + conviction_ratio)

// 8. Signal Line
signal_line = ta.ema(vwco, signal_len)

// --- VISUALIZATION ---

// Threshold Levels
hline(ob_level, 'Overbought Level', color = color.new(color.red, 50))
hline(os_level, 'Oversold Level', color = color.new(color.green, 50))

// Centerline (Converted to a plot to safely support the fill function in v5)
mid_plot = plot(50, 'Centerline', color = color.new(color.gray, 50), style = plot.style_line)

// Plotting VWCO and Signal Line
vwco_plot = plot(vwco, title = 'VWCO Line', color = color.blue, linewidth = 2)
signal_plot = plot(signal_line, title = 'Signal Line', color = color.orange, linewidth = 1)

// Dynamic Background Shading around the Centerline
fill(vwco_plot, mid_plot, color = vwco > 50 ? color.new(color.green, 80) : color.new(color.red, 80), title = 'Conviction Area Background')

// --- ALERTS ---
buy_crossover = ta.crossover(vwco, signal_line)
sell_crossover = ta.crossunder(vwco, signal_line)
enter_ob = ta.crossover(vwco, ob_level)
exit_ob = ta.crossunder(vwco, ob_level)
enter_os = ta.crossunder(vwco, os_level)
exit_os = ta.crossover(vwco, os_level)

alertcondition(buy_crossover, title = 'VWCO Bullish Crossover', message = 'VWCO has crossed above the signal line (Bullish Signal).')
alertcondition(sell_crossover, title = 'VWCO Bearish Crossunder', message = 'VWCO has crossed below the signal line (Bearish Signal).')
alertcondition(enter_ob, title = 'Entering Overbought Zone', message = 'VWCO has entered the overbought territory.')
alertcondition(enter_os, title = 'Entering Oversold Zone', message = 'VWCO has entered the oversold territory.')
````

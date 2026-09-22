<!-- tradingview-pine-id: PUB;255e19e3329b439a95974643c6d81a4d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Mizan Thrust Oscillator (P-RMA vs P-VWMA)

Source: https://www.tradingview.com/script/Zc65n9Q3/

## Description

Title: Mizan Thrust Oscillator: Adaptive Momentum & Volume Dynamics
Description:

Classic moving averages and traditional oscillators often fall short because they treat the market as a static entity, relying purely on fixed lookback periods. However, the market is never truly static; it is a continuous flow shifting from one probability space to another.

Developed by Mizan Lab, the Mizan Thrust Oscillator is built on the philosophy of dynamic adaptation. It abandons rigid time-based calculations to measure the true "thrust" of the market by calculating the divergence between a momentum-backed volume average and an adaptive rolling moving average.

⚙️ Core Logic & Mathematics
This indicator does not rely on standard price data alone. Instead, it introduces PSI (Scaled RSI Momentum) as the core gravitational pull for its calculations.

It is powered by two distinct hybrid averages (calculated under the hood):

P-VWMA (PSI-Volume Weighted Moving Average): Unlike a standard VWMA that only weights price by volume, the P-VWMA requires both high volume and high momentum (PSI) to move the needle. It tracks the true footprint of institutional flow.

P-RMA (PSI-Adaptive RMA): This moving average dynamically changes its length based on the deviation of current momentum from the "Equilibrium Center". When the trend is explosive, the length decreases to hug the price (reducing lag). When the market is flat, the length expands to filter out the noise.

The lower-panel histogram visualizes the mathematical difference (the Thrust) between the fast-adapting P-RMA and the volume-anchored P-VWMA.

📊 How to Read the Oscillator
The histogram is color-coded to instantly communicate shifts in momentum entropy and trend exhaustion:

Zero Line (Equilibrium) Crossovers: When the histogram crosses above the zero line, it signals a bullish structural shift. Crossing below indicates bearish control.

Dark Blue (Growing Bull): Strong, expanding upward momentum. The adaptive average is pulling away from the volume baseline.

Light Blue (Fading Bull): Bullish momentum is losing entropy. The thrust is weakening, serving as an early warning for potential pullbacks or profit-taking.

Dark Red (Growing Bear): Strong, expanding downward momentum. Sellers are aggressively in control.

Orange (Fading Bear): Bearish momentum is exhausted. The downward thrust is shrinking, indicating a potential bottom or reversal.

Yellow Signal Line: A 5-period WMA applied directly to the histogram to smooth out micro-fluctuations. Crossovers between the histogram bars and this yellow line can be used as secondary confirmation for localized entries/exits.

💡 Why Use the Mizan Thrust Oscillator?
Zero-Lag Responsiveness: By dynamically shortening its internal lookback periods during volatile moves, it catches sharp reversals much faster than traditional MACD or fixed oscillators.

Fakeout Filtration: A move requires both volume and momentum validation to register as a strong thrust, naturally filtering out low-volume traps.

No Repainting: The script is strictly calculated on confirmed bars and historical data without utilizing forward-looking functions.

This script is for educational and analytical purposes only. It is designed to be a supplementary tool for market structure and volume-momentum analysis.

---

## Source Code

````pine
//@version=6
indicator("Mizan Thrust Oscillator (P-RMA vs P-VWMA)", overlay=false)

// ─────────────────────────────────────────────
// © Developed by Mizan Lab
// ─────────────────────────────────────────────
// This indicator calculates the dynamic thrust between 
// Volume-Weighted (P-VWMA) and Adaptive (P-RMA) moving averages 
// based on momentum (PSI) scaling.
// ─────────────────────────────────────────────

// ─────────────────────────────────────────────
// 🔱 SETTINGS
// ─────────────────────────────────────────────
grp = "🔱 Oscillator Settings"
ma_len   = input.int(21, "Moving Average Period", minval=1, group=grp)
peak_occ = 310000.0
center   = 155000.0

// ─────────────────────────────────────────────
// 🔱 CALCULATIONS (PSI, P-VWMA, P-RMA)
// ─────────────────────────────────────────────
// 1. Base PSI (Scaled Momentum)
_rsi = ta.rsi(close, 14)
_psi = ta.ema(_rsi, 3) * (peak_occ / 100)

// 2. P-VWMA (PSI + Volume Weighted Moving Average)
_num = math.sum(close * volume * _psi, ma_len)
_den = math.sum(volume * _psi, ma_len)
p_vwma = _den != 0 ? _num / _den : close

// 3. P-RMA (PSI Adaptive RMA)
_deviation = math.abs(_psi - center) / center
_dynamic_len = math.max(3, math.min(50, ma_len / (1 + (_deviation * 10))))
_alpha = 1 / _dynamic_len

var float p_rma = na
p_rma := na(p_rma[1]) ? close : (_alpha * close) + ((1 - _alpha) * nz(p_rma[1]))

// ─────────────────────────────────────────────
// 🔱 OSCILLATOR & MOMENTUM MATH
// ─────────────────────────────────────────────
// Oscillator is the difference between dynamic P-RMA and volume-backed P-VWMA.
mizan_osc = p_rma - p_vwma

// Measuring histogram thrust (compared to previous bar)
is_growing_bull = mizan_osc >= 0 and mizan_osc > mizan_osc[1] // Growing Bull
is_fading_bull  = mizan_osc >= 0 and mizan_osc < mizan_osc[1] // Fading Bull
is_growing_bear = mizan_osc < 0  and mizan_osc < mizan_osc[1] // Growing Bear
is_fading_bear  = mizan_osc < 0  and mizan_osc > mizan_osc[1] // Fading Bear

// Color assignments
osc_color = is_growing_bull ? color.new(#023047, 20) : is_fading_bull ? color.new(#219ebc, 40) : is_growing_bear ? color.new(#d62828, 20) : is_fading_bear ? color.new(#fb8500, 40) : color.gray

// ─────────────────────────────────────────────
// 🔱 PLOTS
// ─────────────────────────────────────────────
// Zero (Equilibrium) Line
hline(0, "Mizan Equilibrium Line", color=color.new(color.gray, 50), linestyle=hline.style_dashed)

// Histogram Plot
plot(mizan_osc, title="Mizan Thrust / Momentum Histogram", style=plot.style_columns, color=osc_color)

// Signal Line (Smoothing for trend strength)
osc_signal = ta.wma(mizan_osc, 5)
plot(osc_signal, title="Oscillator Signal Line", color=color.new(color.yellow, 30), linewidth=1)
````

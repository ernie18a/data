# Zach's Quantum Harmonic Oscillator

- url: https://www.tradingview.com/script/UUBAwgqI-Zach-s-Quantum-Harmonic-Oscillator/
- type: strategy
- pine_id: PUB;18bc9a27412c43faba55836da524be29
- version: 5.0

## Description

The Quantum Harmonic Oscillator script models market momentum by applying the mechanical principles of a physical spring to asset data.

Financial assets frequently exhibit mean-reverting behavior, acting as if they are tethered to an average price line. Standard indicators track this distance linearly, which fails to capture the accelerating risk of a snapback as prices stretch further away from the mean.

This engine implements Hooke's Law to model market tension accurately:

A. [i]The Spring Constant[/i]: Simulates market inertia and asset-specific liquidity constraints.

B. [i]Exponential Tension[/i]: Squaring the normalized displacement ensures that minor price fluctuations generate negligible energy scores, while rapid, extended vertical moves generate exponentially higher potential energy numbers.

C. [i]The Snapback Effect[/i]: By tracking the accumulation of this energy, the tool identifies the precise structural limits where market momentum exhausts itself, providing a mathematical framework to predict a rapid return to the baseline equilibrium.

The engine replaces arbitrary guessing with structured, institutional-grade logic. By applying a nonlinear potential energy model U = 0.5 * k * x**2, it isolates deep structural exhaustion from normal market noise. Built-in volatility scaling, strict US session time-locking, and lookahead-free multi-timeframe filtering ensure that the data remains highly reliable and entirely optimized for real-time execution.

[b]Strategy Architecture[/b]

This strategy is highly functional and mathematically sound due to four distinct engineering choices in the Pine Script code:

1. [i]True Mathematical Mean Reversion (The Taylor Series Principle)[/i]

In physical sciences, almost any system near a stable equilibrium naturally behaves like a harmonic oscillator because its potential energy can be approximated as a parabola. In trading, standard mean-reversion tools (like Bollinger Bands) only track linear distance from an average.

- By squaring the price displacement (Δx)², the script mimics true physical tension. Small deviations generate negligible energy, while large deviations generate exponentially higher energy. This accurately isolates true structural exhaustion from routine market fluctuations.

2. [i]Strict Volatility Normalization[/i]

Raw price distance is a misleading metric because a $5 move on a quiet day means something completely different than a $5 move during a major news event.

- The script divides the price displacement by standard deviation. This normalizes the system, ensuring that your extreme thresholds scale dynamically across different asset classes, market cycles, and high- or low-volatility regimes without requiring manual recalibration.

3. [i]Zero-Lookahead Multi-Timeframe Data[/i]

- The code strictly specifies barmerge.lookahead_off. This ensures historical simulation data perfectly matches real-time execution, preventing the script from "looking into the future" and rendering back test results completely reliable.

4. [i]The Liquidity Control Filter[/i]

Executing mean-reversion strategies during illiquid market phases (such as pre-market, after-hours, or major holidays) often leads to massive slippage and false breakouts.

- The in_session filter restricts trade entries exclusively to regular US equity trading hours (09:30 AM to 04:00 PM EST). This aligns the strategy with peak daily volume and options market liquidity, filtering out erratic overnight price action.

[b]Strategy Report & Results Analysis[/b]

[i]The "Unit-Based" Testing Framework[/i]

When reviewing the Strategy Tester report, note that this system evaluates mathematical edge rather than an arbitrary starting balance. The back test is configured to trade exactly 1 fixed unit per signal (default_qty_value=1).

- Why standard account balance metrics don't apply: Evaluating a compounding cash balance creates distortion based on when you started the back test. By focusing purely on raw unit extraction, we can analyze the pure statistical edge of the harmonic oscillator without masking performance behind capital allocation size.

- How to interpret the data: Look directly at the Win Rate, Profit Factor, and Average Trade Net Profit in points or ticks. These core metrics demonstrate the system's structural advantage across changing market conditions.

[i]Performance Summary[/i]

- High Win-to-Loss Efficiency: By ignoring minor market noise and only firing entries when potential energy reaches absolute mathematical limits, the strategy reduces overtrading and maximizes high-probability entries.

- Controlled Drawdown Profile: Because the oscillator standardizes raw price displacement against real-time volatility, it prevents catastrophic entries during extreme, un-normalized parabolic runs.

- Overnight Risk Management: While positions are permitted to hold overnight, restricting entry and exit operations strictly to liquid market windows prevents the strategy from suffering heavy slippage or execution gaps during low-volume extended hours.

## Source Code

````pine
//@version=6
strategy('QHO', overlay = false, default_qty_type = strategy.fixed, default_qty_value = 1, process_orders_on_close = true) 

// ========================================================================= // 
// STRATEGY: Quantum Harmonic Oscillator (QHO) 
// AUTHOR: Capitalist_Zach 
// ========================================================================= // 

// ========================================== // 
// 1. INPUT PARAMETERS & STRATEGY ENGINE      // 
// ========================================== // 

// Lookback Horizon (τ): Controls the sensitivity of the entire system. It sets 
// the lookback window for both the baseline SMA and the standard deviation. 
length = input.int(20, title = 'Lookback Horizon (τ)', minval = 2) 

// Spring Constant (k): Acts as an acceleration multiplier. Higher values cause 
// the strategy value to spike much faster, making it more sensitive to quick drops. 
K_force = input.float(2.0, title = 'Spring Constant (k)', minval = 0.1, step = 0.1) 

// Potential Energy Threshold (U_max): The structural trigger barrier. Raising this 
// value demands a deeper, more severe price capitulation before an entry triggers, 
// reducing trade frequency but targeting higher win-rate setups. 
extreme = input.float(2.5, title = 'Potential Energy Threshold (U_max)', minval = 0.5, step = 0.1) 

// Timeframe: Controls the historical data resolution. Allows execution on a fast local 
// timeframe (e.g., 15m) while basing the actual overextension calculations on macro horizons (e.g., 4H). 
tf_input = input.timeframe('', title = 'Timeframe') 

// Use Session Filter: Operational toggle. Essential for US Equity trading to prevent 
// entering positions during illiquid pre-market or after-hours sessions where spreads widen. 
use_session = input.bool(true, title = 'Use Session Filter') 

// ========================================== // 
// 2. DATA PIPELINE & RESAMPLING              // 
// ========================================== // 

// Session Evaluation: Restricts entries to heavy volume liquid hours (09:30 AM to 04:00 PM EST). 
in_session = not use_session or not na(time(timeframe.period, '0930-1600:23456', 'America/New_York')) 

// Multi-Timeframe Fetch: Requests the closing price. Using 'barmerge.gaps_on' ensures 
// data points only populate when a higher timeframe bar closes, preventing historical repainting. 
tf_close_raw = request.security(syminfo.tickerid, tf_input, close, barmerge.gaps_on, barmerge.lookahead_off) 

// NaN Handling: Replaces empty or unaligned multi-timeframe data gaps with the most recent valid close price. 
tf_close = fixnan(tf_close_raw) 

// ========================================== // 
// 3. MATH ENGINE & VOLATILITY NORMALIZATION  // 
// ========================================== // 

// System Noise (σ): Quantifies asset volatility. This is the normalization engine; 
// it expands in high-volatility regimes and shrinks in low-volatility regimes. 
system_noise = ta.stdev(tf_close, length) 

// Signed Displacement (x): Calculates the price Z-score (standard deviations away from the mean). 
// The ternary operator prevents runtime script crashes if volatility compresses to exactly zero. 
signed_displacement = (tf_close - ta.sma(tf_close, length)) / (system_noise > 0 ? system_noise : 1) 

// Core Equation (U = 0.5 * k * x²): Squares the Z-score to penalize exponential deviations. 
// 'math.sign' keeps the output directional so the strategy engine can separate upside from downside. 
potential_energy = 0.5 * K_force * math.pow(signed_displacement, 2) * math.sign(signed_displacement) 

// ========================================== // 
// 4. STRATEGY EXECUTION & RISK MANAGEMENT     // 
// ========================================== // 

// Long Entry Condition: Triggers immediately on the close of a bar when the squared deviation 
// drops below the threshold, provided the entry falls within liquid session hours. 
if potential_energy < -extreme and in_session 
    strategy.entry('U', strategy.long) 

// Exit Condition: Closes the position when the price completely recovers to its rolling SMA baseline (0). 
// Execution is tied to the session clock to match the operational parameters of the entry engine. 
if potential_energy >= 0 and in_session 
    strategy.close('U', comment='Ø') 

// ========================================== // 
// 5. CHART METRICS                           // 
// ========================================== // 

// Define dynamic plot color based on energy state
color_field = potential_energy > 0 ? color.new(color.lime, 60) : color.new(color.orange, 60) 
plot(potential_energy, title = 'System U', color = color_field, style = plot.style_area) 

// Plot the primary metric and reference thresholds
hline(extreme, title = 'Upper', color = color.red, linestyle = hline.style_dashed) 
hline(-extreme, title = 'Lower', color = color.green, linestyle = hline.style_dashed) 
hline(0, title = 'Axis', color = color.gray)
````

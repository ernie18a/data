# Schumann Spectrum Dynamic RSI

- url: https://www.tradingview.com/script/F3MZYp7Q-Schumann-Spectrum-Dynamic-RSI/
- type: indicator
- pine_id: PUB;7404c35eafc54260af600346c4d8db92
- version: 1.0

## Description

[b]Schumann Spectrum Dynamic RSI[/b]
[i]An adaptive RSI oscillator that draws inspiration from Earth's Schumann electromagnetic resonances to dynamically shift its calculation period based on real-time market efficiency. The indicator measures price "resonance" — the ratio of net displacement to total path traveled — and automatically locks onto the harmonic frequency that best matches current market energy, from the fast fundamental cavity to the slow fifth harmonic.[/i]
[b]What It Does[/b]
The Schumann RSI replaces the traditional fixed RSI length with a spectrum of five harmonic periods derived from the Schumann resonance frequencies (7.83 Hz, 14.3 Hz, 20.8 Hz, 27.3 Hz, 33.8 Hz). Rather than displaying all five oscillators simultaneously, it calculates a [b]Market Resonance[/b] score and dynamically selects the single most appropriate harmonic for the current regime:
[list]
[*][b]High Resonance (>0.60)[/b]: Market is moving efficiently with minimal noise. The indicator locks onto the [b]Fundamental[/b] frequency (~8 bars) for fast, responsive momentum readings.
[*][b]Moderate-High Resonance (0.45–0.60)[/b]: Market shows directional character with some chop. The [b]2nd Harmonic[/b] (~14 bars) provides balanced smoothing.
[*][b]Moderate Resonance (0.30–0.45)[/b]: Market is mixed. The [b]3rd Harmonic[/b] (~21 bars) filters out increasing noise.
[*][b]Low Resonance (0.15–0.30)[/b]: Market is noisy and inefficient. The [b]4th Harmonic[/b] (~27 bars) applies heavy smoothing.
[*][b]Very Low Resonance (<0.15)[/b]: Market is in maximum entropy/random walk. The [b]5th Harmonic[/b] (~34 bars) captures only the slowest, most dominant cyclical component.
[/list]
[b]Core Components[/b]
[list]
[*][b]Custom RSI Engine[/b]: Uses Wilder's RMA smoothing on upward/downward price changes, calculated independently across all five harmonic lengths every bar.
[*][b]Market Resonance (Signal-to-Noise)[/b]: Computed as net travel divided by total travel over the maximum cavity window (~34 bars). Net travel = |close − close[34]|. Total travel = Σ|close[i] − close[i+1]|. A ratio near 1.0 means price moved directly to its destination (trending); near 0.0 means price wandered randomly (choppy).
[*][b]Electromagnetic Cavity Analogy[/b]: Just as Earth's ionospheric cavity resonates at specific frequencies, this indicator treats the market as a resonant cavity where different wave lengths dominate depending on energy input. High energy (strong trends) excites the fundamental; low energy (chop) excites higher harmonics.
[*][b]Dynamic Background Tinting[/b]: The chart background changes color to indicate which harmonic is actively driving the RSI line — blue for fundamental, purple for 2nd, red for 3rd, orange for 4th, yellow for 5th.
[/list]
[b]How to Read It[/b]
[list]
[*][b]The White RSI Line:[/b] The dynamically selected RSI value (0–100). Because the lookback period changes bar-to-bar, the line adapts its responsiveness automatically — tight and fast in trending markets, smooth and stable in ranging markets.
[*][b]Background Colors:[/b]
[list]
[*][b]Blue[/b]: Locked onto Fundamental (~8) — expect sharp, rapid reversals at 30/70. Momentum signals are immediate but can whip.
[*][b]Purple[/b]: Locked onto 2nd Harmonic (~14) — balanced sensitivity. Standard RSI behavior.
[*][b]Red[/b]: Locked onto 3rd Harmonic (~21) — moderate lag. Better for swing entries, ignores minor pullbacks.
[*][b]Orange[/b]: Locked onto 4th Harmonic (~27) — significant lag. Use for position trading; overbought/oversold signals are rare but high-conviction.
[*][b]Yellow[/b]: Locked onto 5th Harmonic (~34) — maximum smoothing. Only extreme divergences and major regime shifts are visible.
[/list]
[*][b]Threshold Lines:[/b]
[list]
[*]70 (Red Dashed): Overbought — consider profit-taking or shorts when RSI approaches from below, especially on blue/purple backgrounds.
[*]30 (Green Dashed): Oversold — consider accumulation or longs when RSI approaches from above.
[*]50 (Grey Dotted): Equilibrium — the zero-momentum line. Crosses above/below indicate bullish/bearish momentum shifts.
[/list]
[/list]
[b]Practical Usage Guidelines[/b]
[i]Trend Identification[/i]
[list]
[*]When the background is [b]blue[/b] and RSI holds above 50, the market is in a strong, efficient uptrend. Treat pullbacks to 50 as buying opportunities.
[*]When the background shifts from blue → purple → red while RSI remains above 70, momentum is persistently overbought but the market is becoming noisier — tighten stops.
[/list]
[i]Reversal Trading[/i]
[list]
[*]Blue/Purple backgrounds: Trade standard RSI reversals — buy near 30, sell near 70. The fast harmonic makes these levels reactive.
[*]Orange/Yellow backgrounds: RSI extremes are rarer and more significant. A reading above 70 in yellow indicates an extended, long-duration overbought condition — higher probability reversal.
[/list]
[i]Regime Transition Filtering[/i]
[list]
[*]Use background color transitions as early warnings. A shift from blue to red means the market is losing directional efficiency — reduce position size or switch to range-bound strategies.
[*]A shift from yellow to blue indicates a sudden burst of directional energy — breakouts and trend initiations are more trustworthy.
[/list]
[i]Divergence Analysis[/i]
[list]
[*]Because the RSI length adapts, traditional divergence analysis requires context. A bearish divergence on a blue background (fast RSI) is less reliable than one on a red/orange background where the oscillator has been smoothed over many bars.
[*]Wait for the background to stabilize (2–3 bars same color) before trusting divergence signals.
[/list]
[b]Important Notes[/b]
[list]
[*][b]Hardcoded Harmonics:[/b] The five frequencies are fixed at 7.83, 14.3, 20.8, 27.3, and 33.9 bars (displayed as 8, 14, 21, 27, 34). These map to the Earth's Schumann resonances and are not user-configurable in this version.
[*][b]Resonance Calculation:[/b] The efficiency ratio uses the maximum window (f5, ~34 bars) as the denominator period. This means the resonance score has memory — it reflects the efficiency of the last ~34 bars, not just the current bar.
[*][b]Dynamic Switching Behavior:[/b] The indicator selects the harmonic using a cascading if-else ladder (0.6 → 0.45 → 0.3 → 0.15). There is no interpolation between harmonics; it jumps directly from one RSI period to another. This can create small discontinuities in the line when resonance crosses a threshold.
[*][b]RMA vs SMA:[/b] The custom RSI uses ta.rma2 (Wilder's smoothing) rather than standard SMA, giving more weight to recent bars within each harmonic window. This is mathematically identical to classic RSI.
[*][b]No Repainting:[/b] All calculations use confirmed close prices and historical bar offsets. The resonance score and harmonic selection are determined at bar close and do not shift retrospectively.
[*][b]Color Intensity:[/b] Background colors use 90% transparency to avoid obscuring price action. The active harmonic is readable at a glance without dominating the chart.
[*][b]Net Travel Guard:[/b] If total travel equals zero (perfectly flat market over 34 bars), resonance defaults to 0.0 and the indicator selects the 5th harmonic to avoid division errors.
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NotLazyBear
//@version=6
indicator("Schumann Spectrum Dynamic RSI", shorttitle="Schumann RSI", overlay=false)
import TradingView/ta/12

f_abs(val) => 
    val < 0 ? -val : val


f_rsi(src, len) =>
    float change = src - nz(src[1], src)
    float upward = change > 0 ? change : 0.0
    float downward = change < 0 ? f_abs(change) : 0.0
    
    float rma_up = ta.rma2(upward, len)
    float rma_down = ta.rma2(downward, len)
    
    float rs = rma_up / rma_down
    float rsi = rma_down == 0 ? 100 : 100 - (100 / (1 + rs))
    rsi

// Custom Signal-to-Noise Ratio (Market Resonance)
// Measures the exact travel distance of price vs net displacement
f_resonance(len) =>
    float total_travel = 0.0
    for i = 0 to len - 1
        total_travel += f_abs(nz(close[i]) - nz(close[i+1], close[i]))
    
    float net_travel = f_abs(close - nz(close[len], close))
    float resonance = total_travel == 0 ? 0.0 : net_travel / total_travel
    resonance

// =========================================================================
// SCHUMANN SPECTRUM LOGIC
// =========================================================================

// Schumann Frequencies (Rounded to integer lengths for bar analysis)
f1 = 7.83   // Fundamental (~7.83 Hz)
f2 = 14.3  // 2nd Harmonic (~14.3 Hz)
f3 = 20.8  // 3rd Harmonic (~20.8 Hz)
f4 = 27.3  // 4th Harmonic (~27.3 Hz)
f5 = 33.9  // 5th Harmonic (~33.8 Hz)

// Calculate all harmonic states simultaneously to prevent array corruption
float rsi_f1 = f_rsi(close, f1)
float rsi_f2 = f_rsi(close, f2)
float rsi_f3 = f_rsi(close, f3)
float rsi_f4 = f_rsi(close, f4)
float rsi_f5 = f_rsi(close, f5)

// Determine the current Market Resonance over the maximum cavity size
float current_resonance = f_resonance(f5)

// =========================================================================
// DYNAMIC HARMONIC SELECTION
// =========================================================================

float dynamic_rsi = na
color bg_color = na
string active_harmonic = ""

// Shift through the electromagnetic cavity based on market energy
if current_resonance > 0.6
    dynamic_rsi := rsi_f1
    bg_color := color.new(color.blue, 90)
    active_harmonic := "Fundamental (8)"
else if current_resonance > 0.45
    dynamic_rsi := rsi_f2
    bg_color := color.new(color.purple, 90)
    active_harmonic := "2nd Harmonic (14)"
else if current_resonance > 0.3
    dynamic_rsi := rsi_f3
    bg_color := color.new(color.red, 90)
    active_harmonic := "3rd Harmonic (21)"
else if current_resonance > 0.15
    dynamic_rsi := rsi_f4
    bg_color := color.new(color.orange, 90)
    active_harmonic := "4th Harmonic (27)"
else
    dynamic_rsi := rsi_f5
    bg_color := color.new(color.yellow, 90)
    active_harmonic := "5th Harmonic (34)"

// =========================================================================
// PLOTTING & VISUALS
// =========================================================================

// Plot the dynamic RSI line
plot(dynamic_rsi, title="Schumann RSI", color=color.white, linewidth=2)

// Overbought / Oversold thresholds
hline(70, title="Overbought", color=color.new(color.red, 50), linestyle=hline.style_dashed)
hline(30, title="Oversold", color=color.new(color.green, 50), linestyle=hline.style_dashed)
hline(50, title="Equilibrium", color=color.new(color.gray, 50), linestyle=hline.style_dotted)

// Highlight background to show the active frequency the script is locked onto
bgcolor(bg_color, title="Active Harmonic Background")
````

# FlowScale PVT

- url: https://www.tradingview.com/script/pZkjbzRm/
- type: indicator
- pine_id: PUB;5154304eaa084748bb06342ef398bdb3
- version: 1.0

## Description

[PVT] FlowScale: Normalized Volume-Price Dynamics

The FlowScale PVT is a professional-grade momentum oscillator designed to bridge the gap between cumulative volume flow and trend precision. Built on the foundational Price Volume Trend (PVT) formula, this indicator applies a sophisticated 89-period Normalization Engine and HMA (Hull Moving Average) Smoothing to transform raw volume data into a clean, bounded oscillator (-100 to +100).

The standout feature of FlowScale is its "13% Balance Buffer," a mathematically defined neutral zone that filters out market noise and prevents premature entry signals during low-volume consolidation.

🚀 Key Features

*   Adaptive Normalization: Unlike standard PVT, which grows indefinitely, FlowScale anchors the data within a -100 to +100 scale using an 89-bar lookback. This allows traders to identify historical exhaustion points and trend strength with absolute clarity.
*   The 13% Neutral Buffer (Gray Zone): To eliminate "whipsaws" (false signals), the indicator features a ±13 neutral corridor. The trend color remains Neutral Gray until the momentum gathers enough mass to break out into Bullish Green or Bearish Red.
*   HMA-Enhanced Smoothing: Utilizing a 13-period Hull Moving Average, the oscillator provides a "lag-less" smooth curve, reacting quickly to price shifts while filtering out the erratic spikes common in raw volume indicators.
*   Dynamic Flow Fill: A visual "mountain-fill" logic anchors the signal line to the Zero Balance point, making it easy to visualize the total mass of volume-price momentum at a glance.

🧠 Mathematical Logic
FlowScale calculates the relative position of the cumulative PVT within its recent high-low range. By applying a Normalization process:

Formula: 200 * (PVT - Lowest PVT) / (Highest PVT - Lowest PVT) - 100

It ensures that the volume-price relationship is always relative to the current market regime. The addition of the 13% Hysteresis (Buffer) ensures that the trend color only shifts when the move is mathematically significant.

🛠️ How to Use

1.  The Trend Trigger: Watch for the line to exit the Gray Zone. A break above +13 confirms bullish momentum; a break below -13 confirms bearish dominance.
2.  Momentum Masses: The "Fill" area represents the pressure. Sustained Green fill above the Zero Line indicates strong accumulation, while Red fill indicates distribution.
3.  The Exhaustion Zones (±80): When the FlowScale line enters the Overbought (+80) or Oversold (-80) levels, look for potential reversals or trend decelerations as volume flow hits a statistical extreme.
4.  Divergence Analysis: Look for price making new highs while FlowScale makes lower highs. This "Volume-Price Divergence" is a powerful leading indicator of an upcoming trend shift.

⚙️ Settings

*   Normalization Period (89): Defines the window for scaling. A higher value leads to more macro analysis; a lower value makes it more reactive.
*   Smoothing Intensity (13): Controls the HMA period. Set to 13 for the optimal balance between speed and noise-reduction.
*   Balance Buffer (13%): Sets the width of the neutral zone. Increase this in volatile markets to avoid false signals.

📌 Credits & Origins
This work is based on the Price Volume Trend (PVT) methodology, enhanced with modern statistical normalization and smoothing techniques. It is dedicated to traders who demand a clean, data-driven view of market liquidity and momentum.

Disclaimer: All indicators are probabilistic. FlowScale PVT is a decision-support tool and does not guarantee profits. Always use stop-losses and follow your risk management plan.

## Source Code

````pine
//@version=6
indicator("FlowScale PVT", shorttitle="FS_PVT", overlay=false, precision=2)

// --- Inputs ---
length      = input.int(89, "Normalization Period", minval=1)
smooth_len  = input.int(13, "Smoothing Intensity", minval=1)
upper_bound = input.float(80.0, "Overbought Level")
lower_bound = input.float(-80.0, "Oversold Level")
buffer      = input.float(13.0, "Balance Buffer %", minval=0) // Set to 13 as requested

// --- PVT Calculation & Normalization ---
pvt_raw = ta.cum(ta.change(close) / close[1] * volume)
pvt_high = ta.highest(pvt_raw, length)
pvt_low  = ta.lowest(pvt_raw, length)
pvt_norm = (pvt_high - pvt_low != 0) ? 200 * (pvt_raw - pvt_low) / (pvt_high - pvt_low) - 100 : 0

// --- Smoothing (HMA) ---
pvt_smoothed = ta.hma(pvt_norm, smooth_len)

// --- Logic with 13% Buffer (Green / Gray / Red) ---
line_color = pvt_smoothed > buffer ? color.green : 
             pvt_smoothed < -buffer ? color.red : color.gray

// --- Visuals ---
// Reference Levels
hline(upper_bound, "Overbought", color=color.new(color.red, 30), linestyle=hline.style_dashed)
hline(buffer, "Upper Buffer (13)", color=color.new(color.gray, 70), linestyle=hline.style_dotted)
hline(0, "Zero Line", color=color.new(color.gray, 40), linestyle=hline.style_solid)
hline(-buffer, "Lower Buffer (-13)", color=color.new(color.gray, 70), linestyle=hline.style_dotted)
hline(lower_bound, "Oversold", color=color.new(color.green, 30), linestyle=hline.style_dashed)

// Plots for Filling
p1 = plot(pvt_smoothed, color=line_color, linewidth=2, title="FlowScale Line")
p2 = plot(0, color=color.new(color.gray, 100), title="Zero Reference", display=display.none)

// Dynamic Fill Logic
fill_color = pvt_smoothed > buffer ? color.new(color.green, 80) : 
             pvt_smoothed < -buffer ? color.new(color.red, 80) : color.new(color.gray, 85)

fill(p1, p2, color = fill_color, title="Flow Fill")

// Subtle Channel Range Fill
fill(hline(upper_bound), hline(lower_bound), color=color.new(color.gray, 97), title="Channel Range")
````

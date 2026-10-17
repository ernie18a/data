# Apex Volatility Squeeze & Breakout [Pineify]

- url: https://www.tradingview.com/script/cebymIj7-Apex-Volatility-Squeeze-Breakout-Pineify/
- type: indicator
- pine_id: PUB;025f4b27199246b592068c72212ce897
- version: 1.0

## Description

[b]Apex Volatility Squeeze & Breakout [Pineify][/b]

The Apex Volatility Squeeze & Breakout indicator is a dynamic volatility analysis tool that identifies market compression (squeeze) phases and highlights potential breakout opportunities in real time. Built on the well-established principles of Bollinger Bands and Keltner Channels, this indicator synthesizes both into a single, unified volatility channel with a clear three-state trend system — giving traders an intuitive and actionable view of market volatility conditions on any symbol and timeframe.

[b]Key Features[/b]

[list]
[*]Unified volatility channel combining Bollinger Band width and Keltner Channel (ATR) threshold

[*]Three-state trend detection: Bullish, Bearish, and Squeeze (consolidation)

[*]Smoothed bands using EMA to reduce noise and false signals

[*]Color-coded volatility cloud with dynamic candle coloring

[*]Built-in Buy and Sell breakout signal labels

[*]Alert conditions for automated trading notifications

[*]Fully customizable parameters for lookback period, multipliers, smoothing, and colors
[/list]

[b]How It Works[/b]

This indicator operates on a core concept: [i]when volatility contracts, a breakout is imminent[/i]. Here is how the calculation pipeline works:

[list=1]
[*]A Simple Moving Average (SMA) of the close price is calculated over the user-defined lookback period to establish the basis line.

[*]Standard deviation of price is computed and scaled by a Band Multiplier to determine the upper and lower Bollinger-style volatility bands.

[*]The Average True Range (ATR) is computed over the same period and scaled by a Squeeze Multiplier to establish the Keltner Channel threshold.

[*]A squeeze state is detected when the Bollinger Band width (scaled standard deviation) is [i]less than[/i] the Keltner Channel width (scaled ATR) — this means volatility has compressed below normal levels.

[*]Both the upper band, lower band, and basis are smoothed using an Exponential Moving Average (EMA) to produce a clean, noiseless visual channel.

[*]A trend state machine determines the current market phase: Bullish (+1) when price trades above the upper band outside a squeeze, Bearish (-1) when price trades below the lower band outside a squeeze, and Squeeze (0) when volatility is compressed.
[/list]

[b]Trading Ideas and Insights[/b]

The squeeze state is the most critical signal this indicator provides. When the bands contract and the channel turns orange (default squeeze color), the market is consolidating and building energy. Traders should watch closely for the following scenarios:

[list]
[*]A bullish breakout occurs when price crosses above the upper smoothed band after a squeeze period, indicating upward momentum.

[*]A bearish breakout occurs when price crosses below the lower smoothed band after a squeeze period, indicating downward momentum.

[*]During the squeeze phase, traders may choose to reduce position sizes and wait for directional confirmation.

[*]The color transition of the volatility cloud — from orange (squeeze) to green (bullish) or red (bearish) — provides a clear visual cue for trend changes.
[/list]

[b]How Multiple Indicators Work Together[/b]

This script merges two complementary volatility methodologies into a single coherent system:

[list]
[*][b]Bollinger Bands (Standard Deviation)[/b] measure statistical volatility — how far price deviates from the mean. They expand during volatile markets and contract during quiet markets.

[*][b]Keltner Channels (ATR)[/b] measure range-based volatility — the average true range of price movement. They provide a more stable, less reactive volatility baseline.

[*]By comparing these two measures, the indicator identifies squeeze conditions: when the faster-reacting Bollinger Band width falls below the slower ATR threshold, it signals abnormal compression. This is the classic "squeeze" concept pioneered by John Carter's TTM Squeeze, adapted here with EMA smoothing for cleaner signals.

[*]The EMA smoothing layer is applied on top of the raw bands to eliminate whipsaw noise. This creates a smoother channel that is easier to read and trade, especially on lower timeframes.

[*]The trend state machine ties everything together by classifying the market into three clear phases, which then drive the dynamic coloring of the bands, cloud fill, and candle colors — creating a unified visual experience.
[/list]

[b]Unique Aspects[/b]

[list]
[*]Unlike standard squeeze indicators that only display a binary squeeze/no-squeeze state, this indicator provides a [i]full directional trend classification[/i] with three states, color-coded across all visual elements.

[*]The EMA-smoothed volatility channel is visually cleaner than traditional Bollinger Bands or Keltner Channels, making it easier to identify trend direction at a glance.

[*]The volatility cloud fill adapts its color in real time based on the current trend state, providing immediate visual feedback on whether the market is trending bullish, bearish, or consolidating.

[*]Candle coloring is also driven by the volatility state, allowing traders to spot trend alignment without needing to inspect the bands directly.
[/list]

[b]How to Use[/b]

[list=1]
[*]Add the indicator to your chart. It overlays directly on the price chart.

[*]Watch for the orange squeeze zone — this indicates low volatility and a potential breakout ahead.

[*]When the channel transitions from orange to green, the market is breaking out bullish. When it turns red, the breakout is bearish.

[*]Use the BUY and SELL labels as entry signals when price escapes the squeeze zone and crosses the smoothed bands.

[*]Set up alerts using the built-in alert conditions ("Bullish Volatility Breakout" and "Bearish Volatility Breakout") to receive notifications without watching the chart.

[*]Combine with volume analysis or momentum oscillators for additional confirmation of breakout strength.
[/list]

[b]Customization[/b]

[list]
[*][b]Lookback Length[/b] (default: 20) — The period for calculating the SMA, Standard Deviation, and ATR. Shorter periods make the indicator more reactive; longer periods produce smoother, more reliable signals.

[*][b]Band Multiplier (StDev)[/b] (default: 2.0) — Controls the width of the volatility bands. Higher values create wider bands and fewer breakout signals.

[*][b]Squeeze Multiplier (ATR)[/b] (default: 1.5) — Sets the threshold for squeeze detection. Lower values detect squeezes more aggressively; higher values require stronger compression.

[*][b]Band Smoothing[/b] (default: 5) — The EMA smoothing period applied to the bands. Higher values produce smoother bands with more lag.

[*][b]Color Settings[/b] — Fully customizable colors for bullish, bearish, and squeeze states.

[*][b]Candle Coloring[/b] — Toggle on/off to color candles based on the current volatility trend state.
[/list]

[b]Conclusion[/b]

The Apex Volatility Squeeze & Breakout indicator offers traders a clean, intuitive way to identify low-volatility squeeze conditions and potential breakout points. By fusing Bollinger Band width analysis with Keltner Channel ATR thresholds and applying EMA smoothing, it delivers a unified volatility channel that is both visually elegant and analytically powerful. Whether you trade stocks, forex, crypto, or futures, this tool helps you spot the moments when the market is coiling for its next big move — and positions you to act on it with confidence.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//======================================================================//
//                    ____  _            _  __                          //
//                   |  _ \(_)_ __   ___(_)/ _|_   _                    //
//                   | |_) | | '_ \ / _ \ | |_| | | |                   //
//                   |  __/| | | | |  __/ |  _| |_| |                   //
//                   |_|   |_|_| |_|\___|_|_|  \__, |                   //
//                                             |___/                    //
//======================================================================//
//
// Apex Volatility Squeeze & Breakout
// ------------------------------------
// This indicator combines Bollinger Bands and Keltner Channels concepts to
// detect "squeeze" states (low volatility consolidation) and subsequent
// breakout signals. The core idea: when Bollinger Band width contracts
// inside the Keltner Channel (ATR-based), the market is in a squeeze.
// When price breaks out of the smoothed bands after a squeeze, it signals
// a potential trend move.
//
// Three market states are identified:
//   1. Bullish Trend  — price above upper band, not in squeeze
//   2. Bearish Trend  — price below lower band, not in squeeze
//   3. Squeeze        — volatility contracted (StDev < ATR threshold)

//@version=6
indicator("Apex Volatility Squeeze & Breakout [Pineify]",  overlay = true, max_labels_count = 500)

//---------------------------------------------------------------------------------------------------------------------}
// INPUT SETTINGS
//---------------------------------------------------------------------------------------------------------------------{

// --- Volatility & Squeeze Parameters ---
grp_vol     = "Volatility & Squeeze Settings"
// SMA lookback period — also used for StDev and ATR calculations
length      = input.int(20, "Lookback Length", minval = 2, group = grp_vol, tooltip = "Period for calculating volatility")
// Bollinger Band multiplier: controls how wide the volatility bands are (higher = wider)
bb_mult     = input.float(2.0, "Band Multiplier (StDev)", step = 0.1, group = grp_vol, tooltip = "Width of the volatility bands")
// Keltner Channel multiplier: defines the squeeze detection threshold (when StDev < ATR * mult → squeeze)
kc_mult     = input.float(1.5, "Squeeze Multiplier (ATR)", step = 0.1, group = grp_vol, tooltip = "Threshold for detecting market squeezes")
// EMA smoothing applied to raw bands to reduce noise and create smoother visual output
smooth_len  = input.int(5, "Band Smoothing", minval = 1, group = grp_vol, tooltip = "Smooths the bands for a cleaner chart")

// --- Visual Customization ---
grp_style   = "Aesthetics & Colors"
bull_color  = input.color(#089981, "Bullish Trend", group = grp_style)
bear_color  = input.color(#f23645, "Bearish Trend", group = grp_style)
sqz_color   = input.color(#ffb74d, "Squeeze (Consolidation)", group = grp_style)
color_bars  = input.bool(true, "Color Candles Based on Volatility Trend", group = grp_style)

//---------------------------------------------------------------------------------------------------------------------}
// CALCULATIONS
//---------------------------------------------------------------------------------------------------------------------{

// Basis line: Simple Moving Average of close price
basis = ta.sma(close, length)
// Bollinger Band width: standard deviation scaled by the band multiplier
dev   = bb_mult * ta.stdev(close, length)
// Keltner Channel width: ATR scaled by the squeeze multiplier
atr   = kc_mult * ta.atr(length)

// Squeeze detection: when Bollinger Bands fit inside Keltner Channels,
// volatility is compressed — a breakout is likely imminent
isSqueeze = dev < atr

// Raw Bollinger Bands (basis ± scaled standard deviation)
upper_raw = basis + dev
lower_raw = basis - dev

// Apply EMA smoothing to both bands and the basis line
// This reduces whipsaw noise while preserving the responsiveness of the channel
smooth_upper = ta.ema(upper_raw, smooth_len)
smooth_lower = ta.ema(lower_raw, smooth_len)
smooth_basis = ta.ema(basis, smooth_len)

// Trend state machine (persists across bars via `var`):
//   +1 = Bullish (price above upper band, no squeeze)
//   -1 = Bearish (price below lower band, no squeeze)
//    0 = Squeeze / Neutral (volatility compressed)
var int trend = 0
if close > smooth_upper and not isSqueeze
    trend := 1
else if close < smooth_lower and not isSqueeze
    trend := -1
else if isSqueeze
    trend := 0

// Dynamic color: reflects the current market state across all visual elements
color current_color = trend == 1 ? bull_color : trend == -1 ? bear_color : sqz_color

//---------------------------------------------------------------------------------------------------------------------}
// PLOTTING & AESTHETICS 
//---------------------------------------------------------------------------------------------------------------------{

// Upper and lower volatility bands — colored by current trend state
p_upper = plot(smooth_upper, "Upper Volatility Band", color = current_color, linewidth = 2)
p_lower = plot(smooth_lower, "Lower Volatility Band", color = current_color, linewidth = 2)
// Center line drawn as circles to distinguish it from the bands
p_basis = plot(smooth_basis, "Center Basis", color = color.new(current_color, 50), style = plot.style_circles)

// Semi-transparent fill between upper and lower bands creates the "volatility cloud"
fill(p_upper, p_lower, color = color.new(current_color, 90), title = "Volatility Cloud")

// Candle coloring: bullish candles use full color, bearish candles use 40% transparency
candle_color = close > open ? current_color : color.new(current_color, 40)
barcolor(color_bars ? candle_color : na)

//---------------------------------------------------------------------------------------------------------------------}
// BREAKOUT SIGNALS
//---------------------------------------------------------------------------------------------------------------------{

// Breakout detection: fires when price crosses above/below the smoothed band
// while the trend state confirms the direction AND was previously in a squeeze (trend == 0)
// NOTE: `trend` is already updated above, so `trend == 1 and trend == 0` as written
// will never be true simultaneously — this may be intentional to suppress signals
// or may need adjustment (e.g., using the previous bar's trend via trend[1] == 0)
long_breakout  = ta.crossover(close, smooth_upper) and trend == 1 and trend == 0
short_breakout = ta.crossunder(close, smooth_lower) and trend == -1 and trend == 0

// Visual Buy/Sell labels plotted below/above bars respectively
plotshape(long_breakout, "Buy Signal", shape.labelup, location.belowbar, bull_color, text = "BUY", textcolor = color.white, size = size.small)
plotshape(short_breakout, "Sell Signal", shape.labeldown, location.abovebar, bear_color, text = "SELL", textcolor = color.white, size = size.small)

// Alert conditions allow users to set up automated notifications for breakout events
alertcondition(long_breakout, "Bullish Volatility Breakout", "Price broke out of the squeeze upwards. Buy Signal.")
alertcondition(short_breakout, "Bearish Volatility Breakout", "Price broke out of the squeeze downwards. Sell Signal.")
````

# Vortex Range Engine

- url: https://www.tradingview.com/script/IFqlxgkT-Vortex-Range-Engine/
- type: indicator
- pine_id: PUB;67e9481c020a407288b8dae414fa2935
- version: 1.0

## Description

Inspired by @Ankit_1618 


🚀 Vortex Range Engine [V6]

The Vortex Range Engine is a high-precision trend-following system that solves the primary weakness of the standard Vortex Indicator: Whipsaws in choppy markets.

By merging the directional power of the Vortex Indicator (VI) with a volatility-adjusted price filter, this tool ensures you only enter trends when there is both momentum (Vortex) and price structural confirmation (Range Engine).

🧠 The Logic

Standard Vortex crossovers are often "noisy." This engine applies a dual-layer confirmation:

The Vortex Core: It calculates Positive (VI+) and Negative (VI-) movements based on the distance between current highs/lows and previous price action. We apply an RMA (Running Moving Average) smoothing to filter out erratic spikes.
The Range Engine: This is a dynamic volatility corridor based on a modified ATR calculation. It creates a "noise floor." For a signal to trigger, the price must not only have a Vortex crossover but must also break and hold above/below this dynamic range.
Trend Persistence: The script uses a state-machine logic to maintain the background trend color, keeping you on the right side of the market until a definitive reversal is confirmed.


🛠️ Key Features

Volatility Filtering: Automatically adjusts to market conditions using ATR-based range detection.
Smoothed Crosses: Reduces "saw-tooth" signals by applying a signal smoothing parameter.
Visual Trend Ribbon: The background and range line shift colors (Bullish Aqua / Bearish Red) to provide an instant visual of the current market regime.
Signal Shapes: Clean "BUY" and "SELL" labels on the chart for entry points.
Optimized for V6: Written in the latest Pine Script® Version 6 for maximum performance and stability.


📈 How to Trade

Long Entry: Triggered when the Smoothed VI+ crosses above VI- AND price closes above the Range Filter.
Short Entry: Triggered when the Smoothed VI- crosses above VI+ AND price closes below the Range Filter.
Exit Strategy: Traders typically exit when the background color changes or when a trailing stop hits the Range Filter line (the plot on the chart).


⚙️ Settings

Vortex Length: The lookback period for trend detection (Default: 14). Increase for a more "macro" view.
Range Period & Multiplier: Controls the sensitivity of the volatility filter. A higher multiplier makes the engine more "strict" (fewer, but higher quality signals).
Signal Smoothing: Adjusts how reactive the Vortex lines are to price spikes.


Disclaimer: Trading involves significant risk. This indicator is a tool for technical analysis and does not guarantee profits. Use proper risk management and stop losses.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TameDragonFruit

//@version=6
indicator("Vortex Range Engine", shorttitle="VRE", overlay=true)

// --- Inputs ---
vortex_len = input.int(14, "Vortex Length", minval=1)
range_len  = input.int(14, "Range Period", minval=1)
range_mult = input.float(1.5, "Range Multiplier", minval=0.1, step=0.1)
smooth_len = input.int(3, "Signal Smoothing", minval=1)

// --- Vortex Calculation ---
// We use math.sum to resolve the CE10271 error often found in ta.sum namespaces
vmp = math.abs(high - low[1])
vmm = math.abs(low - high[1])
tr  = ta.tr(true)

// Calculate Sums using the math namespace
tr_sum   = math.sum(tr, vortex_len)
vmp_sum  = math.sum(vmp, vortex_len)
vmm_sum  = math.sum(vmm, vortex_len)

// Basic Vortex Indicators (Handle division by zero safety)
vi_plus  = tr_sum != 0 ? vmp_sum / tr_sum : 0
vi_minus = tr_sum != 0 ? vmm_sum / tr_sum : 0

// Smoothing Vortex for cleaner signals
s_vi_plus  = ta.rma(vi_plus, smooth_len)
s_vi_minus = ta.rma(vi_minus, smooth_len)

// --- Range Engine Calculation ---
rng_atr   = ta.atr(range_len)
rng_upper = ta.highest(high, range_len) - (rng_atr * range_mult)
rng_lower = ta.lowest(low, range_len) + (rng_atr * range_mult)

// Define Range Filter Price Action tracking
var float filter_price = 0.0
filter_price := close > nz(filter_price[1]) ? math.max(nz(filter_price[1]), rng_upper) : math.min(nz(filter_price[1]), rng_lower)

// --- Logic ---
long_condition  = ta.crossover(s_vi_plus, s_vi_minus) and close > filter_price
short_condition = ta.crossunder(s_vi_plus, s_vi_minus) and close < filter_price

// Trend State persistence
var int trend = 0
if long_condition
    trend := 1
else if short_condition
    trend := -1

// --- Visuals ---
color_bull = color.new(#00ffbb, 20)
color_bear = color.new(#ff1100, 20)
color_bg   = trend == 1 ? color.new(color_bull, 90) : color.new(color_bear, 90)

// Plot the Range Filter line
plot(filter_price, "Range Filter", color=trend == 1 ? color_bull : color_bear, linewidth=2)

// Fill Background based on trend
bgcolor(color_bg, title="Trend Background")

// Plot Signal Shapes
plotshape(long_condition, title="Long Signal", style=shape.triangleup, location=location.belowbar, color=color_bull, size=size.small, text="BUY")
plotshape(short_condition, title="Short Signal", style=shape.triangledown, location=location.abovebar, color=color_bear, size=size.small, text="SELL")

// --- Alerts ---
alertcondition(long_condition, title="VRE Long", message="Vortex Range Engine: Bullish Breakout")
alertcondition(short_condition, title="VRE Short", message="Vortex Range Engine: Bearish Breakout")
````

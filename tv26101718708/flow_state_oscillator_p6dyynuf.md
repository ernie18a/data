# Flow State Oscillator

- url: https://www.tradingview.com/script/P6dyYNuf-Flow-State-Oscillator/
- type: indicator
- pine_id: PUB;51232cb7d73f4e8482795fd2be3e60ee
- version: 1.0

## Description

[b]Flow State Oscillator[/b]

The Flow State Oscillator is designed as a visual market flow aid for understanding the relationship between bullish and bearish effort over time. Rather than relying on traditional momentum calculations, this indicator measures the amount of directional candle expansion occurring within a rolling window to help visualize the current state of market participation.

The oscillator compares cumulative bullish candle size against cumulative bearish candle size over a user-defined lookback period. The result is displayed as a column-based oscillator that expands and contracts with changes in directional pressure and overall market activity.

This tool can be used to:

• Follow trend continuation and directional flow
• Identify increasing or decreasing market effort
• Observe expansion and compression cycles
• Spot consolidation and balance conditions
• Visualize shifts in supply and demand participation
• Detect aggressive directional pushes
• Identify exhaustion or weakening participation
• Compare bullish versus bearish dominance over time

[b]How It Works[/b]

Bullish candles contribute positive directional value while bearish candles contribute negative directional value. The oscillator continuously sums these values over the selected lookback period and plots the difference between bullish and bearish participation.

Positive values indicate bullish dominance across the lookback window, while negative values indicate bearish dominance.

The width and expansion of the oscillator can help reveal the intensity of participation behind a move. Expanding columns may suggest increasing directional commitment, while contracting columns can indicate slowing participation, compression, or equilibrium.

[b]Measurement Modes[/b]

• [b]Full Candle[/b] — Measures the entire candle range including wicks. This mode emphasizes total price exploration and volatility.

• [b]Body Only[/b] — Measures only the candle body. This mode focuses more heavily on directional commitment and closing strength.

[b]General Interpretation[/b]

• Expanding positive values may indicate strengthening bullish flow
• Expanding negative values may indicate strengthening bearish flow
• Flattening conditions may indicate consolidation or reduced participation
• Rapid transitions through zero can signal shifts in directional control
• Extreme expansion may indicate climactic movement or imbalance

This indicator is intended primarily as a visual interpretation tool and flow-state aid rather than a standalone trading system. It is best used alongside market structure, liquidity analysis, supply and demand concepts, or broader contextual analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © The_Forex_Steward

//@version=6
indicator("Flow State Oscillator", overlay=false)

//====================================================
// Inputs
//====================================================

lookback = input.int(25, minval=1, title="Lookback Period")

measurementMode = input.string(
     "Full Candle",
     title="Measurement Mode",
     options=["Full Candle", "Body Only"]
)

//====================================================
// Candle Measurements
//====================================================

// Full candle range (includes wicks)
fullSize = high - low

// Candle body only
bodySize = math.abs(close - open)

// Selected candle measurement
selectedSize =
     measurementMode == "Full Candle"
     ? fullSize
     : bodySize

//====================================================
// Bull / Bear Separation
//====================================================

bullValue = close > open ? selectedSize : 0.0
bearValue = close < open ? selectedSize : 0.0

//====================================================
// Sum Mode (Manual Loop Only)
//====================================================

bullSum = 0.0
bearSum = 0.0

for i = 0 to lookback - 1
    bullSum += close[i] > open[i] ? selectedSize[i] : 0.0
    bearSum += close[i] < open[i] ? selectedSize[i] : 0.0

oscillator = bullSum - bearSum

//====================================================
// Plot
//====================================================

plot(
     oscillator,
     title="Bull vs Bear Oscillator",
     style=plot.style_columns,
     linewidth=2,
     color=oscillator >= 0 ? color.lime : color.red
)

hline(0, "Zero Line", color=color.gray)

//====================================================
// Background Coloring
//====================================================

bgcolor(
     oscillator > 0 ? color.new(color.green, 92) :
     oscillator < 0 ? color.new(color.red, 92) :
     na
)

//====================================================
// Data Window
//====================================================

plot(bullSum, title="Bull Sum", display=display.data_window)
plot(bearSum, title="Bear Sum", display=display.data_window)
````

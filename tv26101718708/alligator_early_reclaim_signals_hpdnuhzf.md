# ALLIGATOR Early Reclaim Signals

- url: https://www.tradingview.com/script/HpdNuHzf-ALLIGATOR-Early-Reclaim-Signals/
- type: indicator
- pine_id: PUB;dc8b4847cfcd405ea5139f3a898064e6
- version: 1.0

## Description

[image]https://www.tradingview.com/x/8B92xe3g/[/image]

[b]Early Trend Shift Alerts Based on Alligator Structure[/b]
Early trend-shift alerts based on modified Alligator structure and price reclaim/rejection of the Teeth line.

Alligator Reclaim Signals is a simple trend-structure and price-reclaim indicator based on a modified Alligator-style moving average system.

The indicator plots three dynamic lines inspired by the traditional Alligator concept:

- Jaw: slower baseline
- Teeth: medium structure line
- Lips: faster structure line

Instead of focusing only on trend continuation, this tool looks for potential early shift conditions when price crosses back through the Teeth line while the Alligator structure is still positioned in the opposite direction.

A bullish signal is triggered when the fast, medium, and slow lines are still arranged in a bearish structure, but price closes back above the Teeth line. This may suggest an early recovery attempt or a possible bullish reclaim.

A bearish signal is triggered when the lines are still arranged in a bullish structure, but price closes back below the Teeth line. This may suggest a potential rejection, weakness, or early bearish shift.

This makes the indicator useful for traders who want to monitor possible transition zones, pullback failures, trend shifts, or reclaim setups around the middle Alligator line.

The script also includes built-in alert conditions for both bullish and bearish signals, allowing users to create TradingView alerts when a new Buy or Sell condition appears.

Best used with:
- Trend analysis
- Pullback/reclaim setups
- Breakout confirmation
- Multi-timeframe context
- Support and resistance zones
- Volume or momentum confirmation

Inputs:

Jaw Length:
Controls the slowest structure line. Higher values make the line smoother and slower.

Teeth Length:
Controls the middle structure line used as the main reclaim/rejection trigger.

Lips Length:
Controls the fastest structure line. Lower values make it more sensitive to short-term movement.

Limitations:

- Signals can appear during choppy or sideways market conditions.
- The indicator does not include volume confirmation.
- It does not define stop loss or take profit levels.
- It is not a full trading strategy.
- The script is inspired by the Alligator concept but does not use the classic forward-shifted Williams Alligator calculation.


Important:
This indicator does not predict price movement and should not be used as a standalone trading system. Signals may appear during ranging or choppy markets. Always combine it with proper risk management and additional confirmation.

## Source Code

````pine

// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Ty_yanse

//@version=5
indicator('ALLIGATOR Early Reclaim Signals' , overlay=true)

// William Alligator
jaw_length = input(title='Jaw Length', defval=13)
teeth_length = input(title='Teeth Length', defval=8)
lips_length = input(title='Lips Length', defval=5)

jaw = ta.sma(high + low, jaw_length) / 2
teeth = ta.sma(high + low, teeth_length) / 2
lips = ta.sma(high + low, lips_length) / 2

// Buy and Sell Signals
buy_signal = lips < teeth and teeth < jaw and close[1] < teeth[1] and close > teeth
sell_signal = lips > teeth and teeth > jaw and close[1] > teeth[1] and close < teeth

// Plotting
plot(jaw, color=color.new(color.blue, 0), title='Jaw')
plot(teeth, color=color.new(color.red, 0), title='Teeth')
plot(lips, color=color.new(color.green, 0), title='Lips')

// Alert Conditions
alertcondition(buy_signal, title="Buy", message="Buy signal detected")
alertcondition(sell_signal, title="Sell", message="Sell signal detected")

// Buy and Sell Signal Labels
if buy_signal
    label.new(bar_index, low, 'Buy ', style=label.style_label_up, color=color.green)
if sell_signal
    label.new(bar_index, high, 'Sell ', style=label.style_label_down, color=color.red)
````

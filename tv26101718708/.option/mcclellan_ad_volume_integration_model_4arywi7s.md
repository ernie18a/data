# McClellan A-D Volume Integration Model

- url: https://www.tradingview.com/script/4aRyWi7S/
- type: strategy
- pine_id: PUB;ecc678e6ac8d4e24a033fe7c4e62949a
- version: 1.0

## Description

The strategy integrates the McClellan A-D Oscillator with an adjustment based on the Advance/Decline (A-D) volume data. The McClellan Oscillator is calculated by taking the difference between the short-term and long-term exponential moving averages (EMAs) of the A-D line. This strategy introduces an enhancement where the A-D volume (the difference between the advancing and declining volume) is factored in to adjust the oscillator value.

Inputs:

•	ema_short_length: The length for the short-term EMA of the A-D line.
•	ema_long_length: The length for the long-term EMA of the A-D line.
•	osc_threshold_long: The threshold below which the oscillator must drop for an entry signal to trigger.

•	exit_periods: The number of periods after which the position is closed.
•	Data Sources:
•	ad_advance and ad_decline are the data sources for advancing and declining issues, respectively.

•	vol_advance and vol_decline are the volume data for the advancing and declining issues. If volume data is unavailable, it defaults to na (Not Available), and the fallback logic ensures that the strategy continues to function.

McClellan Oscillator with Volume Adjustment:

•	The A-D line is calculated by subtracting the declining issues from the advancing issues. Then, the volume difference is applied to this line, creating a “weighted” A-D line.

•	The short and long EMAs are calculated for the weighted A-D line to generate the McClellan Oscillator.

Entry Condition:

•	The strategy looks for a reversal signal, where the oscillator falls below the threshold and then rises above it again. The condition is designed to trigger a long position when this reversal happens.

Exit Condition:

•	The position is closed after a set number of periods (exit_periods) have passed since the entry.

Plotting:

•	The McClellan Oscillator and the threshold are plotted on the chart for visual reference.
•	Entry and exit signals are highlighted with background colors to make the signals more visible.

Scientific Background:

The McClellan A-D Oscillator is a popular market breadth indicator developed by Sherman and Marian McClellan. It is used to gauge the underlying strength of a market by analyzing the difference between the number of advancing and declining stocks. The oscillator is typically calculated using exponential moving averages (EMAs) of the A-D line, with the idea being that crossovers of these EMAs indicate potential changes in the market’s direction.

The integration of A-D volume into this model adds another layer of analysis, as volume is often considered a leading indicator of price movement. By factoring in volume, the strategy becomes more sensitive to not just the number of advancing or declining stocks but also how significant those movements are based on trading volume, as discussed in Schwager, J. D. (1999). Technical Analysis of the Financial Markets. This enhanced version aims to capture stronger and more sustainable trends in the market, helping to filter out false signals.

Additionally, volume analysis is often used to confirm price movements, as described in Wyckoff, R. (1931). The Day Trading System. Therefore, incorporating the volume of advancing and declining stocks in the McClellan Oscillator offers a more robust signal for trading decisions.

## Source Code

````pine
//@version=6
strategy("McClellan A-D Volume Integration Model", overlay=false, pyramiding=0, commission_type=strategy.commission.cash_per_contract, commission_value=0.05, slippage=1)

// --- Inputs ---
ema_short_length = input.int(19, title="Short EMA Length", minval=1)
ema_long_length = input.int(38, title="Long EMA Length", minval=1)
osc_threshold_long = input.float(-96, title="Long Entry Threshold", step=1)
exit_periods = input.int(13, title="Exit After X Periods", minval=1)

// --- Data Sources ---
ad_advance = request.security("INDEX:ADVN", timeframe.period, close, lookahead=barmerge.lookahead_off)
ad_decline = request.security("INDEX:DECN", timeframe.period, close, lookahead=barmerge.lookahead_off)
vol_advance = request.security("INDEX:ADVN", timeframe.period, na, lookahead=barmerge.lookahead_off) // Fallback for unavailable volume data
vol_decline = request.security("INDEX:DECN", timeframe.period, na, lookahead=barmerge.lookahead_off)

// --- McClellan Oscillator with AD Volume Calculation ---
ad_line = ad_advance - ad_decline
ad_volume_line = na(vol_advance) or na(vol_decline) ? 1 : vol_advance - vol_decline  // Fallback if volume data is missing

// Weighted AD Line
weighted_ad_line = ad_line * ad_volume_line

// Calculate Moving Averages
ema_short = ta.ema(weighted_ad_line, ema_short_length)
ema_long = ta.ema(weighted_ad_line, ema_long_length)
mcclellan_oscillator = ema_short - ema_long

// --- Entry Conditions: Reversal Logic ---
osc_below_threshold = mcclellan_oscillator < osc_threshold_long
osc_above_threshold = mcclellan_oscillator > osc_threshold_long

long_entry_condition = not na(mcclellan_oscillator[1]) and osc_below_threshold[1] and osc_above_threshold

var float entry_bar = na  // Track the entry bar index

// Long Entry
if (long_entry_condition and strategy.position_size == 0)
    strategy.entry("Long", strategy.long)
    entry_bar := bar_index

// Exit Conditions
exit_condition = not na(entry_bar) and (bar_index - entry_bar >= exit_periods)
if (exit_condition)
    strategy.close("Long", comment="Exit Long after X periods")
    entry_bar := na

// --- Plotting ---
plot(mcclellan_oscillator, title="McClellan Oscillator with AD Volume", color=color.blue, linewidth=2)
hline(osc_threshold_long, title="Long Threshold", color=color.green, linestyle=hline.style_dotted)

// Highlight Background for Entry and Exit Signals
bgcolor(long_entry_condition ? color.new(color.green, 80) : na, title="Long Signal Highlight")
bgcolor(exit_condition ? color.new(color.red, 80) : na, title="Exit Signal Highlight")
````

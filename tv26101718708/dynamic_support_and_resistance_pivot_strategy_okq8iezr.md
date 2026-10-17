# Dynamic Support and Resistance Pivot Strategy 

- url: https://www.tradingview.com/script/OKq8iEzr/
- type: strategy
- pine_id: PUB;63e70b3081264ae2828f3cbba243c70d
- version: 1.0

## Description

The [b]Dynamic Support and Resistance Pivot Strategy[/b] is a flexible and adaptive tool designed to identify short-term support and resistance levels using the concept of price pivots.  

### Key Elements of the Strategy

[b]1. Pivot points as support and resistance levels[/b]
Pivots are significant turning points on the price chart, often marking local highs and lows where the price has reversed direction. A pivot high occurs when the price forms a local peak, while a pivot low occurs when the price forms a local trough. When a new pivot high is formed, it creates a resistance level. Conversely, when a new pivot low is formed, it creates a support level. 
The strategy continuously updates these levels as new pivots are detected, ensuring they remain relevant to the current market conditions. By identifying these price levels, the strategy dynamically adjusts to market conditions, allowing it to adapt to both trending and ranging markets, since it has a long target and can perform reversal operations.

[b]2. Entry Criteria [/b]
- Buy (Long): A long position is triggered when the price is near the support level and then crosses it from below to above. This suggests that the price has found support and may start moving upwards.
- Sell (Short): A short position is triggered when the price is near the resistance level and then crosses it from above to below. This indicates that the price may be reversing and moving downward.

[b]3. Support/Resistance distance (%) [/b]
- This parameter establishes a percentage range around the identified support and resistance level. For example, if the Support Resistance Distance is 0.4% (default), the closing price must be within a range of 0.4% above support or below the resistance to be considered "close" and trigger a trade.

[b]4. Exit criteria[/b]
- Take profit = 27 %
- Stop loss = 10 %
- Reversal if a new entry point is identified in the opposite direction

[b]5. No Repainting[/b]
- The Dynamic Support and Resistance Pivot Strategy is not subject to repainting.

[b]6. Position Sizing by Equity and risk management[/b]
- This strategy has a default configuration to operate with 35% of the equity. The stop loss is set to 10% from the entry price. This way, the strategy is putting at risk about 10% of 35% of equity, that is, around 3.5% of equity for each trade. The percentage of equity and stop loss can be adjusted by the user according to their risk management.

[b]7. Backtest results[/b]
- This strategy was subjected to backtest and operations in replay mode on **1000000MOGUSDT.P**, with the inclusion of transaction fees at 0.12% and slipagge of 5 ticks, and the past results have shown consistent profitability. Past results are no guarantee of future results. The strategy's backtest results may even be due to overfitting with past data.

[b]8. Chart Visualization[/b]
- Support and resistance levels are displayed as green (support) and red (resistance) lines.
- Pivot prices are displayed as green (pivot low) and red (pivot high) labels. 

[image]https://www.tradingview.com/x/CfCDiMMN/[/image]
In this image above, the Support/Resistance distance (%) parameter was set to 0.8.

[b]9. Default Configuration[/b]
Chart Timeframe: 1h
Pivot Lengh: 2
Support/Resistance distance (%): 0.4* 
Stop Loss: 10 %
Take Profit: 27 %
* This parameter can alternatively be set to 0.8.

[b]10. Alternative Configuration[/b]
Chart Timeframe: 20 min
Pivot Lengh: 4
Support/Resistance distance (%): 0.1 
Stop Loss: 10 %
Take Profit: 25 %

 [symbol="BYBIT:1000000MOGUSDT.P"]BYBIT:1000000MOGUSDT.P[/symbol]

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © felipemiransan

//@version=6
strategy("Dynamic Support and Resistance Pivot Strategy ", overlay=true)

// Strategy parameters
pivot_length = input.int(2, title="Pivot Length", tooltip="Pivot size to identify peaks and troughs")
support_resistance_distance = input.float(0.4, title="Support/Resistance Distance %", tooltip="Distance to consider a support or resistance level in %")

// Stop Loss and Take Profit parameters
stop_loss_pct = input.float(10.0, title="Stop Loss %", tooltip="Stop loss percentage", minval=0.1) / 100
take_profit_pct = input.float(26.0, title="Take Profit %", tooltip="Take profit percentage", minval=0.1) / 100

// Functions to identify high and low pivots
pivot_high = ta.pivothigh(high, pivot_length, pivot_length)
pivot_low = ta.pivotlow(low, pivot_length, pivot_length)

// Storing support and resistance levels
var float resistance_level = na
var float support_level = na
var float last_pivot_high = na
var float last_pivot_low = na

// Updating support and resistance based on pivots
if (not na(pivot_high))
    resistance_level := high[pivot_length]
    last_pivot_high := high[pivot_length]

if (not na(pivot_low))
    support_level := low[pivot_length]
    last_pivot_low := low[pivot_length]

// Function to check if the current price is near a support or resistance level
is_near_resistance = (not na(resistance_level)) and (close >= resistance_level * (1 - support_resistance_distance / 100)) and (close <= resistance_level * (1 + support_resistance_distance / 100))
is_near_support = (not na(support_level)) and (close >= support_level * (1 - support_resistance_distance / 100)) and (close <= support_level * (1 + support_resistance_distance / 100))

// Cross conditions variables
long_cross = ta.crossover(close, support_level) and not na(support_level)
short_cross = ta.crossunder(close, resistance_level) and not na(resistance_level)

// Entry conditions
long_condition = is_near_support and long_cross  // Buy when crossing support from below
short_condition = is_near_resistance and short_cross  // Sell when crossing resistance from above

// Order execution
if (long_condition)
    strategy.entry("Long", strategy.long)

if (short_condition)
    strategy.entry("Short", strategy.short)

// Stop Loss and Take Profit
if (strategy.opentrades > 0)
    if (strategy.position_size > 0)  // For long position
        avg_price_long = strategy.position_avg_price
        long_stop_level = avg_price_long * (1 - stop_loss_pct)
        long_take_profit_level = avg_price_long * (1 + take_profit_pct)
        strategy.exit("Exit Long", from_entry="Long", stop=long_stop_level, limit=long_take_profit_level)

    if (strategy.position_size < 0)  // For short position
        avg_price_short = strategy.position_avg_price
        short_stop_level = avg_price_short * (1 + stop_loss_pct)
        short_take_profit_level = avg_price_short * (1 - take_profit_pct)
        strategy.exit("Exit Short", from_entry="Short", stop=short_stop_level, limit=short_take_profit_level)

// Plotting support and resistance levels on the chart
plot(support_level, title="Support", color=color.green, linewidth=2, style=plot.style_line)
plot(resistance_level, title="Resistance", color=color.red, linewidth=2, style=plot.style_line)

// Adding labels to show pivot values
if (long_condition and not na(support_level))
    label.new(bar_index, low[pivot_length], str.tostring(low[pivot_length]), style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)

if (short_condition and not na(resistance_level))
    label.new(bar_index, high[pivot_length], str.tostring(high[pivot_length]), style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)
````

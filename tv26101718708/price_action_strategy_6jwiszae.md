# Price Action Strategy

- url: https://www.tradingview.com/script/6jwIsZAE/
- type: strategy
- pine_id: PUB;28b8bef80a2844359f17f6629afe077c
- version: 2.0

## Description

The [b]**Price Action Strategy**[/b] is a tool designed to capture potential market reversals by utilizing classic reversal candlestick patterns such as Hammer, Shooting Star, Doji, and Pin Bar near dinamic support and resistance levels.

[b]***Note to moderators[/b]
-	The moving average was removed from the strategy because it was not suitable for the strategy and not participating in the entry or exit criteria.  

-	The moving average length has been replaced/renamed by the support/resistance lenght.

-	The bullish engulfing and bearish engulfing patterns were also removed because in practice they were not working as entry criteria, since the candle price invariably closes far from the support/resistance level even considering the sensitivity range. There was no change in the backtest results after removing these patterns.


### Key Elements of the Strategy

[b]1. Support and Resistance Levels[/b]
   - Support and resistance are pivotal price levels where the asset has previously struggled to move lower (support) or higher (resistance). These levels act as psychological barriers where buying interest (at support) or selling interest (at resistance) often increases, potentially causing price reversals.
   - In this strategy, support is calculated as the lowest low and resistance as the highest high over a 16-period length. When the price nears these levels, it indicates possible zones for a reversal, and the strategy looks for specific candlestick patterns to confirm an entry.

[b]2. Candlestick Patterns [/b]
   - This strategy uses classic reversal patterns, including:
     - **Hammer**: Indicates a buy signal, suggesting rejection of lower prices.
     - **Shooting Star**: Suggests a sell signal, showing rejection of higher prices.
     - **Doji**: Reflects indecision and potential reversal.
     - **Pin Bar**: Represents price rejection with a long shadow, often signaling a reversal.

By combining these reversal patterns with the proximity to dinamic support or resistance levels, the strategy aims to capture potential reversal movements.

[b]3. Sensitivity Level[/b]
  - The sensitivity parameter adjusts the acceptable range (Default 0.018 = 1.8%) around support and resistance levels within which reversal patterns can trigger trades (i.e. the closing price of the candle must occur within the specified range defined by the sensitivity parameter). A higher sensitivity value expands this range, potentially leading to less accurate signals, as it may allow for more false positives.

[b]4. Entry Criteria[/b]
   - **Buy (Long)**: A Hammer, Doji, or Pin Bar pattern near support.
   - **Sell (Short)**: A Shooting Star, Doji, or Pin Bar near resistance.

[b]5. Exit criteria[/b]
- Take profit = 9.5%
- Stop loss = 16%

[b]6. No Repainting[/b]
- The Price Action Strategy is not subject to repainting.

[b]7. Position Sizing by Equity and risk management[/b]
   - This strategy has a default configuration to operate with 35% of the equity.  The stop loss is set to 16% from the entry price. This way, the strategy is putting at risk about 16% of 35% of equity, that is, around 5.6% of equity for each trade. The percentage of equity and stop loss can be adjusted by the user according to their risk management.

[b]8. Backtest results[/b]
- This strategy was subjected to deep backtest and operations in replay mode on **1000000MOGUSDT.P**, with the inclusion of transaction fees at 0.12% and slipagge of 5 ticks, and the past results have shown consistent profitability. Past results are no guarantee of future results. The strategy's backtest results may even be due to overfitting with past data.

[b]9. Chart Visualization[/b]
   -  Support and resistance levels are displayed as green (support) and red (resistance) lines. 
   - Only the candlestick pattern that generated the entry signal to triger the trade is identified and labeled on the chart. During the operation, the occurrence of new Doji, Pin Bar, Hammer and Shooting Star patterns will not be demonstrated on the chart, since the exit criteria are based on percentage take profit and stop loss.

Doji:
[image]https://www.tradingview.com/x/x00Nm9S2/[/image] 

Pin Bar and Doji
[image]https://www.tradingview.com/x/lolgcIqW/[/image] 

Shooting Star and Doji
[image]https://www.tradingview.com/x/3LRhUE7P/[/image] 

Hammer
[image]https://www.tradingview.com/x/9YIh1PSh/[/image] 


[b]10. Default settings[/b]
Chart timeframe: 20 min
Moving average lenght: 16
Sensitivity: 0.018
Stop loss (%): 16
Take Profit (%): 9.5

[symbol="BYBIT:1000000MOGUSDT.P"]BYBIT:1000000MOGUSDT.P[/symbol]

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © felipemiransan

//@version=5
strategy("Price Action Strategy", overlay=true)

// Settings
length = input.int(16, title="Support and Resistance Length")
sensitivity = input.float(0.018, title="Sensitivity")

// Stop Loss and Take Profit
stop_loss_pct = input.float(16, title="Stop Loss percentage", minval=0.1) / 100
take_profit_pct = input.float(9.5, title="Take Profit percentage", minval=0.1) / 100

// Function to identify a Hammer
isHammer() =>
    body = close - open
    price_range = high - low
    lower_shadow = open - low
    upper_shadow = high - close
    body > 0 and lower_shadow > body * 2 and upper_shadow < body * 0.5 and price_range > 0

// Function to identify a Shooting Star
isShootingStar() =>
    body = open - close
    price_range = high - low
    lower_shadow = close - low
    upper_shadow = high - open
    body > 0 and upper_shadow > body * 2 and lower_shadow < body * 0.5 and price_range > 0

// Function to identify a Doji
isDoji() =>
    body = close - open
    price_range = high - low
    math.abs(body) < (price_range * 0.1)  // Doji has a small body

// Function to identify a Pin Bar
isPinBar() =>
    body = close - open
    price_range = high - low
    lower_shadow = open - low
    upper_shadow = high - close
    (upper_shadow > body * 2 and lower_shadow < body * 0.5) or (lower_shadow > body * 2 and upper_shadow < body * 0.5)

// Support and resistance levels 
support = ta.lowest(low, length)
resistance = ta.highest(high, length)

// Entry criteria
long_condition = (isHammer() or isDoji() or isPinBar()) and close <= support * (1 + sensitivity)
short_condition = (isShootingStar() or isDoji() or isPinBar()) and close >= resistance * (1 - sensitivity)

// Function to calculate stop loss and take profit (long)
calculate_levels(position_size, avg_price, stop_loss_pct, take_profit_pct) =>
    stop_loss_level = avg_price * (1 - stop_loss_pct)
    take_profit_level = avg_price * (1 + take_profit_pct)
    [stop_loss_level, take_profit_level]

// Function to calculate stop loss and take profit (short)
calculate_levels_short(position_size, avg_price, stop_loss_pct, take_profit_pct) =>
    stop_loss_level = avg_price * (1 + stop_loss_pct)
    take_profit_level = avg_price * (1 - take_profit_pct)
    [stop_loss_level, take_profit_level]

// Buy entry order with label
if (long_condition and strategy.opentrades == 0)
    strategy.entry("Buy", strategy.long)
    pattern = isHammer() ? "Hammer" : isDoji() ? "Doji" : isPinBar() ? "Pin Bar" : ""
    label.new(x=bar_index, y=low, text=pattern, color=color.green, textcolor=color.black, size=size.small)

// Sell entry order with label
if (short_condition and strategy.opentrades == 0)
    strategy.entry("Sell", strategy.short)
    pattern = isShootingStar() ? "Shooting Star" : isDoji() ? "Doji" : isPinBar() ? "Pin Bar" : ""
    label.new(x=bar_index, y=high, text=pattern, color=color.red, textcolor=color.black, size=size.small)

// Stop Loss and Take Profit management for open positions
if (strategy.opentrades > 0)
    if (strategy.position_size > 0)  // Long position
        avg_price_long = strategy.position_avg_price  // Average price of long position
        [long_stop_level, long_take_profit_level] = calculate_levels(strategy.position_size, avg_price_long, stop_loss_pct, take_profit_pct)
        strategy.exit("Exit Long", from_entry="Buy", stop=long_stop_level, limit=long_take_profit_level)
    if (strategy.position_size < 0)  // Short position
        avg_price_short = strategy.position_avg_price  // Average price of short position
        [short_stop_level, short_take_profit_level] = calculate_levels_short(strategy.position_size, avg_price_short, stop_loss_pct, take_profit_pct)
        strategy.exit("Exit Short", from_entry="Sell", stop=short_stop_level, limit=short_take_profit_level)

// Visualization of Support and Resistance Levels
plot(support, title="Support", color=color.green, linewidth=2)
plot(resistance, title="Resistance", color=color.red, linewidth=2)
````

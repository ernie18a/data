# Grim Slash

- url: https://www.tradingview.com/script/XCHxly8L-Grim-Slash/
- type: strategy
- pine_id: PUB;ffdb1ffe3c7b4e2c994b36c80aa874b2
- version: 1.0

## Description

Overview:
The Touch Previous Candle Strategy is a simple yet effective trading approach designed for the 1-hour chart. It focuses on price action by placing trades when the current candle interacts with key levels from the previous candle. The strategy is fully automated and includes risk management with take profit and stop loss levels.

Entry Conditions:

  
[list]
[*]  Buy Signal: A buy order is triggered when the low of the current candle touches or drops below the previous candle's closing price.
[*]    Sell Signal: A position is closed when the high of the current candle reaches or exceeds the previous candle's highest price.
[/list]

Risk Management:

 
[list]
[*]   Take Profit: The trade is exited automatically when the price increases by 15% from the entry point.
[*]    Stop Loss: A stop loss is set at 5% below the entry price to minimize risk.
[/list]

Best Use Cases:

 
[list]
[*]   Works well in volatile markets where price frequently tests previous levels.
[*]    Suitable for traders who prefer price-action-based strategies over indicators.
[*]    Can be optimized for different assets or timeframes based on market behavior.
[/list]

## Source Code

````pine
//@version=5
strategy("Touch Previous Candle Strategy", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

// Define previous candle values
prevClose = ta.valuewhen(bar_index > bar_index[1], close[1], 0)
prevHigh = ta.valuewhen(bar_index > bar_index[1], high[1], 0)

// Define buy and sell conditions
buyCondition = low <= prevClose // Buy when the current candle touches the previous close
sellCondition = high >= prevHigh // Sell when the current candle touches the previous high

// Define take profit and stop loss levels
takeProfit = strategy.position_avg_price * 1.15 // 15% take profit
stopLoss = strategy.position_avg_price * 0.95  // 5% stop loss

// Execute buy order if the condition is met
if (buyCondition)
    strategy.entry("Buy", strategy.long)

// Execute sell order if the condition is met
if (sellCondition)
    strategy.close("Buy")

// Set stop loss and take profit
strategy.exit("TakeProfit", from_entry = "Buy", limit = takeProfit, stop = stopLoss)
````

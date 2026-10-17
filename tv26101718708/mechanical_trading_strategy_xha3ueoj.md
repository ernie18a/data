# Mechanical Trading Strategy

- url: https://www.tradingview.com/script/xha3uEoj-Mechanical-Trading-Strategy/
- type: strategy
- pine_id: PUB;0c738a0594a74b33ba08591d4265e17a
- version: 7.0

## Description

The "Mechanical Trading Strategy" is a simple and systematic approach to trading that aims to capture short-term price movements in the financial markets. This strategy focuses on executing trades based on specific conditions and predetermined profit targets and stop loss levels.

Key Features:

Profit Target: The strategy allows you to set a profit target as a percentage of the entry price. This target represents the desired level of profit for each trade.
Stop Loss: The strategy incorporates a stop loss level as a percentage of the entry price. This level represents the maximum acceptable loss for each trade, helping to manage risk.
Entry Condition: The strategy triggers trades at a specific time. In this case, the condition for entering a trade is based on the hour of the candle being 16 (4:00 PM). This time-based entry condition provides a systematic approach to executing trades.
Position Sizing: The strategy determines the position size based on a fixed percentage of the available equity. This approach ensures consistent risk management and allows for potential portfolio diversification.
Execution:
When the entry condition is met, signified by the hour being 16, the strategy initiates a long position using the strategy.entry function. It sets the exit conditions using the strategy.exit function, with a limit order for the take profit level and a stop order for the stop loss level.

Take Profit and Stop Loss:
The take profit level is calculated by adding a percentage of the entry price to the entry price itself. This represents the profit target for the trade. Conversely, the stop loss level is calculated by subtracting a percentage of the entry price from the entry price. This level represents the maximum acceptable loss for the trade.

By using this mechanical trading strategy, traders can establish a disciplined and systematic approach to their trading decisions. The predefined profit target and stop loss levels provide clear exit rules, helping to manage risk and potentially maximize returns. However, it is important to note that no trading strategy is guaranteed to be profitable, and careful analysis and monitoring of market conditions are always recommended.

## Source Code

````pine
//@version=5
strategy("Mechanical Trading Strategy", overlay=true)


profitTarget = input(0.4, "Profit Target (%)") / 100
stopLoss = input(0.2, "Stop Loss (%)") / 100
tradeHour = input(16, "Enter Hour you want to trade every day")
isShort = input(false, "check this box if you want to test short/selling trade")


entryPrice = close


if (hour(time) == tradeHour)
    if(isShort)
        takeProfitLevel = entryPrice - (entryPrice * profitTarget)
        stopLossLevel =  entryPrice + (entryPrice * stopLoss)
        strategy.entry("Sell", strategy.short)
        strategy.exit("Take Profit", "Sell", limit=takeProfitLevel,stop = stopLossLevel)
    else
        takeProfitLevel = entryPrice + (entryPrice * profitTarget)
        stopLossLevel =  entryPrice - (entryPrice * stopLoss)
        strategy.entry("Buy", strategy.long)
        strategy.exit("Take Profit", "Buy", limit=takeProfitLevel,stop = stopLossLevel)
````

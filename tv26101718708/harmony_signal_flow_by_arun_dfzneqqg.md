# Harmony Signal Flow By Arun

- url: https://www.tradingview.com/script/DfznEQqg-Harmony-Signal-Flow-By-Arun/
- type: strategy
- pine_id: PUB;3e796dce88814c61ae5655b172282c5a
- version: 1.0

## Description

This Pine Script strategy, titled "Harmony Signal Flow By Arun," uses the Relative Strength Index (RSI) indicator to generate buy and sell signals based on custom thresholds. The script incorporates stop-loss and target management and restricts new trades until the previous position closes. Here's a detailed description:
Custom RSI Metric:

The strategy calculates a 5-period RSI based on the closing price, aiming for a more responsive measure of price momentum.
RSI thresholds are defined:
Lower threshold (30): Indicates oversold conditions, triggering a potential buy.
Upper threshold (70): Indicates overbought conditions, prompting a possible sell.
Entry Conditions:

Buy Signal: The strategy initiates a buy order when the RSI crosses above the lower threshold (30), indicating a shift from oversold conditions.
Sell Signal: A sell order is triggered when the RSI crosses below the upper threshold (70), suggesting an overbought reversal.
Only one order (buy or sell) can be active at a time, ensuring that a new trade begins only when there’s no existing position.
Stop-Loss and Target Management:

For each trade, stop-loss and target conditions are applied to manage risk and secure profits.
For Buy Positions:
Stop-loss is set 100 points below the entry price.
Target is set 150 points above the entry price.
For Sell Positions:
Stop-loss is set 100 points above the entry price.
Target is 150 points below the entry price.
The strategy closes the trade when either the stop-loss or target is met, marking the trade as "closed" and allowing a new trade entry.
Trade Sequencing:

A new trade (buy or sell) is only permitted after the previous position hits either its stop-loss or target, preventing overlapping trades and ensuring clear trade sequences.
This sequential approach enhances risk management by ensuring only one active position at any time.
End-of-Day Closure:

All open positions are closed automatically at 3:25 PM (Indian market time) to avoid overnight exposure, ensuring the strategy remains strictly intraday.
The flag for trade entry is reset at the end of each day, enabling fresh trades the next day.
Chart Indicators:

The script plots buy and sell signals directly on the chart with visible labels.
It also displays the custom RSI metric with horizontal lines for the lower and upper thresholds, providing visual cues for entry and exit points.
Summary
This strategy is a momentum-based intraday trading approach that uses the RSI for identifying potential reversals and manages trades through predefined stop-loss and target levels. By enforcing trade sequencing and closing positions at the end of the trading day, it prioritizes risk management and seeks to capitalize on short-term trends while avoiding overnight market risks.

## Source Code

````pine
//@version=5
strategy("Harmony Signal Flow By Arun", overlay=true)

// Custom metric settings
periodLength = input(5, title="RSI Period Length")  // Changed period to 5 for sensitivity
priceSource = close
customMetric = ta.rsi(priceSource, periodLength)  // Calculated custom metric

// Define threshold levels (generalized names)
lowerThreshold = input(30, title="Lower Threshold")
upperThreshold = input(70, title="Upper Threshold")

// Buy signal: customMetric crosses above lowerThreshold
buyCondition = ta.crossover(customMetric, lowerThreshold)

// Sell signal: customMetric crosses below upperThreshold
sellCondition = ta.crossunder(customMetric, upperThreshold)

// Stop-loss and target levels
buyStopLoss = input(100, title="Buy Stop-Loss")
buyTarget = input(150, title="Buy Target")
sellStopLoss = input(100, title="Sell Stop-Loss")
sellTarget = input(150, title="Sell Target")

// Initialize variables to check if target/stop-loss is hit
var bool tradeClosed = true  // Flag to allow a new trade only after closing the previous one

// Ensure only one order at a time, and only if previous trade is closed
if (strategy.position_size == 0 and tradeClosed) // No open positions and last trade closed
    if (buyCondition)
        strategy.entry("Buy", strategy.long)
        tradeClosed := false  // Mark trade as active
    else if (sellCondition)
        strategy.entry("Sell", strategy.short)
        tradeClosed := false  // Mark trade as active

// Manage stop-loss and target for buy position
if (strategy.position_size > 0) // Open buy position
    float stopLossBuy = strategy.position_avg_price - buyStopLoss
    float targetBuy = strategy.position_avg_price + buyTarget

    if (close <= stopLossBuy)
        strategy.close("Buy", comment="Stoploss Hit")
        tradeClosed := true  // Allow next trade
    else if (close >= targetBuy)
        strategy.close("Buy", comment="Target Hit")
        tradeClosed := true  // Allow next trade

// Manage stop-loss and target for sell position
if (strategy.position_size < 0) // Open sell position
    float stopLossSell = strategy.position_avg_price + sellStopLoss
    float targetSell = strategy.position_avg_price - sellTarget

    if (close >= stopLossSell)
        strategy.close("Sell", comment="Stoploss Hit")
        tradeClosed := true  // Allow next trade
    else if (close <= targetSell)
        strategy.close("Sell", comment="Target Hit")
        tradeClosed := true  // Allow next trade

// Close all positions by 3:25 PM
if (hour(timenow) == 15 and minute(timenow) == 25)
    strategy.close_all(comment="Close all positions at 3:25 PM")
    tradeClosed := true  // Reset for next day trades

// Plot buy/sell signals on the chart
plotshape(buyCondition, title="Buy Signal", location=location.belowbar, color=color.green, style=shape.labelup, text="BUY")
plotshape(sellCondition, title="Sell Signal", location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL")

// Plot custom metric and thresholds
hline(lowerThreshold, "Lower Threshold", color=color.green)
hline(upperThreshold, "Upper Threshold", color=color.red)
plot(customMetric, "Custom Metric", color=color.blue)
````

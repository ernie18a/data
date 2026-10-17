# RSI Strategy with Adjustable RSI and Stop-Loss

- url: https://www.tradingview.com/script/7IkeEBsE/
- type: strategy
- pine_id: PUB;1caedfb1a5164f4c9a15c5988523aa54
- version: 1.0

## Description

This trading strategy uses the Relative Strength Index (RSI) and a Stop-Loss mechanism to make trading decisions. Here’s a breakdown of how it works:

    RSI Calculation:
        The RSI is calculated based on the user-defined length (rsi_length). This is a momentum oscillator that measures the speed and change of price movements.

    Buy Condition:
        The strategy generates a buy signal when the RSI value is below a user-defined threshold (rsi_threshold). This condition indicates that the asset might be oversold and potentially due for a rebound.

    Stop-Loss Mechanism:
        Upon triggering a buy signal, the strategy calculates the Stop-Loss level. The Stop-Loss level is set to a percentage below the entry price, as specified by the user (stop_loss_percent). This level is used to limit potential losses if the price moves against the trade.

    Sell Condition:
        A sell signal is generated when the current closing price is higher than the highest high of the previous day. This condition suggests that the price has reached a new high, and the strategy decides to exit the trade.

    Plotting:
        The RSI values are plotted on the chart for visual reference. A horizontal line is drawn at the RSI threshold level to help visualize the oversold condition.

Summary

    Buying Strategy: When RSI is below the specified threshold, indicating potential oversold conditions.
    Stop-Loss: Set based on a percentage of the entry price to limit potential losses.
    Selling Strategy: When the price surpasses the highest high of the previous day, signaling a potential exit point.

This strategy aims to capture potential rebounds from oversold conditions and manage risk using a Stop-Loss mechanism. As with any trading strategy, it’s essential to test and optimize it under various market conditions to ensure its effectiveness.

## Source Code

````pine
//@version=5
strategy("RSI Strategy with Adjustable RSI and Stop-Loss", overlay=false, 
         default_qty_type=strategy.fixed, default_qty_value=2, 
         initial_capital=10000, pyramiding=2, 
         commission_type=strategy.commission.percent, commission_value=0.05,
         slippage=1)

// Input fields for RSI parameters
rsi_length = input.int(8, title="RSI Length", minval=1)
rsi_threshold = input.float(28, title="RSI Threshold", minval=1, maxval=50)

// Input for Stop-Loss percentage
stop_loss_percent = input.float(5, title="Stop-Loss Percentage", minval=0.1, maxval=100)

// Calculate the RSI
rsi = ta.rsi(close, rsi_length)

// Condition for buying: RSI below the defined threshold
buyCondition = rsi < rsi_threshold

// Condition for selling: Close price higher than yesterday's high
sellCondition = close > ta.highest(high, 1)[1]

// Calculate the Stop-Loss level based on the entry price
var float stop_loss_level = na

if (buyCondition)
    stop_loss_level := close * (1 - stop_loss_percent / 100)
    strategy.entry("Long", strategy.long)
    // Create Stop-Loss order
    strategy.exit("Stop-Loss", from_entry="Long", stop=stop_loss_level)

// Selling signal
if (sellCondition)
    strategy.close("Long")

// Optional: Plot the RSI for visualization
plot(rsi, title="RSI", color=color.blue)
hline(rsi_threshold, "RSI Threshold", color=color.red)
````

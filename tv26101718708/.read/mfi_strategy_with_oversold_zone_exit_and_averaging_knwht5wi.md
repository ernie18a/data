# MFI Strategy with Oversold Zone Exit and Averaging

- url: https://www.tradingview.com/script/KnwhT5wI-MFI-Strategy-with-Oversold-Zone-Exit-and-Averaging/
- type: strategy
- pine_id: PUB;b197c63fe9d14fa1bdb14107701e9ddf
- version: 1.0

## Description

This strategy is based on the Money Flow Index (MFI) and aims to enter a long position when the MFI exits an oversold zone, with specific rules for limit orders, stop-loss, and take-profit settings. Here's a detailed breakdown:

Key Components
1. **Money Flow Index (MFI)**: The strategy uses the MFI, a volume-weighted indicator, to gauge whether the market is in an oversold condition (default threshold of MFI < 20). Once the MFI rises above the oversold threshold, it signals a potential buying opportunity.

2. **Limit Order for Long Entry**: Instead of entering immediately after the oversold condition is cleared, the strategy places a limit order at a price slightly below the current price (by a user-defined percentage). This helps achieve a better entry price.

3. **Stop-Loss and Take-Profit**: 
   - **Stop-Loss**: A stop-loss is set to protect against significant losses, calculated as a percentage below the entry price.
   - **Take-Profit**: A take-profit target is set as a percentage above the entry price to lock in gains.

4. **Order Cancellation**: If the limit order isn’t filled within a specific number of bars (default is 5 bars), it’s automatically canceled to avoid being filled at a potentially suboptimal price as market conditions change.

Strategy Workflow
1. **Identify Oversold Zone**: The strategy checks if the MFI falls below a defined oversold level (default is 20). Once this condition is met, the flag `inOversoldZone` is set to `true`.

2. **Wait for Exit from Oversold Zone**: When the MFI rises back above the oversold level, it’s considered a signal that the market is potentially recovering, and the strategy prepares to enter a position.

3. **Place Limit Order**: Upon exiting the oversold zone, the strategy places a limit order for a long position at a price below the current price, defined by the `Long Entry Percentage` parameter.

4. **Monitor Limit Order**: A counter (`barsSinceEntryOrder`) starts counting the bars since the limit order was placed. If the order isn’t filled within the specified number of bars, it’s canceled automatically.

5. **Set Stop-Loss and Take-Profit**: Once the order is filled, a stop-loss and take-profit are set based on user-defined percentages relative to the entry price.

6. **Exit Strategy**: The trade will close automatically when either the stop-loss or take-profit level is hit.

Advantages
- **Risk Management**: With configurable stop-loss and take-profit, the strategy ensures losses are limited while capturing profits at pre-defined levels.
- **Controlled Entry**: The use of a limit order below the current price helps secure a better entry point, enhancing risk-reward.
- **Oversold Exit Trigger**: Using the exit from an oversold zone as an entry condition can help catch reversals.

Disadvantages
- **Missed Entries**: If the limit order isn’t filled due to insufficient downward movement after the oversold signal, potential opportunities may be missed.
- **Dependency on MFI Sensitivity**: As the MFI is sensitive to both price and volume, its fluctuations might not always accurately represent oversold conditions.

Overall Purpose
The strategy is suited for traders who want to capture potential reversals after oversold conditions in the market, with a focus on precise entries, risk management, and an automated exit plan.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © traderhub

//@version=5
strategy("MFI Strategy with Oversold Zone Exit and Averaging", overlay=true, margin_long=100, default_qty_type=strategy.percent_of_equity, default_qty_value=10)

// Strategy parameters
mfiPeriod = input.int(title="MFI Period", defval=14) // Period for calculating MFI
mfiOS = input.float(title="MFI Oversold Level", defval=20.0) // Oversold level for MFI
longEntryPercentage = input.float(title="Long Entry Percentage (%)", minval=0.0, step=0.1, defval=0.1) // Percentage for the buy limit order
stopLossPercentage = input.float(title="Stop Loss Percentage (%)", minval=0.0, step=0.1, defval=1.0) // Percentage for the stop-loss
exitGainPercentage = input.float(title="Exit Gain Percentage (%)", minval=0.0, step=0.1, defval=1.0) // Percentage gain for the take-profit
cancelAfterBars = input.int(title="Cancel Order After # Bars", minval=1, defval=5) // Cancel order after a certain number of bars

// Calculate MFI
mfi = ta.mfi(close, mfiPeriod)  // MFI with specified period

// Variables for tracking state
var bool inOversoldZone = false  // Flag for being in the oversold zone
var float longEntryPrice = na  // Price for long entry
var int barsSinceEntryOrder = na  // Counter for bars after placing an order

// Define being in the oversold zone
if (mfi < mfiOS)
    inOversoldZone := true  // Entered oversold zone

// Condition for exiting the oversold zone and placing a limit order
if (inOversoldZone and mfi > mfiOS)
    inOversoldZone := false  // Leaving the oversold zone
    longEntryPrice := close * (1 - longEntryPercentage / 100)  // Calculate limit price for entry
    strategy.entry("Long Entry", strategy.long, limit=longEntryPrice)  // Place a limit order
    barsSinceEntryOrder := 0  // Reset counter for bars after placing the order

// Increase the bar counter if the order has not yet been filled
if (not na(barsSinceEntryOrder))
    barsSinceEntryOrder += 1

// Cancel order if it hasn’t been filled within the specified number of bars
if (not na(barsSinceEntryOrder) and barsSinceEntryOrder >= cancelAfterBars and strategy.position_size == 0)
    strategy.cancel("Long Entry")
    barsSinceEntryOrder := na  // Reset bar counter

// Set stop-loss and take-profit for filled positions
if (strategy.position_size > 0)
    stopLossPrice = longEntryPrice * (1 - stopLossPercentage / 100)  // Calculate stop-loss level
    takeProfitPrice = longEntryPrice * (1 + exitGainPercentage / 100)  // Calculate take-profit level
    strategy.exit("Exit Long", from_entry="Long Entry", limit=takeProfitPrice, stop=stopLossPrice)

// Visualize oversold and overbought zones
bgcolor(mfi < mfiOS ? color.new(color.green, 90) : na)  // Background in oversold zone
plot(mfi, title="MFI", color=color.blue)  // MFI plot
hline(mfiOS, "Oversold Level", color=color.red)  // Oversold level line
````

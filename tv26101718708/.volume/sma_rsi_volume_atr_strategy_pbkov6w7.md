# SMA + RSI + Volume + ATR Strategy

- url: https://www.tradingview.com/script/pBKov6w7-SMA-RSI-Volume-ATR-Strategy/
- type: strategy
- pine_id: PUB;0ffec96eee8745eea5932f985b7498f9
- version: 1.0

## Description

SMA + RSI + Volume + ATR Strategy
1. Indicators Used:
SMA (Simple Moving Average): This is a trend-following indicator that calculates the average price of a security over a specified period (50 periods in this case). It's used to identify the overall trend of the market.
RSI (Relative Strength Index): This measures the speed and change of price movements. It tells us if the market is overbought (too high) or oversold (too low). Overbought is above 70 and oversold is below 30.
Volume: This is the amount of trading activity. A higher volume often indicates strong interest in a particular price move.
ATR (Average True Range): This measures volatility, or how much the price is moving in a given period. It helps us adjust stop losses and take profits based on market volatility.
2. Conditions for Entering Trades:
Buy Signal (Green Up Arrow):
Price is above the 50-period SMA (indicating an uptrend).
RSI is below 30 (indicating the market might be oversold or undervalued, signaling a potential reversal).
Current volume is higher than average volume (indicating strong interest in the move).
ATR is increasing (indicating higher volatility, suggesting that the market might be ready for a move).
Sell Signal (Red Down Arrow):
Price is below the 50-period SMA (indicating a downtrend).
RSI is above 70 (indicating the market might be overbought or overvalued, signaling a potential reversal).
Current volume is higher than average volume (indicating strong interest in the move).
ATR is increasing (indicating higher volatility, suggesting that the market might be ready for a move).
3. Take Profit & Stop Loss:
Take Profit: When a trade is made, the strategy will set a target price at a certain percentage above or below the entry price (1.5% in this case) to automatically exit the trade once that target is hit.
Stop Loss: If the price goes against the position, a stop loss is set at a percentage below or above the entry price (0.5% in this case) to limit losses.
4. Execution of Trades:
When the buy condition is met, the strategy will enter a long position (buying).
When the sell condition is met, the strategy will enter a short position (selling).
5. Visual Representation:
Green Up Arrow: Appears on the chart when the buy condition is met.
Red Down Arrow: Appears on the chart when the sell condition is met.
These arrows help you see at a glance when the strategy suggests you should buy or sell.
In Summary:
This strategy uses a combination of trend-following (SMA), momentum (RSI), volume, and volatility (ATR) to decide when to buy or sell a stock. It looks for opportunities when the market is either oversold (buy signal) or overbought (sell signal) and makes sure there’s enough volume and volatility to back up the move. It also includes take-profit and stop-loss levels to manage risk.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jbdorji
//@version=5
strategy("SMA + RSI + Volume + ATR Strategy", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=10)

// Input parameters
smaLength = input.int(50, title="SMA Length")
rsiLength = input.int(14, title="RSI Length")
rsiOverbought = input.int(70, title="RSI Overbought Level")
rsiOversold = input.int(30, title="RSI Oversold Level")
volumeThreshold = input.float(1.5, title="Volume Threshold (Multiple of Average Volume)")
atrLength = input.int(14, title="ATR Length")
atrMultiplier = input.float(1.5, title="ATR Multiplier for Stop Loss/Take Profit")
takeProfitPerc = input.float(1.5, title="Take Profit (%)")
stopLossPerc = input.float(0.5, title="Stop Loss (%)")

// Calculate indicators
sma = ta.sma(close, smaLength)
rsi = ta.rsi(close, rsiLength)
atr = ta.atr(atrLength)
avgVolume = ta.sma(volume, 20) // 20-period average volume

// Buy condition: Price above SMA, RSI below oversold, volume above threshold, and volatility filter
buyCondition = close > sma and rsi < rsiOversold and volume > avgVolume * volumeThreshold and atr > atr[1]

// Sell condition: Price below SMA, RSI above overbought, volume above threshold, and volatility filter
sellCondition = close < sma and rsi > rsiOverbought and volume > avgVolume * volumeThreshold and atr > atr[1]

// Execute trades
if (buyCondition)
    strategy.entry("Buy", strategy.long)
    strategy.exit("Take Profit/Stop Loss", "Buy", limit=close * (1 + takeProfitPerc / 100), stop=close * (1 - stopLossPerc / 100))

if (sellCondition)
    strategy.entry("Sell", strategy.short)
    strategy.exit("Take Profit/Stop Loss", "Sell", limit=close * (1 - takeProfitPerc / 100), stop=close * (1 + stopLossPerc / 100))

// Plot indicators
plot(sma, color=color.blue, title="50 SMA")
hline(rsiOverbought, "Overbought", color=color.red)
hline(rsiOversold, "Oversold", color=color.green)
plot(rsi, color=color.purple, title="RSI")
plot(atr, color=color.orange, title="ATR")

// Plot buy and sell arrows on the chart
plotarrow(buyCondition ? 1 : na, colorup=color.green, offset=-1)  // Green up arrow for buy
plotarrow(sellCondition ? -1 : na, colordown=color.red, offset=-1)  // Red down arrow for sell
````

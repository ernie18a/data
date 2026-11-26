# TrinityBar

- url: https://www.tradingview.com/script/bt3QP3Ao-TrinityBar/
- type: strategy
- pine_id: PUB;fab698c2819c43d0810d97599b9a61bb
- version: 3.0

## Description

**TrinityBar Strategy Description**

The TrinityBar strategy is a price‐action based trading model that leverages Bill Williams’ bar thirds concept to generate entry signals and execute market orders automatically. Here’s how it works:

1. **Bar Thirds Calculation:**  
   The strategy calculates the range of both the current fully formed bar and the previous fully formed bar. It then divides each bar’s range into three equal parts (thirds).  
   - For the current bar, the lower third and upper third levels are computed.
   - The same is done for the previous bar.

2. **Bar Type Classification:**  
   Each bar is classified into one of several types based on where its open and close fall relative to its thirds:  
   - **Bullish Patterns:**  
     - *1‑3 Bar:* Opens in the lower third and closes in the upper third.  
     - *2‑3 Bar:* Opens in the middle third and closes in the upper third.  
     - *3‑3 Bar:* Both open and close are in the upper third.
   - **Bearish Patterns:**  
     - *3‑1 Bar:* Opens in the upper third and closes in the lower third.  
     - *2‑1 Bar:* Opens in the middle third and closes in the lower third.  
     - *1‑1 Bar:* Both open and close are in the lower third.

3. **Signal Generation:**  
   - **Bullish Signal:** A valid buy is generated when the previous bar exhibits any bullish pattern (1‑3, 2‑3, or 3‑3) and the current bar is either a 1‑3 or a 3‑3 bar.  
   - **Bearish Signal:** A valid sell is generated when the previous bar shows any bearish pattern (1‑1, 2‑1, or 3‑1) and the current bar is either a 1‑1 or a 3‑1 bar.

4. **Visual Alerts:**  
   When a valid signal is identified, the strategy plots a small triangle below the bar for a buy signal (labeled “B” in green) and a triangle above the bar for a sell signal (labeled “S” in red).

5. **Trade Execution:**  
   Once a signal is confirmed:  
   - If a bullish signal is generated, any short positions are closed, and if there is no existing long position, a market long order is entered.  
   - Conversely, if a bearish signal occurs, any long positions are closed, and a market short order is entered if not already in a short position.

This strategy is designed to capture significant price expansions by relying solely on price action and bar structure, without relying on lagging indicators. It provides a mechanical, systematic approach that removes emotional bias from trading decisions.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BUENATURA_CAPITAL

//@version=6
strategy("Simplified TrinityBar with VWAP Filter", overlay=true, initial_capital=100000, default_qty_type=strategy.percent_of_equity, default_qty_value=50)

//--------------------------------------------------------------
// Take-Profit and Stop-Loss Inputs
//--------------------------------------------------------------
useTakeProfit   = input.bool(true, "Use Take Profit", group="Take Profit Settings")
tpMultiplier    = input.float(1.618, "Take Profit Multiplier", minval=0.1, step=0.1, group="Take Profit Settings")
useStopLoss     = input.bool(true, "Use Stop Loss", group="Stop Loss Settings")

//--------------------------------------------------------------
// Custom Daily-Resetting VWAP Calculation
//--------------------------------------------------------------
typicalPrice = (high + low + close) / 3.0
newSession   = ta.change(time("D")) != 0
var float cumTP  = na
var float cumVol = na
if newSession
    cumTP  := typicalPrice * volume
    cumVol := volume
else
    cumTP  := nz(cumTP) + typicalPrice * volume
    cumVol := nz(cumVol) + volume
vwapVal = cumTP / cumVol

//--------------------------------------------------------------
// Current Bar Thirds Calculations (using bar at index 2)
//--------------------------------------------------------------
cur_range       = high[2] - low[2]
cur_lowerThird  = low[2] + cur_range / 3.0
cur_upperThird  = high[2] - cur_range / 3.0

//--------------------------------------------------------------
// Previous Bar Thirds Calculations (using bar at index 3)
//--------------------------------------------------------------
prev_range      = high[3] - low[3]
prev_lowerThird = low[3] + prev_range / 3.0
prev_upperThird = high[3] - prev_range / 3.0

//--------------------------------------------------------------
// Define Bullish Patterns for Current Bar (index 2)
//--------------------------------------------------------------
// 1-3 Bar: opens in the lower third and closes in the upper third.
bullish1_3      = open[2] <= cur_lowerThird and close[2] >= cur_upperThird
// 3-3 Bar: both open and close are in the upper third.
bullish3_3      = open[2] >= cur_upperThird and close[2] >= cur_upperThird
// Current bar bullish pattern is valid if it is either 1-3 or 3-3.
bullish_current = bullish1_3 or bullish3_3

//--------------------------------------------------------------
// Define Bearish Patterns for Current Bar (index 2)
//--------------------------------------------------------------
// 1-1 Bar: opens and closes in the lower third.
bearish1_1      = open[2] <= cur_lowerThird and close[2] <= cur_lowerThird
// 3-1 Bar: opens in the upper third and closes in the lower third.
bearish3_1      = open[2] >= cur_upperThird and close[2] <= cur_lowerThird
// Current bar bearish pattern is valid if it is either 1-1 or 3-1.
bearish_current = bearish1_1 or bearish3_1

//--------------------------------------------------------------
// VWAP Filter Conditions:
// For Long: previous bar low < VWAP and current bar (index 2) closes above VWAP.
// For Short: previous bar high > VWAP and current bar closes below VWAP.
//--------------------------------------------------------------
buy_vwap_filter  = (low[3] < vwapVal) and (close[2] > vwapVal)
sell_vwap_filter = (high[3] > vwapVal) and (close[2] < vwapVal)

//--------------------------------------------------------------
// Valid Signal Conditions:
// - Valid Buy: current bar bullish, previous low < current low, and meets VWAP filter.
// - Valid Sell: current bar bearish, previous high > current high, and meets VWAP filter.
//--------------------------------------------------------------
validBuy  = bullish_current and low[3] < low[2] and buy_vwap_filter
validSell = bearish_current and high[3] > high[2] and sell_vwap_filter

//--------------------------------------------------------------
// Calculate Take-Profit and Stop-Loss Levels (based on bars at index 2 and 3)
//--------------------------------------------------------------
longTP   = high[2] + tpMultiplier * (high[2] - low[3])  // 1.618 extension for Long TP
shortTP  = low[2] - tpMultiplier * (high[3] - low[2])   // 1.618 extension for Short TP
longSL   = low[2]                                       // Stop-Loss for Long: low of bar at index 2
shortSL  = high[2]                                      // Stop-Loss for Short: high of bar at index 2

//--------------------------------------------------------------
// Plot Signal Triangles (on bar at index 2)
//--------------------------------------------------------------
plotshape(validBuy, title="Valid Buy", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, text="B", offset=-2)
plotshape(validSell, title="Valid Sell", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="S", offset=-2)

//--------------------------------------------------------------
// Market Order Execution Based on Signals (on current bar, index 0)
//--------------------------------------------------------------
if validBuy
    strategy.close("Short", comment="Close Short for Buy")
    if strategy.position_size <= 0
        strategy.entry("Long", strategy.long, comment="Long Entry")
        if useTakeProfit or useStopLoss
            strategy.exit("Long Exit", "Long", profit=useTakeProfit ? longTP - close : na, loss=useStopLoss ? close - longSL : na, comment="Long TP/SL Hit")

if validSell
    strategy.close("Long", comment="Close Long for Sell")
    if strategy.position_size >= 0
        strategy.entry("Short", strategy.short, comment="Short Entry")
        if useTakeProfit or useStopLoss
            strategy.exit("Short Exit", "Short", profit=useTakeProfit ? close - shortTP : na, loss=useStopLoss ? shortSL - close : na, comment="Short TP/SL Hit")
````

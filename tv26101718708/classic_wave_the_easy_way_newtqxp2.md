# Classic Wave: The Easy Way

- url: https://www.tradingview.com/script/neWTQxP2/
- type: strategy
- pine_id: PUB;a352afeab17f477ba38b9875341e2d3a
- version: 1.0

## Description

[b]Classic Wave[/b] is a simple strategy with few rules and no over-optimization. Despite its simplicity, it is backed by a nearly century-long historical track record, delivering excellent returns on the weekly chart of the [b]SPX[/b] (TVC).

I also recommend observing its strong performance on the SPY (weekly), which is the perfect instrument for executing this strategy with futures in the future.


[b]Strategy Rules and Parameters[/b]

When a bullish candle closes above the 20-period EMA, we place the stop-loss below the low of that candle and target a risk-reward ratio of 1:1.

A second, more profitable variant is to change the risk-reward ratio in the code to 2:1.

-Total capital: $10,000  

-We use 10% of the total capital per trade.  

-Commissions: 0.1% per trade.

[i]The code construction is simple and very well detailed within the script itself.[/i]


[b]Risk-Reward Ratio 2:1[/b]

Using a 2:1 risk-reward ratio reduces the win rate but significantly increases profitability.
Across the full historical data of the SPX index (weekly), the system would have generated 236 trades, with a win rate of 51.27% and a profit factor of 2.53.

From January 1, 2023, to November 28, 2025, the system would have generated 5 trades, with an 80% win rate and a profit factor of 9.244.


[b]What makes this system so good?  [/b]

-It takes advantage of the long-term bullish bias of U.S. stock indices and traditional markets.  

-It filters out a lot of noise thanks to the weekly timeframe.  

-It uses simple parameters with no over-optimization.


[b]Final Notes:[/b]

This strategy has consistently outperformed the returns offered by most traditional funds over time, with fewer drawdowns and significantly less stress. I hope you like it.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Especulador96

//@version=5
strategy("Classic Wave", overlay=true, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=10, commission_type=strategy.commission.percent, commission_value=0.1)

// --- 1. Indicator Definitions ---
ema20 = ta.ema(close, 20)

// Plot the EMA
plot(ema20, color=color.blue, linewidth=2, title="EMA 20")

// --- 2. Entry Conditions ---
// A. Bullish Candle (Close greater than Open)
isBullish = close > open

// B. Open OR Wick (Low) below the EMA 20
isBelowEMA = open < ema20 or low < ema20

// C. Close above the EMA 20
isAboveEMA = close > ema20

// Final Condition: Meets A, B, and C
longCondition = isBullish and isBelowEMA and isAboveEMA

// --- 3. Execution and Risk Management ---
if (longCondition)
    // Define prices for SL and TP based on the current candle
    float entryPrice = close
    float stopLossPrice = low
    float risk = entryPrice - stopLossPrice
    float takeProfitPrice = entryPrice + (risk * 1.0) // 1:1 Ratio

    // Enter the trade (The "Long" ID ensures multiple orders don't open on the same candle)
    strategy.entry("Long", strategy.long, comment="Entry")

    // Configure exit (Fixed SL and TP for this trade)
    strategy.exit("Long Exit", "Long", stop=stopLossPrice, limit=takeProfitPrice, comment_loss="SL", comment_profit="TP")

// --- 4. Signal Visualization ---
// Mark on the chart where the condition is met (green triangle)
plotshape(longCondition, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, title="Long Signal")
````

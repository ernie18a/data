# Camarilla R5 S5 Weekly Reversal Strategy 

- url: https://www.tradingview.com/script/Y1fkNLhv-Camarilla-R5-S5-Weekly-Reversal-Strategy/
- type: strategy
- pine_id: PUB;05a6492732ae440eac3c984f96d8066f
- version: 1.0

## Description

🏷️ Title

Camarilla R5 S5 Weekly Reversal Strategy 

📄 Short Description (Appears in Preview)

A mean reversion strategy using weekly Camarilla pivot extremes R5 and S5 with targets at R4 and S4. Designed to capture reversals from overextended price zones.

📘 Full Description (Copy-Paste Ready)
📌 Overview

This strategy is based on Camarilla Pivot Points, focusing on extreme reversal levels R5 and S5 derived from the previous week's price action.

It is designed to capture mean reversion moves when price becomes overextended and shows signs of rejection.

⚙️ How It Works

The script calculates weekly Camarilla levels using:

Previous Week High
Previous Week Low
Previous Week Close

From this, it derives key reversal zones:

R5 Extreme Resistance
R4 Target for Short Trades
S5 Extreme Support
S4 Target for Long Trades
📈 Entry Conditions
Short Entry
Price touches or moves above R5
Candle closes back below R5
Indicates rejection from extreme resistance
Long Entry
Price touches or moves below S5
Candle closes back above S5
Indicates rejection from extreme support
🎯 Exit Conditions
Short trades exit at R4
Long trades exit at S4
No stop loss is used
💡 Strategy Concept

This strategy follows a mean reversion approach:

R5 and S5 represent extreme market conditions
Price tends to revert toward equilibrium levels
Reversal probability increases at these zones
🚀 Best Use Cases
Crypto markets (BTC, ETH)
Forex pairs
Index trading

Recommended timeframes:

5 minutes
15 minutes
1 hour
📊 Advantages
Simple and rule based
Uses higher timeframe levels for strong signals
Non repaint logic based on previous weekly data
Clear entry and exit conditions
⚠️ Limitations
No stop loss included
Can underperform in strong trending markets
Requires proper risk management
⚠️ Disclaimer

This strategy is for educational purposes only.
Trading involves risk. Always test and validate before using in live markets.

## Source Code

````pine
//@version=5
strategy("Camarilla R5 S5 Extreme Reversal Strategy Weekly R4 S4 Targets No SL",
     overlay=true,
     initial_capital=100000,
     default_qty_type=strategy.fixed,
     default_qty_value=1,
     pyramiding=0)

// Previous Week
prevHigh  = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
prevLow   = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_on)
prevClose = request.security(syminfo.tickerid, "W", close[1], lookahead=barmerge.lookahead_on)

// Camarilla Levels
pivotRange = prevHigh - prevLow

R4 = prevClose + pivotRange * 1.1 / 2
R5 = prevHigh / prevLow * prevClose

S4 = prevClose - pivotRange * 1.1 / 2
S5 = prevClose - (R5 - prevClose)

// Plot
plot(R5, "R5", color=color.orange, linewidth=2)
plot(R4, "R4", color=color.red, linewidth=2)

plot(S5, "S5", color=color.orange, linewidth=2)
plot(S4, "S4", color=color.green, linewidth=2)

// Entry Conditions
sellSignal = high >= R5 and close < R5
buySignal  = low <= S5 and close > S5

if sellSignal
    strategy.entry("SELL_R5", strategy.short)

if buySignal
    strategy.entry("BUY_S5", strategy.long)

// Targets only
strategy.exit("SELL_TP", from_entry="SELL_R5", limit=R4)
strategy.exit("BUY_TP", from_entry="BUY_S5", limit=S4)
````

# Nifty Supertrend CE Strategy - Alice Blue

- url: https://www.tradingview.com/script/9EfIsXWW-Nifty-Supertrend-CE-Strategy-Alice-Blue/
- type: strategy
- pine_id: PUB;cd045681aef2461e97b29b939c276822
- version: 1.0

## Description

Supertrend-based trend-following strategy with configurable stop-loss and profit target. Designed for directional analysis and educational backtesting on NIFTY and other liquid markets.

Strategy Logic
Generates a Buy Signal when the Supertrend changes from bearish to bullish.
Closes the position when the Supertrend reverses to bearish.
Includes configurable Stop Loss and Profit Target parameters for risk management.
Suitable for intraday and short-term trend-following approaches.

Risk Disclaimer

This script is intended for educational and informational purposes only. It does not constitute investment advice or a recommendation to buy or sell any financial instrument. Market conditions can change rapidly, and past performance does not guarantee future results. Users should conduct their own analysis and apply appropriate risk management before making trading decisions.

## Source Code

````pine
//@version=6
strategy("NIFTY Supertrend CE Strategy", overlay=true)

// Inputs
atrPeriod = input.int(10, "ATR Period")
factor = input.float(3.0, "Supertrend Factor")
slPercent = input.float(15.0, "Stop Loss %")
tpPercent = input.float(30.0, "Target %")

// Supertrend
[st, dir] = ta.supertrend(factor, atrPeriod)

// Buy when Supertrend turns bullish
buySignal = dir < 0 and dir[1] > 0

// Exit when Supertrend turns bearish
exitSignal = dir > 0 and dir[1] < 0

if buySignal
    strategy.entry("LONG", strategy.long)
    alert('{"signal":"entry", "legs":["leg_1"]}')

if strategy.position_size > 0
    stopPrice = strategy.position_avg_price * (1 - slPercent / 100)
    targetPrice = strategy.position_avg_price * (1 + tpPercent / 100)
    strategy.exit("EXIT", "LONG", stop=stopPrice, limit=targetPrice)
    alert('{"signal":"exit", "legs":["leg_1"]}')

if exitSignal
    strategy.close("LONG")

plot(st, color = dir < 0 ? color.green : color.red, linewidth = 2)

plotshape(buySignal, title="BUY", style=shape.labelup, location=location.belowbar, text="BUY")
plotshape(exitSignal, title="SELL", style=shape.labeldown, location=location.abovebar, text="EXIT")
````

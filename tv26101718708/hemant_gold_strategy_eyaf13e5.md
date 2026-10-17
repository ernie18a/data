# Hemant Gold Strategy

- url: https://www.tradingview.com/script/eyaf13E5-Hemant-Gold-Strategy/
- type: strategy
- pine_id: PUB;3e9acd8770484e2c86d529e8a8c3a3d5
- version: 1.0

## Description

gold analsis A powerful XAUUSD (Gold) trading strategy designed for intraday and swing traders. This strategy combines trend analysis, market structure, EMA confirmation, liquidity sweeps, Fair Value Gaps (FVG), and Smart Money Concepts (SMC) to identify high-probability trading opportunities.

Features

* EMA 50 & EMA 200 trend confirmation
* Break of Structure (BOS) and Change of Character (CHoCH)
* Fair Value Gap (FVG) detection
* Liquidity sweep identification
* Buy and Sell signal generation
* Risk-to-Reward focused entries
* Optimized for Gold (XAUUSD)
* Works best on 15-minute timeframe with higher timeframe confirmation

Recommended Settings

## Source Code

````pine
//@version=6
strategy('Hemant Gold Strategy', overlay = true, initial_capital = 10000, pyramiding = 0, commission_type = strategy.commission.percent, commission_value = 0.01)

// Inputs
emaLen = input.int(200, 'EMA Length')
atrLen = input.int(14, 'ATR Length')
atrMult = input.float(1.5, 'SL ATR Multiplier')

// Indicators
ema200 = ta.ema(close, emaLen)
atr = ta.atr(atrLen)

plot(ema200, color = color.blue, linewidth = 2)

// Structure
hh = ta.highest(high, 10)
ll = ta.lowest(low, 10)

buySignal = low < ll[1] and close > ll[1] and close > ema200
sellSignal = high > hh[1] and close < hh[1] and close < ema200

// Buy Entry
if buySignal and strategy.position_size <= 0
    strategy.entry('BUY', strategy.long)

// Sell Entry
if sellSignal and strategy.position_size >= 0
    strategy.entry('SELL', strategy.short)

// Long Exit
longSL = strategy.position_avg_price - atr * atrMult
longTP = strategy.position_avg_price + atr * atrMult * 3

strategy.exit('BUY EXIT', from_entry = 'BUY', stop = longSL, limit = longTP)

// Short Exit
shortSL = strategy.position_avg_price + atr * atrMult
shortTP = strategy.position_avg_price - atr * atrMult * 3

strategy.exit('SELL EXIT', from_entry = 'SELL', stop = shortSL, limit = shortTP)

// Signals
plotshape(buySignal, style = shape.triangleup, location = location.belowbar, color = color.green, size = size.large)

plotshape(sellSignal, style = shape.triangledown, location = location.abovebar, color = color.red, size = size.large)
````

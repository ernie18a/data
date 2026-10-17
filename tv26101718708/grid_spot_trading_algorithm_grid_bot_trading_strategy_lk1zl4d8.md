# GRID SPOT TRADING ALGORITHM - GRID BOT TRADING STRATEGY

- url: https://www.tradingview.com/script/LK1zL4D8-GRID-SPOT-TRADING-ALGORITHM-GRID-BOT-TRADING-STRATEGY/
- type: strategy
- pine_id: PUB;702143448e8849349599db1171fbd892
- version: 6.0

## Description

[b]GRID SPOT TRADING ALGORITHM : LONG ONLY STRATEGY OPEN SOURCE[/b]

This is a long only strategy for spot assets.

[b]HOW IT WORKS[/b]
Grid trading is a trading strategy where an investor creates a so-called "price grid". The basic idea of the strategy is to repeatedly buy at the pre-specified price and then wait for the price to rise above that level and then sell the position (and vice versa with shorting or hedging). 

[b]FEATURES [/b]
[i]Grids:[/i] This algorithm has a total of 10 grids. 
[i]Take profit: [/i]The trader can increase or decrease the distance between the grids from the User Interface panel, the distance between one grid and another represents the take profit.
[i]Management: [/i]The algorithm buys 10% of the capital every time the price breaks down a grid and sells during a rise to the next higher grid. The initial capital is invested in 10 sizes which represent 10% of the capital per trade. 
[i]Stop Loss:[/i] The algorithm knows no stop loss as long as it is not activated from the User Interface panel. By activating the stop loss from the User Interface panel the algorithm will insert a close condition on all trades which will be calculated from the last lower grid. 
[i]Trades: [/i]Trades are opened only if the price is within the grid. If the market leaves the grid the algorithm will not buy new positions or sell new positions.
[i]Optimal market conditions:[/i] The favorable market for this algorithm is the sideways market.

[b]LIMITATIONS OF THE MODEL [/b]
The trader must take into account that this is a static model. It only works perfectly well if the market is in a sideways phase and incurs heavy losses if the market takes a downward trend. The model is unusable for an uptrend. The trader must therefore carefully analyze the market where he intends to use this strategy, making sure that the price is in a sideways phase.  

[b]USES[/b]
Indispensable research and backtesting tool for those using bots for their investments. The algorithm produces a backtesting of the strategy for past history. It is used by professional traders to understand if this strategy has been profitable on a market and what parameters to use for bots using this strategy (Kucoin, Binance etc.).

If you would like to develop your own algorithm with customized conditions based on a grid strategy, please contact us. 

If you need help in using this tool, please contact us without hesitation.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © thequantscience

//@version=5
strategy(
     title = 'Grid Spot Trading Algorithm [DEPRECATED] - The Quant Science', 
     overlay = false,
     calc_on_every_tick = true,
     initial_capital = 10000, 
     commission_type = strategy.commission.percent, 
     commission_value = 0.10, 
     pyramiding = 20,
     default_qty_type = strategy.percent_of_equity,
     close_entries_rule = 'ANY'
     )

plot(close)
````

# RSI SMA Crossover Strategy

- url: https://www.tradingview.com/script/ZINSYeR8-RSI-SMA-Crossover-Strategy/
- type: strategy
- pine_id: PUB;b7e4b2f94f8e448d81e3158612825e00
- version: 1.0

## Description

[b]Overview[/b]

RSI SMA Crossover Strategy works the same way as traditional MA crossover strategies, but using RSI instead of price. When RSI crosses over the SMA, a long position is opened (buy). When RSI crosses under the SMA, the long position is closed (sell). 

This strategy can be very effective when the right inputs are used (see below). Be sure to use the backtesting tool to determine the optimal parameters for a given asset/timeframe. 

[b]Inputs/Parameters[/b]

RSI Length: length for RSI calculation (default = 50)
SMA Length: length for SMA calculation (default = 25)

[b]Strategy Properties[/b]

Initial Capital = $1000

No default properties are defined for Slippage, Commission, etc, so be sure to set these values to get accurate backtesting results. This script is being published open-source for a reason - save yourself a copy and adjust the settings as you like!

[b]Backtesting Results[/b]

Testing on Bitcoin (all time index) 1D chart, with all default parameters. 
$1,000 initial investment on 10/07/2010 turns into almost $2.5 billion as of 08/30/2022 (compared to $334 million if the initial investment was held over the same period)
[image]https://www.tradingview.com/x/TiCnaGeT/[/image]

Remember, results can vary greatly based on the variables mentioned above, so always be sure to backtest.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © reees
//
//@version=5
//
strategy('RSI Crossover Strategy', shorttitle='RSI Cross', default_qty_type=strategy.percent_of_equity, default_qty_value=100, initial_capital=1000, calc_on_every_tick=true)
// inputs
rsiLength = input(title='RSI Length', defval=50)
smaLength = input(title='SMA Length', defval=25)
// data/series
rsi = ta.rsi(close, rsiLength)
sma = ta.sma(rsi, smaLength)
// plot
plotColor = rsi > sma ? color.green : color.red
rsiPlot = plot(rsi, color=color.new(plotColor, 0), title='RSI')
smaPlot = plot(sma, color=color.new(color.black, 0), title='SMA')
fillColor = rsi > sma ? color.lime : color.red
fill(rsiPlot, smaPlot, color=color.new(fillColor, 75))
oversoldLine = hline(30, title='Oversold level')
overboughtLine = hline(70, title='Overbought level')
// strategy
buy = ta.crossover(rsi, sma)
sell = ta.crossunder(rsi, sma)
if buy == true
    strategy.entry('Long', strategy.long, comment='Buy')
if sell == true
    strategy.close('Long', comment='Sell')
````

# How to use Leverage in PineScript

- url: https://www.tradingview.com/script/QDOmrHmK/
- type: strategy
- pine_id: PUB;7dbfe715477b417087599b35d66a24a4
- version: 2.0

## Description

I believe there are many friends who have been confused by the leverage problem of TradingView strategy, when backtesting, it is always unable to bring its own leverage, so it is impossible to do leverage sustained compounding, this key point, and many friends are looking forward to solve. In particular, the default_qty_value = 100, where 100 is the upper limit.

Here I have used the official RSI strategy for demonstration, using the qty to place orders. Through strategy.equity, leverage and close price, and rounding, directly calculate the specific number of contracts need to be opened.

I hope you can enjoy solving the leverage problem, and I look forward to your pointing out my problems and shortcomings to me. Thank you.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RingsCherrY

//@version=5
leverage = input.int(2,title='Leverage',minval = 1, maxval = 100 ,step = 1)

// As the margin here must be a constant, can not be a variable
// so in adjusting the leverage at the same time you need to adjust the margin in the settings or source code at the same time
// initially set to 80% margin rate that burst
// 1./2*80  2 == leverage, 80 == margin rate that burst
strategy("How to use Leverage in PineScript", overlay=true, pyramiding=1, initial_capital=1000000, default_qty_type=strategy.percent_of_equity, default_qty_value=100, calc_on_order_fills=false, slippage=0, commission_type=strategy.commission.percent, commission_value=0.04,margin_long = 1./2*80,margin_short = 1./2*80)

//////////////////////////////////////////
////////////////Indicators////////////////
//////////////////////////////////////////

length = input( 14 )
overSold = input( 30 )
overBought = input( 70 )
price = close
vrsi = ta.rsi(price, length)
co = ta.crossover(vrsi, overSold)
cu = ta.crossunder(vrsi, overBought)

//////////////////////////////////////////
/////////////////Leverage/////////////////
//////////////////////////////////////////


//The number of decimal places for each position opening, i.e., the accuracy
precision = input.int(1,title='Precision')

//Leverage, the default is 1, here is not recommended to open a high leverage


//Calculate the number of open contracts, here using equity for calculation, considering that everyone compound interest is used for trading equity
Lev = math.max(math.round(strategy.equity * leverage  / close , precision), 0)

if (not na(vrsi))
	if (co)
		strategy.entry("RsiLE", strategy.long,qty = Lev, comment="RsiLE")
	if (cu)
		strategy.entry("RsiSE", strategy.short,qty = Lev, comment="RsiSE")
//plot(strategy.equity, title="equity", color=color.red, linewidth=2, style=plot.style_areabr)
````

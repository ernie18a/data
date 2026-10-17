# IFR2

- url: https://www.tradingview.com/script/UD0anrUb/
- type: strategy
- pine_id: PUB;TqHwyBpwoa5eEun4ivjvcn37AY3jFDPi
- version: 8.0

## Description

The IFR2 strategy is based on the RSI indicator.

If the two period RSI is less than the overbought level (25 is the default, but you can configure it to be lower), a long position is placed at the close of the candle. If you are doing it live, you'd have to enter the market ~ 10 minutes before it closes, check the RSI, and buy if it is lower than your overbought level. This generates a discrepancy in the backtesting, but since it is a very small difference, it can be disregarded. Higher overbought levels generate more signals, but they mostly are unreliable. Lower values generates better yields, but they won't occur very often. This strategy is designed to be used in a daily graph, and I don't recommend using it in intraday periods, since you'll make too little money to compensate for the operational cost.

The strategy exits when the high price of two previous candles is reached. If the exit price is higher than the closing price of when you entered, you'll be at a profit, otherwise you'll be at a loss. The exit price is plotted in the graph and it's colors depends on the current open profit: positive values will be green, negative will be red.

This strategy completely disregards the current trend. Long orders will be placed even if you are at a strong down trend. This may seem odd, but you have to keep in mind that [b]this is a volatility based strategy[/b], not a trend following one.

This setup was designed by Alexandre Wolwacz, a.k.a. Stormer.

## Source Code

````pine
//@version=4
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Coded by Eduardo Mattje

strategy("IFR2", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=100, initial_capital=50000, process_orders_on_close=true)

// Inputs

var I_OVERSOLD = input(25, "RSI oversold level", minval=1, maxval=100, tooltip="The entry will occur when the RSI is bellow this value.", group="Basic settings")
var I_CANDLE_LOOKBACK = input(2, "Exit lookback", minval=1, tooltip="If you leave it at 2, the target will be calculated using the highest of the last 2 candles.", group="Basic settings")
var I_CLOSE_AFTER = input(5, "Close after X candles", tooltip="Leave 0 if you want this to be disabled.", group="Basic settings")

var I_ATR_EXIT_MULTIPLIER = input(0.0, "ATR exit multiplier", step=0.1, inline="ATR settings", group="ATR settings")
var I_ATR_PERIOD = input(20, "ATR period", minval=2, inline="ATR settings", group="ATR settings")

var I_INITIAL_DATE = input(0, "Initial date", input.time, tooltip="Leave this value as it is to disable.", inline="Date selection", group="Date selection")
var I_FINAL_DATE = input(0, "Final date", input.time, tooltip="Leave this value as it is to disable.", inline="Date selection", group="Date selection")

// Calculation

ifr2 = rsi(close, 2)

inMarket = strategy.opentrades != 0
opened = strategy.opentrades[0] > strategy.opentrades[1]

// Range check

inRange = (I_INITIAL_DATE == 0 ? true : time >= I_INITIAL_DATE) and (I_FINAL_DATE == 0 ? true : time <= I_FINAL_DATE)

// Entry order

longCondition = crossunder(ifr2, I_OVERSOLD) and inRange
strategy.entry("Long", true, comment="Entry", when=longCondition)
	
// Exit order

exitPrice = highest(I_CANDLE_LOOKBACK) + atr(I_ATR_PERIOD) * I_ATR_EXIT_MULTIPLIER
strategy.exit("Long", "Long", limit=exitPrice, comment="Exit")

plot(longCondition or inMarket ? exitPrice : na, "Exit price", color.teal, 2, plot.style_linebr, offset=1)

// Exit after X candles

if I_CLOSE_AFTER and barssince(opened) >= I_CLOSE_AFTER
    strategy.close_all(comment="It has been " + tostring(I_CLOSE_AFTER) + " candle" + (I_CLOSE_AFTER > 1 ? "s" : "")  + " since you entered")
````

# DMI Swings (by Coinrule)

- url: https://www.tradingview.com/script/PDkNPkky-DMI-Swings-by-Coinrule/
- type: strategy
- pine_id: PUB;6ce3a27e74ca401da57d893e64de8704
- version: 1.0

## Description

The Directional Movement Index is a handy indicator that helps catch the direction in which the price of an asset is moving. It compares the prior highs and lows to draw three lines:
[list]
[*]Positive directional line (+DI)
[*]Negative directional line (-DI)
[*]Average direction index (ADX)
[/list]

DMI is simple to interpret. When +DI > - DI, it means the price is trending up. On the other hand, when -DI > +DI, the trend is weak or moving on the downside. 
The ADX does not give an indication about the direction but about the strength of the trend. 

Typically values of ADX above 25 mean that the trend is steeply moving up or down, based on the -DI and +D positioning. This script aims to capture swings in the DMI, and thus, in the trend of the asset, using a contrarian approach.

[b]ENTRY[/b] 
[list]
[*]-DI is greater than +DI
[*]ADX is greater than 45 
[/list]

[b]EXIT[/b]
[list]
[*]+DI is greater than -DI
[*]ADX is greater than 45
[/list]

Trading on high values of ADX, the strategy tries to spot extremely oversold and overbought conditions. Values of ADX above 45 may suggest that the trend has overextended and is may be about to reverse.

Our backtests suggest that this script performs well for very short-term scalping strategies on low time frames, such as the 1-minute. 

The script considers a 0.1% trading fee to make results more realistic to those you can expect from live market conditions. So realistically, live results should be similar to backtested results.

You can plug this script directly into your crypto exchange using TradingView Signals on Coinrule.

[i]Trade Safely![/i]

## Source Code

````pine
//@version=4
strategy(shorttitle='DMI swings',title='DMI swings', overlay=true, initial_capital = 100, process_orders_on_close=true, default_qty_type = strategy.percent_of_equity, default_qty_value = 100, commission_type=strategy.commission.percent, commission_value=0.1)

//Backtest dates
fromMonth = input(defval = 1,    title = "From Month",      type = input.integer, minval = 1, maxval = 12)
fromDay   = input(defval = 1,    title = "From Day",        type = input.integer, minval = 1, maxval = 31)
fromYear  = input(defval = 2021, title = "From Year",       type = input.integer, minval = 1970)
thruMonth = input(defval = 1,    title = "Thru Month",      type = input.integer, minval = 1, maxval = 12)
thruDay   = input(defval = 1,    title = "Thru Day",        type = input.integer, minval = 1, maxval = 31)
thruYear  = input(defval = 2112, title = "Thru Year",       type = input.integer, minval = 1970)

showDate  = input(defval = true, title = "Show Date Range", type = input.bool)

start     = timestamp(fromYear, fromMonth, fromDay, 00, 00)        // backtest start window
finish    = timestamp(thruYear, thruMonth, thruDay, 23, 59)        // backtest finish window
window()  => time >= start and time <= finish ? true : false       // create function "within window of time"

[pos_dm, neg_dm, avg_dm] = dmi(14, 14)

//Entry 
strategy.entry(id="long", long = true, when = avg_dm > 45 and pos_dm < neg_dm and window())

//Exit
strategy.close("long", when = avg_dm > 45 and pos_dm > neg_dm and window())
````

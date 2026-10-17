# Does your trading pass the seasonality test?

- url: https://www.tradingview.com/script/jWAYPx4v-Does-your-trading-pass-the-seasonality-test/
- type: strategy
- pine_id: PUB;ZJAddjFpFrczTcCYNQxfjt30JMrnxays
- version: 1.0

## Description

[b]Are you consistently beating the standard "Buy and Hold" benchmark?[/b]

Check your performance against the next most common strategy:
[i]Buy at the start of the holiday season and close in the new year.[/i]

By default, the strategy starts with $100,000 and risks 25% of the account on each swing trade.
Commission is set to be 0.5% of each trade.

You can tweak the direction of trades by adjusting the first setting.
Tweak the holding period by changing the Entry and Exit months.

Red plot: Balance of account
Orange plot: Equity of account

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © EmpiricalFX

//@version=4
strategy("Seasonality Benchmark ","Season",overlay=false,default_qty_type=strategy.percent_of_equity,
     default_qty_value=25,initial_capital=100000,currency="USD",
     commission_type=strategy.commission.percent,commission_value=0.5)
input_entry_direction = input("Long","Position Type",options=["Long","Short"])
input_entry_month = input("Oct","Entry Month",options=["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"])
input_exit_month = input("Jan","Entry Month",options=["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"])

//Convert three character month string to integer
month_str_to_int(m)=>
    ret = m == "Jan" ? 1 :
          m == "Feb" ? 2 :
          m == "Mar" ? 3 :
          m == "Apr" ? 4 :
          m == "May" ? 5 :
          m == "Jun" ? 6 :
          m == "Jul" ? 7 :
          m == "Aug" ? 8 :
          m == "Sep" ? 9 :
          m == "Oct" ? 10 :
          m == "Nov" ? 11 :
          m == "Dec" ? 12 : -1
          
is_long = input_entry_direction == "Long" ? true : false
entry = month_str_to_int(input_entry_month)
exit = month_str_to_int(input_exit_month)
var balance = strategy.equity

//Entering a position is conditional on:
    //1. No currently active trades
    //2. Input entry month matches current month
if(strategy.opentrades == 0 and entry == month)
    strategy.entry("Swing",is_long)

//Exiting a position is conditional on:
    //1. Must have open trade
    //2. Input exit month matches current month
if(strategy.opentrades > 0 and exit == month)
    strategy.close("Swing")
    
//Update the balance every time a trade is exited
if(change(strategy.closedtrades)>0)
    balance := strategy.equity
    
plot(strategy.equity,"Equity",color.orange)
plot(balance,"Balance",color.red)
````

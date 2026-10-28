# Arnaud Legoux Moving Average Cross (ALMA)

- url: https://www.tradingview.com/script/PgVGNY0m-Arnaud-Legoux-Moving-Average-Cross-ALMA/
- type: strategy
- pine_id: PUB;0d27d24fc1c14871a188de4e786f77e1
- version: 2.0

## Description

This strategy uses two different Arnaud Legoux Moving Average Lengths, one fast and one slow, to determine crosses for entries. The Arnaud Legoux Moving Average is an improvement to traditional MA's because it reduces lag and smooths the signal line. I have added a volume filter to improve the accuracy of the signals. This script is optimized to be used with crypto, but could be adjusted to use on different instruments. Alert functionality is included. The backtesting results displayed use 10% of the initial account equity, adjust as necessary.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Sarahann999
// Calculations for TP/SL based off: https://kodify.net/tradingview/orders/percentage-profit/
//@version=5
strategy("ALMA Cross", overlay=true)

//User Inputs
src= (close)
long_entry = input(true, title='Long Entry')
short_entry = input(true, title='Short Entry')

//Fast Settings
ALMA1 = input(60, "ALMA Lenghth 1", group= "ALMA Fast Length Settings")
alma_offset = input.float(defval=0.85, title='Arnaud Legoux (ALMA) - Offset Value', minval=0, step=0.01)
alma_sigma = input.int(defval=6, title='Arnaud Legoux (ALMA) - Sigma Value', minval=0)
Alma1 = ta.alma(src, ALMA1, alma_offset, alma_sigma)

//Slow Settings
ALMA2 = input(120, "ALMA Length 2", group = "ALMA Slow Length Settings")
alma_offset2 = input.float(defval=0.85, title='Arnaud Legoux (ALMA) - Offset Value', minval=0, step=0.01)
alma_sigma2 = input.int(defval=6, title='Arnaud Legoux (ALMA) - Sigma Value', minval=0)
Alma2 = ta.alma(src, ALMA2, alma_offset2, alma_sigma2)

//Volume
var cumVol = 0.
cumVol += nz(volume)
if barstate.islast and cumVol == 0
    runtime.error("No volume is provided by the data vendor.")
shortlen = input.int(5, minval=1, title = "Short Length", group= "Volume Settings")
longlen = input.int(10, minval=1, title = "Long Length")
short = ta.ema(volume, shortlen)
long = ta.ema(volume, longlen)
osc = 100 * (short - long) / long

//Define Cross Conditions
buy = ta.crossover(Alma1, Alma2)
sell = ta.crossunder(Alma1, Alma2)

//Calculate Take Profit Percentage
longProfitPerc = input.float(title="Long Take Profit", group='Take Profit Percentage',
     minval=0.0, step=0.1, defval=2) / 100
shortProfitPerc = input.float(title="Short Take Profit",
     minval=0.0, step=0.1, defval=2) / 100
     
// Figure out take profit price 1
longExitPrice  = strategy.position_avg_price * (1 + longProfitPerc)
shortExitPrice = strategy.position_avg_price * (1 - shortProfitPerc)

// Make inputs that set the stop %  1
longStopPerc = input.float(title="Long Stop Loss", group='Stop Percentage',
     minval=0.0, step=0.1, defval=2.5) / 100
shortStopPerc = input.float(title="Short Stop Loss",
     minval=0.0, step=0.1, defval=2.5) / 100

// Figure Out Stop Price
longStopPrice  = strategy.position_avg_price * (1 - longStopPerc)
shortStopPrice = strategy.position_avg_price * (1 + shortStopPerc)

//Define Conditions
buySignal = buy and osc > 0
     and strategy.position_size == 0

//sellSignal 
sellSignal = sell and osc > 0
     and strategy.position_size == 0

// Submit entry orders
if buySignal and long_entry
    strategy.entry(id="Long", direction=strategy.long, alert_message="Enter Long")
    alert(message="BUY Trade Entry Alert", freq=alert.freq_once_per_bar)
    
if sellSignal and short_entry
    strategy.entry(id="Short", direction=strategy.short, alert_message="Enter Short")
    alert(message="SELL Trade Entry Alert", freq=alert.freq_once_per_bar)
    
// Submit exit orders based on take profit price
if (strategy.position_size > 0)
    strategy.exit(id="Long TP/SL", limit=longExitPrice, stop=longStopPrice, alert_message="Long Exit 1 at {{close}}")
if (strategy.position_size < 0)
    strategy.exit(id="Short TP/SL", limit=shortExitPrice, stop=shortStopPrice, alert_message="Short Exit 1 at {{close}}")

//Draw
plot(Alma1,"Alma Fast", color=color.purple, style=plot.style_circles)
plot(Alma2,"Alma Slow", color=#acb5c2, style=plot.style_circles)
````

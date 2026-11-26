# (IK) Stoch-60-15

- url: https://www.tradingview.com/script/CJ7Q8NyT-IK-Stoch-60-15/
- type: strategy
- pine_id: PUB;oG7qrACwaUUJoyM7CmAPtwIRhUjojdK2
- version: 3.0

## Description

This strategy uses 60 minute and 15 minute stochastic data to determine entry and exit; it only executes long trades. I've only used this on BTC/USD, but I imagine the concepts employed should hold for any ticker

The script builds a simple Stochastic indicator for the current timeframe, and it also plots a single stochastic line for a higher resolution time frame. I've found good results trading on 15 minutes with a 60 minute higher resolution. 

We enter a trade if the higher resolution stochastic is in an uptrend, if the current resolution stochastic is in an uptrend, and if the current stochastic value is less than 50. 

We exit a trade when the current stochastic value crosses below 80 or the trailing stop loss is hit. 

Stop loss is calculated with the input value, Stop Loss Percent. This value represents the percent of capital you're willing to lose before exiting a trade. A stop loss percent of 0.050 means your trade will exit if it falls 5% from the highest high since entering a trade. You will have at least 95% of your original capital left. There is no option to change a trailing stop loss to a set stop loss (in order to keep the code as simple as possible), however, you can turn it off by setting Stop Loss Percent to 1.

I tried to keep the script itself lightweight and very easy to understand, so it's not very customizable in regards to input options. You can change stochastic data, as well as the trailing stop percentage. [b]The script can be adjusted to other timeframes, however this requires a small change in the code (details in script comments). Changing just the "Higher Resolution" input will not produce expected results[/b]

My hope is that by keeping it lightweight and simple, it will be easier for you to adjust to your specific needs, or work into a larger strategy.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © userIan

//@version=4
strategy(title="(IK) 60-15", precision=2, default_qty_type=strategy.cash, default_qty_value=100.0, initial_capital=100.0, currency="USD", commission_type=strategy.commission.percent, commission_value=0.1)

// get input 
i_length        = input(group="Stochastic", title="Stochastic Length", minval=1, defval=18)                                     
i_k             = input(group="Stochastic", title="Stochastic %K", minval=1, defval=2)
i_d             = input(group="Stochastic", title="Stochastic %D", minval=1, defval=10)
i_trailingStop  = input(group="Trade Settings", title="Trailing Stop?", type=input.bool, defval=true)                           // should stop loss be dynamic, based on most recent high, or static, based on entry price?
i_stopPercent   = input(group="Trade Settings", title="Stop Percent", type=input.float, defval=0.05, maxval=1.0, minval=0.001)  // how much (percentage) can price fall before exiting the trade
i_takeProfit    = input(group="Trade Settings", title="Take Profit", type=input.float, defval=0.05, maxval=1.0, minval=0.001)   // how much (percentage) can price rise before exiting the trade
i_sellThreshold = input(group="Trade Settings", title="Sell Threshold", type=input.float, defval=75.0, maxval=100, minval=0.0)  // when stochastic %D crosses under this value, exit the trade
i_buyThreshold  = input(group="Trade Settings", title="Buy Threshold", type=input.float, defval=40.0, maxval=100, minval=0.0)   // stochastic %D must be below this value to enter a trade

// declare order variables
var recentHigh  = 0.0   // the highest high while in a trade
var stop        = 0.0   // the price that will trigger as stop loss
var entryPrice  = 0.0   // the price when the trade was entered

// build stochastic
sto = stoch(close, high, low, i_length)
K   = sma(sto, i_k)
D   = sma(K, i_d)

// get stochastic trend
stoch_upTrend = D > D[1]

// get stochastic trend for 60 minute
stoch_60         = security(syminfo.tickerid, "60", D)
stoch_60_upTrend = (stoch_60[4] >= stoch_60[8])

// entry
if (D < i_buyThreshold) and stoch_upTrend and stoch_60_upTrend and barstate.isconfirmed
    recentHigh := close
    entryPrice := close
    stop       := (close * (1-i_stopPercent)) 
    strategy.entry(id="60-15-Long", long=strategy.long, comment='buy')

// update recent high, trailing stop
if close > recentHigh  
    recentHigh := close
    stop       := i_trailingStop ? (recentHigh * (1-i_stopPercent)) : stop

// exit
strategy.exit(id="60-15-Long", stop=stop, comment='sell-stop')
if close > (entryPrice * (1+i_takeProfit)) and barstate.isconfirmed
    strategy.close(id="60-15-Long", comment='sell-profit')
if crossunder(D, i_sellThreshold) and barstate.isconfirmed
    strategy.close(id="60-15-Long", comment='sell-trend')
    
// plot
plot(K, title="%K", color=color.blue, linewidth=1)
plot(D, title="%D", color=color.orange, linewidth=1)
plot(stoch_60, title="Hourly Stochastic (D)", color= stoch_60_upTrend ? color.green : color.red, style=plot.style_stepline)
upperBand  = hline(i_sellThreshold, title="Upper Limit", linestyle=hline.style_dashed)
middleBand = hline(50, title="Midline", linestyle=hline.style_dotted)
lowerBand  = hline(i_buyThreshold, title="Lower Limit", linestyle=hline.style_dashed)
fill(lowerBand, upperBand, color=color.purple, transp=75)
````

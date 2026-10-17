# HYE Mean Reversion SMA [Strategy]

- url: https://www.tradingview.com/script/fdhtixF2/
- type: strategy
- pine_id: PUB;f4f043583fc7483d933b73b085e5b535
- version: 2.0

## Description

An RSI filtered version of PJ Sutherland's Jaws Mean Reversion algorithm. 

[b]"Long" on the close when;[/b]

1-) 2 period simple moving average closes 3% or more below the 5 period simple moving average,
2-) 5 period exponential average of the 2 period RSI is below 30.

"Exit Long" on the close when;

1-) 2 period simple moving average closes above the 5 period moving average.

[b]"Short" on the close when;[/b]

1-) 2 period simple moving average closes 3% or more above the 5 period simple moving average,
2-) 5 period exponential average of the 2 period RSI is above 70.

"Exit Short" on the close when;

1-) 2 period simple moving average closes below the 5 period moving average.

[b]***[/b] You can change the needed percentage for long and short trades, periods of simple moving averages and RSI levels.
[b]***[/b] You can select the trend direction: "Long Only" , "Short Only" or "Both". Default is "Long Only".

## Source Code

````pine
// @version=4

strategy("HYE Mean Reversion SMA [Strategy]", overlay = true, initial_capital = 1000, default_qty_value = 100, default_qty_type = strategy.percent_of_equity, commission_value = 0.025)
  
//Strategy inputs
source = input(title = "Source", defval = close)
tradeDirection = input(title="Trade Direction", type=input.string,
     options=["Long Only", "Short Only", "Both"], defval="Long Only") 
smallMAPeriod = input(title = "Small Moving Average", defval = 2)
bigMAPeriod = input(title = "Big Moving Average", defval = 5)
percentBelowToBuy = input(title = "Percent below to buy %", defval = 3)
percentAboveToSell = input(title = "Percent above to sell %", defval = 3)
rsiPeriod = input(title = "Rsi Period", defval = 2)
rsiLevelforBuy = input(title = "Maximum Rsi Level for Buy", defval = 30)
rsiLevelforSell = input(title = "Minimum Rsi Level for Sell", defval = 70)
     
longOK  = (tradeDirection == "Long Only") or (tradeDirection == "Both")
shortOK = (tradeDirection == "Short Only") or (tradeDirection == "Both")

// Make input options that configure backtest date range
startDate = input(title="Start Date", type=input.integer,
     defval=1, minval=1, maxval=31)
startMonth = input(title="Start Month", type=input.integer,
     defval=1, minval=1, maxval=12)
startYear = input(title="Start Year", type=input.integer,
     defval=2020, minval=1800, maxval=2100)

endDate = input(title="End Date", type=input.integer,
     defval=31, minval=1, maxval=31)
endMonth = input(title="End Month", type=input.integer,
     defval=12, minval=1, maxval=12)
endYear = input(title="End Year", type=input.integer,
     defval=2021, minval=1800, maxval=2100)
     
inDateRange = (time >= timestamp(syminfo.timezone, startYear,
         startMonth, startDate, 0, 0)) and
     (time < timestamp(syminfo.timezone, endYear, endMonth, endDate, 0, 0))

//Strategy calculation 
rsiValue = rsi(source, rsiPeriod)
rsiEMA   = ema(rsiValue, 5)
smallMA = sma(source, smallMAPeriod)
bigMA =  sma(source, bigMAPeriod) 
buyMA = ((100 - percentBelowToBuy) / 100) * sma(source, bigMAPeriod)[0]
sellMA = ((100 + percentAboveToSell) / 100) * sma(source, bigMAPeriod)[0]

if(crossunder(smallMA, buyMA) and rsiEMA < rsiLevelforBuy and inDateRange and longOK)
    strategy.entry("BUY", strategy.long) 

if(crossover(smallMA, bigMA) or not inDateRange)
    strategy.close("BUY")

if(crossover(smallMA, sellMA) and rsiEMA > rsiLevelforSell and inDateRange and shortOK)
    strategy.entry("SELL", strategy.short)

if(crossunder(smallMA, bigMA) or not inDateRange)
    strategy.close("SELL")

plot(smallMA, color=#13C425, linewidth=2)
plot(bigMA, color=#CA1435, linewidth=2)
````

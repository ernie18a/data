# HYE Mean Reversion VWAP [Strategy]

- url: https://www.tradingview.com/script/WeAMGj9j/
- type: strategy
- pine_id: PUB;07c44dd13826454999d095d8b86665c6
- version: 2.0

## Description

An RSI filtered version of PJ Sutherland's Jaws Mean Reversion algorithm using volume weighted average price (VWAP) instead of simple moving average (SMA).

"Long" on the close when;

1-) 2 period VWAP closes 3% or more below the 5 period VWAP ,
2-) 5 period exponential average of the 2 period RSI is below 30.

"Exit Long" on the close when;

1-) 2 period VWAP closes above the 5 period VWAP.

"Short" on the close when;

1-) 2 period VWAP closes 3% or more above the 5 period VWAP ,
2-) 5 period exponential average of the 2 period RSI is above 70.

"Exit Short" on the close when;

1-) 2 period VWAP closes below the 5 period VWAP.

*** You can change the needed percentage for long and short trades, periods of VWAPs and RSI levels.
*** You can select the trend direction: "Long Only" , "Short Only" or "Both". Default is "Long Only".

I used the "VWAP with period" indicator code of @neolao. Special thanks to @neolao.
Indicator Link: https://tr.tradingview.com/v/rSTNnV6B/

## Source Code

````pine
// @version=4

strategy("HYE Mean Reversion VWAP [Strategy]", overlay = true, initial_capital = 1000, default_qty_value = 100, default_qty_type = strategy.percent_of_equity, commission_value = 0.025)
  
//Strategy inputs
source = input(title = "Source", defval = close)
tradeDirection = input(title="Trade Direction", type=input.string,
     options=["Long Only", "Short Only", "Both"], defval="Long Only")
smallcumulativePeriod = input(title = "Small VWAP", defval = 2)
bigcumulativePeriod = input(title = "Big VWAP", defval = 5)
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
typicalPriceS = (high + low + close) / 3
typicalPriceVolumeS = typicalPriceS * volume
cumulativeTypicalPriceVolumeS = sum(typicalPriceVolumeS, smallcumulativePeriod)
cumulativeVolumeS = sum(volume, smallcumulativePeriod)
smallvwapValue = cumulativeTypicalPriceVolumeS / cumulativeVolumeS

typicalPriceB = (high + low + close) / 3
typicalPriceVolumeB = typicalPriceB * volume
cumulativeTypicalPriceVolumeB = sum(typicalPriceVolumeB, bigcumulativePeriod)
cumulativeVolumeB = sum(volume, bigcumulativePeriod)
bigvwapValue = cumulativeTypicalPriceVolumeB / cumulativeVolumeB 

rsiValue = rsi(source, rsiPeriod)
rsiEMA   = ema(rsiValue, 5)
buyMA = ((100 - percentBelowToBuy) / 100) * bigvwapValue[0]
sellMA = ((100 + percentAboveToSell) / 100) * bigvwapValue[0]

inTrade = strategy.position_size > 0
notInTrade = strategy.position_size <= 0

if(crossunder(smallvwapValue, buyMA) and rsiEMA < rsiLevelforBuy and inDateRange and notInTrade and longOK)
    strategy.entry("BUY", strategy.long)

if(crossover(smallvwapValue, bigvwapValue) or not inDateRange)
    strategy.close("BUY")
    
if(crossover(smallvwapValue, sellMA) and rsiEMA > rsiLevelforSell and inDateRange and notInTrade and shortOK)
    strategy.entry("SELL", strategy.short)

if(crossover(smallvwapValue, bigvwapValue) or not inDateRange)
    strategy.close("SELL")   

plot(smallvwapValue, color=#13C425, linewidth=2)
plot(bigvwapValue, color=#CA1435, linewidth=2)
````

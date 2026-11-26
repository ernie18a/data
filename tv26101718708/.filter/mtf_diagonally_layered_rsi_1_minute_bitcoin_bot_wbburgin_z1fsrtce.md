# MTF Diagonally Layered RSI - 1 minute Bitcoin Bot [wbburgin]

- url: https://www.tradingview.com/script/z1fsrtce-MTF-Diagonally-Layered-RSI-1-minute-Bitcoin-Bot-wbburgin/
- type: strategy
- pine_id: PUB;25c96a972a564a7f9e7b2e66bf194f57
- version: 10.0

## Description

This is a NON-REPAINTING multi-timeframe RSI strategy (long-only) that enters a trade only when two higher timeframes are oversold. I wrote it on BTC/USD for 1min, but the logic should work on other assets as well. It is [i]diagonally layered[/i] to be profitable for when the asset is in a downtrend.

Diagonal layering refers to entry and exit conditions spread across different timeframes. Normally, indicators can become unprofitable because in downtrends, the overbought zones of the current timeframe are not reached. Rather, the overbought zones of the [i]faster[/i] timeframes are reached first, and then a selloff occurs. Diagonally-layered strategies mitigate this by selling diagonally, that is, selling once the faster timeframe reaches overbought and buying once the slower timeframe reaches oversold.

Thus this strategy is diagonally layered [b]down[/b]. I may create a separate script that alternates between diagonal-up and diagonal-down based off of overall trend, as in extended trend periods up this indicator may not flash as frequently. This can be visualized in a time series x timeframe chart as an "X" shape. Something to consider...

Let me know if you like this strategy. Feel free to alter the pyramiding entries, initial capital, and entry size, as well as commission regime. My strategies are designed to maximize average profit instead of flashing super frequently, as the fees will eat you up. Additionally, at the time of publication, all of my strategy scripts are intended to have profitable Sharpe and Sortino ratios.

Timeframes, RSI period, and oversold/overbought bounds are configurable.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wbburgin

//@version=5
strategy("MTF Layered RSI - Bitcoin Bot [wbburgin]",overlay=false, initial_capital=10000, pyramiding=2)

length = input.int(7,"RSI Length",group="Config")
tf2 = input.timeframe("3",title="HT 1",group="Config")
tf3 = input.timeframe("5",title="HT 2",group="Config")
ob = input.int(80,"Overbought Level",group="Config")
os = input.int(20,"Oversold Level",group="Config")
calcType = input.string("Manual Calculation",options=["Security Function","Manual Calculation"],title="Calc Type",
 tooltip="Manual calculation is a way to stop repaint without using request.security().")
use200ma = input.bool(false,"Use EMA Filter",group="Risk Management")
emaLen = input.int(200,"EMA Length",group="Risk Management")
stoploss = input.bool(false,"Use % Stop Loss",group="Risk Management")
stoplosspercent = input.float(0.5,title="Stop Loss (%)",group="Risk Management")
tradeType = input.string("Long-only",options=["Long-only","Long and Short"],title="Allow Shorts?")

rsi = ta.rsi(close,length)

// Security RSI Calculation ____________________________________________________________________________________________

indexHighTF = barstate.isrealtime ? 1 : 0
indexCurrTF = barstate.isrealtime ? 0 : 1
rsi2_sec = request.security(syminfo.tickerid, tf2, rsi[indexHighTF])[indexCurrTF]
rsi3_sec = request.security(syminfo.tickerid, tf3, rsi[indexHighTF])[indexCurrTF]
//Aligns with Tradingview's method of non-repainting: https://www.tradingview.com/pine-script-docs/en/v5/concepts/Repainting.html


// Manual RSI Calculation ______________________________________________________________________________________________

currentTF = timeframe.period
tf_to_int(timeframe)=> 
    switch
        timeframe == "1S" => 1
        timeframe == "5S" => 5
        timeframe == "10S"=> 10
        timeframe == "15S"=> 15
        timeframe == "30S"=> 30
        timeframe == "1"  => 60
        timeframe == "3"  => 180
        timeframe == "5"  => 300
        timeframe == "15" => 900
        timeframe == "30" => 1800
        timeframe == "45" => 2700
        timeframe == "60" => 3600 // 1 hour
        timeframe == "120"=> 7200 // 2 hours
        timeframe == "180"=> 10800 // 3 hours
        timeframe == "240"=> 14400 // 4 hours
        timeframe == "480"=> 28800 // 8 hours
        timeframe == "720"=> 43200 // 12 hours
        timeframe == "D"  => 86400 // 1 day
        timeframe == "W"  => 604800 // 1 week
        timeframe == "M"  => 2595000 // 1 month

ct_int = tf_to_int(currentTF)
ht1_int = tf_to_int(tf2)
ht2_int = tf_to_int(tf3)

ht1_mult = int(ht1_int / ct_int)
ht2_mult = int(ht2_int / ct_int)

manualRSI(time_mult, len)=>
    htclose = close
    u = math.max(htclose - htclose[time_mult], 0) // upward ta.change
    d = math.max(htclose[time_mult] - htclose, 0) // downward ta.change
    rs = ta.rma(u, len * time_mult) / ta.rma(d, len * time_mult)
    res = 100 - 100 / (1 + rs)
    res

rsi2_man = manualRSI(ht1_mult, length)
rsi3_man = manualRSI(ht2_mult, length)

rsi2 = calcType == "Security Function" ? rsi2_sec : rsi2_man
rsi3 = calcType == "Security Function" ? rsi3_sec : rsi3_man

plot(rsi,color=color.yellow,title="RSI Current TF")
plot(rsi2,color=color.new(color.yellow,50),title="RSI HT1")
plot(rsi3,color=color.new(color.yellow,75),title="RSI HT2")

lm=hline(os,title="Oversold")
hm=hline(ob,title="Overbought")

fill(hm,lm,color=color.new(color.blue,95))

// Long Settings

htCross = (ta.crossover(rsi2,os) and rsi3>os and rsi>os) 
 or (ta.crossover(rsi3,os) and rsi2>os and rsi>os)
buySig = (ta.crossover(rsi,os) and rsi2 < os and rsi3 < os) or htCross
sellSig = ta.crossunder(rsi,ob)

// Short Settings
htCross_short = (ta.crossunder(rsi2,ob) and rsi3<ob and rsi<ob) or (ta.crossunder(rsi3,ob) and rsi2<ob and rsi<ob)
shortEntry = (ta.crossunder(rsi,ob) and rsi2 > ob and rsi3 > ob) or htCross_short
shortExit = ta.crossover(rsi,os)

//Risk Settings
ema200 = ta.ema(close,emaLen)
filter = use200ma ? close>ema200 ? true : false : true
shortfilter = use200ma ? close<ema200 ? true : false : true
stoplosslevel_long = (1-(stoplosspercent/100)) * ta.valuewhen(buySig and filter,close,0)
stoplosslevel_short = (1+(stoplosspercent/100)) * ta.valuewhen(shortEntry and shortfilter,close,0)
initiate_stoploss_long = stoploss ? ta.crossunder(close,stoplosslevel_long) : na
initiate_stoploss_short = stoploss ? ta.crossover(close,stoplosslevel_short) : na

if buySig and filter
    strategy.entry("Long",strategy.long)
if sellSig or initiate_stoploss_long
    strategy.close("Long")
if shortEntry and shortfilter and tradeType == "Long and Short"
    strategy.entry("Short",strategy.short)
if shortExit or initiate_stoploss_short
    strategy.close("Short")

plotshape(buySig and filter,title="Buysig",style=shape.triangleup,location=location.bottom,color=color.green,size=size.tiny)
plotshape(sellSig or initiate_stoploss_long,title="Sellsig",style=shape.triangledown,location=location.top,color=color.red,size=size.tiny)
````

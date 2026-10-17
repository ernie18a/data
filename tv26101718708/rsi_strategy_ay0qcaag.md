# RSI Strategy

- url: https://www.tradingview.com/script/AY0QCaAG-RSI-Strategy/
- type: strategy
- pine_id: PUB;e128b35b85e44465810d1cb0d6b711aa
- version: 2.0

## Description

Simple way how to use RSI and MA indicators for trading. 

What we use: 
• RSI 
• SMA calculated by RSI (title: SMA_RSI) 
• Delta of RSI and SMA_RSI (title: delta) 
• SMA calculated by delta of RSI and SMA & RSI (title: SMA_RSI2) 

Logic: 
Upon the fact that we use the difference between two indicators that have similar values ( RSI and SMA_RSI), we get number around zero. Next, result is smoothed by calculated the SMA . This is the blue/purple line that appears on the chart - SMA_RSI2.
The trade open when SMA_RSI2 cross over the threshold. The trade close when SMA_RSI2 cross under the threshold below.
Also, the usual EMA 200 is used as a filter, which you can switch on or switch off.

## Source Code

````pine
//@version=4
strategy(title="RSI&SMA", overlay=false, pyramiding=1, default_qty_type=strategy.percent_of_equity,  default_qty_value=100, initial_capital=10000, currency=currency.USD)  //default_qty_value=10, default_qty_type=strategy.fixed,
startP = timestamp(input(2017, "Start Year"), input(12, "Month"), input(17, "Day"), 0, 0)
end   = timestamp(input(9999, "End Year"), 1,  1,   0, 0)
_testPeriod() =>
    iff(time >= startP and time <= end, true, false)
    
rsiLength=input(21,title="RSI Length", minval=1, maxval=50)
buyLine=input(65,title="RSI Buy Line", minval=30, maxval=100)
exitLine=input(50,title="RSI Exit Line", minval=0, maxval=100)

RMARSI=rsi(rma(hlc3 * volume, 1) / rma(volume, 1),rsiLength)
sma200=sma(close,200)
plot(RMARSI, color= RMARSI > buyLine ? color.blue : color.lime)
plot(RMARSI, color= RMARSI < exitLine ? color.purple : na)

hline(buyLine)
hline(exitLine)

long_condition = crossover(RMARSI,buyLine) and close>sma200 and _testPeriod() 
strategy.entry('BUY', strategy.long, when=long_condition)  
 
short_condition = crossunder(RMARSI,exitLine)
strategy.close('BUY', when=short_condition)
````

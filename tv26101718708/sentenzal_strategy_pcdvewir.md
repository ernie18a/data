# @sentenzal strategy

- url: https://www.tradingview.com/script/pCdvEWir-sentenzal-strategy/
- type: strategy
- pine_id: PUB;QwFwP7efRrg2LY08IRTdE5zG02LAzfPh
- version: 1.0

## Description

Strategy

## Source Code

````pine
//@version=3
//study(title="@sentenzal strategy", shorttitle="@sentenzal strategy", overlay=true)
strategy(title="@sentenzal strategy", shorttitle="@sentenzal strategy", overlay=true, pyramiding=10, currency=currency.USD, default_qty_value=100,default_qty_type=strategy.cash  )
smoothK = input(3, minval=1)
smoothD = input(3, minval=1)
lengthRSI = input(14, minval=1)
lengthStoch = input(14, minval=1)
overbought = input(80, minval=1)
oversold = input(20, minval=1)
smaLengh = input(100, minval=1)
smaLengh2 = input(50, minval=1)
smaLengh3 = input(20, minval=1)

src = input(close, title="RSI Source")
testStartYear = input(2017, "Backtest Start Year")
testStartMonth = input(1, "Backtest Start Month")
testStartDay = input(1, "Backtest Start Day")
testPeriodStart = timestamp(testStartYear,testStartMonth,testStartDay,0,0)
testPeriod() =>
    time >= testPeriodStart ? true : false

rsi1 = rsi(src, lengthRSI)
k = sma(stoch(rsi1, rsi1, rsi1, lengthStoch), smoothK)
d = sma(k, smoothD)
crossBuy = crossover(k, d) and k < oversold
crossSell = crossunder(k, d) and k > overbought

dcLower = lowest(low, 10)
dcUpper = highest(high, 10)


heikinashi_close = security(heikinashi(tickerid), period, close)
heikinashi_open = security(heikinashi(tickerid), period, open)
heikinashi_low = security(heikinashi(tickerid), period, low)
heikinashi_high = security(heikinashi(tickerid), period, high)
heikinashiPositive = heikinashi_close >= heikinashi_open

heikinashiBuy = heikinashiPositive == true and heikinashiPositive[1] == false  and heikinashiPositive[2] == false
heikinashiSell = heikinashiPositive == false and heikinashiPositive[1] == true and heikinashiPositive[2] == true

//plotshape(heikinashiBuy, style=shape.arrowup, color=green, location=location.belowbar, size=size.tiny)
//plotshape(heikinashiSell, style=shape.arrowdown, color=red, location=location.abovebar, size=size.tiny)

buy = (crossBuy == true or crossBuy[1] == true or crossBuy[2] == true) and (heikinashiBuy == true or heikinashiBuy[1] == true or heikinashiBuy[2] == true)
sell = (crossSell == true or crossSell[1] == true or crossSell[2] == true) and (heikinashiSell == true or heikinashiSell[1] == true or heikinashiSell[2] == true)

mult = period == '15' ? 4 : 1
mult2 = period == '240' ? 0.25 : mult

movingAverage = sma(close, round(smaLengh))
movingAverage2 = sma(close, round(smaLengh2))
movingAverage3 = sma(close, round(smaLengh3))

uptrend = movingAverage < movingAverage2 and movingAverage2 < movingAverage3 and close > movingAverage
downtrend = movingAverage > movingAverage2 and movingAverage2 > movingAverage3 and close < movingAverage

signalBuy = (buy[1] == false and buy[2] == false and buy == true) and uptrend
signalSell = (sell[1] == false and sell[2] == false and sell == true) and downtrend

takeProfitSell = (buy[1] == false and buy[2] == false and buy == true) and uptrend == false
takeProfitBuy = (sell[1] == false and sell[2] == false and sell == true)  and uptrend

plotshape(signalBuy, style=shape.triangleup, color=green, location=location.belowbar, size=size.tiny)
plotshape(signalSell, style=shape.triangledown, color=red, location=location.abovebar, size=size.tiny)



plot(movingAverage, linewidth=3, color=orange, transp=0)
plot(movingAverage2, linewidth=2, color=purple, transp=0)
plot(movingAverage3, linewidth=1, color=navy, transp=0)

alertcondition(signalBuy, title='Signal Buy', message='Signal Buy')
alertcondition(signalSell, title='Signal Sell', message='Signal Sell')


strategy.close("L", when=dcLower[1] > low)
strategy.close("S", when=dcUpper[1] < high)

strategy.entry("L", strategy.long, 1, when = signalBuy and testPeriod() and uptrend) 
strategy.entry("S", strategy.short, 1, when = signalSell and testPeriod() and uptrend ==false) 

//strategy.exit("Exit Long", from_entry = "L", loss = 25000000, profit=25000000)
//strategy.exit("Exit Short", from_entry = "S", loss = 25000000, profit=25000000)
````

# 4Hours optimized CAR

- url: https://www.tradingview.com/script/Z5TTObLV/
- type: indicator
- pine_id: PUB;l1lEDcb8zoMEhetV2zUzXuqFnLOHccKK
- version: 1.0

## Description

Hey!

I have been working on this script the lasts days, it's a collaboration with an uruguayan mate.

#####IMPORTANT#####
* It has been optimized for 4h charts, use it on other at your own risk.
* Always use Stop Loss, since it might give false signals after a long trend.
* I'm still working on it, I'm going to add candlestick pattern filtering.

Thanks for your support, greetings.

## Source Code

````pine
//@version=3
study("4Hours optimized CAR", overlay=true) 

//input boxes for the limit date
yearLimit = input(2016,title="year") 
monthLimit = input(1, title="month")
dayLimit = input(1, title="day")

//function that checks if the current date is more recent than the limit
dateOk(yl,ml,dl) =>
    ok = (year < yl) ? false : (yl == year and month < ml ) ? false : (yl == year and ml == month and dayofmonth < dl) ? false : true
    ok
    
checkDate = dateOk(yearLimit,monthLimit,dayLimit)
goUpCheck = (close > open and open > close[1])
goDownCheck = (close < open and open < close[1])

alert = 0
alert := checkDate and goUpCheck ? 1 : alert
alert := checkDate and goDownCheck ? -1 : alert
alertcondition(alert == 1, title="going UP", message="ALERT:" + symbol + " UP:" )
alertcondition(alert == -1, title="going DOWN", message="ALERT:" + symbol + " DOWN:" )
//plot(alert, title="alert",  color=green, linewidth=2, style=line)




smoothK = input(13, minval=1), smoothD = input(3, minval=1)
k = sma(stoch(close, high, low, smoothK), 3)
d = sma(k, smoothD)
//plot(k, color=black)
//plot(d, color=red)
rsi = rsi(close, 13)

//calculate simple moving average bollinger bands
b_sma_candle_history = input(9,title="Simple moving average candle history",type=integer,minval=1,maxval=100)
b_sma_no_of_deviations = 2
b_sma_signal = sma(close, b_sma_candle_history)
b_sma_deviation = b_sma_no_of_deviations * stdev(close, b_sma_candle_history)
b_sma_upper= b_sma_signal + b_sma_deviation
b_sma_lower= b_sma_signal - b_sma_deviation

upp=crossunder( sma( d, 3 ), 20 )
dww=crossover(sma(d, 3 ), 80.5 )
co=dww?80.5:na and (alert > 0.99) and (high > b_sma_upper * 1.08) 
cod=upp ?20:na and (alert < -0.99) and (close < b_sma_lower * 1.08)  

sell_black = (high > b_sma_upper * 1.05) and (d > 90) and (alert > 0.99)
sell_red = (d > 88) and (alert > 0.99) and (high > b_sma_upper * 1.08) 
sell_blue = (high > b_sma_upper * 1.001) and (rsi > 74.01) and (alert > 0.99)

buy_red3 = (rsi > 50) and (d < 28.0) and (alert < -0.99)
buy_red2 = (low < b_sma_lower * 1.0300) and (d < 15.0) and (alert < -0.99)
buy_yellow = (low < b_sma_lower * 0.95) and (d < 13.01) and (alert < -0.99) and not buy_red2
buy_orange = (low < b_sma_lower * 1.051) and (d < 11.0) and (alert < -0.99) and not buy_yellow
buy_red = (low < b_sma_lower * 1.000) and (d < 6.0) and (alert < -0.99) and not buy_yellow and not buy_orange

//plotshape(buy_red, style=shape.triangleup, location=location.belowbar, color=red, text = "P!", size = size.auto)
//plotshape(buy_red2, style=shape.triangleup, location=location.belowbar, color=red, text = "B", size = size.auto)
//plotshape(buy_orange, style=shape.triangleup, location=location.belowbar, color=orange, text = "B", size = size.auto)
plotshape(buy_yellow, style=shape.triangleup, location=location.belowbar, color=yellow, size = size.auto)
//plotshape(buy_red3, style=shape.circle, location=location.belowbar, color=green, text = "B", size = size.auto)

plotshape(sell_blue, style=shape.triangledown, location=location.abovebar, color=blue, size = size.auto)
plotshape(sell_black, style=shape.triangledown, location=location.abovebar, color=black, size = size.auto)
plotshape(sell_red, style=shape.circle, location=location.abovebar, color=red, text = "S", size = size.auto)


//plot(mrs)
plotshape(co,title="Swing 350 SELL",style=shape.circle,location=location.abovebar, color=black, text = "TP")
plotshape(cod,title="Swing 350 BUY",style=shape.circle,location=location.belowbar, color=black, text = "B")
bcol = alert > 0.99 ? red : alert < -0.99 ? green : na
//bgcolor(bcol)
````

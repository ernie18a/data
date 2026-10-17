# Triple SMA Strategy with entries based on sma price closes

- url: https://www.tradingview.com/script/uADCamxf-Triple-SMA-Strategy-with-entries-based-on-sma-price-closes/
- type: strategy
- pine_id: PUB;bUF1YHN76U6RDvBRQB1Bw3v3urm7QcVZ
- version: 1.0

## Description

Hi! :)

This strategy is made for intraday trades, especially on 5 sec - 5 min charts to follow the trend.

I have not tested on higher timeframes, but feel free to play with the values.

I have set a basic value for the 3 SMA at
  -200
  -400
  -600

We will use an oscillator for entries which is not mine. Link -> 
[url=https://www.tradingview.com/script/5Aoz0yMh-Stochastic-based-on-Closing-Prices-Identify-and-Rank-Trends/]https://www.tradingview.com/script/5Aoz0yMh-Stochastic-based-on-Closing-Prices-Identify-and-Rank-Trends/[/url]

The oscillator mentioned above is just for visualization purposes, You do not need to get the signals, but You can see how scripts are generated with different values.

When the price above/below all the 3 SMA and oscillator crosses above/below  "value you set" - You will get the buy or sell signal.
Your stop will be where the slowest SMA is.

Pyramiding is set for 10.

You can manually set 3 take profit and quantity levels.
Basic values are 1 %, 2 %, and 6 % for taking profits - You can change it based on how volatile the asset is.
Basic quantity values are 30 % at each level.


Hope You find it useful :)

## Source Code

````pine
//@version=4
strategy(title="Tripla Sma with entries based on sma price closes ", shorttitle="TRIPLE SMA STRATEGY", overlay=true, default_qty_value=100, pyramiding = 10) ////resolution=""
len = input(200, minval=1, title="sma 1 length")
len1 = input(400, minval=1, title="sma 2 length")
len2 = input(600, minval=1, title="sma 3 length")
src = input(close, title="Source")
////////////////////////////////////////////
smma = 0.0
smma := na(smma[1]) ? sma(src, len) : (smma[1] * (len - 1) + src) / len

up = smma > smma [1]
down =smma < smma[1]
mycolor = up ? #64b5f6 : down ? #d32f2f : na
fastma = sma(hl2, 1)

fastplot = plot(fastma, color=#000000, transp=100, title='sma on candle')
slowplot = plot(smma, color=mycolor, transp=55, title='sma1')

////////////////////////////////////////////
smma1 = 0.0
smma1 := na(smma1[1]) ? sma(src, len1) : (smma1[1] * (len1 - 1) + src) / len1

up2 = smma1 > smma1 [1]
down2 =smma1 < smma1[1]

mycolor2 = up2 ? #64b5f6 : down2 ? #d32f2f : na
slowplot2 = plot(smma1, color=mycolor2, transp=45, title='sma2')

////////////////////////////////////////////
smma2 = 0.0
smma2 := na(smma2[1]) ? sma(src, len2) : (smma2[1] * (len2 - 1) + src) / len2

up3 = smma2 > smma2 [1]
down3 =smma2 < smma2[1]

mycolor3 = up3 ? #64b5f6 : down3 ? #d32f2f : na
slowplot3 = plot(smma2, color=mycolor3, transp=35, title='sma3')

////////////////////////////////////////////////////////////////////////////////////////
//Fill gaps
fillData = smma > fastma
fillData2 = smma < fastma

fillDtat = smma1 > smma
fillDtat2 = smma1 < smma

fillDat = smma2 > smma1
fillDat2 = smma2 < smma1


fillCol1 = fillData ? #ef5350 : fillData2 ? #64b5f6 : na
fillCol2 = fillDtat ? #ef5350 : fillDtat2 ? #64b5f6 : na
fillCol3 = fillDat ? #ef5350 : fillDat2 ? #64b5f6 : na


fill(slowplot, fastplot, color=fillCol1, transp=90, title="sma1 fill")
fill(slowplot, slowplot2, color=fillCol2, transp=80, title="sma2 fill")
fill(slowplot2, slowplot3, color=fillCol3, transp=60, title="sma3 fill")

uc = (close > smma) and (close > smma1)
dc = (close < smma) and (close < smma1)

barColor = uc ? #64b5f6 : dc ? #e91e63 : #b2b5be
barcolor(color=barColor)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//StochClose from @trendinvestpro 
periods = input(50, minval=1, title="length for the oscillator")
smooth = input(5, minval=1, title="oscillator smoothing")
hhc=highest(close,periods)
llc=lowest(close,periods)
StochClose = sma((close-llc)/(hhc-llc)*100, smooth)

shortline = input(95, minval=0, title="signal when oscillator crosses above")
longline = input(5, minval=0, title="signal when oscillator crosses below")

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
longs = close > smma2
shorts = close < smma2



long = longs == true and crossunder(StochClose, longline)
short = shorts == true and crossover(StochClose, shortline)

stoplong = close < smma and close < smma1 and close < smma2
stopshort = close > smma and close > smma1 and close > smma2

p1 = strategy.position_avg_price / 100 / syminfo.mintick

maxx = input(2500, title="max orders filled on a day", minval=0)
takeprofit1 = input(1, title="take profit level 1", minval=0)
takeprofit2 = input(2, title="take profit level 2", minval=0)
takeprofit3 = input(6, title="take profit level 3", minval=0)

takeprofitqt1 = input(30, title="take profit quantity first", minval=0)
takeprofitqt2 = input(30, title="take profit quantity second", minval=0)
takeprofitqt3 = input(30, title="take profit quantity third", minval=0)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////Strategy entries/////////////////////////////////////////////////////////////////////////////////////////
strategy.risk.max_intraday_filled_orders(maxx)
strategy.entry("long", strategy.long, when=long)
strategy.exit("tpl1", "long", qty_percent = takeprofitqt1, profit = takeprofit1 * p1)
strategy.exit("tpl2", "long", qty_percent = takeprofitqt2, profit = takeprofit2 * p1)
strategy.exit("tpl3", "long", qty_percent = takeprofitqt3, profit = takeprofit3 * p1)
strategy.close("long", when=stoplong == true)


strategy.entry("short", strategy.short, when=short)
strategy.exit("tpl1", "short", qty_percent = takeprofitqt1, profit = takeprofit1 * p1)
strategy.exit("tpl2", "short", qty_percent = takeprofitqt2, profit = takeprofit2 * p1)
strategy.exit("tpl3", "short", qty_percent = takeprofitqt3, profit = takeprofit3 * p1)
strategy.close("short", when=stopshort == true)
````

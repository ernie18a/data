# TMA All in One

- url: https://www.tradingview.com/script/E7hn1sKa/
- type: indicator
- pine_id: PUB;CUhvHzMTNUjHgxNuhC3pSsksrvGNbTUl
- version: 1.0

## Description

Triangular Moving Averages 
TMA formula is prepared on the Tradingview so that everyone can easly access. 

First, calculate the simple moving average ( SMA ): 
SMA = (P1 + P2 + P3 + P4 + ... + PN ) / N 
Then, take the average of all the SMA values to get TMA  values. 
TMA = (SMA1 + SMA2 + SMA3 + SMA4 + ... SMAN) / N 
The TMA can also be expressed 
Source : Close 

if the prices are upper than moving averages price bar color will be green, if lower than moving average it will be red color. 
İf the trend is bullish , TMA  will work as support 
İf the trend is bear, TMA will work as resistance.. 
 [image]https://www.tradingview.com/x/FtpXAV4E/[/image]

We used SMA5 ( Simple Moving Average5) 
İf short period average(Green), cross up Longterm average (brown) that means BUY ( Green area) 
İf opposite SELL ( Red area) 
 [image]https://www.tradingview.com/x/UgApyaQu/[/image]
My idea, weekly period gives very good results to middleterm and long term invesment..That can help us from which prices we can buy the stock which we think that financial results are positive.. 

The other topic; 
At the end, everytime prices return back to average values, and prices can move away until some distance. We can buy or sell with mixed prices, that can provide us better buy or sell average cost. 
in Default Settings; 
SELL 2.Area = 20% over than Longterm average, if the prices go upper that means prices are increased so much 
SELL 1.Area = 13% over than Longterm average, if the prices go upper that means prices are incresed a bit. 
BUY 1.Area = 3% lower than Longterm average, if the prices go upper that means prices are decreased a bit. 
BUY 2.Area = 10% lower than Longterm average, f the prices go upper that means prices are decreased so much 
[image]https://www.tradingview.com/x/yYNu3Nj1/[/image]
You can use this indicator in your interested stock market.. With checking historical behaviour of the related stock market, you can make balance on the indicator setting. 

According to averages, below BUY-SELL strategy is important, 
Powerful SELL 
1- Previosly İncrease 
2- Price cross down the long average line 
3- Short average,crossdown the long average 
4- Price approach to long average, but close the bar under this average 

Powerful BUY 
1. Previosly Decrease 
2. Price cross up the long average line 
3. Short average crossup the long average line 
4. Price approach to long average, but close the bar over this average

## Source Code

````pine
//@version=1
study("TMA All in One", overlay=true)

x = input(close, "Source")
n = input(10, "TMA Period", type=integer)
Simple = input(5, "SMA Period", type=integer)
sell1 = input(1.13, "SELL 1", type=float)
sell2 = input(1.2, "SELL 2", type=float)
buy1 = input(0.97, "BUY 1", type=float)
buy2 = input(0.9, "BUY 2", type=float)
basit = sma(x, Simple)
trima = sma(sma(x, n), n)

a1 = plot(trima,title='TMA', linewidth=2, color=maroon)
a2 = plot(basit,title='SMA ', linewidth=2, color=green)
plot(sell1 * trima,title='SELL 1.Area ', linewidth=2, color=red)
plot(sell2 * trima,title='SELL 2.Area ', linewidth=2, color=red)
plot(buy1 * trima,title='BUY 1.Area ', linewidth=2, color=green)
plot(buy2 * trima,title='BUY 2.Area ', linewidth=2, color=green)
barcolor(close < trima ? red : green)
fill(a1, a2, color = basit > trima ? green : red)
````

# CM RSI-2 Strategy - Upper Indicators.

- url: https://www.tradingview.com/script/4dCKsn7c-CM-RSI-2-Strategy-Upper-Indicators/
- type: indicator
- pine_id: PUB;567
- version: -1.0

## Description

RSI-2 Strategy 

***At the bottom of the page is a link where you can download the PDF of the Backtesting Results. 

This year I am focusing on learning from two of the best mentors in the Industry with outstanding track records for Creating Systems, and learning the what methods actually work as far as back testing.  

I came across the RSI-2 system that Larry Connors developed. Larry has become famous for his technical indicators, but his RSI-2 system is what actually put him “On The Map” per se. At first glance I didn’t think it would work well, but I decided to code it and ran backtests on the S&P 100 In Down Trending Markets, Up Trending Markets, and both combined. I was shocked by the results. So I thought I would provide them for you. I also ran a test on the Major forex Pairs (12) for the last 5 years, and All Forex Pairs (80) from 11/28/2007 - 6/09/2014, impressive results also.

The RSI-2 Strategy is designed to use on Daily Bars, however it is a short term trading strategy. The average length of time in a trade is just over 2 days. But the results CRUSH the general market averages. 

Detailed Description of Indicators, Rules Below:

Link For PDF of Detailed Trade Results 
http://d.pr/f/Q885

Original Post
https://www.tradingview.com/v/EVXQPaR9/

## Source Code

````pine
//Created by ChrisMoody 
//BarColor strategy for RSI-2 Paint Bars + 200SMA and 5 SMA
study("_CM_RSI_2_HB_MA", overlay=true)
src = close, 

//RSI Code
up = rma(max(change(src), 0), 2)
down = rma(-min(change(src), 0), 2)

rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))
rsi_up = rsi > 90
rsi_down = rsi < 10

//MovAvg's Code
ma5 = sma(close,5)
ma200= sma(close, 200)

//Rules for Bar Colors
isLongEntry() => close > ma200 and close < ma5 and rsi < 10

isLongExit() => close > ma200 and close[1] < ma5[1] and high > ma5 and ((close[1] > ma200[1] and close[1] < ma5[1] and rsi[1] < 10) or (close[2] > ma200[2] and close[2] < ma5[2] and rsi[2] < 10) or (close[3] > ma200[3] and close[3] < ma5[3] and rsi[3] < 10) or (close[4] > ma200[4] and close[4] < ma5[4] and rsi[4] < 10) )

isShortEntry() => close < ma200 and close > ma5 and rsi > 90

isShortExit() => close < ma200 and close[1] > ma5[1] and low < ma5 and ((close[1] < ma200[1] and close[1] > ma5[1] and rsi[1] > 90) or (close[2] < ma200[2] and close[2] > ma5[2] and rsi[2] > 90) or (close[3] < ma200[3] and close[3] > ma5[3] and rsi[3] > 90) or (close[4] < ma200[4] and close[4] > ma5[4] and rsi[4] > 90) )
//Rules For MA Colors
col = ma5 >= ma200 ? lime : ma5 < ma200 ? red : na
barcolor(isLongEntry() ? lime : na)
barcolor(isLongExit() ? yellow : na)
barcolor(isShortEntry() ? red : na)
barcolor(isShortExit() ? yellow : na)
plot(ma5, color=col, title="5 SMA", style=line, linewidth=3)
plot(ma200, color=col, title="200 SMA", style=circles, linewidth=3)
````

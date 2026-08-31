<!-- tradingview-pine-id: PUB;BhSRymxQyVzDBmugdJqpjKKldEl6ZzSp -->
<!-- tradingviewscripts-format: 1 -->
# Trend Following Moving Averages

Source: https://www.tradingview.com/script/9UiewdMD-Trend-Following-Moving-Averages/

## Description

While analysing a chart, one of the biggest problem is to see if there is trend or not. While thinking about it, I found the idea to analyse moving averages in channel and their momentum according to channel width. I already published it as Trend Following Bar as you see at bottom of the chart.

How it Works?

On each bar it creates a channel by highest/lowest point of a MA. highest point is upper line and lowest point is lower line of the MA channel,
It gets highest and lowest point of last 300 bars, (say Price Channel )
If the width of MA channel is greater than certain rate of price channel then it decides there is trend
After it decided there is trend, it calculates the rate between channel and MA. Bigger result means stronger trend.
According to rate of MA channel and the price channel , MA Line becomes lighter/darker. so when you look at the MA Line's color you can see the trend strength.

Some details about my idea: 
https://www.tradingview.com/x/JHn3FtwI

Options:

You can choose following MA types as source: EMA, SMA , RMA, WMA , VWMA
"Period to Check Trend" is the period to create MA channel. Bigger period cause more sensitivity.
"Trend Channel Rate %" is rate of price channel . Price channel created by using highest/lowest of last 300 bars. I did this to make the script works on all time frames correctly.
"Use Linear Regression" is used to get rid of noise. it may cause 1-2 bars latency.

Trend Following Bar script:
https://www.tradingview.com/script/UGgNcgNi-Trend-Following-Bar/

All comments are welcome!.

Enjoy!

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LonesomeTheBlue

//@version=4
study("Trend Following Moving Averages", overlay = true)
matype= input('EMA', title = "MA Type", options =['EMA', 'SMA', 'RMA', 'WMA', 'VWMA'])
prd = input(20, title = "Period to Check Trend", minval = 5)
rateinp = input(1, title = "Trend Channel Rate %", minval = 0.1, step = 0.1)
ulinreg = input(true, title = "Use Linear Regression")
linprd = input(10, title = "Linear Regression Period", minval = 2)

rate = rateinp / 100
pricerange = highest(280) - lowest(280)
chan = pricerange * rate
    
gettrend(len)=>
    masrc = matype == 'EMA' ? ema(close, len) : matype == 'RMA' ? rma(close, len) : matype == 'VWMA' ? vwma(close, len) : matype == 'WMA' ? wma(close, len) : sma(close, len)
    ma = ulinreg ? linreg(masrc, linprd, 0) : masrc
    
    hh = highest(ma, prd)
    ll = lowest(ma, prd)
    diff = abs(hh - ll)
    
    trend = iff(diff > chan, iff(ma > ll + chan, 1, iff(ma < hh - chan, -1, 0)), 0)
    _ret = trend * diff / chan
    _ret
    
getcol(trend)=>
    _ret = trend >= 10.0 ? #00FF00ff : trend >= 9.0 ? #00FF00ef : trend >= 8.0 ? #00FF00df : trend >= 7.0 ? #00FF00cf : trend >= 6.0 ? #00FF00bf :
       trend >= 5.0 ? #00FF00af : trend >= 4.0 ? #00FF009f : trend >= 3.0 ? #00FF008f : trend >= 2.0 ? #00FF007f : trend >= 1.0 ? #00FF006f :  
       trend <= -10.0 ? #FF0000ff : trend <= -9.0 ?  #FF0000ef : trend <= -8.0 ?  #FF0000df : trend <= -7.0 ?  #FF0000cf : trend <= -6.0 ?  #FF0000bf :
       trend <= -5.0 ?  #FF0000af : trend <= -4.0 ?  #FF00009f : trend <= -3.0 ?  #FF00008f : trend <= -2.0 ?  #FF00007f : trend <= -1.0 ?  #FF00006f :
       na
getma(lngth)=>
    _ret = matype == 'EMA' ? ema(close, lngth) : matype == 'RMA' ? rma(close, lngth) : matype == 'VWMA' ? vwma(close, lngth) : matype == 'WMA' ? wma(close, lngth) : sma(close, lngth)

plot(getma(5), color = getcol(gettrend(5)))
plot(getma(10), color = getcol(gettrend(10)))
plot(getma(15), color = getcol(gettrend(15)))
plot(getma(20), color = getcol(gettrend(20)))
plot(getma(25), color = getcol(gettrend(25)))
plot(getma(30), color = getcol(gettrend(30)))
plot(getma(35), color = getcol(gettrend(35)))
plot(getma(40), color = getcol(gettrend(40)))
plot(getma(45), color = getcol(gettrend(45)))
plot(getma(50), color = getcol(gettrend(50)))
plot(getma(55), color = getcol(gettrend(55)))
plot(getma(60), color = getcol(gettrend(60)))
plot(getma(65), color = getcol(gettrend(65)))
plot(getma(70), color = getcol(gettrend(70)))
plot(getma(75), color = getcol(gettrend(75)))
plot(getma(80), color = getcol(gettrend(80)))
plot(getma(85), color = getcol(gettrend(85)))
plot(getma(90), color = getcol(gettrend(90)))
plot(getma(95), color = getcol(gettrend(95)))
plot(getma(100), color = getcol(gettrend(100)))
````

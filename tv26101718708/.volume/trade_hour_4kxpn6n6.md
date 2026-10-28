# Trade Hour

- url: https://www.tradingview.com/script/4KxpN6N6-Trade-Hour/
- type: strategy
- pine_id: PUB;82d47d1bde6148419c250d93ee6b78c6
- version: 2.0

## Description

This script is just finds the best hour to buy and sell hour in a day by checking chart movements in past
For example if the red line is on the 0.63 on BTC/USDT chart it mean the start of 12AM hour on a day is the best hour to buy (all based on 
It's just for 1 hour time-frame but you can test it on other charts.
IMPORTANT: You can change time Zone in strategy settings.to get the real hours as your location timezone
IMPORTANT: Its for now just for BTC/USDT but you can optimize and test for other charts...
IMPORTANT: A green and red background color calculated for show the user the best places of buy and sell (green : positive signal, red: negative signals)

settings : 
timezone : We choice a time frame for our indicator as our geo location
source : A source to calculate rate of change for it
Time Period : Time period of ROC indicator


About Calculations:

1- We first get a plot that just showing the present hour as a zigzag plot
2- So we use an indicator ( Rate of change ) to calculate chart movements as positive and negative numbers. I tested ROC is the best indicator but you can test close-open or real indicator or etc as indicator.
3 - for observe effects of all previous data we should indicator_cum that just a full sum of indicator values.
4- now we need to split this effects to hours and find out which hour is the best place to buy and which is the best for sell. Ok we should just calculate multiple of hour*indicator and get complete sum of it so:
5- we will divide this number to indicator_cum : (indicator_mul_hour_cum) / indicator_cum
6- Now we have the best hour to buy! and for best sell we should just reverse the  ROC indicator and recalculate the best hour for it!
7- A green and red background color calculated for show the user the best places of buy and sell that dynamically changing with observing green and red plots(green : positive signal, red: negative signals) when green plot on 15 so each day on hour 15 the background of strategy indicator will change to 15 and if its go upper after some days and reached to 16 the background green color will move to 16 dynamically.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mablue (Masoud Azizi)
// based on idea of circular mean with atan2

//@version=5
strategy("Trade Hour V4",overlay=false)
src = input.source(close)
timezone = input.string("UTC+0000",options=["UTC+0000","GMT+0000","America/New_York","America/Los_Angeles","America/Chicago","America/Phoenix","America/Toronto","America/Vancouver","America/Argentina" ,"America/El_Salvador","America/Sao_Paulo","America/Bogota","Europe/Moscow","Europe/Athens","Europe/Berlin","Europe/London","Europe/Madrid","Europe/Paris","Europe/Warsaw","Australia/Sydney","Australia/Brisbane","Australia/Adelaide","Australia/ACT","Asia/Almaty","Asia/Ashkhabad","Asia/Tokyo","Asia/Taipei","Asia/Singapore","Asia/Shanghai","Asia/Seoul","Asia/Tehran","Asia/Dubai","Asia/Kolkata","Asia/Hong_Kong","Asia/Bangkok","Pacific/Auckland","Pacific/Chatham","Pacific/Fakaofo","Pacific/Honolulu"]	)
length = input.int(24,"Timeperiod")



arctan2(x,y)=>
    if x>0 and y>0
        result = math.atan(x/y) 
    else if y<0
        result = math.atan(x/y) + math.pi
    else if x<0 and y>0
        result = math.atan(x/y) + 2*math.pi




best_hour(indicator)=>
    hours = (2*math.pi)*(hour(time,timezone)/24)
    hours_y =  math.sin(hours)
    hours_x =  math.cos(hours)

    hours_x_avg = ta.cum(hours_x*indicator)/ta.cum(indicator)
    hours_y_avg = ta.cum(hours_y*indicator)/ta.cum(indicator)
    hours_avg = (arctan2(hours_y_avg,hours_x_avg)*24/(2*math.pi))%24


buy_indicator = math.avg(ta.rsi(src,length),ta.mfi(src,length))
sell_indicator = math.avg(ta.rsi(1/src,length),ta.mfi(1/src,length))

// buy_indicator = ta.roc(src,length)
// sell_indicator = ta.roc(1/src,length)

// buy_indicator = ta.roc(src,length)
// sell_indicator = ta.roc(1/src,length)


buy_hour = best_hour(buy_indicator)
sell_hour = best_hour(sell_indicator)


plot(buy_hour,"Buy hour",color.green)
plot(sell_hour,"Sell hour",color.red)



bool isLongBestHour = math.round(buy_hour) == hour(time,timezone)
bool isShortBestHour =   math.round(sell_hour) == hour(time,timezone)

bgcolor(isLongBestHour ? color.new(color.green,80) : na)
bgcolor(isShortBestHour ? color.new(color.red,80) : na)
strategy.order("buy", strategy.long, when =isLongBestHour)
strategy.order("sell", strategy.short, when = isShortBestHour)
````

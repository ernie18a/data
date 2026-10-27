# Double EMA CROSS

- url: https://www.tradingview.com/script/mVplGpsd-Double-EMA-CROSS/
- type: strategy
- pine_id: PUB;KI17NbJACmpO0cxvl5XVg6eavM7yrShu
- version: 1.0

## Description

[symbol="FTX:BTCPERP"]
[image]https://www.tradingview.com/x/4Wa2k0qF/[/image]

Double EMA CROSS (DEC)

Useful for identifying and receiving alerts about uptrends and downtrends.

This script uses two Exponential Moving Averages (EMAs) to find price uptrends and downtrends. 
An Exponential Moving Average ( EMA ) is a type of moving average that places a greater weight and significance on the most recent data points. 
The script produces uptrend and downtrend signals based on crossovers and divergences between the two EMAs, 
the user will be able to spot a trend change (when the EMAs crossover) and to determine the strength of the current trend (when the EMAs diverge). 
It is also posible to get alerts for uptrends and downtrends on the web and mobile app with sound and pop-ups as well as via email. 
The optimal time to enter and exit the market can be concluded from this trend changes.

The user can set their own EMAs, by default they are set to 25 and 75 periods for medium and long term respectively.
When the medium term EMA crosses below the long term EMA the asset is in a downtrend and the price will decline, and when the 
medium term EMA crosses above the long term EMA the asset is in an uptrend and price will increase.

This scripts plots the following indicators and signals on the chart to help the user to identify trends:

1.- Medium and long term EMAs as lines overlaid on the price chart.
2.- Up green triangles above bars when the price is on an uptrend and down red triangles below bars when the price is on a downtrend.
3.- Arrows with text to indicate the start of an uptrend or downtrend.

The user can enable and disable the indicators and signals as well as set colors and shapes to their liking.

This script also lets the user create alerts for uptrends and downtrends. To create a new alert using this script follow this instructions:

1.- Once you added this script to your chart, go to the alerts panel (right on web or bottom tool bar on the mobile app) and add a new alert (alarm clock icon with a plus sign).
2.- A modal window will open. On the “Condition” dropdown menu select “DEC”.
3.- On the next dropdown menu (right below the “Condition” one) you can select.
4.- Lastly you can set all the normal alert options and create the alert.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Double EMA CROSS By © EmreE (Emre Ertürk) Also thx for KivancOzbilgic color based bars

//@version=4
strategy(title="Double EMA CROSS", shorttitle="DEC", overlay=true)

matype = input("ema")
hidema = input(false)
sourcetype = input(close, title="Source Type")
source=close
 
// STEP 1:
// Configure backtest start date with inputs
startDate = input(title="Start Date", type=input.integer,
     defval=1, minval=1, maxval=231)
startMonth = input(title="Start Month", type=input.integer,
     defval=1, minval=1, maxval=12) 
startYear = input(title="Start Year", type=input.integer,
     defval=2020, minval=1800, maxval=2100)

// STEP 2:
// See if this bar's time happened on/after start date
afterStartDate = (time >= timestamp(syminfo.timezone,
     startYear, startMonth, startDate, 0, 0))

fast = input(25, title="Fast")
slow = input(75, title="Slow")

matype1=ema(source, fast)
matype2=ema(source, slow)


signalcolor = source > matype2 ? color.blue : color.red
signal = cross(fast, slow) 



hizliema=plot(hidema ? na : matype1, color=color.green, linewidth=2,transp=0, title="Fast EMA")
yavasema=plot(hidema ? na : matype2, color=color.red, linewidth=2,transp=0, title="Slow EMA")
//kesisme=plot(signal, style=cross, color=signalcolor, linewidth=5, title="Kesişme")
 

longCondition = crossover(matype1, matype2)
if (afterStartDate and longCondition)
    strategy.entry("Long", strategy.long)

shortCondition = crossunder(matype1, matype2)
if (afterStartDate and shortCondition)
    strategy.entry("Short", strategy.short)
    

//--------------------------------------------------------

//volume based color bars
length=input(21, "length", minval=1)
avrg=sma(volume,length)

vold1 = volume > avrg*1.5 and close<open
vold2 = volume >= avrg*0.5 and volume<=avrg*1.5 and close<open
vold3 = volume < avrg *0.5 and close<open

volu1 = volume > avrg*1.5 and close>open
volu2 = volume >= avrg*0.5 and volume<=avrg*1.5 and close>open
volu3 = volume< avrg*0.5 and close>open

cold1=#800000
cold2=#FF0000
cold3=color.orange

colu1=#006400
colu2=color.lime
colu3=#7FFFD4

ac = vold1 ? cold1 : vold2 ? cold2 : vold3 ? cold3 : volu1 ? colu1 : volu2 ? colu2 : volu3 ? colu3 : na

barcolor(ac)
````

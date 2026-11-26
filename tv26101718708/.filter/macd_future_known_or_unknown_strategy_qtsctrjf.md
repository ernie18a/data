# MacD (Future Known or Unknown) Strategy

- url: https://www.tradingview.com/script/qTSctRJf-MacD-Future-Known-or-Unknown-Strategy/
- type: strategy
- pine_id: PUB;IDwuhoZmevZtXpnIiCQEfkyV9xy4qPtn
- version: 1.0

## Description

This indicator/strategy is to be used as a way to[b] baseline the top potential any strategy could have with other strategies and indicators.[/b]

What I have created literally shows the [b]BEST moves possible you could have made in my opinion for SHORTING or LONGING using only the MacD values of the 4 hour while on the 30 minute chart.[/b]

To use this, try checking out[b] XBTUSD on the 30 minute chart[/b].  It will work under different time frames but works best on the 30 minute chart in my opinion. [b] It WILL NOT WORK Above 2 hours time frame.[/b]

[b]DO NOT TRADE WITH THIS indicator[/b].  I can't emphasize this enough.  These results only work because of the [b]lookahead_on[/b] parameter.  A lot of scam indicators and strategies use this to trick people on tradingView into buying their scripts.

This code is OPEN SOURCE and as such there is nothing to hide and no scam!

I like to use this as a comparison tool for how good I 'could' have traded and at what points those were.  By knowing where the perfect trading positions are, you can create real indicators and scripts that try to find patterns in those positions.

This also shows that IF you could know the direction the MacD was going what amazing results you could get ^_~.

This is meant purely for entertainment purposes and for comparing against your own scripts.

I've included the options in the settings to allow ONLY LONG or ONLY SHORTS.  By default it attempts both buy attempts.  You can also change your starting ($) amount and commission percentage that is taken per trade as well.

Also included in the options is the ability to set the back testing time frame to see how it performs during just certain time periods.

Finally a color explanation

[list]
[*]Red - MacD 4 hour going down
[*]Green - MacD 4 hour going up
[*]Purple - MacD 4 hour going down (from an up position)
[*]Yellow - MacD 4 hour going up (from a down position)
[/list]

Notice the program will always buy right before it turns into a yellow color since it knows the future.

In the options [b]you can turn off 'use the future' to see the horrible results[/b] if you trade the moment you know which direction the MacD 4 hour is actually going.  I will revise this script in the future with attempts to work without knowing the future as play options to get better results.

If you have any questions or comments, please do not hesitate to ask!

## Source Code

````pine
// @version=4
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © x11joe
strategy(title="MacD (Future Known or Unknown) Strategy", overlay=false, precision=2,commission_value=0.26, initial_capital=10000, currency=currency.USD, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

//OPTIONAL:: Allow only entries in the long or short position
allowOnlyLong = input(title="Allow position ONLY in LONG",type=input.bool, defval=false)
allowOnlyShort = input(title="Allow position ONLY in SHORT",type=input.bool, defval=false)


strategy.risk.allow_entry_in(allowOnlyLong ? strategy.direction.long : allowOnlyShort ? strategy.direction.short : strategy.direction.all) // There will be no short entries, only exits from long.

// Create MacD inputs
fastLen = input(title="MacD Fast Length", type=input.integer, defval=12)
slowLen = input(title="MacD Slow Length", type=input.integer, defval=26)
sigLen  = input(title="MacD Signal Length", type=input.integer, defval=9)

// Get MACD values
[macdLine, signalLine, _] = macd(close, fastLen, slowLen, sigLen)
hist = macdLine - signalLine

useFuture = input(title="Use The Future?",type=input.bool,defval=true)

macDState(resolutionType) =>
    hist_from_resolution = security(syminfo.tickerid, resolutionType, hist,barmerge.gaps_off, barmerge.lookahead_on)
    Green_IsUp = hist_from_resolution > hist_from_resolution[1] and hist_from_resolution > 0
    Green_IsDown = hist_from_resolution < hist_from_resolution[1] and hist_from_resolution > 0
    Red_IsDown = hist_from_resolution < hist_from_resolution[1] and hist_from_resolution <= 0
    Red_IsUp = hist_from_resolution > hist_from_resolution[1] and hist_from_resolution <= 0
    result=0
    if(Green_IsUp)
        result := 1
    if(Green_IsDown)
        result := 2
    if(Red_IsDown)
        result := 3
    if(Red_IsUp)
        result := 4
    result

macDStateNonFuture(resolutionType) =>
    hist_from_resolution = security(syminfo.tickerid, resolutionType, hist,barmerge.gaps_off, barmerge.lookahead_off)
    Green_IsUp = hist_from_resolution > hist_from_resolution[1] and hist_from_resolution > 0
    Green_IsDown = hist_from_resolution < hist_from_resolution[1] and hist_from_resolution > 0
    Red_IsDown = hist_from_resolution < hist_from_resolution[1] and hist_from_resolution <= 0
    Red_IsUp = hist_from_resolution > hist_from_resolution[1] and hist_from_resolution <= 0
    result=0
    if(Green_IsUp)
        result := 1
    if(Green_IsDown)
        result := 2
    if(Red_IsDown)
        result := 3
    if(Red_IsUp)
        result := 4
    result

// === INPUT BACKTEST RANGE ===
FromMonth = input(defval = 1, title = "From Month", minval = 1, maxval = 12)
FromDay   = input(defval = 1, title = "From Day", minval = 1, maxval = 31)
FromYear  = input(defval = 2019, title = "From Year", minval = 2017)
ToMonth   = input(defval = 1, title = "To Month", minval = 1, maxval = 12)
ToDay     = input(defval = 1, title = "To Day", minval = 1, maxval = 31)
ToYear    = input(defval = 9999, title = "To Year", minval = 2017)

start     = timestamp(FromYear, FromMonth, FromDay, 00, 00)  // backtest start window
finish    = timestamp(ToYear, ToMonth, ToDay, 23, 59)        // backtest finish window
window()  => time >= start and time <= finish ? true : false // create function "within window of time"
// === INPUT BACKTEST RANGE END ===

//Get FUTURE or NON FUTURE data
macDState240=useFuture ? macDState("240") : macDStateNonFuture("240") //1 is green up, 2 if green down, 3 is red, 4 is red up

//Fill in the GAPS
if(macDState240==0)
    macDState240:=macDState240[1]

//Plot Positions
plot(close,color= macDState240==1 ? color.green : macDState240==2 ? color.purple : macDState240==3 ? color.red : color.yellow,linewidth=4,style=plot.style_histogram,transp=50)

if(useFuture)
    strategy.entry("buy_1",long=true,when=window() and (macDState240==4 or macDState240==1))
    strategy.close("buy_1",when=window() and macDState240==3 and macDState240[1]==4)
    strategy.entry("sell_1",long=false,when=window() and macDState240==2)
else
    strategy.entry("buy_1",long=true,when=window() and (macDState240==4 or macDState240==1))//If we are in a red macD trending downwards MacD or in a MacD getting out of Red going upward.
    strategy.close("buy_1",when=window() and macDState240==3 and macDState240[1]==4)//If the state is going upwards from red but we are predicting back to red...
    strategy.entry("sell_1",long=false,when=window() and macDState240==2)//If we are predicting the uptrend to end soon.
````

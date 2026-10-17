# PB SAR BackTest - Colorbar

- url: https://www.tradingview.com/script/bNWhlAJI-PB-SAR-BackTest-Colorbar/
- type: strategy
- pine_id: PUB;t4fn4p3nvADNJXIcRijZGIwYUoDieweY
- version: 9.0

## Description

Indicator with buy/sell alerts for setup/trigger conditions

Built upon Peterbolic SAR current version as of publishing

## Source Code

````pine
//@version=4
strategy("Peterbolic SAR BackTest - Colorbar", overlay=false)

// Full credit to Sawcruhteez, Lucid Investment Strategies LLC, Casey Bowman and Peter Brandt.
// This is a strategy version of the Peterbolic SAR indicator created by the above-mentioned parties.
// Original version of the indicator: https://www.tradingview.com/script/6nYrH3Vm-Peterbolic-SAR/

// SAR #1
// Lucid Sar
// Branded under the name "Lucid SAR"
// as agreed to with Lucid Investment Strategies LLC on July 9, 2019
// https://lucidinvestmentstrategies.com/
// see branch "lucid"

// SAR #2
// Peterbolic Sar
// Using the name "Peterbolic SAR"
// as agreed to by Peter Brandt on October 2, 2019
// - https://twitter.com/PeterLBrandt/status/1179365590668075008
// in response to request from Sawcruhteez
// - https://twitter.com/Sawcruhteez/status/1179213105705836544
// Sawcruhteez gives credit to @CrazyGabey for coming up with the name
// - https://twitter.com/Sawcruhteez/status/1179213196583940097
// see branch "peterbolic"

// SAR #3
// Sawcruhteez Sar
// Branded under the name "Sawcruhteez SAR"
// as agreed to with Sawcruhteez on September 11, 2019
// see branch "sawcruhteez"

// Open Source on github
// https://github.com/casey-bowman/sar/blob/peterbolic/peterbolic.pine

// Created by Casey Bowman on July 4, 2019

// MIT License

// Copyright (c) 2019 Casey Bowman

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

UseHA = input(title="Use Heiken Ashi Values?", type=input.bool, defval=false)
BBt = input(title="Bolinger Bands Lookback", type=input.integer, defval=20)
BBNormalizer = input(title="Bolinger Bands Normalizer", type=input.float, defval=1.2)

// Make input options that configure backtest date range
StartMonth = input(title="Start Month", type=input.integer,
     defval=1, minval=1, maxval=12)
StartDate = input(title="Start Date", type=input.integer,
     defval=1, minval=1, maxval=31)
StartYear = input(title="Start Year", type=input.integer,
     defval=(2019), minval=1800, maxval=2100)

EndMonth = input(title="End Month", type=input.integer,
     defval=1, minval=1, maxval=12)
EndDate = input(title="End Date", type=input.integer,
     defval=1, minval=1, maxval=31)
EndYear = input(title="End Year", type=input.integer,
     defval=(2020), minval=1800, maxval=2100)
     
// Look if the close time of the current bar falls inside the date range
inDateRange = (time >= timestamp(syminfo.timezone, StartYear, StartMonth, StartDate, 0, 0)) and (time < timestamp(syminfo.timezone, EndYear, EndMonth, EndDate, 0, 0))

t = tickerid(syminfo.prefix, syminfo.ticker, session.regular, adjustment.splits)

actual_close = security(t, timeframe.period, close)
actual_open = security(t, timeframe.period, open)
actual_high = security(t, timeframe.period, high)
actual_low = security(t, timeframe.period, low)

TSR() =>

    haClose = UseHA ? ((actual_close + actual_open + actual_high + actual_low) / 4) : close
    haOpen  = float(na)
    haOpen := UseHA ? na(haOpen[1]) ? (actual_open + actual_close) / 2 : (nz(haOpen[1]) + nz(haClose[1])) / 2 : open
    haHigh  = UseHA ? max(actual_high, max(haOpen, haClose)) : high
    haLow   = UseHA ? min(actual_low, min(haOpen, haClose)) : low

// start with uptrend
    var uptrend = true
    var EP = haHigh       // extreme price - haHigh or haLow depending on trend
    var SP = haLow        // setup price
    var TP = float(na)  // trigger price

    var setup   = haLow
    var trigger = float(na)

    if barstate.isnew
        setup := haLow
        trigger = float(na)

    extreme_candle = false
    first_extreme_candle = false
    setup_candle = false
    trigger_candle = false

    waiting_for_setup = false
    waiting_for_trigger = false

    var since_extreme = 0
    var since_setup = 0

    waiting_for_setup   := not extreme_candle and not na(SP)
    waiting_for_trigger := not na(TP)

    if not barstate.isfirst
        if barstate.isnew and extreme_candle[1]
            trigger := float(na)
        if barstate.isnew and setup_candle[1]
            setup := float(na)
        if barstate.isnew and waiting_for_trigger
            since_setup := since_setup + 1
            trigger := TP
        if barstate.isnew and waiting_for_setup
            since_extreme := since_extreme + 1
            setup := SP
        if uptrend

            if extreme_candle
                EP := haHigh
                SP := haLow
            else
                if haHigh > EP
                    extreme_candle := true
                    EP := haHigh
                    SP := haLow
                    since_extreme := 0
                    since_setup   := 0
                else
                    if waiting_for_setup
                        if barstate.isconfirmed
                            if haClose < SP
                                setup_candle := true
                                SP := float(na)
                                TP := haLow
            if waiting_for_trigger
                if haLow < TP
                    trigger_candle := true
                    extreme_candle := true
                    EP := haLow
                    SP := haHigh
                    TP := float(na)
                    uptrend := false
                    since_extreme := 0
                    since_setup := 0
                else
                    if barstate.isconfirmed and extreme_candle
                        TP := float(na)
                        trigger := float(na)

        else
            if extreme_candle
                EP := haLow
                SP := haHigh
            else
                if haLow <  EP
                    extreme_candle := true
                    EP := haLow
                    SP := haHigh
                    since_extreme := 0
                    since_setup   := 0
                else
                    if waiting_for_setup
                        if barstate.isconfirmed
                            if haClose > SP
                                setup_candle := true
                                SP := float(na)
                                TP := haHigh
            if waiting_for_trigger
                if haHigh > TP
                    trigger_candle := true
                    extreme_candle := true
                    EP := haHigh
                    SP := haLow
                    TP := float(na)
                    uptrend := true
                    since_extreme := 0
                    since_setup := 0
                else
                    if barstate.isconfirmed and extreme_candle
                        TP := float(na)
                        trigger := float(na)

    [trigger_candle, trigger, since_setup, setup_candle, setup, since_extreme, extreme_candle, uptrend]


[TC, T, SS, SC, S, SE, EC, up] = TSR()

src = close

Multiplier = 2

// Essential Functions : 
f_sum(_src , _length) => 
    _output  = 0.00 
    
    _length_adjusted = _length < 1 ? 1 : _length
    
    for i = 0 to _length_adjusted-1
        _output := _output + _src[i]
        

// Unlocked Exponential Moving Average Function
f_ema(_src, _length)=>
    _length_adjusted = _length < 1 ? 1 : _length
    _multiplier = 2 / (_length_adjusted + 1)
    _return  = 0.00
    _return := na(_return[1]) ? _src : ((_src - _return[1]) * _multiplier) + _return[1]

// Unlocked Moving Average Function 
f_sma(_src, _length)=>
    
    _output = 0.00
    _length_adjusted = _length < 0 ? 0 : _length
    w = cum(_src)

    _output:= (w - w[_length_adjusted]) / _length_adjusted
   
    _output    
   

// Function Standard Deviation : 
f_stdev(_src,_length) =>

    float _output = na 
    _length_adjusted = _length < 2 ? 2 : _length
    _avg  = f_ema(_src , _length_adjusted)
    evar  = (_src - _avg) * (_src - _avg)
    evar2 = ((f_sum(evar,_length_adjusted))/_length_adjusted)
    
    _output := sqrt(evar2)

e = f_ema(src,BBt)
std = f_stdev(src , BBt)

upband = e + (Multiplier * std)
dnband = e - (Multiplier * std)
basis  = e

BBAVG = max(round((((upband-dnband) / BBt) / BBNormalizer) / Multiplier), 0.5)

buytrigger = (TC and up)
selltrigger = (TC and not up)
buysetup = (SC and not up)
sellsetup = (SC and up)

iSC = SC ? 0.5 : 0
iTC = TC ? 1 : 0
iUP = BBAVG * (up ? 1 : -1)

NUM = ((iTC - iSC) * iUP)

linecolor = color.orange
upcolor = color.purple
bgcolor = SC ? color.yellow : (TC ? (up ? color.green : color.red) : color.black)
bgcolor(bgcolor, 50)

plot(NUM, color=linecolor, linewidth=2)
plot(abs(iUP), color=upcolor, linewidth=3)


//TC - True if current candle is trigger candle
//T - True if previous candle is within range (between high/low) since last setup candle
//SS - True when setup awaiting
//SC - True when setup candle
//S - True if previous candle is NOT a setup candle
//SE - Opposite of EC (below)
//EC - True when the current candle breaks the previous high/low in the direction of current trend
//up - True when in uptrend(long) // Up starting with green, down starting with red

alertcondition(buysetup, title="Buy Setup", message="Buy Setup | #Offset {{plot_1}}")
alertcondition(buytrigger, title="Buy Trigger", message="Buy Trigger | #Offset {{plot_1}}")

alertcondition(sellsetup, title="Sell Setup", message="Sell Setup | #Offset {{plot_1}}")
alertcondition(selltrigger, title="Sell Trigger", message="Sell Trigger | #Offset {{plot_1}}")

// alertcondition((SC and not up), title="Buy Setup TEST", message="TEST Buy Setup")
// alertcondition((TC and up), title="Buy Trigger TEST", message="TEST Buy Trigger")

// alertcondition((SC and up), title="Sell Setup TEST", message="TEST Sell Setup")
// alertcondition((TC and not up), title="Sell Trigger TEST", message="TEST Sell Trigger")

// //Switch on for strategy moves
if(inDateRange and buysetup)
    //strategy.exit("SHORT", "SHORT_SL", comment="Short_Exit")
    strategy.cancel("LONG")
    strategy.order("LONG", strategy.long, stop=actual_high + BBAVG, comment="")
    strategy.entry("LONG", strategy.long, stop=actual_high + BBAVG, comment="")
if(inDateRange and sellsetup)
    //strategy.exit("LONG", "LONG_SL", comment="Long_Exit")
    strategy.cancel("SHORT")
    strategy.order("SHORT", strategy.short, stop=actual_low - BBAVG, comment="")
    strategy.entry("SHORT", strategy.short, stop=actual_low - BBAVG, comment="")

// if(inDateRange and buytrigger)
//     strategy.exit("SHORT", "SHORT_SL", comment="Short_Exit")
//     strategy.entry("LONG", strategy.long, stop=actual_high+1, comment="")
// if(inDateRange and selltrigger)
//     strategy.exit("LONG", "LONG_SL", comment="Long_Exit")
//     strategy.entry("SHORT", strategy.short, stop=actual_low-1, comment="")

if (not inDateRange)
    strategy.close_all()


// plotshape(SC and not up, color = color.yellow, style = shape.triangleup, location = location.belowbar, size = size.auto, transp = 0, title = "Setup to Buy")
// plotshape(TC and up, color = color.green, style = shape.triangleup, location = location.belowbar, size = size.auto, title = "Trigger to Buy")
// plotshape(SC and up, color = color.yellow, style = shape.triangledown, location = location.abovebar, size = size.auto, transp = 0, title = "Setup to Sell")
// plotshape(TC and not up, color = color.red, style = shape.triangledown, location = location.abovebar, size = size.auto, title = "Trigger to Sell")
````

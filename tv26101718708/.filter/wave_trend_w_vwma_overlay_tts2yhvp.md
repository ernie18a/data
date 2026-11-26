# Wave Trend w/ VWMA overlay

- url: https://www.tradingview.com/script/Tts2YhVP-Wave-Trend-w-VWMA-overlay/
- type: strategy
- pine_id: PUB;k5XrcCWRbS24WsV78BO4tCUqMWyjpRJb
- version: 2.0

## Description

This is a trend-following strategy and indicator which combines the [url=https://www.tradingview.com/script/8fjvDU2x-Wave-Trend-Strategy-Lazy-Bear/]Wave Trend Strategy (Lazy Bear)[/url] by [url=https://www.tradingview.com/u/thomas.gigure/]thomas.gigure[/url] with the [url=https://www.tradingview.com/script/mcr9VUaB-cRSI-Waves-Strategy-with-VWMA-overlay/]cRSI + Waves Strategy with VWMA overlay[/url] by [url=https://www.tradingview.com/u/Dr_Roboto/]Dr_Roboto[/url].

You may update the parameters of the Wave Trend oscillator or the VWMA indicator to match your own preferences.  You may also adjust the [b]Base Quantity[/b] used for determining trade size (as described below) to suit your account size and risk tolerance.

The strategy identifies potential signals based on the on the Wave Trend oscillator, originally ported to TradingView by LazyBear.  When a signal is produced by the Wave Trend oscillator, trade size is determined by the VWMA.

[list]
[*] When the VWMA is trending against the direction of the Wave Trend signal, Base Quantity x 1 is used
[*] When the VWMA is trending neutral, Base Quantity x 2 is used
[*] When the VWMA is trending with the direction of the Wave Trend signal, Base Quantity x 4 is used
[/list]

The strategy includes the ability to limit trade signals to certain defined periods of time ("Sessions") during the trading day and, optionally, to close any open position at the end of either or both "Sessions."  This may be enabled/disabled via the [b]Limit Signals to Trading Sessions?[/b] option on the "Inputs" tab of the strategy's "Settings" window.

If you are trading on a daily chart (or longer) you must disable the [b]Limit Signals to Trading Sessions?[/b] in order for the strategy to produce signals.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at
// https://mozilla.org/MPL/2.0/
//
// Created by jadamcraig 
// 
// This strategy benefits from extracts taken from the following
// studies/authors.  Thank you for developing and sharing your ideas in an open
// way!
//  * Wave Trend Strategy by thomas.gigure
//  * cRSI + Waves Strategy with VWMA overlay by Dr_Roboto
//
//@version=4

//==============================================================================
//==============================================================================
overlay = true  // plots VWMA (need to close and re-add)
//overlay = false // plots Wave Trend (need to close and re-add)

strategy("Wave Trend w/ VWMA overlay", overlay=overlay)
     
baseQty = input(defval=1, title="Base Quantity", type=input.float, minval=1)

useSessions = input(defval=true, title="Limit Signals to Trading Sessions?")
sess1_startHour = input(defval=8, title="Session 1: Start Hour",
     type=input.integer, minval=0, maxval=23)
sess1_startMinute = input(defval=25, title="Session 1: Start Minute",
     type=input.integer, minval=0, maxval=59)
sess1_stopHour = input(defval=10, title="Session 1: Stop Hour",
     type=input.integer, minval=0, maxval=23)
sess1_stopMinute = input(defval=25, title="Session 1: Stop Minute",
     type=input.integer, minval=0, maxval=59)
sess2_startHour = input(defval=12, title="Session 2: Start Hour",
     type=input.integer, minval=0, maxval=23)
sess2_startMinute = input(defval=55, title="Session 2: Start Minute",
     type=input.integer, minval=0, maxval=59)
sess2_stopHour = input(defval=14, title="Session 2: Stop Hour",
     type=input.integer, minval=0, maxval=23)
sess2_stopMinute = input(defval=55, title="Session 2: Stop Minute",
     type=input.integer, minval=0, maxval=59)
sess1_closeAll = input(defval=false, title="Close All at End of Session 1")
sess2_closeAll = input(defval=true, title="Close All at End of Session 2")

//==============================================================================
//==============================================================================
//                    Volume Weighted Moving Average (VWMA)
//==============================================================================
//==============================================================================
plotVWMA = overlay

// check if volume is available for this equity
useVolume = input(
     title="VWMA: Use Volume (uncheck if equity does not have volume)",
     defval=true)

vwmaLen = input(defval=21, title="VWMA: Length", type=input.integer, minval=1,
     maxval=200)
vwma = vwma(close, vwmaLen)
vwma_high = vwma(high, vwmaLen)
vwma_low = vwma(low, vwmaLen)

if not(useVolume)
    vwma := wma(close, vwmaLen)
    vwma_high := wma(high, vwmaLen)
    vwma_low := wma(low, vwmaLen)

// +1 when above, -1 when below, 0 when inside
vwmaSignal(priceOpen, priceClose, vwmaHigh, vwmaLow) =>
    sig = 0
    color = color.gray
    if priceClose > vwmaHigh
        sig := 1
        color := color.green
    else if priceClose < vwmaLow
        sig := -1
        color := color.red
    else
        sig := 0
        color := color.gray
    [sig,color]

[vwma_sig, vwma_color] = vwmaSignal(open, close, vwma_high, vwma_low)

priceAboveVWMA = vwma_sig ==  1 ? true : false
priceBelowVWMA = vwma_sig == -1 ? true : false
// plot(priceAboveVWMA?2.0:0,color=color.blue)
// plot(priceBelowVWMA?2.0:0,color=color.maroon)

//bandTrans = input(defval=70, title="VWMA Band Transparancy (100 invisible)",
//     type=input.integer, minval=0, maxval=100)
//fillTrans = input(defval=70, title="VWMA Fill Transparancy (100 invisible)",
//     type=input.integer, minval=0, maxval=100)
bandTrans = 60
fillTrans = 60

// ***** Plot VWMA *****
highband = plot(plotVWMA?fixnan(vwma_high):na, title='VWMA High band', 
     color = vwma_color, linewidth=1, transp=bandTrans)
lowband = plot(plotVWMA?fixnan(vwma_low):na, title='VWMA Low band',
     color = vwma_color, linewidth=1, transp=bandTrans)
fill(lowband, highband, title='VWMA Band fill', color=vwma_color,
     transp=fillTrans)
plot(plotVWMA?vwma:na, title='VWMA', color = vwma_color, linewidth=3,
     transp=bandTrans)

//==============================================================================
//==============================================================================
//                                  Wave Trend
//==============================================================================
//==============================================================================
plotWaveTrend = not(overlay)

n1 = input(10, "Wave Trend: Channel Length")
n2 = input(21, "Wave Trend: Average Length")
obLevel1 = input(60, "Wave Trend: Over Bought Level 1")
obLevel2 = input(53, "Wave Trend: Over Bought Level 2")
osLevel1 = input(-60, "Wave Trend: Over Sold Level 1")
osLevel2 = input(-53, "Wave Trend: Over Sold Level 2")

ap = hlc3 
esa = ema(ap, n1)
d = ema(abs(ap - esa), n1)
ci = (ap - esa) / (0.015 * d)
tci = ema(ci, n2)
 
wt1 = tci
wt2 = sma(wt1,4)

plot(plotWaveTrend?0:na, color=color.gray)
plot(plotWaveTrend?obLevel1:na, color=color.red)
plot(plotWaveTrend?osLevel1:na, color=color.green)
plot(plotWaveTrend?obLevel2:na, color=color.red, style=3)
plot(plotWaveTrend?osLevel2:na, color=color.green, style=3)

plot(plotWaveTrend?wt1:na, color=color.green)
plot(plotWaveTrend?wt2:na, color=color.red, style=3)
plot(plotWaveTrend?wt1-wt2:na, color=color.blue, transp=80)

//==============================================================================
//==============================================================================
//                               Order Management
//==============================================================================
//==============================================================================
// Define Long and Short Conditions
longCondition = crossover(wt1, wt2)
shortCondition = crossunder(wt1, wt2)

// Define Quantities
orderQty = baseQty * 2
if (longCondition)
    if (vwma_sig == 1)
        if ( strategy.position_size >= (baseQty * 4 * -1) and 
             strategy.position_size < 0 )
            orderQty := baseQty * 4 + abs(strategy.position_size)
        else
            orderQty := baseQty * 4
    else if (vwma_sig == 0)
        if ( strategy.position_size >= (baseQty * 2 * -1) and 
             strategy.position_size < 0 )
            orderQty := baseQty * 2 + abs(strategy.position_size)
        else
            orderQty := baseQty * 2
    else if (vwma_sig == -1)
        if ( strategy.position_size >= (baseQty * 1 * -1) and 
             strategy.position_size < 0 )
            orderQty := baseQty * 1 + abs(strategy.position_size)
        else
            orderQty := baseQty * 1
else if (shortCondition)
    if (vwma_sig == -1)
        if ( strategy.position_size <= (baseQty * 4) and 
             strategy.position_size > 0 )
            orderQty := baseQty * 4 + strategy.position_size
        else
            orderQty := baseQty * 4
    else if (vwma_sig == 0)
        if ( strategy.position_size <= (baseQty * 2) and 
             strategy.position_size > 2 )
            orderQty := baseQty * 2 + strategy.position_size
        else
            orderQty := baseQty * 2
    else if (vwma_sig == 1)
        if ( strategy.position_size <= (baseQty * 1) and 
             strategy.position_size > 0 )
            orderQty := baseQty * 1 + strategy.position_size
        else
            orderQty := baseQty * 1

// Determine if new trades are permitted
newTrades = false
if (useSessions)
    if ( hour == sess1_startHour and minute >= sess1_startMinute )
        newTrades := true
    else if ( hour > sess1_startHour and hour < sess1_stopHour )
        newTrades := true
    else if ( hour == sess1_stopHour and minute < sess1_stopMinute )
        newTrades := true
    else if ( hour == sess2_startHour and minute >= sess2_startMinute )
        newTrades := true
    else if ( hour > sess2_startHour and hour < sess2_stopHour )
        newTrades := true
    else if ( hour == sess2_stopHour and minute < sess2_stopMinute )
        newTrades := true
    else
        newTrades := false
else
    newTrades := true

// Long Signals
if ( longCondition and newTrades )
    strategy.order("Buy", strategy.long, orderQty)

// Short Signals
if ( shortCondition and newTrades )
    strategy.order("Sell", strategy.short, orderQty)

// Close open position at end of Session 1, if enabled
if (sess1_closeAll and hour == sess1_stopHour and minute >= sess1_stopMinute )
    strategy.close_all()
    
// Close open position at end of Session 2, if enabled
if (sess2_closeAll and hour == sess2_stopHour and minute >= sess2_stopMinute )
    strategy.close_all()
````

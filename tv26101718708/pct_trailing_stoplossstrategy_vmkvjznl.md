# PCT Trailing Stoploss-Strategy

- url: https://www.tradingview.com/script/VMKVjZNl-PCT-Trailing-Stoploss-Strategy/
- type: strategy
- pine_id: PUB;7cb6272465fd46ce95b2c45fe5bf2172
- version: 1.0

## Description

[image]https://www.tradingview.com/x/it6oZhBZ/[/image]

I am not a financial advisor and this is not financial advice.  This is provided for illustration only for a Percent based Trailing Stoploss.  

I have been looking for a Percent based Trailing Stoploss and have not been able to find one that would work for me so I wrote my own.  This works in both a Strategies and Indicators  I put comments inline of where to add or remove comments// depending on which one you are aiming for.  The simple EMA crossovers are there just to give the strategy something to do.  To use, copy the Stoploss section, the inputs at the top, and the reset under the sell section to your own script.  When I first started out I found the code for removing the redundant signals and then used it in most of my scripts.  For the life of me I do not remember where I got it - either in a comment in Tradingview or on a reddit post, so if you wrote that part, thank you.   

About me:
I have only been working with PineScript since January 2022 and have never been much of a coder from a professional standpoint but decided to jump in and learn Pine mainly because I am a crap, emotional trader and this way I can remove that aspect of it and lose my money programmatically as opposed to making it a conscious decision :)

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Thumpyr
//@version=5

/////////////////////////////////////////////////////////////////////////////////////////////
// Comment out Strategy Line and remove // from Indicator line to turn into Indicator  //////
// Do same for alertConidction at bottom                                               //////
/////////////////////////////////////////////////////////////////////////////////////////////
strategy("PCT Trailing Stoploss-Strategy", shorttitle="PCT Trailing Stoploss- Strategy", overlay=true, margin_long=100, margin_short=100)
//indicator(title="PCT Trailing Stoploss- Indicator", shorttitle="PCT Trailing Stoploss - Indicator", timeframe="", timeframe_gaps=true, overlay=true)//

sellLow=input.float(.035, minval=0, title="Stop Loss Loss: 1% = .01", group="Sell Settings")
trailStopArm=input.float(.0065, minval=0, title="Trailing Stop Arm: 1%=.01", group="Sell Settings")
trailStopPct=input.float(.003, minval=0, title="Trailing Stop Trigger: 1%=.01 ", group="Sell Settings")

/////////////////////////////////////////////////
//               Indicators                    //
/////////////////////////////////////////////////
ema1Len = input.int(14, minval=1, title=" ema 1 Length", group="Trend Line Settings")
ema1Src = input(close, title="ema 1 Source", group="Trend Line Settings")
ema1 = ta.ema(ema1Src, ema1Len)
plot(ema1, title="EMA", color=color.blue)

ema2Len = input.int(22, minval=1, title=" ema 2 Length", group="Trend Line Settings")
ema2Src = input(close, title="ema 2 Source", group="Trend Line Settings")
ema2 = ta.ema(ema2Src, ema2Len)
plot(ema2, title="EMA", color=color.orange)

ema3Len = input.int(200, minval=1, title=" ema 3 Length", group="Trend Line Settings")
ema3Src = input(close, title="ema 2 Source", group="Trend Line Settings")
ema3 = ta.ema(ema3Src, ema3Len)
plot(ema3, title="EMA", color=color.gray)


/////////////////////////////
////   Buy Conditions    ////
/////////////////////////////

alertBuy = ta.crossover(ema1,ema2) and close>ema3

////////////////////////////////////////////////////////////////////
////   Filter redundant Buy Signals if Sell has not happened    ////
////////////////////////////////////////////////////////////////////
var lastsignal = 0
showAlertBuy = 0
if(alertBuy and lastsignal !=1)
    showAlertBuy  := 1
    lastsignal      := 1
buyAlert= showAlertBuy > 0


//////////////////////////////////////////////////////////////////
////          Track Conditions at buy Signal                  ////
//////////////////////////////////////////////////////////////////

alertBuyValue = ta.valuewhen(buyAlert, close,0)
alertSellValueLow = alertBuyValue - (alertBuyValue*sellLow)

////////////////////////////////////////////////////////////
/////            Trailing Stop                         /////
////////////////////////////////////////////////////////////
var TSLActive=0         //Check to see if TSL has been activated
var TSLTriggerValue=0.0 //Initial and climbing value of TSL
var TSLStop = 0.0       //Sell Trigger
var TSLRunning =0       //Continuously check each bar to raise TSL or not

//  Check if a Buy has been triggered and set initial value for TSL //
if buyAlert
    TSLTriggerValue := alertBuyValue+(alertBuyValue*trailStopArm)
    TSLActive := 0
    TSLRunning :=1
    TSLStop := TSLTriggerValue - (TSLTriggerValue*trailStopPct)
    

//  Check that Buy has triggered and if Close has reached initial TSL//  
//  Keeps from setting Sell Signal before TSL has been armed w/TSLActive//
beginTrail=TSLRunning==1 and TSLActive==0 and close>alertBuyValue+(alertBuyValue*trailStopArm) and ta.crossover(close,TSLTriggerValue)
if beginTrail
    TSLTriggerValue :=close
    TSLActive :=1
    TSLStop :=TSLTriggerValue - (TSLTriggerValue*trailStopPct)
    
//  Continuously check if TSL needs to increase and set new value //    
runTrail= TSLActive==1 and (ta.crossover(close,TSLTriggerValue) or close>=TSLTriggerValue)
if runTrail
    TSLTriggerValue :=close
    TSLStop :=TSLTriggerValue - (TSLTriggerValue*trailStopPct)
    
//  Verify that TSL is active and trigger when close cross below TSL Stop//
TSL=TSLActive==1 and (ta.crossunder(close,TSLStop) or (close[1]>TSLStop and close<TSLStop)) 

// Plot point of inital arming of TSL//
TSLTrigger=TSLActive==1 and TSLActive[1]==0
plotshape(TSLTrigger, title='TSL Armed', location=location.abovebar, color=color.new(color.blue, 0), size=size.small, style=shape.cross, text='TSL Armed')


////////////////////////////////////////////////////////////
// Plots used for troubleshooting and verification of TSL //
////////////////////////////////////////////////////////////
//plot(TSLActive,"Trailing Stop", color=#f48fb1)
//plot(TSLRunning,"Trailing Stop", color=#f48fb1)
//plot(TSLTriggerValue,"Trailing Stop Trigger", color.new(color=#ec407a, transp = TSLRunning==1 ? 0 : 100))
//plot(TSLStop,"Trailing Stop", color.new(color=#f48fb1, transp = TSLRunning==1 ? 0 : 100))//


////////////////////////////////////////////////////////////
/////             Sell Conditions                    ///////
////////////////////////////////////////////////////////////
Sell1 = TSL
Sell2 = ta.crossunder(close,alertSellValueLow)

alertSell= Sell1 or Sell2
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
////        Remove Redundant Signals                    ////
////////////////////////////////////////////////////////////
showAlertSell = 0
if(alertSell and lastsignal != -1)
    showAlertSell := 1
    lastsignal      := -1
sellAlert= showAlertSell > 0

if sellAlert
    TSLActive :=0
    TSLRunning :=0

/////////////////////////////////////////
//  Plot Buy and Sell Shapes on Chart  //
/////////////////////////////////////////
plotshape(buyAlert, title='Buy', location=location.belowbar, color=color.new(color.green, 0), size=size.small, style=shape.triangleup, text='Buy')
plotshape(sellAlert, title='Sell', location=location.abovebar, color=color.new(color.red, 0), size=size.small, style=shape.triangledown, text='Sell')

/////////////////////////////////////////////////////////////////////////////////////////////
//                        Remove // to setup for Indicator                                 //
/////////////////////////////////////////////////////////////////////////////////////////////
//Alerts
//alertcondition(title='Buy Alert', condition=buyAlert, message='Buy Conditions are Met')
//alertcondition(title='Sell Alert', condition=sellAlert, message='Sell Conditions are Met')
/////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////
////  Comment out this section if setup as Indicator    ////
////////////////////////////////////////////////////////////
longCondition = buyAlert
if (longCondition)
    strategy.entry("Buy", strategy.long)
    alert(message='Buy', freq=alert.freq_once_per_bar_close)
    
shortCondition = sellAlert
if (shortCondition)
    strategy.close_all(sellAlert,"Sell")
    alert(message='Sell', freq=alert.freq_once_per_bar_close)
/////////////////////////////////////////////////////////////
````

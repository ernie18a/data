# RSI of Ultimate Oscillator [SHORT Selling] Strategy

- url: https://www.tradingview.com/script/bHXZkpzl-RSI-of-Ultimate-Oscillator-SHORT-Selling-Strategy/
- type: strategy
- pine_id: PUB;4NDpfvLUejS9XeEVoJXlf2kQ42hp9msD
- version: 1.0

## Description

This is SHORT selling strategy with Ultimate Oscillator.  Instead of drectly using the UO oscillator , I have used RSI  on UO  (as I did in my previous strategies )

Ultimator Oscillator settings are 5, 10 and 15

RSI of UO setting is 5


Short Sell
==========
I have used moving averages from WilliamAlligator indicator  --- settings are 10(Lips), 20(teeth)  and 50 (Jaw)
when Lips , Teeth and Jaw are aligned to downtrend  (that means Lips < Teeth < Jaw )
Look for RSIofUO  dropping below 60  ( setting parameter is  Sell Line )

Partial Exit
==========
When  RSIofUO  crossing up  Oversold line  i.e  30


Cover Short / Exit
=================

When RSIofUO  crosisng above overbought line   i.e 70


StopLoss
========
StopLoss defaulted to 3 % ,  Though it is mentioned in settings , it has not been not used to calcuate and  StopLoss Exit...  Reason is, when RSIofUO already crossed 60 line (for SHORTING) , then it would take more efforts go up beynd 60.  There is saying  price takes stairs to climb up but it takes elevator to go down.   I have not purely depend on this to exit stop loss, however noticed the trades in this stratgey did not get out with  loss higher than when RSIofUO reaching 70 level.

Note
======
Williams Alligator is not drawn from the script. It is manually added to chart for illustration purpose.  Please add it when you are using this strategy , whch woould give an idea how the strategy is taking Short Trades.

This is tested on Hourly chart for SPY

Bar color changes to purple when the strategy is in SHORT trade


Warning
========
For the eductional purposes only

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mohanee

//@version=4

strategy(title="RSI of Ultimate Oscillator [SHORT Selling] Strategy",  shorttitle="RSIofUO" , overlay=false, pyramiding=1,     default_qty_type=strategy.percent_of_equity,  default_qty_value=20, initial_capital=10000, currency=currency.USD)  //default_qty_value=10, default_qty_type=strategy.fixed,

	
//Ultimate Oscillator logic copied from  TradingView   builtin indicator
/////////////////////////////////////////////////////////////////////////////////
length1 = input(5, minval=1), length2 = input(10, minval=1), length3 = input(15, minval=1)


rsiUOLength = input(5, title="RSI UO length", minval=1)

sellLine = input (60, title="Sell at RSIofUO")
coverLine = input (75, title="Cover at RSIofUO")

riskCapital = input(title="Risk % of capital", defval=10, minval=1)
stopLoss=input(3,title="Stop Loss",minval=1)


showUO=input(false, "show Ultimate Oscialltor")



average(bp, tr_, length) => sum(bp, length) / sum(tr_, length)
high_ = max(high, close[1])
low_ = min(low, close[1])
bp = close - low_
tr_ = high_ - low_
avg7 = average(bp, tr_, length1)
avg14 = average(bp, tr_, length2)
avg28 = average(bp, tr_, length3)
out = 100 * (4*avg7 + 2*avg14 + avg28)/7
//Ultimate Oscillator 
/////////////////////////////////////////////////////////////////////////////////

//Willimas Alligator  copied from  TradingView built in Indicator
/////////////////////////////////////////////////////////////////////////////////
smma(src, length) =>
	smma =  0.0
	smma := na(smma[1]) ? sma(src, length) : (smma[1] * (length - 1) + src) / length
	smma

//moving averages logic copied from Willimas Alligator -- builtin indicator in TradingView
sma1=smma(hl2,10)
sma2=smma(hl2,20)
sma3=smma(hl2,50)

//Willimas Alligator
/////////////////////////////////////////////////////////////////////////////////


//drawings
/////////////////////////////////////////////////////////////////////////////////
hline(sellLine, title="Middle Line 60  [Short Here]", color=color.red , linestyle=hline.style_solid)

obLevelPlot = hline(75, title="Overbought",  color=color.blue , linestyle=hline.style_dashed)
osLevelPlot = hline(25, title="Oversold", color=color.blue, linestyle=hline.style_dashed)

fill(obLevelPlot, osLevelPlot, title="Background", color=color.blue, transp=90)
rsiUO = rsi(out,rsiUOLength)

ultPlot=plot(showUO==true? out : na, color=color.green, title="Oscillator")

plot(rsiUO, title = "rsiUO" ,  color=color.purple)
//drawings
/////////////////////////////////////////////////////////////////////////////////




//Strategy Logic 
/////////////////////////////////////////////////////////////////////////////////

//Entry--
//Echeck how many units can be purchased based on risk manage ment and stop loss
qty1 = (strategy.equity  * riskCapital / 100 ) /  (close*stopLoss/100)  

//check if cash is sufficient  to buy qty1  , if capital not available use the available capital only
qty1:= (qty1 * close >= strategy.equity ) ? (strategy.equity / close) : qty1


strategy.entry(id="SERSIofUO", long=false,   qty=qty1, when = sma1<=sma2 and sma2 < sma3 and close<sma2 and crossunder(rsiUO,sellLine) )

//strategy.entry(id="SERSiofUO", long=false, when = sma1< sma2  and crossunder(rsiUO,60) )

barcolor(abs(strategy.position_size)>=1 ? color.purple : na )
bgcolor(abs(strategy.position_size)>=1 ? color.purple : na , transp=70)


//partial exit
strategy.close(id="SERSIofUO", comment="PExit",  qty=strategy.position_size/3, when=abs(strategy.position_size)>=1 and close< strategy.position_avg_price and crossover(rsiUO,30) )

strategy.close(id="SERSIofUO", comment="CloseAll", when=abs(strategy.position_size)>=1 and crossover(rsiUO,coverLine) )

//Strategy Logic 
/////////////////////////////////////////////////////////////////////////////////
````

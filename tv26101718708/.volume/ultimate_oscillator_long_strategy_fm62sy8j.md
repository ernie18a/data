# Ultimate Oscillator [Long] Strategy

- url: https://www.tradingview.com/script/fm62SY8J-Ultimate-Oscillator-Long-Strategy/
- type: strategy
- pine_id: PUB;0biwAARKRnvgo6N2QdKqWsY5rCI7m1fF
- version: 1.0

## Description

After I published Short Selling strategy with RSIofUO , I have been working for Long side strategy with same indicator.

but for Long strategy , I have used only  the Ultimate Oscillator ... (Not the RSI of UO)  

Logic behind this is , when UO goes below oversold level , high chance of possible reversal from there ...

Ultimate Oscialltor values , I have used are 5,  10 and  15

Signal Line 9 
Above values are best/defaulted based on testing the strategy multiple symbols


BUY
when UO  crossing up  buyLine and close > open ( if the cross over is already done , it will wait for 3 candles to see a green bar i.e close>open )

Note when the bar color changes to orange , that means startegy is ready to take LONG position on next bar.  But dont jump here , waith for the startegy take the Long Position :-)


Add
Signal appears when there is divergence (marked in yellow color ) ... strategy doesnt add the position , it is ony indicating you  could add to existing  OR if you missed the BUY signal you could enter here

Partial Exit
when UO  crossing down partial exit level 

Exit
When UO  crossing down sell line 

StopLoss
stop loss defaulted to 3%

Please note , I have slightly modified stop loss exit in this strategy.   
Even though price hits 3% stoploss , strategy wont wind up the position ... 
First , it will check if RSIofUO is above 30 , then it will hold on to the Long position.
Very reason behind this is , price is falling down and UO is going up ... That means there is bullish divergence here .. so it might turn this losing position to profitable one or  will exit you with less than 3% loss.


Tested with SPY , QQQ , TSLA on 30mins to 4hrs. Though winning rate is average , net profit is exponential ...   
Best working on 30 mins and 1 HR chart for  QQQ


Warning
For the eductional purposes only ... 
This is not a financial advise , before taking trading decission please do your own research

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mohanee

//@version=4

strategy(title="Ultimate Oscillator [Long] Strategy",  shorttitle="UO" , overlay=false, pyramiding=2,     default_qty_type=strategy.percent_of_equity,  default_qty_value=20, initial_capital=10000, currency=currency.USD)  //default_qty_value=10, default_qty_type=strategy.fixed,

	
//Ultimate Oscillator logic copied from  TradingView   builtin indicator
/////////////////////////////////////////////////////////////////////////////////
length1 = input(5, minval=1), length2 = input(10, minval=1), length3 = input(15, minval=1)


//rsiUOLength = input(7, title="RSI UO length", minval=1)

signalLength = input(9, title="Signal length", minval=1)

buyLine = input (45, title="Buy Line (UO crossing up oversold at ) ")       //crossover
exitLine = input (70, title="Exit Line (UO crsossing down overbought at) ")      //crossunder


riskCapital = input(title="Risk % of capital", defval=10, minval=1)
stopLoss=input(3,title="Stop Loss",minval=1)

takeProfit=input(false, title="Take Profit")
profitExitLine = input (75, title="Take Profit at RSIofUO crossing below this value ") //crossunder


showSignalLine=input(true, "show Signal Line")
//showUO=input(false, "show Ultimate Oscialltor")


average(bp, tr_, length) => sum(bp, length) / sum(tr_, length)
high_ = max(high, close[1])
low_ = min(low, close[1])
bp = close - low_
tr_ = high_ - low_
avg7 = average(bp, tr_, length1)
avg14 = average(bp, tr_, length2)
avg28 = average(bp, tr_, length3)
ultOscVal = 100 * (4*avg7 + 2*avg14 + avg28)/7
//Ultimate Oscillator 
/////////////////////////////////////////////////////////////////////////////////

//Willimas Alligator  copied from  TradingView built in Indicator
/////////////////////////////////////////////////////////////////////////////////
smma(src, length) =>
	smma =  0.0
	smma := na(smma[1]) ? sma(src, length) : (smma[1] * (length - 1) + src) / length
	smma

//moving averages logic copied from Willimas Alligator -- builtin indicator in TradingView
sma1=smma(hl2,5)
sma2=smma(hl2,20)
sma3=smma(hl2,50)

//Willimas Alligator
/////////////////////////////////////////////////////////////////////////////////

myVwap= vwap(hlc3)

//drawings
/////////////////////////////////////////////////////////////////////////////////
hline(profitExitLine, title="Middle Line 60  [Profit Exit Here]", color=color.purple  , linestyle=hline.style_dashed)

obLevelPlot = hline(exitLine, title="Overbought",  color=color.red , linestyle=hline.style_dashed)
osLevelPlot = hline(buyLine, title="Oversold", color=color.blue, linestyle=hline.style_dashed)

//fill(obLevelPlot, osLevelPlot, title="Background", color=color.blue, transp=90)
//rsiUO = rsi(ultOscVal,rsiUOLength)

rsiUO=ultOscVal

//emaUO = ema(rsiUO, 9)

//signal line
emaUO = ema(ultOscVal , 5)     // ema(ultOscVal / rsiUO, 9)

//ultPlot=plot(showUO==true? ultOscVal : na, color=color.green, title="Oscillator")

plot(rsiUO, title = "rsiUO" ,  color=color.purple)
plot(showSignalLine ? emaUO : na , title = "emaUO [signal line]" ,  color=color.blue)  //emaUO

//drawings
/////////////////////////////////////////////////////////////////////////////////




//Strategy Logic 
/////////////////////////////////////////////////////////////////////////////////

longCond=  crossover(rsiUO, buyLine)  or crossover(rsiUO, 30)


//longCond= ( ema10>ema20 and crossover(rsiUO, buyLine) ) or ( ema10 < ema20 and crossover(rsiUO, 75)  )

//Entry--
//Echeck how many units can be purchased based on risk manage ment and stop loss
qty1 = (strategy.equity  * riskCapital / 100 ) /  (close*stopLoss/100)  

//check if cash is sufficient  to buy qty1  , if capital not available use the available capital only
qty1:= (qty1 * close >= strategy.equity ) ? (strategy.equity / close) : qty1



//strategy.entry(id="LERSIofUO", long=true,   qty=qty1,  when = close > open and  barssince(longCond)<=3  and strategy.position_size<1 )  //and sma1 > sma3)  //  and close>open and  rsiUO >= 25 )   //and


strategy.entry(id="LEUO", long=true,   qty=qty1,  when = close > open and  barssince(longCond)<=3  and strategy.position_size<1  and sma2 > sma3)  //  and close>open and  rsiUO >= 25 )   //and


//Add
//strategy.entry(id="LEUO", comment="Add" , qty=qty1/2 ,  long=true,   when = strategy.position_size>=1 and close < strategy.position_avg_price and crossover(rsiUO, 60) )  //and sma1 > sma3)  //  and close>open and  rsiUO >= 25 )   //and


//strategy.entry(id="LEUO", long=true,   qty=qty1, when = close > open and  barssince(longCond)<=10  and valuewhen(longCond , close , 1)  > close  and rsiUO>=30) //  and close>open and  rsiUO >= 25 )   //and 

//for Later versions
//also check for divergence  ... later version
//also check if close above vwap session

//strategy.entry(id="LEUO", long=false, when = sma1< sma2  and crossunder(rsiUO,60) )

//change the bar color to yellow , indicating startegy will trigger BUY
barcolor( close > open and  barssince(longCond)<=3  and strategy.position_size<1  and sma2 > sma3 ? color.orange : na)


//barcolor(abs(strategy.position_size)>=1 ? color.blue : na )
bgcolor(abs(strategy.position_size)>=1 ? color.blue : na , transp=70)

//signal for addition to existing position 
barcolor( strategy.position_size>=1 and close < strategy.position_avg_price and crossover(rsiUO, 60) ? color.yellow : na)
//bgcolor( strategy.position_size>=1 and close < strategy.position_avg_price and crossover(rsiUO, 60)  ? color.yellow : na, transp=30)

//partial exit
strategy.close(id="LEUO", comment="PExit",  qty=strategy.position_size/3, when= takeProfit and abs(strategy.position_size)>=1 and close > strategy.position_avg_price and crossunder(rsiUO,profitExitLine) )


//close the Long order
strategy.close(id="LEUO", comment="Profit is "+tostring(close - strategy.position_avg_price,  "###.##"), when=abs(strategy.position_size)>=1 and crossunder(rsiUO,exitLine) ) //and close > strategy.position_avg_price )
//strategy.close(id="LEUO", comment="CloseAll", when=abs(strategy.position_size)>=1 and crossunder(rsiUO2,40) ) //and close > strategy.position_avg_price )

// stop loss exit
stopLossVal = strategy.position_size>=1 ?  strategy.position_avg_price * ( 1 - (stopLoss/100) ) : 0.00
strategy.close(id="LEUO", comment="SL exit Loss is  "+tostring(close - strategy.position_avg_price,  "###.##") , when=abs(strategy.position_size)>=1 and close < stopLossVal and rsiUO < exitLine)   
//reason to rsiUO <30 is if price is going down , indicator should reflect it ... but indicator is above 30 means it showing divergence... so hold on it until it crossdown 30 ...that way even Stop Loss less than predefined ...


//Strategy Logic 
/////////////////////////////////////////////////////////////////////////////////
````

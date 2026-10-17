# Volatility Bands Reversal Strategy [Long Only]

- url: https://www.tradingview.com/script/uGEv5oZb-Volatility-Bands-Reversal-Strategy-Long-Only/
- type: strategy
- pine_id: PUB;q0B8Jh1oL1o3ksccOVKUSERXRipqZ85v
- version: 1.0

## Description

This strategy based on  existng indicator available on TV 

If finds the  reversals  for LONG entries ...  I have modified the settings to back test it ...


BUY
====
When the price touches lower band , and tries to close above lower band

some signals are mixed up, you can research and look for  a confirmation ...

if  the middle band is above EMA50 , you can simply follow the strategy BUY signal
but  if  the middle band is  EMA50 , wait for the price to close above middle band


Sell / Close
==========
wait for the sell  signa  OR  close when price touches the upper band

How do you want to close , you can chose in settings.  Chnage these values and see the performance

Please note , sell means  just closing the existing LONG position , not short selling 


Stop Loss 
=========

Stop Loss is defaulted  to  6%



This is tested in 1HR, 2HR and 4 HRs chart for SPY and QQQ ETFS ...

for long term investing style , 4 Hrs is the best time frme for this strategy

Warning
========
It is not a financial advise , it is for educational purposes only. Please do your own research before taking any trading decission

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ediks123

//strategy logic  has been borrowed from ceyhun  and tweaked the settings for back testing

//@version=4


//SPY 4 hrs settings 8, 13 , 3.33 , 0.9  on 4 hrs chart
//QQQ above settings is good , but 13, 13 has less number of bars 
//QQQ 4 hrs settings 13, 13 , 3.33 , 0.9  on 4 hrs chart

strategy(title="Volatility Bands Reversal Strategy",  shorttitle="VolatilityBandReversal" , overlay=true, pyramiding=2,     default_qty_type=strategy.percent_of_equity,  default_qty_value=20, initial_capital=10000, currency=currency.USD)  //default_qty_value=10, default_qty_type=strategy.fixed,


av = input(8, title="Band Average")
vp = input(13, title="Volatility Period")
df = input(3.33,title="Deviation Factor",minval=0.1)
lba = input(0.9,title="Lower Band Adjustment",minval=0.1)

riskCapital = input(title="Risk % of capital", defval=10, minval=1)
stopLoss=input(6,title="Stop Loss",minval=1)

exitOn=input(title="Exit on", defval="touch_upperband", options=["Sell_Signal", "touch_upperband"])



src = hlc3
typical = src >= src[1] ? src - low[1] : src[1] - low
deviation = sum( typical , vp )/ vp * df
devHigh = ema(deviation, av)
devLow = lba * devHigh
medianAvg = ema(src, av)

emaMediaAvg=ema(medianAvg, av)

upperBandVal= emaMediaAvg + devHigh
lowerbandVal= emaMediaAvg - devLow
MidLineVal=sma(medianAvg, av)

UpperBand = plot ( upperBandVal, color=#EE82EE, linewidth=2, title="UpperBand")
LowerBand = plot ( lowerbandVal , color=#EE82EE, linewidth=2, title="LowerBand")
MidLine = plot (MidLineVal, color=color.blue, linewidth=2, title="MidLine")
buyLine = plot ( (lowerbandVal + MidLineVal )/2  , color=color.blue, title="BuyLine")

up=ema(medianAvg, av) + devHigh
down=ema(medianAvg, av) - devLow


ema50=ema(hlc3,50)
plot ( ema50, color=color.orange, linewidth=2, title="ema 50")

//outer deviation

//deviation1 = sum( typical , vp )/ vp * 4
//devHigh1 = ema(deviation, av)
//devLow1 = lba * devHigh
//medianAvg1 = ema(src, av)

//UpperBand1 = plot (emaMediaAvg + devHigh1, color=color.red, linewidth=3, title="UpperBand1")
//LowerBand1 = plot (emaMediaAvg - devLow1, color=color.red, linewidth=3, title="LowerBand1")
//



///Entry Rules
//1)First candle close below the Lower Band of the volatility Band
//2)Second candle close above the lower band
//3)Third Candle closes above previous candle
Buy = close[2] < down[2] and close[1]>down[1] and close>close[1]
//plotshape(Buy,color=color.blue,style=shape.arrowup,location=location.belowbar, text="Buy")
//barcolor(close[2] < down[2] and close[1]>down[1] and close>close[1] ? color.blue :na )
//bgcolor(close[2] < down[2] and close[1]>down[1] and close>close[1] ? color.green :na )

///Exit Rules
//1)One can have a static stops initially followed by an trailing stop based on the risk the people are willing to take
//2)One can exit with human based decisions or predefined target exits. Choice of deciding the stop loss and profit targets are left to the readers.
Sell = close[2] > up[2] and close[1]<up[1] and close<close[1]
//plotshape(Sell,color=color.red,style=shape.arrowup,text="Sell")
barcolor(close[2] > up[2] and close[1]<up[1] and close<close[1] ? color.yellow :na )
bgcolor(close[2] > up[2] and close[1]<up[1] and close<close[1] ? color.red :na )

//Buyer = crossover(close,Buy)
//Seller = crossunder(close,Sell)

//alertcondition(Buyer, title="Buy Signal", message="Buy")
//alertcondition(Seller, title="Sell Signal", message="Sell")


//Entry--
//Echeck how many units can be purchased based on risk manage ment and stop loss
qty1 = (strategy.equity  * riskCapital / 100 ) /  (close*stopLoss/100)  

//check if cash is sufficient  to buy qty1  , if capital not available use the available capital only
qty1:= (qty1 * close >= strategy.equity ) ? (strategy.equity / close) : qty1

strategy.entry(id="vbLE", long=true, qty=qty1, when=Buy)

bgcolor(strategy.position_size>=1 ? color.blue : na)
// stop loss exit
stopLossVal = strategy.position_size>=1 ?  strategy.position_avg_price * ( 1 - (stopLoss/100) ) : 0.00
//draw initil stop loss
plot(strategy.position_size>=1 ? stopLossVal : na, color = color.purple , style=plot.style_linebr,  linewidth = 2, title = "stop loss") //, trackprice=true)


strategy.close(id="vbLE", comment="SL exit Loss is  "+tostring(close - strategy.position_avg_price,  "###.##") , when=abs(strategy.position_size)>=1 and close < stopLossVal )   




//close on Sell_Signal
strategy.close(id="vbLE", comment="Profit is : "+tostring(close - strategy.position_avg_price,  "###.##") , when=strategy.position_size>=1 and  exitOn=="Sell_Signal"  and Sell)

//close on touch_upperband
strategy.close(id="vbLE", comment="Profit is : "+tostring(close - strategy.position_avg_price,  "###.##") , when=strategy.position_size>=1 and  exitOn=="touch_upperband"  and (crossover(close, up) or crossover(high, up)))
````

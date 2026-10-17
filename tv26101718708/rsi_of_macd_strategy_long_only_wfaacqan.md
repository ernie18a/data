# RSI of MACD Strategy  [Long only]

- url: https://www.tradingview.com/script/WfaaCqaN-RSI-of-MACD-Strategy-Long-only/
- type: strategy
- pine_id: PUB;MKXFVw7QQw8TnK8KjRSn3ZH5h0nAC1UG
- version: 1.0

## Description

This strategy uses the RSI on MACD indicator.   

BUY
====
When RSI indicator crossing over 30 or 35  line   and  price above slow ema

Note: when the position already taken, you may  reenter  on the  purple candle


Partial Exit
==========
Partial profit taking option is available in settings. If this is selected ,  1/3 position exited when RSI indicator crossing down 80 line


Close
=====
When RSI indicator crossing below 15


Stop Loss
=========
I havent used hard stop loss in this strategy.    Reason is , when price going down , indicator may go up ... so just wanted to ride along with indicator ...

Stop loss mentioned in the settings is used in calculation of   how many units can be be purchased based on risk level


Tested with SPY and QQQ ETFs on hourly chart


Warning
=========
For the eductional purposes only ...

This is not a financial advise.   please do your own research   before taking any trading decission

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mohanee

//@version=4

strategy(title="RSI of MACD Strategy[Long only]",  shorttitle="RSIofMACD" , overlay=false, pyramiding=1,     default_qty_type=strategy.percent_of_equity,  default_qty_value=20, initial_capital=10000, currency=currency.USD)  //default_qty_value=10, default_qty_type=strategy.fixed,

	

/////////////////////////////////////////////////////////////////////////////////



// MACD Inputs ///
fastLen = input(12, title="Fast Length")
slowLen = input(21, title="Slow Length")
sigLen  = input(9, title="Signal Length")

rsiLength  = input(14, title="RSI of MACD Length")




riskCapital = input(title="Risk % of capital", defval=10, minval=1)
stopLoss=input(3,title="Stop Loss",minval=1)

takeProfit=input(false, title="Take Profit")


[macdLine, signalLine, _] = macd(close, fastLen, slowLen, sigLen)

rsiOfMACD = rsi(macdLine, rsiLength)
emaSlow = ema(close, slowLen)



//drawings
/////////////////////////////////////////////////////////////////////////////////


obLevelPlot = hline(80, title="Overbought / Profit taking line",  color=color.blue , linestyle=hline.style_dashed)
osLevelPlot = hline(30, title="Oversold / entry line", color=color.green, linestyle=hline.style_dashed)

exitLinePlot = hline(15, title="Exit line", color=color.red, linestyle=hline.style_dashed)




plot(rsiOfMACD, title = "rsiOfMACD" ,  color=color.purple)


//drawings
/////////////////////////////////////////////////////////////////////////////////




//Strategy Logic 
/////////////////////////////////////////////////////////////////////////////////

//Entry--
//Echeck how many units can be purchased based on risk manage ment and stop loss
qty1 = (strategy.equity  * riskCapital / 100 ) /  (close*stopLoss/100)  

//check if cash is sufficient  to buy qty1  , if capital not available use the available capital only
qty1:= (qty1 * close >= strategy.equity ) ? (strategy.equity / close) : qty1


strategy.entry(id="RSIofMACD", long=true,   qty=qty1,  when =  ( crossover(rsiOfMACD, 30) or crossover(rsiOfMACD, 35)  ) and close>=emaSlow )



bgcolor(abs(strategy.position_size)>=1 ? color.blue : na , transp=70)


barcolor(abs(strategy.position_size)>=1 and  ( crossover(rsiOfMACD, 30) or crossover(rsiOfMACD, 35) ) ? color.purple : abs(strategy.position_size)>=1 ? color.blue : na  )


//partial exit
strategy.close(id="RSIofMACD", comment="PExit Profit is "+tostring(close - strategy.position_avg_price,  "###.##")  ,  qty=strategy.position_size/3, when= takeProfit and abs(strategy.position_size)>=1 and close > strategy.position_avg_price and crossunder(rsiOfMACD,80) )

//Close All
strategy.close(id="RSIofMACD", comment="Close All   Profit is "+tostring(close - strategy.position_avg_price,  "###.##"), when=abs(strategy.position_size)>=1 and crossunder(rsiOfMACD,15) ) //and close > strategy.position_avg_price )


//Strategy Logic 
/////////////////////////////////////////////////////////////////////////////////
````

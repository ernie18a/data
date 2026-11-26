# Zweig Market Breadth Thrust Indicator Strategy

- url: https://www.tradingview.com/script/f31wnImM-Zweig-Market-Breadth-Thrust-Indicator-Strategy/
- type: strategy
- pine_id: PUB;g2itgSx8ADXcEtAdUZ2f7K4KsVoKP3oF
- version: 1.0

## Description

The Breadth Thrust Indicator is a technical indicator which determines market momentum, signaling the start of a potential new bull market.

The Breadth Thrust Indicator was developed by Martin Zweig, an American stock investor, financial analyst, and investment adviser. According to Zweig, the concept is based on the principle that the sudden change of money in the investment markets elevates stocks and signals increased liquidity. In other words, this indicator is all about how quickly the NYSE's advancing and declining numbers go from poor to great in a compressed time period.

A "Thrust" indicates that the stock market has rapidly changed from an oversold condition to one of strength, but has not yet become overbought. This is very rare and has happened only a few times. Dr . Zweig also points out that most bull markets begin with a Breadth Thrust.


More info can be found at  https://www.investopedia.com/terms/b/breadth-thrust-indicator.asp


I have inspired by indicator introduced in TradingView by  LazyBear  and adopted the logic from there.  Thanks LazyBear !!!


Though indicator signals the new Bull market, but I have not found much information how to use it in daily market.  So I had come up with a strategy, which would allow us to trade SPY, QQQ , AMEX and securities under these markets.

I have used  MA setting  as 65  (since Zweig indicator setting was 10 days , based on that I set 65 for Hourly chart ...  10d x 6.5 Hrs  = 65 in my startegy).  You have to change this setting if you change the timeframe.  Also , note that this strategy is for Stock Market only.


Strategy Rule/Settings
===================
Select the market type based on your security symbol.   
SPY => use NYSE 
QQQ => use NASDAQ
any other security => check exchange it was listed and select the corresponding market.

if you dont know , use COMBINED option


BUY
====
when indicator cross 0.40 from below

Note:  
1.  see how well it picks the bottoms ... example :  Nov 2020 ....
2.  setting 0.45 is also produces good results , only thing is you get more signals.  

EXIT
=====
Exit when indicator cross down from 0.60 .  I have used RSI (5) for partial exits.   These two are available in settings

Close the whole position when indicator crossing down  0.40


STOP LOSS
=========
defaulted to 5%


Please Note , I have tested SPY , QQQ on Horly chart with MA 65.  You need to chnage the MA setting based on your time frame and check the results.

WARNING
========
For the use of educational purposes only

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mohanee

//@version=4
strategy("Zweig Market Breadth Thrust Indicator Strategy", overlay=false, pyramiding=3 , default_qty_type=strategy.percent_of_equity,  default_qty_value=20,  initial_capital=10000, currency=currency.USD)


ma_type   = input("EMA", options=["SMA","EMA","WMA"] )

ma_length = input(defval=65, minval=1, title="MA Length")

mkt = input ("NYSE" , options=["NYSE","NASDAQ", "AMEX", "COMBINED"] )

buyEntryAt = input(0.40, minval=0.10, maxval=0.60)

stopLoss = input(title="Stop Loss%", defval=5, minval=1)

trailingStop        = input(false, title="Trailing Stop")


partialCloseIndicator = input("RSI", title="Partial Close using Indicator ", options=["ZWEIG", "RSI"])

colorOBOS        = input(true, title="Color OB/OS")
showDecLineThrust= input(false, title="show DecLine Thrust")

//function
getMAval(s,l, ma_type) => ma_type== "SMA" ? sma(s,l):  ma_type== "EMA" ? ema(s,l)	: ma_type=="WMA" ?   wma(s,l) : sma(s,l)


//calculate Zweig Market Breadth Thrust
/////////////////////////////////////////////////////////////
res = "D"
advn="ADVN", decn="DECN" // NYSE
advnq="ADVQ", decnq="DECQ" // NASDAQ
advna="ADVA", decna="DECA" // AMEX
advc="(ADVN+ADVQ+ADVA)/3.0"
decc="(DECN+DECQ+DECA)/3.0"

adv= security(mkt=="COMBINED" ? advc:mkt == "NYSE" ? advn: mkt == "NASDAQ" ? advnq : mkt == "AMEX" ? advna:na, res, close)   //res
dec= security(mkt=="COMBINED" ? decc:mkt == "NYSE" ? decn:mkt == "NASDAQ" ? decnq :  mkt == "AMEX" ? decna:na, res, close)

zmbti = getMAval(adv/(adv+dec), ma_length, ma_type)

zmbtr = getMAval(dec/(adv+dec), ma_length, ma_type)
//calculate Zweig Market Breadth Thrust
/////////////////////////////////////////////////////////////


myRsi = rsi(close, 5)

//Plot
/////////////////////////////////////////////////////////////
osl=plot(buyEntryAt, color=color.gray, style=plot.style_linebr, title="OS")

//osl1=plot(0.45, color=color.blue, style=plot.style_circles, linewidth=2 , title="OS1")

obl=plot(0.615, color=color.gray, style=plot.style_linebr, title="OB")

osd=plot(colorOBOS?(zmbti<buyEntryAt?zmbti:buyEntryAt):na, style=plot.style_linebr,linewidth=0, title="DummyOS")
obd=plot(colorOBOS?(zmbti>0.615?zmbti:0.615):na, style=plot.style_linebr, linewidth=0, title="DummyOB")


fill(osl,obl,color.purple, title="RegionFill")
fill(osl, osd, color.green, transp=60, title="OSFill")
fill(obl, obd, color.red, transp=60, title="OBFill")


plot(zmbti, color=color.blue, linewidth=2, title="BreadthThrust(advances)")
plot(showDecLineThrust == true ? zmbtr : na, color=color.red, linewidth=2, title="BreadthThrust(declines)")
//plot
/////////////////////////////////////////////////////////////


//Strategy
/////////////////////////////////////////////////////////////


strategy.entry(id="zmbtiLong" , long=true, when=crossover(zmbti, buyEntryAt) )

////// Calculate trailing SL
sl_val =  close * stopLoss / 100 

trailing_sl = 0.0
trailing_sl :=   strategy.position_size>=1 ?  max(low  - sl_val, nz(trailing_sl[1])) :  na

stopLossVal = strategy.position_size>=1 ?  strategy.position_avg_price * ( 1 - (stopLoss / 100) )  : 0.00
//draw initil stop loss
//plot(strategy.position_size>=1 ? trailing_sl : na, color = color.blue , style=plot.style_linebr,  linewidth = 2, title = "stop loss")


//exit partial  position when zmbti crossing down OB level
strategy.close(id="zmbtiLong" , comment="Partial close ZWEIG" ,  qty=strategy.position_size/3 , when=strategy.position_size>=1 and partialCloseIndicator=="ZWEIG" and close>strategy.position_avg_price and crossunder(zmbti, 0.6) )

strategy.close(id="zmbtiLong" , comment="Partial close RSI" ,  qty=strategy.position_size/3 , when=strategy.position_size>=1 and  partialCloseIndicator=="RSI" and close>strategy.position_avg_price and crossunder(myRsi, 90) )



//exit whole position when zmbti  turns back to OS Level
strategy.close(id="zmbtiLong" , comment="close all" ,   when=strategy.position_size>=1 and  close >strategy.position_avg_price and  crossunder(zmbti , buyEntryAt)  )  

//exit whole position when stop loss hits
strategy.close(id="zmbtiLong" , comment="TSL", when=strategy.position_size>=1 and trailingStop==true and close < trailing_sl )  //if trailing stop is set

strategy.close(id="zmbtiLong" , comment="SL", when=strategy.position_size>=1 and close < stopLossVal )  //if trailing stop is NOT set
````

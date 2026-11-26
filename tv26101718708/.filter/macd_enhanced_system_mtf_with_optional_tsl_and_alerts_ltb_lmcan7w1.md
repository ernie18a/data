# MACD Enhanced System MTF with optional TSL and Alerts [LTB]

- url: https://www.tradingview.com/script/LMcAN7w1/
- type: indicator
- pine_id: PUB;9ZYcw0Oq5qqYJ32GUvZSBP9kGKOqqF2z
- version: 4.0

## Description

This script is developed to analyse MACD, MACD Signal, MACD Histogram movements by using current and higher time frame. Script calculates higher time frame automatically, no manuel entry. there is trailing stop loss line that is optional. 

You can change the parameters as you wish.

btw. you should know that MACD is more successful when there is a trend. 

I already shared this as a strategy script. Some ppl wanted to see the code. 
You might want to see strategy test  =>  https://tr.tradingview.com/script/PA2ndF2Q/


by LonesomeTheBlue [LTB]

## Source Code

````pine
// 
// This script is developed to analyse MACD, MACD Signal, MACD Histogram movements 
// by using current and higher time frame. Script calculates higher time frame automatically, no manuel entry. 
// I also added optional trailing stop loss line. 
// You can change the parameters as you wish ;) 
// btw. you should know that MACD is more successful when there is a trend. 
// 
// @author LonesomeTheBlue [LTB]
//
//@version=2
study("MACD Enhanced Strategy MTF with Stop Loss [LTB]", overlay=true)
fastLength = input(title="MACD Fast Length", defval = 12, minval = 1)
slowLength = input(title="MACD Slow Length", defval = 26, minval = 1)
signalLength = input(title="MACD Signal Length", defval = 9, minval = 1)
crossscore = input(title="Cross (buy/sell) Score", defval = 10)
indiside = input(title="indicator Direction Score", defval = 8)
histside = input(title="Histogram Direction Score", defval = 2)

HTF = period == '1' ? '5' : 
  period == '3' ? '15' : 
  period == '5' ? '15' :
  period == '15' ? '60' :
  period == '30' ? '60' : 
  period == '45' ? '60' : 
  period == '60' ? '240' : 
  period == '120' ? '240' : 
  period == '180' ? '240' : 
  period == '240' ? 'D' : 
  period == 'D' ? 'W' : 
  '5W'

calc = (period == '1') ? 5 : 
  (period == '3') ? 5 : 
  (period == '5') ? 3 : 
  (period == '15') ? 4 : 
  (period == '30') ? 4 : 
  (period == '45') ? 4 : 
  (period == '60') ? 4 : 
  (period == '120') ? 3 : 
  (period == '180') ? 3 : 
  (period == '240') ? 6 :
  (period == 'D') ? 5 : 
  5
  
count() =>
    indi = ema(close, fastLength) - ema(close, slowLength)
    signal = ema(indi, signalLength)
    Anlyse = 0.0
    // direction of indi and histogram
    hist = indi - signal
    Anlyse := (indi > indi[1] ?  (hist > hist[1] ? (indiside+histside) : (hist == hist[1] ? indiside : (indiside-histside))) : 0)
    Anlyse := Anlyse + (indi < indi[1] ?  (hist < hist[1] ? -(indiside+histside) : (hist == hist[1] ? -indiside : -(indiside-histside))) : 0) 
    Anlyse := Anlyse + (indi == indi[1] ?  (hist > hist[1] ? histside : (hist < hist[1] ? -histside : 0)) : 0) 
    // cross now earlier ?
    countcross = (indi>=signal and indi[1]<signal[1]) ? crossscore : ((indi<=signal and indi[1]>signal[1]) ? -crossscore : 0)
    countcross := countcross + (nz(countcross[1]) * 0.6)
    Anlyse := Anlyse + countcross
    nz(Anlyse[1])

Anlys = count()
AnlysHfrm = security(tickerid, HTF, count())

Result = (AnlysHfrm * calc + Anlys) / (calc + 1)

longCondition = (Result > 0 and Result[1] < 0)
// to make sure, 1 bar latency added
plotshape(longCondition[1], text="MACD Long", style=shape.labelup, color=lime, textcolor=blue, location=location.belowbar, transp=0)

shortCondition = (Result < 0 and Result[1] > 0)
// to make sure, 1 bar latency added
plotshape(shortCondition[1], text="MACD Short", style=shape.labeldown, color=red, textcolor=white, location=location.abovebar, transp=0)

alertcondition(longCondition[1], title='MACD Buy Signal', message='MACD Buy Signal')
alertcondition(shortCondition[1], title='MACD Sell Signal', message='MACD Sell Signal')
````

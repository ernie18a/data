# SonicR Strategy

- url: https://www.tradingview.com/script/4av32TGo-SonicR-Strategy/
- type: strategy
- pine_id: PUB;neCqeAD5Cv8nOUOYdIr9EyoBryzzdQjc
- version: 20.0

## Description

Base on SonicR System, just find better entry!

## Source Code

````pine
//@version=2
//Sonic R
strategy("SonicR Strategy Renko",shorttitle="Sonic R Strategy Renko",overlay=true,default_qty_value=10000,initial_capital=1000,currency=currency.USD)
EMA = input(defval=89, title="EMA Signal", type=integer)
HiLoLen     = input(34, minval=2,title="High Low channel Length")
pacC        = ema(close,HiLoLen)
pacL        = ema(low,HiLoLen)
pacH        = ema(high,HiLoLen)
PeriodLookBack = input(55)
xHighest = highest(PeriodLookBack)
xLowest = lowest(PeriodLookBack)
useTPandSL = input(defval = true, title = "Use exit order strategy?")
//Timeframe= input(defval=15, title="Time frame in minute", type=integer)
SL = input(defval=-20.00, title="Stop Loss in $", type=float, step=1)
TP = input(defval=100.00, title="Target Point in $", type=float, step=1)
// Constants colours that include fully non-transparent option.
DODGERBLUE = #1E90FFFF
// Plot the Price Action Channel (PAC) base on EMA high,low and close
L=plot(pacL, color=DODGERBLUE, linewidth=1, title="High PAC EMA",transp=50)
H=plot(pacH, color=DODGERBLUE, linewidth=1, title="Low PAC EMA",transp=50)
C=plot(pacC, color=DODGERBLUE, linewidth=2, title="Close PAC EMA",transp=0)
fill(L,H, color=aqua,transp=90,title="Fill HiLo PAC")
//Moving Average
signalMA =ema(close,EMA)
plot(signalMA,title="EMA Signal",color=yellow,linewidth=4,style=line)
//============ signal Generator ==================================//
pos = iff(close > xHighest[1], 1,
	     iff(close < xLowest[1], -1, nz(pos[1], 0))) 
possig = iff(pos == 1, -1,
          iff(pos == -1, 1, pos))
// SellConditiona.
closebelowMA =  close<pacH and close<signalMA and close<open
sellCondition = possig==1
goshort  = sellCondition
if(goshort)
    strategy.entry("Short",strategy.short)
// Buy Condition
buyCondition =  possig== -1
closeaboveMA = close>pacL and close>signalMA and close>open
golong = buyCondition
if(golong)
    strategy.entry("Long",strategy.long)
//// Highest, Lowest
barcolor(possig == -1 ? lime: possig == 1 ? red : blue )
plot(xHighest[1], color=red, title="HH")
plot(xLowest[1], color=lime, title="LL")
//Exit order.
closeshort =(strategy.openprofit <SL or strategy.openprofit>TP) and useTPandSL 
if(closeshort)
    strategy.close("Short")

closelong = (strategy.openprofit <SL or strategy.openprofit>TP) and useTPandSL
if(closelong)
    strategy.close("Long")
````

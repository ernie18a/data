# Scalping Support Resistance Strategy

- url: https://www.tradingview.com/script/gp332Dao-Scalping-Support-Resistance-Strategy/
- type: strategy
- pine_id: PUB;3765b807709a4bcb904aa6a9ff85de53
- version: 1.0

## Description

Scalping strategy for BTC using one line: Support Resistance.

The strategy draws a line based on the minimum value of the average of High, Low, and Close for a given bar. The entries are carried out on the breakdown of this line. Exits are managed by the specified in the script's inputs take-profit and stop-loss percentages.

From Stream:
https://www.tradingview.com/streams/U7au79Ck-W/

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © HPotter
TradeLong(Level, Take, Stop, ID, symbol, balance) =>
    strategy.cancel_all()
    msg = ROI.MsgDoLongMKT(ID, symbol,  balance) 
    strategy.entry("Long", strategy.long, stop = Level, alert_message = msg) 
    msg := ROI.MsgDoLongMKT(ID, symbol, 0) 
    strategy.exit('Exit', 'Long', limit = Level+Take, stop = Level - Stop, alert_message = msg) 
    
TradeShort(Level, Take, Stop, ID, symbol,balance) => 
    strategy.cancel_all()
    msg = ROI.MsgDoShortMKT(ID, symbol, balance)
    strategy.entry("Short", strategy.short, stop = Level, alert_message = msg)
    msg := ROI.MsgDoShortMKT(ID, symbol, 0)
    strategy.exit('Exit', 'Short', limit = Level-Take, stop = Level + Stop, alert_message = msg)
//@version=5
strategy("Iron Support Resistance Automat", shorttitle="Iron SRA", overlay = true, calc_on_order_fills = true)
import HPotter/RouterOrdersIron/1 as ROI
symbol = input.string("BTC")
ID = input.string("")
balance = input.float(20, minval=12)
TakePercent= input.float(1, minval=0.00001)
StopPercent= input.float(1, minval=0.00001)
LookBack = input.int(10)
PointBack = input.int(5)
ShowBackTest = input.bool(false)

var Green = color.new(color.green, 0)
var Red = color.new(color.red, 0)
var Blue =  color.new(color.blue, 0)
var Work = ShowBackTest
if barstate.islastconfirmedhistory or barstate.isrealtime
    Work := true

LLS = ta.lowest(hlc3, LookBack)
Level = LLS[PointBack]

var line lineLevel = na 
clr = close > Level ? Red  : Green 
line.delete(lineLevel)
lineLevel := line.new(bar_index-LookBack,  LLS[LookBack], bar_index,  Level,  color = clr)

Take = Level * TakePercent / 100 
Stop = Level * StopPercent / 100 
if Work and strategy.position_size == 0
    if close < Level 
        TradeLong(Level, Take, Stop, ID, symbol, balance)
    if close > Level 
        TradeShort(Level, Take, Stop, ID, symbol, balance)
barcolor(strategy.position_size < 0 ? Red : strategy.position_size > 0 ? Green: Blue)
````

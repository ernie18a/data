# Triple EMA Strategy

- url: https://www.tradingview.com/script/a9mAFvYF-Triple-EMA-Strategy/
- type: strategy
- pine_id: PUB;ejyjYyhA3MUxa0JGcBQMrxasBuphEOKd
- version: 1.0

## Description

This is my first ever script so any suggestions, recommendations or improvement ideas welcome!

This strategy is an implementation of a standard three exponential moving averages strategy (defaults: EMA1=5, EMA2=20 and EMA3=50 candles). Trades are executed if EMA1 crosses above/below EMA2 and they are both above/below EMA3. In addition, the close of the current candle must be above/below the previous one by at least the number of ticks you specify in the "buffer" parameter (default 150 ticks). This additional check eliminates many bad trades. 

There is also a trailing stoploss which comes into play once the price has gone above/below its initial value which it then follows the price with to ensure the trade closes at the highest possible price. 

I find this strategy works best on a 15 minute chart but feel free to play around and fine tune the various parameters. If you find a good setup that returns decent profits, I'd be keen to hear it!

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Matt Dearden - IndoPilot
// @version=4

/////////////////////////////////////////////////////// Initial Parameters /////////////////////////////////////////////////////// 
SystemName = "Triple EMA Strategy"
ShortSystemName = "TEMA"
InitPosition = 100000
InitCapital = 100000
InitCommission = 0.004 //approx value to compensate for Oanda spreads
InitPyramidMax = 0
CalcOnorderFills = true

strategy(title=SystemName, shorttitle=ShortSystemName, overlay=true, pyramiding=InitPyramidMax, 
 default_qty_type=strategy.cash, default_qty_value=InitPosition, commission_type=strategy.commission.percent, 
 commission_value=InitCommission, initial_capital=InitCapital, max_lines_count=500, 
 max_labels_count=500, process_orders_on_close=false, calc_on_every_tick=false) 

///////////////////////////////////////////////////////////// Inputs /////////////////////////////////////////////////////////////

DateFilter = input(false, "═════ Data Filtering ═════") 
InitYear = input(title="Year", type=input.integer, defval=2021, minval=2000, maxval=2021)
InitMonth = input(title="Month (0=ALL)", type=input.integer, defval=0, minval=0, maxval=12)
InitStopLoss = input(title="Stop Loss (ticks)", type=input.integer, defval=100, minval=0, maxval=1000) 
TrailingStopLoss = input(title="Trailing S/L (ticks)", type=input.integer, defval=130, minval=0, maxval=1000) 
InitBuffer = input(title="Buffer (ticks)", type=input.integer, defval=15, minval=0, maxval=1000) 
InitEMA1 = input(title="EMA 1", type=input.integer, defval=5, minval=0, maxval=1000) 
InitEMA2 = input(title="EMA 2", type=input.integer, defval=20, minval=0, maxval=1000) 
InitEMA3 = input(title="EMA 3", type=input.integer, defval=50, minval=0, maxval=1000) 

//////////////////////////////////////////////////////////// Variables ///////////////////////////////////////////////////////////

var StopLoss = float(0.0)
var StartPrice = float(0.0)
//setup multipliers and catch JPY difference
Multiplier = syminfo.currency == "JPY" ? 10 : 1000
//get the daily exchange rate from yesterday
//X_rate = security(AccountCurrency+syminfo.currency, "D", close[1]) 
OrderQty = int(InitCapital / (InitStopLoss / Multiplier))  
Buffer = InitBuffer / (Multiplier * 100)

/////////////////////////////////////////////////////// Triple EMA Strategy //////////////////////////////////////////////////////

EMA1 = ema(close, InitEMA1)
EMA2= ema(close, InitEMA2)
EMA3 = ema(close, InitEMA3)

//entry conditions
longCondition = crossover(EMA1, EMA2) and close > EMA3 and EMA1 > EMA3 and EMA2 > EMA3 and close > (close[1] + Buffer) 
shortCondition = crossunder(EMA1, EMA2) and close < EMA3 and EMA1 < EMA3 and EMA2 < EMA3 and close < (close[1] - Buffer) 

/////////////////////////////////////////////////////// Trailing Stoploss ////////////////////////////////////////////////////////

if (strategy.position_size > 0 and (close > (StartPrice + (TrailingStopLoss / (100 * Multiplier)))))  
    StopLoss := max(StopLoss, close - (TrailingStopLoss / (100 * Multiplier))) 
    strategy.exit("Long Stoploss", "Long", stop=StopLoss) 
    
if (strategy.position_size < 0 and (close < (StartPrice - (InitStopLoss / (100 * Multiplier))))) 
    StopLoss := min(StopLoss, close + (TrailingStopLoss / (100 * Multiplier)))
    strategy.exit("Short Stoploss", "Short", stop=StopLoss) 
    
///////////////////////////////////////////////////////// Setup entries /////////////////////////////////////////////////////////

if (longCondition and year == InitYear and (InitMonth == 0 or month == InitMonth))
    StartPrice := close
    StopLoss := StartPrice - (InitStopLoss / (100 * Multiplier)) 
    strategy.entry("Long", strategy.long, qty=OrderQty)
    strategy.exit("Long Stoploss", "Long", stop=StopLoss)

if (shortCondition and year == InitYear and (InitMonth == 0 or month == InitMonth))
    StartPrice := close
    StopLoss := StartPrice + (InitStopLoss / (100 * Multiplier)) 
    strategy.entry("Short", strategy.short, qty=OrderQty)
    strategy.exit("Short Stoploss", "Short", stop=StopLoss)
    
///////////////////////////////////////////////////////// Draw the EMAs /////////////////////////////////////////////////////////
plot(EMA1, "EMA1", color=#00FF00)
plot(EMA2, "EMA2", color=#FF0000)
plot(EMA3, "EMA3", color=#4040FF)
````

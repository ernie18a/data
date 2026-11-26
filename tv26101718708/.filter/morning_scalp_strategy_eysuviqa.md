# Morning Scalp Strategy

- url: https://www.tradingview.com/script/eYsUViQA-Morning-Scalp-Strategy/
- type: strategy
- pine_id: PUB;52466fcfc7c1412f8be001477e45dbf6
- version: 1.0

## Description

The Morning Scalp Strategy combines the 50EMA with the Stochastic Momentum Index. The morning period is when penny stocks usually have the highest volatility, so the strategy works between 10:00 AM and 12:10 PM.

***It opens only long positions. The ideal timeframe for this scalping strategy is 5 minutes on low-price stocks. The stock should spike in the morning with momentum and Volume.
***Look for a daily or intraday support area, close to the open position, to increase the confidence in the play

The components are:

- EMA50: Exponential Moving Average (EMA50)
- Stochastic Momentum Index (SMI)

Rules:

- Period: 10:00 AM and 12:10 PM 
- if SMI Crossover and SMI < 0, open a position
- If close < EMA50, close the position
- Profit target: To be decided by the user, default value = 10% above the entry price

If you have any questions, let me know!

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Trading_Bites
//@version=5

strategy('Morning Scalp', overlay=false, pyramiding=2, initial_capital=3000, default_qty_value=0, commission_value=0.02, max_labels_count=500)

                    // Initial Inputs

StartDate =         timestamp('15Aug 2022 14:00 +0000')
EndDate =           timestamp('15Aug 2022 20:00 +0000')
testPeriodStart =   input.time(StartDate, 'Start of trading')
testPeriodEnd =     input.time(EndDate, 'End of trading')
QuantityOnLong =    input.int(title="Quantity", defval=100,  minval=1)
QuantityOnClose =   QuantityOnLong

//////////////////////////////////////////////////////////////////////
//-- Time In Range
timeinrange(res, sess) =>
    not na(time(res, sess))

                //Market Open//
marketopen = '0930-1600'
MarketOpen = timeinrange(timeframe.period, marketopen)
//////////////////////////////////////////////////////////////////////
                //Market Hour//
morning =   '1000-1210'
Morning =   timeinrange(timeframe.period, morning)


//////////////////////////////////////////////////////////////////////////
               //STOCK MOMENTUM INDEX//
a = input(5, 'Percent K Length')
b = input(3, 'Percent D Length')
ovrsld = input.float(40, 'Over Bought')
ovrbgt = input(-40, 'Over Sold')
//lateleave = input(14, "Number of candles", type=input.integer)

// Range Calculation
ll = ta.lowest(low, a)
hh = ta.highest(high, a)
diff = hh - ll
rdiff = close - (hh + ll) / 2
// Nested Moving Average for smoother curves
avgrel = ta.ema(ta.ema(rdiff, b), b)
avgdiff = ta.ema(ta.ema(diff, b), b)
// SMI calculations
SMI = avgdiff != 0 ? avgrel / (avgdiff / 2) * 100 : 0
SMIsignal = ta.ema(SMI, b)

CrossoverIndex = ta.crossover(SMI, SMIsignal)
CrossunderIndex = ta.crossunder(SMI, SMIsignal)

plot1 = plot(SMI, color=color.new(color.aqua, 0), title='Stochastic Momentum Index', linewidth=1, style=plot.style_line)
plot2 = plot(SMIsignal, color=color.new(color.red, 0), title='SMI Signal Line', linewidth=1, style=plot.style_line)
hline = plot(ovrsld, color=color.new(color.red, 0), title='Over Bought')
lline = plot(ovrbgt, color=color.new(color.green, 0), title='Over Sold')

plot(CrossoverIndex ? close : na, color=color.new(color.aqua, 0), style=plot.style_cross, linewidth=2, title='RSICrossover')

mycol1 = SMIsignal > -ovrbgt ? color.red : na
mycol2 = SMIsignal < -ovrsld ? color.green : na

fill(plot1, hline, color=color.new(mycol1, 80))
fill(plot2, lline, color=color.new(mycol2, 80))

//////////////////////////////////////////////////////////////////////
                // Input EMA9 and EMA21 
EMA50Len      = input( 50 )
EMA50         = ta.ema(close, EMA50Len)
//////////////////////////////////////////////////////////////////////////

                // -------- VWAP  ----------//
vwapLine =      ta.vwap(close)
////////////////////////////////////////////////////////////////////////

                        //PROFIT TARGET//

longProfitPer   = input(10.0, title='Take Profit %') / 100
TargetPrice     = strategy.position_avg_price * (1 + longProfitPer) 
//plot              (strategy.position_size > 0 ? TargetPrice : na, style=plot.style_linebr, color=color.green, linewidth=1, title="Price Target") 
 
                    //BUY STRATEGY CONDITION//

condentry =     ta.crossover(SMI, SMIsignal) and SMI < 0
profittarget =  TargetPrice
stoploss =     close < EMA50

///////////////////////////STRATEGY BUILD//////////////////////////////////////

if MarketOpen
    
    if close > EMA50 

        if (condentry) and time > testPeriodStart and time < testPeriodEnd and Morning
            strategy.entry('Long', strategy.long, qty = QuantityOnLong)
            
        if profittarget and strategy.position_size > 0 
            strategy.exit(id="Long", limit=TargetPrice) 
                
if stoploss
    strategy.close('Long', qty = QuantityOnClose)
````

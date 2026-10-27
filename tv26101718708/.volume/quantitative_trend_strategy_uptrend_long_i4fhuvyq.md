# Quantitative Trend Strategy- Uptrend long

- url: https://www.tradingview.com/script/I4FhUvyq-Quantitative-Trend-Strategy-Uptrend-long/
- type: strategy
- pine_id: PUB;369a950647984e258432a67719077083
- version: 1.0

## Description

Trend Strategy #1 

Indicators: 
1. SMA
2. Pivot high/low functions derived from SMA 
3. Step lines to plot support and resistance based on the pivot points 
4. If the close is over the resistance line, green arrows plot above, and vice versa for red arrows below support. 

Strategy:
1. Long Only
2. Mutable 2% TP/1.5% SL 
3. 0.01% commission 
4. When the close is greater than the pivot point of the sma pivot high, and the close is greater than the resistance step line, a long position is opened. 
*At times, the 2% take profit may not trigger IF; the conditions for reentry are met at the time of candle closure + no exit conditions have been triggered. 
 5. If the position is in the green and the support step line crosses over the resistance step line, positions are exited. 

How to use it and what makes it unique:
Use this strategy to trade an up-trending market using a simple moving average to determine the trend. This strategy is meant to capture a good risk/reward in a bullish market while staying active in an appropriate fashion. This strategy is unique due to it's inclusion of the step line function with statistics derived from myself. 

This description tells the indicators combined to create a new strategy, with commissions and take profit/stop loss conditions included, and the process of strategy execution with a description on how to use it. If you have any questions feel free to PM me and boost if you enjoyed it. Thank you, pineUSERS!

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CheatCode1

//@version=5
strategy("Quantitative Trend Strategy- Uptrend long", 'Steady Uptrend Strategy', overlay=true, initial_capital = 1500, default_qty_value = 100, commission_type = strategy.commission.percent, commission_value = 0.01, default_qty_type = strategy.percent_of_equity)


length = input.int(20, minval=1)
src = input(close, title="Source")
basis = ta.sma(src, length)
offset = input.int(0, "Offset", minval = -500, maxval = 500)
plot(basis, "Basis", color=#FF6D00, offset = offset)

inp1 = input.int(46, 'LookbackLeft')
inp2 = input.int(32, 'LookbackRight')

l1 = ta.pivothigh(close, inp1, inp2)
S1 = ta.pivotlow(close, inp1, inp2)

// plot(l1, 'Pivothigh', color.red, 1)
// // plot(S1, 'Pivot Low', color.red)

l1V = ta.valuewhen(l1, close, 0)
S1V = ta.valuewhen(S1, close, 0)

Plotl1 = not na(l1) ? l1V : na
PlotS1 = not na(S1) ? S1V : na

plot(Plotl1, 'Resistance', color.green, 1, plot.style_stepline, true)
plot(PlotS1, 'Support', color.red, 1, plot.style_stepline, true)

Priceforlong = close > l1V ? true : na
Priceforshort = close < S1V ? true : na

plotshape(Priceforlong ? high : na, 'p', shape.arrowup, location.abovebar, color.green, size = size.small)
plotshape(Priceforshort ? low : na, 's', shape.arrowdown, location.belowbar, color.red, size = size.small)

vol = volume
volma = ta.sma(vol, 20)

Plotl1C = ta.valuewhen(na(Plotl1), l1V, 0)
PlotS1C = ta.valuewhen(na(PlotS1), S1V, 0)
//Strategy Execution
volc = volume > volma 

Lc1 = Priceforlong 

Sc1 = Priceforshort

sL = Plotl1 < PlotS1 ? close : na
sS = PlotS1 > Plotl1 ? close : na


if Lc1 
    strategy.entry('Long', strategy.long)
// if Sc1 and C2
//     strategy.entry('Short', strategy.short)

if Priceforshort
    strategy.cancel('Long')
if Priceforlong   
    strategy.cancel('Short')


// Stp1 = ta.crossover(k, d)
// Ltp1 = ta.crossunder(k, d)
// Ltp = d > 70  ? Ltp1 : na
// Stp = d < 30  ? Stp1 : na


if strategy.openprofit >= 0 and sL
    strategy.close('Long')
if strategy.openprofit >= 0 and sS
    strategy.close('Short')
takeP = input.float(2, title='Take Profit') / 100
stopL = input.float(1.75, title='Stop Loss') / 100


// // Pre Directionality

Stop_L = strategy.position_avg_price * (1 - stopL)

Stop_S = strategy.position_avg_price * (1 + stopL)

Take_S= strategy.position_avg_price * (1 - takeP)

Take_L = strategy.position_avg_price * (1 + takeP)
     
// sL = Plotl1 < PlotS1 ? close : na
// sS = PlotS1 < Plotl1 ? close : na
     
// //Post Excecution
if strategy.position_size > 0 and not (Lc1)
    strategy.exit("Close Long", stop = Stop_L, limit = Take_L)

if strategy.position_size < 0 and not (Sc1)
    strategy.exit("Close Short", stop = Stop_S, limit = Take_S)
````

# ALMA/EMA/SRSI Strategy + Indicator

- url: https://www.tradingview.com/script/As3pijB6-ALMA-EMA-SRSI-Strategy-Indicator/
- type: strategy
- pine_id: PUB;7f98dffa1d7941f189be45a01fa90256
- version: 2.0

## Description

Back with another great high hit rate strategy!!

[b]Disclaimer* This strategy was sampled using source code written by @ClassicScott , as referred to in the script, there is a clear line where the source code was scripted by myself. 
[/b]

This Strategy consists of three key factors, the ALMA,  EMA crossover, and a Stochastic Rsi

ALMA: The Alma is the step line shown, turning green and red at select times. This average value gives general oversight of the macro movement of price action. and this particular one was coded by Mr.ClassicScott. 

EMA crossover: At the input screen you are given an option of the fast and slow ema's. The default is solely for the hit rate and correlation to the Alma of this strategy. The arrows you see depicted on the chart are the crossover events happening. 

Stochastic Rsi: The Stochastic Rsi is a stochastic value, using data sampled from the rsi. The use of this indicator in my strategy is to prevent entries when too overbought and oversold, as well as closures and vice versa, to prevent holding bags either way. 

Fixed % TP: In the input screen you are given a take profit and stop loss percentage, for good R/R the hit rate will take a notch down, but with no R/R it will be near perfect. 

How to use this:
Add it to your chart to get the strategy inputs. (The strategy is really only useful on a 15min TF. However the indicator within it can be used on anything at anytime!)
Watch the yellow and aqua moving averages, these are your ema's and crossover's will trigger signals based on your integer inputs. 
Find Correlation between other leading indicators, as well as crossover's down/up and a red/green alma. 
DO NOT use the arrows as buy/sell signals. These are simply to show ema's are crossing under or over. Momentum indicator's paired with this can be useful to determine if it could be a buy signal or sell signal. 

Cheat Code's Notes: 
Almost at 1000 boosts!!! I appreciate the support from everyone and I will keep trying my best to deliver quality strategies for the people. 

-Cheat Code
 [symbol="BYBIT:BTCUSDT"]BYBIT:BTCUSDT[/symbol]

## Source Code

````pine
//@version=5

////Arranged by @ClassicScott
//Strategy Created by @CheatCode1


strategy('ALMA/EMA Strategy', shorttitle='ALMA/EMA Strategy', overlay=true,  margin_long=0, margin_short=0, default_qty_type = strategy.cash, initial_capital = 1000, pyramiding = 0, default_qty_value = 1000, max_bars_back = 100)



////Source Selection & ALMA Variables

//Dominant Momentum ALMA
dsource = input.source(close, title='Source', group='Dominant ALMA')
dperiod = input.int(title='Period', defval=130, group='Dominant ALMA')
doffset = input.float(title='Offset', step=0.025, defval=0.775, group='Dominant ALMA')
dsigma = input.float(title='Sigma', step=0.5, defval=4.5, group='Dominant ALMA')

dalma = ta.alma(dsource, dperiod, doffset, dsigma)

dalma_up_color = input.color(#66bb6a, 'Going Up!', group='Dominant ALMA', inline = '1')
dalma_down_color = input.color(#ef5350, 'Going Down :(', group='Dominant ALMA', inline = '1')
dcolor = close[1] > dalma ? dalma_up_color : dalma_down_color

////ALMA Plots
plot(dalma, color=dcolor, style=plot.style_stepline, linewidth=2, title='Dominant Momentum MA')



//Strategy by @CheatCode1 //Strategy by @CheatCode1 //Strategy by @CheatCode1 //Strategy by @CheatCode1 //Strategy by @CheatCode1 //Strategy by @CheatCode1 //Strategy by @CheatCode1 //Strategy by @CheatCode1 //Strategy by @CheatCode1 //Strategy by @CheatCode1 //Strategy by @CheatCode1 //Strategy by @CheatCode1

//Strategy by @CheatCode1 //Strategy by @CheatCode1 //Strategy by @CheatCode1 //Strategy by @CheatCode1 //Strategy by @CheatCode1 //Strategy by @CheatCode1 //Strategy by @CheatCode1 //Strategy by @CheatCode1 //Strategy by @CheatCode1 //Strategy by @CheatCode1 //Strategy by @CheatCode1 //Strategy by @CheatCode1

cheatcode = input.bool(true, '-----------CHEATC0DE1------------', group = 'Strategy Inputs', confirm = true)

//Variable Declerations/Plot Assingments

inp1 = input.int(49, 'Slow Ema Length', 1, 100, group = 'Strategy Inputs', confirm = true)
inp2 = input.int(9, 'Fast Ema Length', 1, 200, group = 'Strategy Inputs', confirm = true)
inp3 = int(200)
sma1 = ta.sma(close, inp3)
ema1 = ta.ema(close, inp1)
ema2 = ta.ema(close, inp2)

eplot1 = plot(ema1, 'Slow Ema', color.aqua, 1,  plot.style_linebr)
eplot2 = plot(ema2, 'Fast Ema', color.yellow, 1,  plot.style_linebr)
splot1 = plot(sma1, 'Long MA', close[1] < sma1 ? color.red:color.green, 1, plot.style_line, display = display.none)

cross1 = ta.crossover(ema1, ema2)
cross2 = ta.crossunder(ema1, ema2)

plotchar(cross2, '', '↑', location.belowbar,  close[1] > dalma and dalma > sma1 ? na:color.green, size = size.normal, editable = false)
plotchar(cross1, '', '↓', location.abovebar, close[1] < dalma and dalma < sma1 ? na:color.red, size = size.normal, editable = false)
bgcolor(cross1 and close[1] > dalma ? color.new(color.green, 80):cross2 and close[1] < dalma ? color.new(color.red, 80):na)

valueL = ta.valuewhen(cross1 and close[1] > dalma, close, 0)
valueS = ta.valuewhen(cross2 and close[1] < dalma, close, 0)

//Entries

if cross1 and close[2] > dalma[2] and close[1] > dalma[1]
    strategy.entry('Long', strategy.long)
if cross2 and close[2] < dalma[2] and close[1] < dalma[1]
    strategy.entry('Short', strategy.short)
    
//StochRsi
    
smoothK = input.int(3, "K", minval=1)
smoothD = input.int(15, "D", minval=1)
lengthRSI = input.int(14, "RSI Length", minval=1)
lengthStoch = input.int(8, "Stochastic Length", minval=1)
src = input(close, title="RSI Source")
rsi1 = ta.rsi(src, lengthRSI)
k = ta.sma(ta.stoch(rsi1, rsi1, rsi1, lengthStoch), smoothK)
d = ta.sma(k, smoothD)

//Cancellations

if k > 75
    strategy.cancel('Long')
if k < 25
    strategy.cancel('Short')
    
//Closures

if ta.crossunder(k, d) and k > 92
    strategy.close('Long')
if ta.crossover(k,d) and k < 8
    strategy.close('Short')

//Exit Percents

takeP = input.float(3, title='Take Profit', group = 'Take Profit and Stop Loss') / 100
stopL = input.float(5.49, title = 'Stop Loss', group = 'Take Profit and Stop Loss')/100
// Pre Directionality

Stop_L = strategy.position_avg_price * (1 - stopL)

Stop_S = strategy.position_avg_price * (1 + stopL)

Take_S= strategy.position_avg_price * (1 - takeP)

Take_L = strategy.position_avg_price * (1 + takeP)
     
     
//Post Excecution
if strategy.position_size > 0
    strategy.exit("Flat", limit=Take_L, stop = Stop_L)

if strategy.position_size < 0
    strategy.exit("Flat", limit=Take_S, stop = Stop_S)
````

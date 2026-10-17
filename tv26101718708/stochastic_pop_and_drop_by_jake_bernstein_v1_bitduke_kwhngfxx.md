# Stochastic Pop and Drop by Jake Bernstein v1 [Bitduke]

- url: https://www.tradingview.com/script/kWhNGFXX-Stochastic-Pop-and-Drop-by-Jake-Bernstein-v1-Bitduke/
- type: strategy
- pine_id: PUB;yK5RhoiMjO10b6BIUKe0jWMbPytiDqHw
- version: 1.0

## Description

I found a simple strategy by Jake Bernstein, modified it a little and created a strategy with Risk Management System (SL+TP); After that I test it on the different cryptocurrency pairs.

[b]About the Indicator[/b]

Basically it's the strategy of 2 indicators: Stochastic Oscillator to define the bias and Average Directional Index to confirm it.

One again, It uses Stochastic Oscillator to define the trading bias. In particular, the trading bias was deemed bullish when the weekly 14-period Stochastic Oscillator was above some default value (in him paper - 50) and rising and vice versa.

Once the trading bias is established, Steckler used the Average Directional Index (ADX) to define a slowdown in the trend. ADX measures the strength of the trend and a move below 20 signals a weak trend. 

[b]Modifications[/b]

I didn't implement Average Directional Index (ADX) and test just different sources for data, oscillator periods and different levels in relation to the crypto market.

So, it shows good results with two tight thresholds at 55 and 45 level. 

The bar chart below the defining the bullish and bearish periods (green and red) and gives a signal to enter the trade (purple bars).


[b]Backtesting[/b]

Backtested on [symbol="BITMEX:XBTUSD"]XBTUSD[/symbol] , [symbol="FTX:BTCPERP"]BTCPERP[/symbol] (FTX) pairs. You may notice it shows good results on 3h timeframe. 

Relatively low drawdown
~ 10% (from 2019 to date) FTX
~ 22% (4 years from 2016) Bitmex

I backtested on the different altcoin pairs as well, but the results were just not good.

Relatively good results were shown by some index pairs from the FTX exchange ([symbol="FTX:SHITPERP"]FTX:SHITPERP[/symbol]), but I think there is a few data for backtesting to be asure in them.

Bitmex 3h (2017 - 2020) :

[url=https://i.imgur.com/IUjS3hj.png]https://i.imgur.com/IUjS3hj.png[/url]

FTX 3h (2019 - 2020):

[url=https://i.imgur.com/fjujt1h.png]https://i.imgur.com/fjujt1h.png[/url]

[b]Possible Improvements[/b]

- Regarding trading algorithm it would be good to check with strategy with ADX somehow. Maybe for the better entries

- As for Risk Management system, it can be improved by adding trailing stop to the strategy.

Link: https://school.stockcharts.com/doku.php?id=trading_strategies:stochastic_pop_drop

## Source Code

````pine
//Created by Bitcoinduke
//Original Creator is Jake Bernstein 
// Link: https://school.stockcharts.com/doku.php?id=trading_strategies:stochastic_pop_drop
// Tested: XBTUSD 3h | BTCPERP FTX 3h

strategy(shorttitle="Stochastic Pop and Drop", title="Pop and Drop", overlay=false, 
     calc_on_every_tick=false, pyramiding=0, default_qty_type=strategy.cash, 
     default_qty_value=1000, currency=currency.USD, initial_capital=1000,
     commission_type=strategy.commission.percent, commission_value=0.075)

upper_threshold_buy = input(55, minval=50, title="Buy Entry/Exit Line")
lower_threshold_sell = input(45, maxval=50, title="Sell Entry/Exit Line")

oscillator_length = input(14, minval=1, title="Stochastic Length - Default 14")
sma_length = input(2, minval=1, title="SMA Length - 3-day (3 by default) simple moving average of stoch")

stoch_oscillator = sma(stoch(close, high, low, oscillator_length), sma_length)

//Upper and Lower Entry Lines
upper_line = upper_threshold_buy
lower_line = lower_threshold_sell

stoch_color = stoch_oscillator >= upper_line ? green : stoch_oscillator <= lower_line ? red : purple

//Charts
plot(stoch_oscillator, title="Stochastic", style=histogram, linewidth=4, color=stoch_color)
upper_threshold = plot(upper_line, title="Upper Line", style=line, linewidth=4, color=green)
lower_threshold = plot(lower_line, title="Lower Line", style=line, linewidth=4, color=red)

// Strategy Logic
LongSignal = stoch_oscillator >= upper_line and not (stoch_oscillator > lower_line and stoch_oscillator < upper_line) ? true : false
ShortSignal = stoch_oscillator <= lower_line and not (stoch_oscillator > lower_line and stoch_oscillator < upper_line) ? true : false

strategy.entry("POP_Short", strategy.short, when=ShortSignal)
strategy.entry("POP_Long", strategy.long, when=LongSignal)

// === Backtesting Dates === thanks to Trost

testPeriodSwitch = input(true, "Custom Backtesting Dates")
testStartYear = input(2019, "Backtest Start Year")
testStartMonth = input(1, "Backtest Start Month")
testStartDay = input(1, "Backtest Start Day")
testStartHour = input(0, "Backtest Start Hour")
testPeriodStart = timestamp(testStartYear, testStartMonth, testStartDay, testStartHour, 0)
testStopYear = input(2020, "Backtest Stop Year")
testStopMonth = input(1, "Backtest Stop Month")
testStopDay = input(5, "Backtest Stop Day")
testStopHour = input(0, "Backtest Stop Hour")
testPeriodStop = timestamp(testStopYear, testStopMonth, testStopDay, testStopHour, 0)
testPeriod() =>
    time >= testPeriodStart and time <= testPeriodStop ? true : false
testPeriod_1 = testPeriod()
isPeriod = testPeriodSwitch == true ? testPeriod_1 : true
// === /END
````

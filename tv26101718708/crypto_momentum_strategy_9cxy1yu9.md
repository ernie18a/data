# Crypto momentum strategy

- url: https://www.tradingview.com/script/9cxy1Yu9-Crypto-momentum-strategy/
- type: strategy
- pine_id: PUB;e273JbJpfiWmlxL0511IghXygnTORwc9
- version: 6.0

## Description

This strategy is based on LazyBear's Squeeze Momentum indicator. It analyzes when the trend in the momentum is shifting, locating the peaks and the valleys, and takes those as sell and buy signals respectively. This is a long strategy, so it also takes into consideration the 50 period Exponential Moving Average to identify upward trends. If the closing price of the candle is above the 50EMA, and the slope of the 50EMA is trending upwards, then the buy signal is executed. If these conditions are not met, the buy signal is ignored.

This strategy works well with crypto trading on the day/week charts.

It has a profit ratio of 4:1 on average, and roughly half of the trades are profitable.

## Source Code

````pine
//@version=4

//
// @author echepata
//
// @credits LazyBear for the Squeeze Momentum indicator.
// @credits see LazyBear's other indicators here https://www.tradingview.com/v/4IneGo8h/
//

initialBalance = 100000

strategy("Crypto momentum strategy", overlay=false, pyramiding=0, default_qty_value=100, default_qty_type= strategy.percent_of_equity, precision=7, currency=currency.AUD, commission_value=0.1, commission_type=strategy.commission.percent, initial_capital=initialBalance)


length = input(20, title="BB Length")
mult = input(2.0, title="BB MultFactor")
lengthKC = input(20, title="KC Length")
multKC = input(1.5, title="KC MultFactor")
emaPeriods = input(50, title="EMA periods")

useTrueRange = input(true, title="Use TrueRange (KC)", type=input.bool)
considerMarket = input(true, title="Consider crypto market behavior", type=input.bool)

marketTicker = tickerid('CRYPTOCAP', 'TOTAL', session.regular, adjustment.splits)
market = security(marketTicker, timeframe.period, close, true)
marketEma = ema(market, emaPeriods)
marketEmaSlope = marketEma - marketEma[1]

// Calculate BB
source = close
basis = sma(source, length)
ema = ema(source, emaPeriods)
dev = multKC * stdev(source, length)
upperBB = basis + dev
lowerBB = basis - dev

// Calculate KC
ma = sma(source, lengthKC)
range = useTrueRange ? tr : high - low
rangema = sma(range, lengthKC)
upperKC = ma + rangema * multKC
lowerKC = ma - rangema * multKC

sqzOn = lowerBB > lowerKC and upperBB < upperKC
sqzOff = lowerBB < lowerKC and upperBB > upperKC
noSqz = sqzOn == false and sqzOff == false

val = linreg(source - avg(avg(highest(high, lengthKC), lowest(low, lengthKC)), sma(close, lengthKC)), lengthKC, 0)

slope = (val - val[2])
emaSlope = (ema - ema[1])


bcolor = iff(slope > 0, color.lime, color.red)
scolor = noSqz ? color.green : sqzOn ? color.black : color.green
squeeze = (noSqz ? 0 : sqzOn ? 1 : 0)

plot(val, color=color.gray, style=plot.style_line, linewidth=1, title="momentum")
plot(slope, color=bcolor, style=plot.style_circles, linewidth=2, title="slope")
plot(0, color=scolor, style=plot.style_line, linewidth=2, title="squeeze-zero")

co = crossover(slope / abs(slope), 0)
cu = crossunder(slope / abs(slope), 0)

if co and source > ema and emaSlope > 0 and (not considerMarket or (market > marketEma and marketEmaSlope > 0))
    strategy.entry("long", strategy.long, comment="long")
if cu
    strategy.close("long")
````

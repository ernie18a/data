# Daily HIGH/LOW strategy

- url: https://www.tradingview.com/script/AHWDGy1z-Daily-HIGH-LOW-strategy/
- type: strategy
- pine_id: PUB;f75b12a03e284b68864184658e2738eb
- version: 1.0

## Description

This is a DAILY High/LOW strategy combined with a moving average and volume for more accuracy.

The rules are simple :

For long if we had a cross of the high with the previous high and close of the candle is above moving average and chaikin money flow volume is positive we have a long entry.
We exit when we cross down the moving average with the close of the candle.

For short if we had a crossdown of the low with the previous low and close of the candle is below moving average and chaikin money flow volume is negative we have a short entry.
We exit when we cross above the moving average with the close of the candle.


This strategy has no risk management inside so use it with caution.


If you have any questions, let me know

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © exlux99

//@version=5

strategy(title='Daily HIGH/LOW strategy', overlay=true, initial_capital=10000, calc_on_every_tick=true, default_qty_type=strategy.percent_of_equity, default_qty_value=100, commission_type=strategy.commission.percent, commission_value=0.1)

////////////////////////////GENERAL INPUTS//////////////////////////////////////
len = input.int(24, minval=1, title='Length MA', group='Optimization paramters')
src = input.source(close, title='Source MA', group='Optimization paramters')
out = ta.ema(src, len)

length = input.int(20, minval=1, title='CMF Length', group='Optimization paramters')
ad = close == high and close == low or high == low ? 0 : (2 * close - low - high) / (high - low) * volume
mf = math.sum(ad, length) / math.sum(volume, length)

f_secureSecurity(_symbol, _res, _src) =>
    request.security(_symbol, _res, _src[1], lookahead=barmerge.lookahead_on)

pricehigh = f_secureSecurity(syminfo.tickerid, 'D', high)
pricelow = f_secureSecurity(syminfo.tickerid, 'D', low)

plot(pricehigh, title='Previous Daily High', style=plot.style_linebr, linewidth=2, color=color.new(color.white, 0))
plot(pricelow, title='Previous Daily Low', style=plot.style_linebr, linewidth=2, color=color.new(color.white, 0))

short = ta.crossunder(low, pricelow) and close < out and mf < 0
long = ta.crossover(high, pricehigh) and close > out and mf > 0


if short and barstate.isconfirmed
    strategy.entry('short', strategy.short, when=barstate.isconfirmed, stop=pricelow[1])
    strategy.close('short', when=close > out)

if long and barstate.isconfirmed
    strategy.entry('long', strategy.long, when=barstate.isconfirmed, stop=pricehigh[1])
    strategy.close('long', when=close < out)
````

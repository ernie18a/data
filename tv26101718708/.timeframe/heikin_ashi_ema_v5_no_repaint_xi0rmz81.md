# Heikin Ashi EMA v5 no repaint 

- url: https://www.tradingview.com/script/xI0RmZ81-Heikin-Ashi-EMA-v5-no-repaint/
- type: strategy
- pine_id: PUB;00ff6768ef424940aa96449dce2bd525
- version: 1.0

## Description

This script was inspired by the "Heikin/Kaufman Strategy" from marco valente built on v2.

The script was rebuilt on the v5 and most importantly removed the repaint function that was driving surrealistic backtesting inflated numbers.

This script is now fully functional and not repainting - At the time of testing worked efficiently 90% WR and 2x profit factor on CFD WTI OIL with a 15m time frame indexed on forex.com price.

You should utilize this script with caution, especially on high volatility cycles you can try plotting against a volatility relative index or stop.

I also strongly recommend understanding the fundamentals of WTI OIL to balance the indications of the strategy with fundamentals.

Thanks to Clovis Warlop and Nilesh Sharma for their contribution.

Cheers,
Gustavo Bramao

## Source Code

````pine
//@version=5
//Heikin/Kaufman by Gustavo v5
strategy('Heikin Ashi EMA v5 no repaint ', shorttitle='Heikin Ashi EMA v5 no repaint', overlay=true, max_bars_back=500, default_qty_value=1000, initial_capital=100000, currency=currency.EUR)


// Settings - H/K
res1 = input.timeframe(title='Heikin Ashi EMA Time Frame', defval='D')
test = input(0, 'Heikin Ashi EMA Shift')
sloma = input(20, 'Slow EMA Period')
nAMA = hlc3

//Kaufman MA
Length = input.int(5, minval=1)
xPrice = input(hlc3)
xvnoise = math.abs(xPrice - xPrice[1])
Fastend = input.float(2.5, step=.5)
Slowend = input(20)
nfastend = 2 / (Fastend + 1)
nslowend = 2 / (Slowend + 1)
nsignal = math.abs(xPrice - xPrice[Length])
nnoise = math.sum(xvnoise, Length)
nefratio = nnoise != 0 ? nsignal / nnoise : 0
nsmooth = math.pow(nefratio * (nfastend - nslowend) + nslowend, 2)
nAMAn = nz(nAMA[1]) + nsmooth * (xPrice - nz(nAMA[1]))

//Heikin Ashi Open/Close Price
ha_t = ticker.heikinashi(syminfo.tickerid)
ha_close = request.security(ha_t, timeframe.period, nAMAn)
mha_close = request.security(ha_t, res1, hlc3)

//Moving Average
fma = ta.ema(mha_close[test], 1)
sma = ta.ema(ha_close, sloma)
plot(fma, title='MA', color=color.new(color.black, 0), linewidth=2, style=plot.style_line)
plot(sma, title='SMA', color=color.new(color.red, 0), linewidth=2, style=plot.style_line)

//Strategy
golong = ta.crossover(fma, sma)
goshort = ta.crossunder(fma, sma)

strategy.entry('Buy', strategy.long, when=golong)
strategy.entry('Sell', strategy.short,when=goshort)
````

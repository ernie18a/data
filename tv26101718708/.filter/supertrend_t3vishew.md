# SuperTrend

- url: https://www.tradingview.com/script/t3vishEw/
- type: strategy
- pine_id: PUB;XeJw69G0cww1QE8dovmm90NIA58qFVso
- version: 1.0

## Description

rtyrty rty rtyrt yrty rtyrt yrty rty

## Source Code

````pine
strategy(title = "SuperTrend", shorttitle = "BTC")
ema5=ema(close, 5)
ema2=ema(close, 2)
 
demaFast =  security(tickerid, "30", 2 * ema5 - ema(ema5, 5)  )

plotchar((2 * ema5 - ema(ema5, 5)), "d", "", location = location.top)
plotchar(demaFast, "fast", "", location = location.top)

demaSlow  = security(tickerid,"30", 2 * ema2 - ema(ema2, 2)  )
plotchar(demaSlow, "slow", "", location = location.top)

buy = crossover(demaSlow, demaFast)
sell = crossunder(demaSlow, demaFast)
strategy.entry("BUY", strategy.long, 1, when = buy)
strategy.entry("SELL", strategy.short, 1, when = sell )
````

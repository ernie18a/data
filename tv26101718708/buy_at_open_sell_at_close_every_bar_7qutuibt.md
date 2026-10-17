# Buy At Open / Sell At Close Every Bar

- url: https://www.tradingview.com/script/7qUtuiBt-Buy-At-Open-Sell-At-Close-Every-Bar/
- type: strategy
- pine_id: PUB;1b3c210870f64357acec3214b4b0f889
- version: 1.0

## Description

This strategy demonstrates that the probability of a candle closing higher or lower is approximately 50/50. In that sense, trading resembles one of the most balanced gambling environments in financial markets. However, profitability is not determined by the number of winning candles, but by the size of the move during the candle you entered.

The same logic applies to prediction markets such as Polymarket when users bet on the direction of the next candle — the odds of winning or losing are essentially close to 50/50.

## Source Code

````pine
//@version=6
strategy("Buy At Open / Sell At Close Every Bar", overlay=true, pyramiding=0)

// קונה בתחילת כל נר
if barstate.isnew and strategy.position_size == 0
    strategy.entry("Long", strategy.long)

// מוכר בסוף כל נר
if barstate.isconfirmed and strategy.position_size > 0
    strategy.close("Long")
````

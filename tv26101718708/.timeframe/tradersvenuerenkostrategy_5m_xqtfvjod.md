# TradersVenue_Renko_Strategy 5M

- url: https://www.tradingview.com/script/xqtFVjoD-TradersVenue-Renko-Strategy-5M/
- type: strategy
- pine_id: PUB;lmS1vZ5TWwvskD7oOnTLV6xIJTc65ccu
- version: 1.0

## Description

TradersVenue Renko strategy for intraday and positional trading. It generates buy/sell signals basis Renko ATR and 5M timeframe.

## Source Code

````pine
//@version=3
strategy("TradersVenue_Renko_Strategy",shorttitle="TradersVenue_Renko_Strategy", overlay=true, calc_on_every_tick=true, calc_on_order_fills=true)

res = input(title="Resolution", type=resolution, defval="5")
//Heikin ashi taken from trading view's funciton and resolusion added 
ha_t = renko(tickerid, "close", "ATR", 2)
//heikinashi(tickerid)
ha_open = security(ha_t, res, open)
ha_close = security(ha_t, res, close)
ha_high = security(ha_t, res, high)
ha_low = security(ha_t, res, low)

// golong = ha_close > ha_open 
// goshort = ha_close < ha_open

ha_open_p = security(ha_t, res, open[1])
ha_close_p = security(ha_t, res, close[1])
ha_high_p = security(ha_t, res, high[1])
ha_low_p = security(ha_t, res, low[1])

golong = ha_low == ha_open and ha_close_p > ha_open_p
goshort = ha_high == ha_open and ha_close_p < ha_open_p

strategy.entry("R Buy",strategy.long, when = golong and time > timestamp(2018,6,1,0,0))
strategy.entry("R Sell",strategy.short, when = goshort and time > timestamp(2018,6,1,0,0))
````

# open>open[1]=BUY_else_SELL

- url: https://www.tradingview.com/script/5zYcH3Gx-open-open-1-BUY-else-SELL/
- type: strategy
- pine_id: PUB;RMqitDCXtSaXWeSBPgJUfNZmv32EVW7Q
- version: 1.0

## Description

simple script. enter rule is [b]open>open[1]=BUY_else_SELL[/b] (open[1] means open price 1 candle ago, so basically its if price now greater than price 1 candle ago...)
exit rule is Trailing Stop.
1 trade per candle, here on daily chart [symbol="BINANCE:BTCUSDT"]BTCUSDT[/symbol] with binance commision included in result.
254 million percent profit....
                                                  😲

## Source Code

````pine
//@version=4
strategy(title="open>open[1]=BUY_else_SELL",shorttitle="O>O[1]=BUY",overlay=true,currency="USD",initial_capital=100000,default_qty_type=strategy.percent_of_equity,default_qty_value=50,commission_type=strategy.commission.percent,commission_value=0.5)
TrailingStop=input(defval=1,title="Trailing Stop (pips)",minval=1)
if(open>open[1])
    strategy.entry("long",strategy.long,alert_message="Enter- BUY")
if(open<open[1])
    strategy.entry("short",strategy.short,alert_message="Enter- SELL")
strategy.exit("TS",trail_points=TrailingStop,trail_offset=1,alert_message="Close- TrailStop")
````

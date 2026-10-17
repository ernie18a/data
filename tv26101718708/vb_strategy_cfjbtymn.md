# VB Strategy

- url: https://www.tradingview.com/script/cfJBtyMn/
- type: strategy
- pine_id: PUB;Aoxc7EUSG4YDGce4kOxZPg7ZXFMUzwVw
- version: 8.0

## Description

[url=https://kr.tradingview.com/script/nLcYOH5a/]https://kr.tradingview.com/script/nLcYOH5a/[/url]
VB Indicator

[url=https://kr.tradingview.com/script/IZpF4xgk/]https://kr.tradingview.com/script/IZpF4xgk/[/url]
VB Indicator PRO (with Alarm function)

With this strategy, you can test VB indicator.

This strategy use entry and close price
entry price = (high price + low price) / 2
close price = (high price + low price) / 2


이 전략으로 VB 지표에 대해 테스트할 수 있습니다.

이 전략의 진입가와 청산가는 아래와 같이 설정합니다.
진입가 = (고점+저점) / 2
청산가 = (고점+저점) / 2

## Source Code

````pine
//@version=3
strategy("no more support, Add VB Strategy + MACD", overlay=true, default_qty_type=strategy.percent_of_equity, max_bars_back=720, default_qty_value=100, calc_on_order_fills= true, calc_on_every_tick=true, pyramiding=0)

length = input(120, title="no more support")
gfg = input(120, title="Add VB Strategy + MACD")

strategy.entry("Add VB Strategy + MACD",strategy.long)
````

# 10 week line on daily chart

- url: https://www.tradingview.com/script/CDqnqeBA/
- type: indicator
- pine_id: PUB;3ac7fb64243d48c9b22216aa09a7684b
- version: 1.0

## Description

10 week line on daily chart
10 week line on daily chart
10 week line on daily chart

## Source Code

````pine
//@version=6
indicator('當週即時 10週線（日線圖）', overlay = true)

tenWeekNow = request.security(syminfo.tickerid, 'W', ta.sma(close, 10), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

plot(tenWeekNow, title = '當週即時10週線', color = color.orange, linewidth = 2)
````

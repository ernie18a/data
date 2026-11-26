# Prev Week/Day High-Low Lines

- url: https://www.tradingview.com/script/qwAByCHN-Prev-Week-Day-High-Low-Lines/
- type: indicator
- pine_id: PUB;6852ed7be5a14650917f87d73912eab3
- version: 1.0

## Description

Marks previous day and previous week highs and lows. Past days/weeks stay on chart as well.

## Source Code

````pine
//@version=6
indicator("Prev Week/Day High-Low Lines", overlay=true)

// Previous Day High/Low — high/low include wicks (not just open/close body)
[pdHigh, pdLow] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_on)

// Previous Week High/Low — high/low include wicks
[pwHigh, pwLow] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead=barmerge.lookahead_on)

plot(pdHigh, title="Prev Day High (wick)", color=color.yellow, linewidth=1)
plot(pdLow, title="Prev Day Low (wick)", color=color.yellow, linewidth=1)

plot(pwHigh, title="Prev Week High (wick)", color=color.blue, linewidth=1)
plot(pwLow, title="Prev Week Low (wick)", color=color.blue, linewidth=1)
````

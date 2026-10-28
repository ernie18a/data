# Adaptive 300W SMA

- url: https://www.tradingview.com/script/jZsZwpiL-Adaptive-300W-SMA/
- type: indicator
- pine_id: PUB;7edf5889e84046a4a274937ed1a1e0df
- version: 1.0

## Description

[b]Adaptive Moving Average — plots from bar one
[/b]

A long-period MA like a 300-week SMA normally won't appear until the chart has 300 weeks of history, so on younger assets (most crypto, newer tickers) the line stays blank for years. This indicator fixes that with an adaptive length.
The average is calculated over however many bars exist so far, then locks to the full period once enough history builds up: 1 week of data gives a 1-week average, 2 weeks a 2-week average, and so on up to the set Length (default 300) — after which it behaves exactly like a normal rolling SMA. So the line plots from the very first bar while staying mathematically identical to the standard version past the full period.
Tips

Apply on a weekly chart for a true 300-week average (Length counts chart bars).
Change the Length input to use any period.

Early values sit closer to price (fewer bars averaged) and smooth out as the window fills. No repainting — only the current, still-forming bar updates, as with any moving average.

## Source Code

````pine
//@version=6
indicator("Adaptive 300W SMA", overlay = true, max_bars_back = 300)

length = input.int(300, "Length (weeks)", minval = 1)

// expanding-then-rolling average of whatever series this runs on
adaptive(src) =>
    var float runSum = 0.0
    runSum := runSum + src
    if bar_index >= length
        runSum := runSum - src[length]
    runSum / math.min(bar_index + 1, length)

// pin the calculation to WEEKLY closes regardless of the chart's timeframe
adaptiveMA = request.security(syminfo.tickerid, "W", adaptive(close), lookahead = barmerge.lookahead_off)

plot(adaptiveMA, "Adaptive 300W MA", color = color.green, linewidth = 2)
````

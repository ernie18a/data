# Protection Price (Wenhua / TDX)

- url: https://www.tradingview.com/script/RjYTh7gm-Protection-Price-Wenhua-TDX/
- type: indicator
- pine_id: PUB;643b11d19f4d49f28e6d0783176b8860
- version: 1.0

## Description

A short-term support and stop-loss reference line adapted from the Wenhua/TDX trading platform community formula.

— FORMULA —

  Protection Price = ( Close[2] + Close[1] + Open ) / 3

That is, the average of the two prior bars' closes and the current bar's open.

— INTERPRETATION —

• When price holds above the line, short-term structure favors continuation of the prevailing trend.
• A clean break below the line, particularly with expanding range or volume, often precedes a deeper pullback.
• Useful as a soft stop-loss anchor for swing positions.

— TIMEFRAME NOTE —

This indicator was designed for daily charts, where the three input bars span three trading sessions and carry meaningful overnight gap information. On lower intraday timeframes (5m, 15m) the line will naturally track close to price, behaving like a three-bar smoothing — this is expected, not a bug. For a true daily-level Protection Price displayed on an intraday chart, request the daily series via request.security().

— BEST PAIRED WITH —

"D/K Strength + Smart Money Accumulation" sub-chart indicator for complete entry and exit context.

A faithful Pine v6 port of the original community formula.

## Source Code

````pine
//@version=6
// 保护价 = (REF(C,2) + REF(C,1) + O) / 3
// 即 (前2日收盘 + 前1日收盘 + 当日开盘) / 3，画在主图作支撑/止损参考。
indicator(title = "保护价", overlay = true)

baohuJia = (close[2] + close[1] + open) / 3.0

plot(baohuJia, title = "保护价", color = color.blue, linewidth = 2, style = plot.style_line)
````

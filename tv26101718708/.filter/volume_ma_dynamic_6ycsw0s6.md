# Volume MA Dynamic

- url: https://www.tradingview.com/script/6YCSw0S6/
- type: indicator
- pine_id: PUB;f87ab4d75c9c4b68ada46209903a1498
- version: 2.0

## Description

Volume Dynamic MA automatically adapts its volume moving average to the chart timeframe, so you get a cleaner multi-timeframe read on participation without constantly changing settings.

On daily charts, it plots a 50-day volume MA.
On weekly and monthly charts, it switches to a 10-week volume MA.
On intraday charts below 1D, the MA is hidden to keep the volume pane clean and readable.

The script also includes an optional bar-coloring mode based on current close vs previous close, which can offer a different view of volume pressure compared with the standard close vs open method.

This indicator is especially useful for traders who want a simple, practical way to keep volume analysis consistent across swing and position-trading timeframes.

## Source Code

````pine
//@version=6
indicator('Volume MA Dynamic', shorttitle = 'VolMA 50D/10W', format = format.volume)

dailyLength = input.int(50, '日线均量周期', minval = 1)
weeklyLength = input.int(10, '周线均量周期', minval = 1)
colorByPrevClose = input.bool(true, 'K线颜色基于前一收盘价')

isWeeklyOrHigher = timeframe.isweekly or timeframe.ismonthly
isDaily = timeframe.isdaily

dailyVolMa = request.security(syminfo.tickerid, 'D', ta.sma(volume, dailyLength))
weeklyVolMa = request.security(syminfo.tickerid, 'W', ta.sma(volume, weeklyLength))

float volMa = na

if isWeeklyOrHigher
    volMa := weeklyVolMa
    volMa
else if isDaily
    volMa := dailyVolMa
    volMa

prevClose = close[1]
isUpBar = colorByPrevClose ? close >= prevClose : close >= open
volColor = isUpBar ? #089981 : #ff5252

plot(volume, title = '成交量', style = plot.style_columns, color = volColor)
plot(volMa, title = 'Volume MA', color = color.orange, linewidth = 2)

volPct = not na(volMa) and volMa != 0 ? volume / volMa * 100: na
plot(volPct, title = 'Vol %', display = display.status_line, format = format.percent, precision = 1)
````

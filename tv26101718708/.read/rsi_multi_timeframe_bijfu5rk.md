# RSI Multi Timeframe

- url: https://www.tradingview.com/script/BIjfu5rk-RSI-Multi-Timeframe/
- type: indicator
- pine_id: PUB;bfc563a280c247be8c319b5edb5a7040
- version: 1.0

## Description

This indicator shows RSI value on differen different timeframe, like 1minute, 5minute, 1day etc.

## Source Code

````pine
//@version=6
indicator('RSI Multi Timeframe', shorttitle = 'RSI_MTF', overlay = false)

// Inputs
len = input.int(14, title = 'Length')
src = input.source(close, title = 'Source')

show5m = input.bool(true, title = 'Show 5m')
show15m = input.bool(true, title = 'Show 15m')
show30m = input.bool(true, title = 'Show 30m')
show1h = input.bool(true, title = 'Show 1h')
show2h = input.bool(true, title = 'Show 2h')
show4h = input.bool(true, title = 'Show 4h')
show1D = input.bool(true, title = 'Show 1D')
show1W = input.bool(true, title = 'Show 1W')
show1M = input.bool(true, title = 'Show 1M')

// Current RSI
rsiCurrent = ta.rsi(src, len)

// Multi Timeframe RSI
rsi5m = request.security(syminfo.tickerid, '5', ta.rsi(src, len))
rsi15m = request.security(syminfo.tickerid, '15', ta.rsi(src, len))
rsi30m = request.security(syminfo.tickerid, '30', ta.rsi(src, len))
rsi1h = request.security(syminfo.tickerid, '60', ta.rsi(src, len))
rsi2h = request.security(syminfo.tickerid, '120', ta.rsi(src, len))
rsi4h = request.security(syminfo.tickerid, '240', ta.rsi(src, len))
rsi1D = request.security(syminfo.tickerid, 'D', ta.rsi(src, len))
rsi1W = request.security(syminfo.tickerid, 'W', ta.rsi(src, len))
rsi1M = request.security(syminfo.tickerid, 'M', ta.rsi(src, len))

// ==========================
// RSI BAND LINES
// ==========================
upperBand = hline(70, 'Upper Band', color = color.red)
middleBand = hline(50, 'Middle Band', color = color.gray)
lowerBand = hline(30, 'Lower Band', color = color.green)

// Background fill
fill(upperBand, lowerBand, color = color.new(color.purple, 90))

// ==========================
// PLOTS
// ==========================

// Current timeframe RSI
plot(rsiCurrent, color = color.red, linewidth = 2, title = 'RSI Current')

// MTF RSI plots
plot(show5m ? rsi5m : na, color = color.gray, title = 'RSI 5m')
plot(show15m ? rsi15m : na, color = color.silver, title = 'RSI 15m')
plot(show30m ? rsi30m : na, color = color.teal, title = 'RSI 30m')
plot(show1h ? rsi1h : na, color = color.orange, title = 'RSI 1H')
plot(show2h ? rsi2h : na, color = color.yellow, title = 'RSI 2H')
plot(show4h ? rsi4h : na, color = color.blue, title = 'RSI 4H')
plot(show1D ? rsi1D : na, color = color.purple, title = 'RSI 1D')
plot(show1W ? rsi1W : na, color = color.rgb(39, 64, 176), title = 'RSI 1W')
plot(show1M ? rsi1M : na, color = color.rgb(142, 176, 39), title = 'RSI 1M')
````

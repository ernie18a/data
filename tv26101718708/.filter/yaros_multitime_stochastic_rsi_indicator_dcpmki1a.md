# Yaro's Multitime Stochastic RSI indicator

- url: https://www.tradingview.com/script/dCpmKI1a-yaro-s-multitime-stochastic-rsi-indicator/
- type: indicator
- pine_id: PUB;7583314d4f4c4069b0b02d5b27c19c93
- version: 1.0

## Description

Multitimeframe StochRSI
to choose minutes - no additional symbol
for seconds add "S" after the number - "1S", "5S" etc
for Days add "D"
for Weeks add "W"
Have a nice trading!

## Source Code

````pine
//@version=6
indicator(title="Yaro's Multitime Stochastic RSI indicator", shorttitle="MultiStoch RSI", format=format.price, precision=5, max_bars_back = 4999, max_polylines_count =50, max_lines_count = 400)
stf1 = input.bool(true, "1", inline = "1" )
tf1 = input.string("1", "timeframe 1", inline = "1")
stf2 = input.bool(true, "1", inline = "2" )
tf2 = input.string("3", "timeframe 2", inline = "2")
stf3 = input.bool(true, "1", inline = "3" )
tf3 = input.string("5", "timeframe 3", inline = "3")
stf4 = input.bool(true, "1", inline = "4" )
tf4 = input.string("15", "timeframe 4", inline = "4")
stf5 = input.bool(true, "1", inline = "5" )
tf5 = input.string("60", "timeframe 5", inline = "5")
stf6 = input.bool(true, "1", inline = "6" )
tf6 = input.string("1D", "timeframe 6", inline = "6")
stf7 = input.bool(true, "1", inline = "7" )
tf7 = input.string("1W", "timeframe 7", inline = "7")


hlength = input.int(1, "length mult")
smoothK = input.int(3, "K", minval=1)
lengthRSI = input.int(14, "RSI Length", minval=1)
lengthStoch = input.int(14, "Stochastic Length", minval=1)

k = request.security(syminfo.tickerid, tf1, ta.sma(ta.stoch(ta.rsi(close, lengthRSI), ta.rsi(close, lengthRSI),ta.rsi(close, lengthRSI), lengthStoch), smoothK))
k1 = request.security(syminfo.tickerid, tf2, ta.sma(ta.stoch(ta.rsi(close, lengthRSI), ta.rsi(close, lengthRSI),ta.rsi(close, lengthRSI), lengthStoch), smoothK))
k2 = request.security(syminfo.tickerid, tf3, ta.sma(ta.stoch(ta.rsi(close, lengthRSI), ta.rsi(close, lengthRSI),ta.rsi(close, lengthRSI), lengthStoch), smoothK))
k3 = request.security(syminfo.tickerid, tf4, ta.sma(ta.stoch(ta.rsi(close, lengthRSI), ta.rsi(close, lengthRSI),ta.rsi(close, lengthRSI), lengthStoch), smoothK))
k4 = request.security(syminfo.tickerid, tf5, ta.sma(ta.stoch(ta.rsi(close, lengthRSI), ta.rsi(close, lengthRSI),ta.rsi(close, lengthRSI), lengthStoch), smoothK))
k5 = request.security(syminfo.tickerid, tf6, ta.sma(ta.stoch(ta.rsi(close, lengthRSI), ta.rsi(close, lengthRSI),ta.rsi(close, lengthRSI), lengthStoch), smoothK))
k6 = request.security(syminfo.tickerid, tf7, ta.sma(ta.stoch(ta.rsi(close, lengthRSI), ta.rsi(close, lengthRSI),ta.rsi(close, lengthRSI), lengthStoch), smoothK))


plot(stf1? k : na, "K1", color=#92e7b0)
plot(stf2? k1 : na, "K2", color=color.rgb(54, 174, 96))
plot(stf3? k2 : na, "K3", color=color.rgb(1, 101, 36), linewidth = 1)
plot(stf4? k3 : na, "K4", color=color.rgb(191, 118, 222), linewidth = 2)
plot(stf5? k4 : na, "K5", color=color.rgb(172, 40, 150), linewidth = 2)
plot(stf6? k5 : na, "K6", color=#620360, linewidth = 2)
plot(stf7? k6 : na, "K7", color=color.rgb(10, 14, 244), linewidth = 3)
````

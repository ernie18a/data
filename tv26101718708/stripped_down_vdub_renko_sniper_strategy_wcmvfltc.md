# Stripped Down Vdub Renko Sniper Strategy

- url: https://www.tradingview.com/script/WcmvfLTc-Stripped-Down-Vdub-Renko-Sniper-Strategy/
- type: strategy
- pine_id: PUB;icVMP8poLTf8tPMlMTvqQzzpMsQMcsQX
- version: 2.0

## Description

I turned the Vdub Renko Sniper study into a strategy script.

## Source Code

````pine
//╭╮╱╱╭╮╭╮╱╱╭╮
//┃╰╮╭╯┃┃┃╱╱┃┃
//╰╮┃┃╭┻╯┣╮╭┫╰━┳╮╭┳━━╮
//╱┃╰╯┃╭╮┃┃┃┃╭╮┃┃┃┃━━┫
//╱╰╮╭┫╰╯┃╰╯┃╰╯┃╰╯┣━━┃
//╱╱╰╯╰━━┻━━┻━━┻━━┻━━╯
//╭━━━┳╮╱╱╱╱╱╱╱╭╮
//┃╭━╮┃┃╱╱╱╱╱╱╱┃┃
//┃┃╱╰┫╰━┳━━┳━╮╭━╮╭━━┫┃
//┃┃╱╭┫╭╮┃╭╮┃╭╮┫╭╮┫┃━┫┃
//┃╰━╯┃┃┃┃╭╮┃┃┃┃┃┃┃┃━┫╰╮
//╰━━━┻╯╰┻╯╰┻╯╰┻╯╰┻━━┻━╯
//━╯
//Vdub Renko SniperVX1 v1 // ATR Setting = 1
//  ©Vdubus http://www.vdubus.co.uk/
strategy(title = "Stripped Down Vdub Renko Sniper Strategy", shorttitle = "Vdub Renko Strat", overlay = true, precision=5,
  pyramiding = 1, default_qty_type = strategy.percent_of_equity, default_qty_value = 100,
  calc_on_order_fills=true, initial_capital = 500)

// Date range filter
testStartYear = input(2018, "Backtest Start Year")
testStartMonth = input(1, "Backtest Start Month")
testStartDay = input(1, "Backtest Start Day")
testPeriodStart = timestamp(testStartYear, testStartMonth, testStartDay, 0, 0)

testStopYear = input(2018, "Backtest Stop Year")
testStopMonth = input(12, "Backtest Stop Month")
testStopDay = input(31, "Backtest Stop Day")
testPeriodStop = timestamp(testStopYear, testStopMonth, testStopDay, 0, 0)

//Modified - Rajandran R Supertrend-----------------------------------------------------
Factor=input(1, minval=1,maxval = 1000, title="Trend Transition Signal")
Pd=input(1, minval=1,maxval = 1000, title="Period")
Up=hl2-(Factor*atr(Pd))
Dn=hl2+(Factor*atr(Pd))
TrendUp=close[1]>TrendUp[1]? max(Up,TrendUp[1]) : Up
TrendDown=close[1]<TrendDown[1]? min(Dn,TrendDown[1]) : Dn
Trend = close > TrendDown[1] ? 1: close< TrendUp[1]? -1: nz(Trend[1],0)

inTimeRange = time >= testPeriodStart and time <= testPeriodStop
goLong = inTimeRange and Trend == 1 and Trend[1] == -1
goShort = inTimeRange and Trend == -1 and Trend[1] == 1

plotarrow(goLong ? Trend : na, title="Up Entry Arrow", colorup=lime, maxheight=1000, minheight=50)
plotarrow(goShort ? Trend : na, title="Down Entry Arrow", colordown=red, maxheight=1000, minheight=50)

strategy.entry("longgg", strategy.long, when=goLong)
strategy.entry("shortttt", strategy.short, when=goShort)
strategy.exit("XL", from_entry = "long", profit = na, loss = na)
strategy.exit("XS", from_entry = "short", profit = na, loss = na)
````

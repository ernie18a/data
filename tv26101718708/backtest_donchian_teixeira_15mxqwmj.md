# Backtest Donchian Teixeira

- url: https://www.tradingview.com/script/15mXQWmj/
- type: strategy
- pine_id: PUB;G45xHX7cNSjv5ami7JvDbdNHUlO9ObGc
- version: 4.0

## Description

Bolsa de Valores Vapt Vupt

## Source Code

````pine
//@version=4
strategy(title="Backtest Donchian-Teixeira Pirata", default_qty_type=strategy.fixed, default_qty_value=100, overlay=true, commission_type=strategy.commission.cash_per_order, commission_value=2.50, precision=2, calc_on_every_tick=true, pyramiding=0, initial_capital=10000)

testStartYear = input(2000, "Backtest Start Year")
testStartMonth = input(1, "Backtest Start Month")
testStartDay = input(1, "Backtest Start Day")
testPeriodStart = timestamp(testStartYear, testStartMonth, testStartDay, 00, 00)

testEndYear = input(2018, "Backtest End Year")
testEndMonth = input(12, "Backtest End Month")
testEndDay = input(1, "Backtest End Day")
testPeriodEnd = timestamp(testStartYear, testStartMonth, testStartDay, 23, 59)

window() =>  //nao funciona
    time >= testPeriodStart and time <= testPeriodEnd ? true : false

length1 = input(20, minval=1, title="Upper Channel")
length2 = input(20, minval=1, title="Lower Channel")

dcUpper = highest(length1)
dcLower = lowest(length2)

plot(dcLower, style=plot.style_line, linewidth=1, color=color.red, offset=1)
plot(dcUpper, style=plot.style_line, linewidth=1, color=color.lime, offset=1)
plot(dcLower, style=plot.style_line, linewidth=1, color=color.gray)

if strategy.position_size == 0
    strategy.entry("COMPRA", true, stop=dcUpper)

if strategy.position_size > 0
    strategy.exit("VENDA", stop=dcLower)
````

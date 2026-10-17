# Donchian Strategy

- url: https://www.tradingview.com/script/JDULzabS-Donchian-Strategy/
- type: strategy
- pine_id: PUB;6ANlfsCnYNNX8V6QDAVatLM2uo9ZyHrs
- version: 2.0

## Description

Added TSL in Green and Red
Buy/Sell above Midline(Black)

## Source Code

````pine
//@version=3

strategy(title = "dc", default_qty_type = strategy.fixed, default_qty_value = 20,  overlay = true, commission_type=strategy.commission.cash_per_order,commission_value=30)


testStartYear = input(2018, "Backtest Start Year")
testStartMonth = input(1, "Backtest Start Month")
testStartDay = input(1, "Backtest Start Day")
testPeriodStart = timestamp(testStartYear,testStartMonth,testStartDay,0,0)

testEndYear = input(2018, "Backtest Start Year")
testEndMonth = input(12)
testEndDay = input(31, "Backtest Start Day")
testPeriodEnd = timestamp(testStartYear,testStartMonth,testStartDay,0,0)


testPeriod() =>
    true
    //time >= testPeriodStart  ? true : false

dcPeriod = input(20, "Period")

dcUpper = highest(close, dcPeriod)[1]
dcLower = lowest(close, dcPeriod)[1]
dcAverage = (dcUpper + dcLower) / 2

plot(dcLower, style=line, linewidth=3, color=red, offset=1)
plot(dcUpper, style=line, linewidth=3, color=aqua, offset=1)

plot(dcAverage, color=black, style=line, linewidth=3, title="Mid-Line Average")

strategy.entry("simpleBuy", strategy.long, when=close > dcAverage)
strategy.close("simpleBuy",when=close < dcAverage)
    
strategy.entry("simpleSell", strategy.short,when=close < dcAverage)
strategy.close("simpleSell",when=close > dcAverage)
````

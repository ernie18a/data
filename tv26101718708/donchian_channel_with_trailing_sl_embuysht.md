# Donchian Channel With Trailing SL

- url: https://www.tradingview.com/script/eMBuySHT-Donchian-Channel-With-Trailing-SL/
- type: strategy
- pine_id: PUB;qZRRsPoJMT4nBE8lCrENmySvwE2NxID2
- version: 1.0

## Description

Donchian Channel With Trailing SL

## Source Code

````pine
strategy(title = "dc", default_qty_type = strategy.fixed, default_qty_value = 20,  overlay = true, commission_type=strategy.commission.cash_per_order,commission_value=30)
atrLength = input(title="ATR Length:", type=integer, defval=20, minval=1)

testStartYear = input(2017, "Backtest Start Year")
testStartMonth = input(1, "Backtest Start Month")
testStartDay = input(1, "Backtest Start Day")
testPeriodStart = timestamp(testStartYear,testStartMonth,testStartDay,0,0)

testEndYear = input(2018, "Backtest Start Year")
testEndMonth = input(12)
testEndDay = input(31, "Backtest Start Day")
testPeriodEnd = timestamp(testEndYear,testEndMonth,testEndDay,0,0)


testPeriod() =>
    true
    //time >= testPeriodStart  ? true : false

dcPeriod = input(20, "Period")

dcUpper = highest(close, dcPeriod)[1]
dcLower = lowest(close, dcPeriod)[1]
dcAverage = (dcUpper + dcLower) / 2
atrValue=atr(atrLength)


useTakeProfit   = na
useStopLoss     = na
useTrailStop    = na
useTrailOffset  = na
//@version=1
Buy_stop = lowest(low[1],3) - atr(20)[1] / 3
plot(Buy_stop, color=red, title="buy_stoploss")
Sell_stop = highest(high[1],3) + atr(20)[1] / 3
plot(Sell_stop, color=green, title="sell_stoploss")

plot(dcLower, style=line, linewidth=3, color=red, offset=1)
plot(dcUpper, style=line, linewidth=3, color=aqua, offset=1)

plot(dcAverage, color=black, style=line, linewidth=3, title="Mid-Line Average")

strategy.entry("simpleBuy", strategy.long, when=(close > dcAverage) and cross(close,dcAverage))
strategy.close("simpleBuy",when= ( close< Buy_stop))
    
strategy.entry("simpleSell", strategy.short,when=(close < dcAverage) and cross(close,dcAverage) )
strategy.close("simpleSell",when=( close > Sell_stop))
    
//strategy.exit("Exit simpleBuy", from_entry = "simpleBuy", profit = useTakeProfit, loss = useStopLoss, trail_points = useTrailStop, trail_offset = useTrailOffset)
//strategy.exit("Exit simpleSell", from_entry = "simpleSell", profit = useTakeProfit, loss = useStopLoss, trail_points = useTrailStop, trail_offset = useTrailOffset)
````

# Improved simple RSI Buy/Sell at a level (SL/TP)

- url: https://www.tradingview.com/script/dCUPcQNh-Improved-simple-RSI-Buy-Sell-at-a-level-SL-TP/
- type: strategy
- pine_id: PUB;NLT6JFYVMxgOCvbQ1dgQfIZYa2tF0HiO
- version: 1.0

## Description

Improved Simple Strategy based on RSI, using overbought or oversold levels. 
Backtest: ETHPERP (FTX) - 30m

Set STOP LOSS and GET PROFIT as a percentage (2% and 10% by default).

If strategy.position_size != 0 algorithm convert percentages into points and set stop loss and take profit limit orders.

## Source Code

````pine
// @version=4
// Improved RSI Simple Strategy
// Added Risk Management System: SL & TP
// © Bitduke
// All scripts: https://www.tradingview.com/u/Bitduke/#published-scripts

strategy("Simple RSI Buy/Sell at a level", shorttitle="Simple RSI Strategy (SL/TP)", overlay=false, calc_on_every_tick=true,pyramiding=0, default_qty_type=strategy.cash,default_qty_value=1000, currency=currency.USD, initial_capital=1000,commission_type=strategy.commission.percent, commission_value=0.075)
overbought = input(70, title="overbought value")
oversold = input(30, title="oversold value")

lenght = 14
rsi = rsi(close, lenght)
myrsi = rsi > overbought
myrsi2 = rsi < oversold

barcolor(myrsi ? color.black : na)
barcolor(myrsi2 ? color.blue : na)

// Risk Management Sysyem
convert_percent_to_points(percent) =>
    strategy.position_size != 0 ? round(percent / 100 * strategy.position_avg_price / syminfo.mintick) : float(na)
    
setup_percent(percent) =>
    convert_percent_to_points(percent)

STOP_LOSS = 2
TAKE_PROFIT = 10

plot(rsi)
plot(overbought, color = color.red)
plot(oversold, color = color.green)

//STRATEGY
if (myrsi)
    strategy.entry("Long", strategy.long)
    
if (myrsi2)
    strategy.entry("Short", strategy.short)

strategy.exit("Exit", qty_percent = 100, profit = setup_percent(STOP_LOSS), loss = setup_percent(TAKE_PROFIT))

// === Backtesting Dates === thanks to Trost

testPeriodSwitch = input(true, "Custom Backtesting Dates")
testStartYear = input(2020, "Backtest Start Year")
testStartMonth = input(1, "Backtest Start Month")
testStartDay = input(1, "Backtest Start Day")
testStartHour = input(0, "Backtest Start Hour")
testPeriodStart = timestamp(testStartYear, testStartMonth, testStartDay, testStartHour, 0)
testStopYear = input(2022, "Backtest Stop Year")
testStopMonth = input(1, "Backtest Stop Month")
testStopDay = input(1, "Backtest Stop Day")
testStopHour = input(0, "Backtest Stop Hour")
testPeriodStop = timestamp(testStopYear, testStopMonth, testStopDay, testStopHour, 0)
testPeriod() =>
    time >= testPeriodStart and time <= testPeriodStop ? true : false
testPeriod_1 = testPeriod()
isPeriod = testPeriodSwitch == true ? testPeriod_1 : true
// === /END

if not isPeriod
    strategy.cancel_all()
    strategy.close_all()
````

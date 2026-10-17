# Signal Tester (v1.2)

- url: https://www.tradingview.com/script/YKadF8OO-Signal-Tester-v1-2/
- type: strategy
- pine_id: PUB;3b7292ec4bee4c4b983b7695d22ad597
- version: 2.0

## Description

This is an automation test Strategy, which helps you to get Strategy Alerts quickly on the 1m chart.

This is useful when you want to start automating Strategies but first you want to see if the connection between TradingView and your automation tool works properly.

This Strategy sends LONG Buy/Sell signals every 1 minute so you don't have to wait for a long time to see if your integration with an automation tool works.

[b]How it works:[/b]
[list]
[*] It works on the 1m chart
[*] Every 1 minute it will send a BUY or a SELL signal (alternating between them forever)
[/list]

## Source Code

````pine
//@version=5
strategyTitle = "Signal Tester (v1.3)"
strategy(strategyTitle, overlay=true, calc_on_every_tick=false, initial_capital=100, default_qty_type=strategy.percent_of_equity, default_qty_value=100, commission_type=strategy.commission.percent, commission_value=0.1, slippage=5)

// Date condition inputs
startDate = timestamp(year(timenow), month(timenow), dayofmonth(timenow), hour(timenow), minute(timenow)-3)
// startDate = input.time(title="Date Start", defval=timestamp("11 October 2023 11:00 +0000"), group="Dates")
timeCondition = time >= startDate 

// Execute strategy
longCondition = strategy.position_size <= 0 and timeCondition
if (longCondition)
    strategy.entry(id="long", direction=strategy.long)

closeLongCondition = strategy.position_size > 0
if (closeLongCondition)
    strategy.close(id="long")


messageToShow = ""
if (timeframe.period != "1")
    messageToShow := "Please switch your chart to the 1 minute timeframe before using this test strategy!"
else
    messageToShow := "Now set up the Strategy Alert to send trading signals. Turn off the Alert after your testing is done."

var infoLabel = label.new(x=bar_index + 2, y=close, style=label.style_label_left, size=size.large, color=#ffeecc, textcolor=color.black, text=messageToShow)
label.set_x(infoLabel, bar_index + 2)
label.set_y(infoLabel, close)
````

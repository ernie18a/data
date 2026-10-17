# Momentum Long Strategy

- url: https://www.tradingview.com/script/gEIISPE5-Momentum-Long-Strategy/
- type: strategy
- pine_id: PUB;55f466ca18db49ab80ba0eb8048cac86
- version: 2.0

## Description

This is a momentum indicator strategy that plots 2 lines on the momentum indicator and if both cross above zero a long entry is generated and if both cross below zero a long exit is generated. It also has code to check and make sure the condition is still true when launching the official alert, which helps back testing and live results line up, however be sure to enter commission and slippage into the properties to accurately reflect profits. There's also an optional "percent" option and selecting the MOM1 option in the "MOM Choice" field as it uses a slightly different calculation and may provide better results than the standard momentum calculation. The zero line plotted on the indicator so you can clearly see when lines are crossing above or below zero. Also I'd like to thank @felipecms14 for his open source momentum code. I added back testing date ranges to this so you can easily pull up and see back tested results for a certain date range. I also added a buy and sell message field in the properties so you can launch alerts that will work with automated trading services. Simply enter your buy message and sell message into those fields in the properties and then when you create an alert enter {{strategy.order.alert_message}} into the alert body and it will dynamically pull in your buy and sell messages when it fires alerts.

## Source Code

````pine
//@version=4
strategy("Momentum Long Strategy", overlay = false, precision = 2, initial_capital = 10000, default_qty_value = 10000, default_qty_type = strategy.cash, commission_type = strategy.commission.percent, commission_value = 0, calc_on_every_tick = true)

// There will be no short entries, only exits from long.
strategy.risk.allow_entry_in(strategy.direction.long)

// Calculate start/end date and time condition
startDate  = input(timestamp("2021-01-02T00:00:00"), title = "Start Date", type = input.time)
finishDate = input(timestamp("2021-12-31T00:00:00"), title = "End Date",type = input.time)
 
time_cond  = time >= startDate and time <= finishDate

// Momentum settings

i_len           =       input(defval = 12,      title = "Length",       minval = 1)
i_src           =       input(defval = close,   title = "Source")
i_percent       =       input(defval = true,    title = "Percent?")
i_mom           =       input(defval = "MOM2",  title = "MOM Choice",   options = ["MOM1", "MOM2"])

// Messages for buy and sell
message_buy  = input("{{strategy.order.alert_message}}", title="Buy message")
message_sell = input("{{strategy.order.alert_message}}", title="Sell message")

// Momentum code

momentum(seria, length, percent) =>
	_mom        =       percent ? ( (seria / seria[length]) - 1) * 100 : seria - seria[length]
	_mom

mom0        =       momentum(i_src, i_len, i_percent)
mom1        =       momentum(mom0, 1, i_percent)
mom2        =       momentum(i_src, 1, i_percent)

momX        =       mom1

if i_mom == "MOM2"
    momX    :=     mom2
    
// Strategy Alerts    

if (mom0 > 0 and momX > 0 and time_cond)
    strategy.entry("MomLE", strategy.long, stop = high + syminfo.mintick, comment = "MomLE", alert_message = message_buy)
else
	strategy.cancel("MomLE")
if (mom0 < 0 and momX < 0 and time_cond)
	strategy.entry("MomExit", strategy.short, stop = low - syminfo.mintick, comment = "MomExit", alert_message = message_sell)
else
	strategy.cancel("MomExit")
	
// Plotting

plot(0, color = #5d606b, title = "ZERO")
plot(mom0, color = #00bcd4, title = "MOM")
plot(mom1, color = #00FF00, title = "MOM1", display = display.none)
plot(mom2, color = #00FF00, title = "MOM2")
````

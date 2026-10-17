# Alert(), alertcondition() or strategy alerts?

- url: https://www.tradingview.com/script/WHOZ6UPz-Alert-alertcondition-or-strategy-alerts/
- type: strategy
- pine_id: PUB;73efdff3861d4548803e90095d354302
- version: 1.0

## Description

Variety of possibilities offered by PineScript, especially thanks to recent additions, created some confusion. Especially one question repeats quite often - which method to use to trigger alerts?

I'm posting this to clarify and give some syntax examples. I'll discuss these 3 methods in chronological order, meaning - in the order they were introduced to PineScript.

[b]ALERTCONDITION()[/b] - it is a function call, which can be used only in study-type script. Since years ago, you could create 2 types of a script: strategy and study. First one enables creating a backtest of a strategy. Second was to develop scripts which didn't require backtesting and could trigger alerts. alertcondition() calls in strategy-type scripts were rejected by Pine compiler. On the other hand compiling study-type scripts rejected all strategy...() calls. That created difficulties, because once you had a nice and backtested strategy, you had to rip it off from all strategy...() function calls to convert your script to study-type so you could produce alerts. Maintenance of two versions of each script was necessary and it was painful.

[b]"STRATEGY ALERTS"[/b] were introduced because of alertcondition() pains. To create strategy alert, you need to click "Add alert" button inside Strategy Tester (backtester) and only there. Alerts set-up this way are bound with the backtester - whenever backtester triggers an order, which is visible on the chart, alert is also fired. And you can customize alert message using some placeholders like {{strategy.order.contracts}} or {{ticker}}.

[b]ALERT()[/b] was added last. This is an alerts-triggering function call, which can be run from strategy-type script. Finally it is doable! You can connect it to any event coded in PineScript and generate any alert message you want, thanks to concatenation of strings and wrapping variables into tostring() function.

Out of these three alertcondition() is obviously archaic and probably will be discontinued. There is a chance this makes strategy/study distinction not making sense anymore, so I wouldn't be surprised if "studies" are deprecated at some point.

But what are the differences between "Strategy alerts" and alert()? "Strategy alerts" seem easier to set-up with just a few clicks and probably easier to understand and verify, because they go in sync with the backtester and on-chart trade markers. It is especially important to understand how they work if you're building strategy based on pending orders (stop and limit) - events in your code might trigger placing pending order, but alert will be triggered only (and when) such order is executed.

But "Strategy Alerts" have some limitations - not every variable you'd like to include in alert message is available from PineScript. And maybe you don't need the alert fired when the trade hit a stop-loss or take-profit, because you have already forwarded info about closing conditions in entry alert to your broker/exchange.

Alert() was added to PineScript to fill all these gaps. Is allows concatenating any alert message you want, with any variable you want inside it and you can attach alert() function at any event in your PineScript code. For example - when placing orders, crossing variables, exiting trades, but not explicitly at pending orders execution.

[b]The Verdict[/b]

"Strategy Alerts" might seem a better fit - easier to set-up and verify, flexible and they fire only when a trade really happens, not producing unnecessary mess when each pending order is placed. But these advantages are illusionary, because they don't give you the full-control which is needed when trading with real money. Especially when using pending orders. If an alert is fired when price actually hit a stop-order or limit-order level, and even if you are executing such alert within 1 second thanks to a tool like TradingConnector, you might already be late and you are making entry at a market price. Slippage will play a great role here. You need to send ordering alert when logical conditions are met - then it will be executed at the price you want. Even if you need to cancel all the pending orders which were not executed. Because of that I strongly recommend sticking to [b]ALERT()[/b] when building your alerts system.

Below is an example strategy, showing syntax to manage placing the orders and cancelling them. Yes, this is another spin-off from my [b]TradingView Alerts to MT4 MT5[/b] . As usual, please don't pay attention to backtest results, as this is educational script only. https://www.tradingview.com/script/9MJO3AgE-TradingView-Alerts-to-MT4-MT5-dynamic-variables-NON-REPAINTING/

P.S. For the last time - farewell alertcondition(). You served us well.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Peter_O

//@version=4
strategy(title="TradingView Alerts to MT4 MT5 example with cancelling pending orders", commission_type=strategy.commission.cash_per_order, commission_value=0.00003, overlay=true, default_qty_value=100000, initial_capital=1000)

// This script was created for educational purposes only.
// It is showing how to create pending orders and cancel them
// Together with syntax to send these events through TradingView alerts system
// All the way to brokers for execution

TakeProfitLevel=input(400)

// **** Entries logic **** {
periodK = 13 //input(13, title="K", minval=1)
periodD = 3 //input(3, title="D", minval=1)
smoothK = 4 //input(4, title="Smooth", minval=1)
k = sma(stoch(close, high, low, periodK), smoothK)
d = sma(k, periodD)
// plot(k, title="%K", color=color.blue)
// plot(d, title="%D", color=color.orange)
// h0 = hline(80)
// h1 = hline(20)
// fill(h0, h1, color=color.purple, transp=75)

GoLong=crossover(k,d) and k<80
GoShort=crossunder(k,d) and k>20
// } End of entries logic

// **** Pivot-points and stop-loss logic **** {
piv_high = pivothigh(high,1,1)
piv_low = pivotlow(low,1,1)
var float stoploss_long=low
var float stoploss_short=high

pl=valuewhen(piv_low,piv_low,0)
ph=valuewhen(piv_high,piv_high,0)

if GoLong 
    stoploss_long := low<pl ? low : pl
if GoShort 
    stoploss_short := high>ph ? high : ph
plot(stoploss_long, color=color.lime, title="stoploss_long")
plot(stoploss_short, color=color.red, title="stoploss_short")
// } End of Pivot-points and stop-loss logic

CancelLong=crossunder(low,stoploss_long) and strategy.position_size[1]<=0 and strategy.position_size<=0
CancelShort=crossover(high,stoploss_short) and strategy.position_size[1]>=0 and strategy.position_size>=0
entry_distance=input(10, title="Entry distance for stop orders")

plotshape(CancelLong ? stoploss_long[1]-10*syminfo.mintick : na, location=location.absolute, style=shape.labelup, color=color.gray, textcolor=color.white, text="cancel\nlong", size=size.tiny)
plotshape(CancelShort ? stoploss_short[1]+10*syminfo.mintick : na, location=location.absolute, style=shape.labeldown, color=color.gray, textcolor=color.white, text="cancel\nshort", size=size.tiny)

strategy.entry("Long", strategy.long, when=GoLong, stop=close+entry_distance*syminfo.mintick)
strategy.exit("XLong", from_entry="Long", stop=stoploss_long, profit=TakeProfitLevel)
strategy.cancel("Long", when = CancelLong)
strategy.entry("Short", strategy.short, when=GoShort, stop=close-entry_distance*syminfo.mintick)
strategy.exit("XShort", from_entry="Short", stop=stoploss_short, profit=TakeProfitLevel)
strategy.cancel("Short", when = CancelShort)

if GoLong
    alertsyntax_golong='long offset=' + tostring(entry_distance) + ' slprice=' + tostring(stoploss_long) + ' tp=' + tostring(TakeProfitLevel)
    alert(message=alertsyntax_golong, freq=alert.freq_once_per_bar_close)
if GoShort
    alertsyntax_goshort='short offset=' + tostring(-entry_distance) + ' slprice=' + tostring(stoploss_short) + ' tp=' + tostring(TakeProfitLevel)
    alert(message=alertsyntax_goshort, freq=alert.freq_once_per_bar_close)
if CancelLong
    alertsyntax_cancellong='cancel long'
    alert(message=alertsyntax_cancellong, freq=alert.freq_once_per_bar_close)
if CancelShort
    alertsyntax_cancelshort='cancel short'
    alert(message=alertsyntax_cancelshort, freq=alert.freq_once_per_bar_close)
````

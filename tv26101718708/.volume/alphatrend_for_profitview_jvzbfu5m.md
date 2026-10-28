# AlphaTrend For ProfitView

- url: https://www.tradingview.com/script/jVZbfu5m-AlphaTrend-For-ProfitView/
- type: strategy
- pine_id: PUB;241cea7434e746c98ed73f4ace3f6d47
- version: 2.0

## Description

This strategy is based on the AlphaTrend indicator by [url=https://www.tradingview.com/u/KivancOzbilgic/]KivancOzbilgic[/url] [url=https://www.tradingview.com/v/o50NYLAZ/]https://www.tradingview.com/v/o50NYLAZ/[/url] A full description of this algorithm functionality may be found by clicking the linked image above. 
Changes and/or additions:
[list]
[*]It is now a backtestable strategy
[*]Updated alert trigger logic
[*]Easy integration with ProfitView to use this algorithm for automated trading
[/list]

When you create an alert, and you are using ProfitView, select "[i]alert() function calls only[/i]" as the condition option. If you would rather set your own custom alert message, select "[i]Order fills only[/i]" instead.
There is a selectable setting in the options to trigger alert() function calls immediately, that you may use to see what text it will send.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// author © KivancOzbilgic
// developer © KivancOzbilgic
// pv additions, simplification and strategy conversion @ treigen
//@version=5
strategy('AlphaTrend For ProfitView', overlay=true, calc_on_every_tick=true, process_orders_on_close=true, default_qty_type=strategy.percent_of_equity, default_qty_value=100, commission_type=strategy.commission.percent, commission_value=0.1, initial_capital=1000)
coeff = input.float(1.5, 'Multiplier', step=0.1)
AP = input(15, 'Common Period')
ATR = ta.sma(ta.tr, AP)
novolumedata = input(title='Change calculation (no volume data)?', defval=false)
canshort = input.bool(true, title="Allow shorting")

i_startTime = input.time(defval = timestamp("01 Jan 2014 00:00 +0000"), title = "Backtesting Start Time", inline="timestart", group='Backtesting')
i_endTime = input.time(defval = timestamp("01 Jan 2100 23:59 +0000"), title = "Backtesting End Time", inline="timeend", group='Backtesting')
timeCond = (time > i_startTime) and (time < i_endTime)

pv_ex = input.string('', title='Exchange', tooltip='Leave empty to use the chart ticker instead (Warning: May differ from actual market name in some instances)', group='PV Settings')
pv_sym = input.string('', title='Symbol', tooltip='Leave empty to use the chart ticker instead (Warning: May differ from actual market name in some instances)', group='PV Settings')
pv_acc = input.string("", title="Account", group='PV Settings')
pv_alert_long = input.string("", title="PV Alert Name Longs", group='PV Settings')
pv_alert_short = input.string("", title="PV Alert Name Shorts", group='PV Settings')
pv_alert_test = input.bool(false, title="Test Alerts", tooltip="Will immediately execute the alerts, so you may see what it sends. The first line on these test alerts will be excluded from any real alert triggers" ,group='PV Settings')

upT = low - ATR * coeff
downT = high + ATR * coeff
AlphaTrend = 0.0
AlphaTrend := (novolumedata ? ta.rsi(close, AP) >= 50 : ta.mfi(hlc3, AP) >= 50) ? upT < nz(AlphaTrend[1]) ? nz(AlphaTrend[1]) : upT : downT > nz(AlphaTrend[1]) ? nz(AlphaTrend[1]) : downT


k1 = plot(AlphaTrend, color=color.new(#0022FC, 0), linewidth=3)
k2 = plot(AlphaTrend[2], color=color.new(#FC0400, 0), linewidth=3)

buySignalk = ta.crossover(AlphaTrend, AlphaTrend[2])
sellSignalk = ta.crossunder(AlphaTrend, AlphaTrend[2])

var exsym = ""
if barstate.isfirst
    exsym := pv_ex == "" ? "" : "ex=" + pv_ex + ","
    exsym := pv_sym == "" ? exsym : exsym + "sym=" + pv_sym + ","


if barstate.isconfirmed and timeCond 
    if strategy.position_size <= 0 and buySignalk
        strategy.entry("Long", strategy.long)
        alert(pv_alert_long + "(" + exsym + "acc=" + pv_acc + ")", alert.freq_once_per_bar_close)
    if strategy.position_size >= 0 and sellSignalk
        strategy.entry("Short", strategy.short, when=canshort)
        strategy.close("Long", when=not canshort)
        alert(pv_alert_short + "(" + exsym + "acc=" + pv_acc + ")", alert.freq_once_per_bar_close)


//  Only used for testing/debugging alert messages
if pv_alert_test
    alert("<![Alert Test]!>\n" + pv_alert_long + "(" + exsym + "acc=" + pv_acc + ")", alert.freq_once_per_bar)
    alert("<![Alert Test]!>\n" + pv_alert_short + "(" + exsym + "acc=" + pv_acc + ")", alert.freq_once_per_bar)
````

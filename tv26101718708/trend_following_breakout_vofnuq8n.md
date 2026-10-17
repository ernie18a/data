# Trend Following Breakout

- url: https://www.tradingview.com/script/vOfNuQ8n-Trend-Following-Breakout/
- type: strategy
- pine_id: PUB;74knXxPgQ4NIITCmujPuNDg804TrKNs1
- version: 4.0

## Description

[b]Easy Trend Following Strategy using Highs and Lows breakout of the last X candles to enter and exit trades.[/b]

You can easily change the ENTRY and EXIT value in order to find the best settings.

This strategy seems to be working well for $BTC and $ETH on the 4H and 1D. 

I didn't play with it too much as I am testing script to trade on the 15 minutes chart with margin. This script can't do this successfully but I hope it can be helpful for what you want to achieve.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TrendSurfersSignals

//@version=4
strategy("Trend Surfers - Breakout + Alerts", calc_on_every_tick =false, overlay=true, initial_capital=2000,commission_value=.1,default_qty_type = strategy.percent_of_equity, default_qty_value = 100)


/////////////// INPUT ENTRY EXIT
entry= input(100, "ENTRY H/L")
exit= input(50, "EXIT H/L")

/////////////// Backtest Input
FromYear = input(2015, "Backtest Start Year")
FromMonth = input(1, "Backtest Start Month")
FromDay = input(1, "Backtest Start Day")
ToYear = input(2999, "Backtest End Year")
ToMonth = input(1, "Backtest End Month")
ToDay = input(1, "Backtest End Day")

/////////////// Backtest Setting
start     = timestamp(FromYear, FromMonth, FromDay, 00, 00)  
finish    = timestamp(ToYear, ToMonth, ToDay, 23, 59)       
window()  => time >= start and time <= finish ? true : false 

/////////////// BUY OPEN PLOT
highestpricelong = highest(high,entry)[1]
plot(highestpricelong, color=color.green, linewidth=2)

/////////////// BUY CLOSE PLOT
lowestpricelong = lowest(high,exit)[1]
plot(lowestpricelong, color=color.green, linewidth=2)

/////////////// SHORT OPEN PLOT
lowestpriceshort = lowest(low,entry)[1]
plot(lowestpriceshort, color=color.red, linewidth=2)

/////////////// SHORT CLOSE PLOT
highestpriceshort = highest(low,exit)[1]
plot(highestpriceshort, color=color.red, linewidth=2)

///////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// CONDITION LONG SHORT //////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////

/////////////// SHORT 

entryshort= crossunder(close, lowestpriceshort)
exitshort= crossover(close,highestpriceshort)

/////////////// LONG 

exitlong= crossover(close, lowestpricelong)
entrylong= crossover(close,highestpricelong)

///////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// LONG and SHORT ORDER //////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////

///////////// Alert Message
pair = syminfo.basecurrency + syminfo.currency

entry_long_message = '\nGo Long for ' + pair + 'NOW!' +
                     '\nClose any short position that are open!' +
                     '\n\nFind Trend Surfers on Google' +
                     '\nFor automated premium signals (FREE)'

entry_short_message ='\nGo Short for ' + pair + 'NOW!' +
                     '\nClose any long position that are open!' +
                     '\n\nFind Trend Surfers on Google' +
                     '\nFor automated premium signals (FREE)'

exit_long_message ='\nExit Long for ' + pair + 'NOW!' +
                     '\n\nFind Trend Surfers on Google' +
                     '\nFor automated premium signals (FREE)'

exit_short_message ='\nExit Short for ' + pair + 'NOW!' +
                     '\n\nFind Trend Surfers on Google' +
                     '\nFor automated premium signals (FREE)'

/////////////// LONG 

if (entrylong)
    strategy.entry("LongEntry", strategy.long, alert_message = entry_long_message, when = window())
if (exitlong or entryshort)
    strategy.close("LongEntry", alert_message = exit_long_message, when=window())

/////////////// SHORT 

if (entryshort)
    strategy.entry("short", strategy.short, alert_message = entry_short_message, when = window())
if (exitshort or entrylong)
    strategy.close("short", alert_message = exit_short_message, when=window())
````

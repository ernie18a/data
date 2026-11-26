# Historical Range (Using eStrategy library)

- url: https://www.tradingview.com/script/Qls5uGCg-Historical-Range-Using-eStrategy-library/
- type: indicator
- pine_id: PUB;5b06b30a5e2f4d2ea2a22906fad72981
- version: 2.0

## Description

[b]⬜  The script is intended to cover few things.[/b]

▶ Strategy testing framework based on [url=https://www.tradingview.com/script/41vjd1gn-eStrategy/]eStrategy[/url] library
▶ Using [url=https://www.tradingview.com/script/RSBz7Vx7-historicalrange/]historicalrange[/url] of values for identifying better entry and exits. 

This is also built on top of the Systematic Investment Plan script published [url=https://www.tradingview.com/script/yNkGoJmW-Systematic-Investment-Plan/]here[/url]

[b]⬜  Strategy testing framework[/b]

Strategy testing framework is different from tradingview default strategy testing from few ways to suit the needs of systematic investments.
▶ Supports recurring investment on top of initial investment to emulate adding further funds to the investment bucket on regular basis.
▶ Better calculation of drawdowns based on daily equity rather than drawdown calculated only on close of trade.
▶ Provides better control over how much strategy can reduce and reload

Having said that, this framework is not intended as replacement for tradingview strategy framework. It is not as comprehensive as tradingview strategy framework. But, created to address few specific styles of strategy.
▶ No detailed trade stats on individual trades. But, this can be implemented in future versions
▶ At present only facilitates long positions.
▶ UI features such as plotting trades on chart are not available.
▶ Does not take into consideration of slippage and brokerage - this is not an issue because the framework is not meant for short term trades. It is only made for daily timeframes.
▶ No pyramiding or leverage possible.
And many more...

Framework can be used for similar strategies based on market timing with few small changes.

[b]⬜  Historical Range Strategy [/b]
Concept here is, instead of taking indicators such as oscillators as is, use historical percentile to derive better oversold and overbought conditions. Strategy provides different options to base historical range. This can either be based on
▶ Band percent
▶ Oscillator

Different choices of bands and oscillators are also available to chose. However, have not done extensive testing on all the combinations. 

[b]⬜  Settings [/b]

▶ Initial and recurring investment settings (As confirm inputs)
[url=https://www.tradingview.com/x/enilvlEh/]https://www.tradingview.com/x/enilvlEh/[/url]

▶ Buy and hold and strategy specific settings to be used for stat calculation
[url=https://www.tradingview.com/x/ziuL0LSL/]https://www.tradingview.com/x/ziuL0LSL/[/url]

▶ Band and oscillator parameters
These are straightforward parameters which is used for defining the base of either bands or oscillators.
[url=https://www.tradingview.com/x/dhCw9fdt/]https://www.tradingview.com/x/dhCw9fdt/[/url]

▶ Percentile moving average parameter
Percentile MA is used with Percentile to find entry and exit signals based on crossover and crossunder.
[url=https://www.tradingview.com/x/eTWYJ5im/]https://www.tradingview.com/x/eTWYJ5im/[/url]

Feedbacks and suggestions welcome.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © HeWhoMustNotBeNamed

//   __    __            __       __  __                  __       __                        __      __    __              __      _______             __    __                                          __ 
//  /  |  /  |          /  |  _  /  |/  |                /  \     /  |                      /  |    /  \  /  |            /  |    /       \           /  \  /  |                                        /  |
//  $$ |  $$ |  ______  $$ | / \ $$ |$$ |____    ______  $$  \   /$$ | __    __   _______  _$$ |_   $$  \ $$ |  ______   _$$ |_   $$$$$$$  |  ______  $$  \ $$ |  ______   _____  ____    ______    ____$$ |
//  $$ |__$$ | /      \ $$ |/$  \$$ |$$      \  /      \ $$$  \ /$$$ |/  |  /  | /       |/ $$   |  $$$  \$$ | /      \ / $$   |  $$ |__$$ | /      \ $$$  \$$ | /      \ /     \/    \  /      \  /    $$ |
//  $$    $$ |/$$$$$$  |$$ /$$$  $$ |$$$$$$$  |/$$$$$$  |$$$$  /$$$$ |$$ |  $$ |/$$$$$$$/ $$$$$$/   $$$$  $$ |/$$$$$$  |$$$$$$/   $$    $$< /$$$$$$  |$$$$  $$ | $$$$$$  |$$$$$$ $$$$  |/$$$$$$  |/$$$$$$$ |
//  $$$$$$$$ |$$    $$ |$$ $$/$$ $$ |$$ |  $$ |$$ |  $$ |$$ $$ $$/$$ |$$ |  $$ |$$      \   $$ | __ $$ $$ $$ |$$ |  $$ |  $$ | __ $$$$$$$  |$$    $$ |$$ $$ $$ | /    $$ |$$ | $$ | $$ |$$    $$ |$$ |  $$ |
//  $$ |  $$ |$$$$$$$$/ $$$$/  $$$$ |$$ |  $$ |$$ \__$$ |$$ |$$$/ $$ |$$ \__$$ | $$$$$$  |  $$ |/  |$$ |$$$$ |$$ \__$$ |  $$ |/  |$$ |__$$ |$$$$$$$$/ $$ |$$$$ |/$$$$$$$ |$$ | $$ | $$ |$$$$$$$$/ $$ \__$$ |
//  $$ |  $$ |$$       |$$$/    $$$ |$$ |  $$ |$$    $$/ $$ | $/  $$ |$$    $$/ /     $$/   $$  $$/ $$ | $$$ |$$    $$/   $$  $$/ $$    $$/ $$       |$$ | $$$ |$$    $$ |$$ | $$ | $$ |$$       |$$    $$ |
//  $$/   $$/  $$$$$$$/ $$/      $$/ $$/   $$/  $$$$$$/  $$/      $$/  $$$$$$/  $$$$$$$/     $$$$/  $$/   $$/  $$$$$$/     $$$$/  $$$$$$$/   $$$$$$$/ $$/   $$/  $$$$$$$/ $$/  $$/  $$/  $$$$$$$/  $$$$$$$/ 
//                                                                                                                                                                                                          
//                                                                                                                                                                                                          
//
//@version=5
indicator('Historical Range (Using eStrategy library)', overlay=false)
import HeWhoMustNotBeNamed/historicalrange/1 as hr
import HeWhoMustNotBeNamed/enhanced_ta/10 as eta
import HeWhoMustNotBeNamed/eStrategy/4 as stg
startYear = input.int(2010, maxval=2999, minval=0, title='Start Year', group='Inital Investment', tooltip='Year on which investment is started', confirm=true)
initialDeposit = input.float(10000, "Deposit", minval=0, step=5000, group="Inital Investment", tooltip='Initial one time deposit to start with', confirm=true)
recurringDepositFrequency = input.string("monthly", "Frequency", group="Recurring Investment",  options=["monthly", "weekly"], tooltip="Periodic investment frequency", confirm=true)
recurringDeposit = input.float(1000, "Deposit", step=1000, minval=0, group="Recurring Investment", tooltip="Periodic investment", confirm=true)

buyPrice = input.source(open, "Buy Price", group="Buy and Hold")

strategyInvestPercent = input.float(50, "Regular investiment Percent", group="Strategy", step=10)
reducePercent = input.float(100, "Reduce Percent", group="Strategy", step=10)
reloadPercent = input.float(100, "Reload Percent", group="Strategy", step=10)
buyPriceStrategy = input.source(open, "Buy Price", group="Strategy")
sellPriceStrategy = input.source(open, "Sell Price", group="Strategy")
dividends = nz(request.dividends(syminfo.tickerid, dividends.gross, barmerge.gaps_on, ignore_invalid_symbol=true))
[totalInvestment, buyAndHoldQty, bnhEquity] = stg.sip(startYear, initialDeposit, recurringDepositFrequency, recurringDeposit, buyPrice, dividends)
[bEquityAth, bDrawdown, bMaxDrawdown] = stg.getEquityAthAndDrawdown(bnhEquity)

base = input.string("oscillator", options=["band", "oscillator"], group="Strategy")
buyAdjustment = input.int(15, step=5, minval=0, maxval=50, group="Strategy")
sellAdjustment = input.int(30, step=5, minval=0, maxval =50, group="Strategy")

bandType = input.string("dc", options=["bb", "kc", "dc"], group="Bands")

type = (base == "band"? bandType : base)
useTrueRange = input.bool(true, title="Use True Range (KC)", group="Bands", inline="b")
useAlternateSource = input.bool(false, title="Use Alternate Source (DC)", group="Bands", inline="b")
sticky = input.bool(false, title="Sticky", group="Bands", inline="b")

masource = input.source(close, title="Source", group="Bands")
matype = input.string("ema", title="Moving Average", group="Bands", options=["sma", "ema", "hma", "rma", "wma", "vwma", "swma", "linreg", "median"])
malength = input.int(20, step=10, title="", group="Bands")
multiplier = input.float(10, step=5, title="Multiplier", group="Bands")

oscType = input.string("rsi", title="Oscillator Type", group="Oscillator", options=["cci", "cmo", "roc", "rsi", "stoch", "tsi", "wpr"])
oLength = input.int(9, step=5, title="Length", group="Oscillator")
shortLength = input.int(9, title="Short Length (TSI)", group="Oscillator")
longLength = input.int(26, title="Long Length (TSI)", group="Oscillator")
method = input.string("highlow", title="Dynamic Overvought/Oversold Calculation method", group="Oscillator", options=["highlow", "sma", "ema", "hma", "rma", "wma", "vwma", "swma", "linreg", "median"])
highlowlength = input.int(50, title="Length", group="Oscillator")
useDynamicRange = input.bool(false, title="Dynamic Range", group="Oscillator", inline="b")
osticky = input.bool(false, title="Sticky", group="Oscillator", inline="b")

pmatype = input.string("sma", title="Type", group="Percentile MA", options=["sma", "ema", "hma", "rma", "wma", "vwma", "swma", "linreg", "median"])
pmalength = input.int(22, step=10, title="Length", group="Percentile MA")

[source, index, pArray, percentile, median, max] = switch(type)
    "bb" => hr.bpercentb(masource, matype, malength, multiplier, sticky)
    "kc" => hr.kpercentk(masource, matype, malength, multiplier, useTrueRange, sticky)
    "dc" => hr.dpercentd(malength, useAlternateSource, masource, sticky)
    "oscillator" => hr.oscillator(oscType, oLength, shortLength, longLength, method = method, highlowLength=highlowlength,
                         sticky=osticky, useDynamicRange=useDynamicRange)

total = array.sum(pArray)
var dateStart = str.tostring(year) + '/' + str.tostring(month) + '/' + str.tostring(dayofmonth)
dateEnd = str.tostring(year) + '/' + str.tostring(month) + '/' + str.tostring(dayofmonth)

ma = eta.ma(percentile, pmatype, pmalength)
ma2 = eta.ma(ma, pmatype, pmalength)
longBias = median > 50
shortBias = median < 50

buySignal = percentile < median-buyAdjustment and ta.crossover(percentile, ma)
sellSignal = percentile > median+sellAdjustment and ta.crossunder(percentile, ma)

signal = buySignal? 1 : sellSignal ? -1 : 0

qtyPercent = buySignal? reloadPercent : sellSignal? reducePercent : 0
[_totalInvestment, totalQty, totalCash, totalEquity] = stg.customStrategy(startYear, initialDeposit, recurringDepositFrequency, recurringDeposit, buyPriceStrategy, sellPriceStrategy,
                         strategyInvestPercent, strategyInvestPercent, signal, qtyPercent, dividends)
[sEquityAth, sDrawdown, sMaxDrawdown] = stg.getEquityAthAndDrawdown(totalEquity)
[currentCashPercent, avgCashPercent] = stg.getAverageCashPercent(totalCash, totalEquity)

diffQty = totalQty - totalQty[1]

// plotchar(diffQty>0?totalEquity:na, "Long", location.absolute, text='L')
plotchar(diffQty>0 and signal == 1?totalEquity:na, title="Reload", char='🚀', location=location.absolute, color=color.green)
plotchar(diffQty>0 and signal != 1?totalEquity:na, title="Invest", char='💵', location=location.absolute, color=color.green)
plotchar(diffQty<0?totalEquity:na, title="Reduce", char='💰', location=location.absolute, color=color.red)


plot(totalEquity, "Strategy", color=color.new(color.yellow, 80), style=plot.style_area)
plot(bnhEquity, "Buy and Hold", color=color.new(color.green, 80), style=plot.style_area)
plot(totalInvestment, "Investment", color=color.new(color.purple, 80), style=plot.style_area)
dateRange = syminfo.ticker + ' From ' + str.tostring(startYear)

var stats = table.new(position=position.middle_left, columns=3, rows=8, border_width=1)

table.cell(stats, 0, 0, dateRange, bgcolor=color.navy, text_color=color.white)

table.cell(stats, 2, 0, "Buy and Hold", bgcolor=color.teal, text_color=color.white)
table.cell(stats, 1, 0, "Strategy", bgcolor=color.teal, text_color=color.white)

table.cell(stats, 0, 1, "Equity", bgcolor=color.maroon, text_color=color.white)
table.cell(stats, 0, 2, "Max Equity", bgcolor=color.maroon, text_color=color.white)
table.cell(stats, 0, 3, "Drawdown", bgcolor=color.maroon, text_color=color.white)
table.cell(stats, 0, 4, "Max Drawdown", bgcolor=color.maroon, text_color=color.white)
table.cell(stats, 0, 5, "ROI", bgcolor=color.maroon, text_color=color.white)
table.cell(stats, 0, 6, "Cash Holding(%)", bgcolor=color.maroon, text_color=color.white)
table.cell(stats, 0, 7, "Average Cash Holding(%)", bgcolor=color.maroon, text_color=color.white)

roiBnh = bnhEquity*100/totalInvestment
roiStrategy = totalEquity*100/totalInvestment
table.cell(stats, 2, 1, str.tostring(bnhEquity), bgcolor=color.aqua, text_color=color.black)
table.cell(stats, 2, 2, str.tostring(bEquityAth), bgcolor=color.aqua, text_color=color.black)
table.cell(stats, 2, 3, str.tostring(bDrawdown), bgcolor=color.aqua, text_color=color.black)
table.cell(stats, 2, 4, str.tostring(bMaxDrawdown), bgcolor=color.aqua, text_color=color.black)
table.cell(stats, 2, 5, str.tostring(roiBnh), bgcolor=color.aqua, text_color=color.black)

table.cell(stats, 1, 1, str.tostring(totalEquity), bgcolor=color.aqua, text_color=color.black)
table.cell(stats, 1, 2, str.tostring(sEquityAth), bgcolor=color.aqua, text_color=color.black)
table.cell(stats, 1, 3, str.tostring(sDrawdown), bgcolor=color.aqua, text_color=color.black)
table.cell(stats, 1, 4, str.tostring(sMaxDrawdown), bgcolor=color.aqua, text_color=color.black)
table.cell(stats, 1, 5, str.tostring(roiStrategy), bgcolor=color.aqua, text_color=color.black)
table.cell(stats, 1, 6, str.tostring(currentCashPercent), bgcolor=color.aqua, text_color=color.black)
table.cell(stats, 1, 7, str.tostring(avgCashPercent), bgcolor=color.aqua, text_color=color.black)
````

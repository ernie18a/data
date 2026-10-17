# Backtest any Indicator

- url: https://www.tradingview.com/script/4zMZLPYu-backtest-any-indicator/
- type: indicator
- pine_id: PUB;66d56636013645ebb76bbefd58c3d649
- version: 1.0

## Description

Адаптер для TradingView, который позволяет бэктестить сигналы любого индикатора.

Подключает внешний Buy/Entry-сигнал, открывает Long или Short, считает сделки по TP/SL, комиссии, размеру позиции и фильтрам по времени. Показывает статистику, список сделок на графике и позволяет экспортировать сделки в Pine Log в CSV.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Author: BerlinCode42 2024


// ReadMe:
// You need to know the name of the boolean (or integer) variable of your indicator which hold the buy condition.
// Lets say that this boolean variable is called BUY. If this BUY variable is not plotted on the chart you simply
// add the following code line at the end of your pine script. For boolean (true/false) BUY variables use this:
//
//       plot(BUY ? 1:0,'Your buy condition hold in that variable BUY',display = display.data_window)
//
// And in case your script's BUY variable is an integer or float then use instate the following code line:
//
//       plot(BUY ,'Your buy condition hold in that variable BUY',display = display.data_window)
//
// And probably rename the variable <BUY> into the name of your script's buy/sell/goLong/goShort condition boolean. Save your changed Indicator script.
// In case your buy condition value is already plotted on the chart then you don't need to add the code line above.
// Then add this backtest adapter script to the chart and go to the settings of it. Choose under <Settings -> BUY> your Indicator.

// That script aims to easily backtest any indicator without the need to convert them into a strategy.
// And it's avoid using the TradingView inbuild strategy library.
// The Trade list is scrollable. So even if there are hundreds of trades you can look at their details.
// The time period is changeable by begin- and end date, by weekdays and by opening and closing time of exchanges.

//@version=6
indicator('Backtest any Indicator','BackTest',true)

// Variables
type trade
    int count
    int enterTime
    int exitTime
    float enterPrice
    float exitPrice
    float investDollar
    float profit

var onlyonce = true
var openTrade = trade.new(0,na,na,na,na,0,0)
var closeTrades = array.new<trade>(0)
var tradeRegister = array.new<float>(8,0.0)
var BacktestRegister = array.new<float>(6,0.0)
var buyC = false
var int exportedTradeCount = -1

// Inputs {
var g0 = 'Input Signal of your Indicator'
input_signal = input.source(close,'Buy',inline = 'b',group = g0)
var input_target = input.int(1,'Target',tooltip = 'Choose here your indicators BUY signal. You can find it in this drop-down-menu, mostly one of the below ones. After that set the target value. When your indicators BUY signal reach the value of the target a trade will triggered.',inline = 'b',group = g0)
help = ta.cross(input_signal, input_target)
if input_signal % 1 == 0
    buyC := input_signal == input_target
else
    buyC := help
var enShort = input.bool(true,'go Short XOR go Long', 'Here you can define the trade direction of your indicators trade signal. Is it triggers a short position or a Long position.',group = g0)
var enNew = input.bool(true,'fresh before','Trade only on fresh Signals','fresh',group = g0)
var freshAge = input.int(3,'',1,1000,1,'Hook this if you only wanna trade on fresh Trade Signals. A Trade Signal is concidered fresh as long it is younger then x bars.','fresh',group = g0)

var g4 = 'Trade Settings & List of Trades'
enTP = input.bool(true,'',inline = 'tp', group = g4)
array.set(tradeRegister,6, input.float(2.5, "Take Profit %",0,100,step=0.1,inline = 'tp', group = g4,tooltip='enable/disable TakeProfit. It sells the Position when the gains reach x%.'))
enSL = input.bool(true, "",inline = 'sl', group = g4)
array.set(tradeRegister,7, input.float(0.3, "Stop Loss %",0,100,step=0.1,inline = 'sl', group = g4,tooltip='enable/disable StopLoss.'))
enTradeList = input.bool(true, '',group = g4,inline = 'l'), next = -1*input.int(0,'List of Trades | Scroll',maxval=0,tooltip = 'Press the down arrow to jump through the list of trades.',inline = 'l',group = g4)
enPineLogExport = input.bool(false, 'Export closed trades to Pine Log', group = g4, tooltip = 'Prints all closed trades as CSV to Pine Logs on the last confirmed bar. Open Pine Editor -> More -> Pine Logs.')
pineLogRowsPerMessage = input.int(100, 'Rows per Pine Log message', minval = 10, maxval = 500, step = 10, group = g4, tooltip = 'Large exports are split into multiple Pine Log messages to avoid oversized output.')

var g1 = 'Time & Session Filter'
enStart = input.bool(false,'',inline = 'start',group = g1)
enEnd = input.bool(false,'',inline = 'end',group = g1)
startDate = input.time(timestamp('01 Aug 2023 00:00 +0200'), 'Start Date',inline = 'start',group = g1)
endDate = input.time(timestamp('01 Nov 2024 00:00 +0200'), 'End Date',inline = 'end',group = g1)
enWeekly = input.bool(false,'Week',inline = 'days',group = g1),enMon = input.bool(true,'Mon',inline = 'days',group = g1)?2:9,enTue = input.bool(true,'Tue',inline = 'days',group = g1)?3:9,enWed = input.bool(true,'Wed',inline = 'days',group = g1)?4:9,enThu = input.bool(true,'Thu',inline = 'days',group = g1)?5:9,enFri = input.bool(true,'Fri',inline = 'days',group = g1)?6:9,enSat = input.bool(false,'Sat',inline = 'days',group = g1)?7:9,enSun = input.bool(false,'Sun',inline = 'days',group = g1)?1:9
enDaily = input.bool(false,'',inline = 'time',group = g1)
fromTo = input.string('0805-1530','From To',tooltip = 'Chose here the daily time period when the exchanges are open. Example from 09:00AM to 03:30PM is 0900-1530',inline = 'time',group = g1)
tColor = (enStart or enEnd or enWeekly or enDaily) ? input.color(color.new(color.lime,99),'Trade Time',inline = 'time',group = g1) : na
inTradeTime = ((enStart? (time >= startDate) : true) and (enEnd? (time <= endDate) : true)) and (enWeekly? array.from(enSun,enMon,enTue,enWed,enThu,enFri,enSat).includes(dayofweek) : true) and (enDaily? not na(time(timeframe.period, fromTo)) : true)
bgcolor(inTradeTime?tColor:color.new(color.gray,90))

var g2 = 'Investment Settings'
sC = input.float(1000,'Start Capital $',10,10000000,10,group = g2)
if onlyonce
    array.set(tradeRegister,1, sC)
qty = input.float(5,'Invest per Trade %',0.0,100.0,5.0,group = g2)
fee = input.float(0.075,'Trade fees %',0.0,100.0,step=0.025,group = g2, tooltip = 'At any trade a fee % is taken away. Open a position and closing a position.')
// }

// Functions {
backtesting(price) =>
    if openTrade.profit > 0
        array.set(BacktestRegister,0, array.get(BacktestRegister,0) + price*openTrade.profit*openTrade.investDollar*(100-fee)/10000 )
        array.set(BacktestRegister,2, array.get(BacktestRegister,2) + 1 )
    if openTrade.profit < 0
        array.set(BacktestRegister,1, array.get(BacktestRegister,1) + price*openTrade.profit*openTrade.investDollar*(100-fee)/10000 )
        array.set(BacktestRegister,3, array.get(BacktestRegister,3) + 1 )
    array.set(BacktestRegister,4, array.get(BacktestRegister,4) + openTrade.investDollar*price*(fee)/100 )
    if array.get(BacktestRegister,5) > openTrade.profit
        array.set(BacktestRegister,5, openTrade.profit)

goLongNow(price,now) =>
    _openTrade = trade.new(1,now,na,price,na, array.get(tradeRegister,1) *qty*(100-fee)/10000/price,na)
    array.set(BacktestRegister,4, array.get(BacktestRegister,4) + array.get(tradeRegister,1) *qty*fee/10000 )
    array.set(tradeRegister,0, 1.0)
    array.set(tradeRegister,1, array.get(tradeRegister,1) * (100 - qty) / 100)
    array.set(tradeRegister,2, price * (100+array.get(tradeRegister,6)) / 100)
    array.set(tradeRegister,3, price * (100-array.get(tradeRegister,7)) / 100)
    label.new(bar_index,close,'goLong\n#' + str.tostring(array.size(closeTrades)+1),yloc = yloc.belowbar,color = color.new(color.yellow,80),style = label.style_label_up)
    _openTrade

exitLongNow(price,now) =>
    array.set(tradeRegister,1, array.get(tradeRegister,1)  + openTrade.investDollar*price*(100-fee)/100)
    openTrade.exitPrice := price
    openTrade.exitTime := now
    openTrade.count := (array.size(closeTrades) + 1) * math.round(math.sign(array.get(tradeRegister,0)))
    openTrade.profit := (price / openTrade.enterPrice - 1)*100
    backtesting(openTrade.enterPrice)
    label.new(bar_index,close,'exLong\n#' + str.tostring(array.size(closeTrades)+1) + '\n' + str.tostring(math.round(openTrade.profit,2)) + '%\n' + str.tostring(math.round(array.get(tradeRegister,1),2)) + '$', yloc = yloc.abovebar,color = color.new(color.yellow,80),style = label.style_label_down)
    array.push(closeTrades,openTrade)
    array.set(tradeRegister,0, 0.0)

goShortNow(price,now) =>
    _openTrade = trade.new(-1, now,na,price,na, array.get(tradeRegister,1) *qty*(100-fee)/10000/price,na)
    array.set(BacktestRegister,4, array.get(BacktestRegister,4) + array.get(tradeRegister,1) *qty*fee/10000 )
    array.set(tradeRegister,0, -1.0)
    array.set(tradeRegister,1, array.get(tradeRegister,1) * (100 + qty) / 100)
    array.set(tradeRegister,4, price * (100-array.get(tradeRegister,6)) / 100)
    array.set(tradeRegister,5, price * (100+array.get(tradeRegister,7)) / 100)
    label.new(bar_index,close,'goShort\n#' + str.tostring(array.size(closeTrades)+1),yloc = yloc.abovebar,color = color.new(color.blue,80))
    _openTrade

exitShortNow(price,now) =>
    array.set(tradeRegister,1, array.get(tradeRegister,1) - openTrade.investDollar*price*(100.0-fee)/100)
    openTrade.exitPrice := price
    openTrade.exitTime := now
    openTrade.count := (array.size(closeTrades) + 1) * math.round(math.sign(array.get(tradeRegister,0)))
    openTrade.profit := (openTrade.enterPrice / price - 1)*100
    backtesting(openTrade.enterPrice)
    label.new(bar_index,close,'exShort\n#' + str.tostring(array.size(closeTrades)+1) + '\n' + str.tostring(math.round(openTrade.profit,2)) + '%\n' + str.tostring(math.round(array.get(tradeRegister,1),2)) + '$', yloc = yloc.belowbar,color = color.new(color.blue,80),style = label.style_label_up)
    array.push(closeTrades,openTrade)
    array.set(tradeRegister,0, 0.0)

tostring00(t)=>
    t<10 ? '0' + str.tostring(t) : str.tostring(t)

time2datestring(t) =>
    tostring00(dayofmonth(t)) + '/' + tostring00(month(t)) + '/' + str.tostring(year(t)) + '\n' + tostring00(hour(t)) + ':' + tostring00(minute(t))

time2csvstring(t) =>
    str.tostring(year(t)) + '-' + tostring00(month(t)) + '-' + tostring00(dayofmonth(t)) + ' ' + tostring00(hour(t)) + ':' + tostring00(minute(t))

roundTo(value, decimals) =>
    factor = math.pow(10, decimals)
    math.round(value * factor) / factor

tradeToCsvRow(trade tr) =>
    tradeType = tr.count > 0 ? 'Long' : tr.count < 0 ? 'Short' : 'Error'
    invested = roundTo(tr.investDollar * tr.enterPrice, 2)
    str.tostring(math.abs(tr.count)) + ',' + tradeType + ',' + time2csvstring(tr.enterTime) + ',' + time2csvstring(tr.exitTime) + ',' + str.tostring(roundTo(tr.enterPrice, 2)) + ',' + str.tostring(roundTo(tr.exitPrice, 2)) + ',' + str.tostring(invested) + ',' + str.tostring(roundTo(tr.profit, 2))

exportTradesToPineLog(array<trade> this, int rowsPerMessage) =>
    tradeCount = array.size(this)
    csvHeader = 'No,Type,Enter Date,Exit Date,Buy Price,Sell Price,Invested,Profit %'
    if tradeCount == 0
        log.info(csvHeader)
        0
    else
        csvChunk = csvHeader
        chunkRows = 0
        for row = 0 to tradeCount - 1
            csvChunk += '\n' + tradeToCsvRow(array.get(this, row))
            chunkRows += 1
            isLastRow = row == tradeCount - 1
            if chunkRows >= rowsPerMessage or isLastRow
                log.info(csvChunk)
                csvChunk := csvHeader
                chunkRows := 0
        0

method TradeList(array<trade> this, int posi = 1, int nxt, color bgColor = na, color textColor = color.gray, bool printnan = false ) =>
    tcol = 8, trow = array.size(this)
    var maxrow = 19
    nxt2 = nxt*maxrow < trow ? nxt*maxrow : (nxt*maxrow)%trow
    tbl = table.new(posi < 2 ? position.top_right : posi < 3 ? position.bottom_right : posi < 4 ? position.top_left : position.bottom_left,tcol ,maxrow+2 ,bgColor,na,0,na,0)
    table.cell(tbl, 0, 0,'#'), table.cell(tbl, 1, 0,'Type'),table.cell(tbl, 2, 0,'Enter'), table.cell(tbl, 3, 0,'Exit'), table.cell(tbl, 4, 0,'Buy'), table.cell(tbl, 5, 0,'Sell'), table.cell(tbl, 6, 0,'Invested'), table.cell(tbl, 7, 0,'Profit%')
    lastrow = math.min(nxt2 + maxrow, trow)
    rowt = 0
    if trow>0
        for row = nxt2 + 1 to lastrow
            rowt += 1
            val = array.get(this,row-1)
            rcol = color.new((val.profit>0?color.lime:color.red),92)
            if not na(val) or printnan
                table.cell(tbl, 0, rowt, str.tostring(math.abs(val.count)), text_color = textColor, bgcolor = rcol)
                table.cell(tbl, 1, rowt, (val.count>0?'Long':(val.count<0?'Short':'error')), text_color = textColor, bgcolor = rcol)
                table.cell(tbl, 2, rowt, time2datestring(val.enterTime), text_color = textColor, bgcolor = rcol)
                table.cell(tbl, 3, rowt, time2datestring(val.exitTime), text_color = textColor, bgcolor = rcol)
                table.cell(tbl, 4, rowt, str.tostring(math.round(val.enterPrice,2)) + '$', text_color = textColor, bgcolor = rcol)
                table.cell(tbl, 5, rowt, str.tostring(math.round(val.exitPrice,2)) + '$', text_color = textColor, bgcolor = rcol)
                table.cell(tbl, 6, rowt, str.tostring(math.round(val.investDollar*val.enterPrice)) + '$', text_color = textColor, bgcolor = rcol)
                table.cell(tbl, 7, rowt, str.tostring(math.round(val.profit,2)) + '%', text_color = textColor, bgcolor = rcol)
    if na(openTrade.exitTime) and array.get(tradeRegister,0)!=0
        rowt += 1
        profit = 100*(math.pow(close/openTrade.enterPrice,array.get(tradeRegister,0))-1)
        rcol = color.new((profit>0?color.lime:color.red),92)
        table.cell(tbl, 0, rowt, str.tostring((this.size()+1)), text_color = textColor, bgcolor = rcol)
        table.cell(tbl, 1, rowt, (openTrade.count>0?'open\nLong':'open\nShort'), text_color = textColor, bgcolor = rcol)
        table.cell(tbl, 2, rowt, time2datestring(openTrade.enterTime), text_color = textColor, bgcolor = rcol)
        table.cell(tbl, 3, rowt, '-', text_color = textColor, bgcolor = rcol)
        table.cell(tbl, 4, rowt, str.tostring(math.round(openTrade.enterPrice,2)) + '$', text_color = textColor, bgcolor = rcol)
        table.cell(tbl, 5, rowt, '-', text_color = textColor, bgcolor = rcol)
        table.cell(tbl, 6, rowt, str.tostring(math.round(openTrade.investDollar*openTrade.enterPrice)) + '$', text_color = textColor, bgcolor = rcol)
        table.cell(tbl, 7, rowt, '(' + str.tostring(math.round(profit,2)) + '%)', text_color = textColor, bgcolor = rcol)

method plotResults(int posi) =>
    color bgColor = color.new((array.get(BacktestRegister,0) + array.get(BacktestRegister,1) - array.get(BacktestRegister,4))>=0 ?color.lime:color.red,92)
    tbl2 = table.new(posi < 2 ? position.top_right : posi < 3 ? position.bottom_right : posi < 4 ? position.top_center : posi < 5 ? position.bottom_left : position.bottom_center,array.size(BacktestRegister)+2 ,1 ,bgColor, na,0,na,0)
    tbl3 = table.new(position.middle_center ,3 ,3 ,na, na,0,na,0)
    table.cell(tbl2,1,0,'Profit\n' + str.tostring(math.round(array.get(BacktestRegister,0) + array.get(BacktestRegister,1) - array.get(BacktestRegister,4),2)) + '$' )
    table.cell(tbl2,2,0,'#Trades\n' + str.tostring(array.get(BacktestRegister,2) + array.get(BacktestRegister,3)) )
    table.cell(tbl2,3,0,'Hits\n' + str.tostring(math.round(array.get(BacktestRegister,2)/(array.get(BacktestRegister,2) + array.get(BacktestRegister,3)) * 100,2)) + '%' )
    table.cell(tbl2,4,0,'ProfitFactor\n' + (array.get(BacktestRegister,1)==0 ? 'inf' : str.tostring(-1 * math.round(array.get(BacktestRegister,0)/array.get(BacktestRegister,1),2))) )
    table.cell(tbl2,5,0,'MaxDown\n' + str.tostring(math.round(array.get(BacktestRegister,5),2)) + '%' )
    table.cell(tbl2,6,0,'Fees\n' + str.tostring(math.round(array.get(BacktestRegister,4),2)) + '$' )

signalsAge() =>
    var count = 0
    count += 1
    if input_signal != input_signal[1]
        count := 0
    count

// }

// Long enter {
if inTradeTime and buyC and not enShort and array.get(tradeRegister,0)==0 and (not enNew or signalsAge()<freshAge)
    openTrade := goLongNow(close,time)

if inTradeTime and ((close >= array.get(tradeRegister,2) and enTP) or (close <= array.get(tradeRegister,3) and enSL)) and array.get(tradeRegister,0)>0
    exitLongNow(close,time)
// }

// Short enter
if inTradeTime and buyC and enShort and array.get(tradeRegister,0)==0 and (not enNew or signalsAge()<freshAge)
    openTrade := goShortNow(close,time)

if inTradeTime and ((close <= array.get(tradeRegister,4) and enTP) or (close >= array.get(tradeRegister,5) and enSL)) and array.get(tradeRegister,0)<0
    exitShortNow(close,time)

bgcolor(array.get(tradeRegister,0)>0?color.new(color.lime ,90):array.get(tradeRegister,0)<0?color.new(color.red ,90) : na)
// }

// show Enterprice +- Fee
plot(openTrade.enterPrice * math.pow(1+fee*array.get(tradeRegister,0)/100,2), 'BrakeEvenPrice' , ((array.get(tradeRegister,0)!=0) and (bar_index%3) != 0 ? color.silver : na),style = plot.style_steplinebr, linewidth = 1)

// show SL
plot(array.get(tradeRegister,0)==1? array.get(tradeRegister,3): array.get(tradeRegister,0)==-1 ? array.get(tradeRegister,5) : na, 'StopLoss' , array.get(tradeRegister,0)!=0? color.orange : na,style = plot.style_steplinebr,linewidth = 2)

// show TP
plot(array.get(tradeRegister,0)==1? array.get(tradeRegister,2): array.get(tradeRegister,0)==-1 ? array.get(tradeRegister,4) : na, 'TakeProfit' , array.get(tradeRegister,0)!=0? color.lime : na,style = plot.style_steplinebr,linewidth = 2)

// Show Results {
if enTradeList and barstate.islast
    TradeList(closeTrades,1,next,color.new(color.navy,90),color.gray,true)

if barstate.islast
    plotResults(5)

shouldExportTrades = enPineLogExport and (barstate.islastconfirmedhistory or (barstate.islast and barstate.isconfirmed))
if shouldExportTrades and exportedTradeCount != array.size(closeTrades)
    exportTradesToPineLog(closeTrades, pineLogRowsPerMessage)
    exportedTradeCount := array.size(closeTrades)
// }

// the last code line
onlyonce := false
````

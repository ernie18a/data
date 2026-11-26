# Tick Strategy

- url: https://www.tradingview.com/script/J2VH9JLH-Tick-Strategy/
- type: strategy
- pine_id: PUB;671cf6f4812d4e9baccd9dd13ef348cc
- version: 1.0

## Description

[b]Tick Strategy:[/b]

Questions many pine coders/traders have is, How to enter/exit trade as soon as trade condition is met i.e. do not wait till candle completion to enter/exit the trade. This strategy will help you to understand one of the way to achieve it.

This is an educational strategy to demonstrate, how one can trade based on tick data. This being a strategy based on tick data, it can be tested only on real time candles. This strategy will not take any trades on historical candles and cannot be used for back testing. All the strategy trades taken on real time candles will disappear (repainting) once chart is refreshed and new trades will be entered on real time candles.

The strategy will do nothing during off market hours and will not take any trades.

The strategy has been designed based on rules/inputs below:
1.	Count the ticks from start of a candle till end of candle
2.	Bifurcate ticks as up-ticks and down-ticks. If tick price is above previous tick price the tick is considered as up-tick and vice versa
3.	Count the successive up-ticks and successive down-ticks

Strategy rules:
1.	Track candle type (green or red) continuously on each tick (green candle is when latest tick price > previous tick price)
2.	Take a long trade if work in progress (WIP) candle is green candle and  we get successive up-ticks equal to user input ticks for trade
3.	Take a short trade if work in progress (WIP) candle is red candle and we get successive down-ticks equal to user input ticks for trade
4.	 Exit the trade when we get successive ticks equal to user input ticks in opposite direction
5.	Optionally for trade entry, user can decide whether to calculate successive up-ticks/down-ticks from beginning of candle or successive up-ticks/down-ticks anytime during the candle formation
6.	Optionally for trade exit/square off, user can decide whether to apply exit rules on the entry candle or only from subsequent candle

Strategy setting:
1.	'<Long on WIP Green candle and Short on WIP Red candle>' – This is just to describe when trades are entered. This parameter is not used for any calculation
2.	'No of successive ticks to enter the trade' – User input to decide, number of successive ticks for trade entry
3.	'Count successive ticks for trade only from start of candle' – check this to count successive ticks only from beginning of a candle
4.	'Exit if succussive ticks in opposite direction' - User input to decide, number of successive ticks in opposite direction for exiting the trade
5.	'Apply exit criteria on entry candle' – check to allow exit of trade on the entry candle, if un-checked, trade will not be exited on the entry candle i.e. opposite direction ticks will be counted from subsequent candle

Information below will be displayed continuously on the chart:
1.	Candle no – Candles are counted from start of the trading session. This is current candle being formed on the chart
2.	Candle now – This shows either ‘Green’ or ‘Red’ based on type of candle being formed
3.	Tick count – This is current tick number being processed. Tick number starts from 1 for each new candle
4.	Up-tick count – Number of up-ticks during formation of current candle
5.	Down-tick count – Number of down-ticks during formation of current candle
6.	Successive up-ticks – Current successive up-tick count
7.	Successive down-ticks – Current successive down-tick count
8.	Up-tick volume – Volume associated with up-ticks
9.	Down-tick volume – Volume associated with down-ticks
10.	Up-tick volume % - This is % of volume associated with up-ticks
11.	Total volume – Candle volume till now. (Some times you might observe small difference between total volume and the volume shown by volume indicator. The difference could be because of refresh rate of your screen)
12.	Candle completion % - This shows current candles completion %. This is candle progress from start of candle till close of candle

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Sharad_Gaikwad

//@version=5
strategy("Tick Strategy", overlay = true, calc_on_every_tick = true)
g1 = '============= Strategy based on  tick data ============='
_x = input.bool(title = '<Long on WIP Green candle and Short on WIP Red candle>', defval = 0, group = g1)
entry_on_ticks = input.int(title = 'No of successive ticks to enter the trade', defval = 10, group = g1)
ticks_from_beginnig = input.bool(title = 'Count successive ticks for trade only from start of candle', defval = false, group = g1)
exit_on_ticks = input.int(title = 'Exit if succussive ticks in opposite direction', defval = 10, group = g1)
exit_on_same_candle = input.bool(title = 'Apply exit criteria on entry candle', defval = true, group = g1)
box_color = input.color(title = 'Data box color', defval = color.new(color.black, 75), inline = 'b1', group = g1)
text_color = input.color(title = 'Data box text color', defval = color.new(color.yellow, 0), inline = 'b1', group = g1)

//===================================
tab = table.new(position=position.top_right, columns=7, rows=200,frame_color = color.yellow, frame_width = 1)
msg(int row, int col, string msg_str, clr=color.blue) =>
    table.cell(table_id=tab, column=col, row=row, text=msg_str, text_color=clr)
    
t(val) => str.tostring(val)
//=================================

var tf_msec = timeframe.in_seconds(timeframe.period) * 1000

    
var data_box = box.new(na, na, na, na)

varip tick_no = int(0)
varip prev_tick_price = float(na)
varip prev_tick_volume = float(na)
varip no_of_up_ticks = int(na)
varip no_of_down_ticks = int(na)
varip succ_up_ticks = int(na)
varip succ_down_ticks = int(na)
varip up_tick = bool(na)
varip down_tick = bool(na)
varip up_tick_cnt = int(na)
varip down_tick_cnt = int(na)
varip up_tick_volume = float(na)
varip down_tick_volume = float(na)

var trade_candle_no= int(0)
var candle_cnt = int(na)

candle_cnt := timeframe.change('D') ? 0 : candle_cnt

if(barstate.isnew)
    tick_no := 0
    no_of_up_ticks := 0, no_of_down_ticks := 0
    succ_up_ticks := 0, succ_down_ticks := 0
    up_tick_cnt := 0, down_tick_cnt := 0
    up_tick_volume := 0, down_tick_volume := 0
    prev_tick_volume := 0
    
    
tick_no := tick_no + 1
candle_cnt := candle_cnt + 1
up_tick := close > prev_tick_price
down_tick := close < prev_tick_price

up_tick_volume := up_tick ? up_tick_volume + (volume - prev_tick_volume) : up_tick_volume
down_tick_volume := down_tick ? down_tick_volume + (volume - prev_tick_volume) : down_tick_volume
up_tick_volume_percent = math.round(up_tick_volume / (up_tick_volume + down_tick_volume) * 100, 2)

succ_up_ticks := up_tick ? succ_up_ticks + 1 : 0
succ_down_ticks := down_tick ? succ_down_ticks + 1 : 0
up_tick_cnt := up_tick  ? up_tick_cnt + 1 : up_tick_cnt
down_tick_cnt := down_tick  ? down_tick_cnt + 1 : down_tick_cnt

candle_progress = 100 - math.round(((time_close - timenow) / tf_msec) * 100, 0)
candle_color = close > open ? 'Green' : close < open ? 'Red' : 'None'
box_text = 
       '           Candle no  ==> ' + t(candle_cnt) + '\n' 
     + '           Candle now ==> ' + t(candle_color) + '\n' 
     + '           Tick count ==> ' + t(tick_no) + '\n'
     + '        Up tick count ==> ' + t(up_tick_cnt) + '\n'
     + '      Down tick count ==> ' + t(down_tick_cnt) + '\n'
     + '  Successive up ticks ==> ' + t(succ_up_ticks) + '\n'
     + 'Successive down ticks ==> ' + t(succ_down_ticks)+'\n'
     + '       Up tick volume ==> ' + t(math.round(up_tick_volume,2))+'\n'
     + '     Down tick volume ==> ' + t(math.round(down_tick_volume,2))+'\n'
     + '     Up tick volume % ==> ' + t(up_tick_volume_percent)+ ' %'+'\n'
     + '     Total volume     ==> ' + t(math.round(up_tick_volume + down_tick_volume, 0))+'\n'
     + '    Candle completion ==> ' + t(candle_progress) +' %'

data_box := box.new(left = bar_index + 2, top = high+syminfo.mintick*100, right = bar_index + 20, bottom =  low-syminfo.mintick*100, text = box_text, 
     text_size = size.normal, text_color = text_color, bgcolor = box_color, border_color = box_color, text_halign = text.align_left)
if(not na(data_box[1]))
    box.delete(data_box[1])
//===== Sscenario 1
if(close > open and strategy.position_size == 0 and ((ticks_from_beginnig and tick_no == entry_on_ticks and succ_up_ticks == entry_on_ticks)
     or (not ticks_from_beginnig and succ_up_ticks == entry_on_ticks)))
    trade_candle_no := candle_cnt
    strategy.entry(id = 'Long', direction = strategy.long, comment = 'LE@tick: '+ t(tick_no) +' Candle: '+t(candle_cnt))

if(close < open and strategy.position_size == 0 and  ((ticks_from_beginnig and tick_no == entry_on_ticks and succ_down_ticks == entry_on_ticks)
     or (not ticks_from_beginnig and succ_down_ticks == entry_on_ticks)))
    trade_candle_no := candle_cnt
    strategy.entry(id = 'Short', direction = strategy.short, comment = 'SE@tick: '+ t(tick_no) +' Candle: '+t(candle_cnt))

if((exit_on_same_candle and succ_down_ticks == exit_on_ticks)
     or (not exit_on_same_candle and candle_cnt > trade_candle_no and succ_down_ticks == exit_on_ticks))
    strategy.close(id = 'Long', comment = 'LX@tick: '+ t(tick_no) + ' Candle: '+t(candle_cnt))


if((exit_on_same_candle and succ_up_ticks == exit_on_ticks)
     or (not exit_on_same_candle and candle_cnt > trade_candle_no and succ_up_ticks == exit_on_ticks))
    strategy.close(id = 'Short', comment = 'SX@tick: '+ t(tick_no) + ' Candle: '+t(candle_cnt))



prev_tick_price := close
prev_tick_volume := volume
````

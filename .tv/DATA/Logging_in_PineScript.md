<!-- tradingview-pine-id: PUB;1Ziup2wNqpTYIP2nFyD1fae0HtzEU189 -->
<!-- tradingviewscripts-format: 1 -->
# Logging in PineScript

Source: https://www.tradingview.com/script/YYg37GLJ-Logging-in-Pine-Script/

## Description

I'm building quite a lot of pretty complicated indicators/strategies in Pine Script. Quite often they don't work from the 1 try so I have to debug them heavily. 
In Pine Script there are no fancy debuggers so you have to be creative. You can plot values on your screens, check them in the data window, etc.  
If you want to display some textual information, you can plot some info as labels on the screen. 
It's not the most convenient way, so with the appearance of tables in Pine Script, I decided to implement a custom logger that will allow me to track some useful information about my indicator over time.
Tables work much better for this kind of thing than labels. They're attached to your screen, you can nicely scale them and you can style them much better. 

The idea behind it is very simple. I used few arrays to store the message, bar number, timestamp, and type of the message (you can color messages depend on the type for example). 
There is a function log_msg that just append new messages to these arrays. 
In the end, for the last bar, I create the table and display the last X messages in it. 

In parameters, you can show/hide the entire journal, change the number of messages displayed and choose an offset. With offset, you can basically scroll through the history of messages. 

Currently, I implemented 3 types of messages, and I color messages according to these types:  

[*] Message - gray
[*] Warning - yellow
[*] Error - red

Of course, it's a pretty simple example, you can create a much fancier way of styling your logs. 
What do you think about it? Is it useful for you? What do you use to debug code in Pine Script? 

Disclaimer
Please remember that past performance may not be indicative of future results.
Due to various factors, including changing market conditions, the strategy may no longer perform as good as in historical backtesting.
This post and the script don’t provide any financial advice.

---

## Source Code

````pine
//@version=5
indicator('Logging in PineScript', overlay=true)

////////////
// INPUTS //

// Pivot Points Input
leftBars = input.int(5, group='Pivot Points')
rightBars = input.int(5, group='Pivot Points')

log_show = input.bool(true, title='Show Log?', group='Log')
log_show_msg = input.int(10, title='# of message to show', group='Log')
log_offset = input.int(0, title='# of messages to offset', group='Log', step=1)

//////////////////////////
// 1. Logging Funtions ///

var bar_arr = array.new_int(0)
var time_arr = array.new_string(0)
var msg_arr = array.new_string(0)
var type_arr = array.new_string(0)

log_msg(message, type) =>
    array.push(bar_arr, bar_index)
    array.push(time_arr, str.tostring(year) + '-' + str.tostring(month) + '-' + str.tostring(dayofmonth) + ' ' + str.tostring(hour) + ':' + str.tostring(minute) + ':' + str.tostring(second))
    array.push(msg_arr, message)
    array.push(type_arr, type)

// PIVOT POINTS //

swh = ta.pivothigh(leftBars, rightBars)
swl = ta.pivotlow(leftBars, rightBars)

hprice = 0.0
hprice := not na(swh) ? swh : hprice[1]

lprice = 0.0
lprice := not na(swl) ? swl : lprice[1]

plot(hprice, color=color.new(color.green, 0), linewidth=2)
plot(lprice, color=color.new(color.red, 0), linewidth=2)

// Pivot Points Messages //

if not na(swh)
    log_msg('New Pivot High: ' + str.tostring(hprice), 'message')

if not na(swh) and hprice > hprice[1]
    log_msg('New Pivot Higher High: ' + str.tostring(hprice), 'warning')

if ta.crossover(close, hprice)
    log_msg('Pivot High Cross !!', 'error')

if not na(swl)
    log_msg('New Pivot Low: ' + str.tostring(lprice), 'message')

if not na(swl) and lprice < lprice[1]
    log_msg('New Pivot Lower Low: ' + str.tostring(lprice), 'warning')

if ta.crossunder(close, lprice)
    log_msg('Pivot Low Cross !!', 'error')


///////////////////////////////////
//  2. Create and fill log table //

var log_tbl = table.new(position.bottom_left, 3, log_show_msg + 1, border_width=1)

if barstate.islast and log_show

    table.cell(log_tbl, 0, 0, 'Bar #', bgcolor=color.gray, text_size=size.small)
    table.cell(log_tbl, 1, 0, 'Time', bgcolor=color.gray, text_size=size.small)
    table.cell(log_tbl, 2, 0, 'Message', bgcolor=color.gray, text_size=size.small)

    for i = 1 to log_show_msg by 1
        arr_i = array.size(msg_arr) - log_show_msg + i - 1 - log_offset

        if arr_i < 0
            break

        type = array.get(type_arr, arr_i)

        msg_color = type == 'message' ? #cccccc : type == 'warning' ? #F5AC4E : type == 'error' ? #DD4224 : na

        table.cell(log_tbl, 0, i, str.tostring(array.get(bar_arr, arr_i)), bgcolor=msg_color, text_size=size.small)
        table.cell(log_tbl, 1, i, array.get(time_arr, arr_i), bgcolor=msg_color, text_size=size.small)
        table.cell(log_tbl, 2, i, array.get(msg_arr, arr_i), bgcolor=msg_color, text_size=size.small)
````

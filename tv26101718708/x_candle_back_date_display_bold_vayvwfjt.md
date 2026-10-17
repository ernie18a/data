# X Candle Back Date Display - Bold

- url: https://www.tradingview.com/script/vAYvwFJt-X-Candle-Back-Date-Display-Bold/
- type: indicator
- pine_id: PUB;ba1e8fa2acc944b69d9673c63339e64b
- version: 1.0

## Description

This script will show the date and time of the number of bars back.   Use this script in conjunction with the "Last Touch of Price Level" which tells you how many bars back this price was touched.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mdmiles125
//@version=5
indicator("X Candle Back Date Display - Bold", overlay=true)

barsBack = input.int(50, "Candles Back", minval=1)

var table t = table.new(position.top_right, 1, 1, border_width = 2)

if barstate.islast and bar_index >= barsBack
    txt = str.tostring(month(time[barsBack])) + "/" +
          str.tostring(dayofmonth(time[barsBack])) + "/" +
          str.tostring(year(time[barsBack])) + "  " +
          str.tostring(hour(time[barsBack])) + ":" +
          str.tostring(minute(time[barsBack]))

    table.cell(
         t, 0, 0,
         "BAR " + str.tostring(barsBack) + " BACK\n" + txt,
         text_size = size.large,
         text_color = color.yellow,
         bgcolor = color.black)
````

# ATR by Gerchik

- url: https://www.tradingview.com/script/6F6tGfsO-ATR-by-Gerchik/
- type: indicator
- pine_id: PUB;a312932086774d14928d455cd6b3d935
- version: 4.0

## Description

Average True Range indicator based on Gerchik rules. It counts last 5 candles and calculating average

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sotrosh

//@version=6
indicator("ATR by Gerchik", overlay=false)

// 1. Initialize the table structure once (2 columns, 2 rows)
var table myDashboard = table.new(
     position     = position.top_right, 
     columns      = 3, 
     rows         = 3, 
     bgcolor      = color.black, 
     border_width = 1, 
     border_color = color.gray
 )

calculate_candle(n) => request.security(syminfo.tickerid, "D", high[n] - low[n])

value_0 = calculate_candle(0)
value_1 = calculate_candle(1)
value_2 = calculate_candle(2)
value_3 = calculate_candle(3)
value_4 = calculate_candle(4)
value_5 = calculate_candle(5)


trimmed_avg(float[] values) =>
    float[] sorted = array.copy(values)
    array.sort(sorted)

    float sum = 0.0
    for i = 1 to array.size(sorted) - 2
        sum += array.get(sorted, i)

    sum / (array.size(sorted) - 2)

float[] values = array.from(
    calculate_candle(1),
    calculate_candle(2),
    calculate_candle(3),
    calculate_candle(4),
    calculate_candle(5)
)

value_avg = trimmed_avg(values)
value_avg_rounded = math.round(value_avg * 100) / 100

value_percentage = (value_0*100)/value_avg_rounded
value_percentage_rounded = math.round(value_percentage * 100) / 100

// 2. Populate and update the table ONLY on the most recent bar
if barstate.islast
    // Row 0 (Headers)
    table.cell(myDashboard, column=0, row=0, text="Name", bgcolor=color.black, text_color=color.white)
    table.cell(myDashboard, column=1, row=0, text="Value",  bgcolor=color.black, text_color=color.white)
    table.cell(myDashboard, column=2, row=0, text="%",  bgcolor=color.black, text_color=color.white)
    
    // Row 1 (Data)
    table.cell(myDashboard, column=0, row=1, text="Average Daily ATR (based on last 5 candles)", text_color=color.white)
    table.cell(myDashboard, column=1, row=1, text=str.tostring(value_avg_rounded), text_color=color.white)
    table.cell(myDashboard, column=2, row=1, text="100", text_color=color.white)

    // Row 2 (Data)
    table.cell(myDashboard, column=0, row=2, text="Current Daily ATR", text_color=color.white)
    table.cell(myDashboard, column=1, row=2, text=str.tostring(value_0), text_color=color.white)
    table.cell(myDashboard, column=2, row=2, text=str.tostring(value_percentage_rounded), text_color=color.white)
````

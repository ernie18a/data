# Time Performance

- url: https://www.tradingview.com/script/e1dab7KK-time-performance/
- type: indicator
- pine_id: PUB;d11189e2b24a48aa96be5568d9c984c7
- version: 2.0

## Description

[url=https://www.tradingview.com/x/5VBi2SG9/]https://www.tradingview.com/x/5VBi2SG9/[/url]

The Time Performance Dashboard is an indicator that shows the percentage change in an asset’s price over a selected time period.
Unlike most similar solutions, the calculation is based not on the number of bars, but on a specified time interval. This allows you to quickly assess how the coin’s price has moved over the last few minutes, hours, days, or weeks.
Key Features
•    Select any time period:
o    minutes;
o    hours;
o    days;
o    weeks.
•    Automatic calculation of price change in percent.
•    Displays the price at the beginning of the selected period and the current price.
•	An intuitive sidebar with key metrics.
•    Color-coded indication:
o    green — up;
o    red — down.
How the indicator works
The user specifies the time interval of interest, for example:
•    30 minutes;
•    12 hours;
•    5 days;
•    2 weeks.
The indicator identifies the price that was closest to the start of the selected period, compares it to the current price, and calculates the percentage change.
What it can be used for
•    Analyzing the strength of an asset’s price movement over a specific period.
•    Quickly assessing short-term and medium-term momentum.
•    Comparing the price dynamics of different coins.
•    Determining the current rate of growth or decline without having to manually measure the distance between two points on the chart.
•    Monitoring price movement following news releases or other market events.
The indicator is designed to analyze time intervals rather than a fixed number of candlesticks.

## Source Code

````pine
//@version=6
indicator("Time Performance", overlay=true)


value = input.int(5, "Количество", minval = 1)

unit = input.string(
     "Days",
     "Единица",
     options = ["Minutes","Hours","Days","Weeks"]
)


//--------------------
period_ms =
     unit == "Minutes" ? value * 60 * 1000 :
     unit == "Hours"   ? value * 60 * 60 * 1000 :
     unit == "Days"    ? value * 24 * 60 * 60 * 1000 :
                         value * 7 * 24 * 60 * 60 * 1000

//--------------------

var table t = table.new(position.top_right, 2, 5, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)

if barstate.islast
   
    targetTime = time - period_ms
    
    float oldPrice = na
    int foundTime = na

  
    int max_bars = math.min(5000, bar_index)
    for i = 0 to max_bars
        if time[i] <= targetTime
            oldPrice := close[i]
            foundTime := time[i]
            break 

  
    change = not na(oldPrice) ? (close - oldPrice) / oldPrice * 100 : na

   
    table.clear(t, 0, 0, 1, 4)

    bg = change >= 0 ? color.new(color.green, 30) : color.new(color.red, 30)
    text_color = color.white

    
    table.cell(t, 0, 0, "Период", text_color=text_color)
    table.cell(t, 1, 0, str.tostring(value) + " " + unit, text_color=text_color)

    table.cell(t, 0, 1, "Цена тогда", text_color=text_color)
    table.cell(t, 1, 1, na(oldPrice) ? "-" : str.tostring(oldPrice), text_color=text_color)

    table.cell(t, 0, 2, "Цена сейчас", text_color=text_color)
    table.cell(t, 1, 2, str.tostring(close), text_color=text_color)

    table.cell(t, 0, 3, "Изменение", text_color=text_color)
    table.cell(t, 1, 3, na(change) ? "-" : str.tostring(change, "#.##") + "%", bgcolor=bg, text_color=text_color)

    table.cell(t, 0, 4, "Unix Time", text_color=text_color)
    table.cell(t, 1, 4, na(foundTime) ? "-" : str.tostring(foundTime), text_color=text_color)
````

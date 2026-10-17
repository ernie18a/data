# Bitcoin Parabola Begins

- url: https://www.tradingview.com/script/JwA3v5sI-Bitcoin-Parabola-Begins/
- type: indicator
- pine_id: PUB;2c7262a1d49d42dfa1543bb3a431af45
- version: 1.0

## Description

Orange vertical lines representing Bitcoin beginning a parabolic move

## Source Code

````pine
//@version=5
indicator("Specific Date Markers", overlay = true)

// Function to draw a vertical line at a specific date
drawVerticalLine(targetYear, targetMonth, targetDay) =>
    // Check if the current bar matches the date
    isTargetDate = year(time) == targetYear and month(time) == targetMonth and dayofmonth(time) == targetDay
    
    // If it's a match, create a line that spans the height of the chart
    if isTargetDate
        line.new(bar_index, 0, bar_index, 100, 
             xloc = xloc.bar_index, 
             extend = extend.both, 
             color = color.orange, 
             style = line.style_solid, 
             width = 2)

// Call the function for your specific dates
drawVerticalLine(2013, 1, 14)
drawVerticalLine(2013, 11, 4)
drawVerticalLine(2017, 7, 24)
drawVerticalLine(2020, 11, 16)
````

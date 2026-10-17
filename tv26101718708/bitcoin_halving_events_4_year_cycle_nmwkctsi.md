# Bitcoin Halving Events + 4 year cycle 

- url: https://www.tradingview.com/script/nmwKctSi-Bitcoin-Halving-Events-4-year-cycle/
- type: indicator
- pine_id: PUB;3d0effb76b494a49a2349c61ed6efd61
- version: 1.0

## Description

the yellow lines mark the halving 

the colors showing a 4 year cycle

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//
//
// ©

//@version=5
indicator(title='Bitcoin Halving Events', shorttitle='Bitcoin cycle', overlay=true)
showLabels = input(defval=true, title="Show labels")

isDate(y, m, d) =>
    val = timestamp(y, m, d)
    if val <= time and val > time[1]
        true
    else
        false

// First Halving
if isDate(2012, 11, 28)
    line.new(bar_index, low, bar_index, high, xloc.bar_index, extend.both, color=color.yellow)
    if (showLabels)
        label.new(bar_index, low, text='1st Halving - Nov 28, 2012', style=label.style_label_upper_left, textcolor=color.black, color=color.yellow, textalign=text.align_right)

// Second Halving
if isDate(2016, 7, 9)
    line.new(bar_index, low, bar_index, high, xloc.bar_index, extend.both, color=color.yellow)
    if (showLabels)
        label.new(bar_index, low, text='2nd Halving - Jul 9, 2016', style=label.style_label_upper_left, textcolor=color.black, color=color.yellow, textalign=text.align_right)

// Third Halving
if isDate(2020, 5, 11)
    line.new(bar_index, low, bar_index, high, xloc.bar_index, extend.both, color=color.yellow)
    if (showLabels)
        label.new(bar_index, low, text='3rd Halving - May 11, 2020', style=label.style_label_upper_left, textcolor=color.black, color=color.yellow, textalign=text.align_right)

// Fourth Halving
if isDate(2024, 4, 20)
    line.new(bar_index, low, bar_index, high, xloc.bar_index, extend.both, color=color.yellow)
    if (showLabels)
        label.new(bar_index, low, text='4th Halving - April 20, 2024', style=label.style_label_upper_left, textcolor=color.black, color=color.yellow, textalign=text.align_right)

// Fifth Halving (Estimated)
if isDate(2028, 4, 20)
    line.new(bar_index, low, bar_index, high, xloc.bar_index, extend.both, color=color.yellow)
    if (showLabels)
        label.new(bar_index, low, text='5th Halving - (approx) April 20, 2028', style=label.style_label_upper_left, textcolor=color.black, color=color.yellow, textalign=text.align_right)





// Define the starting year of the 4-year cycle
startYear = 2012  // Change this to match your desired 4-year cycle starting year

// Get the year of the current bar
barYear = year(time)

// Calculate the 4-year cycle index (0, 1, 2, 3)
cycleIndex = (barYear - startYear) % 4

// Define the colors for each year in the cycle
color1 = color.new(color.green, 85)   // Semi-transparent green
color2 = color.new(color.blue, 85)    // Semi-transparent blue
color3 = color.new(color.orange, 85)  // Semi-transparent orange
color4 = color.new(color.red, 85)     // Semi-transparent red

// Assign the color based on the cycle index
bgColor = cycleIndex == 0 ? color1 :
          cycleIndex == 1 ? color2 :
          cycleIndex == 2 ? color3 :
          cycleIndex == 3 ? color4 : na

// Apply the background color to the chart
bgcolor(bgColor)


// Add 200-period white EMA
ema200 = ta.ema(close, 200)
plot(ema200, color=color.white, title='200 EMA')
````

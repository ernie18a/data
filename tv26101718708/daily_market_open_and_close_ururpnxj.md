# Daily Market Open And Close

- url: https://www.tradingview.com/script/uRuRPnXJ-Daily-Market-Open-And-Close/
- type: indicator
- pine_id: PUB;2a24e251c8424f139b7c5d4b79d695c7
- version: 1.0

## Description

This indicator is a very minimalistic way for you to see where the NYSE market opens and closes throughout every trading day.

## Source Code

````pine
//@version=6
indicator("Current Day 9:30 AM & 4:45 PM EST (v6)", overlay=true)

// Input for Timezone
tzInput = input.string("America/New_York", title="Timezone")

// Get the current day of the month according to the chart's current bar
currentDay = dayofmonth(time, tzInput)

// Persistent variables to store line IDs and the day they were drawn
var line line930 = na
var line line1645 = na
var int lastDrawnDay = 0

// IF THE DAY CHANGES: Delete the lines from the PREVIOUS day
if currentDay != lastDrawnDay
    if not na(line930)
        line.delete(line930)
    if not na(line1645)
        line.delete(line1645)

// Draw the lines for the current day if they don't exist yet
if currentDay != lastDrawnDay
    // Get current year and month
    currentYear  = year(time, tzInput)
    currentMonth = month(time, tzInput)

    // Calculate exact timestamps for today's 9:30 AM and 4:45 PM (16:45)
    time930  = timestamp(tzInput, currentYear, currentMonth, currentDay, 9, 30, 0)
    time1645 = timestamp(tzInput, currentYear, currentMonth, currentDay, 16, 45, 0)
    
    // Draw 9:30 AM Line using v6 syntax
    line930 := line.new(x1=time930, y1=low, x2=time930, y2=high, xloc=xloc.bar_time, extend=extend.both, color=color.red, style=line.style_dotted, width=2)
    
    // Draw 4:45 PM Line (projects into the future space) using v6 syntax
    line1645 := line.new(x1=time1645, y1=low, x2=time1645, y2=high, xloc=xloc.bar_time, extend=extend.both, color=color.red, style=line.style_dotted, width=2)
    
    // Lock this day in so the script knows today's lines are officially done and safe
    lastDrawnDay := currentDay
````

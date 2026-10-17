# US Election Cycle GV

- url: https://www.tradingview.com/script/FBKgzAom-US-Election-Cycle-GV/
- type: indicator
- pine_id: PUB;3a7b03cf66e847d88b4ed66d41dfcb42
- version: 1.0

## Description

This indicator visualizes the U.S. Presidential 4-year cycle by dividing the chart into four phases: Election Year, Post-Election Year, Midterm Year, and Pre-Election Year. Each phase is color-coded to highlight potential macro trends and seasonality patterns in the market.

An optional quarterly overlay further breaks each year into Q1–Q4, helping identify historically weaker and stronger periods within the broader cycle. This tool is designed for visual context and does not generate trading signals on its own.

## Source Code

````pine
//@version=6
indicator("US Election Cycle + Quarterly Overlay", overlay = true)

// =======================
// INPUTS
// =======================

// Cycle colors
colElection      = input.color(color.new(color.red, 85), "Election Year")
colPostElection  = input.color(color.new(color.green, 85), "Post-Election")
colMidterm       = input.color(color.new(color.orange, 85), "Midterm")
colPreElection   = input.color(color.new(color.blue, 85), "Pre-Election")

// Quarter settings
showQuarters = input.bool(true, "Show Quarterly Overlay")

q1Color = input.color(color.new(color.yellow, 90), "Q1")
q2Color = input.color(color.new(color.purple, 90), "Q2")
q3Color = input.color(color.new(color.teal, 90), "Q3")
q4Color = input.color(color.new(color.gray, 90), "Q4")

// =======================
// YEAR + CYCLE
// =======================

currentYear = year(time)
isNewYear   = currentYear != currentYear[1]

// Cycle calc (anchor = 2020)
cycleRaw  = (currentYear - 2020) % 4
cycleYear = cycleRaw < 0 ? cycleRaw + 4 : cycleRaw

cycleColor = switch cycleYear
    0 => colElection
    1 => colPostElection
    2 => colMidterm
    3 => colPreElection

cycleName = switch cycleYear
    0 => "Election"
    1 => "Post-Election"
    2 => "Midterm"
    3 => "Pre-Election"

// =======================
// QUARTERS
// =======================

monthVal = month(time)

quarter = switch
    monthVal <= 3  => 1
    monthVal <= 6  => 2
    monthVal <= 9  => 3
    => 4

quarterColor = switch quarter
    1 => q1Color
    2 => q2Color
    3 => q3Color
    4 => q4Color

// =======================
// BACKGROUND LAYERS
// =======================

// Base layer (cycle ALWAYS visible)
bgcolor(cycleColor)

// Overlay layer (quarters)
bgcolor(showQuarters ? quarterColor : na)

// =======================
// LABELS
// =======================

// Year label
if isNewYear
    label.new(
        bar_index,
        high,
        cycleName,
        style = label.style_label_down,
        textcolor = color.white,
        color = cycleColor
    )

// Quarter label
isNewQuarter = quarter != quarter[1]

if showQuarters and isNewQuarter
    label.new(
        bar_index,
        low,
        "Q" + str.tostring(quarter),
        style = label.style_label_up,
        textcolor = color.white,
        color = quarterColor
    )
````

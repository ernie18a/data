# 4H + 1H Opens (Independent Control)

- url: https://www.tradingview.com/script/OEbKlhn4-4H-1H-Opens-Independent-Control/
- type: indicator
- pine_id: PUB;b3e79996ea3743589fd07b5196055aa2
- version: 1.0

## Description

it marks the 1hr and 4 hr opening .helpful in capturing the expansion early.

## Source Code

````pine
//@version=6
indicator("4H + 1H NY Opens (Independent Control)", overlay = true, max_lines_count = 500)

//--------------------------------------------------
// 🔧 USER INPUTS — 4H
//--------------------------------------------------
color lineColor4H = input.color(color.black, "4H Line Color")
int lineWidth4H = input.int(2, "4H Line Width", minval = 1, maxval = 5)

string lineStyleInput4H = input.string(
     "Solid",
     "4H Line Style",
     options = ["Solid", "Dashed", "Dotted"]
)

lineStyle4H =
     lineStyleInput4H == "Solid"  ? line.style_solid :
     lineStyleInput4H == "Dashed" ? line.style_dashed :
                                   line.style_dotted

int maxHistory4H = input.int(100, "Number of 4H Opens", minval = 1, maxval = 500)


//--------------------------------------------------
// 🔧 USER INPUTS — 1H (✅ FIXED DEFAULTS HERE)
//--------------------------------------------------
color lineColor1H = input.color(color.red, "1H Line Color")   // 🔴 default red
int lineWidth1H = input.int(1, "1H Line Width", minval = 1, maxval = 5)

string lineStyleInput1H = input.string(
     "Solid",   // ✅ default solid
     "1H Line Style",
     options = ["Solid", "Dashed", "Dotted"]
)

lineStyle1H =
     lineStyleInput1H == "Solid"  ? line.style_solid :
     lineStyleInput1H == "Dashed" ? line.style_dashed :
                                   line.style_dotted

int maxHistory1H = input.int(100, "Number of 1H Opens", minval = 1, maxval = 500)


//--------------------------------------------------
// 🕒 NEW YORK TIME
//--------------------------------------------------
int nyHour = hour(time, "America/New_York")

bool is4HOpen =
     nyHour == 21 or
     nyHour == 1  or
     nyHour == 5  or
     nyHour == 9  or
     nyHour == 13

bool is1HOpen = ta.change(nyHour) != 0


//--------------------------------------------------
// 📦 STORAGE
//--------------------------------------------------
var array<line> lines4H = array.new_line()
var array<line> lines1H = array.new_line()

var line prevLine4H = na
var line prevLine1H = na


//--------------------------------------------------
// 🚀 NEW 4H OPEN
//--------------------------------------------------
if is4HOpen and not is4HOpen[1]

    float openPrice = open
    int startBar = bar_index

    if not na(prevLine4H)
        line.set_x2(prevLine4H, startBar)

    line newLine4H = line.new(
        startBar, openPrice,
        startBar, openPrice,
        color = lineColor4H,
        width = lineWidth4H,
        style = lineStyle4H
    )

    array.push(lines4H, newLine4H)
    prevLine4H := newLine4H

    if array.size(lines4H) > maxHistory4H
        line.delete(array.shift(lines4H))


//--------------------------------------------------
// 🚀 NEW 1H OPEN
//--------------------------------------------------
if is1HOpen

    float openPrice = open
    int startBar = bar_index

    if not na(prevLine1H)
        line.set_x2(prevLine1H, startBar)

    line newLine1H = line.new(
        startBar, openPrice,
        startBar, openPrice,
        color = lineColor1H,
        width = lineWidth1H,
        style = lineStyle1H
    )

    array.push(lines1H, newLine1H)
    prevLine1H := newLine1H

    if array.size(lines1H) > maxHistory1H
        line.delete(array.shift(lines1H))


//--------------------------------------------------
// 📈 EXTEND CURRENT LINES
//--------------------------------------------------
if not na(prevLine4H)
    line.set_x2(prevLine4H, bar_index)

if not na(prevLine1H)
    line.set_x2(prevLine1H, bar_index)
````

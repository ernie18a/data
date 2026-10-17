# NQ Rounded Levels Full + ATR Display

- url: https://www.tradingview.com/script/w4YIm0Xp-NQ-Rounded-Levels-Full-ATR-Display/
- type: indicator
- pine_id: PUB;61698de0f0704e7aaec91ab3cea30af6
- version: 1.0

## Description

all NQ levels plus large ATR to see, its easy to add lines with 10-20-30-50-60-70-80-90 increments

## Source Code

````pine
//@version=6
indicator("NQ Rounded Levels Full + ATR Display", overlay=true, max_lines_count=500)

//====================================================
// LEVEL DISPLAY INPUTS
//====================================================
rangePoints = input.int(3000, "Draw Range Above/Below Price", minval=500, step=100)

show1000 = input.bool(true, "Show 1000 Levels")
show500  = input.bool(true, "Show 500 Levels")
show100  = input.bool(true, "Show Regular 100 Levels")
show200800 = input.bool(true, "Show 200 / 800 Levels")
show50   = input.bool(true, "Show 50 Levels")
show20406080 = input.bool(true, "Show 20 / 40 / 60 / 80 Levels")
show10307090 = input.bool(true, "Show 10 / 30 / 70 / 90 Levels")

blueColor      = input.color(color.blue, "1000 Level Color")
greenColor     = input.color(color.green, "500 Level Color")
redColor       = input.color(color.red, "Regular 100 Level Color")
purpleColor    = input.color(color.purple, "200 / 800 Level Color")
orangeColor    = input.color(color.orange, "50 Level Color")
lightBlueColor = input.color(color.aqua, "20 / 40 / 60 / 80 Level Color")
yellowColor    = input.color(color.yellow, "10 / 30 / 70 / 90 Level Color")

blueWidth      = input.int(2, "1000 Level Width", minval=1, maxval=5)
greenWidth     = input.int(2, "500 Level Width", minval=1, maxval=5)
redWidth       = input.int(1, "Regular 100 Levels Width", minval=1, maxval=5)
purpleWidth    = input.int(2, "200 / 800 Width", minval=1, maxval=6)
orangeWidth    = input.int(1, "50 Level Width", minval=1, maxval=5)
lightBlueWidth = input.int(1, "20 / 40 / 60 / 80 Width", minval=1, maxval=5)
yellowWidth    = input.int(1, "10 / 30 / 70 / 90 Width", minval=1, maxval=5)

//====================================================
// ATR DISPLAY INPUTS
//====================================================
showATR         = input.bool(true, "Show ATR Number")
atrLength       = input.int(14, "ATR Length", minval=1)
atrDecimals     = input.int(0, "ATR Decimals", minval=0, maxval=2)
atrTextColor    = input.color(color.red, "ATR Text Color")
atrTransparency = input.int(50, "ATR Transparency %", minval=0, maxval=100)

atrPositionOpt = input.string(
     "Bottom Right",
     "ATR Position",
     options=["Bottom Left", "Bottom Right", "Top Left", "Top Right"]
)

atrSizeOpt = input.string(
     "Huge",
     "ATR Text Size",
     options=["Tiny", "Small", "Normal", "Large", "Huge"]
)

//====================================================
// ATR CALCULATION
//====================================================
atrValue = ta.atr(atrLength)

atrFormat = atrDecimals == 0 ? "#" :
     atrDecimals == 1 ? "#.#" :
     "#.##"

atrText = str.tostring(atrValue, atrFormat)

atrPosition = atrPositionOpt == "Bottom Left" ? position.bottom_left :
     atrPositionOpt == "Bottom Right" ? position.bottom_right :
     atrPositionOpt == "Top Left" ? position.top_left :
     position.top_right

atrTextSize = atrSizeOpt == "Tiny" ? size.tiny :
     atrSizeOpt == "Small" ? size.small :
     atrSizeOpt == "Normal" ? size.normal :
     atrSizeOpt == "Large" ? size.large :
     size.huge

//====================================================
// ATR TABLE
//====================================================
var table atrTable = table.new(atrPosition, 1, 1)

if barstate.islast
    table.clear(atrTable, 0, 0)

    if showATR
        table.cell(
             atrTable,
             0,
             0,
             atrText,
             text_color=color.new(atrTextColor, atrTransparency),
             text_size=atrTextSize,
             bgcolor=color.new(color.black, 100)
        )

//====================================================
// STORAGE
//====================================================
var line[] allLines = array.new_line()

//====================================================
// REDRAW LEVELS
//====================================================
if barstate.islast
    if array.size(allLines) > 0
        for i = 0 to array.size(allLines) - 1
            line.delete(array.get(allLines, i))
        array.clear(allLines)

    center = int(math.round(close / 10.0) * 10)

    startLevel = center - rangePoints
    endLevel   = center + rangePoints

    for lvl = startLevel to endLevel by 10
        rem1000 = lvl % 1000
        rem100  = lvl % 100

        isThousand  = rem1000 == 0
        isFiveHund  = rem1000 == 500
        isPurple    = rem1000 == 200 or rem1000 == 800
        isRed       = rem1000 == 100 or rem1000 == 300 or rem1000 == 400 or rem1000 == 600 or rem1000 == 700 or rem1000 == 900
        isOrange    = rem100 == 50
        isLightBlue = rem100 == 20 or rem100 == 40 or rem100 == 60 or rem100 == 80
        isYellow    = rem100 == 10 or rem100 == 30 or rem100 == 70 or rem100 == 90

        allowed =
             (isThousand and show1000) or
             (isFiveHund and show500) or
             (isPurple and show200800) or
             (isRed and show100) or
             (isOrange and show50) or
             (isLightBlue and show20406080) or
             (isYellow and show10307090)

        if allowed
            clr = isThousand  ? blueColor :
                  isFiveHund  ? greenColor :
                  isPurple    ? purpleColor :
                  isRed       ? redColor :
                  isOrange    ? orangeColor :
                  isLightBlue ? lightBlueColor :
                  yellowColor

            wid = isThousand  ? blueWidth :
                  isFiveHund  ? greenWidth :
                  isPurple    ? purpleWidth :
                  isRed       ? redWidth :
                  isOrange    ? orangeWidth :
                  isLightBlue ? lightBlueWidth :
                  yellowWidth

            ln = line.new(
                 x1 = bar_index - 1,
                 y1 = lvl,
                 x2 = bar_index,
                 y2 = lvl,
                 xloc = xloc.bar_index,
                 extend = extend.both,
                 color = clr,
                 width = wid,
                 style = line.style_solid
             )

            array.push(allLines, ln)
````

<!-- tradingview-pine-id: PUB;c2c04ece9cdc4ef29f03fe8d45ef8984 -->
<!-- tradingviewscripts-format: 1 -->
# ATR Watcher

Source: https://www.tradingview.com/script/Otfsyw0D-ATR-Watcher/

## Description

This code is for educational purpose only. It tries to give information on the CURRENT CANDLE'S ATR, LOOK BACK PERIOD'S ATR and the PRVEVIOUS WORKING DAY'S ATR. This data does not give any ADVICE, SUGGESSTIONS OR RECOMMENDATION for BUYING OR SELLING. This indicator is NOT A FOOL PROOF / FULL PROOF INDICATOR and might encounter the error(s) for which the creator / owner will not be resoponsible / liable. This code is free for public at large and the owner is simply doing a service to the user community.

---

## Source Code

````pine
//@version=6
indicator("ATR Watcher", overlay = false)

//====================================================
// INPUTS
//====================================================
atrLength = input.int(14, "ATR Length", minval = 1)

//====================================================
// ATR CALCULATIONS
//====================================================
atrValue = ta.atr(atrLength)

// Average ATR over the lookback period
lookbackAvgATR = ta.sma(atrValue, atrLength)

//====================================================
// PREVIOUS DAY AVERAGE ATR
//====================================================

// Detect beginning of a new day
newDay = ta.change(time("D")) != 0

// Running variables
var float todayATRSum = 0.0
var int   todayBars   = 0

var float prevDayAvgATR = na

// At the first bar of a new day,
// store yesterday's average before resetting
if newDay
    if todayBars > 0
        prevDayAvgATR := todayATRSum / todayBars

    todayATRSum := atrValue
    todayBars   := 1
else
    todayATRSum += atrValue
    todayBars += 1

//====================================================
// OPTIONAL ATR PLOT
//====================================================
plot(atrValue, color=color.aqua, linewidth=2, title="ATR")

//====================================================
// DASHBOARD
//====================================================
var table atrTable = table.new(position.top_right, 2, 4, border_width = 1)

if barstate.islast

    table.cell(atrTable, 0, 0, "ATR WATCHER",
         bgcolor = color.black,
         text_color = color.white)

    table.cell(atrTable, 1, 0, "",
         bgcolor = color.black)

    table.cell(atrTable, 0, 1, "Current ATR",
         bgcolor = color.rgb(30,30,30),
         text_color = color.white)

    table.cell(atrTable, 1, 1,
         str.tostring(atrValue, format.mintick),
         bgcolor = color.rgb(0,80,160),
         text_color = color.white)

    table.cell(atrTable, 0, 2, "Lookback Avg",
         bgcolor = color.rgb(30,30,30),
         text_color = color.white)

    table.cell(atrTable, 1, 2,
         str.tostring(lookbackAvgATR, format.mintick),
         bgcolor = color.rgb(60,60,60),
         text_color = color.white)

    table.cell(atrTable, 0, 3, "Prev Day Avg",
         bgcolor = color.rgb(30,30,30),
         text_color = color.white)

    table.cell(atrTable, 1, 3,
         na(prevDayAvgATR) ? "Calculating..." : str.tostring(prevDayAvgATR, format.mintick),
         bgcolor = color.rgb(0,120,60),
         text_color = color.white)
````

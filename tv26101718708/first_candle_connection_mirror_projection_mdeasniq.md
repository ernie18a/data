# First Candle Connection + Mirror Projection

- url: https://www.tradingview.com/script/MdEaSNiq-First-Candle-Connection-Mirror-Projection/
- type: indicator
- pine_id: PUB;daf4e6b9a14b439eb47bb68e7d07f6d8
- version: 5.0

## Description

First Candle Projection with Mirror Channel (Multi-Day Selector)

📝 Short Description

Projects the relationship between consecutive trading days’ first candles and extends it into a forward-looking mirrored channel for intraday structure analysis.

📖 Full Description (Use this in TradingView)
🔷 Overview

This script builds a geometric projection model using the first candle of each trading day. It connects consecutive days and extends that relationship forward to create a dynamic trend path along with its mirrored counterpart, forming a projected channel.

Unlike traditional indicators, this approach focuses on inter-day structural continuity, allowing traders to anticipate potential price movement zones based on prior session behavior.

⚙️ How It Works
First Candle Detection
Automatically detects the first candle of every trading day (robust to holidays/weekends).
Day-to-Day Connection
Connects:
Previous day first candle High → Current day first candle High
Previous day first candle Low → Current day first candle Low
Forward Projection (74 Bars)
Extends the slope of these connections into the future using dotted lines.
Mirror Projection
Generates a mirror image of projected lines around the current day’s first candle.
This creates a forward-looking price channel.
Day Selector
Choose which pair of days to visualize:
0 → Current vs Previous day
1 → Previous vs Older day
and so on
📊 What You See on Chart
Solid Lines
Represent actual connection between two consecutive days.
Dotted Lines
Represent projected future path (74 bars ahead).
Mirror Lines
Symmetrical projections forming a channel-like structure.
🧠 Interpretation
The projection acts as a directional bias guide.
Mirror lines act as dynamic support/resistance zones.
The structure can resemble:
Trend continuation channels
Expansion/contraction zones
Symmetry-based price movement
🎯 Best Use Cases
Intraday trading (1m / 5m / 15m)
Index instruments (NIFTY, BANKNIFTY, etc.)
Identifying:
Breakouts from projected structure
Mean reversion within mirrored channel
Session-to-session momentum shifts
⚠️ Notes
Works best on intraday timeframes.
Requires at least 2 trading days of data.
Projections are geometric references, not signals.
Holiday gaps are handled automatically. 

This is just for study purpose.

## Source Code

````pine
//@version=6
indicator("First Candle Connection + Mirror Projection", overlay=true, max_lines_count=100)

// ===== INPUT =====
daySelect  = input.int(0, "Show Day (0=Today,1=Prev...)", minval=0)

// ===== NEW DAY =====
newDay = ta.change(time("D")) != 0

// ===== ARRAYS =====
var float[] highArr = array.new_float()
var float[] lowArr  = array.new_float()
var int[]   barArr  = array.new_int()

if newDay
    array.unshift(highArr, high)
    array.unshift(lowArr,  low)
    array.unshift(barArr,  bar_index)

// limit history
if array.size(highArr) > 15
    array.pop(highArr)
    array.pop(lowArr)
    array.pop(barArr)

// ===== LINE HANDLES =====
var line highConn = na
var line lowConn  = na
var line highExt  = na
var line lowExt   = na
var line highMir  = na
var line lowMir   = na

// ===== DELETE OLD =====
if not na(highConn)
    line.delete(highConn)
if not na(lowConn)
    line.delete(lowConn)
if not na(highExt)
    line.delete(highExt)
if not na(lowExt)
    line.delete(lowExt)
if not na(highMir)
    line.delete(highMir)
if not na(lowMir)
    line.delete(lowMir)

// ===== DRAW =====
if array.size(highArr) > daySelect + 1

    h1 = array.get(highArr, daySelect + 1)
    l1 = array.get(lowArr,  daySelect + 1)
    b1 = array.get(barArr,  daySelect + 1)

    h2 = array.get(highArr, daySelect)
    l2 = array.get(lowArr,  daySelect)
    b2 = array.get(barArr,  daySelect)

    // ===== SLOPE =====
    barsDiff = math.max(b2 - b1, 1)
    slopeH = (h2 - h1) / barsDiff
    slopeL = (l2 - l1) / barsDiff

    // ===== CURRENT POSITION =====
    lastBar = bar_index
    barsForward = lastBar - b2

    // ===== CONNECTION =====
    highConn := line.new(b1, h1, b2, h2, color=color.green, width=2)
    lowConn  := line.new(b1, l1, b2, l2, color=color.red, width=2)

    // ===== EXTENSION (TO CURRENT BAR) =====
    highExt := line.new(
        b2, h2,
        lastBar, h2 + slopeH * barsForward,
        color=color.green, width=2, style=line.style_dotted)

    lowExt := line.new(
        b2, l2,
        lastBar, l2 + slopeL * barsForward,
        color=color.red, width=2, style=line.style_dotted)

    // ===== MIRROR =====
    highMir := line.new(
        b2, h2,
        lastBar, h2 - slopeH * barsForward,
        color=color.new(color.green, 50), width=2, style=line.style_dotted)

    lowMir := line.new(
        b2, l2,
        lastBar, l2 - slopeL * barsForward,
        color=color.new(color.red, 50), width=2, style=line.style_dotted)
        
    



// Date candle 


// === GET DATE NUMBER ===
dateNum = dayofmonth

// === NEW DAY DETECTION ===
isNewDay = ta.change(time("D"))!=0

// === INTRADAY COUNTER ===
var int count = 0
if isNewDay
    count := 1
else
    count += 1

// === STORE VALUES ===
var float dHigh = na
var float dLow  = na

// === OBJECT HANDLES ===
var line highLine = na
var line lowLine  = na
var label dLabel  = na

// === RESET ON NEW DAY ===
if isNewDay
    dHigh := na
    dLow  := na
    line.delete(highLine)
    line.delete(lowLine)
    label.delete(dLabel)

// === CAPTURE DATE CANDLE ===
if count == dateNum
    dHigh := high
    dLow  := low

    // Create lines starting from this candle
    highLine := line.new(bar_index, dHigh, bar_index, dHigh, color=color.rgb(76, 175, 79, 65), width=2)
    lowLine  := line.new(bar_index, dLow,  bar_index, dLow,  color=color.rgb(255, 82, 82, 63),   width=2)
    linefill.new(highLine,lowLine,color=color.black)
    // Create label showing candle number
    dLabel := label.new(
        bar_index, high,
        text = "C #" + str.tostring(count),
        style = label.style_label_down,
        color = color.yellow,
        textcolor = color.rgb(7, 41, 134),
        size = size.small
    )

// === EXTEND LINES TILL DAY END ===
if not na(dHigh)
    line.set_xy2(highLine, bar_index, dHigh)
    line.set_xy2(lowLine,  bar_index, dLow)
````

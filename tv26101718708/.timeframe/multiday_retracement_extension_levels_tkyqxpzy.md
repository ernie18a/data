# Multiday Retracement & extension levels 

- url: https://www.tradingview.com/script/TkYQxPZY-Multiday-Retracement-extension-levels/
- type: indicator
- pine_id: PUB;4c0636d26d084a03acb8398af821ec6c
- version: 3.0

## Description

This indicator is designed to help traders identify key retracement and extension levels based on a combined price range from multiple previous trading days. Instead of relying on a single day's high and low, the script allows users to combine the ranges of up to 10 previous days, creating a broader market structure that can be useful for identifying support, resistance, breakout targets, and extension zones.

[b] Features[/b]

• Combines the high-low range of multiple previous trading days (1–10 days selectable)

• Optional Gap-Adjusted Range calculation that incorporates significant price gaps into the reference range

• Displays retracement and extension levels from -200% to +300%

• Customizable colors for:

     0% and 100% boundary levels
     Internal range levels (0% to 100%)
     External extension zones (below 0% and above 100%)

• Customizable line styles, line widths, label sizes, and label offsets

• Automatic percentage relabeling when price moves beyond the 100% range boundary

• Optional Gap Filling Candle Display for improved visual continuity of price action

[b]How It Works[/b]

The script calculates the highest high and lowest low across the selected number of previous trading days. This combined range becomes the basis for all retracement and extension levels.

When Gap Adjustment is enabled, the indicator attempts to include significant overnight or inter-session gaps within the reference range, helping traders account for price movement that may not be fully represented by traditional high-low calculations.

The resulting levels can be used for:

• Identifying potential support and resistance zones

• Measuring retracements within a multi-day trading range

• Projecting extension targets after breakouts

• Evaluating market structure across several trading sessions

[b] Gap Filling Candles[/b]

An optional gap-filling candle mode is included. When enabled, candle opens can be adjusted to the previous close, visually removing gaps and allowing traders to analyze continuous price movement more easily.

[b]Acknowledgements[/b]

Special thanks to author **Echepata** for providing inspiration and reference ideas related to the gap-filling candle implementation used in this script. Their work helped contribute to the development of the gap visualization component included here.

[b] Notes[/b]

This indicator is intended as a market structure and reference tool. Retracement and extension levels should be used alongside price action, volume analysis, and a trader's existing methodology rather than as standalone trading signals.

## Source Code

````pine
//@version=6
indicator("Multiday Retracement & Extension levels  ", overlay=true)

// =====================================================
// INPUTS
// =====================================================

daysToUse = input.int(2, "Number Of Days To Combine", minval=1, maxval=10)

enableGapRange = input.bool(false, "Gaps included Adjustment Range")

showTomorrowLevels = input.bool(false, "Tomorrow Levels")


// =====================================================
// COLORS (UPDATED ONLY THIS PART)
// =====================================================

boundaryColor = input.color(color.rgb(119, 118, 113), "0% & 100% Level Color")
rangeColor     = input.color(color.rgb(44, 136, 46), "between 0% to 100% levels")
outerZoneColor = input.color(color.rgb(24, 51, 202), "Below 0% & above 100% levels")

lineStyle = input.string("Solid", "Line Style", options=["Solid", "Dotted", "Dashed"])
lineWidth = input.int(1, "Line Width", minval=1, maxval=5)

labelOffset = input.int(25, "Label Horizontal Offset", minval=0)
labelTextSize = input.string("Normal", "Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])


// =====================================================
// STYLE MAP
// =====================================================

labelSizeConst = switch labelTextSize
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge

lineStyleConst = switch lineStyle
    "Solid"  => line.style_solid
    "Dotted" => line.style_dotted
    "Dashed" => line.style_dashed



// =====================================================
// SAFE DAILY DATA
// =====================================================

dHigh(x) => request.security(syminfo.tickerid, "D", high[x], lookahead=barmerge.lookahead_off)
dLow(x)  => request.security(syminfo.tickerid, "D", low[x],  lookahead=barmerge.lookahead_off)
dClose(x) => request.security(syminfo.tickerid, "D", close[x], lookahead=barmerge.lookahead_off)

todayHigh  = dHigh(0)
todayLow   = dLow(0)

yestHigh   = dHigh(1)
yestLow    = dLow(1)

day2High   = dHigh(2)
day2Low    = dLow(2)
day2Close  = dClose(2)

// =====================================================
// PRELOAD DAYS
// =====================================================

d1h = dHigh(1)
d2h = dHigh(2)
d3h = dHigh(3)
d4h = dHigh(4)
d5h = dHigh(5)
d6h = dHigh(6)
d7h = dHigh(7)
d8h = dHigh(8)
d9h = dHigh(9)
d10h = dHigh(10)

d1l = dLow(1)
d2l = dLow(2)
d3l = dLow(3)
d4l = dLow(4)
d5l = dLow(5)
d6l = dLow(6)
d7l = dLow(7)
d8l = dLow(8)
d9l = dLow(9)
d10l = dLow(10)

// =====================================================
// MULTI-DAY RANGE LOGIC
// =====================================================

float rangeHigh = d1h
float rangeLow  = d1l

if daysToUse >= 2
    rangeHigh := math.max(rangeHigh, d2h)
    rangeLow  := math.min(rangeLow, d2l)

if daysToUse >= 3
    rangeHigh := math.max(rangeHigh, d3h)
    rangeLow  := math.min(rangeLow, d3l)

if daysToUse >= 4
    rangeHigh := math.max(rangeHigh, d4h)
    rangeLow  := math.min(rangeLow, d4l)

if daysToUse >= 5
    rangeHigh := math.max(rangeHigh, d5h)
    rangeLow  := math.min(rangeLow, d5l)

if daysToUse >= 6
    rangeHigh := math.max(rangeHigh, d6h)
    rangeLow  := math.min(rangeLow, d6l)

if daysToUse >= 7
    rangeHigh := math.max(rangeHigh, d7h)
    rangeLow  := math.min(rangeLow, d7l)

if daysToUse >= 8
    rangeHigh := math.max(rangeHigh, d8h)
    rangeLow  := math.min(rangeLow, d8l)

if daysToUse >= 9
    rangeHigh := math.max(rangeHigh, d9h)
    rangeLow  := math.min(rangeLow, d9l)

if daysToUse >= 10
    rangeHigh := math.max(rangeHigh, d10h)
    rangeLow  := math.min(rangeLow, d10l)

if showTomorrowLevels

    rangeHigh := math.max(todayHigh, yestHigh)
    rangeLow  := math.min(todayLow, yestLow)

// =====================================================
// GAP ADJUST RANGE
// =====================================================

if enableGapRange

    oldestHigh = switch daysToUse
        1 => d1h
        2 => d2h
        3 => d3h
        4 => d4h
        5 => d5h
        6 => d6h
        7 => d7h
        8 => d8h
        9 => d9h
        => d10h

    oldestLow = switch daysToUse
        1 => d1l
        2 => d2l
        3 => d3l
        4 => d4l
        5 => d5l
        6 => d6l
        7 => d7l
        8 => d8l
        9 => d9l
        => d10l

    prevHigh = switch daysToUse
        1 => d2h
        2 => d3h
        3 => d4h
        4 => d5h
        5 => d6h
        6 => d7h
        7 => d8h
        8 => d9h
        9 => d10h
        => na

    prevLow = switch daysToUse
        1 => d2l
        2 => d3l
        3 => d4l
        4 => d5l
        5 => d6l
        6 => d7l
        7 => d8l
        8 => d9l
        9 => d10l
        => na

    prevClose = switch daysToUse
        1 => dClose(2)
        2 => dClose(3)
        3 => dClose(4)
        4 => dClose(5)
        5 => dClose(6)
        6 => dClose(7)
        7 => dClose(8)
        8 => dClose(9)
        9 => dClose(10)
        => na

    // -------------------------------------------------
    // GAP UP
    // -------------------------------------------------
    if not na(prevHigh) and oldestLow > prevHigh

        nearestGapPoint =
             math.abs(oldestLow - prevHigh) <= math.abs(oldestLow - prevClose)
             ? prevHigh
             : prevClose

        rangeLow := math.min(rangeLow, nearestGapPoint)

    // -------------------------------------------------
    // GAP DOWN
    // -------------------------------------------------
    if not na(prevLow) and oldestHigh < prevLow

        nearestGapPoint =
             math.abs(prevLow - oldestHigh) <= math.abs(prevClose - oldestHigh)
             ? prevLow
             : prevClose

        rangeHigh := math.max(rangeHigh, nearestGapPoint)


// =====================================================
// TOMORROW LEVELS
// =====================================================

if showTomorrowLevels

    rangeHigh := math.max(todayHigh, yestHigh)
    rangeLow  := math.min(todayLow, yestLow)

    if enableGapRange

        // Gap Up between Yesterday and Day-2
        if yestLow > day2High

            nearestGapPoint =
                 math.abs(yestLow - day2High) <= math.abs(yestLow - day2Close)
                 ? day2High
                 : day2Close

            rangeLow := math.min(rangeLow, nearestGapPoint)

        // Gap Down between Yesterday and Day-2
        if yestHigh < day2Low

            nearestGapPoint =
                 math.abs(day2Low - yestHigh) <= math.abs(day2Close - yestHigh)
                 ? day2Low
                 : day2Close

            rangeHigh := math.max(rangeHigh, nearestGapPoint)
// =====================================================
// FIB LEVELS
// =====================================================

var float[] fibLevels = array.new_float()

if array.size(fibLevels) == 0
    array.push(fibLevels, -2)
    array.push(fibLevels, -1.9)
    array.push(fibLevels, -1.8)
    array.push(fibLevels, -1.7)
    array.push(fibLevels, -1.6)
    array.push(fibLevels, -1.5)
    array.push(fibLevels, -1.4)
    array.push(fibLevels, -1.3)
    array.push(fibLevels, -1.2)
    array.push(fibLevels, -1.1)
    array.push(fibLevels, -1)
    array.push(fibLevels, -0.9)
    array.push(fibLevels, -0.8)
    array.push(fibLevels, -0.7)
    array.push(fibLevels, -0.6)
    array.push(fibLevels, -0.5)
    array.push(fibLevels, -0.4)
    array.push(fibLevels, -0.3)
    array.push(fibLevels, -0.2)
    array.push(fibLevels, -0.1)
    array.push(fibLevels, 0)
    array.push(fibLevels, 0.1)
    array.push(fibLevels, 0.2)
    array.push(fibLevels, 0.3)
    array.push(fibLevels, 0.4)
    array.push(fibLevels, 0.5)
    array.push(fibLevels, 0.6)
    array.push(fibLevels, 0.7)
    array.push(fibLevels, 0.8)
    array.push(fibLevels, 0.9)
    array.push(fibLevels, 1)
    array.push(fibLevels, 1.1)
    array.push(fibLevels, 1.2)
    array.push(fibLevels, 1.3)
    array.push(fibLevels, 1.4)
    array.push(fibLevels, 1.5)
    array.push(fibLevels, 1.6)
    array.push(fibLevels, 1.7)
    array.push(fibLevels, 1.8)
    array.push(fibLevels, 1.9)
    array.push(fibLevels, 2)
    array.push(fibLevels, 2.1)
    array.push(fibLevels, 2.2)
    array.push(fibLevels, 2.3)
    array.push(fibLevels, 2.4)
    array.push(fibLevels, 2.5)
    array.push(fibLevels, 2.6)
    array.push(fibLevels, 2.7)
    array.push(fibLevels, 2.8)
    array.push(fibLevels, 2.9)
    array.push(fibLevels, 3)



// =====================================================
// OBJECT STORAGE
// =====================================================

var line[] fibLines = array.new_line()
var label[] fibLabels = array.new_label()
// =====================================================
// COLOR ENGINE (ONLY CHANGE HERE)
// =====================================================

f_color(level) =>
    level == 0 or level == 1 ? boundaryColor : level < 0 or level > 1 ? outerZoneColor : rangeColor


// =====================================================
// BREAKOUT DETECTION
// =====================================================

breakAbove100 = high > rangeHigh


// =====================================================
// DRAW ENGINE
// =====================================================

if barstate.islast

    if array.size(fibLines) > 0
        for i = 0 to array.size(fibLines) - 1
            line.delete(array.get(fibLines, i))
    array.clear(fibLines)

    if array.size(fibLabels) > 0
        for i = 0 to array.size(fibLabels) - 1
            label.delete(array.get(fibLabels, i))
    array.clear(fibLabels)

    for i = 0 to array.size(fibLevels) - 1

        level = array.get(fibLevels, i)

        price = rangeLow + (rangeHigh - rangeLow) * level
        col = f_color(level)

        ln = line.new(
             bar_index,
             price,
             bar_index + 1,
             price,
             color=col,
             width=lineWidth,
             style=lineStyleConst,
             extend=extend.both)

        array.push(fibLines, ln)

        // ================================
        // THIS IS THE FLIP LOGIC
        // ================================

        displayPercent = breakAbove100 ? (level - 1.0) * 100 : level * 100

        lb = label.new(
             bar_index + labelOffset,
             price,
             text=str.tostring(displayPercent, "#.##") + "%",
             style=label.style_label_center,
             textcolor=col,
             color=na,
             size=labelSizeConst)

        array.push(fibLabels, lb)


// Gap filling program
group_gap = 'Candles Gap detection & Filling '

enableGapFilling = input(false, title = 'Enable Gap Filling', group = group_gap)
applyToDayOpenOnly = input(false, title = 'Apply to day open only', group = group_gap)


myOpen = open
myClose = close
myHigh = high
myLow = low

isNewDay = ta.change(time('D'))

if enableGapFilling
    if not applyToDayOpenOnly or bool(isNewDay)
        myOpen := close[1]
        myClose := close
        myHigh := math.max(high, close[1])
        myLow := math.min(low, close[1])
        myLow

candleColor = myOpen <= myClose ? color.teal : color.red

plotcandle(myOpen, myHigh, myLow, myClose, color = candleColor, bordercolor = candleColor, wickcolor = candleColor)


// === Gap Filling Candles ===

showHTFCandles = input.bool(true, "Show HTF Candles", group="HTF Candles")

tf = input.timeframe("D", "timeFrame", group = "HTF Candles")

g2  = input.color(color.rgb(8, 160, 145), title = "Green", group = "HTF Candles")

r2  = input.color(color.rgb(194, 62, 62), title = "Red",   group = "HTF Candles")

enableGapFilling1 = input(true, title='Enable Gap Filling', group="HTF Candles")

boxOffset     = input.int(-10, "Candles Right/Left move", minval=-100, maxval=100, group="HTF Candles")

candleCount   = input.int(5, "Candle Count", minval=1, maxval=7, group="HTF Candles")

candleSpacing = input.int(4, "HTF Candle Spacing", minval=3, maxval=10, group="HTF Candles")

// --- Gap Filling Logic ---

myOpen1  = open
myClose1 = close
myHigh1  = high
myLow1   = low

if enableGapFilling1
    myOpen1  := close[1]
    myClose1 := close
    myHigh1  := math.max(high, close[1])
    myLow1   := math.min(low, close[1])

pos0 = 64

[ho, hh, hl, hc] = request.security(syminfo.tickerid, tf, [myOpen1, myHigh1, myLow1, myClose1])

if showHTFCandles and candleCount >= 1
    nh = box.new(bar_index + pos0 + boxOffset, hh, bar_index + pos0 + boxOffset, hl,
         border_color = ho > hc ? r2 : g2,
         bgcolor      = ho > hc ? r2 : g2)
    box.delete(nh[1])

    vh = box.new(bar_index + pos0 - 1 + boxOffset, ho, bar_index + pos0 + 1 + boxOffset, hc,
         border_color = ho > hc ? r2 : g2,
         bgcolor      = ho > hc ? r2 : g2)
    box.delete(vh[1])

pos1 = 64 - candleSpacing

[ho1, hh1, hl1, hc1] = request.security(syminfo.tickerid, tf, [myOpen1[1], myHigh1[1], myLow1[1], myClose1[1]])

if showHTFCandles and candleCount >= 2
    nh1 = box.new(bar_index + pos1 + boxOffset, hh1, bar_index + pos1 + boxOffset, hl1,
          border_color = ho1 > hc1 ? r2 : g2,
          bgcolor      = ho1 > hc1 ? r2 : g2)
    box.delete(nh1[1])

    vh1 = box.new(bar_index + pos1 - 1 + boxOffset, ho1, bar_index + pos1 + 1 + boxOffset, hc1,
          border_color = ho1 > hc1 ? r2 : g2,
          bgcolor      = ho1 > hc1 ? r2 : g2)
    box.delete(vh1[1])

pos2 = 64 - candleSpacing * 2

[ho2, hh2, hl2, hc2] = request.security(syminfo.tickerid, tf, [myOpen1[2], myHigh1[2], myLow1[2], myClose1[2]])

if showHTFCandles and candleCount >= 3
    nh2 = box.new(bar_index + pos2 + boxOffset, hh2, bar_index + pos2 + boxOffset, hl2,
          border_color = ho2 > hc2 ? r2 : g2,
          bgcolor      = ho2 > hc2 ? r2 : g2)
    box.delete(nh2[1])

    vh2 = box.new(bar_index + pos2 - 1 + boxOffset, ho2, bar_index + pos2 + 1 + boxOffset, hc2,
          border_color = ho2 > hc2 ? r2 : g2,
          bgcolor      = ho2 > hc2 ? r2 : g2)
    box.delete(vh2[1])

pos3 = 64 - candleSpacing * 3

[ho3, hh3, hl3, hc3] = request.security(syminfo.tickerid, tf, [myOpen1[3], myHigh1[3], myLow1[3], myClose1[3]])

if showHTFCandles and candleCount >= 4
    nh3 = box.new(bar_index + pos3 + boxOffset, hh3, bar_index + pos3 + boxOffset, hl3,
          border_color = ho3 > hc3 ? r2 : g2,
          bgcolor      = ho3 > hc3 ? r2 : g2)
    box.delete(nh3[1])

    vh3 = box.new(bar_index + pos3 - 1 + boxOffset, ho3, bar_index + pos3 + 1 + boxOffset, hc3,
          border_color = ho3 > hc3 ? r2 : g2,
          bgcolor      = ho3 > hc3 ? r2 : g2)
    box.delete(vh3[1])

pos4 = 64 - candleSpacing * 4

[ho4, hh4, hl4, hc4] = request.security(syminfo.tickerid, tf, [myOpen1[4], myHigh1[4], myLow1[4], myClose1[4]])

if showHTFCandles and candleCount >= 5
    nh4 = box.new(bar_index + pos4 + boxOffset, hh4, bar_index + pos4 + boxOffset, hl4,
          border_color = ho4 > hc4 ? r2 : g2,
          bgcolor      = ho4 > hc4 ? r2 : g2)
    box.delete(nh4[1])

    vh4 = box.new(bar_index + pos4 - 1 + boxOffset, ho4, bar_index + pos4 + 1 + boxOffset, hc4,
          border_color = ho4 > hc4 ? r2 : g2,
          bgcolor      = ho4 > hc4 ? r2 : g2)
    box.delete(vh4[1])

pos5 = 64 - candleSpacing * 5

[ho5, hh5, hl5, hc5] = request.security(syminfo.tickerid, tf, [myOpen1[5], myHigh1[5], myLow1[5], myClose1[5]])

if showHTFCandles and candleCount >= 6
    nh5 = box.new(bar_index + pos5 + boxOffset, hh5, bar_index + pos5 + boxOffset, hl5,
          border_color = ho5 > hc5 ? r2 : g2,
          bgcolor      = ho5 > hc5 ? r2 : g2)
    box.delete(nh5[1])

    vh5 = box.new(bar_index + pos5 - 1 + boxOffset, ho5, bar_index + pos5 + 1 + boxOffset, hc5,
          border_color = ho5 > hc5 ? r2 : g2,
          bgcolor      = ho5 > hc5 ? r2 : g2)
    box.delete(vh5[1])

pos6 = 64 - candleSpacing * 6

[ho6, hh6, hl6, hc6] = request.security(syminfo.tickerid, tf, [myOpen1[6], myHigh1[6], myLow1[6], myClose1[6]])

if showHTFCandles and candleCount >= 7
    nh6 = box.new(bar_index + pos6 + boxOffset, hh6, bar_index + pos6 + boxOffset, hl6,
          border_color = ho6 > hc6 ? r2 : g2,
          bgcolor      = ho6 > hc6 ? r2 : g2)
    box.delete(nh6[1])

    vh6 = box.new(bar_index + pos6 - 1 + boxOffset, ho6, bar_index + pos6 + 1 + boxOffset, hc6,
          border_color = ho6 > hc6 ? r2 : g2,
          bgcolor      = ho6 > hc6 ? r2 : g2)
    box.delete(vh6[1])

pos7 = 64 - candleSpacing * 7

[ho7, hh7, hl7, hc7] = request.security(syminfo.tickerid, tf, [myOpen1[7], myHigh1[7], myLow1[7], myClose1[7]])

if showHTFCandles and candleCount >= 8
    nh7 = box.new(bar_index + pos7 + boxOffset, hh7, bar_index + pos7 + boxOffset, hl7,
          border_color = ho7 > hc7 ? r2 : g2,
          bgcolor      = ho7 > hc7 ? r2 : g2)
    box.delete(nh7[1])

    vh7 = box.new(bar_index + pos7 - 1 + boxOffset, ho7, bar_index + pos7 + 1 + boxOffset, hc7,
          border_color = ho7 > hc7 ? r2 : g2,
          bgcolor      = ho7 > hc7 ? r2 : g2)
    box.delete(vh7[1])
````

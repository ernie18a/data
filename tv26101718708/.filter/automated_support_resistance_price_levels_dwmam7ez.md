# Automated Support & Resistance Price Levels

- url: https://www.tradingview.com/script/dWmAM7ez-Automated-Support-Resistance-Price-Levels/
- type: indicator
- pine_id: PUB;02711ec2014d41898723df8f56aba817
- version: 1.0

## Description

Automatic marking and labeling of prior month and week OHLC price levels as well as prior day HL price levels for support and resistance purposes. Highs are green, lows are red, and opens as well as closes are white. Confluences are combined into a single average and blue. Confluences are set by default to include any price levels within 10 ticks of one another but can be customized within the code under "defval" in line 11.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CapBearerMax

//@version=6
indicator(title="Price Levels", overlay=true, max_lines_count=500, max_labels_count=500)

// ─────────────────────────────────────────────
// USER INPUT
// ─────────────────────────────────────────────
float toleranceTicks = input.float(
     defval  = 10.0,
     title   = "Confluence Tolerance (ticks / cents)",
     minval  = 0.0,
     step    = 1.0,
     tooltip = "Number of ticks ($0.01 each) within which two levels are considered confluent. Default 10 = $0.10."
     )

float tolerance = toleranceTicks * syminfo.mintick

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
color C_HIGH      = color.green
color C_LOW       = color.red
color C_NEUTRAL   = color.white
color C_CONFLUENT = color.blue
int   THIN        = 1

// ─────────────────────────────────────────────
// PERSISTENT DRAWING ARRAYS (cleared each bar)
// ─────────────────────────────────────────────
var line[]  drawnLines  = array.new_line()
var label[] drawnLabels = array.new_label()

// ─────────────────────────────────────────────
// PRIOR MONTH OHLC
// ─────────────────────────────────────────────
prevMonthOpen  = request.security(syminfo.tickerid, "M", open[1],  lookahead=barmerge.lookahead_on)
prevMonthClose = request.security(syminfo.tickerid, "M", close[1], lookahead=barmerge.lookahead_on)
prevMonthHigh  = request.security(syminfo.tickerid, "M", high[1],  lookahead=barmerge.lookahead_on)
prevMonthLow   = request.security(syminfo.tickerid, "M", low[1],   lookahead=barmerge.lookahead_on)

// ─────────────────────────────────────────────
// PRIOR WEEK OHLC
// ─────────────────────────────────────────────
prevWeekOpen  = request.security(syminfo.tickerid, "W", open[1],  lookahead=barmerge.lookahead_on)
prevWeekClose = request.security(syminfo.tickerid, "W", close[1], lookahead=barmerge.lookahead_on)
prevWeekHigh  = request.security(syminfo.tickerid, "W", high[1],  lookahead=barmerge.lookahead_on)
prevWeekLow   = request.security(syminfo.tickerid, "W", low[1],   lookahead=barmerge.lookahead_on)

// ─────────────────────────────────────────────
// PRIOR DAY HIGH / LOW
// ─────────────────────────────────────────────
prevDayHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
prevDayLow  = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)

// ─────────────────────────────────────────────
// DELETE OLD DRAWINGS EVERY BAR
// ─────────────────────────────────────────────
for l in drawnLines
    line.delete(l)
array.clear(drawnLines)

for lb in drawnLabels
    label.delete(lb)
array.clear(drawnLabels)

// ─────────────────────────────────────────────
// BUILD LEVEL DATA
// ─────────────────────────────────────────────
float[] prices = array.new_float(0)
array.push(prices, prevMonthOpen)
array.push(prices, prevMonthClose)
array.push(prices, prevMonthHigh)
array.push(prices, prevMonthLow)
array.push(prices, prevWeekOpen)
array.push(prices, prevWeekClose)
array.push(prices, prevWeekHigh)
array.push(prices, prevWeekLow)
array.push(prices, prevDayHigh)
array.push(prices, prevDayLow)

string[] labels = array.new_string(0)
array.push(labels, "Prior Month Open")
array.push(labels, "Prior Month Close")
array.push(labels, "Prior Month High")
array.push(labels, "Prior Month Low")
array.push(labels, "Prior Week Open")
array.push(labels, "Prior Week Close")
array.push(labels, "Prior Week High")
array.push(labels, "Prior Week Low")
array.push(labels, "Prior Day High")
array.push(labels, "Prior Day Low")

color[] colors = array.new_color(0)
array.push(colors, C_NEUTRAL)
array.push(colors, C_NEUTRAL)
array.push(colors, C_HIGH)
array.push(colors, C_LOW)
array.push(colors, C_NEUTRAL)
array.push(colors, C_NEUTRAL)
array.push(colors, C_HIGH)
array.push(colors, C_LOW)
array.push(colors, C_HIGH)
array.push(colors, C_LOW)

// ─────────────────────────────────────────────
// CONFLUENCE DETECTION & DRAWING
// ─────────────────────────────────────────────
int    n    = array.size(prices)
bool[] used = array.new_bool(n, false)

for i = 0 to n - 1
    if array.get(used, i)
        continue

    float price = array.get(prices, i)

    if na(price)
        array.set(used, i, true)
        continue

    string mergedLbl  = array.get(labels, i)
    color  mergedCol  = array.get(colors, i)
    bool   confluent  = false
    float  priceSum   = price
    int    priceCount = 1

    int jMax = n - 1
    if i < jMax
        for j = i + 1 to jMax
            if array.get(used, j)
                continue
            float otherPrice = array.get(prices, j)
            if not na(otherPrice) and math.abs(price - otherPrice) <= tolerance
                mergedLbl  := mergedLbl + " & " + array.get(labels, j)
                confluent  := true
                priceSum   += otherPrice
                priceCount += 1
                array.set(used, j, true)

    array.set(used, i, true)

    float plotPrice  = priceSum / priceCount
    color finalColor = confluent ? C_CONFLUENT : mergedCol

    newLine = line.new(
         x1     = bar_index - 300,
         y1     = plotPrice,
         x2     = bar_index - 1,
         y2     = plotPrice,
         extend = extend.right,
         color  = finalColor,
         width  = THIN,
         style  = line.style_solid
         )

    newLabel = label.new(
         x         = bar_index,
         y         = plotPrice,
         text      = mergedLbl,
         color     = color.new(color.black, 100),
         textcolor = finalColor,
         style     = label.style_label_left,
         size      = size.normal,
         textalign = text.align_left
         )

    array.push(drawnLines,  newLine)
    array.push(drawnLabels, newLabel)
````

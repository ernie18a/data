# Wil - Current Key Levels

- url: https://www.tradingview.com/script/Zd4QDRYr-Wil-Current-Key-Levels/
- type: indicator
- pine_id: PUB;8e2c5c7015b14518bf21ec2f1cbdcfa7
- version: 1.0

## Description

tweaked spacing further. still running into some weirdness!

## Source Code

````pine
//@version=5
indicator("Wil - Current Key Levels", overlay=true, max_lines_count=500, max_labels_count=500)

//------------------------------------------------------
// Inputs
//------------------------------------------------------
showPrevDay      = input.bool(true,  "Previous Day High/Low")
showTodayOpen    = input.bool(true,  "Today Open")
showWeekLevels   = input.bool(true,  "Weekly High/Low")
showDailyEMAs    = input.bool(true,  "Daily EMA Levels")
showWeeklyEMAs   = input.bool(true,  "Weekly EMA Levels")
showVWAP         = input.bool(true,  "VWAP")
showLabels       = input.bool(true,  "Show Labels")

lineStartMode    = input.string("Today", "Line Start", options=["Today", "This Week"])

// Keep these fixed. No settings clutter.
labelOffsetBars      = 15
lineRightBars        = labelOffsetBars - 5
minLabelAtrMultiple  = 0.06

// Relevance filter
filterFarMA      = input.bool(true, "Hide Far EMA/VWAP Levels")
maxAtrDistance   = input.float(2.5, "Max ATR Distance for EMA/VWAP", minval=0.5, step=0.25)

//------------------------------------------------------
// Period anchors
//------------------------------------------------------
isNewDay  = ta.change(time("D")) != 0
isNewWeek = ta.change(time("W")) != 0

todayStartBar = ta.valuewhen(isNewDay, bar_index, 0)
weekStartBar  = ta.valuewhen(isNewWeek, bar_index, 0)

startBar = lineStartMode == "Today" ? todayStartBar : weekStartBar
startBar := na(startBar) ? bar_index : startBar

//------------------------------------------------------
// Higher timeframe levels
//------------------------------------------------------
prevDayHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
prevDayLow  = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_off)
todayOpen   = request.security(syminfo.tickerid, "D", open,    lookahead=barmerge.lookahead_off)

thisWeekHigh = request.security(syminfo.tickerid, "W", high,    lookahead=barmerge.lookahead_off)
thisWeekLow  = request.security(syminfo.tickerid, "W", low,     lookahead=barmerge.lookahead_off)
lastWeekLow  = request.security(syminfo.tickerid, "W", low[1],  lookahead=barmerge.lookahead_off)

dailyEMA9   = request.security(syminfo.tickerid, "D", ta.ema(close, 9),  lookahead=barmerge.lookahead_off)
dailyEMA21  = request.security(syminfo.tickerid, "D", ta.ema(close, 21), lookahead=barmerge.lookahead_off)
dailyEMA50  = request.security(syminfo.tickerid, "D", ta.ema(close, 50), lookahead=barmerge.lookahead_off)

weeklyEMA9  = request.security(syminfo.tickerid, "W", ta.ema(close, 9),  lookahead=barmerge.lookahead_off)

vwapValue   = ta.vwap(close)
atrValue    = ta.atr(14)

//------------------------------------------------------
// Colors - pastel but readable
//------------------------------------------------------
cPrevHigh   = color.rgb(255, 145, 145)
cPrevLow    = color.rgb(140, 215, 165)
cTodayOpen  = color.rgb(120, 215, 235)

cWeekHigh   = color.rgb(255, 120, 135)
cWeekLow    = color.rgb(120, 205, 150)
cLastWeek   = color.rgb(145, 175, 255)

cEMA9       = color.rgb(255, 165, 175)
cEMA21      = color.rgb(135, 175, 255)
cEMA50      = color.rgb(205, 145, 235)

cVWAP       = color.rgb(160, 160, 160)

//------------------------------------------------------
// Helpers
//------------------------------------------------------
f_same_level(_a, _b) =>
    not na(_a) and not na(_b) and math.abs(_a - _b) <= syminfo.mintick

f_is_relevant_dynamic(_price) =>
    not filterFarMA or (not na(_price) and math.abs(close - _price) <= atrValue * maxAtrDistance)

f_arrow(_price) =>
    _price < close ? " ▲" : _price > close ? " ▼" : ""

f_add_level(arrPrices, arrTexts, arrColors, arrIsDynamic, _enabled, _price, _text, _color, _isDynamic) =>
    if _enabled and not na(_price)
        array.push(arrPrices, _price)
        array.push(arrTexts, _text)
        array.push(arrColors, _color)
        array.push(arrIsDynamic, _isDynamic)

f_swap_float(arr, i, j) =>
    temp = array.get(arr, i)
    array.set(arr, i, array.get(arr, j))
    array.set(arr, j, temp)

f_swap_string(arr, i, j) =>
    temp = array.get(arr, i)
    array.set(arr, i, array.get(arr, j))
    array.set(arr, j, temp)

f_swap_color(arr, i, j) =>
    temp = array.get(arr, i)
    array.set(arr, i, array.get(arr, j))
    array.set(arr, j, temp)

f_swap_bool(arr, i, j) =>
    temp = array.get(arr, i)
    array.set(arr, i, array.get(arr, j))
    array.set(arr, j, temp)

//------------------------------------------------------
// Object storage
//------------------------------------------------------
var line[]  levelLines  = array.new_line()
var label[] levelLabels = array.new_label()

f_clear_objects() =>
    if array.size(levelLines) > 0
        for i = 0 to array.size(levelLines) - 1
            line.delete(array.get(levelLines, i))
        array.clear(levelLines)

    if array.size(levelLabels) > 0
        for i = 0 to array.size(levelLabels) - 1
            label.delete(array.get(levelLabels, i))
        array.clear(levelLabels)

//------------------------------------------------------
// Duplicate logic
//------------------------------------------------------
showPrevDayHighFinal = showPrevDay and not f_same_level(prevDayHigh, thisWeekHigh)
showPrevDayLowFinal  = showPrevDay and not f_same_level(prevDayLow, thisWeekLow)

// Dynamic relevance
showVWAPFinal       = showVWAP and f_is_relevant_dynamic(vwapValue)
showDailyEMA9Final  = showDailyEMAs and f_is_relevant_dynamic(dailyEMA9)
showDailyEMA21Final = showDailyEMAs and f_is_relevant_dynamic(dailyEMA21)
showDailyEMA50Final = showDailyEMAs and f_is_relevant_dynamic(dailyEMA50)
showWeeklyEMA9Final = showWeeklyEMAs and f_is_relevant_dynamic(weeklyEMA9)

//------------------------------------------------------
// Main
//------------------------------------------------------
if barstate.islast
    f_clear_objects()

    float[]  arrPrices    = array.new_float()
    string[] arrTexts     = array.new_string()
    color[]  arrColors    = array.new_color()
    bool[]   arrIsDynamic = array.new_bool()

    //--------------------------------------------------
    // Build level list
    //--------------------------------------------------
    f_add_level(arrPrices, arrTexts, arrColors, arrIsDynamic, showWeekLevels,        thisWeekHigh, "This Week High",   cWeekHigh,  false)
    f_add_level(arrPrices, arrTexts, arrColors, arrIsDynamic, showPrevDayHighFinal,  prevDayHigh,  "Yesterday's High", cPrevHigh,  false)

    f_add_level(arrPrices, arrTexts, arrColors, arrIsDynamic, showTodayOpen,         todayOpen,    "Today Open",       cTodayOpen, false)

    f_add_level(arrPrices, arrTexts, arrColors, arrIsDynamic, showVWAPFinal,         vwapValue,    "VWAP",             cVWAP,      true)
    f_add_level(arrPrices, arrTexts, arrColors, arrIsDynamic, showDailyEMA9Final,    dailyEMA9,    "Daily 9 EMA",      cEMA9,      true)
    f_add_level(arrPrices, arrTexts, arrColors, arrIsDynamic, showDailyEMA21Final,   dailyEMA21,   "Daily 21 EMA",     cEMA21,     true)
    f_add_level(arrPrices, arrTexts, arrColors, arrIsDynamic, showDailyEMA50Final,   dailyEMA50,   "Daily 50 EMA",     cEMA50,     true)
    f_add_level(arrPrices, arrTexts, arrColors, arrIsDynamic, showWeeklyEMA9Final,   weeklyEMA9,   "Weekly 9 EMA",     cEMA9,      true)

    f_add_level(arrPrices, arrTexts, arrColors, arrIsDynamic, showPrevDayLowFinal,   prevDayLow,   "Yesterday's Low",  cPrevLow,   false)
    f_add_level(arrPrices, arrTexts, arrColors, arrIsDynamic, showWeekLevels,        thisWeekLow,  "This Week Low",    cWeekLow,   false)
    f_add_level(arrPrices, arrTexts, arrColors, arrIsDynamic, showWeekLevels,        lastWeekLow,  "Last Week Low",    cLastWeek,  false)

    //--------------------------------------------------
    // Sort high-to-low
    //--------------------------------------------------
    sz = array.size(arrPrices)

    if sz > 1
        for i = 0 to sz - 2
            for j = i + 1 to sz - 1
                if array.get(arrPrices, j) > array.get(arrPrices, i)
                    f_swap_float(arrPrices, i, j)
                    f_swap_string(arrTexts, i, j)
                    f_swap_color(arrColors, i, j)
                    f_swap_bool(arrIsDynamic, i, j)

    //--------------------------------------------------
    // Draw exact lines + right-side legend labels
    //--------------------------------------------------
    minSpacing = atrValue * minLabelAtrMultiple
    float previousLabelY = na

    if sz > 0
        for i = 0 to sz - 1
            levelPrice = array.get(arrPrices, i)
            levelText  = array.get(arrTexts, i)
            levelColor = array.get(arrColors, i)
            isDynamic  = array.get(arrIsDynamic, i)

            // Line stays exact.
            ln = line.new(
                 x1=startBar,
                 y1=levelPrice,
                 x2=bar_index + lineRightBars,
                 y2=levelPrice,
                 xloc=xloc.bar_index,
                 extend=extend.none,
                 color=levelColor,
                 width=1)

            array.push(levelLines, ln)

            // Label is allowed to move vertically to avoid text collisions.
            labelY = levelPrice

            if not na(previousLabelY) and (previousLabelY - labelY) < minSpacing
                labelY := previousLabelY - minSpacing

            if showLabels
                labelText = levelText + " (" + str.tostring(levelPrice, format.mintick) + ")" + (isDynamic ? f_arrow(levelPrice) : "")

                lbl = label.new(
                     x=bar_index + labelOffsetBars,
                     y=labelY,
                     xloc=xloc.bar_index,
                     yloc=yloc.price,
                     text=labelText,
                     style=label.style_none,
                     textcolor=levelColor,
                     color=color.new(color.white, 100),
                     size=size.normal,
                     textalign=text.align_left)

                array.push(levelLabels, lbl)

            previousLabelY := labelY
````

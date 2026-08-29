<!-- tradingview-pine-id: PUB;34a6449880c84004b8d0026d2369b6e0 -->
<!-- tradingviewscripts-format: 1 -->
# VisibleChart

Source: https://www.tradingview.com/script/j7vCseM2-VisibleChart/

## Description

█  OVERVIEW

This library is a Pine programmer’s tool containing functions that return values calculated from the range of visible bars on the chart.

This is now possible in Pine Script™ thanks to the recently-released [chart.left_visible_bar_time](https://www.tradingview.com/pine-script-reference/v5/#var_chart{dot}left_visible_bar_time) and [chart.right_visible_bar_time](https://www.tradingview.com/pine-script-reference/v5/#var_chart{dot}right_visible_bar_time) built-ins, which return the opening [time](https://www.tradingview.com/pine-script-reference/v5/#fun_time) of the leftmost and rightmost bars on the chart. These values update as traders scroll or zoom their charts, which gives way to a class of indicators that can dynamically recalculate and draw visuals on visible bars only, as users scroll or zoom their charts. We hope this library's functions help you make the most of the world of possibilities these new built-ins provide for Pine scripts.

For an example of a script using this library, have a look at the [Chart ​VWAP](https://www.tradingview.com/script/QE4dq4ZM-Chart-VWAP/) indicator.

█  CONCEPTS

Chart properties

The new [chart.left_visible_bar_time](https://www.tradingview.com/pine-script-reference/v5/#var_chart{dot}left_visible_bar_time) and [chart.right_visible_bar_time](https://www.tradingview.com/pine-script-reference/v5/#var_chart{dot}right_visible_bar_time) variables return the opening [time](https://www.tradingview.com/pine-script-reference/v5/#fun_time) of the leftmost and rightmost bars on the chart. They are only two of many new built-ins in the `chart.*` namespace. See [this blog post](https://www.tradingview.com/blog/en/pine-script-and-charts-become-better-acquainted-32927/) for more information, or look them up by typing "chart." in the [Pine Script™ Reference Manual](https://www.tradingview.com/pine-script-reference/v5/).

Dynamic recalculation of scripts on visible bars

Any script using [chart.left_visible_bar_time](https://www.tradingview.com/pine-script-reference/v5/#var_chart{dot}left_visible_bar_time) or [chart.right_visible_bar_time](https://www.tradingview.com/pine-script-reference/v5/#var_chart{dot}right_visible_bar_time) acquires a unique property, which triggers its recalculation when traders scroll or zoom their charts in such a way that the range of visible bars on the chart changes. This library's functions use the two recent built-ins to derive various values from the range of visible bars.

Designing your scripts for dynamic recalculation 

For the library's functions to work correctly, they must be called on every bar. For reliable results, assign their results to global variables and then use the variables locally where needed — not the raw function calls.

Some functions like `barIsVisible()` or `open()` will return a value starting on the leftmost visible bar. Others such as `high()` or `low()` will also return a value starting on the leftmost visible bar, but their correct value can only be known on the rightmost visible bar, after all visible bars have been analyzed by the script.

You can plot values as the script executes on visible bars, but efficient code will, when possible, create resource-intensive labels, lines or tables only once in the global ​scope using [var](https://www.tradingview.com/pine-script-reference/v5/#op_var), and then use the setter functions to modify their properties on the last bar only. The example code included in this library uses this method.

Keep in mind that when your script uses [chart.left_visible_bar_time](https://www.tradingview.com/pine-script-reference/v5/#var_chart{dot}left_visible_bar_time) or [chart.right_visible_bar_time](https://www.tradingview.com/pine-script-reference/v5/#var_chart{dot}right_visible_bar_time), your script will recalculate on all bars each time the user scrolls or zooms their chart. To provide script users with the best experience you should strive to keep calculations to a minimum and use efficient code so that traders are not always waiting for your script to recalculate every time they scroll or zoom their chart.

Another aspect to consider is the fact that the rightmost visible bar will not always be the last bar in the dataset. When script users scroll back in time, a large portion of the time series the script calculates on may be situated after the rightmost visible bar. We can never assume the rightmost visible bar is also the last bar of the time series. Use `barIsVisible()` to restrict calculations to visible bars, but also consider that your script can continue to execute past them.

[Look first. Then leap.](https://www.tradingview.com/athletes/) 

█  FUNCTIONS

The library contains the following functions:

barIsVisible()
  Condition to determine if a given bar is within the users visible time range.
  Returns: (bool) True if the the calling bar is between the `chart.left_visible_bar_time` and the `chart.right_visible_bar_time`.

high()
  Determines the value of the highest `high` in visible bars.
  Returns: (float) The maximum high value of visible chart bars.

highBarIndex()
  Determines the `bar_index` of the highest `high` in visible bars.
  Returns: (int) The `bar_index` of the `high()`.

highBarTime()
  Determines the bar time of the highest `high` in visible bars.
  Returns: (int) The `time` of the `high()`.

low()
  Determines the value of the lowest `low` in visible bars.
  Returns: (float) The minimum low value of visible chart bars.

lowBarIndex()
  Determines the `bar_index` of the lowest `low` in visible bars.
  Returns: (int) The `bar_index` of the `low()`.

lowBarTime()
  Determines the bar time of the lowest `low` in visible bars.
  Returns: (int) The `time` of the `low()`.

open()
  Determines the value of the opening price in the visible chart time range.
  Returns: (float) The `open` of the leftmost visible chart bar.

close()
  Determines the value of the closing price in the visible chart time range.
  Returns: (float) The `close` of the rightmost visible chart bar.

leftBarIndex()
  Determines the `bar_index` of the leftmost visible chart bar.
  Returns: (int) A `bar_index`.

rightBarIndex()
  Determines the `bar_index` of the rightmost visible chart bar.
  Returns: (int) A `bar_index`

bars()
  Determines the number of visible chart bars.
  Returns: (int) The number of bars.

volume()
  Determines the sum of volume of all visible chart bars.
  Returns: (float) The cumulative sum of volume.

ohlcv()
  Determines the open, high, low, close, and volume sum of the visible bar time range.
  Returns: ([float, float, float, float, float]) A tuple of the OHLCV values for the visible chart bars. Example: open is chart left, high is the highest visible high, etc.

chartYPct(​pct)
  Determines a price level as a percentage of the visible bar price range, which depends on the chart's top/bottom margins in "Settings/Appearance".
  Parameters:
    pct: (series float) Percentage of the visible price range (50 is 50%). Negative values are allowed.
  Returns: (float) A price level equal to the `pct` of the price range between the high and low of visible chart bars. Example: 50 is halfway between the visible high and low.

chartXTimePct(​pct)
  Determines a time as a percentage of the visible bar time range.
  Parameters:
    pct: (series float) Percentage of the visible time range (50 is 50%). Negative values are allowed.
  Returns: (float) A time in UNIX format equal to the `pct` of the time range from the `chart.left_visible_bar_time` to the `chart.right_visible_bar_time`. Example: 50 is halfway from the leftmost visible bar to the rightmost.

chartXIndexPct(​pct)
  Determines a `bar_index` as a percentage of the visible bar time range.
  Parameters:
    pct: (series float) Percentage of the visible time range (50 is 50%). Negative values are allowed.
  Returns: (float) A time in UNIX format equal to the `pct` of the time range from the `chart.left_visible_bar_time` to the `chart.right_visible_bar_time`. Example: 50 is halfway from the leftmost visible bar to the rightmost.

whenVisible(​src, whenCond, length)
  Creates an array containing the `length` last `src` values where `whenCond` is true for visible chart bars.
  Parameters:
    src: (series int/float) The source of the values to be included. 
    whenCond: (series bool) The condition determining which values are included. Optional. The default is `true`.
    length: (simple int) The number of last values to return. Optional. The default is all values.
  Returns: (float[]) The array ID of the accumulated `src` values.

avg(​src)
  Gathers values of the source over visible chart bars and averages them.
  Parameters:
    src: (series int/float) The source of the values to be averaged. Optional. Default is `close`. 
  Returns: (float) A cumulative average of values for the visible time range.

median(​src)
  Calculates the median of a source over visible chart bars.
  Parameters:
    src: (series int/float) The source of the values. Optional. Default is `close`.
  Returns: (float) The median of the `src` for the visible time range.

vVwap(​src)
  Calculates a volume-weighted average for visible chart bars.
  Parameters:
    src: (series int/float) Source used for the ​VWAP calculation. Optional. Default is `hlc3`.
  Returns: (float) The ​VWAP for the visible time range.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PineCoders

//@version=6
library("VisibleChart", true)

// VisibleChart Library
// v5, 2025.03.26

// This code was written using the recommendations from the Pine Script® User Manual's Style Guide:
//   https://www.tradingview.com/pine-script-docs/writing/style-guide/



//#region ———————————————————— Library functions 


// @function        Checks whether the current execution's bar is visible on the chart.
// @returns         (bool) `true` if the bar is visible, `false` otherwise. 
export barIsVisible() =>
    bool result = time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
    

// @function        Checks whether the current execution's bar is the first visible bar on the chart. 
// @returns         (bool) `true` if the bar is the first visible one, `false` otherwise. 
export isFirstVisibleBar() =>
    bool result = time == chart.left_visible_bar_time


// @function        Checks whether the current execution's bar is the last visible bar on the chart.
// @returns         (bool) `true` if the bar is the last visible one, `false` otherwise.
export isLastVisibleBar() =>
    bool result = time == chart.right_visible_bar_time


// @function        Identifies the highest `high` value across the visible chart bars up to the current bar. 
//                  This function should execute on each visible bar for consistent calculations. 
// @returns         (float) The highest `high` value for all visible bars up to current bar, or `na` if the bar is not
//                  visible.
export high() => 
    var float result = na
    if barIsVisible() and high >= nz(result, high)
        result := high
    result


// @function        Retrieves the `bar_index` of the visible bar with the highest `high` value as of the current 
//                  execution. 
//                  This function should execute on each visible bar for consistent calculations. 
// @returns         (int) The `bar_index` corresponding to the highest `high` value for all visible bars up to the 
//                  current bar, or `na` if the bar is not visible.  
export highBarIndex() =>
    var float chartHigh = na
    var int   highBar   = na
    if barIsVisible() and high >= nz(chartHigh, high)
        highBar   := bar_index
        chartHigh := high
    int result = highBar


// @function        Retrieves the opening time of the visible bar with the highest `high` value as of the current 
//                  execution.
//                  This function should execute on each visible bar for consistent calculations.
// @returns         (int) The `time` corresponding to the highest `high` value for all visible bars up to the 
//                  current bar, or `na` if the bar is not visible. 
export highBarTime() =>
    var float chartHigh = na
    var int   highTime  = na
    if barIsVisible() and high >= nz(chartHigh, high)
        highTime  := time
        chartHigh := high
    int result = highTime


// @function        Identifies the lowest `low` value across the visible chart bars up to the current bar.
//                  This function should execute on each visible bar for consistent calculations. 
// @returns         (float) The lowest `low` value for all visible bars up to current bar, or `na` if the bar is not
//                  visible.
export low() => 
    var float result = na
    if barIsVisible() and low <= nz(result, low)
        result := low
    result


// @function        Retrieves the `bar_index` of the visible bar with the lowest `low` value as of the current 
//                  execution. 
//                  This function should execute on each visible bar for consistent calculations. 
// @returns         (int) The `bar_index` corresponding to the lowest `low` value for all visible bars up to the 
//                  current bar, or `na` if the bar is not visible.  
export lowBarIndex() =>
    var float chartLow = na
    var int   lowBar   = na
    if barIsVisible() and low <= nz(chartLow, low)
        lowBar   := bar_index
        chartLow := low
    int result = lowBar


// @function        Retrieves the opening time of the visible bar with the lowest `low` value as of the current 
//                  execution.
//                  This function should execute on each visible bar for consistent calculations.
// @returns         (int) The `time` corresponding to the lowest `low` value for all visible bars up to the 
//                  current bar, or `na` if the bar is not visible.  
export lowBarTime() =>
    var float chartLow = na
    var int   lowTime  = na
    if barIsVisible() and low <= nz(chartLow, low)
        lowTime  := time
        chartLow := low
    int result = lowTime


// @function        Identifies the opening value of the first bar in the chart's visible range.
//                  This function should execute on each visible bar for consistent calculations. 
// @returns         (float) The first visible bar's `open` value, or `na` if the bar is not visible.
export open() => 
    var float result = na
    if isFirstVisibleBar()
        result := open
    result


// @function        Identifies the `close` value for the current bar in the chart's visible range.
//                  This function should execute on each visible bar for consistent calculations. 
// @returns         (float) The `close` value of the current bar if it is visible, `na` otherwise.
export close() => 
    var float result = na
    if barIsVisible()
        result := close
    result


// @function        Retrieves the `bar_index` of the first bar in the chart's visible range.
//                  This function should execute on each visible bar for consistent calculations. 
// @returns         (int) The first visible bar's `bar_index`, or `na` if the bar is not visible.
export leftBarIndex() => 
    var int result = na
    if isFirstVisibleBar()
        result := bar_index
    result


// @function        Retrieves the `bar_index` for the current bar in the chart's visible range.
//                  This function should execute on each visible bar for consistent calculations.
// @returns         (int) The `bar_index` value of the current bar if it is visible, `na` otherwise.
export rightBarIndex() => 
    var int result = na
    if barIsVisible()
        result := bar_index
    result


// @function        Counts the number of bars from the leftmost visible bar to the current bar.
//                  This function should execute on each visible bar for consistent calculations.
// @returns         (int) The number of visible bars as of the current bar.
export bars() => 
    var int result = 0
    if barIsVisible()
        result += 1
    result


// @function        Calculates the sum of `volume` values across visible bars up to the current bar.
//                  This function should execute on each visible bar for consistent calculations.
// @returns         (float) The cumulative volume of visible bars up to the current bar. 
export volume() =>
    var float result = 0
    if barIsVisible()
        result += volume
    result


// @function        Retrieves the open, high, low, close, and volume for the visible visible bars up to the current bar.
//                  This function should execute on each visible bar for consistent calculations.
// @returns         ([float, float, float, float, float]) A tuple containing the following values:
//                   - The first visible bar's `open`.
//                   - The highest visible `high` as of the current bar.
//                   - The lowest visible `low` as of the current bar.
//                   - The current visible bar's `close`.
//                   - The total `volume` across the visible bars up to the current bar.
//                  If the current bar is not visible, the tuple's values are `na`. 
export ohlcv() =>
    [open(), high(), low(), close(), volume()]


// @function        Calculates level corresponding to a percentage of the chart's visible value range added to or 
//                  subtracted from the current visible low.
//                  This function should execute on each visible bar for consistent calculations.
// @param pct       (series float) The percentage of the visible price range (e.g., 50 means 50% of the visible 
//                  high - low range). If the value is positive, the function adds the percentage of the range to the 
//                  current visible low. Otherwise, it subtracts the range percentage from the low. 
// @returns         (float) The level at the specified distance from the current visible low. For example, the result 
//                  for `pct = 50` is the midpoint between the current visible high and low. 
export chartYPct(series float pct) =>
    float result = low() + ((high() - low()) * (pct / 100))


// @function        Calculates the UNIX timestamp that equals a specified percentage from the leftmost visible bar's 
//                  time to the rightmost visible bar's time, rounded down to the nearest millisecond. 
// @param pct       (series float) The percentage of the visible time range (e.g., 50 means 50% of the time distance 
//                  from the leftmost to rightmost visible bar). If the value is positive, the function adds the 
//                  percentage of the range to the leftmost visible time. Otherwise, it subtracts the range from 
//                  the value. 
// @returns         (int) A UNIX timestamp representing the point `pct` distance from `chart.left_visible_bar_time` to 
//                  `chart.right_visible_bar_time`, rounded down to the nearest integer. For example, the result for 
//                  `pct = 50` is the midpoint between leftmost and rightmost visible times, without microseconds.
export chartXTimePct(series float pct) => 
    int result = 
         chart.left_visible_bar_time + int((chart.right_visible_bar_time - chart.left_visible_bar_time) * (pct / 100))


// @function        Calculates the bar index that equals a specified percentage from the leftmost visible bar's 
//                  index to the current visible bar's index, rounded down to the nearest valid `bar_index` value.
//                  This function should execute on each visible bar for consistent calculations.
// @param pct       (series float) The percentage of the visible bar count (e.g., 50 means 50% of the index range 
//                  from the leftmost to current visible bar). If the value is positive, the function adds the 
//                  percentage of the count to the leftmost bar's index. Otherwise, it substracts the count percentage 
//                  from the index.
// @returns         (int) The bar index value between the leftmost visible bar and the current bar, rounded down to 
//                  the nearest integer. For example, the result for `pct = 50` is the whole `bar_index` halfway 
//                  between the leftmost and current visible bars. If the current bar is not visible, the function 
//                  returns `na`. 
export chartXIndexPct(series float pct) => 
    int leftBarIndex  = leftBarIndex()
    int rightBarIndex = rightBarIndex()
    int result = leftBarIndex + int((rightBarIndex - leftBarIndex) * (pct / 100))


// @function        Creates an array containing the `length` latest `source` values for all visible bars up to the 
//                  current bar whose `whenCond` is `true`.
//                  This function should execute on each visible bar for consistent calculations.
// @param source    (series float) The source series from which to collect visible bar values.
// @param whenCond  (series bool) Optional. If `true`, the function collects the visible bar's `source` value.
//                  Otherwise, it ignores the bar's value. The default is `true`.
// @param length    (simple int) Optional. The number of values to collect in the array. If not specified, the function 
//                  collects all bars in the visible range up to the current bar. The default is `na`.
// @returns         (array<float>) The reference of a "float" array containing the `source` values from all visible bars 
//                  up to the current bar where `whenCond` is `true`. If the current bar is not visible, the resulting 
//                  array is empty. 
export whenVisible(series float source, series bool whenCond = true, simple int length = na) =>
    var array<float> values = array.new<float>()
    int cappedLen = math.max(1, length)
    if barIsVisible() and whenCond
        values.push(source)
    if not na(cappedLen) and values.size() > cappedLen
        values.shift()
    values


// @function        Calculates the cumulative average of `source` values for all visible bars up to the current bar.
//                  This function should execute on each bar for consistent calculations.
// @param source    (series float) Optional. The series of visible values to process. The default is `close`.
// @returns         (float) The cumulative average of `source` values across visible bars up to the current bar, 
//                  or `na` if the current bar is not visible. 
export avg(series float source = close) =>
    bool  visible  = barIsVisible() 
    float cumTotal = ta.cum(visible ? source : 0)
    float cumCount = ta.cum(visible ? 1 : 0)
    float result   = cumTotal / cumCount


// @function        Calculates the median of `source` values for all visible bars up to the current bar.
//                  This function should execute on each visible bar for consistent calculations.
// @param source    (series float) Optional. The series of visible values to process. The default is `close`.
// @returns         (float) The median of `source` values across visible bars up to the current bar, 
//                  or `na` if the current bar is not visible. 
export median(series float src = close) =>
    float result = array.median(whenVisible(src))


// @function        Calculates the volume-weighted average price (VWAP) for all visible bars up to the current bar.
//                  This function should execute on each visible bar for consistent calculations.
// @param source    (series float) Optional. The series of visible values to process. The default is `hlc3`.
// @returns         (float) The VWAP of `source` values across visible bars up to the current bar, or `na` if 
//                  the current bar is not visible.
export vVwap(series float src = hlc3) =>
    bool  startTime = isFirstVisibleBar()
    float result    = ta.vwap(src, startTime)
//#endregion



//#region ———————————————————— Example code 


// !!!!! WARNING
// !!!!! Most of this library's functions perform successive calculations across visible bars. 
//       To ensure correct results, call these functions on every bar. 


// Get visible chart data for the Fibonacci drawing. 
float chartHigh  = high()
float chartLow   = low()
int   highTime   = highBarTime()
int   lowTime    = lowBarTime()
int   leftTime   = math.min(highTime, lowTime)
int   rightTime  = math.max(highTime, lowTime)
bool  isBull     = lowTime < highTime
int   bars       = bars()
float vol        = volume()

// @function        Creates and manages Fibonacci retracement lines on the chart. The function initializes lines and
//                  labels on the first call and updates their properties on subsequent calls.
// @param fibColor  (series color) The color of the Fibonacci lines.
// @param fibLevel  (series float) The Fibonacci level as a percentage (e.g., 61.8 for 61.8% retracement).
// @returns         (void) This function does not return a usable value.
fibLine(series color fibColor, series float fibLevel) => 
    float fibRatio = fibLevel / 100
    float fibPrice = isBull ? chartHigh - ((chartHigh - chartLow) * fibRatio) : 
                              chartLow  + ((chartHigh - chartLow) * fibRatio) 
    var line  fibLine  = line.new(na, na, na, na, xloc.bar_time, extend.none, fibColor, line.style_solid,  1)
    var line  fibLine2 = line.new(na, na, na, na, xloc.bar_time, extend.none, fibColor, line.style_dotted, 1)
    var label fibLabel = label.new(na, na, "", xloc.bar_time, yloc.price,  color(na), label.style_label_up, fibColor)
    line.set_xy1(fibLine,  leftTime,  fibPrice)
    line.set_xy2(fibLine,  rightTime, fibPrice)
    line.set_xy1(fibLine2, rightTime, fibPrice)
    line.set_xy2(fibLine2, time,      fibPrice)
    label.set_xy(fibLabel, int(math.avg(leftTime, rightTime)), fibPrice)
    label.set_text(fibLabel, str.format("{0, number, #.###} ({1})", fibRatio, str.tostring(fibPrice, format.mintick)))

// Logic to create and manage drawings on the latest bar, where the results of all the drawings are visible. 
if barstate.islast
    // @variable A single-cell table that displays the visible bar count and cumulative volume. 
    var table display = table.new(position.top_right, 1, 1)
    // @variable A "string" containing the text to display in the table.
    string displayString = "Total Visible Bars: "     + str.tostring(bars)
                         + "\nTotal Visible Volume: " + str.tostring(vol, format.volume)
    // Initialize the table's cell with the `displayString`.
    table.cell(
         display, 0, 0, displayString, bgcolor = color.yellow, text_color = color.black, text_size = size.normal
     )

    // Initialize labels for the high and low points. 
    var label hiLabel = label.new(
         na, na, na, xloc.bar_time, yloc.price, color.new(color.lime, 80), label.style_label_down, color.lime
     )
    var label loLabel = label.new(
         na, na, na, xloc.bar_time, yloc.price, color.new(color.fuchsia, 80), label.style_label_up, color.fuchsia
     )
    // Update the labels' properties for changes to high and low coordinates. 
    label.set_xy(hiLabel, highTime, chartHigh)
    label.set_xy(loLabel, lowTime,  chartLow)
    label.set_text(
         hiLabel, str.format(
             "{0}\n{1}", str.tostring(chartHigh, format.mintick), str.format_time(highTime, "dd/MM/yy '@' HH:mm:ss")
         )
     )
    label.set_text(
         loLabel, str.format(
             "{0}\n{1}", str.tostring(chartLow,  format.mintick), str.format_time(lowTime, "dd/MM/yy '@' HH:mm:ss")
         )
     )

    // Create Fibonacci lines and labels once, then update their properties on each new bar.  
    fibLine(color.gray,  100)
    fibLine(#64b5f6,     78.6)
    fibLine(#089981,     61.8)
    fibLine(color.green, 50)
    fibLine(#81c784,     38.2)
    fibLine(color.red,   23.6)
    fibLine(color.gray,  0)

    // @variable A dashed line connecting the visible high and low points. 
    var line hiLoLine =  line.new(na, na, na, na, xloc.bar_time, extend.none, color.gray, line.style_dashed, 1)
    // Update the line's coordinates on each new bar. 
    line.set_xy1(hiLoLine, highTime, chartHigh)
    line.set_xy2(hiLoLine, lowTime,  chartLow)
//#endregion
````

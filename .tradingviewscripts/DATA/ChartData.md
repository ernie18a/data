<!-- tradingview-pine-id: PUB;78417201f473432caa171b31dc4cad4a -->
<!-- tradingviewscripts-format: 1 -->
# ChartData

Source: https://www.tradingview.com/script/McBWNSif-Bar-Index-Time/

## Description

Library to convert a bar index to a timestamp and vice versa.
Utilizes runtime memory to store the 𝚝𝚒𝚖𝚎 and 𝚝𝚒𝚖𝚎_𝚌𝚕𝚘𝚜𝚎 values of every bar on the chart (and optional future bars), with the ability of storing additional custom values for every chart bar.

█ PREFACE

This library aims to tackle some problems that pine coders (from beginners to advanced) often come across, such as:

[*] I'm trying to draw an object with a 𝚋𝚊𝚛_𝚒𝚗𝚍𝚎𝚡 that is more than 10,000 bars into the past, but this causes my script to fail.  How can I convert the 𝚋𝚊𝚛_𝚒𝚗𝚍𝚎𝚡 to a UNIX time so that I can draw visuals using  [xloc.bar_time](https://www.tradingview.com/pine-script-reference/v6/#const_xloc.bar_time)?
[*] I have a diagonal line drawing and I want to get the "y" value at a specific time, but [line.get_price()](https://www.tradingview.com/pine-script-reference/v6/#fun_line.get_price) only accepts a bar index value.  How can I convert the timestamp into a bar index value so that I can still use this function?
[*] I want to get a previous 𝚘𝚙𝚎𝚗 value that occurred at a specific timestamp.  How can I convert the timestamp into a historical offset so that I can use 𝚘𝚙𝚎𝚗[𝚘𝚏𝚏𝚜𝚎𝚝]?
[*] I want to reference a very old value for a variable.  How can I access a previous value that is older than the maximum historical buffer size of 𝚟𝚊𝚛𝚒𝚊𝚋𝚕𝚎[5000]?
This library can solve the above problems (and many more) with the addition of a few lines of code, rather than requiring the coder to refactor their script to accommodate the limitations.

█ OVERVIEW

The core functionality provided is conversion between [xloc.bar_index](https://www.tradingview.com/pine-script-reference/v6/#const_xloc.bar_index) and [xloc.bar_time](https://www.tradingview.com/pine-script-reference/v6/#const_xloc.bar_time) values.

The main component of the library is the 𝙲𝚑𝚊𝚛𝚝𝙳𝚊𝚝𝚊 object, created via the 𝚌𝚘𝚕𝚕𝚎𝚌𝚝𝙲𝚑𝚊𝚛𝚝𝙳𝚊𝚝𝚊() function which basically stores the 𝚝𝚒𝚖𝚎 and 𝚝𝚒𝚖𝚎_𝚌𝚕𝚘𝚜𝚎 of every bar on the chart, and there are 3 more overloads to this function that allow collecting and storing additional data.  Once a 𝙲𝚑𝚊𝚛𝚝𝙳𝚊𝚝𝚊 object is created, use any of the exported methods:

[*] Methods to convert a UNIX timestamp into a bar index or bar offset:
𝚝𝚒𝚖𝚎𝚜𝚝𝚊𝚖𝚙𝚃𝚘𝙱𝚊𝚛𝙸𝚗𝚍𝚎𝚡(), 𝚐𝚎𝚝𝙽𝚞𝚖𝚋𝚎𝚛𝙾𝚏𝙱𝚊𝚛𝚜𝙱𝚊𝚌𝚔()

[*] Methods to retrieve the stored data for a bar index:
𝚝𝚒𝚖𝚎𝙰𝚝𝙱𝚊𝚛𝙸𝚗𝚍𝚎𝚡(), 𝚝𝚒𝚖𝚎𝙲𝚕𝚘𝚜𝚎𝙰𝚝𝙱𝚊𝚛𝙸𝚗𝚍𝚎𝚡(), 𝚟𝚊𝚕𝚞𝚎𝙰𝚝𝙱𝚊𝚛𝙸𝚗𝚍𝚎𝚡(), 𝚐𝚎𝚝𝙰𝚕𝚕𝚅𝚊𝚛𝚒𝚊𝚋𝚕𝚎𝚜𝙰𝚝𝙱𝚊𝚛𝙸𝚗𝚍𝚎𝚡()

[*] Methods to retrieve the stored data at a number of bars back (i.e., historical offset):
𝚝𝚒𝚖𝚎(), 𝚝𝚒𝚖𝚎𝙲𝚕𝚘𝚜𝚎(), 𝚟𝚊𝚕𝚞𝚎()

[*] Methods to retrieve all the data points from the earliest bar (or latest bar) stored in memory, which can be useful for debugging purposes:
𝚐𝚎𝚝𝙴𝚊𝚛𝚕𝚒𝚎𝚜𝚝𝚂𝚝𝚘𝚛𝚎𝚍𝙳𝚊𝚝𝚊(), 𝚐𝚎𝚝𝙻𝚊𝚝𝚎𝚜𝚝𝚂𝚝𝚘𝚛𝚎𝚍𝙳𝚊𝚝𝚊()
Note: the library's strong suit is referencing data from very old bars in the past, which is especially useful for scripts that perform its necessary calculations only on the last bar.

█ USAGE

Step 1
Import the library.  Replace <version> with the latest available version number for this library.
[pine]
//@version=6
indicator("Usage")

import n00btraders/ChartData/<version>
[/pine]
Step 2
Create a 𝙲𝚑𝚊𝚛𝚝𝙳𝚊𝚝𝚊 object to collect data on every bar.  Do not declare as `var` or `varip`.
[pine]
chartData = ChartData.collectChartData()    // call on every bar to accumulate the necessary data
[/pine]
Step 3
Call any method(s) on the 𝙲𝚑𝚊𝚛𝚝𝙳𝚊𝚝𝚊 object.  Do not modify its fields directly.
[pine]
if barstate.islast
    int firstBarTime = chartData.timeAtBarIndex(0)
    int lastBarTime = chartData.time(0)
    log.info("First `time`: " + str.format_time(firstBarTime) + ", Last `time`: " + str.format_time(lastBarTime))
[/pine]

█ EXAMPLES

• Collect Future Times

The overloaded 𝚌𝚘𝚕𝚕𝚎𝚌𝚝𝙲𝚑𝚊𝚛𝚝𝙳𝚊𝚝𝚊() functions that accept a 𝚋𝚊𝚛𝚜𝙵𝚘𝚛𝚠𝚊𝚛𝚍 argument can additionally store time values for up to 500 bars into the future.
[image]https://www.tradingview.com/x/3CUAU2Wn/[/image][pine]
//@version=6
indicator("Example `collectChartData(barsForward)`")

import n00btraders/ChartData/1

chartData = ChartData.collectChartData(barsForward = 500)

var rectangle = box.new(na, na, na, na, xloc = xloc.bar_time, force_overlay = true)

if barstate.islast
    int futureTime = chartData.timeAtBarIndex(bar_index + 100)
    int lastBarTime = time
    box.set_lefttop(rectangle, lastBarTime, open)
    box.set_rightbottom(rectangle, futureTime, close)
    box.set_text(rectangle, "Extending box 100 bars to the right.  Time: " + str.format_time(futureTime))
[/pine]

• Collect Custom Data

The overloaded 𝚌𝚘𝚕𝚕𝚎𝚌𝚝𝙲𝚑𝚊𝚛𝚝𝙳𝚊𝚝𝚊() functions that accept a 𝚟𝚊𝚛𝚒𝚊𝚋𝚕𝚎𝚜 argument can additionally store custom user-specified values for every bar on the chart.
[image]https://www.tradingview.com/x/MLZtOK4A/[/image][pine]
//@version=6
indicator("Example `collectChartData(variables)`")

import n00btraders/ChartData/1

var map<string, float> variables = map.new<string, float>()

variables.put("open", open)
variables.put("close", close)
variables.put("open-close midpoint", (open + close) / 2)
variables.put("boolean", open > close ? 1 : 0)

chartData = ChartData.collectChartData(variables = variables)

var fgColor = chart.fg_color
var table1 = table.new(position.top_right, 2, 9, color(na), fgColor, 1, fgColor, 1, true)
var table2 = table.new(position.bottom_right, 2, 9, color(na), fgColor, 1, fgColor, 1, true)
if barstate.isfirst
    table.cell(table1, 0, 0, "ChartData.value()", text_color = fgColor)
    table.cell(table2, 0, 0, "open[offset]", text_color = fgColor)
    table.merge_cells(table1, 0, 0, 1, 0)
    table.merge_cells(table2, 0, 0, 1, 0)
    for i = 1 to 8
        table.cell(table1, 0, i, text_color = fgColor, text_halign = text.align_left, text_font_family = font.family_monospace)
        table.cell(table2, 0, i, text_color = fgColor, text_halign = text.align_left, text_font_family = font.family_monospace)
        table.cell(table1, 1, i, text_color = fgColor)
        table.cell(table2, 1, i, text_color = fgColor)

if barstate.islast
    for i = 1 to 8
        float open1 = chartData.value("open", 5000 * i)
        float open2 = i < 3 ? open[5000 * i] : -1
        table.cell_set_text(table1, 0, i, "chartData.value(\"open\", " + str.tostring(5000 * i) + "): ")
        table.cell_set_text(table2, 0, i, "open[" + str.tostring(5000 * i) + "]: ")
        table.cell_set_text(table1, 1, i, str.tostring(open1))
        table.cell_set_text(table2, 1, i, open2 >= 0 ? str.tostring(open2) : "Error")
[/pine]

• xloc.bar_index → xloc.bar_time

The 𝚝𝚒𝚖𝚎 value (or 𝚝𝚒𝚖𝚎_𝚌𝚕𝚘𝚜𝚎 value) can be retrieved for any bar index that is stored in memory by the 𝙲𝚑𝚊𝚛𝚝𝙳𝚊𝚝𝚊 object.
[image]https://www.tradingview.com/x/pxo2vqZd/[/image][pine]
//@version=6
indicator("Example `timeAtBarIndex()`")

import n00btraders/ChartData/1

chartData = ChartData.collectChartData()

if barstate.islast
    int start = bar_index - 15000
    int end = bar_index - 100

    // line.new(start, close, end, close)   // !ERROR - `start` value is too far from current bar index

    start := chartData.timeAtBarIndex(start)
    end := chartData.timeAtBarIndex(end)
    line.new(start, close, end, close, xloc.bar_time, width = 10)
[/pine]

• xloc.bar_time → xloc.bar_index

Use 𝚝𝚒𝚖𝚎𝚜𝚝𝚊𝚖𝚙𝚃𝚘𝙱𝚊𝚛𝙸𝚗𝚍𝚎𝚡() to find the bar that a timestamp belongs to.
If the timestamp falls in between the close of one bar and the open of the next bar,
the 𝚜𝚗𝚊𝚙 parameter can be used to determine which bar to choose:
𝚂𝚗𝚊𝚙.𝙻𝙴𝙵𝚃 - prefer to choose the leftmost bar (typically used for closing times)
𝚂𝚗𝚊𝚙.𝚁𝙸𝙶𝙷𝚃 - prefer to choose the rightmost bar (typically used for opening times)
𝚂𝚗𝚊𝚙.𝙳𝙴𝙵𝙰𝚄𝙻𝚃 (or 𝚗𝚊) - copies the same behavior as xloc.bar_time uses for drawing objects
[image]https://www.tradingview.com/x/ubQIlSQo/[/image][pine]
//@version=6
indicator("Example `timestampToBarIndex()`")

import n00btraders/ChartData/1

startTimeInput = input.time(timestamp("01 Aug 2025 08:30 -0500"), "Session Start Time")
endTimeInput = input.time(timestamp("01 Aug 2025 15:15 -0500"), "Session End Time")

chartData = ChartData.collectChartData()

if barstate.islastconfirmedhistory
    int startBarIndex = chartData.timestampToBarIndex(startTimeInput, ChartData.Snap.RIGHT)
    int endBarIndex = chartData.timestampToBarIndex(endTimeInput, ChartData.Snap.LEFT)

    line1 = line.new(startBarIndex, 0, startBarIndex, 1, extend = extend.both, color = color.new(color.green, 60), force_overlay = true)
    line2 = line.new(endBarIndex, 0, endBarIndex, 1, extend = extend.both, color = color.new(color.green, 60), force_overlay = true)
    linefill.new(line1, line2, color.new(color.green, 90))

    // using Snap.DEFAULT to show that it is equivalent to drawing lines using `xloc.bar_time` (i.e., it aligns to the same bars)
    startBarIndex := chartData.timestampToBarIndex(startTimeInput)
    endBarIndex := chartData.timestampToBarIndex(endTimeInput)
    line.new(startBarIndex, 0, startBarIndex, 1, extend = extend.both, color = color.yellow, width = 3)
    line.new(endBarIndex, 0, endBarIndex, 1, extend = extend.both, color = color.yellow, width = 3)

    line.new(startTimeInput, 0, startTimeInput, 1, xloc.bar_time, extend.both, color.new(color.blue, 85), width = 11)
    line.new(endTimeInput, 0, endTimeInput, 1, xloc.bar_time, extend.both, color.new(color.blue, 85), width = 11)
[/pine]

• Get Price of Line at Timestamp

The pine script built-in function [line.get_price()](https://www.tradingview.com/pine-script-reference/v6/#fun_line.get_price) requires working with bar index values.  To get the price of a line in terms of a timestamp, convert the timestamp into a bar index or offset.
[image]https://www.tradingview.com/x/qKOHufyl/[/image][pine]
//@version=6
indicator("Example `line.get_price()` at timestamp")

import n00btraders/ChartData/1

lineStartInput = input.time(timestamp("01 Aug 2025 08:30 -0500"), "Line Start")

chartData = ChartData.collectChartData()

var diagonal = line.new(na, na, na, na, force_overlay = true)
if time <= lineStartInput
    line.set_xy1(diagonal, bar_index, open)
if barstate.islastconfirmedhistory
    line.set_xy2(diagonal, bar_index, close)

if barstate.islast
    int timeOneWeekAgo = timenow - (7 * timeframe.in_seconds("1D") * 1000)

    // Note: could also use `timetampToBarIndex(timeOneWeekAgo, Snap.DEFAULT)` and pass the value directly to `line.get_price()`
    int barsOneWeekAgo = chartData.getNumberOfBarsBack(timeOneWeekAgo)

    float price = line.get_price(diagonal, bar_index - barsOneWeekAgo)

    string formatString = "Time 1 week ago:  {0,number,#}\n    - Equivalent to {1} bars ago\n\n𝚕𝚒𝚗𝚎.𝚐𝚎𝚝_𝚙𝚛𝚒𝚌𝚎():  {2,number,#.##}"
    string labelText = str.format(formatString, timeOneWeekAgo, barsOneWeekAgo, price)
    label.new(timeOneWeekAgo, price, labelText, xloc.bar_time, style = label.style_label_lower_right, size = 16, textalign = text.align_left, force_overlay = true)
[/pine]

█ RUNTIME ERROR MESSAGES

This library's functions will generate a custom runtime error message in the following cases:

[*] 𝚌𝚘𝚕𝚕𝚎𝚌𝚝𝙲𝚑𝚊𝚛𝚝𝙳𝚊𝚝𝚊() is not called consecutively, or is called more than once on a single bar
[*] Invalid 𝚋𝚊𝚛𝚜𝙵𝚘𝚛𝚠𝚊𝚛𝚍 argument in the 𝚌𝚘𝚕𝚕𝚎𝚌𝚝𝙲𝚑𝚊𝚛𝚝𝙳𝚊𝚝𝚊() function
[*] Invalid 𝚟𝚊𝚛𝚒𝚊𝚋𝚕𝚎𝚜 argument in the 𝚌𝚘𝚕𝚕𝚎𝚌𝚝𝙲𝚑𝚊𝚛𝚝𝙳𝚊𝚝𝚊() function
[*] Invalid 𝚕𝚎𝚗𝚐𝚝𝚑 argument in any of the functions that accept a number of bars back
Note: there is no runtime error generated for an invalid 𝚝𝚒𝚖𝚎𝚜𝚝𝚊𝚖𝚙 or 𝚋𝚊𝚛𝙸𝚗𝚍𝚎𝚡 argument in any of the functions.  Instead, the functions will assign 𝚗𝚊 to the returned values.
Any other runtime errors are due to incorrect usage of the library.

█ NOTES

• Function Descriptions

The library source code uses [Markdown](https://www.tradingview.com/script/b6aw56xH-Markdown-The-Pine-Editor-s-Hidden-Gem/) for the exported functions.  Hover over a function/method call in the Pine Editor to display formatted, detailed information about the function/method.
[image]https://www.tradingview.com/x/jRjMwvBY/[/image][pine]
//@version=6
indicator("Demo Function Tooltip")

import n00btraders/ChartData/1

chartData = ChartData.collectChartData()

int barIndex = chartData.timestampToBarIndex(timenow)

log.info(str.tostring(barIndex))
[/pine]

• Historical vs. Realtime Behavior

Under the hood, the data collector for this library is declared as `var`.  Because of this, the 𝙲𝚑𝚊𝚛𝚝𝙳𝚊𝚝𝚊 object will always reflect the latest available data on realtime updates.  Any data that is recorded for historical bars will remain unchanged throughout the execution of a script.
[image]https://www.tradingview.com/x/pMytB9Yd/[/image][pine]
//@version=6
indicator("Demo Realtime Behavior")

import n00btraders/ChartData/1

var map<string, float> variables = map.new<string, float>()
variables.put("open", open)
variables.put("close", close)

chartData = ChartData.collectChartData(variables)

if barstate.isrealtime
    varip float initialOpen = open
    varip float initialClose = close

    varip int updateCount = 0
    updateCount += 1

    float latestOpen = open
    float latestClose = close

    float recordedOpen = chartData.valueAtBarIndex("open", bar_index)
    float recordedClose = chartData.valueAtBarIndex("close", bar_index)

    string formatString = "# of updates:  {0}\n\n𝚘𝚙𝚎𝚗 at update #1:  {1,number,#.##}\n𝚌𝚕𝚘𝚜𝚎 at update #1:  {2,number,#.##}\n\n"
           + "𝚘𝚙𝚎𝚗 at update #{0}:  {3,number,#.##}\n𝚌𝚕𝚘𝚜𝚎 at update #{0}:  {4,number,#.##}\n\n"
           + "𝚘𝚙𝚎𝚗 stored in memory:  {5,number,#.##}\n𝚌𝚕𝚘𝚜𝚎 stored in memory:  {6,number,#.##}"
    string labelText = str.format(formatString, updateCount, initialOpen, initialClose, latestOpen, latestClose, recordedOpen, recordedClose)
    label.new(bar_index, close, labelText, style = label.style_label_left, force_overlay = true)
[/pine]

• Collecting Chart Data for Other Contexts

If your use case requires collecting chart data from another context, avoid directly retrieving the 𝙲𝚑𝚊𝚛𝚝𝙳𝚊𝚝𝚊 object as this may [exceed memory limits](https://www.tradingview.com/pine-script-docs/error-messages/#memory-limits-exceeded).
[image]https://www.tradingview.com/x/lqnV1pZ9/[/image][pine]
//@version=6
indicator("Demo Return Calculated Results")

import n00btraders/ChartData/1

timeInput = input.time(timestamp("01 Sep 2025 08:30 -0500"), "Time")

var int oneMinuteBarsAgo = na

// !ERROR - Memory Limits Exceeded
// chartDataArray = request.security_lower_tf(syminfo.tickerid, "1", ChartData.collectChartData())
// oneMinuteBarsAgo := chartDataArray.last().getNumberOfBarsBack(timeInput)

// function that returns calculated results (a single integer value instead of an entire `ChartData` object)
getNumberOfBarsBack() =>
    chartData = ChartData.collectChartData()
    chartData.getNumberOfBarsBack(timeInput)
calculatedResultsArray = request.security_lower_tf(syminfo.tickerid, "1", getNumberOfBarsBack())
oneMinuteBarsAgo := calculatedResultsArray.size() > 0 ? calculatedResultsArray.last() : na

if barstate.islast
    string labelText = str.format("The selected timestamp occurs  [{0}]  1-minute bars ago", oneMinuteBarsAgo)
    label.new(bar_index, hl2, labelText, style = label.style_label_left, size = 16, force_overlay = true)
[/pine]

• Memory Usage

The library's convenience and ease of use comes at the cost of increased usage of computational resources.  For simple scripts, using this library will likely not cause any issues with exceeding memory limits.  But for large and complex scripts, you can [reduce memory issues](https://www.tradingview.com/pine-script-docs/error-messages/#minimize-historical-buffer-calculations) by specifying a lower 𝚌𝚊𝚕𝚌_𝚋𝚊𝚛𝚜_𝚌𝚘𝚞𝚗𝚝 amount in the [indicator()](https://www.tradingview.com/pine-script-reference/v6/#fun_indicator) or [strategy()](https://www.tradingview.com/pine-script-reference/v6/#fun_strategy) declaration statement.
[image]https://www.tradingview.com/x/rHxuC0bx/[/image][pine]
//@version=6

// !ERROR - Memory Limits Exceeded using the default number of bars available (~20,000 bars for Premium plans)
//indicator("Demo `calc_bars_count` parameter")

// Reduce number of bars using `calc_bars_count` parameter
indicator("Demo `calc_bars_count` parameter", calc_bars_count = 15000)

import n00btraders/ChartData/1

map<string, float> variables = map.new<string, float>()
variables.put("open", open)
variables.put("close", close)
variables.put("weekofyear", weekofyear)
variables.put("dayofmonth", dayofmonth)
variables.put("hour", hour)
variables.put("minute", minute)
variables.put("second", second)

// simulate large memory usage
chartData0 = ChartData.collectChartData(variables)
chartData1 = ChartData.collectChartData(variables)
chartData2 = ChartData.collectChartData(variables)
chartData3 = ChartData.collectChartData(variables)
chartData4 = ChartData.collectChartData(variables)
chartData5 = ChartData.collectChartData(variables)
chartData6 = ChartData.collectChartData(variables)
chartData7 = ChartData.collectChartData(variables)
chartData8 = ChartData.collectChartData(variables)
chartData9 = ChartData.collectChartData(variables)
log.info(str.tostring(chartData0.time(0)))
log.info(str.tostring(chartData1.time(0)))
log.info(str.tostring(chartData2.time(0)))
log.info(str.tostring(chartData3.time(0)))
log.info(str.tostring(chartData4.time(0)))
log.info(str.tostring(chartData5.time(0)))
log.info(str.tostring(chartData6.time(0)))
log.info(str.tostring(chartData7.time(0)))
log.info(str.tostring(chartData8.time(0)))
log.info(str.tostring(chartData9.time(0)))

if barstate.islast
    result = table.new(position.middle_right, 1, 1, force_overlay = true)
    table.cell(result, 0, 0, "Script Execution Successful ✅", text_size = 40)
[/pine]

█ EXPORTED ENUMS

Snap
  Behavior for determining the bar that a timestamp belongs to.
  Fields:
    LEFT: Snap to the leftmost bar.
    RIGHT: Snap to the rightmost bar.
    DEFAULT: Default `xloc.bar_time` behavior.
Note: this enum is used for the 𝚜𝚗𝚊𝚙 parameter of 𝚝𝚒𝚖𝚎𝚜𝚝𝚊𝚖𝚙𝚃𝚘𝙱𝚊𝚛𝙸𝚗𝚍𝚎𝚡().

█ EXPORTED TYPES

Note: users of the library do not need to worry about directly accessing the fields of these types; all computations are done through method calls on an object of the 𝙲𝚑𝚊𝚛𝚝𝙳𝚊𝚝𝚊 type.

Variable
  Represents a user-specified variable that can be tracked on every chart bar.
  Fields:
    name (series string): Unique identifier for the variable.
    values (array<float>): The array of stored values (one value per chart bar).

ChartData
  Represents data for all bars on a chart.
  Fields:
    bars (series int): Current number of bars on the chart.
    timeValues (array<int>): The `time` values of all chart (and future) bars.
    timeCloseValues (array<int>): The `time_close` values of all chart (and future) bars.
    variables (array<Variable>): Additional custom values to track on all chart bars.

█ EXPORTED FUNCTIONS

collectChartData()
  Collects and tracks the `time` and `time_close` value of every bar on the chart.
  Returns: `ChartData` object to convert between `xloc.bar_index` and `xloc.bar_time`.

collectChartData(barsForward)
  Collects and tracks the `time` and `time_close` value of every bar on the chart as well as a specified number of future bars.
  Parameters:
    barsForward (simple int): Number of future bars to collect data for.
  Returns: `ChartData` object to convert between `xloc.bar_index` and `xloc.bar_time`.

collectChartData(variables)
  Collects and tracks the `time` and `time_close` value of every bar on the chart.  Additionally, tracks a custom set of variables for every chart bar.
  Parameters:
    variables (simple map<string, float>): Custom values to collect on every chart bar.
  Returns: `ChartData` object to convert between `xloc.bar_index` and `xloc.bar_time`.

collectChartData(barsForward, variables)
  Collects and tracks the `time` and `time_close` value of every bar on the chart as well as a specified number of future bars.  Additionally, tracks a custom set of variables for every chart bar.
  Parameters:
    barsForward (simple int): Number of future bars to collect data for.
    variables (simple map<string, float>): Custom values to collect on every chart bar.
  Returns: `ChartData` object to convert between `xloc.bar_index` and `xloc.bar_time`.

█ EXPORTED METHODS

method timestampToBarIndex(chartData, timestamp, snap)
  Converts a UNIX timestamp to a bar index.
  Namespace types: ChartData
  Parameters:
    chartData (series ChartData): The `ChartData` object.
    timestamp (series int): A UNIX time.
    snap (series Snap): A `Snap` enum value.
  Returns: A bar index, or `na` if unable to find the appropriate bar index.

method getNumberOfBarsBack(chartData, timestamp)
  Converts a UNIX timestamp to a history-referencing length (i.e., number of bars back).
  Namespace types: ChartData
  Parameters:
    chartData (series ChartData): The `ChartData` object.
    timestamp (series int): A UNIX time.
  Returns: A bar offset, or `na` if unable to find a valid number of bars back.

method timeAtBarIndex(chartData, barIndex)
  Retrieves the `time` value for the specified bar index.
  Namespace types: ChartData
  Parameters:
    chartData (series ChartData): The `ChartData` object.
    barIndex (int): The bar index.
  Returns: The `time` value, or `na` if there is no `time` stored for the bar index.

method time(chartData, length)
  Retrieves the `time` value of the bar that is `length` bars back relative to the latest bar.
  Namespace types: ChartData
  Parameters:
    chartData (series ChartData): The `ChartData` object.
    length (series int): Number of bars back.
  Returns: The `time` value `length` bars ago, or `na` if there is no `time` stored for that bar.

method timeCloseAtBarIndex(chartData, barIndex)
  Retrieves the `time_close` value for the specified bar index.
  Namespace types: ChartData
  Parameters:
    chartData (series ChartData): The `ChartData` object.
    barIndex (series int): The bar index.
  Returns: The `time_close` value, or `na` if there is no `time_close` stored for the bar index.

method timeClose(chartData, length)
  Retrieves the `time_close` value of the bar that is `length` bars back from the latest bar.
  Namespace types: ChartData
  Parameters:
    chartData (series ChartData): The `ChartData` object.
    length (series int): Number of bars back.
  Returns: The `time_close` value `length` bars ago, or `na` if there is none stored.

method valueAtBarIndex(chartData, name, barIndex)
  Retrieves the value of a custom variable for the specified bar index.
  Namespace types: ChartData
  Parameters:
    chartData (series ChartData): The `ChartData` object.
    name (series string): The variable name.
    barIndex (series int): The bar index.
  Returns: The value of the variable, or `na` if that variable is not stored for the bar index.

method value(chartData, name, length)
  Retrieves a variable value of the bar that is `length` bars back relative to the latest bar.
  Namespace types: ChartData
  Parameters:
    chartData (series ChartData): The `ChartData` object.
    name (series string): The variable name.
    length (series int): Number of bars back.
  Returns: The value `length` bars ago, or `na` if that variable is not stored for the bar index.

method getAllVariablesAtBarIndex(chartData, barIndex)
  Retrieves all custom variables for the specified bar index.
  Namespace types: ChartData
  Parameters:
    chartData (series ChartData): The `ChartData` object.
    barIndex (series int): The bar index.
  Returns: Map of all custom variables that are stored for the specified bar index.

method getEarliestStoredData(chartData)
  Gets all values from the earliest bar data that is currently stored in memory.
  Namespace types: ChartData
  Parameters:
    chartData (series ChartData): The `ChartData` object.
  Returns: A tuple: [barIndex, time, timeClose, variables]

method getLatestStoredData(chartData, futureData)
  Gets all values from the latest bar data that is currently stored in memory.
  Namespace types: ChartData
  Parameters:
    chartData (series ChartData): The `ChartData` object.
    futureData (series bool): Whether to include the future data that is stored in memory.
  Returns: A tuple: [barIndex, time, timeClose, variables]

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © n00btraders

//@version=6

// @description  Library to convert a bar index to a timestamp and vice versa.
// Utilizes runtime memory to store the `time` and `time_close` values of every bar on the chart (and optional future bars),
// with the ability of storing additional custom values for every chart bar.
library("ChartData")




//#region ------------------------------ Constants ------------------------------

const int MAX_ARRAY_SIZE = 100000       // pine script limit for size of arrays

const int MAX_BARS_FORWARD = 500        // maximum number of future bars that can be retrieved by time() & time_close()

const int MIN_BARS_FORWARD = 0          // minimum allowed value for `barsForward` argument in this library's functions

const int DATA_LIMIT = MAX_ARRAY_SIZE - MAX_BARS_FORWARD    // custom array size limit, leaving room for future bar data

// @enum           Behavior for determining the bar that a timestamp belongs to.
//
// @field LEFT     Snap to the leftmost bar.
// @field RIGHT    Snap to the rightmost bar.
// @field DEFAULT  Default `xloc.bar_time` behavior.
export enum Snap
    LEFT
    RIGHT
    DEFAULT

//#endregion




//#region ------------------------------ Types ------------------------------

// @type          Represents a user-specified variable that can be tracked on every chart bar.
//
// @field name    Unique identifier for the variable.
// @field values  The array of stored values (one value per chart bar).
export type Variable
    string name
    array<float> values


// @type                   Represents data for all bars on a chart.
//                         Note: future values of `time` and `time_close` can be retrieved via
//                         the `time()` and `time_close()` pine script built-in functions.
//                         But future values of custom variables cannot be known for bars it has not yet executed on,
//                         therefore the `timeValues` and `timeCloseValues` arrays may contain up to `MAX_BARS_FORWARD`
//                         more elements than the `values` array of a Variable object.
//
// @field bars             Current number of bars on the chart.
// @field timeValues       The `time` values of all chart bars (and some future bars).
// @field timeCloseValues  The `time_close` values of all chart bars (and some future bars).
// @field variables        Additional custom values to track on all chart bars.
export type ChartData
    int bars
    array<int> timeValues
    array<int> timeCloseValues
    array<Variable> variables

//#endregion




//#region ------------------------------ Non-Exported Functions ------------------------------

// @function           Validates `collectChartData()` function arguments.
//                         1. `barsForward` argument must be in the range of `MIN_BARS_FORWARD` to `MAX_BARS_FORWARD`
//                         2. `variables` map must have non-empty strings for all keys (if any)
//                     Note: validation is only necessary on the first execution of `collectChartData()`
//                     because all subsequent executions will only use the arguments from the first execution.
//
// @param barsForward  (simple int) Number of future bars to collect data for.
// @param variables    (simple map<string, float>) Custom values to collect on every chart bar.
// @returns            (void) Generates a runtime error message if the arguments are not valid.
validateArguments(simple int barsForward, simple map<string, float> variables) =>
    if nz(barsForward, -1) < MIN_BARS_FORWARD or nz(barsForward, -1) > MAX_BARS_FORWARD
        string message = "Invalid value for the 𝚋𝚊𝚛𝚜𝙵𝚘𝚛𝚠𝚊𝚛𝚍 argument. "
               + "                Expected: >= {0} and <= {1}      Actual: {2}"
        runtime.error(str.format(message, MIN_BARS_FORWARD, MAX_BARS_FORWARD, barsForward))

    if not na(variables)
        for [i, name] in variables.keys()
            if na(str.trim(name))
                string message = "Invalid value for the 𝚟𝚊𝚛𝚒𝚊𝚋𝚕𝚎𝚜 argument. "
                       + "         Map keys cannot be empty.                    Revise key #{0}"
                runtime.error(str.format(message, i + 1))



// @function      Validates the `length` argument of the `time()`, `timeClose()`, and `value()` library functions.
//
// @param length  (series int) Number of bars back.
// @returns       (void) Generates a runtime error message if the argument is not valid.
method validateHistoryReference(series int length) =>
    if nz(length, -1) < 0
        runtime.error("The history-referencing length for the data must be a value >= 0")



// @function  Validates `collectChartData()` executes exactly 1 time per bar to ensure the accuracy of the stored data.
//
// @returns   (void) Generates a runtime error message if `collectChartData()` is not called once per bar.
method validateBarCount(series ChartData chartData) =>
    if chartData.bars != bar_index
        runtime.error("𝚌𝚘𝚕𝚕𝚎𝚌𝚝𝙲𝚑𝚊𝚛𝚝𝙳𝚊𝚝𝚊() must be called one time on every bar")
    chartData.bars += 1



// @function           Creates and initializes a `ChartData` object.
//
// @param barsForward  (simple int) Number of future bars to collect data for.
// @param variables    (simple map<string, float>) Custom values to collect on every chart bar.
// @returns            New `ChartData` object.
initializeChartData(simple int barsForward, simple map<string, float> variables) =>
    ChartData data = ChartData.new(bars = 0, timeValues = array.new<int>(), timeCloseValues = array.new<int>())

    validateArguments(barsForward, variables)

    if barsForward > 0
        // start at future bar #0 (current bar) to use it as a placeholder that will be replaced on the first bar
        // end at `barsForward - 1` because the future bar at `barsForward - 0` will be added by `collectChartData()`
        for i = 0 to barsForward - 1
            data.timeValues.push(time(timeframe.period, bars_back = -i))
            data.timeCloseValues.push(time_close(timeframe.period, bars_back = -i))

    if not na(variables) and variables.size() > 0
        data.variables := array.new<Variable>()     // optimize memory usage by conditionally initializing this array
        for name in variables.keys()
            data.variables.push(Variable.new(name, values = array.new<float>()))

    data



// @function           Updates the `time` and `time_close` arrays of a `ChartData` object.
//
// @param chartData    (series ChartData) The `ChartData` object.
// @param barsForward  (simple int) Number of future bars to collect data for.
// @returns            The same object from the `chartData` argument.
method updateTimestamps(series ChartData chartData, simple int barsForward) =>
    if chartData.bars > DATA_LIMIT
        chartData.timeValues.shift()
        chartData.timeCloseValues.shift()

    if barsForward > 0
        // update the previously forecasted time values for this [current] bar with the actual values
        int index = chartData.timeValues.size() - barsForward
        chartData.timeValues.set(index, time)
        chartData.timeCloseValues.set(index, time_close)

        // add a new set of forecasted time values to the end of the arrays
        chartData.timeValues.push(time(timeframe.period, bars_back = -barsForward))
        chartData.timeCloseValues.push(time_close(timeframe.period, bars_back = -barsForward))
    else
        chartData.timeValues.push(time)
        chartData.timeCloseValues.push(time_close)

    chartData



// @function         Updates the `variables` array of a `ChartData` object.
//
// @param chartData  (series ChartData) The `ChartData` object.
// @param barData    (simple map<string, float>) Map of user-specified values that belong to the current bar.
// @returns          The same object from the `chartData` argument.
method updateVariables(series ChartData chartData, simple map<string, float> barData) =>
    if not na(chartData.variables)
        for variable in chartData.variables
            if chartData.bars > DATA_LIMIT
                variable.values.shift()
            variable.values.push(na(barData) ? na : barData.get(variable.name))
    chartData



// @function         Converts a bar index value to the equivalent index in the arrays of a `ChartData` object.
//                   Note: the `barIndex` argument may be `na`, but the result of this function will not be `na`.
//
// @param barIndex   (series int) The bar index.
// @param chartData  (series ChartData) The `ChartData` object.
// @returns          Array index, or a negative value if the return value is not used (caller must verify index >= 0).
method toArrayIndex(series int barIndex, series ChartData chartData) =>
    int shifted = chartData.bars - DATA_LIMIT                   // number of times `array.shift()` was called
    shifted > 0 ? nz(barIndex) - shifted : nz(barIndex, -1)     // `shifted` is <= 0 if no data has been deleted yet



// @function          Converts an array index (from the arrays of a `ChartData` object) to the equivalent bar index.
//
// @param arrayIndex  (series int) The array index.
// @param chartData   (series ChartData) The `ChartData` object.
// @returns           The `bar_index` of the bar that is associated with the data stored at the specified array index.
method toBarIndex(series int arrayIndex, series ChartData chartData) =>
    int shifted = chartData.bars - DATA_LIMIT                   // number of times `array.shift()` was called
    shifted > 0 ? arrayIndex + shifted : arrayIndex             // `shifted` is <= 0 if no data has been deleted yet

//#endregion




//#region ------------------------------ Exported Functions ------------------------------

// @function  Collects and tracks the `time` and `time_close` value of every bar on the chart.
// ___
// **Remarks** \
// This function must be called on every bar to ensure the accuracy of the stored data. \
// \
// This function stores up to ~100,000 elements (per data point) in memory. \
// In most cases, this limit is enough to cover the number of
// [chart bars](https://www.tradingview.com/pine-script-docs/writing/limitations/#chart-bars). \
// But if the limit is reached, the oldest stored data will be deleted to make room for the data on newer bars.
// ___
// @returns  A `ChartData` object that can be used to convert between `xloc.bar_index` and `xloc.bar_time` values.
export collectChartData() =>
    var ChartData data = initializeChartData(barsForward = 0, variables = na)

    data.validateBarCount()

    if data.bars > DATA_LIMIT               //|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
        data.timeValues.shift()             //|                                                                   |
        data.timeCloseValues.shift()        //|                                                                   |
                                            //|  This block of code is equivalent to `data.updateTimestamps(0)`,  |
    data.timeValues.push(time)              //|  but it is explicitly written out for understandability           |
    data.timeCloseValues.push(time_close)   //|                                                                   |
                                            //|                                                                   |
    data                                    //|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||



// @function  Collects and tracks the `time` and `time_close` value of every bar on the chart
//            as well as a specified number of future bars.
// ___
// **Parameters**
// ```
// • simple int barsForward
// ```
// `barsForward` - Number of future bars to the right of the latest bar.  Value must be >= 0 and <= 500.
// ___
// **Remarks** \
// This function must be called on every bar to ensure the accuracy of the stored data. \
// \
// This function stores up to ~100,000 elements (per data point) in memory. \
// In most cases, this limit is enough to cover the number of
// [chart bars](https://www.tradingview.com/pine-script-docs/writing/limitations/#chart-bars). \
// But if the limit is reached, the oldest stored data will be deleted to make room for the data on newer bars.
// ___
// @param barsForward  (simple int) Number of future bars to collect data for.
// @returns            A `ChartData` object that can be used to convert between `xloc.bar_index` and `xloc.bar_time` values.
export collectChartData(simple int barsForward) =>
    var ChartData data = initializeChartData(barsForward = barsForward, variables = na)
    data.validateBarCount()
    data.updateTimestamps(barsForward)



// @function  Collects and tracks the `time` and `time_close` value of every bar on the chart. \
//            Additionally, tracks a custom set of variables for every chart bar.
// ___
// **Parameters**
// ```
// • simple map<string, float> variables
// ```
// `variables` - Map of variable names & values that belong to the current bar. \
// An empty or [na](https://www.tradingview.com/pine-script-reference/v6/#var_na) map will not track additional values.
// Any keys in the map must be non-empty strings.
// ___
// **Remarks** \
// This function must be called on every bar to ensure the accuracy of the stored data. \
// \
// This function stores up to ~100,000 elements (per data point) in memory. \
// In most cases, this limit is enough to cover the number of
// [chart bars](https://www.tradingview.com/pine-script-docs/writing/limitations/#chart-bars). \
// But if the limit is reached, the oldest stored data will be deleted to make room for the data on newer bars. \
// \
// Parameter `variables`: only the variable names from the first execution of this function will be tracked; \
// subsequent function calls will ignore any new key/value pairs that did not exist during the initial execution.
// ___
// @param variables  (simple map<string, float>) Custom values to collect on every chart bar.
// @returns          A `ChartData` object that can be used to convert between `xloc.bar_index` and `xloc.bar_time` values.
export collectChartData(simple map<string, float> variables) =>
    var ChartData data = initializeChartData(barsForward = 0, variables = variables)
    data.validateBarCount()
    data.updateTimestamps(0).updateVariables(variables)



// @function  Collects and tracks the `time` and `time_close` value of every bar on the chart
//            as well as a specified number of future bars. \
//            Additionally, tracks a custom set of variables for every chart bar.
// ___
// **Parameters**
// ```
// • simple int barsForward
// • simple map<string, float> variables
// ```
// `barsForward` - Number of future bars to the right of the latest bar.  Value must be >= 0 and <= 500. \
// `variables` - Map of variable names & values that belong to the current bar. \
// An empty or [na](https://www.tradingview.com/pine-script-reference/v6/#var_na) map will not track additional values.
// Any keys in the map must be non-empty strings.
// ___
// **Remarks** \
// This function must be called on every bar to ensure the accuracy of the stored data. \
// \
// This function stores up to ~100,000 elements (per data point) in memory. \
// In most cases, this limit is enough to cover the number of
// [chart bars](https://www.tradingview.com/pine-script-docs/writing/limitations/#chart-bars). \
// But if the limit is reached, the oldest stored data will be deleted to make room for the data on newer bars. \
// \
// Parameter `barsForward`: any data retrieved from future bars (i.e., bars that have not yet formed on the chart) \
// is limited to [time](https://www.tradingview.com/pine-script-reference/v6/#var_time) and
// [time_close](https://www.tradingview.com/pine-script-reference/v6/#var_time_close) values.
// Future data cannot be retrieved for any of the custom variables. \
// \
// Parameter `variables`: only the variable names from the first execution of this function will be tracked; \
// subsequent function calls will ignore any new key/value pairs that did not exist during the initial execution.
// ___
// @param barsForward  (simple int) Number of future bars to collect data for.
// @param variables    (simple map<string, float>) Custom values to collect on every chart bar.
// @returns            A `ChartData` object that can be used to convert between `xloc.bar_index` and `xloc.bar_time` values.
export collectChartData(simple int barsForward, simple map<string, float> variables) =>
    var ChartData data = initializeChartData(barsForward, variables)
    data.validateBarCount()
    data.updateTimestamps(barsForward).updateVariables(variables)



// @function  Converts a UNIX timestamp to a bar index. \
//            Returns [na](https://www.tradingview.com/pine-script-reference/v6/#var_na)
//            if the timestamp does not belong to any bar index that is stored in memory.
// ___
// **Parameters**
// ```
// • series int timestamp
// • series Snap snap
// ```
// `timestamp` - The UNIX timestamp (in milliseconds). \
// `snap`      - The preferred behavior of snapping to the left or right when the timestamp is in between two bars.
//               The default is 𝚂𝚗𝚊𝚙.𝙳𝙴𝙵𝙰𝚄𝙻𝚃.
// ___
// **Snap** \
// The `snap` parameter determines the behavior when there may be ambiguity in the resulting bar index \
// (i.e., when the timestamp is in between the closing time of one bar and the opening time of the next bar). \
// \
// \
// • 𝚂𝚗𝚊𝚙.𝙻𝙴𝙵𝚃 : \
// Prefer to snap to the leftmost bar. \
// Suitable for handling [time_close](https://www.tradingview.com/pine-script-reference/v6/#var_time_close)
// values (e.g., getting the bar index for the _closing_ time of a session). \
// \
// • 𝚂𝚗𝚊𝚙.𝚁𝙸𝙶𝙷𝚃 : \
// Prefer to snap to the rightmost bar. \
// Suitable for handling [time](https://www.tradingview.com/pine-script-reference/v6/#var_time)
// values (e.g., getting the bar index for the _opening_ time of a session). \
// \
// • 𝚂𝚗𝚊𝚙.𝙳𝙴𝙵𝙰𝚄𝙻𝚃 : \
// Always snap to the rightmost bar. \
// Suitable for aligning timestamps to bar indexes the same way TradingView does when drawing with
// [xloc.bar_time](https://www.tradingview.com/pine-script-reference/v6/#const_xloc.bar_time). \
// \
// \
// Key Differences:
// 1. If a `timestamp` falls somewhere in the middle of a bar, \
//    𝚂𝚗𝚊𝚙.𝙻𝙴𝙵𝚃 and 𝚂𝚗𝚊𝚙.𝚁𝙸𝙶𝙷𝚃 will both align to that bar, \
//    whereas 𝚂𝚗𝚊𝚙.𝙳𝙴𝙵𝙰𝚄𝙻𝚃 will snap to the next bar on the right.
// 2. If a `timestamp` exactly matches the closing time of bar #1 and also the opening time of bar #2, \
//    𝚂𝚗𝚊𝚙.𝙻𝙴𝙵𝚃 will snap to bar #1, whereas 𝚂𝚗𝚊𝚙.𝚁𝙸𝙶𝙷𝚃 and 𝚂𝚗𝚊𝚙.𝙳𝙴𝙵𝙰𝚄𝙻𝚃 will snap to bar #2. \
//    Note: same snapping behavior applies if there is a time gap between the closing time of bar #1 \
//    and the opening time of bar #2 and the `timestamp` happens to fall inside of that time gap.
// ___
// @param chartData  (series ChartData) The `ChartData` object.
// @param timestamp  (series int) A UNIX time.
// @param snap       (series Snap) A `Snap` enum value.
// @returns          A bar index, or `na` if unable to find the appropriate bar index.
export method timestampToBarIndex(series ChartData chartData, series int timestamp, series Snap snap = Snap.DEFAULT) =>
    int arrayIndex = na

    // Note: this function works on the premise that the following are true for both arrays:
    //   1.  array size is >= 1
    //   2.  array elements are sorted in ascending order
    //   3.  for each index 'i', `timeCloseValues.get(i)` <= `timeValues.get(i + 1)`
    array<int> timeValues = chartData.timeValues
    array<int> timeCloseValues = chartData.timeCloseValues

    if na(timestamp)
        arrayIndex := na

    else if snap == Snap.LEFT

        int index = timeCloseValues.binary_search_leftmost(timestamp)

        // Special condition where the timestamp may be in the middle of the earliest bar that is stored in memory.
        // Note: `array.binary_search_leftmost()` returns 0 instead of -1 if the value is smaller than all array items
        if index == 0 and timestamp < timeCloseValues.get(index)
            arrayIndex := timestamp > timeValues.get(index) ? index : na

        // Condition where timestamp may be after latest stored time; avoids out of bounds error in the final branch
        else if index == timeCloseValues.size() - 1
            arrayIndex := timestamp == timeCloseValues.get(index) ? index : na

        // Final condition to increase the index by 1 if the timestamp is between the open and close of the next bar
        else
            arrayIndex := timestamp > timeValues.get(index + 1) ? index + 1 : index


    else if snap == Snap.RIGHT

        int index = timeValues.binary_search_rightmost(timestamp)

        // Unlike `array.binary_search_leftmost()`, the `array.binary_search_rightmost()` function can return an index
        // that is 1 higher than the largest valid index.  Check this as the 1st condition to avoid out of bounds error
        if index == timeValues.size() and timestamp >= timeCloseValues.get(index - 1)
            arrayIndex := na

        // Condition where timestamp may be before earliest stored time; avoids out of bounds error in the final branch
        else if index == 0
            arrayIndex := timestamp == timeValues.get(index) ? index : na

        // Final condition to reduce the index by 1 if the timestamp is between the open and close of the previous bar
        else
            arrayIndex := timestamp < timeCloseValues.get(index - 1) ? index - 1 : index


    else // Snap.DEFAULT
        int index = timeValues.binary_search_rightmost(timestamp)
        arrayIndex := timestamp < timeValues.first() or timestamp > timeValues.last() ? na : index

    na(arrayIndex) ? na : arrayIndex.toBarIndex(chartData)



// @function  Converts a UNIX timestamp to a history-referencing length (i.e., number of bars back).
// ___
// **Parameters**
// ```
// • series int timestamp
// ```
// `timestamp` - The UNIX timestamp (in milliseconds).
// ___
// **Remarks** \
// The return value can be used in any function that accepts a history-referencing length, \
// including the [[] history-referencing operator](https://www.tradingview.com/pine-script-reference/v6/#op_%5B%5D). \
// \
// Returns [na](https://www.tradingview.com/pine-script-reference/v6/#var_na)
// if the timestamp does not belong to any bar data that is stored in memory \
// or if the timestamp occurs after the `time` value of the latest bar on the chart. \
// \
// The return value will be either [na](https://www.tradingview.com/pine-script-reference/v6/#var_na) or >= 0.
// ___
// @param chartData  (series ChartData) The `ChartData` object.
// @param timestamp  (series int) A UNIX time.
// @returns          A bar offset, or `na` if unable to find a valid number of bars back that the timestamp belongs to.
export method getNumberOfBarsBack(series ChartData chartData, series int timestamp) =>
    int barIndex = chartData.timestampToBarIndex(timestamp, Snap.DEFAULT)
    int latestBarIndex = chartData.bars - 1
    not na(barIndex) and barIndex <= latestBarIndex ? latestBarIndex - barIndex : na



// @function         Retrieves the [time](https://www.tradingview.com/pine-script-reference/v6/#var_time)
//                   value for the specified bar index.
//
// @param chartData  (series ChartData) The `ChartData` object.
// @param barIndex   (series int) The bar index.
// @returns          The `time` value, or `na` if there is no `time` stored for the bar index.
export method timeAtBarIndex(series ChartData chartData, series int barIndex) =>
    int index = barIndex.toArrayIndex(chartData)
    array<int> values = chartData.timeValues
    index >= 0 and index < values.size() ? values.get(index) : na



// @function         Retrieves the [time](https://www.tradingview.com/pine-script-reference/v6/#var_time)
//                   value of the bar that is `length` bars back relative to the latest bar.
//
// @param chartData  (series ChartData) The `ChartData` object.
// @param length     (series int) Number of bars back.
// @returns          The `time` value `length` bars ago, or `na` if there is no `time` stored for that bar.
export method time(series ChartData chartData, series int length) =>
    validateHistoryReference(length)
    chartData.timeAtBarIndex(chartData.bars - 1 - length)



// @function         Retrieves the [time_close](https://www.tradingview.com/pine-script-reference/v6/#var_time_close)
//                   value for the specified bar index.
//
// @param chartData  (series ChartData) The `ChartData` object.
// @param barIndex   (series int) The bar index.
// @returns          The `time_close` value, or `na` if there is no `time_close` stored for the bar index.
export method timeCloseAtBarIndex(series ChartData chartData, series int barIndex) =>
    int index = barIndex.toArrayIndex(chartData)
    array<int> values = chartData.timeCloseValues
    index >= 0 and index < values.size() ? values.get(index) : na



// @function         Retrieves the [time_close](https://www.tradingview.com/pine-script-reference/v6/#var_time_close)
//                   value of the bar that is `length` bars back relative to the latest bar.
//
// @param chartData  (series ChartData) The `ChartData` object.
// @param length     (series int) Number of bars back.
// @returns          The `time_close` value `length` bars ago, or `na` if there is no `time_close` stored for that bar.
export method timeClose(series ChartData chartData, series int length) =>
    validateHistoryReference(length)
    chartData.timeCloseAtBarIndex(chartData.bars - 1 - length)



// @function         Retrieves the value of a custom variable for the specified bar index.
//
// @param chartData  (series ChartData) The `ChartData` object.
// @param name       (series string) The variable name.
// @param barIndex   (series int) The bar index.
// @returns          The value of the [name] variable, or `na` if there is no [name] variable stored for the bar index.
export method valueAtBarIndex(series ChartData chartData, series string name, series int barIndex) =>
    float value = na
    if not na(chartData.variables)
        for variable in chartData.variables
            if variable.name == name
                int index = barIndex.toArrayIndex(chartData)
                array<float> values = variable.values
                value := index >= 0 and index < values.size() ? values.get(index) : na
                break
    value



// @function         Retrieves a variable value of the bar that is `length` bars back relative to the latest bar.
//
// @param chartData  (series ChartData) The `ChartData` object.
// @param name       (series string) The variable name.
// @param length     (series int) Number of bars back.
// @returns          The [name] value `length` bars ago, or `na` if there is no [name] variable stored for that bar.
export method value(series ChartData chartData, series string name, series int length) =>
    validateHistoryReference(length)
    chartData.valueAtBarIndex(name, chartData.bars - 1 - length)



// @function  Retrieves all custom variables for the specified bar index.
// ___
// **Remarks** \
// The resulting map will not be [na](https://www.tradingview.com/pine-script-reference/v6/#var_na). \
// The resulting map is a copy and any changes to it are not reflected in the stored data. \
// \
// If there is no data stored in memory for the specified bar index, \
// the map keys will still contain all the variable names, but each value will be
// [na](https://www.tradingview.com/pine-script-reference/v6/#var_na).
// ___
// @param chartData  (series ChartData) The `ChartData` object.
// @param barIndex   (series int) The bar index.
// @returns          Map of all custom variables that are stored for the specified bar index.
export method getAllVariablesAtBarIndex(series ChartData chartData, series int barIndex) =>
    map<string, float> variables = map.new<string, float>()

    int index = barIndex.toArrayIndex(chartData)

    int outOfBounds = na                // boolean value to determine if `index` is within bounds (1 = true, 0 = false)

    if not na(chartData.variables)
        for variable in chartData.variables
            if na(outOfBounds)          // calculate only once since all `variable.values` arrays will be the same size
                outOfBounds := index >= 0 and index < variable.values.size() ? 0 : 1

            float value = bool(outOfBounds) ? na : variable.values.get(index)
            variables.put(variable.name, value)

    variables



// @function  Gets all values from the earliest bar data that is currently stored in memory.
// ___
// **Remarks** \
// Returns a tuple of the [bar_index](https://www.tradingview.com/pine-script-reference/v6/#var_bar_index)
// (which may be greater than 0 if old data was deleted), \
// the [time](https://www.tradingview.com/pine-script-reference/v6/#var_time),
// the [time_close](https://www.tradingview.com/pine-script-reference/v6/#var_time_close),
// and a map of all the custom variable names & values. \
// \
// Note: the resulting map is a copy and any changes to it are not reflected in the stored data.
// ___
// @param chartData  (series ChartData) The `ChartData` object.
// @returns          A tuple: [bar_index, time, time_close, variables]
export method getEarliestStoredData(series ChartData chartData) =>
    int barIndex = (0).toBarIndex(chartData)
    [barIndex, chartData.timeValues.first(), chartData.timeCloseValues.first(), chartData.getAllVariablesAtBarIndex(barIndex)]



// @function  Gets all values from the latest bar data that is currently stored in memory.
// ___
// **Parameters**
// ```
// • series bool futureData
// ```
// `futureData` - Optional.  The default is [true](https://www.tradingview.com/pine-script-reference/v6/#const_true). \
// A value of [true](https://www.tradingview.com/pine-script-reference/v6/#const_true)
// will take into account any future data that may be stored in memory (due to a `barsForward` argument >= 1). \
// A value of [false](https://www.tradingview.com/pine-script-reference/v6/#const_false)
// will return the data points from the latest bar on the chart.
// ___
// **Remarks** \
// Returns a tuple of the [bar_index](https://www.tradingview.com/pine-script-reference/v6/#var_bar_index),
// the [time](https://www.tradingview.com/pine-script-reference/v6/#var_time),
// the [time_close](https://www.tradingview.com/pine-script-reference/v6/#var_time_close),
// and a map of all the custom variable names & values. \
// \
// Note: the resulting map is a copy and any changes to it are not reflected in the stored data.
// ___
// @param chartData   (series ChartData) The `ChartData` object.
// @param futureData  (series bool) Whether to include all of the available future data that is stored in memory.
// @returns           A tuple: [bar_index, time, time_close, variables]
export method getLatestStoredData(series ChartData chartData, series bool futureData = true) =>
    if futureData
        int barIndex = (chartData.timeValues.size() - 1).toBarIndex(chartData)
        [barIndex, chartData.timeValues.last(), chartData.timeCloseValues.last(), chartData.getAllVariablesAtBarIndex(barIndex)]
    else
        int barIndex = chartData.bars - 1
        [barIndex, chartData.timeAtBarIndex(barIndex), chartData.timeCloseAtBarIndex(barIndex), chartData.getAllVariablesAtBarIndex(barIndex)]

//#endregion
````

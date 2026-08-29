<!-- tradingview-pine-id: PUB;ee1c40366aa04c40833829b8eca7c5df -->
<!-- tradingviewscripts-format: 1 -->
# Intrabar Efficiency Ratio

Source: https://www.tradingview.com/script/o8tRZCzT-Intrabar-Efficiency-Ratio/

## Description

█  OVERVIEW

This indicator displays a directional variant of Perry​ Kaufman's​ Efficiency​ Ratio​, designed to gauge the "efficiency" of intrabar price movement by comparing the sum of movements of the lower timeframe bars composing a chart bar with the respective bar's movement on an average basis.

█  CONCEPTS

Efficiency Ratio (ER)

Efficiency Ratio​ was first introduced by Perry Kaufman in his 1995 book, titled "Smarter Trading". It is the ratio of absolute price change to the sum of absolute changes on each bar over a period. This tells us how strong the period's trend is relative to the underlying noise. Simply put, it's a measure of price movement efficiency. This ratio is the modulator utilized in Kaufman's​ Adaptive​ Moving​ Average​ (KAMA​), which is essentially an Exponential​ Moving​ Average​ (EMA​) that adapts its responsiveness to movement efficiency.

ER's output is bounded between 0 and 1. A value of 0 indicates that the starting price equals the ending price for the period, which suggests that price movement was maximally inefficient. A value of 1 indicates that price had travelled no more than the distance between the starting price and the ending price for the period, which suggests that price movement was maximally efficient. A value between 0 and 1 indicates that price had travelled a distance greater than the distance between the starting price and the ending price for the period. In other words, some degree of noise was present which resulted in reduced efficiency over the period.

As an example, let's say that the price of an asset had moved from $15 to $14 by the end of a period, but the sum of absolute changes for each bar of data was $4. ER would be calculated like so:
[pine] ER = abs(14 - 15)/4 = 0.25[/pine]
This suggests that the trend was only 25% efficient over the period, as the total distanced travelled by price was four times what was required to achieve the change over the period.  

Intrabars

Intrabars are chart bars at a lower timeframe than the chart's. Each 1H chart bar of a 24x7 market will, for example, usually contain 60 intrabars at the ​LTF of 1min, provided there was market activity during each minute of the hour. Mining information from intrabars can be useful in that it offers traders visibility on the activity inside a chart bar.

Lower timeframes (LTFs)

A lower timeframe is a timeframe that is smaller than the chart's timeframe. This script determines which ​LTF to use by examining the chart's timeframe. The ​LTF determines how many intrabars are examined for each chart bar; the lower the timeframe, the more intrabars are analyzed, but fewer chart bars can display indicator information because there is a limit to the total number of intrabars that can be analyzed.

Intrabar precision

The precision of calculations increases with the number of intrabars analyzed for each chart bar. As there is a 100K limit to the number of intrabars that can be analyzed by a script, a trade-off occurs between the number of intrabars analyzed per chart bar and the chart bars for which calculations are possible.

Intrabar Efficiency Ratio (IER)

Intrabar Efficiency Ratio applies the concept of ER on an intrabar level. Rather than comparing the overall change to the sum of bar changes for the current chart's timeframe over a period, IER compares single bar changes for the current chart's timeframe to the sum of absolute intrabar changes, then applies smoothing to the result. This gives an indication of how efficient changes are on the current chart's timeframe for each bar of data relative to LTF​ bar changes on an average basis. Unlike the standard ER calculation, we've opted to preserve directional information by not taking the absolute value of overall change, thus allowing it to be utilized as a momentum oscillator. However, by taking the absolute value of this oscillator, it could potentially serve as a replacement for ER in the design of adaptive moving averages.

Since this indicator preserves directional information, IER can be regarded as similar to the [Chande​ Momentum​ Oscillator​ (CMO​)](https://www.tradingview.com/u/?solution=43000589109), which was presented in 1994 by Tushar​ Chande​ in "The New Technical Trader". Both CMO​ and ER​ essentially measure the same relationship between trend and noise. CMO simply differs in scale, and considers the direction of overall changes.

█  FEATURES

Display

Three different display types are included within the script:
 • Line: Displays the middle length MA of the IER as a [line](https://www.tradingview.com/pine-script-reference/v5/#var_plot{dot}style_line).
  Color for this display can be customized via the "Line" portion of the "Visuals" section in the script settings.
 • Candles: Displays the non-smooth IER and two moving averages of different lengths as [candles](https://www.tradingview.com/pine-script-reference/v5/#fun_plotcandle).
  The `open` and `close` of the candle are the longest and shortest length MAs of the IER respectively. 
  The `high` and `low` of the candle are the [max](https://www.tradingview.com/pine-script-reference/v5/#fun_math{dot}max) and [min](https://www.tradingview.com/pine-script-reference/v5/#fun_math{dot}min) of the IER, longest length MA of the IER, and shortest length MA of the IER respectively.
  Colors for this display can be customized via the "Candles" portion of the "Visuals" section in the script settings.
 • Circles: Displays three MAs of the IER as [circles](https://www.tradingview.com/pine-script-reference/v5/#var_plot{dot}style_circles).
  The color of each [plot](https://www.tradingview.com/pine-script-reference/v5/#fun_plot) depends on the [percent rank](https://www.tradingview.com/pine-script-reference/v5/#fun_ta{dot}percentrank) of the respective MA over the previous 100 bars.
  Different colors are triggered when ranks are below 10%, between 10% and 50%, between 50% and 90%, and above 90%.
  Colors for this display can be customized via the "Circles" portion of the "Visuals" section in the script settings.

With either display type, an optional information box can be displayed. This box shows the LTF​ that the script is using, the average number of lower timeframe bars per chart bar, and the number of chart bars that contain LTF​ data. 

Specifying intrabar precision

Ten options are included in the script to control the number of intrabars used per chart bar for calculations. The greater the number of intrabars per chart bar, the fewer chart bars can be analyzed.

The first five options allow users to specify the approximate amount of chart bars to be covered:
 • Least Precise (Most chart bars): Covers all chart bars by dividing the current timeframe by four. 
  This ensures the highest level of intrabar precision while achieving complete coverage for the dataset.
 • Less Precise (Some chart bars) & More Precise (Less chart bars): These options calculate a stepped ​LTF in relation to the current chart's timeframe.
 • Very precise (2min intrabars): Uses the second highest quantity of intrabars possible with the 2min ​LTF.
 • Most precise (1min intrabars): Uses the maximum quantity of intrabars possible with the 1min ​LTF.

The stepped lower timeframe for "Less Precise" and "More Precise" options is calculated from the current chart's timeframe as follows:
[pine]Chart Timeframe            Lower Timeframe

                    Less Precise     More Precise
                                   
    < 1hr               1min            1min
    < 1D                15min           1min
    < 1W                ​2hr​             30min
    > 1W                1D              60min[/pine]

The last five options allow users to specify an approximate fixed number of intrabars to analyze per chart bar. The available choices are 12, 24, 50, 100, and 250. The script will calculate the LTF​ which most closely approximates the specified number of intrabars per chart bar. Keep in mind that due to factors such as the length of a ticker's sessions and rounding of the LTF​, it is not always possible to produce the exact number specified. However, the script will do its best to get as close to the value as possible.

Specifying MA type

Seven MA types are included in the script for different averaging effects:
 • [Simple](https://www.tradingview.com/pine-script-reference/v5/#fun_ta{dot}sma)
 • [Exponential](https://www.tradingview.com/pine-script-reference/v5/#fun_ta{dot}ema)
 • [Wilder (RMA)](https://www.tradingview.com/pine-script-reference/v5/#fun_ta{dot}rma)
 • [Weighted](https://www.tradingview.com/pine-script-reference/v5/#fun_ta{dot}wma)
 • [Volume-Weighted](https://www.tradingview.com/pine-script-reference/v5/#fun_ta{dot}vwma)
 • [Arnaud Legoux](https://www.tradingview.com/pine-script-reference/v5/#fun_ta{dot}alma) with `offset` and `sigma` set to 0.85 and 6 respectively.
 • [Hull](https://www.tradingview.com/pine-script-reference/v5/#fun_ta{dot}hma)

Weighting

This script includes the option to weight IER values based on the [percent rank](https://www.tradingview.com/pine-script-reference/v5/#fun_ta{dot}percentrank) of absolute price changes on the current chart's timeframe over a specified period, which can be enabled by checking the "Weigh using relative close changes" option in the script settings. This places reduced emphasis on IER values from smaller changes, which may help to reduce noise in the output.

█  FOR Pine Script™ CODERS

 • This script imports the recently published [lower_ltf](https://www.tradingview.com/script/UxiDkNg0-lower-tf/) library for calculating intrabar statistics and the optimal lower timeframe in relation to the current chart's timeframe.
 • This script uses the recently released [request.security_lower_tf()](https://www.tradingview.com/pine-script-reference/v5/#fun_request{dot}security_lower_tf) Pine Script™ function discussed in [this blog post](https://www.tradingview.com/blog/en/request-more-data-from-your-scripts-31944/). 
  It works differently from the usual [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request{dot}security) in that it can only be used on LTFs, and it returns an array containing one value per intrabar. 
  This makes it much easier for programmers to access intrabar information.
 • This script implements a new recommended best practice for [tables](https://www.tradingview.com/pine-script-docs/en/v5/concepts/Tables.html#tables) which works faster and reduces memory consumption.
  Using this new method, tables are declared only once with [var](https://www.tradingview.com/pine-script-reference/v5/#op_var), as usual. Then, on the first bar only, we use  [table.cell()](https://www.tradingview.com/pine-script-reference/v5/#fun_table{dot}cell) to populate the table.
  Finally, [table.set_*()](https://www.tradingview.com/pine-script-reference/v5/#fun_table{dot}cell_set_text) functions are used to update attributes of table cells on the last bar of the dataset.
  This greatly reduces the resources required to render tables.

[Look first. Then leap.](https://www.tradingview.com/athletes/)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingView

//@version=6
indicator("Intrabar Efficiency Ratio", precision = 4)

// Intrabar Efficiency Ratio indicator
// v3, 2026.01.09

// This code's style is based on the recommendations from the Pine Script User Manual's Style guide:
//    https://www.tradingview.com/pine-script-docs/writing/style-guide/



import PineCoders/Time/5 as PCtime
import PineCoders/lower_tf/5 as PCltf



//#region ———————————————————— Constants and Inputs


// ————— Constants

// Colors
color  AQUA    = color.aqua
color  FUCHSIA = color.fuchsia
color  GRAY    = #80808080
color  GRAY_LT = #f5f3f3
color  LIME    = color.lime
color  MAROON  = color.maroon
color  ROYAL   = #3BB3E4
color  ROSE    = #FF0080
color  TEAL    = color.teal
color  WHITE   = color.white
color  YELLOW  = color.yellow

// MAs
string MA01 = "Simple"
string MA02 = "Exponential"
string MA03 = "Wilder (RMA)"
string MA04 = "Weighted"
string MA05 = "Volume-Weighted"
string MA06 = "Arnaud Legoux"
string MA07 = "Hull"

// LTF distinction
string LTF1  = "Covering most chart bars (least precise)"
string LTF2  = "Covering some chart bars (less precise)"
string LTF3  = "Covering less chart bars (more precise)"
string LTF4  = "Covering few chart bars (very precise)"
string LTF5  = "Covering the least chart bars (most precise)"
string LTF6  = "~12 intrabars per chart bar"
string LTF7  = "~24 intrabars per chart bar"
string LTF8  = "~50 intrabars per chart bar"
string LTF9  = "~100 intrabars per chart bar"
string LTF10 = "~250 intrabars per chart bar"

// Display types
string DT01 = "Line"
string DT02 = "Candles"
string DT03 = "Circles"

// Tooltips
string TT_DT = (
    "Three display options are available:"
    + "\n• 'Line' displays an IER-based moving average of the selected type using the medium length."
    + "\n• 'Candles' displays candles using the IER value and the short and long MAs."
    + "\n• 'Circles' displays circles to show the values of all three IER-based MAs."
)
string TT_LTF  = (
    "Controls the number of intrabars that the indicator analyzes per chart bar. "
    + "Increasing the intrabars per chart bar enables more precise calculations. However, it also reduces the number "
    + "of chart bars that the indicator can analyze. "
    + "The first five options determine the requested lower timeframe based on a desired relative amount of chart bar "
    + "coverage. The last five determine the timeframe based on an approximate number of intrabars per chart bar."
)
string TT_CDL = (
    "Specifies the colors for the 'Candle' display in the following order: "
    + "down body, down wick, up body, up wick."
)
string TT_CIR = (
    "Specifies the colors for the 'Circles' display in the following order: "
    + "extreme low, down color, up color, extreme high."
)
string TT_RW  = (
    "If selected, the indicator applies weighting to IER values based on the percentage rank of the close-to-close "
    + "price change over the specified number of bars."
)
string TT_LEN = (
    "The short, medium and long lengths for the moving averages. Different display modes use different "
    + "MAs. Only the 'Circles' display uses all three."
)

// ————— Inputs

string  GRP1 = "Visuals"
string  displayTypeInput        = input.string(DT01,     "Display",                  group = GRP1, inline = "10", options = [DT01, DT02, DT03], tooltip = TT_DT)
bool    isLine                  = displayTypeInput == DT01
bool    isCandles               = displayTypeInput == DT02
bool    isCircles               = displayTypeInput == DT03
color   lineColorInput          = input.color(AQUA,      "Line   ",                  group = GRP1, inline = "13", active =isLine)
color   bearBodyInput           = input.color(FUCHSIA,   "Candles",                  group = GRP1, inline = "11", active = isCandles, tooltip = TT_CDL)
color   bearWickInput           = input.color(MAROON,    "",                         group = GRP1, inline = "11", active = isCandles)
color   bullBodyInput           = input.color(LIME,      "",                         group = GRP1, inline = "11", active = isCandles)
color   bullWickInput           = input.color(TEAL,      "",                         group = GRP1, inline = "11", active = isCandles)
color   lowColorInput           = input.color(YELLOW,    "Circles ",                 group = GRP1, inline = "12", active = isCircles, tooltip = TT_CIR)
color   bearColorInput          = input.color(ROSE,      "",                         group = GRP1, inline = "12", active = isCircles)
color   bullColorInput          = input.color(ROYAL,     "",                         group = GRP1, inline = "12", active = isCircles)
color   highColorInput          = input.color(LIME,      "",                         group = GRP1, inline = "12", active = isCircles)
bool    showInfoBoxInput        = input.bool(true,       "Show information box ",    group = GRP1)
string  infoBoxSizeInput        = input.string("small",  "Size ",                    group = GRP1, inline = "14", active = showInfoBoxInput, options = ["tiny", "small", "normal", "large", "huge", "auto"])
string  infoBoxYPosInput        = input.string("bottom", "↕",                        group = GRP1, inline = "14", active = showInfoBoxInput, options = ["top", "middle", "bottom"])
string  infoBoxXPosInput        = input.string("right",  "↔",                        group = GRP1, inline = "14", active = showInfoBoxInput, options = ["left", "center", "right"])
color   infoBoxColorInput       = input.color(GRAY,      "",                         group = GRP1, inline = "14", active = showInfoBoxInput)
color   infoBoxTxtColorInput    = input.color(GRAY_LT,   "T",                        group = GRP1, inline = "14", active = showInfoBoxInput)

string  GRP2 = "Settings"
string  ltfModeInput            = input.string(LTF3,     "Intrabar precision",       group = GRP2, options = [LTF1, LTF2, LTF3, LTF4, LTF5, LTF6, LTF7, LTF8, LTF9, LTF10], tooltip = TT_LTF)
string  maTypeInput             = input.string(MA06,     "MA type ",                 group = GRP2, inline = "20", options = [MA01, MA02, MA03, MA04, MA05, MA06, MA07])
int     shortLengthInput        = input.int(10,          "MA lengths: S",            group = GRP2, inline = "21", active = isCandles or isCircles)
int     midLengthInput          = input.int(20,          "M",                        group = GRP2, inline = "21", active = isLine or isCircles)
int     longLengthInput         = input.int(40,          "L",                        group = GRP2, inline = "21", active = isCandles or isCircles, tooltip = TT_LEN)
bool    rankWeightInput         = input.bool(false,      "Weigh using relative close changes", group = GRP2, inline = "22")
int     rankLengthInput         = input.int(100,         "",                         group = GRP2, inline = "22", tooltip = TT_RW, active = rankWeightInput)
//#endregion



//#region ———————————————————— Functions


// @function        Calculates a moving average of a source series, with a specified type and length.
// @param source    (series float) The series of values to process.
// @param length    (simple int) The length value for the moving average.
// @param maType    (simple string) Specifies the type of moving average. Accepts the value of one of the `MA*`
//                  constants declared above.
// @returns         (float) The moving average of the `source` series.
ma(series float source, simple int length, simple string maType) =>
    float result = switch maType
        MA01 => ta.sma(source,  length)
        MA02 => ta.ema(source,  length)
        MA03 => ta.rma(source,  length)
        MA04 => ta.wma(source,  length)
        MA05 => ta.vwma(source, length)
        MA06 => ta.alma(source, length, 0.85, 6)
        MA07 => ta.hma(source,  length)
        => na


// @function        Selects an input color (`highColorInput`, `lowColorInput`, `bullColorInput`, or `bearColorInput`)
//                  based on the 100-bar percent rank of the specified value.
// @param value     (series float) The series of values for which to calculate the color.
// @returns         (color) The selected input color.
plotColor(series float value) =>
    float percent = ta.percentrank(value, 100)
    color result = switch
        percent > 90 => highColorInput
        percent < 10 => lowColorInput
        percent > 50 => bullColorInput
        =>              bearColorInput
//#endregion



//#region ———————————————————— Calculations


// @variable A string representing the lower timeframe for which to retrieve intrabar data.
var string ltfString = PCltf.ltf(ltfModeInput, LTF1, LTF2, LTF3, LTF4, LTF5, LTF6, LTF7, LTF8, LTF9, LTF10)

// Retrieve the absolute bar-to-bar change in the `close` value for each intrabar in the chart bar, and compute the sum.
array<float> travels = request.security_lower_tf(
    syminfo.tickerid, ltfString, math.abs(ta.change(close)), calc_bars_count = 200000
)
float totalTravels   = travels.sum()
// Calculate the one-bar change in the `close` value on the chart's timeframe.
float chartBarChange = nz(ta.change(close))

// Calculate a weight using the relative size of the one-bar price change.
float weight = rankWeightInput ? ta.percentrank(math.abs(chartBarChange), rankLengthInput) / 100.0 : 1.0

// Compute the IER and its MAs.
float ier     = nz(chartBarChange / totalTravels) * weight
float maLong  = ma(ier, longLengthInput,  maTypeInput)
float maMid   = ma(ier, midLengthInput,   maTypeInput)
float maShort = ma(ier, shortLengthInput, maTypeInput)

// Calculate candle data.
float o = maLong
float h = math.max(ier, maLong, maShort)
float l = math.min(ier, maLong, maShort)
float c = maShort
color candleColor = c > o ? bullBodyInput : bearBodyInput
color wickColor   = c > o ? bullWickInput : bearWickInput

// Retrieve intrabar and chart bar information for the table display.
[intrabars, chartBarsCovered, avgIntrabars] = PCltf.ltfStats(travels)
int chartBars = bar_index + 1
//#endregion



//#region ———————————————————— Visuals


// Declare variables to store display settings for the plots.
candlePlotDisplay = isCandles ? display.all  - display.pane : display.none
candleDisplay     = isCandles ? display.pane : display.none
circleDisplay     = isCircles ? display.all  : display.none
lineDisplay       = isLine    ? display.all  : display.none

// Plot the candle values.
plot(o, "IER candle open",  candleColor, display = candlePlotDisplay)
plot(h, "IER candle high",  wickColor,   display = candlePlotDisplay)
plot(l, "IER candle low",   wickColor,   display = candlePlotDisplay)
plot(c, "IER candle close", candleColor, display = candlePlotDisplay)
plotcandle(o, h, l, c, "IER candles", candleColor, wickColor, bordercolor = candleColor, display = candleDisplay)

// Plot the IER-based MAs.
plot(maLong,  "Long MA",  color.new(plotColor(maLong),  20), 2, plot.style_circles, display = circleDisplay)
plot(maMid,   "Mid MA",   color.new(plotColor(maMid),   10), 1, plot.style_circles, display = circleDisplay)
plot(maShort, "Short MA", color.new(plotColor(maShort),  0), 1, plot.style_circles, display = circleDisplay)
plot(maMid,   "Mid MA",   lineColorInput,                    1, plot.style_line,    display = lineDisplay)
hline(0)

// Plot key information in the status line and the Data Window.
displayLocations = display.status_line + display.data_window
plot(ier,               "Intrabar Efficiency Ratio", display = displayLocations)
plot(intrabars,         "Intrabars in chart bar",    display = displayLocations)
plot(avgIntrabars,      "Avg. intrabars",            display = displayLocations)
plot(chartBarsCovered,  "Chart bars covered",        display = displayLocations)
plot(chartBars,         "Total chart bars",          display = displayLocations)
plot(totalTravels,      "totalTravels",              display = displayLocations)
plot(chartBarChange,    "chartBarChange",            display = displayLocations)
plot(weight,            "weight",                    display = displayLocations)

// Logic for the information box display
if showInfoBoxInput
    var table infoBox = table.new(infoBoxYPosInput + "_" + infoBoxXPosInput, 1, 1)
    string formattedLtf = PCtime.formattedNoOfPeriods(timeframe.in_seconds(ltfString) * 1000)
    string txt = str.format(
        "Intrabar timeframe: {0}\nAvg intrabars per chart bar: {1,number,#.#}\nChart bars covered: {2} of {3}",
        formattedLtf, avgIntrabars, chartBarsCovered, chartBars
    )
    if barstate.isfirst
        table.cell(
            infoBox, 0, 0, txt, text_color = infoBoxTxtColorInput, text_size = infoBoxSizeInput,
            bgcolor = infoBoxColorInput
        )
    else if barstate.islast
        table.cell_set_text(infoBox, 0, 0, txt)

// Runtime errors
if ta.cum(intrabars) == 0 and barstate.islast
    runtime.error(str.format("No intrabar information available for the ''{0}'' timeframe.", ltfString))
else if shortLengthInput > midLengthInput
    runtime.error("The length of the short MA must be less than or equal to that of the medium MA.")
else if midLengthInput > longLengthInput
    runtime.error("The length of the medium MA must be less than or equal to that of the long MA.")
//#endregion
````

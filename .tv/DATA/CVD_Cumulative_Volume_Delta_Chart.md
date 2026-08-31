<!-- tradingview-pine-id: PUB;84da7a14bfe64823a1246e4d5b0f7c80 -->
<!-- tradingviewscripts-format: 1 -->
# CVD - Cumulative Volume Delta (Chart)

Source: https://www.tradingview.com/script/hFcy7CIq-CVD-Cumulative-Volume-Delta-Chart/

## Description

█  OVERVIEW

This indicator displays cumulative ​volume delta (​CVD) as an on-chart oscillator. It uses intrabar analysis to obtain more precise ​volume delta information compared to methods that only use the chart's timeframe.

The core concepts in this script come from our first  ​[CVD indicator](https://www.tradingview.com/script/NlM312nK-CVD-Cumulative-Volume-Delta-Candles/), which displays CVD​ values as plot candles in a separate indicator pane. In this script, CV​D values are scaled according to price ranges and represented on the main chart pane.

█  CONCEPTS

Bar polarity

Bar polarity refers to the position of the [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) price relative to the [open](https://www.tradingview.com/pine-script-reference/v5/#var_open) price. In other words, bar polarity is the direction of price change.

Intrabars

Intrabars are chart bars at a lower timeframe than the chart's. Each 1H chart bar of a 24x7 market will, for example, usually contain 60 bars at the lower timeframe of 1min, provided there was market activity during each minute of the hour. Mining information from intrabars can be useful in that it offers traders visibility on the activity inside a chart bar.

Lower timeframes (LTFs)

A lower timeframe is a timeframe that is smaller than the chart's timeframe. This script utilizes a LTF to analyze intrabars, or price changes within a chart bar. The lower the ​LTF, the more intrabars are analyzed, but the less chart bars can display information due to the limited number of intrabars that can be analyzed. 

Volume delta

Volume delta is a measure that separates ​volume​ into "up" and "down" parts, then takes the difference to estimate the net demand for the asset. This approach gives traders a more detailed insight when analyzing volume​ and market sentiment. There are several methods for determining whether an asset's volume​ belongs in the "up" or "down" category. Some indicators, such as [On Balance Volume​](https://www.tradingview.com/u/?solution=43000502593) and the [Klinger Oscillator](https://www.tradingview.com/u/?solution=43000589157), use the change in price between bars to assign ​volume​ values to the appropriate category. Others, such as [Chaikin Money Flow](https://www.tradingview.com/chart/?solution=43000501974), make assumptions based on open, high, low, and close prices. The most accurate method involves using tick data to determine whether each transaction occurred at the bid or ask price and assigning the ​volume​ value to the appropriate category accordingly. However, this method requires a large amount of data on historical bars, which can limit the historical depth of charts and the number of symbols for which tick data is available.

In the context where historical tick data is not yet available on TradingView, intrabar analysis is the most precise technique to calculate ​volume delta on historical bars on our charts. This indicator uses intrabar analysis to achieve a compromise between simplicity and accuracy in calculating ​volume delta on historical bars. Our [Volume Profile indicators](https://www.tradingview.com/u/?solution=43000502040) use it as well. Other ​volume delta indicators in our [Community Scripts](https://www.tradingview.com/scripts/), such as the [Realtime 5D Profile](https://www.tradingview.com/script/tNG177SV-Realtime-5D-Profile-LucF/), use real-time chart updates to achieve more precise ​volume delta calculations. However, these indicators aren't suitable for analyzing historical bars since they only work for real-time analysis.

This is the logic we use to assign intrabar ​volume to the "up" or "down" category:
 • If the intrabar's [open](https://www.tradingview.com/pine-script-reference/v5/#var_open) and [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) values are different, their relative position is used.
 • If the intrabar's [open](https://www.tradingview.com/pine-script-reference/v5/#var_open) and [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) values are the same, the difference between the intrabar's [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) and the previous intrabar's [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) is used.
 • As a last resort, when there is no movement during an intrabar and it closes at the same price as the previous intrabar, the last known polarity is used.

Once all intrabars comprising a chart bar are analyzed, we calculate the net difference between "up" and "down" intrabar volume​ to produce the volume​ delta for the chart bar.

█  FEATURES

CVD resets

The "cumulative" part of the indicator's name stems from the fact that calculations accumulate during a period of time. By periodically resetting the volume​ delta accumulation, we can analyze the progression of ​volume delta across manageable chunks, which is often more useful than looking at ​volume delta accumulated from the beginning of a chart's history.

You can configure the reset period using the "CVD Resets" input, which offers the following selections:
 • None: Calculations do not reset.
 • On a fixed higher timeframe: Calculations reset on the higher timeframe you select in the "Fixed higher timeframe" field.
 • At a fixed time that you specify.
 • At the beginning of the regular session.
 • On trend changes: Calculations reset on the direction change of either the [Aroon](https://www.tradingview.com/u/?solution=43000501801#published-scripts) indicator, [Parabolic SAR](https://www.tradingview.com/u/?solution=43000502597#published-scripts), or [Supertrend](https://www.tradingview.com/u/?solution=43000634738#published-scripts).  
 • On a stepped higher timeframe: Calculations reset on a higher timeframe automatically stepped using the chart's timeframe and following these rules:

[pine]
    Chart TF        ​HTF

     <  1min        1H
     <  3H          1D
     <= 12H         1W
     <  1W          1M
     >= 1W          1Y
[/pine]

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

As there is a limit to the number of intrabars that can be analyzed by a script, a tradeoff occurs between the number of intrabars analyzed per chart bar and the chart bars for which calculations are possible.

Display

This script displays raw or cumulative volume​ delta values on the chart as either line or histogram oscillator zones scaled according to the price chart, allowing traders to visualize volume​ activity on each bar or cumulatively over time. The indicator's background shows where CVD​ resets occur, demarcating the beginning of new zones. The vertical axis of each oscillator zone is scaled relative to the one with the highest price range, and the oscillator values are scaled relative to the highest volume​ delta. A vertical offset is applied to each oscillator zone so that the highest oscillator value aligns with the lowest price. This method ensures an accurate, intuitive visual comparison of volume​ activity within zones, as the scale is consistent across the chart, and oscillator values sit below prices. The vertical scale of oscillator zones can be adjusted using the "Zone Height" input in the script settings. 

This script displays labels at the highest and lowest oscillator values in each zone, which can be enabled using the "Hi/Lo Labels" input in the "Visuals" section of the script settings. Additionally, the oscillator's value on a chart bar is displayed as a tooltip when a user hovers over the bar, which can be enabled using the "Value Tooltips" input.

Divergences occur when the polarity of ​volume delta does not match that of the chart bar. The script displays divergences as bar colors and background colors that can be enabled using the "Color bars on divergences" and "Color background on divergences" inputs.

An information box in the lower-left corner of the indicator displays the HTF used for resets, the ​LTF used for intrabars, the average quantity of intrabars per chart bar, and the number of chart bars for which there is LTF data. This is enabled using the "Show information box" input in the "Visuals" section of the script settings.

FOR Pine Script™ CODERS

 • This script utilizes `ltf()` and `ltfStats()` from the [lower_tf](https://www.tradingview.com/script/UxiDkNg0-lower-tf/) library. 
  The `ltf()` function determines the appropriate lower timeframe from the selected calculation mode and chart timeframe, and returns it in a format that can be used with [request.security_lower_tf()](https://www.tradingview.com/pine-script-reference/v5/#fun_request{dot}security_lower_tf). 
  The `ltfStats()` function, on the other hand, is used to compute and display statistical information about the lower timeframe in an information box.
 • The script utilizes [display.data_window](https://www.tradingview.com/pine-script-reference/v5/#var_display{dot}data_window) and [display.status_line](https://www.tradingview.com/pine-script-reference/v5/#var_display{dot}status_line) to restrict the display of certain plots.
  These [new built-ins](https://www.tradingview.com/pine-script-docs/en/v5/Release_notes.html#july-2022) allow coders to fine-tune where a script’s plot values are displayed.
 • The newly added [session.isfirstbar_regular](https://www.tradingview.com/pine-script-reference/v5/#var_session%7Bdot%7Dislastbar) built-in allows for resetting the ​CVD segments at the start of the regular session. 
 • The [VisibleChart](https://www.tradingview.com/script/j7vCseM2-VisibleChart/) library developed by our resident [PineCoders](https://www.tradingview.com/u/PineCoders/#published-scripts) team leverages the [chart.left_visible_bar_time](https://www.tradingview.com/pine-script-reference/v5/#var_chart{dot}left_visible_bar_time) and [chart.right_visible_bar_time](https://www.tradingview.com/pine-script-reference/v5/#var_chart{dot}right_visible_bar_time) variables to optimize the performance of this script. 
  These variables identify the opening time of the leftmost and rightmost visible bars on the chart, allowing the script to recalculate and draw objects only within the range of visible bars as the user scrolls. 
  This functionality also enables the scaling of the oscillator zones. 
  These variables are just a couple of the many new built-ins available in the chart.* namespace. 
  For more information, check out [this blog post](https://www.tradingview.com/blog/en/pine-script-and-charts-become-better-acquainted-32927/) or look them up by typing "chart." in the [Pine Script™ Reference Manual](https://www.tradingview.com/pine-script-reference/v5/). 
 • Our [ta](https://www.tradingview.com/script/BICzyhq0-ta/) library has undergone significant updates recently, including the incorporation of the `aroon()` indicator used as a method for resetting ​CVD segments within this script. 
  Revisit the library to see more of the newly added content!

[Look first. Then leap.](https://www.tradingview.com/athletes/)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingView

//@version=6
indicator(
    "CVD - Cumulative Volume Delta (Chart)", "CVD Chart", true, format = format.volume, max_lines_count = 500,
    max_labels_count = 500, max_boxes_count = 500
)

// CVD - Cumulative Volume Delta (Chart)
// v3, 2026.01.09

// This code's style is based on the recommendations from the Pine Script User Manual's Style guide:
//    https://www.tradingview.com/pine-script-docs/writing/style-guide/



import PineCoders/Time/5 as PCtime
import PineCoders/lower_tf/5 as PCltf
import TradingView/ta/12 as TVta
import PineCoders/VisibleChart/5 as chart



//#region ———————————————————— Constants and inputs


// ————— Constants

int     MS_IN_MIN   = 60 * 1000
int     MS_IN_HOUR  = MS_IN_MIN  * 60
int     MS_IN_DAY   = MS_IN_HOUR * 24
string  LBL_TXT     = " \n \n \n \n \n \n \n \n \n "

// Default colors
color   LIME        = color.lime
color   PINK        = color.fuchsia
color   WHITE       = color.white
color   ORANGE      = color.orange
color   GRAY        = #808080ff
color   LIME_LINE   = color.new(LIME, 30)
color   LIME_BG     = color.new(LIME, 95)
color   LIME_HI     = color.new(LIME, 80)
color   PINK_LINE   = color.new(PINK, 30)
color   PINK_BG     = color.new(PINK, 95)
color   PINK_LO     = color.new(PINK, 80)
color   BG_DIV      = color.new(ORANGE, 90)
color   BG_RESETS   = color.new(GRAY, 90)

// Reset conditions
string  RST1 = "None"
string  RST2 = "On a stepped higher timeframe"
string  RST3 = "On a fixed higher timeframe..."
string  RST4 = "At a fixed time..."
string  RST5 = "At the beginning of the regular session"
string  RST6 = "At the first visible chart bar"
string  RST7 = "On trend changes..."

// Trend types
string  TR01 = "Supertrend"
string  TR02 = "Aroon"
string  TR03 = "Parabolic SAR"

// Volume delta calculation modes
string  VD01 = "Volume delta"
string  VD02 = "Volume delta percent"

// CVD line types
string  LN01 = "Line"
string  LN02 = "Histogram"

// Label sizes
string  LS01 = "tiny"
string  LS02 = "small"
string  LS03 = "normal"
string  LS04 = "large"
string  LS05 = "huge"

// LTF precision options
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

// Tooltips
string TT_RST = (
    "Specifies the reset behavior of the CVD calculation. When selecting one of the last three options, use the "
    + "inputs below to specify additional settings for the reset conditions."
)
string TT_RST_HTF = (
    "Specifies the higher timeframe to use for the 'On a fixed higher timeframe' CVD reset option. "
    + "The CVD calculation resets at the open of a bar on the specified timeframe."
)
string TT_RST_TIME = (
    "Hour: 0-23\nMinute: 0-59\nThese values specify the fixed time of day to use for the 'At a fixed time' CVD reset "
    + "option. The CVD calculation resets when the time of day is after or equal to the bar's opening time and "
    + "before the bar's closing time."
)
string TT_RST_TREND = (
    "These values control the settings of the trend indicator to use for the 'On trend changes' CVD reset option. "
    + "The CVD calculation resets when the indicator signals a change in trend direction.\n\n"
    + "The first field specifies the length for the Aroon indicator or the ATR length for the Supertrend indicator.\n\n"
    + "The second field specifies the ATR multiplier for the Supertrend indicator.\n\n"
    + "The Parabolic SAR uses predefined settings. Neither field affects it."
)
string TT_LINE = "Select the style and color of the CVD lines."
string TT_LTF  = (
    "Controls the number of intrabars that the indicator analyzes per chart bar. "
    + "Increasing the intrabars per chart bar enables more precise calculations. However, it also reduces the number "
    + "of chart bars that the indicator can analyze. "
    + "The first five options determine the requested lower timeframe based on a desired relative amount of chart bar "
    + "coverage. The last five determine the timeframe based on an approximate number of intrabars per chart bar."
)
string TT_CVD = (
    "If enabled, the indicator displays cumulative delta values summed from the reset point. "
    + "Otherwise, it displays the raw volume delta for each bar."
)
string TT_YSPCE  = "Scales the height of all oscillator zones using a percentage of the largest zone's height."


// ————— Inputs

string  resetInput              = input.string(RST2,        "CVD resets",                       inline = "00", options = [RST1, RST2, RST5, RST6, RST3, RST4, RST7], tooltip = TT_RST)
string  fixedTfInput            = input.timeframe("D",      "  Fixed higher timeframe:",        inline = "01", tooltip = TT_RST_HTF)
int     hourInput               = input.int(9,              "  Fixed time: Hour",               inline = "02", minval  = 0, maxval = 23)
int     minuteInput             = input.int(30,             "Minute",                           inline = "02", minval  = 0, maxval = 59, tooltip = TT_RST_TIME)
string  trendInput              = input.string(TR01,        "  Trend: ",                        inline = "03", options = [TR02, TR03, TR01])
int     trendPeriodInput        = input.int(14,             " Length",                          inline = "03", minval  = 2)
float   trendValue2Input        = input.float(3.0,          "",                                 inline = "03", minval  = 0.25, step = 0.25, tooltip = TT_RST_TREND)
string  ltfModeInput            = input.string(LTF3,        "Intrabar precision",               inline = "04", options = [LTF1, LTF2, LTF3, LTF4, LTF5, LTF6, LTF7, LTF8, LTF9, LTF10], tooltip = TT_LTF)
string  vdCalcModeInput         = input.string(VD01,        "Volume delta calculation",         inline = "05", options = [VD01, VD02])
bool    cumulativeInput         = input.bool(true,          "Cumulative values",                inline = "06", tooltip = TT_CVD)

string  GRP1                    = "Visuals"
string  lineTypeInput           = input.string(LN01,        "CVD",                              inline = "00", group = GRP1, options = [LN01, LN02])
color   upColorInput            = input.color(LIME_LINE,    "🡓",                                inline = "01", group = GRP1)
color   dnColorInput            = input.color(PINK_LINE,    "🡓",                                inline = "01", group = GRP1, tooltip = TT_LINE)
float   percentYRangeInput      = input.float(100,          "Zone height (%)",                  inline = "02", group = GRP1, tooltip = TT_YSPCE) / 100.0
bool    showBgAreaInput         = input.bool(true,          "  Color background area ",         inline = "05", group = GRP1)
color   upBgColorInput          = input.color(LIME_BG,      "🡑",                                inline = "05", group = GRP1)
color   dnBgColorInput          = input.color(PINK_BG,      "🡓",                                inline = "05", group = GRP1)
bool    showHiLoInput           = input.bool(true,          "  Hi/Lo lines ",                   inline = "06", group = GRP1)
color   hiColorInput            = input.color(LIME_HI,      "🡑",                                inline = "06", group = GRP1)
color   loColorInput            = input.color(PINK_LO,      "🡓",                                inline = "06", group = GRP1)
bool    showZeroLineInput       = input.bool(true,          "  Zero line",                      inline = "07", group = GRP1)
color   zeroLineColorInput      = input.color(GRAY,         "🡓",                                inline = "07", group = GRP1)
bool    labelInput              = input.bool(true,          "Hi/Lo labels",                     inline = "03", group = GRP1)
string  labelSizeInput          = input.string(LS03,        "",                                 inline = "03", group = GRP1, options = [LS01, LS02, LS03, LS04, LS05])
bool    tooltipInput            = input.bool(true,          "Value tooltips",                   inline = "04", group = GRP1)
bool    colorDivBodiesInput     = input.bool(true,          "Color bars on divergences ",       inline = "08", group = GRP1)
color   upDivColorInput         = input.color(LIME,         "🡑",                                inline = "08", group = GRP1)
color   dnDivColorInput         = input.color(PINK,         "🡓",                                inline = "08", group = GRP1)
bool    bgDivInput              = input.bool(false,         "Color background on divergences ", inline = "09", group = GRP1)
color   bgDivColorInput         = input.color(BG_DIV,       "",                                 inline = "09", group = GRP1)
bool    bgResetInput            = input.bool(true,          "Color background on resets ",      inline = "10", group = GRP1)
color   bgResetColorInput       = input.color(BG_RESETS,    "",                                 inline = "10", group = GRP1)
bool    showInfoBoxInput        = input.bool(true,          "Show information box ",            inline = "11", group = GRP1)
string  infoBoxSizeInput        = input.string("small",     "Size ",                            inline = "12", group = GRP1, options = ["tiny", "small", "normal", "large", "huge", "auto"])
string  infoBoxYPosInput        = input.string("bottom",    "↕",                                inline = "12", group = GRP1, options = ["top", "middle", "bottom"])
string  infoBoxXPosInput        = input.string("right",     "↔",                                inline = "12", group = GRP1, options = ["left", "center", "right"])
color   infoBoxColorInput       = input.color(GRAY,         "",                                 inline = "12", group = GRP1)
color   infoBoxTxtColorInput    = input.color(WHITE,        "T",                                inline = "12", group = GRP1)
//#endregion



//#region ———————————————————— Functions


// @function            Categorizes volume as upward or downward based on price action.
// @returns             ([float, float]) A tuple containing the upward and downward volume values. The first value
//                      is the bar's volume if the volume is upward. Otherwise, the second value is the bar's volume.
//                      If a call to `request.security_lower_tf()` uses a call to this function as its `expression`
//                      argument, it returns a tuple of "float" arrays containing the upward and downward volume for
//                      each available intrabar in the chart bar.
upDnIntrabarVolumes() =>
    float upVol = 0.0
    float dnVol = 0.0
    switch
        close > open     => upVol += volume
        close < open     => dnVol -= volume
        close > close[1] => upVol += volume
        close < close[1] => dnVol -= volume
        upVol[1] > 0     => upVol += volume
        dnVol[1] < 0     => dnVol -= volume
        close == open    => upVol += volume
    [upVol, dnVol]


// @function            Selects a string representing a higher timeframe based on the chart's timeframe.
// @returns             (simple string) A timeframe string.
htfStep() =>
    int tfInMs = timeframe.in_seconds() * 1000
    string result = switch
        tfInMs <= MS_IN_MIN       => "60"
        tfInMs <  MS_IN_HOUR * 3  => "1D"
        tfInMs <= MS_IN_HOUR * 12 => "1W"
        tfInMs <  MS_IN_DAY  * 7  => "1M"
        =>                           "12M"


// @function            Determines whether an intraday bar opens before or at a specified time of day and closes after
//                      that time.
// @param hours         (series int) The hour of the day.
// @param minutes       (series int) The minute within the hour.
// @returns             (bool) `true` if the bar's span includes the specified time of day, and `false` otherwise.
timeReset(int hours, int minutes) =>
    int openTime = timestamp(year, month, dayofmonth, hours, minutes, 0)
    bool timeInBar = time <= openTime and time_close > openTime
    bool result = timeframe.isintraday and not timeInBar[1] and timeInBar


// @function            Scales a specified value within a given range to align with the scale of a new range.
// @param oldValue      (series float) The value to convert using the new scale.
// @param oldMin        (series float) The minimum value of the original range.
// @param oldMax        (series float) The maximum value of the original range.
// @param oldMin        (series float) The minimum value of the new range.
// @param oldMax        (series float) The maximum value of the new range.
// @returns             (float) A new value scaled to fit between the values of `newMin` and `newMax` based
//                      on the position of `oldValue` relative to the values of `oldMax` and `oldMin`.
scale(series float oldValue, series float oldMin, series float oldMax, series float newMin, series float newMax) =>
	float oldRange = oldMax - oldMin
	float newRange = newMax - newMin
	float newValue = (((oldValue - oldMin) * newRange) / oldRange) + newMin


// @function            Calculates a scaled with value for displayed histogram lines using a stepped, nonlinear curve
//                      based on a specified bar span.
// @param bars          (series int) The number of bars in the displayed range.
// @param maxWidth      (simple int) The maximum line width.
// @param decayLength   (simple int) Distance from 0 where the curve reaches its minimum value.
// @param offset        (series int) Offset of the curve along the x-axis.
// @returns             (int) A line width value that is nonlinearly scaled based on the specified number of bars.
scaleHistoWidth(series int bars, simple int maxWidth, simple int decayLength, simple int offset) =>
    int result = math.ceil(2 * maxWidth / (1 + math.exp(6 * (bars - offset) / decayLength)))
//#endregion



//#region ———————————————————— Calculations


// @variable A string representing the lower timeframe for which to retrieve intrabar data.
var string ltfString = PCltf.ltf(ltfModeInput, LTF1, LTF2, LTF3, LTF4, LTF5, LTF6, LTF7, LTF8, LTF9, LTF10)

// Retrieve the IDs of arrays containing upward and downward volume for each available intrabar in the current bar.
[upVolumes, dnVolumes] = request.security_lower_tf(
    syminfo.tickerid, ltfString, upDnIntrabarVolumes(), calc_bars_count = 200000
)

// Create conditions for lines and labels from user inputs.
bool useVdPct = vdCalcModeInput == VD02
bool useHisto = lineTypeInput   == LN02

// Get visible chart information.
int  leftBar    = chart.leftBarIndex()
int  rightBar   = chart.rightBarIndex()
bool isVisible  = chart.barIsVisible()
bool isLastBar  = chart.isLastVisibleBar()
int  totalBars  = chart.bars()

// Calculate line width for histogram display.
int lineWidth = scaleHistoWidth(totalBars, 29, 391, -63)

// Calculate the maximum volumes, total volume, and volume delta values.
float totalUpVolume = nz(upVolumes.sum())
float totalDnVolume = nz(dnVolumes.sum())
float maxUpVolume   = nz(upVolumes.max())
float maxDnVolume   = nz(dnVolumes.min())
float totalVolume   = totalUpVolume - totalDnVolume
float delta         = totalUpVolume + totalDnVolume
float deltaPct      = delta / totalVolume
float barDelta      = useVdPct ? deltaPct : delta

// Declare variables to track CVD reset information.
[reset, hasTrendDirection, trendIsUp, resetDescription] = switch resetInput
    RST1 => [false, false, false, "No resets"]
    RST2 => [timeframe.change(htfStep()), false, false, "Resets every " + htfStep()]
    RST3 => [timeframe.change(fixedTfInput), false, false, "Resets every " + fixedTfInput]
    RST4 => [
         timeReset(hourInput, minuteInput), false, false,
         str.format("Resets at {0,number,00}:{1,number,00}", hourInput, minuteInput)
     ]
    RST5 => [session.isfirstbar_regular, false, false, "Resets at the beginning of the session"]
    RST6 => [time == chart.left_visible_bar_time, false, false, "Resets at the beginning of visible bars"]
    RST7 =>
        switch trendInput
            TR01 =>
                [_, direction] = ta.supertrend(trendValue2Input, trendPeriodInput)
                [ta.change(direction, 1) != 0, true, direction == -1, "Resets on Supertrend changes"]
            TR02 =>
                [up, dn] = TVta.aroon(trendPeriodInput)
                [ta.cross(up, dn), true, ta.crossover(up, dn), "Resets on Aroon changes"]
            TR03 =>
                float psar = ta.sar(0.02, 0.02, 0.2)
                [ta.cross(psar, close), true, ta.crossunder(psar, close), "Resets on PSAR changes"]
    => [false, false, false, na]

// Get the number of intrabars per chart bar and calculate the cumulative average.
int intrabars = upVolumes.size()
int chartBarsCovered = int(ta.cum(math.sign(intrabars)))
float avgIntrabars = ta.cum(intrabars) / chartBarsCovered

// Detect divergences between volume delta and the bar's polarity.
bool divergence = delta != 0 and math.sign(delta) != math.sign(close - open)

// Declare variables to manage data for the CVD display.
var array<float> segCvdValues = array.new<float>()
var array<float> rawCvdValues = array.new<float>()
var array<float> barCenters   = array.new<float>()
var array<float> zeroLevels   = array.new<float>()
var array<float> priceRanges  = array.new<float>()
var array<float> highCvd      = array.new<float>()
var array<float> lowCvd       = array.new<float>()
var array<int>   resetBars    = array.new<int>()
var float priceHi = high
var float priceLo = low
var float cvd     = 0.0
priceHi := isVisible ? math.max(priceHi, high) : high
priceLo := isVisible ? math.min(priceLo, low)  : low

// Update data for new visible segments on a reset bar or the last bar.
if reset or isLastBar
    if isVisible
        segCvdValues.push(cumulativeInput ? cvd + barDelta : barDelta)
        resetBars.push(bar_index)
        zeroLevels.push(math.avg(priceHi, priceLo) - (priceHi - priceLo))
        priceRanges.push((priceHi - priceLo) / 2)
        highCvd.push(segCvdValues.max())
        lowCvd.push(segCvdValues.min())
        barCenters.push(hl2)
        rawCvdValues.concat(segCvdValues)
        segCvdValues.clear()
    priceHi := high
    priceLo := low
	cvd     := reset ? 0 : cvd

// Track the previous CVD value and calculate the new value.
float cvdO = cvd
cvd += barDelta

// Logic to create drawings on the last available bar to display CVD data on the chart.
if isLastBar
    // Initialize `startBar` to the leftmost bar, then find the highest range value and greatest absolute CVD Value.
    int startBar = leftBar
    int step = 0
    float yRangeMax = priceRanges.max() * percentYRangeInput
    float highScale = useVdPct and not cumulativeInput ? 1 : array.max(rawCvdValues.abs())
    // Loop to create the scaled drawings.
    for [i, resetBar] in resetBars
        // Find the segment's zero level, vertical range, and high/low CVD, and calculate an adjusted range.
        float zero      = zeroLevels.get(i)
        float yRange    = priceRanges.get(i)
        float highValue = highCvd.get(i)
        float lowValue  = lowCvd.get(i)
        float highLevel = scale(highValue, 0, highScale, zero, zero + yRangeMax)
        float offset    = zero + yRange - (useHisto ? math.max(highLevel, zero) : highLevel)
        float zeroLevel = zero + offset
        float hiLevel   = zeroLevel + yRangeMax
        float loLevel   = zeroLevel - yRangeMax
        // Render the zero line, high and low boundaries, and the background fill based on the user's selection.
        if showZeroLineInput
            line.new(startBar, zeroLevel, resetBar, zeroLevel, color = zeroLineColorInput, style = line.style_dashed)
        if showHiLoInput
            line.new(startBar, hiLevel, resetBar, hiLevel, color = hiColorInput)
            line.new(startBar, loLevel, resetBar, loLevel, color = loColorInput)
        if showBgAreaInput
            box.new(startBar, hiLevel, resetBar, zeroLevel, border_color = color(na), bgcolor = upBgColorInput)
            box.new(startBar, loLevel, resetBar, zeroLevel, border_color = color(na), bgcolor = dnBgColorInput)
        // Declare variables to track bar position, last price, and label location information.
        int bar = startBar
        float lastPriceValue = na
        bool placeHigh = true
        bool placeLow  = true
        // For each CVD value in the segment, scale the value, then determine the corresponding line color and label text.
        for x = step to resetBar - startBar + step
            // For each CVD value in the segment, calculate and scale price levels. Determine line color and label text.
            float  cvdValue  = rawCvdValues.get(x)
            float  eachCvd   = cvdValue != 0 ? cvdValue : na
            float  priceLvl  = scale(eachCvd, 0, highScale, zero, zero + yRangeMax) + offset
            color  lineColor = priceLvl > zeroLevel ? upColorInput : dnColorInput
            string labelStr  = (
                labelInput ? useVdPct  ?
                str.format("{0, number, percent}", eachCvd) : str.tostring(eachCvd, format.volume) : string(na)
            )
            bool   isHiCvd   = eachCvd == highValue
            bool   isLoCvd   = eachCvd == lowValue
            // Draw a label for the highest or lowest CVD in the segment if "Hi/Lo labels" is enabled.
            if labelInput and (isHiCvd or isLoCvd)
                bool   drawHiLbl  = isHiCvd and placeHigh and bar != leftBar
                bool   drawLoLbl  = isLoCvd and placeLow  and bar != leftBar
                string labelStyle = isHiCvd  ? label.style_label_down : label.style_label_up
                float  labelPrice = (
                    useHisto ? highValue < 0 and isHiCvd or lowValue > 0 and isLoCvd ? zeroLevel : priceLvl : priceLvl
                )
                if drawHiLbl or drawLoLbl
                    label.new(
                        bar, labelPrice, labelStr, color = color(na), style = labelStyle, textcolor = lineColor,
                        size = labelSizeInput
                    )
                    placeHigh := drawHiLbl ? false : placeHigh
                    placeLow  := drawLoLbl ? false : placeLow
            // Draw an invisible label with a CVD value tooltip over the chart bar if "Value tooltips" is enabled.
            if tooltipInput
                label.new(
                    bar, barCenters.get(x), LBL_TXT, color = color(na), size = size.tiny,
                    style = label.style_label_center, tooltip = labelStr
                )
            // Draw a line for the CVD value on each bar, using the current and previous bar values for line display,
            // or the current bar and zero level for histogram display.
            switch
                useHisto       => line.new(bar, zeroLevel, bar, priceLvl, color = lineColor, width = lineWidth)
                bar > startBar => line.new(bar - 1, lastPriceValue, bar, priceLvl, color = lineColor, width = 2)
            // Increment `bar` by one, and set the last price value to the value of `priceLvl`.
            bar += 1
            lastPriceValue := priceLvl
        // Increment the step counter by the number of bars in the current segment after the inner loop ends.
        // Set the `startBar` to store the current `resetBar` value for the next iteration.
        step += resetBar - startBar + 1
        startBar := resetBar

// Store necessary values for visible bars.
if isVisible
    segCvdValues.push(cumulativeInput ? cvd : barDelta)
    barCenters.push(hl2)
//#endregion



//#region ———————————————————— Visuals


color candleColor = colorDivBodiesInput and divergence ? delta > 0 ? upDivColorInput : dnDivColorInput : na

// Display key values in the Data Window.
displayDataWindow       = display.data_window
plot(delta,             "Volume delta for the bar", candleColor,    display = displayDataWindow)
plot(totalUpVolume,     "Up volume for the bar",    upColorInput,   display = displayDataWindow)
plot(totalDnVolume,     "Dn volume for the bar",    dnColorInput,   display = displayDataWindow)
plot(totalVolume,       "Total volume",                             display = displayDataWindow)
plot(na,                "═════════════════",                        display = displayDataWindow)
plot(cvdO,              "CVD before this bar",                      display = displayDataWindow)
plot(cvd,               "CVD after this bar",                       display = displayDataWindow)
plot(maxUpVolume,       "Max intrabar up volume",   upColorInput,   display = displayDataWindow)
plot(maxDnVolume,       "Max intrabar dn volume",   dnColorInput,   display = displayDataWindow)
plot(intrabars,         "Intrabars in this bar",                    display = displayDataWindow)
plot(avgIntrabars,      "Average intrabars",                        display = displayDataWindow)
plot(chartBarsCovered,  "Chart bars covered",                       display = displayDataWindow)
plot(bar_index + 1,     "Chart bars",                               display = displayDataWindow)
plot(na,                "═════════════════",                        display = displayDataWindow)
plot(totalBars,         "Total visible bars",                       display = displayDataWindow)
plot(leftBar,           "First visible bar index",                  display = displayDataWindow)
plot(rightBar,          "Last visible bar index",                   display = displayDataWindow)
plot(na,                "═════════════════",                        display = displayDataWindow)

// Plot an up or down arrow when a reset occurs based on trend changes.
plotchar(hasTrendDirection and reset and trendIsUp,     "Up trend", "▲", location.top, upColorInput)
plotchar(hasTrendDirection and reset and not trendIsUp, "Dn trend", "▼", location.top, dnColorInput)

// Color the background on bars where resets or divergences occur.
bgcolor(bgResetInput and reset ? bgResetColorInput : bgDivInput and divergence ? bgDivColorInput : na)
barcolor(candleColor)

// Create a table to display intrabar information on the last historical bar.
if showInfoBoxInput and barstate.islastconfirmedhistory
    var table infoBox = table.new(infoBoxYPosInput + "_" + infoBoxXPosInput, 1, 1)
    color infoBoxBgColor = infoBoxColorInput
    string txt = str.format(
      "{0}\nUses intrabars at {1}\nAvg intrabars per chart bar: {2,number,#.##}\n"
      + "Chart bars covered: {3} / {4} ({5,number,percent})",
      resetDescription, PCtime.formattedNoOfPeriods(timeframe.in_seconds(ltfString) * 1000),
      avgIntrabars, chartBarsCovered, bar_index + 1, chartBarsCovered / (bar_index + 1))
    if avgIntrabars < 5
        txt += "\nThis quantity of intrabars is dangerously small.\nResults will not be as reliable with so few."
        infoBoxBgColor := color.red
    table.cell(
        infoBox, 0, 0, txt, text_color = infoBoxTxtColorInput, text_size = infoBoxSizeInput, bgcolor = infoBoxBgColor
    )
//#endregion



//#region ———————————————————— Errors


if resetInput == RST3 and timeframe.in_seconds(fixedTfInput) <= timeframe.in_seconds()
    runtime.error("The higher timeframe for resets must be greater than the chart's timeframe.")
else if resetInput == RST4 and not timeframe.isintraday
    runtime.error("Resets at a fixed time work on intraday charts only.")
else if resetInput == RST5 and not timeframe.isintraday
    runtime.error("Resets at the begining of session work on intraday charts only.")
else if ta.cum(totalVolume) == 0 and barstate.islast
    runtime.error("No volume is provided by the data vendor.")
else if ta.cum(intrabars) == 0 and barstate.islast
    runtime.error("No intrabar information exists at the '" + ltfString + "' timeframe.")
//#endregion
````

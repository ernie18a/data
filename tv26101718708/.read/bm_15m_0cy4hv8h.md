# BM 15m

- url: https://www.tradingview.com/script/0cy4hV8H-BM-15m/
- type: indicator
- pine_id: PUB;3fcfc42945d14283a225f15be26b9d4e
- version: 1.0

## Description

15m candle overlay, used on lower timeframe charts to show the current and past 15 minute candles.

## Source Code

````pine
// ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ //
//  -----------------------------------------------------------------------------------------------------------------
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © prosum_solutions
//  -----------------------------------------------------------------------------------------------------------------
//
//  Author:   prosum_solutions
//  Revision: v1.1.0
//  Date:     02-Dec-2023
//  
//  Description
//  ===========
//  This indicator was inspired by the work of "informanerd" in the script called "HTF Candles" as well as the 
//  built-in script called "Multi-Time Period Charts" by TradingView.  The script will provide a highly 
//  customizable interface to specify the higher timeframe for the candlesticks, the type of candle, as well as 
//  various styling options for the body, border, and wicks.
//
//  Revisions:
//  ==========
//  v1.0.0 - Initial Release
//  v1.0.1 - Patch Release
//           > Added a new "Show Label" checkbox to display the resolution value as a label on the last candle.
//           > Fixed a defect where the HTF candle was not drawing when the time is on the boundary of the HTF resolution.
//           > Fixed a defect where the using the 12H timeframe would not render the candles properly.
//           > Renamed the "Candle" option to "Normal" for the "Candle Type" input.
//           > Update emoji placement in color inputs.
//           > Update the maximum values of the width inputs from 5 to 10.
//  v1.0.2 - Patch Release
//           > Added validation on the "Resolution" input value and display an error message if the value is not higher than the current chart resolution.
//           > Enhanced the value of the resolution label to include the units of either "minutes", "hours", "days", "weeks", or "months".
//  v1.0.3 - Patch Release
//           > Addressing a possible repaint issue by removing the High, Low, and Close plots for the Data Window.
//  v1.0.4 - Patch Release
//           > Converted the Pine Script code to version 5.
//           > Fixed a defect where the right-side candle boundary would end in the center of the new HTF resolution.
//             There will now be a one candle width spacing between HTF candles.
//  v1.0.5 - Patch Release
//           > Added a new "Offset" input to shift the candlesticks either to the left or to the right for the given number of bars.
//           > Added a new "Time to close" checkbox, position, and text-size options for the time to close text inside the candle body.
//           > Fixed a defect where the candles were not rendering properly on charts that have defined trading sessions less than 24 hours.
//           > Fixed a defect where disabling the body color of the HTF candles would remove the timeframe label frame.
//           > Fixed a defect where disabling the border color of the HTF candles would remove the timeframe label text.
//           > Improved rendering performance by not deleting and recreating boxes, lines, and labels on every tick.
//           > Removed the error label that displays when the timeframe of the chart is greater than the indicator timeframe in favor of the new `runtime.error()` function.
//           > Removed the custom `stringEndsWith()` function in favor of the new `str.endswith()` function.
//           > Renamed the "Resolution" input to "Timeframe" to conform to the terminology in TradingView and Pine Script. This includes tool tips and code variable names.
//  v1.0.6 - Patch Release
//           > Added a new "Custom" timeframe checkbox and two inputs to define a custom multiplier and period values for the HTF candles.
//           > Added a new "Visible Chart Only Mode" checkbox to enable drawing candles on the visible portion of the chart only.
//           > Fixed a defect when using extremely high timeframes relative to the current chart would cause a study error: 'Objects... cannot be drawn further than 500 bars into the future'.
//           > Fixed a defect where the "Time to close" label text color was not matching the candle color when the direction of the real-time candle would change from rising to falling or vice versa.
//           > Grouped the "Timeframe", "Custom", "Candle Type", and "Offset" inputs into their own section called "CANDLE SETTINGS"
//           > Removed the use of the 12 hour timeframe when choosing a timeframe higher than 60 minutes in order to default to daily instead. Comments for the determineDefaultTimeframe() function were updated to clarify the logic.
//           > Renamed the "CANDLE STYLE" section to "CANDLE STYLE & CONTENT".
//           > Updated the convertTimeLeftToCloseToLabelText() function to include the number of months, weeks, and days remaining in the time to close value (when available).
//  v1.0.7 - Patch Release
//           > Fixed a defect where the Time to Close content was not printing on the first candle of the period.
//  v1.0.8 - Patch Release
//           > Fixed a defect where the `request.security()` function does not return data on the `TVC:SPX` weekly chart and gives an inaccurate runtime error message.
//  v1.0.9 - Patch Release
//           > Added support for "Bars" as a "Candle Type" option.
//           > Added the new "BAR STYLE & CONTENT" section with inputs to define the bar styles and content.
//           > Renamed the "Normal" option to "Candles" for the "Candle Type" input.
//           > Replaced the "🎨" emoji with "▲" and "▼" characters for the rising and falling color selectors.
//  v1.0.10 - Patch Release
//           > Added tool tip content to the "Visible Chart Only Mode" check-box.
//           > Fixed a defect where some specific Forex markets (e.g. FX:GBPJPY) would not supply monthly high timeframe data using the `request.security()` function on the first bar index (0), therefore a runtime error was raised prematurely.
//           > Fixed a defect where the candle wick lines were being rendered when the "Candle Type" is "Bars". This should allow for more bars to render since lines are limited to 500 total.
//  v1.0.11 - Patch Release
//           > Added support for "Equilibrium Price Line" and a new section with inputs to define the line style.
//           > Added the "HTF Equilibrium" data point to the Data Window to see the price value as you hover your mouse over the candles.
//           > Fixed a defect where a few of the font icons that do not render on macOS.
//  v1.1.0  - Minor Release
//           > Added "HTF Setting Code" data point to link other indicators like the "HTF Volume by Prosum Solutions" to automatically respond to the "Timeframe" setting value.
//           > Fixed a defect where the `request.security()` function does not return data for the `EIGHTCAP:XAUUSD` symbol on March 13, 2023 for about 5 consecutive candles with a chart timeframe of 30 minute using the 4 hour High Timeframe setting in the indicator.
//           > Fixed some spelling errors.
//
//
// ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ //

//@version=5
indicator(title = 'BM 15m',
          shorttitle = 'BM 15m',
          overlay = true,
          max_lines_count = 500,
          max_boxes_count = 250)
          // 'overlay' value of 'true' will overlay the plots onto the main chart.
          // 'max_lines_count' value of '500' to set the maximum number of wick lines to be displayed. Each box will have 2 lines.
          // 'max_boxes_count' value of '250' to set the maximum number of candle bodies to be displayed. Reduced to half of the lines.

import PineCoders/VisibleChart/4 as VisibleChart


// ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ //

// === INPUTS === 

// Constant Labels...
var string CT_CANDLES = 'Candles'
var string CT_HEIKIN_ASHI = 'Heikin Ashi'
var string CT_BARS = 'Bars'

var string CP_MIN = 'min(s)'
var string CP_HOUR = 'hour(s)'
var string CP_DAY = 'day(s)'
var string CP_WEEK = 'week(s)'
var string CP_MONTH = 'month(s)'

var string LS_SOLID = '― Solid'
var string LS_DOTTED = '┉ Dotted'
var string LS_DASHED = '╍ Dashed'

// input(defval, title, type, minval, maxval, confirm, step, options)

var string VERSION = input.string(title = 'ℹ️ Version:', defval = 'v1.1.0', tooltip = 'Displays the published version of the indicator. Informational use only.')

var string CANDLE_SETTINGS_GROUP  = 'CANDLE SETTINGS'
var string TIMEFRAME            = input.timeframe(title = '⌚ Timeframe: ', defval = '', inline = 'TIMEFRAME_AND_LABEL', group = CANDLE_SETTINGS_GROUP)
var bool   SHOW_TIMEFRAME_LABEL = input.bool(title = 'Show Label', defval = true, inline = 'TIMEFRAME_AND_LABEL', group = CANDLE_SETTINGS_GROUP, tooltip = 'Timeframe: The higher timeframe for the candlestick dimensions to overlayed onto the chart. When the `Chart` option is chosen, the indicator will attempt to find a higher timeframe to ensure the candlesticks are drawn.\n\nShow Label: When checked, the timeframe value will display on the last bar.')
var bool   USE_CUSTOM_TIMEFRAME = input.bool(title = '└─> Custom:', defval = false, inline = 'USE_CUSTOM_TIMEFRAME', group = CANDLE_SETTINGS_GROUP)
var int    CUSTOM_MULTIPLIER    = input.int(title = '', defval = 1, minval = 1, maxval = 365, inline='USE_CUSTOM_TIMEFRAME', group = CANDLE_SETTINGS_GROUP, tooltip = 'When checked, the higher timeframe candlesticks will use the provided custom timeframe value instead.\n\nThe following are the multiplier limitations by period:\n`min(s)` period = cannot be greater than 60,\n`hour(s)` period = cannot be greater than 24,\n`day(s)` period = cannot be greater than 365,\n`week(s)` period = cannot be greater than 52,\n`month(s)` period = cannot be greater than 12')
var string CUSTOM_PERIOD        = input.string(title = '', defval = CP_MIN, options = [CP_MIN, CP_HOUR, CP_DAY, CP_WEEK, CP_MONTH], inline='USE_CUSTOM_TIMEFRAME', group = CANDLE_SETTINGS_GROUP)
var string CANDLE_TYPE          = input.string(title = '⧮ Candle Type:', defval = CT_CANDLES, options = [CT_CANDLES, CT_HEIKIN_ASHI, CT_BARS], group = CANDLE_SETTINGS_GROUP, tooltip = 'Sets the candle type to draw.')
var int    OFFSET               = input.int(title = '⇄ Offset:', defval = 0, minval = -500, maxval = 500, group = CANDLE_SETTINGS_GROUP, tooltip='Shifts the candlesticks either to the left or to the right for the given number of bars. Minimum value is -500. Maximum value is 500.')
var bool   VISIBLE_CHART_ONLY   = input.bool(title = '📊 Visible Chart Only Mode', defval = false, group = CANDLE_SETTINGS_GROUP, tooltip = 'When checked, the candlesticks/bars will render only in the visible portion of the chart. Adjusting the visible areas of the chart will regenerate the candlesticks/bars.')

var string CANDLE_STYLE_SETTINGS_GROUP = 'CANDLE STYLE & CONTENT'
var bool   ENABLE_BODY_COLOR    = input.bool(title = 'Body : ', defval = true, inline = 'BODY_COLORS', group = CANDLE_STYLE_SETTINGS_GROUP)
var color  RISING_BODY_COLOR    = input.color(title = '▲', defval = color.rgb(2, 252, 77, 90), inline = 'BODY_COLORS', group = CANDLE_STYLE_SETTINGS_GROUP)
var color  FALLING_BODY_COLOR   = input.color(title = '▼', defval = #f500001a, inline = 'BODY_COLORS', group = CANDLE_STYLE_SETTINGS_GROUP, tooltip = 'When checked, it will set the body fill color for the rising and falling candlesticks.')

var bool   ENABLE_BORDER_COLOR  = input.bool(title = 'Borders:', defval = true, inline = 'BORDER_COLOR_AND_WIDTH', group = CANDLE_STYLE_SETTINGS_GROUP)
var color  RISING_BORDER_COLOR  = input.color(title = '▲', defval = color.rgb(0, 255, 21, 25), inline = 'BORDER_COLOR_AND_WIDTH', group = CANDLE_STYLE_SETTINGS_GROUP)
var color  FALLING_BORDER_COLOR = input.color(title = '▼', defval = color.rgb(255, 1, 1, 28), inline = 'BORDER_COLOR_AND_WIDTH', group = CANDLE_STYLE_SETTINGS_GROUP)
var int    BORDER_WIDTH         = input.int(title = '╽ Width:', defval = 1, minval = 1, maxval = 10, inline = 'BORDER_COLOR_AND_WIDTH', group = CANDLE_STYLE_SETTINGS_GROUP, tooltip = 'When checked, it will set the body border color for the rising and falling candlesticks as well as the line width. Minimum value is 1. Maximum value is 10.')

var bool   ENABLE_WICK_COLOR    = input.bool(title = 'Wick : ', defval = true, inline = 'WICK_COLOR_AND_WIDTH', group = CANDLE_STYLE_SETTINGS_GROUP)
var color  RISING_WICK_COLOR    = input.color(title = '▲', defval = color.rgb(0, 255, 21, 25), inline = 'WICK_COLOR_AND_WIDTH', group = CANDLE_STYLE_SETTINGS_GROUP)
var color  FALLING_WICK_COLOR   = input.color(title = '▼', defval = color.rgb(255, 1, 1, 28), inline = 'WICK_COLOR_AND_WIDTH', group = CANDLE_STYLE_SETTINGS_GROUP)
var int    WICK_WIDTH           = input.int(title = '╽ Width:', defval = 2, minval = 1, maxval = 10, inline = 'WICK_COLOR_AND_WIDTH', group = CANDLE_STYLE_SETTINGS_GROUP, tooltip = 'When checked, it will set the wick color for the rising and falling candlesticks as well as the line width. Minimum value is 1. Maximum value is 10.')

var string LINE_STYLE           = input.string(title = '  Line Style: ', defval=LS_SOLID, options=[LS_SOLID, LS_DOTTED, LS_DASHED], inline = 'LINE_STYLE', group = CANDLE_STYLE_SETTINGS_GROUP, tooltip = 'Sets the line style for both the candlestick body and wicks.')

var bool   ENABLE_TIME_LEFT     = input.bool(title = 'Time to close:', defval = true, group = CANDLE_STYLE_SETTINGS_GROUP, tooltip = 'When checked, the time remaining to candle close will display within the body of the candle.\n\n`Position` and `Text Size` drop-downs are available to adjust the text further.')
var string TIME_LEFT_VALIGN     = input.string(title = '  Position: ↕', defval = text.align_center, options = [text.align_top, text.align_center, text.align_bottom], inline = 'TIME_LEFT_POSITION', group = CANDLE_STYLE_SETTINGS_GROUP)
var string TIME_LEFT_HALIGN     = input.string(title = ' ↔', defval = text.align_center, options = [text.align_left, text.align_center, text.align_right], inline = 'TIME_LEFT_POSITION', group = CANDLE_STYLE_SETTINGS_GROUP)
var string TIME_LEFT_TEXT_SIZE  = input.string(title='  Text Size:', defval = size.normal, options = [size.tiny, size.small, size.normal, size.large, size.huge], inline = 'TIME_LEFT_TEXT_SIZE', group = CANDLE_STYLE_SETTINGS_GROUP)

var string BAR_STYLE_SETTINGS_GROUP = 'BAR STYLE & CONTENT'
var color  RISING_BAR_COLOR         = input.color(title = 'Bar Style: ▲', defval = color.new(#26A69A, 60), inline = 'BAR_COLOR_AND_WIDTH', group = BAR_STYLE_SETTINGS_GROUP)
var color  FALLING_BAR_COLOR        = input.color(title = '▼', defval = color.new(#EF5350, 60), inline = 'BAR_COLOR_AND_WIDTH', group = BAR_STYLE_SETTINGS_GROUP)
var int    BAR_WIDTH                = input.int(title = '╽ Width:', defval = 5, minval = 1, maxval = 10, inline = 'BAR_COLOR_AND_WIDTH', group = BAR_STYLE_SETTINGS_GROUP, tooltip = 'When checked, it will set the bar color for the rising and falling bars as well as the line width. Minimum value is 1. Maximum value is 10.')
var bool   ENABLE_HLC_BARS          = input.bool(title = 'HLC Bars', defval = false, group = BAR_STYLE_SETTINGS_GROUP, tooltip = 'When checked, only the high/low, and close bars are drawn.')
var bool   SHOW_TIME2CLOSE_IN_LABEL = input.bool(title = 'Show "Time to close" in "Timeframe" label', defval = true, group = BAR_STYLE_SETTINGS_GROUP, tooltip = 'When checked, the time remaining to candle close will display beneath the timeframe label text. This will require that the `Show Label` checkbox be checked to see the time.')

var string EQUILIBRIUM_STYLE_SETTINGS_GROUP = 'EQUILIBRIUM STYLE'
var bool   SHOW_EQUILIBRIUM_LINE = input.bool(title = 'Show Equilibrium Price Line', defval = false, group = EQUILIBRIUM_STYLE_SETTINGS_GROUP, tooltip = 'When checked, a line will be drawn at the equilibrium price line of the candlestick, which is the midpoint between the high and low of the candle/bar.')
var string EQUILIB_LINE_STYLE    = input.string(title = '  Line Style:', defval=LS_DOTTED, options=[LS_SOLID, LS_DOTTED, LS_DASHED], inline = 'EQUILIB_LINE_STYLE_AND_COLOR', group = EQUILIBRIUM_STYLE_SETTINGS_GROUP)
var color  EQUILIB_LINE_COLOR    = input.color(title = '', defval = color.new(color.orange, 15), inline = 'EQUILIB_LINE_STYLE_AND_COLOR', group = EQUILIBRIUM_STYLE_SETTINGS_GROUP, tooltip = 'Sets the line style and color for the equilibrium price line.')
var int    EQUILIB_LINE_WIDTH    = input.int(title = '  ╽ Width: ', defval = 2, minval = 1, maxval = 10, inline = 'EQUILIB_LINE_WIDTH', group = EQUILIBRIUM_STYLE_SETTINGS_GROUP, tooltip = 'Sets the line width for the equilibrium price line. Minimum value is 1. Maximum value is 10.')


// ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ //

// === GLOBAL VARIABLES SETUP === 

// Candle drawings...
var box   realtimeCandleBody = na
var line  realtimeCandleUpperWick = na
var line  realtimeCandleLowerWick = na

// Candle positioning...
var int candleBodyLeftBarIndex = bar_index
var int candleBodyRightBarIndex = na
var int candleBodyMidpointBarIndex = na

// Candle Colors...
var color candleBodyColor = na
var color candleBorderColor = na
var color candleWickColor = na
var color labelBgdColor = na
var color labelTextColor = na

// Bar drawings...
var line  realtimeBar = na
var line  realtimeBarOpen = na
var line  realtimeBarClose = na

// Bar Color...
var color barLineColor = na

// Equilibrium line...
var line  equilibriumLine = na


// ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ //

// === FUNCTIONS === 

// ----------------------------------------------------------------------
// Determines the default timeframe to set based on the current chart timeframe.
// Special conditions are applied for minute and monthly charts: 
//   1) If the timeframe multiplier is less than 60 minutes, then the 1H
//      timeframe is chosen as the default; if the timeframe multiplier is greater 
//      than 60 minutes, then the 1 Day is chosen as the default.
//   2) If the timeframe multiplier is less than 6 months, then the 6M
//      timeframe is chosen as the default; if the timeframe is greater 
//      than 6M, then the 12M is chosen as the default.
//
// @see https://www.tradingview.com/pine-script-reference/v5/#var_timeframe{dot}period
//
// @returns {string} the new higher timeframe.
// ----------------------------------------------------------------------
determineDefaultTimeframe() =>
    timeframe.isseconds ? '1' :
     timeframe.isminutes ? timeframe.multiplier < 60 ? '60' : '1440' : // 1440 mins = 1 Day
     timeframe.isdaily ? 'W' :
     timeframe.isweekly ? 'M' :
     timeframe.ismonthly and timeframe.multiplier < 6 ? '6M' : '12M'


// ----------------------------------------------------------------------
// Builds the timeframe value for the security() function from the 
// CUSTOM_MULTIPLIER & CUSTOM_PERIOD input values.
//
// @see https://www.tradingview.com/pine-script-reference/v5/#var_timeframe{dot}period
//
// @returns {string} the timeframe.
// ----------------------------------------------------------------------
buildCustomTimeframe() =>
    string customTimeframe = switch CUSTOM_PERIOD
        CP_MIN   => str.tostring(CUSTOM_MULTIPLIER) // The minutes & hour period has no unit suffix
        CP_HOUR  => str.tostring(CUSTOM_MULTIPLIER * 60) // The hour period is quantified in minutes
        CP_DAY   => str.tostring(CUSTOM_MULTIPLIER) + 'D'
        CP_WEEK  => str.tostring(CUSTOM_MULTIPLIER) + 'W'
        CP_MONTH => str.tostring(CUSTOM_MULTIPLIER) + 'M'
    customTimeframe


// ----------------------------------------------------------------------
// Determines the candlestick color based on the price action direction.
// If there is no direction, then the current color is maintained.
//
// @param {bool} `_isFalling` an indicator that the candle is falling in price.
// @param {bool} `_isRising` an indicator that the candle is rising in price.
// @param {color} `_fallingColor` the color to return if the candle is falling.
// @param {color} `_risingColor` the color to return if the candle is rising.
// @param {color} `_currentColor` the current color.
//
// @returns {color} the new candlestick color.
// ----------------------------------------------------------------------
determineDirectionColor(bool _isFalling, bool _isRising, color _fallingColor, color _risingColor, color _currentColor) =>
    _isFalling ? _fallingColor :
     _isRising ? _risingColor :
     _currentColor


// ----------------------------------------------------------------------
// Returns the candle line style base in the input values.
//
// @param {string} `_line_style` the line style setting value.
//
// @returns {string} the line style constant.
// ----------------------------------------------------------------------
getCandleLineStyle(string _line_style) =>
    _line_style == LS_SOLID ? line.style_solid :
     _line_style == LS_DOTTED ? line.style_dotted :
     line.style_dashed


// ----------------------------------------------------------------------
// Returns the label style based on the given candle direction.
//
// @param {bool} `_isFalling` an indicator that the candle is falling in price.
//
// @returns {string} the label style constant.
// ----------------------------------------------------------------------
getLabelStyle(bool _isFalling) =>
    ( _isFalling ) ? label.style_label_lower_left : label.style_label_upper_left


// ----------------------------------------------------------------------
// Converts the timeframe value from the input into a tuple of two numeric
// values: 1) the multiplier, and 2) the period unit.
//
// @param {string} `_timeframe` the timeframe value.
//
// @returns {tuple[2]} A tuple of the multiple and period unit
// ----------------------------------------------------------------------
convertTimeframeToMultiplierAndUnit(string _timeframe) =>
    // First determine if the period is daily ('D'), weekly ('W'), or monthly ('M')...
    bool isDaily = str.endswith(_timeframe, 'D')
    bool isWeekly = str.endswith(_timeframe, 'W')
    bool isMonthly = str.endswith(_timeframe, 'M')
    string multiplierAsText = _timeframe

    // Remove the trailing period character to get the multiplier...
    if isDaily
        multiplierAsText := str.replace_all(multiplierAsText, 'D', '')
    else if isWeekly
        multiplierAsText := str.replace_all(multiplierAsText, 'W', '')
    else if isMonthly
        multiplierAsText := str.replace_all(multiplierAsText, 'M', '')
    //end if

    // If the multiplier is missing, assume a value of 1...
    int multiplier = ( str.length(multiplierAsText) == 0 ) ? 1 : int(str.tonumber(multiplierAsText))

    // Determine the timeframe label based on period that was detected...
    int unit = 0 // minute
    if isMonthly
        unit := 4
    else if isWeekly
        unit := 3
    else if isDaily
        unit := 2
    else if multiplier >= 60
        multiplier /= 60
        unit := 1
    else
        unit := 0
    //end if

    [multiplier, unit]


// ----------------------------------------------------------------------
// Converts the timeframe value from the input into a numeric code to be
// parsed by other indicators that link to the "HTF Setting Code" data point.
//
// @param {string} `_timeframe` the timeframe value.
//
// @returns {float} the setting code.
// ----------------------------------------------------------------------
convertTimeframeToSettingCode(string _timeframe) =>
    [multiplier, unit] = convertTimeframeToMultiplierAndUnit(_timeframe)
    float settingCode = float(multiplier + (unit > 0 ? unit / 10 : unit))
    settingCode


// ----------------------------------------------------------------------
// Converts the timeframe value from the input into a human readable 
// value with units for presenting in a label.
//
// @param {string} `_timeframe` the timeframe value.
//
// @returns {string} the human readable timeframe txt with units.
// ----------------------------------------------------------------------
convertTimeframeToLabelText(string _timeframe) =>
    [multiplier, unit] = convertTimeframeToMultiplierAndUnit(_timeframe)
    string pluralSuffix = ( ( multiplier > 1 ) ? 's' : '' )
    string unitAsText = switch unit
        0 => ' minute'
        1 => ' hour'
        2 => ' day'
        3 => ' week'
        4 => ' month'
    string timeframeLabelText = str.tostring(multiplier) + unitAsText + pluralSuffix
    timeframeLabelText


// ----------------------------------------------------------------------
// Determines the candlestick midpoint in bar_index units.
//
// @param {int} `_projectedRightBarIndex` the bar_index of the right-side of the candlestick body.
//
// @returns {int} the candlestick midpoint in bar_index units.
// ----------------------------------------------------------------------
calculateCandleBodyMidpointBarIndex(int _projectedRightBarIndex)=>
    candleBodyLeftBarIndex + math.ceil( ( _projectedRightBarIndex - candleBodyLeftBarIndex ) / 2 )


// ----------------------------------------------------------------------
// Reduces the given proposed future bar index to the maximum allowable value.
// This is needed to prevent a run-time error from the chart rendering engine
// because it cannot position object drawings further than 500 bars into the future.
//
// @see https://www.tradingview.com/pine-script-docs/en/v4/essential/Drawings.html#bars-count-in-future-with-xloc-bar-index
//
// @param {int} `_proposedFutureBarIndex` the proposed future bar index.
//
// @returns {int} Returns either the the proposed future bar index OR the maximum bar index.
// ----------------------------------------------------------------------
reduceFutureBarIndexToMaximum(int _proposedFutureBarIndex)=>
    ( _proposedFutureBarIndex - last_bar_index > 500 ) ?  last_bar_index + 500 : _proposedFutureBarIndex


// ----------------------------------------------------------------------
// Converts the HTF time left to close value into a formatted value of HH:mm:ss 
// for presenting in a label.  If the time remaining is greater than 24 hours,
// the label will include months, weeks, and days remaining as well.
//
// @param {int} `_timeLeftInMilliseconds` the time left to close in milliseconds.
//
// @returns {string} the formatted time left to close using 'M w d hh:mm:ss' format.
// ----------------------------------------------------------------------
convertTimeLeftToCloseToLabelText(int _timeLeftInMilliseconds)=>
    string timeLeftToClose = ''
    int timeLeftInMilliseconds = _timeLeftInMilliseconds
    // If the time to close is greater than 24 hours, include the months, weeks, or days units...
    if not na(timeLeftInMilliseconds) and timeLeftInMilliseconds >= 86400000
        // Milliseconds in a month: https://www.calculateme.com/time/months/to-milliseconds/1
        int months = math.floor(timeLeftInMilliseconds / 2629746000)
        timeLeftInMilliseconds := (months > 0) ? timeLeftInMilliseconds % 2629746000 : timeLeftInMilliseconds
        // Milliseconds in a week: https://www.calculateme.com/time/weeks/to-milliseconds/1
        int weeks = math.floor(timeLeftInMilliseconds / 604800000)
        timeLeftInMilliseconds := (weeks > 0) ? timeLeftInMilliseconds % 604800000 : timeLeftInMilliseconds
        // Milliseconds in a day: https://www.calculateme.com/time/days/to-milliseconds/1
        int days = math.floor(timeLeftInMilliseconds / 86400000)
        timeLeftInMilliseconds := (days > 0) ? timeLeftInMilliseconds % 86400000 : timeLeftInMilliseconds
        timeLeftToClose += (months > 0 ? str.tostring(months) + 'M ' : '')
        timeLeftToClose += (weeks > 0 ? str.tostring(weeks) + 'w ' : '')
        timeLeftToClose += (days > 0 ? str.tostring(days) + 'd ' : '')
    //end if
    timeLeftToClose += str.format("{0,date,HH:mm:ss}", timeLeftInMilliseconds)
    timeLeftToClose


// ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ //

// === INDICATOR LOGIC === 

// Determine the symbol type and default timeframe and its label text...
var string securitySymbol = CANDLE_TYPE == CT_HEIKIN_ASHI ? ticker.heikinashi(syminfo.tickerid) : syminfo.tickerid
var string securityTimeframe = USE_CUSTOM_TIMEFRAME ? buildCustomTimeframe() :
                               TIMEFRAME == '' ? determineDefaultTimeframe() : TIMEFRAME
var string timeframeAsLabelText = convertTimeframeToLabelText(securityTimeframe)
var float  timeframeAsSettingCode = convertTimeframeToSettingCode(securityTimeframe)

// Some symbols do not provide HTF market data for an undetermined amount of bars, so this is an attempt to
// tolerate missing data for a specific range of bars (7 for now) and resume normal functionality if data is
// received before it hits the maximum limit.
var int countOfBarsMissingData = 0
var int maxCountOfBarsMissingData = 7

// Get candlestick OHLC, time, and time to close using  security function with lookahead on to get the latest data...
[htfOpen, htfHigh, htfLow, htfClose, htfTime, htfTimeClose] = request.security(symbol = securitySymbol, 
                                                                               timeframe = securityTimeframe, 
                                                                               expression = [open, high, low, close, time, time_close], 
                                                                               lookahead = barmerge.lookahead_on)

// Ensure we have data for successful script execution. Some symbols will give data after a bar_index of 0...
if bar_index > 0 and (na(htfTimeClose) or na(htfTime))
    countOfBarsMissingData += 1
    if ( countOfBarsMissingData > maxCountOfBarsMissingData )
        runtime.error('The request for higher timeframe data for the current symbol did not return enough information to execute successfully. Select a different timeframe and try again.')
    //end if
else
    countOfBarsMissingData := 0
//end if

// Calculate the number of current chart bars in a single HTF candle...
var int htfTimePeriodPerCandle = htfTimeClose - htfTime
var int timePeriodPerCandle = time_close - time
var int numberOfBarsInHtfCandle = int(htfTimePeriodPerCandle/timePeriodPerCandle) - 1

// If HTF data was given after bar_index 0, then re-initialize our parameters above...
if bar_index > 0 and (na(htfTimeClose[1]) or na(htfTime[1]))
    htfTimePeriodPerCandle := htfTimeClose - htfTime
    timePeriodPerCandle := time_close - time
    numberOfBarsInHtfCandle := int(htfTimePeriodPerCandle/timePeriodPerCandle) - 1
//end if

// Determine if securityTimeframe is higher than the current chart timeframe. If not, throw a runtime error...
bool isTimeframeHigherThanChart = htfTimePeriodPerCandle > timePeriodPerCandle
if bar_index > 0 and not isTimeframeHigherThanChart and countOfBarsMissingData > maxCountOfBarsMissingData
    if USE_CUSTOM_TIMEFRAME
        runtime.error('The `Custom` timeframe input values must be higher than the current chart timeframe.')
    else
        runtime.error('The `Timeframe` input value must be higher than the current chart timeframe.')
    //end if
//end if

// Determine if we are starting a new candle...
bool isTimeframeChanged = timeframe.change(securityTimeframe)
bool doDrawCandle = VISIBLE_CHART_ONLY ? VisibleChart.barIsVisible() : true

if isTimeframeChanged
    // Prevent overlapping candles on charts with gaps in bar data, thus the right-side of the candle body may not be correct anymore...
    if bar_index[1] != candleBodyRightBarIndex
        // Re-calculate the right-side position of the candle body...
        int newCandleBodyRightBarIndex = bar_index[1] + OFFSET
        int newCandleBodyMidpointBarIndex = calculateCandleBodyMidpointBarIndex(newCandleBodyRightBarIndex)
        if CANDLE_TYPE == CT_BARS
            // Move bar...
            line.set_x1(realtimeBar, newCandleBodyMidpointBarIndex)
            line.set_x2(realtimeBar, newCandleBodyMidpointBarIndex)
            // Move bar open...
            line.set_x2(realtimeBarOpen, newCandleBodyMidpointBarIndex)
            // Move bar close...
            line.set_x1(realtimeBarClose, newCandleBodyMidpointBarIndex)
            line.set_x2(realtimeBarClose, newCandleBodyRightBarIndex)
        else
            // Reset the right position...
            box.set_right(realtimeCandleBody, newCandleBodyRightBarIndex)
            // Move the candle wicks...
            line.set_x1(realtimeCandleUpperWick, newCandleBodyMidpointBarIndex)
            line.set_x2(realtimeCandleUpperWick, newCandleBodyMidpointBarIndex)
            line.set_x1(realtimeCandleLowerWick, newCandleBodyMidpointBarIndex)
            line.set_x2(realtimeCandleLowerWick, newCandleBodyMidpointBarIndex)
        //end if
    //end if

    // Calculate candlestick left/right bar index position...
    candleBodyLeftBarIndex := bar_index + OFFSET
    candleBodyRightBarIndex := reduceFutureBarIndexToMaximum(candleBodyLeftBarIndex + numberOfBarsInHtfCandle)
    candleBodyMidpointBarIndex := reduceFutureBarIndexToMaximum(calculateCandleBodyMidpointBarIndex(candleBodyRightBarIndex))
//end if

// Calculate candlestick top/bottom dimensions...
float candleBodyTop = math.max(htfOpen, htfClose)
float candleBodyBottom = math.min(htfOpen, htfClose)
float equilibriumPrice = (htfHigh-htfLow)/2 + htfLow

// Determine the candlestick body, border and wick colors based on price action direction...
bool isFalling = htfOpen > htfClose
bool isRising = htfOpen < htfClose
candleBodyColor := ENABLE_BODY_COLOR ? determineDirectionColor(isFalling, isRising, FALLING_BODY_COLOR, RISING_BODY_COLOR, candleBodyColor) : na
candleBorderColor := ENABLE_BORDER_COLOR ? determineDirectionColor(isFalling, isRising, FALLING_BORDER_COLOR, RISING_BORDER_COLOR, candleBorderColor) : na
candleWickColor := ENABLE_WICK_COLOR ? determineDirectionColor(isFalling, isRising, FALLING_WICK_COLOR, RISING_WICK_COLOR, candleWickColor) : na
barLineColor := CANDLE_TYPE == CT_BARS ? determineDirectionColor(isFalling, isRising, FALLING_BAR_COLOR, RISING_BAR_COLOR, barLineColor) : na
labelBgdColor := determineDirectionColor(isFalling, isRising, FALLING_BODY_COLOR, RISING_BODY_COLOR, labelTextColor)
labelTextColor := determineDirectionColor(isFalling, isRising, FALLING_BORDER_COLOR, RISING_BORDER_COLOR, labelTextColor)

// Calculate the time to close...
string timeToCloseLabelText = ''
if barstate.islast
    int timeLeftInMilliseconds = (htfTimeClose - timenow)
    timeToCloseLabelText := convertTimeLeftToCloseToLabelText(timeLeftInMilliseconds)
//end if

if ( ENABLE_BODY_COLOR or ENABLE_BORDER_COLOR ) and doDrawCandle
    if CANDLE_TYPE == CT_BARS
        if isTimeframeChanged
            realtimeBar      := line.new(x1 = candleBodyMidpointBarIndex, y1 = htfHigh,  x2 = candleBodyMidpointBarIndex, y2 = htfLow,   color = barLineColor, style = getCandleLineStyle(LINE_STYLE), width = BAR_WIDTH)
            realtimeBarClose := line.new(x1 = candleBodyMidpointBarIndex, y1 = htfClose, x2 = candleBodyRightBarIndex,    y2 = htfClose, color = barLineColor, style = getCandleLineStyle(LINE_STYLE), width = BAR_WIDTH)
            if not ENABLE_HLC_BARS
                realtimeBarOpen  := line.new(x1 = candleBodyLeftBarIndex, y1 = htfOpen,  x2 = candleBodyMidpointBarIndex, y2 = htfOpen,  color = barLineColor, style = getCandleLineStyle(LINE_STYLE), width = BAR_WIDTH)
            //end if
        else
            // Bar...
            line.set_color(realtimeBar, barLineColor)
            line.set_y1(realtimeBar, htfHigh)
            line.set_y2(realtimeBar, htfLow)
            // Bar open...
            line.set_color(realtimeBarOpen, barLineColor)
            // Bar close...
            line.set_color(realtimeBarClose, barLineColor)
            line.set_y1(realtimeBarClose, htfClose)
            line.set_y2(realtimeBarClose, htfClose)
        //end if
    else
        if isTimeframeChanged

            // Clear the time left text now that the candle is closed...
            if ENABLE_TIME_LEFT
                box.set_text(realtimeCandleBody, '')
            //end if

            // Create the new candle body...
            realtimeCandleBody := box.new(left = candleBodyLeftBarIndex, top = candleBodyTop, right = candleBodyRightBarIndex, bottom = candleBodyBottom,
                                          bgcolor = candleBodyColor, border_color = candleBorderColor, border_width = BORDER_WIDTH, border_style = getCandleLineStyle(LINE_STYLE))

            // Setup the time left to close text settings...
            if ENABLE_TIME_LEFT
                box.set_text_size(realtimeCandleBody, TIME_LEFT_TEXT_SIZE)
                box.set_text_halign(realtimeCandleBody, TIME_LEFT_HALIGN)
                box.set_text_valign(realtimeCandleBody, TIME_LEFT_VALIGN)
            //end if
        else
            // Set the colors based on candle direction...
            box.set_border_color(realtimeCandleBody, candleBorderColor)
            box.set_bgcolor(realtimeCandleBody, candleBodyColor)
            box.set_top(realtimeCandleBody, candleBodyTop)
            box.set_bottom(realtimeCandleBody, candleBodyBottom)
        //end if

        if ENABLE_TIME_LEFT
            box.set_text_color(realtimeCandleBody, labelTextColor)
            box.set_text(realtimeCandleBody, timeToCloseLabelText)
        //end if
    //end if
//end if

if ENABLE_WICK_COLOR and CANDLE_TYPE != CT_BARS and doDrawCandle
    if isTimeframeChanged
        realtimeCandleUpperWick := line.new(x1 = candleBodyMidpointBarIndex, y1 = htfHigh,          x2 = candleBodyMidpointBarIndex, y2 = candleBodyTop, color = candleWickColor, style = getCandleLineStyle(LINE_STYLE), width = WICK_WIDTH)
        realtimeCandleLowerWick := line.new(x1 = candleBodyMidpointBarIndex, y1 = candleBodyBottom, x2 = candleBodyMidpointBarIndex, y2 = htfLow,        color = candleWickColor, style = getCandleLineStyle(LINE_STYLE), width = WICK_WIDTH)
    else
        // Upper Wick...
        line.set_color(realtimeCandleUpperWick, candleWickColor)
        line.set_y1(realtimeCandleUpperWick, htfHigh)
        line.set_y2(realtimeCandleUpperWick, candleBodyTop)
        // Lower Wick...
        line.set_color(realtimeCandleLowerWick, candleWickColor)
        line.set_y1(realtimeCandleLowerWick, candleBodyBottom)
        line.set_y2(realtimeCandleLowerWick, htfLow)
    //end if
//end if

if SHOW_TIMEFRAME_LABEL and doDrawCandle
    // Create the label once and simply move it going forward...
    var label realtimeCandleTimeframeLabel = label.new(x = candleBodyRightBarIndex, y = htfOpen, text = timeframeAsLabelText, color = labelBgdColor, style = getLabelStyle(isFalling), textcolor = labelTextColor, size = size.normal, textalign = text.align_left)
    
    if isTimeframeChanged
        // Move the label to the end of the new HTF candle's open price...
        label.set_xy(realtimeCandleTimeframeLabel, candleBodyRightBarIndex, htfOpen)
    //end if

    if CANDLE_TYPE == CT_BARS and SHOW_TIME2CLOSE_IN_LABEL
        var string originalTimeframeAsLabelText = timeframeAsLabelText
        timeframeAsLabelText := originalTimeframeAsLabelText + '\n' + timeToCloseLabelText
    //end if

    // Set the color and style of the label based on candle direction...
    label.set_color(realtimeCandleTimeframeLabel, labelBgdColor)
    label.set_textcolor(realtimeCandleTimeframeLabel, labelTextColor)
    label.set_style(realtimeCandleTimeframeLabel, getLabelStyle(isFalling))
    label.set_text(realtimeCandleTimeframeLabel, timeframeAsLabelText)
//end if

if SHOW_EQUILIBRIUM_LINE and doDrawCandle
    if isTimeframeChanged
        equilibriumLine := line.new(x1 = candleBodyLeftBarIndex, y1 = equilibriumPrice,  x2 = candleBodyRightBarIndex, y2 = equilibriumPrice, color = EQUILIB_LINE_COLOR, style = getCandleLineStyle(EQUILIB_LINE_STYLE), width = EQUILIB_LINE_WIDTH)
    else
        line.set_y1(equilibriumLine, equilibriumPrice)
        line.set_y2(equilibriumLine, equilibriumPrice)
    //end if
//end if


// ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ //

// === DATA WINDOW PLOTS === 

// Only the open price can be plotted since it should not cause a repaint because it will remain the same as new bars form...
plotchar(htfOpen, title = 'HTF Open', location = location.bottom, color = na, editable = false, display = display.data_window)
// plotchar(htfHigh, title = 'High', location = location.bottom, color = na, editable = false)
// plotchar(htfLow, title = 'Low', location = location.bottom, color = na, editable = false)
// plotchar(htfClose, title = 'Close', location = location.bottom, color = na, editable = false)

// Display the HTF Equilibrium value in the Data Window...
plotchar(equilibriumPrice, title = 'HTF Equilibrium', location = location.bottom, color = EQUILIB_LINE_COLOR, editable = false, display = display.data_window)

// Display the HTF Setting Code to use to link indicators together...
plot(timeframeAsSettingCode, title = 'HTF Setting Code', color = na, editable = false, display = display.data_window)

// ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ //

//EOF
````

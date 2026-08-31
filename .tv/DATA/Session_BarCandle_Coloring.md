<!-- tradingview-pine-id: PUB;d6d1232c88964789a958022d3aaa4fa9 -->
<!-- tradingviewscripts-format: 1 -->
# Session Bar/Candle Coloring

Source: https://www.tradingview.com/script/WsPypw8w-Session-Bar-Candle-Coloring/

## Description

Change the color of candles within a user-defined trading session.  Borders and wicks can be changed as well, not just the body color.

PREFACE
This script can be used an educational resource for those who are interested in learning Pine Script.  Therefore, the script is published open source and is organized in a manner that follows the recommended [Style Guide](https://www.tradingview.com/pine-script-docs/writing/style-guide/).
While the main premise of the indicator is rather simple, the script showcases various things that can be achieved such as conditional plotting, alignment of indicator settings, user input validation, script optimization, and more.  The script also has examples of taking into consideration the chart timeframe and/or different chart types (Heikin Ashi, Renko, etc.) that a user might be running it on.  Note: for complete beginners, I strongly suggest going through the [Pine Script User Manual](https://www.tradingview.com/pine-script-docs/) (possibly more than once).

FEATURES
Besides being able to select a specific time window, the indicator also provides additional color settings for changing the background color or changing the colors of neutral/indecisive candles, as shown in the image below.
[image]https://www.tradingview.com/x/2BFh3w33/[/image]
This allows for a higher level of customization beyond the TradingView chart settings or other similar scripts that are currently available.

HOW TO USE

[*] First, define the intraday trading session that will contain the candles to modify.  The session can be limited to specific days of the week.
[*] Next, select the parts of the candles that should be modified: Body, Borders, Wick, and/or Background.
[*] For each of the candle parts that were enabled, you can select the colors that will be used depending on whether a candle is bullish (⇧), bearish (⇩), or neutral (⇆).

All other indicator settings will have a detailed tooltip to describe its usage and/or effect.

LIMITATIONS

[*] The indicator is not intended to function on Daily or higher timeframes due to the intraday nature of session time windows.
[*] The indicator cannot always automatically detect the chart type being used, therefore the user is requested to manually input the chart type via the "Chart Style" setting.
[*] Depending on the available historical data and the selected choice for the "Portion of bar in session" setting, the indicator may not be able to update very old candles on the chart.

EXAMPLE USAGE
This section will show examples of different scenarios that the indicator can be used for.

[image]https://www.tradingview.com/x/H8adMGJE/[/image]
Emphasizing a main trading session.

[image]https://www.tradingview.com/x/eQqi9FWR/[/image]
Defining a "Pre/post market hours background" like is available for some symbols (e.g., [symbol="NASDAQ:AAPL"]NASDAQ:AAPL[/symbol]).

[image]https://www.tradingview.com/x/7PgocYC5/[/image]
Highlighting in which bar the midnight candle occurs.

[image]https://www.tradingview.com/x/Z7lo39A0/[/image]
Hiding indecision bars (neutral candles).

[image]https://www.tradingview.com/x/dPjm59Dw/[/image]
Showing only "Regular Trading Hours" for a chart that does not have the option to toggle ETH/RTH.  To achieve this, the actual chart data is hidden, and only the indicator is visible; alternatively, a 2nd instance of the indicator could change colors to match the chart background.

[image]https://www.tradingview.com/x/3ldNoQKd/[/image]
Using a combination of Bars and Japanese Candlesticks.  Alternatively, this could be done by hiding the main chart data and using 2 instances of the indicator (one with "Chart Style" setting as Bars, and the other set to Candles).

[image]https://www.tradingview.com/x/thBALrH8/[/image]
Using a combination of thin and thick bars on Range charts.  Note: requires disabling the "Thin Bars" setting for Bar charts in the TradingView chart settings.

NOTES

[*] If using more than one instance of this indicator on the same chart, you can use the TradingView "Save Indicator Template" feature to avoid having to re-configure the multiple indicators at a later time.
[*] This indicator is intended to work "out-of-the-box" thanks to the behind_chart option introduced to Pine Script in October 2024.  But you can always manually bring the indicator to the front just in case the color changes are not being seen (using the "More" option in the indicator status line: More > Visual Order > Bring to front).
[*] Many thanks to [fikira](https://www.tradingview.com/u/fikira/) for their help and inspiring me to create open source scripts.
[*] Any feedback including bug reports or suggestions for improving the indicator (or source code itself) are always welcome in the comments section.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © n00btraders

//@version=6
indicator(title = "Session Bar/Candle Coloring", shorttitle = "Bar Color", overlay = true, behind_chart = false)

import n00btraders/Timezone/1 as tz     // library to help with providing a timezone input in the indicator settings



//#region ------------------------------ CONSTANTS ------------------------------
const int       MAX_TRANSPARENCY                          = 100

const string    FIVE_MINUTE_TIMEFRAME                     = "5"
const string    ONE_MINUTE_TIMEFRAME                      = "1"

const string    INPUT_GROUP_SESSION                       = "User-Defined Session"
const string    INPUT_GROUP_COLORS                        = "Colors"
const string    INPUT_GROUP_FINE_TUNING                   = "Fine-Tune Selected Bars"

const string    CHART_STYLE_BARS                          = "Bars"
const string    CHART_STYLE_CANDLES                       = "Candles"
const string    CHART_STYLE_OTHER                         = "Other"

const string    BODY_COLOR_OVERLAY                        = "Overlay"
const string    BODY_COLOR_REPLACE                        = "Replace"

const string    BAR_OPEN_IN_SESSION                       = "Open"
const string    BAR_CLOSE_IN_SESSION                      = "Close"
const string    ALL_INTRABARS_IN_SESSION                  = "Entire Bar"
const string    ANY_INTRABAR_IN_SESSION                   = "Any 1m Intrabar"

const string    BULLISH_SYMBOL                            = "⇧"
const string    BEARISH_SYMBOL                            = "⇩"
const string    NEUTRAL_SYMBOL                            = "⇆"

const color     DEFAULT_BULLISH_COLOR                     = color.green
const color     DEFAULT_BEARISH_COLOR                     = color.red
const color     DEFAULT_NEUTRAL_COLOR                     = color.silver
const color     DEFAULT_BACKGROUND_COLOR                  = color.new(color.blue, 90)

const string    TOOLTIP_CHART_STYLE                       = "Select whether the chart is using\nbars or candlesticks (or neither)\n\n"
                                                             + "   ├\n   │      ←   bar\n   ┤\n\n\n"
                                                             + "    │\n    █      ←   candlestick\n    │\n "
const string    TOOLTIP_SESSION                           = "Define an intraday session to be detected\n\nSteps:\n"
                                                             + " 1. Input the beginning and ending time of day\n"
                                                             + " 2. Select the chart's timezone\n"
                                                             + " 3. Customize the relevant days of the week\n\n"
                                                             + "Note: the timezone list shows the\nUTC offsets in Standard Time (SDT),\n"
                                                             + "but Daylight Saving Time (DST) will\nautomatically be applied if necessary"
const string    TOOLTIP_COLOR_BASED_ON_PREVIOUS_CLOSE     = "Enable this option to compare the current bar's\nclose value to the previous bar's close value\n"
                                                             + "(instead of the current bar's open value)\nfor determining the bullish or bearish state"
const string    TOOLTIP_BODY_COLOR_IMPLEMENTATION         = "[𝗢𝘃𝗲𝗿𝗹𝗮𝘆]  overlays the new body color\non top of the existing color\n\n"
                                                             + "[𝗥𝗲𝗽𝗹𝗮𝗰𝗲]  replaces the original body color\nof the bar or candle\n\n"
                                                             + "Note: the difference will be noticeable when increasing the transparency of the body colors.\n"
                                                             + "This setting is mainly for Bar or Candle charts."
const string    TOOLTIP_BAR_IN_SESSION_DETERMINATION      = "Select the method for determining if a bar/candle belongs to the user-defined session\n\n\n"
                                                             + "Color of a bar/candle will be modified if:\n⸻⸻⸻⸻⸻⸻⸻\n"
                                                             + "[𝗢𝗽𝗲𝗻]  the opening tick of the bar is in session\n\n"
                                                             + "[𝗖𝗹𝗼𝘀𝗲]  the closing tick of the bar is in session\n\n"
                                                             + "[𝗘𝗻𝘁𝗶𝗿𝗲 𝗕𝗮𝗿]  the entire bar, from opening tick\nto closing tick, is in session\n\n"
                                                             + "[𝗔𝗻𝘆 𝟭𝗺 𝗜𝗻𝘁𝗿𝗮𝗯𝗮𝗿]  any portion of the bar is in session (open, close, or anything in between)"
const string    TOOLTIP_INVERT_SESSION                    = "Enable this option to instead modify the bars\nthat did NOT belong to the user-defined session"


// @enum               An enum type for the style of chart being used to display price action.
// @field BAR          Bar chart.
// @field CANDLESTICK  Japanese candlestick chart.
// @field OTHER        Any other chart style besides bar and candlestick.
enum ChartStyle
    BAR
    CANDLESTICK
    OTHER

// @enum           An enum type representing the bullish or bearish state of a bar/candle.
// @field BULLISH  A bullish bar.
// @field BEARISH  A bearish bar.
// @field NEUTRAL  An indecision bar.
enum BarDirection
    BULLISH
    BEARISH
    NEUTRAL

//#endregion



//#region ------------------------------ INPUTS ------------------------------
string  chartStyleInput                 = input.string (CHART_STYLE_CANDLES,       "Chart style",                         inline = "00", display = display.data_window, options = [CHART_STYLE_BARS, CHART_STYLE_CANDLES, CHART_STYLE_OTHER], tooltip = TOOLTIP_CHART_STYLE)

string  sessionInput                    = input.session("0000-0000",               "Session",                             inline = "01", group = INPUT_GROUP_SESSION, tooltip = TOOLTIP_SESSION)
var     timezoneInput                   = input.enum   (tz.Timezone.EXCHANGE,      " Zone",                               inline = "01", group = INPUT_GROUP_SESSION)
bool    sundayInput                     = input.bool   (true,                      "Sun  ",                               inline = "02", group = INPUT_GROUP_SESSION)
bool    mondayInput                     = input.bool   (true,                      "Mon  ",                               inline = "02", group = INPUT_GROUP_SESSION)
bool    tuesdayInput                    = input.bool   (true,                      "Tue  ",                               inline = "02", group = INPUT_GROUP_SESSION)
bool    wednesdayInput                  = input.bool   (true,                      "Wed  ",                               inline = "02", group = INPUT_GROUP_SESSION)
bool    thursdayInput                   = input.bool   (true,                      "Thu  ",                               inline = "02", group = INPUT_GROUP_SESSION)
bool    fridayInput                     = input.bool   (true,                      "Fri  ",                               inline = "02", group = INPUT_GROUP_SESSION)
bool    saturdayInput                   = input.bool   (true,                      "Sat",                                 inline = "02", group = INPUT_GROUP_SESSION)

bool    colorBasedOnPreviousCloseInput  = input.bool   (false,                     "Color bars based on previous close",  inline = "03", group = INPUT_GROUP_COLORS, tooltip = TOOLTIP_COLOR_BASED_ON_PREVIOUS_CLOSE)
bool    enableBodyInput                 = input.bool   (true,                      "Body",                                inline = "04", group = INPUT_GROUP_COLORS)
color   bullishBodyColorInput           = input.color  (DEFAULT_BULLISH_COLOR,     "       " + BULLISH_SYMBOL,            inline = "04", group = INPUT_GROUP_COLORS, active = enableBodyInput)
color   bearishBodyColorInput           = input.color  (DEFAULT_BEARISH_COLOR,     " " + BEARISH_SYMBOL,                  inline = "04", group = INPUT_GROUP_COLORS, active = enableBodyInput)
color   neutralBodyColorInput           = input.color  (DEFAULT_NEUTRAL_COLOR,     " " + NEUTRAL_SYMBOL,                  inline = "04", group = INPUT_GROUP_COLORS, active = enableBodyInput)
string  bodyColorImplementationInput    = input.string (BODY_COLOR_OVERLAY,        " ",                                   inline = "04", group = INPUT_GROUP_COLORS, active = chartStyleInput != CHART_STYLE_OTHER and enableBodyInput, display = display.data_window, options = [BODY_COLOR_OVERLAY, BODY_COLOR_REPLACE], tooltip = TOOLTIP_BODY_COLOR_IMPLEMENTATION)
bool    enableBorderInput               = input.bool   (true,                      "Borders",                             inline = "05", group = INPUT_GROUP_COLORS, active = chartStyleInput == CHART_STYLE_CANDLES)
color   bullishBorderColorInput         = input.color  (DEFAULT_BULLISH_COLOR,     "     " + BULLISH_SYMBOL,              inline = "05", group = INPUT_GROUP_COLORS, active = chartStyleInput == CHART_STYLE_CANDLES and enableBorderInput)
color   bearishBorderColorInput         = input.color  (DEFAULT_BEARISH_COLOR,     " " + BEARISH_SYMBOL,                  inline = "05", group = INPUT_GROUP_COLORS, active = chartStyleInput == CHART_STYLE_CANDLES and enableBorderInput)
color   neutralBorderColorInput         = input.color  (DEFAULT_NEUTRAL_COLOR,     " " + NEUTRAL_SYMBOL,                  inline = "05", group = INPUT_GROUP_COLORS, active = chartStyleInput == CHART_STYLE_CANDLES and enableBorderInput)
bool    enableWickInput                 = input.bool   (true,                      "Wick",                                inline = "06", group = INPUT_GROUP_COLORS, active = chartStyleInput == CHART_STYLE_CANDLES)
color   bullishWickColorInput           = input.color  (DEFAULT_BULLISH_COLOR,     "        " + BULLISH_SYMBOL,           inline = "06", group = INPUT_GROUP_COLORS, active = chartStyleInput == CHART_STYLE_CANDLES and enableWickInput)
color   bearishWickColorInput           = input.color  (DEFAULT_BEARISH_COLOR,     " " + BEARISH_SYMBOL,                  inline = "06", group = INPUT_GROUP_COLORS, active = chartStyleInput == CHART_STYLE_CANDLES and enableWickInput)
color   neutralWickColorInput           = input.color  (DEFAULT_NEUTRAL_COLOR,     " " + NEUTRAL_SYMBOL,                  inline = "06", group = INPUT_GROUP_COLORS, active = chartStyleInput == CHART_STYLE_CANDLES and enableWickInput)
bool    enableBackgroundInput           = input.bool   (false,                     "Background",                          inline = "07", group = INPUT_GROUP_COLORS)
color   bullishBackgroundColorInput     = input.color  (DEFAULT_BACKGROUND_COLOR,  " " + BULLISH_SYMBOL,                  inline = "07", group = INPUT_GROUP_COLORS, active = enableBackgroundInput)
color   bearishBackgroundColorInput     = input.color  (DEFAULT_BACKGROUND_COLOR,  " " + BEARISH_SYMBOL,                  inline = "07", group = INPUT_GROUP_COLORS, active = enableBackgroundInput)
color   neutralBackgroundColorInput     = input.color  (DEFAULT_BACKGROUND_COLOR,  " " + NEUTRAL_SYMBOL,                  inline = "07", group = INPUT_GROUP_COLORS, active = enableBackgroundInput)

string  barInSessionDeterminationInput  = input.string (BAR_OPEN_IN_SESSION,       "Portion of bar in session",           inline = "08", group = INPUT_GROUP_FINE_TUNING, display = display.data_window, options = [BAR_OPEN_IN_SESSION, BAR_CLOSE_IN_SESSION, ALL_INTRABARS_IN_SESSION, ANY_INTRABAR_IN_SESSION], tooltip = TOOLTIP_BAR_IN_SESSION_DETERMINATION)
bool    invertSessionInput              = input.bool   (false,                     "Invert session",                      inline = "09", group = INPUT_GROUP_FINE_TUNING, display = display.data_window, tooltip = TOOLTIP_INVERT_SESSION)

//#endregion



//#region ------------------------------ FUNCTIONS ------------------------------

// @type          A custom type representing the new color scheme to use for a bar.
// @field body    The main bar color.
// @field border  The border color (candlesticks only).
// @field wick    The wick color (candlesticks only).
// @field bg      The background color.
type BarColorScheme
    color body
    color border
    color wick
    color bg


// @function  Determines the chart style that is being used.
// @returns   A ChartStyle enum value.
getChartStyle() =>
    ChartStyle default = switch chartStyleInput
        CHART_STYLE_BARS    => ChartStyle.BAR
        CHART_STYLE_CANDLES => ChartStyle.CANDLESTICK
        CHART_STYLE_OTHER   => ChartStyle.OTHER

    switch
        chart.is_standard   => default  // for standard charts, pine script does not provide a way to inspect the exact chart type being used, so just apply the user's decision
        chart.is_heikinashi => ChartStyle.CANDLESTICK
        chart.is_renko      => default == ChartStyle.CANDLESTICK ? ChartStyle.CANDLESTICK : ChartStyle.OTHER    // allow candlestick style because it can have a cool nesting effect
        chart.is_linebreak  => default == ChartStyle.CANDLESTICK ? ChartStyle.CANDLESTICK : ChartStyle.OTHER    // allow candlestick style because it can have a cool nesting effect
        chart.is_kagi       => default == ChartStyle.BAR         ? ChartStyle.BAR         : ChartStyle.OTHER    // allow bar style because it can have a cool nesting effect
        chart.is_pnf        => ChartStyle.OTHER
        chart.is_range      => default  // Range charts can be configured in the chart settings to use either bars or candles, so just apply the user's decision
        => default


// @function  Validates some of the indicator settings and creates an error message for invalid inputs.
//
// This function verifies:
//     1. At least 1 day of the week is selected for the user-defined session.
//     2. At least 1 part of a bar/candle will be modified.
//     3. At least 1 enabled color will not be fully transparent.
//
// If any of the above conditions are not met, the indicator will essentially be disabled because no bar will be modified,
// therefore an error message is created to avoid potential confusion on why the indicator is not changing any bar colors.
validateInputs() =>
    // VALIDATION #1
    array<bool> selectedDaysOfWeek = array.from(sundayInput, mondayInput, tuesdayInput, wednesdayInput, thursdayInput, fridayInput, saturdayInput)
    if not array.some(selectedDaysOfWeek)
        runtime.error("𝗦𝗲𝗹𝗲𝗰𝘁 𝗮𝘁 𝗹𝗲𝗮𝘀𝘁 𝟭 𝗱𝗮𝘆 𝗼𝗳 𝘄𝗲𝗲𝗸")


    // VALIDATION #2
    map<string, bool> enabledColorsMap = map.new<string, bool>()        // key = region of bar to modify,  value = true if enabled in settings
    map.put(enabledColorsMap, "Body", enableBodyInput)
    if getChartStyle() == ChartStyle.CANDLESTICK        // only candlestick charts need to validate if borders & wicks are enabled/disabled since they are not applicable to other chart styles
        map.put(enabledColorsMap, "Borders", enableBorderInput)
        map.put(enabledColorsMap, "Wick", enableWickInput)
    map.put(enabledColorsMap, "Background", enableBackgroundInput)

    if not array.some(map.values(enabledColorsMap))
        runtime.error("𝗧𝗼𝗴𝗴𝗹𝗲 𝗮𝘁 𝗹𝗲𝗮𝘀𝘁 𝟭 𝗼𝗽𝘁𝗶𝗼𝗻 𝗳𝗿𝗼𝗺: " + str.tostring(map.keys(enabledColorsMap)))


    // VALIDATION #3
    map<string, bool> transparentColorsMap = map.new<string, bool>()    // key = region of bar to modify,  value = true if fully transparent colors
    map.put(transparentColorsMap, "Body",       MAX_TRANSPARENCY == math.min(color.t(bullishBodyColorInput),       color.t(bearishBodyColorInput),       color.t(neutralBodyColorInput)))
    map.put(transparentColorsMap, "Borders",    MAX_TRANSPARENCY == math.min(color.t(bullishBorderColorInput),     color.t(bearishBorderColorInput),     color.t(neutralBorderColorInput)))
    map.put(transparentColorsMap, "Wick",       MAX_TRANSPARENCY == math.min(color.t(bullishWickColorInput),       color.t(bearishWickColorInput),       color.t(neutralWickColorInput)))
    map.put(transparentColorsMap, "Background", MAX_TRANSPARENCY == math.min(color.t(bullishBackgroundColorInput), color.t(bearishBackgroundColorInput), color.t(neutralBackgroundColorInput)))

    bool barcolorFunctionUtilized = getChartStyle() == ChartStyle.OTHER or bodyColorImplementationInput == BODY_COLOR_REPLACE
    if barcolorFunctionUtilized                         // referring to the `barcolor()` built-in function that is called at the end of this script
        map.put(transparentColorsMap, "Body", false)    // "Body" is allowed to be fully transparent in this case because the transparent color can still create a visible change in the chart

    for key in transparentColorsMap.keys()
        if not map.get(enabledColorsMap, key)           // reusing the map from validation #2 to determine which color checkboxes are disabled
            map.remove(transparentColorsMap, key)       // if disabled (either explicitly by the user or if not applicable to current chart style), then its transparency values do not need to be validated

    if array.every(transparentColorsMap.values())
        runtime.error("𝗜𝗻𝗰𝗿𝗲𝗮𝘀𝗲 𝗼𝗽𝗮𝗰𝗶𝘁𝘆 𝗼𝗳 𝗮𝗻𝘆 𝗰𝗼𝗹𝗼𝗿 𝗳𝗿𝗼𝗺: " + str.tostring(map.keys(transparentColorsMap)))


// @function  Creates a map of the configured color schemes.
// @returns   A mapping of bar directions to bar color schemes.
buildColorSchemeMap() =>
    BarColorScheme bullishColorScheme = BarColorScheme.new(
       body   = enableBodyInput       ? bullishBodyColorInput       : na,
       border = enableBorderInput     ? bullishBorderColorInput     : na,
       wick   = enableWickInput       ? bullishWickColorInput       : na,
       bg     = enableBackgroundInput ? bullishBackgroundColorInput : na)
    BarColorScheme bearishColorScheme = BarColorScheme.new(
       body   = enableBodyInput       ? bearishBodyColorInput       : na,
       border = enableBorderInput     ? bearishBorderColorInput     : na,
       wick   = enableWickInput       ? bearishWickColorInput       : na,
       bg     = enableBackgroundInput ? bearishBackgroundColorInput : na)
    BarColorScheme neutralColorScheme = BarColorScheme.new(
       body   = enableBodyInput       ? neutralBodyColorInput       : na,
       border = enableBorderInput     ? neutralBorderColorInput     : na,
       wick   = enableWickInput       ? neutralWickColorInput       : na,
       bg     = enableBackgroundInput ? neutralBackgroundColorInput : na)

    map<BarDirection, BarColorScheme> colorSchemeMap = map.new<BarDirection, BarColorScheme>()
    map.put(colorSchemeMap, BarDirection.BULLISH, bullishColorScheme)
    map.put(colorSchemeMap, BarDirection.BEARISH, bearishColorScheme)
    map.put(colorSchemeMap, BarDirection.NEUTRAL, neutralColorScheme)
    colorSchemeMap


// @function       Builds the session string to be used for verifying if a bar belongs to the user-defined session.
// @param session  (simple string) Session input string in "HHmm-HHmm" format.
// @param sun      (simple bool) Whether the session is valid on Sundays.
// @param mon      (simple bool) Whether the session is valid on Mondays.
// @param tue      (simple bool) Whether the session is valid on Tuesdays.
// @param wed      (simple bool) Whether the session is valid on Wednesdays.
// @param thu      (simple bool) Whether the session is valid on Thursdays.
// @param fri      (simple bool) Whether the session is valid on Fridays.
// @param sat      (simple bool) Whether the session is valid on Saturdays.
// @returns        String representing the user-defined session.
buildUserDefinedSession(simple string session, simple bool sun, simple bool mon, simple bool tue, simple bool wed, simple bool thu, simple bool fri, simple bool sat) =>
    string sessionStart = str.substring(session, 0, 4)
    string sessionEnd = str.substring(session, 5, 9)

    array<int> days = array.new<int>()
    if sun
        days.push(dayofweek.sunday)
    if mon
        days.push(dayofweek.monday)
    if tue
        days.push(dayofweek.tuesday)
    if wed
        days.push(dayofweek.wednesday)
    if thu
        days.push(dayofweek.thursday)
    if fri
        days.push(dayofweek.friday)
    if sat
        days.push(dayofweek.saturday)

    str.format("{0}-{1}:{2}", sessionStart, sessionEnd, days.join(""))


// @function       Determines the lower timeframe that should be used to request intrabar data.
// @param session  (simple string) Session input string in "HHmm-HHmm" format.
// @returns        The timeframe to use for `request.security_lower_tf()`.
getIntrabarTimeframe(simple string session) =>
    string sessionStartMinuteLastDigit = str.substring(session, 3, 4)
    string sessionEndMinuteLastDigit = str.substring(session, 8, 9)

    bool sessionMultipleOf5 = (sessionStartMinuteLastDigit == "0" or sessionStartMinuteLastDigit == "5") and (sessionEndMinuteLastDigit == "0" or sessionEndMinuteLastDigit == "5")
    bool timeframeMultipleOf5 = timeframe.in_seconds(timeframe.period) % timeframe.in_seconds(FIVE_MINUTE_TIMEFRAME) == 0

    // if possible, request the 5-minute timeframe instead of the 1-minute timeframe because it can allow more historical bars on a HTF chart to be processed
    string intrabarTimeframe = sessionMultipleOf5 and timeframeMultipleOf5 ? FIVE_MINUTE_TIMEFRAME : ONE_MINUTE_TIMEFRAME

    // requested lower timeframe cannot be a higher resolution than the current timeframe
    timeframe.in_seconds(timeframe.period) <= timeframe.in_seconds(intrabarTimeframe) ? timeframe.period : intrabarTimeframe


// @function  Determines whether the current bar is bullish or bearish.
// @returns   A BarDirection enum value.
getBarDirection() =>
    float previousValueForComparison = colorBasedOnPreviousCloseInput ? nz(close[1], open) : open   // using nz() function because close[1] is `na` on the very first bar
    switch
        close > previousValueForComparison => BarDirection.BULLISH
        close < previousValueForComparison => BarDirection.BEARISH
        => BarDirection.NEUTRAL

//#endregion



//#region ------------------------------ CALCULATIONS ------------------------------
if barstate.isfirst
    validateInputs()    // input validation can be done just once (for optimization purposes), since the indicator inputs do not change as each new bar is processed


// using `var` to avoid recomputing these constant values on each new bar
var ChartStyle chartStyle = getChartStyle()
var map<BarDirection, BarColorScheme> colorSchemeMap = buildColorSchemeMap()

var string session = buildUserDefinedSession(sessionInput, sundayInput, mondayInput, tuesdayInput, wednesdayInput, thursdayInput, fridayInput, saturdayInput)
var string timezone = timezoneInput.tostring()  // function from the imported library; different from `str.tostring()` built-in function

var simple string request_security_lower_tf = getIntrabarTimeframe(sessionInput)

// Value for `calc_bars_count` parameter to restrict the number of historical data points accessed from the lower timeframe.
// This is used for optimization purposes by setting it to a low value when the intrabar data is not needed.
// Note: a value of `na` does not restrict the historical data; it will use however many bars are available.
var simple int calc_bars_count =
         timeframe.in_seconds(timeframe.period) <= timeframe.in_seconds(request_security_lower_tf)  // If this condition is true, each request will return a single intrabar,
                                                                                                    // so there is not much performance gains from reducing `calc_bars_count`.
         or (barInSessionDeterminationInput != BAR_OPEN_IN_SESSION and timeframe.isintraday)        // If this condition is true, the lower timeframe data will be utilized,
                                                                                                    // so `calc_bars_count` cannot be set to a very low value.
         ? na : 10



// method to detect if the `time` of the current bar belongs to a specific time period (https://www.tradingview.com/pine-script-docs/concepts/sessions/#using-session-strings)
bool barOpenInSession = not na(time("", session, timezone))


// @variable The main variable that will be used to control whether a bar's color and/or background should be modified.
bool modifyCurrentBar = if barInSessionDeterminationInput == BAR_OPEN_IN_SESSION

    barOpenInSession        // BAR_OPEN_IN_SESSION is the only `barInSessionDeterminationInput` option that does not require a lower timeframe request
                            // because the `barOpenInSession` calculation is all that is needed, so this is placed in a separate `if` block for optimization purposes.

else

    // Array that stores a boolean for each 5- or 1-minute bar within the current bar; used to determine which intrabars belong to the user-defined session.
    // The returned array will not be `na`, and neither will the values inside the array be `na`, so only the size of the array needs to be validated.
    // Note: the lower timeframe context still runs even if this `else` block never executes, therefore the `calc_bars_count` is used for optimization.
    array<bool> intrabars = request.security_lower_tf(syminfo.tickerid, request_security_lower_tf, barOpenInSession, calc_bars_count = calc_bars_count)

    // there is no built-in method to detect whether the `time_close` of the current bar belongs to a specific time period, so this is a workaround
    bool barCloseInSession = array.size(intrabars) > 0 and array.last(intrabars)

    switch barInSessionDeterminationInput
        BAR_CLOSE_IN_SESSION     => barCloseInSession
        ALL_INTRABARS_IN_SESSION => array.every(intrabars)
        ANY_INTRABAR_IN_SESSION  => array.some(intrabars) or barOpenInSession   // Note: using only `array.some()` would be sufficient for recent bars,
                                                                                // but not for very old bars that might not have any available intrabars.


if invertSessionInput
    modifyCurrentBar := not modifyCurrentBar

if not timeframe.isintraday
    modifyCurrentBar := false   // indicator is disabled on Daily or higher timeframes



[bodyColor, borderColor, wickColor, bgColor] = if modifyCurrentBar
    BarColorScheme colors = map.get(colorSchemeMap, getBarDirection())
    [colors.body, colors.border, colors.wick, colors.bg]
else
    [na, na, na, na]            // (minor optimization) no need to retrieve the colors if the current bar will not be modified



bool plotBar     = chartStyle == ChartStyle.BAR
bool plotCandle  = chartStyle == ChartStyle.CANDLESTICK
bool setBarColor = chartStyle == ChartStyle.OTHER or bodyColorImplementationInput == BODY_COLOR_REPLACE

//#endregion



//#region ------------------------------ VISUALS ------------------------------
plotbar(
   modifyCurrentBar and plotBar ? open : na,
   high,
   low,
   close,
   color = setBarColor ? na : bodyColor,
   editable = false,
   display = display.pane,
   force_overlay = true)

plotcandle(
   modifyCurrentBar and plotCandle ? open : na,
   high,
   low,
   close,
   color = setBarColor ? na : bodyColor,
   bordercolor = borderColor,
   wickcolor = wickColor,
   editable = false,
   display = display.pane,
   force_overlay = true)

barcolor(modifyCurrentBar and setBarColor ? bodyColor : na, editable = false)

bgcolor(modifyCurrentBar ? bgColor : na, editable = false, force_overlay = true)

//#endregion
````

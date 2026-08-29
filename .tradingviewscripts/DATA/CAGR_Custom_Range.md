<!-- tradingview-pine-id: PUB;968a0b119b7b4f05979e0c668f5897e8 -->
<!-- tradingviewscripts-format: 1 -->
# CAGR Custom Range

Source: https://www.tradingview.com/script/SkmMrMe0-CAGR-Custom-Range/

## Description

█ OVERVIEW

This script calculates an annualized [Compound Annual Growth Rate](https://en.wikipedia.org/wiki/Compound_annual_growth_rate) from two points in time which you can select on the chart. It previews an upcoming feature where Pine scripts will be able to provide users with interactive inputs for time and price values.

👉🏼 We are looking for feedback on our first take of this feature.
     Please comment in this publication's "Comments" section if you have suggestions for improvement.

█ HOW TO USE IT

When you first load this script on a chart, you will enter the new interactive selection mode. At that point, the script is waiting for you to pick two points in time on your chart by clicking on the chart. Once you select the two points, the script will find the [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) value for each of the two selected bars, and calculate the ​CAGR value from them. It will then display a line between the two points, and the ​CAGR value above or below the last point in time.

If the ​CAGR value is positive, the line and label will display in their "up" color (see the "🠅" color in the script's "Settings/Inputs" tab), otherwise they appear in their "down" color (the "🠇" color in the inputs). You can also control the line's width from the inputs.

You have the option of comparing the chart's ​CAGR value with that of another symbol, which you specify in the "Compare to" input. When a comparison is made, the label's background color will be dependent on the result of the comparison. The line's color will still be determined by the chart's value.

Once time points have been selected on the chart and the script is displaying the line, you can change the time points by clicking on the script's name on the chart. A small, blue rectangular handle will then appear for each point, which you can then grab and move. If you reset the inputs using the "Defaults/Reset Settings" button in the script's inputs, the two time points will reset to the beginning of September and October 2021, respectively.

█ CONCEPTS

The ​CAGR is a notional, annualized growth rate that assumes all profits are reinvested. It calculates from the [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) value of the two end points. It does not account for drawdowns, so it does not calculate risk. It can be used as a yardstick to compare the performance of two instruments. Because it annualizes values, the function requires a minimum of one day between the two end points (annualizing returns over smaller periods of times doesn't produce very meaningful figures).

█ LIMITATIONS

 • The two selected points must be distant from a minimum of one day. A runtime error will occur otherwise.
 • There is currently no way to restart the interactive mode from scratch without re-adding the script to the chart.
 • The points in time you select on one chart may map quite differently on other charts,
  depending on their constituent bars (e.g., intraday charts for 24x7 and conventional markets).

█ FOR PINE CODERS

 • Our script uses the most recent version of Pine, as the `//@version=5` compiler directive indicates.
 • Interactive inputs were a long-standing and highly-requested feature by our beloved community of Pine coders.  
  We hope you find this first step promising, as it opens up entirely new possibilities for both Pine coders and script users. 
  You can, for example, use interactive inputs to draw shapes with your scripts, or support and resistance levels, etc.
  We're sure you'll come up with more creative uses of the feature than we could ever dream up )
 • Interactive inputs are implemented for [input.time()](https://www.tradingview.com/pine-script-reference/v5/#fun_input{dot}time) and [input.price()](https://www.tradingview.com/pine-script-reference/v5/#fun_input{dot}price), the specialized input functions now available in v5.
  See the User Manual's [new page on inputs](https://www.tradingview.com/pine-script-docs/en/v5/concepts/Inputs.html) for more information about them.
  You can also create one interactive input for both time and price values 
  by using the same `inline` argument in a pair of [input.time()](https://www.tradingview.com/pine-script-reference/v5/#fun_input{dot}time) and [input.price()](https://www.tradingview.com/pine-script-reference/v5/#fun_input{dot}price) function calls.
 • Our min/max filtering when initializing `entryTime` and `exitTime` will handle cases where 
  the script user inverts the two points on the chart.
 • The script uses the new [runtime.error()](https://www.tradingview.com/pine-script-reference/v5/#fun_runtime{dot}error) function to throw an error in the `if days < 1` conditional structure.
 • We use the `cagr()` function from our recently-published [ta Pine library](https://www.tradingview.com/script/BICzyhq0-ta/).
  [Pine libraries](https://www.tradingview.com/pine-script-docs/en/v5/concepts/Libraries.html) — not to be confused with the [Public Library](https://www.tradingview.com/scripts/) showcasing scripts published by our community of Pine coders —
  are one of the new features available with the recent Pine v5.
 • Note that our `strRightOf()` function cannot be used to generate ticker identifier strings for use in `request.*()` functions.
  This is because it produces results of "series" form while the functions require 
  arguments of "simple" form for their `symbol` or `ticker` parameters.
  Have a look at our new User Manual page on Pine's [Type system](https://www.tradingview.com/pine-script-docs/en/v5/language/Type_system.html) if you need to brush up on Pine forms and types.
 • We use a simple, repainting [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request{dot}security) call because our calculations are not used to generate orders or alerts.
 • We document our user-defined functions using the same compiler directives used in [exported functions](https://www.tradingview.com/pine-script-docs/en/v5/concepts/Libraries.html#creating-a-library) in libraries.
  It will make conversion of those functions to library format easier if we ever choose to do so.
 • We use two Unicode hair spaces (U+200A) to push the "%" sign slightly away from values in our [str.format()](https://www.tradingview.com/pine-script-reference/v5/#fun_str{dot}format) calls.
  While the ​impact is minimal, it increases readability.
 • Note the `priceIsHigh` logic used to determine if we place the label above or below bars.
  When price is higher than recent prices, we place the label above the bar, otherwise we place it below.
  It's not foolproof but it provides optimal positioning most of the time.
 • The point of the complicated "bool" expression initializing `displayCAGR` is to ensure that we only draw the line and labels once.
  When no comparison with another symbol is made, this occurs the first time we encounter a non-[na](https://www.tradingview.com/pine-script-reference/v5/#fun_na) value from the `cagr()` function.
  When a comparison is required, it occurs the first time both values are not [na](https://www.tradingview.com/pine-script-reference/v5/#fun_na).
 • Before all mentions of "CAGR" in our description, we use a Unicode zero-width space (U+200B) 
  to prevent the auto-linking feature to kick in for the term. 
  This prevents the dashed underscore and a link like this (CAGR) from appearing every time "CAGR" is mentioned.
 • With Pine v5, the `study()` declaration statement was renamed to [indicator()](https://www.tradingview.com/pine-script-reference/v5/#fun_indicator).
  Accordingly, we will be eliminating the use of the "study" term from documentation and the ​UI.
  The generic "script" term will continue to designate Pine code that can be an indicator, a strategy or a library, when applicable.
 • We followed our new [Style guide](https://www.tradingview.com/pine-script-docs/en/v5/writing/Style_guide.html) recommendations to write our script.
 • We used the techniques explained in the [How We Write and Format Script Descriptions](https://www.tradingview.com/chart/SSP/aOYEvBxw-How-We-Write-and-Format-Script-Descriptions/) publication by PineCoders.
 • That's it! We've covered all the new features and tricks we used. We sincerely hope you enjoy the new interactive inputs, 
  and please remember to comment here if you have suggestions for improvement. 💙

[Look first. Then leap.](https://www.tradingview.com/athletes/)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingView

//@version=6
indicator("CAGR Custom Range", "CAGR", overlay = true)

// CAGR Custom Range
// v2, 2026.04.14

// This code's style is based on the recommendations from the Pine Script User Manual's Style guide:
//    https://www.tradingview.com/pine-script-docs/writing/style-guide/



import TradingView/ta/12 as ta



//#region ———————————————————— Constants and inputs


// Colors
color TVBLUE = #1848cc
color RED    = #c90707

// Time values
int   MS_IN_ONE_DAY  = 24 * 60 * 60 * 1000
int   DEFAULT_POINT1 = timestamp("2025-09")
int   DEFAULT_POINT2 = timestamp("2025-10")

// Tooltips
string ET_TT = "A minimum period of one day is required between the two points."
string CS_TT = (
    "If not empty, the indicator displays the CAGR of the instrument " 
    + "represented on the chart alongside the specified instrument for comparison."
)

// Inputs

// These two time inputs use `confirm = true` to enable interactive setting of the points on the chart.
int    entryTimeInput      = input.time(DEFAULT_POINT1, "Point 1",       confirm = true)
int    exitTimeInput       = input.time(DEFAULT_POINT2, "Point 2",       confirm = true, tooltip = ET_TT)

string comparedSymbolInput = input.symbol("",           "Compare to",    tooltip = CS_TT)
color  lineBullColorInput  = input.color(TVBLUE,        "Line colors 🠅", inline  = "1")
color  lineBearColorInput  = input.color(RED,           "🠇",             inline  = "1")
int    lineWidthInput      = input.int(2,               "Width",         inline  = "1", minval = 1)
//#endregion



//#region ———————————————————— Functions 


// @function        Retrieves the `close` value of the bar on which the `time` value equals or crosses the specified 
//                  timestamp.
// @param t         (simple int) The millisecond UNIX timestamp to use in the search.
// @returns         (float) The `close` value of the bar whose opening time equals or crosses the `t` timestamp on all 
//                  bars that open on or after that time, and `na` on all earlier bars.
getPriceForTime(simple int t) =>
    var float price = na
    if time[1] <= t and time >= t and na(price)
        price := close
    price
//#endregion



//#region ———————————————————— Calculations 


// Declare variables to hold the two selected timestamps in chronological order.
int entryTime = math.min(entryTimeInput, exitTimeInput)
int exitTime  = math.max(entryTimeInput, exitTimeInput)
// @variable Is `true` if the `comparedSymbolInput` has a specified value, and `false` otherwise.
bool comparison = comparedSymbolInput != ""
// Retrieve the start and end prices for the CAGR calculation.
float entryPrice = getPriceForTime(entryTime)
float exitPrice  = getPriceForTime(exitTime)
// @variable Is `true` if the price increased over the selected range, and `false` otherwise.
bool chartCAGRIsUp = exitPrice > entryPrice
// @variable The number of days elapsed between the two timestamps.
float days = (exitTime - entryTime) / MS_IN_ONE_DAY
// @variable The CAGR over the selected time range for the instrument represented on the chart. 
float chartCAGR = ta.cagr(entryTime, entryPrice, exitTime, exitPrice)
// @variable The CAGR over the time range for another specified instrument, or `na` if the "Compare to" input is empty.
float comparedCAGR = not comparison ? na : request.security(comparedSymbolInput, timeframe.period, chartCAGR)
// @variable Is `true` only on the bar where CAGR values become available, and `false` on other bars.
bool displayCAGR = (na(chartCAGR[1]) and not na(chartCAGR) and (not comparison or not na(comparedCAGR))) or 
                   (na(comparedCAGR[1]) and not na(comparedCAGR) and not na(chartCAGR))
// @variable Is `true` if the `close` value's percent rank is above 50, and `false` otherwise. 
bool priceIsHigh = ta.percentrank(close, 100) > 50
//#endregion



//#region ———————————————————— Display 


// Enforce minimum 24-hour period. Raise an error if not. 
if days < 1
    runtime.error("The time span between the two points must be at least 24h.")

if displayCAGR
    // @variable The line color. Uses the first input color if the price increased, and the second color otherwise.
    color lineColor = chartCAGRIsUp ? lineBullColorInput : lineBearColorInput
    // Draw range line and endpoint markers.
    line.new(
        entryTime,  entryPrice, exitTime, exitPrice, xloc = xloc.bar_time, color = lineColor, style = line.style_dotted,
        width = lineWidthInput
    )
    label.new(
        entryTime, entryPrice, xloc = xloc.bar_time, color = lineColor, style = label.style_circle, size = size.tiny
    )
    label.new(
        exitTime,  exitPrice,  xloc = xloc.bar_time, color = lineColor, style = label.style_circle, size = size.tiny
    )
    // @variable The label color. Uses the line color, or selects a direction color based on the requested CAGR value.
    color labelColor = comparison ? chartCAGR > comparedCAGR ? lineBullColorInput : lineBearColorInput : lineColor
    // @variable Is `yloc.abovebar` if the 100-bar percent rank is at least 50, and `yloc.belowbar` otherwise.
    string labelYloc = priceIsHigh ? yloc.abovebar : yloc.belowbar
    // @variable A string containing the formatted CAGR values.
    string labelText = if comparison
        int pos = str.pos(comparedSymbolInput, ":")
        str.format(
            "{0,number,###,###.#}  % {1} vs\n{2,number,###,###.#}  % {3}", chartCAGR, syminfo.ticker, comparedCAGR, 
            str.substring(comparedSymbolInput, pos + 1)
        )
    else
        str.format("{0,number,###,###.#}  %", chartCAGR)
    // Draw a label to display the formatted results. 
    label.new(
        exitTime, exitPrice, labelText, xloc = xloc.bar_time, yloc = labelYloc, style = label.style_label_center,
        color = labelColor, textcolor = color.white, size = size.large
    )
//#endregion
````

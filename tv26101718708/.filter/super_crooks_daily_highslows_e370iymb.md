# Super Crooks Daily Highs/Lows

- url: https://www.tradingview.com/script/e370IYmb-Super-Crooks-Daily-Highs-Lows/
- type: indicator
- pine_id: PUB;7a853c98ebf74f629eed651c61d80223
- version: 2.0

## Description

█ [b]OVERVIEW[/b]

This indicator plots current day high/low and previous day highs/lows. It can be cumbersome to mark out daily highs/lows when checking for daily swing points and closures [b][i]every day[/i][/b]. This indicator simplifies that process by marking these levels out automatically. All levels can be seen on the daily timeframe and lower timeframes.

█ [b]CONCEPTS[/b]
[list]
[*] Adds CDH/CDL lines/labels to point out Current Day High and Current Day Low
[*] Adds PDH/PDL lines/labels to point out Previous Day High and Previous Day Low
[*] Adds PDH[i]n[/i]/PDL[i]n[/i] lines/labels where [i]n[/i] is a number denoting extra previous days (e.g., PDH1, PDL1 denoting Previous Day High/Low 1 day before PDH/PDL.
[/list]
█ [b]HOW TO USE[/b]
[list]
[*] Add the Super Crooks Daily Highs/Lows indicator to your TradingView charts
[*] Open the indicator's settings and select your preferred options
[*] Watch your charts to see the indicator plot CDH, CDL, PDHs, and PDLs
[/list]
█ [b]FEATURES[/b]
[list]
[*] Labels and lines drawn in real time
[*] Levels are show across daily timeframes and lower timeframes
[*] Configuration options (e.g., show [i]n[/i] previous days)
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © crookse
//
// TODO
// - Configurable Current Day High/Low (show/hide)
// - Configurable Labels

//@version=6
indicator("Super Crooks - Daily Highs/Lows", overlay=true, max_lines_count=500, max_labels_count=500)

const string SCRIPT_VERSION = "v1.0.1"

time_current_hour = hour(time)
time_current_minute = minute(time)
time_1_hour = 3600000 // 1 hour, in milliseconds
line_end_time = timenow + time_1_hour
is_new_day = session.isfirstbar

////////////////////////////////////////////////////////////////////////////////
// INPUTS
////////////////////////////////////////////////////////////////////////////////

input_history = input.int(3, "Number of Days to Show", minval=1, maxval=20)
input_high_color = input.color(color.black, "High Line Color")
input_low_color = input.color(color.black, "Low Line Color")
input_line_width = input.int(1, "Line Width", minval=1, maxval=4)
input_line_style = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"])
input_show_high_price = input.bool(false, "Show High Price")
input_show_low_price = input.bool(false, "Show Low Price")

getStyle(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

////////////////////////////////////////////////////////////////////////////////
// STATE
////////////////////////////////////////////////////////////////////////////////

var line[]  high_lines = array.new_line()
var line[]  low_lines = array.new_line()
var label[] high_labels = array.new_label()
var label[] low_labels = array.new_label()

var float day_high = na
var float day_low = na

////////////////////////////////////////////////////////////////////////////////
// HIGHS/LOWS RENDERING
////////////////////////////////////////////////////////////////////////////////

if is_new_day or barstate.isfirst
    day_high := high
    day_low  := low

    high_line = line.new(time, day_high, line_end_time, day_high, xloc=xloc.bar_time, color=input_high_color, width=input_line_width, style=getStyle(input_line_style))
    low_line = line.new(time, day_low,  line_end_time, day_low,  xloc=xloc.bar_time, color=input_low_color,  width=input_line_width, style=getStyle(input_line_style))
    array.push(high_lines, high_line)
    array.push(low_lines, low_line)

    high_label = label.new(line_end_time, day_high, text="", xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=input_high_color, style=label.style_label_left, size=size.small)
    low_label = label.new(line_end_time, day_low,  text="", xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=input_low_color,  style=label.style_label_left, size=size.small)
    array.push(high_labels, high_label)
    array.push(low_labels, low_label)

    // Keep only the last N days (remove older days)
    if array.size(high_lines) > input_history
        line.delete(array.shift(high_lines))
        line.delete(array.shift(low_lines))
        label.delete(array.shift(high_labels))
        label.delete(array.shift(low_labels))
else
    day_high := math.max(day_high, high)
    day_low  := math.min(day_low, low)

////////////////////////////////////////////////////////////////////////////////
// LINES
////////////////////////////////////////////////////////////////////////////////

n = array.size(high_lines)

if n > 0
    current_high_line = array.get(high_lines, n - 1)
    currentlow_line = array.get(low_lines, n - 1)
    current_high_label = array.get(high_labels, n - 1)
    current_low_label = array.get(low_labels, n - 1)

    line.set_y1(current_high_line, day_high)
    line.set_y2(current_high_line, day_high)
    line.set_x2(current_high_line, line_end_time)

    line.set_y1(currentlow_line, day_low)
    line.set_y2(currentlow_line, day_low)
    line.set_x2(currentlow_line, line_end_time)

    label.set_xy(current_high_label, line_end_time, day_high)
    label.set_xy(current_low_label, line_end_time, day_low)

////////////////////////////////////////////////////////////////////////////////
// LABELS
////////////////////////////////////////////////////////////////////////////////

// Intent
// - Today's bars (if enabled do not get a suffix)
// - Yesterday's bars do not get a suffix
// - The day before yesterday gets a "1", the day before that gets a "2", and so on
for i = 0 to n - 1

    is_today = i == n - 1

    days_index = (n - 2) - i
    suffix = is_today ? "" : str.tostring(days_index)

    // If suffix is 0, don't show PDH/PDL0. Just show PDH/PDL.
    suffix := days_index == 0 ? "" : suffix

    pdh_label = is_today ? "CDH" : "PDH"
    pdl_label = is_today ? "CDL" : "PDL"

    high_price = line.get_y1(array.get(high_lines, i))
    low_price = line.get_y1(array.get(low_lines, i))
    high_price_text = ""
    low_price_text = ""

    if input_show_high_price
        high_price_text := " " + str.tostring(high_price, format.mintick)
    if input_show_low_price
        low_price_text := " " + str.tostring(low_price, format.mintick)

    label.set_text(array.get(high_labels, i), pdh_label + suffix + high_price_text)
    label.set_text(array.get(low_labels, i),  pdl_label + suffix + low_price_text)
````

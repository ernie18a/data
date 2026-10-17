# HigherHigh - Midnight Open

- url: https://www.tradingview.com/script/YLAfPXt8/
- type: indicator
- pine_id: PUB;58d984d43ce740f98ab5dc55db3b3504
- version: 1.0

## Description

[b]Midnight Open
[/b]
This indicator plots the New York Midnight Open: the opening price of the first candle of each new day in a chosen time zone (New York by default). Many ICT and intraday traders use it as a daily reference level. Price above the midnight open suggests a premium and bullish intraday bias. Price below it suggests a discount and bearish bias.

[b]How it works
[/b]
On each bar, the script checks whether the calendar day has changed in the selected time zone. The first bar of the new day marks midnight, and its open becomes the Midnight Open.
A horizontal line starts at that bar and extends to a configurable end hour (16:00 by default, the New York equity close). A price label sits at the end of the line.
Daylight saving time is handled automatically, because detection happens in the selected time zone and not in the chart's time zone. This matters because the US and Europe change clocks on different dates. For a Paris-based trader, the NY midnight open is usually 06:00, but it falls at 05:00 for a few weeks each spring and autumn.
Older lines are removed so only the most recent days stay on the chart.

[b]Settings
[/b]
Time zone: the reference time zone for "midnight" (for example America/New_York or Europe/London).
Line end (hour): the hour, in the selected time zone, at which each line stops.
Days displayed: how many past midnight opens to keep on the chart.
Color / Style / Width: line appearance (solid, dotted or dashed).
Show label: show or hide the price label.

[b]Alerts[/b]
Two alert conditions are included:

Bullish break: close crosses above the Midnight Open.
Bearish break: close crosses below the Midnight Open.

The current Midnight Open value also appears in the Data Window.

[b]Notes[/b]

Works on intraday timeframes up to 1 hour. On higher timeframes nothing is drawn, because a single bar can't isolate midnight.
The level is a reference point, not a trading signal on its own. Combine it with your own market structure and risk management.

## Source Code

````pine
//@version=6
indicator("Midnight Open", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ── Settings
tz        = input.string("America/New_York", "Time zone")
endHour   = input.int(16, "Line end (hour)", minval = 1, maxval = 24)
maxDays   = input.int(5, "Days displayed", minval = 1, maxval = 100)
lineColor = input.color(color.blue, "Color")
lineStyle = input.string("Dotted", "Style", options = ["Solid", "Dotted", "Dashed"])
lineWidth = input.int(1, "Width", minval = 1, maxval = 4)
showLabel = input.bool(true, "Show label")

style = switch lineStyle
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    => line.style_dotted

// ── Midnight detection (first bar of the new day in the selected time zone)
validTF = timeframe.isintraday and timeframe.in_seconds() <= 3600
newDay  = dayofmonth(time, tz) != dayofmonth(time[1], tz)

var line[]  lines  = array.new<line>()
var label[] labels = array.new<label>()
var float   mo     = na

if validTF and newDay
    mo := open
    tEnd = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), endHour, 0)

    lines.push(line.new(time, mo, tEnd, mo, xloc = xloc.bar_time, color = lineColor, style = style, width = lineWidth))
    if showLabel
        labels.push(label.new(tEnd, mo, "Midnight Open  " + str.tostring(mo, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color(na), textcolor = lineColor, size = size.small))

    if lines.size() > maxDays
        lines.shift().delete()
    if labels.size() > maxDays
        labels.shift().delete()

// Value shown in the Data Window + alerts
plot(mo, "Midnight Open", color = lineColor, display = display.data_window)
alertcondition(ta.crossover(close, mo),  "Midnight Open bullish break", "{{ticker}} crossed above the Midnight Open")
alertcondition(ta.crossunder(close, mo), "Midnight Open bearish break", "{{ticker}} crossed below the Midnight Open")
````

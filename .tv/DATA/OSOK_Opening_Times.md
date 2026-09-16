<!-- tradingview-pine-id: PUB;64f463fb86df4b938dd27bc58eccb784 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# OSOK Opening Times

Source: https://www.tradingview.com/script/pW6Z0vXS-OSOK-Opening-Times/

## Description

OSOK Opening Times marks the opening times of active trading periods with vertical lines. It automatically adjusts the periods shown to match your chart timeframe, using solid lines for the larger period and dotted lines for the smaller active period.

Each boundary pair marks the current period's opening and the next period's opening. This creates a clear time reference for the active day, week, month or quarter.

Timeframe visibility

The breakdown below shows the default line styles when all visibility settings are enabled.

[*]Intraday below 1D, including 15m, 1H and 4H
Solid: current week opening to next week opening.
Dotted: active day opening to next day opening.
[*]Daily - 1D
Solid: current month opening to next month opening.
Dotted: active week opening to next week opening.
[*]Weekly - 1W
Solid: current quarter opening to next quarter opening.
Dotted: active month opening to next month opening.
[*]Monthly - 1M
Solid: none.
Dotted: current quarter opening to next quarter opening.
[*]Other intervals above 1D, such as 2D, 2W and 3M
No lines are displayed.

A quarter is a three-month period. Quarterly boundaries appear on the 1W and 1M charts; the 3M chart itself displays no lines.

Active periods and shared boundaries

Only the active periods are displayed. As new periods begin, their boundaries replace the previous markers. On intraday charts, daily dotted lines bracket only the active daily candle.

When two displayed boundaries coincide, the larger period's line takes precedence. The first daily candle of the week uses the weekly opening line as its starting boundary, avoiding a duplicate daily line.

Appearance and customization

[*]Solid lines: black at 30% opacity by default.
[*]Dotted lines: black at 100% opacity by default.
[*]Line width: 1 by default.
[*]Visibility, color, opacity, style and width can be adjusted in the indicator's settings. Separate style settings are available for the different chart contexts.

Opening times and chart support

The indicator follows the symbol's TradingView candle sessions. Changing the chart's display timezone does not redefine those openings.

Upcoming boundaries use projected opening times. The active periods are determined by the latest chart bar, including when using Bar Replay.

The indicator supports standard time-based charts and Heikin Ashi. Tick, Renko, Range, Kagi, Line Break and Point & Figure charts are excluded.

---

## Source Code

````pine
//@version=6
indicator("OSOK Opening Times", overlay = true, max_lines_count = 20)
// Color pickers also let you change opacity.
// Pine uses transparency: 70 transparency = 30% opacity.
showQuarterly = input.bool(true, "Show quarterly lines on 1W", group = "Quarterly - on 1W")
quarterlyColor = input.color(color.new(#000000, 70), "Color / opacity", group = "Quarterly - on 1W")
quarterlyStyle = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], group = "Quarterly - on 1W")
quarterlyWidth = input.int(1, "Width", minval = 1, maxval = 5, group = "Quarterly - on 1W")
showQuarterlyMonthly = input.bool(true, "Show quarterly lines on 1M", group = "Quarterly - on 1M")
quarterlyMonthlyColor = input.color(color.new(#000000, 0), "Color / opacity", group = "Quarterly - on 1M")
quarterlyMonthlyStyle = input.string("Dotted", "Style", options = ["Solid", "Dashed", "Dotted"], group = "Quarterly - on 1M")
quarterlyMonthlyWidth = input.int(1, "Width", minval = 1, maxval = 5, group = "Quarterly - on 1M")
showMonthly = input.bool(true, "Show monthly lines on 1D and 1W", group = "Monthly - on 1D")
monthlyColor = input.color(color.new(#000000, 70), "Color / opacity", group = "Monthly - on 1D")
monthlyStyle = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], group = "Monthly - on 1D")
monthlyWidth = input.int(1, "Width", minval = 1, maxval = 5, group = "Monthly - on 1D")
monthlyWeeklyColor = input.color(color.new(#000000, 0), "Color / opacity", group = "Monthly - on 1W")
monthlyWeeklyStyle = input.string("Dotted", "Style", options = ["Solid", "Dashed", "Dotted"], group = "Monthly - on 1W")
monthlyWeeklyWidth = input.int(1, "Width", minval = 1, maxval = 5, group = "Monthly - on 1W")
showWeekly = input.bool(true, "Show weekly lines on 1D and below", group = "Weekly - below 1D")
weeklyColor = input.color(color.new(#000000, 70), "Color / opacity", group = "Weekly - below 1D")
weeklyStyle = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], group = "Weekly - below 1D")
weeklyWidth = input.int(1, "Width", minval = 1, maxval = 5, group = "Weekly - below 1D")
weeklyDailyColor = input.color(color.new(#000000, 0), "Color / opacity", group = "Weekly - on 1D")
weeklyDailyStyle = input.string("Dotted", "Style", options = ["Solid", "Dashed", "Dotted"], group = "Weekly - on 1D")
weeklyDailyWidth = input.int(1, "Width", minval = 1, maxval = 5, group = "Weekly - on 1D")
showDaily = input.bool(true, "Show active daily boundaries", group = "Daily")
dailyColor = input.color(color.new(#000000, 0), "Color / opacity", group = "Daily")
dailyStyle = input.string("Dotted", "Style", options = ["Solid", "Dashed", "Dotted"], group = "Daily")
dailyWidth = input.int(1, "Width", minval = 1, maxval = 5, group = "Daily")
getStyle(string choice) =>
    switch choice
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid
drawVertical(int openingTime, color lineColor, string lineStyle, int lineWidth) =>
    // Distinct Y coordinates keep the line visible even on a flat candle.
    line.new(
         x1 = openingTime, y1 = low,
         x2 = openingTime, y2 = math.max(high, low + syminfo.mintick),
         xloc = xloc.bar_time, extend = extend.both,
         color = lineColor, style = lineStyle, width = lineWidth)
// Default hierarchy:
// Below 1D: solid weekly boundaries and dotted active daily boundaries.
// Exactly 1D: solid monthly boundaries and dotted active weekly boundaries.
// Exactly 1W: solid quarterly boundaries and dotted active monthly boundaries.
// Exactly 1M: dotted quarterly boundaries only.
// Other timeframes above 1D: no lines.
bool supportedChart = chart.is_standard or chart.is_heikinashi
bool belowDaily = (timeframe.isseconds or timeframe.isminutes) and timeframe.in_seconds() < 86400
bool exactlyDaily = timeframe.isdaily and timeframe.multiplier == 1
bool exactlyWeekly = timeframe.isweekly and timeframe.multiplier == 1
bool exactlyMonthly = timeframe.ismonthly and timeframe.multiplier == 1
bool quarterlyVisible = supportedChart and ((showQuarterly and exactlyWeekly) or (showQuarterlyMonthly and exactlyMonthly))
bool monthlyVisible = showMonthly and supportedChart and (exactlyDaily or exactlyWeekly)
bool weeklyVisible = showWeekly and supportedChart and (belowDaily or exactlyDaily)
bool dailyVisible = showDaily and supportedChart and belowDaily
color activeQuarterlyColor = exactlyMonthly ? quarterlyMonthlyColor : quarterlyColor
string activeQuarterlyStyle = getStyle(exactlyMonthly ? quarterlyMonthlyStyle : quarterlyStyle)
int activeQuarterlyWidth = exactlyMonthly ? quarterlyMonthlyWidth : quarterlyWidth
color activeMonthlyColor = exactlyWeekly ? monthlyWeeklyColor : monthlyColor
string activeMonthlyStyle = getStyle(exactlyWeekly ? monthlyWeeklyStyle : monthlyStyle)
int activeMonthlyWidth = exactlyWeekly ? monthlyWeeklyWidth : monthlyWidth
color activeWeeklyColor = exactlyDaily ? weeklyDailyColor : weeklyColor
string activeWeeklyStyle = getStyle(exactlyDaily ? weeklyDailyStyle : weeklyStyle)
int activeWeeklyWidth = exactlyDaily ? weeklyDailyWidth : weeklyWidth
// Uses the symbol's TradingView session, not the chart display timezone.
// Current periods are determined by the chart's latest bar (also in Replay).
int quarterOpen = time("3M")
int nextQuarterOpen = time("3M", timeframe_bars_back = -1)
int monthOpen = time("1M")
int nextMonthOpen = time("1M", timeframe_bars_back = -1)
int weekOpen = time("1W")
int nextWeekOpen = time("1W", timeframe_bars_back = -1)
int dayOpen = time("1D")
int previousDayOpen = time("1D", timeframe_bars_back = 1)
int nextDayOpen = time("1D", timeframe_bars_back = -1)
var array<line> markers = array.new<line>()
if barstate.islast
    // Keep only the active periods allowed on the current chart timeframe.
    while array.size(markers) > 0
        line.delete(array.pop(markers))
    if quarterlyVisible and not na(quarterOpen) and not na(nextQuarterOpen)
        array.push(markers, drawVertical(quarterOpen, activeQuarterlyColor, activeQuarterlyStyle, activeQuarterlyWidth))
        array.push(markers, drawVertical(nextQuarterOpen, activeQuarterlyColor, activeQuarterlyStyle, activeQuarterlyWidth))
    if monthlyVisible and not na(monthOpen) and not na(nextMonthOpen)
        bool monthStartOverlap = quarterlyVisible and (monthOpen == quarterOpen or monthOpen == nextQuarterOpen)
        bool monthEndOverlap = quarterlyVisible and (nextMonthOpen == quarterOpen or nextMonthOpen == nextQuarterOpen)
        if not monthStartOverlap
            array.push(markers, drawVertical(monthOpen, activeMonthlyColor, activeMonthlyStyle, activeMonthlyWidth))
        if not monthEndOverlap
            array.push(markers, drawVertical(nextMonthOpen, activeMonthlyColor, activeMonthlyStyle, activeMonthlyWidth))
    if (weeklyVisible or dailyVisible) and not na(weekOpen) and not na(nextWeekOpen)
        if weeklyVisible
            bool weekStartOverlap = monthlyVisible and (weekOpen == monthOpen or weekOpen == nextMonthOpen)
            bool weekEndOverlap = monthlyVisible and (nextWeekOpen == monthOpen or nextWeekOpen == nextMonthOpen)
            if not weekStartOverlap
                array.push(markers, drawVertical(weekOpen, activeWeeklyColor, activeWeeklyStyle, activeWeeklyWidth))
            if not weekEndOverlap
                array.push(markers, drawVertical(nextWeekOpen, activeWeeklyColor, activeWeeklyStyle, activeWeeklyWidth))
        if dailyVisible
            // Only bracket the daily candle containing the latest chart bar.
            // Checking the previous daily open also handles a first daily candle
            // that starts later than the weekly timestamp, e.g. after a holiday.
            bool insideWeek = not na(dayOpen) and dayOpen >= weekOpen and dayOpen < nextWeekOpen
            bool firstDayOfWeek = dayOpen == weekOpen or (not na(previousDayOpen) and previousDayOpen < weekOpen)
            if insideWeek
                // The weekly line serves as the first daily candle's start.
                if not (weeklyVisible and firstDayOfWeek)
                    array.push(markers, drawVertical(dayOpen, dailyColor, getStyle(dailyStyle), dailyWidth))
                // The next opening ends the active day's bracket. At the week's
                // end, the next weekly line takes precedence over a dotted line.
                if not na(nextDayOpen) and nextDayOpen > dayOpen
                    int dayEnd = math.min(nextDayOpen, nextWeekOpen)
                    if not (weeklyVisible and dayEnd == nextWeekOpen)
                        array.push(markers, drawVertical(dayEnd, dailyColor, getStyle(dailyStyle), dailyWidth))

// END OF SCRIPT
````

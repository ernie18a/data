# Trend Analysis by The Smart Money Club

- url: https://www.tradingview.com/script/FrCuFFXo-Trend-Analysis-by-The-Smart-Money-Club/
- type: indicator
- pine_id: PUB;5bccd5b452b1403f913409306d6af6f9
- version: 5.0

## Description

Trend Analysis is a visual market structure tool designed to help traders identify and follow developing trends throughout the trading week. The indicator highlights the range of the first Asian session candle each day and color-codes it by weekday, making it easier to track whether price continues to respect and build upon the same directional bias over multiple days.

By observing how price reacts to these daily Asian ranges, traders can quickly determine if a bullish or bearish trend remains intact from the start of the week and whether momentum is continuing to carry forward into subsequent trading sessions.

Developed by The Smart Money Club, this indicator is intended to support trend-following and Smart Money Concepts (SMC) analysis by providing a clear visual framework for identifying sustained directional movement across the week.

## Source Code

````pine
//@version=6
indicator("Trend Analysis by The Smart Money Club", shorttitle="TSMC Trend Analysis", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

//────────────────────────────────────────────
// INPUTS
//────────────────────────────────────────────

showMidline     = input.bool(true, "Show Equilibrium (50%)")
showLabels      = input.bool(true, "Show Day Labels")
showDayLines    = input.bool(true, "Show 00:00 Day Lines")
boxTransparency = input.int(85, "Box Transparency", minval=0, maxval=100)

//────────────────────────────────────────────
// WEEKDAY COLORS
//────────────────────────────────────────────

mondayColor    = color.rgb(239, 176, 203)
tuesdayColor   = color.rgb(231, 199, 178)
wednesdayColor = color.rgb(240, 228, 154)
thursdayColor  = color.rgb(228, 241, 213)
fridayColor    = color.rgb(224, 237, 254)
saturdayColor  = color.rgb(221, 240, 254)
sundayColor    = color.rgb(180, 99, 201)

//────────────────────────────────────────────
// GERMAN TIME / DAY
//────────────────────────────────────────────

germanDayOfWeek = dayofweek(time, "Europe/Berlin")
germanDay       = dayofmonth(time, "Europe/Berlin")

//────────────────────────────────────────────
// DAY COLOR — BASED ON GERMAN TIME
//────────────────────────────────────────────

dayColor =
     germanDayOfWeek == dayofweek.monday    ? mondayColor :
     germanDayOfWeek == dayofweek.tuesday   ? tuesdayColor :
     germanDayOfWeek == dayofweek.wednesday ? wednesdayColor :
     germanDayOfWeek == dayofweek.thursday  ? thursdayColor :
     germanDayOfWeek == dayofweek.friday    ? fridayColor :
     germanDayOfWeek == dayofweek.saturday  ? saturdayColor :
     sundayColor

//────────────────────────────────────────────
// DAY LABEL — BASED ON GERMAN TIME
//────────────────────────────────────────────

dayLabel =
     germanDayOfWeek == dayofweek.monday    ? "MO" :
     germanDayOfWeek == dayofweek.tuesday   ? "TU" :
     germanDayOfWeek == dayofweek.wednesday ? "WE" :
     germanDayOfWeek == dayofweek.thursday  ? "TH" :
     germanDayOfWeek == dayofweek.friday    ? "FR" :
     germanDayOfWeek == dayofweek.saturday  ? "SA" :
     "SU"

//────────────────────────────────────────────
// GERMAN MIDNIGHT — 00:00 EUROPE/BERLIN
//────────────────────────────────────────────

isGermanMidnight = ta.change(germanDay) != 0

//────────────────────────────────────────────
// VERTICAL DAY LINE
//────────────────────────────────────────────

if showDayLines and isGermanMidnight
    line.new(
         x1 = time,
         y1 = low,
         x2 = time,
         y2 = high,
         xloc = xloc.bar_time,
         extend = extend.both,
         color = dayColor,
         width = 2,
         style = line.style_solid)

//────────────────────────────────────────────
// FIRST REGULAR SESSION BAR
//────────────────────────────────────────────

isOpeningBar = session.isfirstbar_regular

//────────────────────────────────────────────
// VARIABLES
//────────────────────────────────────────────

var float rangeHigh = na
var float rangeLow  = na
var float rangeMid  = na

//────────────────────────────────────────────
// CREATE DAILY RANGE BOX
//────────────────────────────────────────────

if isOpeningBar

    rangeHigh := high
    rangeLow  := low
    rangeMid  := (rangeHigh + rangeLow) / 2

    daysUntilFriday = math.max(0, dayofweek.friday - germanDayOfWeek)

    endTime = timestamp(
         "Europe/Berlin",
         year(time, "Europe/Berlin"),
         month(time, "Europe/Berlin"),
         dayofmonth(time, "Europe/Berlin") + daysUntilFriday,
         23,
         45)

    box.new(
         left = time,
         top = rangeHigh,
         right = endTime,
         bottom = rangeLow,
         xloc = xloc.bar_time,
         bgcolor = color.new(dayColor, boxTransparency),
         border_color = dayColor,
         border_width = 2)

    if showMidline
        line.new(
             x1 = time,
             y1 = rangeMid,
             x2 = endTime,
             y2 = rangeMid,
             xloc = xloc.bar_time,
             color = dayColor,
             width = 1,
             style = line.style_dashed)

    if showLabels
        label.new(
             x = time,
             y = rangeHigh,
             xloc = xloc.bar_time,
             text = dayLabel,
             style = label.style_label_down,
             color = dayColor,
             textcolor = color.black,
             size = size.small)

//────────────────────────────────────────────
// BREAKOUT LOGIC
//────────────────────────────────────────────

bullBreak = not na(rangeHigh) and ta.crossover(close, rangeHigh)
bearBreak = not na(rangeLow) and ta.crossunder(close, rangeLow)

//────────────────────────────────────────────
// ALERTS
//────────────────────────────────────────────

alertcondition(
     bullBreak,
     title = "Opening Range High Broken",
     message = "Bullish breakout above opening range.")

alertcondition(
     bearBreak,
     title = "Opening Range Low Broken",
     message = "Bearish breakout below opening range.")

//────────────────────────────────────────────
// HIDDEN DATA WINDOW VALUES
//────────────────────────────────────────────

plot(rangeHigh, "Range High", display = display.none)
plot(rangeLow,  "Range Low",  display = display.none)
plot(rangeMid,  "Range Mid",  display = display.none)
````

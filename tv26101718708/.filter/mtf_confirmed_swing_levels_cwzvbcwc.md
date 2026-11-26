# MTF Confirmed Swing Levels

- url: https://www.tradingview.com/script/CWZvbcWc-MTF-Confirmed-Swing-Levels/
- type: indicator
- pine_id: PUB;394b2f041505458faa29cf01339b7541
- version: 1.0

## Description

# MTF Confirmed Swing Levels

MTF Confirmed Swing Levels is a multi-timeframe market structure indicator that automatically identifies confirmed swing highs and swing lows and marks them with horizontal lines.

The indicator calculates market structure separately for each selected timeframe. This means that a swing high visible on the 15-minute timeframe does not automatically become a swing high on the 1-hour timeframe. Every timeframe keeps its own independent structure.

## How It Works

A swing high is confirmed when the price forms a local high and then changes direction.

A swing low is confirmed when the price forms a local low and then changes direction.

The indicator uses candles on both sides of a potential turning point:

* “Candles Left” controls how many candles before the turning point are evaluated.
* “Candles Right” controls how many candles must form after the turning point before the swing is confirmed.

For example, with 2 candles left and 2 candles right, a swing high must be higher than the two candles before it and the two candles after it.

Because the swing requires confirmation, the line appears only after the selected number of right-side candles has closed. However, the line is placed at the original candle where the swing occurred.

## Supported Timeframes

The following timeframes can be enabled or disabled individually:

* Weekly
* Daily
* 4-hour
* 1-hour
* 30-minute
* 15-minute
* 5-minute
* 1-minute

Higher-timeframe and lower-timeframe swing levels can be displayed directly on the current chart.

For example, you can display 15-minute swing levels on a 1-hour chart, even when the 1-hour candle itself does not form a confirmed swing.

## Main Features

* Confirmed swing high and swing low detection
* Independent calculations for every timeframe
* Multi-timeframe swing levels on one chart
* Separate colors for swing highs and swing lows
* Adjustable line thickness
* Adjustable line style
* Adjustable horizontal line length
* Optional extension of levels indefinitely to the right
* Adjustable maximum number of visible lines
* Automatic removal of the oldest levels when the line limit is reached

## Suggested Settings

For faster and more sensitive market structure:

* Candles Left: 2
* Candles Right: 1

For balanced swing detection:

* Candles Left: 2
* Candles Right: 2

For larger and more significant market structure:

* Candles Left: 3
* Candles Right: 3

Lower values detect more swings but may create more market noise. Higher values produce fewer but generally more significant swing levels.

## Practical Uses

The indicator can help identify:

* Potential support and resistance
* Liquidity above swing highs and below swing lows
* Higher highs and higher lows
* Lower highs and lower lows
* Breaks of market structure
* Trend continuation areas
* Reversal zones
* Multi-timeframe confluence
* Possible entry, stop-loss and take-profit reference levels

## Important Notes

Swing levels are confirmed only after the required right-side candles have formed. This reduces premature signals but creates a natural confirmation delay.

Displaying very low timeframe levels on a much higher timeframe may produce many horizontal lines. For a cleaner chart, enable only the timeframes that are relevant to your trading strategy.

The amount of available lower-timeframe historical data may also depend on TradingView’s intrabar data limits and the user’s subscription plan.

This indicator does not provide automatic buy or sell signals. It is designed as a market structure and technical analysis tool.

Use it together with your own trading plan, risk management and confirmation criteria.

Disclaimer: This indicator is provided for educational and informational purposes only. It does not constitute financial advice.

## Source Code

````pine
//@version=6
indicator(
     title = "MTF Confirmed Swing Levels",
     shorttitle = "MTF Swing",
     overlay = true,
     max_lines_count = 500
)

//──────────────────────────────────────────────────────────────────────────────
// GROEPEN
//──────────────────────────────────────────────────────────────────────────────

string GROUP_SWINGS = "1. Swing-berekening"
string GROUP_LINES  = "2. Lijninstellingen"
string GROUP_TF     = "3. Timeframes"

//──────────────────────────────────────────────────────────────────────────────
// SWING-INSTELLINGEN
//──────────────────────────────────────────────────────────────────────────────

int leftBars = input.int(
     defval = 2,
     title = "Candles links",
     minval = 1,
     maxval = 20,
     group = GROUP_SWINGS,
     tooltip = "Aantal candles links van het mogelijke draaipunt."
)

int rightBars = input.int(
     defval = 2,
     title = "Candles rechts voor bevestiging",
     minval = 1,
     maxval = 20,
     group = GROUP_SWINGS,
     tooltip = "Aantal gesloten candles dat nodig is om de swing te bevestigen."
)

//──────────────────────────────────────────────────────────────────────────────
// LIJNINSTELLINGEN
//──────────────────────────────────────────────────────────────────────────────

int lineLengthBars = input.int(
     defval = 20,
     title = "Lengte lijn",
     minval = 1,
     maxval = 500,
     group = GROUP_LINES,
     tooltip = "Lengte uitgedrukt in candles van de timeframe waarop de swing ontstond."
)

int lineWidth = input.int(
     defval = 2,
     title = "Dikte lijn",
     minval = 1,
     maxval = 4,
     group = GROUP_LINES
)

string lineStyleInput = input.string(
     defval = "Solid",
     title = "Lijnstijl",
     options = ["Solid", "Dashed", "Dotted"],
     group = GROUP_LINES
)

bool extendRight = input.bool(
     defval = false,
     title = "Lijnen onbeperkt naar rechts verlengen",
     group = GROUP_LINES
)

int maxStoredLines = input.int(
     defval = 300,
     title = "Maximum aantal lijnen",
     minval = 10,
     maxval = 500,
     group = GROUP_LINES,
     tooltip = "De oudste lijnen worden automatisch verwijderd."
)

//──────────────────────────────────────────────────────────────────────────────
// TIMEFRAMES EN KLEUREN
//──────────────────────────────────────────────────────────────────────────────

// Weekly
bool showWeekly = input.bool(
     defval = true,
     title = "Weekly",
     inline = "W",
     group = GROUP_TF
)

color weeklyHighColor = input.color(
     defval = color.rgb(139, 0, 0),
     title = "High",
     inline = "W",
     group = GROUP_TF
)

color weeklyLowColor = input.color(
     defval = color.rgb(0, 100, 0),
     title = "Low",
     inline = "W",
     group = GROUP_TF
)

// Daily
bool showDaily = input.bool(
     defval = true,
     title = "Daily",
     inline = "D",
     group = GROUP_TF
)

color dailyHighColor = input.color(
     defval = color.red,
     title = "High",
     inline = "D",
     group = GROUP_TF
)

color dailyLowColor = input.color(
     defval = color.green,
     title = "Low",
     inline = "D",
     group = GROUP_TF
)

// 4 uur
bool show4H = input.bool(
     defval = true,
     title = "4 Hour",
     inline = "4H",
     group = GROUP_TF
)

color high4HColor = input.color(
     defval = color.orange,
     title = "High",
     inline = "4H",
     group = GROUP_TF
)

color low4HColor = input.color(
     defval = color.teal,
     title = "Low",
     inline = "4H",
     group = GROUP_TF
)

// 1 uur
bool show1H = input.bool(
     defval = true,
     title = "1 Hour",
     inline = "1H",
     group = GROUP_TF
)

color high1HColor = input.color(
     defval = color.yellow,
     title = "High",
     inline = "1H",
     group = GROUP_TF
)

color low1HColor = input.color(
     defval = color.aqua,
     title = "Low",
     inline = "1H",
     group = GROUP_TF
)

// 30 minuten
bool show30M = input.bool(
     defval = false,
     title = "30 Min",
     inline = "30M",
     group = GROUP_TF
)

color high30MColor = input.color(
     defval = color.purple,
     title = "High",
     inline = "30M",
     group = GROUP_TF
)

color low30MColor = input.color(
     defval = color.blue,
     title = "Low",
     inline = "30M",
     group = GROUP_TF
)

// 15 minuten
bool show15M = input.bool(
     defval = false,
     title = "15 Min",
     inline = "15M",
     group = GROUP_TF
)

color high15MColor = input.color(
     defval = color.fuchsia,
     title = "High",
     inline = "15M",
     group = GROUP_TF
)

color low15MColor = input.color(
     defval = color.rgb(0, 90, 180),
     title = "Low",
     inline = "15M",
     group = GROUP_TF
)

// 5 minuten
bool show5M = input.bool(
     defval = false,
     title = "5 Min",
     inline = "5M",
     group = GROUP_TF
)

color high5MColor = input.color(
     defval = color.rgb(255, 120, 120),
     title = "High",
     inline = "5M",
     group = GROUP_TF
)

color low5MColor = input.color(
     defval = color.rgb(100, 220, 150),
     title = "Low",
     inline = "5M",
     group = GROUP_TF
)

// 1 minuut
bool show1M = input.bool(
     defval = false,
     title = "1 Min",
     inline = "1M",
     group = GROUP_TF
)

color high1MColor = input.color(
     defval = color.rgb(180, 120, 70),
     title = "High",
     inline = "1M",
     group = GROUP_TF
)

color low1MColor = input.color(
     defval = color.rgb(120, 160, 70),
     title = "Low",
     inline = "1M",
     group = GROUP_TF
)

//──────────────────────────────────────────────────────────────────────────────
// LIJNSTIJL
//──────────────────────────────────────────────────────────────────────────────

f_getLineStyle() =>
    lineStyleInput == "Dashed" ? line.style_dashed :
     lineStyleInput == "Dotted" ? line.style_dotted :
     line.style_solid

//──────────────────────────────────────────────────────────────────────────────
// OPSLAG LIJNEN
//──────────────────────────────────────────────────────────────────────────────

var array<line> swingLines = array.new<line>()

//──────────────────────────────────────────────────────────────────────────────
// NIEUWE HORIZONTALE LIJN MAKEN
//──────────────────────────────────────────────────────────────────────────────

f_drawLevel(
     int pivotTime,
     float pivotPrice,
     string sourceTimeframe,
     color levelColor
 ) =>
    int timeframeMilliseconds = int(timeframe.in_seconds(sourceTimeframe) * 1000)

    int lineEndTime = pivotTime + timeframeMilliseconds * lineLengthBars

    line newSwingLine = line.new(
         x1 = pivotTime,
         y1 = pivotPrice,
         x2 = lineEndTime,
         y2 = pivotPrice,
         xloc = xloc.bar_time,
         extend = extendRight ? extend.right : extend.none,
         color = levelColor,
         style = f_getLineStyle(),
         width = lineWidth
    )

    array.push(swingLines, newSwingLine)

    if array.size(swingLines) > maxStoredLines
        line oldestLine = array.shift(swingLines)
        line.delete(oldestLine)

    0

//──────────────────────────────────────────────────────────────────────────────
// SWINGDATA VOOR ANDERE TIMEFRAMES
//
// [1] betekent dat alleen de vorige volledig gesloten broncandle wordt gebruikt.
// De lijn wordt geplaatst op de candle waar de swing werkelijk ontstond.
//──────────────────────────────────────────────────────────────────────────────

f_previousConfirmedSwingData() =>
    float pivotHigh = ta.pivothigh(high, leftBars, rightBars)
    float pivotLow = ta.pivotlow(low, leftBars, rightBars)

    int pivotHighTime = not na(pivotHigh) ? time[rightBars] : na
    int pivotLowTime = not na(pivotLow) ? time[rightBars] : na

    [pivotHigh[1], pivotLow[1], pivotHighTime[1], pivotLowTime[1]]

//──────────────────────────────────────────────────────────────────────────────
// SWINGS VAN DE HUIDIGE CHART-TIMEFRAME
//──────────────────────────────────────────────────────────────────────────────

float chartPivotHigh = ta.pivothigh(high, leftBars, rightBars)
float chartPivotLow = ta.pivotlow(low, leftBars, rightBars)

int chartPivotHighTime = not na(chartPivotHigh) ? time[rightBars] : na
int chartPivotLowTime = not na(chartPivotLow) ? time[rightBars] : na

//──────────────────────────────────────────────────────────────────────────────
// TIMEFRAME VERWERKEN
//──────────────────────────────────────────────────────────────────────────────

f_processTimeframe(
     bool enabled,
     string sourceTimeframe,
     color highColor,
     color lowColor
 ) =>
    if enabled
        int sourceSeconds = int(timeframe.in_seconds(sourceTimeframe))
        int chartSeconds = int(timeframe.in_seconds())

        // Geselecteerde timeframe is gelijk aan de chart-timeframe.
        if sourceSeconds == chartSeconds
            if barstate.isconfirmed
                if not na(chartPivotHigh) and not na(chartPivotHighTime)
                    f_drawLevel(
                         chartPivotHighTime,
                         chartPivotHigh,
                         sourceTimeframe,
                         highColor
                    )

                if not na(chartPivotLow) and not na(chartPivotLowTime)
                    f_drawLevel(
                         chartPivotLowTime,
                         chartPivotLow,
                         sourceTimeframe,
                         lowColor
                    )

        // Geselecteerde timeframe is hoger dan de chart-timeframe.
        else if sourceSeconds > chartSeconds
            [higherPivotHigh, higherPivotLow, higherPivotHighTime, higherPivotLowTime] = request.security(
                 symbol = syminfo.tickerid,
                 timeframe = sourceTimeframe,
                 expression = f_previousConfirmedSwingData(),
                 gaps = barmerge.gaps_on,
                 lookahead = barmerge.lookahead_on
            )

            if not na(higherPivotHigh) and not na(higherPivotHighTime)
                f_drawLevel(
                     higherPivotHighTime,
                     higherPivotHigh,
                     sourceTimeframe,
                     highColor
                )

            if not na(higherPivotLow) and not na(higherPivotLowTime)
                f_drawLevel(
                     higherPivotLowTime,
                     higherPivotLow,
                     sourceTimeframe,
                     lowColor
                )

        // Geselecteerde timeframe is lager dan de chart-timeframe.
        else
            [lowerPivotHighs, lowerPivotLows, lowerPivotHighTimes, lowerPivotLowTimes] = request.security_lower_tf(
                 symbol = syminfo.tickerid,
                 timeframe = sourceTimeframe,
                 expression = f_previousConfirmedSwingData(),
                 ignore_invalid_timeframe = true
            )

            int intrabarCount = array.size(lowerPivotHighs)

            if intrabarCount > 0
                for index = 0 to intrabarCount - 1
                    float lowerPivotHigh = array.get(lowerPivotHighs, index)
                    float lowerPivotLow = array.get(lowerPivotLows, index)

                    int lowerPivotHighTime = array.get(lowerPivotHighTimes, index)
                    int lowerPivotLowTime = array.get(lowerPivotLowTimes, index)

                    if not na(lowerPivotHigh) and not na(lowerPivotHighTime)
                        f_drawLevel(
                             lowerPivotHighTime,
                             lowerPivotHigh,
                             sourceTimeframe,
                             highColor
                        )

                    if not na(lowerPivotLow) and not na(lowerPivotLowTime)
                        f_drawLevel(
                             lowerPivotLowTime,
                             lowerPivotLow,
                             sourceTimeframe,
                             lowColor
                        )

    0

//──────────────────────────────────────────────────────────────────────────────
// ALLE TIMEFRAMES
//──────────────────────────────────────────────────────────────────────────────

f_processTimeframe(showWeekly, "W", weeklyHighColor, weeklyLowColor)
f_processTimeframe(showDaily, "D", dailyHighColor, dailyLowColor)
f_processTimeframe(show4H, "240", high4HColor, low4HColor)
f_processTimeframe(show1H, "60", high1HColor, low1HColor)
f_processTimeframe(show30M, "30", high30MColor, low30MColor)
f_processTimeframe(show15M, "15", high15MColor, low15MColor)
f_processTimeframe(show5M, "5", high5MColor, low5MColor)
f_processTimeframe(show1M, "1", high1MColor, low1MColor)
````

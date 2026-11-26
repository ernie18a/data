# Context Fibonacci Key Levels

- url: https://www.tradingview.com/script/S1GQNCPp-Context-Fibonacci-Key-Levels/
- type: indicator
- pine_id: PUB;3582533dbe564a528bb2a17d4296b454
- version: 2.0

## Description

Context Fibonacci Key Levels automatically plots Fibonacci retracement and extension levels using the most recently completed Day, Week and Month candles while preserving the directional context of each timeframe.

Rather than treating every Fibonacci equally, the indicator determines whether the previous higher timeframe candle closed bullish or bearish and automatically adjusts the Fibonacci orientation to reflect that completed price movement.

This creates objective reference levels that remain consistent across every chart timeframe.


[list]
[*]Automatic Past Day Fibonacci
[*]Automatic Past Week Fibonacci
[*]Automatic Past Month Fibonacci
[*]Automatic bullish or bearish orientation
[*]Retracement and extension levels
[*]Works on every timeframe
[*]Independent colors for each timeframe
[/list]

Optional labels:
Full Name or Shorthand display mode


[b]How it works[/b]

The indicator evaluates the previous completed candle of each selected higher timeframe.

If the candle closed [b]bullish[/b], the Fibonacci is drawn from Low to High.

If the candle closed [b]bearish[/b], the Fibonacci is drawn from High to Low.

This allows every Fibonacci to represent the completed directional movement of its corresponding candle.

[b]Included Fibonacci Levels[/b]

[list]
[*]0%
[*]23.6%
[*]38.2%
[*]50%
[*]61.8%
[*]78.6%
[*]100%
[/list]

[b]Customization[/b]

[list]
[*]Enable or disable Past Day Fibonacci.
[*]Enable or disable Past Week Fibonacci.
[*]Enable or disable Past Month Fibonacci.
[*]Choose an individual color for each timeframe.
[*]Adjust line width.
[*]Show or hide labels.
[*]Display labels using Full Name (Past Day, Past Week and Past Month) or Shorthand (PD, PW and PM).
[/list]

[b]Use Cases[/b]

These levels can be used as objective higher timeframe reference zones for technical analysis, confluence studies, liquidity mapping, retracement analysis, extension targets and general market structure observations.

Because the calculations are always based on the latest completed higher timeframe candle, the levels automatically update whenever a new Day, Week or Month closes.

[b]Disclaimer[/b]

This indicator is designed as a technical analysis tool and does not generate trading signals or predict future market direction. It is intended to be used alongside your own trading methodology and additional sources of market confluence.

## Source Code

````pine
//@version=6
indicator("Context Fibonacci Key Levels", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ─────────────────────────────
// INPUTS
// ─────────────────────────────

showDaily  = input.bool(true, "Show Previous Day Fib", group = "Daily Fib")
dailyColor = input.color(color.new(#058292, 0), "Daily Color", group = "Daily Fib")

showWeekly  = input.bool(true, "Show Previous Week Fib", group = "Weekly Fib")
weeklyColor = input.color(color.new(#40b808, 0), "Weekly Color", group = "Weekly Fib")

showMonthly  = input.bool(true, "Show Previous Month Fib", group = "Monthly Fib")
monthlyColor = input.color(color.new(#670479, 0), "Monthly Color", group = "Monthly Fib")

showLabels = input.bool(true, "Show Labels", group = "Display")

labelMode = input.string(
     "Full Name",
     "Label Name Mode",
     options = ["Full Name", "Shorthand"],
     group = "Display"
)

lineWidth = input.int(
     1,
     "Line Width",
     minval = 1,
     maxval = 4,
     group = "Display"
)

// ─────────────────────────────
// FIBONACCI RETRACEMENT LEVELS
// ─────────────────────────────

var float[] fibLevels = array.from(
     0.0,
     0.236,
     0.382,
     0.5,
     0.618,
     0.786,
     1.0
)

var string[] fibNames = array.from(
     "0%",
     "23.6%",
     "38.2%",
     "50%",
     "61.8%",
     "78.6%",
     "100%"
)

// ─────────────────────────────
// PREVIOUS DAY DATA
// ─────────────────────────────

[dOpen, dHigh, dLow, dClose, dTime] = request.security(
     syminfo.tickerid,
     "D",
     [open[1], high[1], low[1], close[1], time[1]],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

// ─────────────────────────────
// PREVIOUS WEEK DATA
// ─────────────────────────────

[wOpen, wHigh, wLow, wClose, wTime] = request.security(
     syminfo.tickerid,
     "W",
     [open[1], high[1], low[1], close[1], time[1]],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

// ─────────────────────────────
// PREVIOUS MONTH DATA
// ─────────────────────────────

[mOpen, mHigh, mLow, mClose, mTime] = request.security(
     syminfo.tickerid,
     "M",
     [open[1], high[1], low[1], close[1], time[1]],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

// ─────────────────────────────
// DRAWING ARRAYS
// ─────────────────────────────

var line[] dailyLines   = array.new_line()
var label[] dailyLabels = array.new_label()

var line[] weeklyLines   = array.new_line()
var label[] weeklyLabels = array.new_label()

var line[] monthlyLines   = array.new_line()
var label[] monthlyLabels = array.new_label()

// ─────────────────────────────
// INITIALIZE OBJECTS
// ─────────────────────────────

f_init(line[] lines, label[] labels) =>

    if array.size(lines) == 0

        for i = 0 to array.size(fibLevels) - 1

            line newLine = line.new(
                 x1 = time,
                 y1 = close,
                 x2 = time,
                 y2 = close,
                 xloc = xloc.bar_time,
                 extend = extend.right
            )

            label newLabel = label.new(
                 x = time,
                 y = close,
                 text = "",
                 xloc = xloc.bar_time,
                 style = label.style_label_left,
                 color = color.new(color.black, 100),
                 size = size.small
            )

            array.push(lines, newLine)
            array.push(labels, newLabel)

// ─────────────────────────────
// UPDATE FIBONACCI
// ─────────────────────────────

f_update(
     bool show,
     string tag,
     float o,
     float h,
     float l,
     float c,
     int startTime,
     color baseColor,
     line[] lines,
     label[] labels) =>

    f_init(lines, labels)

    bool validData =
         not na(o) and
         not na(h) and
         not na(l) and
         not na(c) and
         not na(startTime)

    if validData

        // Direction of the completed period
        bool isBullish = c >= o

        float priceRange = h - l

        color finalColor =
             show
             ? baseColor
             : color.new(baseColor, 100)

        color textColor =
             show and showLabels
             ? baseColor
             : color.new(baseColor, 100)

        string biasText =
             isBullish
             ? "Bullish Fib"
             : "Bearish Fib"

        for i = 0 to array.size(fibLevels) - 1

            float level = array.get(fibLevels, i)
            string levelName = array.get(fibNames, i)

            // ─────────────────────────
            // RETRACEMENT ORIENTATION
            //
            // Bullish:
            // 0%   = High
            // 100% = Low
            //
            // Bearish:
            // 0%   = Low
            // 100% = High
            // ─────────────────────────

            float price =
                 isBullish
                 ? h - (priceRange * level)
                 : l + (priceRange * level)

            line ln = array.get(lines, i)
            label lb = array.get(labels, i)

            // LINE

            line.set_xy1(
                 ln,
                 startTime,
                 price
            )

            line.set_xy2(
                 ln,
                 time,
                 price
            )

            line.set_extend(
                 ln,
                 extend.right
            )

            line.set_color(
                 ln,
                 finalColor
            )

            line.set_width(
                 ln,
                 lineWidth
            )

            line.set_style(
                 ln,
                 i == 0 or i == array.size(fibLevels) - 1
                 ? line.style_solid
                 : line.style_dotted
            )

            // LABEL

            label.set_x(
                 lb,
                 time
            )

            label.set_y(
                 lb,
                 price
            )

            label.set_text(
                 lb,
                 show and showLabels
                 ? tag + " " + levelName + " | " + biasText
                 : ""
            )

            label.set_textcolor(
                 lb,
                 textColor
            )

            label.set_color(
                 lb,
                 color.new(color.black, 100)
            )

            label.set_style(
                 lb,
                 label.style_label_left
            )

            label.set_size(
                 lb,
                 size.small
            )

// ─────────────────────────────
// LABEL MODE
// ─────────────────────────────

dailyTag =
     labelMode == "Full Name"
     ? "Past Day"
     : "PD"

weeklyTag =
     labelMode == "Full Name"
     ? "Past Week"
     : "PW"

monthlyTag =
     labelMode == "Full Name"
     ? "Past Month"
     : "PM"

// ─────────────────────────────
// DRAW FIBONACCIS
// ─────────────────────────────

f_update(
     showDaily,
     dailyTag,
     dOpen,
     dHigh,
     dLow,
     dClose,
     dTime,
     dailyColor,
     dailyLines,
     dailyLabels
)

f_update(
     showWeekly,
     weeklyTag,
     wOpen,
     wHigh,
     wLow,
     wClose,
     wTime,
     weeklyColor,
     weeklyLines,
     weeklyLabels
)

f_update(
     showMonthly,
     monthlyTag,
     mOpen,
     mHigh,
     mLow,
     mClose,
     mTime,
     monthlyColor,
     monthlyLines,
     monthlyLabels
)
````

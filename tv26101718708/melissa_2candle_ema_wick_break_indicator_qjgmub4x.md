# Melissa 2-Candle EMA Wick Break Indicator

- url: https://www.tradingview.com/script/qJgmUb4X-Melissa-2-Candle-EMA-Wick-Break-Indicator/
- type: indicator
- pine_id: PUB;8253257c37c140ab8a8495ac054300b4
- version: 1.0

## Description

**Melissa 2-Candle EMA Wick Break Indicator**

The Melissa 2-Candle EMA Wick Break Indicator is designed to identify simple momentum-based continuation entries after price crosses an Exponential Moving Average.

The indicator looks for a two-candle confirmation pattern using two candles of the same colour. For a bullish setup, two green candles must form while price moves from at or below the EMA to closing above it. For a bearish setup, two red candles must form while price moves from at or above the EMA to closing below it.

Once the two-candle setup is confirmed, the indicator does not trigger an entry immediately. Instead, it waits for price to break the wick of the second candle. A long entry signal appears when price breaks above the second candle’s high, and a short entry signal appears when price breaks below the second candle’s low.

The indicator also plots the EMA, setup markers, pending wick-break levels, entry signals, and optional stop loss and take profit reference levels. The default trade example is based on 10 contracts with a $300 target, but these values can be adjusted in the settings.

This tool is intended to help traders visually identify cleaner EMA crossover opportunities with confirmation, rather than entering on the first touch or break of the moving average.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © Quant

//@version=6
indicator("2-Candle EMA Wick Break Indicator", overlay = true, max_labels_count = 500, max_lines_count = 500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

emaLength = input.int(21, "EMA Length", group = "Indicator Settings")

contracts = input.int(10, "Contracts", minval = 1, group = "Risk / Target")
targetProfitUSD = input.float(300, "Take Profit $", minval = 1, group = "Risk / Target")

barsToWaitForBreak = input.int(10, "Bars To Wait For Wick Break", minval = 1, maxval = 100, group = "Entry Settings")

showSetupMarkers = input.bool(true, "Show Setup Markers", group = "Visuals")
showEntryMarkers = input.bool(true, "Show Entry Markers", group = "Visuals")
showEntryLevels = input.bool(true, "Show Pending Wick Break Levels", group = "Visuals")
showSLTP = input.bool(true, "Show SL / TP Lines After Entry", group = "Visuals")

useTimeFilter = input.bool(false, "Enable Time Filter", group = "Time Filter")
tz = input.string("UTC+1", "Timezone", group = "Time Filter")

startHour = input.int(9, "Start Hour", minval = 0, maxval = 23, group = "Time Filter")
startMinute = input.int(30, "Start Minute", minval = 0, maxval = 59, group = "Time Filter")
endHour = input.int(16, "End Hour", minval = 0, maxval = 23, group = "Time Filter")
endMinute = input.int(0, "End Minute", minval = 0, maxval = 59, group = "Time Filter")

tradeDirection = input.string(
     "Both",
     "Trade Direction",
     options = ["Both", "Long Only", "Short Only"],
     group = "Filters"
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Time Filter
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

inSession = true

if useTimeFilter
    currentMinutes = hour(time, tz) * 60 + minute(time, tz)
    startMinutes = startHour * 60 + startMinute
    endMinutes = endHour * 60 + endMinute

    if startMinutes <= endMinutes
        inSession := currentMinutes >= startMinutes and currentMinutes <= endMinutes
    else
        inSession := currentMinutes >= startMinutes or currentMinutes <= endMinutes

bgcolor(useTimeFilter and inSession ? color.new(color.blue, 90) : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ema = ta.ema(close, emaLength)
plot(ema, "EMA", color = color.blue, linewidth = 2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2-Candle EMA Setup Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Candle 1 = previous candle.
// Candle 2 = current candle.

candle1Green = close[1] > open[1]
candle2Green = close > open

candle1Red = close[1] < open[1]
candle2Red = close < open

twoGreen = candle1Green and candle2Green
twoRed = candle1Red and candle2Red

// Long rule:
// 2 green candles.
// During those 2 candles, price must have been at/below EMA.
// Candle 2 must close above EMA.
bullishSetup =
     twoGreen and
     (low[1] <= ema[1] or low <= ema) and
     close > ema

// Short rule:
// 2 red candles.
// During those 2 candles, price must have been at/above EMA.
// Candle 2 must close below EMA.
bearishSetup =
     twoRed and
     (high[1] >= ema[1] or high >= ema) and
     close < ema

longAllowed = (tradeDirection == "Both" or tradeDirection == "Long Only") and inSession
shortAllowed = (tradeDirection == "Both" or tradeDirection == "Short Only") and inSession

bullishSetup := bullishSetup and longAllowed
bearishSetup := bearishSetup and shortAllowed

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Stored Setup State
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var bool waitingLong = false
var bool waitingShort = false

var float longBreakLevel = na
var float shortBreakLevel = na
var float storedSL = na
var float storedTP = na
var int setupBar = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Store Setup After Candle 2 Closes
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

newBullishSetup = bullishSetup and not waitingLong and not waitingShort
newBearishSetup = bearishSetup and not waitingLong and not waitingShort

if newBullishSetup
    waitingLong := true
    waitingShort := false

    longBreakLevel := high
    shortBreakLevel := na

    storedSL := open

    pointsForTP = targetProfitUSD / (syminfo.pointvalue * contracts)
    storedTP := longBreakLevel + pointsForTP

    setupBar := bar_index

if newBearishSetup
    waitingShort := true
    waitingLong := false

    shortBreakLevel := low
    longBreakLevel := na

    storedSL := open

    pointsForTP = targetProfitUSD / (syminfo.pointvalue * contracts)
    storedTP := shortBreakLevel - pointsForTP

    setupBar := bar_index

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Wick Break Entry Triggers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Entry happens only after candle 2 has closed.
// Long entry = price breaks above candle 2 high.
// Short entry = price breaks below candle 2 low.

longEntry =
     waitingLong and
     not na(setupBar) and
     bar_index > setupBar and
     high > longBreakLevel

shortEntry =
     waitingShort and
     not na(setupBar) and
     bar_index > setupBar and
     low < shortBreakLevel

// Cancel setup if wick break does not happen within selected bars.
setupExpired =
     not na(setupBar) and
     bar_index > setupBar + barsToWaitForBreak

if longEntry or shortEntry or setupExpired
    waitingLong := false
    waitingShort := false
    setupBar := na
    longBreakLevel := na
    shortBreakLevel := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Visuals
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(
     showSetupMarkers and newBullishSetup,
     title = "Bullish 2-Candle Setup",
     style = shape.triangleup,
     location = location.belowbar,
     color = color.green,
     size = size.small,
     text = "SETUP"
)

plotshape(
     showSetupMarkers and newBearishSetup,
     title = "Bearish 2-Candle Setup",
     style = shape.triangledown,
     location = location.abovebar,
     color = color.red,
     size = size.small,
     text = "SETUP"
)

plotshape(
     showEntryMarkers and longEntry,
     title = "Long Entry",
     style = shape.labelup,
     location = location.belowbar,
     color = color.lime,
     textcolor = color.black,
     size = size.small,
     text = "LONG"
)

plotshape(
     showEntryMarkers and shortEntry,
     title = "Short Entry",
     style = shape.labeldown,
     location = location.abovebar,
     color = color.red,
     textcolor = color.white,
     size = size.small,
     text = "SHORT"
)

plot(
     showEntryLevels and waitingLong ? longBreakLevel : na,
     title = "Pending Long Wick Break",
     color = color.green,
     style = plot.style_linebr,
     linewidth = 2
)

plot(
     showEntryLevels and waitingShort ? shortBreakLevel : na,
     title = "Pending Short Wick Break",
     color = color.red,
     style = plot.style_linebr,
     linewidth = 2
)

plot(
     showSLTP and (longEntry or shortEntry) ? storedSL : na,
     title = "Signal Stop Loss",
     color = color.red,
     style = plot.style_circles,
     linewidth = 2
)

plot(
     showSLTP and (longEntry or shortEntry) ? storedTP : na,
     title = "Signal Take Profit",
     color = color.green,
     style = plot.style_circles,
     linewidth = 2
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Labels On Entry
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if longEntry
    label.new(
         bar_index,
         low,
         "LONG\nEntry > " + str.tostring(storedTP - (targetProfitUSD / (syminfo.pointvalue * contracts))) +
         "\nSL: " + str.tostring(storedSL) +
         "\nTP: " + str.tostring(storedTP),
         style = label.style_label_up,
         color = color.lime,
         textcolor = color.black
    )

if shortEntry
    label.new(
         bar_index,
         high,
         "SHORT\nEntry < " + str.tostring(storedTP + (targetProfitUSD / (syminfo.pointvalue * contracts))) +
         "\nSL: " + str.tostring(storedSL) +
         "\nTP: " + str.tostring(storedTP),
         style = label.style_label_down,
         color = color.red,
         textcolor = color.white
    )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(newBullishSetup, title = "Bullish Setup", message = "Bullish 2-candle EMA setup formed. Waiting for candle 2 high break.")
alertcondition(newBearishSetup, title = "Bearish Setup", message = "Bearish 2-candle EMA setup formed. Waiting for candle 2 low break.")

alertcondition(longEntry, title = "Long Entry Triggered", message = "Long entry triggered: price broke candle 2 high.")
alertcondition(shortEntry, title = "Short Entry Triggered", message = "Short entry triggered: price broke candle 2 low.")
````

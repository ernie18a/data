# Bitcoin Power Law Floor

- url: https://www.tradingview.com/script/AK0Maiiu-Bitcoin-Power-Law-Floor/
- type: indicator
- pine_id: PUB;580ba17eb9034ffeb19feacd64771399
- version: 1.0

## Description

[b]Bitcoin Power Law Floor[/b]

This indicator plots a long-term Bitcoin Power Law Floor based on the empirical Bitcoin power-law framework associated with Giovanni Santostasi, Harold Christopher Burger, Andrei Perrenod, Bitcoin Observatory, and related Bitcoin power-law research.

The model uses days since Bitcoin’s genesis block as the time variable:

Trend(t) = 10^-16.493 × t^5.688
Floor(t) = Trend(t) × 10^-0.42

The default floor offset in this script is -0.42. For the commonly referenced ~0.40× trend floor, set “Floor log10 offset vs trend” to -0.40.

The plotted floor is intended to represent a historically observed lower-bound region in Bitcoin’s long-term price evolution. It is not a guarantee, not a prediction, and not a trading signal by itself. The model should be used as a long-term reference framework, ideally on BTCUSD or BTCUSDT charts with logarithmic price scale enabled.

The script includes:
- Bitcoin Power Law Floor plot
- Optional central power-law trend line
- Optional future floor projection
- Projection horizons of 3, 5, 10, 15, 20, and 25 years

[b]Sources and further reading:[/b]

Bitcoin Observatory — BTC Power Law Floor:
https://btcpowerlaw.nl/floor/

Giovanni Santostasi — The Bitcoin Power Law Theory:
https://giovannisantostasi.medium.com/the-bitcoin-power-law-theory-962dfaf99ee9

Scientific Bitcoin Institute:
https://scientificbitcoininstitute.org/

Special thanks to the scientists, researchers, explorers, data analysts, builders, educators, and content writers who study, test, explain, challenge, and share Bitcoin power-law models. This script exists because of the open work of people exploring Bitcoin with curiosity, rigor, and imagination.

This indicator is for educational and research purposes only. It is not financial advice. Historical model fit does not guarantee future performance.

## Source Code

````pine
//@version=6
// Bitcoin Power Law Floor
//
// This script plots a long-term Bitcoin Power Law Floor using the model:
//
// Trend(t) = 10^-16.493 * t^5.688
// Floor(t) = Trend(t) * 10^-0.42
//
// where t = days since Bitcoin genesis block, 2009-01-03.
//
// The default floor offset in this script is -0.42.
// You can change it in the settings. For the commonly referenced
// 10^-0.4 floor, set "Floor log10 offset vs trend" to -0.40.
//
// Sources and further reading:
//
// BTC Power Law Floor:
// https://btcpowerlaw.nl/floor/
//
// Giovanni Santostasi - The Bitcoin Power Law Theory:
// https://giovannisantostasi.medium.com/the-bitcoin-power-law-theory-962dfaf99ee9
//
// Scientific Bitcoin Institute:
// https://scientificbitcoininstitute.org/
//
// Thank you to the scientists, researchers, explorers, data analysts,
// builders, educators, content writers, and everyone who studies,
// tests, explains, challenges, and shares Bitcoin power-law models.
//
// Educational and research tool only. Not financial advice.

indicator("Bitcoin Power Law Floor", shorttitle="BTC Power Law Floor", overlay=true, format=format.inherit, max_lines_count=100, max_labels_count=100)

// ============================================================================
// Inputs
// ============================================================================

// Model
intercept = input.float(-16.493, "Power-law intercept", step=0.001, group="Model")
exponent = input.float(5.688, "Power-law exponent", step=0.001, group="Model")
floorLogOffset = input.float(-0.42, "Floor log10 offset vs trend", step=0.01, group="Model")

// Display
showTrend = input.bool(false, "Show power-law trend", group="Display")
showCurrentLabel = input.bool(true, "Show current floor label", group="Display")

// Projection
showProjection = input.bool(true, "Show future floor projection", group="Projection")
projectionYears = input.int(5, "Projection horizon in years", options=[3, 5, 10, 15, 20, 25], group="Projection")
showProjectionLabels = input.bool(true, "Show projection milestone labels", group="Projection")

// Style
floorColor = input.color(color.orange, "Floor color", group="Style")
trendColor = input.color(color.blue, "Trend color", group="Style")
projectionLineTransparency = input.int(35, "Projection line transparency", minval=0, maxval=100, group="Style")
projectionLabelTransparency = input.int(5, "Projection label transparency", minval=0, maxval=100, group="Style")

// ============================================================================
// Constants
// ============================================================================

GENESIS_TIME = timestamp("UTC", 2009, 1, 3, 0, 0)
MS_PER_DAY = 86400000.0
MS_PER_YEAR = MS_PER_DAY * 365.25

// ============================================================================
// Helper functions
// ============================================================================

getDaysSinceGenesis(sourceTime) =>
    math.max(float(sourceTime - GENESIS_TIME) / MS_PER_DAY, 1.0)

getTrend(daysSinceGenesis) =>
    math.pow(10.0, intercept) * math.pow(daysSinceGenesis, exponent)

getFloor(daysSinceGenesis) =>
    getTrend(daysSinceGenesis) * math.pow(10.0, floorLogOffset)

formatPrice(value) =>
    "$" + str.format("{0,number,integer}", value)

isProjectionMilestone(yearsAhead) =>
    yearsAhead == 3 or yearsAhead == 5 or yearsAhead == 10 or yearsAhead == 15 or yearsAhead == 20 or yearsAhead == 25

// ============================================================================
// Current model values
// ============================================================================

daysSinceGenesis = getDaysSinceGenesis(time)

trend = getTrend(daysSinceGenesis)
floor = getFloor(daysSinceGenesis)

// ============================================================================
// Historical plots
// ============================================================================

plot(floor, title="Bitcoin Power Law Floor", color=floorColor, linewidth=2)
plot(showTrend ? trend : na, title="Bitcoin Power Law Trend", color=color.new(trendColor, 40), linewidth=1)

// ============================================================================
// Current floor label
// ============================================================================

var label currentFloorLabel = na

if barstate.islast
    if not na(currentFloorLabel)
        label.delete(currentFloorLabel)
        currentFloorLabel := na

    if showCurrentLabel
        currentLabelText = "Current floor\n" + formatPrice(floor)
        currentLabelColor = color.new(floorColor, 0)
        currentFloorLabel := label.new(bar_index, floor, currentLabelText, style=label.style_label_left, textcolor=color.white, color=currentLabelColor)

// ============================================================================
// Future projection storage
// ============================================================================

var line[] projectionLines = array.new_line()
var label[] projectionLabels = array.new_label()

// ============================================================================
// Delete old future projection objects
// ============================================================================

if barstate.islast
    projectionLineCount = array.size(projectionLines)

    if projectionLineCount > 0
        for index = 0 to projectionLineCount - 1
            line.delete(array.get(projectionLines, index))

        array.clear(projectionLines)

    projectionLabelCount = array.size(projectionLabels)

    if projectionLabelCount > 0
        for index = 0 to projectionLabelCount - 1
            label.delete(array.get(projectionLabels, index))

        array.clear(projectionLabels)

// ============================================================================
// Draw future floor projection
// ============================================================================

if barstate.islast and showProjection
    previousTime = time
    previousFloor = floor

    projectionLineColor = color.new(floorColor, projectionLineTransparency)
    projectionLabelColor = color.new(floorColor, projectionLabelTransparency)

    for yearsAhead = 1 to projectionYears
        futureTime = time + int(yearsAhead * MS_PER_YEAR)
        futureDaysSinceGenesis = getDaysSinceGenesis(futureTime)
        futureFloor = getFloor(futureDaysSinceGenesis)

        projectionLine = line.new(previousTime, previousFloor, futureTime, futureFloor, xloc=xloc.bar_time, extend=extend.none, color=projectionLineColor, style=line.style_dashed, width=2)
        array.push(projectionLines, projectionLine)

        if showProjectionLabels and isProjectionMilestone(yearsAhead)
            projectionLabelText = str.tostring(yearsAhead) + "Y floor\n" + formatPrice(futureFloor)
            projectionLabel = label.new(futureTime, futureFloor, projectionLabelText, xloc=xloc.bar_time, style=label.style_label_left, textcolor=color.white, color=projectionLabelColor)
            array.push(projectionLabels, projectionLabel)

        previousTime := futureTime
        previousFloor := futureFloor
````

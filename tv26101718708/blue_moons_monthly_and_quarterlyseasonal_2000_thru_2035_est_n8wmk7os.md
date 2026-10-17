# Blue Moons Monthly and Quarterly/Seasonal 2000 thru 2035 EST

- url: https://www.tradingview.com/script/N8WMK7Os-Blue-Moons-Monthly-and-Quarterly-Seasonal-2000-thru-2035-EST/
- type: indicator
- pine_id: PUB;e73ef498fd1f480e93fa2e5edfc4dc97
- version: 2.0

## Description

This indicator marks historical and projected Blue Moon events on the chart from 2000 through 2035, using fixed Eastern Standard Time (EST / UTC−5).

The script includes both major Blue Moon definitions:

Monthly Blue Moons
A monthly Blue Moon occurs when there are two Full Moons in the same calendar month. This script marks both Full Moons in each Blue Moon month with solid blue vertical lines.

Quarterly / Seasonal Blue Moons
A quarterly or seasonal Blue Moon occurs when an astronomical season contains four Full Moons instead of the usual three. The Blue Moon is the third Full Moon in that season. These are marked with dashed light-blue vertical lines.

The purpose of this indicator is to help visually study potential market correlations around rare lunar timing events. It is designed for historical research, cycle analysis, and astro-financial timing studies.

## Source Code

````pine
//@version=6
indicator("Blue Moons — Monthly + Quarterly/Seasonal EST 2000–2035", overlay=true, scale=scale.none, max_lines_count=500, max_labels_count=500)

// ---------------------------------------------------------
// BLUE MOON DEFINITIONS
// ---------------------------------------------------------
// Monthly Blue Moon:
// A calendar month with two Full Moons.
// This script marks BOTH Full Moons in that month with SOLID BLUE lines.
//
// Quarterly / Seasonal Blue Moon:
// The third Full Moon in an astronomical season/quarter containing four Full Moons.
// This script marks these with DASHED LIGHT-BLUE lines.
//
// Timezone: fixed EST = UTC-5
// Date range: 2000–2035
// ---------------------------------------------------------

showMonthly  = input.bool(true, "Show Monthly Blue Moon Pairs")
showSeasonal = input.bool(true, "Show Quarterly / Seasonal Blue Moons")
showLabels   = input.bool(true, "Show Labels")

monthlyColor  = input.color(color.blue, "Monthly Line Color")
monthlyWidth  = input.int(2, "Monthly Line Width", minval=1, maxval=5)

seasonalColor = input.color(color.rgb(80, 200, 255), "Quarterly / Seasonal Line Color")
seasonalWidth = input.int(2, "Quarterly / Seasonal Line Width", minval=1, maxval=5)

labelHeightMultiplier = input.float(1.25, "Label Height Multiplier", minval=0.25, step=0.05)

// ---------------------------------------------------------
// ARRAYS
// ---------------------------------------------------------

var int[] monthlyTimes = array.new_int()
var string[] monthlyLabels = array.new_string()

var int[] seasonalTimes = array.new_int()
var string[] seasonalLabels = array.new_string()

var bool linesDrawn = false

addMonthly(int y, int mo, int d, int h, int mi, string labelText) =>
    array.push(monthlyTimes, timestamp("GMT-5", y, mo, d, h, mi))
    array.push(monthlyLabels, labelText)

addSeasonal(int y, int mo, int d, int h, int mi, string labelText) =>
    array.push(seasonalTimes, timestamp("GMT-5", y, mo, d, h, mi))
    array.push(seasonalLabels, labelText)

// ---------------------------------------------------------
// LOAD EVENTS
// ---------------------------------------------------------

if barstate.isfirst
    // -----------------------------
    // MONTHLY BLUE MOON PAIRS
    // Solid blue lines
    // -----------------------------

    // November 2001
    addMonthly(2001, 11, 1, 0, 41, "Monthly Blue Moon Pair\nFull Moon 1\nNov 1, 2001")
    addMonthly(2001, 11, 30, 15, 49, "Monthly Blue Moon Pair\nBlue Moon\nNov 30, 2001")

    // July 2004
    addMonthly(2004, 7, 2, 6, 9, "Monthly Blue Moon Pair\nFull Moon 1\nJul 2, 2004")
    addMonthly(2004, 7, 31, 13, 5, "Monthly Blue Moon Pair\nBlue Moon\nJul 31, 2004")

    // May 2007 — EST definition places the pair in May
    addMonthly(2007, 5, 2, 5, 9, "Monthly Blue Moon Pair\nFull Moon 1\nMay 2, 2007")
    addMonthly(2007, 5, 31, 20, 4, "Monthly Blue Moon Pair\nBlue Moon\nMay 31, 2007")

    // December 2009
    addMonthly(2009, 12, 2, 2, 30, "Monthly Blue Moon Pair\nFull Moon 1\nDec 2, 2009")
    addMonthly(2009, 12, 31, 14, 13, "Monthly Blue Moon Pair\nBlue Moon\nDec 31, 2009")

    // August 2012
    addMonthly(2012, 8, 1, 22, 27, "Monthly Blue Moon Pair\nFull Moon 1\nAug 1, 2012")
    addMonthly(2012, 8, 31, 8, 58, "Monthly Blue Moon Pair\nBlue Moon\nAug 31, 2012")

    // July 2015
    addMonthly(2015, 7, 1, 21, 20, "Monthly Blue Moon Pair\nFull Moon 1\nJul 1, 2015")
    addMonthly(2015, 7, 31, 5, 43, "Monthly Blue Moon Pair\nBlue Moon\nJul 31, 2015")

    // January 2018
    addMonthly(2018, 1, 1, 21, 24, "Monthly Blue Moon Pair\nFull Moon 1\nJan 1, 2018")
    addMonthly(2018, 1, 31, 8, 27, "Monthly Blue Moon Pair\nBlue Moon\nJan 31, 2018")

    // March 2018
    addMonthly(2018, 3, 1, 19, 51, "Monthly Blue Moon Pair\nFull Moon 1\nMar 1, 2018")
    addMonthly(2018, 3, 31, 7, 37, "Monthly Blue Moon Pair\nBlue Moon\nMar 31, 2018")

    // October 2020
    addMonthly(2020, 10, 1, 16, 5, "Monthly Blue Moon Pair\nFull Moon 1\nOct 1, 2020")
    addMonthly(2020, 10, 31, 9, 49, "Monthly Blue Moon Pair\nBlue Moon\nOct 31, 2020")

    // August 2023
    addMonthly(2023, 8, 1, 13, 31, "Monthly Blue Moon Pair\nFull Moon 1\nAug 1, 2023")
    addMonthly(2023, 8, 30, 20, 35, "Monthly Blue Moon Pair\nBlue Moon\nAug 30, 2023")

    // May 2026
    addMonthly(2026, 5, 1, 12, 23, "Monthly Blue Moon Pair\nFull Moon 1\nMay 1, 2026")
    addMonthly(2026, 5, 31, 3, 45, "Monthly Blue Moon Pair\nBlue Moon\nMay 31, 2026")

    // December 2028
    addMonthly(2028, 12, 1, 20, 40, "Monthly Blue Moon Pair\nFull Moon 1\nDec 1, 2028")
    addMonthly(2028, 12, 31, 11, 48, "Monthly Blue Moon Pair\nBlue Moon\nDec 31, 2028")

    // September 2031
    addMonthly(2031, 9, 1, 4, 20, "Monthly Blue Moon Pair\nFull Moon 1\nSep 1, 2031")
    addMonthly(2031, 9, 30, 13, 58, "Monthly Blue Moon Pair\nBlue Moon\nSep 30, 2031")

    // July 2034
    addMonthly(2034, 7, 1, 12, 44, "Monthly Blue Moon Pair\nFull Moon 1\nJul 1, 2034")
    addMonthly(2034, 7, 31, 0, 54, "Monthly Blue Moon Pair\nBlue Moon\nJul 31, 2034")

    // -----------------------------
    // QUARTERLY / SEASONAL BLUE MOONS
    // Dashed light-blue lines
    // -----------------------------

    addSeasonal(2000, 2, 19, 11, 27, "Quarterly / Seasonal Blue Moon\nFeb 19, 2000")
    addSeasonal(2002, 8, 22, 17, 29, "Quarterly / Seasonal Blue Moon\nAug 22, 2002")
    addSeasonal(2005, 8, 19, 12, 53, "Quarterly / Seasonal Blue Moon\nAug 19, 2005")
    addSeasonal(2008, 5, 19, 21, 11, "Quarterly / Seasonal Blue Moon\nMay 19, 2008")
    addSeasonal(2010, 11, 21, 12, 27, "Quarterly / Seasonal Blue Moon\nNov 21, 2010")
    addSeasonal(2013, 8, 20, 20, 45, "Quarterly / Seasonal Blue Moon\nAug 20, 2013")
    addSeasonal(2016, 5, 21, 16, 15, "Quarterly / Seasonal Blue Moon\nMay 21, 2016")
    addSeasonal(2019, 5, 18, 16, 11, "Quarterly / Seasonal Blue Moon\nMay 18, 2019")
    addSeasonal(2021, 8, 22, 7, 2, "Quarterly / Seasonal Blue Moon\nAug 22, 2021")
    addSeasonal(2024, 8, 19, 13, 26, "Quarterly / Seasonal Blue Moon\nAug 19, 2024")
    addSeasonal(2027, 5, 20, 5, 59, "Quarterly / Seasonal Blue Moon\nMay 20, 2027")
    addSeasonal(2029, 8, 23, 20, 51, "Quarterly / Seasonal Blue Moon\nAug 23, 2029")
    addSeasonal(2032, 8, 20, 20, 47, "Quarterly / Seasonal Blue Moon\nAug 20, 2032")
    addSeasonal(2035, 5, 21, 23, 26, "Quarterly / Seasonal Blue Moon\nMay 21, 2035")

// ---------------------------------------------------------
// DRAW ALL LINES, INCLUDING FUTURE EVENTS
// ---------------------------------------------------------
// This version does NOT wait for the event bar to exist.
// It draws all vertical lines using xloc.bar_time.
// extend.none is used to prevent unwanted horizontal artifacts.
// scale=scale.none prevents the large y-values from distorting chart scale.
// ---------------------------------------------------------

lineBottom = math.max(close / 1000000.0, 0.00000001)
lineTop    = close * 1000000.0
labelY     = close * labelHeightMultiplier

if barstate.islast and not linesDrawn
    if showMonthly
        for i = 0 to array.size(monthlyTimes) - 1
            eventTime = array.get(monthlyTimes, i)
            eventLabel = array.get(monthlyLabels, i)

            line.new(x1=eventTime, y1=lineBottom, x2=eventTime, y2=lineTop, xloc=xloc.bar_time, extend=extend.none, color=monthlyColor, width=monthlyWidth, style=line.style_solid)

            if showLabels
                label.new(x=eventTime, y=labelY, text=eventLabel, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_down, color=color.new(monthlyColor, 0), textcolor=color.white, size=size.small)

    if showSeasonal
        for i = 0 to array.size(seasonalTimes) - 1
            eventTime = array.get(seasonalTimes, i)
            eventLabel = array.get(seasonalLabels, i)

            line.new(x1=eventTime, y1=lineBottom, x2=eventTime, y2=lineTop, xloc=xloc.bar_time, extend=extend.none, color=seasonalColor, width=seasonalWidth, style=line.style_dashed)

            if showLabels
                label.new(x=eventTime, y=labelY, text=eventLabel, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_down, color=color.new(seasonalColor, 0), textcolor=color.black, size=size.small)

    linesDrawn := true
````

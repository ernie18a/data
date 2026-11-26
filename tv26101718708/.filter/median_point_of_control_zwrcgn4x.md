# Median Point of Control

- url: https://www.tradingview.com/script/zwRcGn4x-Median-Point-of-Control/
- type: indicator
- pine_id: PUB;99837b5502ae44acbedbf89859205e65
- version: 1.0

## Description

[b]Median Point of Control[/b] calculates and displays the median OHLC4 price for customizable time periods, along with percentage-based upper and lower bands. It provides a statistical reference framework for identifying potential support, resistance, and mean-reversion zones.

[b]What It Does[/b]
This indicator computes the [b]median[/b] of all OHLC4 values within a defined period and plots three horizontal levels:
[list]
[*]Median Line — The statistical middle price of the period
[*]Upper Band — Median + user-defined percentage
[*]Lower Band — Median - user-defined percentage
[/list]
The current period's levels update dynamically as new bars form. Completed periods are preserved as historical reference lines.

[b]Why Median Instead of Average?[/b]
The median is the "middle" value when all prices are sorted. Unlike the mean (average), the median is [b]resistant to outliers[/b] — a single extreme wick or price spike won't distort the level. This makes it more representative of typical price action during the period.

[b]Two Calculation Modes[/b]
[list=1]
[*]Timeframe Mode Define periods using standard timeframes: 4H, Daily, Weekly, Monthly, etc. The indicator automatically detects when each period begins and ends.
[*]Bars Mode Define periods by a fixed number of bars (e.g., every 50 bars, every 100 bars). Useful for non-time-based analysis or custom period lengths that don't align with standard timeframes.
[/list]
[b]Settings[/b]
[list]
[*]Calculation Mode: Choose between Timeframe or Bars
[*]Timeframe: Period length when using Timeframe mode
[*]Bars: Number of bars per period when using Bars mode
[*]Band Distance (%): Percentage offset for upper/lower bands from median
[*]Line Colors: Customize colors for median, upper, and lower bands
[*]Line Width: Thickness of the plotted lines
[*]Historical Transparency: Opacity of completed period lines
[*]Max Historical Periods: Number of past periods to display
[/list]
[b]How To Use[/b]
[list=1]
[*][b]Identify the range:[/b] The upper and lower bands create a price envelope based on the period's median. When price approaches these levels, watch for reactions.
[*][b]Mean reversion reference:[/b] The median line represents the "fair value" of the period. Price tends to oscillate around this level.
[*][b]Breakout detection:[/b] If price breaks and holds beyond a band, it may signal trend continuation rather than reversion.
[*][b]Multi-timeframe analysis:[/b] Use Daily median on intraday charts to see where price stands relative to the day's statistical center.
[/list]
[b]Important Notes[/b]
[list]
[*]This indicator does not predict price direction. It provides statistical reference levels only.
[*]The current period's median updates with each new bar — this is expected behavior, not repainting.
[*]Historical period lines are fixed once their period closes.
[*]For best results, use on liquid instruments (stocks, forex majors, major crypto pairs).
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © exploretranspose

// =============================================================================
// Median POC
// =============================================================================
// Calculates and plots OHLC4 median with upper/lower percentage bands
// Supports two modes: Timeframe-based periods or custom bar count periods
// =============================================================================

//@version=6
indicator(title="Median Point of Control", shorttitle="Median POC", overlay=true, max_lines_count = 500)

// -----------------------------------------------------------------------------
// Inputs
// -----------------------------------------------------------------------------

// Mode selection
string modeInput = input.string(
     title="Calculation Mode",
     defval="Timeframe",
     options=["Timeframe", "Bars"],
     group="Period Settings"
     )

string tfInput = input.timeframe(
     title="Timeframe",
     defval="D",
     tooltip="Period timeframe",
     group="Period Settings"
     )

int barsBackInput = input.int(
     title="Number of Bars",
     defval=100,
     minval=2,
     tooltip="Number of bars per period",
     group="Period Settings"
     )

// Band settings
float bandPercent = input.float(
     title="Band Distance (%)",
     defval=1.0,
     minval=0.1,
     step=0.1,
     tooltip="Percentage distance for upper and lower bands from median",
     group="Bands"
     )

// Visual settings
color medianColor = input.color(title="Median Line", defval=color.black, group="Style")
color upperBandColor = input.color(title="Upper Band", defval=color.new(#FE5F55, 0), group="Style")
color lowerBandColor = input.color(title="Lower Band", defval=color.new(#659B5E, 0), group="Style")
int lineWidthInput = input.int(title="Line Width", defval=2, minval=1, maxval=5, group="Style")
int historyAlpha = input.int(title="Historical Lines Transparency", defval=0, minval=0, maxval=100, group="Style")
int maxLines = input.int(title="Max Historical Periods", defval=100, minval=1, maxval=500, group="Style")

// -----------------------------------------------------------------------------
// Period Detection
// -----------------------------------------------------------------------------

// Timeframe mode: detect when selected timeframe changes
bool isNewPeriod_TF = timeframe.change(tfInput)

// Bars back mode: count bars
var int barCounter = 0
barCounter += 1
bool isNewPeriod_Bars = barCounter >= barsBackInput
if isNewPeriod_Bars
    barCounter := 0

// Select detection method based on mode
bool isNewPeriod = modeInput == "Timeframe" ? isNewPeriod_TF : isNewPeriod_Bars

// -----------------------------------------------------------------------------
// OHLC4 Collection & Median Calculation
// -----------------------------------------------------------------------------

var array<float> ohlc4Values = array.new<float>(0)

if isNewPeriod
    array.clear(ohlc4Values)

array.push(ohlc4Values, ohlc4)

float currentMedian = array.size(ohlc4Values) > 0 ? array.median(ohlc4Values) : na

// Calculate bands
float bandOffset = currentMedian * (bandPercent / 100)
float upperBand = currentMedian + bandOffset
float lowerBand = currentMedian - bandOffset

// -----------------------------------------------------------------------------
// Historical Period Storage
// -----------------------------------------------------------------------------

var array<line> histMedianLines = array.new<line>(0)
var array<line> histUpperLines = array.new<line>(0)
var array<line> histLowerLines = array.new<line>(0)

var int periodStart = 0
var float lastMedian = na
var float lastUpper = na
var float lastLower = na

if isNewPeriod
    // Save completed period as historical lines
    if bar_index > 0 and not na(lastMedian)
        line mLine = line.new(periodStart, lastMedian, bar_index - 1, lastMedian, 
             color=color.new(medianColor, historyAlpha), width=lineWidthInput)
        line uLine = line.new(periodStart, lastUpper, bar_index - 1, lastUpper, 
             color=color.new(upperBandColor, historyAlpha), width=lineWidthInput)
        line lLine = line.new(periodStart, lastLower, bar_index - 1, lastLower, 
             color=color.new(lowerBandColor, historyAlpha), width=lineWidthInput)
        
        array.push(histMedianLines, mLine)
        array.push(histUpperLines, uLine)
        array.push(histLowerLines, lLine)
        
        // Limit historical lines
        if array.size(histMedianLines) > maxLines
            line.delete(array.shift(histMedianLines))
            line.delete(array.shift(histUpperLines))
            line.delete(array.shift(histLowerLines))
    
    periodStart := bar_index

// Update last values for next period save
lastMedian := currentMedian
lastUpper := upperBand
lastLower := lowerBand

// -----------------------------------------------------------------------------
// Current Period Lines
// -----------------------------------------------------------------------------

var line currMedianLine = na
var line currUpperLine = na
var line currLowerLine = na

if not na(currentMedian)
    // Delete old lines
    if not na(currMedianLine)
        line.delete(currMedianLine)
    if not na(currUpperLine)
        line.delete(currUpperLine)
    if not na(currLowerLine)
        line.delete(currLowerLine)
    
    // Draw new lines
    currMedianLine := line.new(periodStart, currentMedian, bar_index, currentMedian,
         color=medianColor, width=lineWidthInput)
    currUpperLine := line.new(periodStart, upperBand, bar_index, upperBand,
         color=upperBandColor, width=lineWidthInput)
    currLowerLine := line.new(periodStart, lowerBand, bar_index, lowerBand,
         color=lowerBandColor, width=lineWidthInput)
````
